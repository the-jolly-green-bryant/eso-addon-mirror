-- Battleboard_Events.lua  (queue/timer tracking and battleground event wiring)
-- Part of Battleboard. Loaded before Capture and Init.

local BL = Battleboard
local _x = BL.__constants

local Num = _x.Num
local IsFinalRoundPostround4v4Deathmatch = _x.IsFinalRoundPostround4v4Deathmatch
local QUEUE_CACHE_TTL_SECONDS = 120

function BL.MarkBattlegroundEnteredIfNeeded()
    if IsActiveWorldBattleground()
        and GetCurrentBattlegroundState() == BATTLEGROUND_STATE_RUNNING then
        if not BL.currentBattlegroundEnteredAt then
            BL.currentBattlegroundEnteredAt = GetTimeStamp()
            BL.currentBattlegroundDeadSeconds = 0
            BL.currentBattlegroundDeathStartedAt = nil
            BL.currentBattlegroundCombatSeconds = 0
            BL.currentBattlegroundCombatStartedAt = nil
            BL.currentBattlegroundTimersFrozen = false
            BL.currentBattlegroundFrozenAt = nil
            BL.currentBattlegroundFrozenDurationSeconds = nil
            BL.currentBattlegroundFrozenDeadSeconds = nil
            BL.currentBattlegroundFrozenCombatSeconds = nil
            BL.CarryQueueTimerIntoBattleground()
        end

        local isDead = IsUnitDeadOrReincarnating("player") == true

        if isDead and not BL.currentBattlegroundDeathStartedAt then
            BL.currentBattlegroundDeathStartedAt = GetTimeStamp()
        end

        if IsUnitInCombat("player") == true and not BL.currentBattlegroundCombatStartedAt then
            BL.currentBattlegroundCombatStartedAt = GetTimeStamp()
        end

        BL.UpdateDebugPanel()
    end
end

function BL.MarkBattlegroundLoadedIfNeeded()
    if IsActiveWorldBattleground() then
        BL.CarryQueueTimerIntoBattleground()
    end
end

function BL.ClearBattlegroundEntryTimestamp()
    local wasTrackingBattleground = BL.currentBattlegroundEnteredAt ~= nil
        or BL.currentBattlegroundTimersFrozen == true
        or BL.autoSaveBattlegroundFinishedHandled == true
        or BL.autoSaveBattlegroundPending == true

    if wasTrackingBattleground then
        BL.HideEndMatchScoreboard()
    end

    BL.currentBattlegroundEnteredAt = nil
    BL.currentBattlegroundDeadSeconds = 0
    BL.currentBattlegroundDeathStartedAt = nil
    BL.currentBattlegroundCombatSeconds = 0
    BL.currentBattlegroundCombatStartedAt = nil
    BL.currentBattlegroundTimersFrozen = false
    BL.currentBattlegroundFrozenAt = nil
    BL.currentBattlegroundFrozenDurationSeconds = nil
    BL.currentBattlegroundFrozenDeadSeconds = nil
    BL.currentBattlegroundFrozenCombatSeconds = nil
    BL.currentBattlegroundQueueSeconds = nil
    if BL.queueCacheInBattleground then
        BL.ClearQueueCache()
    end
    BL.UpdateDebugPanel()
end

function BL.OnLocalPlayerDeathStateChanged(isDead)
    if not IsActiveWorldBattleground() then return end
    if BL.currentBattlegroundTimersFrozen then return end
    if GetCurrentBattlegroundState() ~= BATTLEGROUND_STATE_RUNNING then return end

    BL.MarkBattlegroundEnteredIfNeeded()

    local now = GetTimeStamp()
    if isDead then
        if not BL.currentBattlegroundDeathStartedAt then
            BL.currentBattlegroundDeathStartedAt = now
        end
        BL.UpdateDebugPanel()
        return
    end

    if BL.currentBattlegroundDeathStartedAt then
        BL.currentBattlegroundDeadSeconds = Num(BL.currentBattlegroundDeadSeconds) + math.max(0, now - BL.currentBattlegroundDeathStartedAt)
        BL.currentBattlegroundDeathStartedAt = nil
    end

    BL.UpdateDebugPanel()
end

function BL.GetCurrentBattlegroundDeadSeconds(now)
    if BL.currentBattlegroundTimersFrozen then
        return Num(BL.currentBattlegroundFrozenDeadSeconds)
    end

    local deadSeconds = Num(BL.currentBattlegroundDeadSeconds)
    now = Num(now)

    if BL.currentBattlegroundDeathStartedAt and now > 0 then
        deadSeconds = deadSeconds + math.max(0, now - BL.currentBattlegroundDeathStartedAt)
    end

    return deadSeconds
end

function BL.OnLocalPlayerCombatStateChanged(inCombat)
    if not IsActiveWorldBattleground() then return end
    if BL.currentBattlegroundTimersFrozen then return end
    if GetCurrentBattlegroundState() ~= BATTLEGROUND_STATE_RUNNING then return end

    BL.MarkBattlegroundEnteredIfNeeded()

    local now = GetTimeStamp()
    if inCombat then
        if not BL.currentBattlegroundCombatStartedAt then
            BL.currentBattlegroundCombatStartedAt = now
        end
        BL.UpdateDebugPanel()
        return
    end

    if BL.currentBattlegroundCombatStartedAt then
        BL.currentBattlegroundCombatSeconds = Num(BL.currentBattlegroundCombatSeconds) + math.max(0, now - BL.currentBattlegroundCombatStartedAt)
        BL.currentBattlegroundCombatStartedAt = nil
    end

    BL.UpdateDebugPanel()
end

function BL.GetCurrentBattlegroundCombatSeconds(now)
    if BL.currentBattlegroundTimersFrozen then
        return Num(BL.currentBattlegroundFrozenCombatSeconds)
    end

    local combatSeconds = Num(BL.currentBattlegroundCombatSeconds)
    now = Num(now)

    if BL.currentBattlegroundCombatStartedAt and now > 0 then
        combatSeconds = combatSeconds + math.max(0, now - BL.currentBattlegroundCombatStartedAt)
    end

    return combatSeconds
end


local function IsBattlegroundLFGActivity(activityType)
    if activityType == nil then return false end

    return activityType == LFG_ACTIVITY_BATTLE_GROUND_CHAMPION
        or activityType == LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL
        or activityType == LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION
end

function BL.GetReadyCheckActivityType()
    return GetLFGReadyCheckActivityType()
end

function BL.IsReadyCheckBattleground()
    return IsBattlegroundLFGActivity(BL.GetReadyCheckActivityType())
end

function BL.IsActivityIdBattleground(activityId)
    activityId = Num(activityId)
    if activityId <= 0 then return false end

    return IsBattlegroundLFGActivity(GetActivityType(activityId))
end

function BL.IsActivitySetBattleground(activitySetId)
    activitySetId = Num(activitySetId)
    if activitySetId <= 0 then return false end

    local count = Num(GetNumActivitySetActivities(activitySetId))
    for index = 1, count do
        if BL.IsActivityIdBattleground(GetActivitySetActivityIdByIndex(activitySetId, index)) then
            return true
        end
    end

    return false
end

function BL.IsCurrentActivityFinderSearchBattleground()
    local count = Num(GetNumActivityRequests())
    for index = 1, count do
        local activityId, activitySetId = GetActivityRequestIds(index)
        if BL.IsActivityIdBattleground(activityId) or BL.IsActivitySetBattleground(activitySetId) then
            return true
        end
    end

    return false
end

function BL.ClearQueueCache()
    BL.queueCacheSeconds = nil
    BL.queueCacheCreatedAt = nil
    BL.queueCacheExpiresAt = nil
    BL.queueCacheInBattleground = false
    BL.currentBattlegroundQueueSeconds = nil

    BL.UpdateDebugPanel()
end

function BL.ClearQueueSession()
    BL.queueSessionIsBattleground = false
    BL.queueSessionAccepted = false
    BL.queueSessionStartedAt = nil
    BL.queueSessionSearchStartTimeMs = nil
    BL.currentQueueStartedAt = nil

    BL.UpdateDebugPanel()
end

function BL.ExpireQueueCacheIfNeeded(now)
    if not BL.queueCacheExpiresAt then return false end
    if BL.queueCacheInBattleground or IsActiveWorldBattleground() then
        return false
    end

    now = Num(now) > 0 and Num(now) or GetTimeStamp()
    if now < Num(BL.queueCacheExpiresAt) then return false end

    BL.ClearQueueCache()
    return true
end

function BL.ScheduleQueueCacheExpiry()
    zo_callLater(function()
        BL.ExpireQueueCacheIfNeeded(GetTimeStamp())
    end, QUEUE_CACHE_TTL_SECONDS * 1000)
end

function BL.SetQueueCache(seconds)
    local now = GetTimeStamp()
    BL.queueCacheSeconds = math.max(0, Num(seconds))
    BL.queueCacheCreatedAt = now
    BL.queueCacheExpiresAt = now + QUEUE_CACHE_TTL_SECONDS
    BL.queueCacheInBattleground = false
    BL.currentBattlegroundQueueSeconds = BL.queueCacheSeconds
    BL.ScheduleQueueCacheExpiry()

    BL.UpdateDebugPanel()
end

function BL.GetLFGQueueElapsedSeconds()
    local searchStartTimeMs = Num(BL.queueSessionSearchStartTimeMs)
    if searchStartTimeMs <= 0 then
        searchStartTimeMs = Num(GetLFGSearchTimes())
        if searchStartTimeMs > 0 then
            BL.queueSessionSearchStartTimeMs = searchStartTimeMs
        end
    end

    searchStartTimeMs = Num(searchStartTimeMs)
    if searchStartTimeMs > 0 then
        local elapsedMs = math.max(0, Num(GetFrameTimeMilliseconds()) - searchStartTimeMs)
        return elapsedMs / 1000
    end

    if BL.queueSessionStartedAt then
        return math.max(0, GetTimeStamp() - Num(BL.queueSessionStartedAt))
    end

    if BL.currentQueueStartedAt then
        return math.max(0, GetTimeStamp() - Num(BL.currentQueueStartedAt))
    end

    return 0
end

function BL.CacheBattlegroundQueueTimer()
    BL.ExpireQueueCacheIfNeeded()
    if BL.queueCacheSeconds then return end

    BL.SetQueueCache(BL.GetLFGQueueElapsedSeconds())
    BL.ClearQueueSession()
end

function BL.MarkBattlegroundQueueAccepted()
    BL.queueSessionAccepted = true

    BL.UpdateDebugPanel()
end

function BL.CacheReadyCheckQueueIfBattleground()
    if not BL.IsReadyCheckBattleground() then
        return false
    end

    BL.CacheBattlegroundQueueTimer()

    if HasAcceptedLFGReadyCheck() then
        BL.MarkBattlegroundQueueAccepted()
    end

    return true
end

function BL.StartQueueSessionIfCurrentSearchIsBattleground()
    BL.ExpireQueueCacheIfNeeded()

    -- A cache that has already been carried into the active battleground belongs to the
    -- match currently in progress. Never let a new queue disturb it.
    if BL.queueCacheInBattleground or IsActiveWorldBattleground() then
        return false
    end

    -- Any other cache is left over from a pop we never entered (declined/abandoned/timed out).
    -- A fresh queue supersedes it, so discard it up front. Clearing here (before the
    -- battleground/early-return checks below) is what lets a new queue overwrite the old timer,
    -- and it also keeps a stale cache from dead-locking the RetryStartQueueTimerIfBattleground guard.
    if BL.queueCacheSeconds then
        BL.ClearQueueCache()
    end

    if not BL.IsCurrentActivityFinderSearchBattleground() then
        return false
    end

    if BL.queueSessionIsBattleground then
        BL.GetLFGQueueElapsedSeconds()
        return true
    end

    BL.ClearQueueCache()
    BL.queueSessionIsBattleground = true
    BL.queueSessionAccepted = false
    BL.queueSessionStartedAt = GetTimeStamp()
    BL.currentQueueStartedAt = BL.queueSessionStartedAt

    local searchStartTimeMs = GetLFGSearchTimes()
    searchStartTimeMs = Num(searchStartTimeMs)
    if searchStartTimeMs > 0 then
        BL.queueSessionSearchStartTimeMs = searchStartTimeMs
    end

    BL.UpdateDebugPanel()

    return true
end

function BL.RetryStartQueueTimerIfBattleground()
    if BL.queueSessionIsBattleground or BL.queueCacheSeconds then return end

    BL.StartQueueSessionIfCurrentSearchIsBattleground()
end

function BL.IsCurrentLFGActivityBattleground()
    if BL.IsReadyCheckBattleground() then return true end
    if BL.IsCurrentActivityFinderSearchBattleground() then return true end

    local activityId = GetCurrentLFGActivityId()
    if activityId and Num(activityId) > 0 then
        local activityType = GetActivityType(activityId)
        if IsBattlegroundLFGActivity(activityType) then return true end
    end

    return false
end

function BL.CacheAcceptedBattlegroundQueueTimer()
    BL.CacheBattlegroundQueueTimer()
    BL.MarkBattlegroundQueueAccepted()
end

function BL.CarryQueueTimerIntoBattleground()
    if BL.queueCacheSeconds then
        BL.queueCacheInBattleground = true
        BL.queueCacheExpiresAt = nil
        BL.currentBattlegroundQueueSeconds = BL.queueCacheSeconds
        BL.UpdateDebugPanel()
        return
    end

    BL.ExpireQueueCacheIfNeeded()
end

function BL.HandleActivityFinderStatusUpdate(status)
    if status == ACTIVITY_FINDER_STATUS_QUEUED then
        if not BL.StartQueueSessionIfCurrentSearchIsBattleground() and zo_callLater then
            zo_callLater(function() BL.RetryStartQueueTimerIfBattleground() end, 250)
            zo_callLater(function() BL.RetryStartQueueTimerIfBattleground() end, 1000)
        end
    elseif status == ACTIVITY_FINDER_STATUS_NONE then
        BL.ClearQueueSession()
    elseif status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        if not BL.CacheReadyCheckQueueIfBattleground() then
            BL.ClearQueueSession()
        end
    end
end

function BL.HandleGroupingToolsReadyCheckUpdated()
    if BL.CacheReadyCheckQueueIfBattleground() then
        return
    end

    BL.ClearQueueSession()
end

function BL.HandleGroupingToolsReadyCheckCancelled(reason)
    if reason == LFG_READY_CHECK_CANCEL_REASON_GROUP_FORMED_SUCCESSFULLY then
        BL.MarkBattlegroundQueueAccepted()
        return
    end

    BL.ClearQueueSession()
end

-- Deserter penalty tracking.
-- Leaving a battleground in progress applies an LFG "deserter" cooldown. We listen for
-- EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE and, on the rising edge (cooldown goes from
-- inactive to active), add the newly-applied duration to a running cache. Edge detection
-- keeps repeated cooldown-update ticks from double counting the same penalty.
-- NOTE: deserterTimerCacheSeconds is in-memory only for now; it resets on /reloadui.
-- SavedVariables keep the rounded event history for Metrics aggregation.
local function GetDeserterCooldownRemainingSeconds()
    return Num(GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_DESERTED_QUEUE))
end

function BL.PrimeDeserterCooldownTracking()
    BL.deserterCooldownLastSeen = GetDeserterCooldownRemainingSeconds()
end

function BL.HandleActivityFinderCooldownsUpdate()
    local remaining = GetDeserterCooldownRemainingSeconds()

    local lastSeen = Num(BL.deserterCooldownLastSeen)

    if remaining > 0 and lastSeen <= 0 then
        BL.deserterTimerCacheSeconds = Num(BL.deserterTimerCacheSeconds) + remaining

        local minutes = math.floor((remaining / 60) + 0.5)
        if minutes < 1 then minutes = 1 end
        if BL.vars then
            if type(BL.vars.deserterEvents) ~= "table" then BL.vars.deserterEvents = {} end
            table.insert(BL.vars.deserterEvents, {
                duration = minutes,
                timestamp = GetTimeStamp(),
            })
        end
    end

    BL.deserterCooldownLastSeen = remaining

    BL.UpdateDebugPanel()
end

function BL.FreezeBattlegroundTimers(now)
    if BL.currentBattlegroundTimersFrozen or not BL.currentBattlegroundEnteredAt then return end

    now = Num(now) > 0 and Num(now) or GetTimeStamp()
    local frozenDeadSeconds = BL.GetCurrentBattlegroundDeadSeconds(now)
    local frozenCombatSeconds = BL.GetCurrentBattlegroundCombatSeconds(now)

    BL.currentBattlegroundTimersFrozen = true
    BL.currentBattlegroundFrozenAt = now
    BL.currentBattlegroundFrozenDurationSeconds = math.max(0, now - Num(BL.currentBattlegroundEnteredAt))
    BL.currentBattlegroundFrozenDeadSeconds = frozenDeadSeconds
    BL.currentBattlegroundFrozenCombatSeconds = frozenCombatSeconds
    BL.currentBattlegroundDeathStartedAt = nil
    BL.currentBattlegroundCombatStartedAt = nil

    BL.UpdateDebugPanel()
end


local AUTO_SAVE_INITIAL_DELAY_MS = 800
local AUTO_SAVE_RETRY_DELAY_MS = 500
local AUTO_SAVE_MAX_ATTEMPTS = 120

local function IsAutoSaveableBattlegroundEnd()
    if not IsActiveWorldBattleground() then
        return false
    end

    if GetCurrentBattlegroundState() == BATTLEGROUND_STATE_FINISHED then
        return true
    end

    local bgId = GetCurrentBattlegroundId()
    return IsFinalRoundPostround4v4Deathmatch and IsFinalRoundPostround4v4Deathmatch(bgId) == true
end

function BL.TryAutoSaveFinishedBattleground()
    -- Auto-save is driven by battleground state/scoreboard data, not by the
    -- scoreboard UI opening. This prevents duplicate saves when the player opens
    -- Battleboard and then returns to the finished-match scoreboard.
    if BL.autoSaveBattlegroundFinishedHandled or BL.autoSaveBattlegroundPending then
        return
    end

    if not IsAutoSaveableBattlegroundEnd() then
        return
    end

    BL.autoSaveBattlegroundFinishedHandled = true
    BL.autoSaveBattlegroundPending = true
    BL.autoSaveBattlegroundAttempts = 0

    -- Wait until the scoreboard data is actually readable before opening
    -- Battleboard. Opening Battleboard immediately can prevent ESO's own
    -- post-match scoreboard from initializing, especially for round-based
    -- 4v4 Deathmatch match-results data.
    BL.pendingMatchLoad = false

    BL.QueueBattlegroundAutoSaveAttempt(AUTO_SAVE_INITIAL_DELAY_MS)
end

function BL.QueueBattlegroundAutoSaveAttempt(delayMs)
    zo_callLater(function()
        BL.RunBattlegroundAutoSaveAttempt()
    end, delayMs or AUTO_SAVE_RETRY_DELAY_MS)
end

function BL.FinishBattlegroundAutoSave(keepHandled)
    BL.autoSaveBattlegroundPending = false
    BL.pendingMatchLoad = false
    BL.autoSaveBattlegroundAttempts = 0

    if not keepHandled then
        BL.autoSaveBattlegroundFinishedHandled = false
    end

    if BL.window and BL.selectedMatchId == nil then
        BL.RefreshDetails(nil)
    end
end

function BL.RunBattlegroundAutoSaveAttempt()
    if not BL.autoSaveBattlegroundPending then return end

    if not IsActiveWorldBattleground() then
        BL.FinishBattlegroundAutoSave(false)
        return
    end

    if not IsAutoSaveableBattlegroundEnd() then
        BL.FinishBattlegroundAutoSave(false)
        return
    end

    BL.autoSaveBattlegroundAttempts = Num(BL.autoSaveBattlegroundAttempts) + 1

    local match, result = BL.SaveCurrentScoreboard("automatic end-of-bg", { silentNoData = true })
    if match then
        BL.PrintEndMatchSweetroll(match)
        if BL.ShouldShowEndMatchScoreboard() then
            BL.ShowEndMatchScoreboard(match)
        end
        BL.autoSaveBattlegroundPending = false
        BL.pendingMatchLoad = false
        BL.autoSaveBattlegroundAttempts = 0
        return
    end

    if result == "duplicate" then
        BL.autoSaveBattlegroundPending = false
        BL.pendingMatchLoad = false
        BL.autoSaveBattlegroundAttempts = 0
        return
    end

    if BL.autoSaveBattlegroundAttempts >= AUTO_SAVE_MAX_ATTEMPTS then
        BL.FinishBattlegroundAutoSave(true)
        d("|cFFD700Battleboard|r could not save: battleground scoreboard data was not ready.")
        return
    end

    BL.QueueBattlegroundAutoSaveAttempt(AUTO_SAVE_RETRY_DELAY_MS)
end


function BL.OnBattlegroundStateChanged(previousState, currentState)
    if IsAutoSaveableBattlegroundEnd() then
        BL.FreezeBattlegroundTimers(GetTimeStamp())
        BL.TryAutoSaveFinishedBattleground()
        return
    end

    if IsActiveWorldBattleground() then
        BL.MarkBattlegroundLoadedIfNeeded()
        BL.MarkBattlegroundEnteredIfNeeded()
    else
        BL.ClearBattlegroundEntryTimestamp()
    end

    -- Any non-saveable BG state means this is no longer the same completed
    -- scoreboard. Reset the one-shot guard so the next BG can be saved.
    BL.autoSaveBattlegroundPending = false
    BL.autoSaveBattlegroundFinishedHandled = false
    BL.pendingMatchLoad = false
    BL.autoSaveBattlegroundAttempts = 0
    BL.lastCapturedSignature = nil
end


function BL.RegisterBattlegroundAutoSave()
    if BL.battlegroundAutoSaveRegistered then return end
    BL.battlegroundAutoSaveRegistered = true

    EVENT_MANAGER:RegisterForEvent(BL.name .. "BattlegroundAutoSave", EVENT_BATTLEGROUND_STATE_CHANGED, function(_, previousState, currentState)
        BL.OnBattlegroundStateChanged(previousState, currentState)
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "BattlegroundScoreboardUpdated", EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, function()
        if BL.autoSaveBattlegroundPending then
            BL.RunBattlegroundAutoSaveAttempt()
        else
            BL.TryAutoSaveFinishedBattleground()
        end
    end)

    local deathEventName = BL.name .. "PlayerDeathState"
    EVENT_MANAGER:RegisterForEvent(deathEventName, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
        if unitTag == "player" then
            BL.OnLocalPlayerDeathStateChanged(isDead == true)
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(deathEventName, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(BL.name .. "PlayerDead", EVENT_PLAYER_DEAD, function()
        BL.OnLocalPlayerDeathStateChanged(true)
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "PlayerAlive", EVENT_PLAYER_ALIVE, function()
        BL.OnLocalPlayerDeathStateChanged(false)
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        BL.OnLocalPlayerCombatStateChanged(inCombat == true)
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "ActivityFinderStatus", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, function(_, status)
        BL.HandleActivityFinderStatusUpdate(status)
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "ActivityQueueResult", EVENT_ACTIVITY_QUEUE_RESULT, function(_, result)
        if result == ACTIVITY_QUEUE_RESULT_REQUEST_QUEUED then
            if not BL.StartQueueSessionIfCurrentSearchIsBattleground() then
                zo_callLater(function() BL.RetryStartQueueTimerIfBattleground() end, 250)
                zo_callLater(function() BL.RetryStartQueueTimerIfBattleground() end, 1000)
            end
        elseif result ~= ACTIVITY_QUEUE_RESULT_SUCCESS then
            BL.ClearQueueSession()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "ReadyCheckUpdated", EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, function()
        BL.HandleGroupingToolsReadyCheckUpdated()
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "ReadyCheckCancelled", EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, function(_, reason)
        BL.HandleGroupingToolsReadyCheckCancelled(reason)
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "NoLongerLFG", EVENT_GROUPING_TOOLS_NO_LONGER_LFG, function()
        if not BL.queueCacheSeconds and not IsActiveWorldBattleground() then
            BL.ClearQueueSession()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(BL.name .. "ActivityFinderCooldowns", EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, function()
        BL.HandleActivityFinderCooldownsUpdate()
    end)
end

-- Backwards-compatible wrapper name. This no longer creates a visible button;
-- it only wires the automatic end-of-match save callback.
function BL.CreateScoreboardSaveButton()
    BL.RegisterBattlegroundAutoSave()
end


function BL.OnPlayerActivated()
    if IsActiveWorldBattleground() then
        BL.MarkBattlegroundLoadedIfNeeded()
        BL.MarkBattlegroundEnteredIfNeeded()
    else
        BL.ClearBattlegroundEntryTimestamp()
    end

    BL.PruneSavedMatchesToLimit()
end
