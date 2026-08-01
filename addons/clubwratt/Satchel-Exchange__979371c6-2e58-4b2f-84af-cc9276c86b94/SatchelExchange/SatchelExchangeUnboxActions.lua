-- SatchelExchangeUnboxActions.lua: Built-in unboxer.
--
-- The game blocks item use during vendor interactions (CanInteractWithItem is
-- false the whole time), so the only workable strategy is to use the satchel
-- AFTER the interaction ends. StoreActions queues a sequence when a run
-- settles (unbox.pendingItemLink) and this module starts it on the next
-- interaction-end event. Three hard-won timing rules shape the sequence:
--
-- 1. The close events fire BEFORE the purchased satchel reaches the backpack
--    (the buy receipt precedes the inventory update from the server), so the
--    sequence must start empty-handed and wait for the satchel to appear.
-- 2. At most ONE UseItem may be in flight. The server resolves the slot index
--    when the request arrives, and the satchel's contents can land in the
--    slot the satchel just vacated -- a second in-flight UseItem on that slot
--    would use (and potentially bind) whatever random item is there now.
--    A use request can however be silently dropped (no error, no effect), so
--    a retry IS allowed once we are certain the first request did nothing:
--    the exact same satchel -- matched by unique id, not item id -- must
--    still be sitting in the bag well past any realistic server round trip.
-- 3. The game silently drops UseItem while any scene other than the plain HUD
--    is up -- including the store scene still FADING OUT after the
--    interaction ends. GetInteractionType() goes back to INTERACTION_NONE
--    well before the scene finishes, so interaction state alone is a false
--    green light. Readiness therefore also requires SCENE_MANAGER to be on
--    hud/hudui.
--
-- Success is therefore "the satchel was seen in the bag and is now gone".
--
-- The whole sequence is one frame-rate update loop. Send attempts start the
-- instant the satchel is in the bag and every readiness gate passes, and each
-- BLOCKED attempt backs the retry delay off by 16ms (0, 16, 32, ...) up to a
-- 200ms ceiling -- so the happy path fires at ~0ms while a slow scene fade
-- degrades gracefully instead of hammering. The same loop is the lifecycle
-- authority: completion detection, the dropped-request detector, and the
-- give-up deadline. Every stage logs a "+Nms" timestamp (ms since the
-- interaction ended) for field diagnosis (visible when LibConsoleLogger is
-- installed; logging is optional and silently off without it).
--
-- Opening a container without the game's autoloot setting shows a loot window
-- instead of delivering the contents, so a persistent EVENT_LOOT_UPDATED
-- handler performs Take All (LootAll) for any loot window that appears within
-- a short window after our UseItem. The window is time-based rather than tied
-- to the sequence because the satchel can vanish from the bag (ending the
-- sequence) before the loot window opens.

local BagUtils = SatchelExchange.BagUtils

local SatchelExchangeUnboxActions = {}

local PERSISTENT_NAMESPACE = "SatchelExchangeUnbox"
local LOOP_UPDATE_NAME = "SatchelExchangeUnboxLoop"
-- Loop cadence and backoff step; one frame at 60fps
local LOOP_INTERVAL_MS = 16
local BACKOFF_STEP_MS = 16
local MAX_ATTEMPT_INTERVAL_MS = 200
-- How long after our UseItem a loot window is assumed to be the satchel's
local LOOT_WATCH_WINDOW_MS = 5000
-- A use request with no visible effect after this long is considered dropped
local USE_RETRY_TIMEOUT_MS = 1000
-- Minimum sequence time guaranteed to remain after a dropped-request retry
local RETRY_GRACE_MS = 2000

local Log = SatchelExchange.Log

---@return SatchelExchangeUnboxState
local function GetUnbox()
    return SatchelExchange.state.unbox
end

---@return SatchelExchangeSavedVars
local function GetSettings()
    return SatchelExchange.state.savedVars
end

---@param now integer
---@return integer
local function Elapsed(now)
    return now - GetUnbox().startedAtMs
end

local function StopLoop()
    EVENT_MANAGER:UnregisterForUpdate(LOOP_UPDATE_NAME)
end

local function EndSequence()
    StopLoop()
    local unbox = GetUnbox()
    unbox.active = false
    unbox.itemId = nil
    unbox.seenInBag = false
    unbox.useSent = false
    -- lootWatchUntilMs deliberately survives: the loot window can open after
    -- the satchel disappears from the bag (which ends the sequence).
end

---@param slotIndex integer
---@return boolean sent
local function TryUseItem(slotIndex)
    if IsProtectedFunction("UseItem") then
        return CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex)
    end
    UseItem(BAG_BACKPACK, slotIndex)
    return true
end

---Use the armed satchel at slotIndex if every gate passes. One send in flight
---only (see rule 2 in the header). Returns the block reason so the loop can
---log gate transitions without spamming.
---@param slotIndex integer
---@param now integer
---@return boolean sent
---@return string|nil blockReason
local function AttemptUse(slotIndex, now)
    local unbox = GetUnbox()

    -- Re-verify at send time: this is the last gate before UseItem touches
    -- the slot.
    if GetItemId(BAG_BACKPACK, slotIndex) ~= unbox.itemId then
        return false, "slot no longer holds the satchel"
    end

    local readiness = BagUtils.GetUseReadiness(slotIndex)
    if not BagUtils.IsReadyToUse(readiness) then
        return false, BagUtils.FormatUseReadiness(readiness)
    end

    if not TryUseItem(slotIndex) then
        return false, "UseItem was rejected (in combat?)"
    end

    unbox.useSent = true
    unbox.useSentAtMs = now
    unbox.useUniqueId = Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex))
    unbox.lootWatchUntilMs = now + LOOT_WATCH_WINDOW_MS
    return true, nil
end

---Detect a silently dropped use request and rearm the send (the reliability
---half of rule 2). Only fires when the EXACT same satchel instance (unique id
---match) is still in the bag USE_RETRY_TIMEOUT_MS after the send with no loot
---window open. A different unique id means the first use went through and
---this slot now holds something else -- never touch it.
---@param slotIndex integer
---@param now integer
local function MaybeRetryDroppedUse(slotIndex, now)
    local unbox = GetUnbox()
    if IsLooting() then
        return
    end
    if now - unbox.useSentAtMs < USE_RETRY_TIMEOUT_MS then
        return
    end
    if Id64ToString(GetItemUniqueId(BAG_BACKPACK, slotIndex)) ~= unbox.useUniqueId then
        return
    end

    Log(string.format("Unbox +%dms: no response %dms after UseItem; assuming it was dropped, retrying",
        Elapsed(now), now - unbox.useSentAtMs))
    unbox.useSent = false
    unbox.attemptIntervalMs = 0
    unbox.nextAttemptAtMs = 0
    unbox.lastBlockReason = nil
    unbox.deadlineMs = math.max(unbox.deadlineMs, now + RETRY_GRACE_MS)
end

---The single per-frame driver: waits for delivery, sends with backoff,
---detects dropped requests, detects completion, and enforces the deadline.
local function Loop()
    local unbox = GetUnbox()
    if not unbox.active then
        StopLoop()
        return
    end

    local now = GetGameTimeMilliseconds()
    local slotIndex = BagUtils.FindItemInBackpack(unbox.itemId)

    -- Only "seen then gone" counts as unboxed; "never seen" just means the
    -- purchase hasn't reached the backpack yet. An open loot window means the
    -- Take All hasn't finished, so keep looping until it closes.
    if not slotIndex and unbox.seenInBag and not IsLooting() then
        Log(string.format("Unbox +%dms: done, press Talk for the next one (arrived +%dms, use sent +%dms, %d blocked attempts)",
            Elapsed(now), unbox.seenAtMs - unbox.startedAtMs,
            unbox.useSentAtMs - unbox.startedAtMs, unbox.attemptCount))
        EndSequence()
        return
    end

    if now >= unbox.deadlineMs then
        if slotIndex then
            local readiness = BagUtils.GetUseReadiness(slotIndex)
            Log(string.format("Unbox +%dms: gave up: %s", Elapsed(now), BagUtils.FormatUseReadiness(readiness)))
        else
            Log(string.format("Unbox +%dms: gave up: the satchel never arrived in the backpack", Elapsed(now)))
        end
        EndSequence()
        return
    end

    if not slotIndex then
        return
    end

    if not unbox.seenInBag then
        unbox.seenInBag = true
        unbox.seenAtMs = now
        Log(string.format("Unbox +%dms: satchel in bag (slot %d)", Elapsed(now), slotIndex))
    end

    if unbox.useSent then
        MaybeRetryDroppedUse(slotIndex, now)
        return
    end

    if now < unbox.nextAttemptAtMs then
        return
    end

    local sent, blockReason = AttemptUse(slotIndex, now)
    if sent then
        Log(string.format("Unbox +%dms: UseItem sent (%dms after arrival, %d blocked attempts)",
            Elapsed(now), now - unbox.seenAtMs, unbox.attemptCount))
        return
    end

    unbox.attemptCount = unbox.attemptCount + 1
    unbox.attemptIntervalMs = math.min(unbox.attemptIntervalMs + BACKOFF_STEP_MS, MAX_ATTEMPT_INTERVAL_MS)
    unbox.nextAttemptAtMs = now + unbox.attemptIntervalMs
    if blockReason ~= unbox.lastBlockReason then
        unbox.lastBlockReason = blockReason
        Log(string.format("Unbox +%dms: blocked (attempt %d, next retry in %dms): %s",
            Elapsed(now), unbox.attemptCount, unbox.attemptIntervalMs, blockReason))
    end
end

---Kick off the sequence StoreActions queued (unbox.pendingItemLink), if any.
---The pending link -- set only when a settled run left a satchel to open --
---is what keeps interaction-end events from OTHER interactions (notably our
---own loot window closing) from starting phantom sequences that wait out the
---full timeout for a satchel that will never arrive.
local function StartSequence()
    local settings = GetSettings()
    if not settings.enabled or not settings.autoUnbox then
        return
    end

    local unbox = GetUnbox()
    local pendingItemLink = unbox.pendingItemLink
    if not pendingItemLink or unbox.active then
        return
    end
    unbox.pendingItemLink = nil

    local now = GetGameTimeMilliseconds()

    -- Deliberately no "is the satchel in the bag" gate: on the buying visit
    -- the close events fire before the satchel lands (rule 1 in the header),
    -- so the loop waits for it to appear instead.
    unbox.active = true
    unbox.itemId = GetItemLinkItemId(pendingItemLink)
    unbox.startedAtMs = now
    unbox.deadlineMs = now + settings.unboxTimeoutMs
    unbox.seenInBag = false
    unbox.seenAtMs = 0
    unbox.useSent = false
    unbox.useSentAtMs = 0
    unbox.useUniqueId = nil
    unbox.attemptIntervalMs = 0
    unbox.nextAttemptAtMs = 0
    unbox.attemptCount = 0
    unbox.lastBlockReason = nil

    Log(string.format("Unbox +0ms: sequence started (item %d, give up after %dms)",
        unbox.itemId, settings.unboxTimeoutMs))
    EVENT_MANAGER:RegisterForUpdate(LOOP_UPDATE_NAME, LOOP_INTERVAL_MS, Loop)
end

local function OnInteractionEnded()
    local unbox = GetUnbox()
    if unbox.active then
        -- EVENT_CHATTER_END and EVENT_CLOSE_STORE both fire on a vendor exit;
        -- the first starts the sequence, later ones just refresh its deadline.
        unbox.deadlineMs = GetGameTimeMilliseconds() + GetSettings().unboxTimeoutMs
        return
    end
    StartSequence()
end

---Take All for the loot window our UseItem just opened. Time-window keyed
---(see header): loot windows inside the watch window are treated as ours.
---One LootAll per window: the event re-fires for every item the LootAll
---removes, so the watch is cleared after the first call.
local function OnLootUpdated()
    local unbox = GetUnbox()
    local now = GetGameTimeMilliseconds()
    if now > unbox.lootWatchUntilMs then
        return
    end
    unbox.lootWatchUntilMs = 0
    Log(string.format("Unbox: loot window %dms after UseItem; taking all",
        now - unbox.useSentAtMs))
    LootAll(false)
end

---Install the post-interaction triggers; called once from Main
function SatchelExchangeUnboxActions.InitializePersistentHandlers()
    -- Both fire when leaving a vendor; StartSequence de-dupes via unbox.active.
    EVENT_MANAGER:RegisterForEvent(PERSISTENT_NAMESPACE, EVENT_CHATTER_END, OnInteractionEnded)
    EVENT_MANAGER:RegisterForEvent(PERSISTENT_NAMESPACE, EVENT_CLOSE_STORE, OnInteractionEnded)
    EVENT_MANAGER:RegisterForEvent(PERSISTENT_NAMESPACE, EVENT_LOOT_UPDATED, OnLootUpdated)
end

SatchelExchange.UnboxActions = SatchelExchangeUnboxActions
