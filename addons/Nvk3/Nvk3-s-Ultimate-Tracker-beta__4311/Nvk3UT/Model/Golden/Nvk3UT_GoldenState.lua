-- Model/Golden/Nvk3UT_GoldenState.lua
-- SavedVariables wrapper for Golden tracker UI state. Nil-safe accessors only; no UI or event side-effects.

Nvk3UT = Nvk3UT or {}

local GoldenState = Nvk3UT.GoldenState or {}
Nvk3UT.GoldenState = GoldenState

GoldenState._root = type(GoldenState._root) == "table" and GoldenState._root or nil
GoldenState._config = type(GoldenState._config) == "table" and GoldenState._config or nil
GoldenState._state = type(GoldenState._state) == "table" and GoldenState._state or nil
GoldenState._defaults = type(GoldenState._defaults) == "table" and GoldenState._defaults or nil
GoldenState._status = type(GoldenState._status) == "table" and GoldenState._status or nil

local VALID_COMPLETED_HANDLING = {
    hide = true,
    recolor = true,
    showOpen = true,
}

local DEFAULT_BEHAVIOR = {
    headerExpanded = true,
    categoryExpanded = true,
    entryExpanded = true,
    dailyExpanded = true,
    weeklyExpanded = true,
    completedHandling = "hide",
}

local DEFAULT_STATUS = {
    isAvailable = false,
    isLocked = false,
    hasEntries = false,
}

local function getSafeCall()
    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" and type(root.SafeCall) == "function" then
        return root.SafeCall
    end
    return nil
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local safe = getSafeCall()
    if type(safe) == "function" then
        return safe(fn, ...)
    end

    local ok, results = pcall(function(...)
        return { fn(...) }
    end, ...)
    if ok and type(results) == "table" then
        if unpack then
            return unpack(results)
        end
        return results[1]
    end

    return nil
end

local function resolveGlobalGoldenDefaults()
    local stateInit = rawget(_G, "Nvk3UT_StateInit")
    if type(stateInit) == "table" then
        local defaultSV = stateInit.defaultSV
        if type(defaultSV) == "table" then
            local trackerDefaults = defaultSV.TrackerDefaults
            if type(trackerDefaults) == "table" then
                local goldenDefaults = trackerDefaults.GoldenDefaults
                if type(goldenDefaults) == "table" then
                    return goldenDefaults
                end
            end
        end
    end

    return nil
end

local function newStatus()
    return {
        isAvailable = false,
        isLocked = false,
        hasEntries = false,
    }
end

local function copyStatus(status)
    local snapshot = newStatus()
    if type(status) == "table" then
        snapshot.isAvailable = status.isAvailable == true
        snapshot.isLocked = status.isLocked == true
        snapshot.hasEntries = status.hasEntries == true
    end
    return snapshot
end

local function ensureStatus(self, create)
    local status = self._status
    if type(status) == "table" then
        return status
    end

    if not create then
        return nil
    end

    status = newStatus()
    self._status = status
    return status
end

local function deepCopyTable(source)
    if type(source) ~= "table" then
        return nil
    end

    local function copier(tbl, seen)
        if seen[tbl] then
            return seen[tbl]
        end

        local clone = {}
        seen[tbl] = clone

        for key, value in pairs(tbl) do
            if type(value) == "table" then
                clone[key] = copier(value, seen)
            else
                clone[key] = value
            end
        end

        return clone
    end

    local function copyWrapper()
        return copier(source, {})
    end

    local copy = safeCall(copyWrapper)
    if type(copy) == "table" then
        return copy
    end

    local ok, fallback = pcall(copyWrapper)
    if ok and type(fallback) == "table" then
        return fallback
    end

    return nil
end

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return root:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local sv = root and (root.sv or root.SV)
    if type(sv) == "table" and sv.debug ~= nil then
        return sv.debug == true
    end

    return false
end

local function debugLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local message
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, fmt, ...)
        message = ok and formatted or tostring(fmt)
    else
        message = tostring(fmt)
    end

    local payload = string.format("[GoldenState] %s", tostring(message))
    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" and type(root.Debug) == "function" then
        safeCall(root.Debug, payload)
    elseif type(d) == "function" then
        d(string.format("[Nvk3UT] %s", payload))
    end
end

local function statusDebugLog(self, key, value)
    if not isDebugEnabled() then
        return
    end

    debugLog("status %s=%s", tostring(key), tostring(value))
end

local function fetchConfig(self)
    local config = self._config
    if type(config) == "table" then
        return config
    end

    local root = self._root
    if type(root) ~= "table" then
        return nil
    end

    local golden = root.Golden
    if type(golden) ~= "table" then
        return nil
    end

    self._config = golden
    return golden
end

local function ensureConfig(self)
    local config = fetchConfig(self)
    if type(config) == "table" then
        return config
    end

    local root = self._root
    if type(root) ~= "table" then
        return nil
    end

    local golden = {}
    root.Golden = golden
    self._config = golden
    return golden
end

local function getStateTable(self, create)
    local state = self._state
    if type(state) == "table" then
        return state
    end

    local config = fetchConfig(self)
    if type(config) == "table" and type(config.State) == "table" then
        self._state = config.State
        return self._state
    end

    if not create then
        return nil
    end

    config = ensureConfig(self)
    if type(config) ~= "table" then
        return nil
    end

    state = config.State
    if type(state) ~= "table" then
        state = {}
        config.State = state
    end

    self._state = state
    return state
end

local function getDefaults(self)
    local defaults = self._defaults
    if type(defaults) == "table" then
        return defaults
    end

    local config = fetchConfig(self)
    if type(config) == "table" and type(config.Defaults) == "table" then
        self._defaults = config.Defaults
        return self._defaults
    end

    local globalDefaults = resolveGlobalGoldenDefaults()
    if type(globalDefaults) == "table" then
        self._defaults = globalDefaults
        return self._defaults
    end

    return nil
end

local function resolveBehaviorDefaults(self)
    local defaults = getDefaults(self)
    if type(defaults) == "table" then
        local behavior = defaults.Behavior
        if type(behavior) == "table" then
            return behavior
        end

        local candidate = {}
        local hasValue = false

        local header = defaults.headerExpanded or defaults.HeaderExpanded
        if header ~= nil then
            candidate.headerExpanded = header
            hasValue = true
        end

        local daily = defaults.dailyExpanded or defaults.DailyExpanded
        if daily ~= nil then
            candidate.dailyExpanded = daily
            hasValue = true
        end

        local categoryExpanded = defaults.categoryExpanded or defaults.CategoryExpanded
        if categoryExpanded ~= nil then
            candidate.categoryExpanded = categoryExpanded
            hasValue = true
        end

        local entryExpanded = defaults.entryExpanded or defaults.EntryExpanded
        if entryExpanded ~= nil then
            candidate.entryExpanded = entryExpanded
            hasValue = true
        end

        local weekly = defaults.weeklyExpanded or defaults.WeeklyExpanded
        if weekly ~= nil then
            candidate.weeklyExpanded = weekly
            hasValue = true
        end

        local handling = defaults.completedHandling or defaults.CompletedHandling
        if handling ~= nil then
            candidate.completedHandling = handling
            hasValue = true
        end

        if hasValue then
            return candidate
        end
    end

    return DEFAULT_BEHAVIOR
end

local function normalizeBoolean(value, fallback)
    if value == nil then
        return fallback and true or false
    end

    if type(value) == "boolean" then
        return value
    end

    if type(value) == "number" then
        if value == 0 then
            return false
        end
        return true
    end

    if type(value) == "string" then
        local trimmed = value:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed ~= "" then
            local lowered = string.lower(trimmed)
            if lowered == "true" or lowered == "1" or lowered == "yes" or lowered == "on" then
                return true
            end
            if lowered == "false" or lowered == "0" or lowered == "no" or lowered == "off" then
                return false
            end
        end
    end

    return value and true or false
end

local function resolveDefaultBoolean(self, key)
    local behavior = resolveBehaviorDefaults(self)
    local value = behavior[key]
    if value == nil then
        local altKey = key:gsub("^%l", string.upper)
        value = behavior[altKey]
    end

    if key == "headerExpanded" or key == "dailyExpanded" or key == "weeklyExpanded"
        or key == "categoryExpanded" or key == "entryExpanded" then
        return normalizeBoolean(value, true)
    end

    return normalizeBoolean(value, false)
end

local function normalizeHandling(value)
    if type(value) ~= "string" then
        return nil
    end

    local lowered = string.lower(value)
    if VALID_COMPLETED_HANDLING[lowered] then
        return lowered
    end

    return nil
end

local function resolveDefaultHandling(self)
    local behavior = resolveBehaviorDefaults(self)
    local candidate = behavior.completedHandling or behavior.CompletedHandling
    local normalized = normalizeHandling(candidate)
    if normalized then
        return normalized
    end

    local defaults = getDefaults(self)
    if type(defaults) == "table" then
        normalized = normalizeHandling(defaults.CompletedHandling or defaults.completedHandling)
        if normalized then
            return normalized
        end
    end

    local config = fetchConfig(self)
    if type(config) == "table" then
        normalized = normalizeHandling(config.CompletedHandling or config.completedHandling)
        if normalized then
            return normalized
        end
    end

    return DEFAULT_BEHAVIOR.completedHandling
end

local function resolveEnabledDefault(self)
    local defaults = getDefaults(self)
    if type(defaults) == "table" then
        if defaults.Enabled ~= nil then
            return defaults.Enabled ~= false
        end

        local behavior = defaults.Behavior
        if type(behavior) == "table" and behavior.Enabled ~= nil then
            return behavior.Enabled ~= false
        end
    end

    return true
end

local function resolveColors(self)
    local config = fetchConfig(self)
    if type(config) == "table" and type(config.Colors) == "table" then
        return config.Colors
    end

    local defaults = getDefaults(self)
    if type(defaults) == "table" then
        local colors = defaults.Colors
        if type(colors) == "table" then
            return colors
        end
    end

    return nil
end

local function resolveFonts(self)
    local config = fetchConfig(self)
    if type(config) == "table" then
        if type(config.Fonts) == "table" then
            return config.Fonts
        end

        local tracker = config.Tracker
        if type(tracker) == "table" and type(tracker.Fonts) == "table" then
            return tracker.Fonts
        end
    end

    local defaults = getDefaults(self)
    if type(defaults) == "table" then
        if type(defaults.Fonts) == "table" then
            return defaults.Fonts
        end

        local tracker = defaults.Tracker
        if type(tracker) == "table" and type(tracker.Fonts) == "table" then
            return tracker.Fonts
        end
    end

    return nil
end

local function copyOrEmpty(source)
    local copy = deepCopyTable(source)
    if type(copy) == "table" then
        return copy
    end
    return {}
end

local function getStateBoolean(self, key)
    local state = getStateTable(self, false)
    if type(state) == "table" then
        local value = state[key]
        if value == nil then
            local altKey = key:gsub("^%l", string.upper)
            value = state[altKey]
        end
        if value ~= nil then
            return value ~= false
        end
    end

    return resolveDefaultBoolean(self, key)
end

local function setStateBoolean(self, key, value)
    if value == nil then
        return false
    end

    local state = getStateTable(self, true)
    if type(state) ~= "table" then
        return false
    end

    local normalized = value and true or false
    state[key] = normalized

    debugLog("set %s=%s", tostring(key), tostring(normalized))

    return true
end

local function getCategoryExpansionMap(self, create)
    local state = getStateTable(self, create)
    if type(state) ~= "table" then
        return nil
    end

    local expansion = state.categoryExpansion
    if type(expansion) ~= "table" then
        if not create then
            return nil
        end

        expansion = {}
        state.categoryExpansion = expansion
    end

    return expansion
end

function GoldenState:Init(svRoot)
    if type(svRoot) ~= "table" then
        self._root = nil
        self._config = nil
        self._state = nil
        self._defaults = nil
        return nil
    end

    self._root = svRoot

    local config = svRoot.Golden
    if type(config) ~= "table" then
        config = {}
        svRoot.Golden = config
    end
    self._config = config

    local state = config.State
    if type(state) ~= "table" then
        state = {}
        config.State = state
    end
    self._state = state

    if type(config.Defaults) == "table" then
        self._defaults = config.Defaults
    else
        self._defaults = resolveGlobalGoldenDefaults()
    end

    ensureStatus(self, true)

    debugLog("init")

    return state
end

function GoldenState:GetSystemStatus()
    return copyStatus(self._status)
end

function GoldenState:IsSystemAvailable()
    local status = self._status
    if type(status) ~= "table" then
        return DEFAULT_STATUS.isAvailable
    end
    return status.isAvailable == true
end

function GoldenState:IsSystemLocked()
    local status = self._status
    if type(status) ~= "table" then
        return DEFAULT_STATUS.isLocked
    end
    return status.isLocked == true
end

function GoldenState:HasEntries()
    local status = self._status
    if type(status) ~= "table" then
        return DEFAULT_STATUS.hasEntries
    end
    return status.hasEntries == true
end

function GoldenState:SetSystemAvailable(isAvailable)
    local status = ensureStatus(self, true)
    if type(status) ~= "table" then
        return false
    end

    local normalized = isAvailable == true
    if status.isAvailable ~= normalized then
        status.isAvailable = normalized
        if not normalized then
            status.hasEntries = false
        else
            status.isLocked = false
        end
        statusDebugLog(self, "available", normalized)
    elseif normalized and status.isLocked then
        status.isLocked = false
    end

    return status.isAvailable == true
end

function GoldenState:SetSystemLocked(isLocked)
    local status = ensureStatus(self, true)
    if type(status) ~= "table" then
        return false
    end

    local normalized = isLocked == true
    if status.isLocked ~= normalized then
        status.isLocked = normalized
        if normalized then
            status.isAvailable = false
            status.hasEntries = false
        end
        statusDebugLog(self, "locked", normalized)
    elseif normalized then
        status.isAvailable = false
        status.hasEntries = false
    end

    return status.isLocked == true
end

function GoldenState:SetHasEntries(hasEntries)
    local status = ensureStatus(self, true)
    if type(status) ~= "table" then
        return false
    end

    local normalized = hasEntries == true
    if status.hasEntries ~= normalized then
        status.hasEntries = normalized
        statusDebugLog(self, "hasEntries", normalized)
    end

    if normalized then
        status.isAvailable = true
    end

    return status.hasEntries == true
end

function GoldenState:ResetSystemStatus()
    self._status = copyStatus(DEFAULT_STATUS)
    statusDebugLog(self, "reset", "defaults")
    return true
end

function GoldenState:IsHeaderExpanded()
    local expanded = getStateBoolean(self, "headerExpanded")
    return expanded ~= false
end

function GoldenState:SetHeaderExpanded(expanded)
    if expanded == nil then
        return false
    end

    local state = getStateTable(self, true)
    if type(state) ~= "table" then
        return false
    end

    local previous = state.headerExpanded
    local normalized = expanded and true or false
    local changed = previous ~= normalized

    state.headerExpanded = normalized

    debugLog("set headerExpanded: %s -> %s", tostring(previous), tostring(normalized))

    return changed
end

function GoldenState:IsCategoryHeaderExpanded()
    return getStateBoolean(self, "categoryExpanded")
end

function GoldenState:SetCategoryHeaderExpanded(expanded)
    return setStateBoolean(self, "categoryExpanded", expanded)
end

function GoldenState:IsEntryExpanded()
    return getStateBoolean(self, "entryExpanded")
end

function GoldenState:SetEntryExpanded(expanded)
    return setStateBoolean(self, "entryExpanded", expanded)
end

function GoldenState:IsDailyExpanded()
    return getStateBoolean(self, "dailyExpanded")
end

function GoldenState:SetDailyExpanded(expanded)
    return setStateBoolean(self, "dailyExpanded", expanded)
end

function GoldenState:IsWeeklyExpanded()
    return getStateBoolean(self, "weeklyExpanded")
end

function GoldenState:SetWeeklyExpanded(expanded)
    return setStateBoolean(self, "weeklyExpanded", expanded)
end

function GoldenState:IsCategoryExpanded(key)
    if key == nil or key == "" then
        return true
    end

    local expansion = getCategoryExpansionMap(self, false)
    if type(expansion) ~= "table" then
        return true
    end

    local value = expansion[key]
    if value == nil then
        return true
    end

    return value ~= false
end

function GoldenState:SetCategoryExpanded(key, expanded)
    if key == nil or key == "" then
        return false
    end

    local expansion = getCategoryExpansionMap(self, true)
    if type(expansion) ~= "table" then
        return false
    end

    local normalized = expanded ~= false
    expansion[key] = normalized

    debugLog("set categoryExpanded[%s]=%s", tostring(key), tostring(normalized))

    return normalized
end

function GoldenState:GetCompletedHandling()
    local state = getStateTable(self, false)
    if type(state) == "table" then
        local normalized = normalizeHandling(state.completedHandling or state.CompletedHandling)
        if normalized then
            return normalized
        end
    end

    return resolveDefaultHandling(self)
end

function GoldenState:SetCompletedHandling(value)
    local normalized = normalizeHandling(value)
    if not normalized then
        return false
    end

    local state = getStateTable(self, true)
    if type(state) ~= "table" then
        return false
    end

    state.completedHandling = normalized

    debugLog("set completedHandling=%s", normalized)

    return true
end

function GoldenState:IsEnabled()
    local config = fetchConfig(self)
    if type(config) == "table" and config.Enabled ~= nil then
        return config.Enabled ~= false
    end

    return resolveEnabledDefault(self)
end

function GoldenState:GetColors()
    local colors = resolveColors(self)
    return copyOrEmpty(colors)
end

function GoldenState:GetFonts()
    local fonts = resolveFonts(self)
    return copyOrEmpty(fonts)
end

function GoldenState:ResetToDefaults()
    local state = getStateTable(self, true)
    if type(state) ~= "table" then
        return false
    end

    state.headerExpanded = resolveDefaultBoolean(self, "headerExpanded")
    state.categoryExpanded = resolveDefaultBoolean(self, "categoryExpanded")
    state.entryExpanded = resolveDefaultBoolean(self, "entryExpanded")
    state.dailyExpanded = resolveDefaultBoolean(self, "dailyExpanded")
    state.weeklyExpanded = resolveDefaultBoolean(self, "weeklyExpanded")
    state.completedHandling = resolveDefaultHandling(self)
    state.categoryExpansion = nil

    debugLog("reset to defaults")

    return true
end

return GoldenState
