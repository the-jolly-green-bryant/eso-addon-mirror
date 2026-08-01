-- ============================================================================
-- AKsAttributeBars - Gridlines Module
-- ============================================================================
-- Provides alignment gridlines to help users position UI elements precisely

local AKB = AKsAttributeBars

-- Create Gridlines namespace
AKB.Gridlines = AKB.Gridlines or {}

-- Local variables
local gridContainer = nil
local gridLines = {}
local isVisible = false

-- Grid configuration for gamepad UI
local GRID_CONFIG = {
    baseMajorSpacing = 100,     -- Base major grid lines every 100 pixels (at 100% scale)
    baseMinorSpacing = 50,      -- Base minor grid lines every 50 pixels (at 100% scale)
    majorColor = {r = 1.0, g = 1.0, b = 1.0, a = 0.3},  -- White, 30% opacity
    minorColor = {r = 1.0, g = 1.0, b = 1.0, a = 0.15}, -- White, 15% opacity
    lineThickness = 1,          -- Line thickness in pixels
}

-- Get current UI scale factor
local function GetUIScale()
    -- ESO's GetUIGlobalScale() returns the current UI scale factor
    if GetUIGlobalScale then
        return GetUIGlobalScale()
    end
    -- Fallback to 1.0 (100% scale) if function not available
    return 1.0
end

-- Calculate scale-adjusted spacing
local function GetScaledSpacing()
    local scale = GetUIScale()
    return {
        majorSpacing = GRID_CONFIG.baseMajorSpacing * scale,
        minorSpacing = GRID_CONFIG.baseMinorSpacing * scale,
        scale = scale
    }
end

-- Initialize the gridlines system
function AKB.Gridlines.Initialize()
    if gridContainer then
        return
    end
    
    -- Register for UI scale change events if available
    if EVENT_MANAGER and EVENT_MANAGER.RegisterForEvent then
        EVENT_MANAGER:RegisterForEvent("AKB_Gridlines_ScaleChange", EVENT_INTERFACE_SETTING_CHANGED, function(eventCode, settingType, settingId)
            -- Check if this is a UI scale setting change
            if settingType == SETTING_TYPE_UI and settingId == UI_SETTING_CUSTOM_SCALE then
                AKB.Gridlines.OnUIScaleChange()
            end
        end)
    end
    
    local settings = AKB.Settings.GetAll()
    if settings and settings.showGridlines then
        AKB.Gridlines.CreateGridlines()
        AKB.Gridlines.Show()
    end
end

-- Create the gridlines UI elements
function AKB.Gridlines.CreateGridlines()
    if gridContainer or not WINDOW_MANAGER or not GuiRoot then
        return
    end
    
    local screenWidth = GuiRoot:GetWidth() or 1920
    local screenHeight = GuiRoot:GetHeight() or 1080
    local spacing = GetScaledSpacing()
    
    gridContainer = WINDOW_MANAGER:CreateTopLevelWindow("AKB_GridContainer")
    if not gridContainer then 
        return 
    end
    
    gridContainer:SetDimensions(screenWidth, screenHeight)
    gridContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    gridContainer:SetMouseEnabled(false)
    gridContainer:SetHidden(true)
    
    AKB.Gridlines.CreateVerticalLines(screenWidth, screenHeight, spacing)
    AKB.Gridlines.CreateHorizontalLines(screenWidth, screenHeight, spacing)
end

-- Create vertical grid lines
function AKB.Gridlines.CreateVerticalLines(screenWidth, screenHeight, spacing)
    local lineIndex = 1
    
    for x = 0, screenWidth, spacing.minorSpacing do
        local isMajorLine = (x % spacing.majorSpacing == 0)
        local color = isMajorLine and GRID_CONFIG.majorColor or GRID_CONFIG.minorColor
        
        local line = WINDOW_MANAGER:CreateControl("AKB_GridVertical_" .. lineIndex, gridContainer, CT_TEXTURE)
        if line then
            line:SetDimensions(GRID_CONFIG.lineThickness, screenHeight)
            line:SetAnchor(TOPLEFT, gridContainer, TOPLEFT, x, 0)
            line:SetColor(color.r, color.g, color.b, color.a)
            line:SetMouseEnabled(false)
            
            table.insert(gridLines, line)
            lineIndex = lineIndex + 1
        end
    end
end

-- Create horizontal grid lines
function AKB.Gridlines.CreateHorizontalLines(screenWidth, screenHeight, spacing)
    local lineIndex = 1000
    
    for y = 0, screenHeight, spacing.minorSpacing do
        local isMajorLine = (y % spacing.majorSpacing == 0)
        local color = isMajorLine and GRID_CONFIG.majorColor or GRID_CONFIG.minorColor
        
        local line = WINDOW_MANAGER:CreateControl("AKB_GridHorizontal_" .. lineIndex, gridContainer, CT_TEXTURE)
        if line then
            line:SetDimensions(screenWidth, GRID_CONFIG.lineThickness)
            line:SetAnchor(TOPLEFT, gridContainer, TOPLEFT, 0, y)
            line:SetColor(color.r, color.g, color.b, color.a)
            line:SetMouseEnabled(false)
            
            table.insert(gridLines, line)
            lineIndex = lineIndex + 1
        end
    end
end

-- Show the gridlines
function AKB.Gridlines.Show()
    if not gridContainer then
        AKB.Gridlines.CreateGridlines()
    end
    
    if gridContainer and gridContainer.SetHidden then
        gridContainer:SetHidden(false)
        isVisible = true
    end
end

-- Hide the gridlines
function AKB.Gridlines.Hide()
    if gridContainer and gridContainer.SetHidden then
        gridContainer:SetHidden(true)
        isVisible = false
    end
end

-- Toggle gridlines visibility
function AKB.Gridlines.Toggle()
    if isVisible then
        AKB.Gridlines.Hide()
    else
        AKB.Gridlines.Show()
    end
end

-- Destroy all gridlines (cleanup)
function AKB.Gridlines.Destroy()
    for _, line in ipairs(gridLines) do
        if line and line.Destroy then
            line:Destroy()
        end
    end
    gridLines = {}
    
    if gridContainer and gridContainer.Destroy then
        gridContainer:Destroy()
    end
    gridContainer = nil
    isVisible = false
end

-- Check if gridlines are currently visible
function AKB.Gridlines.IsVisible()
    return isVisible
end

-- Handle UI scale changes
function AKB.Gridlines.OnUIScaleChange()
    if gridContainer and isVisible then
        AKB.Gridlines.Destroy()
        AKB.Gridlines.CreateGridlines()
        AKB.Gridlines.Show()
    end
end

-- Handle screen resolution changes (for console docking/undocking)
function AKB.Gridlines.OnResolutionChange()
    if gridContainer then
        AKB.Gridlines.Destroy()
        if isVisible then
            AKB.Gridlines.CreateGridlines()
            AKB.Gridlines.Show()
        end
    end
end

-- Get current grid information for debugging
function AKB.Gridlines.GetGridInfo()
    local spacing = GetScaledSpacing()
    return {
        scale = spacing.scale,
        majorSpacing = spacing.majorSpacing,
        minorSpacing = spacing.minorSpacing,
        isVisible = isVisible,
        lineCount = #gridLines
    }
end
