BGMeter = BGMeter or {}
local BGMeter = BGMeter

local Diag = { on = false }

local now = GetGameTimeMilliseconds
local gcc = collectgarbage

local STALL_MS = 1000

local probes, plist = {}, {}
local frame = { n = 0, ms = 0, max = 0, maxAt = 0, b8 = 0, b16 = 0, b25 = 0, b33 = 0, bx = 0, last = 0,
                stalls = 0, stallMs = 0, stallMax = 0 }
local heap = { cur = 0, min = math.huge, max = 0, alloc = 0, cycles = 0, last = 0 }
local gp = { active = false, result = nil }
local armedAt = 0

local function probe(name)
    local p = probes[name]
    if not p then
        p = { name = name, calls = 0, ms = 0, maxMs = 0, kb = 0, maxKb = 0, gc = 0 }
        probes[name] = p
        plist[#plist + 1] = p
    end
    return p
end

local function wrap_fn(fn, p)
    return function(...)
        local k0 = gcc("count")
        local t0 = now()
        local r1, r2, r3, r4 = fn(...)
        local dt = now() - t0
        local dk = gcc("count") - k0
        p.calls = p.calls + 1
        p.ms = p.ms + dt
        if dt > p.maxMs then p.maxMs = dt end
        if dk >= 0 then
            p.kb = p.kb + dk
            if dk > p.maxKb then p.maxKb = dk end
        else
            p.gc = p.gc + 1
        end
        return r1, r2, r3, r4
    end
end

local function on_frame()
    local t = now()
    local last = frame.last
    frame.last = t
    if last == 0 then return end
    local dt = t - last
    if dt > STALL_MS then
        frame.stalls = frame.stalls + 1
        frame.stallMs = frame.stallMs + dt
        if dt > frame.stallMax then frame.stallMax = dt end
    else
        frame.n = frame.n + 1
        frame.ms = frame.ms + dt
        if dt > frame.max then frame.max = dt; frame.maxAt = t - armedAt end
        if dt <= 8 then frame.b8 = frame.b8 + 1
        elseif dt <= 16 then frame.b16 = frame.b16 + 1
        elseif dt <= 25 then frame.b25 = frame.b25 + 1
        elseif dt <= 33 then frame.b33 = frame.b33 + 1
        else frame.bx = frame.bx + 1 end
    end

    if gp.active then
        local kb = gcc("count")
        local d = kb - gp.last
        gp.last = kb
        gp.frames = gp.frames + 1
        if d >= 0 then
            gp.kb = gp.kb + d
            if d > gp.maxKb then gp.maxKb = d end
        else
            gp.cycles = gp.cycles + 1
        end
        if t >= gp.tEnd then
            gp.active = false
            local secs = (t - gp.t0) / 1000
            gp.result = string.format(
                "gcprobe: %.1f KB alloc in %.1fs over %d frames  ·  %.0f B/frame  ·  %.1f KB/s  ·  %d GC cycles  ·  worst frame %.1f KB",
                gp.kb, secs, gp.frames,
                gp.frames > 0 and (gp.kb * 1024 / gp.frames) or 0,
                secs > 0 and (gp.kb / secs) or 0,
                gp.cycles, gp.maxKb)
            BGMeter.Log.say(gp.result)
        end
    end
end

local function on_heap()
    local kb = gcc("count")
    if heap.last > 0 then
        local d = kb - heap.last
        if d >= 0 then heap.alloc = heap.alloc + d else heap.cycles = heap.cycles + 1 end
    end
    heap.last = kb
    heap.cur = kb
    if kb < heap.min then heap.min = kb end
    if kb > heap.max then heap.max = kb end
end

function Diag.gcprobe(sec)
    if not Diag.on then return end
    sec = sec or 10
    gp.active = true
    gp.t0 = now()
    gp.tEnd = gp.t0 + sec * 1000
    gp.frames, gp.kb, gp.cycles, gp.maxKb = 0, 0, 0, 0
    gp.last = gcc("count")
    BGMeter.Log.say("gcprobe armed for %ds -- play normally, result prints when done", sec)
end

function Diag.reset()
    for i = 1, #plist do
        local p = plist[i]
        p.calls, p.ms, p.maxMs, p.kb, p.maxKb, p.gc = 0, 0, 0, 0, 0, 0
    end
    frame.n, frame.ms, frame.max, frame.maxAt = 0, 0, 0, 0
    frame.b8, frame.b16, frame.b25, frame.b33, frame.bx, frame.last = 0, 0, 0, 0, 0, 0
    frame.stalls, frame.stallMs, frame.stallMax = 0, 0, 0
    heap.min, heap.max, heap.alloc, heap.cycles, heap.last = math.huge, 0, 0, 0, 0
    gp.result = nil
    armedAt = now()
end

function Diag.lines()
    local F = BGMeter.Format
    local L = {}
    local function add(fmt, ...)
        if select("#", ...) > 0 then L[#L + 1] = string.format(fmt, ...)
        else L[#L + 1] = fmt end
    end

    add("--- diag layer (dev build)  ·  armed %s ago ---", F.duration(now() - armedAt))

    if frame.n > 0 then
        local avg = frame.ms / frame.n
        add("frames: %d sampled  ·  avg %.1fms (%.0f fps)  ·  worst %dms at %s",
            frame.n, avg, avg > 0 and (1000 / avg) or 0, frame.max, F.duration(frame.maxAt))
        add("  histogram: <=8ms %d%%  ·  <=16ms %d%%  ·  <=25ms %d%%  ·  <=33ms %d%%  ·  >33ms %d (%d%%)",
            math.floor(frame.b8 / frame.n * 100 + 0.5),
            math.floor(frame.b16 / frame.n * 100 + 0.5),
            math.floor(frame.b25 / frame.n * 100 + 0.5),
            math.floor(frame.b33 / frame.n * 100 + 0.5),
            frame.bx, math.floor(frame.bx / frame.n * 100 + 0.5))
        if frame.stalls > 0 then
            add("  stalls >%ds (loading screens etc, excluded above): %d  ·  worst %.1fs",
                math.floor(STALL_MS / 1000), frame.stalls, frame.stallMax / 1000)
        end
    else
        add("frames: (no samples yet)")
    end

    add("heap: %.0f KB now  ·  min %.0f  max %.0f  ·  +%.0f KB churned  ·  %d GC cycles seen",
        heap.cur, heap.min == math.huge and 0 or heap.min, heap.max, heap.alloc, heap.cycles)

    if gp.result then add(gp.result) end
    if gp.active then add("gcprobe: RUNNING") end

    local sorted = {}
    for i = 1, #plist do sorted[i] = plist[i] end
    table.sort(sorted, function(a, b) return a.kb > b.kb end)
    add("probes (calls / alloc total / avg-per-call / WORST call / time total / worst ms / gc-during):")
    local shown = 0
    for i = 1, #sorted do
        local p = sorted[i]
        if p.calls > 0 then
            shown = shown + 1
            add("  %-24s %6d  %8.1f KB  %6.0f B  %7.1f KB  %5dms  %3dms  %d",
                p.name, p.calls, p.kb, p.kb * 1024 / p.calls, p.maxKb, p.ms, p.maxMs, p.gc)
        end
    end
    if shown == 0 then add("  (no probe has fired yet)") end
    return L
end

function Diag.install()
    if Diag.on then return end
    local K = BGMeter.Constants
    if not (K and K.dev_tools and K.dev_tools()) then return end
    Diag.on = true
    armedAt = now()

    local E = BGMeter.zenimax.events
    local reg, regu = E.register, E.register_update
    E.register = function(name, code, handler)
        return reg(name, code, wrap_fn(handler, probe("ev:" .. name)))
    end
    E.register_update = function(name, ms, handler)
        return regu(name, ms, wrap_fn(handler, probe("up:" .. name)))
    end

    local W = BGMeter.UI and BGMeter.UI.window
    if W then
        local keys = { "render", "render_detail", "show_match" }
        for i = 1, #keys do
            local k = keys[i]
            if type(W[k]) == "function" then W[k] = wrap_fn(W[k], probe("ui:" .. k)) end
        end
        if type(W._sections) == "table" then
            for k, fn in pairs(W._sections) do
                if type(fn) == "function" then
                    W._sections[k] = wrap_fn(fn, probe("sec:" .. k))
                end
            end
        end
    end

    local Cap = BGMeter.Capture
    if Cap then
        local keys = { "begin", "rescan", "read_battle", "finalize" }
        for i = 1, #keys do
            local k = keys[i]
            if type(Cap[k]) == "function" then Cap[k] = wrap_fn(Cap[k], probe("cap:" .. k)) end
        end
    end

    regu("BGMeterDiagFrame", 0, on_frame)
    regu("BGMeterDiagHeap", 1000, on_heap)

    BGMeter.Log.debug("diag layer armed (frame + heap samplers, event/update/render/capture probes)")
end

BGMeter.Diag = Diag
