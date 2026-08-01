-- ============================================================================
-- AKsAttributeBars - Enemy Health Bars Module
-- ============================================================================
-- Displays health bars for targeted enemies

local AKB = AKsAttributeBars

-- Create enemy bars namespace
AKB.EnemyBars = AKB.EnemyBars or {}

-- Local variables
local enemyNameLabel = nil
local enemyChampionIcon = nil
local enemyChampionLabel = nil
local enemyHealthBar = nil
local enemyBarWindow = nil
local currentTarget = nil
local currentTargetIsHostile = false

-- Console-safe draw constants (matching player bars)
local DT_LOW = 1
local DT_MEDIUM = 2  
local DT_HIGH = 3
local DL_BACKGROUND = DL_BACKGROUND or 1
local DL_OVERLAY = DL_OVERLAY or 6

-- Initialize the enemy bars system
function AKB.EnemyBars.Initialize()
    -- Create the enemy bar UI elements (hidden by default)
    AKB.EnemyBars.CreateEnemyBar()
    
    -- Register for events
    AKB.EnemyBars.RegisterEvents()
end

-- Create the enemy health bar UI
function AKB.EnemyBars.CreateEnemyBar()
    if enemyBarWindow then
        return -- Already created
    end
    
    local settings = AKB.Settings.GetAll()
    local width = settings.enemyBarWidth or 300
    local height = settings.enemyBarHeight or 20
    
    -- Main window container
    enemyBarWindow = WINDOW_MANAGER:CreateTopLevelWindow("AKB_EnemyBarWindow")
    if not enemyBarWindow then return end
    
    enemyBarWindow:SetDimensions(width + 40, height + 60) -- Extra space for larger text
    enemyBarWindow:SetAnchor(CENTER, GuiRoot, CENTER, settings.enemyBarXPosition or 0, settings.enemyBarYPosition or -150)
    enemyBarWindow:SetMovable(false)
    enemyBarWindow:SetMouseEnabled(false)
    enemyBarWindow:SetHidden(true)
    
    -- Enemy name label (left-aligned, with space reserved for champion elements on gamepad UI)
    enemyNameLabel = WINDOW_MANAGER:CreateControl("AKB_EnemyNameLabel", enemyBarWindow, CT_LABEL)
    if enemyNameLabel then
        enemyNameLabel:SetFont("$(BOLD_FONT)|20|thick-outline")
        enemyNameLabel:SetColor(1, 1, 1, 1)
        enemyNameLabel:SetText("")
        enemyNameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        -- Reserve space for champion elements on gamepad UI - leave 80px for icon + CP number
        local maxNameWidth = width - 80
        enemyNameLabel:SetDimensionConstraints(0, 0, maxNameWidth, 40)
        -- Enable text clipping for gamepad UI to handle long names gracefully
        if enemyNameLabel.SetWrapMode then enemyNameLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    end
    
    -- Health bar background (with gradient depth like player bars)
    local barBackground = WINDOW_MANAGER:CreateControl("AKB_EnemyBarBG", enemyBarWindow, CT_TEXTURE)
    if barBackground then
        barBackground:SetDimensions(width, height)
        barBackground:SetAnchor(TOP, enemyBarWindow, TOP, 0, 35) -- More space for larger text
        barBackground:SetColor(0, 0, 0, 0.5)
        
        -- Add subtle gradient for 3D depth (like player bars)
        if barBackground.SetGradientColors then
            barBackground:SetGradientColors(2, 
                0.0, 0.0, 0.0, 0.6,  -- Top (darker)
                0.1, 0.1, 0.1, 0.4   -- Bottom (slightly lighter)
            )
        end
        
        if barBackground.SetDrawTier then barBackground:SetDrawTier(DT_LOW) end
        if barBackground.SetDrawLayer then barBackground:SetDrawLayer(DL_BACKGROUND) end
        if barBackground.SetDrawLevel then barBackground:SetDrawLevel(1) end
        barBackground:SetHidden(false)
        
        -- Reposition enemy name label to anchor to bar background for stable positioning
        if enemyNameLabel then
            enemyNameLabel:SetAnchor(TOPLEFT, barBackground, TOPLEFT, 0, -25) -- Position above bar, aligned with left edge
        end
        
        -- Create champion icon (initially hidden, positioned at same level as name)
        enemyChampionIcon = WINDOW_MANAGER:CreateControl("AKB_EnemyChampionIcon", enemyBarWindow, CT_TEXTURE)
        if enemyChampionIcon then
            enemyChampionIcon:SetDimensions(24, 24)
            enemyChampionIcon:SetTexture("EsoUI/Art/Champion/champion_icon.dds")
            enemyChampionIcon:SetColor(1, 1, 1, 1)
            enemyChampionIcon:SetAnchor(TOPLEFT, barBackground, TOPLEFT, 0, -25) -- Same level as name label
            enemyChampionIcon:SetHidden(true)
            enemyChampionIcon:SetMouseEnabled(false)
            if enemyChampionIcon.SetDrawTier then enemyChampionIcon:SetDrawTier(DT_HIGH) end
        end
        
        -- Create champion level label (initially hidden, positioned after icon)
        enemyChampionLabel = WINDOW_MANAGER:CreateControl("AKB_EnemyChampionLabel", enemyBarWindow, CT_LABEL)
        if enemyChampionLabel then
            enemyChampionLabel:SetFont("$(BOLD_FONT)|20|thick-outline")
            enemyChampionLabel:SetColor(1, 1, 1, 1)
            enemyChampionLabel:SetText("")
            enemyChampionLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            enemyChampionLabel:SetAnchor(TOPLEFT, barBackground, TOPLEFT, 28, -25) -- Positioned after icon (24px width + 4px spacing)
            enemyChampionLabel:SetHidden(true)
            enemyChampionLabel:SetMouseEnabled(false)
        end
    end
    
    -- Create professional border system (like player bars)
    local borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.9}
    local borderThickness = 1
    
    -- Top border
    local topBorder = WINDOW_MANAGER:CreateControl("AKB_EnemyTopBorder", enemyBarWindow, CT_TEXTURE)
    if topBorder then
        topBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, -borderThickness)
        topBorder:SetDimensions(width + (borderThickness * 2), borderThickness)
        topBorder:SetTexture("")
        topBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if topBorder.SetDrawTier then topBorder:SetDrawTier(DT_LOW) end
        if topBorder.SetDrawLayer then topBorder:SetDrawLayer(DL_BACKGROUND) end
        if topBorder.SetDrawLevel then topBorder:SetDrawLevel(3) end
        topBorder:SetHidden(false)
    end
    
    -- Bottom border
    local bottomBorder = WINDOW_MANAGER:CreateControl("AKB_EnemyBottomBorder", enemyBarWindow, CT_TEXTURE)
    if bottomBorder then
        bottomBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, height)
        bottomBorder:SetDimensions(width + (borderThickness * 2), borderThickness)
        bottomBorder:SetTexture("")
        bottomBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if bottomBorder.SetDrawTier then bottomBorder:SetDrawTier(DT_LOW) end
        if bottomBorder.SetDrawLayer then bottomBorder:SetDrawLayer(DL_BACKGROUND) end
        if bottomBorder.SetDrawLevel then bottomBorder:SetDrawLevel(3) end
        bottomBorder:SetHidden(false)
    end
    
    -- Left border
    local leftBorder = WINDOW_MANAGER:CreateControl("AKB_EnemyLeftBorder", enemyBarWindow, CT_TEXTURE)
    if leftBorder then
        leftBorder:SetAnchor(TOPLEFT, barBackground, TOPLEFT, -borderThickness, 0)
        leftBorder:SetDimensions(borderThickness, height)
        leftBorder:SetTexture("")
        leftBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if leftBorder.SetDrawTier then leftBorder:SetDrawTier(DT_LOW) end
        if leftBorder.SetDrawLayer then leftBorder:SetDrawLayer(DL_BACKGROUND) end
        if leftBorder.SetDrawLevel then leftBorder:SetDrawLevel(3) end
        leftBorder:SetHidden(false)
    end
    
    -- Right border
    local rightBorder = WINDOW_MANAGER:CreateControl("AKB_EnemyRightBorder", enemyBarWindow, CT_TEXTURE)
    if rightBorder then
        rightBorder:SetAnchor(TOPRIGHT, barBackground, TOPRIGHT, borderThickness, 0)
        rightBorder:SetDimensions(borderThickness, height)
        rightBorder:SetTexture("")
        rightBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        if rightBorder.SetDrawTier then rightBorder:SetDrawTier(DT_LOW) end
        if rightBorder.SetDrawLayer then rightBorder:SetDrawLayer(DL_BACKGROUND) end
        if rightBorder.SetDrawLevel then rightBorder:SetDrawLevel(3) end
        rightBorder:SetHidden(false)
    end
    
    -- Health bar fill (with 3D visual effects like player bars)
    enemyHealthBar = WINDOW_MANAGER:CreateControl("AKB_EnemyHealthBar", enemyBarWindow, CT_TEXTURE)
    if enemyHealthBar then
        local borderSize = 1 -- Match border thickness for proper inset
        enemyHealthBar:SetDimensions(width - (borderSize * 2), height - (borderSize * 2))
        enemyHealthBar:SetAnchor(LEFT, barBackground, LEFT, borderSize, borderSize) -- Properly inset from borders
        local healthColor = settings.enemyHealthColor or {r = 0.8, g = 0.2, b = 0.2}
        local transparency = settings.enemyBarTransparency or 1.0
        enemyHealthBar:SetColor(healthColor.r, healthColor.g, healthColor.b, transparency)
        
        if enemyHealthBar.SetDrawTier then enemyHealthBar:SetDrawTier(DT_LOW) end
        if enemyHealthBar.SetDrawLayer then enemyHealthBar:SetDrawLayer(DL_BACKGROUND) end
        if enemyHealthBar.SetDrawLevel then enemyHealthBar:SetDrawLevel(2) end
        enemyHealthBar:SetHidden(false)
        
        -- Store border references for dynamic resizing
        enemyHealthBar.topBorder = topBorder
        enemyHealthBar.bottomBorder = bottomBorder
        enemyHealthBar.leftBorder = leftBorder
        enemyHealthBar.rightBorder = rightBorder
        
        -- Create subtle highlight overlay for top portion (3D effect)
        local highlightOverlay = WINDOW_MANAGER:CreateControl("AKB_EnemyHighlight", enemyBarWindow, CT_TEXTURE)
        if highlightOverlay then
            local overlayHeight = math.floor((height - (borderSize * 2)) * 0.5) -- Top 50%
            highlightOverlay:SetAnchor(TOPLEFT, enemyHealthBar, TOPLEFT, 0, 0)
            highlightOverlay:SetDimensions(width - (borderSize * 2), overlayHeight)
            highlightOverlay:SetColor(1, 1, 1, 0.08) -- Subtle white highlight
            if highlightOverlay.SetDrawTier then highlightOverlay:SetDrawTier(DT_LOW) end
            if highlightOverlay.SetDrawLayer then highlightOverlay:SetDrawLayer(DL_OVERLAY) end
            if highlightOverlay.SetDrawLevel then highlightOverlay:SetDrawLevel(4) end
            highlightOverlay:SetHidden(false)
        end
        
        -- Create subtle shadow overlay for bottom portion (3D effect)
        local shadowOverlay = WINDOW_MANAGER:CreateControl("AKB_EnemyShadow", enemyBarWindow, CT_TEXTURE)
        if shadowOverlay then
            local overlayHeight = math.floor((height - (borderSize * 2)) * 0.4) -- Bottom 40%
            local yOffset = (height - (borderSize * 2)) - overlayHeight
            shadowOverlay:SetAnchor(TOPLEFT, enemyHealthBar, TOPLEFT, 0, yOffset)
            shadowOverlay:SetDimensions(width - (borderSize * 2), overlayHeight)
            shadowOverlay:SetColor(0, 0, 0, 0.12) -- Subtle black shadow
            if shadowOverlay.SetDrawTier then shadowOverlay:SetDrawTier(DT_LOW) end
            if shadowOverlay.SetDrawLayer then shadowOverlay:SetDrawLayer(DL_OVERLAY) end
            if shadowOverlay.SetDrawLevel then shadowOverlay:SetDrawLevel(4) end
            shadowOverlay:SetHidden(false)
        end
        
        -- Inner glow effect for professional lighting
        local innerGlow = WINDOW_MANAGER:CreateControl("AKB_EnemyGlow", enemyBarWindow, CT_TEXTURE)
        if innerGlow then
            innerGlow:SetAnchor(TOPLEFT, enemyHealthBar, TOPLEFT, 0, 0)
            innerGlow:SetDimensions(width - (borderSize * 2), height - (borderSize * 2))
            innerGlow:SetColor(healthColor.r, healthColor.g, healthColor.b, 0.06) -- Color-matched glow
            if innerGlow.SetDrawTier then innerGlow:SetDrawTier(DT_LOW) end
            if innerGlow.SetDrawLayer then innerGlow:SetDrawLayer(DL_OVERLAY) end
            if innerGlow.SetDrawLevel then innerGlow:SetDrawLevel(3) end
            innerGlow:SetHidden(false)
            enemyHealthBar.innerGlow = innerGlow -- Store reference for dynamic color updates
        end
        
        -- Edge lighting effect for depth and separation  
        local edgeLight = WINDOW_MANAGER:CreateControl("AKB_EnemyEdge", enemyBarWindow, CT_TEXTURE)
        if edgeLight then
            local edgeThickness = 1
            edgeLight:SetAnchor(TOPLEFT, enemyHealthBar, TOPLEFT, edgeThickness, edgeThickness)
            edgeLight:SetDimensions(width - (borderSize * 2) - (edgeThickness * 2), 
                                   height - (borderSize * 2) - (edgeThickness * 2))
            edgeLight:SetColor(1, 1, 1, 0.05) -- Subtle white rim light
            if edgeLight.SetDrawTier then edgeLight:SetDrawTier(DT_LOW) end
            if edgeLight.SetDrawLayer then edgeLight:SetDrawLayer(DL_OVERLAY) end
            if edgeLight.SetDrawLevel then edgeLight:SetDrawLevel(5) end
            edgeLight:SetHidden(false)
        end
    end
    
    -- Create separate label window (like player bars) - This ensures text is always on top
    local labelWindow = WINDOW_MANAGER:CreateTopLevelWindow("AKB_EnemyLabelWindow")
    if labelWindow then
        -- Convert CENTER-based enemy bar positioning to TOPLEFT absolute positioning like player bars
        local screenCenterX = GuiRoot:GetWidth() / 2
        local screenCenterY = GuiRoot:GetHeight() / 2
        local enemyBarCenterX = screenCenterX + (settings.enemyBarXPosition or 0)
        local enemyBarCenterY = screenCenterY + (settings.enemyBarYPosition or -150)
        
        -- Calculate TOPLEFT position for label window (matching player bar approach)
        local bgY = 35  -- Background Y offset within enemy bar window
        local labelY = bgY + height / 2 - 10  -- Player bar centering formula
        local labelXPos = enemyBarCenterX - (width + 40) / 2 + 25  -- Align with bar content, not window edge
        local labelYPos = enemyBarCenterY - (height + 60) / 2 + labelY  -- Convert to TOPLEFT, add calculated Y
        
        labelWindow:SetDimensions(width - 10, 22)  -- Match the actual bar width more closely
        labelWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, labelXPos, labelYPos)
        labelWindow:SetClampedToScreen(true)
        labelWindow:SetMouseEnabled(false)
        labelWindow:SetMovable(false)
        labelWindow:SetHidden(false)
    end
    
    -- Health value text (left-aligned) - In separate window like player bars
    local healthValueText = WINDOW_MANAGER:CreateControl("AKB_EnemyHealthValue", labelWindow, CT_LABEL)
    if healthValueText then
        healthValueText:SetFont("$(BOLD_FONT)|18|thick-outline")
        healthValueText:SetColor(1, 1, 1, 1)
        healthValueText:SetAnchor(TOPLEFT, labelWindow, TOPLEFT, 0, 0)  -- No offset, direct alignment like player bars
        healthValueText:SetDimensions(width - 60, 22) -- Leave space for percentage
        healthValueText:SetText("")
        healthValueText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        healthValueText:SetHidden(false)
        healthValueText:SetMouseEnabled(false)
    end
    
    -- Health percentage text (right-aligned) - In separate window like player bars
    local healthPercentText = WINDOW_MANAGER:CreateControl("AKB_EnemyHealthPercent", labelWindow, CT_LABEL)
    if healthPercentText then
        healthPercentText:SetFont("$(BOLD_FONT)|18|thick-outline")
        healthPercentText:SetColor(1, 1, 1, 1)
        healthPercentText:SetAnchor(TOPRIGHT, labelWindow, TOPRIGHT, 0, 0)  -- No offset, direct alignment like player bars
        healthPercentText:SetDimensions(55, 22) -- Fixed width for percentage
        healthPercentText:SetText("")
        healthPercentText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        healthPercentText:SetHidden(false)
        healthPercentText:SetMouseEnabled(false)
        
        -- Store references for proper updating
        if enemyHealthBar then
            enemyHealthBar.healthValueText = healthValueText
            enemyHealthBar.healthPercentText = healthPercentText
            enemyHealthBar.labelWindow = labelWindow -- Store label window reference
        end
        
        -- Store references to background for proper updating
        enemyHealthBar.background = barBackground
        enemyHealthBar.fullWidth = width
        
        -- Add border update function for dynamic resizing
        enemyHealthBar.UpdateBorders = function(self, newWidth)
            local borderThickness = 1
            if self.topBorder then
                self.topBorder:SetDimensions(newWidth + (borderThickness * 2), borderThickness)
            end
            if self.bottomBorder then
                self.bottomBorder:SetDimensions(newWidth + (borderThickness * 2), borderThickness)
            end
            -- Left and right borders don't need width updates, only height which stays constant
        end
        
        -- Add Update method to the health bar
        enemyHealthBar.Update = function(self, currentHealth, maxHealth)
            -- Ensure valid values, provide defaults if missing
            currentHealth = tonumber(currentHealth) or 0
            maxHealth = tonumber(maxHealth) or 1
            
            -- Calculate percentage and bar width
            local percentage = 0
            if maxHealth > 0 then
                percentage = (currentHealth / maxHealth)
            end
            local fillWidth = math.max(1, self.fullWidth * percentage) -- Ensure at least 1 pixel width
            
            -- Update borders to match new width
            if self.UpdateBorders then
                self:UpdateBorders(self.fullWidth) -- Use full width for borders
            end
            
            -- Update bar width to show current health using smooth animation
            if self.SetDimensions then
                -- Use smooth animation for enemy health bar width changes
                if AKB.Animation and AKB.Animation.AnimateBarWidth then
                    local settings = AKB.Settings.GetAll()
                    local targetHeight = settings.enemyBarHeight or 20
                    AKB.Animation.AnimateBarWidth(self, fillWidth, targetHeight)
                else
                    -- Fallback to instant update if animation system isn't available
                    self:SetDimensions(fillWidth, height)
                end
                
                -- If health is 0, hide the bar
                if currentHealth == 0 then
                    self:SetHidden(true)
                else
                    self:SetHidden(false)
                end
            end
            
            -- Update health text using separate labels (like custom health bars)
            if self.healthValueText and self.healthPercentText then
                local settings = AKB.Settings.GetAll()
                local textFormatType = settings.enemyTextFormatType or 1
                local hidePercent = settings.enemyHidePercentage or false
                local textColor = settings.enemyTextColor or {r=1, g=1, b=1}
                
                -- Format health value text (current/max)
                local currentText = AKB.Utils.FormatNumberByType(currentHealth, textFormatType)
                local maxText = AKB.Utils.FormatNumberByType(maxHealth, textFormatType)
                local healthValueLabel = currentText .. "/" .. maxText
                
                -- Format percentage text
                local percentText = math.floor(percentage * 100) .. "%"
                
                -- Update left-aligned health value
                if self.healthValueText.SetText then
                    self.healthValueText:SetText(healthValueLabel)
                    if self.healthValueText.SetColor then
                        self.healthValueText:SetColor(textColor.r, textColor.g, textColor.b, 1)
                    end
                end
                
                -- Update right-aligned percentage (only if not hidden by settings)
                if self.healthPercentText.SetText then
                    if not hidePercent then
                        self.healthPercentText:SetText(percentText)
                        if self.healthPercentText.SetColor then
                            self.healthPercentText:SetColor(textColor.r, textColor.g, textColor.b, 1)
                        end
                        self.healthPercentText:SetHidden(false)
                    else
                        self.healthPercentText:SetHidden(true)
                    end
                end
            end
        end
    end
end

-- Register events for enemy targeting
function AKB.EnemyBars.RegisterEvents()
    if not EVENT_MANAGER then return end
    
    -- Target change event
    EVENT_MANAGER:RegisterForEvent(AKB.name .. "_EnemyTargetChanged", EVENT_RETICLE_TARGET_CHANGED, function()
        AKB.EnemyBars.OnTargetChanged()
    end)
    
    -- Health update event (filtered to reticleover)
    EVENT_MANAGER:RegisterForEvent(AKB.name .. "_EnemyHealthUpdate", EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        if unitTag == "reticleover" and powerType == 32 and currentTarget and AKB.Settings.Get("showEnemyBars") and enemyHealthBar then
            -- Direct update without throttling since events are efficient
            enemyHealthBar:Update(powerValue or 0, powerMax or 1)
        end
    end)
    
    -- Unit death event (for immediate cleanup when target dies)
    if EVENT_UNIT_DEATH_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_EnemyDeath", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
            if unitTag == "reticleover" and isDead and currentTarget then
                AKB.EnemyBars.HideEnemyBar()
            end
        end)
    end
    
    -- Combat state change event (hide bars when out of combat as additional cleanup)
    if EVENT_PLAYER_COMBAT_STATE then
        EVENT_MANAGER:RegisterForEvent(AKB.name .. "_EnemyCombat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            if not inCombat and currentTarget then
                -- Short delay to allow for target validation after leaving combat
                EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_EnemyValidation", 1000, function()
                    EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_EnemyValidation")
                    AKB.EnemyBars.OnTargetChanged() -- Revalidate current target
                end)
            end
        end)
    end
    
    -- Backup polling mechanism to catch edge cases (every 2 seconds)
    EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_EnemyPolling", 2000, function()
        if currentTarget and AKB.Settings.Get("showEnemyBars") then
            -- Validate current target still exists and is valid (like default bars)
            local targetName = GetUnitName("reticleover")
            if not targetName or targetName == "" or targetName ~= currentTarget or 
               not DoesUnitExist("reticleover") then
                AKB.EnemyBars.HideEnemyBar()
            end
        end
    end)
end

-- Handle target change events
function AKB.EnemyBars.OnTargetChanged()
    if not AKB.Settings.Get("showEnemyBars") then
        AKB.EnemyBars.HideEnemyBar()
        return
    end
    
    -- Check if we have a valid target
    local targetName = GetUnitName("reticleover")
    if not targetName or targetName == "" then
        AKB.EnemyBars.HideEnemyBar()
        return
    end
    
    -- Check if target exists (only requirement now - show all targets like default bars)
    if not DoesUnitExist("reticleover") then
        AKB.EnemyBars.HideEnemyBar()
        return
    end
    
    -- Only show bar if this is a new target or we need to refresh
    if currentTarget ~= targetName then
        currentTarget = targetName
        currentTargetIsHostile = (IsUnitAttackable and IsUnitAttackable("reticleover")) or false
        AKB.EnemyBars.ShowEnemyBar()
    end
end

-- Show the enemy bar for current target
function AKB.EnemyBars.ShowEnemyBar()
    if not enemyBarWindow or not currentTarget then
        return
    end
    
    -- Update enemy name and level display
    AKB.EnemyBars.UpdateEnemyInfo()
    
    -- Apply correct bar color based on whether target is hostile or allied
    AKB.EnemyBars.UpdateBarColor()
    
    -- Get current health and update bar
    AKB.EnemyBars.UpdateEnemyHealth()
    
    -- Show the bar and label window
    enemyBarWindow:SetHidden(false)
    if enemyHealthBar and enemyHealthBar.labelWindow then
        enemyHealthBar.labelWindow:SetHidden(false)
    end
    
    -- Start health polling for this target (less frequent since events work now)
    EVENT_MANAGER:RegisterForUpdate(AKB.name .. "_EnemyHealthPolling", 500, function()
        if currentTarget and DoesUnitExist("reticleover") and AKB.Settings.Get("showEnemyBars") then
            AKB.EnemyBars.UpdateEnemyHealth()
        else
            -- Stop polling if target is gone
            EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_EnemyHealthPolling")
        end
    end)
end

-- Update enemy health bar with current values
function AKB.EnemyBars.UpdateEnemyHealth()
    if not enemyHealthBar or not currentTarget then
        return
    end
    
    local currentHealth = nil
    local maxHealth = nil
    
    -- Get health values using powerType 32 (Enemy Health)
    if GetUnitPower and GetUnitMaxPower then
        currentHealth = GetUnitPower("reticleover", 32)
        maxHealth = GetUnitMaxPower("reticleover", 32)
    else
        return
    end
    
    -- Ensure we have valid values
    currentHealth = tonumber(currentHealth) or 0
    maxHealth = tonumber(maxHealth) or 1
    
    -- Update the health bar
    if enemyHealthBar and enemyHealthBar.Update then
        enemyHealthBar:Update(currentHealth, maxHealth)
    end
end

-- Hide the enemy bar
function AKB.EnemyBars.HideEnemyBar()
    if enemyBarWindow then
        enemyBarWindow:SetHidden(true)
    end
    
    -- Hide the label window too
    if enemyHealthBar and enemyHealthBar.labelWindow then
        enemyHealthBar.labelWindow:SetHidden(true)
    end
    
    -- Stop health polling when hiding
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_EnemyHealthPolling")
    end
    
    currentTarget = nil
    currentTargetIsHostile = false
end

-- Return the health color for the current target (enemy red vs ally green)
function AKB.EnemyBars.GetCurrentHealthColor()
    local settings = AKB.Settings.GetAll()
    if currentTargetIsHostile then
        return settings.enemyHealthColor or {r = 0.8, g = 0.2, b = 0.2}
    else
        return settings.targetAllyHealthColor or {r = 0.2, g = 0.8, b = 0.2}
    end
end

-- Apply the correct health color to the bar and inner glow for the current target
function AKB.EnemyBars.UpdateBarColor()
    if not enemyHealthBar then return end
    local healthColor = AKB.EnemyBars.GetCurrentHealthColor()
    local transparency = AKB.Settings.Get("enemyBarTransparency") or 1.0
    enemyHealthBar:SetColor(healthColor.r, healthColor.g, healthColor.b, transparency)
    if enemyHealthBar.innerGlow then
        enemyHealthBar.innerGlow:SetColor(healthColor.r, healthColor.g, healthColor.b, 0.06)
    end
end

-- Update enemy name and level information
function AKB.EnemyBars.UpdateEnemyInfo()
    if not enemyNameLabel or not currentTarget then
        return
    end
    
    local settings = AKB.Settings.GetAll()
    local displayText = ""
    
    -- Add target name (for all target types - friendly, enemy, dead, etc.)
    if settings.showEnemyName then
        local nameType = settings.enemyNameType or 1
        if nameType == AKB.Settings.ENEMY_NAME_TYPES.USERNAME then
            -- Use username for players, character name for NPCs
            local isPlayer = IsUnitPlayer("reticleover")
            if isPlayer then
                local fullDisplayName = GetUnitDisplayName("reticleover")
                -- Remove the "@" symbol if present and use username
                displayText = fullDisplayName and string.gsub(fullDisplayName, "^@", "") or currentTarget
            else
                -- For NPCs, always use character name since they don't have usernames
                displayText = currentTarget
            end
        else
            -- Use character name (default)
            displayText = currentTarget
        end
    end
    
    -- Handle level display for players only (not NPCs)
    if settings.showEnemyLevel then
        local level = GetUnitLevel("reticleover")
        local championPoints = GetUnitChampionPoints("reticleover")
        local isPlayer = IsUnitPlayer("reticleover")
        
        -- Only show level for players, not NPCs
        if level and level > 0 and isPlayer then
            if level >= 50 and championPoints and championPoints > 0 then
                -- Show champion icon immediately after the name text (left-adjusted, inline with name)
                if enemyChampionIcon then
                    enemyChampionIcon:ClearAnchors()
                    enemyChampionIcon:SetAnchor(LEFT, enemyNameLabel, RIGHT, 6, -4)
                    enemyChampionIcon:SetHidden(false)
                end
                
                if enemyChampionLabel then
                    enemyChampionLabel:SetText(tostring(championPoints))
                    enemyChampionLabel:ClearAnchors()
                    -- Position CP number immediately after the champion icon
                    enemyChampionLabel:SetAnchor(LEFT, enemyChampionIcon, RIGHT, 2, 4)
                    enemyChampionLabel:SetHidden(false)
                end
            else
                -- Show regular level with brackets for non-champions
                if displayText ~= "" then
                    displayText = displayText .. " [" .. level .. "]"
                else
                    displayText = "[" .. level .. "]"
                end
                
                -- Hide champion elements
                if enemyChampionIcon then enemyChampionIcon:SetHidden(true) end
                if enemyChampionLabel then enemyChampionLabel:SetHidden(true) end
            end
        else
            -- Hide champion elements for NPCs
            if enemyChampionIcon then enemyChampionIcon:SetHidden(true) end
            if enemyChampionLabel then enemyChampionLabel:SetHidden(true) end
        end
    else
        -- Hide champion elements if level display is disabled
        if enemyChampionIcon then enemyChampionIcon:SetHidden(true) end
        if enemyChampionLabel then enemyChampionLabel:SetHidden(true) end
    end
    
    enemyNameLabel:SetText(displayText)
end

-- Apply user settings to enemy bars
function AKB.EnemyBars.ApplySettings()
    if not enemyBarWindow then
        return
    end
    
    local settings = AKB.Settings.GetAll()
    
    -- Update positioning
    enemyBarWindow:ClearAnchors()
    enemyBarWindow:SetAnchor(CENTER, GuiRoot, CENTER, settings.enemyBarXPosition or 0, settings.enemyBarYPosition or -150)
    
    -- Update dimensions
    local width = settings.enemyBarWidth or 300
    local height = settings.enemyBarHeight or 20
    enemyBarWindow:SetDimensions(width + 20, height + 40)
    
    if enemyHealthBar then
        -- Update the background dimensions
        if enemyHealthBar.background then
            enemyHealthBar.background:SetDimensions(width, height)
        end
        
        -- Update the bar's full width reference
        enemyHealthBar.fullWidth = width
        
        -- Update colors and transparency based on current target type (enemy vs ally)
        AKB.EnemyBars.UpdateBarColor()
        
        -- If we have a target, refresh the display
        if currentTarget then
            local currentHealth = nil
            local maxHealth = nil
            if GetUnitPower and GetUnitMaxPower then
                currentHealth = GetUnitPower("reticleover", 32)
                maxHealth = GetUnitMaxPower("reticleover", 32)
            end
            if currentHealth and maxHealth then
                enemyHealthBar:Update(currentHealth, maxHealth)
            end
        end
    end
    
    -- Update info display
    if currentTarget then
        AKB.EnemyBars.UpdateEnemyInfo()
    end
end

-- Cleanup function
function AKB.EnemyBars.Cleanup()
    -- Clear any animations on enemy bars
    if enemyHealthBar and AKB.Animation and AKB.Animation.CancelAnimation then
        AKB.Animation.CancelAnimation(enemyHealthBar)
    end
    
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_EnemyTargetChanged", EVENT_RETICLE_TARGET_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_EnemyHealthUpdate", EVENT_POWER_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_EnemyDeath", EVENT_UNIT_DEATH_STATE_CHANGED)
        EVENT_MANAGER:UnregisterForEvent(AKB.name .. "_EnemyCombat", EVENT_PLAYER_COMBAT_STATE)
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_EnemyPolling")
        EVENT_MANAGER:UnregisterForUpdate(AKB.name .. "_EnemyValidation")
    end
    
    AKB.EnemyBars.HideEnemyBar()
end

-- Integration with existing UI hiding system
function AKB.EnemyBars.SetVisibility(visible)
    if not AKB.Settings.Get("showEnemyBars") then
        return
    end
    
    if not visible then
        AKB.EnemyBars.HideEnemyBar()
    elseif currentTarget then
        AKB.EnemyBars.ShowEnemyBar()
    end
end
