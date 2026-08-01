-- ============================================================================
-- AKsAttributeBars - Settings Module
-- ============================================================================
-- Handles saved variables and user settings

local AKB = AKsAttributeBars

-- Create settings namespace
AKB.Settings = AKB.Settings or {}

-- Stat Window Constants for dropdown values
AKB.Settings.STAT_TYPES = {
    NONE = 0,
    PHYSICAL_RESISTANCE = 1,
    SPELL_RESISTANCE = 2,
    WEAPON_DAMAGE = 3,
    SPELL_DAMAGE = 4,
    PHYSICAL_PENETRATION = 5,
    SPELL_PENETRATION = 6,
    CRITICAL_CHANCE = 7,
    CRITICAL_RESIST = 8,
    CRITICAL_DAMAGE = 9
}

-- Enemy Name Type Constants
AKB.Settings.ENEMY_NAME_TYPES = {
    CHARACTER_NAME = 1,
    USERNAME = 2
}

-- Stat labels for UI display
AKB.Settings.STAT_LABELS = {
    [0] = "None",
    [1] = "Physical Resistance", 
    [2] = "Spell Resistance",
    [3] = "Weapon Damage",
    [4] = "Spell Damage", 
    [5] = "Physical Penetration",
    [6] = "Spell Penetration",
    [7] = "Critical Chance",
    [8] = "Critical Resist",
    [9] = "Critical Damage"
}

-- Enemy name type labels for UI display
AKB.Settings.ENEMY_NAME_LABELS = {
    [1] = "Character Name",
    [2] = "Username (Account)"
}

-- Default Settings
local defaultSettings = {
    -- UI Alignment Helper
    showGridlines = false,  -- Show alignment gridlines to help position UI elements
    
    showBars = false,  -- Default to off - let users choose to enable
    defaultBarsYPosition = 0,  -- Vertical offset for default bars
    defaultBarsProximity = 0,   -- Distance between default bars
    
    -- Custom bar positioning
    customBarsXPosition = 600,  -- X position for custom bars
    customBarsYPosition = 450,  -- Y position for custom bars
    
    -- Custom bar layout and appearance
    customBarLayout = 1,  -- 1 = Stacked (default), 2 = Pyramid
    customBarType = 1,  -- 1 = Expanded (default), 2 = Compact
    
    -- Text formatting
    textFormatType = 1,  -- 1 = Full (10,000), 2 = Short (10k), 3 = Decimal (10.5k)
    textColor = {r = 1.0, g = 1.0, b = 1.0},  -- White text by default
    hidePercentage = false,  -- Show percentage by default
    
    -- Bar colors
    healthBarColor = {r = 1.0, g = 0.0, b = 0.0},  -- Red
    magickaBarColor = {r = 0.0, g = 0.0, b = 1.0},  -- Blue
    staminaBarColor = {r = 0.0, g = 1.0, b = 0.0},  -- Green
    mountStaminaBarColor = {r = 0.0, g = 0.8, b = 0.0},  -- Darker green
    
    -- Mount stamina settings
    showMountStamina = true,  -- Show mount stamina bar when custom bars are enabled
    mountStaminaHeight = 12,  -- Height of mount stamina bar (thinner than main bars)
    
    -- Shield settings
    showShields = true,  -- Show shield indicators on health bars
    shieldColor = {r = 0.3, g = 0.7, b = 1.0, a = 0.6},  -- Light blue with transparency
    shieldInText = true,  -- Show shield values in health text
    
    -- Bar transparency
    barTransparency = 1.0,  -- 0.0 = fully transparent, 1.0 = fully opaque
    
    -- Auto-hide settings
    hideWhenFullAndOutOfCombat = false,  -- Hide bars when all attributes full and not in combat
    
    -- Player name display settings
    showPlayerName = true,      -- Show player name above bars
    showPlayerLevel = true,     -- Show player level and champion points
    showClassIcon = true,       -- Show class icon
    
    -- Chat box positioning and sizing
    chatBoxXPosition = 0,  -- X position offset from default
    chatBoxYPosition = 0,  -- Y position offset from default
    chatBoxWidth = 0,      -- Width adjustment (0 = default size)
    chatBoxHeight = 0,     -- Height adjustment (0 = default size)
    enableChatBoxCustomization = false,  -- Enable/disable chat box customization
    
    -- Enemy health bar settings
    showEnemyBars = false,              -- Master toggle for enemy health bars
    enemyBarXPosition = 0,              -- X offset from screen center
    enemyBarYPosition = -150,           -- Y offset from screen center (below crosshair)
    enemyBarWidth = 300,                -- Bar width in pixels
    enemyBarHeight = 20,                -- Bar height in pixels
    
    -- Enemy bar appearance
    enemyHealthColor = {r = 0.8, g = 0.2, b = 0.2},  -- Dark red for enemy health
    targetAllyHealthColor = {r = 0.2, g = 0.8, b = 0.2},  -- Green for friendly/ally targets
    enemyBarBackgroundColor = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},  -- Dark background
    enemyBarTransparency = 1.0,         -- 0.0 = fully transparent, 1.0 = fully opaque
    showEnemyName = true,               -- Show enemy name above bar
    showEnemyLevel = true,              -- Show enemy level next to name
    enemyNameType = 1,                  -- 1 = Character Name, 2 = Username (@AccountName)
    
    -- Enemy text settings
    enemyTextFormatType = 1,            -- 1 = Full (10,000), 2 = Short (10k), 3 = Decimal (10.5k)
    enemyHidePercentage = false,        -- Show percentage by default
    enemyTextColor = {r = 1.0, g = 1.0, b = 1.0},  -- White text by default
    
    hideEnemyBarsInUI = true,           -- Hide when map/inventory open (like player bars)

    -- Food/drink reminder
    showFoodDrinkReminder = true,       -- Show bread icon when no food/drink buff
    
    -- Custom Stat Window 1
    statWindow1Enabled = true,          -- Show stat window 1
    statWindow1Stat1 = 1,              -- 1=Physical Resistance, 2=Spell Resistance, 3=Weapon Damage, 4=Spell Damage, 5=Physical Penetration, 6=Spell Penetration, 7=Critical Chance, 8=Critical Resist, 9=Critical Damage
    statWindow1Stat2 = 0,              -- 0=None, 1-9=Same as above
    statWindow1XPosition = 100,         -- X position offset from custom bars
    statWindow1YPosition = 200,         -- Y position offset from custom bars
    
    -- Custom Stat Window 2
    statWindow2Enabled = false,         -- Show stat window 2
    statWindow2Stat1 = 3,              -- Default to Weapon Damage
    statWindow2Stat2 = 4,              -- Default to Spell Damage
    statWindow2XPosition = 300,         -- X position offset from custom bars
    statWindow2YPosition = 200,         -- Y position offset from custom bars
    
    -- Custom Stat Window 3
    statWindow3Enabled = false,         -- Show stat window 3
    statWindow3Stat1 = 7,              -- Default to Critical Chance
    statWindow3Stat2 = 8,              -- Default to Critical Resist
    statWindow3XPosition = 500,         -- X position offset from custom bars
    statWindow3YPosition = 200,         -- Y position offset from custom bars
}

-- Initialize saved variables
function AKB.Settings.Initialize()
    local SV_NAME = "AKsAttributeBarsSavedVars"
    local SV_VERSION = 1
    
    -- Load or create saved vars
    if ZO_SavedVars then
        AKB.settings = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VERSION, nil, defaultSettings)
    else
        -- Fallback to defaults if ZO_SavedVars not available
        AKB.settings = defaultSettings
    end
end

-- Save a setting to SavedVariables
function AKB.Settings.Save(key, value)
    if AKB.settings then
        AKB.settings[key] = value
    end
end

-- Get a setting value
function AKB.Settings.Get(key)
    if AKB.settings then
        return AKB.settings[key]
    end
    return defaultSettings[key]
end

-- Get all settings
function AKB.Settings.GetAll()
    return AKB.settings or defaultSettings
end

-- Utility functions for stat windows
function AKB.Settings.GetStatWindowConfig(windowNum)
    if windowNum < 1 or windowNum > 3 then
        return nil
    end
    
    local settings = AKB.Settings.GetAll()
    return {
        enabled = settings["statWindow" .. windowNum .. "Enabled"],
        stat1 = settings["statWindow" .. windowNum .. "Stat1"],
        stat2 = settings["statWindow" .. windowNum .. "Stat2"],
        xPosition = settings["statWindow" .. windowNum .. "XPosition"],
        yPosition = settings["statWindow" .. windowNum .. "YPosition"]
    }
end

-- Get display label for stat type
function AKB.Settings.GetStatLabel(statType)
    return AKB.Settings.STAT_LABELS[statType] or "Unknown"
end

-- Get list of stat choices for dropdowns (excluding None for first stat, including None for second stat)
function AKB.Settings.GetStatChoices(includeNone)
    local choices = {}
    local startIndex = includeNone and 0 or 1
    
    for i = startIndex, 9 do
        table.insert(choices, AKB.Settings.STAT_LABELS[i])
    end
    
    return choices
end

-- Get stat choices with values for LibAddonMenu2
function AKB.Settings.GetStatChoicesWithValues(includeNone)
    local choices = AKB.Settings.GetStatChoices(includeNone)
    local values = {}
    local startIndex = includeNone and 0 or 1
    
    for i = startIndex, 9 do
        table.insert(values, i)
    end
    
    return choices, values
end

-- Get enemy name type choices for dropdowns
function AKB.Settings.GetEnemyNameChoices()
    local choices = {}
    for i = 1, 2 do
        table.insert(choices, AKB.Settings.ENEMY_NAME_LABELS[i])
    end
    return choices
end

-- Get enemy name type choices with values for LibAddonMenu2
function AKB.Settings.GetEnemyNameChoicesWithValues()
    local choices = AKB.Settings.GetEnemyNameChoices()
    local values = {1, 2}
    return choices, values
end

-- Get display label for enemy name type
function AKB.Settings.GetEnemyNameLabel(nameType)
    return AKB.Settings.ENEMY_NAME_LABELS[nameType] or "Character Name"
end
