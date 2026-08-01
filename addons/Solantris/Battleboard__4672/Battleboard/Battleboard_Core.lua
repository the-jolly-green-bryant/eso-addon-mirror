-- Battleboard_Core.lua  (Core: namespace, state, and saved-variable normalization)
-- Part of Battleboard. Cross-file constants and helpers are read from Battleboard.__constants.

Battleboard = Battleboard or {}
local BL = Battleboard
BL.__constants = BL.__constants or {}

BL.name = "Battleboard"
BL.displayName = "BATTLEBOARD"
BL.savedVarsName = "BattleboardSavedVariables"
BL.version = 1
BL.schemaVersion = 2
BL.matches = {}
BL.rows = {}
BL.historyRows = {}
BL.rowDataCache = {}
BL.detailCache = {}
BL.selectedMatchId = nil
BL.selectedPlayerRowKey = nil
BL.lastCapturedSignature = nil
BL.autoSaveBattlegroundPending = false
BL.autoSaveBattlegroundFinishedHandled = false
BL.menuCategory = nil
BL.historyRefreshId = 0
BL.detailRefreshId = 0
BL.currentSort = nil
BL.historyFilter = "All"
BL.matchTypeFilter = "All"
BL.historyLockedFilter = false     -- false = not active; toggled by button
BL.historyMvpFilter = false        -- false = not active; toggled by sweetroll button
BL.historySearchFilter = ""        -- empty = no search filter
BL.teamSizeFilter = "All"
BL.dateRangeFilter = "All"
BL.performanceMetric = "kills"
BL.performanceAggregateMode = "Averages"
BL.observatoryEncounterAggregateMode = "Averages"
BL.observatoryClassSpreadMode = "Popularity"
BL.deserterTimerCacheSeconds = 0
BL.deserterCooldownLastSeen = 0
BL.matchTypeButtons = {}
BL.activePage = "History"
BL.selectedCharacterKey = nil
BL.historyListBuilt = false
BL.historyNeedsRebuild = true
BL.characterDropdown = nil
BL.characterDropdownCombo = nil
BL.menuCategoryData = nil
BL.menuSceneData = nil
BL.resetHistoryOnNextOpen = true

local function Num(value)
    return tonumber(value) or 0
end

-- ===========================================================================
-- Saved-variable normalization.
-- ===========================================================================

function BL.NormalizeSavedVariables(defaults)
    if type(BL.vars) ~= "table" then
        BL.vars = {}
    end

    if type(BL.vars.matches) ~= "table" then
        BL.vars.matches = {}
    end
    if type(BL.vars.characters) ~= "table" then
        BL.vars.characters = {}
    end
    if type(BL.vars.deserterEvents) ~= "table" then
        BL.vars.deserterEvents = {}
    end

    BL.vars.maxMatchesSaved = Num(BL.vars.maxMatchesSaved) > 0 and BL.vars.maxMatchesSaved or defaults.maxMatchesSaved
    if BL.vars.maxMatchesSaved < 1000 then BL.vars.maxMatchesSaved = 1000 end
    if BL.vars.maxMatchesSaved > 10000 then BL.vars.maxMatchesSaved = 10000 end
    BL.vars.maxMatchesSaved = math.floor((BL.vars.maxMatchesSaved + 500) / 1000) * 1000

    if BL.vars.replaceScoreboard == nil then
        BL.vars.replaceScoreboard = defaults.replaceScoreboard
    else
        -- Keep this as a real boolean. Treat only literal true as enabled.
        -- This prevents stale SavedVariables such as "false" from being coerced to true.
        BL.vars.replaceScoreboard = BL.vars.replaceScoreboard == true
    end
    if BL.vars.showEndMatchScoreboard == nil then
        BL.vars.showEndMatchScoreboard = defaults.showEndMatchScoreboard
    else
        BL.vars.showEndMatchScoreboard = BL.vars.showEndMatchScoreboard == true
    end
    if BL.vars.autoShowHistorySweetroll == nil then
        BL.vars.autoShowHistorySweetroll = defaults.autoShowHistorySweetroll
    else
        BL.vars.autoShowHistorySweetroll = BL.vars.autoShowHistorySweetroll == true
    end
    if BL.vars.autoShowEndMatchSweetroll == nil then
        BL.vars.autoShowEndMatchSweetroll = defaults.autoShowEndMatchSweetroll
    else
        BL.vars.autoShowEndMatchSweetroll = BL.vars.autoShowEndMatchSweetroll == true
    end

    BL.vars.defaultScene = BL.GetDefaultBattleboardSceneName()
    BL.vars.debugPanel = BL.vars.debugPanel == true
    BL.vars.schemaVersion = BL.schemaVersion
end
