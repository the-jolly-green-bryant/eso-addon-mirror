local PvPerformance = PvPerformance
local Dueling = PvPerformance.Modules.Dueling
local Private = PvPerformance.Private
setfenv(1, setmetatable({
    PvPerformance = PvPerformance,
    Dueling = Dueling,
    Private = Private,
}, {
    __index = function(_, key)
        local value = Private[key]
        if value ~= nil then
            return value
        end
        return _G[key]
    end,
}))
function Dueling:CanOpenDuelSummaryFromCurrentView()
    if not self.ui then
        return false
    end
    if self.ui.activeTab == "recent" then
        return true
    end
    return (self.ui.activeTab == "opponents" or self.ui.activeTab == "classes")
        and self.ui.detailFilter ~= nil
        and self.ui.detailFilter.tab == self.ui.activeTab
end

function Dueling:SetMainContentMode(mode)
    if not self.ui then
        return
    end

    if mode ~= "dashboard" and mode ~= "opponentDetails" and mode ~= "combatSummary" then
        mode = "dashboard"
    end
    self.ui.mainContentMode = mode
end

function Dueling:OpenDuelSummary(duel, sourceContext)
    if not duel or not self.ui then
        return
    end
    sourceContext = sourceContext or {
        tab = self.ui.activeTab,
        detailFilter = self.ui.detailFilter,
        page = self.ui.page,
    }
    self.ui.duelSummarySource = {
        tab = sourceContext.tab or self.ui.activeTab,
        detailFilter = sourceContext.detailFilter,
        page = sourceContext.page or self.ui.page,
    }
    self.ui.selectedDuel = duel
    self:SetMainContentMode("combatSummary")
    self.ui.page = 1
    self:RefreshUI()
end

function Dueling:CloseDuelSummary()
    if not self.ui then
        return
    end
    local source = self.ui.duelSummarySource
    self.ui.selectedDuel = nil
    self.ui.duelSummarySource = nil
    if source then
        self.ui.activeTab = source.tab or self.ui.activeTab
        self.ui.detailFilter = source.detailFilter
        self:SetMainContentMode(self.ui.detailFilter and "opponentDetails" or "dashboard")
        self.ui.page = source.page or 1
    else
        self:SetMainContentMode("dashboard")
        self.ui.page = 1
    end
    self:RefreshUI()
end

function Dueling:RefreshDuelSummary()
    local duel = self.ui and self.ui.selectedDuel
    if not duel then
        return
    end

    -- New PvP-erformance records use one compact combatSummary table as the
    -- canonical detailed-combat schema. The reportedHealing fallback keeps
    -- the first refactor build's already-saved records readable.
    local summary = duel.combatSummary
    local duration = tonumber(duel.durationSeconds)
    local resultText = duel.drawn and "DRAW" or (duel.won and "WIN" or "LOSS")
    local subtitle = string.format(
        "%s vs %s  |  %s  |  %s  |  %s",
        resultText,
        duel.opponent and duel.opponent.displayName or "Unknown @name",
        FormatDuelTime(duel),
        FormatDuration(duration),
        duel.opponent and ClassDisplayForDuel(duel.opponent) or "Unknown class"
    )
    self.ui.duelDetailTitle:SetText("DUEL SUMMARY")
    self.ui.duelDetailSubtitle:SetText(subtitle)

    local function SetDualMetric(card, total, rate, unavailableText)
        if total == nil then
            card.leftValue:SetText("N/A")
            card.rightValue:SetText("N/A")
            card.leftValue:SetColor(0.70, 0.77, 0.85, 1)
            card.rightValue:SetColor(0.70, 0.77, 0.85, 1)
            card.note:SetText(unavailableText or "Not available")
            card.note:SetHidden(false)
            return
        end
        card.leftValue:SetText(FormatDamage(total))
        card.rightValue:SetText(rate)
        card.leftValue:SetColor(0.88, 0.90, 0.94, 1)
        card.rightValue:SetColor(0.88, 0.90, 0.94, 1)
        card.note:SetText(unavailableText or "")
        card.note:SetHidden(unavailableText == nil)
    end

    local function SetShieldMetric(card, shieldAbsorbed)
        if shieldAbsorbed == nil then
            card.value:SetText("N/A")
            card.value:SetColor(0.70, 0.77, 0.85, 1)
            card.note:SetText("Shield value unavailable")
            card.note:SetHidden(false)
            return
        end
        card.value:SetText(FormatDamage(shieldAbsorbed))
        card.value:SetColor(0.88, 0.90, 0.94, 1)
        card.note:SetHidden(true)
    end

    if not summary then
        self.ui.duelDetailNotice:SetHidden(false)
        self.ui.duelDetailNotice:SetText("Detailed combat summary unavailable for this duel.")
        SetDualMetric(self.ui.duelDetailTotals.damageDone, nil, nil)
        SetDualMetric(self.ui.duelDetailTotals.damageTaken, nil, nil)
        SetDualMetric(self.ui.duelDetailTotals.healing, nil, nil)
        SetShieldMetric(self.ui.duelDetailTotals.shield, nil)
    else
        self.ui.duelDetailNotice:SetHidden(true)
        SetDualMetric(self.ui.duelDetailTotals.damageDone, summary.damageDone, FormatCombatRate(summary.damageDone, duration))
        SetDualMetric(self.ui.duelDetailTotals.damageTaken, summary.damageTaken, FormatCombatRate(summary.damageTaken, duration))
        -- ESO reports healing events but does not expose a dependable
        -- effective-healing/overheal split. The UI names this explicitly.
        local healingDone = summary.healingDone
        if healingDone == nil then
            healingDone = summary.reportedHealing
        end
        SetDualMetric(self.ui.duelDetailTotals.healing, healingDone, FormatCombatRate(healingDone, duration), "API-reported healing")
        SetShieldMetric(self.ui.duelDetailTotals.shield, summary.shieldAbsorbed)
    end

    local function PopulateBreakdown(board, sources, total, isOutgoing)
        sources = type(sources) == "table" and sources or {}
        total = tonumber(total) or 0
        local sourceCharacters = math.max(13, math.floor((board.sourceWidth or 150) / 7.2))
        for index, row in ipairs(board.rows) do
            local source = sources[index]
            if source and tonumber(source.total) and source.total > 0 and total > 0 then
                local topColors = {
                    { 1.00, 0.84, 0.24, 1 },
                    { 0.38, 0.88, 0.50, 1 },
                    { 0.46, 0.82, 1.00, 1 },
                }
                local color = (index <= 3 and (isOutgoing and topColors[index] or { 1, 0.56, 0.52, 1 }))
                    or { 0.84, 0.88, 0.94, 1 }
                row.name:SetText(TruncateCombatSourceName(source.name, sourceCharacters))
                row.percent:SetText(string.format("%.1f%%", source.total / total * 100))
                row.dps:SetText(FormatCombatRate(source.total, duration))
                row.name:SetColor(color[1], color[2], color[3], color[4])
                row.percent:SetColor(color[1], color[2], color[3], color[4])
                row.dps:SetColor(color[1], color[2], color[3], color[4])
                row.name:SetHidden(false)
                row.percent:SetHidden(false)
                row.dps:SetHidden(false)
            else
                row.name:SetHidden(true)
                row.percent:SetHidden(true)
                row.dps:SetHidden(true)
            end
        end
        board.empty:SetHidden(#sources > 0 and total > 0)
    end

    PopulateBreakdown(
        self.ui.duelDetailDamageDoneBoard,
        summary and summary.topDamageDone,
        summary and summary.damageDone,
        true
    )
    PopulateBreakdown(
        self.ui.duelDetailDamageTakenBoard,
        summary and summary.topDamageTaken,
        summary and summary.damageTaken,
        false
    )
end

function Dueling:GetStatisticsTrendValues(mode)
    local values = {}
    local rating = STARTING_RATING
    local decisiveResults = {}
    local decisiveWins = 0
    local viewedSeason = self:GetViewedSeason()
    for _, duel in ipairs(viewedSeason and viewedSeason.history or {}) do
        if mode == "rating" then
            rating = rating + (tonumber(duel.overallRatingChange) or 0)
            table.insert(values, rating)
        elseif not duel.drawn then
            local wasWin = duel.won == true
            table.insert(decisiveResults, wasWin)
            if wasWin then
                decisiveWins = decisiveWins + 1
            end
            if #decisiveResults > GRAPH_ROLLING_WINDOW then
                if decisiveResults[1] then
                    decisiveWins = decisiveWins - 1
                end
                table.remove(decisiveResults, 1)
            end
            table.insert(values, decisiveWins / #decisiveResults * 100)
        elseif #decisiveResults > 0 then
            table.insert(values, decisiveWins / #decisiveResults * 100)
        end
    end
    return values
end

function Dueling:RefreshStatisticsTrend()
    local mode = self.ui.statisticsTrendMode or "rating"
    local isRating = mode == "rating"
    local formatter
    if isRating then
        formatter = function(value)
            return FormatRating(value)
        end
    else
        formatter = function(value)
            return string.format("%.0f%%", value)
        end
    end
    for buttonMode, button in pairs(self.ui.statisticsTrendButtons) do
        button:SetColor(buttonMode == mode and 0.44 or 0.70, buttonMode == mode and 0.78 or 0.77, buttonMode == mode and 1 or 0.85, 1)
    end
    self.ui.statisticsTrendGraph.topValue:SetColor(
        isRating and 1 or 0.62,
        isRating and 0.82 or 0.70,
        isRating and 0.28 or 0.79,
        1
    )
    self.ui.statisticsTrendGraph.bottomValue:SetColor(
        isRating and 1 or 0.62,
        isRating and 0.82 or 0.70,
        isRating and 0.28 or 0.79,
        1
    )
    SetTrendGraphValues(
        self.ui.statisticsTrendGraph,
        isRating and "OVERALL RATING TREND" or "WIN RATE (LAST 10 DUELS)",
        self:GetStatisticsTrendValues(mode),
        isRating and { 1, 0.78, 0.26 } or { 0.44, 0.78, 1 },
        formatter
    )
end

