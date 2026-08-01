--[[
-------------------------------------------------------------------------------
-- CustomCompassPins
-------------------------------------------------------------------------------
-- Original author: Shinni, 2014-04-09
--
-- Contributors:
--   Garkin (contributions starting 2014-05-07)
--   Scootworks (contributions starting 2020-05-25)
--
-- Maintainer:
--   Sharlikran (maintainer since 2025-06-11
--   GitHub & CC license confirmation on 2020-05-21)
--
-------------------------------------------------------------------------------
-- This addon includes contributions licensed under the following terms:
--
-- Creative Commons BY-NC-SA 4.0 (original work by Shinni; contributions by Garkin, Scootworks):
--   You are free to share and adapt the material with attribution, but not for
--   commercial purposes. Derivatives must be licensed under the same terms.
--   Full terms at: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
--
-- BSD 3-Clause License (Sharlikran, contributions since 2020-05-21):
--   Redistribution and use in source and binary forms, with or without
--   modification, are permitted under the conditions detailed in the LICENSE file.
--
-------------------------------------------------------------------------------
-- Maintainer Notice:
-- Redistribution of this addon outside of ESOUI.com or GitHub is discouraged
-- unless authorized by the current maintainer. While the CC license permits
-- sharing, uncoordinated uploads may cause version fragmentation or confusion.
-- Please respect the integrity of the ESO addon ecosystem.
-------------------------------------------------------------------------------
]]
local lib = {}
lib.name = "CustomCompassPins"
lib.version = 138

local sharedMapPinManager = ZO_WorldMap_GetPinManager()

--[[
  additionalLayout (optional)

  A table of functions that allow authors to customize compass pin appearance during updates and resets.

  Supports both named keys:
    - "update" – Called after the pin is positioned, sized, and made visible.
    - "reset"  – Called when the pin is released back to the pool.

  And with or without numeric keys for backward compatibility:
    - [1] is treated as "update", [2] as "reset"
    - Without keys, the order matters: the first function is used for updating, the second for resetting

  Using named keys ("update", "reset") is recommended for clarity and maintainability.

  IMPORTANT:
    The "update" function should not override or recalculate values already determined by the compass system—
    such as angle, normalizedAngle, normalizedDistance, position, alpha, or size.
    Doing so may interfere with how pins are displayed or culled.

  Example usage:
    additionalLayout = {
      update = function(pin)
        local icon = pin:GetNamedChild("Background")
        icon:SetColor(1, 0.6, 0.2, 1) -- Custom tint
      end,
      reset = function(pin)
        local icon = pin:GetNamedChild("Background")
        icon:SetColor(1, 1, 1, 1) -- Reset tint
      end,
    }
]]

-- Constants for additionalLayout function keys
CUSTOM_COMPASS_LAYOUT_UPDATE = "update" -- Called when the pin is updated (positioned and resized)
CUSTOM_COMPASS_LAYOUT_RESET = "reset"  -- Called when the pin is reset and returned to the pool

local function GetAdditionalLayoutFunction(layout, key)
  local LEGACY_LAYOUT_UPDATE = 1 -- Legacy numeric fallback for update
  local LEGACY_LAYOUT_RESET = 2 -- Legacy numeric fallback for reset

  local layoutTable = layout.additionalLayout
  if not layoutTable then return nil end

  -- Prefer named keys
  if layoutTable[key] then return layoutTable[key] end

  -- Fallback to legacy numbered keys
  if key == CUSTOM_COMPASS_LAYOUT_UPDATE then
    return layoutTable[LEGACY_LAYOUT_UPDATE]
  elseif key == CUSTOM_COMPASS_LAYOUT_RESET then
    return layoutTable[LEGACY_LAYOUT_RESET]
  end

  return nil
end

local PARENT = COMPASS.container
local FOV = math.pi * 0.6
local coefficients = { 0.16, 1.08, 1.32, 1.14, 1.14, 1.23, 1.16, 1.24, 1.33, 1.00, 1.12, 1.00, 1.00, 0.89, 1.00, 1.37, 1.20, 4.27, 2.67, 3.20, 5.00, 8.45, 0.89, 0.10, 1.14 }

--
-- Base class, can be accessed via COMPASS_PINS
--
local CompassPinManager = ZO_ControlPool:Subclass()

function lib:New(...)
  self:Initialize(...)

  self.control:SetHidden(false)
  self.defaultFOV = FOV
  self:RefreshDistanceCoefficient()

  local lastUpdate = 0
  self.control:SetHandler("OnUpdate", function()
    local now = GetFrameTimeMilliseconds()
    if (now - lastUpdate) >= 20 then
      self:Update()
      lastUpdate = now
    end
  end)

  self:SetupCallbacks()

  return self
end

function lib:Initialize(...)
  --can't create OnUpdate handler on controls created via CreateControl, so i'll have to create somethin else via virtual
  self.control = WINDOW_MANAGER:CreateControlFromVirtual(nil, GuiRoot, "ZO_MapPin")
  self.pinCallbacks = {}
  self.pinLayouts = {}
  self.pinManager = CompassPinManager:New()
end

function lib:SetupCallbacks()
  if _G["CustomCompassPins_MapChangeDetector"] == nil then
    ZO_WorldMap_GetPinManager():AddCustomPin("CustomCompassPins_MapChangeDetector", function()
      local tileIndex = 1
      local currentMap = select(3, (GetMapTileTexture(tileIndex)):lower():find("maps/([%w%-]+/[%w%-]+_%w+)"))
      CALLBACK_MANAGER:FireCallbacks("CustomCompassPins_MapChanged", currentMap)
    end)
    ZO_WorldMap_GetPinManager():SetCustomPinEnabled(_G["CustomCompassPins_MapChangeDetector"], true)

    CALLBACK_MANAGER:RegisterCallback("CustomCompassPins_MapChanged", function(currentMap)
      if self.map ~= currentMap then
        self:RefreshDistanceCoefficient()
        self:RefreshPins()
        self.map = currentMap
      end
    end)
  end

  local callback
  callback = function(oldState, newState)
    if self.version ~= lib.version then
      WORLD_MAP_SCENE:UnregisterCallback("StateChange", callback)
      return
    end
    if newState == SCENE_HIDING then
      if (SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED) then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
      end
    end
  end
  WORLD_MAP_SCENE:RegisterCallback("StateChange", callback)
end

-- pinType should be a string eg "skyshard"
-- pinCallbacks should be a function, it receives the pinManager as argument
-- layout should be table, currently only the key texture is used (which should return a string)
function lib:AddCustomPin(pinType, pinCallback, layout, savedVarTable)
  if type(pinType) ~= "string" or self.pinLayouts[pinType] ~= nil or type(pinCallback) ~= "function" or type(layout) ~= "table" then return end

  -- Optional: Attach a back-reference to the map pin type (from LibMapPins)
  if type(layout.mapPinTypeString) == "string" then
    local pinTypeId = _G[layout.mapPinTypeString]
    if type(pinTypeId) == "number" then
      -- Augment the map pin metadata in sharedMapPinManager
      local pinData = sharedMapPinManager.customPins[pinTypeId]
      if type(pinData) == "table" then
        pinData.compassPinTypeString = pinType
        pinData.onToggleCallback = layout.onToggleCallback
      end
    end
  end

  layout.maxDistance = layout.maxDistance or 0.02
  layout.texture = layout.texture or "EsoUI/Art/MapPins/hostile_pin.dds"

  self.pinCallbacks[pinType] = pinCallback
  self.pinLayouts[pinType] = layout

  -- Handle saved variable state or default to true
  local enabled = true
  if type(savedVarTable) == "table" then
    local svState = savedVarTable[pinType]
    if type(svState) == "boolean" then
      enabled = svState
    else
      savedVarTable[pinType] = true
    end
  end

  self.pinManager:SetCompassPinEnabled(pinType, enabled)
end

-- refreshes/calls the pinCallback of the given pinType
-- refreshes all custom pins if no pinType is given
function lib:RefreshPins(pinType)
  self.pinManager:RemovePins(pinType)
  if pinType then
    if not self.pinCallbacks[pinType] then
      return
    end
    self.pinCallbacks[pinType](self.pinManager)
  else
    for tag, callback in pairs(self.pinCallbacks) do
      callback(self.pinManager)
    end
  end
end

function lib:GetDistanceCoefficient()
  -- coefficient = Auridon size / current map size
  local coefficient = 1
  local mapId = GetCurrentMapIndex()
  if mapId then
    coefficient = coefficients[mapId] or 1 -- zones and starting isles
  else
    if GetMapContentType() == MAP_CONTENT_DUNGEON then
      coefficient = 16 -- all dungeons, value between 8 - 47, usually 16
    elseif GetMapType() == MAPTYPE_SUBZONE then
      coefficient = 6 -- all subzones, value between 5 - 8, usually 6
    end
  end

  return zo_sqrt(coefficient) -- as we do not want that big difference, lets make it smaller...
end

function lib:RefreshDistanceCoefficient()
  self.distanceCoefficient = self:GetDistanceCoefficient()
end

-- updates the pins (recalculates the position of the pins)
function lib:Update()
  local heading = GetPlayerCameraHeading()
  if not heading then return end
  if heading > math.pi then
    --normalize heading to [-pi,pi]
    heading = heading - 2 * math.pi
  end

  local x, y = GetMapPlayerPosition("player")
  self.pinManager:Update(x, y, heading)
end

--
-- pin manager class, updates position etc
--
function CompassPinManager:New(...)
  local result = ZO_ControlPool.New(self, "ZO_MapPin", PARENT, "Pin")
  result:Initialize2(...)

  return result
end

function CompassPinManager:Initialize2(...)
  self.pinData = {}
  self.defaultAngle = 1
  self.compassPinEnabled = {} -- internal compass pin visibility state
end

function CompassPinManager:GetNewPin(data)
  local pin, pinKey = self:AcquireObject()
  self:ResetPin(pin)
  pin:SetHandler("OnMouseDown", nil)
  pin:SetHandler("OnMouseUp", nil)
  pin:SetHandler("OnMouseEnter", nil)
  pin:SetHandler("OnMouseExit", nil)
  pin:GetNamedChild("Highlight"):SetHidden(true)

  pin.xLoc = data.xLoc
  pin.yLoc = data.yLoc
  pin.pinType = data.pinType
  pin.pinTag = data.pinTag
  pin.pinName = data.pinName
  pin.data = data

  local layout = lib.pinLayouts[data.pinType]
  local texture = pin:GetNamedChild("Background")
  texture:SetTexture(layout.texture)

  return pin, pinKey
end

function CompassPinManager:SetCompassPinEnabled(pinType, state)
  if type(state) == "boolean" then
    self.compassPinEnabled[pinType] = state
  end
end

function lib:SetCompassPinEnabled(...)
  return self.pinManager:SetCompassPinEnabled(...)
end

function CompassPinManager:IsCompassPinEnabled(pinType)
  local state = self.compassPinEnabled[pinType]
  return state ~= false -- Treat nil as true (visible by default)
end

function lib:IsCompassPinEnabled(...)
  return self.pinManager:IsCompassPinEnabled(...)
end

-- creates a pin of the given pinType at the given location
-- (radius is not implemented yet)
function CompassPinManager:CreatePin(pinType, pinTag, xLoc, yLoc, pinName, ...)
  if not self:IsCompassPinEnabled(pinType) then return end

  local data = { ... } -- in case the user wants to add more information
  data.xLoc = xLoc or 0
  data.yLoc = yLoc or 0
  data.pinType = pinType or "NoType"
  data.pinTag = pinTag or {}
  data.pinName = pinName

  self:RemovePin(data.pinTag) -- added in 1.29
  -- some addons add new compass pins outside of this libraries callback
  -- function. in such a case the old pins haven't been removed yet and get stuck
  -- see destinations comment section 03/19/16 (uladz) and newer

  self.pinData[pinTag] = data
end

function lib:CreatePin(...)
  return self.pinManager:CreatePin(...)
end

function CompassPinManager:RemovePin(pinTag)
  local entry = self.pinData[pinTag]
  if entry and entry.pinKey then
    self:ReleaseObject(entry.pinKey)
  end
  self.pinData[pinTag] = nil
end

function lib:RemovePin(...)
  return self.pinManager:RemovePin(...)
end

function CompassPinManager:RemovePins(pinType)
  if not pinType then
    self:ReleaseAllObjects()
    self.pinData = {}
  else
    for key, data in pairs(self.pinData) do
      if data.pinType == pinType then
        if data.pinKey then
          self:ReleaseObject(data.pinKey)
        end
        self.pinData[key] = nil
      end
    end
  end
end

function lib:RemovePins(...)
  return self.pinManager:RemovePins(...)
end

function CompassPinManager:ResetPin(pin)
  for _, layout in pairs(lib.pinLayouts) do
    local resetFn = GetAdditionalLayoutFunction(layout, CUSTOM_COMPASS_LAYOUT_RESET)
    if resetFn then
      resetFn(pin)
    end
  end
end

function lib:ResetPin(...)
  return self.pinManager:ResetPin(...)
end

function CompassPinManager:Update(x, y, heading)
  for _, pinData in pairs(self.pinData) do
    self:UpdateSinglePin(pinData, x, y, heading)
  end
end

local function UpdateAngles(xDif, yDif, heading, currentFOV)
  local angle = -math.atan2(xDif, yDif) + heading
  if angle > math.pi then
    angle = angle - 2 * math.pi
  elseif angle < -math.pi then
    angle = angle + 2 * math.pi
  end
  local normalizedAngle = 2 * angle / currentFOV
  local absNormalizedAngle = zo_abs(normalizedAngle)
  return angle, normalizedAngle, absNormalizedAngle
end

local function UpdatePinSize(layout, pin, angle, normalizedAngle, normalizedDistance, absNormalizedAngle)
  if layout.sizeCallback then
    layout.sizeCallback(pin, angle, normalizedAngle, normalizedDistance)
  else
    if absNormalizedAngle > 0.25 then
      pin:SetDimensions(36 - 16 * absNormalizedAngle, 36 - 16 * absNormalizedAngle)
    else
      pin:SetDimensions(32, 32)
    end
  end
end

local function UpdatePinAnchor(pin, normalizedAngle)
  pin:ClearAnchors()
  pin:SetAnchor(CENTER, PARENT, CENTER, 0.5 * PARENT:GetWidth() * normalizedAngle, 0)
end

function CompassPinManager:UpdateSinglePin(pinData, x, y, heading)
  local layout = lib.pinLayouts[pinData.pinType]
  if not layout then return end
  if not layout.maxDistance then layout.maxDistance = 0.05 end

  local distance = layout.maxDistance * lib.distanceCoefficient
  local xDif = x - pinData.xLoc
  local yDif = y - pinData.yLoc
  local normalizedDistance = (xDif * xDif + yDif * yDif) / (distance * distance)

  if normalizedDistance >= 1 then
    if pinData.pinKey then
      self:ReleaseObject(pinData.pinKey)
      pinData.pinKey = nil
    end
    return
  end

  local pin
  if pinData.pinKey then
    pin = self:GetActiveObject(pinData.pinKey)
  else
    pin, pinData.pinKey = self:GetNewPin(pinData)
  end

  if not pin then
    CHAT_ROUTER:AddSystemMessage(string.format("CustomCompassPin Error: no pin with key %s found!", pinData.pinKey))
    return
  end

  local currentFOV = layout.FOV or lib.defaultFOV
  local angle, normalizedAngle, absNormalizedAngle = UpdateAngles(xDif, yDif, heading, currentFOV)

  if absNormalizedAngle > (layout.maxAngle or self.defaultAngle) then
    pin:SetHidden(true)
    return
  end

  UpdatePinAnchor(pin, normalizedAngle)
  UpdatePinSize(layout, pin, angle, normalizedAngle, normalizedDistance, absNormalizedAngle)

  local updateFn = GetAdditionalLayoutFunction(layout, CUSTOM_COMPASS_LAYOUT_UPDATE)
  if updateFn then
    updateFn(pin, angle, normalizedAngle, normalizedDistance)
  end
  pin:SetAlpha(1 - normalizedDistance)

  pin:SetHidden(false)
end

COMPASS_PINS = lib
COMPASS_PINS:New()

--[[
example:

COMPASS_PINS:AddCustomPin("myCompassPins", function()
    for _, pinTag in pairs(myData) do
        COMPASS_PINS:CreatePin("myCompassPins", pinTag, pinTag.x, pinTag.y)
    end
end,
{
    maxDistance = 0.05,
    texture = "esoui/art/compass/quest_assistedareapin.dds"
})
--]]

