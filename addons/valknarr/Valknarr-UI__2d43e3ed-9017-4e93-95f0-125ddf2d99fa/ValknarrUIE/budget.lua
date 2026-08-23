-- Console budget instrumentation.
--
-- PROJECT.md and docs/CONSOLE_CONSTRAINTS.md treat the 100 MB add-on memory
-- ceiling and the shared 1-second frame budget as hard limits, but nothing
-- measured them. Exceeding memory disables every add-on the player has
-- installed, so "probably fine" is not good enough. This module is what
-- /uiedit budget and /uiedit diag report from.
--
-- Deliberately cheap: no per-frame allocation, and every engine call is
-- guarded because these APIs are not all present outside the game.

ValknarrUIEBudget = ValknarrUIEBudget or {}

local Budget = ValknarrUIEBudget

-- Depth cap: our control trees are shallow, and this stops a cycle or an
-- unexpected native parent from turning diagnostics into a hang.
local MAX_TREE_DEPTH = 8
local SLOW_POLL_MS = 4
local VERY_SLOW_POLL_MS = 16

-- Top-level controls this add-on creates. Everything else it owns is a child
-- of one of these.
local OUR_ROOTS = {
    "ValknarrUIERoot",
    "ValknarrUIELogHud",
    "ValknarrUIESettingsRoot",
}

function Budget:Reset()
    self.frames = 0
    self.poll = { samples = 0, totalMs = 0, maxMs = 0, slow = 0, verySlow = 0 }
end

Budget:Reset()

function Budget:Now()
    if type(GetGameTimeMilliseconds) ~= "function" then
        return nil
    end
    local ok, value = pcall(GetGameTimeMilliseconds)
    if ok and type(value) == "number" then
        return value
    end
    return nil
end

-- Whole-VM Lua heap, which is the right number to watch: the console limit is
-- shared across every installed add-on, not per add-on.
function Budget:LuaHeapKB()
    if type(collectgarbage) ~= "function" then
        return nil
    end
    local ok, kb = pcall(collectgarbage, "count")
    if ok and type(kb) == "number" then
        return kb
    end
    return nil
end

local function CountTree(control, depth)
    if not control or depth > MAX_TREE_DEPTH then
        return 0
    end
    local total = 1
    if type(control.GetNumChildren) ~= "function" or type(control.GetChild) ~= "function" then
        return total
    end
    local ok, count = pcall(control.GetNumChildren, control)
    if not ok or type(count) ~= "number" then
        return total
    end
    for index = 1, count do
        local childOk, child = pcall(control.GetChild, control, index)
        if childOk and child then
            total = total + CountTree(child, depth + 1)
        end
    end
    return total
end

function Budget:CountControls()
    local total = 0
    local perRoot = {}
    for index = 1, #OUR_ROOTS do
        local name = OUR_ROOTS[index]
        local control = _G[name]
        local count = 0
        if control then
            count = CountTree(control, 1)
        end
        perRoot[name] = count
        total = total + count
    end
    return total, perRoot
end

function Budget:CountFrame()
    self.frames = (self.frames or 0) + 1
end

-- Editor poll timing. GetGameTimeMilliseconds has 1 ms resolution, so this
-- surfaces spikes and the slow-poll counts rather than a precise average of
-- sub-millisecond work.
function Budget:RecordPoll(startMs)
    if type(startMs) ~= "number" then
        return
    end
    local endMs = self:Now()
    if type(endMs) ~= "number" then
        return
    end
    local elapsed = endMs - startMs
    if elapsed < 0 then
        return
    end
    local poll = self.poll
    poll.samples = poll.samples + 1
    poll.totalMs = poll.totalMs + elapsed
    if elapsed > poll.maxMs then
        poll.maxMs = elapsed
    end
    if elapsed >= VERY_SLOW_POLL_MS then
        poll.verySlow = poll.verySlow + 1
    elseif elapsed >= SLOW_POLL_MS then
        poll.slow = poll.slow + 1
    end
end

function Budget:PollAverageMs()
    local poll = self.poll or {}
    if (poll.samples or 0) <= 0 then
        return nil
    end
    return poll.totalMs / poll.samples
end

function Budget:Describe()
    local total, perRoot = self:CountControls()
    local poll = self.poll or {}
    local result = {
        luaHeapKB = self:LuaHeapKB(),
        controlsTotal = total,
        editorFrames = self.frames or 0,
        pollSamples = poll.samples or 0,
        pollMaxMs = poll.maxMs or 0,
        pollOver4ms = poll.slow or 0,
        pollOver16ms = poll.verySlow or 0,
        pollAvgMs = self:PollAverageMs(),
    }
    for name, count in pairs(perRoot) do
        result["controls_" .. name] = count
    end
    return result
end

-- Player-facing lines. Uses Log:Always so the report still appears with
-- "Show debug logs" off, which is the default a console tester will be on.
function Budget:Report(Log)
    if not Log then
        return
    end
    local info = self:Describe()
    Log:Always("Valknarr UI budget")
    if info.luaHeapKB then
        Log:Always(string.format(
            "  Lua heap (all add-ons): %.0f KB of the shared 100 MB console limit",
            info.luaHeapKB
        ))
    else
        Log:Always("  Lua heap: unavailable on this client")
    end
    Log:Always(string.format("  controls created by Valknarr UI: %d", info.controlsTotal))
    if info.pollSamples > 0 then
        Log:Always(string.format(
            "  editor poll: %d samples, avg %.1f ms, max %.0f ms",
            info.pollSamples,
            info.pollAvgMs or 0,
            info.pollMaxMs
        ))
        Log:Always(string.format(
            "  slow polls: %d over 4 ms, %d over 16 ms (frames ticked: %d)",
            info.pollOver4ms,
            info.pollOver16ms,
            info.editorFrames
        ))
    else
        Log:Always("  editor poll: no samples yet — open /uiedit and move a piece first")
    end
end

return Budget
