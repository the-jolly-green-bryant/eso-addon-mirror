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
--   LibDebugLogger     - optional structured diagnostics / caught-error logging
--
-- No encounter telemetry is persisted. SavedVariables contain presentation
-- settings and UI position only.

local ADDON_NAME = "PandaloresCoralAerieGuideCompanion"
local DISPLAY_NAME = "Pandalore's Coral Aerie Guide Companion"
local VERSION = "1.0.0"
local LAM_PANEL_ID = "PCAGCOptions"
local EVENT_NAMESPACE = "PCAGC"
local UI_NAMESPACE = "PCAGC"

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

-- Lightweight bootstrap sentinels for diagnosing load failures without logs.
_G.PCAGC_BOOTSTRAP_LOADED = true
_G.PCAGC_INITIALIZED = false
_G.PCAGC_BOOTSTRAP_ERROR = nil

local PCAGC = {
    inCombat = false,
    runtimeLoaded = false,
    combatStartMs = nil,
    encounterActive = false,
    varallionSeen = false,
    currentBossName = "",
    lastBoss1Name = "",
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
    tetherDeadlineMs = nil,

    arrows = {},

    -- Experimental movement-ranking predictor. The first selection window runs
    -- from the confirmed Varallion combat start to the first authoritative
    -- 149224 ACTION_RESULT_BEGIN. Later windows run from final Mind Link tether
    -- fade to the next 149224 BEGIN. Distances are accumulated from successive
    -- GetUnitWorldPosition samples and are never persisted.
    pathTrackingActive = false,
    pathSamples = {},
    predictionArrows = {},

    -- Maligalig Building Static is local-player state. Branddi's combat-event
    -- stream includes an initial gain before the visible stack count, so the
    -- displayed/threshold count is max(raw - 1, 0).
    staticStacksRaw = 0,
    staticStacks = 0,

    -- Sarydil state is tracked for the whole group but rendered only on the
    -- local healer UI. Purge targets retain per-ability membership so one fade
    -- cannot clear a target that still has the other purgeable effect.
    purgeTargets = {},
    pinpointTarget = nil,
    sarydilPurgeArrows = {},
    sarydilPinpointArrow = nil,

    -- Varallion world markers use fixed safe-zone coordinates only.
    safeZoneMarkerKeys = {},

    -- Ephemeral runtime diagnostics. Nothing here is written to SavedVariables.
    lastTrackedEvent = "none",
    lastRuntimeError = "none",

    -- Optional LibDebugLogger state. The per-addon debug override is deliberately
    -- session-only and is never persisted in PandaloresCoralAerieGuideCompanionSaved.
    logger = nil,
    loggerApiVersion = 0,
    hasDebugLogger = false,

    -- Populated during initialization so dependency/API mismatches degrade
    -- cleanly instead of surfacing in the middle of a mechanic.
    hasLibUnits = false,
    hasCrutchAttachedIcons = false,
    hasCrutchRemoveAll = false,
    hasCrutchWorldDrawing = false,
}

---------------------------------------------------------------------
-- FIXED MECHANIC CONFIGURATION
---------------------------------------------------------------------
-- Encounter timing is deliberately not user-adjustable. Keeping these values
-- fixed preserves the research premise and Branddi-derived timing anchors.
local CONFIG = {
    FIRST_MARK_SECONDS = 39,       -- combat start + 39 seconds (Coral Aerie Helper Varallion anchor)
    FIRST_VISIBLE_SECONDS = 20,    -- first countdown appears for its final 20 seconds
    NEXT_MARK_SECONDS = 20,        -- last beam fade + 20 seconds (Coral Aerie Helper beam-fade anchor)
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

    -- Experimental path predictor appearance is intentionally independent
    -- from the authoritative Mind Link arrows.
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

    legacyMigrationComplete = false,
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
local MALIGALIG_NAME = "maligalig"
local SARYDIL_NAME = "sarydil"
local VARALLION_NAME = "varallion"

local IDS = {
    -- Maligalig
    BUILDING_STATIC = 162279,

    -- Sarydil
    PINPOINT_A = 167569,
    PINPOINT_B = 158201,
    PURGE_IGNITE = 168776,
    PURGE_APERTURE = 168897,

    -- Varallion
    MARK_CAST = 149224,
    LINK_A = 149225,
    LINK_B = 149227,
    BEAM_A = 167437,
    BEAM_B = 167462,

}


-- Branddi / Coral Aerie Helper verified these four fixed safe positions.
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

local function IsVarallionAbility(abilityId)
    return abilityId == IDS.MARK_CAST
        or abilityId == IDS.LINK_A
        or abilityId == IDS.LINK_B
        or abilityId == IDS.BEAM_A
        or abilityId == IDS.BEAM_B
end

local function IsSarydilAbility(abilityId)
    return abilityId == IDS.PINPOINT_A
        or abilityId == IDS.PINPOINT_B
        or abilityId == IDS.PURGE_IGNITE
        or abilityId == IDS.PURGE_APERTURE
end

local function IsSupportedBossName(bossName)
    return bossName == MALIGALIG_NAME
        or bossName == SARYDIL_NAME
        or bossName == VARALLION_NAME
end

---------------------------------------------------------------------
-- SMALL HELPERS
---------------------------------------------------------------------
local function Msg(text)
    local message = string.format("|c4FD9D9[CAGC]|r %s", tostring(text))
    if CHAT_SYSTEM and type(CHAT_SYSTEM.AddMessage) == "function" then
        CHAT_SYSTEM:AddMessage(message)
        return true
    end
    if type(d) == "function" then
        d(message)
        return true
    end
    return false
end

-- LibDebugLogger is optional; logging degrades to no-ops when unavailable.
local function SafeLoggerCall(methodName, ...)
    local logger = PCAGC.logger
    if not logger then return false end
    local method = logger[methodName]
    if type(method) ~= "function" then return false end
    local ok = pcall(method, logger, ...)
    return ok
end

function PCAGC:LogDebug(...)
    SafeLoggerCall("Debug", ...)
end

function PCAGC:LogInfo(...)
    SafeLoggerCall("Info", ...)
end

function PCAGC:LogWarn(...)
    SafeLoggerCall("Warn", ...)
end

function PCAGC:LogError(...)
    SafeLoggerCall("Error", ...)
end

function PCAGC:ReportCaughtError(context, err)
    self.lastRuntimeError = string.format("%s: %s", tostring(context), tostring(err))
    self:LogError("%s failed: %s", tostring(context), tostring(err))
end

function PCAGC:InitializeLogger()
    if type(LibDebugLogger) ~= "table" or type(LibDebugLogger.Create) ~= "function" then
        self.hasDebugLogger = false
        return
    end

    local ok, loggerOrErr = pcall(LibDebugLogger.Create, LibDebugLogger, ADDON_NAME)
    if not ok or not loggerOrErr then
        self.hasDebugLogger = false
        self.lastRuntimeError = string.format("LibDebugLogger.Create: %s", tostring(loggerOrErr))
        return
    end

    self.logger = loggerOrErr
    self.hasDebugLogger = true

    if type(LibDebugLogger.GetAPIVersion) == "function" then
        local apiOk, apiVersion = pcall(LibDebugLogger.GetAPIVersion)
        if apiOk and tonumber(apiVersion) then
            self.loggerApiVersion = tonumber(apiVersion)
        end
    end
end

function PCAGC:RefreshLibUnits(context)
    if not self.hasLibUnits or type(LibUnits2) ~= "table" or type(LibUnits2.RefreshUnits) ~= "function" then return false end
    local ok, err = pcall(LibUnits2.RefreshUnits)
    if not ok then
        self:ReportCaughtError(context or "LibUnits2.RefreshUnits", err)
        return false
    end
    return true
end

local function IsEffectGain(result)
    return result == ACTION_RESULT_EFFECT_GAINED
        or result == ACTION_RESULT_EFFECT_GAINED_DURATION
end

local function NormalizedName(name)
    return zo_strformat("<<1>>", name or "")
end

local function CurrentZoneId()
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex or zoneIndex <= 0 then return 0 end
    return GetZoneId(zoneIndex) or 0
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

    local rootWidth = GuiRoot:GetWidth() or 1920
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
    if not self.ui then return end
    self.saved.offsetX = self.ui.window:GetLeft()
    self.saved.offsetY = self.ui.window:GetTop()
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
    local role = nil
    if type(GetGroupMemberSelectedRole) == "function" then
        role = GetGroupMemberSelectedRole("player")
    end
    if (not role or role == LFG_ROLE_INVALID) and type(GetSelectedLFGRole) == "function" then
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
    -- the underlying mechanic state.
    if self.unlocked then return end

    if not self.runtimeLoaded or not self.encounterActive then return end

    -- Movement ranking is sampled on the same 100 ms update cadence as the
    -- mechanic UI. The first window begins at Varallion combat start; later
    -- windows begin at final tether fade. Every window ends at authoritative
    -- 149224 ACTION_RESULT_BEGIN.
    self:UpdatePathTracking()

    -- Presentation is reconstructed from authoritative runtime state every
    -- update. No prior Hide()/Show() call is trusted to remain correct.
    if self.beamAActive or self.beamBActive then
        if self.tetherDeadlineMs then
            self:ShowTether(SecondsCeil(self.tetherDeadlineMs - nowMs))
        else
            self:ShowTether(0)
        end
        return
    end

    if self.targetA or self.targetB then
        self:ShowMindLink()
        return
    end

    if self.markNowUntilMs then
        if nowMs < self.markNowUntilMs then
            self:HideLinkUI()
            self:RenderMarkNow()
            return
        end
        self.markNowUntilMs = nil
    end

    if self.nextMarkDeadlineMs then
        local remainingMs = self.nextMarkDeadlineMs - nowMs
        if remainingMs > 0 then
            local visibleLimitMs = CONFIG.FIRST_VISIBLE_SECONDS * 1000
            if remainingMs <= visibleLimitMs then
                self:HideLinkUI()
                self:ShowMarkCountdown(SecondsCeil(remainingMs))
            else
                self:HideMark()
                self:HideLinkUI()
            end
        else
            -- The countdown is a forecast. A real 149224 event is the only
            -- thing allowed to display "Now".
            self:HideMark()
            self:HideLinkUI()
        end
        return
    end

    self:HideMark()
    self:HideLinkUI()
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

function PCAGC:ResolveTarget(targetUnitId, targetName, targetType)
    local displayName = ""
    local unitTag = ""

    -- Prefer LibUnits2 lookups, then fall back to a direct group scan if its
    -- unit-ID map does not yet contain this player.
    if self.hasLibUnits then
        local displayOk, displayOrErr = pcall(LibUnits2.GetDisplayNameForUnitId, targetUnitId)
        if displayOk then
            displayName = displayOrErr or ""
        else
            self:ReportCaughtError("LibUnits2.GetDisplayNameForUnitId", displayOrErr)
        end

        local tagOk, tagOrErr = pcall(LibUnits2.GetUnitTagForUnitId, targetUnitId)
        if tagOk then
            unitTag = tagOrErr or ""
        else
            self:ReportCaughtError("LibUnits2.GetUnitTagForUnitId", tagOrErr)
        end
    end

    if targetType == COMBAT_UNIT_TYPE_PLAYER then
        if displayName == "" then displayName = GetUnitDisplayName("player") or "" end
        if unitTag == "" then unitTag = "player" end
    end

    if displayName == "" and unitTag ~= "" then
        displayName = GetUnitDisplayName(unitTag) or ""
    end

    if displayName == "" or unitTag == "" then
        local fallbackDisplay, fallbackTag = FindGroupMemberByName(targetName)
        if displayName == "" then displayName = fallbackDisplay end
        if unitTag == "" then unitTag = fallbackTag end
    end

    -- This should be rare in a four-player dungeon, but the on-screen event
    -- still appears immediately even if the @displayName could not be resolved.
    if displayName == "" then
        displayName = NormalizedName(targetName)
    end
    if displayName == "" then
        displayName = "?"
    end

    if unitTag == "" then
        self:LogWarn("Could not resolve a unit tag for targetUnitId=%s target=%s; text will remain available but the arrow cannot attach", tostring(targetUnitId), tostring(displayName))
    end
    self:LogDebug("Resolved targetUnitId=%s target=%s unitTag=%s", tostring(targetUnitId), tostring(displayName), unitTag ~= "" and unitTag or "none")

    return {
        displayName = displayName,
        unitTag = unitTag,
        unitId = targetUnitId,
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

    if self.hasCrutchAttachedIcons and arrow.unitTag ~= "" then
        local ok, err = pcall(CrutchAlerts.RemoveAttachedIconForUnit, arrow.unitTag, IconNameForSlot(slot))
        if not ok then
            self:ReportCaughtError("CrutchAlerts.RemoveAttachedIconForUnit", err)
        end
    end

    self.arrows[slot] = nil
end

function PCAGC:RemoveAllArrows()
    self:RemoveArrow("A")
    self:RemoveArrow("B")

    -- Unit tags can change during zoning/group changes. Use Crutch's catch-all
    -- cleanup API when the installed version exposes it. Older supported U49
    -- builds can still render/remove per-unit icons without this helper.
    if self.hasCrutchRemoveAll then
        local okA, errA = pcall(CrutchAlerts.RemoveAllAttachedIcons, ICON_NAME_A)
        if not okA then self:ReportCaughtError("CrutchAlerts.RemoveAllAttachedIcons(A)", errA) end
        local okB, errB = pcall(CrutchAlerts.RemoveAllAttachedIcons, ICON_NAME_B)
        if not okB then self:ReportCaughtError("CrutchAlerts.RemoveAllAttachedIcons(B)", errB) end
    end
end

function PCAGC:ShowArrow(slot, target)
    self:RemoveArrow(slot)

    if not self.saved.arrowsEnabled then return end

    -- CrutchAlerts is the only renderer. Force its modern Space API path.
    -- If unit-tag resolution fails, the text notification still functions and
    -- no renderer fallback is attempted.
    if not self.hasCrutchAttachedIcons or target.unitTag == "" then return end

    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.arrowSpaceSize,
            color = ColorAsArray(self.saved.arrowColor),
        },
    }

    local ok, err = pcall(
        CrutchAlerts.SetAttachedIconForUnit,
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

    if ok then
        self.arrows[slot] = {
            unitTag = target.unitTag,
        }
        self:LogDebug("Attached Mind Link arrow %s to %s", tostring(slot), tostring(target.unitTag))
    else
        self:ReportCaughtError("CrutchAlerts.SetAttachedIconForUnit", err)
    end
end

function PCAGC:RefreshActiveArrows()
    self:RemoveAllArrows()
    if not self.saved.arrowsEnabled then
        self:RemoveAllPredictionArrows()
        return
    end

    if self.targetA then self:ShowArrow("A", self.targetA) end
    if self.targetB then self:ShowArrow("B", self.targetB) end

    if self.pathTrackingActive then
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

    if self.hasCrutchAttachedIcons and arrow.unitTag ~= "" then
        local ok, err = pcall(
            CrutchAlerts.RemoveAttachedIconForUnit,
            arrow.unitTag,
            PredictionIconNameForSlot(slot)
        )
        if not ok then
            self:ReportCaughtError("CrutchAlerts.RemoveAttachedIconForUnit(path prediction)", err)
        end
    end

    self.predictionArrows[slot] = nil
end

function PCAGC:RemoveAllPredictionArrows()
    self:RemovePredictionArrow("A")
    self:RemovePredictionArrow("B")

    if self.hasCrutchRemoveAll then
        local okA, errA = pcall(CrutchAlerts.RemoveAllAttachedIcons, PREDICTION_ICON_NAME_A)
        if not okA then self:ReportCaughtError("CrutchAlerts.RemoveAllAttachedIcons(path A)", errA) end
        local okB, errB = pcall(CrutchAlerts.RemoveAllAttachedIcons, PREDICTION_ICON_NAME_B)
        if not okB then self:ReportCaughtError("CrutchAlerts.RemoveAllAttachedIcons(path B)", errB) end
    end
end

function PCAGC:RefreshPredictionArrowAppearance()
    self:RemoveAllPredictionArrows()
    if self.saved.arrowsEnabled and self.pathTrackingActive then
        self:RefreshPathPredictionArrows()
    end
end

function PCAGC:ShowPredictionArrow(slot, unitTag)
    if not self.saved.arrowsEnabled or not self.hasCrutchAttachedIcons or not unitTag or unitTag == "" then
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

    local ok, err = pcall(
        CrutchAlerts.SetAttachedIconForUnit,
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

    if ok then
        self.predictionArrows[slot] = {unitTag = unitTag}
    else
        self:ReportCaughtError("CrutchAlerts.SetAttachedIconForUnit(path prediction)", err)
    end
end

function PCAGC:GetRankedPathSamples(eligibleOnly)
    local ranked = {}
    for _, sample in pairs(self.pathSamples) do
        if sample.unitTag and sample.unitTag ~= ""
            and (not eligibleOnly or not IsUnitDead(sample.unitTag)) then
            ranked[#ranked + 1] = sample
        end
    end

    table.sort(ranked, function(a, b)
        if a.distanceUnits == b.distanceUnits then
            return (a.order or 999) < (b.order or 999)
        end
        return a.distanceUnits < b.distanceUnits
    end)

    return ranked
end

function PCAGC:RefreshPathPredictionArrows()
    if not self.pathTrackingActive or not self.saved.arrowsEnabled then
        self:RemoveAllPredictionArrows()
        return
    end

    -- Continue accumulating distance for dead players, but only living players
    -- are shown as current Mind Link candidates. A resurrected player therefore
    -- re-enters this ranking with the path score accumulated while dead.
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

function PCAGC:StartPathTracking(nowMs)
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
        if unitTag and unitTag ~= "" then
            local zoneId, x, y, z = GetUnitWorldPosition(unitTag)
            if zoneId and zoneId ~= 0 and x and y and z then
                self.pathSamples[unitTag] = {
                    unitTag = unitTag,
                    displayName = GetUnitDisplayName(unitTag) or unitTag,
                    order = i,
                    zoneId = zoneId,
                    lastX = x,
                    lastY = y,
                    lastZ = z,
                    distanceUnits = 0,
                }
                trackedCount = trackedCount + 1
            end
        end
    end

    self:RefreshPathPredictionArrows()
    self:LogInfo("Path-distance tracking started at %d for %d group members", trackingStartMs, trackedCount)
end

function PCAGC:UpdatePathTracking()
    if not self.pathTrackingActive then return end

    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag and unitTag ~= "" then
            local zoneId, x, y, z = GetUnitWorldPosition(unitTag)
            if zoneId and zoneId ~= 0 and x and y and z then
                local sample = self.pathSamples[unitTag]
                if not sample then
                    sample = {
                        unitTag = unitTag,
                        displayName = GetUnitDisplayName(unitTag) or unitTag,
                        order = i,
                        zoneId = zoneId,
                        lastX = x,
                        lastY = y,
                        lastZ = z,
                        distanceUnits = 0,
                    }
                    self.pathSamples[unitTag] = sample
                elseif sample.zoneId == zoneId then
                    local dx = x - sample.lastX
                    local dy = y - sample.lastY
                    local dz = z - sample.lastZ
                    sample.distanceUnits = sample.distanceUnits + zo_sqrt((dx * dx) + (dy * dy) + (dz * dz))
                    sample.lastX = x
                    sample.lastY = y
                    sample.lastZ = z
                    sample.order = i
                else
                    -- A zone discontinuity is not player travel. Re-anchor the
                    -- sample without adding an artificial teleport distance.
                    sample.zoneId = zoneId
                    sample.lastX = x
                    sample.lastY = y
                    sample.lastZ = z
                    sample.order = i
                end
            end
        end
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
                (sample.distanceUnits or 0) / 100
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
    self.staticStacksRaw = 0
    self.staticStacks = 0
    if self.currentBossName == MALIGALIG_NAME then
        self:HideBossAlerts()
    end
end

function PCAGC:RefreshMaligaligUI()
    if self.currentBossName ~= MALIGALIG_NAME then return end
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
    if not unitTag or unitTag == "" or not self.hasCrutchAttachedIcons then return end
    local ok, err = pcall(CrutchAlerts.RemoveAttachedIconForUnit, unitTag, SARYDIL_PURGE_ICON_NAME)
    if not ok then self:ReportCaughtError("CrutchAlerts.RemoveAttachedIconForUnit(Sarydil purge)", err) end
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
    if self.hasCrutchRemoveAll then
        local ok, err = pcall(CrutchAlerts.RemoveAllAttachedIcons, SARYDIL_PURGE_ICON_NAME)
        if not ok then self:ReportCaughtError("CrutchAlerts.RemoveAllAttachedIcons(Sarydil purge)", err) end
    end
end

function PCAGC:ShowSarydilPurgeArrow(target)
    if not self.saved.arrowsEnabled or not self:IsHealerUI() or not self.hasCrutchAttachedIcons then return end
    if not target or not target.unitTag or target.unitTag == "" then return end

    local color = ColorAsArray(self.saved.sarydilPurgeArrowColor)
    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.sarydilPurgeArrowSpaceSize,
            color = color,
        },
    }
    local ok, err = pcall(
        CrutchAlerts.SetAttachedIconForUnit,
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
    if ok then
        self.sarydilPurgeArrows[target.unitTag] = true
    else
        self:ReportCaughtError("CrutchAlerts.SetAttachedIconForUnit(Sarydil purge)", err)
    end
end

function PCAGC:RemoveSarydilPinpointArrow()
    local arrow = self.sarydilPinpointArrow
    if arrow and arrow.unitTag and arrow.unitTag ~= "" and self.hasCrutchAttachedIcons then
        local ok, err = pcall(CrutchAlerts.RemoveAttachedIconForUnit, arrow.unitTag, SARYDIL_PINPOINT_ICON_NAME)
        if not ok then self:ReportCaughtError("CrutchAlerts.RemoveAttachedIconForUnit(Sarydil Pinpoint)", err) end
    end
    self.sarydilPinpointArrow = nil
    if self.hasCrutchRemoveAll then
        local ok, err = pcall(CrutchAlerts.RemoveAllAttachedIcons, SARYDIL_PINPOINT_ICON_NAME)
        if not ok then self:ReportCaughtError("CrutchAlerts.RemoveAllAttachedIcons(Sarydil Pinpoint)", err) end
    end
end

function PCAGC:ShowSarydilPinpointArrow(target)
    self:RemoveSarydilPinpointArrow()
    if not self.saved.arrowsEnabled or not self:IsHealerUI() or not self.hasCrutchAttachedIcons then return end
    if not target or not target.unitTag or target.unitTag == "" then return end

    local color = ColorAsArray(self.saved.sarydilPinpointArrowColor)
    local spaceOptions = {
        texture = {
            path = CONFIG.ARROW_TEXTURE,
            size = self.saved.sarydilPinpointArrowSpaceSize,
            color = color,
        },
    }
    local ok, err = pcall(
        CrutchAlerts.SetAttachedIconForUnit,
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
    if ok then
        self.sarydilPinpointArrow = {unitTag = target.unitTag}
    else
        self:ReportCaughtError("CrutchAlerts.SetAttachedIconForUnit(Sarydil Pinpoint)", err)
    end
end

function PCAGC:CountPurgeTargets()
    local count = 0
    for _ in pairs(self.purgeTargets) do count = count + 1 end
    return count
end

function PCAGC:RefreshSarydilRendering()
    self:RemoveAllSarydilPurgeArrows()
    self:RemoveSarydilPinpointArrow()

    if self.currentBossName ~= SARYDIL_NAME or not self.inCombat or not self:IsHealerUI() then
        if self.currentBossName == SARYDIL_NAME then self:HideBossAlerts() end
        return
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
        for _, entry in pairs(self.purgeTargets) do
            self:ShowSarydilPurgeArrow(entry.target)
        end
    else
        self.ui.bossAlert:SetHidden(true)
    end

    if detailVisible then
        self.ui.bossDetail:SetText(string.format("Healcheck %s", self.pinpointTarget.displayName or "?"))
        self.ui.bossDetail:SetColor(1.00, 0.12, 0.08, 1.00)
        self.ui.bossDetail:SetHidden(false)
        self:ShowSarydilPinpointArrow(self.pinpointTarget)
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
    self.pinpointTarget = nil
    self:RemoveAllSarydilPurgeArrows()
    self:RemoveSarydilPinpointArrow()
    if self.currentBossName == SARYDIL_NAME then
        self:HideBossAlerts()
    end
end

function PCAGC:PurgeTargetKey(targetUnitId, target)
    if targetUnitId and targetUnitId ~= 0 then return tostring(targetUnitId) end
    if target and target.unitTag and target.unitTag ~= "" then return target.unitTag end
    return target and target.displayName or "unknown"
end

function PCAGC:HandleMaligaligEvent(result, targetType)
    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if IsEffectGain(result) then
        self.staticStacksRaw = self.staticStacksRaw + 1
        self.staticStacks = math.max(0, self.staticStacksRaw - 1)
        self:LogDebug("Maligalig Building Static raw=%d visible=%d", self.staticStacksRaw, self.staticStacks)
        self:RefreshMaligaligUI()
    elseif result == ACTION_RESULT_EFFECT_FADED then
        self.staticStacksRaw = 0
        self.staticStacks = 0
        self:RefreshMaligaligUI()
    end
end

function PCAGC:HandleSarydilPurgeEvent(result, abilityId, targetUnitId, targetName, targetType)
    local target = self:ResolveTarget(targetUnitId, targetName, targetType)
    local key = self:PurgeTargetKey(targetUnitId, target)

    if result == ACTION_RESULT_EFFECT_GAINED_DURATION or result == ACTION_RESULT_EFFECT_GAINED then
        local entry = self.purgeTargets[key]
        if not entry then
            entry = {target = target, effects = {}}
            self.purgeTargets[key] = entry
        else
            entry.target = target
        end
        entry.effects[abilityId] = true
    elseif result == ACTION_RESULT_EFFECT_FADED then
        local entry = self.purgeTargets[key]
        if entry then
            entry.effects[abilityId] = nil
            if not next(entry.effects) then
                if entry.target then self:RemoveSarydilPurgeArrow(entry.target.unitTag) end
                self.purgeTargets[key] = nil
            end
        end
    end

    self:RefreshSarydilRendering()
end

function PCAGC:HandleSarydilPinpointEvent(result, targetUnitId, targetName, targetType)
    if IsEffectGain(result) then
        self.pinpointTarget = self:ResolveTarget(targetUnitId, targetName, targetType)
        self:LogInfo("Sarydil Pinpoint target: %s", tostring(self.pinpointTarget.displayName))
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if not self.pinpointTarget or not targetUnitId or self.pinpointTarget.unitId == targetUnitId then
            self.pinpointTarget = nil
        end
    end
    self:RefreshSarydilRendering()
end


---------------------------------------------------------------------
-- VARALLION WORLD MARKERS
---------------------------------------------------------------------
function PCAGC:RemoveWorldMarkerKey(key, context)
    if not key or not self.hasCrutchWorldDrawing then return end
    local draw = CrutchAlerts and CrutchAlerts.Drawing
    if not draw or type(draw.RemoveWorldTexture) ~= "function" then return end
    local ok, err = pcall(draw.RemoveWorldTexture, key)
    if not ok then self:ReportCaughtError(context or "CrutchAlerts.Drawing.RemoveWorldTexture", err) end
end

function PCAGC:ClearVarallionSafeZones()
    for _, key in ipairs(self.safeZoneMarkerKeys or {}) do
        self:RemoveWorldMarkerKey(key, "remove Varallion safe-zone marker")
    end
    self.safeZoneMarkerKeys = {}
end

function PCAGC:RefreshVarallionSafeZones()
    self:ClearVarallionSafeZones()
    if self.currentBossName ~= VARALLION_NAME then return end
    if not self.saved or not self.saved.varallionSafeZonesEnabled then return end
    if not self.hasCrutchWorldDrawing then return end

    local draw = CrutchAlerts.Drawing
    local color = ColorAsArray(self.saved.varallionSafeZoneColor)
    local radius = tonumber(self.saved.varallionSafeZoneRadius) or DEFAULTS.varallionSafeZoneRadius

    for _, position in ipairs(VARALLION_SAFE_ZONES) do
        local ok, keyOrErr = pcall(
            draw.CreateGroundCircle,
            position.x,
            position.y + 5,
            position.z,
            radius,
            color,
            nil,
            nil,
            false
        )
        if ok and keyOrErr then
            self.safeZoneMarkerKeys[#self.safeZoneMarkerKeys + 1] = keyOrErr
        elseif not ok then
            self:ReportCaughtError("CrutchAlerts.Drawing.CreateGroundCircle(Varallion safe zone)", keyOrErr)
        end
    end
end


function PCAGC:ClearVarallionWorldMarkers()
    self:ClearVarallionSafeZones()
end

function PCAGC:RefreshVarallionWorldMarkers()
    self:RefreshVarallionSafeZones()
end

function PCAGC:SetBossContext(bossName, source)
    bossName = bossName or ""
    if bossName == self.currentBossName then
        self.varallionSeen = bossName == VARALLION_NAME
        return
    end

    local previous = self.currentBossName
    if previous == VARALLION_NAME then
        if self.encounterActive then self:ResetEncounter() end
        self:ClearVarallionWorldMarkers()
    end
    if previous == MALIGALIG_NAME then self:ResetMaligaligState() end
    if previous == SARYDIL_NAME then self:ResetSarydilState() end

    self.currentBossName = bossName
    self.varallionSeen = bossName == VARALLION_NAME
    self:HideBossAlerts()
    if bossName == VARALLION_NAME then self:RefreshVarallionWorldMarkers() end
    self:LogInfo("Boss context: %s -> %s (%s)", previous ~= "" and previous or "none", bossName ~= "" and bossName or "none", source or "unknown")
end

function PCAGC:EnsureBossMechanicContext(bossName)
    if not self.runtimeLoaded or CurrentWorldZoneId() ~= CORAL_AERIE_ZONE_ID then return false end

    -- A recognized boss1 is stronger evidence than a late mechanic event from
    -- the previous encounter. Blank or unrecognized boss1 values still allow
    -- mechanic-based recovery when unit tags are late.
    local explicitBoss = string.lower(NormalizedName(GetUnitName("boss1")))
    if IsSupportedBossName(explicitBoss) and explicitBoss ~= bossName then
        self:LogDebug("Ignored %s mechanic context while boss1 identifies %s", tostring(bossName), tostring(explicitBoss))
        return false
    end

    if self.currentBossName ~= bossName then
        self:SetBossContext(bossName, "mechanic")
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

    -- Boss identity is cached independently; the fresh combat edge owns the
    -- first deadline and is never shifted by a late boss confirmation.
    self.nextMarkDeadlineMs = self.combatStartMs + (CONFIG.FIRST_MARK_SECONDS * 1000)
    self.markNowUntilMs = nil
    self.lastAcceptedMarkMs = nil

    self:ClearLinkState(true)
    self:HideMark()

    self:RefreshLibUnits("LibUnits2.RefreshUnits")

    -- First-cycle path sampling starts at combat; later cycles restart at the
    -- final tether fade. Ability 149224 ends each sampling window.
    self:StartPathTracking(self.combatStartMs)

    self:LogInfo("Initial Mark deadline armed: combatStartMs=%d deadlineMs=%d", self.combatStartMs, self.nextMarkDeadlineMs)
    self:EnsureUpdate()
end

function PCAGC:EnterRecoveryMode()
    if not self.runtimeLoaded then return end

    self:PrepareEncounterPresentation()
    self.encounterActive = true

    -- A mid-combat reload has no trustworthy pull edge. Do not invent one.
    -- The next tracked mechanic event repairs state and the next final beam
    -- fade restores the closed-loop +20s countdown.
    self.nextMarkDeadlineMs = nil
    self.markNowUntilMs = nil
    self.lastAcceptedMarkMs = nil

    self:ClearLinkState(true)
    self:HideMark()

    self:RefreshLibUnits("LibUnits2.RefreshUnits")

    self:LogWarn("Entered mid-combat recovery mode; waiting for authoritative mechanic timing")
    self:EnsureUpdate()
end

function PCAGC:EnsureEncounterFromMechanic()
    -- Varallion mechanics may repair a blank/late boss unit tag, but must not
    -- override an explicit Maligalig or Sarydil boss1 context.
    if not self:EnsureBossMechanicContext(VARALLION_NAME) then
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

        self:RefreshLibUnits("LibUnits2.RefreshUnits")
    end

    self:EnsureUpdate()
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
    -- Late beam-fade events can arrive while a wipe is tearing combat down.
    -- Do not let a fade resurrect a +20s recurrence when both our cached state
    -- and ESO's live player-combat state agree that combat is already over.
    local isBeamFade = (abilityId == IDS.BEAM_A or abilityId == IDS.BEAM_B)
        and result == ACTION_RESULT_EFFECT_FADED
    if isBeamFade and not self.inCombat and not IsUnitInCombat("player") then
        self.lastTrackedEvent = string.format(
            "%d (%s), result=%s, ignored=out-of-combat-fade",
            abilityId or 0,
            NormalizedName(abilityName),
            tostring(result)
        )
        return
    end

    if abilityId == IDS.BUILDING_STATIC then
        if not self:EnsureBossMechanicContext(MALIGALIG_NAME) then return end
        self.lastTrackedEvent = string.format("%d (%s), result=%s", abilityId, NormalizedName(abilityName), tostring(result))
        self:HandleMaligaligEvent(result, targetType)
        return
    end

    if IsSarydilAbility(abilityId) then
        if not self:EnsureBossMechanicContext(SARYDIL_NAME) then return end
        self.lastTrackedEvent = string.format("%d (%s), result=%s, target=%s", abilityId, NormalizedName(abilityName), tostring(result), NormalizedName(targetName))
        if abilityId == IDS.PURGE_IGNITE or abilityId == IDS.PURGE_APERTURE then
            self:HandleSarydilPurgeEvent(result, abilityId, targetUnitId, targetName, targetType)
        else
            self:HandleSarydilPinpointEvent(result, targetUnitId, targetName, targetType)
        end
        return
    end

    if not IsVarallionAbility(abilityId) then return end
    if not self:EnsureEncounterFromMechanic() then return end

    self.lastTrackedEvent = string.format(
        "%d (%s), result=%s, target=%s",
        abilityId or 0,
        NormalizedName(abilityName),
        tostring(result),
        NormalizedName(targetName)
    )
    self:LogDebug("Combat event abilityId=%s ability=%s result=%s target=%s targetUnitId=%s", tostring(abilityId), tostring(NormalizedName(abilityName)), tostring(result), tostring(NormalizedName(targetName)), tostring(targetUnitId))

    local nowMs = GetGameTimeMilliseconds()


    if abilityId == IDS.MARK_CAST then
        -- The defining purpose of this addon is to track the beginning of
        -- ability 149224. Only ACTION_RESULT_BEGIN is authoritative for the
        -- actual Mark-of-the-Sea start; predictions never synthesize "Now".
        if result == ACTION_RESULT_BEGIN and (
            not self.lastAcceptedMarkMs
            or (nowMs - self.lastAcceptedMarkMs) >= CONFIG.MARK_DEBOUNCE_MS
        ) then
            self.lastAcceptedMarkMs = nowMs
            self:LogInfo("149224 ACTION_RESULT_BEGIN accepted as Mark start at %d", nowMs)
            -- End the experimental prediction phase before the real 149225 /
            -- 149227 Mind Link markers can arrive. This deliberately prevents
            -- purple prediction chevrons from overlapping the authoritative
            -- pink mechanic chevrons.
            self:StopPathTracking()
            self:ClearLinkState(true)
            self:BeginMarkNow(nowMs)
        end
        return
    end

    if abilityId == IDS.LINK_A and IsEffectGain(result) then
        if not self.targetA then
            self.targetA = self:ResolveTarget(targetUnitId, targetName, targetType)
            self:LogInfo("Mind Link endpoint A: %s", tostring(self.targetA.displayName))
            -- Text is the primary research cue; render it before asking Crutch
            -- to create the world-space marker.
            self:ShowMindLink()
            self:ShowArrow("A", self.targetA)
        end
        return
    end

    if abilityId == IDS.LINK_B and IsEffectGain(result) then
        if not self.targetB then
            self.targetB = self:ResolveTarget(targetUnitId, targetName, targetType)
            self:LogInfo("Mind Link endpoint B: %s", tostring(self.targetB.displayName))
            self:ShowMindLink()
            self:ShowArrow("B", self.targetB)
        end
        return
    end

    if abilityId == IDS.BEAM_A then
        if IsEffectGain(result) then
            self.beamAActive = true
            self.tetherDeadlineMs = nowMs + (CONFIG.TETHER_SECONDS * 1000)
            self:LogDebug("Beam A gained; tether deadline=%d", self.tetherDeadlineMs)
            self:ShowTether(CONFIG.TETHER_SECONDS)
        elseif result == ACTION_RESULT_EFFECT_FADED then
            self.beamAActive = false
            self.nextMarkDeadlineMs = nowMs + (CONFIG.NEXT_MARK_SECONDS * 1000)
            self:LogInfo("Beam A faded; provisional next Mark deadline=%d", self.nextMarkDeadlineMs)
            if not self.beamAActive and not self.beamBActive then
                self.tetherDeadlineMs = nil
                self.markNowUntilMs = nil
                self.lastAcceptedMarkMs = nil
                self:HideLinkUI()
                self:RemoveAllArrows()
                self.targetA = nil
                self.targetB = nil
                self:StartPathTracking(nowMs)
            end
        end
        return
    end

    if abilityId == IDS.BEAM_B then
        if IsEffectGain(result) then
            self.beamBActive = true
            self.tetherDeadlineMs = nowMs + (CONFIG.TETHER_SECONDS * 1000)
            self:LogDebug("Beam B gained; tether deadline=%d", self.tetherDeadlineMs)
            self:ShowTether(CONFIG.TETHER_SECONDS)
        elseif result == ACTION_RESULT_EFFECT_FADED then
            self.beamBActive = false
            self.nextMarkDeadlineMs = nowMs + (CONFIG.NEXT_MARK_SECONDS * 1000)
            self:LogInfo("Beam B faded; provisional next Mark deadline=%d", self.nextMarkDeadlineMs)
            if not self.beamAActive and not self.beamBActive then
                self.tetherDeadlineMs = nil
                self.markNowUntilMs = nil
                self.lastAcceptedMarkMs = nil
                self:HideLinkUI()
                self:RemoveAllArrows()
                self.targetA = nil
                self.targetB = nil
                self:StartPathTracking(nowMs)
            end
        end
        return
    end
end

function PCAGC:RegisterAbility(abilityId)
    local namespace = string.format("%s_Ability_%d", EVENT_NAMESPACE, abilityId)
    EM:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, function(...)
        PCAGC:OnCombatEvent(...)
    end)
    EM:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)
end

function PCAGC:RegisterCombatEvents()
    for _, abilityId in pairs(IDS) do
        self:RegisterAbility(abilityId)
    end
end

function PCAGC:UnregisterCombatEvents()
    for _, abilityId in pairs(IDS) do
        EM:UnregisterForEvent(string.format("%s_Ability_%d", EVENT_NAMESPACE, abilityId), EVENT_COMBAT_EVENT)
    end
end

---------------------------------------------------------------------
-- COMBAT / ZONE / BOSS LIFECYCLE
---------------------------------------------------------------------
function PCAGC:OnBossesChanged()
    if not self.runtimeLoaded then return end

    local worldZone = CurrentWorldZoneId()
    if worldZone ~= CORAL_AERIE_ZONE_ID then
        self:SetBossContext("", "zone")
        self.lastBoss1Name = ""
        return
    end

    local bossName = string.lower(NormalizedName(GetUnitName("boss1")))
    local priorBossName = self.lastBoss1Name
    self.lastBoss1Name = bossName

    -- A transient blank boss1 does not erase a previously established boss
    -- context. Only the three supported main bosses become explicit contexts;
    -- an unrelated/non-main boss clears the main-boss context.
    if bossName ~= "" then
        if IsSupportedBossName(bossName) then
            self:SetBossContext(bossName, "boss1")
        else
            self:SetBossContext("", "boss1-unrecognized")
        end
    end

    if bossName ~= priorBossName then
        self:LogInfo("Boss state changed: boss1=%s context=%s", bossName ~= "" and bossName or "none", self.currentBossName ~= "" and self.currentBossName or "none")
    else
        self:LogDebug("EVENT_BOSSES_CHANGED boss1=%s context=%s", bossName ~= "" and bossName or "none", self.currentBossName ~= "" and self.currentBossName or "none")
    end

    -- If Varallion identity became available fractionally after the combat
    -- edge, preserve the already-captured combatStartMs rather than shifting
    -- the +39s anchor.
    if self.currentBossName == VARALLION_NAME then
        if self.inCombat and self.combatStartMs and not self.encounterActive then
            self:StartInitialPrediction()
        end
    end
end

function PCAGC:LoadCoralAerieRuntime()
    if self.runtimeLoaded then return end

    self.runtimeLoaded = true
    self:LogInfo("Coral Aerie runtime loaded")

    self:RegisterCombatEvents()
    EM:RegisterForEvent(EVENT_NAMESPACE .. "_BossesChanged", EVENT_BOSSES_CHANGED, function()
        PCAGC:OnBossesChanged()
    end)

    -- Synchronize boss1 immediately, then follow EVENT_BOSSES_CHANGED.
    self:OnBossesChanged()

    self:RefreshLibUnits("LibUnits2.RefreshUnits")
end

function PCAGC:UnloadCoralAerieRuntime()
    if not self.runtimeLoaded then return end

    self:UnregisterCombatEvents()
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_BossesChanged", EVENT_BOSSES_CHANGED)

    self:LogInfo("Coral Aerie runtime unloaded")
    self:ClearVarallionWorldMarkers()
    self.runtimeLoaded = false
    self.currentBossName = ""
    self.varallionSeen = false
    self.lastBoss1Name = ""
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
        return
    end

    if not self.runtimeLoaded then return end

    self.combatStartMs = GetGameTimeMilliseconds()
    local combatBossName = string.lower(NormalizedName(GetUnitName("boss1")))
    if combatBossName ~= "" then
        if IsSupportedBossName(combatBossName) then
            self:SetBossContext(combatBossName, "combat-edge")
        else
            self:SetBossContext("", "combat-edge-unrecognized")
        end
        self.lastBoss1Name = combatBossName
    end

    self:LogInfo(
        "Coral Aerie combat edge: combatStartMs=%d boss1=%s context=%s",
        self.combatStartMs,
        combatBossName ~= "" and combatBossName or "none",
        self.currentBossName ~= "" and self.currentBossName or "none"
    )

    if self.currentBossName ~= VARALLION_NAME then
        self:PrepareEncounterPresentation()
        if self.currentBossName == MALIGALIG_NAME then
            self:RefreshMaligaligUI()
        elseif self.currentBossName == SARYDIL_NAME then
            self:RefreshSarydilRendering()
        end
        return
    end

    -- A tracked Varallion mechanic can theoretically beat this state callback
    -- to Lua. Never replace an already-authoritative state with a new forecast.
    if self.lastAcceptedMarkMs or self.markNowUntilMs
        or self.nextMarkDeadlineMs or self.tetherDeadlineMs
        or self.targetA or self.targetB
        or self.beamAActive or self.beamBActive then
        return
    end

    self:PrepareEncounterPresentation()
    if self.varallionSeen then self:StartInitialPrediction() end
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
    local LAM = LibAddonMenu2
    if not LAM then
        self:LogWarn("LibAddonMenu-2.0 API unavailable; settings panel could not be created")
        Msg("LibAddonMenu-2.0 API unavailable; settings panel could not be created.")
        return
    end

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
            text = "Boss-specific Coral Aerie alerts for Maligalig, Sarydil, and Varallion.",
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
            tooltip = "Draw four circular floor markers at Branddi's verified always-safe wave positions.",
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
            name = "Path Predictor Arrows",
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
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
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
            disabled = function() return not PCAGC.saved.arrowsEnabled end,
            default = ColorDefault(DEFAULTS.predictorArrowColor),
            width = "half",
        },
    }

    LAM:RegisterOptionControls(panelId, options)
end

---------------------------------------------------------------------
-- INITIALIZATION
---------------------------------------------------------------------

local SAVED_VARIABLES_NAME = "PandaloresCoralAerieGuideCompanionSaved"
local LEGACY_SAVED_VARIABLES_NAME = "MarkOfTheSeaTrackerSaved"

local function CopySimpleValue(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = CopySimpleValue(v) end
    return copy
end

function PCAGC:MigrateLegacySavedVariables()
    if self.saved.legacyMigrationComplete then return end

    local legacy = ZO_SavedVars:NewAccountWide(LEGACY_SAVED_VARIABLES_NAME, 1, nil, {})
    for key, _ in pairs(DEFAULTS) do
        if key ~= "legacyMigrationComplete" and legacy[key] ~= nil then
            self.saved[key] = CopySimpleValue(legacy[key])
        end
    end

    -- Carry forward custom values, but translate the former defaults to the
    -- new 0.6.2 defaults requested for the generalized companion.
    if legacy.maligaligLeaveStacks == 10 then self.saved.maligaligLeaveStacks = 6 end
    if legacy.sarydilPurgeArrowSpaceSize == 0.85 then self.saved.sarydilPurgeArrowSpaceSize = 0.65 end
    if legacy.sarydilPinpointArrowSpaceSize == 0.85 then self.saved.sarydilPinpointArrowSpaceSize = 0.65 end

    self.saved.legacyMigrationComplete = true
end

function PCAGC:Initialize()
    self.saved = ZO_SavedVars:NewAccountWide(SAVED_VARIABLES_NAME, 1, nil, DEFAULTS)
    self:MigrateLegacySavedVariables()
    self:InitializeLogger()
    self:LogInfo("Initializing %s version %s", ADDON_NAME, VERSION)

    -- Live mechanic text is intentionally opaque.
    if self.saved.markColor then self.saved.markColor.a = 1 end
    if self.saved.linkColor then self.saved.linkColor.a = 1 end

    self.hasLibUnits = LibUnits2
        and type(LibUnits2.GetDisplayNameForUnitId) == "function"
        and type(LibUnits2.GetUnitTagForUnitId) == "function"

    self.hasCrutchAttachedIcons = CrutchAlerts
        and type(CrutchAlerts.SetAttachedIconForUnit) == "function"
        and type(CrutchAlerts.RemoveAttachedIconForUnit) == "function"

    self.hasCrutchRemoveAll = CrutchAlerts
        and type(CrutchAlerts.RemoveAllAttachedIcons) == "function"

    self.hasCrutchWorldDrawing = CrutchAlerts
        and type(CrutchAlerts.Drawing) == "table"
        and type(CrutchAlerts.Drawing.CreateGroundCircle) == "function"
        and type(CrutchAlerts.Drawing.CreateLine) == "function"
        and type(CrutchAlerts.Drawing.CreatePlacedPositionMarker) == "function"
        and type(CrutchAlerts.Drawing.RemoveWorldTexture) == "function"

    if not self.hasLibUnits then
        self:LogWarn("LibUnits2 lookup API unavailable; target names will use direct group lookup")
        Msg("LibUnits2 API unavailable; target names will use direct group lookup.")
    end
    if not self.hasCrutchAttachedIcons then
        self:LogWarn("CrutchAlerts attached-icon API unavailable; overhead arrows are disabled")
        Msg("CrutchAlerts attached-icon API unavailable; overhead arrows are disabled.")
    end
    if not self.hasCrutchWorldDrawing then
        self:LogWarn("CrutchAlerts world-drawing API unavailable; Varallion floor/entry markers are disabled")
        Msg("CrutchAlerts world-drawing API unavailable; Varallion floor/entry markers are disabled.")
    end
    self:CreateUI()
    local settingsOk, settingsErr = pcall(function() self:RegisterSettings() end)
    if not settingsOk then
        self:ReportCaughtError("LibAddonMenu settings registration", settingsErr)
        Msg(string.format("Settings panel registration failed: %s", tostring(settingsErr)))
    end

    self.inCombat = IsUnitInCombat("player")
    self.runtimeLoaded = false
    self.currentBossName = ""
    self.varallionSeen = false
    self.lastBoss1Name = ""
    self.combatStartMs = nil
    self.staticStacksRaw = 0
    self.staticStacks = 0
    self.purgeTargets = {}
    self.pinpointTarget = nil

    self:RefreshLibUnits("LibUnits2.RefreshUnits")

    -- Keep boss detection active before combat so the pull edge can use the
    -- cached Varallion identity for the +39s anchor.
    EM:RegisterForEvent(EVENT_NAMESPACE .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        PCAGC:CheckCoralAerieRuntime()
    end)

    EM:RegisterForEvent(EVENT_NAMESPACE .. "_CombatState", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        PCAGC:OnCombatState(inCombat)
    end)

    if EVENT_GROUP_MEMBER_ROLE_CHANGED then
        EM:RegisterForEvent(EVENT_NAMESPACE .. "_RoleChanged", EVENT_GROUP_MEMBER_ROLE_CHANGED, function()
            PCAGC:RefreshSarydilRendering()
        end)
    end

    -- Initialize now and re-check after loading screens/zone transitions.
    self:CheckCoralAerieRuntime()

    -- If /reloadui happens during Varallion, there is no trustworthy fresh
    -- pull edge. Enter Varallion recovery mode without inventing +39s. The
    -- Maligalig and Sarydil modules are event-driven and need no timer recovery.
    if self.inCombat and self.runtimeLoaded and self.currentBossName == VARALLION_NAME then
        self:EnterRecoveryMode()
    end

    self:LogInfo("Initialization complete; LibUnits2=%s CrutchAttachedIcons=%s CrutchWorldDrawing=%s LibDebugLogger=%s", tostring(self.hasLibUnits), tostring(self.hasCrutchAttachedIcons), tostring(self.hasCrutchWorldDrawing), tostring(self.hasDebugLogger))
end

local initialized = false

local function TryInitialize(trigger)
    if initialized then return true end

    local ok, err = pcall(function() PCAGC:Initialize() end)
    if ok then
        initialized = true
        PCAGC.initialized = true
        PCAGC.bootstrapError = nil
        _G.PCAGC_INITIALIZED = true
        _G.PCAGC_BOOTSTRAP_ERROR = nil
        return true
    end

    PCAGC.initialized = false
    PCAGC.bootstrapError = string.format("%s: %s", tostring(trigger), tostring(err))
    _G.PCAGC_INITIALIZED = false
    _G.PCAGC_BOOTSTRAP_ERROR = PCAGC.bootstrapError
    return false
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED)
    TryInitialize("EVENT_ADD_ON_LOADED")
end

-- Normal path: initialize after this addon's manifest has finished loading.
EM:RegisterForEvent(EVENT_NAMESPACE .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- Defensive fallback: if the add-on-loaded callback is missed or initialization
-- fails before the player UI exists, retry once when the player is activated.
EM:RegisterForEvent(EVENT_NAMESPACE .. "_BootstrapPlayerActivated", EVENT_PLAYER_ACTIVATED, function()
    EM:UnregisterForEvent(EVENT_NAMESPACE .. "_BootstrapPlayerActivated", EVENT_PLAYER_ACTIVATED)
    if initialized then return end

    if not TryInitialize("EVENT_PLAYER_ACTIVATED") then
        Msg(string.format("Initialization failed: %s", tostring(PCAGC.bootstrapError)))
    end
end)
