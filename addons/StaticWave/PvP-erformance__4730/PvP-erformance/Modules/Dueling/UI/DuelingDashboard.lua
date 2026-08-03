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
function Dueling:GetDuelingStatistics()
    local statistics = {
        longestWinStreak = 0,
        longestLossStreak = 0,
        averageDuration = nil,
        longestDuration = nil,
        longestDuelOpponent = nil,
        currentStreak = { kind = nil, count = 0 },
        mostPlayedOpponent = nil,
        bestClassMatchup = nil,
        worstClassMatchup = nil,
        lastTen = { wins = 0, losses = 0, draws = 0, total = 0 },
        dangerousOpponents = {},
        easiestOpponents = {},
    }
    local groupedOpponents = {}
    local groupedClasses = {}
    local currentWinStreak = 0
    local currentLossStreak = 0
    local durationTotal = 0
    local durationCount = 0

    local viewedSeason = self:GetViewedSeason()
    for _, duel in ipairs(viewedSeason and viewedSeason.history or {}) do
        if duel.won then
            currentWinStreak = currentWinStreak + 1
            currentLossStreak = 0
            statistics.longestWinStreak = math.max(statistics.longestWinStreak, currentWinStreak)
        elseif duel.drawn then
            -- A draw ends either kind of streak without counting as a loss.
            currentWinStreak = 0
            currentLossStreak = 0
        else
            currentLossStreak = currentLossStreak + 1
            currentWinStreak = 0
            statistics.longestLossStreak = math.max(statistics.longestLossStreak, currentLossStreak)
        end

        if duel.durationSeconds and duel.durationSeconds >= 0 then
            durationTotal = durationTotal + duel.durationSeconds
            durationCount = durationCount + 1
            if not statistics.longestDuration or duel.durationSeconds > statistics.longestDuration then
                statistics.longestDuration = duel.durationSeconds
                statistics.longestDuelOpponent = duel.opponent and duel.opponent.displayName or "Unknown @name"
            end
        end

        local displayName = duel.opponent and duel.opponent.displayName or "Unknown @name"
        local key = zo_strlower(displayName)
        local opponent = groupedOpponents[key]
        if not opponent then
            opponent = {
                name = displayName,
                wins = 0,
                losses = 0,
                draws = 0,
                total = 0,
            }
            groupedOpponents[key] = opponent
        end
        AddToStats(opponent, duel)

        local className = ClassDisplayForDuel(duel.opponent)
        local classKey = zo_strlower(className)
        local classMatchup = groupedClasses[classKey]
        if not classMatchup then
            classMatchup = {
                name = className,
                wins = 0,
                losses = 0,
                draws = 0,
                total = 0,
            }
            groupedClasses[classKey] = classMatchup
        end
        AddToStats(classMatchup, duel)
    end

    if currentWinStreak > 0 then
        statistics.currentStreak = { kind = "win", count = currentWinStreak }
    elseif currentLossStreak > 0 then
        statistics.currentStreak = { kind = "loss", count = currentLossStreak }
    end

    local history = viewedSeason and viewedSeason.history or {}
    for index = math.max(1, #history - 9), #history do
        AddToStats(statistics.lastTen, history[index])
    end

    if durationCount > 0 then
        statistics.averageDuration = math.floor(durationTotal / durationCount + 0.5)
    end

    local opponents = {}
    for _, opponent in pairs(groupedOpponents) do
        table.insert(opponents, opponent)
    end

    local function CompareName(left, right)
        return zo_strlower(left.name) < zo_strlower(right.name)
    end

    local dangerous = {}
    local easiest = {}
    for _, opponent in ipairs(opponents) do
        -- These boards are result-specific: Hardest contains only opponents
        -- with an actual loss, while Easiest contains only opponents with an
        -- actual win. A draw-only or opposite-result opponent is excluded.
        if opponent.losses > 0 then
            table.insert(dangerous, opponent)
        end
        if opponent.wins > 0 then
            table.insert(easiest, opponent)
        end
    end
    table.sort(dangerous, function(left, right)
        local leftRate = SmoothedWinRate(left)
        local rightRate = SmoothedWinRate(right)
        if leftRate ~= rightRate then
            return leftRate < rightRate
        elseif left.total ~= right.total then
            return left.total > right.total
        end
        return CompareName(left, right)
    end)
    table.sort(easiest, function(left, right)
        local leftRate = SmoothedWinRate(left)
        local rightRate = SmoothedWinRate(right)
        if leftRate ~= rightRate then
            return leftRate > rightRate
        elseif left.total ~= right.total then
            return left.total > right.total
        end
        return CompareName(left, right)
    end)

    local mostPlayed = {}
    for _, opponent in ipairs(opponents) do
        table.insert(mostPlayed, opponent)
    end
    table.sort(mostPlayed, function(left, right)
        if left.total ~= right.total then
            return left.total > right.total
        elseif left.wins ~= right.wins then
            return left.wins > right.wins
        end
        return CompareName(left, right)
    end)
    statistics.mostPlayedOpponent = mostPlayed[1]

    local classMatchups = {}
    for _, matchup in pairs(groupedClasses) do
        table.insert(classMatchups, matchup)
    end
    local bestMatchups = {}
    local worstMatchups = {}
    for _, matchup in ipairs(classMatchups) do
        if matchup.wins > 0 then
            table.insert(bestMatchups, matchup)
        end
        if matchup.losses > 0 then
            table.insert(worstMatchups, matchup)
        end
    end
    table.sort(bestMatchups, function(left, right)
        if left.wins ~= right.wins then
            return left.wins > right.wins
        elseif left.total ~= right.total then
            return left.total > right.total
        end
        return CompareName(left, right)
    end)
    table.sort(worstMatchups, function(left, right)
        if left.losses ~= right.losses then
            return left.losses > right.losses
        elseif left.total ~= right.total then
            return left.total > right.total
        end
        return CompareName(left, right)
    end)
    statistics.bestClassMatchup = bestMatchups[1]
    statistics.worstClassMatchup = worstMatchups[1]

    for index = 1, math.min(5, #dangerous) do
        statistics.dangerousOpponents[index] = dangerous[index]
    end
    for index = 1, math.min(5, #easiest) do
        statistics.easiestOpponents[index] = easiest[index]
    end

    return statistics
end

function Dueling:RefreshStatistics()
    local statistics = self:GetDuelingStatistics()
    local cards = self.ui.statMetricCards
    cards[1].value:SetText(string.format("%d", statistics.longestWinStreak))
    cards[1].detail:SetText("Draws end a streak")
    cards[2].value:SetText(string.format("%d", statistics.longestLossStreak))
    cards[2].detail:SetText("Draws end a streak")
    if statistics.currentStreak.kind == "win" then
        cards[3].value:SetText(string.format("%d win%s", statistics.currentStreak.count, statistics.currentStreak.count == 1 and "" or "s"))
        cards[3].detail:SetText("Active streak")
    elseif statistics.currentStreak.kind == "loss" then
        cards[3].value:SetText(string.format("%d loss%s", statistics.currentStreak.count, statistics.currentStreak.count == 1 and "" or "es"))
        cards[3].detail:SetText("Active streak")
    else
        cards[3].value:SetText("No streak")
        cards[3].detail:SetText("Draws end a streak")
    end
    cards[4].value:SetText(statistics.averageDuration and FormatDuration(statistics.averageDuration) or "N/A")
    cards[4].detail:SetText(statistics.averageDuration and "Recorded duel average" or "No duration data yet")
    cards[5].value:SetText(statistics.longestDuration and FormatDuration(statistics.longestDuration) or "N/A")
    cards[5].detail:SetText(statistics.longestDuelOpponent and string.format("vs %s", statistics.longestDuelOpponent) or "No duration data yet")

    local detailCards = self.ui.statDetailCards
    local function SetEntryCard(card, entry, emptyText)
        if entry then
            card.value:SetText(entry.name)
            card.value:SetScale(DisplayNameScale(entry.name))
            card.detail:SetText(CompactStatsText(entry))
        else
            card.value:SetText(emptyText)
            card.value:SetScale(1)
            card.detail:SetText("No recorded duels")
        end
    end
    SetEntryCard(detailCards[1], statistics.mostPlayedOpponent, "No opponent")
    SetEntryCard(detailCards[2], statistics.bestClassMatchup, "N/A")
    SetEntryCard(detailCards[3], statistics.worstClassMatchup, "N/A")
    if not statistics.bestClassMatchup then
        detailCards[2].detail:SetText("No wins recorded")
    end
    if not statistics.worstClassMatchup then
        detailCards[3].detail:SetText("No losses recorded")
    end
    if statistics.lastTen.wins + statistics.lastTen.losses > 0 then
        local lastTenRate = WinRatePercent(statistics.lastTen)
        detailCards[4].value:SetText(string.format("%.1f%%", lastTenRate))
        detailCards[4].value:SetScale(1)
        detailCards[4].detail:SetText(string.format(
            "%dW-%dL-%dD  |  %d duel%s",
            statistics.lastTen.wins,
            statistics.lastTen.losses,
            statistics.lastTen.draws,
            statistics.lastTen.total,
            statistics.lastTen.total == 1 and "" or "s"
        ))
    else
        detailCards[4].value:SetText("N/A")
        detailCards[4].value:SetScale(1)
        detailCards[4].detail:SetText("No recorded duels")
    end

    local function PopulateBoard(board, opponents, emptyText)
        for index = 1, 5 do
            local opponent = opponents[index]
            if opponent then
                local maximumCharacters = math.max(14, (board.names[index].maximumCharacters or 28) - 3)
                board.names[index]:SetText(string.format(
                    "%d. %s",
                    index,
                    TruncateCombatSourceName(opponent.name, maximumCharacters)
                ))
                board.records[index]:SetText(RecordOnlyText(opponent))
                board.rates[index]:SetText(WinRateOnlyText(opponent))
            elseif index == 1 then
                board.names[index]:SetText(emptyText or "No opponents recorded")
                board.records[index]:SetText("")
                board.rates[index]:SetText("")
            else
                board.names[index]:SetText("")
                board.records[index]:SetText("")
                board.rates[index]:SetText("")
            end
        end
    end

    PopulateBoard(self.ui.dangerousBoard, statistics.dangerousOpponents, "N/A")
    PopulateBoard(self.ui.easiestBoard, statistics.easiestOpponents, "N/A")
    self:RefreshStatisticsTrend()
end

function Dueling:RefreshSettingsPanel()
    if not self.ui or not self.ui.settingsRows then
        return
    end

    local settings = self:GetSettings()
    local effectLabel = "NORMAL"
    for _, option in ipairs(EFFECT_INTENSITY_OPTIONS) do
        if math.abs(option.value - settings.effectIntensity) < 0.02 then
            effectLabel = option.label
            break
        end
    end

    self.ui.settingsRows[1].buttonText:SetText(effectLabel)
    self.ui.settingsRows[2].buttonText:SetText(settings.damageRatingEnabled and "ENABLED" or "DISABLED")
    self.ui.settingsRows[2].button:SetEdgeColor(
        settings.damageRatingEnabled and 0.35 or 1,
        settings.damageRatingEnabled and 0.84 or 0.42,
        settings.damageRatingEnabled and 0.45 or 0.40,
        1
    )
    self.ui.settingsRows[3].buttonText:SetText(settings.duelTrackingEnabled and "TRACKING ON" or "TRACKING OFF")
    self.ui.settingsRows[3].button:SetEdgeColor(
        settings.duelTrackingEnabled and 0.35 or 1,
        settings.duelTrackingEnabled and 0.84 or 0.42,
        settings.duelTrackingEnabled and 0.45 or 0.40,
        1
    )
    self.ui.settingsRows[4].buttonText:SetText("COPY SUMMARY")
end

function Dueling:RefreshUI()
    if not self.ui then
        return
    end

    local Analytics = PvPerformance.Modules.Analytics
    if PvPerformance.activeModule == "analytics" and Analytics and Analytics.RefreshUI then
        if self.ui.moduleTab then
            self.ui.moduleTab:SetColor(0.84, 0.88, 0.94, 1)
            if self.ui.moduleTabBorder then
                self.ui.moduleTabBorder:SetCenterColor(0, 0, 0, 0)
                self.ui.moduleTabBorder:SetEdgeColor(0.48, 0.52, 0.58, 1)
            end
            self.ui.moduleUnderline:SetHidden(true)
        end
        Analytics:SetVisible(true)
        Analytics:RefreshUI()
        return
    elseif Analytics and Analytics.SetVisible then
        Analytics:SetVisible(false)
    end

    self:RefreshRankingInfoGuide()
    local wins, losses, draws, total, winRate = self:GetSummary()
    local ratingState = self:GetRatingState()
    local selectedClassTierId = self:GetSelectedClassTierId()
    local classRatingState = self:GetClassRatingState(selectedClassTierId)
    self.ui.summary:SetText(string.format("%d", total))
    self.ui.uniqueOpponents:SetText(string.format("%d", self:GetUniqueOpponentCount()))
    self.ui.record:SetText(string.format("|c42FF63%d|r - |cFF4C4C%d|r - |cA8A8A8%d|r", wins, losses, draws))
    self.ui.winRate:SetText(string.format("%.1f%%", winRate))
    local winRateRank = RankForRating(winRate)
    self.ui.winRate:SetColor(winRateRank.color[1], winRateRank.color[2], winRateRank.color[3], 1)
    self.ui.winRateBox:SetEdgeColor(winRateRank.color[1], winRateRank.color[2], winRateRank.color[3], 1)
    self:SetTierCardGlow(self.ui.winRateEffectCard, winRateRank)
    local displayName = GetDisplayName() or "@Unknown"
    local playerHeaderText = string.format("Player: %s", displayName)
    self.ui.playerName:SetText(playerHeaderText)
    self.ui.playerName:SetScale(DisplayNameScale(playerHeaderText))
    local playerClassIcon = type(GetClassIcon) == "function" and GetClassIcon(GetUnitClassId("player")) or nil
    self.ui.headerClassIcon:SetHidden(not playerClassIcon)
    if playerClassIcon then
        self.ui.headerClassIcon:SetTexture(playerClassIcon)
    end
    self.ui.headerChampionPoints:SetText(string.format("CP %d", ChampionPointCount()))
    self.ui.classTierCaption:SetText("CLASS TIER")
    local classSelectorText = string.format("%s  v", classRatingState.className)
    self.ui.classTierSelectorText:SetText(classSelectorText)
    self.ui.classTierSelectorText:SetScale(string.len(classSelectorText) > 11 and 0.86 or 1.05)
    if classRatingState.placed then
        local classRank = RankForRating(classRatingState.rating)
        local classProgress, classProgressText = RatingProgressForRank(classRatingState.rating, classRank)
        if classRatingState.calibrating then
            classProgress = classRatingState.calibrationDecisiveCount / CALIBRATION_DECISIVE_DUELS_REQUIRED
            classProgressText = string.format("PROV %d / %d", classRatingState.calibrationDecisiveCount, CALIBRATION_DECISIVE_DUELS_REQUIRED)
        end
        self.ui.classTier:SetText(classRank.name)
        self.ui.classTier:SetScale(TIER_LABEL_SCALE)
        self.ui.classTier:SetColor(classRank.color[1], classRank.color[2], classRank.color[3], 1)
        self.ui.classTierBox:SetEdgeColor(classRank.color[1], classRank.color[2], classRank.color[3], 1)
        self.ui.classTierProgress:SetEdgeColor(classRank.color[1], classRank.color[2], classRank.color[3], 1)
        self.ui.classTierProgressFill:SetDimensions(math.floor(TIER_PROGRESS_FILL_WIDTH * classProgress + 0.5), TIER_PROGRESS_FILL_HEIGHT)
        self.ui.classTierProgressFill:SetCenterColor(classRank.color[1], classRank.color[2], classRank.color[3], 1)
        self.ui.classTierProgressLabel:SetText(classProgressText)
        self.ui.classTierProgressLabel:SetColor(1, 1, 1, 1)
        self.ui.classTierTooltipText = ClassTierTooltipText(classRank.name, classRatingState.className)
        self:SetTierCardGlow(self.ui.classTierCard, classRank)
    else
        local classProgress = classRatingState.placementDecisiveCount / PLACEMENT_DECISIVE_DUELS_REQUIRED
        self.ui.classTier:SetText(string.format("%d / %d", classRatingState.qualifyingOpponents, PLACEMENT_OPPONENTS_REQUIRED))
        self.ui.classTier:SetScale(1)
        self.ui.classTier:SetColor(0.44, 0.78, 1, 1)
        self.ui.classTierBox:SetEdgeColor(0.36, 0.74, 1, 1)
        self.ui.classTierProgress:SetEdgeColor(0.36, 0.74, 1, 1)
        self.ui.classTierProgressFill:SetDimensions(math.floor(TIER_PROGRESS_FILL_WIDTH * classProgress + 0.5), TIER_PROGRESS_FILL_HEIGHT)
        self.ui.classTierProgressFill:SetCenterColor(0.44, 0.78, 1, 1)
        self.ui.classTierProgressLabel:SetText(string.format("DEC %d / %d", classRatingState.placementDecisiveCount, PLACEMENT_DECISIVE_DUELS_REQUIRED))
        self.ui.classTierProgressLabel:SetColor(1, 1, 1, 1)
        self.ui.classTierTooltipText = nil
        self:SetTierCardGlow(self.ui.classTierCard, nil)
    end

    if ratingState.placed then
        local rank = RankForRating(ratingState.rating)
        local progress, progressText = RatingProgressForRank(ratingState.rating, rank)
        if ratingState.calibrating then
            progress = ratingState.calibrationDecisiveCount / CALIBRATION_DECISIVE_DUELS_REQUIRED
            progressText = string.format("PROV %d / %d", ratingState.calibrationDecisiveCount, CALIBRATION_DECISIVE_DUELS_REQUIRED)
        end
        self.ui.tierCaption:SetText("OVERALL TIER")
        self.ui.tier:SetScale(TIER_LABEL_SCALE)
        self.ui.tier:SetText(rank.name)
        self.ui.tier:SetColor(rank.color[1], rank.color[2], rank.color[3], 1)
        self.ui.tierBox:SetEdgeColor(rank.color[1], rank.color[2], rank.color[3], 1)
        self.ui.tierProgress:SetEdgeColor(rank.color[1], rank.color[2], rank.color[3], 1)
        self.ui.tierProgressFill:SetDimensions(math.floor(TIER_PROGRESS_FILL_WIDTH * progress + 0.5), TIER_PROGRESS_FILL_HEIGHT)
        self.ui.tierProgressFill:SetCenterColor(rank.color[1], rank.color[2], rank.color[3], 1)
        self.ui.tierProgressLabel:SetText(progressText)
        self.ui.tierProgressLabel:SetColor(1, 1, 1, 1)
        self.ui.tierTooltipText = OverallTierTooltipText(rank.name)
        self:SetTierCardGlow(self.ui.overallTierCard, rank)
    else
        local progress = ratingState.placementDecisiveCount / PLACEMENT_DECISIVE_DUELS_REQUIRED
        self.ui.tierCaption:SetText("OVERALL TIER")
        self.ui.tier:SetScale(1)
        self.ui.tier:SetText(string.format("%d / %d", ratingState.qualifyingOpponents, PLACEMENT_OPPONENTS_REQUIRED))
        self.ui.tier:SetColor(0.44, 0.78, 1, 1)
        self.ui.tierBox:SetEdgeColor(0.36, 0.74, 1, 1)
        self.ui.tierProgress:SetEdgeColor(0.36, 0.74, 1, 1)
        self.ui.tierProgressFill:SetDimensions(math.floor(TIER_PROGRESS_FILL_WIDTH * progress + 0.5), TIER_PROGRESS_FILL_HEIGHT)
        self.ui.tierProgressFill:SetCenterColor(0.44, 0.78, 1, 1)
        self.ui.tierProgressLabel:SetText(string.format("DEC %d / %d", ratingState.placementDecisiveCount, PLACEMENT_DECISIVE_DUELS_REQUIRED))
        self.ui.tierProgressLabel:SetColor(1, 1, 1, 1)
        self.ui.tierTooltipText = nil
        self:SetTierCardGlow(self.ui.overallTierCard, nil)
    end

    for tabName, tab in pairs(self.ui.tabs) do
        local selected = tabName == self.ui.activeTab
        tab:SetColor(selected and 0.44 or 0.70, selected and 0.78 or 0.77, selected and 1 or 0.85, 1)
        if tab.tabBorder then
            tab.tabBorder:SetCenterColor(
                selected and 0.44 or 0,
                selected and 0.78 or 0,
                selected and 1.00 or 0,
                selected and 0.18 or 0
            )
            tab.tabBorder:SetEdgeColor(
                selected and 0.44 or 0.48,
                selected and 0.78 or 0.52,
                selected and 1.00 or 0.58,
                1
            )
        end
    end

    if self.ui.moduleTab then
        local isDuelingActive = PvPerformance.activeModule == "dueling"
        self.ui.moduleTab:SetColor(0.84, 0.88, 0.94, 1)
        if self.ui.moduleTabBorder then
            self.ui.moduleTabBorder:SetCenterColor(
                isDuelingActive and 0.44 or 0,
                isDuelingActive and 0.78 or 0,
                isDuelingActive and 1.00 or 0,
                isDuelingActive and 0.18 or 0
            )
            self.ui.moduleTabBorder:SetEdgeColor(
                isDuelingActive and 0.44 or 0.48,
                isDuelingActive and 0.78 or 0.52,
                isDuelingActive and 1.00 or 0.58,
                1
            )
        end
        self.ui.moduleUnderline:SetHidden(true)
    end

    local detailFilter = self.ui.detailFilter
    local selectedDuel = self.ui.selectedDuel
    local isStatisticsTab = self.ui.activeTab == "statistics"
    local isSettingsTab = self.ui.activeTab == "settings"
    local isCommandsTab = self.ui.activeTab == "commands"
    local contentMode = self.ui.mainContentMode or "dashboard"
    if contentMode == "combatSummary" and not selectedDuel then
        contentMode = "dashboard"
        self.ui.mainContentMode = contentMode
    end
    local isDuelSummary = contentMode == "combatSummary" and selectedDuel ~= nil
    local duelSummarySource = self.ui.duelSummarySource
    local isDashboardTab = isStatisticsTab or isSettingsTab or isCommandsTab or isDuelSummary
    local isOpponentDetail = contentMode == "opponentDetails"
        and detailFilter and detailFilter.tab == "opponents"
    local supportsSearch = self.ui.activeTab ~= "classes" and not isDashboardTab and not detailFilter
    local supportsAggregateSort = (self.ui.activeTab == "opponents" or self.ui.activeTab == "classes") and not detailFilter
    self.ui.searchLabel:SetHidden(not supportsSearch)
    self.ui.searchBackdrop:SetHidden(not supportsSearch)
    self.ui.searchInput:SetHidden(not supportsSearch)
    self.ui.aggregateSortBackdrop:SetHidden(not supportsAggregateSort)
    self.ui.aggregateSortClickTarget:SetMouseEnabled(supportsAggregateSort)
    if supportsAggregateSort then
        self.ui.aggregateSortLabel:SetText("Sort")
    end
    self.ui.detailBack:SetHidden(not (detailFilter or isDuelSummary))
    if isDuelSummary then
        local sourceTab = duelSummarySource and duelSummarySource.tab or self.ui.activeTab
        if sourceTab == "recent" then
            self.ui.detailBack:SetText("< RECENT DUELS")
        elseif sourceTab == "classes" then
            self.ui.detailBack:SetText("< CLASS DUELS")
        else
            self.ui.detailBack:SetText("< OPPONENT DUELS")
        end
    elseif detailFilter then
        self.ui.detailBack:SetText(detailFilter.tab == "opponents" and "< ALL OPPONENTS" or "< ALL CLASSES")
    end
    self.ui.statisticsPanel:SetHidden(not isStatisticsTab)
    self.ui.settingsPanel:SetHidden(not isSettingsTab)
    self.ui.commandsPanel:SetHidden(not isCommandsTab)
    self.ui.opponentPerformancePanel:SetHidden(not isOpponentDetail)
    self.ui.duelDetailPanel:SetHidden(not isDuelSummary)

    -- Combat summary is an exclusive main-content mode. Hide the reusable
    -- dashboard row pool and its pager before rendering summary values, so a
    -- renderer failure can never leave a stale history row over the report.
    if isDuelSummary then
        for _, row in ipairs(self.ui.rows) do
            row.entry = nil
            row:SetMouseEnabled(false)
            row.clickTarget:SetMouseEnabled(false)
            row:SetHidden(true)
        end
        self.ui.pageLabel:SetHidden(true)
        self.ui.newer:SetHidden(true)
        self.ui.older:SetHidden(true)
    end

    if isStatisticsTab then
        self:RefreshStatistics()
    end
    if isSettingsTab then
        self:RefreshSettingsPanel()
    end
    if isOpponentDetail then
        self:RefreshOpponentPerformance(detailFilter.key)
    end
    if isDuelSummary then
        self:RefreshDuelSummary()
    end

    local entries = isDashboardTab and {} or self:GetViewEntries()
    local pageCount = math.max(1, math.ceil(#entries / #self.ui.rows))
    self.ui.page = math.min(self.ui.page, pageCount)
    local firstIndex = (self.ui.page - 1) * #self.ui.rows + 1
    local rowWidth = self.ui.rowWidth or (DEFAULT_WINDOW_WIDTH - MAIN_CONTENT_LEFT - 22)
    -- Date, duration, damage done, and damage taken form a fixed right-side
    -- grid. The remaining left space grows with the resizable journal.
    local duelStatsWidth = 552
    local duelStatsLeft = rowWidth - duelStatsWidth
    local duelOpponentWidth = math.max(220, duelStatsLeft - 96)
    local aggregateOpponentWidth = math.max(190, rowWidth - 390)

    -- The opponent-performance card occupies a fixed detail-only header.
    -- Reanchor the reusable row pool rather than adding another scroll list.
    local previousRow
    local firstRowOffset = ROW_TOP + (isOpponentDetail and DETAIL_PERFORMANCE_HEIGHT + 10 or 0)
    for _, row in ipairs(self.ui.rows) do
        row:ClearAnchors()
        if previousRow then
            row:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, 6)
        else
            row:SetAnchor(TOPLEFT, self.ui.window, TOPLEFT, MAIN_CONTENT_LEFT, firstRowOffset)
        end
        previousRow = row
    end

    for rowIndex, row in ipairs(self.ui.rows) do
        local entry = entries[firstIndex + rowIndex - 1]
        if entry then
            row:SetHidden(false)
            row.entry = entry
            if entry.kind == "duel" then
                local canSelectDuel = self:CanOpenDuelSummaryFromCurrentView()
                row:SetMouseEnabled(false)
                row.clickTarget:SetMouseEnabled(canSelectDuel)
                local duel = entry.duel
                row.result:SetHidden(false)
                row.result:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 5)
                row.result:SetDimensions(60, 22)
                row.opponent:SetAnchor(TOPLEFT, row, TOPLEFT, 88, 5)
                row.opponent:SetDimensions(duelOpponentWidth, 22)
                row.time:SetHidden(true)
                row.rate:SetHidden(true)
                row.recordHeader:SetHidden(true)
                row.rateHeader:SetHidden(true)
                row.statsDivider:SetHidden(true)
                row.damage:SetHidden(true)
                -- Lift the matchup line so the enlarged rating row below has
                -- a consistent visual gap instead of touching its baseline.
                row.matchup:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 37)
                row.matchup:SetDimensions(math.max(340, duelStatsLeft - 24), 20)
                row.matchup:SetColor(0.70, 0.81, 0.92, 1)
                row.ratingChange:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 65)
                row.ratingChange:SetDimensions(72, 20)
                row.ratingChange:SetHidden(false)
                row.overallRatingChange:SetAnchor(TOPLEFT, row, TOPLEFT, 92, 64)
                row.overallRatingChange:SetDimensions(104, 21)
                row.overallRatingChange:SetHidden(false)
                row.ratingDivider:SetAnchor(TOPLEFT, row, TOPLEFT, 204, 65)
                row.ratingDivider:SetHidden(false)
                row.classRatingChange:SetAnchor(TOPLEFT, row, TOPLEFT, 216, 64)
                row.classRatingChange:SetDimensions(100, 21)
                row.classRatingChange:SetHidden(false)
                row.ratingPlacementDivider:SetAnchor(TOPLEFT, row, TOPLEFT, 322, 65)
                row.ratingPlacementDivider:SetHidden(false)
                row.ratingPlacement:SetAnchor(TOPLEFT, row, TOPLEFT, 334, 64)
                row.ratingPlacement:SetDimensions(136, 21)
                row.ratingPlacement:SetHidden(false)

                row.duelDateHeader:SetAnchor(TOPRIGHT, row, TOPRIGHT, -392, 10)
                row.duelDurationHeader:SetAnchor(TOPRIGHT, row, TOPRIGHT, -284, 10)
                row.duelDamageDoneHeader:SetAnchor(TOPRIGHT, row, TOPRIGHT, -144, 10)
                row.duelDamageTakenHeader:SetAnchor(TOPRIGHT, row, TOPRIGHT, -8, 10)
                row.duelDate:SetAnchor(TOPRIGHT, row, TOPRIGHT, -392, 34)
                row.duelDuration:SetAnchor(TOPRIGHT, row, TOPRIGHT, -284, 34)
                row.duelDamageDone:SetAnchor(TOPRIGHT, row, TOPRIGHT, -144, 34)
                row.duelDamageTaken:SetAnchor(TOPRIGHT, row, TOPRIGHT, -8, 34)
                row.duelStatsDivider:SetAnchor(TOPRIGHT, row, TOPRIGHT, -280, 9)
                row.duelDateHeader:SetHidden(false)
                row.duelDurationHeader:SetHidden(false)
                row.duelDamageDoneHeader:SetHidden(false)
                row.duelDamageTakenHeader:SetHidden(false)
                row.duelDate:SetHidden(false)
                row.duelDuration:SetHidden(false)
                row.duelDamageDone:SetHidden(false)
                row.duelDamageTaken:SetHidden(false)
                row.duelStatsDivider:SetHidden(false)

                local resultText = duel.drawn and "DRAW" or (duel.won and "WIN" or "LOSS")
                row.result:SetText(resultText)
                if duel.won then
                    row.result:SetColor(0.35, 0.84, 0.45, 1)
                elseif duel.drawn then
                    row.result:SetColor(0.66, 0.66, 0.66, 1)
                else
                    row.result:SetColor(1, 0.42, 0.40, 1)
                end

                local characterName = CleanCharacterName(duel.opponent.characterName)
                local opponentText = string.format(
                    "%s  (%s)",
                    duel.opponent.displayName or "Unknown @name",
                    characterName
                )
                row.opponent:SetText(TruncateCombatSourceName(
                    opponentText,
                    math.max(18, math.floor(duelOpponentWidth / 7.4))
                ))
                row.duelDate:SetText(FormatDuelTime(duel))
                row.duelDuration:SetText(FormatDuration(duel.durationSeconds))
                row.matchup:SetText(string.format(
                    "You: %s %s     vs     Opponent: %s %s",
                    duel.player.raceName,
                    ClassDisplayForDuel(duel.player),
                    duel.opponent.raceName,
                    ClassDisplayForDuel(duel.opponent)
                ))
                if duel.damageDone ~= nil and duel.damageTaken ~= nil then
                    row.duelDamageDone:SetText(FormatDamage(duel.damageDone))
                    row.duelDamageTaken:SetText(FormatDamage(duel.damageTaken))
                else
                    row.duelDamageDone:SetText("N/A")
                    row.duelDamageTaken:SetText("N/A")
                end
                local overallChange = duel.overallRatingChange
                local classChange = duel.classRatingChange
                if overallChange ~= nil and classChange ~= nil then
                    row.ratingChange:SetText("RATING")
                    row.ratingChange:SetColor(0.62, 0.70, 0.79, 1)
                    row.overallRatingChange:SetText(string.format("Overall %s", FormatSignedRating(overallChange)))
                    row.classRatingChange:SetText(string.format("Class %s", FormatSignedRating(classChange)))
                    local ratingStatus = ""
                    if duel.suspectedCcLock then
                        ratingStatus = string.format("%s CC LOCK", duel.ccLockConfidence or "SUSPECTED")
                        row.ratingPlacement:SetColor(1, 0.78, 0.26, 1)
                    elseif duel.suspectedLatencySpike then
                        ratingStatus = string.format("%s LAG", duel.latencySpikeConfidence or "SUSPECTED")
                        row.ratingPlacement:SetColor(0.48, 0.78, 1, 1)
                    elseif duel.overallPlacement or duel.classPlacement then
                        ratingStatus = "PLACEMENT"
                        row.ratingPlacement:SetColor(0.70, 0.77, 0.85, 1)
                    elseif duel.overallCalibration or duel.classCalibration then
                        ratingStatus = "PROVISIONAL"
                        row.ratingPlacement:SetColor(0.44, 0.78, 1, 1)
                    end
                    row.ratingPlacement:SetText(ratingStatus)
                    row.ratingPlacement:SetHidden(ratingStatus == "")
                    row.ratingPlacementDivider:SetHidden(ratingStatus == "")
                    if tonumber(overallChange) > 0 then
                        row.overallRatingChange:SetColor(0.38, 0.88, 0.50, 1)
                    elseif tonumber(overallChange) < 0 then
                        row.overallRatingChange:SetColor(1, 0.58, 0.54, 1)
                    else
                        row.overallRatingChange:SetColor(0.66, 0.72, 0.80, 1)
                    end
                    if tonumber(classChange) > 0 then
                        row.classRatingChange:SetColor(0.38, 0.88, 0.50, 1)
                    elseif tonumber(classChange) < 0 then
                        row.classRatingChange:SetColor(1, 0.58, 0.54, 1)
                    else
                        row.classRatingChange:SetColor(0.66, 0.72, 0.80, 1)
                    end
                else
                    row.ratingChange:SetText("RATING N/A")
                    row.ratingChange:SetColor(0.62, 0.70, 0.79, 1)
                    row.overallRatingChange:SetHidden(true)
                    row.ratingDivider:SetHidden(true)
                    row.classRatingChange:SetHidden(true)
                    row.ratingPlacementDivider:SetHidden(true)
                    row.ratingPlacement:SetHidden(true)
                end
            else
                row:SetMouseEnabled(true)
                row.clickTarget:SetMouseEnabled(true)
                row.result:SetHidden(true)
                row.damage:SetHidden(true)
                row.ratingChange:SetHidden(true)
                row.overallRatingChange:SetHidden(true)
                row.ratingDivider:SetHidden(true)
                row.classRatingChange:SetHidden(true)
                row.ratingPlacementDivider:SetHidden(true)
                row.ratingPlacement:SetHidden(true)
                row.duelDateHeader:SetHidden(true)
                row.duelDurationHeader:SetHidden(true)
                row.duelDamageDoneHeader:SetHidden(true)
                row.duelDamageTakenHeader:SetHidden(true)
                row.duelDate:SetHidden(true)
                row.duelDuration:SetHidden(true)
                row.duelDamageDone:SetHidden(true)
                row.duelDamageTaken:SetHidden(true)
                row.duelStatsDivider:SetHidden(true)
                row.opponent:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 12)
                row.opponent:SetDimensions(aggregateOpponentWidth, 24)
                row.opponent:SetText(TruncateCombatSourceName(
                    entry.name,
                    math.max(18, math.floor(aggregateOpponentWidth / 7.4))
                ))
                row.time:SetHidden(false)
                row.time:SetAnchor(TOPRIGHT, row, TOPRIGHT, -80, 43)
                row.time:SetDimensions(104, 20)
                row.time:SetText(RecordOnlyText(entry))
                row.rate:SetAnchor(TOPRIGHT, row, TOPRIGHT, -10, 43)
                row.rate:SetDimensions(58, 20)
                row.rate:SetText(WinRateOnlyText(entry))
                row.rate:SetHidden(false)
                row.recordHeader:SetHidden(false)
                row.rateHeader:SetHidden(false)
                row.statsDivider:SetHidden(false)
                row.matchup:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 47)
                row.matchup:SetDimensions(aggregateOpponentWidth, 18)
                row.matchup:SetColor(0.62, 0.70, 0.79, 1)
                local aggregateDetail = string.format(
                    "%d duel%s",
                    entry.total,
                    entry.total == 1 and "" or "s"
                )
                if entry.note and entry.note ~= "" then
                    aggregateDetail = string.format("%s  |  %s", aggregateDetail, entry.note)
                end
                row.matchup:SetText(string.format("%s  |  Click to view history", aggregateDetail))
            end
        else
            row.entry = nil
            row:SetMouseEnabled(false)
            row.clickTarget:SetMouseEnabled(false)
            row:SetHidden(true)
        end
    end

    if not isDashboardTab then
        local visibleRows = math.max(1, math.min(#self.ui.rows, #entries - firstIndex + 1))
        local pagerAnchor = self.ui.rows[visibleRows]
        self.ui.newer:ClearAnchors()
        self.ui.newer:SetAnchor(TOPLEFT, pagerAnchor, BOTTOMLEFT, 0, 10)
        self.ui.pageLabel:ClearAnchors()
        self.ui.pageLabel:SetAnchor(TOP, pagerAnchor, BOTTOM, 0, 10)
        self.ui.older:ClearAnchors()
        self.ui.older:SetAnchor(TOPRIGHT, pagerAnchor, BOTTOMRIGHT, 0, 10)
    end

    self.ui.pageLabel:SetText(string.format("Page %d of %d", self.ui.page, pageCount))
    self.ui.pageLabel:SetHidden(isDashboardTab)
    self.ui.newer:SetHidden(isDashboardTab or self.ui.page <= 1)
    self.ui.older:SetHidden(isDashboardTab or self.ui.page >= pageCount)
end

local PVPERFORMANCE_DUELING_SCENE_NAME = "PVPERFORMANCE_DUELING_SCENE"

local function GetSceneStateName(state)
    local names = {}
    if SCENE_SHOWING ~= nil then names[SCENE_SHOWING] = "SHOWING" end
    if SCENE_SHOWN ~= nil then names[SCENE_SHOWN] = "SHOWN" end
    if SCENE_HIDING ~= nil then names[SCENE_HIDING] = "HIDING" end
    if SCENE_HIDDEN ~= nil then names[SCENE_HIDDEN] = "HIDDEN" end
    return state ~= nil and (names[state] or tostring(state)) or "N/A"
end

local function ReadSceneObjectState(object)
    if not object or type(object.GetState) ~= "function" then
        return nil
    end

    local ok, state = pcall(object.GetState, object)
    return ok and state or nil
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetCurrentScene) ~= "function" then
        return "N/A"
    end

    local ok, currentScene = pcall(SCENE_MANAGER.GetCurrentScene, SCENE_MANAGER)
    if not ok or not currentScene then
        return "N/A"
    end
    if type(currentScene.GetName) == "function" then
        local nameOk, name = pcall(currentScene.GetName, currentScene)
        return nameOk and tostring(name) or "N/A"
    end
    return currentScene.name and tostring(currentScene.name) or "N/A"
end

local function SetSceneFallback(self, reason)
    self.sceneFallbackReason = reason or self.sceneFallbackReason or "unknown scene lifecycle failure"
    if not self.sceneFallbackActive then
        self.sceneFallbackActive = true
        Print(string.format(
            "PvP-erformance: scene UI unavailable (%s); using the safe window fallback.",
            self.sceneFallbackReason
        ))
    end
    return false
end

function Dueling:InitializeScene()
    self:CreateUI()

    if self.sceneFallbackActive then
        return false
    end
    if self.scene and self.windowFragment then
        return true
    end
    if self.sceneInitializationAttempted then
        return SetSceneFallback(self, "scene initialization was already attempted")
    end
    if not (
            SCENE_MANAGER
            and SCENE_MANAGER.RegisterCallback
            and SCENE_MANAGER.Show
            and SCENE_MANAGER.Hide
            and SCENE_MANAGER.IsShowing
            and ZO_Scene
            and ZO_FadeSceneFragment
        ) then
        return SetSceneFallback(self, "required scene API is unavailable")
    end

    self.sceneInitializationAttempted = true
    local ok, scene, fragment = pcall(function()
        local newScene = ZO_Scene:New(PVPERFORMANCE_DUELING_SCENE_NAME, SCENE_MANAGER)
        -- A single normal scene and fade fragment are the sole visibility
        -- authority. ESO places the scene on its normal navigation stack, so
        -- ESC closes it without an addon-owned key handler or UI-mode toggle.
        local newFragment = ZO_FadeSceneFragment:New(self.ui.window)
        newScene:AddFragment(newFragment)
        return newScene, newFragment
    end)
    if not ok or not scene or not fragment then
        return SetSceneFallback(self, "scene or window fragment creation failed")
    end

    -- One scene and one fragment own the existing window. They are runtime-only
    -- fields and are never written to SavedVariables.
    self.scene = scene
    self.windowFragment = fragment
    self.sceneName = PVPERFORMANCE_DUELING_SCENE_NAME
    self.sceneMouseDrivenGroup = false
    PvPerformance.scene = scene
    PvPerformance.windowFragment = fragment

    local callbackRegistered = pcall(function()
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(changedScene, newState)
            if changedScene ~= scene or not self.ui then
                return
            end

            if newState == SCENE_SHOWING then
                self.ui.sceneVisible = true
                self:RefreshUI()
            elseif newState == SCENE_HIDING then
                self:HideRankingInfoPanel()
                self.ui.window:StopMovingOrResizing()
            elseif newState == SCENE_HIDDEN then
                self.ui.sceneVisible = false
            end
        end)
    end)
    if not callbackRegistered then
        self.scene = nil
        self.windowFragment = nil
        self.sceneName = nil
        self.sceneMouseDrivenGroup = nil
        PvPerformance.scene = nil
        PvPerformance.windowFragment = nil
        return SetSceneFallback(self, "scene callback registration failed")
    end

    return true
end

function Dueling:IsSceneShowing()
    return self:IsSceneActive()
end

function Dueling:IsSceneActive()
    if not self.scene or not self.sceneName or not SCENE_MANAGER then
        return false
    end

    local state = ReadSceneObjectState(self.scene)
    if (SCENE_SHOWING ~= nil and state == SCENE_SHOWING)
        or (SCENE_SHOWN ~= nil and state == SCENE_SHOWN)
        or (SCENE_HIDING ~= nil and state == SCENE_HIDING) then
        return true
    end

    local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, self.sceneName)
    return ok and showing == true
end

function Dueling:GetSceneInputStatus()
    return {
        sceneExists = self.scene ~= nil,
        sceneName = self.sceneName or PVPERFORMANCE_DUELING_SCENE_NAME,
        currentSceneName = GetCurrentSceneName(),
        sceneState = GetSceneStateName(ReadSceneObjectState(self.scene)),
        fragmentExists = self.windowFragment ~= nil,
        fragmentState = GetSceneStateName(ReadSceneObjectState(self.windowFragment)),
        mouseDrivenGroup = self.sceneMouseDrivenGroup == true,
        exitKeybindActive = self.sceneExitKeybindActive == true,
        ownsUIMode = self.ui and self.ui.ownsUIMode == true or false,
        active = self:IsSceneActive(),
        fallback = self.sceneFallbackActive == true,
        fallbackReason = self.sceneFallbackReason,
        windowHidden = not (self.ui and self.ui.window) or self.ui.window:IsHidden(),
        view = self.ui and string.format("%s/%s", self.ui.activeTab or "none", self.ui.mainContentMode or "dashboard") or "N/A",
        selectedDuel = self.ui and self.ui.selectedDuel ~= nil or false,
    }
end

function Dueling:OpenJournal(context)
    self:CreateUI()

    if context then
        if context.activeTab then
            self.ui.activeTab = context.activeTab
        end
        if context.detailFilter ~= nil then
            self.ui.detailFilter = context.detailFilter
        end
        if context.mainContentMode then
            self:SetMainContentMode(context.mainContentMode)
        end
        if context.page then
            self.ui.page = context.page
        end
    end

    if self:InitializeScene() then
        if self:IsSceneActive() then
            self:RefreshUI()
            return true
        end

        local shown, result = pcall(SCENE_MANAGER.Show, SCENE_MANAGER, self.sceneName)
        if shown and result ~= false then
            return true
        end
        SetSceneFallback(self, "scene show request failed")
    end

    -- Strict emergency fallback only: a normal journal open never reaches this
    -- path after startup scene initialization succeeded.
    self:RefreshUI()
    self.ui.window:SetHidden(false)
    return false
end

function Dueling:ShowUI()
    return self:OpenJournal()
end

function Dueling:HideUI()
    if not self.ui then
        return
    end

    if self:IsSceneActive() then
        local hidden, result = pcall(SCENE_MANAGER.Hide, SCENE_MANAGER, self.sceneName)
        if hidden and result ~= false then
            return
        end
        SetSceneFallback(self, "scene hide request failed")
    end

    if not self.sceneFallbackActive then
        -- The scene is already hidden; there is no direct-window lifecycle to
        -- clean up in the normal path.
        return
    end

    -- Emergency fallback only. No child-control teardown, focus forcing, or
    -- custom keyboard/camera handling occurs here.
    self:HideRankingInfoPanel()
    self.ui.window:SetHidden(true)
end

function Dueling:ToggleUI()
    self:CreateUI()
    if self:IsSceneActive() then
        self:HideUI()
    else
        self:OpenJournal()
    end
end

function Dueling:ShowRankingInfoPanel(mode)
    if self.ui and self.ui.rankingInfoOverlay then
        self.ui.rankingInfoMode = mode == "class" and "class" or "overall"
        self:RefreshRankingInfoGuide()
        self.ui.rankingInfoOverlay:SetHidden(false)
    end
end

function Dueling:HideRankingInfoPanel()
    if self.ui and self.ui.rankingInfoOverlay then
        self.ui.rankingInfoOverlay:SetHidden(true)
    end
end

function Dueling:RefreshRankingInfoGuide()
    if not self.ui or not self.ui.rankingInfoTierRows then
        return
    end

    for _, row in pairs(self.ui.rankingInfoTierRows) do
        row.highlight:SetHidden(true)
    end

    local isClassGuide = self.ui.rankingInfoMode == "class"
    local ratingState
    if isClassGuide then
        ratingState = self:GetClassRatingState(self:GetSelectedClassTierId())
        self.ui.rankingInfoTitle:SetText("CLASS TIER PROGRESSION")
        self.ui.rankingInfoBlurb:SetText(string.format(
            "Your %s Class Tier uses the same 0-100 point ranks and global rules.\nExpected-matchup scoring adjusts gains and losses before those rules apply.",
            ratingState.className
        ))
        self.ui.rankingInfoPlacement:SetText(string.format(
            "|c73C7FFCLASS PLACEMENT & BASE RATING|r\n\n"
            .. "While playing %s, placement requires 20 decisive results against at least 15 opponents. Only 2 results from the same opponent can count.\n\n"
            .. "Everyone starts from 50. Each placement win moves the starting rating up by 2 points and each loss moves it down by 2, with a final placement range of 40 to 84. The next 20 decisive class results are marked PROV.\n\n"
            .. "After placement, Class Rating adjusts changes for expected matchup difficulty. Draws and forfeits change nothing, and ratings stay between 0 and 100.\n\n"
            .. "|c73C7FFREPEAT-OPPONENT ANTI-FARMING|r\n\n"
            .. "Successive wins against one opponent award 100%%, 75%%, 50%%, 25%%, then 2%%. At standard rating value, an exhausted win adds only one-hundredth of a point, so 100 exhausted wins are needed for 1 point before other modifiers.\n\n"
            .. "A loss before exhaustion lowers fatigue by one step; draws do not restore value.\n\n"
            .. "An exhausted matchup resets either after 48 real-world hours or after 10 decisive duels against other opponents that include at least 5 different players. If five opponents are exhausted together, they provide only four other players for each activity-based lock. You must duel a sixth different player before that kind of reset is possible.",
            ratingState.className
        ))
        self.ui.rankingInfoClass:SetScale(1.08)
        self.ui.rankingInfoClass:SetText(string.format(
            "Overall Tier records raw results. %s Class Tier is independent. Underdog wins award more and expected losses cost less; favored wins award less and upset losses cost more. Mirror matches use the standard half-point change. Win Rate excludes draws.\n"
            .. "Ratings are local progression, not official ESO MMR or a verified global percentile. Matchup coefficients are author-defined and patch-dependent; CC and damage signals are API-based approximations. No results are uploaded automatically.",
            ratingState.className
        ))
    else
        ratingState = self:GetRatingState()
        self.ui.rankingInfoTitle:SetText("DUELING TIER PROGRESSION")
        self.ui.rankingInfoBlurb:SetText(
            "Your Overall Tier appears after placement. The 0-100 point ladder is shown below;\nyour current tier is highlighted."
        )
        self.ui.rankingInfoPlacement:SetText(
            "|c73C7FFPLACEMENT & BASE RATING|r\n\n"
            .. "Placement requires 20 decisive results against at least 15 opponents. Only 2 results from the same opponent can count.\n\n"
            .. "Everyone starts from 50. Each placement win moves the starting rating up by 2 points and each loss moves it down by 2, with a final placement range of 40 to 84. The next 20 decisive results are marked PROV.\n\n"
            .. "After placement, a standard win adds half a point, a standard loss removes half a point, and a draw or forfeit changes nothing. Ratings stay between 0 and 100.\n\n"
            .. "|c73C7FFREPEAT-OPPONENT ANTI-FARMING|r\n\n"
            .. "Successive wins against one opponent award 100%, 75%, 50%, 25%, then 2%. At standard rating value, an exhausted win adds only one-hundredth of a point, so 100 exhausted wins are needed for 1 point before other modifiers.\n\n"
            .. "A loss before exhaustion lowers fatigue by one step; draws do not restore value.\n\n"
            .. "An exhausted matchup resets either after 48 real-world hours or after 10 decisive duels against other opponents that include at least 5 different players. If five opponents are exhausted together, they provide only four other players for each activity-based lock. You must duel a sixth different player before that kind of reset is possible."
        )
        self.ui.rankingInfoClass:SetScale(1.08)
        self.ui.rankingInfoClass:SetText(
            "Overall Tier records raw results. Class Tier is independent per class and adjusts expected matchups. Win Rate counts wins and losses only; draws are neutral.\n"
            .. "Ratings are local progression, not official ESO MMR or a verified global percentile. Class coefficients are patch-dependent; CC and damage signals are API-based approximations. No results are uploaded automatically."
        )
    end

    if ratingState.placed then
        local currentRank = RankForRating(ratingState.rating)
        local currentRow = self.ui.rankingInfoTierRows[currentRank.name]
        if currentRow then
            currentRow.highlight:SetHidden(false)
        end
    end
end

