-- Timed Activities (Endeavor) data snapshot module. No UI or event wiring.

Nvk3UT = Nvk3UT or {}

local EndeavorModel = Nvk3UT.EndeavorModel or {}
Nvk3UT.EndeavorModel = EndeavorModel

EndeavorModel.state = type(EndeavorModel.state) == "table" and EndeavorModel.state or nil
EndeavorModel._snapshot = type(EndeavorModel._snapshot) == "table" and EndeavorModel._snapshot or nil
EndeavorModel._summary = type(EndeavorModel._summary) == "table" and EndeavorModel._summary or nil

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
        diagnostics.Debug("[EndeavorModel] %s", message)
        return
    end

    if type(d) == "function" then
        d(string.format("[Nvk3UT][EndeavorModel] %s", message))
        return
    end

    if type(print) == "function" then
        print("[Nvk3UT][EndeavorModel]", message)
    end
end

local function warnLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local message = formatMessage(fmt, ...)
    local diagnostics = resolveDiagnostics()
    if diagnostics and type(diagnostics.Warn) == "function" then
        diagnostics.Warn("[EndeavorModel] %s", message)
        return
    end

    debugLog("WARN: %s", message)
end

local function clampNumber(value, minValue, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        return fallback or minValue or 0
    end
    if minValue and numeric < minValue then
        numeric = minValue
    end
    return numeric
end

local function deepCopyTable(source)
    if type(source) ~= "table" then
        return {}
    end

    if type(ZO_DeepTableCopy) == "function" then
        local ok, copy = pcall(ZO_DeepTableCopy, source)
        if ok and type(copy) == "table" then
            return copy
        end
        local target = {}
        ok = pcall(ZO_DeepTableCopy, source, target)
        if ok then
            return target
        end
    end

    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = deepCopyTable(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function newBucket()
    return {
        total = 0,
        completed = 0,
        limit = 0,
        items = {},
    }
end

local function newSnapshot()
    return {
        timestamp = 0,
        seals = 0,
        systemActive = false,
        daily = newBucket(),
        weekly = newBucket(),
    }
end

local function newSummary()
    return {
        dailyCompleted = 0,
        dailyTotal = 0,
        dailyLimit = 0,
        weeklyCompleted = 0,
        weeklyTotal = 0,
        weeklyLimit = 0,
        seals = 0,
        isActive = false,
        timestamp = 0,
    }
end

local TIMED_ACTIVITY_TYPE_DAILY = _G.TIMED_ACTIVITY_TYPE_DAILY
local TIMED_ACTIVITY_TYPE_WEEKLY = _G.TIMED_ACTIVITY_TYPE_WEEKLY

local TYPE_TO_KEY = {}
if type(TIMED_ACTIVITY_TYPE_DAILY) ~= "nil" then
    TYPE_TO_KEY[TIMED_ACTIVITY_TYPE_DAILY] = "daily"
end
if type(TIMED_ACTIVITY_TYPE_WEEKLY) ~= "nil" then
    TYPE_TO_KEY[TIMED_ACTIVITY_TYPE_WEEKLY] = "weekly"
end

local CURT_ENDEAVOR_SEALS = _G.CURT_ENDEAVOR_SEALS
local CURRENCY_LOCATION_ACCOUNT = _G.CURRENCY_LOCATION_ACCOUNT

local function appendItem(bucket, item)
    if type(bucket) ~= "table" or type(bucket.items) ~= "table" then
        return
    end
    bucket.items[#bucket.items + 1] = item
end

local function sanitizeString(value)
    if type(value) ~= "string" then
        return ""
    end
    return value
end

local function sanitizeRemainingSeconds(value)
    local numeric = clampNumber(value, 0, 0)
    if numeric < 0 then
        return 0
    end
    return numeric
end

local function sanitizeProgress(value)
    local numeric = clampNumber(value, 0, 0)
    if numeric < 0 then
        return 0
    end
    return numeric
end

local function sanitizeMaxProgress(value)
    local numeric = clampNumber(value, 1, 1)
    if numeric < 1 then
        numeric = 1
    end
    return numeric
end

local function lowerKeyForSort(text)
    local Utils = resolveUtils()
    if Utils and type(Utils.StripLeadingIconTag) == "function" then
        text = Utils.StripLeadingIconTag(text)
    end

    if type(zo_strlower) == "function" then
        return zo_strlower(text)
    end

    if type(string.lower) == "function" then
        return string.lower(text)
    end

    return text
end

local function finalizeBucket(bucket)
    if type(bucket) ~= "table" then
        return
    end

    local items = bucket.items or {}
    local incomplete = {}
    local complete = {}

    for index = 1, #items do
        local entry = items[index]
        if type(entry) == "table" then
            entry._order = index
            if entry.completed then
                entry._sortName = lowerKeyForSort(entry.name or "")
                complete[#complete + 1] = entry
            else
                incomplete[#incomplete + 1] = entry
            end
        end
    end

    table.sort(incomplete, function(left, right)
        if left.remainingSeconds ~= right.remainingSeconds then
            return left.remainingSeconds < right.remainingSeconds
        end
        return (left._order or 0) < (right._order or 0)
    end)

    table.sort(complete, function(left, right)
        if left._sortName ~= right._sortName then
            return (left._sortName or "") < (right._sortName or "")
        end
        return (left._order or 0) < (right._order or 0)
    end)

    local ordered = {}
    for _, entry in ipairs(incomplete) do
        entry._order = nil
        entry._sortName = nil
        ordered[#ordered + 1] = entry
    end
    for _, entry in ipairs(complete) do
        entry._order = nil
        entry._sortName = nil
        ordered[#ordered + 1] = entry
    end

    bucket.items = ordered
    bucket.total = #ordered

    local completedCount = 0
    for i = 1, #ordered do
        if ordered[i].completed then
            completedCount = completedCount + 1
        end
    end
    bucket.completed = completedCount
end

local function coerceEpoch()
    local now = 0
    if type(os) == "table" and type(os.time) == "function" then
        local ok, value = pcall(os.time)
        if ok and type(value) == "number" then
            now = value
        end
    end

    if type(now) ~= "number" or now < 0 then
        local Utils = resolveUtils()
        if Utils and type(Utils.Now) == "function" then
            local fallback = Utils.Now()
            if type(fallback) == "number" and fallback >= 0 then
                now = fallback
            end
        end
    end

    if type(now) ~= "number" or now < 0 then
        now = 0
    end

    return now
end

function EndeavorModel:Init(state)
    if type(state) == "table" then
        self.state = state
    else
        self.state = nil
    end

    self._snapshot = newSnapshot()
    self._summary = newSummary()

    return self
end

local function buildItem(index, activityType)
    local nameValue = ""
    local nameFn = (type(_G) == "table" and rawget(_G, "GetTimedActivityName")) or GetTimedActivityName
    if type(nameFn) == "function" then
        local ok, value = pcall(nameFn, index)
        if ok and type(value) == "string" then
            nameValue = value
        end
    end
    local name = sanitizeString(nameValue or "")

    local descriptionValue = ""
    local descriptionFn = (type(_G) == "table" and rawget(_G, "GetTimedActivityDescription")) or GetTimedActivityDescription
    if type(descriptionFn) == "function" then
        local ok, value = pcall(descriptionFn, index)
        if ok and type(value) == "string" then
            descriptionValue = value
        end
    end
    local description = sanitizeString(descriptionValue or "")

    local progressValue = 0
    local progressFn = (type(_G) == "table" and rawget(_G, "GetTimedActivityProgress")) or GetTimedActivityProgress
    if type(progressFn) == "function" then
        local ok, value = pcall(progressFn, index)
        if ok and type(value) == "number" then
            progressValue = value
        end
    end
    local progress = sanitizeProgress(progressValue or 0)

    local maxProgressValue = 1
    local maxFn = (type(_G) == "table" and rawget(_G, "GetTimedActivityMaxProgress")) or GetTimedActivityMaxProgress
    if type(maxFn) == "function" then
        local ok, value = pcall(maxFn, index)
        if ok and type(value) == "number" then
            maxProgressValue = value
        end
    end
    local maxProgress = sanitizeMaxProgress(maxProgressValue or 1)

    local remainingValue = 0
    local remainingFn = (type(_G) == "table" and rawget(_G, "GetTimedActivityTimeRemainingSeconds")) or GetTimedActivityTimeRemainingSeconds
    if type(remainingFn) == "function" then
        local ok, value = pcall(remainingFn, index)
        if ok and type(value) == "number" then
            remainingValue = value
        end
    end
    local remainingSeconds = sanitizeRemainingSeconds(remainingValue or 0)

    local completed = progress >= maxProgress

    return {
        id = index,
        type = activityType,
        name = name,
        description = description,
        progress = progress,
        maxProgress = maxProgress,
        remainingSeconds = remainingSeconds,
        completed = completed,
    }
end

local function fetchLimit(activityTypeId)
    if type(activityTypeId) ~= "number" then
        return 0
    end

    local getter = (type(_G) == "table" and rawget(_G, "GetTimedActivityTypeLimit")) or GetTimedActivityTypeLimit
    if type(getter) ~= "function" then
        return 0
    end

    local ok, limit = pcall(getter, activityTypeId)
    if not ok then
        warnLog("GetTimedActivityTypeLimit failed for %s", tostring(activityTypeId))
        return 0
    end

    return clampNumber(limit, 0, 0)
end

local function fetchCompletedCount(activityTypeId)
    if type(activityTypeId) ~= "number" then
        return nil
    end

    local getter = (type(_G) == "table" and rawget(_G, "GetNumTimedActivitiesCompleted")) or GetNumTimedActivitiesCompleted
    if type(getter) ~= "function" then
        return nil
    end

    local ok, count = pcall(getter, activityTypeId)
    if not ok then
        warnLog("GetNumTimedActivitiesCompleted failed for %s", tostring(activityTypeId))
        return nil
    end
    return clampNumber(count, 0, 0)
end

local function fetchSeals()
    local getter = (type(_G) == "table" and rawget(_G, "GetCurrencyAmount")) or GetCurrencyAmount
    if type(getter) ~= "function" then
        return 0
    end
    if type(CURT_ENDEAVOR_SEALS) == "nil" or type(CURRENCY_LOCATION_ACCOUNT) == "nil" then
        return 0
    end

    local ok, amount = pcall(getter, CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
    if not ok then
        warnLog("GetCurrencyAmount failed for Endeavor seals")
        return 0
    end

    local numeric = clampNumber(amount, 0, 0)
    if numeric < 0 then
        numeric = 0
    end
    return numeric
end

local function fetchSystemActive()
    local getter = (type(_G) == "table" and rawget(_G, "IsTimedActivitySystemActive")) or IsTimedActivitySystemActive
    if type(getter) ~= "function" then
        return false
    end

    local ok, active = pcall(getter)
    if not ok then
        warnLog("IsTimedActivitySystemActive failed")
        return false
    end

    return active == true
end

local function collectActivities(snapshot)
    local countGetter = (type(_G) == "table" and rawget(_G, "GetNumTimedActivities")) or GetNumTimedActivities
    if type(countGetter) ~= "function" then
        warnLog("Timed activity API missing: GetNumTimedActivities")
        return
    end

    local ok, count = pcall(countGetter)
    if not ok or type(count) ~= "number" or count <= 0 then
        if not ok then
            warnLog("GetNumTimedActivities failed: %s", tostring(count))
        end
        return
    end

    local typeGetter = (type(_G) == "table" and rawget(_G, "GetTimedActivityType")) or GetTimedActivityType
    if type(typeGetter) ~= "function" then
        warnLog("Timed activity API missing: GetTimedActivityType")
        return
    end

    for index = 1, count do
        local okType, rawType = pcall(typeGetter, index)
        if not okType then
            warnLog("GetTimedActivityType failed for index %d", index)
        else
            local bucketKey = TYPE_TO_KEY[rawType]
            if not bucketKey then
                warnLog("Unknown timed activity type %s at index %d", tostring(rawType), index)
            else
                local item = buildItem(index, bucketKey)
                appendItem(snapshot[bucketKey], item)
            end
        end
    end
end

local function reconcileCounts(bucket, activityTypeId)
    if type(bucket) ~= "table" then
        return
    end

    finalizeBucket(bucket)

    local apiCount = fetchCompletedCount(activityTypeId)
    if apiCount ~= nil and apiCount ~= bucket.completed then
        warnLog("Completed count mismatch for %s: api=%d model=%d", tostring(activityTypeId), apiCount, bucket.completed)
    end
end

function EndeavorModel:RefreshFromGame()
    self._snapshot = newSnapshot()
    self._summary = newSummary()

    local snapshot = self._snapshot
    local summary = self._summary

    collectActivities(snapshot)

    snapshot.seals = fetchSeals()

    local dailyItems = snapshot.daily and snapshot.daily.items or {}
    local weeklyItems = snapshot.weekly and snapshot.weekly.items or {}
    debugLog("scan: daily=%d weekly=%d seals=%d", #dailyItems, #weeklyItems, snapshot.seals or 0)

    snapshot.daily.limit = fetchLimit(TIMED_ACTIVITY_TYPE_DAILY)
    snapshot.weekly.limit = fetchLimit(TIMED_ACTIVITY_TYPE_WEEKLY)

    reconcileCounts(snapshot.daily, TIMED_ACTIVITY_TYPE_DAILY)
    reconcileCounts(snapshot.weekly, TIMED_ACTIVITY_TYPE_WEEKLY)

    snapshot.systemActive = fetchSystemActive()

    local epoch = coerceEpoch()
    snapshot.timestamp = epoch

    summary.dailyCompleted = snapshot.daily.completed or 0
    summary.dailyTotal = snapshot.daily.total or 0
    summary.dailyLimit = snapshot.daily.limit or 0
    summary.weeklyCompleted = snapshot.weekly.completed or 0
    summary.weeklyTotal = snapshot.weekly.total or 0
    summary.weeklyLimit = snapshot.weekly.limit or 0
    summary.seals = snapshot.seals or 0
    summary.isActive = snapshot.systemActive == true
    summary.timestamp = snapshot.timestamp or 0

    if self.state and type(self.state.SetLastRefresh) == "function" then
        safeCall(function()
            self.state:SetLastRefresh(epoch)
        end)
    end

    debugLog("snapshot ready: daily=%d/%d weekly=%d/%d", summary.dailyCompleted, summary.dailyTotal, summary.weeklyCompleted, summary.weeklyTotal)
end

local function copySnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return newSnapshot()
    end
    return deepCopyTable(snapshot)
end

function EndeavorModel:GetViewData()
    if type(self._snapshot) ~= "table" then
        self._snapshot = newSnapshot()
    end

    return copySnapshot(self._snapshot)
end

function EndeavorModel:GetSummary()
    if type(self._summary) ~= "table" then
        self._summary = newSummary()
    end

    local summary = self._summary
    return {
        dailyCompleted = summary.dailyCompleted or 0,
        dailyTotal = summary.dailyTotal or 0,
        dailyLimit = summary.dailyLimit or 0,
        weeklyCompleted = summary.weeklyCompleted or 0,
        weeklyTotal = summary.weeklyTotal or 0,
        weeklyLimit = summary.weeklyLimit or 0,
        seals = summary.seals or 0,
        isActive = summary.isActive == true,
        timestamp = summary.timestamp or 0,
    }
end

local function isCapReached(completed, limit)
    local completedValue = tonumber(completed) or 0
    if completedValue < 0 then
        completedValue = 0
    end

    local limitValue = tonumber(limit) or 0
    if limitValue <= 0 then
        return false
    end

    if limitValue < 0 then
        limitValue = 0
    end

    return completedValue >= limitValue
end

function EndeavorModel:IsDailyCapped()
    local summary = self._summary
    if type(summary) ~= "table" then
        summary = self:GetSummary()
    end

    local completed = summary and summary.dailyCompleted
    local limit = summary and summary.dailyLimit

    if summary == self._summary then
        completed = summary.dailyCompleted or 0
        limit = summary.dailyLimit or 0
    end

    if isCapReached(completed, limit) then
        return true
    end

    local snapshot = self._snapshot
    if type(snapshot) == "table" then
        local daily = snapshot.daily
        if type(daily) == "table" then
            return isCapReached(daily.completed, daily.limit)
        end
    end

    return false
end

function EndeavorModel:IsWeeklyCapped()
    local summary = self._summary
    if type(summary) ~= "table" then
        summary = self:GetSummary()
    end

    local completed = summary and summary.weeklyCompleted
    local limit = summary and summary.weeklyLimit

    if summary == self._summary then
        completed = summary.weeklyCompleted or 0
        limit = summary.weeklyLimit or 0
    end

    if isCapReached(completed, limit) then
        return true
    end

    local snapshot = self._snapshot
    if type(snapshot) == "table" then
        local weekly = snapshot.weekly
        if type(weekly) == "table" then
            return isCapReached(weekly.completed, weekly.limit)
        end
    end

    return false
end

function EndeavorModel:GetCountsForDebug()
    if type(self._snapshot) ~= "table" then
        return {
            dailyTotal = 0,
            weeklyTotal = 0,
            seals = 0,
        }
    end

    local snapshot = self._snapshot
    local daily = snapshot.daily or {}
    local weekly = snapshot.weekly or {}

    local dailyTotal = tonumber(daily.total)
    if dailyTotal == nil then
        local items = daily.items
        if type(items) == "table" then
            dailyTotal = #items
        else
            dailyTotal = 0
        end
    end

    local weeklyTotal = tonumber(weekly.total)
    if weeklyTotal == nil then
        local items = weekly.items
        if type(items) == "table" then
            weeklyTotal = #items
        else
            weeklyTotal = 0
        end
    end

    local seals = tonumber(snapshot.seals) or 0

    return {
        dailyTotal = dailyTotal,
        weeklyTotal = weeklyTotal,
        seals = seals,
    }
end

return EndeavorModel
