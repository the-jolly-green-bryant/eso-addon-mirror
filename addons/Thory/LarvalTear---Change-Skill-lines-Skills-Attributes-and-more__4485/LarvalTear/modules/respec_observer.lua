local Addon = LarvalTearMod
local Log = Addon.Common.Log
local SHARED_UTIL = Addon.Common.Util
local M = Addon.Modules.RespecObserver

local ATTRIBUTE_RESULT_EVENT_NAMESPACE = "LTM_AttributeApply_Result"
local ATTRIBUTE_CAST_EVENT_NAMESPACE = "LTM_AttributeApply_Cast"

local function LogDebugSummary(...)
    Log.LogDebugSummary(...)
end

local function GetAttributeRespecCastTimeRemainingMsSafe()
    if type(GetAttributeRespecCastTimeRemainingMs) == "function" then
        local ok, remainingMs = pcall(GetAttributeRespecCastTimeRemainingMs)
        if ok then
            return remainingMs
        end
    end

    return nil
end

local function IsDialogShowing(dialogName)
    if type(ZO_Dialogs_IsShowing) ~= "function" then
        return false
    end

    local showing = ZO_Dialogs_IsShowing(dialogName)
    local hiding = type(ZO_Dialogs_IsDialogHiding) == "function"
        and ZO_Dialogs_IsDialogHiding(dialogName)
        or false
    return showing and not hiding
end

local function GetCurrentAttributeAllocationMode(statsManager)
    if type(statsManager) ~= "table" then
        return nil
    end

    if type(statsManager.GetAttributePointAllocationMode) == "function" then
        local ok, mode = pcall(statsManager.GetAttributePointAllocationMode, statsManager)
        if ok then
            return mode
        end
    end

    return statsManager.attributePointAllocationMode
end

function M:GetAttributeResultEventNamespace()
    return ATTRIBUTE_RESULT_EVENT_NAMESPACE
end

function M:GetAttributeCastEventNamespace()
    return ATTRIBUTE_CAST_EVENT_NAMESPACE
end

function M:BuildAttributeSnapshot(context, statsManager, sceneHelper)
    return {
        allocationMode = GetCurrentAttributeAllocationMode(statsManager),
        statsShowing = sceneHelper and sceneHelper:IsStatsSceneShowing() or false,
        interaction = sceneHelper and sceneHelper:GetCurrentInteractionTypeSafe() or nil,
        resultReceived = context and context.resultReceived or false,
        resultCode = context and context.resultCode or nil,
        commitSent = context and context.commitSent or false,
        commitAttempt = context and context.commitAttempt or 0,
        castRemainingMs = GetAttributeRespecCastTimeRemainingMsSafe(),
        castDialogShowing = IsDialogShowing("ATTRIBUTE_RESPEC_CAST_KEYBOARD")
            or IsDialogShowing("ATTRIBUTE_RESPEC_CAST_GAMEPAD"),
    }
end

function M:BuildAttributeSnapshotSignature(snapshot)
    if type(snapshot) ~= "table" then
        return "nil"
    end

    return table.concat({
        tostring(snapshot.allocationMode),
        tostring(snapshot.statsShowing),
        tostring(snapshot.interaction),
        tostring(snapshot.resultReceived),
        tostring(snapshot.resultCode),
        tostring(snapshot.commitSent),
        tostring(snapshot.commitAttempt),
        tostring(snapshot.castRemainingMs),
        tostring(snapshot.castDialogShowing),
    }, "|")
end

function M:LogAttributeSnapshotIfChanged(context, label, snapshot)
    if type(context) ~= "table" or type(snapshot) ~= "table" then
        return
    end

    local signature = self:BuildAttributeSnapshotSignature(snapshot)
    if context.attributeObserverSnapshotSignature == signature then
        return
    end

    context.attributeObserverSnapshotSignature = signature
    LogDebugSummary(
        "Attribute observer",
        "label=" .. tostring(label),
        "allocationMode=" .. tostring(snapshot.allocationMode),
        "interaction=" .. tostring(snapshot.interaction),
        "resultReceived=" .. tostring(snapshot.resultReceived),
        "resultCode=" .. tostring(snapshot.resultCode),
        "commitSent=" .. tostring(snapshot.commitSent),
        "commitAttempt=" .. tostring(snapshot.commitAttempt),
        "castRemainingMs=" .. tostring(snapshot.castRemainingMs),
        "castDialogShowing=" .. tostring(snapshot.castDialogShowing)
    )
end

function M:ClearAttributeObservationSignature(context)
    if type(context) == "table" then
        context.attributeObserverSnapshotSignature = nil
    end
end

function M:UnregisterAttributeEvents(context)
    local eventManager = SHARED_UTIL:GetEventManager()
    if eventManager == nil
        or type(eventManager.UnregisterForEvent) ~= "function"
        or type(context) ~= "table" then
        return
    end

    if context.resultEventRegistered and EVENT_ATTRIBUTE_RESPEC_RESULT ~= nil then
        eventManager:UnregisterForEvent(ATTRIBUTE_RESULT_EVENT_NAMESPACE, EVENT_ATTRIBUTE_RESPEC_RESULT)
    end

    if context.castEventRegistered and EVENT_START_ATTRIBUTE_RESPEC_CAST ~= nil then
        eventManager:UnregisterForEvent(ATTRIBUTE_CAST_EVENT_NAMESPACE, EVENT_START_ATTRIBUTE_RESPEC_CAST)
    end

    context.resultEventRegistered = false
    context.castEventRegistered = false
end

function M:RegisterAttributeEvents(context, generation, handlers)
    local eventManager = SHARED_UTIL:GetEventManager()
    if eventManager == nil then
        return false, "event_manager_unavailable"
    end

    if type(eventManager.RegisterForEvent) ~= "function" or type(eventManager.UnregisterForEvent) ~= "function" then
        return false, "event_manager_register_for_event_unavailable"
    end

    self:UnregisterAttributeEvents(context)

    if EVENT_ATTRIBUTE_RESPEC_RESULT == nil then
        return false, "event_attribute_respec_result_unavailable"
    end

    eventManager:RegisterForEvent(ATTRIBUTE_RESULT_EVENT_NAMESPACE, EVENT_ATTRIBUTE_RESPEC_RESULT, function(_, result)
        LogDebugSummary(
            "Attribute observer event",
            "kind=result",
            "generation=" .. tostring(generation),
            "result=" .. tostring(result)
        )
        if type(handlers) == "table" and type(handlers.onResult) == "function" then
            handlers.onResult(result)
        end
    end)
    context.resultEventRegistered = true

    if EVENT_START_ATTRIBUTE_RESPEC_CAST ~= nil then
        eventManager:RegisterForEvent(ATTRIBUTE_CAST_EVENT_NAMESPACE, EVENT_START_ATTRIBUTE_RESPEC_CAST, function()
            LogDebugSummary(
                "Attribute observer event",
                "kind=cast",
                "generation=" .. tostring(generation)
            )
            if type(handlers) == "table" and type(handlers.onCast) == "function" then
                handlers.onCast()
            end
        end)
        context.castEventRegistered = true
    end

    LogDebugSummary(
        "Attribute observer register",
        "generation=" .. tostring(generation),
        "resultEvent=" .. tostring(context.resultEventRegistered),
        "castEvent=" .. tostring(context.castEventRegistered)
    )
    return true
end
