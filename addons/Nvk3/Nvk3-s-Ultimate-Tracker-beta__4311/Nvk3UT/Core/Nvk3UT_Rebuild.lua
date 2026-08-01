-- Core/Nvk3UT_Rebuild.lua
-- Centralized rebuild / refresh helpers for Nvk3UT.
-- This module is allowed to request a full UI/model refresh, but it should NOT
-- directly register events, build UI controls, or call ReloadUI.

Nvk3UT_Rebuild = Nvk3UT_Rebuild or {}

local Rebuild = Nvk3UT_Rebuild
Rebuild._root = type(Rebuild._root) == "table" and Rebuild._root or nil

local ATTACH_RETRY_MS = 100
local ATTACH_MAX_ATTEMPTS = 10
local TOGGLE_FOLLOWUP_DELAY_MS = 1

local attachToRoot
local pendingToggleFollowup = false
local pendingToggleReason

local function formatMessage(prefix, fmt, ...)
    if fmt == nil then
        return prefix
    end

    local messageFmt = prefix .. tostring(fmt)
    local ok, message = pcall(string.format, messageFmt, ...)
    if ok then
        return message
    end

    return prefix .. tostring(fmt)
end

local function _debug(fmt, ...)
    if Nvk3UT and type(Nvk3UT.Debug) == "function" then
        Nvk3UT.Debug(fmt, ...)
        return
    end

    if d then
        d(formatMessage("[Nvk3UT Rebuild] ", fmt, ...))
    end
end

local function _error(fmt, ...)
    if Nvk3UT and type(Nvk3UT.Error) == "function" then
        Nvk3UT.Error(fmt, ...)
        return
    end

    if d then
        d(formatMessage("|cFF0000[Nvk3UT Rebuild ERROR]|r ", fmt, ...))
    end
end

local function safeInvoke(label, fn, ...)
    if type(fn) ~= "function" then
        return false
    end

    local ok, result = pcall(fn, ...)
    if not ok then
        _error("%s failed: %s", tostring(label or "callback"), tostring(result))
        return false
    end

    return true, result
end

local function getRoot()
    if type(Rebuild._root) == "table" then
        return Rebuild._root
    end

    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" then
        if attachToRoot then
            attachToRoot(root)
        end
        return root
    end

    return nil
end

local function getRuntime()
    local root = getRoot()
    if type(root) ~= "table" then
        return nil
    end

    local runtime = rawget(root, "TrackerRuntime")
    if type(runtime) == "table" then
        return runtime
    end

    return nil
end

local function getHost()
    local root = getRoot()
    if type(root) ~= "table" then
        return nil
    end

    local host = rawget(root, "TrackerHost")
    if type(host) ~= "table" then
        return nil
    end

    return host
end

local function isHostVisible()
    local host = getHost()
    if type(host) ~= "table" then
        return true
    end

    local isVisible = host.IsVisible or host.IsShown
    if type(isVisible) == "function" then
        local ok, visible = pcall(isVisible, host)
        if ok and visible ~= nil then
            return visible == true
        end
    end

    return false
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

    local root = getRoot()
    if type(root) == "table" and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return root:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local sv = root and (rawget(root, "SV") or rawget(root, "sv"))
    if type(sv) == "table" and sv.debug ~= nil then
        return sv.debug == true
    end

    return false
end

local function debugLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local message = formatMessage("[Rebuild] ", fmt, ...)
    if Nvk3UT and type(Nvk3UT.Debug) == "function" then
        safeInvoke("Nvk3UT.Debug", Nvk3UT.Debug, message)
        return
    end

    local root = getRoot()
    if type(root) == "table" and type(root.Debug) == "function" then
        safeInvoke("Addon.Debug", root.Debug, message)
        return
    end

    if d then
        d(message)
    end
end

local function formatToggleReason(reason)
    if type(reason) ~= "string" or reason == "" then
        return "toggleDelayed"
    end

    return string.format("toggleDelayed:%s", reason)
end

local TRACKER_SECTION_ORDER = { "quest", "endeavor", "achievement", "golden" }
local VALID_SECTION_KEYS = {
    quest = "quest",
    endeavor = "endeavor",
    golden = "golden",
    achievement = "achievement",
    layout = "layout",
}

local function resolveSafeCall()
    local root = getRoot()
    if type(root) == "table" and type(root.SafeCall) == "function" then
        return root.SafeCall
    end

    if Nvk3UT and type(Nvk3UT.SafeCall) == "function" then
        return Nvk3UT.SafeCall
    end

    return nil
end

-- MARK: GEVENTS_SWITCH_GOLDEN_REFRESH_CALLERS
-- GEVENTS note: Rebuild/StateInit keep calling into GoldenTracker's refresh API even after ESO registrations migrate to Events/.
local function queueGoldenDirtyChannel(context)
    local root = getRoot()
    local tracker = type(root) == "table" and rawget(root, "GoldenTracker") or nil

    local resolvedReason = context
    if resolvedReason == nil or resolvedReason == "" then
        resolvedReason = "rebuild"
    else
        resolvedReason = tostring(resolvedReason)
    end

    local function invokeHelper(helper, label, passSelf)
        if type(helper) ~= "function" then
            return false
        end

        local ok, result
        if passSelf then
            ok, result = safeInvoke(label, helper, tracker, resolvedReason)
        else
            ok, result = safeInvoke(label, helper, resolvedReason)
        end

        if not ok then
            return false
        end

        if result == nil then
            return true
        end

        return result ~= false
    end

    if type(tracker) == "table" then
        if invokeHelper(tracker.RequestFullRefresh, "GoldenTracker.RequestFullRefresh", true) then
            return true
        end

        if invokeHelper(tracker.NotifyDataChanged, "GoldenTracker.NotifyDataChanged", true) then
            return true
        end

        if invokeHelper(tracker.RequestDataRefresh, "GoldenTracker.RequestDataRefresh", true) then
            return true
        end

        if invokeHelper(tracker.RequestRefresh, "GoldenTracker.RequestRefresh", true) then
            return true
        end
    end

    local runtime = getRuntime()
    if type(runtime) ~= "table" then
        return false
    end

    local queueDirty = runtime.QueueDirty or runtime.queueDirty
    if type(queueDirty) ~= "function" then
        return false
    end

    local safeCall = resolveSafeCall()
    if type(safeCall) == "function" then
        local result = safeCall(queueDirty, runtime, "golden")
        if result == false then
            return false
        end

        return true
    end

    local label = "TrackerRuntime.QueueDirty(golden)"
    return safeInvoke(label, queueDirty, runtime, "golden") == true
end

local function queueDirtyChannel(channel)
    local runtime = getRuntime()
    if type(runtime) ~= "table" then
        return false
    end

    local queueDirty = runtime.QueueDirty or runtime.queueDirty
    if type(queueDirty) ~= "function" then
        return false
    end

    local label = string.format("TrackerRuntime.QueueDirty(%s)", tostring(channel or "all"))
    local ok = safeInvoke(label, queueDirty, runtime, channel)
    return ok == true
end

local function buildSectionList(sections)
    local requested = {}

    local function addSection(key)
        if type(key) ~= "string" then
            return
        end

        local normalized = string.lower(key)
        local resolved = VALID_SECTION_KEYS[normalized]
        if resolved ~= nil then
            requested[resolved] = true
            return
        end

        if isDebugEnabled() then
            _debug("Sections(): unknown key '%s'", tostring(key))
        end
    end

    if sections == nil then
        for index = 1, #TRACKER_SECTION_ORDER do
            requested[TRACKER_SECTION_ORDER[index]] = true
        end
        return requested
    end

    if type(sections) == "string" then
        if sections == "all" or sections == "trackers" then
            for index = 1, #TRACKER_SECTION_ORDER do
                requested[TRACKER_SECTION_ORDER[index]] = true
            end
            return requested
        end

        addSection(sections)
        return requested
    end

    if type(sections) == "table" then
        for index = 1, #sections do
            local value = sections[index]
            if value == "all" or value == "trackers" then
                for order = 1, #TRACKER_SECTION_ORDER do
                    requested[TRACKER_SECTION_ORDER[order]] = true
                end
            else
                addSection(value)
            end
        end
    end

    return requested
end

local function queueSectionsInternal(sectionFlags, context)
    local queued = {}
    local triggered = false

    for order = 1, #TRACKER_SECTION_ORDER do
        local key = TRACKER_SECTION_ORDER[order]
        if sectionFlags[key] then
            local queuedChannel = false
            if key == "golden" then
                local reason = context
                if reason == nil or reason == "" then
                    reason = string.format("sections:%s", key)
                end
                queuedChannel = queueGoldenDirtyChannel(reason)
            else
                queuedChannel = queueDirtyChannel(key)
            end

            if queuedChannel then
                queued[#queued + 1] = key
                triggered = true
            end
        end
    end

    if sectionFlags.layout and queueDirtyChannel("layout") then
        queued[#queued + 1] = "layout"
        triggered = true
    end

    if triggered and #queued > 0 then
        local joined = table.concat(queued, ", ")
        if context ~= nil and context ~= "" then
            debugLog("queued %s dirty (%s)", joined, tostring(context))
        else
            debugLog("queued %s dirty", joined)
        end
    end

    return triggered
end

local function resolveAchievementsSystem()
    if type(SYSTEMS) == "table" and type(SYSTEMS.GetObject) == "function" then
        local ok, system = pcall(SYSTEMS.GetObject, SYSTEMS, "achievements")
        if ok and system then
            return system
        end
    end

    return ACHIEVEMENTS
end

local function describeContext(action, context)
    if context == nil or context == "" then
        _debug("%s() requested", action)
    else
        _debug("%s() requested (%s)", action, tostring(context))
    end
end

local function requestQuestTrackerRefresh()
    local root = getRoot()
    local tracker = root and root.QuestTracker
    local runtime = root and root.TrackerRuntime
    if type(runtime) == "table" and type(runtime.QueueDirty) == "function" then
        return safeInvoke("TrackerRuntime.QueueDirty", runtime.QueueDirty, runtime, "quest")
    end
    if type(tracker) ~= "table" then
        return false
    end

    if type(tracker.RequestRefresh) == "function" then
        return safeInvoke("QuestTracker.RequestRefresh", tracker.RequestRefresh)
    end

    return false
end

local function requestAchievementTrackerRefresh()
    local root = getRoot()
    local runtime = root and root.TrackerRuntime
    if type(runtime) == "table" and type(runtime.QueueDirty) == "function" then
        return safeInvoke("TrackerRuntime.QueueDirty(achievement)", runtime.QueueDirty, runtime, "achievement")
    end

    local controller = root and root.AchievementTrackerController
    if type(controller) == "table" and type(controller.MarkDirty) == "function" then
        return safeInvoke("AchievementTrackerController.MarkDirty", controller.MarkDirty, controller)
    end

    local tracker = root and root.AchievementTracker
    if type(tracker) == "table" and type(tracker.Refresh) == "function" then
        return safeInvoke("AchievementTracker.Refresh", tracker.Refresh, tracker)
    end

    return false
end

local function refreshTrackerHost()
    local root = getRoot()
    local host = root and root.TrackerHost
    if type(host) ~= "table" or type(host.Refresh) ~= "function" then
        return false
    end

    return safeInvoke("TrackerHost.Refresh", host.Refresh)
end

local function rebuildCompletedData()
    local root = getRoot()
    local completed = root and root.CompletedData
    if type(completed) ~= "table" or type(completed.Rebuild) ~= "function" then
        return false
    end

    return safeInvoke("CompletedData.Rebuild", completed.Rebuild)
end

---Force the quest tracker to refresh its view model / layout.
---@param context string|nil
---@return boolean triggered
function Rebuild.ForceQuestRefresh(context)
    describeContext("ForceQuestRefresh", context)

    local triggered = false

    -- TODO: Replace direct tracker refresh with Runtime dirty-queue once
    -- RUNTIME_001_CREATE_TrackerRuntime_lua lands.
    triggered = requestQuestTrackerRefresh() or triggered

    if not triggered then
        triggered = refreshTrackerHost() or triggered
    end

    return triggered
end

---Force the achievement tracker to refresh its view model / layout.
---@param context string|nil
---@return boolean triggered
function Rebuild.ForceAchievementRefresh(context)
    describeContext("ForceAchievementRefresh", context)

    local triggered = false

    -- TODO: Replace direct tracker refresh with Runtime dirty-queue once
    -- RUNTIME_001_CREATE_TrackerRuntime_lua lands.
    triggered = requestAchievementTrackerRefresh() or triggered

    if not triggered then
        triggered = refreshTrackerHost() or triggered
    end

    return triggered
end

---Force the endeavor tracker to refresh via the runtime dirty queue.
---@param context string|nil
---@return boolean triggered
function Rebuild.ForceEndeavorRefresh(context)
    describeContext("ForceEndeavorRefresh", context)

    local triggered = queueDirtyChannel("endeavor")
    if triggered then
        if context ~= nil and context ~= "" then
            debugLog("queued endeavor dirty (%s)", tostring(context))
        else
            debugLog("queued endeavor dirty")
        end
    end

    return triggered
end

---Queue the golden tracker to refresh via the runtime dirty queue.
---@param context string|nil
---@return boolean triggered
function Rebuild.Golden(context)
    describeContext("Golden", context)

    local reason = context
    if reason == nil or reason == "" then
        reason = "rebuild"
    else
        reason = string.format("rebuild:%s", tostring(reason))
    end

    local triggered = queueGoldenDirtyChannel(reason)
    if triggered then
        debugLog("Rebuild Golden requested (dirty queued)")
    end

    return triggered
end

---Force a global refresh touching quests, achievements, and tracker host state.
---@param context string|nil
function Rebuild.ForceGlobalRefresh(context)
    describeContext("ForceGlobalRefresh", context)

    rebuildCompletedData()

    local questTriggered = Rebuild.ForceQuestRefresh(context)
    local endeavorTriggered = Rebuild.ForceEndeavorRefresh(context)
    local achievementTriggered = Rebuild.ForceAchievementRefresh(context)

    if questTriggered or endeavorTriggered or achievementTriggered then
        refreshTrackerHost()
    end

    local root = getRoot()
    if type(root) == "table" then
        if type(root.UIUpdateStatus) == "function" then
            safeInvoke("Addon:UIUpdateStatus", function()
                root:UIUpdateStatus()
            end)
        elseif root.UI and type(root.UI.UpdateStatus) == "function" then
            safeInvoke("UI.UpdateStatus", root.UI.UpdateStatus)
        end
    end
end

---Queue all trackers to rebuild via the runtime.
---@param context string|nil
---@return boolean triggered
function Rebuild.MarkAllDirty(context)
    describeContext("MarkAllDirty", context)

    local flags = {}
    for order = 1, #TRACKER_SECTION_ORDER do
        flags[TRACKER_SECTION_ORDER[order]] = true
    end

    return queueSectionsInternal(flags, context)
end

---Queue quests, endeavors, achievements, and golden plus layout in a single call.
---@param context string|nil
---@return boolean triggered
function Rebuild.All(context)
    describeContext("All", context)

    local hostVisible = isHostVisible()

    if not hostVisible then
        local runtime = getRuntime()
        local setPending = runtime and (runtime.SetPendingFullRebuild or runtime.setPendingFullRebuild)
        if type(setPending) == "function" then
            local reason = context
            if reason == nil or reason == "" then
                reason = "hidden"
            end

            safeInvoke("TrackerRuntime.SetPendingFullRebuild", setPending, runtime, reason)
        end
    end

    local flags = { layout = true }
    for order = 1, #TRACKER_SECTION_ORDER do
        flags[TRACKER_SECTION_ORDER[order]] = true
    end

    debugLog("Rebuild.All queue order: %s", table.concat(TRACKER_SECTION_ORDER, " → "))

    local triggered = queueSectionsInternal(flags, context)

    if triggered and isHostVisible() then
        local runtime = getRuntime()
        local processFrame = runtime and (runtime.ProcessFrame or runtime.processFrame)
        if type(processFrame) == "function" then
            safeInvoke("TrackerRuntime.ProcessFrame", processFrame, runtime)
        end
    end

    return triggered
end

---Queue specified tracker sections to rebuild.
---@param sections string|string[]
---@param context string|nil
---@return boolean triggered
function Rebuild.Sections(sections, context)
    describeContext("Sections", context)

    local flags = buildSectionList(sections)
    return queueSectionsInternal(flags, context)
end

---Queue all tracker sections to rebuild (quest → endeavor → achievement → golden).
---@param context string|nil
---@return boolean triggered
function Rebuild.Trackers(context)
    describeContext("Trackers", context)

    local flags = {}
    for order = 1, #TRACKER_SECTION_ORDER do
        flags[TRACKER_SECTION_ORDER[order]] = true
    end

    return queueSectionsInternal(flags, context)
end

---Queue tracker or layout rebuild by name.
---@param name string
---@param context string|nil
---@return boolean triggered
function Rebuild.ByName(name, context)
    describeContext("ByName", context)

    if type(name) ~= "string" or name == "" then
        return false
    end

    local normalized = string.lower(name)
    if normalized == "golden" then
        return Rebuild.Golden(context)
    elseif normalized == "all" then
        return Rebuild.All(context)
    elseif normalized == "trackers" then
        return Rebuild.Trackers(context)
    elseif normalized == "layout" then
        return Rebuild.ForceLayout(context)
    end

    return Rebuild.Sections(normalized, context)
end

---Queue the tracker host layout for recompute.
---@param context string|nil
---@return boolean triggered
function Rebuild.ForceLayout(context)
    describeContext("ForceLayout", context)

    local flags = { layout = true }
    return queueSectionsInternal(flags, context)
end

function Rebuild.ScheduleToggleFollowup(reason)
    if pendingToggleFollowup then
        debugLog("[Rebuild.ToggleFollowup] skip, already pending (reason=%s)", tostring(reason))
        return false
    end

    if type(zo_callLater) ~= "function" then
        debugLog("[Rebuild.ToggleFollowup] unable to schedule (zo_callLater missing, reason=%s)", tostring(reason))
        return false
    end

    pendingToggleFollowup = true
    pendingToggleReason = reason

    local delayMs = TOGGLE_FOLLOWUP_DELAY_MS
    debugLog("[Rebuild.ToggleFollowup] scheduled (reason=%s, delay=%dms)", tostring(reason), delayMs)

    local scheduledReason = reason
    zo_callLater(function()
        pendingToggleFollowup = false
        pendingToggleReason = nil

        local rebuildReason = formatToggleReason(scheduledReason)
        debugLog("[Rebuild.ToggleFollowup] executing delayed rebuild (reason=%s)", rebuildReason)

        local rebuildAll = Rebuild and Rebuild.All
        if type(rebuildAll) == "function" then
            rebuildAll(rebuildReason)
        end
    end, delayMs)

    return true
end

function Rebuild.ScheduleSpacingRebuild(reason)
    local spacingReason = reason
    if spacingReason == nil or spacingReason == "" then
        spacingReason = "spacing"
    end
    return Rebuild.ScheduleToggleFollowup(spacingReason)
end

attachToRoot = function(root)
    if type(root) ~= "table" then
        return
    end

    Rebuild._root = root
    root.Rebuild = Rebuild
end

function Rebuild.AttachToRoot(root)
    attachToRoot(root)
end

local function scheduleAttach(attempt)
    if type(Rebuild._root) == "table" then
        return
    end

    local root = rawget(_G, "Nvk3UT")
    if type(root) == "table" then
        attachToRoot(root)
        return
    end

    if attempt >= ATTACH_MAX_ATTEMPTS then
        return
    end

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            scheduleAttach(attempt + 1)
        end, ATTACH_RETRY_MS)
    end
end

scheduleAttach(0)

return Rebuild
