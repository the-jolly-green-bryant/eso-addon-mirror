local PvPerformance = PvPerformance
local Analytics = PvPerformance.Modules.Analytics
local Dueling = PvPerformance.Modules.Dueling

Analytics.CATEGORIES = {
    damageDone = { label = "DAMAGE DONE", rateLabel = "DPS", duelRateLabel = "DUEL DPS" },
    damageTaken = { label = "DAMAGE TAKEN", rateLabel = "INCOMING DPS", duelRateLabel = "DUEL DPS" },
    healingDone = { label = "HEALING DONE", rateLabel = "HPS", duelRateLabel = "DUEL HPS" },
    healingReceived = { label = "HEALING RECEIVED", rateLabel = "INCOMING HPS", duelRateLabel = "DUEL HPS" },
}

Analytics.SUB_TABS = {
    { key = "damageDone", label = "DAMAGE DONE" },
    { key = "damageTaken", label = "DAMAGE TAKEN" },
    { key = "healingDone", label = "HEALING DONE" },
    { key = "healingReceived", label = "HEALING RECEIVED" },
}

Analytics.LOG_FILTER_DEFINITIONS = {
    { key = "all", label = "ALL" },
    { key = "damageDone", label = "DAMAGE DONE" },
    { key = "damageTaken", label = "DAMAGE TAKEN" },
    { key = "healingDone", label = "HEALING DONE" },
    { key = "healingReceived", label = "HEALING RECEIVED" },
    { key = "incomingBuff", label = "INCOMING BUFF" },
    { key = "outgoingBuff", label = "OUTGOING BUFF" },
    { key = "incomingDebuff", label = "INCOMING DEBUFF" },
    { key = "outgoingDebuff", label = "OUTGOING DEBUFF" },
    { key = "resourceEvent", label = "RESOURCE" },
    { key = "usedSkill", label = "USED SKILL" },
    { key = "statsChange", label = "STAT CHANGE" },
    { key = "infoEvent", label = "INFO" },
    { key = "performanceInfo", label = "PERFORMANCE" },
}

local function NewDefaultLogFilters()
    local filters = {}
    for _, definition in ipairs(Analytics.LOG_FILTER_DEFINITIONS) do
        if definition.key ~= "all" then
            filters[definition.key] = true
        end
    end
    return filters
end

local function VisitDuelHistory(savedVars, callback)
    if type(savedVars) ~= "table" or type(callback) ~= "function" then
        return
    end
    for _, season in pairs(savedVars.seasons or {}) do
        for _, duel in ipairs(type(season) == "table" and season.history or {}) do
            callback(duel)
        end
    end
    -- Retain a defensive root-history pass for an interrupted legacy season
    -- migration. The current schema normally stores history inside seasons.
    for _, duel in ipairs(savedVars.history or {}) do
        callback(duel)
    end
end

function Analytics:InitializeRetention()
    -- Full Analytics reports are session-only unless the user explicitly
    -- saves them. Clear older automatically-persisted reports on load while
    -- leaving Dueling history, ratings, and compact duel summaries intact.
    VisitDuelHistory(self.savedVars, function(duel)
        if type(duel) == "table" and duel.analyticsSaved ~= true then
            duel.analytics = nil
            duel.analyticsSaved = nil
        end
    end)
    self.sessionAnalyticsByDuelId = {}
end

function Analytics:GetAnalyticsForDuel(duel)
    if type(duel) ~= "table" then
        return nil
    end
    local duelId = duel.id and tostring(duel.id) or nil
    return (duelId and self.sessionAnalyticsByDuelId and self.sessionAnalyticsByDuelId[duelId])
        or (duel.analyticsSaved == true and duel.analytics or nil)
end

function Analytics:RegisterCompletedDuel(duel, summary)
    if type(duel) ~= "table" or type(summary) ~= "table" or duel.id == nil then
        return false
    end
    self.sessionAnalyticsByDuelId = self.sessionAnalyticsByDuelId or {}
    self.sessionAnalyticsByDuelId[tostring(duel.id)] = summary
    return true
end

function Analytics:SaveSelectedDuel()
    local duel = self:GetSelectedDuel()
    local summary = self:GetAnalyticsForDuel(duel)
    if not duel or not summary then
        PvPerformance.Utilities.Print("No Analytics duel is available to save.")
        return false
    end
    duel.analytics = summary
    duel.analyticsSaved = true
    PvPerformance.Utilities.Print(string.format(
        "|cFFF24ASaved Analytics duel:|r %s, %s",
        duel.opponent and duel.opponent.displayName or "Unknown @name",
        PvPerformance.Utilities.FormatDuelTime(duel)
    ))
    self:RefreshUI()
    return true
end

function Analytics:DeleteSelectedDuel()
    local duel = self:GetSelectedDuel()
    if not duel then
        PvPerformance.Utilities.Print("No Analytics duel is available to delete.")
        return false
    end
    local duelId = duel.id and tostring(duel.id) or nil
    if duelId and self.sessionAnalyticsByDuelId then
        self.sessionAnalyticsByDuelId[duelId] = nil
    end
    duel.analytics = nil
    duel.analyticsSaved = nil
    self.selectedHistoryIndex = nil
    self.selectedSkillFilter = nil
    PvPerformance.Utilities.Print(string.format(
        "|cFF6F6FDeleted Analytics duel:|r %s, %s. Dueling result and rating were retained.",
        duel.opponent and duel.opponent.displayName or "Unknown @name",
        PvPerformance.Utilities.FormatDuelTime(duel)
    ))
    self:SelectLatestDuel()
    self:RefreshUI()
    return true
end

function Analytics:SafeCall(methodName, ...)
    local method = self[methodName]
    if type(method) ~= "function" then
        return nil
    end
    local ok, result = pcall(method, self, ...)
    if not ok then
        local tracking = Dueling.currentDuelTracking
        local runtime = tracking and tracking.analytics
        if not runtime or not runtime.warningPrinted then
            if runtime then
                runtime.warningPrinted = true
            end
            PvPerformance.Utilities.Print("Analytics encountered an error; normal duel tracking will continue.")
        end
        return nil
    end
    return result
end

function Analytics:Initialize()
    self.activeScope = "dueling"
    self.activeTab = self.CATEGORIES[self.activeTab] and self.activeTab or "damageDone"
    self.logFilters = NewDefaultLogFilters()
    self.selectedSkillFilter = nil
    self.selectedHistoryIndex = nil
    self.uptimeFilter = self.uptimeFilter or "all"
    self:InitializeRetention()
    self:CreateUI()
end

function Analytics:SetActiveScope(scopeName)
    if scopeName ~= "dueling" and scopeName ~= "fightStats" and scopeName ~= "help" then
        return
    end
    self.activeScope = scopeName
    self:RefreshUI()
end

function Analytics:GetHistory()
    local season = Dueling.GetViewedSeason and Dueling:GetViewedSeason()
    local sourceHistory = season and season.history or (self.savedVars and self.savedVars.history) or {}
    local analyticsHistory = {}
    for _, duel in ipairs(sourceHistory) do
        if self:GetAnalyticsForDuel(duel) then
            table.insert(analyticsHistory, duel)
        end
    end
    return analyticsHistory
end

function Analytics:SelectLatestDuel()
    local history = self:GetHistory()
    self.selectedHistoryIndex = #history > 0 and #history or nil
    self.selectedSkillFilter = nil
end

function Analytics:GetSelectedDuel()
    local history = self:GetHistory()
    local index = tonumber(self.selectedHistoryIndex)
    if not index or not history[index] then
        self:SelectLatestDuel()
        index = self.selectedHistoryIndex
    end
    return index and history[index] or nil, index, #history
end

function Analytics:StepDuel(direction)
    local history = self:GetHistory()
    if #history == 0 then
        self.selectedHistoryIndex = nil
    else
        local index = tonumber(self.selectedHistoryIndex) or #history
        self.selectedHistoryIndex = math.max(1, math.min(#history, index + (tonumber(direction) or 0)))
    end
    self.selectedSkillFilter = nil
    self:RefreshUI()
end

function Analytics:SelectHistoryIndex(index)
    local history = self:GetHistory()
    index = math.floor(tonumber(index) or 0)
    if index < 1 or not history[index] then
        return
    end
    self.selectedHistoryIndex = index
    self.selectedSkillFilter = nil
    self:RefreshUI()
end

-- Opens the Analytics report belonging to one exact Dueling journal record.
-- The object identity check handles the live session; the stable duel ID
-- keeps the shortcut working after a reload for explicitly saved reports.
function Analytics:OpenDuelFromJournal(duel)
    if type(duel) ~= "table" or not self:GetAnalyticsForDuel(duel) then
        PvPerformance.Utilities.Print("No Analytics report is available for this duel.")
        return false
    end
    local selectedIndex
    local duelId = duel.id and tostring(duel.id) or nil
    for index, candidate in ipairs(self:GetHistory()) do
        if candidate == duel
            or (duelId and candidate.id and tostring(candidate.id) == duelId) then
            selectedIndex = index
            break
        end
    end
    if not selectedIndex then
        PvPerformance.Utilities.Print("No Analytics report is available for this duel.")
        return false
    end
    self.selectedHistoryIndex = selectedIndex
    self.selectedSkillFilter = nil
    self.activeScope = "dueling"
    self.activeTab = "damageDone"
    PvPerformance.activeModule = "analytics"
    Dueling:OpenJournal()
    Dueling:RefreshUI()
    return true
end

function Analytics:FormatDuelSelectorText(duel)
    local opponent = duel and duel.opponent and duel.opponent.displayName or "Unknown @name"
    local className = duel and duel.opponent and PvPerformance.Utilities.ClassDisplayForDuel(duel.opponent)
        or "Unknown class"
    return string.format(
        "%s, %s, %s, %s",
        opponent,
        className,
        PvPerformance.Utilities.FormatDuelTime(duel),
        PvPerformance.Utilities.FormatDuration(duel and duel.durationSeconds)
    )
end

function Analytics:ShowOpponentSelectorMenu(control)
    local addMenuItem = AddCustomMenuItem or AddMenuItem
    if not control or not ClearMenu or not addMenuItem or not ShowMenu then
        return
    end
    local history = self:GetHistory()
    ClearMenu()
    if #history == 0 then
        addMenuItem("No recorded duels", function() end)
    else
        for index = #history, 1, -1 do
            local selectedIndex = index
            local prefix = selectedIndex == self.selectedHistoryIndex and "* " or ""
            addMenuItem(prefix .. self:FormatDuelSelectorText(history[selectedIndex]), function()
                self:SelectHistoryIndex(selectedIndex)
            end)
        end
    end
    ShowMenu(control)
end

function Analytics:SetActiveTab(tabName)
    for _, definition in ipairs(self.SUB_TABS) do
        if definition.key == tabName then
            if self.selectedSkillFilter
                and self.CATEGORIES[tabName]
                and self.selectedSkillFilter.category ~= tabName
            then
                self.selectedSkillFilter = nil
                self.logFilters = NewDefaultLogFilters()
                self.embeddedLogOffset = 0
            end
            self.activeTab = tabName
            self:RefreshUI()
            return
        end
    end
end

function Analytics:IsEveryLogFilterEnabled()
    for _, definition in ipairs(self.LOG_FILTER_DEFINITIONS) do
        if definition.key ~= "all" and not self.logFilters[definition.key] then
            return false
        end
    end
    return true
end

function Analytics:ToggleLogFilter(category)
    self.logFilters = self.logFilters or NewDefaultLogFilters()
    if category == "all" then
        local enable = not self:IsEveryLogFilterEnabled()
        for _, definition in ipairs(self.LOG_FILTER_DEFINITIONS) do
            if definition.key ~= "all" then
                self.logFilters[definition.key] = enable
            end
        end
    else
        local valid
        for _, definition in ipairs(self.LOG_FILTER_DEFINITIONS) do
            if definition.key == category then
                valid = true
                break
            end
        end
        if not valid then
            return
        end
        self.logFilters[category] = not self.logFilters[category]
    end
    self.logOffset = 0
    self:RefreshUI()
end

-- Compatibility helper for source-row drill-down: focus the chosen category,
-- while the normal combat-log buttons remain independent multi-select toggles.
function Analytics:SetLogFilter(category)
    if not self.CATEGORIES[category] then
        return
    end
    self.logFilters = {}
    self.logFilters[category] = true
    self.selectedSkillFilter = nil
    self.logOffset = 0
    self:RefreshUI()
end

function Analytics:SetUptimeFilter(filterName)
    local validFilters = {
        all = true,
        incomingBuff = true,
        outgoingBuff = true,
        incomingDebuff = true,
        outgoingDebuff = true,
    }
    if not validFilters[filterName] then
        return
    end
    self.uptimeFilter = filterName
    self.uptimeOffset = 0
    self:RefreshUI()
end

function Analytics:SelectSkillForCombatLog(category, source)
    if not self.CATEGORIES[category] or type(source) ~= "table" then
        return
    end
    local selected = self.selectedSkillFilter
    local sourceAbilityId = tonumber(source.abilityId)
    local sourceName = tostring(source.name or "Unknown effect")
    local isSameAbility = selected
        and selected.category == category
        and ((sourceAbilityId and sourceAbilityId > 0 and selected.abilityId == sourceAbilityId)
            or ((not sourceAbilityId or sourceAbilityId <= 0)
                and zo_strlower(tostring(selected.name or "")) == zo_strlower(sourceName)))
    if isSameAbility then
        self:ClearSkillFilter(false)
        return
    end
    self.logFilters = { [category] = true }
    self.selectedSkillFilter = {
        category = category,
        abilityId = sourceAbilityId,
        name = sourceName,
    }
    self.logOffset = 0
    self.embeddedLogOffset = 0
    -- Keep the selected damage/healing workspace open. Its upper-left panel
    -- now becomes the focused timestamp list, so users retain the target,
    -- uptime, and source context around the selected ability.
    self:RefreshUI()
end

function Analytics:ClearSkillFilter(resetEventFilters)
    self.selectedSkillFilter = nil
    -- Deselecting an ability preserves the user's event-category choices.
    -- The explicit CLEAR button requests the complete event view instead.
    if resetEventFilters then
        self.logFilters = NewDefaultLogFilters()
    end
    self.logOffset = 0
    self.embeddedLogOffset = 0
    self:RefreshUI()
end

function Analytics:SetVisible(visible)
    if self.ui and self.ui.panel then
        if self.SetDuelingContentHidden then
            self:SetDuelingContentHidden(visible)
        end
        self.ui.panel:SetHidden(not visible)
        self.ui.analyticsTab:SetColor(0.84, 0.88, 0.94, 1)
        if self.ui.analyticsTabBorder then
            self.ui.analyticsTabBorder:SetCenterColor(
                visible and 0.44 or 0,
                visible and 0.78 or 0,
                visible and 1.00 or 0,
                visible and 0.18 or 0
            )
            self.ui.analyticsTabBorder:SetEdgeColor(
                visible and 0.44 or 0.48,
                visible and 0.78 or 0.52,
                visible and 1.00 or 0.58,
                1
            )
        end
        self.ui.analyticsUnderline:SetHidden(true)
    end
end

function Analytics:SelectModule()
    PvPerformance.activeModule = "analytics"
    self:SelectLatestDuel()
    Dueling:OpenJournal()
    Dueling:RefreshUI()
end
