-- SPDX-FileCopyrightText: 2026 PinkBanther
--
-- SPDX-License-Identifier: Artistic-2.0
--
-- Runs the same workload against two copies of the library and reports the heap each one holds.
-- Usage: lua test/memory_compare.lua <new dir> <old dir>

local newRoot = arg[1] or "."
local oldRoot = arg[2]

local function Measure(root, label, entries)
    local harness = assert(loadfile(newRoot .. "/test/harness.lua"))(root)
    collectgarbage("collect")
    local before = collectgarbage("count")

    local lib = harness.LoadLibrary()
    local internal = lib.internal
    if lib.SetMaxEntries then lib:SetMaxEntries(entries) end
    local log = lib:Create("SomeAddon/SomeFile")

    for i = 1, entries * 2 do -- twice the capacity, so the buffer wraps / the old log prunes
        harness.AdvanceGameTime(16)
        log:Info("a reasonably typical log message, iteration %d of the workload", i)
    end

    collectgarbage("collect")
    local after = collectgarbage("count")
    local held = internal.logCount or #internal.log
    print(string.format("%-28s %8.1f KB for %5d entries (%.0f B/entry)",
        label, after - before, held, (after - before) * 1024 / held))
    _G.LibDebugLogger = nil
    _G.LibDebugLoggerLog = nil
    _G.LibDebugLoggerSettings = nil
    collectgarbage("collect")
    return after - before
end

print("same workload, memory held afterwards:")
local new1000 = Measure(newRoot, "new (1000 entries)", 1000)
local new2000 = Measure(newRoot, "new (2000 entries)", 2000)
if oldRoot then
    local old = Measure(oldRoot, "original (10000 entries)", 10000)
    print("")
    print(string.format("original -> new default: %.1f KB -> %.1f KB  (%.1fx less)",
        old, new1000, old / new1000))
end
