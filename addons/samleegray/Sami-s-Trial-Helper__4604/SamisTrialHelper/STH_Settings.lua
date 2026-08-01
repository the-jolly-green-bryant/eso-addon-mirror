local STH = SamisTrialHelperAddon
local LAM2 = LibAddonMenu2
local STHUtils = STH.utils

function STH.InitializeSettings()
  local panelData = {
    type = "panel",
    name = STH.displayName,
    displayName = STH.displayName,
    author = STH.styledAuthor,
    version = STH.version,
    website = "https://lethalrejection.com",
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local optionsPanel = LAM2:RegisterAddonPanel(STH.name .. "Options", panelData)

  local optionsData = {
    {
      type = "description",
      text = "Configure the settings for Sami's Trial Helper.",
    },
    {
      type = "checkbox",
      name = "Enable Debug",
      tooltip = "Toggle debug messages.",
      getFunc = function() return STH.settings.enableDebug end,
      setFunc = function(value) STH.settings.enableDebug = value end,
      default = false,
    },
    {
      type = "checkbox",
      name = "Clear On Zone Change",
      tooltip = "Automatically clear tracked uncollected items when you change zones.",
      getFunc = function() return STH.settings.clearOnZoneChange end,
      setFunc = function(value) STH.settings.clearOnZoneChange = value end,
      default = true,
    },
    {
      type = "checkbox",
      name = "Listen to Say Channel",
      tooltip = "Listen for item links in the say channel.",
      getFunc = function() return STH.settings.listenToSayChannel end,
      setFunc = function(value) STH.settings.listenToSayChannel = value end,
      default = false,
    },
    {
      type = "checkbox",
      name = "Listen to Group Channel",
      tooltip = "Listen for item links in the group channel.",
      getFunc = function() return STH.settings.listenToGroupChannel end,
      setFunc = function(value) STH.settings.listenToGroupChannel = value end,
      default = true,
    },
    {
      type = "checkbox",
      name = "Whisper Player",
      tooltip = "When enabled, whisper the player directly. When disabled, post in group chat.",
      getFunc = function() return STH.settings.whisperPlayer end,
      setFunc = function(value) STH.settings.whisperPlayer = value end,
      default = false,
    },
  }

  LAM2:RegisterOptionControls(STH.name .. "Options", optionsData)
end
