-- Beltalowda Damage Timer Tracker
-- Tracks timed damage abilities per group member using reactive buff detection.
-- Flat per-effect layout (RdK style): each tracked effect gets its own bar,
-- sorted by remaining time (most time remaining at top).
--
-- Layout: each bar is a single row showing [Timer | Progress Bar | Icon]
-- with player name overlaid.
--
-- Abilities tracked:
--   1. Subterranean Assault / Deep Fissure (with wave 2 color variants)
--   2. Proximity Detonation
--   3. Blighted Blastbones
--
-- Also evaluates coordination quality ("Good timers!" / "Perfect timers!")
-- when multiple shalks + proxy are detected in sync.

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.GroupDamageTimersByRole = Beltalowda.UI.GroupDamageTimersByRole or {}

local GDTR = Beltalowda.UI.GroupDamageTimersByRole
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

GDTR.ADDON_NAME = "Beltalowda"
GDTR.CALLBACK_NAME = "BeltalowdaDamageTimerTracker"
GDTR.TLW_NAME = "BeltalowdaDamageTimerTracker"

-- Layout dimensions
GDTR.PLAYER_BAR_WIDTH = 180
GDTR.ROW_HEIGHT = 18             -- Height of each bar
GDTR.COMBAT_BORDER_WIDTH = 1     -- Border thickness (thin visible border)
GDTR.ICON_SIZE = 18              -- Ability icon
GDTR.ICON_AREA_WIDTH = 22        -- 18px icon + 2px border + 2px gap
GDTR.WINDOW_PADDING = 8
GDTR.HEADER_HEIGHT = 24
GDTR.BAR_GAP = 0                 -- No gap between bars (flush stacking)
GDTR.MAX_BARS = 48               -- Maximum simultaneous effect bars

-- Single bar height: border(1) + 18 + border(1) = 20
GDTR.BAR_HEIGHT = (GDTR.COMBAT_BORDER_WIDTH * 2) + GDTR.ROW_HEIGHT

-- Common reference duration for bar fill normalization.
-- All bars use this as the denominator so that identical remaining times
-- produce identical visual fill levels (continuous vertical plane).
GDTR.BAR_REFERENCE_DURATION = 9

-- ============================================================================
-- Tracked Ability Registry
-- ============================================================================

GDTR.TRACKED_ABILITIES = {
    -- 1: Subterranean Assault / Deep Fissure
    {
        key = "subAssault",
        buffIds = { [86019] = true },
        iconAbilityId = 86019,
        fallbackDuration = 9,
        colorKey = "subAssaultColor",
        hasVariant = true,
        variantBuffIds = { [86015] = true },
        variantIconId = 86015,
        variantColorKey = "deepFissureColor",
        waveTwoBuffIds = { [146919] = true },
        waveTwoColorKey = "subAssaultW2Color",
        variantWaveTwoBuffIds = { [178028] = true },
        variantWaveTwoColorKey = "deepFissureW2Color",
    },
    -- 2: Proximity Detonation
    {
        key = "proxDet",
        buffIds = { [61500] = true },
        iconAbilityId = 61500,
        fallbackDuration = 8,
        colorKey = "proxDetColor",
    },
    -- 3: Blighted Blastbones
    {
        key = "blightedBlastbones",
        buffIds = { [117691] = true },
        iconAbilityId = 117691,
        fallbackDuration = 8,
        displayDuration = 3.8,
        colorKey = "blightedBlastbonesColor",
    },
}

-- Build reverse lookup: abilityId -> { index, matchType }
GDTR.BUFF_LOOKUP = {}

local function buildBuffLookup()
    GDTR.BUFF_LOOKUP = {}
    for idx, ability in ipairs(GDTR.TRACKED_ABILITIES) do
        for id in pairs(ability.buffIds) do
            GDTR.BUFF_LOOKUP[id] = { index = idx, matchType = "primary" }
        end
        if ability.waveTwoBuffIds then
            for id in pairs(ability.waveTwoBuffIds) do
                GDTR.BUFF_LOOKUP[id] = { index = idx, matchType = "wave2" }
            end
        end
        if ability.variantBuffIds then
            for id in pairs(ability.variantBuffIds) do
                GDTR.BUFF_LOOKUP[id] = { index = idx, matchType = "variant" }
            end
        end
        if ability.variantWaveTwoBuffIds then
            for id in pairs(ability.variantWaveTwoBuffIds) do
                GDTR.BUFF_LOOKUP[id] = { index = idx, matchType = "variantWave2" }
            end
        end
    end
end
buildBuffLookup()

-- Colors
GDTR.COLORS = {
    BAR_BACKDROP     = { 0.5, 0.5, 0.5, 0.3 },
    PLAYER_NAME      = { 0.28515625, 0.8828125, 0.02734375 },
    FONT_DEFAULT     = { 1, 1, 1 },
    IN_COMBAT        = { 1, 0, 0 },
    OUT_OF_COMBAT    = { 0, 0, 0 },
    GLOW_ORANGE      = { 1, 0.6, 0 },
    HEADER_PERFECT   = { 0, 1, 0 },
    HEADER_GOOD      = { 1, 1, 0 },
    HEADER_DEFAULT   = { 1, 1, 1 },
}

-- Coordination detection thresholds
GDTR.COORD_PERFECT_WINDOW = 0.3
GDTR.COORD_GOOD_WINDOW    = 1.0
GDTR.COORD_MIN_SHALKS     = 2
GDTR.BLASTBONES_ABILITY_INDEX = 3
GDTR.SHALK_ABILITY_INDEX   = 1
GDTR.PROXY_ABILITY_INDEX   = 2

-- ============================================================================
-- State
-- ============================================================================

GDTR.state = {
    initialized = false,
    menuHidden = false,
    pvpHidden = false,
    registeredConsumers = false,
    registeredActiveConsumers = false,
}

GDTR.controls = {}
GDTR.settings = nil

-- Coordination state (updated each scan cycle)
GDTR.coordination = {
    quality = "none",
    shalkLandingTime = nil,
    proxyActive = false,
    shalkCount = 0,
}

-- ============================================================================
-- Default Settings
-- ============================================================================

function GDTR.GetDefaults()
    return {
        enabled = false,
        preventMovement = false,
        location = nil,
        hideHeader = false,
        subAssaultColor        = { r = 0.1,  g = 0.95, b = 0.1 },
        subAssaultW2Color      = { r = 1.0,  g = 0.8,  b = 0.1 },
        proxDetColor           = { r = 0.65, g = 0.15, b = 0.85 },
        deepFissureColor       = { r = 0.1,  g = 0.35, b = 0.15 },
        deepFissureW2Color     = { r = 0.2,  g = 0.75, b = 0.55 },
        blightedBlastbonesColor= { r = 0.6,  g = 0.55, b = 0.15 },
        fontColor              = { r = 1,    g = 1,    b = 1 },
        showBlastbonesHint     = true,
        blastbonesCastWindow   = 4.0,
        nameDisplayMode        = 2,    -- 1 = all names, 2 = no names, 3 = my name only
        scale                  = 1.0,
        smoothTransition       = true,
    }
end

-- ============================================================================
-- Settings Persistence
-- ============================================================================

function GDTR.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    if not BeltalowdaVars.ui.groupDamageTimersByRole then
        BeltalowdaVars.ui.groupDamageTimersByRole = GDTR.GetDefaults()
    end

    local defaults = GDTR.GetDefaults()
    for k, v in pairs(defaults) do
        if BeltalowdaVars.ui.groupDamageTimersByRole[k] == nil then
            BeltalowdaVars.ui.groupDamageTimersByRole[k] = v
        end
    end

    -- Ensure nested color tables
    for _, key in ipairs({"subAssaultColor", "subAssaultW2Color", "proxDetColor",
                          "deepFissureColor", "deepFissureW2Color",
                          "blightedBlastbonesColor", "fontColor"}) do
        if type(BeltalowdaVars.ui.groupDamageTimersByRole[key]) ~= "table" then
            BeltalowdaVars.ui.groupDamageTimersByRole[key] = defaults[key]
        end
    end

    -- Migrate old 'positionLocked' to 'preventMovement'
    local saved = BeltalowdaVars.ui.groupDamageTimersByRole
    if saved.preventMovement == nil and saved.positionLocked ~= nil then
        saved.preventMovement = saved.positionLocked
        saved.positionLocked = nil
    end

    GDTR.settings = BeltalowdaVars.ui.groupDamageTimersByRole
end

function GDTR.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.groupDamageTimersByRole = GDTR.settings
end

-- ============================================================================
-- Font Helper
-- ============================================================================

local function MakeFontString(size)
    return "$(MEDIUM_FONT)|" .. tostring(math.floor(size)) .. "|soft-shadow-thin"
end

-- ============================================================================
-- UI Creation
-- ============================================================================

function GDTR.GetEffectiveHeaderHeight()
    if GDTR.settings.hideHeader then
        return 0
    end
    return GDTR.HEADER_HEIGHT
end

--[[ Create a single flat effect bar.

    Layout within 180x22 container:

      +----------------------------------------------+
      |T 6.7 [===============progress bar======] [ic]|
      +----------------------------------------------+

      Left: timer text (left-aligned)
      Middle: progress bar (right-aligned fill, shrinks toward left)
      Right: ability icon (18x18)
      Overlaid: player name (centered, semi-transparent backdrop)
]]
function GDTR.CreateEffectBar(parent, index)
    local bar = {}

    -- Container
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    container:SetDimensions(GDTR.PLAYER_BAR_WIDTH, GDTR.BAR_HEIGHT)
    container:SetHidden(true)

    -- Background
    local backdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    backdrop:SetDimensions(GDTR.PLAYER_BAR_WIDTH, GDTR.BAR_HEIGHT)
    backdrop:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    backdrop:SetEdgeColor(0, 0, 0, 1)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    -- Combat border — drawn ABOVE the progress bar so borders stay visible at full fill
    local combatBorder = wm:CreateControl(nil, container, CT_BACKDROP)
    combatBorder:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    combatBorder:SetDimensions(GDTR.PLAYER_BAR_WIDTH, GDTR.BAR_HEIGHT)
    combatBorder:SetCenterColor(0, 0, 0, 0)
    combatBorder:SetEdgeColor(0, 0, 0, 1)
    combatBorder:SetEdgeTexture(nil, GDTR.COMBAT_BORDER_WIDTH, GDTR.COMBAT_BORDER_WIDTH, GDTR.COMBAT_BORDER_WIDTH, 0)
    combatBorder:SetDrawTier(DT_HIGH)
    combatBorder:SetDrawLevel(0)

    -- Player name label (centered overlay)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    nameLabel:SetFont(MakeFontString(GDTR.ROW_HEIGHT - 4))
    nameLabel:SetText("")
    nameLabel:SetDimensions(GDTR.PLAYER_BAR_WIDTH, GDTR.BAR_HEIGHT)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetColor(GDTR.COLORS.PLAYER_NAME[1], GDTR.COLORS.PLAYER_NAME[2], GDTR.COLORS.PLAYER_NAME[3], 1)
    nameLabel:SetDrawTier(DT_HIGH)
    nameLabel:SetDrawLevel(1)



    -- Ability row: [timer | bar backdrop + progress bar | icon]
    local barWidth = GDTR.PLAYER_BAR_WIDTH - GDTR.ICON_AREA_WIDTH - GDTR.COMBAT_BORDER_WIDTH
    local rowY = GDTR.COMBAT_BORDER_WIDTH

    -- Icon (far right)
    local icon = wm:CreateControl(nil, container, CT_TEXTURE)
    icon:SetAnchor(TOPRIGHT, container, TOPRIGHT, -2, rowY)
    icon:SetDimensions(GDTR.ICON_SIZE, GDTR.ICON_SIZE)
    icon:SetDrawLevel(2)

    -- Bar backdrop
    local barBackdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    barBackdrop:SetAnchor(TOPLEFT, container, TOPLEFT, GDTR.COMBAT_BORDER_WIDTH, rowY)
    barBackdrop:SetDimensions(barWidth, GDTR.ROW_HEIGHT)
    barBackdrop:SetCenterColor(GDTR.COLORS.BAR_BACKDROP[1], GDTR.COLORS.BAR_BACKDROP[2],
        GDTR.COLORS.BAR_BACKDROP[3], GDTR.COLORS.BAR_BACKDROP[4])
    barBackdrop:SetEdgeColor(0, 0, 0, 0)
    barBackdrop:SetDrawLevel(0)

    -- Progress bar (anchored right, fills leftward)
    local statusBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    statusBar:SetAnchor(TOPRIGHT, container, TOPRIGHT, -GDTR.ICON_AREA_WIDTH, rowY)
    statusBar:SetDimensions(barWidth, GDTR.ROW_HEIGHT)
    statusBar:SetBarAlignment(BAR_ALIGNMENT_RIGHT)
    statusBar:SetMinMax(0, 100)
    statusBar:SetValue(0)
    statusBar:SetDrawLevel(1)

    -- Timer label (far left)
    local timer = wm:CreateControl(nil, container, CT_LABEL)
    timer:SetAnchor(LEFT, statusBar, LEFT, 2, 0)
    timer:SetFont(MakeFontString(GDTR.ROW_HEIGHT - 4))
    timer:SetText("")
    timer:SetDimensions(30, GDTR.ROW_HEIGHT)
    timer:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timer:SetColor(1, 1, 1, 1)
    timer:SetDrawLevel(3)

    -- Tooltip
    container:SetMouseEnabled(true)
    container:SetHandler("OnMouseEnter", function(ctrl)
        if bar.playerName then
            InitializeTooltip(InformationTooltip, ctrl, RIGHT, 0, 0)
            local tooltipName = bar.playerName
            if bar.unitTag then
                local charName = GetUnitName(bar.unitTag)
                local acctName = GetUnitDisplayName(bar.unitTag)
                if charName and acctName and acctName ~= "" then
                    tooltipName = string.format("%s (%s)", charName, acctName)
                end
            end
            SetTooltipText(InformationTooltip, tooltipName)
        end
    end)
    container:SetHandler("OnMouseExit", function(ctrl)
        ClearTooltip(InformationTooltip)
    end)

    -- Drag forwarding
    container:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not GDTR.settings.preventMovement then
            GDTR.controls.TLW:StartMoving()
        end
    end)
    container:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            GDTR.controls.TLW:StopMovingOrResizing()
        end
    end)

    -- Store references
    bar.container = container
    bar.backdrop = backdrop
    bar.combatBorder = combatBorder
    bar.nameLabel = nameLabel
    bar.icon = icon
    bar.barBackdrop = barBackdrop
    bar.bar = statusBar
    bar.timer = timer
    bar.playerName = nil
    bar.unitTag = nil

    return bar
end

function GDTR.CreateUI()
    local tlw = wm:CreateTopLevelWindow(GDTR.TLW_NAME)
    tlw:SetClampedToScreen(true)
    tlw:SetDrawLayer(DL_BACKGROUND)
    tlw:SetDrawLevel(1)
    tlw:SetMovable(not GDTR.settings.preventMovement)
    tlw:SetMouseEnabled(true)
    tlw:SetHidden(true)

    local width = GDTR.PLAYER_BAR_WIDTH + (GDTR.WINDOW_PADDING * 2)
    local height = GDTR.GetEffectiveHeaderHeight() + (GDTR.WINDOW_PADDING * 2)
    tlw:SetDimensions(width, height)

    if GDTR.settings.location then
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, GDTR.settings.location.x, GDTR.settings.location.y)
    else
        local screenW, screenH = GuiRoot:GetDimensions()
        local defaultX = math.floor(screenW / 2 + 200)
        local defaultY = math.floor(screenH / 2 - 100)
        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaultX, defaultY)
    end

    tlw:SetHandler("OnMoveStop", function()
        GDTR.settings.location = {
            x = tlw:GetLeft(),
            y = tlw:GetTop(),
        }
        GDTR.SaveSettings()
    end)

    -- Backdrop
    local backdrop = wm:CreateControl(GDTR.TLW_NAME .. "Backdrop", tlw, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
    backdrop:SetDimensions(width, height)
    backdrop:SetDrawLevel(0)
    backdrop:SetCenterColor(1, 0, 0, 0.0)
    backdrop:SetEdgeColor(0, 0, 0, 0)
    backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    -- Coordination quality label
    local coordLabel = wm:CreateControl(GDTR.TLW_NAME .. "CoordLabel", tlw, CT_LABEL)
    coordLabel:SetAnchor(TOP, tlw, TOP, 0, GDTR.WINDOW_PADDING)
    coordLabel:SetFont("ZoFontWinH4")
    coordLabel:SetText("")
    coordLabel:SetColor(1, 1, 0, 1)
    coordLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    coordLabel:SetHidden(GDTR.settings.hideHeader)

    -- Bar container
    local containerY = GDTR.GetEffectiveHeaderHeight() + GDTR.WINDOW_PADDING
    local barContainer = wm:CreateControl(GDTR.TLW_NAME .. "Container", tlw, CT_CONTROL)
    barContainer:SetAnchor(TOPLEFT, tlw, TOPLEFT, GDTR.WINDOW_PADDING, containerY)
    barContainer:SetDimensions(GDTR.PLAYER_BAR_WIDTH, GDTR.BAR_HEIGHT * GDTR.MAX_BARS)

    -- Pre-create effect bars
    local effectBars = {}
    for i = 1, GDTR.MAX_BARS do
        effectBars[i] = GDTR.CreateEffectBar(barContainer, i)
    end

    GDTR.controls.TLW = tlw
    GDTR.controls.backdrop = backdrop
    GDTR.controls.coordLabel = coordLabel
    GDTR.controls.container = barContainer
    GDTR.controls.effectBars = effectBars

    -- Apply scale
    tlw:SetScale(GDTR.settings.scale or 1.0)

    GDTR.SetPreventMovement(GDTR.settings.preventMovement)
end

-- ============================================================================
-- Positioning
-- ============================================================================

function GDTR.SetPreventMovement(value)
    GDTR.settings.preventMovement = value
    local tlw = GDTR.controls.TLW
    if not tlw then return end

    tlw:SetMovable(not value)
    tlw:SetMouseEnabled(true)

    local bd = GDTR.controls.backdrop
    if bd then
        bd:SetCenterColor(0, 0, 0, 0.0)
        bd:SetEdgeColor(0, 0, 0, 0)
    end

    GDTR.SaveSettings()
end

-- ============================================================================
-- Window Resizing
-- ============================================================================

function GDTR.ResizeWindow(totalBarsHeight)
    local tlw = GDTR.controls.TLW
    if not tlw then return end

    local headerH = GDTR.GetEffectiveHeaderHeight()
    local height = headerH + (GDTR.WINDOW_PADDING * 2) + totalBarsHeight
    local width = GDTR.PLAYER_BAR_WIDTH + (GDTR.WINDOW_PADDING * 2)

    tlw:SetDimensions(width, height)
    GDTR.controls.backdrop:SetDimensions(width, height)
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function GDTR.SetEnabled(value)
    if not GDTR.state.initialized or value == nil then return end
    GDTR.settings.enabled = value
    GDTR.SaveSettings()

    if value then
        if not GDTR.state.registeredConsumers then
            EVENT_MANAGER:RegisterForEvent(GDTR.CALLBACK_NAME, EVENT_PLAYER_ACTIVATED, GDTR.OnPlayerActivated)
        end
        GDTR.state.registeredConsumers = true
    else
        if GDTR.state.registeredConsumers then
            EVENT_MANAGER:UnregisterForEvent(GDTR.CALLBACK_NAME, EVENT_PLAYER_ACTIVATED)
        end
        GDTR.state.registeredConsumers = false
    end

    GDTR.OnPlayerActivated()
end

function GDTR.SetControlVisibility()
    local tlw = GDTR.controls.TLW
    if not tlw then return end

    if GDTR.settings.enabled then
        tlw:SetHidden(GDTR.state.menuHidden == true or GDTR.state.pvpHidden == true)
    else
        tlw:SetHidden(true)
    end
end

function GDTR.SetMenuHidden(hidden)
    GDTR.state.menuHidden = hidden
    GDTR.SetControlVisibility()
end

function GDTR.SetPvPHidden(hidden)
    GDTR.state.pvpHidden = hidden
    GDTR.SetControlVisibility()
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

function GDTR.OnPlayerActivated(eventCode, initial)
    if GDTR.settings.enabled then
        if not GDTR.state.registeredActiveConsumers then
            EVENT_MANAGER:RegisterForUpdate(GDTR.CALLBACK_NAME, 100, GDTR.UiLoop)
            GDTR.state.registeredActiveConsumers = true
        end
    else
        if GDTR.state.registeredActiveConsumers then
            EVENT_MANAGER:UnregisterForUpdate(GDTR.CALLBACK_NAME)
            GDTR.state.registeredActiveConsumers = false
        end
    end
    GDTR.SetControlVisibility()
end

-- ============================================================================
-- Buff Scanning (flat per-effect)
-- ============================================================================

--- Scan all group members for tracked abilities and return a flat list of
--- individual effect entries, each representing one (player, ability) pair.
function GDTR.ScanGroupBuffs()
    local groupSize = GetGroupSize()
    local effects = {}
    local now = GetGameTimeMilliseconds() / 1000

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

    for _, unitTag in ipairs(unitTags) do
        local playerName = GetUnitName(unitTag)
        if not playerName or playerName == "" then playerName = unitTag end

        local numBuffs = GetNumBuffs(unitTag)
        for buffIndex = 1, numBuffs do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
                  buffType, effectType, abilityType, statusEffectType, abilityId =
                GetUnitBuffInfo(unitTag, buffIndex)

            if effectType == BUFF_EFFECT_TYPE_BUFF then
                local lookup = GDTR.BUFF_LOOKUP[abilityId]
                if lookup then
                    local abilityDef = GDTR.TRACKED_ABILITIES[lookup.index]
                    local remaining = timeEnding - now
                    local duration = timeEnding - timeStarted
                    if duration <= 0 then duration = abilityDef.fallbackDuration end

                    -- Handle displayDuration (e.g. Blastbones)
                    if abilityDef.displayDuration then
                        local elapsed = now - timeStarted
                        remaining = abilityDef.displayDuration - elapsed
                        duration = abilityDef.displayDuration
                    end

                    if remaining > 0 then
                        table.insert(effects, {
                            name = playerName,
                            unitTag = unitTag,
                            abilityIndex = lookup.index,
                            matchType = lookup.matchType,
                            remaining = remaining,
                            duration = duration,
                            started = timeStarted,
                            ending = timeEnding,
                            waveTwo = (lookup.matchType == "wave2" or lookup.matchType == "variantWave2"),
                            isVariant = (lookup.matchType == "variant" or lookup.matchType == "variantWave2"),
                        })
                    end
                end
            end
        end
    end

    -- Sort by remaining time descending (most time remaining at top = goes off last)
    table.sort(effects, function(a, b)
        if a.remaining ~= b.remaining then return a.remaining > b.remaining end
        if a.name ~= b.name then return a.name < b.name end
        return a.abilityIndex < b.abilityIndex
    end)

    return effects
end

-- ============================================================================
-- Coordination Quality Evaluation
-- ============================================================================

function GDTR.EvaluateCoordination(effects)
    local coord = GDTR.coordination
    coord.quality = "none"
    coord.shalkLandingTime = nil
    coord.proxyActive = false
    coord.shalkCount = 0

    local shalkStartTimes = {}
    local earliestShalkLanding = nil
    local shalkPlayers = {}  -- Track unique players with shalks

    for _, e in ipairs(effects) do
        if e.abilityIndex == GDTR.SHALK_ABILITY_INDEX then
            if not shalkPlayers[e.name] then
                shalkPlayers[e.name] = true
                coord.shalkCount = coord.shalkCount + 1
                table.insert(shalkStartTimes, e.started)
                if not earliestShalkLanding or e.ending < earliestShalkLanding then
                    earliestShalkLanding = e.ending
                end
            end
        elseif e.abilityIndex == GDTR.PROXY_ABILITY_INDEX then
            coord.proxyActive = true
        end
    end

    coord.shalkLandingTime = earliestShalkLanding

    if coord.shalkCount >= GDTR.COORD_MIN_SHALKS and coord.proxyActive then
        table.sort(shalkStartTimes)
        local totalSpread = shalkStartTimes[#shalkStartTimes] - shalkStartTimes[1]

        if totalSpread <= GDTR.COORD_PERFECT_WINDOW then
            coord.quality = "perfect"
        elseif totalSpread <= GDTR.COORD_GOOD_WINDOW then
            coord.quality = "good"
        end
    end
end

-- ============================================================================
-- Color / Icon Resolution
-- ============================================================================

local function ResolveColorKey(abilityDef, effect)
    if abilityDef.hasVariant then
        if effect.isVariant then
            if effect.waveTwo and abilityDef.variantWaveTwoColorKey then
                return abilityDef.variantWaveTwoColorKey
            end
            return abilityDef.variantColorKey or abilityDef.colorKey
        else
            if effect.waveTwo and abilityDef.waveTwoColorKey then
                return abilityDef.waveTwoColorKey
            end
            return abilityDef.colorKey
        end
    else
        if effect.waveTwo and abilityDef.waveTwoColorKey then
            return abilityDef.waveTwoColorKey
        end
        return abilityDef.colorKey
    end
end

local function ResolveIconId(abilityDef, effect)
    if abilityDef.hasVariant and effect.isVariant and abilityDef.variantIconId then
        return abilityDef.variantIconId
    end
    return abilityDef.iconAbilityId
end

-- ============================================================================
-- UI Update Loop (100ms)
-- ============================================================================

function GDTR.UiLoop()
    local effects = GDTR.ScanGroupBuffs()
    local bars = GDTR.controls.effectBars
    local now = GetGameTimeMilliseconds() / 1000
    local sv = GDTR.settings

    -- Evaluate coordination quality
    GDTR.EvaluateCoordination(effects)
    local coord = GDTR.coordination

    -- Update coordination label
    local coordLabel = GDTR.controls.coordLabel
    if coordLabel then
        if GDTR.settings.hideHeader then
            coordLabel:SetHidden(true)
        elseif coord.quality == "perfect" then
            coordLabel:SetText("Perfect timers!")
            coordLabel:SetColor(GDTR.COLORS.HEADER_PERFECT[1], GDTR.COLORS.HEADER_PERFECT[2], GDTR.COLORS.HEADER_PERFECT[3], 1)
            coordLabel:SetHidden(false)
        elseif coord.quality == "good" then
            coordLabel:SetText("Good timers!")
            coordLabel:SetColor(GDTR.COLORS.HEADER_GOOD[1], GDTR.COLORS.HEADER_GOOD[2], GDTR.COLORS.HEADER_GOOD[3], 1)
            coordLabel:SetHidden(false)
        else
            coordLabel:SetText("")
            coordLabel:SetHidden(false)
        end
    end

    local localPlayerName = GetUnitName("player")
    local visibleCount = math.min(#effects, GDTR.MAX_BARS)
    local yAccum = 0

    for i = 1, visibleCount do
        local e = effects[i]
        local bar = bars[i]
        if not bar then break end

        -- Position this bar
        bar.container:ClearAnchors()
        bar.container:SetAnchor(TOPLEFT, GDTR.controls.container, TOPLEFT, 0, yAccum)
        bar.container:SetHidden(false)

        bar.playerName = e.name
        bar.unitTag = e.unitTag

        local isLocalPlayer = (e.name == localPlayerName)
        local abilityDef = GDTR.TRACKED_ABILITIES[e.abilityIndex]

        -- Name display: 1=all, 2=none, 3=mine only
        local nameMode = sv.nameDisplayMode
        local showName = (nameMode == 1) or (nameMode == 3 and isLocalPlayer)

        if showName then
            local displayName = Beltalowda.GetDisplayName(e.unitTag)
            bar.nameLabel:SetText(displayName)
            bar.nameLabel:SetHidden(false)
        else
            bar.nameLabel:SetText("")
            bar.nameLabel:SetHidden(true)
        end

        -- Set bar value and timer
        -- Use common reference duration so bars with equal remaining times
        -- produce equal visual fill (continuous vertical plane on damage bombs).
        local percent = math.min((e.remaining / GDTR.BAR_REFERENCE_DURATION) * 100, 100)
        ZO_StatusBar_SmoothTransition(bar.bar, percent, 100, not sv.smoothTransition)
        bar.timer:SetText(string.format("%.1f", e.remaining))

        -- Set color
        local colorKey = ResolveColorKey(abilityDef, e)
        local c = sv[colorKey]
        if c then
            bar.bar:SetColor(c.r, c.g, c.b)
        end

        -- Set icon
        local iconId = ResolveIconId(abilityDef, e)
        bar.icon:SetTexture(GetAbilityIcon(iconId))

        yAccum = yAccum + GDTR.BAR_HEIGHT + GDTR.BAR_GAP
    end

    -- Hide unused bars
    for i = visibleCount + 1, #bars do
        bars[i].container:SetHidden(true)
        bars[i].playerName = nil
        bars[i].unitTag = nil
    end

    -- Resize window
    local totalH = yAccum
    if visibleCount > 0 then
        totalH = totalH - GDTR.BAR_GAP
    end
    GDTR.ResizeWindow(totalH)
end

-- ============================================================================
-- Initialize
-- ============================================================================

function GDTR.Initialize()
    if GDTR.state.initialized then return end
    GDTR.LoadSettings()
    GDTR.CreateUI()
    GDTR.state.initialized = true
    GDTR.SetEnabled(GDTR.settings.enabled)

    -- Debug: /gdtrdump
    SLASH_COMMANDS["/gdtrdump"] = function()
        local unitTag = "player"
        local numBuffs = GetNumBuffs(unitTag)
        d("|cFFFF00=== GDTR Buff Dump (" .. numBuffs .. " buffs) ===|r")
        for buffIndex = 1, numBuffs do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
                  buffType, effectType, abilityType, statusEffectType, abilityId =
                GetUnitBuffInfo(unitTag, buffIndex)
            local effStr = (effectType == BUFF_EFFECT_TYPE_BUFF) and "BUFF" or "DEBUFF"
            local remaining = timeEnding - (GetGameTimeMilliseconds() / 1000)
            if remaining > 0 and remaining < 30 then
                d(string.format("  [%d] %s | %s | %.1fs | %s", abilityId, buffName, effStr, remaining, tostring(iconFilename)))
            end
        end
    end
end

-- ============================================================================
-- Settings Panel Controls
-- ============================================================================

function GDTR.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFDamage Tracker|r |t24:24:/esoui/art/icons/ability_warden_015_a.dds|t + |t24:24:/esoui/art/icons/ability_ava_proximity_detonation.dds|t",
            tooltip = "Tracks timed damage abilities per group member",
            controls = {
                {
                    type = "description",
                    text = "Tracks group members' timed damage ability countdown timers (|t20:20:/esoui/art/icons/ability_warden_015_a.dds|t Deep Fissure, |t20:20:/esoui/art/icons/ability_ava_proximity_detonation.dds|t Proximity Detonation, |t20:20:/esoui/art/icons/ability_necromancer_002_a.dds|t Blighted Blastbones). Individual bars per tracked effect, sorted by remaining time.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Damage Timer Tracker",
                    tooltip = "Show/hide the damage timer tracker",
                    getFunc = function() return GDTR.settings.enabled end,
                    setFunc = function(value) GDTR.SetEnabled(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Prevent Movement",
                    tooltip = "When enabled, the tracker cannot be dragged. When disabled, click and drag anywhere on the tracker to reposition it.",
                    getFunc = function() return GDTR.settings.preventMovement end,
                    setFunc = function(value) GDTR.SetPreventMovement(value) end,
                    width = "full",
                    default = false,
                },
                {
                    type = "dropdown",
                    name = "Player Name Display",
                    tooltip = "Controls which player names are shown on the tracker bars",
                    choices = { "All names", "No names", "My name only" },
                    getFunc = function()
                        local mode = GDTR.settings.nameDisplayMode
                        if mode == 2 then return "No names"
                        elseif mode == 3 then return "My name only"
                        else return "All names" end
                    end,
                    setFunc = function(value)
                        if value == "No names" then GDTR.settings.nameDisplayMode = 2
                        elseif value == "My name only" then GDTR.settings.nameDisplayMode = 3
                        else GDTR.settings.nameDisplayMode = 1 end
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                    default = "No names",
                },
                {
                    type = "checkbox",
                    name = "Hide Timer Quality",
                    tooltip = "Hide the 'Good timers!' / 'Perfect timers!' coordination messages above the tracker bars",
                    getFunc = function() return GDTR.settings.hideHeader end,
                    setFunc = function(value)
                        GDTR.settings.hideHeader = value
                        if GDTR.controls.coordLabel then
                            GDTR.controls.coordLabel:SetHidden(value)
                        end
                        if GDTR.controls.container then
                            local containerY = GDTR.GetEffectiveHeaderHeight() + GDTR.WINDOW_PADDING
                            GDTR.controls.container:ClearAnchors()
                            GDTR.controls.container:SetAnchor(TOPLEFT, GDTR.controls.TLW, TOPLEFT, GDTR.WINDOW_PADDING, containerY)
                        end
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "slider",
                    name = "Scale",
                    tooltip = "Adjust the overall size of the damage timer tracker (0.5 = half size, 2.0 = double size)",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    decimals = 1,
                    getFunc = function() return GDTR.settings.scale end,
                    setFunc = function(value)
                        GDTR.settings.scale = value
                        if GDTR.controls.TLW then
                            GDTR.controls.TLW:SetScale(value)
                        end
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "checkbox",
                    name = "Smooth Transition",
                    tooltip = "Enable smooth bar transitions so retreating bars form a continuous plane. Disable for snappy updates.",
                    getFunc = function() return GDTR.settings.smoothTransition end,
                    setFunc = function(value)
                        GDTR.settings.smoothTransition = value
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                    default = true,
                },
                -- Color pickers
                {
                    type = "header",
                    name = "Bar Colors",
                },
                {
                    type = "colorpicker",
                    name = "Sub. Assault Bar",
                    getFunc = function()
                        local c = GDTR.settings.subAssaultColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDTR.settings.subAssaultColor = { r = r, g = g, b = b }
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Sub. Assault Wave 2 Bar",
                    getFunc = function()
                        local c = GDTR.settings.subAssaultW2Color
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDTR.settings.subAssaultW2Color = { r = r, g = g, b = b }
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Prox. Detonation Bar",
                    getFunc = function()
                        local c = GDTR.settings.proxDetColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDTR.settings.proxDetColor = { r = r, g = g, b = b }
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Deep Fissure Bar",
                    getFunc = function()
                        local c = GDTR.settings.deepFissureColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDTR.settings.deepFissureColor = { r = r, g = g, b = b }
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Deep Fissure Wave 2 Bar",
                    getFunc = function()
                        local c = GDTR.settings.deepFissureW2Color
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDTR.settings.deepFissureW2Color = { r = r, g = g, b = b }
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                },
                {
                    type = "colorpicker",
                    name = "Blighted Blastbones Bar",
                    getFunc = function()
                        local c = GDTR.settings.blightedBlastbonesColor
                        return c.r, c.g, c.b, 1
                    end,
                    setFunc = function(r, g, b)
                        GDTR.settings.blightedBlastbonesColor = { r = r, g = g, b = b }
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                },
                -- Blastbones cast reminder
                {
                    type = "header",
                    name = "Blastbones Cast Reminder",
                },
                {
                    type = "description",
                    text = "Shows an orange glow on your Blastbones row when group shalks + proxy are coordinated and it's time to cast. Only visible to the local player.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Cast Reminder Glow",
                    tooltip = "Show an orange glow on your Blastbones row when it's time to cast (requires Good or Perfect group timers)",
                    getFunc = function() return GDTR.settings.showBlastbonesHint end,
                    setFunc = function(value)
                        GDTR.settings.showBlastbonesHint = value
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "Cast Window Trigger (seconds)",
                    tooltip = "Show the glow when group shalks have this many seconds remaining. The glow stays for a 1-second window.",
                    min = 3.0,
                    max = 6.0,
                    step = 0.1,
                    decimals = 1,
                    getFunc = function() return GDTR.settings.blastbonesCastWindow end,
                    setFunc = function(value)
                        GDTR.settings.blastbonesCastWindow = value
                        GDTR.SaveSettings()
                    end,
                    width = "full",
                    default = 4.0,
                },
            },
        },
    }
end
