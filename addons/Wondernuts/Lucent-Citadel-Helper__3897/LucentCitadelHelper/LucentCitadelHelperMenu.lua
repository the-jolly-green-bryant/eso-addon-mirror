LCH = LCH or {}
local LCH = LCH
LCH.Menu = {}

function LCH.Menu.AddonMenu()
  local menuOptions = {
    type         = "panel",
    name         = "Lucent Citadel Helper",
    displayName  = "|cFF4500Lucent Citadel Helper|r",
    author       = LCH.author,
    version      = LCH.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }
  local requiresOSI = "Requires Ody Support Icons."
  local dataTable = {
    {
      type = "description",
      text = "Trial timers, alerts and indicators for Lucent Citadel. This version requires Code's Combat Alerts.",
    },
    {
      type = "divider",
    },
    {
      type = "description",
      text = "For mechanics arrows on players for Target, Positions... install |cff0000OdySupportIcons|r (optional dependency)",
    },
    {
      type = "divider",
    },
    {
      type    = "checkbox",
      name    = "Unlock UI",
      default = false,
      getFunc = function() return not LCH.status.locked end,
      setFunc = function( newValue ) LCH.UnlockUI(newValue) end,
    },
    {
      type = "description",
      text = "You can also do /lch lock and /lch unlock to reposition the UI.",
    },
    {
      type    = "button",
      name    = "Reset to default position",
      func = function() LCH.DefaultPosition()  end,
      warning = "Requires /reloadui for the position to reset",
    },
    {
      type    = "checkbox",
      name    = "Hide welcome text on chat",
      default = false,
      getFunc = function() return LCH.savedVariables.hideWelcome end,
      setFunc = function( newValue ) LCH.savedVariables.hideWelcome = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Zilyesset & Count Ryelaz",
      reference = "ZilyessetHeader"
    },
    {
      type    = "checkbox",
      name    = "Icon: Show Pad Numbers",
      default = true,
      getFunc = function() return LCH.savedVariables.showPadIcons end,
      setFunc = function(newValue) LCH.savedVariables.showPadIcons = newValue end,
      warning = requiresOSI
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Orphic Shattered Shard",
      reference = "OrphicHeader"
    },
    {
      type    = "checkbox",
      name    = "Panel: Thunder Thrall (Xoryn Jump) Timer",
      default = true,
      getFunc = function() return LCH.savedVariables.showXorynJumpTimer end,
      setFunc = function(newValue) LCH.savedVariables.showXorynJumpTimer = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Lightning Flood (Xoryn Cone) Timer",
      default = false,
      getFunc = function() return LCH.savedVariables.showXorynConeTimer end,
      setFunc = function(newValue) LCH.savedVariables.showXorynConeTimer = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Icon: Show Mirror Numbers",
      default = true,
      getFunc = function() return LCH.savedVariables.showMirrorIcons end,
      setFunc = function(newValue) LCH.savedVariables.showMirrorIcons = newValue end,
      warning = requiresOSI
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Last Boss",
      reference = "XorynHeader"
    },
    {
      type    = "checkbox",
      name    = "Panel: Fluctuating Current holder",
      default = true,
      getFunc = function() return LCH.savedVariables.showFluctuatingCurrentHolder end,
      setFunc = function(newValue) LCH.savedVariables.showFluctuatingCurrentHolder = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Fluctuating Current timer",
      default = true,
      getFunc = function() return LCH.savedVariables.showFluctuatingCurrentTimer end,
      setFunc = function(newValue) LCH.savedVariables.showFluctuatingCurrentTimer = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Overloaded Current timer",
      default = true,
      getFunc = function() return LCH.savedVariables.showOverloadedCurrentTimer end,
      setFunc = function(newValue) LCH.savedVariables.showOverloadedCurrentTimer = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Show Overloaded Current icons",
      default = false,
      getFunc = function() return LCH.savedVariables.showOverloadedCurrentIcons end,
      setFunc = function(newValue) LCH.savedVariables.showOverloadedCurrentIcons = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Xynizata Piercing Beam timer",
      default = false,
      getFunc = function() return LCH.savedVariables.showXynizataBeamTimer end,
      setFunc = function(newValue) LCH.savedVariables.showXynizataBeamTimer = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Xynizata Channel timer and alert",
      default = false,
      getFunc = function() return LCH.savedVariables.showXynizataChannelTimer end,
      setFunc = function(newValue) LCH.savedVariables.showXynizataChannelTimer = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Necrotic Barrage Alert",
      default = true,
      getFunc = function() return LCH.savedVariables.showNecroticBarrage end,
      setFunc = function(newValue) LCH.savedVariables.showNecroticBarrage = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Misc",
      reference = "LucentCitadelMiscMenu"
    },
    {
      type = "description",
      text = "NOT recommended to change. Unlock UI first to be able to change scale.",
    },
    {
      type    = "slider",
      name    = "Scale",
      min = 0.2,
      max = 2.5,
      step = 0.1,
      decimals = 1,
      tooltip = "0.5 is tiny, 2 is huge",
      default = LCH.savedVariables.uiCustomScale,
      disabled = function() return LCH.status.locked end,
      getFunc = function() return LCH.savedVariables.uiCustomScale end,
      setFunc = function(newValue) LCH.SetScale(newValue) end,
      warning = "Only for extreme resolutions. Addon optimized for scale=1."
    },
  }

  LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(LCH.name .. "Options", menuOptions)
  LAM:RegisterOptionControls(LCH.name .. "Options", dataTable)
end
