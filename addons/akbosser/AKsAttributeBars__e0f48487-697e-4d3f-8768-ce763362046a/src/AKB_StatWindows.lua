-- ============================================================================
-- AKsAttributeBars - Stat Windows Module  
-- ============================================================================
-- Handles creation and management of configurable stat display windows

local AKB = AKsAttributeBars

-- Create StatWindows namespace
AKB.UI = AKB.UI or {}
AKB.UI.StatWindows = AKB.UI.StatWindows or {}

-- Console-safe draw constants
local DT_LOW = 1
local DT_MEDIUM = 2  
local DT_HIGH = 3
local DL_BACKGROUND = DL_BACKGROUND or 1
local DL_OVERLAY = DL_OVERLAY or 6

-- ESO Stat constants mapping to our stat types
local ESO_STAT_MAP = {
    [AKB.Settings.STAT_TYPES.PHYSICAL_RESISTANCE] = STAT_PHYSICAL_RESIST,
    [AKB.Settings.STAT_TYPES.SPELL_RESISTANCE] = STAT_SPELL_RESIST,
    [AKB.Settings.STAT_TYPES.WEAPON_DAMAGE] = STAT_POWER,
    [AKB.Settings.STAT_TYPES.SPELL_DAMAGE] = STAT_SPELL_POWER,
    [AKB.Settings.STAT_TYPES.PHYSICAL_PENETRATION] = STAT_PHYSICAL_PENETRATION,
    [AKB.Settings.STAT_TYPES.SPELL_PENETRATION] = STAT_SPELL_PENETRATION,
    [AKB.Settings.STAT_TYPES.CRITICAL_CHANCE] = STAT_CRITICAL_STRIKE,
    [AKB.Settings.STAT_TYPES.CRITICAL_RESIST] = STAT_CRITICAL_RESISTANCE,
    [AKB.Settings.STAT_TYPES.CRITICAL_DAMAGE] = nil -- Will use GetCriticalDamageBonus()
}

-- Active stat windows storage
local activeWindows = {}

-- Performance optimization: Update throttling
local lastUpdateTime = 0
local UPDATE_THROTTLE_MS = 50 -- Limit updates to 20fps max for console performance
local pendingUpdate = false

-- Performance optimization: Batch updates
local function ScheduleStatUpdate()
    if pendingUpdate then return end
    
    local currentTime = GetGameTimeMilliseconds()
    if currentTime - lastUpdateTime < UPDATE_THROTTLE_MS then
        -- Schedule delayed update
        pendingUpdate = true
        zo_callLater(function()
            lastUpdateTime = GetGameTimeMilliseconds()
            pendingUpdate = false
            AKB.UI.StatWindows.UpdateAllWindows()
        end, UPDATE_THROTTLE_MS - (currentTime - lastUpdateTime))
    else
        -- Update immediately
        lastUpdateTime = currentTime
        AKB.UI.StatWindows.UpdateAllWindows()
    end
end

-- Public function for event integration - use smart throttling
function AKB.UI.StatWindows.RequestUpdate()
    ScheduleStatUpdate()
end

-- Performance optimization: Object pooling for console memory efficiency
local objectPool = {
    textColors = {
        white = {r = 1, g = 1, b = 1, a = 1}
    }
}

-- Get cached color object to avoid repeated table creation
local function GetTextColor()
    return objectPool.textColors.white
end

-- Get stat value from ESO API
local function GetStatValue(statType)
    if not statType or statType == AKB.Settings.STAT_TYPES.NONE then
        return 0
    end
    
    -- Handle critical damage separately (no direct ESO stat)
    if statType == AKB.Settings.STAT_TYPES.CRITICAL_DAMAGE then
        if GetCriticalDamageBonus then
            local critDamageBonus = GetCriticalDamageBonus() or 0
            -- Convert to percentage and round to 1 decimal
            return math.floor(critDamageBonus * 1000) / 10 -- Convert from decimal to percentage
        else
            -- Fallback calculation if API not available
            return 50.0 -- Default critical damage bonus in ESO
        end
    end
    
    -- Handle critical chance conversion (ESO rating to percentage)
    if statType == AKB.Settings.STAT_TYPES.CRITICAL_CHANCE then
        local esoStatId = ESO_STAT_MAP[statType]
        if esoStatId and GetPlayerStat then
            local critRating = GetPlayerStat(esoStatId, STAT_BONUS_OPTION_APPLY_BONUS) or 0
            
            -- Use ESO's GetCriticalStrikeChance API if available (most accurate)
            if GetCriticalStrikeChance then
                local critChance = GetCriticalStrikeChance(critRating) -- Already returns percentage
                return math.floor(critChance * 10) / 10 -- Round to 1 decimal place
            end
            
            -- Fallback: Current ESO formula (rating / 219) based on community research
            -- This is the standard conversion used by most ESO addons
            local critPercentage = critRating / 219
            return math.floor(critPercentage * 10) / 10 -- Round to 1 decimal place
        end
        return 0
    end
    
    -- Standard stat lookup
    local esoStatId = ESO_STAT_MAP[statType]
    if esoStatId and GetPlayerStat then
        return GetPlayerStat(esoStatId, STAT_BONUS_OPTION_APPLY_BONUS) or 0
    end
    
    return 0
end

-- Calculate dynamic window dimensions based on content
local function CalculateWindowSize(stat1Type, stat2Type)
    local hasSecondStat = stat2Type and stat2Type ~= AKB.Settings.STAT_TYPES.NONE
    
    -- Narrower but taller dimensions to prevent text clipping
    local baseWidth = 180  -- Narrower width for compact appearance
    local baseHeight = 56  -- Increased height to prevent clipping
    
    -- Adjust for content
    if hasSecondStat then
        -- Two stats side by side - moderate width increase
        return baseWidth + 50, baseHeight + 6  -- Narrow dual layout with more height
    else
        -- Single stat centered - narrow and tall
        return baseWidth, baseHeight
    end
end

-- Create text labels for a stat window
local function CreateStatLabels(parentWindow, windowWidth, windowHeight, stat1Type, stat2Type)
    local hasSecondStat = stat2Type and stat2Type ~= AKB.Settings.STAT_TYPES.NONE
    local labels = {}
    
    -- Create stat 1 label and value
    local stat1Label = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, parentWindow, CT_LABEL)
    local stat1Value = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, parentWindow, CT_LABEL)
    
    if stat1Label and stat1Value then
        local labelFontSize = 12  -- Very small font for labels
        local valueFontSize = 28  -- Even larger font for numbers
        local labelFontString = string.format("$(BOLD_FONT)|%d|thick-outline", labelFontSize)
        local valueFontString = string.format("$(BOLD_FONT)|%d|thick-outline", valueFontSize)
        
        -- Position and configure stat 1 with better vertical spacing
        if hasSecondStat then
            -- Two stats: left side with increased inward margins
            stat1Label:SetAnchor(TOPLEFT, parentWindow, TOPLEFT, 10, 6)
            stat1Label:SetDimensions(windowWidth / 2 - 14, 16)  -- Slightly taller label
            stat1Value:SetAnchor(TOPLEFT, parentWindow, TOPLEFT, 10, 24)  -- More vertical space
            stat1Value:SetDimensions(windowWidth / 2 - 14, 26)  -- Larger height for big font
            stat1Label:SetHorizontalAlignment(TEXT_ALIGN_LEFT or 0)
            stat1Value:SetHorizontalAlignment(TEXT_ALIGN_LEFT or 0)
        else
            -- Single stat: center with taller layout
            stat1Label:SetAnchor(TOP, parentWindow, TOP, 0, 6)
            stat1Label:SetDimensions(windowWidth - 12, 16)  -- Slightly taller label
            stat1Value:SetAnchor(TOP, parentWindow, TOP, 0, 20)  -- Raised number (was 24)
            stat1Value:SetDimensions(windowWidth - 12, 26)  -- Larger height for big font
            stat1Label:SetHorizontalAlignment(TEXT_ALIGN_CENTER or 1)
            stat1Value:SetHorizontalAlignment(TEXT_ALIGN_CENTER or 1)
        end
        
        stat1Label:SetFont(labelFontString)
        stat1Value:SetFont(valueFontString)
        stat1Label:SetText(AKB.Settings.GetStatLabel(stat1Type))
        
        -- Apply proper text color (matching attribute bars approach)
        local settings = AKB.Settings.GetAll()
        local textColor = settings.textColor or {r = 1, g = 1, b = 1}
        stat1Label:SetColor(textColor.r, textColor.g, textColor.b, 1)
        stat1Value:SetColor(textColor.r, textColor.g, textColor.b, 1)
        
        -- Set explicit draw order to ensure text appears above background
        -- Text needs to be on a higher layer than DL_BACKGROUND (which backgrounds use)
        if stat1Label.SetDrawTier then stat1Label:SetDrawTier(DT_MEDIUM) end
        if stat1Label.SetDrawLayer then stat1Label:SetDrawLayer(DL_TEXT) end
        if stat1Label.SetDrawLevel then stat1Label:SetDrawLevel(1) end
        
        if stat1Value.SetDrawTier then stat1Value:SetDrawTier(DT_MEDIUM) end
        if stat1Value.SetDrawLayer then stat1Value:SetDrawLayer(DL_TEXT) end
        if stat1Value.SetDrawLevel then stat1Value:SetDrawLevel(1) end
        
        stat1Label:SetMouseEnabled(false)
        stat1Value:SetMouseEnabled(false)
        stat1Label:SetHidden(false)
        stat1Value:SetHidden(false)
        
        labels.stat1Label = stat1Label
        labels.stat1Value = stat1Value
    end
    
    -- Create stat 2 if needed
    if hasSecondStat then
        local stat2Label = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, parentWindow, CT_LABEL)
        local stat2Value = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, parentWindow, CT_LABEL)
        
        if stat2Label and stat2Value then
            local labelFontSize = 12  -- Very small font for labels
            local valueFontSize = 28  -- Even larger font for numbers
            local labelFontString = string.format("$(BOLD_FONT)|%d|thick-outline", labelFontSize)
            local valueFontString = string.format("$(BOLD_FONT)|%d|thick-outline", valueFontSize)
            
            -- Position on right side with increased inward margins
            stat2Label:SetAnchor(TOPRIGHT, parentWindow, TOPRIGHT, -10, 6)
            stat2Label:SetDimensions(windowWidth / 2 - 14, 16)  -- Slightly taller label
            stat2Value:SetAnchor(TOPRIGHT, parentWindow, TOPRIGHT, -10, 24)  -- More vertical space
            stat2Value:SetDimensions(windowWidth / 2 - 14, 26)  -- Larger height for big font
            stat2Label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT or 2)
            stat2Value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT or 2)
            
            stat2Label:SetFont(labelFontString)
            stat2Value:SetFont(valueFontString)
            stat2Label:SetText(AKB.Settings.GetStatLabel(stat2Type))
            
            -- Apply proper text color (matching attribute bars approach)
            local settings = AKB.Settings.GetAll()
            local textColor = settings.textColor or {r = 1, g = 1, b = 1}
            stat2Label:SetColor(textColor.r, textColor.g, textColor.b, 1)
            stat2Value:SetColor(textColor.r, textColor.g, textColor.b, 1)
            
            -- Set explicit draw order to ensure text appears above background
            -- Text needs to be on a higher layer than DL_BACKGROUND (which backgrounds use)
            if stat2Label.SetDrawTier then stat2Label:SetDrawTier(DT_MEDIUM) end
            if stat2Label.SetDrawLayer then stat2Label:SetDrawLayer(DL_TEXT) end
            if stat2Label.SetDrawLevel then stat2Label:SetDrawLevel(1) end
            
            if stat2Value.SetDrawTier then stat2Value:SetDrawTier(DT_MEDIUM) end
            if stat2Value.SetDrawLayer then stat2Value:SetDrawLayer(DL_TEXT) end
            if stat2Value.SetDrawLevel then stat2Value:SetDrawLevel(1) end
            
            stat2Label:SetMouseEnabled(false)
            stat2Value:SetMouseEnabled(false)
            stat2Label:SetHidden(false)
            stat2Value:SetHidden(false)
            
            labels.stat2Label = stat2Label
            labels.stat2Value = stat2Value
        end
    end
    
    return labels
end

-- Create a configurable stat window
local function CreateStatWindow(windowId, config)
    if not config or not config.enabled then
        return nil
    end
    
    local windowName = "AKB_StatWindow" .. windowId
    local uniqueName = AKB.Utils.GenerateUniqueName(windowName)
    
    -- Create main window
    local statWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(uniqueName)
    if not statWindow then
        return nil
    end
    
    -- Calculate dimensions based on content
    local windowWidth, windowHeight = CalculateWindowSize(config.stat1, config.stat2)
    
    -- Position window
    local settings = AKB.Settings.GetAll()
    local xPos = settings.customBarsXPosition + config.xPosition
    local yPos = settings.customBarsYPosition + config.yPosition
    
    statWindow:SetDimensions(windowWidth, windowHeight)
    statWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, xPos, yPos)
    statWindow:SetClampedToScreen(true)
    statWindow:SetMouseEnabled(false)
    statWindow:SetMovable(false)
    statWindow:SetHidden(false)
    
    -- Create enhanced background with proper styling (matching attribute bars)
    local windowBackground = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, statWindow, CT_TEXTURE)
    local borders = {}
    
    if windowBackground then
        -- Main background with proper positioning
        windowBackground:SetAnchor(TOPLEFT, statWindow, TOPLEFT, 4, 4)
        windowBackground:SetDimensions(windowWidth - 8, windowHeight - 8)
        windowBackground:SetColor(0, 0, 0, 0.5)
        
        -- Add subtle gradient for 3D depth (matching attribute bars)
        if windowBackground.SetGradientColors then
            windowBackground:SetGradientColors(2, 
                0.0, 0.0, 0.0, 0.6,  -- Top (darker)
                0.1, 0.1, 0.1, 0.4   -- Bottom (slightly lighter)
            )
        end
        
        -- Set proper draw order (background layer, level 1)
        if windowBackground.SetDrawTier then windowBackground:SetDrawTier(DT_LOW) end
        if windowBackground.SetDrawLayer then windowBackground:SetDrawLayer(DL_BACKGROUND) end
        if windowBackground.SetDrawLevel then windowBackground:SetDrawLevel(1) end
        windowBackground:SetHidden(false)
        
        -- Create complete border system with improved positioning
        local borderColor = {r = 0.8, g = 0.8, b = 0.8, a = 1.0}  -- Brighter, more visible borders
        local borderThickness = 2  -- Slightly thicker for better visibility
        
        -- Calculate border dimensions
        local bgWidth = windowWidth - 8
        local bgHeight = windowHeight - 8
        
        -- Top border - spans full width including corners
        local topBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, statWindow, CT_TEXTURE)
        if topBorder then
            topBorder:SetAnchor(TOPLEFT, statWindow, TOPLEFT, 2, 2)  -- Align with window edge
            topBorder:SetDimensions(bgWidth + 4, borderThickness)
            topBorder:SetTexture("")
            topBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            if topBorder.SetDrawTier then topBorder:SetDrawTier(DT_LOW) end
            if topBorder.SetDrawLayer then topBorder:SetDrawLayer(DL_BACKGROUND) end
            if topBorder.SetDrawLevel then topBorder:SetDrawLevel(3) end
            topBorder:SetHidden(false)
            borders.top = topBorder
        end
        
        -- Bottom border - spans full width including corners
        local bottomBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, statWindow, CT_TEXTURE)
        if bottomBorder then
            bottomBorder:SetAnchor(TOPLEFT, statWindow, TOPLEFT, 2, windowHeight - 4)
            bottomBorder:SetDimensions(bgWidth + 4, borderThickness)
            bottomBorder:SetTexture("")
            bottomBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            if bottomBorder.SetDrawTier then bottomBorder:SetDrawTier(DT_LOW) end
            if bottomBorder.SetDrawLayer then bottomBorder:SetDrawLayer(DL_BACKGROUND) end
            if bottomBorder.SetDrawLevel then bottomBorder:SetDrawLevel(3) end
            bottomBorder:SetHidden(false)
            borders.bottom = bottomBorder
        end
        
        -- Left border - spans full height excluding corners (to avoid overlap)
        local leftBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, statWindow, CT_TEXTURE)
        if leftBorder then
            leftBorder:SetAnchor(TOPLEFT, statWindow, TOPLEFT, 2, 4)  -- Start below top border
            leftBorder:SetDimensions(borderThickness, bgHeight)
            leftBorder:SetTexture("")
            leftBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            if leftBorder.SetDrawTier then leftBorder:SetDrawTier(DT_LOW) end
            if leftBorder.SetDrawLayer then leftBorder:SetDrawLayer(DL_BACKGROUND) end
            if leftBorder.SetDrawLevel then leftBorder:SetDrawLevel(3) end
            leftBorder:SetHidden(false)
            borders.left = leftBorder
        end
        
        -- Right border - spans full height excluding corners (to avoid overlap)
        local rightBorder = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, statWindow, CT_TEXTURE)
        if rightBorder then
            rightBorder:SetAnchor(TOPLEFT, statWindow, TOPLEFT, windowWidth - 4, 4)  -- Start below top border
            rightBorder:SetDimensions(borderThickness, bgHeight)
            rightBorder:SetTexture("")
            rightBorder:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            if rightBorder.SetDrawTier then rightBorder:SetDrawTier(DT_LOW) end
            if rightBorder.SetDrawLayer then rightBorder:SetDrawLayer(DL_BACKGROUND) end
            if rightBorder.SetDrawLevel then rightBorder:SetDrawLevel(3) end
            rightBorder:SetHidden(false)
            borders.right = rightBorder
        end
    end
    
    -- Create text labels
    local labels = CreateStatLabels(statWindow, windowWidth, windowHeight, config.stat1, config.stat2)
    
    -- Create and return stat window object
    local statWindowObj = {
        id = windowId,
        window = statWindow,
        background = windowBackground,
        borders = borders,
        labels = labels,
        config = config,
        
        -- Performance: Cache last values to prevent unnecessary UI updates
        cachedValues = {
            stat1 = nil,
            stat2 = nil
        },
        
        -- Update method (optimized with value caching)
        Update = function(self)
            if not self.labels then return end
            
            -- Use pooled color object for performance
            local textColor = GetTextColor()
            
            -- Update stat 1 (with caching)
            if self.labels.stat1Value then
                local value = GetStatValue(self.config.stat1)
                if value ~= self.cachedValues.stat1 then
                    local formattedValue = AKB.Utils.FormatNumberByType(value, 1) -- Use full number format
                    -- Add percentage symbol for critical chance
                    if self.config.stat1 == AKB.Settings.STAT_TYPES.CRITICAL_CHANCE then
                        formattedValue = formattedValue .. "%"
                    end
                    self.labels.stat1Value:SetText(formattedValue)
                    self.labels.stat1Value:SetColor(textColor.r, textColor.g, textColor.b, 1)
                    self.cachedValues.stat1 = value
                end
            end
            
            if self.labels.stat1Label then
                self.labels.stat1Label:SetColor(textColor.r, textColor.g, textColor.b, 1)
            end
            
            -- Update stat 2 if it exists (with caching)
            if self.labels.stat2Value and self.config.stat2 and self.config.stat2 ~= AKB.Settings.STAT_TYPES.NONE then
                local value = GetStatValue(self.config.stat2)
                if value ~= self.cachedValues.stat2 then
                    local formattedValue = AKB.Utils.FormatNumberByType(value, 1) -- Use full number format
                    -- Add percentage symbol for critical chance
                    if self.config.stat2 == AKB.Settings.STAT_TYPES.CRITICAL_CHANCE then
                        formattedValue = formattedValue .. "%"
                    end
                    self.labels.stat2Value:SetText(formattedValue)
                    self.labels.stat2Value:SetColor(textColor.r, textColor.g, textColor.b, 1)
                    self.cachedValues.stat2 = value
                end
            end
            
            if self.labels.stat2Label then
                self.labels.stat2Label:SetColor(textColor.r, textColor.g, textColor.b, 1)
            end
        end,
        
        -- Show method
        Show = function(self)
            if self.window and self.window.SetHidden then
                self.window:SetHidden(false)
            end
        end,
        
        -- Hide method
        Hide = function(self)
            if self.window and self.window.SetHidden then
                self.window:SetHidden(true)
            end
        end,
        
        -- Destroy method
        Destroy = function(self)
            -- Clean up labels
            if self.labels then
                for _, label in pairs(self.labels) do
                    if label and label.SetHidden then
                        label:SetHidden(true)
                        if label.ClearAnchors then label:ClearAnchors() end
                        if label.SetParent then label:SetParent(nil) end
                    end
                end
            end
            
            -- Clean up background
            if self.background then
                self.background:SetHidden(true)
                if self.background.ClearAnchors then self.background:ClearAnchors() end
                if self.background.SetParent then self.background:SetParent(nil) end
            end
            
            -- Clean up borders
            if self.borders then
                for _, border in pairs(self.borders) do
                    if border and border.SetHidden then
                        border:SetHidden(true)
                        if border.ClearAnchors then border:ClearAnchors() end
                        if border.SetParent then border:SetParent(nil) end
                    end
                end
            end
            
            -- Clean up main window
            if self.window then
                self.window:SetHidden(true)
                if self.window.ClearAnchors then self.window:ClearAnchors() end
                if self.window.SetParent then self.window:SetParent(nil) end
            end
        end
    }
    
    return statWindowObj
end

-- Public API functions

-- Create all enabled stat windows
function AKB.UI.StatWindows.CreateAllWindows()
    AKB.UI.StatWindows.DestroyAllWindows() -- Clean up first
    
    -- Create each of the 3 configurable windows
    local hasActiveWindows = false
    for i = 1, 3 do
        local config = AKB.Settings.GetStatWindowConfig(i)
        if config and config.enabled then
            local window = CreateStatWindow(i, config)
            if window then
                activeWindows[i] = window
                window:Update() -- Initial update
                hasActiveWindows = true
            end
        end
    end
    
    -- Start stat polling if we have active windows
    if hasActiveWindows and AKB.Events and AKB.Events.StartStatPolling then
        AKB.Events.StartStatPolling()
    end
    
    -- Ensure UI state monitoring is active for gamepad menu detection
    if hasActiveWindows and AKB.Events and AKB.Events.RegisterUIStateEvents then
        -- This will set up proper menu/UI detection for hiding stat windows
        AKB.Events.RegisterUIStateEvents()
    end
end

-- Throttling variables
local lastUpdateTime = 0
local UPDATE_THROTTLE_MS = 50 -- Update at most every 50ms for better responsiveness

-- Update all active stat windows (with throttling)
function AKB.UI.StatWindows.UpdateAllWindows()
    local currentTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if currentTime - lastUpdateTime < UPDATE_THROTTLE_MS then
        return -- Skip update if called too frequently
    end
    lastUpdateTime = currentTime
    
    for _, window in pairs(activeWindows) do
        if window and window.Update then
            window:Update()
        end
    end
end

-- Force update all active stat windows (bypass throttling for weapon swaps)
function AKB.UI.StatWindows.ForceUpdateAllWindows()
    -- Skip throttling - force immediate update for critical events like weapon swaps
    for _, window in pairs(activeWindows) do
        if window and window.Update then
            window:Update()
        end
    end
    
    -- Update the throttle timestamp to prevent rapid successive calls
    lastUpdateTime = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

-- Show all stat windows (respects individual enabled settings)
function AKB.UI.StatWindows.ShowAllWindows()
    -- Check if we need to create windows that should exist but don't
    local needsCreation = false
    for i = 1, 3 do
        local windowConfig = AKB.Settings.GetStatWindowConfig(i)
        if windowConfig and windowConfig.enabled and not activeWindows[i] then
            needsCreation = true
            break
        end
    end
    
    -- Create windows if needed
    if needsCreation then
        AKB.UI.StatWindows.CreateAllWindows()
    end
    
    -- Show enabled windows, with gamepad UI safety checks
    for i = 1, 3 do
        local window = activeWindows[i]
        local windowConfig = AKB.Settings.GetStatWindowConfig(i)
        
        -- Only show window if it exists, has Show method, and is enabled in settings
        if window and window.Show and windowConfig and windowConfig.enabled then
            -- Additional safety check: ensure window is not hidden by gamepad UI state
            local canShow = true
            if AKB.Events and AKB.Events.IsAnyMenuOpen then
                local status, menuOpen = pcall(AKB.Events.IsAnyMenuOpen)
                if status and menuOpen then
                    canShow = false
                end
            end
            
            if canShow then
                window:Show()
            end
        end
    end
end

-- Hide all stat windows
function AKB.UI.StatWindows.HideAllWindows()
    for _, window in pairs(activeWindows) do
        if window and window.Hide then
            window:Hide()
        end
    end
end

-- Update visibility for all stat windows based on current UI state and settings
function AKB.UI.StatWindows.UpdateVisibility()
    -- Check if any major UI is open that should hide stat windows
    -- Enhanced for gamepad UI compatibility
    local shouldHide = false
    
    if AKB.Events and AKB.Events.IsAnyMenuOpen then
        local status, menuOpen = pcall(AKB.Events.IsAnyMenuOpen)
        if status then
            shouldHide = menuOpen
        end
    end
    
    -- Additional gamepad-specific checks for console compatibility
    if not shouldHide and IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        -- Check for gamepad-specific UI states that should hide stat windows
        if IsReticleHidden and IsReticleHidden() then
            shouldHide = true
        end
    end
    
    if shouldHide then
        AKB.UI.StatWindows.HideAllWindows()
    else
        AKB.UI.StatWindows.ShowAllWindows()
    end
end

-- Destroy all stat windows
function AKB.UI.StatWindows.DestroyAllWindows()
    for _, window in pairs(activeWindows) do
        if window and window.Destroy then
            window:Destroy()
        end
    end
    activeWindows = {}
    
    -- Stop stat polling when no windows are active
    if AKB.Events and AKB.Events.StopStatPolling then
        AKB.Events.StopStatPolling()
    end
end

-- Get active windows (for debugging/inspection)
function AKB.UI.StatWindows.GetActiveWindows()
    return activeWindows
end
