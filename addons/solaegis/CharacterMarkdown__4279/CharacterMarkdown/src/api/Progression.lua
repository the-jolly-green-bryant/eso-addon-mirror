-- CharacterMarkdown - API Layer - Progression
-- Abstraction for riding skills, age, enlightenment, and level

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.progression = {}

local api = CM.api.progression

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetRidingSkills()
    -- GetRidingStats: inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus
    local success, inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus =
        CM.SafeCallMulti(GetRidingStats)
    if not success then
        return {
            speed = 0,
            stamina = 0,
            capacity = 0,
            maxSpeed = 0,
            maxStamina = 0,
            maxCapacity = 0,
        }
    end
    -- Export as capacity/maxCapacity for generators (ESO "inventory" riding skill = bag capacity)
    return {
        speed = speedBonus or 0,
        stamina = staminaBonus or 0,
        capacity = inventoryBonus or 0,
        maxSpeed = maxSpeedBonus or 0,
        maxStamina = maxStaminaBonus or 0,
        maxCapacity = maxInventoryBonus or 0,
    }
end

function api.GetEnlightenment()
    local pool = CM.SafeCall(GetEnlightenedPool) or 0
    local cap = CM.SafeCall(GetEnlightenedPoolCap) or 0
    return {
        current = pool,
        max = cap,
    }
end

function api.GetAge()
    local seconds = CM.SafeCall(GetSecondsPlayed) or 0
    return seconds
end

function api.GetVeterancy()
    -- Historical check, mostly returns 0 now or maps to CP
    local rank = 0
    if GetUnitVeteranRank then
        rank = CM.SafeCall(GetUnitVeteranRank, "player") or 0
    end
    return rank
end

-- Composition functions moved to collector level
