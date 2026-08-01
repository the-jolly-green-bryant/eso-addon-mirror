ET = {}

ET.name = "EndeavorTracker"
ET.author = "Lari"
ET.addonVersion = "2.3.1"

ET.SavedVars = {}

ET.DisplaySettings = {
  [1] = GetString(ENDEAVOR_TRACKER_DefaultsDisplaySettings1),
  [2] = GetString(ENDEAVOR_TRACKER_DefaultsDisplaySettings2),
  [3] = GetString(ENDEAVOR_TRACKER_DefaultsDisplaySettings3),
  [4] = GetString(ENDEAVOR_TRACKER_DefaultsDisplaySettings4),
  [5] = GetString(ENDEAVOR_TRACKER_DefaultsDisplaySettings5),
}

ET.Defaults = {
  buttonLeft = nil,
  buttonTop = nil,
  panelLeft = nil,
  panelTop = nil,
  panelBottom = nil,
  isBackdropVisible = true,
  backdropAlpha = 1,
  isShortcutButtonVisible = true,
  areDailiesCollapsed = false,
  areWeekliesCollapsed = false,
  progressUpdatesEnabled = true,
  completionMessageEnabled = true,
  displayInCombat = false,
  displayInDungeons = true,
  displayInCyroAndBGs = true,
  displayCheckboxes = true,
  displayTimeRemaining = true,
  collapseCompletedEndeavors = true,
  displayPanelSetting = ET.DisplaySettings[2],
  anchorPanelSetting = false,
  fontSize = 16,
  red    = { r = 0.8, g = 0.2, b = 0.2, a = 1 },
  green  = { r = 0.2, g = 0.65, b = 0.2, a = 1 },
  orange = { r = 0.9, g = 0.7, b = 0.08, a = 1 },
  white  = { r = 1, g = 1, b = 1, a = 1 },
  checkedEntries = {},
  History = {
    Daily = {
      IdList = {},
      Repeats = {},
      Log = {},
      Stats = {
        TotalCompleted = 0,
        TotalSeals = 0,
        MaxSeals = 0,
        MinSeals = 100000,
        TotalGold = 0,
      },
    },
    Weekly = {
      IdList = {},
      Repeats = {},
      Log = {},
      Stats = {
        TotalCompleted = 0,
        TotalSeals = 0,
        MaxSeals = 0,
        MinSeals = 100000,
        TotalGold = 0,
      },
    },
    TotalLifetimeSeals = 0,
    LifetimeSealsInitialized = false,
    LifetimeSealsInitDate = nil,
  },
}
