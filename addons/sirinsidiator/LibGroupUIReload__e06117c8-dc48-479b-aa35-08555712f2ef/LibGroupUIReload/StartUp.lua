-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

local LGB = LibGroupBroadcast

--- @class LibGroupUIReload
local lib = {}

local handler = LGB:RegisterHandler("LibGroupUIReload", "UIReload")
handler:SetDisplayName("UI Reload")
handler:SetDescription("Notifies other group members when your UI has reloaded.")
handler:SetApi(lib)

local EVENT_NAME = "UIReload"
local SendEvent = handler:DeclareCustomEvent(0, EVENT_NAME)

EVENT_MANAGER:RegisterForEvent("LibGroupUIReload", EVENT_PLAYER_ACTIVATED, function(_, initial)
    if initial == false then
        SendEvent()
    end
    EVENT_MANAGER:UnregisterForEvent("LibGroupUIReload", EVENT_PLAYER_ACTIVATED)
end)

--- Registers a callback for group member UI reloads.
--- @param callback fun(unitTag: string) The callback function that will be called when a group member's UI reloads.
--- @return boolean success True if the callback was successfully registered, false otherwise.
--- @see LibGroupUIReload.UnregisterForUIReload
function lib:RegisterForUIReload(callback)
    return LGB:RegisterForCustomEvent(EVENT_NAME, callback)
end

--- Unregisters a callback for group member UI reloads.
--- @param callback fun(unitTag: string) The callback function to unregister. Has to be the same instance as the one registered.
--- @return boolean success True if the callback was successfully unregistered, false otherwise.
--- @see LibGroupUIReload.RegisterForUIReload
function lib:UnregisterForUIReload(callback)
    return LGB:UnregisterForCustomEvent(EVENT_NAME, callback)
end
