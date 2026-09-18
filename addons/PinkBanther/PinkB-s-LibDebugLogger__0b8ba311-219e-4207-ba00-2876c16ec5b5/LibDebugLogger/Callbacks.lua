-- SPDX-FileCopyrightText: 2025 sirinsidiator
-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Modified version by PinkBanther: see LogHandler.lua

local lib = LibDebugLogger
local callback = lib.callback

--- This callback is fired when the log is wiped by the user or an addon.
--- @param log - an empty table. The log itself is a ring buffer and is not handed out directly.
callback.LOG_CLEARED = "LogCleared"

--- This callback is fired whenever the oldest entry is overwritten because the log is full.
--- @param startIndex - always 2, meaning the entry that used to be second is now the first one.
--- Kept for compatibility with the previous block-wise pruning.
callback.LOG_PRUNED = "LogPruned"

--- This callback is fired whenever a new message is logged.
--- @param entry - a table with the data of the entry that was just written.
--- Can either use unpack to assign it to local variables:
--- local time, formattedTime, count, level, tag, message, trace = unpack(entry)
--- or use the lib.ENTRY_*_INDEX constants to access individual values directly:
--- local message = entry[lib.ENTRY_MESSAGE_INDEX]
--- IMPORTANT: this table is reused for every call, so copy out what you need instead of keeping
--- a reference to it. Building a fresh table per entry is what made the old log expensive.
--- @param wasDuplicate - true if the same message was logged more than once.
--- In which case only the time is updated and the occurrences count increased by one.
--- A message counts as a duplicate when it matches any of the last few entries, not just the
--- entry right before it.
callback.LOG_ADDED = "LogAdded"
