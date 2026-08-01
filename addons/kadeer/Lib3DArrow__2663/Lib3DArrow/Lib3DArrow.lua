Lib3DArrow = {}
local lib = Lib3DArrow      -- use this e.g. Lib3DArrow:Create()
lib.name = "Lib3DArrow"

-------------------------------------------------------------------------------------------
L3DA = L3DA or {}
local allArrows = {}
Lib3DArrow.allArrows = allArrows

-- This is all common player info required by most things
local lastPData = {}

local function GetPlayerData()
  local pData = {}
  local isChanged = false

  -- player world position
  _, pData.worldX, pData.worldY, pData.worldZ = GetUnitWorldPosition("player")
  pData.worldX, pData.worldY, pData.worldZ = WorldPositionToGuiRender3DPosition(pData.worldX, pData.worldY, pData.worldZ)
  if not pData.worldX then return false end

  -- player map position
  pData.playerX, pData.playerY = LibGPS2:LocalToGlobal(GetMapPlayerPosition("player"))

  -- sometimes there are no measurements in localtoglobal so it returns nil values
  if pData.playerX == nil then
    -- pdata = false (this will tell update() to skip iteration), ischanged = doesnt matter
    -- *** could possibly use lastPData ***
    return false, false
  end

  -- player camera view
  _, _, _, pData.forwardX, pData.forwardY, pData.forwardZ, pData.rightX, pData.rightY, pData.rightZ, pData.upX, pData.upY, pData.upZ = Lib3D:GetCameraRenderSpace()


  if lastPData ~= {} then
    if pData.worldX ~= lastPData.worldX or pData.worldY ~= lastPData.worldY or pData.worldZ ~= lastPData.worldZ then
      isChanged = true
    end

    if pData.playerX ~= lastPData.playerX or pData.playerY ~= lastPData.playerY then
      isChanged = true
    end

    if pData.forwardX ~= lastPData.forwardX or pData.forwardY ~= lastPData.forwardY or pData.forwardZ ~= lastPData.forwardZ or
      pData.rightX ~= lastPData.rightX or pData.rightY ~= lastPData.rightY or pData.rightZ ~= lastPData.rightZ or
      pData.upX ~= lastPData.upX or pData.upY ~= lastPData.upY or pData.upZ ~= lastPData.upZ then
      isChanged = true
    end
  end

  lastPData = pData
  return pData, isChanged -- passing isChanged because need to also know if Target has not changed
end

local function GDIM(px, py, tx, ty)

  if px == nil or py == nil or tx == nil or ty == nil then
    return 0
  end

  return Lib3D:GlobalDistanceInMeters(px, py, tx, ty)
end

local function Update()
  -- get common shared data and work out if anything changed
  local pData, isChanged = GetPlayerData()
  if pData == false then return end

  -- if pData.playerX == 0 and pData.playerY == 0 then
  -- 	pData.playerX, pData.playerY = LibGPS2:LocalToGlobal(GetMapPlayerPosition("player"))
  -- end

  -- could possibly use callbacks instead ?
  local data

  for i = 1, #allArrows do
    data = allArrows[i].data

    -- only continue if its visible and something changed
    if not allArrows[i]:IsHidden() or data.targetX ~= data.lastTargetX or data.targetY ~= data.lastTargetY or isChanged or (data.targetX ~= 0 and data.targetY ~= 0) then
      data.lastTargetX = data.targetX
      data.lastTargetY = data.targetY
      data.metres = Lib3D:IsValidZone() and GDIM(pData.playerX, pData.playerY, data.targetX, data.targetY) or 0

      -- update
      if not allArrows[i].arrow:IsHidden() then L3DA:UpdateArrow(allArrows[i], data, pData) end
      if not allArrows[i].distance:IsHidden() then L3DA:UpdateDistance(allArrows[i], data, pData) end
      if not allArrows[i].marker:IsHidden() then L3DA:UpdateMarker(allArrows[i], data, pData) end
    end
  end
end

local function OnPlayerActivated(identifier, zoneIndex, isValidZone, newZone)
  if not newZone then return end

  -- reset
  -- lastPData = {}
  -- for i = 1, #allArrows do
  --   data = allArrows[i].data
  --   data.targetX = 0
  --   data.targetY = 0
  --   data.lastTargetX = 0
  --   data.lastTargetY = 0
  --   allArrows[i]:SetTarget(data.targetX, data.targetY)
  -- end

  EVENT_MANAGER:UnregisterForUpdate(identifier)

  -- main loop
  local status, err
  EVENT_MANAGER:RegisterForUpdate(identifier, 0, function(timeMS)
    status, err = pcall(Update)

    if status == false then
      d("Lib3DArrow Error:")
      d(err)
      EVENT_MANAGER:UnregisterForUpdate(identifier)
    end

  end)
end

--------------------------------------------------------------------------------------------------

local uniqueId = 0

function lib:CreateArrow(data)
  uniqueId = uniqueId + 1

  -- register worldcallback (main loop, need only one)
  if uniqueId == 1 then
    Lib3D:RegisterWorldChangeCallback(self.name .. "_ArrowWorldChangeCallback", OnPlayerActivated)
  end

  -- Check settings/defaults
  data = data or {}
  data.targetX = 0
  data.targetY = 0
  data.lastTargetX = 0
  data.lastTargetY = 0

  -- arrow and distance use this
  data.depthBuffer = type(data.depthBuffer) == "nil" and true or data.depthBuffer

  -- arrow and distance use this
  data.arrowMagnitude = data.arrowMagnitude or 5

  -- Top Level
  local toplevel = WINDOW_MANAGER:CreateTopLevelWindow(self.name .. "_TopLevel" .. uniqueId)
  toplevel:SetDrawLayer(0)           -- need for fragment to work ?
  -- toplevel:SetDrawLevel(0)        -- dont need ?
  -- toplevel:Create3DRenderSpace()  -- not making toplevel 3dspace so origin doesnt reset at 1km or in new zone
  toplevel.uniqueId = uniqueId
  toplevel.data = data

  -- show only in relevant scenes
  -- toplevel.fragment = ZO_SimpleSceneFragment:New(toplevel)
  -- HUD_UI_SCENE:AddFragment(toplevel.fragment)
  -- HUD_SCENE:AddFragment(toplevel.fragment)
  -- LOOT_SCENE:AddFragment(toplevel.fragment)

  -- adding some helpful getter/setter functions
  -- function toplevel:SetTarget(x, y)
  --   self.data.targetX, self.data.targetY = LibGPS2:LocalToGlobal(x, y)
  -- end

  function toplevel:SetTarget(x, y)
    if x == 0 and y == 0 or not x then
      self.data.targetX = 0
      self.data.targetY = 0
      self.data.lastTargetX = 0
      self.data.lastTargetY = 0
      self:SetHidden(true)
      return
    end

    self.data.targetX, self.data.targetY = LibGPS2:LocalToGlobal(x, y)
    self:SetHidden(false)
  end

  function toplevel:GetTarget()
    return self.data.targetX, self.data.targetY
  end

  function toplevel:ChangeColours(arrowColour, markerColour)
    local c

    if arrowColour then
      c = ZO_ColorDef:New(arrowColour)
      self.arrow.chevron:SetColor(c.r, c.g, c.b, c.a)
    end

    if markerColour then
      if self.marker then
        c = ZO_ColorDef:New(markerColour)
        self.marker.pillar:SetColor(c.r, c.g, c.b, c.a)
      end
    end
  end

  -- create compoonents
  L3DA:CreateArrow(toplevel, data)
  L3DA:CreateDistance(toplevel, data)
  L3DA:CreateMarker(toplevel, data)

  toplevel:SetHidden(true)
  allArrows[uniqueId] = toplevel
  return allArrows[uniqueId]
end

