local ET = _G["ET"]

local LAM = LibAddonMenu2

----------------------------------
-- SETTINGS MENU --
----------------------------------

function ET.CreateSettingsMenu()
  local panelName = "EndeavorTrackerSettings"

  local panelData = {
    type = "panel",
    name = "|cECB8A2Endeavor Tracker|r",
    author = "|cBFFF00Lari|r (|c7B68EE@akshari|r on PC/EU)",
    slashCommand = "/ethelp",
    version = ET.addonVersion,
    registerForRefresh = true,
    registerForDefaults = true
  }

  local panel = LAM:RegisterAddonPanel(panelName, panelData)

  local optionsData = {
    {
      type = "description",
      text = string.format("%s\n%s\n%s", GetString(ENDEAVOR_TRACKER_SettingsTogglePanel), GetString(ENDEAVOR_TRACKER_SettingsToggleHistory), GetString(ENDEAVOR_TRACKER_SettingsToggleSettings)),
      width = "full"
    },
    {
      type = "button",
      name = GetString(ENDEAVOR_TRACKER_SettingsFeedbackButton),
      func = function() MAIN_MENU_KEYBOARD:ShowScene("mailSend") MAIL_SEND:SetReply("@akshari", "Endeavor Tracker") end,
      tooltip = GetString(ENDEAVOR_TRACKER_SettingsFeedbackTooltip),
    },
    {
      type = "header",
      name = GetString(ENDEAVOR_TRACKER_SettingsHeaderDisplayOptions),
      width = "full",
    },
    {
      type = "dropdown",
      name = GetString(ENDEAVOR_TRACKER_SettingsShowPanel),
      choices = {
                  ET.DisplaySettings[1],
                  ET.DisplaySettings[2],
                  ET.DisplaySettings[3],
                  ET.DisplaySettings[4],
                  ET.DisplaySettings[5],
                },
      getFunc = function() return ET.SavedVars.displayPanelSetting end,
      setFunc = function(setting) ET.SavedVars.displayPanelSetting = setting
                                  ET.DisplayPanelBySetting(setting) end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsDisplayInCombat),
      getFunc = function() return ET.SavedVars.displayInCombat end,
      setFunc = function(setting) ET.SavedVars.displayInCombat = setting end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsDisplayInDungeons),
      getFunc = function() return ET.SavedVars.displayInDungeons end,
      setFunc = function(setting) ET.SavedVars.displayInDungeons = setting
                                  ET.DisplayPanelBySetting(ET.SavedVars.displayPanelSetting) end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsDisplayInCyroAndBGs),
      getFunc = function() return ET.SavedVars.displayInCyroAndBGs end,
      setFunc = function(setting) ET.SavedVars.displayInCyroAndBGs = setting
                                  ET.DisplayPanelBySetting(ET.SavedVars.displayPanelSetting) end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsDisplayShortcutIcon),
      getFunc = function() return ET.SavedVars.isShortcutButtonVisible end,
      setFunc = function(setting) ET.SavedVars.isShortcutButtonVisible = setting
                                  ET_ShortcutBG:SetHidden(not setting)
                                  ET_ShortcutButton:SetHidden(not setting) end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsDisplayCheckboxes),
      getFunc = function() return ET.SavedVars.displayCheckboxes end,
      setFunc = function(setting) ET.SavedVars.displayCheckboxes = setting
                                  ET.ToggleCheckboxes(setting) end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsDisplayTimeRemaining),
      getFunc = function() return ET.SavedVars.displayTimeRemaining end,
      setFunc = function(setting) ET.SavedVars.displayTimeRemaining = setting
                                  ET.RefreshEndeavorHeaders() end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsHideCompleted),
      getFunc = function() return ET.SavedVars.collapseCompletedEndeavors end,
      setFunc = function(setting) ET.SavedVars.collapseCompletedEndeavors = setting
                                  ET.RefreshAll() end,
    },
    {
      type = "submenu",
      name = GetString(ENDEAVOR_TRACKER_SettingsHeaderCustomization),
      controls = {
        {
          type = "slider",
          name = GetString(ENDEAVOR_TRACKER_SettingsFontSize),
          getFunc = function() return ET.SavedVars.fontSize end,
          setFunc = function(setting) ET.SavedVars.fontSize = setting
                                      ET.SetCustomFontSize(setting) end,
          min = 12,
          max = 20,
          step = 1,
          default = 16,
        },
        {
          type = "checkbox",
          name = GetString(ENDEAVOR_TRACKER_SettingsDisplayBackground),
          getFunc = function() return ET.SavedVars.isBackdropVisible end,
          setFunc = function(setting) ET.SavedVars.isBackdropVisible = setting
                                      ET_PanelBG:SetHidden(not setting) end,
        },
        {
          type = "slider",
          name = GetString(ENDEAVOR_TRACKER_SettingsBackdropAlpha),
          getFunc = function() return ET.SavedVars.backdropAlpha end,
          setFunc = function(setting) ET.SavedVars.backdropAlpha = setting
                                      ET_PanelBG:SetAlpha(setting) end,
          min = 0,
          max = 1,
          step = 0.1,
          default = 1,
          decimals = 1,
          disabled = function() return not ET.SavedVars.isBackdropVisible end
        },
        {
          type = "colorpicker",
          name = GetString(ENDEAVOR_TRACKER_SettingsColorCompleted),
          getFunc = function() return ET.SavedVars.green.r, ET.SavedVars.green.g, ET.SavedVars.green.b, ET.SavedVars.green.a end,
          setFunc = function(r,g,b,a) ET.SavedVars.green.r = r
                                      ET.SavedVars.green.g = g
                                      ET.SavedVars.green.b = b
                                      ET.SavedVars.green.a = a
                                      ET.RefreshAll() end,
          width = "full",
          default = { r = ET.Defaults.green.r, g = ET.Defaults.green.g, b = ET.Defaults.green.b, a = ET.Defaults.green.a}
        },
        {
          type = "colorpicker",
          name = GetString(ENDEAVOR_TRACKER_SettingsColorInProgress),
          getFunc = function() return ET.SavedVars.orange.r, ET.SavedVars.orange.g, ET.SavedVars.orange.b, ET.SavedVars.orange.a end,
          setFunc = function(r,g,b,a) ET.SavedVars.orange.r = r
                                      ET.SavedVars.orange.g = g
                                      ET.SavedVars.orange.b = b
                                      ET.SavedVars.orange.a = a
                                      ET.RefreshAll() end,
          width = "full",
          default = { r = ET.Defaults.orange.r, g = ET.Defaults.orange.g, b = ET.Defaults.orange.b, a = ET.Defaults.orange.a}
        },
        {
          type = "colorpicker",
          name = GetString(ENDEAVOR_TRACKER_SettingsColorNotStartedHeader),
          getFunc = function() return ET.SavedVars.red.r, ET.SavedVars.red.g, ET.SavedVars.red.b, ET.SavedVars.red.a end,
          setFunc = function(r,g,b,a) ET.SavedVars.red.r = r
                                      ET.SavedVars.red.g = g
                                      ET.SavedVars.red.b = b
                                      ET.SavedVars.red.a = a
                                      ET.RefreshAll() end,
          width = "full",
          default = { r = ET.Defaults.red.r, g = ET.Defaults.red.g, b = ET.Defaults.red.b, a = ET.Defaults.red.a}
        },
        {
          type = "colorpicker",
          name = GetString(ENDEAVOR_TRACKER_SettingsColorNotStartedList),
          getFunc = function() return ET.SavedVars.white.r, ET.SavedVars.white.g, ET.SavedVars.white.b, ET.SavedVars.white.a end,
          setFunc = function(r,g,b,a) ET.SavedVars.white.r = r
                                      ET.SavedVars.white.g = g
                                      ET.SavedVars.white.b = b
                                      ET.SavedVars.white.a = a
                                      ET.RefreshAll() end,
          width = "full",
          default = { r = ET.Defaults.white.r, g = ET.Defaults.white.g, b = ET.Defaults.white.b, a = ET.Defaults.white.a}
        },
        {
          type = "checkbox",
          name = GetString(ENDEAVOR_TRACKER_SettingsPanelAnchor),
          tooltip = GetString(ENDEAVOR_TRACKER_SettingsPanelAnchorTooltip),
          getFunc = function() return ET.SavedVars.anchorPanelSetting end,
          setFunc = function(setting) ET.SavedVars.anchorPanelSetting = setting
                                      ET.RestorePanelPosition() end,
        },
      },
    },
    {
      type = "header",
      name = GetString(ENDEAVOR_TRACKER_SettingsHeaderChatOptions),
      width = "full",
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsPostProgressUpdates),
      getFunc = function() return ET.SavedVars.progressUpdatesEnabled end,
      setFunc = function(setting) ET.SavedVars.progressUpdatesEnabled = setting end,
    },
    {
      type = "checkbox",
      name = GetString(ENDEAVOR_TRACKER_SettingsPostCompletionMessage),
      getFunc = function() return ET.SavedVars.completionMessageEnabled end,
      setFunc = function(setting) ET.SavedVars.completionMessageEnabled = setting end,
    }
  }

  LAM:RegisterOptionControls("EndeavorTrackerSettings", optionsData)
end
