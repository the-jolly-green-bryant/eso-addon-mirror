local KeepTypes = {
  Keep = {Id = 1, Name = "Keep", Icon = "EsoUI/Art/MapPins/AvA_largeKeep_Aldmeri.dds"},
  Outpost = {Id = 2, Name = "Outpost", Icon = "EsoUI/Art/MapPins/AvA_outpost_aldmeri.dds"},
  BorderKeep = {Id = 3, Name = "Border Keep", Icon = "EsoUI/Art/MapPins/AvA_borderKeep_pin_aldmeri.dds"},
  Farm = {Id = 4, Name = "Farm", Icon = "EsoUI/Art/MapPins/AvA_farm_Aldmeri.dds"},
  Mine = {Id = 5, Name = "Mine", Icon = "EsoUI/Art/MapPins/AvA_mine_Aldmeri.dds"},
  Mill = {Id = 6, Name = "Mill", Icon = "EsoUI/Art/MapPins/AvA_lumbermill_Aldmeri.dds"},
  ArtifactKeep = {Id = 7, Name = "Scroll Keep", Icon = "EsoUI/Art/MapPins/AvA_artifactTemple_Aldmeri.dds"},
  ArtifactGate = {Id = 8, Name = "Scroll Gate", Icon = "EsoUI/Art/MapPins/AvA_artifactGate_aldmeri_open.dds"},
  AvATown = {Id = 9, Name = "Town", Icon = "EsoUI/Art/MapPins/AvA_town_Aldmeri.dds"},
  Bridge = {Id = 10, Name = "Bridge", Icon = "EsoUI/Art/MapPins/AvA_bridge_passable.dds"},
  BridgeMileGate = {Id = 11, Name = "Mile Gate", Icon = "EsoUI/Art/MapPins/AvA_milegate_passable.dds"}
}

local IconMapping = {
  [MAP_PIN_TYPE_KEEP_NEUTRAL] = KeepTypes.Keep.Id,
  [MAP_PIN_TYPE_KEEP_ALDMERI_DOMINION] = KeepTypes.Keep.Id,
  [MAP_PIN_TYPE_KEEP_EBONHEART_PACT] = KeepTypes.Keep.Id,
  [MAP_PIN_TYPE_KEEP_DAGGERFALL_COVENANT] = KeepTypes.Keep.Id,
  [MAP_PIN_TYPE_OUTPOST_NEUTRAL] = KeepTypes.Outpost.Id,
  [MAP_PIN_TYPE_OUTPOST_ALDMERI_DOMINION] = KeepTypes.Outpost.Id,
  [MAP_PIN_TYPE_OUTPOST_EBONHEART_PACT] = KeepTypes.Outpost.Id,
  [MAP_PIN_TYPE_OUTPOST_DAGGERFALL_COVENANT] = KeepTypes.Outpost.Id,
  [MAP_PIN_TYPE_BORDER_KEEP_ALDMERI_DOMINION] = KeepTypes.BorderKeep.Id,
  [MAP_PIN_TYPE_BORDER_KEEP_EBONHEART_PACT] = KeepTypes.BorderKeep.Id,
  [MAP_PIN_TYPE_BORDER_KEEP_DAGGERFALL_COVENANT] = KeepTypes.BorderKeep.Id,
  [MAP_PIN_TYPE_FARM_NEUTRAL] = KeepTypes.Farm.Id,
  [MAP_PIN_TYPE_FARM_ALDMERI_DOMINION] = KeepTypes.Farm.Id,
  [MAP_PIN_TYPE_FARM_EBONHEART_PACT] = KeepTypes.Farm.Id,
  [MAP_PIN_TYPE_FARM_DAGGERFALL_COVENANT] = KeepTypes.Farm.Id,
  [MAP_PIN_TYPE_MINE_NEUTRAL] = KeepTypes.Mine.Id,
  [MAP_PIN_TYPE_MINE_ALDMERI_DOMINION] = KeepTypes.Mine.Id,
  [MAP_PIN_TYPE_MINE_EBONHEART_PACT] = KeepTypes.Mine.Id,
  [MAP_PIN_TYPE_MINE_DAGGERFALL_COVENANT] = KeepTypes.Mine.Id,
  [MAP_PIN_TYPE_MILL_NEUTRAL] = KeepTypes.Mill.Id,
  [MAP_PIN_TYPE_MILL_ALDMERI_DOMINION] = KeepTypes.Mill.Id,
  [MAP_PIN_TYPE_MILL_EBONHEART_PACT] = KeepTypes.Mill.Id,
  [MAP_PIN_TYPE_MILL_DAGGERFALL_COVENANT] = KeepTypes.Mill.Id,
  [MAP_PIN_TYPE_ARTIFACT_KEEP_ALDMERI_DOMINION] = KeepTypes.ArtifactKeep.Id,
  [MAP_PIN_TYPE_ARTIFACT_KEEP_EBONHEART_PACT] = KeepTypes.ArtifactKeep.Id,
  [MAP_PIN_TYPE_ARTIFACT_KEEP_DAGGERFALL_COVENANT] = KeepTypes.ArtifactKeep.Id,
  [MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_ALDMERI_DOMINION] = KeepTypes.ArtifactGate.Id,
  [MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_DAGGERFALL_COVENANT] = KeepTypes.ArtifactGate.Id,
  [MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_EBONHEART_PACT] = KeepTypes.ArtifactGate.Id,
  [MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_ALDMERI_DOMINION] = KeepTypes.ArtifactGate.Id,
  [MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_DAGGERFALL_COVENANT] = KeepTypes.ArtifactGate.Id,
  [MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_EBONHEART_PACT] = KeepTypes.ArtifactGate.Id,
  -- [MAP_PIN_TYPE_KEEP_ATTACKED_SMALL] = false.Id,
  -- [MAP_PIN_TYPE_KEEP_ATTACKED_LARGE] = false.Id,
  [MAP_PIN_TYPE_AVA_TOWN_NEUTRAL] = KeepTypes.AvATown.Id,
  [MAP_PIN_TYPE_AVA_TOWN_ALDMERI_DOMINION] = KeepTypes.AvATown.Id,
  [MAP_PIN_TYPE_AVA_TOWN_EBONHEART_PACT] = KeepTypes.AvATown.Id,
  [MAP_PIN_TYPE_AVA_TOWN_DAGGERFALL_COVENANT] = KeepTypes.AvATown.Id,
  [MAP_PIN_TYPE_KEEP_BRIDGE] = KeepTypes.Bridge.Id,
  [MAP_PIN_TYPE_KEEP_BRIDGE_IMPASSABLE] = KeepTypes.Bridge.Id,
  [MAP_PIN_TYPE_KEEP_MILEGATE] = KeepTypes.BridgeMileGate.Id,
  [MAP_PIN_TYPE_KEEP_MILEGATE_CENTER_DESTROYED] = KeepTypes.BridgeMileGate.Id,
  [MAP_PIN_TYPE_KEEP_MILEGATE_IMPASSABLE] = KeepTypes.BridgeMileGate.Id
}

ProvinatusAVA = ZO_Object:Subclass()

function ProvinatusAVA:New(...)
  self.Keeps = {}
  for i = 1, GetNumKeeps() do
    local keepId, BGContext = GetKeepKeysByIndex((i))
    if keepId ~= 0 then
      table.insert(self.Keeps, keepId, BGContext)
    end
  end
  return ZO_Object.New(self)
end

function ProvinatusAVA:Update()
  local Elements = {}
  if Provinatus.SavedVars.AVA.Enabled and IsInAvAZone() then
    for Id, BGContext in pairs(self.Keeps) do
      if Provinatus.SavedVars.AVA.Objectives and GetKeepArtifactObjectiveId(Id) ~= 0 then
        local ObjectivePinType, X, Y, ContinuousUpdate =
          GetObjectivePinInfo(Id, GetKeepArtifactObjectiveId(Id), BGContext)
        local Texture = ZO_MapPin.GetStaticPinTexture(ObjectivePinType)
        table.insert(
          Elements,
          {
            X = X,
            Y = Y,
            Height = Provinatus.SavedVars.AVA.Size * 2,
            Width = Provinatus.SavedVars.AVA.Size * 2,
            Alpha = Provinatus.SavedVars.AVA.Alpha,
            PinType = ObjectivePinType,
            BGContext = BGContext,
            KeepId = Id,
            Texture = Texture
          }
        )
      end

      local PinType, X, Y = GetKeepPinInfo(Id, BGContext)
      if IconMapping[PinType] ~= nil and Provinatus.SavedVars.AVA[IconMapping[PinType]] then
        if not Provinatus.SavedVars.AVA.OnlyUnderAttack or GetKeepUnderAttack(Id, BGContext) then
          local Texture = ZO_MapPin.GetStaticPinTexture(PinType)
          table.insert(
            Elements,
            {
              X = X,
              Y = Y,
              Texture = Texture,
              Alpha = Provinatus.SavedVars.AVA.Alpha,
              Height = Provinatus.SavedVars.AVA.Size,
              Width = Provinatus.SavedVars.AVA.Size,
              KeepId = Id,
              PinType = PinType,
              BGContext = BGContext
            }
          )
        end
      end
    end
  end
  local RenderedElements = Provinatus:DrawElements(self, Elements)
  for Element, Icon in pairs(RenderedElements) do
    if GetKeepUnderAttack(Element.KeepId, Element.BGContext) then
      if Icon.UnderAttackIcon == nil then
        Icon.UnderAttackIcon = WINDOW_MANAGER:CreateControl(nil, Icon, CT_TEXTURE)
        Icon.UnderAttackIcon:SetTexture("/esoui/art/mappins/ava_attackburst_64.dds")
        Icon.UnderAttackIcon:SetDimensions(Provinatus.SavedVars.AVA.Size, Provinatus.SavedVars.AVA.Size)
        Icon.UnderAttackIcon:SetAnchor(CENTER, Icon, CENTER, 0, 0)
        Icon:SetDrawLevel(1)
      end

      Icon.UnderAttackIcon:SetColor(1, 1, 1, 1)
    elseif
      not GetKeepUnderAttack(Element.KeepId, Element.BGContext) and Icon.UnderAttackIcon and
        Icon.UnderAttackIcon:GetAlpha() ~= 0
     then
      Icon.UnderAttackIcon:SetAlpha(0)
    end
  end
end

function ProvinatusAVA:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.AVA.Size
  end
  local function setSize(value)
    Provinatus.SavedVars.AVA.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.AVA.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.AVA.Alpha = value / 100
  end

  local Controls = {
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.AVA.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.AVA.Enabled = value
      end,
      tooltip = PROVINATUS_PVP_ENABLE,
      width = "full",
      default = ProvinatusConfig.AVA.Enabled
    },
    {
      type = "checkbox",
      name = PROVINATUS_AVA_ONLY_UNDER_ATTACK,
      getFunc = function()
        return Provinatus.SavedVars.AVA.OnlyUnderAttack
      end,
      setFunc = function(value)
        Provinatus.SavedVars.AVA.OnlyUnderAttack = value
      end,
      width = "full",
      default = ProvinatusConfig.AVA.OnlyUnderAttack,
      disable = function()
        return not ProvinatusConfig.AVA.Enabled
      end
    },
    {
      type = "slider",
      name = PROVINATUS_ICON_SIZE,
      getFunc = getSize,
      setFunc = setSize,
      min = 20,
      max = 150,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      tooltip = PROVINATUS_ICON_SIZE_TT,
      width = "half",
      default = ProvinatusConfig.AVA.Size
    },
    {
      type = "slider",
      name = PROVINATUS_TRANSPARENCY,
      getFunc = getAlpha,
      setFunc = setAlpha,
      min = 0,
      max = 100,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      tooltip = PROVINATUS_TRANSPARENCY_TT,
      width = "half",
      default = ProvinatusConfig.AVA.Alpha * 100
    },
    {
      type = "checkbox",
      name = PROVINATUS_OBJECTIVES,
      getFunc = function()
        return Provinatus.SavedVars.AVA.Objectives
      end,
      setFunc = function(value)
        Provinatus.SavedVars.AVA.Objectives = value
      end,
      reference = "ProvinatusObjective",
      tooltip = PROVINATUS_OBJECTIVES_TT,
      width = "full",
      default = ProvinatusConfig.AVA.Objectives
    }
  }

  for KeepType, KeepData in pairs(KeepTypes) do
    if Provinatus.SavedVars.AVA[KeepData.Id] == nil then
      Provinatus.SavedVars.AVA[KeepData.Id] = false
    end
    local Item = {
      type = "checkbox",
      name = KeepData.Name,
      getFunc = function()
        return Provinatus.SavedVars.AVA[KeepData.Id]
      end,
      setFunc = function(value)
        Provinatus.SavedVars.AVA[KeepData.Id] = value
      end,
      reference = "Provinatus" .. KeepType,
      width = "full",
      default = false
    }

    table.insert(Controls, Item)
  end
  return {
    type = "submenu",
    name = PROVINATUS_PVP,
    reference = "ProvinatusAVAMenu",
    controls = Controls,
    icon = "Provinatus/Icons/ava-icon.dds"
  }
end

function ProvinatusAVA:SetMenuIcon()
  for KeepType, KeepData in pairs(KeepTypes) do
    local Control = _G["Provinatus" .. KeepType]
    local Icon = WINDOW_MANAGER:CreateControl(nil, Control, CT_TEXTURE)
    Icon:SetAnchor(CENTER, Control, CENTER, 0, 0)
    Icon:SetTexture(KeepData.Icon)
    Icon:SetDimensions(50, 50)
    Icon:SetAlpha(1)
  end

  local Icon = WINDOW_MANAGER:CreateControl(nil, ProvinatusObjective, CT_TEXTURE)
  Icon:SetAnchor(CENTER, ProvinatusObjective, CENTER, 0, 0)
  Icon:SetTexture("esoui/art/campaign/overview_scrollicon_aldmeri.dds")
  Icon:SetDimensions(50, 50)
  Icon:SetAlpha(1)
end
