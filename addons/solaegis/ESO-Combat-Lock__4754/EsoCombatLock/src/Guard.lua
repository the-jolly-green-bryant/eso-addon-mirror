-- EsoCombatLock - combat guard state machine

local ECL = EsoCombatLock
ECL.Guard = ECL.Guard or {}
local Guard = ECL.Guard
local Slots = ECL.Slots

local EVENT_NAMESPACE = ECL.NAME .. "_Guard"
local POST_COMBAT_DISARM_DELAY_MS = 1000
local POLL_INTERVAL_MS = 200
local MAX_CONSECUTIVE_REVERT_FAILURES = 5
local POLL_UPDATE_NAME = EVENT_NAMESPACE .. "_Poll"

-- Armed state
local armed = false
local disarmPending = false
local preCombatSlot = nil
local lastSafeSlot = nil
local companionCollectibleId = nil
local companionDefId = nil
local reverting = false -- reentrancy guard around SetCurrentQuickslot
local warnedNoTarget = false
local announcedCompanionLoss = false
local consecutiveRevertFailures = 0
local pollBackedOff = false

-- Raw key presses are not observable, so the guard announces the moment it
-- moves the selection instead. Spinning the wheel must not spam chat.
local GUARD_ALERT_THROTTLE_MS = 1000
local GUARD_ALERT_DEDUPE_MS = 3000
local lastGuardAlertMs = 0
local lastGuardAlertMessage = nil
local lastGuardAlertMessageMs = 0

local function resetGuardAlertThrottle()
    lastGuardAlertMs = 0
    lastGuardAlertMessage = nil
    lastGuardAlertMessageMs = 0
end

local function announceGuardAction(targetSlot)
    if not ECL.IsPressAlertsEnabled() then
        return
    end

    local message
    if Slots.IsEmpty(targetSlot) then
        message = ECL.FormatGuardParkedEmpty()
    elseif Slots.IsNoOpCollectible(targetSlot) then
        message = ECL.FormatGuardParkedNoOp(Slots.GetName(targetSlot) or ("slot " .. tostring(targetSlot)))
    else
        message = ECL.FormatGuardParkedOn(Slots.GetName(targetSlot) or ("slot " .. tostring(targetSlot)))
    end

    local now = GetGameTimeMilliseconds()
    if now - lastGuardAlertMs < GUARD_ALERT_THROTTLE_MS then
        return
    end
    if message == lastGuardAlertMessage and now - lastGuardAlertMessageMs < GUARD_ALERT_DEDUPE_MS then
        return
    end

    lastGuardAlertMs = now
    lastGuardAlertMessage = message
    lastGuardAlertMessageMs = now
    ECL.Announce(message)
end

------------------------------------------------------------
-- Internal
------------------------------------------------------------

local function onArmedEffects()
    if ECL.Indicator and ECL.Indicator.OnArmed then
        ECL.Indicator.OnArmed(companionCollectibleId)
    end
    if ECL.PressWatch and ECL.PressWatch.Start then
        ECL.PressWatch.Start()
    end
end

local function onDisarmedEffects()
    if ECL.Indicator and ECL.Indicator.OnDisarmed then
        ECL.Indicator.OnDisarmed()
    end
    if ECL.PressWatch and ECL.PressWatch.Stop then
        ECL.PressWatch.Stop()
    end
end


local ensureSafeSelection

local function stopPoll()
    EVENT_MANAGER:UnregisterForUpdate(POLL_UPDATE_NAME)
end

local function resetPollState()
    consecutiveRevertFailures = 0
    pollBackedOff = false
end

ensureSafeSelection = function(reason)
    if not armed then
        return
    end
    local current = Slots.GetCurrent()
    if Slots.IsSafe(current) then
        if not Slots.IsEmpty(current) or lastSafeSlot == nil then
            -- Remember non-empty safe slots; also remember empty if nothing else yet.
            lastSafeSlot = current
        end
        return
    end

    local target = Slots.ResolveTarget(lastSafeSlot)
    if not target then
        if not warnedNoTarget then
            warnedNoTarget = true
            ECL.Announce(
                string.format(
                    "No safe quickslot available — companion may still be dismissed by %s",
                    ECL.GetQuickslotKeyLabel()
                ),
                true
            )
        end
        return
    end

    ECL.Debug(string.format("Revert (%s): %s -> %s", reason, Slots.DescribeSlot(current), tostring(target)))
    reverting = true
    Slots.SetCurrent(target)
    reverting = false

    local after = Slots.GetCurrent()
    if after ~= target or Slots.IsRisky(after) then
        consecutiveRevertFailures = consecutiveRevertFailures + 1
        ECL.Debug(string.format(
            "Revert failed (%s): wanted %s, got %s (failures=%d)",
            reason,
            tostring(target),
            Slots.DescribeSlot(after),
            consecutiveRevertFailures
        ))
        if consecutiveRevertFailures >= MAX_CONSECUTIVE_REVERT_FAILURES then
            pollBackedOff = true
            stopPoll()
            ECL.Debug("Poll safety net disabled after repeated revert failures — event-driven only")
        end
        return
    end

    consecutiveRevertFailures = 0
    announceGuardAction(target)
    -- Keep lastSafe as a usable resource when parking on an empty no-op slot.
    if not Slots.IsEmpty(target) then
        lastSafeSlot = target
    end
end

local function startPoll()
    stopPoll()
    if pollBackedOff then
        return
    end
    EVENT_MANAGER:RegisterForUpdate(POLL_UPDATE_NAME, POLL_INTERVAL_MS, function()
        if not armed or pollBackedOff then
            return
        end
        if Slots.IsRisky(Slots.GetCurrent()) then
            ensureSafeSelection("poll")
        end
    end)
end

local function cancelPendingDisarm()
    disarmPending = false
end

local function arm()
    if armed then
        cancelPendingDisarm()
        return
    end
    if not ECL.IsGuardEnabled() then
        return
    end
    if not HasActiveCompanion or not HasActiveCompanion() then
        if not Slots.HasActiveRiskyCollectible() then
            ECL.Debug("Combat started with no companion or active risky collectible — guard stays idle")
            return
        end
        ECL.Debug("Combat started with active assistant/pet — arming guard without companion")
    end

    companionCollectibleId, companionDefId = Slots.GetActiveCompanionCollectibleId()
    preCombatSlot = Slots.GetCurrent()
    if Slots.IsSafe(preCombatSlot) then
        lastSafeSlot = preCombatSlot
    else
        lastSafeSlot = nil
    end
    warnedNoTarget = false
    announcedCompanionLoss = false
    resetGuardAlertThrottle()
    resetPollState()
    armed = true
    ECL.Debug(string.format(
        "Armed. companionCollectible=%s preSlot=%s lastSafe=%s",
        tostring(companionCollectibleId),
        tostring(preCombatSlot),
        tostring(lastSafeSlot)
    ))

    -- If a substitute is configured, force it at combat start even when the
    -- current slot is already safe (verification scenario from the plan).
    local sub = ECL.GetSubstitute()
    if sub then
        local target = Slots.ResolveTarget(lastSafeSlot)
        if target and target ~= Slots.GetCurrent() then
            ECL.Debug("Forcing substitute at combat start -> " .. tostring(target))
            reverting = true
            Slots.SetCurrent(target)
            reverting = false
            announceGuardAction(target)
            if not Slots.IsEmpty(target) then
                lastSafeSlot = target
            end
            onArmedEffects()
            startPoll()
            return
        end
    end

    ensureSafeSelection("combat-start")
    onArmedEffects()
    startPoll()
end

local function disarm(restore)
    if not armed then
        return
    end
    stopPoll()
    armed = false
    onDisarmedEffects()
    local savedCompanion = companionCollectibleId
    local savedPre = preCombatSlot

    companionCollectibleId = nil
    companionDefId = nil
    lastSafeSlot = nil
    preCombatSlot = nil
    warnedNoTarget = false
    announcedCompanionLoss = false
    resetGuardAlertThrottle()
    resetPollState()

    if restore and savedPre then
        reverting = true
        Slots.SetCurrent(savedPre)
        reverting = false
        ECL.Debug("Restored pre-combat quickslot " .. tostring(savedPre))
    end

    -- Hand off to recovery if the companion vanished during the fight.
    if ECL.IsResummonEnabled() and savedCompanion then
        if not HasActiveCompanion or not HasActiveCompanion() then
            ECL.Recovery.Start(savedCompanion)
        end
    end
end

local function scheduleDisarm(restore)
    if not armed or disarmPending then
        return
    end
    disarmPending = true
    ECL.Debug(string.format("Scheduling disarm in %dms", POST_COMBAT_DISARM_DELAY_MS))
    zo_callLater(function()
        if not disarmPending then
            return
        end
        disarmPending = false
        disarm(restore)
    end, POST_COMBAT_DISARM_DELAY_MS)
end

------------------------------------------------------------
-- Event handlers
------------------------------------------------------------

local function onCombatState(_, inCombat)
    if inCombat then
        cancelPendingDisarm()
        arm()
    else
        scheduleDisarm(true)
    end
end

local function onQuickslotChanged(_, actionSlotIndex)
    if not armed or reverting then
        return
    end
    if not ECL.IsGuardEnabled() then
        return
    end

    local slot = actionSlotIndex or Slots.GetCurrent()

    if Slots.IsRisky(slot) then
        ensureSafeSelection("quickslot-changed")
    else
        if not Slots.IsEmpty(slot) or lastSafeSlot == nil then
            lastSafeSlot = slot
        end
        ECL.Debug("Accepted safe quickslot " .. tostring(slot))
    end
end

local function onCompanionStateChanged(_, newState, _)
    -- Companion drop while armed is recovered after combat ends (cannot summon in combat).
    if not armed then
        return
    end
    if newState == COMPANION_STATE_INACTIVE and companionCollectibleId and not announcedCompanionLoss then
        announcedCompanionLoss = true
        ECL.Debug("Companion became inactive during combat — queued for post-combat resummon")
        -- Authoritative loss signal: EVENT_COLLECTIBLE_USE_RESULT cannot identify
        -- which collectible fired, so this is the only reliable place to report it.
        if ECL.IsResummonEnabled() then
            ECL.Announce(
                "Unexpected: companion lost during combat — please report this bug (will resummon when combat ends)",
                true
            )
        else
            ECL.Announce(
                "Unexpected: companion lost during combat — please report this bug",
                true
            )
        end
    end
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------

function Guard.IsArmed()
    return armed
end

function Guard.GetState()
    return {
        armed = armed,
        preCombatSlot = preCombatSlot,
        lastSafeSlot = lastSafeSlot,
        companionCollectibleId = companionCollectibleId,
        companionDefId = companionDefId,
    }
end

function Guard.ForceEnsure()
    ensureSafeSelection("manual")
end

function Guard.Register()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, onCombatState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_QUICKSLOT_CHANGED, onQuickslotChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_COMPANION_STATE_CHANGED, onCompanionStateChanged)

    -- Sync if we load mid-combat (reloadui).
    if IsUnitInCombat and IsUnitInCombat("player") then
        arm()
    end
end

function Guard.Unregister()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_QUICKSLOT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTIVE_COMPANION_STATE_CHANGED)
    stopPoll()
    cancelPendingDisarm()
    if armed then
        disarm(false)
    end
end
