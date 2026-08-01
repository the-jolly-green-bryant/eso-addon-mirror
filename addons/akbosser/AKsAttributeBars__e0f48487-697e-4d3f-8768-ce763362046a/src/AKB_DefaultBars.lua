-- ============================================================================
-- AKsAttributeBars - Default Bars Management Module
-- ============================================================================
-- Handles positioning and visibility of default ESO attribute bars

local AKB = AKsAttributeBars

-- Create default bars namespace
AKB.DefaultBars = AKB.DefaultBars or {}

-- Store original positions for bars
local originalBarPositions = {
    health = { x = nil, y = nil },
    magicka = { x = nil, y = nil },
    stamina = { x = nil, y = nil }
}

-- Function to hide/show default ESO attribute bars
function AKB.DefaultBars.SetVisibility(visible)
    -- Try to find and hide/show the default attribute bars
    local playerAttributeBars = ZO_PlayerAttributeBars
    if playerAttributeBars then
        playerAttributeBars:SetHidden(not visible)
    end
    
    -- Also try the individual bar controls
    local healthBar = ZO_PlayerAttributeHealth
    local magickaBar = ZO_PlayerAttributeMagicka  
    local staminaBar = ZO_PlayerAttributeStamina
    local mountStaminaBar = ZO_PlayerAttributeMountStamina
    
    if healthBar then
        healthBar:SetHidden(not visible)
    end
    if magickaBar then
        magickaBar:SetHidden(not visible)
    end
    if staminaBar then
        staminaBar:SetHidden(not visible)
    end
    
    -- Hide default mount stamina bar when custom bars are enabled
    if mountStaminaBar then
        mountStaminaBar:SetHidden(not visible)
    end
end

-- Function to capture original bar positions
function AKB.DefaultBars.CaptureOriginalPositions()
    local healthBar = ZO_PlayerAttributeHealth
    local magickaBar = ZO_PlayerAttributeMagicka  
    local staminaBar = ZO_PlayerAttributeStamina
    
    -- Only capture if we haven't already
    if originalBarPositions.health.x == nil then
        if healthBar and healthBar.GetLeft and healthBar.GetTop then
            originalBarPositions.health.x = healthBar:GetLeft() or 100
            originalBarPositions.health.y = healthBar:GetTop() or 100
        end
    end
    
    if originalBarPositions.magicka.x == nil then
        if magickaBar and magickaBar.GetLeft and magickaBar.GetTop then
            originalBarPositions.magicka.x = magickaBar:GetLeft() or 100
            originalBarPositions.magicka.y = magickaBar:GetTop() or 130
        end
    end
    
    if originalBarPositions.stamina.x == nil then
        if staminaBar and staminaBar.GetLeft and staminaBar.GetTop then
            originalBarPositions.stamina.x = staminaBar:GetLeft() or 100
            originalBarPositions.stamina.y = staminaBar:GetTop() or 160
        end
    end
end

-- Function to apply positioning settings to default ESO attribute bars
function AKB.DefaultBars.ApplyPositioning()
    -- Get the default bar controls
    local healthBar = ZO_PlayerAttributeHealth
    local magickaBar = ZO_PlayerAttributeMagicka  
    local staminaBar = ZO_PlayerAttributeStamina
    
    -- Capture original positions first if not already done
    AKB.DefaultBars.CaptureOriginalPositions()
    
    local settings = AKB.Settings.GetAll()
    local yPosition = settings.defaultBarsYPosition or 0
    local proximity = settings.defaultBarsProximity or 0
    
    -- Apply positioning to health bar (center reference) - only if Y position changed
    if healthBar and healthBar.ClearAnchors and healthBar.SetAnchor and yPosition ~= 0 then
        healthBar:ClearAnchors()
        local originalY = originalBarPositions.health.y or 100
        local originalX = originalBarPositions.health.x or 100
        local newY = originalY - yPosition  -- Inverted: positive moves UP
        healthBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, originalX, newY)
    end
    
    -- Apply positioning to magicka bar (moves right with positive proximity)
    if magickaBar and magickaBar.ClearAnchors and magickaBar.SetAnchor then
        magickaBar:ClearAnchors()
        local originalX = originalBarPositions.magicka.x or 100
        local originalY = originalBarPositions.magicka.y or 130
        local newX = originalX + proximity
        local newY = originalY - yPosition  -- Inverted: positive moves UP
        magickaBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newX, newY)
    end
    
    -- Apply positioning to stamina bar (moves left with positive proximity)
    if staminaBar and staminaBar.ClearAnchors and staminaBar.SetAnchor then
        staminaBar:ClearAnchors()
        local originalX = originalBarPositions.stamina.x or 100
        local originalY = originalBarPositions.stamina.y or 160
        local newX = originalX - proximity
        local newY = originalY - yPosition  -- Inverted: positive moves UP
        staminaBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, newX, newY)
    end
end

-- Reset bars to original positions
function AKB.DefaultBars.ResetToOriginal()
    local healthBar = ZO_PlayerAttributeHealth
    local magickaBar = ZO_PlayerAttributeMagicka  
    local staminaBar = ZO_PlayerAttributeStamina
    
    if healthBar and healthBar.ClearAnchors and healthBar.SetAnchor then
        healthBar:ClearAnchors()
        local resetX = originalBarPositions.health.x or 100
        local resetY = originalBarPositions.health.y or 100
        healthBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, resetX, resetY)
    end
    
    if magickaBar and magickaBar.ClearAnchors and magickaBar.SetAnchor then
        magickaBar:ClearAnchors()
        local resetX = originalBarPositions.magicka.x or 100
        local resetY = originalBarPositions.magicka.y or 130
        magickaBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, resetX, resetY)
    end
    
    if staminaBar and staminaBar.ClearAnchors and staminaBar.SetAnchor then
        staminaBar:ClearAnchors()
        local resetX = originalBarPositions.stamina.x or 100
        local resetY = originalBarPositions.stamina.y or 160
        staminaBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, resetX, resetY)
    end
end
