local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Endeavor = {}
Endeavor.__index = Endeavor

local MODULE_TAG = addonName .. ".Endeavor"

local state = {
    container = nil,
    initialized = false,
    lastHeight = 0,
}

local function safeDebug(fmt, ...)
    local root = rawget(_G, addonName)
    if type(root) ~= "table" then
        return
    end

    local diagnostics = root.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled("Endeavor", fmt, ...)
        return
    end

    local debugMethod = root.Debug
    if type(debugMethod) == "function" then
        if fmt == nil then
            debugMethod(root, ...)
        else
            debugMethod(root, fmt, ...)
        end
        return
    end

    if fmt == nil then
        return
    end

    local message = string.format(tostring(fmt), ...)
    local prefix = string.format("[%s]", MODULE_TAG)
    if d then
        d(prefix, message)
    elseif print then
        print(prefix, message)
    end
end

local function coerceNumber(value)
    local numeric = tonumber(value)
    if numeric == nil then
        return 0
    end

    if numeric ~= numeric then
        return 0
    end

    return numeric
end

local function getAddon()
    return rawget(_G, addonName)
end

local function getSafeCall()
    local addon = getAddon()
    if type(addon) == "table" then
        local safeCall = rawget(addon, "SafeCall")
        if type(safeCall) == "function" then
            return safeCall
        end
    end

    return nil
end

local function runSafe(tag, fn)
    if type(fn) ~= "function" then
        return nil
    end

    local safeCall = getSafeCall()
    if safeCall then
        return safeCall(function()
            return fn()
        end)
    end

    local ok, results = pcall(function()
        return { fn() }
    end)

    if ok and type(results) == "table" then
        return unpack(results)
    end

    return nil
end

local function getTracker()
    local addon = getAddon()
    if type(addon) ~= "table" then
        return nil
    end

    local tracker = rawget(addon, "EndeavorTracker")
    if type(tracker) ~= "table" then
        return nil
    end

    return tracker
end

local function resolveContainerName(container)
    if container and type(container.GetName) == "function" then
        local ok, name = pcall(container.GetName, container)
        if ok then
            return name
        end
    end

    return nil
end

function Endeavor.Init(hostContainer)
    if hostContainer ~= nil then
        state.container = hostContainer
    end

    local container = state.container
    if container == nil then
        safeDebug("Endeavor.Init: container=nil (deferred)")
        return
    end

    local tracker = getTracker()
    if not tracker or type(tracker.Init) ~= "function" then
        safeDebug("Endeavor.Init: tracker unavailable")
        return
    end

    runSafe("Endeavor.Init", function()
        tracker.Init(container)
    end)

    state.initialized = true
    state.lastHeight = 0

    safeDebug("Endeavor.Init: container=%s", resolveContainerName(container) or "nil")
end

local function ensureInitialized()
    if state.initialized then
        return
    end

    Endeavor.Init(state.container)
end

local function measureHeight(tracker)
    if not tracker or type(tracker.GetHeight) ~= "function" then
        return 0
    end

    local measured = runSafe("Endeavor.GetHeight", function()
        return tracker.GetHeight()
    end)

    return coerceNumber(measured)
end

function Endeavor.Refresh(viewModel)
    ensureInitialized()

    local tracker = getTracker()
    if not tracker then
        state.lastHeight = 0
        return 0
    end

    local payload = {}
    if type(viewModel) == "table" then
        payload = viewModel
    end

    if type(tracker.Refresh) == "function" then
        runSafe("Endeavor.Refresh", function()
            tracker.Refresh(payload)
        end)
    end

    local height = measureHeight(tracker)
    state.lastHeight = height

    local count = 0
    if type(payload.items) == "table" then
        count = #payload.items
    end

    safeDebug("Endeavor.Refresh: items=%d height=%d", count, height)

    return height
end

function Endeavor.GetHeight()
    local tracker = getTracker()
    if not tracker then
        return coerceNumber(state.lastHeight)
    end

    local height = measureHeight(tracker)
    if height == 0 then
        height = coerceNumber(state.lastHeight)
    else
        state.lastHeight = height
    end

    return height
end

Nvk3UT.Endeavor = Endeavor

return Endeavor
