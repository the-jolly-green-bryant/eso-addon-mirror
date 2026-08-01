-- Copyright (c) 2026 Toriga (https://github.com/Master-Antonio)
-- All rights reserved.
-- TorigaHUD: A modern, minimalist, combat HUD inspired by Horizon Zero Dawn.
-- Features independent, draggable resource frames with segmented bars and clean high-contrast borders.

TorigaHUD = {}
TorigaHUD.name = "TorigaHUD"

-- Default configurations
TorigaHUD.defaults = {
    healthPosX = 100,
    healthPosY = 50,
    xpPosX = 100,
    xpPosY = 95,
    magickaPosX = 100,
    magickaPosY = 130,
    staminaPosX = 100,
    staminaPosY = 170,
    targetPosX = 0,
    targetPosY = 100,
    hideOutOfCombat = false,
    showShields = true,
    lerpSpeed = 0.25,
    unlockHUD = false,
    segmentSize = 2000,
    hudScale = 1.0,
    layoutPreset = "Default",
}

-- Current state tracking
TorigaHUD.player = {
    health = { cur = 0, max = 0, vis = 0, maxCached = 0 },
    magicka = { cur = 0, max = 0, vis = 0, maxCached = 0 },
    stamina = { cur = 0, max = 0, vis = 0, maxCached = 0 },
    shield = { cur = 0, vis = 0 }
}

TorigaHUD.target = {
    health = { cur = 0, max = 0, vis = 0, maxCached = 0 },
    exists = false,
    name = "",
    level = 0
}

-- Format numbers cleanly (e.g., 24500 -> 24.5k)
local function FormatNumber(value)
    if value >= 1000000 then
        return string.format("%.2fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fk", value / 1000)
    else
        return tostring(value)
    end
end

-- Smoothly interpolate visual values
local function Lerp(startVal, endVal, speed)
    if math.abs(startVal - endVal) < 1 then
        return endVal
    end
    return startVal + (endVal - startVal) * speed
end

-- Hides the default ESO resource frames
local function HideDefaultHUD()
    local frames = {
        ZO_PlayerAttributeHealth,
        ZO_PlayerAttributeMagicka,
        ZO_PlayerAttributeStamina,
        ZO_TargetUnitFrame
    }
    for _, frame in ipairs(frames) do
        if frame then
            frame:SetHidden(true)
            frame:SetAlpha(0)
            frame.SetHidden = function() end
        end
    end
end

-- Get player's active shield value
local function GetPlayerShieldValue()
    local value, maxValue = GetUnitAttributeVisualizerEffectInfo(
        "player", 
        ATTRIBUTE_VISUAL_POWER_SHIELDING, 
        STAT_MITIGATION, 
        ATTRIBUTE_HEALTH, 
        POWERTYPE_HEALTH
    )
    return value or 0
end

-- Get player's level or champion points
local function GetPlayerLevelString()
    local level = GetUnitLevel("player")
    if level >= 50 then
        return tostring(GetPlayerChampionPointsEarned())
    else
        return tostring(level)
    end
end

-- Get player's XP progress percentage
local function GetPlayerXPPercentage()
    local level = GetUnitLevel("player")
    if level >= 50 then
        local currentCP = GetPlayerChampionPointsEarned()
        local currentXP = GetCurrentChampionXP()
        local threshold = GetChampionXPThreshold(currentCP)
        if threshold and threshold > 0 then
            return currentXP / threshold
        else
            return 0
        end
    else
        local earned = GetUnitXP("player")
        local maxXP = GetUnitXPMax("player")
        if maxXP > 0 then
            return earned / maxXP
        else
            return 0
        end
    end
end

-- Apply the global scale to all frames
local function ApplyHUDScale()
    local scale = TorigaHUD.db.hudScale or 1.0
    local frames = {
        TorigaHUD.healthFrame,
        TorigaHUD.xpFrame,
        TorigaHUD.magickaFrame,
        TorigaHUD.staminaFrame,
        TorigaHUD.targetFrame
    }
    for _, f in ipairs(frames) do
        if f then
            f:SetScale(scale)
        end
    end
end

-- Force reset of cached max values so segments are redrawn
local function ResetCachedMaxValues()
    TorigaHUD.player.health.maxCached = 0
    TorigaHUD.player.magicka.maxCached = 0
    TorigaHUD.player.stamina.maxCached = 0
    TorigaHUD.target.health.maxCached = 0
end

-- Apply predefined layout presets
local function ApplyPreset(presetName)
    local w, h = GuiRoot:GetDimensions()
    
    if presetName == "Default" then
        TorigaHUD.db.healthPosX = 100
        TorigaHUD.db.healthPosY = 50
        TorigaHUD.db.xpPosX = 100
        TorigaHUD.db.xpPosY = 95
        TorigaHUD.db.magickaPosX = 100
        TorigaHUD.db.magickaPosY = 130
        TorigaHUD.db.staminaPosX = 100
        TorigaHUD.db.staminaPosY = 170
        TorigaHUD.db.targetPosX = 0
        TorigaHUD.db.targetPosY = 100
        TorigaHUD.db.hudScale = 1.0
        TorigaHUD.db.segmentSize = 2000
    elseif presetName == "Focus Combat (Verticale)" then
        TorigaHUD.db.healthPosX = (w / 2) - 125
        TorigaHUD.db.healthPosY = h - 220
        TorigaHUD.db.xpPosX = (w / 2) - 125
        TorigaHUD.db.xpPosY = h - 180
        TorigaHUD.db.magickaPosX = (w / 2) - 125
        TorigaHUD.db.magickaPosY = h - 150
        TorigaHUD.db.staminaPosX = (w / 2) - 125
        TorigaHUD.db.staminaPosY = h - 110
        TorigaHUD.db.targetPosX = 0
        TorigaHUD.db.targetPosY = 150
        TorigaHUD.db.hudScale = 1.0
        TorigaHUD.db.segmentSize = 2000
    elseif presetName == "Focus Combat (Orizzontale)" then
        TorigaHUD.db.healthPosX = (w / 2) - 125
        TorigaHUD.db.healthPosY = h - 160
        TorigaHUD.db.xpPosX = (w / 2) - 125
        TorigaHUD.db.xpPosY = h - 120
        TorigaHUD.db.magickaPosX = (w / 2) - 125 - 15 - 250
        TorigaHUD.db.magickaPosY = h - 160
        TorigaHUD.db.staminaPosX = (w / 2) + 125 + 15
        TorigaHUD.db.staminaPosY = h - 160
        TorigaHUD.db.targetPosX = 0
        TorigaHUD.db.targetPosY = 150
        TorigaHUD.db.hudScale = 1.0
        TorigaHUD.db.segmentSize = 2000
    elseif presetName == "Minimalist (Compatto)" then
        TorigaHUD.db.healthPosX = 40
        TorigaHUD.db.healthPosY = 35
        TorigaHUD.db.xpPosX = 40
        TorigaHUD.db.xpPosY = 70
        TorigaHUD.db.magickaPosX = 40
        TorigaHUD.db.magickaPosY = 95
        TorigaHUD.db.staminaPosX = 40
        TorigaHUD.db.staminaPosY = 125
        TorigaHUD.db.targetPosX = 0
        TorigaHUD.db.targetPosY = 80
        TorigaHUD.db.hudScale = 0.85
        TorigaHUD.db.segmentSize = 5000
    end
    
    -- Re-anchor controls
    if TorigaHUD.healthFrame then
        TorigaHUD.healthFrame:ClearAnchors()
        TorigaHUD.healthFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.healthPosX, TorigaHUD.db.healthPosY)
    end
    if TorigaHUD.xpFrame then
        TorigaHUD.xpFrame:ClearAnchors()
        TorigaHUD.xpFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.xpPosX, TorigaHUD.db.xpPosY)
    end
    if TorigaHUD.magickaFrame then
        TorigaHUD.magickaFrame:ClearAnchors()
        TorigaHUD.magickaFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.magickaPosX, TorigaHUD.db.magickaPosY)
    end
    if TorigaHUD.staminaFrame then
        TorigaHUD.staminaFrame:ClearAnchors()
        TorigaHUD.staminaFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.staminaPosX, TorigaHUD.db.staminaPosY)
    end
    if TorigaHUD.targetFrame then
         TorigaHUD.targetFrame:ClearAnchors()
         TorigaHUD.targetFrame:SetAnchor(TOP, GuiRoot, TOP, TorigaHUD.db.targetPosX, TorigaHUD.db.targetPosY)
    end
    
    -- Apply scale & force rebuild segments
    ApplyHUDScale()
    ResetCachedMaxValues()
end

-- Helper to create a segmented bar with a clean outline
local function CreateHUDBar(name, parent, width, height, showBorder)
    local wm = GetWindowManager()
    
    -- Container
    local container = wm:CreateControl(name .. "_Container", parent, CT_CONTROL)
    container:SetDimensions(width, height)
    container:SetHidden(false)
    
    -- Backdrop (outer border outline only, center is transparent so gaps see through)
    local bg = wm:CreateControl(name .. "_BG", container, CT_BACKDROP)
    bg:ClearAnchors()
    bg:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
    bg:SetCenterColor(0, 0, 0, 0) -- Completely transparent center
    
    if showBorder then
        bg:SetEdgeColor(1, 1, 1, 0.7) -- Clean solid white outline border
        bg:SetEdgeTexture("", 2, 1, 1) -- Sharp corners (2px edge size, 1px thickness)
    else
        bg:SetEdgeColor(0, 0, 0, 0)
        bg:SetEdgeTexture("", 2, 1, 0) -- No border
    end
    bg:SetHidden(false)
    
    container.bg = bg
    container.width = width
    container.height = height
    container.name = name
    container.segments = {}
    
    return container
end

-- Update the segments of a HUD bar dynamically
local function UpdateHUDBarSegments(barContainer, maxPower, barColor, trackColor, numSegmentsOverride)
    if not barContainer then return end
    
    local numSegments
    if numSegmentsOverride then
        numSegments = numSegmentsOverride
    else
        local segmentSize = TorigaHUD.db.segmentSize or 2000
        numSegments = math.ceil(maxPower / segmentSize)
    end
    numSegments = math.max(1, math.min(numSegments, 40))
    
    local name = barContainer.name
    local bg = barContainer.bg
    local width = barContainer.width
    local height = barContainer.height
    local segments = barContainer.segments or {}
    barContainer.segments = segments
    
    local gap = 2
    
    -- Dynamic padding based on bar height (prevents height 0 bugs on thin bars like XP bar)
    local padding = math.max(0, math.floor(height / 4) - 1)
    
    local availableWidth = width - (padding * 2)
    local totalGaps = (numSegments - 1) * gap
    local segmentWidth = (availableWidth - totalGaps) / numSegments
    
    local wm = GetWindowManager()
    
    for i = 1, numSegments do
        local seg = segments[i]
        if not seg then
            -- Segment background track (shows if segment is empty)
            local segBg = wm:CreateControl(name .. "_SegBG_" .. i, bg, CT_TEXTURE)
            segBg:SetColor(trackColor[1], trackColor[2], trackColor[3], trackColor[4] or 0.35)
            
            -- Segment fill texture
            local segFill = wm:CreateControl(name .. "_SegFill_" .. i, segBg, CT_TEXTURE)
            segFill:SetColor(barColor[1], barColor[2], barColor[3], barColor[4] or 0.9)
            
            local segShield
            if name == "TorigaHUD_Health" then
                segShield = wm:CreateControl(name .. "_SegShield_" .. i, segBg, CT_TEXTURE)
                segShield:SetColor(0.4, 0.75, 0.95, 0.6)
                segShield:SetDrawLevel(2)
                segShield:ClearAnchors()
                segShield:SetAnchor(TOPLEFT, segBg, TOPLEFT, 0, 0)
                segShield:SetAnchor(BOTTOMLEFT, segBg, BOTTOMLEFT, 0, 0)
                segShield:SetWidth(0)
                segShield:SetHidden(true)
            end
            
            seg = { bg = segBg, fill = segFill, shield = segShield, width = segmentWidth }
            segments[i] = seg
        end
        
        -- Update positions and widths of all active segments
        local xOffset = padding + (i - 1) * (segmentWidth + gap)
        seg.bg:ClearAnchors()
        seg.bg:SetAnchor(TOPLEFT, bg, TOPLEFT, xOffset, padding)
        seg.bg:SetAnchor(BOTTOMLEFT, bg, BOTTOMLEFT, xOffset, -padding)
        seg.bg:SetWidth(segmentWidth)
        seg.bg:SetHidden(false)
        
        seg.fill:ClearAnchors()
        seg.fill:SetAnchor(TOPLEFT, seg.bg, TOPLEFT, 0, 0)
        seg.fill:SetAnchor(BOTTOMLEFT, seg.bg, BOTTOMLEFT, 0, 0)
        
        seg.width = segmentWidth
        
        if seg.shield then
            seg.shield:ClearAnchors()
            seg.shield:SetAnchor(TOPLEFT, seg.bg, TOPLEFT, 0, 0)
            seg.shield:SetAnchor(BOTTOMLEFT, seg.bg, BOTTOMLEFT, 0, 0)
        end
    end
    
    -- Hide any extra segments beyond numSegments
    for i = numSegments + 1, #segments do
        local seg = segments[i]
        if seg then
            seg.bg:SetHidden(true)
            seg.fill:SetHidden(true)
            if seg.shield then seg.shield:SetHidden(true) end
        end
    end
    
    barContainer.numSegments = numSegments
end

-- Update the fill percentage of a segmented bar
local function SetBarPercentage(barContainer, pct)
    if not barContainer or not barContainer.segments then return end
    
    -- Clamp percentage
    pct = math.max(0, math.min(1, pct))
    
    local numSegments = barContainer.numSegments
    local totalFill = pct * numSegments
    
    for i = 1, numSegments do
        local seg = barContainer.segments[i]
        if not seg then break end
        
        if i <= totalFill then
            seg.fill:SetWidth(seg.width)
            seg.fill:SetHidden(false)
        elseif i - 1 < totalFill then
            local fraction = totalFill - (i - 1)
            seg.fill:SetWidth(seg.width * fraction)
            seg.fill:SetHidden(false)
        else
            seg.fill:SetWidth(0)
            seg.fill:SetHidden(true)
        end
    end
end

-- Update the shield percentage overlay
local function SetShieldPercentage(barContainer, shieldPct)
    if not barContainer or not barContainer.segments then return end
    
    shieldPct = math.max(0, math.min(1, shieldPct))
    local numSegments = barContainer.numSegments
    local totalFill = shieldPct * numSegments
    
    for i = 1, numSegments do
        local seg = barContainer.segments[i]
        if not seg then break end
        
        if seg.shield then
            if i <= totalFill then
                seg.shield:SetWidth(seg.width)
                seg.shield:SetHidden(false)
            elseif i - 1 < totalFill then
                local fraction = totalFill - (i - 1)
                seg.shield:SetWidth(seg.width * fraction)
                seg.shield:SetHidden(false)
            else
                seg.shield:SetWidth(0)
                seg.shield:SetHidden(true)
            end
        end
    end
end

-- Toggle lock state on all frames
local function SetHUDUnlocked(unlocked)
    TorigaHUD.db.unlockHUD = unlocked
    local frames = {
        TorigaHUD.healthFrame,
        TorigaHUD.xpFrame,
        TorigaHUD.magickaFrame,
        TorigaHUD.staminaFrame,
        TorigaHUD.targetFrame
    }
    for _, f in ipairs(frames) do
        if f then
            f:SetMovable(unlocked)
            f:SetMouseEnabled(unlocked)
            if f.dragBG then
                f.dragBG:SetHidden(not unlocked)
            end
        end
    end
    
    -- Enter/Exit UI mouse mode
    SetGameCameraUIMode(unlocked)
end

-- Open drag mode: cache positions, hide settings panel, show dialog, unlock frames
function TorigaHUD.OpenDragMode()
    TorigaHUD.cachedPositions = {
        healthPosX = TorigaHUD.db.healthPosX,
        healthPosY = TorigaHUD.db.healthPosY,
        xpPosX = TorigaHUD.db.xpPosX,
        xpPosY = TorigaHUD.db.xpPosY,
        magickaPosX = TorigaHUD.db.magickaPosX,
        magickaPosY = TorigaHUD.db.magickaPosY,
        staminaPosX = TorigaHUD.db.staminaPosX,
        staminaPosY = TorigaHUD.db.staminaPosY,
        targetPosX = TorigaHUD.db.targetPosX,
        targetPosY = TorigaHUD.db.targetPosY,
    }
    
    -- Track if settings menu was open
    TorigaHUD.wasSettingsOpen = not (HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing())
    
    -- Close settings menu if open
    SCENE_MANAGER:ShowBaseScene()
    
    -- Show dialog
    if TorigaHUD.confirmDialog then
        TorigaHUD.confirmDialog:SetHidden(false)
    end
    
    -- Unlock HUD & trigger mouse interaction
    SetHUDUnlocked(true)
end

-- Close drag mode: hide dialog, lock frames, restore positions if canceled, re-open settings if needed
function TorigaHUD.CloseDragMode(save)
    -- Hide dialog
    if TorigaHUD.confirmDialog then
        TorigaHUD.confirmDialog:SetHidden(true)
    end
    
    -- Lock HUD
    SetHUDUnlocked(false)
    
    if not save and TorigaHUD.cachedPositions then
        -- Restore cached positions
        TorigaHUD.db.healthPosX = TorigaHUD.cachedPositions.healthPosX
        TorigaHUD.db.healthPosY = TorigaHUD.cachedPositions.healthPosY
        TorigaHUD.db.xpPosX = TorigaHUD.cachedPositions.xpPosX
        TorigaHUD.db.xpPosY = TorigaHUD.cachedPositions.xpPosY
        TorigaHUD.db.magickaPosX = TorigaHUD.cachedPositions.magickaPosX
        TorigaHUD.db.magickaPosY = TorigaHUD.cachedPositions.magickaPosY
        TorigaHUD.db.staminaPosX = TorigaHUD.cachedPositions.staminaPosX
        TorigaHUD.db.staminaPosY = TorigaHUD.cachedPositions.staminaPosY
        TorigaHUD.db.targetPosX = TorigaHUD.cachedPositions.targetPosX
        TorigaHUD.db.targetPosY = TorigaHUD.cachedPositions.targetPosY
        
        -- Re-anchor
        if TorigaHUD.healthFrame then
            TorigaHUD.healthFrame:ClearAnchors()
            TorigaHUD.healthFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.healthPosX, TorigaHUD.db.healthPosY)
        end
        if TorigaHUD.xpFrame then
            TorigaHUD.xpFrame:ClearAnchors()
            TorigaHUD.xpFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.xpPosX, TorigaHUD.db.xpPosY)
        end
        if TorigaHUD.magickaFrame then
            TorigaHUD.magickaFrame:ClearAnchors()
            TorigaHUD.magickaFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.magickaPosX, TorigaHUD.db.magickaPosY)
        end
        if TorigaHUD.staminaFrame then
            TorigaHUD.staminaFrame:ClearAnchors()
            TorigaHUD.staminaFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TorigaHUD.db.staminaPosX, TorigaHUD.db.staminaPosY)
        end
        if TorigaHUD.targetFrame then
            TorigaHUD.targetFrame:ClearAnchors()
            TorigaHUD.targetFrame:SetAnchor(TOP, GuiRoot, TOP, TorigaHUD.db.targetPosX, TorigaHUD.db.targetPosY)
        end
        
        ResetCachedMaxValues()
    end
    
    -- Re-open settings menu if it was open before sbloccando
    if TorigaHUD.wasSettingsOpen and TorigaHUD.settingsPanel then
        LibAddonMenu2:OpenToPanel(TorigaHUD.settingsPanel)
    end
end

-- Toggle drag mode action
function TorigaHUD.ToggleDragMode()
    if TorigaHUD.db.unlockHUD then
        TorigaHUD.CloseDragMode(true)
    else
        TorigaHUD.OpenDragMode()
    end
end

-- Helper to create a draggable top-level frame with custom drag overlay
local function CreateDraggableFrame(name, width, height, defaultX, defaultY, dbKeyX, dbKeyY, labelText, parentAnchor)
    local wm = GetWindowManager()
    
    local frame = wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDimensions(width, height)
    
    -- Retrieve saved position or use default
    local savedX = TorigaHUD.db[dbKeyX] or defaultX
    local savedY = TorigaHUD.db[dbKeyY] or defaultY
    
    frame:ClearAnchors()
    frame:SetAnchor(parentAnchor or TOPLEFT, GuiRoot, parentAnchor or TOPLEFT, savedX, savedY)
    frame:SetHidden(false)
    frame:SetMovable(TorigaHUD.db.unlockHUD)
    frame:SetMouseEnabled(TorigaHUD.db.unlockHUD)
    
    -- Save position on move stop
    frame:SetHandler("OnMoveStop", function(control)
        local isValid, point, relTo, relPoint, x, y = control:GetAnchor(0)
        TorigaHUD.db[dbKeyX] = x
        TorigaHUD.db[dbKeyY] = y
        TorigaHUD.db.layoutPreset = "Personalizzato"
    end)
    
    -- Create drag overlay
    local dragBG = wm:CreateControl(name .. "_DragBG", frame, CT_BACKDROP)
    dragBG:ClearAnchors()
    dragBG:SetAnchor(TOPLEFT, frame, TOPLEFT, -2, -2)
    dragBG:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, 2, 2)
    dragBG:SetCenterColor(0.2, 0.6, 1, 0.3)
    dragBG:SetEdgeColor(0.2, 0.6, 1, 0.9)
    dragBG:SetEdgeTexture("", 2, 1, 1) -- Sharp corners
    dragBG:SetHidden(not TorigaHUD.db.unlockHUD)
    
    local dragLabel = wm:CreateControl(name .. "_DragLabel", dragBG, CT_LABEL)
    dragLabel:ClearAnchors()
    dragLabel:SetAnchor(CENTER, dragBG, CENTER, 0, 0)
    dragLabel:SetFont("$(GAMEPAD_BOLD_FONT)|11|soft-shadow-thin")
    dragLabel:SetColor(1, 1, 1, 0.95)
    dragLabel:SetText(labelText)
    dragLabel:SetHidden(false)
    
    frame.dragBG = dragBG
    
    return frame
end

-- Helper to create a sleek flat buttons for dialogs
local function CreateSleekButton(name, parent, width, height, text, onClickCallback)
    local wm = GetWindowManager()
    local btn = wm:CreateControl(name, parent, CT_BACKDROP)
    btn:SetDimensions(width, height)
    btn:SetCenterColor(0.1, 0.1, 0.1, 0.9)
    btn:SetEdgeColor(1, 1, 1, 0.5)
    btn:SetEdgeTexture("", 2, 1, 1)
    btn:SetMouseEnabled(true)
    
    local label = wm:CreateControl(name .. "_Label", btn, CT_LABEL)
    label:ClearAnchors()
    label:SetAnchor(CENTER, btn, CENTER, 0, 0)
    label:SetFont("$(GAMEPAD_BOLD_FONT)|11|soft-shadow-thin")
    label:SetColor(1, 1, 1, 0.9)
    label:SetText(text)
    
    btn:SetHandler("OnMouseEnter", function()
        btn:SetCenterColor(0.2, 0.2, 0.2, 0.95)
        btn:SetEdgeColor(1, 1, 1, 0.9)
        label:SetColor(1, 1, 1, 1)
    end)
    
    btn:SetHandler("OnMouseExit", function()
        btn:SetCenterColor(0.1, 0.1, 0.1, 0.9)
        btn:SetEdgeColor(1, 1, 1, 0.5)
        label:SetColor(1, 1, 1, 0.9)
    end)
    
    btn:SetHandler("OnMouseUp", function(control, button, upInside)
        if upInside and onClickCallback then
            onClickCallback()
        end
    end)
    
    return btn
end

-- Create all UI controls dynamically
function TorigaHUD.CreateUI()
    local wm = GetWindowManager()
    
    -- A. HEALTH FRAME (Top-Left)
    local healthFrame = CreateDraggableFrame("TorigaHUD_HealthFrame", 250, 36, TorigaHUD.defaults.healthPosX, TorigaHUD.defaults.healthPosY, "healthPosX", "healthPosY", GetString(SI_TORIGAHUD_TEXT_HEALTH), TOPLEFT)
    TorigaHUD.healthFrame = healthFrame

    -- Health Bar (Width 250, Height 14, Horizon Coral Red, with solid white border)
    local hpBar = CreateHUDBar("TorigaHUD_Health", healthFrame, 250, 14, true)
    hpBar:ClearAnchors()
    hpBar:SetAnchor(TOPLEFT, healthFrame, TOPLEFT, 0, 18)
    TorigaHUD.healthBar = hpBar

    -- Health Label (Placed ABOVE the Health bar, aligned right)
    local hpText = wm:CreateControl("TorigaHUD_HealthText", healthFrame, CT_LABEL)
    hpText:SetAnchor(BOTTOMRIGHT, hpBar, TOPRIGHT, 0, -2)
    hpText:SetFont("$(GAMEPAD_BOLD_FONT)|13|soft-shadow-thin")
    hpText:SetColor(1, 1, 1, 0.95)
    hpText:SetHidden(false)
    TorigaHUD.healthText = hpText

    -- Level Label (Placed ABOVE the Health bar, aligned left)
    local lvlText = wm:CreateControl("TorigaHUD_LevelText", healthFrame, CT_LABEL)
    lvlText:SetAnchor(BOTTOMLEFT, hpBar, TOPLEFT, 0, -2)
    lvlText:SetFont("$(GAMEPAD_BOLD_FONT)|13|soft-shadow-thin")
    lvlText:SetColor(0.78, 0.63, 0.35, 0.95) -- Gold color
    lvlText:SetHidden(false)
    TorigaHUD.levelText = lvlText

    -- B. XP FRAME
    local xpFrame = CreateDraggableFrame("TorigaHUD_XPFrame", 250, 26, TorigaHUD.defaults.xpPosX, TorigaHUD.defaults.xpPosY, "xpPosX", "xpPosY", GetString(SI_TORIGAHUD_DRAG_XP), TOPLEFT)
    TorigaHUD.xpFrame = xpFrame

    -- XP Bar (Width 250, Height 4, Teal/Blue)
    local xpBar = CreateHUDBar("TorigaHUD_XP", xpFrame, 250, 4, false)
    xpBar:ClearAnchors()
    xpBar:SetAnchor(TOPLEFT, xpFrame, TOPLEFT, 0, 18)
    TorigaHUD.xpBar = xpBar

    -- XP Label (Placed ABOVE the XP bar, displays Level Progress title)
    local xpText = wm:CreateControl("TorigaHUD_XPText", xpFrame, CT_LABEL)
    xpText:SetAnchor(BOTTOMLEFT, xpBar, TOPLEFT, 0, -2)
    xpText:SetFont("$(GAMEPAD_BOLD_FONT)|11|soft-shadow-thin")
    xpText:SetColor(0.78, 0.63, 0.35, 0.95)
    xpText:SetText(GetString(SI_TORIGAHUD_TEXT_XP))
    xpText:SetHidden(false)
    TorigaHUD.xpText = xpText

    -- Initialize XP bar segments once (15 segments)
    UpdateHUDBarSegments(xpBar, 0, { 0.44, 0.68, 0.74, 0.95 }, { 0.05, 0.05, 0.05, 0.4 }, 15)

    -- C. MAGICKA FRAME
    local magickaFrame = CreateDraggableFrame("TorigaHUD_MagickaFrame", 250, 32, TorigaHUD.defaults.magickaPosX, TorigaHUD.defaults.magickaPosY, "magickaPosX", "magickaPosY", GetString(SI_TORIGAHUD_TEXT_MAGICKA), TOPLEFT)
    TorigaHUD.magickaFrame = magickaFrame

    local mpBar = CreateHUDBar("TorigaHUD_Magicka", magickaFrame, 250, 10, true)
    mpBar:ClearAnchors()
    mpBar:SetAnchor(TOPLEFT, magickaFrame, TOPLEFT, 0, 16)
    TorigaHUD.magickaBar = mpBar

    -- Magicka Label
    local mpText = wm:CreateControl("TorigaHUD_MagickaText", magickaFrame, CT_LABEL)
    mpText:SetAnchor(BOTTOMLEFT, mpBar, TOPLEFT, 0, -2)
    mpText:SetFont("$(GAMEPAD_MEDIUM_FONT)|11|soft-shadow-thin")
    mpText:SetColor(0.65, 0.85, 1, 0.9)
    mpText:SetHidden(false)
    TorigaHUD.magickaText = mpText

    -- D. STAMINA FRAME
    local staminaFrame = CreateDraggableFrame("TorigaHUD_StaminaFrame", 250, 32, TorigaHUD.defaults.staminaPosX, TorigaHUD.defaults.staminaPosY, "staminaPosX", "staminaPosY", GetString(SI_TORIGAHUD_TEXT_STAMINA), TOPLEFT)
    TorigaHUD.staminaFrame = staminaFrame

    local spBar = CreateHUDBar("TorigaHUD_Stamina", staminaFrame, 250, 10, true)
    spBar:ClearAnchors()
    spBar:SetAnchor(TOPLEFT, staminaFrame, TOPLEFT, 0, 16)
    TorigaHUD.staminaBar = spBar

    -- Stamina Label
    local spText = wm:CreateControl("TorigaHUD_StaminaText", staminaFrame, CT_LABEL)
    spText:SetAnchor(BOTTOMLEFT, spBar, TOPLEFT, 0, -2)
    spText:SetFont("$(GAMEPAD_MEDIUM_FONT)|11|soft-shadow-thin")
    spText:SetColor(0.65, 1, 0.75, 0.9)
    spText:SetHidden(false)
    TorigaHUD.staminaText = spText

    -- E. TARGET FRAME
    local targetFrame = CreateDraggableFrame("TorigaHUD_TargetFrame", 300, 36, TorigaHUD.defaults.targetPosX, TorigaHUD.defaults.targetPosY, "targetPosX", "targetPosY", GetString(SI_TORIGAHUD_DRAG_TARGET), TOP)
    TorigaHUD.targetFrame = targetFrame
    TorigaHUD.targetControl = targetFrame

    -- Target Health Bar (Width 300, Height 14)
    local tgBar = CreateHUDBar("TorigaHUD_Target", targetFrame, 300, 14, true)
    tgBar:ClearAnchors()
    tgBar:SetAnchor(TOPLEFT, targetFrame, TOPLEFT, 0, 18)
    TorigaHUD.targetBar = tgBar

    -- Target Health Label (Centered inside target bar)
    local tgText = wm:CreateControl("TorigaHUD_TargetText", tgBar, CT_LABEL)
    tgText:SetAnchor(CENTER, tgBar, CENTER, 0, 0)
    tgText:SetFont("$(GAMEPAD_BOLD_FONT)|11|soft-shadow-thin")
    tgText:SetColor(1, 1, 1, 0.95)
    tgText:SetHidden(false)
    TorigaHUD.targetText = tgText

    -- Target Name Label (Centered above the bar, uppercase with shadow)
    local tgNameText = wm:CreateControl("TorigaHUD_TargetNameText", targetFrame, CT_LABEL)
    tgNameText:SetAnchor(BOTTOM, tgBar, TOP, 0, -2)
    tgNameText:SetFont("$(GAMEPAD_BOLD_FONT)|14|soft-shadow-thin")
    tgNameText:SetColor(1, 1, 1, 0.95)
    tgNameText:SetHidden(false)
    TorigaHUD.targetNameText = tgNameText
    
    -- F. CONFIRMATION DIALOG FOR DRAG MODE
    local confirmDialog = wm:CreateControl("TorigaHUD_ConfirmDialog", GuiRoot, CT_TOPLEVELCONTROL)
    confirmDialog:SetDimensions(280, 85)
    confirmDialog:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -220)
    confirmDialog:SetHidden(true)
    
    local cdBg = wm:CreateControl("TorigaHUD_ConfirmDialog_BG", confirmDialog, CT_BACKDROP)
    cdBg:SetAnchorFill(confirmDialog)
    cdBg:SetCenterColor(0.05, 0.05, 0.05, 0.95)
    cdBg:SetEdgeColor(1, 1, 1, 0.8)
    cdBg:SetEdgeTexture("", 2, 1, 1)
    
    local cdLabel = wm:CreateControl("TorigaHUD_ConfirmDialog_Label", cdBg, CT_LABEL)
    cdLabel:ClearAnchors()
    cdLabel:SetAnchor(TOP, cdBg, TOP, 0, 12)
    cdLabel:SetFont("$(GAMEPAD_BOLD_FONT)|11|soft-shadow-thin")
    cdLabel:SetColor(1, 1, 1, 0.95)
    cdLabel:SetText(GetString(SI_TORIGAHUD_DIALOG_TITLE))
    
    local btnApply = CreateSleekButton("TorigaHUD_ConfirmDialog_BtnApply", cdBg, 110, 25, GetString(SI_TORIGAHUD_DIALOG_APPLY), function()
        TorigaHUD.CloseDragMode(true)
    end)
    btnApply:ClearAnchors()
    btnApply:SetAnchor(BOTTOMLEFT, cdBg, BOTTOMLEFT, 20, -12)
    
    local btnCancel = CreateSleekButton("TorigaHUD_ConfirmDialog_BtnCancel", cdBg, 110, 25, GetString(SI_TORIGAHUD_DIALOG_CANCEL), function()
        TorigaHUD.CloseDragMode(false)
    end)
    btnCancel:ClearAnchors()
    btnCancel:SetAnchor(BOTTOMRIGHT, cdBg, BOTTOMRIGHT, -20, -12)
    
    TorigaHUD.confirmDialog = confirmDialog

    -- Apply scales on creation
    ApplyHUDScale()
end

-- Refresh real and visual values on events
local function UpdatePower(unitTag, powerType, powerValue, powerMax)
    if unitTag == "player" then
        if powerType == POWERTYPE_HEALTH then
            TorigaHUD.player.health.cur = powerValue
            TorigaHUD.player.health.max = powerMax
        elseif powerType == POWERTYPE_MAGICKA then
            TorigaHUD.player.magicka.cur = powerValue
            TorigaHUD.player.magicka.max = powerMax
        elseif powerType == POWERTYPE_STAMINA then
            TorigaHUD.player.stamina.cur = powerValue
            TorigaHUD.player.stamina.max = powerMax
        end
    elseif unitTag == "target" and powerType == POWERTYPE_HEALTH then
        TorigaHUD.target.health.cur = powerValue
        TorigaHUD.target.health.max = powerMax
    end
end

local function OnPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    UpdatePower(unitTag, powerType, powerValue, powerMax)
end

-- Handle shield updates
local function OnShieldUpdate(eventCode, unitTag, visualType, statType, attributeType, powerType, value, maxValue)
    if unitTag == "player" and visualType == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        TorigaHUD.player.shield.cur = GetPlayerShieldValue()
    end
end

-- Handle target changes
local function OnTargetChanged(eventCode)
    local exists = DoesUnitExist("target")
    TorigaHUD.target.exists = exists
    
    if exists then
        local name = GetUnitName("target")
        local level = GetUnitLevel("target")
        TorigaHUD.target.name = name
        TorigaHUD.target.level = level
        
        TorigaHUD.targetNameText:SetText(string.upper(name) .. "  |cFFD700Lvl " .. tostring(level) .. "|r")
        
        local curHealth, maxHealth = GetUnitPower("target", POWERTYPE_HEALTH)
        TorigaHUD.target.health.cur = curHealth
        TorigaHUD.target.health.max = maxHealth
        TorigaHUD.target.health.vis = curHealth
    end
end

-- Core updates loop for smooth resource bar movement (lerping) and out of combat hiding
function TorigaHUD.OnUpdateHandler()
    -- Hide everything if we are in a menu (inventory, character sheet, map, etc.) unless HUD is unlocked for dragging
    local isHudVisible = HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()
    local unlocked = TorigaHUD.db.unlockHUD
    
    if not isHudVisible and not unlocked then
        if TorigaHUD.healthFrame then TorigaHUD.healthFrame:SetHidden(true) end
        if TorigaHUD.xpFrame then TorigaHUD.xpFrame:SetHidden(true) end
        if TorigaHUD.magickaFrame then TorigaHUD.magickaFrame:SetHidden(true) end
        if TorigaHUD.staminaFrame then TorigaHUD.staminaFrame:SetHidden(true) end
        if TorigaHUD.targetFrame then TorigaHUD.targetFrame:SetHidden(true) end
        return
    end

    local speed = TorigaHUD.db.lerpSpeed
    local inCombat = IsUnitInCombat("player")
    
    -- Handle out of combat hiding
    local hide = false
    if TorigaHUD.db.hideOutOfCombat and not unlocked then
        hide = not inCombat and not TorigaHUD.target.exists
    end
    
    TorigaHUD.healthFrame:SetHidden(hide)
    TorigaHUD.xpFrame:SetHidden(hide)
    TorigaHUD.magickaFrame:SetHidden(hide)
    TorigaHUD.staminaFrame:SetHidden(hide)

    if unlocked then
        TorigaHUD.targetFrame:SetHidden(false)
    elseif not TorigaHUD.target.exists then
        TorigaHUD.targetFrame:SetHidden(true)
    else
        TorigaHUD.targetFrame:SetHidden(hide)
    end

    -- Update player level dynamically above the health bar
    local levelStr = GetPlayerLevelString()
    TorigaHUD.levelText:SetText(GetString(SI_TORIGAHUD_TEXT_LEVEL) .. " " .. levelStr)
    
    -- Update XP progress bar dynamically
    local xpPct = GetPlayerXPPercentage()
    SetBarPercentage(TorigaHUD.xpBar, xpPct)

    local p = TorigaHUD.player

    -- 1. Player Health & Shield
    p.health.vis = Lerp(p.health.vis, p.health.cur, speed)
    local hpVisPct = p.health.max > 0 and (p.health.vis / p.health.max) or 0
    
    -- Rebuild health segments dynamically if max value changed
    if p.health.max ~= p.health.maxCached then
        p.health.maxCached = p.health.max
        UpdateHUDBarSegments(TorigaHUD.healthBar, p.health.max, { 0.88, 0.38, 0.32, 0.95 }, { 0.05, 0.05, 0.05, 0.65 })
    end
    SetBarPercentage(TorigaHUD.healthBar, hpVisPct)
    
    local hPct = p.health.max > 0 and (p.health.cur / p.health.max * 100) or 0
    TorigaHUD.healthText:SetText(GetString(SI_TORIGAHUD_TEXT_HEALTH) .. ": " .. FormatNumber(p.health.cur) .. " / " .. FormatNumber(p.health.max) .. " (" .. string.format("%d", hPct) .. "%)")

    -- Shield Overlay
    if TorigaHUD.db.showShields and p.shield.cur > 0 then
        p.shield.vis = Lerp(p.shield.vis, p.shield.cur, speed)
        local shPct = p.health.max > 0 and (p.shield.vis / p.health.max) or 0
        SetShieldPercentage(TorigaHUD.healthBar, shPct)
    else
        SetShieldPercentage(TorigaHUD.healthBar, 0)
    end

    -- 2. Player Magicka
    p.magicka.vis = Lerp(p.magicka.vis, p.magicka.cur, speed)
    local mpVisPct = p.magicka.max > 0 and (p.magicka.vis / p.magicka.max) or 0
    
    -- Rebuild magicka segments dynamically if max value changed
    if p.magicka.max ~= p.magicka.maxCached then
        p.magicka.maxCached = p.magicka.max
        UpdateHUDBarSegments(TorigaHUD.magickaBar, p.magicka.max, { 0.25, 0.55, 0.85, 0.95 }, { 0.05, 0.05, 0.05, 0.65 })
    end
    SetBarPercentage(TorigaHUD.magickaBar, mpVisPct)
    local mPct = p.magicka.max > 0 and (p.magicka.cur / p.magicka.max * 100) or 0
    TorigaHUD.magickaText:SetText(GetString(SI_TORIGAHUD_TEXT_MAGICKA) .. ": " .. FormatNumber(p.magicka.cur) .. " / " .. FormatNumber(p.magicka.max) .. " (" .. string.format("%d", mPct) .. "%)")

    -- 3. Player Stamina
    p.stamina.vis = Lerp(p.stamina.vis, p.stamina.cur, speed)
    local spVisPct = p.stamina.max > 0 and (p.stamina.vis / p.stamina.max) or 0
    
    -- Rebuild stamina segments dynamically if max value changed
    if p.stamina.max ~= p.stamina.maxCached then
        p.stamina.maxCached = p.stamina.max
        UpdateHUDBarSegments(TorigaHUD.staminaBar, p.stamina.max, { 0.4, 0.8, 0.45, 0.95 }, { 0.05, 0.05, 0.05, 0.65 })
    end
    SetBarPercentage(TorigaHUD.staminaBar, spVisPct)
    local sPct = p.stamina.max > 0 and (p.stamina.cur / p.stamina.max * 100) or 0
    TorigaHUD.staminaText:SetText(GetString(SI_TORIGAHUD_TEXT_STAMINA) .. ": " .. FormatNumber(p.stamina.cur) .. " / " .. FormatNumber(p.stamina.max) .. " (" .. string.format("%d", sPct) .. "%)")

    -- 4. Target Health
    if TorigaHUD.target.exists then
        local t = TorigaHUD.target
        t.health.vis = Lerp(t.health.vis, t.health.cur, speed)
        local tgVisPct = t.health.max > 0 and (t.health.vis / t.health.max) or 0
        
        -- Rebuild target segments dynamically if max value changed
        if t.health.max ~= t.health.maxCached then
            t.health.maxCached = t.health.max
            UpdateHUDBarSegments(TorigaHUD.targetBar, t.health.max, { 0.88, 0.38, 0.32, 0.95 }, { 0.05, 0.05, 0.05, 0.65 })
        end
        SetBarPercentage(TorigaHUD.targetBar, tgVisPct)
        
        local tPct = t.health.max > 0 and (t.health.cur / t.health.max * 100) or 0
        TorigaHUD.targetText:SetText(FormatNumber(t.health.cur) .. " (" .. string.format("%d", tPct) .. "%)")
        
        local formattedName = string.upper(t.name) .. "  |cFFD700Lvl " .. tostring(t.level) .. "|r"
        TorigaHUD.targetNameText:SetText(formattedName)
    elseif unlocked then
        -- Default text for target when unlocked but no target exists
        TorigaHUD.targetText:SetText("50.0k (100%)")
        TorigaHUD.targetNameText:SetText(GetString(SI_TORIGAHUD_TEXT_TARGET_TEST) .. "  |cFFD700Lvl 50|r")
        if TorigaHUD.target.health.maxCached ~= 50000 then
            TorigaHUD.target.health.maxCached = 50000
            UpdateHUDBarSegments(TorigaHUD.targetBar, 50000, { 0.88, 0.38, 0.32, 0.95 }, { 0.05, 0.05, 0.05, 0.65 })
        end
        SetBarPercentage(TorigaHUD.targetBar, 1.0)
    end
end

-- Refresh current values to avoid starting at 0
local function InitCurrentValues()
    local stats = {
        { "player", POWERTYPE_HEALTH, TorigaHUD.player.health },
        { "player", POWERTYPE_MAGICKA, TorigaHUD.player.magicka },
        { "player", POWERTYPE_STAMINA, TorigaHUD.player.stamina }
    }
    for _, stat in ipairs(stats) do
        local cur, max = GetUnitPower(stat[1], stat[2])
        stat[3].cur = cur
        stat[3].max = max
        stat[3].vis = cur
    end
    TorigaHUD.player.shield.cur = GetPlayerShieldValue()
    TorigaHUD.player.shield.vis = TorigaHUD.player.shield.cur
end

-- LibAddonMenu settings panel
function TorigaHUD.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "TorigaHUD",
        displayName = "|cFFD700TorigaHUD|r Settings",
        author = "Toriga",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local panel = LAM:RegisterAddonPanel("TorigaHUDSettingsPanel", panelData)

    local optionsTable = {
        {
            type = "header",
            name = GetString(SI_TORIGAHUD_SETTINGS_GENERAL_HEADER),
        },
        {
            type = "checkbox",
            name = GetString(SI_TORIGAHUD_SETTINGS_HIDE_OOC),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_HIDE_OOC_TT),
            getFunc = function() return TorigaHUD.db.hideOutOfCombat end,
            setFunc = function(value) TorigaHUD.db.hideOutOfCombat = value end,
            default = TorigaHUD.defaults.hideOutOfCombat,
        },
        {
            type = "checkbox",
            name = GetString(SI_TORIGAHUD_SETTINGS_SHOW_SHIELDS),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_SHOW_SHIELDS_TT),
            getFunc = function() return TorigaHUD.db.showShields end,
            setFunc = function(value) TorigaHUD.db.showShields = value end,
            default = TorigaHUD.defaults.showShields,
        },
        {
            type = "slider",
            name = GetString(SI_TORIGAHUD_SETTINGS_LERP_SPEED),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_LERP_SPEED_TT),
            min = 0.05,
            max = 1.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return TorigaHUD.db.lerpSpeed end,
            setFunc = function(value) TorigaHUD.db.lerpSpeed = value end,
            default = TorigaHUD.defaults.lerpSpeed,
        },
        {
            type = "slider",
            name = GetString(SI_TORIGAHUD_SETTINGS_SEGMENT_SIZE),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_SEGMENT_SIZE_TT),
            min = 500,
            max = 10000,
            step = 500,
            getFunc = function() return TorigaHUD.db.segmentSize or 2000 end,
            setFunc = function(value) 
                TorigaHUD.db.segmentSize = value
                ResetCachedMaxValues()
            end,
            default = TorigaHUD.defaults.segmentSize,
        },
        {
            type = "slider",
            name = GetString(SI_TORIGAHUD_SETTINGS_SCALE),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_SCALE_TT),
            min = 0.50,
            max = 1.50,
            step = 0.05,
            decimals = 2,
            getFunc = function() return TorigaHUD.db.hudScale or 1.0 end,
            setFunc = function(value)
                TorigaHUD.db.hudScale = value
                ApplyHUDScale()
            end,
            default = TorigaHUD.defaults.hudScale,
        },
        {
            type = "header",
            name = GetString(SI_TORIGAHUD_SETTINGS_PRESETS_HEADER),
        },
        {
            type = "dropdown",
            name = GetString(SI_TORIGAHUD_SETTINGS_PRESET),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_PRESET_TT),
            choices = { 
                GetString(SI_TORIGAHUD_SETTINGS_PRESET_DEFAULT), 
                GetString(SI_TORIGAHUD_SETTINGS_PRESET_VERTICAL), 
                GetString(SI_TORIGAHUD_SETTINGS_PRESET_HORIZONTAL), 
                GetString(SI_TORIGAHUD_SETTINGS_PRESET_MINIMALIST) 
            },
            choicesValues = { "Default", "Focus Combat (Verticale)", "Focus Combat (Orizzontale)", "Minimalist (Compatto)" },
            getFunc = function() return TorigaHUD.db.layoutPreset or "Default" end,
            setFunc = function(value)
                TorigaHUD.db.layoutPreset = value
                ApplyPreset(value)
            end,
            default = TorigaHUD.defaults.layoutPreset,
        },
        {
            type = "checkbox",
            name = GetString(SI_TORIGAHUD_SETTINGS_UNLOCK),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_UNLOCK_TT),
            getFunc = function() return TorigaHUD.db.unlockHUD end,
            setFunc = function(value) 
                if value then
                    TorigaHUD.OpenDragMode()
                else
                    TorigaHUD.CloseDragMode(true)
                end
            end,
            default = TorigaHUD.defaults.unlockHUD,
        },
        {
            type = "button",
            name = GetString(SI_TORIGAHUD_SETTINGS_RESET),
            tooltip = GetString(SI_TORIGAHUD_SETTINGS_RESET_TT),
            func = function()
                ApplyPreset("Default")
                TorigaHUD.db.layoutPreset = "Default"
            end,
        }
    }

    LAM:RegisterOptionControls("TorigaHUDSettingsPanel", optionsTable)
    TorigaHUD.settingsPanel = panel
end

-- Addon Loaded Event Entry
local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName == TorigaHUD.name then
        EVENT_MANAGER:UnregisterForEvent(TorigaHUD.name, EVENT_ADD_ON_LOADED)
        
        -- Safe repair function: cleans up bad string "version" keys inside saved vars before ZO_SavedVars loads
        local function CleanSavedVarsTable(t)
            if type(t) ~= "table" then return end
            if type(t.version) == "string" then
                t.version = 1 -- Reset ZOS's internal variable back to integer
            end
            for k, v in pairs(t) do
                if type(v) == "table" then
                    CleanSavedVarsTable(v)
                end
            end
        end
        CleanSavedVarsTable(TorigaHUDSavedVariables)

        -- Saved Variables
        TorigaHUD.db = ZO_SavedVars:NewAccountWide("TorigaHUDSavedVariables", 1, nil, TorigaHUD.defaults)
        
        -- Backwards compatibility or migration
        if TorigaHUD.db.targetPositionY and not TorigaHUD.db.targetPosY then
            TorigaHUD.db.targetPosY = TorigaHUD.db.targetPositionY
        end

        -- Create UI elements
        TorigaHUD.CreateUI()
        InitCurrentValues()
        HideDefaultHUD()

        -- Register HUD scene fragments so HUD elements hide in menus
        local controls = {
            TorigaHUD.healthFrame,
            TorigaHUD.xpFrame,
            TorigaHUD.magickaFrame,
            TorigaHUD.staminaFrame,
            TorigaHUD.targetFrame
        }
        for _, ctrl in ipairs(controls) do
            if ctrl then
                local fragment = ZO_HUDFadeSceneFragment:New(ctrl)
                HUD_SCENE:AddFragment(fragment)
                HUD_UI_SCENE:AddFragment(fragment)
            end
        end

        -- Force position alignment upgrade
        if not TorigaHUD.db.addonVersion or TorigaHUD.db.addonVersion ~= "1.4.0" then
            TorigaHUD.db.addonVersion = "1.4.0"
            ApplyPreset("Default")
            TorigaHUD.db.layoutPreset = "Default"
        end

        -- Register Events
        EVENT_MANAGER:RegisterForEvent(TorigaHUD.name, EVENT_POWER_UPDATE, OnPowerUpdate)
        EVENT_MANAGER:RegisterForEvent(TorigaHUD.name, EVENT_RETICLE_TARGET_CHANGED, OnTargetChanged)
        EVENT_MANAGER:RegisterForEvent(TorigaHUD.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, OnShieldUpdate)
        EVENT_MANAGER:RegisterForEvent(TorigaHUD.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, OnShieldUpdate)
        EVENT_MANAGER:RegisterForEvent(TorigaHUD.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATE, OnShieldUpdate)

        -- Register update loop for smooth lerping
        EVENT_MANAGER:RegisterForUpdate(TorigaHUD.name .. "Loop", 15, TorigaHUD.OnUpdateHandler)

        -- Register Slash Commands for drag toggle
        SLASH_COMMANDS["/torigahud"] = TorigaHUD.ToggleDragMode
        SLASH_COMMANDS["/thud"] = TorigaHUD.ToggleDragMode

        -- Settings Panel
        TorigaHUD.CreateSettingsMenu()
    end
end

EVENT_MANAGER:RegisterForEvent(TorigaHUD.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
