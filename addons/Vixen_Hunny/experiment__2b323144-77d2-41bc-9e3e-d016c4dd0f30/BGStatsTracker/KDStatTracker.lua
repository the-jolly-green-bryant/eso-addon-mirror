-- Initialize the addon table
KDStatTracker = {}
KDStatTracker.name = "KDStatTracker"
KDStatTracker.version = "2.0"
KDStatTracker.defaults = {
    totalKills = 0,
    totalDeaths = 0,
    perCharKDA = {}, -- { [characterName] = { kills, deaths } }
    matchHistory = {}, -- { {matchId, kills, deaths, matchType, characterName}, ... }
    matchCounter = 0,  -- Persistent match counter
    duels = {

        totalDuels = 0,
        wins = 0,
        losses = 0,
        perCharStats = {}, -- { [characterName] = { duels, wins, losses, charactersFaced = {} }
    },
    deathSources = {},
    killSources = {}, -- { [charName] = { [abilityId] = { count = 0, lastVictim = "" } } }
}

-- Match type mapping (numeric values from ESO API)
KDStatTracker.matchTypes = {
    [1] = "Deathmatch",
    [2] = "Domination",
    [3] = "Chaosball",
    [4] = "Capture the Relic",
    [5] = "King of the Hill",
    [6] = "Murderball",
    [7] = "Crazy King",
}

-- Placeholder for BG zone IDs (replace with actual IDs)
local BG_ZONE_IDS = {
    0, -- Replace with actual BG zone IDs, e.g., 1234, 1235, etc.
}
function KDStatTracker:isDuelingStateChanged(eventCode, duelResult, wasResultofPlayer, opponentCharName, opponentDisplayName, _, _, _, _)
    local charName = GetUnitName("player")
    self.savedVars.duels.perCharStats[charName] = self.savedVars.duels.perCharStats[charName] or { duels = 0, wins = 0, losses = 0, charactersFaced = {} }
    self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName] = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName] or {wins = 0, losses = 0}
    if duelResult == DUEL_RESULT_WON and wasResultofPlayer then
        self.savedVars.duels.totalDuels = self.savedVars.duels.totalDuels + 1
        self.savedVars.duels.wins = self.savedVars.duels.wins + 1
        self.savedVars.duels.perCharStats[charName] = self.savedVars.duels.perCharStats[charName] or { duels = 0, wins = 0, losses = 0 }
        self.savedVars.duels.perCharStats[charName].duels = self.savedVars.duels.perCharStats[charName].duels + 1
        self.savedVars.duels.perCharStats[charName].wins = self.savedVars.duels.perCharStats[charName].wins + 1
        self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName] = {wins = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins + 1 or 1, losses = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses or 0}
        local kdratio = string.format("%.2f", self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins / self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses)

        d("KDStatTracker: Duel won against " .. opponentDisplayName:gsub("%s+", "") .. " (" .. opponentCharName:gsub("\r", "") .. "). Total Duels Against "..opponentDisplayName..": " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins + self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses .. ", Wins: " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins .. " W/L Ratio: |cff00cc"..kdratio.."|r")
    elseif duelResult == DUEL_RESULT_FORFEIT and wasResultofPlayer then
        self.savedVars.duels.totalDuels = self.savedVars.duels.totalDuels + 1
        self.savedVars.duels.losses = self.savedVars.duels.losses + 1
        local charName = GetUnitName("player")
        self.savedVars.duels.perCharStats[charName] = self.savedVars.duels.perCharStats[charName] or { duels = 0, wins = 0, losses = 0 }
        self.savedVars.duels.perCharStats[charName].duels = self.savedVars.duels.perCharStats[charName].duels + 1
        self.savedVars.duels.perCharStats[charName].losses = self.savedVars.duels.perCharStats[charName].losses + 1
        self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName] = {wins = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins or 0, losses = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses + 1 or 1}

        local kdratio = string.format("%.2f", self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins / self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses)

        d("KDStatTracker: Duel lost by forfeit against " .. opponentDisplayName:gsub("%s+", "") .. " (" .. opponentCharName:gsub("\r", "") .. "). Total Duels Against "..opponentDisplayName..": " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins + self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses .. ", Wins: " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins .. " W/L Ratio: |cff00cc"..kdratio.."|r")
    elseif duelResult == DUEL_RESULT_FORFEIT and not wasResultofPlayer then
        self.savedVars.duels.totalDuels = self.savedVars.duels.totalDuels + 1
        self.savedVars.duels.wins = self.savedVars.duels.wins + 1
        local charName = GetUnitName("player")
        self.savedVars.duels.perCharStats[charName] = self.savedVars.duels.perCharStats[charName] or { duels = 0, wins = 0, losses = 0 }
        self.savedVars.duels.perCharStats[charName].duels = self.savedVars.duels.perCharStats[charName].duels + 1
        self.savedVars.duels.perCharStats[charName].wins = self.savedVars.duels.perCharStats[charName].wins + 1
        self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName] = {wins = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins + 1 or 1, losses = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses or 0}
        local kdratio = string.format("%.2f", self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins / self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses)

        d("KDStatTracker: Duel won by forfeit against " .. opponentDisplayName:gsub("%s+", "") .. " (" .. opponentCharName:gsub("\r", "") .. "). Total Duels Against "..opponentDisplayName..": " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins + self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses .. ", Wins: " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins .. " W/L Ratio: |cff00cc"..kdratio.."|r")
    elseif duelResult == DUEL_RESULT_WON and not wasResultofPlayer then
        self.savedVars.duels.totalDuels = self.savedVars.duels.totalDuels + 1
        self.savedVars.duels.losses = self.savedVars.duels.losses + 1
        local charName = GetUnitName("player")
        self.savedVars.duels.perCharStats[charName] = self.savedVars.duels.perCharStats[charName] or { duels = 0, wins = 0, losses = 0 }
        self.savedVars.duels.perCharStats[charName].duels = self.savedVars.duels.perCharStats[charName].duels + 1
        self.savedVars.duels.perCharStats[charName].losses = self.savedVars.duels.perCharStats[charName].losses + 1
        self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName] = {wins = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins or 0, losses = self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses + 1 or 1}
        local kdratio = string.format("%.2f", self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins / self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses)

        d("KDStatTracker: Duel lost against " .. opponentDisplayName:gsub("%s+", "") .. " (" .. opponentCharName:gsub("\r", "") .. "). Total Duels Against "..zo_strformat("<<1>>", opponentDisplayName)..": " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins + self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].losses .. ", Wins: " .. self.savedVars.duels.perCharStats[charName].charactersFaced[opponentDisplayName].wins .. " W/L Ratio: |cff00cc"..kdratio.."|r")
    end
end
-- Handle Battleground kills
function KDStatTracker:OnBattlegroundKill(eventCode, _, killerUnitTag, _, _, victimUnitTag, _, killType, abilityId)
    local playerDisplayName = GetUnitDisplayName("player") or ""
    if killerUnitTag == playerDisplayName then
        return
    end
    if victimUnitTag ~= playerDisplayName then
        return
    end
    if killType == BATTLEGROUND_KILL_TYPE_KILLING_BLOW then
        
    local charName = GetUnitName("player")
    if not self.perCharKDA then
        d("KDStatTracker: Error - perCharKDA not initialized in OnBattlegroundKill")
        return
    end
    self.perCharKDA[charName] = self.perCharKDA[charName] or { kills = 0, deaths = 0 }
    
    self.currentMatchKills = (self.currentMatchKills or 0) + 1
    self.savedVars.totalKills = self.savedVars.totalKills + 1
    self.perCharKDA[charName].kills = self.perCharKDA[charName].kills + 1
    d("KDStatTracker: Kill recorded for " .. charName .. " (Killing Blow: " .. tostring(GetAbilityName(abilityId, "player")) .. ")")
end
end

-- Handle player death
function KDStatTracker:OnUnitDeathStateChanged(eventCode)
    local playerName = GetUnitName("player")
    local unitName = GetUnitName("player") or "Unknown"
    if unitName ~= playerName or not IsUnitPlayer("player") then
        return
    end
    if not IsActiveWorldBattleground() then
        return
    end
    if not self.perCharKDA then
        return
    end
    self.perCharKDA[playerName] = self.perCharKDA[playerName] or { kills = 0, deaths = 0 }
    
    self.currentMatchDeaths = (self.currentMatchDeaths or 0) + 1
    self.savedVars.totalDeaths = self.savedVars.totalDeaths + 1
    self.perCharKDA[playerName].deaths = self.perCharKDA[playerName].deaths + 1
    d("KDStatTracker: Death recorded for " .. playerName)
end

-- Handle activity finder status updates for match start/end
function KDStatTracker:OnActivityFinderStatusUpdate(eventCode, status, currentStatus)
        local matchTypeName = ""
        if status == BATTLEGROUND_STATE_PREGAME and currentStatus == BATTLEGROUND_STATE_STARTING then
            if not self.currentMatchId then
                self.savedVars.matchCounter = (self.savedVars.matchCounter or 0) + 1
                self.currentMatchId = GetCurrentBattlegroundId()
                self.currentMatchKills = 0
                self.currentMatchDeaths = 0
                self.currentMatchType = GetBattlegroundGameType(self.currentMatchId)
                self.currentCharacterName = GetUnitName("player")
                if self.currentMatchType == BATTLEGROUND_GAME_TYPE_CAPTURE_THE_FLAG then
                    matchTypeName = "Capture the Relic"
                elseif self.currentMatchType == BATTLEGROUND_GAME_TYPE_DEATHMATCH then
                    matchTypeName = "Deathmatch"
                elseif self.currentMatchType == BATTLEGROUND_GAME_TYPE_CRAZY_KING then
                    matchTypeName = "Crazy King"
                elseif self.currentMatchType == BATTLEGROUND_GAME_TYPE_DOMINATION then
                    matchTypeName = "Domination"
                elseif self.currentMatchType == BATTLEGROUND_GAME_TYPE_MURDERBALL then
                    matchTypeName = "Chaosball"
                elseif self.currentMatchType == BATTLEGROUND_GAME_TYPE_KING_OF_THE_HILL then
                    matchTypeName = "King of the Hill"
                end

                d("KDStatTracker: Match " .. self.currentMatchId .. " (" .. matchTypeName .. ") started")
            end
        elseif currentStatus == BATTLEGROUND_STATE_FINISHED or currentStatus == BATTLEGROUND_STATE_POSTGAME then
                local matchData = {
                    matchId = self.currentMatchId or 0,
                    kills = self.currentMatchKills or 0,
                    deaths = self.currentMatchDeaths or 0,
                    matchType = matchTypeName or 0,
                    characterName = GetUnitName("player")
                }
                table.insert(self.savedVars.matchHistory, matchData)
                if #self.savedVars.matchHistory > 20 then
                    table.remove(self.savedVars.matchHistory, 1)
                end
                local ratio = matchData.kills / (matchData.deaths > 0 and matchData.deaths or 1)
                local kdRatio = string.format("%.2f", ratio)
                d("KDStatTracker: Match " .. matchData.matchId .."("..matchTypeName..")".. " ended. K/D: " .. matchData.kills .. "/" .. matchData.deaths .. "K/D Ratio: " .. kdRatio)
                self.currentMatchId = nil
        end
    end

-- Show overall stats
function KDStatTracker:ShowOverallStats()
    local totalKills = self.savedVars.totalKills
    local totalDeaths = self.savedVars.totalDeaths
    local kdRatio = (totalDeaths > 0) and string.format("%.2f", totalKills / totalDeaths) or "N/A"
    d("KDStatTracker: Total Kills: " .. totalKills .. ", Deaths: " .. totalDeaths .. ", K/D Ratio: " .. kdRatio)
    for i, match in ipairs(self.savedVars.matchHistory) do
        local matchTypeName = self.matchTypes[match.matchType] or "Unknown (" .. tostring(match.matchType) .. ")"
        d("KDStatTracker: Match " .. match.matchId .. ": Type: " .. matchTypeName .. ", |c00ff00Kills: " .. match.kills .. "|r, |cff0000Deaths: " .. match.deaths .. "|r, |cff00ffK/D Ratio: " .. kdRatio .. "|r")
    end
end

-- Show per-character stats
function KDStatTracker:ShowDuelStats(displayName)
    local charName = GetUnitName("player")
    local charData = self.savedVars.duels.perCharStats[charName]
    if not charData then
        d("KDStatTracker: No duel data for character " .. charName)
        return
    end
    if displayName  == "" then
        displayName = nil
        kdRatio = string.format("%.2f", (charData.wins / (charData.losses > 0 and charData.losses or 1)) or "N/A")
        d("KDStatTracker: Showing overall duel stats for " .. charName .. " (no specific opponent)" .. " - Total Duels: " .. charData.duels .. ", |c00ff00Wins: " .. charData.wins .. "|r, |cff0000Losses: " .. charData.losses .. "|r, |cff00ffW/L Ratio: " .. kdRatio .. "|r")
    end
    if displayName and charData.charactersFaced and charData.charactersFaced[displayName] then
        if not string.find(displayName, "@", 1, true) then
            d("KDStatTracker: Please provide a valid display name with @, e.g., /duelstats @OpponentUsername")
            return
        end
        local facedData = charData.charactersFaced[displayName]
        local kdRatio = string.format("%.2f", (facedData.wins / (facedData.losses > 0 and facedData.losses or 1)) or "N/A")
        d("KDStatTracker: Duel Stats Against " .. displayName .. " - |c00ff00 Wins: " .. facedData.wins .. "|r, |cff0000Losses: " .. facedData.losses .. "|r, |cff00ffW/L Ratio: " .. kdRatio .. "|r")
    elseif displayName then
        d("|cff0000KDStatTracker: No duel data against " .. displayName .. ".|r")
    end
end
function KDStatTracker:ShowCharacterStats()
    local charName = GetUnitName("player")
    local charData = self.perCharKDA[charName] or { kills = 0, deaths = 0 }
    local kdRatio = (charData.deaths > 0) and string.format("%.2f", charData.kills / charData.deaths) or "N/A"
    d("KDStatTracker: Stats for " .. charName .. " - Kills: " .. charData.kills .. ", Deaths: " .. charData.deaths .. ", K/D Ratio: " .. kdRatio)
end
function KDStatTracker:OnCombatEvent(eventCode, ...)
    local result, isError, abilityName, abilityGraphic, abilityActionSlotType,
          sourceName, sourceType, targetName, targetType,
          hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId = ...

    local playerName = GetUnitName("player")
    local player = playerName and zo_strformat("<<1>>", playerName)
    local src = zo_strformat("<<1>>", sourceName or "")
    local tgt = zo_strformat("<<1>>", targetName or "")
    local abilityKey = tostring(abilityId or abilityName or "unknown")
    local abilityClean = zo_strformat("<<1>>", abilityName or "Unknown")
    -- Only care about deaths / killing blows
    if result ~= 2265 and result ~= ACTION_RESULT_TARGET_DEAD and result ~= ACTION_RESULT_KILLING_BLOW and result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP then
        return
    end
    if sourceType ~= 5 and targetType ~= 5 then
        return
    end
    if sourceType ~= 1 and targetType ~= 1 then
        return
    end
    -- d("KDStatTracker: Combat Event - Result: " .. tostring(result) .. ", Source: " .. src .. " ("..sourceUnitId.."), Target: " .. tgt .. " ("..targetUnitId.."), Ability: " .. abilityClean .. " (ID: " .. abilityKey .. ") SourceType: " .. tostring(sourceType) .. ", TargetType: " .. tostring(targetType))
        -- You killed an enemy player
        
        if src == player and tgt ~= player then
            self:RecordKill(abilityKey, abilityClean, tgt)
        -- You died to an enemy player
        elseif tgt == player and src ~= player then
            self:RecordDeath(abilityKey, abilityClean, src)
        end
    
end
function KDStatTracker:ShowKillStats()
    local charName = GetUnitName("player")
    local sources = self.savedVars.killSources[charName]
    if not sources then
        d("KDStatTracker: No kill data recorded yet for " .. charName)
        return
    end
-- Death tracking: only if killed by enemy player
    d("KDStatTracker: Top Kill Sources for " .. charName .. ":")
    local sorted = {}
    for abilityId, data in pairs(sources) do
        table.insert(sorted, { abilityId = abilityId, count = data.count, lastVictim = data.lastVictim })
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    for i = 1, #sorted do
        local abilityName = GetAbilityName(sorted[i].abilityId)
        d(i .. ". " .. abilityName .. " - " .. sorted[i].count .. " kills (last on " .. sorted[i].lastVictim .. ")")
    end
end
function KDStatTracker:RecordKill(abilityKey, abilityName, victimDisplayName)
    local charName = GetUnitName("player")
    self.savedVars.killSources[charName] = self.savedVars.killSources[charName] or {}
    local tbl = self.savedVars.killSources[charName]

    tbl[abilityKey] = tbl[abilityKey] or { count = 0, lastVictim = "", abilityName = abilityName }
    tbl[abilityKey].count = tbl[abilityKey].count + 1
    tbl[abilityKey].lastVictim = zo_strformat("<<1>>", victimDisplayName)

    d(("KD: Killed %s  with %s (ID: %d) (%d times) |cff00cc/killstats to see|r"):format(tbl[abilityKey].lastVictim, abilityName, abilityKey, tbl[abilityKey].count))
end

function KDStatTracker:RecordDeath(abilityKey, abilityName, killerDisplayName)
    local charName = GetUnitName("player")
    self.savedVars.deathSources[charName] = self.savedVars.deathSources[charName] or {}
    local tbl = self.savedVars.deathSources[charName]

    tbl[abilityKey] = tbl[abilityKey] or { count = 0, lastKiller = "", abilityName = abilityName }
    tbl[abilityKey].count = tbl[abilityKey].count + 1
    tbl[abilityKey].lastKiller = zo_strformat("<<1>>", killerDisplayName)

    d(("KD: Died to %s from %s (ID: %d) (%d times) Type |cff00cc/deathstats to see|r"):format(abilityName, tbl[abilityKey].lastKiller, abilityKey, tbl[abilityKey].count))
end
function KDStatTracker:ShowDeathStats()
    local charName = GetUnitName("player")
    local sources = self.savedVars.deathSources[charName]
    if not sources then
        d("KDStatTracker: No death data recorded yet for " .. charName)
        return
    end

    d("KDStatTracker: Top Death Sources for " .. charName .. ":")
    local sorted = {}
    for abilityId, data in pairs(sources) do
        table.insert(sorted, { abilityId = abilityId, count = data.count, lastKiller = data.lastKiller })
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    for i = 1, #sorted do
        local abilityName = GetAbilityName(sorted[i].abilityId)
        d(i .. ". " .. abilityName .. " - " .. sorted[i].count .. " times (last from " .. sorted[i].lastKiller .. ")")
    end
end
function KDStatTracker:ShowHelp()
    d("|ccf00cfKDStatTracker Commands:|r")
    d("/bgstats - Show overall Battleground stats")
    d("/bgcharstats - Show per-character Battleground stats")
    d("/logzone - Log current zone ID (useful for adding new BG zones)")
    d("/duelstats |cff00ff@(argument)|r - Show per-character Duel stats")
    d("/deathstats - Show what you've died to")
    d("/killstats - Show what has killed people the most")
end
-- Initialize addon
function KDStatTracker:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("KDStatTrackerVars", 1, nil, self.defaults)
    self.perCharKDA = self.savedVars.perCharKDA or {}
    EVENT_MANAGER:RegisterForEvent(self.name .. "_CombatEvent", EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
-- Make sure the namespace string matches the RegisterForEvent call above
    EVENT_MANAGER:RegisterForEvent(self.name .. "_BGKill", EVENT_BATTLEGROUND_KILL, function(...) self:OnBattlegroundKill(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_UnitDeath", EVENT_PLAYER_DEAD, function(...) self:OnUnitDeathStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_ActivityFinder", EVENT_BATTLEGROUND_STATE_CHANGED, function(...) self:OnActivityFinderStatusUpdate(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name .. "_Duel", EVENT_DUEL_FINISHED, function(...) self:isDuelingStateChanged(...) end)
    SLASH_COMMANDS["/bgstats"] = function() self:ShowOverallStats() end
    SLASH_COMMANDS["/bgcharstats"] = function() self:ShowCharacterStats() end
    SLASH_COMMANDS["/logzone"] = function()
        local zoneIndex = GetUnitZoneIndex("player")
        local zoneId = GetZoneId(zoneIndex)
        local zoneName = GetZoneName(zoneIndex)
        d("Current Zone - ID: " .. tostring(zoneId) .. ", Name: " .. zoneName)
    end
    SLASH_COMMANDS["/duelstats"] = function(arg) self:ShowDuelStats(arg) end
    SLASH_COMMANDS["/kdhelp"] = function() self:ShowHelp() end
    SLASH_COMMANDS["/killstats"] = function() KDStatTracker:ShowKillStats() end
    SLASH_COMMANDS["/deathstats"] = function() self:ShowDeathStats() end
    
end

-- Handle addon loading
function KDStatTracker:OnAddOnLoaded(eventCode, addonName)
    if addonName == self.name then
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
        self:Initialize()
        d("KDStatTracker: Addon initialized.") -- Debug message to confirm initialization
        d("KDStatTracker: Welcome to KDStatTracker! Use |cff00ff/kdhelp|r for commands. Thank you for using mine and |cff00ffSynkronist's|r Addon |ccf00cf~@Awh Lina|r") -- Welcome message
    end
end

-- Register addon load event
EVENT_MANAGER:RegisterForEvent(KDStatTracker.name, EVENT_ADD_ON_LOADED, function(...) KDStatTracker:OnAddOnLoaded(...) end)
