-- SPDX-FileCopyrightText: 2025 sirinsidiator
-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Modified version by PinkBanther. What changed compared to the original and why:
--
--  * The log is a fixed size ring buffer of flat slots instead of a growing array of one table
--    per entry. One table per entry costs 56 bytes of header plus 16 bytes per slot before any
--    message is stored, which was about two thirds of the memory the library used.
--  * The formatted time string is no longer stored. It is derived from the timestamp whenever
--    somebody actually wants to read it.
--  * The log is no longer written to saved variables, so nothing is carried over into the next
--    session and there is no second copy of the whole log during start up.
--  * Pruning no longer copies the whole log into a new table every thousand entries. The ring
--    buffer overwrites the oldest entry in place.
--  * Identical messages are merged when they match any of the last few entries, not only the
--    entry right before them, so two addons spamming in turn no longer fill the log.
--  * Messages and stack traces are truncated instead of being split into a table of chunks.
--  * TimeSync.lua is gone. It raised an error on purpose every login so an external log viewer
--    website could line up its timestamps with the client log, and hid the error dialog with two
--    hard coded error codes. On console the add-on lives under a per install GUID path, so the
--    error code is different for everybody and the dialog always showed up. The log is no longer
--    persisted either, so there was nothing left for that website to read.
--
-- Storage layout: entry n (1 = oldest) lives in the slots
--   base + SLOT_TIME .. base + SLOT_ERROR_CODE, where base = slot * SLOT_STRIDE
-- and slot = (logStart + n - 1) % logCapacity. Unused fields hold false, never nil, so the
-- array part of the buffer stays dense.

local lib = LibDebugLogger
local internal = lib.internal
local callback = lib.callback

local strsub = string.sub
local strformat = string.format
local tostring = tostring
local tconcat = table.concat
local osdate = os.date
local traceback = debug.traceback
local select = select
local type = type
local pcall = pcall
local ZO_ClearTable = ZO_ClearTable
local GetGameTimeMilliseconds = GetGameTimeMilliseconds

local SLOT_TIME = internal.SLOT_TIME
local SLOT_OCCURENCES = internal.SLOT_OCCURENCES
local SLOT_LEVEL = internal.SLOT_LEVEL
local SLOT_TAG = internal.SLOT_TAG
local SLOT_MESSAGE = internal.SLOT_MESSAGE
local SLOT_STACK = internal.SLOT_STACK
local SLOT_ERROR_CODE = internal.SLOT_ERROR_CODE
local SLOT_STRIDE = internal.SLOT_STRIDE

local ENTRY_TIME_INDEX = internal.ENTRY_TIME_INDEX
local ENTRY_FORMATTED_TIME_INDEX = internal.ENTRY_FORMATTED_TIME_INDEX
local ENTRY_OCCURENCES_INDEX = internal.ENTRY_OCCURENCES_INDEX
local ENTRY_LEVEL_INDEX = internal.ENTRY_LEVEL_INDEX
local ENTRY_TAG_INDEX = internal.ENTRY_TAG_INDEX
local ENTRY_MESSAGE_INDEX = internal.ENTRY_MESSAGE_INDEX
local ENTRY_STACK_INDEX = internal.ENTRY_STACK_INDEX
local ENTRY_ERROR_CODE_INDEX = internal.ENTRY_ERROR_CODE_INDEX

local MAX_MESSAGE_LENGTH = internal.MAX_MESSAGE_LENGTH
local MAX_STACK_LENGTH = internal.MAX_STACK_LENGTH
local DUPLICATE_LOOKBACK = internal.DUPLICATE_LOOKBACK
local TRUNCATION_MARKER = "... (truncated)"

-- time formatting ------------------------------------------------------------------------------

-- the time zone offset does not change while the client runs, so we only ask for it once
local timeZoneSuffix = " " .. osdate("%z")

local mfloor = math.floor
local function FormatTime(timestamp)
    local seconds = mfloor(timestamp / 1000)
    return strformat("%s.%03d%s", osdate("%F %T", seconds), mfloor(timestamp - seconds * 1000), timeZoneSuffix)
end
internal.FormatTime = FormatTime

-- ring buffer ----------------------------------------------------------------------------------

local function ClampCapacity(capacity)
    if type(capacity) ~= "number" then return internal.DEFAULT_MAX_ENTRIES end
    capacity = math.floor(capacity)
    if capacity < internal.MIN_MAX_ENTRIES then return internal.MIN_MAX_ENTRIES end
    if capacity > internal.MAX_MAX_ENTRIES then return internal.MAX_MAX_ENTRIES end
    return capacity
end

--- copies the newest entries into a buffer of the requested size. Only called when the user
--- changes the setting, so the temporary second buffer is not a concern.
local function SetCapacity(newCapacity)
    newCapacity = ClampCapacity(newCapacity)
    if newCapacity == internal.logCapacity then return end

    local oldLog = internal.log
    local oldCount = internal.logCount
    local oldStart = internal.logStart
    local oldCapacity = internal.logCapacity

    local newLog = {}
    local keep = oldCount
    if keep > newCapacity then keep = newCapacity end
    local firstKept = oldCount - keep -- number of entries dropped from the front

    for i = 1, keep do
        local fromBase = ((oldStart + firstKept + i - 1) % oldCapacity) * SLOT_STRIDE
        local toBase = (i - 1) * SLOT_STRIDE
        for slot = 1, SLOT_STRIDE do
            newLog[toBase + slot] = oldLog[fromBase + slot]
        end
    end

    internal.log = newLog
    internal.logCount = keep
    internal.logStart = 0
    internal.logCapacity = newCapacity
end
internal.SetLogCapacity = SetCapacity

SetCapacity(internal.DEFAULT_MAX_ENTRIES)

--- @param index - 1 is the oldest entry still in the buffer
--- @return the offset of that entry in the flat buffer, or nil if the index is out of range
local function GetBase(index)
    if type(index) ~= "number" or index < 1 or index > internal.logCount then return nil end
    return ((internal.logStart + index - 1) % internal.logCapacity) * SLOT_STRIDE
end
internal.GetEntryBase = GetBase

--- builds a table in the layout the public ENTRY_*_INDEX constants describe. The formatted time
--- is generated here instead of being kept for every entry.
--- @param index - 1 is the oldest entry still in the buffer
--- @param target - optional table to fill instead of creating a new one
local function BuildEntry(index, target)
    local base = GetBase(index)
    if not base then return nil end

    local log = internal.log
    local entry = target or {}
    local timestamp = log[base + SLOT_TIME]
    entry[ENTRY_TIME_INDEX] = timestamp
    entry[ENTRY_FORMATTED_TIME_INDEX] = FormatTime(timestamp)
    entry[ENTRY_OCCURENCES_INDEX] = log[base + SLOT_OCCURENCES]
    entry[ENTRY_LEVEL_INDEX] = log[base + SLOT_LEVEL]
    entry[ENTRY_TAG_INDEX] = log[base + SLOT_TAG]
    entry[ENTRY_MESSAGE_INDEX] = log[base + SLOT_MESSAGE]
    entry[ENTRY_STACK_INDEX] = log[base + SLOT_STACK] or nil
    entry[ENTRY_ERROR_CODE_INDEX] = log[base + SLOT_ERROR_CODE] or nil
    return entry
end
internal.BuildEntry = BuildEntry

--- @return a plain array of entry tables, newest last. Only build this when you really need it,
--- since it allocates one table per entry.
local function GetLogSnapshot()
    local snapshot = {}
    for i = 1, internal.logCount do
        snapshot[i] = BuildEntry(i)
    end
    return snapshot
end
internal.GetLogSnapshot = GetLogSnapshot

local function ClearLog()
    internal.log = {}
    internal.logCount = 0
    internal.logStart = 0
end
internal.ClearLog = ClearLog

-- message preparation --------------------------------------------------------------------------

-- this function should probably be smarter about detecting real formatting strings.
-- right now we just do a simple detection, try if it works and fall back to using tostring otherwise
local function IsFormattingString(input)
    if(type(input) == "string" and input:find("%%%S")) then
        return true
    end
    return false
end

local function Truncate(value, maxLength)
    if not value then return false end
    if #value > maxLength then
        return strsub(value, 1, maxLength) .. TRUNCATION_MARKER
    end
    return value
end

local temp = {}
local function PrepareMessage(...)
    local message = ""
    local count = select("#", ...)
    if(count > 0) then
        local handled = false
        if(IsFormattingString(select(1, ...))) then
            -- use pcall to try formatting the string, otherwise we may end up with an infinite error loop
            handled, message = pcall(strformat, ...)
        end

        if(not handled) then
            ZO_ClearTable(temp)
            for i = 1, count do
                temp[i] = tostring(select(i, ...))
            end

            if(internal.appendFormattingErrors and message ~= "") then
                -- try to append the error without the stack trace in case we failed to format it earlier
                local index = message:find("\nstack traceback")
                if(index) then
                    temp[#temp + 1] = message:sub(1, index)
                end
            end
            message = tconcat(temp, " ")
        end
    end

    return message
end

-- writing --------------------------------------------------------------------------------------

local scratchEntry = {}

local function FireLogAdded(index, updatedExisting)
    if not internal:HasCallbacks(callback.LOG_ADDED) then return end
    -- the entry table is reused between calls, so listeners must not hold on to it
    internal:FireCallbacks(callback.LOG_ADDED, BuildEntry(index, scratchEntry), updatedExisting)
end

--- @return the index of an identical entry among the newest DUPLICATE_LOOKBACK ones, or nil
local function FindDuplicate(level, tag, message, stacktrace)
    local log = internal.log
    local count = internal.logCount
    local oldest = count - DUPLICATE_LOOKBACK + 1
    if oldest < 1 then oldest = 1 end

    for index = count, oldest, -1 do
        local base = GetBase(index)
        if log[base + SLOT_LEVEL] == level
            and log[base + SLOT_TAG] == tag
            and log[base + SLOT_MESSAGE] == message
            and log[base + SLOT_STACK] == stacktrace
        then
            return index
        end
    end
    return nil
end

local function DoLog(level, tag, message, stacktrace, errorCode)
    local now = internal.SESSION_START_TIME + GetGameTimeMilliseconds()
    if stacktrace and internal.originStacktrace then
        stacktrace = stacktrace .. "\nregistered by:\n" .. internal.originStacktrace
    end
    message = Truncate(message, MAX_MESSAGE_LENGTH) or ""
    stacktrace = Truncate(stacktrace, MAX_STACK_LENGTH)

    local log = internal.log
    local duplicate = FindDuplicate(level, tag, message, stacktrace)
    if duplicate then
        local base = GetBase(duplicate)
        log[base + SLOT_TIME] = now
        log[base + SLOT_OCCURENCES] = log[base + SLOT_OCCURENCES] + 1
        FireLogAdded(duplicate, true)
        return
    end

    local capacity = internal.logCapacity
    local slot
    if internal.logCount < capacity then
        slot = (internal.logStart + internal.logCount) % capacity
        internal.logCount = internal.logCount + 1
    else
        -- the buffer is full, so the oldest entry is overwritten in place
        slot = internal.logStart
        internal.logStart = (internal.logStart + 1) % capacity
        if internal:HasCallbacks(callback.LOG_PRUNED) then
            internal:FireCallbacks(callback.LOG_PRUNED, 2)
        end
    end

    local base = slot * SLOT_STRIDE
    log[base + SLOT_TIME] = now
    log[base + SLOT_OCCURENCES] = 1
    log[base + SLOT_LEVEL] = level
    log[base + SLOT_TAG] = tag
    log[base + SLOT_MESSAGE] = message
    log[base + SLOT_STACK] = stacktrace or false
    log[base + SLOT_ERROR_CODE] = errorCode or false

    FireLogAdded(internal.logCount, false)
end

-- add a simple log that should hopefully never fail
local function LogFallbackMessage(message)
    if(type(message) == "string") then
        message = strsub(message, 1, MAX_MESSAGE_LENGTH)
    else
        message = "Could not create log entry"
    end
    pcall(DoLog, internal.LOG_LEVEL_ERROR, lib.id, message, nil, nil)
end

local function ShouldLog(level, tag, minLevelOverride)
    local minLevel = internal.settings.minLogLevel
    if minLevelOverride ~= nil then minLevel = minLevelOverride end
    local LOG_LEVEL_TO_NUMBER = internal.LOG_LEVEL_TO_NUMBER
    if
        not LOG_LEVEL_TO_NUMBER[level]
        or not LOG_LEVEL_TO_NUMBER[minLevel]
        or LOG_LEVEL_TO_NUMBER[level] < LOG_LEVEL_TO_NUMBER[minLevel]
        or (level == internal.LOG_LEVEL_VERBOSE and not internal.verboseWhitelist[tag])
    then
        return false
    end
    return true
end

local function TryLog(level, tag, message, stacktrace, errorCode)
    local handled, err = pcall(DoLog, level, tag, message, stacktrace, errorCode)

    if(not handled) then
        LogFallbackMessage(err)
    end
end

local function LogRaw(level, tag, message, stacktrace, errorCode)
    if(not ShouldLog(level, tag)) then return end
    TryLog(level, tag, message, stacktrace, errorCode)
end
internal.LogRaw = LogRaw

local function Log(level, config, ...)
    if(not ShouldLog(level, config.tag, config.minLevelOverride)) then return end

    local handled, message = pcall(PrepareMessage, ...)

    if(handled) then
        local stacktrace
        local shouldLogTraces = internal.settings.logTraces
        if config.logTracesOverride ~= nil then shouldLogTraces = config.logTracesOverride end
        if shouldLogTraces then
            stacktrace = traceback()
        end
        TryLog(level, config.tag, message, stacktrace)
    else
        LogFallbackMessage(message)
    end
end
internal.Log = Log

--- applies the settings that affect the buffer. Called once the saved settings are available.
function internal:InitializeLog()
    SetCapacity(internal.settings.maxEntries)
end
