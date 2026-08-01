NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local LuaGc = {}

local FEATURE_NAME = "Lua GC"
local EVENT_NAMESPACE = "NQOL_LuaGc"
local GC_STEP_NAMESPACE = EVENT_NAMESPACE .. "_Step"
local CHECK_INTERVAL_MS = 60000
local CLEANUP_COOLDOWN_MS = 600000
local USAGE_THRESHOLD = 0.60
local MIN_REPORTABLE_RECOVERY_MB = 0.005
local GC_STEP_INTERVAL_MS = 50
local GC_STEP_SIZE = 100
local GC_MAX_STEPS = 8

local defaults = {
    utility = {
        luaGc = false,
        luaGcDebugOutput = false,
    },
}

local savedVariables
local initialized = false
local running = false
local cleanupInProgress = false
local lastCleanupMs = 0
local cleanupBeforePool
local cleanupStepsRemaining = 0

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Boolean(settings, defaults.utility, "luaGc")
    NQOL.Settings.Boolean(settings, defaults.utility, "luaGcDebugOutput")

    return settings
end

local function IsEnabled()
    return GetSettings().luaGc == true
end

local function IsPoolApiAvailable()
    return type(GetTotalUserAddOnMemoryPoolUsageMB) == "function"
        and type(GetTotalUserAddOnMemoryPoolCapacityMB) == "function"
end

local function GetPoolUsage()
    if not IsPoolApiAvailable() then
        return nil, nil
    end

    local usage = GetTotalUserAddOnMemoryPoolUsageMB()
    local capacity = GetTotalUserAddOnMemoryPoolCapacityMB()
    if not usage or not capacity or capacity <= 0 then
        return nil, nil
    end

    return usage, capacity
end

local function GetCurrentPoolUsage()
    if type(GetTotalUserAddOnMemoryPoolUsageMB) ~= "function" then
        return nil
    end

    return GetTotalUserAddOnMemoryPoolUsageMB()
end

local function IsInCombat()
    return IsUnitInCombat and IsUnitInCombat("player") == true
end

local function FormatMb(value)
    return string.format("%.2f MB", value or 0)
end

local function GetTimeMilliseconds()
    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end

    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end

    return 0
end

local function ReportCleanup(beforePool, afterPool)
    if GetSettings().luaGcDebugOutput ~= true then
        return
    end

    local recovered = math.max((beforePool or 0) - (afterPool or 0), 0)
    if recovered < MIN_REPORTABLE_RECOVERY_MB then
        return
    end

    local message = "Recovered " .. FormatMb(recovered) .. " addon memory."

    if afterPool and beforePool then
        message = message .. " Pool " .. FormatMb(beforePool) .. " -> " .. FormatMb(afterPool) .. "."
    end

    NQOL.Chat.Message(message, FEATURE_NAME)
end

local function ReportManualCleanup(beforeLua, afterLua, beforePool, afterPool)
    local recoveredLua = math.max((beforeLua or 0) - (afterLua or 0), 0)
    local message = "Manual GC complete. Lua " .. FormatMb(beforeLua) .. " -> " .. FormatMb(afterLua)
        .. " (" .. FormatMb(recoveredLua) .. " recovered)."

    if beforePool and afterPool then
        local recoveredPool = math.max(beforePool - afterPool, 0)
        message = message .. " Pool " .. FormatMb(beforePool) .. " -> " .. FormatMb(afterPool)
            .. " (" .. FormatMb(recoveredPool) .. " recovered)."
    end

    NQOL.Chat.Message(message, FEATURE_NAME)
end

local function FinishCleanup(report)
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(GC_STEP_NAMESPACE)
    end

    local beforePool = cleanupBeforePool
    local afterPool = GetCurrentPoolUsage() or beforePool

    cleanupInProgress = false
    cleanupBeforePool = nil
    cleanupStepsRemaining = 0

    if report ~= false then
        ReportCleanup(beforePool, afterPool)
    end
end

local function RunCleanupStep()
    if not IsEnabled() or IsInCombat() then
        FinishCleanup(false)
        return
    end

    if cleanupStepsRemaining <= 0 then
        FinishCleanup(true)
        return
    end

    cleanupStepsRemaining = cleanupStepsRemaining - 1
    local completed = collectgarbage("step", GC_STEP_SIZE)
    if completed or cleanupStepsRemaining <= 0 then
        FinishCleanup(true)
    end
end

local function RunCleanup()
    if cleanupInProgress or not IsEnabled() or IsInCombat() then
        return
    end

    local now = GetTimeMilliseconds()
    if lastCleanupMs > 0 and now - lastCleanupMs < CLEANUP_COOLDOWN_MS then
        return
    end

    local beforePool, capacity = GetPoolUsage()
    if not beforePool or beforePool / capacity < USAGE_THRESHOLD then
        return
    end

    cleanupInProgress = true
    lastCleanupMs = now
    cleanupBeforePool = beforePool
    cleanupStepsRemaining = GC_MAX_STEPS

    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForUpdate(GC_STEP_NAMESPACE, GC_STEP_INTERVAL_MS, RunCleanupStep)
        RunCleanupStep()
    else
        while cleanupStepsRemaining > 0 and not collectgarbage("step", GC_STEP_SIZE) do
            cleanupStepsRemaining = cleanupStepsRemaining - 1
        end
        FinishCleanup(true)
    end
end

local function StopTimer()
    if not running or not EVENT_MANAGER then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(EVENT_NAMESPACE)
    running = false
end

local function StartTimer()
    if running or not EVENT_MANAGER or not IsPoolApiAvailable() then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(EVENT_NAMESPACE, CHECK_INTERVAL_MS, RunCleanup)
    running = true
end

local function RefreshTimer()
    if IsEnabled() then
        StartTimer()
        RunCleanup()
    else
        FinishCleanup(false)
        StopTimer()
    end
end

function LuaGc.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function LuaGc.Initialize()
    if initialized then
        return
    end

    initialized = true
    RefreshTimer()
end

function LuaGc.GetEnabled()
    return IsEnabled()
end

function LuaGc.SetEnabled(value)
    GetSettings().luaGc = value == true
    RefreshTimer()
end

function LuaGc.GetEnabledLabel()
    return NQOL.L("ui.navigation.lua_gc_be3883a")
end

function LuaGc.GetEnabledTooltip()
    return NQOL.L("features.lua_gc.enabled_tooltip")
end

function LuaGc.GetDebugOutput()
    return GetSettings().luaGcDebugOutput == true
end

function LuaGc.SetDebugOutput(value)
    GetSettings().luaGcDebugOutput = value == true
end

function LuaGc.RunFullCleanup()
    if type(collectgarbage) ~= "function" then
        NQOL.Chat.Message("Lua garbage collection is not available.", FEATURE_NAME)
        return
    end

    if cleanupInProgress then
        FinishCleanup(false)
    end

    local beforeLua = collectgarbage("count") / 1024
    local beforePool = GetCurrentPoolUsage()

    collectgarbage("collect")

    local afterLua = collectgarbage("count") / 1024
    local afterPool = GetCurrentPoolUsage()

    lastCleanupMs = GetTimeMilliseconds()
    ReportManualCleanup(beforeLua, afterLua, beforePool, afterPool)
end

function LuaGc.GetDebugOutputLabel()
    return "Debug output"
end

function LuaGc.GetDebugOutputTooltip()
    return "Prints a chat message after Lua GC runs, including the addon memory recovered."
end

function LuaGc.GetRunFullCleanupLabel()
    return "Perfom GC now"
end

function LuaGc.GetRunFullCleanupTooltip()
    return "Runs a full Lua garbage collection immediately and reports the memory change in chat."
end

NQOL.Features.LuaGc = LuaGc
