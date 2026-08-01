-- Beltalowda Powerful Assault Display
-- Standalone floating window showing per-player Powerful Assault buff timer bars
-- Auto-shows for PA wearers with opt-in for other group members

Beltalowda = Beltalowda or {}
Beltalowda.UI = Beltalowda.UI or {}
Beltalowda.UI.PowerfulAssaultDisplay = Beltalowda.UI.PowerfulAssaultDisplay or {}

local PAD = Beltalowda.UI.PowerfulAssaultDisplay
local wm = WINDOW_MANAGER

-- ============================================================================
-- Constants
-- ============================================================================

PAD.PA_SET_ID = 180                    -- Powerful Assault set ID (LibSetDetection)
PAD.PA_BUFF_ABILITY_ID = 61771         -- Powerful Assault proc ability ID
PAD.BUFF_DURATION = 15                 -- Max buff duration in seconds
PAD.MAX_GROUP_SIZE = 24                -- Maximum group members
PAD.FALLBACK_SCAN_INTERVAL_MS = 2000   -- Periodic fallback scan interval
PAD.DISPLAY_REFRESH_INTERVAL_MS = 100  -- UI refresh interval when visible
PAD.ROW_HEIGHT = 22                    -- Height per player row in pixels
PAD.BAR_WIDTH = 180                    -- Per-player bar width (matches damage timers)
PAD.WINDOW_WIDTH = 188                 -- Total window width (BAR_WIDTH + 8 padding)
PAD.TITLE_HEIGHT = 30                  -- Title area height
PAD.BAR_ICON_SIZE = 18                 -- Ability icon on each bar
PAD.BAR_ICON_AREA_WIDTH = 22           -- 18px icon + 2px border + 2px gap
PAD.PROC_RANGE = 12                    -- Powerful Assault effect range in meters

-- Colors
PAD.COLORS = {
    BUFF_ACTIVE = { 0.72, 0.52, 0.18, 0.85 },        -- Muted amber (buff active)
    BUFF_INACTIVE = { 0.72, 0.52, 0.18, 0.15 },      -- Dim amber (no buff)
    PLAYER_NAME = { 1, 1, 1, 1 },                    -- White
    NAME_IN_RANGE = { 0, 1, 0, 1 },                  -- Green (within 12m of wearer)
    NAME_OUT_OF_RANGE = { 1, 0, 0, 1 },              -- Red (beyond 12m)
    NAME_UNKNOWN = { 1, 1, 1, 1 },                   -- White (distance unknown)
    TIMER_TEXT = { 1, 1, 1, 1 },                      -- White
    TITLE_TEXT = { 0.28, 0.57, 1.0, 1.0 },            -- Beltalowda blue
    BAR_BACKDROP = { 0.1, 0.1, 0.1, 0.6 },           -- Dark background
    WINDOW_BACKDROP = { 0, 0, 0, 0.7 },               -- Window background
}

-- ============================================================================
-- Controls & State
-- ============================================================================

PAD.controls = {
    mainWindow = nil,
    backdrop = nil,
    titleLabel = nil,
    playerBlocks = {},
}

PAD.menuHidden = false
PAD.pvpHidden = false
PAD.initialized = false
PAD.displayRefreshRegistered = false
PAD.fallbackScanRegistered = false

-- Buff tracking state: buffState[unitTag] = { endTime, active }
PAD.buffState = {}

-- PA wearer tracking
PAD.paWearers = {}          -- set of unitTags wearing PA
PAD.localPlayerHasPA = false
PAD.paDetectedInGroup = false

-- Settings
PAD.settings = {
    enabled = true,
    showWhenGroupHasPA = false,
    showOnlyInCombat = true,
    scale = 1.0,
    positionX = 200,
    positionY = 200,
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

function PAD.SetMenuHidden(hidden)
    PAD.menuHidden = hidden
    PAD.UpdateVisibility()
end

function PAD.SetPvPHidden(hidden)
    PAD.pvpHidden = hidden
    PAD.UpdateVisibility()
end

-- ============================================================================
-- Initialization
-- ============================================================================

function PAD.Initialize()
    if PAD.initialized then return end

    -- Create module logger if available
    if Beltalowda.Logger and Beltalowda.Logger.CreateModuleLogger then
        logger = Beltalowda.Logger.CreateModuleLogger("PowerfulAssault")
    end

    PAD.LoadSettings()
    PAD.CreateMainWindow()
    PAD.CreatePlayerBlocks()
    PAD.ApplySettings()

    -- Register for equipment changes via LibSetDetection
    PAD.RegisterEquipmentCallbacks()

    -- Hook into Beltalowda network OnDataChanged for equipment updates
    -- This catches protocol 222 data from remote group members
    if Beltalowda.network and Beltalowda.network.OnDataChanged then
        local originalOnDataChanged = Beltalowda.network.OnDataChanged
        Beltalowda.network.OnDataChanged = function(dataType, unitTag)
            if originalOnDataChanged and type(originalOnDataChanged) == "function" then
                originalOnDataChanged(dataType, unitTag)
            end
            if dataType == "equipment" then
                PAD.OnEquipmentChanged(unitTag)
            end
        end
    end

    -- Register for group membership changes
    EVENT_MANAGER:RegisterForEvent("BeltalowdaPAD", EVENT_GROUP_MEMBER_JOINED, function()
        zo_callLater(function() PAD.OnGroupChanged() end, 500)
    end)
    EVENT_MANAGER:RegisterForEvent("BeltalowdaPAD", EVENT_GROUP_MEMBER_LEFT, function()
        zo_callLater(function() PAD.OnGroupChanged() end, 500)
    end)
    EVENT_MANAGER:RegisterForEvent("BeltalowdaPAD", EVENT_GROUP_UPDATE, function()
        zo_callLater(function() PAD.OnGroupChanged() end, 500)
    end)

    -- Register for combat state changes
    EVENT_MANAGER:RegisterForEvent("BeltalowdaPAD", EVENT_PLAYER_COMBAT_STATE, function()
        PAD.UpdateVisibility()
    end)

    -- Register EVENT_EFFECT_CHANGED for PA buff ability on group members
    EVENT_MANAGER:RegisterForEvent("BeltalowdaPAD_Effect", EVENT_EFFECT_CHANGED,
        function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                 stackCount, iconName, buffType, effectType, abilityType, statusEffectType,
                 unitName, unitId, abilityId, sourceType)
            PAD.OnEffectChanged(changeType, unitTag, endTime, abilityId)
        end)
    EVENT_MANAGER:AddFilterForEvent("BeltalowdaPAD_Effect", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, PAD.PA_BUFF_ABILITY_ID)

    -- Initial PA detection scan
    zo_callLater(function()
        PAD.ScanGroupForPA()
        PAD.FallbackBuffScan()
        PAD.UpdateVisibility()
    end, 2000)

    PAD.initialized = true
    Log("Info", "Powerful Assault Display initialized")
    return true
end

-- ============================================================================
-- Settings Load/Save
-- ============================================================================

function PAD.LoadSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}
    BeltalowdaVars.ui.powerfulAssault = BeltalowdaVars.ui.powerfulAssault or {}

    local saved = BeltalowdaVars.ui.powerfulAssault

    PAD.settings.enabled = (saved.enabled ~= nil) and saved.enabled or true
    PAD.settings.showWhenGroupHasPA = (saved.showWhenGroupHasPA ~= nil) and saved.showWhenGroupHasPA or false
    PAD.settings.showOnlyInCombat = (saved.showOnlyInCombat ~= nil) and saved.showOnlyInCombat or true
    PAD.settings.scale = saved.scale or 1.0
    PAD.settings.positionX = saved.positionX or 200
    PAD.settings.positionY = saved.positionY or 200
end

function PAD.SaveSettings()
    BeltalowdaVars = BeltalowdaVars or {}
    BeltalowdaVars.ui = BeltalowdaVars.ui or {}

    BeltalowdaVars.ui.powerfulAssault = {
        enabled = PAD.settings.enabled,
        showWhenGroupHasPA = PAD.settings.showWhenGroupHasPA,
        showOnlyInCombat = PAD.settings.showOnlyInCombat,
        scale = PAD.settings.scale,
        positionX = PAD.settings.positionX,
        positionY = PAD.settings.positionY,
    }
end

-- ============================================================================
-- Main Window
-- ============================================================================

function PAD.CreateMainWindow()
    local window = wm:GetControlByName("BeltalowdaPowerfulAssault")
    if window then
        PAD.controls.mainWindow = window
        return
    end

    window = wm:CreateTopLevelWindow("BeltalowdaPowerfulAssault")
    window:SetClampedToScreen(true)
    window:SetDrawLayer(DL_BACKGROUND)
    window:SetDrawLevel(0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetHidden(true)
    window:SetDimensions(PAD.WINDOW_WIDTH, PAD.TITLE_HEIGHT)

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PAD.settings.positionX, PAD.settings.positionY)

    window:SetHandler("OnMoveStop", function()
        PAD.OnWindowMoved()
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
    titleLabel:SetDimensions(PAD.WINDOW_WIDTH, PAD.TITLE_HEIGHT)
    titleLabel:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
    titleLabel:SetText("Powerful Assault")
    titleLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    titleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    titleLabel:SetColor(PAD.COLORS.TITLE_TEXT[1], PAD.COLORS.TITLE_TEXT[2],
        PAD.COLORS.TITLE_TEXT[3], PAD.COLORS.TITLE_TEXT[4])
    PAD.controls.titleLabel = titleLabel

    PAD.controls.mainWindow = window
end

-- ============================================================================
-- Player Blocks (pre-created rows for each group member)
-- ============================================================================

function PAD.CreatePlayerBlocks()
    local mainWindow = PAD.controls.mainWindow
    for i = 1, PAD.MAX_GROUP_SIZE do
        local block = PAD.CreatePlayerBlock(mainWindow, i)
        PAD.controls.playerBlocks[i] = block
    end
end

function PAD.CreatePlayerBlock(parent, index)
    local block = {}

    local yOffset = PAD.TITLE_HEIGHT + (PAD.ROW_HEIGHT * (index - 1))
    local barWidth = PAD.BAR_WIDTH - PAD.BAR_ICON_AREA_WIDTH

    -- Container
    local container = wm:CreateControl(nil, parent, CT_CONTROL)
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 4, yOffset)
    container:SetDimensions(PAD.BAR_WIDTH, PAD.ROW_HEIGHT)
    container:SetHidden(true)

    -- Bar backdrop (left portion, excluding icon area)
    local barBackdrop = wm:CreateControl(nil, container, CT_BACKDROP)
    barBackdrop:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    barBackdrop:SetDimensions(barWidth, PAD.ROW_HEIGHT)
    barBackdrop:SetCenterColor(PAD.COLORS.BAR_BACKDROP[1], PAD.COLORS.BAR_BACKDROP[2],
        PAD.COLORS.BAR_BACKDROP[3], PAD.COLORS.BAR_BACKDROP[4])
    barBackdrop:SetEdgeColor(0, 0, 0, 0)
    barBackdrop:SetEdgeTexture(nil, 1, 1, 1, 0)

    -- Progress bar (right-aligned fill, shrinks toward left)
    local progressBar = wm:CreateControl(nil, container, CT_STATUSBAR)
    progressBar:SetAnchor(TOPRIGHT, container, TOPRIGHT, -PAD.BAR_ICON_AREA_WIDTH, 1)
    progressBar:SetDimensions(barWidth, PAD.ROW_HEIGHT - 2)
    progressBar:SetBarAlignment(BAR_ALIGNMENT_RIGHT)
    progressBar:SetMinMax(0, PAD.BUFF_DURATION * 10)  -- 0.1s precision
    progressBar:SetValue(0)
    progressBar:SetColor(PAD.COLORS.BUFF_INACTIVE[1], PAD.COLORS.BUFF_INACTIVE[2],
        PAD.COLORS.BUFF_INACTIVE[3], PAD.COLORS.BUFF_INACTIVE[4])
    progressBar:SetDrawLevel(1)

    -- Timer label (far left, matching damage timer style)
    local timerLabel = wm:CreateControl(nil, container, CT_LABEL)
    timerLabel:SetAnchor(LEFT, barBackdrop, LEFT, 2, 0)
    timerLabel:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
    timerLabel:SetText("")
    timerLabel:SetDimensions(30, PAD.ROW_HEIGHT)
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    timerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    timerLabel:SetColor(PAD.COLORS.TIMER_TEXT[1], PAD.COLORS.TIMER_TEXT[2],
        PAD.COLORS.TIMER_TEXT[3], PAD.COLORS.TIMER_TEXT[4])
    timerLabel:SetDrawLevel(5)

    -- Player name label (centered overlay, spanning bar area)
    local nameLabel = wm:CreateControl(nil, container, CT_LABEL)
    nameLabel:SetAnchor(TOPLEFT, barBackdrop, TOPLEFT, 0, 0)
    nameLabel:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thin")
    nameLabel:SetText("")
    nameLabel:SetDimensions(barWidth, PAD.ROW_HEIGHT)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameLabel:SetColor(PAD.COLORS.PLAYER_NAME[1], PAD.COLORS.PLAYER_NAME[2],
        PAD.COLORS.PLAYER_NAME[3], PAD.COLORS.PLAYER_NAME[4])
    nameLabel:SetDrawLevel(5)

    -- Buff icon (far right)
    local buffIcon = wm:CreateControl(nil, container, CT_TEXTURE)
    buffIcon:SetAnchor(TOPRIGHT, container, TOPRIGHT, -2, (PAD.ROW_HEIGHT - PAD.BAR_ICON_SIZE) / 2)
    buffIcon:SetDimensions(PAD.BAR_ICON_SIZE, PAD.BAR_ICON_SIZE)
    local iconTexture = GetAbilityIcon(PAD.PA_BUFF_ABILITY_ID)
    buffIcon:SetTexture(iconTexture or "/esoui/art/icons/ability_healer_019.dds")
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
            SetTooltipText(InformationTooltip, string.format("%s (%s)\nPowerful Assault: %s", charName, acctName, status))
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
    block.unitTag = nil
    block.remaining = 0

    return block
end

-- ============================================================================
-- Equipment Detection (LibSetDetection)
-- ============================================================================

function PAD.RegisterEquipmentCallbacks()
    local LSD = LibSetDetection
    if not LSD then
        Log("Error", "LibSetDetection not available")
        return
    end

    LSD.RegisterEvent(LSD_EVENT_DATA_UPDATE, "BeltalowdaPAD_Equipment", function(unitTag)
        PAD.OnEquipmentChanged(unitTag)
    end, LSD_UNIT_TYPE_ALL)
end

function PAD.OnEquipmentChanged(unitTag)
    PAD.ScanGroupForPA()
    PAD.UpdateVisibility()
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

function PAD.ScanGroupForPA()
    PAD.paWearers = {}
    PAD.localPlayerHasPA = false
    PAD.paDetectedInGroup = false

    local groupSize = GetGroupSize()
    if groupSize == 0 then
        -- Solo: check player only
        if UnitHasSet("player", PAD.PA_SET_ID) then
            PAD.localPlayerHasPA = true
            PAD.paDetectedInGroup = true
            PAD.paWearers["player"] = true
        end
        return
    end

    for i = 1, groupSize do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            if UnitHasSet(unitTag, PAD.PA_SET_ID) then
                PAD.paWearers[unitTag] = true
                PAD.paDetectedInGroup = true
                if AreUnitsEqual("player", unitTag) then
                    PAD.localPlayerHasPA = true
                end
            end
        end
    end
end

-- ============================================================================
-- Buff Tracking
-- ============================================================================

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

function PAD.OnEffectChanged(changeType, unitTag, endTime, abilityId)
    if abilityId ~= PAD.PA_BUFF_ABILITY_ID then return end
    if not unitTag or unitTag == "" then return end

    unitTag = NormalizeUnitTag(unitTag)
    if not unitTag then return end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        PAD.buffState[unitTag] = {
            endTime = endTime,
            active = true,
        }
    elseif changeType == EFFECT_RESULT_FADED then
        PAD.buffState[unitTag] = {
            endTime = 0,
            active = false,
        }
    end
end

function PAD.FallbackBuffScan()
    local groupSize = GetGroupSize()
    if groupSize == 0 then
        -- Solo: scan player
        PAD.ScanUnitBuffs("player")
        return
    end

    for i = 1, groupSize do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            PAD.ScanUnitBuffs(unitTag)
        end
    end
end

function PAD.ScanUnitBuffs(unitTag)
    local numBuffs = GetNumBuffs(unitTag)
    local found = false
    for i = 1, numBuffs do
        local _, _, endTime, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo(unitTag, i)
        if abilityId == PAD.PA_BUFF_ABILITY_ID then
            PAD.buffState[unitTag] = {
                endTime = endTime,
                active = true,
            }
            found = true
            break
        end
    end
    -- Only clear if event hasn't already set an active state with a future endTime
    if not found then
        local existing = PAD.buffState[unitTag]
        if not existing or not existing.active or (existing.endTime and existing.endTime <= GetGameTimeSeconds()) then
            PAD.buffState[unitTag] = {
                endTime = 0,
                active = false,
            }
        end
    end
end

-- ============================================================================
-- Group Change Handling
-- ============================================================================

function PAD.OnGroupChanged()
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

    for unitTag, _ in pairs(PAD.buffState) do
        if not validTags[unitTag] then
            PAD.buffState[unitTag] = nil
        end
    end

    PAD.ScanGroupForPA()
    PAD.FallbackBuffScan()
    PAD.UpdateVisibility()
end

-- ============================================================================
-- Visibility Management
-- ============================================================================

function PAD.ShouldBeVisible()
    if not PAD.settings.enabled then return false end
    if PAD.menuHidden then return false end
    if PAD.pvpHidden then return false end
    if GetGroupSize() == 0 then return false end

    -- Combat-only check
    if PAD.settings.showOnlyInCombat and not IsUnitInCombat("player") then
        return false
    end

    -- Auto-show for PA wearers
    if PAD.localPlayerHasPA then return true end

    -- Opt-in for non-PA wearers when PA is detected in group
    if PAD.settings.showWhenGroupHasPA and PAD.paDetectedInGroup then return true end

    return false
end

function PAD.UpdateVisibility()
    local shouldShow = PAD.ShouldBeVisible()

    if shouldShow then
        PAD.StartDisplayRefresh()
        PAD.StartFallbackScan()
        if PAD.controls.mainWindow then
            PAD.controls.mainWindow:SetHidden(false)
        end
    else
        PAD.StopDisplayRefresh()
        PAD.StopFallbackScan()
        if PAD.controls.mainWindow then
            PAD.controls.mainWindow:SetHidden(true)
        end
    end
end

function PAD.StartDisplayRefresh()
    if PAD.displayRefreshRegistered then return end
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaPAD_Display", PAD.DISPLAY_REFRESH_INTERVAL_MS, function()
        PAD.RefreshDisplay()
    end)
    PAD.displayRefreshRegistered = true
end

function PAD.StopDisplayRefresh()
    if not PAD.displayRefreshRegistered then return end
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaPAD_Display")
    PAD.displayRefreshRegistered = false
end

function PAD.StartFallbackScan()
    if PAD.fallbackScanRegistered then return end
    EVENT_MANAGER:RegisterForUpdate("BeltalowdaPAD_Fallback", PAD.FALLBACK_SCAN_INTERVAL_MS, function()
        PAD.FallbackBuffScan()
    end)
    PAD.fallbackScanRegistered = true
end

function PAD.StopFallbackScan()
    if not PAD.fallbackScanRegistered then return end
    EVENT_MANAGER:UnregisterForUpdate("BeltalowdaPAD_Fallback")
    PAD.fallbackScanRegistered = false
end

-- ============================================================================
-- Display Refresh
-- ============================================================================

function PAD.RefreshDisplay()
    if not PAD.settings.enabled or PAD.menuHidden or PAD.pvpHidden then return end

    local window = PAD.controls.mainWindow
    if not window or window:IsHidden() then return end

    local now = GetGameTimeSeconds()
    local visibleCount = 0
    local groupSize = GetGroupSize()

    -- Collect world positions of all PA wearers for distance checks
    local wearerPositions = {}
    for wearerTag, _ in pairs(PAD.paWearers) do
        local _, rx, ry, rz = GetUnitRawWorldPosition(wearerTag)
        if rx and rx ~= 0 then
            wearerPositions[#wearerPositions + 1] = { x = rx, y = ry, z = rz }
        end
    end

    for i = 1, groupSize do
        local unitTag = "group" .. i
        if DoesUnitExist(unitTag) then
            visibleCount = visibleCount + 1
            local block = PAD.controls.playerBlocks[visibleCount]
            if block then
                block.unitTag = unitTag
                block.container:SetHidden(false)

                -- Update player name
                local displayName = Beltalowda.GetDisplayName(unitTag)
                block.nameLabel:SetText(displayName)

                -- Distance-based name coloring
                local nameColor = PAD.COLORS.NAME_UNKNOWN
                local isWearer = PAD.paWearers[unitTag]
                if isWearer then
                    -- Wearers are always "in range" of themselves
                    nameColor = PAD.COLORS.NAME_IN_RANGE
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
                        if minDist <= PAD.PROC_RANGE then
                            nameColor = PAD.COLORS.NAME_IN_RANGE
                        else
                            nameColor = PAD.COLORS.NAME_OUT_OF_RANGE
                        end
                    end
                end
                block.nameLabel:SetColor(nameColor[1], nameColor[2], nameColor[3], nameColor[4])

                -- Update buff status
                local state = PAD.buffState[unitTag]
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
                    block.progressBar:SetColor(PAD.COLORS.BUFF_ACTIVE[1], PAD.COLORS.BUFF_ACTIVE[2],
                        PAD.COLORS.BUFF_ACTIVE[3], PAD.COLORS.BUFF_ACTIVE[4])
                else
                    block.progressBar:SetColor(PAD.COLORS.BUFF_INACTIVE[1], PAD.COLORS.BUFF_INACTIVE[2],
                        PAD.COLORS.BUFF_INACTIVE[3], PAD.COLORS.BUFF_INACTIVE[4])
                end

                -- Update timer text
                if active and remaining > 0 then
                    block.timerLabel:SetText(string.format("%.1f", remaining))
                else
                    block.timerLabel:SetText("")
                end
            end
        end
    end

    -- Hide unused blocks
    for i = visibleCount + 1, PAD.MAX_GROUP_SIZE do
        local block = PAD.controls.playerBlocks[i]
        if block then
            block.container:SetHidden(true)
            block.unitTag = nil
        end
    end

    -- Resize window to fit content (4px bottom padding to match top gap)
    local totalHeight = PAD.TITLE_HEIGHT + (PAD.ROW_HEIGHT * visibleCount) + 4
    window:SetDimensions(PAD.WINDOW_WIDTH, totalHeight)
end

-- ============================================================================
-- Apply Settings
-- ============================================================================

function PAD.ApplySettings()
    local window = PAD.controls.mainWindow
    if not window then return end

    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetScale(PAD.settings.scale)

    PAD.UpdateVisibility()
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

function PAD.OnWindowMoved()
    local window = PAD.controls.mainWindow
    if not window then return end

    local left = window:GetLeft()
    local top = window:GetTop()
    if left and top then
        PAD.settings.positionX = left
        PAD.settings.positionY = top
        PAD.SaveSettings()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

function PAD.SetEnabled(enabled)
    PAD.settings.enabled = enabled
    PAD.SaveSettings()
    PAD.ApplySettings()

    if enabled then
        PAD.ScanGroupForPA()
        PAD.FallbackBuffScan()
    end
end

-- ============================================================================
-- Defaults & Settings Panel
-- ============================================================================

function PAD.GetDefaults()
    return {
        enabled = true,
        showWhenGroupHasPA = false,
        showOnlyInCombat = true,
        scale = 1.0,
        positionX = 200,
        positionY = 200,
    }
end

function PAD.GetSettingsControls()
    return {
        {
            type = "submenu",
            name = "|c4592FFPowerful Assault|r |t24:24:" .. (GetAbilityIcon(PAD.PA_BUFF_ABILITY_ID) or "") .. "|t",
            tooltip = "Track Powerful Assault buff uptime across group members",
            controls = {
                {
                    type = "description",
                    text = "Displays a floating window showing Powerful Assault buff timers for all group members. Auto-shows when you are wearing Powerful Assault. Inspired by Hyperioxes' Powerful Assault Tracker.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Powerful Assault",
                    tooltip = "Show the Powerful Assault buff tracker window",
                    getFunc = function() return PAD.settings.enabled end,
                    setFunc = function(value) PAD.SetEnabled(value) end,
                    width = "full",
                    default = true,
                },
                {
                    type = "checkbox",
                    name = "Show When Group Has PA",
                    tooltip = "Show the tracker even if you are not wearing Powerful Assault, as long as someone in your group is.",
                    getFunc = function() return PAD.settings.showWhenGroupHasPA end,
                    setFunc = function(value)
                        PAD.settings.showWhenGroupHasPA = value
                        PAD.SaveSettings()
                        PAD.UpdateVisibility()
                    end,
                    width = "full",
                    default = false,
                },
                {
                    type = "checkbox",
                    name = "Show Only In Combat",
                    tooltip = "Only show the tracker during combat",
                    getFunc = function() return PAD.settings.showOnlyInCombat end,
                    setFunc = function(value)
                        PAD.settings.showOnlyInCombat = value
                        PAD.SaveSettings()
                        PAD.UpdateVisibility()
                    end,
                    width = "full",
                    default = true,
                },
                {
                    type = "slider",
                    name = "UI Scale",
                    tooltip = "Scale of the Powerful Assault tracker window",
                    min = 0.5,
                    max = 2.0,
                    step = 0.1,
                    getFunc = function() return PAD.settings.scale end,
                    setFunc = function(value)
                        PAD.settings.scale = value
                        PAD.ApplySettings()
                        PAD.SaveSettings()
                    end,
                    width = "full",
                    default = 1.0,
                },
                {
                    type = "button",
                    name = "Reset Position",
                    tooltip = "Reset the tracker window position to default",
                    func = function()
                        PAD.settings.positionX = 200
                        PAD.settings.positionY = 200
                        if PAD.controls.mainWindow then
                            PAD.controls.mainWindow:ClearAnchors()
                            PAD.controls.mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 200, 200)
                        end
                        PAD.SaveSettings()
                    end,
                    width = "full",
                },
            },
        },
    }
end
