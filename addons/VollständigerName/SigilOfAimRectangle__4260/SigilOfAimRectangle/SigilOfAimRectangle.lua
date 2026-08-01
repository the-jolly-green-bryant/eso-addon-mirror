-- =============================================================================
-- === SigilOfAimRectangle Core Logic (SigilOfAimRectangle.lua)                          ===
-- =============================================================================
--[[
    AddOn Name:         SigilOfAimRectangle
    Description:        Custom dot-style crosshair reticle replacement
    Version:            1.0.1
    Author:             VollständigerName
    Dependencies:       None
--]]
-- =============================================================================
--[[
    SYSTEM ARCHITECTURE:
    - Custom Reticle Rendering Engine
    - Dynamic State Detection System
    - UI Mode Awareness Handler
    - Event-Based Initialization
--]]
-- =============================================================================

-- Global table for addon (main container)
SigilOfAimRectangle = {}

-- Local variables for better performance
local reticleControl = nil    -- Reference to crosshair texture element
local isInitialized = false   -- Status variable to prevent duplicate initialization
local Action_Scale = 0.9 -- Scale factor when actions are active (targeting, etc.)
local Action_Scale_BIG = 1.1 -- Bigger scale factor when actions are active (swimming, etc.)

-- =============================================================================
-- == CORE INITIALIZATION SUBSYSTEM ============================================
-- =============================================================================
--[[
    Function: SigilOfAimRectangleInitialized
    Purpose: Main initialization routine
    Logic:
    1. Clear existing anchors
    2. Center align to screen
    3. Create custom reticle texture
    4. Set initialization flag
    5. Debug output
--]]

--------------------------------------------------------------------------------
-- Main Initialization Function
-- @return: None
--------------------------------------------------------------------------------
function SigilOfAimRectangleInitialized()
    -- Clear all existing anchor points
    SigilOfAimRectangle:ClearAnchors()
    -- Anchor crosshair to screen center
    SigilOfAimRectangle:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    
    -- Create custom crosshair texture
    CreateSigilOfAimRectangleReticle()
    -- Set initialization flag to prevent duplicate calls
    isInitialized = true
    
    -- Debug console output
    d("SigilOfAimRectangle initialized")
end

-- =============================================================================
-- == FRAME UPDATE SUBSYSTEM ===================================================
-- =============================================================================
--[[
    Function: SigilOfAimRectangleUpdate
    Purpose: Per-frame update handler
    Logic:
    1. Skip if not initialized
    2. Hide default ESO reticle
    3. Handle UI mode visibility
    4. Query player state variables
    5. Apply dynamic reticle adjustments
--]]

--------------------------------------------------------------------------------
-- Applies consistent style (color and scale) to all triangle elements
-- @param r: Red color component (0-1)
-- @param g: Green color component (0-1)
-- @param b: Blue color component (0-1)
-- @param a: Alpha transparency component (0-1)
-- @param scale: Size multiplier for the elements
--------------------------------------------------------------------------------
local function ApplyStyle(r, g, b, a, scale)
    reticleControl:SetColor(r, g, b, a)
    reticleControl:SetScale(scale)
end

--------------------------------------------------------------------------------
-- Frame Update Handler
-- @return: None
--------------------------------------------------------------------------------
function SigilOfAimRectangleUpdate()
    -- Exit if not initialized
    if not isInitialized then return end
    
    -- Hide default ESO crosshair
    ZO_ReticleContainerReticle:SetHidden(true)
    
    -- Check if player is in mouse mode
    local inMouseMode = IsGameCameraUIModeActive()
    local inSiegeWeapon = IsPlayerControllingSiegeWeapon()
        
    if reticleControl then
        reticleControl:SetHidden(inMouseMode or inSiegeWeapon)
    end
    
    -- Get various game state information for visual feedback
    local playerStealth = GetUnitStealthState("player") -- Player's stealth state
    local playerDisguised = GetUnitDisguiseState("player") ~= DISGUISE_STATE_NONE -- Player's disguise state
    local targetUnitHighlighted = (GetUnitNameHighlightedByReticle() ~= "" and IsGameCameraUnitHighlightedAttackable()) -- Target is attackable
    local targetUnitInteractable = GetGameCameraInteractableInfo() -- Target is interactable

    -- Apply different styles based on game state
    if playerStealth > 0 then
        -- Stealth state: white with full transparency
        ApplyStyle(1, 1, 1, 0, 1.0)

    elseif IsUnitDead("player") then
        -- Dead state: black with full transparency
        ApplyStyle(0, 0, 0, 0, 1.0 * Action_Scale_BIG)

    elseif IsUnitReincarnating("player") then
        -- Reincarnating state: blue with medium visibility
        ApplyStyle(0.1, 0.8, 0.9, 0.8, 1.0 * Action_Scale_BIG)
    
    elseif IsUnitFalling("player") then
        -- Falling state: off-white with medium visibility
        ApplyStyle(0.95, 0.95, 0.95, 0.7, 1.0 * Action_Scale_BIG)

    elseif IsUnitSwimming("player") then
        -- Swimming state: blue with medium visibility
        ApplyStyle(0.1, 0.3, 0.9, 0.8, 1.0 * Action_Scale_BIG)        

    elseif IsPlayerStunned() then
        -- Disguised state: black with low visibility
        ApplyStyle(0, 0, 0, 0.4, 1.0 * Action_Scale_BIG)     

    elseif IsUnitInCombat("player") then
        -- Combat state: bright red for immediate recognition
        ApplyStyle(0.7, 0.1, 0.1, 0.9, 1.0 * Action_Scale)        

    elseif targetUnitHighlighted then
        -- Attackable target: orange-red with high visibility
        ApplyStyle(0.9, 0.3, 0.1, 0.8, 1.0 * Action_Scale)

    elseif targetUnitInteractable then
        -- Interactable target: orange-yellow with high visibility
        ApplyStyle(0.9, 0.6, 0.1, 0.8, 1.0 * Action_Scale)
        
    elseif playerDisguised then
        -- Disguised state: black with low visibility
        ApplyStyle(0, 0, 0, 0.4, 1.0 * Action_Scale)

    else
        -- Default state: off-white with medium visibility
        ApplyStyle(0.95, 0.95, 0.95, 0.7, 1.0)
    end
end

-- =============================================================================
-- == RETICLE CREATION SUBSYSTEM ===============================================
-- =============================================================================
--[[
    Function: CreateSigilOfAimRectangleReticle
    Purpose: Create custom reticle texture
    Logic:
    1. Skip if already exists
    2. Create new texture control
    3. Set anchors and dimensions
    4. Load custom texture
    5. Apply default color
--]]

--------------------------------------------------------------------------------
-- Custom Reticle Creation Function
-- @return: None
--------------------------------------------------------------------------------
function CreateSigilOfAimRectangleReticle()
    -- Exit if already created
    if reticleControl then return end
    
    -- Create new texture control in UI manager
    reticleControl = WINDOW_MANAGER:CreateControl("SigilOfAimRectangleCrosshair", SigilOfAimRectangle, CT_TEXTURE)
    -- Clear existing anchors
    reticleControl:ClearAnchors()
    -- Center texture in crosshair container
    reticleControl:SetAnchor(CENTER, SigilOfAimRectangle, CENTER, 0, 0)
    -- Texture dimensions in pixels (8x8)
    reticleControl:SetDimensions(16, 16)
    
    -- Load custom addon texture
    reticleControl:SetTexture("SigilOfAimRectangle/SigilOfAimRectangle.dds")
    -- Initial color: light gray with low opacity
    reticleControl:SetColor(0.95, 0.95, 0.95, 0.7)
end

-- =============================================================================
-- == UI MODE HANDLING SUBSYSTEM ===============================================
-- =============================================================================
--[[
    Function: OnUIModeChanged
    Purpose: Handle UI mode changes (Mouse/Gamepad)
    Logic:
    1. Only react if reticle exists
    2. Hide in mouse mode, show in gamepad mode
--]]

--------------------------------------------------------------------------------
-- UI Mode Change Event Handler
-- @param eventCode: Event code (unused)
-- @param uiMode: New UI mode
-- @return: None
--------------------------------------------------------------------------------
function OnUIModeChanged(eventCode, uiMode)
    -- Only react if crosshair exists
    if reticleControl then
        -- Hide crosshair in mouse mode, show in gamepad mode
        reticleControl:SetHidden(IsGameCameraUIModeActive())
    end
end

-- Register event listener for UI mode changes
EVENT_MANAGER:RegisterForEvent("SigilOfAimRectangle", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnUIModeChanged)