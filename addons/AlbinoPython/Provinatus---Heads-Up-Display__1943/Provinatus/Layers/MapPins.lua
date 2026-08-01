ProvinatusMapPins = ZO_Object:Subclass()

function ProvinatusMapPins:New(...)
  self.PM = ZO_WorldMap_GetPinManager()
  self.SavedVars = Provinatus.SavedVars.MapPins
  self.PinTypeSettings = {}
  for PinType, PinSettings in pairs(self.SavedVars.PinTypes) do
    if _G[PinSettings.PinName] then
      self.PinTypeSettings[_G[PinSettings.PinName]] = PinSettings
    end
  end

  return ZO_Object.New(self)
end

function ProvinatusMapPins:Update()
  local Elements = {}
  if Provinatus.SavedVars.MapPins.Enabled then
    for _, Data in self.PM:ActiveObjectIterator(
      {
        [1] = function(CurrentData)
          return CurrentData.m_PinType and self.PinTypeSettings[CurrentData.m_PinType] and
            self.PinTypeSettings[CurrentData.m_PinType].Enabled and
            CurrentData.normalizedX >= 0 and
            CurrentData.normalizedX <= 1 and
            CurrentData.normalizedY >= 0 and
            CurrentData.normalizedY <= 1
        end
      }
    ) do
      local Texture
      if Data.m_PinTag.texture then
        if type(Data.m_PinTag.texture) == "function" then
          Texture = Data.m_PinTag.texture(Data)
        else
          Texture = Data.m_PinTag.texture
        end
      end

      if not Texture then
        Texture = self.PinTypeSettings[Data.m_PinType].Texture
      end

      table.insert(
        Elements,
        {
          X = Data.normalizedX,
          Y = Data.normalizedY,
          Alpha = self.SavedVars.Alpha,
          Size = self.SavedVars.Size,
          Texture = Texture,
          Data = Data
        }
      )
    end
  end
  Provinatus:DrawElements(self, Elements)
end

function ProvinatusMapPins:GetPinTypeSettings(SettingName, Settings)
  return {
    type = "checkbox",
    name = Settings.MenuTitle,
    getFunc = function()
      return Settings.Enabled
    end,
    setFunc = function(value)
      Settings.Enabled = value
    end,
    width = "full",
    default = ProvinatusConfig.MapPins.PinTypes[SettingName].Enabled,
    disabled = function()
      return not self.SavedVars.Enabled
    end
  }
end

function ProvinatusMapPins:GetMenu()
  local PinTypes = self.SavedVars.PinTypes
  local PinTypeDefaults = ProvinatusConfig.MapPins.PinTypes

  local function getSize()
    return Provinatus.SavedVars.MapPins.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.MapPins.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.MapPins.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.MapPins.Alpha = value / 100
  end

  local Controls = {
    {
      type = "description",
      text = PROVINATUS_MAPPIN_ICON_WARNING,
      width = "full"
    },
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.MapPins.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.MapPins.Enabled = value
      end,
      width = "full",
      tooltip = PROVINATUS_MAPPINS_ENABLE_TT,
      default = ProvinatusConfig.MapPins.Enabled
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
      default = ProvinatusConfig.MapPins.Size
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
      default = ProvinatusConfig.MapPins.Alpha * 100
    }
  }

  for SettingName, PinTypeSettings in pairs(self.SavedVars.PinTypes) do
    table.insert(Controls, self:GetPinTypeSettings(SettingName, PinTypeSettings))
  end

  return {
    type = "submenu",
    name = PROVINATUS_MAPPINS,
    tooltip = PROVINATUS_MAPPINS_ENABLE_TT,
    controls = Controls,
    disabled = not pinType_Skyshards,
    icon = "Provinatus/Icons/Chest_1.dds"
  }
end
