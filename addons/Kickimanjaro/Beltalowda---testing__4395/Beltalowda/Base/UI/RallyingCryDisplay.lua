-- Beltalowda Rallying Cry Display
-- Standalone floating window showing per-player Rallying Cry buff timer bars
-- Auto-shows for RC wearers with opt-in for other group members

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.RallyingCryDisplay = Beltalowda.UI.RallyingCryDisplay or {}

local RCD = Beltalowda.UI.RallyingCryDisplay
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

RCD.RC_SET_ID = 629                    -- Rallying Cry set ID (LibSetDetection)
RCD.RC_BUFF_ABILITY_ID = 166731        -- Rallying Cry proc ability ID
RCD.BUFF_DURATION = 20                 -- Max buff duration in seconds
RCD.MAX_GROUP_SIZE = 24                -- Maximum group members
RCD.FALLBACK_SCAN_INTERVAL_MS = 2000   -- Periodic fallback scan interval
RCD.DISPLAY_REFRESH_INTERVAL_MS = 100  -- UI refresh interval when visible
RCD.ROW_HEIGHT = 22                    -- Height per player row in pixels
RCD.BAR_WIDTH = 180                    -- Per-player bar width (matches damage timers)
RCD.WINDOW_WIDTH = 188                 -- Total window width (BAR_WIDTH + 8 padding)
RCD.TITLE_HEIGHT = 30                  -- Title area height
RCD.BAR_ICON_SIZE = 18                 -- Ability icon on each bar
RCD.BAR_ICON_AREA_WIDTH = 22           -- 18px icon + 2px border + 2px gap
RCD.PROC_RANGE = 12                    -- Rallying Cry effect range in meters
RCD.REAPPLY_COOLDOWN = 15              -- Seconds after application before reapply is possible

-- Rallying Cry scaling values
-- "Each group member affected reduces the Weapon and Spell Damage by 15
--  and Critical Resistance by 83."
RCD.BASE_CRIT_RESIST = 1650
RCD.BASE_WEAPON_SPELL_DAMAGE = 300
RCD.CRIT_RESIST_PER_MEMBER = 83
RCD.WEAPON_SPELL_DAMAGE_PER_MEMBER = 15

-- Colors
RCD.COLORS = {
    BUFF_ACTIVE = { 0.18, 0.65, 0.55, 0.85 },        -- Teal (buff active)
    BUFF_INACTIVE = { 0.18, 0.65, 0.55, 0.15 },      -- Dim teal (no buff)
    PLAYER_NAME = { 1, 1, 1, 1 },                    -- White
    NAME_IN_RANGE = { 0, 1, 0, 1 },                  -- Green (within 12m of wearer)
    NAME_OUT_OF_RANGE = { 1, 0, 0, 1 },              -- Red (beyond 12m)
    NAME_UNKNOWN = { 1, 1, 1, 1 },                   -- White (distance unknown)
    TIMER_TEXT = { 1, 1, 1, 1 },                      -- White
    TITLE_TEXT = { 0.28, 0.57, 1.0, 1.0 },            -- Beltalowda blue
    BAR_BACKDROP = { 0.1, 0.1, 0.1, 0.6 },           -- Dark background
    REAPPLY_TICK = { 1, 1, 1, 0.7 },                  -- White (reapply cooldown marker)
    WINDOW_BACKDROP = { 0, 0, 0, 0.7 },               -- Window background
}

-- ============================================================================
-- Controls & State
-- ============================================================================

RCD.controls = {
    mainWindow = nil,
    backdrop = nil,
    titleLabel = nil,
    playerBlocks = {},
}

RCD.menuHidden = false
RCD.pvpHidden = false
RCD.initialized = false
RCD.displayRefreshRegistered = false
RCD.fallbackScanRegistered = false

-- Buff tracking state: buffState[unitTag] = { endTime, active }
RCD.buffState = {}

-- RC wearer tracking
RCD.rcWearers = {}          -- set of unitTags wearing RC
RCD.localPlayerHasRC = false
RCD.rcDetectedInGroup = false

-- Settings
RCD.settings = {
    enabled = true,
    showWhenGroupHasRC = false,
    showOnlyInCombat = true,
    scale = 1.0,
    positionX = 250,
    positionY = 250,
}

-- Logger
local logger = nil

-- ============================================================================
-- Logging
-- ============================================================================

local function Log(level, message)
    if logger then
        if level == "Debug" then
            logger:Debug(message)
        elseif level == "Info" then
            logger:Info(message)
        elseif level == "Error" then
            logger:Error(message)
        end
    end
end

-- ============================================================================
-- Menu Visibility
-- ============================================================================

function RCD.SetMenuHidden(hidden)
    RCD.menuHidden = hidden
    RCD.UpdateVisibility()
end

function RCD.SetPvPHidden(hidden)
    RCD.pvpHidden = hidden
    RCD.UpdateVisibility()
end

-- ============================================================================
-- Initialization
-- ============================================================================

function RCD.Initialize()
    if RCD.initialized then return end

    -- Create module logger if available
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        logger = Beltalowda.Logger.CreateModuleLogger("RallyingCry")
    end

    RCD.LoadSettings()
    RCD.CreateMainWindow()
    RCD.CreatePlayerBlocks()
    RCD.ApplySettings()

    -- Register for equipment changes via LibSetDetection
    RCD.RegisterEquipmentCallbacks()

    -- Hook into Beltalowda network OnDataChanged for equipment updates
    -- This catches protocol 222 data from remote group members
    if Beltalowda.network and Beltalowda.network.OnDataChanged then
        local originalOnDataChanged = Beltalowda.network.OnDataChanged
        Beltalowda.network.OnDataChanged = function(dataType, unitTag)
            if originalOnDataChanged and type(originalOnDataChanged) == "function" then
                originalOnDataChanged(dataType, unitTag)
            end
            if dataType == "equipment" then
                RCD.OnEquipmentChanged(unitTag)
            end
        end
    end

    -- Register for group membership changes
    EVENT_MANAGER:RegisterForEvent("BeltalowdaRCD", EVENT_GROUP_MEMBER_JOINED, function()
        zo_callLater(function() RCD.OnGroupChanged() end, 500)
    end)
    EVENT_MANAGER:RegisterForEvent("BeltalowdaRCD", EVENT_GROUP_MEMBER_LEFT, function()
        zo_callLater(function() RCD.OnGroupChanged() end, 500)
    end)
    EVENT_MANAGER:RegisterForEvent("BeltalowdaRCD", EVENT_GROUP_UPDATE, function()
        zo_callLater(function() RCD.OnGroupChanged() end, 500)
    end)

    -- Register for combat state changes
    EVENT_MANAGER:RegisterForEvent("BeltalowdaRCD", EVENT_PLAYER_COMBAT_STATE, function()
        RCD.UpdateVisibility()
    end)

    -- Register EVENT_EFFECT_CHANGED for RC buff ability on group members
    EVENT_MANAGER:RegisterForEvent("BeltalowdaRCD_Effect", EVENT_EFFECT_CHANGED,
        function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                 stackCount, iconName, buffType, effectType, abilityType, statusEffectType,
                 unitName, unitId, abilityId, sourceType)
            RCD.OnEffectChanged(changeType, unitTag, endTime, abilityId)
        end)
    EVENT_MANAGER:AddFilterForEvent("BeltalowdaRCD_Effect", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, RCD.RC_BUFF_ABILITY_ID)

    -- Initial RC detection scan
    zo_callLater(function()
        RCD.ScanGroupForRC()
        RCD.FallbackBuffScan()
        RCD.UpdateVisibility()
    end, 2000)

    RCD.initialized = true
    Log("Info", "Rallying Cry Display initialized")
    return true
end

-- ============================================================================
-- Settings Load/Save
-- ============================================================================

function RCD.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.rallyingCry = BeltalowdaVars.ui.rallyingCry or {}

    local saved = BeltalowdaVars.ui.rallyingCry

    RCD.settings.enabled = (saved.enabled ~= nil) and saved.enabled or true
    RCD.settings.showWhenGroupHasRC = (saved.showWhenGroupHasRC ~= nil) and saved.showWhenGroupHasRC or false
    RCD.settings.showOnlyInCombat = (saved.showOnlyInCombat ~= nil) and saved.showOnlyInCombat or true
    RCD.settings.scale = saved.scale or 1.0
    RCD.settings.positionX = saved.positionX or 250
    RCD.settings.positionY = saved.positionY or 250
end

function RCD.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    BeltalowdaVars.ui.rallyingCry = {
        enabled = RCD.settings.enabled,
        showWhenGroupHasRC = RCD.settings.showWhenGroupHasRC,
        showOnlyInCombat = RCD.settings.showOnlyInCombat,
        scale = RCD.settings.scale,
        positionX = RCD.settings.positionX,
        positionY = RCD.settings.positionY,
    }
end

-- ============================================================================
-- Main Window
-- ============================================================================

function RCD.CreateMainWindow()
    local window = wm:GetControlByName("BeltalowdaRallyingCry")
    if window then
        RCD.controls.mainWindow = window
        return
    end

    window = wm:CreateTopLevelWindow("BeltalowdaRallyingCry")
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawLevel(0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(true)
    window:SetDimensions(RCD.WINDOW_WIDTH, RCD.TITLE_HEIGHT)

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RCD.settings.positionX, RCD.settings.positionY)

    window:SetHandler("OnMoveStop", function()
        RCD.OnWindowMoved()
    end)

    -- Backdrop (dark semi-transparent, matching warning indicator style)
    local backdrop = wm:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.05, 0.05, 0.05, 0.7)
    backdrop:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
    backdrop:SetEdgeTexture("", 1, 1, 1)
    backdrop:SetDrawLevel(0)
    backdrop:SetMouseEnabled(true)

    backdrop:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    backdrop:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    window.backdrop = backdrop

    -- Title label (centered)
    local titleLabel = wm:CreateControl(nil, window, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleLabel:SetDimensions(RCD.WINDOW_WIDTH, RCD.TITLE_HEIGHT)
    titleLabel:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
    titleLabel:SetText("Rallying Cry")
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    titleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    titleLabel:SetColor(RCD.COLORS.TITLE_TEXT[1], RCD.COLORS.TITLE_TEXT[2],
        RCD.COLORS.TITLE_TEXT[3], RCD.COLORS.TITLE_TEXT[4])
    RCD.controls.titleLabel = titleLabel

    RCD.controls.mainWindow = window
end

-- ============================================================================
-- Player Blocks (pre-created rows for each group member)
-- ============================================================================

function RCD.CreatePlayerBlocks()
    local mainWindow = RCD.controls.mainWindow
    for i = 1, RCD.MAX_GROUP_SIZE do
        local block = RCD.CreatePlayerBlock(mainWindow, i)
        RCD.controls.playerBlocks[i] = block
    end
end

function RCD.CreatePlayerBlock(parent, index)
    local block = {}

    local yOffset = RCD.TITLE_HEIGHT + (RCD.ROW_HEIGHT * (index - 1))
    local barWidth = RCD.BAR_WIDTH - RCD.BAR_ICON_AREA_WIDTH

    -- Container
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 4, yOffset)
    container:SetDimensions(RCD.BAR_WIDTH, RCD.ROW_HEIGHT)
    container:SetHidden(true)

    -- Bar backdrop (left portion, excluding icon area)
    local barBackdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    barBackdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    barBackdrop:SetDimensions(barWidth, RCD.ROW_HEIGHT)
    barBackdrop:SetCenterColor(RCD.COLORS.BAR_BACKDROP[1], RCD.COLORS.BAR_BACKDROP[2],
        RCD.COLORS.BAR_BACKDROP[3], RCD.COLORS.BAR_BACKDROP[4])
    barBackdrop:SetEdgeColor(0, 0, 0, 0)
    barBackdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    -- Progress bar (right-aligned fill, shrinks toward left)
    local progressBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    progressBar:SetAnchor(TOPRIGHT, container, TOPRIGHT, -RCD.BAR_ICON_AREA_WIDTH, 1)
    progressBar:SetDimensions(barWidth, RCD.ROW_HEIGHT - 2)
    progressBar:SetBarAlignment(BAR_ALIGNMENT_RIGHT)
    progressBar:SetMinMax(0, RCD.BUFF_DURATION * 10)  -- 0.1s precision
    progressBar:SetValue(0)
    progressBar:SetColor(RCD.COLORS.BUFF_INACTIVE[1], RCD.COLORS.BUFF_INACTIVE[2],
        RCD.COLORS.BUFF_INACTIVE[3], RCD.COLORS.BUFF_INACTIVE[4])
    progressBar:SetDrawLevel(1)

    -- Timer label (far left, matching damage timer style)
    local timerLabel = wm:CreateControl(nil, container, CT_LABEL)
    timerLabel:SetAnchor(LEFT, barBackdrop, LEFT, 2, 0)
    timerLabel:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
    timerLabel:SetText("")
    timerLabel:SetDimensions(30, RCD.ROW_HEIGHT)
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timerLabel:SetColor(RCD.COLORS.TIMER_TEXT[1], RCD.COLORS.TIMER_TEXT[2],
        RCD.COLORS.TIMER_TEXT[3], RCD.COLORS.TIMER_TEXT[4])
    timerLabel:SetDrawLevel(5)

    -- Player name label (centered overlay, spanning bar area)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(TOPLEFT, barBackdrop, TOPLEFT, 0, 0)
    nameLabel:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
    nameLabel:SetText("")
    nameLabel:SetDimensions(barWidth, RCD.ROW_HEIGHT)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetColor(RCD.COLORS.PLAYER_NAME[1], RCD.COLORS.PLAYER_NAME[2],
        RCD.COLORS.PLAYER_NAME[3], RCD.COLORS.PLAYER_NAME[4])
    nameLabel:SetDrawLevel(5)

    -- Reapply cooldown tick mark (vertical line at 5s remaining = 15s after application)
    -- Bar recedes from the right; 5s remaining = 25% fill on the left side
    local reapplyTickFraction = (RCD.BUFF_DURATION - RCD.REAPPLY_COOLDOWN) / RCD.BUFF_DURATION
    local tickXOffset = math.floor(barWidth * (1 - reapplyTickFraction))
    local reapplyTick = wm:CreateControl(nil, container, CT_BACKDROP)
    reapplyTick:SetAnchor(TOPLEFT, barBackdrop, TOPRIGHT, -tickXOffset, 2)
    reapplyTick:SetDimensions(2, RCD.ROW_HEIGHT - 4)
    reapplyTick:SetCenterColor(RCD.COLORS.REAPPLY_TICK[1], RCD.COLORS.REAPPLY_TICK[2],
        RCD.COLORS.REAPPLY_TICK[3], RCD.COLORS.REAPPLY_TICK[4])
    reapplyTick:SetEdgeColor(0, 0, 0, 0)
    reapplyTick:SetEdgeTexture(nil, 1, 1, 1, 0)
    reapplyTick:SetDrawLevel(3)
    reapplyTick:SetHidden(true)

    -- Buff icon (far right)
    local buffIcon = wm:CreateControl(nil, container, CT_TEXTURE)
    buffIcon:SetAnchor(TOPRIGHT, container, TOPRIGHT, -2, (RCD.ROW_HEIGHT - RCD.BAR_ICON_SIZE) / 2)
    buffIcon:SetDimensions(RCD.BAR_ICON_SIZE, RCD.BAR_ICON_SIZE)
    local iconTexture = GetAbilityIcon(RCD.RC_BUFF_ABILITY_ID)
    buffIcon:SetTexture(iconTexture or "/esoui/art/icons/ability_healer_005.dds")
    buffIcon:SetDrawLevel(2)

    -- Mouse: forward drag events to window, keep tooltip support
    container:SetMouseEnabled(true)
    container:SetHandler("OnMouseDown", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            parent:StartMoving()
        end
    end)
    container:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            parent:StopMovingOrResizing()
        end
    end)
    container:SetHandler("OnMouseEnter", function(ctrl)
        if block.unitTag then
            InitializeTooltip(InformationTooltip, ctrl, RIGHT, 5, 0)
            local charName = GetUnitName(block.unitTag) or ""
            local acctName = GetUnitDisplayName(block.unitTag) or ""
            local remaining = block.remaining or 0
            local status = remaining > 0 and string.format("%.1fs remaining", remaining) or "Inactive"

            -- Count active buffs for scaling calculation
            local activeCount = RCD.GetActiveBuffCount()
            local critResist = math.max(0, RCD.BASE_CRIT_RESIST - (activeCount * RCD.CRIT_RESIST_PER_MEMBER))
            local weapSpellDmg = math.max(0, RCD.BASE_WEAPON_SPELL_DAMAGE - (activeCount * RCD.WEAPON_SPELL_DAMAGE_PER_MEMBER))

            local tooltipText = string.format(
                "%s (%s)\nRallying Cry: %s\nAffected: %d members\nCritical Resistance: %d\nWeapon & Spell Damage: %d",
                charName, acctName, status, activeCount, critResist, weapSpellDmg)
            SetTooltipText(InformationTooltip, tooltipText)
        end
    end)
    container:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    block.container = container
    block.barBackdrop = barBackdrop
    block.progressBar = progressBar
    block.nameLabel = nameLabel
    block.timerLabel = timerLabel
    block.buffIcon = buffIcon
    block.reapplyTick = reapplyTick
    block.unitTag = nil
    block.remaining = 0

    return block
end

-- ============================================================================
-- Equipment Detection (LibSetDetection)
-- ============================================================================

function RCD.RegisterEquipmentCallbacks()
    local LSD = LibSetDetection
    if not LSD then
        Log("Error", "LibSetDetection not available")
        return
    end

    LSD.RegisterEvent(LSD_EVENT_DATA_UPDATE, "BeltalowdaRCD_Equipment", function(unitTag)
        RCD.OnEquipmentChanged(unitTag)
    end, LSD_UNIT_TYPE_ALL)
end

function RCD.OnEquipmentChanged(unitTag)
    RCD.ScanGroupForRC()
    RCD.UpdateVisibility()
end

-- Check if a unit has a specific set via LSD directly or Beltalowda network data
local function UnitHasSet(unitTag, setId)
    -- Primary: LibSetDetection direct query
    local LSD = LibSetDetection
    if LSD then
        local setData = LSD.GetUnitSetData(unitTag)
        if setData and setData[setId] then
            return true
        end
    end

    -- Fallback: Beltalowda network equipment data (protocol 222)
    if Beltalowda.network and Beltalowda.network.GetEquipmentData then
        local equipData = Beltalowda.network.GetEquipmentData(unitTag)
        if equipData and equipData.usefulBits and equipData.usefulBits.sets then
            for _, setInfo in ipairs(equipData.usefulBits.sets) do
                if setInfo.id == setId then
                    return true
                end
            end
        end
    end

    return false
end

function RCD.ScanGroupForRC()
    RCD.rcWearers = {}
    RCD.localPlayerHasRC = false
    RCD.rcDetectedInGroup = false

    local groupSize = GetGroupSize()
    if groupSize == 0 then
        -- Solo: check player only
        if UnitHasSet("player", RCD.RC_SET_ID) then
            RCD.localPlayerHasRC = true
            RCD.rcDetectedInGroup = true
            RCD.rcWearers["player"] = true
        end
        return
    end

    for i = 1, groupSize do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            if UnitHasSet(unitTag, RCD.RC_SET_ID) then
                RCD.rcWearers[unitTag] = true
                RCD.rcDetectedInGroup = true
                if AreUnitsEqual("player", unitTag) then
                    RCD.localPlayerHasRC = true
                end
            end
        end
    end
end

-- ============================================================================
-- Buff Tracking
-- ============================================================================

function RCD.GetActiveBuffCount()
    local now = GetGameTimeSeconds()
    local count = 0
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        local state = RCD.buffState["player"]
        if state and state.active and state.endTime and state.endTime > now then
            return 1
        end
        return 0
    end
    for i = 1, groupSize do
        local state = RCD.buffState["group" .. i]
        if state and state.active and state.endTime and state.endTime > now then
            count = count + 1
        end
    end
    return count
end

-- Normalize unitTag to the canonical group tag.
-- EVENT_EFFECT_CHANGED may fire with "player", "companion1", etc. in
-- addition to the "groupN" tag for the same person.  We store buff
-- state keyed by group tag so each person has exactly one entry.
local function NormalizeUnitTag(unitTag)
    local groupSize = GetGroupSize()
    if groupSize == 0 then return unitTag end
    for i = 1, groupSize do
        local groupTag = "group" .. i
        if AreUnitsEqual(unitTag, groupTag) then
            return groupTag
        end
    end
    return nil  -- not a group member (pet, companion, etc.)
end

function RCD.OnEffectChanged(changeType, unitTag, endTime, abilityId)
    if abilityId ~= RCD.RC_BUFF_ABILITY_ID then return end
    if not unitTag or unitTag == "" then return end

    unitTag = NormalizeUnitTag(unitTag)
    if not unitTag then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        RCD.buffState[unitTag] = {
            endTime = endTime,
            active = true,
        }
    elseif changeType == EFFECT_RESULT_FADED then
        RCD.buffState[unitTag] = {
            endTime = 0,
            active = false,
        }
    end
end

function RCD.FallbackBuffScan()
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        -- Solo: scan player
        RCD.ScanUnitBuffs("player")
        return
    end

    for i = 1, groupSize do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            RCD.ScanUnitBuffs(unitTag)
        end
    end
end

function RCD.ScanUnitBuffs(unitTag)
    local numBuffs = GetNumBuffs(unitTag)
    local found = false
    for i = 1, numBuffs do
        local _, _, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
        if abilityId == RCD.RC_BUFF_ABILITY_ID then
            RCD.buffState[unitTag] = {
                endTime = endTime,
                active = true,
            }
            found = true
            break
        end
    end
    -- Only clear if event hasn't already set an active state with a future endTime
    if not found then
        local existing = RCD.buffState[unitTag]
        if not existing or not existing.active or (existing.endTime and existing.endTime <= GetGameTimeSeconds()) then
            RCD.buffState[unitTag] = {
                endTime = 0,
                active = false,
            }
        end
    end
end

-- ============================================================================
-- Group Change Handling
-- ============================================================================

function RCD.OnGroupChanged()
    -- Clean up buff state for units that no longer exist
    local validTags = {}
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        validTags["player"] = true
    else
        for i = 1, groupSize do
            validTags["group" .. i] = true
        end
    end

    for unitTag, _ in pairs(RCD.buffState) do
        if not validTags[unitTag] then
            RCD.buffState[unitTag] = nil
        end
    end

    RCD.ScanGroupForRC()
    RCD.FallbackBuffScan()
    RCD.UpdateVisibility()
end

-- ============================================================================
-- Visibility Management
-- ============================================================================

function RCD.ShouldBeVisible()
    if not RCD.settings.enabled then return false end
    if RCD.menuHidden then return false end
    if RCD.pvpHidden then return false end
    if GetGroupSize() == 0 then return false end

    -- Combat-only check
    if RCD.settings.showOnlyInCombat and not IsUnitInCombat("player") then
        return false
    end

    -- Auto-show for RC wearers
    if RCD.localPlayerHasRC then return true end

    -- Opt-in for non-RC wearers when RC is detected in group
    if RCD.settings.showWhenGroupHasRC and RCD.rcDetectedInGroup then return true end

    return false
end

function RCD.UpdateVisibility()
    local shouldShow = RCD.ShouldBeVisible()

    if shouldShow then
        RCD.StartDisplayRefresh()
        RCD.StartFallbackScan()
        if RCD.controls.mainWindow then
            RCD.controls.mainWindow:SetHidden(false)
        end
    else
        RCD.StopDisplayRefresh()
        RCD.StopFallbackScan()
        if RCD.controls.mainWindow then
            RCD.controls.mainWindow:SetHidden(true)
        end
    end
end

function RCD.StartDisplayRefresh()
    if RCD.displayRefreshRegistered then return end
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaRCD_Display", RCD.DISPLAY_REFRESH_INTERVAL_MS, function()
        RCD.RefreshDisplay()
    end)
    RCD.displayRefreshRegistered = true
end

function RCD.StopDisplayRefresh()
    if not RCD.displayRefreshRegistered then return end
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaRCD_Display")
    RCD.displayRefreshRegistered = false
end

function RCD.StartFallbackScan()
    if RCD.fallbackScanRegistered then return end
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaRCD_Fallback", RCD.FALLBACK_SCAN_INTERVAL_MS, function()
        RCD.FallbackBuffScan()
    end)
    RCD.fallbackScanRegistered = true
end

function RCD.StopFallbackScan()
    if not RCD.fallbackScanRegistered then return end
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaRCD_Fallback")
    RCD.fallbackScanRegistered = false
end

-- ============================================================================
-- Display Refresh
-- ============================================================================

function RCD.RefreshDisplay()
    if not RCD.settings.enabled or RCD.menuHidden or RCD.pvpHidden then return end

    local window = RCD.controls.mainWindow
    if not window or window:IsHidden() then return end

    local now = GetGameTimeSeconds()
    local visibleCount = 0
    local groupSize = GetGroupSize()

    -- Collect world positions of all RC wearers for distance checks
    local wearerPositions = {}
    for wearerTag, _ in pairs(RCD.rcWearers) do
        local _, rx, ry, rz = GetUnitRawWorldPosition(wearerTag)
        if rx and rx ~= 0 then
            wearerPositions[#wearerPositions + 1] = { x = rx, y = ry, z = rz }
        end
    end

    for i = 1, groupSize do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            visibleCount = visibleCount + 1
            local block = RCD.controls.playerBlocks[visibleCount]
            if block then
                block.unitTag = unitTag
                block.container:SetHidden(false)

                -- Update player name
                local displayName = Beltalowda.GetDisplayName(unitTag)
                block.nameLabel:SetText(displayName)

                -- Distance-based name coloring
                local nameColor = RCD.COLORS.NAME_UNKNOWN
                local isWearer = RCD.rcWearers[unitTag]
                if isWearer then
                    -- Wearers are always "in range" of themselves
                    nameColor = RCD.COLORS.NAME_IN_RANGE
                elseif #wearerPositions > 0 then
                    local _, ux, uy, uz = GetUnitRawWorldPosition(unitTag)
                    if ux and ux ~= 0 then
                        local minDist = math.huge
                        for _, wp in ipairs(wearerPositions) do
                            local dx = (ux - wp.x) / 100
                            local dy = (uy - wp.y) / 100
                            local dz = (uz - wp.z) / 100
                            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                            if dist < minDist then minDist = dist end
                        end
                        if minDist <= RCD.PROC_RANGE then
                            nameColor = RCD.COLORS.NAME_IN_RANGE
                        else
                            nameColor = RCD.COLORS.NAME_OUT_OF_RANGE
                        end
                    end
                end
                block.nameLabel:SetColor(nameColor[1], nameColor[2], nameColor[3], nameColor[4])

                -- Update buff status
                local state = RCD.buffState[unitTag]
                local remaining = 0
                local active = false

                if state and state.active and state.endTime then
                    remaining = state.endTime - now
                    if remaining < 0 then
                        remaining = 0
                        active = false
                        state.active = false
                    else
                        active = true
                    end
                end

                block.remaining = remaining

                -- Update progress bar
                block.progressBar:SetValue(remaining * 10)

                -- Update bar color
                if active then
                    block.progressBar:SetColor(RCD.COLORS.BUFF_ACTIVE[1], RCD.COLORS.BUFF_ACTIVE[2],
                        RCD.COLORS.BUFF_ACTIVE[3], RCD.COLORS.BUFF_ACTIVE[4])
                else
                    block.progressBar:SetColor(RCD.COLORS.BUFF_INACTIVE[1], RCD.COLORS.BUFF_INACTIVE[2],
                        RCD.COLORS.BUFF_INACTIVE[3], RCD.COLORS.BUFF_INACTIVE[4])
                end

                -- Update timer text
                if active and remaining > 0 then
                    block.timerLabel:SetText(string.format("%.1f", remaining))
                else
                    block.timerLabel:SetText("")
                end

                -- Show reapply tick mark only for wearers with an active buff
                block.reapplyTick:SetHidden(not (isWearer and active))
            end
        end
    end

    -- Hide unused blocks
    for i = visibleCount + 1, RCD.MAX_GROUP_SIZE do
        local block = RCD.controls.playerBlocks[i]
        if block then
            block.container:SetHidden(true)
            block.unitTag = nil
        end
    end

    -- Resize window to fit content (4px bottom padding to match top gap)
    local totalHeight = RCD.TITLE_HEIGHT + (RCD.ROW_HEIGHT * visibleCount) + 4
    window:SetDimensions(RCD.WINDOW_WIDTH, totalHeight)
end

-- ============================================================================
-- Apply Settings
-- ============================================================================

function RCD.ApplySettings()
    local window = RCD.controls.mainWindow
    if not window then return end

    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetScale(RCD.settings.scale)

    RCD.UpdateVisibility()
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

function RCD.OnWindowMoved()
    local window = RCD.controls.mainWindow
    if not window then return end

    local left = window:GetLeft()
    local top = window:GetTop()
    if left and top then
        RCD.settings.positionX = left
        RCD.settings.positionY = top
        RCD.SaveSettings()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

function RCD.SetEnabled(enabled)
    RCD.settings.enabled = enabled
    RCD.SaveSettings()
    RCD.ApplySettings()

    if enabled then
        RCD.ScanGroupForRC()
        RCD.FallbackBuffScan()
    end
end

-- ============================================================================
-- Defaults & Settings Panel
-- ============================================================================

function RCD.GetDefaults()
    return {
        enabled = true,
        showWhenGroupHasRC = false,
        showOnlyInCombat = true,
        scale = 1.0,
        positionX = 250,
        positionY = 250,
    }
end

function RCD.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFRallying Cry|r |t24:24:" .. (GetAbilityIcon(RCD.RC_BUFF_ABILITY_ID) or "") .. "|t",
            tooltip = "Track Rallying Cry buff uptime across group members",
            controls = {
                {
                    type = "description",
                    text = "Displays a floating window showing Rallying Cry buff timers for all group members. Auto-shows when you are wearing Rallying Cry. Inspired by Hyperioxes' Powerful Assault Tracker.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Rallying Cry",
                    tooltip = "Show the Rallying Cry buff tracker window",
                    getFunc = function() return RCD.settings.enabled end,
                    setFunc = function(value) RCD.SetEnabled(value) end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Show When Group Has RC",
                    tooltip = "Show the tracker even if you are not wearing Rallying Cry, as long as someone in your group is.",
                    getFunc = function() return RCD.settings.showWhenGroupHasRC end,
                    setFunc = function(value)
                        RCD.settings.showWhenGroupHasRC = value
                        RCD.SaveSettings()
                        RCD.UpdateVisibility()
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Show Only In Combat",
                    tooltip = "Only show the tracker during combat",
                    getFunc = function() return RCD.settings.showOnlyInCombat end,
                    setFunc = function(value)
                        RCD.settings.showOnlyInCombat = value
                        RCD.SaveSettings()
                        RCD.UpdateVisibility()
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the Rallying Cry tracker window",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function() return RCD.settings.scale end,
                    setFunc = function(value)
                        RCD.settings.scale = value
                        RCD.ApplySettings()
                        RCD.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "button",
                    name = "Reset Position",
                    tooltip = "Reset the tracker window position to default",
                    func = function()
                        RCD.settings.positionX = 250
                        RCD.settings.positionY = 250
                        if RCD.controls.mainWindow then
                            RCD.controls.mainWindow:ClearAnchors()
                            RCD.controls.mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 250, 250)
                        end
                        RCD.SaveSettings()
                    end,
                    width = "full",
                },
            },
        },
    }
end
