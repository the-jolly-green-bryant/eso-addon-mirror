local LMP = LibMapPins
local GPS = LibGPS3

local DEG_ADDON = _G["DEG_CURRENT_ADDON"]
local function d(msg)
  _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:d(msg)
end

local function ts(...)
  return tostring(...)
end

local Addon = {}
Addon.initialized = false
Addon.debug = false--release:false
Addon.name = DEG_ADDON.ADDON_NAME
Addon.versionString = '1.15'
Addon.saveVariablesName = DEG_ADDON.SAVED_VARS_NAME
Addon.savedVariablesAccount = nil
Addon.savedVariablesCharacter = nil
Addon.saveVariablesVersion = 1
Addon.vars = {control = nil}
Addon.Settings = _G[DEG_ADDON.ADDON_NAME.."Settings"]

function Addon:InitCharWantsBooksDefaults()
  if not self.savedVariablesAccount then return end
  if type(self.savedVariablesAccount.charWantsBooks) ~= "table" then
    self.savedVariablesAccount.charWantsBooks = {}
  end
  for i = 1, GetNumCharacters() do
    local _, _, _, _, _, _, charId = GetCharacterInfo(i)
    if self.savedVariablesAccount.charWantsBooks[charId] == nil then
      self.savedVariablesAccount.charWantsBooks[charId] = true -- default ON
    end
  end
end

function Addon:Initialize()
  if (self.initialized) then return end

  local defaultsAccount = {}
  self.savedVariablesAccount = ZO_SavedVars:NewAccountWide(self.saveVariablesName, self.saveVariablesVersion, nil, defaultsAccount)

  local defaultsCharacter = {}
  self.savedVariablesCharacter = ZO_SavedVars:New(self.saveVariablesName, self.saveVariablesVersion, nil, defaultsCharacter)

  self:InitCharWantsBooksDefaults()
  self.Settings:initialize()

  self.worldControlPool = ZO_ControlPool:New("DEGLorePin", DEGLorePins, "DEGLorePin")

  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:onEVENT_PLAYER_ACTIVATED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEACTIVATED, function(...) self:onEVENT_PLAYER_DEACTIVATED(...) end)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ZONE_CHANGED, function(...) self:onEVENT_ZONE_CHANGED(...) end)

  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function(...) self:onWorldMapChange(...) end)

  self.initialized = true
end

function Addon:CharWantsBooks(charId)
  if not self.savedVariablesAccount then
    -- Called before Initialize has set up saved vars; default to TRUE (show pins)
    return true
  end
  if not charId then
    charId = GetCurrentCharacterId()
  end
  local map = self.savedVariablesAccount.charWantsBooks
  if type(map) == "table" and map[charId] ~= nil then
    return map[charId]
  end
  return true
end


function Addon:setCharWantsBooks(charId, newValue)
  if not self.savedVariablesAccount then return end
  if type(self.savedVariablesAccount.charWantsBooks) ~= "table" then
    self.savedVariablesAccount.charWantsBooks = {}
  end
  self.savedVariablesAccount.charWantsBooks[charId] = newValue and true or false

  if newValue then
    self:reinitPins()
  end
  self:checkRefreshHandler()
end


function Addon:checkRefreshHandler()
  if self:CharWantsBooks() then
    DEGLorePins:SetHidden(false)
    self:reinitPins()
    EVENT_MANAGER:RegisterForUpdate("DryzlerElderGeekLoreUpdate", 200, function(...) self:onUpdate(...)  end)
  else
    DEGLorePins:SetHidden(true)
    EVENT_MANAGER:UnregisterForUpdate("DryzlerElderGeekLoreUpdate")
  end
end

Addon.pins= { }

function Addon:onWorldMapChange()
  d("onWorldMapChange")

  self:reinitPins()
end

function Addon:playerActivated(eventCode, initial)
  if not self.savedVariablesAccount then return end
  d("playerActivated")
  if not Addon:CharWantsBooks(GetCurrentCharacterId()) then return end
  self:reinitPins()
end

function Addon:onWorldChange(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
  if not self.savedVariablesAccount then return end
  d("onWorldChange;"..zoneName..";"..subZoneName..";"..ts(newSubzone)..";" .. ts(zoneId))
  if not Addon:CharWantsBooks(GetCurrentCharacterId()) then return end
  self:reinitPins()
end

EVENT_MANAGER:RegisterForEvent(Addon.name .. "_WorldChange_Activated", EVENT_PLAYER_ACTIVATED, function(...) Addon:playerActivated(...) end)
EVENT_MANAGER:RegisterForEvent(Addon.name .. "_WorldChange_Zone",      EVENT_ZONE_CHANGED,     function(...) Addon:onWorldChange(...) end)

--CALLBACK_MANGER:FireCallbacks("OnWorldMapChanged")

--    { 0.5928, 0.8493, 19, 4 },    -- History of the Fighter's Guilds Pt.2
--    { 0.6196, 0.8249, 19, 4 },
--    { 0.5993, 0.7961, 19, 4 },
--    { 0.5679, 0.8275, 19, 4 },

Addon.currentZone = nil

function Addon:reinitPins()
  d("Addon:reinitPins")

  -- make sure parent 3D space exists
  if not DEGLorePins:Has3DRenderSpace() then
    DEGLorePins:Create3DRenderSpace()
  end
  DEGLorePins:Set3DRenderSpaceOrigin(0, 0, 0)

  local zoneName, subzoneName = LMP:GetZoneAndSubzone()
  if not zoneName or not subzoneName then return end

  local zoneKey = ts(zoneName) .. ";" .. ts(subzoneName)

  -- reset when zone actually changes
  if self.currentZone and self.currentZone ~= zoneKey then
    self.worldControlPool:ReleaseAllObjects()
    self.pins = {}
  end
  self.currentZone = zoneKey

  -- get all lorebook data for current map
  local lorebooks = LoreBooks_GetLocalData(GetCurrentMapId())
  if not lorebooks then return end

  ---------------------------------------------------------------------------
  -- Compute a one-time Global→World transform for this zone
  ---------------------------------------------------------------------------
  local zoneId, playerWorldXcm, playerWorldYcm, playerWorldZcm = GetUnitWorldPosition("player")

  local offsetCm = 10000 -- 100 m
  local ax, ay, az = playerWorldXcm, playerWorldYcm, playerWorldZcm
  local bx, by, bz = ax + offsetCm, ay, az + offsetCm

  -- world→local→global chain
  local alx, aly = GetNormalizedWorldPosition(zoneId, ax, ay, az)
  local blx, bly = GetNormalizedWorldPosition(zoneId, bx, by, bz)
  local agx, agy = GPS:LocalToGlobal(alx, aly)
  local bgx, bgy = GPS:LocalToGlobal(blx, bly)

  local metersPerGlobalUnit, originGlobalX, originGlobalY
  if agx and agy and bgx and bgy and bgx ~= agx and bgy ~= agy then
    local axm, azm = ax * 0.01, az * 0.01
    local bxm, bzm = bx * 0.01, bz * 0.01
    local scaleX = (bxm - axm) / (bgx - agx)
    local scaleZ = (bzm - azm) / (bgy - agy)
    metersPerGlobalUnit = (scaleX + scaleZ) / 2
    originGlobalX = agx - (axm / metersPerGlobalUnit)
    originGlobalY = agy - (azm / metersPerGlobalUnit)
  end

  local function GlobalToWorldCm(gx, gy)
    if not metersPerGlobalUnit or not originGlobalX then return nil, nil end
    local wxm = (gx - originGlobalX) * metersPerGlobalUnit
    local wzm = (gy - originGlobalY) * metersPerGlobalUnit
    return wxm * 100, wzm * 100
  end

  ---------------------------------------------------------------------------
  -- Create visible 3D pins
  ---------------------------------------------------------------------------
  self.worldControlPool:ReleaseAllObjects()

  for pinIndex, pinData in ipairs(lorebooks) do
    local _, _, known = GetLoreBookInfo(1, pinData[3], pinData[4])
    if not known then
      local pinKeyStr = ts(zoneName) .. ";" .. ts(subzoneName) .. ";" .. pinIndex
      local pinId = self.pins[pinKeyStr]
      local pin = pinId and self.worldControlPool:GetActiveObject(pinId)
      if not pin then
        pin, pinId = self.worldControlPool:AcquireObject()
      end
      self.pins[pinKeyStr] = pinId

      pin:SetHidden(true)
      pin.myPinKey = pinKeyStr
      pin.pinData = pinData

      local pinLocalX, pinLocalY = pinData[1], pinData[2]
      local pinGlobalX, pinGlobalY = GPS:LocalToGlobal(pinLocalX, pinLocalY)
      local pinWorldXcm, pinWorldZcm = GlobalToWorldCm(pinGlobalX, pinGlobalY)
      if pinWorldXcm and pinWorldZcm then
        pin.x, pin.y = pinWorldXcm, pinWorldZcm
      else
        pin.x, pin.y = 0, 0 -- fallback to avoid nils
      end

      -- make sure each pin has its 3D space
      local icon = pin:GetNamedChild("Icon")
      pin.icon = icon
      if not pin:Has3DRenderSpace() then
        pin:Create3DRenderSpace()
        icon:Create3DRenderSpace()
        icon:SetTexture("Lorebooks/Icons/book1.dds")
      end

      local height = 2
      icon:Set3DRenderSpaceOrigin(0, height, 0)
      icon:Set3DLocalDimensions(0.25 * height + 0.5, 0.25 * height + 0.5)

      local _, _, playerYcm = GetUnitWorldPosition("player")
      local rx, ry, rz = WorldPositionToGuiRender3DPosition(pin.x, playerYcm, pin.y)
      pin:Set3DRenderSpaceOrigin(rx, ry, rz)
      pin:SetHidden(false)
    end
  end
end

function Addon:onUpdate()
--  if true then return end
  if self.deactivated then return end

  if not Addon:CharWantsBooks(GetCurrentCharacterId()) then return end

--  d("onUpdate")

  local zoneTemp,x,z,y = GetUnitWorldPosition("player") --centimeters

  --d("GetUnitWorldPosition;zoneTemp="..ts(zoneTemp)..";x="..ts(x)..";z="..ts(z).."y="..ts(y))
  --draußen
  --GetUnitWorldPosition;zoneTemp=381;x=231176;z=12025y=379500
  --drinnen
  --GetUnitWorldPosition;zoneTemp=381;x=231523;z=12040y=380202

  local heading = GetPlayerCameraHeading()
  if heading > math.pi then --normalize heading to [-pi,pi]
    heading = heading - 2 * math.pi
  end

  --spieler
  local Ax = x
  local Ay = y

  for i, control in pairs(self.worldControlPool.m_Active) do
    control:Set3DRenderSpaceOrientation(0, heading, 0)

    if true then
      local Bx = control.x
      local By = control.y

      local Cx = Ax
      local Cy = By

      --d("By="..ts(By)..";Ay="..ts(Ay))

      local Dy = By - Ay
      local Dx = Bx - Ax

      local dist = math.sqrt((Dx * Dx) + (Dy * Dy)) / 100  --meter

      if (dist <= 50) then --50 meter
        local _, _, known = GetLoreBookInfo(1, control.pinData[3], control.pinData[4])

        if (known) then
          control:SetHidden(true)
        else
          --d("activating:pin.myPinKey="..ts(control.myPinKey))
          control:SetHidden(false)

          local worldX, worldY, worldZ = WorldPositionToGuiRender3DPosition(control.x, z, control.y)
          control:Set3DRenderSpaceOrigin(worldX, worldY, worldZ)

          --if (dist <= 4) then
            --control.icon:SetColor(0.0*255/255,0.5*255/255,0.0*255/255,1*255/255)
            --control.hasColor = true
          --else
            --if (control.hasColor) then
              --control.icon:SetColor(1,1,1)
              --control.hasColor = false
            --end
          --end
        end
      else
        control:SetHidden(true)
      end
    end
  end
end

function Addon:onEVENT_ZONE_CHANGED (eventCode, zoneName, subZoneName, bNewSubzone, zoneId, subZoneId)
  d("onEVENT_ZONE_CHANGED")

  self:reinitPins()
end

function Addon:onEVENT_PLAYER_DEACTIVATED(intEventCode)
  d("onEVENT_PLAYER_DEACTIVATED: "..GetUnitName("player"))

  self.deactivated = true
  EVENT_MANAGER:UnregisterForUpdate("DryzlerElderGeekLoreUpdate")
end

function Addon:onEVENT_PLAYER_ACTIVATED(intEventCode, bInitial)
  d("onEVENT_PLAYER_ACTIVATED: "..GetUnitName("player")..";bInitial="..ts(bInitial))

  self.deactivated = false
  --self:reinitPins()

  self:checkRefreshHandler();



--  EVENT_MANAGER:RegisterForUpdate("DryzlerElderGeekLoreUpdateDebug", 5000, function(...)
--    self:reinitPins()
--  end)

end

--#################################################################################################

function Addon:d(m)
  if self.debug then
    _G.d(self.name.."> "..tostring(m))
  end
end

_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT] = Addon;

EVENT_MANAGER:RegisterForEvent(DEG_ADDON.ADDON_NAME, EVENT_ADD_ON_LOADED,
  function(event, AddonName)
    if AddonName == _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name then
      _G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT]:Initialize()
      EVENT_MANAGER:UnregisterForEvent(_G[DEG_ADDON.PACKAGE_NAME].plugins[DEG_ADDON.ADDON_NAME_SHORT].name, EVENT_ADD_ON_LOADED)
    end
  end
)