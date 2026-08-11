TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.UI = TR.UI or {}
local UI = TR.UI

local DIALOG_NAME = "TRIAL_RECORDER_TRIAL_RECORD"
local LEADERBOARD_EVENT_NAMESPACE = "TrialRecorder_Leaderboard"
local LEADERBOARD_REQUEST_TIMEOUT_MS = 2500
local RECENT_RUN_LIMIT = 10

function TR:FormatDuration(milliseconds)
    milliseconds = tonumber(milliseconds) or 0
    local totalSeconds = math.floor(milliseconds / 1000)
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, seconds)
    end

    return string.format("%d:%02d", minutes, seconds)
end

function TR:FormatScore(score)
    local value = tostring(math.floor(tonumber(score) or 0))
    return value:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

function TR:FormatVitality(run)
    if not run then
        return "Not recorded"
    end

    local remaining = tonumber(run.vitalityRemaining)
    local starting = tonumber(run.vitalityStarting)

    if remaining == nil then
        return "Not recorded"
    end

    if starting and starting > 0 then
        return string.format("%d/%d", math.max(0, remaining), starting)
    end

    return tostring(math.max(0, remaining))
end

function TR:FormatDate(timestamp)
    timestamp = tonumber(timestamp) or 0
    if timestamp <= 0 then
        return "--"
    end

    if GetDateStringFromTimestamp then
        return GetDateStringFromTimestamp(timestamp)
    end

    if FormatAchievementLinkTimestamp then
        return FormatAchievementLinkTimestamp(timestamp)
    end

    return tostring(timestamp)
end

local function GetFirstClearTimestamp(record)
    local firstVeteran = tonumber(record.firstVeteranClearAt) or 0
    local firstHardMode = tonumber(record.firstHardModeClearAt) or 0

    if firstVeteran == 0 then
        return firstHardMode
    elseif firstHardMode == 0 then
        return firstVeteran
    end

    return math.min(firstVeteran, firstHardMode)
end

local function GetLatestClearTimestamp(record)
    return math.max(
        tonumber(record.latestVeteranClearAt) or 0,
        tonumber(record.latestHardModeClearAt) or 0
    )
end

local function NormalizeDisplayName(value)
    value = tostring(value or "")
    return zo_strlower(value:gsub("^@", ""))
end

local function NormalizeCharacterName(value)
    if not value or value == "" then
        return nil
    end
    if ZO_CachedStrFormat then
        return ZO_CachedStrFormat(SI_UNIT_NAME, value)
    end
    return value
end

function UI:GetLeaderboardRequestInfo(trialKey)
    TR:RefreshRaidLeaderboardIds()

    local raidId = TR:GetRaidIdForTrial(trialKey)
    if not raidId then
        return nil
    end

    local weeklyRaidId = nil
    if type(GetRaidOfTheWeekLeaderboardInfo) == "function" then
        local ok, _, returnedRaidId = pcall(GetRaidOfTheWeekLeaderboardInfo, RAID_CATEGORY_TRIAL)
        if ok then
            weeklyRaidId = tonumber(returnedRaidId)
        end
    end

    return {
        raidId = raidId,
        requestRaidId = weeklyRaidId and weeklyRaidId == raidId and 0 or raidId,
        isWeekly = weeklyRaidId ~= nil and weeklyRaidId > 0 and weeklyRaidId == raidId,
        raidCategory = RAID_CATEGORY_TRIAL,
    }
end

function UI:ScanLeaderboardForAccount(requestInfo)
    if not requestInfo then
        return nil
    end

    local accountName = NormalizeDisplayName(GetDisplayName and GetDisplayName() or "")
    if accountName == "" then
        return nil
    end

    local count = 0
    local infoFunction

    if requestInfo.isWeekly then
        if type(GetNumTrialOfTheWeekLeaderboardEntries) ~= "function"
            or type(GetTrialOfTheWeekLeaderboardEntryInfo) ~= "function" then
            return nil
        end
        count = tonumber(GetNumTrialOfTheWeekLeaderboardEntries()) or 0
        infoFunction = function(index)
            return GetTrialOfTheWeekLeaderboardEntryInfo(index)
        end
    else
        if type(GetNumTrialLeaderboardEntries) ~= "function"
            or type(GetTrialLeaderboardEntryInfo) ~= "function" then
            return nil
        end
        count = tonumber(GetNumTrialLeaderboardEntries(requestInfo.raidId)) or 0
        infoFunction = function(index)
            return GetTrialLeaderboardEntryInfo(requestInfo.raidId, index)
        end
    end

    local best = nil
    for index = 1, count do
        local rank, characterName, score, _, _, displayName = infoFunction(index)
        if NormalizeDisplayName(displayName) == accountName then
            local candidate = {
                rank = tonumber(rank),
                score = tonumber(score),
                characterName = NormalizeCharacterName(characterName),
                characterId = nil,
                isWeekly = requestInfo.isWeekly,
                source = "ACCOUNT_LEADERBOARD_ROW",
            }

            if candidate.score and candidate.score > 0 then
                if not best
                    or candidate.score > best.score
                    or (candidate.score == best.score and candidate.rank and best.rank and candidate.rank < best.rank) then
                    best = candidate
                end
            end
        end
    end

    return best
end

function UI:ReadCurrentCharacterLeaderboardInfo(requestInfo)
    if not requestInfo then
        return nil
    end

    local rank
    local score

    if requestInfo.isWeekly and type(GetRaidOfTheWeekLeaderboardLocalPlayerInfo) == "function" then
        local ok, returnedRank, returnedScore = pcall(GetRaidOfTheWeekLeaderboardLocalPlayerInfo, RAID_CATEGORY_TRIAL)
        if ok then
            rank = tonumber(returnedRank)
            score = tonumber(returnedScore)
        end
    elseif type(GetRaidLeaderboardLocalPlayerInfo) == "function" then
        local ok, returnedRank, returnedScore = pcall(GetRaidLeaderboardLocalPlayerInfo, requestInfo.raidId)
        if ok then
            rank = tonumber(returnedRank)
            score = tonumber(returnedScore)
        end
    end

    if not score or score <= 0 then
        return nil
    end

    return {
        rank = rank and rank > 0 and rank or nil,
        score = score,
        characterId = GetCurrentCharacterId and GetCurrentCharacterId() or 0,
        characterName = NormalizeCharacterName(GetUnitName and GetUnitName("player") or nil),
        isWeekly = requestInfo.isWeekly,
        source = "LOCAL_PLAYER_INFO",
    }
end

function UI:ReadLeaderboardInfo(requestInfo, trialKey)
    local accountResult = self:ScanLeaderboardForAccount(requestInfo)
    local characterResult = self:ReadCurrentCharacterLeaderboardInfo(requestInfo)

    if characterResult then
        TR:SaveLeaderboardResult(trialKey, characterResult)
    end

    if accountResult then
        TR:SaveLeaderboardResult(trialKey, accountResult)
        return accountResult
    end

    if characterResult then
        return characterResult
    end

    return TR:GetBestKnownLeaderboardResult(
        trialKey,
        requestInfo and requestInfo.isWeekly
    )
end

function UI:ShowTrialDialog(trialKey)
    local data = { trialKey = trialKey }

    if ZO_Dialogs_ShowGamepadDialog then
        ZO_Dialogs_ShowGamepadDialog(DIALOG_NAME, data)
    else
        ZO_Dialogs_ShowDialog(DIALOG_NAME, data)
    end
end

function UI:FinishLeaderboardRequest(requestId)
    local pending = self.pendingLeaderboardRequest
    if not pending or pending.requestId ~= requestId then
        return
    end

    self.pendingLeaderboardRequest = nil

    EVENT_MANAGER:UnregisterForUpdate(LEADERBOARD_EVENT_NAMESPACE .. "_Finish")

    local result = self:ReadLeaderboardInfo(pending.requestInfo, pending.trialKey)
    self.leaderboardCache[pending.trialKey] = {
        result = result,
        isWeekly = pending.requestInfo and pending.requestInfo.isWeekly or false,
    }

    self:ShowTrialDialog(pending.trialKey)
end

function UI:ScheduleLeaderboardFinish(requestId, delayMs)
    EVENT_MANAGER:UnregisterForUpdate(LEADERBOARD_EVENT_NAMESPACE .. "_Finish")
    EVENT_MANAGER:RegisterForUpdate(LEADERBOARD_EVENT_NAMESPACE .. "_Finish", delayMs or 100, function()
        EVENT_MANAGER:UnregisterForUpdate(LEADERBOARD_EVENT_NAMESPACE .. "_Finish")
        UI:FinishLeaderboardRequest(requestId)
    end)
end

function UI:OnLeaderboardDataReceived(_, raidCategory, raidId)
    local pending = self.pendingLeaderboardRequest
    if not pending or not pending.requestInfo then
        return
    end

    if raidCategory == pending.requestInfo.raidCategory
        and raidId == pending.requestInfo.requestRaidId then
        -- ESO's native list manager refreshes the leaderboard first. Give the
        -- player-data callback one frame to populate before reading the result.
        self:ScheduleLeaderboardFinish(pending.requestId, 100)
    end
end

function UI:OnLeaderboardPlayerDataChanged()
    local pending = self.pendingLeaderboardRequest
    if not pending then
        return
    end

    self:ScheduleLeaderboardFinish(pending.requestId, 50)
end

function UI:RequestLeaderboardAndShow(trialKey)
    self.requestId = (self.requestId or 0) + 1
    local requestId = self.requestId
    local requestInfo = self:GetLeaderboardRequestInfo(trialKey)

    self.pendingLeaderboardRequest = {
        requestId = requestId,
        trialKey = trialKey,
        requestInfo = requestInfo,
    }

    if not requestInfo
        or not LEADERBOARD_LIST_MANAGER
        or type(LEADERBOARD_LIST_MANAGER.QueryLeaderboardData) ~= "function"
        or not LEADERBOARD_DATA_TYPE then
        self:FinishLeaderboardRequest(requestId)
        return
    end

    local ok = pcall(function()
        LEADERBOARD_LIST_MANAGER:QueryLeaderboardData(LEADERBOARD_DATA_TYPE.RAID, {
            raidId = requestInfo.requestRaidId,
            raidCategory = requestInfo.raidCategory,
        })
    end)

    if not ok then
        self:FinishLeaderboardRequest(requestId)
        return
    end

    -- The native API may return synchronously or may only update player data.
    -- This bounded fallback keeps the Trial Recorder menu responsive.
    zo_callLater(function()
        UI:FinishLeaderboardRequest(requestId)
    end, LEADERBOARD_REQUEST_TIMEOUT_MS)
end

function UI:GetCurrentLeaderboardInfo(trialKey)
    local cached = self.leaderboardCache and self.leaderboardCache[trialKey]
    if cached and cached.result then
        return cached.result, cached.isWeekly
    end

    local requestInfo = self:GetLeaderboardRequestInfo(trialKey)
    local result = TR:GetBestKnownLeaderboardResult(trialKey, requestInfo and requestInfo.isWeekly)
    return result, requestInfo and requestInfo.isWeekly or false
end

function UI:BuildTrialText(trialKey)
    local trial = TR.TrialByKey[trialKey]
    if not trial then
        return "Trial record unavailable."
    end

    local record = TR:GetTrialRecord(trialKey)
    local leaderboardResult, isWeekly = self:GetCurrentLeaderboardInfo(trialKey)

    local leaderboardTitle = "Current Leaderboard"
    local lines = {
        "|cD9B66F" .. leaderboardTitle .. "|r",
        string.format("Score: %s", leaderboardResult and leaderboardResult.score and TR:FormatScore(leaderboardResult.score) or "Not Ranked"),
        string.format("Rank: %s", leaderboardResult and leaderboardResult.rank and TR:FormatScore(leaderboardResult.rank) or "Not Ranked"),
    }

    if leaderboardResult and leaderboardResult.characterName then
        table.insert(lines, string.format("Character: %s", leaderboardResult.characterName))
    end

    table.insert(lines, "")
    table.insert(lines, "|cD9B66FTrial Recorder Stats|r")
    table.insert(lines, string.format("Veteran Clears: %d", record.veteranClears or 0))
    table.insert(lines, string.format("Hard Mode Clears: %d", record.hardModeClears or 0))
    table.insert(lines, string.format("Total Clears: %d", record.totalClears or 0))
    table.insert(lines, "")
    table.insert(lines, string.format("Fastest Veteran: %s", record.fastestVeteranTime and TR:FormatDuration(record.fastestVeteranTime) or "--"))
    table.insert(lines, string.format("Highest Veteran Score: %s", record.highestVeteranScore and TR:FormatScore(record.highestVeteranScore) or "--"))
    table.insert(lines, string.format("Fastest Hard Mode: %s", record.fastestHardModeTime and TR:FormatDuration(record.fastestHardModeTime) or "--"))
    table.insert(lines, string.format("Highest Hard Mode Score: %s", record.highestHardModeScore and TR:FormatScore(record.highestHardModeScore) or "--"))
    table.insert(lines, "")
    table.insert(lines, string.format("First Recorded Clear: %s", TR:FormatDate(GetFirstClearTimestamp(record))))
    table.insert(lines, string.format("Latest Clear: %s", TR:FormatDate(GetLatestClearTimestamp(record))))
    local latestRun = record.runs and record.runs[1] or nil
    table.insert(lines, string.format("Latest Vitality: %s", TR:FormatVitality(latestRun)))
    table.insert(lines, "")
    table.insert(lines, "|cD9B66FRecent Clears|r")

    if not record.runs or #record.runs == 0 then
        table.insert(lines, "No clears recorded since installation.")
    else
        for index = 1, math.min(#record.runs, RECENT_RUN_LIMIT) do
            local run = record.runs[index]
            local completionType = run.completionType == "HARD_MODE" and "HM" or "Vet"
            if run.configuration then
                completionType = completionType .. " " .. run.configuration
            end

            table.insert(lines, string.format(
                "%s  |  %s  |  %s  |  %s  |  %s",
                TR:FormatDate(run.completedAt),
                run.characterName or "Unknown Character",
                completionType,
                TR:FormatDuration(run.durationMs),
                TR:FormatScore(run.score)
            ))
            table.insert(lines, string.format("Vitality: %s", TR:FormatVitality(run)))
        end
    end

    return table.concat(lines, "\n")
end

function UI:Initialize()
    if self.initialized then
        return
    end

    self.leaderboardCache = {}

    EVENT_MANAGER:RegisterForEvent(
        LEADERBOARD_EVENT_NAMESPACE .. "_Data",
        EVENT_RAID_LEADERBOARD_DATA_RECEIVED,
        function(...)
            UI:OnLeaderboardDataReceived(...)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        LEADERBOARD_EVENT_NAMESPACE .. "_PlayerData",
        EVENT_RAID_LEADERBOARD_PLAYER_DATA_CHANGED,
        function(...)
            UI:OnLeaderboardPlayerDataChanged(...)
        end
    )


    ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = function(dialog)
                local data = dialog.data or {}
                local trial = TR.TrialByKey[data.trialKey]
                return trial and trial.name or TR.DISPLAY_NAME
            end,
        },
        mainText = {
            text = function(dialog)
                local data = dialog.data or {}
                return UI:BuildTrialText(data.trialKey)
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CLOSE,
                callback = function()
                    ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME)
                end,
            },
        },
    })

    self.initialized = true
end

function UI:ShowTrial(trialKey)
    self:Initialize()
    self:RequestLeaderboardAndShow(trialKey)
end

function UI:IsShowing()
    return false
end

function UI:Refresh()
    -- Trial and leaderboard data refresh when a trial is selected.
end
