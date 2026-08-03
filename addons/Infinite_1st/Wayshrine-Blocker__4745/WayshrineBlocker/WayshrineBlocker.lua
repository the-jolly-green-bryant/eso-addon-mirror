local ADDON_NAME = "WayshrineBlocker"
local ADDON_VERSION = 1

local WayshrineBlocker = {}
WayshrineBlocker.savedVars = nil

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
    LibInteractionHook.RegisterOnTryHandlingInteraction(ADDON_NAME, OnTryHandlingInteraction)
end

local function UnregisterHook()
    LibInteractionHook.UnregisterOnTryHandlingInteraction(ADDON_NAME)
end

local function SetEnabled(enabled)
    WayshrineBlocker.savedVars.enabled = enabled
    if enabled then
        RegisterHook()
    else
        UnregisterHook()
    end
    d("WayshrineBlocker: " .. (enabled and "blocking enabled" or "blocking disabled"))
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    WayshrineBlocker.savedVars = ZO_SavedVars:NewAccountWide("WayshrineBlockerSV", ADDON_VERSION, GetWorldName(), defaults)

    if WayshrineBlocker.savedVars.enabled then
        RegisterHook()
    end

    SLASH_COMMANDS["/wayshrineblock"] = function()
        SetEnabled(not WayshrineBlocker.savedVars.enabled)
    end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
