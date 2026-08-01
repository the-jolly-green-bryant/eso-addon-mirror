-- =============================================================================
-- === SigilOfAimTriangle Core Logic (SigilOfAimTriangle.lua)                ===
-- =============================================================================
--[[
    AddOn Name:         SigilOfAimTriangle
    Description:        Triangle-style crosshair reticle replacement with weapon swap and block flip animation
    Version:            1.0.1
    Author:             VollständigerName
    Dependencies:       None
--]]

SigilOfAimTriangle = {
    -- Internal namespace identifier (must match folder name)
    name = "SigilOfAimTriangle",
    
    -- Semantic version (Major=breaking, Minor=features, Patch=fixes)
    version = "1.0.1",
    
}

-- =============================================================================
-- == LOCALIZED ALIASES & RUNTIME REFERENCES ===================================
-- =============================================================================
--[[
    Purpose: Optimize frequent access patterns
    Contains:
    - Localized addon namespace reference
    - Cached event manager reference
    - SavedVariables placeholder initialization
--]]

local SOAT = SigilOfAimTriangle             -- Local namespace alias
local NAME = SOAT.name                 -- Immutable addon name

-- =============================================================================
-- == POSITION CONFIGURATION ===================================================
-- =============================================================================
-- Central positioning for the entire reticle
local RETICLE_POSITION_X = 0  -- X coordinate (0 = screen center)
local RETICLE_POSITION_Y = 0  -- Y coordinate (0 = screen center)

-- =============================================================================
-- == DISPLAY CONFIGURATION ====================================================
-- =============================================================================
-- Controls visibility of the original ESO reticle
local SHOW_ORIGINAL_RETICLE = false -- true = show original, false = hide original

-- =============================================================================
-- == SIZE AND SCALING CONFIGURATION ===========================================
-- =============================================================================
local TRIANGLE_SCALE = 0.15 -- Base scale factor for triangle elements
local TRIANGLE_Y_OFFSET = 45 * TRIANGLE_SCALE -- Vertical offset for triangle positioning
local Action_Scale = 0.9 -- Scale factor when actions are active (targeting, etc.)
local Action_Scale_BIG = 1.1 -- Bigger scale factor when actions are active (swimming, etc.)

-- Base rotation angles for triangle parts (in degrees)
local BASE_BOTTOM = 0 -- Bottom triangle element rotation
local BASE_LEFT = -240 -- Left triangle element rotation
local BASE_RIGHT = 240 -- Right triangle element rotation

-- Texture scaling factors
local TEXTURE_SCALE_X = 1.0 -- Horizontal texture scale
local TEXTURE_SCALE_Y = 1.55 -- Vertical texture scale

-- Reticle control dimensions calculated from base values
local RETICLE_CONTROL_WIDTH = 256 * TEXTURE_SCALE_X * TRIANGLE_SCALE
local RETICLE_CONTROL_HEIGHT = 256 * TEXTURE_SCALE_Y * TRIANGLE_SCALE

-- Bottom line positioning offsets
local BOTTOM_LINE_OFFSET_X = 1 * TEXTURE_SCALE_Y - 1 -- Horizontal offset for bottom element
local BOTTOM_LINE_OFFSET_Y = -TRIANGLE_Y_OFFSET * 2 -- Vertical offset for bottom element

-- Left line positioning offsets
local LEFT_LINE_OFFSET_X = -128 * TEXTURE_SCALE_Y * TRIANGLE_SCALE -- Horizontal offset for left element
local LEFT_LINE_OFFSET_Y = TRIANGLE_Y_OFFSET -- Vertical offset for left element

-- Right line positioning offsets
local RIGHT_LINE_OFFSET_X = 128 * TEXTURE_SCALE_Y * TRIANGLE_SCALE -- Horizontal offset for right element
local RIGHT_LINE_OFFSET_Y = TRIANGLE_Y_OFFSET -- Vertical offset for right element

-- Animation durations in milliseconds
local WEAPON_SWAP_MAIN_DURATION = 150 -- Duration for main weapon swap animation
local WEAPON_SWAP_BACK_DURATION = 150 -- Duration for back weapon swap animation
local BLOCK_ANIMATION_DURATION = 200 -- Duration for block flip animation

-- =============================================================================
-- == RUNTIME VARIABLE DECLARATIONS ============================================
-- =============================================================================
local reticleControl = nil -- Reference to the main reticle control
local bottomLine, leftLine, rightLine = nil, nil, nil -- References to triangle element controls

local isInitialized = false -- Flag indicating if addon is initialized
local triangleUpsideDown = false -- Current orientation state of triangle
local isBlocking = nil

-- =============================================================================
-- == BLOCK ANIMATION SUBSYSTEM ================================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Animates a texture control with rotation and offset for block down (unblocking) state
-- @param control: The texture control to animate
--------------------------------------------------------------------------------
local function animateRotateBlockDown(control)
    -- Create animation timeline
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    
    -- Add rotation animation (from upside down to normal)
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(math.pi) -- Start from 180 degrees (π radians)
    rotate:SetEndRotation(0) -- End at 0 degrees (normal orientation)
    rotate:SetDuration(BLOCK_ANIMATION_DURATION) -- Set animation duration

    -- Add offset transformation animation
    local transformOffset = timeline:InsertAnimation(ANIMATION_TRANSFORMOFFSET, control)
    local endX, endY = 0, 0 -- Initialize end position

    -- Calculate specific end position based on which triangle element is being animated
    if control == bottomLine then
        endX = 0
        endY = -BOTTOM_LINE_OFFSET_Y * 2
    elseif control == leftLine then
        endX = -LEFT_LINE_OFFSET_X/1.5
        endY = -LEFT_LINE_OFFSET_Y/1.5
    elseif control == rightLine then
        endX = -RIGHT_LINE_OFFSET_X/1.5
        endY = -RIGHT_LINE_OFFSET_Y/1.5
    end

    -- Set animation to move from calculated position back to original position
    transformOffset:SetStartOffset(endX, endY, 0) -- Start from offset position
    transformOffset:SetEndOffset(0, 0, 0) -- End at original position
    transformOffset:SetDuration(BLOCK_ANIMATION_DURATION) -- Set animation duration

    timeline:PlayFromStart() -- Start the animation immediately
end

--------------------------------------------------------------------------------
-- Animates a texture control with rotation and offset for block up (blocking) state
-- @param control: The texture control to animate
--------------------------------------------------------------------------------
local function animateRotateBlockUp(control)
    -- Create animation timeline
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    
    -- Add rotation animation (from normal to upside down)
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(0) -- Start from 0 degrees (normal orientation)
    rotate:SetEndRotation(math.pi) -- End at 180 degrees (π radians, upside down)
    rotate:SetDuration(BLOCK_ANIMATION_DURATION) -- Set animation duration

    -- Add offset transformation animation
    local transformOffset = timeline:InsertAnimation(ANIMATION_TRANSFORMOFFSET, control)
    local endX, endY = 0, 0 -- Initialize end position

    -- Calculate specific end position based on which triangle element is being animated
    if control == bottomLine then
        endX = 0
        endY = -BOTTOM_LINE_OFFSET_Y * 2
    elseif control == leftLine then
        endX = -LEFT_LINE_OFFSET_X/1.5
        endY = -LEFT_LINE_OFFSET_Y/1.5
    elseif control == rightLine then
        endX = -RIGHT_LINE_OFFSET_X/1.5
        endY = -RIGHT_LINE_OFFSET_Y/1.5
    end

    -- Set animation to move from original position to calculated offset position
    transformOffset:SetStartOffset(0, 0, 0) -- Start from original position
    transformOffset:SetEndOffset(endX, endY, 0) -- End at offset position
    transformOffset:SetDuration(BLOCK_ANIMATION_DURATION) -- Set animation duration

    timeline:PlayFromStart() -- Start the animation immediately
end

--------------------------------------------------------------------------------
-- Controls the animated flip of the entire triangle based on blocking state
-- @param targetUpsideDown: The desired orientation state (true = upside down)
--------------------------------------------------------------------------------
local function SetTriangleRotationAnimated(targetUpsideDown)
    -- Exit if triangle elements don't exist or state wouldn't change
    if not (bottomLine and leftLine and rightLine) then return end
    if targetUpsideDown == triangleUpsideDown then return end

    -- Animate to upside down orientation
    if targetUpsideDown then
        animateRotateBlockUp(bottomLine)
        animateRotateBlockUp(leftLine)
        animateRotateBlockUp(rightLine)
    else
    -- Animate to normal orientation
        animateRotateBlockDown(bottomLine)
        animateRotateBlockDown(leftLine)
        animateRotateBlockDown(rightLine)
    end

    -- Update current orientation state
    triangleUpsideDown = targetUpsideDown
end

-- =============================================================================
-- == WEAPON SWAP ANIMATION SUBSYSTEM ==========================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Animates a texture control with a full clockwise rotation for main weapon swap
-- @param control: The texture control to animate
--------------------------------------------------------------------------------
function animateRotateMainWeapon(control)
    -- Create animation timeline and rotation animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(0) -- Start from 0 radians
    rotate:SetEndRotation(-6.28319) -- Rotate clockwise 360 degrees (approx 2π radians)
    rotate:SetDuration(WEAPON_SWAP_MAIN_DURATION) -- Set animation duration

    timeline:PlayFromStart() -- Start the animation immediately

end

--------------------------------------------------------------------------------
-- Animates a texture control with a full counter-clockwise rotation for back weapon swap
-- @param control: The texture control to animate
--------------------------------------------------------------------------------
function animateRotateBackWeapon(control)
    -- Create animation timeline and rotation animation
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(0) -- Start from 0 radians
    rotate:SetEndRotation(6.28319) -- Rotate counter-clockwise 360 degrees (approx 2π radians)
    rotate:SetDuration(WEAPON_SWAP_BACK_DURATION) -- Set animation duration
    
    timeline:PlayFromStart() -- Start the animation immediately

end

--------------------------------------------------------------------------------
-- Event handler for weapon bar switching
-- @param eventCode: The event code from ESO
-- @param activeWeaponPair: The new active weapon bar (1 or 2)
-- @param locked: Whether the weapon swap is locked
--------------------------------------------------------------------------------
function OnWeaponBarSwitch(eventCode, activeWeaponPair, locked)
    -- Only proceed if all triangle elements exist
    if bottomLine and leftLine and rightLine then
        if activeWeaponPair == 1 then
            -- Animate all elements for main weapon swap
            animateRotateMainWeapon(bottomLine)
            animateRotateMainWeapon(leftLine)
            animateRotateMainWeapon(rightLine)
        else
            -- Animate all elements for back weapon swap
            animateRotateBackWeapon(bottomLine)
            animateRotateBackWeapon(leftLine)
            animateRotateBackWeapon(rightLine)
        end
        triangleUpsideDown = false
        SetTriangleRotationAnimated(isBlocking)
    end
end

-- =============================================================================
-- == CORE INITIALIZATION SUBSYSTEM ============================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Main initialization function for the addon
-- Sets up anchors, creates the reticle, and registers events
--------------------------------------------------------------------------------
function SigilOfAimTriangleInitialized()
    -- Clear any existing anchors and set new central positioning
    SigilOfAimTriangle:ClearAnchors()
    SigilOfAimTriangle:SetAnchor(CENTER, GuiRoot, CENTER, RETICLE_POSITION_X, RETICLE_POSITION_Y)

    -- Create the triangle reticle elements
    CreateSigilOfAimTriangleReticle()
    isInitialized = true -- Mark addon as initialized

    -- Register for weapon swap events
    EVENT_MANAGER:RegisterForEvent("SigilOfAimTriangleWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnWeaponBarSwitch)

    -- Debug output (commented out)
    --d("SigilOfAimTriangle initialized with weapon swap + block flip animation")
end

-- =============================================================================
-- == FRAME UPDATE SUBSYSTEM ===================================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Applies consistent style (color and scale) to all triangle elements
-- @param r: Red color component (0-1)
-- @param g: Green color component (0-1)
-- @param b: Blue color component (0-1)
-- @param a: Alpha transparency component (0-1)
-- @param scale: Size multiplier for the elements
--------------------------------------------------------------------------------
local function ApplyStyle(r, g, b, a, scale)
    -- Apply to bottom triangle element if it exists
    if bottomLine then
        bottomLine:SetColor(r, g, b, a)
        bottomLine:SetScale(scale)
    end
    -- Apply to left triangle element if it exists
    if leftLine then
        leftLine:SetColor(r, g, b, a)
        leftLine:SetScale(scale)
    end
    -- Apply to right triangle element if it exists
    if rightLine then
        rightLine:SetColor(r, g, b, a)
        rightLine:SetScale(scale)
    end
end

--------------------------------------------------------------------------------
-- Main update function called each frame
-- Handles visibility, blocking state, and visual feedback for different game states
--------------------------------------------------------------------------------
function SigilOfAimTriangleUpdate()
    -- Exit if addon isn't initialized
    if not isInitialized then return end

    -- Control visibility of original ESO reticle based on configuration
    ZO_ReticleContainerReticle:SetHidden(not SHOW_ORIGINAL_RETICLE)

    -- Hide custom reticle in mouse mode (UI navigation)
    local inMouseMode = IsGameCameraUIModeActive()
    local inSiegeWeapon = IsPlayerControllingSiegeWeapon()
        
    if reticleControl then
        reticleControl:SetHidden(inMouseMode or inSiegeWeapon)
    end

    -- Check if player is blocking and animate triangle flip accordingly
    isBlocking = IsBlockActive() or false
    SetTriangleRotationAnimated(isBlocking)

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

--------------------------------------------------------------------------------
-- Creates the triangle reticle with three individual texture elements
-- positioned to form a triangular shape
--------------------------------------------------------------------------------
function CreateSigilOfAimTriangleReticle()
    -- Exit if reticle already exists
    if reticleControl then return end

    -- Main parent control for the entire triangle reticle
    reticleControl = WINDOW_MANAGER:CreateControl("SigilOfAimTriangleCrosshair", SigilOfAimTriangle, CT_CONTROL)
    reticleControl:SetAnchor(CENTER, SigilOfAimTriangle, CENTER, 0, 0) -- Center alignment
    reticleControl:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT) -- Set dimensions

    -- Bottom triangle element
    bottomLine = WINDOW_MANAGER:CreateControl("$(parent)Bottom", reticleControl, CT_TEXTURE)
    bottomLine:SetAnchor(BOTTOM, reticleControl, BOTTOM, BOTTOM_LINE_OFFSET_X, BOTTOM_LINE_OFFSET_Y)
    bottomLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    bottomLine:SetTexture("SigilOfAimTriangle/SigilOfAimTriangle.dds") -- Texture file
    bottomLine:SetColor(0.95, 0.95, 0.95, 0.7) -- Default color (off-white)
    bottomLine:SetTextureRotation(math.rad(BASE_BOTTOM)) -- Initial rotation

    -- Left triangle element
    leftLine = WINDOW_MANAGER:CreateControl("$(parent)Left", reticleControl, CT_TEXTURE)
    leftLine:SetAnchor(BOTTOMLEFT, reticleControl, BOTTOM, LEFT_LINE_OFFSET_X, LEFT_LINE_OFFSET_Y)
    leftLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    leftLine:SetTexture("SigilOfAimTriangle/SigilOfAimTriangle.dds") -- Texture file
    leftLine:SetColor(0.95, 0.95, 0.95, 0.7) -- Default color (off-white)
    leftLine:SetTextureRotation(math.rad(BASE_LEFT)) -- Initial rotation

    -- Right triangle element
    rightLine = WINDOW_MANAGER:CreateControl("$(parent)Right", reticleControl, CT_TEXTURE)
    rightLine:SetAnchor(BOTTOMRIGHT, reticleControl, BOTTOM, RIGHT_LINE_OFFSET_X, RIGHT_LINE_OFFSET_Y)
    rightLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    rightLine:SetTexture("SigilOfAimTriangle/SigilOfAimTriangle.dds") -- Texture file
    rightLine:SetColor(0.95, 0.95, 0.95, 0.7) -- Default color (off-white)
    rightLine:SetTextureRotation(math.rad(BASE_RIGHT)) -- Initial rotation

    -- Initialize orientation state
    triangleUpsideDown = false
end

-- =============================================================================
-- == UI MODE HANDLING SUBSYSTEM ===============================================
-- =============================================================================

--------------------------------------------------------------------------------
-- Handles UI mode changes to show/hide reticle appropriately
-- @param eventCode: The event code from ESO
-- @param uiMode: The new UI mode
--------------------------------------------------------------------------------
function OnUIModeChanged(eventCode, uiMode)
    -- Hide reticle in UI mode, show in game mode
    if reticleControl then
        reticleControl:SetHidden(IsGameCameraUIModeActive())
    end
end

-- Register for UI mode change events
EVENT_MANAGER:RegisterForEvent("SigilOfAimTriangle", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnUIModeChanged)