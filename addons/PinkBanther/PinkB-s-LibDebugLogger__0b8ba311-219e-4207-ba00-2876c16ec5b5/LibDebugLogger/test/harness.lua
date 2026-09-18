-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Stand-in for the parts of the client API that the log core touches, so the library can be
-- exercised in plain Lua before it is put on a console. Only StartUp/Constants/Logger/Settings/
-- LogHandler/Callbacks/API are loaded; Initialization.lua needs the whole game API and is not
-- part of this harness.

local gameTime = 0
function GetTimeStamp() return 1700000000 end
function GetGameTimeMilliseconds() return gameTime end
function AdvanceGameTime(ms) gameTime = gameTime + ms end

function ZO_ShallowTableCopy(source, target)
    target = target or {}
    for k, v in pairs(source) do target[k] = v end
    return target
end

function ZO_ClearTable(t)
    for k in pairs(t) do t[k] = nil end
    return t
end

ZO_CallbackObject = {}
ZO_CallbackObject.__index = ZO_CallbackObject
function ZO_CallbackObject:New()
    return setmetatable({ callbackRegistry = {} }, ZO_CallbackObject)
end
function ZO_CallbackObject:RegisterCallback(name, fn)
    local registry = self.callbackRegistry
    registry[name] = registry[name] or {}
    table.insert(registry[name], fn)
end
function ZO_CallbackObject:FireCallbacks(name, ...)
    local handlers = self.callbackRegistry[name]
    if not handlers then return end
    for i = 1, #handlers do handlers[i](...) end
end

ZO_Object = {}
ZO_Object.__index = ZO_Object
function ZO_Object:Subclass()
    local class = setmetatable({}, { __index = self })
    class.__index = class
    return class
end
function ZO_Object.New(class)
    return setmetatable({}, class)
end

SLASH_COMMANDS = {}
function zo_strsplit(sep, str) return str, "" end

local root = (...) or "."
local FILES = {
    "StartUp.lua", "Constants.lua", "Logger.lua", "Settings.lua",
    "LogHandler.lua", "Callbacks.lua", "API.lua",
}

local function LoadLibrary()
    _G.LibDebugLogger = nil
    for i = 1, #FILES do
        local path = root .. "/" .. FILES[i]
        local chunk, err = loadfile(path)
        if not chunk then error(err) end
        chunk()
    end
    -- the library normally only knows about performance logging after Initialization.lua
    LibDebugLogger.internal.LogPerformance = function() end
    return LibDebugLogger
end

return { LoadLibrary = LoadLibrary, AdvanceGameTime = AdvanceGameTime }
