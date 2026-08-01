JensenRankedDuels = {}
JensenRankedDuels.name = "JensenRankedDuels"
JensenRankedDuels.displayName = "Jensen Ranked Duels"
JensenRankedDuels.version = "1.2.8"
JensenRankedDuels.menuBackgroundTexture = "/JensenRankedDuels/media/jrd_menu_background.dds"
JensenRankedDuels.menuBannerTexture = "/JensenRankedDuels/media/jrd_menu_banner.dds"

JensenRankedDuels.defaults =
{
    settings =
    {
        rankedMode = false,
        autoTrackUnranked = true,
        localQueueMode = "none",
        miniPanelVisible = true,
        openLeaderboardAfterReload = false,
        startingMmr = 1000,
        kFactor = 32,
        minimumDuelSeconds = 10,
        sameOpponentCooldownSeconds = 86400,
    },
    localStats =
    {
        wins = 0,
        losses = 0,
        matches = 0,
        currentStreak = 0,
        bestStreak = 0,
        opponents = {},
        history = {},
    },
    ranked =
    {
        players = {},
        matches = {},
    },
    activeDuel = nil,
    lastDiscordReport = nil,
    clientExports = {},
    clientReports = {},
    clientQueueExports = {},
    clientQueueRequests = {},
    clientQueueStatus =
    {
        status = "not_queued",
        message = "Not queued",
        opponentEso = "",
        inviteCommand = "",
    },
}

local JRD = JensenRankedDuels

local function JRDChat(message)
    d("|cC5A3FFJensen Ranked Duels|r " .. tostring(message))
end

function JRD:SafeString(value)
    if value == nil or value == "" then
        return "Unknown"
    end

    return tostring(value)
end

function JRD:GetNow()
    if GetTimeStamp ~= nil then
        return GetTimeStamp()
    end

    return 0
end

function JRD:GetReadableTimestamp(timestamp)
    local dateText = tostring(timestamp)

    if GetDateStringFromTimestamp ~= nil then
        dateText = GetDateStringFromTimestamp(timestamp)
    end

    if GetTimeString ~= nil then
        dateText = dateText .. " " .. GetTimeString()
    end

    return dateText
end

function JRD:GetLocalAccount()
    if GetDisplayName ~= nil then
        return self:SafeString(GetDisplayName())
    end

    return "LocalPlayer"
end

function JRD:GetLocalCharacter()
    if GetUnitName ~= nil then
        return self:SafeString(GetUnitName("player"))
    end

    return "LocalCharacter"
end

function JRD:GetLocalClassName()
    if GetUnitClass ~= nil then
        local className = GetUnitClass("player")
        return self:SafeString(className)
    end

    return "Unknown"
end

function JRD:GetActiveDuelDuration(now)
    if self.saved.activeDuel ~= nil and self.saved.activeDuel.startedAt ~= nil then
        return now - self.saved.activeDuel.startedAt
    end

    return 0
end

function JRD:GetOpponentLocalRecord(opponentAccount, opponentCharacter)
    local key = self:SafeString(opponentAccount)

    if key == "Unknown" and opponentCharacter ~= nil then
        key = self:SafeString(opponentCharacter)
    end

    if self.saved.localStats.opponents[key] == nil then
        self.saved.localStats.opponents[key] =
        {
            accountName = key,
            characterName = self:SafeString(opponentCharacter),
            wins = 0,
            losses = 0,
            matches = 0,
            currentStreak = 0,
            bestStreak = 0,
            lastDuelTimestamp = 0,
            lastDuelReadableTimestamp = "",
        }
    else
        if opponentCharacter ~= nil and opponentCharacter ~= "" then
            self.saved.localStats.opponents[key].characterName = opponentCharacter
        end
    end

    return self.saved.localStats.opponents[key]
end

function JRD:RecordUnrankedResult(localWon, opponentCharacterName, opponentDisplayName, opponentClassId)
    if self.saved.settings.autoTrackUnranked ~= true then
        return
    end

    local now = self:GetNow()
    local readableTimestamp = self:GetReadableTimestamp(now)
    local duration = self:GetActiveDuelDuration(now)

    local opponentAccount = self:SafeString(opponentDisplayName)
    local opponentCharacter = self:SafeString(opponentCharacterName)
    local opponentClass = self:SafeString(opponentClassId)

    local localStats = self.saved.localStats
    local opponentStats = self:GetOpponentLocalRecord(opponentAccount, opponentCharacter)

    localStats.matches = localStats.matches + 1
    opponentStats.matches = opponentStats.matches + 1

    if localWon == true then
        localStats.wins = localStats.wins + 1
        localStats.currentStreak = localStats.currentStreak + 1

        if localStats.currentStreak > localStats.bestStreak then
            localStats.bestStreak = localStats.currentStreak
        end

        opponentStats.wins = opponentStats.wins + 1
        opponentStats.currentStreak = opponentStats.currentStreak + 1

        if opponentStats.currentStreak > opponentStats.bestStreak then
            opponentStats.bestStreak = opponentStats.currentStreak
        end
    else
        localStats.losses = localStats.losses + 1
        localStats.currentStreak = 0

        opponentStats.losses = opponentStats.losses + 1
        opponentStats.currentStreak = 0
    end

    opponentStats.lastDuelTimestamp = now
    opponentStats.lastDuelReadableTimestamp = readableTimestamp

    local resultText = "LOSS"

    if localWon == true then
        resultText = "WIN"
    end

    local match =
    {
        timestamp = now,
        readableTimestamp = readableTimestamp,
        durationSeconds = duration,
        localAccount = self:GetLocalAccount(),
        localCharacter = self:GetLocalCharacter(),
        localClass = self:GetLocalClassName(),
        opponentAccount = opponentAccount,
        opponentCharacter = opponentCharacter,
        opponentClass = opponentClass,
        localWon = localWon,
        resultText = resultText,
    }

    table.insert(localStats.history, match)

    self:RefreshDuelLog()

    JRDChat("Unranked duel result " .. resultText .. " vs " .. opponentAccount .. ". Your record vs them is " .. tostring(opponentStats.wins) .. "W " .. tostring(opponentStats.losses) .. "L. Overall " .. tostring(localStats.wins) .. "W " .. tostring(localStats.losses) .. "L. Duration " .. tostring(duration) .. "s.")
end

function JRD:GetRankedPlayer(accountName, characterName, className)
    accountName = self:SafeString(accountName)

    if self.saved.ranked.players[accountName] == nil then
        self.saved.ranked.players[accountName] =
        {
            accountName = accountName,
            characterName = self:SafeString(characterName),
            className = self:SafeString(className),
            mmr = self.saved.settings.startingMmr,
            wins = 0,
            losses = 0,
            matches = 0,
            currentStreak = 0,
            bestStreak = 0,
            lastOpponents = {},
        }
    else
        if characterName ~= nil and characterName ~= "" then
            self.saved.ranked.players[accountName].characterName = characterName
        end

        if className ~= nil and className ~= "" then
            self.saved.ranked.players[accountName].className = className
        end
    end

    return self.saved.ranked.players[accountName]
end

function JRD:GetAbuseMultiplier(player, opponentAccount)
    local now = self:GetNow()
    local history = player.lastOpponents[opponentAccount]

    if history == nil then
        return 1
    end

    local secondsSinceLast = now - history.lastMatchTime

    if secondsSinceLast > self.saved.settings.sameOpponentCooldownSeconds then
        return 1
    end

    if history.count == 1 then
        return 0.25
    end

    if history.count == 2 then
        return 0.10
    end

    return 0
end

function JRD:UpdateOpponentHistory(player, opponentAccount)
    local now = self:GetNow()
    local history = player.lastOpponents[opponentAccount]

    if history == nil then
        player.lastOpponents[opponentAccount] =
        {
            count = 1,
            lastMatchTime = now,
        }
        return
    end

    local secondsSinceLast = now - history.lastMatchTime

    if secondsSinceLast > self.saved.settings.sameOpponentCooldownSeconds then
        history.count = 1
    else
        history.count = history.count + 1
    end

    history.lastMatchTime = now
end

function JRD:CalculateMmrGain(winnerMmr, loserMmr, multiplier)
    local k = self.saved.settings.kFactor
    local expected = 1 / (1 + zo_pow(10, (loserMmr - winnerMmr) / 400))
    local rawGain = k * (1 - expected) * multiplier
    local gain = zo_floor(rawGain)

    if gain < 1 and multiplier > 0 then
        gain = 1
    end

    return gain
end

function JRD:CreateMatchId(timestamp, accountA, accountB)
    local cleanA = tostring(accountA):gsub("[^%w]", "")
    local cleanB = tostring(accountB):gsub("[^%w]", "")
    return "JRDPCNA" .. tostring(timestamp) .. cleanA .. cleanB
end


function JRD:CleanCodeName(value)
    value = string.upper(tostring(value or ""))
    value = string.gsub(value, "@", "")
    value = string.gsub(value, "[^A-Z0-9]", "")
    return value
end

function JRD:SimpleChecksum(payload)
    local hash = 7

    for i = 1, string.len(payload) do
        hash = ((hash * 31) + string.byte(payload, i)) % 1000000
    end

    return hash
end

function JRD:GenerateMatchCode(winnerAccount, opponentAccount, timestamp)
    local secondBucket = timestamp or GetTimeStamp()
    local winnerClean = self:CleanCodeName(winnerAccount)
    local opponentClean = self:CleanCodeName(opponentAccount)
    local payload = "JRD5|" .. tostring(secondBucket) .. "|" .. winnerClean .. "|" .. opponentClean
    local code = self:SimpleChecksum(payload) % 100000

    return string.format("%05d", code)
end

function JRD:BuildDiscordReportCommand(opponentAccount, duration, timestamp)
    opponentAccount = tostring(opponentAccount or "")

    if opponentAccount == "" or opponentAccount == "nil" then
        opponentAccount = "@OpponentESOName"
    end

    if string.sub(opponentAccount, 1, 1) ~= "@" then
        opponentAccount = "@" .. opponentAccount
    end

    local winnerAccount = self:GetLocalAccount()
    local code = self:GenerateMatchCode(winnerAccount, opponentAccount, timestamp)
    local discordOpponent = string.gsub(opponentAccount, "^@", "")

    return "/report_win opponent_eso:" .. discordOpponent .. " code:" .. code
end


function JRD:EscapeClientField(value)
    local text = tostring(value or "")
    text = string.gsub(text, "|", "")
    text = string.gsub(text, "\n", " ")
    text = string.gsub(text, "\r", " ")
    return text
end

function JRD:GetClientReportKey(winnerAccount, opponentAccount, code, timestamp)
    return self:EscapeClientField(winnerAccount) .. "_" .. self:EscapeClientField(opponentAccount) .. "_" .. tostring(code) .. "_" .. tostring(timestamp)
end

function JRD:QueueClientReport(report)
    if self.saved.clientExports == nil then
        self.saved.clientExports = {}
    end

    if self.saved.clientReports == nil then
        self.saved.clientReports = {}
    end

    local key = tostring(report.clientReportKey or "")
    if key == "" then
        return
    end

    if self.saved.clientReports[key] ~= nil then
        return
    end

    local exportLine =
        "JRDREPORT|" ..
        self:EscapeClientField(key) .. "|" ..
        self:EscapeClientField(report.winnerAccount) .. "|" ..
        self:EscapeClientField(report.opponentAccount) .. "|" ..
        self:EscapeClientField(report.code) .. "|" ..
        self:EscapeClientField(report.timestamp) .. "|" ..
        self:EscapeClientField(report.durationSeconds)

    self.saved.clientReports[key] =
    {
        key = key,
        winnerAccount = report.winnerAccount,
        opponentAccount = report.opponentAccount,
        code = report.code,
        timestamp = report.timestamp,
        durationSeconds = report.durationSeconds,
        command = report.command,
        uploadedByClient = false,
    }

    table.insert(self.saved.clientExports, exportLine)

    while #self.saved.clientExports > 50 do
        table.remove(self.saved.clientExports, 1)
    end
end

function JRD:SaveLastDiscordReport(opponentAccount, duration)
    local timestamp = self:GetNow()
    local winnerAccount = self:GetLocalAccount()
    local command = self:BuildDiscordReportCommand(opponentAccount, duration, timestamp)
    local code = string.match(command, "code:([^%s]+)") or ""
    local key = self:GetClientReportKey(winnerAccount, opponentAccount, code, timestamp)

    self.saved.lastDiscordReport =
    {
        clientReportKey = key,
        winnerAccount = tostring(winnerAccount),
        opponentAccount = tostring(opponentAccount),
        durationSeconds = duration,
        code = code,
        command = command,
        timestamp = timestamp,
    }

    self:QueueClientReport(self.saved.lastDiscordReport)
end

function JRD:PrintLastDiscordReport()
    if self.saved.lastDiscordReport == nil then
        JRDChat("No ranked win report saved yet. Win a ranked duel first.")
        return
    end

    JRDChat("Copy this into Discord:")
    d(self.saved.lastDiscordReport.command)
end

function JRD:RecordRankedResult(localWon, opponentCharacterName, opponentDisplayName, opponentClassId)
    if self.saved.settings.rankedMode ~= true then
        return
    end

    local now = self:GetNow()
    local readableTimestamp = self:GetReadableTimestamp(now)
    local duration = self:GetActiveDuelDuration(now)

    if duration < self.saved.settings.minimumDuelSeconds then
        JRDChat("Ranked duel lasted " .. tostring(duration) .. " seconds. Minimum is " .. tostring(self.saved.settings.minimumDuelSeconds) .. " seconds, so no Discord report command was created.")
        return
    end

    local localAccount = self:GetLocalAccount()
    local localCharacter = self:GetLocalCharacter()
    local localClass = self:GetLocalClassName()

    local opponentAccount = self:SafeString(opponentDisplayName)
    local opponentCharacter = self:SafeString(opponentCharacterName)
    local opponentClass = self:SafeString(opponentClassId)

    local localPlayer = self:GetRankedPlayer(localAccount, localCharacter, localClass)
    local opponentPlayer = self:GetRankedPlayer(opponentAccount, opponentCharacter, opponentClass)

    local winner = nil
    local loser = nil

    if localWon == true then
        winner = localPlayer
        loser = opponentPlayer
    else
        winner = opponentPlayer
        loser = localPlayer
    end

    local multiplier = self:GetAbuseMultiplier(winner, loser.accountName)
    local mmrChange = self:CalculateMmrGain(winner.mmr, loser.mmr, multiplier)

    local winnerBefore = winner.mmr
    local loserBefore = loser.mmr

    winner.mmr = winner.mmr + mmrChange
    loser.mmr = loser.mmr - mmrChange

    if loser.mmr < 100 then
        loser.mmr = 100
    end

    winner.wins = winner.wins + 1
    winner.matches = winner.matches + 1
    winner.currentStreak = winner.currentStreak + 1

    if winner.currentStreak > winner.bestStreak then
        winner.bestStreak = winner.currentStreak
    end

    loser.losses = loser.losses + 1
    loser.matches = loser.matches + 1
    loser.currentStreak = 0

    self:UpdateOpponentHistory(winner, loser.accountName)
    self:UpdateOpponentHistory(loser, winner.accountName)

    local match =
    {
        matchId = self:CreateMatchId(now, localAccount, opponentAccount),
        timestamp = now,
        readableTimestamp = readableTimestamp,
        durationSeconds = duration,
        localAccount = localAccount,
        localCharacter = localCharacter,
        localClass = localClass,
        opponentAccount = opponentAccount,
        opponentCharacter = opponentCharacter,
        opponentClass = opponentClass,
        winnerAccount = winner.accountName,
        loserAccount = loser.accountName,
        winnerMmrBefore = winnerBefore,
        loserMmrBefore = loserBefore,
        winnerMmrAfter = winner.mmr,
        loserMmrAfter = loser.mmr,
        mmrChange = mmrChange,
        abuseMultiplier = multiplier,
        verifiedByDiscord = false,
    }

    table.insert(self.saved.ranked.matches, match)

    if mmrChange == 0 then
        JRDChat("Ranked duel saved. No MMR awarded because repeat opponent protection applied.")
    else
        JRDChat("Ranked duel saved. Winner " .. winner.accountName .. " gained " .. tostring(mmrChange) .. " local MMR. Official MMR still belongs in Discord.")
    end

    if localWon == true then
        self:SaveLastDiscordReport(opponentAccount, duration)
        JRDChat("|c66FF66Ranked win detected.|r Copy this exact command into Discord:")
        d(self.saved.lastDiscordReport.command)
        d("This includes a 5 digit code. Do not reuse old codes. The opponent name is printed without @ so Discord will not turn it into a mention.")
    else
        JRDChat("Ranked loss recorded locally. If your opponent reports this match incorrectly, use /flag_match in Discord.")
    end
end

function JRD:OnDuelCountdown(eventCode, startTimeMS)
    self.saved.activeDuel =
    {
        startedAt = self:GetNow(),
        startTimeMS = startTimeMS,
        localAccount = self:GetLocalAccount(),
        localCharacter = self:GetLocalCharacter(),
    }
end

function JRD:OnDuelFinished(eventCode, result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    local localWon = nil

    if DUEL_RESULT_FORFEIT ~= nil and result == DUEL_RESULT_FORFEIT then
        JRDChat("Duel ended by forfeit. No duel was logged and no ranked report was created.")
        self.saved.activeDuel = nil
        return
    end

    if DUEL_RESULT_WON ~= nil and result == DUEL_RESULT_WON then
        localWon = wasLocalPlayersResult == true
    end

    if localWon == nil then
        JRDChat("Duel ended by draw, cancel, forfeit, or unreadable result. No duel was logged and no ranked report was created.")
        self.saved.activeDuel = nil
        return
    end

    self:RecordUnrankedResult(localWon, opponentCharacterName, opponentDisplayName, opponentClassId)
    self:RecordRankedResult(localWon, opponentCharacterName, opponentDisplayName, opponentClassId)

    self.saved.activeDuel = nil
end

function JRD:PrintStats()
    local stats = self.saved.localStats

    JRDChat("Local duel stats")
    d("Overall " .. tostring(stats.wins) .. "W " .. tostring(stats.losses) .. "L")
    d("Total duels " .. tostring(stats.matches))
    d("Current streak " .. tostring(stats.currentStreak))
    d("Best streak " .. tostring(stats.bestStreak))
    d("These are local unranked stats saved on your computer.")
end

function JRD:PrintRankedStats()
    local player = self:GetRankedPlayer(self:GetLocalAccount(), self:GetLocalCharacter(), self:GetLocalClassName())

    JRDChat("Local ranked preview")
    d("MMR " .. tostring(player.mmr))
    d("Wins " .. tostring(player.wins))
    d("Losses " .. tostring(player.losses))
    d("Matches " .. tostring(player.matches))
    d("Official MMR should be tracked in Discord.")
end

function JRD:GetSortedOpponents()
    local list = {}

    for accountName, opponent in pairs(self.saved.localStats.opponents) do
        table.insert(list, opponent)
    end

    table.sort(list, function(a, b)
        if a.matches == b.matches then
            return a.wins > b.wins
        end

        return a.matches > b.matches
    end)

    return list
end

function JRD:PrintRivals()
    local list = self:GetSortedOpponents()

    JRDChat("Local rival board")

    if #list == 0 then
        d("No local duel data yet.")
        return
    end

    for index = 1, zo_min(10, #list) do
        local opponent = list[index]
        d(tostring(index) .. ". " .. opponent.accountName .. "  " .. tostring(opponent.wins) .. "W " .. tostring(opponent.losses) .. "L  Duels " .. tostring(opponent.matches))
    end
end

function JRD:PrintRival(name)
    if name == nil or name == "" then
        JRDChat("Use /jrd rival @PlayerName")
        return
    end

    local opponent = self.saved.localStats.opponents[name]

    if opponent == nil then
        JRDChat("No local duel record found for " .. tostring(name))
        return
    end

    JRDChat("Local record vs " .. opponent.accountName)
    d("Wins " .. tostring(opponent.wins))
    d("Losses " .. tostring(opponent.losses))
    d("Duels " .. tostring(opponent.matches))
    d("Best streak " .. tostring(opponent.bestStreak))
    d("Last duel " .. tostring(opponent.lastDuelReadableTimestamp))
end

function JRD:PrintHistory()
    JRDChat("Recent local duels")

    local history = self.saved.localStats.history
    local total = #history

    if total == 0 then
        d("No local duel history yet.")
        return
    end

    local first = zo_max(1, total - 9)

    for index = total, first, -1 do
        local match = history[index]
        d(match.readableTimestamp .. "  " .. match.resultText .. " vs " .. match.opponentAccount .. "  Duration " .. tostring(match.durationSeconds) .. "s")
    end
end

function JRD:PrintRankedHistory()
    JRDChat("Recent local ranked duels")

    local history = self.saved.ranked.matches
    local total = #history

    if total == 0 then
        d("No local ranked duel history yet.")
        return
    end

    local first = zo_max(1, total - 9)

    for index = total, first, -1 do
        local match = history[index]
        d(match.readableTimestamp .. "  " .. match.winnerAccount .. " beat " .. match.loserAccount .. "  MMR " .. tostring(match.mmrChange) .. "  Duration " .. tostring(match.durationSeconds) .. "s")
    end
end

function JRD:SetRankedMode(value)
    self.saved.settings.rankedMode = value == true

    if self.saved.settings.rankedMode then
        JRDChat("|c66FF66Ranked mode is ON.|r Ranked duel wins will print a Discord report command.")
        d("Ranked status: ON")
    else
        JRDChat("|cFF6666Ranked mode is OFF.|r Duels will still be tracked locally as unranked.")
        d("Ranked status: OFF")
    end

    self:RefreshMenu()
    self:RefreshMiniPanel()
end

function JRD:ResetData()
    self.saved.localStats =
    {
        wins = 0,
        losses = 0,
        matches = 0,
        currentStreak = 0,
        bestStreak = 0,
        opponents = {},
        history = {},
    }

    self.saved.ranked =
    {
        players = {},
        matches = {},
    }

    self.saved.activeDuel = nil
    self.saved.lastDiscordReport = nil
    self.saved.clientExports = {}
    self.saved.clientReports = {}
    self:RefreshMenu()
    self:RefreshMiniPanel()
    self:RefreshDuelLog()
    JRDChat("All local duel data reset.")
end




function JRD:GetSyncedQueueData()
    if JRD_QUEUE_DATA ~= nil then
        return JRD_QUEUE_DATA
    end

    return nil
end

function JRD:GetClientQueueStatusText()
    local data = self:GetSyncedQueueData()

    if data ~= nil and data.message ~= nil then
        local text = tostring(data.message or "Not queued")

        if data.invite_command ~= nil and tostring(data.invite_command) ~= "" then
            text = text .. "\n" .. tostring(data.invite_command)
        end

        if data.updated_at_local ~= nil then
            text = text .. "\nLast synced: " .. tostring(data.updated_at_local)
        end

        return text
    end

    return "Not queued.\nClick Join Queue to send a queue request to the client."
end

function JRD:GetClientQueueOneLineText()
    local data = self:GetSyncedQueueData()

    if data ~= nil and data.message ~= nil then
        return tostring(data.message)
    end

    return "Not queued"
end

function JRD:GetClientQueueRequestKey(action, timestamp)
    return self:EscapeClientField(self:GetLocalAccount()) .. "_" .. tostring(action) .. "_" .. tostring(timestamp)
end

function JRD:QueueClientQueueRequest(action)
    action = string.lower(tostring(action or "status"))
    local timestamp = self:GetNow()
    local account = self:GetLocalAccount()
    local key = self:GetClientQueueRequestKey(action, timestamp)

    if self.saved.clientQueueExports == nil then
        self.saved.clientQueueExports = {}
    end

    if self.saved.clientQueueRequests == nil then
        self.saved.clientQueueRequests = {}
    end

    if self.saved.clientQueueRequests[key] ~= nil then
        return
    end

    local exportLine =
        "JRDQUEUE|" ..
        self:EscapeClientField(key) .. "|" ..
        self:EscapeClientField(account) .. "|" ..
        self:EscapeClientField(action) .. "|" ..
        self:EscapeClientField(timestamp)

    self.saved.clientQueueRequests[key] =
    {
        key = key,
        account = account,
        action = action,
        timestamp = timestamp,
    }

    table.insert(self.saved.clientQueueExports, exportLine)

    while #self.saved.clientQueueExports > 25 do
        table.remove(self.saved.clientQueueExports, 1)
    end

    if action == "join" then
        self:SetRankedMode(true)
        self.saved.settings.localQueueMode = "competitive"
        JRDChat("Queue request saved. Reloading UI so the client can join queue.")
    elseif action == "leave" then
        self.saved.settings.localQueueMode = "none"
        JRDChat("Leave queue request saved. Reloading UI so the client can leave queue.")
    else
        JRDChat("Queue status request saved. Reloading UI so the client can check queue.")
    end

    self:RefreshMenu()
    self:RefreshMiniPanel()

    if zo_callLater ~= nil then
        zo_callLater(function()
            if ReloadUI ~= nil then
                ReloadUI("ingame")
            end
        end, 600)
    elseif ReloadUI ~= nil then
        ReloadUI("ingame")
    else
        JRDChat("Type /reloadui now to send this queue request to the client.")
    end
end


function JRD:GetOfficialRankName(mmr)
    mmr = tonumber(mmr or 0) or 0

    if mmr >= 1700 then
        return "Champion"
    elseif mmr >= 1600 then
        return "Legate"
    elseif mmr >= 1500 then
        return "Centurion"
    elseif mmr >= 1400 then
        return "Praetorian"
    elseif mmr >= 1300 then
        return "Gladiator"
    elseif mmr >= 1200 then
        return "Veteran"
    elseif mmr >= 1100 then
        return "Duelist"
    elseif mmr >= 1000 then
        return "Contender"
    end

    return "New Recruit"
end

function JRD:GetRankedModeText()
    if self.saved.settings.rankedMode == true then
        return "|c66FF66ON|r"
    end

    return "|cFF6666OFF|r"
end

function JRD:GetLocalQueueText()
    local mode = self.saved.settings.localQueueMode or "none"

    if mode == "competitive" then
        return "|c66FF661v1 Competitive|r"
    elseif mode == "unranked" then
        return "|c66CCFF1v1 Unranked|r"
    end

    return "|cCCCCCCNot queued|r"
end

function JRD:SetLocalQueueMode(mode)
    self.saved.settings.localQueueMode = mode or "none"

    if mode == "competitive" then
        self:SetRankedMode(true)
        JRDChat("Local queue panel set to 1v1 Competitive.")
    elseif mode == "unranked" then
        self:SetRankedMode(false)
        JRDChat("Local queue panel set to 1v1 Unranked.")
    else
        self.saved.settings.localQueueMode = "none"
        JRDChat("Local queue status cleared.")
    end

    self:RefreshMenu()
    self:RefreshMiniPanel()
end

function JRD:GetQueueSayName()
    local account = self:GetLocalAccount()

    if account == nil or account == "" then
        return "@Unknown"
    end

    return account
end

function JRD:OpenSayQueueMessage(mode)
    local playerName = self:GetQueueSayName()
    local message = ""

    if mode == "competitive" or mode == "ranked" then
        self:SetLocalQueueMode("competitive")
        message = "Ranked Duels: " .. playerName .. " is looking for a ranked 1v1 duel. Whisper me or invite me to duel."
    elseif mode == "unranked" then
        self:SetLocalQueueMode("unranked")
        message = "Ranked Duels: " .. playerName .. " is looking for an unranked 1v1 duel. Whisper me or invite me to duel."
    else
        self:SetLocalQueueMode("none")
        message = "Ranked Duels: " .. playerName .. " has left the local duel queue."
    end

    StartChatInput("/s " .. message)
    JRDChat("Local /say queue message is ready. Press Enter to send it.")
end

function JRD:GetMenuStatusText()
    local stats = self.saved.localStats
    local player = self:GetRankedPlayer(self:GetLocalAccount(), self:GetLocalCharacter(), self:GetLocalClassName())
    local lastReport = "No ranked win report saved yet."

    if self.saved.lastDiscordReport ~= nil and self.saved.lastDiscordReport.command ~= nil then
        lastReport = self.saved.lastDiscordReport.command
    end

    return
        "|cFFFFFFPlayer Panel|r\n" ..
        "Ranked mode: " .. self:GetRankedModeText() .. "\n" ..
        "Queue panel: " .. self:GetLocalQueueText() .. "\n" ..
        "Client queue: " .. self:GetClientQueueOneLineText() .. "\n" ..
        "Local preview MMR: " .. tostring(player.mmr) .. "\n" ..
        "Local preview rank: " .. self:GetOfficialRankName(player.mmr) .. "\n\n" ..
        "|cFFFFFFLocal Duel Stats|r\n" ..
        "Overall: " .. tostring(stats.wins) .. "W " .. tostring(stats.losses) .. "L\n" ..
        "Total duels: " .. tostring(stats.matches) .. "\n" ..
        "Current streak: " .. tostring(stats.currentStreak) .. "\n" ..
        "Best streak: " .. tostring(stats.bestStreak) .. "\n\n" ..
        "|cFFFFFFLast Discord Report|r\n" ..
        lastReport
end

function JRD:GetMenuFaqText()
    return
        "|cFFFFFFActivity Finder Style Queue|r\n" ..
        "1v1 Competitive means ranked mode ON and official MMR through Discord.\n" ..
        "1v1 Unranked means ranked mode OFF and local duel tracking only.\n\n" ..
        "|cFFFFFFImportant Limitation|r\n" ..
        "ESO addons cannot run a shared live matchmaking server by themselves.\n" ..
        "Official queue and official MMR currently live in Discord.\n\n" ..
        "|cFFFFFFCompetitive Flow|r\n" ..
        "1. Register in Discord with your exact ESO @ name\n" ..
        "2. Click 1v1 Competitive or type /jrd ranked on\n" ..
        "3. Duel another registered player for longer than 10 seconds\n" ..
        "4. Winner copies the addon report command with code\n\n" ..
        "|cFFFFFFMenu Commands|r\n" ..
        "/jrd toggle opens or closes this menu\n" ..
        "/jrd mini shows or hides the mini panel\n" ..
        "/jrd opens or closes this menu\n" ..
        "/jrd report prints your last report command"
end


function JRD:GetSyncedLeaderboardData()
    if JRD_LEADERBOARD_DATA == nil then
        return nil
    end

    return JRD_LEADERBOARD_DATA
end

function JRD:GetSyncedLeaderboardText(limit)
    local data = self:GetSyncedLeaderboardData()
    limit = limit or 10

    if data == nil or data.players == nil or #data.players == 0 then
        return "No synced leaderboard data yet.\n\nRun the Jensen Ranked Duels Client, let it sync, then /reloadui."
    end

    local text = ""
    local updated = tostring(data.updated_at_local or data.updated_at_iso or "unknown")

    text = text .. "Last synced: " .. updated .. "\n\n"

    for index = 1, zo_min(limit, #data.players) do
        local player = data.players[index]
        local placement = ""

        if tonumber(player.placement_matches or 0) < 5 then
            placement = "  Placement " .. tostring(player.placement_matches or 0) .. "/5"
        end

        text = text ..
            tostring(player.rank or index) .. ". " ..
            tostring(player.eso_account or "?") .. "  " ..
            tostring(player.mmr or 0) .. " MMR  " ..
            tostring(player.wins or 0) .. "W " ..
            tostring(player.losses or 0) .. "L" ..
            placement .. "\n"
    end

    return text
end

function JRD:PrintSyncedLeaderboard()
    JRDChat("Official synced leaderboard")
    d(self:GetSyncedLeaderboardText(10))
end

function JRD:CreateLeaderboardWindow()
    if self.leaderboardWindow ~= nil then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("JensenRankedDuelsLeaderboardWindow")
    window:SetDimensions(560, 520)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 80)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local backdrop = wm:CreateControl("JensenRankedDuelsLeaderboardBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    backdrop:SetCenterColor(0.03, 0.02, 0.06, 0.94)
    backdrop:SetEdgeColor(0.75, 0.58, 0.22, 1)

    local title = self:CreateMenuLabel(window, "JensenRankedDuelsLeaderboardTitle", "|cFFDD66Official Synced Leaderboard|r", 20, 18, 440, 34, "ZoFontWinH2")
    local body = self:CreateMenuLabel(window, "JensenRankedDuelsLeaderboardBody", "", 25, 65, 510, 370, "ZoFontGame")

    self:CreateMenuButton(window, "JensenRankedDuelsLeaderboardPrintButton", "Print", 25, 455, 96, 34, function()
        self:PrintSyncedLeaderboard()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsLeaderboardHelpButton", "Client Info", 135, 455, 120, 34, function()
        JRDChat("Leaderboard sync info")
        d("The Windows client downloads the official leaderboard.")
        d("The client writes LeaderboardData.lua into the addon folder.")
        d("Use /reloadui after the client syncs to refresh the in game board.")
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsLeaderboardCloseButton", "Close", 438, 455, 96, 34, function()
        window:SetHidden(true)
    end)

    self.leaderboardWindow =
    {
        window = window,
        body = body,
    }

    self:RefreshLeaderboardWindow()
end

function JRD:RefreshLeaderboardWindow()
    if self.leaderboardWindow == nil or self.leaderboardWindow.body == nil then
        return
    end

    self.leaderboardWindow.body:SetText(self:GetSyncedLeaderboardText(12))
end

function JRD:OpenLeaderboardWindow()
    self:CreateLeaderboardWindow()
    self:RefreshLeaderboardWindow()
    self.leaderboardWindow.window:SetHidden(false)
end

function JRD:RequestLeaderboardWindow()
    if self.saved ~= nil and self.saved.settings ~= nil then
        self.saved.settings.openLeaderboardAfterReload = true
    end

    JRDChat("Reloading UI to load the newest synced leaderboard.")

    if zo_callLater ~= nil then
        zo_callLater(function()
            if ReloadUI ~= nil then
                ReloadUI("ingame")
            end
        end, 300)
    elseif ReloadUI ~= nil then
        ReloadUI("ingame")
    else
        JRDChat("Type /reloadui now to refresh the leaderboard.")
    end
end


function JRD:CreateMenuLabel(parent, name, text, x, y, width, height, font)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    label:SetDimensions(width, height)
    label:SetFont(font or "ZoFontGame")
    label:SetText(text or "")
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    return label
end

function JRD:CreateMenuButton(parent, name, text, x, y, width, height, callback)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    button:SetDimensions(width, height)
    button:SetFont("ZoFontGameBold")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 1, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetHandler("OnClicked", callback)
    return button
end

function JRD:RefreshMenu()
    if self.menu == nil then
        return
    end

    if self.menu.statusLabel ~= nil then
        self.menu.statusLabel:SetText(self:GetMenuStatusText())
    end

    if self.menu.faqLabel ~= nil then
        self.menu.faqLabel:SetText(self:GetMenuFaqText())
    end

    if self.menu.titleLabel ~= nil then
        self.menu.titleLabel:SetText("|cC5A3FFJensen Ranked Duels|r  v" .. tostring(self.version))
    end

    if self.menu.rankStatusLabel ~= nil then
        self.menu.rankStatusLabel:SetText("|cFFFFFFRanked Mode:|r " .. self:GetRankedModeText())
    end

    if self.menu.queueStatusLabel ~= nil then
        self.menu.queueStatusLabel:SetText("|cFFFFFFQueue Panel:|r " .. self:GetLocalQueueText())
    end

    if self.menu.clientQueueLabel ~= nil then
        self.menu.clientQueueLabel:SetText("|cFFFFFFClient Queue:|r " .. self:GetClientQueueOneLineText())
    end

    if self.leaderboardWindow ~= nil then
        self:RefreshLeaderboardWindow()
    end
end

function JRD:PrintDiscordQueueHelp()
    JRDChat("Discord queue commands")
    d("/queue_join")
    d("/queue_leave")
    d("Queue is optional. Ranked duels can happen anytime two registered players agree.")
end

function JRD:PrintDiscordRankedCommands()
    JRDChat("Discord ranked commands")
    d("/register eso_account:@YourName")
    d("/leaderboard")
    d("/profile")
    d("/queue_join")
    d("/queue_leave")
    d("/report_win opponent_eso:@OpponentName code:12345")
    d("/flag_match match_id:JRD123 reason:Reason here")
    d("/refresh_rank")
end

function JRD:CreateActivityCard(parent, name, title, body, x, y)
    local wm = WINDOW_MANAGER
    local card = wm:CreateControl(name, parent, CT_BACKDROP)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    card:SetDimensions(315, 160)
    card:SetCenterColor(0.07, 0.06, 0.10, 0.92)
    card:SetEdgeColor(0.42, 0.34, 0.85, 0.85)

    self:CreateMenuLabel(card, name .. "Title", title, 14, 12, 285, 28, "ZoFontWinH3")
    self:CreateMenuLabel(card, name .. "Body", body, 14, 47, 285, 95, "ZoFontGame")
    return card
end


function JRD:GetDuelLogRows()
    local rows = {}
    local localStats = self.saved.localStats or {}
    local opponents = localStats.opponents or {}
    local history = localStats.history or {}

    table.insert(rows, "|cFFFFFFOpponent Records|r")

    local opponentCount = 0

    for opponentName, record in pairs(opponents) do
        opponentCount = opponentCount + 1
        table.insert(rows, tostring(record.wins or 0) .. "W " .. tostring(record.losses or 0) .. "L vs " .. tostring(record.accountName or opponentName))
    end

    if opponentCount == 0 then
        table.insert(rows, "No opponent records yet.")
    end

    table.insert(rows, "")
    table.insert(rows, "|cFFFFFFRecent Duel Log|r")

    local total = #history

    if total == 0 then
        table.insert(rows, "No duel history yet.")
    else
        for index = total, 1, -1 do
            local match = history[index]
            local result = match.resultText or "DUEL"
            local opponent = match.opponentAccount or "Unknown"
            local duration = tostring(match.durationSeconds or 0)
            local when = match.readableTimestamp or ""
            table.insert(rows, result .. " vs " .. opponent .. "  " .. duration .. "s  " .. when)
        end
    end

    return rows
end

function JRD:GetDuelLogPageText()
    local rows = self:GetDuelLogRows()
    local pageSize = 16
    local totalRows = #rows
    local maxPage = zo_max(1, zo_ceil(totalRows / pageSize))

    self.logPage = tonumber(self.logPage or 1) or 1

    if self.logPage < 1 then
        self.logPage = 1
    end

    if self.logPage > maxPage then
        self.logPage = maxPage
    end

    local startIndex = ((self.logPage - 1) * pageSize) + 1
    local endIndex = zo_min(totalRows, startIndex + pageSize - 1)
    local text = "|cFFFFFFPage " .. tostring(self.logPage) .. " of " .. tostring(maxPage) .. "|r\n\n"

    for index = startIndex, endIndex do
        text = text .. rows[index] .. "\n"
    end

    return text
end

function JRD:RefreshDuelLog()
    if self.duelLog == nil then
        return
    end

    if self.duelLog.textLabel ~= nil then
        self.duelLog.textLabel:SetText(self:GetDuelLogPageText())
    end

    if self.duelLog.summaryLabel ~= nil then
        local stats = self.saved.localStats or {}
        self.duelLog.summaryLabel:SetText("Overall: " .. tostring(stats.wins or 0) .. "W " .. tostring(stats.losses or 0) .. "L  Total duels: " .. tostring(stats.matches or 0))
    end
end

function JRD:CreateDuelLogWindow()
    if self.duelLog ~= nil then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("JensenRankedDuelsDuelLogWindow")
    window:SetDimensions(680, 520)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 95)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local backdrop = wm:CreateControl("JensenRankedDuelsDuelLogBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    backdrop:SetCenterColor(0.03, 0.02, 0.06, 0.96)
    backdrop:SetEdgeColor(0.75, 0.58, 0.22, 1)

    local title = self:CreateMenuLabel(window, "JensenRankedDuelsDuelLogTitle", "|cC5A3FFJensen Ranked Duels Log|r", 20, 16, 560, 32, "ZoFontWinH2")
    local summary = self:CreateMenuLabel(window, "JensenRankedDuelsDuelLogSummary", "", 20, 52, 620, 24, "ZoFontGameBold")

    local textLabel = self:CreateMenuLabel(window, "JensenRankedDuelsDuelLogText", "", 20, 86, 640, 350, "ZoFontGame")

    self:CreateMenuButton(window, "JensenRankedDuelsDuelLogPrevButton", "Scroll Up", 70, 455, 120, 34, function()
        self.logPage = (tonumber(self.logPage or 1) or 1) - 1
        self:RefreshDuelLog()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsDuelLogNextButton", "Scroll Down", 210, 455, 130, 34, function()
        self.logPage = (tonumber(self.logPage or 1) or 1) + 1
        self:RefreshDuelLog()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsDuelLogResetButton", "Reset Local", 360, 455, 120, 34, function()
        self:ResetData()
        self.logPage = 1
        self:RefreshDuelLog()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsDuelLogCloseButton", "Close", 500, 455, 100, 34, function()
        window:SetHidden(true)
    end)

    self.duelLog =
    {
        window = window,
        textLabel = textLabel,
        summaryLabel = summary,
    }

    self.logPage = 1
    self:RefreshDuelLog()
end

function JRD:OpenDuelLog()
    self:CreateDuelLogWindow()
    self:RefreshDuelLog()
    self.duelLog.window:SetHidden(false)
end

function JRD:ToggleDuelLog()
    self:CreateDuelLogWindow()
    self:RefreshDuelLog()
    self.duelLog.window:SetHidden(not self.duelLog.window:IsHidden())
end



function JRD:RefreshMiniPanel()
    if self.miniPanel == nil then
        return
    end

    if self.miniPanel.statusLabel ~= nil then
        self.miniPanel.statusLabel:SetText("|cFFFFFFRanked:|r " .. self:GetRankedModeText())
    end
end

function JRD:CreateMiniPanel()
    if self.miniPanel ~= nil then
        return
    end

    local wm = WINDOW_MANAGER
    local panel = wm:CreateTopLevelWindow("JensenRankedDuelsMiniPanel")
    panel:SetDimensions(335, 92)
    panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 24, 165)
    panel:SetMovable(true)
    panel:SetMouseEnabled(true)
    panel:SetClampedToScreen(true)
    panel:SetHidden(self.saved.settings.miniPanelVisible == false)

    local backdrop = wm:CreateControl("JensenRankedDuelsMiniPanelBackdrop", panel, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
    backdrop:SetCenterColor(0.03, 0.02, 0.06, 0.88)
    backdrop:SetEdgeColor(0.75, 0.58, 0.22, 1)

    local title = self:CreateMenuLabel(panel, "JensenRankedDuelsMiniPanelTitle", "|cC5A3FFJensen Ranked Duels|r", 10, 8, 265, 24, "ZoFontGameBold")
    local status = self:CreateMenuLabel(panel, "JensenRankedDuelsMiniPanelStatus", "", 10, 32, 160, 22, "ZoFontGame")

    self:CreateMenuButton(panel, "JensenRankedDuelsMiniPanelOnButton", "Ranked On", 10, 58, 98, 24, function()
        self:SetRankedMode(true)
    end)

    self:CreateMenuButton(panel, "JensenRankedDuelsMiniPanelOffButton", "Ranked Off", 116, 58, 98, 24, function()
        self:SetRankedMode(false)
    end)

    self:CreateMenuButton(panel, "JensenRankedDuelsMiniPanelMenuButton", "Menu", 222, 58, 66, 24, function()
        self:ToggleMenu()
    end)

    self:CreateMenuButton(panel, "JensenRankedDuelsMiniPanelHideButton", "X", 302, 8, 22, 22, function()
        self.saved.settings.miniPanelVisible = false
        panel:SetHidden(true)
        JRDChat("Mini panel hidden. Type /jrd mini to show it again.")
    end)

    self.miniPanel =
    {
        window = panel,
        statusLabel = status,
    }

    self:RefreshMiniPanel()
end

function JRD:ShowMiniPanel()
    self:CreateMiniPanel()
    self.saved.settings.miniPanelVisible = true
    self.miniPanel.window:SetHidden(false)
    self:RefreshMiniPanel()
end

function JRD:HideMiniPanel()
    self:CreateMiniPanel()
    self.saved.settings.miniPanelVisible = false
    self.miniPanel.window:SetHidden(true)
end

function JRD:ToggleMiniPanel()
    self:CreateMiniPanel()

    if self.miniPanel.window:IsHidden() then
        self:ShowMiniPanel()
    else
        self:HideMiniPanel()
    end
end


function JRD:CreateMenu()
    if self.menu ~= nil then
        return
    end

    local wm = WINDOW_MANAGER
    local window = wm:CreateTopLevelWindow("JensenRankedDuelsMainMenu")
    window:SetDimensions(820, 700)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 110)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)

    local backdrop = wm:CreateControl("JensenRankedDuelsMainMenuBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    backdrop:SetCenterColor(0.03, 0.02, 0.06, 0.88)
    backdrop:SetEdgeColor(0.55, 0.43, 0.95, 1)

    local backgroundImage = wm:CreateControl("JensenRankedDuelsMenuBackgroundImage", window, CT_TEXTURE)
    backgroundImage:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backgroundImage:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    backgroundImage:SetTexture(self.menuBackgroundTexture)
    backgroundImage:SetAlpha(0.18)
    backgroundImage:SetDrawLayer(DL_BACKGROUND)

    local darkOverlay = wm:CreateControl("JensenRankedDuelsMenuDarkOverlay", window, CT_BACKDROP)
    darkOverlay:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    darkOverlay:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    darkOverlay:SetCenterColor(0.02, 0.015, 0.035, 0.58)
    darkOverlay:SetEdgeColor(0, 0, 0, 0)
    darkOverlay:SetDrawLayer(DL_BACKGROUND)

    local bannerFrame = wm:CreateControl("JensenRankedDuelsMenuBannerFrame", window, CT_BACKDROP)
    bannerFrame:SetDimensions(640, 320)
    bannerFrame:SetAnchor(BOTTOM, window, TOP, 0, -12)
    bannerFrame:SetCenterColor(0.02, 0.015, 0.035, 0.92)
    bannerFrame:SetEdgeColor(0.75, 0.58, 0.22, 1)

    local bannerImage = wm:CreateControl("JensenRankedDuelsMenuBannerImage", bannerFrame, CT_TEXTURE)
    bannerImage:SetAnchor(TOPLEFT, bannerFrame, TOPLEFT, 6, 6)
    bannerImage:SetAnchor(BOTTOMRIGHT, bannerFrame, BOTTOMRIGHT, -6, -6)
    bannerImage:SetTexture(self.menuBannerTexture)
    bannerImage:SetAlpha(1)

    local title = self:CreateMenuLabel(window, "JensenRankedDuelsMainMenuTitle", "", 24, 18, 620, 40, "ZoFontWinH1")

    self:CreateMenuButton(window, "JensenRankedDuelsCloseButton", "X", 768, 18, 32, 32, function()
        window:SetHidden(true)
    end)

    local rankStatus = self:CreateMenuLabel(window, "JensenRankedDuelsRankStatus", "", 24, 58, 350, 26, "ZoFontGameBold")
    local queueStatus = self:CreateMenuLabel(window, "JensenRankedDuelsQueueStatus", "", 390, 58, 380, 26, "ZoFontGameBold")

    self:CreateActivityCard(
        window,
        "JensenRankedDuelsCompetitiveCard",
        "|cFFDD661v1 Competitive|r",
        "Ranked duel mode.\nTurns ranked mode ON.\nUse Discord queue or duel anyone who agrees.",
        24,
        95
    )

    self:CreateActivityCard(
        window,
        "JensenRankedDuelsUnrankedCard",
        "|c66CCFF1v1 Unranked|r",
        "Casual duel mode.\nTurns ranked mode OFF.\nTracked locally only.",
        370,
        95
    )

    self:CreateMenuButton(window, "JensenRankedDuelsJoinCompetitiveButton", "Say Ranked", 44, 265, 116, 34, function()
        self:OpenSayQueueMessage("competitive")
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsClientJoinQueueButton", "Join Queue", 170, 265, 116, 34, function()
        self:QueueClientQueueRequest("join")
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsClientLeaveQueueButton", "Leave Queue", 296, 265, 116, 34, function()
        self:QueueClientQueueRequest("leave")
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsJoinUnrankedButton", "Say Unranked", 422, 265, 116, 34, function()
        self:OpenSayQueueMessage("unranked")
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsQueueStatusButton", "Queue Status", 548, 265, 116, 34, function()
        JRDChat("Client queue status")
        d(self:GetClientQueueStatusText())
    end)

    local clientQueueLabel = self:CreateMenuLabel(window, "JensenRankedDuelsClientQueueLabel", "|cFFFFFFClient Queue:|r " .. self:GetClientQueueOneLineText(), 24, 305, 745, 34, "ZoFontGameBold")

    local statusHeader = self:CreateMenuLabel(window, "JensenRankedDuelsStatusHeader", "|cFFFFFFStatus|r", 24, 340, 330, 26, "ZoFontWinH3")
    local statusLabel = self:CreateMenuLabel(window, "JensenRankedDuelsStatusLabel", "", 24, 370, 345, 235, "ZoFontGame")

    local faqHeader = self:CreateMenuLabel(window, "JensenRankedDuelsFaqHeader", "|cFFFFFFFAQ and Commands|r", 410, 340, 360, 26, "ZoFontWinH3")
    local faqLabel = self:CreateMenuLabel(window, "JensenRankedDuelsFaqLabel", "", 410, 370, 370, 235, "ZoFontGame")

    self:CreateMenuButton(window, "JensenRankedDuelsRankedOnButton", "Ranked On", 24, 625, 96, 34, function()
        self:SetRankedMode(true)
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsRankedOffButton", "Ranked Off", 130, 625, 96, 34, function()
        self:SetRankedMode(false)
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsReportButton", "Last Report", 236, 625, 96, 34, function()
        self:PrintLastDiscordReport()
        self:RefreshMenu()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsDuelLogButton", "Duel Log", 342, 625, 96, 34, function()
        self:OpenDuelLog()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsCommandsButton", "Commands", 448, 625, 96, 34, function()
        self:PrintHelp()
        self:PrintDiscordRankedCommands()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsStatsButton", "Stats", 554, 625, 96, 34, function()
        self:PrintStats()
        self:PrintRankedStats()
        self:RefreshMenu()
    end)

    self:CreateMenuButton(window, "JensenRankedDuelsLeaderboardButton", "Leaderboard", 660, 625, 116, 34, function()
        self:RequestLeaderboardWindow()
    end)

    local footer = self:CreateMenuLabel(window, "JensenRankedDuelsFooter", "Open or close this menu with /jrd toggle", 24, 670, 760, 22, "ZoFontGameSmall")

    self.menu =
    {
        window = window,
        titleLabel = title,
        statusLabel = statusLabel,
        faqLabel = faqLabel,
        rankStatusLabel = rankStatus,
        queueStatusLabel = queueStatus,
        clientQueueLabel = clientQueueLabel,
        backgroundImage = backgroundImage,
        bannerFrame = bannerFrame,
        bannerImage = bannerImage,
    }

    self:RefreshMenu()
end

function JRD:OpenMenu()
    self:CreateMenu()
    self:RefreshMenu()
    self.menu.window:SetHidden(false)
end

function JRD:ToggleMenu()
    self:CreateMenu()
    self:RefreshMenu()
    self.menu.window:SetHidden(not self.menu.window:IsHidden())
end


function JRD:PrintHelp()
    JRDChat("Commands")
    d("/jrd stats")
    d("/jrd top")
    d("/jrd rivals")
    d("/jrd rival @PlayerName")
    d("/jrd history")
    d("/jrd log")
    d("/jrd rankedstats")
    d("/jrd rankedhistory")
    d("/jrd report")
    d("/jrd ranked on")
    d("/jrd ranked off")
    d("/jrd menu")
    d("/jrd toggle")
    d("/jrd mini")
    d("/jrd showmini")
    d("/jrd hidemini")
    d("/jrd faq")
    d("/jrd queue")
    d("/jrd queue ranked")
    d("/jrd queue unranked")
    d("/jrd queue join")
    d("/jrd queue leave")
    d("/jrd discord")
    d("/jrd reset")
end

function JRD:HandleSlashCommand(text)
    text = text or ""

    local command, rest = text:match("^(%S*)%s*(.-)$")
    command = string.lower(command or "")
    rest = rest or ""

    if command == "" or command == "menu" or command == "open" or command == "toggle" then
        self:ToggleMenu()
    elseif command == "stats" then
        self:PrintStats()
    elseif command == "top" then
        self:PrintRivals()
    elseif command == "rivals" then
        self:PrintRivals()
    elseif command == "rival" then
        self:PrintRival(rest)
    elseif command == "history" then
        self:PrintHistory()
    elseif command == "log" or command == "duellog" then
        self:OpenDuelLog()
    elseif command == "rankedstats" then
        self:PrintRankedStats()
    elseif command == "rankedhistory" then
        self:PrintRankedHistory()
    elseif command == "report" then
        self:PrintLastDiscordReport()
    elseif command == "mini" then
        self:ToggleMiniPanel()
    elseif command == "showmini" then
        self:ShowMiniPanel()
    elseif command == "hidemini" then
        self:HideMiniPanel()
    elseif command == "faq" then
        self:OpenMenu()
    elseif command == "queue" then
        local queueCommand = string.lower(rest or "")
        self:OpenMenu()

        if queueCommand == "join" or queueCommand == "client" or queueCommand == "ranked" or queueCommand == "competitive" then
            self:QueueClientQueueRequest("join")
        elseif queueCommand == "sayranked" then
            self:OpenSayQueueMessage("competitive")
        elseif queueCommand == "unranked" or queueCommand == "casual" then
            self:OpenSayQueueMessage("unranked")
        elseif queueCommand == "leave" or queueCommand == "off" or queueCommand == "none" then
            self:QueueClientQueueRequest("leave")
        elseif queueCommand == "status" then
            JRDChat("Client queue status")
            d(self:GetClientQueueStatusText())
        else
            JRDChat("Client queue commands")
            d("/jrd queue join")
            d("/jrd queue leave")
            d("/jrd queue status")
        end
    elseif command == "competitive" then
        self:OpenMenu()
        self:OpenSayQueueMessage("competitive")
    elseif command == "unranked" then
        self:OpenMenu()
        self:OpenSayQueueMessage("unranked")
    elseif command == "leavequeue" then
        self:OpenSayQueueMessage("none")
    elseif command == "leaderboard" or command == "lb" then
        self:RequestLeaderboardWindow()
    elseif command == "client" then
        JRDChat("Jensen Ranked Duels Client info")
        d("The Windows client reads SavedVariables and uploads pending ranked win reports.")
        d("After a ranked win, use /reloadui if you want the client to see the report right away.")
        d("Saved pending reports: " .. tostring(#(self.saved.clientExports or {})))
    elseif command == "discord" then
        self:PrintDiscordRankedCommands()
    elseif command == "commands" then
        self:PrintHelp()
        self:PrintDiscordRankedCommands()
    elseif command == "on" then
        self:SetRankedMode(true)
    elseif command == "off" then
        self:SetRankedMode(false)
    elseif command == "ranked" then
        local rankedCommand = string.lower(rest or "")

        if rankedCommand == "on" then
            self:SetRankedMode(true)
        elseif rankedCommand == "off" then
            self:SetRankedMode(false)
        else
            JRDChat("Use /jrd ranked on or /jrd ranked off")
        end
    elseif command == "reset" then
        self:ResetData()
    else
        self:PrintHelp()
    end
end

function JRD:UpgradeSavedData()
    if self.saved.localStats == nil then
        self.saved.localStats =
        {
            wins = 0,
            losses = 0,
            matches = 0,
            currentStreak = 0,
            bestStreak = 0,
            opponents = {},
            history = {},
        }
    end

    if self.saved.localStats.opponents == nil then
        self.saved.localStats.opponents = {}
    end

    if self.saved.localStats.history == nil then
        self.saved.localStats.history = {}
    end

    if self.saved.ranked == nil then
        self.saved.ranked =
        {
            players = {},
            matches = {},
        }
    end

    if self.saved.ranked.players == nil then
        self.saved.ranked.players = {}
    end

    if self.saved.ranked.matches == nil then
        self.saved.ranked.matches = {}
    end

    if self.saved.settings.autoTrackUnranked == nil then
        self.saved.settings.autoTrackUnranked = true
    end

    if self.saved.settings.localQueueMode == nil then
        self.saved.settings.localQueueMode = "none"
    end

    if self.saved.settings.miniPanelVisible == nil then
        self.saved.settings.miniPanelVisible = true
    end

    if self.saved.settings.openLeaderboardAfterReload == nil then
        self.saved.settings.openLeaderboardAfterReload = false
    end

    if self.saved.settings.minimumDuelSeconds == nil or self.saved.settings.minimumDuelSeconds == 30 then
        self.saved.settings.minimumDuelSeconds = 10
    end

    if self.saved.lastDiscordReport == nil then
        self.saved.lastDiscordReport = nil
    end

    if self.saved.clientExports == nil then
        self.saved.clientExports = {}
    end

    if self.saved.clientReports == nil then
        self.saved.clientReports = {}
    end
end

function JRD:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide("JensenRankedDuelsSavedVariables", 1, nil, self.defaults)
    self:UpgradeSavedData()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_COUNTDOWN, function(eventCode, startTimeMS)
        self:OnDuelCountdown(eventCode, startTimeMS)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DUEL_FINISHED, function(eventCode, result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
        self:OnDuelFinished(eventCode, result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName, opponentAlliance, opponentGender, opponentClassId, opponentRaceId)
    end)

    SLASH_COMMANDS["/jrd"] = function(text)
        self:HandleSlashCommand(text)
    end

    self:CreateMenu()
    self:CreateMiniPanel()

    if self.saved.settings.openLeaderboardAfterReload == true then
        self.saved.settings.openLeaderboardAfterReload = false

        if zo_callLater ~= nil then
            zo_callLater(function()
                self:OpenLeaderboardWindow()
            end, 900)
        else
            self:OpenLeaderboardWindow()
        end
    end

    JRDChat("Loaded. Mini panel is active. Type /jrd toggle to open the full menu, or /jrd mini to show or hide the mini panel.")
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= JRD.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(JRD.name, EVENT_ADD_ON_LOADED)
    JRD:Initialize()
end

EVENT_MANAGER:RegisterForEvent(JRD.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
