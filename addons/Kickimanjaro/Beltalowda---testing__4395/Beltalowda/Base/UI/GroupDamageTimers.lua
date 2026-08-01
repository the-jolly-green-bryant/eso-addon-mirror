-- Beltalowda Group Damage Timers
-- Ported from RdK Group Tool Detonation/Shalk Tracker by @s0rdrak
-- Tracks Proximity Detonation, Subterranean Assault, and Deep Fissure
-- across all group members with countdown timer bars.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupDamageTimers = Beltalowda.UI.GroupDamageTimers or {}

local GDT = Beltalowda.UI.GroupDamageTimers

-- ============================================================================
-- Constants
-- ============================================================================

GDT.ADDON_NAME = "Beltalowda"
GDT.CALLBACK_NAME = "BeltalowdaGroupDamageTimers"
GDT.TLW_NAME = "BeltalowdaGroupDamageTimersTLW"

-- Display modes
GDT.MODE_BOTH = 1
GDT.MODE_DETONATION = 2
GDT.MODE_SHALK = 3

GDT.MODE_NAMES = {
    [1] = "Both",
    [2] = "Detonation",
    [3] = "Shalk",
}

-- Timer types (for coloring in MODE_BOTH)
GDT.TYPE_DETONATION = 1
GDT.TYPE_SUBTERRANEAN_ASSAULT = 2
GDT.TYPE_DEEP_FISSURE = 3

-- Size presets (interpolated via slider)
GDT.SIZE_SMALL = 1
GDT.SIZE_BIG = 2

GDT.SIZES = {
    [1] = { width = 150, blockHeight = 20, height = 200, fontSize = 15 },
    [2] = { width = 300, blockHeight = 40, height = 400, fontSize = 30 },
}

-- Tracked ability IDs
GDT.ABILITY_IDS = {
    proximityDetonation     = { [61500] = true },
    subterraneanAssault     = { [86019] = true },
    subterraneanAssaultWave2 = { [146919] = true },
    deepFissure             = { [86015] = true },
    deepFissureWave2        = { [178028] = true },
}

-- ============================================================================
-- Configuration
-- ============================================================================

GDT.config = {
    updateInterval = 100,   -- ms between UI + buff scan updates
    isClampedToScreen = false,
    maxPlayers = 24,
}

-- ============================================================================
-- State
-- ============================================================================

GDT.state = {
    initialized = false,
    foreground = true,
    activeLayerIndex = 1,
    menuHidden = false,
    pvpHidden = false,
    registeredConsumers = false,
    registeredActiveConsumers = false,
    -- Interpolated dimensions (recalculated in AdjustSize)
    width = GDT.SIZES[GDT.SIZE_SMALL].width,
    blockHeight = GDT.SIZES[GDT.SIZE_SMALL].blockHeight,
    height = GDT.SIZES[GDT.SIZE_SMALL].height,
    fontSize = GDT.SIZES[GDT.SIZE_SMALL].fontSize,
    font = nil,
}

-- Per-player buff data, indexed by unitTag
GDT.playerData = {}

-- UI control references
GDT.controls = {}

-- Settings (loaded from saved variables)
GDT.settings = nil

local wm = WINDOW_MANAGER

-- ============================================================================
-- Default Settings
-- ============================================================================

function GDT.GetDefaults()
    return {
        enabled = false,  -- Disabled by default - role-based damage tracker is the primary view
        positionLocked = false,
        location = nil,     -- { x, y } or nil for centered default
        size = GDT.SIZE_SMALL,
        mode = GDT.MODE_BOTH,
        smoothTransition = true,
        detonation = {
            fontColor     = { r = 1, g = 1, b = 1 },
            progressColor = { r = 0.578, g = 0.289, b = 0.641 },  -- purple
        },
        subterraneanAssault = {
            fontColor     = { r = 1, g = 1, b = 1 },
            progressColor = { r = 0.1, g = 0.95, b = 0.1 },       -- green
        },
        subterraneanAssault2 = {
            fontColor     = { r = 1, g = 1, b = 1 },
            progressColor = { r = 1, g = 0.8, b = 0.1 },          -- yellow
        },
        deepFissure = {
            fontColor     = { r = 1, g = 1, b = 1 },
            progressColor = { r = 0.289, g = 0.289, b = 0.95 },   -- blue
        },
        deepFissure2 = {
            fontColor     = { r = 1, g = 1, b = 1 },
            progressColor = { r = 0.089, g = 0.0, b = 1.0 },      -- dark blue
        },
    }
end

-- ============================================================================
-- Settings Persistence
-- ============================================================================

function GDT.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    if not BeltalowdaVars.ui.groupDamageTimers then
        BeltalowdaVars.ui.groupDamageTimers = GDT.GetDefaults()
    end

    -- Ensure all default keys exist (forward compat)
    local defaults = GDT.GetDefaults()
    for k, v in pairs(defaults) do
        if BeltalowdaVars.ui.groupDamageTimers[k] == nil then
            BeltalowdaVars.ui.groupDamageTimers[k] = v
        end
    end
    -- Ensure nested color tables exist
    for _, key in ipairs({"detonation", "subterraneanAssault", "subterraneanAssault2", "deepFissure", "deepFissure2"}) do
        if type(BeltalowdaVars.ui.groupDamageTimers[key]) ~= "table" then
            BeltalowdaVars.ui.groupDamageTimers[key] = defaults[key]
        else
            for ck, cv in pairs(defaults[key]) do
                if BeltalowdaVars.ui.groupDamageTimers[key][ck] == nil then
                    BeltalowdaVars.ui.groupDamageTimers[key][ck] = cv
                end
            end
        end
    end

    GDT.settings = BeltalowdaVars.ui.groupDamageTimers
end

function GDT.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupDamageTimers = GDT.settings
end

-- ============================================================================
-- Font Helper
-- ============================================================================

--- Build an ESO font string. Falls back to a safe default.
local function MakeFontString(size)
    -- ESO font descriptor: "FontPath|sizeInPixels|weight"
    -- MEDIUM_FONT is the standard ESO UI font
    return "$(MEDIUM_FONT)|" .. tostring(math.floor(size)) .. "|soft-shadow-thin"
end

-- ============================================================================
-- UI Creation
-- ============================================================================

function GDT.Initialize()
    if GDT.state.initialized then return end
    GDT.LoadSettings()
    GDT.CreateUI()
    GDT.state.initialized = true
    GDT.SetEnabled(GDT.settings.enabled)
end

function GDT.CreateUI()
    local s = GDT.state

    -- Top-level window
    GDT.controls.TLW = wm:CreateTopLevelWindow(GDT.TLW_NAME)
    GDT.SetTlwLocation()
    GDT.controls.TLW:SetClampedToScreen(GDT.config.isClampedToScreen)
    GDT.controls.TLW:SetHandler("OnMoveStop", GDT.SaveWindowLocation)
    GDT.controls.TLW:SetDimensions(s.width, s.height)

    -- Root control inside the TLW
    GDT.controls.TLW.rootControl = wm:CreateControl(nil, GDT.controls.TLW, CT_CONTROL)
    local root = GDT.controls.TLW.rootControl
    root:SetDimensions(s.width, s.height)
    root:SetAnchor(TOPLEFT, GDT.controls.TLW, TOPLEFT, 0, 0)

    -- Movable backdrop (visible when unlocked)
    root.movableBackdrop = wm:CreateControl(nil, root, CT_BACKDROP)
    root.movableBackdrop:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
    root.movableBackdrop:SetDimensions(s.width, s.height)
    root.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
    root.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)

    -- Player blocks
    root.playerBlocks = GDT.CreatePlayerBlocks(root, s.width, s.blockHeight)

    GDT.controls.TLW:SetHidden(true)
    GDT.AdjustSize()
    GDT.AdjustColors()
    GDT.SetPositionLocked(GDT.settings.positionLocked)
end

function GDT.CreatePlayerBlock(parent, width, blockHeight, font)
    local block = wm:CreateControl(nil, parent, CT_CONTROL)
    block:SetDimensions(width, blockHeight)
    block:SetHidden(true)

    -- Edge border
    block.edge = wm:CreateControl(nil, block, CT_BACKDROP)
    block.edge:SetAnchor(TOPLEFT, block, TOPLEFT, 0, 0)
    block.edge:SetDimensions(width, blockHeight)
    block.edge:SetEdgeTexture(nil, 2, 2, 2, 0)
    block.edge:SetCenterColor(0, 0, 0, 0)
    block.edge:SetEdgeColor(0, 0, 0, 1)

    -- Status bar
    block.progress = wm:CreateControl(nil, block, CT_STATUSBAR)
    block.progress:SetAnchor(CENTER, block, CENTER, 0, 0)
    block.progress:SetDimensions(width - 4, blockHeight - 4)
    block.progress:SetMinMax(0, 100)
    block.progress:SetValue(0)

    -- Time label (left aligned)
    block.timeLabel = wm:CreateControl(nil, block, CT_LABEL)
    block.timeLabel:SetAnchor(CENTER, block, CENTER, 0, 0)
    block.timeLabel:SetFont(font)
    block.timeLabel:SetWrapMode(ELLIPSIS)
    block.timeLabel:SetDimensions(width - 6, blockHeight)
    block.timeLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    block.timeLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    -- Name label (centered)
    block.nameLabel = wm:CreateControl(nil, block, CT_LABEL)
    block.nameLabel:SetAnchor(CENTER, block, CENTER, 0, 0)
    block.nameLabel:SetFont(font)
    block.nameLabel:SetWrapMode(ELLIPSIS)
    block.nameLabel:SetDimensions(width - 50, blockHeight)
    block.nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    block.nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    return block
end

function GDT.CreatePlayerBlocks(parent, width, blockHeight)
    local blocks = {}
    local font = MakeFontString(blockHeight - 4)
    GDT.state.font = font

    for i = 1, GDT.config.maxPlayers do
        blocks[i] = GDT.CreatePlayerBlock(parent, width, blockHeight, font)
        blocks[i]:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (i - 1) * blockHeight)
    end

    return blocks
end

-- ============================================================================
-- Positioning
-- ============================================================================

function GDT.SetTlwLocation()
    GDT.controls.TLW:ClearAnchors()
    if GDT.settings.location then
        GDT.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GDT.settings.location.x, GDT.settings.location.y)
    else
        -- Default to upper-center area using TOPLEFT (avoids anchor type mismatch on first drag)
        local screenW, screenH = GuiRoot:GetDimensions()
        local defaultX = math.floor(screenW / 2 - 125)
        local defaultY = math.floor(screenH / 2 - 125)
        GDT.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaultX, defaultY)
    end
end

function GDT.SaveWindowLocation()
    if not GDT.settings.positionLocked then
        GDT.settings.location = GDT.settings.location or {}
        GDT.settings.location.x = GDT.controls.TLW:GetLeft()
        GDT.settings.location.y = GDT.controls.TLW:GetTop()
        GDT.SaveSettings()
    end
end

-- ============================================================================
-- Size / Mode / Colors
-- ============================================================================

function GDT.AdjustSize()
    local sizeIncrease = GDT.settings.size - GDT.SIZE_SMALL
    local small = GDT.SIZES[GDT.SIZE_SMALL]
    local big   = GDT.SIZES[GDT.SIZE_BIG]

    local height     = small.height     + (big.height     - small.height)     * sizeIncrease
    local width      = small.width      + (big.width      - small.width)      * sizeIncrease
    local blockH     = small.blockHeight + (big.blockHeight - small.blockHeight) * sizeIncrease
    local fontSize   = small.fontSize   + (big.fontSize   - small.fontSize)   * sizeIncrease

    local font = MakeFontString(fontSize)
    GDT.state.width = width
    GDT.state.blockHeight = blockH
    GDT.state.height = height
    GDT.state.fontSize = fontSize
    GDT.state.font = font

    local root = GDT.controls.TLW.rootControl
    local blocks = root.playerBlocks
    for i = 1, #blocks do
        blocks[i]:ClearAnchors()
        blocks[i]:SetAnchor(TOPLEFT, root, TOPLEFT, 0, (i - 1) * blockH)
        blocks[i]:SetDimensions(width, blockH)
        blocks[i]:SetHidden(true)

        blocks[i].edge:SetDimensions(width, blockH)
        blocks[i].progress:SetDimensions(width - 4, blockH - 4)
        blocks[i].timeLabel:SetFont(font)
        blocks[i].timeLabel:SetDimensions(width - 6, blockH)
        blocks[i].nameLabel:SetFont(font)
        blocks[i].nameLabel:SetDimensions(width - 50, blockH)
    end

    GDT.controls.TLW:SetDimensions(width, height)
    root:SetDimensions(width, height)
    root.movableBackdrop:SetDimensions(width, height)
end

function GDT.AdjustColors()
    local blocks = GDT.controls.TLW.rootControl.playerBlocks
    -- When in single-mode, pre-set all blocks to that mode's color
    if GDT.settings.mode == GDT.MODE_DETONATION then
        local fc = GDT.settings.detonation.fontColor
        local pc = GDT.settings.detonation.progressColor
        for i = 1, #blocks do
            blocks[i].nameLabel:SetColor(fc.r, fc.g, fc.b)
            blocks[i].timeLabel:SetColor(fc.r, fc.g, fc.b)
            blocks[i].progress:SetColor(pc.r, pc.g, pc.b)
        end
    end
    -- MODE_BOTH and MODE_SHALK set colors per-block in UiLoop
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function GDT.SetEnabled(value)
    if not GDT.state.initialized or value == nil then return end
    GDT.settings.enabled = value
    GDT.SaveSettings()

    if value then
        if not GDT.state.registeredConsumers then
            EVENT_MANAGER:RegisterForEvent(GDT.CALLBACK_NAME, EVENT_PLAYER_ACTIVATED, GDT.OnPlayerActivated)
        end
        GDT.state.registeredConsumers = true
    else
        if GDT.state.registeredConsumers then
            EVENT_MANAGER:UnregisterForEvent(GDT.CALLBACK_NAME, EVENT_PLAYER_ACTIVATED)
        end
        GDT.state.registeredConsumers = false
    end

    GDT.OnPlayerActivated()
end

function GDT.SetControlVisibility()
    if not GDT.controls.TLW then return end

    if GDT.settings.enabled then
        GDT.controls.TLW:SetHidden(GDT.state.menuHidden == true or GDT.state.pvpHidden == true)
    else
        GDT.controls.TLW:SetHidden(true)
    end
end

function GDT.SetMenuHidden(hidden)
    GDT.state.menuHidden = hidden
    GDT.SetControlVisibility()
end

function GDT.SetPvPHidden(hidden)
    GDT.state.pvpHidden = hidden
    GDT.SetControlVisibility()
end

function GDT.SetPositionLocked(value)
    GDT.settings.positionLocked = value
    GDT.controls.TLW:SetMovable(not value)
    GDT.controls.TLW:SetMouseEnabled(not value)

    if value then
        GDT.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.0)
        GDT.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
    else
        GDT.controls.TLW.rootControl.movableBackdrop:SetCenterColor(1, 0, 0, 0.5)
        GDT.controls.TLW.rootControl.movableBackdrop:SetEdgeColor(1, 0, 0, 0.0)
    end
    GDT.SaveSettings()
end

-- ============================================================================
-- Player Activated / Layer Handlers
-- ============================================================================

function GDT.OnPlayerActivated(eventCode, initial)
    if GDT.settings.enabled then
        if not GDT.state.registeredActiveConsumers then
            EVENT_MANAGER:RegisterForUpdate(GDT.CALLBACK_NAME, GDT.config.updateInterval, GDT.UiLoop)
            GDT.state.registeredActiveConsumers = true
        end
    else
        if GDT.state.registeredActiveConsumers then
            EVENT_MANAGER:UnregisterForUpdate(GDT.CALLBACK_NAME)
            GDT.state.registeredActiveConsumers = false
        end
    end
    GDT.SetControlVisibility()
end

-- ============================================================================
-- Buff Scanning (self-contained, no RdK dependency)
-- ============================================================================

--- Scan all group members for tracked abilities and populate GDT.playerData.
--- Also scans the "player" unit tag when solo (not in a group).
function GDT.ScanGroupBuffs()
    local groupSize = GetGroupSize()
    local players = {}

    -- Build list of unit tags to scan
    local unitTags = {}
    if groupSize > 0 then
        for i = 1, groupSize do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag and DoesUnitExist(unitTag) then
                table.insert(unitTags, unitTag)
            end
        end
    else
        -- Solo: scan the player directly
        table.insert(unitTags, "player")
    end

    for _, unitTag in ipairs(unitTags) do
        local playerName = Beltalowda.GetDisplayName(unitTag)
        local info = {
            name = (playerName ~= "" and playerName) or unitTag,
            unitTag = unitTag,
            proximityDetonation = { active = false, started = 0, ending = 0 },
            subterraneanAssault = { active = false, started = 0, ending = 0, waveTwo = false },
            deepFissure         = { active = false, started = 0, ending = 0, waveTwo = false },
        }

        local numBuffs = GetNumBuffs(unitTag)
        for buffIndex = 1, numBuffs do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
                  buffType, effectType, abilityType, statusEffectType, abilityId =
                GetUnitBuffInfo(unitTag, buffIndex)

            -- RdK checks effectType (8th return value), not buffType (7th)
            if effectType == BUFF_EFFECT_TYPE_BUFF then
                -- Check Proximity Detonation
                if GDT.ABILITY_IDS.proximityDetonation[abilityId] then
                    info.proximityDetonation.active = true
                    info.proximityDetonation.started = timeStarted
                    info.proximityDetonation.ending = timeEnding
                end
                -- Check Subterranean Assault (wave 1)
                if GDT.ABILITY_IDS.subterraneanAssault[abilityId] then
                    info.subterraneanAssault.active = true
                    info.subterraneanAssault.started = timeStarted
                    info.subterraneanAssault.ending = timeEnding
                    info.subterraneanAssault.waveTwo = false
                end
                -- Check Subterranean Assault (wave 2)
                if GDT.ABILITY_IDS.subterraneanAssaultWave2[abilityId] then
                    info.subterraneanAssault.active = true
                    info.subterraneanAssault.started = timeStarted
                    info.subterraneanAssault.ending = timeEnding
                    info.subterraneanAssault.waveTwo = true
                end
                -- Check Deep Fissure (wave 1)
                if GDT.ABILITY_IDS.deepFissure[abilityId] then
                    info.deepFissure.active = true
                    info.deepFissure.started = timeStarted
                    info.deepFissure.ending = timeEnding
                    info.deepFissure.waveTwo = false
                end
                -- Check Deep Fissure (wave 2)
                if GDT.ABILITY_IDS.deepFissureWave2[abilityId] then
                    info.deepFissure.active = true
                    info.deepFissure.started = timeStarted
                    info.deepFissure.ending = timeEnding
                    info.deepFissure.waveTwo = true
                end
            end
        end

        table.insert(players, info)
    end

    return players
end

-- ============================================================================
-- Sorting
-- ============================================================================

local function CompareByRemaining(a, b)
    if a.remaining < b.remaining then
        return false
    elseif a.remaining > b.remaining then
        return true
    else
        if a.name ~= b.name then
            return a.name < b.name
        else
            return (a.buff or 0) < (b.buff or 0)
        end
    end
end

function GDT.GetSortedList(players)
    local displayItems = {}
    local now = GetGameTimeMilliseconds() / 1000
    local mode = GDT.settings.mode

    for i = 1, #players do
        local p = players[i]
        if mode == GDT.MODE_BOTH or mode == GDT.MODE_DETONATION then
            if p.proximityDetonation.active then
                table.insert(displayItems, {
                    buff      = GDT.TYPE_DETONATION,
                    remaining = p.proximityDetonation.ending - now,
                    name      = p.name,
                    started   = p.proximityDetonation.started,
                    ending    = p.proximityDetonation.ending,
                })
            end
        end
        if mode == GDT.MODE_BOTH or mode == GDT.MODE_SHALK then
            if p.subterraneanAssault.active then
                table.insert(displayItems, {
                    buff      = GDT.TYPE_SUBTERRANEAN_ASSAULT,
                    remaining = p.subterraneanAssault.ending - now,
                    name      = p.name,
                    started   = p.subterraneanAssault.started,
                    ending    = p.subterraneanAssault.ending,
                    waveTwo   = p.subterraneanAssault.waveTwo,
                })
            elseif p.deepFissure.active then
                table.insert(displayItems, {
                    buff      = GDT.TYPE_DEEP_FISSURE,
                    remaining = p.deepFissure.ending - now,
                    name      = p.name,
                    started   = p.deepFissure.started,
                    ending    = p.deepFissure.ending,
                    waveTwo   = p.deepFissure.waveTwo,
                })
            end
        end
    end

    table.sort(displayItems, CompareByRemaining)
    return displayItems
end

-- ============================================================================
-- Main UI Loop
-- ============================================================================

function GDT.UiLoop()
    local players = GDT.ScanGroupBuffs()
    if not players or #players == 0 then
        -- Hide all blocks when not in a group
        if GDT.controls.TLW and GDT.controls.TLW.rootControl then
            local blocks = GDT.controls.TLW.rootControl.playerBlocks
            if blocks then
                for i = 1, #blocks do
                    blocks[i]:SetHidden(true)
                end
            end
        end
        return
    end

    local displayItems = GDT.GetSortedList(players)
    local blocks = GDT.controls.TLW.rootControl.playerBlocks
    local sv = GDT.settings

    for i = 1, #displayItems do
        local item = displayItems[i]
        local timespan = item.remaining
        if timespan < 0 then timespan = 0 end

        -- Ensure block exists
        if not blocks[i] then
            blocks[i] = GDT.CreatePlayerBlock(GDT.controls.TLW.rootControl, GDT.state.width, GDT.state.blockHeight, GDT.state.font)
            blocks[i]:SetAnchor(TOPLEFT, GDT.controls.TLW.rootControl, TOPLEFT, 0, (i - 1) * GDT.state.blockHeight)
        end

        -- Set colors based on timer type
        local fc, pc
        local percent = 0

        if item.buff == GDT.TYPE_DETONATION then
            fc = sv.detonation.fontColor
            pc = sv.detonation.progressColor
            local duration = item.ending - item.started
            if duration > 0 then
                percent = item.remaining / duration * 100
            end

        elseif item.buff == GDT.TYPE_SUBTERRANEAN_ASSAULT then
            if item.waveTwo then
                fc = sv.subterraneanAssault2.fontColor
                pc = sv.subterraneanAssault2.progressColor
            else
                fc = sv.subterraneanAssault.fontColor
                pc = sv.subterraneanAssault.progressColor
            end
            local duration = item.ending - item.started + 5
            if duration > 0 then
                percent = item.remaining / duration * 100
            end

        elseif item.buff == GDT.TYPE_DEEP_FISSURE then
            if item.waveTwo then
                fc = sv.deepFissure2.fontColor
                pc = sv.deepFissure2.progressColor
                local duration = item.ending - item.started + 2
                if duration > 0 then
                    percent = item.remaining / duration * 100
                end
            else
                fc = sv.deepFissure.fontColor
                pc = sv.deepFissure.progressColor
                local duration = item.ending - item.started + 5
                if duration > 0 then
                    percent = item.remaining / duration * 100
                end
            end
        end

        if fc and pc then
            blocks[i].timeLabel:SetColor(fc.r, fc.g, fc.b)
            blocks[i].nameLabel:SetColor(fc.r, fc.g, fc.b)
            blocks[i].progress:SetColor(pc.r, pc.g, pc.b)
        end

        blocks[i]:SetHidden(false)
        blocks[i].timeLabel:SetText(string.format("%.1f", timespan))
        blocks[i].nameLabel:SetText(item.name)
        ZO_StatusBar_SmoothTransition(blocks[i].progress, percent, 100, not sv.smoothTransition)
    end

    -- Hide unused blocks
    for i = #displayItems + 1, #blocks do
        blocks[i]:SetHidden(true)
    end
end

-- ============================================================================
-- Settings Panel Controls (called from BeltalowdaSettings.lua)
-- ============================================================================

function GDT.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFClassic Damage Tracker|r",
            tooltip = "Track Proximity Detonation, Subterranean Assault, and Deep Fissure timers across the group",
            controls = {
                {
                    type = "description",
                    text = "Shows countdown timer bars for coordinated damage abilities (Proximity Detonation, Subterranean Assault / Deep Fissure) across all group members. Ported from RdK Group Tool.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Group Damage Timers",
                    tooltip = "Show/hide the group damage timer display",
                    getFunc = function() return GDT.settings.enabled end,
                    setFunc = function(value) GDT.SetEnabled(value) end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Lock Position",
                    tooltip = "Lock the damage timer window position (prevent accidental movement)",
                    getFunc = function() return GDT.settings.positionLocked end,
                    setFunc = function(value) GDT.SetPositionLocked(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "dropdown",
                    name = "Display Mode",
                    tooltip = "Choose which timer types to display",
                    choices = { "Both", "Detonation", "Shalk" },
                    getFunc = function() return GDT.MODE_NAMES[GDT.settings.mode] end,
                    setFunc = function(value)
                        for k, v in pairs(GDT.MODE_NAMES) do
                            if v == value then
                                GDT.settings.mode = k
                                GDT.AdjustColors()
                                GDT.SaveSettings()
                                break
                            end
                        end
                    end,
                    width = "full",
                    default = "Both",
                },
                {
                    type = "slider",
                    name = "Size",
                    tooltip = "Adjust the overall size of the timer display (1.0 = small, 2.0 = large)",
                    min = 1.0,
                    max = 2.0,
                    step = 0.01,
                    decimals = 2,
                    getFunc = function() return GDT.settings.size end,
                    setFunc = function(value)
                        if value >= GDT.SIZE_SMALL and value <= GDT.SIZE_BIG then
                            GDT.settings.size = value
                            GDT.AdjustSize()
                            GDT.SaveSettings()
                        end
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "checkbox",
                    name = "Smooth Transition",
                    tooltip = "Enable smooth bar transitions (disable for snappy updates)",
                    getFunc = function() return GDT.settings.smoothTransition end,
                    setFunc = function(value)
                        GDT.settings.smoothTransition = value
                        GDT.SaveSettings()
                    end,
                    width = "full",
                    default = true,
                },
                -- Color pickers
                {
                    type = "colorpicker",
                    name = "Detonation: Font Color",
                    getFunc = function()
                        local c = GDT.settings.detonation.fontColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.detonation.fontColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Detonation: Progress Color",
                    getFunc = function()
                        local c = GDT.settings.detonation.progressColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.detonation.progressColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Sub. Assault: Font Color",
                    getFunc = function()
                        local c = GDT.settings.subterraneanAssault.fontColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.subterraneanAssault.fontColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Sub. Assault: Progress Color",
                    getFunc = function()
                        local c = GDT.settings.subterraneanAssault.progressColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.subterraneanAssault.progressColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Sub. Assault Wave 2: Font Color",
                    getFunc = function()
                        local c = GDT.settings.subterraneanAssault2.fontColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.subterraneanAssault2.fontColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Sub. Assault Wave 2: Progress Color",
                    getFunc = function()
                        local c = GDT.settings.subterraneanAssault2.progressColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.subterraneanAssault2.progressColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Deep Fissure: Font Color",
                    getFunc = function()
                        local c = GDT.settings.deepFissure.fontColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.deepFissure.fontColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Deep Fissure: Progress Color",
                    getFunc = function()
                        local c = GDT.settings.deepFissure.progressColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.deepFissure.progressColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Deep Fissure Wave 2: Font Color",
                    getFunc = function()
                        local c = GDT.settings.deepFissure2.fontColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.deepFissure2.fontColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Deep Fissure Wave 2: Progress Color",
                    getFunc = function()
                        local c = GDT.settings.deepFissure2.progressColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDT.settings.deepFissure2.progressColor = { r = r, g = g, b = b }
                        GDT.AdjustColors()
                        GDT.SaveSettings()
                    end,
                    width = "full",
                },
            },
        },
    }
end
