-- SPDX-FileCopyrightText: 2025 sirinsidiator
-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Modified version by PinkBanther: see LogHandler.lua

local lib = LibDebugLogger
local internal = lib.internal

internal.defaultSettings = {
    version = 3,
    logTraces = false, -- save a trace for each call to one of the Log functions
    minLogLevel = internal.LOG_LEVEL_INFO, -- define which entries we will actually keep
    maxEntries = internal.DEFAULT_MAX_ENTRIES, -- size of the ring buffer, see Constants.lua
    loadScreenStartTime = internal.UI_LOAD_START_TIME -- not an actual setting, used to measure how long loading screens take
}

-- make a temporary copy until the real settings are available to avoid errors when they are accessed
internal.settings = ZO_ShallowTableCopy(internal.defaultSettings)

function internal:InitializeSettings()
    if not internal.ignoreSavedVars then
        if LibDebugLoggerSettings then
            local tempSettings = self.settings
            self.settings = LibDebugLoggerSettings

            -- upgrade settings
            for key, value in pairs(tempSettings) do
                if(self.settings[key] == nil) then
                    self.settings[key] = value
                end
            end

            for key in pairs(self.settings) do
                if(tempSettings[key] == nil) then
                    self.settings[key] = nil
                end
            end

            self.settings.version = tempSettings.version
        else
            LibDebugLoggerSettings = self.settings
        end
    end

    -- the log itself is no longer persisted. Clean up the saved variable left behind by older
    -- versions so it stops being loaded into memory on every login.
    LibDebugLoggerLog = nil

    -- we want to avoid having a dependency on LibChatLogger, but still use it in case it is around
    local chat
    local function GetChatProxy()
        if(not chat) then
            if(LibChatMessage) then
                chat = LibChatMessage(lib.id, "LDL")
            else
                local CHAT_ROUTER = CHAT_ROUTER
                local TAG_TEMPLATE = "[%s] %s"
                chat = {
                    Print = function(self, message)
                        CHAT_ROUTER:AddSystemMessage(TAG_TEMPLATE:format(lib.id, message))
                    end,
                    Printf = function(self, formatter, ...)
                        local taggedFormatter = TAG_TEMPLATE:format(lib.id, formatter)
                        return CHAT_ROUTER:AddSystemMessage(taggedFormatter:format(...))
                    end,
                }
            end
        end
        return chat
    end

    SLASH_COMMANDS["/debuglogger"] = function(params)
        local chat = GetChatProxy()
        local handled = false
        local command, arg = zo_strsplit(" ", params)
        command = string.lower(command)
        arg = string.lower(arg)

        if(command == "stack") then
            if(arg == "on") then
                lib:SetTraceLoggingEnabled(true)
                chat:Print("Enabled stack trace logging")
            elseif(arg == "off") then
                lib:SetTraceLoggingEnabled(false)
                chat:Print("Disabled stack trace logging")
            else
                local enabled = lib:IsTraceLoggingEnabled()
                chat:Printf("Stack trace logging is currently %s", enabled and "enabled" or "disabled")
            end
            handled = true
        elseif(command == "level") then
            local level = internal.STR_TO_LOG_LEVEL[arg]
            if(level) then
                lib:SetMinLogLevel(level)
                chat:Printf("Set log level to %s", internal.LOG_LEVEL_TO_STRING[level])
            else
                level = lib:GetMinLogLevel()
                chat:Printf("Log level is currently set to %s", internal.LOG_LEVEL_TO_STRING[level])
            end
            handled = true
        elseif(command == "size") then
            local size = tonumber(arg)
            if(size) then
                lib:SetMaxEntries(size)
                chat:Printf("Set log size to %d entries", lib:GetMaxEntries())
            else
                chat:Printf("Log holds %d of %d entries (about %d KB)",
                    lib:GetNumEntries(), lib:GetMaxEntries(), lib:GetEstimatedMemoryUsage() / 1024)
            end
            handled = true
        elseif(command == "clear") then
            lib:ClearLog()
            chat:Print("log was emptied")
            handled = true
        end

        if(not handled) then
            local out = {}
            out[#out + 1] = "/debuglogger <command> [argument]"
            out[#out + 1] = "<stack>|u100%:0: :|u[on/off]|u270%:0:       :|uEnables or disables trace logging"
            out[#out + 1] = "<level>|u120%:0: :|u[v/d/i/w/e]|u180%:0:    :|uSets the minimum level for logging"
            out[#out + 1] = "<size>|u150%:0: :|u[number]|u250%:0:        :|uSets how many entries are kept"
            out[#out + 1] = "<clear>|u600%:0:                            :|uDeletes all log entries"
            out[#out + 1] = "Example: /debuglogger stack on"
            chat:Print(table.concat(out, "\n"))
        end
    end

    return self.settings
end
