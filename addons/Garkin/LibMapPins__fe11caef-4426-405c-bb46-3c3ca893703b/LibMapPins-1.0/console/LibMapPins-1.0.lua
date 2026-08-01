--[[
-------------------------------------------------------------------------------
-- LibMapPins-1.0
-------------------------------------------------------------------------------
-- Core library Copyright (c) 2014, 2015 Ales Machat (Garkin)
--
-- Current maintainer: Sharlikran (contributions since 2020-05-08)
-- Previous maintainers: AssemblerManiac, Ayantir, Fyrakin, Sensi, Scootworks
--
-- ----------------------------------------------------------------------------
-- Core portions of this library are licensed under the following terms:
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- ----------------------------------------------------------------------------
-- Contributions by Sharlikran (starting 2020-05-08) are licensed under the
-- BSD 3-Clause License:
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice,
--    this list of conditions and the following disclaimer.
--
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
--
-- 3. Neither the name of the author "Sharlikran" nor the names of previous
--    maintainers may be used to endorse or promote products derived from this
--    software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES ARE DISCLAIMED. IN NO EVENT SHALL THE
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING IN ANY WAY OUT
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-- Maintainer Notice:
-- Redistribution of this software outside of ESOUI.com (including Bethesda.net
-- or other platforms) is discouraged unless authorized by the current
-- maintainer. While the original MIT license permits redistribution with proper
-- attribution and license inclusion, uncoordinated platform uploads may cause
-- version fragmentation or compatibility issues. Please respect the intent of
-- the maintainer and the integrity of the ESO addon ecosystem.
-------------------------------------------------------------------------------
]]

local lib = {}

lib.name = "LibMapPins-1.0"
lib.version = 10047
lib.filters = {}
lib.mapGroup = "pve"
lib.pinManager = ZO_WorldMap_GetPinManager()
LIBMAPPINS_PVE_MAPGROUP = "pve"
LIBMAPPINS_AVA_MAPGROUP = "pvp"
LIBMAPPINS_AVA_IMPERIAL_MAPGROUP = "imperialPvP"
LIBMAPPINS_BATTLEGROUND_MAPGROUP = "battleground"
local LIBMAPPINS_GLOBAL_MAPGROUP = "global"

LIBMAPPINS_PIN_ACTION_GROUP_QUEST = "quest"
LIBMAPPINS_PIN_ACTION_GROUP_FAST_TRAVEL = "fastTravel"
LIBMAPPINS_PIN_ACTION_GROUP_RESPAWN = "respawn"

local function GetPinTypeId(pinType)
  local pinTypeId
  if type(pinType) == "string" then
    pinTypeId = _G[pinType]
  elseif type(pinType) == "number" then
    pinTypeId = pinType
  end
  return pinTypeId
end

local function GetPinTypeIdAndString(pinType)
  local pinTypeString, pinTypeId
  if type(pinType) == "string" then
    pinTypeString = pinType
    pinTypeId = _G[pinType]
  elseif type(pinType) == "number" then
    pinTypeId = pinType
    local pinData = lib.pinManager.customPins[pinTypeId]
    pinTypeString = pinData and pinData.pinTypeString or nil
  end
  return pinTypeId, pinTypeString
end

local function GetCurrentMapFilterGroup()
  local mapGroup
  local mapFilterType = GetMapFilterType()

  if mapFilterType == MAP_FILTER_TYPE_STANDARD then
    mapGroup = "pve"
  elseif mapFilterType == MAP_FILTER_TYPE_AVA_CYRODIIL then
    mapGroup = "pvp"
  elseif mapFilterType == MAP_FILTER_TYPE_AVA_IMPERIAL then
    mapGroup = "imperialPvP"
  elseif mapFilterType == MAP_FILTER_TYPE_BATTLEGROUND then
    mapGroup = "battleground"
  elseif mapFilterType == MAP_FILTER_TYPE_GLOBAL then
    mapGroup = "global"
  end

  if mapGroup then
    return mapGroup, mapGroup .. "Key"
  end

  return nil, nil
end

local function GetCurrentGamepadMapFilterPanel()
  return GAMEPAD_WORLD_MAP_FILTERS and GAMEPAD_WORLD_MAP_FILTERS.currentPanel
end

-------------------------------------------------------------------------------
-- Library Functions ----------------------------------------------------------
-------------------------------------------------------------------------------
-- Arguments used by most of the functions:
--
-- pinType:       either pinTypeId or pinTypeString, you can use both
-- pinTypeString: unique string name of your choice (it will be used as a name
--                for global variable)
-- pinTypeId:     unique number code for your pin type, return value from lib:AddPinType
--                ( local pinTypeId = _G[pinTypeString] )
-- pinLayoutData: table which can contain the following keys:
--    level =     number > 2, pins with higher level are drawn on top of pins with lower level.
--                Examples: Points of interest 50, quests 110, group members 130, wayshrine 140,
--                player 160.
--    texture =   string or function(pin). A texture path or a function returning one or more textures
--                (e.g., base, glow, and overlay). Determines the visual appearance of the pin.
--    size =      number (optional). Sets the pin’s size in pixels (width and height). Defaults to 20.
--    tint  =     ZO_ColorDef object or function(pin). If defined, the background texture color is set
--                to this color.
--    grayscale = boolean or function(pin). If true or function returns true, the texture is shown in
--                grayscale.
--    onToggleCallback: (optional) function(compassPinType, enabled). Called when the corresponding map
--                filter checkbox is toggled. Commonly used to toggle compass pins via CustomCompassPins.
--    mapPinTypeString: (optional) string passed as the first argument to onToggleCallback. Required if
--                onToggleCallback is used, so the associated compass pin type can be enabled or disabled.
--    insetX =    (optional) number. Adds horizontal transparent padding around the pin for better
--                click targeting.
--    insetY =    (optional) number. Same as insetX but vertical.
--    minSize =   (optional) number. Prevents pins from shrinking below this size when zoomed out.
--    minAreaSize = (optional) number. Minimum size of area-based pins (e.g., discovery radius).
--    showsPinAndArea = (optional) boolean. If true, both the pin and its area (e.g., region circle) are
--                displayed.
--    isAnimated = (optional) boolean. Enables frame-based texture animation. Requires frame fields.
--    mouseLevel = (optional) number. Determines click priority. Higher values are clicked above lower ones.
--    framesWide = (optional) number. Number of horizontal frames in an animated texture.
--    framesHigh = (optional) number. Number of vertical frames in an animated texture.
--    framesPerSecond = (optional) number. Animation speed, in FPS. Requires isAnimated = true.
--    hitInsetX =  (optional) number. Expands or shrinks the clickable area horizontally beyond the pin.
--    hitInsetY =  (optional) number. Same as hitInsetX but vertical.
--
-------------------------------------------------------------------------------
-- lib:AddPinType(pinTypeString, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator)
-------------------------------------------------------------------------------
-- Adds custom pin type
-- returns: pinTypeId
--
-- pinTypeString: string
-- pinTypeAddCallback: function(pinManager), will be called every time when map
--                is changed. It should create pins on the current map using the
--                lib:CreatePin(...) function.
-- pinTypeOnResizeCallback: (nilable) function(pinManager, mapWidth, mapHeight),
--                is called when map is resized (zoomed).
-- pinLayoutData:  (nilable) table, details above
-- pinTooltipCreator: (nilable) etiher string to display or table with the
--                following keys:
--    creator =   function(pin). Called when the mouse hovers over the pin. This function defines the
--                behavior of the tooltip, such as what content is shown or whether to show one at all.
--                It is not required to create a tooltip. It may also be used for dynamic effects or
--                other context-aware reactions during hover.
--    tooltip =   (optional) number, selects the tooltip mode:
--                1 = INFORMATION, 2 = KEEP, 3 = MAP_LOCATION.
--    hasTooltip = (optional) function(pin) that returns true/false to enable/disable tooltip rendering.
--    categoryId = (optional) number. Grouping ID for built-in map pin sorting layers:
--                ZO_MapPin.PIN_ORDERS = {
--                   DESTINATIONS = 10,
--                   AVA_KEEP = 19,
--                   AVA_OUTPOST = 20,
--                   AVA_TOWN = 21,
--                   AVA_RESOURCE = 22,
--                   AVA_GATE = 23,
--                   AVA_KILL_LOCATION = 24,
--                   AVA_ARTIFACT = 25,
--                   AVA_IMPERIAL_CITY = 26,
--                   AVA_FORWARD_CAMP = 27,
--                   AVA_RESTRICTED_LINK = 28,
--                   CRAFTING = 30,
--                   SUGGESTIONS = 34,
--                   SKYSHARDS = 36,
--                   ANTIQUITIES = 38,
--                   QUESTS = 40,
--                   WORLD_EVENT_UNITS = 45,
--                   PLAYERS = 50,
--                }
--    filterTooltipCreator = (optional) function or string.
--                If a function, it is called when the mouse hovers over the pin’s
--                map filter checkbox and should return the tooltip text to display.
--                If a string, it is wrapped in a function automatically.
--                Only applies to the map filter UI in PC keyboard mode (not available in Gamepad UI).
--    entryName = (optional) string or function(pin). Name shown in tooltips, such as a Wayshrine label.
--    headerCreator = (optional) function(pin). Creates a header line in the tooltip layout.
--    gamepadCategory = (optional) string. Header title shown for grouped Gamepad pins.
--    gamepadCategoryIcon = (optional) string. Path to an icon displayed next to the Gamepad group name.
--    gamepadCategoryStyleName = (optional) string. Style used for Gamepad headers (e.g., bold text).
--                Example:
--                   local mapQuestTitle = {
--                      fontFace = "$(GAMEPAD_BOLD_FONT)",
--                      fontSize = "$(GP_34)",
--                   }
--                Referenced as "ZO_MapLocation_GamepadQuestTitleHeader".
--    gamepadSpacing = (optional) boolean. Adds spacing between Gamepad UI entries if true.
--
-------------------------------------------------------------------------------
function lib:AddPinType(pinTypeString, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator, filterTooltipCreator)
  assert(type(pinTypeString) == "string", "Parameter pinTypeString is not a string.")
  assert(not _G[pinTypeString], "Parameter pinTypeString: " .. pinTypeString .. " already exists.")
  assert(type(pinTypeAddCallback) == "function", "Parameter pinTypeAddCallback is not a function.")

  if pinLayoutData == nil then
    pinLayoutData = { level = 40, texture = "EsoUI/Art/Inventory/newitem_icon.dds" }
  end

  if type(pinTooltipCreator) == "string" then
    local text = pinTooltipCreator
    pinTooltipCreator = {
      creator = function(pin)
        if IsInGamepadPreferredMode() then
          local InformationTooltip = ZO_MapLocationTooltip_Gamepad
          local baseSection = InformationTooltip.tooltip
          InformationTooltip:LayoutIconStringLine(baseSection, nil, text, baseSection:GetStyle("mapLocationTooltipContentName"))
        else
          SetTooltipText(InformationTooltip, text)
        end
      end,
      tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    }
  elseif type(pinTooltipCreator) == "table" then
    if type(pinTooltipCreator.tooltip) ~= "number" then
      pinTooltipCreator.tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION
    end
  elseif pinTooltipCreator ~= nil then
    return
  end

  if type(pinLayoutData.color) == "table" then
    if pinLayoutData.tint == nil or pinLayoutData.tint.UnpackRGBA == nil then
      pinLayoutData.tint = ZO_ColorDef:New(unpack(pinLayoutData.color))
    end
  end

  self.pinManager:AddCustomPin(pinTypeString, pinTypeAddCallback, pinTypeOnResizeCallback, pinLayoutData, pinTooltipCreator)
  local pinTypeId = _G[pinTypeString]
  self.pinManager:SetCustomPinEnabled(pinTypeId, true)
  self.pinManager:RefreshCustomPins(pinTypeId)

  return pinTypeId
end

-------------------------------------------------------------------------------
-- lib:CreatePin(pinType, pinTag, locX, locY, areaRadius)
-------------------------------------------------------------------------------
-- create single pin on the current map, primary use is from pinTypeAddCallback
--
-- pinType:       pinTypeId or pinTypeString
-- pinTag:        can be anything, but I recommend using table or string with
--                additional pin details. You can use it later in code.
--                ( local pinTypeId, pinTag = pin:GetPinTypeAndTag() )
--                Argument pinTag is used as an id for functions
--                lib:RemoveCustomPin(...) and lib:FindCustomPin(...).
-- locX, locY:    normalized position on the current map
-- areaRadius:    (nilable)
-------------------------------------------------------------------------------
function lib:CreatePin(pinType, pinTag, locX, locY, areaRadius)
  if pinTag == nil or type(locX) ~= "number" or type(locY) ~= "number" then return end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    local pinData = self.pinManager.customPins[pinTypeId]
    if pinData then
      local isEnabled = self:IsEnabled(pinTypeId)
      if isEnabled then
        self.pinManager:CreatePin(pinTypeId, pinTag, locX, locY, areaRadius)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- lib:GetLayoutData(pinType)
-------------------------------------------------------------------------------
-- Gets reference to pinLayoutData table
-- returns: pinLayoutData
--
-- pinType:       pinTypeId or pinTypeString
-------------------------------------------------------------------------------
function lib:GetLayoutData(pinType)
  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    return ZO_MapPin.PIN_DATA[pinTypeId]
  end
end

-------------------------------------------------------------------------------
-- lib:GetLayoutKey(pinType, key)
-------------------------------------------------------------------------------
-- Gets a single key from pinLayoutData table
-- returns: pinLayoutData[key]
--
-- pinType:       pinTypeId or pinTypeString
-- key:           key name in pinLayoutData table
--
-- example: LibMapPins:GetLayoutData(244, "tint")
-------------------------------------------------------------------------------
function lib:GetLayoutKey(pinType, key)
  if type(key) ~= "string" then return end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId and ZO_MapPin.PIN_DATA[pinTypeId] then
    return ZO_MapPin.PIN_DATA[pinTypeId][key]
  end
end

-------------------------------------------------------------------------------
-- lib:SetLayoutData(pinType, pinLayoutData)
-------------------------------------------------------------------------------
-- Replace whole pinLayoutData table
--
-- pinType:       pinTypeId or pinTypeString
-- pinLayoutData: table
-------------------------------------------------------------------------------
function lib:SetLayoutData(pinType, pinLayoutData)
  if type(pinLayoutData) ~= "table" then return end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    pinLayoutData.level = pinLayoutData.level or 30
    pinLayoutData.texture = pinLayoutData.texture or "EsoUI/Art/Inventory/newitem_icon.dds"

    ZO_MapPin.PIN_DATA[pinTypeId] = {}
    for k, v in pairs(pinLayoutData) do
      ZO_MapPin.PIN_DATA[pinTypeId][k] = v
    end
  end
end

-------------------------------------------------------------------------------
-- lib:SetLayoutKey(pinType, key, data)
-------------------------------------------------------------------------------
-- change a single key in the pinLayoutData table
--
-- pinType:       pinTypeId or pinTypeString
-- key:           key name in pinLayoutData table
-- data:          data to be stored in pinLayoutData[key]
--
-- example: LibMapPins:SetLayoutKey(244, "tint", { 0, 0.5, 0.9, 1 } )
-------------------------------------------------------------------------------
function lib:SetLayoutKey(pinType, key, data)
  if type(key) ~= "string" then return end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    ZO_MapPin.PIN_DATA[pinTypeId][key] = data
  end
end

-------------------------------------------------------------------------------
-- lib:SetClickHandlers(pinType, LMB_handler, RMB_handler)
-------------------------------------------------------------------------------
-- Adds click handlers for pins of given pinType, if handler is nil, any existing
-- handler will be removed.
--
-- pinType:       pinTypeId or pinTypeString
--
-- LMB_handler:   hadler for left mouse button
-- RMB_handler:   handler for right mouse button
--
-- handler = {
--    {
--       name        = string or function(pin) end --required
--       show        = function(pin) end, (optional) default is true. Callback function
--                is called only when show returns true.
--       callback    = function(pin) end           --required
--       duplicates  = function(pin1, pin2) end, (optional) default is true.
--                What happens when mouse click hits more than one pin. If true,
--                pins are considered to be duplicates and just one callback
--                function is called.
--       gamepadName = string or function(pin) end --required
--    },
-- }
-- One handler can have defined more actions, with different conditions in show
-- function. First action with true result from show function will be used.
-- handler = {
--    {name = "name1", callback = callback1, show = show1},
--    {name = "name2", callback = callback2, show = show2},
--     ...
-- }
-------------------------------------------------------------------------------
function lib:SetClickHandlers(pinType, LMB_handler, RMB_handler)
  local pinTypeId = GetPinTypeId(pinType)
  if LMB_handler and not LMB_handler.gamepadName then
    LMB_handler.gamepadName = LMB_handler.name
  end
  if RMB_handler and not RMB_handler.gamepadName then
    RMB_handler.gamepadName = RMB_handler.name
  end
  if pinTypeId then
    if type(LMB_handler) == "table" or LMB_handler == nil then
      ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT][pinTypeId] = LMB_handler
    end
    if type(RMB_handler) == "table" or RMB_handler == nil then
      ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_RIGHT][pinTypeId] = RMB_handler
    end
  end
end

-------------------------------------------------------------------------------
-- lib:RefreshPins(pinType)
-------------------------------------------------------------------------------
-- Refreshes pins. If pinType is nil, refreshes all custom pins
--
-- pinType:       pinTypeId or pinTypeString
-------------------------------------------------------------------------------
function lib:RefreshPins(pinType)
  local pinTypeId = GetPinTypeId(pinType)
  self.pinManager:RefreshCustomPins(pinTypeId)
end

-------------------------------------------------------------------------------
-- lib:RemoveCustomPin(pinType, pinTag)
-------------------------------------------------------------------------------
-- Removes custom pin. If pinTag is nil, all pins of the given pinType are removed.
--
-- pinType:       pinTypeId or pinTypeString
-- pinTag:        id assigned to the pin by function lib:CreatePin(...)
-------------------------------------------------------------------------------
function lib:RemoveCustomPin(pinType, pinTag)
  local pinTypeId, pinTypeString = GetPinTypeIdAndString(pinType)
  if pinTypeId and pinTypeString then
    self.pinManager:RemovePins(pinTypeString, pinTypeId, pinTag)
  end
end

-------------------------------------------------------------------------------
-- lib:FindCustomPin(pinType, pinTag)
-------------------------------------------------------------------------------
-- Returns pin.
--
-- pinType:       pinTypeId or pinTypeString
-- pinTag:        id assigned to the pin by function lib:CreatePin(...)
-------------------------------------------------------------------------------
function lib:FindCustomPin(pinType, pinTag)
  if pinTag == nil then return end

  local pinTypeId, pinTypeString = GetPinTypeIdAndString(pinType)
  if pinTypeId and pinTypeString then
    return self.pinManager:FindPin(pinTypeString, pinTypeId, pinTag)
  end
end

-------------------------------------------------------------------------------
-- lib:SetAddCallback(pinType, pinTypeAddCallback)
-------------------------------------------------------------------------------
-- Set add callback
--
-- pinType:       pinTypeId or pinTypeString
-- pinTypeAddCallback: function(pinManager)
-------------------------------------------------------------------------------
function lib:SetAddCallback(pinType, pinTypeAddCallback)
  if type(pinTypeAddCallback) ~= "function" then return end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    self.pinManager.customPins[pinTypeId].layoutCallback = pinTypeAddCallback
  end
end

-------------------------------------------------------------------------------
-- lib:SetResizeCallback(pinType, pinTypeOnResizeCallback)
-------------------------------------------------------------------------------
-- Set OnResize callback
--
-- pinType:       pinTypeId or pinTypeString
-- pinTypeOnResizeCallback: function(pinManager, mapWidth, mapHeight)
-------------------------------------------------------------------------------
function lib:SetResizeCallback(pinType, pinTypeOnResizeCallback)
  if type(pinTypeOnResizeCallback) ~= "function" then return end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    self.pinManager.customPins[pinTypeId].resizeCallback = pinTypeOnResizeCallback
  end
end

-------------------------------------------------------------------------------
-- lib:IsEnabled(pinType)
-------------------------------------------------------------------------------
-- Checks if pins are enabled
-- returns: true/false
--
-- pinType:       pinTypeId or pinTypeString
-------------------------------------------------------------------------------
function lib:IsEnabled(pinType)
  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId then
    return self.pinManager:IsCustomPinEnabled(pinTypeId)
  end
end

-------------------------------------------------------------------------------
-- lib:SetEnabled(pinType, state)
-------------------------------------------------------------------------------
-- Set enabled/disabled state of the given pinType. It will also update state
-- of world map filter checkbox.
--
-- pinType:       pinTypeId or pinTypeString
-- state:         true/false, as false is considered nil, false or 0. All other
--                values are true.
-------------------------------------------------------------------------------
function lib:SetEnabled(pinType, state)
  local mapGroup, filterKey = GetCurrentMapFilterGroup()
  if mapGroup == LIBMAPPINS_GLOBAL_MAPGROUP then
    return
  end

  local pinTypeId = GetPinTypeId(pinType)
  if pinTypeId == nil then return end

  local enabled
  if type(state) == "number" then
    enabled = state ~= 0
  else
    enabled = state and true or false
  end

  local filter = self.filters[pinTypeId]
  if filter then

    local targetCheckbox = filter[mapGroup]
    if targetCheckbox then
      ZO_CheckButton_SetCheckState(targetCheckbox, enabled)
    end

    local currentPanel = GetCurrentGamepadMapFilterPanel()
    if not currentPanel or not currentPanel.list then return end
    currentPanel:SetPinFilter(pinTypeId, enabled)
  end

  local needsRefresh = self.pinManager:IsCustomPinEnabled(pinTypeId) ~= enabled
  self.pinManager:SetCustomPinEnabled(pinTypeId, enabled)

  if needsRefresh then
    self:RefreshPins(pinType)
  end
end

-------------------------------------------------------------------------------
-- lib:Enable(pinType)
-------------------------------------------------------------------------------
-- Enables pins of the given pinType
--
-- pinType:       pinTypeId or pinTypeString
-------------------------------------------------------------------------------
function lib:Enable(pinType)
  self:SetEnabled(pinType, true)
end

-------------------------------------------------------------------------------
-- lib:Disable(pinType)
-------------------------------------------------------------------------------
-- Disables pins of the given pinType
--
-- pinType:       pinTypeId or pinTypeString
-------------------------------------------------------------------------------
function lib:Disable(pinType)
  self:SetEnabled(pinType, false)
end

-------------------------------------------------------------------------------
-- lib:AddPinFilter(pinType, pinCheckboxText, separate, savedVars, savedVarsPveKey, savedVarsPvpKey, savedVarsImperialPvpKey)
-------------------------------------------------------------------------------
-- Adds filter checkboxes to the world map.
-- Returns: pveCheckbox, pvpCheckbox
-- (newly created checkbox controls for PvE and PvP depending on the map type of the world map)
--
-- pinType:       pinTypeId or pinTypeString
-- pinCheckboxText: (nilable), description displayed next to the checkbox, if nil
--                pinCheckboxText = pinTypeString
-- separate:      (nilable), if false or nil, checkboxes for PvE and PvP map type
--                will be linked together. If savedVars argument is nil, separate
--                is ignored and checkboxes will be linked together.
-- savedVars:     (nilable), table where you store filter settings
-- savedVarsPveKey: (nilable), key in the savedVars table where you store filter
--                state for PvE map. If savedVars table exists but this key
--                is nil, state will be stored in savedVars[pinTypeString].
-- savedVarsPvpKey: (nilable), key in the savedVars table where you store filter
--                state for PvP map, used only if separate is true. If separate
--                is true, savedVars exists but this argument is nil, state will
--                be stored in savedVars[pinTypeString .. "_pvp"].
-- savedVarsImperialPvpKey: (nilable), key in the savedVars table where you store
--                filter state for Imperial City PvP map, used only if separate
--                is true. If separate is true, savedVars exists but this argument
--                is nil, state will be stored in savedVars[pinTypeString .. "_imperialPvP"].
-- savedVarsBattlegroundKey: (nilable), key in the savedVars table where you store
--                filter state for Battleground PvP map, used only if separate
--                is true. If separate is true, savedVars exists but this argument
--                is nil, state will be stored in savedVars[pinTypeString .. "_battleground"].
-------------------------------------------------------------------------------
function lib:AddPinFilter(pinType, pinCheckboxText, separate, savedVars, savedVarsPveKey, savedVarsPvpKey, savedVarsImperialPvpKey, savedVarsBattlegroundKey)
  local pinTypeId, pinTypeString = GetPinTypeIdAndString(pinType)
  if pinTypeId == nil or self.filters[pinTypeId] then return end

  self.filters[pinTypeId] = {}
  local filter = self.filters[pinTypeId]

  if type(savedVars) == "table" then
    filter.vars = savedVars
    filter.pveKey = savedVarsPveKey or pinTypeString
    if separate then
      filter.pvpKey = savedVarsPvpKey or pinTypeString .. "_pvp"
      filter.imperialPvPKey = savedVarsImperialPvpKey or pinTypeString .. "_imperialPvP"
      filter.battlegroundKey = savedVarsBattlegroundKey or pinTypeString .. "_battleground"
    else
      filter.pvpKey = filter.pveKey
      filter.imperialPvPKey = filter.pveKey
      filter.battlegroundKey = filter.pveKey
    end
  end

  if type(pinCheckboxText) ~= "string" then
    pinCheckboxText = pinTypeString
  end

  local customPinState = self:IsEnabled(pinTypeId)
  local pveFilterState, pvpFilterState, imperialPvPFilterState, battlegroundFilterState = customPinState, customPinState, customPinState, customPinState
  if filter.vars ~= nil then
    pveFilterState = filter.vars[filter.pveKey]
    pvpFilterState = filter.vars[filter.pvpKey]
    imperialPvPFilterState = filter.vars[filter.imperialPvPKey]
    battlegroundFilterState = filter.vars[filter.battlegroundKey]
  end

  local mapFilterType = GetMapFilterType()
  if mapFilterType == MAP_FILTER_TYPE_STANDARD then
    self:SetEnabled(pinTypeId, pveFilterState)
  elseif mapFilterType == MAP_FILTER_TYPE_AVA_CYRODIIL then
    self:SetEnabled(pinTypeId, pvpFilterState)
  elseif mapFilterType == MAP_FILTER_TYPE_AVA_IMPERIAL then
    self:SetEnabled(pinTypeId, imperialPvPFilterState)
  elseif mapFilterType == MAP_FILTER_TYPE_BATTLEGROUND then
    self:SetEnabled(pinTypeId, battlegroundFilterState)
  elseif mapFilterType == MAP_FILTER_TYPE_GLOBAL then
    return -- SILENT EXIT
  end

  -- Gamepad support
  local function GamepadToggleFunction(data)
    local currentPanel = GetCurrentGamepadMapFilterPanel()
    if not currentPanel or not currentPanel.list then return end

    local pinData = self.pinManager.customPins[data.mapPinGroup]

    data.currentValue = not data.currentValue
    local keyField = lib.panelToKeyFields_Gamepad[currentPanel] .. "Key"
    if keyField then
      local toggleFilter = lib.filters and lib.filters[data.mapPinGroup]
      if toggleFilter and toggleFilter.vars and toggleFilter[keyField] then
        toggleFilter.vars[toggleFilter[keyField]] = data.currentValue

        if pinData and type(pinData.compassPinTypeString) == "string" then
          toggleFilter.vars[pinData.compassPinTypeString] = data.currentValue
        end
      end
    end

    currentPanel:SetPinFilter(data.mapPinGroup, data.currentValue)
    currentPanel:BuildControls()
    SCREEN_NARRATION_MANAGER:QueueParametricListEntry(currentPanel.list)

    if pinData and type(pinData.onToggleCallback) == "function" then
      pinData.onToggleCallback(pinData.compassPinTypeString, data.currentValue)
    end
  end

  local info = {
    name = pinCheckboxText,
    onSelect = GamepadToggleFunction,
    mapPinGroup = pinTypeId,
    showSelectButton = true,
    narrationText = function(entryData, entryControl)
      return ZO_FormatToggleNarrationText(entryData.text, entryData.currentValue)
    end,
  }

  for panel, key in pairs(lib.panelToKeyFields_Gamepad) do
    panel.gamepadMapFiltersInfo = panel.gamepadMapFiltersInfo or {}
    table.insert(panel.gamepadMapFiltersInfo, info)
  end
end

-------------------------------------------------------------------------------
-- lib:SetPinFilterHidden(pinType, mapGroup, hidden)
-------------------------------------------------------------------------------
-- Shows or hides the map filter checkbox for the given mapGroup
--
-- pinType:     pinTypeId or pinTypeString
-- mapGroup:    which instance of the filter: "pve", "pvp", "imperialPvP" or "battleground"
-- hidden:      true for hiding the filter, false for showing it
-------------------------------------------------------------------------------
function lib:SetPinFilterHidden(pinType, mapGroup, hidden)
  if mapGroup == LIBMAPPINS_GLOBAL_MAPGROUP then
    return
  end

  local pinTypeId, pinTypeString = GetPinTypeIdAndString(pinType)
  if pinTypeId and self.filters[pinTypeId] then
    local control = self.filters[pinTypeId][mapGroup]
    if control and control:IsControlHidden() ~= hidden then
      control:SetHidden(hidden)
      local _, point, relativeTo, relativePoint, offsetX, offsetY, restrain = control:GetAnchor(0)
      if hidden then
        control.oldOffsetY = offsetY
        offsetY = control:GetHeight() * -1
      else
        offsetY = control.oldOffsetY
      end
      control:ClearAnchors()
      control:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY, restrain)
    end
  end
end

-------------------------------------------------------------------------------
-- lib:GetZoneAndSubzone(alternative, bStripUIMap, bKeepMapNum)
-------------------------------------------------------------------------------
-- Returns zone and subzone derived from map texture.

-- You can select from 2 formats:
-- 1: "zone", "subzone"                     (that's what I use in my addons)
-- 2: "zone/subzone"                        (used by HarvestMap)
-- If 2nd argument is nil or false, function returns first format

-- Additionally if the third argument bKeepMapNBum is true you will preserve
-- the ending of the map texture.
-- 3: "zone/subzone_0" or "zone", "subzone_0" (used by Destinations)
-------------------------------------------------------------------------------
--[[ changed to cover these situations
    Reference https://wiki.esoui.com/Texture_List/ESO/art/maps

   "/art/maps/southernelsweyr/els_dragonguard_island05_base_8.dds",
   "/art/maps/murkmire/tsofeercavern01_1.dds",
   "/art/maps/housing/blackreachcrypts.base_0.dds",
   "/art/maps/housing/blackreachcrypts.base_1.dds",
   "Art/maps/skyrim/blackreach_base_0.dds",
   "Textures/maps/summerset/alinor_base.dds",
   "art/maps/murkmire/ui_map_tsofeercavern01_0.dds",
   "art/maps/elsweyr/jodesembrace1.base_0.dds",
]]--

local function mysplit(inputstr)
  local t = {}
  for str in string.gmatch(inputstr, "([^%/]+)") do
    table.insert(t, str)
  end
  return t
end

function lib:GetZoneAndSubzone(alternative, bStripUIMap, bKeepMapNum)
  local mapTexture = GetMapTileTexture():lower()
  mapTexture = mapTexture:gsub("^.*/maps/", "")
  if bStripUIMap == true then
    mapTexture = mapTexture:gsub("ui_map_", "")
  end
  mapTexture = mapTexture:gsub("%.dds$", "")
  if not bKeepMapNum then
    mapTexture = mapTexture:gsub("%d*$", "")
    mapTexture = mapTexture:gsub("_+$", "")
  end

  if alternative then
    return mapTexture
  end

  return unpack(mysplit(mapTexture))
end


-------------------------------------------------------------------------------
-- Callbacks ------------------------------------------------------------------
-------------------------------------------------------------------------------
--refresh checkbox state for world map filters
function lib.OnMapChanged()
  local mapGroup, filterKey = GetCurrentMapFilterGroup()
  if lib.mapGroup ~= mapGroup then
    lib.mapGroup = mapGroup
    if mapGroup == LIBMAPPINS_GLOBAL_MAPGROUP then
      return
    end
    for pinTypeId, filter in pairs(lib.filters) do
      if filter.vars then
        local state = filter.vars[filter[filterKey]]
        lib:SetEnabled(pinTypeId, state)
      else
        ZO_CheckButton_SetCheckState(filter[mapGroup], lib:IsEnabled(pinTypeId))
      end
    end
  end
end
CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", lib.OnMapChanged)

-------------------------------------------------------------------------------
-- Hooks ----------------------------------------------------------------------
-------------------------------------------------------------------------------
-- support "grayscale" in pinLayoutData
-------------------------------------------------------------------------------
ZO_PostHook(ZO_MapPin, "SetData", function(self, pinType)
  local singlePinData = ZO_MapPin.PIN_DATA[pinType]
  if singlePinData then
    local grayscale = singlePinData.grayscale
    if grayscale ~= nil then
      self.backgroundControl:SetDesaturation((type(grayscale) == "function" and grayscale(self) or grayscale == true) and 1 or 0)
    end
  end
end)

ZO_PostHook(ZO_MapPin, "ClearData", function(self, ...)
  local control = self.backgroundControl
  if control then
    self.backgroundControl:SetDesaturation(0)
  end
end)

-------------------------------------------------------------------------------
-- Scrollbox for map filters
-------------------------------------------------------------------------------
local function OnLoad(code, addon)
  if addon:find("^ZO") then return end
  EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)

  CALLBACK_MANAGER:FireCallbacks("WorldMapFiltersReady")
  CALLBACK_MANAGER:FireCallbacks("PostHooksForWorldMapFilters")
end
EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_ADD_ON_LOADED, OnLoad)

-------------------------------------------------------------------------------
-- lib:MyPosition()
-------------------------------------------------------------------------------
-- Returns the player position on current map.
-- Not really intended for use as a library function.
-- For example it does not return the different formats from GetZoneAndSubzone
-------------------------------------------------------------------------------
function lib:MyPosition()
  if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
    CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
  end

  local mapName = zo_strformat(SI_WINDOW_TITLE_WORLD_MAP, GetMapName())
  local x, y = GetMapPlayerPosition("player")
  local zone, subzone = self:GetZoneAndSubzone()

  return x, y, zone, subzone, mapName
end

-------------------------------------------------------------------------------
-- Displays the player position on current map.
-- The output format is prepared for data collection.
-------------------------------------------------------------------------------
local function show_position()
  local x, y, zone, subzone, mapName = lib:MyPosition()
  d(string.format("[\"%s\"][\"%s\"] = { %0.5f, %0.5f } -- %s", zone, subzone, x, y, mapName))
end

SLASH_COMMANDS["/lmploc"] = function() show_position() end

SLASH_COMMANDS["/lmppins"] = function()
  local customPins = lib.pinManager.customPins
  for pinId, pinLayout in pairs(customPins) do
    df("pinId: %d - pinName: %s", pinId, pinLayout.pinTypeString)
  end
end

SLASH_COMMANDS["/pinlist"] = function()
  local customPins = lib.pinManager.customPins
  for pinId, pinLayout in pairs(customPins) do
    df("pinId: %d - pinName: %s", pinId, pinLayout.pinTypeString)
  end
end

CALLBACK_MANAGER:RegisterCallback("WorldMapFiltersReady", function()
  lib.panelToKeyFields_Gamepad = {
    [GAMEPAD_WORLD_MAP_FILTERS.pvePanel] = "pve",
    [GAMEPAD_WORLD_MAP_FILTERS.pvpPanel] = "pvp",
    [GAMEPAD_WORLD_MAP_FILTERS.imperialPvPPanel] = "imperialPvP",
    [GAMEPAD_WORLD_MAP_FILTERS.battlegroundPanel] = "battleground",
  }

  lib.gamepadPanelsByKey = {}
  for panel, key in pairs(lib.panelToKeyFields_Gamepad) do
    lib.gamepadPanelsByKey[key] = panel

    -- Inject list if needed
    if panel and panel.control then
      panel.gamepadMapFiltersInfo = panel.gamepadMapFiltersInfo or {}
      if not panel.list then
        local listControl = panel.control:GetNamedChild("List")
        if listControl then
          panel.list = ZO_GamepadVerticalParametricScrollList:New(listControl)
          panel.list:SetAlignToScreenCenter(true)
          panel.list:SetOnSelectedDataChangedCallback(function()
            if GAMEPAD_WORLD_MAP_FILTERS.SelectKeybind then
              GAMEPAD_WORLD_MAP_FILTERS:SelectKeybind()
            end
          end)
          panel.list:AddDataTemplate("ZO_GamepadWorldMapFilterCheckboxOptionTemplate", ZO_GamepadCheckboxOptionTemplate_Setup, ZO_GamepadMenuEntryTemplateParametricListFunction)
          panel.list:AddDataTemplateWithHeader("ZO_GamepadWorldMapFilterComboBoxTemplate", function(...) panel:SetupDropDown(...) end, ZO_GamepadMenuEntryTemplateParametricListFunction, nil, "ZO_GamepadMenuEntryHeaderTemplate")
        end
      end
    end
  end
end)

CALLBACK_MANAGER:RegisterCallback("PostHooksForWorldMapFilters", function()
  for panel, key in pairs(lib.panelToKeyFields_Gamepad) do
    local keyField = key .. "Key"
    ZO_PreHook(panel, "PostBuildControls", function()
      local entries = panel.gamepadMapFiltersInfo
      if entries then
        for _, info in ipairs(entries) do
          local pinTypeId = info.mapPinGroup
          local filter = lib.filters and lib.filters[pinTypeId]

          if filter then
            local savedKey = filter[keyField]
            local isChecked
            if filter.vars and savedKey and filter.vars[savedKey] ~= nil then
              isChecked = filter.vars[savedKey]
            else
              isChecked = lib:IsEnabled(pinTypeId)
            end

            local checkBox = ZO_GamepadEntryData:New(info.name)
            checkBox:SetDataSource(info)
            checkBox.currentValue = isChecked

            -- Ensure the enabled state matches what we're about to show
            lib:SetEnabled(pinTypeId, isChecked)

            table.insert(panel.pinFilterCheckBoxes, checkBox)
            panel.list:AddEntry("ZO_GamepadWorldMapFilterCheckboxOptionTemplate", checkBox)
          end
        end
      end
    end)
  end
end)

------------------------------
---       Debugging        ---
------------------------------

lib.show_log = true
lib.loggerName = 'LibMapPins'

if LibDebugLogger then
  lib.logger = LibDebugLogger.Create(lib.loggerName)
end

local logger = lib.logger ~= nil
local viewer = DebugLogViewer ~= nil

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if logger and log_type == "Info" then
    lib.logger:Info(log_content)
  end
  if not lib.show_log then return end
  if logger and log_type == "Debug" then
    lib.logger:Debug(log_content)
  end
  if logger and log_type == "Verbose" then
    lib.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    lib.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if text == "" then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  if not t then
    emit_message(log_type, indent .. "[Nil Table]")
    return
  end

  if next(t) == nil then
    emit_message(log_type, indent .. "[Empty Table]")
    return
  end

  for k, v in pairs(t) do
    local vType = type(v)
    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))
    if vType == "table" then
      if table_history[v] then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

local function emit_userdata(log_type, udata)
  local function_limit = 5
  local total_limit = 10
  local function_count = 0
  local entry_count = 0

  emit_message(log_type, "Userdata: " .. tostring(udata))

  local meta = getmetatable(udata)
  if meta and meta.__index then
    for k, v in pairs(meta.__index) do
      if type(v) == "function" then
        if function_count < function_limit then
          emit_message(log_type, "  Function: " .. tostring(k))
          function_count = function_count + 1
          entry_count = entry_count + 1
        end
      else
        emit_message(log_type, "  " .. tostring(k) .. ": " .. tostring(v))
        entry_count = entry_count + 1
      end

      if entry_count >= total_limit then
        emit_message(log_type, "  ... (output truncated due to limit)")
        break
      end
    end
  else
    emit_message(log_type, "  (No detailed metadata available)")
  end
end

local function contains_placeholders(str)
  return type(str) == "string" and str:find("<<%d+>>")
end

function lib:dm(log_type, ...)
  if not lib.show_log and log_type ~= "Info" then return end

  local num_args = select("#", ...)
  local first_arg = select(1, ...)

  if type(first_arg) == "string" and contains_placeholders(first_arg) then
    local remaining_args = { select(2, ...) }
    local formatted_value = ZO_CachedStrFormat(first_arg, unpack(remaining_args))
    emit_message(log_type, formatted_value)
  else
    for i = 1, num_args do
      local value = select(i, ...)
      if type(value) == "userdata" then
        emit_userdata(log_type, value)
      elseif type(value) == "table" then
        emit_table(log_type, value)
      else
        emit_message(log_type, tostring(value))
      end
    end
  end
end

LibMapPins = lib
