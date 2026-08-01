
TheSynapticRegistry = TheSynapticRegistry or {}

local Addon = TheSynapticRegistry

Addon.Name = "TheSynapticRegistry"
Addon.Version = "0.1.8"
Addon.EventNamespace = "TheSynapticRegistry"
Addon.LogColor = "B7E3CF"
Addon.DefaultLogLevel = "Info"
Addon.LogLevel = Addon.DefaultLogLevel
Addon.LogUseChatSystem = true



Addon.DefaultLockoutMs = 20000



Addon.AlertColors = {
    offered = { 1.00, 0.84, 0.30 },
    ready = { 0.60, 0.93, 0.55 },
}

Addon.Strings = {
    offered = "Use %s.",
    ready = "Synergy ready.",
    enabled = "The Registry attends.",
    disabled = "The Registry rests.",
    statusHeader = "Synaptic Registry status",
    diagnosticsEnabled = "Diagnostics wake.",
    diagnosticsDisabled = "Diagnostics sleep.",
    diagnosticsReset = "Diagnostics reset.",
    broadDiagnosticsEnabled = "Wide diagnostics wake.",
    broadDiagnosticsDisabled = "Wide diagnostics sleep.",
    unknownCommand = "Unknown /synreg command.",
    validCommands = "on, off, status, report, cue on, cue off, gate on, gate off, "
        .. "diag on, diag off, diag reset, broad on, broad off",
}

Addon.SettingDefaults = {
    enabled = true,
    alertThrottleMs = 2000,
    alertDurationMs = 2500,
    readyCue = true,
    groupOnly = false,
    diagnosticsEnabled = false,
    diagnosticBroadEnabled = false,
}

local function applyDefaults(settings)
    for key, value in pairs(Addon.SettingDefaults) do
        if settings[key] == nil then
            settings[key] = value
        end
    end

    return settings
end

local function resolveProfile()
    if type(GetWorldName) == "function" then
        local world = GetWorldName()

        if type(world) == "string" and world ~= "" then
            return world
        end
    end

    return "default"
end

function Addon.InitializeSettings()
    local saved = TheSynapticRegistrySaved

    if type(saved) ~= "table" then
        saved = {}
        TheSynapticRegistrySaved = saved
    end

    local profile = resolveProfile()

    if type(saved[profile]) ~= "table" then
        saved[profile] = {}
    end

    Addon.Settings = applyDefaults(saved[profile])
    return Addon.Settings
end

function Addon.GetSettings()
    if type(Addon.Settings) == "table" then
        return Addon.Settings
    end

    return Addon.InitializeSettings()
end
