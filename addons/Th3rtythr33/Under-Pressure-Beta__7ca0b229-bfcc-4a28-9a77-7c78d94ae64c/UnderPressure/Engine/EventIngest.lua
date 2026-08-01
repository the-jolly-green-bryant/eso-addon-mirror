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
-- Second namespace used only in Tank mode, so EVENT_COMBAT_EVENT can carry a
-- different target filter than the primary registration. See Register().
local NAMESPACE_GROUP = "UnderPressure_IngestGroup"

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

    -- Values are passed straight through rather than boxed into a normalised
    -- event table. That table was one allocation per incoming hit, on the
    -- busiest path in the addon, for an abstraction with two producers and one
    -- consumer. Shield-absorbed hits are no longer distinguished as a separate
    -- "kind" because the engine treated both identically anyway.
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
    if category == UP.RISK.NONE then return end

    -- UNITS: EVENT_EFFECT_CHANGED reports beginTime/endTime in SECONDS, on the
    -- same clock as GetFrameTimeSeconds(). Everything else in this addon works
    -- in milliseconds (GetGameTimeMilliseconds). Convert here, at the boundary,
    -- and name the field so the unit travels with the value.
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

    UP.Engine.IngestEffect(now(), abilityId, category, changeType, endTimeMs)
    UP.Debug.LogEffect(category, abilityId)
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
    -- Combat events.
    --
    -- Solo mode only needs events targeting the local player: one registration,
    -- one filter.
    --
    -- Tank mode also needs events targeting groupmates. Through 0.2.8 development
    -- that was done by registering with NO target filter at all, which means
    -- every combat event the client receives crosses into Lua -- including the
    -- overwhelming majority that target NPCs (in a trial, every player's damage
    -- on the boss). Instead we register TWICE under separate namespaces, each
    -- with its own target filter: one for the local player, one for other
    -- players. Groupmates are other players, so this keeps everything Tank mode
    -- needs while discarding all NPC-targeted traffic at the C level, before it
    -- ever reaches a Lua callback. EVENT_MANAGER namespaces are independent
    -- registrations, so the same event can carry a different filter in each.
    local mode = (UP.sv and UP.sv.attacker_mode) or "solo"

    if UP.features.combatFilter then
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_COMBAT_EVENT, onCombatEvent)
        EVENT_MANAGER:AddFilterForEvent(NAMESPACE, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_IS_ERROR, false)

        if mode == "tank" and type(COMBAT_UNIT_TYPE_OTHER_PLAYER) == "number" then
            EVENT_MANAGER:RegisterForEvent(NAMESPACE_GROUP, EVENT_COMBAT_EVENT, onCombatEvent)
            EVENT_MANAGER:AddFilterForEvent(NAMESPACE_GROUP, EVENT_COMBAT_EVENT,
                REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_OTHER_PLAYER,
                REGISTER_FILTER_IS_ERROR, false)
        end
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
    -- Always attempt the group namespace: it may or may not be registered
    -- depending on the mode at Register() time, and unregistering an absent
    -- namespace is a no-op.
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE_GROUP, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
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
