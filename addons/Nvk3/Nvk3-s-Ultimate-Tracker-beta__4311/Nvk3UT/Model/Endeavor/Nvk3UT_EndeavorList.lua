-- Low-level Endeavor timed-activity scanner. No SV/UI/event side-effects.

Nvk3UT = Nvk3UT or {}

local EndeavorList = Nvk3UT.EndeavorList or {}
Nvk3UT.EndeavorList = EndeavorList

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
    if root and type(root.SafeCall) == "function" then
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
        return safe(fn, ...)
    end

    local results = { pcall(fn, ...) }
    if results[1] then
        table.remove(results, 1)
        if #results == 0 then
            return nil
        end
        return unpack(results)
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
        diagnostics.Debug("[EndeavorList] %s", message)
        return
    end

    if type(d) == "function" then
        d(string.format("[Nvk3UT][EndeavorList] %s", message))
        return
    end

    if type(print) == "function" then
        print("[Nvk3UT][EndeavorList]", message)
    end
end

local function warnLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local message = formatMessage(fmt, ...)
    local diagnostics = resolveDiagnostics()
    if diagnostics and type(diagnostics.Warn) == "function" then
        diagnostics.Warn("[EndeavorList] %s", message)
        return
    end

    debugLog("WARN: %s", message)
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

local function ensureString(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end

local function newResult()
    return {
        systemActive = false,
        seals = 0,
        limits = { daily = 0, weekly = 0 },
        totals = { daily = 0, weekly = 0 },
        completed = { daily = 0, weekly = 0 },
        daily = { items = {} },
        weekly = { items = {} },
        timestamp = 0,
    }
end

local GetNumTimedActivities = rawget(_G, "GetNumTimedActivities")
local GetTimedActivityType = rawget(_G, "GetTimedActivityType")
local GetTimedActivityName = rawget(_G, "GetTimedActivityName")
local GetTimedActivityDescription = rawget(_G, "GetTimedActivityDescription")
local GetTimedActivityProgress = rawget(_G, "GetTimedActivityProgress")
local GetTimedActivityMaxProgress = rawget(_G, "GetTimedActivityMaxProgress")
local GetTimedActivityTimeRemainingSeconds = rawget(_G, "GetTimedActivityTimeRemainingSeconds")
local GetNumTimedActivitiesCompleted = rawget(_G, "GetNumTimedActivitiesCompleted")
local GetTimedActivityTypeLimit = rawget(_G, "GetTimedActivityTypeLimit")
local GetCurrencyAmount = rawget(_G, "GetCurrencyAmount")
local IsTimedActivitySystemActive = rawget(_G, "IsTimedActivitySystemActive")
local osTime = os and os.time

local TIMED_ACTIVITY_TYPE_DAILY = rawget(_G, "TIMED_ACTIVITY_TYPE_DAILY")
local TIMED_ACTIVITY_TYPE_WEEKLY = rawget(_G, "TIMED_ACTIVITY_TYPE_WEEKLY")
local CURT_ENDEAVOR_SEALS = rawget(_G, "CURT_ENDEAVOR_SEALS")
local CURRENCY_LOCATION_ACCOUNT = rawget(_G, "CURRENCY_LOCATION_ACCOUNT")

local function resolveBucketKey(typeId)
    if typeId == TIMED_ACTIVITY_TYPE_DAILY then
        return "daily"
    end
    if typeId == TIMED_ACTIVITY_TYPE_WEEKLY then
        return "weekly"
    end
    return nil
end

local function readLimit(activityType)
    if type(GetTimedActivityTypeLimit) ~= "function" then
        return 0
    end

    local value = safeCall(GetTimedActivityTypeLimit, activityType)
    return clampNumber(value, 0, 0)
end

local function readCompletedFromApi(activityType)
    if type(GetNumTimedActivitiesCompleted) ~= "function" then
        return nil
    end
    return clampNumber(safeCall(GetNumTimedActivitiesCompleted, activityType), 0, 0)
end

local function readSystemActive()
    if type(IsTimedActivitySystemActive) ~= "function" then
        return false
    end

    local active = safeCall(IsTimedActivitySystemActive)
    return active == true
end

local function readSeals()
    if type(GetCurrencyAmount) ~= "function" then
        return 0
    end
    if CURT_ENDEAVOR_SEALS == nil or CURRENCY_LOCATION_ACCOUNT == nil then
        return 0
    end

    local seals = safeCall(GetCurrencyAmount, CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
    return clampNumber(seals, 0, 0)
end

function EndeavorList:ScanFromGame()
    local result = newResult()

    result.systemActive = readSystemActive()
    result.limits.daily = readLimit(TIMED_ACTIVITY_TYPE_DAILY)
    result.limits.weekly = readLimit(TIMED_ACTIVITY_TYPE_WEEKLY)
    result.seals = readSeals()

    local total = 0
    if type(GetNumTimedActivities) == "function" then
        total = clampNumber(safeCall(GetNumTimedActivities), 0, 0)
    end

    local completedCounts = { daily = 0, weekly = 0 }
    local totals = { daily = 0, weekly = 0 }

    if total > 0 then
        for index = 1, total do
            local typeId = type(GetTimedActivityType) == "function" and safeCall(GetTimedActivityType, index) or nil
            local bucketKey = resolveBucketKey(typeId)
            if bucketKey ~= nil then
                local name = ensureString(type(GetTimedActivityName) == "function" and safeCall(GetTimedActivityName, index) or "")
                local description = ensureString(type(GetTimedActivityDescription) == "function" and safeCall(GetTimedActivityDescription, index) or "")
                local progress = clampNumber(type(GetTimedActivityProgress) == "function" and safeCall(GetTimedActivityProgress, index) or 0, 0, 0)
                local maxProgress = clampNumber(type(GetTimedActivityMaxProgress) == "function" and safeCall(GetTimedActivityMaxProgress, index) or 1, 1, 1)
                local remaining = clampNumber(type(GetTimedActivityTimeRemainingSeconds) == "function" and safeCall(GetTimedActivityTimeRemainingSeconds, index) or 0, 0, 0)

                local item = {
                    id = index,
                    type = bucketKey,
                    name = name,
                    description = description,
                    progress = progress,
                    maxProgress = maxProgress,
                    remainingSeconds = remaining,
                }

                local items = result[bucketKey].items
                items[#items + 1] = item

                totals[bucketKey] = totals[bucketKey] + 1
                if progress >= maxProgress then
                    completedCounts[bucketKey] = completedCounts[bucketKey] + 1
                end
            elseif isDebugEnabled() then
                warnLog("skipped timed activity index=%d type=%s", index, tostring(typeId))
            end
        end
    end

    result.totals.daily = totals.daily
    result.totals.weekly = totals.weekly
    result.completed.daily = completedCounts.daily
    result.completed.weekly = completedCounts.weekly

    local dailyCompletedApi = readCompletedFromApi(TIMED_ACTIVITY_TYPE_DAILY)
    if dailyCompletedApi ~= nil and dailyCompletedApi ~= completedCounts.daily then
        warnLog("daily completed mismatch api=%d counted=%d", dailyCompletedApi, completedCounts.daily)
    end

    local weeklyCompletedApi = readCompletedFromApi(TIMED_ACTIVITY_TYPE_WEEKLY)
    if weeklyCompletedApi ~= nil and weeklyCompletedApi ~= completedCounts.weekly then
        warnLog("weekly completed mismatch api=%d counted=%d", weeklyCompletedApi, completedCounts.weekly)
    end

    if type(osTime) == "function" then
        local timestamp = safeCall(osTime)
        result.timestamp = clampNumber(timestamp, 0, 0)
    end

    debugLog("scan: daily=%d weekly=%d seals=%d active=%s", totals.daily, totals.weekly, result.seals, tostring(result.systemActive))

    return result
end

return EndeavorList
