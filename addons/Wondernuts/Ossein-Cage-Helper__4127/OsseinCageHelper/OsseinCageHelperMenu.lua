OCH = OCH or {}
local OCH = OCH
OCH.Menu = {}

function OCH.Menu.AddonMenu()
  local menuOptions = {
    type         = "panel",
    name         = "Ossein Cage Helper",
    displayName  = "|cFF4500Ossein Cage Helper|r",
    author       = OCH.author,
    version      = OCH.version,
    registerForRefresh  = true,
    registerForDefaults = true,
  }
  local requiresOSI = "Requires Ody Support Icons."
  local dataTable = {
    {
      type = "description",
      text = "Trial timers, alerts and indicators for Ossein Cage. This version requires Code's Combat Alerts.",
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
      getFunc = function() return not OCH.status.locked end,
      setFunc = function( newValue ) OCH.UnlockUI(newValue) end,
    },
    {
      type = "description",
      text = "You can also do /OCH lock and /OCH unlock to reposition the UI.",
    },
    {
      type    = "button",
      name    = "Reset to default position",
      func = function() OCH.DefaultPosition()  end,
      warning = "Requires /reloadui for the position to reset",
    },
    {
      type    = "checkbox",
      name    = "Hide welcome text on chat",
      default = false,
      getFunc = function() return OCH.savedVariables.hideWelcome end,
      setFunc = function( newValue ) OCH.savedVariables.hideWelcome = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Common",
      reference = "CommonHeader"
    },
    {
      type    = "checkbox",
      name    = "Show Personal Caustic Carrion Stacks",
      default = true,
      getFunc = function() return OCH.savedVariables.showCausticCarrion end,
      setFunc = function(newValue) OCH.savedVariables.showCausticCarrion = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Shapers of Flesh",
      reference = "ShaperOfFleshHeader"
    },
    {
      type    = "checkbox",
      name    = "Show Channeler Done notification",
      default = true,
      getFunc = function() return OCH.savedVariables.showChannelerDone end,
      setFunc = function(newValue) OCH.savedVariables.showChannelerDone = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Show Daedroth spawn points and alerts",
      default = true,
      getFunc = function() return OCH.savedVariables.showDaedrothSpawn end,
      setFunc = function(newValue) OCH.savedVariables.showDaedrothSpawn = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Jynorah & Skorkhif",
      reference = "JynorahHeader"
    },
    {
      type    = "checkbox",
      name    = "Panel: Titanic Leap/Clash timer",
      default = true,
      getFunc = function() return OCH.savedVariables.showTitanicClash end,
      setFunc = function(newValue) OCH.savedVariables.showTitanicClash = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Boss health percentages",
      default = true,
      getFunc = function() return OCH.savedVariables.showSplitBossHealth end,
      setFunc = function(newValue) OCH.savedVariables.showSplitBossHealth = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Panel: Titan health percentages (HM only)",
      default = true,
      getFunc = function() return OCH.savedVariables.showDragonBossHealth end,
      setFunc = function(newValue) OCH.savedVariables.showDragonBossHealth = newValue end,
    },
    {
      type    = "dropdown",
      name    = "Heat Ray alerts",
      choices = {"NONE", "RELEVANT", "ALL"},
      getFunc = function() return OCH.savedVariables.showHeatRay end,
      setFunc = function(newValue) OCH.savedVariables.showHeatRay = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Reflective Scales CCA cast bars",
      default = true,
      getFunc = function() return OCH.savedVariables.showReflectiveScales end,
      setFunc = function(newValue) OCH.savedVariables.showReflectiveScales = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Reflective Scales screen border",
      default = false,
      getFunc = function() return OCH.savedVariables.showReflectiveScalesBorder end,
      setFunc = function(newValue) OCH.savedVariables.showReflectiveScalesBorder = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Titan Tail Slam cast bar (shows globally)",
      default = false,
      getFunc = function() return OCH.savedVariables.showTailSlam end,
      setFunc = function(newValue) OCH.savedVariables.showTailSlam = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Jynorah & Skorkhif Portal Helper",
      reference = "PortalHelperHeader"
    },
    {
      type = "description",
      text = "Portal Helper to remind players which portal they should be going to based on their current curse debuffs. " .. 
             "Tanks are identified by role. Settings are saved per character.",
    },
    {
      type    = "checkbox",
      name    = "Enable Portal Helper",
      default = false,
      getFunc = function() return OCH.savedVariablesChar.enablePortalHelper end,
      setFunc = function(newValue) OCH.savedVariablesChar.enablePortalHelper = newValue end,
    },
    {
      type    = "dropdown",
      name    = "Portal Team Type",
      choices = {"CHANNELER", "DRAGON"},
      getFunc = function() return OCH.savedVariablesChar.portalTeamType end,
      setFunc = function(newValue) OCH.savedVariablesChar.portalTeamType = newValue end,
    },
    {
      type    = "dropdown",
      name    = "Portal Assignment Logic",
      tooltip = "STATIC: Portal assignments are based off the first curse debuff you get, and will alternate for every curse phase. Deaths or catching the wrong curse will not affect assignments.\n" .. 
                "DYNAMIC: Portal assignments are based off the last curse debuff you get. You will never enter a portal with the wrong debuff, despite catching a curse of the unintended color.",
      choices = {"STATIC", "DYNAMIC"},
      getFunc = function() return OCH.savedVariablesChar.portalAssignmentLogic end,
      setFunc = function(newValue) OCH.savedVariablesChar.portalAssignmentLogic = newValue end,
    },
    {
      type    = "dropdown",
      name    = "Starting Boss Side (for Tanks or non-HM)",
      tooltip = "Configure your starting boss side, which is only needed to determine your portal if you do not get a curse debuff. You only need to configure this if you are a tank or playing on " .. 
                "non-hardmode difficulty where you may not get inflicted by a curse.",
      choices = {"", "RED", "BLUE"},
      getFunc = function() return OCH.savedVariablesChar.startingBossSide end,
      setFunc = function(newValue) OCH.savedVariablesChar.startingBossSide = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Boss Assignments After Portal Ends",
      default = false,
      getFunc = function() return OCH.savedVariablesChar.enablePortalEndBossAlert end,
      setFunc = function(newValue) OCH.savedVariablesChar.enablePortalEndBossAlert = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Overlord Kazpian",
      reference = "KazpianHeader"
    },
    {
      type    = "checkbox",
      name    = "Show Vile Leap alert",
      default = true,
      getFunc = function() return OCH.savedVariables.showVileLeap end,
      setFunc = function(newValue) OCH.savedVariables.showVileLeap = newValue end,
    },
    {
      type    = "dropdown",
      name    = "Dominator's Chains alert",
      choices = OCH.TARGET_CHOICES,
      getFunc = function() return OCH.savedVariables.showDominatorsChains end,
      setFunc = function(newValue) OCH.savedVariables.showDominatorsChains = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Show Giant Sword alert",
      default = false,
      getFunc = function() return OCH.savedVariables.showGiantSwords end,
      setFunc = function(newValue) OCH.savedVariables.showGiantSwords = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Show Portal Starting and Done alerts",
      default = true,
      getFunc = function() return OCH.savedVariables.showKazpianPortalDone end,
      setFunc = function(newValue) OCH.savedVariables.showKazpianPortalDone = newValue end,
    },
    {
      type    = "checkbox",
      name    = "Show Portal Exit icon",
      default = true,
      getFunc = function() return OCH.savedVariables.showKazpianPortalExitIcon end,
      setFunc = function(newValue) OCH.savedVariables.showKazpianPortalExitIcon = newValue end,
    },
    {
      type = "divider",
    },
    {
      type = "header",
      name = "Misc",
      reference = "OsseinCageMiscMenu"
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
      default = OCH.savedVariables.uiCustomScale,
      disabled = function() return OCH.status.locked end,
      getFunc = function() return OCH.savedVariables.uiCustomScale end,
      setFunc = function(newValue) OCH.SetScale(newValue) end,
      warning = "Only for extreme resolutions. Addon optimized for scale=1."
    },
  }

  LAM = LibAddonMenu2
  LAM:RegisterAddonPanel(OCH.name .. "Options", menuOptions)
  LAM:RegisterOptionControls(OCH.name .. "Options", dataTable)
end
