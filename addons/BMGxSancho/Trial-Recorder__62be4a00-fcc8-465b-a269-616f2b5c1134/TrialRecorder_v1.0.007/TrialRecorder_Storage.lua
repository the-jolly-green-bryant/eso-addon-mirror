TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.SAVED_VARS_VERSION = 1
TR.MAX_RUNS_PER_TRIAL = 1000
TR.TRIM_TO_RUNS = 500

local defaults = {
    schemaVersion = 1,
    addonVersion = "1.0.007",
    trackingStartedAt = 0,
    settings = { showClearNotifications = true, debugEnabled = false },
    accountStats = { totalVeteranClears = 0, totalHardModeClears = 0, totalClears = 0, latestClearAt = nil },
    trials = {},
    leaderboards = {},
    recentFingerprints = {},
    diagnostics = {},
}

local function EmptyTrialRecord()
    return {
        veteranClears = 0,
        hardModeClears = 0,
        totalClears = 0,
        fastestVeteranTime = nil,
        fastestVeteranRunId = nil,
        fastestHardModeTime = nil,
        fastestHardModeRunId = nil,
        highestVeteranScore = nil,
        highestVeteranRunId = nil,
        highestHardModeScore = nil,
        highestHardModeRunId = nil,
        firstVeteranClearAt = nil,
        latestVeteranClearAt = nil,
        firstHardModeClearAt = nil,
        latestHardModeClearAt = nil,
        characterCounts = {},
        runs = {},
    }
end

local function EmptyLeaderboardContext()
    return {
        accountBest = nil,
        characters = {},
    }
end

local function EmptyLeaderboardRecord()
    return {
        regular = EmptyLeaderboardContext(),
        weekly = EmptyLeaderboardContext(),
    }
end

function TR:InitializeStorage()
    self.sv = ZO_SavedVars:NewAccountWide("TrialRecorderSavedVariables", self.SAVED_VARS_VERSION, nil, defaults)

    self.sv.settings = self.sv.settings or { showClearNotifications = true, debugEnabled = false }
    self.sv.accountStats = self.sv.accountStats or { totalVeteranClears = 0, totalHardModeClears = 0, totalClears = 0, latestClearAt = nil }
    self.sv.trials = self.sv.trials or {}
    self.sv.leaderboards = self.sv.leaderboards or {}
    self.sv.recentFingerprints = self.sv.recentFingerprints or {}
    self.sv.diagnostics = self.sv.diagnostics or {}

    if self.sv.trackingStartedAt == 0 then
        self.sv.trackingStartedAt = GetTimeStamp()
    end

    self.sv.addonVersion = self.VERSION

    for _, trial in ipairs(self.Trials) do
        if not self.sv.trials[trial.key] then
            self.sv.trials[trial.key] = EmptyTrialRecord()
        end
        if not self.sv.leaderboards[trial.key] then
            self.sv.leaderboards[trial.key] = EmptyLeaderboardRecord()
        else
            local leaderboardRecord = self.sv.leaderboards[trial.key]
            leaderboardRecord.regular = leaderboardRecord.regular or EmptyLeaderboardContext()
            leaderboardRecord.weekly = leaderboardRecord.weekly or EmptyLeaderboardContext()
            leaderboardRecord.regular.characters = leaderboardRecord.regular.characters or {}
            leaderboardRecord.weekly.characters = leaderboardRecord.weekly.characters or {}
        end
    end

    self:RebuildAggregatesIfNeeded()
end

function TR:GetTrialRecord(trialKey)
    if not self.sv.trials[trialKey] then
        self.sv.trials[trialKey] = EmptyTrialRecord()
    end
    return self.sv.trials[trialKey]
end

function TR:GetLeaderboardRecord(trialKey)
    self.sv.leaderboards = self.sv.leaderboards or {}
    if not self.sv.leaderboards[trialKey] then
        self.sv.leaderboards[trialKey] = EmptyLeaderboardRecord()
    end
    local record = self.sv.leaderboards[trialKey]
    record.regular = record.regular or EmptyLeaderboardContext()
    record.weekly = record.weekly or EmptyLeaderboardContext()
    record.regular.characters = record.regular.characters or {}
    record.weekly.characters = record.weekly.characters or {}
    return record
end

function TR:GetLeaderboardContext(trialKey, isWeekly)
    local record = self:GetLeaderboardRecord(trialKey)
    return isWeekly and record.weekly or record.regular
end

local function IsBetterLeaderboardResult(current, candidate)
    if not candidate or not candidate.score or candidate.score <= 0 then
        return false
    end
    if not current or not current.score or current.score <= 0 then
        return true
    end
    if candidate.score ~= current.score then
        return candidate.score > current.score
    end
    if candidate.rank and candidate.rank > 0 then
        return not current.rank or current.rank <= 0 or candidate.rank < current.rank
    end
    return false
end

function TR:SaveLeaderboardResult(trialKey, result)
    if not result or not result.score or result.score <= 0 then
        return nil
    end

    local record = self:GetLeaderboardContext(trialKey, result.isWeekly == true)
    local timestamp = GetTimeStamp()
    local saved = {
        score = tonumber(result.score),
        rank = tonumber(result.rank),
        characterId = result.characterId,
        characterName = result.characterName,
        isWeekly = result.isWeekly == true,
        source = result.source or "ESO_LEADERBOARD",
        updatedAt = timestamp,
    }

    if saved.characterId and saved.characterId ~= 0 then
        local characterKey = tostring(saved.characterId)
        local previous = record.characters[characterKey]
        if IsBetterLeaderboardResult(previous, saved) or not previous then
            record.characters[characterKey] = saved
        else
            previous.updatedAt = timestamp
            previous.rank = saved.rank or previous.rank
            previous.characterName = saved.characterName or previous.characterName
            previous.isWeekly = saved.isWeekly
            previous.source = saved.source
        end
    end

    if IsBetterLeaderboardResult(record.accountBest, saved) or not record.accountBest then
        record.accountBest = saved
    elseif record.accountBest.score == saved.score then
        record.accountBest.rank = saved.rank or record.accountBest.rank
        record.accountBest.characterName = saved.characterName or record.accountBest.characterName
        record.accountBest.characterId = saved.characterId or record.accountBest.characterId
        record.accountBest.updatedAt = timestamp
        record.accountBest.isWeekly = saved.isWeekly
        record.accountBest.source = saved.source
    end

    return record.accountBest
end

function TR:GetBestKnownLeaderboardResult(trialKey, isWeekly)
    local record = self:GetLeaderboardContext(trialKey, isWeekly == true)
    local best = record.accountBest

    for _, characterResult in pairs(record.characters) do
        if IsBetterLeaderboardResult(best, characterResult) then
            best = characterResult
        end
    end

    if best and best ~= record.accountBest then
        record.accountBest = best
    end

    return best
end

function TR:MakeFingerprint(run)
    return string.format("%s:%s:%s:%s:%s", run.trialKey or "?", tostring(run.completedAt or 0), tostring(run.durationMs or 0), tostring(run.score or 0), tostring(run.characterId or 0))
end

function TR:IsDuplicate(run)
    local fp = self:MakeFingerprint(run)
    local previous = self.sv.recentFingerprints[fp]
    if previous then return true, fp end
    return false, fp
end

function TR:RememberFingerprint(fp, timestamp)
    self.sv.recentFingerprints[fp] = timestamp
    local cutoff = GetTimeStamp() - 86400
    for key, value in pairs(self.sv.recentFingerprints) do
        if value < cutoff then self.sv.recentFingerprints[key] = nil end
    end
end

local function BetterFastest(current, candidate)
    return candidate and candidate > 0 and (not current or candidate < current)
end

local function BetterHighest(current, candidate)
    return candidate and (not current or candidate > current)
end

function TR:AddRun(run)
    local duplicate, fp = self:IsDuplicate(run)
    if duplicate then return false, "duplicate" end

    run.id = fp
    local record = self:GetTrialRecord(run.trialKey)
    table.insert(record.runs, 1, run)
    record.totalClears = record.totalClears + 1
    self.sv.accountStats.totalClears = self.sv.accountStats.totalClears + 1
    self.sv.accountStats.latestClearAt = run.completedAt

    local charKey = tostring(run.characterId or 0)
    record.characterCounts[charKey] = record.characterCounts[charKey] or { name = run.characterName or "Unknown", veteran = 0, hardMode = 0, total = 0 }
    local charStats = record.characterCounts[charKey]
    charStats.name = run.characterName or charStats.name
    charStats.total = charStats.total + 1

    run.newFastest = false
    run.newHighest = false

    if run.completionType == "HARD_MODE" then
        record.hardModeClears = record.hardModeClears + 1
        self.sv.accountStats.totalHardModeClears = self.sv.accountStats.totalHardModeClears + 1
        charStats.hardMode = charStats.hardMode + 1
        record.firstHardModeClearAt = record.firstHardModeClearAt or run.completedAt
        record.latestHardModeClearAt = run.completedAt
        if BetterFastest(record.fastestHardModeTime, run.durationMs) then
            record.fastestHardModeTime, record.fastestHardModeRunId, run.newFastest = run.durationMs, run.id, true
        end
        if BetterHighest(record.highestHardModeScore, run.score) then
            record.highestHardModeScore, record.highestHardModeRunId, run.newHighest = run.score, run.id, true
        end
    else
        record.veteranClears = record.veteranClears + 1
        self.sv.accountStats.totalVeteranClears = self.sv.accountStats.totalVeteranClears + 1
        charStats.veteran = charStats.veteran + 1
        record.firstVeteranClearAt = record.firstVeteranClearAt or run.completedAt
        record.latestVeteranClearAt = run.completedAt
        if BetterFastest(record.fastestVeteranTime, run.durationMs) then
            record.fastestVeteranTime, record.fastestVeteranRunId, run.newFastest = run.durationMs, run.id, true
        end
        if BetterHighest(record.highestVeteranScore, run.score) then
            record.highestVeteranScore, record.highestVeteranRunId, run.newHighest = run.score, run.id, true
        end
    end

    self:RememberFingerprint(fp, run.completedAt)
    self:TrimHistory(record)
    return true, run
end

function TR:TrimHistory(record)
    if #record.runs <= self.MAX_RUNS_PER_TRIAL then return end
    local preserved = {}
    local important = {
        [record.fastestVeteranRunId or ""] = true,
        [record.fastestHardModeRunId or ""] = true,
        [record.highestVeteranRunId or ""] = true,
        [record.highestHardModeRunId or ""] = true,
    }
    for index, run in ipairs(record.runs) do
        if index <= self.TRIM_TO_RUNS or important[run.id] then table.insert(preserved, run) end
    end
    record.runs = preserved
end

function TR:RebuildAggregatesIfNeeded()
    local totals = { vet = 0, hm = 0, all = 0, latest = nil }
    for _, trial in ipairs(self.Trials) do
        local record = self:GetTrialRecord(trial.key)
        totals.vet = totals.vet + (record.veteranClears or 0)
        totals.hm = totals.hm + (record.hardModeClears or 0)
        totals.all = totals.all + (record.totalClears or 0)
        local latest = math.max(record.latestVeteranClearAt or 0, record.latestHardModeClearAt or 0)
        if latest > 0 and (not totals.latest or latest > totals.latest) then totals.latest = latest end
    end
    self.sv.accountStats.totalVeteranClears = totals.vet
    self.sv.accountStats.totalHardModeClears = totals.hm
    self.sv.accountStats.totalClears = totals.all
    self.sv.accountStats.latestClearAt = totals.latest
end

function TR:AddDiagnostic(entry)
    if not self.sv.settings.debugEnabled then return end
    entry.at = entry.at or GetTimeStamp()
    table.insert(self.sv.diagnostics, 1, entry)
    while #self.sv.diagnostics > 100 do table.remove(self.sv.diagnostics) end
end
