-- ===========================================================================
-- PvpMode.lua
-- ---------------------------------------------------------------------------
-- Simple PvP world mode. While the player is in AvA or a Battleground, the
-- core zoom handler may use a dedicated manual zoom step. No automatic zoom,
-- FOV, offset, combat, health, sprint, or situation profiles are applied.
-- ===========================================================================

local addon = BureauOfAcceptableViews
local private = addon.private

addon.PvpMode = addon.PvpMode or {}
local PvpMode = addon.PvpMode

local IsPlayerInAvAWorld = IsPlayerInAvAWorld
local IsActiveWorldBattleground = IsActiveWorldBattleground

local CameraSettings = addon.CameraSettings

local SCREEN_SHAKE_KEY = "screenShake"

local STATE_OFF = "off"
local STATE_ACTIVE = "active"
local STATE_SUSPENDED = "suspended"

local config = {
    enabled = false,
    cameraShake = false,
}

local runtime = {
    ready = false,
    inPvp = false,
    suspended = false,
    shakeSnapshot = nil,
    shakeSuppressed = false,
}

local function LogDebug(...)
    if private.LogDebug then private.LogDebug(...) end
end

local function LogWarn(...)
    if private.LogWarn then private.LogWarn(...) end
end

local function DetectPvpWorld()
    local inAva = IsPlayerInAvAWorld and IsPlayerInAvAWorld() or false
    local inBattleground = IsActiveWorldBattleground
        and IsActiveWorldBattleground() or false
    return inAva or inBattleground
end

local function PersistShakeSnapshot(value)
    local settings = addon.Settings
    if settings and settings.SetPvpScreenShakeSnapshot then
        settings.SetPvpScreenShakeSnapshot(value)
    end
end

local function LoadShakeSnapshot()
    local settings = addon.Settings
    if settings and settings.GetPvpScreenShakeSnapshot then
        return settings.GetPvpScreenShakeSnapshot()
    end
    return nil
end

local function SuppressShake()
    if config.cameraShake or runtime.shakeSuppressed then
        return true
    end
    if not (CameraSettings and CameraSettings.Get and CameraSettings.Set) then
        return false
    end

    if runtime.shakeSnapshot == nil then
        local value, ok = CameraSettings.Get(SCREEN_SHAKE_KEY)
        if not ok or value == nil then
            LogWarn("PvpMode: unable to capture camera shake")
            return false
        end
        runtime.shakeSnapshot = value
        PersistShakeSnapshot(value)
    end

    if not CameraSettings.Set(SCREEN_SHAKE_KEY, 0) then
        LogWarn("PvpMode: unable to suppress camera shake")
        return false
    end

    runtime.shakeSuppressed = true
    return true
end

local function RestoreShake()
    local snapshot = runtime.shakeSnapshot
    if snapshot == nil then
        snapshot = LoadShakeSnapshot()
        runtime.shakeSnapshot = snapshot
    end
    if snapshot == nil then
        runtime.shakeSuppressed = false
        return true
    end
    if not (CameraSettings and CameraSettings.Set) then
        return false
    end

    if not CameraSettings.Set(SCREEN_SHAKE_KEY, snapshot) then
        LogWarn("PvpMode: unable to restore camera shake")
        return false
    end

    runtime.shakeSnapshot = nil
    runtime.shakeSuppressed = false
    PersistShakeSnapshot(nil)
    return true
end

local function ApplyMode()
    local active = config.enabled and runtime.ready and runtime.inPvp
        and not runtime.suspended
    if active and not config.cameraShake then
        SuppressShake()
    else
        RestoreShake()
    end
end

function PvpMode.Refresh()
    local wasInPvp = runtime.inPvp
    runtime.inPvp = config.enabled and runtime.ready and DetectPvpWorld() or false

    if runtime.inPvp ~= wasInPvp then
        runtime.suspended = false
        LogDebug("PvpMode: world mode %s", runtime.inPvp and "active" or "off")
    elseif not runtime.inPvp then
        runtime.suspended = false
    end

    ApplyMode()
end

function PvpMode.Configure(options)
    options = options or {}
    local enabled = options.enabled and true or false
    local cameraShake = options.cameraShake and true or false

    if enabled ~= config.enabled then
        config.enabled = enabled
        runtime.suspended = false
    end
    config.cameraShake = cameraShake

    if runtime.ready then
        PvpMode.Refresh()
    elseif not config.enabled or config.cameraShake then
        RestoreShake()
    end
end

function PvpMode.ActivateAfterRecovery()
    runtime.ready = true
    runtime.shakeSnapshot = LoadShakeSnapshot()
    PvpMode.Refresh()
end

function PvpMode.OnPlayerDeactivated()
    RestoreShake()
    runtime.inPvp = false
    runtime.suspended = false
end

function PvpMode.GetState()
    if runtime.inPvp and runtime.suspended then
        return STATE_SUSPENDED
    end
    if config.enabled and runtime.ready and runtime.inPvp then
        return STATE_ACTIVE
    end
    return STATE_OFF
end

function PvpMode.IsEnabled()
    return config.enabled
end

function PvpMode.IsActiveInPvpWorld()
    return config.enabled and runtime.ready and runtime.inPvp
        and not runtime.suspended
end

function PvpMode.EmergencySuspend()
    runtime.suspended = runtime.inPvp and true or false
    RestoreShake()
end
