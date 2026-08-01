-- Beltalowda Fight Totals
-- Collects local player's raw damage, healing, and shield output totals
-- for the current fight via EVENT_COMBAT_EVENT and EVENT_EFFECT_CHANGED.
-- Each player accumulates their own totals and broadcasts them to the group
-- via a custom LibGroupBroadcast protocol (see GroupBroadcast.lua).
--
-- Damage: Sum of all outgoing damage hits (including shielded/blocked)
-- Healing: Sum of all outgoing heals to group members (excluding self-heals)
-- Shield Output: Sum of shield values applied to self and group members
--   (via EVENT_EFFECT_CHANGED + EVENT_UNIT_ATTRIBUTE_VISUAL correlation)

Beltalowda = Beltalowda or {}
Beltalowda.Data = Beltalowda.Data or {}
Beltalowda.Data.FightTotals = Beltalowda.Data.FightTotals or {}

local FT = Beltalowda.Data.FightTotals

-- ============================================================================
-- State
-- ============================================================================

FT.damage = 0
FT.healing = 0
FT.shielding = 0

-- Previous broadcast values (to detect changes)
FT.previousBroadcast = {
    damage = 0,
    healing = 0,
    shielding = 0,
}

-- Pending shield correlations: when EVENT_EFFECT_CHANGED fires a damage shield
-- from the local player, we record the unitTag + timestamp here. Then when
-- EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED/UPDATED fires for the same unitTag within
-- the same frame, we capture the shield value.
-- pendingShields[unitTag] = { timestamp = gameTimeMs }
FT.pendingShields = {}

FT.initialized = false
FT.registered = false

-- ============================================================================
-- Constants
-- ============================================================================

FT.CALLBACK_NAME = "BeltalowdaFightTotals"
FT.BROADCAST_INTERVAL = 3000    -- ms between broadcasts to group
FT.SHIELD_CORRELATION_WINDOW = 100  -- ms to match shield effect → visual

-- ============================================================================
-- Core API
-- ============================================================================

function FT.GetDamage()
    return FT.damage
end

function FT.GetHealing()
    return FT.healing
end

function FT.GetShielding()
    return FT.shielding
end

function FT.Reset()
    FT.damage = 0
    FT.healing = 0
    FT.shielding = 0
    FT.previousBroadcast.damage = 0
    FT.previousBroadcast.healing = 0
    FT.previousBroadcast.shielding = 0
    FT.pendingShields = {}
end

-- ============================================================================
-- Combat Event Handlers
-- ============================================================================

--[[
    Damage handler: accumulates outgoing damage to enemies.
    Filters: source is player or player pet, target is OTHER (enemy),
    source ~= target, hitValue > 0.
    Follows RdK HpDmgMeter.lua pattern (lines 714-720).
]]
function FT.OnCombatEventDamage(eventCode, result, isError, abilityName,
        abilityGraphic, abilityActionSlotType, sourceName, sourceType,
        targetName, targetType, hitValue, powerType, damageType, bLog,
        sourceUnitId, targetUnitId, abilityId, overflow)
    if targetType == COMBAT_UNIT_TYPE_OTHER
        and sourceName ~= targetName
        and hitValue > 0 then
        FT.damage = FT.damage + hitValue
    end
end

--[[
    Healing handler: accumulates outgoing heals to group members.
    Filters: source is player or player pet, source ~= target,
    hitValue > 0, target is in the group.
    Self-heals are excluded (sourceName ~= targetName).
    Follows RdK HpDmgMeter.lua pattern (lines 731-756).
]]
function FT.OnCombatEventHealing(eventCode, result, isError, abilityName,
        abilityGraphic, abilityActionSlotType, sourceName, sourceType,
        targetName, targetType, hitValue, powerType, damageType, bLog,
        sourceUnitId, targetUnitId, abilityId, overflow)
    if sourceName ~= targetName and hitValue > 0 then
        -- Only count heals on group members
        if FT.IsInGroup(targetName) then
            FT.healing = FT.healing + hitValue
        end
    end
end

--[[
    Check if a raw character name (e.g. "^NPlayerName") is in the current group.
    Uses GetGroupUnitTagByIndex to iterate through group members.
]]
function FT.IsInGroup(rawName)
    if not rawName or rawName == "" then return false end
    local groupSize = GetGroupSize()
    if groupSize == 0 then return false end

    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local unitName = GetRawUnitName(unitTag)
            if unitName == rawName then
                return true
            end
        end
    end
    return false
end

-- ============================================================================
-- Shield Output Tracking
-- ============================================================================

--[[
    EVENT_EFFECT_CHANGED handler for shield output correlation (step 1 of 2).
    When the local player applies a damage shield to any target, record that
    target's unitTag in pendingShields so we can match the shield value from
    the subsequent EVENT_UNIT_ATTRIBUTE_VISUAL event.
]]
function FT.OnEffectChanged(eventCode, changeType, effectSlot, effectName,
        unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType,
        effectType, abilityType, statusEffectType, unitName, unitId, abilityId,
        sourceType)
    -- Only care about new shields cast by the local player
    if changeType ~= EFFECT_RESULT_GAINED then return end
    if abilityType ~= ABILITY_TYPE_DAMAGESHIELD then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET then return end

    -- Record pending shield correlation for this unitTag
    if unitTag then
        FT.pendingShields[unitTag] = {
            timestamp = GetGameTimeMilliseconds(),
        }
    end
end

--[[
    EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED handler for shield output (step 2 of 2).
    When a shield visual is added to a unit that has a pending shield from
    our EVENT_EFFECT_CHANGED handler, capture the shield value.
]]
function FT.OnAttributeVisualAdded(eventCode, unitTag, unitAttributeVisual,
        statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end

    local pending = FT.pendingShields[unitTag]
    if not pending then return end

    local now = GetGameTimeMilliseconds()
    if now - pending.timestamp > FT.SHIELD_CORRELATION_WINDOW then
        -- Stale entry — clean up
        FT.pendingShields[unitTag] = nil
        return
    end

    -- Match found — accumulate the shield value
    if value and value > 0 then
        FT.shielding = FT.shielding + value
    end

    FT.pendingShields[unitTag] = nil
end

--[[
    EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED handler for shield output (step 2 of 2).
    When a shield visual is updated (e.g. shield refreshed/stacked) on a unit
    that has a pending shield, capture the delta.
]]
function FT.OnAttributeVisualUpdated(eventCode, unitTag, unitAttributeVisual,
        statType, attributeType, powerType, oldValue, newValue, oldMaxValue,
        newMaxValue, sequenceId)
    if unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end

    local pending = FT.pendingShields[unitTag]
    if not pending then return end

    local now = GetGameTimeMilliseconds()
    if now - pending.timestamp > FT.SHIELD_CORRELATION_WINDOW then
        FT.pendingShields[unitTag] = nil
        return
    end

    -- Capture the delta (new shield amount added)
    local delta = (newValue or 0) - (oldValue or 0)
    if delta > 0 then
        FT.shielding = FT.shielding + delta
    end

    FT.pendingShields[unitTag] = nil
end

-- ============================================================================
-- Broadcast Loop
-- ============================================================================

--[[
    Periodic broadcast of fight totals to the group via LGB protocol 229.
    Only sends if values have changed since last broadcast.
    Called every BROADCAST_INTERVAL ms (3000ms).
]]
function FT.BroadcastLoop()
    -- Only broadcast if in a group
    if GetGroupSize() == 0 then return end

    -- Check if values changed
    local d = math.floor(FT.damage / 1000)
    local h = math.floor(FT.healing / 1000)
    local s = math.floor(FT.shielding / 1000)

    if d == FT.previousBroadcast.damage
        and h == FT.previousBroadcast.healing
        and s == FT.previousBroadcast.shielding then
        return
    end

    FT.previousBroadcast.damage = d
    FT.previousBroadcast.healing = h
    FT.previousBroadcast.shielding = s

    -- Broadcast via GroupBroadcast
    local BN = Beltalowda.network
    if BN and BN.BroadcastFightTotals then
        BN.BroadcastFightTotals(d, h, s)
    end
end

-- ============================================================================
-- Event Registration
-- ============================================================================

--[[
    Helper to register a filtered combat event.
    Registers EVENT_COMBAT_EVENT with sourceType and result filters.
]]
local function RegisterCombatEvent(name, sourceType, resultType, handler)
    EVENT_MANAGER:RegisterForEvent(name, EVENT_COMBAT_EVENT, handler)
    EVENT_MANAGER:AddFilterForEvent(name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, sourceType,
        REGISTER_FILTER_COMBAT_RESULT, resultType)
end

--[[
    Register all combat event handlers for damage, healing, and shields.
    22 filtered combat event registrations + 2 shield visual events.
]]
function FT.RegisterCombatEvents()
    if FT.registered then return end

    local cb = FT.CALLBACK_NAME

    -- Damage events: PLAYER source
    RegisterCombatEvent(cb .. ".D1",  COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_DAMAGE, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D2",  COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_CRITICAL_DAMAGE, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D3",  COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_DOT_TICK, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D4",  COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_DOT_TICK_CRITICAL, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D5",  COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_DAMAGE_SHIELDED, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D6",  COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_BLOCKED_DAMAGE, FT.OnCombatEventDamage)

    -- Damage events: PLAYER_PET source
    RegisterCombatEvent(cb .. ".D7",  COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_DAMAGE, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D8",  COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_CRITICAL_DAMAGE, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D9",  COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_DOT_TICK, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D10", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_DOT_TICK_CRITICAL, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D11", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_DAMAGE_SHIELDED, FT.OnCombatEventDamage)
    RegisterCombatEvent(cb .. ".D12", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_BLOCKED_DAMAGE, FT.OnCombatEventDamage)

    -- Healing events: PLAYER source
    RegisterCombatEvent(cb .. ".H1", COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_HEAL, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H2", COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_CRITICAL_HEAL, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H3", COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_HOT_TICK, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H4", COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_HOT_TICK_CRITICAL, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H5", COMBAT_UNIT_TYPE_PLAYER, ACTION_RESULT_HEAL_ABSORBED, FT.OnCombatEventHealing)

    -- Healing events: PLAYER_PET source
    RegisterCombatEvent(cb .. ".H6", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_HEAL, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H7", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_CRITICAL_HEAL, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H8", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_HOT_TICK, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H9", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_HOT_TICK_CRITICAL, FT.OnCombatEventHealing)
    RegisterCombatEvent(cb .. ".H10", COMBAT_UNIT_TYPE_PLAYER_PET, ACTION_RESULT_HEAL_ABSORBED, FT.OnCombatEventHealing)

    -- Shield output: EVENT_EFFECT_CHANGED (step 1 — identifies caster)
    EVENT_MANAGER:RegisterForEvent(cb .. ".ShieldEffect", EVENT_EFFECT_CHANGED, FT.OnEffectChanged)

    -- Shield output: attribute visual events (step 2 — provides value)
    EVENT_MANAGER:RegisterForEvent(cb .. ".ShieldVisualAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, FT.OnAttributeVisualAdded)
    EVENT_MANAGER:RegisterForEvent(cb .. ".ShieldVisualUpd", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, FT.OnAttributeVisualUpdated)

    -- Broadcast loop
    EVENT_MANAGER:RegisterForUpdate(cb .. ".Broadcast", FT.BROADCAST_INTERVAL, FT.BroadcastLoop)

    FT.registered = true
end

--[[
    Unregister all combat event handlers.
]]
function FT.UnregisterCombatEvents()
    if not FT.registered then return end

    local cb = FT.CALLBACK_NAME

    -- Damage events
    for i = 1, 12 do
        EVENT_MANAGER:UnregisterForEvent(cb .. ".D" .. i, EVENT_COMBAT_EVENT)
    end

    -- Healing events
    for i = 1, 10 do
        EVENT_MANAGER:UnregisterForEvent(cb .. ".H" .. i, EVENT_COMBAT_EVENT)
    end

    -- Shield events
    EVENT_MANAGER:UnregisterForEvent(cb .. ".ShieldEffect", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(cb .. ".ShieldVisualAdd", EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
    EVENT_MANAGER:UnregisterForEvent(cb .. ".ShieldVisualUpd", EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)

    -- Broadcast loop
    EVENT_MANAGER:UnregisterForUpdate(cb .. ".Broadcast")

    FT.registered = false
end

-- ============================================================================
-- Initialization
-- ============================================================================

function FT.Initialize()
    if FT.initialized then return end
    FT.initialized = true
end
