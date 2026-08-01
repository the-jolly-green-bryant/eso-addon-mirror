-- Model/Endeavor/Nvk3UT_EndeavorState.lua
-- SavedVariables wrapper for Endeavor tracker UI state. No UI or event side-effects.

Nvk3UT = Nvk3UT or {}

local EndeavorState = Nvk3UT.EndeavorState or {}
Nvk3UT.EndeavorState = EndeavorState

EndeavorState._root = type(EndeavorState._root) == "table" and EndeavorState._root or nil
EndeavorState._sv = type(EndeavorState._sv) == "table" and EndeavorState._sv or nil

local DEFAULTS = {
    expanded = true,
    position = { x = nil, y = nil },
    window = { locked = false },
    categories = {},
    lastRefresh = 0,
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

    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end

    return nil
end

local function deepCopyTable(source)
    if type(source) ~= "table" then
        return nil
    end

    local function copier(tbl)
        local copy = {}
        for key, value in pairs(tbl) do
            if type(value) == "table" then
                copy[key] = copier(value)
            else
                copy[key] = value
            end
        end
        return copy
    end

    local copy = safeCall(copier, source)
    if type(copy) == "table" then
        return copy
    end

    return copier(source)
end

local function mergeDefaults(target, defaults)
    if type(defaults) ~= "table" then
        return target
    end

    if type(target) ~= "table" then
        target = {}
    end

    for key, value in pairs(defaults) do
        local existing = target[key]
        if type(value) == "table" then
            if type(existing) ~= "table" then
                target[key] = deepCopyTable(value) or {}
            else
                mergeDefaults(existing, value)
            end
        elseif existing == nil then
            target[key] = value
        end
    end

    return target
end

local function normalizeCategories(categories)
    if type(categories) ~= "table" then
        return {}
    end

    for key, value in pairs(categories) do
        if type(value) == "table" then
            if value.expanded == nil then
                value.expanded = true
            else
                value.expanded = value.expanded and true or false
            end
        else
            categories[key] = { expanded = value ~= false }
        end
    end

    return categories
end

local function applyDefaults(container)
    container = mergeDefaults(container, DEFAULTS)

    if container.expanded == nil then
        container.expanded = true
    else
        container.expanded = container.expanded and true or false
    end

    if type(container.position) ~= "table" then
        container.position = deepCopyTable(DEFAULTS.position) or { x = nil, y = nil }
    else
        if container.position.x ~= nil then
            local numericX = tonumber(container.position.x)
            container.position.x = numericX ~= nil and numericX or nil
        end
        if container.position.y ~= nil then
            local numericY = tonumber(container.position.y)
            container.position.y = numericY ~= nil and numericY or nil
        end
    end

    if type(container.window) ~= "table" then
        container.window = deepCopyTable(DEFAULTS.window) or { locked = false }
    end
    container.window.locked = container.window.locked == true

    container.categories = normalizeCategories(container.categories)

    local numericRefresh = tonumber(container.lastRefresh)
    if numericRefresh == nil then
        numericRefresh = 0
    else
        if numericRefresh < 0 then
            numericRefresh = 0
        end
    end
    container.lastRefresh = numericRefresh

    return container
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

    if type(Nvk3UT) == "table" and type(Nvk3UT.Debug) == "function" then
        Nvk3UT.Debug("[EndeavorState] %s", message)
    elseif type(d) == "function" then
        d(string.format("[Nvk3UT][EndeavorState] %s", message))
    end
end

local function normalizeCategoryKey(key)
    if type(key) ~= "string" then
        return nil
    end

    local trimmed = key:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then
        return nil
    end

    return trimmed
end

local function ensureState()
    local sv = EndeavorState._sv
    if type(sv) ~= "table" then
        return nil
    end
    return sv
end

function EndeavorState:Init(svRoot)
    if type(svRoot) ~= "table" then
        self._root = nil
        self._sv = nil
        return nil
    end

    self._root = svRoot

    local data = svRoot.EndeavorData
    if type(data) ~= "table" then
        data = {}
        svRoot.EndeavorData = data
    end

    data = applyDefaults(data)
    self._sv = data

    debugLog("init")

    return data
end

function EndeavorState:IsExpanded()
    local sv = ensureState()
    if not sv then
        return true
    end

    if sv.expanded == nil then
        sv.expanded = true
    end

    return sv.expanded ~= false
end

function EndeavorState:SetExpanded(expanded)
    if expanded == nil then
        return false
    end

    local sv = ensureState()
    if not sv then
        return false
    end

    local normalized = expanded and true or false
    sv.expanded = normalized

    debugLog("set expanded=%s", tostring(normalized))

    return true
end

function EndeavorState:GetPosition()
    local sv = ensureState()
    if not sv then
        return nil, nil
    end

    local position = sv.position
    if type(position) ~= "table" then
        return nil, nil
    end

    return position.x, position.y
end

local function normalizeCoordinate(value)
    if value == nil then
        return nil
    end

    local numeric = tonumber(value)
    if numeric == nil then
        return nil
    end

    return numeric
end

function EndeavorState:SetPosition(x, y)
    local sv = ensureState()
    if not sv then
        return false
    end

    local normalizedX = normalizeCoordinate(x)
    local normalizedY = normalizeCoordinate(y)

    sv.position = sv.position or { x = nil, y = nil }

    sv.position.x = normalizedX
    sv.position.y = normalizedY

    debugLog("set position=%s,%s", tostring(normalizedX), tostring(normalizedY))

    return true
end

local function ensureCategoryEntry(key, create)
    local sv = ensureState()
    if not sv then
        return nil, nil
    end

    local categories = sv.categories
    if type(categories) ~= "table" then
        if not create then
            return nil, nil
        end
        categories = {}
        sv.categories = categories
    end

    local entry = categories[key]
    if type(entry) ~= "table" then
        if create then
            entry = { expanded = true }
            categories[key] = entry
        else
            return nil, categories
        end
    end

    if entry.expanded == nil then
        entry.expanded = true
    else
        entry.expanded = entry.expanded and true or false
    end

    return entry, categories
end

function EndeavorState:IsCategoryExpanded(key)
    local normalizedKey = normalizeCategoryKey(key)
    if not normalizedKey then
        return true
    end

    local entry = ensureCategoryEntry(normalizedKey, false)
    if type(entry) ~= "table" then
        return true
    end

    return entry.expanded ~= false
end

function EndeavorState:SetCategoryExpanded(key, expanded)
    local normalizedKey = normalizeCategoryKey(key)
    if not normalizedKey or expanded == nil then
        return false
    end

    local entry = ensureCategoryEntry(normalizedKey, true)
    if type(entry) ~= "table" then
        return false
    end

    local normalized = expanded and true or false
    entry.expanded = normalized

    debugLog("set category[%s]=%s", normalizedKey, tostring(normalized))

    return true
end

function EndeavorState:GetLastRefresh()
    local sv = ensureState()
    if not sv then
        return 0
    end

    local numeric = tonumber(sv.lastRefresh)
    if not numeric or numeric < 0 then
        return 0
    end

    return numeric
end

function EndeavorState:SetLastRefresh(epochSeconds)
    local numeric = tonumber(epochSeconds)
    if numeric == nil then
        return false
    end

    if numeric < 0 then
        numeric = 0
    end

    local sv = ensureState()
    if not sv then
        return false
    end

    sv.lastRefresh = numeric

    debugLog("set lastRefresh=%s", tostring(numeric))

    return true
end

function EndeavorState:ResetToDefaults(keepPosition)
    local svRoot = self._root
    if type(svRoot) ~= "table" then
        return false
    end

    local existingPosition
    if keepPosition and type(self._sv) == "table" then
        local position = self._sv.position
        if type(position) == "table" then
            existingPosition = { x = position.x, y = position.y }
        end
    end

    local defaultsCopy = deepCopyTable(DEFAULTS) or {
        expanded = true,
        position = { x = nil, y = nil },
        window = { locked = false },
        categories = {},
        lastRefresh = 0,
    }

    if type(existingPosition) == "table" then
        defaultsCopy.position = defaultsCopy.position or { x = nil, y = nil }
        defaultsCopy.position.x = existingPosition.x
        defaultsCopy.position.y = existingPosition.y
    end

    defaultsCopy = applyDefaults(defaultsCopy)
    svRoot.EndeavorData = defaultsCopy
    self._sv = defaultsCopy

    debugLog("set reset=%s", keepPosition and "keepPosition" or "defaults")

    return true
end

return EndeavorState
