-- =============================================================================
-- === HideCompassDistances Core Logic (HideCompassDistances.lua)             ===
-- =============================================================================
--[[
    AddOn Name:         HideCompassDistances
    Description:        Hides compass distance indicators in the game interface
    Version:            1.0.3
    Author:             VollständigerName
    Dependencies:       None
--]]
-- =============================================================================
--[[
    SYSTEM ARCHITECTURE:
    - Compass Distance Manipulation Engine
    - Settings Persistence System
    - Slash Command Interface
    - Event-Based Initialization
--]]
-- =============================================================================

-- =============================================================================
-- == GLOBAL ADDON DEFINITION & VERSION CONTROL ================================
-- =============================================================================
--[[
    Purpose: Establishes fundamental addon identity and version tracking
    Contains:
    - Addon metadata for ESO client recognition
    - Version control using semantic versioning (SemVer)
    - Settings persistence system
--]]

local HideCompassDistances = {
    -- Internal namespace identifier 
    name = "HideCompassDistances",
    
    -- Semantic version (Major=Breaking, Minor=Features, Patch=Fixes)
    version = "1.0.3",
    
    -- Settings configuration 
    settings = {
        hideDistances = true  -- Default: distances hidden
    },
    
    -- Original string storage for restoration purposes
    originalStrings = {}
}


-- =============================================================================
-- == LOCALIZED ALIASES & RUNTIME REFERENCES ===================================
-- =============================================================================
--[[
    Purpose: Optimizes frequent access patterns and reduces overhead
    Contains:
    - Localized addon namespace reference
    - Cached event manager reference
    - SavedVariables reference initialization
--]]

local HCD = HideCompassDistances     -- Local namespace alias
local NAME = HCD.name                -- Immutable addon name
local HCDSV                          -- Will hold SavedVariables reference
local EM = EVENT_MANAGER             -- Event system shortcut




-- =============================================================================
-- == CORE FUNCTIONALITY: DISTANCE MANIPULATION ================================
-- =============================================================================
--[[
    Function: UpdateDistances
    Purpose:
    Applies current settings to compass distance strings
    
    Process Flow:
    1. Checks hideDistances setting value
    2. Sets EsoStrings accordingly:
    - If true: Empty strings to hide distances
    - If false: Restores original strings
    3. Persists settings to SavedVariables
    --]]
    
local function UpdateDistances()
    if HCD.settings.hideDistances then
        -- Hide distance strings
        EsoStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER] = ""  -- Short distances
        EsoStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER] = ""  -- Long distances 
    else
        -- Restore original strings
        EsoStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER] = HCD.originalStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER] or ""
        EsoStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER] = HCD.originalStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER] or ""
    end
    
    -- Persist settings for future sessions
    --HCDSV = HCD.settings
end


-- =============================================================================
-- == ADDON INITIALIZATION & EVENT HANDLING ====================================
-- =============================================================================
--[[
    Function: Initialize
    Purpose:
    Performs addon initialization routines
    
    Process Flow:
    1. Backs up original strings for later restoration
    2. Loads saved settings if available
    3. Applies initial configuration
    --]]
    
local function Initialize()
    -- Backup original strings
    HCD.originalStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER] = EsoStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER]
    HCD.originalStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER] = EsoStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER]
    
    -- Load saved settings if available
    -- if HCDSV then
    --     HCD.settings = HCDSV
    -- end
    HCDSV = ZO_SavedVars:NewAccountWide("HideCompassDistancesSV", 1, nil, HCD.settings)
    HCD.settings = HCDSV
    
    -- Initial configuration application
    UpdateDistances()
end
    
-- =============================================================================
-- == SLASH COMMAND IMPLEMENTATION =============================================
-- =============================================================================
--[[
    Purpose: Provides user interaction via chat commands
    Process Flow:
        1. Registers /compassdistancetoggle command
        2. Toggles hideDistances setting when called
        3. Immediately updates distance display
        4. Provides visual feedback in chat
--]]
    
SLASH_COMMANDS["/hidecompassdistance"] = function()
    -- Toggle setting with safe null-check handling
    HCD.settings.hideDistances = not HCD.settings.hideDistances
    
    -- Immediate application of changes
    UpdateDistances()
    
    -- Visual feedback for user
    d("Compass distances: " .. (HCD.settings.hideDistances and "|cFF0000hidden|r" or "|c00FF00shown|r"))
end
    
-- =============================================================================
-- == EVENT HANDLER: ADDON LOADED ==============================================
-- =============================================================================
--[[
    Function: OnAddOnLoaded
    Purpose:
    Handles the EVENT_ADD_ON_LOADED event to initialize the addon
    only when its specific data is available
    
    Process Flow:
    1. Checks if the loaded addon is our own
    2. Unregisters event handler after successful initialization
    3. Performs addon initialization
    --]]
    
    local function OnAddOnLoaded(event, addonName)
        if addonName == NAME then
            -- Event unregistration after successful loading
            EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
            
            -- Addon initialization
            Initialize()
        end
    end
        
        
-- =============================================================================
-- == EVENT REGISTRATION & SYSTEM BOOTSTRAP ====================================
-- =============================================================================
--[[
    Purpose: Registers necessary event handlers for addon operation
    Contains:
    - EVENT_ADD_ON_LOADED handler for delayed initialization
    --]]
                
EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)