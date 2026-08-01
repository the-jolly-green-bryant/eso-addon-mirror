-- Tracker/Golden/Nvk3UT_GoldenTrackerController.lua
-- Normalizes Golden tracker data into an Endeavor-style category/entry view model.

local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Controller = Nvk3UT.GoldenTrackerController or {}
Nvk3UT.GoldenTrackerController = Controller

local MODULE_TAG = addonName .. ".GoldenTrackerController"

local DEFAULT_STATUS = {
    isAvailable = false,
    isLocked = false,
    hasEntries = false,
}

local state = {
    dirty = true,
    viewModel = nil,
    categoryExpanded = true,
    entryExpanded = true,
}

local function scheduleToggleFollowup(reason)
    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or _G.Nvk3UT_Rebuild
    if rebuild and type(rebuild.ScheduleToggleFollowup) == "function" then
        rebuild.ScheduleToggleFollowup(reason)
    end
end

local attachments = {
    model = nil,
    tracker = nil,
    debugLogger = nil,
}

local function getAddonRoot()
    local root = rawget(_G, addonName)
    if type(root) == "table" then
        return root
    end
    return Nvk3UT
end

local function getGoldenState()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil
    end

    local goldenState = rawget(root, "GoldenState")
    if type(goldenState) == "table" then
        return goldenState
    end

    return nil
end

local function getGoldenModel()
    if type(attachments.model) == "table" then
        return attachments.model
    end

    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil
    end

    local goldenModel = rawget(root, "GoldenModel")
    if type(goldenModel) == "table" then
        return goldenModel
    end

    return nil
end

local function getSavedVars()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil
    end

    return rawget(root, "sv")
end

local function getGoldenConfig()
    local saved = getSavedVars()
    if type(saved) ~= "table" then
        return nil
    end

    local config = saved.Golden
    if type(config) ~= "table" then
        return nil
    end

    return config
end

local function getGoldenDefaults()
    local saved = getSavedVars()
    if type(saved) == "table" then
        local trackerDefaults = saved.TrackerDefaults
        if type(trackerDefaults) == "table" then
            local goldenDefaults = trackerDefaults.GoldenDefaults
            if type(goldenDefaults) == "table" then
                return goldenDefaults
            end
        end
    end

    local stateInit = rawget(_G, "Nvk3UT_StateInit")
    local defaultSV = stateInit and stateInit.defaultSV
    if type(defaultSV) == "table" then
        local trackerDefaults = defaultSV.TrackerDefaults
        if type(trackerDefaults) == "table" then
            local goldenDefaults = trackerDefaults.GoldenDefaults
            if type(goldenDefaults) == "table" then
                return goldenDefaults
            end
        end
    end

    return nil
end

local function shouldHideBaseGameTracking()
    local config = getGoldenConfig()
    if type(config) == "table" and config.hideBaseGameTracking ~= nil then
        return config.hideBaseGameTracking ~= false
    end

    local defaults = getGoldenDefaults()
    if type(defaults) == "table" and defaults.hideBaseGameTracking ~= nil then
        return defaults.hideBaseGameTracking ~= false
    end

    return true
end

local function applyBaseGameTrackerHidden(isHidden)
    local tracker = _G.PROMOTIONAL_EVENT_TRACKER or _G.ZO_PromotionalEventTracker
    if not tracker then
        return
    end

    local control = tracker.control or tracker
    if not control then
        return
    end

    if type(tracker.SetHiddenForReason) == "function" then
        tracker:SetHiddenForReason("Nvk3UT_GoldenBaseSuppressed", isHidden == true)
    elseif type(control.SetHidden) == "function" then
        control:SetHidden(isHidden == true)
    end
end

local function isDebugEnabled()
    local root = getAddonRoot()

    local utils = root and root.Utils or Nvk3UT_Utils
    if type(utils) == "table" and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = root and root.Diagnostics or Nvk3UT_Diagnostics
    if type(diagnostics) == "table" and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

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

local function safeDebug(message, ...)
    if not isDebugEnabled() then
        return
    end

    local debugFn = attachments.debugLogger
    if type(debugFn) ~= "function" then
        local root = getAddonRoot()
        debugFn = root and root.Debug
    end
    if type(debugFn) ~= "function" then
        return
    end

    local payload = tostring(message)
    if select("#", ...) > 0 then
        local formatString = type(message) == "string" and message or payload
        local ok, formatted = pcall(string.format, formatString, ...)
        if ok and formatted ~= nil then
            payload = formatted
        end
    end

    pcall(debugFn, string.format("%s: %s", MODULE_TAG, tostring(payload)))
end

local function callStateMethod(goldenState, methodName, ...)
    if type(goldenState) ~= "table" or type(methodName) ~= "string" then
        return nil
    end

    local method = goldenState[methodName]
    if type(method) ~= "function" then
        return nil
    end

    local ok, result = pcall(method, goldenState, ...)
    if ok then
        return result
    end

    safeDebug("Call to GoldenState:%s failed: %s", methodName, tostring(result))
    return nil
end

local function callModelMethod(model, methodName, ...)
    if type(model) ~= "table" or type(methodName) ~= "string" then
        return nil
    end

    local method = model[methodName]
    if type(method) ~= "function" then
        safeDebug("GoldenModel:%s missing; skipping call", tostring(methodName))
        return nil
    end

    local ok, result = pcall(method, model, ...)
    if ok then
        return result
    end

    safeDebug("Call to GoldenModel:%s failed: %s", methodName, tostring(result))
    return nil
end

local function ensureString(value)
    if value == nil then
        return ""
    end
    return tostring(value)
end

local function coerceNumber(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil then
        numeric = fallback or 0
    end

    if numeric ~= numeric then
        numeric = fallback or 0
    end

    return numeric
end

local function selectFirstNumber(...)
    local argumentCount = select("#", ...)
    for index = 1, argumentCount do
        local candidate = select(index, ...)
        local numeric = tonumber(candidate)
        if numeric ~= nil and numeric == numeric then
            return numeric
        end
    end

    return nil
end

local function isObjectiveCompleted(objectiveData)
    if type(objectiveData) ~= "table" then
        return false
    end

    if objectiveData.isCompleted == true or objectiveData.isComplete == true or objectiveData.completed == true then
        return true
    end

    local progress = selectFirstNumber(objectiveData.progress, objectiveData.current, objectiveData.progressDisplay)
    local maxValue = selectFirstNumber(objectiveData.max, objectiveData.maxDisplay)
    if progress ~= nil and maxValue ~= nil and maxValue > 0 and progress >= maxValue then
        return true
    end

    return false
end

local function normalizeObjectiveHandling(value)
    if value == "recolor" then
        return "recolor"
    end
    if value == "hide" then
        return "hide"
    end
    return nil
end

local function normalizeGeneralHandling(value)
    if value == "recolor" then
        return "recolor"
    end
    if value == "hide" then
        return "hide"
    end
    if value == "showOpen" then
        return "showOpen"
    end
    return nil
end

local function resolveGeneralHandling(config)
    local handling
    if type(config) == "table" then
        handling = normalizeGeneralHandling(config.generalCompletedHandling)
        if handling == nil then
            handling = normalizeGeneralHandling(config.CompletedHandlingGeneral)
        end
        if handling == nil then
            handling = normalizeGeneralHandling(config.CompletedHandling)
        end
    end

    if handling == nil then
        handling = "hide"
    end

    return handling
end

local function resolveObjectiveHandling(config)
    local handling
    if type(config) == "table" then
        handling = normalizeObjectiveHandling(config.CompletedHandlingObjectives)
        if handling == nil then
            handling = normalizeObjectiveHandling(config.generalCompletedHandling)
        end
        if handling == nil then
            handling = normalizeObjectiveHandling(config.CompletedHandlingGeneral)
        end
    end

    if handling == nil then
        handling = "hide"
    end

    return handling
end

local function clampNonNegative(value, fallback)
    local numeric = coerceNumber(value, fallback or 0)
    if numeric < 0 then
        numeric = 0
    end

    return numeric
end

local function clampProgress(value, maxValue)
    local numeric = clampNonNegative(value, 0)
    if type(maxValue) == "number" and maxValue >= 0 and numeric > maxValue then
        numeric = maxValue
    end

    return numeric
end

local function clampMax(value)
    local numeric = coerceNumber(value, 1)
    if numeric < 1 then
        numeric = 1
    end

    return numeric
end

local function normalizeProgressPair(progressValue, maxValue)
    local maxNumeric = clampMax(maxValue)
    local currentNumeric = clampProgress(progressValue, maxNumeric)

    return currentNumeric, maxNumeric
end

local function isCapstoneComplete(payload)
    if type(payload) ~= "table" then
        return false
    end

    if payload.isComplete == true or payload.isCompleted == true or payload.completed == true then
        return true
    end

    local completed = selectFirstNumber(
        payload.completedObjectives,
        payload.completedActivities,
        payload.countCompleted,
        payload.totalCompleted
    )
    local total = selectFirstNumber(
        payload.maxRewardTier,
        payload.capstoneCompletionThreshold,
        payload.capLimit,
        payload.totalEntries,
        payload.totalCount,
        payload.countTotal
    )

    if total and total > 0 and completed and completed >= total then
        return true
    end

    local remaining = selectFirstNumber(
        payload.remainingObjectivesToNextReward,
        payload.remainingObjectives,
        payload.totalRemaining,
        payload.remaining
    )
    if remaining ~= nil and remaining <= 0 then
        return true
    end

    return false
end

local function buildObjectiveFromEntry(entryVm)
    -- Golden-entry → Objective table for tracker rows
    if type(entryVm) ~= "table" then
        return nil
    end

    local title = tostring(entryVm.title or entryVm.displayName or entryVm.name or "")

    local progress = tonumber(entryVm.current or entryVm.progressCurrent or entryVm.progressDisplay) or 0
    local maxValue = tonumber(entryVm.max or entryVm.progressMax or entryVm.maxDisplay) or 0

    local objective = {
        title = title,
        displayName = title,
        name = title,
        text = entryVm.description or title,
        progress = progress,
        max = maxValue,
        progressDisplay = progress,
        maxDisplay = maxValue,
        counterText = entryVm.counterText or entryVm.progressText,
        progressText = entryVm.progressText or entryVm.counterText,
        completed = entryVm.isComplete == true or entryVm.isCompleted == true,
        remainingSeconds = entryVm.remainingSeconds or entryVm.timeRemainingSec,
        entryId = entryVm.entryId or entryVm.id,
        categoryKey = entryVm.categoryKey,
        campaignId = entryVm.campaignId,
    }

    return objective
end

local function copyStatus(status)
    local snapshot = {
        isAvailable = false,
        isLocked = false,
        hasEntries = false,
    }

    if type(status) == "table" then
        snapshot.isAvailable = status.isAvailable == true
        snapshot.isLocked = status.isLocked == true
        snapshot.hasEntries = status.hasEntries == true
    end

    return snapshot
end

local function resolveStateStatus(goldenState)
    local status = callStateMethod(goldenState, "GetSystemStatus")
    if type(status) == "table" then
        return copyStatus(status)
    end

    return copyStatus(DEFAULT_STATUS)
end

local function resolveExpansionFlags(goldenState)
    local categoryExpanded = true
    local entryExpanded = true

    if goldenState then
        local header = callStateMethod(goldenState, "IsHeaderExpanded")
        if header == nil then
            header = callStateMethod(goldenState, "IsCategoryHeaderExpanded")
        end

        if header ~= nil then
            categoryExpanded = header ~= false
        end

        local entry = callStateMethod(goldenState, "IsEntryExpanded")
        if entry ~= nil then
            entryExpanded = entry ~= false
        end
    elseif state.categoryExpanded ~= nil then
        categoryExpanded = state.categoryExpanded ~= false
        entryExpanded = state.entryExpanded ~= false
    end

    return {
        category = categoryExpanded,
        entry = entryExpanded,
    }
end

local function newEmptyViewModel(status, expansionFlags)
    local viewStatus = copyStatus(status)

    local categoryExpanded = true
    local entryExpanded = true
    if type(expansionFlags) == "table" then
        if expansionFlags.category ~= nil then
            categoryExpanded = expansionFlags.category ~= false
        end
        if expansionFlags.entry ~= nil then
            entryExpanded = expansionFlags.entry ~= false
        end
    end

    local viewModel = {
        status = viewStatus,
        header = { isExpanded = categoryExpanded },
        categoryExpanded = categoryExpanded,
        entryExpanded = entryExpanded,
        categories = {},
        summary = {
            totalEntries = 0,
            totalCompleted = 0,
            totalRemaining = 0,
            campaignCount = 0,
        },
    }

    return viewModel
end

local function ensureViewModel()
    if type(state.viewModel) == "table" then
        return state.viewModel
    end

    local goldenState = getGoldenState()
    local expansionFlags = resolveExpansionFlags(goldenState)
    local viewStatus = resolveStateStatus(goldenState)

    state.viewModel = newEmptyViewModel(viewStatus, expansionFlags)
    safeDebug("ensureViewModel fallback: created empty view model")
    return state.viewModel
end

local function normalizeEntry(rawCategory, rawEntry, index)
    if type(rawEntry) ~= "table" then
        return nil
    end

    local categoryKey = ""
    if type(rawCategory) == "table" then
        categoryKey = ensureString(rawCategory.key or rawCategory.id or "")
    end

    local entryId = rawEntry.id
    if entryId == nil or entryId == "" then
        entryId = string.format("%s:%d", categoryKey, index)
    end

    local title = rawEntry.name
    if title == nil then
        title = ""
    else
        title = tostring(title)
    end

    local description = rawEntry.description
    if description == nil then
        description = ""
    else
        description = tostring(description)
    end

    local currentValue, maxValue = normalizeProgressPair(rawEntry.progress, rawEntry.maxProgress)
    local currentInt = math.floor(currentValue + 0.5)
    local maxInt = math.max(1, math.floor(maxValue + 0.5))
    local isComplete = rawEntry.isCompleted == true or (maxValue > 0 and currentValue >= maxValue)

    local remainingSeconds = rawEntry.timeRemainingSec
    if remainingSeconds == nil and rawEntry.remainingSeconds ~= nil then
        remainingSeconds = rawEntry.remainingSeconds
    end
    remainingSeconds = clampNonNegative(remainingSeconds)

    local progressText = string.format("%d/%d", currentInt, maxInt)

    local entryVm = {
        entryId = tostring(entryId),
        id = tostring(entryId),
        categoryKey = categoryKey,
        categoryId = ensureString(rawCategory and (rawCategory.id or categoryKey) or categoryKey),
        type = rawEntry.type or categoryKey,
        entryType = rawEntry.type or categoryKey,
        title = title,
        displayName = title,
        name = title,
        description = description,
        tooltip = description,
        current = currentValue,
        progressCurrent = currentValue,
        count = currentInt,
        max = maxInt,
        progressMax = maxValue,
        maxProgress = maxValue,
        maxDisplay = maxInt,
        progressDisplay = currentInt,
        isComplete = isComplete,
        isCompleted = isComplete,
        isVisible = true,
        isHidden = false,
        progressPercent = maxValue > 0 and currentValue / maxValue or 0,
        progressText = progressText,
        counterText = progressText,
        remainingSeconds = remainingSeconds,
        timeRemainingSec = remainingSeconds,
        objectives = {},
        index = index,
        campaignId = rawEntry.campaignId or (rawCategory and rawCategory.campaignId),
        campaignKey = rawEntry.campaignKey or (rawCategory and rawCategory.campaignKey),
        campaignIndex = rawEntry.campaignIndex or (rawCategory and rawCategory.campaignIndex),
        rewardId = rawEntry.rewardId,
        rewardQuantity = rawEntry.rewardQuantity,
        isRewardClaimed = rawEntry.isRewardClaimed == true,
        veq = rawEntry.veq,
    }

    local objective = buildObjectiveFromEntry(entryVm)
    if objective then
        entryVm.objectives[1] = objective
    end
    entryVm.hasObjectives = #entryVm.objectives > 0

    return entryVm
end

local function buildCategory(rawCategory)
    if type(rawCategory) ~= "table" then
        return nil
    end

    local key = ensureString(rawCategory.key or rawCategory.id or "")
    local displayName = ensureString(rawCategory.displayName or rawCategory.name or key)
    local expanded = rawCategory.expanded ~= false

    local categoryVm = {
        id = ensureString(rawCategory.id or key),
        categoryKey = key,
        key = key,
        categoryId = ensureString(rawCategory.id or key),
        type = key,
        displayName = displayName,
        title = displayName,
        name = displayName,
        description = ensureString(rawCategory.description),
        isExpanded = expanded,
        isCollapsed = not expanded,
        expanded = expanded,
        isVisible = true,
        entryCount = 0,
        completedCount = 0,
        totalCount = 0,
        hasEntries = false,
        timeRemainingSec = clampNonNegative(rawCategory.timeRemainingSec),
        remainingSeconds = clampNonNegative(rawCategory.remainingSeconds or rawCategory.timeRemainingSec),
        capLimit = 0,
        progressText = "0/0",
        entries = {},
        campaignId = rawCategory.campaignId,
        campaignKey = rawCategory.campaignKey,
        campaignIndex = rawCategory.campaignIndex,
    }

    local entries = {}
    local rawEntries = type(rawCategory.entries) == "table" and rawCategory.entries or {}
    for index = 1, #rawEntries do
        local entryVm = normalizeEntry(rawCategory, rawEntries[index], index)
        if entryVm then
            entries[#entries + 1] = entryVm
        end
    end

    categoryVm.entries = entries
    categoryVm.entryCount = #entries

    local capTotal = tonumber(rawCategory.capstoneCompletionThreshold)
    local completedFromCap = tonumber(rawCategory.completedActivities)

    if capTotal == nil or capTotal <= 0 or completedFromCap == nil then
        safeDebug("Category gated (capstone missing): name=%s", displayName)
        return nil
    end

    local total = math.max(capTotal, 0)
    local completed = math.max(completedFromCap, 0)

    if total <= 0 then
        safeDebug("Category gated (non-positive capstone): name=%s", displayName)
        return nil
    end

    completed = math.min(completed, total)

    safeDebug(
        "Category uses capstone: name=%s completed=%d total=%d",
        displayName,
        completed,
        total
    )

    categoryVm.completedCount = clampNonNegative(completed)
    categoryVm.totalCount = clampNonNegative(total)
    categoryVm.capLimit = categoryVm.totalCount
    categoryVm.countCompleted = categoryVm.completedCount
    categoryVm.countTotal = categoryVm.totalCount
    categoryVm.hasEntries = categoryVm.entryCount > 0

    local progressMax = math.max(1, categoryVm.totalCount)
    categoryVm.progressText = string.format("%d/%d", math.floor(categoryVm.completedCount + 0.5), progressMax)

    if categoryVm.remainingSeconds <= 0 then
        local minRemaining
        for index = 1, #entries do
            local remaining = clampNonNegative(entries[index].timeRemainingSec)
            if remaining > 0 then
                if minRemaining == nil then
                    minRemaining = remaining
                else
                    minRemaining = math.min(minRemaining, remaining)
                end
            end
        end
        if minRemaining ~= nil then
            categoryVm.timeRemainingSec = minRemaining
            categoryVm.remainingSeconds = minRemaining
        end
    end

    return categoryVm
end

function Controller:New(model, tracker, debugLogger)
    if type(model) == "table" then
        attachments.model = model
    end

    if type(tracker) == "table" then
        attachments.tracker = tracker
    end

    if debugLogger ~= nil then
        attachments.debugLogger = debugLogger
    end

    return self
end

function Controller:Init()
    state.dirty = true
    state.viewModel = nil
    safeDebug("Init")
end

function Controller:MarkDirty(reason)
    state.dirty = true
    if reason ~= nil then
        safeDebug("MarkDirty(%s)", tostring(reason))
    end

    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if type(runtime) == "table" and type(runtime.QueueDirty) == "function" then
        runtime:QueueDirty("golden")
    end
end

function Controller.ApplyBaseGameTrackerVisibility(isHidden)
    return applyBaseGameTrackerHidden(isHidden)
end

function Controller.ApplyBaseGameTrackerVisibilityFromSettings()
    return applyBaseGameTrackerHidden(shouldHideBaseGameTracking())
end

function Controller.ShouldHideBaseGameTracking()
    return shouldHideBaseGameTracking()
end

function Controller:IsDirty()
    return state.dirty == true
end

function Controller:ClearDirty()
    state.dirty = false
end

function Controller:BuildViewModel(options)
    local goldenState = getGoldenState()
    local expansionFlags = resolveExpansionFlags(goldenState)
    local stateStatus = resolveStateStatus(goldenState)
    local viewModel = newEmptyViewModel(stateStatus, expansionFlags)

    local isEnabled = true
    if goldenState ~= nil then
        local enabled = callStateMethod(goldenState, "IsEnabled")
        if enabled ~= nil then
            isEnabled = enabled ~= false
        end
    end

    if not isEnabled then
        local gatedStatus = copyStatus(stateStatus)
        gatedStatus.isAvailable = false
        gatedStatus.isLocked = false
        gatedStatus.hasEntries = false
        viewModel = newEmptyViewModel(gatedStatus, expansionFlags)
        state.viewModel = viewModel
        state.dirty = false
        safeDebug("BuildViewModel gated (disabled)")
        return viewModel
    end

    local isAvailable = stateStatus.isAvailable == true
    local isLocked = stateStatus.isLocked == true
    local hasEntries = stateStatus.hasEntries == true

    if not isAvailable then
        state.viewModel = viewModel
        state.dirty = false
        safeDebug(
            "BuildViewModel gated (state unavailable): locked=%s hasEntries=%s",
            tostring(isLocked),
            tostring(hasEntries)
        )
        return viewModel
    end

    if isLocked then
        state.viewModel = viewModel
        state.dirty = false
        safeDebug("BuildViewModel gated (state locked)")
        return viewModel
    end

    local model = getGoldenModel()
    if model == nil then
        state.viewModel = viewModel
        state.dirty = false
        safeDebug("BuildViewModel fallback: GoldenModel missing")
        return viewModel
    end

    local modelStatus = callModelMethod(model, "GetSystemStatus")
    if type(modelStatus) == "table" then
        viewModel.status = copyStatus(modelStatus)
        isAvailable = viewModel.status.isAvailable == true
        isLocked = viewModel.status.isLocked == true
        hasEntries = viewModel.status.hasEntries == true
    else
        viewModel.status = copyStatus(stateStatus)
        viewModel.status.hasEntries = true
    end

    if not isAvailable then
        state.viewModel = viewModel
        state.dirty = false
        safeDebug(
            "BuildViewModel gated (model unavailable): locked=%s hasEntries=%s",
            tostring(isLocked),
            tostring(hasEntries)
        )
        return viewModel
    end

    if isLocked then
        state.viewModel = viewModel
        state.dirty = false
        safeDebug("BuildViewModel gated (model locked)")
        return viewModel
    end

    local rawData = callModelMethod(model, "GetViewData") or {}
    local counters = callModelMethod(model, "GetCounters") or {}

    local rawSummary = type(rawData.summary) == "table" and rawData.summary or {}
    local rawObjectives = type(rawData.objectives) == "table" and rawData.objectives or {}

    safeDebug(
        "BuildViewModel raw data: nil=%s hasEntriesForTracker=%s hasCampaign=%s objectives=%d",
        tostring(rawData == nil),
        tostring(rawData and rawData.hasEntriesForTracker),
        tostring(rawSummary.hasActiveCampaign),
        #rawObjectives
    )

    local trackedCampaignKey, trackedActivityIndex
    if type(GetTrackedPromotionalEventActivityInfo) == "function" then
        trackedCampaignKey, trackedActivityIndex = GetTrackedPromotionalEventActivityInfo()
        if trackedCampaignKey == nil or trackedCampaignKey == 0 then
            trackedCampaignKey, trackedActivityIndex = nil, nil
        end
    end

    if rawData == nil or rawData.hasEntriesForTracker ~= true then
        viewModel.status.hasEntries = false
        viewModel.status.hasEntriesForTracker = false
        viewModel.hasEntriesForTracker = false
        state.viewModel = viewModel
        state.dirty = false
        safeDebug("BuildViewModel gated: capstone not ready")
        return viewModel
    end

    local categoryExpanded = expansionFlags.category ~= false
    if type(rawData) == "table" and rawData.headerExpanded ~= nil then
        categoryExpanded = rawData.headerExpanded ~= false
    end
    viewModel.header = { isExpanded = categoryExpanded }
    viewModel.categoryExpanded = categoryExpanded

    local rawCategories = type(rawData.categories) == "table" and rawData.categories or {}
    local categories = {}

    for index = 1, #rawCategories do
        local categoryVm = buildCategory(rawCategories[index])
        if categoryVm then
            categories[#categories + 1] = categoryVm
        end
    end

    if #categories == 0 then
        viewModel.categories = categories
        viewModel.hasEntriesForTracker = false
        viewModel.status.hasEntries = false
        viewModel.status.hasEntriesForTracker = false
        state.viewModel = viewModel
        state.dirty = false
        safeDebug("BuildViewModel gated: no capstone categories")
        return viewModel
    end

    viewModel.categories = categories

    local summary = {
        hasActiveCampaign = rawSummary.hasActiveCampaign == true,
        campaignName = ensureString(rawSummary.campaignName),
        campaignId = ensureString(rawSummary.campaignId),
        campaignKey = ensureString(rawSummary.campaignKey),
        completedObjectives = clampNonNegative(rawSummary.completedObjectives),
        maxRewardTier = clampNonNegative(rawSummary.maxRewardTier),
        remainingObjectivesToNextReward = clampNonNegative(rawSummary.remainingObjectivesToNextReward),
        totalEntries = clampNonNegative(counters.totalActivities),
        totalCompleted = clampNonNegative(counters.completedActivities),
        campaignCount = clampNonNegative(rawSummary.campaignCount or counters.campaignCount or #categories),
    }
    local campaignKey = summary.campaignId or summary.campaignName or summary.campaignKey or summary.title or "campaign"
    if type(rawSummary.campaignKey) == "string" and rawSummary.campaignKey ~= "" then
        campaignKey = rawSummary.campaignKey
    end
    local entryExpanded = expansionFlags.entry ~= false

    summary.isExpanded = entryExpanded
    viewModel.entryExpanded = entryExpanded
    summary.totalRemaining = math.max(0, summary.totalEntries - summary.totalCompleted)

    viewModel.summary = summary

    local totalObjectives = #rawObjectives
    local totalCompletedOverall = 0
    local pinnedObjectiveId
    local pinnedObjectiveName
    for index = 1, #rawObjectives do
        local objectiveData = rawObjectives[index]

        if trackedCampaignKey ~= nil and trackedActivityIndex ~= nil and objectiveData ~= nil then
            local sameCampaign = objectiveData.campaignKey == trackedCampaignKey
            local sameActivity = tonumber(objectiveData.activityIndex) == tonumber(trackedActivityIndex)

            if sameCampaign and sameActivity then
                objectiveData.isPinned = true
                pinnedObjectiveId = pinnedObjectiveId or objectiveData.id or objectiveData.name
                pinnedObjectiveName = pinnedObjectiveName or objectiveData.name or objectiveData.displayName
            else
                if objectiveData.isPinned ~= nil then
                    objectiveData.isPinned = false
                end
            end
        else
            if objectiveData and objectiveData.isPinned ~= nil then
                objectiveData.isPinned = false
            end
        end

        if isObjectiveCompleted(objectiveData) then
            totalCompletedOverall = totalCompletedOverall + 1
        end
    end

    if pinnedObjectiveId ~= nil then
        safeDebug(
            "Pinned objective resolved: id=%s name=%s",
            tostring(pinnedObjectiveId),
            tostring(pinnedObjectiveName)
        )
    end

    local capstoneGoal = summary.maxRewardTier
    local remainingAllObjectives = math.max(0, totalObjectives - totalCompletedOverall)

    summary.totalObjectives = totalObjectives
    summary.totalCompletedOverall = totalCompletedOverall
    summary.capstoneGoal = capstoneGoal
    summary.remainingAllObjectives = remainingAllObjectives

    local goldenConfig = getGoldenConfig()
    local generalHandling = resolveGeneralHandling(goldenConfig)
    local objectiveHandling = resolveObjectiveHandling(goldenConfig)
    local capstoneReached = isCapstoneComplete(summary)
    local showOpenObjectiveRecolorMode = generalHandling == "showOpen" and objectiveHandling == "recolor"
    local hideCategoryWhenCompleted = capstoneReached and generalHandling == "hide"
    local hideObjectivesWhenCompleted = capstoneReached and (generalHandling == "recolor" or (generalHandling == "showOpen" and not showOpenObjectiveRecolorMode))
    local showOpenMode = capstoneReached and generalHandling == "showOpen" and not showOpenObjectiveRecolorMode

    summary.capstoneReached = capstoneReached
    summary.generalCompletedMode = generalHandling
    summary.hideCategoryWhenCompleted = hideCategoryWhenCompleted
    summary.hideObjectivesWhenCompleted = hideObjectivesWhenCompleted

    local trackerObjectives = rawObjectives
    local hideObjectivesForRecolorMode = generalHandling == "recolor" and objectiveHandling == "hide"
    if capstoneReached and generalHandling == "recolor" then
        trackerObjectives = {}
    elseif capstoneReached and generalHandling == "showOpen" and not showOpenObjectiveRecolorMode then
        trackerObjectives = {}
        for index = 1, #rawObjectives do
            local objectiveData = rawObjectives[index]
            if not isObjectiveCompleted(objectiveData) then
                trackerObjectives[#trackerObjectives + 1] = objectiveData
            end
        end
    elseif hideObjectivesForRecolorMode then
        trackerObjectives = {}
    elseif objectiveHandling ~= "recolor" and #rawObjectives > 0 then
        trackerObjectives = {}
        for index = 1, #rawObjectives do
            local objectiveData = rawObjectives[index]
            if not isObjectiveCompleted(objectiveData) then
                trackerObjectives[#trackerObjectives + 1] = objectiveData
            end
        end
    end

    local pinnedObjectives = {}
    local normalObjectives = {}

    for index = 1, #trackerObjectives do
        local objectiveData = trackerObjectives[index]
        if objectiveData and objectiveData.isPinned == true then
            pinnedObjectives[#pinnedObjectives + 1] = objectiveData
        else
            normalObjectives[#normalObjectives + 1] = objectiveData
        end
    end

    local orderedObjectives = {}
    for index = 1, #pinnedObjectives do
        orderedObjectives[#orderedObjectives + 1] = pinnedObjectives[index]
    end
    for index = 1, #normalObjectives do
        orderedObjectives[#orderedObjectives + 1] = normalObjectives[index]
    end

    if isDebugEnabled() then
        local firstPinnedIndex = #pinnedObjectives > 0 and 1 or "n/a"
        safeDebug(
            "[GoldenController] pinned ordering: pinned=%d normal=%d firstPinnedIndex=%s",
            #pinnedObjectives,
            #normalObjectives,
            tostring(firstPinnedIndex)
        )
    end

    viewModel.objectives = orderedObjectives

    viewModel.generalCompletedMode = generalHandling
    viewModel.capstoneReached = capstoneReached
    viewModel.hideCategoryWhenCompleted = hideCategoryWhenCompleted
    viewModel.hideObjectivesWhenCompleted = hideObjectivesWhenCompleted
    viewModel.showOpenMode = showOpenMode
    viewModel.showOpenObjectiveRecolorMode = showOpenObjectiveRecolorMode
    viewModel.totalObjectives = totalObjectives
    viewModel.totalCompletedOverall = totalCompletedOverall
    viewModel.capstoneGoal = capstoneGoal
    viewModel.remainingAllObjectives = remainingAllObjectives

    viewModel.hasEntriesForTracker = rawData.hasEntriesForTracker == true and #categories > 0

    if hideCategoryWhenCompleted and viewModel.hasEntriesForTracker then
        viewModel.hasEntriesForTracker = false
    end

    if viewModel.hasEntriesForTracker then
        viewModel.status.isAvailable = true
        viewModel.status.hasEntries = true
        viewModel.status.hasEntriesForTracker = true
    else
        viewModel.status.hasEntries = false
        viewModel.status.hasEntriesForTracker = false
    end

    state.viewModel = viewModel
    state.dirty = false

    local trackerObjectiveCount = #viewModel.objectives

    safeDebug(
        "BuildViewModel populated: avail=%s locked=%s hasEntries=%s hasEntriesForTracker=%s campaigns=%d activities=%d/%d objectives=%d",
        tostring(viewModel.status.isAvailable),
        tostring(viewModel.status.isLocked),
        tostring(viewModel.status.hasEntries),
        tostring(viewModel.hasEntriesForTracker),
        summary.campaignCount,
        summary.totalCompleted,
        summary.totalEntries,
        trackerObjectiveCount
    )

    safeDebug(
        "[GoldenController] completedHandling=%s generalCompletedMode=%s capstoneReached=%s hideCategory=%s hideObjectives=%s objectivesInModel=%d objectivesInTracker=%d",
        tostring(objectiveHandling),
        tostring(generalHandling),
        tostring(capstoneReached),
        tostring(hideCategoryWhenCompleted),
        tostring(hideObjectivesWhenCompleted),
        #rawObjectives,
        trackerObjectiveCount
    )

    return viewModel
end

function Controller:GetViewModel()
    return ensureViewModel()
end

local function toggleEntryExpanded()
    local goldenState = getGoldenState()
    if goldenState and type(goldenState.IsEntryExpanded) == "function" then
        local current = callStateMethod(goldenState, "IsEntryExpanded")
        local nextState = current == false
        if type(goldenState.SetEntryExpanded) == "function" then
            pcall(goldenState.SetEntryExpanded, goldenState, nextState)
        end
        state.entryExpanded = nextState
        return nextState
    end

    state.entryExpanded = not (state.entryExpanded == false)
    return state.entryExpanded
end

function Controller:ToggleHeaderExpanded()
    local goldenState = getGoldenState()
    local wasExpanded = true
    if goldenState and type(goldenState.IsHeaderExpanded) == "function" then
        wasExpanded = callStateMethod(goldenState, "IsHeaderExpanded") ~= false
    elseif state.categoryExpanded ~= nil then
        wasExpanded = state.categoryExpanded ~= false
    end

    local nowExpanded = not wasExpanded
    local changed = false

    if goldenState and type(goldenState.SetHeaderExpanded) == "function" then
        changed = callStateMethod(goldenState, "SetHeaderExpanded", nowExpanded) ~= false
    elseif goldenState and type(goldenState.SetCategoryHeaderExpanded) == "function" then
        changed = callStateMethod(goldenState, "SetCategoryHeaderExpanded", nowExpanded) ~= false
    else
        changed = state.categoryExpanded ~= nowExpanded
        state.categoryExpanded = nowExpanded
    end

    if changed then
        self:MarkDirty("ToggleHeaderExpanded")
        scheduleToggleFollowup("goldenCategoryToggle")
    end
end

function Controller:ToggleCategoryExpanded()
    self:ToggleHeaderExpanded()
end

function Controller:ToggleEntryExpanded()
    toggleEntryExpanded()
    self:MarkDirty("ToggleEntryExpanded")
    scheduleToggleFollowup("goldenEntryToggle")
end

return Controller
