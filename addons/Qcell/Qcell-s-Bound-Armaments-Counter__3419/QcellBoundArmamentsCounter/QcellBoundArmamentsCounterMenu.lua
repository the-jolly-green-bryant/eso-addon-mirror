QBAC = QBAC or {}
local QBAC = QBAC
QBAC.Menu = {}

function QBAC.Menu.AddonMenu()
  local menuOptions = {
    type         = "panel",
    name         = "Qcell's Bound Armaments Counter",
    displayName  = "|cFF4500Qcell's Bound Armanents Counter|r",
    author       = QBAC.author,
    version      = QBAC.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }
  local dataTable = {
    {
      type = "description",
      text = "Bound Armaments Counter for Sorcerer.",
    },
    {
      type = "divider",
    },
    {
      type    = "checkbox",
      name    = "Show UI (sorc only)",
      default = true,
      getFunc = function() return not QBAC.status.hidden end,
      setFunc = function( newValue ) QBAC.HideUI(not newValue) end,
    },
    {
      type    = "checkbox",
      name    = "Enable simple mode (number only)",
      default = QBAC.savedVariables.simpleMode,
      getFunc = function() return QBAC.savedVariables.simpleMode end,
      setFunc = function( newValue ) QBAC.SimpleMode(newValue) end,
      warning = "The background and border will disappear.",
    },
    {
      type    = "slider",
      name    = "Alpha",
      min = 0,
      max = 1,
      step = 0.05,
      decimals = 2,
      tooltip = "0 is invisible, 1 full",
      default = QBAC.savedVariables.textureAlpha,
      disabled = function() return false end,
      getFunc = function() return QBAC.savedVariables.textureAlpha end,
      setFunc = function(newValue) QBAC.SetAlpha(newValue) end,
      warning = "Addon optimized for alpha=0.85."
    },
    {
      type    = "slider",
      name    = "Scale",
      min = 0.2,
      max = 2.5,
      step = 0.1,
      decimals = 1,
      tooltip = "0.5 is tiny, 2 is huge",
      default = QBAC.savedVariables.uiCustomScale,
      disabled = function() return false end,
      getFunc = function() return QBAC.savedVariables.uiCustomScale end,
      setFunc = function(newValue) QBAC.SetScale(newValue) end,
      warning = "Addon optimized for scale=1."
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Advanced settings & skill blocking",
      reference = "QcellBoundArmamentsCounterAdvanced"
    },
    {
      type = "description",
      text = "The settings below let you block the cast of Bound Armaments if it doesn't have full stacks, " ..
             "but it lets you still cast it at low stacks if the target has low HP % (in case you want to use " ..
             "it as a finisher). If you can't enable it, install LibSkillBlocker.",
    },
    {
      type    = "checkbox",
      name    = "Block casting it at < 4 stacks (dependency)",
      default = QBAC.savedVariables.blockCastLessThanFour,
      disabled = function() return not QBAC.HasLSB() end,
      getFunc = function() return QBAC.savedVariables.blockCastLessThanFour end,
      setFunc = function( newValue ) QBAC.SettingBlockCast(newValue) end,
      warning = "Install the library LibSkillBlocker to enable this setting.",
    },
    {
      type    = "slider",
      name    = "HP % block override",
      min = 0,
      max = 100,
      step = 1,
      decimals = 0,
      tooltip = "Lets you cast any stacks below this HP%",
      default = QBAC.savedVariables.unblockHPThreshold,
      disabled = function() return not QBAC.savedVariables.blockCastLessThanFour end,
      getFunc = function() return QBAC.savedVariables.unblockHPThreshold end,
      setFunc = function(newValue) QBAC.savedVariables.unblockHPThreshold = newValue end,
      warning = "Recommended = 15%"
    },
    {
      type    = "button",
      name    = "Force unblock (HALP!)",
      func = function() QBAC.ForceUnblockCast()  end,
      warning = "You should never need to click this, in case the addon bugs (let Qcell#0001 know, please)",
    },
  }

  LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(QBAC.name .. "Options", menuOptions)
  LAM:RegisterOptionControls(QBAC.name .. "Options", dataTable)
end