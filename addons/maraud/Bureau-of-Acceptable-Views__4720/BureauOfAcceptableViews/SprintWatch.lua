-- ===========================================================================
-- SprintWatch.lua
-- ---------------------------------------------------------------------------
-- One sprint detector for the whole addon, shared by every module that needs
-- to know whether the player is sprinting.
--
-- ESO exposes no factual "is sprinting" API. This module owns BAV's current
-- action-slot heuristic: when the player is moving and every normal active-bar
-- ability slot has a non-cost state failure, ESO is treating the bar as
-- unavailable for sprint. The signal is intentionally event-driven, mirroring
-- the client action-slot state without any external dependency.
--
-- Design rules (mirror OptionsWatch / Ease):
--   * ONE lazy detector for the whole addon. Engine events exist only while at
--     least one consumer is subscribed.
--   * Canonical state. IsSprinting() is the single source of truth for the
--     latest action-slot sample.
--   * Payload only. Subscribers receive boolean state edges and an immediate
--     seed; the engine-event lifecycle belongs here.
--   * Action-slot and combat edges settle through one coalesced 100 ms refresh,
--     avoiding transient action-slot states.
-- ===========================================================================

local addon = BureauOfAcceptableViews

addon.SprintWatch = addon.SprintWatch or {}
local SprintWatch = addon.SprintWatch

-- Hot-path / library globals bound to locals once at load.
local EVENT_MANAGER                    = EVENT_MANAGER
local pairs                            = pairs
local type                             = type
local next                             = next
local IsPlayerMoving                   = IsPlayerMoving
local IsUnitSwimming                   = IsUnitSwimming
local IsUnitFalling                    = IsUnitFalling
local IsUnitDeadOrReincarnating        = IsUnitDeadOrReincarnating
local IsMounted                        = IsMounted
local IsPlayerInWerewolfForm           = IsPlayerInWerewolfForm
local IsGameCameraSiegeControlled      = IsGameCameraSiegeControlled
local GetActiveWeaponPairInfo          = GetActiveWeaponPairInfo
local ActionSlotHasNonCostStateFailure = ActionSlotHasNonCostStateFailure

local EVENT_NAMESPACE = "BAV_SprintWatch"
local REFRESH_NAME    = "BAV_SprintWatch_Refresh"
local ROLL_DODGE_CLEAR_NAME = "BAV_SprintWatch_RollDodgeClear"
local REFRESH_DELAY_MS = 100
local ROLL_DODGE_SUPPRESSION_MS = 1000
local SPRINT_CONFIRM_SAMPLES = 2
local PLAYER_UNIT = "player"
local ROLL_DODGE_ABILITY_ID = 28549

-- Subscriber registry and detector state.
--   subscribers[name] = onChange  -- function(isSprinting:boolean)
--   isSprinting                   -- latest sampled value
--   eventsRegistered              -- true while engine events are active
--   refreshPending                -- one coalesced delayed refresh is queued
--   isPlayerRollDodging           -- blocks sprint during a bounded dodge window
local subscribers = {}
local isSprinting = false
local eventsRegistered = false
local refreshPending = false
local isPlayerRollDodging = false
local rollDodgeClearPending = false
local positiveSamples = 0
local ScheduleRefresh

-- Fan out a sample to every subscriber. Each module's SetPhysical already
-- no-ops on an unchanged value.
local function Dispatch(value)
    for _, onChange in pairs(subscribers) do
        if onChange then
            onChange(value)
        end
    end
end

-- Commit a fresh sample only when it differs from the canonical value.
local function SetSprinting(value)
    value = value and true or false
    if value == isSprinting then
        return
    end

    isSprinting = value
    Dispatch(isSprinting)
end

-- Read the current action-slot heuristic. This is not a factual engine sprint
-- query.
local function DetectSprinting()
    if not IsPlayerMoving()
        or IsUnitSwimming(PLAYER_UNIT)
        or IsUnitFalling(PLAYER_UNIT)
        or IsUnitDeadOrReincarnating(PLAYER_UNIT)
        or IsMounted()
        or IsPlayerInWerewolfForm()
        or IsGameCameraSiegeControlled()
        or isPlayerRollDodging then
        return false
    end

    local hotbarCategory = (GetActiveWeaponPairInfo() == ACTIVE_WEAPON_PAIR_MAIN)
        and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP

    for slotIndex = 3, 8 do
        if not ActionSlotHasNonCostStateFailure(slotIndex, hotbarCategory) then
            return false
        end
    end

    return true
end

local function Refresh()
    if not DetectSprinting() then
        positiveSamples = 0
        SetSprinting(false)
        return
    end

    positiveSamples = positiveSamples + 1
    if positiveSamples >= SPRINT_CONFIRM_SAMPLES then
        SetSprinting(true)
    else
        ScheduleRefresh()
    end
end

local function CancelRefresh()
    if not refreshPending then
        return
    end
    EVENT_MANAGER:UnregisterForUpdate(REFRESH_NAME)
    refreshPending = false
end

-- One-shot delayed refresh. Several slot updates in the same transition share
-- a single settle window instead of creating repeated reads.
local function OnRefreshElapsed()
    CancelRefresh()
    Refresh()
end

ScheduleRefresh = function()
    if refreshPending then
        return
    end
    refreshPending = true
    EVENT_MANAGER:RegisterForUpdate(REFRESH_NAME, REFRESH_DELAY_MS, OnRefreshElapsed)
end

local function OnActionSlotStateUpdated()
    ScheduleRefresh()
end

local function OnPlayerCombatState()
    ScheduleRefresh()
end

local function OnPhysicalStateChanged()
    positiveSamples = 0
    Refresh()
end

-- A player roll-dodge event suppresses false positives while the bar is
-- temporarily unavailable. Suppression is time-bounded because a rejected
-- dodge is not guaranteed to emit a matching completion/fade event.
local function CancelRollDodgeClear()
    if not rollDodgeClearPending then
        return
    end
    EVENT_MANAGER:UnregisterForUpdate(ROLL_DODGE_CLEAR_NAME)
    rollDodgeClearPending = false
end

local function OnRollDodgeClearElapsed()
    CancelRollDodgeClear()
    isPlayerRollDodging = false
    ScheduleRefresh()
end

local function OnCombatEvent()
    isPlayerRollDodging = true
    positiveSamples = 0
    CancelRefresh()
    SetSprinting(false)

    -- A rejected roll dodge can emit its start without a matching fade. Keep
    -- suppression bounded and re-arm it for repeated dodge events so sprint
    -- detection always recovers without depending on undocumented results.
    CancelRollDodgeClear()
    rollDodgeClearPending = true
    EVENT_MANAGER:RegisterForUpdate(
        ROLL_DODGE_CLEAR_NAME, ROLL_DODGE_SUPPRESSION_MS, OnRollDodgeClearElapsed)
end

local function RegisterDetectorEvents()
    if eventsRegistered then
        return
    end
    eventsRegistered = true

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_ACTION_SLOT_STATE_UPDATED, OnActionSlotStateUpdated)
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED, OnPhysicalStateChanged)
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_WEREWOLF_STATE_CHANGED, OnPhysicalStateChanged)
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_PLAYER_SWIMMING, OnPhysicalStateChanged)
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_PLAYER_NOT_SWIMMING, OnPhysicalStateChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE,
        EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE,
        COMBAT_UNIT_TYPE_PLAYER,
        REGISTER_FILTER_ABILITY_ID,
        ROLL_DODGE_ABILITY_ID)
end

local function UnregisterDetectorEvents()
    if not eventsRegistered then
        return
    end
    CancelRefresh()
    CancelRollDodgeClear()
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ACTION_SLOT_STATE_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_WEREWOLF_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_NOT_SWIMMING)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT)
    eventsRegistered = false
    isPlayerRollDodging = false
    positiveSamples = 0
end

-- ---------------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------------

-- True while the canonical action-slot sample says the player is sprinting.
function SprintWatch.IsSprinting()
    return isSprinting
end

-- True while `name` is currently subscribed.
function SprintWatch.IsSubscribed(name)
    return subscribers[name] ~= nil
end

-- Subscribe a module under `name` to sprint-state edges.
--   onChange(isSprinting) : called when the sampled flag flips, and once
--                           immediately with the current sample.
-- Re-subscribing under the same name replaces the callback (idempotent). The
-- detector is activated on the first subscriber.
function SprintWatch.Subscribe(name, onChange)
    if type(name) ~= "string" or name == "" then
        return
    end
    if type(onChange) ~= "function" then
        return
    end

    local wasEmpty = next(subscribers) == nil
    subscribers[name] = onChange

    if wasEmpty then
        RegisterDetectorEvents()
        Refresh()
        if not isSprinting then
            onChange(false)
        end
    else
        onChange(isSprinting)
    end
end

-- Drop a subscriber. The final unsubscribe releases all engine hooks and clears
-- the canonical state so a future first subscriber always receives a fresh read.
function SprintWatch.Unsubscribe(name)
    if subscribers[name] == nil then
        return
    end
    subscribers[name] = nil

    if next(subscribers) == nil then
        UnregisterDetectorEvents()
        isSprinting = false
    end
end
