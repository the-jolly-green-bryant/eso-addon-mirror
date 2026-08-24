local U = Ultivite
U.Combat = U.Combat or {}
local KS = U.Combat
local FAB = U.FancyActionBar
local Frames = U.Frames

KS.name = "UltiviteCombat"
KS.version = "1.6.110 / Ultivite 1.0.200"
KS.savedVersion = 1
KS.scopeSavedVersion = 1
KS.unitTag = "reticleover"
KS.pollMs = 250
KS.timerPollMs = 100
KS.hideWatchdogMs = 10000
KS.worldFollowMs = 16
KS.currentStacks = 0
KS.currentTarget = ""
KS.currentAbilityId = 0
KS.currentEffectName = ""
KS.learning = false
KS.debug = false
KS.forceVisible = false
KS.lastDebugAt = 0
KS.selectedTarget = ""
KS.currentExpiresAt = 0
KS.targetCache = {}
KS.targetInfoCache = {}
KS.liveSelectedTarget = false
KS.lastDecoyName = ""
KS.kjalnarEquipped = false
KS.kjalnarEquippedPieces = 0
KS.kjalnarSetName = ""
KS.lastReticleEventMs = 0
KS.positionPreview = false
KS.lamPanelOpen = false
KS.lamPanel = nil
KS.editSnapshot = nil
KS.editToolbar = nil
KS.editToolbarHint = nil
KS.balorghEquipped = false
KS.balorghEquippedPieces = 0
KS.balorghSetName = ""
KS.onslaughtExpiresAt = 0
KS.balorghExpiresAt = 0
KS.timerRoot = nil
KS.onslaughtTimerLabel = nil
KS.balorghTimerLabel = nil
KS.lastOnslaughtTimerText = nil
KS.lastBalorghTimerText = nil
KS.lastTimerRootVisible = nil
KS.lastTimerLayoutKey = nil
KS.lastUltimateEventSlot = 0
KS.lastUltimateEventHotbar = 0
KS.lastUltimateEventAbilityId = 0
KS.lastUltimateEventSlotName = ""
KS.lastUltimateEventAbilityName = ""
KS.lastUltimateEventWasOnslaught = false
KS.tarnishedWorn = false
KS.tarnishedActive = false
KS.tarnishedPiecesActive = 0
KS.tarnishedPiecesTotal = 0
KS.tarnishedSetName = ""
KS.tarnishedTriggeredAt = 0
KS.tarnishedProcAt = 0
KS.tarnishedExpiresAt = 0
KS.tarnishedTimerLabel = nil
KS.lastTarnishedTimerText = nil
KS.nullArcaWorn = false
KS.nullArcaActive = false
KS.nullArcaPiecesActive = 0
KS.nullArcaPiecesTotal = 0
KS.nullArcaSetName = ""
KS.nullArcaStacks = 0
KS.nullArcaStackExpiresAt = 0
KS.nullArcaLastStackAt = 0
KS.nullArcaProcFlashUntil = 0
KS.nullArcaExpiresAt = 0
KS.nullArcaTimerLabel = nil
KS.lastNullArcaTimerText = nil
KS.dragonAppetiteWorn = false
KS.dragonAppetiteActive = false
KS.dragonAppetitePiecesActive = 0
KS.dragonAppetitePiecesTotal = 0
KS.dragonAppetiteSetName = ""
KS.dragonAppetiteStacks = 0
KS.dragonAppetiteAbilityId = 0
KS.dragonAppetiteEffectName = ""
KS.dragonAppetiteTimerLabel = nil
KS.lastDragonAppetiteTimerText = nil
KS.wretchedVitalityRoot = nil
KS.wretchedVitalitySlots = {}
KS.wretchedVitalityBuffs = {}
KS.wretchedVitalityLastScanMs = 0
KS.ccImmunityRoot = nil
KS.ccImmunityIcon = nil
KS.ccImmunityCountdown = nil
KS.ccImmunityAura = nil
KS.ccImmunityDragUnlocked = false
KS.playerDebuffRoot = nil
KS.playerDebuffSlots = {}
KS.playerDebuffAuras = {}
KS.playerAuraHudLastScanMs = 0
KS.playerAuraHudScanPending = false
KS.liveStatWidgets = {}
KS.frontResistanceValue = nil
KS.backResistanceValue = nil
KS.killMessageRoot = nil
KS.killMessageLabel = nil
KS.killMessageExpiresAt = 0
KS.killMessageFadeSeconds = 0.8
KS.killMessageText = ""
KS.killMessageBurstCount = 0
KS.killMessageBurstLastAtMs = 0
KS.killMessageBurstWindowMs = 900
KS.killMessageRecentVictims = {}
KS.pvpHudRoot = nil
KS.pvpHudLabel = nil
KS.lastPvpHudText = nil
KS.lastPvpHudVisible = nil
KS.pvpHudEditMode = false
KS.duelActive = false
KS.lastDeathCountAtMs = 0
KS.lastKillCountAtMs = 0
KS.lastBattlegroundState = nil
KS.lastBattlegroundRoundIndex = nil
KS.lastBattlegroundId = nil
KS.lastPvpContextType = "NONE"
KS.lastDragStateKey = nil
KS.pendingReticleRefresh = false
KS.pendingMetadataSerial = 0
KS.lastTargetStableAtMs = 0
KS.lastRootVisible = nil
KS.lastNameText = nil
KS.lastDetailText = nil
KS.lastHealthY = nil
KS.lastHealthWidth = nil
KS.lastHealthText = nil
KS.lastHealthPercentText = nil
KS.lastDisplayAlphaMode = nil
KS.lastKjalnarRenderKey = nil
KS.lastRootHeight = nil
KS.lastStatusText = nil
KS.lastShowKjalnar = nil
KS.worldProbe = nil
KS.worldFollowAvailable = false
KS.lastWorldAnchorX = nil
KS.lastWorldAnchorY = nil
KS.lastWorldFailure = "not-yet-attempted"
KS.lastWorldPositionSource = "none"
KS.lastWorldSnapshot = nil
KS.lastWorldSuccessSnapshot = nil
KS.diagLog = {}
KS.diagMax = 24
KS.diagCounters = { reticle = 0, power = 0, worldSuccess = 0, worldFail = 0 }
KS.fallbackActive = false
KS.majorBreachActive = false
KS.majorBreachExpiresAt = 0
KS.majorBreachAbilityId = 0
KS.majorBreachEffectName = ""
KS.majorBreachRoot = nil
KS.majorBreachLabel = nil
KS.lastMajorBreachDisplayKey = nil
KS.majorBreachEditMode = false
KS.foodWarningRoot = nil
KS.foodWarningLabel = nil
KS.foodBuffActive = false
KS.foodBuffName = ""
KS.foodBuffAbilityId = 0
KS.foodEventAura = nil
KS.foodWarningReadyAt = 0
KS.lastFoodWarningVisible = nil
KS.majorResolveWarningRoot = nil
KS.majorResolveWarningLabel = nil
KS.majorResolveActive = false
KS.majorResolveBuffName = ""
KS.majorResolveAbilityId = 0
KS.majorResolveEventAura = nil
KS.lastMajorResolveWarningVisible = nil
KS.combatDangerRoot = nil
KS.combatDangerLabels = {}
KS.healthBurstSamples = {}
KS.shieldBreakExpiresAtMs = 0
KS.burstDamageExpiresAtMs = 0
KS.lastBurstDamageTriggerAtMs = 0
KS.lastShieldBreakTriggerAtMs = 0
KS.lastKnownShieldValue = 0
KS.lastShieldDamageAtMs = 0
KS.lastCombatDangerRenderKey = nil

local MAJOR_BREACH_EFFECT_ID = 61743
local FRAME_WIDTH = 440
local FRAME_DEFAULT_HEIGHT = 66
local HEALTH_BG_WIDTH = 376
local HEALTH_FILL_WIDTH = 372
local HEALTH_BG_HEIGHT = 30
local STACK_BADGE_SIZE = 48

local defaults = {
    x = 0,
    y = 0,
    scale = 0.9,
    frameScale = 0.9,
    locked = true,
    snapToGrid = true,
    gridSize = 10,
    showZero = true,
    showTargetName = true,
    playerNameMode = "@Account name",
    abilityId = 0,
    learnedName = "",
    uiRevision = 53,
    stickyTarget = true,
    targetFrame = true,
    targetFrameMode = "ultivite",
    anchorAboveTarget = false,
    targetHeadOffsetCm = 220,
    targetScreenGap = 8,
    nativeOverheadTargetBar = true,
    hideNativeOverheadHealthBars = false,
    nativeSettingsCaptured = false,
    nativeOriginalAllHealthbars = "",
    nativeOriginalAllNameplates = "",
    nativeOriginalEnemyNpcHealthbars = "",
    nativeOriginalEnemyPlayerHealthbars = "",
    nativeOriginalEnemyNpcNameplates = "",
    nativeOriginalEnemyPlayerNameplates = "",
    nativeOriginalFriendlyNpcNameplates = "",
    nativeOriginalNeutralNpcNameplates = "",
    nativeHideNpcNames = false,
    npcNamesGlobalHidden = false,
    npcNamesOverrideActive = false,
    nativeAllEnemyHealthbars = true,
    hideDefaultTargetFrame = true,
    showNativePlayerCpFrame = true,
    overheadPlayerInfo = true,
    cpOnHover = true,
    overheadPlayerInfoOriginalAllNameplates = "",
    overheadPlayerInfoOriginalEnemyPlayerNameplates = "",
    overheadPlayerInfoOriginalFriendlyPlayerNameplates = "",
    overheadPlayerInfoOriginalGroupMemberNameplates = "",
    playerNamesGlobalHidden = false,
    playerNamesOverrideActive = false,
    hideLUIETargetFrame = true,
    autoHideOtherTargetFrames = true,
    externalTargetFrameControlName = "",
    decoyGuard = true,
    fontFace = "Stone Tablet",
    boldFont = true,
    thickTextShadow = true,
    nameFontSize = 22,
    healthFontSize = 16,
    kjalnarFontSize = 34,
    showKjalnarTracker = true,
    onslaughtTimer = true,
    balorghTimer = true,
    tarnishedTimer = true,
    nullArcaTimer = false,
    dragonAppetiteCounter = true,
    dragonAppetiteFontSize = 22,
    dragonAppetiteYOffset = -90,
    wretchedVitalityTimers = true,
    wretchedVitalityIconSize = 54,
    wretchedVitalityX = 0,
    wretchedVitalityY = -350,
    showCcImmunityTracker = true,
    showPlayerDebuffTracker = false,
    playerAuraIconSize = 48,
    playerDebuffMaxIcons = 8,
    ccImmunityX = -310,
    ccImmunityY = -420,
    playerDebuffX = 120,
    playerDebuffY = -420,
    showLiveDamageStat = false,
    showFrontResistanceStat = false,
    showBackResistanceStat = false,
    liveStatFontSize = 28,
    liveDamageX = -150,
    liveDamageY = -255,
    liveFrontResistanceX = 0,
    liveFrontResistanceY = -255,
    liveBackResistanceX = 150,
    liveBackResistanceY = -255,
    showDamageShieldStat = false,
    liveShieldX = 300,
    liveShieldY = -255,
    showGenericStackTracker = true,
    genericStackIconSize = 44,
    genericStackX = -120,
    genericStackY = -315,
    showStreakFatigueTracker = true,
    streakFatigueIconSize = 48,
    streakFatigueX = -360,
    streakFatigueY = -315,
    showResourceDanger = true,
    resourceDangerHealthPct = 35,
    resourceDangerMagickaPct = 20,
    resourceDangerStaminaPct = 50,
    resourceDangerFontSize = 26,
    resourceDangerX = 0,
    resourceDangerY = 325,
    showShieldBrokenWarning = true,
    showExecuteDangerWarning = true,
    executeDangerWarningMode = "always",
    executeDangerHealthPct = 25,
    showBurstDamageWarning = true,
    burstDamageWarningMode = "always",
    burstDamagePct = 35,
    burstDamageWindowMs = 700,
    combatDangerFontSize = 30,
    combatDangerX = 0,
    combatDangerY = 155,
    showImportantTargetDebuffs = false,
    targetDebuffIconSize = 42,
    targetDebuffMaxIcons = 8,
    targetDebuffX = 0,
    targetDebuffY = -145,
    majorBreachTracker = true,
    majorBreachX = 0,
    majorBreachY = 0,
    majorBreachFontSize = 16,
    showNoFoodWarning = true,
    foodWarningX = 0,
    foodWarningY = 70,
    foodWarningFontSize = 28,
    showNoMajorResolveWarning = true,
    majorResolveWarningX = 0,
    majorResolveWarningY = -80,
    majorResolveWarningFontSize = 24,
    showEnemyCorrosiveAlert = true,
    showEnemyOnslaughtAlert = true,
    enemyUltimateAlertIconSize = 54,
    enemyUltimateAlertTargetX = 0,
    enemyUltimateAlertTargetY = -115,
    enemyUltimateAlertGlobalX = 0,
    enemyUltimateAlertGlobalY = 165,
    timerPlacement = "Above frame",
    timerFontSize = 44,
    balorghTimerFontSize = 32,
    alwaysCollapseChat = false,
    diagnosticLogging = false,
    showPvpKillCounter = true,
    showPvpKillMessages = true,
    killMessageX = 0,
    killMessageY = -145,
    killMessageFontSize = 30,
    pvpHudX = 89,
    pvpHudY = 51,
    pvpHudFontSize = 20,
    pvpKills = 0,
    pvpDeaths = 0,
    pvpSessionKey = "",
    pvpSessionActive = false,
    kjalnarSetId = 0,
}

local scopeDefaults = {
    useAccountWide = true,
}

KS.defaults = defaults

local function copySavedSettings(source, destination)
    if not source or not destination then return end
    for key in pairs(defaults) do
        destination[key] = source[key]
    end
end

local function chat(msg)
    d(string.format("|c7FD4FF[Ultivite: Combat]|r %s", tostring(msg)))
end

function KS.IsDiagnosticLoggingEnabled()
    return KS.sv ~= nil and KS.sv.diagnosticLogging == true
end

function KS.DiagnosticChat(msg)
    if KS.IsDiagnosticLoggingEnabled() then
        chat(msg)
    end
end

local function diagBool(value)
    return value and "true" or "false"
end

function KS.DiagPush(kind, message)
    local ms = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    local line = string.format("%d %s %s", tonumber(ms) or 0, tostring(kind or "INFO"), tostring(message or ""))
    KS.diagLog = KS.diagLog or {}
    KS.diagLog[#KS.diagLog + 1] = line
    local maxLines = tonumber(KS.diagMax) or 24
    while #KS.diagLog > maxLines do table.remove(KS.diagLog, 1) end
end

function KS.SetWorldFailure(reason, detail)
    reason = tostring(reason or "unknown")
    detail = tostring(detail or "")
    KS.diagCounters = KS.diagCounters or { reticle = 0, power = 0, worldSuccess = 0, worldFail = 0 }
    KS.diagCounters.worldFail = (tonumber(KS.diagCounters.worldFail) or 0) + 1
    if KS.lastWorldFailure ~= reason then
        KS.lastWorldFailure = reason
        KS.DiagPush("WORLD_FAIL", reason .. (detail ~= "" and (" | " .. detail) or ""))
    end
end

function KS.SetWorldSuccess(source, worldX, worldY, worldZ, screenX, screenY)
    KS.diagCounters = KS.diagCounters or { reticle = 0, power = 0, worldSuccess = 0, worldFail = 0 }
    KS.diagCounters.worldSuccess = (tonumber(KS.diagCounters.worldSuccess) or 0) + 1
    KS.lastWorldFailure = "none"
    KS.lastWorldPositionSource = tostring(source or "unknown")
    KS.lastWorldSuccessSnapshot = {
        source = KS.lastWorldPositionSource,
        worldX = worldX, worldY = worldY, worldZ = worldZ,
        screenX = screenX, screenY = screenY,
        at = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
    }
end

local function normalizeName(name)
    if not name then return "" end
    local n = zo_strlower(name)
    n = n:gsub("’", "'")
    return n
end

local function cleanName(name)
    if not name or name == "" then return "" end
    return zo_strformat("<<C:1>>", name)
end

function KS.GetDisplayedTargetName(info, fallbackName)
    fallbackName = fallbackName or ""
    if not info or not info.isPlayer then return fallbackName end

    if KS.sv and KS.sv.playerNameMode == "@Account name" then
        local accountName = tostring(info.displayName or "")
        if accountName ~= "" then return accountName end
    end

    return fallbackName
end

local function looksLikeKjalnarName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    if n:find("kjalnar", 1, true) then return true end
    if n:find("bone stack", 1, true) then return true end
    if n:find("bone stacks", 1, true) then return true end
    return false
end

local function looksLikeKjalnarSetName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("kjalnar", 1, true) ~= nil
end

local function looksLikeBalorghSetName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("balorgh", 1, true) ~= nil
end

local function looksLikeTarnishedSetName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("tarnished nightmare", 1, true) ~= nil
end

local function looksLikeNullArcaSetName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("slivers of the null arca", 1, true) ~= nil
        or n:find("null arca", 1, true) ~= nil
end

local function looksLikeDragonAppetiteSetName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("dragon's appetite", 1, true) ~= nil
        or n:find("dragons appetite", 1, true) ~= nil
end

local function looksLikeDragonAppetiteEffectName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("dragon's appetite", 1, true) ~= nil
        or n:find("dragons appetite", 1, true) ~= nil
end

local function looksLikeWretchedVitalityEffectName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    return n:find("wretched vitality", 1, true) ~= nil
end

-- ESO currently exposes the generic Crowd Control Immunity aura through more
-- than one ability id depending on the effect path. Mature aura trackers such
-- as LUI Extended account for both 28301 and 38117. Keep both here and still
-- retain name matching for Immovable / Unstoppable style immunity sources.
local CC_IMMUNITY_ABILITY_ID = 28301
local CC_IMMUNITY_ABILITY_IDS = {
    [28301] = true,
    [38117] = true,
}

local function looksLikeCcImmunityEffect(name, abilityId)
    local id = tonumber(abilityId) or 0
    if CC_IMMUNITY_ABILITY_IDS[id] == true then return true end

    local n = normalizeName(name)
    if n == "" then return false end

    return n:find("crowd control immunity", 1, true) ~= nil
        or n:find("cc immunity", 1, true) ~= nil
        or n:find("immovable", 1, true) ~= nil
        or n:find("immovability", 1, true) ~= nil
        or n:find("unstoppable", 1, true) ~= nil
        or n:find("unstopable", 1, true) ~= nil
end

local function isTimedPlayerDebuff(effectType, timeStarted, timeEnding, now)
    local isDebuff = false
    if BUFF_EFFECT_TYPE_DEBUFF ~= nil then
        isDebuff = effectType == BUFF_EFFECT_TYPE_DEBUFF
    else
        isDebuff = tonumber(effectType) == 2
    end

    local started = tonumber(timeStarted) or 0
    local ending = tonumber(timeEnding) or 0
    return isDebuff and ending > (tonumber(now) or 0) and ending > started
end

local function looksLikeExplicitDecoyName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    if n:find("blastbones", 1, true) then return true end
    if n:find("blast bones", 1, true) then return true end
    if n:find("engine guardian", 1, true) then return true end
    return false
end

local function looksLikeGenericEngineGuardianName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    if n:find("dwemer automaton", 1, true) then return true end
    if n:find("dwarven sphere", 1, true) then return true end
    if n:find("dwemer sphere", 1, true) then return true end
    return false
end

local function isValidStackCount(v)
    return type(v) == "number" and v >= 1 and v <= 5
end

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function formatInt(value)
    local s = tostring(math.floor(tonumber(value) or 0))
    local sign, digits = s:match("^([%-]?)(%d+)$")
    if not digits then return s end
    local rev = digits:reverse():gsub("(%d%d%d)", "%1,")
    rev = rev:gsub(",$", "")
    return sign .. rev:reverse()
end

function KS.IsHUDAllowed()
    -- Never draw the target frame over map, inventory, settings, mail, etc.
    -- ESO exposes UI camera mode for these full UI scenes.
    if IsGameCameraActive and not IsGameCameraActive() then return false end
    if IsGameCameraUIModeActive and IsGameCameraUIModeActive() then return false end
    return true
end

function KS.IsPlayerInCombat()
    return IsUnitInCombat and IsUnitInCombat("player") == true
end


function KS.IsPositionPreviewActive()
    -- Editing is now a single explicit state: unlocked. This keeps the frame
    -- visible and movable even after the settings panel is closed.
    return KS.sv and KS.sv.locked ~= true
end

function KS.IsDragEnabled()
    return KS.sv and KS.sv.locked ~= true
end

function KS.CaptureEditSnapshot()
    if not KS.sv or KS.editSnapshot then return end
    KS.editSnapshot = {
        x = tonumber(KS.sv.x) or 0,
        y = tonumber(KS.sv.y) or -82,
        frameScale = KS.GetFrameScale(),
    }
end

function KS.RestoreEditSnapshot(lockAfter)
    if not KS.editSnapshot or not KS.sv then
        if lockAfter then KS.SetLocked(true, true) end
        return
    end
    KS.sv.x = KS.editSnapshot.x
    KS.sv.y = KS.editSnapshot.y
    KS.sv.frameScale = KS.editSnapshot.frameScale
    KS.sv.scale = KS.editSnapshot.frameScale
    if KS.root then KS.root:SetScale(KS.GetFrameScale()) end
    if KS.timerRoot then KS.timerRoot:SetScale(KS.GetFrameScale()) end
    KS.ApplyPosition()
    KS.ApplyTimerAnchor()
    KS.RefreshDisplay()
    KS.UpdateCombatTimers()
    if lockAfter then
        KS.editSnapshot = nil
        KS.SetLocked(true, true)
    end
end

function KS.SaveAndLockEdit()
    KS.editSnapshot = nil
    KS.SetLocked(true, true)
    chat("Frame position and size saved.")
end

function KS.CancelEdit()
    KS.RestoreEditSnapshot(true)
    chat("Frame changes cancelled.")
end

function KS.UndoEdit()
    if not KS.editSnapshot then return end
    local snapshot = KS.editSnapshot
    KS.sv.x = snapshot.x
    KS.sv.y = snapshot.y
    KS.sv.frameScale = snapshot.frameScale
    KS.sv.scale = snapshot.frameScale
    if KS.root then KS.root:SetScale(KS.GetFrameScale()) end
    if KS.timerRoot then KS.timerRoot:SetScale(KS.GetFrameScale()) end
    KS.ApplyPosition()
    KS.ApplyTimerAnchor()
    KS.RefreshDisplay()
    KS.UpdateCombatTimers()
    chat("Frame restored to the position and size from when editing started.")
end

function KS.GetGridSize()
    return clamp(math.floor(tonumber(KS.sv and KS.sv.gridSize) or 10), 2, 50)
end

function KS.SnapCoordinate(value)
    local grid = KS.GetGridSize()
    if grid <= 1 then return math.floor((tonumber(value) or 0) + 0.5) end
    local v = tonumber(value) or 0
    if v >= 0 then return math.floor((v / grid) + 0.5) * grid end
    return math.ceil((v / grid) - 0.5) * grid
end

function KS.CenterHorizontally(silent)
    if not KS.sv then return end
    KS.sv.x = 0
    KS.ApplyPosition()
    if not silent then chat("Target frame centered horizontally.") end
end

function KS.CenterOnScreen(silent)
    if not KS.sv then return end
    KS.sv.x = 0
    KS.sv.y = 0
    KS.ApplyPosition()
    if not silent then chat("Target frame centered on screen.") end
end

function KS.UpdateEditToolbar()
    local editing = KS.IsDragEnabled()
    if KS.editToolbar then KS.editToolbar:SetHidden(not editing) end
    if KS.editToolbarHint and editing then
        KS.editToolbarHint:SetText(string.format("Drag frame  •  Wheel resize  •  Shift+wheel fine resize  •  Grid %s",
            (KS.sv and KS.sv.snapToGrid ~= false) and tostring(KS.GetGridSize()) or "OFF"))
    end
end

function KS.UpdateDragState()
    local canDrag = KS.IsDragEnabled()
    local key = tostring(canDrag) .. ":" .. tostring(KS.sv and KS.sv.snapToGrid ~= false) .. ":" .. tostring(KS.GetGridSize())
    if KS.lastDragStateKey == key then
        KS.UpdateEditToolbar()
        return
    end
    KS.lastDragStateKey = key

    if KS.root then KS.root:SetMouseEnabled(canDrag) end
    if KS.dragger then KS.dragger:SetMouseEnabled(canDrag) end
    if KS.unlockHint then
        KS.unlockHint:SetText("MOVE")
        KS.unlockHint:SetHidden(not canDrag)
    end
    if KS.outline then
        KS.outline:SetEdgeColor(0.25, 0.72, 0.95, canDrag and 0.90 or 0)
    end
    KS.UpdateEditToolbar()
end

function KS.SetPositionPreview(enabled)
    -- Backward-compatible alias retained for old menu/slash integrations.
    KS.SetLocked(not (enabled and true or false), true)
end

function KS.HasPreferredTarget()
    -- ESO exposes the preferred enemy target state directly. This remains
    -- valid while a Tab target is retained even when reticleover is empty,
    -- and becomes false when the preferred target is cleared.
    if IsGameCameraPreferredTargetValid then
        return IsGameCameraPreferredTargetValid() == true
    end
    return false
end

function KS.CanRetainOffReticle()
    return KS.sv and KS.sv.stickyTarget == true and KS.HasPreferredTarget()
end

function KS.GetFrameScale()
    if not KS.sv then return defaults.frameScale end
    return clamp(tonumber(KS.sv.frameScale) or defaults.frameScale, 0.35, 1.50)
end

function KS.SetFrameScale(scale, silent)
    scale = clamp(tonumber(scale) or defaults.frameScale, 0.35, 1.50)
    KS.sv.frameScale = scale
    -- Keep the legacy value synchronized so old /ks scale usage and saved data remain sane.
    KS.sv.scale = scale
    if KS.root then
        KS.root:SetScale(scale)
        KS.ApplyPosition()
    end
    if KS.timerRoot then
        KS.timerRoot:SetScale(scale)
        KS.ApplyTimerAnchor()
    end
    if KS.killMessageRoot then
        KS.killMessageRoot:SetScale(scale)
        KS.ApplyKillMessageAnchor()
    end
    if not silent then chat(string.format("Target frame size set to %d%%.", math.floor(scale * 100 + 0.5))) end
end

local FONT_FACE_TOKENS = {
    ["ESO Medium"] = "$(MEDIUM_FONT)",
    ["ESO Chat"] = "$(CHAT_FONT)",
    ["Antique"] = "$(ANTIQUE_FONT)",
    ["Handwritten"] = "$(HANDWRITTEN_FONT)",
    ["Stone Tablet"] = "$(STONE_TABLET_FONT)",
}

local FONT_FACE_CHOICES = {
    "ESO Medium",
    "ESO Chat",
    "Antique",
    "Handwritten",
    "Stone Tablet",
}

function KS.GetConfiguredFontToken()
    if not KS.sv then return "$(BOLD_FONT)" end
    if KS.sv.boldFont == true then return "$(BOLD_FONT)" end
    return FONT_FACE_TOKENS[KS.sv.fontFace] or "$(MEDIUM_FONT)"
end

function KS.GetConfiguredFontEffect()
    if KS.sv and KS.sv.thickTextShadow == false then
        return "soft-shadow-thin"
    end
    return "soft-shadow-thick"
end

function KS.ApplyFontSettings()
    if not KS.sv then return end

    local token = KS.GetConfiguredFontToken()
    local effect = KS.GetConfiguredFontEffect()
    local nameSize = clamp(math.floor(tonumber(KS.sv.nameFontSize) or defaults.nameFontSize), 14, 40)
    local healthSize = clamp(math.floor(tonumber(KS.sv.healthFontSize) or defaults.healthFontSize), 10, 30)
    local kjSize = clamp(math.floor(tonumber(KS.sv.kjalnarFontSize) or defaults.kjalnarFontSize), 18, 42)

    KS.sv.nameFontSize = nameSize
    KS.sv.healthFontSize = healthSize
    KS.sv.kjalnarFontSize = kjSize

    if KS.nameLabel then
        KS.nameLabel:SetFont(string.format("%s|%d|%s", token, nameSize, effect))
    end
    if KS.detailLabel then
        KS.detailLabel:SetFont(string.format("%s|%d|%s", token, clamp(nameSize - 14, 9, 18), effect))
    end
    if KS.healthText then
        KS.healthText:SetFont(string.format("%s|%d|%s", token, healthSize, effect))
    end
    if KS.healthPercent then
        KS.healthPercent:SetFont(string.format("%s|%d|%s", token, healthSize, effect))
    end
    if KS.kjLabel then
        KS.kjLabel:SetFont(string.format("%s|%d|%s", token, clamp(kjSize - 3, 8, 20), effect))
    end
    if KS.numberLabel then
        KS.numberLabel:SetFont(string.format("%s|%d", token, clamp(kjSize, 18, 42)))
    end
    if KS.statusLabel then
        KS.statusLabel:SetFont(string.format("%s|%d|soft-shadow-thin", token, clamp(kjSize - 5, 8, 14)))
    end
    if KS.unlockHint then
        KS.unlockHint:SetFont(string.format("%s|%d|soft-shadow-thin", token, clamp(kjSize - 5, 8, 14)))
    end
    local timerSize = clamp(math.floor(tonumber(KS.sv.timerFontSize) or defaults.timerFontSize), 16, 44)
    local balorghTimerSize = clamp(math.floor(tonumber(KS.sv.balorghTimerFontSize) or defaults.balorghTimerFontSize), 16, 48)
    local dragonAppetiteFontSize = clamp(math.floor(tonumber(KS.sv.dragonAppetiteFontSize) or defaults.dragonAppetiteFontSize), 10, 36)
    KS.sv.timerFontSize = timerSize
    KS.sv.balorghTimerFontSize = balorghTimerSize
    KS.sv.dragonAppetiteFontSize = dragonAppetiteFontSize
    if KS.onslaughtTimerLabel then
        KS.onslaughtTimerLabel:SetFont(string.format("%s|%d|%s", token, timerSize, effect))
    end
    if KS.balorghTimerLabel then
        KS.balorghTimerLabel:SetFont(string.format("%s|%d|%s", token, balorghTimerSize, effect))
    end
    if KS.tarnishedTimerLabel then
        KS.tarnishedTimerLabel:SetFont(string.format("%s|%d|%s", token, timerSize, effect))
    end
    if KS.nullArcaTimerLabel then
        KS.nullArcaTimerLabel:SetFont(string.format("%s|%d|%s", token, timerSize, effect))
    end
    if KS.dragonAppetiteTimerLabel then
        KS.dragonAppetiteTimerLabel:SetFont(string.format("%s|%d|%s", token, dragonAppetiteFontSize, effect))
    end
    if KS.killMessageLabel then
        local killMessageFontSize = clamp(math.floor(tonumber(KS.sv.killMessageFontSize) or defaults.killMessageFontSize), 20, 56)
        KS.sv.killMessageFontSize = killMessageFontSize
        KS.killMessageLabel:SetFont(string.format("%s|%d|%s", token, killMessageFontSize, effect))
    end
    if KS.pvpHudLabel then
        if KS.ApplyPvpHudAppearance then
            KS.ApplyPvpHudAppearance()
        else
            KS.pvpHudLabel:SetFont(string.format("%s|%d|%s", token, 20, effect))
        end
    end
end

function KS.ResetFontSettings()
    KS.sv.fontFace = defaults.fontFace
    KS.sv.boldFont = defaults.boldFont
    KS.sv.thickTextShadow = defaults.thickTextShadow
    KS.sv.nameFontSize = defaults.nameFontSize
    KS.sv.healthFontSize = defaults.healthFontSize
    KS.sv.kjalnarFontSize = defaults.kjalnarFontSize
    KS.sv.timerFontSize = defaults.timerFontSize
    KS.sv.balorghTimerFontSize = defaults.balorghTimerFontSize
    KS.sv.dragonAppetiteFontSize = defaults.dragonAppetiteFontSize
    KS.sv.killMessageFontSize = defaults.killMessageFontSize
    KS.ApplyFontSettings()
    KS.RefreshDisplay()
end

function KS.AdjustAllFontSizes(delta)
    delta = tonumber(delta) or 0
    KS.sv.nameFontSize = clamp((tonumber(KS.sv.nameFontSize) or defaults.nameFontSize) + delta, 14, 40)
    KS.sv.healthFontSize = clamp((tonumber(KS.sv.healthFontSize) or defaults.healthFontSize) + delta, 10, 30)
    KS.sv.kjalnarFontSize = clamp((tonumber(KS.sv.kjalnarFontSize) or defaults.kjalnarFontSize) + delta, 18, 42)
    KS.sv.timerFontSize = clamp((tonumber(KS.sv.timerFontSize) or defaults.timerFontSize) + delta, 16, 44)
    KS.sv.balorghTimerFontSize = clamp((tonumber(KS.sv.balorghTimerFontSize) or defaults.balorghTimerFontSize) + delta, 16, 48)
    KS.sv.dragonAppetiteFontSize = clamp((tonumber(KS.sv.dragonAppetiteFontSize) or defaults.dragonAppetiteFontSize) + delta, 10, 36)
    KS.ApplyFontSettings()
    KS.RefreshDisplay()
end

function KS.ApplyTimerAnchor()
    if not KS.timerRoot or not KS.root then return end
    local placement = KS.sv and KS.sv.timerPlacement or defaults.timerPlacement
    if placement ~= "Below frame" then placement = "Above frame" end

    KS.timerRoot:ClearAnchors()
    KS.timerRoot:SetDimensions(560, 162)
    if placement == "Below frame" then
        KS.timerRoot:SetAnchor(TOP, KS.root, BOTTOM, 0, 8)
    else
        KS.timerRoot:SetAnchor(BOTTOM, KS.root, TOP, 0, -8)
    end

    local labels = {
        KS.onslaughtTimerLabel,
        KS.balorghTimerLabel,
        KS.tarnishedTimerLabel,
        KS.nullArcaTimerLabel,
        KS.dragonAppetiteTimerLabel,
    }
    for _, label in ipairs(labels) do
        if label then
            label:ClearAnchors()
            label:SetAnchor(TOP, KS.timerRoot, TOP, 0, 0)
            label:SetDimensions(560, 38)
            label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
    end
    KS.lastTimerLayoutKey = nil
    KS.ApplyKillMessageAnchor()
end

function KS.LayoutCombatTimerLabels(showOn, showBal, showTarnished, showNullArca, showDragon)
    if not KS.timerRoot then return end

    local dragonYOffset = clamp(
        math.floor(tonumber(KS.sv and KS.sv.dragonAppetiteYOffset) or defaults.dragonAppetiteYOffset),
        -250,
        200
    )
    if KS.sv then KS.sv.dragonAppetiteYOffset = dragonYOffset end

    local key = (showOn and "1" or "0")
        .. (showBal and "1" or "0")
        .. (showTarnished and "1" or "0")
        .. (showNullArca and "1" or "0")
        .. (showDragon and "1" or "0")
        .. ":" .. tostring(dragonYOffset)
    if KS.lastTimerLayoutKey == key then return end
    KS.lastTimerLayoutKey = key

    -- Keep the general combat timers in their existing rows.
    local rows = {}
    if showOn and KS.onslaughtTimerLabel then rows[#rows + 1] = KS.onslaughtTimerLabel end
    if showBal and KS.balorghTimerLabel then rows[#rows + 1] = KS.balorghTimerLabel end
    if showTarnished and KS.tarnishedTimerLabel then rows[#rows + 1] = KS.tarnishedTimerLabel end
    if showNullArca and KS.nullArcaTimerLabel then rows[#rows + 1] = KS.nullArcaTimerLabel end

    local rowCount = #rows
    KS.timerRoot:SetHeight(rowCount > 0 and (rowCount * 40 + 2) or 40)
    for i, label in ipairs(rows) do
        label:ClearAnchors()
        label:SetAnchor(TOP, KS.timerRoot, TOP, 0, (i - 1) * 40)
        label:SetDimensions(560, 38)
    end

    -- Dragon's Appetite is intentionally independent so it can be smaller and
    -- moved farther upward without shifting or overlapping the other timer rows.
    if KS.dragonAppetiteTimerLabel then
        KS.dragonAppetiteTimerLabel:ClearAnchors()
        KS.dragonAppetiteTimerLabel:SetAnchor(TOP, KS.timerRoot, TOP, 0, dragonYOffset)
        KS.dragonAppetiteTimerLabel:SetDimensions(560, 38)
    end

    KS.ApplyKillMessageAnchor()
end

function KS.StartCombatTimer(timerName, durationSeconds, explicitEndTime)
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local expiresAt = tonumber(explicitEndTime) or 0
    if expiresAt <= now then expiresAt = now + (tonumber(durationSeconds) or 0) end
    if timerName == "onslaught" then
        KS.onslaughtExpiresAt = expiresAt
    elseif timerName == "balorgh" then
        KS.balorghExpiresAt = expiresAt
    end
    KS.UpdateCombatTimers()
end

function KS.StopCombatTimer(timerName)
    if timerName == "onslaught" then
        KS.onslaughtExpiresAt = 0
    elseif timerName == "balorgh" then
        KS.balorghExpiresAt = 0
    end
    KS.UpdateCombatTimers()
end

function KS.StartTarnishedTracker(now)
    now = tonumber(now) or (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0)
    KS.tarnishedTriggeredAt = now
    KS.tarnishedProcAt = now + 1.3
    KS.tarnishedExpiresAt = now + 8
    KS.lastTimerLayoutKey = nil
    KS.UpdateCombatTimers()
end

function KS.AddNullArcaCritical(now)
    now = tonumber(now) or (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0)
    if (tonumber(KS.nullArcaExpiresAt) or 0) > now then return end

    if (tonumber(KS.nullArcaStackExpiresAt) or 0) <= now then
        KS.nullArcaStacks = 0
        KS.nullArcaStackExpiresAt = 0
    end

    local lastStackAt = tonumber(KS.nullArcaLastStackAt) or 0
    if lastStackAt > 0 and (now - lastStackAt) < 0.49 then return end

    KS.nullArcaLastStackAt = now
    KS.nullArcaStacks = math.min(3, (tonumber(KS.nullArcaStacks) or 0) + 1)
    KS.nullArcaStackExpiresAt = now + 10

    if KS.nullArcaStacks >= 3 then
        KS.nullArcaStacks = 0
        KS.nullArcaStackExpiresAt = 0
        KS.nullArcaProcFlashUntil = now + 0.9
        KS.nullArcaExpiresAt = now + 4
    end

    KS.lastTimerLayoutKey = nil
    KS.UpdateCombatTimers()
end

function KS.OnProcCriticalEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if (tonumber(hitValue) or 0) <= 0 then return end
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0

    if KS.tarnishedActive and (tonumber(KS.tarnishedExpiresAt) or 0) <= now then
        KS.StartTarnishedTracker(now)
    end
    if KS.nullArcaActive then
        KS.AddNullArcaCritical(now)
    end
end

function KS.UpdateCombatTimers()
    if not KS.timerRoot then return end
    local preview = KS.IsPositionPreviewActive()
    local hudAllowed = KS.IsHUDAllowed()
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0

    local onRemain = math.max(0, (tonumber(KS.onslaughtExpiresAt) or 0) - now)
    local balRemain = math.max(0, (tonumber(KS.balorghExpiresAt) or 0) - now)
    local tarnishedRemain = math.max(0, (tonumber(KS.tarnishedExpiresAt) or 0) - now)
    local nullRemain = math.max(0, (tonumber(KS.nullArcaExpiresAt) or 0) - now)
    local nullStackRemain = math.max(0, (tonumber(KS.nullArcaStackExpiresAt) or 0) - now)

    if onRemain <= 0 then KS.onslaughtExpiresAt = 0 end
    if balRemain <= 0 then KS.balorghExpiresAt = 0 end
    if tarnishedRemain <= 0 then
        KS.tarnishedExpiresAt = 0
        KS.tarnishedTriggeredAt = 0
        KS.tarnishedProcAt = 0
    end
    if nullRemain <= 0 then
        KS.nullArcaExpiresAt = 0
        KS.nullArcaProcFlashUntil = 0
    end
    if nullStackRemain <= 0 then
        KS.nullArcaStacks = 0
        KS.nullArcaStackExpiresAt = 0
    end

    local hasNullStacks = (tonumber(KS.nullArcaStacks) or 0) > 0 and (tonumber(KS.nullArcaStackExpiresAt) or 0) > now
    local showOn = KS.sv and KS.sv.onslaughtTimer ~= false and (preview or onRemain > 0)
    local showBal = KS.sv and KS.sv.balorghTimer ~= false and (preview or balRemain > 0)
    local showTarnished = KS.sv and KS.sv.tarnishedTimer ~= false and (preview or tarnishedRemain > 0)
    local showNullArca = KS.sv and KS.sv.nullArcaTimer ~= false and (preview or nullRemain > 0 or hasNullStacks)
    local showDragon = KS.sv
        and KS.sv.dragonAppetiteCounter ~= false
        and (preview or (KS.dragonAppetiteWorn == true and KS.IsPlayerInCombat()))

    KS.LayoutCombatTimerLabels(showOn, showBal, showTarnished, showNullArca, showDragon)

    if KS.onslaughtTimerLabel then
        local wasHidden = KS.onslaughtTimerLabel:IsHidden()
        if wasHidden == showOn then KS.onslaughtTimerLabel:SetHidden(not showOn) end
        if showOn then
            local n = preview and 8 or math.max(1, math.ceil(onRemain - 0.001))
            local text = string.format("ONSLAUGHT    %d", n)
            if KS.lastOnslaughtTimerText ~= text then
                KS.lastOnslaughtTimerText = text
                KS.onslaughtTimerLabel:SetText(text)
            end
        else
            KS.lastOnslaughtTimerText = nil
        end
    end

    if KS.balorghTimerLabel then
        local wasHidden = KS.balorghTimerLabel:IsHidden()
        if wasHidden == showBal then KS.balorghTimerLabel:SetHidden(not showBal) end
        if showBal then
            local n = preview and 12 or math.max(1, math.ceil(balRemain - 0.001))
            local text = string.format("BALORGH    %d", n)
            if KS.lastBalorghTimerText ~= text then
                KS.lastBalorghTimerText = text
                KS.balorghTimerLabel:SetText(text)
            end
        else
            KS.lastBalorghTimerText = nil
        end
    end

    if KS.tarnishedTimerLabel then
        local wasHidden = KS.tarnishedTimerLabel:IsHidden()
        if wasHidden == showTarnished then KS.tarnishedTimerLabel:SetHidden(not showTarnished) end
        if showTarnished then
            local text
            if preview then
                text = "TARNISHED    PROC 1.3"
            else
                local procRemain = math.max(0, (tonumber(KS.tarnishedProcAt) or 0) - now)
                if procRemain > 0 then
                    text = string.format("TARNISHED    PROC %.1f", math.ceil(procRemain * 10 - 0.001) / 10)
                else
                    text = string.format("TARNISHED    CD %d", math.max(1, math.ceil(tarnishedRemain - 0.001)))
                end
            end
            if KS.lastTarnishedTimerText ~= text then
                KS.lastTarnishedTimerText = text
                KS.tarnishedTimerLabel:SetText(text)
            end
        else
            KS.lastTarnishedTimerText = nil
        end
    end

    if KS.nullArcaTimerLabel then
        local wasHidden = KS.nullArcaTimerLabel:IsHidden()
        if wasHidden == showNullArca then KS.nullArcaTimerLabel:SetHidden(not showNullArca) end
        if showNullArca then
            local text
            if preview then
                text = "NULL ARCA    2 / 3"
            elseif nullRemain > 0 then
                local n = math.max(1, math.ceil(nullRemain - 0.001))
                if (tonumber(KS.nullArcaProcFlashUntil) or 0) > now then
                    text = string.format("NULL ARCA    PROC    CD %d", n)
                else
                    text = string.format("NULL ARCA    CD %d", n)
                end
            else
                text = string.format("NULL ARCA    %d / 3", tonumber(KS.nullArcaStacks) or 0)
            end
            if KS.lastNullArcaTimerText ~= text then
                KS.lastNullArcaTimerText = text
                KS.nullArcaTimerLabel:SetText(text)
            end
        else
            KS.lastNullArcaTimerText = nil
        end
    end

    if KS.dragonAppetiteTimerLabel then
        local wasHidden = KS.dragonAppetiteTimerLabel:IsHidden()
        if wasHidden == showDragon then KS.dragonAppetiteTimerLabel:SetHidden(not showDragon) end
        if showDragon then
            local stacks = preview and 6 or clamp(math.floor((tonumber(KS.dragonAppetiteStacks) or 0) + 0.5), 0, 10)
            local dragonText = string.format("DRAGON'S APPETITE    %d / 10", stacks)
            if KS.lastDragonAppetiteTimerText ~= dragonText then
                KS.lastDragonAppetiteTimerText = dragonText
                KS.dragonAppetiteTimerLabel:SetText(dragonText)
            end
        else
            KS.lastDragonAppetiteTimerText = nil
        end
    end

    local visible = (preview or hudAllowed) and (showOn or showBal or showTarnished or showNullArca or showDragon)
    if KS.lastTimerRootVisible ~= visible then
        KS.lastTimerRootVisible = visible
        KS.timerRoot:SetHidden(not visible)
    end
end

function KS.HandlePlayerTimerEffect(changeType, effectName, unitTag, beginTime, endTime)
    if unitTag ~= "player" then return end
    local effectNorm = normalizeName(effectName)
    if effectNorm:find("onslaught", 1, true) then
        -- Do not let a short-lived auxiliary Onslaught effect overwrite the real
        -- penetration window started by the ultimate-use event. If the action-slot
        -- event was missed, the player effect still starts a minimum 8 second timer.
        -- A longer API-reported end time is preserved for modes where ESO reports one.
        if changeType ~= EFFECT_RESULT_FADED then
            local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
            local currentExpiry = tonumber(KS.onslaughtExpiresAt) or 0
            local reportedExpiry = tonumber(endTime) or 0
            local expiresAt
            if currentExpiry > now then
                expiresAt = math.max(currentExpiry, reportedExpiry)
            else
                expiresAt = math.max(now + 8, reportedExpiry)
            end
            KS.onslaughtExpiresAt = expiresAt
            KS.lastTimerLayoutKey = nil
            KS.UpdateCombatTimers()
        end
        -- Ignore fade events here. The countdown expires from its authoritative
        -- activation time so an early effect fade cannot hide Onslaught while active.
        return
    elseif effectNorm:find("balorgh", 1, true) then
        if changeType == EFFECT_RESULT_FADED then
            KS.StopCombatTimer("balorgh")
        else
            KS.StartCombatTimer("balorgh", 12, endTime)
        end
    end
end

function KS.OnActionSlotAbilityUsed(eventCode, actionSlotIndex)
    -- EVENT_ACTION_SLOT_ABILITY_USED reports the physical action-bar slot. ESO's
    -- ACTION_BAR_ULTIMATE_SLOT_INDEX is the zero-offset logical index (7), while
    -- the physical Ultimate slot used by action-bar APIs and this event is +1 (8).
    -- Comparing directly with ACTION_BAR_ULTIMATE_SLOT_INDEX incorrectly treats
    -- skill slot 5 (physical slot 7) as an Ultimate, which is why Streak could
    -- start Balorgh. Only physical slot 8 is accepted here.
    local ultimateSlotIndex = (tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX) or 7) + 1
    if tonumber(actionSlotIndex) ~= ultimateSlotIndex then return end

    -- Resolve the active weapon bar explicitly. GetActiveHotbarCategory can return
    -- a non weapon category while temporary bars are active, so use the active
    -- weapon pair as the authoritative fallback for the normal front and back bars.
    local hotbar = GetActiveHotbarCategory and GetActiveHotbarCategory() or nil
    if GetActiveWeaponPairInfo then
        local weaponPair = GetActiveWeaponPairInfo()
        if weaponPair == ACTIVE_WEAPON_PAIR_MAIN and HOTBAR_CATEGORY_PRIMARY then
            hotbar = HOTBAR_CATEGORY_PRIMARY
        elseif weaponPair == ACTIVE_WEAPON_PAIR_BACKUP and HOTBAR_CATEGORY_BACKUP then
            hotbar = HOTBAR_CATEGORY_BACKUP
        end
    end

    local slotName = GetSlotName and GetSlotName(ultimateSlotIndex, hotbar) or ""
    local abilityId = GetSlotBoundId and GetSlotBoundId(ultimateSlotIndex, hotbar) or 0
    abilityId = tonumber(abilityId) or 0
    local abilityName = abilityId > 0 and GetAbilityName and GetAbilityName(abilityId) or ""

    -- The bound Ultimate ID/name is sufficient here and avoids transforming the
    -- ID through APIs that can return a different runtime effect ID.
    local isOnslaught = normalizeName(slotName):find("onslaught", 1, true) ~= nil
        or normalizeName(abilityName):find("onslaught", 1, true) ~= nil

    KS.lastUltimateEventSlot = tonumber(actionSlotIndex) or 0
    KS.lastUltimateEventHotbar = tonumber(hotbar) or 0
    KS.lastUltimateEventAbilityId = abilityId
    KS.lastUltimateEventSlotName = tostring(slotName or "")
    KS.lastUltimateEventAbilityName = tostring(abilityName or "")
    KS.lastUltimateEventWasOnslaught = isOnslaught and true or false

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0

    -- Onslaught's Update 49 penetration window is 8 seconds. Start it from the
    -- actual Ultimate activation event. Balorgh is independent and starts from the
    -- same Ultimate event only when its 2 piece bonus is equipped.
    if isOnslaught then
        KS.onslaughtExpiresAt = now + 8
    end
    if KS.balorghEquipped then
        KS.balorghExpiresAt = now + 12
    end

    KS.lastTimerLayoutKey = nil
    KS.UpdateCombatTimers()
end

local function applyHiddenStateToControl(control, hide)
    if not control then return false end
    if control.SetHiddenForReason then
        pcall(function() control:SetHiddenForReason("KjalnarStacksCustomTargetFrame", hide) end)
    end
    if control.SetHidden then
        local needsChange = true
        if control.IsHidden then
            local ok, current = pcall(function() return control:IsHidden() end)
            if ok and current == hide then needsChange = false end
        end
        if needsChange then pcall(function() control:SetHidden(hide) end) end
    end
    return true
end

function KS.ForceHideDefaultUnitFrameObject(unitFrame)
    if not unitFrame then return false end
    local hide = KS.ShouldHideDefaultTargetFrame()
    local control = unitFrame.frame or unitFrame.control or unitFrame.primaryControl

    -- During rapid target switching ZOS refreshes this object repeatedly. Once our
    -- persistent hidden reason is installed, avoid forcing SetHidden(true) again
    -- when the control is already hidden. Repeated SetHidden calls can invalidate UI
    -- layout and were one source of the target-switch hitch.
    if hide and control and control.IsHidden then
        local ok, alreadyHidden = pcall(function() return control:IsHidden() end)
        if ok and alreadyHidden then return true end
    end

    if unitFrame.SetHiddenForReason then
        pcall(function() unitFrame:SetHiddenForReason("KjalnarStacksCustomTargetFrame", hide) end)
    end

    if control then applyHiddenStateToControl(control, hide) end
    return true
end

function KS.InstallDefaultTargetFrameHooks()
    if KS.defaultTargetFrameHooksInstalled then return end
    KS.defaultTargetFrameHooksInstalled = true

    -- ZOS passes the actual unit-frame object to this function. Hiding it here
    -- means our hide runs after the stock reticle target has just refreshed.
    if ZO_PostHook and ZO_UnitFrames_UpdateWindow then
        ZO_PostHook("ZO_UnitFrames_UpdateWindow", function(unitTag, unitChanged, unitFrame)
            if unitTag == "reticleover" and KS.ShouldHideDefaultTargetFrame() then
                KS.ForceHideDefaultUnitFrameObject(unitFrame)
            end
        end)
    end

    -- Azurah and other UI addons can cause the stock unit frame to refresh again.
    -- This post-hook makes sure a refresh cannot leave it visible afterwards.
    if ZO_PostHook and ZO_UnitFrameObject and ZO_UnitFrameObject.RefreshVisible then
        ZO_PostHook(ZO_UnitFrameObject, "RefreshVisible", function(unitFrame)
            if unitFrame and unitFrame.unitTag == "reticleover" and KS.ShouldHideDefaultTargetFrame() then
                KS.ForceHideDefaultUnitFrameObject(unitFrame)
            end
        end)
    end
end

function KS.GetLUIETargetFrame()
    local tlw = _G["LUIE_CustomTargetFrame"]
    local frameData = nil
    if _G["LUIE"] and LUIE.UnitFrames and LUIE.UnitFrames.CustomFrames then
        frameData = LUIE.UnitFrames.CustomFrames["reticleover"]
        if frameData and frameData.tlw then tlw = frameData.tlw end
    end
    return tlw, frameData
end

local function setControlHiddenOnlyWhenNeeded(control, hide)
    if not control then return false end
    if control.IsHidden and control.SetHidden then
        local ok, current = pcall(function() return control:IsHidden() end)
        if not ok or current ~= hide then
            pcall(function() control:SetHidden(hide) end)
        end
    elseif control.SetHidden then
        pcall(function() control:SetHidden(hide) end)
    end
    if control.GetAlpha and control.SetAlpha then
        local wanted = hide and 0 or 1
        local ok, current = pcall(function() return control:GetAlpha() end)
        if not ok or math.abs((tonumber(current) or wanted) - wanted) > 0.01 then
            pcall(function() control:SetAlpha(wanted) end)
        end
    end
    return true
end

function KS.ApplyLUIETargetFrameVisibility()
    local hide = (KS.sv and KS.sv.hideLUIETargetFrame == true)
        or (KS.ShouldHideEnemyTargetFramesOutsideCombat and KS.ShouldHideEnemyTargetFramesOutsideCombat())
    local tlw, frameData = KS.GetLUIETargetFrame()
    local applied = false

    if tlw then
        setControlHiddenOnlyWhenNeeded(tlw, hide)
        applied = true
    end

    if frameData and frameData.control then
        setControlHiddenOnlyWhenNeeded(frameData.control, hide)
        applied = true
    end

    return applied
end

function KS.ShouldShowNativePlayerCpFrame()
    -- Compatibility shim retained for older callers. Ultivite now renders player
    -- CP / level itself, so Target Frame Mode = Ultivite must never release ESO's
    -- stock reticle target frame just to obtain the native Champion icon.
    return false
end

function KS.SetShowPlayerTargetChampionPoints(enabled, silent)
    -- Compatibility shim for older profiles / callers. Player-target CP / level
    -- is now permanently enabled and cannot be disabled through Ultivite.
    if not KS.sv then return end
    KS.sv.showNativePlayerCpFrame = true
    if KS.ApplyDefaultTargetFrameVisibility then KS.ApplyDefaultTargetFrameVisibility() end
    KS.RefreshDisplay(true)
    if U and U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if not silent and d then
        d("[Ultivite] Player target CP / level: ALWAYS ON")
    end
end

function KS.ShouldHideEnemyTargetFramesOutsideCombat()
    if KS.IsPlayerInCombat() then return false end
    if not DoesUnitExist or not IsUnitAttackable then return false end

    local tags = { "reticleoverplayer", KS.unitTag or "reticleover" }
    for _, unitTag in ipairs(tags) do
        local okExists, exists = pcall(DoesUnitExist, unitTag)
        if okExists and exists then
            local okAttackable, attackable = pcall(IsUnitAttackable, unitTag)
            if okAttackable and attackable == true then return true end
        end
    end
    return false
end

function KS.ShouldHideDefaultTargetFrame()
    -- Ultivite ownership remains absolute. When Vanilla / Default owns the stock
    -- frame, suppress attackable enemy target frames outside combat so no enemy
    -- Health bar is shown merely from mouseover or targeting. Friendly/non-hostile
    -- target information is not affected by this combat-only rule.
    return (KS.sv ~= nil and KS.sv.hideDefaultTargetFrame == true)
        or KS.ShouldHideEnemyTargetFramesOutsideCombat()
end

function KS.ApplyDefaultTargetFrameVisibility()
    local hide = KS.ShouldHideDefaultTargetFrame()
    local applied = false
    local stockUnitFrame = nil

    if UNIT_FRAMES and UNIT_FRAMES.GetFrame then
        local ok, unitFrame = pcall(function() return UNIT_FRAMES:GetFrame("reticleover") end)
        if ok and unitFrame then
            stockUnitFrame = unitFrame
            KS.ForceHideDefaultUnitFrameObject(unitFrame)
            applied = true
        end
    end

    if UNIT_FRAMES and UNIT_FRAMES.SetFrameHiddenForReason then
        pcall(function()
            UNIT_FRAMES:SetFrameHiddenForReason("reticleover", "KjalnarStacksCustomTargetFrame", hide)
            applied = true
        end)
    end

    -- This is the real stock keyboard target-frame control name created by ZOS.
    local stockControl = _G["ZO_TargetUnitFramereticleover"]
    if stockControl then
        applyHiddenStateToControl(stockControl, hide)
        applied = true
    end

    if KS.ApplyLUIETargetFrameVisibility() then applied = true end
    -- Never perform the expensive GuiRoot duplicate-frame scan here. This function
    -- runs during reticle target changes. If we already know the duplicate control,
    -- hiding it is cheap; discovery is deferred by ScheduleOtherTargetFrameHide().
    if KS.dynamicHiddenTargetFrame and KS.ApplyOtherTargetFrameVisibility(false) then applied = true end

    -- When Vanilla / Default mode releases the stock frame, refresh its native
    -- level / Champion presentation so ESO immediately owns the complete frame again.
    if not hide and stockUnitFrame
        and DoesUnitExist and DoesUnitExist(KS.unitTag)
        and IsUnitPlayer and IsUnitPlayer(KS.unitTag) then
        if stockUnitFrame.UpdateLevel then
            pcall(function() stockUnitFrame:UpdateLevel() end)
        end
        if stockUnitFrame.RefreshVisible then
            pcall(function() stockUnitFrame:RefreshVisible(true) end)
        end
    end

    return applied
end

local function getControlName(control)
    if not control or not control.GetName then return "" end
    local ok, value = pcall(function() return control:GetName() end)
    return ok and tostring(value or "") or ""
end

local function isControlVisible(control)
    if not control then return false end
    if control.IsHidden then
        local ok, hidden = pcall(function() return control:IsHidden() end)
        if ok and hidden then return false end
    end
    if control.GetAlpha then
        local ok, alpha = pcall(function() return control:GetAlpha() end)
        if ok and tonumber(alpha) and tonumber(alpha) <= 0.01 then return false end
    end
    return true
end

local function isDescendantOf(control, ancestor)
    if not control or not ancestor then return false end
    local current = control
    for _ = 1, 24 do
        if current == ancestor then return true end
        if not current.GetParent then return false end
        local ok, parent = pcall(function() return current:GetParent() end)
        if not ok or not parent or parent == current then return false end
        current = parent
    end
    return false
end

function KS.IsProtectedReticleControl(control)
    if not control then return false end

    local stockTargetFrame = _G["ZO_TargetUnitFramereticleover"]
    if stockTargetFrame then
        if control == stockTargetFrame then return true end
        if isDescendantOf(control, stockTargetFrame) then return true end
        if isDescendantOf(stockTargetFrame, control) then return true end
    end

    local mouseoverCpFrame = KS.nativeReticlePlayerFrame and KS.nativeReticlePlayerFrame.frame or nil
    if mouseoverCpFrame then
        if control == mouseoverCpFrame then return true end
        if isDescendantOf(control, mouseoverCpFrame) then return true end
        if isDescendantOf(mouseoverCpFrame, control) then return true end
    end

    local mouseoverCpBadge = KS.nativeReticlePlayerBadge
    if mouseoverCpBadge then
        if control == mouseoverCpBadge then return true end
        if isDescendantOf(control, mouseoverCpBadge) then return true end
        if isDescendantOf(mouseoverCpBadge, control) then return true end
    end

    local reticleContainer = _G["ZO_ReticleContainer"]
    if not reticleContainer then return false end

    -- ESO's resource-node / container / door / NPC interaction prompt lives under
    -- ZO_ReticleContainer. Never let the duplicate target-frame detector suppress
    -- that branch or any parent that would also hide it.
    if control == reticleContainer then return true end
    if isDescendantOf(control, reticleContainer) then return true end
    if isDescendantOf(reticleContainer, control) then return true end
    return false
end

function KS.RepairReticleInteractionUI()
    local reticleContainer = _G["ZO_ReticleContainer"]
    if reticleContainer and reticleContainer.SetAlpha then
        pcall(function() reticleContainer:SetAlpha(1) end)
    end

    -- Let ZOS immediately restore the correct hidden/interact state after an older
    -- UltiviteCombat version accidentally suppressed this branch.
    if _G["RETICLE"] then
        if RETICLE.UpdateHiddenState then pcall(function() RETICLE:UpdateHiddenState() end) end
        if RETICLE.UpdateInteractText then
            local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
            pcall(function() RETICLE:UpdateInteractText(now) end)
        end
    end
end

local function stripControlText(value)
    local s = tostring(value or "")
    s = s:gsub("|c%x%x%x%x%x%x", "")
    s = s:gsub("|r", "")
    s = s:gsub("|t.-|t", "")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

local function getParent(control)
    if not control or not control.GetParent then return nil end
    local ok, parent = pcall(function() return control:GetParent() end)
    if ok then return parent end
    return nil
end

local function findCommonAncestor(a, b)
    if not a or not b then return nil end
    local ancestors = {}
    local current = a
    for depth = 1, 24 do
        if not current then break end
        ancestors[current] = depth
        current = getParent(current)
    end
    current = b
    for _ = 1, 24 do
        if not current then break end
        if ancestors[current] then return current end
        current = getParent(current)
    end
    return nil
end

local function getControlDimensions(control)
    local width, height = 0, 0
    if control and control.GetWidth then
        local ok, value = pcall(function() return control:GetWidth() end)
        if ok then width = tonumber(value) or 0 end
    end
    if control and control.GetHeight then
        local ok, value = pcall(function() return control:GetHeight() end)
        if ok then height = tonumber(value) or 0 end
    end
    return width, height
end

function KS.FindOtherVisibleTargetFrame(printResult)
    local liveReticle = DoesUnitExist and DoesUnitExist("reticleover")
    local targetName = ""
    local hp, hpMax = 0, 0

    if liveReticle then
        targetName = cleanName(GetUnitName("reticleover"))
        if GetUnitPower then hp, hpMax = GetUnitPower("reticleover", COMBAT_MECHANIC_FLAGS_HEALTH) end
    end
    if targetName == "" then
        targetName = KS.currentTarget ~= "" and KS.currentTarget or KS.selectedTarget or ""
        local cached = KS.targetInfoCache and KS.targetInfoCache[targetName] or nil
        if cached then
            hp = tonumber(cached.health) or 0
            hpMax = tonumber(cached.healthMax) or 0
        end
    end

    if targetName == "" then
        if printResult then chat("Duplicate-frame scan: no target is available. Target something so the unwanted frame is visible, then press Identify and hide duplicate target frame.") end
        return nil
    end

    local targetNorm = normalizeName(targetName)
    local pctText = nil
    if tonumber(hpMax) and hpMax > 0 then
        pctText = string.format("%d%%", math.floor((tonumber(hp) or 0) * 100 / hpMax + 0.5))
    end
    local hpPlain = formatInt(hp)

    local nameControls = {}
    local valueControls = {}
    local seen = {}

    local reticleContainer = _G["ZO_ReticleContainer"]
    local function walk(control, depth)
        if not control or depth > 28 or seen[control] then return end
        seen[control] = true

        -- Interaction prompts are unrelated to target frames and must never be
        -- considered as duplicate-frame text matches. Skipping the entire branch
        -- also makes the one-time discovery scan cheaper.
        if reticleContainer and control == reticleContainer then return end

        if control ~= KS.root and not isDescendantOf(control, KS.root) and isControlVisible(control) then
            if control.GetText then
                local ok, rawText = pcall(function() return control:GetText() end)
                if ok and rawText and rawText ~= "" then
                    local cleanText = stripControlText(rawText)
                    local normalized = normalizeName(cleanText)
                    if normalized ~= "" and normalized:find(targetNorm, 1, true) then
                        table.insert(nameControls, control)
                    end
                    if (pctText and cleanText:find(pctText, 1, true)) or (hpPlain ~= "0" and cleanText:find(hpPlain, 1, true)) then
                        table.insert(valueControls, control)
                    end
                end
            end
        end

        if control.GetNumChildren and control.GetChild then
            local ok, count = pcall(function() return control:GetNumChildren() end)
            count = ok and tonumber(count) or 0
            for i = 1, math.min(count or 0, 500) do
                local childOk, child = pcall(function() return control:GetChild(i) end)
                if childOk and child then walk(child, depth + 1) end
            end
        end
    end

    walk(GuiRoot, 0)

    local best = nil
    local bestArea = nil
    local function consider(common)
        if not common or common == GuiRoot or common == KS.root or isDescendantOf(common, KS.root) then return end
        if KS.IsProtectedReticleControl(common) then return end
        local width, height = getControlDimensions(common)
        if width >= 180 and width <= 1400 and height >= 24 and height <= 260 then
            local area = width * height
            if not best or area < bestArea then
                best = common
                bestArea = area
            end
        end
    end

    -- Strong match: target name and either health or percentage share a parent.
    for _, nameControl in ipairs(nameControls) do
        for _, valueControl in ipairs(valueControls) do
            consider(findCommonAncestor(nameControl, valueControl))
        end
    end

    -- Fallback for addons where health text is rendered by a statusbar and not a label.
    -- Walk upward from each target-name label and choose the smallest frame-shaped parent.
    if not best then
        for _, nameControl in ipairs(nameControls) do
            local current = nameControl
            for _ = 1, 10 do
                current = getParent(current)
                if not current or current == GuiRoot then break end
                consider(current)
            end
        end
    end

    if printResult then
        chat(string.format("Duplicate-frame scan: target=%s | nameMatches=%d | healthMatches=%d", targetName, #nameControls, #valueControls))
        for i = 1, math.min(#nameControls, 8) do
            local c = nameControls[i]
            local w,h = getControlDimensions(c)
            chat(string.format("NAME[%d] %s %dx%d", i, getControlName(c) ~= "" and getControlName(c) or "<unnamed>", math.floor(w+0.5), math.floor(h+0.5)))
            local parent = c
            local chain = {}
            for depth = 1, 7 do
                parent = getParent(parent)
                if not parent or parent == GuiRoot then break end
                local pw,ph = getControlDimensions(parent)
                table.insert(chain, string.format("%s[%dx%d]", getControlName(parent) ~= "" and getControlName(parent) or "<unnamed>", math.floor(pw+0.5), math.floor(ph+0.5)))
            end
            if #chain > 0 then chat("PARENTS: " .. table.concat(chain, " > ")) end
        end
    end

    if best then
        local width, height = getControlDimensions(best)
        if printResult then
            chat(string.format("DUPLICATE FOUND: %s size=%dx%d. Hiding it now.", getControlName(best) ~= "" and getControlName(best) or "<unnamed>", math.floor(width + 0.5), math.floor(height + 0.5)))
        end
        return best
    end

    if printResult then chat("Duplicate-frame scan found the target-name labels but no safe frame-shaped parent to hide. Send the NAME and PARENTS lines above.") end
    return nil
end

function KS.ApplyOtherTargetFrameVisibility(printResult)
    local hide = KS.sv and KS.sv.autoHideOtherTargetFrames == true
    if not hide then
        local state = KS.dynamicHiddenTargetFrameState
        if state and state.control and state.control.SetAlpha and state.wasAlpha ~= nil then
            pcall(function() state.control:SetAlpha(state.wasAlpha) end)
        end
        KS.dynamicHiddenTargetFrame = nil
        KS.dynamicHiddenTargetFrameState = nil
        return false
    end

    local candidate = KS.dynamicHiddenTargetFrame
    if candidate and candidate ~= KS.root then
        -- Safety first: a learned control from an older build may be ESO's general
        -- reticle interaction branch. Restore it and forget it instead of hiding
        -- resource-node / container / NPC prompts.
        if KS.IsProtectedReticleControl(candidate) then
            local state = KS.dynamicHiddenTargetFrameState
            if candidate.SetAlpha then
                local restoreAlpha = state and state.wasAlpha ~= nil and state.wasAlpha or 1
                pcall(function() candidate:SetAlpha(restoreAlpha) end)
            end
            KS.dynamicHiddenTargetFrame = nil
            KS.dynamicHiddenTargetFrameState = nil
            if KS.sv then KS.sv.externalTargetFrameControlName = "" end
            KS.RepairReticleInteractionUI()
            return false
        end

        -- Alpha-only suppression avoids forcing another addon's layout to recalculate
        -- on target switches. Never call SetHidden on a dynamically learned frame.
        if candidate.SetAlpha then
            local ok, alpha = pcall(function() return candidate:GetAlpha() end)
            if not ok or (tonumber(alpha) or 1) > 0.01 then
                pcall(function() candidate:SetAlpha(0) end)
            end
            return true
        end
        return false
    end

    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if not printResult and KS.lastExternalTargetScanMs and nowMs > 0 and (nowMs - KS.lastExternalTargetScanMs) < 1000 then
        return false
    end
    KS.lastExternalTargetScanMs = nowMs

    if DoesUnitExist and DoesUnitExist("reticleover") then
        local found = KS.FindOtherVisibleTargetFrame(printResult)
        if found and found ~= KS.root and not KS.IsProtectedReticleControl(found) then
            local wasHidden, wasAlpha = false, 1
            if found.IsHidden then
                local ok, value = pcall(function() return found:IsHidden() end)
                if ok then wasHidden = value and true or false end
            end
            if found.GetAlpha then
                local ok, value = pcall(function() return found:GetAlpha() end)
                if ok and tonumber(value) then wasAlpha = tonumber(value) end
            end
            KS.dynamicHiddenTargetFrame = found
            KS.dynamicHiddenTargetFrameState = { control = found, wasHidden = wasHidden, wasAlpha = wasAlpha }
            local foundName = getControlName(found)
            if KS.sv and foundName ~= "" then
                KS.sv.externalTargetFrameControlName = foundName
            end
            if found.SetAlpha then pcall(function() found:SetAlpha(0) end) end
            return true
        elseif found and KS.IsProtectedReticleControl(found) then
            if printResult then chat("Duplicate-frame scan rejected a protected ESO reticle interaction control. Resource/interact prompts were left untouched.") end
        end
    elseif printResult then
        chat("External target scan: target something first, then press the scan button.")
    end

    return false
end

function KS.ScheduleOtherTargetFrameHide(delayMs)
    if not KS.sv or KS.sv.autoHideOtherTargetFrames ~= true then return end

    -- Once the duplicate control has been learned, this is a tiny state check only.
    if KS.dynamicHiddenTargetFrame then
        KS.ApplyOtherTargetFrameVisibility(false)
        return
    end

    -- Discovery walks GuiRoot and can be expensive. Never do that in the same frame
    -- as EVENT_RETICLE_TARGET_CHANGED. Coalesce rapid target switches into one scan.
    if KS.externalTargetScanScheduled then return end
    KS.externalTargetScanScheduled = true
    zo_callLater(function()
        KS.externalTargetScanScheduled = false
        if KS.sv and KS.sv.autoHideOtherTargetFrames == true and not KS.dynamicHiddenTargetFrame then
            KS.ApplyOtherTargetFrameVisibility(false)
        end
    end, tonumber(delayMs) or 250)
end

function KS.PrintTargetFrameDiagnostic()
    local unitFrame = nil
    if UNIT_FRAMES and UNIT_FRAMES.GetFrame then
        local ok, value = pcall(function() return UNIT_FRAMES:GetFrame("reticleover") end)
        if ok then unitFrame = value end
    end
    local stockControl = _G["ZO_TargetUnitFramereticleover"]
    local stockHidden = stockControl and stockControl.IsHidden and stockControl:IsHidden() or nil
    local azurahLoaded = _G["Azurah"] ~= nil
    local azScale, azOpacity, azCombatOpacity = nil, nil, nil
    if azurahLoaded and Azurah.CheckModified then
        pcall(function()
            azScale, azOpacity, azCombatOpacity = Azurah:CheckModified("ZO_TargetUnitFramereticleover")
        end)
    end

    local luieLoaded = _G["LUIE"] ~= nil
    local luieTarget, luieFrameData = KS.GetLUIETargetFrame()
    local luieHidden = luieTarget and luieTarget.IsHidden and luieTarget:IsHidden() or nil

    local dynamicName = KS.dynamicHiddenTargetFrame and getControlName(KS.dynamicHiddenTargetFrame) or ""
    chat(string.format("Target diagnostic: stockObject=%s | stockControl=%s | stockHidden=%s | Azurah=%s | Azurah scale=%s opacity=%s combatOpacity=%s | LUIE=%s | LUIETarget=%s | LUIEHidden=%s | dynamic=%s",
        tostring(unitFrame ~= nil), tostring(stockControl ~= nil), tostring(stockHidden), tostring(azurahLoaded),
        tostring(azScale), tostring(azOpacity), tostring(azCombatOpacity), tostring(luieLoaded),
        tostring(luieTarget ~= nil or luieFrameData ~= nil), tostring(luieHidden), dynamicName ~= "" and dynamicName or "none"))
end

function KS.PrintDiagnostic()
    local exists = DoesUnitExist and DoesUnitExist(KS.unitTag) or false
    local liveName = exists and cleanName(GetUnitName(KS.unitTag)) or ""
    local isPlayer = exists and IsUnitPlayer and IsUnitPlayer(KS.unitTag) or false
    local attackable = exists and IsUnitAttackable and IsUnitAttackable(KS.unitTag) or false
    local dead = exists and IsUnitDead and IsUnitDead(KS.unitTag) or false
    local preferred = KS.HasPreferredTarget()
    local hudAllowed = KS.IsHUDAllowed()

    local rootHidden = KS.root and KS.root.IsHidden and KS.root:IsHidden() or true
    local rootX, rootY = nil, nil
    if KS.root and KS.root.GetCenter then rootX, rootY = KS.root:GetCenter() end
    local gw, gh = GuiRoot:GetDimensions()
    local probeHas3D = KS.worldProbe and KS.worldProbe.Has3DRenderSpace and KS.worldProbe:Has3DRenderSpace() or false
    local probeSystem = "n/a"
    if KS.worldProbe and KS.worldProbe.Get3DRenderSpaceSystem then
        local ok, v = pcall(function() return KS.worldProbe:Get3DRenderSpaceSystem() end)
        if ok then probeSystem = tostring(v) end
    end

    local c = KS.diagCounters or {}
    chat(string.format("DIAG v%s target=%s selected=%s current=%s exists=%s player=%s attackable=%s dead=%s preferred=%s",
        tostring(KS.version), liveName ~= "" and liveName or "none",
        KS.selectedTarget ~= "" and KS.selectedTarget or "none",
        KS.currentTarget ~= "" and KS.currentTarget or "none",
        diagBool(exists), diagBool(isPlayer), diagBool(attackable), diagBool(dead), diagBool(preferred)))
    chat(string.format("DIAG frame hidden=%s requestedVisible=%s locked=%s followMode=%s followAvailable=%s fallback=%s HUD=%s rootCenter=%s,%s GuiRoot=%s,%s",
        diagBool(rootHidden), diagBool(KS.lastRootVisible == true), diagBool(KS.sv and KS.sv.locked == true),
        diagBool(KS.IsWorldFollowMode()), diagBool(KS.worldFollowAvailable == true), diagBool(KS.fallbackActive == true),
        diagBool(hudAllowed), tostring(rootX), tostring(rootY), tostring(gw), tostring(gh)))
    -- ESOUI policy forbids querying the position of a non-grouped reticle
    -- target. Diagnostics intentionally report the safe fallback state only.
    chat(string.format("DIAG target-world-position=not-queried | source=%s failure=%s",
        tostring(KS.lastWorldPositionSource or "none"), tostring(KS.lastWorldFailure or "none")))
    chat(string.format("DIAG probe=%s system=%s events reticle=%s power=%s worldOK=%s worldFail=%s",
        diagBool(probeHas3D), probeSystem, tostring(c.reticle or 0), tostring(c.power or 0), tostring(c.worldSuccess or 0), tostring(c.worldFail or 0)))

    if KS.sv then
        chat(string.format("DIAG nativeOverhead=%s allEnemyHB=%s allHB=%s npcHB=%s playerHB=%s allNP=%s npcNP=%s playerNP=%s",
            diagBool(KS.sv.nativeOverheadTargetBar == true),
            diagBool(KS.sv.nativeAllEnemyHealthbars == true),
            KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_HEALTHBARS),
            KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS),
            KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS),
            KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES),
            KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES),
            KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES)))
    end

    local snap = KS.lastWorldSuccessSnapshot
    if snap then
        chat(string.format("DIAG lastOK at=%s screen=%.1f,%.1f world=%s,%s,%s via=%s",
            tostring(snap.at or 0), tonumber(snap.screenX) or 0, tonumber(snap.screenY) or 0,
            tostring(snap.worldX), tostring(snap.worldY), tostring(snap.worldZ), tostring(snap.source)))
    else
        chat("DIAG lastOK=none")
    end
end

function KS.PrintDiagnosticLog()
    KS.PrintDiagnostic()
    local log = KS.diagLog or {}
    if #log == 0 then
        chat("DIAGLOG empty")
        return
    end
    local first = math.max(1, #log - 11)
    for i = first, #log do
        chat("DIAGLOG " .. tostring(log[i]))
    end
end

function KS.ClearDiagnosticLog()
    KS.diagLog = {}
    KS.diagCounters = { reticle = 0, power = 0, worldSuccess = 0, worldFail = 0 }
    KS.lastWorldFailure = "cleared"
    KS.lastWorldSuccessSnapshot = nil
    chat("Diagnostics cleared. Mouse over or tab target an enemy, move for a few seconds, then run /ks diaglog.")
end

function KS.PrintWorldFollowDiagnostic()
    KS.PrintDiagnostic()
end

local NATIVE_NAMEPLATE_SETTINGS = {
    { key = "nativeOriginalAllHealthbars", id = function() return NAMEPLATE_TYPE_ALL_HEALTHBARS end },
    { key = "nativeOriginalAllNameplates", id = function() return NAMEPLATE_TYPE_ALL_NAMEPLATES end },
    { key = "nativeOriginalEnemyNpcHealthbars", id = function() return NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS end },
    { key = "nativeOriginalEnemyPlayerHealthbars", id = function() return NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS end },
    { key = "nativeOriginalEnemyNpcNameplates", id = function() return NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES end },
    { key = "nativeOriginalEnemyPlayerNameplates", id = function() return NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES end },
    { key = "nativeOriginalFriendlyNpcNameplates", id = function() return NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES end },
    { key = "nativeOriginalNeutralNpcNameplates", id = function() return NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES end },
}

function KS.GetNativeNameplateSetting(settingId)
    if not GetSetting or not SETTING_TYPE_NAMEPLATES or settingId == nil then return "" end
    local ok, value = pcall(GetSetting, SETTING_TYPE_NAMEPLATES, settingId)
    if not ok or value == nil then return "" end
    return tostring(value)
end

function KS.SetNativeNameplateSetting(settingId, value)
    if not SetSetting or not SETTING_TYPE_NAMEPLATES or settingId == nil or value == nil or tostring(value) == "" then return false end
    value = tostring(value)
    if KS.GetNativeNameplateSetting(settingId) == value then return true end

    local option = SETTINGS_SET_OPTION_DO_NOT_SAVE_TO_PERSISTED_DATA
    local ok
    if option ~= nil then
        ok = pcall(SetSetting, SETTING_TYPE_NAMEPLATES, settingId, value, option)
    else
        ok = pcall(SetSetting, SETTING_TYPE_NAMEPLATES, settingId, value)
    end
    if not ok then return false end
    return KS.GetNativeNameplateSetting(settingId) == value
end

function KS.GetNativeNameplateOffChoice()
    if NAMEPLATE_CHOICE_NEVER ~= nil then return NAMEPLATE_CHOICE_NEVER end
    if NAMEPLATE_CHOICE_NONE ~= nil then return NAMEPLATE_CHOICE_NONE end
    return 0
end

-- Enemy overhead Health bars have a separate transient snapshot from native
-- target-mode ownership. This lets ESO Default remain combat-only without
-- capturing or later restoring unrelated player/NPC name settings.
function KS.CaptureEnemyHealthbarCombatGate()
    if KS.enemyHealthbarCombatSnapshot then return true end
    KS.enemyHealthbarCombatSnapshot = {
        all = KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_HEALTHBARS),
        npc = KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS),
        player = KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS),
    }
    return true
end

function KS.RestoreEnemyHealthbarCombatGate()
    local snapshot = KS.enemyHealthbarCombatSnapshot
    if type(snapshot) ~= "table" then return true end

    local ok = true
    if snapshot.all and snapshot.all ~= "" then
        ok = KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_HEALTHBARS, snapshot.all) and ok
    end
    if snapshot.npc and snapshot.npc ~= "" then
        ok = KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS, snapshot.npc) and ok
    end
    if snapshot.player and snapshot.player ~= "" then
        ok = KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS, snapshot.player) and ok
    end
    if ok then KS.enemyHealthbarCombatSnapshot = nil end
    return ok
end

-- When a user changes ESO's persisted Health-bar choices while either temporary
-- owner is active, update the relevant restoration snapshot immediately.
function KS.RememberNativeHealthbarPreference(settingId, value)
    if not KS.sv or settingId == nil or value == nil then return false end
    value = tostring(value)

    local gate = KS.enemyHealthbarCombatSnapshot
    if settingId == NAMEPLATE_TYPE_ALL_HEALTHBARS then
        if gate then gate.all = value end
        if KS.sv.nativeSettingsCaptured == true then KS.sv.nativeOriginalAllHealthbars = value end
        return true
    end
    if settingId == NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS then
        if gate then gate.npc = value end
        if KS.sv.nativeSettingsCaptured == true then KS.sv.nativeOriginalEnemyNpcHealthbars = value end
        return true
    end
    if settingId == NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS then
        if gate then gate.player = value end
        if KS.sv.nativeSettingsCaptured == true then KS.sv.nativeOriginalEnemyPlayerHealthbars = value end
        return true
    end
    return false
end

function KS.SetPersistedNameplateSetting(settingId, value)
    if not SetSetting or SETTING_TYPE_NAMEPLATES == nil or settingId == nil or value == nil then return false end
    value = tostring(value)
    if KS.GetNativeNameplateSetting(settingId) == value then return true end

    local option = SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA
    local ok
    if option ~= nil then
        ok = pcall(SetSetting, SETTING_TYPE_NAMEPLATES, settingId, value, option)
    else
        ok = pcall(SetSetting, SETTING_TYPE_NAMEPLATES, settingId, value)
    end
    if not ok then return false end
    return KS.GetNativeNameplateSetting(settingId) == value
end

function KS.ApplyNpcNamesOverride()
    if not KS.sv or KS.sv.npcNamesOverrideActive ~= true then return false end

    local hidden = KS.sv.npcNamesGlobalHidden == true
    local choice
    if hidden then
        choice = KS.GetNativeNameplateOffChoice()
    else
        choice = NAMEPLATE_CHOICE_ALWAYS
        if choice == nil then choice = NAMEPLATE_CHOICE_TARGETED end
        if choice == nil then return false end
        if NAMEPLATE_TYPE_ALL_NAMEPLATES ~= nil then
            KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES, 1)
        end
    end

    local ok = true
    ok = KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, choice) and ok
    ok = KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, choice) and ok
    ok = KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, choice) and ok
    return ok
end

function KS.SetNpcNamesHidden(hidden)
    if not KS.sv then return false end
    KS.sv.npcNamesOverrideActive = true
    KS.sv.npcNamesGlobalHidden = hidden and true or false

    local function ReapplyNpcNameOwner()
        if not KS.sv then return end
        if KS.sv.nativeOverheadTargetBar == true then
            KS.ApplyNativeOverheadTargetBar()
        else
            KS.ApplyNpcNamesOverride()
        end
    end

    ReapplyNpcNameOwner()

    -- ESO and other UI modules can refresh nameplate settings on the same frame.
    -- Reassert after that refresh so the explicit user choice remains authoritative.
    if zo_callLater then
        zo_callLater(ReapplyNpcNameOwner, 50)
        zo_callLater(ReapplyNpcNameOwner, 250)
    end
    return true
end

function KS.ClearNpcNamesOverride()
    if not KS.sv then return end
    KS.sv.npcNamesOverrideActive = false
end

function KS.IsNpcNamesHidden()
    if not KS.sv then return false end
    if KS.sv.npcNamesOverrideActive == true then
        return KS.sv.npcNamesGlobalHidden == true
    end
    local master = NAMEPLATE_TYPE_ALL_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES) or "1"
    if master == "0" or master == "false" then return true end
    local off = tostring(KS.GetNativeNameplateOffChoice())
    local enemy = NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES) or ""
    local friendly = NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES) or ""
    local neutral = NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES) or ""
    return enemy == off and friendly == off and neutral == off
end


function KS.CaptureNativeNameplateSettings()
    if not KS.sv or KS.sv.nativeSettingsCaptured == true then return end
    for _, setting in ipairs(NATIVE_NAMEPLATE_SETTINGS) do
        local id = setting.id()
        KS.sv[setting.key] = KS.GetNativeNameplateSetting(id)
    end
    KS.sv.nativeSettingsCaptured = true
end

function KS.RestoreNativeNameplateSettings()
    if not KS.sv or KS.sv.nativeSettingsCaptured ~= true then return true end
    local restored = true
    for _, setting in ipairs(NATIVE_NAMEPLATE_SETTINGS) do
        local value = tostring(KS.sv[setting.key] or "")
        if value ~= "" then
            restored = KS.SetNativeNameplateSetting(setting.id(), value) and restored
        end
    end

    -- One ownership cycle only. A permanent snapshot can overwrite later
    -- changes the player makes in ESO's own nameplate settings. Keep the
    -- snapshot if ESO rejected any write so a later refresh can retry safely.
    if restored then
        KS.sv.nativeSettingsCaptured = false
        for _, setting in ipairs(NATIVE_NAMEPLATE_SETTINGS) do
            KS.sv[setting.key] = ""
        end
    end
    return restored
end


function KS.ApplyPlayerNamesOverride()
    if not KS.sv or KS.sv.playerNamesOverrideActive ~= true then return false end

    local hidden = KS.sv.playerNamesGlobalHidden == true
    local choice
    if hidden then
        choice = KS.GetNativeNameplateOffChoice()
    else
        choice = NAMEPLATE_CHOICE_ALWAYS or NAMEPLATE_CHOICE_TARGETED
        if choice == nil then return false end
        if NAMEPLATE_TYPE_ALL_NAMEPLATES ~= nil then
            KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES, 1)
        end
    end

    local ok = true
    if NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES ~= nil then
        ok = KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES, choice) and ok
    end
    if NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES ~= nil then
        ok = KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES, choice) and ok
    end
    if NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES ~= nil then
        ok = KS.SetPersistedNameplateSetting(NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, choice) and ok
    end
    return ok
end

function KS.SetPlayerNamesHidden(hidden, silent)
    if not KS.sv then return false end
    KS.sv.playerNamesOverrideActive = true
    KS.sv.playerNamesGlobalHidden = hidden and true or false

    local ok = KS.ApplyPlayerNamesOverride()
    if KS.ApplyNativeOverheadTargetBar then KS.ApplyNativeOverheadTargetBar() end
    KS.ApplyPlayerNamesOverride()

    -- ESO/nameplate modules can refresh in the same frame. Reassert the explicit
    -- user choice twice without coupling it to Overhead Player Info.
    if zo_callLater then
        zo_callLater(function() if KS.sv then KS.ApplyPlayerNamesOverride() end end, 100)
        zo_callLater(function() if KS.sv then KS.ApplyPlayerNamesOverride() end end, 500)
    end
    if U and U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if not silent then chat(hidden and "Player names hidden." or "Player names shown.") end
    return ok
end

function KS.ClearPlayerNamesOverride()
    if not KS.sv then return end
    KS.sv.playerNamesOverrideActive = false
end

function KS.IsPlayerNamesHidden()
    if not KS.sv then return false end
    if KS.sv.playerNamesOverrideActive == true then
        return KS.sv.playerNamesGlobalHidden == true
    end
    local master = NAMEPLATE_TYPE_ALL_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES) or "1"
    if master == "0" or master == "false" then return true end
    local off = tostring(KS.GetNativeNameplateOffChoice())
    local enemy = NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES) or ""
    local friendly = NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES) or ""
    local group = NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES ~= nil and KS.GetNativeNameplateSetting(NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES) or ""
    return enemy == off and friendly == off and group == off
end

function KS.ApplyNativeOverheadTargetBar()
    if not KS.sv then return false end

    -- Dark Souls presets can suppress ESO's engine-rendered overhead Health bars
    -- without permanently changing the player's ESO nameplate preferences. The
    -- original values are captured once and restored when this option is disabled.
    if KS.sv.hideNativeOverheadHealthBars == true then
        KS.CaptureNativeNameplateSettings()
        local hidden = KS.GetNativeNameplateOffChoice()
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_HEALTHBARS, 0)
        if NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS ~= nil then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS, hidden)
        end
        if NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS ~= nil then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS, hidden)
        end
        KS.ApplyNpcNamesOverride()
        KS.ApplyPlayerNamesOverride()
        return true
    end

    -- All enemy overhead Health-bar modes are combat-only. ESO Default uses a
    -- small Health-bar-only snapshot, while native Target/All mode keeps using its
    -- existing full ownership snapshot so disabling that mode still restores the
    -- user's original ESO nameplate configuration.
    if not KS.IsPlayerInCombat() then
        if KS.sv.nativeOverheadTargetBar == true then
            KS.CaptureNativeNameplateSettings()
            local originalMaster = tostring(KS.sv.nativeOriginalAllHealthbars or "")
            if originalMaster ~= "" then
                KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_HEALTHBARS, originalMaster)
            end
        else
            KS.CaptureEnemyHealthbarCombatGate()
        end

        local hidden = KS.GetNativeNameplateOffChoice()
        if NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS ~= nil then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS, hidden)
        end
        if NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS ~= nil then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS, hidden)
        end
        KS.ApplyNpcNamesOverride()
        KS.ApplyPlayerNamesOverride()
        return true
    end

    if KS.sv.nativeOverheadTargetBar ~= true then
        KS.RestoreEnemyHealthbarCombatGate()
        KS.ApplyNpcNamesOverride()
        KS.ApplyPlayerNamesOverride()
        return false
    end

    KS.enemyHealthbarCombatSnapshot = nil
    KS.CaptureNativeNameplateSettings()

    -- ESO's own in-world nameplate renderer owns the unit-to-screen attachment.
    -- Targeted enemy nameplates and healthbars therefore remain physically bound
    -- to the unit even when reticleover is unavailable to Lua. For enemy
    -- healthbars, ESO only accepts NEVER, TARGETED, INJURED,
    -- INJURED_OR_TARGETED, or ALWAYS. NAMEPLATE_CHOICE_ALL is not valid here.
    local targeted = NAMEPLATE_CHOICE_TARGETED
    local allEnemies = NAMEPLATE_CHOICE_ALWAYS
    local hidden = KS.GetNativeNameplateOffChoice()
    if targeted == nil then return false end

    local enemyHealthbarChoice = targeted
    if KS.sv.nativeAllEnemyHealthbars == true and allEnemies ~= nil then
        enemyHealthbarChoice = allEnemies
    end

    KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_HEALTHBARS, 1)
    KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS, enemyHealthbarChoice)
    KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS, enemyHealthbarChoice)

    -- Enemy overhead Health bars and player/NPC names are separate controls.
    -- Native overhead mode must not silently turn names on. If Ultivite owns a
    -- high-level name choice, reapply it. Otherwise preserve the ESO values that
    -- were present before native overhead mode took ownership of the Health bars.
    local playerOverrideActive = KS.sv.playerNamesOverrideActive == true
    local npcOverrideActive = KS.sv.npcNamesOverrideActive == true
    if not playerOverrideActive and not npcOverrideActive then
        local allNamesOriginal = tostring(KS.sv.nativeOriginalAllNameplates or "")
        if allNamesOriginal ~= "" then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ALL_NAMEPLATES, allNamesOriginal)
        end
    end

    if playerOverrideActive then
        KS.ApplyPlayerNamesOverride()
    else
        local enemyPlayerOriginal = tostring(KS.sv.nativeOriginalEnemyPlayerNameplates or "")
        if enemyPlayerOriginal ~= "" then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES, enemyPlayerOriginal)
        end
    end

    local globalHidden = npcOverrideActive and KS.sv.npcNamesGlobalHidden == true
    local hideNpcNamesHere = KS.sv.nativeHideNpcNames == true or globalHidden

    if hideNpcNamesHere then
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, hidden)
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, hidden)
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, hidden)
    elseif npcOverrideActive then
        local always = NAMEPLATE_CHOICE_ALWAYS or targeted
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, always)
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, always)
        KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, always)
    else
        local enemyOriginal = tostring(KS.sv.nativeOriginalEnemyNpcNameplates or "")
        local friendlyOriginal = tostring(KS.sv.nativeOriginalFriendlyNpcNameplates or "")
        local neutralOriginal = tostring(KS.sv.nativeOriginalNeutralNpcNameplates or "")
        if enemyOriginal ~= "" then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, enemyOriginal)
        end
        if friendlyOriginal ~= "" then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, friendlyOriginal)
        end
        if neutralOriginal ~= "" then
            KS.SetNativeNameplateSetting(NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, neutralOriginal)
        end
    end
    return true
end

function KS.SetNativeOverheadTargetBar(enabled)
    if not KS.sv then return end
    enabled = enabled and true or false
    local wasEnabled = KS.sv.nativeOverheadTargetBar == true

    if enabled then
        -- If ESO Default was currently suppressed outside combat, restore those
        -- intended values before capturing native-mode ownership. Otherwise native
        -- mode would incorrectly remember Never as the user's original choice.
        KS.RestoreEnemyHealthbarCombatGate()
        if KS.sv.nativeSettingsCaptured ~= true then KS.CaptureNativeNameplateSettings() end
        KS.sv.hideNativeOverheadHealthBars = false
    elseif wasEnabled and KS.sv.hideNativeOverheadHealthBars ~= true then
        KS.RestoreNativeNameplateSettings()
    end

    KS.sv.nativeOverheadTargetBar = enabled
    KS.ApplyNativeOverheadTargetBar()
    KS.ApplyPosition()
    KS.RefreshDisplay()
    KS.UpdateCombatTimers()
    chat(enabled and "Native overhead target healthbar enabled." or "Native overhead target healthbar disabled; previous nameplate settings restored.")
end

function KS.IsNativeOverheadMode()
    return KS.sv and KS.sv.nativeOverheadTargetBar == true
end

function KS.SetHideNativeOverheadHealthBars(enabled, silent)
    if not KS.sv then return end
    enabled = enabled and true or false

    if enabled then
        KS.RestoreEnemyHealthbarCombatGate()
        if KS.sv.nativeSettingsCaptured ~= true then KS.CaptureNativeNameplateSettings() end
        KS.sv.hideNativeOverheadHealthBars = true
        KS.sv.nativeOverheadTargetBar = false
    else
        KS.sv.hideNativeOverheadHealthBars = false
        KS.RestoreNativeNameplateSettings()
    end

    KS.ApplyNativeOverheadTargetBar()
    KS.ApplyPosition()
    KS.RefreshDisplay()
    if not silent then
        chat(enabled and "Default overhead Health bars hidden." or "Default overhead Health bars restored.")
    end
end

function KS.GetHideNativeOverheadHealthBars()
    return KS.sv and KS.sv.hideNativeOverheadHealthBars == true
end

-- One canonical controller for ESO overhead enemy health bars. This is kept
-- completely separate from Target Frame Mode so changing overhead bars can
-- never silently enable or disable Ultivite's target frame again.
function KS.GetEnemyOverheadHealthMode()
    if not KS.sv then return "vanilla" end
    if KS.sv.hideNativeOverheadHealthBars == true then return "off" end
    if KS.sv.nativeOverheadTargetBar == true then
        return KS.sv.nativeAllEnemyHealthbars == true and "all" or "target"
    end
    return "vanilla"
end

function KS.SetEnemyOverheadHealthMode(mode, silent)
    if not KS.sv then return false end
    mode = tostring(mode or "vanilla")
    if mode ~= "off" and mode ~= "target" and mode ~= "all" then mode = "vanilla" end

    if mode == "off" then
        KS.sv.nativeAllEnemyHealthbars = false
        KS.SetHideNativeOverheadHealthBars(true, true)
    elseif mode == "vanilla" then
        KS.RestoreEnemyHealthbarCombatGate()
        KS.RestoreNativeNameplateSettings()
        KS.sv.hideNativeOverheadHealthBars = false
        KS.sv.nativeOverheadTargetBar = false
        KS.sv.nativeAllEnemyHealthbars = false
        KS.ApplyNativeOverheadTargetBar()
        KS.ApplyPosition()
        KS.RefreshDisplay()
    else
        KS.RestoreEnemyHealthbarCombatGate()
        if KS.sv.nativeSettingsCaptured ~= true then KS.CaptureNativeNameplateSettings() end
        KS.sv.hideNativeOverheadHealthBars = false
        KS.sv.nativeOverheadTargetBar = true
        KS.sv.nativeAllEnemyHealthbars = mode == "all"
        KS.ApplyNativeOverheadTargetBar()
        KS.ApplyPosition()
        KS.RefreshDisplay()
    end

    if U and U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if not silent then
        local labels = { vanilla = "ESO default", target = "target only", all = "all enemies", off = "hidden" }
        chat("Enemy overhead Health bars: " .. (labels[mode] or labels.vanilla))
    end
    return true
end


local OVERHEAD_PLAYER_INFO_UPDATE_MS = 100
local OVERHEAD_PLAYER_INFO_HEAD_OFFSET_CM = 225
local OVERHEAD_PLAYER_INFO_SCREEN_GAP = 12

KS.overheadPlayerInfoGroupLabels = KS.overheadPlayerInfoGroupLabels or {}
KS.overheadPlayerInfoGroupCount = KS.overheadPlayerInfoGroupCount or 0
KS.overheadPlayerInfoVisibleCount = KS.overheadPlayerInfoVisibleCount or 0
KS.overheadPlayerInfoReticleLabel = KS.overheadPlayerInfoReticleLabel or nil
KS.overheadPlayerInfoProbe = KS.overheadPlayerInfoProbe or nil
KS.overheadPlayerInfoReticleCache = KS.overheadPlayerInfoReticleCache or nil
KS.overheadPlayerInfoTargetBridgeLabel = KS.overheadPlayerInfoTargetBridgeLabel or nil
KS.nativeReticlePlayerFrame = KS.nativeReticlePlayerFrame or nil

-- 1.0.192 keeps true world projection limited to stable group unit tags. API
-- 101050 exposes the targeted ungrouped player and CP through reticleoverplayer,
-- but ESO's native floating nameplate is engine-owned and has no writable Lua
-- text control or arbitrary-player world position. In native overhead mode,
-- Ultivite therefore renders a compact player-name + CP bridge at the supported
-- screen-space target-frame location. The normal Ultivite target frame continues
-- to render name + CP directly when native overhead mode is not active.
-- EVENT_UNIT_CREATED is deliberately not used as an arbitrary-player discovery path.

-- CP diagnostics cover group world projection plus targeted-player name presentation.
-- No global scans and no protected APIs.
KS.worldCpDiag = KS.worldCpDiag or {
    reticleChanged = 0,
    reticlePlayerChanged = 0,
    reticleCaptures = 0,
    reticleMisses = 0,
    pollPlayerHits = 0,
    pollPlayerLosses = 0,
    lastReticle = nil,
    lastPollTag = "",
    lastPollAtMs = 0,
}
local function WorldCpDiagNowMs()
    return GetGameTimeMilliseconds and (tonumber(GetGameTimeMilliseconds()) or 0) or 0
end

local function WorldCpDiagSafeCall(fn, ...)
    if type(fn) ~= "function" then return false, nil end
    return pcall(fn, ...)
end

function KS.IsOverheadPlayerInfoEnabled()
    -- Ultivite 1.0.173: player CP / level presentation is no longer an optional
    -- HUD feature. It stays enabled whenever the combat module is available.
    return KS.sv ~= nil
end

-- Player CP / level presentation is Ultivite-owned. Group members can use
-- world-follow labels because stable group unit tags expose position. Ungrouped
-- players use target-frame or reticle presentation only. Native player names are
-- controlled independently by the Player Names option.
function KS.ApplyOverheadPlayerInfoNameplates()
    if KS.ApplyPlayerNamesOverride then KS.ApplyPlayerNamesOverride() end
    if KS.sv then KS.sv.overheadPlayerInfo = true end
    return KS.sv ~= nil
end

local function GetUnitLevelSafe(unitTag)
    local level = 0
    if GetUnitLevel then
        local ok, value = pcall(GetUnitLevel, unitTag)
        if ok then level = tonumber(value) or 0 end
    end
    if level <= 0 and GetUnitEffectiveLevel then
        local ok, value = pcall(GetUnitEffectiveLevel, unitTag)
        if ok then level = tonumber(value) or 0 end
    end
    return math.max(0, level)
end

local function GetUnitChampionPointsSafe(unitTag)
    -- Do not gate CP lookup behind IsUnitChampion(). ESO can expose a valid
    -- Champion Point value on short-lived world unit tags before every other
    -- unit-state helper has settled. The CP value itself is authoritative.
    local cp = 0
    if GetUnitEffectiveChampionPoints then
        local ok, value = pcall(GetUnitEffectiveChampionPoints, unitTag)
        if ok then cp = tonumber(value) or 0 end
    end
    if cp <= 0 and GetUnitChampionPoints then
        local ok, value = pcall(GetUnitChampionPoints, unitTag)
        if ok then cp = tonumber(value) or 0 end
    end
    return math.max(0, cp)
end

local function CaptureWorldCpUnitSnapshot(unitTag, source)
    local snapshot = {
        atMs = WorldCpDiagNowMs(),
        source = tostring(source or "snapshot"),
        tag = tostring(unitTag or ""),
        exists = false,
        isPlayer = false,
        displayName = "",
        rawName = "",
        cpEffective = 0,
        cpBase = 0,
        canGainCp = false,
        level = 0,
        effectiveLevel = 0,
        grouped = false,
        zoneId = 0,
        worldX = 0,
        worldY = 0,
        worldZ = 0,
        hasWorldPosition = false,
        projected = false,
        screenX = nil,
        screenY = nil,
    }

    if snapshot.tag == "" then return snapshot end

    do
        local ok, value = WorldCpDiagSafeCall(DoesUnitExist, snapshot.tag)
        snapshot.exists = ok and value == true
    end
    do
        local ok, value = WorldCpDiagSafeCall(IsUnitPlayer, snapshot.tag)
        snapshot.isPlayer = ok and value == true
    end
    do
        local ok, value = WorldCpDiagSafeCall(GetUnitDisplayName, snapshot.tag)
        if ok and type(value) == "string" then snapshot.displayName = value end
    end
    do
        local ok, value = WorldCpDiagSafeCall(GetRawUnitName, snapshot.tag)
        if ok and type(value) == "string" then snapshot.rawName = value end
    end
    do
        local ok, value = WorldCpDiagSafeCall(GetUnitEffectiveChampionPoints, snapshot.tag)
        if ok then snapshot.cpEffective = math.max(0, tonumber(value) or 0) end
    end
    do
        local ok, value = WorldCpDiagSafeCall(GetUnitChampionPoints, snapshot.tag)
        if ok then snapshot.cpBase = math.max(0, tonumber(value) or 0) end
    end
    do
        local ok, value = WorldCpDiagSafeCall(CanUnitGainChampionPoints, snapshot.tag)
        snapshot.canGainCp = ok and value == true
    end
    do
        local ok, value = WorldCpDiagSafeCall(GetUnitLevel, snapshot.tag)
        if ok then snapshot.level = math.max(0, tonumber(value) or 0) end
    end
    do
        local ok, value = WorldCpDiagSafeCall(GetUnitEffectiveLevel, snapshot.tag)
        if ok then snapshot.effectiveLevel = math.max(0, tonumber(value) or 0) end
    end
    do
        local ok, value = WorldCpDiagSafeCall(IsUnitGrouped, snapshot.tag)
        snapshot.grouped = ok and value == true
    end
    -- World positioning is intentionally sampled only for grouped players.
    -- API 101050 exposes CP for reticleoverplayer but does not expose usable
    -- arbitrary ungrouped-player world coordinates. Do not keep probing a path
    -- the client has already proven unavailable.
    local stableGroupTag = string.match(snapshot.tag, "^group%d+$") ~= nil
    local groupWorldPosition = GetUnitRawWorldPosition or GetUnitWorldPosition
    if stableGroupTag and type(groupWorldPosition) == "function" then
        local ok, zoneId, worldX, worldY, worldZ = pcall(groupWorldPosition, snapshot.tag)
        if ok then
            snapshot.zoneId = tonumber(zoneId) or 0
            snapshot.worldX = tonumber(worldX) or 0
            snapshot.worldY = tonumber(worldY) or 0
            snapshot.worldZ = tonumber(worldZ) or 0
            snapshot.hasWorldPosition = snapshot.zoneId > 0
                and not (snapshot.worldX == 0 and snapshot.worldY == 0 and snapshot.worldZ == 0)
        end
    end
    if snapshot.exists and snapshot.isPlayer and stableGroupTag and KS.GetUnitHeadScreenPosition then
        local ok, sx, sy = pcall(KS.GetUnitHeadScreenPosition, snapshot.tag)
        if ok and tonumber(sx) and tonumber(sy) then
            snapshot.projected = true
            snapshot.screenX = tonumber(sx)
            snapshot.screenY = tonumber(sy)
        end
    end
    return snapshot
end

local function FormatWorldCpSnapshot(snapshot)
    if not snapshot then return "none" end
    local name = snapshot.displayName ~= "" and snapshot.displayName
        or (snapshot.rawName ~= "" and snapshot.rawName or "-")
    local world = snapshot.hasWorldPosition
        and string.format("z=%d xyz=%d,%d,%d",
            tonumber(snapshot.zoneId) or 0,
            tonumber(snapshot.worldX) or 0,
            tonumber(snapshot.worldY) or 0,
            tonumber(snapshot.worldZ) or 0)
        or "world=NO"
    local screen = snapshot.projected
        and string.format("screen=%.1f,%.1f", tonumber(snapshot.screenX) or 0, tonumber(snapshot.screenY) or 0)
        or "screen=NO"
    return string.format(
        "src=%s tag=%s exists=%s player=%s name=%s cpEff=%d cpBase=%d canCP=%s lv=%d effLv=%d grouped=%s %s %s",
        tostring(snapshot.source or "-"),
        tostring(snapshot.tag or "-"),
        diagBool(snapshot.exists),
        diagBool(snapshot.isPlayer),
        tostring(name),
        tonumber(snapshot.cpEffective) or 0,
        tonumber(snapshot.cpBase) or 0,
        diagBool(snapshot.canGainCp),
        tonumber(snapshot.level) or 0,
        tonumber(snapshot.effectiveLevel) or 0,
        diagBool(snapshot.grouped),
        world,
        screen)
end

function KS.CaptureWorldCpReticleDiagnostic(source)
    KS.worldCpDiag = KS.worldCpDiag or {}
    local diag = KS.worldCpDiag
    local unitTag = KS.GetActiveReticlePlayerTag and KS.GetActiveReticlePlayerTag() or nil
    if unitTag then
        local snapshot = CaptureWorldCpUnitSnapshot(unitTag, tostring(source or "reticle"))
        diag.reticleCaptures = (tonumber(diag.reticleCaptures) or 0) + 1
        diag.lastReticle = snapshot
        return snapshot
    end

    diag.reticleMisses = (tonumber(diag.reticleMisses) or 0) + 1
    return nil
end
function KS.ScheduleWorldCpReticleDiagnostic(source)
    KS.worldCpDiag = KS.worldCpDiag or {}
    local sourceText = tostring(source or "reticle")
    if sourceText == "EVENT_RETICLE_TARGET_CHANGED" then
        KS.worldCpDiag.reticleChanged = (tonumber(KS.worldCpDiag.reticleChanged) or 0) + 1
    elseif sourceText == "EVENT_RETICLE_TARGET_PLAYER_CHANGED" then
        KS.worldCpDiag.reticlePlayerChanged = (tonumber(KS.worldCpDiag.reticlePlayerChanged) or 0) + 1
    end

    -- One event-time sample is enough now that the production path also reads
    -- reticleoverplayer every 100 ms. Avoid diagnostic delayed callbacks fighting
    -- with rapidly changing reticle state.
    KS.CaptureWorldCpReticleDiagnostic(sourceText)
end
function KS.RecordWorldCpPollingDiagnostic(activeReticlePlayerTag)
    KS.worldCpDiag = KS.worldCpDiag or {}
    local diag = KS.worldCpDiag
    local nowMs = WorldCpDiagNowMs()
    local activeTag = tostring(activeReticlePlayerTag or "")
    local previousTag = tostring(diag.lastPollTag or "")

    if activeTag ~= "" then
        if activeTag ~= previousTag or (nowMs - (tonumber(diag.lastPollAtMs) or 0)) >= 500 then
            diag.pollPlayerHits = (tonumber(diag.pollPlayerHits) or 0) + 1
            local snapshot = CaptureWorldCpUnitSnapshot(activeTag, "PLAYER_CP_LOOP")
            if snapshot.exists and snapshot.isPlayer then
                diag.lastReticle = snapshot
            end
            diag.lastPollAtMs = nowMs
        end
    elseif previousTag ~= "" then
        diag.pollPlayerLosses = (tonumber(diag.pollPlayerLosses) or 0) + 1
    end

    diag.lastPollTag = activeTag
end
function KS.GetOverheadPlayerInfoText(unitTag)
    if not DoesUnitExist or not DoesUnitExist(unitTag) then return "" end
    if IsUnitPlayer and not IsUnitPlayer(unitTag) then return "" end

    -- Native ESO nameplates already own the player name, title and guild text.
    -- Ultivite adds only progression information so the world-space display does
    -- not duplicate the player's name. Champion players show CP; players below
    -- Champion level show their normal level.
    local cp = GetUnitChampionPointsSafe(unitTag)
    if cp > 0 then
        return string.format("CP %d", cp)
    end

    local level = GetUnitLevelSafe(unitTag)
    if level > 0 then
        return string.format("Lv %d", level)
    end
    return ""
end

local function GetTargetPlayerBridgeText(info)
    if not info or info.isPlayer ~= true then return "" end

    local name = KS.GetDisplayedTargetName and KS.GetDisplayedTargetName(info, tostring(info.name or ""))
        or tostring(info.displayName ~= "" and info.displayName or info.name or "")
    if name == "" then return "" end

    local title = ""
    if GetUnitTitle and type(info.unitTag) == "string" and info.unitTag ~= "" then
        local ok, value = pcall(GetUnitTitle, info.unitTag)
        if ok and type(value) == "string" and value ~= "" then
            title = cleanName(value)
        end
    end
    if title ~= "" then
        name = string.format("%s, %s", name, title)
    end

    local cp = tonumber(info.championPoints) or 0
    if cp > 0 then
        return string.format("%s   CP %d", name, cp)
    end

    local level = tonumber(info.level) or 0
    if level > 0 then
        return string.format("%s   Lv %d", name, level)
    end
    return name
end

function KS.PositionTargetPlayerProgressBridge()
    -- Retired before 1.0.191. Kept as a compatibility no-op for older callers.
end

function KS.GetTargetPlayerProgressBridgeLabel()
    if KS.overheadPlayerInfoTargetBridgeLabel then
        KS.overheadPlayerInfoTargetBridgeLabel:SetHidden(true)
    end
    return nil
end

local MOUSEOVER_CP_NAMEPLATE_OFFSET_Y = -72
local MOUSEOVER_CP_NAMEPLATE_GAP = 8

local function HideNativeReticlePlayerFrame()
    -- Native target-frame experiments are retired. Keep legacy references hidden
    -- defensively, then hide the independent mouseover progression label.
    local frame = KS.nativeReticlePlayerFrame
    if frame then
        if frame.SetHiddenForReason then
            pcall(function() frame:SetHiddenForReason("UltiviteMouseoverCp", true) end)
        end
        if frame.frame and frame.frame.SetHidden then
            pcall(function() frame.frame:SetHidden(true) end)
        end
    end
    local badge = KS.nativeReticlePlayerBadge
    if badge and badge.SetHidden then
        pcall(function() badge:SetHidden(true) end)
    end
end

local function GetMouseoverNativeNameLine(unitTag)
    if type(unitTag) ~= "string" or unitTag == "" then return "" end

    local name = ""
    if GetUnitDisplayName then
        local ok, value = pcall(GetUnitDisplayName, unitTag)
        if ok and type(value) == "string" then name = cleanName(value) end
    end
    if name == "" and GetUnitName then
        local ok, value = pcall(GetUnitName, unitTag)
        if ok and type(value) == "string" then name = cleanName(value) end
    end
    if name == "" then return "" end

    local title = ""
    if GetUnitTitle then
        local ok, value = pcall(GetUnitTitle, unitTag)
        if ok and type(value) == "string" then title = cleanName(value) end
    end
    if title ~= "" then
        return string.format("%s, %s", name, title)
    end
    return name
end

local function PositionMouseoverCpBadge(badge, unitTag, progressionText)
    if not badge or not badge.cpLabel or not GuiRoot then return false end

    local reticle = _G and _G["ZO_ReticleContainerReticle"] or nil
    local anchorTarget = reticle or GuiRoot
    local nameLine = GetMouseoverNativeNameLine(unitTag)
    local nameWidth = 0
    local progressionWidth = 0

    if badge.cpLabel.GetStringWidth then
        local okName, measuredName = pcall(function() return badge.cpLabel:GetStringWidth(nameLine) end)
        if okName then nameWidth = tonumber(measuredName) or 0 end
        local okProgress, measuredProgress = pcall(function() return badge.cpLabel:GetStringWidth(progressionText or "") end)
        if okProgress then progressionWidth = tonumber(measuredProgress) or 0 end
    end

    if progressionWidth <= 0 then progressionWidth = 78 end
    local badgeWidth = math.max(72, progressionWidth + 8)
    badge:SetDimensions(badgeWidth, 34)
    badge.cpLabel:SetDimensions(badgeWidth, 34)

    -- ESO's world nameplate itself is engine-owned, so there is no public anchor
    -- to attach to. While reticleoverplayer is active, reconstruct the displayed
    -- blue name/title width with the same font and place progression immediately
    -- after its expected right edge. This visually fuses CP with the highlighted
    -- line without bringing back a target frame or a distant standalone badge.
    local offsetX = (nameWidth * 0.5) + MOUSEOVER_CP_NAMEPLATE_GAP + (badgeWidth * 0.5)
    badge:ClearAnchors()
    badge:SetAnchor(CENTER, anchorTarget, CENTER, offsetX, MOUSEOVER_CP_NAMEPLATE_OFFSET_Y)

    badge._ultiviteNameLine = nameLine
    badge._ultiviteNameWidth = nameWidth
    badge._ultiviteProgressionWidth = progressionWidth
    badge._ultiviteOffsetX = offsetX
    badge._ultiviteOffsetY = MOUSEOVER_CP_NAMEPLATE_OFFSET_Y
    return true
end

local function EnsureMouseoverCpBadge()
    if KS.nativeReticlePlayerBadge and KS.nativeReticlePlayerBadge.cpLabel then
        return KS.nativeReticlePlayerBadge
    end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    -- Completely independent top-level label. No ZO_TargetUnitFrame controls are
    -- reused, so native target-frame hidden reasons cannot suppress it.
    local badge = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteMouseoverPlayerCpBadge")
    badge:SetDimensions(100, 34)
    badge:SetMouseEnabled(false)
    badge:SetMovable(false)
    if badge.SetClampedToScreen then badge:SetClampedToScreen(true) end
    if badge.SetDrawTier and DT_HIGH then badge:SetDrawTier(DT_HIGH) end
    if badge.SetDrawLayer and DL_OVERLAY then badge:SetDrawLayer(DL_OVERLAY) end
    if badge.SetDrawLevel then badge:SetDrawLevel(3000) end
    badge:SetHidden(true)

    local label = WINDOW_MANAGER:CreateControl("UltiviteMouseoverPlayerCpBadgeLabel", badge, CT_LABEL)
    label:SetAnchorFill(badge)
    label:SetFont("ZoFontGameBold")
    if label.SetVerticalAlignment and TEXT_ALIGN_CENTER then label:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetHorizontalAlignment and TEXT_ALIGN_CENTER then label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    label:SetMouseEnabled(false)
    if label.SetDrawTier and DT_HIGH then label:SetDrawTier(DT_HIGH) end
    if label.SetDrawLayer and DL_OVERLAY then label:SetDrawLayer(DL_OVERLAY) end
    if label.SetDrawLevel then label:SetDrawLevel(3001) end

    badge.cpIcon = nil
    badge.cpLabel = label
    KS.nativeReticlePlayerBadge = badge
    return badge
end

function KS.EnsureNativeReticlePlayerFrame()
    -- Compatibility name retained for callers. The mouseover CP presentation is
    -- now an independent Ultivite top-level badge, not a native target frame.
    return nil
end

function KS.IsCpOnHoverEnabled()
    return KS.sv ~= nil and KS.sv.cpOnHover ~= false
end

function KS.SetCpOnHoverEnabled(enabled, silent)
    if not KS.sv then return false end
    KS.sv.cpOnHover = enabled ~= false
    if KS.sv.cpOnHover ~= true then
        HideNativeReticlePlayerFrame()
    elseif KS.UpdateOverheadPlayerInfo then
        KS.UpdateOverheadPlayerInfo()
    end
    if U and U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if not silent then
        chat("CP on Hover: " .. (KS.sv.cpOnHover == true and "ON" or "OFF"))
    end
    return true
end

function KS.UpdateNativeReticlePlayerFrame(activeUnitTag, suppressForGroup)
    if not KS.IsCpOnHoverEnabled() then
        HideNativeReticlePlayerFrame()
        return false
    end
    if activeUnitTag ~= "reticleoverplayer" or suppressForGroup == true then
        HideNativeReticlePlayerFrame()
        return false
    end
    if not DoesUnitExist or not IsUnitPlayer
        or not DoesUnitExist("reticleoverplayer") or not IsUnitPlayer("reticleoverplayer") then
        HideNativeReticlePlayerFrame()
        return false
    end

    local badge = EnsureMouseoverCpBadge()
    if not badge or not badge.cpLabel then
        HideNativeReticlePlayerFrame()
        return false
    end

    local cp = GetUnitChampionPointsSafe("reticleoverplayer")
    local level = cp > 0 and 0 or GetUnitLevelSafe("reticleoverplayer")
    local hasValue = cp > 0 or level > 0
    if not hasValue then
        HideNativeReticlePlayerFrame()
        return false
    end

    local progressionText = cp > 0 and ("CP " .. tostring(cp)) or ("Lv " .. tostring(level))
    badge.cpLabel:SetText(progressionText)
    PositionMouseoverCpBadge(badge, "reticleoverplayer", progressionText)

    local r, g, b = 0.20, 0.80, 1.00
    if GetUnitReactionColor then
        local okColor, rr, gg, bb = pcall(GetUnitReactionColor, "reticleoverplayer")
        if okColor and tonumber(rr) and tonumber(gg) and tonumber(bb) then
            r, g, b = rr, gg, bb
        end
    end
    badge.cpLabel:SetColor(r, g, b, 1)
    badge.cpLabel:SetAlpha(1)
    badge.cpLabel:SetHidden(false)
    badge:SetAlpha(1)
    badge:SetHidden(false)

    local left, top, width, height = nil, nil, nil, nil
    if badge.GetLeft then pcall(function() left = badge:GetLeft() end) end
    if badge.GetTop then pcall(function() top = badge:GetTop() end) end
    if badge.GetWidth then pcall(function() width = badge:GetWidth() end) end
    if badge.GetHeight then pcall(function() height = badge:GetHeight() end) end

    KS.worldCpDiag = KS.worldCpDiag or {}
    KS.worldCpDiag.lastNativeReticlePlayerFrameRender = {
        atMs = WorldCpDiagNowMs(),
        tag = "reticleoverplayer",
        cp = cp,
        level = level,
        nameText = "",
        levelText = tostring(badge.cpLabel:GetText() or ""),
        visible = true,
        cpOnly = true,
        badgeLeft = tonumber(left),
        badgeTop = tonumber(top),
        badgeWidth = tonumber(width),
        badgeHeight = tonumber(height),
        offsetX = tonumber(badge._ultiviteOffsetX),
        offsetY = tonumber(badge._ultiviteOffsetY),
        nameLine = tostring(badge._ultiviteNameLine or ""),
        nameWidth = tonumber(badge._ultiviteNameWidth) or 0,
        progressionWidth = tonumber(badge._ultiviteProgressionWidth) or 0,
        directTopLevel = true,
        visuallyFusedToName = true,
    }
    return true
end

function KS.CreateOverheadPlayerInfoUi()
    if not WINDOW_MANAGER then return false end

    if not KS.overheadPlayerInfoProbe then
        local probe = WINDOW_MANAGER:CreateControl("UltiviteOverheadPlayerInfoProbe", GuiRoot, CT_TEXTURE)
        KS.overheadPlayerInfoProbe = probe
        probe:SetDimensions(1, 1)
        probe:SetMouseEnabled(false)
        probe:SetAlpha(0.001)
        probe:SetHidden(false)
        pcall(function()
            if probe.Create3DRenderSpace then probe:Create3DRenderSpace() end
            if probe.Set3DRenderSpaceSystem and GUI_RENDER_3D_SPACE_SYSTEM_WORLD then
                probe:Set3DRenderSpaceSystem(GUI_RENDER_3D_SPACE_SYSTEM_WORLD)
            end
            if probe.Set3DRenderSpaceUsesDepthBuffer then probe:Set3DRenderSpaceUsesDepthBuffer(false) end
            if probe.Set3DLocalDimensions then probe:Set3DLocalDimensions(0.01, 0.01) end
        end)
    end

    KS.EnsureNativeReticlePlayerFrame()
    return true
end

function KS.GetUnitHeadScreenPosition(unitTag)
    -- World-space CP is intentionally limited to stable groupN unit tags. API
    -- 101050 exposes CP for reticleoverplayer but not usable arbitrary-player
    -- world coordinates. Keep this helper fail-closed so future callers cannot
    -- accidentally reintroduce ungrouped-player projection attempts.
    if type(unitTag) ~= "string" or not string.match(unitTag, "^group%d+$") then return nil, nil end
    local groupWorldPosition = GetUnitRawWorldPosition or GetUnitWorldPosition
    if not KS.overheadPlayerInfoProbe or not groupWorldPosition or not WorldPositionToGuiRender3DPosition then
        return nil, nil
    end

    -- OdySupportIcons moved group world markers to raw positions to avoid
    -- remapping errors in places such as Imperial City and instanced zones.
    local okWorld, zoneId, worldX, worldY, worldZ = pcall(groupWorldPosition, unitTag)
    if not okWorld then return nil, nil end
    zoneId = tonumber(zoneId) or 0
    worldX = tonumber(worldX)
    worldY = tonumber(worldY)
    worldZ = tonumber(worldZ)
    if zoneId <= 0 or not worldX or not worldY or not worldZ then return nil, nil end
    if worldX == 0 and worldY == 0 and worldZ == 0 then return nil, nil end

    local okRender, renderX, renderY, renderZ = pcall(
        WorldPositionToGuiRender3DPosition,
        worldX,
        worldY + OVERHEAD_PLAYER_INFO_HEAD_OFFSET_CM,
        worldZ
    )
    if not okRender then return nil, nil end

    renderX, renderY, renderZ = tonumber(renderX), tonumber(renderY), tonumber(renderZ)
    if not renderX or not renderY or not renderZ then return nil, nil end

    local okOrigin = pcall(function()
        KS.overheadPlayerInfoProbe:Set3DRenderSpaceOrigin(renderX, renderY, renderZ)
    end)
    if not okOrigin then return nil, nil end

    local x, y
    if KS.overheadPlayerInfoProbe.ProjectToScreen then
        local okProject, sx, sy = pcall(function()
            return KS.overheadPlayerInfoProbe:ProjectToScreen(0.5, 0.5)
        end)
        if okProject then x, y = tonumber(sx), tonumber(sy) end
    elseif KS.overheadPlayerInfoProbe.ProjectRectToScreenAndComputeAABBPoint then
        local okProject, sx, sy = pcall(function()
            return KS.overheadPlayerInfoProbe:ProjectRectToScreenAndComputeAABBPoint(CENTER)
        end)
        if okProject then x, y = tonumber(sx), tonumber(sy) end
    end
    if not x or not y then return nil, nil end

    local rootWidth, rootHeight = GuiRoot:GetDimensions()
    rootWidth, rootHeight = tonumber(rootWidth) or 0, tonumber(rootHeight) or 0
    if rootWidth > 0 and rootHeight > 0 then
        if x < -100 or x > rootWidth + 100 or y < -100 or y > rootHeight + 100 then
            return nil, nil
        end
    end
    return x, y
end

function KS.GetOverheadPlayerInfoGroupLabel(index)
    local label = KS.overheadPlayerInfoGroupLabels[index]
    if label then return label end
    if not WINDOW_MANAGER then return nil end

    label = WINDOW_MANAGER:CreateControl("UltiviteOverheadPlayerInfoGroup" .. tostring(index), GuiRoot, CT_LABEL)
    KS.overheadPlayerInfoGroupLabels[index] = label
    label:SetDimensions(420, 24)
    label:SetFont("ZoFontGameShadow")
    label:SetColor(1, 1, 1, 1)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetMouseEnabled(false)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetHidden(true)
    return label
end

local function IsSameUnitSafe(unitTagA, unitTagB)
    if not unitTagA or not unitTagB or not DoesUnitExist or not AreUnitsEqual then return false end
    if not DoesUnitExist(unitTagA) or not DoesUnitExist(unitTagB) then return false end
    local ok, same = pcall(AreUnitsEqual, unitTagA, unitTagB)
    return ok and same == true
end

function KS.GetActiveReticlePlayerTag()
    -- Dedicated player targeting is authoritative. reticleover can simultaneously
    -- point at a pet, summon or other generic unit while reticleoverplayer contains
    -- the actual highlighted player.
    local candidates = { "reticleoverplayer", "reticleover" }
    for _, unitTag in ipairs(candidates) do
        if DoesUnitExist and IsUnitPlayer then
            local okExists, exists = pcall(DoesUnitExist, unitTag)
            local okPlayer, isPlayer = pcall(IsUnitPlayer, unitTag)
            if okExists and exists and okPlayer and isPlayer then
                return unitTag
            end
        end
    end
    return nil
end

function KS.GetLiveReticlePlayerPresentationInfo()
    local unitTag = KS.GetActiveReticlePlayerTag()
    if not unitTag then return nil end

    local name = ""
    if GetUnitName then
        local ok, value = pcall(GetUnitName, unitTag)
        if ok then name = cleanName(value) end
    end
    local displayName = ""
    if GetUnitDisplayName then
        local ok, value = pcall(GetUnitDisplayName, unitTag)
        if ok and type(value) == "string" then displayName = value end
    end
    if name == "" then name = cleanName(displayName) end
    if name == "" then return nil end

    local cp = GetUnitChampionPointsSafe(unitTag)
    local level = cp > 0 and 0 or GetUnitLevelSafe(unitTag)
    local health, healthMax = 0, 0
    if GetUnitPower then
        local ok, value, maxValue = pcall(GetUnitPower, unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
        if ok then
            health = tonumber(value) or 0
            healthMax = tonumber(maxValue) or 0
        end
    end

    return {
        unitTag = unitTag,
        name = name,
        isPlayer = true,
        displayName = displayName,
        className = "",
        classId = 0,
        championPoints = cp,
        level = level,
        health = health,
        healthMax = healthMax,
        updatedAt = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0,
    }
end

local function IsUltiviteTargetPlayerProgressActuallyVisible(activeUnitTag)
    -- Suppress the fallback only when the same targeted player has another
    -- Ultivite CP/level presentation that was actually rendered on screen.
    -- Settings are not evidence of visibility.
    local activeTag = tostring(activeUnitTag or "")
    if activeTag == "" then return false end

    local diag = KS.worldCpDiag or {}
    local render = diag.lastTargetNameRender
    if render and render.visible == true and tostring(render.tag or "") == activeTag then
        local ageMs = WorldCpDiagNowMs() - (tonumber(render.atMs) or 0)
        if ageMs >= 0 and ageMs <= 300 then
            return true
        end
    end

    -- The Dark Souls player frame has its own Champion icon/number. It is safe
    -- to treat it as an alternate only while it is visibly rendering a player.
    if Frames and Frames.IsDSEnemyPlayerPresentationVisible
        and Frames.IsDSEnemyPlayerPresentationVisible() then
        return true
    end

    return false
end

function KS.ShouldUseNativePlayerProgressBridge(activeUnitTag)
    if not KS.sv then return false end
    -- 1.0.184 incorrectly gated this fallback on nativeOverheadTargetBar. That
    -- setting controls enemy overhead health bars and is unrelated to ESO's
    -- engine-rendered player nameplate. A real targeted player now gets this
    -- bridge unless the same player already has confirmed Ultivite CP/level text.
    return not IsUltiviteTargetPlayerProgressActuallyVisible(activeUnitTag)
end

function KS.ShouldUseReticlePlayerProgressFallback()
    -- Compatibility shim for diagnostics/older callers. The old reticle-anchored
    -- label is retired; the supported fallback is now the top-centre target bridge.
    return KS.ShouldUseNativePlayerProgressBridge(KS.GetActiveReticlePlayerTag and KS.GetActiveReticlePlayerTag() or nil)
end

local function ApplyOverheadPlayerLabelColor(label, unitTag)
    if not label then return end
    if GetUnitReactionColor then
        local ok, r, g, b = pcall(GetUnitReactionColor, unitTag)
        if ok and tonumber(r) and tonumber(g) and tonumber(b) then
            label:SetColor(r, g, b, 1)
            return
        end
    end
    label:SetColor(1, 1, 1, 1)
end

function KS.InstallOverheadPlayerUnitTracking()
    if KS.overheadPlayerUnitTrackingInstalled then return end
    KS.overheadPlayerUnitTrackingInstalled = true

    -- Reticle handling is consolidated into the main target-change registrations
    -- during initialization. Keep this compatibility initializer so settings and
    -- older callers can safely request the runtime without creating duplicate
    -- event writers.
    KS.worldCpReticleChangedRegistered = EVENT_RETICLE_TARGET_CHANGED ~= nil
    KS.worldCpReticlePlayerChangedRegistered = EVENT_RETICLE_TARGET_PLAYER_CHANGED ~= nil
end

function KS.HideOverheadPlayerInfo()
    HideNativeReticlePlayerFrame()
    if KS.overheadPlayerInfoReticleLabel then
        KS.overheadPlayerInfoReticleLabel:SetHidden(true)
    end
    if KS.overheadPlayerInfoTargetBridgeLabel then
        KS.overheadPlayerInfoTargetBridgeLabel:SetHidden(true)
    end
    for _, label in pairs(KS.overheadPlayerInfoGroupLabels or {}) do
        if label then label:SetHidden(true) end
    end
end

function KS.UpdateOverheadPlayerInfo()
    if not KS.sv then
        KS.HideOverheadPlayerInfo()
        return
    end
    local immersive = U and U.Immersive
    if immersive and immersive.ShouldHideOverheadPlayerInfo and immersive.ShouldHideOverheadPlayerInfo() then
        KS.HideOverheadPlayerInfo()
        return
    end
    KS.sv.overheadPlayerInfo = true
    if not KS.CreateOverheadPlayerInfoUi() then return end

    local activeReticlePlayerTag = KS.GetActiveReticlePlayerTag()
    KS.RecordWorldCpPollingDiagnostic(activeReticlePlayerTag)

    -- Supported world-follow path: stable group unit tags only.
    local groupSize = 0
    if GetGroupSize then
        local ok, value = pcall(GetGroupSize)
        if ok then groupSize = math.max(0, math.min(tonumber(value) or 0, tonumber(GROUP_SIZE_MAX) or 24)) end
    end
    local reticleIsGroupMember = false
    local reticleGroupLabelVisible = false
    local visibleGroupCount = 0
    for index = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex and GetGroupUnitTagByIndex(index) or nil
        if type(unitTag) ~= "string" or unitTag == "" then
            unitTag = "group" .. tostring(index)
        end
        local label = KS.GetOverheadPlayerInfoGroupLabel(index)
        local visible = false
        if label and DoesUnitExist and DoesUnitExist(unitTag) then
            local matchesReticle = activeReticlePlayerTag and IsSameUnitSafe(unitTag, activeReticlePlayerTag) or false
            if matchesReticle then reticleIsGroupMember = true end
            local textValue = KS.GetOverheadPlayerInfoText(unitTag)
            if textValue ~= "" then
                local x, y = KS.GetUnitHeadScreenPosition(unitTag)
                if x and y then
                    label:SetText(textValue)
                    ApplyOverheadPlayerLabelColor(label, unitTag)
                    label:ClearAnchors()
                    label:SetAnchor(BOTTOM, GuiRoot, TOPLEFT, x, y - OVERHEAD_PLAYER_INFO_SCREEN_GAP)
                    label:SetHidden(false)
                    visible = true
                    visibleGroupCount = visibleGroupCount + 1
                    if matchesReticle then reticleGroupLabelVisible = true end
                end
            end
        end
        if label and not visible then label:SetHidden(true) end
    end
    for index = groupSize + 1, tonumber(GROUP_SIZE_MAX) or 24 do
        local label = KS.overheadPlayerInfoGroupLabels[index]
        if label then label:SetHidden(true) end
    end
    KS.overheadPlayerInfoGroupCount = groupSize
    KS.overheadPlayerInfoVisibleCount = visibleGroupCount

    -- Mouseover-only player CP badge. ESO does not expose a writable blue
    -- floating nameplate, so use only the proven native Champion icon/level
    -- controls and position that compact pair directly under the nameplate area.
    -- If a group world label already occupies the same player, suppress the
    -- mouseover badge to avoid duplicate CP values.
    local reticleLabel = KS.overheadPlayerInfoReticleLabel
    if reticleLabel then reticleLabel:SetHidden(true) end
    if KS.overheadPlayerInfoTargetBridgeLabel then
        KS.overheadPlayerInfoTargetBridgeLabel:SetHidden(true)
    end
    local mouseoverCpVisible = KS.UpdateNativeReticlePlayerFrame(activeReticlePlayerTag, reticleGroupLabelVisible == true)

    KS.overheadPlayerInfoLastReticleTag = activeReticlePlayerTag or ""
    KS.overheadPlayerInfoLastReticleCp = activeReticlePlayerTag and GetUnitChampionPointsSafe(activeReticlePlayerTag) or 0
    KS.overheadPlayerInfoLastReticleProjected = false
    KS.overheadPlayerInfoLastReticleFallback = mouseoverCpVisible == true
    KS.overheadPlayerInfoLastReticleGrace = false
    KS.overheadPlayerInfoLastReticleGroupMatch = reticleIsGroupMember == true
    KS.overheadPlayerInfoLastReticleTrackedMatch = false
    KS.overheadPlayerInfoLastReticleAlternateVisible = reticleGroupLabelVisible == true
end

function KS.RefreshOverheadPlayerInfoRuntime()
    if not EVENT_MANAGER then return end
    local updateName = KS.name .. "OverheadPlayerInfo"
    if KS.sv then
        -- CP / level is an always-on presentation rule from 1.0.172 onward.
        KS.sv.overheadPlayerInfo = true
        KS.CreateOverheadPlayerInfoUi()
        KS.InstallOverheadPlayerUnitTracking()
        if not KS.overheadPlayerInfoUpdateRegistered then
            EVENT_MANAGER:RegisterForUpdate(updateName, OVERHEAD_PLAYER_INFO_UPDATE_MS, function()
                KS.UpdateOverheadPlayerInfo()
            end)
            KS.overheadPlayerInfoUpdateRegistered = true
        end
        KS.UpdateOverheadPlayerInfo()
    else
        if KS.overheadPlayerInfoUpdateRegistered then
            EVENT_MANAGER:UnregisterForUpdate(updateName)
            KS.overheadPlayerInfoUpdateRegistered = false
        end
        KS.HideOverheadPlayerInfo()
    end
end

function KS.SetOverheadPlayerInfoEnabled(enabled, silent)
    if not KS.sv then return end
    -- Compatibility entry point retained for older profiles/callers. The setting
    -- is deliberately forced on because CP / level should accompany player HUD
    -- information whenever ESO exposes a usable player unitTag.
    KS.sv.overheadPlayerInfo = true
    KS.RefreshOverheadPlayerInfoRuntime()
    if KS.ApplyPlayerNamesOverride then KS.ApplyPlayerNamesOverride() end
    if U and U.RequestSettingsSave then U.RequestSettingsSave(true) end

    if not silent then
        chat("Player CP / level: ALWAYS ON")
    end
end

function KS.IsWorldFollowMode()
    -- Legacy target-frame world-follow is permanently disabled. Group CP labels
    -- have their own independent world-follow path and must never move the main
    -- target frame or force it onto the fallback anchor.
    return false
end

function KS.GetWorldPlayerCpDiagnostics()
    return tonumber(KS.overheadPlayerInfoGroupCount) or 0,
        tonumber(KS.overheadPlayerInfoVisibleCount) or 0,
        tostring(KS.overheadPlayerInfoLastReticleTag or ""),
        tonumber(KS.overheadPlayerInfoLastReticleCp) or 0,
        false
end

function KS.ClearWorldPlayerCpDiagnostic()
    KS.worldCpDiag = {
        reticleChanged = 0,
        reticlePlayerChanged = 0,
        reticleCaptures = 0,
        reticleMisses = 0,
        pollPlayerHits = 0,
        pollPlayerLosses = 0,
        lastReticle = nil,
        lastPollTag = "",
        lastPollAtMs = 0,
        lastTargetNameRender = nil,
        lastNativePlayerBridgeRender = nil,
    }
    chat("CP diagnostics reset. Look directly at a player, then run /ulticpdiag. Group world labels, native-overhead bridge, and custom target-frame CP are reported separately.")
end

local worldCpDiagCollector = nil

local function WorldCpDiagChat(message)
    local line = "CP DIAG | " .. tostring(message or "")
    if worldCpDiagCollector then
        worldCpDiagCollector[#worldCpDiagCollector + 1] = line
    else
        chat(line)
    end
end

local function WorldCpDiagPrintSnapshot(prefix, snapshot)
    WorldCpDiagChat(tostring(prefix) .. " " .. FormatWorldCpSnapshot(snapshot))
end

local function EmitWorldPlayerCpDiagnostic()
    KS.UpdateOverheadPlayerInfo()
    KS.RefreshDisplay(true)

    local diag = KS.worldCpDiag or {}
    local apiVersion = GetAPIVersion and tonumber(GetAPIVersion()) or 0
    local groupCount = tonumber(KS.overheadPlayerInfoGroupCount) or 0
    local groupVisible = tonumber(KS.overheadPlayerInfoVisibleCount) or 0
    local livePlayer = KS.GetLiveReticlePlayerPresentationInfo()

    WorldCpDiagChat(string.format("BEGIN | Ultivite 1.0.200 | API=%d", apiVersion))
    WorldCpDiagChat("Architecture: groupTags=world-follow | mouseoverPlayer=reticle-driven CP visually fused to measured blue name/title width | nativeNameplateText=engine-owned")
    WorldCpDiagChat("CP on Hover: " .. (KS.IsCpOnHoverEnabled() and "ON" or "OFF"))
    WorldCpDiagChat(string.format(
        "Tracking: installed=%s reticleChanged=%s reticlePlayerChanged=%s groupTags=%d groupVisible=%d",
        diagBool(KS.overheadPlayerUnitTrackingInstalled == true),
        diagBool(KS.worldCpReticleChangedRegistered == true),
        diagBool(KS.worldCpReticlePlayerChangedRegistered == true),
        groupCount, groupVisible))

    WorldCpDiagPrintSnapshot("NOW reticleoverplayer:", CaptureWorldCpUnitSnapshot("reticleoverplayer", "command"))
    WorldCpDiagPrintSnapshot("NOW reticleover:", CaptureWorldCpUnitSnapshot("reticleover", "command"))

    if livePlayer then
        WorldCpDiagChat(string.format(
            "Target presentation: tag=%s name=%s cp=%d level=%d health=%d/%d mode=%s",
            tostring(livePlayer.unitTag or ""), tostring(livePlayer.displayName ~= "" and livePlayer.displayName or livePlayer.name or ""),
            tonumber(livePlayer.championPoints) or 0, tonumber(livePlayer.level) or 0,
            tonumber(livePlayer.health) or 0, tonumber(livePlayer.healthMax) or 0,
            "engine-nameplate-unaddressable"))
    else
        WorldCpDiagChat("Target presentation: NONE")
    end

    local lastReticle = diag.lastReticle
    if lastReticle then
        local ageMs = math.max(0, WorldCpDiagNowMs() - (tonumber(lastReticle.atMs) or 0))
        WorldCpDiagPrintSnapshot(string.format("LAST player target (%dms ago):", ageMs), lastReticle)
    else
        WorldCpDiagChat("LAST player target: NONE")
    end

    WorldCpDiagChat(string.format(
        "Events: reticle=%d playerReticle=%d captures=%d misses=%d worldLoopHits=%d worldLoopLosses=%d",
        tonumber(diag.reticleChanged) or 0, tonumber(diag.reticlePlayerChanged) or 0,
        tonumber(diag.reticleCaptures) or 0, tonumber(diag.reticleMisses) or 0,
        tonumber(diag.pollPlayerHits) or 0, tonumber(diag.pollPlayerLosses) or 0))

    WorldCpDiagChat("Reticle indicator: RETIRED | native floating nameplate is not writable")

    HideNativeReticlePlayerFrame()
    WorldCpDiagChat("Native mouseover CP badge: independent top-level label; name/title width measured with ZoFontGameBold; CP placed after expected blue-line right edge; Y=-72 from ESO reticle")
    if diag.lastNativeReticlePlayerFrameRender then
        local render = diag.lastNativeReticlePlayerFrameRender
        local renderAge = math.max(0, WorldCpDiagNowMs() - (tonumber(render.atMs) or 0))
        WorldCpDiagChat(string.format(
            "LAST mouseover CP badge %dms ago: tag=%s cp=%d level=%d visible=%s text=%q cpOnly=%s nameLine=%q nameWidth=%.1f offset=%.1f,%.1f rect=%s",
            renderAge, tostring(render.tag or ""), tonumber(render.cp) or 0,
            tonumber(render.level) or 0, diagBool(render.visible == true),
            tostring(render.levelText or ""), diagBool(render.cpOnly == true),
            tostring(render.nameLine or ""), tonumber(render.nameWidth) or 0,
            tonumber(render.offsetX) or 0, tonumber(render.offsetY) or 0,
            render.badgeLeft and string.format("%.1f,%.1f %.1fx%.1f", render.badgeLeft, render.badgeTop or 0, render.badgeWidth or 0, render.badgeHeight or 0) or "none"))
    else
        WorldCpDiagChat("LAST mouseover CP badge: NONE")
    end
    local last = diag.lastReticle
    if last and last.exists and last.isPlayer then
        WorldCpDiagChat(string.format(
            "Ungrouped nameplate limit: tag=%s name=%s cp=%d level=%d worldPosition=%s writableNameplate=false",
            tostring(last.tag or ""),
            tostring(last.displayName ~= "" and last.displayName or last.rawName or ""),
            tonumber(last.cpEffective) or 0, tonumber(last.level) or 0,
            diagBool(last.hasWorldPosition == true)))
    else
        WorldCpDiagChat("Ungrouped nameplate limit: no recent player snapshot")
    end

    if diag.lastTargetNameRender then
        local render = diag.lastTargetNameRender
        local renderAge = math.max(0, WorldCpDiagNowMs() - (tonumber(render.atMs) or 0))
        WorldCpDiagChat(string.format(
            "LAST target-name render %dms ago: tag=%s cp=%d level=%d visible=%s mode=%s text=%q",
            renderAge, tostring(render.tag or ""), tonumber(render.cp) or 0,
            tonumber(render.level) or 0, diagBool(render.visible == true),
            tostring(render.targetFrameMode or ""), tostring(render.text or "")))
    else
        WorldCpDiagChat("LAST target-name render: NONE")
    end

    WorldCpDiagChat("END")
end

function KS.GetWorldPlayerCpDiagnosticText()
    local previousCollector = worldCpDiagCollector
    local lines = {}
    worldCpDiagCollector = lines
    local ok, err = pcall(EmitWorldPlayerCpDiagnostic)
    worldCpDiagCollector = previousCollector
    if not ok then
        lines[#lines + 1] = "CP DIAG | ERROR while building report: " .. tostring(err)
    end
    return table.concat(lines, "\n")
end

function KS.PrintWorldPlayerCpDiagnostic()
    EmitWorldPlayerCpDiagnostic()
end

function KS.ShowWorldPlayerCpDiagnostic()
    if not WINDOW_MANAGER or not GuiRoot then
        KS.PrintWorldPlayerCpDiagnostic()
        return false
    end

    local window = KS.worldCpDiagnosticWindow
    if not window then
        window = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteWorldCpDiagnosticWindow")
        window:SetDimensions(1080, 680)
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        window:SetDrawTier(DT_HIGH)
        window:SetDrawLayer(DL_OVERLAY)
        window:SetDrawLevel(5200)
        window:SetMouseEnabled(true)
        window:SetMovable(true)
        window:SetClampedToScreen(true)
        window:SetHidden(true)

        local backdrop = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticBackdrop", window, CT_BACKDROP)
        backdrop:SetAnchorFill(window)
        backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
        backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.98)
        backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
        backdrop:SetEdgeColor(0.35, 0.35, 0.35, 1)

        local title = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticTitle", window, CT_LABEL)
        title:SetFont("ZoFontWinH2")
        title:SetText("Ultivite Player CP Diagnostics")
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 18)
        title:SetMouseEnabled(true)
        title:SetHandler("OnMouseDown", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and window.StartMoving then window:StartMoving() end
        end)
        title:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT and window.StopMovingOrResizing then window:StopMovingOrResizing() end
        end)

        local help = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticHelp", window, CT_LABEL)
        help:SetFont("ZoFontGame")
        help:SetText("The concise CP report is already selected. Press Ctrl+C, then paste it into ChatGPT. It reports group world-follow separately from targeted-player CP presentation.")
        help:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
        help:SetDimensions(1030, 44)

        local edit = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticEdit", window, CT_EDITBOX)
        edit:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 94)
        edit:SetDimensions(1032, 510)
        edit:SetFont("ZoFontGame")
        edit:SetMultiLine(true)
        edit:SetNewLineEnabled(true)
        edit:SetEditEnabled(true)
        edit:SetCopyEnabled(true)
        edit:SetPasteEnabled(false)
        edit:SetMaxInputChars(50000)
        edit:SetSelectAllOnFocus(true)
        edit:SetColor(1, 1, 1, 1)
        edit:SetHandler("OnEscape", function()
            edit:LoseFocus()
            window:SetHidden(true)
        end)

        local arm = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticArm", window, CT_BUTTON)
        arm:SetDimensions(200, 36)
        arm:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 24, -18)
        arm:SetFont("ZoFontGameBold")
        arm:SetText("Reset Capture")
        arm:SetHandler("OnClicked", function()
            edit:LoseFocus()
            KS.ClearWorldPlayerCpDiagnostic()
            window:SetHidden(true)
        end)

        local printButton = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticPrint", window, CT_BUTTON)
        printButton:SetDimensions(180, 36)
        printButton:SetAnchor(BOTTOM, window, BOTTOM, 0, -18)
        printButton:SetFont("ZoFontGameBold")
        printButton:SetText("Print to Chat")
        printButton:SetHandler("OnClicked", function() KS.PrintWorldPlayerCpDiagnostic() end)

        local close = WINDOW_MANAGER:CreateControl("UltiviteWorldCpDiagnosticClose", window, CT_BUTTON)
        close:SetDimensions(180, 36)
        close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -24, -18)
        close:SetFont("ZoFontGameBold")
        close:SetText("Close")
        close:SetHandler("OnClicked", function()
            edit:LoseFocus()
            window:SetHidden(true)
        end)

        window.edit = edit
        KS.worldCpDiagnosticWindow = window
    end

    window.edit:SetText(KS.GetWorldPlayerCpDiagnosticText())
    window:SetHidden(false)
    if zo_callLater then
        zo_callLater(function()
            if window and window.edit and not window:IsHidden() then
                window.edit:TakeFocus()
                window.edit:SelectAll()
            end
        end, 20)
    else
        window.edit:TakeFocus()
        window.edit:SelectAll()
    end
    return true
end

function KS.ApplyRootVisibility()
    if not KS.root then return end
    -- Never hide the entire frame merely because 3D projection failed. 1.6.4
    -- coupled visibility to worldFollowAvailable, so any projection failure made
    -- the addon look completely dead. Visibility and positioning are separate now.
    KS.root:SetHidden(KS.lastRootVisible ~= true)
end

function KS.SetWorldFollowAvailable(available)
    available = available and true or false
    if KS.worldFollowAvailable == available then return end
    KS.worldFollowAvailable = available
    KS.fallbackActive = not available
    KS.ApplyRootVisibility()
end

function KS.ApplyWorldFallbackAnchor()
    if not KS.root then return end
    -- Diagnostic-safe fallback. Keep the target frame visible while the projection
    -- reason is recorded instead of parking it at -10000,-10000.
    KS.root:ClearAnchors()
    KS.root:SetClampedToScreen(true)
    KS.root:SetAnchor(BOTTOM, GuiRoot, CENTER, 0, -95)
end

function KS.CreateWorldTargetProbe()
    -- Compatibility no-op. Ultivite no longer creates a probe for non-grouped
    -- target projection; the target frame uses its fixed 2D fallback.
    KS.worldProbe = nil
end

function KS.GetLiveTargetHeadScreenPosition()
    -- Retained as a compatibility API for old callers, but deliberately does no
    -- target-position work. The target frame uses its safe 2D fallback instead.
    KS.SetWorldFailure("disabled-esoui-compliance")
    return nil, nil, "disabled-esoui-compliance"
end

function KS.UpdateWorldTargetAnchor()
    if not KS.root or not KS.sv then return false end
    if not KS.IsWorldFollowMode() then
        KS.SetWorldFollowAvailable(false)
        return false
    end
    if not KS.IsHUDAllowed() or KS.currentTarget == "" then
        KS.SetWorldFailure(KS.currentTarget == "" and "no-current-target" or "hud-not-allowed")
        KS.SetWorldFollowAvailable(false)
        return false
    end

    local screenX, screenY, reason = KS.GetLiveTargetHeadScreenPosition()
    if not screenX or not screenY then
        KS.SetWorldFollowAvailable(false)
        -- If we have never had a valid world anchor this session, keep the frame
        -- visible in the diagnostic fallback position. If we did have one, leave it
        -- at the last known position so a one-frame reticle gap does not teleport it.
        if KS.lastWorldAnchorX == nil or KS.lastWorldAnchorY == nil then
            KS.ApplyWorldFallbackAnchor()
        end
        return false
    end

    local gap = tonumber(KS.sv.targetScreenGap) or defaults.targetScreenGap
    local anchorX = screenX
    local anchorY = screenY - gap

    if KS.lastWorldAnchorX == nil or KS.lastWorldAnchorY == nil
        or math.abs(anchorX - KS.lastWorldAnchorX) >= 0.25
        or math.abs(anchorY - KS.lastWorldAnchorY) >= 0.25 then
        KS.lastWorldAnchorX = anchorX
        KS.lastWorldAnchorY = anchorY
        KS.root:ClearAnchors()
        KS.root:SetClampedToScreen(false)
        KS.root:SetAnchor(BOTTOM, GuiRoot, TOPLEFT, anchorX, anchorY)
    end

    KS.SetWorldFollowAvailable(true)
    return true
end

function KS.ApplyPosition()
    if not KS.root then return end

    KS.root:ClearAnchors()
    KS.lastWorldAnchorX = nil
    KS.lastWorldAnchorY = nil

    if KS.IsWorldFollowMode() then
        KS.root:SetClampedToScreen(false)
        if not KS.UpdateWorldTargetAnchor() then
            KS.ApplyWorldFallbackAnchor()
        end
    else
        KS.root:SetClampedToScreen(true)
        KS.SetWorldFollowAvailable(false)
        KS.root:SetAnchor(CENTER, GuiRoot, CENTER, tonumber(KS.sv.x) or 0, tonumber(KS.sv.y) or -82)
    end
end

function KS.SetPosition(x, y)
    if x ~= nil then KS.sv.x = math.floor(tonumber(x) or 0) end
    if y ~= nil then KS.sv.y = math.floor(tonumber(y) or 0) end
    KS.ApplyPosition()
end

function KS.IsSelectedTargetDeadUnderReticle()
    if KS.selectedTarget == "" then return false end
    if DoesUnitExist and not DoesUnitExist(KS.unitTag) then return false end
    if not IsUnitDead or not IsUnitDead(KS.unitTag) then return false end
    local deadName = cleanName(GetUnitName(KS.unitTag))
    return deadName ~= "" and deadName == KS.selectedTarget
end

function KS.IsUsingAccountWideSettings()
    if Ultivite and U.IsUsingAccountWideSettings then
        return U.IsUsingAccountWideSettings()
    end
    return not KS.scopeSV or KS.scopeSV.useAccountWide ~= false
end

function KS.SetAccountWideSettings(enabled)
    if Ultivite and U.SetAccountWideSettings then
        U.SetAccountWideSettings(enabled)
        return
    end

    enabled = enabled and true or false
    if not KS.scopeSV then return end
    if KS.IsUsingAccountWideSettings() == enabled then return end

    local destination = enabled and KS.accountSV or KS.characterSV
    copySavedSettings(KS.sv, destination)
    KS.scopeSV.useAccountWide = enabled
    zo_callLater(function()
        if ReloadUI then ReloadUI() end
    end, 50)
end

function KS.IsChatTextEntryActive()
    local editBox = ZO_ChatWindowTextEntryEditBox
    if not editBox or not editBox.HasFocus then return false end
    local ok, focused = pcall(function() return editBox:HasFocus() end)
    return ok and focused == true
end

function KS.ApplyAlwaysCollapseChat()
    -- Retired in Ultivite 1.0.146. Structural chat minimization can interfere
    -- with the stock resize path. Frames owns non-destructive chat visibility.
    return false
end

function KS.GetPvpContextType()
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then return "BG" end
    if IsInImperialCity and IsInImperialCity() then return "IC" end
    if IsInCyrodiil and IsInCyrodiil() then return "CYRO" end
    if IsPlayerInAvAWorld and IsPlayerInAvAWorld() then return "AVA" end
    if IsInCampaign and IsInCampaign() then return "AVA" end
    return "NONE"
end

function KS.IsDuelActive()
    if KS.duelActive == true then return true end
    if IsUnitInDuel then
        local ok, value = pcall(function() return IsUnitInDuel("player") end)
        if ok and value == true then return true end
    end
    return false
end

function KS.IsPvpTrackingContext()
    return KS.GetPvpContextType() ~= "NONE" and not KS.IsDuelActive()
end

function KS.GetPvpSessionKey(contextType)
    contextType = tostring(contextType or KS.GetPvpContextType())
    local charId = GetCurrentCharacterId and tostring(GetCurrentCharacterId() or 0) or "0"
    local zoneId = 0
    if GetUnitZoneIndex and GetZoneId then
        local zoneIndex = tonumber(GetUnitZoneIndex("player")) or 0
        if zoneIndex > 0 then zoneId = tonumber(GetZoneId(zoneIndex)) or 0 end
    end
    local campaignId = GetCurrentCampaignId and tonumber(GetCurrentCampaignId()) or 0

    if contextType == "BG" then
        local battlegroundId = GetCurrentBattlegroundId and tonumber(GetCurrentBattlegroundId()) or 0
        local roundIndex = GetCurrentBattlegroundRoundIndex and tonumber(GetCurrentBattlegroundRoundIndex()) or 0
        return string.format("%s:%s:%d:%d:%d:%d", contextType, charId, zoneId, campaignId, battlegroundId, roundIndex)
    end

    return string.format("%s:%s:%d:%d", contextType, charId, zoneId, campaignId)
end

function KS.ResetPvpStats(reason, silent)
    if not KS.sv then return end
    KS.sv.pvpKills = 0
    KS.sv.pvpDeaths = 0
    KS.lastDeathCountAtMs = 0
    KS.lastKillCountAtMs = 0
    if not silent then
        chat("PvP K/D reset" .. (reason and reason ~= "" and (" (" .. tostring(reason) .. ")") or "") .. ".")
    end
    KS.UpdatePvpHud()
end

function KS.RefreshPvpSession(forceReset)
    if not KS.sv then return end
    local contextType = KS.GetPvpContextType()
    KS.lastPvpContextType = contextType

    if contextType == "NONE" then
        KS.sv.pvpSessionActive = false
        KS.UpdatePvpHud()
        return
    end

    local key = KS.GetPvpSessionKey(contextType)
    local needsReset = forceReset == true or KS.sv.pvpSessionActive ~= true or tostring(KS.sv.pvpSessionKey or "") ~= key
    if needsReset then
        KS.sv.pvpSessionKey = key
        KS.sv.pvpSessionActive = true
        KS.ResetPvpStats(nil, true)
    else
        KS.sv.pvpSessionActive = true
    end
    KS.UpdatePvpHud()
end

function KS.IsLocalPlayerCombatUnit(name, unitId)
    local localUnitId = GetUnitId and tonumber(GetUnitId("player")) or 0
    unitId = tonumber(unitId) or 0
    if localUnitId > 0 and unitId > 0 then return localUnitId == unitId end

    local candidate = normalizeName(cleanName(name))
    if candidate == "" then return false end
    local characterName = GetUnitName and normalizeName(cleanName(GetUnitName("player"))) or ""
    local displayName = GetUnitDisplayName and normalizeName(GetUnitDisplayName("player") or "") or ""
    return candidate == characterName or candidate == displayName
end

function KS.IsPlayerCombatUnit(unitType, name)
    if tonumber(unitType) == tonumber(COMBAT_UNIT_TYPE_PLAYER) then return true end
    local candidate = tostring(name or "")
    return candidate:sub(1, 1) == "@"
end

function KS.ResolveKilledPlayerDisplayName(targetName)
    local raw = tostring(targetName or "")
    if raw:sub(1, 1) == "@" then return raw end

    local characterName = cleanName(raw)
    if characterName ~= "" then
        local info = KS.targetInfoCache and KS.targetInfoCache[characterName] or nil
        if info and tostring(info.displayName or "") ~= "" then return tostring(info.displayName) end

        if DoesUnitExist and DoesUnitExist(KS.unitTag) and IsUnitPlayer and IsUnitPlayer(KS.unitTag) then
            local liveName = GetUnitName and cleanName(GetUnitName(KS.unitTag)) or ""
            if liveName == characterName and GetUnitDisplayName then
                local displayName = tostring(GetUnitDisplayName(KS.unitTag) or "")
                if displayName ~= "" then return displayName end
            end
        end
    end

    return characterName ~= "" and characterName or "player"
end

function KS.ApplyKillMessageAnchor()
    if not KS.killMessageRoot or not GuiRoot then return end
    -- Kill announcements are a screen HUD element, not part of the target frame.
    -- Preview Everything can now move this independently, so keep the saved
    -- centre-relative position instead of hard-coding the old 0,-145 anchor.
    local x = clamp(math.floor(tonumber(KS.sv and KS.sv.killMessageX) or defaults.killMessageX), -1100, 1100)
    local y = clamp(math.floor(tonumber(KS.sv and KS.sv.killMessageY) or defaults.killMessageY), -600, 600)
    if KS.sv then KS.sv.killMessageX, KS.sv.killMessageY = x, y end
    KS.killMessageRoot:ClearAnchors()
    KS.killMessageRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

local function rememberKillMessageVictim(displayName, victimKey, nowMs)
    KS.killMessageRecentVictims = KS.killMessageRecentVictims or {}

    local key = normalizeName(cleanName(victimKey))
    if key == "" then key = normalizeName(cleanName(displayName)) end
    if key == "" then key = normalizeName(displayName) end
    if key == "" then return false end

    local previousAtMs = tonumber(KS.killMessageRecentVictims[key]) or 0
    KS.killMessageRecentVictims[key] = nowMs

    for recentKey, atMs in pairs(KS.killMessageRecentVictims) do
        atMs = tonumber(atMs) or 0
        if atMs <= 0 or nowMs < atMs or (nowMs - atMs) > 1500 then
            KS.killMessageRecentVictims[recentKey] = nil
        end
    end

    return previousAtMs > 0 and nowMs >= previousAtMs and (nowMs - previousAtMs) < 1250
end

function KS.ShowKillMessage(displayName, sourceKind, victimKey)
    if not KS.sv or KS.sv.showPvpKillMessages == false then return end
    if not KS.IsPvpTrackingContext() then return end
    if not KS.killMessageRoot or not KS.killMessageLabel then return end

    displayName = tostring(displayName or "")
    if displayName == "" then displayName = "player" end
    sourceKind = tostring(sourceKind or "direct")
    victimKey = tostring(victimKey or displayName)

    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if nowMs <= 0 then nowMs = math.floor((GetFrameTimeSeconds and GetFrameTimeSeconds() or 0) * 1000) end

    -- PvP killing blows can be reported once by EVENT_COMBAT_EVENT and again by
    -- the Battleground/PvP kill feed. Both event families expose the victim's
    -- character name, so use that stable identity to count the kill only once.
    local duplicateVictim = rememberKillMessageVictim(displayName, victimKey, nowMs)
    local logicalNewKill = not duplicateVictim

    local incomingIsAccountName = displayName:sub(1, 1) == "@"
    local previousName = tostring(KS.lastKillMessageName or "")
    local previousWasAccountName = previousName:sub(1, 1) == "@"
    local previousAtMs = tonumber(KS.lastKillMessageAtMs) or 0

    -- The authoritative PvP event usually has the victim's @display name while
    -- the combat-event fallback may only have the character name. Upgrade the
    -- text when that richer name arrives without incrementing the burst count.
    if duplicateVictim and sourceKind == "authoritative" and incomingIsAccountName then
        KS.lastKillMessageName = displayName
    elseif logicalNewKill then
        KS.lastKillMessageName = displayName
    elseif not incomingIsAccountName and previousWasAccountName and previousAtMs > 0
        and nowMs >= previousAtMs and (nowMs - previousAtMs) < 350 then
        displayName = previousName
    end

    if logicalNewKill then
        local burstWindowMs = tonumber(KS.killMessageBurstWindowMs) or 900
        local lastBurstAtMs = tonumber(KS.killMessageBurstLastAtMs) or 0
        if lastBurstAtMs <= 0 or nowMs < lastBurstAtMs or (nowMs - lastBurstAtMs) > burstWindowMs then
            KS.killMessageBurstCount = 1
        else
            KS.killMessageBurstCount = math.max(1, tonumber(KS.killMessageBurstCount) or 1) + 1
        end
        KS.killMessageBurstLastAtMs = nowMs
    end

    local burstCount = math.max(1, tonumber(KS.killMessageBurstCount) or 1)
    local shownName = tostring(KS.lastKillMessageName or displayName)
    if burstCount > 1 then
        local streakTitle = nil
        if burstCount >= 10 then
            streakTitle = "ULTRA KILL"
        elseif burstCount >= 5 then
            streakTitle = "M M M MONSTER KILL"
        elseif burstCount == 4 then
            streakTitle = "QUAD KILL"
        elseif burstCount == 3 then
            streakTitle = "TRIPLE KILL"
        elseif burstCount == 2 then
            streakTitle = "DOUBLE KILL"
        end

        if streakTitle then
            KS.killMessageText = string.format("%s  |  KILLED %d PLAYERS", streakTitle, burstCount)
        else
            KS.killMessageText = string.format("KILLED %d PLAYERS", burstCount)
        end
    else
        KS.killMessageText = "KILLED " .. shownName
    end

    KS.lastKillMessageAtMs = nowMs
    KS.killMessageLabel:SetText(KS.killMessageText)
    KS.killMessageRoot:SetAlpha(1)
    KS.killMessageRoot:SetHidden(false)
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    KS.killMessageExpiresAt = now + 3.0
end

function KS.UpdateKillMessage()
    if not KS.killMessageRoot then return end
    local quickMenu = U and U.QuickMenu or nil
    local previewKill = quickMenu and quickMenu.IsPreviewing and quickMenu.IsPreviewing("killMessage") or false
    if previewKill then
        if KS.killMessageLabel then KS.killMessageLabel:SetText("KILLED @PREVIEW") end
        KS.killMessageRoot:SetAlpha(1)
        KS.killMessageRoot:SetHidden(false)
        return
    end
    local expiresAt = tonumber(KS.killMessageExpiresAt) or 0
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local remain = expiresAt - now
    if expiresAt <= 0 or remain <= 0 or not KS.IsPvpTrackingContext() then
        KS.killMessageExpiresAt = 0
        KS.killMessageRoot:SetHidden(true)
        KS.killMessageRoot:SetAlpha(1)
        return
    end

    local fadeSeconds = tonumber(KS.killMessageFadeSeconds) or 0.8
    local alpha = 1
    if remain < fadeSeconds and fadeSeconds > 0 then alpha = math.max(0, math.min(1, remain / fadeSeconds)) end
    KS.killMessageRoot:SetAlpha(alpha)
    KS.killMessageRoot:SetHidden(false)
end

function KS.ApplyPvpHudPosition()
    if not KS.pvpHudRoot or not KS.sv then return end
    local x = tonumber(KS.sv.pvpHudX)
    local y = tonumber(KS.sv.pvpHudY)
    if x == nil then x = defaults.pvpHudX end
    if y == nil then y = defaults.pvpHudY end
    KS.pvpHudRoot:ClearAnchors()
    KS.pvpHudRoot:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function KS.ApplyPvpHudAppearance()
    if not KS.sv or not KS.pvpHudRoot or not KS.pvpHudLabel then return end
    local fontSize = clamp(math.floor(tonumber(KS.sv.pvpHudFontSize) or defaults.pvpHudFontSize), 14, 36)
    KS.sv.pvpHudFontSize = fontSize

    local token = KS.GetConfiguredFontToken()
    local effect = KS.GetConfiguredFontEffect()
    KS.pvpHudLabel:SetFont(string.format("%s|%d|%s", token, fontSize, effect))

    -- Grow the invisible grab surface with the text so the K/D counter remains
    -- easy to grab at every size. Resizing is intentionally controlled only by
    -- the Quick Menu RESIZE toggle; ordinary dragging never changes the size.
    local scale = fontSize / defaults.pvpHudFontSize
    KS.pvpHudRoot:SetDimensions(math.max(300, zo_round(420 * scale)), math.max(30, zo_round(34 * scale)))
    KS.ApplyPvpHudPosition()
end

function KS.SavePvpHudPosition()
    if not KS.pvpHudRoot or not KS.sv then return end

    local left = KS.pvpHudRoot:GetLeft()
    local top = KS.pvpHudRoot:GetTop()
    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()
    if left == nil or top == nil or rootLeft == nil or rootTop == nil then return end

    KS.sv.pvpHudX = math.floor((left - rootLeft) + 0.5)
    KS.sv.pvpHudY = math.floor((top - rootTop) + 0.5)
    KS.ApplyPvpHudPosition()
end

function KS.SetPvpHudEditMode(enabled)
    -- The K/D counter has a large transparent grab surface. Keep that surface
    -- completely non-interactive during normal play so it can never sit over
    -- stock UI controls such as the chat resize edge. Preview mode explicitly
    -- enables it when the user wants to move the counter.
    KS.pvpHudEditMode = enabled and true or false
    local interactive = KS.pvpHudEditMode == true

    if KS.pvpHudRoot then
        KS.pvpHudRoot:SetMouseEnabled(interactive)
        KS.pvpHudRoot:SetMovable(interactive)
    end
    if KS.pvpHudDragger then
        KS.pvpHudDragger:SetMouseEnabled(interactive)
    end

    KS.lastPvpHudText = nil
    KS.lastPvpHudVisible = nil
    KS.UpdatePvpHud()
end

function KS.ResetPvpHudPosition()
    if not KS.sv then return end
    KS.sv.pvpHudX = defaults.pvpHudX
    KS.sv.pvpHudY = defaults.pvpHudY
    KS.ApplyPvpHudPosition()
    KS.lastPvpHudVisible = nil
    KS.UpdatePvpHud()
    chat("K/D counter position reset.")
end

function KS.UpdatePvpHud(syncBattleground)
    if not KS.pvpHudRoot or not KS.pvpHudLabel or not KS.sv then return end
    if syncBattleground ~= false and KS.GetPvpContextType() == "BG" then
        KS.SyncBattlegroundScoreboard(false)
    end

    local normalVisible = KS.sv.showPvpKillCounter ~= false
        and KS.IsPvpTrackingContext()
        and KS.IsHUDAllowed()

    local visible = KS.pvpHudEditMode == true or normalVisible

    if visible then
        local text = string.format("Kills: %d  Deaths: %d", tonumber(KS.sv.pvpKills) or 0, tonumber(KS.sv.pvpDeaths) or 0)
        if KS.pvpHudEditMode then
            text = text .. "   |c7FD4FFDRAG TO MOVE|r"
        end
        if KS.lastPvpHudText ~= text then
            KS.lastPvpHudText = text
            KS.pvpHudLabel:SetText(text)
        end
    end

    if KS.lastPvpHudVisible ~= visible then
        KS.lastPvpHudVisible = visible
        KS.pvpHudRoot:SetHidden(not visible)
    end
end

function KS.GetCurrentBattlegroundScoreboardRoundIndex()
    if not IsActiveWorldBattleground or not IsActiveWorldBattleground() then return nil end
    local battlegroundId = GetCurrentBattlegroundId and tonumber(GetCurrentBattlegroundId()) or 0
    if battlegroundId <= 0 then return nil end
    if DoesBattlegroundHaveRounds and DoesBattlegroundHaveRounds(battlegroundId) then
        if GetCurrentBattlegroundRoundIndex then
            local roundIndex = tonumber(GetCurrentBattlegroundRoundIndex())
            if roundIndex and roundIndex > 0 then return roundIndex end
        end
    end
    return nil
end

function KS.SyncBattlegroundScoreboard(forceZero)
    if not KS.sv or KS.GetPvpContextType() ~= "BG" then return false end

    local battlegroundId = GetCurrentBattlegroundId and tonumber(GetCurrentBattlegroundId()) or 0
    local roundIndex = KS.GetCurrentBattlegroundScoreboardRoundIndex()

    if battlegroundId > 0 then
        KS.lastBattlegroundId = battlegroundId
    end

    if roundIndex ~= nil and KS.lastBattlegroundRoundIndex ~= nil and roundIndex ~= KS.lastBattlegroundRoundIndex then
        forceZero = true
    end
    if roundIndex ~= nil then
        KS.lastBattlegroundRoundIndex = roundIndex
    end

    local state = GetCurrentBattlegroundState and tonumber(GetCurrentBattlegroundState()) or nil
    local isRunning = BATTLEGROUND_STATE_RUNNING and state == BATTLEGROUND_STATE_RUNNING

    if forceZero == true then
        KS.sv.pvpKills = 0
        KS.sv.pvpDeaths = 0
        KS.lastPvpHudText = nil
    end

    -- During STARTING/PREROUND keep the fresh round at 0. The scoreboard can still
    -- expose the previous round briefly, so do not read it until RUNNING.
    if not isRunning then
        return forceZero == true
    end

    if not GetScoreboardLocalPlayerEntryIndex or not GetScoreboardEntryScoreByType
        or not SCORE_TRACKER_TYPE_KILL or not SCORE_TRACKER_TYPE_DEATH then
        return false
    end

    local okEntry, entryIndex = pcall(function()
        return GetScoreboardLocalPlayerEntryIndex(roundIndex)
    end)
    entryIndex = okEntry and tonumber(entryIndex) or nil
    if not entryIndex or entryIndex <= 0 then
        KS.UpdatePvpHud(false)
        return false
    end

    local okKills, kills = pcall(function()
        return GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_KILL, roundIndex)
    end)
    local okDeaths, deaths = pcall(function()
        return GetScoreboardEntryScoreByType(entryIndex, SCORE_TRACKER_TYPE_DEATH, roundIndex)
    end)

    if okKills and tonumber(kills) ~= nil then KS.sv.pvpKills = tonumber(kills) end
    if okDeaths and tonumber(deaths) ~= nil then KS.sv.pvpDeaths = tonumber(deaths) end
    KS.lastPvpHudText = nil
    return okKills or okDeaths
end

function KS.IsLocalPvpIdentity(displayName, characterName)
    local localAccount = GetDisplayName and normalizeName(GetDisplayName() or "") or ""
    local localUnitDisplay = GetUnitDisplayName and normalizeName(GetUnitDisplayName("player") or "") or ""
    local localCharacter = GetUnitName and normalizeName(cleanName(GetUnitName("player") or "")) or ""
    local candidateDisplay = normalizeName(displayName or "")
    local candidateCharacter = normalizeName(cleanName(characterName or ""))

    if candidateDisplay ~= "" then
        if localAccount ~= "" and candidateDisplay == localAccount then return true end
        if localUnitDisplay ~= "" and candidateDisplay == localUnitDisplay then return true end
    end
    if localCharacter ~= "" and candidateCharacter ~= "" and candidateCharacter == localCharacter then return true end
    return false
end

function KS.OnBattlegroundKill(eventCode, killedCharacterName, killedDisplayName, killedTeam, killingCharacterName, killingDisplayName, killingTeam, battlegroundKillType, killingAbilityId)
    if not KS.sv or KS.GetPvpContextType() ~= "BG" or KS.IsDuelActive() then return end

    local localKiller = KS.IsLocalPvpIdentity(killingDisplayName, killingCharacterName)
    local localVictim = KS.IsLocalPvpIdentity(killedDisplayName, killedCharacterName)

    if localKiller and not localVictim then
        local victimName = tostring(killedDisplayName or "")
        if victimName == "" then victimName = tostring(killedCharacterName or "") end
        KS.ShowKillMessage(victimName, "authoritative", killedCharacterName)
    end

    zo_callLater(function()
        KS.SyncBattlegroundScoreboard(false)
        KS.UpdatePvpHud(false)
    end, 50)
end

function KS.OnPvpKillFeedDeath(eventCode, killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank, victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)
    if not KS.sv or not KS.IsPvpTrackingContext() then return end
    if KS.GetPvpContextType() == "BG" then return end

    local localKiller = KS.IsLocalPvpIdentity(killerDisplayName, killerCharacterName)
    local localVictim = KS.IsLocalPvpIdentity(victimDisplayName, victimCharacterName)

    if localKiller and not localVictim then
        KS.CountPvpKill((tostring(victimDisplayName or "") ~= "" and victimDisplayName) or victimCharacterName, victimCharacterName)
    elseif localVictim then
        KS.CountPvpDeath()
    end
end

function KS.CountPvpKill(targetName, targetCharacterName)
    if not KS.sv or not KS.IsPvpTrackingContext() then return end
    if KS.GetPvpContextType() == "BG" then
        KS.SyncBattlegroundScoreboard(false)
        KS.UpdatePvpHud(false)
        return
    end

    KS.sv.pvpKills = (tonumber(KS.sv.pvpKills) or 0) + 1
    KS.ShowKillMessage(KS.ResolveKilledPlayerDisplayName(targetName), "authoritative", targetCharacterName or targetName)
    KS.UpdatePvpHud(false)
end

function KS.CountPvpDeath()
    if not KS.sv or not KS.IsPvpTrackingContext() then return end
    if KS.GetPvpContextType() == "BG" then
        KS.SyncBattlegroundScoreboard(false)
        KS.UpdatePvpHud(false)
        return
    end

    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if nowMs > 0 and (nowMs - (tonumber(KS.lastDeathCountAtMs) or 0)) < 1250 then return end
    KS.lastDeathCountAtMs = nowMs
    KS.sv.pvpDeaths = (tonumber(KS.sv.pvpDeaths) or 0) + 1
    KS.UpdatePvpHud(false)
end

function KS.OnBattlegroundStateChanged(eventCode, previousState, currentState)
    if not IsActiveWorldBattleground or not IsActiveWorldBattleground() then
        KS.lastBattlegroundState = nil
        KS.lastBattlegroundRoundIndex = nil
        KS.lastBattlegroundId = nil
        return
    end

    local state = tonumber(currentState)
    local previous = tonumber(previousState)
    if state == nil and GetCurrentBattlegroundState then state = tonumber(GetCurrentBattlegroundState()) end
    if previous == nil then previous = tonumber(KS.lastBattlegroundState) end
    KS.lastBattlegroundState = state

    local roundIndex = KS.GetCurrentBattlegroundScoreboardRoundIndex()
    local roundChanged = roundIndex ~= nil and KS.lastBattlegroundRoundIndex ~= nil and roundIndex ~= KS.lastBattlegroundRoundIndex
    if roundIndex ~= nil then KS.lastBattlegroundRoundIndex = roundIndex end

    local enteringStart = (BATTLEGROUND_STATE_STARTING and state == BATTLEGROUND_STATE_STARTING)
        or (BATTLEGROUND_STATE_PREROUND and state == BATTLEGROUND_STATE_PREROUND)
    local enteringRunning = BATTLEGROUND_STATE_RUNNING and state == BATTLEGROUND_STATE_RUNNING and previous ~= BATTLEGROUND_STATE_RUNNING

    if enteringStart or enteringRunning or roundChanged then
        KS.RefreshPvpSession(true)
        KS.SyncBattlegroundScoreboard(true)
        zo_callLater(function()
            KS.SyncBattlegroundScoreboard(false)
            KS.UpdatePvpHud(false)
        end, 250)
    else
        KS.SyncBattlegroundScoreboard(false)
        KS.UpdatePvpHud(false)
    end
end

function KS.GetMenuOptions()
    local options = {
        {
            type = "description",
            text = "Native overhead target healthbar with Kjalnar stacks and combat timers. ESO owns the world-space target attachment; the Kjalnar number remains a compact movable HUD badge.",
            width = "full",
        },
        {
            type = "header",
            name = "Settings profile",
        },
        {
            type = "checkbox",
            name = "Use account-wide settings",
            tooltip = "When enabled, this addon uses one shared layout and configuration for every character on this account. Disable it to give the current character its own settings. Switching profiles copies your current settings first, so the frame does not reset.",
            getFunc = function() return KS.IsUsingAccountWideSettings() end,
            setFunc = function(value) KS.SetAccountWideSettings(value) end,
            default = scopeDefaults.useAccountWide,
            width = "full",
            warning = "Changing this option reloads the UI once so the selected settings profile is applied cleanly.",
        },
        { type = "divider" },
        {
            type = "header",
            name = "Target Frame — Position & Size",
        },
        {
            type = "checkbox",
            name = "Unlock target frame for editing",
            tooltip = "Turns on edit mode and forces the frame visible. Close Settings, drag the frame anywhere, and use the mouse wheel over it to resize. A small Save/Undo toolbar appears at the top of the screen.",
            getFunc = function() return KS.sv.locked ~= true end,
            setFunc = function(value) KS.SetLocked(not (value and true or false), true) end,
            default = not defaults.locked,
            width = "full",
            warning = "While unlocked the frame captures mouse input over its own area. Use SAVE & LOCK when you finish positioning it.",
        },
        {
            type = "description",
            text = "Editing: drag anywhere on the frame to move it. Mouse wheel resizes. Shift + mouse wheel makes fine 1% size adjustments. Grid snapping happens when you release the frame; hold Shift while releasing to bypass the grid for that move.",
            width = "full",
        },
        {
            type = "button",
            name = "Center horizontally",
            tooltip = "Keeps the current vertical position and places the frame exactly on the horizontal center line.",
            func = function() KS.CenterHorizontally(false) end,
            width = "half",
        },
        {
            type = "button",
            name = "Center on screen",
            tooltip = "Places the frame at the exact center of the screen.",
            func = function() KS.CenterOnScreen(false) end,
            width = "half",
        },
        {
            type = "slider",
            name = "Target frame size",
            tooltip = "Resize the compact target frame, including the target name, health bar, Kjalnar number and attached combat timers.",
            min = 35,
            max = 150,
            step = 1,
            getFunc = function() return math.floor(KS.GetFrameScale() * 100 + 0.5) end,
            setFunc = function(value) KS.SetFrameScale((tonumber(value) or 70) / 100, true) end,
            default = math.floor(defaults.frameScale * 100),
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use native overhead target bar",
            tooltip = "Uses ESO's engine-rendered targeted enemy nameplate and healthbar. This is the reliable way to keep the health meter physically attached above the target, including when Lua no longer has a reticleover world position.",
            getFunc = function() return KS.sv.nativeOverheadTargetBar == true end,
            setFunc = function(value) KS.SetNativeOverheadTargetBar(value) end,
            default = defaults.nativeOverheadTargetBar,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show health bars for ALL enemies",
            tooltip = "When native overhead mode is enabled, show overhead Health bars for every enemy NPC in PvE and every enemy player in PvP while you are in combat. Outside combat, enemy Health bars are always hidden. Names are controlled separately.",
            getFunc = function() return KS.sv.nativeAllEnemyHealthbars == true end,
            setFunc = function(value) KS.sv.nativeAllEnemyHealthbars = value and true or false; KS.ApplyNativeOverheadTargetBar() end,
            default = defaults.nativeAllEnemyHealthbars,
            width = "full",
        },
        {
            type = "description",
            text = "Native overhead mode: ESO itself follows the enemy with the healthbar. Kjalnar remains a large movable 0-5 HUD badge because ESO does not expose the engine nameplate control to addons.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide NPC names in native mode",
            tooltip = "Hides enemy, friendly and neutral NPC names while keeping the targeted overhead healthbar behaviour. Player names are left alone.",
            getFunc = function() return KS.sv.nativeHideNpcNames == true end,
            setFunc = function(value) KS.sv.nativeHideNpcNames = value and true or false; KS.ApplyNativeOverheadTargetBar() end,
            default = defaults.nativeHideNpcNames,
            width = "full",
        },
        {
            type = "submenu",
            name = "Edit behaviour",
            controls = {
                {
                    type = "checkbox",
                    name = "Snap movement to grid",
                    tooltip = "Straightens placement when you release the frame. Hold Shift while releasing to bypass snapping for one move.",
                    getFunc = function() return KS.sv.snapToGrid ~= false end,
                    setFunc = function(value) KS.sv.snapToGrid = value and true or false; KS.UpdateDragState() end,
                    default = defaults.snapToGrid,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Grid size",
                    min = 2,
                    max = 50,
                    step = 1,
                    getFunc = function() return KS.GetGridSize() end,
                    setFunc = function(value) KS.sv.gridSize = clamp(math.floor(tonumber(value) or 10), 2, 50); KS.UpdateDragState() end,
                    default = defaults.gridSize,
                    width = "full",
                },
            },
        },
        { type = "divider" },
        {
            type = "submenu",
            name = "Target behaviour",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable target frame",
                    tooltip = "Show the persistent custom target frame during normal gameplay.",
                    getFunc = function() return KS.sv.targetFrame end,
                    setFunc = function(value) KS.sv.targetFrame = value and true or false; KS.RefreshDisplay() end,
                    default = defaults.targetFrame,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Retain Tab target when looking away",
                    tooltip = "Keeps the frame visible while ESO still has a valid preferred enemy target.",
                    getFunc = function() return KS.sv.stickyTarget end,
                    setFunc = function(value)
                        KS.sv.stickyTarget = value and true or false
                        if not KS.sv.stickyTarget and KS.GetTargetName() == "" then KS.ClearTarget() end
                        KS.RefreshDisplay()
                    end,
                    default = defaults.stickyTarget,
                    width = "full",
                },
                {
                    type = "dropdown",
                    name = "Player name shown",
                    tooltip = "Choose character name or @account name for player targets. NPC names are unchanged.",
                    choices = { "Character name", "@Account name" },
                    getFunc = function() return KS.sv.playerNameMode or defaults.playerNameMode end,
                    setFunc = function(value)
                        KS.sv.playerNameMode = value == "@Account name" and "@Account name" or "Character name"
                        if KS.currentTarget ~= "" then
                            KS.targetInfoCache[KS.currentTarget] = nil
                            KS.CaptureTargetInfo(KS.currentTarget)
                        end
                        KS.RefreshDisplay(true)
                    end,
                    default = defaults.playerNameMode,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Decoy guard",
                    tooltip = "Prevents known Blastbones and Engine Guardian decoys from replacing a retained player target.",
                    getFunc = function() return KS.sv.decoyGuard end,
                    setFunc = function(value) KS.sv.decoyGuard = value and true or false; KS.RefreshDisplay() end,
                    default = defaults.decoyGuard,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Clear retained target",
                    func = function() KS.ClearTarget() end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Other target frames",
            controls = {
                {
                    type = "checkbox",
                    name = "Hide stock ESO target frame",
                    tooltip = "Hides ZOS's normal reticle target frame.",
                    getFunc = function() return KS.sv.hideDefaultTargetFrame == true end,
                    setFunc = function(value) KS.sv.hideDefaultTargetFrame = value and true or false; KS.ApplyDefaultTargetFrameVisibility() end,
                    default = defaults.hideDefaultTargetFrame,
                    width = "full",
                },
                {
                    type = "description",
                    text = "Use UI Visibility -> Target Frames & ESO Overhead Bars -> Target Frame Mode to switch between Ultivite and ESO's stock target frame. Player CP / level remains automatic on Ultivite player target frames.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Hide LUI Extended custom target frame",
                    tooltip = "Hides LUI Extended's separate custom target frame.",
                    getFunc = function() return KS.sv.hideLUIETargetFrame == true end,
                    setFunc = function(value) KS.sv.hideLUIETargetFrame = value and true or false; KS.ApplyLUIETargetFrameVisibility() end,
                    default = defaults.hideLUIETargetFrame,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Auto hide any other target frame",
                    tooltip = "Detect and suppress another visible target frame without touching protected reticle interaction controls.",
                    getFunc = function() return KS.sv.autoHideOtherTargetFrames == true end,
                    setFunc = function(value)
                        KS.sv.autoHideOtherTargetFrames = value and true or false
                        KS.dynamicHiddenTargetFrame = nil
                        KS.ApplyOtherTargetFrameVisibility(false)
                    end,
                    default = defaults.autoHideOtherTargetFrames,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Identify and hide duplicate target frame",
                    func = function()
                        KS.dynamicHiddenTargetFrame = nil
                        KS.dynamicHiddenTargetFrameState = nil
                        KS.ApplyOtherTargetFrameVisibility(true)
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Full target frame diagnostic",
                    tooltip = "Prints ESO, Azurah and LUIE state, then scans the visible UI for the actual duplicate target frame and its parent controls.",
                    func = function()
                        KS.ApplyDefaultTargetFrameVisibility()
                        KS.PrintTargetFrameDiagnostic()
                        KS.dynamicHiddenTargetFrame = nil
                        KS.dynamicHiddenTargetFrameState = nil
                        KS.ApplyOtherTargetFrameVisibility(true)
                    end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Warnings & HUD Convenience",
            controls = {
                {
                    type = "checkbox",
                    name = "Show no Major Resolve warning",
                    tooltip = "Shows NO MAJOR RESOLVE above the centre of the screen only while you are in combat and Major Resolve is not active. Werewolf form, Hurricane, Boundless Storm, Lightning Form and an equipped Oakensoul Ring are accepted as Major Resolve sources.",
                    getFunc = function() return KS.sv.showNoMajorResolveWarning ~= false end,
                    setFunc = function(value)
                        KS.sv.showNoMajorResolveWarning = value and true or false
                        KS.lastMajorResolveWarningVisible = nil
                        KS.UpdateMajorResolveWarning()
                    end,
                    default = defaults.showNoMajorResolveWarning,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show no food buff warning",
                    tooltip = "Shows NO FOOD BUFF near the centre of the screen only when ESO reports no active removable long-duration food or drink stat buff.",
                    getFunc = function() return KS.sv.showNoFoodWarning ~= false end,
                    setFunc = function(value)
                        KS.sv.showNoFoodWarning = value and true or false
                        KS.lastFoodWarningVisible = nil
                        KS.UpdateFoodWarning()
                    end,
                    default = defaults.showNoFoodWarning,
                    width = "full",
                },
                {
                    type = "submenu",
                    name = "Enemy Ultimate alerts",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Corrosive Armor alert",
                            tooltip = "Uses incoming periodic damage to identify Corrosive Armor. The live skill has a 10-second base duration; when the detected source is under your reticle Ultivite reads ESO's actual buff end time, so duration bonuses such as Eternal Mountain are reflected exactly.",
                            getFunc = function() return KS.sv.showEnemyCorrosiveAlert ~= false end,
                            setFunc = function(value)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.SetCorrosiveEnabled then alerts.SetCorrosiveEnabled(value) else KS.sv.showEnemyCorrosiveAlert = value and true or false end
                            end,
                            default = defaults.showEnemyCorrosiveAlert,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Onslaught alert",
                            tooltip = "Uses the established incoming-hit warning method for Onslaught. When an enemy Onslaught hits you, Ultivite warns immediately and tracks the attacker for 8 seconds. While you mouse over that attacker, the Onslaught icon is shown above them.",
                            getFunc = function() return KS.sv.showEnemyOnslaughtAlert ~= false end,
                            setFunc = function(value)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.SetOnslaughtEnabled then alerts.SetOnslaughtEnabled(value) else KS.sv.showEnemyOnslaughtAlert = value and true or false end
                            end,
                            default = defaults.showEnemyOnslaughtAlert,
                            width = "full",
                        },
                        {
                            type = "button",
                            name = "Test Corrosive Armor alert",
                            tooltip = "Runs the real Corrosive warning display using the current 10-second base Corrosive Armor duration without requiring another player.",
                            func = function()
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.TestAlert then alerts.TestAlert("corrosive") end
                            end,
                            disabled = function() return KS.sv.showEnemyCorrosiveAlert == false end,
                            width = "half",
                        },
                        {
                            type = "button",
                            name = "Test Onslaught alert",
                            tooltip = "Runs the real Onslaught warning display for eight seconds without requiring another player.",
                            func = function()
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.TestAlert then alerts.TestAlert("onslaught") end
                            end,
                            disabled = function() return KS.sv.showEnemyOnslaughtAlert == false end,
                            width = "half",
                        },
                        {
                            type = "button",
                            name = "Move Corrosive warning",
                            tooltip = "Opens Ultivite Move / Resize Mode with the Corrosive warning preview selected. Drag the visible caster banner or reticle icon directly, then use SAVE & LOCK or close Ultivite settings.",
                            func = function()
                                local quick = U.QuickMenu
                                if not quick then return end
                                if quick.OpenFromSettings then quick.OpenFromSettings() end
                                if quick.SetPreviewEnabled then quick.SetPreviewEnabled(true) end
                                if quick.SelectPreview then quick.SelectPreview("corrosiveAlert") end
                                if quick.ApplyActualPreviewVisibility then quick.ApplyActualPreviewVisibility() end
                            end,
                            disabled = function() return KS.sv.showEnemyCorrosiveAlert == false end,
                            width = "half",
                        },
                        {
                            type = "button",
                            name = "Move Onslaught warning",
                            tooltip = "Opens Ultivite Move / Resize Mode with the Onslaught warning preview selected. Drag the visible caster banner or reticle icon directly, then use SAVE & LOCK or close Ultivite settings.",
                            func = function()
                                local quick = U.QuickMenu
                                if not quick then return end
                                if quick.OpenFromSettings then quick.OpenFromSettings() end
                                if quick.SetPreviewEnabled then quick.SetPreviewEnabled(true) end
                                if quick.SelectPreview then quick.SelectPreview("onslaughtAlert") end
                                if quick.ApplyActualPreviewVisibility then quick.ApplyActualPreviewVisibility() end
                            end,
                            disabled = function() return KS.sv.showEnemyOnslaughtAlert == false end,
                            width = "half",
                        },
                        {
                            type = "slider",
                            name = "Enemy Ultimate icon size",
                            min = 32, max = 96, step = 2,
                            getFunc = function() return tonumber(KS.sv.enemyUltimateAlertIconSize) or defaults.enemyUltimateAlertIconSize end,
                            setFunc = function(value)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.SetIconSize then alerts.SetIconSize(value) else KS.sv.enemyUltimateAlertIconSize = value end
                            end,
                            default = defaults.enemyUltimateAlertIconSize,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Warning position X",
                            tooltip = "Moves the Corrosive and Onslaught reticle warning icons left or right.",
                            min = -800, max = 800, step = 5,
                            getFunc = function() return tonumber(KS.sv.enemyUltimateAlertTargetX) or defaults.enemyUltimateAlertTargetX end,
                            setFunc = function(value)
                                KS.sv.enemyUltimateAlertTargetX = clamp(math.floor(tonumber(value) or defaults.enemyUltimateAlertTargetX), -800, 800)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.ApplyLayout then alerts.ApplyLayout() end
                                if alerts and alerts.UpdateTargetMarker then alerts.UpdateTargetMarker() end
                            end,
                            default = defaults.enemyUltimateAlertTargetX,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Warning position Y",
                            tooltip = "Moves the Corrosive and Onslaught reticle warning icons up or down.",
                            min = -500, max = 500, step = 5,
                            getFunc = function() return tonumber(KS.sv.enemyUltimateAlertTargetY) or defaults.enemyUltimateAlertTargetY end,
                            setFunc = function(value)
                                KS.sv.enemyUltimateAlertTargetY = clamp(math.floor(tonumber(value) or defaults.enemyUltimateAlertTargetY), -500, 500)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.ApplyLayout then alerts.ApplyLayout() end
                                if alerts and alerts.UpdateTargetMarker then alerts.UpdateTargetMarker() end
                            end,
                            default = defaults.enemyUltimateAlertTargetY,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Caster alert banner X",
                            tooltip = "Moves the Corrosive and Onslaught source/caster banner left or right. You can also drag this banner directly in MOVE / RESIZE MODE while previewing either alert.",
                            min = -1600, max = 1600, step = 5,
                            getFunc = function() return tonumber(KS.sv.enemyUltimateAlertGlobalX) or defaults.enemyUltimateAlertGlobalX end,
                            setFunc = function(value)
                                KS.sv.enemyUltimateAlertGlobalX = clamp(math.floor(tonumber(value) or defaults.enemyUltimateAlertGlobalX), -1600, 1600)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.ApplyLayout then alerts.ApplyLayout() end
                                if alerts and alerts.UpdateGlobalAlert then alerts.UpdateGlobalAlert() end
                            end,
                            default = defaults.enemyUltimateAlertGlobalX,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Caster alert banner Y",
                            tooltip = "Moves the Corrosive and Onslaught source/caster banner vertically. The full screen height is available instead of only the old upper-screen range.",
                            min = 0, max = 1600, step = 5,
                            getFunc = function() return tonumber(KS.sv.enemyUltimateAlertGlobalY) or defaults.enemyUltimateAlertGlobalY end,
                            setFunc = function(value)
                                KS.sv.enemyUltimateAlertGlobalY = clamp(math.floor(tonumber(value) or defaults.enemyUltimateAlertGlobalY), 0, 1600)
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.ApplyLayout then alerts.ApplyLayout() end
                                if alerts and alerts.UpdateGlobalAlert then alerts.UpdateGlobalAlert() end
                            end,
                            default = defaults.enemyUltimateAlertGlobalY,
                            width = "full",
                        },
                        {
                            type = "button",
                            name = "Reset Enemy Ultimate warning positions",
                            func = function()
                                KS.sv.enemyUltimateAlertTargetX = defaults.enemyUltimateAlertTargetX
                                KS.sv.enemyUltimateAlertTargetY = defaults.enemyUltimateAlertTargetY
                                KS.sv.enemyUltimateAlertGlobalX = defaults.enemyUltimateAlertGlobalX
                                KS.sv.enemyUltimateAlertGlobalY = defaults.enemyUltimateAlertGlobalY
                                local alerts = U.EnemyUltimateAlerts
                                if alerts and alerts.ApplyLayout then alerts.ApplyLayout() end
                                if alerts and alerts.UpdateTargetMarker then alerts.UpdateTargetMarker() end
                                if alerts and alerts.UpdateGlobalAlert then alerts.UpdateGlobalAlert() end
                            end,
                            width = "full",
                        },
                    },
                },
                {
                    type = "submenu",
                    name = "Combat danger warnings",
                    controls = {
                        {
                            type = "description",
                            text = "Large text warnings for shield break, execute range and sudden burst damage. Shield break only fires when a shield is depleted by damage. Normal shield expiry does not fire the warning.",
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show SHIELD BROKEN warning",
                            tooltip = "Shows SHIELD BROKEN when ESO reports the player damage shield changing from a positive value to zero because it was consumed by damage. Ordinary shield removal or expiry is ignored.",
                            getFunc = function() return KS.sv.showShieldBrokenWarning ~= false end,
                            setFunc = function(value)
                                KS.sv.showShieldBrokenWarning = value and true or false
                                if not KS.sv.showShieldBrokenWarning then KS.shieldBreakExpiresAtMs = 0 end
                                KS.UpdateCombatDangerWarnings(true)
                            end,
                            default = defaults.showShieldBrokenWarning,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show EXECUTE DANGER warning",
                            tooltip = "Shows EXECUTE DANGER while you are alive, in combat and at or below the configured Health percentage. Default is 25 percent.",
                            getFunc = function() return KS.sv.showExecuteDangerWarning ~= false end,
                            setFunc = function(value)
                                KS.sv.showExecuteDangerWarning = value and true or false
                                KS.sv.executeDangerWarningMode = "always"
                                KS.UpdateCombatDangerWarnings(true)
                            end,
                            default = defaults.showExecuteDangerWarning,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show BURST DAMAGE warning",
                            tooltip = "Shows BURST DAMAGE when your Health percentage drops by the configured amount inside the configured rolling time window. Default is 35 percent within 700 ms.",
                            getFunc = function() return KS.sv.showBurstDamageWarning ~= false end,
                            setFunc = function(value)
                                KS.sv.showBurstDamageWarning = value and true or false
                                KS.sv.burstDamageWarningMode = "always"
                                if not KS.sv.showBurstDamageWarning then KS.burstDamageExpiresAtMs = 0 end
                                KS.ResetBurstDamageHistory()
                                KS.UpdateCombatDangerWarnings(true)
                            end,
                            default = defaults.showBurstDamageWarning,
                            width = "full",
                        },
                        {
                            type = "submenu",
                            name = "Thresholds and timing",
                            controls = {
                                {
                                    type = "slider",
                                    name = "Execute danger Health",
                                    tooltip = "EXECUTE DANGER remains visible while your current Health is at or below this percentage in combat.",
                                    min = 10,
                                    max = 50,
                                    step = 1,
                                    getFunc = function() return tonumber(KS.sv.executeDangerHealthPct) or defaults.executeDangerHealthPct end,
                                    setFunc = function(value)
                                        KS.sv.executeDangerHealthPct = clamp(math.floor(tonumber(value) or defaults.executeDangerHealthPct), 10, 50)
                                        KS.UpdateCombatDangerWarnings(true)
                                    end,
                                    default = defaults.executeDangerHealthPct,
                                    disabled = function() return KS.sv.showExecuteDangerWarning == false end,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Burst Health loss",
                                    tooltip = "Required loss in Health percentage points before BURST DAMAGE fires.",
                                    min = 20,
                                    max = 60,
                                    step = 1,
                                    getFunc = function() return tonumber(KS.sv.burstDamagePct) or defaults.burstDamagePct end,
                                    setFunc = function(value)
                                        KS.sv.burstDamagePct = clamp(math.floor(tonumber(value) or defaults.burstDamagePct), 20, 60)
                                        KS.ResetBurstDamageHistory()
                                    end,
                                    default = defaults.burstDamagePct,
                                    disabled = function() return KS.sv.showBurstDamageWarning == false end,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Burst window",
                                    tooltip = "Rolling time window used for burst detection. Default is 700 ms.",
                                    min = 300,
                                    max = 1500,
                                    step = 50,
                                    getFunc = function() return tonumber(KS.sv.burstDamageWindowMs) or defaults.burstDamageWindowMs end,
                                    setFunc = function(value)
                                        KS.sv.burstDamageWindowMs = clamp(math.floor(tonumber(value) or defaults.burstDamageWindowMs), 300, 1500)
                                        KS.ResetBurstDamageHistory()
                                    end,
                                    default = defaults.burstDamageWindowMs,
                                    disabled = function() return KS.sv.showBurstDamageWarning == false end,
                                    width = "full",
                                },
                            },
                        },
                        {
                            type = "submenu",
                            name = "Position and appearance",
                            controls = {
                                {
                                    type = "slider",
                                    name = "Font size",
                                    min = 22,
                                    max = 42,
                                    step = 1,
                                    getFunc = function() return tonumber(KS.sv.combatDangerFontSize) or defaults.combatDangerFontSize end,
                                    setFunc = function(value)
                                        KS.sv.combatDangerFontSize = clamp(math.floor(tonumber(value) or defaults.combatDangerFontSize), 22, 42)
                                        KS.ApplyCombatDangerLayout()
                                        KS.UpdateCombatDangerWarnings(true)
                                    end,
                                    default = defaults.combatDangerFontSize,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Horizontal position",
                                    min = -800,
                                    max = 800,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.combatDangerX) or defaults.combatDangerX end,
                                    setFunc = function(value)
                                        KS.sv.combatDangerX = clamp(math.floor(tonumber(value) or defaults.combatDangerX), -800, 800)
                                        KS.ApplyCombatDangerLayout()
                                    end,
                                    default = defaults.combatDangerX,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Vertical position",
                                    min = -500,
                                    max = 500,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.combatDangerY) or defaults.combatDangerY end,
                                    setFunc = function(value)
                                        KS.sv.combatDangerY = clamp(math.floor(tonumber(value) or defaults.combatDangerY), -500, 500)
                                        KS.ApplyCombatDangerLayout()
                                    end,
                                    default = defaults.combatDangerY,
                                    width = "full",
                                },
                                {
                                    type = "button",
                                    name = "Reset combat warning position",
                                    func = function()
                                        KS.sv.combatDangerX = defaults.combatDangerX
                                        KS.sv.combatDangerY = defaults.combatDangerY
                                        KS.ApplyCombatDangerLayout()
                                    end,
                                    width = "full",
                                },
                            },
                        },
                    },
                },
                {
                    type = "submenu",
                    name = "Resource danger",
                    controls = {
                        {
                            type = "description",
                            text = "Normally invisible. A compact percentage appears only when Health, Magicka or Stamina falls below its configured threshold. Health gently pulses while critically low.",
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show resource danger indicators",
                            getFunc = function() return KS.sv.showResourceDanger ~= false end,
                            setFunc = function(value)
                                KS.sv.showResourceDanger = value and true or false
                                KS.RefreshResourceDangerValues()
                                KS.UpdateResourceDangerHud(true)
                            end,
                            default = defaults.showResourceDanger,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Health warning below",
                            min = 10, max = 70, step = 1,
                            getFunc = function() return tonumber(KS.sv.resourceDangerHealthPct) or defaults.resourceDangerHealthPct end,
                            setFunc = function(value) KS.sv.resourceDangerHealthPct = clamp(math.floor(tonumber(value) or defaults.resourceDangerHealthPct), 10, 70); KS.UpdateResourceDangerHud(true) end,
                            default = defaults.resourceDangerHealthPct,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Magicka warning below",
                            min = 5, max = 60, step = 1,
                            getFunc = function() return tonumber(KS.sv.resourceDangerMagickaPct) or defaults.resourceDangerMagickaPct end,
                            setFunc = function(value) KS.sv.resourceDangerMagickaPct = clamp(math.floor(tonumber(value) or defaults.resourceDangerMagickaPct), 5, 60); KS.UpdateResourceDangerHud(true) end,
                            default = defaults.resourceDangerMagickaPct,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Stamina warning below",
                            min = 5, max = 60, step = 1,
                            getFunc = function() return tonumber(KS.sv.resourceDangerStaminaPct) or defaults.resourceDangerStaminaPct end,
                            setFunc = function(value) KS.sv.resourceDangerStaminaPct = clamp(math.floor(tonumber(value) or defaults.resourceDangerStaminaPct), 5, 60); KS.UpdateResourceDangerHud(true) end,
                            default = defaults.resourceDangerStaminaPct,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Indicator font size",
                            min = 16, max = 38, step = 1,
                            getFunc = function() return tonumber(KS.sv.resourceDangerFontSize) or defaults.resourceDangerFontSize end,
                            setFunc = function(value) KS.sv.resourceDangerFontSize = clamp(math.floor(tonumber(value) or defaults.resourceDangerFontSize), 16, 38); KS.ApplyResourceDangerLayout(); KS.UpdateResourceDangerHud(true) end,
                            default = defaults.resourceDangerFontSize,
                            width = "full",
                        },
                        {
                            type = "submenu",
                            name = "Position (advanced)",
                            controls = {
                                {
                                    type = "slider", name = "Horizontal position", min = -800, max = 800, step = 5,
                                    getFunc = function() return tonumber(KS.sv.resourceDangerX) or defaults.resourceDangerX end,
                                    setFunc = function(value) KS.sv.resourceDangerX = clamp(math.floor(tonumber(value) or defaults.resourceDangerX), -800, 800); KS.ApplyResourceDangerLayout() end,
                                    default = defaults.resourceDangerX, width = "full",
                                },
                                {
                                    type = "slider", name = "Vertical position", min = -500, max = 500, step = 5,
                                    getFunc = function() return tonumber(KS.sv.resourceDangerY) or defaults.resourceDangerY end,
                                    setFunc = function(value) KS.sv.resourceDangerY = clamp(math.floor(tonumber(value) or defaults.resourceDangerY), -500, 500); KS.ApplyResourceDangerLayout() end,
                                    default = defaults.resourceDangerY, width = "full",
                                },
                                {
                                    type = "button", name = "Reset resource danger position",
                                    func = function() KS.sv.resourceDangerX = defaults.resourceDangerX; KS.sv.resourceDangerY = defaults.resourceDangerY; KS.ApplyResourceDangerLayout() end,
                                    width = "full",
                                },
                            },
                        },
                    },
                },
                {
                    type = "checkbox",
                    name = "Always collapse chat window",
                    tooltip = "Keeps the keyboard chat window minimized whenever you are not actively typing. Press Enter to use chat normally; after text entry closes the window is collapsed again.",
                    getFunc = function() return KS.sv.alwaysCollapseChat == true end,
                    setFunc = function(value)
                        KS.sv.alwaysCollapseChat = value and true or false
                        if KS.sv.alwaysCollapseChat then
                            zo_callLater(function() KS.ApplyAlwaysCollapseChat() end, 50)
                        end
                    end,
                    default = defaults.alwaysCollapseChat,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Self effects: CC immunity & debuffs",
            controls = {
                {
                    type = "description",
                    text = "Player-only effect tracking. CC immunity and debuffs are independent: either can be turned off without affecting the other. Movement controls are grouped with the HUD element they move.",
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Self effect icon size",
                    tooltip = "Shared icon size for the CC immunity icon and the debuff row.",
                    min = 34,
                    max = 68,
                    step = 1,
                    getFunc = function() return tonumber(KS.sv.playerAuraIconSize) or defaults.playerAuraIconSize end,
                    setFunc = function(value)
                        KS.sv.playerAuraIconSize = clamp(math.floor(tonumber(value) or defaults.playerAuraIconSize), 34, 68)
                        KS.ApplyPlayerAuraHudLayout()
                        KS.UpdatePlayerAuraHud()
                    end,
                    default = defaults.playerAuraIconSize,
                    width = "full",
                },
                {
                    type = "submenu",
                    name = "CC immunity",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show CC immunity timer",
                            tooltip = "Shows current hard crowd-control immunity as the active ESO buff icon with a countdown. Includes normal CC Immunity and common Immovable / Unstoppable sources.",
                            getFunc = function() return KS.sv.showCcImmunityTracker ~= false end,
                            setFunc = function(value)
                                KS.sv.showCcImmunityTracker = value and true or false
                                KS.ScanPlayerAuraHud()
                            end,
                            default = defaults.showCcImmunityTracker,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Unlock CC immunity icon for drag",
                            tooltip = "Shows a preview of the CC immunity / Immovability icon and lets you drag it directly with the mouse. Turn this off when finished; the position is saved in the active profile.",
                            getFunc = function() return KS.ccImmunityDragUnlocked == true end,
                            setFunc = function(value) KS.SetCcImmunityDragUnlocked(value == true) end,
                            default = false,
                            width = "full",
                        },
                        {
                            type = "submenu",
                            name = "Move CC immunity",
                            controls = {
                                {
                                    type = "slider",
                                    name = "Horizontal position",
                                    min = -800,
                                    max = 800,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.ccImmunityX) or defaults.ccImmunityX end,
                                    setFunc = function(value)
                                        KS.sv.ccImmunityX = clamp(math.floor(tonumber(value) or defaults.ccImmunityX), -800, 800)
                                        KS.ApplyPlayerAuraHudLayout()
                                    end,
                                    default = defaults.ccImmunityX,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Vertical position",
                                    tooltip = "Negative values move the CC immunity icon higher on the screen.",
                                    min = -520,
                                    max = 420,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.ccImmunityY) or defaults.ccImmunityY end,
                                    setFunc = function(value)
                                        KS.sv.ccImmunityY = clamp(math.floor(tonumber(value) or defaults.ccImmunityY), -520, 420)
                                        KS.ApplyPlayerAuraHudLayout()
                                    end,
                                    default = defaults.ccImmunityY,
                                    width = "full",
                                },
                                {
                                    type = "button",
                                    name = "Reset CC immunity position",
                                    func = function()
                                        KS.sv.ccImmunityX = defaults.ccImmunityX
                                        KS.sv.ccImmunityY = defaults.ccImmunityY
                                        KS.ApplyPlayerAuraHudLayout()
                                    end,
                                    width = "full",
                                },
                            },
                        },
                    },
                },
                {
                    type = "submenu",
                    name = "Debuffs on me",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show debuffs active on me",
                            tooltip = "Shows timed effects ESO classifies as BUFF_EFFECT_TYPE_DEBUFF on the player. Each debuff uses ESO's own icon and a countdown number.",
                            getFunc = function() return KS.sv.showPlayerDebuffTracker ~= false end,
                            setFunc = function(value)
                                KS.sv.showPlayerDebuffTracker = value and true or false
                                KS.ScanPlayerAuraHud()
                            end,
                            default = defaults.showPlayerDebuffTracker,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Maximum debuff icons",
                            min = 3,
                            max = 12,
                            step = 1,
                            getFunc = function() return tonumber(KS.sv.playerDebuffMaxIcons) or defaults.playerDebuffMaxIcons end,
                            setFunc = function(value)
                                KS.sv.playerDebuffMaxIcons = clamp(math.floor(tonumber(value) or defaults.playerDebuffMaxIcons), 3, 12)
                                KS.ApplyPlayerAuraHudLayout()
                                KS.UpdatePlayerAuraHud()
                            end,
                            default = defaults.playerDebuffMaxIcons,
                            disabled = function() return KS.sv.showPlayerDebuffTracker == false end,
                            width = "full",
                        },
                        {
                            type = "submenu",
                            name = "Move self debuffs",
                            controls = {
                                {
                                    type = "slider",
                                    name = "Horizontal position",
                                    min = -800,
                                    max = 800,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.playerDebuffX) or defaults.playerDebuffX end,
                                    setFunc = function(value)
                                        KS.sv.playerDebuffX = clamp(math.floor(tonumber(value) or defaults.playerDebuffX), -800, 800)
                                        KS.ApplyPlayerAuraHudLayout()
                                    end,
                                    default = defaults.playerDebuffX,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Vertical position",
                                    tooltip = "Negative values move the self-debuff row higher on the screen.",
                                    min = -520,
                                    max = 420,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.playerDebuffY) or defaults.playerDebuffY end,
                                    setFunc = function(value)
                                        KS.sv.playerDebuffY = clamp(math.floor(tonumber(value) or defaults.playerDebuffY), -520, 420)
                                        KS.ApplyPlayerAuraHudLayout()
                                    end,
                                    default = defaults.playerDebuffY,
                                    width = "full",
                                },
                                {
                                    type = "button",
                                    name = "Reset self-debuff position",
                                    func = function()
                                        KS.sv.playerDebuffX = defaults.playerDebuffX
                                        KS.sv.playerDebuffY = defaults.playerDebuffY
                                        KS.ApplyPlayerAuraHudLayout()
                                    end,
                                    width = "full",
                                },
                            },
                        },
                    },
                },
                {
                    type = "submenu",
                    name = "Self effect diagnostics",
                    controls = {
                        {
                            type = "button",
                            name = "Rescan player auras now",
                            func = function() KS.ScanPlayerAuraHud() end,
                            width = "half",
                        },
                        {
                            type = "button",
                            name = "Print aura diagnostic",
                            func = function() KS.PrintPlayerAuraHudDiagnostic() end,
                            width = "half",
                        },
                    },
                },
            },
        },
        {
            type = "submenu",
            name = "Live character stats",
            controls = {
                {
                    type = "description",
                    text = "Four number-only HUD widgets. They are NEVER locked: open any screen that gives you the mouse cursor and drag each white number directly. Damage Shield appears only while a shield is actually present.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Weapon / Spell Damage number",
                    tooltip = "Shows one white number using the higher of your current Weapon Damage and Spell Damage.",
                    getFunc = function() return KS.sv.showLiveDamageStat ~= false end,
                    setFunc = function(value)
                        KS.sv.showLiveDamageStat = value and true or false
                        KS.UpdateLiveStatWidgets(true)
                    end,
                    default = defaults.showLiveDamageStat,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Front Bar Resistance number",
                    tooltip = "Shows the lower of Physical and Spell Resistance last observed while your front weapon bar was active. Swap to the front bar once after login to refresh it exactly.",
                    getFunc = function() return KS.sv.showFrontResistanceStat ~= false end,
                    setFunc = function(value)
                        KS.sv.showFrontResistanceStat = value and true or false
                        KS.UpdateLiveStatWidgets(true)
                    end,
                    default = defaults.showFrontResistanceStat,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Back Bar Resistance number",
                    tooltip = "Shows the lower of Physical and Spell Resistance last observed while your back weapon bar was active. Swap to the back bar once after login to refresh it exactly.",
                    getFunc = function() return KS.sv.showBackResistanceStat ~= false end,
                    setFunc = function(value)
                        KS.sv.showBackResistanceStat = value and true or false
                        KS.UpdateLiveStatWidgets(true)
                    end,
                    default = defaults.showBackResistanceStat,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show current Damage Shield number",
                    tooltip = "Shows the current player damage-shield value as a white number and hides automatically when no shield remains.",
                    getFunc = function() return KS.sv.showDamageShieldStat ~= false end,
                    setFunc = function(value)
                        KS.sv.showDamageShieldStat = value and true or false
                        KS.UpdateLiveStatWidgets(true)
                    end,
                    default = defaults.showDamageShieldStat,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Live stat font size",
                    min = 16,
                    max = 42,
                    step = 1,
                    getFunc = function() return tonumber(KS.sv.liveStatFontSize) or defaults.liveStatFontSize end,
                    setFunc = function(value)
                        KS.sv.liveStatFontSize = clamp(math.floor(tonumber(value) or defaults.liveStatFontSize), 16, 42)
                        KS.ApplyLiveStatWidgetAppearance()
                    end,
                    default = defaults.liveStatFontSize,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset live stat positions",
                    tooltip = "Restores the four numbers to their default upper-middle row: Damage, Front Resistance, Back Resistance, Damage Shield.",
                    func = function() KS.ResetLiveStatPositions() end,
                    width = "half",
                },
                {
                    type = "button",
                    name = "Print live stat diagnostic",
                    tooltip = "Prints Weapon Damage, Spell Damage, Physical Resistance, Spell Resistance, recorded front/back values and the current damage shield to chat.",
                    func = function() KS.PrintLiveStatDiagnostic() end,
                    width = "half",
                },
            },
        },
        {
            type = "submenu",
            name = "PvP kills and deaths",
            controls = {
                {
                    type = "description",
                    text = "Tracks your PvP killing blows and deaths in Battlegrounds, Cyrodiil and Imperial City. The counter stays visible in supported PvP areas and is suppressed during duels. Battleground counts reset when a new running round or match starts. Cyrodiil and Imperial City counts reset when you enter a new PvP session or switch PvP areas.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show K/D counter",
                    tooltip = "Shows Kills and Deaths whenever you are in Battlegrounds, Cyrodiil, or Imperial City. The counter is always directly draggable when visible. Battleground values are read directly from the ESO scoreboard and reset for each match or round.",
                    getFunc = function() return KS.sv.showPvpKillCounter ~= false end,
                    setFunc = function(value) KS.sv.showPvpKillCounter = value and true or false; KS.UpdatePvpHud() end,
                    default = defaults.showPvpKillCounter,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset K/D counter position",
                    func = function() KS.ResetPvpHudPosition() end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show killed player message",
                    tooltip = "Shows KILLED @playername for a single kill. Rapid multi-kills add streak titles while keeping the exact count: DOUBLE KILL at 2, TRIPLE KILL at 3, QUAD KILL at 4, M M M MONSTER KILL from 5 to 9, and ULTRA KILL from 10 onward. The message stays up for about 3 seconds, then fades out.",
                    getFunc = function() return KS.sv.showPvpKillMessages ~= false end,
                    setFunc = function(value)
                        KS.sv.showPvpKillMessages = value and true or false
                        if not KS.sv.showPvpKillMessages and KS.killMessageRoot then
                            KS.killMessageExpiresAt = 0
                            KS.killMessageRoot:SetHidden(true)
                        end
                    end,
                    default = defaults.showPvpKillMessages,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Test kill message",
                    func = function()
                        if KS.sv.showPvpKillMessages == false or not KS.killMessageRoot or not KS.killMessageLabel then return end
                        KS.killMessageLabel:SetText("KILLED @TestPlayer")
                        KS.killMessageRoot:SetAlpha(1)
                        KS.killMessageRoot:SetHidden(false)
                        local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
                        KS.killMessageExpiresAt = now + 3.0
                    end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Reset current K/D",
                    func = function() KS.ResetPvpStats("manual", false) end,
                    width = "full",
                },
            },
        },
        {
            type = "submenu",
            name = "Target effects & debuffs",
            controls = {
                {
                    type = "description",
                    text = "Target combat information is split into independent collapsible sections. Major Breach and target debuffs can each be enabled, disabled and positioned without changing the other.",
                    width = "full",
                },
                {
                    type = "submenu",
                    name = "Major Breach dot",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show Major Breach dot",
                            tooltip = "Shows a small dot only for the current Tab targeted enemy. Red means Major Breach is active. White means Major Breach is not active. Hidden when there is no Tab target.",
                            getFunc = function() return KS.sv.majorBreachTracker ~= false end,
                            setFunc = function(value)
                                KS.sv.majorBreachTracker = value and true or false
                                if KS.sv.majorBreachTracker then
                                    KS.ScanTargetAuras()
                                else
                                    KS.SetMajorBreachState(false, 0, 0, "")
                                    KS.UpdateMajorBreachDisplay()
                                end
                            end,
                            default = defaults.majorBreachTracker,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Move Major Breach dot",
                            tooltip = "Temporarily forces the dot visible and makes it draggable. Close Settings, drag the dot where you want it, then turn this option off. The position is saved when you release the mouse button.",
                            getFunc = function() return KS.majorBreachEditMode == true end,
                            setFunc = function(value) KS.SetMajorBreachEditMode(value) end,
                            default = false,
                            width = "full",
                        },
                        {
                            type = "button",
                            name = "Reset Major Breach dot position",
                            func = function() KS.ResetMajorBreachPosition() end,
                            width = "full",
                        },
                    },
                },
                {
                    type = "submenu",
                    name = "Target debuffs",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show important target debuffs",
                            tooltip = "Shows timed high-value debuffs and combat status effects on the current live reticle target using ESO's official icons and countdowns. It reuses Ultivite's existing throttled target aura scan.",
                            getFunc = function() return KS.sv.showImportantTargetDebuffs ~= false end,
                            setFunc = function(value)
                                KS.sv.showImportantTargetDebuffs = value and true or false
                                if KS.sv.showImportantTargetDebuffs then
                                    KS.ScanTargetAuras()
                                else
                                    KS.targetDebuffAuras = {}
                                    KS.UpdateImportantTargetDebuffs(true)
                                end
                            end,
                            default = defaults.showImportantTargetDebuffs,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Target debuff icon size",
                            min = 30,
                            max = 64,
                            step = 1,
                            getFunc = function() return tonumber(KS.sv.targetDebuffIconSize) or defaults.targetDebuffIconSize end,
                            setFunc = function(value)
                                KS.sv.targetDebuffIconSize = clamp(math.floor(tonumber(value) or defaults.targetDebuffIconSize), 30, 64)
                                KS.ApplyImportantTargetDebuffLayout()
                                KS.UpdateImportantTargetDebuffs(true)
                            end,
                            default = defaults.targetDebuffIconSize,
                            disabled = function() return KS.sv.showImportantTargetDebuffs == false end,
                            width = "full",
                        },
                        {
                            type = "slider",
                            name = "Maximum target debuff icons",
                            min = 3,
                            max = 12,
                            step = 1,
                            getFunc = function() return tonumber(KS.sv.targetDebuffMaxIcons) or defaults.targetDebuffMaxIcons end,
                            setFunc = function(value)
                                KS.sv.targetDebuffMaxIcons = clamp(math.floor(tonumber(value) or defaults.targetDebuffMaxIcons), 3, 12)
                                KS.ApplyImportantTargetDebuffLayout()
                                KS.UpdateImportantTargetDebuffs(true)
                            end,
                            default = defaults.targetDebuffMaxIcons,
                            disabled = function() return KS.sv.showImportantTargetDebuffs == false end,
                            width = "full",
                        },
                        {
                            type = "submenu",
                            name = "Move target debuffs",
                            controls = {
                                {
                                    type = "slider",
                                    name = "Horizontal position",
                                    min = -800,
                                    max = 800,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.targetDebuffX) or defaults.targetDebuffX end,
                                    setFunc = function(value)
                                        KS.sv.targetDebuffX = clamp(math.floor(tonumber(value) or defaults.targetDebuffX), -800, 800)
                                        KS.ApplyImportantTargetDebuffLayout()
                                    end,
                                    default = defaults.targetDebuffX,
                                    width = "full",
                                },
                                {
                                    type = "slider",
                                    name = "Vertical position",
                                    min = -500,
                                    max = 500,
                                    step = 5,
                                    getFunc = function() return tonumber(KS.sv.targetDebuffY) or defaults.targetDebuffY end,
                                    setFunc = function(value)
                                        KS.sv.targetDebuffY = clamp(math.floor(tonumber(value) or defaults.targetDebuffY), -500, 500)
                                        KS.ApplyImportantTargetDebuffLayout()
                                    end,
                                    default = defaults.targetDebuffY,
                                    width = "full",
                                },
                                {
                                    type = "button",
                                    name = "Reset target debuff position",
                                    func = function()
                                        KS.sv.targetDebuffX = defaults.targetDebuffX
                                        KS.sv.targetDebuffY = defaults.targetDebuffY
                                        KS.ApplyImportantTargetDebuffLayout()
                                    end,
                                    width = "full",
                                },
                            },
                        },
                        {
                            type = "button",
                            name = "Print target debuff diagnostic",
                            func = function() KS.PrintImportantTargetDebuffDiagnostic() end,
                            width = "full",
                        },
                    },
                },
            },
        },
        {
            type = "submenu",
            name = "Combat Timers & Set Trackers",
            controls = {
                {
                    type = "description",
                    text = "Onslaught tracks its active window. Balorgh tracks the monster-set window after an Ultimate while the 2-piece is equipped.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Kjalnar stack counter",
                    tooltip = "Shows the existing number-only Kjalnar stack counter while the 2-piece is equipped. Full Dark Souls disables this so only its resource and enemy Health bars remain visible.",
                    getFunc = function() return KS.sv.showKjalnarTracker ~= false end,
                    setFunc = function(value)
                        KS.sv.showKjalnarTracker = value and true or false
                        KS.RefreshDisplay()
                    end,
                    default = defaults.showKjalnarTracker,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Onslaught timer",
                    getFunc = function() return KS.sv.onslaughtTimer ~= false end,
                    setFunc = function(value) KS.sv.onslaughtTimer = value and true or false; KS.UpdateCombatTimers() end,
                    default = defaults.onslaughtTimer,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Balorgh timer",
                    getFunc = function() return KS.sv.balorghTimer ~= false end,
                    setFunc = function(value) KS.sv.balorghTimer = value and true or false; KS.UpdateCombatTimers() end,
                    default = defaults.balorghTimer,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Wretched Vitality tracker",
                    tooltip = "Shows the two timed Wretched Vitality recovery buffs using ESO's active buff icons and independent countdowns.",
                    getFunc = function() return KS.sv.wretchedVitalityTimers ~= false end,
                    setFunc = function(value)
                        KS.sv.wretchedVitalityTimers = value and true or false
                        if KS.sv.wretchedVitalityTimers then
                            KS.ScanWretchedVitalityBuffs()
                        else
                            KS.wretchedVitalityBuffs = {}
                            KS.UpdateWretchedVitalityTimers()
                        end
                    end,
                    default = defaults.wretchedVitalityTimers,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Tarnished Nightmare tracker",
                    tooltip = "Shows the 1.3 second glass burst delay and the remaining 8 second proc cooldown while the 5-piece is active.",
                    getFunc = function() return KS.sv.tarnishedTimer ~= false end,
                    setFunc = function(value) KS.sv.tarnishedTimer = value and true or false; KS.UpdateCombatTimers() end,
                    default = defaults.tarnishedTimer,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Null Arca tracker",
                    tooltip = "Shows Sliver progress to 3 stacks, then the 4 second lockout after the crystal launches.",
                    getFunc = function() return KS.sv.nullArcaTimer ~= false end,
                    setFunc = function(value) KS.sv.nullArcaTimer = value and true or false; KS.UpdateCombatTimers() end,
                    default = defaults.nullArcaTimer,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Dragon's Appetite stack counter",
                    tooltip = "When the Dragon's Appetite 5-piece is worn, shows the actual player buff stacks as 0 / 10 through 9 / 10 during combat. The 10th stack is consumed immediately by the set heal.",
                    getFunc = function() return KS.sv.dragonAppetiteCounter ~= false end,
                    setFunc = function(value)
                        KS.sv.dragonAppetiteCounter = value and true or false
                        KS.lastTimerLayoutKey = nil
                        KS.UpdateCombatTimers()
                    end,
                    default = defaults.dragonAppetiteCounter,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Dragon's Appetite font size",
                    tooltip = "Adjusts only the Dragon's Appetite stack counter. The new default is 22, half of the previous 44-point presentation.",
                    min = 10,
                    max = 36,
                    step = 1,
                    getFunc = function()
                        return tonumber(KS.sv.dragonAppetiteFontSize) or defaults.dragonAppetiteFontSize
                    end,
                    setFunc = function(value)
                        KS.sv.dragonAppetiteFontSize = clamp(math.floor(tonumber(value) or defaults.dragonAppetiteFontSize), 10, 36)
                        KS.ApplyFontSettings()
                        KS.UpdateCombatTimers()
                    end,
                    default = defaults.dragonAppetiteFontSize,
                    disabled = function() return KS.sv.dragonAppetiteCounter == false end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Dragon's Appetite vertical position",
                    tooltip = "Moves only the Dragon's Appetite stack counter. Negative values move it farther up the screen; positive values move it down.",
                    min = -250,
                    max = 200,
                    step = 5,
                    getFunc = function()
                        return tonumber(KS.sv.dragonAppetiteYOffset) or defaults.dragonAppetiteYOffset
                    end,
                    setFunc = function(value)
                        KS.sv.dragonAppetiteYOffset = clamp(math.floor(tonumber(value) or defaults.dragonAppetiteYOffset), -250, 200)
                        KS.lastTimerLayoutKey = nil
                        KS.UpdateCombatTimers()
                    end,
                    default = defaults.dragonAppetiteYOffset,
                    disabled = function() return KS.sv.dragonAppetiteCounter == false end,
                    width = "full",
                },
                {
                    type = "submenu",
                    name = "Slotted skill stacks & Streak",
                    controls = {
                    {
                        type = "description",
                        text = "Automatic generic stack display for slotted abilities. It reads ESO's public hotbar effect stack values and does not replace Kjalnar, Dragon's Appetite, Wretched Vitality, Null Arca or any existing dedicated tracker.",
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show slotted skill stack tracker",
                        getFunc = function() return KS.sv.showGenericStackTracker ~= false end,
                        setFunc = function(value) KS.sv.showGenericStackTracker = value and true or false; KS.UpdateSkillStackTrackers(true) end,
                        default = defaults.showGenericStackTracker, width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show Streak fatigue counter",
                        tooltip = "Shows the Streak icon and current fatigue stack while ESO reports Streak's slotted effect as active. It disappears when the effect ends.",
                        getFunc = function() return KS.sv.showStreakFatigueTracker ~= false end,
                        setFunc = function(value) KS.sv.showStreakFatigueTracker = value and true or false; KS.UpdateSkillStackTrackers(true) end,
                        default = defaults.showStreakFatigueTracker, width = "full",
                    },
                    {
                        type = "slider", name = "Skill stack icon size", min = 30, max = 64, step = 1,
                        getFunc = function() return tonumber(KS.sv.genericStackIconSize) or defaults.genericStackIconSize end,
                        setFunc = function(value) KS.sv.genericStackIconSize = clamp(math.floor(tonumber(value) or defaults.genericStackIconSize), 30, 64); KS.ApplySkillStackTrackerLayout(); KS.UpdateSkillStackTrackers(true) end,
                        default = defaults.genericStackIconSize, width = "full",
                    },
                    {
                        type = "submenu",
                        name = "Skill stack positions (advanced)",
                        controls = {
                            { type = "slider", name = "Generic stacks horizontal", min = -800, max = 800, step = 5, getFunc = function() return tonumber(KS.sv.genericStackX) or defaults.genericStackX end, setFunc = function(value) KS.sv.genericStackX = clamp(math.floor(tonumber(value) or defaults.genericStackX), -800, 800); KS.ApplySkillStackTrackerLayout() end, default = defaults.genericStackX, width = "full" },
                            { type = "slider", name = "Generic stacks vertical", min = -500, max = 500, step = 5, getFunc = function() return tonumber(KS.sv.genericStackY) or defaults.genericStackY end, setFunc = function(value) KS.sv.genericStackY = clamp(math.floor(tonumber(value) or defaults.genericStackY), -500, 500); KS.ApplySkillStackTrackerLayout() end, default = defaults.genericStackY, width = "full" },
                            { type = "slider", name = "Streak fatigue horizontal", min = -800, max = 800, step = 5, getFunc = function() return tonumber(KS.sv.streakFatigueX) or defaults.streakFatigueX end, setFunc = function(value) KS.sv.streakFatigueX = clamp(math.floor(tonumber(value) or defaults.streakFatigueX), -800, 800); KS.ApplySkillStackTrackerLayout() end, default = defaults.streakFatigueX, width = "full" },
                            { type = "slider", name = "Streak fatigue vertical", min = -500, max = 500, step = 5, getFunc = function() return tonumber(KS.sv.streakFatigueY) or defaults.streakFatigueY end, setFunc = function(value) KS.sv.streakFatigueY = clamp(math.floor(tonumber(value) or defaults.streakFatigueY), -500, 500); KS.ApplySkillStackTrackerLayout() end, default = defaults.streakFatigueY, width = "full" },
                            { type = "button", name = "Reset skill stack positions", func = function() KS.sv.genericStackX = defaults.genericStackX; KS.sv.genericStackY = defaults.genericStackY; KS.sv.streakFatigueX = defaults.streakFatigueX; KS.sv.streakFatigueY = defaults.streakFatigueY; KS.ApplySkillStackTrackerLayout() end, width = "full" },
                        },
                    },
                    { type = "button", name = "Print skill stack diagnostic", func = function() KS.PrintSkillStackDiagnostic() end, width = "full" },
                    },
                },
                {
                    type = "submenu",
                    name = "Wretched Vitality settings",
                    controls = {
                    {
                        type = "description",
                        text = "Use the Show Wretched Vitality tracker toggle above to enable or disable tracking. These controls adjust its two buff icons, countdowns and position.",
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Wretched Vitality icon size",
                        min = 36,
                        max = 80,
                        step = 1,
                        getFunc = function()
                            return tonumber(KS.sv.wretchedVitalityIconSize) or defaults.wretchedVitalityIconSize
                        end,
                        setFunc = function(value)
                            KS.sv.wretchedVitalityIconSize = clamp(math.floor(tonumber(value) or defaults.wretchedVitalityIconSize), 36, 80)
                            KS.ApplyWretchedVitalityLayout()
                            KS.UpdateWretchedVitalityTimers()
                        end,
                        default = defaults.wretchedVitalityIconSize,
                        disabled = function() return KS.sv.wretchedVitalityTimers == false end,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Wretched Vitality horizontal position",
                        tooltip = "Moves both icons left or right.",
                        min = -700,
                        max = 700,
                        step = 5,
                        getFunc = function()
                            return tonumber(KS.sv.wretchedVitalityX) or defaults.wretchedVitalityX
                        end,
                        setFunc = function(value)
                            KS.sv.wretchedVitalityX = clamp(math.floor(tonumber(value) or defaults.wretchedVitalityX), -700, 700)
                            KS.ApplyWretchedVitalityLayout()
                        end,
                        default = defaults.wretchedVitalityX,
                        disabled = function() return KS.sv.wretchedVitalityTimers == false end,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Wretched Vitality vertical position",
                        tooltip = "Negative values move the two Wretched Vitality icons higher on the screen. Default is -350.",
                        min = -500,
                        max = 350,
                        step = 5,
                        getFunc = function()
                            return tonumber(KS.sv.wretchedVitalityY) or defaults.wretchedVitalityY
                        end,
                        setFunc = function(value)
                            KS.sv.wretchedVitalityY = clamp(math.floor(tonumber(value) or defaults.wretchedVitalityY), -500, 350)
                            KS.ApplyWretchedVitalityLayout()
                        end,
                        default = defaults.wretchedVitalityY,
                        disabled = function() return KS.sv.wretchedVitalityTimers == false end,
                        width = "full",
                    },
                    {
                        type = "button",
                        name = "Rescan Wretched Vitality buffs",
                        tooltip = "Immediately rescans the player's active buffs. Useful if testing a new proc source.",
                        func = function() KS.ScanWretchedVitalityBuffs() end,
                        disabled = function() return KS.sv.wretchedVitalityTimers == false end,
                        width = "full",
                    },
                    },
                },
                {
                    type = "dropdown",
                    name = "Timer position",
                    choices = { "Above frame", "Below frame" },
                    getFunc = function() return KS.sv.timerPlacement or defaults.timerPlacement end,
                    setFunc = function(value) KS.sv.timerPlacement = value or defaults.timerPlacement; KS.ApplyTimerAnchor(); KS.UpdateCombatTimers() end,
                    default = defaults.timerPlacement,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Timer font size",
                    min = 16, max = 44, step = 1,
                    getFunc = function() return tonumber(KS.sv.timerFontSize) or defaults.timerFontSize end,
                    setFunc = function(value) KS.sv.timerFontSize = tonumber(value) or defaults.timerFontSize; KS.ApplyFontSettings(); KS.UpdateCombatTimers() end,
                    default = defaults.timerFontSize,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Balorgh timer font size",
                    tooltip = "Adjusts the Balorgh countdown independently. The timer remains text-only with no background panel.",
                    min = 16, max = 48, step = 1,
                    getFunc = function() return tonumber(KS.sv.balorghTimerFontSize) or defaults.balorghTimerFontSize end,
                    setFunc = function(value) KS.sv.balorghTimerFontSize = tonumber(value) or defaults.balorghTimerFontSize; KS.ApplyFontSettings(); KS.UpdateCombatTimers() end,
                    default = defaults.balorghTimerFontSize,
                    width = "full",
                },
                { type = "button", name = "Test Onslaught", func = function() KS.StartCombatTimer("onslaught", 8) end, width = "half" },
                { type = "button", name = "Test Balorgh", func = function() KS.StartCombatTimer("balorgh", 12) end, width = "half" },
                { type = "button", name = "Test Tarnished", func = function() KS.StartTarnishedTracker() end, width = "half" },
                { type = "button", name = "Test Null Arca", func = function() KS.nullArcaStacks = 2; KS.nullArcaLastStackAt = 0; KS.nullArcaStackExpiresAt = (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0) + 10; KS.AddNullArcaCritical() end, width = "half" },
            },
        },
        {
            type = "submenu",
            name = "Combat HUD Text Appearance",
            controls = {
                {
                    type = "dropdown",
                    name = "Font",
                    choices = FONT_FACE_CHOICES,
                    getFunc = function() return KS.sv.fontFace or defaults.fontFace end,
                    setFunc = function(value) KS.sv.fontFace = value or defaults.fontFace; KS.ApplyFontSettings() end,
                    default = defaults.fontFace,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Bold font",
                    getFunc = function() return KS.sv.boldFont == true end,
                    setFunc = function(value) KS.sv.boldFont = value and true or false; KS.ApplyFontSettings() end,
                    default = defaults.boldFont,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Thick text shadow",
                    getFunc = function() return KS.sv.thickTextShadow ~= false end,
                    setFunc = function(value) KS.sv.thickTextShadow = value and true or false; KS.ApplyFontSettings() end,
                    default = defaults.thickTextShadow,
                    width = "full",
                },
                { type = "slider", name = "Target name font size", min = 14, max = 40, step = 1, getFunc = function() return tonumber(KS.sv.nameFontSize) or defaults.nameFontSize end, setFunc = function(value) KS.sv.nameFontSize = tonumber(value) or defaults.nameFontSize; KS.ApplyFontSettings() end, default = defaults.nameFontSize, width = "full" },
                { type = "slider", name = "Health text font size", min = 16, max = 44, step = 1, getFunc = function() return tonumber(KS.sv.healthFontSize) or defaults.healthFontSize end, setFunc = function(value) KS.sv.healthFontSize = tonumber(value) or defaults.healthFontSize; KS.ApplyFontSettings() end, default = defaults.healthFontSize, width = "full" },
                { type = "slider", name = "Kjalnar counter font size", min = 18, max = 42, step = 1, getFunc = function() return tonumber(KS.sv.kjalnarFontSize) or defaults.kjalnarFontSize end, setFunc = function(value) KS.sv.kjalnarFontSize = tonumber(value) or defaults.kjalnarFontSize; KS.ApplyFontSettings() end, default = defaults.kjalnarFontSize, width = "full" },
                { type = "button", name = "Increase all text", func = function() KS.AdjustAllFontSizes(1) end, width = "half" },
                { type = "button", name = "Decrease all text", func = function() KS.AdjustAllFontSizes(-1) end, width = "half" },
                { type = "button", name = "Reset text appearance", func = function() KS.ResetFontSettings() end, width = "full" },
            },
        },
        {
            type = "submenu",
            name = "Combat HUD Reset",
            controls = {
                {
                    type = "button",
                    name = "Reset position and size",
                    tooltip = "Returns the frame to its addon default position and size.",
                    func = function() KS.ResetPosition(true); KS.RefreshDisplay(); KS.UpdateCombatTimers() end,
                    width = "full",
                    warning = "This changes your saved frame position and size.",
                },
            },
        },
    }

    return options
end

function KS.BuildMenu()
    return KS.GetMenuOptions()
end

function KS.DetectKjalnarEquipped()
    if not GetItemLink or not GetItemLinkSetInfo then return false, 0, "", 0 end

    local matchingPieces = 0
    local detectedSetId = 0
    local detectedSetName = ""
    local knownSetId = tonumber(KS.sv and KS.sv.kjalnarSetId) or 0
    local slots = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS }

    for _, slotIndex in ipairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink, true)
            setId = tonumber(setId) or 0
            if hasSet and ((knownSetId > 0 and setId == knownSetId) or looksLikeKjalnarSetName(setName)) then
                matchingPieces = matchingPieces + 1
                detectedSetId = setId
                detectedSetName = setName or detectedSetName
                if knownSetId <= 0 and setId > 0 and KS.sv then
                    KS.sv.kjalnarSetId = setId
                    knownSetId = setId
                end
            end
        end
    end

    return matchingPieces >= 2, detectedSetId, detectedSetName, matchingPieces
end

function KS.DetectBalorghEquipped()
    if not GetItemLink or not GetItemLinkSetInfo then return false, "", 0 end
    local matchingPieces = 0
    local detectedSetName = ""
    local slots = { EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS }
    for _, slotIndex in ipairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local hasSet, setName = GetItemLinkSetInfo(itemLink, true)
            if hasSet and looksLikeBalorghSetName(setName) then
                matchingPieces = matchingPieces + 1
                detectedSetName = setName or detectedSetName
            end
        end
    end
    return matchingPieces >= 2, detectedSetName, matchingPieces
end

local function addEquipSlot(slots, slot)
    if slot ~= nil then slots[#slots + 1] = slot end
end

function KS.CountProcSetPieces(matcher)
    if not GetItemLink or not GetItemLinkSetInfo then return false, false, 0, 0, "" end

    local bodySlots = {}
    addEquipSlot(bodySlots, EQUIP_SLOT_HEAD)
    addEquipSlot(bodySlots, EQUIP_SLOT_CHEST)
    addEquipSlot(bodySlots, EQUIP_SLOT_SHOULDERS)
    addEquipSlot(bodySlots, EQUIP_SLOT_WAIST)
    addEquipSlot(bodySlots, EQUIP_SLOT_HAND)
    addEquipSlot(bodySlots, EQUIP_SLOT_LEGS)
    addEquipSlot(bodySlots, EQUIP_SLOT_FEET)
    addEquipSlot(bodySlots, EQUIP_SLOT_NECK)
    addEquipSlot(bodySlots, EQUIP_SLOT_RING1)
    addEquipSlot(bodySlots, EQUIP_SLOT_RING2)

    local mainSlots = {}
    addEquipSlot(mainSlots, EQUIP_SLOT_MAIN_HAND)
    addEquipSlot(mainSlots, EQUIP_SLOT_OFF_HAND)

    local backupSlots = {}
    addEquipSlot(backupSlots, EQUIP_SLOT_BACKUP_MAIN)
    addEquipSlot(backupSlots, EQUIP_SLOT_BACKUP_OFF)

    local detectedName = ""
    local function countSlots(slots)
        local count = 0
        for _, slotIndex in ipairs(slots) do
            local itemLink = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)
            if itemLink and itemLink ~= "" then
                local hasSet, setName = GetItemLinkSetInfo(itemLink, true)
                if hasSet and matcher(setName) then
                    detectedName = setName or detectedName
                    local weight = 1
                    if GetItemLinkEquipType and EQUIP_TYPE_TWO_HAND and GetItemLinkEquipType(itemLink) == EQUIP_TYPE_TWO_HAND then
                        weight = 2
                    end
                    count = count + weight
                end
            end
        end
        return count
    end

    local bodyCount = countSlots(bodySlots)
    local mainCount = countSlots(mainSlots)
    local backupCount = countSlots(backupSlots)
    local weaponPair = GetActiveWeaponPairInfo and GetActiveWeaponPairInfo() or ACTIVE_WEAPON_PAIR_MAIN
    local activeWeaponCount = weaponPair == ACTIVE_WEAPON_PAIR_BACKUP and backupCount or mainCount
    local activeCount = bodyCount + activeWeaponCount
    local totalCount = math.max(bodyCount + mainCount, bodyCount + backupCount)

    return activeCount >= 5, totalCount >= 5, activeCount, totalCount, detectedName
end

function KS.RefreshProcSetEquipment(silent)
    local oldTarnishedActive = KS.tarnishedActive == true
    local oldNullActive = KS.nullArcaActive == true
    local oldDragonActive = KS.dragonAppetiteActive == true

    local tarnishedActive, tarnishedWorn, tarnishedActiveCount, tarnishedTotalCount, tarnishedName = KS.CountProcSetPieces(looksLikeTarnishedSetName)
    KS.tarnishedActive = tarnishedActive and true or false
    KS.tarnishedWorn = tarnishedWorn and true or false
    KS.tarnishedPiecesActive = tonumber(tarnishedActiveCount) or 0
    KS.tarnishedPiecesTotal = tonumber(tarnishedTotalCount) or 0
    KS.tarnishedSetName = tarnishedName or ""

    local nullActive, nullWorn, nullActiveCount, nullTotalCount, nullName = KS.CountProcSetPieces(looksLikeNullArcaSetName)
    KS.nullArcaActive = nullActive and true or false
    KS.nullArcaWorn = nullWorn and true or false
    KS.nullArcaPiecesActive = tonumber(nullActiveCount) or 0
    KS.nullArcaPiecesTotal = tonumber(nullTotalCount) or 0
    KS.nullArcaSetName = nullName or ""

    local dragonActive, dragonWorn, dragonActiveCount, dragonTotalCount, dragonName = KS.CountProcSetPieces(looksLikeDragonAppetiteSetName)
    KS.dragonAppetiteActive = dragonActive and true or false
    KS.dragonAppetiteWorn = dragonWorn and true or false
    KS.dragonAppetitePiecesActive = tonumber(dragonActiveCount) or 0
    KS.dragonAppetitePiecesTotal = tonumber(dragonTotalCount) or 0
    KS.dragonAppetiteSetName = dragonName or ""

    if not KS.nullArcaWorn then
        KS.nullArcaStacks = 0
        KS.nullArcaStackExpiresAt = 0
        KS.nullArcaLastStackAt = 0
        KS.nullArcaProcFlashUntil = 0
        KS.nullArcaExpiresAt = 0
    end
    if not KS.tarnishedWorn then
        KS.tarnishedTriggeredAt = 0
        KS.tarnishedProcAt = 0
        KS.tarnishedExpiresAt = 0
    end
    if not KS.dragonAppetiteWorn then
        KS.dragonAppetiteStacks = 0
        KS.dragonAppetiteAbilityId = 0
        KS.dragonAppetiteEffectName = ""
    end

    if not silent and oldTarnishedActive ~= KS.tarnishedActive then
        KS.DiagnosticChat(KS.tarnishedActive and "Tarnished Nightmare 5-piece active on this bar." or "Tarnished Nightmare 5-piece inactive on this bar.")
    end
    if not silent and oldNullActive ~= KS.nullArcaActive then
        KS.DiagnosticChat(KS.nullArcaActive and "Null Arca 5-piece active on this bar." or "Null Arca 5-piece inactive on this bar.")
    end
    if not silent and oldDragonActive ~= KS.dragonAppetiteActive then
        KS.DiagnosticChat(KS.dragonAppetiteActive and "Dragon's Appetite 5-piece active on this bar." or "Dragon's Appetite 5-piece inactive on this bar.")
    end

    KS.lastTimerLayoutKey = nil
    KS.UpdateCombatTimers()
end

function KS.RefreshKjalnarEquipment(silent)
    local wasEquipped = KS.kjalnarEquipped == true
    KS.RefreshProcSetEquipment(true)
    local equipped, setId, setName, pieces = KS.DetectKjalnarEquipped()
    KS.kjalnarEquipped = equipped and true or false
    KS.kjalnarEquippedPieces = tonumber(pieces) or 0
    KS.kjalnarSetName = setName or ""

    local wasBalorghEquipped = KS.balorghEquipped == true
    local balorghEquipped, balorghSetName, balorghPieces = KS.DetectBalorghEquipped()
    KS.balorghEquipped = balorghEquipped and true or false
    KS.balorghEquippedPieces = tonumber(balorghPieces) or 0
    KS.balorghSetName = balorghSetName or ""
    if not KS.balorghEquipped then
        KS.balorghExpiresAt = 0
    end

    if not KS.kjalnarEquipped then
        KS.currentStacks = 0
        KS.currentExpiresAt = 0
    end

    if not silent and wasEquipped ~= KS.kjalnarEquipped then
        if KS.kjalnarEquipped then
            KS.DiagnosticChat("Kjalnar 2-piece detected. Bone stack counter enabled.")
        else
            KS.DiagnosticChat("Kjalnar 2-piece not equipped. Persistent target frame remains active; bone stack counter hidden.")
        end
    end

    if not silent and wasBalorghEquipped ~= KS.balorghEquipped then
        if KS.balorghEquipped then
            KS.DiagnosticChat("Balorgh 2-piece detected. Balorgh Ultimate timer enabled.")
        else
            KS.DiagnosticChat("Balorgh 2-piece not equipped. Balorgh timer will remain idle.")
        end
    end

    if KS.root then KS.RefreshDisplay() end
    KS.UpdateCombatTimers()
end

function KS.IsReticleDecoyCandidate(unitTag)
    unitTag = unitTag or KS.unitTag
    if not KS.sv or not KS.sv.decoyGuard then return false end
    if DoesUnitExist and not DoesUnitExist(unitTag) then return false end
    if IsUnitPlayer and IsUnitPlayer(unitTag) then return false end

    local name = cleanName(GetUnitName(unitTag))
    if name == "" then return false end
    if looksLikeExplicitDecoyName(name) then return true end

    -- Generic Dwarven Sphere style names are only treated as Engine Guardian
    -- decoys while a retained target exists. This prevents real PvE
    -- Dwarven Sphere enemies from being filtered out.
    local selectedInfo = KS.targetInfoCache and KS.targetInfoCache[KS.selectedTarget or ""] or nil
    if selectedInfo and selectedInfo.isPlayer and looksLikeGenericEngineGuardianName(name) then
        return true
    end

    return false
end

function KS.IsLiveTarget(unitTag)
    unitTag = unitTag or KS.unitTag
    if DoesUnitExist and not DoesUnitExist(unitTag) then return false end
    if KS.IsReticleDecoyCandidate(unitTag) then return false end

    -- Players must be displayable on mouseover even when ESO does not currently
    -- classify them as attackable. This is common outside combat and was the
    -- reason the custom target frame appeared to be combat-only.
    if IsUnitPlayer and IsUnitPlayer(unitTag) then return true end

    -- Keep normal PvE behaviour restricted to actual attackable targets so
    -- scenery, critters, assistants and other incidental units do not steal
    -- the target frame.
    if IsUnitAttackable then return IsUnitAttackable(unitTag) == true end
    return cleanName(GetUnitName(unitTag)) ~= ""
end

function KS.GetTargetName()
    if not KS.IsLiveTarget(KS.unitTag) then return "" end
    return cleanName(GetUnitName(KS.unitTag))
end

function KS.GetReticleNonPlayerName()
    if DoesUnitExist and not DoesUnitExist(KS.unitTag) then return "" end
    if IsUnitPlayer and IsUnitPlayer(KS.unitTag) then return "" end
    return cleanName(GetUnitName(KS.unitTag))
end

function KS.IsDecoyUnderReticle()
    if not KS.sv or not KS.sv.decoyGuard then return false, "" end
    if not KS.IsReticleDecoyCandidate(KS.unitTag) then return false, "" end
    local name = KS.GetReticleNonPlayerName()
    return name ~= "" and true or false, name
end

function KS.TargetExists()
    return KS.selectedTarget ~= ""
end

function KS.CacheTargetState(name, stacks, expiresAt, abilityId, effectName)
    if not name or name == "" then return end
    KS.targetCache[name] = {
        stacks = clamp(tonumber(stacks) or 0, 0, 5),
        expiresAt = tonumber(expiresAt) or 0,
        abilityId = tonumber(abilityId) or 0,
        effectName = effectName or "",
        updatedAt = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0,
    }
end

function KS.LoadCachedTargetState(name)
    local state = name and KS.targetCache[name] or nil
    if not state then
        KS.currentStacks = 0
        KS.currentExpiresAt = 0
        return
    end
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    if state.expiresAt and state.expiresAt > 0 and now >= state.expiresAt then
        state.stacks = 0
        state.expiresAt = 0
    end
    KS.currentStacks = tonumber(state.stacks) or 0
    KS.currentExpiresAt = tonumber(state.expiresAt) or 0
    if state.abilityId and state.abilityId > 0 then KS.currentAbilityId = state.abilityId end
    if state.effectName and state.effectName ~= "" then KS.currentEffectName = state.effectName end
end

function KS.CaptureTargetInfo(name, trustedLiveTarget)
    if not name or name == "" then return end
    if DoesUnitExist and not DoesUnitExist(KS.unitTag) then return end

    local liveName = cleanName(GetUnitName(KS.unitTag))
    if liveName == "" or liveName ~= name then return end
    if not trustedLiveTarget and not KS.IsLiveTarget(KS.unitTag) then return end

    -- Keep EVENT_RETICLE_TARGET_CHANGED cheap. Only capture the values required to
    -- draw the frame immediately. Display name / CP / effective level are enriched
    -- after the target has remained under the reticle for a short period.
    local isPlayer = IsUnitPlayer and IsUnitPlayer(KS.unitTag) or false
    local health, healthMax = 0, 0
    if GetUnitPower then
        health, healthMax = GetUnitPower(KS.unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    end

    local existing = KS.targetInfoCache[name] or {}
    local info = {
        name = name,
        isPlayer = isPlayer,
        displayName = existing.displayName or "",
        className = "",
        classId = 0,
        championPoints = tonumber(existing.championPoints) or 0,
        level = tonumber(existing.level) or 0,
        health = tonumber(health) or 0,
        healthMax = tonumber(healthMax) or 0,
        updatedAt = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0,
    }
    KS.targetInfoCache[name] = info

    KS.pendingMetadataSerial = (tonumber(KS.pendingMetadataSerial) or 0) + 1
    local serial = KS.pendingMetadataSerial
    zo_callLater(function()
        if serial ~= KS.pendingMetadataSerial then return end
        if KS.currentTarget ~= name then return end
        if DoesUnitExist and not DoesUnitExist(KS.unitTag) then return end
        local currentName = cleanName(GetUnitName(KS.unitTag))
        if currentName ~= name then return end

        local cached = KS.targetInfoCache[name]
        if not cached then return end
        local changed = false

        if cached.isPlayer and GetUnitDisplayName then
            local displayName = GetUnitDisplayName(KS.unitTag) or ""
            if cached.displayName ~= displayName then cached.displayName = displayName; changed = true end
        end

        local cp = 0
        if cached.isPlayer then
            if GetUnitEffectiveChampionPoints then
                cp = GetUnitEffectiveChampionPoints(KS.unitTag)
            elseif GetUnitChampionPoints then
                cp = GetUnitChampionPoints(KS.unitTag)
            end
        end
        cp = tonumber(cp) or 0
        if cached.championPoints ~= cp then cached.championPoints = cp; changed = true end

        local level = 0
        if cp <= 0 and GetUnitEffectiveLevel then level = tonumber(GetUnitEffectiveLevel(KS.unitTag)) or 0 end
        if cached.level ~= level then cached.level = level; changed = true end

        if changed then KS.RefreshDisplay(true) end
    end, 75)
end

function KS.SetSelectedTarget(name)
    if not name or name == "" then return false end
    local changed = KS.selectedTarget ~= name
    if changed then
        KS.selectedTarget = name
        KS.currentTarget = name
        KS.currentEffectName = ""
        KS.SetMajorBreachState(false, 0, 0, "")
        KS.LoadCachedTargetState(name)
    else
        KS.currentTarget = name
    end

    if changed or not KS.targetInfoCache[name] then
        KS.CaptureTargetInfo(name, true)
    end
    return changed
end

function KS.ClearTarget()
    KS.selectedTarget = ""
    KS.currentTarget = ""
    KS.currentStacks = 0
    KS.currentExpiresAt = 0
    KS.liveSelectedTarget = false
    KS.lastDecoyName = ""
    KS.SetMajorBreachState(false, 0, 0, "")
    KS.RefreshDisplay(true)
    KS.UpdateMajorBreachDisplay()
end

function KS.CreateUI()
    local wm = WINDOW_MANAGER

    local root = wm:CreateTopLevelWindow("KjalnarStacksIndicator")
    KS.root = root
    root:SetDimensions(FRAME_WIDTH, FRAME_DEFAULT_HEIGHT)
    root:SetScale(KS.GetFrameScale())
    root:SetClampedToScreen(true)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetMovable(true)
    root:SetMouseEnabled(false)
    root:SetHidden(true)
    KS.CreateWorldTargetProbe()
    KS.ApplyPosition()

    local breachRoot = wm:CreateTopLevelWindow("KjalnarStacksMajorBreach")
    KS.majorBreachRoot = breachRoot
    breachRoot:SetDimensions(28, 24)
    breachRoot:SetDrawLayer(DL_OVERLAY)
    breachRoot:SetDrawTier(DT_HIGH)
    breachRoot:SetClampedToScreen(true)
    breachRoot:SetMovable(false)
    breachRoot:SetMouseEnabled(false)
    breachRoot:SetHidden(true)

    breachRoot:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and KS.majorBreachEditMode then
            control:StartMoving()
        end
    end)
    breachRoot:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and KS.majorBreachEditMode then
            control:StopMovingOrResizing()
            KS.SaveMajorBreachPosition()
        end
    end)

    local breachLabel = wm:CreateControl("KjalnarStacksMajorBreachLabel", breachRoot, CT_LABEL)
    KS.majorBreachLabel = breachLabel
    breachLabel:SetAnchorFill(breachRoot)
    breachLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", clamp(math.floor(tonumber(KS.sv.majorBreachFontSize) or defaults.majorBreachFontSize), 10, 34)))
    breachLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    breachLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    breachLabel:SetText("●")
    breachLabel:SetColor(1.0, 1.0, 1.0, 1.0)
    KS.ApplyMajorBreachPosition()

    local outline = wm:CreateControl("KjalnarStacksIndicatorOutline", root, CT_BACKDROP)
    KS.outline = outline
    outline:SetAnchorFill(root)
    outline:SetCenterColor(0, 0, 0, 0)
    outline:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 16, 1)
    outline:SetInsets(1, 1, -1, -1)
    outline:SetEdgeColor(0.25, 0.72, 0.95, KS.sv.locked and 0 or 0.75)

    local nameLabel = wm:CreateControl("KjalnarStacksPlayerName", root, CT_LABEL)
    KS.nameLabel = nameLabel
    nameLabel:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    nameLabel:SetColor(1, 1, 1, 1)
    nameLabel:SetAnchor(TOP, root, TOP, 0, 0)
    nameLabel:SetDimensions(FRAME_WIDTH - 12, 28)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Match ESO's target-frame level presentation instead of drawing CP at the
    -- reticle. Champion players get the stock Champion icon and their effective
    -- CP value on the same top row as the target name.
    local championIcon = wm:CreateControl("KjalnarStacksPlayerChampionIcon", root, CT_TEXTURE)
    KS.championIcon = championIcon
    championIcon:SetTexture("EsoUI/Art/Champion/champion_icon_32.dds")
    championIcon:SetDimensions(20, 20)
    championIcon:SetAnchor(LEFT, root, TOPLEFT, 10, 14)
    championIcon:SetHidden(true)

    local targetLevelLabel = wm:CreateControl("KjalnarStacksPlayerLevel", root, CT_LABEL)
    KS.targetLevelLabel = targetLevelLabel
    targetLevelLabel:SetFont("ZoFontGameShadow")
    targetLevelLabel:SetColor(1, 1, 1, 1)
    targetLevelLabel:SetAnchor(LEFT, championIcon, RIGHT, 3, 0)
    targetLevelLabel:SetDimensions(70, 24)
    targetLevelLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    targetLevelLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    targetLevelLabel:SetHidden(true)

    local detailLabel = wm:CreateControl("KjalnarStacksPlayerDetail", root, CT_LABEL)
    KS.detailLabel = detailLabel
    detailLabel:SetFont("$(BOLD_FONT)|10|soft-shadow-thin")
    detailLabel:SetColor(0.78, 0.82, 0.90, 0.95)
    detailLabel:SetAnchor(TOP, root, TOP, 0, 24)
    detailLabel:SetDimensions(FRAME_WIDTH - 12, 14)
    detailLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local healthBg = wm:CreateControl("KjalnarStacksHealthBG", root, CT_BACKDROP)
    KS.healthBg = healthBg
    healthBg:SetDimensions(HEALTH_BG_WIDTH, HEALTH_BG_HEIGHT)
    healthBg:SetAnchor(TOPLEFT, root, TOPLEFT, 10, 28)
    healthBg:SetCenterColor(0.015, 0.015, 0.02, 0.82)
    healthBg:SetEdgeColor(0.08, 0.08, 0.10, 0.98)
    healthBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 16, 2)
    healthBg:SetInsets(1, 1, -1, -1)

    local healthFill = wm:CreateControl("KjalnarStacksHealthFill", healthBg, CT_BACKDROP)
    KS.healthFill = healthFill
    healthFill:SetDimensions(HEALTH_FILL_WIDTH, HEALTH_BG_HEIGHT - 4)
    healthFill:SetAnchor(LEFT, healthBg, LEFT, 2, 0)
    healthFill:SetCenterColor(0.62, 0.035, 0.055, 0.98)
    healthFill:SetEdgeColor(0, 0, 0, 0)

    local healthText = wm:CreateControl("KjalnarStacksHealthText", root, CT_LABEL)
    KS.healthText = healthText
    healthText:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    healthText:SetColor(1, 1, 1, 0.96)
    healthText:SetAnchor(LEFT, healthBg, LEFT, 12, 0)
    healthText:SetDimensions(190, HEALTH_BG_HEIGHT)
    healthText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    healthText:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local healthPercent = wm:CreateControl("KjalnarStacksHealthPercent", root, CT_LABEL)
    KS.healthPercent = healthPercent
    healthPercent:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    healthPercent:SetColor(1, 1, 1, 0.98)
    healthPercent:SetAnchor(RIGHT, healthBg, RIGHT, -12, 0)
    healthPercent:SetDimensions(78, HEALTH_BG_HEIGHT)
    healthPercent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    healthPercent:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local stackBadge = wm:CreateControl("KjalnarStacksBadge", root, CT_BACKDROP)
    KS.kjBadge = stackBadge
    stackBadge:SetDimensions(STACK_BADGE_SIZE, STACK_BADGE_SIZE)
    stackBadge:SetAnchor(TOPRIGHT, root, TOPRIGHT, -8, 22)
    -- Counter boxes are intentionally invisible. The control remains only as an
    -- anchor/size container so the stack number can stay perfectly centered.
    stackBadge:SetCenterColor(0, 0, 0, 0)
    stackBadge:SetEdgeColor(0, 0, 0, 0)
    stackBadge:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 16, 2)
    stackBadge:SetInsets(2, 2, -2, -2)

    local kjLabel = wm:CreateControl("KjalnarStacksKJLabel", root, CT_LABEL)
    KS.kjLabel = kjLabel
    kjLabel:SetHidden(true)

    local number = wm:CreateControl("KjalnarStacksNumber", root, CT_LABEL)
    KS.numberLabel = number
    number:SetFont("$(BOLD_FONT)|34|soft-shadow-thick")
    number:SetColor(1, 1, 1, 1)
    number:SetAnchorFill(stackBadge)
    number:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    number:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    number:SetText("0")

    KS.pips = {}
    local statusLabel = wm:CreateControl("KjalnarStacksTargetStatus", root, CT_LABEL)
    KS.statusLabel = statusLabel
    statusLabel:SetFont("$(BOLD_FONT)|9|soft-shadow-thin")
    statusLabel:SetAnchor(BOTTOM, root, BOTTOM, 0, 0)
    statusLabel:SetDimensions(FRAME_WIDTH - 10, 12)
    statusLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    statusLabel:SetText("")

    local unlock = wm:CreateControl("KjalnarStacksUnlockHint", root, CT_LABEL)
    KS.unlockHint = unlock
    unlock:SetFont("$(BOLD_FONT)|9|soft-shadow-thin")
    unlock:SetColor(0.45, 0.85, 1.0, 0.95)
    unlock:SetText("DRAG")
    unlock:SetAnchor(TOPRIGHT, root, TOPRIGHT, -5, 1)
    unlock:SetHidden(KS.sv.locked)

    local dragger = wm:CreateControl("KjalnarStacksDragSurface", root, CT_BACKDROP)
    KS.dragger = dragger
    dragger:SetAnchorFill(root)
    dragger:SetDrawLayer(DL_OVERLAY)
    dragger:SetDrawTier(DT_HIGH)
    dragger:SetCenterColor(0, 0, 0, 0)
    dragger:SetEdgeColor(0, 0, 0, 0)
    dragger:SetMouseEnabled(false)

    local function beginMove(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and KS.IsDragEnabled() then
            root:StartMoving()
        end
    end
    local function endMove(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and KS.IsDragEnabled() then
            root:StopMovingOrResizing()
            KS.SavePosition()
        end
    end

    local function wheelResize(_, delta)
        if not KS.IsDragEnabled() then return end
        local step = (IsShiftKeyDown and IsShiftKeyDown()) and 0.01 or 0.05
        KS.SetFrameScale(KS.GetFrameScale() + ((tonumber(delta) or 0) * step), true)
        KS.UpdateEditToolbar()
    end

    dragger:SetHandler("OnMouseDown", beginMove)
    dragger:SetHandler("OnMouseUp", endMove)
    dragger:SetHandler("OnMouseWheel", wheelResize)
    root:SetHandler("OnMouseDown", beginMove)
    root:SetHandler("OnMouseUp", endMove)
    root:SetHandler("OnMouseWheel", wheelResize)
    root:SetHandler("OnMoveStop", function()
        if KS.IsDragEnabled() then KS.SavePosition() end
    end)

    -- Small Azurah-style edit toolbar: always reachable, never covers the frame,
    -- and disappears completely when the frame is locked.
    local toolbar = wm:CreateTopLevelWindow("KjalnarStacksEditToolbar")
    KS.editToolbar = toolbar
    toolbar:SetDimensions(560, 56)
    toolbar:SetAnchor(TOP, GuiRoot, TOP, 0, 70)
    toolbar:SetDrawLayer(DL_OVERLAY)
    toolbar:SetDrawTier(DT_HIGH)
    toolbar:SetMouseEnabled(true)
    toolbar:SetHidden(true)

    local toolbarBg = wm:CreateControl("KjalnarStacksEditToolbarBG", toolbar, CT_BACKDROP)
    toolbarBg:SetAnchorFill(toolbar)
    toolbarBg:SetCenterColor(0.015, 0.02, 0.03, 0.82)
    toolbarBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-SliderBackdrop.dds", 16, 1)
    toolbarBg:SetEdgeColor(0.25, 0.72, 0.95, 0.85)
    toolbarBg:SetInsets(1, 1, -1, -1)

    local hint = wm:CreateControl("KjalnarStacksEditToolbarHint", toolbar, CT_LABEL)
    KS.editToolbarHint = hint
    hint:SetFont("$(MEDIUM_FONT)|13|soft-shadow-thin")
    hint:SetColor(0.82, 0.90, 1.0, 1.0)
    hint:SetAnchor(TOP, toolbar, TOP, 0, 4)
    hint:SetDimensions(548, 18)
    hint:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local function makeToolbarButton(name, text, x, width, callback)
        local button = wm:CreateControl(name, toolbar, CT_BUTTON)
        button:SetDimensions(width, 24)
        button:SetAnchor(BOTTOMLEFT, toolbar, BOTTOMLEFT, x, -5)
        button:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
        button:SetText(text)
        button:SetHandler("OnClicked", callback)
        return button
    end

    makeToolbarButton("KjalnarStacksEditSave", "SAVE & LOCK", 8, 130, function() KS.SaveAndLockEdit() end)
    makeToolbarButton("KjalnarStacksEditCenter", "CENTER", 145, 100, function() KS.CenterHorizontally(true) end)
    makeToolbarButton("KjalnarStacksEditUndo", "UNDO", 252, 100, function() KS.UndoEdit() end)
    makeToolbarButton("KjalnarStacksEditCancel", "CANCEL", 359, 100, function() KS.CancelEdit() end)

    KS.ApplyFontSettings()
    local timerRoot = wm:CreateTopLevelWindow("KjalnarStacksCombatTimers")
    KS.timerRoot = timerRoot
    timerRoot:SetDimensions(560, 82)
    timerRoot:SetScale(KS.GetFrameScale())
    timerRoot:SetDrawLayer(DL_OVERLAY)
    timerRoot:SetDrawTier(DT_HIGH)
    timerRoot:SetMouseEnabled(false)
    timerRoot:SetHidden(true)

    local onslaughtLabel = wm:CreateControl("KjalnarStacksOnslaughtTimer", timerRoot, CT_LABEL)
    KS.onslaughtTimerLabel = onslaughtLabel
    onslaughtLabel:SetColor(1.0, 0.72, 0.22, 1.0)
    onslaughtLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    onslaughtLabel:SetHidden(true)

    local balorghLabel = wm:CreateControl("KjalnarStacksBalorghTimer", timerRoot, CT_LABEL)
    KS.balorghTimerLabel = balorghLabel
    -- Text-only by design: CT_LABEL has no backdrop, so Balorgh remains fully transparent.
    balorghLabel:SetColor(0.76, 0.66, 1.0, 1.0)
    balorghLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    balorghLabel:SetHidden(true)

    local tarnishedLabel = wm:CreateControl("KjalnarStacksTarnishedTimer", timerRoot, CT_LABEL)
    KS.tarnishedTimerLabel = tarnishedLabel
    tarnishedLabel:SetColor(0.35, 0.88, 1.0, 1.0)
    tarnishedLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    tarnishedLabel:SetHidden(true)

    local nullArcaLabel = wm:CreateControl("KjalnarStacksNullArcaTimer", timerRoot, CT_LABEL)
    KS.nullArcaTimerLabel = nullArcaLabel
    nullArcaLabel:SetColor(0.88, 0.90, 1.0, 1.0)
    nullArcaLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nullArcaLabel:SetHidden(true)

    local dragonAppetiteLabel = wm:CreateControl("KjalnarStacksDragonAppetiteTimer", timerRoot, CT_LABEL)
    KS.dragonAppetiteTimerLabel = dragonAppetiteLabel
    dragonAppetiteLabel:SetColor(1.0, 0.56, 0.30, 1.0)
    dragonAppetiteLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    dragonAppetiteLabel:SetHidden(true)

    local wretchedRoot = wm:CreateTopLevelWindow("UltiviteWretchedVitalityTimers")
    KS.wretchedVitalityRoot = wretchedRoot
    wretchedRoot:SetDimensions(118, 54)
    wretchedRoot:SetAnchor(CENTER, GuiRoot, CENTER, defaults.wretchedVitalityX, defaults.wretchedVitalityY)
    wretchedRoot:SetDrawLayer(DL_OVERLAY)
    wretchedRoot:SetDrawTier(DT_HIGH)
    wretchedRoot:SetDrawLevel(1455)
    wretchedRoot:SetMouseEnabled(false)
    wretchedRoot:SetHidden(true)

    KS.wretchedVitalitySlots = {}
    for index = 1, 2 do
        local slot = wm:CreateControl("UltiviteWretchedVitalitySlot" .. tostring(index), wretchedRoot, CT_CONTROL)
        slot:SetDimensions(defaults.wretchedVitalityIconSize, defaults.wretchedVitalityIconSize)
        slot:SetHidden(true)
        slot:SetMouseEnabled(false)

        local icon = wm:CreateControl("UltiviteWretchedVitalityIcon" .. tostring(index), slot, CT_TEXTURE)
        icon:SetAnchorFill(slot)
        icon:SetTextureCoords(0.04, 0.96, 0.04, 0.96)
        icon:SetMouseEnabled(false)

        local countdown = wm:CreateControl("UltiviteWretchedVitalityCountdown" .. tostring(index), slot, CT_LABEL)
        countdown:SetAnchorFill(slot)
        countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        countdown:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        countdown:SetFont("$(BOLD_FONT)|25|soft-shadow-thick")
        countdown:SetColor(1, 1, 1, 1)
        countdown:SetText("15")
        countdown:SetMouseEnabled(false)

        KS.wretchedVitalitySlots[index] = {
            control = slot,
            icon = icon,
            countdown = countdown,
        }
    end
    KS.ApplyWretchedVitalityLayout()

    local ccRoot = wm:CreateTopLevelWindow("UltiviteCcImmunityTracker")
    KS.ccImmunityRoot = ccRoot
    ccRoot:SetDimensions(defaults.playerAuraIconSize, defaults.playerAuraIconSize)
    ccRoot:SetAnchor(CENTER, GuiRoot, CENTER, defaults.ccImmunityX, defaults.ccImmunityY)
    ccRoot:SetDrawLayer(DL_OVERLAY)
    ccRoot:SetDrawTier(DT_HIGH)
    ccRoot:SetDrawLevel(1458)
    ccRoot:SetMouseEnabled(KS.ccImmunityDragUnlocked == true)
    ccRoot:SetMovable(true)
    ccRoot:SetClampedToScreen(true)
    ccRoot:SetHidden(true)
    local function saveCcImmunityDraggedPosition(control)
        if KS.ccImmunityDragUnlocked ~= true then return false end
        if not (control and control.GetCenter and GuiRoot and GuiRoot.GetCenter and KS.sv) then return false end
        local x, y = control:GetCenter()
        local gx, gy = GuiRoot:GetCenter()
        if not (x and y and gx and gy) then return false end

        local nextX = clamp(math.floor((x - gx) + 0.5), -800, 800)
        local nextY = clamp(math.floor((y - gy) + 0.5), -520, 420)
        local changed = tonumber(KS.sv.ccImmunityX) ~= nextX or tonumber(KS.sv.ccImmunityY) ~= nextY
        KS.sv.ccImmunityX = nextX
        KS.sv.ccImmunityY = nextY
        KS.ApplyPlayerAuraHudLayout()
        if changed and Ultivite and U.RequestSettingsSave then U.RequestSettingsSave(true) end
        return changed
    end

    ccRoot:SetHandler("OnMouseDown", function(control, button)
        if KS.ccImmunityDragUnlocked ~= true then return end
        if MOUSE_BUTTON_INDEX_LEFT ~= nil and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if control.StartMoving then control:StartMoving() end
    end)
    ccRoot:SetHandler("OnMouseUp", function(control, button)
        if KS.ccImmunityDragUnlocked ~= true then return end
        if MOUSE_BUTTON_INDEX_LEFT ~= nil and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if control.StopMovingOrResizing then control:StopMovingOrResizing() end
        saveCcImmunityDraggedPosition(control)
    end)
    ccRoot:SetHandler("OnMoveStop", function(control)
        saveCcImmunityDraggedPosition(control)
    end)

    local ccIcon = wm:CreateControl("UltiviteCcImmunityIcon", ccRoot, CT_TEXTURE)
    KS.ccImmunityIcon = ccIcon
    ccIcon:SetAnchorFill(ccRoot)
    ccIcon:SetTextureCoords(0.04, 0.96, 0.04, 0.96)
    ccIcon:SetMouseEnabled(false)

    local ccCountdown = wm:CreateControl("UltiviteCcImmunityCountdown", ccRoot, CT_LABEL)
    KS.ccImmunityCountdown = ccCountdown
    ccCountdown:SetAnchorFill(ccRoot)
    ccCountdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ccCountdown:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    ccCountdown:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    ccCountdown:SetColor(1, 1, 1, 1)
    ccCountdown:SetText("6")
    ccCountdown:SetMouseEnabled(false)

    local debuffRoot = wm:CreateTopLevelWindow("UltivitePlayerDebuffTracker")
    KS.playerDebuffRoot = debuffRoot
    debuffRoot:SetDimensions(642, defaults.playerAuraIconSize)
    debuffRoot:SetAnchor(CENTER, GuiRoot, CENTER, defaults.playerDebuffX, defaults.playerDebuffY)
    debuffRoot:SetDrawLayer(DL_OVERLAY)
    debuffRoot:SetDrawTier(DT_HIGH)
    debuffRoot:SetDrawLevel(1457)
    debuffRoot:SetMouseEnabled(false)
    debuffRoot:SetHidden(true)

    KS.playerDebuffSlots = {}
    for index = 1, 12 do
        local slot = wm:CreateControl("UltivitePlayerDebuffSlot" .. tostring(index), debuffRoot, CT_CONTROL)
        slot:SetDimensions(defaults.playerAuraIconSize, defaults.playerAuraIconSize)
        slot:SetHidden(true)
        slot:SetMouseEnabled(false)

        local icon = wm:CreateControl("UltivitePlayerDebuffIcon" .. tostring(index), slot, CT_TEXTURE)
        icon:SetAnchorFill(slot)
        icon:SetTextureCoords(0.04, 0.96, 0.04, 0.96)
        icon:SetMouseEnabled(false)

        local countdown = wm:CreateControl("UltivitePlayerDebuffCountdown" .. tostring(index), slot, CT_LABEL)
        countdown:SetAnchorFill(slot)
        countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        countdown:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
        countdown:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
        countdown:SetColor(1, 1, 1, 1)
        countdown:SetText("5")
        countdown:SetMouseEnabled(false)

        KS.playerDebuffSlots[index] = {
            control = slot,
            icon = icon,
            countdown = countdown,
        }
    end

    KS.ApplyPlayerAuraHudLayout()

    -- Lightweight combat helpers. These are independent of all existing dedicated
    -- set/skill trackers and use public read-only API data only.
    KS.CreateSkillStackTrackers()
    KS.CreateResourceDangerHud()
    KS.CreateCombatDangerWarnings()
    KS.CreateImportantTargetDebuffHud()

    -- Four text-only live stat HUD numbers. Their grab surfaces are enabled only
    -- by Quick Menu preview so they cannot intercept normal UI mouse input.
    KS.CreateLiveStatWidgets()

    local majorResolveWarningRoot = wm:CreateTopLevelWindow("KjalnarStacksMajorResolveWarning")
    KS.majorResolveWarningRoot = majorResolveWarningRoot
    majorResolveWarningRoot:SetDimensions(520, 38)
    majorResolveWarningRoot:SetAnchor(CENTER, GuiRoot, CENTER, tonumber(KS.sv.majorResolveWarningX) or defaults.majorResolveWarningX, tonumber(KS.sv.majorResolveWarningY) or defaults.majorResolveWarningY)
    majorResolveWarningRoot:SetDrawLayer(DL_OVERLAY)
    majorResolveWarningRoot:SetDrawTier(DT_HIGH)
    majorResolveWarningRoot:SetMouseEnabled(false)
    majorResolveWarningRoot:SetHidden(true)

    local majorResolveWarningLabel = wm:CreateControl("KjalnarStacksMajorResolveWarningLabel", majorResolveWarningRoot, CT_LABEL)
    KS.majorResolveWarningLabel = majorResolveWarningLabel
    majorResolveWarningLabel:SetAnchorFill(majorResolveWarningRoot)
    majorResolveWarningLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    majorResolveWarningLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    majorResolveWarningLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", clamp(math.floor(tonumber(KS.sv.majorResolveWarningFontSize) or defaults.majorResolveWarningFontSize), 16, 46)))
    majorResolveWarningLabel:SetColor(1.0, 0.20, 0.14, 1.0)
    majorResolveWarningLabel:SetText("NO MAJOR RESOLVE")

    local foodWarningRoot = wm:CreateTopLevelWindow("KjalnarStacksFoodWarning")
    KS.foodWarningRoot = foodWarningRoot
    foodWarningRoot:SetDimensions(520, 42)
    foodWarningRoot:SetAnchor(CENTER, GuiRoot, CENTER, tonumber(KS.sv.foodWarningX) or defaults.foodWarningX, tonumber(KS.sv.foodWarningY) or defaults.foodWarningY)
    foodWarningRoot:SetDrawLayer(DL_OVERLAY)
    foodWarningRoot:SetDrawTier(DT_HIGH)
    foodWarningRoot:SetMouseEnabled(false)
    foodWarningRoot:SetHidden(true)

    local foodWarningLabel = wm:CreateControl("KjalnarStacksFoodWarningLabel", foodWarningRoot, CT_LABEL)
    KS.foodWarningLabel = foodWarningLabel
    foodWarningLabel:SetAnchorFill(foodWarningRoot)
    foodWarningLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    foodWarningLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    foodWarningLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", clamp(math.floor(tonumber(KS.sv.foodWarningFontSize) or defaults.foodWarningFontSize), 16, 50)))
    foodWarningLabel:SetColor(1.0, 0.18, 0.12, 1.0)
    foodWarningLabel:SetText("NO FOOD BUFF")

    local killMessageRoot = wm:CreateTopLevelWindow("KjalnarStacksKillMessage")
    KS.killMessageRoot = killMessageRoot
    killMessageRoot:SetDimensions(560, 46)
    killMessageRoot:SetScale(1)
    killMessageRoot:SetDrawLayer(DL_OVERLAY)
    killMessageRoot:SetDrawTier(DT_HIGH)
    killMessageRoot:SetMouseEnabled(false)
    killMessageRoot:SetHidden(true)

    local killMessageLabel = wm:CreateControl("KjalnarStacksKillMessageLabel", killMessageRoot, CT_LABEL)
    KS.killMessageLabel = killMessageLabel
    killMessageLabel:SetAnchorFill(killMessageRoot)
    killMessageLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    killMessageLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    killMessageLabel:SetColor(1.0, 0.42, 0.30, 1.0)
    killMessageLabel:SetText("")

    local pvpHudRoot = wm:CreateTopLevelWindow("KjalnarStacksPvpKD")
    KS.pvpHudRoot = pvpHudRoot
    pvpHudRoot:SetDimensions(420, 34)
    pvpHudRoot:SetDrawLayer(DL_OVERLAY)
    pvpHudRoot:SetDrawTier(DT_HIGH)
    pvpHudRoot:SetClampedToScreen(true)
    pvpHudRoot:SetMovable(false)
    pvpHudRoot:SetMouseEnabled(false)
    pvpHudRoot:SetHidden(true)

    local pvpHudLabel = wm:CreateControl("KjalnarStacksPvpKDLabel", pvpHudRoot, CT_LABEL)
    KS.pvpHudLabel = pvpHudLabel
    pvpHudLabel:SetAnchorFill(pvpHudRoot)
    pvpHudLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    pvpHudLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    pvpHudLabel:SetColor(1, 1, 1, 1)
    pvpHudLabel:SetText("Kills: 0  Deaths: 0")
    pvpHudLabel:SetMouseEnabled(false)

    -- Dedicated transparent drag surface. This mirrors the working mover used
    -- by the main target frame and avoids relying on the label/root to receive
    -- mouse input consistently after closing the settings panel.
    local pvpHudDragger = wm:CreateControl("KjalnarStacksPvpKDDragger", pvpHudRoot, CT_BACKDROP)
    KS.pvpHudDragger = pvpHudDragger
    pvpHudDragger:SetAnchorFill(pvpHudRoot)
    pvpHudDragger:SetDrawLayer(DL_OVERLAY)
    pvpHudDragger:SetDrawTier(DT_HIGH)
    pvpHudDragger:SetCenterColor(0, 0, 0, 0)
    pvpHudDragger:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    pvpHudDragger:SetEdgeColor(0, 0, 0, 0)
    pvpHudDragger:SetMouseEnabled(false)

    local function beginPvpHudMove(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            pvpHudRoot:StartMoving()
        end
    end

    local function endPvpHudMove(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            pvpHudRoot:StopMovingOrResizing()
            KS.SavePvpHudPosition()
        end
    end

    local function showPvpHudGrabHighlight()
        pvpHudDragger:SetCenterColor(0.02, 0.03, 0.04, 0.16)
        pvpHudDragger:SetEdgeColor(0.78, 0.90, 1.00, 0.78)
    end

    local function hidePvpHudGrabHighlight()
        pvpHudDragger:SetCenterColor(0, 0, 0, 0)
        pvpHudDragger:SetEdgeColor(0, 0, 0, 0)
    end

    pvpHudDragger:SetHandler("OnMouseDown", beginPvpHudMove)
    pvpHudDragger:SetHandler("OnMouseUp", endPvpHudMove)
    pvpHudDragger:SetHandler("OnMouseEnter", showPvpHudGrabHighlight)
    pvpHudDragger:SetHandler("OnMouseExit", hidePvpHudGrabHighlight)
    pvpHudRoot:SetHandler("OnMouseDown", beginPvpHudMove)
    pvpHudRoot:SetHandler("OnMouseUp", endPvpHudMove)
    pvpHudRoot:SetHandler("OnMoveStop", function()
        KS.SavePvpHudPosition()
    end)

    KS.ApplyPvpHudPosition()
    KS.ApplyPvpHudAppearance()
    KS.ApplyTimerAnchor()
    KS.ApplyKillMessageAnchor()
    KS.ApplyFontSettings()
    KS.UpdateCombatTimers()
    KS.UpdateKillMessage()
    KS.UpdatePvpHud()

    KS.UpdateDragState()
    KS.RefreshDisplay()
end

function KS.SavePosition()
    if not KS.root or not KS.sv then return end
    local frameX, frameY = KS.root:GetCenter()
    local rootX, rootY = GuiRoot:GetCenter()
    if not frameX or not frameY or not rootX or not rootY then return end

    local x = math.floor((frameX - rootX) + 0.5)
    local y = math.floor((frameY - rootY) + 0.5)
    local bypassSnap = IsShiftKeyDown and IsShiftKeyDown()
    if KS.sv.snapToGrid ~= false and not bypassSnap then
        x = KS.SnapCoordinate(x)
        y = KS.SnapCoordinate(y)
    end
    KS.sv.x = x
    KS.sv.y = y
    KS.ApplyPosition()
end

function KS.SetLocked(locked, silent)
    locked = locked and true or false
    if not locked and not KS.editSnapshot then KS.CaptureEditSnapshot() end

    KS.sv.locked = locked
    KS.forceVisible = not locked
    if locked then KS.editSnapshot = nil end
    KS.ApplyPosition()
    KS.ApplyTimerAnchor()
    KS.UpdateDragState()
    KS.RefreshDisplay()
    KS.UpdateCombatTimers()
    if not silent then
        chat(locked and "Frame locked." or "Edit mode ON. Drag the frame, use the mouse wheel to resize, then choose SAVE & LOCK.")
    end
end

function KS.SetScale(scale, silent)
    -- Backward compatible alias for older slash commands.
    KS.SetFrameScale(scale, silent)
end

function KS.SetStacks(stacks, abilityId, effectName, source, expiresAt)
    stacks = tonumber(stacks) or 0
    stacks = clamp(math.floor(stacks + 0.5), 0, 5)

    local oldStacks = tonumber(KS.currentStacks) or 0
    local oldAbilityId = tonumber(KS.currentAbilityId) or 0
    local oldEffectName = KS.currentEffectName or ""

    KS.currentStacks = stacks
    if abilityId and abilityId > 0 then KS.currentAbilityId = abilityId end
    if effectName and effectName ~= "" then KS.currentEffectName = effectName end
    if expiresAt ~= nil then KS.currentExpiresAt = tonumber(expiresAt) or 0 end

    local cacheName = KS.selectedTarget ~= "" and KS.selectedTarget or KS.currentTarget
    if cacheName ~= "" then
        KS.CacheTargetState(cacheName, stacks, KS.currentExpiresAt, abilityId, effectName)
    end
    if KS.debug and source then
        local now = GetGameTimeMilliseconds()
        if now - KS.lastDebugAt > 100 then
            KS.lastDebugAt = now
            chat(string.format("%s: %d/5 | id=%s | %s", source, stacks, tostring(abilityId or 0), tostring(effectName or "")))
        end
    end

    -- Aura polls often report the same state every 250 ms. Do not rebuild the
    -- target frame unless something visible actually changed.
    if oldStacks ~= KS.currentStacks or oldAbilityId ~= (tonumber(KS.currentAbilityId) or 0) or oldEffectName ~= (KS.currentEffectName or "") then
        KS.RefreshDisplay(true)
    end
end

function KS.RefreshTargetInfo()
    if KS.IsSelectedTargetDeadUnderReticle() then
        KS.ClearTarget()
        return
    end

    local liveTarget = KS.GetTargetName()
    KS.liveSelectedTarget = false

    if liveTarget ~= "" then
        KS.SetSelectedTarget(liveTarget)
        KS.liveSelectedTarget = liveTarget == KS.selectedTarget
    elseif KS.CanRetainOffReticle() then
        KS.currentTarget = KS.selectedTarget or ""
    else
        KS.ClearTarget()
        return
    end

    local isDecoy, decoyName = KS.IsDecoyUnderReticle()
    KS.lastDecoyName = isDecoy and decoyName or ""
end

function KS.ApplyLiveTargetHealth(health, healthMax, expectedUnitTag)
    if KS.currentTarget == "" then return end
    if expectedUnitTag and expectedUnitTag ~= KS.unitTag then return end
    if DoesUnitExist and not DoesUnitExist(KS.unitTag) then return end

    local liveName = cleanName(GetUnitName(KS.unitTag))
    if liveName == "" or liveName ~= KS.currentTarget then return end

    health = tonumber(health) or 0
    healthMax = tonumber(healthMax) or 0

    local info = KS.targetInfoCache[KS.currentTarget]
    if not info then
        info = {
            name = KS.currentTarget,
            isPlayer = IsUnitPlayer and IsUnitPlayer(KS.unitTag) or false,
            displayName = "",
            className = "",
            classId = 0,
            championPoints = 0,
            level = 0,
            health = health,
            healthMax = healthMax,
            updatedAt = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0,
        }
        KS.targetInfoCache[KS.currentTarget] = info
    else
        if info.health == health and info.healthMax == healthMax then return end
        info.health = health
        info.healthMax = healthMax
        info.updatedAt = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    end

    local healthPct = healthMax > 0 and clamp(health / healthMax, 0, 1) or 0
    local width = math.max(1, math.floor(HEALTH_FILL_WIDTH * healthPct + 0.5))
    local text = healthMax > 0 and formatInt(health) or "HEALTH UNKNOWN"
    local pct = healthMax > 0 and string.format("%d%%", math.floor(healthPct * 100 + 0.5)) or ""
    if KS.healthFill and KS.lastHealthWidth ~= width then KS.lastHealthWidth = width; KS.healthFill:SetWidth(width) end
    if KS.healthText and KS.lastHealthText ~= text then KS.lastHealthText = text; KS.healthText:SetText(text) end
    if KS.healthPercent and KS.lastHealthPercentText ~= pct then KS.lastHealthPercentText = pct; KS.healthPercent:SetText(pct) end
end

function KS.UpdateLiveHealth()
    if KS.currentTarget == "" then return end
    if DoesUnitExist and not DoesUnitExist(KS.unitTag) then return end
    if not GetUnitPower then return end

    local health, healthMax = GetUnitPower(KS.unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    KS.ApplyLiveTargetHealth(health, healthMax, KS.unitTag)
end

function KS.OnTargetPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= KS.unitTag then return end
    if powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH then return end
    KS.diagCounters = KS.diagCounters or { reticle = 0, power = 0, worldSuccess = 0, worldFail = 0 }
    KS.diagCounters.power = (tonumber(KS.diagCounters.power) or 0) + 1
    KS.ApplyLiveTargetHealth(powerValue, powerMax, unitTag)
end

function KS.RefreshNativeKjalnarBadge(preview, hasTarget)
    if not KS.root then return end

    local showKjalnar = KS.sv.showKjalnarTracker ~= false and KS.kjalnarEquipped == true and (preview or KS.IsPlayerInCombat())
    local visible = preview or (KS.IsHUDAllowed() and hasTarget and showKjalnar)
    KS.lastRootVisible = visible
    KS.ApplyRootVisibility()
    KS.UpdateDragState()
    if not visible then return end

    -- The health/name portion is rendered by ESO's native in-world nameplate.
    -- Keep only the Kjalnar number as a compact movable HUD badge because the
    -- public Lua API exposes no control handle for an engine nameplate.
    if KS.nameLabel then KS.nameLabel:SetHidden(true) end
    if KS.championIcon then KS.championIcon:SetHidden(true) end
    if KS.targetLevelLabel then KS.targetLevelLabel:SetHidden(true) end
    if KS.detailLabel then KS.detailLabel:SetHidden(true) end
    if KS.healthBg then KS.healthBg:SetHidden(true) end
    if KS.healthText then KS.healthText:SetHidden(true) end
    if KS.healthPercent then KS.healthPercent:SetHidden(true) end
    if KS.statusLabel then KS.statusLabel:SetHidden(true) end
    if KS.outline then KS.outline:SetEdgeColor(0.25, 0.72, 0.95, preview and 0.90 or 0) end

    KS.root:SetDimensions(92, 92)
    if KS.kjBadge then
        KS.kjBadge:SetHidden(false)
        KS.kjBadge:SetDimensions(80, 80)
        KS.kjBadge:ClearAnchors()
        KS.kjBadge:SetAnchor(CENTER, KS.root, CENTER, 0, 0)
        KS.kjBadge:SetCenterColor(0, 0, 0, 0)
        KS.kjBadge:SetEdgeColor(0, 0, 0, 0)
    end
    if KS.numberLabel then KS.numberLabel:SetHidden(false) end

    local s = preview and 5 or clamp(tonumber(KS.currentStacks) or 0, 0, 5)
    local kjKey = "native:" .. tostring(s)
    if KS.lastKjalnarRenderKey ~= kjKey then
        KS.lastKjalnarRenderKey = kjKey
        KS.numberLabel:SetText(tostring(s))
        if s >= 5 then
            KS.numberLabel:SetColor(1.0, 0.34, 0.18, 1)
            KS.kjBadge:SetEdgeColor(0, 0, 0, 0)
        elseif s >= 3 then
            KS.numberLabel:SetColor(1.0, 0.82, 0.26, 1)
            KS.kjBadge:SetEdgeColor(0, 0, 0, 0)
        elseif s > 0 then
            KS.numberLabel:SetColor(0.58, 0.90, 1.0, 1)
            KS.kjBadge:SetEdgeColor(0, 0, 0, 0)
        else
            KS.numberLabel:SetColor(0.72, 0.74, 0.80, 0.95)
            KS.kjBadge:SetEdgeColor(0, 0, 0, 0)
        end
    end
end

function KS.RefreshDisplay(skipTargetSync)
    if not KS.root then return end

    if not skipTargetSync then
        if KS.IsSelectedTargetDeadUnderReticle() then
            KS.ClearTarget()
            return
        end

        local liveTarget = KS.GetTargetName()
        KS.liveSelectedTarget = false
        if liveTarget ~= "" then
            KS.SetSelectedTarget(liveTarget)
            KS.liveSelectedTarget = liveTarget == KS.selectedTarget
        elseif KS.CanRetainOffReticle() then
            KS.currentTarget = KS.selectedTarget or ""
        else
            KS.selectedTarget = ""
            KS.currentTarget = ""
            KS.currentStacks = 0
            KS.currentExpiresAt = 0
        end

        local isDecoy, decoyName = KS.IsDecoyUnderReticle()
        KS.lastDecoyName = isDecoy and decoyName or ""
    end

    local isDecoy = KS.lastDecoyName ~= ""
    local decoyName = KS.lastDecoyName or ""

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    if KS.currentStacks > 0 and KS.currentExpiresAt and KS.currentExpiresAt > 0 and now >= KS.currentExpiresAt then
        KS.currentStacks = 0
        KS.currentExpiresAt = 0
        if KS.selectedTarget ~= "" then
            KS.CacheTargetState(KS.selectedTarget, 0, 0, KS.currentAbilityId, KS.currentEffectName)
        end
    end

    local hasTarget = KS.currentTarget ~= ""
    local preview = KS.IsPositionPreviewActive()
    local livePlayerPresentation = KS.GetLiveReticlePlayerPresentationInfo()
    local hasPresentationTarget = hasTarget or livePlayerPresentation ~= nil

    if KS.IsNativeOverheadMode() then
        KS.RefreshNativeKjalnarBadge(preview, hasTarget)
        return
    end

    -- Restore controls that native compact mode may have hidden before drawing the
    -- legacy screen-space custom frame.
    local showTargetHealthBar = preview or KS.IsPlayerInCombat()
    if KS.nameLabel then KS.nameLabel:SetHidden(false) end
    if KS.healthBg then KS.healthBg:SetHidden(not showTargetHealthBar) end
    if KS.healthText then KS.healthText:SetHidden(not showTargetHealthBar) end
    if KS.healthPercent then KS.healthPercent:SetHidden(not showTargetHealthBar) end
    if KS.statusLabel then KS.statusLabel:SetHidden(false) end
    if KS.kjBadge then
        KS.kjBadge:SetDimensions(STACK_BADGE_SIZE, STACK_BADGE_SIZE)
        KS.kjBadge:SetCenterColor(0, 0, 0, 0)
        KS.kjBadge:SetEdgeColor(0, 0, 0, 0)
    end
    KS.root:SetWidth(FRAME_WIDTH)

    local visible = preview or (KS.IsHUDAllowed() and (KS.forceVisible or (KS.sv.targetFrame and hasPresentationTarget)))
    KS.lastRootVisible = visible
    KS.ApplyRootVisibility()
    KS.UpdateDragState()
    if not visible then return end

    -- For player presentation, reticleoverplayer is authoritative. This mirrors
    -- established target-frame addons and avoids showing a pet/summon from the
    -- generic reticleover tag while the dedicated player tag contains the actual
    -- highlighted player and their CP.
    local info = livePlayerPresentation or KS.targetInfoCache[KS.currentTarget] or {}
    local rawName = livePlayerPresentation and livePlayerPresentation.name
        or (KS.currentTarget ~= "" and KS.currentTarget or (preview and "TARGET FRAME PREVIEW" or "NO TARGET"))
    local name = KS.GetDisplayedTargetName(info, rawName)
    local championPoints = tonumber(info.championPoints) or 0
    local level = tonumber(info.level) or 0

    -- Custom target mode: player CP/level lives in the same label as the Ultivite-rendered
    -- player name. This makes progression inseparable from the already proven
    -- target-name rendering path instead of relying on a separately anchored icon
    -- or reticle label. Character/@Account name selection is preserved.
    local nameText = name
    if info.isPlayer == true then
        if championPoints > 0 then
            nameText = string.format("%s   CP %d", name, championPoints)
        elseif level > 0 then
            nameText = string.format("%s   Lv %d", name, level)
        end
    end
    if KS.lastNameText ~= nameText then
        KS.lastNameText = nameText
        KS.nameLabel:SetText(nameText)
    end

    -- The old separate Champion icon/number controls are retained for SavedUI
    -- compatibility but are deliberately hidden. The name label is now the one
    -- authoritative player-progression presentation in the Ultivite target frame.
    if KS.championIcon then KS.championIcon:SetHidden(true) end
    if KS.targetLevelLabel then
        KS.targetLevelLabel:SetText("")
        KS.targetLevelLabel:SetHidden(true)
    end

    if livePlayerPresentation and info.isPlayer == true then
        KS.worldCpDiag = KS.worldCpDiag or {}
        KS.worldCpDiag.lastTargetNameRender = {
            atMs = WorldCpDiagNowMs(),
            tag = tostring(livePlayerPresentation.unitTag or ""),
            cp = championPoints,
            level = level,
            text = tostring(nameText or ""),
            visible = KS.nameLabel and not KS.nameLabel:IsHidden(),
            targetFrameMode = tostring(KS.sv and KS.sv.targetFrameMode or "ultivite"),
        }
    end

    local detailText = (preview and not hasPresentationTarget) and "EDIT MODE • drag to move • mouse wheel to resize" or ""
    local hasDetails = detailText ~= ""
    if KS.lastDetailText ~= detailText then
        KS.lastDetailText = detailText
        KS.detailLabel:SetText(detailText)
        KS.detailLabel:SetHidden(not hasDetails)
    end

    local healthY = hasDetails and 40 or 28
    if KS.lastHealthY ~= healthY then
        KS.lastHealthY = healthY
        KS.healthBg:ClearAnchors()
        KS.healthBg:SetAnchor(TOPLEFT, KS.root, TOPLEFT, 10, healthY)
    end

    local health = tonumber(info.health) or 0
    local healthMax = tonumber(info.healthMax) or 0
    local healthPct = healthMax > 0 and clamp(health / healthMax, 0, 1) or 0
    local healthWidth, healthText, percentText
    if preview and not hasPresentationTarget then
        healthWidth = HEALTH_FILL_WIDTH
        healthText = "DRAG TO POSITION"
        percentText = ""
    else
        healthWidth = math.max(1, math.floor(HEALTH_FILL_WIDTH * healthPct + 0.5))
        healthText = healthMax > 0 and formatInt(health) or "HEALTH UNKNOWN"
        percentText = healthMax > 0 and string.format("%d%%", math.floor(healthPct * 100 + 0.5)) or ""
    end
    if KS.lastHealthWidth ~= healthWidth then KS.lastHealthWidth = healthWidth; KS.healthFill:SetWidth(healthWidth) end
    if KS.lastHealthText ~= healthText then KS.lastHealthText = healthText; KS.healthText:SetText(healthText) end
    if KS.healthPercent and KS.lastHealthPercentText ~= percentText then KS.lastHealthPercentText = percentText; KS.healthPercent:SetText(percentText) end

    local alphaMode = preview and "preview" or ((livePlayerPresentation or KS.liveSelectedTarget) and "live" or "retained")
    if KS.lastDisplayAlphaMode ~= alphaMode then
        KS.lastDisplayAlphaMode = alphaMode
        if alphaMode == "preview" or alphaMode == "live" then
            KS.nameLabel:SetAlpha(1)
            KS.detailLabel:SetAlpha(alphaMode == "preview" and 0.95 or 0.95)
            KS.healthBg:SetAlpha(1)
            KS.healthText:SetAlpha(0.96)
            if KS.healthPercent then KS.healthPercent:SetAlpha(0.96) end
        else
            KS.nameLabel:SetAlpha(0.88)
            KS.detailLabel:SetAlpha(0.72)
            KS.healthBg:SetAlpha(0.58)
            KS.healthText:SetAlpha(0.72)
            if KS.healthPercent then KS.healthPercent:SetAlpha(0.72) end
        end
    end

    local presentationMatchesSelected = not livePlayerPresentation
        or cleanName(livePlayerPresentation.name or "") == cleanName(KS.currentTarget or "")
    local showKjalnar = KS.sv.showKjalnarTracker ~= false and KS.kjalnarEquipped == true
        and (preview or KS.IsPlayerInCombat()) and presentationMatchesSelected
    if KS.lastShowKjalnar ~= showKjalnar then
        KS.lastShowKjalnar = showKjalnar
        if KS.kjLabel then KS.kjLabel:SetHidden(true) end
        if KS.kjBadge then KS.kjBadge:SetHidden(not showKjalnar) end
        if KS.numberLabel then KS.numberLabel:SetHidden(not showKjalnar) end
    end

    local layoutKey = tostring(healthY) .. ":" .. tostring(showKjalnar)
    if KS.lastTargetLayoutKey ~= layoutKey then
        KS.lastTargetLayoutKey = layoutKey
        if KS.kjBadge then
            KS.kjBadge:ClearAnchors()
            KS.kjBadge:SetAnchor(TOPRIGHT, KS.root, TOPRIGHT, -8, healthY - 6)
        end
    end

    -- A dedicated reticleoverplayer presentation wins over a generic reticle
    -- decoy such as a pet or summon. Do not show "DECOY IGNORED" beneath the
    -- actual player target in that case.
    local displayIsDecoy = isDecoy and livePlayerPresentation == nil
    local hasStatus = displayIsDecoy or preview
    local contentBottom = showTargetHealthBar and (healthY + HEALTH_BG_HEIGHT) or 28
    if showKjalnar then
        contentBottom = math.max(contentBottom, healthY - 6 + STACK_BADGE_SIZE)
    end
    local rootHeight = contentBottom + (hasStatus and 14 or 4)
    if KS.lastRootHeight ~= rootHeight then KS.lastRootHeight = rootHeight; KS.root:SetHeight(rootHeight) end

    if showKjalnar then
        local s = clamp(tonumber(KS.currentStacks) or 0, 0, 5)
        local kjKey = tostring(s)
        if KS.lastKjalnarRenderKey ~= kjKey then
            KS.lastKjalnarRenderKey = kjKey
            KS.numberLabel:SetText(tostring(s))
            if s >= 5 then
                KS.numberLabel:SetColor(1.0, 0.34, 0.18, 1)
                if KS.kjBadge then KS.kjBadge:SetEdgeColor(0, 0, 0, 0) end
            elseif s >= 3 then
                KS.numberLabel:SetColor(1.0, 0.82, 0.26, 1)
                if KS.kjBadge then KS.kjBadge:SetEdgeColor(0, 0, 0, 0) end
            elseif s > 0 then
                KS.numberLabel:SetColor(0.58, 0.90, 1.0, 1)
                if KS.kjBadge then KS.kjBadge:SetEdgeColor(0, 0, 0, 0) end
            else
                KS.numberLabel:SetColor(0.72, 0.74, 0.80, 0.95)
                if KS.kjBadge then KS.kjBadge:SetEdgeColor(0, 0, 0, 0) end
            end
        end
    end

    local statusText = displayIsDecoy and ("DECOY IGNORED: " .. decoyName) or (preview and "POSITIONING MODE" or "")
    if KS.lastStatusText ~= statusText then
        KS.lastStatusText = statusText
        if displayIsDecoy then KS.statusLabel:SetColor(1.0, 0.72, 0.22, 0.98)
        elseif preview then KS.statusLabel:SetColor(0.45, 0.85, 1.0, 0.98) end
        KS.statusLabel:SetText(statusText)
    end
end

function KS.StopLearning(silent)
    KS.learning = false
    KS.forceVisible = not KS.sv.locked
    KS.RefreshDisplay()
    if not silent then
        chat("Learn mode OFF. The learned Kjalnar effect is still saved.")
    end
end

function KS.RememberAbility(abilityId, effectName, why)
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 then return false end
    KS.sv.abilityId = abilityId
    KS.sv.learnedName = effectName or ""
    KS.currentAbilityId = abilityId
    KS.currentEffectName = effectName or ""
    KS.learning = false
    KS.forceVisible = not KS.sv.locked
    chat(string.format("Tracking learned: %s (abilityId %d)%s. Learn mode is now OFF.", effectName or "Kjalnar stack", abilityId, why and (" - " .. why) or ""))
    KS.RefreshDisplay()
    return true
end

function KS.IsTrackedEffect(name, abilityId, stackCount, duration)
    abilityId = tonumber(abilityId) or 0
    if KS.sv.abilityId and KS.sv.abilityId > 0 and abilityId == KS.sv.abilityId then
        return true
    end
    if looksLikeKjalnarName(name) and isValidStackCount(stackCount) then
        if abilityId > 0 then KS.RememberAbility(abilityId, name, "matched Kjalnar effect name") end
        return true
    end
    if KS.learning and isValidStackCount(stackCount) then
        duration = tonumber(duration) or 0
        if duration == 0 or (duration >= 3.5 and duration <= 6.5) then
            if abilityId > 0 then
                KS.RememberAbility(abilityId, name, "learn mode")
                return true
            end
        end
    end
    return false
end

local FOOD_RELEVANT_DERIVED_STATS = {
    [STAT_HEALTH_MAX] = true,
    [STAT_MAGICKA_MAX] = true,
    [STAT_STAMINA_MAX] = true,
    [STAT_HEALTH_REGEN_COMBAT] = true,
    [STAT_HEALTH_REGEN_IDLE] = true,
    [STAT_MAGICKA_REGEN_COMBAT] = true,
    [STAT_MAGICKA_REGEN_IDLE] = true,
    [STAT_STAMINA_REGEN_COMBAT] = true,
    [STAT_STAMINA_REGEN_IDLE] = true,
}

-- Known long-duration non-food effects that otherwise resemble food in ability metadata.
-- These IDs are intentionally only exclusions. Food detection itself is not ID based.
local FOOD_ABILITY_BLACKLIST = {
    [43752] = true,
    [21263] = true,
    [92232] = true,
    [64210] = true,
    [66776] = true,
    [77123] = true,
    [85501] = true,
    [85502] = true,
    [85503] = true,
    [86755] = true,
    [88445] = true,
    [89683] = true,
    [91369] = true,
}

function KS.AbilityAffectsFoodStat(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 or not DoesAbilityExist or not DoesAbilityExist(abilityId) then
        return false
    end

    if not GetAbilityNumDerivedStats or not GetAbilityDerivedStatAndEffectByIndex then
        return false
    end

    local numStats = tonumber(GetAbilityNumDerivedStats(abilityId)) or 0
    for i = 1, numStats do
        local derivedStat, effect = GetAbilityDerivedStatAndEffectByIndex(abilityId, i)
        if FOOD_RELEVANT_DERIVED_STATS[derivedStat] and (tonumber(effect) or 0) ~= 0 then
            return true
        end
    end

    return false
end

local function TextMentionsFoodStats(text)
    local normalized = normalizeName(text or "")
    if normalized == "" then return false end
    local tokens = {
        "max health", "maximum health",
        "max magicka", "maximum magicka",
        "max stamina", "maximum stamina",
        "health recovery", "magicka recovery", "stamina recovery",
    }
    for _, token in ipairs(tokens) do
        if normalized:find(token, 1, true) then return true end
    end
    return false
end

local function IsQuickMenuPreviewing(key)
    local quickMenu = U and U.QuickMenu or nil
    return quickMenu and quickMenu.IsPreviewing and quickMenu.IsPreviewing(key) or false
end

local function SafeAbilityText(apiFunc, abilityId)
    if type(apiFunc) ~= "function" then return "" end
    local ok, value = pcall(apiFunc, abilityId)
    if not ok then return "" end
    return tostring(value or "")
end

local function EffectNowSeconds()
    if GetFrameTimeSeconds then return tonumber(GetFrameTimeSeconds()) or 0 end
    if GetGameTimeMilliseconds then return (tonumber(GetGameTimeMilliseconds()) or 0) / 1000 end
    return 0
end

function KS.IsLongDurationProvisioningAbility(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 or FOOD_ABILITY_BLACKLIST[abilityId] then return false end
    if not DoesAbilityExist or not DoesAbilityExist(abilityId) then return false end

    -- This follows the same durable shape used by established ESO food-reminder
    -- addons: provisioning buffs are very long-duration self effects with no
    -- cast time, cost, range or area geometry. It is a fallback for live builds
    -- where derived-stat metadata is incomplete.
    local abilityDurationMs = GetAbilityDuration and (tonumber(GetAbilityDuration(abilityId, nil, "player")) or 0) or 0
    if abilityDurationMs < 600000 then return false end

    local cost = GetAbilityCost and (tonumber(GetAbilityCost(abilityId)) or 0) or 0
    if cost > 0 then return false end

    if GetAbilityCastInfo then
        local channeled, castTime = GetAbilityCastInfo(abilityId)
        if channeled == true or (tonumber(castTime) or 0) > 0 then return false end
    end

    if GetAbilityRange then
        local minRange, maxRange = GetAbilityRange(abilityId)
        if (tonumber(minRange) or 0) > 0 or (tonumber(maxRange) or 0) > 0 then return false end
    end
    if GetAbilityRadius and (tonumber(GetAbilityRadius(abilityId)) or 0) > 0 then return false end
    if GetAbilityAngleDistance and (tonumber(GetAbilityAngleDistance(abilityId)) or 0) > 0 then return false end

    local description = SafeAbilityText(GetAbilityDescription, abilityId)
    if description == "" then return false end
    return true
end

function KS.LooksLikeProvisioningAbility(abilityId, buffName, iconFilename, activeDuration)
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 or FOOD_ABILITY_BLACKLIST[abilityId] then return false end

    -- Best signal: ESO reports that the active ability modifies a maximum
    -- resource or resource recovery stat.
    if KS.AbilityAffectsFoodStat(abilityId) then return true end

    -- Current ESO builds do not expose derived-stat metadata consistently for
    -- every food/drink effect. Fall back to the ability's own provisioning-like
    -- metadata instead of requiring the visible buff to be clickable.
    if KS.IsLongDurationProvisioningAbility(abilityId) then return true end

    -- Some live builds do not expose derived-stat metadata for every provisioning
    -- effect ID. The ability text still describes the same resource bonuses.
    local description = SafeAbilityText(GetAbilityDescription, abilityId)
    local effectDescription = SafeAbilityText(GetAbilityEffectDescription, abilityId)
    if TextMentionsFoodStats(description) or TextMentionsFoodStats(effectDescription) then return true end

    -- Final conservative fallback for genuine long-duration consumable effects.
    -- Do not use this by itself for short buffs, Mundus effects or passives.
    local duration = tonumber(activeDuration) or 0
    local icon = normalizeName(iconFilename or "")
    if duration >= 600 and (icon:find("food", 1, true) or icon:find("drink", 1, true)
        or icon:find("provision", 1, true) or icon:find("serving", 1, true)) then
        return true
    end

    return false
end

function KS.IsFoodBuffCandidate(name, timeStarted, timeEnding, effectType, abilityType, abilityId, iconFilename, canClickOff)
    local now = EffectNowSeconds()
    local started = tonumber(timeStarted) or 0
    local ending = tonumber(timeEnding) or 0
    local duration = math.max(0, ending - started)

    if ending > 0 and ending <= now then return false end
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 then return false end

    -- Prefer the ability metadata because some current food auras report an
    -- abbreviated or zero begin/end span through GetUnitBuffInfo/EventEffect.
    if KS.LooksLikeProvisioningAbility(abilityId, name, iconFilename, duration) then return true end

    -- If metadata was unavailable, only then use the visible aura duration.
    if duration < 600 then return false end

    -- canClickOff changed behavior across ESO UI revisions. Treat it only as a
    -- supporting signal, never as a mandatory food requirement.
    if canClickOff == true and duration >= 1800 then
        if ABILITY_TYPE_BONUS == nil or abilityType == nil or abilityType == ABILITY_TYPE_BONUS then
            return true
        end
    end
    return false
end

function KS.ScanFoodBuff()
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local eventAura = KS.foodEventAura
    if eventAura and (tonumber(eventAura.endTime) or 0) > now then
        KS.foodBuffActive = true
        KS.foodBuffName = tostring(eventAura.name or "")
        KS.foodBuffAbilityId = tonumber(eventAura.abilityId) or 0
        return true
    elseif eventAura then
        KS.foodEventAura = nil
    end

    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0
    local found = false
    local foundName = ""
    local foundAbilityId = 0

    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)

        if KS.IsFoodBuffCandidate(
            name,
            timeStarted,
            timeEnding,
            effectType,
            abilityType,
            abilityId,
            iconFilename,
            canClickOff
        ) then
            found = true
            foundName = tostring(name or "")
            foundAbilityId = tonumber(abilityId) or 0
            break
        end
    end

    KS.foodBuffActive = found
    KS.foodBuffName = foundName
    KS.foodBuffAbilityId = foundAbilityId
    return found
end

function KS.UpdateFoodWarning()
    if not KS.foodWarningRoot or not KS.foodWarningLabel or not KS.sv then return end

    if IsQuickMenuPreviewing("food") then
        KS.foodWarningLabel:SetText("NO FOOD BUFF")
        KS.foodWarningRoot:SetHidden(false)
        KS.lastFoodWarningVisible = true
        return
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    if now < (tonumber(KS.foodWarningReadyAt) or 0) then
        KS.foodWarningRoot:SetHidden(true)
        return
    end

    local hasFood = KS.ScanFoodBuff()
    local visible = KS.sv.showNoFoodWarning ~= false
        and not hasFood
        and KS.IsHUDAllowed()

    if KS.lastFoodWarningVisible ~= visible then
        KS.lastFoodWarningVisible = visible
        KS.foodWarningRoot:SetHidden(not visible)
    end
end

function KS.PrintFoodDiagnostic()
    local now = GetGameTimeMilliseconds and (GetGameTimeMilliseconds() / 1000) or
        (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0)
    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0
    local candidates = 0

    chat(string.format(
        "Food diag: detected=%s name=%s id=%s buffs=%d",
        tostring(KS.ScanFoodBuff() == true),
        tostring(KS.foodBuffName or ""),
        tostring(KS.foodBuffAbilityId or 0),
        tonumber(numBuffs) or 0
    ))

    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo("player", i)

        local endTime = tonumber(timeEnding) or 0
        local duration = endTime - (tonumber(timeStarted) or 0)
        if endTime > now and canClickOff == true and duration >= 300 then
            local isFood = KS.IsFoodBuffCandidate(
                name,
                timeStarted,
                timeEnding,
                effectType,
                abilityType,
                abilityId,
                iconFilename,
                canClickOff
            )

            if isFood then candidates = candidates + 1 end

            local abilityDuration = GetAbilityDuration and
                (tonumber(GetAbilityDuration(tonumber(abilityId) or 0, nil, "player")) or 0) or 0
            local statMatch = KS.AbilityAffectsFoodStat(abilityId)

            chat(string.format(
                "%s%s | id=%s | remaining=%.0fs | abilityDur=%.0fs | statMatch=%s | clickOff=%s",
                isFood and "FOOD " or "",
                tostring(name or ""),
                tostring(abilityId or 0),
                math.max(0, endTime - now),
                abilityDuration / 1000,
                tostring(statMatch),
                tostring(canClickOff)
            ))
        end
    end

    if candidates == 0 then
        chat("Food diag: no active food/drink candidate detected.")
    end
end

function KS.IsOakensoulEquipped()
    if not GetItemLink then return false, "" end

    local slots = { EQUIP_SLOT_RING1, EQUIP_SLOT_RING2 }
    for _, slotIndex in ipairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slotIndex, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            if GetItemLinkSetInfo then
                local hasSet, detectedSetName = GetItemLinkSetInfo(itemLink, true)
                if hasSet then
                    local setName = tostring(detectedSetName or "")
                    if normalizeName(setName):find("oakensoul", 1, true) then
                        return true, setName
                    end
                end
            end

            -- Fallback to the equipped item name in case the set-name metadata
            -- is exposed differently by a future/current API revision.
            if GetItemLinkName then
                local itemName = tostring(GetItemLinkName(itemLink) or "")
                if normalizeName(itemName):find("oakensoul", 1, true) then
                    return true, itemName
                end
            end
        end
    end

    return false, ""
end

function KS.IsMajorResolveBuff(name)
    local normalized = normalizeName(name or "")
    if normalized == "" then return false end
    if normalized:find("major resolve", 1, true) then return true end
    if normalized:find("hurricane", 1, true) then return true end
    if normalized:find("boundless storm", 1, true) then return true end
    if normalized:find("lightning form", 1, true) then return true end
    return false
end

function KS.AbilityGrantsMajorResolve(abilityId)
    abilityId = tonumber(abilityId) or 0
    if abilityId <= 0 then return false end

    -- GetAbilityBuffType is the strongest available signal and avoids relying
    -- on localized effect names. Guard it for compatibility with older clients.
    if type(GetAbilityBuffType) == "function" and BUFF_TYPE_MAJOR_RESOLVE ~= nil then
        local ok, buffType = pcall(GetAbilityBuffType, abilityId)
        if ok and buffType == BUFF_TYPE_MAJOR_RESOLVE then return true end
    end

    local abilityName = SafeAbilityText(GetAbilityName, abilityId)
    if KS.IsMajorResolveBuff(abilityName) then return true end
    local description = SafeAbilityText(GetAbilityDescription, abilityId)
    local effectDescription = SafeAbilityText(GetAbilityEffectDescription, abilityId)
    return normalizeName(description):find("major resolve", 1, true) ~= nil
        or normalizeName(effectDescription):find("major resolve", 1, true) ~= nil
end

function KS.IsMajorResolveEffect(name, abilityId)
    return KS.IsMajorResolveBuff(name) or KS.AbilityGrantsMajorResolve(abilityId)
end

function KS.ScanMajorResolve()
    local now = EffectNowSeconds()
    local eventAura = KS.majorResolveEventAura
    if eventAura and ((tonumber(eventAura.endTime) or 0) == 0 or (tonumber(eventAura.endTime) or 0) > now) then
        KS.majorResolveActive = true
        KS.majorResolveBuffName = tostring(eventAura.name or "Major Resolve")
        KS.majorResolveAbilityId = tonumber(eventAura.abilityId) or 0
        return true
    elseif eventAura then
        KS.majorResolveEventAura = nil
    end

    -- Werewolf form has its own built-in Major Resolve source. Detect the form
    -- directly instead of waiting for a separate named buff to appear.
    if type(IsPlayerInWerewolfForm) == "function" and IsPlayerInWerewolfForm() == true then
        KS.majorResolveActive = true
        KS.majorResolveBuffName = "Werewolf"
        KS.majorResolveAbilityId = 0
        return true
    end

    -- Oakensoul grants Major Resolve as part of its one-piece effect. Detect the
    -- equipped mythic directly rather than depending on ESO exposing a separate
    -- buff whose display name literally contains "Major Resolve".
    local oakensoulEquipped, oakensoulName = KS.IsOakensoulEquipped()
    if oakensoulEquipped then
        KS.majorResolveActive = true
        KS.majorResolveBuffName = oakensoulName ~= "" and oakensoulName or "Oakensoul"
        KS.majorResolveAbilityId = 0
        return true
    end

    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0
    local found = false
    local foundName = ""
    local foundAbilityId = 0

    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)

        if KS.IsMajorResolveEffect(name, abilityId) then
            local scanNow = EffectNowSeconds()
            local ending = tonumber(timeEnding) or 0

            if ending == 0 or ending > scanNow then
                found = true
                foundName = tostring(name or "")
                foundAbilityId = tonumber(abilityId) or 0
                break
            end
        end
    end

    KS.majorResolveActive = found
    KS.majorResolveBuffName = foundName
    KS.majorResolveAbilityId = foundAbilityId
    return found
end

function KS.UpdateMajorResolveWarning()
    if not KS.majorResolveWarningRoot or not KS.majorResolveWarningLabel or not KS.sv then return end

    if IsQuickMenuPreviewing("resolve") then
        KS.majorResolveWarningLabel:SetText("NO MAJOR RESOLVE")
        KS.majorResolveWarningRoot:SetHidden(false)
        KS.lastMajorResolveWarningVisible = true
        return
    end

    local visible = false

    if KS.sv.showNoMajorResolveWarning ~= false
        and KS.IsPlayerInCombat()
        and KS.IsHUDAllowed() then
        visible = not KS.ScanMajorResolve()
    end

    if KS.lastMajorResolveWarningVisible ~= visible then
        KS.lastMajorResolveWarningVisible = visible
        KS.majorResolveWarningRoot:SetHidden(not visible)
    end
end

function KS.PrintMajorResolveDiagnostic()
    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0
    local oakensoulEquipped, oakensoulName = KS.IsOakensoulEquipped()
    local werewolfActive = type(IsPlayerInWerewolfForm) == "function" and IsPlayerInWerewolfForm() == true
    chat(string.format(
        "Resolve diag: active=%s name=%s id=%s buffs=%d werewolf=%s oakensoul=%s%s",
        tostring(KS.ScanMajorResolve() == true),
        tostring(KS.majorResolveBuffName or ""),
        tostring(KS.majorResolveAbilityId or 0),
        tonumber(numBuffs) or 0,
        tostring(werewolfActive),
        tostring(oakensoulEquipped == true),
        oakensoulEquipped and (" (" .. tostring(oakensoulName or "Oakensoul") .. ")") or ""
    ))

    local shown = 0
    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)

        local normalized = normalizeName(name or "")
        if normalized:find("resolve", 1, true)
            or normalized:find("hurricane", 1, true)
            or normalized:find("storm", 1, true)
            or normalized:find("lightning form", 1, true) then
            shown = shown + 1
            chat(string.format(
                "Resolve buff %d: %s | id=%s | end=%.2f",
                shown,
                tostring(name or ""),
                tostring(abilityId or 0),
                tonumber(timeEnding) or 0
            ))
        end
    end

    if shown == 0 then
        chat("Resolve diag: no Resolve/Hurricane/Storm buff names found on player.")
    end
end

function KS.ScanDragonAppetiteStacks()
    if not KS.dragonAppetiteWorn then
        local changed = (tonumber(KS.dragonAppetiteStacks) or 0) ~= 0
            or (tonumber(KS.dragonAppetiteAbilityId) or 0) ~= 0
            or tostring(KS.dragonAppetiteEffectName or "") ~= ""
        KS.dragonAppetiteStacks = 0
        KS.dragonAppetiteAbilityId = 0
        KS.dragonAppetiteEffectName = ""
        if changed then
            KS.lastDragonAppetiteTimerText = nil
            KS.UpdateCombatTimers()
        end
        return 0
    end

    local foundStacks = 0
    local foundAbilityId = 0
    local foundName = ""
    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0

    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)

        local id = tonumber(abilityId) or 0
        local abilityName = id > 0 and GetAbilityName and GetAbilityName(id) or ""
        if looksLikeDragonAppetiteEffectName(name) or looksLikeDragonAppetiteEffectName(abilityName) then
            local stacks = math.floor((tonumber(stackCount) or 0) + 0.5)
            stacks = clamp(stacks, 0, 10)
            if stacks >= foundStacks then
                foundStacks = stacks
                foundAbilityId = id
                foundName = tostring(name or abilityName or "")
            end
        end
    end

    local changed = foundStacks ~= (tonumber(KS.dragonAppetiteStacks) or 0)
        or foundAbilityId ~= (tonumber(KS.dragonAppetiteAbilityId) or 0)
        or foundName ~= tostring(KS.dragonAppetiteEffectName or "")

    KS.dragonAppetiteStacks = foundStacks
    KS.dragonAppetiteAbilityId = foundAbilityId
    KS.dragonAppetiteEffectName = foundName

    if changed then
        KS.lastDragonAppetiteTimerText = nil
        KS.UpdateCombatTimers()
    end

    return foundStacks
end

function KS.OnDragonAppetiteEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" or not KS.dragonAppetiteWorn then return end

    local abilityName = (tonumber(abilityId) or 0) > 0 and GetAbilityName and GetAbilityName(abilityId) or ""
    if not looksLikeDragonAppetiteEffectName(effectName)
        and not looksLikeDragonAppetiteEffectName(abilityName)
        and (tonumber(abilityId) or 0) ~= (tonumber(KS.dragonAppetiteAbilityId) or -1) then
        return
    end

    zo_callLater(function()
        KS.ScanDragonAppetiteStacks()
    end, 0)
end

function KS.ApplyPlayerAuraHudLayout()
    if not KS.sv then return end

    local size = clamp(math.floor(tonumber(KS.sv.playerAuraIconSize) or defaults.playerAuraIconSize), 34, 68)
    local ccX = clamp(math.floor(tonumber(KS.sv.ccImmunityX) or defaults.ccImmunityX), -800, 800)
    local ccY = clamp(math.floor(tonumber(KS.sv.ccImmunityY) or defaults.ccImmunityY), -520, 420)
    local debuffX = clamp(math.floor(tonumber(KS.sv.playerDebuffX) or defaults.playerDebuffX), -800, 800)
    local debuffY = clamp(math.floor(tonumber(KS.sv.playerDebuffY) or defaults.playerDebuffY), -520, 420)
    local maxIcons = clamp(math.floor(tonumber(KS.sv.playerDebuffMaxIcons) or defaults.playerDebuffMaxIcons), 3, 12)

    KS.sv.playerAuraIconSize = size
    KS.sv.ccImmunityX = ccX
    KS.sv.ccImmunityY = ccY
    KS.sv.playerDebuffX = debuffX
    KS.sv.playerDebuffY = debuffY
    KS.sv.playerDebuffMaxIcons = maxIcons

    local timerFontSize = clamp(math.floor(size * 0.45 + 0.5), 16, 32)

    if KS.ccImmunityRoot then
        KS.ccImmunityRoot:SetDimensions(size, size)
        if KS.ccImmunityRoot.ultiviteQuickDragging ~= true then
            KS.ccImmunityRoot:ClearAnchors()
            KS.ccImmunityRoot:SetAnchor(CENTER, GuiRoot, CENTER, ccX, ccY)
        end
    end
    if KS.ccImmunityCountdown then
        KS.ccImmunityCountdown:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", timerFontSize))
    end

    local gap = 6
    if KS.playerDebuffRoot then
        KS.playerDebuffRoot:SetDimensions((size * maxIcons) + (gap * math.max(0, maxIcons - 1)), size)
        if KS.playerDebuffRoot.ultiviteQuickDragging ~= true then
            KS.playerDebuffRoot:ClearAnchors()
            KS.playerDebuffRoot:SetAnchor(CENTER, GuiRoot, CENTER, debuffX, debuffY)
        end
    end

    for index, slot in ipairs(KS.playerDebuffSlots or {}) do
        if slot and slot.control then
            slot.control:SetDimensions(size, size)
            slot.control:ClearAnchors()
            slot.control:SetAnchor(LEFT, KS.playerDebuffRoot, LEFT, (index - 1) * (size + gap), 0)
            if slot.countdown then
                slot.countdown:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", timerFontSize))
            end
        end
    end
end

function KS.SetCcImmunityDragUnlocked(enabled)
    KS.ccImmunityDragUnlocked = enabled == true
    if KS.ccImmunityRoot then
        KS.ccImmunityRoot:SetMouseEnabled(KS.ccImmunityDragUnlocked)
        KS.ccImmunityRoot:SetMovable(true)
        KS.ccImmunityRoot:SetClampedToScreen(true)
    end
    KS.UpdatePlayerAuraHud()
end

function KS.OnPlayerAuraHudEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
    stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not KS.sv or unitTag ~= "player" then return end

    local id = tonumber(abilityId) or 0
    local displayName = tostring(effectName or "")
    local abilityName = id > 0 and GetAbilityName and tostring(GetAbilityName(id) or "") or ""
    local isCcImmunity = looksLikeCcImmunityEffect(displayName, id) or looksLikeCcImmunityEffect(abilityName, id)
    local faded = EFFECT_RESULT_FADED ~= nil and changeType == EFFECT_RESULT_FADED
    local started = tonumber(beginTime) or 0
    local ending = tonumber(endTime) or 0

    -- Cache food and Major Resolve directly from the authoritative player effect
    -- event. This avoids false warnings when the same effect is represented
    -- differently by GetUnitBuffInfo() in a later scan.
    if not faded and KS.IsFoodBuffCandidate(displayName, started, ending, effectType, abilityType, id, iconName, nil) then
        KS.foodEventAura = { name = displayName, abilityId = id, beginTime = started, endTime = ending, effectSlot = tonumber(effectSlot) or 0 }
    elseif faded and KS.foodEventAura then
        local sameId = id ~= 0 and (tonumber(KS.foodEventAura.abilityId) or 0) == id
        local sameSlot = (tonumber(KS.foodEventAura.effectSlot) or 0) ~= 0 and (tonumber(KS.foodEventAura.effectSlot) or 0) == (tonumber(effectSlot) or -1)
        if sameId or sameSlot then KS.foodEventAura = nil end
    end

    if not faded and KS.IsMajorResolveEffect(displayName ~= "" and displayName or abilityName, id) then
        KS.majorResolveEventAura = { name = displayName ~= "" and displayName or abilityName, abilityId = id, beginTime = started, endTime = ending, effectSlot = tonumber(effectSlot) or 0 }
    elseif faded and KS.majorResolveEventAura then
        local sameId = id ~= 0 and (tonumber(KS.majorResolveEventAura.abilityId) or 0) == id
        local sameSlot = (tonumber(KS.majorResolveEventAura.effectSlot) or 0) ~= 0 and (tonumber(KS.majorResolveEventAura.effectSlot) or 0) == (tonumber(effectSlot) or -1)
        if sameId or sameSlot then KS.majorResolveEventAura = nil end
    end

    if KS.foodWarningRoot then KS.UpdateFoodWarning() end
    if KS.majorResolveWarningRoot then KS.UpdateMajorResolveWarning() end

    if KS.sv.showCcImmunityTracker ~= false and isCcImmunity then
        local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0

        if not faded and ending > now and ending > started then
            local icon = tostring(iconName or "")
            if icon == "" and id > 0 and GetAbilityIcon then
                icon = tostring(GetAbilityIcon(id) or "")
            end

            KS.ccImmunityEventAura = {
                name = displayName ~= "" and displayName or (abilityName ~= "" and abilityName or "CC Immunity"),
                abilityId = id,
                beginTime = started,
                endTime = ending,
                icon = icon,
                effectSlot = tonumber(effectSlot) or 0,
            }
            KS.ccImmunityAura = KS.ccImmunityEventAura
            KS.UpdatePlayerAuraHud()
        elseif faded then
            local active = KS.ccImmunityEventAura
            if active then
                local sameSlot = (tonumber(active.effectSlot) or 0) ~= 0
                    and (tonumber(active.effectSlot) or 0) == (tonumber(effectSlot) or -1)
                local sameId = id ~= 0 and (tonumber(active.abilityId) or 0) == id
                if sameSlot or sameId then
                    KS.ccImmunityEventAura = nil
                    KS.ccImmunityAura = nil
                    KS.UpdatePlayerAuraHud()
                end
            end
        end
    end

    -- Keep the normal player aura scan as a fallback for debuffs and for
    -- immunity sources that ESO exposes only through GetUnitBuffInfo().
    KS.SchedulePlayerAuraHudScan()
end

function KS.SchedulePlayerAuraHudScan()
    if KS.playerAuraHudScanPending then return end
    KS.playerAuraHudScanPending = true
    zo_callLater(function()
        KS.playerAuraHudScanPending = false
        if KS.sv then KS.ScanPlayerAuraHud() end
    end, 25)
end

function KS.ScanPlayerAuraHud()
    if not KS.sv then return 0 end

    local trackCc = KS.sv.showCcImmunityTracker ~= false
    local trackDebuffs = KS.sv.showPlayerDebuffTracker ~= false

    if not trackCc and not trackDebuffs then
        KS.ccImmunityAura = nil
        KS.ccImmunityEventAura = nil
        KS.playerDebuffAuras = {}
        KS.playerAuraHudLastScanMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
        KS.UpdatePlayerAuraHud()
        return 0
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local eventAura = KS.ccImmunityEventAura
    if eventAura and (tonumber(eventAura.endTime) or 0) <= now then
        KS.ccImmunityEventAura = nil
        eventAura = nil
    end
    local ccAura = eventAura
    local debuffsByKey = {}
    local debuffs = {}
    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0

    for index = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
            deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId =
            GetUnitBuffInfo("player", index)

        local id = tonumber(abilityId) or 0
        local started = tonumber(timeStarted) or 0
        local ending = tonumber(timeEnding) or 0
        local displayName = tostring(name or "")
        local abilityName = id > 0 and GetAbilityName and tostring(GetAbilityName(id) or "") or ""
        local icon = tostring(iconFilename or "")
        if icon == "" and id > 0 and GetAbilityIcon then
            icon = tostring(GetAbilityIcon(id) or "")
        end

        if trackCc and ending > now and ending > started
            and (looksLikeCcImmunityEffect(displayName, id) or looksLikeCcImmunityEffect(abilityName, id)) then
            if not ccAura or ending > (tonumber(ccAura.endTime) or 0) then
                ccAura = {
                    name = displayName ~= "" and displayName or (abilityName ~= "" and abilityName or "CC Immunity"),
                    abilityId = id,
                    beginTime = started,
                    endTime = ending,
                    icon = icon,
                }
            end
        end

        if trackDebuffs and isTimedPlayerDebuff(effectType, started, ending, now) then
            local key = id > 0 and ("id:" .. tostring(id)) or ("name:" .. normalizeName(displayName))
            local existing = debuffsByKey[key]
            local aura = {
                name = displayName ~= "" and displayName or abilityName,
                abilityId = id,
                beginTime = started,
                endTime = ending,
                icon = icon,
                stackCount = tonumber(stackCount) or 0,
                effectType = effectType,
            }
            if not existing or ending > (tonumber(existing.endTime) or 0) then
                debuffsByKey[key] = aura
            end
        end
    end

    for _, aura in pairs(debuffsByKey) do
        debuffs[#debuffs + 1] = aura
    end

    table.sort(debuffs, function(a, b)
        local ae = tonumber(a.endTime) or 0
        local be = tonumber(b.endTime) or 0
        if ae ~= be then return ae < be end
        return normalizeName(a.name) < normalizeName(b.name)
    end)

    KS.ccImmunityAura = ccAura
    KS.playerDebuffAuras = debuffs
    KS.playerAuraHudLastScanMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    KS.UpdatePlayerAuraHud()
    return #debuffs
end

function KS.UpdatePlayerAuraHud()
    if not KS.sv then return end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local hudAllowed = KS.IsHUDAllowed()
    KS.ApplyPlayerAuraHudLayout()

    if KS.ccImmunityRoot then
        local aura = KS.ccImmunityAura
        local remaining = aura and math.max(0, (tonumber(aura.endTime) or 0) - now) or 0
        local previewCc = IsQuickMenuPreviewing("cc") or KS.ccImmunityDragUnlocked == true
        local show = previewCc or (hudAllowed and KS.sv.showCcImmunityTracker ~= false and aura ~= nil and remaining > 0)

        if show then
            local icon = aura and tostring(aura.icon or "") or ""
            if icon == "" and GetAbilityIcon then
                icon = tostring(GetAbilityIcon(aura and (tonumber(aura.abilityId) or CC_IMMUNITY_ABILITY_ID) or CC_IMMUNITY_ABILITY_ID) or "")
            end
            if icon == "" and GetAbilityIcon then
                icon = tostring(GetAbilityIcon(CC_IMMUNITY_ABILITY_ID) or "")
            end
            if KS.ccImmunityIcon then
                KS.ccImmunityIcon:SetTexture(icon)
                KS.ccImmunityIcon:SetHidden(icon == "")
            end
            if KS.ccImmunityCountdown then
                KS.ccImmunityCountdown:SetText(previewCc and "6" or tostring(math.max(1, math.ceil(remaining - 0.001))))
            end
        end
        KS.ccImmunityRoot:SetHidden(not show)
    end

    local maxIcons = clamp(math.floor(tonumber(KS.sv.playerDebuffMaxIcons) or defaults.playerDebuffMaxIcons), 3, 12)
    local active = {}

    if KS.sv.showPlayerDebuffTracker ~= false then
        for _, aura in ipairs(KS.playerDebuffAuras or {}) do
            local remaining = math.max(0, (tonumber(aura.endTime) or 0) - now)
            if remaining > 0 then
                active[#active + 1] = aura
                if #active >= maxIcons then break end
            end
        end
    end

    local previewDebuffs = IsQuickMenuPreviewing("debuffs")
    if previewDebuffs and #active == 0 then
        local previewEnd = now + 8
        active[1] = { name = "Major Breach", abilityId = 0, beginTime = now, endTime = previewEnd, icon = "" }
        active[2] = { name = "Poisoned", abilityId = 0, beginTime = now, endTime = now + 4, icon = "" }
    end
    local showDebuffRoot = previewDebuffs or (hudAllowed and KS.sv.showPlayerDebuffTracker ~= false and #active > 0)

    if KS.playerDebuffRoot then
        for index, slot in ipairs(KS.playerDebuffSlots or {}) do
            local aura = active[index]
            if slot and slot.control then
                if showDebuffRoot and aura then
                    local remaining = math.max(0, (tonumber(aura.endTime) or 0) - now)
                    local icon = tostring(aura.icon or "")
                    if icon == "" and (tonumber(aura.abilityId) or 0) > 0 and GetAbilityIcon then
                        icon = tostring(GetAbilityIcon(aura.abilityId) or "")
                    end
                    if slot.icon then
                        slot.icon:SetTexture(icon)
                        slot.icon:SetHidden(icon == "")
                    end
                    if slot.countdown then
                        slot.countdown:SetText(tostring(math.max(1, math.ceil(remaining - 0.001))))
                    end
                    slot.control:SetHidden(false)
                else
                    slot.control:SetHidden(true)
                end
            end
        end
        KS.playerDebuffRoot:SetHidden(not showDebuffRoot)
    end
end

function KS.PrintPlayerAuraHudDiagnostic()
    KS.ScanPlayerAuraHud()

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local cc = KS.ccImmunityAura
    if cc then
        chat(string.format(
            "CC immunity: %s id=%s remaining=%.1f source=%s icon=%s",
            tostring(cc.name or ""),
            tostring(cc.abilityId or 0),
            math.max(0, (tonumber(cc.endTime) or 0) - now),
            KS.ccImmunityEventAura == cc and "effect-event" or "buff-scan",
            tostring(cc.icon or "")
        ))
    else
        chat("CC immunity: no active tracked hard-CC immunity aura.")
    end

    chat(string.format("Timed player debuffs: %d", #(KS.playerDebuffAuras or {})))
    for index, aura in ipairs(KS.playerDebuffAuras or {}) do
        if index > 12 then break end
        chat(string.format(
            "DEBUFF[%d] %s id=%s remaining=%.1f stacks=%s",
            index,
            tostring(aura.name or ""),
            tostring(aura.abilityId or 0),
            math.max(0, (tonumber(aura.endTime) or 0) - now),
            tostring(aura.stackCount or 0)
        ))
    end
end

function KS.ApplyWretchedVitalityLayout()
    if not KS.wretchedVitalityRoot or not KS.sv then return end

    local size = clamp(
        math.floor(tonumber(KS.sv.wretchedVitalityIconSize) or defaults.wretchedVitalityIconSize),
        36,
        80
    )
    local x = clamp(math.floor(tonumber(KS.sv.wretchedVitalityX) or defaults.wretchedVitalityX), -700, 700)
    local y = clamp(math.floor(tonumber(KS.sv.wretchedVitalityY) or defaults.wretchedVitalityY), -500, 350)
    KS.sv.wretchedVitalityIconSize = size
    KS.sv.wretchedVitalityX = x
    KS.sv.wretchedVitalityY = y

    local gap = 10
    local width = (size * 2) + gap
    KS.wretchedVitalityRoot:SetDimensions(width, size)
    KS.wretchedVitalityRoot:ClearAnchors()
    KS.wretchedVitalityRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)

    local fontSize = clamp(math.floor(size * 0.46 + 0.5), 18, 36)
    for index, slot in ipairs(KS.wretchedVitalitySlots or {}) do
        if slot and slot.control then
            slot.control:SetDimensions(size, size)
            slot.control:ClearAnchors()
            if index == 1 then
                slot.control:SetAnchor(LEFT, KS.wretchedVitalityRoot, LEFT, 0, 0)
            else
                slot.control:SetAnchor(RIGHT, KS.wretchedVitalityRoot, RIGHT, 0, 0)
            end
            if slot.countdown then
                slot.countdown:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize))
            end
        end
    end
end

function KS.ScanWretchedVitalityBuffs()
    if not KS.sv or KS.sv.wretchedVitalityTimers == false then
        KS.wretchedVitalityBuffs = {}
        KS.UpdateWretchedVitalityTimers()
        return 0
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local found = {}
    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0

    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename,
            deprecatedBuffType, effectType, abilityType, statusEffectType, abilityId =
            GetUnitBuffInfo("player", i)

        local id = tonumber(abilityId) or 0
        local abilityName = id > 0 and GetAbilityName and GetAbilityName(id) or ""
        local matches = looksLikeWretchedVitalityEffectName(name)
            or looksLikeWretchedVitalityEffectName(abilityName)

        local started = tonumber(timeStarted) or 0
        local ending = tonumber(timeEnding) or 0

        -- Ignore passive/static set entries. The two Wretched recovery effects
        -- are timed player buffs and therefore have a real expiration time.
        if matches and ending > now and ending > started then
            local icon = tostring(iconFilename or "")
            if icon == "" and id > 0 and GetAbilityIcon then
                icon = tostring(GetAbilityIcon(id) or "")
            end

            found[#found + 1] = {
                name = tostring(name or abilityName or "Wretched Vitality"),
                abilityId = id,
                buffSlot = tonumber(buffSlot) or i,
                beginTime = started,
                endTime = ending,
                icon = icon,
            }
        end
    end

    table.sort(found, function(a, b)
        if a.abilityId ~= b.abilityId then
            return a.abilityId < b.abilityId
        end
        if a.buffSlot ~= b.buffSlot then
            return a.buffSlot < b.buffSlot
        end
        return a.endTime > b.endTime
    end)

    KS.wretchedVitalityBuffs = {}
    for i = 1, math.min(2, #found) do
        KS.wretchedVitalityBuffs[i] = found[i]
    end

    KS.wretchedVitalityLastScanMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    KS.UpdateWretchedVitalityTimers()
    return #KS.wretchedVitalityBuffs
end

function KS.UpdateWretchedVitalityTimers()
    local root = KS.wretchedVitalityRoot
    if not root then return end
    local preview = IsQuickMenuPreviewing("wretchedVitality")

    if not preview and (not KS.sv or KS.sv.wretchedVitalityTimers == false or not KS.IsHUDAllowed()) then
        root:SetHidden(true)
        return
    end

    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local active = {}

    for _, buff in ipairs(KS.wretchedVitalityBuffs or {}) do
        local remain = math.max(0, (tonumber(buff.endTime) or 0) - now)
        if remain > 0 then
            active[#active + 1] = buff
        end
    end

    -- Expired locally: rescan once so refreshed effects are picked up even if
    -- ESO replaced the buff slot at the same moment the old timer reached zero.
    if #active < #(KS.wretchedVitalityBuffs or {}) then
        KS.wretchedVitalityBuffs = active
    end

    if preview and #active == 0 then
        active = {
            { name = "Wretched Vitality", abilityId = 0, beginTime = now, endTime = now + 15, icon = "" },
            { name = "Wretched Vitality", abilityId = 0, beginTime = now, endTime = now + 9, icon = "" },
        }
    end

    if #active == 0 then
        for _, slot in ipairs(KS.wretchedVitalitySlots or {}) do
            if slot and slot.control then slot.control:SetHidden(true) end
        end
        root:SetHidden(true)
        return
    end

    KS.ApplyWretchedVitalityLayout()

    -- Center a single active icon; use left/right slots when both buffs are up.
    local size = tonumber(KS.sv.wretchedVitalityIconSize) or defaults.wretchedVitalityIconSize
    local gap = 10
    if #active == 1 then
        root:SetDimensions(size, size)
    else
        root:SetDimensions((size * 2) + gap, size)
    end

    for index = 1, 2 do
        local slot = KS.wretchedVitalitySlots[index]
        local buff = active[index]

        if slot and slot.control then
            if buff then
                slot.control:SetHidden(false)
                slot.control:ClearAnchors()
                if #active == 1 then
                    slot.control:SetAnchor(CENTER, root, CENTER, 0, 0)
                elseif index == 1 then
                    slot.control:SetAnchor(LEFT, root, LEFT, 0, 0)
                else
                    slot.control:SetAnchor(RIGHT, root, RIGHT, 0, 0)
                end

                if slot.icon and buff.icon ~= "" then
                    slot.icon:SetTexture(buff.icon)
                    slot.icon:SetHidden(false)
                elseif slot.icon then
                    slot.icon:SetHidden(true)
                end

                local remain = math.max(0, (tonumber(buff.endTime) or 0) - now)
                if slot.countdown then
                    slot.countdown:SetText(tostring(math.max(1, math.ceil(remain - 0.001))))
                end
            else
                slot.control:SetHidden(true)
            end
        end
    end

    root:SetHidden(false)
end

function KS.OnWretchedVitalityEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag,
    beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType,
    statusEffectType, unitName, unitId, abilityId, sourceType)

    if unitTag ~= "player" then return end

    local abilityName = (tonumber(abilityId) or 0) > 0 and GetAbilityName and GetAbilityName(abilityId) or ""
    if not looksLikeWretchedVitalityEffectName(effectName)
        and not looksLikeWretchedVitalityEffectName(abilityName) then
        return
    end

    zo_callLater(function()
        KS.ScanWretchedVitalityBuffs()
    end, 0)
end

function KS.PrintWretchedVitalityDiagnostic()
    local count = KS.ScanWretchedVitalityBuffs()
    chat(string.format("Wretched Vitality diag: %d active timed buff(s)", tonumber(count) or 0))

    for index, buff in ipairs(KS.wretchedVitalityBuffs or {}) do
        local remain = math.max(0, (tonumber(buff.endTime) or 0) - (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0))
        chat(string.format(
            "WRETCHED[%d] name=%s id=%s slot=%s remaining=%.1f icon=%s",
            index,
            tostring(buff.name or ""),
            tostring(buff.abilityId or 0),
            tostring(buff.buffSlot or 0),
            remain,
            tostring(buff.icon or "")
        ))
    end
end


local IMPORTANT_TARGET_DEBUFF_NAMES = {
    "major breach", "minor breach", "major defile", "minor defile",
    "major vulnerability", "minor vulnerability", "off balance",
    "burning", "chilled", "concussed", "poisoned", "diseased",
    "hemorrhaging", "sundered", "overcharged",
}

local function isImportantTargetDebuffName(name)
    local n = normalizeName(name)
    if n == "" then return false end
    for _, wanted in ipairs(IMPORTANT_TARGET_DEBUFF_NAMES) do
        if n == wanted or n:find(wanted, 1, true) then return true end
    end
    return false
end

local function isStreakSkillName(name)
    local n = normalizeName(name)
    return n == "streak" or n:find("streak", 1, true) ~= nil
end

function KS.GetReadableHotbarCategories()
    local categories = {}
    local seen = {}
    local function add(category)
        if type(category) == "number" and not seen[category] then
            seen[category] = true
            categories[#categories + 1] = category
        end
    end
    if type(GetActiveHotbarCategory) == "function" then
        local ok, category = pcall(GetActiveHotbarCategory)
        if ok then add(category) end
    end
    add(rawget(_G, "HOTBAR_CATEGORY_PRIMARY"))
    add(rawget(_G, "HOTBAR_CATEGORY_BACKUP"))
    return categories
end

function KS.CollectSlottedSkillStackState()
    local generic = {}
    local byKey = {}
    local streak = nil
    if type(GetActionSlotEffectStackCount) ~= "function" then return generic, streak end

    local firstSlot = tonumber(rawget(_G, "ACTION_BAR_FIRST_NORMAL_SLOT_INDEX")) or 3
    local lastSlot = tonumber(rawget(_G, "ACTION_BAR_LAST_WEAPON_SLOT_INDEX")) or 8
    for _, hotbar in ipairs(KS.GetReadableHotbarCategories()) do
        for slotIndex = firstSlot, lastSlot do
            local name = type(GetSlotName) == "function" and tostring(GetSlotName(slotIndex, hotbar) or "") or ""
            local abilityId = type(GetSlotBoundId) == "function" and (tonumber(GetSlotBoundId(slotIndex, hotbar)) or 0) or 0
            local stacks = tonumber(GetActionSlotEffectStackCount(slotIndex, hotbar)) or 0
            local remainingMs = type(GetActionSlotEffectTimeRemaining) == "function" and (tonumber(GetActionSlotEffectTimeRemaining(slotIndex, hotbar)) or 0) or 0
            local icon = type(GetSlotTexture) == "function" and tostring((GetSlotTexture(slotIndex, hotbar)) or "") or ""

            if isStreakSkillName(name) and (stacks > 0 or remainingMs > 0) then
                local count = stacks > 0 and stacks or 1
                if not streak or count > (tonumber(streak.stacks) or 0) then
                    streak = { name = name, abilityId = abilityId, stacks = count, remainingMs = remainingMs, icon = icon, slotIndex = slotIndex, hotbar = hotbar }
                end
            elseif stacks > 0 then
                local key = abilityId > 0 and ("id:" .. tostring(abilityId)) or (normalizeName(name) .. ":" .. tostring(hotbar) .. ":" .. tostring(slotIndex))
                local existing = byKey[key]
                if not existing or stacks > (tonumber(existing.stacks) or 0) then
                    byKey[key] = { name = name, abilityId = abilityId, stacks = stacks, remainingMs = remainingMs, icon = icon, slotIndex = slotIndex, hotbar = hotbar }
                end
            end
        end
    end

    for _, entry in pairs(byKey) do generic[#generic + 1] = entry end
    table.sort(generic, function(a, b)
        if (tonumber(a.hotbar) or 0) ~= (tonumber(b.hotbar) or 0) then return (tonumber(a.hotbar) or 0) < (tonumber(b.hotbar) or 0) end
        return (tonumber(a.slotIndex) or 0) < (tonumber(b.slotIndex) or 0)
    end)
    return generic, streak
end

function KS.ApplySkillStackTrackerLayout()
    if not KS.sv then return end
    local size = clamp(math.floor(tonumber(KS.sv.genericStackIconSize) or defaults.genericStackIconSize), 30, 64)
    local streakSize = clamp(math.floor(tonumber(KS.sv.streakFatigueIconSize) or defaults.streakFatigueIconSize), 30, 68)
    local gap = 6
    local x = clamp(math.floor(tonumber(KS.sv.genericStackX) or defaults.genericStackX), -800, 800)
    local y = clamp(math.floor(tonumber(KS.sv.genericStackY) or defaults.genericStackY), -500, 500)
    local sx = clamp(math.floor(tonumber(KS.sv.streakFatigueX) or defaults.streakFatigueX), -800, 800)
    local sy = clamp(math.floor(tonumber(KS.sv.streakFatigueY) or defaults.streakFatigueY), -500, 500)
    KS.sv.genericStackIconSize = size
    KS.sv.streakFatigueIconSize = streakSize
    KS.sv.genericStackX, KS.sv.genericStackY = x, y
    KS.sv.streakFatigueX, KS.sv.streakFatigueY = sx, sy

    if KS.genericStackRoot then
        KS.genericStackRoot:SetDimensions((size * 6) + (gap * 5), size)
        KS.genericStackRoot:ClearAnchors()
        KS.genericStackRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    end
    for index, slot in ipairs(KS.genericStackSlots or {}) do
        slot.control:SetDimensions(size, size)
        slot.control:ClearAnchors()
        slot.control:SetAnchor(LEFT, KS.genericStackRoot, LEFT, (index - 1) * (size + gap), 0)
        slot.count:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", clamp(math.floor(size * 0.52), 16, 34)))
    end
    if KS.streakFatigueRoot then
        KS.streakFatigueRoot:SetDimensions(streakSize, streakSize)
        KS.streakFatigueRoot:ClearAnchors()
        KS.streakFatigueRoot:SetAnchor(CENTER, GuiRoot, CENTER, sx, sy)
    end
    if KS.streakFatigueCount then
        KS.streakFatigueCount:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", clamp(math.floor(streakSize * 0.55), 17, 36)))
    end
end

function KS.CreateSkillStackTrackers()
    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow("UltiviteGenericSkillStacks")
    KS.genericStackRoot = root
    root:SetDrawLayer(DL_OVERLAY); root:SetDrawTier(DT_HIGH); root:SetDrawLevel(1458); root:SetMouseEnabled(false); root:SetHidden(true)
    KS.genericStackSlots = {}
    for index = 1, 6 do
        local slot = wm:CreateControl("UltiviteGenericSkillStackSlot" .. tostring(index), root, CT_CONTROL)
        slot:SetHidden(true); slot:SetMouseEnabled(false)
        local icon = wm:CreateControl("UltiviteGenericSkillStackIcon" .. tostring(index), slot, CT_TEXTURE)
        icon:SetAnchorFill(slot); icon:SetTextureCoords(0.04, 0.96, 0.04, 0.96); icon:SetMouseEnabled(false)
        local count = wm:CreateControl("UltiviteGenericSkillStackCount" .. tostring(index), slot, CT_LABEL)
        count:SetAnchorFill(slot); count:SetHorizontalAlignment(TEXT_ALIGN_CENTER); count:SetVerticalAlignment(TEXT_ALIGN_BOTTOM); count:SetColor(1,1,1,1); count:SetMouseEnabled(false)
        KS.genericStackSlots[index] = { control = slot, icon = icon, count = count }
    end

    local streakRoot = wm:CreateTopLevelWindow("UltiviteStreakFatigue")
    KS.streakFatigueRoot = streakRoot
    streakRoot:SetDrawLayer(DL_OVERLAY); streakRoot:SetDrawTier(DT_HIGH); streakRoot:SetDrawLevel(1459); streakRoot:SetMouseEnabled(false); streakRoot:SetHidden(true)
    local streakIcon = wm:CreateControl("UltiviteStreakFatigueIcon", streakRoot, CT_TEXTURE)
    KS.streakFatigueIcon = streakIcon
    streakIcon:SetAnchorFill(streakRoot); streakIcon:SetTextureCoords(0.04, 0.96, 0.04, 0.96); streakIcon:SetMouseEnabled(false)
    local streakCount = wm:CreateControl("UltiviteStreakFatigueCount", streakRoot, CT_LABEL)
    KS.streakFatigueCount = streakCount
    streakCount:SetAnchorFill(streakRoot); streakCount:SetHorizontalAlignment(TEXT_ALIGN_CENTER); streakCount:SetVerticalAlignment(TEXT_ALIGN_BOTTOM); streakCount:SetColor(1,1,1,1); streakCount:SetMouseEnabled(false)
    KS.ApplySkillStackTrackerLayout()
end

local function GetPreviewSlottedSkillSamples(maxCount)
    local samples = {}
    local streakSample = nil
    local firstSlot = tonumber(rawget(_G, "ACTION_BAR_FIRST_NORMAL_SLOT_INDEX")) or 3
    local lastSlot = tonumber(rawget(_G, "ACTION_BAR_LAST_WEAPON_SLOT_INDEX")) or 8
    for _, hotbar in ipairs(KS.GetReadableHotbarCategories()) do
        for slotIndex = firstSlot, lastSlot do
            local icon = type(GetSlotTexture) == "function" and tostring(GetSlotTexture(slotIndex, hotbar) or "") or ""
            local name = type(GetSlotName) == "function" and tostring(GetSlotName(slotIndex, hotbar) or "") or ""
            local abilityId = type(GetSlotBoundId) == "function" and (tonumber(GetSlotBoundId(slotIndex, hotbar)) or 0) or 0
            if icon ~= "" then
                local sample = { name = name, abilityId = abilityId, icon = icon, slotIndex = slotIndex, hotbar = hotbar }
                if isStreakSkillName(name) and not streakSample then streakSample = sample end
                if #samples < (tonumber(maxCount) or 3) then samples[#samples + 1] = sample end
            end
        end
    end
    return samples, streakSample
end

function KS.UpdateSkillStackTrackers(force)
    if not KS.sv then return end
    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if not force and nowMs > 0 and (nowMs - (tonumber(KS.skillStackLastScanMs) or 0)) < 200 then return end
    if nowMs > 0 then KS.skillStackLastScanMs = nowMs end
    local preview = IsQuickMenuPreviewing("skillStacks")
    local hudAllowed = preview or KS.IsHUDAllowed()
    local generic, streak = KS.CollectSlottedSkillStackState()
    if preview and #generic == 0 then
        local samples, streakSample = GetPreviewSlottedSkillSamples(3)
        generic = {
            { name = (samples[1] and samples[1].name) or "Stack Preview", abilityId = (samples[1] and samples[1].abilityId) or 0, stacks = 3, remainingMs = 6000, slotIndex = (samples[1] and samples[1].slotIndex) or 1, hotbar = (samples[1] and samples[1].hotbar) or 1, icon = (samples[1] and samples[1].icon) or "" },
            { name = (samples[2] and samples[2].name) or "Stack Preview", abilityId = (samples[2] and samples[2].abilityId) or 0, stacks = 5, remainingMs = 6000, slotIndex = (samples[2] and samples[2].slotIndex) or 2, hotbar = (samples[2] and samples[2].hotbar) or 1, icon = (samples[2] and samples[2].icon) or "" },
        }
        if not streak then
            local ss = streakSample or samples[3]
            streak = { name = (ss and ss.name) or "Streak Fatigue", abilityId = (ss and ss.abilityId) or 0, stacks = 2, remainingMs = 3000, slotIndex = (ss and ss.slotIndex) or 3, hotbar = (ss and ss.hotbar) or 1, icon = (ss and ss.icon) or "" }
        end
    end
    if preview and not streak then
        streak = { name = "Streak Fatigue", abilityId = 0, stacks = 2, remainingMs = 3000, slotIndex = 3, hotbar = 1, icon = "" }
    end
    local showGeneric = preview or (hudAllowed and KS.sv.showGenericStackTracker ~= false and #generic > 0)
    if KS.genericStackRoot then
        for index, slot in ipairs(KS.genericStackSlots or {}) do
            local entry = generic[index]
            if showGeneric and entry then
                local icon = tostring(entry.icon or "")
                if force or slot.lastIcon ~= icon then slot.lastIcon = icon; slot.icon:SetTexture(icon) end
                slot.icon:SetHidden(icon == "")
                local text = tostring(math.max(1, math.floor(tonumber(entry.stacks) or 1)))
                if force or slot.lastText ~= text then slot.lastText = text; slot.count:SetText(text) end
                slot.control:SetHidden(false)
            else
                slot.control:SetHidden(true)
            end
        end
        KS.genericStackRoot:SetHidden(not showGeneric)
    end
    local showStreak = preview or (hudAllowed and KS.sv.showStreakFatigueTracker ~= false and streak ~= nil)
    if KS.streakFatigueRoot then
        if showStreak then
            local icon = tostring(streak.icon or "")
            if force or KS.lastStreakFatigueIcon ~= icon then KS.lastStreakFatigueIcon = icon; KS.streakFatigueIcon:SetTexture(icon) end
            KS.streakFatigueIcon:SetHidden(icon == "")
            local text = tostring(math.max(1, math.floor(tonumber(streak.stacks) or 1)))
            if force or KS.lastStreakFatigueText ~= text then KS.lastStreakFatigueText = text; KS.streakFatigueCount:SetText(text) end
        end
        KS.streakFatigueRoot:SetHidden(not showStreak)
    end
end

function KS.PrintSkillStackDiagnostic()
    local generic, streak = KS.CollectSlottedSkillStackState()
    chat(string.format("Generic slotted stack entries: %d", #generic))
    for index, entry in ipairs(generic) do
        chat(string.format("STACK[%d] name=%s id=%s stacks=%s remainingMs=%s slot=%s hotbar=%s", index, tostring(entry.name), tostring(entry.abilityId), tostring(entry.stacks), tostring(entry.remainingMs), tostring(entry.slotIndex), tostring(entry.hotbar)))
    end
    if streak then
        chat(string.format("STREAK name=%s id=%s fatigue=%s remainingMs=%s slot=%s hotbar=%s", tostring(streak.name), tostring(streak.abilityId), tostring(streak.stacks), tostring(streak.remainingMs), tostring(streak.slotIndex), tostring(streak.hotbar)))
    else
        chat("STREAK: no active slotted Streak fatigue effect reported by ESO.")
    end
end

function KS.RefreshResourceDangerValues()
    KS.resourceDangerValues = KS.resourceDangerValues or {}
    if type(GetUnitPower) ~= "function" then return end
    for _, powerType in ipairs({ COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA }) do
        local current, maximum, effectiveMaximum = GetUnitPower("player", powerType)
        KS.resourceDangerValues[powerType] = { current = tonumber(current) or 0, maximum = tonumber(effectiveMaximum) or tonumber(maximum) or 0 }
    end
end

function KS.ApplyResourceDangerLayout()
    if not KS.sv or not KS.resourceDangerRoot then return end
    local x = clamp(math.floor(tonumber(KS.sv.resourceDangerX) or defaults.resourceDangerX), -800, 800)
    local y = clamp(math.floor(tonumber(KS.sv.resourceDangerY) or defaults.resourceDangerY), -500, 500)
    local size = clamp(math.floor(tonumber(KS.sv.resourceDangerFontSize) or defaults.resourceDangerFontSize), 16, 38)
    KS.sv.resourceDangerX, KS.sv.resourceDangerY, KS.sv.resourceDangerFontSize = x, y, size
    KS.resourceDangerRoot:ClearAnchors(); KS.resourceDangerRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    for _, label in pairs(KS.resourceDangerLabels or {}) do label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", size)) end
end

function KS.CreateResourceDangerHud()
    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow("UltiviteResourceDanger")
    KS.resourceDangerRoot = root
    root:SetDimensions(330, 42); root:SetDrawLayer(DL_OVERLAY); root:SetDrawTier(DT_HIGH); root:SetDrawLevel(1456); root:SetMouseEnabled(false); root:SetHidden(true)
    KS.resourceDangerLabels = {}
    local defs = {
        { power = COMBAT_MECHANIC_FLAGS_HEALTH, x = -110, r = 1.0, g = 0.25, b = 0.20 },
        { power = COMBAT_MECHANIC_FLAGS_MAGICKA, x = 0, r = 0.35, g = 0.62, b = 1.0 },
        { power = COMBAT_MECHANIC_FLAGS_STAMINA, x = 110, r = 0.35, g = 1.0, b = 0.42 },
    }
    for index, def in ipairs(defs) do
        local label = wm:CreateControl("UltiviteResourceDangerLabel" .. tostring(index), root, CT_LABEL)
        label:SetDimensions(100, 42); label:SetAnchor(CENTER, root, CENTER, def.x, 0); label:SetHorizontalAlignment(TEXT_ALIGN_CENTER); label:SetVerticalAlignment(TEXT_ALIGN_CENTER); label:SetColor(def.r, def.g, def.b, 1); label:SetMouseEnabled(false); label:SetHidden(true)
        KS.resourceDangerLabels[def.power] = label
    end
    KS.ApplyResourceDangerLayout()
    KS.RefreshResourceDangerValues()
end

function KS.OnPlayerPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" then return end
    if powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH and powerType ~= COMBAT_MECHANIC_FLAGS_MAGICKA and powerType ~= COMBAT_MECHANIC_FLAGS_STAMINA then return end
    KS.resourceDangerValues = KS.resourceDangerValues or {}
    KS.resourceDangerValues[powerType] = { current = tonumber(powerValue) or 0, maximum = tonumber(powerEffectiveMax) or tonumber(powerMax) or 0 }
    KS.UpdateResourceDangerHud(false)
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        KS.OnCombatDangerHealthUpdate(tonumber(powerValue) or 0, tonumber(powerEffectiveMax) or tonumber(powerMax) or 0)
    end
end

function KS.UpdateResourceDangerHud(force)
    if not KS.sv or not KS.resourceDangerRoot then return end
    local preview = IsQuickMenuPreviewing("resourceDanger")
    if not preview and (KS.sv.showResourceDanger == false or not KS.IsHUDAllowed() or (IsUnitDead and IsUnitDead("player"))) then
        KS.resourceDangerRoot:SetHidden(true)
        return
    end
    local thresholds = {
        [COMBAT_MECHANIC_FLAGS_HEALTH] = clamp(tonumber(KS.sv.resourceDangerHealthPct) or defaults.resourceDangerHealthPct, 10, 70),
        [COMBAT_MECHANIC_FLAGS_MAGICKA] = clamp(tonumber(KS.sv.resourceDangerMagickaPct) or defaults.resourceDangerMagickaPct, 5, 60),
        [COMBAT_MECHANIC_FLAGS_STAMINA] = clamp(tonumber(KS.sv.resourceDangerStaminaPct) or defaults.resourceDangerStaminaPct, 5, 60),
    }
    local any = false
    local previewValues = {
        [COMBAT_MECHANIC_FLAGS_HEALTH] = 35,
        [COMBAT_MECHANIC_FLAGS_MAGICKA] = 20,
        [COMBAT_MECHANIC_FLAGS_STAMINA] = 50,
    }
    for powerType, label in pairs(KS.resourceDangerLabels or {}) do
        local v = KS.resourceDangerValues and KS.resourceDangerValues[powerType] or nil
        local maximum = v and tonumber(v.maximum) or 0
        local pct = preview and (previewValues[powerType] or thresholds[powerType]) or (maximum > 0 and ((tonumber(v.current) or 0) * 100 / maximum) or 100)
        local show = preview or (pct > 0 and pct <= thresholds[powerType])
        if show then
            any = true
            local text = tostring(math.floor(pct + 0.5)) .. "%"
            if force or label.lastText ~= text then label.lastText = text; label:SetText(text) end
            label:SetHidden(false)
        else
            label:SetHidden(true)
        end
    end
    KS.resourceDangerRoot:SetHidden(not any)
    if any then
        local health = KS.resourceDangerLabels[COMBAT_MECHANIC_FLAGS_HEALTH]
        if health and not health:IsHidden() then
            local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
            local alpha = 0.70 + 0.30 * ((math.sin(now * 7) + 1) * 0.5)
            health:SetAlpha(alpha)
        elseif health then
            health:SetAlpha(1)
        end
    end
end

local COMBAT_DANGER_TRANSIENT_MS = 1400

function KS.ApplyCombatDangerLayout()
    if not KS.sv or not KS.combatDangerRoot then return end
    local x = clamp(math.floor(tonumber(KS.sv.combatDangerX) or defaults.combatDangerX), -800, 800)
    local y = clamp(math.floor(tonumber(KS.sv.combatDangerY) or defaults.combatDangerY), -500, 500)
    local fontSize = clamp(math.floor(tonumber(KS.sv.combatDangerFontSize) or defaults.combatDangerFontSize), 22, 42)
    KS.sv.combatDangerX = x
    KS.sv.combatDangerY = y
    KS.sv.combatDangerFontSize = fontSize
    KS.combatDangerRoot:ClearAnchors()
    KS.combatDangerRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    for _, label in ipairs(KS.combatDangerLabels or {}) do
        label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize))
    end
end

function KS.CreateCombatDangerWarnings()
    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow("UltiviteCombatDangerWarnings")
    KS.combatDangerRoot = root
    root:SetDimensions(620, 132)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLevel(1465)
    root:SetMouseEnabled(false)
    root:SetHidden(true)

    KS.combatDangerLabels = {}
    for index = 1, 3 do
        local label = wm:CreateControl("UltiviteCombatDangerWarningLabel" .. tostring(index), root, CT_LABEL)
        label:SetDimensions(620, 42)
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetMouseEnabled(false)
        label:SetHidden(true)
        KS.combatDangerLabels[index] = label
    end
    KS.ApplyCombatDangerLayout()
end

function KS.ResetBurstDamageHistory()
    KS.healthBurstSamples = {}
    if type(GetUnitPower) == "function" and KS.IsPlayerInCombat() then
        local current, maximum, effectiveMaximum = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
        maximum = tonumber(effectiveMaximum) or tonumber(maximum) or 0
        current = tonumber(current) or 0
        if maximum > 0 and current > 0 then
            local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            KS.healthBurstSamples[1] = { at = nowMs, pct = current / maximum }
        end
    end
end

function KS.TriggerShieldBrokenWarning()
    if not KS.sv or KS.sv.showShieldBrokenWarning == false then return end
    if not KS.IsPlayerInCombat() then return end
    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if nowMs > 0 and (nowMs - (tonumber(KS.lastShieldBreakTriggerAtMs) or 0)) < 250 then return end
    KS.lastShieldBreakTriggerAtMs = nowMs
    KS.shieldBreakExpiresAtMs = nowMs + COMBAT_DANGER_TRANSIENT_MS
    KS.UpdateCombatDangerWarnings(true)
end

function KS.TriggerBurstDamageWarning()
    if not KS.sv or KS.sv.showBurstDamageWarning == false then return end
    if not KS.IsPlayerInCombat() then return end
    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    KS.lastBurstDamageTriggerAtMs = nowMs
    KS.burstDamageExpiresAtMs = nowMs + COMBAT_DANGER_TRANSIENT_MS
    KS.UpdateCombatDangerWarnings(true)
end

function KS.OnCombatDangerHealthUpdate(current, maximum)
    if not KS.sv then return end
    current = math.max(0, tonumber(current) or 0)
    maximum = math.max(0, tonumber(maximum) or 0)
    if maximum <= 0 then return end

    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if not KS.IsPlayerInCombat() or current <= 0 then
        KS.healthBurstSamples = {}
        KS.UpdateCombatDangerWarnings(false)
        return
    end

    local pct = current / maximum
    local windowMs = clamp(math.floor(tonumber(KS.sv.burstDamageWindowMs) or defaults.burstDamageWindowMs), 300, 1500)
    local cutoff = nowMs - windowMs
    local samples = KS.healthBurstSamples or {}
    local kept = {}
    local peakPct = pct
    for _, sample in ipairs(samples) do
        local at = tonumber(sample.at) or 0
        local samplePct = tonumber(sample.pct) or pct
        if at >= cutoff then
            kept[#kept + 1] = sample
            if samplePct > peakPct then peakPct = samplePct end
        end
    end
    kept[#kept + 1] = { at = nowMs, pct = pct }
    while #kept > 40 do table.remove(kept, 1) end
    KS.healthBurstSamples = kept

    if KS.sv.showBurstDamageWarning ~= false then
        local requiredDrop = clamp(tonumber(KS.sv.burstDamagePct) or defaults.burstDamagePct, 20, 60) / 100
        local drop = peakPct - pct
        local cooldownMs = math.max(1000, windowMs)
        if drop >= requiredDrop and (nowMs - (tonumber(KS.lastBurstDamageTriggerAtMs) or 0)) >= cooldownMs then
            KS.TriggerBurstDamageWarning()
        end
    end

    KS.UpdateCombatDangerWarnings(false)
end

function KS.GetDangerWarningMode(kind)
    if not KS.sv then return "off" end
    local boolKey = kind == "burst" and "showBurstDamageWarning" or "showExecuteDangerWarning"
    local modeKey = kind == "burst" and "burstDamageWarningMode" or "executeDangerWarningMode"
    if KS.sv[boolKey] == false then return "off" end
    local mode = tostring(KS.sv[modeKey] or "always")
    if mode == "pvp" then return "pvp" end
    return "always"
end

function KS.SetDangerWarningMode(kind, mode, silent)
    if not KS.sv then return end
    local boolKey = kind == "burst" and "showBurstDamageWarning" or "showExecuteDangerWarning"
    local modeKey = kind == "burst" and "burstDamageWarningMode" or "executeDangerWarningMode"
    mode = tostring(mode or "off")
    if mode ~= "pvp" and mode ~= "always" then mode = "off" end
    KS.sv[boolKey] = mode ~= "off"
    KS.sv[modeKey] = mode == "off" and "always" or mode
    if mode == "off" then
        if kind == "burst" then KS.burstDamageExpiresAtMs = 0 end
    end
    KS.UpdateCombatDangerWarnings(true)
    if Ultivite and U.RequestSettingsSave then U.RequestSettingsSave(true) end
    if not silent then chat(string.format("%s warning: %s", kind == "burst" and "Burst damage" or "Execute danger", string.upper(mode))) end
end

function KS.IsDangerWarningActive(kind)
    local mode = KS.GetDangerWarningMode(kind)
    if mode == "off" then return false end
    if mode == "pvp" then
        return U and U.Frames and U.Frames.IsPvpUiContext and U.Frames.IsPvpUiContext() or false
    end
    return true
end

function KS.UpdateCombatDangerWarnings(force)
    if not KS.sv or not KS.combatDangerRoot then return end
    local allowed = KS.IsHUDAllowed() and KS.IsPlayerInCombat() and not (IsUnitDead and IsUnitDead("player"))
    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    local messages = {}
    local previewBurst = IsQuickMenuPreviewing("burst")
    local previewExecute = IsQuickMenuPreviewing("execute")
    local previewShield = IsQuickMenuPreviewing("shield")

    if previewBurst then
        messages[#messages + 1] = { text = "BURST DAMAGE", r = 1.0, g = 0.12, b = 0.08 }
    elseif previewExecute then
        messages[#messages + 1] = { text = "EXECUTE DANGER", r = 1.0, g = 0.18, b = 0.16 }
    elseif previewShield and KS.sv.showShieldBrokenWarning ~= false then
        messages[#messages + 1] = { text = "SHIELD BROKEN", r = 1.0, g = 0.34, b = 0.10 }
    end

    local liveWarnings = not (previewBurst or previewExecute or previewShield)
    if liveWarnings and allowed and KS.sv.showShieldBrokenWarning ~= false and (tonumber(KS.shieldBreakExpiresAtMs) or 0) > nowMs then
        messages[#messages + 1] = { text = "SHIELD BROKEN", r = 1.0, g = 0.34, b = 0.10 }
    end
    if liveWarnings and allowed and KS.IsDangerWarningActive("burst") and (tonumber(KS.burstDamageExpiresAtMs) or 0) > nowMs then
        messages[#messages + 1] = { text = "BURST DAMAGE", r = 1.0, g = 0.12, b = 0.08 }
    end

    if liveWarnings and allowed and KS.IsDangerWarningActive("execute") then
        local v = KS.resourceDangerValues and KS.resourceDangerValues[COMBAT_MECHANIC_FLAGS_HEALTH] or nil
        local maximum = v and tonumber(v.maximum) or 0
        local current = v and tonumber(v.current) or 0
        local pct = maximum > 0 and (current * 100 / maximum) or 100
        local threshold = clamp(tonumber(KS.sv.executeDangerHealthPct) or defaults.executeDangerHealthPct, 10, 50)
        if current > 0 and pct <= threshold then
            messages[#messages + 1] = { text = "EXECUTE DANGER", r = 1.0, g = 0.18, b = 0.16 }
        end
    end

    local keyParts = {}
    for i, message in ipairs(messages) do keyParts[i] = message.text end
    local renderKey = table.concat(keyParts, "|")
    if force or KS.lastCombatDangerRenderKey ~= renderKey then
        KS.lastCombatDangerRenderKey = renderKey
        local count = #messages
        local spacing = 40
        for index, label in ipairs(KS.combatDangerLabels or {}) do
            local message = messages[index]
            if message then
                local y = (index - ((count + 1) / 2)) * spacing
                label:ClearAnchors()
                label:SetAnchor(CENTER, KS.combatDangerRoot, CENTER, 0, y)
                label:SetText(message.text)
                label:SetColor(message.r, message.g, message.b, 1)
                label:SetHidden(false)
            else
                label:SetHidden(true)
            end
        end
    end
    KS.combatDangerRoot:SetHidden(#messages == 0)
end

function KS.PrintCombatDangerDiagnostic()
    local v = KS.resourceDangerValues and KS.resourceDangerValues[COMBAT_MECHANIC_FLAGS_HEALTH] or nil
    local current = v and tonumber(v.current) or 0
    local maximum = v and tonumber(v.maximum) or 0
    local pct = maximum > 0 and (current * 100 / maximum) or 0
    chat(string.format(
        "Danger diag: health=%d/%d %.1f%% execute=%s%% | burst=%s%%/%sms samples=%d | shield=%d lastShieldDamageMs=%s",
        current,
        maximum,
        pct,
        tostring(KS.sv and KS.sv.executeDangerHealthPct or defaults.executeDangerHealthPct),
        tostring(KS.sv and KS.sv.burstDamagePct or defaults.burstDamagePct),
        tostring(KS.sv and KS.sv.burstDamageWindowMs or defaults.burstDamageWindowMs),
        #(KS.healthBurstSamples or {}),
        tonumber(KS.lastKnownShieldValue) or 0,
        tostring(KS.lastShieldDamageAtMs or 0)
    ))
end

function KS.ApplyImportantTargetDebuffLayout()
    if not KS.sv or not KS.targetDebuffRoot then return end
    local size = clamp(math.floor(tonumber(KS.sv.targetDebuffIconSize) or defaults.targetDebuffIconSize), 30, 64)
    local maxIcons = clamp(math.floor(tonumber(KS.sv.targetDebuffMaxIcons) or defaults.targetDebuffMaxIcons), 3, 12)
    local x = clamp(math.floor(tonumber(KS.sv.targetDebuffX) or defaults.targetDebuffX), -800, 800)
    local y = clamp(math.floor(tonumber(KS.sv.targetDebuffY) or defaults.targetDebuffY), -500, 500)
    local gap = 5
    KS.sv.targetDebuffIconSize, KS.sv.targetDebuffMaxIcons, KS.sv.targetDebuffX, KS.sv.targetDebuffY = size, maxIcons, x, y
    KS.targetDebuffRoot:SetDimensions((size * maxIcons) + gap * math.max(0, maxIcons - 1), size)
    KS.targetDebuffRoot:ClearAnchors(); KS.targetDebuffRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
    for index, slot in ipairs(KS.targetDebuffSlots or {}) do
        slot.control:SetDimensions(size, size); slot.control:ClearAnchors(); slot.control:SetAnchor(LEFT, KS.targetDebuffRoot, LEFT, (index - 1) * (size + gap), 0)
        slot.countdown:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", clamp(math.floor(size * 0.45), 15, 30)))
    end
end

function KS.CreateImportantTargetDebuffHud()
    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow("UltiviteImportantTargetDebuffs")
    KS.targetDebuffRoot = root
    root:SetDrawLayer(DL_OVERLAY); root:SetDrawTier(DT_HIGH); root:SetDrawLevel(1455); root:SetMouseEnabled(false); root:SetHidden(true)
    KS.targetDebuffSlots = {}
    for index = 1, 12 do
        local slot = wm:CreateControl("UltiviteImportantTargetDebuffSlot" .. tostring(index), root, CT_CONTROL)
        slot:SetHidden(true); slot:SetMouseEnabled(false)
        local icon = wm:CreateControl("UltiviteImportantTargetDebuffIcon" .. tostring(index), slot, CT_TEXTURE)
        icon:SetAnchorFill(slot); icon:SetTextureCoords(0.04,0.96,0.04,0.96); icon:SetMouseEnabled(false)
        local countdown = wm:CreateControl("UltiviteImportantTargetDebuffCountdown" .. tostring(index), slot, CT_LABEL)
        countdown:SetAnchorFill(slot); countdown:SetHorizontalAlignment(TEXT_ALIGN_CENTER); countdown:SetVerticalAlignment(TEXT_ALIGN_BOTTOM); countdown:SetColor(1,1,1,1); countdown:SetMouseEnabled(false)
        KS.targetDebuffSlots[index] = { control = slot, icon = icon, countdown = countdown }
    end
    KS.targetDebuffAuras = KS.targetDebuffAuras or {}
    KS.ApplyImportantTargetDebuffLayout()
end

function KS.UpdateImportantTargetDebuffs(force)
    if not KS.sv or not KS.targetDebuffRoot then return end
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local maxIcons = clamp(math.floor(tonumber(KS.sv.targetDebuffMaxIcons) or defaults.targetDebuffMaxIcons), 3, 12)
    local active = {}
    if KS.sv.showImportantTargetDebuffs ~= false then
        for _, aura in ipairs(KS.targetDebuffAuras or {}) do
            if (tonumber(aura.endTime) or 0) > now then active[#active + 1] = aura; if #active >= maxIcons then break end end
        end
    end
    local previewDebuffs = IsQuickMenuPreviewing("debuffs")
    if previewDebuffs and #active == 0 then
        active[1] = { name = "Major Breach", abilityId = 0, beginTime = now, endTime = now + 8, icon = "" }
        active[2] = { name = "Poisoned", abilityId = 0, beginTime = now, endTime = now + 4, icon = "" }
    end
    local showRoot = previewDebuffs or (KS.IsHUDAllowed() and KS.sv.showImportantTargetDebuffs ~= false and #active > 0)
    for index, slot in ipairs(KS.targetDebuffSlots or {}) do
        local aura = active[index]
        if showRoot and aura then
            local icon = tostring(aura.icon or "")
            if force or slot.lastIcon ~= icon then slot.lastIcon = icon; slot.icon:SetTexture(icon) end
            slot.icon:SetHidden(icon == "")
            local remaining = math.max(0, (tonumber(aura.endTime) or 0) - now)
            local text = tostring(math.max(1, math.ceil(remaining - 0.001)))
            if force or slot.lastText ~= text then slot.lastText = text; slot.countdown:SetText(text) end
            slot.control:SetHidden(false)
        else
            slot.control:SetHidden(true)
        end
    end
    KS.targetDebuffRoot:SetHidden(not showRoot)
end

function KS.PrintImportantTargetDebuffDiagnostic()
    KS.ScanTargetAuras()
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    chat(string.format("Important target debuffs: %d", #(KS.targetDebuffAuras or {})))
    for index, aura in ipairs(KS.targetDebuffAuras or {}) do
        chat(string.format("TARGETDEBUFF[%d] name=%s id=%s remaining=%.1f status=%s icon=%s", index, tostring(aura.name), tostring(aura.abilityId), math.max(0,(tonumber(aura.endTime) or 0)-now), tostring(aura.statusEffectType), tostring(aura.icon)))
    end
end

local LIVE_STAT_CONFIG = {
    damage = {
        rootName = "UltiviteLiveDamage",
        xKey = "liveDamageX",
        yKey = "liveDamageY",
        enabledKey = "showLiveDamageStat",
        defaultX = -150,
        defaultY = -255,
    },
    front = {
        rootName = "UltiviteLiveFrontResistance",
        xKey = "liveFrontResistanceX",
        yKey = "liveFrontResistanceY",
        enabledKey = "showFrontResistanceStat",
        defaultX = 0,
        defaultY = -255,
    },
    back = {
        rootName = "UltiviteLiveBackResistance",
        xKey = "liveBackResistanceX",
        yKey = "liveBackResistanceY",
        enabledKey = "showBackResistanceStat",
        defaultX = 150,
        defaultY = -255,
    },
    shield = {
        rootName = "UltiviteLiveDamageShield",
        xKey = "liveShieldX",
        yKey = "liveShieldY",
        enabledKey = "showDamageShieldStat",
        defaultX = 300,
        defaultY = -255,
    },
}

function KS.GetSafePlayerStat(statConstant)
    if type(GetPlayerStat) ~= "function" or type(statConstant) ~= "number" then
        return 0
    end
    local ok, value = pcall(GetPlayerStat, statConstant)
    if not ok then return 0 end
    return math.max(0, tonumber(value) or 0)
end

function KS.GetCurrentDamageStat()
    -- A single number was requested for "weapon / spell damage". Use the higher
    -- current value so the widget remains useful on hybridized builds.
    local weaponStat = rawget(_G, "STAT_WEAPON_POWER")
    local spellStat = rawget(_G, "STAT_SPELL_POWER")
    local weaponDamage = KS.GetSafePlayerStat(weaponStat)
    local spellDamage = KS.GetSafePlayerStat(spellStat)
    return math.max(weaponDamage, spellDamage), weaponDamage, spellDamage
end

function KS.GetCurrentResistanceStat()
    -- One resistance number per weapon bar: use the lower of Physical and Spell
    -- Resistance so the display represents the character's weaker mitigation.
    local physicalStat = rawget(_G, "STAT_PHYSICAL_RESIST") or rawget(_G, "STAT_PHYSICAL_RESISTANCE")
    local spellStat = rawget(_G, "STAT_SPELL_RESIST") or rawget(_G, "STAT_SPELL_RESISTANCE")
    local physical = KS.GetSafePlayerStat(physicalStat)
    local spell = KS.GetSafePlayerStat(spellStat)

    local resistance = 0
    if physical > 0 and spell > 0 then
        resistance = math.min(physical, spell)
    else
        resistance = math.max(physical, spell)
    end
    return resistance, physical, spell
end

function KS.GetCurrentDamageShieldValue()
    if type(GetUnitAttributeVisualizerEffectInfo) ~= "function" then return 0 end
    if not ATTRIBUTE_VISUAL_POWER_SHIELDING or not STAT_MITIGATION or not ATTRIBUTE_HEALTH or not COMBAT_MECHANIC_FLAGS_HEALTH then return 0 end
    local ok, value = pcall(GetUnitAttributeVisualizerEffectInfo, "player", ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    if not ok then return 0 end
    return math.max(0, tonumber(value) or 0)
end

function KS.GetCurrentWeaponPairForStats()
    if type(GetActiveWeaponPairInfo) == "function" then
        local ok, pair = pcall(GetActiveWeaponPairInfo)
        if ok then return pair end
    end

    if type(GetActiveHotbarCategory) == "function" then
        local ok, hotbar = pcall(GetActiveHotbarCategory)
        if ok then
            if hotbar == HOTBAR_CATEGORY_BACKUP then return ACTIVE_WEAPON_PAIR_BACKUP end
            if hotbar == HOTBAR_CATEGORY_PRIMARY then return ACTIVE_WEAPON_PAIR_MAIN end
        end
    end

    return ACTIVE_WEAPON_PAIR_MAIN
end

function KS.SaveLiveStatPosition(key)
    if not KS.sv then return end
    local config = LIVE_STAT_CONFIG[key]
    local widget = KS.liveStatWidgets and KS.liveStatWidgets[key]
    local root = widget and widget.root
    if not config or not root or not root.GetCenter or not GuiRoot or not GuiRoot.GetCenter then return end

    local cx, cy = root:GetCenter()
    local gx, gy = GuiRoot:GetCenter()
    if not cx or not cy or not gx or not gy then return end

    KS.sv[config.xKey] = zo_round(cx - gx)
    KS.sv[config.yKey] = zo_round(cy - gy)

    if RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave("Ultivite")
    end
end

function KS.ApplyLiveStatPosition(key)
    if not KS.sv then return end
    local config = LIVE_STAT_CONFIG[key]
    local widget = KS.liveStatWidgets and KS.liveStatWidgets[key]
    local root = widget and widget.root
    if not config or not root then return end

    local x = clamp(math.floor(tonumber(KS.sv[config.xKey]) or config.defaultX), -900, 900)
    local y = clamp(math.floor(tonumber(KS.sv[config.yKey]) or config.defaultY), -520, 520)
    KS.sv[config.xKey] = x
    KS.sv[config.yKey] = y

    root:ClearAnchors()
    root:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

function KS.ApplyLiveStatWidgetAppearance()
    if not KS.sv then return end
    local fontSize = clamp(math.floor(tonumber(KS.sv.liveStatFontSize) or defaults.liveStatFontSize), 16, 42)
    KS.sv.liveStatFontSize = fontSize

    for key, widget in pairs(KS.liveStatWidgets or {}) do
        if widget and widget.label then
            widget.label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", fontSize))
            widget.label:SetColor(1, 1, 1, 1)
        end
        KS.ApplyLiveStatPosition(key)
    end
end

function KS.GetLiveStatMousePosition()
    if type(GetUIMousePosition) == "function" then
        local x, y = GetUIMousePosition()
        if x ~= nil and y ~= nil then return tonumber(x), tonumber(y) end
    end
    if GuiMouse and GuiMouse.GetCenter then
        local x, y = GuiMouse:GetCenter()
        if x ~= nil and y ~= nil then return tonumber(x), tonumber(y) end
    end
    return nil, nil
end

function KS.EnsureLiveStatDragCapture()
    if KS.liveStatDragCapture then return KS.liveStatDragCapture end
    local capture = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteLiveStatDragCapture")
    capture:SetAnchorFill(GuiRoot)
    capture:SetDrawLayer(DL_OVERLAY)
    capture:SetDrawTier(DT_HIGH)
    capture:SetDrawLevel(2000)
    capture:SetMouseEnabled(true)
    capture:SetHidden(true)
    capture:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            KS.EndLiveStatDrag()
        end
    end)
    KS.liveStatDragCapture = capture
    return capture
end

function KS.UpdateLiveStatDrag()
    local state = KS.liveStatDragState
    if not state or not KS.sv then return end
    local config = LIVE_STAT_CONFIG[state.key]
    if not config then return end
    local mouseX, mouseY = KS.GetLiveStatMousePosition()
    if not mouseX or not mouseY then return end

    local x = clamp(zo_round(state.startX + (mouseX - state.mouseX)), -900, 900)
    local y = clamp(zo_round(state.startY + (mouseY - state.mouseY)), -520, 520)
    KS.sv[config.xKey] = x
    KS.sv[config.yKey] = y
    KS.ApplyLiveStatPosition(state.key)
end

function KS.BeginLiveStatDrag(key)
    if KS.liveStatDragState or not KS.sv then return end
    local config = LIVE_STAT_CONFIG[key]
    local widget = KS.liveStatWidgets and KS.liveStatWidgets[key]
    if not config or not widget or not widget.root or widget.root:IsHidden() then return end

    local mouseX, mouseY = KS.GetLiveStatMousePosition()
    if not mouseX or not mouseY then return end

    KS.liveStatDragState = {
        key = key,
        mouseX = mouseX,
        mouseY = mouseY,
        startX = tonumber(KS.sv[config.xKey]) or config.defaultX,
        startY = tonumber(KS.sv[config.yKey]) or config.defaultY,
    }

    local capture = KS.EnsureLiveStatDragCapture()
    capture:SetMouseEnabled(true)
    capture:SetHidden(false)
    EVENT_MANAGER:UnregisterForUpdate(KS.name .. "LiveStatDrag")
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "LiveStatDrag", 8, function()
        KS.UpdateLiveStatDrag()
    end)
end

function KS.EndLiveStatDrag()
    local state = KS.liveStatDragState
    if state then KS.UpdateLiveStatDrag() end
    EVENT_MANAGER:UnregisterForUpdate(KS.name .. "LiveStatDrag")
    if KS.liveStatDragCapture then
        KS.liveStatDragCapture:SetMouseEnabled(false)
        KS.liveStatDragCapture:SetHidden(true)
    end
    KS.liveStatDragState = nil
    if state then KS.SaveLiveStatPosition(state.key) end
end

function KS.CreateLiveStatWidget(key)
    local config = LIVE_STAT_CONFIG[key]
    if not config then return nil end
    KS.liveStatWidgets = KS.liveStatWidgets or {}
    if KS.liveStatWidgets[key] then return KS.liveStatWidgets[key] end

    local wm = WINDOW_MANAGER
    local root = wm:CreateTopLevelWindow(config.rootName)
    -- Give preview/edit mode a generous hit area without making the displayed
    -- number itself visually larger. Outside preview the hit area is disabled
    -- so transparent HUD controls cannot block stock UI mouse interaction.
    root:SetDimensions(156, 56)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLevel(1460)
    root:SetClampedToScreen(true)
    root:SetMovable(false)
    root:SetMouseEnabled(false)
    root:SetHidden(false)

    local dragger = wm:CreateControl(config.rootName .. "Dragger", root, CT_BACKDROP)
    dragger:SetAnchorFill(root)
    dragger:SetCenterColor(0, 0, 0, 0)
    dragger:SetEdgeColor(0, 0, 0, 0)
    dragger:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    dragger:SetMouseEnabled(false)

    local label = wm:CreateControl(config.rootName .. "Label", root, CT_LABEL)
    label:SetAnchorFill(root)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(1, 1, 1, 1)
    label:SetText("0")
    label:SetMouseEnabled(false)

    local function beginMove(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            KS.BeginLiveStatDrag(key)
        end
    end

    local function endMove(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            KS.EndLiveStatDrag()
        end
    end

    local function showGrabHighlight()
        dragger:SetCenterColor(0.02, 0.03, 0.04, 0.18)
        dragger:SetEdgeColor(0.78, 0.90, 1.00, 0.82)
    end

    local function hideGrabHighlight()
        dragger:SetCenterColor(0, 0, 0, 0)
        dragger:SetEdgeColor(0, 0, 0, 0)
    end

    dragger:SetHandler("OnMouseDown", beginMove)
    dragger:SetHandler("OnMouseUp", endMove)
    dragger:SetHandler("OnMouseEnter", showGrabHighlight)
    dragger:SetHandler("OnMouseExit", hideGrabHighlight)
    root:SetHandler("OnMouseDown", beginMove)
    root:SetHandler("OnMouseUp", endMove)

    KS.liveStatWidgets[key] = { root = root, label = label, dragger = dragger }
    KS.ApplyLiveStatPosition(key)
    KS.ApplyLiveStatWidgetAppearance()
    return KS.liveStatWidgets[key]
end

function KS.CreateLiveStatWidgets()
    KS.CreateLiveStatWidget("damage")
    KS.CreateLiveStatWidget("front")
    KS.CreateLiveStatWidget("back")
    KS.CreateLiveStatWidget("shield")
    KS.UpdateLiveStatWidgets(true)
end

function KS.ResetLiveStatPositions()
    if not KS.sv then return end
    KS.sv.liveDamageX = defaults.liveDamageX
    KS.sv.liveDamageY = defaults.liveDamageY
    KS.sv.liveFrontResistanceX = defaults.liveFrontResistanceX
    KS.sv.liveFrontResistanceY = defaults.liveFrontResistanceY
    KS.sv.liveBackResistanceX = defaults.liveBackResistanceX
    KS.sv.liveBackResistanceY = defaults.liveBackResistanceY
    KS.sv.liveShieldX = defaults.liveShieldX
    KS.sv.liveShieldY = defaults.liveShieldY
    KS.ApplyLiveStatWidgetAppearance()
    chat("Live stat positions reset: Damage, Front Resistance, Back Resistance, Damage Shield.")
end

function KS.UpdateLiveStatWidgets(force)
    if not KS.sv then return end
    if not KS.liveStatWidgets or not KS.liveStatWidgets.damage then return end

    local damage = KS.GetCurrentDamageStat()
    local resistance = KS.GetCurrentResistanceStat()
    local pair = KS.GetCurrentWeaponPairForStats()

    -- Seed both sides on first load so the HUD never starts with a meaningless 0.
    -- Each side becomes exact as soon as that weapon bar has been visited.
    if KS.frontResistanceValue == nil and KS.backResistanceValue == nil then
        KS.frontResistanceValue = resistance
        KS.backResistanceValue = resistance
    end

    if pair == ACTIVE_WEAPON_PAIR_BACKUP then
        KS.backResistanceValue = resistance
    else
        KS.frontResistanceValue = resistance
    end

    local shield = KS.GetCurrentDamageShieldValue()
    KS.lastKnownShieldValue = tonumber(shield) or 0
    local previewStats = IsQuickMenuPreviewing("stats")
    local previewShield = IsQuickMenuPreviewing("shield")
    local values = {
        damage = damage,
        front = tonumber(KS.frontResistanceValue) or resistance,
        back = tonumber(KS.backResistanceValue) or resistance,
        shield = previewShield and 12500 or shield,
    }

    for key, widget in pairs(KS.liveStatWidgets) do
        local config = LIVE_STAT_CONFIG[key]
        if config and widget and widget.root and widget.label then
            local previewVisible = (previewStats and key ~= "shield") or (previewShield and key == "shield")
            local interactive = previewVisible
            widget.root:SetMovable(interactive)
            widget.root:SetMouseEnabled(interactive)
            if widget.dragger then widget.dragger:SetMouseEnabled(interactive) end
            local enabled = KS.sv[config.enabledKey] ~= false
            local visible = previewVisible or (enabled and (key ~= "shield" or (tonumber(values.shield) or 0) > 0))
            widget.root:SetHidden(not visible)
            if visible then
                local value = math.max(0, math.floor((tonumber(values[key]) or 0) + 0.5))
                local text = tostring(value)
                if force or widget.lastText ~= text then
                    widget.lastText = text
                    widget.label:SetText(text)
                end
            end
        end
    end
end

function KS.PrintLiveStatDiagnostic()
    local damage, weaponDamage, spellDamage = KS.GetCurrentDamageStat()
    local resistance, physical, spell = KS.GetCurrentResistanceStat()
    local pair = KS.GetCurrentWeaponPairForStats()
    local shield = KS.GetCurrentDamageShieldValue()
    chat(string.format(
        "Live stats: damage=%d weapon=%d spell=%d | resistance=%d physical=%d spellResist=%d | pair=%s | front=%s back=%s | shield=%d",
        tonumber(damage) or 0,
        tonumber(weaponDamage) or 0,
        tonumber(spellDamage) or 0,
        tonumber(resistance) or 0,
        tonumber(physical) or 0,
        tonumber(spell) or 0,
        tostring(pair),
        tostring(KS.frontResistanceValue or "unset"),
        tostring(KS.backResistanceValue or "unset"),
        tonumber(shield) or 0
    ))
end

function KS.PrintDragonAppetiteDiagnostic()
    KS.RefreshProcSetEquipment(true)
    KS.ScanDragonAppetiteStacks()

    chat(string.format(
        "Dragon diag: active=%s worn=%s pieces=%d/%d stacks=%d/10 effect=%s id=%s",
        tostring(KS.dragonAppetiteActive == true),
        tostring(KS.dragonAppetiteWorn == true),
        tonumber(KS.dragonAppetitePiecesActive) or 0,
        tonumber(KS.dragonAppetitePiecesTotal) or 0,
        tonumber(KS.dragonAppetiteStacks) or 0,
        tostring(KS.dragonAppetiteEffectName or ""),
        tostring(KS.dragonAppetiteAbilityId or 0)
    ))

    local numBuffs = GetNumBuffs and (GetNumBuffs("player") or 0) or 0
    local shown = 0
    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType,
            effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo("player", i)

        local stacks = tonumber(stackCount) or 0
        local id = tonumber(abilityId) or 0
        local abilityName = id > 0 and GetAbilityName and GetAbilityName(id) or ""
        local directMatch = looksLikeDragonAppetiteEffectName(name) or looksLikeDragonAppetiteEffectName(abilityName)

        if directMatch or (stacks > 0 and stacks <= 10) then
            shown = shown + 1
            if shown <= 15 then
                chat(string.format(
                    "%sBuff: %s | ability=%s | id=%s | stacks=%s | remaining=%.1f",
                    directMatch and "DRAGON " or "",
                    tostring(name or ""),
                    tostring(abilityName or ""),
                    tostring(id),
                    tostring(stackCount or 0),
                    math.max(0, (tonumber(timeEnding) or 0) - (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0))
                ))
            end
        end
    end

    if shown == 0 then
        chat("Dragon diag: no player stack-bearing buff candidates found.")
    end
end

function KS.ApplyMajorBreachPosition()
    if not KS.majorBreachRoot or not KS.sv or not GuiRoot then return end
    local x = tonumber(KS.sv.majorBreachX)
    local y = tonumber(KS.sv.majorBreachY)
    if x == nil then x = defaults.majorBreachX end
    if y == nil then y = defaults.majorBreachY end

    KS.majorBreachRoot:ClearAnchors()
    KS.majorBreachRoot:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

function KS.SaveMajorBreachPosition()
    if not KS.majorBreachRoot or not KS.sv or not GuiRoot then return end

    local left = KS.majorBreachRoot:GetLeft()
    local top = KS.majorBreachRoot:GetTop()
    local width = KS.majorBreachRoot:GetWidth()
    local height = KS.majorBreachRoot:GetHeight()
    local rootLeft = GuiRoot:GetLeft()
    local rootTop = GuiRoot:GetTop()
    local rootWidth = GuiRoot:GetWidth()
    local rootHeight = GuiRoot:GetHeight()

    if left == nil or top == nil or width == nil or height == nil
        or rootLeft == nil or rootTop == nil or rootWidth == nil or rootHeight == nil then
        return
    end

    local centerX = left + (width * 0.5)
    local centerY = top + (height * 0.5)
    local guiCenterX = rootLeft + (rootWidth * 0.5)
    local guiCenterY = rootTop + (rootHeight * 0.5)

    KS.sv.majorBreachX = math.floor((centerX - guiCenterX) + 0.5)
    KS.sv.majorBreachY = math.floor((centerY - guiCenterY) + 0.5)
    KS.ApplyMajorBreachPosition()
end

function KS.SetMajorBreachEditMode(enabled)
    KS.majorBreachEditMode = enabled and true or false

    if KS.majorBreachRoot then
        KS.majorBreachRoot:SetMouseEnabled(KS.majorBreachEditMode)
        KS.majorBreachRoot:SetMovable(KS.majorBreachEditMode)
    end

    KS.lastMajorBreachDisplayKey = nil
    KS.UpdateMajorBreachDisplay()
end

function KS.ResetMajorBreachPosition()
    if not KS.sv then return end
    KS.sv.majorBreachX = defaults.majorBreachX
    KS.sv.majorBreachY = defaults.majorBreachY
    KS.ApplyMajorBreachPosition()
    KS.lastMajorBreachDisplayKey = nil
    KS.UpdateMajorBreachDisplay()
    chat("Major Breach dot position reset.")
end

function KS.IsMajorBreachAura(name, abilityId, effectType)
    abilityId = tonumber(abilityId) or 0
    if abilityId == MAJOR_BREACH_EFFECT_ID then return true end

    if BUFF_EFFECT_TYPE_DEBUFF and effectType ~= nil and effectType ~= BUFF_EFFECT_TYPE_DEBUFF then
        return false
    end

    local auraName = zo_strlower and zo_strlower(tostring(name or "")) or string.lower(tostring(name or ""))
    auraName = auraName:gsub("^%s+", ""):gsub("%s+$", "")
    if auraName == "major breach" then return true end

    if GetAbilityName then
        local localized = tostring(GetAbilityName(MAJOR_BREACH_EFFECT_ID) or "")
        if localized ~= "" then
            localized = zo_strlower and zo_strlower(localized) or string.lower(localized)
            localized = localized:gsub("^%s+", ""):gsub("%s+$", "")
            if localized ~= "" and auraName == localized then return true end
        end
    end

    return false
end

function KS.SetMajorBreachState(active, expiresAt, abilityId, effectName)
    active = active and true or false
    expiresAt = active and (tonumber(expiresAt) or 0) or 0
    abilityId = active and (tonumber(abilityId) or 0) or 0
    effectName = active and tostring(effectName or "") or ""

    local changed = KS.majorBreachActive ~= active
        or math.abs((tonumber(KS.majorBreachExpiresAt) or 0) - expiresAt) > 0.05
        or (tonumber(KS.majorBreachAbilityId) or 0) ~= abilityId
        or tostring(KS.majorBreachEffectName or "") ~= effectName

    KS.majorBreachActive = active
    KS.majorBreachExpiresAt = expiresAt
    KS.majorBreachAbilityId = abilityId
    KS.majorBreachEffectName = effectName

    if changed then KS.UpdateMajorBreachDisplay() end
end

function KS.UpdateMajorBreachDisplay()
    if not KS.majorBreachRoot or not KS.majorBreachLabel or not KS.sv then return end

    local enabled = KS.sv.majorBreachTracker ~= false
    local preferredTargetValid = KS.HasPreferredTarget()
    local liveTarget = KS.GetTargetName()
    local visible = KS.majorBreachEditMode == true
        or (enabled
            and preferredTargetValid
            and liveTarget ~= ""
            and KS.IsHUDAllowed())

    if not visible then
        KS.majorBreachRoot:SetHidden(true)
        KS.lastMajorBreachDisplayKey = nil
        return
    end

    local key = KS.majorBreachActive == true and "breached" or "clear"
    if KS.majorBreachEditMode and not preferredTargetValid then key = "clear" end
    if KS.lastMajorBreachDisplayKey ~= key then
        KS.lastMajorBreachDisplayKey = key
        KS.majorBreachLabel:SetText("●")
        if key == "breached" then
            KS.majorBreachLabel:SetColor(1.0, 0.12, 0.12, 1.0)
        else
            KS.majorBreachLabel:SetColor(1.0, 1.0, 1.0, 1.0)
        end
    end

    KS.majorBreachRoot:SetHidden(false)
end

function KS.PrintMajorBreachDiagnostic()
    local liveTarget = KS.GetTargetName()
    if liveTarget == "" then
        chat("Major Breach diag: no live reticle target.")
        return
    end

    chat(string.format("Major Breach diag: target=%s detected=%s id=%s effect=%s", tostring(liveTarget), tostring(KS.majorBreachActive == true), tostring(KS.majorBreachAbilityId or 0), tostring(KS.majorBreachEffectName or "")))
    local numBuffs = GetNumBuffs(KS.unitTag) or 0
    local shown = 0
    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo(KS.unitTag, i)
        if BUFF_EFFECT_TYPE_DEBUFF == nil or effectType == BUFF_EFFECT_TYPE_DEBUFF then
            shown = shown + 1
            chat(string.format("Debuff %d: %s | id=%s | end=%.2f", shown, tostring(name or ""), tostring(abilityId or 0), tonumber(timeEnding) or 0))
            if shown >= 20 then break end
        end
    end
    if shown == 0 then chat("Major Breach diag: target exposes no debuffs through GetUnitBuffInfo.") end
end

function KS.ScanTargetAuras()
    -- Controlled polling avoids ESO's large EVENT_EFFECT_CHANGED burst whenever
    -- reticleover changes. Major Breach, important debuffs and Kjalnar are read
    -- together in one pass.
    local trackKjalnar = KS.sv.showKjalnarTracker ~= false and KS.kjalnarEquipped == true
    local trackBreach = KS.sv
        and KS.sv.majorBreachTracker ~= false
        and KS.HasPreferredTarget()
    local trackImportantDebuffs = KS.sv and KS.sv.showImportantTargetDebuffs ~= false

    if not trackKjalnar and not trackBreach and not trackImportantDebuffs then
        KS.SetMajorBreachState(false, 0, 0, "")
        KS.UpdateMajorBreachDisplay()
        KS.targetDebuffAuras = {}
        KS.UpdateImportantTargetDebuffs(true)
        return
    end

    local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if KS.lastTargetStableAtMs and nowMs > 0 and (nowMs - KS.lastTargetStableAtMs) < 150 then return end

    local liveTarget = KS.GetTargetName()
    if liveTarget == "" then
        if trackBreach then KS.SetMajorBreachState(false, 0, 0, "") end
        KS.UpdateMajorBreachDisplay()
        KS.targetDebuffAuras = {}
        KS.UpdateImportantTargetDebuffs(true)
        return
    end

    if KS.selectedTarget ~= liveTarget then
        KS.SetSelectedTarget(liveTarget)
    end

    local foundKjalnar = false
    local foundBreach = false
    local breachExpiresAt = 0
    local breachAbilityId = 0
    local breachEffectName = ""
    local importantByKey = {}
    local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
    local numBuffs = GetNumBuffs(KS.unitTag) or 0

    for i = 1, numBuffs do
        local name, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(KS.unitTag, i)
        local duration = 0
        if timeStarted and timeEnding then duration = math.max(0, timeEnding - timeStarted) end

        if trackImportantDebuffs and effectType == BUFF_EFFECT_TYPE_DEBUFF and (tonumber(timeEnding) or 0) > now and duration > 0 then
            local abilityName = (tonumber(abilityId) or 0) > 0 and GetAbilityName and tostring(GetAbilityName(abilityId) or "") or ""
            if isImportantTargetDebuffName(name) or isImportantTargetDebuffName(abilityName) then
                local id = tonumber(abilityId) or 0
                local key = id > 0 and ("id:" .. tostring(id)) or ("name:" .. normalizeName(name))
                local icon = tostring(iconFilename or "")
                if icon == "" and id > 0 and GetAbilityIcon then icon = tostring(GetAbilityIcon(id) or "") end
                local aura = {
                    name = tostring((name and name ~= "") and name or abilityName or ""),
                    abilityId = id,
                    beginTime = tonumber(timeStarted) or 0,
                    endTime = tonumber(timeEnding) or 0,
                    icon = icon,
                    stackCount = tonumber(stackCount) or 0,
                    statusEffectType = statusEffectType,
                }
                local existing = importantByKey[key]
                if not existing or aura.endTime > (tonumber(existing.endTime) or 0) then importantByKey[key] = aura end
            end
        end

        if trackBreach and KS.IsMajorBreachAura(name, abilityId, effectType) then
            foundBreach = true
            local candidateEnd = tonumber(timeEnding) or 0
            if candidateEnd >= breachExpiresAt then
                breachExpiresAt = candidateEnd
                breachAbilityId = tonumber(abilityId) or 0
                breachEffectName = tostring(name or "Major Breach")
            end
        end

        if trackKjalnar and not foundKjalnar then
            if KS.debug and isValidStackCount(stackCount) then
                local debugNow = GetGameTimeMilliseconds()
                if debugNow - KS.lastDebugAt > 750 then
                    KS.lastDebugAt = debugNow
                    chat(string.format("Target stack aura candidate: %s | stacks=%s | id=%s | duration=%.1f", tostring(name), tostring(stackCount), tostring(abilityId), duration))
                end
            end

            if KS.IsTrackedEffect(name, abilityId, stackCount, duration) then
                foundKjalnar = true
                KS.SetStacks(stackCount, abilityId, name, "scan", timeEnding or 0)
            end
        end
    end

    if trackImportantDebuffs then
        local important = {}
        for _, aura in pairs(importantByKey) do important[#important + 1] = aura end
        table.sort(important, function(a, b)
            local ae, be = tonumber(a.endTime) or 0, tonumber(b.endTime) or 0
            if ae ~= be then return ae < be end
            return normalizeName(a.name) < normalizeName(b.name)
        end)
        KS.targetDebuffAuras = important
    else
        KS.targetDebuffAuras = {}
    end
    KS.UpdateImportantTargetDebuffs(false)

    if trackKjalnar and not foundKjalnar and KS.currentStacks ~= 0 then
        KS.SetStacks(0, KS.currentAbilityId, KS.currentEffectName, "scan-clear", 0)
    end

    if trackBreach then
        KS.SetMajorBreachState(foundBreach, breachExpiresAt, breachAbilityId, breachEffectName)
    else
        KS.SetMajorBreachState(false, 0, 0, "")
        KS.UpdateMajorBreachDisplay()
    end
end

function KS.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not KS.kjalnarEquipped then return end

    local duration = 0
    if beginTime and endTime then duration = math.max(0, endTime - beginTime) end

    local cleanUnitName = cleanName(unitName)
    local liveTarget = KS.GetTargetName()
    if unitTag == KS.unitTag and liveTarget ~= "" then
        KS.SetSelectedTarget(liveTarget)
    end

    local isCurrentTarget = false
    if liveTarget ~= "" and unitTag == KS.unitTag and liveTarget == KS.selectedTarget then
        isCurrentTarget = true
    elseif cleanUnitName ~= "" and KS.selectedTarget ~= "" then
        isCurrentTarget = cleanUnitName == KS.selectedTarget
    end

    if not isCurrentTarget then return end

    if KS.debug and isValidStackCount(stackCount) then
        chat(string.format("Effect event candidate: %s | stacks=%s | id=%s | duration=%.1f | unit=%s", tostring(effectName), tostring(stackCount), tostring(abilityId), duration, tostring(unitTag)))
    end

    if KS.IsTrackedEffect(effectName, abilityId, stackCount, duration) then
        if changeType == EFFECT_RESULT_FADED then
            KS.SetStacks(0, abilityId, effectName, "event-fade", 0)
        else
            KS.SetStacks(stackCount or 0, abilityId, effectName, "event", endTime or 0)
        end
    end
end

function KS.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local isDeathResult = result == ACTION_RESULT_DIED or result == ACTION_RESULT_DIED_XP or result == ACTION_RESULT_DIED_COMPANION_XP

    if result == ACTION_RESULT_KILLING_BLOW then
        local contextType = KS.GetPvpContextType()
        local isLocalPlayerKill = KS.IsPvpTrackingContext()
            and KS.IsLocalPlayerCombatUnit(sourceName, sourceUnitId)
            and KS.IsPlayerCombatUnit(targetType, targetName)
            and not KS.IsLocalPlayerCombatUnit(targetName, targetUnitId)

        if contextType == "BG" then
            -- The scoreboard remains authoritative for BG K/D, but combat events are a
            -- reliable independent trigger for the visual announcement if the BG kill
            -- event is delayed or missed. The dedicated BG event will replace this with
            -- the victim's @display name when available.
            if isLocalPlayerKill then
                KS.ShowKillMessage(KS.ResolveKilledPlayerDisplayName(targetName), "fallback", targetName)
            end
            return
        end

        if isLocalPlayerKill then
            -- In Cyrodiil/IC the dedicated kill-feed event owns K/D counting. Still show
            -- the announcement here as a visual fallback, without changing the counter.
            KS.ShowKillMessage(KS.ResolveKilledPlayerDisplayName(targetName), "fallback", targetName)

        end
        return
    end

    if not isDeathResult then return end

    if KS.GetPvpContextType() ~= "BG" and KS.IsPvpTrackingContext() and KS.IsLocalPlayerCombatUnit(targetName, targetUnitId) then
        KS.CountPvpDeath()
    end

    if KS.selectedTarget ~= "" then
        local deadName = cleanName(targetName)
        if deadName ~= "" and deadName == KS.selectedTarget then
            KS.ClearTarget()
        end
    end
end

function KS.ProcessTargetChanged()
    KS.lastTargetStableAtMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0

    if KS.IsSelectedTargetDeadUnderReticle() then
        KS.ClearTarget()
        return
    end

    local liveTarget = KS.GetTargetName()
    KS.liveSelectedTarget = false
    if liveTarget ~= "" then
        KS.SetSelectedTarget(liveTarget)
        KS.liveSelectedTarget = true
        KS.lastDecoyName = ""
        KS.RefreshDisplay(true)
        return
    end

    local isDecoy, decoyName = KS.IsDecoyUnderReticle()
    KS.lastDecoyName = isDecoy and decoyName or ""

    if KS.CanRetainOffReticle() then
        KS.currentTarget = KS.selectedTarget or ""
        KS.RefreshDisplay(true)
    else
        KS.ClearTarget()
    end
end

function KS.OnTargetChanged()
    KS.diagCounters = KS.diagCounters or { reticle = 0, power = 0, worldSuccess = 0, worldFail = 0 }
    KS.diagCounters.reticle = (tonumber(KS.diagCounters.reticle) or 0) + 1
    local exists = DoesUnitExist and DoesUnitExist(KS.unitTag) or false
    local eventName = exists and cleanName(GetUnitName(KS.unitTag)) or ""
    KS.DiagPush("RETICLE", string.format("exists=%s name=%s preferred=%s", diagBool(exists), eventName ~= "" and eventName or "none", diagBool(KS.HasPreferredTarget())))
    -- Do not do custom UI work inside ESO's reticle-change frame. Mouse movement can
    -- generate several notifications while ESO and other addons are also rebuilding
    -- their target UI. Coalesce them and process only the final target next frame.
    if KS.pendingReticleRefresh then return end
    KS.pendingReticleRefresh = true
    zo_callLater(function()
        KS.pendingReticleRefresh = false
        KS.ProcessTargetChanged()
        KS.ApplyDefaultTargetFrameVisibility()
        if KS.sv and KS.sv.majorBreachTracker ~= false and KS.HasPreferredTarget() then
            KS.ScanTargetAuras()
        else
            KS.SetMajorBreachState(false, 0, 0, "")
            KS.UpdateMajorBreachDisplay()
        end
    end, 1)
end

function KS.ResetPosition(silent)
    KS.sv.x = defaults.x
    KS.sv.y = defaults.y
    KS.sv.frameScale = defaults.frameScale
    KS.sv.scale = defaults.frameScale
    if KS.root then
        KS.root:SetScale(KS.GetFrameScale())
        KS.ApplyPosition()
    end
    if not silent then chat("Position and target frame size reset.") end
end

function KS.Nudge(dx, dy)
    dx = tonumber(dx) or 0
    dy = tonumber(dy) or 0
    KS.sv.x = (tonumber(KS.sv.x) or 0) + dx
    KS.sv.y = (tonumber(KS.sv.y) or 0) + dy
    if KS.root then
        KS.root:ClearAnchors()
        KS.root:SetAnchor(CENTER, GuiRoot, CENTER, KS.sv.x, KS.sv.y)
    end
    chat(string.format("Position: x=%d y=%d", KS.sv.x, KS.sv.y))
end

function KS.PrintStatus()
    local info = KS.targetInfoCache[KS.selectedTarget] or {}
    chat(string.format("Target=%s | live=%s | health=%s/%s | Kjalnar2pc=%s (%d pieces) | stacks=%d/5 | abilityId=%s | effect=%s | learn=%s | locked=%s | decoyGuard=%s",
        KS.currentTarget ~= "" and KS.currentTarget or "none",
        tostring(KS.liveSelectedTarget),
        tostring(info.health or 0),
        tostring(info.healthMax or 0),
        tostring(KS.kjalnarEquipped),
        tonumber(KS.kjalnarEquippedPieces) or 0,
        KS.currentStacks,
        tostring(KS.sv.abilityId or 0),
        KS.sv.learnedName ~= "" and KS.sv.learnedName or (KS.currentEffectName ~= "" and KS.currentEffectName or "unknown"),
        tostring(KS.learning),
        tostring(KS.sv.locked),
        tostring(KS.sv.decoyGuard)))
    if KS.lastDecoyName ~= "" then
        chat("Current ignored decoy: " .. KS.lastDecoyName)
    end
end

function KS.HandleSlash(text)
    text = zo_strtrim(text or "")
    local cmd, arg = text:match("^(%S+)%s*(.-)$")
    cmd = zo_strlower(cmd or "")

    if cmd == "unlock" then
        KS.SetLocked(false)
    elseif cmd == "lock" then
        KS.SetLocked(true)
    elseif cmd == "reset" then
        KS.ResetPosition()
    elseif cmd == "clear" then
        KS.ClearTarget()
        chat("Persistent target cleared.")
    elseif cmd == "learn" then
        KS.RefreshKjalnarEquipment(true)
        if not KS.kjalnarEquipped then
            chat("Kjalnar 2-piece is not equipped. Persistent target frame stays active, but learn mode is only needed while wearing Kjalnar.")
        else
            KS.learning = true
            KS.sv.abilityId = 0
            KS.sv.learnedName = ""
            KS.forceVisible = true
            KS.RefreshDisplay()
            chat("Learn mode ON. Target an enemy and build a Kjalnar stack. It turns OFF automatically as soon as an effect is learned.")
        end
    elseif cmd == "learnoff" or cmd == "stop" or cmd == "done" then
        KS.StopLearning(false)
    elseif cmd == "forget" then
        KS.learning = false
        KS.sv.abilityId = 0
        KS.sv.learnedName = ""
        KS.currentAbilityId = 0
        KS.currentEffectName = ""
        KS.forceVisible = not KS.sv.locked
        chat("Forgot the learned Kjalnar effect. Automatic name detection is active.")
        KS.RefreshDisplay()
    elseif cmd == "debug" then
        KS.sv.diagnosticLogging = not (KS.sv.diagnosticLogging == true)
        KS.debug = KS.sv.diagnosticLogging == true
        if Ultivite and U.RequestSettingsSave then U.RequestSettingsSave(true) end
        chat("Diagnostic logging " .. (KS.debug and "ON. Automatic combat/set diagnostics may print to chat." or "OFF."))
    elseif cmd == "sticky" then
        KS.sv.stickyTarget = not KS.sv.stickyTarget
        chat("Persistent target: " .. tostring(KS.sv.stickyTarget))
        KS.OnTargetChanged()
    elseif cmd == "targetframe" then
        KS.sv.targetFrame = not KS.sv.targetFrame
        chat("Persistent target frame: " .. tostring(KS.sv.targetFrame))
        KS.RefreshDisplay()
    elseif cmd == "decoyguard" then
        KS.sv.decoyGuard = not KS.sv.decoyGuard
        chat("Decoy guard: " .. tostring(KS.sv.decoyGuard))
        KS.RefreshDisplay()
    elseif cmd == "showzero" then
        KS.sv.showZero = true
        chat("Target frame is permanent while an attackable target is retained.")
        KS.RefreshDisplay()
    elseif cmd == "targetname" then
        KS.sv.showTargetName = true
        chat("Player target name is always shown in persistent target frame mode.")
        KS.RefreshDisplay()
    elseif cmd == "left" then
        KS.Nudge(-(tonumber(arg) or 25), 0)
    elseif cmd == "right" then
        KS.Nudge(tonumber(arg) or 25, 0)
    elseif cmd == "up" then
        KS.Nudge(0, -(tonumber(arg) or 25))
    elseif cmd == "down" then
        KS.Nudge(0, tonumber(arg) or 25)
    elseif cmd == "scale" then
        KS.SetScale(arg)
    elseif cmd == "center" then
        KS.CenterHorizontally(false)
    elseif cmd == "centerscreen" then
        KS.CenterOnScreen(false)
    elseif cmd == "id" then
        local id = tonumber(arg)
        if id and id > 0 then
            KS.RememberAbility(id, "manual abilityId", "manual")
        else
            chat("Usage: /ks id 123456")
        end
    elseif cmd == "status" then
        KS.PrintStatus()
    elseif cmd == "kdreset" then
        KS.ResetPvpStats("manual", false)
    elseif cmd == "timerdiag" then
        chat(string.format("Timer diag: slot=%s hotbar=%s abilityId=%s slotName=%s abilityName=%s onslaught=%s | onExpires=%.2f balExpires=%.2f balorghEquipped=%s",
            tostring(KS.lastUltimateEventSlot or 0),
            tostring(KS.lastUltimateEventHotbar or 0),
            tostring(KS.lastUltimateEventAbilityId or 0),
            tostring(KS.lastUltimateEventSlotName or ""),
            tostring(KS.lastUltimateEventAbilityName or ""),
            tostring(KS.lastUltimateEventWasOnslaught == true),
            tonumber(KS.onslaughtExpiresAt) or 0,
            tonumber(KS.balorghExpiresAt) or 0,
            tostring(KS.balorghEquipped == true)))
    elseif cmd == "procdiag" then
        local now = GetFrameTimeSeconds and GetFrameTimeSeconds() or 0
        chat(string.format("Proc sets: Tarnished active=%s worn=%s pieces=%d/%d cd=%.1f | Null active=%s worn=%s pieces=%d/%d stacks=%d cd=%.1f",
            tostring(KS.tarnishedActive == true), tostring(KS.tarnishedWorn == true), tonumber(KS.tarnishedPiecesActive) or 0, tonumber(KS.tarnishedPiecesTotal) or 0, math.max(0, (tonumber(KS.tarnishedExpiresAt) or 0) - now),
            tostring(KS.nullArcaActive == true), tostring(KS.nullArcaWorn == true), tonumber(KS.nullArcaPiecesActive) or 0, tonumber(KS.nullArcaPiecesTotal) or 0, tonumber(KS.nullArcaStacks) or 0, math.max(0, (tonumber(KS.nullArcaExpiresAt) or 0) - now)))
    elseif cmd == "breachdiag" then
        KS.PrintMajorBreachDiagnostic()
    elseif cmd == "fooddiag" then
        KS.PrintFoodDiagnostic()
    elseif cmd == "resolvediag" then
        KS.PrintMajorResolveDiagnostic()
    elseif cmd == "dragondiag" then
        KS.PrintDragonAppetiteDiagnostic()
    elseif cmd == "wretcheddiag" then
        KS.PrintWretchedVitalityDiagnostic()
    elseif cmd == "auradiag" or cmd == "debuffdiag" then
        KS.PrintPlayerAuraHudDiagnostic()
    elseif cmd == "statdiag" then
        KS.PrintLiveStatDiagnostic()
    elseif cmd == "stackdiag" or cmd == "streakdiag" then
        KS.PrintSkillStackDiagnostic()
    elseif cmd == "targetdebuffdiag" then
        KS.PrintImportantTargetDebuffDiagnostic()
    elseif cmd == "dangerdiag" then
        KS.PrintCombatDangerDiagnostic()
    elseif cmd == "cpdiag" or cmd == "worldcpdiag" then
        if zo_strlower(zo_strtrim(arg or "")) == "clear" then
            KS.ClearWorldPlayerCpDiagnostic()
        else
            KS.PrintWorldPlayerCpDiagnostic()
        end
    elseif cmd == "nativeon" then
        KS.SetNativeOverheadTargetBar(true)
    elseif cmd == "nativeoff" then
        KS.SetNativeOverheadTargetBar(false)
    elseif cmd == "diag" or cmd == "worlddiag" then
        KS.PrintDiagnostic()
    elseif cmd == "diaglog" then
        KS.PrintDiagnosticLog()
    elseif cmd == "diagclear" then
        KS.ClearDiagnosticLog()
    else
        chat("Commands: /ks unlock | lock | center | centerscreen | reset | clear | sticky | targetframe | decoyguard | left/right/up/down 25 | learn | learnoff | forget | debug | scale 1.0 | id 123456 | status | kdreset | timerdiag | procdiag | breachdiag | fooddiag | resolvediag | dragondiag | wretcheddiag | auradiag | statdiag | stackdiag | streakdiag | targetdebuffdiag | dangerdiag | cpdiag | nativeon | nativeoff | diag | diaglog | diagclear")
    end
end

function KS.Initialize(externalSV)
    if externalSV then
        KS.sv = externalSV
        KS.accountSV = externalSV
        KS.characterSV = externalSV
        KS.scopeSV = { useAccountWide = true }
    else
        KS.accountSV = ZO_SavedVars:NewAccountWide("KjalnarStacksSavedVariables", KS.savedVersion, nil, defaults)
        KS.characterSV = ZO_SavedVars:NewCharacterIdSettings("KjalnarStacksSavedVariables", KS.savedVersion, nil, defaults)
        KS.scopeSV = ZO_SavedVars:NewCharacterIdSettings("KjalnarStacksProfileSavedVariables", KS.scopeSavedVersion, nil, scopeDefaults)
        KS.sv = KS.IsUsingAccountWideSettings() and KS.accountSV or KS.characterSV
    end

    if (tonumber(KS.sv.uiRevision) or 0) < 2 then
        KS.sv.showZero = false
        KS.sv.showTargetName = false
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 3 then
        KS.sv.locked = false
        KS.sv.stickyTarget = true
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 4 then
        KS.sv.uiRevision = 4
        KS.sv.locked = false
        KS.sv.stickyTarget = true
        KS.sv.targetFrame = true
        KS.sv.decoyGuard = true
        KS.sv.showZero = true
        KS.sv.showTargetName = true
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 5 then
        KS.sv.uiRevision = 5
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 6 then
        -- 1.3.7's ESO-style frame was intentionally large. Start existing users smaller
        -- and keep the frame fully adjustable from the addon menu.
        KS.sv.frameScale = defaults.frameScale
        KS.sv.scale = defaults.frameScale
        KS.sv.hideDefaultTargetFrame = true
        KS.sv.uiRevision = 6
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 7 then
        KS.sv.hideDefaultTargetFrame = true
        if (tonumber(KS.sv.frameScale) or 0) >= 0.65 then
            KS.sv.frameScale = defaults.frameScale
            KS.sv.scale = defaults.frameScale
        end
        KS.sv.uiRevision = 7
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 9 then
        -- 1.4.0 experimented with instantiating the full ZOS target template and
        -- forced a much larger default scale. Return to the proven custom frame.
        if (tonumber(KS.sv.frameScale) or 0) >= 0.95 then
            KS.sv.frameScale = defaults.frameScale
            KS.sv.scale = defaults.frameScale
        end
        KS.sv.hideDefaultTargetFrame = true
        KS.sv.uiRevision = 9
    end

    if KS.sv.hideLUIETargetFrame == nil then
        KS.sv.hideLUIETargetFrame = true
    end
    -- CP / level on player targets is permanent. Migrate any older profile that
    -- stored this as false back to ON.
    KS.sv.showNativePlayerCpFrame = true
    if KS.sv.autoHideOtherTargetFrames == nil then
        KS.sv.autoHideOtherTargetFrames = true
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 10 then
        KS.sv.autoHideOtherTargetFrames = true
        KS.sv.uiRevision = 10
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 11 then
        if KS.sv.fontFace == nil then KS.sv.fontFace = defaults.fontFace end
        if KS.sv.boldFont == nil then KS.sv.boldFont = defaults.boldFont end
        if KS.sv.thickTextShadow == nil then KS.sv.thickTextShadow = defaults.thickTextShadow end
        if KS.sv.nameFontSize == nil then KS.sv.nameFontSize = defaults.nameFontSize end
        if KS.sv.healthFontSize == nil then KS.sv.healthFontSize = defaults.healthFontSize end
        if KS.sv.kjalnarFontSize == nil then KS.sv.kjalnarFontSize = defaults.kjalnarFontSize end
        if KS.sv.nativeHideNpcNames == nil then KS.sv.nativeHideNpcNames = defaults.nativeHideNpcNames end
        KS.sv.uiRevision = 11
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 12 then
        if KS.sv.onslaughtTimer == nil then KS.sv.onslaughtTimer = defaults.onslaughtTimer end
        if KS.sv.balorghTimer == nil then KS.sv.balorghTimer = defaults.balorghTimer end
        if KS.sv.timerPlacement == nil then KS.sv.timerPlacement = defaults.timerPlacement end
        if KS.sv.timerFontSize == nil then KS.sv.timerFontSize = defaults.timerFontSize end
        if KS.sv.balorghTimerFontSize == nil then KS.sv.balorghTimerFontSize = defaults.balorghTimerFontSize end
        KS.sv.uiRevision = 12
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 13 then
        -- 1.4.8 replaces the narrow side-by-side timer with a full-width banner.
        -- Old "Right of frame" placement is migrated to Above so the countdown
        -- number cannot be clipped at larger font sizes.
        if KS.sv.timerPlacement == "Right of frame" then KS.sv.timerPlacement = "Above frame" end
        if (tonumber(KS.sv.timerFontSize) or 0) < 24 then KS.sv.timerFontSize = defaults.timerFontSize end
        KS.sv.uiRevision = 13
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 14 then
        if KS.sv.playerNameMode ~= "@Account name" then
            KS.sv.playerNameMode = "Character name"
        end
        KS.sv.uiRevision = 14
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 15 then
        KS.sv.uiRevision = 15
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 16 then
        KS.sv.uiRevision = 16
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 17 then
        KS.sv.uiRevision = 17
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 18 then
        KS.sv.anchorAboveTarget = true
        KS.sv.locked = true
        if (tonumber(KS.sv.frameScale) or defaults.frameScale) > 0.55 then
            KS.sv.frameScale = 0.55
            KS.sv.scale = 0.55
        end
        if (tonumber(KS.sv.kjalnarFontSize) or 0) < 22 then KS.sv.kjalnarFontSize = 26 end
        if (tonumber(KS.sv.nameFontSize) or 0) > 24 then KS.sv.nameFontSize = defaults.nameFontSize end
        if (tonumber(KS.sv.healthFontSize) or 0) > 18 then KS.sv.healthFontSize = defaults.healthFontSize end
        KS.sv.uiRevision = 18
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 19 then
        KS.sv.anchorAboveTarget = true
        KS.sv.locked = true
        KS.sv.targetHeadOffsetCm = tonumber(KS.sv.targetHeadOffsetCm) or defaults.targetHeadOffsetCm
        KS.sv.targetScreenGap = tonumber(KS.sv.targetScreenGap) or defaults.targetScreenGap
        if (tonumber(KS.sv.frameScale) or 0) < defaults.frameScale then
            KS.sv.frameScale = defaults.frameScale
            KS.sv.scale = defaults.frameScale
        end
        if (tonumber(KS.sv.kjalnarFontSize) or 0) < defaults.kjalnarFontSize then
            KS.sv.kjalnarFontSize = defaults.kjalnarFontSize
        end
        KS.sv.uiRevision = 19
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 20 then
        KS.sv.nativeOverheadTargetBar = true
        KS.sv.nativeSettingsCaptured = false
        KS.sv.nativeOriginalAllHealthbars = ""
        KS.sv.nativeOriginalAllNameplates = ""
        KS.sv.nativeOriginalEnemyNpcHealthbars = ""
        KS.sv.nativeOriginalEnemyPlayerHealthbars = ""
        KS.sv.nativeOriginalEnemyNpcNameplates = ""
        KS.sv.nativeOriginalEnemyPlayerNameplates = ""
        KS.sv.nativeOriginalFriendlyNpcNameplates = ""
        KS.sv.nativeOriginalNeutralNpcNameplates = ""
        -- The old world-projection experiment cannot follow ordinary targets on
        -- this API build, so stop forcing it on for upgraded users.
        KS.sv.anchorAboveTarget = false
        KS.sv.x = 0
        KS.sv.y = -150
        KS.sv.uiRevision = 20
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 21 then
        if KS.sv.nativeHideNpcNames == nil then KS.sv.nativeHideNpcNames = true end
        if KS.sv.nativeOriginalFriendlyNpcNameplates == nil then KS.sv.nativeOriginalFriendlyNpcNameplates = "" end
        if KS.sv.nativeOriginalNeutralNpcNameplates == nil then KS.sv.nativeOriginalNeutralNpcNameplates = "" end
        if (tonumber(KS.sv.kjalnarFontSize) or 0) < defaults.kjalnarFontSize then
            KS.sv.kjalnarFontSize = defaults.kjalnarFontSize
        end
        KS.sv.uiRevision = 21
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 22 then
        -- Keep Balorgh's existing transparent text-only presentation, but make it
        -- a few points larger by default than the general combat timer text.
        if (tonumber(KS.sv.balorghTimerFontSize) or 0) < defaults.balorghTimerFontSize then
            KS.sv.balorghTimerFontSize = defaults.balorghTimerFontSize
        end
        KS.sv.uiRevision = 22
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 23 then
        -- Preserve 1.6.8 behaviour for existing users. The new all-enemy mode is
        -- opt-in and only changes the two enemy healthbar visibility choices.
        if KS.sv.nativeAllEnemyHealthbars == nil then
            KS.sv.nativeAllEnemyHealthbars = false
        end
        KS.sv.uiRevision = 23
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 24 then
        if KS.sv.alwaysCollapseChat == nil then
            KS.sv.alwaysCollapseChat = false
        end
        KS.sv.uiRevision = 24
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 25 then
        if KS.sv.showPvpKillCounter == nil then KS.sv.showPvpKillCounter = true end
        if KS.sv.showPvpKillMessages == nil then KS.sv.showPvpKillMessages = true end
        KS.sv.pvpKills = tonumber(KS.sv.pvpKills) or 0
        KS.sv.pvpDeaths = tonumber(KS.sv.pvpDeaths) or 0
        KS.sv.pvpSessionKey = tostring(KS.sv.pvpSessionKey or "")
        if KS.sv.pvpSessionActive == nil then KS.sv.pvpSessionActive = false end
        KS.sv.uiRevision = 25
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 26 then
        if KS.sv.tarnishedTimer == nil then KS.sv.tarnishedTimer = true end
        if KS.sv.nullArcaTimer == nil then KS.sv.nullArcaTimer = true end
        KS.sv.uiRevision = 26
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 27 then
        if KS.sv.pvpHudX == nil then KS.sv.pvpHudX = defaults.pvpHudX end
        if KS.sv.pvpHudY == nil then KS.sv.pvpHudY = 118 end
        if KS.sv.pvpHudFontSize == nil then KS.sv.pvpHudFontSize = defaults.pvpHudFontSize end
        KS.sv.uiRevision = 27
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 28 then
        -- Move only the old untouched default upward. Preserve any position the user dragged manually.
        if tonumber(KS.sv.pvpHudX) == 34 and tonumber(KS.sv.pvpHudY) == 118 then
            KS.sv.pvpHudY = defaults.pvpHudY
        end
        KS.sv.uiRevision = 28
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 29 then
        KS.sv.uiRevision = 29
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 30 then
        -- Raise only the untouched 1.6.18+ default. Preserve manually dragged positions.
        if tonumber(KS.sv.pvpHudX) == 34 and tonumber(KS.sv.pvpHudY) == 60 then
            KS.sv.pvpHudY = defaults.pvpHudY
        end
        KS.sv.uiRevision = 30
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 31 then
        if KS.sv.majorBreachTracker == nil then KS.sv.majorBreachTracker = true end
        KS.sv.uiRevision = 31
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 32 then
        if KS.sv.majorBreachX == nil then KS.sv.majorBreachX = 0 end
        if KS.sv.majorBreachY == nil then KS.sv.majorBreachY = -140 end
        if KS.sv.majorBreachFontSize == nil then KS.sv.majorBreachFontSize = defaults.majorBreachFontSize end
        if KS.sv.foodWarningX == nil then KS.sv.foodWarningX = defaults.foodWarningX end
        if KS.sv.foodWarningY == nil then KS.sv.foodWarningY = defaults.foodWarningY end
        if KS.sv.foodWarningFontSize == nil then KS.sv.foodWarningFontSize = defaults.foodWarningFontSize end
        if KS.sv.majorResolveWarningX == nil then KS.sv.majorResolveWarningX = defaults.majorResolveWarningX end
        if KS.sv.majorResolveWarningY == nil then KS.sv.majorResolveWarningY = defaults.majorResolveWarningY end
        if KS.sv.majorResolveWarningFontSize == nil then KS.sv.majorResolveWarningFontSize = defaults.majorResolveWarningFontSize end
        if KS.sv.showNoFoodWarning == nil then KS.sv.showNoFoodWarning = true end
        KS.sv.uiRevision = 32
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 33 then
        -- Move only the untouched 1.6.25/1.6.26 default to the exact screen centre.
        -- Preserve any custom position the user already dragged manually.
        if tonumber(KS.sv.majorBreachX) == 0 and tonumber(KS.sv.majorBreachY) == -140 then
            KS.sv.majorBreachX = defaults.majorBreachX
            KS.sv.majorBreachY = defaults.majorBreachY
        end
        KS.sv.uiRevision = 33
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 34 then
        -- Move only the untouched previous K/D default slightly downward.
        -- Preserve any custom K/D position.
        if tonumber(KS.sv.pvpHudX) == 34 and tonumber(KS.sv.pvpHudY) == 35 then
            KS.sv.pvpHudY = defaults.pvpHudY
        end
        KS.sv.uiRevision = 34
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 35 then
        if KS.sv.showNoMajorResolveWarning == nil then
            KS.sv.showNoMajorResolveWarning = true
        end
        KS.sv.uiRevision = 35
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 36 then
        if KS.sv.dragonAppetiteCounter == nil then
            KS.sv.dragonAppetiteCounter = true
        end
        KS.sv.uiRevision = 36
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 37 then
        -- New independent Dragon's Appetite presentation settings.
        -- Do not touch the user's general timer font size or any existing layout.
        if KS.sv.dragonAppetiteFontSize == nil then
            KS.sv.dragonAppetiteFontSize = defaults.dragonAppetiteFontSize
        end
        if KS.sv.dragonAppetiteYOffset == nil then
            KS.sv.dragonAppetiteYOffset = defaults.dragonAppetiteYOffset
        end
        KS.sv.uiRevision = 37
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 38 then
        -- Wretched Vitality timers are a new independent HUD element. Only
        -- initialize missing keys so every existing Ultivite setting is retained.
        if KS.sv.wretchedVitalityTimers == nil then
            KS.sv.wretchedVitalityTimers = defaults.wretchedVitalityTimers
        end
        if KS.sv.wretchedVitalityIconSize == nil then
            KS.sv.wretchedVitalityIconSize = defaults.wretchedVitalityIconSize
        end
        if KS.sv.wretchedVitalityX == nil then
            KS.sv.wretchedVitalityX = defaults.wretchedVitalityX
        end
        if KS.sv.wretchedVitalityY == nil then
            KS.sv.wretchedVitalityY = defaults.wretchedVitalityY
        end
        KS.sv.uiRevision = 38
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 39 then
        -- Live stat HUD settings. Only add missing keys; never overwrite
        -- existing combat, layout, tracker or profile settings during upgrade.
        if KS.sv.showLiveDamageStat == nil then KS.sv.showLiveDamageStat = defaults.showLiveDamageStat end
        if KS.sv.showFrontResistanceStat == nil then KS.sv.showFrontResistanceStat = defaults.showFrontResistanceStat end
        if KS.sv.showBackResistanceStat == nil then KS.sv.showBackResistanceStat = defaults.showBackResistanceStat end
        if KS.sv.liveStatFontSize == nil then KS.sv.liveStatFontSize = defaults.liveStatFontSize end
        if KS.sv.liveDamageX == nil then KS.sv.liveDamageX = defaults.liveDamageX end
        if KS.sv.liveDamageY == nil then KS.sv.liveDamageY = defaults.liveDamageY end
        if KS.sv.liveFrontResistanceX == nil then KS.sv.liveFrontResistanceX = defaults.liveFrontResistanceX end
        if KS.sv.liveFrontResistanceY == nil then KS.sv.liveFrontResistanceY = defaults.liveFrontResistanceY end
        if KS.sv.liveBackResistanceX == nil then KS.sv.liveBackResistanceX = defaults.liveBackResistanceX end
        if KS.sv.liveBackResistanceY == nil then KS.sv.liveBackResistanceY = defaults.liveBackResistanceY end
        KS.sv.uiRevision = 39
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 40 then
        -- Add only the new player aura HUD keys. Do not overwrite any existing
        -- profile, layout, tracker, frame, sound or combat setting.
        if KS.sv.showCcImmunityTracker == nil then KS.sv.showCcImmunityTracker = defaults.showCcImmunityTracker end
        if KS.sv.showPlayerDebuffTracker == nil then KS.sv.showPlayerDebuffTracker = defaults.showPlayerDebuffTracker end
        if KS.sv.playerAuraIconSize == nil then KS.sv.playerAuraIconSize = defaults.playerAuraIconSize end
        if KS.sv.playerDebuffMaxIcons == nil then KS.sv.playerDebuffMaxIcons = defaults.playerDebuffMaxIcons end
        if KS.sv.ccImmunityX == nil then KS.sv.ccImmunityX = defaults.ccImmunityX end
        if KS.sv.ccImmunityY == nil then KS.sv.ccImmunityY = defaults.ccImmunityY end
        if KS.sv.playerDebuffX == nil then KS.sv.playerDebuffX = defaults.playerDebuffX end
        if KS.sv.playerDebuffY == nil then KS.sv.playerDebuffY = defaults.playerDebuffY end
        KS.sv.uiRevision = 40
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 41 then
        -- Ultivite 1.0.15 combat helpers. Nil-only migration preserves every
        -- existing setting and every existing dedicated stack tracker.
        local newKeys = {
            "showDamageShieldStat", "liveShieldX", "liveShieldY",
            "showGenericStackTracker", "genericStackIconSize", "genericStackX", "genericStackY",
            "showStreakFatigueTracker", "streakFatigueIconSize", "streakFatigueX", "streakFatigueY",
            "showResourceDanger", "resourceDangerHealthPct", "resourceDangerMagickaPct", "resourceDangerStaminaPct", "resourceDangerFontSize", "resourceDangerX", "resourceDangerY",
            "showImportantTargetDebuffs", "targetDebuffIconSize", "targetDebuffMaxIcons", "targetDebuffX", "targetDebuffY",
        }
        for _, key in ipairs(newKeys) do if KS.sv[key] == nil then KS.sv[key] = defaults[key] end end
        KS.sv.uiRevision = 41
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 42 then
        -- Ultivite 1.0.17 combat danger warnings. Add only missing keys so all
        -- existing account, character, layout, tracker and position settings survive.
        local newKeys = {
            "showShieldBrokenWarning", "showExecuteDangerWarning", "executeDangerHealthPct",
            "showBurstDamageWarning", "burstDamagePct", "burstDamageWindowMs",
            "combatDangerFontSize", "combatDangerX", "combatDangerY",
        }
        for _, key in ipairs(newKeys) do if KS.sv[key] == nil then KS.sv[key] = defaults[key] end end
        KS.sv.uiRevision = 42
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 43 then
        -- Ultivite 1.0.21: automatic combat/set chat diagnostics are opt-in.
        -- Nil-only initialization preserves every existing setting and position.
        if KS.sv.diagnosticLogging == nil then KS.sv.diagnosticLogging = defaults.diagnosticLogging end
        KS.sv.uiRevision = 43
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 44 then
        if KS.sv.showKjalnarTracker == nil then KS.sv.showKjalnarTracker = defaults.showKjalnarTracker end
        KS.sv.uiRevision = 44
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 45 then
        -- Ultivite 1.0.37: profile-backed native overhead Health bar suppression.
        -- Nil-only migration preserves every existing target/nameplate preference.
        if KS.sv.hideNativeOverheadHealthBars == nil then
            KS.sv.hideNativeOverheadHealthBars = defaults.hideNativeOverheadHealthBars
        end
        KS.sv.uiRevision = 45
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 46 then
        -- Ultivite 1.0.92: quick-menu PvP-only warning modes. Preserve all
        -- existing warning toggles and only add the new mode fields.
        if KS.sv.executeDangerWarningMode == nil then KS.sv.executeDangerWarningMode = defaults.executeDangerWarningMode end
        if KS.sv.burstDamageWarningMode == nil then KS.sv.burstDamageWarningMode = defaults.burstDamageWarningMode end
        -- Preserve the existing CP / level preference. Older builds briefly
        -- forced this on, but current Ultivite exposes it as a normal setting.
        if KS.sv.showNativePlayerCpFrame == nil then KS.sv.showNativePlayerCpFrame = defaults.showNativePlayerCpFrame end
        KS.sv.uiRevision = 46
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 47 then
        -- Ultivite 1.0.106 enemy Ultimate awareness. Nil-only migration keeps
        -- every existing profile and position untouched.
        if KS.sv.showEnemyCorrosiveAlert == nil then KS.sv.showEnemyCorrosiveAlert = defaults.showEnemyCorrosiveAlert end
        if KS.sv.showEnemyOnslaughtAlert == nil then KS.sv.showEnemyOnslaughtAlert = defaults.showEnemyOnslaughtAlert end
        if KS.sv.enemyUltimateAlertIconSize == nil then KS.sv.enemyUltimateAlertIconSize = defaults.enemyUltimateAlertIconSize end
        KS.sv.uiRevision = 47
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 48 then
        -- Ultivite 1.0.120: deterministic NPC name override. Keep it inactive
        -- until the player explicitly uses the NPC names control.
        if KS.sv.npcNamesOverrideActive == nil then KS.sv.npcNamesOverrideActive = false end
        KS.sv.uiRevision = 48
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 49 then
        -- 1.0.121 separates the global NPC-name choice from the native-mode-only
        -- suppression setting. 1.0.120 already persisted the global choice in
        -- the Frames profile, so use that as the migration source when present.
        if KS.sv.npcNamesGlobalHidden == nil then
            local frameSettings = U and U.Frames and U.Frames.saved or nil
            if frameSettings and frameSettings.vanillaNpcNamesHidden ~= nil then
                KS.sv.npcNamesGlobalHidden = frameSettings.vanillaNpcNamesHidden == true
            elseif KS.sv.npcNamesOverrideActive == true then
                KS.sv.npcNamesGlobalHidden = KS.sv.nativeHideNpcNames == true
            else
                KS.sv.npcNamesGlobalHidden = defaults.npcNamesGlobalHidden
            end
        end
        KS.sv.uiRevision = 49
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 50 then
        -- Ultivite 1.0.125: one profile-backed Overhead Player Info toggle.
        -- It is opt-in and snapshots player nameplate settings only when enabled.
        if KS.sv.overheadPlayerInfo == nil then KS.sv.overheadPlayerInfo = defaults.overheadPlayerInfo end
        if KS.sv.overheadPlayerInfoOriginalAllNameplates == nil then KS.sv.overheadPlayerInfoOriginalAllNameplates = "" end
        if KS.sv.overheadPlayerInfoOriginalEnemyPlayerNameplates == nil then KS.sv.overheadPlayerInfoOriginalEnemyPlayerNameplates = "" end
        if KS.sv.overheadPlayerInfoOriginalFriendlyPlayerNameplates == nil then KS.sv.overheadPlayerInfoOriginalFriendlyPlayerNameplates = "" end
        if KS.sv.overheadPlayerInfoOriginalGroupMemberNameplates == nil then KS.sv.overheadPlayerInfoOriginalGroupMemberNameplates = "" end
        KS.sv.uiRevision = 50
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 51 then
        -- Ultivite 1.0.126 separates native Player Names from Overhead Player
        -- Info. Restore the pre-1.0.126 native nameplate snapshot once, then
        -- clear those legacy ownership fields so the two controls cannot fight.
        local legacy = {
            { key = "overheadPlayerInfoOriginalAllNameplates", id = function() return NAMEPLATE_TYPE_ALL_NAMEPLATES end },
            { key = "overheadPlayerInfoOriginalEnemyPlayerNameplates", id = function() return NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES end },
            { key = "overheadPlayerInfoOriginalFriendlyPlayerNameplates", id = function() return NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES end },
            { key = "overheadPlayerInfoOriginalGroupMemberNameplates", id = function() return NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES end },
        }
        for _, entry in ipairs(legacy) do
            local id = entry.id()
            local value = tostring(KS.sv[entry.key] or "")
            if id ~= nil and value ~= "" then KS.SetNativeNameplateSetting(id, value) end
            KS.sv[entry.key] = ""
        end
        if KS.sv.playerNamesGlobalHidden == nil then KS.sv.playerNamesGlobalHidden = defaults.playerNamesGlobalHidden end
        if KS.sv.playerNamesOverrideActive == nil then KS.sv.playerNamesOverrideActive = defaults.playerNamesOverrideActive end
        KS.sv.uiRevision = 51
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 52 then
        -- Ultivite 1.0.146 retires legacy stock chat minimization. Existing
        -- SavedVariables could retain this hidden setting even though the main
        -- Ultivite menu no longer exposes it. Force it off once.
        KS.sv.alwaysCollapseChat = false
        KS.sv.uiRevision = 52
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 53 then
        -- Ultivite Preview Everything adds a real movable kill-message
        -- position and independent size. Nil-only migration preserves existing
        -- combat settings and every established HUD position.
        if KS.sv.killMessageX == nil then KS.sv.killMessageX = defaults.killMessageX end
        if KS.sv.killMessageY == nil then KS.sv.killMessageY = defaults.killMessageY end
        if KS.sv.killMessageFontSize == nil then KS.sv.killMessageFontSize = defaults.killMessageFontSize end
        KS.sv.uiRevision = 53
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 54 then
        -- Ultivite 1.0.173: CP / level is presentation information, not an
        -- optional tracker. Force it on for existing profiles as well as new ones.
        KS.sv.overheadPlayerInfo = true
        KS.sv.uiRevision = 54
    end
    if (tonumber(KS.sv.uiRevision) or 0) < 55 then
        -- Legacy migration only. 1.0.192 uses group tags for true world
        -- following and reticleoverplayer for targeted-player presentation.
        KS.sv.overheadPlayerInfo = true
        KS.sv.uiRevision = 55
    end

    KS.debug = KS.sv.diagnosticLogging == true
    KS.learning = false
    KS.forceVisible = not KS.sv.locked
    KS.RefreshKjalnarEquipment(true)
    KS.CreateUI()
    KS.ScanDragonAppetiteStacks()
    KS.ScanWretchedVitalityBuffs()
    KS.ScanPlayerAuraHud()
    KS.RefreshResourceDangerValues()
    KS.UpdateResourceDangerHud(true)
    KS.ResetBurstDamageHistory()
    KS.UpdateCombatDangerWarnings(true)
    KS.UpdateSkillStackTrackers(true)
    KS.ScanTargetAuras()
    KS.foodWarningReadyAt = (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0) + 1.0
    KS.UpdateMajorBreachDisplay()
    if KS.sv.locked ~= true then KS.CaptureEditSnapshot() end
    KS.UpdateDragState()
    -- Ultivite owns the single consolidated LibAddonMenu panel.
    KS.ApplyNativeOverheadTargetBar()
    KS.ApplyOverheadPlayerInfoNameplates()
    KS.ApplyPlayerNamesOverride()
    KS.RefreshOverheadPlayerInfoRuntime()
    -- Performance-safe mode: do not post-hook ZOS target-frame refresh functions.
    -- Those functions execute during every mouseover and were a direct source of hitching.

    -- Reuse the duplicate-frame control learned by 1.4.4+ so normal sessions do
    -- not need to walk the entire GuiRoot after the first target is selected.
    local savedExternalName = tostring(KS.sv.externalTargetFrameControlName or "")
    local savedExternalControl = savedExternalName ~= "" and _G[savedExternalName] or nil
    if savedExternalControl and savedExternalControl ~= KS.root then
        if KS.IsProtectedReticleControl(savedExternalControl) then
            -- 1.5.2 could persist a broad reticle control. Explicitly repair it and
            -- discard that learned name so resource-node/interact text can render.
            KS.sv.externalTargetFrameControlName = ""
            KS.RepairReticleInteractionUI()
        else
            local wasHidden, wasAlpha = false, 1
            if savedExternalControl.IsHidden then
                local ok, value = pcall(function() return savedExternalControl:IsHidden() end)
                if ok then wasHidden = value and true or false end
            end
            if savedExternalControl.GetAlpha then
                local ok, value = pcall(function() return savedExternalControl:GetAlpha() end)
                if ok and tonumber(value) then wasAlpha = tonumber(value) end
            end
            KS.dynamicHiddenTargetFrame = savedExternalControl
            KS.dynamicHiddenTargetFrameState = { control = savedExternalControl, wasHidden = wasHidden, wasAlpha = wasAlpha }
            -- Alpha-only suppression does not force a layout/show-hide recalculation.
            if savedExternalControl.SetAlpha then pcall(function() savedExternalControl:SetAlpha(0) end) end
        end
    end

    KS.ApplyDefaultTargetFrameVisibility()
    CALLBACK_MANAGER:RegisterCallback("UnitFramesCreated", function() KS.ApplyDefaultTargetFrameVisibility() end)

    EVENT_MANAGER:RegisterForEvent(KS.name, EVENT_RETICLE_TARGET_CHANGED, function()
        KS.ScheduleWorldCpReticleDiagnostic("EVENT_RETICLE_TARGET_CHANGED")
        KS.UpdateOverheadPlayerInfo()
        KS.OnTargetChanged()
    end)

    -- Match the event-driven target-health pattern used by mature unit-frame addons:
    -- initialize from GetUnitPower when the reticle target changes, then consume only
    -- reticleover HEALTH power updates. This avoids a permanent health polling loop
    -- and keeps the bar/percentage synchronized with ESO's target power events.
    local targetHealthEvent = KS.name .. "TargetHealthPower"
    EVENT_MANAGER:RegisterForEvent(targetHealthEvent, EVENT_POWER_UPDATE, function(...)
        KS.OnTargetPowerUpdate(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(targetHealthEvent, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, KS.unitTag,
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

    -- Dedicated player target presentation follows the same event-driven model.
    -- It does not replace Kjalnar's generic reticleover combat/aura source; it only
    -- refreshes the visible player target frame when ESO updates that player tag.
    local targetPlayerHealthEvent = KS.name .. "TargetPlayerHealthPower"
    EVENT_MANAGER:RegisterForEvent(targetPlayerHealthEvent, EVENT_POWER_UPDATE, function(_, unitTag, _, powerType)
        if unitTag == "reticleoverplayer" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
            KS.RefreshDisplay(true)
        end
    end)
    EVENT_MANAGER:AddFilterForEvent(targetPlayerHealthEvent, EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "reticleoverplayer",
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

    if EVENT_CHAMPION_POINT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(KS.name .. "TargetPlayerChampionPoints", EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
            if unitTag == "reticleoverplayer" then KS.RefreshDisplay(true) end
        end)
    end
    if EVENT_LEVEL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(KS.name .. "TargetPlayerLevel", EVENT_LEVEL_UPDATE, function(_, unitTag)
            if unitTag == "reticleoverplayer" then KS.RefreshDisplay(true) end
        end)
    end

    if EVENT_RETICLE_TARGET_PLAYER_CHANGED then
        EVENT_MANAGER:RegisterForEvent(KS.name .. "ReticlePlayerChanged", EVENT_RETICLE_TARGET_PLAYER_CHANGED, function()
            KS.ScheduleWorldCpReticleDiagnostic("EVENT_RETICLE_TARGET_PLAYER_CHANGED")
            KS.UpdateOverheadPlayerInfo()
            KS.OnTargetChanged()
            -- Immediate player presentation uses reticleoverplayer directly while
            -- the normal target-state coalescer settles generic reticleover.
            KS.RefreshDisplay(true)
        end)
    end

    -- IMPORTANT: do not register EVENT_EFFECT_CHANGED for reticleover. ESO emits a
    -- burst for the target's effects when the mouse enters a unit, which can hitch
    -- the exact frame the player changes target. Kjalnar uses the controlled 250 ms
    -- aura poll below instead. Player-only timer effects remain safely filtered.

    local playerTimerEffectEvent = KS.name .. "PlayerTimerEffects"
    EVENT_MANAGER:RegisterForEvent(playerTimerEffectEvent, EVENT_EFFECT_CHANGED, function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime)
        KS.HandlePlayerTimerEffect(changeType, effectName, unitTag, beginTime, endTime)
    end)
    EVENT_MANAGER:AddFilterForEvent(playerTimerEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    EVENT_MANAGER:RegisterForEvent(KS.name .. "CombatTimers", EVENT_ACTION_SLOT_ABILITY_USED, function(...) KS.OnActionSlotAbilityUsed(...) end)

    local dragonEffectEvent = KS.name .. "DragonAppetiteEffect"
    EVENT_MANAGER:RegisterForEvent(dragonEffectEvent, EVENT_EFFECT_CHANGED, function(...)
        KS.OnDragonAppetiteEffectChanged(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(dragonEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    local wretchedEffectEvent = KS.name .. "WretchedVitalityEffect"
    EVENT_MANAGER:RegisterForEvent(wretchedEffectEvent, EVENT_EFFECT_CHANGED, function(...)
        KS.OnWretchedVitalityEffectChanged(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(wretchedEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    local playerAuraHudEffectEvent = KS.name .. "PlayerAuraHudEffect"
    EVENT_MANAGER:RegisterForEvent(playerAuraHudEffectEvent, EVENT_EFFECT_CHANGED, function(...)
        KS.OnPlayerAuraHudEffectChanged(...)
    end)
    EVENT_MANAGER:AddFilterForEvent(playerAuraHudEffectEvent, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    local criticalResults = { ACTION_RESULT_CRITICAL_DAMAGE, ACTION_RESULT_DOT_TICK_CRITICAL }
    for i, resultCode in ipairs(criticalResults) do
        local eventName = KS.name .. "ProcCritical" .. tostring(i)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...) KS.OnProcCriticalEvent(...) end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER,
            REGISTER_FILTER_COMBAT_RESULT, resultCode)
    end

    EVENT_MANAGER:RegisterForEvent(KS.name .. "BattlegroundKill", EVENT_BATTLEGROUND_KILL, function(...) KS.OnBattlegroundKill(...) end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "BattlegroundScoreboard", EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, function()
        if KS.GetPvpContextType() == "BG" then
            KS.SyncBattlegroundScoreboard(false)
            KS.UpdatePvpHud(false)
        end
    end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "PvpKillFeed", EVENT_PVP_KILL_FEED_DEATH, function(...) KS.OnPvpKillFeedDeath(...) end)

    local killEvent = KS.name .. "PvpKillingBlow"
    EVENT_MANAGER:RegisterForEvent(killEvent, EVENT_COMBAT_EVENT, function(...) KS.OnCombatEvent(...) end)
    EVENT_MANAGER:AddFilterForEvent(killEvent, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_KILLING_BLOW)

    local deathResults = { ACTION_RESULT_DIED, ACTION_RESULT_DIED_XP, ACTION_RESULT_DIED_COMPANION_XP }
    for i, resultCode in ipairs(deathResults) do
        local eventName = KS.name .. "TargetDeath" .. tostring(i)
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(...) KS.OnCombatEvent(...) end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, resultCode)
    end

    EVENT_MANAGER:RegisterForEvent(KS.name .. "NativeNameplates", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            KS.ApplyNativeOverheadTargetBar()
            KS.ApplyOverheadPlayerInfoNameplates()
            KS.RefreshOverheadPlayerInfoRuntime()
            KS.ApplyAlwaysCollapseChat()
            KS.RefreshPvpSession(false)
            KS.RefreshProcSetEquipment(true)
            KS.ScanDragonAppetiteStacks()
            KS.ScanWretchedVitalityBuffs()
            KS.RefreshResourceDangerValues()
            KS.UpdateResourceDangerHud(true)
            KS.ResetBurstDamageHistory()
            KS.UpdateCombatDangerWarnings(true)
            KS.UpdateSkillStackTrackers(true)
            KS.foodWarningReadyAt = (GetFrameTimeSeconds and GetFrameTimeSeconds() or 0) + 0.75
            zo_callLater(function() KS.UpdateFoodWarning() end, 800)
        end, 250)
    end)

    local playerPowerEvent = KS.name .. "PlayerResourceDanger"
    EVENT_MANAGER:RegisterForEvent(playerPowerEvent, EVENT_POWER_UPDATE, function(...) KS.OnPlayerPowerUpdate(...) end)
    EVENT_MANAGER:AddFilterForEvent(playerPowerEvent, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")

    do
        local eventName = KS.name .. "ShieldAdded"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
            if unitTag ~= "player" or unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
            KS.lastKnownShieldValue = math.max(0, tonumber(value) or KS.GetCurrentDamageShieldValue())
            KS.UpdateLiveStatWidgets(true)
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, "player")
    end
    do
        local eventName = KS.name .. "ShieldUpdated"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
            if unitTag ~= "player" or unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
            local oldShield = math.max(0, tonumber(oldValue) or tonumber(KS.lastKnownShieldValue) or 0)
            local newShield = math.max(0, tonumber(newValue) or KS.GetCurrentDamageShieldValue())
            local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            KS.lastKnownShieldValue = newShield
            -- A zero-value visual update alone is not enough to call this a break.
            -- Correlate it with an incoming DAMAGE_SHIELDED combat result so a
            -- normal timed expiry cannot produce SHIELD BROKEN.
            if oldShield > 0 and newShield <= 0
                and nowMs > 0
                and (nowMs - (tonumber(KS.lastShieldDamageAtMs) or 0)) <= 120 then
                KS.TriggerShieldBrokenWarning()
            end
            KS.UpdateLiveStatWidgets(true)
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")
    end
    do
        local eventName = KS.name .. "ShieldRemoved"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(eventCode, unitTag, unitAttributeVisual)
            if unitTag ~= "player" or unitAttributeVisual ~= ATTRIBUTE_VISUAL_POWER_SHIELDING then return end
            -- Removal is intentionally not treated as a break. A timed shield expiring
            -- normally reaches this path and must not show SHIELD BROKEN.
            KS.lastKnownShieldValue = 0
            KS.UpdateLiveStatWidgets(true)
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, "player")
    end

    do
        local eventName = KS.name .. "ShieldDamageFallback"
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue)
            if targetType ~= COMBAT_UNIT_TYPE_PLAYER then return end
            local before = math.max(0, tonumber(KS.lastKnownShieldValue) or KS.GetCurrentDamageShieldValue())
            local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            KS.lastShieldDamageAtMs = nowMs
            zo_callLater(function()
                local after = KS.GetCurrentDamageShieldValue()
                if before > 0 and after <= 0 then KS.TriggerShieldBrokenWarning() end
                KS.lastKnownShieldValue = after
                KS.UpdateLiveStatWidgets(true)
            end, 10)
        end)
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT,
            REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DAMAGE_SHIELDED,
            REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

    EVENT_MANAGER:RegisterForEvent(KS.name .. "CameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED, function() KS.RefreshDisplay(); KS.UpdateCombatTimers(); KS.UpdateFoodWarning(); KS.UpdateMajorResolveWarning() end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "CameraOn", EVENT_GAME_CAMERA_ACTIVATED, function() KS.RefreshDisplay(); KS.UpdateCombatTimers(); KS.UpdateFoodWarning(); KS.UpdateMajorResolveWarning() end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "CameraOff", EVENT_GAME_CAMERA_DEACTIVATED, function() KS.RefreshDisplay(); KS.UpdateCombatTimers(); KS.UpdateFoodWarning(); KS.UpdateMajorResolveWarning() end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function()
        KS.lastShowKjalnar = nil
        KS.ApplyNativeOverheadTargetBar()
        KS.ApplyDefaultTargetFrameVisibility()
        KS.RefreshDisplay()
        KS.UpdateCombatTimers()
        KS.UpdatePvpHud()
        KS.ScanDragonAppetiteStacks()
        KS.ScanWretchedVitalityBuffs()
        KS.lastTimerLayoutKey = nil
        KS.UpdateCombatTimers()
        KS.lastMajorResolveWarningVisible = nil
        KS.UpdateMajorResolveWarning()
        KS.shieldBreakExpiresAtMs = 0
        KS.burstDamageExpiresAtMs = 0
        KS.ResetBurstDamageHistory()
        KS.UpdateCombatDangerWarnings(true)
    end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "DuelStarted", EVENT_DUEL_STARTED, function()
        KS.duelActive = true
        KS.UpdatePvpHud()
        if KS.killMessageRoot then KS.killMessageRoot:SetHidden(true) end
    end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "DuelFinished", EVENT_DUEL_FINISHED, function()
        KS.duelActive = false
        KS.UpdatePvpHud()
    end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "BattlegroundState", EVENT_BATTLEGROUND_STATE_CHANGED, function(...) KS.OnBattlegroundStateChanged(...) end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "PlayerDead", EVENT_PLAYER_DEAD, function()
        if KS.GetPvpContextType() == "BG" then
            zo_callLater(function()
                KS.SyncBattlegroundScoreboard(false)
                KS.UpdatePvpHud(false)
            end, 75)
        else
            KS.CountPvpDeath()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(KS.name .. "Equipment", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotIndex)
        if bagId == BAG_WORN then
            zo_callLater(function()
                KS.RefreshKjalnarEquipment(false)
                KS.ScanDragonAppetiteStacks()
            end, 50)
        end
    end)
    EVENT_MANAGER:RegisterForEvent(KS.name .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function()
        zo_callLater(function()
            KS.RefreshProcSetEquipment(false)
            KS.ScanDragonAppetiteStacks()
            KS.UpdateLiveStatWidgets(true)
            KS.UpdateSkillStackTrackers(true)
        end, 25)
    end)
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "KjalnarPoll", KS.pollMs, function()
        if KS.kjalnarEquipped or (KS.sv and (KS.sv.majorBreachTracker ~= false or KS.sv.showImportantTargetDebuffs ~= false)) then
            KS.ScanTargetAuras()
        elseif KS.majorBreachRoot and not KS.majorBreachRoot:IsHidden() then
            KS.UpdateMajorBreachDisplay()
        end
    end)
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "DragonAppetitePoll", 250, function()
        if KS.dragonAppetiteWorn == true then
            KS.ScanDragonAppetiteStacks()
        elseif (tonumber(KS.dragonAppetiteStacks) or 0) ~= 0 then
            KS.dragonAppetiteStacks = 0
            KS.lastDragonAppetiteTimerText = nil
            KS.UpdateCombatTimers()
        end
    end)
    -- Legacy non-grouped target projection is disabled for ESOUI compliance.
    -- Ensure an older reload/session cannot leave its high-frequency update live.
    EVENT_MANAGER:UnregisterForUpdate(KS.name .. "WorldFollow")
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "TimerPoll", KS.timerPollMs, function()
        if (tonumber(KS.onslaughtExpiresAt) or 0) > 0
            or (tonumber(KS.balorghExpiresAt) or 0) > 0
            or (tonumber(KS.tarnishedExpiresAt) or 0) > 0
            or (tonumber(KS.nullArcaExpiresAt) or 0) > 0
            or (tonumber(KS.nullArcaStacks) or 0) > 0
            or (KS.dragonAppetiteWorn == true and KS.IsPlayerInCombat())
            or KS.IsPositionPreviewActive() then
            KS.UpdateCombatTimers()
        end
        if (tonumber(KS.killMessageExpiresAt) or 0) > 0 then KS.UpdateKillMessage() end
        if KS.sv and KS.sv.wretchedVitalityTimers ~= false then
            KS.UpdateWretchedVitalityTimers()
            local nowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            if nowMs > 0 and (nowMs - (tonumber(KS.wretchedVitalityLastScanMs) or 0)) >= 1000 then
                KS.ScanWretchedVitalityBuffs()
            end
        end
        if KS.sv and (KS.sv.showCcImmunityTracker ~= false or KS.sv.showPlayerDebuffTracker ~= false) then
            KS.UpdatePlayerAuraHud()
            local auraNowMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
            if auraNowMs > 0 and (auraNowMs - (tonumber(KS.playerAuraHudLastScanMs) or 0)) >= 1000 then
                KS.ScanPlayerAuraHud()
            end
        end
        KS.UpdateSkillStackTrackers(false)
        KS.UpdateImportantTargetDebuffs(false)
        KS.UpdateResourceDangerHud(false)
        KS.UpdateCombatDangerWarnings(false)
        KS.UpdateLiveStatWidgets(false)
    end)
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "PvpHud", 250, function()
        KS.UpdatePvpHud()
    end)
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "MajorResolveWarning", 250, function()
        if KS.sv and KS.sv.showNoMajorResolveWarning ~= false then
            KS.UpdateMajorResolveWarning()
        elseif KS.majorResolveWarningRoot and not KS.majorResolveWarningRoot:IsHidden() then
            KS.majorResolveWarningRoot:SetHidden(true)
        end
    end)
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "FoodWarning", 1000, function()
        if KS.sv and KS.sv.showNoFoodWarning ~= false then
            KS.UpdateFoodWarning()
        elseif KS.foodWarningRoot and not KS.foodWarningRoot:IsHidden() then
            KS.foodWarningRoot:SetHidden(true)
        end
    end)
    -- Very slow visibility watchdog. Never scan GuiRoot and never touch the unit-frame
    -- object here. Known third-party frames are suppressed with alpha only so this
    -- addon cannot enter a SetHidden fight with another target-frame addon.
    EVENT_MANAGER:RegisterForUpdate(KS.name .. "HideWatchdog", KS.hideWatchdogMs, function()
        if KS.dynamicHiddenTargetFrame then
            if KS.IsProtectedReticleControl(KS.dynamicHiddenTargetFrame) then
                local state = KS.dynamicHiddenTargetFrameState
                if KS.dynamicHiddenTargetFrame.SetAlpha then
                    local restoreAlpha = state and state.wasAlpha ~= nil and state.wasAlpha or 1
                    pcall(function() KS.dynamicHiddenTargetFrame:SetAlpha(restoreAlpha) end)
                end
                KS.dynamicHiddenTargetFrame = nil
                KS.dynamicHiddenTargetFrameState = nil
                KS.sv.externalTargetFrameControlName = ""
                KS.RepairReticleInteractionUI()
            elseif KS.dynamicHiddenTargetFrame.SetAlpha then
                local ok, alpha = pcall(function() return KS.dynamicHiddenTargetFrame:GetAlpha() end)
                if not ok or (tonumber(alpha) or 1) > 0.01 then pcall(function() KS.dynamicHiddenTargetFrame:SetAlpha(0) end) end
            end
        end
        local luieTarget = KS.GetLUIETargetFrame()
        if KS.sv.hideLUIETargetFrame and luieTarget and luieTarget.SetAlpha then
            local ok, alpha = pcall(function() return luieTarget:GetAlpha() end)
            if not ok or (tonumber(alpha) or 1) > 0.01 then pcall(function() luieTarget:SetAlpha(0) end) end
        end
    end)

    SLASH_COMMANDS["/ks"] = function(text) KS.HandleSlash(text) end
    SLASH_COMMANDS["/kjalnar"] = function(text) KS.HandleSlash(text) end
    SLASH_COMMANDS["/ulticpdiag"] = function(text)
        local arg = zo_strlower(zo_strtrim(text or ""))
        if arg == "clear" then
            KS.ClearWorldPlayerCpDiagnostic()
        elseif arg == "print" or arg == "chat" then
            KS.PrintWorldPlayerCpDiagnostic()
        else
            KS.ShowWorldPlayerCpDiagnostic()
        end
    end
    SLASH_COMMANDS["/ucpdiag"] = SLASH_COMMANDS["/ulticpdiag"]

    zo_callLater(function()
        KS.ApplyDefaultTargetFrameVisibility()
        KS.OnTargetChanged()
        KS.UpdateCombatTimers()
        KS.UpdateKillMessage()
        KS.RefreshPvpSession(false)
        KS.ApplyAlwaysCollapseChat()
        if KS.IsDiagnosticLoggingEnabled() then
            if KS.kjalnarEquipped then
                if KS.sv.abilityId and KS.sv.abilityId > 0 then
                    KS.DiagnosticChat(string.format("Loaded native overhead target bar. Kjalnar 2-piece detected and bone stack counter enabled. Learned effect retained (abilityId %d).", KS.sv.abilityId))
                else
                    KS.DiagnosticChat("Loaded native overhead target bar. Kjalnar 2-piece detected and bone stack counter enabled. Use /ks learn only if stack detection needs relearning.")
                end
            else
                KS.DiagnosticChat("Loaded persistent PvP/PvE target frame. Kjalnar is not equipped, so the bone stack counter is hidden. Target retention and decoy guard remain active.")
            end
        end
    end, 500)
end
