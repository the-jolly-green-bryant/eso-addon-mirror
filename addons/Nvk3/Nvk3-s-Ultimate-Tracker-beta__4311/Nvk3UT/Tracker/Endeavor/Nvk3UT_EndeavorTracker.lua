local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Utils = Nvk3UT and Nvk3UT.Utils

local EndeavorTracker = {}
EndeavorTracker.__index = EndeavorTracker

local MODULE_TAG = addonName .. ".EndeavorTracker"

local state = {
    container = nil,
    currentHeight = 0,
    isInitialized = false,
    isDisposed = false,
    ui = nil,
}

-- EBOOT TempEvents (Endeavor)
-- Purpose: SHIM-only events for Endeavor until EEVENTS_*_SWITCH migrates handlers to Events/*
-- Removal plan:
--   1) Set EBOOT_TEMP_EVENTS_ENABLED = false
--   2) Delete code between EBOOT_TEMP_EVENTS_BEGIN/END markers
--   3) Ensure Events/* registers Endeavor events; this tracker must not register any events
-- Search tags: @EBOOT @TEMP @ENDEAVOR @REMOVE_ON_EEVENTS_SWITCH
--[[ EBOOT_TEMP_EVENTS_BEGIN: Endeavor (remove on Eevents SWITCH) ]]

local EBOOT_TEMP_EVENTS_ENABLED = true -- flip to false in Eevents SWITCH token

local TEMP_EVENT_NAMESPACE = MODULE_TAG .. ".TempEvents"

local tempEvents = {
    registered = false,
    pending = false,
    timerHandle = nil,
    lastQueuedAt = 0,
    debounceMs = 150,
}

local shimStateInitialized = false
local shimModelInitialized = false
local centralEventsWarningShown = false

local initKick = {
    done = false,
    timerHandle = nil,
    delayMs = 200,
}

local progressFallback = {
    lastProgressAtMs = nil,
    timerHandle = nil,
    delayMs = 750,
}

local safeDebug

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

    local addon = rawget(_G, addonName)
    if type(addon) == "table" and type(addon.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return addon:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    return false
end

local INIT_POLLER_UPDATE_NAME = "Nvk3UT_Endeavor_InitPoller"

local CATEGORY_HEADER_HEIGHT = 26
local SECTION_ROW_HEIGHT = 24
local HEADER_TO_ROWS_GAP = 3
local ROW_GAP = 3
local SECTION_BOTTOM_GAP = 3
local SECTION_BOTTOM_GAP_COLLAPSED = 3
local CATEGORY_INDENT_X = 0
local CATEGORY_SPACING_ABOVE = 3
local CATEGORY_SPACING_BELOW = 6
local CATEGORY_CHEVRON_SIZE = 20
local CATEGORY_LABEL_OFFSET_X = 4
local SUBHEADER_INDENT_X = 18
local ENTRY_INDENT_X = SUBHEADER_INDENT_X
local ENTRY_ICON_SLOT_PX = 20
local ENTRY_SPACING_ABOVE = HEADER_TO_ROWS_GAP
local ENTRY_SPACING_BELOW = 0
local OBJECTIVE_INDENT_DEFAULT = 40
local OBJECTIVE_BASE_INDENT = 20
local OBJECTIVE_SPACING_ABOVE_DEFAULT = 3
local OBJECTIVE_SPACING_BELOW_DEFAULT = 3
local OBJECTIVE_SPACING_BETWEEN_DEFAULT = 1
local SUBROW_FIRST_SPACING = 2
local SUBROW_BETWEEN_SPACING = 1
local SUBROW_TRAILING_SPACING = 2

local DEFAULT_CATEGORY_FONT = "$(BOLD_FONT)|20|soft-shadow-thick"
local DEFAULT_SECTION_FONT = "$(BOLD_FONT)|16|soft-shadow-thick"
local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { 1, 1, 0.6, 1 }

local CHEVRON_TEXTURES = {
    expanded = "EsoUI/Art/Buttons/tree_open_up.dds",
    collapsed = "EsoUI/Art/Buttons/tree_closed_up.dds",
}

local CATEGORY_COLOR_ROLE_EXPANDED = "activeTitle"
local CATEGORY_COLOR_ROLE_COLLAPSED = "categoryTitle"
local ENTRY_COLOR_ROLE_DEFAULT = "entryTitle"

local function scheduleToggleFollowup(reason)
    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or _G.Nvk3UT_Rebuild
    if rebuild and type(rebuild.ScheduleToggleFollowup) == "function" then
        rebuild.ScheduleToggleFollowup(reason)
    end
end

local ENDEAVOR_TRACKER_COLOR_KIND = "endeavorTracker"

local function coerceHeight(value)
    if type(value) == "number" then
        if value ~= value then -- NaN guard
            return 0
        end
        return value
    end

    return 0
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

local function applyCategorySpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local endeavorSpacing = spacing and spacing.endeavor
    local category = endeavorSpacing and endeavorSpacing.category
    local entry = endeavorSpacing and endeavorSpacing.entry

    CATEGORY_INDENT_X = normalizeSpacingValue(category and category.indent, CATEGORY_INDENT_X)
    CATEGORY_SPACING_ABOVE = normalizeSpacingValue(category and category.spacingAbove, CATEGORY_SPACING_ABOVE)
    CATEGORY_SPACING_BELOW = normalizeSpacingValue(category and category.spacingBelow, CATEGORY_SPACING_BELOW)
    ENTRY_INDENT_X = normalizeSpacingValue(entry and entry.indent, ENTRY_INDENT_X)
    ENTRY_SPACING_ABOVE = normalizeSpacingValue(entry and entry.spacingAbove, ENTRY_SPACING_ABOVE)
    ENTRY_SPACING_BELOW = normalizeSpacingValue(entry and entry.spacingBelow, ENTRY_SPACING_BELOW)
end

local function getObjectiveIndentFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local endeavorSpacing = spacing and spacing.endeavor
    local objective = endeavorSpacing and endeavorSpacing.objective

    local indent = normalizeSpacingValue(objective and objective.indent, OBJECTIVE_INDENT_DEFAULT)
    return indent + OBJECTIVE_BASE_INDENT
end

local function getObjectiveSpacingAboveFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local endeavorSpacing = spacing and spacing.endeavor
    local objective = endeavorSpacing and endeavorSpacing.objective

    return normalizeSpacingValue(objective and objective.spacingAbove, OBJECTIVE_SPACING_ABOVE_DEFAULT)
end

local function getObjectiveSpacingBelowFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local endeavorSpacing = spacing and spacing.endeavor
    local objective = endeavorSpacing and endeavorSpacing.objective

    return normalizeSpacingValue(objective and objective.spacingBelow, OBJECTIVE_SPACING_BELOW_DEFAULT)
end

local function getObjectiveSpacingBetweenFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local endeavorSpacing = spacing and spacing.endeavor
    local objective = endeavorSpacing and endeavorSpacing.objective

    return normalizeSpacingValue(objective and objective.spacingBetween, OBJECTIVE_SPACING_BETWEEN_DEFAULT)
end

local function getCategoryRowHeightValue(rows, expanded)
    if rows and type(rows.GetCategoryRowHeight) == "function" then
        local ok, height = pcall(rows.GetCategoryRowHeight, expanded)
        if ok then
            local resolved = coerceHeight(height)
            if resolved > 0 then
                return resolved
            end
        end
    end

    return CATEGORY_HEADER_HEIGHT
end

local function FormatParensCount(a, b)
    local aNum = tonumber(a) or 0
    if aNum < 0 then
        aNum = 0
    end

    local bNum = tonumber(b) or 1
    if bNum < 1 then
        bNum = 1
    end

    if aNum > bNum then
        aNum = bNum
    end

    return string.format("(%d/%d)", math.floor(aNum + 0.5), math.floor(bNum + 0.5))
end

local function CallIfFunction(fn, ...)
    if type(fn) == "function" then
        return pcall(fn, ...)
    end

    return false, "not a function"
end

local function ScheduleLater(ms, cb)
    ms = (type(ms) == "number" and ms >= 0) and ms or 0

    if type(cb) ~= "function" then
        return nil
    end

    if type(_G.zo_callLater) == "function" then
        local ok, handle = pcall(_G.zo_callLater, cb, ms)
        if ok and handle ~= nil then
            return handle
        end
    end

    local cbLabel = tostring(cb or "cb")
    cbLabel = cbLabel:gsub("[^%w_]", "_")
    local id = "Nvk3UT_Endeavor_Once_" .. cbLabel .. "_" .. tostring(getFrameTime())
    local eventManager = rawget(_G, "EVENT_MANAGER")
    if eventManager and type(eventManager.RegisterForUpdate) == "function" then
        if type(eventManager.UnregisterForUpdate) == "function" then
            eventManager:UnregisterForUpdate(id)
        end
        eventManager:RegisterForUpdate(id, ms, function()
            local manager = rawget(_G, "EVENT_MANAGER")
            if manager and type(manager.UnregisterForUpdate) == "function" then
                manager:UnregisterForUpdate(id)
            end
            CallIfFunction(cb)
        end)
        return id
    end

    return nil
end

local function RemoveScheduled(handle)
    if handle == nil then
        return
    end

    if type(handle) == "number" and type(_G.zo_removeCallLater) == "function" then
        pcall(_G.zo_removeCallLater, handle)
        return
    end

    if type(handle) == "string" then
        local eventManager = rawget(_G, "EVENT_MANAGER")
        if eventManager and type(eventManager.UnregisterForUpdate) == "function" then
            eventManager:UnregisterForUpdate(handle)
        end
    end
end

local EVENT_TIMED_ACTIVITIES_UPDATED_ID = rawget(_G, "EVENT_TIMED_ACTIVITIES_UPDATED")
local EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED_ID = rawget(_G, "EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED")
local EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED_ID = rawget(_G, "EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED")

local function getAddon()
    return rawget(_G, addonName)
end

local function getTrackerColorFromHost(role)
    local addon = getAddon()
    if type(addon) ~= "table" then
        return 1, 1, 1, 1
    end

    local host = rawget(addon, "TrackerHost")
    if type(host) ~= "table" then
        return 1, 1, 1, 1
    end

    local ensureDefaults = host.EnsureAppearanceDefaults
    if type(ensureDefaults) == "function" then
        pcall(ensureDefaults, host)
    end

    local getColor = host.GetTrackerColor
    if type(getColor) ~= "function" then
        return 1, 1, 1, 1
    end

    local ok, r, g, b, a = pcall(getColor, host, ENDEAVOR_TRACKER_COLOR_KIND, role)
    if ok and type(r) == "number" then
        return r, g or 1, b or 1, a or 1
    end

    return 1, 1, 1, 1
end

local function getMouseoverHighlightColor()
    local addon = getAddon()
    if type(addon) ~= "table" then
        return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
    end

    local host = rawget(addon, "TrackerHost")
    if type(host) ~= "table" then
        return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
    end

    local ensureDefaults = host.EnsureAppearanceDefaults
    if type(ensureDefaults) == "function" then
        pcall(ensureDefaults, host)
    end

    local getColor = host.GetMouseoverHighlightColor
    if type(getColor) == "function" then
        local ok, r, g, b, a = pcall(getColor, host, ENDEAVOR_TRACKER_COLOR_KIND)
        if ok and r and g and b and a then
            return r, g, b, a
        end
    end

    return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
end

local function applyLabelFont(label, font, fallback)
    if not (label and label.SetFont) then
        return
    end

    local resolved = font
    if resolved == nil or resolved == "" then
        resolved = fallback
    end

    if resolved and resolved ~= "" then
        label:SetFont(resolved)
    end
end

local function applyEntryLabelAnchors(label, control)
    if not (label and label.ClearAnchors and label.SetAnchor and control) then
        return
    end

    local entryLabelIndentX = ENTRY_INDENT_X + ENTRY_ICON_SLOT_PX
    local align = "left"
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host and type(host.GetContentAlignment) == "function" then
        local ok, value = pcall(host.GetContentAlignment, host)
        if ok and type(value) == "string" and value ~= "" then
            align = string.lower(value)
        end
    end
    label:ClearAnchors()
    if align == "right" then
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        label:SetAnchor(TOPRIGHT, control, TOPRIGHT, -entryLabelIndentX, 0)
        label:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 0, 0)
    else
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetAnchor(TOPLEFT, control, TOPLEFT, entryLabelIndentX, 0)
        label:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
    end
end

local function extractColorComponents(color)
    if type(color) ~= "table" then
        return nil
    end

    local r = tonumber(color.r or color[1])
    local g = tonumber(color.g or color[2])
    local b = tonumber(color.b or color[3])
    local a = tonumber(color.a or color[4] or 1)

    if r == nil or g == nil or b == nil then
        return nil
    end

    if r < 0 then
        r = 0
    elseif r > 1 then
        r = 1
    end

    if g < 0 then
        g = 0
    elseif g > 1 then
        g = 1
    end

    if b < 0 then
        b = 0
    elseif b > 1 then
        b = 1
    end

    if a < 0 then
        a = 0
    elseif a > 1 then
        a = 1
    end

    return r, g, b, a
end

local function applyLabelColor(label, role, overrideColors)
    if not label or not label.SetColor then
        return
    end

    local r, g, b, a

    if type(overrideColors) == "table" then
        r, g, b, a = extractColorComponents(overrideColors[role])
    end

    if r == nil then
        r, g, b, a = getTrackerColorFromHost(role)
    end

    label:SetColor(r or 1, g or 1, b or 1, a or 1)
end

local function runSafe(fn)
    if type(fn) ~= "function" then
        return
    end

    local addon = getAddon()
    if type(addon) == "table" then
        local safeCall = rawget(addon, "SafeCall")
        if type(safeCall) == "function" then
            safeCall(fn)
            return
        end
    end

    pcall(fn)
end

local function getEndeavorState()
    local addon = getAddon()
    if type(addon) ~= "table" then
        return nil
    end

    local stateModule = rawget(addon, "EndeavorState")
    if type(stateModule) ~= "table" then
        return nil
    end

    return stateModule
end

local function queueTrackerDirty()
    runSafe(function()
        local addon = getAddon()
        if type(addon) ~= "table" then
            return
        end

        local runtime = rawget(addon, "TrackerRuntime")
        if type(runtime) ~= "table" then
            return
        end

        local queueDirty = runtime.QueueDirty or runtime.MarkDirty or runtime.RequestRefresh
        if type(queueDirty) == "function" then
            queueDirty(runtime, "endeavor")
        end
    end)
end

local function toggleRootExpanded()
    local stateModule = getEndeavorState()
    if type(stateModule) ~= "table" then
        return
    end

    local expanded = false
    local ok, value = CallIfFunction(stateModule.IsExpanded, stateModule)
    if ok and value == true then
        expanded = true
    end

    local okSet = CallIfFunction(stateModule.SetExpanded, stateModule, not expanded)
    if okSet then
        queueTrackerDirty()
        scheduleToggleFollowup("endeavorRootToggle")
    end
end

local function toggleCategoryExpanded(key)
    if key == nil then
        return
    end

    local stateModule = getEndeavorState()
    if type(stateModule) ~= "table" then
        return
    end

    local expanded = false
    local ok, value = CallIfFunction(stateModule.IsCategoryExpanded, stateModule, key)
    if ok and value == true then
        expanded = true
    end

    local okSet = CallIfFunction(stateModule.SetCategoryExpanded, stateModule, key, not expanded)
    if okSet then
        queueTrackerDirty()
        scheduleToggleFollowup("endeavorCategoryToggle")
    end
end

local function openTimedActivities(kind)
    local showTimedActivities = rawget(_G, "ZO_ShowTimedActivities") or ZO_ShowTimedActivities
    if type(showTimedActivities) ~= "function" then
        return
    end

    showTimedActivities()

    local isGamepadPreferred = false
    local getGamepadPreferredMode = rawget(_G, "IsInGamepadPreferredMode") or IsInGamepadPreferredMode
    if type(getGamepadPreferredMode) == "function" then
        local ok, preferred = pcall(getGamepadPreferredMode)
        if ok and preferred == true then
            isGamepadPreferred = true
        end
    end

    if isGamepadPreferred then
        return
    end

    local timedActivitiesKeyboard = rawget(_G, "TIMED_ACTIVITIES_KEYBOARD") or TIMED_ACTIVITIES_KEYBOARD
    if type(timedActivitiesKeyboard) ~= "table" then
        return
    end

    local setCurrentActivityType = timedActivitiesKeyboard.SetCurrentActivityType
    if type(setCurrentActivityType) ~= "function" then
        return
    end

    local activityType = nil
    if kind == "daily" then
        activityType = rawget(_G, "TIMED_ACTIVITY_TYPE_DAILY") or TIMED_ACTIVITY_TYPE_DAILY
    elseif kind == "weekly" then
        activityType = rawget(_G, "TIMED_ACTIVITY_TYPE_WEEKLY") or TIMED_ACTIVITY_TYPE_WEEKLY
    end

    if activityType ~= nil then
        setCurrentActivityType(timedActivitiesKeyboard, activityType)
    end
end

local function getFrameTime()
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

local function ensureEndeavorInitialized()
    runSafe(function()
        local addon = getAddon()
        if type(addon) ~= "table" then
            return
        end

        local sv = rawget(addon, "sv")
        if type(sv) ~= "table" then
            return
        end

        local stateModule = rawget(addon, "EndeavorState")
        if type(stateModule) == "table" then
            if type(stateModule._sv) ~= "table" and type(stateModule.Init) == "function" then
                stateModule:Init(sv)
            end

            if not shimStateInitialized and type(stateModule._sv) == "table" then
                shimStateInitialized = true
                safeDebug("[EndeavorTracker.SHIM] init state")
            end
        end

        local modelModule = rawget(addon, "EndeavorModel")
        if type(modelModule) == "table" then
            if type(modelModule.state) ~= "table" and type(modelModule.Init) == "function" then
                local stateInstance = rawget(addon, "EndeavorState")
                if type(stateInstance) == "table" then
                    modelModule:Init(stateInstance)
                end
            end

            if not shimModelInitialized and type(modelModule.state) == "table" then
                shimModelInitialized = true
                safeDebug("[EndeavorTracker.SHIM] init model")
            end
        end
    end)
end

local function shimRefreshEndeavors()
    runSafe(function()
        ensureEndeavorInitialized()

        local addon = getAddon()
        if type(addon) ~= "table" then
            return
        end

        local model = rawget(addon, "EndeavorModel")
        local countsDaily = 0
        local countsWeekly = 0
        local countsSeals = 0
        if type(model) == "table" then
            local refresh = model.RefreshFromGame or model.Refresh
            if type(refresh) == "function" then
                refresh(model)
                safeDebug("[EndeavorTracker.SHIM] model refreshed")

                local getCounts = model.GetCountsForDebug
                if type(getCounts) == "function" then
                    local ok, counts = pcall(getCounts, model)
                    if ok and type(counts) == "table" then
                        countsDaily = tonumber(counts.dailyTotal) or countsDaily
                        countsWeekly = tonumber(counts.weeklyTotal) or countsWeekly
                        countsSeals = tonumber(counts.seals) or countsSeals
                    end
                end
            end
        end

        local controller = rawget(addon, "EndeavorTrackerController")
        if type(controller) == "table" then
            local markDirty = controller.MarkDirty or controller.RequestRefresh
            if type(markDirty) == "function" then
                markDirty(controller)
            end
        end

        safeDebug("[EndeavorTracker.SHIM] counts: daily=%d weekly=%d seals=%d", countsDaily, countsWeekly, countsSeals)

        local runtime = rawget(addon, "TrackerRuntime")
        if type(runtime) == "table" then
            local queueDirty = runtime.QueueDirty or runtime.MarkDirty or runtime.RequestRefresh
            if type(queueDirty) == "function" then
                queueDirty(runtime, "endeavor")
            end
        end

        safeDebug("[EndeavorTracker.SHIM] refresh → model+dirty+queue")
    end)
end

local function clearTempEventsTimer()
    if tempEvents.timerHandle ~= nil then
        RemoveScheduled(tempEvents.timerHandle)
        tempEvents.timerHandle = nil
    end
    tempEvents.pending = false
end

local function cancelProgressFallbackTimer()
    if progressFallback.timerHandle == nil then
        return
    end

    RemoveScheduled(progressFallback.timerHandle)
    progressFallback.timerHandle = nil
end

local function queueTempEventRefresh()
    local now = getFrameTime()
    local lastQueued = tempEvents.lastQueuedAt or 0
    local elapsed = now - lastQueued
    if elapsed < 0 then
        elapsed = 0
    end

    if elapsed >= tempEvents.debounceMs then
        tempEvents.lastQueuedAt = now
        shimRefreshEndeavors()
        return
    end

    if tempEvents.pending then
        return
    end

    tempEvents.pending = true

    local delay = tempEvents.debounceMs - elapsed
    if delay < 0 then
        delay = 0
    end

    tempEvents.timerHandle = ScheduleLater(delay, function()
        tempEvents.timerHandle = nil
        tempEvents.pending = false
        tempEvents.lastQueuedAt = getFrameTime()
        shimRefreshEndeavors()
    end)

    if tempEvents.timerHandle == nil then
        tempEvents.pending = false
        tempEvents.lastQueuedAt = now
        shimRefreshEndeavors()
        return
    end

    safeDebug("[EndeavorTracker.TempEvents] refresh queued (debounced)")
end

local function queueTempEventRefreshSafe()
    runSafe(function()
        if type(queueTempEventRefresh) == "function" then
            queueTempEventRefresh()
            return
        end

        shimRefreshEndeavors()
    end)
end

function EndeavorTracker:TempEvents_QueueRefresh()
    queueTempEventRefreshSafe()
end

local function hasRecentDebouncedRefresh()
    local lastQueued = tempEvents.lastQueuedAt or 0
    if lastQueued <= 0 then
        return false
    end

    local now = getFrameTime()
    local elapsed = now - lastQueued
    if elapsed < 0 then
        elapsed = 0
    end

    return elapsed < tempEvents.debounceMs or tempEvents.pending
end

local function scheduleProgressFallback()
    if progressFallback.timerHandle ~= nil then
        return
    end

    runSafe(function()
        local delay = progressFallback.delayMs or 0
        progressFallback.timerHandle = ScheduleLater(delay, function()
            progressFallback.timerHandle = nil
            if state.isDisposed then
                return
            end

            local now = getFrameTime()
            local last = progressFallback.lastProgressAtMs or 0
            local elapsed = now - last
            if elapsed < 0 then
                elapsed = 0
            end

            if elapsed >= (progressFallback.delayMs or 0) then
                queueTempEventRefreshSafe()
            end
        end)

        if progressFallback.timerHandle ~= nil then
            safeDebug("[EndeavorTracker.TempEvents] fallback scheduled (no progress yet)")
        else
            queueTempEventRefreshSafe()
        end
    end)
end

local function onTimedActivitiesUpdated()
    scheduleProgressFallback()
end

local function onTimedActivitySystemStatusUpdated()
    scheduleProgressFallback()
end

local function onTimedActivityProgressUpdated()
    progressFallback.lastProgressAtMs = getFrameTime()
    safeDebug("[EndeavorTracker.TempEvents] progress → queue (debounced)")
    queueTempEventRefreshSafe()
end

local function cancelInitKickTimer(silent)
    if initKick.timerHandle == nil then
        return
    end

    RemoveScheduled(initKick.timerHandle)
    initKick.timerHandle = nil

    if not silent then
        safeDebug("[EndeavorTracker.SHIM] init-kick canceled")
    end
end

local function scheduleInitKick()
    if initKick.done then
        return
    end

    if state.isDisposed then
        return
    end

    if initKick.timerHandle ~= nil then
        return
    end

    runSafe(function()
        safeDebug("[EndeavorTracker.SHIM] init-kick scheduled")

        initKick.timerHandle = ScheduleLater(initKick.delayMs, function()
            initKick.timerHandle = nil
            if state.isDisposed then
                initKick.done = true
                return
            end

            initKick.done = true
            if not hasRecentDebouncedRefresh() then
                queueTempEventRefreshSafe()
            end
        end)

        if initKick.timerHandle == nil then
            initKick.done = true
            if not hasRecentDebouncedRefresh() then
                queueTempEventRefreshSafe()
            end
        end
    end)
end

local function tempEventsRegister()
    if tempEvents.registered then
        return
    end

    runSafe(function()
        local eventManager = rawget(_G, "EVENT_MANAGER")
        local eventManagerType = type(eventManager)
        if eventManagerType ~= "table" and eventManagerType ~= "userdata" then
            return
        end

        local registerMethod = eventManager.RegisterForEvent
        if type(registerMethod) ~= "function" then
            return
        end

        local registeredCount = 0

        if EVENT_TIMED_ACTIVITIES_UPDATED_ID then
            registerMethod(eventManager, TEMP_EVENT_NAMESPACE, EVENT_TIMED_ACTIVITIES_UPDATED_ID, onTimedActivitiesUpdated)
            registeredCount = registeredCount + 1
        end

        if EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED_ID then
            registerMethod(eventManager, TEMP_EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED_ID, onTimedActivityProgressUpdated)
            registeredCount = registeredCount + 1
        end

        if EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED_ID then
            registerMethod(eventManager, TEMP_EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED_ID, onTimedActivitySystemStatusUpdated)
            registeredCount = registeredCount + 1
        end

        if registeredCount > 0 then
            tempEvents.registered = true
            safeDebug("[EndeavorTracker.TempEvents] register")
        end
    end)
end

local function warnCentralEventsIfNeeded()
    if centralEventsWarningShown then
        return
    end

    runSafe(function()
        if centralEventsWarningShown then
            return
        end

        local addon = getAddon()
        if type(addon) ~= "table" then
            return
        end

        if not addon.debug then
            return
        end

        local eventsHub = rawget(addon, "Events")
        if type(eventsHub) ~= "table" then
            return
        end

        local hasHandlers = rawget(eventsHub, "HasEndeavorHandlers")
        local active = false

        if type(hasHandlers) == "function" then
            local ok, result = pcall(hasHandlers, eventsHub)
            active = ok and result == true
        elseif type(hasHandlers) == "boolean" then
            active = hasHandlers
        end

        if active then
            centralEventsWarningShown = true
            safeDebug("[EndeavorTracker.TempEvents] central events detected → temp events should be disabled after SWITCH")
        end
    end)
end

local function unregisterTempEventsInternal(options)
    local opts = options or {}
    local silentKick = opts.silentInitKick == true

    cancelInitKickTimer(silentKick)
    initKick.done = true

    cancelProgressFallbackTimer()
    progressFallback.lastProgressAtMs = nil

    stopInitPoller(EndeavorTracker)

    clearTempEventsTimer()
    tempEvents.pending = false
    tempEvents.lastQueuedAt = 0

    if not tempEvents.registered then
        return
    end

    runSafe(function()
        local eventManager = rawget(_G, "EVENT_MANAGER")
        local eventManagerType = type(eventManager)
        if eventManagerType ~= "table" and eventManagerType ~= "userdata" then
            tempEvents.registered = false
            safeDebug("[EndeavorTracker.TempEvents] unregister")
            return
        end

        local unregisterMethod = eventManager.UnregisterForEvent
        if type(unregisterMethod) == "function" then
            if EVENT_TIMED_ACTIVITIES_UPDATED_ID then
                unregisterMethod(eventManager, TEMP_EVENT_NAMESPACE, EVENT_TIMED_ACTIVITIES_UPDATED_ID)
            end
            if EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED_ID then
                unregisterMethod(eventManager, TEMP_EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED_ID)
            end
            if EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED_ID then
                unregisterMethod(eventManager, TEMP_EVENT_NAMESPACE, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED_ID)
            end
        end

        tempEvents.registered = false
        safeDebug("[EndeavorTracker.TempEvents] unregister")
    end)
end

function EndeavorTracker:TempEvents_UnregisterAll(options)
    unregisterTempEventsInternal(options)
end

--[[ EBOOT_TEMP_EVENTS_END: Endeavor ]]

safeDebug = function(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local root = rawget(_G, addonName)
    if type(root) ~= "table" then
        return
    end

    local diagnostics = root.Diagnostics
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled("EndeavorTracker", fmt, ...)
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

local function storeHeaderBaseColor(label)
    if type(label) ~= "userdata" then
        return
    end

    local base = label._nvk3HeaderBaseColor
    if type(base) ~= "table" then
        base = {}
        label._nvk3HeaderBaseColor = base
    end

    local source = label._baseColor
    if type(source) == "table" then
        base[1], base[2], base[3], base[4] = source[1] or 1, source[2] or 1, source[3] or 1, source[4] or 1
        return
    end

    if label.GetColor then
        local r, g, b, a = label:GetColor()
        base[1], base[2], base[3], base[4] = r or 1, g or 1, b or 1, a or 1
        return
    end

    base[1], base[2], base[3], base[4] = 1, 1, 1, 1
end

local function applyHeaderMouseover(control, label)
    if not (control and label and label.SetColor) then
        return
    end

    storeHeaderBaseColor(label)

    local r, g, b, a = getMouseoverHighlightColor()
    label:SetColor(r, g, b, a)

    safeDebug(
        "Endeavor header hover: applying mouseover highlight color r=%.3f g=%.3f b=%.3f a=%.3f",
        r or 0,
        g or 0,
        b or 0,
        a or 0
    )
end

local function restoreHeaderMouseover(control, label)
    if not (control and label and label.SetColor) then
        return
    end

    local base = label._nvk3HeaderBaseColor or label._baseColor
    if type(base) ~= "table" then
        return
    end

    label:SetColor(base[1] or 1, base[2] or 1, base[3] or 1, base[4] or 1)

    safeDebug(
        "Endeavor header hover: restored base color r=%.3f g=%.3f b=%.3f a=%.3f",
        base[1] or 0,
        base[2] or 0,
        base[3] or 0,
        base[4] or 0
    )
end

local function measureControlHeight(control, fallback)
    if control and control.GetHeight then
        local ok, height = pcall(control.GetHeight, control)
        if ok then
            local measured = coerceHeight(height)
            if measured > 0 then
                return measured
            end
        end
    end

    return coerceHeight(fallback)
end

local function anchorControlAtOffset(control, container, offsetY, indentX)
    if not (control and container) then
        return
    end

    indentX = tonumber(indentX) or 0
    if indentX < 0 then
        indentX = 0
    end

    if control.ClearAnchors then
        control:ClearAnchors()
    end

    if control.SetAnchor then
        control:SetAnchor(TOPLEFT, container, TOPLEFT, indentX, offsetY)
        control:SetAnchor(TOPRIGHT, container, TOPRIGHT, 0, offsetY)
    end
end

local function resetObjectiveContainer(rows, container)
    if container == nil then
        return
    end

    container._objectiveRows = {}

    if rows and type(rows.ResetEntryPool) == "function" then
        local ok, err = pcall(rows.ResetEntryPool, container)
        if not ok then
            safeDebug("[EndeavorTracker.UI] resetObjectiveContainer reset pool failed: %s", tostring(err))
        end
    end

    if container.SetHidden then
        container:SetHidden(true)
    end

    if container.SetHeight then
        container:SetHeight(0)
    end

    if container.ClearAnchors then
        container:ClearAnchors()
    end
end

local function buildObjectiveRows(rows, container, objectivesList, rowsOptions)
    if container == nil then
        return 0
    end

    local module = rows or getRowsModule()

    if module and type(module.ResetEntryPool) == "function" then
        local ok, err = pcall(module.ResetEntryPool, container)
        if not ok then
            safeDebug("[EndeavorTracker.UI] buildObjectiveRows pool reset failed: %s", tostring(err))
        end
    end

    if container.SetResizeToFitDescendents then
        container:SetResizeToFitDescendents(false)
    end

    local objectives = type(objectivesList) == "table" and objectivesList or {}
    local usedRows = {}
    container._objectiveRows = usedRows

    local cursorY = 0
    local visibleObjectives = 0
    local spacingAbove = normalizeSpacingValue(rowsOptions and rowsOptions.objectiveSpacingAbove, OBJECTIVE_SPACING_ABOVE_DEFAULT)
    local spacingBetween = normalizeSpacingValue(rowsOptions and rowsOptions.objectiveSpacingBetween, OBJECTIVE_SPACING_BETWEEN_DEFAULT)
    local spacingBelow = normalizeSpacingValue(rowsOptions and rowsOptions.objectiveSpacingBelow, OBJECTIVE_SPACING_BELOW_DEFAULT)

    for index = 1, #objectives do
        local objective = objectives[index]
        if type(objective) == "table" and objective.hidden ~= true then
            local row = module and type(module.AcquireEntryRow) == "function" and module.AcquireEntryRow(container) or nil
            if row then
                usedRows[#usedRows + 1] = row

                if module and type(module.ApplyEntryRow) == "function" then
                    module.ApplyEntryRow(row, objective, rowsOptions)
                end

                if visibleObjectives == 0 then
                    if spacingAbove > 0 then
                        cursorY = cursorY + spacingAbove
                    end
                elseif spacingBetween > 0 then
                    cursorY = cursorY + spacingBetween
                end

                anchorControlAtOffset(row, container, cursorY)
                if row.SetHidden then
                    row:SetHidden(false)
                end

                local entryHeight = 0
                if module and type(module.GetEntryRowHeight) == "function" then
                    entryHeight = coerceHeight(module.GetEntryRowHeight())
                end
                if entryHeight <= 0 then
                    entryHeight = measureControlHeight(row, entryHeight)
                end

                cursorY = cursorY + entryHeight
                visibleObjectives = visibleObjectives + 1

                local sanitizedSubrows = type(row._subrows) == "table" and row._subrows or {}
                local baseAfterEntry = cursorY
                local blockHeight = 0
                if module and type(module.GetSubrowsBlockHeight) == "function" then
                    blockHeight = coerceHeight(module.GetSubrowsBlockHeight(sanitizedSubrows))
                end

                local subCursor = baseAfterEntry
                local visibleSubrows = 0

                for _, subEntry in ipairs(sanitizedSubrows) do
                    local control = subEntry.control
                    if control then
                        local visible = subEntry.visible ~= false and subEntry.hidden ~= true
                        if visible then
                            visibleSubrows = visibleSubrows + 1
                            local spacing = (visibleSubrows == 1) and SUBROW_FIRST_SPACING or SUBROW_BETWEEN_SPACING
                            subCursor = subCursor + spacing
                            anchorControlAtOffset(control, container, subCursor)
                            if control.SetHidden then
                                control:SetHidden(false)
                            end

                            local subHeight = 0
                            if module and type(module.GetSubrowHeight) == "function" then
                                subHeight = coerceHeight(module.GetSubrowHeight(subEntry.kind))
                            end
                            if subHeight <= 0 then
                                subHeight = measureControlHeight(control, subHeight)
                            end

                            subCursor = subCursor + subHeight
                        else
                            if control.SetHidden then
                                control:SetHidden(true)
                            end
                            if control.ClearAnchors then
                                control:ClearAnchors()
                            end
                        end
                    end
                end

                if blockHeight > 0 then
                    cursorY = baseAfterEntry + blockHeight
                else
                    if visibleSubrows > 0 then
                        subCursor = subCursor + SUBROW_TRAILING_SPACING
                    end
                    cursorY = subCursor
                end
            end
        end
    end

    if visibleObjectives > 0 and spacingBelow > 0 then
        cursorY = cursorY + spacingBelow
    end

    local totalHeight = coerceHeight(cursorY)

    if totalHeight <= 0 or visibleObjectives == 0 then
        if module and type(module.ResetEntryPool) == "function" then
            module.ResetEntryPool(container)
        end
        usedRows = {}
        container._objectiveRows = usedRows
        totalHeight = 0
        if container.SetHidden then
            container:SetHidden(true)
        end
        if container.SetHeight then
            container:SetHeight(0)
        end
        if container.ClearAnchors then
            container:ClearAnchors()
        end
        safeDebug("[EndeavorTracker.UI] objective container empty")
        return totalHeight
    end

    if container.SetHidden then
        container:SetHidden(false)
    end

    if container.SetHeight then
        container:SetHeight(totalHeight)
    end

    safeDebug(
        "[EndeavorTracker.UI] objective container rows=%d subHeight=%d",
        visibleObjectives,
        totalHeight
    )

    return totalHeight
end

local function newLayoutContext(container)
    local context = {
        container = container,
        cursorY = 0,
        height = 0,
        visibleCount = 0,
        rowCount = 0,
        previousKind = nil,
        pendingEntryGap = nil,
    }

    if container and container.SetResizeToFitDescendents then
        container:SetResizeToFitDescendents(false)
    end

    return context
end

local function appendLayoutControl(context, control, fallbackHeight, kind)
    if context == nil or control == nil then
        return
    end

    local container = context.container
    if container == nil then
        return
    end

    local measuredHeight = measureControlHeight(control, fallbackHeight)
    if measuredHeight <= 0 then
        if control.SetHidden then
            control:SetHidden(true)
        end
        if control.ClearAnchors then
            control:ClearAnchors()
        end
        return
    end

    local offsetY = context.cursorY
    local gap = 0
    local resolvedKind = kind or "row"
    local pendingEntryGap = context.pendingEntryGap
    local isObjectivesAfterEntry = context.previousKind == "entry" and resolvedKind == "objectives"

    if pendingEntryGap ~= nil and pendingEntryGap > 0 and not isObjectivesAfterEntry then
        gap = pendingEntryGap
        context.pendingEntryGap = nil
    else
        if context.visibleCount > 0 then
            if isObjectivesAfterEntry then
                gap = 0
            elseif resolvedKind == "entry" then
                gap = ENTRY_SPACING_ABOVE
            elseif resolvedKind == "header" then
                gap = CATEGORY_SPACING_ABOVE
            elseif context.previousKind == "header" then
                gap = HEADER_TO_ROWS_GAP
            else
                gap = ROW_GAP
            end
        elseif resolvedKind == "header" then
            gap = CATEGORY_SPACING_ABOVE
        elseif resolvedKind == "entry" then
            gap = ENTRY_SPACING_ABOVE
        end
    end

    if gap > 0 then
        offsetY = offsetY + gap
        context.height = context.height + gap
    end

    anchorControlAtOffset(control, container, offsetY, 0)
    if control.SetHidden then
        control:SetHidden(false)
    end

    context.cursorY = offsetY + measuredHeight
    context.height = context.cursorY
    context.visibleCount = context.visibleCount + 1

    if resolvedKind ~= "header" then
        context.rowCount = context.rowCount + 1
    end
    context.previousKind = resolvedKind
    if resolvedKind == "entry" then
        if ENTRY_SPACING_BELOW > 0 then
            context.pendingEntryGap = ENTRY_SPACING_BELOW
        else
            context.pendingEntryGap = nil
        end
    end
end

local function N3UT_Endeavor_InitPoller_Tick()
    local tracker = Nvk3UT and Nvk3UT.EndeavorTrackerInstance
    if not tracker or tracker._disposed or not tracker._initPollerActive then
        if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
            EVENT_MANAGER:UnregisterForUpdate(INIT_POLLER_UPDATE_NAME)
        end
        if tracker and Nvk3UT and Nvk3UT.EndeavorTrackerInstance == tracker then
            Nvk3UT.EndeavorTrackerInstance = nil
        end
        return
    end

    safeDebug("[EndeavorTracker.SHIM] poller tick")

    tracker._initPollerTries = (tonumber(tracker._initPollerTries) or 0) + 1

    local count = 0
    if type(GetNumTimedActivities) == "function" then
        local value = GetNumTimedActivities()
        if type(value) == "number" then
            count = value
        end
    end

    if count > 0 then
        safeDebug("[EndeavorTracker.SHIM] init-poller success: count=%d", count)

        if type(tracker.TempEvents_QueueRefresh) == "function" then
            tracker:TempEvents_QueueRefresh()
        else
            CallIfFunction(Nvk3UT and Nvk3UT.EndeavorModel and Nvk3UT.EndeavorModel.RefreshFromGame, Nvk3UT.EndeavorModel)
            CallIfFunction(Nvk3UT and Nvk3UT.EndeavorTrackerController and Nvk3UT.EndeavorTrackerController.MarkDirty, Nvk3UT.EndeavorTrackerController)
            CallIfFunction(Nvk3UT and Nvk3UT.TrackerRuntime and Nvk3UT.TrackerRuntime.QueueDirty, Nvk3UT.TrackerRuntime, "endeavor")
        end

        tracker._initPollerActive = false
        if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
            EVENT_MANAGER:UnregisterForUpdate(INIT_POLLER_UPDATE_NAME)
        end
        if Nvk3UT and Nvk3UT.EndeavorTrackerInstance == tracker then
            Nvk3UT.EndeavorTrackerInstance = nil
        end
        return
    end

    local maxTries = tonumber(tracker._initPollerMaxTries) or 10
    if tracker._initPollerTries >= maxTries then
        tracker._initPollerActive = false
        safeDebug("[EndeavorTracker.SHIM] init-poller gave up (count=0)")
        if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
            EVENT_MANAGER:UnregisterForUpdate(INIT_POLLER_UPDATE_NAME)
        end
        if Nvk3UT and Nvk3UT.EndeavorTrackerInstance == tracker then
            Nvk3UT.EndeavorTrackerInstance = nil
        end
        return
    end
end

local function startInitPoller(tracker)
    if not tracker or tracker._disposed or tracker._initPollerActive then
        return
    end

    tracker._initPollerActive = true
    tracker._initPollerTries = 0
    tracker._initPollerMaxTries = tonumber(tracker._initPollerMaxTries) or 10
    tracker._initPollerInterval = tonumber(tracker._initPollerInterval) or 1000

    if Nvk3UT then
        Nvk3UT.EndeavorTrackerInstance = tracker
    end

    if EVENT_MANAGER and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        if type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
            EVENT_MANAGER:UnregisterForUpdate(INIT_POLLER_UPDATE_NAME)
        end
        EVENT_MANAGER:RegisterForUpdate(INIT_POLLER_UPDATE_NAME, tracker._initPollerInterval, N3UT_Endeavor_InitPoller_Tick)
        safeDebug("[EndeavorTracker.SHIM] init-poller scheduled")
    else
        tracker._initPollerActive = false
        if Nvk3UT and Nvk3UT.EndeavorTrackerInstance == tracker then
            Nvk3UT.EndeavorTrackerInstance = nil
        end
    end
end

local function stopInitPoller(tracker)
    if not tracker then
        return
    end

    tracker._initPollerActive = false
    tracker._initPollerTries = 0

    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(INIT_POLLER_UPDATE_NAME)
    end

    if Nvk3UT and Nvk3UT.EndeavorTrackerInstance == tracker then
        Nvk3UT.EndeavorTrackerInstance = nil
    end
end

local function getRowsModule()
    local root = rawget(_G, addonName)
    if type(root) ~= "table" then
        return nil
    end

    local rows = rawget(root, "EndeavorTrackerRows")
    if type(rows) ~= "table" then
        return nil
    end

    return rows
end

local function ensureUi(container)
    if container == nil then
        return state.ui
    end

    local wm = WINDOW_MANAGER
    if wm == nil then
        return state.ui
    end

    local ui = state.ui
    if type(ui) ~= "table" then
        ui = {}
        state.ui = ui
    end

    local containerName
    if type(container.GetName) == "function" then
        local ok, name = pcall(container.GetName, container)
        if ok and type(name) == "string" then
            containerName = name
        end
    end

    local baseName = (containerName or "Nvk3UT_Endeavor") .. "_"
    ui.baseName = baseName

    local daily = ui.daily
    if type(daily) ~= "table" then
        local controlName = baseName .. "Daily"
        local control = GetControl(controlName)
        if not control then
            control = wm:CreateControl(controlName, container, CT_CONTROL)
        else
            control:SetParent(container)
        end
        control:SetResizeToFitDescendents(false)
        control:SetHeight(SECTION_ROW_HEIGHT)
        control:SetMouseEnabled(true)
        control:SetHidden(false)
        control:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside ~= true then
                return
            end

            if button == MOUSE_BUTTON_INDEX_LEFT then
                toggleCategoryExpanded("daily")
                return
            end

            if button == MOUSE_BUTTON_INDEX_RIGHT then
                if not (ClearMenu and AddCustomMenuItem and ShowMenu) then
                    return
                end

                ClearMenu()
                local optionType = (_G and _G.MENU_ADD_OPTION_LABEL) or MENU_ADD_OPTION_LABEL or 1
                AddCustomMenuItem(
                    GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CONTEXT_OPEN_DAILY),
                    function()
                        openTimedActivities("daily")
                        safeDebug("[EndeavorTracker.UI] Context: open daily timed activities base UI")
                    end,
                    optionType
                )
                ShowMenu(control)
            end
        end)

        local labelName = controlName .. "Label"
        local label = GetControl(labelName)
        if not label then
            label = wm:CreateControl(labelName, control, CT_LABEL)
        end
        label:SetParent(control)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        applyEntryLabelAnchors(label, control)
        applyLabelFont(label, DEFAULT_SECTION_FONT, DEFAULT_SECTION_FONT)

        control:SetHandler("OnMouseEnter", function(ctrl)
            applyHeaderMouseover(ctrl, label)
        end)

        control:SetHandler("OnMouseExit", function(ctrl)
            restoreHeaderMouseover(ctrl, label)
        end)

        ui.daily = {
            control = control,
            label = label,
        }
    else
        local control = daily.control
        if control then
            control:SetParent(container)
            control:SetHeight(SECTION_ROW_HEIGHT)
        end
        local label = daily.label
        applyLabelFont(label, DEFAULT_SECTION_FONT, DEFAULT_SECTION_FONT)
    end

    local weekly = ui.weekly
    if type(weekly) ~= "table" then
        local controlName = baseName .. "Weekly"
        local control = GetControl(controlName)
        if not control then
            control = wm:CreateControl(controlName, container, CT_CONTROL)
        else
            control:SetParent(container)
        end
        control:SetResizeToFitDescendents(false)
        control:SetHeight(SECTION_ROW_HEIGHT)
        control:SetMouseEnabled(true)
        control:SetHidden(false)
        control:SetHandler("OnMouseUp", function(_, button, upInside)
            if upInside ~= true then
                return
            end

            if button == MOUSE_BUTTON_INDEX_LEFT then
                toggleCategoryExpanded("weekly")
                return
            end

            if button == MOUSE_BUTTON_INDEX_RIGHT then
                if not (ClearMenu and AddCustomMenuItem and ShowMenu) then
                    return
                end

                ClearMenu()
                local optionType = (_G and _G.MENU_ADD_OPTION_LABEL) or MENU_ADD_OPTION_LABEL or 1
                AddCustomMenuItem(
                    GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CONTEXT_OPEN_WEEKLY),
                    function()
                        openTimedActivities("weekly")
                        safeDebug("[EndeavorTracker.UI] Context: open weekly timed activities base UI")
                    end,
                    optionType
                )
                ShowMenu(control)
            end
        end)

        local labelName = controlName .. "Label"
        local label = GetControl(labelName)
        if not label then
            label = wm:CreateControl(labelName, control, CT_LABEL)
        end
        label:SetParent(control)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        applyEntryLabelAnchors(label, control)
        applyLabelFont(label, DEFAULT_SECTION_FONT, DEFAULT_SECTION_FONT)

        control:SetHandler("OnMouseEnter", function(ctrl)
            applyHeaderMouseover(ctrl, label)
        end)

        control:SetHandler("OnMouseExit", function(ctrl)
            restoreHeaderMouseover(ctrl, label)
        end)

        ui.weekly = {
            control = control,
            label = label,
        }
    else
        local control = weekly.control
        if control then
            control:SetParent(container)
            control:SetHeight(SECTION_ROW_HEIGHT)
        end
        local label = weekly.label
        applyLabelFont(label, DEFAULT_SECTION_FONT, DEFAULT_SECTION_FONT)
    end

    local dailyObjectives = ui.dailyObjectives
    if type(dailyObjectives) ~= "table" then
        local controlName = baseName .. "DailyObjectives"
        local control = GetControl(controlName)
        if not control then
            control = wm:CreateControl(controlName, container, CT_CONTROL)
        else
            control:SetParent(container)
        end
        control:SetResizeToFitDescendents(false)
        control:SetMouseEnabled(false)
        control:SetHidden(true)
        control:SetHeight(0)

        ui.dailyObjectives = {
            control = control,
        }
    else
        local control = dailyObjectives.control
        if control then
            control:SetParent(container)
        end
    end

    local weeklyObjectives = ui.weeklyObjectives
    if type(weeklyObjectives) ~= "table" then
        local controlName = baseName .. "WeeklyObjectives"
        local control = GetControl(controlName)
        if not control then
            control = wm:CreateControl(controlName, container, CT_CONTROL)
        else
            control:SetParent(container)
        end
        control:SetResizeToFitDescendents(false)
        control:SetMouseEnabled(false)
        control:SetHidden(true)
        control:SetHeight(0)

        ui.weeklyObjectives = {
            control = control,
        }
    else
        local control = weeklyObjectives.control
        if control then
            control:SetParent(container)
        end
    end

    return ui
end

function EndeavorTracker.Init(sectionContainer)
    state.container = sectionContainer
    state.currentHeight = 0
    state.isInitialized = true
    state.isDisposed = false
    EndeavorTracker._disposed = false
    state.ui = nil

    ensureEndeavorInitialized()

    initKick.done = false
    if initKick.timerHandle ~= nil then
        cancelInitKickTimer(true)
    end

    cancelProgressFallbackTimer()
    progressFallback.lastProgressAtMs = nil

    local rows = getRowsModule()
    if rows and type(rows.Init) == "function" then
        pcall(rows.Init)
    end

    local container = state.container
    if container and container.SetHeight then
        container:SetHeight(0)
    end

    if not EBOOT_TEMP_EVENTS_ENABLED then
        EndeavorTracker:TempEvents_UnregisterAll({ silentInitKick = true })
        return
    end

    tempEventsRegister()
    warnCentralEventsIfNeeded()

    local disableViaSwitch = false

    runSafe(function()
        local addon = getAddon()
        if type(addon) ~= "table" then
            return
        end

        local flags = rawget(addon, "Flags")
        if type(flags) ~= "table" then
            return
        end

        if flags.EEVENTS_SWITCH_ENDEAVOR == true then
            disableViaSwitch = true
        end
    end)

    if disableViaSwitch then
        EndeavorTracker:TempEvents_UnregisterAll({ silentInitKick = true })
        return
    end

    scheduleInitKick()

    if EBOOT_TEMP_EVENTS_ENABLED and not state.isDisposed then
        startInitPoller(EndeavorTracker)
    end

    local containerName
    if container and container.GetName then
        local ok, name = pcall(container.GetName, container)
        if ok then
            containerName = name
        end
    end

    safeDebug("EndeavorTracker.Init: container=%s", containerName or "nil")
end


function EndeavorTracker.Refresh(viewModel)
    if not state.isInitialized then
        return
    end

    applyCategorySpacingFromSaved()
    do
        local sv = Nvk3UT and Nvk3UT.SV
        local spacing = sv and sv.spacing
        local endeavorSpacing = spacing and spacing.endeavor
        local categorySpacing = endeavorSpacing and endeavorSpacing.category
        local spacingIndent = categorySpacing and categorySpacing.indent
        safeDebug(
            "[EndeavorTracker.UI] categoryIndent SV=%s CATEGORY_INDENT_X=%s",
            tostring(spacingIndent),
            tostring(CATEGORY_INDENT_X)
        )
    end

    if EndeavorTracker._building then
        safeDebug("[EndeavorTracker.UI] Refresh skipped due to active guard")
        return
    end

    EndeavorTracker._building = true
    local function release()
        EndeavorTracker._building = false
    end

    local function handleError(err)
        local message = tostring(err)
        safeDebug("[EndeavorTracker.UI] Refresh error: %s", message)
        local traceback
        if type(debug) == "table" and type(debug.traceback) == "function" then
            traceback = debug.traceback(message, 2)
            if traceback ~= nil then
                safeDebug("[EndeavorTracker.UI] Refresh traceback: %s", traceback)
            end
        end
        return traceback or message
    end

    local ok, err = xpcall(function()
            local container = state.container
            if container == nil then
                return
            end

            local vm = type(viewModel) == "table" and viewModel or {}
            local categoryVm = type(vm.category) == "table" and vm.category or {}
            local dailyVm = type(vm.daily) == "table" and vm.daily or {}
            local weeklyVm = type(vm.weekly) == "table" and vm.weekly or {}
            local settings = type(vm.settings) == "table" and vm.settings or {}

            local enabled = settings.enabled ~= false
            local showCounts = settings.showCounts ~= false
            local completedHandling = settings.completedHandling == "recolor" and "recolor" or "hide"
            local overrideColors = type(settings.colors) == "table" and settings.colors or nil
            local fontsTable = type(settings.fonts) == "table" and settings.fonts or {}

            local categoryFont = fontsTable.category or DEFAULT_CATEGORY_FONT
            local sectionFont = fontsTable.section or DEFAULT_SECTION_FONT
            local objectiveFont = fontsTable.objective or sectionFont
            local rowHeight = math.max(fontsTable.rowHeight or 20, 20)

            local rowsOptionsTemplate = type(settings.rowsOptions) == "table" and settings.rowsOptions or nil
            local rowsOptions = {}
            if rowsOptionsTemplate then
                for key, value in pairs(rowsOptionsTemplate) do
                    rowsOptions[key] = value
                end
            end
            rowsOptions.colorKind = rowsOptions.colorKind or ENDEAVOR_TRACKER_COLOR_KIND
            rowsOptions.defaultRole = rowsOptions.defaultRole or "objectiveText"
            rowsOptions.completedRole = rowsOptions.completedRole or "completed"
            rowsOptions.entryRole = rowsOptions.entryRole or ENTRY_COLOR_ROLE_DEFAULT
            rowsOptions.font = objectiveFont
            rowsOptions.rowHeight = rowHeight
            rowsOptions.colors = overrideColors
            rowsOptions.completedHandling = completedHandling
            rowsOptions.objectiveIndent = getObjectiveIndentFromSaved()
            rowsOptions.objectiveSpacingAbove = getObjectiveSpacingAboveFromSaved()
            rowsOptions.objectiveSpacingBelow = getObjectiveSpacingBelowFromSaved()
            rowsOptions.objectiveSpacingBetween = getObjectiveSpacingBetweenFromSaved()

            local dailyObjectivesList = type(dailyVm.objectives) == "table" and dailyVm.objectives or {}
            local weeklyObjectivesList = type(weeklyVm.objectives) == "table" and weeklyVm.objectives or {}

            local sectionVm = type(vm.section) == "table" and vm.section or {}
            local dailyHideRow = dailyVm.hideRow == true
            local weeklyHideRow = weeklyVm.hideRow == true
            local dailyHideObjectives = dailyVm.hideObjectives == true
            local weeklyHideObjectives = weeklyVm.hideObjectives == true
            local dailyUseCompletedStyle = dailyVm.useCompletedStyle == true
            local weeklyUseCompletedStyle = weeklyVm.useCompletedStyle == true
            local hideEntireSection = sectionVm.hideEntireSection == true

            if hideEntireSection then
                dailyHideRow = true
                weeklyHideRow = true
                dailyHideObjectives = true
                weeklyHideObjectives = true
            end

            safeDebug("[EndeavorTracker.UI] Refresh: daily=%d weekly=%d", #dailyObjectivesList, #weeklyObjectivesList)

            local ui = ensureUi(container)
            if type(ui) ~= "table" then
                return
            end

            local rows = getRowsModule()
            if rows and type(rows.ResetCategoryPool) == "function" then
                rows.ResetCategoryPool()
            end
            if rows and type(rows.ResetAlignmentLog) == "function" then
                rows.ResetAlignmentLog()
            end

            local previousCategoryRow = type(ui.category) == "table" and ui.category or nil
            local categoryRow = nil
            if rows and type(rows.AcquireCategoryRow) == "function" then
                categoryRow = rows.AcquireCategoryRow(container)
            end

            if not categoryRow then
                categoryRow = previousCategoryRow
            end

            ui.category = categoryRow

            local categoryControl = categoryRow and categoryRow.control
            local categoryLabel = categoryRow and categoryRow.label
            local categoryChevron = categoryRow and categoryRow.chevron
            local dailyControl = ui.daily and ui.daily.control
            local dailyLabel = ui.daily and ui.daily.label
            local weeklyControl = ui.weekly and ui.weekly.control
            local weeklyLabel = ui.weekly and ui.weekly.label
            local dailyObjectivesControl = ui.dailyObjectives and ui.dailyObjectives.control
            local weeklyObjectivesControl = ui.weeklyObjectives and ui.weeklyObjectives.control

            if hideEntireSection then
                resetObjectiveContainer(rows, dailyObjectivesControl)
                resetObjectiveContainer(rows, weeklyObjectivesControl)

                if categoryControl and categoryControl.SetHidden then
                    categoryControl:SetHidden(true)
                end
                if dailyControl and dailyControl.SetHidden then
                    dailyControl:SetHidden(true)
                end
                if weeklyControl and weeklyControl.SetHidden then
                    weeklyControl:SetHidden(true)
                end

                if container.SetHidden then
                    container:SetHidden(true)
                end
                state.currentHeight = 0
                if container.SetHeight then
                    container:SetHeight(0)
                end

                return
            end

            local function resolveTitle(value, fallback)
                if value == nil or value == "" then
                    return fallback
                end
                return tostring(value)
            end

            local function shouldShowCountsFor(entryVm)
                local entry = type(entryVm) == "table" and entryVm or nil
                local kind = entry and entry.kind or nil
                if kind == "dailyHeader" or kind == "weeklyHeader" then
                    return true
                end
                if entry == dailyVm or entry == weeklyVm then
                    return true
                end
                return showCounts
            end

            applyLabelFont(categoryLabel, categoryFont, DEFAULT_CATEGORY_FONT)
            applyLabelFont(dailyLabel, sectionFont, DEFAULT_SECTION_FONT)
            applyLabelFont(weeklyLabel, sectionFont, DEFAULT_SECTION_FONT)
            applyEntryLabelAnchors(dailyLabel, dailyControl)
            applyEntryLabelAnchors(weeklyLabel, weeklyControl)

            local formatCategoryHeader = Utils and Utils.FormatCategoryHeaderText
            local categoryTitle = resolveTitle(categoryVm.title, GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_ROOT))
            local categoryRemaining = tonumber(categoryVm.remaining) or 0
            categoryRemaining = math.max(0, math.floor(categoryRemaining + 0.5))
            local categoryExpanded = categoryVm.expanded == true
            local categoryShowCounts = enabled and shouldShowCountsFor(categoryVm)

            local appliedCategoryRow = false
            if categoryRow and rows and type(rows.ApplyCategoryRow) == "function" then
                safeDebug(
                    "[EndeavorTracker.UI] ApplyCategoryRow categoryIndent=%s",
                    tostring(CATEGORY_INDENT_X)
                )
                rows.ApplyCategoryRow(categoryRow, {
                    title = categoryTitle,
                    remaining = categoryRemaining,
                    showCounts = categoryShowCounts,
                    expanded = categoryExpanded,
                    formatHeader = formatCategoryHeader,
                    overrideColors = overrideColors,
                    textures = CHEVRON_TEXTURES,
                    categoryIndent = CATEGORY_INDENT_X,
                    colorRoles = {
                        expanded = CATEGORY_COLOR_ROLE_EXPANDED,
                        collapsed = CATEGORY_COLOR_ROLE_COLLAPSED,
                    },
                    rowsOptions = rowsOptions,
                    onToggle = toggleRootExpanded,
                })
                appliedCategoryRow = true
            end

            if not appliedCategoryRow then
                if categoryLabel and categoryLabel.SetText then
                    if type(formatCategoryHeader) == "function" then
                        categoryLabel:SetText(formatCategoryHeader(categoryTitle, categoryRemaining, categoryShowCounts))
                    elseif categoryShowCounts then
                        categoryLabel:SetText(string.format("%s (%d)", categoryTitle, categoryRemaining))
                    else
                        categoryLabel:SetText(categoryTitle)
                    end
                end

                if categoryChevron and categoryChevron.SetTexture then
                    local texturePath = categoryExpanded and CHEVRON_TEXTURES.expanded or CHEVRON_TEXTURES.collapsed
                    categoryChevron:SetTexture(texturePath)
                end

                if categoryLabel then
                    local role = categoryExpanded and CATEGORY_COLOR_ROLE_EXPANDED or CATEGORY_COLOR_ROLE_COLLAPSED
                    applyLabelColor(categoryLabel, role, overrideColors)
                end
            end

            if not enabled then
                if dailyLabel and dailyLabel.SetText then
                    local dailyTitle = resolveTitle(
                        dailyVm.title or GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_DAILY),
                        GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_DAILY)
                    )
                    dailyLabel:SetText(dailyTitle)
                end
                if weeklyLabel and weeklyLabel.SetText then
                    local weeklyTitle = resolveTitle(
                        weeklyVm.title or GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_WEEKLY),
                        GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_WEEKLY)
                    )
                    weeklyLabel:SetText(weeklyTitle)
                end

                resetObjectiveContainer(rows, dailyObjectivesControl)
                resetObjectiveContainer(rows, weeklyObjectivesControl)

                if dailyControl and dailyControl.SetHidden then
                    dailyControl:SetHidden(true)
                end
                if weeklyControl and weeklyControl.SetHidden then
                    weeklyControl:SetHidden(true)
                end
                if categoryControl and categoryControl.SetHidden then
                    categoryControl:SetHidden(true)
                end

                if container.SetHidden then
                    container:SetHidden(true)
                end

                state.currentHeight = 0
                if container.SetHeight then
                    container:SetHeight(0)
                end

                return
            end

            if not hideEntireSection and container.SetHidden then
                container:SetHidden(false)
            end

            if dailyLabel and dailyLabel.SetText then
                local dailyTitle = resolveTitle(
                    dailyVm.title or GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_DAILY),
                    GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_DAILY)
                )
                local dailyShowCounts = shouldShowCountsFor(dailyVm)
                if dailyShowCounts then
                    local completed = dailyVm.displayCompleted or dailyVm.completed
                    local total = dailyVm.displayLimit or dailyVm.total
                    dailyLabel:SetText(string.format("%s %s", dailyTitle, FormatParensCount(completed, total)))
                else
                    dailyLabel:SetText(dailyTitle)
                end
            end

            if weeklyLabel and weeklyLabel.SetText then
                local weeklyTitle = resolveTitle(
                    weeklyVm.title or GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_WEEKLY),
                    GetString(SI_NVK3UT_TRACKER_ENDEAVOR_CATEGORY_WEEKLY)
                )
                local weeklyShowCounts = shouldShowCountsFor(weeklyVm)
                if weeklyShowCounts then
                    local completed = weeklyVm.displayCompleted or weeklyVm.completed
                    local total = weeklyVm.displayLimit or weeklyVm.total
                    weeklyLabel:SetText(string.format("%s %s", weeklyTitle, FormatParensCount(completed, total)))
                else
                    weeklyLabel:SetText(weeklyTitle)
                end
            end

            local dailyExpanded = categoryExpanded and dailyVm.expanded == true
            local weeklyExpanded = categoryExpanded and weeklyVm.expanded == true

            local function applyGroupLabel(label, useCompletedStyle)
                if not label then
                    return
                end

                local applied
                if rows and type(rows.ApplyGroupLabelColor) == "function" then
                    local ok, result = pcall(rows.ApplyGroupLabelColor, label, rowsOptions, useCompletedStyle)
                    if ok then
                        applied = result == true
                    end
                end

                if not applied then
                    local role
                    if useCompletedStyle then
                        role = rowsOptions.completedRole or "completed"
                    else
                        role = rowsOptions.entryRole or ENTRY_COLOR_ROLE_DEFAULT
                    end
                    applyLabelColor(label, role, overrideColors)
                end
            end

            applyGroupLabel(dailyLabel, dailyUseCompletedStyle)
            applyGroupLabel(weeklyLabel, weeklyUseCompletedStyle)

            if dailyHideRow and dailyControl and dailyControl.SetHidden then
                dailyControl:SetHidden(true)
            end

            if categoryControl and categoryControl.SetHidden then
                categoryControl:SetHidden(false)
            end

            if dailyControl and dailyControl.SetHidden then
                local shouldHideDaily = dailyHideRow or not categoryExpanded
                dailyControl:SetHidden(shouldHideDaily)
            end
            if weeklyControl and weeklyControl.SetHidden then
                local shouldHideWeekly = weeklyHideRow or not categoryExpanded
                weeklyControl:SetHidden(shouldHideWeekly)
            end

            local dailyObjectivesIncluded =
                categoryExpanded
                and dailyExpanded
                and not dailyHideObjectives
                and not dailyHideRow
                and dailyObjectivesControl ~= nil
            local weeklyObjectivesIncluded =
                categoryExpanded
                and weeklyExpanded
                and not weeklyHideObjectives
                and not weeklyHideRow
                and weeklyObjectivesControl ~= nil

            if not categoryExpanded then
                resetObjectiveContainer(rows, dailyObjectivesControl)
                resetObjectiveContainer(rows, weeklyObjectivesControl)
            end

            local dailyObjectivesHeight = 0
            if dailyObjectivesControl then
                if dailyObjectivesIncluded then
                    dailyObjectivesHeight = buildObjectiveRows(rows, dailyObjectivesControl, dailyObjectivesList, rowsOptions)
                else
                    resetObjectiveContainer(rows, dailyObjectivesControl)
                end
            end

            local weeklyObjectivesHeight = 0
            if weeklyObjectivesControl then
                if weeklyObjectivesIncluded then
                    weeklyObjectivesHeight = buildObjectiveRows(rows, weeklyObjectivesControl, weeklyObjectivesList, rowsOptions)
                else
                    resetObjectiveContainer(rows, weeklyObjectivesControl)
                end
            end

            local layout = newLayoutContext(container)
            appendLayoutControl(layout, categoryControl, getCategoryRowHeightValue(rows, categoryExpanded), "header")

            if categoryExpanded then
                if dailyControl and not dailyHideRow then
                    appendLayoutControl(layout, dailyControl, SECTION_ROW_HEIGHT, "entry")
                end
                if dailyObjectivesIncluded then
                    appendLayoutControl(layout, dailyObjectivesControl, dailyObjectivesHeight, "objectives")
                end
                if weeklyControl and not weeklyHideRow then
                    appendLayoutControl(layout, weeklyControl, SECTION_ROW_HEIGHT, "entry")
                end
                if weeklyObjectivesIncluded then
                    appendLayoutControl(layout, weeklyObjectivesControl, weeklyObjectivesHeight, "objectives")
                end
            end

            if layout.visibleCount > 0 then
                local bottomPadding
                if categoryExpanded and layout.rowCount > 0 then
                    bottomPadding = SECTION_BOTTOM_GAP
                else
                    bottomPadding = SECTION_BOTTOM_GAP_COLLAPSED
                end
                layout.height = layout.height + bottomPadding + CATEGORY_SPACING_BELOW
            end
            state.currentHeight = coerceHeight(layout.height)
            if container and container.SetHeight then
                container:SetHeight(state.currentHeight)
            end

            safeDebug(
                "[Endeavor.UI] cat=%s remaining=%d daily=%d/%d weekly=%d/%d",
                tostring(categoryExpanded),
                categoryRemaining,
                tonumber(dailyVm.displayCompleted or dailyVm.completed) or 0,
                tonumber(dailyVm.displayLimit or dailyVm.total) or 0,
                tonumber(weeklyVm.displayCompleted or weeklyVm.completed) or 0,
                tonumber(weeklyVm.displayLimit or weeklyVm.total) or 0
            )

            safeDebug(
                "[Endeavor.UI] formatted: daily=%s weekly=%s",
                FormatParensCount(dailyVm.displayCompleted or dailyVm.completed, dailyVm.displayLimit or dailyVm.total),
                FormatParensCount(weeklyVm.displayCompleted or weeklyVm.completed, weeklyVm.displayLimit or weeklyVm.total)
            )
    end, handleError)

    release()

    if not ok then
        if type(CallErrorHandler) == "function" then
            CallErrorHandler(err)
        else
            error(err)
        end
    end
end
function EndeavorTracker.GetHeight()
    return coerceHeight(state.currentHeight)
end

function EndeavorTracker.Dispose()
    EndeavorTracker._disposed = true
    state.isDisposed = true
    EndeavorTracker:TempEvents_UnregisterAll({ silentInitKick = false })
    state.isInitialized = false
    state.currentHeight = 0
    state.container = nil
    state.ui = nil
end

Nvk3UT.EndeavorTracker = EndeavorTracker

return EndeavorTracker
