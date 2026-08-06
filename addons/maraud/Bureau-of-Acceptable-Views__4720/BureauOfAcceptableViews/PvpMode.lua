-- ===========================================================================
-- PvpMode.lua
-- ---------------------------------------------------------------------------
-- Event-driven PvP situation detector. This module never writes camera settings
-- directly: it resolves one stable state and asks ContextPresets to apply an
-- external profile through its existing snapshot/restore/FOV ownership path.
-- ===========================================================================

local addon = BureauOfAcceptableViews
local private = addon.private

addon.PvpMode = addon.PvpMode or {}
local PvpMode = addon.PvpMode

local EVENT_MANAGER = EVENT_MANAGER
local GetFrameTimeMilliseconds = GetFrameTimeMilliseconds
local IsUnitInCombat = IsUnitInCombat
local IsUnitActivelyEngaged = IsUnitActivelyEngaged
local IsUnitDeadOrReincarnating = IsUnitDeadOrReincarnating
local IsGameCameraSiegeControlled = IsGameCameraSiegeControlled
local IsGameCameraUIModeActive = IsGameCameraUIModeActive
local IsPlayerInAvAWorld = IsPlayerInAvAWorld
local IsActiveWorldBattleground = IsActiveWorldBattleground
local IsMounted = IsMounted
local GetUnitPower = GetUnitPower
local GetUnitZoneIndex = GetUnitZoneIndex
local GetZoneId = GetZoneId
local tonumber = tonumber
local type = type
local pairs = pairs

local SOURCE = "PvpMode"
local EVENT_NAMESPACE = "BAV_PvpMode"
local OUTGOING_EVENT_NAMESPACE = "BAV_PvpMode_Outgoing"
local SAFETY_UPDATE_NAME = "BAV_PvpMode_Safety"
local SAFETY_INTERVAL_MS = 250
local DAMAGE_WINDOW_MS = 1500
local COMBAT_ACTIVITY_HOLD_MS = 2000
local PRESSURE_HOLD_MS = 3000
local PLAYER_UNIT = "player"

local STATE_OFF = "off"
local STATE_SCOUTING = "scouting"
local STATE_MOUNTED = "mounted"
local STATE_PURSUIT = "pursuit"
local STATE_ENGAGED = "engaged"
local STATE_PRESSURE = "pressure"
local STATE_SUSPENDED = "suspended"

local PROFILES = {
    [STATE_SCOUTING] = {
        instant = true,
        freezeInMenus = true,
        fovTarget = 58,
        distanceOffset = 0.20,
        screenShakeTarget = 0.45,
    },
    [STATE_MOUNTED] = {
        instant = true,
        freezeInMenus = true,
        fovTarget = 60,
        distanceOffset = 0.55,
        verticalOffset = 0.04,
        screenShakeTarget = 0.35,
    },
    [STATE_PURSUIT] = {
        instant = true,
        freezeInMenus = true,
        fovTarget = 60,
        distanceOffset = 0.15,
        screenShakeTarget = 0.35,
    },
    [STATE_ENGAGED] = {
        instant = true,
        freezeInMenus = true,
        fovTarget = 61,
        distanceOffset = 0.45,
        verticalOffset = 0.03,
        screenShakeTarget = 0.20,
    },
    [STATE_PRESSURE] = {
        instant = true,
        freezeInMenus = true,
        fovTarget = 63,
        distanceOffset = 0.70,
        verticalOffset = 0.04,
        screenShakeTarget = 0.0,
    },
}

local DAMAGE_RESULTS = {}
local ENGAGEMENT_RESULTS = {}
local HEAL_RESULTS = {}

local function AddResult(results, result)
    if result ~= nil then
        results[result] = true
    end
end

local function AddDamageResult(result)
    AddResult(DAMAGE_RESULTS, result)
    AddResult(ENGAGEMENT_RESULTS, result)
end

AddDamageResult(ACTION_RESULT_DAMAGE)
AddDamageResult(ACTION_RESULT_CRITICAL_DAMAGE)
AddDamageResult(ACTION_RESULT_DOT_TICK)
AddDamageResult(ACTION_RESULT_DOT_TICK_CRITICAL)

AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_BLOCKED_DAMAGE)
AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_DAMAGE_SHIELDED)
AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_IMMUNE)
AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_DODGED)
AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_PARRIED)
AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_REFLECTED)
AddResult(ENGAGEMENT_RESULTS, ACTION_RESULT_MISS)

AddResult(HEAL_RESULTS, ACTION_RESULT_HEAL)
AddResult(HEAL_RESULTS, ACTION_RESULT_CRITICAL_HEAL)
AddResult(HEAL_RESULTS, ACTION_RESULT_HOT_TICK)
AddResult(HEAL_RESULTS, ACTION_RESULT_HOT_TICK_CRITICAL)

local config = {
    enabled = false,
    scouting = true,
    mountedScouting = true,
    pursuit = true,
    pressure = true,
    lowHealthThreshold = 0.35,
    criticalHealthThreshold = 0.20,
    burstThreshold = 0.25,
    stabilityLock = true,
    zoomAssist = true,
    cameraShake = false,
}

local runtime = {
    ready = false,
    inPvp = false,
    inCombat = false,
    activelyEngaged = false,
    uiMode = false,
    sprinting = false,
    mounted = false,
    dead = false,
    siege = false,
    writeFault = false,
    manualSuspended = false,
    health = nil,
    healthMax = nil,
    activityUntil = 0,
    pressureUntil = 0,
    pvpZoneId = nil,
    currentState = STATE_OFF,
    damageSamples = {},
    damageHead = 1,
    damageTail = 0,
    damageTotal = 0,
    combatBootstrapPending = false,
    eventsRegistered = false,
    manualZoomOverride = false,
}

local function LogDebug(...)
    if private.LogDebug then private.LogDebug(...) end
end

local function LogWarn(...)
    if private.LogWarn then private.LogWarn(...) end
end

local function Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

local function Now()
    return GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
end

local function DetectPvpWorld()
    local inAva = IsPlayerInAvAWorld and IsPlayerInAvAWorld() or false
    local inBattleground = IsActiveWorldBattleground and IsActiveWorldBattleground() or false
    return inAva or inBattleground
end

local function ReadPlayerZoneId()
    if not GetUnitZoneIndex or not GetZoneId then
        return nil
    end
    local zoneIndex = GetUnitZoneIndex(PLAYER_UNIT)
    if zoneIndex == nil then
        return nil
    end
    local zoneId = tonumber(GetZoneId(zoneIndex))
    if zoneId == nil or zoneId <= 0 then
        return nil
    end
    return zoneId
end

local function ReadHealth()
    if not GetUnitPower or POWERTYPE_HEALTH == nil then
        return nil, nil
    end
    local current, maximum = GetUnitPower(PLAYER_UNIT, POWERTYPE_HEALTH)
    current = tonumber(current)
    maximum = tonumber(maximum)
    if current == nil or maximum == nil or maximum <= 0 then
        return nil, nil
    end
    return current, maximum
end

local function HealthRatio()
    if runtime.health == nil or runtime.healthMax == nil or runtime.healthMax <= 0 then
        return nil
    end
    return runtime.health / runtime.healthMax
end

local function ClearDamageSamples()
    runtime.damageSamples = {}
    runtime.damageHead = 1
    runtime.damageTail = 0
    runtime.damageTotal = 0
end

local function PruneDamageSamples(now)
    local samples = runtime.damageSamples
    while runtime.damageHead <= runtime.damageTail do
        local sample = samples[runtime.damageHead]
        if sample == nil or now - sample.at <= DAMAGE_WINDOW_MS then
            break
        end
        runtime.damageTotal = runtime.damageTotal - sample.amount
        samples[runtime.damageHead] = nil
        runtime.damageHead = runtime.damageHead + 1
    end
    if runtime.damageHead > runtime.damageTail then
        ClearDamageSamples()
    end
end

local function RecordDamage(now, amount)
    runtime.damageTail = runtime.damageTail + 1
    runtime.damageSamples[runtime.damageTail] = { at = now, amount = amount }
    runtime.damageTotal = runtime.damageTotal + amount
end

local function RecentDamage(now)
    PruneDamageSamples(now)
    return runtime.damageTotal
end

local function MarkCombatActivity(now)
    local nextUntil = now + COMBAT_ACTIVITY_HOLD_MS
    if nextUntil > runtime.activityUntil then
        runtime.activityUntil = nextUntil
    end
end

local function ClearExternalProfile()
    local presets = addon.ContextPresets
    if presets and presets.ClearExternalProfile then
        presets.ClearExternalProfile(SOURCE, true)
    end
end

local function PersistManualZoomOverride(value)
    local settings = addon.Settings
    if settings and settings.SetPvpManualZoomOverride then
        settings.SetPvpManualZoomOverride(value)
    end
end

local function LoadManualZoomOverride()
    local settings = addon.Settings
    if settings and settings.GetPvpManualZoomOverride then
        return settings.GetPvpManualZoomOverride()
    end
    return false
end

local function ResetPvpWorldSession(releaseProfile)
    runtime.activityUntil = 0
    runtime.pressureUntil = 0
    runtime.writeFault = false
    runtime.manualSuspended = false
    runtime.manualZoomOverride = false
    PersistManualZoomOverride(false)
    ClearDamageSamples()
    if releaseProfile then
        ClearExternalProfile()
        runtime.currentState = STATE_OFF
    end
end

local function BuildProfile(stateId)
    local source = PROFILES[stateId]
    if source == nil then
        return nil
    end

    local profile = {}
    for key, value in pairs(source) do
        profile[key] = value
    end

    if not config.zoomAssist or runtime.manualZoomOverride then
        profile.distanceOffset = nil
    else
        profile.distancePolicy = "outwardOnly"
    end

    if not config.cameraShake then
        profile.screenShakeTarget = 0.0
    end

    return profile
end

local RegisterEvents
local UnregisterEvents

local function ApplyState(stateId, force)
    if stateId == runtime.currentState and not force then
        return
    end

    if stateId == STATE_OFF or stateId == STATE_SUSPENDED then
        ClearExternalProfile()
    else
        local presets = addon.ContextPresets
        local profile = BuildProfile(stateId)
        if not (presets and presets.SetExternalProfile and profile) then
            ClearExternalProfile()
            stateId = STATE_OFF
        elseif not presets.SetExternalProfile(SOURCE, "pvp:" .. stateId, profile, force) then
            LogWarn("PvpMode: unable to apply external profile '%s'", tostring(stateId))
            ClearExternalProfile()
            stateId = STATE_OFF
        elseif presets.GetExternalProfileFailureCount
            and presets.GetExternalProfileFailureCount(SOURCE) > 0 then
            LogWarn("PvpMode: profile '%s' was only partially applied; suspending", tostring(stateId))
            runtime.writeFault = true
            ClearExternalProfile()
            stateId = STATE_SUSPENDED
        end
    end

    LogDebug("PvpMode: state %s -> %s", runtime.currentState, stateId)
    runtime.currentState = stateId
end

local function ResolveState(now)
    if not config.enabled or not runtime.ready or not runtime.inPvp then
        if not runtime.inPvp then
            runtime.manualSuspended = false
        end
        return STATE_OFF
    end
    if runtime.manualSuspended then
        return STATE_SUSPENDED
    end
    if runtime.dead or runtime.siege or runtime.writeFault then
        return STATE_SUSPENDED
    end

    local healthRatio = HealthRatio()
    local activeCombat = now < runtime.activityUntil
    local critical = activeCombat and healthRatio ~= nil
        and healthRatio <= config.criticalHealthThreshold
    local pressured = config.pressure and (
        now < runtime.pressureUntil
        or (activeCombat and healthRatio ~= nil
            and healthRatio <= config.lowHealthThreshold))

    -- At critical health, retain the already-established threat framing rather
    -- than starting another camera transition. If no threat profile exists yet,
    -- engaged is the single conservative entry before the lock takes effect.
    if config.stabilityLock and critical then
        if runtime.currentState == STATE_ENGAGED
            or (config.pressure and runtime.currentState == STATE_PRESSURE) then
            return runtime.currentState
        end
        return STATE_ENGAGED
    end

    if pressured then
        return STATE_PRESSURE
    end
    if activeCombat then
        return STATE_ENGAGED
    end
    if config.pursuit and runtime.sprinting then
        return STATE_PURSUIT
    end
    if config.mountedScouting and runtime.mounted then
        return STATE_MOUNTED
    end
    if config.scouting then
        return STATE_SCOUTING
    end
    return STATE_OFF
end

function PvpMode.Refresh(force)
    if not config.enabled or not runtime.ready then
        if UnregisterEvents then UnregisterEvents() end
        ApplyState(STATE_OFF, true)
        return
    end

    local inPvp = DetectPvpWorld()
    runtime.inPvp = inPvp
    if inPvp then
        local zoneId = ReadPlayerZoneId()
        if runtime.pvpZoneId ~= nil and zoneId ~= nil
            and zoneId ~= runtime.pvpZoneId then
            ResetPvpWorldSession(true)
        end
        runtime.pvpZoneId = zoneId or runtime.pvpZoneId
        RegisterEvents()
    else
        UnregisterEvents()
    end

    if not runtime.inPvp then
        runtime.pvpZoneId = nil
        runtime.inCombat = false
        runtime.activelyEngaged = false
        runtime.uiMode = false
        runtime.sprinting = false
        runtime.mounted = false
        runtime.dead = false
        runtime.siege = false
        runtime.health = nil
        runtime.healthMax = nil
        ResetPvpWorldSession()
        ApplyState(STATE_OFF, true)
        return
    end

    runtime.uiMode = IsGameCameraUIModeActive
        and IsGameCameraUIModeActive() or false
    runtime.inCombat = IsUnitInCombat
        and IsUnitInCombat(PLAYER_UNIT) or false
    runtime.activelyEngaged = IsUnitActivelyEngaged
        and IsUnitActivelyEngaged(PLAYER_UNIT) or false
    runtime.mounted = IsMounted and IsMounted() or false
    runtime.dead = IsUnitDeadOrReincarnating
        and IsUnitDeadOrReincarnating(PLAYER_UNIT) or false
    runtime.siege = IsGameCameraSiegeControlled
        and IsGameCameraSiegeControlled() or false
    runtime.health, runtime.healthMax = ReadHealth()

    local now = Now()
    if runtime.combatBootstrapPending then
        runtime.combatBootstrapPending = false
        if runtime.inCombat or runtime.activelyEngaged then
            MarkCombatActivity(now)
        end
    end

    if runtime.uiMode then
        return
    end

    ApplyState(ResolveState(now), force)
end

local function OnMountedState(_, mounted)
    runtime.mounted = mounted and true or false
    PvpMode.Refresh()
end

local function OnCombatState(_, inCombat)
    runtime.inCombat = inCombat and true or false
    if runtime.inCombat and runtime.inPvp then
        MarkCombatActivity(Now())
    end
    PvpMode.Refresh()
end

local function OnActivelyEngagedState()
    runtime.activelyEngaged = IsUnitActivelyEngaged
        and IsUnitActivelyEngaged(PLAYER_UNIT) or false
    if runtime.activelyEngaged and runtime.inPvp then
        MarkCombatActivity(Now())
    end
    PvpMode.Refresh()
end

local function OnPowerUpdate(_, unitTag, _, powerType, powerValue, powerMax)
    if unitTag ~= PLAYER_UNIT or powerType ~= POWERTYPE_HEALTH then
        return
    end
    runtime.health = tonumber(powerValue)
    runtime.healthMax = tonumber(powerMax)
    PvpMode.Refresh()
end

local function OnIncomingDamage(
    _, result, isError, _, _, _, _, sourceType, _, targetType, hitValue)
    if isError or sourceType == COMBAT_UNIT_TYPE_PLAYER
        or targetType ~= COMBAT_UNIT_TYPE_PLAYER
        or not ENGAGEMENT_RESULTS[result] then
        return
    end

    local amount = tonumber(hitValue) or 0
    if not runtime.inPvp then
        return
    end

    local now = Now()
    MarkCombatActivity(now)

    if not DAMAGE_RESULTS[result] or amount <= 0 then
        PvpMode.Refresh()
        return
    end

    local maximum = runtime.healthMax
    if config.pressure and maximum and maximum > 0 then
        RecordDamage(now, amount)
        if RecentDamage(now) >= maximum * config.burstThreshold then
            runtime.pressureUntil = now + PRESSURE_HOLD_MS
        end
    end
    PvpMode.Refresh()
end

local function OnOutgoingCombatEvent(
    _, result, isError, _, _, _, _, sourceType, _, targetType, hitValue)
    if isError or sourceType ~= COMBAT_UNIT_TYPE_PLAYER
        or targetType == COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    local amount = tonumber(hitValue) or 0
    if not runtime.inPvp then
        return
    end

    local now = Now()
    if ENGAGEMENT_RESULTS[result] then
        MarkCombatActivity(now)
    elseif HEAL_RESULTS[result] and amount > 0 and now < runtime.activityUntil then
        runtime.inCombat = IsUnitInCombat
            and IsUnitInCombat(PLAYER_UNIT) and true or false
        runtime.activelyEngaged = IsUnitActivelyEngaged
            and IsUnitActivelyEngaged(PLAYER_UNIT) and true or false
        if not runtime.inCombat or not runtime.activelyEngaged then
            return
        end
        MarkCombatActivity(now)
    else
        return
    end
    PvpMode.Refresh()
end

local function OnGameCameraUIModeChanged()
    local wasUiMode = runtime.uiMode
    runtime.uiMode = IsGameCameraUIModeActive
        and IsGameCameraUIModeActive() or false
    if wasUiMode and not runtime.uiMode then
        PvpMode.Refresh(true)
    end
end

local function OnSprintChanged(sprinting)
    runtime.sprinting = sprinting and true or false
    PvpMode.Refresh()
end

local function OnSafetyUpdate()
    local now = Now()
    local wasDead = runtime.dead
    local wasSiege = runtime.siege
    runtime.inCombat = IsUnitInCombat
        and IsUnitInCombat(PLAYER_UNIT) or false
    runtime.activelyEngaged = IsUnitActivelyEngaged
        and IsUnitActivelyEngaged(PLAYER_UNIT) or false
    if runtime.activelyEngaged then
        MarkCombatActivity(now)
    end
    runtime.dead = IsUnitDeadOrReincarnating
        and IsUnitDeadOrReincarnating(PLAYER_UNIT) or false
    runtime.siege = IsGameCameraSiegeControlled
        and IsGameCameraSiegeControlled() or false
    local wasWriteFault = runtime.writeFault
    local failureCount = private.GetZoomWriteFailureCount
        and private.GetZoomWriteFailureCount() or 0
    if failureCount >= 3 then
        runtime.writeFault = true
    end
    if not runtime.uiMode and (
        ResolveState(now) ~= runtime.currentState
        or runtime.dead ~= wasDead or runtime.siege ~= wasSiege
        or runtime.writeFault ~= wasWriteFault) then
        PvpMode.Refresh(true)
    end
end

RegisterEvents = function()
    if runtime.eventsRegistered then return end
    runtime.eventsRegistered = true
    runtime.combatBootstrapPending = true

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    if EVENT_PLAYER_ACTIVELY_ENGAGED_STATE ~= nil then
        EVENT_MANAGER:RegisterForEvent(
            EVENT_NAMESPACE, EVENT_PLAYER_ACTIVELY_ENGAGED_STATE, OnActivelyEngagedState)
    end
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED, OnMountedState)
    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE, EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnGameCameraUIModeChanged)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT, OnIncomingDamage)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    EVENT_MANAGER:RegisterForEvent(
        OUTGOING_EVENT_NAMESPACE, EVENT_COMBAT_EVENT, OnOutgoingCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(
        OUTGOING_EVENT_NAMESPACE, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    local sprintWatch = addon.SprintWatch
    if sprintWatch and sprintWatch.Subscribe then
        sprintWatch.Subscribe(SOURCE, OnSprintChanged)
    end
    EVENT_MANAGER:RegisterForUpdate(SAFETY_UPDATE_NAME, SAFETY_INTERVAL_MS, OnSafetyUpdate)
end

UnregisterEvents = function()
    if not runtime.eventsRegistered then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    if EVENT_PLAYER_ACTIVELY_ENGAGED_STATE ~= nil then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVELY_ENGAGED_STATE)
    end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GAME_CAMERA_UI_MODE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(OUTGOING_EVENT_NAMESPACE, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(SAFETY_UPDATE_NAME)
    local sprintWatch = addon.SprintWatch
    if sprintWatch and sprintWatch.Unsubscribe then
        sprintWatch.Unsubscribe(SOURCE)
    end
    runtime.eventsRegistered = false
end

function PvpMode.Configure(options)
    options = options or {}
    config.scouting = options.scouting ~= false
    config.mountedScouting = options.mountedScouting ~= false
    config.pursuit = options.pursuit ~= false
    local pressureEnabled = options.pressure ~= false
    if config.pressure and not pressureEnabled then
        runtime.pressureUntil = 0
        ClearDamageSamples()
    end
    config.pressure = pressureEnabled
    config.stabilityLock = options.stabilityLock ~= false
    local zoomAssistEnabled = options.zoomAssist ~= false
    local releaseZoomAssist = config.zoomAssist and not zoomAssistEnabled
    config.zoomAssist = zoomAssistEnabled
    config.cameraShake = options.cameraShake and true or false
    config.lowHealthThreshold = Clamp(tonumber(options.lowHealthThreshold) or 0.35, 0.10, 0.80)
    config.criticalHealthThreshold = Clamp(
        tonumber(options.criticalHealthThreshold) or 0.20, 0.05, config.lowHealthThreshold)
    config.burstThreshold = Clamp(tonumber(options.burstThreshold) or 0.25, 0.05, 1.0)

    local enabled = options.enabled and true or false
    if enabled ~= config.enabled then
        config.enabled = enabled
        if enabled then
            runtime.manualSuspended = false
            if runtime.ready then
                runtime.manualZoomOverride = false
                PersistManualZoomOverride(false)
            end
        else
            UnregisterEvents()
            runtime.activityUntil = 0
            runtime.pressureUntil = 0
            runtime.sprinting = false
            runtime.writeFault = false
            runtime.manualZoomOverride = false
            PersistManualZoomOverride(false)
            ClearDamageSamples()
            ApplyState(STATE_OFF, true)
        end
    end

    if releaseZoomAssist and config.enabled and runtime.ready
        and runtime.currentState ~= STATE_OFF
        and runtime.currentState ~= STATE_SUSPENDED then
        ClearExternalProfile()
        runtime.currentState = STATE_OFF
    end

    if config.enabled and runtime.ready then
        PvpMode.Refresh(true)
    end
end

function PvpMode.ActivateAfterRecovery()
    runtime.ready = true
    runtime.manualZoomOverride = LoadManualZoomOverride()
    if config.enabled then
        PvpMode.Refresh()
    else
        UnregisterEvents()
        ApplyState(STATE_OFF, true)
    end
end

-- Load-screen boundary. Stop every PvP-only event and timer, but keep the
-- external profile/snapshot intact until the next activation identifies the new
-- world. Core persistence reads ContextPresets' base snapshot, so no PvP offset
-- is saved as the player's normal zoom; delaying profile resolution also avoids
-- starting a restore glide on the loading screen.
function PvpMode.OnPlayerDeactivated()
    UnregisterEvents()
    runtime.activityUntil = 0
    runtime.pressureUntil = 0
    ClearDamageSamples()
end

function PvpMode.GetState()
    return runtime.currentState
end

function PvpMode.IsEnabled()
    return config.enabled
end

function PvpMode.IsActiveInPvpWorld()
    return config.enabled and runtime.ready and runtime.inPvp
end

-- A successful player-driven zoom becomes authoritative for the remainder of
-- the current PvP world. Future state changes retain FOV/framing changes but
-- omit distance, and the restore snapshot adopts this distance so leaving PvP
-- does not undo the player's choice.
function PvpMode.OnManualZoom(distance)
    if not config.enabled or not runtime.inPvp then
        return false
    end

    runtime.manualZoomOverride = true
    PersistManualZoomOverride(true)
    local presets = addon.ContextPresets
    if presets and presets.UpdateExternalBaseDistance then
        presets.UpdateExternalBaseDistance(SOURCE, distance)
    end
    PvpMode.Refresh(true)
    return true
end

-- Explicit panic path used by /bav reset. Keep the detector suspended for the
-- remainder of the current PvP world so subsequent health/combat events cannot
-- immediately re-apply the profile the player just dismissed. Toggling PvP mode
-- off/on also clears this session-local suspension.
function PvpMode.EmergencySuspend()
    if not runtime.inPvp then
        runtime.manualSuspended = false
        ApplyState(STATE_OFF, true)
        return
    end
    runtime.manualSuspended = true
    ApplyState(STATE_SUSPENDED, true)
end
