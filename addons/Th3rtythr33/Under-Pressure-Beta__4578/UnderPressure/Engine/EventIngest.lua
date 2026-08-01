-- =============================================================================
-- Under Pressure -- EventIngest.lua
-- =============================================================================
-- Subscribes to combat, effect, power, and combat-state events. Normalizes
-- each event into a common threat-event struct and hands it to the pressure
-- engine.
--
-- Threat event struct:
--   { t        = number (ms timestamp),
--     kind     = "damage" | "effect" | "shieldHit",
--     amount   = number (post-mitigation observed damage, nil for non-damage),
--     abilityId = number_or_nil,
--     category = string from UP.RISK,
--     confidence = "high" | "medium" | "low" }
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

local function isHostileResult(result)
    -- ACTION_RESULT_* constants identify outcome categories. Damage-bearing
    -- results we care about. We exclude heals, immunity, dodged, missed.
    if not result then return false end
    if result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_DAMAGE_SHIELDED
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
        or result == ACTION_RESULT_BLOCKED_DAMAGE
        or result == ACTION_RESULT_PARTIAL_RESIST then
        return true
    end
    return false
end

local function isShieldHitResult(result)
    return result == ACTION_RESULT_DAMAGE_SHIELDED
end

-- ---------------------------------------------------------------------------
-- EVENT_COMBAT_EVENT handler
-- ---------------------------------------------------------------------------
local function onCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                              abilityActionSlotType, sourceName, sourceType,
                              targetName, targetType, hitValue, powerType,
                              damageType, log, sourceUnitId, targetUnitId,
                              abilityId, overflow)
    if isError then return end
    if not isHostileResult(result) then return end
    if not hitValue or hitValue <= 0 then return end

    local nowMs = now()

    -- Classify target scope for the attacker counter. Tank mode wants events
    -- targeting groupmates; Solo mode only cares about events on the local
    -- player. The Record() call internally enforces the mode-specific scope.
    local targetScope = "other"
    if UP.Attackers and UP.Attackers.ClassifyTarget then
        targetScope = UP.Attackers.ClassifyTarget(targetType, targetUnitId, targetName, nowMs)
        UP.Attackers.Record(nowMs, sourceUnitId, sourceName, targetScope)
    end

    -- The pressure engine itself only consumes events targeting the local
    -- player. Tank-mode group-target events feed the counter but not the
    -- pressure model. This keeps the indicator state (color/shape) honest:
    -- it still reflects YOUR risk of dying, not your groupmate's.
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local kind = isShieldHitResult(result) and "shieldHit" or "damage"
    local event = {
        t          = nowMs,
        kind       = kind,
        amount     = hitValue,
        abilityId  = abilityId,
        category   = UP.RISK.NONE,  -- damage events have no category; engine treats them as raw threat
        confidence = "high",
        damageType = damageType,
        result     = result,
    }

    if UP.Engine and UP.Engine.IngestEvent then
        UP.Engine.IngestEvent(event)
    end
    if UP.Debug and UP.Debug.LogEvent then
        UP.Debug.LogEvent(event)
    end
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
    local effect = { abilityId = abilityId, statusEffectType = statusEffectType }
    local category = UP.Classifier.classify(effect)
    if category == UP.RISK.NONE then return end

    local event = {
        t          = now(),
        kind       = "effect",
        amount     = nil,
        abilityId  = abilityId,
        category   = category,
        confidence = (UP.features.statusEffectType and statusEffectType) and "high" or "medium",
        changeType = changeType,
        endTime    = endTime,
    }

    if UP.Engine and UP.Engine.IngestEvent then
        UP.Engine.IngestEvent(event)
    end
    if UP.Debug and UP.Debug.LogEvent then
        UP.Debug.LogEvent(event)
    end
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
-- toggle the indicator's visibility through the UI module.
local function onPlayerDead(eventCode)
    if UP.UI and UP.UI.SetDead then UP.UI.SetDead(true) end
end

local function onPlayerAlive(eventCode)
    if UP.UI and UP.UI.SetDead then UP.UI.SetDead(false) end
end

-- ---------------------------------------------------------------------------
-- Registration
-- ---------------------------------------------------------------------------
function UP.Ingest.Register()
    -- Combat events. In Solo mode we ask the runtime to pre-filter to events
    -- targeting the local player; in Tank mode we MUST see events targeting
    -- groupmates too, so we skip the target-side filter and apply our own
    -- target classification inside the callback.
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_COMBAT_EVENT, onCombatEvent)
    local mode = (UnderPressureSavedVars and UnderPressureSavedVars.attacker_mode) or "solo"
    if UP.features.combatFilter and mode ~= "tank" then
        EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_IS_ERROR, false)
    end

    -- Effect/debuff changes on player
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED, onEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player")

    -- Power changes (health only; damage-shield power is not exposed)
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_POWER_UPDATE, onPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player")

    -- Combat state (used to decide when to render and when to fully decay)
    if UP.features.combatStateEvent then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE, onCombatStateChanged)
    end

    -- Death / revival (used to hide the indicator when the player is dead)
    if type(EVENT_PLAYER_DEAD) == "number" then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_DEAD, onPlayerDead)
    end
    if type(EVENT_PLAYER_ALIVE) == "number" then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ALIVE, onPlayerAlive)
    end
end

function UP.Ingest.Unregister()
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_POWER_UPDATE)
    if UP.features.combatStateEvent then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    end
    if type(EVENT_PLAYER_DEAD) == "number" then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_DEAD)
    end
    if type(EVENT_PLAYER_ALIVE) == "number" then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_ALIVE)
    end
end

-- Re-register listeners with the current Tank/Solo mode's filter setting.
-- Called from the Settings panel when the user flips the mode toggle so the
-- change takes effect immediately without a /reloadui.
function UP.Ingest.Rewire()
    UP.Ingest.Unregister()
    UP.Ingest.Register()
    if UP.Attackers and UP.Attackers.Clear then UP.Attackers.Clear() end
end
