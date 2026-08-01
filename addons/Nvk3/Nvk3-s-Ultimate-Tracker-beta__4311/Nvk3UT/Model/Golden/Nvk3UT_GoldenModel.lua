-- Model/Golden/Nvk3UT_GoldenModel.lua
-- Golden tracker facade that composes GoldenState and GoldenList.
-- Builds read-only raw/view data snapshots without touching UI or runtime pieces.

Nvk3UT = Nvk3UT or {}

local GoldenModel = Nvk3UT.GoldenModel or {}
Nvk3UT.GoldenModel = GoldenModel

GoldenModel._svRoot = type(GoldenModel._svRoot) == "table" and GoldenModel._svRoot or nil
GoldenModel._state = type(GoldenModel._state) == "table" and GoldenModel._state or nil
GoldenModel._list = type(GoldenModel._list) == "table" and GoldenModel._list or nil
GoldenModel._rawData = type(GoldenModel._rawData) == "table" and GoldenModel._rawData or nil
GoldenModel._viewData = type(GoldenModel._viewData) == "table" and GoldenModel._viewData or nil
GoldenModel._counters = type(GoldenModel._counters) == "table" and GoldenModel._counters or nil
GoldenModel._systemStatus = type(GoldenModel._systemStatus) == "table" and GoldenModel._systemStatus or nil
GoldenModel._stateInitialized = GoldenModel._stateInitialized == true
GoldenModel._listInitialized = GoldenModel._listInitialized == true

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
        diagnostics.Debug("[GoldenModel] %s", message)
        return
    end

    if type(d) == "function" then
        d(string.format("[Nvk3UT][GoldenModel] %s", message))
        return
    end

    if type(print) == "function" then
        print("[Nvk3UT][GoldenModel]", message)
    end
end

local function ensureBoolean(value, fallback)
    if value == nil then
        return fallback == true
    end
    return value == true
end

local function ensureNumber(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        return fallback or 0
    end
    if numeric < 0 and (fallback or 0) >= 0 then
        numeric = fallback or 0
    end
    return numeric
end

local function ensureString(value, fallback)
    if value == nil then
        if fallback ~= nil then
            return tostring(fallback)
        end
        return ""
    end
    return tostring(value)
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

local function newEmptyRawData()
    return { categories = {} }
end

local function newEmptyCounters()
    return {
        campaignCount = 0,
        completedActivities = 0,
        totalActivities = 0,
    }
end

local function newSystemStatus()
    return {
        isAvailable = false,
        isLocked = false,
        hasEntries = false,
    }
end

local function copySystemStatus(status)
    local snapshot = newSystemStatus()
    if type(status) == "table" then
        snapshot.isAvailable = status.isAvailable == true
        snapshot.isLocked = status.isLocked == true
        snapshot.hasEntries = status.hasEntries == true
    end
    return snapshot
end

local function resolveSystemStatus(self, create)
    local status = self._systemStatus
    if type(status) == "table" then
        return status
    end

    if not create then
        return nil
    end

    status = newSystemStatus()
    self._systemStatus = status
    return status
end

local function applyStateSystemStatus(state, status)
    if type(state) ~= "table" then
        return
    end

    local snapshot = copySystemStatus(status)

    local function invoke(methodName, value)
        local method = state[methodName]
        if type(method) ~= "function" then
            return
        end

        safeCall(function()
            method(state, value)
        end)
    end

    invoke("SetSystemAvailable", snapshot.isAvailable)
    invoke("SetSystemLocked", snapshot.isLocked)
    invoke("SetHasEntries", snapshot.hasEntries)
end

local function copyOrEmpty(value, fallbackFactory)
    if type(value) == "table" then
        local copy = deepCopyTable(value)
        if type(copy) == "table" then
            return copy
        end
    end

    if type(fallbackFactory) == "function" then
        return fallbackFactory()
    end

    return {}
end

local function findCategoryByKey(data, key)
    if type(data) ~= "table" or type(data.categories) ~= "table" then
        return nil
    end

    for index = 1, #data.categories do
        local category = data.categories[index]
        if type(category) == "table" and category.key == key then
            return category
        end
    end

    return nil
end

local function coerceEntries(category)
    if type(category) ~= "table" then
        return {}
    end
    local entries = category.entries
    if type(entries) ~= "table" then
        return {}
    end
    local copy = deepCopyTable(entries)
    if type(copy) == "table" then
        return copy
    end
    local fallback = {}
    for index = 1, #entries do
        fallback[index] = entries[index]
    end
    return fallback
end

local function coerceCount(value, entries)
    local numeric = tonumber(value)
    if numeric ~= nil and numeric >= 0 then
        return numeric
    end
    if type(entries) == "table" then
        return #entries
    end
    return 0
end

local function getStateBoolean(state, methodName, fallback)
    if type(state) ~= "table" or type(methodName) ~= "string" then
        return ensureBoolean(fallback, true)
    end
    local method = state[methodName]
    if type(method) ~= "function" then
        return ensureBoolean(fallback, true)
    end

    local ok, value = pcall(method, state)
    if ok then
        return ensureBoolean(value, fallback)
    end

    return ensureBoolean(fallback, true)
end

local function refreshStateInit(state, svRoot)
    if type(state) ~= "table" or type(state.Init) ~= "function" then
        return
    end
    safeCall(function()
        state:Init(svRoot)
    end)
end

local function refreshListInit(list, svRoot)
    if type(list) ~= "table" or type(list.Init) ~= "function" then
        return
    end
    safeCall(function()
        list:Init(svRoot)
    end)
end

local function resolveSavedVarsRoot()
    local root = resolveRoot()
    if type(root) ~= "table" then
        return nil
    end

    local sv = rawget(root, "sv") or rawget(root, "SV")
    if type(sv) == "table" then
        return sv
    end

    return nil
end

local function ensureSavedVars(self, svRoot)
    if type(self) ~= "table" then
        return nil
    end

    if type(svRoot) == "table" then
        self._svRoot = svRoot
        return svRoot
    end

    local resolved = resolveSavedVarsRoot()
    if type(resolved) == "table" then
        self._svRoot = resolved
        return resolved
    end

    self._svRoot = nil
    return nil
end

local function ensureGoldenState(self, svRoot)
    if type(self) ~= "table" then
        return nil
    end

    local state = self._state
    if type(state) ~= "table" then
        local root = resolveRoot()
        state = root and root.GoldenState
        if type(state) == "table" then
            self._state = state
        else
            self._state = nil
            return nil
        end
    end

    if self._stateInitialized ~= true then
        refreshStateInit(self._state, svRoot)
        self._stateInitialized = true
    end

    return self._state
end

local function ensureGoldenList(self, svRoot)
    if type(self) ~= "table" then
        return nil
    end

    local list = self._list
    if type(list) ~= "table" or type(list.RefreshFromGame) ~= "function" then
        local root = resolveRoot()
        list = root and root.GoldenList
        if type(list) == "table" and type(list.RefreshFromGame) == "function" then
            self._list = list
        else
            self._list = nil
            return nil
        end
    end

    if self._listInitialized ~= true then
        refreshListInit(self._list, svRoot)
        self._listInitialized = true
    end

    return self._list
end

local function buildCounters(data)
    local counters = newEmptyCounters()
    if type(data) ~= "table" then
        return counters
    end

    local categories = data.categories
    if type(categories) ~= "table" then
        return counters
    end

    local totalActivities = 0
    local completedActivities = 0

    for index = 1, #categories do
        local category = categories[index]
        if type(category) == "table" then
            local capTotal = tonumber(category.capstoneCompletionThreshold)
            local completedFromCap = tonumber(category.completedActivities)

            if capTotal == nil or capTotal <= 0 or completedFromCap == nil then
                debugLog(
                    "Counters gated: missing capstone for category=%s",
                    ensureString(category.name or category.displayName or category.key or tostring(index))
                )
            else
                local total = math.max(capTotal, 0)
                local completed = math.max(completedFromCap, 0)

                if total > 0 then
                    completed = math.min(completed, total)
                    totalActivities = totalActivities + total
                    completedActivities = completedActivities + completed
                    debugLog(
                        "Counters capstone: category=%s completed=%d total=%d",
                        ensureString(category.name or category.displayName or category.key or tostring(index)),
                        completed,
                        total
                    )
                else
                    debugLog(
                        "Counters gated: non-positive capstone for category=%s",
                        ensureString(category.name or category.displayName or category.key or tostring(index))
                    )
                end
            end
        end
    end

    counters.totalActivities = totalActivities
    counters.completedActivities = completedActivities
    counters.campaignCount = #categories
    return counters
end

local function computeIsEmpty(counters)
    if type(counters) ~= "table" then
        return true
    end

    local total = tonumber(counters.totalActivities) or 0

    return total <= 0
end

local goldenApi

do
    -- Local Golden API facade that centralizes promotional event queries for Golden pursuits.
    local function fetchGlobal(name)
        if type(_G) == "table" then
            local fn = rawget(_G, name)
            if type(fn) == "function" then
                return fn
            end
        end
        return nil
    end

    local RequestPromotionalEventCampaignData = fetchGlobal("RequestPromotionalEventCampaignData")
    local GetNumActivePromotionalEventCampaigns = fetchGlobal("GetNumActivePromotionalEventCampaigns")
    local GetActivePromotionalEventCampaignKey = fetchGlobal("GetActivePromotionalEventCampaignKey")
    local GetPromotionalEventCampaignInfo = fetchGlobal("GetPromotionalEventCampaignInfo")
    local GetPromotionalEventCampaignDisplayName = fetchGlobal("GetPromotionalEventCampaignDisplayName")
    local GetPromotionalEventCampaignDescription = fetchGlobal("GetPromotionalEventCampaignDescription")
    local GetSecondsRemainingInPromotionalEventCampaign = fetchGlobal("GetSecondsRemainingInPromotionalEventCampaign")
    local GetPromotionalEventCampaignProgress = fetchGlobal("GetPromotionalEventCampaignProgress")
    local GetNumPromotionalEventCampaignActivities = fetchGlobal("GetNumPromotionalEventCampaignActivities")
    local GetPromotionalEventCampaignActivityInfo = fetchGlobal("GetPromotionalEventCampaignActivityInfo")
    local GetPromotionalEventCampaignActivityProgress = fetchGlobal("GetPromotionalEventCampaignActivityProgress")
    local GetPromotionalEventCampaignActivityTimeRemainingSeconds = fetchGlobal("GetPromotionalEventCampaignActivityTimeRemainingSeconds")
    local IsPromotionalEventSystemLocked = fetchGlobal("IsPromotionalEventSystemLocked")

    goldenApi = {}

    function goldenApi:HasRequiredApis()
        local required = {
            { "GetNumActivePromotionalEventCampaigns", GetNumActivePromotionalEventCampaigns },
            { "GetActivePromotionalEventCampaignKey", GetActivePromotionalEventCampaignKey },
            { "GetPromotionalEventCampaignInfo", GetPromotionalEventCampaignInfo },
            { "GetPromotionalEventCampaignDisplayName", GetPromotionalEventCampaignDisplayName },
            { "GetPromotionalEventCampaignDescription", GetPromotionalEventCampaignDescription },
            { "GetSecondsRemainingInPromotionalEventCampaign", GetSecondsRemainingInPromotionalEventCampaign },
            { "GetPromotionalEventCampaignProgress", GetPromotionalEventCampaignProgress },
            { "GetNumPromotionalEventCampaignActivities", GetNumPromotionalEventCampaignActivities },
            { "GetPromotionalEventCampaignActivityInfo", GetPromotionalEventCampaignActivityInfo },
            { "GetPromotionalEventCampaignActivityProgress", GetPromotionalEventCampaignActivityProgress },
            { "IsPromotionalEventSystemLocked", IsPromotionalEventSystemLocked },
        }

        for index = 1, #required do
            local entry = required[index]
            if type(entry[2]) ~= "function" then
                return false, entry[1]
            end
        end

        return true, nil
    end

    function goldenApi:InvokeProvider(providerFn)
        if type(providerFn) ~= "function" then
            return nil
        end

        local payload = safeCall(providerFn)
        if payload ~= nil then
            return payload
        end

        local ok, fallback = pcall(providerFn)
        if ok then
            return fallback
        end

        return nil
    end

    function goldenApi:IsSystemLocked()
        if type(IsPromotionalEventSystemLocked) ~= "function" then
            return false
        end

        local locked = safeCall(IsPromotionalEventSystemLocked)
        return locked == true
    end

    function goldenApi:GetActiveCampaignCount()
        if type(GetNumActivePromotionalEventCampaigns) ~= "function" then
            return 0
        end

        local count = safeCall(GetNumActivePromotionalEventCampaigns)
        count = ensureNumber(count, 0)
        if count < 0 then
            count = 0
        end

        return count
    end

    function goldenApi:WarmupCampaignData()
        if type(RequestPromotionalEventCampaignData) ~= "function" then
            return
        end

        safeCall(RequestPromotionalEventCampaignData)
    end

    function goldenApi:CollectVeqAugment(campaignHandle, activityIndex)
        -- Placeholder for Phase B2 VEQ augmentation hook.
        -- Future tokens will enrich Golden pursuit activities with VEQ data here.
        return nil
    end

    function goldenApi:BuildActivityPayload(campaignKey, campaignIndex, activityIndex, campaignMeta)
        local payload = {
            campaignIndex = campaignIndex,
            campaignHandle = campaignKey,
            activityIndex = activityIndex,
            campaignId = campaignMeta and campaignMeta.id,
            campaignKey = campaignMeta and campaignMeta.key,
            campaignName = campaignMeta and campaignMeta.displayName,
        }

        local activityId, name, description, completionThreshold, rewardId, rewardQuantity = safeCall(
            GetPromotionalEventCampaignActivityInfo,
            campaignKey,
            activityIndex
        )

        payload.id = activityId or string.format("%s:%d", tostring(campaignKey), activityIndex)
        payload.name = ensureString(name)
        payload.description = ensureString(description)
        payload.rewardId = rewardId
        payload.rewardQuantity = rewardQuantity

        if completionThreshold ~= nil then
            payload.maxProgress = ensureNumber(completionThreshold, 1)
        end

        local progress, isRewardClaimed = safeCall(
            GetPromotionalEventCampaignActivityProgress,
            campaignKey,
            activityIndex
        )
        if progress ~= nil then
            payload.progress = ensureNumber(progress, payload.progress or 0)
        end
        if isRewardClaimed ~= nil then
            payload.isCompleted = isRewardClaimed == true
            payload.isRewardClaimed = isRewardClaimed == true
        end

        if payload.progress == nil then
            payload.progress = 0
        end

        if payload.maxProgress == nil then
            payload.maxProgress = 1
        end

        if payload.isCompleted == nil then
            payload.isCompleted = payload.progress >= payload.maxProgress and payload.maxProgress > 0
        end

        local remaining = safeCall(
            GetPromotionalEventCampaignActivityTimeRemainingSeconds,
            campaignKey,
            activityIndex
        )
        if remaining ~= nil then
            payload.timeRemainingSec = ensureNumber(remaining, 0)
        elseif campaignMeta and campaignMeta.timeRemainingSec ~= nil then
            payload.timeRemainingSec = ensureNumber(campaignMeta.timeRemainingSec, 0)
        end

        if payload.timeRemainingSec ~= nil then
            payload.remainingSeconds = payload.timeRemainingSec
        end

        local veqAugment = self:CollectVeqAugment(campaignKey, activityIndex)
        if veqAugment ~= nil then
            payload.veq = veqAugment
        end

        return payload
    end

    function goldenApi:CollectActivitiesForCampaign(campaignKey, campaignIndex, campaignMeta)
        local activities = {}

        local count = ensureNumber(safeCall(GetNumPromotionalEventCampaignActivities, campaignKey), 0)
        if count <= 0 then
            return activities
        end

        for activityIndex = 1, count do
            local entry = self:BuildActivityPayload(campaignKey, campaignIndex, activityIndex, campaignMeta)
            if type(entry) == "table" then
                activities[#activities + 1] = entry
            end
        end

        return activities
    end

    function goldenApi:CollectCampaignActivities()
        local campaigns = {}

        local count = self:GetActiveCampaignCount()
        if count <= 0 then
            return campaigns
        end

        for index = 1, count do
            local campaignKey = safeCall(GetActivePromotionalEventCampaignKey, index)
            if campaignKey ~= nil then
                local campaignId, numActivities, numMilestones, capstoneCompletionThreshold, capstoneRewardId, capstoneRewardQuantity, campaignFrequency = safeCall(
                    GetPromotionalEventCampaignInfo,
                    campaignKey
                )

                local campaignName
                if campaignId ~= nil then
                    campaignName = safeCall(GetPromotionalEventCampaignDisplayName, campaignId)
                end

                local campaignDescription
                if campaignId ~= nil then
                    campaignDescription = safeCall(GetPromotionalEventCampaignDescription, campaignId)
                end

                local secondsRemaining = ensureNumber(
                    safeCall(GetSecondsRemainingInPromotionalEventCampaign, campaignKey),
                    0
                )

                local completedActivities, isCapstoneRewardClaimed = safeCall(
                    GetPromotionalEventCampaignProgress,
                    campaignKey
                )

                local campaignMeta = {
                    id = campaignId or campaignKey or index,
                    handle = campaignKey,
                    key = campaignKey,
                    index = index,
                    displayName = campaignName,
                    description = campaignDescription,
                    timeRemainingSec = secondsRemaining,
                    resetFrequency = campaignFrequency,
                    numActivities = ensureNumber(numActivities, 0),
                    numMilestones = ensureNumber(numMilestones, 0),
                    capstoneCompletionThreshold = ensureNumber(capstoneCompletionThreshold, 0),
                    capstoneRewardId = capstoneRewardId,
                    capstoneRewardQuantity = capstoneRewardQuantity,
                    numCompletedActivities = ensureNumber(completedActivities, 0),
                    isCapstoneRewardClaimed = isCapstoneRewardClaimed == true,
                }

                debugLog(
                    "Campaign meta: id=%s name=%s objectives=%d completed=%d capstone=%d",
                    tostring(campaignMeta.id),
                    ensureString(campaignMeta.displayName),
                    campaignMeta.numActivities or 0,
                    campaignMeta.numCompletedActivities or 0,
                    campaignMeta.capstoneCompletionThreshold or 0
                )

                local activities = self:CollectActivitiesForCampaign(campaignKey, index, campaignMeta)
                if type(activities) == "table" and #activities > 0 then
                    campaigns[#campaigns + 1] = {
                        id = campaignMeta.id,
                        index = index,
                        handle = campaignKey,
                        key = campaignKey,
                        timeRemainingSec = campaignMeta.timeRemainingSec,
                        resetFrequency = campaignMeta.resetFrequency,
                        displayName = ensureString(campaignMeta.displayName),
                        description = ensureString(campaignMeta.description),
                        activities = activities,
                        numActivities = campaignMeta.numActivities,
                        activityCount = #activities,
                        numCompleted = campaignMeta.numCompletedActivities,
                        capstoneCompletionThreshold = campaignMeta.capstoneCompletionThreshold,
                        capstoneRewardId = campaignMeta.capstoneRewardId,
                        capstoneRewardQuantity = campaignMeta.capstoneRewardQuantity,
                        isCapstoneRewardClaimed = campaignMeta.isCapstoneRewardClaimed,
                    }
                end
            end
        end

        return campaigns
    end

    local function computeCategoryKey(campaign, index)
        if type(campaign) ~= "table" then
            return string.format("campaign_%d", index)
        end

        local key = campaign.id or campaign.handle or campaign.key
        if key == nil or key == "" then
            key = string.format("campaign_%d", index)
        end

        return ensureString(key)
    end

    local function buildCampaignCategory(campaign, index)
        if type(campaign) ~= "table" then
            return nil
        end

        local activities = type(campaign.activities) == "table" and campaign.activities or {}
        if #activities == 0 then
            return nil
        end

        local categoryKey = computeCategoryKey(campaign, index)
        local entries = {}
        local completed = 0
        local fallbackRemaining = ensureNumber(campaign.timeRemainingSec, 0)
        local minRemaining = fallbackRemaining > 0 and fallbackRemaining or nil

        for activityIndex = 1, #activities do
            local activity = activities[activityIndex]
            if type(activity) == "table" then
                local entryId = activity.id
                if entryId == nil or entryId == "" then
                    entryId = string.format("%s:%d", categoryKey, ensureNumber(activity.activityIndex, activityIndex))
                end

                local progress = ensureNumber(activity.progress, 0)
                local maxProgress = ensureNumber(activity.maxProgress, 1)
                local entryRemaining = ensureNumber(activity.timeRemainingSec, fallbackRemaining)
                if entryRemaining > 0 then
                    if minRemaining == nil then
                        minRemaining = entryRemaining
                    else
                        minRemaining = math.min(minRemaining, entryRemaining)
                    end
                end

                local entryCompleted = ensureBoolean(activity.isCompleted, false) or (maxProgress > 0 and progress >= maxProgress)
                if entryCompleted then
                    completed = completed + 1
                end

                local entry = {
                    id = ensureString(entryId),
                    name = ensureString(activity.name),
                    description = ensureString(activity.description),
                    progress = progress,
                    maxProgress = maxProgress,
                    isCompleted = entryCompleted,
                    timeRemainingSec = entryRemaining,
                    remainingSeconds = entryRemaining,
                    rewardId = activity.rewardId,
                    rewardQuantity = activity.rewardQuantity,
                    isRewardClaimed = activity.isRewardClaimed,
                    type = activity.type,
                    campaignId = campaign.id,
                    campaignKey = campaign.key,
                    campaignIndex = campaign.index or index,
                }

                entries[#entries + 1] = entry
            end
        end

        if #entries == 0 then
            return nil
        end

        if minRemaining == nil then
            minRemaining = fallbackRemaining
        end
        minRemaining = ensureNumber(minRemaining, 0)

        return {
            key = categoryKey,
            id = categoryKey,
            name = ensureString(campaign.displayName),
            displayName = ensureString(campaign.displayName),
            description = ensureString(campaign.description),
            entries = entries,
            countCompleted = completed,
            countTotal = #entries,
            timeRemainingSec = minRemaining,
            remainingSeconds = minRemaining,
            capstoneCompletionThreshold = tonumber(campaign.capstoneCompletionThreshold) or nil,
            completedActivities = tonumber(campaign.numCompleted or campaign.completedActivities or campaign.numCompletedActivities) or nil,
            campaignId = campaign.id,
            campaignKey = campaign.key,
            campaignIndex = campaign.index or index,
        }
    end

    function goldenApi:BuildCampaignCategories(campaigns)
        local categories = {}
        if type(campaigns) ~= "table" then
            return categories
        end

        for index = 1, #campaigns do
            local category = buildCampaignCategory(campaigns[index], index)
            if type(category) == "table" then
                categories[#categories + 1] = category
            end
        end

        return categories
    end

    function goldenApi:CollectCampaignState()
        local hasApis, missingApi = self:HasRequiredApis()
        if not hasApis then
            return {
                hasRequiredApis = false,
                missingApi = missingApi,
                isLocked = false,
                isAvailable = false,
                hasEntries = false,
                campaigns = {},
            }
        end

        local locked = self:IsSystemLocked()
        if locked then
            return {
                hasRequiredApis = true,
                missingApi = nil,
                isLocked = true,
                isAvailable = false,
                hasEntries = false,
                campaigns = {},
            }
        end

        self:WarmupCampaignData()

        local campaigns = self:CollectCampaignActivities()
        local hasEntries = type(campaigns) == "table" and #campaigns > 0

        return {
            hasRequiredApis = true,
            missingApi = nil,
            isLocked = false,
            isAvailable = true,
            hasEntries = hasEntries,
            campaigns = campaigns or {},
        }
    end

    function goldenApi:BuildPayloadFromCampaigns(campaigns)
        local categories = self:BuildCampaignCategories(campaigns)
        return { categories = categories }
    end

    function goldenApi:BuildPayload(providerFn)
        local payload = self:InvokeProvider(providerFn)
        if type(payload) == "table" and type(payload.categories) == "table" then
            return payload
        end

        local state = self:CollectCampaignState()
        return self:BuildPayloadFromCampaigns(state.campaigns)
    end

    function goldenApi:CreateProvider(providerFn)
        return function()
            return goldenApi:BuildPayload(providerFn)
        end
    end
end

local function getCategoryExpanded(state, key, fallback)
    if type(state) == "table" and type(state.IsCategoryExpanded) == "function" and key ~= nil then
        local ok, value = pcall(state.IsCategoryExpanded, state, key)
        if ok then
            return ensureBoolean(value, fallback)
        end
    end

    return ensureBoolean(fallback, true)
end

local function buildCategoryView(rawCategory, state)
    local source = type(rawCategory) == "table" and rawCategory or {}
    local entries = coerceEntries(source)
    local countCompleted = coerceCount(source.countCompleted, entries)
    local countTotal = coerceCount(source.countTotal, entries)
    local remaining = ensureNumber(source.timeRemainingSec, 0)
    local key = ensureString(source.key or source.id or "")
    local expanded = getCategoryExpanded(state, key, true)

    return {
        key = key,
        id = ensureString(source.id or key),
        name = ensureString(source.name or source.displayName or key),
        displayName = ensureString(source.displayName or source.name or key),
        description = ensureString(source.description),
        entries = entries,
        countCompleted = countCompleted,
        countTotal = countTotal,
        timeRemainingSec = remaining,
        remainingSeconds = remaining,
        capstoneCompletionThreshold = source.capstoneCompletionThreshold,
        completedActivities = source.completedActivities,
        expanded = expanded,
        hasEntries = #entries > 0,
        campaignId = source.campaignId,
        campaignKey = source.campaignKey,
        campaignIndex = source.campaignIndex,
    }
end

local function buildViewDataSnapshot(rawData, state)
    local data = type(rawData) == "table" and rawData or newEmptyRawData()
    local headerExpanded = getStateBoolean(state, "IsHeaderExpanded", true)

    local categories = {}
    local rawCategories = type(data.categories) == "table" and data.categories or {}
    for index = 1, #rawCategories do
        categories[index] = buildCategoryView(rawCategories[index], state)
    end

    local summary = {
        hasActiveCampaign = false,
        campaignName = "",
        completedObjectives = 0,
        maxRewardTier = 0,
        remainingObjectivesToNextReward = 0,
    }

    local objectives = {}
    for categoryIndex = 1, #categories do
        local category = categories[categoryIndex]
        if type(category) == "table" then
            local entries = type(category.entries) == "table" and category.entries or {}
            for entryIndex = 1, #entries do
                objectives[#objectives + 1] = entries[entryIndex]
            end
        end
    end

    local primaryCategory = categories[1]
    if type(primaryCategory) == "table" then
        local maxTier = ensureNumber(primaryCategory.capstoneCompletionThreshold, 0)
        local completed = ensureNumber(primaryCategory.completedActivities, 0)

        if maxTier < 0 then
            maxTier = 0
        end

        if completed < 0 then
            completed = 0
        end

        if maxTier > 0 then
            completed = math.min(completed, maxTier)
            summary.hasActiveCampaign = true
        else
            completed = 0
            summary.hasActiveCampaign = false
        end

        summary.campaignName = primaryCategory.displayName or primaryCategory.name or ""

        summary.completedObjectives = completed
        summary.maxRewardTier = maxTier

        local remainingToCapstone = math.max(0, maxTier - completed)
        local closestRewardRemaining = nil

        local entries = type(primaryCategory.entries) == "table" and primaryCategory.entries or {}
        for entryIndex = 1, #entries do
            local entry = entries[entryIndex]
            if type(entry) == "table" and entry.isCompleted ~= true then
                local rewardQuantity = ensureNumber(entry.rewardQuantity)
                if rewardQuantity and rewardQuantity > 0 then
                    local progress = ensureNumber(entry.progress, 0)
                    local maxProgress = ensureNumber(entry.maxProgress, 1)
                    local remaining = math.max(0, maxProgress - progress)
                    if remaining == 0 then
                        remaining = 1
                    end

                    if closestRewardRemaining == nil then
                        closestRewardRemaining = remaining
                    else
                        closestRewardRemaining = math.min(closestRewardRemaining, remaining)
                    end
                end
            end
        end

        if closestRewardRemaining == nil then
            closestRewardRemaining = remainingToCapstone
        end

        summary.remainingObjectivesToNextReward = closestRewardRemaining
    end

    local hasEntriesForTracker = (#categories > 0) or (#objectives > 0)

    local viewData = {
        headerExpanded = headerExpanded,
        categories = categories,
        objectives = objectives,
        summary = summary,
        hasEntriesForTracker = hasEntriesForTracker,
    }

    debugLog(
        "view snapshot: campaigns=%d objectives=%d active=%s name=%s completed=%d/%d remaining=%d",
        #categories,
        #objectives,
        tostring(summary.hasActiveCampaign),
        tostring(summary.campaignName),
        summary.completedObjectives,
        summary.maxRewardTier,
        summary.remainingObjectivesToNextReward
    )

    return viewData
end

function GoldenModel:Init(svRoot, goldenState, goldenList)
    self._stateInitialized = false
    self._listInitialized = false

    local resolvedSv = ensureSavedVars(self, svRoot)

    if type(goldenState) == "table" then
        self._state = goldenState
    else
        self._state = type(Nvk3UT.GoldenState) == "table" and Nvk3UT.GoldenState or nil
    end

    if type(goldenList) == "table" then
        self._list = goldenList
    else
        self._list = type(Nvk3UT.GoldenList) == "table" and Nvk3UT.GoldenList or nil
    end

    local state = ensureGoldenState(self, resolvedSv)
    local list = ensureGoldenList(self, resolvedSv)

    self._rawData = newEmptyRawData()
    self._viewData = buildViewDataSnapshot(self._rawData, state)
    self._counters = buildCounters(self._rawData)
    self._isEmpty = computeIsEmpty(self._counters)

    local status = resolveSystemStatus(self, true)
    status.isAvailable = false
    status.isLocked = false
    status.hasEntries = false
    applyStateSystemStatus(state, status)

    if list == nil then
        debugLog("init: GoldenList unavailable; model will lazy-resolve on refresh")
    else
        debugLog("init")
    end

    return self
end

local function runListRefresh(list, providerFn)
    if type(list) ~= "table" or type(list.RefreshFromGame) ~= "function" then
        return
    end
    list:RefreshFromGame(providerFn)
end

function GoldenModel:RefreshFromGame(providerFn)
    local status = resolveSystemStatus(self, true)
    status.hasEntries = false

    local svRoot = ensureSavedVars(self, self._svRoot)
    local state = ensureGoldenState(self, svRoot)
    local list = ensureGoldenList(self, svRoot)

    local function resetModelData()
        self._rawData = newEmptyRawData()
        self._viewData = buildViewDataSnapshot(self._rawData, state)
        self._counters = buildCounters(self._rawData)
        self._isEmpty = true
    end

    local campaignState = goldenApi:CollectCampaignState()
    status.isAvailable = campaignState.isAvailable == true
    status.isLocked = campaignState.isLocked == true
    status.hasEntries = campaignState.hasEntries == true

    local campaigns = {}
    if type(campaignState.campaigns) == "table" then
        campaigns = campaignState.campaigns
    end

    local dataProvider
    if type(providerFn) == "function" then
        dataProvider = goldenApi:CreateProvider(providerFn)
    else
        dataProvider = function()
            return goldenApi:BuildPayloadFromCampaigns(campaigns)
        end
    end

    debugLog(
        "refresh start: provider=%s list=%s",
        type(dataProvider) == "function" and "function" or tostring(dataProvider),
        type(list) == "table" and "ready" or "missing"
    )

    applyStateSystemStatus(state, status)

    if type(list) ~= "table" then
        status.isAvailable = false
        status.hasEntries = false
        resetModelData()
        applyStateSystemStatus(state, status)
        debugLog("refresh gated: GoldenList missing")
        return false
    end

    debugLog(
        "refresh status: hasApis=%s locked=%s available=%s campaigns=%d",
        tostring(campaignState.hasRequiredApis ~= false),
        tostring(status.isLocked),
        tostring(status.isAvailable),
        #campaigns
    )

    if campaignState.hasRequiredApis == false then
        resetModelData()
        safeCall(runListRefresh, list, nil)
        debugLog("refresh gated: missing promotional event API %s", tostring(campaignState.missingApi))
        applyStateSystemStatus(state, status)
        return false
    end

    if status.isLocked then
        resetModelData()
        safeCall(runListRefresh, list, nil)
        debugLog("refresh gated: promotional event system locked")
        applyStateSystemStatus(state, status)
        return false
    end

    safeCall(runListRefresh, list, dataProvider)

    local rawData = copyOrEmpty(list.GetRawData and list:GetRawData(), newEmptyRawData)
    if type(rawData.categories) ~= "table" then
        rawData = newEmptyRawData()
    end

    self._rawData = rawData
    self._viewData = buildViewDataSnapshot(self._rawData, state)
    self._counters = buildCounters(self._rawData)

    local campaignCount = self._counters.campaignCount or 0
    local totalActivities = self._counters.totalActivities or 0

    if campaignCount > 0 and totalActivities <= 0 then
        debugLog("refresh gated: capstone data not ready (campaigns=%d)", campaignCount)
        resetModelData()
        status.hasEntries = false
        applyStateSystemStatus(state, status)
        return false
    end

    local isEmpty = computeIsEmpty(self._counters)
    self._isEmpty = isEmpty
    status.hasEntries = not isEmpty

    local completedActivities = self._counters.completedActivities or 0

    if isEmpty then
        debugLog("refresh: available but no Golden entries (campaigns=%d)", campaignCount)
    else
        debugLog(
            "refresh: campaigns=%d activities=%d/%d",
            campaignCount,
            completedActivities,
            totalActivities
        )
    end

    applyStateSystemStatus(state, status)

    return true
end

function GoldenModel:GetRawData()
    local copy = deepCopyTable(self._rawData)
    if type(copy) == "table" then
        return copy
    end
    return newEmptyRawData()
end

function GoldenModel:GetViewData()
    local copy = deepCopyTable(self._viewData)
    if type(copy) == "table" then
        return copy
    end
    return buildViewDataSnapshot(self._rawData, self._state)
end

function GoldenModel:GetCounters()
    local counters = self._counters
    if type(counters) ~= "table" then
        counters = newEmptyCounters()
    end

    return {
        campaignCount = counters.campaignCount or 0,
        completedActivities = counters.completedActivities or 0,
        totalActivities = counters.totalActivities or 0,
    }
end

function GoldenModel:IsSystemAvailable()
    local status = resolveSystemStatus(self, false)
    if type(status) ~= "table" then
        return false
    end
    return status.isAvailable == true
end

function GoldenModel:IsSystemLocked()
    local status = resolveSystemStatus(self, false)
    if type(status) ~= "table" then
        return false
    end
    return status.isLocked == true
end

function GoldenModel:HasEntries()
    local status = resolveSystemStatus(self, false)
    if type(status) ~= "table" then
        return false
    end
    return status.hasEntries == true
end

function GoldenModel:GetSystemStatus()
    return copySystemStatus(resolveSystemStatus(self, false))
end

function GoldenModel:IsEmpty()
    if self._isEmpty ~= nil then
        return self._isEmpty == true
    end
    self._isEmpty = computeIsEmpty(self._counters)
    return self._isEmpty == true
end

return GoldenModel
