-- ============================================================================
-- AKsAttributeBars - Bar Creation Module
-- ============================================================================
-- Handles creation and management of individual attribute bars

local AKB = AKsAttributeBars

-- Create Bars namespace
AKB.UI = AKB.UI or {}
AKB.UI.Bars = AKB.UI.Bars or {}

-- Console-safe draw constants (from working archive)
local DT_LOW = 1
local DT_MEDIUM = 2  
local DT_HIGH = 3
local DL_BACKGROUND = DL_BACKGROUND or 1
local DL_OVERLAY = DL_OVERLAY or 6

-- Create a single attribute bar (health, magicka, or stamina)
local function CreateSingleAttributeBar(barType, powerType, xOffset, yOffset, color)
    local barName = "AKB_Console" .. barType .. "Bar"
    local uniqueName = AKB.Utils.GenerateUniqueName(barName)
    
    local barWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(uniqueName)
    if not barWindow then
        return nil
    end
    
    local settings = AKB.Settings.GetAll()
    local isCompact = settings.customBarType == 2
    local constants = AKB.Utils.BAR_CONSTANTS
    
    -- Set window properties based on bar type
    local actualBarHeight = isCompact and (constants.HEIGHT + 8) or constants.HEIGHT
    local windowHeight = isCompact and (actualBarHeight + 20) or (constants.HEIGHT + 20)
    
    barWindow:SetDimensions(constants.WIDTH + 20, windowHeight)
    local xPos = settings.customBarsXPosition + xOffset
    local yPos = settings.customBarsYPosition + yOffset
    barWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos, yPos)
    barWindow:SetClampedToScreen(true)
    barWindow:SetMouseEnabled(false)
    barWindow:SetMovable(false)
    barWindow:SetHidden(false)
    
    -- Create background
    local barBackground = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if not barBackground then
        return nil
    end
    
    local bgY = isCompact and 10 or 10
    barBackground:SetAnchor(TOPLEFT, barWindow, TOPLEFT, 10, bgY)
    barBackground:SetDimensions(constants.WIDTH, actualBarHeight)
    barBackground:SetColor(0, 0, 0, 0.5)
    
    -- Phase 2: Add subtle gradient to background for 3D depth (gamepad compatible)
    if barBackground.SetGradientColors then
        -- Very subtle gradient for background depth - darker at top, slightly lighter at bottom
        barBackground:SetGradientColors(2, 
            0.0, 0.0, 0.0, 0.6,  -- Top (darker)
            0.1, 0.1, 0.1, 0.4   -- Bottom (slightly lighter)
        )
    end
    
    if barBackground.SetDrawTier then barBackground:SetDrawTier(DT_LOW) end
    if barBackground.SetDrawLayer then barBackground:SetDrawLayer(DL_BACKGROUND) end
    if barBackground.SetDrawLevel then barBackground:SetDrawLevel(1) end
    barBackground:SetHidden(false)
    
    -- Create simple border using 4 separate border elements
    local borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.9}
    local borderThickness = 1
    
    -- Top border
    local topBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if topBorder then
        topBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, -borderThickness)
        topBorder:SetDimensions(constants.WIDTH + (borderThickness * 2), borderThickness)
        topBorder:SetTexture("")
        topBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if topBorder.SetDrawTier then topBorder:SetDrawTier(DT_LOW) end
        if topBorder.SetDrawLayer then topBorder:SetDrawLayer(DL_BACKGROUND) end
        if topBorder.SetDrawLevel then topBorder:SetDrawLevel(3) end
        topBorder:SetHidden(false)
    end
    
    -- Bottom border
    local bottomBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if bottomBorder then
        bottomBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, actualBarHeight)
        bottomBorder:SetDimensions(constants.WIDTH + (borderThickness * 2), borderThickness)
        bottomBorder:SetTexture("")
        bottomBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if bottomBorder.SetDrawTier then bottomBorder:SetDrawTier(DT_LOW) end
        if bottomBorder.SetDrawLayer then bottomBorder:SetDrawLayer(DL_BACKGROUND) end
        if bottomBorder.SetDrawLevel then bottomBorder:SetDrawLevel(3) end
        bottomBorder:SetHidden(false)
    end
    
    -- Left border
    local leftBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if leftBorder then
        leftBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, 0)
        leftBorder:SetDimensions(borderThickness, actualBarHeight)
        leftBorder:SetTexture("")
        leftBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if leftBorder.SetDrawTier then leftBorder:SetDrawTier(DT_LOW) end
        if leftBorder.SetDrawLayer then leftBorder:SetDrawLayer(DL_BACKGROUND) end
        if leftBorder.SetDrawLevel then leftBorder:SetDrawLevel(3) end
        leftBorder:SetHidden(false)
    end
    
    -- Right border - position slightly inside the background to ensure visibility
    local rightBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if rightBorder then
        rightBorder:SetAnchor(TOPLEFT, barWindow, TOPLEFT, 10 + constants.WIDTH - 2, bgY)
        rightBorder:SetDimensions(2, actualBarHeight) -- Make right border 2px wide for better visibility
        rightBorder:SetTexture("")
        rightBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if rightBorder.SetDrawTier then rightBorder:SetDrawTier(DT_LOW) end
        if rightBorder.SetDrawLayer then rightBorder:SetDrawLayer(DL_BACKGROUND) end
        if rightBorder.SetDrawLevel then rightBorder:SetDrawLevel(3) end -- Higher draw level
        rightBorder:SetHidden(false)
    end
    
    -- Create fill
    local barFill = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if not barFill then
        return nil
    end
    
    barFill:SetAnchor(TOPLEFT, barBackground, TOPLEFT, constants.BORDER, constants.BORDER)
    barFill:SetDimensions(constants.WIDTH - (constants.BORDER * 2), actualBarHeight - (constants.BORDER * 2))
    barFill:SetColor(color.r, color.g, color.b, settings.barTransparency)
    
    -- Phase 2B: Refined 3D effect using subtle overlay technique (gamepad compatible)
    -- Adjusted for more natural appearance with softer contrast
    
    -- Create subtle highlight overlay for top portion (softer lighter effect)
    local highlightOverlay = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if highlightOverlay then
        local overlayHeight = math.floor((actualBarHeight - (constants.BORDER * 2)) * 0.5) -- Top 50% for smoother transition
        highlightOverlay:SetAnchor(TOPLEFT, barFill, TOPLEFT, 0, 0)
        highlightOverlay:SetDimensions(constants.WIDTH - (constants.BORDER * 2), overlayHeight)
        -- Reduced white overlay opacity for subtlety
        highlightOverlay:SetColor(1, 1, 1, 0.08)
        if highlightOverlay.SetDrawTier then highlightOverlay:SetDrawTier(DT_LOW) end
        if highlightOverlay.SetDrawLayer then highlightOverlay:SetDrawLayer(DL_OVERLAY) end
        if highlightOverlay.SetDrawLevel then highlightOverlay:SetDrawLevel(4) end
        highlightOverlay:SetHidden(false)
    end
    
    -- Create subtle shadow overlay for bottom portion (softer darker effect)
    local shadowOverlay = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if shadowOverlay then
        local overlayHeight = math.floor((actualBarHeight - (constants.BORDER * 2)) * 0.4) -- Bottom 40% for gentler gradient
        local yOffset = (actualBarHeight - (constants.BORDER * 2)) - overlayHeight
        shadowOverlay:SetAnchor(TOPLEFT, barFill, TOPLEFT, 0, yOffset)
        shadowOverlay:SetDimensions(constants.WIDTH - (constants.BORDER * 2), overlayHeight)
        -- Reduced black overlay opacity for subtlety
        shadowOverlay:SetColor(0, 0, 0, 0.12)
        if shadowOverlay.SetDrawTier then shadowOverlay:SetDrawTier(DT_LOW) end
        if shadowOverlay.SetDrawLayer then shadowOverlay:SetDrawLayer(DL_OVERLAY) end
        if shadowOverlay.SetDrawLevel then shadowOverlay:SetDrawLevel(4) end
        shadowOverlay:SetHidden(false)
    end
    
    -- Phase 3: Inner glow effect for professional lighting (gamepad compatible)
    local innerGlow = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if innerGlow then
        -- Inner glow covers the entire fill area with subtle color-matched luminosity
        innerGlow:SetAnchor(TOPLEFT, barFill, TOPLEFT, 0, 0)
        innerGlow:SetDimensions(constants.WIDTH - (constants.BORDER * 2), actualBarHeight - (constants.BORDER * 2))
        -- Use the bar's color but with very low opacity for subtle inner glow
        innerGlow:SetColor(color.r, color.g, color.b, 0.06)
        if innerGlow.SetDrawTier then innerGlow:SetDrawTier(DT_LOW) end
        if innerGlow.SetDrawLayer then innerGlow:SetDrawLayer(DL_OVERLAY) end
        if innerGlow.SetDrawLevel then innerGlow:SetDrawLevel(3) end -- Below highlight/shadow but above fill
        innerGlow:SetHidden(false)
    end
    
    -- Phase 3: Edge lighting effect for depth and separation
    local edgeLight = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if edgeLight then
        -- Edge light is a thin inner border that creates a soft rim light effect
        local edgeThickness = 1
        edgeLight:SetAnchor(TOPLEFT, barFill, TOPLEFT, edgeThickness, edgeThickness)
        edgeLight:SetDimensions(constants.WIDTH - (constants.BORDER * 2) - (edgeThickness * 2), 
                               actualBarHeight - (constants.BORDER * 2) - (edgeThickness * 2))
        -- White edge light with very low opacity for subtle rim lighting
        edgeLight:SetColor(1, 1, 1, 0.05)
        if edgeLight.SetDrawTier then edgeLight:SetDrawTier(DT_LOW) end
        if edgeLight.SetDrawLayer then edgeLight:SetDrawLayer(DL_OVERLAY) end
        if edgeLight.SetDrawLevel then edgeLight:SetDrawLevel(5) end -- Top layer for edge effect
        edgeLight:SetHidden(false)
    end
    
    if barFill.SetDrawTier then barFill:SetDrawTier(DT_LOW) end
    if barFill.SetDrawLayer then barFill:SetDrawLayer(DL_BACKGROUND) end
    if barFill.SetDrawLevel then barFill:SetDrawLevel(2) end
    barFill:SetHidden(false)
    
    -- Create shield bar overlay (only for health bars) - always create for health bars
    local shieldBar = nil
    local shieldGlow = nil  -- Phase 3: Shield glow effect
    -- Regen/Degen arrow windows (only for health) - moving arrows
    local regenArrowWindow = nil
    local degenArrowWindow = nil
    
    if barType == "Health" then
        shieldBar = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
        if shieldBar then
            -- Anchor shield bar to background, not the fill, so it doesn't move when health bar animates
            shieldBar:SetAnchor(TOPLEFT, barBackground, TOPLEFT, constants.BORDER, constants.BORDER)
            shieldBar:SetDimensions(0, actualBarHeight - (constants.BORDER * 2))  -- Start with 0 width
            local shieldColor = settings.shieldColor
            shieldBar:SetColor(shieldColor.r, shieldColor.g, shieldColor.b, shieldColor.a)
            
            -- Phase 2: Add gradient for 3D effect to shield bar (gamepad compatible)
            if shieldBar.SetGradientColors then
                -- Create lighter top and darker bottom for 3D depth effect
                local lighter = {
                    r = math.min(1.0, shieldColor.r + 0.2), 
                    g = math.min(1.0, shieldColor.g + 0.2), 
                    b = math.min(1.0, shieldColor.b + 0.2)
                }
                local darker = {
                    r = math.max(0.0, shieldColor.r - 0.15), 
                    g = math.max(0.0, shieldColor.g - 0.15), 
                    b = math.max(0.0, shieldColor.b - 0.15)
                }
                
                -- Direction 2 = vertical gradient (top to bottom)
                shieldBar:SetGradientColors(2, 
                    lighter.r, lighter.g, lighter.b, shieldColor.a,  -- Top (lighter)
                    darker.r, darker.g, darker.b, shieldColor.a      -- Bottom (darker)
                )
            end
            
            if shieldBar.SetDrawTier then shieldBar:SetDrawTier(DT_MEDIUM) end
            if shieldBar.SetDrawLayer then shieldBar:SetDrawLayer(DL_BACKGROUND) end
            if shieldBar.SetDrawLevel then shieldBar:SetDrawLevel(3) end
            shieldBar:SetHidden(true)  -- Hidden by default until shield is detected
            
            -- Phase 3: Enhanced glow effects for shield bar
            shieldGlow = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
            if shieldGlow then
                -- Shield glow covers the entire shield area with distinctive luminosity
                shieldGlow:SetAnchor(TOPLEFT, shieldBar, TOPLEFT, 0, 0)
                shieldGlow:SetDimensions(0, actualBarHeight - (constants.BORDER * 2))  -- Start with 0 width like shield
                -- Use shield color but with higher opacity for more prominent glow
                shieldGlow:SetColor(shieldColor.r, shieldColor.g, shieldColor.b, 0.12)
                if shieldGlow.SetDrawTier then shieldGlow:SetDrawTier(DT_MEDIUM) end
                if shieldGlow.SetDrawLayer then shieldGlow:SetDrawLayer(DL_OVERLAY) end
                if shieldGlow.SetDrawLevel then shieldGlow:SetDrawLevel(6) end -- Above all other overlays
                shieldGlow:SetHidden(true)  -- Hidden by default until shield is detected
            end
        end

        -- Moving arrow indicators - use same top-level window approach as labels for guaranteed overlay
        local innerHeight = (actualBarHeight - (constants.BORDER * 2))
        local arrowSize = math.floor(innerHeight * 0.9)
        local arrowSpacing = math.floor(arrowSize * 0.4)  -- Tight spacing: arrows overlap by 60%

        -- Create arrows as independent top-level windows (same as label approach)
        -- Each window holds 3 closely-packed arrows; width = arrowSize + arrowSpacing * 2
        regenArrowWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(uniqueName .. "_RegenArrow")
        if regenArrowWindow then
            regenArrowWindow:SetDimensions(arrowSize + arrowSpacing * 2, arrowSize)
            regenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos + 10 + constants.BORDER, yPos + bgY + (actualBarHeight - arrowSize) / 2)
            regenArrowWindow:SetClampedToScreen(true)
            regenArrowWindow:SetMouseEnabled(false)
            regenArrowWindow:SetMovable(false)
            regenArrowWindow:SetHidden(true)
            
            local regenArrow = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, regenArrowWindow, CT_TEXTURE)
            if regenArrow then
                regenArrow:SetAnchor(TOPLEFT, regenArrowWindow, TOPLEFT, 0, 0)
                regenArrow:SetDimensions(arrowSize, arrowSize)
                regenArrow:SetTexture("EsoUI/Art/Buttons/Gamepad/gp_menu_rightarrow.dds")
                regenArrow:SetColor(1.0, 1.0, 1.0, 0.95)
                regenArrow:SetHidden(false)
                regenArrow:SetMouseEnabled(false)
            end
            local regenArrow2 = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, regenArrowWindow, CT_TEXTURE)
            if regenArrow2 then
                regenArrow2:SetAnchor(TOPLEFT, regenArrowWindow, TOPLEFT, arrowSpacing, 0)
                regenArrow2:SetDimensions(arrowSize, arrowSize)
                regenArrow2:SetTexture("EsoUI/Art/Buttons/Gamepad/gp_menu_rightarrow.dds")
                regenArrow2:SetColor(1.0, 1.0, 1.0, 0.95)
                regenArrow2:SetHidden(false)
                regenArrow2:SetMouseEnabled(false)
            end
            local regenArrow3 = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, regenArrowWindow, CT_TEXTURE)
            if regenArrow3 then
                regenArrow3:SetAnchor(TOPLEFT, regenArrowWindow, TOPLEFT, arrowSpacing * 2, 0)
                regenArrow3:SetDimensions(arrowSize, arrowSize)
                regenArrow3:SetTexture("EsoUI/Art/Buttons/Gamepad/gp_menu_rightarrow.dds")
                regenArrow3:SetColor(1.0, 1.0, 1.0, 0.95)
                regenArrow3:SetHidden(false)
                regenArrow3:SetMouseEnabled(false)
            end
        end

        degenArrowWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(uniqueName .. "_DegenArrow")
        if degenArrowWindow then
            degenArrowWindow:SetDimensions(arrowSize + arrowSpacing * 2, arrowSize)
            degenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos + 10 + constants.WIDTH - constants.BORDER - arrowSize - arrowSpacing * 2, yPos + bgY + (actualBarHeight - arrowSize) / 2)
            degenArrowWindow:SetClampedToScreen(true)
            degenArrowWindow:SetMouseEnabled(false)
            degenArrowWindow:SetMovable(false)
            degenArrowWindow:SetHidden(true)
            
            local degenArrow = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, degenArrowWindow, CT_TEXTURE)
            if degenArrow then
                degenArrow:SetAnchor(TOPLEFT, degenArrowWindow, TOPLEFT, 0, 0)
                degenArrow:SetDimensions(arrowSize, arrowSize)
                degenArrow:SetTexture("EsoUI/Art/Buttons/large_leftarrow_up.dds")
                degenArrow:SetColor(1.0, 1.0, 1.0, 0.95)
                degenArrow:SetHidden(false)
                degenArrow:SetMouseEnabled(false)
            end
            local degenArrow2 = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, degenArrowWindow, CT_TEXTURE)
            if degenArrow2 then
                degenArrow2:SetAnchor(TOPLEFT, degenArrowWindow, TOPLEFT, arrowSpacing, 0)
                degenArrow2:SetDimensions(arrowSize, arrowSize)
                degenArrow2:SetTexture("EsoUI/Art/Buttons/large_leftarrow_up.dds")
                degenArrow2:SetColor(1.0, 1.0, 1.0, 0.95)
                degenArrow2:SetHidden(false)
                degenArrow2:SetMouseEnabled(false)
            end
            local degenArrow3 = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, degenArrowWindow, CT_TEXTURE)
            if degenArrow3 then
                degenArrow3:SetAnchor(TOPLEFT, degenArrowWindow, TOPLEFT, arrowSpacing * 2, 0)
                degenArrow3:SetDimensions(arrowSize, arrowSize)
                degenArrow3:SetTexture("EsoUI/Art/Buttons/large_leftarrow_up.dds")
                degenArrow3:SetColor(1.0, 1.0, 1.0, 0.95)
                degenArrow3:SetHidden(false)
                degenArrow3:SetMouseEnabled(false)
            end
        end
    end
    
    -- Create label window for text overlay
    local labelWindow, barLabel, percentLabel = AKB.UI.Bars.CreateBarLabel(uniqueName, xPos, yPos, isCompact, bgY, actualBarHeight)
    
    -- Return bar object with methods - pass arrow windows for animation control (no barFrame for 4-border approach)
    return AKB.UI.Bars.CreateBarObject(barType, powerType, color, barWindow, labelWindow, barBackground, barFill, barLabel, actualBarHeight, shieldBar, percentLabel, regenArrowWindow, degenArrowWindow, nil, shieldGlow)
end

-- Create a mount stamina bar (thinner version)
local function CreateMountStaminaBar(barType, powerType, xOffset, yOffset, color)
    local barName = "AKB_Console" .. barType .. "Bar"
    local uniqueName = AKB.Utils.GenerateUniqueName(barName)
    
    local barWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(uniqueName)
    if not barWindow then
        return nil
    end
    
    local settings = AKB.Settings.GetAll()
    local constants = AKB.Utils.BAR_CONSTANTS
    
    -- Mount stamina bar is thinner and slightly shorter to distinguish from stamina bar
    local actualBarHeight = settings.mountStaminaHeight or 12
    local windowHeight = actualBarHeight + 10  -- Small padding for mount stamina
    local mountBarWidth = constants.WIDTH * 0.85  -- Make mount stamina bar 15% shorter
    local iconSize = actualBarHeight + 4  -- Make icon slightly larger than bar height
    local iconSpacing = 8  -- Space between icon and bar
    local totalWidth = 10 + iconSize + iconSpacing + mountBarWidth + 10  -- left padding + icon + spacing + bar + right padding
    
    barWindow:SetDimensions(totalWidth, windowHeight)
    local xPos = settings.customBarsXPosition + xOffset
    local yPos = settings.customBarsYPosition + yOffset
    barWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos, yPos)
    barWindow:SetClampedToScreen(true)
    barWindow:SetMouseEnabled(false)
    barWindow:SetMovable(false)
    barWindow:SetHidden(false)
    
    -- Create background
    local barBackground = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if not barBackground then
        return nil
    end
    
    -- Create single mount icon on the left side of the bar
    local mountIcon = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    local iconSize = actualBarHeight + 20  -- Make icon larger than bar height for better visibility
    local iconSpacing = 8  -- Space between icon and bar
    
    if not mountIcon then
        -- Mount icon creation failed, continue without icon
    else
        -- Position icon on the left with some padding from window edge
        mountIcon:SetAnchor(TOPLEFT, barWindow, TOPLEFT, 10, (actualBarHeight - iconSize) / 2 + 5)
        mountIcon:SetDimensions(iconSize, iconSize)
        -- Use gamepad stablemaster icon for mount stamina
        mountIcon:SetTexture("EsoUI/Art/Icons/servicetooltipicons/gamepad/gp_servicetooltipicon_stablemaster.dds")
        mountIcon:SetColor(1, 1, 1, 1)  -- White, so icon is not tinted
        if mountIcon.SetDrawTier then 
            mountIcon:SetDrawTier(AKB.Utils.DRAW_TIERS.HIGH) 
        end
        if mountIcon.SetDrawLayer then 
            mountIcon:SetDrawLayer(DL_OVERLAY or 6) 
        end
        mountIcon:SetHidden(false)
        mountIcon:SetMouseEnabled(false)
    end
    
    local bgY = 5  -- Smaller top padding for mount stamina
    -- Position bar to the right of the icon
    local barStartX = 10 + iconSize + iconSpacing
    barBackground:SetAnchor(TOPLEFT, barWindow, TOPLEFT, barStartX, bgY)
    barBackground:SetDimensions(mountBarWidth, actualBarHeight)
    barBackground:SetColor(0, 0, 0, 0.5)
    
    -- Phase 2: Add subtle gradient to background for 3D depth (gamepad compatible)
    if barBackground.SetGradientColors then
        -- Very subtle gradient for background depth - darker at top, slightly lighter at bottom
        barBackground:SetGradientColors(2, 
            0.0, 0.0, 0.0, 0.6,  -- Top (darker)
            0.1, 0.1, 0.1, 0.4   -- Bottom (slightly lighter)
        )
    end
    
    if barBackground.SetDrawTier then barBackground:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) end
    if barBackground.SetDrawLayer then barBackground:SetDrawLayer(DL_BACKGROUND) end
    if barBackground.SetDrawLevel then barBackground:SetDrawLevel(1) end
    barBackground:SetHidden(false)
    
    -- Create simple border using 4 separate border elements
    local borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.9}
    local borderThickness = 1
    
    -- Top border
    local topBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if topBorder then
        topBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, -borderThickness)
        topBorder:SetDimensions(mountBarWidth + (borderThickness * 2), borderThickness)
        topBorder:SetTexture("")
        topBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if topBorder.SetDrawTier then topBorder:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) end
        if topBorder.SetDrawLayer then topBorder:SetDrawLayer(DL_BACKGROUND) end
        if topBorder.SetDrawLevel then topBorder:SetDrawLevel(3) end
        topBorder:SetHidden(false)
    end
    
    -- Bottom border
    local bottomBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if bottomBorder then
        bottomBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, actualBarHeight)
        bottomBorder:SetDimensions(mountBarWidth + (borderThickness * 2), borderThickness)
        bottomBorder:SetTexture("")
        bottomBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if bottomBorder.SetDrawTier then bottomBorder:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) end
        if bottomBorder.SetDrawLayer then bottomBorder:SetDrawLayer(DL_BACKGROUND) end
        if bottomBorder.SetDrawLevel then bottomBorder:SetDrawLevel(3) end
        bottomBorder:SetHidden(false)
    end
    
    -- Left border
    local leftBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if leftBorder then
        leftBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, 0)
        leftBorder:SetDimensions(borderThickness, actualBarHeight)
        leftBorder:SetTexture("")
        leftBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if leftBorder.SetDrawTier then leftBorder:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) end
        if leftBorder.SetDrawLayer then leftBorder:SetDrawLayer(DL_BACKGROUND) end
        if leftBorder.SetDrawLevel then leftBorder:SetDrawLevel(3) end
        leftBorder:SetHidden(false)
    end
    
    -- Right border - anchor to barBackground like other borders for consistent positioning
    local rightBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if rightBorder then
        rightBorder:SetAnchor(0, barBackground, 0, mountBarWidth, 0) -- 0 = TOPLEFT
        rightBorder:SetDimensions(borderThickness, actualBarHeight)
        rightBorder:SetTexture("")
        rightBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if rightBorder.SetDrawTier then rightBorder:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) end
        if rightBorder.SetDrawLayer then rightBorder:SetDrawLayer(DL_BACKGROUND) end
        if rightBorder.SetDrawLevel then rightBorder:SetDrawLevel(3) end
        rightBorder:SetHidden(false)
    end
    
    -- Create fill
    local barFill = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if not barFill then
        return nil
    end
    
    barFill:SetAnchor(TOPLEFT, barBackground, TOPLEFT, constants.BORDER, constants.BORDER)
    barFill:SetDimensions(mountBarWidth - (constants.BORDER * 2), actualBarHeight - (constants.BORDER * 2))
    barFill:SetColor(color.r, color.g, color.b, settings.barTransparency)
    if barFill.SetDrawTier then barFill:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) end
    barFill:SetHidden(false)
    
    -- Phase 2B: Refined 3D effect for mount stamina bar using subtle overlay technique
    -- Create subtle highlight overlay for top portion (softer lighter effect)
    local mountHighlightOverlay = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if mountHighlightOverlay then
        local overlayHeight = math.floor((actualBarHeight - (constants.BORDER * 2)) * 0.5) -- Top 50% for smoother transition
        mountHighlightOverlay:SetAnchor(TOPLEFT, barFill, TOPLEFT, 0, 0)
        mountHighlightOverlay:SetDimensions(mountBarWidth - (constants.BORDER * 2), overlayHeight)
        -- Reduced white overlay opacity for subtlety
        mountHighlightOverlay:SetColor(1, 1, 1, 0.08)
        if mountHighlightOverlay.SetDrawTier then mountHighlightOverlay:SetDrawTier(DT_LOW) end
        if mountHighlightOverlay.SetDrawLayer then mountHighlightOverlay:SetDrawLayer(DL_OVERLAY) end
        if mountHighlightOverlay.SetDrawLevel then mountHighlightOverlay:SetDrawLevel(4) end
        mountHighlightOverlay:SetHidden(false)
    end
    
    -- Create subtle shadow overlay for bottom portion (softer darker effect)
    local mountShadowOverlay = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if mountShadowOverlay then
        local overlayHeight = math.floor((actualBarHeight - (constants.BORDER * 2)) * 0.4) -- Bottom 40% for gentler gradient
        local yOffset = (actualBarHeight - (constants.BORDER * 2)) - overlayHeight
        mountShadowOverlay:SetAnchor(TOPLEFT, barFill, TOPLEFT, 0, yOffset)
        mountShadowOverlay:SetDimensions(mountBarWidth - (constants.BORDER * 2), overlayHeight)
        -- Reduced black overlay opacity for subtlety
        mountShadowOverlay:SetColor(0, 0, 0, 0.12)
        if mountShadowOverlay.SetDrawTier then mountShadowOverlay:SetDrawTier(DT_LOW) end
        if mountShadowOverlay.SetDrawLayer then mountShadowOverlay:SetDrawLayer(DL_OVERLAY) end
        if mountShadowOverlay.SetDrawLevel then mountShadowOverlay:SetDrawLevel(4) end
        mountShadowOverlay:SetHidden(false)
    end
    
    -- Phase 3: Inner glow effect for mount stamina bar
    local mountInnerGlow = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if mountInnerGlow then
        -- Inner glow covers the entire fill area with subtle color-matched luminosity
        mountInnerGlow:SetAnchor(TOPLEFT, barFill, TOPLEFT, 0, 0)
        mountInnerGlow:SetDimensions(mountBarWidth - (constants.BORDER * 2), actualBarHeight - (constants.BORDER * 2))
        -- Use the bar's color but with very low opacity for subtle inner glow
        mountInnerGlow:SetColor(color.r, color.g, color.b, 0.06)
        if mountInnerGlow.SetDrawTier then mountInnerGlow:SetDrawTier(DT_LOW) end
        if mountInnerGlow.SetDrawLayer then mountInnerGlow:SetDrawLayer(DL_OVERLAY) end
        if mountInnerGlow.SetDrawLevel then mountInnerGlow:SetDrawLevel(3) end -- Below highlight/shadow but above fill
        mountInnerGlow:SetHidden(false)
    end
    
    -- Phase 3: Edge lighting effect for mount stamina bar
    local mountEdgeLight = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, barWindow, CT_TEXTURE)
    if mountEdgeLight then
        -- Edge light is a thin inner border that creates a soft rim light effect
        local edgeThickness = 1
        mountEdgeLight:SetAnchor(TOPLEFT, barFill, TOPLEFT, edgeThickness, edgeThickness)
        mountEdgeLight:SetDimensions(mountBarWidth - (constants.BORDER * 2) - (edgeThickness * 2), 
                                    actualBarHeight - (constants.BORDER * 2) - (edgeThickness * 2))
        -- White edge light with very low opacity for subtle rim lighting
        mountEdgeLight:SetColor(1, 1, 1, 0.05)
        if mountEdgeLight.SetDrawTier then mountEdgeLight:SetDrawTier(DT_LOW) end
        if mountEdgeLight.SetDrawLayer then mountEdgeLight:SetDrawLayer(DL_OVERLAY) end
        if mountEdgeLight.SetDrawLevel then mountEdgeLight:SetDrawLevel(5) end -- Top layer for edge effect
        mountEdgeLight:SetHidden(false)
    end
    
    -- Mount stamina doesn't need a label - it's a simple indicator bar
    
    -- Return bar object with methods (no label for mount stamina, no arrow windows, no barFrame for 4-border approach)
    local barObj = AKB.UI.Bars.CreateBarObject(barType, powerType, color, barWindow, nil, barBackground, barFill, nil, actualBarHeight, nil, nil, nil, nil, nil)
    -- Store the custom width for mount stamina bar and single mount icon
    if barObj then
        barObj.barWidth = mountBarWidth
        barObj.mountIcon = mountIcon
    end
    -- Always hide on creation; will be shown by mount event if needed
    if barObj and barObj.window and barObj.window.SetHidden then
        barObj.window:SetHidden(true)
    end
    return barObj
end

-- Create label for a bar
function AKB.UI.Bars.CreateBarLabel(uniqueName, xPos, yPos, isCompact, bgY, actualBarHeight)
    local labelUniqueName = uniqueName .. "_Label"
    local labelWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(labelUniqueName)
    
    if not labelWindow then
        return nil, nil
    end
    
    local constants = AKB.Utils.BAR_CONSTANTS
    local labelY = isCompact and (bgY + actualBarHeight / 2 - 10) or -10
    local labelXPos = xPos + 15
    local labelYPos = yPos + labelY
    
    labelWindow:SetDimensions(constants.WIDTH - 20, 22)
    labelWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, labelXPos, labelYPos)
    labelWindow:SetClampedToScreen(true)
    labelWindow:SetMouseEnabled(false)
    labelWindow:SetMovable(false)
    labelWindow:SetHidden(false)
    
    local barLabel = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, labelWindow, CT_LABEL)
    local percentLabel = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, labelWindow, CT_LABEL)
    if barLabel then
        barLabel:SetAnchor(TOPLEFT, labelWindow, TOPLEFT, 0, 0)
        barLabel:SetDimensions(constants.WIDTH - 60, 22)
        local fontSize = isCompact and 16 or 18
        local fontString = string.format("$(BOLD_FONT)|%d|thick-outline", fontSize)
        barLabel:SetFont(fontString)
        barLabel:SetText("1000/1000")
        local settings = AKB.Settings.GetAll()
        local textColor = settings.textColor
        barLabel:SetColor(textColor.r, textColor.g, textColor.b, 1)
        barLabel:SetHidden(false)
        barLabel:SetMouseEnabled(false)
        barLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT or 0)
    end
    if percentLabel then
        percentLabel:SetAnchor(TOPRIGHT, labelWindow, TOPRIGHT, 0, 0)
        percentLabel:SetDimensions(55, 22)
        local fontSize = isCompact and 16 or 18
        local fontString = string.format("$(BOLD_FONT)|%d|thick-outline", fontSize)
        percentLabel:SetFont(fontString)
        percentLabel:SetText("100%")
        local settings = AKB.Settings.GetAll()
        local textColor = settings.textColor
        percentLabel:SetColor(textColor.r, textColor.g, textColor.b, 1)
        percentLabel:SetHidden(false)
        percentLabel:SetMouseEnabled(false)
        percentLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT or 2)
    end
    return labelWindow, barLabel, percentLabel
end

-- Create bar object with methods
function AKB.UI.Bars.CreateBarObject(barType, powerType, color, barWindow, labelWindow, barBackground, barFill, barLabel, actualBarHeight, shieldBar, percentLabel, regenArrowWindow, degenArrowWindow, barFrame, shieldGlow)
    local constants = AKB.Utils.BAR_CONSTANTS
    return {
        type = barType,
        powerType = powerType,
        color = color,
        window = barWindow,
        labelWindow = labelWindow,
        background = barBackground,
        frame = barFrame,  -- Add frame reference for 3D effect
        fill = barFill,
        label = barLabel,
        percentLabel = percentLabel,
        actualBarHeight = actualBarHeight,
        shieldBar = shieldBar,  -- Add shield bar reference
        shieldGlow = shieldGlow,  -- Phase 3: Add shield glow reference
        regenArrowWindow = regenArrowWindow,  -- Top-level window for regen arrow
        degenArrowWindow = degenArrowWindow,  -- Top-level window for degen arrow
        _lastPower = nil,
        _regenAnimActive = false,
        _degenAnimActive = false,
        _regenAnimId = nil,
        _degenAnimId = nil,
        _regenStackCount = 0,   -- number of active regen visual effects
        _degenStackCount = 0,   -- number of active degen visual effects
        _arrowDuration = 800, -- ms per pass (double speed; animation runs 2 passes)
    _arrowCooldownMs = 50, -- reduced cooldown for more responsive arrows in combat
    _lastRegenTrigger = 0,
    _lastDegenTrigger = 0,

        TriggerRegenArrow = function(self, durationMs)
            if not (self.type == "Health" and self.regenArrowWindow and EVENT_MANAGER) then return end
            local nowTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            -- Allow immediate triggering if opposite effect was recently active (combat dynamics)
            local allowOppositeOverride = (nowTime - self._lastDegenTrigger) < 500 -- 500ms override window
            if not allowOppositeOverride and (nowTime - self._lastRegenTrigger < self._arrowCooldownMs) then return end
            self._lastRegenTrigger = nowTime
            -- Stack counting is handled exclusively by the ADDED event; do not increment here
            local barWidth = self.barWidth or constants.WIDTH
            local contentWidth = barWidth - (constants.BORDER * 2)
            local arrowSize = math.floor((self.actualBarHeight - (constants.BORDER * 2)) * 0.9)
            local id = (self.window and self.window.GetName and self.window:GetName() or "AKB_Health") .. "_RegenMove"
            self._regenAnimId = id
            self._regenAnimActive = true
            
            -- Get initial position from window anchor - start offset from center, move right
            local barXPos = self.window:GetLeft()
            local barYPos = self.window:GetTop()
            local bgY = 10  -- Same as bgY from creation
            local centerX = barXPos + 10 + (constants.WIDTH / 2) - (arrowSize / 2)  -- True center of bar
            local offsetAmount = arrowSize * 0.6  -- Offset by 60% of arrow size to prevent overlap
            local arrowSpacing = math.floor(arrowSize * 0.4)  -- Must match creation spacing
            -- Lead arrow is the rightmost (at window offset arrowSpacing*2); shift window left by arrowSpacing*2
            -- so the lead starts at the original single-arrow start point (slightly right of center).
            local startX = centerX + offsetAmount - arrowSpacing * 2  -- Lead arrow starts at centerX + offsetAmount
            local endX = barXPos + 10 + constants.WIDTH - constants.BORDER - arrowSize - arrowSpacing * 2  -- Lead arrow ends at right border
            local fixedY = barYPos + bgY + (self.actualBarHeight - arrowSize) / 2
            
            -- Start at offset position (left of center)
            self.regenArrowWindow:ClearAnchors()
            self.regenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, startX, fixedY)
            self.regenArrowWindow:SetHidden(false)
            
            local startTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            local duration = ((type(durationMs) == "number" and durationMs > 0) and durationMs or self._arrowDuration * 2) / 2  -- per-pass duration
            local totalDuration = duration * 2  -- 2 passes total
            EVENT_MANAGER:UnregisterForUpdate(id)
            EVENT_MANAGER:RegisterForUpdate(id, 16, function()
                local now = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or startTime
                local elapsed = now - startTime
                if elapsed >= totalDuration then
                    if self._regenStackCount > 0 then
                        -- Stacks still active: loop back to pass 1
                        startTime = now
                        self.regenArrowWindow:ClearAnchors()
                        self.regenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, startX, fixedY)
                        return
                    end
                    self.regenArrowWindow:SetHidden(true)
                    self._regenAnimActive = false
                    EVENT_MANAGER:UnregisterForUpdate(id)
                    return
                end
                local t = (elapsed % duration) / duration  -- loops back to 0 at start of pass 2
                local currentX = startX + (endX - startX) * t
                self.regenArrowWindow:ClearAnchors()
                self.regenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, currentX, fixedY)
            end)
        end,

        TriggerDegenArrow = function(self, durationMs)
            if not (self.type == "Health" and self.degenArrowWindow and EVENT_MANAGER) then return end
            local nowTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            -- Allow immediate triggering if opposite effect was recently active (combat dynamics)
            local allowOppositeOverride = (nowTime - self._lastRegenTrigger) < 500 -- 500ms override window
            if not allowOppositeOverride and (nowTime - self._lastDegenTrigger < self._arrowCooldownMs) then return end
            self._lastDegenTrigger = nowTime
            -- Stack counting is handled exclusively by the ADDED event; do not increment here
            local barWidth = self.barWidth or constants.WIDTH
            local arrowSize = math.floor((self.actualBarHeight - (constants.BORDER * 2)) * 0.9)
            local id2 = (self.window and self.window.GetName and self.window:GetName() or "AKB_Health") .. "_DegenMove"
            self._degenAnimId = id2
            self._degenAnimActive = true
            
            -- Get initial position from window anchor - start offset from center, move left
            local barXPos = self.window:GetLeft()
            local barYPos = self.window:GetTop()
            local bgY = 10  -- Same as bgY from creation
            local centerX = barXPos + 10 + (constants.WIDTH / 2) - (arrowSize / 2)  -- True center of bar
            local offsetAmount = arrowSize * 0.6  -- Offset by 60% of arrow size to prevent overlap
            local arrowSpacing = math.floor(arrowSize * 0.4)  -- Must match creation spacing
            -- Lead arrow is the leftmost (window offset 0); window left position = lead arrow left.
            -- startX unchanged from original single-arrow start point (slightly left of center).
            local startX = centerX - offsetAmount  -- Lead (left) arrow starts at centerX - offsetAmount
            local endX = barXPos + 10 + constants.BORDER  -- Lead arrow ends at left border (window left aligns)
            local fixedY = barYPos + bgY + (self.actualBarHeight - arrowSize) / 2
            
            -- Start at offset position (right of center)
            self.degenArrowWindow:ClearAnchors()
            self.degenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, startX, fixedY)
            self.degenArrowWindow:SetHidden(false)
            
            local startTime2 = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            local duration2 = ((type(durationMs) == "number" and durationMs > 0) and durationMs or self._arrowDuration * 2) / 2  -- per-pass duration
            local totalDuration2 = duration2 * 2  -- 2 passes total
            EVENT_MANAGER:UnregisterForUpdate(id2)
            EVENT_MANAGER:RegisterForUpdate(id2, 16, function()
                local now = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or startTime2
                local elapsed = now - startTime2
                if elapsed >= totalDuration2 then
                    if self._degenStackCount > 0 then
                        -- Stacks still active: loop back to pass 1
                        startTime2 = now
                        self.degenArrowWindow:ClearAnchors()
                        self.degenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, startX, fixedY)
                        return
                    end
                    self.degenArrowWindow:SetHidden(true)
                    self._degenAnimActive = false
                    EVENT_MANAGER:UnregisterForUpdate(id2)
                    return
                end
                local t = (elapsed % duration2) / duration2  -- loops back to 0 at start of pass 2
                local currentX = startX + (endX - startX) * t
                self.degenArrowWindow:ClearAnchors()
                self.degenArrowWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, currentX, fixedY)
            end)
        end,

        HideRegenArrow = function(self, force)
            -- Decrement stack count; only hide if all stacks are gone (or forced)
            self._regenStackCount = math.max(0, self._regenStackCount - 1)
            if not force and self._regenStackCount > 0 then return end
            self._regenStackCount = 0
            if self.regenArrowWindow then self.regenArrowWindow:SetHidden(true) end
            if EVENT_MANAGER and self._regenAnimId then EVENT_MANAGER:UnregisterForUpdate(self._regenAnimId) end
            self._regenAnimActive = false
        end,

        HideDegenArrow = function(self, force)
            -- Decrement stack count; only hide if all stacks are gone (or forced)
            self._degenStackCount = math.max(0, self._degenStackCount - 1)
            if not force and self._degenStackCount > 0 then return end
            self._degenStackCount = 0
            if self.degenArrowWindow then self.degenArrowWindow:SetHidden(true) end
            if EVENT_MANAGER and self._degenAnimId then EVENT_MANAGER:UnregisterForUpdate(self._degenAnimId) end
            self._degenAnimActive = false
        end,
        
        Update = function(self, currentPower, maxPower)
            if not currentPower or not maxPower then
                return
            end
            
            -- For mount stamina, show the bar even if maxPower is 0 (when not on a mount)
            if maxPower == 0 and self.type ~= "MountStamina" then
                return
            end
            
            local percentage = 0
            local fillWidth = 0
            
            if maxPower > 0 then
                percentage = math.floor((currentPower / maxPower) * 100)
                -- Use custom bar width for mount stamina, or default width for other bars
                local barWidth = self.barWidth or constants.WIDTH
                fillWidth = ((barWidth - (constants.BORDER * 2)) * currentPower) / maxPower
            end
            
            if self.fill and self.fill.SetDimensions then
                -- Use smooth animation for bar width changes
                if AKB.Animation and AKB.Animation.AnimateBarWidth then
                    local targetHeight = self.actualBarHeight - (constants.BORDER * 2)
                    AKB.Animation.AnimateBarWidth(self.fill, fillWidth, targetHeight)
                else
                    -- Fallback to instant update if animation system isn't available
                    self.fill:SetDimensions(fillWidth, self.actualBarHeight - (constants.BORDER * 2))
                end
            end
            
            -- Update shield bar for health bars - always check for shields
            if self.type == "Health" and self.shieldBar then
                local shieldValue = AKB.Utils.GetShieldValue("player")
                
                
                if shieldValue > 0 then
                    local shieldPercentage = shieldValue / maxPower
                    -- Cap shield bar width to never exceed the maximum health bar width (100%)
                    if shieldPercentage > 1.0 then
                        shieldPercentage = 1.0
                    end
                    -- Use custom bar width for mount stamina, or default width for other bars
                    local barWidth = self.barWidth or constants.WIDTH
                    local shieldWidth = ((barWidth - (constants.BORDER * 2)) * shieldPercentage)
                    
                    -- Use smooth animation for shield bar width changes
                    if AKB.Animation and AKB.Animation.AnimateBarWidth then
                        local targetHeight = self.actualBarHeight - (constants.BORDER * 2)
                        AKB.Animation.AnimateBarWidth(self.shieldBar, shieldWidth, targetHeight)
                    else
                        -- Fallback to instant update if animation system isn't available
                        self.shieldBar:SetDimensions(shieldWidth, self.actualBarHeight - (constants.BORDER * 2))
                        -- Phase 3: Resize shield glow to match shield size
                        if self.shieldGlow then
                            self.shieldGlow:SetDimensions(shieldWidth, self.actualBarHeight - (constants.BORDER * 2))
                        end
                    end
                    self.shieldBar:SetHidden(false)
                    -- Phase 3: Show shield glow when shield is visible
                    if self.shieldGlow then
                        self.shieldGlow:SetHidden(false)
                    end
                else
                    self.shieldBar:SetHidden(true)
                    -- Phase 3: Hide shield glow when shield is hidden
                    if self.shieldGlow then
                        self.shieldGlow:SetHidden(true)
                    end
                end
            end
            
            if self.label and self.label.SetText then
                local settings = AKB.Settings.GetAll()
                local currentText = AKB.Utils.FormatNumberByType(currentPower, settings.textFormatType)
                local maxText = AKB.Utils.FormatNumberByType(maxPower, settings.textFormatType)
                local labelText = currentText .. "/" .. maxText
                -- Add shield value to health text - always show for health bars
                if self.type == "Health" then
                    local shieldValue = AKB.Utils.GetShieldValue("player")
                    if shieldValue > 0 then
                        local shieldText = AKB.Utils.FormatNumberByType(shieldValue, settings.textFormatType)
                        labelText = labelText .. " [" .. shieldText .. "]"
                    end
                end
                self.label:SetText(labelText)
                -- Update text color
                local textColor = settings.textColor
                self.label:SetColor(textColor.r, textColor.g, textColor.b, 1)
            end
            if self.percentLabel and self.percentLabel.SetText and not AKB.Settings.GetAll().hidePercentage then
                local percentageText = percentage .. "%"
                self.percentLabel:SetText(percentageText)
                local textColor = AKB.Settings.GetAll().textColor
                self.percentLabel:SetColor(textColor.r, textColor.g, textColor.b, 1)
            end
            
            if self.fill and self.fill.SetColor then
                local settings = AKB.Settings.GetAll()
                self.fill:SetColor(self.color.r, self.color.g, self.color.b, settings.barTransparency)
                
                -- Phase 2: Update gradient when color changes (gamepad compatible)
                if self.fill.SetGradientColors then
                    -- Create lighter top and darker bottom for 3D depth effect
                    local lighter = {
                        r = math.min(1.0, self.color.r + 0.2), 
                        g = math.min(1.0, self.color.g + 0.2), 
                        b = math.min(1.0, self.color.b + 0.2)
                    }
                    local darker = {
                        r = math.max(0.0, self.color.r - 0.15), 
                        g = math.max(0.0, self.color.g - 0.15), 
                        b = math.max(0.0, self.color.b - 0.15)
                    }
                    
                    -- Direction 2 = vertical gradient (top to bottom)
                    self.fill:SetGradientColors(2, 
                        lighter.r, lighter.g, lighter.b, settings.barTransparency,  -- Top (lighter)
                        darker.r, darker.g, darker.b, settings.barTransparency      -- Bottom (darker)
                    )
                end
            end

            -- No delta-based detection - using pure event-driven approach like BanditsUI/archive
            -- Arrows are triggered only by EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED with sequenceId == 0
        end,
        
        Show = function(self)
            if self.window and self.window.SetHidden then
                self.window:SetHidden(false)
            end
            if self.labelWindow and self.labelWindow.SetHidden then
                self.labelWindow:SetHidden(false)
            end
            if self.mountIcon and self.mountIcon.SetHidden then
                self.mountIcon:SetHidden(false)
            end
            -- Do not forcibly hide arrows here; allow active animation to remain visible
        end,
        
        Hide = function(self)
            if self.window and self.window.SetHidden then
                self.window:SetHidden(true)
            end
            if self.labelWindow and self.labelWindow.SetHidden then
                self.labelWindow:SetHidden(true)
            end
            if self.mountIcon and self.mountIcon.SetHidden then
                self.mountIcon:SetHidden(true)
            end
            if self.HideRegenArrow then self:HideRegenArrow(true) end
            if self.HideDegenArrow then self:HideDegenArrow(true) end
        end,
        
        Destroy = function(self)
            -- Stop arrow animations and hide arrows
            if self.HideRegenArrow then self:HideRegenArrow(true) end
            if self.HideDegenArrow then self:HideDegenArrow(true) end
            if self.regenArrow then
                self.regenArrow:SetHidden(true)
                if self.regenArrow.ClearAnchors then self.regenArrow:ClearAnchors() end
                if self.regenArrow.SetParent then self.regenArrow:SetParent(nil) end
            end
            if self.degenArrow then
                self.degenArrow:SetHidden(true)
                if self.degenArrow.ClearAnchors then self.degenArrow:ClearAnchors() end
                if self.degenArrow.SetParent then self.degenArrow:SetParent(nil) end
            end

            -- Mount icon cleanup
            if self.mountIcon then
                self.mountIcon:SetHidden(true)
                if self.mountIcon.ClearAnchors then self.mountIcon:ClearAnchors() end
                if self.mountIcon.SetParent then self.mountIcon:SetParent(nil) end
            end

            -- Shield bar cleanup
            if self.shieldBar then
                self.shieldBar:SetHidden(true)
                if self.shieldBar.ClearAnchors then self.shieldBar:ClearAnchors() end
                if self.shieldBar.SetParent then self.shieldBar:SetParent(nil) end
            end

            -- Text cleanup
            if self.label then
                self.label:SetHidden(true)
                if self.label.ClearAnchors then self.label:ClearAnchors() end
                if self.label.SetParent then self.label:SetParent(nil) end
            end
            if self.labelWindow then
                self.labelWindow:SetHidden(true)
                if self.labelWindow.ClearAnchors then self.labelWindow:ClearAnchors() end
                if self.labelWindow.SetParent then self.labelWindow:SetParent(nil) end
            end

            -- Bar pieces cleanup
            if self.fill then
                self.fill:SetHidden(true)
                if self.fill.ClearAnchors then self.fill:ClearAnchors() end
                if self.fill.SetParent then self.fill:SetParent(nil) end
            end
            if self.background then
                self.background:SetHidden(true)
                if self.background.ClearAnchors then self.background:ClearAnchors() end
                if self.background.SetParent then self.background:SetParent(nil) end
            end
            if self.window then
                self.window:SetHidden(true)
                if self.window.ClearAnchors then self.window:ClearAnchors() end
                if self.window.SetParent then self.window:SetParent(nil) end
            end
        end
    }
end

-- Public factory functions
function AKB.UI.Bars.CreateSingleAttributeBar(barType, powerType, xOffset, yOffset, color)
    return CreateSingleAttributeBar(barType, powerType, xOffset, yOffset, color)
end

function AKB.UI.Bars.CreateMountStaminaBar(barType, powerType, xOffset, yOffset, color)
    return CreateMountStaminaBar(barType, powerType, xOffset, yOffset, color)
end
