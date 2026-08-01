-- =============================================================================
-- Under Pressure -- FeatureDetect.lua
-- =============================================================================
-- Runtime detection of API capabilities that the research could not verify on
-- console. Each probe is non-destructive and runs once at addon init. Results
-- are stored in UP.features and consulted by the engine so the indicator
-- degrades gracefully rather than erroring if a particular API is absent.
--
-- See eso-console-api-surface.md, section 10, for the list of unknowns this
-- module is designed to neutralize.
-- =============================================================================

UP = UP or {}
UP.features = {}

local function safeCall(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c
end

-- ---------------------------------------------------------------------------
-- 1. Combat event filter availability
-- ---------------------------------------------------------------------------
-- PC: EVENT_MANAGER:AddFilterForEvent(EVENT_COMBAT_EVENT,
--          REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
-- Console: unverified. We probe by checking the constants exist; if either is
-- nil, we skip filter registration and apply the filter in our own callback.
local function probeCombatFilter()
    local hasConstant = (type(REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE) == "number")
                    and (type(COMBAT_UNIT_TYPE_PLAYER) == "number")
    local hasMethod = (EVENT_MANAGER and type(EVENT_MANAGER.AddFilterForEvent) == "function")
    return hasConstant and hasMethod
end

-- ---------------------------------------------------------------------------
-- 2. Damage shield power type
-- ---------------------------------------------------------------------------
-- GetUnitPower("player", COMBAT_MECHANIC_FLAGS_DAMAGE_SHIELD) on PC returns
-- absorb-layer value. On console the constant may or may not exist. If it
-- exists and the call returns numeric values we mark it available.
local function probeShieldPower()
    if type(COMBAT_MECHANIC_FLAGS_DAMAGE_SHIELD) ~= "number" then return false end
    local current, max = safeCall(GetUnitPower, "player", COMBAT_MECHANIC_FLAGS_DAMAGE_SHIELD)
    return type(current) == "number" and type(max) == "number"
end

-- ---------------------------------------------------------------------------
-- 3. Attribute visualizer events
-- ---------------------------------------------------------------------------
-- EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED/UPDATED/REMOVED carry shield/proc deltas
-- on PC. We can't probe firing directly; we only check the constants exist.
-- Engine treats this as "supplemental" so absence is non-fatal.
local function probeAttributeVisualEvents()
    return type(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED) == "number"
       and type(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED) == "number"
       and type(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED) == "number"
end

-- ---------------------------------------------------------------------------
-- 4. Combat-state event
-- ---------------------------------------------------------------------------
local function probeCombatStateEvent()
    return type(EVENT_PLAYER_COMBAT_STATE) == "number"
end

-- ---------------------------------------------------------------------------
-- 5. Status-effect-type field on EVENT_EFFECT_CHANGED
-- ---------------------------------------------------------------------------
-- StatusEffectType lets us classify CC/anti-heal by category rather than by
-- maintaining a per-ability-ID list. The enum is defined on PC; on console
-- we check the constants exist. If they do, the classifier uses them; if not
-- it falls back to the static ID table.
local function probeStatusEffectType()
    return type(STATUS_EFFECT_TYPE_MAGIC) == "number"
        or type(STATUS_EFFECT_TYPE_STUN) == "number"
        or type(STATUS_EFFECT_TYPE_SNARE) == "number"
end

-- ---------------------------------------------------------------------------
-- 6. Group unit tag availability
-- ---------------------------------------------------------------------------
-- For Phase 2. We probe by reading group1 health; if it returns nil or zero
-- with no group present that's expected. We only flag as "available" if the
-- call doesn't error.
local function probeGroupTags()
    if type(COMBAT_MECHANIC_FLAGS_HEALTH) ~= "number" then return false end
    local ok = pcall(GetUnitPower, "group1", COMBAT_MECHANIC_FLAGS_HEALTH)
    return ok
end

-- ---------------------------------------------------------------------------
-- 7. GetGameTimeMilliseconds
-- ---------------------------------------------------------------------------
-- Foundational for the rolling-window math. If absent the engine cannot work.
local function probeGameTime()
    return type(GetGameTimeMilliseconds) == "function"
       and type(GetGameTimeMilliseconds()) == "number"
end

-- ---------------------------------------------------------------------------
-- 8. Source-type constants for distinguishing player vs NPC damage
-- ---------------------------------------------------------------------------
-- COMBAT_UNIT_TYPE_OTHER_PLAYER identifies damage coming from enemy/other
-- players. COMBAT_UNIT_TYPE_PLAYER_PET covers sorc pets, warden bears, etc.
-- If either constant is absent on console, the smart-hybrid weighting
-- gracefully falls back to treating every source equally (matches the
-- pre-hybrid behavior, so no regression).
local function probeSourceType()
    return type(COMBAT_UNIT_TYPE_OTHER_PLAYER) == "number"
end

-- ---------------------------------------------------------------------------
-- Run all probes
-- ---------------------------------------------------------------------------
function UP.RunFeatureDetect()
    UP.features.combatFilter         = probeCombatFilter()
    UP.features.shieldPower          = probeShieldPower()
    UP.features.attributeVisual      = probeAttributeVisualEvents()
    UP.features.combatStateEvent     = probeCombatStateEvent()
    UP.features.statusEffectType     = probeStatusEffectType()
    UP.features.groupTags            = probeGroupTags()
    UP.features.gameTime             = probeGameTime()
    UP.features.sourceType           = probeSourceType()

    if UP.Debug and UP.Debug.Log then
        UP.Debug.Log("FeatureDetect results:")
        for k, v in pairs(UP.features) do
            UP.Debug.Log(("  %s = %s"):format(k, tostring(v)))
        end
    end

    -- Hard fatal: without game time we cannot compute any window
    if not UP.features.gameTime then
        d("[Under Pressure] GetGameTimeMilliseconds unavailable. Cannot start.")
        return false
    end
    return true
end
