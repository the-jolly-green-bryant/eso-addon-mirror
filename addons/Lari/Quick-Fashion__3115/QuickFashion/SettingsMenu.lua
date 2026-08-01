local QF = _G["QF"]

local LAM = LibAddonMenu2

---------------------------
-- SETTINGS MENU --
---------------------------

function QF.CreateSettingsMenu()
  local panelName = "QuickFashionSettings"

  local panelData = {
    type = "panel",
    name = "|c7B68EEQuick|r |c9F00FFFashion|r",
    author = "|cBFFF00Lari|r (|c7B68EE@akshari|r on PC/EU)",
    slashCommand = "/qfhelp",
    version = QF.addonVersion,
    registerForRefresh = true,
		registerForDefaults = true,
  }

  local panel = LAM:RegisterAddonPanel(panelName, panelData)

  local optionsData = {
    {
      type = "header",
      name = "Help",
      width = "full",
    },
    {
      type  = "description",
      title = "Slash Commands",
      text  = "|c7B68EE/qf|r |c7E7E7E- Toggle Quick Fashion AND Quick Favourites panels|r\n" ..
              "|c7B68EE/qfashion|r |c7E7E7E- Toggle Quick Fashion panel|r\n" ..
              "|c7B68EE/qfavs|r |c7E7E7E- Toggle Quick Favourites panel|r\n" ..
              "|c7B68EE/qprofiles|r |c7E7E7E- Toggle Quick Profiles panel|r\n" ..
              "|c7B68EE/qf|r |c9832FF<number>|r |c7E7E7E- Equip profile by number (e.g. /qf 1)|r\n" ..
              "|c7B68EE/qflist|r |c7E7E7E- List profiles assigned to hotkeys|r\n" ..
              "|c7B68EE/qrand|r |c7E7E7E- Randomize your equipped collectibles\n" ..
              "|c7B68EE/qfhelp| |c7E7E7E- Opens this window",
      width = "full",
    },
    {
      type = "button",
      name = "Send Feedback",
      func = function() MAIN_MENU_KEYBOARD:ShowScene("mailSend") MAIL_SEND:SetReply("@akshari", "Quick Fashion") end,
      tooltip = "Send me a mail with any bug reports, feedback, or suggestions!",
    },
    {
      type = "header",
      name = "Display",
      width = "full",
    },
    {
      type = "checkbox",
      name = "Display Quick Fashion with Collections menu",
      getFunc = function() return QF.SavedVars.showQFPanelWithCollections end,
      setFunc = function(setting) QF.SavedVars.showQFPanelWithCollections = setting end,
    },
    {
      type = "checkbox",
      name = "Display Quick Favourites with Collections menu",
      getFunc = function() return QF.SavedVars.showFavsPanelWithCollections end,
      setFunc = function(setting) QF.SavedVars.showFavsPanelWithCollections = setting end,
    },
    {
      type = "checkbox",
      name = "Display Quick Profiles with Collections menu",
      getFunc = function() return QF.SavedVars.showAOPanelWithCollections end,
      setFunc = function(setting) QF.SavedVars.showAOPanelWithCollections = setting end,
    },
    {
      type = "button",
      name = "Reset positions",
      func = QF.ResetPositions,
      width = "half",
    },
    {
      type = "header",
      name = "Quick Favourites Panel",
      width = "full",
    },
    {
      type  = "description",
      title = "Add or remove all collectibles to Favourites:",
      width = "full",
    },
    {
      type = "button",
      name = "Add all to Favourites",
      func = QF.AddAllCollectiblesToFavourites,
      tooltip = "Add all owned collectibles to Favourites",
      width = "half",
    },
    {
      type = "button",
      name = "Remove all Favourites",
      func = QF.RemoveAllCollectiblesFromFavourites,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Load all collectibles on startup",
      getFunc = function() return QF.SavedVars.initAllCollectibleIcons end,
      setFunc = function(setting) QF.SavedVars.initAllCollectibleIcons = setting end,
      warning = "May result in slower load times",
    },
    {
      type = "slider",
      name = "Recently equipped items to display",
      getFunc = function() return QF.SavedVars.numRecentCollectibles end,
      setFunc = function(setting) QF.SavedVars.numRecentCollectibles = setting
                                  QF.RefreshRecentlyEquipped() end,
      min = 4,
      max = 16,
      step = 1,
      default = 8,
    },
    {
      type = "header",
      name = "Account-Wide Settings",
      width = "full",
    },
    {
      type = "checkbox",
      name = "Use account-wide settings",
      tooltip = "If enabled, all your characters will share the same profiles and favourites.",
      getFunc = function() return QF.AWSV.accountWide end,
      setFunc = function(setting) QF.AWSV.accountWide = setting
                                  ReloadUI() end,
      warning = "Changing this setting will reload the UI",
    },
  }

  LAM:RegisterOptionControls("QuickFashionSettings", optionsData)
end
