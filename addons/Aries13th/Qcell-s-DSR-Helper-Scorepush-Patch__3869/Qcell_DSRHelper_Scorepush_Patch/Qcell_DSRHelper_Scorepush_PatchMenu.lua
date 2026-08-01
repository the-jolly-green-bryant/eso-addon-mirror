QDRH_SP = QDRH_SP or {}
local QDRH_SP = QDRH_SP
QDRH_SP.Menu = {}

function QDRH_SP.Menu.AddonMenu()
  local menuOptions = {
    type         = "panel",
    name         = "Qcell's DSR Helper Scorepush Patch",
    displayName  = "|cFF4500Qcell's DSR Helper Scorepush Patch|r",
    author       = QDRH_SP.author,
    version      = QDRH_SP.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }
  local dataTable = {
    {
      type = "description",
      text = "Additional changes for Qcell's Dreadsail Reef Helper.",
    },
    {
      type = "header",
      name = "Lylanar & Turlassil",
      reference = "LylanarTurlassil"
    },
    {
      type = "divider",
    },
    {
      type = "description",
      text = "This option adds adaptive positions to stack.\nAddon will look for best positions in two different corners of the group.\nThis option should be enabled only if two tanks stand in different sides of arena on execute phase",
    },
    {
      type    = "checkbox",
      name    = "Adaptive Fire/Frostbrand rune stack",
      default = true,
      getFunc = function() return QDRH_SP.savedVariables.useAdaptiveStackPoints end,
      setFunc = function(newValue) QDRH_SP.savedVariables.useAdaptiveStackPoints = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Show both stack points every time",
      default = false,
      getFunc = function() return QDRH_SP.savedVariables.showAdaptiveStackPointsEveryTime end,
      setFunc = function(newValue) QDRH_SP.savedVariables.showAdaptiveStackPointsEveryTime = newValue end,
      warning = "It shows '1' and '2' visual numbers on both stack positions (geo-location still shows if you have the debuff)",
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Reef Guardian",
      reference = "ReefGuardian"
    },
    {
      type = "divider",
    },
    {
      type    = "checkbox",
      name    = "Hide Combat Alerts panel",
      default = false,
      getFunc = function() return not QDRH_SP.savedVariables.showCAPanel end,
      setFunc = function(newValue) QDRH_SP.savedVariables.showCAPanel = not newValue end,
      warning = "Shows/Hides default Code's Combat Alerts' panel with reefs statuses",
    },
    {
      type    = "checkbox",
      name    = "Show Guardians HP comparison panel",
      default = false,
      getFunc = function() return QDRH_SP.savedVariables.showHPComparison end,
      setFunc = function(newValue) QDRH_SP.savedVariables.showHPComparison = newValue end,
      warning = "Shows panel with pairs bosses HP comparison (L with M1) and (M2 with S1). Red color - need damage. Green color - above 80%.",
    },
    {
      type    = "checkbox",
      name    = "Unlock Panel",
      default = false,
      getFunc = function() return QDRH_SP.settings.unlockHPComparison end,
      setFunc = function(newValue) QDRH_SP.settings.unlockHPComparison = newValue; QCellDSRHelperScorepushPanel:SetMovable(newValue); QCellDSRHelperScorepushPanel:SetHidden(not newValue); end,
    },
  }

  LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(QDRH_SP.name .. "Options", menuOptions)
  LAM:RegisterOptionControls(QDRH_SP.name .. "Options", dataTable)
end