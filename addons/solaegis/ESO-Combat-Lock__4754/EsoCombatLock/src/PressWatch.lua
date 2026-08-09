-- EsoCombatLock - detect quickslot use during combat

local ECL = EsoCombatLock
ECL.PressWatch = ECL.PressWatch or {}
local PressWatch = ECL.PressWatch
local Slots = ECL.Slots

local EVENT_NAMESPACE = ECL.NAME .. "_PressWatch"
local HOTBAR = HOTBAR_CATEGORY_QUICKSLOT_WHEEL
local POLL_MS = 150

local THROTTLE_MS = 1000
local DEDUPE_MS = 3000
local USE_DEDUPE_MS = 400

local active = false
local alertsEnabled = false
local lastAlertMs = 0
local lastMessage = nil
local lastMessageMs = 0
local lastUseSignature = nil
local lastUseMs = 0
local lastRemains = {}

local function resetThrottle()
    lastAlertMs = 0
    lastMessage = nil
    lastMessageMs = 0
    lastUseSignature = nil
    lastUseMs = 0
    lastRemains = {}
end

local function snapshotRemains()
    local snap = {}
    Slots.ForEachSlot(function(slot)
        local remain = GetSlotCooldownInfo(slot, HOTBAR)
        snap[slot] = remain or 0
    end)
    return snap
end

local function announcePress(message)
    if not alertsEnabled then
        return
    end
    if not ECL.IsPressAlertsEnabled() then
        return
    end

    local now = GetGameTimeMilliseconds()
    if now - lastAlertMs < THROTTLE_MS then
        return
    end
    if message == lastMessage and now - lastMessageMs < DEDUPE_MS then
        return
    end

    lastAlertMs = now
    lastMessage = message
    lastMessageMs = now
    ECL.Debug("PressWatch alert: " .. tostring(message))
    ECL.Announce(message)
end

local function announceUseOnce(signature, message)
    local now = GetGameTimeMilliseconds()
    if signature == lastUseSignature and now - lastUseMs < USE_DEDUPE_MS then
        return
    end
    lastUseSignature = signature
    lastUseMs = now
    announcePress(message)
end

local function cooldownUsesMilliseconds(duration)
    return duration and duration > 200
end

local function cooldownJustStarted(prev, remain, duration)
    prev = prev or 0
    remain = remain or 0
    if remain <= 0 or not duration or duration <= 0 then
        return false
    end
    if cooldownUsesMilliseconds(duration) then
        return prev < 500 and remain > 1000
    end
    return prev < 0.5 and remain > 1
end

local function scanAllSlotsForUse(reason)
    if not active then
        return
    end

    Slots.ForEachSlot(function(slot)
        if Slots.IsEmpty(slot) then
            lastRemains[slot] = 0
            return
        end

        local remain, duration = GetSlotCooldownInfo(slot, HOTBAR)
        remain = remain or 0
        local prev = lastRemains[slot] or 0
        lastRemains[slot] = remain

        if not alertsEnabled then
            return
        end

        local started = cooldownJustStarted(prev, remain, duration)
        if not started then
            return
        end

        local name = Slots.GetName(slot) or ("slot " .. tostring(slot))
        ECL.Debug(
            string.format(
                "PressWatch detect (%s): slot=%s prev=%s remain=%s duration=%s",
                reason,
                tostring(slot),
                tostring(prev),
                tostring(remain),
                tostring(duration)
            )
        )
        announceUseOnce("use:" .. tostring(slot) .. ":" .. tostring(remain), ECL.FormatQuickslotUsed(name))
    end)
end

local function onInventoryItemUsed()
    if not active then
        return
    end
    ECL.Debug("PressWatch event: EVENT_INVENTORY_ITEM_USED")
    scanAllSlotsForUse("inventory")
end

local function onActionUpdateCooldowns()
    if not active then
        return
    end
    scanAllSlotsForUse("cooldowns")
end

local function onItemOnCooldown()
    if not active then
        return
    end
    scanAllSlotsForUse("item-cooldown")
end

local function onHotbarSlotStateUpdated(_, actionSlotIndex, hotbarCategory)
    if not active then
        return
    end
    if hotbarCategory ~= HOTBAR then
        return
    end
    ECL.Debug(string.format("PressWatch event: HOTBAR_SLOT_STATE_UPDATED slot=%s", tostring(actionSlotIndex)))
    scanAllSlotsForUse("hotbar-state")
end

local function onCollectibleUseResult(_, result, isAttemptingActivation)
    if not active or not alertsEnabled then
        return
    end

    ECL.Debug(
        string.format(
            "PressWatch event: COLLECTIBLE_USE_RESULT result=%s attempting=%s",
            tostring(result),
            tostring(isAttemptingActivation)
        )
    )

    local slot = Slots.GetCurrent()
    if Slots.IsRisky(slot) then
        -- This event carries no collectible id, so a successful result cannot be
        -- attributed to our companion. Actual loss is reported by the guard from
        -- EVENT_ACTIVE_COMPANION_STATE_CHANGED instead of guessed here.
        if isAttemptingActivation and result ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
            announceUseOnce("risky-blocked", "Companion/assistant use blocked")
        end
        return
    end

    if Slots.GetType(slot) ~= ACTION_TYPE_COLLECTIBLE then
        scanAllSlotsForUse("collectible-fallback")
        return
    end

    local collectibleId = Slots.GetBoundId(slot)
    local name = (collectibleId and GetCollectibleName(collectibleId)) or Slots.GetName(slot) or "collectible"
    if Slots.IsNoOpCollectible(slot) and isAttemptingActivation then
        announceUseOnce("noop:" .. tostring(collectibleId), ECL.FormatQuickslotNoOp(name))
        return
    end
    if result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
        announceUseOnce("col:" .. tostring(collectibleId), ECL.FormatQuickslotUsed(name))
    elseif isAttemptingActivation then
        announcePress(ECL.FormatQuickslotBlocked(name))
    end
end

local function onUpdate()
    if not active then
        return
    end
    scanAllSlotsForUse("poll")
end

function PressWatch.IsActive()
    return active
end

function PressWatch.AreAlertsEnabled()
    return alertsEnabled
end

function PressWatch.Start()
    if active then
        return
    end
    active = true
    alertsEnabled = false
    resetThrottle()
    lastRemains = snapshotRemains()

    local current = Slots.GetCurrent()
    local detectable, reason = Slots.IsPressDetectable(current)
    ECL.Debug(
        string.format(
            "PressWatch arm: slot=%s detectable=%s%s (alerts pending parking)",
            tostring(current),
            tostring(detectable),
            detectable and "" or (" reason=" .. tostring(reason))
        )
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_INVENTORY_ITEM_USED, onInventoryItemUsed)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_UPDATE_COOLDOWNS, onActionUpdateCooldowns)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ITEM_ON_COOLDOWN, onItemOnCooldown)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_HOTBAR_SLOT_STATE_UPDATED, onHotbarSlotStateUpdated)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COLLECTIBLE_USE_RESULT, onCollectibleUseResult)
    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, POLL_MS, onUpdate)
    ECL.Debug("PressWatch started (listening; alerts off until parking completes)")
end

--- Enable press alerts after combat-start parking. Absorbs cooldown/slot events while off.
function PressWatch.EnableAlerts()
    if not active then
        return
    end
    lastRemains = snapshotRemains()
    alertsEnabled = true
    ECL.Debug("PressWatch alerts enabled")
end

function PressWatch.Stop()
    if not active then
        return
    end
    active = false
    alertsEnabled = false
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_INVENTORY_ITEM_USED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_UPDATE_COOLDOWNS)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ITEM_ON_COOLDOWN)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_HOTBAR_SLOT_STATE_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_COLLECTIBLE_USE_RESULT)
    EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
    resetThrottle()
    ECL.Debug("PressWatch stopped")
end
