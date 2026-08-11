local ADDON_NAME = "WayshrineBlocker"
local ADDON_VERSION = 2

local WayshrineBlocker = {}
WayshrineBlocker.savedVars = nil
WayshrineBlocker.hookRegistered = false

local defaults = {
    enabled = true,
}

local WAYSHRINE_PATTERNS = {
    "Wayshrine",
    "Дорожное святилище",
    "Wegschrein",
    "Oratoire",
    "Ermita",
    "路点神龛",
}

local function IsWayshrine(interactableName)
    if not interactableName or interactableName == "" then
        return false
    end
    for _, pattern in ipairs(WAYSHRINE_PATTERNS) do
        if interactableName:find(pattern) then
            return true
        end
    end
    return false
end

local function OnTryHandlingInteraction(action, interactableName, currentFrameTimeSeconds)
    if IsWayshrine(interactableName) then
        LibInteractionHook.HideInteraction()
        return true
    end
    return false
end

local function RegisterHook()
    if WayshrineBlocker.hookRegistered then
        return
    end
    LibInteractionHook.RegisterOnTryHandlingInteraction(ADDON_NAME, OnTryHandlingInteraction)
    WayshrineBlocker.hookRegistered = true
    d("WayshrineBlocker: blocking enabled")
end

local function UnregisterHook()
    if not WayshrineBlocker.hookRegistered then
        return
    end
    LibInteractionHook.UnregisterOnTryHandlingInteraction(ADDON_NAME)
    WayshrineBlocker.hookRegistered = false
    d("WayshrineBlocker: blocking disabled")
end

local function ApplyHookState()
    if WayshrineBlocker.savedVars.enabled and not IsPlayerInAvAWorld() then
        RegisterHook()
    else
        UnregisterHook()
    end
end

local function SetEnabled(enabled)
    WayshrineBlocker.savedVars.enabled = enabled
    ApplyHookState()
end

local function OnPlayerActivated()
    ApplyHookState()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    WayshrineBlocker.savedVars = ZO_SavedVars:NewAccountWide("WayshrineBlockerSV", ADDON_VERSION, GetWorldName(), defaults)

    ApplyHookState()
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    SLASH_COMMANDS["/wayshrineblock"] = function()
        SetEnabled(not WayshrineBlocker.savedVars.enabled)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
