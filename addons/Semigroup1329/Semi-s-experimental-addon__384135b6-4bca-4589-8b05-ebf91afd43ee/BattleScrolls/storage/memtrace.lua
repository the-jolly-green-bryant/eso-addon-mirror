-- Startup memory timeline for the console memory investigation.
-- This is the first manifest entry, so its "first" sample precedes every other
-- Battle Scrolls file, before the access check exists. It records two numbers
-- and defines one sampler; it has no strings, events, settings or history use.
-- storage/memtrace_end.lua takes the "code" sample as the last manifest entry.
-- /bsmemlab load reports both alongside its own SavedVariables-loaded sample.
BattleScrolls = BattleScrolls or {}

local MIB = 1024 * 1024
-- Research build switch: collect at every manifest boundary so the trace
-- report separates each group's retained cost from its load-time garbage.
-- Off in the measurement build: only the eager collection in
-- storage/memtrace_end.lua runs, so its effect is measured on its own.
local TRACE_GC = false

---@class MemTraceSample
---@field gauge number Add-on pool gauge in MiB; 0 where the API is absent
---@field heap number Whole-VM Lua heap in MiB

---@class MemTrace
---@field samples table<string, MemTraceSample> Keyed by manifest position name
---@field order string[] Sample names in first-recording order
local trace = { samples = {}, order = {} }
BattleScrolls.memTrace = trace

---Records the current counters under a name; later samples with the same
---name overwrite earlier ones, so callers use distinct manifest positions.
---@param name string
function trace.sample(name)
    if not trace.samples[name] then trace.order[#trace.order + 1] = name end
    trace.samples[name] = {
        gauge = GetTotalUserAddOnMemoryPoolUsageMB and GetTotalUserAddOnMemoryPoolUsageMB() or 0,
        heap = collectgarbage("count") * 1024 / MIB,
    }
end

---Records a manifest-group boundary. In a TRACE_GC build it then runs a full
---collection and records the same name with a "+" suffix, so the pair shows
---the group's garbage (before) and retained cost (after).
---@param name string
function trace.boundary(name)
    trace.sample(name)
    if TRACE_GC then
        collectgarbage("collect")
        trace.sample(name .. "+")
    end
end

trace.boundary("first")
