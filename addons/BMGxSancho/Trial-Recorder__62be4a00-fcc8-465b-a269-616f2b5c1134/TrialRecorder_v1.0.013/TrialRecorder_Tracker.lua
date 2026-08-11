TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.activeSession = nil

local HIGH_BONUS_REASON = rawget(_G, "RAID_POINT_REASON_BONUS_ACTIVITY_HIGH")
local MEDIUM_BONUS_REASON = rawget(_G, "RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM")
local LOW_BONUS_REASON = rawget(_G, "RAID_POINT_REASON_BONUS_ACTIVITY_LOW")
local BONUS_ONE = rawget(_G, "RAID_POINT_REASON_BONUS_POINT_ONE")
local BONUS_TWO = rawget(_G, "RAID_POINT_REASON_BONUS_POINT_TWO")
local BONUS_THREE = rawget(_G, "RAID_POINT_REASON_BONUS_POINT_THREE")

local function IsVeteranDifficulty()
    return GetCurrentZoneDungeonDifficulty and GetCurrentZoneDungeonDifficulty() == DUNGEON_DIFFICULTY_VETERAN
end

function TR:ResetSession(reason)
    if self.activeSession then
        self:AddDiagnostic({ event = "SESSION_RESET", reason = reason, trialName = self.activeSession.trialName })
    end
    self.activeSession = nil
end

function TR:OnRaidStarted(trialName, weekly)
    local trial = self:GetTrialByName(trialName)
    if not trial then
        self:AddDiagnostic({ event = "UNKNOWN_TRIAL_STARTED", trialName = trialName, weekly = weekly })
        return
    end
    if not IsVeteranDifficulty() then return end
    self.activeSession = {
        trialKey = trial.key,
        trialName = trialName,
        startedAt = GetTimeStamp(),
        weekly = weekly,
        scoreReasons = {},
        bonusHighCount = 0,
        bonusMediumCount = 0,
        bonusLowCount = 0,
        bonusPointMask = 0,
        completionSaved = false,
    }
    self:AddDiagnostic({ event = "RAID_STARTED", trialKey = trial.key, trialName = trialName, weekly = weekly })
end

function TR:OnScoreUpdate(reason, amount, totalScore)
    if not self.activeSession then return end
    local session = self.activeSession
    session.scoreReasons[reason] = (session.scoreReasons[reason] or 0) + (amount or 0)
    session.lastScore = totalScore
    if reason == HIGH_BONUS_REASON then session.bonusHighCount = session.bonusHighCount + 1 end
    if reason == MEDIUM_BONUS_REASON then session.bonusMediumCount = session.bonusMediumCount + 1 end
    if reason == LOW_BONUS_REASON then session.bonusLowCount = session.bonusLowCount + 1 end
    if reason == BONUS_ONE then session.bonusPointMask = BitOr(session.bonusPointMask, 1) end
    if reason == BONUS_TWO then session.bonusPointMask = BitOr(session.bonusPointMask, 2) end
    if reason == BONUS_THREE then session.bonusPointMask = BitOr(session.bonusPointMask, 4) end
    self:AddDiagnostic({ event = "SCORE_UPDATE", trialKey = session.trialKey, reason = reason, amount = amount, totalScore = totalScore })
end

function TR:ClassifyCompletion(trial, session)
    -- Conservative rule: the API's high-tier bonus activity is treated as the full HM signal.
    -- Debug capture preserves the score-reason stream so this mapping can be verified on console.
    local isHardMode = session and session.bonusHighCount and session.bonusHighCount > 0
    local configuration = nil

    if trial.configuration == "AS" then
        if isHardMode then configuration = "+2"
        elseif session and session.bonusMediumCount > 0 then configuration = "+1"
        else configuration = "+0" end
    elseif trial.configuration == "CR" then
        if isHardMode then configuration = "+3"
        elseif session and session.bonusMediumCount > 0 then configuration = "+2"
        elseif session and session.bonusLowCount > 0 then configuration = "+1"
        else configuration = "+0" end
    end

    return isHardMode and "HARD_MODE" or "VETERAN", configuration, isHardMode and "BONUS_ACTIVITY_HIGH" or "STANDARD"
end

function TR:OnRaidComplete(trialName, score, totalTime)
    local trial = self:GetTrialByName(trialName)
    if not trial then
        self:AddDiagnostic({ event = "UNKNOWN_TRIAL_COMPLETE", trialName = trialName, score = score, totalTime = totalTime })
        return
    end
    if not IsVeteranDifficulty() then return end

    local session = self.activeSession
    if not session or session.trialKey ~= trial.key then
        session = { trialKey = trial.key, trialName = trialName, scoreReasons = {}, bonusHighCount = 0, bonusMediumCount = 0, bonusLowCount = 0, bonusPointMask = 0 }
    end
    if session.completionSaved then return end

    local completionType, configuration, classificationSource = self:ClassifyCompletion(trial, session)
    local durationMs = tonumber(totalTime) or 0
    -- EVENT_RAID_TRIAL_COMPLETE totalTime is milliseconds on current API. Keep raw value.
    local run = {
        trialKey = trial.key,
        trialName = trial.name,
        completionType = completionType,
        configuration = configuration,
        classificationSource = classificationSource,
        completedAt = GetTimeStamp(),
        durationMs = durationMs,
        score = tonumber(score) or (GetCurrentRaidScore and GetCurrentRaidScore()) or 0,
        characterId = GetCurrentCharacterId and GetCurrentCharacterId() or 0,
        characterName = zo_strformat(SI_UNIT_NAME, GetUnitName("player")),
        addonVersion = self.VERSION,
        -- Vitality is intentionally stored in dedicated fields beginning with v1.0.009.
        -- Older records are not backfilled from legacy revive-counter fields.
        vitalityRemaining = GetRaidReviveCountersRemaining and GetRaidReviveCountersRemaining() or nil,
        vitalityStarting = GetCurrentRaidStartingReviveCounters and GetCurrentRaidStartingReviveCounters() or nil,
        vitalityRecordedAtVersion = self.VERSION,
        remainingRevives = GetRaidReviveCountersRemaining and GetRaidReviveCountersRemaining() or nil,
        startingRevives = GetCurrentRaidStartingReviveCounters and GetCurrentRaidStartingReviveCounters() or nil,
        deaths = GetCurrentRaidDeaths and GetCurrentRaidDeaths() or nil,
    }

    local saved, result = self:AddRun(run)
    session.completionSaved = saved
    self:AddDiagnostic({
        event = "RAID_COMPLETE",
        trialKey = trial.key,
        score = run.score,
        totalTime = run.durationMs,
        completionType = completionType,
        configuration = configuration,
        classificationSource = classificationSource,
        bonusHighCount = session.bonusHighCount,
        bonusMediumCount = session.bonusMediumCount,
        bonusLowCount = session.bonusLowCount,
        bonusPointMask = session.bonusPointMask,
        saved = saved,
    })

    if saved then
        self:ShowClearNotification(trial, result)
        if self.UI and self.UI:IsShowing() then self.UI:Refresh() end
    end
end

function TR:OnRaidFailed(trialName, score)
    self:AddDiagnostic({ event = "RAID_FAILED", trialName = trialName, score = score })
    self:ResetSession("failed")
end

function TR:InitializeTracker()
    EVENT_MANAGER:RegisterForEvent(self.NAME, EVENT_RAID_TRIAL_STARTED, function(_, trialName, weekly) self:OnRaidStarted(trialName, weekly) end)
    EVENT_MANAGER:RegisterForEvent(self.NAME, EVENT_RAID_TRIAL_SCORE_UPDATE, function(_, reason, amount, totalScore) self:OnScoreUpdate(reason, amount, totalScore) end)
    EVENT_MANAGER:RegisterForEvent(self.NAME, EVENT_RAID_TRIAL_COMPLETE, function(_, trialName, score, totalTime) self:OnRaidComplete(trialName, score, totalTime) end)
    EVENT_MANAGER:RegisterForEvent(self.NAME, EVENT_RAID_TRIAL_FAILED, function(_, trialName, score) self:OnRaidFailed(trialName, score) end)
end

function TR:ShowClearNotification(trial, run)
    if not self.sv.settings.showClearNotifications then return end
    local typeName = run.completionType == "HARD_MODE" and "Hard Mode" or "veteran"
    local recordText = ""
    if run.newFastest and run.newHighest then recordText = " | New fastest time and high score"
    elseif run.newFastest then recordText = " | New fastest time"
    elseif run.newHighest then recordText = " | New high score" end
    local message = string.format("%s %s clear recorded. %s | %s%s", trial.name, typeName, self:FormatDuration(run.durationMs), self:FormatScore(run.score), recordText)
    if ZO_Alert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ACHIEVEMENT_AWARDED, message)
    else
        d(string.format("[%s] %s", self.NAME, message))
    end
end
