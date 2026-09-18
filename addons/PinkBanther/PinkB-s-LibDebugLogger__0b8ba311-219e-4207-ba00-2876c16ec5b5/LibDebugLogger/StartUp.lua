-- SPDX-FileCopyrightText: 2025 sirinsidiator
-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Modified version by PinkBanther: see LogHandler.lua

-- first thing we do is to measure the start time
local UI_LOAD_START_TIME = GetTimeStamp() * 1000
local SESSION_START_TIME = UI_LOAD_START_TIME - GetGameTimeMilliseconds()

local LIB_IDENTIFIER = "LibDebugLogger"

assert(not _G[LIB_IDENTIFIER], LIB_IDENTIFIER .. " is already loaded")

local callbackObject = ZO_CallbackObject:New()

local function FireCallbacks(self, ...)
    return callbackObject:FireCallbacks(...)
end

-- building a compatibility table for an entry is only worth it when somebody is listening, so we
-- keep track of the registrations ourselves. ZO_CallbackObject also exposes its registry, which
-- catches listeners that registered on the callback object directly.
local registeredCallbacks = {}
local function HasCallbacks(self, name)
    if registeredCallbacks[name] then return true end
    local registry = callbackObject.callbackRegistry
    if registry and registry[name] then return true end
    return false
end

local function OnCallbackRegistered(self, name)
    registeredCallbacks[name] = true
end

local lib = {
    id = LIB_IDENTIFIER,
    internal = {
        class = {},
        -- flat ring buffer. Entry n occupies SLOT_STRIDE consecutive slots; see LogHandler.lua
        log = {},
        logCount = 0,
        logStart = 0, -- zero based slot index of the oldest entry
        logCapacity = 0,
        verboseWhitelist = {},
        callbackObject = callbackObject,
        FireCallbacks = FireCallbacks,
        HasCallbacks = HasCallbacks,
        OnCallbackRegistered = OnCallbackRegistered,
        UI_LOAD_START_TIME = UI_LOAD_START_TIME,
        SESSION_START_TIME = SESSION_START_TIME,
    },
    callback = {},
}
_G[LIB_IDENTIFIER] = lib
