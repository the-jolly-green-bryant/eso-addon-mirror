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
local IsUnitDeadOrReincarnating = IsUnitDeadOrReincarnating
local IsGameCameraSiegeControlled = IsGameCameraSiegeControlled
local IsPlayerInAvAWorld = IsPlayerInAvAWorld
local IsActiveWorldBattleground = IsActiveWorldBattleground
local IsMounted = IsMounted
local GetUnitPower = GetUnitPower
local tonumber = tonumber
local type = type
local pairs = pairs

local SOURCE = "PvpMode"
local EVENT_NAMESPACE = "BAV_PvpMode"
local SAFETY_UPDATE_NAME = "BAV_PvpMode_Safety"
local PRESSURE_RELEASE_NAME = "BAV_PvpMode_PressureRelease"
local GANK_RELEASE_NAME = "BAV_PvpMode_GankRelease"
local STATE_HOLD_UPDATE_NAME = "BAV_PvpMode_StateHold"
local SAFETY_INTERVAL_MS = 250
local DAMAGE_WINDOW_MS = 1500
local PRESSURE_HOLD_MS = 3000
local GANK_HOLD_MS = 2500
local MIN_STATE_HOLD_MS = 500
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
        fovTarget = 58,
        distanceOffset = 0.20,
        screenShakeTarget = 0.45,
    },
    [STATE_MOUNTED] = {
        instant = true,
        fovTarget = 60,
        distanceOffset = 0.55,
        verticalOffset = 0.04,
        screenShakeTarget = 0.35,
    },
    [STATE_PURSUIT] = {
        instant = true,
        fovTarget = 60,
        distanceOffset = 0.15,
        screenShakeTarget = 0.35,
    },
    [STATE_ENGAGED] = {
        instant = true,
        fovTarget = 61,
        distanceOffset = 0.45,
        verticalOffset = 0.03,
        screenShakeTarget = 0.20,
    },
    [STATE_PRESSURE] = {
        instant = true,
        fovTarget = 63,
        distanceOffset = 0.70,
        verticalOffset = 0.04,
        screenShakeTarget = 0.0,
    },
}

local DAMAGE_RESULTS = {}
local function AddDamageResult(result)
    if result ~= nil then
        DAMAGE_RESULTS[result] = true
    end
end
AddDamageResult(ACTION_RESULT_DAMAGE)
AddDamageResult(ACTION_RESULT_CRITICAL_DAMAGE)
AddDamageResult(ACTION_RESULT_DOT_TICK)
AddDamageResult(ACTION_RESULT_DOT_TICK_CRITICAL)

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
    sprinting = false,
    mounted = false,
    dead = false,
    siege = false,
    writeFault = false,
    manualSuspended = false,
    health = nil,
    healthMax = nil,
    pressureUntil = 0,
    gankUntil = 0,
    currentState = STATE_OFF,
    stateSince = 0,
    damageSamples = {},
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
end

local function PruneDamageSamples(now)
    local samples = runtime.damageSamples
    local first = 1
    while samples[first] and now - samples[first].at > DAMAGE_WINDOW_MS do
        first = first + 1
    end
    if first > 1 then
        local compacted = {}
        for index = first, #samples do
            compacted[#compacted + 1] = samples[index]
        end
        runtime.damageSamples = compacted
    end
end

local function RecentDamage(now)
    PruneDamageSamples(now)
    local total = 0
    for index = 1, #runtime.damageSamples do
        total = total + runtime.damageSamples[index].amount
    end
    return total
end

local function SchedulePressureRelease()
    EVENT_MANAGER:UnregisterForUpdate(PRESSURE_RELEASE_NAME)
    local delay = runtime.pressureUntil - Now()
    if delay <= 0 then
        return
    end
    EVENT_MANAGER:RegisterForUpdate(PRESSURE_RELEASE_NAME, delay, function()
        EVENT_MANAGER:UnregisterForUpdate(PRESSURE_RELEASE_NAME)
        PvpMode.Refresh()
    end)
end

local function ScheduleGankRelease()
    EVENT_MANAGER:UnregisterForUpdate(GANK_RELEASE_NAME)
    local delay = runtime.gankUntil - Now()
    if delay <= 0 then
        return
    end
    EVENT_MANAGER:RegisterForUpdate(GANK_RELEASE_NAME, delay, function()
        EVENT_MANAGER:UnregisterForUpdate(GANK_RELEASE_NAME)
        PvpMode.Refresh()
    end)
end

local function ClearExternalProfile()
    local presets = addon.ContextPresets
    if presets and presets.ClearExternalProfile then
        presets.ClearExternalProfile(SOURCE)
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
    local now = Now()
    if stateId == runtime.currentState and not force then
        return
    end

    if not force and runtime.currentState ~= STATE_OFF
        and now - runtime.stateSince < MIN_STATE_HOLD_MS
        and stateId ~= STATE_PRESSURE and stateId ~= STATE_SUSPENDED then
        EVENT_MANAGER:UnregisterForUpdate(STATE_HOLD_UPDATE_NAME)
        EVENT_MANAGER:RegisterForUpdate(
            STATE_HOLD_UPDATE_NAME,
            MIN_STATE_HOLD_MS - (now - runtime.stateSince),
            function()
                EVENT_MANAGER:UnregisterForUpdate(STATE_HOLD_UPDATE_NAME)
                PvpMode.Refresh()
            end)
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(STATE_HOLD_UPDATE_NAME)

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
    runtime.stateSince = now
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
    local critical = healthRatio ~= nil and healthRatio <= config.criticalHealthThreshold
    local pressured = config.pressure and (
        now < runtime.pressureUntil
        or (healthRatio ~= nil and healthRatio <= config.lowHealthThreshold))

    -- At critical health, retain the already-established threat framing rather
    -- than starting another camera transition. If no threat profile exists yet,
    -- engaged is the single conservative entry before the lock takes effect.
    if config.stabilityLock and critical then
        if runtime.currentState == STATE_PRESSURE or runtime.currentState == STATE_ENGAGED then
            return runtime.currentState
        end
        return STATE_ENGAGED
    end

    if pressured then
        return STATE_PRESSURE
    end
    if runtime.inCombat or now < runtime.gankUntil then
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
        RegisterEvents()
    else
        UnregisterEvents()
    end

    if not runtime.inPvp then
        runtime.inCombat = false
        runtime.sprinting = false
        runtime.mounted = false
        runtime.dead = false
        runtime.siege = false
        runtime.health = nil
        runtime.healthMax = nil
        runtime.pressureUntil = 0
        runtime.gankUntil = 0
        runtime.writeFault = false
        runtime.manualSuspended = false
        runtime.manualZoomOverride = false
        PersistManualZoomOverride(false)
        ClearDamageSamples()
        ApplyState(STATE_OFF, true)
        return
    end

    runtime.inCombat = IsUnitInCombat and IsUnitInCombat(PLAYER_UNIT) or false
    runtime.mounted = IsMounted and IsMounted() or false
    runtime.dead = IsUnitDeadOrReincarnating
        and IsUnitDeadOrReincarnating(PLAYER_UNIT) or false
    runtime.siege = IsGameCameraSiegeControlled
        and IsGameCameraSiegeControlled() or false
    runtime.health, runtime.healthMax = ReadHealth()

    ApplyState(ResolveState(Now()), force)
end

local function OnCombatState(_, inCombat)
    runtime.inCombat = inCombat and true or false
    PvpMode.Refresh()
end

local function OnMountedState(_, mounted)
    runtime.mounted = mounted and true or false
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

local function OnCombatEvent(_, result, isError, _, _, _, _, _, _, targetType, hitValue)
    if isError or targetType ~= COMBAT_UNIT_TYPE_PLAYER or not DAMAGE_RESULTS[result] then
        return
    end

    local amount = tonumber(hitValue) or 0
    if amount <= 0 or not runtime.inPvp then
        return
    end

    local now = Now()
    if not runtime.inCombat then
        runtime.gankUntil = now + GANK_HOLD_MS
        ScheduleGankRelease()
    end

    runtime.damageSamples[#runtime.damageSamples + 1] = { at = now, amount = amount }
    local maximum = runtime.healthMax
    if config.pressure and maximum and maximum > 0
        and RecentDamage(now) >= maximum * config.burstThreshold then
        runtime.pressureUntil = now + PRESSURE_HOLD_MS
        SchedulePressureRelease()
    end
    PvpMode.Refresh()
end

local function OnSprintChanged(sprinting)
    runtime.sprinting = sprinting and true or false
    PvpMode.Refresh()
end

local function OnSafetyUpdate()
    local wasDead = runtime.dead
    local wasSiege = runtime.siege
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
    if runtime.dead ~= wasDead or runtime.siege ~= wasSiege
        or runtime.writeFault ~= wasWriteFault then
        PvpMode.Refresh(true)
    end
end

RegisterEvents = function()
    if runtime.eventsRegistered then return end
    runtime.eventsRegistered = true

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED, OnMountedState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE, OnPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_HEALTH)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(
        EVENT_NAMESPACE, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    local sprintWatch = addon.SprintWatch
    if sprintWatch and sprintWatch.Subscribe then
        sprintWatch.Subscribe(SOURCE, OnSprintChanged)
    end
    EVENT_MANAGER:RegisterForUpdate(SAFETY_UPDATE_NAME, SAFETY_INTERVAL_MS, OnSafetyUpdate)
end

UnregisterEvents = function()
    if not runtime.eventsRegistered then return end
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForUpdate(SAFETY_UPDATE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(PRESSURE_RELEASE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(GANK_RELEASE_NAME)
    EVENT_MANAGER:UnregisterForUpdate(STATE_HOLD_UPDATE_NAME)
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
    config.pressure = options.pressure ~= false
    config.stabilityLock = options.stabilityLock ~= false
    config.zoomAssist = options.zoomAssist ~= false
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
            runtime.pressureUntil = 0
            runtime.gankUntil = 0
            runtime.sprinting = false
            runtime.writeFault = false
            runtime.manualZoomOverride = false
            PersistManualZoomOverride(false)
            ClearDamageSamples()
            ApplyState(STATE_OFF, true)
        end
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
    runtime.pressureUntil = 0
    runtime.gankUntil = 0
    ClearDamageSamples()
end

function PvpMode.GetState()
    return runtime.currentState
end

function PvpMode.IsEnabled()
    return config.enabled
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
    runtime.manualSuspended = true
    ApplyState(STATE_SUSPENDED, true)
end
