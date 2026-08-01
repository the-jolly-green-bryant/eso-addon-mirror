-- SatchelExchangeUnboxActions.lua: Optional built-in unboxer (off by default).
--
-- The game blocks item use during vendor interactions (CanInteractWithItem is
-- false the whole time), so the only workable strategy is to use the satchel
-- AFTER the interaction ends. This module starts a polling sequence when the
-- interaction closes: each tick it re-checks readiness (CanInteractWithItem,
-- item cooldown) and fires UseItem through CallSecureProtected the moment the
-- game allows it, retrying until the satchel leaves the bag or attempts run
-- out. Polling readiness (instead of a single fixed delay) is what should make
-- this feel snappier than generic autoloot addons.
--
-- Enable via the settings page and disable your external unboxer to compare.

---@type LibConsoleLogger
local CL = LibConsoleLogger

local BagUtils = SatchelExchange.BagUtils

local SatchelExchangeUnboxActions = {}

local PERSISTENT_NAMESPACE = "SatchelExchangeUnbox"
local RETRY_INTERVAL_MS = 300

local function Log(message)
    CL:Log("[SatchelExchange] " .. message)
end

---@return SatchelExchangeUnboxState
local function GetUnbox()
    return SatchelExchange.state.unbox
end

---@return SatchelExchangeSavedVars
local function GetSettings()
    return SatchelExchange.state.savedVars
end

local function EndSequence()
    local unbox = GetUnbox()
    unbox.active = false
    unbox.itemId = nil
    unbox.attemptsLeft = 0
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

local function Tick()
    local unbox = GetUnbox()
    if not unbox.active then
        return
    end

    local slotIndex = BagUtils.FindItemInBackpack(unbox.itemId)
    if not slotIndex then
        Log("Satchel unboxed; press Talk for the next one")
        EndSequence()
        return
    end

    if unbox.attemptsLeft <= 0 then
        local readiness = BagUtils.GetUseReadiness(slotIndex)
        Log("Unbox gave up: " .. BagUtils.FormatUseReadiness(readiness))
        EndSequence()
        return
    end
    unbox.attemptsLeft = unbox.attemptsLeft - 1

    -- The end-of-interaction events can fire while the old interaction is
    -- still winding down (or the player may have pressed Talk again already);
    -- in either case just wait a tick instead of using the item.
    if GetInteractionType() == INTERACTION_NONE then
        local readiness = BagUtils.GetUseReadiness(slotIndex)
        if BagUtils.IsReadyToUse(readiness) then
            local sent = TryUseItem(slotIndex)
            if not sent then
                Log("UseItem was rejected (in combat?); retrying")
            end
        end
    end

    zo_callLater(Tick, RETRY_INTERVAL_MS)
end

---Kick off a sequence for the armed item if one isn't already running
local function StartSequence()
    local settings = GetSettings()
    if not settings.enabled or not settings.autoUnbox then
        return
    end

    local session = SatchelExchange.state.session
    if not session.resumeItemLink then
        return
    end

    local unbox = GetUnbox()
    if unbox.active then
        return
    end

    local itemId = GetItemLinkItemId(session.resumeItemLink)
    if not BagUtils.FindItemInBackpack(itemId) then
        return
    end

    unbox.active = true
    unbox.itemId = itemId
    unbox.attemptsLeft = settings.unboxMaxAttempts

    zo_callLater(Tick, settings.unboxDelayMs)
end

local function OnInteractionEnded()
    StartSequence()
end

---Install the post-interaction triggers; called once from Main
function SatchelExchangeUnboxActions.InitializePersistentHandlers()
    -- Both fire when leaving a vendor; StartSequence de-dupes via unbox.active.
    EVENT_MANAGER:RegisterForEvent(PERSISTENT_NAMESPACE, EVENT_CHATTER_END, OnInteractionEnded)
    EVENT_MANAGER:RegisterForEvent(PERSISTENT_NAMESPACE, EVENT_CLOSE_STORE, OnInteractionEnded)
end

SatchelExchange.UnboxActions = SatchelExchangeUnboxActions
