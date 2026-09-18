-- SPDX-FileCopyrightText: 2025 sirinsidiator
-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Modified version by PinkBanther: see LogHandler.lua

local lib = LibDebugLogger
local internal = lib.internal
local callback = lib.callback
local Logger = internal.class.Logger

--- Returns the current LibDebugLogger API version. It will be incremented in case there are any breaking changes.
--- You can check this before accessing any functions to gracefully handle future incompatibilities.
lib.GetAPIVersion = function() return 2 end

--- The default settings table. See Settings.lua for details.
lib.DEFAULT_SETTINGS = internal.defaultSettings
--- The tag used to log messages coming from the vanilla UI.
lib.TAG_INGAME = internal.TAG_INGAME

--- The verbose log level is not logged unless explicitly white-listed in the StartUpConfig.lua.
--- It should be used for messages that are printed very often and are not of much interest to other parties .
lib.LOG_LEVEL_VERBOSE = internal.LOG_LEVEL_VERBOSE
--- The debug log level is not logged by default and can be used for anything that helps identifying a problem,
--- but is not of interest during regular operation.
lib.LOG_LEVEL_DEBUG = internal.LOG_LEVEL_DEBUG
--- The info log level is the default log level and should be used to log messages that give a rough idea of
--- the flow of events during regular operation. It is also used for logging d() messages.
lib.LOG_LEVEL_INFO = internal.LOG_LEVEL_INFO
--- The warning log level should be used to log messages that could potentially lead to errors.
--- Ingame alert messages of the UI_ALERT_CATEGORY_ERROR are logged as warnings.
lib.LOG_LEVEL_WARNING = internal.LOG_LEVEL_WARNING
--- The error log level should usually not be used by addons, except when they suppress the ingame error message via pcall.
--- UI errors are otherwise automatically logged with this level.
lib.LOG_LEVEL_ERROR = internal.LOG_LEVEL_ERROR
--- This table can be used to iterate over the log levels in order of severity.
lib.LOG_LEVELS = internal.LOG_LEVELS
--- This table maps each log level to an English word
lib.LOG_LEVEL_TO_STRING = internal.LOG_LEVEL_TO_STRING
--- This table contains the lower case log levels (e.g. "d") and their string counter-parts (e.g. "debug") as keys and their respective levels as value.
--- It is for example used for the settings slash command input
lib.STR_TO_LOG_LEVEL = internal.STR_TO_LOG_LEVEL

--- index for the timestamp in log entries
lib.ENTRY_TIME_INDEX = internal.ENTRY_TIME_INDEX
--- index for the formatted time in log entries
lib.ENTRY_FORMATTED_TIME_INDEX = internal.ENTRY_FORMATTED_TIME_INDEX
--- index for the occurrences in log entries
lib.ENTRY_OCCURENCES_INDEX = internal.ENTRY_OCCURENCES_INDEX
--- index for the level in log entries
lib.ENTRY_LEVEL_INDEX = internal.ENTRY_LEVEL_INDEX
--- index for the tag in log entries
lib.ENTRY_TAG_INDEX = internal.ENTRY_TAG_INDEX
--- index for the message in log entries
lib.ENTRY_MESSAGE_INDEX = internal.ENTRY_MESSAGE_INDEX
--- index for the stack trace in log entries
lib.ENTRY_STACK_INDEX = internal.ENTRY_STACK_INDEX
--- index for the error code in log entries
lib.ENTRY_ERROR_CODE_INDEX = internal.ENTRY_ERROR_CODE_INDEX

--- The time when the client was started in milliseconds.
lib.SESSION_START_TIME = internal.SESSION_START_TIME

--- The approximate time when the UI was loaded in milliseconds.
--- We don't actually know the exact time for the UI load, so instead we just use the time when LibDebugLogger.lua was loaded.
--- Since all log messages will have a timestamp after that, it's good enough for our purpose.
lib.UI_LOAD_START_TIME = internal.UI_LOAD_START_TIME

--- @param tag - a string identifier that is used to identify entries made via this logger
--- @return a new logger instance with the passed tag
function lib:Create(tag)
    if(self ~= lib) then -- this is so both calling lib.Create and lib:Create work
        tag = self
    end
    return Logger:New(tag)
end
setmetatable(lib, { __call = function(_, ...) return lib:Create(...) end })

--- @return true, if logs capture a stack trace.
function lib:IsTraceLoggingEnabled()
    return internal.settings.logTraces
end

--- @param enabled - controls if logs should capture a stack trace.
function lib:SetTraceLoggingEnabled(enabled)
    internal.settings.logTraces = enabled
end

--- @return the minimum log level.
function lib:GetMinLogLevel()
    return internal.settings.minLogLevel
end

--- @param level - sets the minimum log level.
function lib:SetMinLogLevel(level)
    internal.settings.minLogLevel = level
end

--- Builds an array of entry tables in the documented ENTRY_*_INDEX layout, oldest first.
--- The log itself is stored as a flat ring buffer, so this allocates one table per entry and
--- should only be called when the entries are really needed (e.g. to display or export them).
--- Use GetNumEntries and GetEntry to walk the log without building the whole array.
--- @return an array of log entries.
function lib:GetLog()
    return internal.GetLogSnapshot()
end

--- @return the number of entries currently held in the log.
function lib:GetNumEntries()
    return internal.logCount
end

--- @param index - position in the log, where 1 is the oldest entry still held.
--- @param target - optional table to fill instead of allocating a new one.
--- @return a log entry in the documented ENTRY_*_INDEX layout, or nil when the index is invalid.
function lib:GetEntry(index, target)
    if(self ~= lib) then -- this is so both calling lib.GetEntry and lib:GetEntry work
        index, target = self, index
    end
    return internal.BuildEntry(index, target)
end

--- @return how many entries the log keeps before the oldest one is overwritten.
function lib:GetMaxEntries()
    return internal.logCapacity
end

--- Resizes the log. The oldest entries are dropped when the new size is smaller than the
--- current number of entries.
--- @param maxEntries - the new size, clamped to a sane range.
function lib:SetMaxEntries(maxEntries)
    internal.SetLogCapacity(maxEntries)
    internal.settings.maxEntries = internal.logCapacity
end

--- Rough estimate of how much memory the log occupies, for reporting purposes.
--- @return the estimated size of the log in bytes.
function lib:GetEstimatedMemoryUsage()
    local SLOT_BYTES = 16
    local STRING_HEADER_BYTES = 25
    local log = internal.log
    local bytes = internal.logCapacity * internal.SLOT_STRIDE * SLOT_BYTES
    for i = 1, internal.logCount do
        local base = internal.GetEntryBase(i)
        local message = log[base + internal.SLOT_MESSAGE]
        local stack = log[base + internal.SLOT_STACK]
        if type(message) == "string" then bytes = bytes + STRING_HEADER_BYTES + #message end
        if type(stack) == "string" then bytes = bytes + STRING_HEADER_BYTES + #stack end
    end
    return bytes
end

--- When toggled on, the log handler will append errors in case the first argument was interpreted as a formatting string,
--- but the subsequent call to string.format failed. This is purely for the convenience of authors who try to debug their log output
--- and as such it doesn't have a corresponding setting.
--- Intended use is either via "/script d(LibDebugLogger:ToggleFormattingErrors())" or in StartUpConfig.lua
--- @return the new state
function lib:ToggleFormattingErrors()
    internal.appendFormattingErrors = not internal.appendFormattingErrors
    return internal.appendFormattingErrors
end

--- removes all entries from the log.
--- @return an empty array, for compatibility with the previous behaviour.
function lib:ClearLog()
    internal.ClearLog()
    local empty = {}
    internal:FireCallbacks(callback.LOG_CLEARED, empty)
    return empty
end

--- @param enabled - controls if logs created via d(), df() or CHAT_ROUTER:AddDebugMessage should be hidden from the chat window
function lib:SetBlockChatOutputEnabled(enabled)
    internal.blockChatOutput = enabled
end

--- @return true, if logs created via d(), df() or CHAT_ROUTER:AddDebugMessage are hidden from the chat window
function lib:IsBlockChatOutputEnabled()
    return internal.blockChatOutput
end

--- Kept for compatibility. The log is no longer written to saved variables, so messages are never
--- split into chunks any more and this simply returns the input. Long messages are truncated
--- instead, see MAX_MESSAGE_LENGTH in Constants.lua.
--- @return the resulting string
function lib.CombineSplitStringIfNeeded(input)
    if(type(input) == "table") then
        return table.concat(input, "")
    else
        return input
    end
end

--- Register to a callback fired by the library. Usage is the same as with CALLBACK_MANAGER:RegisterCallback.
--- The available callback names are located in Callbacks.lua
--- Callback functions should be as lightweight as possible. If you plan to use expensive calls,
--- defer the execution with zo_callLater!
function lib:RegisterCallback(...)
    internal:OnCallbackRegistered((select(1, ...)))
    return internal.callbackObject:RegisterCallback(...)
end
