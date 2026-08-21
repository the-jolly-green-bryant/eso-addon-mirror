local U = Ultivite
U.Frames = U.Frames or {}
local VFM = U.Frames
local FAB = U.FancyActionBar

local ADDON_NAME = "Ultivite"
local SAVED_VARS_NAME = "VanillaFrameMoverSavedVariables"
local CHARACTER_SAVED_VARS_NAME = "VanillaFrameMoverCharacterSavedVariables"
local SAVED_VARS_VERSION = 1
local VERSION = "10.7.90 / Ultivite 1.0.125"


local NORMAL_WIDTH = 237
local SHRUNK_WIDTH = 141
local SHRUNK_RATIO = SHRUNK_WIDTH / NORMAL_WIDTH
local MAX_BAR_SCALE = 5.00

local DARKSOULS_LEFT = 28
local DARKSOULS_TOP = 77
local DARKSOULS_BAR_GAP = 2
local DARKSOULS_BAR_WIDTH_SCALE = 1.32
local DARKSOULS_BAR_THICKNESS_SCALE = 0.65
local DARKSOULS_BAR_INDEX = { health = 1, magicka = 2, stamina = 3 }
local DS_ULTIMATE_BOX_SIZE = 54
local DS_ULTIMATE_BAR_OFFSET = 58
local DS_ULTIMATE_LEFT_NUDGE = -4
local DS_ULTIMATE_BOTTOM_GAP = 12
local DS_ULTIMATE_DARKSOULS_WIDTH_MULTIPLIER = 1.20
local DS_ULTIMATE_DARKSOULS_THICKNESS_MULTIPLIER = 1.05

local DS_ENEMY_HEALTH_MODE_OFF = "off"
local DS_ENEMY_HEALTH_MODE_ONLY = "only"
local DS_ENEMY_HEALTH_MODE_PLUS_NORMAL = "plus"
local DS_ENEMY_HEALTH_UPDATE_MS = 50
local DS_ENEMY_HEALTH_WIDTH = 988
local DS_ENEMY_HEALTH_HEIGHT = 18
local DS_ENEMY_HEALTH_BOTTOM_OFFSET = -220
local DS_ENEMY_HEALTH_HIDDEN_REASON = "VanillaFrameMoverDSEnemyHealthOnly"
local DS_SELF_HEALTH_UPDATE_MS = 50
local DS_SELF_HEALTH_WIDTH = 988
local DS_SELF_HEALTH_HEIGHT = 18
local DS_SELF_HEALTH_BOTTOM_OFFSET = -220
local DS_SELF_HEALTH_STACK_GAP = 8
local DS_SELF_RESOURCE_GAP = 8
local GROUP_FRAME_CANDIDATE_NAMES = { "ZO_GroupList", "ZO_GroupUnitFrames", "ZO_RaidUnitFrames" }
local GROUP_FRAME_HIDDEN_REASON = "VanillaFrameMoverGroupFrames"
local LUI_GROUP_FRAME_NAMES = { "LUIE_CustomSmallGroupFrame", "LUIE_CustomRaidGroupFrame" }

local BAR_KEYS = { "health", "magicka", "stamina" }

local EDIT_SNAPSHOT_KEYS = {
    "healthX", "healthY",
    "magickaX", "magickaY",
    "staminaX", "staminaY",
    "barWidth", "barThickness",
    "snapToGrid", "gridSize",
    "darkSoulsLeft", "darkSoulsTop", "darkSoulsGap",
    "dsBottomX", "dsBottomOffset", "dsBottomGap",
}

local BAR_INFO = {
    health = {
        displayName = "HEALTH",
        powerType = COMBAT_MECHANIC_FLAGS_HEALTH,
        xKey = "healthX",
        yKey = "healthY",
    },
    magicka = {
        displayName = "MAGICKA",
        powerType = COMBAT_MECHANIC_FLAGS_MAGICKA,
        xKey = "magickaX",
        yKey = "magickaY",
    },
    stamina = {
        displayName = "STAMINA",
        powerType = COMBAT_MECHANIC_FLAGS_STAMINA,
        xKey = "staminaX",
        yKey = "staminaY",
    },
}

local PROFILE_SETTING_KEYS = {
    "locked",
    "individualPositionsInitialized",
    "healthX", "healthY",
    "magickaX", "magickaY",
    "staminaX", "staminaY",
    "snapToGrid", "gridSize",
    "layoutVersion", "compactGap", "bottomMargin",
    "darkSoulsLeft", "darkSoulsTop", "darkSoulsGap",
    "dsBottomX", "dsBottomOffset", "dsBottomGap", "dsSelfScale",
    "barWidth", "barThickness",
    "combatOnly",
    "hideChampionProgress",
    "hideChampionProgressInPvp",
    "championProgressVisibilityMode",
    "showTeammateCpReticle",
    "showGroupFrameChampionPoints",
    "groupFrameVisibilityMode",
    "chatVisibilityMode",
    "feetCompassVisibilityMode",
    "crownDirectionArrowVisibilityMode",
    "vanillaNpcNamesHidden",
    "vanillaNpcNameRestoreEnemy",
    "vanillaNpcNameRestoreFriendly",
    "vanillaNpcNameRestoreNeutral",
    "hideWerewolfResourceBar",
    "hideMountStaminaBar",
    "autoHideChat",
    "hideBattlegroundQueueStatus",
    "compassVisibilityMode",
    "questTrackerVisibilityMode",
    "queueStatusVisibilityMode",
    "crosshairVisibilityMode",
    "crownDirectionArrow",
    "crownDirectionArrowSize",
    "crownDirectionArrowOpacity",
    "crownDirectionArrowX",
    "crownDirectionArrowY",
    "feetCompass",
    "feetCompassSize",
    "feetCompassOpacity",
    "feetCompassX",
    "feetCompassY",
    "darkSoulsMode",
    "fullDarkSoulsMode",
    "hideActionBar",
    "showDSUltimate",
    "hideGroupFrame",
    "groupFramePositionInitialized",
    "groupFrameX", "groupFrameY",
    "dsEnemyHealthMode",
    "dsEnemyTrackReticle",
    "dsEnemyX", "dsEnemyBottomOffset", "dsEnemyWidth", "dsEnemyHeight",
    "dsSelfHealthBar",
    "dsSelfHealthCombatOnly",
    "dsSelfResourceBars",
    "dsBottomOnly",
    "font", "textScale", "textMode",
}

local defaults = {
    -- Evidence-based defaults captured from the user's in-game saved profile.
    locked = true,
    useAccountWide = true,

    -- New profiles must use these positions immediately. If this were false,
    -- first activation would capture ESO's vanilla anchors and overwrite them.
    individualPositionsInitialized = true,
    healthX = 0,
    healthY = 623,
    magickaX = -553,
    magickaY = 623,
    staminaX = 553,
    staminaY = 623,

    snapToGrid = true,
    gridSize = 7,
    layoutVersion = 0,
    compactGap = 24,
    bottomMargin = 8,

    -- Dark Souls preset anchors are saved so the user can tune them, print
    -- the exact values, and later promote a preferred arrangement to a new
    -- built-in default without touching the normal saved ESO bar positions.
    darkSoulsLeft = DARKSOULS_LEFT,
    darkSoulsTop = DARKSOULS_TOP,
    darkSoulsGap = DARKSOULS_BAR_GAP,
    dsBottomX = 0,
    dsBottomOffset = DS_SELF_HEALTH_BOTTOM_OFFSET,
    dsBottomGap = DS_SELF_RESOURCE_GAP,
    dsSelfScale = 1.00,

    barWidth = 1.455,
    barThickness = 2.123,

    combatOnly = false,
    hideChampionProgress = false,
    hideChampionProgressInPvp = true,
    championProgressVisibilityMode = "pvp",
    showTeammateCpReticle = false,
    showGroupFrameChampionPoints = true,
    groupFrameVisibilityMode = "show",
    chatVisibilityMode = "show",
    feetCompassVisibilityMode = "show",
    crownDirectionArrowVisibilityMode = "show",
    vanillaNpcNamesHidden = false,
    vanillaNpcNameRestoreEnemy = "",
    vanillaNpcNameRestoreFriendly = "",
    vanillaNpcNameRestoreNeutral = "",
    hideWerewolfResourceBar = true,
    hideMountStaminaBar = true,
    autoHideChat = false,
    hideBattlegroundQueueStatus = true, -- legacy retired setting retained for compatibility
    compassVisibilityMode = "combat",
    questTrackerVisibilityMode = "pvp",
    queueStatusVisibilityMode = "show",
    crosshairVisibilityMode = "show",

    -- Navigation helpers are intentionally opt-in. They use only public ESO
    -- position/camera APIs and never modify the world map or group state.
    crownDirectionArrow = false,
    crownDirectionArrowSize = 40,
    crownDirectionArrowOpacity = 0.70,
    crownDirectionArrowX = 0,
    crownDirectionArrowY = -90,
    feetCompass = false,
    feetCompassSize = 330,
    feetCompassOpacity = 0.66,
    feetCompassX = 0,
    feetCompassY = 335,

    darkSoulsMode = false,
    fullDarkSoulsMode = false,
    hideActionBar = false,
    showDSUltimate = false,
    hideGroupFrame = false,
    groupFramePositionInitialized = true,
    groupFrameX = 841,
    groupFrameY = 60,
    dsEnemyHealthMode = DS_ENEMY_HEALTH_MODE_OFF,
    dsEnemyTrackReticle = false,
    dsEnemyX = 0,
    dsEnemyBottomOffset = DS_ENEMY_HEALTH_BOTTOM_OFFSET,
    dsEnemyWidth = DS_ENEMY_HEALTH_WIDTH,
    dsEnemyHeight = DS_ENEMY_HEALTH_HEIGHT,
    dsSelfHealthBar = false,
    dsSelfHealthCombatOnly = false,
    dsSelfResourceBars = false,
    dsBottomOnly = false,

    font = "default",
    textScale = 1.35,
    textMode = "default",
}

VFM.defaults = defaults
VFM.profileSettingKeys = PROFILE_SETTING_KEYS

-- Persistence intentionally follows the same simple pattern as v10.5:
-- one long-standing account-wide SavedVariables table, one long-standing
-- character SavedVariables table, and a single boolean selector stored in the
-- account-wide table. No migrations, namespaces, replacement table names or
-- raw-global wrappers are involved.

local TEXT_MODE_NAMES = {
    "ESO default",
    "Current / Max",
    "Current only",
    "Percent",
    "Current + percent",
    "Hide numbers",
}

local TEXT_MODE_VALUES = {
    "default",
    "currentmax",
    "current",
    "percent",
    "currentpercent",
    "hide",
}

local FONT_NAMES = {
    "ESO default",
    "ESO Game",
    "ESO Game Bold",
    "ESO Window H4",
    "ESO Window H5",
    "ESO Window H6",
}

local FONT_VALUES = {
    "default",
    "ZoFontGame",
    "ZoFontGameBold",
    "ZoFontWinH4",
    "ZoFontWinH5",
    "ZoFontWinH6",
}

VFM.initialized = false
VFM.runtimeReady = false
VFM.applyPending = false
VFM.shrinkExpandModule = nil
VFM.baseGeometry = nil
VFM.movers = {}
VFM.draggingKey = nil
VFM.dragStartMouseX = nil
VFM.dragStartMouseY = nil
VFM.dragStartX = nil
VFM.dragStartY = nil
VFM.dragCapture = nil
VFM.vanillaPositions = {}
VFM.visualReapplyPending = false
VFM.editSnapshot = nil
VFM.editDirty = false
VFM.suspendDirtyTracking = false
VFM.editToolbar = nil
VFM.azurahConflictWarned = false
VFM.inCombat = false
VFM.lastPrepareFailure = "not attempted"
VFM.lastDirectApplyReason = "none"
VFM.lastDirectApplyAt = 0
VFM.slashHandler = nil
VFM.slashStatusHandler = nil
VFM.slashForceHandler = nil
VFM.actionBarPlatformRefreshPending = false
VFM.actionBarVisibilitySnapshot = nil
VFM.dsUltimateControl = nil
VFM.dsEnemyHealthControl = nil
VFM.dsEnemyHealthUpdateRegistered = false
VFM.dsEnemyPreferredTargetActive = false
VFM.dsEnemyPreferredTargetName = nil
VFM.dsEnemyPadlockHookInstalled = false
VFM.dsSelfMagickaControl = nil
VFM.dsSelfStaminaControl = nil
VFM.dsEnemyLastCurrent = 0
VFM.dsEnemyLastMaximum = 0
VFM.dsEnemyLastIsPlayer = false
VFM.dsEnemyLastChampionPoints = 0
VFM.dsEnemyLastLevel = 0
VFM.dsSelfHealthControl = nil
VFM.dsSelfHealthUpdateRegistered = false
VFM.groupFrameOriginalX = nil
VFM.groupFrameOriginalY = nil
VFM.groupFrameHiddenByAddon = false
VFM.werewolfHiddenByAddon = false
VFM.uiVisibilityNativeSnapshots = {}
VFM.luiGroupFrameVisibilitySnapshot = nil
VFM.teammateCpReticleControl = nil

local function Print(message)
    d(string.format("|c7FD5FF[Ultivite: Frames]|r %s", tostring(message)))
end

function VFM.RequestSettingsSave()
    if Ultivite and U.RequestSettingsSave then
        U.RequestSettingsSave(true)
    elseif RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave("Ultivite")
    end
end

local function Clamp(value, minimum, maximum)
    value = tonumber(value) or minimum
    if value < minimum then
        return minimum
    elseif value > maximum then
        return maximum
    end
    return value
end

function VFM.GetActiveBarWidthScale()
    if VFM.saved and VFM.saved.darkSoulsMode then
        local scale = DARKSOULS_BAR_WIDTH_SCALE
        if VFM.saved.showDSUltimate then
            scale = scale * DS_ULTIMATE_DARKSOULS_WIDTH_MULTIPLIER
        end
        return Clamp(scale, 0.50, MAX_BAR_SCALE)
    end
    return Clamp(VFM.saved and VFM.saved.barWidth or defaults.barWidth, 0.50, MAX_BAR_SCALE)
end

function VFM.GetActiveBarThicknessScale()
    if VFM.saved and VFM.saved.darkSoulsMode then
        local scale = DARKSOULS_BAR_THICKNESS_SCALE
        if VFM.saved.showDSUltimate then
            scale = scale * DS_ULTIMATE_DARKSOULS_THICKNESS_MULTIPLIER
        end
        return Clamp(scale, 0.50, MAX_BAR_SCALE)
    end
    return Clamp(VFM.saved and VFM.saved.barThickness or defaults.barThickness, 0.50, MAX_BAR_SCALE)
end

local function Trim(text)
    return (text or ""):match("^%s*(.-)%s*$")
end

local function FormatNumber(value)
    value = zo_round(tonumber(value) or 0)
    if ZO_LocalizeDecimalNumber then
        return ZO_LocalizeDecimalNumber(value)
    end
    return tostring(value)
end

local function GetRootCenter()
    local x, y = GuiRoot:GetCenter()
    if x and y then
        return x, y
    end
    return GuiRoot:GetWidth() / 2, GuiRoot:GetHeight() / 2
end

local function SnapValue(value, gridSize)
    if not gridSize or gridSize <= 1 then
        return zo_round(value)
    end
    return zo_round(value / gridSize) * gridSize
end

local function GetMousePosition()
    if GetUIMousePosition then
        local x, y = GetUIMousePosition()
        if x and y then
            return x, y
        end
    end

    if GuiMouse and GuiMouse.GetCenter then
        local x, y = GuiMouse:GetCenter()
        if x and y then
            return x, y
        end
    end

    return nil, nil
end


function VFM.IsHUDAllowed()
    -- Keep Ultivite top-level HUD controls out of map, inventory, addon
    -- settings and other full UI scenes. These are public ESO APIs.
    if IsGameCameraActive and not IsGameCameraActive() then
        return false
    end
    if IsGameCameraUIModeActive and IsGameCameraUIModeActive() then
        return false
    end
    return true
end

function VFM.GetFrame()
    if PLAYER_ATTRIBUTE_BARS and PLAYER_ATTRIBUTE_BARS.control then
        return PLAYER_ATTRIBUTE_BARS.control
    end
    return ZO_PlayerAttribute
end

function VFM.GetGroupFrameControl()
    if GROUP_LIST and GROUP_LIST.control then
        return GROUP_LIST.control
    end

    for _, name in ipairs(GROUP_FRAME_CANDIDATE_NAMES) do
        local control = _G[name]
        if control then
            return control
        end
    end

    return nil
end

function VFM.CaptureGroupFramePosition(control)
    control = control or VFM.GetGroupFrameControl()
    if not control or not control.GetCenter then
        return false
    end

    local x, y = control:GetCenter()
    if not x or not y then
        return false
    end

    local rootX, rootY = GetRootCenter()
    local relativeX = zo_round(x - rootX)
    local relativeY = zo_round(y - rootY)

    if VFM.groupFrameOriginalX == nil or VFM.groupFrameOriginalY == nil then
        VFM.groupFrameOriginalX = relativeX
        VFM.groupFrameOriginalY = relativeY
    end

    if not VFM.saved.groupFramePositionInitialized then
        VFM.saved.groupFrameX = relativeX
        VFM.saved.groupFrameY = relativeY
        VFM.saved.groupFramePositionInitialized = true
        VFM.RequestSettingsSave()
    end

    return true
end

function VFM.GetGroupFrameVisibilityMode()
    if not VFM.saved then return "show" end
    local mode = tostring(VFM.saved.groupFrameVisibilityMode or "")
    if mode == "show" or mode == "pvp" or mode == "hide" then return mode end
    if VFM.saved.hideGroupFrame == true then return "hide" end
    return "show"
end

function VFM.ShouldHideGroupFrame()
    local mode = VFM.GetGroupFrameVisibilityMode()
    if mode == "hide" then return true end
    if mode == "pvp" then return VFM.IsPvpUiContext and VFM.IsPvpUiContext() or false end
    return false
end

function VFM.ApplyGroupFrameState()
    if not VFM.saved then return false end
    local shouldHide = VFM.ShouldHideGroupFrame()
    local applied = false

    if UNIT_FRAMES and type(UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason) == "function" then
        pcall(function()
            UNIT_FRAMES:SetGroupAndRaidFramesHiddenForReason(GROUP_FRAME_HIDDEN_REASON, shouldHide)
            if type(UNIT_FRAMES.UpdateGroupAnchorFrames) == "function" then
                UNIT_FRAMES:UpdateGroupAnchorFrames()
            end
        end)
        VFM.groupFrameHiddenByAddon = shouldHide
        applied = true
    end

    -- LUI group frames are explicit known controls. Preserve their current
    -- visibility before hiding so leaving PvP or switching back to ON returns
    -- ownership cleanly instead of forcing another addon's frame visible.
    if shouldHide then
        VFM.luiGroupFrameVisibilitySnapshot = VFM.luiGroupFrameVisibilitySnapshot or {}
        for _, name in ipairs(LUI_GROUP_FRAME_NAMES) do
            local control = _G[name]
            if control and control.SetHidden then
                if VFM.luiGroupFrameVisibilitySnapshot[control] == nil and control.IsHidden then
                    VFM.luiGroupFrameVisibilitySnapshot[control] = control:IsHidden() and true or false
                end
                pcall(function() control:SetHidden(true) end)
                applied = true
            end
        end
    elseif VFM.luiGroupFrameVisibilitySnapshot then
        for control, wasHidden in pairs(VFM.luiGroupFrameVisibilitySnapshot) do
            if control and control.SetHidden then
                pcall(function() control:SetHidden(wasHidden and true or false) end)
                applied = true
            end
        end
        VFM.luiGroupFrameVisibilitySnapshot = nil
    end

    return applied
end

function VFM.SetGroupFrameVisibilityMode(mode, silent)
    if not VFM.saved then return end
    mode = tostring(mode or "show")
    if mode ~= "pvp" and mode ~= "hide" then mode = "show" end
    VFM.saved.groupFrameVisibilityMode = mode
    VFM.saved.hideGroupFrame = mode == "hide"
    VFM.RequestSettingsSave()
    VFM.ApplyGroupFrameState()
    if VFM.RefreshUiVisibilityRules then VFM.RefreshUiVisibilityRules(true) end
    if not silent then Print("Group frame visibility: " .. string.upper(mode)) end
end

function VFM.SetHideGroupFrame(enabled, silent)
    VFM.SetGroupFrameVisibilityMode(enabled and "hide" or "show", silent)
end

local function IsGroupUnitTag(unitTag)
    return type(unitTag) == "string" and string.match(unitTag, "^group%d+$") ~= nil
end

local function ApplyGroupFrameChampionPointState(frame)
    if not frame or not VFM.saved then return false end
    local unitTag = frame.unitTag
    if not IsGroupUnitTag(unitTag) then return false end

    local isChampion = false
    if IsUnitChampion then
        local ok, value = pcall(IsUnitChampion, unitTag)
        isChampion = ok and value == true
    end

    -- Ultivite never suppresses group-frame CP. ESO owns the actual number and
    -- Champion icon; this post-hook only guarantees they stay visible for
    -- Champion group members if an older Ultivite profile previously hid them.
    if isChampion then
        if frame.levelLabel and frame.levelLabel.SetHidden then
            pcall(function() frame.levelLabel:SetHidden(false) end)
        end
        if frame.championIcon and frame.championIcon.SetHidden then
            pcall(function() frame.championIcon:SetHidden(false) end)
        end
    end
    return true
end

function VFM.ApplyGroupFrameChampionPoints()
    if not VFM.saved or not UNIT_FRAMES or type(UNIT_FRAMES.GetFrame) ~= "function" then return false end
    local applied = false
    local maxGroupSize = tonumber(GROUP_SIZE_MAX) or 24
    for index = 1, maxGroupSize do
        local ok, frame = pcall(function() return UNIT_FRAMES:GetFrame("group" .. tostring(index)) end)
        if ok and frame then
            -- Let ESO first calculate the correct level / CP presentation, then
            -- the post-hook below applies Ultivite's optional CP suppression.
            if frame.UpdateLevel then pcall(function() frame:UpdateLevel() end) end
            if ApplyGroupFrameChampionPointState(frame) then applied = true end
        end
    end
    return applied
end

function VFM.InstallGroupFrameChampionPointHook()
    if VFM.groupFrameChampionPointHookInstalled then return true end
    if not ZO_PostHook or not ZO_UnitFrameObject or type(ZO_UnitFrameObject.UpdateLevel) ~= "function" then return false end

    ZO_PostHook(ZO_UnitFrameObject, "UpdateLevel", function(frame)
        ApplyGroupFrameChampionPointState(frame)
    end)
    VFM.groupFrameChampionPointHookInstalled = true
    return true
end

function VFM.SetShowGroupFrameChampionPoints(enabled, silent)
    -- Compatibility shim for older profiles / callers. Group-frame CP is now
    -- permanently enabled and cannot be disabled through Ultivite.
    if not VFM.saved then return end
    VFM.saved.showGroupFrameChampionPoints = true
    VFM.RequestSettingsSave()
    VFM.InstallGroupFrameChampionPointHook()
    VFM.ApplyGroupFrameChampionPoints()
    if not silent then
        Print("Group frame Champion Points: ALWAYS ON")
    end
end

function VFM.SetGroupFramePositionAxis(axis, value)
    -- Legacy setting retained for SavedVariables compatibility only.
    if axis == "x" then
        VFM.saved.groupFrameX = zo_round(value)
    else
        VFM.saved.groupFrameY = zo_round(value)
    end
    VFM.saved.groupFramePositionInitialized = true
    VFM.RequestSettingsSave()
end

function VFM.ResetGroupFramePosition(silent)
    local control = VFM.GetGroupFrameControl()
    if (VFM.groupFrameOriginalX == nil or VFM.groupFrameOriginalY == nil) and control then
        VFM.CaptureGroupFramePosition(control)
    end

    if VFM.groupFrameOriginalX == nil or VFM.groupFrameOriginalY == nil then
        if not silent then
            Print("Group frame is not available yet")
        end
        return false
    end

    VFM.saved.groupFrameX = VFM.groupFrameOriginalX
    VFM.saved.groupFrameY = VFM.groupFrameOriginalY
    VFM.saved.groupFramePositionInitialized = true
    VFM.RequestSettingsSave()
    VFM.ApplyGroupFrameState()

    if not silent then
        Print("Group frame position reset")
    end

    return true
end

function VFM.GetBars()
    if not PLAYER_ATTRIBUTE_BARS or not PLAYER_ATTRIBUTE_BARS.bars then
        return nil
    end
    return PLAYER_ATTRIBUTE_BARS.bars
end

function VFM.GetPrimaryBarObjects()
    local bars = VFM.GetBars()
    if not bars then
        return nil
    end

    local result = {}
    for _, bar in ipairs(bars) do
        if bar and bar.control and bar.unitTag == "player" then
            if bar.powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
                result.health = bar
            elseif bar.powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
                result.magicka = bar
            elseif bar.powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                result.stamina = bar
            end
        end
    end

    if not result.health or not result.magicka or not result.stamina then
        return nil
    end

    return result
end

function VFM.GetPrimaryControl(key)
    local bars = VFM.GetPrimaryBarObjects()
    local bar = bars and bars[key]
    return bar and bar.control or nil
end

function VFM.IsPrimaryBar(bar)
    return bar
        and bar.unitTag == "player"
        and (
            bar.powerType == COMBAT_MECHANIC_FLAGS_HEALTH
            or bar.powerType == COMBAT_MECHANIC_FLAGS_MAGICKA
            or bar.powerType == COMBAT_MECHANIC_FLAGS_STAMINA
        )
end

function VFM.FindShrinkExpandModule()
    if VFM.shrinkExpandModule then
        return VFM.shrinkExpandModule
    end

    local visualizer = PLAYER_ATTRIBUTE_BARS and PLAYER_ATTRIBUTE_BARS.attributeVisualizer
    if not visualizer or not visualizer.visualModules then
        return nil
    end

    -- Identify the exact ZOS max-resource shrink/expand module by what it
    -- handles, rather than by table shape alone. This mirrors the approach
    -- used by working attribute-bar scaling addons.
    for module in pairs(visualizer.visualModules) do
        if module
            and module.IsUnitVisualRelevant
            and module:IsUnitVisualRelevant(ATTRIBUTE_VISUAL_INCREASED_MAX_POWER, STAT_HEALTH_MAX) then
            VFM.shrinkExpandModule = module
            return module
        end
    end

    return nil
end

function VFM.CaptureEditSnapshot()
    local snapshot = {}
    for _, key in ipairs(EDIT_SNAPSHOT_KEYS) do
        snapshot[key] = VFM.saved[key]
    end
    VFM.editSnapshot = snapshot
    VFM.editDirty = false
    VFM.UpdateEditToolbar()
end

function VFM.RefreshEditDirty()
    if VFM.suspendDirtyTracking or VFM.saved.locked or not VFM.editSnapshot then
        return
    end

    local dirty = false
    for _, key in ipairs(EDIT_SNAPSHOT_KEYS) do
        if VFM.saved[key] ~= VFM.editSnapshot[key] then
            dirty = true
            break
        end
    end

    VFM.editDirty = dirty
    VFM.UpdateEditToolbar()
end

function VFM.CommitEditSession()
    VFM.editSnapshot = nil
    VFM.editDirty = false
    VFM.UpdateEditToolbar()
end

function VFM.RestoreEditSnapshot()
    if not VFM.editSnapshot then
        return false
    end

    VFM.suspendDirtyTracking = true
    for _, key in ipairs(EDIT_SNAPSHOT_KEYS) do
        VFM.saved[key] = VFM.editSnapshot[key]
    end
    VFM.suspendDirtyTracking = false

    VFM.ApplyBarGeometry()
    VFM.ApplyDarkSoulsHealthStyle()
    VFM.ApplyTextStyle()
    VFM.AnchorAllBarsToSavedPositions()
    VFM.PositionAllMovers()
    VFM.UpdateAllMoverSizes()
    VFM.UpdateAllMoverLabels()

    VFM.editDirty = false
    VFM.UpdateEditToolbar()
    return true
end

function VFM.UndoEditSession()
    if VFM.saved.locked then
        return
    end

    if VFM.RestoreEditSnapshot() then
        Print("Edit changes restored to the layout from when edit mode was opened")
    end
end

function VFM.CancelEditSession()
    if VFM.saved.locked then
        return
    end

    VFM.RestoreEditSnapshot()
    VFM.SetLocked(true, true)
    Print("Edit mode closed without keeping the pending changes")
end

function VFM.UndoBarToEditSnapshot(key)
    if VFM.saved.locked or not VFM.editSnapshot then
        return
    end

    local info = BAR_INFO[key]
    if not info then
        return
    end

    VFM.suspendDirtyTracking = true
    VFM.saved[info.xKey] = VFM.editSnapshot[info.xKey]
    VFM.saved[info.yKey] = VFM.editSnapshot[info.yKey]
    VFM.suspendDirtyTracking = false

    VFM.AnchorBarToSavedPosition(key)
    VFM.PositionMover(key)
    VFM.UpdateMoverSize(key)
    VFM.UpdateMoverLabel(key)
    VFM.RefreshEditDirty()
end

function VFM.GetSavedPosition(key)
    local info = BAR_INFO[key]
    if not info then
        return 0, 0
    end
    return tonumber(VFM.saved[info.xKey]) or 0, tonumber(VFM.saved[info.yKey]) or 0
end

function VFM.GetDarkSoulsBarCenter(key)
    local index = DARKSOULS_BAR_INDEX[key]
    if not index then
        return nil, nil
    end

    local barWidth = VFM.GetVisualPrimaryBarWidth()
    local barHeight = VFM.GetVisualPrimaryBarHeight()
    local left = VFM.GetDarkSoulsLeftOffset()
    local top = tonumber(VFM.saved and VFM.saved.darkSoulsTop) or DARKSOULS_TOP
    local gap = Clamp(tonumber(VFM.saved and VFM.saved.darkSoulsGap) or DARKSOULS_BAR_GAP, 0, 100)

    return left + (barWidth / 2),
        top + (barHeight / 2) + ((index - 1) * (barHeight + gap))
end

function VFM.GetExpectedBarCenter(key)
    if VFM.saved and VFM.saved.darkSoulsMode then
        local x, y = VFM.GetDarkSoulsBarCenter(key)
        return x, y, true
    end

    local rootX, rootY = GetRootCenter()
    local x, y = VFM.GetSavedPosition(key)
    return rootX + x, rootY + y, false
end

function VFM.IsDSBottomUltimateEnabled()
    if not VFM.saved
        or VFM.saved.showDSUltimate ~= true
        or VFM.saved.dsSelfHealthBar ~= true
        or VFM.saved.dsSelfResourceBars ~= true
        or VFM.saved.dsBottomOnly ~= true
        or VFM.saved.hideActionBar ~= true then
        return false
    end
    -- If FAB is temporarily unlocked, its edit visibility deliberately wins.
    -- Do not draw the replacement Ultimate at the same time as the edit bar.
    if FAB and FAB.IsUnlocked and FAB.IsUnlocked() then
        return false
    end
    return true
end

function VFM.IsActionBarRootVisible()
    local root = ZO_ActionBar1
    if not root then
        return false
    end
    if root.IsHidden and root:IsHidden() then
        return false
    end
    if root.GetAlpha then
        local alpha = tonumber(root:GetAlpha()) or 1
        if alpha <= 0.01 then
            return false
        end
    end
    return true
end

function VFM.IsDSUltimateEnabled()
    if not VFM.saved or VFM.saved.showDSUltimate ~= true then
        return false
    end

    -- Never render Ultivite's standalone Ultimate at the same time as the
    -- shared ESO/Fancy Action Bar root. FAB already contains its own Ultimate
    -- slot, so a second Dark Souls Ultimate would be a duplicate. The custom
    -- Ultimate is only needed when the action bar is actually hidden.
    if VFM.IsActionBarRootVisible() then
        return false
    end

    return VFM.saved.darkSoulsMode == true or VFM.IsDSBottomUltimateEnabled()
end

function VFM.GetDarkSoulsLeftOffset()
    local left = tonumber(VFM.saved and VFM.saved.darkSoulsLeft) or DARKSOULS_LEFT
    -- Only the compact top-left layout needs to reserve horizontal room for
    -- Ultimate. The large bottom layout positions Ultimate independently to
    -- the left of the complete 988px resource stack.
    if VFM.saved and VFM.saved.darkSoulsMode and VFM.saved.showDSUltimate then
        left = left + DS_ULTIMATE_BAR_OFFSET
    end
    return left
end

function VFM.GetDSUltimateAbilityId()
    local hotbar = GetActiveHotbarCategory and GetActiveHotbarCategory() or HOTBAR_CATEGORY_PRIMARY

    -- Prefer FAB+'s own resolved slot helper when the addon is loaded so skill
    -- substitutions and alternate hotbars follow the same ability FAB+ is showing.
    local fab = FAB or FancyActionBar
    if fab and type(fab.GetSlotBoundAbilityId) == "function" then
        local id = fab.GetSlotBoundAbilityId(8, hotbar)
        if id and id > 0 then
            return id, hotbar
        end
    end

    if GetSlotBoundId then
        local id = GetSlotBoundId(8, hotbar)
        if id and id > 0 then
            if GetSlotType and GetSlotType(8, hotbar) == ACTION_TYPE_CRAFTED_ABILITY and GetAbilityIdForCraftedAbilityId then
                id = GetAbilityIdForCraftedAbilityId(id)
            end
            if GetEffectiveAbilityIdForAbilityOnHotbar then
                local effectiveId = GetEffectiveAbilityIdForAbilityOnHotbar(id, hotbar)
                if effectiveId and effectiveId > 0 then
                    id = effectiveId
                end
            end
            return id, hotbar
        end
    end

    return 0, hotbar
end

function VFM.GetDSUltimateIcon()
    local abilityId, hotbar = VFM.GetDSUltimateAbilityId()
    if not abilityId or abilityId <= 0 then
        return nil, hotbar
    end

    local fab = FAB or FancyActionBar
    if fab and type(fab.GetSkillStyleIconForAbilityId) == "function" then
        local styledIcon = fab.GetSkillStyleIconForAbilityId(abilityId)
        if styledIcon and styledIcon ~= "" then
            return styledIcon, hotbar
        end
    end

    if GetAbilityIcon then
        local icon = GetAbilityIcon(abilityId)
        if icon and icon ~= "" then
            return icon, hotbar
        end
    end

    return nil, hotbar
end

function VFM.CreateDSUltimateControl()
    if VFM.dsUltimateControl then
        return VFM.dsUltimateControl
    end

    local frame = WINDOW_MANAGER:CreateTopLevelWindow("VanillaFrameMoverDSUltimate")
    frame:SetDimensions(DS_ULTIMATE_BOX_SIZE, DS_ULTIMATE_BOX_SIZE)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawTier(DT_HIGH)
    frame:SetDrawLevel(1450)
    frame:SetMouseEnabled(false)
    frame:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("VanillaFrameMoverDSUltimateBackdrop", frame, CT_BACKDROP)
    backdrop:SetAnchorFill(frame)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.015, 0.015, 0.015, 0.96)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 5, 0)
    backdrop:SetEdgeColor(0.04, 0.04, 0.04, 1.00)
    backdrop:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl("VanillaFrameMoverDSUltimateIcon", frame, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, frame, TOPLEFT, 2, 2)
    icon:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -2, -2)
    icon:SetTextureCoords(0.06, 0.94, 0.06, 0.94)
    icon:SetMouseEnabled(false)

    -- Keep the ultimate value separate from the icon artwork. It sits directly
    -- above the box in white so the icon remains clean and unobstructed.
    local label = WINDOW_MANAGER:CreateControl("VanillaFrameMoverDSUltimateLabel", frame, CT_LABEL)
    label:SetDimensions(DS_ULTIMATE_BOX_SIZE + 18, 24)
    label:SetAnchor(BOTTOM, frame, TOP, 0, -2)
    label:SetFont("ZoFontWinH3")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    label:SetColor(1.00, 1.00, 1.00, 1.00)
    label:SetText("0")
    label:SetMouseEnabled(false)

    VFM.dsUltimateControl = {
        frame = frame,
        backdrop = backdrop,
        icon = icon,
        label = label,
    }

    return VFM.dsUltimateControl
end

function VFM.UpdateDSUltimateControl()
    local control = VFM.dsUltimateControl
    if not VFM.IsDSUltimateEnabled() or not VFM.IsHUDAllowed() then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        return false
    end

    if VFM.saved and VFM.saved.combatOnly and not VFM.inCombat and VFM.saved.locked then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        return false
    end

    control = VFM.CreateDSUltimateControl()
    if not control then
        return false
    end

    control.frame:ClearAnchors()

    if VFM.IsDSBottomUltimateEnabled() then
        -- Dark Souls Self uses three 988px bars centred on dsBottomX. When the
        -- action bar is deliberately disabled, put Ultimate immediately to the
        -- left of that complete stack and centre it vertically against Health
        -- through Stamina. This custom Ultimate is independent of ZO_ActionBar1.
        local stackCenterX = tonumber(VFM.saved.dsBottomX) or 0
        local stackLeftX = stackCenterX - (DS_SELF_HEALTH_WIDTH / 2)
        local centerX = stackLeftX - DS_ULTIMATE_BOTTOM_GAP - (DS_ULTIMATE_BOX_SIZE / 2)
        local healthBottom = VFM.GetDSSelfResourceBottomOffset("health")
        local staminaBottom = VFM.GetDSSelfResourceBottomOffset("stamina")
        local centerY = ((healthBottom + staminaBottom) / 2) - (DS_SELF_HEALTH_HEIGHT / 2)
        control.frame:SetAnchor(CENTER, GuiRoot, BOTTOM, zo_round(centerX), zo_round(centerY))
    else
        -- Centre the ultimate box vertically against the whole compact top-left
        -- three-bar stack.
        local _, healthY = VFM.GetDarkSoulsBarCenter("health")
        local _, staminaY = VFM.GetDarkSoulsBarCenter("stamina")
        local centerY = zo_round(((healthY or 0) + (staminaY or 0)) / 2)
        local savedLeft = tonumber(VFM.saved and VFM.saved.darkSoulsLeft) or DARKSOULS_LEFT
        local centerX = savedLeft + DS_ULTIMATE_LEFT_NUDGE + zo_round(DS_ULTIMATE_BOX_SIZE / 2)
        control.frame:SetAnchor(CENTER, GuiRoot, TOPLEFT, centerX, centerY)
    end

    local iconTexture, hotbar = VFM.GetDSUltimateIcon()
    if iconTexture then
        control.icon:SetTexture(iconTexture)
        control.icon:SetHidden(false)
    else
        control.icon:SetTexture("")
        control.icon:SetHidden(true)
    end

    -- This is the same resource FAB+ reads for values such as 500.
    local current = 0
    if GetUnitPower then
        current = select(1, GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)) or 0
    end
    current = math.max(0, tonumber(current) or 0)
    control.label:SetText(FormatNumber(current))

    -- Keep the Dark Souls ultimate value fixed white and independent from
    -- Fancy Action Bar+'s dynamic usable/capped colouring.
    control.label:SetColor(1.00, 1.00, 1.00, 1.00)

    control.frame:SetHidden(false)
    return true
end

function VFM.SetShowDSUltimate(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.showDSUltimate == enabled then
        return
    end

    VFM.saved.showDSUltimate = enabled
    VFM.RequestSettingsSave()
    VFM.ApplyBarGeometry()
    if VFM.saved.darkSoulsMode then
        VFM.ApplyDarkSoulsHealthStyle()
    end
    VFM.AnchorAllBarsToSavedPositions()
    VFM.PositionAllMovers()
    VFM.UpdateAllMoverSizes()
    VFM.UpdateAllMoverLabels()
    VFM.UpdateDSUltimateControl()

    if not silent then
        Print(enabled and "Dark Souls ultimate box enabled" or "Dark Souls ultimate box disabled")
    end
end

function VFM.GetActionBarControls()
    local controls = {}

    -- Fancy Action Bar+ deliberately parents FAB_ActionBar and its custom
    -- back-bar controls to ZO_ActionBar1. Its front-bar overlays and quickslot
    -- overlay are also children of ZO_ActionBar1. Hiding individual ESO slots
    -- therefore leaves FAB's overlay frames/timers behind and produces a
    -- mangled empty action bar. Hide the single common root instead.
    if ZO_ActionBar1 then
        controls[#controls + 1] = ZO_ActionBar1
    end

    return controls
end

function VFM.CaptureActionBarVisibilitySnapshot()
    if not VFM.actionBarVisibilitySnapshot then
        VFM.actionBarVisibilitySnapshot = {}
    end

    for _, control in ipairs(VFM.GetActionBarControls()) do
        if VFM.actionBarVisibilitySnapshot[control] == nil then
            VFM.actionBarVisibilitySnapshot[control] = {
                hidden = control.IsHidden and control:IsHidden() and true or false,
            }
        end
    end

    return true
end

function VFM.ApplyActionBarHidden()
    if not VFM.saved or not VFM.saved.hideActionBar or VFM.actionBarPlatformRefreshPending then
        return false
    end
    -- FAB edit mode must always win over normal/custom visibility rules so the
    -- user can actually see and move the bar while it is unlocked.
    if FAB and FAB.IsUnlocked and FAB.IsUnlocked() then
        return false
    end
    VFM.CaptureActionBarVisibilitySnapshot()

    -- Hide the complete shared ESO/Fancy Action Bar+ root, including Ultimate.
    for _, control in ipairs(VFM.GetActionBarControls()) do
        if control.SetHidden then
            control:SetHidden(true)
        end
    end

    return true
end

function VFM.RestoreActionBarVisibility()
    if not VFM.actionBarVisibilitySnapshot then
        return false
    end

    for control, snapshot in pairs(VFM.actionBarVisibilitySnapshot) do
        if control and control.SetHidden and snapshot and snapshot.hidden ~= nil then
            control:SetHidden(snapshot.hidden and true or false)
        end
    end

    VFM.actionBarVisibilitySnapshot = nil
    return true
end

function VFM.GetActionBarVisibilityDrift()
    if not VFM.saved or not VFM.saved.hideActionBar or VFM.actionBarPlatformRefreshPending then
        return false
    end
    for _, control in ipairs(VFM.GetActionBarControls()) do
        if control.IsHidden and not control:IsHidden() then
            return true
        end
    end

    return false
end

function VFM.ApplyDarkSoulsHealthStyle()
    if not VFM.saved or not VFM.saved.darkSoulsMode then
        return false
    end

    local bars = VFM.GetPrimaryBarObjects()
    local healthBar = bars and bars.health
    local control = healthBar and healthBar.control
    if not control then
        return false
    end

    local barLeft = control:GetNamedChild("BarLeft")
    local barRight = control:GetNamedChild("BarRight")
    local bg = control:GetNamedChild("BgContainer")
    local warner = control:GetNamedChild("Warner")
    if not barLeft or not barRight or not bg then
        return false
    end

    -- ESO's native Health bar is a mirrored two-half bar. Dark Souls mode needs
    -- the same single right-facing silhouette as Stamina, so use the Stamina
    -- edge templates and let the existing right Health status bar span the full
    -- control. Health still owns both status bars internally, so ESO's resource
    -- update path remains intact while the hidden left half is simply not drawn.
    if ApplyTemplateToControl and ZO_GetPlatformTemplate then
        local bgLeft = bg:GetNamedChild("BgLeft")
        local bgRight = bg:GetNamedChild("BgRight")
        local bgCenter = bg:GetNamedChild("BgCenter")
        local frameLeft = control:GetNamedChild("FrameLeft")
        local frameRight = control:GetNamedChild("FrameRight")
        local frameCenter = control:GetNamedChild("FrameCenter")

        if bgLeft then ApplyTemplateToControl(bgLeft, ZO_GetPlatformTemplate("ZO_PlayerAttributeBgLeft")) end
        if bgRight then ApplyTemplateToControl(bgRight, ZO_GetPlatformTemplate("ZO_PlayerAttributeBgRightArrow")) end
        if bgCenter then ApplyTemplateToControl(bgCenter, ZO_GetPlatformTemplate("ZO_PlayerAttributeBgCenter")) end

        if frameLeft then ApplyTemplateToControl(frameLeft, ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameLeft")) end
        if frameRight then ApplyTemplateToControl(frameRight, ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameRightArrow")) end
        if frameCenter then ApplyTemplateToControl(frameCenter, ZO_GetPlatformTemplate("ZO_PlayerAttributeFrameCenter")) end

        if warner then
            local warnLeft = warner:GetNamedChild("Left")
            local warnRight = warner:GetNamedChild("Right")
            local warnCenter = warner:GetNamedChild("Center")
            if warnLeft then
                ApplyTemplateToControl(warnLeft, ZO_GetPlatformTemplate("ZO_PlayerAttributeHealthWarnerTexture"))
                ApplyTemplateToControl(warnLeft, ZO_GetPlatformTemplate("ZO_PlayerAttributeWarnerLeft"))
            end
            if warnRight then
                ApplyTemplateToControl(warnRight, ZO_GetPlatformTemplate("ZO_PlayerAttributeHealthWarnerTexture"))
                ApplyTemplateToControl(warnRight, ZO_GetPlatformTemplate("ZO_PlayerAttributeWarnerRightArrow"))
            end
            if warnCenter then
                ApplyTemplateToControl(warnCenter, ZO_GetPlatformTemplate("ZO_PlayerAttributeHealthWarnerTexture"))
                ApplyTemplateToControl(warnCenter, ZO_GetPlatformTemplate("ZO_PlayerAttributeWarnerCenter"))
            end
        end

        barRight:ClearAnchors()
        ApplyTemplateToControl(barRight, ZO_GetPlatformTemplate("ZO_PlayerAttributeBarAnchorRight"))
    else
        barRight:ClearAnchors()
        barRight:SetAnchor(LEFT, control, LEFT)
        barRight:SetAnchor(RIGHT, control, RIGHT)
    end

    barLeft:SetHidden(true)
    barRight:SetHidden(false)
    return true
end

function VFM.RestoreDarkSoulsHealthStyle()
    local bars = VFM.GetPrimaryBarObjects()
    local healthBar = bars and bars.health
    local control = healthBar and healthBar.control
    if not control then
        return false
    end

    local barLeft = control:GetNamedChild("BarLeft")
    local barRight = control:GetNamedChild("BarRight")
    if barLeft then barLeft:SetHidden(false) end
    if barRight then barRight:SetHidden(false) end

    -- Restore ESO's native split Health templates and anchors. VFM reapplies its
    -- own outer positions and scaling immediately afterward, so normal saved
    -- layout settings are not modified by this temporary Dark Souls skin.
    if PLAYER_ATTRIBUTE_BARS and PLAYER_ATTRIBUTE_BARS.ApplyStyle then
        PLAYER_ATTRIBUTE_BARS:ApplyStyle()
        if PLAYER_ATTRIBUTE_BARS.attributeVisualizer and PLAYER_ATTRIBUTE_BARS.attributeVisualizer.ApplyPlatformStyle then
            PLAYER_ATTRIBUTE_BARS.attributeVisualizer:ApplyPlatformStyle()
        end
    end
    return true
end

function VFM.GetDarkSoulsHealthStyleDrift()
    if not VFM.saved or not VFM.saved.darkSoulsMode then
        return false
    end

    local bars = VFM.GetPrimaryBarObjects()
    local healthBar = bars and bars.health
    local control = healthBar and healthBar.control
    local barLeft = control and control:GetNamedChild("BarLeft")
    local barRight = control and control:GetNamedChild("BarRight")
    if not control or not barLeft or not barRight then
        return true
    end

    if barLeft.IsHidden and not barLeft:IsHidden() then
        return true
    end

    local controlWidth = tonumber(control:GetWidth()) or 0
    local rightWidth = tonumber(barRight:GetWidth()) or 0
    return controlWidth > 0 and math.abs(rightWidth - controlWidth) > 2
end

function VFM.ExitFullDarkSoulsPresetState()
    if not VFM.saved or VFM.saved.fullDarkSoulsMode ~= true then return false end
    VFM.saved.fullDarkSoulsMode = false
    VFM.saved.hideActionBar = false
    VFM.saved.dsEnemyHealthMode = DS_ENEMY_HEALTH_MODE_OFF
    VFM.saved.dsEnemyTrackReticle = false
    VFM.RestoreActionBarVisibility()
    VFM.RefreshDSEnemyHealthRuntime()
    if Ultivite and U.ApplyFullDarkSoulsAuxVisibility then
        U.ApplyFullDarkSoulsAuxVisibility(false)
    end
    VFM.RequestSettingsSave()
    return true
end

function VFM.SetDarkSoulsMode(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved then return end
    if not enabled and VFM.saved.fullDarkSoulsMode == true then
        VFM.ExitFullDarkSoulsPresetState()
    end
    if VFM.saved.darkSoulsMode == enabled then
        return
    end

    -- Keep edit mode available in Dark Souls mode. Dragging any top-left
    -- resource bar moves the complete Dark Souls stack as one unit.
    VFM.saved.darkSoulsMode = enabled
    VFM.RequestSettingsSave()

    if enabled then
        VFM.ApplyBarGeometry()
        VFM.ApplyDarkSoulsHealthStyle()
        VFM.ApplyTextStyle()
        VFM.SetDarkSoulsResourceTextHidden(true)
    else
        VFM.RestoreDarkSoulsHealthStyle()
        VFM.SetDarkSoulsResourceTextHidden(false)
        VFM.ApplyBarGeometry()
        VFM.ApplyTextStyle()
    end

    VFM.PositionAllMovers()
    VFM.UpdateAllMoverSizes()
    VFM.UpdateAllMoverLabels()
    VFM.UpdateDSUltimateControl()

    if not silent then
        Print(enabled and "darksouls mode enabled" or "darksouls mode disabled")
    end
end

function VFM.SetHideActionBar(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.hideActionBar == enabled then
        return
    end

    VFM.saved.hideActionBar = enabled
    VFM.RequestSettingsSave()

    if enabled then
        VFM.ApplyActionBarHidden()
    else
        VFM.RestoreActionBarVisibility()
        if FAB and FAB.ApplyCombatOnlyVisibility then
            FAB.ApplyCombatOnlyVisibility(VFM.saved.combatOnly ~= true)
        end
    end

    -- The standalone Ultimate is used by Dark Souls Self only when the action
    -- bar is hidden, so update it immediately when this toggle changes.
    VFM.UpdateDSUltimateControl()

    if not silent then
        Print(enabled and "Action bar hidden" or "Action bar shown")
    end
end

function VFM.IsDSEnemyHealthEnabled()
    if not VFM.saved then
        return false
    end

    -- A full Dark Souls player resource stack at the bottom owns this screen
    -- region. Never render the long enemy Health bar at the same time.
    if VFM.saved.dsSelfResourceBars == true or VFM.saved.dsBottomOnly == true then
        return false
    end

    return VFM.saved.dsEnemyHealthMode == DS_ENEMY_HEALTH_MODE_ONLY
        or VFM.saved.dsEnemyHealthMode == DS_ENEMY_HEALTH_MODE_PLUS_NORMAL
end

function VFM.GetReticleTargetUnitFrame()
    if ZO_UnitFrames_GetUnitFrame then
        return ZO_UnitFrames_GetUnitFrame("reticleover")
    end
    return nil
end

function VFM.IsValidDSEnemyReticleTarget()
    return DoesUnitExist
        and DoesUnitExist("reticleover")
        and (not IsUnitAttackable or IsUnitAttackable("reticleover"))
        and (not IsUnitDead or not IsUnitDead("reticleover"))
end

function VFM.GetDSEnemyReticleTargetName()
    if not VFM.IsValidDSEnemyReticleTarget() then
        return nil
    end

    local name
    if GetRawUnitName then
        name = GetRawUnitName("reticleover")
    end
    if (not name or name == "") and GetUnitName then
        name = GetUnitName("reticleover")
    end
    if not name or name == "" then
        return nil
    end
    return name
end

function VFM.IsCurrentReticleDSEnemyPreferredTarget()
    if not VFM.dsEnemyPreferredTargetActive then
        return false
    end

    -- A normal reticle mouseover must never count as a DS target. ESO exposes
    -- preferred-target state separately from reticleover, so require an active
    -- preferred target before accepting the cached Tab-selected target.
    if IsGameCameraPreferredTargetValid and not IsGameCameraPreferredTargetValid() then
        return false
    end

    local currentName = VFM.GetDSEnemyReticleTargetName()
    if not currentName then
        return false
    end

    if VFM.dsEnemyPreferredTargetName and currentName ~= VFM.dsEnemyPreferredTargetName then
        return false
    end

    return true
end

function VFM.ApplyDSEnemyNormalFrameVisibility()
    local unitFrame = VFM.GetReticleTargetUnitFrame()
    if not unitFrame or not unitFrame.SetHiddenForReason then
        return false
    end

    local hideNormal = VFM.saved
        and VFM.saved.dsEnemyHealthMode == DS_ENEMY_HEALTH_MODE_ONLY
        and (VFM.IsCurrentReticleDSEnemyPreferredTarget()
            or (VFM.saved.dsEnemyTrackReticle == true and VFM.IsValidDSEnemyReticleTarget()))
        or false

    unitFrame:SetHiddenForReason(DS_ENEMY_HEALTH_HIDDEN_REASON, hideNormal)
    return true
end

function VFM.GetDSEnemyHealthGeometry()
    local width = Clamp(VFM.saved and VFM.saved.dsEnemyWidth or DS_ENEMY_HEALTH_WIDTH, 320, 1800)
    local height = Clamp(VFM.saved and VFM.saved.dsEnemyHeight or DS_ENEMY_HEALTH_HEIGHT, 8, 80)
    local x = Clamp(VFM.saved and VFM.saved.dsEnemyX or 0, -1400, 1400)
    local bottomOffset = Clamp(VFM.saved and VFM.saved.dsEnemyBottomOffset or DS_ENEMY_HEALTH_BOTTOM_OFFSET, -900, 0)
    return width, height, x, bottomOffset
end

function VFM.ApplyDSEnemyHealthGeometry()
    local control = VFM.dsEnemyHealthControl
    local frame = control and control.frame
    if not frame then return false end

    local width, height, x, bottomOffset = VFM.GetDSEnemyHealthGeometry()
    local signature = string.format("%.1f:%.1f:%.1f:%.1f", width, height, x, bottomOffset)
    if VFM.dsEnemyGeometrySignature == signature then return true end
    VFM.dsEnemyGeometrySignature = signature

    frame:SetDimensions(width, height)
    frame:ClearAnchors()
    frame:SetAnchor(BOTTOM, GuiRoot, BOTTOM, x, bottomOffset)
    return true
end

function VFM.SetDSEnemyGeometryValue(key, value)
    if not VFM.saved then return end
    if key == "dsEnemyWidth" then value = Clamp(value, 320, 1800)
    elseif key == "dsEnemyHeight" then value = Clamp(value, 8, 80)
    elseif key == "dsEnemyX" then value = Clamp(value, -1400, 1400)
    elseif key == "dsEnemyBottomOffset" then value = Clamp(value, -900, 0)
    else return end
    VFM.saved[key] = value
    VFM.dsEnemyGeometrySignature = nil
    VFM.RequestSettingsSave()
    VFM.ApplyDSEnemyHealthGeometry()
end

function VFM.CreateDSEnemyHealthBar()
    if VFM.dsEnemyHealthControl then
        return VFM.dsEnemyHealthControl
    end

    local frame = WINDOW_MANAGER:CreateTopLevelWindow("VanillaFrameMoverDSEnemyHealth")
    local width, height, x, bottomOffset = VFM.GetDSEnemyHealthGeometry()
    frame:SetDimensions(width, height)
    frame:SetAnchor(BOTTOM, GuiRoot, BOTTOM, x, bottomOffset)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawTier(DT_HIGH)
    frame:SetDrawLevel(1500)
    frame:SetMouseEnabled(false)
    frame:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("VanillaFrameMoverDSEnemyHealthBackdrop", frame, CT_BACKDROP)
    backdrop:SetAnchorFill(frame)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.015, 0.015, 0.015, 0.88)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    backdrop:SetEdgeColor(0.04, 0.04, 0.04, 1.00)
    backdrop:SetMouseEnabled(false)

    local fill = WINDOW_MANAGER:CreateControl(
        "VanillaFrameMoverDSEnemyHealthFill",
        frame,
        CT_STATUSBAR
    )
    fill:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_tall.dds")
    fill:ClearAnchors()
    fill:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 3)
    fill:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3, -3)
    fill:SetMinMax(0, 1)
    fill:SetValue(1)
    fill:SetMouseEnabled(false)

    -- Raw CT_STATUSBAR controls do not inherit ESO's player-bar colouring.
    -- Use a tintable progress texture and explicit Dark Souls colours.
    if fill.SetColor then
        fill:SetColor(0.78, 0.08, 0.08, 1.00)
    end

    local championIcon = WINDOW_MANAGER:CreateControl(
        "VanillaFrameMoverDSEnemyChampionIcon",
        frame,
        CT_TEXTURE
    )
    championIcon:SetTexture("EsoUI/Art/Champion/champion_icon_32.dds")
    championIcon:SetDimensions(20, 20)
    championIcon:SetAnchor(BOTTOMLEFT, frame, TOPLEFT, 4, -3)
    championIcon:SetHidden(true)
    championIcon:SetMouseEnabled(false)

    local levelLabel = WINDOW_MANAGER:CreateControl(
        "VanillaFrameMoverDSEnemyLevel",
        frame,
        CT_LABEL
    )
    levelLabel:SetFont("ZoFontGameShadow")
    levelLabel:SetColor(1, 1, 1, 1)
    levelLabel:SetDimensions(90, 22)
    levelLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    levelLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    levelLabel:SetHidden(true)
    levelLabel:SetMouseEnabled(false)

    VFM.dsEnemyHealthControl = {
        frame = frame,
        backdrop = backdrop,
        fill = fill,
        championIcon = championIcon,
        levelLabel = levelLabel,
    }
    VFM.dsEnemyGeometrySignature = nil
    VFM.ApplyDSEnemyHealthGeometry()

    return VFM.dsEnemyHealthControl
end


local function UpdateDSEnemyPlayerLevelDisplay(control, isPlayer, championPoints, level)
    if not control then return end
    championPoints = tonumber(championPoints) or 0
    level = tonumber(level) or 0
    local showChampion = isPlayer == true and championPoints > 0
    local showLevel = isPlayer == true and not showChampion and level > 0

    if control.championIcon then
        control.championIcon:SetHidden(not showChampion)
    end

    if control.levelLabel then
        control.levelLabel:ClearAnchors()
        if showChampion and control.championIcon then
            control.levelLabel:SetAnchor(LEFT, control.championIcon, RIGHT, 3, 0)
            control.levelLabel:SetText(tostring(championPoints))
            control.levelLabel:SetHidden(false)
        elseif showLevel then
            control.levelLabel:SetAnchor(BOTTOMLEFT, control.frame, TOPLEFT, 4, -3)
            control.levelLabel:SetText(tostring(level))
            control.levelLabel:SetHidden(false)
        else
            control.levelLabel:SetText("")
            control.levelLabel:SetHidden(true)
        end
    end
end

function VFM.UpdateDSEnemyHealthBar()
    local control = VFM.dsEnemyHealthControl
    if not VFM.IsDSEnemyHealthEnabled() or not VFM.IsHUDAllowed() then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        VFM.dsEnemyLastCurrent = 0
        VFM.dsEnemyLastMaximum = 0
        VFM.dsEnemyLastIsPlayer = false
        VFM.dsEnemyLastChampionPoints = 0
        VFM.dsEnemyLastLevel = 0
        if control then UpdateDSEnemyPlayerLevelDisplay(control, false, 0, 0) end
        VFM.ApplyDSEnemyNormalFrameVisibility()
        return false
    end

    if VFM.saved and VFM.saved.combatOnly and not VFM.inCombat and VFM.saved.locked then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        VFM.ApplyDSEnemyNormalFrameVisibility()
        return false
    end

    control = VFM.CreateDSEnemyHealthBar()
    if not control then
        return false
    end
    VFM.ApplyDSEnemyHealthGeometry()

    -- Normal DS enemy mode remains preferred/Tab-target driven. Full Dark Souls
    -- can opt into the public reticleover unit so the large bottom boss-style bar
    -- appears immediately for the enemy currently being fought.
    local useLiveReticle = VFM.saved and VFM.saved.dsEnemyTrackReticle == true and VFM.IsValidDSEnemyReticleTarget()

    -- Mouseover/reticleover alone must never activate the legacy DS bar. ESO exposes
    -- preferred-target state via IsGameCameraPreferredTargetValid(). If Tab has
    -- produced a valid preferred target but a UI/load-order hook missed the key
    -- press, lazily capture the current enemy while preferred targeting is active.
    if IsGameCameraPreferredTargetValid then
        if not IsGameCameraPreferredTargetValid() then
            VFM.dsEnemyPreferredTargetActive = false
            VFM.dsEnemyPreferredTargetName = nil
            VFM.dsEnemyLastCurrent = 0
            VFM.dsEnemyLastMaximum = 0
            VFM.dsEnemyLastIsPlayer = false
            VFM.dsEnemyLastChampionPoints = 0
            VFM.dsEnemyLastLevel = 0
        elseif not VFM.dsEnemyPreferredTargetActive then
            local preferredName = VFM.GetDSEnemyReticleTargetName()
            if preferredName then
                VFM.dsEnemyPreferredTargetActive = true
                VFM.dsEnemyPreferredTargetName = preferredName
            end
        end
    end

    local current = nil
    local maximum = nil
    local targetIsPlayer = false
    local targetChampionPoints = 0
    local targetLevel = 0

    if useLiveReticle or VFM.IsCurrentReticleDSEnemyPreferredTarget() then
        local liveCurrent, liveMaximum, effectiveMaximum = GetUnitPower(
            "reticleover",
            COMBAT_MECHANIC_FLAGS_HEALTH
        )

        liveCurrent = tonumber(liveCurrent) or 0
        liveMaximum = tonumber(liveMaximum) or 0
        effectiveMaximum = tonumber(effectiveMaximum) or 0
        if effectiveMaximum > 0 then
            liveMaximum = effectiveMaximum
        end

        if liveMaximum > 0 then
            current = Clamp(liveCurrent, 0, liveMaximum)
            maximum = liveMaximum
            VFM.dsEnemyLastCurrent = current
            VFM.dsEnemyLastMaximum = maximum

            targetIsPlayer = IsUnitPlayer and IsUnitPlayer("reticleover") or false
            if targetIsPlayer then
                if GetUnitEffectiveChampionPoints then
                    targetChampionPoints = tonumber(GetUnitEffectiveChampionPoints("reticleover")) or 0
                elseif GetUnitChampionPoints then
                    targetChampionPoints = tonumber(GetUnitChampionPoints("reticleover")) or 0
                end
                if targetChampionPoints <= 0 and GetUnitEffectiveLevel then
                    targetLevel = tonumber(GetUnitEffectiveLevel("reticleover")) or 0
                end
            end
            VFM.dsEnemyLastIsPlayer = targetIsPlayer
            VFM.dsEnemyLastChampionPoints = targetChampionPoints
            VFM.dsEnemyLastLevel = targetLevel
        end
    elseif VFM.dsEnemyPreferredTargetActive and (tonumber(VFM.dsEnemyLastMaximum) or 0) > 0 then
        -- There is no public unitTag for the preferred Tab target when it is no
        -- longer the current reticleover target. Keep the DS bar visible using
        -- the last known health values for as long as ESO reports that the
        -- preferred target still exists.
        current = tonumber(VFM.dsEnemyLastCurrent) or 0
        maximum = tonumber(VFM.dsEnemyLastMaximum) or 0
        targetIsPlayer = VFM.dsEnemyLastIsPlayer == true
        targetChampionPoints = tonumber(VFM.dsEnemyLastChampionPoints) or 0
        targetLevel = tonumber(VFM.dsEnemyLastLevel) or 0
    end

    if not current or not maximum or maximum <= 0 then
        UpdateDSEnemyPlayerLevelDisplay(control, false, 0, 0)
        control.frame:SetHidden(true)
        VFM.ApplyDSEnemyNormalFrameVisibility()
        return false
    end

    current = Clamp(current, 0, maximum)
    control.fill:SetMinMax(0, maximum)
    control.fill:SetValue(current)
    UpdateDSEnemyPlayerLevelDisplay(control, targetIsPlayer, targetChampionPoints, targetLevel)
    control.frame:SetHidden(false)
    VFM.ApplyDSEnemyNormalFrameVisibility()
    return true
end

function VFM.CaptureDSEnemyPreferredTargetFromGame()
    if not VFM.IsDSEnemyHealthEnabled() then
        VFM.dsEnemyPreferredTargetActive = false
        VFM.dsEnemyPreferredTargetName = nil
        VFM.UpdateDSEnemyHealthBar()
        return
    end

    -- API 101050 exposes the actual preferred-target state independently from
    -- reticleover. This prevents ordinary mouseover from arming the DS bar.
    if IsGameCameraPreferredTargetValid and not IsGameCameraPreferredTargetValid() then
        VFM.dsEnemyPreferredTargetActive = false
        VFM.dsEnemyPreferredTargetName = nil
        VFM.UpdateDSEnemyHealthBar()
        return
    end

    local name = VFM.GetDSEnemyReticleTargetName()
    if name then
        VFM.dsEnemyPreferredTargetActive = true
        VFM.dsEnemyPreferredTargetName = name
    elseif not (IsGameCameraPreferredTargetValid and IsGameCameraPreferredTargetValid()) then
        VFM.dsEnemyPreferredTargetActive = false
        VFM.dsEnemyPreferredTargetName = nil
    end

    VFM.UpdateDSEnemyHealthBar()
end

function VFM.InstallDSEnemyPreferredTargetHook()
    -- API 101050 exposes IsGameCameraPreferredTargetValid() to addons, but the
    -- functions that change/cycle/clear the preferred target are private.
    -- Do not read or hook any of those private globals from insecure addon code.
    --
    -- UpdateDSEnemyHealthBar already polls IsGameCameraPreferredTargetValid()
    -- every DS enemy-health update, so no keybind hook is required. This keeps
    -- ordinary reticle mouseover from arming the bar while allowing ESO's real
    -- preferred/Tab target state to drive it.
    VFM.dsEnemyPadlockHookInstalled = true
    return true
end

function VFM.RefreshDSEnemyHealthRuntime()
    if VFM.IsDSEnemyHealthEnabled() then
        VFM.CreateDSEnemyHealthBar()
        VFM.InstallDSEnemyPreferredTargetHook()
        if not VFM.dsEnemyHealthUpdateRegistered then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "DSEnemyHealth", DS_ENEMY_HEALTH_UPDATE_MS, function()
                VFM.UpdateDSEnemyHealthBar()
            end)
            VFM.dsEnemyHealthUpdateRegistered = true
        end
        VFM.UpdateDSEnemyHealthBar()
    else
        VFM.dsEnemyPreferredTargetActive = false
        VFM.dsEnemyPreferredTargetName = nil
        if VFM.dsEnemyHealthUpdateRegistered then
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "DSEnemyHealth")
            VFM.dsEnemyHealthUpdateRegistered = false
        end
        if VFM.dsEnemyHealthControl and VFM.dsEnemyHealthControl.frame then
            VFM.dsEnemyHealthControl.frame:SetHidden(true)
        end
        VFM.ApplyDSEnemyNormalFrameVisibility()
    end
end

function VFM.SetDSEnemyHealthMode(mode, silent)
    if mode ~= DS_ENEMY_HEALTH_MODE_ONLY and mode ~= DS_ENEMY_HEALTH_MODE_PLUS_NORMAL then
        mode = DS_ENEMY_HEALTH_MODE_OFF
    end

    -- Bottom player Health/Magicka/Stamina and the long enemy bar are mutually
    -- exclusive. The player resource stack always wins.
    if VFM.saved and (VFM.saved.dsSelfResourceBars == true or VFM.saved.dsBottomOnly == true) then
        mode = DS_ENEMY_HEALTH_MODE_OFF
    end

    if not VFM.saved or VFM.saved.dsEnemyHealthMode == mode then
        return
    end

    VFM.saved.dsEnemyHealthMode = mode
    VFM.dsEnemyPreferredTargetActive = false
    VFM.dsEnemyPreferredTargetName = nil
    VFM.dsEnemyLastCurrent = 0
    VFM.dsEnemyLastMaximum = 0
    VFM.dsEnemyLastIsPlayer = false
    VFM.dsEnemyLastChampionPoints = 0
    VFM.dsEnemyLastLevel = 0
    VFM.RequestSettingsSave()
    VFM.RefreshDSEnemyHealthRuntime()

    -- The player bottom stack sits above the enemy long bar when both are
    -- enabled, so reposition it immediately when enemy mode changes.
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()

    if VFM.optionsPanel and CALLBACK_MANAGER then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", VFM.optionsPanel)
    end

    if not silent then
        if mode == DS_ENEMY_HEALTH_MODE_ONLY then
            Print("DS Enemy health bar only enabled")
        elseif mode == DS_ENEMY_HEALTH_MODE_PLUS_NORMAL then
            Print("DS Enemy health bar + normal enabled")
        else
            Print("DS Enemy health bar disabled")
        end
    end
end

function VFM.IsDSSelfHealthEnabled()
    return VFM.saved and VFM.saved.dsSelfHealthBar and true or false
end

function VFM.GetDSSelfBottomBaseOffset()
    -- The target bar keeps the lowest proven position. When an enemy long bar
    -- is enabled, the player stack moves above it as one unit. The base offset
    -- is profile-backed so Dark Souls presets can be tuned and synced.
    local base = tonumber(VFM.saved and VFM.saved.dsBottomOffset) or DS_SELF_HEALTH_BOTTOM_OFFSET
    if VFM.IsDSEnemyHealthEnabled() then
        return base - DS_SELF_HEALTH_HEIGHT - DS_SELF_HEALTH_STACK_GAP
    end
    return base
end

function VFM.GetDSSelfResourceBottomOffset(resourceKey)
    local base = VFM.GetDSSelfBottomBaseOffset()

    -- With only the self Health bar enabled, preserve its established position.
    if not VFM.saved.dsSelfResourceBars then
        return base
    end

    -- Full bottom stack mirrors the top-left order:
    -- Health on top, Magicka in the middle, Stamina on the bottom.
    local gap = Clamp(tonumber(VFM.saved and VFM.saved.dsBottomGap) or DS_SELF_RESOURCE_GAP, 0, 100)
    local step = DS_SELF_HEALTH_HEIGHT + gap
    if resourceKey == "health" then
        return base - (step * 2)
    elseif resourceKey == "magicka" then
        return base - step
    end
    return base
end

function VFM.GetDSSelfHealthBottomOffset()
    return VFM.GetDSSelfResourceBottomOffset("health")
end

function VFM.CreateDSSelfHealthBar()
    if VFM.dsSelfHealthControl then
        return VFM.dsSelfHealthControl
    end

    local frame = WINDOW_MANAGER:CreateTopLevelWindow("VanillaFrameMoverDSSelfHealth")
    frame:SetDimensions(DS_SELF_HEALTH_WIDTH, DS_SELF_HEALTH_HEIGHT)
    frame:SetScale(Clamp(tonumber(VFM.saved and VFM.saved.dsSelfScale) or 1.0, 0.50, 2.50))
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawTier(DT_HIGH)
    frame:SetDrawLevel(1490)
    frame:SetMouseEnabled(false)
    frame:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("VanillaFrameMoverDSSelfHealthBackdrop", frame, CT_BACKDROP)
    backdrop:SetAnchorFill(frame)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.015, 0.015, 0.015, 0.88)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    backdrop:SetEdgeColor(0.04, 0.04, 0.04, 1.00)
    backdrop:SetMouseEnabled(false)

    local fill = WINDOW_MANAGER:CreateControl(
        "VanillaFrameMoverDSSelfHealthFill",
        frame,
        CT_STATUSBAR
    )
    fill:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_tall.dds")
    fill:ClearAnchors()
    fill:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 3)
    fill:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3, -3)
    fill:SetMinMax(0, 1)
    fill:SetValue(1)
    fill:SetMouseEnabled(false)

    -- Raw CT_STATUSBAR controls do not inherit ESO's player-bar colouring.
    -- Use a tintable progress texture and explicit Dark Souls colours.
    if fill.SetColor then
        fill:SetColor(0.78, 0.08, 0.08, 1.00)
    end

    VFM.dsSelfHealthControl = {
        frame = frame,
        backdrop = backdrop,
        fill = fill,
    }

    return VFM.dsSelfHealthControl
end


function VFM.CreateDSSelfResourceBar(resourceKey)
    local isMagicka = resourceKey == "magicka"
    local existing = isMagicka and VFM.dsSelfMagickaControl or VFM.dsSelfStaminaControl
    if existing then
        return existing
    end

    local suffix = isMagicka and "Magicka" or "Stamina"
    local powerType = isMagicka and COMBAT_MECHANIC_FLAGS_MAGICKA or COMBAT_MECHANIC_FLAGS_STAMINA

    local frame = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteDSSelf" .. suffix)
    frame:SetDimensions(DS_SELF_HEALTH_WIDTH, DS_SELF_HEALTH_HEIGHT)
    frame:SetScale(Clamp(tonumber(VFM.saved and VFM.saved.dsSelfScale) or 1.0, 0.50, 2.50))
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawTier(DT_HIGH)
    frame:SetDrawLevel(1488)
    frame:SetMouseEnabled(false)
    frame:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("UltiviteDSSelf" .. suffix .. "Backdrop", frame, CT_BACKDROP)
    backdrop:SetAnchorFill(frame)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.015, 0.015, 0.015, 0.88)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    backdrop:SetEdgeColor(0.04, 0.04, 0.04, 1.00)
    backdrop:SetMouseEnabled(false)

    local fill = WINDOW_MANAGER:CreateControl(
        "UltiviteDSSelf" .. suffix .. "Fill",
        frame,
        CT_STATUSBAR
    )
    fill:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill_tall.dds")
    fill:ClearAnchors()
    fill:SetAnchor(TOPLEFT, frame, TOPLEFT, 3, 3)
    fill:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -3, -3)
    fill:SetMinMax(0, 1)
    fill:SetValue(1)
    fill:SetMouseEnabled(false)

    if fill.SetColor then
        if isMagicka then
            fill:SetColor(0.08, 0.38, 0.88, 1.00)
        else
            fill:SetColor(0.05, 0.62, 0.26, 1.00)
        end
    end

    local result = {
        frame = frame,
        backdrop = backdrop,
        fill = fill,
        powerType = powerType,
        resourceKey = resourceKey,
    }

    if isMagicka then
        VFM.dsSelfMagickaControl = result
    else
        VFM.dsSelfStaminaControl = result
    end

    return result
end

function VFM.UpdateDSSelfResourceBar(resourceKey)
    local control = resourceKey == "magicka" and VFM.dsSelfMagickaControl or VFM.dsSelfStaminaControl

    if not VFM.saved or not VFM.saved.dsSelfHealthBar or not VFM.saved.dsSelfResourceBars or not VFM.IsHUDAllowed() then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        return false
    end

    if (VFM.saved.dsSelfHealthCombatOnly or VFM.saved.combatOnly) and not VFM.inCombat and VFM.saved.locked then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        return false
    end

    control = VFM.CreateDSSelfResourceBar(resourceKey)
    if not control then
        return false
    end

    control.frame:ClearAnchors()
    control.frame:SetAnchor(
        BOTTOM,
        GuiRoot,
        BOTTOM,
        tonumber(VFM.saved.dsBottomX) or 0,
        VFM.GetDSSelfResourceBottomOffset(resourceKey)
    )

    local current, maximum, effectiveMaximum = GetUnitPower("player", control.powerType)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    effectiveMaximum = tonumber(effectiveMaximum) or 0
    if effectiveMaximum > 0 then
        maximum = effectiveMaximum
    end

    if maximum <= 0 then
        control.frame:SetHidden(true)
        return false
    end

    current = Clamp(current, 0, maximum)
    control.fill:SetMinMax(0, maximum)
    control.fill:SetValue(current)
    control.frame:SetHidden(false)
    return true
end

function VFM.UpdateDSSelfResourceBars()
    VFM.UpdateDSSelfResourceBar("magicka")
    VFM.UpdateDSSelfResourceBar("stamina")
end

function VFM.UpdateDSSelfHealthBar()
    local control = VFM.dsSelfHealthControl
    if not VFM.IsDSSelfHealthEnabled() or not VFM.IsHUDAllowed() then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        return false
    end

    -- Optional independent visibility rule for the long player Health bar.
    -- This does not change the normal player resource bars or the global
    -- "Show bars only in combat" setting.
    if (VFM.saved.dsSelfHealthCombatOnly or VFM.saved.combatOnly) and not VFM.inCombat and VFM.saved.locked then
        if control and control.frame then
            control.frame:SetHidden(true)
        end
        return false
    end

    control = VFM.CreateDSSelfHealthBar()
    if not control then
        return false
    end

    control.frame:ClearAnchors()
    control.frame:SetAnchor(BOTTOM, GuiRoot, BOTTOM, tonumber(VFM.saved.dsBottomX) or 0, VFM.GetDSSelfHealthBottomOffset())

    local current, maximum, effectiveMaximum = GetUnitPower(
        "player",
        COMBAT_MECHANIC_FLAGS_HEALTH
    )

    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    effectiveMaximum = tonumber(effectiveMaximum) or 0
    if effectiveMaximum > 0 then
        maximum = effectiveMaximum
    end

    if maximum <= 0 then
        control.frame:SetHidden(true)
        return false
    end

    current = Clamp(current, 0, maximum)
    control.fill:SetMinMax(0, maximum)
    control.fill:SetValue(current)
    control.frame:SetHidden(false)
    return true
end

function VFM.RefreshDSSelfHealthRuntime()
    if VFM.IsDSSelfHealthEnabled() then
        VFM.CreateDSSelfHealthBar()
        if VFM.saved.dsSelfResourceBars then
            VFM.CreateDSSelfResourceBar("magicka")
            VFM.CreateDSSelfResourceBar("stamina")
        end

        if not VFM.dsSelfHealthUpdateRegistered then
            EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "DSSelfHealth", DS_SELF_HEALTH_UPDATE_MS, function()
                VFM.UpdateDSSelfHealthBar()
                VFM.UpdateDSSelfResourceBars()
            end)
            VFM.dsSelfHealthUpdateRegistered = true
        end

        VFM.UpdateDSSelfHealthBar()
        VFM.UpdateDSSelfResourceBars()
    else
        if VFM.dsSelfHealthUpdateRegistered then
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "DSSelfHealth")
            VFM.dsSelfHealthUpdateRegistered = false
        end
        if VFM.dsSelfHealthControl and VFM.dsSelfHealthControl.frame then
            VFM.dsSelfHealthControl.frame:SetHidden(true)
        end
        if VFM.dsSelfMagickaControl and VFM.dsSelfMagickaControl.frame then
            VFM.dsSelfMagickaControl.frame:SetHidden(true)
        end
        if VFM.dsSelfStaminaControl and VFM.dsSelfStaminaControl.frame then
            VFM.dsSelfStaminaControl.frame:SetHidden(true)
        end
    end
end

function VFM.SetDSSelfHealthBar(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.dsSelfHealthBar == enabled then
        return
    end

    VFM.saved.dsSelfHealthBar = enabled

    -- Do not leave Bottom-only active with no replacement player bars.
    if not enabled then
        VFM.saved.dsSelfResourceBars = false
        VFM.saved.dsBottomOnly = false
    end

    VFM.RequestSettingsSave()
    VFM.RefreshDSSelfHealthRuntime()
    VFM.UpdateCombatVisibility()

    if not silent then
        Print(enabled and "DS Self Health Bar enabled" or "DS Self Health Bar disabled")
    end
end

function VFM.SetDSSelfHealthCombatOnly(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.dsSelfHealthCombatOnly == enabled then
        return
    end

    VFM.saved.dsSelfHealthCombatOnly = enabled
    VFM.RequestSettingsSave()
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()

    if not silent then
        Print(enabled and "DS Self Health Bar combat-only enabled" or "DS Self Health Bar combat-only disabled")
    end
end


function VFM.SetDSSelfResourceBars(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.dsSelfResourceBars == enabled then
        return
    end

    VFM.saved.dsSelfResourceBars = enabled
    if enabled then
        VFM.saved.dsSelfHealthBar = true
        VFM.saved.dsEnemyHealthMode = DS_ENEMY_HEALTH_MODE_OFF
        VFM.saved.dsEnemyTrackReticle = false
        VFM.dsEnemyPreferredTargetActive = false
        VFM.dsEnemyPreferredTargetName = nil
    elseif VFM.saved.dsBottomOnly then
        VFM.saved.dsBottomOnly = false
    end

    VFM.RequestSettingsSave()
    VFM.RefreshDSEnemyHealthRuntime()
    VFM.RefreshDSSelfHealthRuntime()
    VFM.UpdateCombatVisibility()

    if not silent then
        Print(enabled and "Bottom Dark Souls Magicka and Stamina enabled" or "Bottom Dark Souls Magicka and Stamina disabled")
    end
end

function VFM.SetDSBottomOnly(enabled, silent)
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.dsBottomOnly == enabled then
        return
    end

    VFM.saved.dsBottomOnly = enabled

    if enabled then
        -- Bottom-only means a complete player-resource stack. It can never
        -- coexist with the long enemy Health bar.
        VFM.saved.dsSelfHealthBar = true
        VFM.saved.dsSelfResourceBars = true
        VFM.saved.dsEnemyHealthMode = DS_ENEMY_HEALTH_MODE_OFF
        VFM.saved.dsEnemyTrackReticle = false
        VFM.dsEnemyPreferredTargetActive = false
        VFM.dsEnemyPreferredTargetName = nil
    end

    VFM.RequestSettingsSave()
    VFM.RefreshDSEnemyHealthRuntime()
    VFM.RefreshDSSelfHealthRuntime()
    VFM.UpdateCombatVisibility()

    if not silent then
        Print(enabled and "Bottom Dark Souls player bars only enabled" or "Top-left/native player bars restored")
    end
end

function VFM.SetSavedPosition(key, x, y, applySnap)
    local info = BAR_INFO[key]
    if not info then
        return
    end

    x = Clamp(x, -4000, 4000)
    y = Clamp(y, -2500, 2500)

    if applySnap and VFM.saved.snapToGrid then
        local grid = Clamp(VFM.saved.gridSize, 2, 100)
        x = SnapValue(x, grid)
        y = SnapValue(y, grid)
    end

    VFM.saved[info.xKey] = x
    VFM.saved[info.yKey] = y
    VFM.RequestSettingsSave()
    VFM.RefreshEditDirty()
end

function VFM.CaptureIndividualPositions()
    local controls = VFM.GetPrimaryBarObjects()
    if not controls then
        return false
    end

    local rootX, rootY = GetRootCenter()
    local frame = VFM.GetFrame()
    local frameX, frameY = frame and frame:GetCenter()

    local oldDeltaX = 0
    local oldDeltaY = 0

    if not VFM.saved.individualPositionsInitialized
        and VFM.saved.positionInitialized
        and frameX
        and frameY
        and type(VFM.saved.posX) == "number"
        and type(VFM.saved.posY) == "number" then
        oldDeltaX = VFM.saved.posX - (frameX - rootX)
        oldDeltaY = VFM.saved.posY - (frameY - rootY)
    end

    for _, key in ipairs(BAR_KEYS) do
        local control = controls[key] and controls[key].control
        if not control then
            return false
        end

        local x, y = control:GetCenter()
        if not x or not y then
            return false
        end

        local relativeX = (x - rootX) + oldDeltaX
        local relativeY = (y - rootY) + oldDeltaY

        VFM.vanillaPositions[key] = {
            x = x - rootX,
            y = y - rootY,
        }

        VFM.SetSavedPosition(key, relativeX, relativeY, false)
    end

    VFM.saved.individualPositionsInitialized = true
    return true
end

function VFM.CaptureVanillaPositionsOnly()
    local controls = VFM.GetPrimaryBarObjects()
    if not controls then
        return false
    end

    local rootX, rootY = GetRootCenter()
    for _, key in ipairs(BAR_KEYS) do
        local control = controls[key] and controls[key].control
        local x, y = control and control:GetCenter()
        if not x or not y then
            return false
        end
        VFM.vanillaPositions[key] = {
            x = x - rootX,
            y = y - rootY,
        }
    end
    return true
end

local function GetControlGeometry(control)
    if not control then
        return nil
    end

    local width = tonumber(control:GetWidth()) or 0
    local height = tonumber(control:GetHeight()) or 0
    local scale = tonumber(control:GetScale()) or 1

    return {
        width = width,
        height = height,
        scale = scale,
    }
end

function VFM.CaptureBaseGeometry(force)
    if VFM.baseGeometry and not force then
        return true
    end

    local bars = VFM.GetBars()
    if not bars then
        return false
    end

    VFM.baseGeometry = {}

    for _, bar in ipairs(bars) do
        local control = bar and bar.control
        if control then
            local geometry = GetControlGeometry(control) or {}

            if VFM.IsPrimaryBar(bar) then
                -- ZOS defines the three main player containers as 237x23 at
                -- scale 1. Always use that stock baseline even if this routine
                -- runs after a platform/style refresh while our scale is active.
                geometry.width = NORMAL_WIDTH
                geometry.height = 23
                geometry.scale = 1
            else
                if not geometry.width or geometry.width <= 0 then
                    geometry.width = NORMAL_WIDTH
                end
                if not geometry.height or geometry.height <= 0 then
                    geometry.height = 23
                end
                if not geometry.scale or geometry.scale <= 0 then
                    geometry.scale = 1
                end
            end

            geometry.bgContainer = GetControlGeometry(control:GetNamedChild("BgContainer"))
            geometry.frame = GetControlGeometry(control:GetNamedChild("Frame"))
            geometry.frameLeft = GetControlGeometry(control:GetNamedChild("FrameLeft"))
            geometry.frameRight = GetControlGeometry(control:GetNamedChild("FrameRight"))
            geometry.frameCenter = GetControlGeometry(control:GetNamedChild("FrameCenter"))
            geometry.warner = GetControlGeometry(control:GetNamedChild("Warner"))

            local bg = control:GetNamedChild("BgContainer")
            if bg then
                geometry.bgLeft = GetControlGeometry(bg:GetNamedChild("BgLeft"))
                geometry.bgRight = GetControlGeometry(bg:GetNamedChild("BgRight"))
                geometry.bgCenter = GetControlGeometry(bg:GetNamedChild("BgCenter"))
            end

            local warner = control:GetNamedChild("Warner")
            if warner then
                geometry.warnerLeft = GetControlGeometry(warner:GetNamedChild("Left"))
                geometry.warnerRight = GetControlGeometry(warner:GetNamedChild("Right"))
                geometry.warnerCenter = GetControlGeometry(warner:GetNamedChild("Center"))
            end

            geometry.subBars = {}
            for index, subBar in ipairs(bar.barControls or {}) do
                geometry.subBars[index] = GetControlGeometry(subBar)
            end

            VFM.baseGeometry[control] = geometry
        end
    end

    return true
end

function VFM.GetRawNormalWidth()
    -- The whole native bar is visually scaled with SetTransformScale().
    -- Raw width is compensated so width and thickness stay independent:
    -- final width = raw width * transform scale.
    local thickness = VFM.GetActiveBarThicknessScale()
    local width = VFM.GetActiveBarWidthScale()
    return NORMAL_WIDTH * width / thickness
end

function VFM.GetRawTargetWidthForControl(control, rawNormal, rawShrunk)
    local module = VFM.FindShrinkExpandModule()
    if module and module.barInfo and module.barControls then
        for stat, moduleControl in pairs(module.barControls) do
            if moduleControl == control then
                local info = module.barInfo[stat]
                if info and (info.state == ATTRIBUTE_BAR_STATE_SHRUNK or (info.value and info.value < 0)) then
                    return rawShrunk
                end
                return rawNormal
            end
        end
    end
    return rawNormal
end

function VFM.ApplyShrinkExpandWidths()
    local module = VFM.FindShrinkExpandModule()
    if not module then
        return false
    end

    if not module.vfmOriginalWidths then
        module.vfmOriginalWidths = {
            normal = module.normalWidth,
            expanded = module.expandedWidth,
            shrunk = module.shrunkWidth,
        }
    end

    local original = module.vfmOriginalWidths
    local scale = VFM.GetActiveBarWidthScale()

    -- Keep the proven v9 horizontal sizing model: scale ESO's managed raw
    -- widths and the native bar transform together. Positive max-resource
    -- visuals deliberately use the normal width so buffs can never make the
    -- player bars physically larger than the configured size.
    module.normalWidth = zo_round((original.normal or NORMAL_WIDTH) * scale)
    module.expandedWidth = module.normalWidth
    module.shrunkWidth = zo_round((original.shrunk or SHRUNK_WIDTH) * scale)

    if module.barInfo and module.barControls then
        local owner = module.GetOwner and module:GetOwner() or nil

        for statType, barControl in pairs(module.barControls) do
            local info = module.barInfo[statType]
            if barControl and info then
                if info.animation and info.animation:IsPlaying() then
                    info.animation:Stop()
                end

                local value = tonumber(info.value) or 0
                local state
                local targetWidth

                if value < 0 then
                    state = ATTRIBUTE_BAR_STATE_SHRUNK
                    targetWidth = module.shrunkWidth
                elseif value > 0 then
                    state = ATTRIBUTE_BAR_STATE_EXPANDED
                    targetWidth = module.normalWidth
                else
                    state = ATTRIBUTE_BAR_STATE_NORMAL
                    targetWidth = module.normalWidth
                end

                -- ESO's ShrinkExpand:OnValueChanged only writes the width when
                -- its internal state changes. That makes live slider/wheel
                -- resizing unreliable while the bar remains in the same state.
                -- Apply the target raw width directly every time, using the same
                -- resize callbacks as ESO's own instant-resize path so attached
                -- systems such as the native shield can refresh correctly.
                info.state = state

                if owner and owner.FireCallbacks then
                    owner:FireCallbacks("AttributeBarSizeChangingStart", barControl, state, true)
                    if barControl.bgContainer then
                        owner:FireCallbacks("AttributeBarSizeChangingStart", barControl.bgContainer, state, true)
                    end
                end

                if barControl.SetWidth then
                    barControl:SetWidth(targetWidth)
                end
                if barControl.bgContainer and barControl.bgContainer.SetWidth then
                    barControl.bgContainer:SetWidth(targetWidth)
                end

                if owner and owner.FireCallbacks then
                    owner:FireCallbacks("AttributeBarSizeChangingStopped", barControl, state)
                    if barControl.bgContainer then
                        owner:FireCallbacks("AttributeBarSizeChangingStopped", barControl.bgContainer, state)
                    end
                end
            end
        end
    end

    return true
end

function VFM.SetNativeBarTransform(control, widthScale, thicknessScale, mirrorX)
    if not control then
        return
    end

    widthScale = Clamp(widthScale, 0.50, MAX_BAR_SCALE)
    thicknessScale = Clamp(thicknessScale, 0.50, MAX_BAR_SCALE)

    local appliedXScale = mirrorX and -widthScale or widthScale

    -- ESO exposes independent X and Y transform scales. Dark Souls mode mirrors
    -- Magicka horizontally so its native left-facing artwork and depletion
    -- direction visually match the right-facing Stamina bar. Normal mode always
    -- uses the original positive transform and is therefore unchanged.
    if control.SetTransformScaleX and control.SetTransformScaleY then
        control:SetTransformScaleX(appliedXScale)
        control:SetTransformScaleY(thicknessScale)
    elseif control.SetTransformScale then
        -- Uniform fallback cannot mirror only X without also changing Y. Keep
        -- normal sizing rather than damaging the bar on older clients.
        control:SetTransformScale(widthScale)
    else
        control:SetScale(widthScale)
    end
end

function VFM.ApplyBarGeometry()
    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return false
    end

    local widthScale = VFM.GetActiveBarWidthScale()
    local thicknessScale = VFM.GetActiveBarThicknessScale()

    -- Width and thickness are deliberately independent. The horizontal path is
    -- unchanged from v9. Thickness only changes the Y transform.
    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        local control = bar and bar.control
        if control then
            local mirrorX = VFM.saved and VFM.saved.darkSoulsMode and key == "magicka"
            VFM.SetNativeBarTransform(control, widthScale, thicknessScale, mirrorX)
        end
    end

    -- ESO's shrink/expand visualizer only manages horizontal widths. Keep that
    -- tied to barWidth and lock positive buff expansion to the selected width.
    VFM.ApplyShrinkExpandWidths()

    VFM.AnchorAllBarsToSavedPositions()
    VFM.PositionAllMovers()
    VFM.UpdateAllMoverSizes()
    VFM.UpdateAllMoverLabels()
    VFM.UpdateAllMoverHints()
    return true
end

function VFM.SetDarkSoulsResourceTextHidden(hidden)
    hidden = hidden and true or false

    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return false
    end

    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        local control = bar and bar.control
        local label = control and (control.resourceNumbersLabel or control:GetNamedChild("ResourceNumbers"))
        if label then
            if hidden then
                if label.SetText then
                    label:SetText("")
                end
                if label.SetHidden then
                    label:SetHidden(true)
                end
            else
                if label.SetHidden then
                    label:SetHidden(false)
                end
            end
        end
    end

    return true
end

function VFM.GetLivePrimaryBarResourceValues(bar)
    if not bar then
        return nil, nil
    end

    local unitTag = bar.unitTag or "player"
    local powerType = bar.powerType
    if not GetUnitPower or not powerType then
        return nil, nil
    end

    local current, maximum, effectiveMaximum = GetUnitPower(unitTag, powerType)
    current = tonumber(current)
    maximum = tonumber(maximum)
    effectiveMaximum = tonumber(effectiveMaximum) or 0

    if effectiveMaximum > 0 then
        maximum = effectiveMaximum
    end

    if current == nil or maximum == nil or maximum <= 0 then
        return nil, nil
    end

    current = Clamp(current, 0, maximum)
    return current, maximum
end

function VFM.FormatResourceText(current, maximum)
    local mode = VFM.saved.textMode

    if mode == "hide" then
        return ""
    elseif mode == "current" then
        return FormatNumber(current)
    elseif mode == "currentmax" then
        return string.format("%s / %s", FormatNumber(current), FormatNumber(maximum))
    end

    local percent = 0
    if maximum and maximum > 0 then
        percent = zo_round((current / maximum) * 100)
    end

    if mode == "percent" then
        return string.format("%d%%", percent)
    elseif mode == "currentpercent" then
        return string.format("%s  %d%%", FormatNumber(current), percent)
    end

    return nil
end

function VFM.PatchResourceText()
    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return false
    end

    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        if not bar.vfmOriginalUpdateResourceNumbersLabel then
            bar.vfmOriginalUpdateResourceNumbersLabel = bar.UpdateResourceNumbersLabel

            bar.UpdateResourceNumbersLabel = function(barSelf, current, maximum)
                local label = barSelf.control and barSelf.control.resourceNumbersLabel
                if VFM.saved and VFM.saved.darkSoulsMode then
                    if label then
                        if label.SetText then
                            label:SetText("")
                        end
                        if label.SetHidden then
                            label:SetHidden(true)
                        end
                    end
                    return
                end

                -- Some ESO visual refresh paths call the label updater before
                -- the bar object's cached current/max fields are ready. Never
                -- manufacture a visible "0  0%" value from that transient state.
                current = tonumber(current)
                maximum = tonumber(maximum)
                if current == nil or maximum == nil or maximum <= 0 then
                    local liveCurrent, liveMaximum = VFM.GetLivePrimaryBarResourceValues(barSelf)
                    if liveMaximum then
                        current, maximum = liveCurrent, liveMaximum
                    end
                end

                if VFM.saved.textMode == "default" then
                    if current ~= nil and maximum ~= nil and maximum > 0 then
                        return barSelf.vfmOriginalUpdateResourceNumbersLabel(barSelf, current, maximum)
                    end
                    return
                end

                if label and current ~= nil and maximum ~= nil and maximum > 0 then
                    label:SetText(VFM.FormatResourceText(current, maximum))
                end
            end
        end
    end

    return true
end

function VFM.ApplyTextStyle()
    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return false
    end

    local textScale = Clamp(VFM.saved.textScale, 0.50, 2.50)

    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        local control = bar.control
        local label = control and control.resourceNumbersLabel
        if label then
            if VFM.saved.font == "default" then
                ApplyTemplateToControl(label, ZO_GetPlatformTemplate("ZO_PlayerAttributeResourceNumbers"))
            else
                label:SetFont(VFM.saved.font)
            end

            -- Keep text sizing genuinely independent from bar sizing. Read the
            -- transform actually applied to the native bar instead of assuming
            -- the requested transform succeeded. This avoids the old failure
            -- mode where an unapplied bar transform made inverse-scaled text tiny.
            local parentScaleX, parentScaleY = 1, 1
            if control.GetTransformScale then
                local x, y = control:GetTransformScale()
                parentScaleX = tonumber(x) or 1
                parentScaleY = tonumber(y) or parentScaleX
            end
            if parentScaleX == 0 then parentScaleX = 1 end
            if parentScaleY == 0 then parentScaleY = 1 end

            if label.SetTransformScaleX and label.SetTransformScaleY then
                label:SetTransformScaleX(textScale / parentScaleX)
                label:SetTransformScaleY(textScale / parentScaleY)
            elseif label.SetTransformScale then
                -- Uniform fallback. Current ESO exposes separate X/Y methods,
                -- but use X compensation on older clients rather than allowing
                -- text to balloon with bar width.
                label:SetTransformScale(textScale / parentScaleX)
            else
                label:SetScale(textScale / parentScaleX)
            end
        end

        if VFM.saved.darkSoulsMode then
            if label then
                if label.SetText then
                    label:SetText("")
                end
                if label.SetHidden then
                    label:SetHidden(true)
                end
            end
        else
            if label and label.SetHidden then
                label:SetHidden(false)
            end
            if bar.UpdateResourceNumbersLabel then
                local current, maximum = VFM.GetLivePrimaryBarResourceValues(bar)
                if maximum then
                    bar:UpdateResourceNumbersLabel(current, maximum)
                end
            end
        end
    end

    return true
end

function VFM.EnsureDragCapture()
    if VFM.dragCapture then
        return VFM.dragCapture
    end

    local capture = WINDOW_MANAGER:CreateTopLevelWindow("VanillaFrameMoverDragCapture")
    capture:SetAnchorFill(GuiRoot)
    capture:SetMouseEnabled(true)
    capture:SetMovable(false)
    capture:SetClampedToScreen(false)
    capture:SetDrawLayer(DL_OVERLAY)
    capture:SetDrawTier(DT_HIGH)
    capture:SetDrawLevel(2000)
    capture:SetHidden(true)

    capture:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and VFM.draggingKey then
            VFM.EndManualDrag(VFM.draggingKey)
        end
    end)

    VFM.dragCapture = capture
    return capture
end

function VFM.BeginManualDrag(key)
    if VFM.saved.locked or VFM.draggingKey then
        return
    end

    local mouseX, mouseY = GetMousePosition()
    if not mouseX or not mouseY then
        Print("Could not read mouse position")
        return
    end

    local startX, startY
    if VFM.saved.darkSoulsMode then
        startX = tonumber(VFM.saved.darkSoulsLeft) or DARKSOULS_LEFT
        startY = tonumber(VFM.saved.darkSoulsTop) or DARKSOULS_TOP
        VFM.draggingDarkSoulsStack = true
    else
        startX, startY = VFM.GetSavedPosition(key)
        VFM.draggingDarkSoulsStack = false
    end
    VFM.draggingKey = key
    VFM.dragStartMouseX = mouseX
    VFM.dragStartMouseY = mouseY
    VFM.dragStartX = startX
    VFM.dragStartY = startY

    local moverData = VFM.movers[key]
    if moverData then
        moverData.coords:SetHidden(false)
        if moverData.helper then
            moverData.helper:SetHidden(true)
        end
        moverData.backdrop:SetCenterColor(0.15, 0.75, 1.00, 0.08)
        moverData.backdrop:SetEdgeColor(0.45, 0.90, 1.00, 1.00)
        moverData.label:SetColor(1.00, 1.00, 1.00, 1.00)
    end

    local capture = VFM.EnsureDragCapture()
    capture:SetHidden(false)
    capture:SetMouseEnabled(true)

    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "DragUpdate")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "DragUpdate", 5, function()
        VFM.UpdateManualDrag()
    end)
end

function VFM.UpdateManualDrag()
    local key = VFM.draggingKey
    if not key then
        return
    end

    local mouseX, mouseY = GetMousePosition()
    if not mouseX or not mouseY then
        return
    end

    local x = VFM.dragStartX + (mouseX - VFM.dragStartMouseX)
    local y = VFM.dragStartY + (mouseY - VFM.dragStartMouseY)

    local fineMove = IsShiftKeyDown and IsShiftKeyDown()
    if VFM.saved.snapToGrid and not fineMove then
        local grid = Clamp(VFM.saved.gridSize, 2, 100)
        x = SnapValue(x, grid)
        y = SnapValue(y, grid)
    end

    if VFM.draggingDarkSoulsStack then
        VFM.saved.darkSoulsLeft = x
        VFM.saved.darkSoulsTop = y
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverLabels()
    else
        VFM.SetSavedPosition(key, x, y, false)
        VFM.AnchorBarToSavedPosition(key)
        VFM.PositionMover(key)
        VFM.UpdateMoverLabel(key)
    end
end

function VFM.EndManualDrag(key)
    if VFM.draggingKey ~= key then
        return
    end

    VFM.UpdateManualDrag()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "DragUpdate")
    if VFM.dragCapture then
        VFM.dragCapture:SetMouseEnabled(false)
        VFM.dragCapture:SetHidden(true)
    end

    local fineMove = IsShiftKeyDown and IsShiftKeyDown()
    if VFM.draggingDarkSoulsStack then
        local x = tonumber(VFM.saved.darkSoulsLeft) or DARKSOULS_LEFT
        local y = tonumber(VFM.saved.darkSoulsTop) or DARKSOULS_TOP
        if VFM.saved.snapToGrid and not fineMove then
            local grid = Clamp(VFM.saved.gridSize, 2, 100)
            x = SnapValue(x, grid)
            y = SnapValue(y, grid)
        end
        VFM.saved.darkSoulsLeft = x
        VFM.saved.darkSoulsTop = y
        VFM.RequestSettingsSave()
    else
        local x, y = VFM.GetSavedPosition(key)
        VFM.SetSavedPosition(key, x, y, not fineMove)
    end
    VFM.draggingKey = nil
    VFM.draggingDarkSoulsStack = nil
    VFM.dragStartMouseX = nil
    VFM.dragStartMouseY = nil
    VFM.dragStartX = nil
    VFM.dragStartY = nil

    local moverData = VFM.movers[key]
    if moverData then
        moverData.coords:SetHidden(true)
        moverData.backdrop:SetCenterColor(0.15, 0.75, 1.00, 0.015)
        moverData.backdrop:SetEdgeColor(0.20, 0.75, 1.00, 0.65)
        moverData.label:SetColor(0.72, 0.88, 1.00, 0.95)
    end

    if VFM.saved.darkSoulsMode then
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverLabels()
    else
        VFM.AnchorBarToSavedPosition(key)
        VFM.PositionMover(key)
        VFM.UpdateMoverLabel(key)
    end
end

function VFM.CancelManualDrag()
    if not VFM.draggingKey then
        return
    end

    local key = VFM.draggingKey
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "DragUpdate")
    if VFM.dragCapture then
        VFM.dragCapture:SetMouseEnabled(false)
        VFM.dragCapture:SetHidden(true)
    end
    VFM.draggingKey = nil
    VFM.draggingDarkSoulsStack = nil
    VFM.dragStartMouseX = nil
    VFM.dragStartMouseY = nil
    VFM.dragStartX = nil
    VFM.dragStartY = nil

    local moverData = VFM.movers[key]
    if moverData then
        moverData.coords:SetHidden(true)
        moverData.backdrop:SetCenterColor(0.15, 0.75, 1.00, 0.015)
        moverData.backdrop:SetEdgeColor(0.20, 0.75, 1.00, 0.65)
        moverData.label:SetColor(0.72, 0.88, 1.00, 0.95)
    end
end

function VFM.CreateMover(key)
    if VFM.movers[key] then
        return VFM.movers[key]
    end

    local info = BAR_INFO[key]
    if not info then
        return nil
    end

    local suffix = info.displayName:gsub("%W", "")
    local mover = WINDOW_MANAGER:CreateTopLevelWindow("VanillaFrameMoverHandle" .. suffix)
    mover:SetMovable(false)
    mover:SetMouseEnabled(true)
    mover:SetClampedToScreen(false)
    mover:SetDrawLayer(DL_OVERLAY)
    mover:SetDrawTier(DT_HIGH)
    mover:SetDrawLevel(1000)

    -- Azurah-style edit affordance: a very light cyan outline that hugs the
    -- rendered bar. It is an input target, not a large opaque window.
    local backdrop = WINDOW_MANAGER:CreateControl("VanillaFrameMoverBackdrop" .. suffix, mover, CT_BACKDROP)
    backdrop:SetAnchorFill(mover)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.15, 0.75, 1.00, 0.015)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 3, 0)
    backdrop:SetEdgeColor(0.20, 0.75, 1.00, 0.65)
    backdrop:SetMouseEnabled(false)

    local label = WINDOW_MANAGER:CreateControl("VanillaFrameMoverLabel" .. suffix, mover, CT_LABEL)
    label:SetAnchor(BOTTOM, mover, TOP, 0, -2)
    label:SetFont("ZoFontGameBold")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.72, 0.88, 1.00, 0.95)
    label:SetText(info.displayName)
    label:SetMouseEnabled(false)

    local coords = WINDOW_MANAGER:CreateControl("VanillaFrameMoverCoords" .. suffix, mover, CT_LABEL)
    coords:SetAnchor(TOP, mover, BOTTOM, 0, 2)
    coords:SetFont("ZoFontGame")
    coords:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    coords:SetColor(0.75, 0.90, 1.00, 0.95)
    coords:SetMouseEnabled(false)
    coords:SetHidden(true)

    local helper = WINDOW_MANAGER:CreateControl("VanillaFrameMoverHelper" .. suffix, mover, CT_LABEL)
    helper:SetDimensions(260, 22)
    helper:SetAnchor(TOP, mover, BOTTOM, 0, 3)
    helper:SetFont("ZoFontGame")
    helper:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    helper:SetColor(0.72, 0.82, 0.90, 0.95)
    helper:SetMouseEnabled(false)
    helper:SetHidden(true)

    mover:SetHandler("OnMouseEnter", function()
        if not VFM.saved.locked and VFM.draggingKey ~= key then
            backdrop:SetCenterColor(0.15, 0.75, 1.00, 0.035)
            backdrop:SetEdgeColor(0.35, 0.85, 1.00, 0.95)
            label:SetColor(1.00, 1.00, 1.00, 1.00)
            VFM.UpdateMoverHint(key)
            helper:SetHidden(false)
        end
    end)

    mover:SetHandler("OnMouseExit", function()
        if not VFM.saved.locked and VFM.draggingKey ~= key then
            backdrop:SetCenterColor(0.15, 0.75, 1.00, 0.015)
            backdrop:SetEdgeColor(0.20, 0.75, 1.00, 0.65)
            label:SetColor(0.72, 0.88, 1.00, 0.95)
            helper:SetHidden(true)
        end
    end)

    mover:SetHandler("OnMouseDown", function(_, button)
        if VFM.saved.locked then
            return
        end

        if button == MOUSE_BUTTON_INDEX_RIGHT then
            VFM.UndoBarToEditSnapshot(key)
        elseif button == MOUSE_BUTTON_INDEX_LEFT then
            VFM.BeginManualDrag(key)
        end
    end)

    mover:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            VFM.EndManualDrag(key)
        end
    end)

    mover:SetHandler("OnMouseWheel", function(_, delta)
        if VFM.saved.locked or delta == 0 then
            return
        end

        local change = delta > 0 and 0.05 or -0.05

        if IsShiftKeyDown and IsShiftKeyDown() then
            VFM.SetBarThickness(VFM.saved.barThickness + change, true)
        elseif IsControlKeyDown and IsControlKeyDown() then
            VFM.SetBarWidth(VFM.saved.barWidth + change, true)
        else
            VFM.SetOverallSize(VFM.saved.barWidth + change, true)
        end

        VFM.UpdateAllMoverHints()
    end)

    VFM.movers[key] = {
        control = mover,
        backdrop = backdrop,
        label = label,
        coords = coords,
        helper = helper,
    }

    VFM.PositionMover(key)
    VFM.UpdateMoverSize(key)
    VFM.UpdateMoverLabel(key)
    VFM.UpdateMoverHint(key)
    return VFM.movers[key]
end

function VFM.CreateMovers()
    for _, key in ipairs(BAR_KEYS) do
        VFM.CreateMover(key)
    end
end

function VFM.UpdateMoverLabel(key)
    local moverData = VFM.movers[key]
    if not moverData then
        return
    end

    local x, y = VFM.GetSavedPosition(key)
    local gridText = VFM.saved.snapToGrid and string.format("grid %d", VFM.saved.gridSize) or "grid off"
    moverData.coords:SetText(string.format("X %d   Y %d   %s", zo_round(x), zo_round(y), gridText))
end

function VFM.UpdateMoverHint(key)
    local moverData = VFM.movers[key]
    if not moverData or not moverData.helper then
        return
    end

    moverData.helper:SetText(string.format(
        "Width %d%%   Thickness %d%%",
        zo_round(Clamp(VFM.saved.barWidth, 0.50, MAX_BAR_SCALE) * 100),
        zo_round(Clamp(VFM.saved.barThickness, 0.50, MAX_BAR_SCALE) * 100)
    ))
end

function VFM.UpdateAllMoverHints()
    for _, key in ipairs(BAR_KEYS) do
        VFM.UpdateMoverHint(key)
    end
end

function VFM.UpdateMoverSize(key)
    local moverData = VFM.movers[key]
    local control = VFM.GetPrimaryControl(key)
    if not moverData or not control then
        return
    end

    -- Use the control's actual rendered screen rectangle. This automatically
    -- follows ESO's current normal/shrunk width and our X/Y transforms, so the
    -- edit target never becomes a guessed oversized box.
    local width, height
    if control.GetScreenRect then
        local left, top, right, bottom = control:GetScreenRect()
        if left and top and right and bottom and right > left and bottom > top then
            width = right - left
            height = bottom - top
        end
    end

    if not width or not height then
        width = VFM.GetVisualPrimaryBarWidth()
        height = VFM.GetVisualPrimaryBarHeight()
    end

    moverData.control:SetDimensions(math.max(48, width + 4), math.max(18, height + 4))
end

function VFM.UpdateAllMoverSizes()
    for _, key in ipairs(BAR_KEYS) do
        VFM.UpdateMoverSize(key)
    end
end

function VFM.UpdateAllMoverLabels()
    for _, key in ipairs(BAR_KEYS) do
        VFM.UpdateMoverLabel(key)
    end
end

function VFM.PositionMover(key)
    local moverData = VFM.movers[key]
    if not moverData then
        return
    end

    local control = VFM.GetPrimaryControl(key)
    if control and control.GetScreenRect then
        local left, top, right, bottom = control:GetScreenRect()
        if left and top and right and bottom and right > left and bottom > top then
            local rootLeft = GuiRoot:GetLeft() or 0
            local rootTop = GuiRoot:GetTop() or 0
            moverData.control:ClearAnchors()
            moverData.control:SetAnchor(
                CENTER,
                GuiRoot,
                TOPLEFT,
                ((left + right) / 2) - rootLeft,
                ((top + bottom) / 2) - rootTop
            )
            return
        end
    end

    local x, y = VFM.GetSavedPosition(key)
    moverData.control:ClearAnchors()
    moverData.control:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

function VFM.PositionAllMovers()
    for _, key in ipairs(BAR_KEYS) do
        VFM.PositionMover(key)
    end
end

function VFM.AnchorBarToSavedPosition(key)
    local control = VFM.GetPrimaryControl(key)
    if not control then
        return false
    end

    control:ClearAnchors()
    if VFM.saved and VFM.saved.darkSoulsMode then
        local x, y = VFM.GetDarkSoulsBarCenter(key)
        if not x or not y then
            return false
        end
        control:SetAnchor(CENTER, GuiRoot, TOPLEFT, x, y)
    else
        local x, y = VFM.GetSavedPosition(key)
        control:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    end
    return true
end

function VFM.AnchorAllBarsToSavedPositions()
    for _, key in ipairs(BAR_KEYS) do
        VFM.AnchorBarToSavedPosition(key)
    end
end

function VFM.CreateEditToolbar()
    if VFM.editToolbar then
        return VFM.editToolbar
    end

    local toolbar = WINDOW_MANAGER:CreateTopLevelWindow("VanillaFrameMoverEditToolbar")
    toolbar:SetDimensions(650, 58)
    toolbar:SetAnchor(TOP, GuiRoot, TOP, 0, 40)
    toolbar:SetMouseEnabled(true)
    toolbar:SetMovable(false)
    toolbar:SetClampedToScreen(true)
    toolbar:SetDrawLayer(DL_OVERLAY)
    toolbar:SetDrawTier(DT_HIGH)
    toolbar:SetDrawLevel(3000)
    toolbar:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("VanillaFrameMoverEditToolbarBackdrop", toolbar, CT_BACKDROP)
    backdrop:SetAnchorFill(toolbar)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetCenterColor(0.02, 0.03, 0.04, 0.78)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 3, 0)
    backdrop:SetEdgeColor(0.20, 0.70, 0.95, 0.82)
    backdrop:SetMouseEnabled(false)

    local status = WINDOW_MANAGER:CreateControl("VanillaFrameMoverEditToolbarStatus", toolbar, CT_LABEL)
    status:SetDimensions(96, 28)
    status:SetAnchor(TOPLEFT, toolbar, TOPLEFT, 12, 6)
    status:SetFont("ZoFontGameBold")
    status:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    status:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    status:SetColor(0.80, 0.92, 1.00, 1.00)

    local function NewButton(name, text, width, anchorTo)
        local button = WINDOW_MANAGER:CreateControlFromVirtual(name, toolbar, "ZO_DefaultButton")
        button:SetDimensions(width, 28)
        button:SetText(text)
        button:SetAnchor(LEFT, anchorTo, RIGHT, 5, 0)
        return button
    end

    local saveButton = NewButton("VanillaFrameMoverEditSave", "SAVE & LOCK", 112, status)
    saveButton:SetHandler("OnClicked", function()
        VFM.SetLocked(true, false)
    end)

    local undoButton = NewButton("VanillaFrameMoverEditUndo", "UNDO", 78, saveButton)
    undoButton:SetHandler("OnClicked", function()
        VFM.UndoEditSession()
    end)

    local cancelButton = NewButton("VanillaFrameMoverEditCancel", "CANCEL", 82, undoButton)
    cancelButton:SetHandler("OnClicked", function()
        VFM.CancelEditSession()
    end)

    local gridButton = NewButton("VanillaFrameMoverEditGrid", "GRID", 96, cancelButton)
    gridButton:SetHandler("OnClicked", function()
        VFM.SetSnapToGrid(not VFM.saved.snapToGrid)
    end)

    local help = WINDOW_MANAGER:CreateControl("VanillaFrameMoverEditToolbarHelp", toolbar, CT_LABEL)
    help:SetDimensions(626, 18)
    help:SetAnchor(BOTTOM, toolbar, BOTTOM, 0, -5)
    help:SetFont("ZoFontGameSmall")
    help:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    help:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    help:SetColor(0.72, 0.82, 0.90, 0.95)
    help:SetText("Drag to move   Wheel resize   Shift + Wheel thickness   Ctrl + Wheel width   Shift + Drag fine move")
    help:SetMouseEnabled(false)

    VFM.editToolbar = {
        control = toolbar,
        backdrop = backdrop,
        status = status,
        help = help,
        saveButton = saveButton,
        undoButton = undoButton,
        cancelButton = cancelButton,
        gridButton = gridButton,
    }

    VFM.UpdateEditToolbar()
    return VFM.editToolbar
end

function VFM.UpdateEditToolbar()
    local toolbar = VFM.editToolbar
    if not toolbar then
        return
    end

    toolbar.control:SetHidden(VFM.saved.locked)
    if VFM.saved.locked then
        return
    end

    if VFM.editDirty then
        toolbar.status:SetText("|cFFD36AUNSAVED|r")
    else
        toolbar.status:SetText("|c7FD5FFEDITING|r")
    end

    if VFM.saved.snapToGrid then
        toolbar.gridButton:SetText(string.format("GRID %d", zo_round(VFM.saved.gridSize or 10)))
    else
        toolbar.gridButton:SetText("GRID OFF")
    end

    if toolbar.undoButton.SetEnabled then
        toolbar.undoButton:SetEnabled(VFM.editDirty)
    end
end

function VFM.CheckAzurahCompatibility()
    if VFM.azurahConflictWarned or not Azurah or not Azurah.CheckModified then
        return
    end

    local modified = {}
    local names = {
        "ZO_PlayerAttributeHealth",
        "ZO_PlayerAttributeMagicka",
        "ZO_PlayerAttributeStamina",
    }

    for _, name in ipairs(names) do
        local scale = Azurah:CheckModified(name)
        if scale then
            modified[#modified + 1] = name:gsub("ZO_PlayerAttribute", "")
        end
    end

    if #modified > 0 then
        VFM.azurahConflictWarned = true
        Print("Azurah is also scaling: " .. table.concat(modified, ", ") .. ". Reset those attribute frame scale changes in Azurah to avoid both addons controlling the same bars.")
    end
end

-- LUI Extended's Unit Frames module deliberately clears and re-anchors ESO's
-- default Health/Magicka/Stamina controls during its initialization. VFM owns
-- those same native controls, so when LUIE runs after VFM it can make the bars
-- look as if VFM reset even though VFM's SavedVariables are still correct.
-- Keep VFM authoritative without changing any LUIE settings.
function VFM.InstallLuiCompatibilityHook()
    if VFM.luiCompatibilityHookInstalled then
        return true
    end

    local unitFrames = LUIE and LUIE.UnitFrames
    if not unitFrames or type(unitFrames.RepositionDefaultFrames) ~= "function" then
        return false
    end

    local function ReapplyAfterLui()
        zo_callLater(function()
            -- Do not gate the repair on runtimeReady. The three native controls
            -- can already exist even when optional frame/base-geometry capture
            -- has not completed after /reloadui.
            if not VFM.RepairLayoutDrift("LUIE_RepositionDefaultFrames", true) then
                VFM.ScheduleApply(0)
            end
        end, 0)
    end

    -- Wrap the LUIE method directly instead of relying on hook-library calling
    -- conventions. RepositionDefaultFrames has no useful return value, and this
    -- guarantees our repair is scheduled after LUIE's own ClearAnchors/SetAnchor pass.
    local original = unitFrames.RepositionDefaultFrames
    unitFrames.RepositionDefaultFrames = function(...)
        original(...)
        ReapplyAfterLui()
    end

    VFM.luiCompatibilityHookInstalled = true
    return true
end

function VFM.GetLayoutDrift()
    -- Saved layout enforcement only needs the three native player bars. It must
    -- remain usable during reload startup even if PrepareRuntime has not yet
    -- completed optional capture work.
    if not VFM.saved then
        return false, false, false
    end

    local positionDrift = false
    local transformDrift = false
    local widthDrift = false
    local wantedXScale = VFM.GetActiveBarWidthScale()
    local wantedYScale = VFM.GetActiveBarThicknessScale()

    local module = VFM.FindShrinkExpandModule()
    local wantedNormal = zo_round(NORMAL_WIDTH * wantedXScale)
    local wantedShrunk = zo_round(SHRUNK_WIDTH * wantedXScale)

    for _, key in ipairs(BAR_KEYS) do
        local control = VFM.GetPrimaryControl(key)
        if not control then
            return false, false, false
        end

        local cx, cy = control:GetCenter()
        local expectedX, expectedY = VFM.GetExpectedBarCenter(key)
        if not cx or not cy or not expectedX or not expectedY
            or math.abs(cx - expectedX) > 1.5 or math.abs(cy - expectedY) > 1.5 then
            positionDrift = true
        end

        if control.GetTransformScale then
            local tx, ty = control:GetTransformScale()
            tx = tonumber(tx) or 1
            ty = tonumber(ty) or tx
            local expectedXScale = wantedXScale
            if VFM.saved.darkSoulsMode and key == "magicka" and control.SetTransformScaleX then
                expectedXScale = -wantedXScale
            end
            if math.abs(tx - expectedXScale) > 0.01 or math.abs(ty - wantedYScale) > 0.01 then
                transformDrift = true
            end
        end

        if module and module.barInfo and module.barControls then
            for statType, moduleControl in pairs(module.barControls) do
                if moduleControl == control then
                    local info = module.barInfo[statType]
                    local expectedWidth = wantedNormal
                    if info and (info.state == ATTRIBUTE_BAR_STATE_SHRUNK or (tonumber(info.value) or 0) < 0) then
                        expectedWidth = wantedShrunk
                    end
                    local actualWidth = tonumber(control:GetWidth()) or 0
                    if math.abs(actualWidth - expectedWidth) > 1.5 then
                        widthDrift = true
                    end
                    break
                end
            end
        end
    end

    if module then
        if math.abs((tonumber(module.normalWidth) or 0) - wantedNormal) > 1.5
            or math.abs((tonumber(module.expandedWidth) or 0) - wantedNormal) > 1.5
            or math.abs((tonumber(module.shrunkWidth) or 0) - wantedShrunk) > 1.5 then
            widthDrift = true
        end
    end

    return positionDrift, transformDrift, widthDrift
end

function VFM.RepairLayoutDrift(reason, force)
    if not VFM.saved or VFM.draggingKey or not VFM.GetPrimaryBarObjects() then
        return false
    end

    local positionDrift, transformDrift, widthDrift = VFM.GetLayoutDrift()
    local healthStyleDrift = VFM.GetDarkSoulsHealthStyleDrift()
    if not force and not positionDrift and not transformDrift and not widthDrift and not healthStyleDrift then
        return false
    end

    if transformDrift or widthDrift or force then
        VFM.ApplyBarGeometry()
        VFM.ApplyTextStyle()
    elseif positionDrift then
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
    end

    if VFM.saved.darkSoulsMode and (healthStyleDrift or force or positionDrift or transformDrift or widthDrift) then
        VFM.ApplyDarkSoulsHealthStyle()
    end
    -- ApplyBarGeometry also anchors all three bars, but do this explicitly on a
    -- forced compatibility pass so there is no dependency on geometry state.
    if force then
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
    end

    VFM.layoutRepairCount = (tonumber(VFM.layoutRepairCount) or 0) + 1
    VFM.lastLayoutRepairReason = tostring(reason or "unknown")
    VFM.lastLayoutRepairAt = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0

    if VFM.debug and reason then
        Print("Layout repaired after " .. tostring(reason))
    end
    return true
end

function VFM.PrintConflictStatus()
    local positionDrift, transformDrift, widthDrift = VFM.GetLayoutDrift()
    local unitFrames = LUIE and LUIE.UnitFrames
    local luiLoaded = unitFrames ~= nil
    local luiReposition = unitFrames and unitFrames.SV and unitFrames.SV.RepositionFrames

    Print(string.format(
        "Conflict status: ready=%s LUIE=%s hook=%s LUIE-RepositionFrames=%s drift(position=%s scale=%s width=%s) repairs=%d last=%s",
        tostring(VFM.runtimeReady and true or false),
        tostring(luiLoaded),
        tostring(VFM.luiCompatibilityHookInstalled and true or false),
        tostring(luiReposition),
        tostring(positionDrift),
        tostring(transformDrift),
        tostring(widthDrift),
        tonumber(VFM.layoutRepairCount) or 0,
        tostring(VFM.lastLayoutRepairReason or "none")
    ))
    Print(string.format(
        "Runtime: prepare=%s direct=%s slashOwner=%s darksouls=%s hideActionBar=%s",
        tostring(VFM.lastPrepareFailure or "none"),
        tostring(VFM.lastDirectApplyReason or "none"),
        tostring(VFM.slashHandler ~= nil and SLASH_COMMANDS and SLASH_COMMANDS["/vfm"] == VFM.slashHandler),
        tostring(VFM.saved and VFM.saved.darkSoulsMode and true or false),
        tostring(VFM.saved and VFM.saved.hideActionBar and true or false)
    ))

    local rootX, rootY = GetRootCenter()
    for _, key in ipairs(BAR_KEYS) do
        local control = VFM.GetPrimaryControl(key)
        if control then
            local cx, cy = control:GetCenter()
            local tx, ty = 1, 1
            if control.GetTransformScale then
                tx, ty = control:GetTransformScale()
                tx = tonumber(tx) or 1
                ty = tonumber(ty) or tx
            end
            Print(string.format(
                "%s saved=%.0f,%.0f actual=%.0f,%.0f rawW=%.0f transform=%.2fx%.2f",
                BAR_INFO[key].displayName,
                select(1, VFM.GetSavedPosition(key)), select(2, VFM.GetSavedPosition(key)),
                cx and (cx - rootX) or 0, cy and (cy - rootY) or 0,
                tonumber(control:GetWidth()) or 0, tx, ty
            ))
        end
    end
end

function VFM.IsChampionProgressActive()
    local progressBar = PLAYER_PROGRESS_BAR
    if not progressBar or not PPB_CLASS_CP or not progressBar.GetBarTypeInfo then
        return false
    end

    local barTypeInfo = progressBar:GetBarTypeInfo()
    return barTypeInfo and barTypeInfo.barTypeClass == PPB_CLASS_CP
end

function VFM.GetChampionProgressVisibilityMode()
    if not VFM.saved then return "show" end

    -- 1.0.66 stores the full four-state mode directly. Older profiles used two
    -- booleans, so preserve those as a compatibility fallback.
    local stored = tostring(VFM.saved.championProgressVisibilityMode or "")
    if stored == "show" or stored == "combat" or stored == "pvp" or stored == "hide" then
        return stored
    end
    if VFM.saved.hideChampionProgress == true then return "hide" end
    if VFM.saved.hideChampionProgressInPvp == true then return "pvp" end
    return "show"
end

function VFM.ShouldHideChampionProgress(isPvpContext, isCombatContext)
    local mode = VFM.GetChampionProgressVisibilityMode()
    if mode == "hide" then return true end
    if mode == "combat" then
        if isCombatContext == nil then
            if IsUnitInCombat then
                isCombatContext = IsUnitInCombat("player") and true or false
            else
                isCombatContext = VFM.inCombat and true or false
            end
        end
        return isCombatContext and true or false
    end
    if mode == "pvp" then
        if isPvpContext == nil then isPvpContext = VFM.IsPvpUiContext() end
        return isPvpContext and true or false
    end
    return false
end

function VFM.SetChampionProgressAlwaysFragments(enabled)
    enabled = enabled and true or false

    local mainFragment = PLAYER_PROGRESS_BAR_FRAGMENT
    local currentFragment = PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT
    if not mainFragment or not currentFragment then
        return false
    end

    local hudScene = HUD_SCENE or (SCENE_MANAGER and SCENE_MANAGER.GetScene and SCENE_MANAGER:GetScene("hud"))
    local hudUiScene = HUD_UI_SCENE or (SCENE_MANAGER and SCENE_MANAGER.GetScene and SCENE_MANAGER:GetScene("hudui"))
    if not hudScene and not hudUiScene then
        return false
    end

    if enabled then
        if VFM.championProgressAlwaysFragmentsAdded then
            return true
        end
        if hudScene and hudScene.AddFragment then
            hudScene:AddFragment(mainFragment)
            hudScene:AddFragment(currentFragment)
        end
        if hudUiScene and hudUiScene.AddFragment then
            hudUiScene:AddFragment(mainFragment)
            hudUiScene:AddFragment(currentFragment)
        end
        VFM.championProgressAlwaysFragmentsAdded = true
        return true
    end

    if not VFM.championProgressAlwaysFragmentsAdded then
        return true
    end
    if hudScene and hudScene.RemoveFragment then
        hudScene:RemoveFragment(mainFragment)
        hudScene:RemoveFragment(currentFragment)
    end
    if hudUiScene and hudUiScene.RemoveFragment then
        hudUiScene:RemoveFragment(mainFragment)
        hudUiScene:RemoveFragment(currentFragment)
    end
    VFM.championProgressAlwaysFragmentsAdded = nil
    return true
end

function VFM.ApplyChampionProgressVisibility(forceRelease)
    if not VFM.saved then return false end

    local progressBar = PLAYER_PROGRESS_BAR
    local control = progressBar and progressBar.control
    if not control then return false end

    local mode = VFM.GetChampionProgressVisibilityMode()

    -- ESO's CP/XP progress bar is scene-fragment driven. Merely calling
    -- SetHidden(false) cannot make it persistent because the stock HUD removes
    -- its current-progress fragment again. In Show Always mode, attach the two
    -- stock progress fragments to both gameplay HUD scenes. This keeps the real
    -- native CP bar visible and still lets skill/XP gain animations temporarily
    -- take over before returning to Champion progress.
    if mode == "show" then
        VFM.SetChampionProgressAlwaysFragments(true)
        VFM.championProgressHiddenByAddon = nil

        if PPB_CP and CanUnitGainChampionPoints and CanUnitGainChampionPoints("player") then
            if progressBar.SetBaseType and progressBar.baseType ~= PPB_CP then
                progressBar:SetBaseType(PPB_CP)
            end
            local hasIncreaseOwner = progressBar.GetOwner and progressBar:GetOwner() ~= nil
            local hasPendingIncrease = progressBar.pendingShowIncrease ~= nil
            if not hasIncreaseOwner and not hasPendingIncrease then
                local controlHidden = control.IsHidden and control:IsHidden() or false
                if not VFM.IsChampionProgressActive()
                    or progressBar.barState == ZO_STATE.HIDDEN
                    or progressBar.barState == ZO_STATE.HIDING
                    or controlHidden then
                    if progressBar.ShowCurrent then progressBar:ShowCurrent(PPB_CP) end
                end
            end
        end
        return true
    end

    -- Hide modes must first release the extra HUD fragments added by Show
    -- Always. From this point ESO owns the normal progress-bar scene behavior.
    VFM.SetChampionProgressAlwaysFragments(false)

    local shouldHide = VFM.ShouldHideChampionProgress()
    if shouldHide and VFM.IsChampionProgressActive() then
        -- Keep only the Champion Point class invisible. ESO remains free to use
        -- the same PlayerProgressBar for XP and skill progression.
        control:SetHidden(true)
        control:SetAlpha(0)
        VFM.championProgressHiddenByAddon = true
        return true
    end

    if VFM.championProgressHiddenByAddon == true or forceRelease == true then
        VFM.championProgressHiddenByAddon = nil
        if progressBar.RefreshAlpha then progressBar:RefreshAlpha() end
        if VFM.IsChampionProgressActive()
            and progressBar.barState ~= ZO_STATE.HIDDEN
            and progressBar.barState ~= ZO_STATE.HIDING then
            control:SetHidden(false)
        end
    end
    return false
end

function VFM.ApplyChampionProgressHidden()
    -- Compatibility wrapper retained for older Ultivite call sites.
    return VFM.ApplyChampionProgressVisibility(false)
end


function VFM.IsReticleOverTeammatePlayer()
    if not DoesUnitExist or not DoesUnitExist("reticleover") then return false end
    if not IsUnitPlayer or not IsUnitPlayer("reticleover") then return false end
    if AreUnitsEqual and AreUnitsEqual("player", "reticleover") then return false end

    if IsUnitGrouped and IsUnitGrouped("reticleover") then
        return true
    end
    if AreUnitsCurrentlyAllied and AreUnitsCurrentlyAllied("player", "reticleover") then
        return true
    end
    return false
end

function VFM.CreateTeammateCpReticleControl()
    if VFM.teammateCpReticleControl then return VFM.teammateCpReticleControl end

    local control = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteTeammateCpReticle")
    control:SetDimensions(260, 34)
    control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 52)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLevel(1800)
    control:SetMouseEnabled(false)
    control:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("UltiviteTeammateCpReticleLabel", control, CT_LABEL)
    label:SetAnchor(CENTER, control, CENTER, 0, 0)
    label:SetFont("ZoFontGameBold")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(0.55, 0.85, 1.00, 1.00)
    label:SetText("")
    control.label = label

    VFM.teammateCpReticleControl = control
    return control
end

function VFM.UpdateTeammateCpReticle()
    -- Retired in Ultivite 1.0.65. Champion Points now belong in the target
    -- frame path, matching ESO's native level / Champion presentation.
    if VFM.teammateCpReticleControl then
        VFM.teammateCpReticleControl:SetHidden(true)
    end
    return false
end

function VFM.SetShowTeammateCpReticle(enabled, silent)
    -- Legacy compatibility only. Never recreate the old center-screen CP label.
    if not VFM.saved then return end
    VFM.saved.showTeammateCpReticle = false
    VFM.RequestSettingsSave()
    VFM.UpdateTeammateCpReticle()
    if not silent then
        Print("Reticle Champion Point label retired; player CP is shown through target-frame settings")
    end
end

function VFM.GetWerewolfResourceBarControl()
    local control = _G["ZO_PlayerAttributeWerewolf"]
    if control then return control end

    local root = _G["ZO_PlayerAttribute"]
    if root and root.GetNamedChild then
        local ok, child = pcall(root.GetNamedChild, root, "Werewolf")
        if ok and child then return child end
    end
    return nil
end

function VFM.ApplyWerewolfResourceBarVisibility()
    if not VFM.saved then return false end
    local control = VFM.GetWerewolfResourceBarControl()
    if not control then return false end

    if VFM.saved.hideWerewolfResourceBar == true then
        if control.SetHidden then pcall(control.SetHidden, control, true) end
        if control.SetAlpha then pcall(control.SetAlpha, control, 0) end
        VFM.werewolfHiddenByAddon = true
        return true
    end

    if control.SetAlpha then pcall(control.SetAlpha, control, 1) end

    -- OFF must release a hidden state that Ultivite itself applied. Only show it
    -- immediately while transformed so the native meter is not exposed normally.
    if VFM.werewolfHiddenByAddon == true then
        VFM.werewolfHiddenByAddon = false
        local transformed = false
        if type(IsWerewolf) == "function" then
            local ok, result = pcall(IsWerewolf)
            transformed = ok and result == true
        end
        if transformed and control.SetHidden then
            pcall(control.SetHidden, control, false)
        end
    end
    return true
end

function VFM.SetHideWerewolfResourceBar(enabled, silent)
    if not VFM.saved then return end
    VFM.saved.hideWerewolfResourceBar = enabled and true or false
    VFM.RequestSettingsSave()
    VFM.ApplyWerewolfResourceBarVisibility()
    if not silent then
        Print(VFM.saved.hideWerewolfResourceBar and "Werewolf resource meter hidden" or "Werewolf resource meter returned to ESO control")
    end
end

function VFM.GetMountStaminaBarObject()
    local bars = VFM.GetBars()
    if not bars then return nil end

    for _, bar in ipairs(bars) do
        if bar and bar.powerType == COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA then
            return bar
        end
    end
    return nil
end

function VFM.GetMountStaminaBarControl()
    local control = _G["ZO_PlayerAttributeMountStamina"]
    if control then return control end

    local root = _G["ZO_PlayerAttribute"]
    if root and root.GetNamedChild then
        local ok, child = pcall(root.GetNamedChild, root, "MountStamina")
        if ok and child then return child end
    end
    return nil
end

function VFM.InstallMountStaminaVisibilityRequirement()
    local bar = VFM.GetMountStaminaBarObject()
    if not bar or not bar.SetExternalVisibilityRequirement then
        return false
    end

    local shouldOwn = VFM.saved and VFM.saved.hideMountStaminaBar ~= false

    if shouldOwn then
        if not bar.vfmMountRequirementWrapper
            or bar.externalVisibilityRequirement ~= bar.vfmMountRequirementWrapper then
            local originalRequirement = bar.externalVisibilityRequirement
            if originalRequirement == bar.vfmMountRequirementWrapper then
                originalRequirement = bar.vfmOriginalMountVisibilityRequirement
            end

            bar.vfmOriginalMountVisibilityRequirement = originalRequirement
            local wrapper = function()
                if VFM.saved and VFM.saved.hideMountStaminaBar ~= false then
                    return false
                end
                if originalRequirement then
                    return originalRequirement()
                end
                return true
            end

            bar.vfmMountRequirementWrapper = wrapper
            bar:SetExternalVisibilityRequirement(wrapper)
        end
        return true
    end

    if bar.vfmMountRequirementWrapper
        and bar.externalVisibilityRequirement == bar.vfmMountRequirementWrapper then
        bar:SetExternalVisibilityRequirement(bar.vfmOriginalMountVisibilityRequirement)
    end
    return true
end

function VFM.ApplyMountStaminaBarVisibility()
    if not VFM.saved then return false end

    local bar = VFM.GetMountStaminaBarObject()
    local control = (bar and bar.control) or VFM.GetMountStaminaBarControl()
    if not control then return false end

    VFM.InstallMountStaminaVisibilityRequirement()

    if VFM.saved.hideMountStaminaBar ~= false then
        if bar and bar.timeline and bar.timeline.PlayInstantlyToStart then
            pcall(bar.timeline.PlayInstantlyToStart, bar.timeline, true)
        end
        if bar then
            bar.isContextuallyShown = false
            bar.vfmMountHardHidden = true
        end
        if control.SetAlpha then pcall(control.SetAlpha, control, 0) end
        if control.SetHidden then pcall(control.SetHidden, control, true) end
        return true
    end

    if bar and bar.vfmMountHardHidden then
        bar.vfmMountHardHidden = nil
    end

    -- Return ownership to ESO rather than forcing the meter visible. ESO's
    -- native requirement shows this bar only while mounted.
    if control.SetHidden then pcall(control.SetHidden, control, false) end
    if control.SetAlpha then pcall(control.SetAlpha, control, 1) end
    if bar and bar.UpdateContextualFading then
        pcall(bar.UpdateContextualFading, bar)
    end
    return true
end

function VFM.SetHideMountStaminaBar(enabled, silent)
    if not VFM.saved then return end
    VFM.saved.hideMountStaminaBar = enabled and true or false
    VFM.RequestSettingsSave()
    VFM.ApplyMountStaminaBarVisibility()
    if not silent then
        Print(VFM.saved.hideMountStaminaBar and "Mount stamina meter hidden" or "Mount stamina meter returned to ESO control")
    end
end

function VFM.InstallChampionProgressHook()
    if VFM.championProgressHookInstalled then
        return true
    end

    local progressBar = PLAYER_PROGRESS_BAR
    if not progressBar or type(progressBar.Show) ~= "function" then
        return false
    end

    local originalShow = progressBar.Show
    progressBar.Show = function(barSelf, ...)
        originalShow(barSelf, ...)

        if VFM.saved and VFM.ShouldHideChampionProgress() and barSelf.GetBarTypeInfo then
            local barTypeInfo = barSelf:GetBarTypeInfo()
            if barTypeInfo and barTypeInfo.barTypeClass == PPB_CLASS_CP and barSelf.control then
                barSelf.control:SetHidden(true)
                barSelf.control:SetAlpha(0)
                VFM.championProgressHiddenByAddon = true
            end
        end
    end

    VFM.championProgressHookInstalled = true
    return true
end

function VFM.SetChampionProgressVisibilityMode(mode, silent)
    if not VFM.saved then return end
    mode = tostring(mode or "show")
    if mode ~= "hide" and mode ~= "pvp" and mode ~= "combat" then mode = "show" end

    VFM.saved.championProgressVisibilityMode = mode

    -- Keep the old flags synchronized for rollback compatibility. Combat is a
    -- new mode, so both legacy hide flags remain false in that state.
    VFM.saved.hideChampionProgress = mode == "hide"
    VFM.saved.hideChampionProgressInPvp = mode == "pvp"
    VFM.RequestSettingsSave()
    VFM.InstallChampionProgressHook()
    VFM.ApplyChampionProgressVisibility(true)

    if not silent then
        local labels = {
            show = "shown on the gameplay HUD",
            combat = "hidden while in combat",
            pvp = "hidden in PvP only",
            hide = "hidden always",
        }
        Print("Champion Point progress " .. (labels[mode] or labels.show))
    end
end

function VFM.SetHideChampionProgress(enabled, silent)
    -- Legacy API: ON still means Hide Always; OFF maps to the visible HUD mode.
    VFM.SetChampionProgressVisibilityMode(enabled and "hide" or "show", silent)
end

-- Legacy queue suppressor state is retained only so an upgrade can restore a
-- control hidden by an older Ultivite build. The former discovery/scanning code
-- is intentionally gone. Current queue visibility uses explicit control names
-- through RefreshUiVisibilityRules below.
function VFM.RestoreBattlegroundQueueStatus()
    if not VFM.battlegroundQueueSuppressedControls then
        return
    end

    for control, wasHidden in pairs(VFM.battlegroundQueueSuppressedControls) do
        if control and control.SetHidden then
            pcall(control.SetHidden, control, wasHidden and true or false)
        end
    end

    VFM.battlegroundQueueSuppressedControls = {}
end

function VFM.RefreshBattlegroundQueueSuppressor()
    -- Retired in Ultivite 1.0.13. The previous implementation could not
    -- reliably identify every Battleground queue overlay without unsafe or
    -- addon-specific UI discovery. Keep the old SavedVariables value intact,
    -- but perform no scans and release anything an older version suppressed.
    local updateName = ADDON_NAME .. "BattlegroundQueueSuppressor"
    EVENT_MANAGER:UnregisterForUpdate(updateName)
    VFM.RestoreBattlegroundQueueStatus()
end

function VFM.SetHideBattlegroundQueueStatus(enabled, silent)
    -- Legacy value retained only so an upgrade never deletes a user's setting.
    enabled = enabled and true or false
    if not VFM.saved or VFM.saved.hideBattlegroundQueueStatus == enabled then
        VFM.RefreshBattlegroundQueueSuppressor()
        return
    end

    VFM.saved.hideBattlegroundQueueStatus = enabled
    VFM.RequestSettingsSave()
    VFM.RefreshBattlegroundQueueSuppressor()

    if not silent then
        Print("Battleground queue hiding is retired because the queue overlay cannot be identified reliably")
    end
end

local UI_VISIBILITY_SHOW = "show"
local UI_VISIBILITY_HIDE = "hide"
local UI_VISIBILITY_PVP = "pvp"
local UI_VISIBILITY_COMBAT = "combat"
local UI_VISIBILITY_COMBAT_ONLY = "combatOnly"
local UI_VISIBILITY_PVP_ONLY = "pvpOnly"

local UI_VISIBILITY_SETTING_KEYS = {
    compass = "compassVisibilityMode",
    quests = "questTrackerVisibilityMode",
    queue = "queueStatusVisibilityMode",
    crosshair = "crosshairVisibilityMode",
}

local UI_VISIBILITY_CONTROL_NAMES = {
    compass = { "ZO_CompassFrame" },
    quests = { "ZO_FocusedQuestTrackerPanel" },
    -- Hide only the crosshair texture, not the whole reticle container. This
    -- preserves interaction text, stealth/disguise UI and other reticle prompts.
    crosshair = { "ZO_ReticleContainerReticle" },
    -- Queue/status UI has changed across ESO releases and can also be supplied by
    -- other addons. These are deliberately only explicit names. Never scan _G or
    -- walk GuiRoot looking for queue text. Unknown overlays are left untouched.
    queue = {
        "ZO_ActivityTracker",
        "ZO_ActivityTrackerPanel",
        "ZO_ActivityFinderStatus",
        "ZO_BattlegroundFinderStatus",
    },
}

-- ESO can disable the Quest Tracker independently from its HUD control.
-- Manage that public setting while Ultivite owns a quest visibility rule so
-- leaving PvP restores a usable tracker. The compass has no equivalent master
-- UI visibility setting. UI_SETTING_COMPASS_ACTIVE_QUESTS controls quest pins
-- on the compass, not the compass frame itself, so Ultivite must not alter it.
-- These writes are runtime-only and never replace persisted UserSettings.
local UI_VISIBILITY_NATIVE_SETTINGS = {
    quests = {
        {
            key = "questTracker",
            system = function() return SETTING_TYPE_UI end,
            id = function() return UI_SETTING_SHOW_QUEST_TRACKER end,
            hidden = function() return 0 end,
            visible = function() return 1 end,
        },
    },
}

local function ResolveUiVisibilityNativeValue(value)
    if type(value) ~= "function" then return value end
    local ok, result = pcall(value)
    if not ok then return nil end
    return result
end

function VFM.GetUiVisibilityNativeSetting(systemType, settingId)
    if not GetSetting or systemType == nil or settingId == nil then return nil end
    local ok, value = pcall(GetSetting, systemType, settingId)
    if not ok or value == nil then return nil end
    return tostring(value)
end

function VFM.SetUiVisibilityNativeSetting(systemType, settingId, value)
    if not SetSetting or systemType == nil or settingId == nil or value == nil then return false end
    value = tostring(value)
    if VFM.GetUiVisibilityNativeSetting(systemType, settingId) == value then return true end

    -- Runtime-only is intentional. Ultivite owns the effective setting only
    -- while its conditional visibility rule is actively hiding the element.
    local option = SETTINGS_SET_OPTION_DO_NOT_SAVE_TO_PERSISTED_DATA
    local ok
    if option ~= nil then
        ok = pcall(SetSetting, systemType, settingId, value, option)
    else
        ok = pcall(SetSetting, systemType, settingId, value)
    end
    if not ok then return false end
    return VFM.GetUiVisibilityNativeSetting(systemType, settingId) == value
end

function VFM.ApplyNativeUiVisibilityRule(kind, mode, shouldHide)
    local settings = UI_VISIBILITY_NATIVE_SETTINGS[kind]
    if not settings then return end

    VFM.uiVisibilityNativeManaged = VFM.uiVisibilityNativeManaged or {}
    VFM.uiVisibilityNativeSnapshots = VFM.uiVisibilityNativeSnapshots or {}

    if shouldHide then
        if VFM.uiVisibilityNativeManaged[kind] ~= true then
            local snapshot = {}
            for _, setting in ipairs(settings) do
                local systemType = ResolveUiVisibilityNativeValue(setting.system)
                local settingId = ResolveUiVisibilityNativeValue(setting.id)
                snapshot[setting.key] = VFM.GetUiVisibilityNativeSetting(systemType, settingId)
            end
            VFM.uiVisibilityNativeSnapshots[kind] = snapshot
        end

        for _, setting in ipairs(settings) do
            local systemType = ResolveUiVisibilityNativeValue(setting.system)
            local settingId = ResolveUiVisibilityNativeValue(setting.id)
            local desired = ResolveUiVisibilityNativeValue(setting.hidden)
            VFM.SetUiVisibilityNativeSetting(systemType, settingId, desired)
        end
        VFM.uiVisibilityNativeManaged[kind] = true
        return
    end

    if VFM.uiVisibilityNativeManaged[kind] == true then
        -- The condition ended or the rule was returned to Show. Restore the exact
        -- value ESO had when Ultivite took ownership instead of forcing it ON.
        local snapshot = VFM.uiVisibilityNativeSnapshots[kind] or {}
        for _, setting in ipairs(settings) do
            local systemType = ResolveUiVisibilityNativeValue(setting.system)
            local settingId = ResolveUiVisibilityNativeValue(setting.id)
            local desired = snapshot[setting.key]
            if desired == nil or desired == "" then
                desired = ResolveUiVisibilityNativeValue(setting.visible)
            end
            VFM.SetUiVisibilityNativeSetting(systemType, settingId, desired)
        end
        VFM.uiVisibilityNativeManaged[kind] = nil
        VFM.uiVisibilityNativeSnapshots[kind] = nil
    end
end

function VFM.IsPvpUiContext()
    -- Keep this deliberately strict. The rule is about where the player is
    -- physically located, not campaign assignment, queue state or a broad AvA
    -- world flag that can remain true during transitions.
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then return true end
    if IsInImperialCity and IsInImperialCity() then return true end
    if IsInCyrodiil and IsInCyrodiil() then return true end
    return false
end

function VFM.NormalizeUiVisibilityMode(mode)
    mode = tostring(mode or UI_VISIBILITY_SHOW)
    if mode == UI_VISIBILITY_HIDE
        or mode == UI_VISIBILITY_PVP
        or mode == UI_VISIBILITY_COMBAT
        or mode == UI_VISIBILITY_COMBAT_ONLY
        or mode == UI_VISIBILITY_PVP_ONLY then
        return mode
    end
    return UI_VISIBILITY_SHOW
end

function VFM.GetUiVisibilityMode(kind)
    local key = UI_VISIBILITY_SETTING_KEYS[kind]
    if not key or not VFM.saved then return UI_VISIBILITY_SHOW end
    return VFM.NormalizeUiVisibilityMode(VFM.saved[key])
end

function VFM.ShouldHideUiKind(kind, isPvpContext, isCombatContext)
    local mode = VFM.GetUiVisibilityMode(kind)
    if mode == UI_VISIBILITY_HIDE then return true end
    if mode == UI_VISIBILITY_COMBAT_ONLY then
        if isCombatContext == nil then
            if IsUnitInCombat then
                isCombatContext = IsUnitInCombat("player") and true or false
            else
                isCombatContext = VFM.inCombat and true or false
            end
        end
        return not isCombatContext
    end
    if mode == UI_VISIBILITY_PVP_ONLY then
        if isPvpContext == nil then isPvpContext = VFM.IsPvpUiContext() end
        return not isPvpContext
    end
    if mode == UI_VISIBILITY_COMBAT then
        if isCombatContext == nil then
            if IsUnitInCombat then
                isCombatContext = IsUnitInCombat("player") and true or false
            else
                isCombatContext = VFM.inCombat and true or false
            end
        end
        return isCombatContext and true or false
    end
    if mode == UI_VISIBILITY_PVP then
        if isPvpContext == nil then isPvpContext = VFM.IsPvpUiContext() end
        return isPvpContext and true or false
    end
    return false
end

function VFM.GetNamedUiControl(name)
    if not WINDOW_MANAGER or not WINDOW_MANAGER.GetControlByName then return nil end
    local ok, control = pcall(WINDOW_MANAGER.GetControlByName, WINDOW_MANAGER, tostring(name or ""))
    if ok then return control end
    return nil
end

function VFM.ApplyManagedUiControl(group, control, shouldHide, forceRelease)
    if not control or not control.SetHidden then return false end
    VFM.uiVisibilityHiddenByAddon = VFM.uiVisibilityHiddenByAddon or {}

    if shouldHide then
        VFM.uiVisibilityHiddenByAddon[control] = true
        pcall(control.SetHidden, control, true)
        return true
    end

    if forceRelease == true or VFM.uiVisibilityHiddenByAddon[control] == true then
        -- On a managed -> released transition, explicitly hand the control back.
        -- Do not force normal HUD controls visible every 500 ms because ESO scenes
        -- are still allowed to hide their own HUD while menus are open.
        if group == "crosshair" then
            -- ESO normally hides the crosshair texture during stealth/disguise.
            -- Restore that native state rather than blindly forcing the texture on.
            local inStealthOrDisguise = false
            if GetUnitDisguiseState and GetUnitStealthState then
                inStealthOrDisguise = GetUnitDisguiseState("player") ~= DISGUISE_STATE_NONE
                    or GetUnitStealthState("player") ~= STEALTH_STATE_NONE
            end
            pcall(control.SetHidden, control, inStealthOrDisguise)
        else
            pcall(control.SetHidden, control, false)
        end
        VFM.uiVisibilityHiddenByAddon[control] = nil
    end
    return false
end

function VFM.RefreshUiVisibilityRules(forceReleaseManaged)
    if not VFM.saved then return end

    local previousPvpContext = VFM.lastUiVisibilityPvpContext
    local isPvpContext = VFM.IsPvpUiContext()
    local justLeftPvp = previousPvpContext == true and isPvpContext == false
    local justEnteredPvp = previousPvpContext == false and isPvpContext == true
    VFM.lastUiVisibilityPvpContext = isPvpContext

    local previousCombatContext = VFM.lastUiVisibilityCombatContext
    local isCombatContext = VFM.inCombat and true or false
    if IsUnitInCombat then
        isCombatContext = IsUnitInCombat("player") and true or false
    end
    local justLeftCombat = previousCombatContext == true and isCombatContext == false
    local justEnteredCombat = previousCombatContext == false and isCombatContext == true
    VFM.lastUiVisibilityCombatContext = isCombatContext

    local needsGuardian = false
    local groupMode = VFM.GetGroupFrameVisibilityMode and VFM.GetGroupFrameVisibilityMode() or "show"
    local chatMode = VFM.GetChatVisibilityMode and VFM.GetChatVisibilityMode() or "show"
    if groupMode ~= "show" or chatMode ~= "show" then needsGuardian = true end
    for kind, names in pairs(UI_VISIBILITY_CONTROL_NAMES) do
        local mode = VFM.GetUiVisibilityMode(kind)
        local shouldHide = VFM.ShouldHideUiKind(kind, isPvpContext, isCombatContext)
        VFM.ApplyNativeUiVisibilityRule(kind, mode, shouldHide)

        -- Conditional modes are guarded only while their condition is active.
        -- Outside that state ESO owns normal scene visibility again.
        if mode == UI_VISIBILITY_HIDE
            or (mode == UI_VISIBILITY_PVP and isPvpContext)
            or (mode == UI_VISIBILITY_COMBAT and isCombatContext)
            or (mode == UI_VISIBILITY_COMBAT_ONLY and not isCombatContext)
            or (mode == UI_VISIBILITY_PVP_ONLY and not isPvpContext) then
            needsGuardian = true
        end

        local forceRelease = (mode == UI_VISIBILITY_PVP
                and not isPvpContext
                and (justLeftPvp or forceReleaseManaged == true))
            or (mode == UI_VISIBILITY_COMBAT
                and not isCombatContext
                and (justLeftCombat or forceReleaseManaged == true))
            or (mode == UI_VISIBILITY_COMBAT_ONLY
                and isCombatContext
                and (justEnteredCombat or forceReleaseManaged == true))
            or (mode == UI_VISIBILITY_PVP_ONLY
                and isPvpContext
                and (justEnteredPvp or forceReleaseManaged == true))

        for _, name in ipairs(names) do
            local control = VFM.GetNamedUiControl(name)
            if control then
                VFM.ApplyManagedUiControl(kind, control, shouldHide, forceRelease)
            end
        end
    end

    VFM.ApplyGroupFrameState()
    VFM.ApplyChatVisibilityMode()

    local updateName = ADDON_NAME .. "UiVisibilityGuardian"
    if needsGuardian and not VFM.uiVisibilityGuardianRegistered then
        VFM.uiVisibilityGuardianRegistered = true
        EVENT_MANAGER:RegisterForUpdate(updateName, 500, function()
            VFM.RefreshUiVisibilityRules(false)
        end)
    elseif not needsGuardian and VFM.uiVisibilityGuardianRegistered then
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        VFM.uiVisibilityGuardianRegistered = false
    end
end

function VFM.SetUiVisibilityMode(kind, mode, silent)
    local key = UI_VISIBILITY_SETTING_KEYS[kind]
    if not key or not VFM.saved then return end
    mode = VFM.NormalizeUiVisibilityMode(mode)
    if VFM.saved[key] == mode then
        VFM.RefreshUiVisibilityRules()
        return
    end
    VFM.saved[key] = mode
    VFM.RequestSettingsSave()
    VFM.RefreshUiVisibilityRules()
    if not silent then
        Print(string.format("%s visibility set to %s", tostring(kind), tostring(mode)))
    end
end

function VFM.GetChatVisibilityMode()
    if not VFM.saved then return "show" end
    local mode = tostring(VFM.saved.chatVisibilityMode or "")
    if mode == "combat" or mode == "pvp" or mode == "hide" or mode == "show" then return mode end
    if VFM.saved.autoHideChat == true then return "hide" end
    return "show"
end

function VFM.GetChatControl()
    if CHAT_SYSTEM and CHAT_SYSTEM.primaryContainer and CHAT_SYSTEM.primaryContainer.control then
        return CHAT_SYSTEM.primaryContainer.control
    end
    return _G.ZO_ChatWindow
end

function VFM.IsChatTextEntryOpen()
    if CHAT_SYSTEM and CHAT_SYSTEM.textEntry and CHAT_SYSTEM.textEntry.IsOpen then
        local ok, open = pcall(CHAT_SYSTEM.textEntry.IsOpen, CHAT_SYSTEM.textEntry)
        return ok and open == true
    end
    return false
end

function VFM.ApplyChatVisibilityMode()
    if not VFM.saved then return false end
    local mode = VFM.GetChatVisibilityMode()
    local shouldHide = mode == "hide"
        or (mode == "combat" and (IsUnitInCombat and IsUnitInCombat("player") or VFM.inCombat == true))
        or (mode == "pvp" and VFM.IsPvpUiContext and VFM.IsPvpUiContext())

    -- Never hide chat while the user is typing. Once text entry closes the
    -- normal visibility guardian applies the selected rule immediately.
    if VFM.IsChatTextEntryOpen() then shouldHide = false end

    local control = VFM.GetChatControl()
    if not control or not control.SetHidden then return false end
    if shouldHide then
        if VFM.chatVisibilitySnapshot == nil and control.IsHidden then
            VFM.chatVisibilitySnapshot = control:IsHidden() and true or false
        end
        pcall(function() control:SetHidden(true) end)
        VFM.chatHiddenByAddon = true
        return true
    end

    if VFM.chatHiddenByAddon == true then
        local wasHidden = VFM.chatVisibilitySnapshot == true
        pcall(function() control:SetHidden(wasHidden) end)
        VFM.chatHiddenByAddon = nil
        VFM.chatVisibilitySnapshot = nil
    end
    return false
end

function VFM.SetChatVisibilityMode(mode, silent)
    if not VFM.saved then return end
    mode = tostring(mode or "show")
    if mode ~= "combat" and mode ~= "pvp" and mode ~= "hide" then mode = "show" end
    VFM.saved.chatVisibilityMode = mode
    VFM.saved.autoHideChat = mode == "hide"
    VFM.RequestSettingsSave()
    VFM.ApplyChatVisibilityMode()
    VFM.RefreshUiVisibilityRules(true)
    if not silent then Print("Chat visibility: " .. string.upper(mode)) end
end

function VFM.ApplyAutoHideChat()
    if not VFM.saved or VFM.saved.autoHideChat ~= true then return false end

    -- Never minimize the chat container while the text entry is open. Several
    -- Dark Souls presets intentionally use auto-hide chat, but the quick menu is
    -- itself opened through chat. Minimizing the container during a preset click
    -- used to destroy the quick-menu session before the selected profile could be
    -- reviewed or adjusted. The normal visibility guardian applies the saved hide
    -- rule as soon as text entry closes.
    if VFM.IsChatTextEntryOpen and VFM.IsChatTextEntryOpen() then
        return false
    end
    local quickMenu = Ultivite and Ultivite.QuickMenu or nil
    if quickMenu and quickMenu.panel and quickMenu.panel.IsHidden and not quickMenu.panel:IsHidden() then
        return false
    end

    -- CHAT_SYSTEM:Minimize() is safe once the chat containers have loaded. This
    -- function is only called from/after EVENT_PLAYER_ACTIVATED, never during
    -- early addon initialization.
    if CHAT_SYSTEM and type(CHAT_SYSTEM.Minimize) == "function" then
        local ok = pcall(CHAT_SYSTEM.Minimize, CHAT_SYSTEM)
        return ok
    end
    return false
end

function VFM.SetAutoHideChat(enabled, silent)
    if not VFM.saved then return end
    VFM.SetChatVisibilityMode(enabled and "hide" or "show", silent)
end

local NAVIGATION_UPDATE_NAME = ADDON_NAME .. "NavigationHelpers"
local NAVIGATION_UPDATE_MS = 16
local CROWN_DIRECTION_UPDATE_MS = 50
local TWO_PI = math.pi * 2

local function ClampNumber(value, minValue, maxValue, fallback)
    value = tonumber(value)
    if value == nil then value = fallback end
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function Atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 then
        return math.atan(y / x) + (y >= 0 and math.pi or -math.pi)
    elseif y > 0 then
        return math.pi / 2
    elseif y < 0 then
        return -math.pi / 2
    end
    return 0
end

local function NormalizeRadians(angle)
    angle = tonumber(angle) or 0
    while angle > math.pi do angle = angle - TWO_PI end
    while angle < -math.pi do angle = angle + TWO_PI end
    return angle
end

function VFM.GetNavigationHelperVisibilityMode(kind)
    if not VFM.saved then return "show" end
    local key = kind == "feet" and "feetCompassVisibilityMode" or "crownDirectionArrowVisibilityMode"
    local mode = tostring(VFM.saved[key] or "show")
    if mode == "combatOnly" or mode == "pvpOnly" or mode == "show" then return mode end
    return "show"
end

function VFM.SetNavigationHelperVisibilityMode(kind, mode, silent)
    if not VFM.saved then return end
    local key = kind == "feet" and "feetCompassVisibilityMode" or "crownDirectionArrowVisibilityMode"
    mode = tostring(mode or "show")
    if mode ~= "combatOnly" and mode ~= "pvpOnly" then mode = "show" end
    VFM.saved[key] = mode
    VFM.RequestSettingsSave()
    VFM.RefreshNavigationHelpers(true)
    if not silent then Print(string.format("%s visibility: %s", kind == "feet" and "Feet compass" or "Crown arrow", string.upper(mode))) end
end

function VFM.ShouldShowNavigationHelper(kind)
    local mode = VFM.GetNavigationHelperVisibilityMode(kind)
    if mode == "combatOnly" then
        return IsUnitInCombat and IsUnitInCombat("player") or VFM.inCombat == true
    end
    if mode == "pvpOnly" then
        return VFM.IsPvpUiContext and VFM.IsPvpUiContext() or false
    end
    return true
end

function VFM.IsNavigationHudAvailable()
    if IsGameCameraUIModeActive then
        local ok, active = pcall(IsGameCameraUIModeActive)
        if ok and active then return false end
    end
    return true
end

function VFM.CreateCrownDirectionArrow()
    if VFM.crownDirectionArrowControl then return VFM.crownDirectionArrowControl end
    local control = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteCrownDirectionArrow")
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    control:SetClampedToScreen(true)
    if control.SetDrawTier then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLayer then control:SetDrawLayer(DL_OVERLAY) end
    if control.SetDrawLevel then control:SetDrawLevel(20) end

    -- 1.0.84 uses one composite marker texture. The gold crown is physically
    -- baked into the tail of the arrow, so rotation can never separate it from
    -- the arrow base regardless of which direction the marker points.
    local texture = WINDOW_MANAGER:CreateControl("UltiviteCrownDirectionArrowTexture", control, CT_TEXTURE)
    texture:SetAnchorFill(control)
    texture:SetTexture("Ultivite/art/crown_direction_marker.dds")
    texture:SetColor(1, 1, 1, 1)

    control.texture = texture
    control.accent = nil
    control:SetHidden(true)
    VFM.crownDirectionArrowControl = control
    return control
end

function VFM.CreateFeetCompass()
    if VFM.feetCompassControl then return VFM.feetCompassControl end
    local control = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteFeetCompass")
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    control:SetClampedToScreen(true)
    if control.SetDrawTier then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLayer then control:SetDrawLayer(DL_OVERLAY) end
    if control.SetDrawLevel then control:SetDrawLevel(15) end

    -- Keep the ring fixed in screen space and move the primary plus diagonal
    -- bearings around it from camera heading. Diagonals are kept smaller and
    -- slightly more central so the compass remains professional and readable.
    local texture = WINDOW_MANAGER:CreateControl("UltiviteFeetCompassTexture", control, CT_TEXTURE)
    texture:SetAnchorFill(control)
    texture:SetTexture("Ultivite/art/feet_compass.dds")
    texture:SetColor(1, 1, 1, 1)

    local labels = {}
    local bearingLabels = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
    for i = 1, #bearingLabels do
        local name = bearingLabels[i]
        local label = WINDOW_MANAGER:CreateControl("UltiviteFeetCompass" .. name, control, CT_LABEL)
        label:SetText(name)
        label:SetColor(1, 1, 1, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        labels[name] = label
    end

    control.texture = texture
    control.cardinalLabels = labels
    control:SetHidden(true)
    VFM.feetCompassControl = control
    return control
end

function VFM.ApplyCrownDirectionArrowLayout()
    if not VFM.saved then return end
    local control = VFM.CreateCrownDirectionArrow()
    local size = ClampNumber(VFM.saved.crownDirectionArrowSize, 14, 96, defaults.crownDirectionArrowSize)
    local alpha = ClampNumber(VFM.saved.crownDirectionArrowOpacity, 0.10, 1.00, defaults.crownDirectionArrowOpacity)

    -- The composite asset is deliberately tall inside a square canvas. Scaling
    -- the whole square keeps the rotation perfectly centred while giving the
    -- arrow substantially more shaft length than the old stretched texture.
    local markerSize = math.max(46, zo_round(size * 2.55))
    control:SetDimensions(markerSize, markerSize)
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER,
        ClampNumber(VFM.saved.crownDirectionArrowX, -2000, 2000, defaults.crownDirectionArrowX),
        ClampNumber(VFM.saved.crownDirectionArrowY, -1200, 1200, defaults.crownDirectionArrowY))
    control:SetAlpha(alpha)

    if control.texture then
        control.texture:ClearAnchors()
        control.texture:SetAnchorFill(control)
    end
end

function VFM.ApplyFeetCompassLayout()
    if not VFM.saved then return end
    local control = VFM.CreateFeetCompass()
    local width = ClampNumber(VFM.saved.feetCompassSize, 140, 650, defaults.feetCompassSize)

    -- 1.0.85 keeps the professional ground-compass shape from 1.0.84 but adds
    -- diagonal bearings back in with cleaner hierarchy so readability stays high.
    local height = math.max(112, width * 0.70)
    local alpha = ClampNumber(VFM.saved.feetCompassOpacity, 0.10, 1.00, defaults.feetCompassOpacity)
    control:SetDimensions(width, height)
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER,
        ClampNumber(VFM.saved.feetCompassX, -2000, 2000, defaults.feetCompassX),
        ClampNumber(VFM.saved.feetCompassY, -1200, 1200, defaults.feetCompassY))

    control:SetAlpha(1)
    if control.texture then
        local ringAlpha = math.max(0.20, math.min(0.78, alpha * 0.95))
        control.texture:SetColor(1, 1, 1, ringAlpha)
    end

    local majorSize = math.max(20, math.min(34, zo_round(width * 0.086)))
    local minorSize = math.max(14, math.min(23, zo_round(majorSize * 0.64)))
    if control.cardinalLabels then
        for name, label in pairs(control.cardinalLabels) do
            local isMajor = (name == "N" or name == "E" or name == "S" or name == "W")
            local fontSize = isMajor and majorSize or minorSize
            label:SetDimensions(fontSize * (isMajor and 3.0 or 2.6), fontSize * (isMajor and 1.95 or 1.7))
            label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", fontSize))
            if name == "N" then
                label:SetColor(1, 1, 1, 1)
            elseif isMajor then
                label:SetColor(0.96, 0.96, 0.96, 0.98)
            else
                label:SetColor(0.88, 0.88, 0.88, 0.93)
            end
        end
    end
end

function VFM.GetGroupLeaderUnitTagSafe()
    if not IsUnitGrouped or not IsUnitGrouped("player") then return nil end
    if GetGroupLeaderUnitTag then
        local ok, unitTag = pcall(GetGroupLeaderUnitTag)
        if ok and unitTag and unitTag ~= "" and (not DoesUnitExist or DoesUnitExist(unitTag)) then
            return unitTag
        end
    end
    if not GetGroupSize or not GetGroupUnitTagByIndex or not IsUnitGroupLeader then return nil end
    local count = tonumber(GetGroupSize()) or 0
    for i = 1, count do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and unitTag ~= "" and DoesUnitExist(unitTag) and IsUnitGroupLeader(unitTag) then
            return unitTag
        end
    end
    return nil
end

function VFM.GetCrownWorldBearing()
    local leaderTag = VFM.GetGroupLeaderUnitTagSafe()
    if not leaderTag then return nil end
    if AreUnitsEqual and AreUnitsEqual("player", leaderTag) then return nil end
    if IsUnitOnline and not IsUnitOnline(leaderTag) then return nil end

    -- World coordinates are preferable to map coordinates because they do not
    -- depend on whatever map the player currently has open. ESO's world axes use
    -- +X east and +Z south, so north is -Z.
    if GetUnitWorldPosition then
        local okP, pZone, pX, _, pZ = pcall(GetUnitWorldPosition, "player")
        local okL, lZone, lX, _, lZ = pcall(GetUnitWorldPosition, leaderTag)
        if okP and okL and pZone and lZone and pZone == lZone
            and pX and pZ and lX and lZ
            and not (pX == 0 and pZ == 0 and lX == 0 and lZ == 0) then
            local dx = lX - pX
            local dz = lZ - pZ
            if (dx * dx + dz * dz) > 10000 then -- hide when within ~1 metre
                return Atan2(dx, -dz)
            end
            return nil
        end
    end

    -- Conservative fallback for older clients/edge cases. Local map coordinates
    -- use +X east and +Y south as well. If the map cannot represent both units,
    -- the API generally returns zeros and the arrow stays hidden.
    if GetMapPlayerPosition then
        local okP, pX, pY = pcall(GetMapPlayerPosition, "player")
        local okL, lX, lY = pcall(GetMapPlayerPosition, leaderTag)
        if okP and okL and pX and pY and lX and lY
            and not (pX == 0 and pY == 0 and lX == 0 and lY == 0) then
            local dx = lX - pX
            local dy = lY - pY
            if (dx * dx + dy * dy) > 0.00000001 then
                return Atan2(dx, -dy)
            end
        end
    end
    return nil
end

function VFM.UpdateCrownDirectionArrow(force)
    if not VFM.saved then return end
    local control = VFM.CreateCrownDirectionArrow()
    local quickPreview = Ultivite and Ultivite.QuickMenu and Ultivite.QuickMenu.IsPreviewing
        and Ultivite.QuickMenu.IsPreviewing("crownArrow")
    if quickPreview then
        VFM.ApplyCrownDirectionArrowLayout()
        if control.texture and control.texture.SetTextureRotation then control.texture:SetTextureRotation(0) end
        control:SetHidden(false)
        return
    end
    if VFM.saved.crownDirectionArrow ~= true or not VFM.ShouldShowNavigationHelper("crown") or not VFM.IsNavigationHudAvailable() then
        control:SetHidden(true)
        VFM.cachedCrownWorldBearing = nil
        VFM.lastCrownDirectionUpdateMs = nil
        return
    end

    -- Sample the leader's world position at a modest rate, but rotate against
    -- the camera every UI tick. This keeps camera movement immediate while
    -- avoiding the visible positional jitter produced by tying the marker to a
    -- constantly moving world-space anchor.
    local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    local shouldSample = force or VFM.cachedCrownWorldBearing == nil
        or VFM.lastCrownDirectionUpdateMs == nil
        or (now - VFM.lastCrownDirectionUpdateMs) >= CROWN_DIRECTION_UPDATE_MS

    if shouldSample then
        VFM.lastCrownDirectionUpdateMs = now
        local sampledBearing = VFM.GetCrownWorldBearing()
        if sampledBearing == nil then
            VFM.cachedCrownWorldBearing = nil
        elseif VFM.cachedCrownWorldBearing ~= nil and not force then
            local delta = NormalizeRadians(sampledBearing - VFM.cachedCrownWorldBearing)
            VFM.cachedCrownWorldBearing = NormalizeRadians(VFM.cachedCrownWorldBearing + delta * 0.45)
        else
            VFM.cachedCrownWorldBearing = sampledBearing
        end
    end

    local heading = GetPlayerCameraHeading and GetPlayerCameraHeading() or nil
    if VFM.cachedCrownWorldBearing == nil or heading == nil then
        control:SetHidden(true)
        return
    end

    VFM.ApplyCrownDirectionArrowLayout()
    local angle = NormalizeRadians(VFM.cachedCrownWorldBearing - heading)
    if control.texture and control.texture.SetTextureRotation then
        control.texture:SetTextureRotation(angle)
    end
    control:SetHidden(false)
end

function VFM.UpdateFeetCompass(force)
    if not VFM.saved then return end
    local control = VFM.CreateFeetCompass()
    local quickPreview = Ultivite and Ultivite.QuickMenu and Ultivite.QuickMenu.IsPreviewing
        and Ultivite.QuickMenu.IsPreviewing("feetCompass")
    if quickPreview then
        -- Keep the actual feet compass steadily visible in its real location even
        -- though chat puts ESO in UI mode. This avoids hide/show fighting and the
        -- visible strobe seen in 1.0.104 preview mode.
        VFM.ApplyFeetCompassLayout()
        control:SetHidden(false)
    elseif VFM.saved.feetCompass ~= true or not VFM.ShouldShowNavigationHelper("feet") or not VFM.IsNavigationHudAvailable() then
        control:SetHidden(true)
        VFM.lastFeetCompassHeading = nil
        return
    end
    local heading = GetPlayerCameraHeading and GetPlayerCameraHeading() or nil
    if heading == nil then
        if quickPreview then
            -- Preview must remain steady even if ESO momentarily withholds camera
            -- heading while chat owns UI focus.
            heading = VFM.lastFeetCompassHeading or 0
        else
            control:SetHidden(true)
            return
        end
    end

    VFM.ApplyFeetCompassLayout()

    if force or VFM.lastFeetCompassHeading == nil
        or math.abs(NormalizeRadians(heading - VFM.lastFeetCompassHeading)) > 0.00035 then
        VFM.lastFeetCompassHeading = heading

        local width = control:GetWidth()
        local height = control:GetHeight()
        local majorRadiusX = width * 0.455
        local majorRadiusY = height * 0.445
        local minorRadiusX = width * 0.345
        local minorRadiusY = height * 0.325
        local yBias = height * 0.015
        local bearings = {
            N = { angle = 0, major = true },
            NE = { angle = math.pi * 0.25, major = false },
            E = { angle = math.pi * 0.5, major = true },
            SE = { angle = math.pi * 0.75, major = false },
            S = { angle = math.pi, major = true },
            SW = { angle = math.pi * 1.25, major = false },
            W = { angle = math.pi * 1.5, major = true },
            NW = { angle = math.pi * 1.75, major = false },
        }

        for name, info in pairs(bearings) do
            local label = control.cardinalLabels and control.cardinalLabels[name]
            if label then
                local relative = NormalizeRadians(info.angle - heading)
                local radiusX = info.major and majorRadiusX or minorRadiusX
                local radiusY = info.major and majorRadiusY or minorRadiusY
                local x = math.sin(relative) * radiusX
                local y = (-math.cos(relative) * radiusY) + yBias
                x = math.floor(x + 0.5)
                y = math.floor(y + 0.5)
                label:ClearAnchors()
                label:SetAnchor(CENTER, control, CENTER, x, y)
            end
        end
    end

    if control.texture and control.texture.SetTextureRotation then
        control.texture:SetTextureRotation(0)
    end
    control:SetHidden(false)
end

function VFM.RefreshNavigationHelpers(force)
    if not VFM.saved then return end
    VFM.ApplyCrownDirectionArrowLayout()
    VFM.ApplyFeetCompassLayout()
    VFM.UpdateCrownDirectionArrow(force == true)
    VFM.UpdateFeetCompass(force == true)

    local shouldRun = VFM.saved.crownDirectionArrow == true or VFM.saved.feetCompass == true
    if shouldRun and not VFM.navigationUpdateRegistered then
        VFM.navigationUpdateRegistered = true
        EVENT_MANAGER:RegisterForUpdate(NAVIGATION_UPDATE_NAME, NAVIGATION_UPDATE_MS, function()
            VFM.UpdateCrownDirectionArrow(false)
            VFM.UpdateFeetCompass(false)
        end)
    elseif not shouldRun and VFM.navigationUpdateRegistered then
        EVENT_MANAGER:UnregisterForUpdate(NAVIGATION_UPDATE_NAME)
        VFM.navigationUpdateRegistered = false
    end
end

function VFM.SetCrownDirectionArrow(enabled, silent)
    if not VFM.saved then return end
    VFM.saved.crownDirectionArrow = enabled and true or false
    VFM.RequestSettingsSave()
    VFM.RefreshNavigationHelpers(true)
    if not silent then Print(VFM.saved.crownDirectionArrow and "Crown direction arrow enabled" or "Crown direction arrow disabled") end
end

function VFM.SetCrownDirectionArrowSize(value)
    if not VFM.saved then return end
    VFM.saved.crownDirectionArrowSize = ClampNumber(value, 14, 96, defaults.crownDirectionArrowSize)
    VFM.RequestSettingsSave()
    VFM.ApplyCrownDirectionArrowLayout()
end

function VFM.SetCrownDirectionArrowOpacity(value)
    if not VFM.saved then return end
    VFM.saved.crownDirectionArrowOpacity = ClampNumber(value, 0.10, 1.00, defaults.crownDirectionArrowOpacity)
    VFM.RequestSettingsSave()
    VFM.ApplyCrownDirectionArrowLayout()
end

function VFM.SetCrownDirectionArrowX(value)
    if not VFM.saved then return end
    VFM.saved.crownDirectionArrowX = ClampNumber(value, -2000, 2000, defaults.crownDirectionArrowX)
    VFM.RequestSettingsSave()
    VFM.ApplyCrownDirectionArrowLayout()
end

function VFM.SetCrownDirectionArrowY(value)
    if not VFM.saved then return end
    VFM.saved.crownDirectionArrowY = ClampNumber(value, -1200, 1200, defaults.crownDirectionArrowY)
    VFM.RequestSettingsSave()
    VFM.ApplyCrownDirectionArrowLayout()
end

function VFM.SetFeetCompass(enabled, silent)
    if not VFM.saved then return end
    VFM.saved.feetCompass = enabled and true or false
    VFM.RequestSettingsSave()
    VFM.RefreshNavigationHelpers(true)
    if not silent then Print(VFM.saved.feetCompass and "Feet compass enabled" or "Feet compass disabled") end
end

function VFM.SetFeetCompassSize(value)
    if not VFM.saved then return end
    VFM.saved.feetCompassSize = ClampNumber(value, 140, 650, defaults.feetCompassSize)
    VFM.RequestSettingsSave()
    VFM.ApplyFeetCompassLayout()
end

function VFM.SetFeetCompassOpacity(value)
    if not VFM.saved then return end
    VFM.saved.feetCompassOpacity = ClampNumber(value, 0.10, 1.00, defaults.feetCompassOpacity)
    VFM.RequestSettingsSave()
    VFM.ApplyFeetCompassLayout()
end

function VFM.SetFeetCompassX(value)
    if not VFM.saved then return end
    VFM.saved.feetCompassX = ClampNumber(value, -2000, 2000, defaults.feetCompassX)
    VFM.RequestSettingsSave()
    VFM.ApplyFeetCompassLayout()
end

function VFM.SetFeetCompassY(value)
    if not VFM.saved then return end
    VFM.saved.feetCompassY = ClampNumber(value, -1200, 1200, defaults.feetCompassY)
    VFM.RequestSettingsSave()
    VFM.ApplyFeetCompassLayout()
end

function VFM.PrintUiVisibilityDiagnostic()
    Print(string.format("PvP context: %s", VFM.IsPvpUiContext() and "yes" or "no"))
    for kind, names in pairs(UI_VISIBILITY_CONTROL_NAMES) do
        local found = {}
        for _, name in ipairs(names) do
            if VFM.GetNamedUiControl(name) then found[#found + 1] = name end
        end
        local nativeParts = {}
        local nativeSettings = UI_VISIBILITY_NATIVE_SETTINGS[kind]
        if nativeSettings then
            for _, setting in ipairs(nativeSettings) do
                local systemType = ResolveUiVisibilityNativeValue(setting.system)
                local settingId = ResolveUiVisibilityNativeValue(setting.id)
                local value = VFM.GetUiVisibilityNativeSetting(systemType, settingId)
                nativeParts[#nativeParts + 1] = string.format("%s=%s", tostring(setting.key), tostring(value or "unavailable"))
            end
        end
        Print(string.format("%s mode=%s controls=%s native=%s", kind, VFM.GetUiVisibilityMode(kind), #found > 0 and table.concat(found, ", ") or "none found", #nativeParts > 0 and table.concat(nativeParts, ", ") or "n/a"))
    end
    Print(string.format("championProgress=%s mountStaminaHidden=%s autoHideChat=%s", tostring(VFM.GetChampionProgressVisibilityMode()), tostring(VFM.saved.hideMountStaminaBar ~= false), tostring(VFM.saved.autoHideChat == true)))
    Print(string.format("navigation crownArrow=%s crownSize=%s crownOpacity=%s feetCompass=%s compassSize=%s compassOpacity=%s",
        tostring(VFM.saved.crownDirectionArrow == true), tostring(VFM.saved.crownDirectionArrowSize), tostring(VFM.saved.crownDirectionArrowOpacity),
        tostring(VFM.saved.feetCompass == true), tostring(VFM.saved.feetCompassSize), tostring(VFM.saved.feetCompassOpacity)))
end

function VFM.StartLayoutGuardian()
    if VFM.layoutGuardianStarted then
        return
    end

    VFM.layoutGuardianStarted = true
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "LayoutGuardian")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "LayoutGuardian", 250, function()
        -- Keep /vfm authoritative. LibAddonMenu registers panel shortcuts by
        -- writing directly to SLASH_COMMANDS, so a later registration can replace
        -- another handler that uses the same command.
        VFM.EnsureSlashCommandOwnership()

        if not VFM.saved then
            return
        end

        -- Best-effort runtime preparation is useful for movers/text, but native
        -- bar position/scale repair must not depend on it. This is the critical
        -- /reloadui fix.
        if not VFM.runtimeReady then
            VFM.PrepareRuntime(false)
        end

        -- Action-bar hiding is independent from Dark Souls mode and from the
        -- resource-bar edit lock. Fancy Action Bar+ can refresh ZO_ActionBar1,
        -- so keep the separate visibility toggle authoritative on its own.
        if VFM.saved.hideActionBar and VFM.GetActionBarVisibilityDrift() then
            VFM.ApplyActionBarHidden()
        elseif FAB and FAB.ApplyCombatOnlyVisibility then
            -- Combat-only is the master visibility rule for FAB when the action
            -- bar is otherwise enabled. Reconcile it here as well as on combat
            -- events because ESO can refresh ZO_ActionBar1 outside those events.
            FAB.ApplyCombatOnlyVisibility()
        end

        -- FAB+ owns its own weapon-lock row behavior. Ultivite only manages the
        -- separate native Werewolf resource meter.
        VFM.ApplyWerewolfResourceBarVisibility()

        -- ESO and other UI addons can refresh the native resource labels after
        -- VFM has already blanked them. Dark Souls mode owns their visibility,
        -- so keep all three native number labels physically hidden while active.
        if VFM.saved.darkSoulsMode then
            VFM.SetDarkSoulsResourceTextHidden(true)
        end

        -- EVENT_PLAYER_COMBAT_STATE can be missed across loading, death and scene
        -- transitions. Reconcile against ESO's live combat state so the cached
        -- value cannot leave Combat Only stuck visible after combat has ended.
        local liveInCombat = VFM.inCombat
        if IsUnitInCombat then
            liveInCombat = IsUnitInCombat("player") and true or false
            if liveInCombat ~= VFM.inCombat then
                VFM.UpdateCombatVisibility(liveInCombat)
            end
        end

        VFM.UpdateDSUltimateControl()
        -- Navigation helpers are screen-space controls. Their own 16 ms updater
        -- handles heading changes; this guardian only repairs visibility/layout
        -- after scene or addon refreshes.
        if VFM.saved.crownDirectionArrow == true or VFM.saved.feetCompass == true then
            VFM.ApplyCrownDirectionArrowLayout()
            VFM.ApplyFeetCompassLayout()
        end

        -- ESO can refresh native attribute-bar timelines outside combat after
        -- interactions, loading, death/respawn and attribute visual changes.
        -- Reassert the hidden state while Combat Only owns the player HUD, even
        -- when there was no new combat-state event. Bottom-only Dark Souls uses
        -- the same immediate suppression path.
        if VFM.saved.dsSelfHealthBar
            or VFM.saved.dsSelfResourceBars
            or VFM.saved.dsBottomOnly
            or (VFM.saved.combatOnly and VFM.saved.locked and not liveInCombat) then
            VFM.ApplyImmediateCombatOnlyHide()
        end

        -- PLAYER_PROGRESS_BAR can be shown again whenever Champion XP is awarded.
        -- Reconcile the three-state CP visibility rule without touching XP or skill
        -- progress. PvP-only mode automatically releases the bar outside PvP.
        VFM.InstallChampionProgressHook()
        VFM.ApplyChampionProgressVisibility(false)

        -- ESO refreshes the Mount Stamina child whenever mount state changes.
        -- Keep the dedicated visibility rule authoritative when requested.
        VFM.ApplyMountStaminaBarVisibility()

        VFM.ApplyGroupFrameState()

        if VFM.saved.locked and not VFM.draggingKey then
            if not VFM.RepairLayoutDrift("guardian", false) and not VFM.GetPrimaryBarObjects() then
                VFM.ScheduleApply(0)
            end
        end
    end)
end

function VFM.IsPrimaryBarReplacedByDSSelf(bar)
    if not VFM.saved or not VFM.IsPrimaryBar(bar) then
        return false
    end

    -- The bottom Dark Souls controls replace the corresponding ESO player
    -- resource controls directly. Fancy Action Bar+ may move/reanchor those
    -- native controls, but it does not own this replacement decision.
    if VFM.saved.dsBottomOnly == true then
        return true
    end

    if bar.powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        return VFM.saved.dsSelfHealthBar == true or VFM.saved.dsSelfResourceBars == true
    end

    if bar.powerType == COMBAT_MECHANIC_FLAGS_MAGICKA
        or bar.powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
        return VFM.saved.dsSelfResourceBars == true
    end

    return false
end

function VFM.ShouldForceShowBars(bar)
    if not VFM.saved then
        return false
    end

    -- A native bar replaced by a Dark Souls Self bar must stay hidden even
    -- while player-bar editing is unlocked. This prevents standalone FAB+ or
    -- ESO from making the old bar visible again after an anchor refresh.
    if VFM.IsPrimaryBarReplacedByDSSelf(bar) then
        return false
    end

    -- Edit mode shows only native bars that are actually part of the layout.
    if not VFM.saved.locked then
        return true
    end

    return VFM.saved.combatOnly and VFM.inCombat
end

function VFM.InstallCombatVisibilityRequirements()
    local bars = VFM.GetBars()
    if not bars then
        return false
    end

    for _, bar in ipairs(bars) do
        -- Combat Only belongs to the player's three primary resource bars.
        -- Do not take ownership of mount, siege, werewolf or other special bars.
        if VFM.IsPrimaryBar(bar) and bar.SetExternalVisibilityRequirement then
            local barRef = bar

            -- ESO or another UI addon can replace the external visibility
            -- requirement after Ultivite has installed its callback. Detect that
            -- drift and wrap the newest requirement instead of trusting a stale
            -- one-time installed flag.
            if not barRef.vfmCombatRequirementWrapper
                or barRef.externalVisibilityRequirement ~= barRef.vfmCombatRequirementWrapper then
                local originalRequirement = barRef.externalVisibilityRequirement
                if originalRequirement == barRef.vfmCombatRequirementWrapper then
                    originalRequirement = barRef.vfmOriginalExternalVisibilityRequirement
                end

                barRef.vfmOriginalExternalVisibilityRequirement = originalRequirement

                local wrapper = function()
                    if originalRequirement and not originalRequirement() then
                        return false
                    end

                    if not VFM.saved then
                        return true
                    end

                    -- A bottom Dark Souls replacement owns this specific
                    -- resource bar. Keep the corresponding ESO/FAB-moved native
                    -- control suppressed for as long as the replacement is on.
                    if VFM.IsPrimaryBarReplacedByDSSelf(barRef) then
                        return false
                    end

                    -- Edit mode deliberately reveals bars for positioning.
                    if not VFM.saved.locked then
                        return true
                    end

                    if VFM.saved.combatOnly then
                        return VFM.inCombat and true or false
                    end

                    return true
                end

                barRef.vfmCombatRequirementWrapper = wrapper
                barRef:SetExternalVisibilityRequirement(wrapper)
                barRef.vfmCombatRequirementInstalled = true
            end
        end
    end

    return true
end

function VFM.UpdateForceShowState()
    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return
    end

    -- Use the native per-bar reference counter instead of the group's boolean
    -- ForceShow switch. That gives this addon its own reference and avoids
    -- accidentally clearing another addon's request when we stop forcing bars.
    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        local shouldForce = VFM.ShouldForceShowBars(bar)
        if bar and bar.AddForcedVisibleReference and bar.RemoveForcedVisibleReference then
            if shouldForce and not bar.vfmForcedVisibleReference then
                bar:AddForcedVisibleReference()
                bar.vfmForcedVisibleReference = true
            elseif not shouldForce and bar.vfmForcedVisibleReference then
                bar:RemoveForcedVisibleReference()
                bar.vfmForcedVisibleReference = false
            end
        end
    end
end

function VFM.RefreshNativeBarVisibility()
    local bars = VFM.GetBars()
    if not bars then
        return
    end

    for _, bar in ipairs(bars) do
        if bar then
            -- UpdateStatusBar refreshes values that may not have been processed
            -- while Combat Only's external visibility requirement was false.
            if bar.UpdateStatusBar then
                bar:UpdateStatusBar()
            end
            if bar.UpdateContextualFading then
                bar:UpdateContextualFading()
            end
        end
    end
end

function VFM.ShouldHardHidePrimaryBar(bar)
    if not VFM.saved or not VFM.IsPrimaryBar(bar) then
        return false
    end

    if VFM.IsPrimaryBarReplacedByDSSelf(bar) then
        return true
    end

    return VFM.saved.combatOnly == true
        and VFM.saved.locked == true
        and VFM.inCombat ~= true
end

function VFM.SetPrimaryBarHardHidden(bar, hidden)
    if not VFM.IsPrimaryBar(bar) or not bar.control then
        return false
    end

    local control = bar.control
    hidden = hidden and true or false

    if hidden then
        -- Timeline state alone is not enough. ESO can restart the contextual
        -- fade animation after interactions, resource updates and scene changes.
        -- Physically hide the primary control as the final authority while the
        -- Combat Only rule owns it.
        if bar.timeline and bar.timeline.PlayInstantlyToStart then
            bar.timeline:PlayInstantlyToStart(true)
        end
        bar.isContextuallyShown = false
        if control.SetAlpha then
            control:SetAlpha(0)
        end
        if control.SetHidden then
            control:SetHidden(true)
        end
        bar.vfmCombatHardHidden = true
        return true
    end

    if bar.vfmCombatHardHidden then
        bar.vfmCombatHardHidden = false
        if control.SetHidden then
            control:SetHidden(false)
        end
        if control.SetAlpha then
            control:SetAlpha(1)
        end
        -- Once Ultivite releases its hard hide, return ownership of fading to
        -- ESO. In combat this makes the resource bar visible immediately.
        if bar.UpdateContextualFading then
            bar:UpdateContextualFading()
        end
    end

    return false
end

function VFM.InstallPrimaryBarHardHideHooks()
    if not ZO_PostHook then
        return false
    end

    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return false
    end

    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        if bar then
            if type(bar.UpdateContextualFading) == "function" and not bar.vfmContextualFadeHardHideHook then
                local barRef = bar
                ZO_PostHook(barRef, "UpdateContextualFading", function()
                    if VFM.ShouldHardHidePrimaryBar(barRef) and barRef.control then
                        barRef.isContextuallyShown = false
                        if barRef.control.SetAlpha then barRef.control:SetAlpha(0) end
                        if barRef.control.SetHidden then barRef.control:SetHidden(true) end
                        barRef.vfmCombatHardHidden = true
                    end
                end)
                bar.vfmContextualFadeHardHideHook = true
            end

            if type(bar.UpdateStatusBar) == "function" and not bar.vfmStatusHardHideHook then
                local barRef = bar
                ZO_PostHook(barRef, "UpdateStatusBar", function()
                    if VFM.ShouldHardHidePrimaryBar(barRef) and barRef.control then
                        barRef.isContextuallyShown = false
                        if barRef.control.SetAlpha then barRef.control:SetAlpha(0) end
                        if barRef.control.SetHidden then barRef.control:SetHidden(true) end
                        barRef.vfmCombatHardHidden = true
                    end
                end)
                bar.vfmStatusHardHideHook = true
            end
        end
    end

    return true
end

function VFM.ApplyImmediateCombatOnlyHide()
    if not VFM.saved then
        return
    end

    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        return
    end

    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        if bar then
            VFM.SetPrimaryBarHardHidden(bar, VFM.ShouldHardHidePrimaryBar(bar))
        end
    end
end

function VFM.UpdateCombatVisibility(inCombat)
    if inCombat ~= nil then
        VFM.inCombat = inCombat and true or false
    elseif IsUnitInCombat then
        VFM.inCombat = IsUnitInCombat("player") and true or false
    end

    if not VFM.runtimeReady or not VFM.saved then
        return
    end

    VFM.InstallCombatVisibilityRequirements()
    VFM.InstallPrimaryBarHardHideHooks()
    VFM.UpdateForceShowState()
    VFM.RefreshNativeBarVisibility()
    VFM.ApplyImmediateCombatOnlyHide()
end

function VFM.SetCombatOnly(enabled, silent)
    VFM.saved.combatOnly = enabled and true or false

    -- FAB+ has no native whole-action-bar combat-only SavedVariable. Ultivite
    -- therefore synchronizes the shared ZO_ActionBar1 root through its bridge
    -- instead of writing a made-up setting into FAB's SavedVariables.
    VFM.RequestSettingsSave()
    VFM.UpdateCombatVisibility()
    if FAB and FAB.ApplyCombatOnlyVisibility then
        FAB.ApplyCombatOnlyVisibility(VFM.saved.combatOnly ~= true)
    end
    VFM.ApplyBarGeometry()
    if VFM.saved.darkSoulsMode then
        VFM.ApplyDarkSoulsHealthStyle()
    end
    VFM.AnchorAllBarsToSavedPositions()
    VFM.PositionAllMovers()
    VFM.UpdateAllMoverSizes()
    VFM.UpdateAllMoverLabels()
    VFM.UpdateDSUltimateControl()
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()
    VFM.UpdateDSEnemyHealthBar()

    if not silent then
        Print(VFM.saved.combatOnly and "Combat HUD: only in combat" or "Combat HUD: always visible")
    end
end

function VFM.OnCombatStateChanged(_, inCombat)
    VFM.UpdateCombatVisibility(inCombat)

    -- Reconcile UI elements using Hide In Combat immediately on both entry and
    -- exit. Champion progress uses ESO's shared progress-bar object, so apply it
    -- separately from the named-control visibility manager.
    VFM.RefreshUiVisibilityRules(false)
    VFM.ApplyChampionProgressVisibility(true)

    -- Apply the independent bottom Dark Souls combat-only rule immediately on
    -- combat transitions instead of waiting for the 50 ms updater.
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()
    VFM.UpdateDSEnemyHealthBar()
    VFM.UpdateDSUltimateControl()
    if FAB and FAB.ApplyCombatOnlyVisibility then
        FAB.ApplyCombatOnlyVisibility()
    end

    -- ESO may refresh ZO_ActionBar1 visibility when combat state changes.
    -- Reassert the independent action-bar hiding option immediately.
    if VFM.saved and VFM.saved.hideActionBar then
        zo_callLater(function()
            VFM.ApplyActionBarHidden()
        end, 0)
    end
end

function VFM.SetEditingVisibility(unlocked)
    -- Keep a single edit visibility entry point so locking, unlocking and
    -- Combat Only all converge on the same native visibility logic.
    VFM.UpdateCombatVisibility()
end

function VFM.SetLocked(locked, silent)
    local newLocked = locked and true or false
    local wasLocked = VFM.saved.locked and true or false

    if not newLocked and (wasLocked or not VFM.editSnapshot) then
        VFM.CaptureEditSnapshot()
    end

    VFM.saved.locked = newLocked
    VFM.RequestSettingsSave()
    VFM.CreateMovers()
    VFM.CreateEditToolbar()

    if VFM.saved.locked then
        VFM.CancelManualDrag()
        -- Dragging writes the bar anchors continuously, so locking should not
        -- re-derive positions from the visual mover rectangles. This avoids
        -- any scale-origin drift and preserves the exact saved coordinates.
        VFM.AnchorAllBarsToSavedPositions()
        for _, key in ipairs(BAR_KEYS) do
            local moverData = VFM.movers[key]
            moverData.control:SetMouseEnabled(false)
            moverData.control:SetHidden(true)
        end
        VFM.SetEditingVisibility(false)
        VFM.CommitEditSession()
    else
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverSizes()
        VFM.UpdateAllMoverLabels()
        for _, key in ipairs(BAR_KEYS) do
            local moverData = VFM.movers[key]
            moverData.control:SetHidden(false)
            moverData.control:SetMouseEnabled(true)
        end
        VFM.SetEditingVisibility(true)
        VFM.UpdateEditToolbar()
    end

    if not silent then
        if VFM.saved.locked then
            Print("Player bars saved and locked")
        else
            Print("Edit mode enabled. Drag to move, mouse wheel to resize, right click a bar to undo its movement. Use the small toolbar to save, undo or cancel.")
        end
    end
end

function VFM.SetSnapToGrid(enabled)
    VFM.saved.snapToGrid = enabled and true or false
    VFM.RequestSettingsSave()

    if VFM.saved.snapToGrid then
        for _, key in ipairs(BAR_KEYS) do
            local x, y = VFM.GetSavedPosition(key)
            VFM.SetSavedPosition(key, x, y, true)
        end
        VFM.ApplyPositions()
    end

    VFM.UpdateAllMoverLabels()
    VFM.RefreshEditDirty()
end

function VFM.SetGridSize(value)
    VFM.saved.gridSize = Clamp(zo_round(value), 2, 100)
    VFM.RequestSettingsSave()

    if VFM.saved.snapToGrid then
        for _, key in ipairs(BAR_KEYS) do
            local x, y = VFM.GetSavedPosition(key)
            VFM.SetSavedPosition(key, x, y, true)
        end
        VFM.ApplyPositions()
    end

    VFM.UpdateAllMoverLabels()
    VFM.RefreshEditDirty()
end

function VFM.ApplyPositions()
    if VFM.saved.locked then
        VFM.AnchorAllBarsToSavedPositions()
    else
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
    end
end

function VFM.SetBarPositionAxis(key, axis, value)
    local x, y = VFM.GetSavedPosition(key)
    if axis == "x" then
        x = value
    else
        y = value
    end
    VFM.SetSavedPosition(key, x, y, true)
    VFM.ApplyPositions()
    VFM.UpdateMoverLabel(key)
end

function VFM.CenterBarHorizontally(key)
    local _, y = VFM.GetSavedPosition(key)
    VFM.SetSavedPosition(key, 0, y, true)
    VFM.ApplyPositions()
    VFM.UpdateMoverLabel(key)
    Print(BAR_INFO[key].displayName .. " centered horizontally")
end

function VFM.AlignAllToHealthY()
    local _, healthY = VFM.GetSavedPosition("health")
    local magX = select(1, VFM.GetSavedPosition("magicka"))
    local stamX = select(1, VFM.GetSavedPosition("stamina"))

    VFM.SetSavedPosition("magicka", magX, healthY, true)
    VFM.SetSavedPosition("stamina", stamX, healthY, true)
    VFM.ApplyPositions()
    VFM.UpdateAllMoverLabels()
    Print("Magicka and Stamina aligned to Health Y")
end

function VFM.GetVisualPrimaryBarWidth()
    local control = VFM.GetPrimaryControl("health")
    local transformX = VFM.GetActiveBarWidthScale()

    if control and control.GetTransformScale then
        local x = control:GetTransformScale()
        transformX = tonumber(x) or transformX
    end

    local module = VFM.FindShrinkExpandModule()
    local rawNormalWidth = module and tonumber(module.normalWidth)
    if not rawNormalWidth or rawNormalWidth <= 0 then
        -- The proven v9 horizontal sizing path scales both ESO's managed raw
        -- normal width and the native control transform. Preserve that exact
        -- behavior so existing saved sizes do not visually change on upgrade.
        rawNormalWidth = NORMAL_WIDTH * VFM.GetActiveBarWidthScale()
    end

    return rawNormalWidth * transformX
end

function VFM.GetVisualPrimaryBarHeight()
    local control = VFM.GetPrimaryControl("health")
    if control then
        local rawHeight = tonumber(control:GetHeight()) or 23
        local transformY = VFM.GetActiveBarThicknessScale()
        if control.GetTransformScale then
            local _, y = control:GetTransformScale()
            transformY = tonumber(y) or transformY
        end
        return rawHeight * transformY
    end

    return 23 * VFM.GetActiveBarThicknessScale()
end

function VFM.ApplyBottomCompactLayout(silent)
    local rootHeight = GuiRoot:GetHeight() or 1080
    local gap = Clamp(VFM.saved.compactGap, 0, 200)
    local bottomMargin = Clamp(VFM.saved.bottomMargin, 0, 300)
    local width = VFM.GetVisualPrimaryBarWidth()
    local height = VFM.GetVisualPrimaryBarHeight()

    local y = (rootHeight / 2) - bottomMargin - (height / 2)
    local sideX = width + gap

    VFM.SetSavedPosition("health", 0, y, true)
    VFM.SetSavedPosition("magicka", -sideX, y, true)
    VFM.SetSavedPosition("stamina", sideX, y, true)

    VFM.ApplyPositions()
    VFM.UpdateAllMoverLabels()

    if not silent then
        Print("Bottom compact layout applied: MAGICKA | HEALTH | STAMINA")
    end
end

function VFM.SetCompactGap(value)
    VFM.saved.compactGap = Clamp(zo_round(value), 0, 200)
    VFM.RequestSettingsSave()
end

function VFM.SetBottomMargin(value)
    VFM.saved.bottomMargin = Clamp(zo_round(value), 0, 300)
    VFM.RequestSettingsSave()
end

function VFM.ApplyUltiviteBottomPreset(silent)
    -- Recommended Ultivite layout captured in game. Keep these
    -- exact saved offsets rather than recalculating from screen dimensions.
    VFM.saved.barWidth = 1.455
    VFM.saved.barThickness = 2.123
    VFM.saved.compactGap = 24
    VFM.saved.bottomMargin = 8
    VFM.saved.individualPositionsInitialized = true
    VFM.SetSavedPosition("health", 0, 623, false)
    VFM.SetSavedPosition("magicka", -553, 623, false)
    VFM.SetSavedPosition("stamina", 553, 623, false)
    VFM.ApplyBarGeometry()
    VFM.ApplyPositions()
    VFM.UpdateAllMoverLabels()
    VFM.RequestSettingsSave()

    if not silent then
        Print("Recommended player-bar layout restored")
    end
end

function VFM.SetDarkSoulsTopLeftX(value)
    VFM.saved.darkSoulsLeft = Clamp(zo_round(value), -400, 2400)
    VFM.RequestSettingsSave()
    if VFM.saved.darkSoulsMode then
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverLabels()
    end
end

function VFM.SetDarkSoulsTopLeftY(value)
    VFM.saved.darkSoulsTop = Clamp(zo_round(value), 0, 1600)
    VFM.RequestSettingsSave()
    if VFM.saved.darkSoulsMode then
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverLabels()
    end
end

function VFM.SetDarkSoulsTopLeftGap(value)
    VFM.saved.darkSoulsGap = Clamp(zo_round(value), 0, 100)
    VFM.RequestSettingsSave()
    if VFM.saved.darkSoulsMode then
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverLabels()
    end
end

function VFM.SetDarkSoulsBottomX(value)
    VFM.saved.dsBottomX = Clamp(zo_round(value), -1600, 1600)
    VFM.RequestSettingsSave()
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()
end

function VFM.SetDarkSoulsBottomDistance(value)
    VFM.saved.dsBottomOffset = -Clamp(zo_round(value), 0, 700)
    VFM.RequestSettingsSave()
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()
end

function VFM.SetDarkSoulsBottomGap(value)
    VFM.saved.dsBottomGap = Clamp(zo_round(value), 0, 100)
    VFM.RequestSettingsSave()
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()
end

function VFM.SetDSSelfScale(value)
    if not VFM.saved then return end
    VFM.saved.dsSelfScale = Clamp(tonumber(value) or 1.0, 0.50, 2.50)
    for _, control in ipairs({ VFM.dsSelfHealthControl, VFM.dsSelfMagickaControl, VFM.dsSelfStaminaControl }) do
        if control and control.frame then control.frame:SetScale(VFM.saved.dsSelfScale) end
    end
    VFM.RequestSettingsSave()
    VFM.UpdateDSSelfHealthBar()
    VFM.UpdateDSSelfResourceBars()
end

function VFM.GetLayoutPositioningLines()
    local lines = {}
    local rootW, rootH = 0, 0
    if GuiRoot and GuiRoot.GetDimensions then
        rootW, rootH = GuiRoot:GetDimensions()
    end

    local hX, hY = VFM.GetSavedPosition("health")
    local mX, mY = VFM.GetSavedPosition("magicka")
    local sX, sY = VFM.GetSavedPosition("stamina")
    lines[#lines + 1] = string.format("SCREEN root=(%.1f,%.1f)", tonumber(rootW) or 0, tonumber(rootH) or 0)
    lines[#lines + 1] = string.format(
        "NORMAL health=(%.1f,%.1f) magicka=(%.1f,%.1f) stamina=(%.1f,%.1f) width=%.3f thickness=%.3f gap=%d bottom=%d",
        hX, hY, mX, mY, sX, sY,
        tonumber(VFM.saved.barWidth) or 0,
        tonumber(VFM.saved.barThickness) or 0,
        tonumber(VFM.saved.compactGap) or 0,
        tonumber(VFM.saved.bottomMargin) or 0
    )
    lines[#lines + 1] = string.format(
        "DARKSOULS topLeft=(%.1f,%.1f) topGap=%d mode=%s full=%s ultimate=%s hideActionBar=%s combatOnly=%s",
        tonumber(VFM.saved.darkSoulsLeft) or DARKSOULS_LEFT,
        tonumber(VFM.saved.darkSoulsTop) or DARKSOULS_TOP,
        tonumber(VFM.saved.darkSoulsGap) or DARKSOULS_BAR_GAP,
        tostring(VFM.saved.darkSoulsMode == true),
        tostring(VFM.saved.fullDarkSoulsMode == true),
        tostring(VFM.saved.showDSUltimate == true),
        tostring(VFM.saved.hideActionBar == true),
        tostring(VFM.saved.combatOnly == true)
    )
    lines[#lines + 1] = string.format(
        "DSENEMY mode=%s x=%.1f bottomDistance=%d width=%d height=%d reticle=%s",
        tostring(VFM.saved.dsEnemyHealthMode or DS_ENEMY_HEALTH_MODE_OFF),
        tonumber(VFM.saved.dsEnemyX) or 0,
        math.abs(tonumber(VFM.saved.dsEnemyBottomOffset) or DS_ENEMY_HEALTH_BOTTOM_OFFSET),
        tonumber(VFM.saved.dsEnemyWidth) or DS_ENEMY_HEALTH_WIDTH,
        tonumber(VFM.saved.dsEnemyHeight) or DS_ENEMY_HEALTH_HEIGHT,
        tostring(VFM.saved.dsEnemyTrackReticle == true)
    )
    lines[#lines + 1] = string.format(
        "DSSELF health=%s resources=%s bottomOnly=%s combatOnly=%s x=%.1f bottomDistance=%d gap=%d width=%d height=%d",
        tostring(VFM.saved.dsSelfHealthBar == true),
        tostring(VFM.saved.dsSelfResourceBars == true),
        tostring(VFM.saved.dsBottomOnly == true),
        tostring(VFM.saved.dsSelfHealthCombatOnly == true),
        tonumber(VFM.saved.dsBottomX) or 0,
        math.abs(tonumber(VFM.saved.dsBottomOffset) or DS_SELF_HEALTH_BOTTOM_OFFSET),
        tonumber(VFM.saved.dsBottomGap) or DS_SELF_RESOURCE_GAP,
        DS_SELF_HEALTH_WIDTH,
        DS_SELF_HEALTH_HEIGHT
    )
    lines[#lines + 1] = string.format(
        "VISIBILITY compass=%s quests=%s queue=%s crosshair=%s champion=%s autoHideChat=%s",
        tostring(VFM.saved.compassVisibilityMode or "show"),
        tostring(VFM.saved.questTrackerVisibilityMode or "show"),
        tostring(VFM.saved.queueStatusVisibilityMode or "show"),
        tostring(VFM.saved.crosshairVisibilityMode or "show"),
        tostring(VFM.GetChampionProgressVisibilityMode()),
        tostring(VFM.saved.autoHideChat == true)
    )
    return lines
end

function VFM.PrintLayoutPositioning()
    for _, line in ipairs(VFM.GetLayoutPositioningLines()) do
        Print("LAYOUT " .. line)
    end
end

function VFM.ResetPositions()
    for _, key in ipairs(BAR_KEYS) do
        local vanilla = VFM.vanillaPositions[key]
        if vanilla then
            VFM.SetSavedPosition(key, vanilla.x, vanilla.y, true)
        end
    end
    VFM.ApplyPositions()
    VFM.UpdateAllMoverLabels()
    Print("All player bar positions reset")
end

function VFM.SetBarWidth(value, silent)
    VFM.saved.barWidth = Clamp(value, 0.50, MAX_BAR_SCALE)
    VFM.RequestSettingsSave()
    VFM.ApplyBarGeometry()
    VFM.ApplyTextStyle()
    VFM.RefreshEditDirty()

    if not silent then
        Print(string.format("Bar width set to %d%%", zo_round(VFM.saved.barWidth * 100)))
    end
end

function VFM.SetBarThickness(value, silent)
    VFM.saved.barThickness = Clamp(value, 0.50, MAX_BAR_SCALE)
    VFM.RequestSettingsSave()
    VFM.ApplyBarGeometry()
    VFM.ApplyTextStyle()
    VFM.RefreshEditDirty()

    if not silent then
        Print(string.format("Bar thickness set to %d%%", zo_round(VFM.saved.barThickness * 100)))
    end
end

function VFM.SetOverallSize(value, silent)
    local newWidth = Clamp(value, 0.50, MAX_BAR_SCALE)
    local oldWidth = Clamp(VFM.saved.barWidth, 0.50, MAX_BAR_SCALE)
    local oldThickness = Clamp(VFM.saved.barThickness, 0.50, MAX_BAR_SCALE)
    local ratio = oldThickness / oldWidth

    VFM.saved.barWidth = newWidth
    VFM.saved.barThickness = Clamp(newWidth * ratio, 0.50, MAX_BAR_SCALE)
    VFM.RequestSettingsSave()
    VFM.ApplyBarGeometry()
    VFM.ApplyTextStyle()
    VFM.RefreshEditDirty()

    if not silent then
        Print(string.format("Overall bar size set to %d%% while preserving thickness", zo_round(newWidth * 100)))
    end
end

function VFM.ResetSize()
    VFM.saved.barWidth = defaults.barWidth
    VFM.saved.barThickness = defaults.barThickness
    VFM.RequestSettingsSave()
    VFM.ApplyBarGeometry()
    VFM.ApplyTextStyle()
    VFM.UpdateAllMoverHints()
    VFM.RefreshEditDirty()
    Print("Player bar size reset")
end

function VFM.ResetText()
    VFM.saved.font = defaults.font
    VFM.saved.textScale = defaults.textScale
    VFM.saved.textMode = defaults.textMode
    VFM.RequestSettingsSave()
    VFM.ApplyTextStyle()
    Print("Resource text reset")
end

function VFM.ResetAll()
    if VFM.saved.darkSoulsMode then
        VFM.RestoreDarkSoulsHealthStyle()
    end
    if VFM.saved.hideActionBar then
        VFM.RestoreActionBarVisibility()
    end
    if VFM.saved.dsEnemyHealthMode ~= DS_ENEMY_HEALTH_MODE_OFF then
        VFM.SetDSEnemyHealthMode(DS_ENEMY_HEALTH_MODE_OFF, true)
    end
    if VFM.saved.dsSelfHealthBar then
        VFM.SetDSSelfHealthBar(false, true)
    end
    VFM.saved.combatOnly = defaults.combatOnly
    VFM.saved.hideWerewolfResourceBar = defaults.hideWerewolfResourceBar
    VFM.saved.hideMountStaminaBar = defaults.hideMountStaminaBar
    VFM.saved.darkSoulsMode = defaults.darkSoulsMode
    VFM.saved.hideActionBar = defaults.hideActionBar
    VFM.saved.showDSUltimate = defaults.showDSUltimate
    VFM.saved.dsEnemyHealthMode = defaults.dsEnemyHealthMode
    VFM.saved.dsSelfHealthBar = defaults.dsSelfHealthBar
    VFM.saved.dsSelfHealthCombatOnly = defaults.dsSelfHealthCombatOnly
    VFM.saved.dsSelfResourceBars = defaults.dsSelfResourceBars
    VFM.saved.dsBottomOnly = defaults.dsBottomOnly
    VFM.saved.snapToGrid = defaults.snapToGrid
    VFM.saved.gridSize = defaults.gridSize
    VFM.saved.barWidth = defaults.barWidth
    VFM.saved.barThickness = defaults.barThickness
    VFM.saved.compactGap = defaults.compactGap
    VFM.saved.bottomMargin = defaults.bottomMargin
    VFM.saved.darkSoulsLeft = defaults.darkSoulsLeft
    VFM.saved.darkSoulsTop = defaults.darkSoulsTop
    VFM.saved.darkSoulsGap = defaults.darkSoulsGap
    VFM.saved.dsBottomX = defaults.dsBottomX
    VFM.saved.dsBottomOffset = defaults.dsBottomOffset
    VFM.saved.dsBottomGap = defaults.dsBottomGap
    VFM.saved.font = defaults.font
    VFM.saved.textScale = defaults.textScale
    VFM.saved.textMode = defaults.textMode
    VFM.saved.individualPositionsInitialized = true

    VFM.SetSavedPosition("health", defaults.healthX, defaults.healthY, false)
    VFM.SetSavedPosition("magicka", defaults.magickaX, defaults.magickaY, false)
    VFM.SetSavedPosition("stamina", defaults.staminaX, defaults.staminaY, false)
    VFM.RequestSettingsSave()

    VFM.ApplyBarGeometry()
    VFM.ApplyTextStyle()
    VFM.ApplyPositions()
    VFM.UpdateAllMoverLabels()
    VFM.UpdateCombatVisibility()
    VFM.ApplyWerewolfResourceBarVisibility()
    VFM.ApplyMountStaminaBarVisibility()
    VFM.RefreshEditDirty()
    Print("Vanilla player bars reset")
end

function VFM.PrintGeometryDebug()
    local bars = VFM.GetPrimaryBarObjects()
    if not bars then
        Print("Primary bars are not available yet")
        return
    end

    local module = VFM.FindShrinkExpandModule()
    Print(string.format(
        "Persistence v10.7.12 | ready %s | load %s | scope %s | world %s | health %.0f,%.0f | width %.2f | thickness %.2f",
        tostring(VFM.runtimeReady and true or false),
        tostring(VFM.accountSaved and VFM.accountSaved.persistenceLoadCount or "?"),
        VFM.IsUsingAccountWideSettings() and "ACCOUNT" or "CHARACTER",
        tostring((GetWorldName and GetWorldName()) or "?"),
        tonumber(VFM.saved.healthX) or 0, tonumber(VFM.saved.healthY) or 0,
        tonumber(VFM.saved.barWidth) or 0, tonumber(VFM.saved.barThickness) or 0
    ))
    Print(string.format("Requested WIDTH %d%%  THICKNESS %d%%  TEXT %d%%", zo_round(VFM.saved.barWidth * 100), zo_round(VFM.saved.barThickness * 100), zo_round(VFM.saved.textScale * 100)))
    if module then
        Print(string.format("ShrinkExpand raw widths normal %.1f expanded %.1f shrunk %.1f  expected normal visual width %.1f", module.normalWidth or 0, module.expandedWidth or 0, module.shrunkWidth or 0, VFM.GetVisualPrimaryBarWidth()))
    else
        Print("ShrinkExpand module NOT FOUND")
    end

    for _, key in ipairs(BAR_KEYS) do
        local bar = bars[key]
        local control = bar and bar.control
        if control then
            local width = control:GetWidth()
        local height = control:GetHeight()
            local bg = control:GetNamedChild("BgContainer")
            local bgWidth, bgHeight = 0, 0
            if bg then
                bgWidth, bgHeight = bg:GetDimensions()
            end

            local fillHeight = 0
            if bar.barControls and bar.barControls[1] then
                fillHeight = bar.barControls[1]:GetHeight() or 0
            end

            local transformX, transformY = 1, 1
            if control.GetTransformScale then
                transformX, transformY = control:GetTransformScale()
                transformX = transformX or 1
                transformY = transformY or transformX
            end

            Print(string.format(
                "%s raw %.0fx%.0f  transform %.2fx%.2f  VISUAL %.0fx%.0f  bg %.0fx%.0f  fillH %.0f",
                BAR_INFO[key].displayName,
                width or 0,
                height or 0,
                transformX,
                transformY,
                (width or 0) * transformX,
                (height or 0) * transformY,
                bgWidth or 0,
                bgHeight or 0,
                fillHeight
            ))
        end
    end
end

function VFM.ScheduleAttributeVisualReapply()
    if VFM.visualReapplyPending then
        return
    end

    VFM.visualReapplyPending = true
    zo_callLater(function()
        VFM.visualReapplyPending = false
        if VFM.runtimeReady then
            VFM.ApplyBarGeometry()
            VFM.ApplyDarkSoulsHealthStyle()
            VFM.ApplyTextStyle()
            -- Attribute visual updates can restart ESO's native resource-bar
            -- timelines. Reapply Combat Only immediately after the visual pass.
            VFM.UpdateCombatVisibility()
        end
    end, 0)
end

function VFM.OnAttributeVisualChanged(_, unitTag)
    if unitTag == "player" then
        VFM.ScheduleAttributeVisualReapply()
    end
end

function VFM.ApplySavedLayoutDirect(reason, force)
    if not VFM.saved or not VFM.GetPrimaryBarObjects() then
        return false
    end

    -- This path intentionally has no runtimeReady dependency. The saved layout
    -- is authoritative as soon as Health, Magicka and Stamina exist.
    VFM.ApplyBarGeometry()
    VFM.ApplyDarkSoulsHealthStyle()
    VFM.ApplyTextStyle()
    VFM.AnchorAllBarsToSavedPositions()
    VFM.PositionAllMovers()
    VFM.UpdateAllMoverSizes()
    VFM.UpdateAllMoverLabels()
    VFM.ApplyActionBarHidden()
    VFM.ApplyGroupFrameState()
    VFM.ApplyGroupFrameChampionPoints()
    VFM.ApplyWerewolfResourceBarVisibility()
    VFM.ApplyMountStaminaBarVisibility()
    VFM.UpdateDSUltimateControl()
    VFM.RefreshBattlegroundQueueSuppressor()
    VFM.RefreshUiVisibilityRules()
    VFM.RefreshDSEnemyHealthRuntime()
    VFM.RefreshDSSelfHealthRuntime()

    VFM.lastDirectApplyReason = tostring(reason or "direct")
    VFM.lastDirectApplyAt = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0

    if force then
        VFM.layoutRepairCount = (tonumber(VFM.layoutRepairCount) or 0) + 1
        VFM.lastLayoutRepairReason = VFM.lastDirectApplyReason
        VFM.lastLayoutRepairAt = VFM.lastDirectApplyAt
    end

    return true
end

function VFM.ApplyAll()
    VFM.applyPending = false

    if not VFM.runtimeReady then
        return false
    end

    VFM.CreateMovers()
    VFM.PatchResourceText()
    VFM.ApplyBarGeometry()
    VFM.ApplyDarkSoulsHealthStyle()
    VFM.ApplyTextStyle()
    VFM.ApplyActionBarHidden()
    VFM.ApplyGroupFrameState()
    VFM.ApplyGroupFrameChampionPoints()
    VFM.ApplyWerewolfResourceBarVisibility()
    VFM.ApplyMountStaminaBarVisibility()
    VFM.UpdateDSUltimateControl()
    VFM.RefreshDSEnemyHealthRuntime()
    VFM.RefreshDSSelfHealthRuntime()
    VFM.RefreshNavigationHelpers(true)

    if VFM.saved.locked then
        VFM.AnchorAllBarsToSavedPositions()
        for _, key in ipairs(BAR_KEYS) do
            local moverData = VFM.movers[key]
            moverData.control:SetHidden(true)
            moverData.control:SetMouseEnabled(false)
        end
        VFM.SetEditingVisibility(false)
    else
        if not VFM.editSnapshot then
            VFM.CaptureEditSnapshot()
        end
        VFM.CreateEditToolbar()
        VFM.AnchorAllBarsToSavedPositions()
        VFM.PositionAllMovers()
        VFM.UpdateAllMoverSizes()
        VFM.UpdateAllMoverLabels()
        for _, key in ipairs(BAR_KEYS) do
            local moverData = VFM.movers[key]
            moverData.control:SetHidden(false)
            moverData.control:SetMouseEnabled(true)
        end
        VFM.SetEditingVisibility(true)
        VFM.UpdateEditToolbar()
    end

    return true
end

function VFM.PrepareRuntime(forceGeometryCapture)
    if not VFM.saved then
        VFM.lastPrepareFailure = "saved variables unavailable"
        return false
    end

    -- The three native bar objects are the only hard requirement. Older builds
    -- also required PLAYER_ATTRIBUTE_BARS.control plus successful center/base
    -- geometry capture. After /reloadui those optional pieces can lag behind the
    -- bars themselves, leaving runtimeReady false forever while diagnostics can
    -- already see the bars.
    local primary = VFM.GetPrimaryBarObjects()
    if not primary then
        VFM.lastPrepareFailure = "primary bars unavailable"
        return false
    end

    if not VFM.saved.individualPositionsInitialized then
        if not VFM.CaptureIndividualPositions() then
            VFM.lastPrepareFailure = "initial position capture pending"
            return false
        end
    elseif not VFM.vanillaPositions.health then
        -- Reset-to-vanilla metadata is optional for normal operation. Never let
        -- a temporarily missing GetCenter() block saved layout application.
        VFM.CaptureVanillaPositionsOnly()
    end

    if forceGeometryCapture or not VFM.baseGeometry then
        -- Base geometry is diagnostic/reset metadata only in this build. Capture
        -- it when possible, but do not gate runtime readiness on it.
        VFM.CaptureBaseGeometry(true)
    end

    VFM.runtimeReady = true
    VFM.lastPrepareFailure = "ok"
    VFM.saved.geometryVersion = 8
    return true
end

function VFM.ScheduleApply(delay)
    if VFM.applyPending then
        return
    end

    VFM.applyPending = true
    zo_callLater(function()
        VFM.applyPending = false

        -- First restore the actual native controls immediately. This succeeds
        -- even when runtime preparation is still waiting on optional metadata.
        local directApplied = VFM.ApplySavedLayoutDirect("scheduled startup", false)
        local prepared = VFM.PrepareRuntime(false)

        if prepared then
            VFM.ApplyAll()
        end

        if not directApplied and not prepared then
            zo_callLater(function()
                VFM.ScheduleApply(250)
            end, 250)
        end
    end, delay or 100)
end

function VFM.OnPlayerActivated()
    if IsUnitInCombat then
        VFM.inCombat = IsUnitInCombat("player") and true or false
    end

    VFM.InstallLuiCompatibilityHook()
    VFM.EnsureSlashCommandOwnership()
    VFM.RefreshDSEnemyHealthRuntime()
    VFM.RefreshDSSelfHealthRuntime()
    -- Player activation is a safe HUD point to repair a compass or quest tracker
    -- left hidden by the previous PvP zone before ESO finishes the transition.
    VFM.RefreshUiVisibilityRules(true)
    VFM.UpdateCombatVisibility(VFM.inCombat)
    VFM.ApplyWerewolfResourceBarVisibility()
    VFM.ApplyMountStaminaBarVisibility()
    VFM.RefreshNavigationHelpers(true)
    if VFM.saved and VFM.saved.autoHideChat then
        zo_callLater(function() VFM.ApplyAutoHideChat() end, 500)
    end

    zo_callLater(function()
        VFM.ApplySavedLayoutDirect("player activated", false)
        if VFM.PrepareRuntime(false) then
            VFM.ApplyAll()
            VFM.CheckAzurahCompatibility()
        else
            VFM.ScheduleApply(250)
        end
    end, 250)
end

function VFM.OnPlatformStyleChanged()
    zo_callLater(function()
        VFM.baseGeometry = nil
        VFM.shrinkExpandModule = nil
        VFM.actionBarPlatformRefreshPending = false
        -- Keep actionBarVisibilitySnapshot intact while the independent Hide
        -- action bar option is active. Recapturing a hidden root here would save
        -- the temporary hidden state and prevent correct restoration on toggle-off.
        if VFM.PrepareRuntime(true) then
            VFM.ApplyAll()
        end
    end, 150)
end

function VFM.CopyProfileSettings(source, destination)
    if not source or not destination then
        return
    end

    for _, key in ipairs(PROFILE_SETTING_KEYS) do
        destination[key] = source[key]
    end
end

function VFM.IsUsingAccountWideSettings()
    if Ultivite and U.IsUsingAccountWideSettings then
        return U.IsUsingAccountWideSettings()
    end
    return not VFM.accountSaved or VFM.accountSaved.useAccountWide ~= false
end

function VFM.SetAccountWideSettings(enabled, silent)
    if Ultivite and U.SetAccountWideSettings then
        U.SetAccountWideSettings(enabled, silent)
        return
    end
end

local QUICK_PLAYER_LAYOUT_NORMAL = "normal"
local QUICK_PLAYER_LAYOUT_TOPLEFT = "topLeft"
local QUICK_PLAYER_LAYOUT_BOTTOM = "bottomOnly"
local QUICK_PLAYER_LAYOUT_BOTH = "both"

function VFM.GetQuickPlayerLayout()
    if not VFM.saved then return QUICK_PLAYER_LAYOUT_NORMAL end

    local topLeft = VFM.saved.darkSoulsMode == true
    local bottom = VFM.saved.dsSelfHealthBar == true and VFM.saved.dsSelfResourceBars == true
    local bottomOnly = VFM.saved.dsBottomOnly == true

    if bottomOnly and bottom then
        return QUICK_PLAYER_LAYOUT_BOTTOM
    elseif topLeft and bottom then
        return QUICK_PLAYER_LAYOUT_BOTH
    elseif topLeft then
        return QUICK_PLAYER_LAYOUT_TOPLEFT
    end
    return QUICK_PLAYER_LAYOUT_NORMAL
end

function VFM.SetQuickPlayerLayout(layout, silent)
    if not VFM.saved then return end
    layout = tostring(layout or QUICK_PLAYER_LAYOUT_NORMAL)
    VFM.ExitFullDarkSoulsPresetState()

    -- Use the existing setters rather than changing flags directly. They own
    -- resource-text restoration, Dark Souls health artwork, bottom-stack
    -- visibility and native-bar hidden reasons.
    if layout == QUICK_PLAYER_LAYOUT_TOPLEFT then
        VFM.saved.darkSoulsLeft = DARKSOULS_LEFT
        VFM.saved.darkSoulsTop = DARKSOULS_TOP
        VFM.saved.darkSoulsGap = DARKSOULS_BAR_GAP
        VFM.SetDSBottomOnly(false, true)
        VFM.SetDSSelfResourceBars(false, true)
        VFM.SetDSSelfHealthBar(false, true)
        VFM.SetDarkSoulsMode(true, true)
        VFM.SetShowDSUltimate(true, true)
    elseif layout == QUICK_PLAYER_LAYOUT_BOTTOM then
        VFM.SetDarkSoulsMode(false, true)
        VFM.SetDSSelfHealthBar(true, true)
        VFM.SetDSSelfResourceBars(true, true)
        VFM.SetDSBottomOnly(true, true)
        -- Keep the standalone Ultimate preference ready. It remains hidden while
        -- the action bar is shown and appears automatically if Hide Action Bar is enabled.
        VFM.SetShowDSUltimate(true, true)
    elseif layout == QUICK_PLAYER_LAYOUT_BOTH then
        VFM.saved.darkSoulsLeft = DARKSOULS_LEFT
        VFM.saved.darkSoulsTop = DARKSOULS_TOP
        VFM.saved.darkSoulsGap = DARKSOULS_BAR_GAP
        VFM.SetDSBottomOnly(false, true)
        VFM.SetDSSelfHealthBar(true, true)
        VFM.SetDSSelfResourceBars(true, true)
        VFM.SetDarkSoulsMode(true, true)
        VFM.SetShowDSUltimate(true, true)
    else
        VFM.SetDSBottomOnly(false, true)
        VFM.SetDSSelfResourceBars(false, true)
        VFM.SetDSSelfHealthBar(false, true)
        VFM.SetDarkSoulsMode(false, true)
    end

    VFM.RequestSettingsSave()
    VFM.ApplySavedLayoutDirect("quick player layout", true)
    VFM.RefreshDSSelfHealthRuntime()
    VFM.UpdateCombatVisibility()

    if not silent then
        Print("Player layout changed")
    end
end

function VFM.GetMenuOptions()
    local optionsData = {
        {
            type = "description",
            text = "Move, resize and control visibility of ESO's native Health, Magicka and Stamina bars while keeping the vanilla artwork and shield visuals.",
            width = "full",
        },
        {
            type = "header",
            name = "Settings scope",
        },
        {
            type = "checkbox",
            name = "Use account wide settings",
            tooltip = "When enabled, this layout and all Vanilla Frame Mover options are shared by every character on the account. Enabling it copies this character's current settings into the shared profile. Disabling it creates a character specific copy so this character can be adjusted independently.",
            getFunc = function() return VFM.IsUsingAccountWideSettings() end,
            setFunc = function(value) VFM.SetAccountWideSettings(value, false) end,
            width = "full",
        },
        {
            type = "description",
            text = "Profile switching preserves the layout you are currently using, so changing this option does not reset positions or sizing.",
            width = "full",
        },
        {
            type = "header",
            name = "General Visibility",
        },
        {
            type = "checkbox",
            name = "Show bars only in combat",
            tooltip = "Master combat visibility. Health/Magicka/Stamina, Dark Souls Ultimate, the Dark Souls long Health bar and Fancy Action Bar hide together out of combat and show together in combat. Unlocking an editor temporarily shows the element being edited.",
            getFunc = function() return VFM.saved.combatOnly end,
            setFunc = function(value) VFM.SetCombatOnly(value, true) end,
            default = false,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Champion Point progress visibility",
            tooltip = "Show always keeps ESO's native Champion Point progress bar on the normal HUD. Hide in combat suppresses Champion progress while fighting. Hide in PvP suppresses it only in PvP areas. Hide always suppresses Champion progress everywhere. Skill and XP gain animations can still temporarily use the shared progress bar.",
            choices = { "Show always", "Hide in combat", "Hide in PvP only", "Hide always" },
            choicesValues = { "show", "combat", "pvp", "hide" },
            getFunc = function() return VFM.GetChampionProgressVisibilityMode() end,
            setFunc = function(value) VFM.SetChampionProgressVisibilityMode(value, true) end,
            default = "pvp",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide Mount Stamina meter",
            tooltip = "Force hides ESO's small Mount Stamina bar even while mounted. Ultivite also blocks ESO's mount-state refresh from bringing it back. Turn this off to return the meter to normal ESO control.",
            getFunc = function() return VFM.saved.hideMountStaminaBar ~= false end,
            setFunc = function(value) VFM.SetHideMountStaminaBar(value, true) end,
            default = true,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Dark Souls player bars",
            tooltip = "Matches the compact top left Dark Souls resource layout only: wider thin stacked Health, Magicka and Stamina bars with no resource text, all using the same single right-facing Stamina-style silhouette. It does not change the action bar. Turning it off restores your normal saved resource-bar positions, size and text settings.",
            getFunc = function() return VFM.saved.darkSoulsMode end,
            setFunc = function(value) VFM.SetDarkSoulsMode(value, true) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show Ultimate beside Dark Souls bars",
            tooltip = "Shows your active Ultimate icon to the left of the compact top-left Dark Souls bars. In Dark Souls Self, the same icon appears to the left of the large bottom Health/Magicka/Stamina stack whenever the action bar is disabled. The icon is vertically centered against the three bars and displays the live Ultimate number.",
            getFunc = function() return VFM.saved.showDSUltimate end,
            setFunc = function(value) VFM.SetShowDSUltimate(value, true) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide action bar",
            tooltip = "Separately hides the complete ESO action bar root, including Fancy Action Bar+ and Ultimate. This is independent of darksouls mode and restores the previous action-bar visibility when turned off.",
            getFunc = function() return VFM.saved.hideActionBar end,
            setFunc = function(value) VFM.SetHideActionBar(value, true) end,
            width = "full",
        },
        {
            type = "submenu",
            name = "Group frame",
            tooltip = "Controls ESO group/raid frames and the known LUI Extended group-frame controls. The quick menu exposes the same visibility modes.",
            controls = {
                {
                    type = "dropdown",
                    name = "Group frame visibility",
                    tooltip = "ON leaves group frames under normal ESO/LUI control. HIDE IN PVP suppresses them only in Battlegrounds, Cyrodiil and Imperial City. OFF hides them everywhere.",
                    choices = { "ON", "HIDE IN PVP", "OFF" },
                    choicesValues = { "show", "pvp", "hide" },
                    getFunc = function() return VFM.GetGroupFrameVisibilityMode() end,
                    setFunc = function(value) VFM.SetGroupFrameVisibilityMode(value, true) end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Dark Souls enemy health bar",
            tooltip = "Large bottom enemy Health bar used by the Full Dark Souls preset. Position and size are saved and included in account-wide sync.",
            controls = {
                {
                    type = "checkbox",
                    name = "Dark Souls enemy health bar only",
                    tooltip = "Shows the large Dark Souls enemy Health bar and hides ESO's normal target frame for the same target.",
                    getFunc = function() return VFM.saved.dsEnemyHealthMode == DS_ENEMY_HEALTH_MODE_ONLY end,
                    setFunc = function(value)
                        VFM.SetDSEnemyHealthMode(value and DS_ENEMY_HEALTH_MODE_ONLY or DS_ENEMY_HEALTH_MODE_OFF, true)
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Dark Souls enemy health bar + normal",
                    tooltip = "Shows the large Dark Souls enemy Health bar while leaving ESO's normal target frame visible.",
                    getFunc = function() return VFM.saved.dsEnemyHealthMode == DS_ENEMY_HEALTH_MODE_PLUS_NORMAL end,
                    setFunc = function(value)
                        VFM.SetDSEnemyHealthMode(value and DS_ENEMY_HEALTH_MODE_PLUS_NORMAL or DS_ENEMY_HEALTH_MODE_OFF, true)
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show for current reticle enemy",
                    tooltip = "Uses the public reticleover target so the large bar appears for the enemy you are actively aiming at. Full Dark Souls enables this automatically. When off, the legacy preferred/Tab-target behavior is used.",
                    getFunc = function() return VFM.saved.dsEnemyTrackReticle == true end,
                    setFunc = function(value)
                        VFM.saved.dsEnemyTrackReticle = value and true or false
                        VFM.RequestSettingsSave()
                        VFM.UpdateDSEnemyHealthBar()
                    end,
                    width = "full",
                },
                {
                    type = "slider", name = "Enemy bar horizontal offset", min = -1400, max = 1400, step = 1,
                    getFunc = function() return tonumber(VFM.saved.dsEnemyX) or 0 end,
                    setFunc = function(value) VFM.SetDSEnemyGeometryValue("dsEnemyX", value) end, width = "full",
                },
                {
                    type = "slider", name = "Enemy bar distance above bottom", min = 0, max = 900, step = 1,
                    getFunc = function() return math.abs(tonumber(VFM.saved.dsEnemyBottomOffset) or DS_ENEMY_HEALTH_BOTTOM_OFFSET) end,
                    setFunc = function(value) VFM.SetDSEnemyGeometryValue("dsEnemyBottomOffset", -math.abs(value)) end, width = "full",
                },
                {
                    type = "slider", name = "Enemy bar width", min = 320, max = 1800, step = 10,
                    getFunc = function() return tonumber(VFM.saved.dsEnemyWidth) or DS_ENEMY_HEALTH_WIDTH end,
                    setFunc = function(value) VFM.SetDSEnemyGeometryValue("dsEnemyWidth", value) end, width = "half",
                },
                {
                    type = "slider", name = "Enemy bar height", min = 8, max = 80, step = 1,
                    getFunc = function() return tonumber(VFM.saved.dsEnemyHeight) or DS_ENEMY_HEALTH_HEIGHT end,
                    setFunc = function(value) VFM.SetDSEnemyGeometryValue("dsEnemyHeight", value) end, width = "half",
                },
            },
        },
        {
            type = "header",
            name = "Dark Souls bottom player bars",
        },
        {
            type = "description",
            text = "Build a large bottom-screen player resource stack. Health, Magicka and Stamina use the same long Dark Souls bar style. The existing top-left Dark Souls layout remains available separately.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show bottom player Health",
            tooltip = "Shows your own long Dark Souls Health bar at the bottom and automatically hides the normal ESO/FAB-moved player Health bar. This never replaces the target health frame above an enemy's head.",
            getFunc = function() return VFM.saved.dsSelfHealthBar end,
            setFunc = function(value) VFM.SetDSSelfHealthBar(value, true) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Add bottom Magicka and Stamina",
            tooltip = "Adds matching long Magicka and Stamina bars and automatically hides the normal ESO/FAB-moved Magicka and Stamina bars. The three bottom bars stack Health, Magicka, Stamina.",
            getFunc = function() return VFM.saved.dsSelfResourceBars end,
            setFunc = function(value) VFM.SetDSSelfResourceBars(value, true) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Bottom player bars only",
            tooltip = "Uses the full bottom Health, Magicka and Stamina stack as your player resource display and hides all native/top-left PLAYER attribute bars, including the Werewolf transformation bar. Mount, siege and target bars are not affected. Turning this off restores the native or top-left layout according to your Dark Souls player bars setting.",
            getFunc = function() return VFM.saved.dsBottomOnly end,
            setFunc = function(value) VFM.SetDSBottomOnly(value, true) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show bottom player bars only in combat",
            tooltip = "Hides the bottom player Health, Magicka and Stamina bars out of combat and shows them immediately when combat starts.",
            getFunc = function() return VFM.saved.dsSelfHealthCombatOnly end,
            setFunc = function(value) VFM.SetDSSelfHealthCombatOnly(value, true) end,
            disabled = function() return not VFM.saved.dsSelfHealthBar end,
            width = "full",
        },
        {
            type = "header",
            name = "Move & Edit Player Bars",
        },
        {
            type = "checkbox",
            name = "Unlock bars for editing",
            tooltip = "Shows edit outlines around the resource bars. In normal mode, drag each bar independently. In Dark Souls top-left mode, dragging any resource bar moves the complete Dark Souls stack together. Mouse wheel resizing still works. Save & Lock keeps the changes.",
            getFunc = function() return not VFM.saved.locked end,
            setFunc = function(value) VFM.SetLocked(not value, true) end,
            width = "full",
        },
        {
            type = "description",
            text = "Drag: move   |   Wheel: resize   |   Shift + Wheel: thickness   |   Ctrl + Wheel: width   |   Shift + Drag: fine movement   |   Right click: undo that bar position",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Snap to grid",
            tooltip = "Keeps the bars aligned to a consistent grid while dragging. Hold Shift while dragging to temporarily bypass the grid for fine placement.",
            getFunc = function() return VFM.saved.snapToGrid end,
            setFunc = function(value) VFM.SetSnapToGrid(value) end,
            width = "half",
        },
        {
            type = "slider",
            name = "Grid size",
            tooltip = "Smaller values allow finer placement. Larger values make alignment more rigid.",
            min = 2,
            max = 50,
            step = 1,
            getFunc = function() return VFM.saved.gridSize end,
            setFunc = function(value) VFM.SetGridSize(value) end,
            disabled = function() return not VFM.saved.snapToGrid end,
            width = "half",
        },
        {
            type = "header",
            name = "Player Bar Size",
        },
        {
            type = "slider",
            name = "Width",
            tooltip = "Changes the horizontal size of Health, Magicka and Stamina together.",
            min = 50,
            max = 500,
            step = 5,
            getFunc = function() return zo_round(VFM.saved.barWidth * 100) end,
            setFunc = function(value) VFM.SetBarWidth(value / 100, true) end,
            width = "full",
        },
        {
            type = "slider",
            name = "Thickness",
            tooltip = "Changes only the vertical thickness of Health, Magicka and Stamina.",
            min = 50,
            max = 500,
            step = 5,
            getFunc = function() return zo_round(VFM.saved.barThickness * 100) end,
            setFunc = function(value) VFM.SetBarThickness(value / 100, true) end,
            width = "full",
        },
        {
            type = "description",
            text = "Tip: when edit mode is unlocked, resize directly on the bars. Wheel changes overall size, Shift + Wheel changes thickness only, and Ctrl + Wheel changes width only.",
            width = "full",
        },
        {
            type = "submenu",
            name = "Layout presets",
            tooltip = "Optional alignment helpers. Your normal layout is edited directly by dragging the bars.",
            controls = {
                {
                    type = "button",
                    name = "Vanilla bottom HUD",
                    tooltip = "Applies Ultivite's default combat layout for the three player resource bars: centered, tightly spaced and almost touching the bottom edge. Fancy Action Bar is positioned directly above by the main Ultivite preset.",
                    func = function()
                        if Ultivite and U.ApplyDefaultCombatHUDLayout then
                            U.ApplyDefaultCombatHUDLayout(false)
                        else
                            VFM.ApplyUltiviteBottomPreset(false)
                        end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Dark Souls Self",
                    tooltip = "Large stacked Dark Souls Health, Magicka and Stamina bars for the player while keeping the action bar available.",
                    func = function()
                        if Ultivite and U.ApplyDarkSoulsSelfPreset then
                            U.ApplyDarkSoulsSelfPreset(false)
                        else
                            VFM.SetQuickPlayerLayout("bottomOnly", false)
                        end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Dark Souls",
                    tooltip = "Minimal Dark Souls preset: Health, Magicka and Stamina at top left with Ultimate centered to their left, one wide thin enemy Health bar at the bottom, and no action bar or extra Ultivite combat HUD.",
                    warning = "This preset changes the current profile's visibility toggles. Save or Sync from the top of the Ultivite menu after you are happy with it.",
                    func = function()
                        if Ultivite and U.ApplyFullDarkSoulsPreset then
                            U.ApplyFullDarkSoulsPreset(false)
                        end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Dark Souls + Action Bar",
                    tooltip = "Same top-left Dark Souls player layout, but keeps Fancy Action Bar and places one centered wide thin enemy Health bar directly above it.",
                    warning = "If Fancy Action Bar was disabled when this UI session started, apply the preset then use Reload UI now once.",
                    func = function()
                        if Ultivite and U.ApplyDarkSoulsActionBarPreset then
                            U.ApplyDarkSoulsActionBarPreset(false)
                        end
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Dark Souls + Action Bar long Health bar",
                    tooltip = "Switch the long bar above Fancy Action Bar between the current enemy target and your own Health.",
                    choices = { "Enemy target", "Self Health" },
                    choicesValues = { "enemy", "self" },
                    getFunc = function() return Ultivite and U.GetDarkSoulsActionBarHealthSource and U.GetDarkSoulsActionBarHealthSource() or "enemy" end,
                    setFunc = function(value)
                        if Ultivite and U.SetDarkSoulsActionBarHealthSource then
                            U.SetDarkSoulsActionBarHealthSource(value, false)
                        end
                    end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Hide default overhead Health bars",
                    tooltip = "Hides ESO's normal engine-rendered Health bars above characters while keeping Ultivite's Dark Souls long Health bar available. Dark Souls and Dark Souls + Action Bar enable this automatically. Turning it off restores your previous ESO nameplate Health bar settings.",
                    getFunc = function()
                        return Combat and Combat.GetHideNativeOverheadHealthBars and Combat.GetHideNativeOverheadHealthBars() or false
                    end,
                    setFunc = function(value)
                        if Combat and Combat.SetHideNativeOverheadHealthBars then
                            Combat.SetHideNativeOverheadHealthBars(value, false)
                        end
                    end,
                    default = false,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Compact bottom layout",
                    tooltip = "Places Magicka on the left, Health in the middle and Stamina on the right near the bottom of the screen using the gap and bottom-margin values below.",
                    func = function() VFM.ApplyBottomCompactLayout(false) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Gap between bars",
                    tooltip = "Spacing used the next time Compact bottom layout is applied.",
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function() return VFM.saved.compactGap end,
                    setFunc = function(value) VFM.SetCompactGap(value) end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Bottom margin",
                    tooltip = "Distance from the bottom edge used the next time Compact bottom layout is applied.",
                    min = 0,
                    max = 150,
                    step = 1,
                    getFunc = function() return VFM.saved.bottomMargin end,
                    setFunc = function(value) VFM.SetBottomMargin(value) end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Align side bars to Health",
                    tooltip = "Matches Magicka and Stamina to Health's vertical position without changing their horizontal positions.",
                    func = function() VFM.AlignAllToHealthY() end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Dark Souls preset positioning",
            tooltip = "Fine tune the saved Dark Souls top-left and bottom presets. These values are profile-backed and can be printed to chat for creating a new addon default.",
            controls = {
                {
                    type = "description",
                    text = "Unlock bars for editing to drag the complete Dark Souls top-left resource stack. The controls below provide exact values for repeatable placement.",
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Top-left X",
                    min = -400,
                    max = 2400,
                    step = 1,
                    getFunc = function() return tonumber(VFM.saved.darkSoulsLeft) or DARKSOULS_LEFT end,
                    setFunc = function(value) VFM.SetDarkSoulsTopLeftX(value) end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Top-left Y",
                    min = 0,
                    max = 1600,
                    step = 1,
                    getFunc = function() return tonumber(VFM.saved.darkSoulsTop) or DARKSOULS_TOP end,
                    setFunc = function(value) VFM.SetDarkSoulsTopLeftY(value) end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Top-left bar gap",
                    min = 0,
                    max = 60,
                    step = 1,
                    getFunc = function() return tonumber(VFM.saved.darkSoulsGap) or DARKSOULS_BAR_GAP end,
                    setFunc = function(value) VFM.SetDarkSoulsTopLeftGap(value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Bottom bars horizontal offset",
                    tooltip = "0 is centered.",
                    min = -1200,
                    max = 1200,
                    step = 1,
                    getFunc = function() return tonumber(VFM.saved.dsBottomX) or 0 end,
                    setFunc = function(value) VFM.SetDarkSoulsBottomX(value) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Bottom bars distance above bottom",
                    min = 0,
                    max = 500,
                    step = 1,
                    getFunc = function() return math.abs(tonumber(VFM.saved.dsBottomOffset) or DS_SELF_HEALTH_BOTTOM_OFFSET) end,
                    setFunc = function(value) VFM.SetDarkSoulsBottomDistance(value) end,
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Bottom bars gap",
                    min = 0,
                    max = 80,
                    step = 1,
                    getFunc = function() return tonumber(VFM.saved.dsBottomGap) or DS_SELF_RESOURCE_GAP end,
                    setFunc = function(value) VFM.SetDarkSoulsBottomGap(value) end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Print Positions",
                    tooltip = "Prints the exact normal and Dark Souls positioning values to chat so you can copy them back for a future default preset.",
                    func = function()
                        if Ultivite and U.PrintLayoutPositioning then
                            U.PrintLayoutPositioning()
                        else
                            VFM.PrintLayoutPositioning()
                        end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Show Layout Report",
                    tooltip = "Opens the complete current layout in one selectable text box. Press Ctrl+C to copy it for troubleshooting or support.",
                    func = function()
                        if Ultivite and U.ShowLayoutReport then
                            U.ShowLayoutReport()
                        end
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Player Bar Text",
            controls = {
                {
                    type = "dropdown",
                    name = "Number format",
                    choices = TEXT_MODE_NAMES,
                    choicesValues = TEXT_MODE_VALUES,
                    getFunc = function() return VFM.saved.textMode end,
                    setFunc = function(value)
                        VFM.saved.textMode = value
                        VFM.ApplyTextStyle()
                        VFM.RequestSettingsSave()
                    end,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Font",
                    choices = FONT_NAMES,
                    choicesValues = FONT_VALUES,
                    getFunc = function() return VFM.saved.font end,
                    setFunc = function(value)
                        VFM.saved.font = value
                        VFM.ApplyTextStyle()
                        VFM.RequestSettingsSave()
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Text size",
                    min = 50,
                    max = 200,
                    step = 5,
                    getFunc = function() return zo_round(VFM.saved.textScale * 100) end,
                    setFunc = function(value)
                        VFM.saved.textScale = Clamp(value / 100, 0.50, 2.00)
                        VFM.ApplyTextStyle()
                        VFM.RequestSettingsSave()
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Player UI Reset & Diagnostics",
            tooltip = "Reset individual parts of the addon or print sizing information for troubleshooting.",
            controls = {
                {
                    type = "button",
                    name = "Print sizing diagnostics",
                    tooltip = "Prints the requested and actual native bar dimensions to chat. This does not change anything.",
                    func = function() VFM.PrintGeometryDebug() end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Print runtime / conflict status",
                    tooltip = "Prints startup readiness, LUI Extended compatibility state, layout drift and slash-command ownership.",
                    func = function() VFM.PrintConflictStatus() end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Force saved layout now",
                    tooltip = "Immediately reapplies the saved positions, width and thickness to the native player bars.",
                    func = function()
                        if VFM.ApplySavedLayoutDirect("menu force", true) then
                            VFM.PrepareRuntime(false)
                            if VFM.runtimeReady then
                                VFM.ApplyAll()
                            end
                            Print("Saved layout forced onto native player bars")
                        else
                            Print("Primary bars are not available yet; guardian will retry")
                            VFM.ScheduleApply(0)
                        end
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset positions",
                    func = function() VFM.ResetPositions() end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset bar size",
                    func = function() VFM.ResetSize() end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset resource text",
                    func = function() VFM.ResetText() end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset everything",
                    tooltip = "Restores default positions, size, grid, visibility and resource text settings.",
                    warning = "This resets all Ultivite frame settings.",
                    func = function() VFM.ResetAll() end,
                    width = "full",
                },
            },
        },
    }

    return optionsData
end

function VFM.RegisterSettings()
    -- Ultivite owns the consolidated settings panel.
end

function VFM.HandleSlashCommand(rawText)
    local text = string.lower(Trim(rawText))

    if text == "" then
        VFM.SetLocked(not VFM.saved.locked)
        return
    elseif text == "unlock" then
        VFM.SetLocked(false)
        return
    elseif text == "lock" or text == "save" then
        VFM.SetLocked(true)
        return
    elseif text == "undo" then
        VFM.UndoEditSession()
        return
    elseif text == "cancel" or text == "exit" then
        VFM.CancelEditSession()
        return
    elseif text == "align" then
        VFM.AlignAllToHealthY()
        return
    elseif text == "bottom" or text == "compact" then
        VFM.ApplyBottomCompactLayout(false)
        return
    elseif text == "reset" then
        VFM.ResetAll()
        return
    elseif text == "debug" then
        VFM.PrintGeometryDebug()
        return
    elseif text == "conflict" or text == "status" then
        VFM.PrintConflictStatus()
        return
    elseif text == "visibilitydiag" or text == "uidiag" then
        VFM.PrintUiVisibilityDiagnostic()
        return
    elseif text == "force" or text == "apply" then
        if VFM.ApplySavedLayoutDirect("slash force", true) then
            VFM.PrepareRuntime(false)
            if VFM.runtimeReady then
                VFM.ApplyAll()
            end
            Print("Saved layout forced onto native player bars")
        else
            Print("Primary bars are not available yet; guardian will retry")
            VFM.ScheduleApply(0)
        end
        return
    elseif text == "menu" then
        if LibAddonMenu2 and VFM.optionsPanel and LibAddonMenu2.OpenToPanel then
            LibAddonMenu2:OpenToPanel(VFM.optionsPanel)
        end
        return
    elseif text == "snap on" then
        VFM.SetSnapToGrid(true)
        Print("Grid snapping enabled")
        return
    elseif text == "snap off" then
        VFM.SetSnapToGrid(false)
        Print("Grid snapping disabled")
        return
    end

    if text == "account" or text == "accountwide" then
        VFM.SetAccountWideSettings(true)
        return
    elseif text == "character" or text == "percharacter" then
        VFM.SetAccountWideSettings(false)
        return
    end

    if text == "darksouls on" then
        VFM.SetDarkSoulsMode(true)
        return
    elseif text == "darksouls off" then
        VFM.SetDarkSoulsMode(false)
        return
    elseif text == "darksouls" then
        VFM.SetDarkSoulsMode(not VFM.saved.darkSoulsMode)
        return
    end

    if text == "actionbar hide" or text == "actionbar off" then
        VFM.SetHideActionBar(true)
        return
    elseif text == "actionbar show" or text == "actionbar on" then
        VFM.SetHideActionBar(false)
        return
    elseif text == "actionbar" then
        VFM.SetHideActionBar(not VFM.saved.hideActionBar)
        return
    end

    if text == "combat on" then
        VFM.SetCombatOnly(true)
        return
    elseif text == "combat off" then
        VFM.SetCombatOnly(false)
        return
    elseif text == "combat" then
        VFM.SetCombatOnly(not VFM.saved.combatOnly)
        return
    end

    local centerKey = text:match("^center%s+(%a+)$")
    if centerKey and BAR_INFO[centerKey] then
        VFM.CenterBarHorizontally(centerKey)
        return
    end

    local gridText = text:match("^grid%s+(%d+)$")
    if gridText then
        VFM.SetGridSize(tonumber(gridText))
        Print(string.format("Grid size set to %d", VFM.saved.gridSize))
        return
    end

    local gapText = text:match("^gap%s+(%d+)$")
    if gapText then
        VFM.SetCompactGap(tonumber(gapText))
        Print(string.format("Bottom layout gap set to %d", VFM.saved.compactGap))
        return
    end

    local marginText = text:match("^margin%s+(%d+)$")
    if marginText then
        VFM.SetBottomMargin(tonumber(marginText))
        Print(string.format("Bottom margin set to %d", VFM.saved.bottomMargin))
        return
    end

    local widthText = text:match("^width%s+(%d+%.?%d*)$")
    if widthText then
        VFM.SetBarWidth(tonumber(widthText) / 100)
        return
    end

    local thicknessText = text:match("^thickness%s+(%d+%.?%d*)$")
    if thicknessText then
        VFM.SetBarThickness(tonumber(thicknessText) / 100)
        return
    end

    local sizeText = text:match("^size%s+(%d+%.?%d*)$")
    if sizeText then
        VFM.SetOverallSize(tonumber(sizeText) / 100)
        return
    end

    Print("Commands: /vfm | menu | unlock | save | undo | cancel | account | character | darksouls on/off | actionbar hide/show | combat on/off | bottom | grid 10 | snap on/off | align | reset | debug | conflict | status | force | apply | width 150 | thickness 150 | size 150")
end

function VFM.EnsureSlashCommandOwnership()
    if not SLASH_COMMANDS then
        return false
    end

    if not VFM.slashHandler then
        VFM.slashHandler = function(rawText)
            VFM.HandleSlashCommand(rawText)
        end
    end

    if not VFM.slashStatusHandler then
        VFM.slashStatusHandler = function() VFM.PrintConflictStatus() end
    end
    if not VFM.slashForceHandler then
        VFM.slashForceHandler = function() VFM.HandleSlashCommand("force") end
    end

    if SLASH_COMMANDS["/vfm"] ~= VFM.slashHandler then
        SLASH_COMMANDS["/vfm"] = VFM.slashHandler
    end

    -- Dedicated aliases remain useful even if another addon deliberately claims
    -- /vfm in the future. They do not open LibAddonMenu.
    if SLASH_COMMANDS["/vfmstatus"] ~= VFM.slashStatusHandler then
        SLASH_COMMANDS["/vfmstatus"] = VFM.slashStatusHandler
    end
    if SLASH_COMMANDS["/vfmforce"] ~= VFM.slashForceHandler then
        SLASH_COMMANDS["/vfmforce"] = VFM.slashForceHandler
    end
    return true
end

function VFM.RegisterSlashCommands()
    VFM.EnsureSlashCommandOwnership()
end

function VFM.Initialize(externalSaved)
    if VFM.initialized then
        return
    end

    if externalSaved then
        VFM.saved = externalSaved
        VFM.accountSaved = externalSaved
        VFM.characterSaved = externalSaved
        VFM.accountSaved.useAccountWide = VFM.IsUsingAccountWideSettings()
    else
        VFM.accountSaved = ZO_SavedVars:NewAccountWide(
            SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, defaults, GetWorldName()
        )
        VFM.characterSaved = ZO_SavedVars:NewCharacterIdSettings(
            CHARACTER_SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, defaults, GetWorldName()
        )
        if VFM.accountSaved.useAccountWide == nil then
            VFM.accountSaved.useAccountWide = true
        end
        VFM.saved = VFM.IsUsingAccountWideSettings() and VFM.accountSaved or VFM.characterSaved
    end

    -- 1.0.92 adds profile-backed quick-menu visibility modes. Existing profiles
    -- get only missing keys, preserving all prior choices and positions.
    if VFM.saved.groupFrameVisibilityMode == nil then
        VFM.saved.groupFrameVisibilityMode = VFM.saved.hideGroupFrame == true and "hide" or "show"
    end
    -- CP is a permanent part of Ultivite group-frame presentation. Migrate any
    -- older profile that stored this as false back to ON.
    VFM.saved.showGroupFrameChampionPoints = true
    if VFM.saved.chatVisibilityMode == nil then
        VFM.saved.chatVisibilityMode = VFM.saved.autoHideChat == true and "hide" or "show"
    end
    if VFM.saved.feetCompassVisibilityMode == nil then VFM.saved.feetCompassVisibilityMode = "show" end
    if VFM.saved.crownDirectionArrowVisibilityMode == nil then VFM.saved.crownDirectionArrowVisibilityMode = "show" end

    -- 1.0.65 retires the center-screen teammate CP label. Preserve the legacy
    -- key for SavedVariables compatibility, but force it off so exports also
    -- reflect that the old presentation no longer exists.
    VFM.saved.showTeammateCpReticle = false

    VFM.accountSaved.persistenceLoadCount = (tonumber(VFM.accountSaved.persistenceLoadCount) or 0) + 1
    VFM.RequestSettingsSave()

    if IsUnitInCombat then
        VFM.inCombat = IsUnitInCombat("player") and true or false
    end

    -- Ultivite owns the single consolidated LibAddonMenu panel.
    VFM.RegisterSlashCommands()
    VFM.InstallLuiCompatibilityHook()
    VFM.InstallChampionProgressHook()
    VFM.InstallGroupFrameChampionPointHook()
    VFM.ApplyChampionProgressVisibility(true)
    VFM.StartLayoutGuardian()
    VFM.ApplyGroupFrameState()
    VFM.ApplyGroupFrameChampionPoints()
    VFM.ApplyWerewolfResourceBarVisibility()
    VFM.ApplyMountStaminaBarVisibility()
    VFM.UpdateDSUltimateControl()
    VFM.RefreshDSEnemyHealthRuntime()
    VFM.RefreshDSSelfHealthRuntime()
    VFM.RefreshUiVisibilityRules()
    VFM.RefreshNavigationHelpers(true)

    if EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CameraUiMode", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            -- Returning from interaction/full UI scenes can make ESO refresh the
            -- native player bars. Reconcile Combat Only as part of that transition.
            VFM.UpdateCombatVisibility()
            VFM.UpdateDSUltimateControl()
            VFM.UpdateDSEnemyHealthBar()
            VFM.UpdateDSSelfHealthBar()
            VFM.UpdateDSSelfResourceBars()
            VFM.ApplyMountStaminaBarVisibility()
            VFM.RefreshNavigationHelpers(true)
        end)
    end

    -- Reassert once after the rest of the UI has had a chance to register panel
    -- shortcuts. The guardian continues to protect /vfm afterwards.
    zo_callLater(function() VFM.EnsureSlashCommandOwnership() end, 1000)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, function()
        VFM.OnPlayerActivated()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function(eventCode, inCombat)
        VFM.OnCombatStateChanged(eventCode, inCombat)
    end)

    if EVENT_WEREWOLF_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WerewolfState", EVENT_WEREWOLF_STATE_CHANGED, function()
            zo_callLater(function()
                            VFM.ApplyWerewolfResourceBarVisibility()
            end, 0)
        end)
    end

    if EVENT_MOUNTED_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "MountState", EVENT_MOUNTED_STATE_CHANGED, function()
            -- ZOS refreshes MountStamina on this event. Reassert our dedicated
            -- suppression immediately after the native handler runs.
            zo_callLater(function()
                VFM.ApplyMountStaminaBarVisibility()
            end, 0)
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "GamepadMode", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
        VFM.OnPlatformStyleChanged()
    end)

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ScreenResize", EVENT_SCREEN_RESIZED, function()
        zo_callLater(function()
            VFM.ApplyPositions()
            VFM.UpdateAllMoverSizes()
            VFM.UpdateAllMoverLabels()
            VFM.ApplyCrownDirectionArrowLayout()
            VFM.ApplyFeetCompassLayout()
        end, 100)
    end)

    local visualEvents = {
        { EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, "VisualAdded" },
        { EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, "VisualUpdated" },
        { EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, "VisualRemoved" },
    }

    for _, eventData in ipairs(visualEvents) do
        local eventId = eventData[1]
        local suffix = eventData[2]
        if eventId then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. suffix, eventId, function()
                zo_callLater(function()
                    if VFM.runtimeReady then
                        VFM.ApplyAll()
                    else
                        VFM.ScheduleApply(0)
                    end
                end, 0)
            end)
        end
    end

    VFM.initialized = true

    -- Critical reload path: enforce the saved native layout from addon startup
    -- without waiting for EVENT_PLAYER_ACTIVATED or optional runtime metadata.
    VFM.ScheduleApply(0)
end

