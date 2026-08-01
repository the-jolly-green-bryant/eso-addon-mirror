-- Battleboard_Stats.lua  (Player statistics aggregation)
-- Part of Battleboard.
-- Cross-file constants and helpers are read from Battleboard.__constants (aliased _x).

local BL = Battleboard
local _x = BL.__constants

local ALL_CHARACTERS_KEY = _x.ALL_CHARACTERS_KEY
local Num = _x.Num
local GetGameTypeFilterKey = _x.GetGameTypeFilterKey
local GetMatchTypeFilterKey = _x.GetMatchTypeFilterKey
local FormatBigNumber = _x.FormatBigNumber
local GetPlayerResultText = _x.GetPlayerResultText
local NormalizePlayerName = _x.NormalizePlayerName
local GetMatchCharacterKey = _x.GetMatchCharacterKey
local GetSelectedCharacterKey = _x.GetSelectedCharacterKey
local MatchPassesSelectedCharacter = _x.MatchPassesSelectedCharacter
local GetLocalPlayerForMatch = _x.GetLocalPlayerForMatch
local MatchPassesHistoryFilter = _x.MatchPassesHistoryFilter
local MatchCapturedOnDate = _x.MatchCapturedOnDate
local MatchPassesEncounterWindow = _x.MatchPassesEncounterWindow
local encounterClassOrder = _x.encounterClassOrder


local function GetSelectedCharacterWinRate()
    local total, wins = 0, 0

    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match) then
            local result = GetPlayerResultText(match)
            if result == "Win" then
                wins = wins + 1
                total = total + 1
            elseif result == "Loss" then
                total = total + 1
            end
        end
    end

    if total == 0 then return nil end
    return math.floor((wins / total) * 100 + 0.5)
end

local function FormatStatTableNumber(value, statKey, isAverage)
    value = Num(value)
    if isAverage then
        if statKey == "kills" or statKey == "deaths" then
            return string.format("%.1f", value)
        end
        if statKey == "kd" then
            return string.format("%.2f", value)
        end
        return FormatBigNumber(math.floor(value + 0.5))
    end
    if statKey == "kd" then
        return string.format("%.2f", value)
    end
    return FormatBigNumber(math.floor(value + 0.5))
end

local function GetStatPlayerForFilteredMatch(match)
    if not match then return nil end

    -- The stats table should follow the same filter strip as Match History.
    -- Once MatchPassesHistoryFilter(match) has accepted a match, the saved
    -- recorder/local-player row is the row we want, regardless of which
    -- character is currently logged in.
    local localPlayer = GetLocalPlayerForMatch(match)
    if localPlayer then
        return localPlayer
    end

    return nil
end

local function GetSelectedCharacterStatSummaryForDate(dateText)
    local stats = {
        kills = { label = "|t20:20:/esoui/art/compass/ava_murderball_neutral.dds|t", total = 0, max = 0 },
        deaths = { label = "|t20:20:/esoui/art/tutorial/poi_cemetary_complete.dds|t", total = 0, max = 0 },
        damage = { label = "|t20:20:/esoui/art/addons/gamepad/gp_mod_listing_category_combat.dds|t", total = 0, max = 0 },
        healing = { label = "|t20:20:/esoui/art/lfg/gamepad/lfg_roleicon_healer_down.dds|t", total = 0, max = 0 },
    }
    local count = 0

    for _, match in ipairs(BL.matches or {}) do
        -- MatchPassesHistoryFilter is the same filter strip used by Match History:
        -- character dropdown, match type, and objective subfilters.
        if MatchPassesHistoryFilter(match) and MatchCapturedOnDate(match, dateText) then
            local player = GetStatPlayerForFilteredMatch(match)
            if player then
                count = count + 1
                for key, data in pairs(stats) do
                    local value = Num(player[key])
                    data.total = data.total + value
                    if value > data.max then data.max = value end
                end
            end
        end
    end

    for _, data in pairs(stats) do
        data.average = count > 0 and (data.total / count) or nil
    end

    return stats, count
end


local function GetSelectedCharacterStatSummaryForAllTime()
    local stats = {
        kills = { label = "|t20:20:/esoui/art/compass/ava_murderball_neutral.dds|t", total = 0, max = 0 },
        deaths = { label = "|t20:20:/esoui/art/tutorial/poi_cemetary_complete.dds|t", total = 0, max = 0 },
        damage = { label = "|t20:20:/esoui/art/addons/gamepad/gp_mod_listing_category_combat.dds|t", total = 0, max = 0 },
        healing = { label = "|t20:20:/esoui/art/lfg/gamepad/lfg_roleicon_healer_down.dds|t", total = 0, max = 0 },
    }
    local count = 0

    for _, match in ipairs(BL.matches or {}) do
        -- Summary follows the shared filter strip, including the date-range dropdown.
        if MatchPassesHistoryFilter(match) then
            local player = GetStatPlayerForFilteredMatch(match)
            if player then
                count = count + 1
                for key, data in pairs(stats) do
                    local value = Num(player[key])
                    data.total = data.total + value
                    if value > data.max then data.max = value end
                end
            end
        end
    end

    for _, data in pairs(stats) do
        data.average = count > 0 and (data.total / count) or nil
    end

    return stats, count
end

local function GetSelectedCharacterMatchCountAndShare()
    local selectedKey = GetSelectedCharacterKey()
    local totalAllCharacters = 0
    local totalSelectedCharacter = 0

    for _, match in ipairs(BL.matches or {}) do
        totalAllCharacters = totalAllCharacters + 1
        if selectedKey == ALL_CHARACTERS_KEY or GetMatchCharacterKey(match) == selectedKey then
            totalSelectedCharacter = totalSelectedCharacter + 1
        end
    end

    local share = nil
    if totalAllCharacters > 0 then
        share = (totalSelectedCharacter / totalAllCharacters) * 100
    end

    return totalSelectedCharacter, share
end

local function GetSelectedCharacterWinLossCounts()
    local wins, losses, ties = 0, 0, 0
    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match, true) then
            local result = GetPlayerResultText(match)
            if result == "Win" then
                wins = wins + 1
            elseif result == "Loss" then
                losses = losses + 1
            else
                ties = ties + 1
            end
        end
    end
    return wins, losses, ties
end

local function GetTotalRecordCount()
    return #(BL.matches or {})
end

local function FormatKDValue(value)
    value = tonumber(value)
    if value == nil or value < 0 then return "--" end
    return string.format("%.2f", value)
end

local function FormatLocalMetricKDValue(value)
    value = tonumber(value)
    if value == nil then return "--" end
    return string.format("%.2f", value)
end

local function CalculateDisplayKD(kills, deaths)
    kills = Num(kills)
    deaths = Num(deaths)
    if kills <= 0 and deaths > 0 then
        return -deaths
    end
    if deaths <= 0 then
        return kills
    end
    return kills / deaths
end

local function GetSelectedCharacterKD()
    local kills, deaths, count = 0, 0, 0

    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match) then
            local player = GetStatPlayerForFilteredMatch(match)
            if player then
                kills = kills + Num(player.kills)
                deaths = deaths + Num(player.deaths)
                count = count + 1
            end
        end
    end

    if count <= 0 then return "--" end
    return FormatLocalMetricKDValue(CalculateDisplayKD(kills, deaths))
end

local function FormatContributionAverageValue(value)
    if value == nil then return "--" end
    return string.format("%d%%", math.floor(Num(value) + 0.5))
end

local function GetContributionPercentFromSavedData(contribution, key)
    if not contribution then return nil end

    -- Preferred path: use the raw local-player value and raw team total saved
    -- with the contribution row. This avoids parsing formatted percentage strings.
    local values = contribution.values
    local teamTotals = contribution.teamTotals
    if type(values) == "table" and type(teamTotals) == "table" then
        local value = Num(values[key])
        local total = Num(teamTotals[key])
        if total > 0 then
            return (value / total) * 100
        end
    end

    return nil
end

local function GetSelectedCharacterStatAveragesForAllTime()
    -- Returns average kills/deaths/damage/healing/score/KD per match across all filtered matches.
    local keys = { "kills", "deaths", "damage", "healing", "score", "kd" }
    local totals = {}
    for _, k in ipairs(keys) do totals[k] = 0 end
    local count = 0
    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match) then
            for _, player in ipairs(match.players or {}) do
                if player.isLocalPlayer then
                    count = count + 1
                    for _, k in ipairs(keys) do
                        if k == "kd" then
                            totals[k] = totals[k] + CalculateDisplayKD(player.kills, player.deaths)
                        else
                            totals[k] = totals[k] + Num(player[k])
                        end
                    end
                    break
                end
            end
        end
    end
    if count == 0 then return nil end
    local avgs = {}
    for _, k in ipairs(keys) do
        avgs[k] = totals[k] / count
    end
    return avgs, count
end

local function GetSelectedCharacterContributionAverages()
    local keys = { "score", "kills", "deaths", "damage", "healing" }
    local totals = {}
    local counts = {}

    for _, key in ipairs(keys) do
        totals[key] = 0
        counts[key] = 0
    end

    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match) then
            local contribution = match and match.playerContribution
            if contribution then
                for _, key in ipairs(keys) do
                    local percent = GetContributionPercentFromSavedData(contribution, key)
                    if percent ~= nil then
                        totals[key] = totals[key] + percent
                        counts[key] = counts[key] + 1
                    end
                end
            end
        end
    end

    local averages = {}
    for _, key in ipairs(keys) do
        if counts[key] > 0 then
            averages[key] = totals[key] / counts[key]
        else
            averages[key] = nil
        end
    end

    return averages
end


local function GetSelectedCharacterPersonalBests()
    -- Returns { kills={value, matchId}, deaths=..., damage=..., healing=..., score=..., kd=... }
    -- across all matches that pass the current character/filter selection.
    local keys = { "kills", "deaths", "damage", "healing", "score", "kd" }
    local bests = {}
    for _, key in ipairs(keys) do
        bests[key] = { value = nil, matchId = nil }
    end

    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match, true) then
            for _, player in ipairs(match.players or {}) do
                if player.isLocalPlayer then
                    for _, key in ipairs(keys) do
                        local v = key == "kd" and CalculateDisplayKD(player.kills, player.deaths) or Num(player[key])
                        if bests[key].value == nil or v > bests[key].value then
                            bests[key].value   = v
                            bests[key].matchId = match.id
                        end
                    end
                    break
                end
            end
        end
    end
    return bests
end

local function GetSelectedCharacterMatchCounts()
    -- Returns counts keyed by GetGameTypeFilterKey result, each with total/wins/losses.
    local counts = {}
    for _, k in ipairs({"DM","R","C","CK","DOM","Other"}) do
        counts[k] = { total = 0, wins = 0, losses = 0 }
    end
    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match) then
            local k = GetGameTypeFilterKey(match.gameType)
            local c = counts[k] or { total = 0, wins = 0, losses = 0 }
            c.total = c.total + 1
            local result = GetPlayerResultText(match)
            if result == "Win" then c.wins = c.wins + 1
            elseif result == "Loss" then c.losses = c.losses + 1 end
            counts[k] = c
        end
    end
    return counts
end

-- Generalised per-class, per-window aggregator for the Performance panel.
-- metric is one of: "kills", "kd", "damage", "healing".
-- mode is "Averages" or "Totals"; this panel deliberately ignores the global
-- date-range dropdown because its own columns are already date windows.
local function GetClassMetricForWindows(metric, mode)
    metric = metric or "kd"
    mode = mode == "Totals" and "Totals" or "Averages"
    local now     = Num(GetTimeStamp())
    local windows = {
        today   = { start = now - 86400      },
        week    = { start = now - 7 * 86400  },
        thirty  = { start = now - 30 * 86400 },
        overall = { start = 0                },
    }
    local data = {}
    for _, classSpec in ipairs(encounterClassOrder) do
        data[classSpec.key] = {}
        for wKey in pairs(windows) do
            data[classSpec.key][wKey] = { kills = 0, deaths = 0, damage = 0, healing = 0, matches = 0 }
        end
    end
    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match, true) then
            local capturedAt = Num(match and match.capturedAt)
            for _, player in ipairs(match.players or {}) do
                if player.isLocalPlayer then
                    local classKey = tonumber(player.classId)
                    if classKey and data[classKey] then
                        for wKey, window in pairs(windows) do
                            if capturedAt >= window.start then
                                local d = data[classKey][wKey]
                                d.kills   = d.kills   + Num(player.kills)
                                d.deaths  = d.deaths  + Num(player.deaths)
                                d.damage  = d.damage  + Num(player.damage)
                                d.healing = d.healing + Num(player.healing)
                                d.matches = d.matches + 1
                            end
                        end
                    end
                    break
                end
            end
        end
    end
    local result = {}
    for classKey, windowData in pairs(data) do
        result[classKey] = {}
        for wKey, d in pairs(windowData) do
            local text = "--"
            if d.matches > 0 then
                if mode == "Totals" then
                    if metric == "kd" then
                        text = FormatLocalMetricKDValue(CalculateDisplayKD(d.kills, d.deaths))
                    elseif metric == "kills" then
                        text = FormatBigNumber(d.kills)
                    elseif metric == "damage" then
                        text = FormatBigNumber(d.damage)
                    elseif metric == "healing" then
                        text = FormatBigNumber(d.healing)
                    end
                elseif metric == "kd" then
                    text = FormatLocalMetricKDValue(CalculateDisplayKD(d.kills, d.deaths))
                elseif metric == "kills" then
                    text = string.format("%.1f", d.kills / d.matches)
                elseif metric == "damage" then
                    text = FormatBigNumber(math.floor(d.damage / d.matches + 0.5))
                elseif metric == "healing" then
                    text = FormatBigNumber(math.floor(d.healing / d.matches + 0.5))
                end
            end
            result[classKey][wKey] = text
        end
    end
    return result
end

local function CalculateKD(kills, deaths)
    kills = Num(kills)
    deaths = Num(deaths)
    if kills <= 0 and deaths > 0 then
        return -deaths
    end
    if deaths <= 0 then
        return kills
    end
    return kills / deaths
end

local OBSERVATORY_WINDOWS = {
    { key = "today" },
    { key = "week" },
    { key = "thirty" },
    { key = "all" },
}

local OBSERVATORY_SPREAD_MODES = {
    "Popularity",
    "Survivability",
    "Deadliness",
    "Brutality",
    "Supportiveness",
}

local function CreateEncounterWindowData()
    local data = {
        matchCount = 0,
        players = {},
        characters = {},
        playerCount = 0,
        characterCount = 0,
        classTotals = {},
        classAverages = {},
        classCharacters = {},
        classCharacterCounts = {},
    }
    for _, classSpec in ipairs(encounterClassOrder or {}) do
        data.classTotals[classSpec.key] = 0
        data.classAverages[classSpec.key] = nil
        data.classCharacters[classSpec.key] = {}
        data.classCharacterCounts[classSpec.key] = 0
    end
    return data
end

local function AddPlayerToEncounterWindow(data, player)
    local displayName = tostring(player and player.displayName or "")
    if displayName ~= "" and not data.players[displayName] then
        data.players[displayName] = true
        data.playerCount = data.playerCount + 1
    end

    local characterName = NormalizePlayerName(player and player.characterName)
    if characterName ~= "" and not data.characters[characterName] then
        data.characters[characterName] = true
        data.characterCount = data.characterCount + 1
    end

    local classId = tonumber(player and player.classId) or 0
    if data.classTotals[classId] ~= nil then
        data.classTotals[classId] = data.classTotals[classId] + 1
        if characterName ~= "" and not data.classCharacters[classId][characterName] then
            data.classCharacters[classId][characterName] = true
            data.classCharacterCounts[classId] = data.classCharacterCounts[classId] + 1
        end
    end
end

local function CreateClassSpreadTotals()
    local totals = {}
    for _, mode in ipairs(OBSERVATORY_SPREAD_MODES) do
        totals[mode] = {}
        for _, classSpec in ipairs(encounterClassOrder or {}) do
            totals[mode][classSpec.key] = { total = 0, count = 0, label = classSpec.label }
        end
    end
    return totals
end

local function AddPlayerToClassSpreadTotals(totals, player)
    local classKey = tonumber(player and player.classId) or 0
    local kills = Num(player and player.kills)
    local deaths = Num(player and player.deaths)
    local damage = Num(player and player.damage)
    local healing = Num(player and player.healing)

    local row = totals.Survivability and totals.Survivability[classKey]
    if row then
        row.total = row.total + deaths
        row.count = row.count + 1
    end

    row = totals.Deadliness and totals.Deadliness[classKey]
    if row then
        row.total = row.total + kills
        row.count = row.count + 1
    end

    if healing <= damage then
        row = totals.Brutality and totals.Brutality[classKey]
        if row then
            row.total = row.total + damage
            row.count = row.count + 1
        end
    end

    if healing > damage then
        row = totals.Supportiveness and totals.Supportiveness[classKey]
        if row then
            row.total = row.total + healing
            row.count = row.count + 1
        end
    end
end

local function BuildClassSpreadRowsFromSummary(summary, mode)
    mode = mode or "Popularity"
    local rows = {}

    if mode == "Popularity" then
        local allData = summary and summary.encounter and summary.encounter.all
        local totalCharacters = Num(allData and allData.characterCount)

        for _, classSpec in ipairs(encounterClassOrder or {}) do
            local count = Num(allData and allData.classCharacterCounts and allData.classCharacterCounts[classSpec.key])
            local percent = totalCharacters > 0 and ((count / totalCharacters) * 100) or nil
            rows[#rows + 1] = {
                key = classSpec.key,
                label = classSpec.label,
                count = count,
                value = percent,
                text = percent and string.format("%d%%", math.floor(percent + 0.5)) or "--",
            }
        end

        table.sort(rows, function(a, b)
            if Num(a.count) == Num(b.count) then
                return string.lower(tostring(a.label or "")) < string.lower(tostring(b.label or ""))
            end
            return Num(a.count) > Num(b.count)
        end)

        return rows
    end

    local totals = summary and summary.spreadTotals and summary.spreadTotals[mode]
    for _, classSpec in ipairs(encounterClassOrder or {}) do
        local total = totals and totals[classSpec.key]
        local average = total and total.count > 0 and (total.total / total.count) or nil
        local text = "--"
        if average ~= nil then
            if mode == "Supportiveness" or mode == "Brutality" then
                text = FormatBigNumber(math.floor(average + 0.5))
            else
                text = string.format("%.2f", average)
            end
        end
        rows[#rows + 1] = {
            key = classSpec.key,
            label = classSpec.label,
            count = total and total.count or 0,
            value = average,
            text = text,
        }
    end

    table.sort(rows, function(a, b)
        local aHasValue = a.value ~= nil
        local bHasValue = b.value ~= nil
        if aHasValue ~= bHasValue then return aHasValue end
        if not aHasValue then
            return string.lower(tostring(a.label or "")) < string.lower(tostring(b.label or ""))
        end
        if Num(a.value) == Num(b.value) then
            return string.lower(tostring(a.label or "")) < string.lower(tostring(b.label or ""))
        end
        if mode == "Survivability" then
            return Num(a.value) < Num(b.value)
        end
        return Num(a.value) > Num(b.value)
    end)

    return rows
end

local function BuildClassInsightFromRows(spreadRows)
    local function firstValue(rows)
        for _, row in ipairs(rows or {}) do
            if row and row.value ~= nil then return row.key end
        end
        return nil
    end
    local function lastValue(rows)
        for i = #(rows or {}), 1, -1 do
            local row = rows[i]
            if row and row.value ~= nil then return row.key end
        end
        return nil
    end

    return {
        mostPopular = firstValue(spreadRows.Popularity),
        leastPopular = lastValue(spreadRows.Popularity),
        mostSurvivable = firstValue(spreadRows.Survivability),
        leastSurvivable = lastValue(spreadRows.Survivability),
        mostDeadly = firstValue(spreadRows.Deadliness),
        leastDeadly = lastValue(spreadRows.Deadliness),
        mostBrutal = firstValue(spreadRows.Brutality),
        leastBrutal = lastValue(spreadRows.Brutality),
        mostSupportive = firstValue(spreadRows.Supportiveness),
        leastSupportive = lastValue(spreadRows.Supportiveness),
    }
end

local function GetHallOfFameUserKey(player)
    local displayName = tostring(player and player.displayName or "")
    if displayName ~= "" then return displayName end
    local characterName = NormalizePlayerName(player and player.characterName)
    if characterName ~= "" then return characterName end
    return nil
end

local function ConsiderHallOfFamePlayer(bests, match, player)
    local userKey = GetHallOfFameUserKey(player)
    if not userKey then return end

    local classId = Num(player and player.classId)
    local rowValues = {
        damage = Num(player and player.damage),
        healing = Num(player and player.healing),
        kills = Num(player and player.kills),
        kd = CalculateKD(player and player.kills, player and player.deaths),
    }

    for key, value in pairs(rowValues) do
        local best = bests[key]
        if best == nil or value > best.value then
            bests[key] = {
                key = key,
                value = value,
                userKey = userKey,
                matchId = match and match.id,
                displayName = tostring(player and player.displayName or ""),
                characterName = tostring(player and player.characterName or ""),
                classId = classId,
            }
        end
    end
end

local function GetObservatoryCacheKey(todayText)
    local matches = BL.matches or {}
    local latestId = ""
    local latestCapturedAt = 0
    for _, match in ipairs(matches) do
        local capturedAt = Num(match and match.capturedAt)
        if capturedAt > latestCapturedAt then
            latestCapturedAt = capturedAt
            latestId = tostring(match and match.id or "")
        end
    end

    return table.concat({
        tostring(#matches),
        tostring(latestCapturedAt),
        latestId,
        tostring(GetSelectedCharacterKey and GetSelectedCharacterKey() or ""),
        tostring(BL.teamSizeFilter or "All"),
        tostring(BL.matchTypeFilter or "All"),
        tostring(BL.historyFilter or "All"),
        tostring(BL.dateRangeFilter or "All"),
        tostring(todayText or ""),
    }, "|")
end

local function GetObservatorySummary(todayText)
    local cacheKey = GetObservatoryCacheKey(todayText)
    if BL.observatoryStatsCache and BL.observatoryStatsCache.key == cacheKey then
        return BL.observatoryStatsCache.summary
    end

    local summary = {
        encounter = {},
        spreadTotals = CreateClassSpreadTotals(),
        spreadRows = {},
        insight = {},
        hall = {
            damage = nil,
            healing = nil,
            kills = nil,
            kd = nil,
        },
    }

    for _, window in ipairs(OBSERVATORY_WINDOWS) do
        summary.encounter[window.key] = CreateEncounterWindowData()
    end

    for _, match in ipairs(BL.matches or {}) do
        local passesHistory = MatchPassesHistoryFilter(match)
        if passesHistory then
            local players = match.players or {}
            for _, player in ipairs(players) do
                AddPlayerToClassSpreadTotals(summary.spreadTotals, player)
                ConsiderHallOfFamePlayer(summary.hall, match, player)
            end

            for _, window in ipairs(OBSERVATORY_WINDOWS) do
                local include = window.key == "all" or MatchPassesEncounterWindow(match, window.key, todayText)
                if include then
                    local data = summary.encounter[window.key]
                    data.matchCount = data.matchCount + 1
                    for _, player in ipairs(players) do
                        AddPlayerToEncounterWindow(data, player)
                    end
                end
            end
        end
    end

    for _, window in ipairs(OBSERVATORY_WINDOWS) do
        local data = summary.encounter[window.key]
        if data.matchCount > 0 then
            for _, classSpec in ipairs(encounterClassOrder or {}) do
                data.classAverages[classSpec.key] = data.classTotals[classSpec.key] / data.matchCount
            end
        end
    end

    for _, mode in ipairs(OBSERVATORY_SPREAD_MODES) do
        summary.spreadRows[mode] = BuildClassSpreadRowsFromSummary(summary, mode)
    end
    summary.insight = BuildClassInsightFromRows(summary.spreadRows)

    BL.observatoryStatsCache = {
        key = cacheKey,
        summary = summary,
    }

    return summary
end

local function BuildEncounterSummary(todayText)
    local summary = GetObservatorySummary(todayText)
    return summary and summary.encounter or {}
end

local function BuildClassSpreadRows(mode, todayText)
    mode = mode or "Popularity"
    local summary = GetObservatorySummary(todayText)
    return (summary and summary.spreadRows and summary.spreadRows[mode]) or {}
end

local function GetClassInsightSummary(todayText)
    local summary = GetObservatorySummary(todayText)
    return summary and summary.insight or {}
end

local function GetEncounterHallOfFame(todayText)
    local summary = GetObservatorySummary(todayText)
    return summary and summary.hall or {}
end

local function GetSelectedCharacterTimerSummary()
    local summary = {
        matchDuration = { total = 0, count = 0 },
        queueDuration = { total = 0, count = 0 },
        deadDuration = { total = 0, count = 0 },
        combatDuration = { total = 0, count = 0 },
    }

    for _, match in ipairs(BL.matches or {}) do
        if MatchPassesHistoryFilter(match) then
            local matchDuration = tonumber(match.localDurationSeconds)
            if matchDuration then
                local data = summary.matchDuration
                data.total = data.total + matchDuration
                data.count = data.count + 1
            end

            local queueDuration = tonumber(match.localQueueSeconds)
            if queueDuration then
                local data = summary.queueDuration
                data.total = data.total + queueDuration
                data.count = data.count + 1
            end

            local deadDuration = tonumber(match.localDeadSeconds)
            if deadDuration then
                local data = summary.deadDuration
                data.total = data.total + deadDuration
                data.count = data.count + 1
            end

            local combatDuration = tonumber(match.localCombatSeconds)
            if combatDuration then
                local data = summary.combatDuration
                data.total = data.total + combatDuration
                data.count = data.count + 1
            end
        end
    end

    for _, data in pairs(summary) do
        data.average = data.count > 0 and (data.total / data.count) or nil
    end

    return summary
end

-- Export stat functions consumed by the UI page.
do
    local _x = BL.__constants
    _x.GetSelectedCharacterWinRate = GetSelectedCharacterWinRate
    _x.FormatStatTableNumber = FormatStatTableNumber
    _x.GetStatPlayerForFilteredMatch = GetStatPlayerForFilteredMatch
    _x.GetSelectedCharacterStatSummaryForDate = GetSelectedCharacterStatSummaryForDate
    _x.GetSelectedCharacterStatSummaryForAllTime = GetSelectedCharacterStatSummaryForAllTime
    _x.GetSelectedCharacterMatchCountAndShare = GetSelectedCharacterMatchCountAndShare
    _x.GetSelectedCharacterWinLossCounts = GetSelectedCharacterWinLossCounts
    _x.GetTotalRecordCount = GetTotalRecordCount
    _x.GetSelectedCharacterKD = GetSelectedCharacterKD
    _x.FormatContributionAverageValue = FormatContributionAverageValue
    _x.GetContributionPercentFromSavedData = GetContributionPercentFromSavedData
    _x.GetSelectedCharacterStatAveragesForAllTime = GetSelectedCharacterStatAveragesForAllTime
    _x.GetSelectedCharacterContributionAverages = GetSelectedCharacterContributionAverages
    _x.GetSelectedCharacterPersonalBests = GetSelectedCharacterPersonalBests
    _x.GetSelectedCharacterMatchCounts = GetSelectedCharacterMatchCounts
    _x.GetClassMetricForWindows = GetClassMetricForWindows
    _x.BuildEncounterSummary = BuildEncounterSummary
    _x.BuildClassSpreadRows = BuildClassSpreadRows
    _x.GetClassInsightSummary = GetClassInsightSummary
    _x.GetEncounterHallOfFame = GetEncounterHallOfFame
    _x.GetSelectedCharacterTimerSummary = GetSelectedCharacterTimerSummary
end
