local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Rows = Nvk3UT and Nvk3UT.GoldenTrackerRows
local Layout = Nvk3UT and Nvk3UT.GoldenTrackerLayout

local GoldenTracker = {}
GoldenTracker.__index = GoldenTracker
GoldenTracker.rows = {}
GoldenTracker.height = 0
GoldenTracker.viewModel = nil
GoldenTracker.initialized = false
GoldenTracker.container = nil
GoldenTracker.root = nil
GoldenTracker.content = nil
GoldenTracker.options = nil

local MODULE_TAG = addonName .. ".GoldenTracker"

local state = {
    container = nil,
    root = nil,
    content = nil,
    height = 0,
    initialized = false,
    options = nil,
}

local function getAddonRoot()
    local root = rawget(_G, addonName)
    if type(root) == "table" then
        return root
    end
    return Nvk3UT
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

    local root = getAddonRoot()
    local debugFn = root and root.Debug
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

local function normalizeSpacingValue(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil or numeric ~= numeric then
        return fallback
    end
    if numeric < 0 then
        return fallback
    end
    return numeric
end

local OBJECTIVE_INDENT_DEFAULT = 40
local OBJECTIVE_BASE_INDENT = 20
local ENTRY_INDENT_DEFAULT = 60
local ENTRY_SPACING_DEFAULT = 3

local function getCategoryIndentFromSaved()
    local root = getAddonRoot()
    local sv = root and (root.SV or root.sv)
    if sv == nil then
        sv = Nvk3UT and Nvk3UT.SV
    end
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local category = goldenSpacing and goldenSpacing.category
    local rawIndent = category and category.indent
    local normalized = normalizeSpacingValue(rawIndent, 0)
    safeDebug("[GoldenIndent] SV raw=%s normalized=%s", tostring(rawIndent), tostring(normalized))
    return normalized
end

local function getObjectiveIndentFromSaved()
    local root = getAddonRoot()
    local sv = root and (root.SV or root.sv)
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local objective = goldenSpacing and goldenSpacing.objective

    local indent = normalizeSpacingValue(objective and objective.indent, OBJECTIVE_INDENT_DEFAULT)
    return indent + OBJECTIVE_BASE_INDENT
end

local function getEntryIndentFromSaved()
    local root = getAddonRoot()
    local sv = root and (root.SV or root.sv)
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local entry = goldenSpacing and goldenSpacing.entry

    local rawIndent = entry and entry.indent
    local normalized = normalizeSpacingValue(rawIndent, ENTRY_INDENT_DEFAULT)
    safeDebug("[GoldenEntryIndent] SV raw=%s normalized=%s", tostring(rawIndent), tostring(normalized))
    return normalized
end

local function getEntrySpacingAboveFromSaved()
    local root = getAddonRoot()
    local sv = root and (root.SV or root.sv)
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local entry = goldenSpacing and goldenSpacing.entry

    return normalizeSpacingValue(entry and entry.spacingAbove, ENTRY_SPACING_DEFAULT)
end

local function getEntrySpacingBelowFromSaved()
    local root = getAddonRoot()
    local sv = root and (root.SV or root.sv)
    local spacing = sv and sv.spacing
    local goldenSpacing = spacing and spacing.golden
    local entry = goldenSpacing and goldenSpacing.entry

    return normalizeSpacingValue(entry and entry.spacingBelow, ENTRY_SPACING_DEFAULT)
end

local function isObjectiveCompleted(objectiveData)
    if type(objectiveData) ~= "table" then
        return false
    end

    if objectiveData.isCompleted == true or objectiveData.isComplete == true or objectiveData.completed == true then
        return true
    end

    local progress = tonumber(objectiveData.progress or objectiveData.current or objectiveData.progressDisplay)
    local maxValue = tonumber(objectiveData.max or objectiveData.maxDisplay)
    if progress ~= nil and maxValue ~= nil and maxValue > 0 and progress >= maxValue then
        return true
    end

    return false
end

local function logTrackerError(message, ...)
    local payload = tostring(message)
    if select("#", ...) > 0 then
        local formatString = type(message) == "string" and message or payload
        local ok, formatted = pcall(string.format, formatString, ...)
        if ok and formatted ~= nil then
            payload = formatted
        end
    end

    local root = getAddonRoot()
    local diagnostics = root and root.Diagnostics
    if type(diagnostics) == "table" then
        local errorFn = diagnostics.Error or diagnostics.Warn or diagnostics.Debug
        if type(errorFn) == "function" then
            pcall(errorFn, diagnostics, string.format("%s: %s", MODULE_TAG, payload))
            return
        end
    end

    if type(root) == "table" then
        if type(root.Warn) == "function" then
            pcall(root.Warn, string.format("%s: %s", MODULE_TAG, payload))
            return
        elseif type(root.Debug) == "function" then
            pcall(root.Debug, string.format("%s: %s", MODULE_TAG, payload))
            return
        end
    end

    if type(d) == "function" then
        pcall(d, string.format("[Nvk3UT][GoldenTracker] %s", payload))
        return
    end

    safeDebug(payload)
end

local function runSafe(fn)
    if type(fn) ~= "function" then
        return
    end

    local root = getAddonRoot()
    if type(root) == "table" then
        local safeCall = rawget(root, "SafeCall")
        if type(safeCall) == "function" then
            local ok = pcall(safeCall, fn)
            if ok then
                return
            end
        end
    end

    pcall(fn)
end

local function getRowsModule()
    if Rows and type(Rows) == "table" then
        return Rows
    end

    Rows = Nvk3UT and Nvk3UT.GoldenTrackerRows
    if type(Rows) == "table" then
        return Rows
    end

    return nil
end

local function getLayoutModule()
    if Layout and type(Layout) == "table" then
        return Layout
    end

    Layout = Nvk3UT and Nvk3UT.GoldenTrackerLayout
    if type(Layout) == "table" then
        return Layout
    end

    return nil
end

local function ClearChildren(control)
    if not control then
        return
    end

    local getNumChildren = control.GetNumChildren
    local getChild = control.GetChild
    if type(getNumChildren) ~= "function" or type(getChild) ~= "function" then
        return
    end

    local okCount, childCount = pcall(getNumChildren, control)
    if not okCount or type(childCount) ~= "number" or childCount <= 0 then
        return
    end

    for index = childCount - 1, 0, -1 do
        local okChild, child = pcall(getChild, control, index)
        if okChild and child then
            if child.SetHidden then
                child:SetHidden(true)
            end
            if child.ClearAnchors then
                child:ClearAnchors()
            end
            if child.SetParent then
                child:SetParent(nil)
            end
        end
    end
end

local function resolveGoldenContainer(candidate)
    local fallback = nil

    local uiRegistry = Nvk3UT and Nvk3UT.UI
    if uiRegistry and uiRegistry.GoldenContainer then
        fallback = uiRegistry.GoldenContainer
    end

    local hostRegistry = Nvk3UT and Nvk3UT.TrackerHost and Nvk3UT.TrackerHost.sectionContainers
    if hostRegistry and hostRegistry.golden then
        fallback = hostRegistry.golden
    end

    local candidateName
    if candidate and type(candidate.GetName) == "function" then
        local ok, name = pcall(candidate.GetName, candidate)
        if ok and type(name) == "string" then
            candidateName = name
        end
    end

    local isGoldenCandidate = candidateName and string.find(candidateName, "GoldenContainer", 1, true) ~= nil
    if not isGoldenCandidate and fallback and fallback ~= candidate then
        local fallbackName = fallback.GetName and fallback:GetName() or "<unknown>"
        safeDebug(
            "createRootAndContent: parent corrected from %s to %s",
            tostring(candidateName or "<nil>"),
            tostring(fallbackName)
        )
        return fallback
    end

    return candidate or fallback
end

local function getParentBaseName(parentControl)
    if parentControl and type(parentControl.GetName) == "function" then
        local ok, name = pcall(parentControl.GetName, parentControl)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end

    return "Nvk3UT_Golden"
end

local function cleanupOrphanedControls(parentControl)
    local parentName = getParentBaseName(parentControl)
    local targets = {
        parentName .. "Root",
        parentName .. "Content",
    }

    for _, controlName in ipairs(targets) do
        local control = _G[controlName]
        if control then
            local parent = control.GetParent and control:GetParent()
            if parent ~= parentControl then
                local parentLabel = parent and parent.GetName and parent:GetName() or "<nil>"
                safeDebug(
                    "Init: orphaned control %s cleaned up (parent=%s)",
                    tostring(controlName),
                    tostring(parentLabel)
                )
                if control.ClearAnchors then
                    control:ClearAnchors()
                end
                if control.SetHidden then
                    control:SetHidden(true)
                end
                if control.SetParent then
                    control:SetParent(nil)
                end
            end
        end
    end
end

local function createRootAndContent(parentControl)
    local wm = rawget(_G, "WINDOW_MANAGER")
    if wm == nil then
        safeDebug("Init aborted; WINDOW_MANAGER unavailable")
        return nil, nil
    end

    local resolvedParent = resolveGoldenContainer(parentControl)
    if resolvedParent == nil then
        safeDebug("Init aborted; Golden container missing")
        return nil, nil
    end

    local parentName = getParentBaseName(resolvedParent)

    local rootName = parentName .. "Root"
    local rootControl = wm:CreateControl(rootName, resolvedParent, CT_CONTROL)
    if rootControl then
        rootControl:SetParent(resolvedParent)
        if rootControl.SetResizeToFitDescendents then
            rootControl:SetResizeToFitDescendents(true)
        end
        if rootControl.SetHidden then
            rootControl:SetHidden(true)
        end
        if rootControl.SetMouseEnabled then
            rootControl:SetMouseEnabled(false)
        end
        if rootControl.ClearAnchors then
            rootControl:ClearAnchors()
        end
        if rootControl.SetAnchor then
            rootControl:SetAnchor(TOPLEFT, resolvedParent, TOPLEFT, 0, 0)
            rootControl:SetAnchor(TOPRIGHT, resolvedParent, TOPRIGHT, 0, 0)
        end
    end

    local contentControl
    if rootControl then
        local contentName = parentName .. "Content"
        contentControl = wm:CreateControl(contentName, rootControl, CT_CONTROL)
        if contentControl then
            contentControl:SetParent(rootControl)
            if contentControl.SetResizeToFitDescendents then
                contentControl:SetResizeToFitDescendents(true)
            end
            if contentControl.SetHidden then
                contentControl:SetHidden(true)
            end
            if contentControl.SetMouseEnabled then
                contentControl:SetMouseEnabled(false)
            end
            if contentControl.ClearAnchors then
                contentControl:ClearAnchors()
            end
            if contentControl.SetAnchor then
                contentControl:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, 0)
                contentControl:SetAnchor(TOPRIGHT, rootControl, TOPRIGHT, 0, 0)
            end
        end
    end

    return rootControl, contentControl
end

local function setContainerHeight(container, height)
    local numericHeight = tonumber(height) or 0
    if numericHeight < 0 then
        numericHeight = 0
    end

    if container and container.SetHeight then
        container:SetHeight(numericHeight)
    end
end

local function applyVisibility(control, hidden)
    if control and control.SetHidden then
        control:SetHidden(hidden)
    end
end

local function resolveInitArguments(...)
    local first = ...
    if first == GoldenTracker or (type(first) == "table" and first.__index == GoldenTracker) then
        return first, select(2, ...), select(3, ...)
    end

    return GoldenTracker, first, select(2, ...)
end

local function resolveRefreshArguments(...)
    local first = ...
    if first == GoldenTracker or (type(first) == "table" and first.__index == GoldenTracker) then
        return first, select(2, ...)
    end

    return GoldenTracker, first
end

local function resetRows(rows)
    if type(rows) ~= "table" then
        return
    end

    for index = #rows, 1, -1 do
        rows[index] = nil
    end
end

local function isControl(control)
    if control == nil then
        return false
    end

    if type(control) == "userdata" then
        return true
    end

    local getType = control and control.GetType
    if type(getType) == "function" then
        local ok, objectType = pcall(getType, control)
        if ok and type(objectType) == "number" then
            return true
        end
    end

    return false
end

function GoldenTracker.Init(...)
    local tracker, parentControl, options = resolveInitArguments(...)

    if parentControl == nil then
        logTrackerError("Init aborted; missing parent control")
        return
    end

    if not isControl(parentControl) then
        logTrackerError("Init aborted; invalid parent control (type=%s)", type(parentControl))
        return
    end

    local resolvedContainer = resolveGoldenContainer(parentControl)

    tracker.container = resolvedContainer or parentControl
    tracker.options = type(options) == "table" and options or nil
    tracker.height = 0
    tracker.viewModel = nil
    tracker.rows = tracker.rows or {}
    tracker.root = nil
    tracker.content = nil
    tracker.initialized = false

    state.container = resolvedContainer or parentControl
    state.options = tracker.options
    state.height = tracker.height
    state.initialized = false
    state.root = nil
    state.content = nil

    cleanupOrphanedControls(resolvedContainer or parentControl)

    local root, content = createRootAndContent(resolvedContainer or parentControl)
    tracker.root = root
    tracker.content = content
    state.root = root
    state.content = content

    if not root or not content then
        safeDebug("Init incomplete; root or content missing")
        return
    end

    ClearChildren(content)

    tracker.height = 0
    state.height = 0
    setContainerHeight(tracker.container, 0)
    applyVisibility(tracker.container, false)
    applyVisibility(root, true)
    applyVisibility(content, true)

    tracker.initialized = true
    state.initialized = true

    safeDebug("Init: container=%s parent=%s root=%s content=%s", 
        tracker.container and tracker.container.GetName and tracker.container:GetName() or "<nil>",
        tracker.container and tracker.container.GetParent and tracker.container:GetParent() and tracker.container:GetParent():GetName() or "<nil>",
        root and root.GetName and root:GetName() or "<nil>",
        content and content.GetName and content:GetName() or "<nil>"
    )

    local initReason = "init"
    safeDebug("[GoldenTracker.SHIM] init-kick (reason=%s)", initReason)
    GoldenTracker:RequestFullRefresh(initReason)
end

-- MARK: GEVENTS_SWITCH_KEEP_REFRESH_HELPER
-- GEVENTS note: This shim helper persists after GEVENTS_*_SWITCH; only the ESO registrations migrate to Events/.
local function goldenDataChanged(reason)
    local reasonForLog = reason
    if reasonForLog == nil or reasonForLog == "" then
        reasonForLog = "n/a"
    else
        reasonForLog = tostring(reasonForLog)
    end

    local results = {
        modelRefreshed = false,
        controllerMarked = false,
        runtimeQueued = false,
    }

    runSafe(function()
        local root = getAddonRoot()
        if type(root) ~= "table" then
            safeDebug("[GoldenTracker.SHIM] data change aborted (reason=%s; addon missing)", reasonForLog)
            return
        end

        local model = rawget(root, "GoldenModel")
        if type(model) == "table" then
            local refresh = model.RefreshFromGame or model.Refresh
            if type(refresh) == "function" then
                local ok, err = pcall(refresh, model)
                if ok then
                    results.modelRefreshed = true
                    safeDebug("[GoldenTracker.SHIM] model refreshed (reason=%s)", reasonForLog)
                else
                    safeDebug("[GoldenTracker.SHIM] model refresh failed (reason=%s, error=%s)", reasonForLog, tostring(err))
                end
            end
        end

        local controller = rawget(root, "GoldenTrackerController")
        if type(controller) == "table" then
            local markDirty = controller.MarkDirty or controller.RequestRefresh
            if type(markDirty) == "function" then
                local ok, err = pcall(markDirty, controller, reason)
                if ok then
                    results.controllerMarked = true
                else
                    safeDebug("[GoldenTracker.SHIM] mark dirty failed (reason=%s, error=%s)", reasonForLog, tostring(err))
                end
            end
        end

        local runtime = rawget(root, "TrackerRuntime")
        if type(runtime) == "table" then
            local queueDirty = runtime.QueueDirty or runtime.MarkDirty or runtime.RequestRefresh
            if type(queueDirty) == "function" then
                local ok, err = pcall(queueDirty, runtime, "golden")
                if ok then
                    results.runtimeQueued = true
                else
                    safeDebug("[GoldenTracker.SHIM] queue dirty failed (reason=%s, error=%s)", reasonForLog, tostring(err))
                end
            end
        end

        safeDebug(
            "[GoldenTracker.SHIM] data changed (reason=%s model=%s dirty=%s queued=%s)",
            reasonForLog,
            tostring(results.modelRefreshed),
            tostring(results.controllerMarked),
            tostring(results.runtimeQueued)
        )
    end)

    return results.modelRefreshed or results.controllerMarked or results.runtimeQueued
end

local function resolveGoldenRefreshReason(...)
    local argumentCount = select("#", ...)
    if argumentCount == 0 then
        return nil
    end

    local first = select(1, ...)
    if type(first) == "table" then
        if first == GoldenTracker then
            if argumentCount >= 2 then
                return select(2, ...)
            end
            return nil
        end

        local mt = getmetatable(first)
        if mt ~= nil then
            if mt == GoldenTracker then
                if argumentCount >= 2 then
                    return select(2, ...)
                end
                return nil
            end

            if type(mt) == "table" and mt.__index == GoldenTracker then
                if argumentCount >= 2 then
                    return select(2, ...)
                end
                return nil
            end
        end
    end

    return first
end

local function requestGoldenDataRefreshInternal(reason)
    return goldenDataChanged(reason) == true
end

-- MARK: GEVENTS_SWITCH_REFRESH_API
-- GEVENTS note: TempEvents and lifecycle callers use this API; future Events/Nvk3UT_GoldenEventHandler.lua should keep calling it.
function GoldenTracker:NotifyDataChanged(reason)
    local resolvedReason = resolveGoldenRefreshReason(self, reason)
    return requestGoldenDataRefreshInternal(resolvedReason)
end

function GoldenTracker.RequestDataRefresh(...)
    local resolvedReason = resolveGoldenRefreshReason(...)
    return requestGoldenDataRefreshInternal(resolvedReason)
end

GoldenTracker.RequestRefresh = GoldenTracker.RequestDataRefresh
GoldenTracker.RequestFullRefresh = GoldenTracker.RequestDataRefresh

local function getFrameTimeMilliseconds()
    local getter = rawget(_G, "GetFrameTimeMilliseconds")
    if type(getter) ~= "function" then
        getter = rawget(_G, "GetGameTimeMilliseconds")
    end

    if type(getter) == "function" then
        local ok, value = pcall(getter)
        if ok and type(value) == "number" then
            return value
        end
    end

    return 0
end

local function scheduleLater(delayMs, callback)
    local delay = tonumber(delayMs)
    if delay == nil or delay < 0 then
        delay = 0
    end

    if type(callback) ~= "function" then
        return nil
    end

    local callLater = rawget(_G, "zo_callLater")
    if type(callLater) == "function" then
        local ok, handle = pcall(callLater, callback, delay)
        if ok and handle ~= nil then
            return handle
        end
    end

    local callbackLabel = tostring(callback):gsub("[^%w_]", "_")
    local identifier = string.format("Nvk3UT_Golden_Once_%s_%d", callbackLabel, getFrameTimeMilliseconds())

    local eventManager = rawget(_G, "EVENT_MANAGER")
    if eventManager ~= nil and type(eventManager.RegisterForUpdate) == "function" then
        if type(eventManager.UnregisterForUpdate) == "function" then
            eventManager:UnregisterForUpdate(identifier)
        end

        eventManager:RegisterForUpdate(identifier, delay, function()
            local manager = rawget(_G, "EVENT_MANAGER")
            if manager ~= nil and type(manager.UnregisterForUpdate) == "function" then
                manager:UnregisterForUpdate(identifier)
            end

            pcall(callback)
        end)

        return identifier
    end

    return nil
end

local function cancelScheduled(handle)
    if handle == nil then
        return
    end

    if type(handle) == "number" then
        local remover = rawget(_G, "zo_removeCallLater")
        if type(remover) == "function" then
            pcall(remover, handle)
        end
        return
    end

    if type(handle) == "string" then
        local eventManager = rawget(_G, "EVENT_MANAGER")
        if eventManager ~= nil and type(eventManager.UnregisterForUpdate) == "function" then
            eventManager:UnregisterForUpdate(handle)
        end
    end
end

local function formatTempEventReason(reason)
    if reason == nil then
        return "n/a"
    end

    if type(reason) == "string" then
        if reason == "" then
            return "n/a"
        end
        return reason
    end

    return tostring(reason)
end

-- GEVENT TempEvents (Golden)
-- Purpose: temporary ESO registrations until GEVENTS_*_SWITCH migrates handlers into Events/Nvk3UT_GoldenEventHandler.lua.
-- Removal plan:
--   1) Delete the code enclosed by GEVENTS_TEMP_EVENTS_BEGIN/END markers when GEVENTS_*_SWITCH lands.
--   2) Ensure Events/Nvk3UT_GoldenEventHandler.lua wires the ESO events and calls the GoldenTracker refresh helper.
-- Search tags: @GEVENTS @TEMP @GOLDEN @REMOVE_ON_GEVENTS_SWITCH
--[[ GEVENTS_TEMP_EVENTS_BEGIN: Golden (remove on GEVENTS_*_SWITCH) ]]

local GOLDEN_TEMP_EVENT_NAMESPACE = MODULE_TAG .. ".TempEvents"

local GOLDEN_TEMP_EVENT_HANDLES = {
    updated = GOLDEN_TEMP_EVENT_NAMESPACE .. ".PursuitsUpdated",
    progress = GOLDEN_TEMP_EVENT_NAMESPACE .. ".ProgressUpdated",
    status = GOLDEN_TEMP_EVENT_NAMESPACE .. ".StatusUpdated",
    tracking = GOLDEN_TEMP_EVENT_NAMESPACE .. ".TrackingUpdated",
}

local GOLDEN_TEMP_EVENT_REASONS = {
    updated = "EVENT_GOLDEN_PURSUITS_UPDATED",
    progress = "EVENT_GOLDEN_PURSUITS_PROGRESS_UPDATED",
    status = "EVENT_GOLDEN_PURSUITS_STATUS_UPDATED",
    tracking = "EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED",
}

local GOLDEN_TEMP_EVENT_IDS = {
    updated = rawget(_G, "EVENT_GOLDEN_PURSUITS_UPDATED"),
    progress = rawget(_G, "EVENT_GOLDEN_PURSUITS_PROGRESS_UPDATED"),
    status = rawget(_G, "EVENT_GOLDEN_PURSUITS_STATUS_UPDATED"),
    tracking = rawget(_G, "EVENT_PROMOTIONAL_EVENTS_ACTIVITY_TRACKING_UPDATED"),
}

local goldenTempEventsState = {
    registered = false,
    pending = false,
    timerHandle = nil,
    lastQueuedAtMs = 0,
    debounceMs = 150,
}

local goldenProgressFallbackState = {
    timerHandle = nil,
    lastProgressAtMs = nil,
    delayMs = 750,
    pendingReason = nil,
}

local function clearGoldenTempEventsTimer()
    if goldenTempEventsState.timerHandle ~= nil then
        cancelScheduled(goldenTempEventsState.timerHandle)
        goldenTempEventsState.timerHandle = nil
    end

    goldenTempEventsState.pending = false
    goldenTempEventsState.lastQueuedAtMs = 0
end

local function cancelGoldenProgressFallbackTimer()
    if goldenProgressFallbackState.timerHandle ~= nil then
        cancelScheduled(goldenProgressFallbackState.timerHandle)
        goldenProgressFallbackState.timerHandle = nil
    end

    goldenProgressFallbackState.pendingReason = nil
end

local function queueGoldenTempEventRefresh(reason)
    local now = getFrameTimeMilliseconds()
    local lastQueued = goldenTempEventsState.lastQueuedAtMs or 0
    local elapsed = now - lastQueued
    if elapsed < 0 then
        elapsed = 0
    end

    local debounceMs = tonumber(goldenTempEventsState.debounceMs) or 0
    if debounceMs < 0 then
        debounceMs = 0
    end

    if elapsed >= debounceMs then
        goldenTempEventsState.lastQueuedAtMs = now
        GoldenTracker.RequestFullRefresh(GoldenTracker, reason)
        return
    end

    if goldenTempEventsState.pending then
        return
    end

    goldenTempEventsState.pending = true

    local delay = debounceMs - elapsed
    if delay < 0 then
        delay = 0
    end

    goldenTempEventsState.timerHandle = scheduleLater(delay, function()
        goldenTempEventsState.timerHandle = nil
        goldenTempEventsState.pending = false
        goldenTempEventsState.lastQueuedAtMs = getFrameTimeMilliseconds()
        GoldenTracker.RequestFullRefresh(GoldenTracker, reason)
    end)

    if goldenTempEventsState.timerHandle == nil then
        goldenTempEventsState.pending = false
        goldenTempEventsState.lastQueuedAtMs = now
        GoldenTracker.RequestFullRefresh(GoldenTracker, reason)
        return
    end

    safeDebug(
        "[GoldenTracker.TempEvents] refresh queued (debounced; reason=%s)",
        formatTempEventReason(reason)
    )
end

local function queueGoldenTempEventRefreshSafe(reason)
    runSafe(function()
        queueGoldenTempEventRefresh(reason)
    end)
end

local function scheduleGoldenProgressFallback(reason)
    if goldenProgressFallbackState.timerHandle ~= nil then
        return
    end

    local fallbackReason = reason or GOLDEN_TEMP_EVENT_REASONS.updated

    runSafe(function()
        local delay = tonumber(goldenProgressFallbackState.delayMs) or 0
        if delay < 0 then
            delay = 0
        end

        goldenProgressFallbackState.pendingReason = fallbackReason
        goldenProgressFallbackState.timerHandle = scheduleLater(delay, function()
            goldenProgressFallbackState.timerHandle = nil

            local now = getFrameTimeMilliseconds()
            local lastProgress = goldenProgressFallbackState.lastProgressAtMs or 0
            local elapsed = now - lastProgress
            if elapsed < 0 then
                elapsed = 0
            end

            if elapsed >= delay then
                safeDebug(
                    "[GoldenTracker.TempEvents] fallback triggered (reason=%s)",
                    formatTempEventReason(fallbackReason)
                )
                queueGoldenTempEventRefreshSafe(fallbackReason)
            end

            goldenProgressFallbackState.pendingReason = nil
        end)

        if goldenProgressFallbackState.timerHandle ~= nil then
            safeDebug(
                "[GoldenTracker.TempEvents] fallback scheduled (reason=%s)",
                formatTempEventReason(fallbackReason)
            )
        else
            goldenProgressFallbackState.pendingReason = nil
            queueGoldenTempEventRefreshSafe(fallbackReason)
        end
    end)
end

local function onGoldenPursuitsUpdated(...)
    local reason = GOLDEN_TEMP_EVENT_REASONS.updated
    safeDebug("[GoldenTracker.TempEvents] %s", reason)
    scheduleGoldenProgressFallback(reason)
end

local function onGoldenPursuitsProgressUpdated(...)
    local reason = GOLDEN_TEMP_EVENT_REASONS.progress
    goldenProgressFallbackState.lastProgressAtMs = getFrameTimeMilliseconds()
    safeDebug("[GoldenTracker.TempEvents] progress → queue (reason=%s)", formatTempEventReason(reason))
    queueGoldenTempEventRefreshSafe(reason)
end

local function onGoldenPursuitsStatusUpdated(...)
    local reason = GOLDEN_TEMP_EVENT_REASONS.status
    safeDebug("[GoldenTracker.TempEvents] %s", reason)
    scheduleGoldenProgressFallback(reason)
end

local function onGoldenPursuitsTrackingUpdated(...)
    local reason = GOLDEN_TEMP_EVENT_REASONS.tracking
    safeDebug("[GoldenTracker.TempEvents] %s", reason)
    queueGoldenTempEventRefreshSafe(reason)
end

local function registerGoldenTempEvents()
    if goldenTempEventsState.registered then
        return
    end

    clearGoldenTempEventsTimer()
    cancelGoldenProgressFallbackTimer()
    goldenProgressFallbackState.lastProgressAtMs = nil

    local eventManager = rawget(_G, "EVENT_MANAGER")
    if eventManager == nil then
        return
    end

    local registerMethod = eventManager.RegisterForEvent
    if type(registerMethod) ~= "function" then
        return
    end

    local registeredCount = 0

    if GOLDEN_TEMP_EVENT_IDS.updated ~= nil then
        eventManager:RegisterForEvent(
            GOLDEN_TEMP_EVENT_HANDLES.updated,
            GOLDEN_TEMP_EVENT_IDS.updated,
            onGoldenPursuitsUpdated
        )
        registeredCount = registeredCount + 1
    end

    if GOLDEN_TEMP_EVENT_IDS.progress ~= nil then
        eventManager:RegisterForEvent(
            GOLDEN_TEMP_EVENT_HANDLES.progress,
            GOLDEN_TEMP_EVENT_IDS.progress,
            onGoldenPursuitsProgressUpdated
        )
        registeredCount = registeredCount + 1
    end

    if GOLDEN_TEMP_EVENT_IDS.status ~= nil then
        eventManager:RegisterForEvent(
            GOLDEN_TEMP_EVENT_HANDLES.status,
            GOLDEN_TEMP_EVENT_IDS.status,
            onGoldenPursuitsStatusUpdated
        )
        registeredCount = registeredCount + 1
    end

    if GOLDEN_TEMP_EVENT_IDS.tracking ~= nil then
        eventManager:RegisterForEvent(
            GOLDEN_TEMP_EVENT_HANDLES.tracking,
            GOLDEN_TEMP_EVENT_IDS.tracking,
            onGoldenPursuitsTrackingUpdated
        )
        registeredCount = registeredCount + 1
    end

    if registeredCount > 0 then
        goldenTempEventsState.registered = true
        safeDebug("[GoldenTracker.TempEvents] register (%d handlers)", registeredCount)
    end
end

local function unregisterGoldenTempEvents()
    clearGoldenTempEventsTimer()
    cancelGoldenProgressFallbackTimer()
    goldenProgressFallbackState.lastProgressAtMs = nil

    if not goldenTempEventsState.registered then
        return
    end

    local eventManager = rawget(_G, "EVENT_MANAGER")
    if eventManager == nil then
        return
    end

    local unregisterMethod = eventManager.UnregisterForEvent
    if type(unregisterMethod) ~= "function" then
        return
    end

    unregisterMethod(eventManager, GOLDEN_TEMP_EVENT_HANDLES.updated)
    unregisterMethod(eventManager, GOLDEN_TEMP_EVENT_HANDLES.progress)
    unregisterMethod(eventManager, GOLDEN_TEMP_EVENT_HANDLES.status)
    unregisterMethod(eventManager, GOLDEN_TEMP_EVENT_HANDLES.tracking)

    goldenTempEventsState.registered = false
    safeDebug("[GoldenTracker.TempEvents] unregister")
end

function GoldenTracker:TempEvents_Register()
    registerGoldenTempEvents()
end

function GoldenTracker:TempEvents_Unregister()
    unregisterGoldenTempEvents()
end

registerGoldenTempEvents()

--[[ GEVENTS_TEMP_EVENTS_END: Golden (remove on GEVENTS_*_SWITCH) ]]

function GoldenTracker.Refresh(...)
    local tracker, viewModel = resolveRefreshArguments(...)
    if not tracker.initialized then
        return
    end

    local container = tracker.container or state.container
    local root = tracker.root or state.root
    local content = tracker.content or state.content

    if not container or not root or not content then
        tracker.height = 0
        state.height = 0
        setContainerHeight(container, 0)
        return
    end

    local rowsModule = getRowsModule()
    local layoutModule = getLayoutModule()

    if rowsModule and type(rowsModule.ResetAlignmentLog) == "function" then
        rowsModule.ResetAlignmentLog()
    end

    local objectiveIndent = getObjectiveIndentFromSaved()
    local entryIndent = getEntryIndentFromSaved()

    if rowsModule and type(rowsModule.SetObjectiveIndent) == "function" then
        rowsModule.SetObjectiveIndent(objectiveIndent)
    end

    if rowsModule and type(rowsModule.SetEntryIndent) == "function" then
        rowsModule.SetEntryIndent(entryIndent)
    end

    safeDebug(
        "[GoldenIndent] resolved objective=%s entry=%s",
        tostring(objectiveIndent),
        tostring(entryIndent)
    )

    if rowsModule and type(rowsModule.ReleaseAllCategoryRows) == "function" then
        rowsModule.ReleaseAllCategoryRows()
    end

    if rowsModule and type(rowsModule.ReleaseAllEntryRows) == "function" then
        rowsModule.ReleaseAllEntryRows()
    end

    if rowsModule and type(rowsModule.ReleaseAllObjectiveRows) == "function" then
        rowsModule.ReleaseAllObjectiveRows()
    end

    tracker.viewModel = type(viewModel) == "table" and viewModel or nil
    local vm = tracker.viewModel
    local summary = type(vm) == "table" and type(vm.summary) == "table" and vm.summary or {}
    local objectives = type(vm) == "table" and type(vm.objectives) == "table" and vm.objectives or {}
    local hasEntriesForTracker = type(vm) == "table" and vm.hasEntriesForTracker == true
    local capstoneReached = vm and (vm.capstoneReached == true or summary.capstoneReached == true)
    local generalMode = vm and (vm.generalCompletedMode or summary.generalCompletedMode)
    local hideCategoryWhenCompleted = vm and (vm.hideCategoryWhenCompleted == true or summary.hideCategoryWhenCompleted == true)
    local hideObjectivesWhenCompleted = vm and (vm.hideObjectivesWhenCompleted == true or summary.hideObjectivesWhenCompleted == true)
    local showOpenObjectiveRecolorMode = vm and vm.showOpenObjectiveRecolorMode == true
    local showOpenMode = vm and not showOpenObjectiveRecolorMode and (vm.showOpenMode == true or (capstoneReached and generalMode == "showOpen"))

    if hideCategoryWhenCompleted then
        hasEntriesForTracker = false
        if vm then
            vm.hasEntriesForTracker = false
            if type(vm.status) == "table" then
                vm.status.hasEntriesForTracker = false
                vm.status.hasEntries = false
            end
        end
    end

    safeDebug(
        "Refresh start: vmNil=%s hasEntriesForTracker=%s hasCampaign=%s objectives=%d",
        tostring(vm == nil),
        tostring(hasEntriesForTracker),
        tostring(summary.hasActiveCampaign),
        #objectives
    )

    if capstoneReached ~= nil or generalMode ~= nil then
        safeDebug(
            "[GoldenTracker] generalMode=%s capstoneReached=%s hideCategory=%s hideObjectives=%s",
            tostring(generalMode),
            tostring(capstoneReached),
            tostring(hideCategoryWhenCompleted),
            tostring(hideObjectivesWhenCompleted)
        )
    end

    if vm == nil then
        tracker.height = 0
        state.height = 0
        setContainerHeight(container, 0)
        applyVisibility(root, true)
        applyVisibility(content, true)
        safeDebug("Refresh aborted: view model missing")
        return
    end

    local rows = tracker.rows or {}
    resetRows(rows)
    tracker.rows = rows

    if not hasEntriesForTracker then
        tracker.height = 0
        state.height = 0
        setContainerHeight(container, 0)
        applyVisibility(root, true)
        applyVisibility(content, true)
        safeDebug("Refresh aborted: no tracker entries")
        return
    end

    local categoryExpanded = true
    if vm and vm.categoryExpanded ~= nil then
        categoryExpanded = vm.categoryExpanded ~= false
    elseif vm and vm.header ~= nil then
        categoryExpanded = vm.header.isExpanded ~= false
    end

    local entryExpanded = true
    if vm and vm.entryExpanded ~= nil then
        entryExpanded = vm.entryExpanded ~= false
    else
        entryExpanded = summary.isExpanded ~= false
    end

    if rowsModule then
        if summary.hasActiveCampaign == true then
            local categoryPayload = {
                isExpanded = categoryExpanded,
                categoryIndent = getCategoryIndentFromSaved(),
                remainingObjectivesToNextReward = summary.remainingObjectivesToNextReward,
                remainingAllObjectives = summary.remainingAllObjectives,
                generalCompletedMode = summary.generalCompletedMode,
                capstoneReached = summary.capstoneReached,
                textures = summary.textures,
            }
            safeDebug(
                "[GoldenIndent] payload.categoryIndent=%s",
                tostring(categoryPayload.categoryIndent)
            )

            local categoryRow = nil
            if type(rowsModule.AcquireCategoryRow) == "function" then
                categoryRow = rowsModule.AcquireCategoryRow(content)
                if categoryRow and type(rowsModule.ApplyCategoryRow) == "function" then
                    rowsModule.ApplyCategoryRow(categoryRow, categoryPayload)
                end
            end

            if categoryRow then
                table.insert(rows, categoryRow.control or categoryRow)
            end

            if categoryExpanded then
                local campaignPayload = summary
                if type(campaignPayload) == "table" then
                    campaignPayload.isExpanded = entryExpanded
                end

                local campaignRow = nil
                if type(rowsModule.AcquireEntryRow) == "function" then
                    campaignRow = rowsModule.AcquireEntryRow(content)
                    if campaignRow and type(rowsModule.ApplyEntryRow) == "function" then
                        rowsModule.ApplyEntryRow(campaignRow, campaignPayload)
                    end
                end

                if campaignRow then
                    table.insert(rows, campaignRow.control or campaignRow)
                end
            end
        end

        if categoryExpanded and entryExpanded then
            local objectivesForRows = objectives
            if capstoneReached and generalMode == "recolor" then
                objectivesForRows = {}
            elseif showOpenMode then
                objectivesForRows = {}
                for index = 1, #objectives do
                    local objectiveData = objectives[index]
                    if not isObjectiveCompleted(objectiveData) then
                        objectivesForRows[#objectivesForRows + 1] = objectiveData
                    end
                end
            elseif hideObjectivesWhenCompleted then
                objectivesForRows = {}
            end
            for objectiveIndex = 1, #objectivesForRows do
                local objectiveData = objectivesForRows[objectiveIndex]
                if type(objectiveData) == "table" then
                    local objectiveRow = nil
                    if type(rowsModule.AcquireObjectiveRow) == "function" then
                        objectiveRow = rowsModule.AcquireObjectiveRow(content)
                        if objectiveRow and type(rowsModule.ApplyObjectiveRow) == "function" then
                            rowsModule.ApplyObjectiveRow(objectiveRow, objectiveData)
                        end
                    end

                    if objectiveRow then
                        table.insert(rows, objectiveRow.control or objectiveRow)
                    end
                end
            end
        end
    else
        safeDebug("Refresh aborted; rows module unavailable")
    end

    local totalHeight = 0

    if layoutModule then
        totalHeight = layoutModule.ApplyLayout(content, rows) or 0
    else
        safeDebug("Refresh passthrough skipped; layout module unavailable")
    end

    local hasRows = #rows > 0 and layoutModule ~= nil
    applyVisibility(root, not hasRows)
    applyVisibility(content, not hasRows)

    tracker.height = totalHeight
    state.height = totalHeight
    setContainerHeight(container, totalHeight)

    safeDebug(
        "Refresh complete: rows=%d height=%d hasCampaign=%s remaining=%s",
        #rows,
        totalHeight,
        tostring(summary.hasActiveCampaign),
        tostring(summary.remainingObjectivesToNextReward)
    )
end

function GoldenTracker:GetHeight()
    local resolvedHeight = self and self.height or state.height
    local height = tonumber(resolvedHeight) or 0
    if height < 0 then
        height = 0
    end
    return height
end

Nvk3UT.GoldenTracker = GoldenTracker

-- MARK: GEVENTS_SWITCH_REFRESH_EXPORT
-- GEVENTS note: Central events will continue to call this entry point after ESO registrations move to Events/.
function Nvk3UT.GoldenTracker_RequestFullRefresh(...)
    return GoldenTracker.RequestFullRefresh(...)
end

return GoldenTracker
