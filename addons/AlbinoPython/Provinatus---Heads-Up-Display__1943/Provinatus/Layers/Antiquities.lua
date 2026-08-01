ProvinatusAntiquities = ZO_Object:Subclass()
local DisableLayer = false

function ProvinatusAntiquities:New(...)
  return ZO_Object.New(self)
end

function ProvinatusAntiquities:Update()
  local Elements = {}

  if Provinatus.SavedVars.Antiquities.Enabled and not DisableLayer then
    for AntiquityIndex = 1, GetNumInProgressAntiquities() do
      local InProgressId = GetInProgressAntiquityId(AntiquityIndex)
      local NumDigSites = GetNumDigSitesForInProgressAntiquity(AntiquityIndex)
      for DigSiteIndex = 1, NumDigSites do
        local DigSiteId = GetInProgressAntiquityDigSiteId(AntiquityIndex, DigSiteIndex)
        local X, Y, IsOnCurrentMap = GetDigSiteNormalizedCenterPosition(DigSiteId)
        if IsOnCurrentMap then
          table.insert(
            Elements,
            {
              X = X,
              Y = Y,
              Height = Provinatus.SavedVars.Antiquities.Size,
              Width = Provinatus.SavedVars.Antiquities.Size,
              Alpha = Provinatus.SavedVars.Antiquities.Alpha,
              Texture = "/esoui/art/icons/collectible_memento_psijicscryingtalisman.dds" -- ZO_ANTIQUITY_UNKNOWN_ICON_TEXTURE
            }
          )
        end
      end
    end
  end

  for Element, Icon in pairs(Provinatus:DrawElements(self, Elements)) do
    Icon:SetColor(1, 1, 1, Provinatus.SavedVars.Antiquities.Alpha)
  end
end

function ProvinatusAntiquities:GetMenu()
  local function getSize()
    return Provinatus.SavedVars.Antiquities.Size
  end

  local function setSize(value)
    Provinatus.SavedVars.Antiquities.Size = value
  end

  local function getAlpha()
    return Provinatus.SavedVars.Antiquities.Alpha * 100
  end

  local function setAlpha(value)
    Provinatus.SavedVars.Antiquities.Alpha = value / 100
  end

  local Controls = {
    {
      type = "checkbox",
      name = PROVINATUS_ENABLE,
      getFunc = function()
        return Provinatus.SavedVars.Antiquities.Enabled
      end,
      setFunc = function(value)
        Provinatus.SavedVars.Antiquities.Enabled = value
      end,
      width = "full",
      tooltip = PROVINATUS_LAYER_ENABLE_TT,
      default = ProvinatusConfig.Antiquities.Enabled,
      disabled = DisableLayer
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
      default = ProvinatusConfig.Antiquities.Size,
      disabled = DisableLayer
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
      default = ProvinatusConfig.Antiquities.Alpha * 100,
      disabled = DisableLayer
    }
  }

  return {
    type = "submenu",
    name = "Antiquities",
    tooltip = "Displays location of dig sites",
    controls = Controls,
    icon = "/esoui/art/icons/collectible_memento_psijicscryingtalisman.dds"
  }
end
