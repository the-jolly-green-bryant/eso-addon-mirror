-- SPDX-FileCopyrightText: 2025 sirinsidiator
-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Modified version: the log is kept in a fixed size ring buffer and is no longer written to
-- saved variables. See LogHandler.lua for the storage layout.

local lib = LibDebugLogger
local internal = lib.internal

internal.TAG_INGAME = "UI"

internal.LOG_LEVEL_VERBOSE = "V"
internal.LOG_LEVEL_DEBUG = "D"
internal.LOG_LEVEL_INFO = "I"
internal.LOG_LEVEL_WARNING = "W"
internal.LOG_LEVEL_ERROR = "E"

-- how many entries the ring buffer holds. Every entry costs one slot per field (16 bytes each on
-- a 64 bit client) plus the message itself, so this number is the whole memory budget of the log.
internal.DEFAULT_MAX_ENTRIES = 1000
internal.MIN_MAX_ENTRIES = 100
internal.MAX_MAX_ENTRIES = 10000

-- a single runaway message must not be able to eat the whole heap
internal.MAX_MESSAGE_LENGTH = 4000
internal.MAX_STACK_LENGTH = 4000

-- how far back we look for an identical message before adding a new entry. Messages that alternate
-- (two addons spamming in turn) are the usual reason for a log that fills up within minutes.
internal.DUPLICATE_LOOKBACK = 4

-- layout of one entry inside the flat ring buffer. These are internal and unrelated to the
-- public ENTRY_*_INDEX constants below, which describe the compatibility tables handed out by
-- GetLog() and the LOG_ADDED callback.
internal.SLOT_TIME = 1
internal.SLOT_OCCURENCES = 2
internal.SLOT_LEVEL = 3
internal.SLOT_TAG = 4
internal.SLOT_MESSAGE = 5
internal.SLOT_STACK = 6
internal.SLOT_ERROR_CODE = 7
internal.SLOT_STRIDE = 7

internal.ENTRY_TIME_INDEX = 1
internal.ENTRY_FORMATTED_TIME_INDEX = 2
internal.ENTRY_OCCURENCES_INDEX = 3
internal.ENTRY_LEVEL_INDEX = 4
internal.ENTRY_TAG_INDEX = 5
internal.ENTRY_MESSAGE_INDEX = 6
internal.ENTRY_STACK_INDEX = 7
internal.ENTRY_ERROR_CODE_INDEX = 8

internal.LOG_LEVELS = {
    internal.LOG_LEVEL_VERBOSE,
    internal.LOG_LEVEL_DEBUG,
    internal.LOG_LEVEL_INFO,
    internal.LOG_LEVEL_WARNING,
    internal.LOG_LEVEL_ERROR,
}

internal.LOG_LEVEL_TO_NUMBER = {
    [internal.LOG_LEVEL_VERBOSE] = 0,
    [internal.LOG_LEVEL_DEBUG] = 1,
    [internal.LOG_LEVEL_INFO] = 2,
    [internal.LOG_LEVEL_WARNING] = 3,
    [internal.LOG_LEVEL_ERROR] = 4,
}

internal.LOG_LEVEL_TO_STRING = {
    [internal.LOG_LEVEL_VERBOSE] = "verbose",
    [internal.LOG_LEVEL_DEBUG] = "debug",
    [internal.LOG_LEVEL_INFO] = "info",
    [internal.LOG_LEVEL_WARNING] =  "warning",
    [internal.LOG_LEVEL_ERROR] = "error",
}

internal.STR_TO_LOG_LEVEL = {}
for level, str in pairs(internal.LOG_LEVEL_TO_STRING) do
    internal.STR_TO_LOG_LEVEL[str] = level
    internal.STR_TO_LOG_LEVEL[level:lower()] = level
end
