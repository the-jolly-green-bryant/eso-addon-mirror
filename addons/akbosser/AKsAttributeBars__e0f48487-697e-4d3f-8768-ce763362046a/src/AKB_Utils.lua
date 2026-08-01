-- ============================================================================
-- AKsAttributeBars - Utility Functions Module
-- ============================================================================
-- Common utility functions used throughout the addon

local AKB = AKsAttributeBars

-- Create utils namespace
AKB.Utils = AKB.Utils or {}

-- Format numbers with commas for better readability
function AKB.Utils.FormatNumber(num)
    local formatted = tostring(num)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Format numbers based on user preference
function AKB.Utils.FormatNumberByType(num, formatType)
    if not num then return "0" end
    
    if formatType == 1 then
        -- Full format with commas (10,000)
        return AKB.Utils.FormatNumber(num)
    elseif formatType == 2 then
        -- Short format (10k)
        if num >= 1000000 then
            return string.format("%.0fm", num / 1000000)
        elseif num >= 1000 then
            return string.format("%.0fk", num / 1000)
        else
            return tostring(num)
        end
    elseif formatType == 3 then
        -- Decimal format (10.5k)
        if num >= 1000000 then
            return string.format("%.1fm", num / 1000000)
        elseif num >= 1000 then
            return string.format("%.1fk", num / 1000)
        else
            return tostring(num)
        end
    else
        -- Default to full format
        return AKB.Utils.FormatNumber(num)
    end
end

-- Generate unique control names to avoid conflicts
function AKB.Utils.GenerateUniqueName(baseName)
    return baseName .. "_" .. tostring(GetTimeStamp and GetTimeStamp() or os.time()) .. "_" .. tostring(math.random(1000, 9999))
end

-- Detect power types (handles both PC and console differences)
function AKB.Utils.DetectPowerTypes()
    -- Try common power type constants first
    local healthType = POWERTYPE_HEALTH or 0
    local magickaType = POWERTYPE_MAGICKA or 1  
    local staminaType = POWERTYPE_STAMINA or 2
    local mountStaminaType = 16 -- Hardcoded for this platform
    
    -- Console-specific fallback values if constants aren't available
    if not POWERTYPE_HEALTH then
        -- These are known console values from testing
        healthType = 32   -- Console health power type
        magickaType = 1   -- Console magicka power type  
        staminaType = 4   -- Console stamina power type
        mountStaminaType = 16  -- Mount stamina power type for this platform
    end
    
    return healthType, magickaType, staminaType, mountStaminaType
end

-- Initialize power types based on platform
local healthPowerType, magickaPowerType, staminaPowerType, mountStaminaPowerType = AKB.Utils.DetectPowerTypes()

-- Constants for power types (auto-detected for platform compatibility)
AKB.Utils.POWER_TYPES = {
    HEALTH = healthPowerType,
    MAGICKA = magickaPowerType,  
    STAMINA = staminaPowerType,
    MOUNT_STAMINA = mountStaminaPowerType
}

-- Get current shield value for a unit
function AKB.Utils.GetShieldValue(unitTag)
    if not GetUnitAttributeVisualizerEffectInfo then
        return 0
    end

    local tag = unitTag or "player"
    -- Use correct arguments for shield detection
    local visual = 5
    local stat = 20
    local attr = 1
    local powertype = 32

    local shieldValue, maxShieldValue = GetUnitAttributeVisualizerEffectInfo(tag, visual, stat, attr, powertype)

    return shieldValue or 0
end

-- Constants for bar dimensions and positioning
AKB.Utils.BAR_CONSTANTS = {
    WIDTH = 300,
    HEIGHT = 28,
    BORDER = 3,
    SPACING = 8,
    DEFAULT_X = 600,
    DEFAULT_Y = 450
}

-- Draw tiers for proper layering
AKB.Utils.DRAW_TIERS = {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3
}

-- Class icon paths mapping
AKB.Utils.CLASS_ICONS = {
    [1]   = "EsoUI/Art/Icons/class/class_dragonknight.dds",   -- Dragonknight
    [2]   = "EsoUI/Art/Icons/class/class_sorcerer.dds",       -- Sorcerer
    [3]   = "EsoUI/Art/Icons/class/class_nightblade.dds",     -- Nightblade
    [6]   = "EsoUI/Art/Icons/class/class_templar.dds",        -- Templar
    [4]   = "EsoUI/Art/Icons/class/class_warden.dds",         -- Warden
    [5]   = "EsoUI/Art/Icons/class/class_necromancer.dds",    -- Necromancer
    [117] = "EsoUI/Art/Icons/class/class_arcanist.dds",       -- Arcanist
}
