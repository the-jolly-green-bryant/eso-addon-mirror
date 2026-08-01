-- =============================================================================
-- === HideReticleMounted Core Logic (HideReticleMounted.lua)                ===
-- =============================================================================
--[[
    AddOn Name:         HideReticleMounted
    Description:        Hides the default crosshair reticle only when mounted. 
                        Wished by stmagnus in ESOUI forum
    Version:            1.0.1
    Author:             VollständigerName
    Dependencies:       None
--]]
-- =============================================================================
--[[
    SYSTEM ARCHITECTURE:
    - Reticle Visibility Control System (Mount-Based)
    - Event-Based Mount State Detection
    - Automatic Visibility Management
    - Alpha-based control to avoid SetHidden() bugs
--]]
-- =============================================================================

-- =============================================================================
-- == GLOBAL ADDON DEFINITION & VERSION CONTROL ================================
-- =============================================================================
local HideReticleMounted = {
    name = "HideReticleMounted",
    version = "1.0.1"
}

-- =============================================================================
-- == LOCALIZED ALIASES & RUNTIME REFERENCES ===================================
-- =============================================================================
local HRM = HideReticleMounted
local NAME = HRM.name
local EM = EVENT_MANAGER

-- =============================================================================
-- == CORE FUNCTIONALITY: MOUNT-BASED RETICLE CONTROL ==========================
-- =============================================================================
--[[
    Function: UpdateReticleForMountState
    Purpose: Updates reticle visibility based on mount state
    Process Flow:
      1. Checks if reticle exists
      2. Gets current mount state using IsMounted()
      3. Sets reticle alpha accordingly (0 when mounted, 1 when not)
--]]
local function UpdateReticleForMountState()
    if ZO_ReticleContainerReticle then
        local isMounted = IsMounted()
        if isMounted then
            ZO_ReticleContainerReticle:SetAlpha(0)
        else
            ZO_ReticleContainerReticle:SetAlpha(1) 
        end
    end
end

-- =============================================================================
-- == MOUNT STATE EVENT HANDLER ================================================
-- =============================================================================
--[[
    Function: OnMountStateChanged
    Purpose: Handles mount state change events
    Process Flow:
      1. Called whenever mount state changes
      2. Updates reticle alpha immediately
--]]
local function OnMountStateChanged(eventCode, isMounted)
    if ZO_ReticleContainerReticle then
        if isMounted then
            ZO_ReticleContainerReticle:SetAlpha(0)
        else
            ZO_ReticleContainerReticle:SetAlpha(1)
        end
    end
end

-- =============================================================================
-- == CONTINUOUS UPDATE FOR INITIAL STATE ======================================
-- =============================================================================
--[[
    Function: WaitForReticleAndInitialize
    Purpose: Waits for reticle to exist then initializes
    Process Flow:
      1. Checks if reticle exists every 100ms
      2. Once found, stops checking
      3. Sets initial reticle alpha based on mount state
      4. Registers for mount state changes
--]]
local function WaitForReticleAndInitialize()
    if ZO_ReticleContainerReticle then
        EM:UnregisterForUpdate(NAME .. "WaitForReticle")
        UpdateReticleForMountState()
        EM:RegisterForEvent(NAME, EVENT_MOUNTED_STATE_CHANGED, OnMountStateChanged)
    end
end

-- =============================================================================
-- == ADDON INITIALIZATION =====================================================
-- =============================================================================
--[[
    Function: Initialize
    Purpose: Performs addon initialization routines
    Process Flow:
      1. Starts waiting for reticle to be created
      2. Sets up periodic check until reticle exists
--]]
local function Initialize()
    EM:RegisterForUpdate(NAME .. "WaitForReticle", 100, WaitForReticleAndInitialize)
end

-- =============================================================================
-- == EVENT HANDLER: ADDON LOADED ==============================================
-- =============================================================================
local function OnAddOnLoaded(event, addonName)
    if addonName == NAME then
        EM:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)
        Initialize()
    end
end

-- =============================================================================
-- == EVENT REGISTRATION =======================================================
-- =============================================================================
EM:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)