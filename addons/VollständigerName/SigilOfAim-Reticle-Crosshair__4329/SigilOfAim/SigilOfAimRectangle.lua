-- =============================================================================
-- === SigilOfAimRectangle Core Logic (Updated for Menu Integration)         ===
-- =============================================================================

SigilOfAimRectangle = {
    name = "SigilOfAimRectangle",
    version = "1.0.1",
    isEnabled = true,
    savedVars = nil,
}

-- Local variables for better performance
local reticleControl = nil
local isInitialized = false
local Action_Scale = 0.9
local Action_Scale_BIG = 1.1

-- =============================================================================
-- == MODULE CONTROL FUNCTIONS ================================================
-- =============================================================================

function SigilOfAimRectangle.SetEnabled(enabled)
    SigilOfAimRectangle.isEnabled = enabled
    if reticleControl then
        reticleControl:SetHidden(not enabled)
    end
end

function SigilOfAimRectangle.UpdateScale()
    if reticleControl and SigilOfAimRectangle.SOASV then
        -- Scale logic can be added here if needed
        -- Currently scale is handled in ApplyStyle
    end
end

-- =============================================================================
-- == CORE INITIALIZATION SUBSYSTEM ============================================
-- =============================================================================

function SigilOfAimRectangleInitialized()
    -- Check if module is enabled
    if SigilOfAimRectangle.SOASV and not SigilOfAimRectangle.SOASV.rectangleEnabled then
        SigilOfAimRectangle.isEnabled = false
        SigilOfAimRectangle:SetHidden(true)
        return
    end
    
    SigilOfAimRectangle:ClearAnchors()
    SigilOfAimRectangle:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    
    CreateSigilOfAimRectangleReticle()
    isInitialized = true
    
    -- Apply initial enabled state
    if reticleControl then
        reticleControl:SetHidden(not SigilOfAimRectangle.isEnabled)
    end
    
    d("SigilOfAimRectangle initialized")
end

-- =============================================================================
-- == FRAME UPDATE SUBSYSTEM ===================================================
-- =============================================================================

local function ApplyStyleFromMenu(state, scale)
    if not SigilOfAimRectangle.SOASV then return end
    
    if SigilOfAimMenu and SigilOfAimMenu.ApplyColorStyle then
        SigilOfAimMenu.ApplyColorStyle(reticleControl, state, scale)
    else
        -- Fallback to default colors if menu isn't loaded
        local color = SigilOfAimRectangle.SOASV.colors and SigilOfAimRectangle.SOASV.colors[state]
        local defaultColor = SigilOfAimRectangle.SOASV.colors and SigilOfAimRectangle.SOASV.colors["default"]
        
        if color and color.enabled then
            reticleControl:SetColor(color.r, color.g, color.b, color.a)
            reticleControl:SetScale(scale)
        else
            -- Use default color if specific state color is disabled
            if defaultColor and defaultColor.enabled then
                reticleControl:SetColor(defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a)
            else
                -- Fallback: light gray with medium visibility
                reticleControl:SetColor(0.95, 0.95, 0.95, 0.7)
            end
            reticleControl:SetScale(scale)
        end
    end
end

function SigilOfAimRectangleUpdate()
    -- Exit if not initialized or not enabled
    if not isInitialized or not SigilOfAimRectangle.isEnabled then return end
    
    -- Hide default ESO crosshair if configured
    if SigilOfAimRectangle.SOASV then
        ZO_ReticleContainerReticle:SetHidden(not SigilOfAimRectangle.SOASV.showOriginalReticle)
    else
        ZO_ReticleContainerReticle:SetHidden(true)
    end
    
    -- Check visibility conditions
    local shouldHide = false
    if SigilOfAimRectangle.SOASV then
        if SigilOfAimRectangle.SOASV.hideInMouseMode and IsGameCameraUIModeActive() then
            shouldHide = true
        end
        if SigilOfAimRectangle.SOASV.hideInSiegeWeapon and IsPlayerControllingSiegeWeapon() then
            shouldHide = true
        end
    end
    
    if reticleControl then
        reticleControl:SetHidden(shouldHide)
        if shouldHide then return end
    end
    
    -- Get various game state information for visual feedback
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

function CreateSigilOfAimRectangleReticle()
    -- Exit if already created
    if reticleControl then return end
    
    -- Create new texture control in UI manager
    reticleControl = WINDOW_MANAGER:CreateControl("SigilOfAimRectangleCrosshair", SigilOfAimRectangle, CT_TEXTURE)
    -- Clear existing anchors
    reticleControl:ClearAnchors()
    -- Center texture in crosshair container
    reticleControl:SetAnchor(CENTER, SigilOfAimRectangle, CENTER, 0, 0)
    -- Texture dimensions in pixels
    reticleControl:SetDimensions(16, 16)
    
    -- Load custom addon texture with updated path
    reticleControl:SetTexture("SigilOfAim/Textures/SigilOfAimRectangle.dds")
    -- Initial color
    reticleControl:SetColor(0.95, 0.95, 0.95, 0.7)
end

-- =============================================================================
-- == UI MODE HANDLING SUBSYSTEM ===============================================
-- =============================================================================

function OnUIModeChanged(eventCode, uiMode)
    -- Only react if crosshair exists
    if reticleControl and SigilOfAimRectangle.isEnabled then
        -- Hide crosshair in mouse mode if configured
        local shouldHide = IsGameCameraUIModeActive() and 
                          SigilOfAimRectangle.SOASV and 
                          SigilOfAimRectangle.SOASV.hideInMouseMode
        reticleControl:SetHidden(shouldHide)
    end
end

-- Register event listener for UI mode changes
EVENT_MANAGER:RegisterForEvent("SigilOfAimRectangle", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnUIModeChanged)