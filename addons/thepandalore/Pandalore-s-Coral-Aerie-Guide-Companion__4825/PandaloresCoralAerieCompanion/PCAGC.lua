-- Pandalore's Coral Aerie Guide Companion
-- Author: thepandalore
--
-- Purpose:
--   Coral Aerie encounter companion for Maligalig, Sarydil, and Varallion.
--   Boss-specific mechanics share one zone runtime, notification surface,
--   attached-icon renderer, and account-wide settings profile.
--
-- Runtime dependencies:
--   CrutchAlerts      - attached-player arrow renderer (Space API path)
--   LibUnits2         - combat unit ID -> group unit tag / @displayName resolution
--   LibAddonMenu-2.0  - in-game settings panel
--   LibDebugLogger     - optional structured diagnostics
--
-- No encounter telemetry is persisted. SavedVariables contain presentation
-- settings and UI position only.

local ADDON_NAME = "PandaloresCoralAerieCompanion"
local DISPLAY_NAME = "Pandalore's Coral Aerie Guide Companion"
local VERSION = "1.0.2"
local LAM_PANEL_ID = "PCAGCOptions"
local EVENT_NAMESPACE = "PCAGC"
local UI_NAMESPACE = "PCAGC"

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

local PCAGC = {
    inCombat = false,
    runtimeLoaded = false,
    combatStartMs = nil,
    encounterActive = false,
    varallionSeen = false,
    currentBossKey = "",
    updateRegistered = false,
    unlocked = false,
    previewMode = "OFF",


    nextMarkDeadlineMs = nil,
    markNowUntilMs = nil,
    lastAcceptedMarkMs = nil,

    targetA = nil,
    targetB = nil,

    beamAActive = false,
    beamBActive = false,
    beamCycleSeen = false,
    beamCycleAnchored = false,
    tetherDeadlineMs = nil,

    arrows = {},

    -- Experimental movement-ranking predictor. The first selection window can
    -- begin sampling only after locale-neutral Varallion context is observed;
    -- the first forecast itself remains anchored to the true combat edge. Later
    -- windows run from final Mind Link tether fade to the next 149224 BEGIN.
    -- Distances are accumulated from successive
    -- GetUnitRawWorldPosition samples and are never persisted.
    pathTrackingActive = false,
    pathSamples = {},
    predictionArrows = {},

    -- Maligalig Building Static is local-player effect state. The native
    -- EVENT_EFFECT_CHANGED stackCount is authoritative for the displayed count.
    staticStacks = 0,

    -- Sarydil state is tracked for the whole group but rendered only on the
    -- local healer UI. Purge targets retain per-ability membership so one fade
    -- cannot clear a target that still has the other purgeable effect.
    purgeTargets = {},
    pinpointEffects = {},
    pinpointSequence = 0,
    pinpointTarget = nil,
    sarydilPurgeArrows = {},
    sarydilPinpointArrow = nil,

    -- Varallion world markers use fixed safe-zone coordinates only.
    safeZoneMarkerKeys = {},

    -- Ephemeral runtime diagnostics. Nothing here is written to SavedVariables.
    lastTrackedEvent = "none",

    -- Optional LibDebugLogger state. The per-addon debug override is deliberately
    -- session-only and is never persisted in PandaloresCoralAerieGuideCompanionSaved.
    logger = nil,
    hasDebugLogger = false,

    -- Hard dependency contracts are validated once during initialization.
    -- Optional LibDebugLogger remains the only capability that may be absent.
}

-- One addon-owned global exposes the common core to the optional DEV overlay.
-- RELEASE and DEV load this exact same PCAGC.lua byte-for-byte.
_G.PandaloresCoralAerieGuideCompanion = PCAGC

---------------------------------------------------------------------
-- FIXED MECHANIC CONFIGURATION
---------------------------------------------------------------------
-- Encounter timing is deliberately not user-adjustable. These values are
-- maintainer-confirmed encounter anchors and are tested as fixed invariants.
local CONFIG = {
    FIRST_MARK_SECONDS = 36,       -- confirmed encounter timing: combat start + 36 seconds
    FIRST_VISIBLE_SECONDS = 20,    -- first countdown appears for its final 20 seconds
    NEXT_MARK_SECONDS = 17,        -- confirmed encounter timing: final beam fade + 17 seconds
    MARK_NOW_MS = 1000,            -- "Mark of the Sea: Now" lifetime
    TETHER_SECONDS = 25,           -- stateful 167437 / 167462 beam window
    UPDATE_INTERVAL_MS = 100,
    MARK_DEBOUNCE_MS = 5000,     -- debounce duplicate 149224 ACTION_RESULT_BEGIN events


    DEFAULT_TOP_OFFSET = 210,
    MIN_FRAME_HEIGHT = 120,
    FONT_FACE = "$(BOLD_FONT)",
    FONT_STYLE = "soft-shadow-thick",
    LINE_GAP = 2,

    -- CrutchAlerts owns both the renderer and this texture.
    ARROW_TEXTURE = "CrutchAlerts/assets/shape/chevron.dds",
    ARROW_PRIORITY = 520,          -- just above CrutchAlerts mechanic priorities 500/510
    PREDICTION_ARROW_PRIORITY = 519, -- below real Mind Link arrows; normally removed before they appear
    SARYDIL_PURGE_ARROW_PRIORITY = 518,
    SARYDIL_PINPOINT_ARROW_PRIORITY = 521,
    ARROW_SIZE = 100,              -- legacy arg; Space options control rendered scale
}

---------------------------------------------------------------------
-- ACCOUNT-WIDE PRESENTATION DEFAULTS
---------------------------------------------------------------------
local DEFAULTS = {
    offsetX = nil,
    offsetY = nil,

    widthPercent = 25,
    justification = "CENTER",
    markFontSize = 32,
    linkHeaderFontSize = 34,
    linkNamesFontSize = 27,

    markColor = {r = 0.10, g = 0.90, b = 0.85, a = 1.00},
    linkColor = {r = 1.00, g = 0.10, b = 0.75, a = 1.00},

    arrowsEnabled = true,
    arrowSpaceSize = 0.85,
    arrowColor = {r = 1.00, g = 0.10, b = 0.75, a = 1.00},

    -- Experimental path predictor is a separate opt-in feature. It is off by
    -- default so authoritative mechanic indicators never imply a prediction.
    predictorEnabled = false,
    predictorArrowSpaceSize = 0.85,
    predictorArrowColor = {r = 0.60, g = 0.15, b = 1.00, a = 1.00},

    maligaligLeaveStacks = 6,

    sarydilPurgeArrowSpaceSize = 0.65,
    sarydilPurgeArrowColor = {r = 1.00, g = 0.82, b = 0.00, a = 1.00},
    sarydilPinpointArrowSpaceSize = 0.65,
    sarydilPinpointArrowColor = {r = 1.00, g = 0.12, b = 0.08, a = 1.00},
    sarydilHumorEnabled = true,

    varallionSafeZonesEnabled = true,
    varallionSafeZoneRadius = 1.00,
    varallionSafeZoneColor = {r = 0.20, g = 1.00, b = 0.45, a = 0.90},

    schemaVersion = 1,
}

local ALIGNMENT_VALUES = {
    LEFT = TEXT_ALIGN_LEFT,
    CENTER = TEXT_ALIGN_CENTER,
    RIGHT = TEXT_ALIGN_RIGHT,
}

---------------------------------------------------------------------
-- ENCOUNTER CONSTANTS
---------------------------------------------------------------------
local CORAL_AERIE_ZONE_ID = 1301

-- Internal encounter-state keys only. They are never compared with localized
-- boss/unit names, so mechanic activation does not depend on client language.
local MALIGALIG_KEY = "maligalig"
local SARYDIL_KEY = "sarydil"
local VARALLION_KEY = "varallion"

local IDS = {
    -- Maligalig
    BUILDING_STATIC = 162279,

    -- Sarydil
    PINPOINT_A = 167569,
    PINPOINT_B = 158201,
    PURGE_IGNITE = 168776,
    PURGE_APERTURE = 168897,

    -- Varallion. 158553 and 158778 are early, locale-neutral combat signals
    -- observed from Varallion across all three pulls in the supplied capture.
    -- They identify encounter context only; timing remains anchored to the
    -- player combat edge and authoritative Mark behavior remains 149224.
    VARALLION_SIGNAL_SLICE = 158553,
    VARALLION_SIGNAL_OBLITERATE = 158778,
    MARK_CAST = 149224,
    LINK_A = 149225,
    LINK_B = 149227,
    BEAM_A = 167437,
    BEAM_B = 167462,

}


-- These four fixed positions are inherited from prior Coral Aerie Helper-derived
-- development. Their in-client positional accuracy remains a live acceptance item.
-- Coordinates are ESO raw-world coordinates used by CrutchAlerts Drawing.
local VARALLION_SAFE_ZONES = {
    {x = 60764, y = 29601, z = 133431},
    {x = 58962, y = 29601, z = 133212},
    {x = 58967, y = 29601, z = 131423},
    {x = 60751, y = 29601, z = 131528},
}


local ICON_NAME_A = ADDON_NAME .. "_MindLinkA"
local ICON_NAME_B = ADDON_NAME .. "_MindLinkB"
local PREDICTION_ICON_NAME_A = ADDON_NAME .. "_PathPredictionA"
local PREDICTION_ICON_NAME_B = ADDON_NAME .. "_PathPredictionB"
local SARYDIL_PURGE_ICON_NAME = ADDON_NAME .. "_SarydilPurge"
local SARYDIL_PINPOINT_ICON_NAME = ADDON_NAME .. "_SarydilPinpoint"

local function IsSarydilAbility(abilityId)
    return abilityId == IDS.PINPOINT_A
        or abilityId == IDS.PINPOINT_B
        or abilityId == IDS.PURGE_IGNITE
        or abilityId == IDS.PURGE_APERTURE
end


---------------------------------------------------------------------
-- SMALL HELPERS
---------------------------------------------------------------------
local function RequireFunction(owner, methodName, ownerName)
    assert(type(owner) == "table", string.format("%s dependency table is unavailable", ownerName))
    assert(type(owner[methodName]) == "function", string.format("%s.%s is unavailable", ownerName, methodName))
end

function PCAGC:ValidateDependencyContracts()
    RequireFunction(LibUnits2, "GetDisplayNameForUnitId", "LibUnits2")
    RequireFunction(LibUnits2, "GetUnitTagForUnitId", "LibUnits2")

    RequireFunction(CrutchAlerts, "SetAttachedIconForUnit", "CrutchAlerts")
    RequireFunction(CrutchAlerts, "RemoveAttachedIconForUnit", "CrutchAlerts")
    RequireFunction(CrutchAlerts, "RemoveAllAttachedIcons", "CrutchAlerts")
    assert(type(CrutchAlerts.Drawing) == "table", "CrutchAlerts.Drawing is unavailable")
    RequireFunction(CrutchAlerts.Drawing, "CreateGroundCircle", "CrutchAlerts.Drawing")
    RequireFunction(CrutchAlerts.Drawing, "RemoveWorldTexture", "CrutchAlerts.Drawing")

    RequireFunction(LibAddonMenu2, "RegisterAddonPanel", "LibAddonMenu2")
    RequireFunction(LibAddonMenu2, "RegisterOptionControls", "LibAddonMenu2")
end

-- LibDebugLogger is optional; logging degrades to no-ops when unavailable.
local function LoggerCall(methodName, ...)
    local logger = PCAGC.logger
    if not logger then return false end
    local method = logger[methodName]
    if type(method) ~= "function" then return false end
    method(logger, ...)
    return true
end

function PCAGC:LogDebug(...)
    LoggerCall("Debug", ...)
end

function PCAGC:LogInfo(...)
    LoggerCall("Info", ...)
end

function PCAGC:LogWarn(...)
    LoggerCall("Warn", ...)
end

function PCAGC:LogError(...)
    LoggerCall("Error", ...)
end

function PCAGC:InitializeLogger()
    if type(LibDebugLogger) ~= "table" or type(LibDebugLogger.Create) ~= "function" then
        self.hasDebugLogger = false
        return
    end

    -- LibDebugLogger is optional, but when present its documented Create API is
    -- called directly. Programming errors are not hidden behind a blanket pcall.
    self.logger = LibDebugLogger:Create(ADDON_NAME)
    self.hasDebugLogger = self.logger ~= nil
end

local function IsEffectPresent(changeType)
    return changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED
end

local function NormalizedName(name)
    return zo_strformat("<<1>>", name or "")
end

local function CurrentWorldZoneId()
    -- Coral Aerie Helper uses this world-zone ID path for dungeon detection.
    local zoneId = select(1, GetUnitWorldPosition("player"))
    return zoneId or 0
end


local function MakeFont(size)
    return string.format("%s|%d|%s", CONFIG.FONT_FACE, size, CONFIG.FONT_STYLE)
end

local function SetLabelColor(label, color)
    -- Live mechanic text is always fully opaque. Color remains user-adjustable,
    -- but an inherited/saved alpha of zero must never make an alert disappear.
    label:SetColor(color.r, color.g, color.b, 1)
end

local function ForceNotificationDrawPriority(control, level)
    -- Keep companion notification text above other combat-alert surfaces. Event
    -- registration order does not affect delivery; this only hardens z-order.
    control:SetDrawTier(DT_HIGH)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawLevel(level or 1000)
end

local function ColorAsArray(color)
    return {color.r, color.g, color.b, color.a or 1}
end

local function ColorDefault(color)
    return {r = color.r, g = color.g, b = color.b, a = 1}
end

local function SecondsCeil(ms)
    if not ms then return 0 end
    return math.max(0, math.ceil(ms / 1000))
end

---------------------------------------------------------------------
-- UI
---------------------------------------------------------------------
function PCAGC:CreateUI()
    local window = WM:CreateTopLevelWindow(UI_NAMESPACE .. "Window")
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    ForceNotificationDrawPriority(window, 1000)
    window:SetAlpha(1)
    -- The transparent parent stays visible; only child labels toggle.
    window:SetHidden(false)

    local mark = WM:CreateControl(nil, window, CT_LABEL)
    mark:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    mark:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    mark:SetMouseEnabled(false)
    ForceNotificationDrawPriority(mark, 1010)
    mark:SetHidden(true)

    local linkHeader = WM:CreateControl(nil, window, CT_LABEL)
    linkHeader:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    linkHeader:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    linkHeader:SetMouseEnabled(false)
    ForceNotificationDrawPriority(linkHeader, 1020)
    linkHeader:SetHidden(true)

    local linkNames = WM:CreateControl(nil, window, CT_LABEL)
    linkNames:SetAnchor(TOP, linkHeader, BOTTOM, 0, CONFIG.LINE_GAP)
    linkNames:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    linkNames:SetMouseEnabled(false)
    ForceNotificationDrawPriority(linkNames, 1030)
    linkNames:SetHidden(true)

    local bossAlert = WM:CreateControl(nil, window, CT_LABEL)
    bossAlert:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    bossAlert:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    bossAlert:SetMouseEnabled(false)
    ForceNotificationDrawPriority(bossAlert, 1040)
    bossAlert:SetHidden(true)

    local bossDetail = WM:CreateControl(nil, window, CT_LABEL)
    bossDetail:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    bossDetail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    bossDetail:SetMouseEnabled(false)
    ForceNotificationDrawPriority(bossDetail, 1050)
    bossDetail:SetHidden(true)

    local bossAside = WM:CreateControl(nil, window, CT_LABEL)
    bossAside:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    bossAside:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    bossAside:SetMouseEnabled(false)
    ForceNotificationDrawPriority(bossAside, 1060)
    bossAside:SetHidden(true)

    -- ESO handles dragging automatically when a top-level control is both
    -- mouse-enabled and movable. Keep only the move-stop handler so there is
    -- no custom mouse logic competing with the native drag behavior.
    window:SetHandler("OnMoveStop", function()
        if PCAGC.unlocked then
            PCAGC:SavePosition()
        end
    end)

    self.ui = {
        window = window,
        mark = mark,
        linkHeader = linkHeader,
        linkNames = linkNames,
        bossAlert = bossAlert,
        bossDetail = bossDetail,
        bossAside = bossAside,
    }

    self:ApplyPresentation()
    self:RestorePosition()
end
function PCAGC:ApplyPresentation()
    if not self.ui or not self.saved then return end

    local rootWidth = tonumber(GuiRoot:GetWidth())
    if not rootWidth or rootWidth <= 0 then rootWidth = 1920 end
    local frameWidth = math.floor(rootWidth * (self.saved.widthPercent / 100))
    local markHeight = self.saved.markFontSize + 16
    local headerHeight = self.saved.linkHeaderFontSize + 16
    local namesHeight = self.saved.linkNamesFontSize + 16
    local asideFontSize = math.max(16, self.saved.linkNamesFontSize - 7)
    local asideHeight = asideFontSize + 12
    local frameHeight = math.max(
        CONFIG.MIN_FRAME_HEIGHT,
        markHeight,
        headerHeight + CONFIG.LINE_GAP + namesHeight,
        (headerHeight * 2) + (CONFIG.LINE_GAP * 2) + asideHeight
    )
    local justification = ALIGNMENT_VALUES[self.saved.justification] or TEXT_ALIGN_CENTER

    self.ui.window:SetDimensions(frameWidth, frameHeight)

    self.ui.mark:SetDimensions(frameWidth, markHeight)
    self.ui.mark:SetFont(MakeFont(self.saved.markFontSize))
    self.ui.mark:SetHorizontalAlignment(justification)
    SetLabelColor(self.ui.mark, self.saved.markColor)

    self.ui.linkHeader:SetDimensions(frameWidth, headerHeight)
    self.ui.linkHeader:SetFont(MakeFont(self.saved.linkHeaderFontSize))
    self.ui.linkHeader:SetHorizontalAlignment(justification)
    SetLabelColor(self.ui.linkHeader, self.saved.linkColor)

    self.ui.linkNames:SetDimensions(frameWidth, namesHeight)
    self.ui.linkNames:SetFont(MakeFont(self.saved.linkNamesFontSize))
    self.ui.linkNames:SetHorizontalAlignment(justification)
    SetLabelColor(self.ui.linkNames, self.saved.linkColor)

    self.ui.bossAlert:SetDimensions(frameWidth, headerHeight)
    self.ui.bossAlert:SetFont(MakeFont(self.saved.linkHeaderFontSize))
    self.ui.bossAlert:SetHorizontalAlignment(justification)

    self.ui.bossDetail:SetDimensions(frameWidth, headerHeight)
    self.ui.bossDetail:SetFont(MakeFont(self.saved.linkHeaderFontSize))
    self.ui.bossDetail:SetHorizontalAlignment(justification)

    self.ui.bossAside:SetDimensions(frameWidth, asideHeight)
    self.ui.bossAside:SetFont(MakeFont(asideFontSize))
    self.ui.bossAside:SetHorizontalAlignment(justification)
end

function PCAGC:RestorePosition()
    if not self.ui then return end

    self.ui.window:ClearAnchors()
    if self.saved.offsetX ~= nil and self.saved.offsetY ~= nil then
        self.ui.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.saved.offsetX, self.saved.offsetY)
    else
        self.ui.window:SetAnchor(TOP, GuiRoot, TOP, 0, CONFIG.DEFAULT_TOP_OFFSET)
    end
end

function PCAGC:SavePosition()
    if not self.ui or not self.saved then return end
    local left = tonumber(self.ui.window:GetLeft())
    local top = tonumber(self.ui.window:GetTop())
    if left and left == left and left ~= math.huge and left ~= -math.huge
        and top and top == top and top ~= math.huge and top ~= -math.huge then
        self.saved.offsetX = left
        self.saved.offsetY = top
    else
        self.saved.offsetX = nil
        self.saved.offsetY = nil
    end
end

function PCAGC:EnsureNotificationSurface()
    if not self.ui then return end
    self.ui.window:SetAlpha(1)
    self.ui.window:SetHidden(false)
end

function PCAGC:HideMark()
    if not self.ui then return end
    self.ui.mark:SetHidden(true)
end

function PCAGC:ShowMarkCountdown(seconds)
    if self.unlocked or not self.ui then return end
    self:EnsureNotificationSurface()
    self.ui.mark:SetAlpha(1)
    self.ui.mark:SetText(string.format("Mark of the Sea: %ds", seconds))
    self.ui.mark:SetHidden(false)
end

function PCAGC:RenderMarkNow()
    if self.unlocked or not self.ui then return end
    self:EnsureNotificationSurface()
    self.ui.mark:SetAlpha(1)
    self.ui.mark:SetText("Mark of the Sea: Now")
    self.ui.mark:SetHidden(false)
end

function PCAGC:BeginMarkNow(nowMs)
    self.nextMarkDeadlineMs = nil
    self.markNowUntilMs = (nowMs or GetGameTimeMilliseconds()) + CONFIG.MARK_NOW_MS
    self:RenderMarkNow()
    self:EnsureUpdate()
end

function PCAGC:RefreshLinkNames()
    if self.unlocked or not self.ui then return end

    if not self.targetA and not self.targetB then
        self.ui.linkNames:SetHidden(true)
        return
    end

    local left = self.targetA and self.targetA.displayName or ""
    local right = self.targetB and self.targetB.displayName or ""

    if left ~= "" and right ~= "" then
        self.ui.linkNames:SetText(string.format("%s -> %s", left, right))
    elseif left ~= "" then
        self.ui.linkNames:SetText(string.format("%s ->", left))
    else
        self.ui.linkNames:SetText(string.format("-> %s", right))
    end

    self:EnsureNotificationSurface()
    self.ui.linkNames:SetAlpha(1)
    self.ui.linkNames:SetHidden(false)
end

function PCAGC:ShowMindLink()
    if self.unlocked or not self.ui then return end
    self:EnsureNotificationSurface()
    self:HideMark()
    self.ui.linkHeader:SetAlpha(1)
    self.ui.linkHeader:SetText("Mind Link")
    self.ui.linkHeader:SetHidden(false)
    self:RefreshLinkNames()
end

function PCAGC:ShowTether(seconds)
    if self.unlocked or not self.ui then return end
    self:EnsureNotificationSurface()
    self:HideMark()
    self.ui.linkHeader:SetAlpha(1)
    self.ui.linkHeader:SetText(string.format("Tether: %ds", seconds))
    self.ui.linkHeader:SetHidden(false)
    self:RefreshLinkNames()
end

function PCAGC:HideLinkUI()
    if not self.ui then return end
    self.ui.linkHeader:SetHidden(true)
    self.ui.linkNames:SetHidden(true)
end

function PCAGC:HideBossAlerts()
    if not self.ui then return end
    self.ui.bossAlert:SetHidden(true)
    self.ui.bossDetail:SetHidden(true)
    self.ui.bossAside:SetHidden(true)
end

function PCAGC:LayoutBossAlerts(alertVisible, detailVisible, asideVisible)
    if not self.ui then return end
    local alert = self.ui.bossAlert
    local detail = self.ui.bossDetail
    local aside = self.ui.bossAside

    alert:ClearAnchors()
    detail:ClearAnchors()
    aside:ClearAnchors()
    alert:SetAnchor(TOPLEFT, self.ui.window, TOPLEFT, 0, 0)

    if detailVisible then
        if alertVisible then
            detail:SetAnchor(TOP, alert, BOTTOM, 0, CONFIG.LINE_GAP)
        else
            detail:SetAnchor(TOPLEFT, self.ui.window, TOPLEFT, 0, 0)
        end
    else
        detail:SetAnchor(TOPLEFT, self.ui.window, TOPLEFT, 0, 0)
    end

    if asideVisible then
        if detailVisible then
            aside:SetAnchor(TOP, detail, BOTTOM, 0, CONFIG.LINE_GAP)
        elseif alertVisible then
            aside:SetAnchor(TOP, alert, BOTTOM, 0, CONFIG.LINE_GAP)
        else
            aside:SetAnchor(TOPLEFT, self.ui.window, TOPLEFT, 0, 0)
        end
    else
        aside:SetAnchor(TOPLEFT, self.ui.window, TOPLEFT, 0, 0)
    end
end

function PCAGC:IsHealerUI()
    local role = GetGroupMemberSelectedRole("player")
    if not role or role == LFG_ROLE_INVALID then
        role = GetSelectedLFGRole()
    end
    return role == LFG_ROLE_HEAL
end

function PCAGC:ShowMovePreview()
    if not self.ui then return end

    -- Unlocking must always provide a visible object to grab. If the user has
    -- selected a specific preview, preserve it; otherwise show the Mark sample
    -- as the neutral mover text. No texture, fill, border, or backdrop is used.
    if self.previewMode ~= "OFF" then
        self:ShowPreview(self.previewMode)
    else
        self.ui.linkHeader:SetHidden(true)
        self.ui.linkNames:SetHidden(true)
        self.ui.mark:SetText("Mark of the Sea: 20s")
        self.ui.mark:SetHidden(false)
        self:EnsureNotificationSurface()
    end
end


---------------------------------------------------------------------
-- UPDATE LOOP
---------------------------------------------------------------------
function PCAGC:EnsureUpdate()
    if self.updateRegistered then return end

    EM:RegisterForUpdate(EVENT_NAMESPACE .. "_Update", CONFIG.UPDATE_INTERVAL_MS, function()
        PCAGC:OnUpdate()
    end)
    self.updateRegistered = true
end

function PCAGC:StopUpdate()
    if not self.updateRegistered then return end
    EM:UnregisterForUpdate(EVENT_NAMESPACE .. "_Update")
    self.updateRegistered = false
end

function PCAGC:OnUpdate()
    local nowMs = GetGameTimeMilliseconds()

    -- Moving/configuring the notification suppresses live rendering, but not
    -- the underlying mechanic state. Unlocking is blocked during combat.
    if self.unlocked then return end

    if not self.runtimeLoaded or not self.encounterActive then
        self:StopUpdate()
        return
    end

    -- Path sampling is the only intentionally continuous combat work. It runs
    -- only during an active prediction window.
    self:UpdatePathTracking()

    if self.beamAActive or self.beamBActive then
        if self.tetherDeadlineMs then
            self:ShowTether(SecondsCeil(self.tetherDeadlineMs - nowMs))
        else
            self:ShowTether(0)
        end
        return
    end

    if self.markNowUntilMs then
        if nowMs < self.markNowUntilMs then
            self:RenderMarkNow()
            return
        end
        self.markNowUntilMs = nil
        self:HideMark()
    end

    if self.nextMarkDeadlineMs then
        local remainingMs = self.nextMarkDeadlineMs - nowMs
        if remainingMs > 0 then
            local visibleLimitMs = CONFIG.FIRST_VISIBLE_SECONDS * 1000
            if remainingMs <= visibleLimitMs then
                self:ShowMarkCountdown(SecondsCeil(remainingMs))
            else
                self:HideMark()
            end
        else
            -- Forecast expiry never synthesizes an authoritative Mark event. It
            -- only bounds stale prediction work if that event was missed.
            self.nextMarkDeadlineMs = nil
            self:StopPathTracking()
            self:HideMark()
        end
    else
        self:HideMark()
    end

    -- If no countdown/tether/path state needs periodic work, leave the static
    -- Mind Link text entirely event-driven and stop the 100 ms callback.
    if not self.pathTrackingActive and not self.beamAActive and not self.beamBActive
        and not self.markNowUntilMs and not self.nextMarkDeadlineMs then
        self:StopUpdate()
    end
end

---------------------------------------------------------------------
-- UNIT RESOLUTION
---------------------------------------------------------------------
local function FindGroupMemberByName(targetName)
    local wanted = NormalizedName(targetName)
    if wanted == "" then return "", "" end

    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and unitTag ~= "" then
            local rawName = NormalizedName(GetRawUnitName(unitTag))
            local unitName = NormalizedName(GetUnitName(unitTag))
            if rawName == wanted or unitName == wanted then
                return GetUnitDisplayName(unitTag) or "", unitTag
            end
        end
    end

    local playerRaw = NormalizedName(GetRawUnitName("player"))
    local playerName = NormalizedName(GetUnitName("player"))
    if playerRaw == wanted or playerName == wanted then
        return GetUnitDisplayName("player") or "", "player"
    end

    return "", ""
end

local function FindGroupMemberByDisplayName(displayName)
    if not displayName or displayName == "" or displayName == "?" then return "" end

    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and unitTag ~= "" and (GetUnitDisplayName(unitTag) or "") == displayName then
            return unitTag
        end
    end

    if (GetUnitDisplayName("player") or "") == displayName then
        return "player"
    end
    return ""
end

function PCAGC:ReconcileTargetUnitTag(target)
    if not target then return false end

    -- Do not trust a stored groupN tag merely because it still exists: groupN
    -- references can be reassigned to a different player after roster changes.
    local unitTag = FindGroupMemberByDisplayName(target.displayName)
    if unitTag == "" and target.unitName and target.unitName ~= "" then
        local displayName
        displayName, unitTag = FindGroupMemberByName(target.unitName)
        if displayName and displayName ~= "" then target.displayName = displayName end
    end

    target.unitTag = unitTag or ""
    return target.unitTag ~= ""
end

function PCAGC:ResolveEffectTarget(unitTag, unitId, unitName)
    unitTag = unitTag or ""
    local displayName = ""

    -- EVENT_EFFECT_CHANGED already provides the affected unitTag. Prefer that
    -- authoritative native identity and use LibUnits2 only as a recovery path.
    if unitTag ~= "" and DoesUnitExist(unitTag) then
        displayName = GetUnitDisplayName(unitTag) or ""
    end

    if (unitTag == "" or displayName == "") and unitId and unitId ~= 0 then
        if displayName == "" then
            displayName = LibUnits2.GetDisplayNameForUnitId(unitId) or ""
        end
        if unitTag == "" then
            unitTag = LibUnits2.GetUnitTagForUnitId(unitId) or ""
        end
    end

    if displayName == "" and unitTag ~= "" then
        displayName = GetUnitDisplayName(unitTag) or ""
    end

    if displayName == "" or unitTag == "" then
        local fallbackDisplay, fallbackTag = FindGroupMemberByName(unitName)
        if displayName == "" then displayName = fallbackDisplay end
        if unitTag == "" then unitTag = fallbackTag end
    end

    if displayName == "" then displayName = NormalizedName(unitName) end
    if displayName == "" then displayName = "?" end

    if unitTag == "" then
        self:LogWarn("Could not resolve a unit tag for effect unitId=%s target=%s; text will remain available but the arrow cannot attach", tostring(unitId), tostring(displayName))
    end

    return {
        displayName = displayName,
        unitTag = unitTag,
        unitId = unitId,
        unitName = NormalizedName(unitName),
    }
end

---------------------------------------------------------------------
-- ATTACHED ARROWS
---------------------------------------------------------------------
local function IconNameForSlot(slot)
    if slot == "A" then return ICON_NAME_A end
    return ICON_NAME_B
end

function PCAGC:RemoveArrow(slot)
    local arrow = self.arrows[slot]
    if not arrow then return end

    if arrow.unitTag ~= "" then
        CrutchAlerts.RemoveAttachedIconForUnit(arrow.unitTag, IconNameForSlot(slot))
    end

    self.arrows[slot] = nil
end

function PCAGC:RemoveAllArrows()
    self:RemoveArrow("A")
    self:RemoveArrow("B")

    -- Unit tags can change during zoning/group changes. CrutchAlerts 2.24.0+
    -- exposes catch-all cleanup, so remove addon-owned icons by unique name.
    CrutchAlerts.RemoveAllAttachedIcons(ICON_NAME_A)
    CrutchAlerts.RemoveAllAttachedIcons(ICON_NAME_B)
end

function PCAGC:ShowArrow(slot, target)
    self:RemoveArrow(slot)

    if not self.saved.arrowsEnabled then return end

    -- CrutchAlerts is the only renderer. Force its modern Space API path.
    -- If unit-tag resolution fails, the text notification still functions and
    -- no renderer fallback is attempted.
    if target.unitTag == "" then return end

    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.arrowSpaceSize,
            color = ColorAsArray(self.saved.arrowColor),
        },
    }

    CrutchAlerts.SetAttachedIconForUnit(
        target.unitTag,
        IconNameForSlot(slot),
        CONFIG.ARROW_PRIORITY,
        CONFIG.ARROW_TEXTURE,
        CONFIG.ARROW_SIZE,
        ColorAsArray(self.saved.arrowColor),
        false,
        nil,
        spaceOptions
    )
    self.arrows[slot] = {unitTag = target.unitTag}
    self:LogDebug("Attached Mind Link arrow %s to %s", tostring(slot), tostring(target.unitTag))
end

function PCAGC:RefreshActiveArrows()
    self:RemoveAllArrows()
    if not self.saved.arrowsEnabled then
        self:RemoveAllPredictionArrows()
        return
    end

    if self.targetA then self:ShowArrow("A", self.targetA) end
    if self.targetB then self:ShowArrow("B", self.targetB) end

    if self.pathTrackingActive and self.saved.predictorEnabled then
        self:RefreshPathPredictionArrows()
    end
end

---------------------------------------------------------------------
-- EXPERIMENTAL PATH-DISTANCE PREDICTOR
---------------------------------------------------------------------
local function PredictionIconNameForSlot(slot)
    if slot == "A" then return PREDICTION_ICON_NAME_A end
    return PREDICTION_ICON_NAME_B
end

function PCAGC:RemovePredictionArrow(slot)
    local arrow = self.predictionArrows[slot]
    if not arrow then return end

    if arrow.unitTag ~= "" then
        CrutchAlerts.RemoveAttachedIconForUnit(arrow.unitTag, PredictionIconNameForSlot(slot))
    end

    self.predictionArrows[slot] = nil
end

function PCAGC:RemoveAllPredictionArrows()
    self:RemovePredictionArrow("A")
    self:RemovePredictionArrow("B")

    CrutchAlerts.RemoveAllAttachedIcons(PREDICTION_ICON_NAME_A)
    CrutchAlerts.RemoveAllAttachedIcons(PREDICTION_ICON_NAME_B)
end

function PCAGC:RefreshPredictionArrowAppearance()
    self:RemoveAllPredictionArrows()
    if self.saved.arrowsEnabled and self.saved.predictorEnabled and self.pathTrackingActive then
        self:RefreshPathPredictionArrows()
    end
end

function PCAGC:ShowPredictionArrow(slot, unitTag)
    if not self.saved.arrowsEnabled or not self.saved.predictorEnabled or not unitTag or unitTag == "" then
        return
    end

    local existing = self.predictionArrows[slot]
    if existing and existing.unitTag == unitTag then return end
    self:RemovePredictionArrow(slot)

    local color = ColorAsArray(self.saved.predictorArrowColor)
    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.predictorArrowSpaceSize,
            color = color,
        },
    }

    CrutchAlerts.SetAttachedIconForUnit(
        unitTag,
        PredictionIconNameForSlot(slot),
        CONFIG.PREDICTION_ARROW_PRIORITY,
        CONFIG.ARROW_TEXTURE,
        CONFIG.ARROW_SIZE,
        color,
        false,
        nil,
        spaceOptions
    )
    self.predictionArrows[slot] = {unitTag = unitTag}
end

function PCAGC:GetRankedPathSamples(eligibleOnly)
    local ranked = {}
    for _, sample in pairs(self.pathSamples) do
        local eligible = sample.unitTag and sample.unitTag ~= ""
        if eligibleOnly then
            eligible = eligible
                and sample.present == true
                and sample.continuous == true
                and DoesUnitExist(sample.unitTag)
                and not IsUnitDead(sample.unitTag)
        end
        if eligible then
            ranked[#ranked + 1] = sample
        end
    end

    table.sort(ranked, function(a, b)
        if a.distanceCm == b.distanceCm then
            return (a.order or 999) < (b.order or 999)
        end
        return a.distanceCm < b.distanceCm
    end)

    return ranked
end

function PCAGC:RefreshPathPredictionArrows()
    if not self.pathTrackingActive or not self.saved.arrowsEnabled or not self.saved.predictorEnabled then
        self:RemoveAllPredictionArrows()
        return
    end

    -- Death does not break observation continuity: a resurrected player can
    -- re-enter the candidate ranking with the path accumulated in this window.
    -- Group departure/re-entry does break continuity because movement while the
    -- player was absent is unknowable; that sample is excluded until the next
    -- prediction window.
    local ranked = self:GetRankedPathSamples(true)
    local first = ranked[1]
    local second = ranked[2]

    if first then
        self:ShowPredictionArrow("A", first.unitTag)
    else
        self:RemovePredictionArrow("A")
    end

    if second then
        self:ShowPredictionArrow("B", second.unitTag)
    else
        self:RemovePredictionArrow("B")
    end
end

local function PathIdentityForUnitTag(unitTag)
    local displayName = GetUnitDisplayName(unitTag) or ""
    if displayName == "" then return nil end
    return displayName
end

local function SetSamplePosition(sample, zoneId, x, y, z, order, unitTag)
    sample.zoneId = zoneId
    sample.lastX = x
    sample.lastY = y
    sample.lastZ = z
    sample.order = order
    sample.unitTag = unitTag
end

function PCAGC:StartPathTracking(nowMs)
    -- Prediction is an explicit opt-in. Enabling it after a window has started
    -- waits for the next window rather than ranking an incomplete sample.
    if not self.saved.predictorEnabled then
        self:RemoveAllPredictionArrows()
        return
    end

    -- Duplicate EFFECT_FADED notifications must not erase distance already
    -- accumulated for the current selection window.
    if self.pathTrackingActive then return end

    self.pathTrackingActive = true
    local trackingStartMs = nowMs or GetGameTimeMilliseconds()
    self.pathSamples = {}
    self:RemoveAllPredictionArrows()

    local trackedCount = 0
    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local identity = unitTag and unitTag ~= "" and PathIdentityForUnitTag(unitTag) or nil
        if identity then
            local zoneId, x, y, z = GetUnitRawWorldPosition(unitTag)
            if zoneId and zoneId ~= 0 and x and y and z then
                self.pathSamples[identity] = {
                    unitTag = unitTag,
                    displayName = identity,
                    order = i,
                    zoneId = zoneId,
                    lastX = x,
                    lastY = y,
                    lastZ = z,
                    distanceCm = 0,
                    present = true,
                    continuous = true,
                }
                trackedCount = trackedCount + 1
            end
        end
    end

    self:RefreshPathPredictionArrows()
    self:LogInfo("Path-distance tracking started at %d for %d continuously observed group members", trackingStartMs, trackedCount)
    self:EnsureUpdate()
end

function PCAGC:UpdatePathTracking()
    if not self.pathTrackingActive then return end
    if not self.saved.predictorEnabled then
        self:StopPathTracking()
        return
    end

    for _, sample in pairs(self.pathSamples) do
        sample.seenNow = false
    end

    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        local identity = unitTag and unitTag ~= "" and PathIdentityForUnitTag(unitTag) or nil
        if identity then
            local zoneId, x, y, z = GetUnitRawWorldPosition(unitTag)
            if zoneId and zoneId ~= 0 and x and y and z then
                local sample = self.pathSamples[identity]
                if not sample then
                    -- Joining after the window began cannot be ranked fairly;
                    -- preserve it for diagnostics but exclude it as a candidate.
                    sample = {
                        unitTag = unitTag,
                        displayName = identity,
                        order = i,
                        zoneId = zoneId,
                        lastX = x,
                        lastY = y,
                        lastZ = z,
                        distanceCm = 0,
                        present = true,
                        continuous = false,
                    }
                    self.pathSamples[identity] = sample
                elseif sample.present ~= true then
                    -- A returning member has an observation gap. Re-anchor but
                    -- do not pretend its unseen movement was zero.
                    sample.present = true
                    sample.continuous = false
                    SetSamplePosition(sample, zoneId, x, y, z, i, unitTag)
                elseif sample.zoneId == zoneId then
                    local dx = x - sample.lastX
                    local dy = y - sample.lastY
                    local dz = z - sample.lastZ
                    sample.distanceCm = sample.distanceCm + zo_sqrt((dx * dx) + (dy * dy) + (dz * dz))
                    SetSamplePosition(sample, zoneId, x, y, z, i, unitTag)
                else
                    -- A zone discontinuity is not player travel. Re-anchor the
                    -- sample without adding an artificial teleport distance.
                    SetSamplePosition(sample, zoneId, x, y, z, i, unitTag)
                end
                sample.seenNow = true
            end
        end
    end

    for _, sample in pairs(self.pathSamples) do
        if not sample.seenNow then
            sample.present = false
        end
        sample.seenNow = nil
    end

    self:RefreshPathPredictionArrows()
end

function PCAGC:StopPathTracking()
    if self.pathTrackingActive then
        local ranked = self:GetRankedPathSamples(false)
        local eligible = self:GetRankedPathSamples(true)
        local parts = {}
        for i = 1, #ranked do
            local sample = ranked[i]
            parts[#parts + 1] = string.format(
                "%d:%s=%.2fm",
                i,
                tostring(sample.displayName),
                (sample.distanceCm or 0) / 100
            )
        end
        if #parts > 0 then
            self:LogInfo("Final path ranking: %s", table.concat(parts, ", "))
        end
        self:LogInfo(
            "Final living path candidates: A=%s B=%s",
            eligible[1] and tostring(eligible[1].displayName) or "none",
            eligible[2] and tostring(eligible[2].displayName) or "none"
        )
    end

    self.pathTrackingActive = false
    self.pathSamples = {}
    self:RemoveAllPredictionArrows()
end

---------------------------------------------------------------------
-- MALIGALIG / SARYDIL
---------------------------------------------------------------------
function PCAGC:ResetMaligaligState()
    self.staticStacks = 0
    if self.currentBossKey == MALIGALIG_KEY then
        self:HideBossAlerts()
    end
end

function PCAGC:RefreshMaligaligUI()
    if self.currentBossKey ~= MALIGALIG_KEY then return end
    if self.unlocked or not self.inCombat or not self.ui then
        self:HideBossAlerts()
        return
    end

    if self.staticStacks >= self.saved.maligaligLeaveStacks then
        self:EnsureNotificationSurface()
        self:HideMark()
        self:HideLinkUI()
        self.ui.bossAlert:SetText("LEAVE NOW")
        self.ui.bossAlert:SetColor(1.00, 0.24, 0.08, 1.00)
        self.ui.bossAlert:SetHidden(false)
        self.ui.bossDetail:SetHidden(true)
        self.ui.bossAside:SetHidden(true)
        self:LayoutBossAlerts(true, false, false)
    else
        self:HideBossAlerts()
    end
end

function PCAGC:RemoveSarydilPurgeArrow(unitTag)
    if not unitTag or unitTag == "" then return end
    CrutchAlerts.RemoveAttachedIconForUnit(unitTag, SARYDIL_PURGE_ICON_NAME)
    self.sarydilPurgeArrows[unitTag] = nil
end

function PCAGC:RemoveAllSarydilPurgeArrows()
    local unitTags = {}
    for unitTag in pairs(self.sarydilPurgeArrows) do
        unitTags[#unitTags + 1] = unitTag
    end
    for _, unitTag in ipairs(unitTags) do
        self:RemoveSarydilPurgeArrow(unitTag)
    end
    CrutchAlerts.RemoveAllAttachedIcons(SARYDIL_PURGE_ICON_NAME)
end

function PCAGC:ShowSarydilPurgeArrow(target)
    if not self.saved.arrowsEnabled or not self:IsHealerUI() then return end
    if not target or not target.unitTag or target.unitTag == "" then return end
    if self.sarydilPurgeArrows[target.unitTag] then return end

    local color = ColorAsArray(self.saved.sarydilPurgeArrowColor)
    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.sarydilPurgeArrowSpaceSize,
            color = color,
        },
    }
    CrutchAlerts.SetAttachedIconForUnit(
        target.unitTag,
        SARYDIL_PURGE_ICON_NAME,
        CONFIG.SARYDIL_PURGE_ARROW_PRIORITY,
        CONFIG.ARROW_TEXTURE,
        CONFIG.ARROW_SIZE,
        color,
        false,
        nil,
        spaceOptions
    )
    self.sarydilPurgeArrows[target.unitTag] = true
end

function PCAGC:RemoveSarydilPinpointArrow()
    local arrow = self.sarydilPinpointArrow
    if arrow and arrow.unitTag and arrow.unitTag ~= "" then
        CrutchAlerts.RemoveAttachedIconForUnit(arrow.unitTag, SARYDIL_PINPOINT_ICON_NAME)
    end
    self.sarydilPinpointArrow = nil
    CrutchAlerts.RemoveAllAttachedIcons(SARYDIL_PINPOINT_ICON_NAME)
end

function PCAGC:ShowSarydilPinpointArrow(target)
    if not self.saved.arrowsEnabled or not self:IsHealerUI() then return end
    if not target or not target.unitTag or target.unitTag == "" then return end
    if self.sarydilPinpointArrow and self.sarydilPinpointArrow.unitTag == target.unitTag then return end
    self:RemoveSarydilPinpointArrow()

    local color = ColorAsArray(self.saved.sarydilPinpointArrowColor)
    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.sarydilPinpointArrowSpaceSize,
            color = color,
        },
    }
    CrutchAlerts.SetAttachedIconForUnit(
        target.unitTag,
        SARYDIL_PINPOINT_ICON_NAME,
        CONFIG.SARYDIL_PINPOINT_ARROW_PRIORITY,
        CONFIG.ARROW_TEXTURE,
        CONFIG.ARROW_SIZE,
        color,
        false,
        nil,
        spaceOptions
    )
    self.sarydilPinpointArrow = {unitTag = target.unitTag}
end

function PCAGC:CountPurgeTargets()
    local count = 0
    for _ in pairs(self.purgeTargets) do count = count + 1 end
    return count
end

function PCAGC:RefreshSarydilRendering()
    local isHealer = self:IsHealerUI()
    local canRender = self.currentBossKey == SARYDIL_KEY
        and self.inCombat
        and isHealer
        and self.saved.arrowsEnabled

    if self.currentBossKey ~= SARYDIL_KEY or not self.inCombat or not isHealer then
        self:RemoveAllSarydilPurgeArrows()
        self:RemoveSarydilPinpointArrow()
        if self.currentBossKey == SARYDIL_KEY then self:HideBossAlerts() end
        return
    end

    -- Reconcile world markers instead of tearing down and recreating every icon
    -- on every effect event. This keeps low-frequency Sarydil updates idempotent.
    local wantedPurgeTags = {}
    if canRender then
        for _, entry in pairs(self.purgeTargets) do
            local target = entry.target
            if target and target.unitTag and target.unitTag ~= "" then
                wantedPurgeTags[target.unitTag] = true
            end
        end
    end

    local stale = {}
    for unitTag in pairs(self.sarydilPurgeArrows) do
        if not wantedPurgeTags[unitTag] then stale[#stale + 1] = unitTag end
    end
    for _, unitTag in ipairs(stale) do self:RemoveSarydilPurgeArrow(unitTag) end

    if canRender then
        for _, entry in pairs(self.purgeTargets) do self:ShowSarydilPurgeArrow(entry.target) end
        if self.pinpointTarget then
            self:ShowSarydilPinpointArrow(self.pinpointTarget)
        else
            self:RemoveSarydilPinpointArrow()
        end
    else
        self:RemoveAllSarydilPurgeArrows()
        self:RemoveSarydilPinpointArrow()
    end

    local purgeVisible = self:CountPurgeTargets() > 0
    local detailVisible = self.pinpointTarget ~= nil
    local asideVisible = detailVisible and self.saved.sarydilHumorEnabled

    if purgeVisible or detailVisible then
        self:EnsureNotificationSurface()
        self:HideMark()
        self:HideLinkUI()
    end

    if purgeVisible then
        self.ui.bossAlert:SetText("PURGE")
        self.ui.bossAlert:SetColor(1.00, 0.82, 0.00, 1.00)
        self.ui.bossAlert:SetHidden(false)
    else
        self.ui.bossAlert:SetHidden(true)
    end

    if detailVisible then
        self.ui.bossDetail:SetText(string.format("Healcheck %s", self.pinpointTarget.displayName or "?"))
        self.ui.bossDetail:SetColor(1.00, 0.12, 0.08, 1.00)
        self.ui.bossDetail:SetHidden(false)
    else
        self.ui.bossDetail:SetHidden(true)
    end

    if asideVisible then
        self.ui.bossAside:SetText("well look who's dying again!")
        self.ui.bossAside:SetColor(0.72, 0.72, 0.72, 1.00)
        self.ui.bossAside:SetHidden(false)
    else
        self.ui.bossAside:SetHidden(true)
    end

    self:LayoutBossAlerts(purgeVisible, detailVisible, asideVisible)
end

function PCAGC:ResetSarydilState()
    self.purgeTargets = {}
    self.pinpointEffects = {}
    self.pinpointSequence = 0
    self.pinpointTarget = nil
    self:RemoveAllSarydilPurgeArrows()
    self:RemoveSarydilPinpointArrow()
    if self.currentBossKey == SARYDIL_KEY then
        self:HideBossAlerts()
    end
end

function PCAGC:PurgeTargetKey(targetUnitId, target)
    if targetUnitId and targetUnitId ~= 0 then return "id:" .. tostring(targetUnitId) end
    if target and target.unitTag and target.unitTag ~= "" then return "tag:" .. target.unitTag end
    if target and target.displayName and target.displayName ~= "" and target.displayName ~= "?" then
        return "name:" .. target.displayName
    end
    return nil
end

local function EffectIdentityMatches(target, unitTag, unitId, unitName)
    if not target then return false end
    if unitId and unitId ~= 0 and target.unitId and target.unitId ~= 0 then
        return target.unitId == unitId
    end
    local normalized = NormalizedName(unitName)
    if normalized ~= "" and target.unitName and target.unitName ~= "" then
        return target.unitName == normalized
    end
    if unitTag and unitTag ~= "" and target.unitTag and target.unitTag ~= "" then
        return target.unitTag == unitTag
    end
    return normalized ~= "" and target.displayName == normalized
end

local function TargetsEquivalent(a, b)
    if not a or not b then return false end
    if a.unitId and a.unitId ~= 0 and b.unitId and b.unitId ~= 0 then
        return a.unitId == b.unitId
    end
    if a.unitName and a.unitName ~= "" and b.unitName and b.unitName ~= "" then
        return a.unitName == b.unitName
    end
    if a.unitTag ~= "" and b.unitTag ~= "" then
        return a.unitTag == b.unitTag
    end
    return a.displayName ~= "" and a.displayName ~= "?" and a.displayName == b.displayName
end

function PCAGC:FindPurgeTargetEntry(unitTag, unitId, unitName)
    if unitId and unitId ~= 0 then
        local key = "id:" .. tostring(unitId)
        if self.purgeTargets[key] then return key, self.purgeTargets[key] end
    end
    for key, entry in pairs(self.purgeTargets) do
        if EffectIdentityMatches(entry.target, unitTag, unitId, unitName) then
            return key, entry
        end
    end
    return nil, nil
end

function PCAGC:HandleMaligaligEffect(changeType, stackCount)
    if IsEffectPresent(changeType) then
        local stacks = tonumber(stackCount) or 0
        self.staticStacks = math.max(0, math.floor(stacks))
        self:LogDebug("Maligalig Building Static stacks=%d", self.staticStacks)
    elseif changeType == EFFECT_RESULT_FADED then
        self.staticStacks = 0
    else
        return
    end
    self:RefreshMaligaligUI()
end

function PCAGC:HandleSarydilPurgeEffect(changeType, abilityId, unitTag, unitId, unitName)
    if IsEffectPresent(changeType) then
        local target = self:ResolveEffectTarget(unitTag, unitId, unitName)
        local preferredKey = self:PurgeTargetKey(unitId, target)
        if not preferredKey then return end

        local existingKey, entry = self:FindPurgeTargetEntry(unitTag, unitId, unitName)
        if not entry then
            entry = {target = target, effects = {}}
            self.purgeTargets[preferredKey] = entry
        else
            entry.target = target
            if existingKey ~= preferredKey then
                self.purgeTargets[existingKey] = nil
                self.purgeTargets[preferredKey] = entry
            end
        end
        entry.effects[abilityId] = true
    elseif changeType == EFFECT_RESULT_FADED then
        local key, entry = self:FindPurgeTargetEntry(unitTag, unitId, unitName)
        if entry then
            entry.effects[abilityId] = nil
            if not next(entry.effects) then
                if entry.target then self:RemoveSarydilPurgeArrow(entry.target.unitTag) end
                self.purgeTargets[key] = nil
            end
        end
    else
        return
    end

    self:RefreshSarydilRendering()
end

function PCAGC:RefreshPinpointTarget()
    local newest = nil
    for _, entry in pairs(self.pinpointEffects) do
        if not newest or (entry.sequence or 0) > (newest.sequence or 0) then
            newest = entry
        end
    end
    self.pinpointTarget = newest and newest.target or nil
end

function PCAGC:HandleSarydilPinpointEffect(changeType, abilityId, unitTag, unitId, unitName)
    if IsEffectPresent(changeType) then
        local target = self:ResolveEffectTarget(unitTag, unitId, unitName)
        local entry = self.pinpointEffects[abilityId]
        if not entry or not TargetsEquivalent(entry.target, target) then
            self.pinpointSequence = self.pinpointSequence + 1
            self.pinpointEffects[abilityId] = {target = target, sequence = self.pinpointSequence}
        else
            entry.target = target
        end
    elseif changeType == EFFECT_RESULT_FADED then
        local entry = self.pinpointEffects[abilityId]
        if entry and EffectIdentityMatches(entry.target, unitTag, unitId, unitName) then
            self.pinpointEffects[abilityId] = nil
        end
    else
        return
    end

    self:RefreshPinpointTarget()
    if self.pinpointTarget then
        self:LogInfo("Sarydil Pinpoint target: %s", tostring(self.pinpointTarget.displayName))
    end
    self:RefreshSarydilRendering()
end


---------------------------------------------------------------------
-- VARALLION WORLD MARKERS
---------------------------------------------------------------------
function PCAGC:RemoveWorldMarkerKey(key)
    if not key then return end
    CrutchAlerts.Drawing.RemoveWorldTexture(key)
end

function PCAGC:ClearVarallionSafeZones()
    for _, key in ipairs(self.safeZoneMarkerKeys or {}) do
        self:RemoveWorldMarkerKey(key)
    end
    self.safeZoneMarkerKeys = {}
end

function PCAGC:RefreshVarallionSafeZones()
    self:ClearVarallionSafeZones()
    if self.currentBossKey ~= VARALLION_KEY then return end
    if not self.saved or not self.saved.varallionSafeZonesEnabled then return end
    

    local draw = CrutchAlerts.Drawing
    local color = ColorAsArray(self.saved.varallionSafeZoneColor)
    local radius = tonumber(self.saved.varallionSafeZoneRadius) or DEFAULTS.varallionSafeZoneRadius

    for _, position in ipairs(VARALLION_SAFE_ZONES) do
        local key = draw.CreateGroundCircle(
            position.x,
            position.y + 5,
            position.z,
            radius,
            color,
            nil,
            nil,
            false
        )
        if key then
            self.safeZoneMarkerKeys[#self.safeZoneMarkerKeys + 1] = key
        end
    end
end


function PCAGC:ClearVarallionWorldMarkers()
    self:ClearVarallionSafeZones()
end

function PCAGC:RefreshVarallionWorldMarkers()
    self:RefreshVarallionSafeZones()
end

function PCAGC:SetBossContext(bossKey, source)
    bossKey = bossKey or ""
    if bossKey == self.currentBossKey then
        self.varallionSeen = bossKey == VARALLION_KEY
        return
    end

    local previous = self.currentBossKey
    if previous == VARALLION_KEY then
        if self.encounterActive then self:ResetEncounter() end
        self:ClearVarallionWorldMarkers()
    end
    if previous == MALIGALIG_KEY then self:ResetMaligaligState() end
    if previous == SARYDIL_KEY then self:ResetSarydilState() end

    self.currentBossKey = bossKey
    self.varallionSeen = bossKey == VARALLION_KEY
    self:HideBossAlerts()
    if bossKey == VARALLION_KEY then self:RefreshVarallionWorldMarkers() end
    self:LogInfo("Encounter context: %s -> %s (%s)", previous ~= "" and previous or "none", bossKey ~= "" and bossKey or "none", source or "unknown")
end

function PCAGC:EnsureBossMechanicContext(bossKey)
    if not self.runtimeLoaded or CurrentWorldZoneId() ~= CORAL_AERIE_ZONE_ID then return false end

    -- Late teardown events must not recreate encounter state after combat. The
    -- native player-combat query covers the short race before our state callback.
    if not self.inCombat and not IsUnitInCombat("player") then
        self:LogDebug("Ignored %s mechanic context outside combat", tostring(bossKey))
        return false
    end

    -- Once a supported encounter has supplied mechanic evidence during this
    -- combat, a contradictory late event from another encounter cannot replace it.
    if self.currentBossKey ~= "" and self.currentBossKey ~= bossKey then
        self:LogDebug("Ignored %s mechanic context while %s context is active", tostring(bossKey), tostring(self.currentBossKey))
        return false
    end

    if self.currentBossKey ~= bossKey then
        self:SetBossContext(bossKey, "mechanic")
    end
    return true
end

---------------------------------------------------------------------
-- ENCOUNTER STATE
---------------------------------------------------------------------
function PCAGC:ClearLinkState(removeArrows)
    self.targetA = nil
    self.targetB = nil
    self.beamAActive = false
    self.beamBActive = false
    self.beamCycleSeen = false
    self.beamCycleAnchored = false
    self.tetherDeadlineMs = nil

    if removeArrows then
        self:RemoveAllArrows()
    end

    self:HideLinkUI()
end

function PCAGC:PrepareEncounterPresentation()
    -- Live combat always wins over setup previews and mover state.
    self.previewMode = "OFF"
    if self.unlocked then
        self:SetUnlocked(false)
    end
end

function PCAGC:StartInitialPrediction()
    if not self.runtimeLoaded or not self.inCombat or not self.combatStartMs then return end
    if not self.varallionSeen then return end

    self:PrepareEncounterPresentation()
    self.encounterActive = true

    -- Encounter identity is established by locale-neutral mechanic evidence;
    -- the fresh combat edge owns the first deadline and is never shifted by a
    -- later identification signal.
    self.nextMarkDeadlineMs = self.combatStartMs + (CONFIG.FIRST_MARK_SECONDS * 1000)
    self.markNowUntilMs = nil
    self.lastAcceptedMarkMs = nil

    self:ClearLinkState(true)
    self:HideMark()


    -- First-cycle path sampling begins only once Varallion context has been
    -- established; movement before that early signal cannot be reconstructed.
    -- The forecast deadline above still uses the true combat edge. Later cycles
    -- restart at final tether fade. Ability 149224 ends each sampling window.
    self:StartPathTracking(GetGameTimeMilliseconds())

    self:LogInfo("Initial Mark deadline armed: combatStartMs=%d deadlineMs=%d", self.combatStartMs, self.nextMarkDeadlineMs)
    self:EnsureUpdate()
end

function PCAGC:EnterRecoveryMode()
    if not self.runtimeLoaded then return end

    self:PrepareEncounterPresentation()
    self.encounterActive = true

    -- A mid-combat reload has no trustworthy pull edge. Do not invent one.
    -- The next tracked mechanic event repairs state and the next final beam
    -- fade restores the closed-loop +17s countdown.
    self.nextMarkDeadlineMs = nil
    self.markNowUntilMs = nil
    self.lastAcceptedMarkMs = nil

    self:ClearLinkState(true)
    self:HideMark()


    self:LogWarn("Entered mid-combat recovery mode; waiting for authoritative mechanic timing")
end

function PCAGC:EnsureEncounterFromMechanic()
    -- Varallion mechanics may establish a blank encounter context, but must
    -- not override Maligalig or Sarydil mechanic evidence in the same combat.
    if not self:EnsureBossMechanicContext(VARALLION_KEY) then
        return false
    end

    if not self.encounterActive then
        self:PrepareEncounterPresentation()
        self.encounterActive = true
        self:LogInfo("Encounter state recovered from tracked mechanic event")
        self.nextMarkDeadlineMs = nil
        self.markNowUntilMs = nil
        self.lastAcceptedMarkMs = nil
        self:ClearLinkState(true)
    end

    return true
end

function PCAGC:ResetEncounter()
    self.encounterActive = false
    self.nextMarkDeadlineMs = nil
    self.markNowUntilMs = nil
    self.lastAcceptedMarkMs = nil

    self:StopPathTracking()
    self:ClearLinkState(true)
    self:HideMark()
    if not self.unlocked then
        self:StopUpdate()
    end
end

---------------------------------------------------------------------
-- COMBAT EVENTS
---------------------------------------------------------------------
function PCAGC:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                            sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
                            combatEventLog, sourceUnitId, targetUnitId, abilityId, overflow)
    if result ~= ACTION_RESULT_BEGIN then return end

    if abilityId == IDS.VARALLION_SIGNAL_SLICE or abilityId == IDS.VARALLION_SIGNAL_OBLITERATE then
        if not self:EnsureBossMechanicContext(VARALLION_KEY) then return end
        self.lastTrackedEvent = string.format("%d (%s), result=%s, context=varallion", abilityId, NormalizedName(abilityName), tostring(result))

        -- Fresh pulls already own a combat-edge timestamp. A signal arriving
        -- after that edge arms the +36 forecast against the original edge; a
        -- signal racing ahead of EVENT_PLAYER_COMBAT_STATE only caches context.
        -- Mid-combat reload has no trustworthy edge and therefore enters recovery.
        if self.inCombat then
            if self.combatStartMs then
                if not self.encounterActive then self:StartInitialPrediction() end
            elseif not self.encounterActive then
                self:EnterRecoveryMode()
            end
        end
        return
    end

    if abilityId ~= IDS.MARK_CAST then return end
    if not self:EnsureEncounterFromMechanic() then return end

    local nowMs = GetGameTimeMilliseconds()
    self.lastTrackedEvent = string.format("%d (%s), result=%s", abilityId, NormalizedName(abilityName), tostring(result))

    if self.lastAcceptedMarkMs and (nowMs - self.lastAcceptedMarkMs) < CONFIG.MARK_DEBOUNCE_MS then
        return
    end

    self.lastAcceptedMarkMs = nowMs
    self:LogInfo("149224 ACTION_RESULT_BEGIN accepted as Mark start at %d", nowMs)
    self:StopPathTracking()
    self:ClearLinkState(true)
    self:BeginMarkNow(nowMs)
end

function PCAGC:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
                               iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if abilityId == IDS.BUILDING_STATIC then
        if not self:EnsureBossMechanicContext(MALIGALIG_KEY) then return end
        self.lastTrackedEvent = string.format("%d (%s), effect=%s, stacks=%s", abilityId, NormalizedName(effectName), tostring(changeType), tostring(stackCount))
        self:HandleMaligaligEffect(changeType, stackCount)
        return
    end

    if IsSarydilAbility(abilityId) then
        if not self:EnsureBossMechanicContext(SARYDIL_KEY) then return end
        self.lastTrackedEvent = string.format("%d (%s), effect=%s, target=%s", abilityId, NormalizedName(effectName), tostring(changeType), NormalizedName(unitName))
        if abilityId == IDS.PURGE_IGNITE or abilityId == IDS.PURGE_APERTURE then
            self:HandleSarydilPurgeEffect(changeType, abilityId, unitTag, unitId, unitName)
        else
            self:HandleSarydilPinpointEffect(changeType, abilityId, unitTag, unitId, unitName)
        end
        return
    end

    if abilityId ~= IDS.LINK_A and abilityId ~= IDS.LINK_B
        and abilityId ~= IDS.BEAM_A and abilityId ~= IDS.BEAM_B then return end

    -- Ignore teardown fades after combat has ended; they must not re-arm the
    -- closed-loop recurrence during a wipe.
    if (abilityId == IDS.BEAM_A or abilityId == IDS.BEAM_B)
        and changeType == EFFECT_RESULT_FADED
        and not self.inCombat and not IsUnitInCombat("player") then
        self.lastTrackedEvent = string.format("%d (%s), effect=%s, ignored=out-of-combat-fade", abilityId, NormalizedName(effectName), tostring(changeType))
        return
    end

    if not self:EnsureEncounterFromMechanic() then return end

    local nowMs = GetGameTimeMilliseconds()
    self.lastTrackedEvent = string.format("%d (%s), effect=%s, target=%s", abilityId, NormalizedName(effectName), tostring(changeType), NormalizedName(unitName))

    if abilityId == IDS.LINK_A and IsEffectPresent(changeType) then
        if not self.targetA then
            self.targetA = self:ResolveEffectTarget(unitTag, unitId, unitName)
            self:LogInfo("Mind Link endpoint A: %s", tostring(self.targetA.displayName))
            self:ShowMindLink()
            self:ShowArrow("A", self.targetA)
        end
        return
    end

    if abilityId == IDS.LINK_B and IsEffectPresent(changeType) then
        if not self.targetB then
            self.targetB = self:ResolveEffectTarget(unitTag, unitId, unitName)
            self:LogInfo("Mind Link endpoint B: %s", tostring(self.targetB.displayName))
            self:ShowMindLink()
            self:ShowArrow("B", self.targetB)
        end
        return
    end

    local beamSlot
    if abilityId == IDS.BEAM_A then beamSlot = "A" end
    if abilityId == IDS.BEAM_B then beamSlot = "B" end
    if not beamSlot then return end

    if changeType == EFFECT_RESULT_UPDATED then
        -- UPDATED confirms an already observed beam but is not a trustworthy
        -- start-time anchor. An orphan/late update must not invent a 25-second
        -- tether window or reopen a completed cycle.
        local isActive = beamSlot == "A" and self.beamAActive or self.beamBActive
        if isActive and self.tetherDeadlineMs then
            self:ShowTether(SecondsCeil(self.tetherDeadlineMs - nowMs))
            self:EnsureUpdate()
        end
        return
    end

    if changeType == EFFECT_RESULT_GAINED then
        local wasAnyActive = self.beamAActive or self.beamBActive
        if not wasAnyActive and self.beamCycleAnchored then
            -- A new observed beam gain begins a new tether cycle.
            self.beamCycleAnchored = false
        end
        self.beamCycleSeen = true
        if beamSlot == "A" then self.beamAActive = true else self.beamBActive = true end
        if not wasAnyActive or not self.tetherDeadlineMs then
            self.tetherDeadlineMs = nowMs + (CONFIG.TETHER_SECONDS * 1000)
        end
        self:ShowTether(SecondsCeil(self.tetherDeadlineMs - nowMs))
        self:EnsureUpdate()
        return
    end

    if changeType ~= EFFECT_RESULT_FADED then return end

    -- A fade is meaningful only if this client observed that beam as active.
    -- This rejects duplicate late fades and reload teardown without inventing a
    -- new 17-second recurrence anchor.
    local wasActive = beamSlot == "A" and self.beamAActive or self.beamBActive
    if not wasActive then return end
    if beamSlot == "A" then self.beamAActive = false else self.beamBActive = false end

    if self.beamAActive or self.beamBActive then return end
    if not self.beamCycleSeen or self.beamCycleAnchored then return end

    self.beamCycleAnchored = true
    self.tetherDeadlineMs = nil
    self.markNowUntilMs = nil
    self.lastAcceptedMarkMs = nil
    self.nextMarkDeadlineMs = nowMs + (CONFIG.NEXT_MARK_SECONDS * 1000)
    self:HideLinkUI()
    self:RemoveAllArrows()
    self.targetA = nil
    self.targetB = nil
    self:StartPathTracking(nowMs)
    self:LogInfo("Final observed Mind Link beam faded; next Mark forecast deadline=%d", self.nextMarkDeadlineMs)
end

local EFFECT_ABILITY_IDS = {
    IDS.BUILDING_STATIC,
    IDS.PINPOINT_A,
    IDS.PINPOINT_B,
    IDS.PURGE_IGNITE,
    IDS.PURGE_APERTURE,
    IDS.LINK_A,
    IDS.LINK_B,
    IDS.BEAM_A,
    IDS.BEAM_B,
}

function PCAGC:RegisterEffectAbility(abilityId, playerOnly)
    local namespace = string.format("%s_Effect_%d", EVENT_NAMESPACE, abilityId)
    EM:RegisterForEvent(namespace, EVENT_EFFECT_CHANGED, function(...) PCAGC:OnEffectChanged(...) end)
    EM:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    if playerOnly then
        EM:AddFilterForEvent(namespace, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    end
end

function PCAGC:RegisterCombatAbility(abilityId, suffix)
    local namespace = EVENT_NAMESPACE .. "_Combat_" .. suffix
    EM:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, function(...) PCAGC:OnCombatEvent(...) end)
    EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
    EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
end

function PCAGC:RegisterMechanicEvents()
    self:RegisterCombatAbility(IDS.MARK_CAST, "MarkCast")
    self:RegisterCombatAbility(IDS.VARALLION_SIGNAL_SLICE, "VarallionSlice")
    self:RegisterCombatAbility(IDS.VARALLION_SIGNAL_OBLITERATE, "VarallionObliterate")

    for _, abilityId in ipairs(EFFECT_ABILITY_IDS) do
        self:RegisterEffectAbility(abilityId, abilityId == IDS.BUILDING_STATIC)
    end
end

function PCAGC:UnregisterMechanicEvents()
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_Combat_MarkCast", EVENT_COMBAT_EVENT)
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_Combat_VarallionSlice", EVENT_COMBAT_EVENT)
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_Combat_VarallionObliterate", EVENT_COMBAT_EVENT)
    for _, abilityId in ipairs(EFFECT_ABILITY_IDS) do
        EM:UnregisterForEvent(string.format("%s_Effect_%d", EVENT_NAMESPACE, abilityId), EVENT_EFFECT_CHANGED)
    end
end

---------------------------------------------------------------------
-- GROUP IDENTITY RECONCILIATION
---------------------------------------------------------------------
function PCAGC:OnGroupUpdate()
    if not self.runtimeLoaded then return end

    -- groupN tags are mutable local references. Remove currently attached icons
    -- before reconciling them so a tag reassignment cannot leave an icon on the
    -- wrong player. Text identity remains keyed by @displayName where available.
    self:RemoveAllArrows()
    self:RemoveAllSarydilPurgeArrows()
    self:RemoveSarydilPinpointArrow()

    if self.targetA then self:ReconcileTargetUnitTag(self.targetA) end
    if self.targetB then self:ReconcileTargetUnitTag(self.targetB) end

    for key, entry in pairs(self.purgeTargets) do
        if not entry.target or not self:ReconcileTargetUnitTag(entry.target) then
            self.purgeTargets[key] = nil
        end
    end

    for abilityId, entry in pairs(self.pinpointEffects) do
        if not entry.target or not self:ReconcileTargetUnitTag(entry.target) then
            self.pinpointEffects[abilityId] = nil
        end
    end
    self:RefreshPinpointTarget()

    if self.currentBossKey == SARYDIL_KEY then
        self:RefreshSarydilRendering()
    elseif self.currentBossKey == VARALLION_KEY then
        self:RefreshLinkNames()
        if self.targetA then self:ShowArrow("A", self.targetA) end
        if self.targetB then self:ShowArrow("B", self.targetB) end
    end
end

---------------------------------------------------------------------
-- COMBAT / ZONE / ENCOUNTER LIFECYCLE
---------------------------------------------------------------------
function PCAGC:LoadCoralAerieRuntime()
    if self.runtimeLoaded then return end

    self.runtimeLoaded = true
    self:LogInfo("Coral Aerie runtime loaded")

    self:RegisterMechanicEvents()
    EM:RegisterForEvent(EVENT_NAMESPACE .. "_GroupUpdate", EVENT_GROUP_UPDATE, function()
        PCAGC:OnGroupUpdate()
    end)

end

function PCAGC:UnloadCoralAerieRuntime()
    if not self.runtimeLoaded then return end

    self:UnregisterMechanicEvents()
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_GroupUpdate", EVENT_GROUP_UPDATE)

    self:LogInfo("Coral Aerie runtime unloaded")
    self:ClearVarallionWorldMarkers()
    self.runtimeLoaded = false
    self.currentBossKey = ""
    self.varallionSeen = false
    self.combatStartMs = nil
    self:ResetMaligaligState()
    self:ResetSarydilState()
    self:ResetEncounter()
    self:HideBossAlerts()
end

function PCAGC:CheckCoralAerieRuntime()
    -- Load encounter listeners only in Coral Aerie.
    if CurrentWorldZoneId() == CORAL_AERIE_ZONE_ID then
        self:LoadCoralAerieRuntime()
    else
        self:UnloadCoralAerieRuntime()
    end
end

function PCAGC:OnCombatState(inCombat)
    self:LogDebug("EVENT_PLAYER_COMBAT_STATE inCombat=%s", tostring(inCombat))
    self:CheckCoralAerieRuntime()

    if inCombat == self.inCombat then return end
    self.inCombat = inCombat

    if not inCombat then
        if self.encounterActive then self:ResetEncounter() end
        self:ResetMaligaligState()
        self:ResetSarydilState()
        self:HideBossAlerts()
        self.combatStartMs = nil
        self:SetBossContext("", "combat-end")
        return
    end

    if not self.runtimeLoaded then return end

    self.combatStartMs = GetGameTimeMilliseconds()
    self:LogInfo(
        "Coral Aerie combat edge: combatStartMs=%d context=%s",
        self.combatStartMs,
        self.currentBossKey ~= "" and self.currentBossKey or "none"
    )

    self:PrepareEncounterPresentation()

    -- A locale-neutral Varallion combat signal can race slightly ahead of this
    -- callback. If it already established context, retain this fresh combat edge
    -- as the +36-second anchor instead of shifting timing to the signal itself.
    if self.currentBossKey == VARALLION_KEY then
        if not self.encounterActive then self:StartInitialPrediction() end
    elseif self.currentBossKey == MALIGALIG_KEY then
        self:RefreshMaligaligUI()
    elseif self.currentBossKey == SARYDIL_KEY then
        self:RefreshSarydilRendering()
    end
end

function PCAGC:SetUnlocked(unlocked)
    if unlocked and self.inCombat then return end
    self.unlocked = unlocked
    if not self.ui then return end

    self.ui.window:SetMouseEnabled(unlocked)
    self.ui.window:SetMovable(unlocked)

    if unlocked then
        -- Keep the mover text-only; live encounter rendering resumes after locking.
        self:ShowMovePreview()
    else
        self.ui.mark:SetHidden(true)
        self.ui.linkHeader:SetHidden(true)
        self.ui.linkNames:SetHidden(true)

        if self.encounterActive then
            self:EnsureUpdate()
            self:OnUpdate()
        elseif self.previewMode ~= "OFF" then
            self:ShowPreview(self.previewMode)
        end
    end
end

function PCAGC:ResetPosition()
    self.saved.offsetX = nil
    self.saved.offsetY = nil
    self:RestorePosition()
end

function PCAGC:ShowPreview(mode)
    if not self.ui or self.encounterActive then return end

    self.ui.mark:SetHidden(true)
    self.ui.linkHeader:SetHidden(true)
    self.ui.linkNames:SetHidden(true)

    if mode == "MARK" then
        self.ui.mark:SetText("Mark of the Sea: 20s")
        self.ui.mark:SetHidden(false)
    elseif mode == "MIND_LINK" then
        self.ui.linkHeader:SetText("Mind Link")
        self.ui.linkHeader:SetHidden(false)
        self.ui.linkNames:SetText("@PlayerOne -> @PlayerTwo")
        self.ui.linkNames:SetHidden(false)
    elseif mode == "TETHER" then
        self.ui.linkHeader:SetText("Tether: 25s")
        self.ui.linkHeader:SetHidden(false)
        self.ui.linkNames:SetText("@PlayerOne -> @PlayerTwo")
        self.ui.linkNames:SetHidden(false)
    end
    self:EnsureNotificationSurface()
end

function PCAGC:SetPreviewMode(mode)
    self.previewMode = mode or "OFF"
    if self.previewMode == "OFF" then
        if self.unlocked then
            -- The mover must never become invisible while unlocked.
            self:ShowMovePreview()
        elseif not self.encounterActive and self.ui then
            self.ui.mark:SetHidden(true)
            self.ui.linkHeader:SetHidden(true)
            self.ui.linkNames:SetHidden(true)
        end
        return
    end

    self:ShowPreview(self.previewMode)
end

function PCAGC:RefreshPreview()
    if self.encounterActive then return end
    if self.previewMode ~= "OFF" then
        self:ShowPreview(self.previewMode)
    elseif self.unlocked then
        self:ShowMovePreview()
    end
end


---------------------------------------------------------------------
-- LIBADDONMENU SETTINGS
---------------------------------------------------------------------
function PCAGC:RegisterSettings()
    -- LibAddonMenu-2.0 is a versioned hard dependency in the manifest. Use its
    -- documented API directly so packaging/dependency errors remain visible.
    local LAM = LibAddonMenu2

    local panelId = LAM_PANEL_ID
    local panelData = {
        type = "panel",
        name = DISPLAY_NAME,
        displayName = DISPLAY_NAME,
        author = "thepandalore",
        version = VERSION,
        keywords = "Coral Aerie Maligalig Sarydil Varallion purge Pinpoint Mark Mind Link Tether",
        slashCommand = "/pcagc",
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            PCAGC.previewMode = "OFF"
            PCAGC:SetUnlocked(false)
            PCAGC:ResetPosition()
            PCAGC:ApplyPresentation()
            PCAGC:RefreshActiveArrows()
            PCAGC:RefreshVarallionWorldMarkers()
        end,
    }

    self.settingsPanel = LAM:RegisterAddonPanel(panelId, panelData)
    if not self.settingsPanel then
        error("LibAddonMenu RegisterAddonPanel returned nil for " .. tostring(panelId))
    end

    local options = {
        {
            type = "description",
            text = "Boss-specific Coral Aerie alerts for Maligalig, Sarydil, and Varallion. Intended for use alongside Pandalore's Coral Aerie Guide.",
            width = "full",
        },
        {
            type = "header",
            name = "Position and Preview",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Unlock notification position",
            tooltip = "Shows a movable preview. Drag it to the desired location, then turn this option off to lock it.",
            getFunc = function() return PCAGC.unlocked end,
            setFunc = function(value) PCAGC:SetUnlocked(value) end,
            disabled = function() return PCAGC.inCombat end,
            default = false,
            width = "full",
        },
        {
            type = "button",
            name = "Reset position",
            tooltip = "Return the notification anchor to its default centered position in the upper third of the screen.",
            func = function() PCAGC:ResetPosition() end,
            disabled = function() return PCAGC.inCombat end,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Preview notification",
            tooltip = "Preview each text state outside combat while adjusting appearance.",
            choices = {"Off", "Mark of the Sea", "Mind Link", "Tether"},
            choicesValues = {"OFF", "MARK", "MIND_LINK", "TETHER"},
            getFunc = function() return PCAGC.previewMode end,
            setFunc = function(value) PCAGC:SetPreviewMode(value) end,
            disabled = function() return PCAGC.inCombat end,
            default = "OFF",
            width = "full",
        },
        {
            type = "header",
            name = "Text Layout",
            width = "full",
        },
        {
            type = "slider",
            name = "Notification area width",
            tooltip = "Width of the text alignment/wrapping area as a percentage of screen width.",
            min = 15,
            max = 50,
            step = 1,
            getFunc = function() return PCAGC.saved.widthPercent end,
            setFunc = function(value)
                PCAGC.saved.widthPercent = value
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = DEFAULTS.widthPercent,
            width = "half",
        },
        {
            type = "dropdown",
            name = "Text alignment",
            choices = {"Left", "Center", "Right"},
            choicesValues = {"LEFT", "CENTER", "RIGHT"},
            getFunc = function() return PCAGC.saved.justification end,
            setFunc = function(value)
                PCAGC.saved.justification = value
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = DEFAULTS.justification,
            width = "half",
        },
        {
            type = "header",
            name = "Maligalig",
            width = "full",
        },
        {
            type = "slider",
            name = "LEAVE NOW stack threshold",
            tooltip = "Show LEAVE NOW when the local player's Building Static reaches this visible stack count. Default 6 matches the companion's current recommended leave cue; adjust it for your group strategy.",
            min = 1,
            max = 15,
            step = 1,
            getFunc = function() return PCAGC.saved.maligaligLeaveStacks end,
            setFunc = function(value)
                PCAGC.saved.maligaligLeaveStacks = value
                PCAGC:RefreshMaligaligUI()
            end,
            default = DEFAULTS.maligaligLeaveStacks,
            width = "full",
        },
        {
            type = "header",
            name = "Sarydil - Healer UI",
            width = "full",
        },
        {
            type = "description",
            text = "Purge and Pinpoint assistance renders only when your selected group role is Healer. PURGE is yellow; Healcheck and the Pinpoint chevron are red.",
            width = "full",
        },
        {
            type = "slider",
            name = "Purge chevron scale",
            min = 0.40,
            max = 1.50,
            step = 0.05,
            decimals = 2,
            getFunc = function() return PCAGC.saved.sarydilPurgeArrowSpaceSize end,
            setFunc = function(value)
                PCAGC.saved.sarydilPurgeArrowSpaceSize = value
                PCAGC:RemoveAllSarydilPurgeArrows()
                PCAGC:RefreshSarydilRendering()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = DEFAULTS.sarydilPurgeArrowSpaceSize,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Purge chevron color",
            getFunc = function()
                local c = PCAGC.saved.sarydilPurgeArrowColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.sarydilPurgeArrowColor = {r = r, g = g, b = b, a = a or 1}
                PCAGC:RemoveAllSarydilPurgeArrows()
                PCAGC:RefreshSarydilRendering()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = ColorDefault(DEFAULTS.sarydilPurgeArrowColor),
            width = "half",
        },
        {
            type = "slider",
            name = "Pinpoint chevron scale",
            min = 0.40,
            max = 1.50,
            step = 0.05,
            decimals = 2,
            getFunc = function() return PCAGC.saved.sarydilPinpointArrowSpaceSize end,
            setFunc = function(value)
                PCAGC.saved.sarydilPinpointArrowSpaceSize = value
                PCAGC:RemoveSarydilPinpointArrow()
                PCAGC:RefreshSarydilRendering()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = DEFAULTS.sarydilPinpointArrowSpaceSize,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Pinpoint chevron color",
            getFunc = function()
                local c = PCAGC.saved.sarydilPinpointArrowColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.sarydilPinpointArrowColor = {r = r, g = g, b = b, a = a or 1}
                PCAGC:RemoveSarydilPinpointArrow()
                PCAGC:RefreshSarydilRendering()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = ColorDefault(DEFAULTS.sarydilPinpointArrowColor),
            width = "half",
        },
        {
            type = "checkbox",
            name = "Humorous healer text",
            tooltip = "Show the small 'well look who's dying again!' line beneath Healcheck. Functional Pinpoint warnings are unaffected.",
            getFunc = function() return PCAGC.saved.sarydilHumorEnabled end,
            setFunc = function(value)
                PCAGC.saved.sarydilHumorEnabled = value
                PCAGC:RefreshSarydilRendering()
            end,
            default = DEFAULTS.sarydilHumorEnabled,
            width = "full",
        },
        {
            type = "header",
            name = "Varallion - World Markers",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show wave safe zones",
            tooltip = "Draw four circular floor markers at the configured Varallion wave-safe positions.",
            getFunc = function() return PCAGC.saved.varallionSafeZonesEnabled end,
            setFunc = function(value)
                PCAGC.saved.varallionSafeZonesEnabled = value
                PCAGC:RefreshVarallionSafeZones()
            end,
            default = DEFAULTS.varallionSafeZonesEnabled,
            width = "full",
        },
        {
            type = "slider",
            name = "Safe-zone circle radius",
            min = 0.50,
            max = 2.50,
            step = 0.10,
            decimals = 1,
            getFunc = function() return PCAGC.saved.varallionSafeZoneRadius end,
            setFunc = function(value)
                PCAGC.saved.varallionSafeZoneRadius = value
                PCAGC:RefreshVarallionSafeZones()
            end,
            disabled = function() return not PCAGC.saved.varallionSafeZonesEnabled end,
            default = DEFAULTS.varallionSafeZoneRadius,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Safe-zone circle color",
            getFunc = function()
                local c = PCAGC.saved.varallionSafeZoneColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.varallionSafeZoneColor = {r = r, g = g, b = b, a = a or 1}
                PCAGC:RefreshVarallionSafeZones()
            end,
            disabled = function() return not PCAGC.saved.varallionSafeZonesEnabled end,
            default = {r = DEFAULTS.varallionSafeZoneColor.r, g = DEFAULTS.varallionSafeZoneColor.g, b = DEFAULTS.varallionSafeZoneColor.b, a = DEFAULTS.varallionSafeZoneColor.a},
            width = "half",
        },
        {
            type = "header",
            name = "Mark of the Sea",
            width = "full",
        },
        {
            type = "slider",
            name = "Mark font size",
            min = 18,
            max = 60,
            step = 1,
            getFunc = function() return PCAGC.saved.markFontSize end,
            setFunc = function(value)
                PCAGC.saved.markFontSize = value
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = DEFAULTS.markFontSize,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Mark color",
            getFunc = function()
                local c = PCAGC.saved.markColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.markColor = {r = r, g = g, b = b, a = 1}
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = ColorDefault(DEFAULTS.markColor),
            width = "half",
        },
        {
            type = "header",
            name = "Mind Link and Tether",
            width = "full",
        },
        {
            type = "slider",
            name = "Header font size",
            min = 18,
            max = 60,
            step = 1,
            getFunc = function() return PCAGC.saved.linkHeaderFontSize end,
            setFunc = function(value)
                PCAGC.saved.linkHeaderFontSize = value
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = DEFAULTS.linkHeaderFontSize,
            width = "half",
        },
        {
            type = "slider",
            name = "Player-name font size",
            min = 16,
            max = 54,
            step = 1,
            getFunc = function() return PCAGC.saved.linkNamesFontSize end,
            setFunc = function(value)
                PCAGC.saved.linkNamesFontSize = value
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = DEFAULTS.linkNamesFontSize,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Mind Link / Tether color",
            getFunc = function()
                local c = PCAGC.saved.linkColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.linkColor = {r = r, g = g, b = b, a = 1}
                PCAGC:ApplyPresentation()
                PCAGC:RefreshPreview()
            end,
            default = ColorDefault(DEFAULTS.linkColor),
            width = "half",
        },
        {
            type = "header",
            name = "Overhead Arrows",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show overhead arrows",
            tooltip = "Use CrutchAlerts attached icons to mark Mind Link endpoints.",
            getFunc = function() return PCAGC.saved.arrowsEnabled end,
            setFunc = function(value)
                PCAGC.saved.arrowsEnabled = value
                PCAGC:RefreshActiveArrows()
                PCAGC:RefreshSarydilRendering()
            end,
            default = DEFAULTS.arrowsEnabled,
            width = "full",
        },
        {
            type = "slider",
            name = "Arrow scale",
            tooltip = "Rendered Space API scale for the attached chevron marker.",
            min = 0.40,
            max = 1.50,
            step = 0.05,
            decimals = 2,
            getFunc = function() return PCAGC.saved.arrowSpaceSize end,
            setFunc = function(value)
                PCAGC.saved.arrowSpaceSize = value
                PCAGC:RefreshActiveArrows()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = DEFAULTS.arrowSpaceSize,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Arrow color",
            getFunc = function()
                local c = PCAGC.saved.arrowColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.arrowColor = {r = r, g = g, b = b, a = a or 1}
                PCAGC:RefreshActiveArrows()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = ColorDefault(DEFAULTS.arrowColor),
            width = "half",
        },
        {
            type = "header",
            name = "Mind Link Predictor Arrows",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Mind Link target predictor",
            tooltip = "Opt-in toggle for predictive chevrons based on cumulative minimum path distance preceding the Mind Link selection event. This is separate from authoritative Mind Link arrows. Enabling takes effect with the next prediction window. Null path accumulation persists through death, and untimely resurrections may present an appearance of faulty logic. All-player comparable path accumulation may also present an appearance of faulty logic.",
            getFunc = function() return PCAGC.saved.predictorEnabled end,
            setFunc = function(value)
                PCAGC.saved.predictorEnabled = value == true
                if not PCAGC.saved.predictorEnabled then
                    PCAGC:StopPathTracking()
                end
                PCAGC:RefreshPredictionArrowAppearance()
            end,
            default = DEFAULTS.predictorEnabled,
            width = "full",
        },
        {
            type = "slider",
            name = "Predictor arrow scale",
            tooltip = "Rendered scale for the path-distance prediction chevrons. This does not change the real Mind Link arrows.",
            min = 0.40,
            max = 1.50,
            step = 0.05,
            decimals = 2,
            getFunc = function() return PCAGC.saved.predictorArrowSpaceSize end,
            setFunc = function(value)
                PCAGC.saved.predictorArrowSpaceSize = value
                PCAGC:RefreshPredictionArrowAppearance()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled or not PCAGC.saved.predictorEnabled end,
            default = DEFAULTS.predictorArrowSpaceSize,
            width = "half",
        },
        {
            type = "colorpicker",
            name = "Predictor arrow color",
            tooltip = "Color for the experimental least-path prediction chevrons only.",
            getFunc = function()
                local c = PCAGC.saved.predictorArrowColor
                return c.r, c.g, c.b, c.a
            end,
            setFunc = function(r, g, b, a)
                PCAGC.saved.predictorArrowColor = {r = r, g = g, b = b, a = a or 1}
                PCAGC:RefreshPredictionArrowAppearance()
            end,
            disabled = function() return not PCAGC.saved.arrowsEnabled or not PCAGC.saved.predictorEnabled end,
            default = ColorDefault(DEFAULTS.predictorArrowColor),
            width = "half",
        },
    }

    if type(self.ExtendSettingsOptions) == "function" then
        self:ExtendSettingsOptions(options)
    end

    LAM:RegisterOptionControls(panelId, options)
end

---------------------------------------------------------------------
-- INITIALIZATION
---------------------------------------------------------------------

local SAVED_VARIABLES_NAME = "PandaloresCoralAerieGuideCompanionSaved"
local function FiniteNumber(value)
    local number = tonumber(value)
    if not number or number ~= number or number == math.huge or number == -math.huge then return nil end
    return number
end

local function ClampNumber(value, minimum, maximum, fallback)
    local number = FiniteNumber(value)
    if not number then number = fallback end
    if number < minimum then return minimum end
    if number > maximum then return maximum end
    return number
end

local function NormalizeBoolean(value, fallback)
    if type(value) == "boolean" then return value end
    return fallback
end

local function NormalizeColor(value, fallback, forceOpaque)
    local source = type(value) == "table" and value or {}
    local color = {
        r = ClampNumber(source.r, 0, 1, fallback.r),
        g = ClampNumber(source.g, 0, 1, fallback.g),
        b = ClampNumber(source.b, 0, 1, fallback.b),
        a = forceOpaque and 1 or ClampNumber(source.a, 0, 1, fallback.a),
    }
    return color
end

function PCAGC:NormalizeSavedVariables()
    local saved = self.saved
    if not saved then return end

    local offsetX = FiniteNumber(saved.offsetX)
    local offsetY = FiniteNumber(saved.offsetY)
    if offsetX and offsetY then
        saved.offsetX, saved.offsetY = offsetX, offsetY
    else
        saved.offsetX, saved.offsetY = nil, nil
    end

    saved.widthPercent = ClampNumber(saved.widthPercent, 15, 50, DEFAULTS.widthPercent)
    saved.justification = ALIGNMENT_VALUES[saved.justification] and saved.justification or DEFAULTS.justification
    saved.markFontSize = math.floor(ClampNumber(saved.markFontSize, 18, 60, DEFAULTS.markFontSize) + 0.5)
    saved.linkHeaderFontSize = math.floor(ClampNumber(saved.linkHeaderFontSize, 18, 60, DEFAULTS.linkHeaderFontSize) + 0.5)
    saved.linkNamesFontSize = math.floor(ClampNumber(saved.linkNamesFontSize, 16, 54, DEFAULTS.linkNamesFontSize) + 0.5)

    saved.markColor = NormalizeColor(saved.markColor, DEFAULTS.markColor, true)
    saved.linkColor = NormalizeColor(saved.linkColor, DEFAULTS.linkColor, true)
    saved.arrowColor = NormalizeColor(saved.arrowColor, DEFAULTS.arrowColor, false)
    saved.predictorArrowColor = NormalizeColor(saved.predictorArrowColor, DEFAULTS.predictorArrowColor, false)
    saved.sarydilPurgeArrowColor = NormalizeColor(saved.sarydilPurgeArrowColor, DEFAULTS.sarydilPurgeArrowColor, false)
    saved.sarydilPinpointArrowColor = NormalizeColor(saved.sarydilPinpointArrowColor, DEFAULTS.sarydilPinpointArrowColor, false)
    saved.varallionSafeZoneColor = NormalizeColor(saved.varallionSafeZoneColor, DEFAULTS.varallionSafeZoneColor, false)

    saved.arrowsEnabled = NormalizeBoolean(saved.arrowsEnabled, DEFAULTS.arrowsEnabled)
    saved.predictorEnabled = NormalizeBoolean(saved.predictorEnabled, DEFAULTS.predictorEnabled)
    saved.sarydilHumorEnabled = NormalizeBoolean(saved.sarydilHumorEnabled, DEFAULTS.sarydilHumorEnabled)
    saved.varallionSafeZonesEnabled = NormalizeBoolean(saved.varallionSafeZonesEnabled, DEFAULTS.varallionSafeZonesEnabled)
    saved.schemaVersion = 1

    saved.arrowSpaceSize = ClampNumber(saved.arrowSpaceSize, 0.40, 1.50, DEFAULTS.arrowSpaceSize)
    saved.predictorArrowSpaceSize = ClampNumber(saved.predictorArrowSpaceSize, 0.40, 1.50, DEFAULTS.predictorArrowSpaceSize)
    saved.sarydilPurgeArrowSpaceSize = ClampNumber(saved.sarydilPurgeArrowSpaceSize, 0.40, 1.50, DEFAULTS.sarydilPurgeArrowSpaceSize)
    saved.sarydilPinpointArrowSpaceSize = ClampNumber(saved.sarydilPinpointArrowSpaceSize, 0.40, 1.50, DEFAULTS.sarydilPinpointArrowSpaceSize)
    saved.maligaligLeaveStacks = math.floor(ClampNumber(saved.maligaligLeaveStacks, 1, 15, DEFAULTS.maligaligLeaveStacks) + 0.5)
    saved.varallionSafeZoneRadius = ClampNumber(saved.varallionSafeZoneRadius, 0.50, 2.50, DEFAULTS.varallionSafeZoneRadius)
end

function PCAGC:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, 1, nil, DEFAULTS)
    self:NormalizeSavedVariables()
    self:ValidateDependencyContracts()
    self:InitializeLogger()
    self:LogInfo("Initializing %s version %s", ADDON_NAME, VERSION)

    self:CreateUI()
    self:RegisterSettings()

    self.inCombat = IsUnitInCombat("player")
    self.runtimeLoaded = false
    self.currentBossKey = ""
    self.varallionSeen = false
    self.combatStartMs = nil
    self.staticStacks = 0
    self.purgeTargets = {}
    self.pinpointEffects = {}
    self.pinpointSequence = 0
    self.pinpointTarget = nil


    EM:RegisterForEvent(EVENT_NAMESPACE .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        PCAGC:CheckCoralAerieRuntime()
    end)

    EM:RegisterForEvent(EVENT_NAMESPACE .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        PCAGC:OnCombatState(inCombat)
    end)

    local roleNamespace = EVENT_NAMESPACE .. "_RoleChanged"
    EM:RegisterForEvent(roleNamespace, EVENT_GROUP_MEMBER_ROLE_CHANGED, function()
        PCAGC:RefreshSarydilRendering()
    end)
    EM:AddFilterForEvent(roleNamespace, EVENT_GROUP_MEMBER_ROLE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    self:CheckCoralAerieRuntime()


    self.initialized = true
    self:LogInfo("Initialization complete; hard dependency contracts validated; LibDebugLogger=%s", tostring(self.hasDebugLogger))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    PCAGC:Initialize()
end

-- SavedVariables and all core initialization run once, directly from the
-- add-on-loaded lifecycle required by ZO_SavedVars. No activation retry masks
-- partial initialization or programming errors.
EM:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
