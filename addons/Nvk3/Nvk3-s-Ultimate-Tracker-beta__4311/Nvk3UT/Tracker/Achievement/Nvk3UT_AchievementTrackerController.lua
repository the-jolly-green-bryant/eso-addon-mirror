-- Tracker/Achievement/Nvk3UT_AchievementTrackerController.lua
-- Centralizes Achievement tracker view model building and refresh signaling.

local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Controller = Nvk3UT.AchievementTrackerController or {}
Nvk3UT.AchievementTrackerController = Controller

local MODULE_TAG = addonName .. ".AchievementTrackerController"

local function getAddonRoot()
    local root = rawget(_G, addonName)
    if type(root) == "table" then
        return root
    end

    return Nvk3UT
end

local function getRuntime()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil
    end

    return rawget(root, "TrackerRuntime")
end

local function getRebuild()
    local root = getAddonRoot()
    local rebuild = root and rawget(root, "Rebuild")
    if type(rebuild) == "table" then
        return rebuild
    end

    return _G.Nvk3UT_Rebuild
end

local function getAchievementModel()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil
    end

    return rawget(root, "AchievementModel")
end

local function getAchievementTracker()
    local root = getAddonRoot()
    if type(root) ~= "table" then
        return nil
    end

    return rawget(root, "AchievementTracker")
end

local function isDebugEnabled()
    local root = getAddonRoot()

    local utils = root and root.Utils or _G.Nvk3UT_Utils
    if type(utils) == "table" and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = root and root.Diagnostics or _G.Nvk3UT_Diagnostics
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

    local sv = root and (root.SV or root.sv)
    if type(sv) == "table" and sv.debug ~= nil then
        return sv.debug == true
    end

    return false
end

local function debugLog(message, ...)
    if not isDebugEnabled() then
        return
    end

    local formatted = message or ""
    if select("#", ...) > 0 then
        formatted = string.format(tostring(message), ...)
    end

    if d then
        d(string.format("[%s] %s", MODULE_TAG, formatted))
    elseif print then
        print(string.format("[%s] %s", MODULE_TAG, formatted))
    end
end

function Controller.BuildViewModel()
    debugLog("BuildViewModel")

    local model = getAchievementModel()
    if type(model) ~= "table" then
        return nil
    end

    local getViewData = model.GetViewData or model.GetSnapshot or model.GetViewModel
    if type(getViewData) ~= "function" then
        return nil
    end

    return getViewData(model)
end

function Controller.MarkDirty(reason)
    local runtime = getRuntime()
    if type(runtime) == "table" then
        local queueDirty = runtime.QueueDirty or runtime.queueDirty
        if type(queueDirty) == "function" then
            local ok = pcall(queueDirty, runtime, "achievement")
            if ok then
                return true
            end
        end
    end

    local rebuild = getRebuild()
    if type(rebuild) == "table" then
        local forceRefresh = rebuild.ForceAchievementRefresh
        if type(forceRefresh) == "function" then
            local context = reason
            if context == nil or context == "" then
                context = MODULE_TAG
            else
                context = string.format("%s:%s", MODULE_TAG, tostring(reason))
            end

            local ok, triggered = pcall(forceRefresh, context)
            if ok then
                return triggered == true
            end
        end
    end

    local tracker = getAchievementTracker()
    if type(tracker) == "table" and type(tracker.Refresh) == "function" then
        local ok = pcall(tracker.Refresh, tracker)
        return ok
    end

    return false
end

function Controller.RefreshNow(reason)
    return Controller.MarkDirty(reason)
end

return Controller
