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
function Dueling:CreateInitialRanking()
    return {
        rulesVersion = RATING_RULES_VERSION,
        rating = STARTING_RATING,
        opponentDuels = {},
        opponentFatigue = {},
        diminishingOpponents = {},
        exhaustedMatchupRecovery = {},
        winStreak = 0,
        qualifyingOpponents = {},
        qualifyingCount = 0,
        placementOpponentResults = {},
        placementDecisiveCount = 0,
        placementWins = 0,
        placementLosses = 0,
        calibrationDecisiveCount = 0,
    }
end

function Dueling:ApplyRatingForDuel(duel, season)
    season = season or self:GetActiveSeason()
    return ApplyRatingChange(season.ranking, duel, WIN_POINTS, LOSS_POINTS)
end

function Dueling:RebuildRankingFromHistory(season)
    season = season or self:GetActiveSeason()
    season.ranking = self:CreateInitialRanking()
    for _, duel in ipairs(season.history) do
        local change, wasPlacement, _, _, wasCalibration, details = self:ApplyRatingForDuel(duel, season)
        duel.overallRatingChange = SignedRatingChange(duel, change)
        duel.overallPlacement = wasPlacement
        duel.overallCalibration = wasCalibration
        duel.overallRatingDebug = details
    end
end

function Dueling:NormalizeHistoricalForfeits()
    -- Older builds could store a forfeit as a win. The raw result was retained
    -- in every journal entry, so correct the presentation and replay inputs
    -- before ratings are rebuilt.
    for _, duel in ipairs(self.savedVars.history or {}) do
        if duel.result == DUEL_RESULT_FORFEIT then
            duel.drawn = true
            duel.won = false
        end
    end
end

function Dueling:GetRatingState()
    if self.testRatingState and self:IsViewingActiveSeason() then
        return self.testRatingState
    end

    local season = self:GetViewedSeason()
    local ranking = season and season.ranking or self:CreateInitialRanking()
    return {
        rating = ranking.rating,
        placed = PlacementComplete(ranking),
        calibrating = PlacementComplete(ranking) and not CalibrationComplete(ranking),
        qualifyingOpponents = ranking.qualifyingCount or 0,
        placementDecisiveCount = ranking.placementDecisiveCount or 0,
        calibrationDecisiveCount = ranking.calibrationDecisiveCount or 0,
    }
end

function Dueling:CreateInitialClassRanking()
    return {
        rating = STARTING_RATING,
        opponentDuels = {},
        opponentFatigue = {},
        diminishingOpponents = {},
        exhaustedMatchupRecovery = {},
        winStreak = 0,
        qualifyingOpponents = {},
        qualifyingCount = 0,
        placementOpponentResults = {},
        placementDecisiveCount = 0,
        placementWins = 0,
        placementLosses = 0,
        calibrationDecisiveCount = 0,
    }
end

function Dueling:GetCurrentClassTierId()
    if PlayerIsWerewolf() then
        return CLASS_WEREWOLF
    end

    return GetUnitClassId("player")
end

function Dueling:GetDuelPlayerClassTierId(duel)
    local player = duel and duel.player or {}
    if player.wasWerewolf then
        return CLASS_WEREWOLF
    end

    return player.classId
end

function Dueling:GetDuelOpponentClassTierId(duel)
    local opponent = duel and duel.opponent or {}
    if opponent.wasWerewolf then
        return CLASS_WEREWOLF
    end

    return opponent.classId
end

function Dueling:GetClassRanking(classId, createIfMissing, season)
    classId = tonumber(classId)
    if not classId or classId == 0 then
        return nil
    end

    season = season or self:GetActiveSeason()
    if not season then
        return nil
    end

    if not season.classRankings then
        if createIfMissing == false then
            return nil
        end
        season.classRankings = {}
    end
    local ranking = season.classRankings[classId]
    if not ranking and createIfMissing ~= false then
        ranking = self:CreateInitialClassRanking()
        season.classRankings[classId] = ranking
    end

    return ranking
end

function Dueling:ApplyClassRatingForDuel(duel, season)
    season = season or self:GetActiveSeason()
    local playerClassId = self:GetDuelPlayerClassTierId(duel)
    local opponentClassId = self:GetDuelOpponentClassTierId(duel)
    local ranking = self:GetClassRanking(playerClassId, nil, season)
    if not ranking then
        return 0, false
    end

    local expectedWinChance = ClassExpectedWinChance(playerClassId, opponentClassId)
    local change, wasPlacement, winMultiplier, lossMultiplier, wasCalibration, details = ApplyRatingChange(
        ranking,
        duel,
        CLASS_RATING_K * (1 - expectedWinChance),
        CLASS_RATING_K * expectedWinChance
    )
    details.expectedWinChance = expectedWinChance
    return change, wasPlacement, winMultiplier, lossMultiplier, wasCalibration, details
end

function Dueling:RebuildClassRankingsFromHistory(season)
    season = season or self:GetActiveSeason()
    season.classRankings = {}
    for _, duel in ipairs(season.history) do
        local change, wasPlacement, _, _, wasCalibration, details = self:ApplyClassRatingForDuel(duel, season)
        duel.classRatingChange = SignedRatingChange(duel, change)
        duel.classPlacement = wasPlacement
        duel.classCalibration = wasCalibration
        duel.classRatingDebug = details
    end
    season.classRankingRulesVersion = CLASS_RATING_RULES_VERSION
end

function Dueling:GetSelectedClassTierId()
    if self.ui and self.ui.selectedClassTierId then
        return self.ui.selectedClassTierId
    end

    return self:GetCurrentClassTierId()
end

function Dueling:GetClassRatingState(classId)
    classId = tonumber(classId) or self:GetCurrentClassTierId()
    if self.testClassRatingState and self:IsViewingActiveSeason()
        and self.testClassRatingState.classId == classId then
        return self.testClassRatingState
    end

    -- Looking at a class must never create or modify a saved ranking. An
    -- untouched class simply presents its unplaced starting state.
    local ranking = self:GetClassRanking(classId, false, self:GetViewedSeason()) or self:CreateInitialClassRanking()

    return {
        classId = classId,
        className = NameForClass(classId, GetUnitGender("player")),
        rating = ranking.rating,
        placed = PlacementComplete(ranking),
        calibrating = PlacementComplete(ranking) and not CalibrationComplete(ranking),
        qualifyingOpponents = ranking.qualifyingCount or 0,
        placementDecisiveCount = ranking.placementDecisiveCount or 0,
        calibrationDecisiveCount = ranking.calibrationDecisiveCount or 0,
    }
end

function Dueling:CreateSeasonData(seasonId, seasonName, startedAt)
    return {
        id = seasonId,
        name = seasonName,
        startedAt = startedAt or GetTimeStamp(),
        history = {},
        ranking = self:CreateInitialRanking(),
        classRankings = {},
        classRankingRulesVersion = CLASS_RATING_RULES_VERSION,
    }
end

function Dueling:EnsureSeasonRankings(season)
    if not season then
        return
    end

    season.history = season.history or {}
    if not season.ranking
        or not season.ranking.opponentDuels
        or not season.ranking.qualifyingOpponents
        or season.ranking.qualifyingCount == nil
        or not season.ranking.placementOpponentResults
        or season.ranking.placementDecisiveCount == nil
        or season.ranking.calibrationDecisiveCount == nil
        or season.ranking.rating == nil
        or season.ranking.rulesVersion ~= RATING_RULES_VERSION then
        self:RebuildRankingFromHistory(season)
    end
    if type(season.classRankings) ~= "table"
        or season.classRankingRulesVersion ~= CLASS_RATING_RULES_VERSION then
        self:RebuildClassRankingsFromHistory(season)
    end
end

function Dueling:InitializeSeasons()
    self.savedVars.seasons = self.savedVars.seasons or {}
    local seasons = self.savedVars.seasons

    -- v0.15.3 and older stored a single journal at the saved-variable root.
    -- Preserve it once as a read-only Preseason archive before Season 1 begins.
    if (tonumber(self.savedVars.seasonSchemaVersion) or 0) < 1 then
        local legacyHistory = type(self.savedVars.history) == "table" and self.savedVars.history or {}
        local hasLegacyData = #legacyHistory > 0
            or self.savedVars.ranking ~= nil
            or self.savedVars.classRankings ~= nil
        if hasLegacyData and not seasons[PRESEASON_ID] then
            seasons[PRESEASON_ID] = {
                id = PRESEASON_ID,
                name = PRESEASON_NAME,
                startedAt = 0,
                endedAt = GetTimeStamp(),
                history = legacyHistory,
                ranking = self.savedVars.ranking,
                classRankings = self.savedVars.classRankings,
                classRankingRulesVersion = self.savedVars.classRankingRulesVersion,
            }
        end
        self.savedVars.history = nil
        self.savedVars.ranking = nil
        self.savedVars.classRankings = nil
        self.savedVars.classRankingRulesVersion = nil
        self.savedVars.seasonSchemaVersion = 1
    end

    local previousActiveId = self.savedVars.activeSeasonId
    if previousActiveId and previousActiveId ~= CURRENT_SEASON_ID and seasons[previousActiveId] then
        seasons[previousActiveId].endedAt = seasons[previousActiveId].endedAt or GetTimeStamp()
    end
    if not seasons[CURRENT_SEASON_ID] then
        seasons[CURRENT_SEASON_ID] = self:CreateSeasonData(CURRENT_SEASON_ID, CURRENT_SEASON_NAME)
    end
    self.savedVars.activeSeasonId = CURRENT_SEASON_ID

    for _, season in pairs(seasons) do
        self:EnsureSeasonRankings(season)
    end
end

function Dueling:ShowClassTierSelectorMenu(control)
    local addMenuItem = AddCustomMenuItem or AddMenuItem
    if not ClearMenu or not addMenuItem or not ShowMenu then
        return
    end

    ClearMenu()
    for _, classId in ipairs(CLASS_TIER_OPTIONS) do
        local selectedId = classId
        local className = NameForClass(selectedId, GetUnitGender("player"))
        addMenuItem(className, function()
            if self.ui then
                self.ui.selectedClassTierId = selectedId
                self:RefreshUI()
            end
        end)
    end
    ShowMenu(control)
end

function Dueling:ShowAggregateSortMenu(control)
    if not self.ui then
        return
    end

    local tab = self.ui.activeTab
    if (tab ~= "opponents" and tab ~= "classes") or self.ui.detailFilter then
        return
    end

    local addMenuItem = AddCustomMenuItem or AddMenuItem
    if not ClearMenu or not addMenuItem or not ShowMenu then
        return
    end

    local state = self.ui.aggregateSort[tab]
    ClearMenu()
    for _, option in ipairs(AGGREGATE_SORT_OPTIONS) do
        local selectedOption = option
        local isActive = state.key == selectedOption.key
        local direction = selectedOption.key == "name" and "A-Z" or "high to low"
        local prefix = isActive and string.format("* %s (%s)", selectedOption.label, direction)
            or string.format("%s (%s)", selectedOption.label, direction)
        addMenuItem(prefix, function()
            -- Numeric aggregate choices are intentionally always high to low.
            -- Selecting an already-active item must not silently reverse the
            -- order, which made the old menu appear to sort incorrectly.
            state.key = selectedOption.key
            self.ui.page = 1
            self:RefreshUI()
        end)
    end
    ShowMenu(control)
end

function Dueling:ShowRatingPreview()
    self:CreateUI()
    if self.ui.window:IsHidden() then
        self:ShowUI()
    else
        self:RefreshUI()
    end
end

function Dueling:SetPlacementPreview(progress)
    progress = tonumber(progress) or 0
    progress = math.max(0, math.min(PLACEMENT_DECISIVE_DUELS_REQUIRED - 1, math.floor(progress)))
    self.testRatingState = {
        rating = STARTING_RATING,
        placed = false,
        qualifyingOpponents = math.min(progress, PLACEMENT_OPPONENTS_REQUIRED),
        placementDecisiveCount = progress,
        calibrationDecisiveCount = 0,
    }
    Print(string.format(
        "Creator preview: provisional results set to %d/%d. Your saved records and rating are unchanged.",
        progress,
        PLACEMENT_DECISIVE_DUELS_REQUIRED
    ))
    self:ShowRatingPreview()
end

function Dueling:SetRatingPreview(rating)
    rating = tonumber(rating) or STARTING_RATING
    rating = math.max(0, math.min(100, rating))
    self.testRatingState = {
        rating = rating,
        placed = true,
        calibrating = false,
        qualifyingOpponents = PLACEMENT_OPPONENTS_REQUIRED,
        placementDecisiveCount = PLACEMENT_DECISIVE_DUELS_REQUIRED,
        calibrationDecisiveCount = CALIBRATION_DECISIVE_DUELS_REQUIRED,
    }
    local rank = RankForRating(rating)
    Print(string.format(
        "Creator preview: %s rating (%s tier). Your saved records and rating are unchanged.",
        FormatRating(rating),
        rank.name
    ))
    self:ShowRatingPreview()
end

function Dueling:SetClassPlacementPreview(progress)
    progress = tonumber(progress) or 0
    progress = math.max(0, math.min(PLACEMENT_DECISIVE_DUELS_REQUIRED - 1, math.floor(progress)))
    local classId = self:GetCurrentClassTierId()
    self.testClassRatingState = {
        classId = classId,
        className = NameForClass(classId, GetUnitGender("player")),
        rating = STARTING_RATING,
        placed = false,
        qualifyingOpponents = math.min(progress, PLACEMENT_OPPONENTS_REQUIRED),
        placementDecisiveCount = progress,
        calibrationDecisiveCount = 0,
    }
    Print(string.format(
        "Creator preview: Class Tier provisional results set to %d/%d. Your saved records and rating are unchanged.",
        progress,
        PLACEMENT_DECISIVE_DUELS_REQUIRED
    ))
    self:ShowRatingPreview()
end

function Dueling:SetClassRatingPreview(rating)
    rating = tonumber(rating) or STARTING_RATING
    rating = math.max(0, math.min(100, rating))
    local classId = self:GetCurrentClassTierId()
    self.testClassRatingState = {
        classId = classId,
        className = NameForClass(classId, GetUnitGender("player")),
        rating = rating,
        placed = true,
        calibrating = false,
        qualifyingOpponents = PLACEMENT_OPPONENTS_REQUIRED,
        placementDecisiveCount = PLACEMENT_DECISIVE_DUELS_REQUIRED,
        calibrationDecisiveCount = CALIBRATION_DECISIVE_DUELS_REQUIRED,
    }
    local rank = RankForRating(rating)
    Print(string.format(
        "Creator preview: Class Tier %s rating (%s tier). Your saved records and rating are unchanged.",
        FormatRating(rating),
        rank.name
    ))
    self:ShowRatingPreview()
end

function Dueling:GetTestSandboxForCurrentClass()
    local classId = self:GetCurrentClassTierId()
    if not classId or classId == 0 then
        return nil, nil
    end

    local activeSeason = self:GetActiveSeason()
    if not self.testSandbox then
        local liveClassRanking = activeSeason.classRankings and activeSeason.classRankings[classId]
        self.testSandbox = {
            overall = CopyRanking(activeSeason.ranking),
            classes = {},
        }
        self.testSandbox.classes[classId] = CopyRanking(liveClassRanking or self:CreateInitialClassRanking())
    elseif not self.testSandbox.classes[classId] then
        local liveClassRanking = activeSeason.classRankings and activeSeason.classRankings[classId]
        self.testSandbox.classes[classId] = CopyRanking(liveClassRanking or self:CreateInitialClassRanking())
    end

    return self.testSandbox.overall, self.testSandbox.classes[classId]
end

function Dueling:SimulateTestDuel(resultText, opponentClassText, opponentDisplayName)
    local result = zo_strlower(resultText or "")
    local opponentClassId = TestClassIdFromText(opponentClassText)
    local playerClassId = self:GetCurrentClassTierId()
    if result ~= "win" and result ~= "loss" and result ~= "draw" then
        Print("Usage: /metrics test simulate <win|loss|draw> <ww|dk|sorc|nb|warden|necro|templar|arc> [@name]")
        return
    end
    if not opponentClassId then
        Print("Unknown test class. Use ww, dk, sorc, nb, warden, necro, templar, or arc.")
        return
    end
    if not playerClassId or playerClassId == 0 then
        Print("Could not determine your current class for the Class Tier simulation.")
        return
    end

    local overallRanking, classRanking = self:GetTestSandboxForCurrentClass()
    if not overallRanking or not classRanking then
        Print("Could not start the rating test sandbox.")
        return
    end

    local opponentName = opponentDisplayName and opponentDisplayName ~= "" and opponentDisplayName
        or string.format("@test_%s", opponentClassText)
    local duel = {
        won = result == "win",
        drawn = result == "draw",
        player = { classId = playerClassId },
        opponent = {
            displayName = opponentName,
            classId = opponentClassId,
            wasWerewolf = opponentClassId == CLASS_WEREWOLF,
        },
    }

    local overallBefore = overallRanking.rating
    local _, overallPlacement, _, _, overallCalibration = ApplyRatingChange(overallRanking, duel, WIN_POINTS, LOSS_POINTS)
    local overallActualChange = math.abs(overallRanking.rating - overallBefore)

    local expectedWinChance = ClassExpectedWinChance(playerClassId, opponentClassId)
    local classBefore = classRanking.rating
    local _, classPlacement, _, _, classCalibration = ApplyRatingChange(
        classRanking,
        duel,
        CLASS_RATING_K * (1 - expectedWinChance),
        CLASS_RATING_K * expectedWinChance
    )
    local classActualChange = math.abs(classRanking.rating - classBefore)

    self.testRatingState = {
        rating = overallRanking.rating,
        placed = PlacementComplete(overallRanking),
        calibrating = PlacementComplete(overallRanking) and not CalibrationComplete(overallRanking),
        qualifyingOpponents = overallRanking.qualifyingCount,
        placementDecisiveCount = overallRanking.placementDecisiveCount,
        calibrationDecisiveCount = overallRanking.calibrationDecisiveCount,
    }
    self.testClassRatingState = {
        classId = playerClassId,
        className = NameForClass(playerClassId, GetUnitGender("player")),
        rating = classRanking.rating,
        placed = PlacementComplete(classRanking),
        calibrating = PlacementComplete(classRanking) and not CalibrationComplete(classRanking),
        qualifyingOpponents = classRanking.qualifyingCount,
        placementDecisiveCount = classRanking.placementDecisiveCount,
        calibrationDecisiveCount = classRanking.calibrationDecisiveCount,
    }

    local resultPrefix = duel.won and "+" or (duel.drawn and "" or "-")
    local overallDeltaText = duel.drawn and "0" or resultPrefix .. FormatRating(overallActualChange)
    local classDeltaText = duel.drawn and "0" or resultPrefix .. FormatRating(classActualChange)
    local overallContext = overallPlacement and " provisional" or (overallCalibration and " calibration" or "")
    local classContext = classPlacement and " provisional" or (classCalibration and " calibration" or "")
    local classModifierText = string.format("%d%% expected win chance", expectedWinChance * 100)
    Print(string.format(
        "Sandbox %s vs %s: Overall %s%s | Class %s%s (%s)",
        string.upper(result),
        NameForClass(opponentClassId, GENDER_MALE),
        overallDeltaText,
        overallContext,
        classDeltaText,
        classContext,
        classModifierText
    ))
    self:ShowRatingPreview()
end

function Dueling:ClearRatingPreview()
    self.testRatingState = nil
    self.testClassRatingState = nil
    self.testSandbox = nil
    Print("Creator preview disabled. Showing your live placement and rating.")
    self:RefreshUI()
end

