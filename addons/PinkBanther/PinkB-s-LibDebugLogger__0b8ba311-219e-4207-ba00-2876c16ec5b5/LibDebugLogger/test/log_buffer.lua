-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Exercises the ring buffer: ordering, wrapping, duplicate merging, resizing and the
-- compatibility layer that other add-ons see. Run with: lua test/log_buffer.lua

local root = arg[1] or "."
local harness = assert(loadfile(root .. "/test/harness.lua"))(root)
local LoadLibrary, AdvanceGameTime = harness.LoadLibrary, harness.AdvanceGameTime

local failures = 0
local function check(name, condition, detail)
    if condition then
        print("  ok   " .. name)
    else
        failures = failures + 1
        print("  FAIL " .. name .. (detail and ("  -- " .. tostring(detail)) or ""))
    end
end

local lib = LoadLibrary()
local internal = lib.internal
internal.settings.minLogLevel = lib.LOG_LEVEL_VERBOSE
internal.verboseWhitelist["verbose"] = true

local function reset(capacity)
    lib:ClearLog()
    lib:SetMaxEntries(capacity or internal.DEFAULT_MAX_ENTRIES)
end

print("defaults")
check("default capacity is 1000", lib:GetMaxEntries() == 1000, lib:GetMaxEntries())
check("log starts empty", lib:GetNumEntries() == 0)
check("saved variable for the log is not used", rawget(_G, "LibDebugLoggerLog") == nil)

print("basic logging")
reset(100)
local log = lib:Create("Test")
log:Info("hello %s", "world")
check("one entry", lib:GetNumEntries() == 1)
local entry = lib:GetEntry(1)
check("message", entry[lib.ENTRY_MESSAGE_INDEX] == "hello world", entry[lib.ENTRY_MESSAGE_INDEX])
check("level", entry[lib.ENTRY_LEVEL_INDEX] == lib.LOG_LEVEL_INFO)
check("tag", entry[lib.ENTRY_TAG_INDEX] == "Test")
check("occurrences", entry[lib.ENTRY_OCCURENCES_INDEX] == 1)
check("timestamp is a number", type(entry[lib.ENTRY_TIME_INDEX]) == "number")
check("formatted time is derived", entry[lib.ENTRY_FORMATTED_TIME_INDEX]:match("^%d%d%d%d%-%d%d%-%d%d "),
    entry[lib.ENTRY_FORMATTED_TIME_INDEX])
check("no stack trace by default", entry[lib.ENTRY_STACK_INDEX] == nil)

print("level filter")
reset(100)
internal.settings.minLogLevel = lib.LOG_LEVEL_INFO
log:Debug("not kept")
check("debug below info is dropped", lib:GetNumEntries() == 0)
internal.settings.minLogLevel = lib.LOG_LEVEL_VERBOSE

print("ordering and wrapping")
reset(100)
for i = 1, 250 do
    AdvanceGameTime(1)
    log:Info("entry %d", i)
end
check("count is capped at capacity", lib:GetNumEntries() == 100, lib:GetNumEntries())
check("oldest kept entry is 151", lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX] == "entry 151",
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX])
check("newest entry is 250", lib:GetEntry(100)[lib.ENTRY_MESSAGE_INDEX] == "entry 250",
    lib:GetEntry(100)[lib.ENTRY_MESSAGE_INDEX])
check("index past the end is nil", lib:GetEntry(101) == nil)
check("index zero is nil", lib:GetEntry(0) == nil)
local snapshot = lib:GetLog()
check("snapshot length", #snapshot == 100, #snapshot)
check("snapshot is in order", snapshot[1][lib.ENTRY_MESSAGE_INDEX] == "entry 151"
    and snapshot[100][lib.ENTRY_MESSAGE_INDEX] == "entry 250")
check("snapshot entries are separate tables", snapshot[1] ~= snapshot[2])

print("duplicate merging")
reset(100)
for i = 1, 10 do
    AdvanceGameTime(1)
    log:Info("same message")
end
check("repeated message stays one entry", lib:GetNumEntries() == 1, lib:GetNumEntries())
check("occurrences counted", lib:GetEntry(1)[lib.ENTRY_OCCURENCES_INDEX] == 10,
    lib:GetEntry(1)[lib.ENTRY_OCCURENCES_INDEX])

reset(100)
for i = 1, 10 do
    AdvanceGameTime(1)
    log:Info("ping")
    log:Info("pong")
end
check("alternating messages stay two entries", lib:GetNumEntries() == 2, lib:GetNumEntries())
check("ping counted", lib:GetEntry(1)[lib.ENTRY_OCCURENCES_INDEX] == 10)
check("pong counted", lib:GetEntry(2)[lib.ENTRY_OCCURENCES_INDEX] == 10)

reset(100)
for i = 1, 20 do
    AdvanceGameTime(1)
    log:Info("rotating %d", i % 8) -- more distinct messages than the lookback window
end
check("beyond the lookback a new entry is added", lib:GetNumEntries() > 8, lib:GetNumEntries())

print("different tags are not merged")
reset(100)
local other = lib:Create("Other")
log:Info("shared")
other:Info("shared")
check("two entries for two tags", lib:GetNumEntries() == 2, lib:GetNumEntries())

print("truncation")
reset(100)
log:Info(string.rep("x", internal.MAX_MESSAGE_LENGTH * 2))
local truncated = lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX]
check("long message is truncated", #truncated < internal.MAX_MESSAGE_LENGTH + 32, #truncated)
check("truncation is marked", truncated:find("truncated", 1, true) ~= nil)

print("resizing")
reset(500)
for i = 1, 500 do
    AdvanceGameTime(1)
    log:Info("entry %d", i)
end
lib:SetMaxEntries(100)
check("shrink keeps the newest", lib:GetNumEntries() == 100 and
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX] == "entry 401" and
    lib:GetEntry(100)[lib.ENTRY_MESSAGE_INDEX] == "entry 500",
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX])
lib:SetMaxEntries(300)
check("grow keeps what was left", lib:GetNumEntries() == 100 and
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX] == "entry 401")
AdvanceGameTime(1)
log:Info("after resize")
check("writing after a resize works", lib:GetEntry(101)[lib.ENTRY_MESSAGE_INDEX] == "after resize")
lib:SetMaxEntries(1)
check("capacity is clamped to the minimum", lib:GetMaxEntries() == internal.MIN_MAX_ENTRIES,
    lib:GetMaxEntries())
lib:SetMaxEntries(1000000)
check("capacity is clamped to the maximum", lib:GetMaxEntries() == internal.MAX_MAX_ENTRIES,
    lib:GetMaxEntries())

print("shrinking a buffer that has already wrapped")
reset(100)
for i = 1, 250 do
    AdvanceGameTime(1)
    log:Info("wrap %d", i)
end
lib:SetMaxEntries(150) -- grow from a wrapped buffer, the copy has to start at logStart
check("grow from a wrapped buffer keeps order", lib:GetNumEntries() == 100 and
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX] == "wrap 151" and
    lib:GetEntry(100)[lib.ENTRY_MESSAGE_INDEX] == "wrap 250",
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX])
for i = 251, 400 do
    AdvanceGameTime(1)
    log:Info("wrap %d", i)
end
check("still capped at the new size", lib:GetNumEntries() == 150, lib:GetNumEntries())
check("oldest is 251", lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX] == "wrap 251",
    lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX])

print("clearing")
reset(100)
log:Info("something")
local cleared = false
lib:RegisterCallback(lib.callback.LOG_CLEARED, function() cleared = true end)
lib:ClearLog()
check("log is empty", lib:GetNumEntries() == 0)
check("clear callback fired", cleared)
check("snapshot of an empty log", #lib:GetLog() == 0)
AdvanceGameTime(1)
log:Info("after clear")
check("logging works after clear", lib:GetEntry(1)[lib.ENTRY_MESSAGE_INDEX] == "after clear")

print("callbacks")
reset(100)
local added, lastMessage, lastDuplicate = 0, nil, nil
lib:RegisterCallback(lib.callback.LOG_ADDED, function(entry, wasDuplicate)
    added = added + 1
    lastMessage = entry[lib.ENTRY_MESSAGE_INDEX]
    lastDuplicate = wasDuplicate
end)
AdvanceGameTime(1)
log:Info("callback test")
check("LOG_ADDED fired", added == 1 and lastMessage == "callback test" and lastDuplicate == false,
    tostring(added) .. " " .. tostring(lastMessage))
AdvanceGameTime(1)
log:Info("callback test")
check("LOG_ADDED reports duplicates", added == 2 and lastDuplicate == true)

local pruned = 0
lib:RegisterCallback(lib.callback.LOG_PRUNED, function() pruned = pruned + 1 end)
reset(100)
for i = 1, 130 do
    AdvanceGameTime(1)
    log:Info("prune %d", i)
end
check("LOG_PRUNED fired once per dropped entry", pruned == 30, pruned)

print("logger options")
reset(100)
local quiet = lib:Create("Quiet")
quiet:SetEnabled(false)
quiet:Info("ignored")
check("disabled logger logs nothing", lib:GetNumEntries() == 0)
quiet:SetEnabled(true)
quiet:SetMinLevelOverride(lib.LOG_LEVEL_ERROR)
quiet:Info("below override")
check("min level override is honoured", lib:GetNumEntries() == 0)
quiet:Error("at override")
check("override lets errors through", lib:GetNumEntries() == 1)
local sub = log:Create("Sub")
AdvanceGameTime(1)
sub:Info("sub")
check("sub logger tag", lib:GetEntry(2)[lib.ENTRY_TAG_INDEX] == "Test/Sub",
    lib:GetEntry(2)[lib.ENTRY_TAG_INDEX])

print("stack traces")
reset(100)
lib:SetTraceLoggingEnabled(true)
AdvanceGameTime(1)
log:Info("with trace")
check("trace is stored", type(lib:GetEntry(1)[lib.ENTRY_STACK_INDEX]) == "string")
lib:SetTraceLoggingEnabled(false)

print("bad input does not throw")
reset(100)
local ok = pcall(function()
    log:Info("%d", "not a number")
    log:Info(nil)
    log:Info({}, 1, true)
    log:Info()
end)
check("malformed calls are handled", ok and lib:GetNumEntries() > 0, lib:GetNumEntries())

print("memory estimate")
reset(1000)
for i = 1, 1000 do
    AdvanceGameTime(1)
    log:Info("a reasonably typical log message number %d", i)
end
local bytes = lib:GetEstimatedMemoryUsage()
print(string.format("  1000 entries -> %.1f KB estimated (%.0f B/entry)", bytes / 1024, bytes / 1000))

print("")
if failures == 0 then
    print("all checks passed")
else
    print(failures .. " check(s) failed")
    os.exit(1)
end
