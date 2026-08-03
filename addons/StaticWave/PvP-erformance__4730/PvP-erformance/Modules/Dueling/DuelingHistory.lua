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
local function AggregateSortValue(entry, key)
    if key == "winRate" then
        return WinRateRatio(entry)
    elseif key == "wins" then
        return entry.wins
    elseif key == "losses" then
        return entry.losses
    elseif key == "name" then
        return zo_strlower(entry.name or "")
    end

    return entry.total
end

local function CompareAggregateNumberHighToLow(left, right, key)
    local leftValue = AggregateSortValue(left, key)
    local rightValue = AggregateSortValue(right, key)
    if leftValue ~= rightValue then
        return leftValue > rightValue
    end
    return nil
end

local function SortAggregateEntries(entries, state)
    local key = state and state.key or "total"
    table.sort(entries, function(left, right)
        -- Name is deliberately the only alphabetical choice. Every numeric
        -- choice is descending, with an explicit tie-break chain so Lua never
        -- falls back to the non-deterministic order produced by `pairs`.
        if key == "name" then
            return zo_strlower(left.name or "") < zo_strlower(right.name or "")
        end

        local primary = CompareAggregateNumberHighToLow(left, right, key)
        if primary ~= nil then
            return primary
        end

        -- Keep the displayed W-L-D record itself in a consistent high-to-low
        -- order when two entries share the selected sort value.
        for _, tieKey in ipairs({ "total", "wins", "losses" }) do
            if tieKey ~= key then
                local tieBreak = CompareAggregateNumberHighToLow(left, right, tieKey)
                if tieBreak ~= nil then
                    return tieBreak
                end
            end
        end

        if left.draws ~= right.draws then
            return left.draws > right.draws
        end

        return zo_strlower(left.name or "") < zo_strlower(right.name or "")
    end)
end

function Dueling:GetViewEntries()
    local tab = self.ui and self.ui.activeTab or "recent"
    local searchText = self.ui and self.ui.searchText or ""
    local viewedSeason = self:GetViewedSeason()
    local history = viewedSeason and viewedSeason.history or {}
    local detailFilter = self.ui and self.ui.detailFilter

    if tab == "statistics" or tab == "settings" or tab == "commands" then
        return {}
    end

    if tab == "recent" then
        local entries = {}
        for index = #history, 1, -1 do
            local duel = history[index]
            if MatchesSearch(duel.opponent.displayName, searchText) then
                table.insert(entries, { kind = "duel", duel = duel })
            end
        end
        return entries
    end

    if detailFilter and detailFilter.tab == tab then
        local entries = {}
        for index = #history, 1, -1 do
            local duel = history[index]
            local key = tab == "opponents"
                and zo_strlower(duel.opponent.displayName or "Unknown @name")
                or zo_strlower(ClassDisplayForDuel(duel.opponent))
            if key == detailFilter.key then
                table.insert(entries, { kind = "duel", duel = duel })
            end
        end
        return entries
    end

    local grouped = {}
    for _, duel in ipairs(history) do
        local name
        if tab == "opponents" then
            name = duel.opponent.displayName or "Unknown @name"
            if not MatchesSearch(name, searchText) then
                name = nil
            end
        else
            name = ClassDisplayForDuel(duel.opponent)
        end

        if name then
            local key = zo_strlower(name)
            local entry = grouped[key]
            if not entry then
                entry = {
                    kind = "aggregate",
                    key = key,
                    name = name,
                    note = tab == "opponents" and self:GetOpponentNote(name) or nil,
                    wins = 0,
                    losses = 0,
                    draws = 0,
                    total = 0,
                }
                grouped[key] = entry
            end
            AddToStats(entry, duel)
        end
    end

    local entries = {}
    for _, entry in pairs(grouped) do
        table.insert(entries, entry)
    end
    local aggregateSort = self.ui and self.ui.aggregateSort and self.ui.aggregateSort[tab]
    SortAggregateEntries(entries, aggregateSort)
    return entries
end

function Dueling:SetActiveTab(tab)
    self:CreateUI()
    self.ui.activeTab = tab
    self.ui.detailFilter = nil
    self.ui.selectedDuel = nil
    self.ui.duelSummarySource = nil
    self:SetMainContentMode("dashboard")
    self.ui.page = 1
    self:OpenJournal()
end

function Dueling:OpenDetail(entry)
    if not entry or entry.kind ~= "aggregate" then
        return
    end
    self:CreateUI()

    self.ui.detailFilter = {
        tab = self.ui.activeTab,
        key = entry.key,
        name = entry.name,
    }
    self.ui.selectedDuel = nil
    self.ui.duelSummarySource = nil
    self:SetMainContentMode("opponentDetails")
    self.ui.page = 1
    self:OpenJournal()
end

function Dueling:CloseDetail()
    self.ui.detailFilter = nil
    self.ui.selectedDuel = nil
    self.ui.duelSummarySource = nil
    self:SetMainContentMode("dashboard")
    self.ui.page = 1
    self:RefreshUI()
end

function Dueling:GetOpponentPerformance(opponentKey)
    local performance = {
        name = "Unknown @name",
        wins = 0,
        losses = 0,
        draws = 0,
        total = 0,
        overallChange = 0,
        classChange = 0,
        lastFive = {},
        ratingValues = {},
    }
    local viewedSeason = self:GetViewedSeason()
    for _, duel in ipairs(viewedSeason and viewedSeason.history or {}) do
        local key = zo_strlower(duel.opponent and duel.opponent.displayName or "Unknown @name")
        if key == opponentKey then
            performance.name = duel.opponent and duel.opponent.displayName or performance.name
            AddToStats(performance, duel)
            performance.overallChange = performance.overallChange + (tonumber(duel.overallRatingChange) or 0)
            performance.classChange = performance.classChange + (tonumber(duel.classRatingChange) or 0)
            table.insert(performance.lastFive, duel.drawn and "D" or (duel.won and "W" or "L"))
            if #performance.lastFive > 5 then
                table.remove(performance.lastFive, 1)
            end
            table.insert(performance.ratingValues, performance.overallChange)
        end
    end

    local ranking = viewedSeason and viewedSeason.ranking
    if ranking and self:IsViewingActiveSeason() then
        ResetExpiredExhaustedMatchups(ranking, GetTimeStamp())
    end
    local fatigue = ranking and ranking.opponentFatigue and ranking.opponentFatigue[opponentKey] or 0
    performance.nextWinValue = ranking and ranking.diminishingOpponents and ranking.diminishingOpponents[opponentKey]
        and EXHAUSTED_MATCHUP_WIN_MULTIPLIER
        or ConsecutiveWinMultiplier(fatigue)
    return performance
end

function Dueling:RefreshOpponentPerformance(opponentKey)
    local performance = self:GetOpponentPerformance(opponentKey)
    local lines = self.ui.opponentPerformanceLines
    local titleWidth = self.ui.opponentPerformanceTitle:GetWidth()
    local titleCharacters = math.max(16, math.floor((tonumber(titleWidth) or 310) / 8.2))
    self.ui.opponentPerformanceTitle:SetText(TruncateCombatSourceName(performance.name, titleCharacters))
    lines[1]:SetText(string.format(
        "Record: %dW-%dL-%dD",
        performance.wins,
        performance.losses,
        performance.draws
    ))
    lines[2]:SetText(string.format("Win rate: %.1f%%", WinRatePercent(performance)))
    lines[3]:SetText(string.format("Overall rating change: %s", FormatSignedRating(performance.overallChange)))
    lines[4]:SetText(string.format("Class rating change: %s", FormatSignedRating(performance.classChange)))
    lines[5]:SetText(string.format("Current repeat fatigue: %.0f%%", performance.nextWinValue * 100))
    local function SetChangeColor(label, value)
        if value > 0 then
            label:SetColor(0.38, 0.88, 0.50, 1)
        elseif value < 0 then
            label:SetColor(1, 0.58, 0.54, 1)
        else
            label:SetColor(0.76, 0.82, 0.90, 1)
        end
    end
    lines[1]:SetColor(0.76, 0.82, 0.90, 1)
    lines[2]:SetColor(0.76, 0.82, 0.90, 1)
    SetChangeColor(lines[3], performance.overallChange)
    SetChangeColor(lines[4], performance.classChange)
    lines[5]:SetColor(0.76, 0.82, 0.90, 1)

    local coloredResults = {}
    for _, result in ipairs(performance.lastFive) do
        if result == "W" then
            table.insert(coloredResults, "|c59D66FW|r")
        elseif result == "L" then
            table.insert(coloredResults, "|cFF6B66L|r")
        else
            table.insert(coloredResults, "|cA8A8A8D|r")
        end
    end
    self.ui.opponentPerformanceLastFive:SetText("Last 5: " .. (#coloredResults > 0 and table.concat(coloredResults, "  ") or "N/A"))
    SetTrendGraphValues(
        self.ui.opponentPerformanceGraph,
        "OVERALL RATING CHANGE",
        performance.ratingValues,
        { 0.44, 0.78, 1 },
        function(value) return FormatSignedRating(value) end
    )
end

local function FormatCombatRate(total, durationSeconds)
    local value = tonumber(total)
    local duration = tonumber(durationSeconds) or 0
    if not value or value < 0 or duration <= 0 then
        return "N/A"
    end
    -- The surrounding column is explicitly labelled DPS or HPS, so a second
    -- "/s" suffix would add visual noise without conveying extra meaning.
    return FormatCombatNumber(value / duration)
end

local function TruncateCombatSourceName(name, maximumCharacters)
    local text = tostring(name or "Unknown effect")
    maximumCharacters = math.max(8, math.floor(tonumber(maximumCharacters) or 20))
    if string.len(text) <= maximumCharacters then
        return text
    end
    return string.sub(text, 1, math.max(5, maximumCharacters - 3)) .. "..."
end

-- DuelingDetails renders the compact saved summary. These display-only
-- helpers stay local in normal use, but are deliberately exposed through the
-- module's private context because that renderer loads after this file.
Private.FormatCombatRate = FormatCombatRate
Private.TruncateCombatSourceName = TruncateCombatSourceName

