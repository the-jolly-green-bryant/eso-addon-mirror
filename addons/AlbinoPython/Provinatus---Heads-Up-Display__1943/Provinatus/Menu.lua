ProvinatusMenu = {}

local function GetPanelData()
  return {
    type = "panel",
    name = ProvinatusConfig.Name,
    displayName = ProvinatusConfig.FriendlyName,
    author = ProvinatusConfig.Author,
    version = ProvinatusConfig.Version,
    website = ProvinatusConfig.Website,
    feedback = ProvinatusConfig.Feedback,
    slashCommand = ProvinatusConfig.SlashCommand,
    registerForRefresh = true,
    registerForDefaults = true
  }
end

local function GetOptionsData(Layers)
  local OptionsData = {
    ProvinatusMenu.ProfileHandler:GetMenu()
  }

  for _, Layer in pairs(Layers) do
    if Layer.GetMenu then
      local Menu = Layer:GetMenu()
      if Menu then
        table.insert(OptionsData, Menu)
      end
    end
  end

  return OptionsData
end

function ProvinatusMenu:OpenMenu()
  LibAddonMenu2:OpenToPanel(ProvinatusMenu.SettingMenu)
end

function ProvinatusMenu.DrawMenuIcon(Anchor, Texture)
  local Icon = WINDOW_MANAGER:CreateControl(nil, Anchor, CT_TEXTURE)
  Icon:SetAnchor(CENTER, Anchor, LEFT, -10, 0)
  Icon:SetTexture(Texture)
  Icon:SetDimensions(30, 30)
  Icon:SetAlpha(1)
  return Icon
end

function ProvinatusMenu.Initialize(Layers)
  local LAM2 = LibAddonMenu2
  ProvinatusMenu.SettingMenu = LAM2:RegisterAddonPanel(ProvinatusConfig.Name .. "Options", GetPanelData())
  ProvinatusMenu.ProfileHandler = ProvinatusProfiles:New()
  LAM2:RegisterOptionControls(ProvinatusConfig.Name .. "Options", GetOptionsData(Layers))
  CALLBACK_MANAGER:RegisterCallback(
    "LAM-PanelControlsCreated",
    function(Panel)
      if Panel == ProvinatusMenu.SettingMenu then
        for _, Layer in pairs(Layers) do
          if Layer.SetMenuIcon then
            Layer:SetMenuIcon(Panel)
          end
        end

        ProvinatusMenu.ProfileHandler:MenuCreated()
      end
    end
  )
end

function ProvinatusMenu.GetSubmenu(Name, Controls, Tooltip, Icon)
  return {
    type = "submenu",
    name = Name,
    icon = Icon,
    tooltip = Tooltip,
    controls = Controls
  }
end

function ProvinatusMenu.GetCheckbox(
  DisplayName,
  FeatureName,
  SettingName,
  ToolTip,
  Width,
  Disabled,
  RequiresReload,
  Reference,
  ForceAccountWide)
  local Vars = Provinatus.SavedVars
  if ForceAccountWide then
    Vars = Provinatus.SavedVarsAccount
  end
  return {
    type = "checkbox",
    name = DisplayName,
    getFunc = function()
      return Vars[FeatureName][SettingName]
    end,
    setFunc = function(value)
      Vars[FeatureName][SettingName] = value
    end,
    width = Width or "full",
    tooltip = ToolTip,
    disabled = Disabled,
    default = ProvinatusConfig[FeatureName][SettingName],
    reference = Reference
  }
end

function ProvinatusMenu.GetIconSettingsMenu(
  DescriptionText,
  GetSizeFunction,
  SetSizeFunction,
  GetAlphaFunction,
  SetAlphaFunction,
  defaultSizeFunction,
  defaultAlphaFunction,
  disabledFunction)
  local Settings = {
    {
      type = "description",
      text = DescriptionText,
      width = "full"
    },
    {
      type = "slider",
      name = PROVINATUS_ICON_SIZE,
      getFunc = GetSizeFunction,
      setFunc = SetSizeFunction,
      min = 20,
      max = 150,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      tooltip = PROVINATUS_ICON_SIZE_TT,
      width = "half",
      disabled = disabledFunction,
      default = defaultSizeFunction
    },
    {
      type = "slider",
      name = PROVINATUS_TRANSPARENCY,
      getFunc = GetAlphaFunction,
      setFunc = SetAlphaFunction,
      min = 0,
      max = 100,
      step = 1,
      clampInput = true,
      decimals = 0,
      autoSelect = true,
      inputLocation = "below",
      tooltip = PROVINATUS_TRANSPARENCY_TT,
      width = "half",
      disabled = disabledFunction,
      default = defaultAlphaFunction
    }
  }

  return Settings
end
