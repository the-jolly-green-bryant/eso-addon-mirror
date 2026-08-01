-- =============================================================================
-- === SigilOfAimTriangle Core Logic (Updated for Menu Integration)          ===
-- =============================================================================

SigilOfAimTriangle = {
    name = "SigilOfAimTriangle",
    version = "1.0.1",
    isEnabled = true,
    savedVars = nil,
}

-- Local namespace alias
local SOAT = SigilOfAimTriangle
local NAME = SOAT.name

-- =============================================================================
-- == POSITION CONFIGURATION ===================================================
-- =============================================================================
local RETICLE_POSITION_X = 0
local RETICLE_POSITION_Y = 0

-- =============================================================================
-- == DISPLAY CONFIGURATION ====================================================
-- =============================================================================
local SHOW_ORIGINAL_RETICLE = false

-- =============================================================================
-- == SIZE AND SCALING CONFIGURATION ===========================================
-- =============================================================================
local TRIANGLE_SCALE = 0.15
local TRIANGLE_Y_OFFSET = 45 * TRIANGLE_SCALE
local Action_Scale = 0.9
local Action_Scale_BIG = 1.1

-- Base rotation angles for triangle parts (in degrees)
local BASE_BOTTOM = 0
local BASE_LEFT = -240
local BASE_RIGHT = 240

-- Texture scaling factors
local TEXTURE_SCALE_X = 1.0
local TEXTURE_SCALE_Y = 1.55

-- Reticle control dimensions
local RETICLE_CONTROL_WIDTH = 256 * TEXTURE_SCALE_X * TRIANGLE_SCALE
local RETICLE_CONTROL_HEIGHT = 256 * TEXTURE_SCALE_Y * TRIANGLE_SCALE

-- Positioning offsets
local BOTTOM_LINE_OFFSET_X = 1 * TEXTURE_SCALE_Y - 1
local BOTTOM_LINE_OFFSET_Y = -TRIANGLE_Y_OFFSET * 2
local LEFT_LINE_OFFSET_X = -128 * TEXTURE_SCALE_Y * TRIANGLE_SCALE
local LEFT_LINE_OFFSET_Y = TRIANGLE_Y_OFFSET
local RIGHT_LINE_OFFSET_X = 128 * TEXTURE_SCALE_Y * TRIANGLE_SCALE
local RIGHT_LINE_OFFSET_Y = TRIANGLE_Y_OFFSET

-- Animation durations in milliseconds
local WEAPON_SWAP_MAIN_DURATION = 150
local WEAPON_SWAP_BACK_DURATION = 150
local BLOCK_ANIMATION_DURATION = 200

-- =============================================================================
-- == RUNTIME VARIABLE DECLARATIONS ============================================
-- =============================================================================
local reticleControl = nil
local bottomLine, leftLine, rightLine = nil, nil, nil
local isInitialized = false
local triangleUpsideDown = false
local isBlocking = nil

-- =============================================================================
-- == MODULE CONTROL FUNCTIONS ================================================
-- =============================================================================

function SigilOfAimTriangle.SetEnabled(enabled)
    SigilOfAimTriangle.isEnabled = enabled
    if reticleControl then
        reticleControl:SetHidden(not enabled)
    end
end

function SigilOfAimTriangle.UpdateScale()
    if not SigilOfAimTriangle.SOASV then return end
    
    TRIANGLE_SCALE = SigilOfAimTriangle.SOASV.triangleScale or 0.15
    TRIANGLE_Y_OFFSET = 45 * TRIANGLE_SCALE
    RETICLE_CONTROL_WIDTH = 256 * TEXTURE_SCALE_X * TRIANGLE_SCALE
    RETICLE_CONTROL_HEIGHT = 256 * TEXTURE_SCALE_Y * TRIANGLE_SCALE
    BOTTOM_LINE_OFFSET_Y = -TRIANGLE_Y_OFFSET * 2
    LEFT_LINE_OFFSET_X = -128 * TEXTURE_SCALE_Y * TRIANGLE_SCALE
    LEFT_LINE_OFFSET_Y = TRIANGLE_Y_OFFSET
    RIGHT_LINE_OFFSET_X = 128 * TEXTURE_SCALE_Y * TRIANGLE_SCALE
    RIGHT_LINE_OFFSET_Y = TRIANGLE_Y_OFFSET
    
    -- Update control dimensions if they exist
    if reticleControl then
        reticleControl:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    end
    if bottomLine then
        bottomLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
        bottomLine:SetAnchor(BOTTOM, reticleControl, BOTTOM, BOTTOM_LINE_OFFSET_X, BOTTOM_LINE_OFFSET_Y)
    end
    if leftLine then
        leftLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
        leftLine:SetAnchor(BOTTOMLEFT, reticleControl, BOTTOM, LEFT_LINE_OFFSET_X, LEFT_LINE_OFFSET_Y)
    end
    if rightLine then
        rightLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
        rightLine:SetAnchor(BOTTOMRIGHT, reticleControl, BOTTOM, RIGHT_LINE_OFFSET_X, RIGHT_LINE_OFFSET_Y)
    end
end

-- =============================================================================
-- == BLOCK ANIMATION SUBSYSTEM ================================================
-- =============================================================================

local function animateRotateBlockDown(control)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(math.pi)
    rotate:SetEndRotation(0)
    rotate:SetDuration(BLOCK_ANIMATION_DURATION)

    local transformOffset = timeline:InsertAnimation(ANIMATION_TRANSFORMOFFSET, control)
    local endX, endY = 0, 0

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

    transformOffset:SetStartOffset(endX, endY, 0)
    transformOffset:SetEndOffset(0, 0, 0)
    transformOffset:SetDuration(BLOCK_ANIMATION_DURATION)

    timeline:PlayFromStart()
end

local function animateRotateBlockUp(control)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(0)
    rotate:SetEndRotation(math.pi)
    rotate:SetDuration(BLOCK_ANIMATION_DURATION)

    local transformOffset = timeline:InsertAnimation(ANIMATION_TRANSFORMOFFSET, control)
    local endX, endY = 0, 0

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

    transformOffset:SetStartOffset(0, 0, 0)
    transformOffset:SetEndOffset(endX, endY, 0)
    transformOffset:SetDuration(BLOCK_ANIMATION_DURATION)

    timeline:PlayFromStart()
end

local function SetTriangleRotationAnimated(targetUpsideDown)
    if not (bottomLine and leftLine and rightLine) then return end
    if targetUpsideDown == triangleUpsideDown then return end

    if targetUpsideDown then
        animateRotateBlockUp(bottomLine)
        animateRotateBlockUp(leftLine)
        animateRotateBlockUp(rightLine)
    else
        animateRotateBlockDown(bottomLine)
        animateRotateBlockDown(leftLine)
        animateRotateBlockDown(rightLine)
    end

    triangleUpsideDown = targetUpsideDown
end

-- =============================================================================
-- == WEAPON SWAP ANIMATION SUBSYSTEM ==========================================
-- =============================================================================

function animateRotateMainWeapon(control)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(0)
    rotate:SetEndRotation(-6.28319)
    rotate:SetDuration(WEAPON_SWAP_MAIN_DURATION)
    timeline:PlayFromStart()
end

function animateRotateBackWeapon(control)
    local timeline = ANIMATION_MANAGER:CreateTimeline()
    local rotate = timeline:InsertAnimation(ANIMATION_TEXTUREROTATE, control)
    rotate:SetStartRotation(0)
    rotate:SetEndRotation(6.28319)
    rotate:SetDuration(WEAPON_SWAP_BACK_DURATION)
    timeline:PlayFromStart()
end

function OnWeaponBarSwitch(eventCode, activeWeaponPair, locked)
    if bottomLine and leftLine and rightLine and SigilOfAimTriangle.isEnabled then
        if activeWeaponPair == 1 then
            animateRotateMainWeapon(bottomLine)
            animateRotateMainWeapon(leftLine)
            animateRotateMainWeapon(rightLine)
        else
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

function SigilOfAimTriangleInitialized()
    -- Check if module is enabled
    if SigilOfAimTriangle.SOASV and not SigilOfAimTriangle.SOASV.triangleEnabled then
        SigilOfAimTriangle.isEnabled = false
        SigilOfAimTriangle:SetHidden(true)
        return
    end
    
    SigilOfAimTriangle:ClearAnchors()
    SigilOfAimTriangle:SetAnchor(CENTER, GuiRoot, CENTER, RETICLE_POSITION_X, RETICLE_POSITION_Y)

    CreateSigilOfAimTriangleReticle()
    isInitialized = true
    
    -- Apply scale from settings
    if SigilOfAimTriangle.SOASV then
        SigilOfAimTriangle.UpdateScale()
    end
    
    -- Apply initial enabled state
    if reticleControl then
        reticleControl:SetHidden(not SigilOfAimTriangle.isEnabled)
    end
    
    EVENT_MANAGER:RegisterForEvent("SigilOfAimTriangleWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnWeaponBarSwitch)
end

-- =============================================================================
-- == FRAME UPDATE SUBSYSTEM ===================================================
-- =============================================================================

local function ApplyStyleFromMenu(state, scale)
    if not SigilOfAimTriangle.SOASV then return end
    
    local applyToControl = function(control)
        if not control then return end
        
        if SigilOfAimMenu and SigilOfAimMenu.ApplyColorStyle then
            SigilOfAimMenu.ApplyColorStyle(control, state, scale)
        else
            -- Fallback to default colors if menu isn't loaded
            local color = SigilOfAimTriangle.SOASV.colors and SigilOfAimTriangle.SOASV.colors[state]
            local defaultColor = SigilOfAimTriangle.SOASV.colors and SigilOfAimTriangle.SOASV.colors["default"]
            
            if color and color.enabled then
                control:SetColor(color.r, color.g, color.b, color.a)
                control:SetScale(scale)
            else
                -- Use default color if specific state color is disabled
                if defaultColor and defaultColor.enabled then
                    control:SetColor(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
                else
                    -- Fallback: light gray with medium visibility
                    control:SetColor(0.95, 0.95, 0.95, 0.7)
                end
                control:SetScale(scale)
            end
        end
    end
    
    applyToControl(bottomLine)
    applyToControl(leftLine)
    applyToControl(rightLine)
end

function SigilOfAimTriangleUpdate()
    if not isInitialized or not SigilOfAimTriangle.isEnabled then return end

    -- Control visibility of original ESO reticle
    if SigilOfAimTriangle.SOASV then
        ZO_ReticleContainerReticle:SetHidden(not SigilOfAimTriangle.SOASV.showOriginalReticle)
    else
        ZO_ReticleContainerReticle:SetHidden(true)
    end

    -- Check visibility conditions
    local shouldHide = false
    if SigilOfAimTriangle.SOASV then
        if SigilOfAimTriangle.SOASV.hideInMouseMode and IsGameCameraUIModeActive() then
            shouldHide = true
        end
        if SigilOfAimTriangle.SOASV.hideInSiegeWeapon and IsPlayerControllingSiegeWeapon() then
            shouldHide = true
        end
    end
    
    if reticleControl then
        reticleControl:SetHidden(shouldHide)
        if shouldHide then return end
    end

    -- Check if player is blocking
    isBlocking = IsBlockActive() or false
    SetTriangleRotationAnimated(isBlocking)

    -- Get various game state information
    local playerStealth = GetUnitStealthState("player")
    local playerDisguised = GetUnitDisguiseState("player") ~= DISGUISE_STATE_NONE
    local targetUnitHighlighted = (GetUnitNameHighlightedByReticle() ~= "" and IsGameCameraUnitHighlightedAttackable())
    local targetUnitInteractable = GetGameCameraInteractableInfo()

    -- Apply different styles based on game state
    if playerStealth > 0 then
        ApplyStyleFromMenu("stealth", 1.0)
    elseif IsUnitDead("player") then
        ApplyStyleFromMenu("dead", 1.0 * Action_Scale_BIG)
    elseif IsUnitReincarnating("player") then
        ApplyStyleFromMenu("reincarnating", 1.0 * Action_Scale_BIG)
    elseif IsUnitFalling("player") then
        ApplyStyleFromMenu("falling", 1.0 * Action_Scale_BIG)
    elseif IsUnitSwimming("player") then
        ApplyStyleFromMenu("swimming", 1.0 * Action_Scale_BIG)
    elseif IsPlayerStunned() then
        ApplyStyleFromMenu("stunned", 1.0 * Action_Scale_BIG)
    elseif IsUnitInCombat("player") then
        ApplyStyleFromMenu("combat", 1.0 * Action_Scale)
    elseif targetUnitHighlighted then
        ApplyStyleFromMenu("attackable", 1.0 * Action_Scale)
    elseif targetUnitInteractable then
        ApplyStyleFromMenu("interactable", 1.0 * Action_Scale)
    elseif playerDisguised then
        ApplyStyleFromMenu("disguised", 1.0 * Action_Scale)
    else
        ApplyStyleFromMenu("default", 1.0)
    end
end

-- =============================================================================
-- == RETICLE CREATION SUBSYSTEM ===============================================
-- =============================================================================

function CreateSigilOfAimTriangleReticle()
    if reticleControl then return end

    -- Main parent control for the entire triangle reticle
    reticleControl = WINDOW_MANAGER:CreateControl("SigilOfAimTriangleCrosshair", SigilOfAimTriangle, CT_CONTROL)
    reticleControl:SetAnchor(CENTER, SigilOfAimTriangle, CENTER, 0, 0)
    reticleControl:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)

    -- Bottom triangle element
    bottomLine = WINDOW_MANAGER:CreateControl("$(parent)Bottom", reticleControl, CT_TEXTURE)
    bottomLine:SetAnchor(BOTTOM, reticleControl, BOTTOM, BOTTOM_LINE_OFFSET_X, BOTTOM_LINE_OFFSET_Y)
    bottomLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    bottomLine:SetTexture("SigilOfAim/Textures/SigilOfAimTriangle.dds")
    bottomLine:SetColor(0.95, 0.95, 0.95, 0.7)
    bottomLine:SetTextureRotation(math.rad(BASE_BOTTOM))

    -- Left triangle element
    leftLine = WINDOW_MANAGER:CreateControl("$(parent)Left", reticleControl, CT_TEXTURE)
    leftLine:SetAnchor(BOTTOMLEFT, reticleControl, BOTTOM, LEFT_LINE_OFFSET_X, LEFT_LINE_OFFSET_Y)
    leftLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    leftLine:SetTexture("SigilOfAim/Textures/SigilOfAimTriangle.dds")
    leftLine:SetColor(0.95, 0.95, 0.95, 0.7)
    leftLine:SetTextureRotation(math.rad(BASE_LEFT))

    -- Right triangle element
    rightLine = WINDOW_MANAGER:CreateControl("$(parent)Right", reticleControl, CT_TEXTURE)
    rightLine:SetAnchor(BOTTOMRIGHT, reticleControl, BOTTOM, RIGHT_LINE_OFFSET_X, RIGHT_LINE_OFFSET_Y)
    rightLine:SetDimensions(RETICLE_CONTROL_WIDTH, RETICLE_CONTROL_HEIGHT)
    rightLine:SetTexture("SigilOfAim/Textures/SigilOfAimTriangle.dds")
    rightLine:SetColor(0.95, 0.95, 0.95, 0.7)
    rightLine:SetTextureRotation(math.rad(BASE_RIGHT))

    triangleUpsideDown = false
end

-- =============================================================================
-- == UI MODE HANDLING SUBSYSTEM ===============================================
-- =============================================================================

function OnUIModeChanged(eventCode, uiMode)
    if reticleControl and SigilOfAimTriangle.isEnabled then
        local shouldHide = IsGameCameraUIModeActive() and 
                          SigilOfAimTriangle.SOASV and 
                          SigilOfAimTriangle.SOASV.hideInMouseMode
        reticleControl:SetHidden(shouldHide)
    end
end

EVENT_MANAGER:RegisterForEvent("SigilOfAimTriangle", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnUIModeChanged)