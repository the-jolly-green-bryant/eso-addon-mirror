-- =============================================================================
-- === HidePlayerMapMarker Core Logic (HidePlayerMapMarker.lua)               ===
-- =============================================================================
--[[
    AddOn Name:         HidePlayerMapMarker
    Description:        Hides player marker on the map
    Version:            1.0.2
    Author:             VollständigerName
    Dependencies:       None
--]]
-- =============================================================================
--[[
    SYSTEM ARCHITECTURE:
    - Player Marker Suppression System
    - Settings Persistence
    - Slash Command Interface
    - Event-Based Initialization
--]]
-- =============================================================================

-- =============================================================================
-- == GLOBAL ADDON DEFINITION & VERSION CONTROL ================================
-- =============================================================================
--[[
    Purpose: Establishes fundamental addon identity and configuration
    Contains:
    - Addon metadata for ESO client recognition
    - Default settings configuration
    - Storage for original function handlers
--]]
local HidePlayerMapMarker = {
    name = "HidePlayerMapMarker",
    version = "1.0.2",
    settings = {
        enabled = true  -- Default: marker hidden
    },
    originalSetHidden = nil  -- Store original SetHidden function
}

-- =============================================================================
-- == LOCALIZED ALIASES & RUNTIME REFERENCES ===================================
-- =============================================================================
--[[
    Purpose: Optimizes frequent access patterns and reduces overhead
    Contains:
    - Localized addon namespace reference
    - Cached event manager reference
--]]
local HPM = HidePlayerMapMarker
local NAME = HPM.name
local EM = EVENT_MANAGER
local HPMSV -- SavedVariables reference

-- =============================================================================
-- == CORE FUNCTIONALITY: MARKER SUPPRESSION ===================================
-- =============================================================================
--[[
    Function: ModifiedSetHidden
    Purpose:
      Custom SetHidden function that respects addon settings
      
    Process Flow:
      1. Checks if addon is enabled
      2. If enabled: Forces marker to be hidden regardless of input
      3. If disabled: Passes through the original call with boolean conversion
--]]
local function ModifiedSetHidden(hidden, ...)
    if HPM.settings.enabled then
        HPM.originalSetHidden(ZO_MapPin0, true, ...)
    else
        -- Ensure hidden is a boolean value
        local isHidden = (hidden == true)
        HPM.originalSetHidden(ZO_MapPin0, isHidden, ...)
    end
end

-- =============================================================================
-- == MARKER CONTROL FUNCTIONS =================================================
-- =============================================================================
--[[
    Function: HPM.UpdateMarkerVisibility
    Purpose:
      Applies or removes marker suppression based on current settings
      
    Process Flow:
      1. Checks if ZO_MapPin0 exists
      2. Applies visibility setting:
         - If enabled: Forces marker to be hidden
         - If disabled: Forces marker to be shown
--]]
local function UpdateMarkerVisibility()
    if ZO_MapPin0 then
        if HPM.settings.enabled then
            HPM.originalSetHidden(ZO_MapPin0, true)
        else
            HPM.originalSetHidden(ZO_MapPin0, false)
        end
    end
end

-- =============================================================================
-- == SLASH COMMAND IMPLEMENTATION =============================================
-- =============================================================================
--[[
    Function: Slash Command Handler
    Purpose:
      Provides user interaction via chat commands
      
    Process Flow:
      1. Toggles enabled setting when /hideplayermapmarker is called
      2. Immediately updates marker visibility
      3. Provides visual feedback in chat
--]]
SLASH_COMMANDS["/hideplayermapmarker"] = function()
    HPM.settings.enabled = not HPM.settings.enabled
    UpdateMarkerVisibility()
    d("|c808080Hide|r Player map marker: " .. (HPM.settings.enabled and "|cFF0000hidden|r" or "|c00FF00shown|r"))
end

-- =============================================================================
-- == ADDON INITIALIZATION =====================================================
-- =============================================================================
--[[
    Function: HPM.Initialize
    Purpose:
      Performs addon initialization routines
      
    Process Flow:
      1. Waits for map pins to be created using a periodic check
      2. Backs up original SetHidden function for later restoration
      3. Replaces with custom function
      4. Applies initial configuration based on settings
--]]
local function Initialize()
    -- SavedVariables initialization
    HPMSV = ZO_SavedVars:NewAccountWide("HidePlayerMapMarkerSV", 1, nil, HPM.settings)
    HPM.settings = HPMSV

    -- Wait for map pins to be created
    EM:RegisterForUpdate(NAME .. "WaitForPin", 100, function()
        if ZO_MapPin0 and ZO_MapPin0.SetHidden then
            EM:UnregisterForUpdate(NAME .. "WaitForPin")
            
            -- Backup original function
            HPM.originalSetHidden = ZO_MapPin0.SetHidden
            
            -- Replace with custom function
            ZO_MapPin0.SetHidden = ModifiedSetHidden
            
            -- Apply initial setting
            UpdateMarkerVisibility()
        end
    end)
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
        EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

-- =============================================================================
-- == EVENT REGISTRATION =======================================================
-- =============================================================================
--[[
    Purpose: Registers necessary event handlers for addon operation
    Contains:
    - EVENT_ADD_ON_LOADED handler for delayed initialization
--]]
EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)