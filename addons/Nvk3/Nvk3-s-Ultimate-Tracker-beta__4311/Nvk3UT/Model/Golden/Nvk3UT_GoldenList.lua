-- Model/Golden/Nvk3UT_GoldenList.lua
-- Golden tracker data extraction wrapper. Normalizes provider output without touching UI or runtime.

Nvk3UT = Nvk3UT or {}

local GoldenList = Nvk3UT.GoldenList or {}
Nvk3UT.GoldenList = GoldenList

GoldenList._svRoot = type(GoldenList._svRoot) == "table" and GoldenList._svRoot or nil
GoldenList._data = type(GoldenList._data) == "table" and GoldenList._data or nil

local function resolveRoot()
    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" then
        return root
    end
    return Nvk3UT
end

local function resolveDiagnostics()
    local root = resolveRoot()
    local diagnostics = root and root.Diagnostics
    if type(diagnostics) == "table" then
        return diagnostics
    end
    if type(Nvk3UT_Diagnostics) == "table" then
        return Nvk3UT_Diagnostics
    end
    return nil
end

local function resolveUtils()
    local root = resolveRoot()
    local utils = root and root.Utils
    if type(utils) == "table" then
        return utils
    end
    if type(Nvk3UT_Utils) == "table" then
        return Nvk3UT_Utils
    end
    return nil
end

local function resolveSafeCall()
    local root = resolveRoot()
    if type(root.SafeCall) == "function" then
        return root.SafeCall
    end
    return nil
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local safe = resolveSafeCall()
    if type(safe) == "function" then
        local ok, results = pcall(function(...)
            return { safe(fn, ...) }
        end, ...)
        if ok and type(results) == "table" then
            if unpack then
                return unpack(results)
            end
            return results[1]
        end
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

local function fallbackDeepCopyTable(source)
    if type(source) ~= "table" then
        return nil
    end

    local function clone(value, seen)
        if type(value) ~= "table" then
            return value
        end

        if seen[value] then
            return seen[value]
        end

        local result = {}
        seen[value] = result

        if value[1] ~= nil then
            for index = 1, #value do
                result[index] = clone(value[index], seen)
            end
        end

        for key, child in pairs(value) do
            if result[key] == nil then
                result[key] = clone(child, seen)
            end
        end

        return result
    end

    local ok, copy = pcall(function()
        return clone(source, {})
    end)
    if ok and type(copy) == "table" then
        return copy
    end

    return nil
end

local function isDebugEnabled()
    local utils = resolveUtils()
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = resolveDiagnostics()
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = resolveRoot()
    if type(root.IsDebugEnabled) == "function" then
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

local function formatMessage(fmt, ...)
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, tostring(fmt), ...)
        if ok then
            return formatted
        end
    end

    if fmt == nil then
        return "<nil>"
    end

    return tostring(fmt)
end

local function debugLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local message = formatMessage(fmt, ...)
    local diagnostics = resolveDiagnostics()
    if diagnostics and type(diagnostics.Debug) == "function" then
        diagnostics.Debug("[GoldenList] %s", message)
        return
    end

    if type(d) == "function" then
        d(string.format("[Nvk3UT][GoldenList] %s", message))
        return
    end

    if type(print) == "function" then
        print("[Nvk3UT][GoldenList]", message)
    end
end

local function clampNumber(value, minimum, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        return fallback or minimum or 0
    end

    if minimum and numeric < minimum then
        numeric = minimum
    end

    return numeric
end

local function ensureNonNegative(value)
    local numeric = tonumber(value)
    if numeric == nil or numeric < 0 then
        return 0
    end
    return numeric
end

local function ensureMaxProgress(value)
    local numeric = tonumber(value)
    if numeric == nil or numeric < 1 then
        return 1
    end
    return numeric
end

local function ensureString(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end

local function ensureBoolean(value)
    if value == nil then
        return false
    end
    return value == true
end

local function newEmptyStatus()
    return {
        isAvailable = false,
        isLocked = false,
        hasEntries = false,
    }
end

local function normalizeStatus(status)
    local normalized = newEmptyStatus()
    if type(status) == "table" then
        normalized.isAvailable = status.isAvailable == true
        normalized.isLocked = status.isLocked == true
        normalized.hasEntries = status.hasEntries == true
    end
    return normalized
end

local function newEmptyCounters()
    return {
        campaignCount = 0,
        totalActivities = 0,
        completedActivities = 0,
    }
end

local function newEmptyData()
    return {
        categories = {},
        status = newEmptyStatus(),
        counters = newEmptyCounters(),
    }
end

function GoldenList:_ensureData()
    if type(self._data) ~= "table" then
        self._data = newEmptyData()
    end

    return self._data
end

function GoldenList:Init(svRoot)
    if type(svRoot) == "table" then
        self._svRoot = svRoot
    else
        self._svRoot = nil
    end

    self._data = newEmptyData()

    debugLog("initialized GoldenList module")
end

local function normalizeCounters(counters)
    local normalized = newEmptyCounters()
    if type(counters) == "table" then
        normalized.campaignCount = ensureNonNegative(counters.campaignCount)
        normalized.totalActivities = ensureNonNegative(counters.totalActivities)
        normalized.completedActivities = ensureNonNegative(counters.completedActivities)
    end
    return normalized
end

local function normalizeRawSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return newEmptyData()
    end

    snapshot.categories = type(snapshot.categories) == "table" and snapshot.categories or {}
    snapshot.status = normalizeStatus(snapshot.status)
    snapshot.counters = normalizeCounters(snapshot.counters)

    return snapshot
end

local function normalizeEntry(rawEntry, categoryKey, fallbackRemaining, entryIndex)
    local normalized = {}
    if type(rawEntry) ~= "table" then
        normalized.id = ""
        normalized.name = ""
        normalized.description = ""
        normalized.progress = 0
        normalized.maxProgress = 1
        normalized.isCompleted = false
        normalized.type = categoryKey
        normalized.timeRemainingSec = ensureNonNegative(fallbackRemaining)
        normalized.remainingSeconds = normalized.timeRemainingSec
        normalized.campaignId = nil
        normalized.campaignKey = nil
        normalized.campaignIndex = nil
        normalized.rewardId = nil
        normalized.rewardQuantity = nil
        normalized.isRewardClaimed = false
        return normalized
    end

    local identifier = rawEntry.id
    if identifier == nil or identifier == "" then
        identifier = string.format("%s:%d", ensureString(categoryKey), tonumber(entryIndex) or 0)
    end

    local progress = ensureNonNegative(rawEntry.progress)
    local maxProgress = ensureMaxProgress(rawEntry.maxProgress)
    local remaining = rawEntry.timeRemainingSec
    if remaining == nil then
        remaining = rawEntry.remainingSeconds
    end
    remaining = ensureNonNegative(remaining or fallbackRemaining)

    normalized.id = ensureString(identifier)
    normalized.name = ensureString(rawEntry.name)
    normalized.description = ensureString(rawEntry.description)
    normalized.progress = progress
    normalized.maxProgress = maxProgress
    if normalized.progressDisplay == nil then
        normalized.progressDisplay = progress
    end
    if normalized.current == nil then
        normalized.current = progress
    end
    if normalized.maxDisplay == nil then
        normalized.maxDisplay = maxProgress
    end
    if normalized.max == nil then
        normalized.max = maxProgress
    end
    normalized.isCompleted = ensureBoolean(rawEntry.isCompleted) or (maxProgress > 0 and progress >= maxProgress)
    normalized.type = rawEntry.type or categoryKey
    normalized.timeRemainingSec = remaining
    normalized.remainingSeconds = remaining
    normalized.campaignId = rawEntry.campaignId
    normalized.campaignKey = rawEntry.campaignKey
    normalized.campaignIndex = rawEntry.campaignIndex
    normalized.activityIndex = rawEntry.activityIndex or entryIndex
    normalized.rewardId = rawEntry.rewardId
    normalized.rewardQuantity = rawEntry.rewardQuantity
    normalized.isRewardClaimed = rawEntry.isRewardClaimed == true
    normalized.veq = rawEntry.veq

    return normalized
end

local function toCategoryKey(raw)
    if raw == nil then
        return nil
    end

    local rawType = type(raw)
    if rawType == "number" then
        return tostring(raw)
    end

    if rawType == "string" then
        local trimmed = raw
        if type(zo_strtrim) == "function" then
            trimmed = zo_strtrim(trimmed)
        end

        if trimmed == nil or trimmed == "" then
            return nil
        end

        return trimmed
    end

    return nil
end

local function normalizeCategoryPayload(payload, index)
    if type(payload) ~= "table" then
        return nil
    end

    local key = toCategoryKey(payload.key or payload.id or payload.name or index)
    if key == nil or key == "" then
        key = string.format("campaign_%d", tonumber(index) or 1)
    end
    key = ensureString(key)

    local fallbackRemaining = ensureNonNegative(payload.timeRemainingSec or payload.remainingSeconds)

    local entries = {}
    local rawEntries = payload.entries
    if type(rawEntries) == "table" then
        if rawEntries[1] ~= nil then
            for entryIndex = 1, #rawEntries do
                entries[#entries + 1] = normalizeEntry(rawEntries[entryIndex], key, fallbackRemaining, entryIndex)
            end
        else
            local entryIndex = 0
            for _, value in pairs(rawEntries) do
                entryIndex = entryIndex + 1
                entries[#entries + 1] = normalizeEntry(value, key, fallbackRemaining, entryIndex)
            end
        end
    end

    local countCompleted = payload.countCompleted
    if countCompleted == nil then
        local completed = 0
        for i = 1, #entries do
            if entries[i].isCompleted then
                completed = completed + 1
            end
        end
        countCompleted = completed
    else
        countCompleted = clampNumber(countCompleted, 0, #entries)
    end

    local countTotal = payload.countTotal
    if countTotal == nil then
        countTotal = #entries
    else
        countTotal = clampNumber(countTotal, 0, #entries)
    end

    local name = ensureString(payload.name or payload.displayName or key)
    local displayName = ensureString(payload.displayName or name)
    local description = ensureString(payload.description)
    local capstoneCompletionThreshold = tonumber(payload.capstoneCompletionThreshold)
    local completedActivities = payload.completedActivities or payload.numCompleted or payload.numCompletedActivities
    if completedActivities ~= nil then
        completedActivities = tonumber(completedActivities)
    end

    return {
        key = key,
        id = ensureString(payload.id or key),
        name = name,
        displayName = displayName,
        description = description,
        entries = entries,
        countCompleted = countCompleted,
        countTotal = countTotal,
        timeRemainingSec = fallbackRemaining,
        remainingSeconds = fallbackRemaining,
        campaignId = payload.campaignId,
        campaignKey = payload.campaignKey,
        campaignIndex = payload.campaignIndex or index,
        capstoneCompletionThreshold = capstoneCompletionThreshold,
        completedActivities = completedActivities,
    }
end

local function applyProviderPayload(payload)
    local categories = {}

    if type(payload) ~= "table" then
        debugLog("refresh: provider returned no data; using empty list")
        return categories
    end

    local rawCategories = {}
    if type(payload.categories) == "table" then
        for index = 1, #payload.categories do
            rawCategories[#rawCategories + 1] = payload.categories[index]
        end
    elseif type(payload.campaigns) == "table" then
        for index = 1, #payload.campaigns do
            rawCategories[#rawCategories + 1] = payload.campaigns[index]
        end
    end

    for index = 1, #rawCategories do
        local category = normalizeCategoryPayload(rawCategories[index], index)
        if type(category) == "table" then
            categories[#categories + 1] = category
        end
    end

    return categories
end

function GoldenList:RefreshFromGame(providerFn)
    local data = self:_ensureData()

    local payload
    if type(providerFn) == "function" then
        payload = safeCall(providerFn)
        if payload == nil then
            local ok, fallback = pcall(providerFn)
            if ok then
                payload = fallback
            end
        end
    end

    local categories = applyProviderPayload(payload)
    data.categories = categories
    data.status = normalizeStatus(payload and payload.status)
    data.counters = normalizeCounters(payload and payload.counters)

    local totalEntries = 0
    local completedActivities = 0
    for index = 1, #categories do
        local category = categories[index]
        if type(category) == "table" and type(category.entries) == "table" then
            local entryCount = #category.entries
            totalEntries = totalEntries + entryCount

            for entryIndex = 1, entryCount do
                local entry = category.entries[entryIndex]
                if type(entry) == "table" and entry.isCompleted == true then
                    completedActivities = completedActivities + 1
                end
            end
        end
    end

    if data.counters.campaignCount < #categories then
        data.counters.campaignCount = #categories
    end
    if data.counters.totalActivities < totalEntries then
        data.counters.totalActivities = totalEntries
    end
    if data.counters.completedActivities < completedActivities then
        data.counters.completedActivities = completedActivities
    end

    debugLog(
        "refresh: categories=%d entries=%d",
        #categories,
        totalEntries
    )
end

local function cloneSnapshot(source)
    local copy = fallbackDeepCopyTable(source)
    if type(copy) ~= "table" then
        return newEmptyData()
    end

    return normalizeRawSnapshot(copy)
end

function GoldenList:GetRawData()
    local data = self:_ensureData()
    local source = normalizeRawSnapshot({
        categories = data.categories,
        status = data.status,
        counters = data.counters,
    })

    return cloneSnapshot(source)
end

function GoldenList:IsEmpty()
    local data = self:_ensureData()
    local categories = data.categories
    if type(categories) ~= "table" then
        return true
    end

    for index = 1, #categories do
        local category = categories[index]
        if type(category) == "table" and type(category.entries) == "table" then
            if #category.entries > 0 then
                return false
            end
        end
    end

    return true
end

return GoldenList
