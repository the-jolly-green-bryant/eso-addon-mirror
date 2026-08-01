-- Beltalowda Rapid Overview
-- Ported from RdK Group Tool Rapid Tracker by @s0rdrak
-- Displays Major and Minor Expedition buff timers for every group member.
-- Each player is shown with their name and two status bars that drain as
-- the buff expires. Player names are colored by distance.
--
-- Improvement over RdK: Uses the API-reported timeEnding value directly
-- instead of hardcoding an 8-second duration. This correctly handles
-- Jorvuld's Guidance and any other buff duration modifiers.
-- This helps transform the tracker from something that just told you to recast
-- rapids into something that shows actual group Expedition status.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.RapidOverview = Beltalowda.UI.RapidOverview or {}

local RO = Beltalowda.UI.RapidOverview

-- ============================================================================
-- Constants
-- ============================================================================

RO.ADDON_NAME = "Beltalowda"
RO.CALLBACK_NAME = "BeltalowdaRapidOverview"
RO.TLW_NAME = "BeltalowdaRapidOverviewTLW"

-- Tracked ability IDs
RO.ABILITY_IDS = {
    majorExpedition = 61736,
    minorExpedition = 61735,
}

-- Distance thresholds (meters)
RO.DISTANCE_IN_RANGE = 28       -- Rapid Maneuver range
RO.DISTANCE_MAX_VISIBLE = 100   -- Beyond this = out of range

-- ============================================================================
-- Configuration
-- ============================================================================

RO.MAX_PLAYERS = 12     -- Cyrodiil group cap

RO.config = {
    updateInterval = 100,   -- ms between UI + buff scan updates
    isClampedToScreen = true,
    rowHeight = 16,         -- tall enough to contain ZoFontGameSmall (~14px)
    rowSpacing = 1,
    labelWidth = 140,
    barWidth = 20,
    barSpacing = 2,
    headerHeight = 20,      -- height reserved for buff icons above bar columns
    headerIconSize = 16,    -- size of the buff icon textures in the header
    font = "ZoFontGameSmall",
}

-- ============================================================================
-- State
-- ============================================================================

RO.state = {
    initialized = false,
    menuHidden = false,
    pvpHidden = false,
    registeredConsumers = false,
    registeredActiveConsumers = false,
}

-- UI control references
RO.controls = {}

-- Settings (loaded from saved variables)
RO.settings = nil

local wm = WINDOW_MANAGER

-- ============================================================================
-- Default Settings
-- ============================================================================

function RO.GetDefaults()
    return {
        enabled = false,
        preventMovement = false,
        location = nil,     -- { x, y } or nil for centered default
        colors = {
            inRange    = { r = 0, g = 1, b = 0 },      -- green (≤28m)
            notInRange = { r = 1, g = 0, b = 0 },      -- red (28–100m)
            outOfRange = { r = 1, g = 1, b = 1 },      -- white (>100m)
            rapidOn    = { r = 0, g = 1, b = 0 },      -- green bar fill
            rapidOff   = { r = 1, g = 0, b = 0 },      -- red bar background
        },
    }
end

-- ============================================================================
-- Settings Persistence
-- ============================================================================

function RO.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    if not BeltalowdaVars.ui.rapidOverview then
        BeltalowdaVars.ui.rapidOverview = RO.GetDefaults()
    end

    -- Ensure all default keys exist (forward compat)
    local defaults = RO.GetDefaults()
    for k, v in pairs(defaults) do
        if BeltalowdaVars.ui.rapidOverview[k] == nil then
            BeltalowdaVars.ui.rapidOverview[k] = v
        end
    end

    -- Migrate positionLocked → preventMovement
    if BeltalowdaVars.ui.rapidOverview.preventMovement == nil and BeltalowdaVars.ui.rapidOverview.positionLocked ~= nil then
        BeltalowdaVars.ui.rapidOverview.preventMovement = BeltalowdaVars.ui.rapidOverview.positionLocked
        BeltalowdaVars.ui.rapidOverview.positionLocked = nil
    end
    -- Ensure nested color tables exist
    if type(BeltalowdaVars.ui.rapidOverview.colors) ~= "table" then
        BeltalowdaVars.ui.rapidOverview.colors = defaults.colors
    else
        for ck, cv in pairs(defaults.colors) do
            if BeltalowdaVars.ui.rapidOverview.colors[ck] == nil then
                BeltalowdaVars.ui.rapidOverview.colors[ck] = cv
            end
        end
    end

    RO.settings = BeltalowdaVars.ui.rapidOverview
end

function RO.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.rapidOverview = RO.settings
end

-- ============================================================================
-- UI Creation
-- ============================================================================

function RO.Initialize()
    if RO.state.initialized then return end
    RO.LoadSettings()
    RO.CreateUI()
    RO.state.initialized = true
    RO.SetEnabled(RO.settings.enabled)
end

function RO.CreateUI()
    local cfg = RO.config
    -- Single column: labelWidth + 2 bars + spacing
    local totalWidth = cfg.labelWidth + (cfg.barWidth * 2) + (cfg.barSpacing * 2)
    local headerH = cfg.headerHeight
    local totalHeight = headerH + RO.MAX_PLAYERS * (cfg.rowHeight + cfg.rowSpacing)

    -- Top-level window
    RO.controls.TLW = wm:CreateTopLevelWindow(RO.TLW_NAME)
    RO.SetTlwLocation()
    RO.controls.TLW:SetClampedToScreen(cfg.isClampedToScreen)
    RO.controls.TLW:SetHandler("OnMoveStop", RO.SaveWindowLocation)
    RO.controls.TLW:SetDimensions(totalWidth, totalHeight)

    -- Root control inside the TLW
    RO.controls.TLW.rootControl = wm:CreateControl(nil, RO.controls.TLW, CT_CONTROL)
    local root = RO.controls.TLW.rootControl
    root:SetDimensions(totalWidth, totalHeight)
    root:SetAnchor(TOPLEFT, RO.controls.TLW, TOPLEFT, 0, 0)

    -- Movable backdrop (always transparent, no red indicator)
    root.movableBackdrop = wm:CreateControl(nil, root, CT_BACKDROP)
    root.movableBackdrop:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    root.movableBackdrop:SetDimensions(totalWidth, totalHeight)
    root.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
    root.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)

    -- Header row: buff icons above the Major / Minor Expedition bar columns
    local iconSz = cfg.headerIconSize
    local majorIcon = GetAbilityIcon(RO.ABILITY_IDS.majorExpedition)
    local minorIcon = GetAbilityIcon(RO.ABILITY_IDS.minorExpedition)
    local iconY = math.floor((headerH - iconSz) / 2)

    local majX = math.floor((cfg.barWidth - iconSz) / 2)
    local minX = cfg.barWidth + cfg.barSpacing + math.floor((cfg.barWidth - iconSz) / 2)

    local majTex = wm:CreateControl(nil, root, CT_TEXTURE)
    majTex:SetDimensions(iconSz, iconSz)
    majTex:SetTexture(majorIcon)
    majTex:SetAnchor(TOPLEFT, root, TOPLEFT, majX, iconY)

    local minTex = wm:CreateControl(nil, root, CT_TEXTURE)
    minTex:SetDimensions(iconSz, iconSz)
    minTex:SetTexture(minorIcon)
    minTex:SetAnchor(TOPLEFT, root, TOPLEFT, minX, iconY)

    -- Player controls (12 slots, single column below the header)
    root.playerControls = {}
    for i = 1, RO.MAX_PLAYERS do
        local offsetY = headerH + (i - 1) * (cfg.rowHeight + cfg.rowSpacing)
        root.playerControls[i] = RO.CreatePlayerControl(
            root, offsetY, 0, cfg.rowHeight, cfg.labelWidth, cfg.barWidth
        )
    end

    RO.controls.TLW:SetHidden(true)
    RO.AdjustColors()
    RO.SetPreventMovement(RO.settings.preventMovement)
end

function RO.CreatePlayerControl(parent, offsetHeight, offsetWidth, height, labelWidth, barWidth)
    local cfg = RO.config

    local playerControl = wm:CreateControl(nil, parent, CT_CONTROL)
    playerControl:SetAnchor(TOPLEFT, parent, TOPLEFT, offsetWidth, offsetHeight)
    playerControl:SetDimensions(labelWidth + (barWidth * 2) + (cfg.barSpacing * 2), height)
    playerControl:SetHidden(true)

    -- All bars anchored to parent TOPLEFT with explicit pixel offsets
    -- Inset 2px top/bottom so bars appear thinner while staying centered
    local majorX = 0
    local minorX = barWidth + cfg.barSpacing
    local barInset = 2
    local barH = height - (barInset * 2)

    -- Major Expedition backdrop (background/off color)
    playerControl.majorExpeditionStatus = wm:CreateControl(nil, playerControl, CT_BACKDROP)
    playerControl.majorExpeditionStatus:SetDimensions(barWidth, barH)
    playerControl.majorExpeditionStatus:SetAnchor(TOPLEFT, playerControl, TOPLEFT, majorX, barInset)

    -- Major Expedition status bar (fill/on color)
    playerControl.majorExpeditionBar = wm:CreateControl(nil, playerControl, CT_STATUSBAR)
    playerControl.majorExpeditionBar:SetDimensions(barWidth, barH)
    playerControl.majorExpeditionBar:SetAnchor(TOPLEFT, playerControl, TOPLEFT, majorX, barInset)
    playerControl.majorExpeditionBar:SetMinMax(0, 100)
    playerControl.majorExpeditionBar:SetValue(0)

    -- Minor Expedition backdrop (background/off color)
    playerControl.minorExpeditionStatus = wm:CreateControl(nil, playerControl, CT_BACKDROP)
    playerControl.minorExpeditionStatus:SetDimensions(barWidth, barH)
    playerControl.minorExpeditionStatus:SetAnchor(TOPLEFT, playerControl, TOPLEFT, minorX, barInset)

    -- Minor Expedition status bar (fill/on color)
    playerControl.minorExpeditionBar = wm:CreateControl(nil, playerControl, CT_STATUSBAR)
    playerControl.minorExpeditionBar:SetDimensions(barWidth, barH)
    playerControl.minorExpeditionBar:SetAnchor(TOPLEFT, playerControl, TOPLEFT, minorX, barInset)
    playerControl.minorExpeditionBar:SetMinMax(0, 100)
    playerControl.minorExpeditionBar:SetValue(0)

    -- Player name label (to the right of the bars)
    local labelX = (barWidth * 2) + (cfg.barSpacing * 2)
    playerControl.playerLabel = wm:CreateControl(nil, playerControl, CT_LABEL)
    playerControl.playerLabel:SetDimensions(labelWidth, height)
    playerControl.playerLabel:SetAnchor(TOPLEFT, playerControl, TOPLEFT, labelX, 0)
    playerControl.playerLabel:SetFont(cfg.font)
    playerControl.playerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    playerControl.playerLabel:SetText("")

    return playerControl
end

-- ============================================================================
-- Positioning
-- ============================================================================

function RO.SetTlwLocation()
    RO.controls.TLW:ClearAnchors()
    if RO.settings and RO.settings.location then
        RO.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RO.settings.location.x, RO.settings.location.y)
    else
        RO.controls.TLW:SetAnchor(CENTER, GuiRoot, CENTER, 250, 150)
    end
end

function RO.SaveWindowLocation()
    if not RO.settings.preventMovement then
        RO.settings.location = RO.settings.location or {}
        RO.settings.location.x = RO.controls.TLW:GetLeft()
        RO.settings.location.y = RO.controls.TLW:GetTop()
        RO.SaveSettings()
    end
end

-- ============================================================================
-- Colors
-- ============================================================================

function RO.AdjustColors()
    local colors = RO.settings.colors
    local controls = RO.controls.TLW.rootControl.playerControls

    for i = 1, #controls do
        local pc = controls[i]
        -- Backdrop = "off" color
        pc.majorExpeditionStatus:SetCenterColor(colors.rapidOff.r, colors.rapidOff.g, colors.rapidOff.b)
        pc.majorExpeditionStatus:SetEdgeColor(colors.rapidOff.r, colors.rapidOff.g, colors.rapidOff.b)
        pc.minorExpeditionStatus:SetCenterColor(colors.rapidOff.r, colors.rapidOff.g, colors.rapidOff.b)
        pc.minorExpeditionStatus:SetEdgeColor(colors.rapidOff.r, colors.rapidOff.g, colors.rapidOff.b)
        -- Status bar = "on" color
        pc.majorExpeditionBar:SetColor(colors.rapidOn.r, colors.rapidOn.g, colors.rapidOn.b)
        pc.minorExpeditionBar:SetColor(colors.rapidOn.r, colors.rapidOn.g, colors.rapidOn.b)
    end
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function RO.SetEnabled(value)
    if not RO.state.initialized or value == nil then return end
    RO.settings.enabled = value
    RO.SaveSettings()

    if value then
        if not RO.state.registeredConsumers then
            EVENT_MANAGER:RegisterForEvent(RO.CALLBACK_NAME, EVENT_PLAYER_ACTIVATED, RO.OnPlayerActivated)
            RO.state.registeredConsumers = true
        end
    else
        if RO.state.registeredConsumers then
            EVENT_MANAGER:UnregisterForEvent(RO.CALLBACK_NAME, EVENT_PLAYER_ACTIVATED)
            RO.state.registeredConsumers = false
        end
    end

    RO.OnPlayerActivated()
end

function RO.SetControlVisibility()
    if not RO.controls.TLW then return end

    if RO.settings.enabled then
        RO.controls.TLW:SetHidden(RO.state.menuHidden == true or RO.state.pvpHidden == true)
    else
        RO.controls.TLW:SetHidden(true)
    end
end

function RO.SetMenuHidden(hidden)
    RO.state.menuHidden = hidden
    RO.SetControlVisibility()
end

function RO.SetPvPHidden(hidden)
    RO.state.pvpHidden = hidden
    RO.SetControlVisibility()
end

function RO.SetPreventMovement(value)
    RO.settings.preventMovement = value
    RO.controls.TLW:SetMovable(not value)
    RO.controls.TLW:SetMouseEnabled(not value)

    -- Always transparent backdrop (no red indicator)
    RO.controls.TLW.rootControl.movableBackdrop:SetCenterColor(0, 0, 0, 0.0)
    RO.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(0, 0, 0, 0.0)
    RO.SaveSettings()
end

-- ============================================================================
-- Player Activated
-- ============================================================================

function RO.OnPlayerActivated(eventCode, initial)
    if RO.settings.enabled then
        if not RO.state.registeredActiveConsumers then
            EVENT_MANAGER:RegisterForUpdate(RO.CALLBACK_NAME, RO.config.updateInterval, RO.UiLoop)
            RO.state.registeredActiveConsumers = true
        end
    else
        if RO.state.registeredActiveConsumers then
            EVENT_MANAGER:UnregisterForUpdate(RO.CALLBACK_NAME)
            RO.state.registeredActiveConsumers = false
        end
    end
    RO.SetControlVisibility()
end

-- ============================================================================
-- Buff Scanning (self-contained, no RdK dependency)
-- ============================================================================

--- Scan all group members for Major/Minor Expedition buffs.
--- Uses timeEnding directly from the API (not hardcoded duration) so
--- Jorvuld's Guidance and other modifiers are handled correctly.
function RO.ScanGroupBuffs()
    local groupSize = GetGroupSize()
    local players = {}

    -- Build unit tags to scan
    local unitTags = {}
    if groupSize > 0 then
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag and DoesUnitExist(unitTag) then
                table.insert(unitTags, unitTag)
            end
        end
    else
        table.insert(unitTags, "player")
    end

    local currentTime = GetGameTimeMilliseconds() / 1000

    -- Cache our own world position once per scan
    local _, myRawX, myRawY, myRawZ = GetUnitRawWorldPosition("player")

    for _, unitTag in ipairs(unitTags) do
        local playerName = GetUnitName(unitTag)
        local displayName = Beltalowda.GetDisplayName(unitTag)
        local isOnline = IsUnitOnline(unitTag)
        local isDead = IsUnitDead(unitTag)

        local info = {
            name = displayName or playerName or unitTag,
            unitTag = unitTag,
            majorExpedition = { active = false, ending = 0, uptime = 0 },
            minorExpedition = { active = false, ending = 0, uptime = 0 },
            distance = -1,  -- -1 = unknown/offline
            isOnline = isOnline,
            isDead = isDead,
        }

        -- Only scan buffs and distance for online, alive players
        if isOnline and not isDead then
            -- Scan buffs
            local numBuffs = GetNumBuffs(unitTag)
            for buffIndex = 1, numBuffs do
                local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
                      buffType, effectType, abilityType, statusEffectType, abilityId =
                    GetUnitBuffInfo(unitTag, buffIndex)

                if abilityId == RO.ABILITY_IDS.majorExpedition then
                    info.majorExpedition.active = true
                    info.majorExpedition.ending = timeEnding
                    info.majorExpedition.uptime = timeEnding - timeStarted
                elseif abilityId == RO.ABILITY_IDS.minorExpedition then
                    info.minorExpedition.active = true
                    info.minorExpedition.ending = timeEnding
                    info.minorExpedition.uptime = timeEnding - timeStarted
                end
            end

            -- Calculate distance using raw world positions (centimeters)
            if unitTag ~= "player" then
                local _, theirRawX, theirRawY, theirRawZ = GetUnitRawWorldPosition(unitTag)
                if theirRawX and theirRawX ~= 0 and theirRawY ~= 0 then
                    local dx = (theirRawX - myRawX) / 100  -- cm → m
                    local dy = (theirRawY - myRawY) / 100
                    local dz = (theirRawZ - myRawZ) / 100
                    info.distance = math.sqrt(dx * dx + dy * dy + dz * dz)
                end
            else
                info.distance = 0  -- self
            end
        end

        table.insert(players, info)
    end

    return players, currentTime
end

-- ============================================================================
-- Bar Update Helper
-- ============================================================================

local function AdjustExpeditionBar(statusBar, buff, currentTime)
    if buff.active then
        local remaining = buff.ending - currentTime
        if remaining < 0 then remaining = 0 end
        local percent = 0
        if buff.uptime > 0 then
            percent = remaining / buff.uptime * 100
        end
        statusBar:SetValue(percent)
    else
        statusBar:SetValue(0)
    end
end

-- ============================================================================
-- Main UI Loop
-- ============================================================================

function RO.UiLoop()
    local players, currentTime = RO.ScanGroupBuffs()
    local controls = RO.controls.TLW.rootControl.playerControls
    local colors = RO.settings.colors

    if not players or #players == 0 then
        for i = 1, #controls do
            controls[i]:SetHidden(true)
        end
        return
    end

    for i = 1, #players do
        local p = players[i]
        local pc = controls[i]
        if not pc then break end

        -- Update bars
        AdjustExpeditionBar(pc.majorExpeditionBar, p.majorExpedition, currentTime)
        AdjustExpeditionBar(pc.minorExpeditionBar, p.minorExpedition, currentTime)

        -- Color name by status and distance
        if not p.isOnline or p.isDead then
            -- Offline or dead → red (not in range)
            pc.playerLabel:SetColor(colors.notInRange.r, colors.notInRange.g, colors.notInRange.b)
        elseif p.distance < 0 then
            -- Unknown position → white (out of range)
            pc.playerLabel:SetColor(colors.outOfRange.r, colors.outOfRange.g, colors.outOfRange.b)
        elseif p.distance <= RO.DISTANCE_IN_RANGE then
            pc.playerLabel:SetColor(colors.inRange.r, colors.inRange.g, colors.inRange.b)
        elseif p.distance <= RO.DISTANCE_MAX_VISIBLE then
            pc.playerLabel:SetColor(colors.notInRange.r, colors.notInRange.g, colors.notInRange.b)
        else
            pc.playerLabel:SetColor(colors.outOfRange.r, colors.outOfRange.g, colors.outOfRange.b)
        end

        pc.playerLabel:SetText(p.name)
        pc:SetHidden(false)
    end

    -- Hide unused slots
    for i = #players + 1, #controls do
        controls[i]:SetHidden(true)
        controls[i].playerLabel:SetText("")
    end
end

-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function RO.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFRapid Overview|r |t24:24:/esoui/art/icons/ability_ava_002_b.dds|t",
            tooltip = "Track Major and Minor Expedition buff uptime across the group",
            controls = {
                {
                    type = "description",
                    text = "Shows Major and Minor Expedition buff timers for every group member. Players are colored by distance: green = in Rapid Maneuver range (≤28m), red = nearby but out of range, white = far away. Uses API-reported durations so Jorvuld's Guidance is handled correctly.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Rapid Overview",
                    tooltip = "Show/hide the Rapid Overview display",
                    getFunc = function() return RO.settings.enabled end,
                    setFunc = function(value) RO.SetEnabled(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Prevent Movement",
                    tooltip = "When enabled, the window cannot be dragged. When disabled, click and drag anywhere to reposition it.",
                    getFunc = function() return RO.settings.preventMovement end,
                    setFunc = function(value) RO.SetPreventMovement(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "colorpicker",
                    name = "In Range Color (≤28m)",
                    tooltip = "Name color for players within Rapid Maneuver range",
                    getFunc = function()
                        local c = RO.settings.colors.inRange
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        RO.settings.colors.inRange = { r = r, g = g, b = b }
                        RO.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Not In Range Color (28–100m)",
                    tooltip = "Name color for players nearby but outside Rapid Maneuver range",
                    getFunc = function()
                        local c = RO.settings.colors.notInRange
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        RO.settings.colors.notInRange = { r = r, g = g, b = b }
                        RO.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Out of Range Color (>100m)",
                    tooltip = "Name color for players far away or with unknown position",
                    getFunc = function()
                        local c = RO.settings.colors.outOfRange
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        RO.settings.colors.outOfRange = { r = r, g = g, b = b }
                        RO.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Buff Active Color",
                    tooltip = "Status bar fill color when the Expedition buff is active",
                    getFunc = function()
                        local c = RO.settings.colors.rapidOn
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        RO.settings.colors.rapidOn = { r = r, g = g, b = b }
                        RO.AdjustColors()
                        RO.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Buff Inactive Color",
                    tooltip = "Status bar background color when the Expedition buff is not active",
                    getFunc = function()
                        local c = RO.settings.colors.rapidOff
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        RO.settings.colors.rapidOff = { r = r, g = g, b = b }
                        RO.AdjustColors()
                        RO.SaveSettings()
                    end,
                    width = "full",
                },
            },
        },
    }
end
