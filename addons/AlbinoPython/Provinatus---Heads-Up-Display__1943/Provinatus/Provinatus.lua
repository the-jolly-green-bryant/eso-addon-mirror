local ProvinatusDriver = ZO_Object:Subclass()

local PROVINATUS_ADDON_LOADED = "ProvinatusAddonLoaded"

local PROVINANATUS_PLAYER_ACTIVATED = "ProvinatusPlayerActivated"

local PROVINATUS_UPDATE = "ProvinatusUpdate"

local ACCOUNTWIDE_VARS = "ProvinatusVariables"

function ProvinatusDriver:New(...)
  self.Listeners = { OnClear = {} }
  self.DisplayEnable = true
  self.Icons = {}
  self.DisabledLayers = {}
  self.SavedVarsAccount = ZO_SavedVars:NewAccountWide(ACCOUNTWIDE_VARS, 1, nil, ProvinatusConfig)
  self.Profile = ZO_SavedVars:NewAccountWide("ProvinatusProfileConfig", 1, nil, { Profiles = {} })
  if self.SavedVarsAccount.AccountWideVars then
    self.SavedVars = self.SavedVarsAccount
  else
    self.SavedVars = ZO_SavedVars:NewCharacterIdSettings(ACCOUNTWIDE_VARS, 1, nil, ProvinatusConfig)
  end
  self.DisplaySettings = self.SavedVars.Display
  self.TopLevelWindow = CreateTopLevelWindow("ProvinatusHUD")
  self.TopLevelWindow:SetAnchor(CENTER, nil, CENTER, self.DisplaySettings.X, self.DisplaySettings.Y)
  EVENT_MANAGER:UnregisterForEvent(PROVINATUS_ADDON_LOADED, EVENT_ADD_ON_LOADED)
  EVENT_MANAGER:RegisterForEvent(
      PROVINANATUS_PLAYER_ACTIVATED, EVENT_PLAYER_ACTIVATED, function(_, _)
        self:OnPlayerActivated()
      end)
  return ZO_Object.New(self)
end

function ProvinatusDriver:OnPlayerActivated()
  AVA_LAYER_INDEX = 5
  LOREBOOKS_LAYER_INDEX = 13
  HARVESTMAP_LAYER_INDEX = 18
  self.PinIterator = ProvinatusPinIterator:New()
  self.DropMarker = ProvinatusDropMarker:New()
  self.PinHandlers = {
    -- [1] = ProvinatusDaedricAnchors:New(),
    [2] = ProvinatusWaypoint:New(),
    [3] = self.DropMarker,
    [4] = ProvinatusHarvensPins:New()
  }

  self.Layers = {
    [1] = ProvinatusDisplay:New(),
    [2] = ProvinatusCompass:New(),
    [3] = ProvinatusPointer:New(),
    [4] = ProvinatusTeam:New(),
    [AVA_LAYER_INDEX] = ProvinatusAVA:New(),
    [6] = ProvinatusCompanion:New(),
    [7] = ProvinatusQuests:New(),
    -- [8] = ProvinatusWaypoint:New(),
    [9] = ProvinatusServicePins:New(),
    [10] = ProvinatusSkyshards:New(),
    [11] = ProvinatusPOI:New(),
    [12] = ProvinatusTreasureMaps:New(),
    [LOREBOOKS_LAYER_INDEX] = ProvinatusLoreBooks:New(),
    [14] = ProvinatusRallyPoint:New(),
    [15] = ProvinatusPlayerOrientation:New(),
    [16] = ProvinatusWorldEvents:New(),
    [17] = ProvinatusDungeonChampions:New(),
    [HARVESTMAP_LAYER_INDEX] = ProvinatusHarvestMap:New(),
    [19] = ProvinatusPsijic:New(),
    [20] = ProvinatusCombat:New(),
    [21] = ProvinatusChat:New(),
    [22] = ProvinatusAntiquities:New(),
    [23] = ProvinatusMapPins:New()
  }

  local OrderedMenu = {
    self.Layers[1],
    self.Layers[2],
    self.Layers[3],
    self.Layers[4],
    self.Layers[7],
    self.Layers[6],
    self.PinHandlers[2],
    self.Layers[14],
    self.Layers[9],
    self.Layers[11],
    self.Layers[15],
    self.DropMarker,
    self.Layers[16],
    self.Layers[20],
    self.Layers[19],
    self.Layers[AVA_LAYER_INDEX],
    self.Layers[22],
    self.Layers[HARVESTMAP_LAYER_INDEX],
    self.Layers[23],
    self.Layers[10],
    self.Layers[12],
    self.Layers[LOREBOOKS_LAYER_INDEX],
    self.Layers[17],
    self.Layers[21],
    self.PinHandlers[4]
  }

  self.Projection = ProvinatusProjection:New()
  self:SetPlayerData()
  for Index, Layer in pairs(self.Layers) do
    if Layer.Initialize then
      self.DisabledLayers[Index] = false
      Layer:Initialize()
    end
  end

  ProvinatusMenu.Initialize(OrderedMenu)
  local Fragment = ZO_SimpleSceneFragment:New(self.TopLevelWindow)
  HUD_SCENE:AddFragment(Fragment)
  HUD_UI_SCENE:AddFragment(Fragment)
  SIEGE_BAR_SCENE:AddFragment(Fragment)
  EVENT_MANAGER:UnregisterForEvent(PROVINANATUS_PLAYER_ACTIVATED, EVENT_PLAYER_ACTIVATED)
  EVENT_MANAGER:RegisterForUpdate(
      PROVINATUS_UPDATE, 1000 / self.DisplaySettings.RefreshRate, function()
        -- Temp work-around for Zos issue
        if not LibGPS3:GetCurrentMapMeasurement() or GetMapFilterType() == 0 then
          return
        end

        self:OnUpdate()
      end)

  if self.SavedVars.PrintInfoAtStart then
    d("Provinatus version: " .. ProvinatusConfig.Version)
    d("Author: " .. ProvinatusConfig.Author)
    d("Map Projection Mode: " .. PROV_PROJECTIONS[self.SavedVars.Display.ProjectionCode].HumanName)
    if self.SavedVars.Display.ProjectionCode == PROV_ORTHO then
      d("Orthographic Projection Scale: " .. self.SavedVars.Display.Orthomultiplier)
    end
    d("Map Coverage: " .. self.SavedVars.Display.MaxDistance .. " meters")
  end
end

function ProvinatusDriver:OnUpdate()
  if not self.DisplayEnable or self.TopLevelWindow:IsHidden() then
    return
  end

  if not ZO_WorldMap_IsWorldMapShowing() and not DoesCurrentMapMatchMapForPlayerLocation() and
      SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
    CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
  end

  self:SetPlayerData()
  self.PinIterator:Update()
  for Name, Layer in pairs(self.Layers) do
    if Layer.Update and not self.DisabledLayers[Name] then
      Layer:Update()
    end
  end
end

function ProvinatusDriver:SetPlayerData()
  local X, Y, Heading = GetMapPlayerPosition("player")
  local Zone, Subzone = select(
      3, (GetMapTileTexture()):lower():gsub("ui_map_", ""):find("maps/([%w%-]+)/([%w%-]+_[%w%-]+)"))
  self.X = X
  self.Y = Y
  self.GlobalX, self.GlobalY = LibGPS3:LocalToGlobal(X, Y)
  self.Heading = Heading
  self.Zone = Zone
  self.Subzone = Subzone
  self.GroupSize = GetGroupSize()
end

function ProvinatusDriver:DrawElements(Layer, Elements)
  if not self.Icons[Layer] and Elements ~= nil then
    self.Icons[Layer] = {}
  end

  local RenderedElements = {}

  if Elements ~= nil and #Elements > 0 then
    for Index, Element in pairs(Elements) do
      if not self.Icons[Layer][Index] then
        self.Icons[Layer][Index] = WINDOW_MANAGER:CreateControl(
            nil, self.TopLevelWindow, CT_TEXTURE)
      end

      local Projection = self.Projection:Project(Element.X, Element.Y)
      Element.Projection = Projection
      if not self.DisplaySettings.ShowDistant and Projection.DistanceM >=
          self.DisplaySettings.MaxDistance then
        self.Icons[Layer][Index]:SetAlpha(0)
      elseif self.DisplaySettings.Fade then
        self.Icons[Layer][Index]:SetAlpha(self:Fade(Projection.Distance))
      else
        self.Icons[Layer][Index]:SetAlpha(Element.Alpha)
      end

      self.Icons[Layer][Index]:SetAnchor(
          CENTER, self.TopLevelWindow, CENTER, Projection.XProjected, Projection.YProjected)
      if Element.Size then
        self.Icons[Layer][Index]:SetDimensions(Element.Size, Element.Size)
      else
        self.Icons[Layer][Index]:SetDimensions(Element.Width, Element.Height)
      end

      if Element.Texture then
        self.Icons[Layer][Index]:SetTexture(Element.Texture)
      end

      -- Map the icon to the element in case the caller wants to modify it
      RenderedElements[Element] = self.Icons[Layer][Index]
    end
  end

  if self.Icons[Layer] then
    for Index, Icon in pairs(self.Icons[Layer]) do
      if Elements == nil or Index > #Elements then
        Icon:SetAlpha(0)
      end
    end
  end

  return RenderedElements
end

function ProvinatusDriver:SetRefreshRate(Rate)
  Rate = Rate or self.DisplaySettings.RefreshRate
  EVENT_MANAGER:UnregisterForUpdate(PROVINATUS_UPDATE)
  EVENT_MANAGER:RegisterForUpdate(
      PROVINATUS_UPDATE, 1000 / Rate, function()
        self:OnUpdate()
      end)
end

function ProvinatusDriver:ClearHUD()
  for _, Layer in pairs(self.Layers) do
    self:DrawElements(Layer, {})
  end

  for _, Action in pairs(self.Listeners.OnClear) do
    Action()
  end
end

function ProvinatusDriver:RegisterOnClearListener(Action)
  if Action then
    table.insert(self.Listeners.OnClear, Action)
  end
end

function ProvinatusDriver:ToggleHUD()
  self.DisplayEnable = not self.DisplayEnable
  if not self.DisplayEnable then
    EVENT_MANAGER:UnregisterForUpdate(PROVINATUS_UPDATE)
    self:ClearHUD()
  else
    EVENT_MANAGER:RegisterForUpdate(
        PROVINATUS_UPDATE, 1000 / self.DisplaySettings.RefreshRate, function()
          self:OnUpdate()
        end)
  end
end

function ProvinatusDriver:ToggleLayer(Layer)
  self.DisabledLayers[Layer] = not self.DisabledLayers[Layer]
  if self.DisabledLayers[Layer] then
    self:DrawElements(self.Layers[Layer], {})
  end
end

function ProvinatusDriver:ToggleShowDistant()
  self.DisplaySettings.ShowDistant = not self.DisplaySettings.ShowDistant
end

function ProvinatusDriver:GetSettings(SettingsName)
  return self.SavedVars[SettingsName]
end

function ProvinatusDriver:Fade(distance)
  if self.DisplaySettings.Fade == false then
    return 1
  end
  
  local DistanceRatio = (self.DisplaySettings.Size - distance) / self.DisplaySettings.Size
  local FadeOffset = 1 - self.DisplaySettings.MinFade
  local FadeRatio = DistanceRatio * FadeOffset
  local FadeRate = FadeOffset - FadeRatio
  local Fade = 1 - FadeRate
  return Fade
end

local function AddonLoaded(EventCode, AddonName)
  if AddonName == "Provinatus" then
    Provinatus = ProvinatusDriver:New()
  end
end

EVENT_MANAGER:RegisterForEvent(PROVINATUS_ADDON_LOADED, EVENT_ADD_ON_LOADED, AddonLoaded)
