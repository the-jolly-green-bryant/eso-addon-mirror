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
    if not duel then
        return
    end
    self:CreateUI()
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
    -- Detail selection only chooses content. It deliberately reuses the
    -- journal scene that was initialized during addon startup.
    self:OpenJournal()
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

local function SetCombatSourceRowColor(row, color)
    for _, label in ipairs({
        row.name,
        row.percent,
        row.dps,
        row.damage,
        row.critHits,
        row.critPercent,
        row.min,
        row.avg,
        row.max,
    }) do
        label:SetColor(color[1], color[2], color[3], color[4])
    end
end

local function SetCombatSourceRowHidden(row, hidden)
    for _, control in ipairs({
        row.icon,
        row.name,
        row.percent,
        row.dps,
        row.damage,
        row.critHits,
        row.critPercent,
        row.min,
        row.avg,
        row.max,
    }) do
        control:SetHidden(hidden)
    end
end

function Dueling:SetCombatBreakdownScroll(board, requestedOffset)
    if not board then
        return
    end

    local sources = type(board.sources) == "table" and board.sources or {}
    local visibleRows = board.visibleRowCount or #board.rows
    local maxOffset = math.max(0, #sources - visibleRows)
    board.scrollOffset = math.max(0, math.min(math.floor(tonumber(requestedOffset) or 0), maxOffset))

    local total = tonumber(board.total) or 0
    local duration = tonumber(board.duration) or 0
    local topColors = {
        { 1.00, 0.84, 0.24, 1 },
        { 0.38, 0.88, 0.50, 1 },
        { 0.46, 0.82, 1.00, 1 },
    }
    local neutral = { 0.84, 0.88, 0.94, 1 }
    local incomingTop = { 1, 0.56, 0.52, 1 }
    local sourceCharacters = math.max(14, math.floor((board.abilityTextWidth or 220) / 7.3))

    for visibleIndex, row in ipairs(board.rows) do
        local sourceIndex = visibleIndex + board.scrollOffset
        local source = sources[sourceIndex]
        local sourceTotal = source and tonumber(source.total) or 0
        if source and sourceTotal > 0 then
            local rankColor = sourceIndex <= 3
                and (board.isOutgoing and topColors[sourceIndex] or incomingTop)
                or neutral
            local hitCount = tonumber(source.hitCount)
            local hasHitData = hitCount ~= nil
            hitCount = hasHitData and math.max(0, math.floor(hitCount + 0.5)) or nil
            local critCount = hasHitData and math.max(0, math.floor((tonumber(source.critCount) or 0) + 0.5)) or nil
            local minHit = hasHitData and tonumber(source.minHit) or nil
            local maxHit = hasHitData and tonumber(source.maxHit) or nil
            local abilityIcon = nil
            if source.abilityId and type(GetAbilityIcon) == "function" then
                abilityIcon = GetAbilityIcon(source.abilityId)
            end

            row.icon:SetTexture(abilityIcon or "")
            row.icon:SetHidden(not abilityIcon or abilityIcon == "")
            row.name:SetText(TruncateCombatSourceName(source.name, sourceCharacters))
            row.percent:SetText(total > 0 and string.format("%.1f%%", sourceTotal / total * 100) or "0%")
            row.dps:SetText(FormatCombatRate(sourceTotal, duration))
            row.damage:SetText(FormatCombatNumber(sourceTotal))
            if hasHitData then
                row.critHits:SetText(string.format("%d/%d", critCount, hitCount))
                row.critPercent:SetText(hitCount > 0 and string.format("%.1f%%", critCount / hitCount * 100) or "0%")
                row.min:SetText(minHit and minHit > 0 and FormatCombatNumber(minHit) or "N/A")
                row.avg:SetText(hitCount > 0 and FormatCombatNumber(sourceTotal / hitCount) or "N/A")
                row.max:SetText(maxHit and maxHit > 0 and FormatCombatNumber(maxHit) or "N/A")
            else
                row.critHits:SetText("N/A")
                row.critPercent:SetText("N/A")
                row.min:SetText("N/A")
                row.avg:SetText("N/A")
                row.max:SetText("N/A")
            end
            SetCombatSourceRowColor(row, rankColor)
            SetCombatSourceRowHidden(row, false)
            row.icon:SetHidden(not abilityIcon or abilityIcon == "")
        else
            SetCombatSourceRowHidden(row, true)
        end
    end

    board.empty:SetHidden(#sources > 0 and total > 0)
    local showScroll = maxOffset > 0
    board.scrollTrack:SetHidden(not showScroll)
    board.scrollThumb:SetHidden(not showScroll)
    if showScroll then
        local trackHeight = math.max(1, board.scrollTrack:GetHeight())
        local thumbHeight = math.max(18, math.floor(trackHeight * visibleRows / #sources))
        local travel = math.max(0, trackHeight - thumbHeight)
        board.scrollThumb:ClearAnchors()
        board.scrollThumb:SetAnchor(TOP, board.scrollTrack, TOP, 0, math.floor(travel * board.scrollOffset / maxOffset + 0.5))
        board.scrollThumb:SetDimensions(4, thumbHeight)
    end
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
    local Analytics = PvPerformance.Modules.Analytics
    local analyticsAvailable = Analytics and Analytics.GetAnalyticsForDuel
        and Analytics:GetAnalyticsForDuel(duel) ~= nil
    if self.ui.duelDetailAnalyticsButton then
        self.ui.duelDetailAnalyticsButton:SetEdgeColor(
            analyticsAvailable and 0.44 or 0.48,
            analyticsAvailable and 0.78 or 0.52,
            analyticsAvailable and 1.00 or 0.58,
            1
        )
        self.ui.duelDetailAnalyticsButton.label:SetColor(
            analyticsAvailable and 0.84 or 0.58,
            analyticsAvailable and 0.88 or 0.62,
            analyticsAvailable and 0.94 or 0.68,
            1
        )
    end

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
        card.leftValue:SetText(FormatCombatNumber(total))
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
        card.value:SetText(FormatCombatNumber(shieldAbsorbed))
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
        board.sources = type(sources) == "table" and sources or {}
        board.total = tonumber(total) or 0
        board.duration = duration
        board.isOutgoing = isOutgoing == true
        self:SetCombatBreakdownScroll(board, board.scrollOffset or 0)
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
        local selected = buttonMode == mode
        button:SetColor(selected and 0.44 or 0.70, selected and 0.78 or 0.77, selected and 1 or 0.85, 1)
        if button.tabBorder then
            button.tabBorder:SetCenterColor(
                selected and 0.44 or 0,
                selected and 0.78 or 0,
                selected and 1.00 or 0,
                selected and 0.18 or 0
            )
            button.tabBorder:SetEdgeColor(
                selected and 0.44 or 0.48,
                selected and 0.78 or 0.52,
                selected and 1.00 or 0.58,
                1
            )
        end
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

