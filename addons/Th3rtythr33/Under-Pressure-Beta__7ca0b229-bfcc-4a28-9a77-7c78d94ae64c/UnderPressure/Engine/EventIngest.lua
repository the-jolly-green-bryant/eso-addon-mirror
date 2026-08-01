-- =============================================================================
-- Under Pressure -- EventIngest.lua
-- =============================================================================
-- Subscribes to combat, effect, power, and combat-state events, and hands the
-- values each one carries to the pressure engine.
--
-- Every subscription here is scoped to the LOCAL PLAYER. The normalised
-- threat-event struct this file used to build was removed during 0.2.8 (one
-- table allocation per incoming hit, for an abstraction with two producers and
-- one consumer); the second, group-scoped combat registration Tank mode needed
-- was removed in 0.2.9 along with the mode itself.
-- =============================================================================

UP = UP or {}
UP.Ingest = {}

local NAMESPACE = "UnderPressure_Ingest"

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
local function now()
    return GetGameTimeMilliseconds()
end

-- ACTION_RESULT_* values we treat as incoming damage. Heals, immunity, dodges
-- and misses are excluded. Built once as a lookup set rather than evaluated as
-- a comparison chain per event -- this runs on every combat event the client
-- delivers, which in a busy fight is the highest-frequency code in the addon.
--
-- Each constant is added individually rather than via a list literal, because
-- a nil constant in a list would silently truncate an ipairs walk.
local HOSTILE_RESULTS = {}
local function addHostileResult(v)
    if type(v) == "number" then HOSTILE_RESULTS[v] = true end
end
addHostileResult(ACTION_RESULT_DAMAGE)
addHostileResult(ACTION_RESULT_DAMAGE_SHIELDED)
addHostileResult(ACTION_RESULT_CRITICAL_DAMAGE)
addHostileResult(ACTION_RESULT_DOT_TICK)
addHostileResult(ACTION_RESULT_DOT_TICK_CRITICAL)
addHostileResult(ACTION_RESULT_BLOCKED_DAMAGE)
addHostileResult(ACTION_RESULT_PARTIAL_RESIST)

-- ---------------------------------------------------------------------------
-- EVENT_COMBAT_EVENT handler
-- ---------------------------------------------------------------------------
local function onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType,
                              targetName, targetType, hitValue, powerType,
                              damageType, log, sourceUnitId, targetUnitId,
                              abilityId, overflow)
    if isError then return end
    if not HOSTILE_RESULTS[result] then return end
    if not hitValue or hitValue <= 0 then return end

    -- Only events targeting the local player matter, to the counter and to the
    -- pressure model alike. When the runtime supports filters this is already
    -- guaranteed at the C level; the check stays for the unfiltered fallback
    -- path below, and it now runs FIRST so the counter sees the same events the
    -- engine does.
    --
    -- Until 0.2.9 this check sat after the attacker-counter call, because Tank
    -- mode deliberately fed the counter groupmate-targeted events while keeping
    -- them out of the pressure model -- so the indicator shape stayed a readout
    -- of YOUR risk of dying, not your groupmate's. With Tank mode gone there is
    -- one scope for both.
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local nowMs = now()

    -- Values are passed straight through rather than boxed into a normalised
    -- event table. That table was one allocation per incoming hit, on the
    -- busiest path in the addon. Shield-absorbed hits are not distinguished as
    -- a separate "kind" because the engine treated both identically anyway.
    UP.Attackers.Record(nowMs, sourceUnitId, sourceName)
    UP.Engine.IngestDamage(nowMs, hitValue)
    UP.Debug.LogDamage(hitValue, abilityId)
end

-- ---------------------------------------------------------------------------
-- EVENT_EFFECT_CHANGED handler
-- ---------------------------------------------------------------------------
local function onEffectChanged(eventCode, changeType, effectSlot, effectName,
                                unitTag, beginTime, endTime, stackCount,
                                iconName, buffType, effectType, abilityType,
                                statusEffectType, unitName, unitId, abilityId,
                                sourceType)
    if unitTag ~= "player" then return end

    -- UNITS: EVENT_EFFECT_CHANGED reports beginTime/endTime in SECONDS, on the
    -- same clock as GetFrameTimeSeconds(). Everything else in this addon works
    -- in milliseconds (GetGameTimeMilliseconds). Convert here, once, at the
    -- boundary, and name the variable so the unit travels with the value.
    --
    -- This was the bug: through 0.2.8 development the raw seconds value was
    -- stored and then compared against a millisecond clock in expireEffects.
    -- Being ~1000x smaller it always compared as already-expired, so every
    -- timed debuff was dropped on the next tick and the whole risk-bonus layer
    -- silently contributed nothing. Verified against ZOS source --
    -- esoui/ingame/buffdebuff/buffdebuffstyles.lua computes
    -- "timeRemainingS = data.timeEnding - GetFrameTimeSeconds()".
    --
    -- endTime == 0 means no timed expiry (toggles, permanent auras); preserve
    -- that as 0 rather than converting it into a real timestamp.
    local endTimeMs = 0
    if type(endTime) == "number" and endTime > 0 then
        endTimeMs = endTime * 1000
    end

    -- SILENCE, CHECKED FIRST -- ahead of both early returns below.
    --
    -- This ordering is load-bearing. The isDebuff gate and the RISK.NONE gate
    -- would each discard a silence before it was ever seen: if the console
    -- runtime does not populate statusEffectType, the classifier falls back to a
    -- ~13-entry ability-ID table that will not contain the silence, so the
    -- category comes back NONE and the event is dropped. Silence detection does
    -- not depend on classification at all, so it must not sit behind it.
    --
    -- ONE detector, TWO consumers (0.3.2). isSilence() is the more robust test
    -- -- it accepts either abilityType or statusEffectType, where the classifier
    -- below trusts statusEffectType alone -- so it now drives the ring AND
    -- injects the CONTROL risk bonus directly, instead of also depending on the
    -- classifier's statusEffectType-only map to independently rediscover the
    -- same fact with weaker coverage. AbilityClassifier no longer carries a
    -- SILENCE entry at all (see AbilityClassifier.lua), so nothing downstream
    -- double-detects it. IngestEffect already no-ops safely on FADED regardless
    -- of the category passed in, so this is safe to call unconditionally.
    if UP.Silence.IsSilenceEffect(abilityType, statusEffectType) then
        UP.Silence.Record(abilityId, changeType, endTimeMs)
        UP.Debug.LogSilence(abilityId, changeType, abilityType, statusEffectType)
        UP.Engine.IngestEffect(now(), abilityId, UP.RISK.CONTROL, changeType, endTimeMs)
    end

    -- Only care about debuffs gained or refreshed. Use BUFF_EFFECT_TYPE_DEBUFF
    -- where available; fall back to effectType == 2.
    local isDebuff = false
    if type(BUFF_EFFECT_TYPE_DEBUFF) == "number" then
        isDebuff = (effectType == BUFF_EFFECT_TYPE_DEBUFF)
    else
        isDebuff = (effectType == 2)
    end
    if not isDebuff then return end

    -- We track GAINED and UPDATED. FADED clears the contribution in the engine.
    local category = UP.Classifier.classify(abilityId, statusEffectType)

    -- Logged BEFORE the RISK.NONE return, deliberately. An unclassified debuff
    -- is the interesting one when verifying detection on hardware -- it is what
    -- you need to see in order to add an ability ID to the classifier table, and
    -- returning first would hide exactly those.
    UP.Debug.LogEffect(category, abilityId, abilityType, statusEffectType)

    if category == UP.RISK.NONE then return end

    -- endTimeMs was converted from seconds at the top of this function.
    UP.Engine.IngestEffect(now(), abilityId, category, changeType, endTimeMs)
end

-- ---------------------------------------------------------------------------
-- EVENT_POWER_UPDATE handler (health deltas; shield power not exposed)
-- ---------------------------------------------------------------------------
local function onPowerUpdate(eventCode, unitTag, powerIndex, powerType,
                              powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" then return end
    if UP.Engine and UP.Engine.UpdatePower then
        UP.Engine.UpdatePower(powerType, powerValue, powerMax)
    end
end

-- ---------------------------------------------------------------------------
-- EVENT_PLAYER_COMBAT_STATE handler
-- ---------------------------------------------------------------------------
local function onCombatStateChanged(eventCode, inCombat)
    if UP.Engine and UP.Engine.SetCombatState then
        UP.Engine.SetCombatState(inCombat)
    end
    if UP.UI and UP.UI.SetInCombat then
        UP.UI.SetInCombat(inCombat)
    end
end

-- ---------------------------------------------------------------------------
-- Death / revival
-- ---------------------------------------------------------------------------
-- EVENT_PLAYER_ALIVE fires when the local player comes back alive (revive,
-- soul gem, wayshrine). EVENT_PLAYER_DEAD fires on death. Both are used to
-- toggle the indicator's visibility through the UI module, and (0.3.2) to
-- stop a lethal pre-death reading from surviving into the next life.
local function onPlayerDead(eventCode)
    if UP.UI and UP.UI.SetDead then UP.UI.SetDead(true) end
    -- Effects clear on death, but FADED events for them are not guaranteed to
    -- arrive. Clearing explicitly means the ring cannot survive a death.
    if UP.Silence and UP.Silence.Clear then UP.Silence.Clear() end
    -- Stop the 10 Hz tick from doing any work while dead. Health reads 0 the
    -- whole time, so left running it would just recompute TTD=0 (RED_THREE)
    -- every 100ms for no one to see -- the indicator is already hidden by
    -- SetDead above.
    if UP.Engine and UP.Engine.SetDead then UP.Engine.SetDead(true) end
end

-- ---------------------------------------------------------------------------
-- EVENT_EFFECTS_FULL_UPDATE handler
-- ---------------------------------------------------------------------------
-- Fires when the client's effect list has been replaced wholesale rather than
-- changed incrementally, so per-effect EVENT_EFFECT_CHANGED events are not
-- delivered for what is now active. Without this, silence state could be stale
-- with no event ever arriving to correct it.
local function onEffectsFullUpdate(eventCode)
    if UP.Silence and UP.Silence.Resync then UP.Silence.Resync() end
end

-- Order matters here. Reset() must run, and combat state must be re-seeded,
-- BEFORE UP.UI.SetDead(false) -- that call is what re-evaluates visibility,
-- and it must not find a stale RED_THREE reading or a stale inCombat value
-- still sitting there when it does. (SetInCombat below also re-evaluates
-- visibility on its own, but lastDead is still true at that point, so it
-- cannot prematurely reveal anything -- see Indicator.lua's shouldShow.)
local function onPlayerAlive(eventCode)
    -- Clears the damage buffer, active effects, and the published state back
    -- to green_square, and pushes that to the indicator immediately. Without
    -- this, whatever burst killed the player -- still within the damage
    -- buffer's 8s window -- keeps reading as lethal against whatever health
    -- they resurrect with, for as long as that window has left to run.
    if UP.Engine and UP.Engine.Reset then UP.Engine.Reset() end
    if UP.Engine and UP.Engine.SetDead then UP.Engine.SetDead(false) end

    -- EVENT_PLAYER_COMBAT_STATE only fires on a CHANGE (see the load-time
    -- seeding in UnderPressure.lua for the same reasoning). Re-querying here
    -- closes the gap where a combat-state transition around the death/revive
    -- boundary was missed or arrived out of order, leaving lastInCombat
    -- stale at the exact moment visibility is about to be re-evaluated.
    if type(IsUnitInCombat) == "function" then
        local ok, inCombat = pcall(IsUnitInCombat, "player")
        if ok then
            UP.Engine.SetCombatState(inCombat == true)
            if UP.UI and UP.UI.SetInCombat then UP.UI.SetInCombat(inCombat == true) end
        end
    end

    if UP.UI and UP.UI.SetDead then UP.UI.SetDead(false) end
end

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------
function UP.Ingest.Register()
    -- Combat events. One registration, filtered to the local player.
    --
    -- The filter matters more than it looks: without it every combat event the
    -- client receives crosses into Lua, including the overwhelming majority
    -- that target NPCs (in a trial, every player's damage on the boss). With it
    -- that traffic is discarded at the C level before reaching a Lua callback.
    if UP.features.combatFilter then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_COMBAT_EVENT, onCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_IS_ERROR, false)
    else
        -- No runtime filtering available: fall back to one unfiltered
        -- registration and sort it out in the callback, as before.
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_COMBAT_EVENT, onCombatEvent)
    end

    -- Effect/debuff changes on player
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED, onEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    -- Power changes (health only; damage-shield power is not exposed)
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_POWER_UPDATE, onPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player")

    -- Combat state (used to decide when to render and when to fully decay).
    -- Unconditional since 2026-07-29: EVENT_PLAYER_COMBAT_STATE is assumed
    -- present rather than probed. See APIAUDITS.md.
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE, onCombatStateChanged)

    -- Wholesale effect-list replacement (zone change, reload, resurrect).
    -- Re-reads silence state, which per-effect events will not report for
    -- effects that are already active.
    if type(EVENT_EFFECTS_FULL_UPDATE) == "number" then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_EFFECTS_FULL_UPDATE, onEffectsFullUpdate)
    end

    -- Death / revival (used to hide the indicator when the player is dead)
    if type(EVENT_PLAYER_DEAD) == "number" then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_DEAD, onPlayerDead)
    end
    if type(EVENT_PLAYER_ALIVE) == "number" then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ALIVE, onPlayerAlive)
    end
end

-- Counterpart to Register(). Nothing calls it as of 0.2.9 -- its only caller
-- was UP.Ingest.Rewire(), which re-registered when the user flipped the Tank/
-- Solo toggle. Kept because a teardown path is the natural pair of a setup one
-- and any future setting that changes how we subscribe will need it again.
function UP.Ingest.Unregister()
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    if type(EVENT_EFFECTS_FULL_UPDATE) == "number" then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_EFFECTS_FULL_UPDATE)
    end
    if type(EVENT_PLAYER_DEAD) == "number" then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_DEAD)
    end
    if type(EVENT_PLAYER_ALIVE) == "number" then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_ALIVE)
    end
end
