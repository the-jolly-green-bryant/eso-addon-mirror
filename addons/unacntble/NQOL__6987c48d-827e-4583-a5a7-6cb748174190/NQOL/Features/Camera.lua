NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Camera = {}

local EVENT_NAMESPACE = "NQOL_Camera"
local MOUNTED_EVENT_NAMESPACE = EVENT_NAMESPACE .. "_Mounted"
local COMBAT_EVENT_NAMESPACE = EVENT_NAMESPACE .. "_Combat"
local MIN_ZOOM = 2
local MAX_ZOOM = 10
local ZOOM_STEP = 0.5
local MAX_ZOOM_CALLS = 18
local ZOOM_TOLERANCE = 0.01

local Abs = math.abs
local ToNumber = tonumber
local GetCameraSetting = GetSetting
local ZoomIn = CameraZoomIn
local ZoomOut = CameraZoomOut
local PlayerIsInCombat = IsUnitInCombat
local PlayerIsMounted = IsMounted

local defaults = {
    ui = {
        camera = {
            enabled = false,
            onFootZoom = MAX_ZOOM,
            mountedZoom = MAX_ZOOM,
            combatZoom = MAX_ZOOM,
        },
    },
}

local savedVariables
local initialized = false
local eventsRegistered = false

local function NormalizeZoom(value)
    value = NQOL.Util.Clamp(value, MIN_ZOOM, MAX_ZOOM)
    local steps = NQOL.Util.Round((value - MIN_ZOOM) / ZOOM_STEP)
    return MIN_ZOOM + (steps * ZOOM_STEP)
end

local function GetSettings()
    local uiSettings = NQOL.Settings.GetSection(savedVariables, defaults, "ui")
    local settings = NQOL.Settings.EnsureTable(uiSettings, "camera")
    local cameraDefaults = defaults.ui.camera

    NQOL.Settings.Boolean(settings, cameraDefaults, "enabled")
    NQOL.Settings.Default(settings, cameraDefaults, "onFootZoom")
    NQOL.Settings.Default(settings, cameraDefaults, "mountedZoom")
    NQOL.Settings.Default(settings, cameraDefaults, "combatZoom")

    settings.onFootZoom = NormalizeZoom(settings.onFootZoom)
    settings.mountedZoom = NormalizeZoom(settings.mountedZoom)
    settings.combatZoom = NormalizeZoom(settings.combatZoom)
    return settings
end

local function GetCurrentZoom()
    if not GetCameraSetting then
        return nil
    end

    return ToNumber(GetCameraSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
end

local function ApplyZoom(targetZoom)
    local currentZoom = GetCurrentZoom()
    if not currentZoom then
        return false
    end

    targetZoom = NormalizeZoom(targetZoom)
    local unchangedCalls = 0

    for _ = 1, MAX_ZOOM_CALLS do
        if Abs(currentZoom - targetZoom) <= ZOOM_TOLERANCE then
            return true
        end

        if currentZoom < targetZoom then
            if not ZoomOut then
                return false
            end
            ZoomOut()
        else
            if not ZoomIn then
                return false
            end
            ZoomIn()
        end

        local nextZoom = GetCurrentZoom()
        if not nextZoom then
            return false
        end

        if Abs(nextZoom - currentZoom) <= ZOOM_TOLERANCE then
            unchangedCalls = unchangedCalls + 1
            if unchangedCalls >= 2 then
                return false
            end
        else
            unchangedCalls = 0
            currentZoom = nextZoom
        end
    end

    return Abs(currentZoom - targetZoom) <= ZOOM_TOLERANCE
end

local function GetTargetZoom(settings)
    if PlayerIsInCombat and PlayerIsInCombat("player") then
        return settings.combatZoom
    end
    if PlayerIsMounted and PlayerIsMounted() then
        return settings.mountedZoom
    end
    return settings.onFootZoom
end

local function ApplyCurrentZoom()
    local settings = GetSettings()
    if settings.enabled ~= true then
        return false
    end

    return ApplyZoom(GetTargetZoom(settings))
end

local function OnStateChanged()
    ApplyCurrentZoom()
end

local function RegisterEvents()
    if eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(MOUNTED_EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED, OnStateChanged)
    EVENT_MANAGER:RegisterForEvent(COMBAT_EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnStateChanged)
    eventsRegistered = true
end

local function UnregisterEvents()
    if not eventsRegistered then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(MOUNTED_EVENT_NAMESPACE, EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(COMBAT_EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    eventsRegistered = false
end

local function RefreshRuntime(settings)
    if not initialized then
        return
    end

    settings = settings or GetSettings()
    if settings.enabled then
        RegisterEvents()
        ApplyZoom(GetTargetZoom(settings))
    else
        UnregisterEvents()
    end
end

local function SetZoom(key, value)
    local settings = GetSettings()
    settings[key] = NormalizeZoom(value)
    if settings.enabled then
        ApplyZoom(GetTargetZoom(settings))
    end
end

function Camera.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Camera.Initialize()
    if initialized then
        RefreshRuntime()
        return
    end

    initialized = true
    RefreshRuntime()
end

function Camera.GetEnabled() return GetSettings().enabled end
function Camera.GetEnabledDefault() return defaults.ui.camera.enabled end
function Camera.SetEnabled(value)
    local settings = GetSettings()
    settings.enabled = value == true
    RefreshRuntime(settings)
end

function Camera.GetOnFootZoom() return GetSettings().onFootZoom end
function Camera.GetOnFootZoomDefault() return defaults.ui.camera.onFootZoom end
function Camera.SetOnFootZoom(value) SetZoom("onFootZoom", value) end

function Camera.GetMountedZoom() return GetSettings().mountedZoom end
function Camera.GetMountedZoomDefault() return defaults.ui.camera.mountedZoom end
function Camera.SetMountedZoom(value) SetZoom("mountedZoom", value) end

function Camera.GetCombatZoom() return GetSettings().combatZoom end
function Camera.GetCombatZoomDefault() return defaults.ui.camera.combatZoom end
function Camera.SetCombatZoom(value) SetZoom("combatZoom", value) end

function Camera.GetZoomMin() return MIN_ZOOM end
function Camera.GetZoomMax() return MAX_ZOOM end
function Camera.GetZoomStep() return ZOOM_STEP end

function Camera.GetName() return NQOL.L("features.camera.name") end
function Camera.GetEntryTooltip() return NQOL.L("features.camera.entry_tooltip") end
function Camera.GetEnabledLabel() return NQOL.L("features.camera.enabled_label") end
function Camera.GetEnabledTooltip() return NQOL.L("features.camera.enabled_tooltip") end
function Camera.GetOnFootZoomLabel() return NQOL.L("features.camera.on_foot_zoom_label") end
function Camera.GetOnFootZoomTooltip() return NQOL.L("features.camera.on_foot_zoom_tooltip") end
function Camera.GetMountedZoomLabel() return NQOL.L("features.camera.mounted_zoom_label") end
function Camera.GetMountedZoomTooltip() return NQOL.L("features.camera.mounted_zoom_tooltip") end
function Camera.GetCombatZoomLabel() return NQOL.L("features.camera.combat_zoom_label") end
function Camera.GetCombatZoomTooltip() return NQOL.L("features.camera.combat_zoom_tooltip") end

NQOL.Features.Camera = Camera
