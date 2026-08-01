ProvinatusServicePins = ZO_Object:Subclass()

function ProvinatusServicePins:New(...)
  return ZO_Object.New(self)
end

function ProvinatusServicePins:Update()
  local Elements = {}
  if Provinatus.SavedVars.ServicePins.Enabled then
    for i = 1, GetNumMapLocations() do
      local icon, normalizedX, normalizedY = GetMapLocationIcon(i)
      if (icon and (icon ~= "")) then
        table.insert(
          Elements,
          {
            X = normalizedX,
            Y = normalizedY,
            Texture = icon,
            Alpha = Provinatus.SavedVars.ServicePins.Alpha,
            Height = Provinatus.SavedVars.ServicePins.Size,
            Width = Provinatus.SavedVars.ServicePins.Size
          }
        )
      end
    end
  end

  Provinatus:DrawElements(self, Elements)
end

function ProvinatusServicePins:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.ServicePins.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.ServicePins.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.ServicePins.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.ServicePins.Alpha = value / 100
  end

  local Controls = {
    [1] = {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.ServicePins.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.ServicePins.Enabled = value
      end,
      width = "full",
      default = ProvinatusConfig.ServicePins.Enabled
    },
    [2] = {
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
      default = ProvinatusConfig.ServicePins.Size
    },
    [3] = {
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
      default = ProvinatusConfig.ServicePins.Alpha * 100
    }
  }

  return {
    type = "submenu",
    name = PROVINATIS_SERVICES,
    tooltip = PROVINATIS_SERVICES_TT,
    icon = "esoui/art/icons/servicemappins/servicepin_stable.dds",
    reference = "ProvinatusServicePinsMenu",
    controls = Controls
  }
end
