
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Bench = {}
local M = Verditer.Bench

local NOOP = function() end
M.stress_fill   = NOOP
M.stress_events = NOOP
M.alloc_probe   = function() d("[allocprobe] disabled (DEBUG=false)") end
M.run           = function() d("[bench] disabled (DEBUG=false)") end

if not Verditer.Constants.DEBUG then return end

-- ── below this line only parses / runs when DEBUG=true ────────────────────────
--! "You shall not pass!!!"

local api            = Verditer.zenimax.api
local now_ms         = api.GetGameTimeMilliseconds
local d              = d
local ipairs         = ipairs
local collectgarbage = collectgarbage
local math_sin       = math.sin
local math_floor     = math.floor
local math_max       = math.max
local string_format  = string.format
local table_concat   = table.concat


local SAMPLE_MS      = 100   -- spacing between fabricated samples (cosmetic; render ignores it)
local TYPE_BUCKETS   = 8     -- max damage-type groups per sample
local SOURCE_BUCKETS = 8     -- max attacker groups per sample (top-7 + Other)
local REPS           = 20    -- render repetitions per view for stable percentiles

local SAFETY_MAX_SAMPLES = 20000   -- well above any real config (10Hz×10min = 6000)

-- worst-case group scratch, built ONCE and reused (push copies out of it, so the
-- same shape on every sample = max stacked-segment count = heaviest render).
local function build_groups(n, with_src)
  local g = { count = n }
  local share = 1.0 / n
  for i = 1, n do
    g[i] = {
      r = (i * 37 % 100) / 100, g = (i * 71 % 100) / 100, b = (i * 113 % 100) / 100, a = 0.9,
      share = share,
      dt   = i,
      uid  = with_src and (1000 + i) or nil,
      name = with_src and ("Mock Attacker " .. i) or nil,
    }
  end
  return g
end
local TYPE_SCRATCH   = build_groups(TYPE_BUCKETS,   false)
local SOURCE_SCRATCH = build_groups(SOURCE_BUCKETS, true)

local MOCK_NAMES = {}
for i = 0, SOURCE_BUCKETS do MOCK_NAMES[i] = "Mock " .. i end

local function synth_dtps(i) return 8000 + 4000 * math_sin(i * 0.30) + ((i % 17 == 0) and 60000 or 0) end
local function synth_abs(i)  return 3000 + 2500 * math_sin(i * 0.21) + ((i % 23 == 0) and 30000 or 0) end
local function synth_hp(i)   return 1.0 - (i % 50) / 50 end

function M.stress_fill(count)
  local TB  = Verditer.TemporalBuffer
  local cap = TB.capacity()
  count = count or cap
  if count > cap then count = cap end
  if count < 1 then count = 1 end
  TB.clear()
  local t0   = now_ms()
  local prev = -1
  for i = 1, count do
    local hp   = synth_hp(i)
    local drop = (prev >= 0) and math_max(0, prev - hp) or 0
    prev = hp
    TB.push(t0 + i * SAMPLE_MS, synth_dtps(i), synth_abs(i), TYPE_SCRATCH, hp, drop, SOURCE_SCRATCH)
  end
  d(string_format("[bench] stress_fill: %d/%d samples (worst case: %d type + %d source groups each)",
                  count, cap, TYPE_BUCKETS, SOURCE_BUCKETS))
  return count
end

function M.stress_events(n)
  n = n or 5000
  local Pipeline = Verditer.Pipeline
  local RESULT   = ACTION_RESULT_DAMAGE
  for i = 1, n do
    local hit  = 2000 + (i % 50) * 300 + ((i % 19 == 0) and 40000 or 0)
    local bkt  = i % SOURCE_BUCKETS
    local uid  = 1000 + bkt
    local dt   = 1 + (i % TYPE_BUCKETS)
    Pipeline.dispatch_dmg_in(RESULT, false, nil, nil, nil,
      MOCK_NAMES[bkt], nil, nil, nil, hit,
      nil, dt, nil, uid, nil, 10000 + dt, 0)
    if i % 7 == 0 then
      Pipeline.dispatch_abs_in(RESULT, false, nil, nil, nil,
        MOCK_NAMES[bkt], nil, nil, nil, 1500,
        nil, dt, nil, uid, 20000 + dt)
    end
  end
  d(string_format("[bench] stress_events: injected %d dmg_in (+%d abs_in) through the pipeline. See /verditer prof.",
                  n, math_floor(n / 7)))
end

local ALLOC_PROBE_N    = 20
local ALLOC_PROBE_WARM = 4

function M.alloc_probe(n)
  n = n or ALLOC_PROBE_N
  if n > 30 then n = 30 elseif n < 5 then n = 5 end   -- hard clamp: renders are expensive
  local TB    = Verditer.TemporalBuffer
  local Graph = Verditer.Graph
  if TB.is_recording() then d("[allocprobe] press Stop first."); return end
  if not Graph.bench_ensure_open() then d("[allocprobe] open the graph first."); return end
  local cw = Graph.bench_canvas()
  if (cw or 0) <= 4 then d("[allocprobe] canvas not laid out; make the graph visible, then re-run."); return end

  local cap = TB.capacity()
  if cap > SAFETY_MAX_SAMPLES then
    d(string_format("[allocprobe] capacity=%d absurdly large for N renders; lower the sliders.", cap))
    return
  end

  local filled = M.stress_fill()
  local labels, vmin, vmax = Graph.bench_views()
  local lines = {}
  local function L(s) lines[#lines + 1] = s; d("[allocprobe] " .. s) end

  L(string_format("=== Verditer allocprobe  N=%d  cap=%d  (double-collect, pools pre-warmed) ===", n, filled))
  for v = vmin, vmax do
    Graph.bench_set_view(v)
    for _ = 1, ALLOC_PROBE_WARM do Graph.bench_render_once() end   -- warm pools + hit index
    for _ = 1, 2 do collectgarbage("collect") end
    local before = collectgarbage("count")
    for _ = 1, n do Graph.bench_render_once() end
    local after = collectgarbage("count")
    local bytes = (after - before) * 1024 / n
    L(string_format("%-9s %10.2f bytes/render   (drawn=%d)", labels[v], bytes, Graph.bench_drawn()))
  end
  TB.clear(); Graph.bench_set_view(vmin)
  L("verdict: ~0 ⇒ Phase-A TYPE alloc was noise; nonzero ⇒ a real per-render alloc (F4).")
  L("(buffer cleared)")
  if Verditer.CopyBox then Verditer.CopyBox.show("Verditer allocprobe", table_concat(lines, "\n")) end
end

function M.run(label, force)
  label = label or "run"
  local TB    = Verditer.TemporalBuffer
  local Graph = Verditer.Graph
  local Prof  = Verditer.Profiler

  if TB.is_recording() then
    d("[bench] press Stop first — the bench measures the FROZEN render path.")
    return
  end
  if not Graph.bench_ensure_open() then
    d("[bench] open the graph first (/verditer graph), then re-run.")
    return
  end
  local cw, ch = Graph.bench_canvas()
  if (cw or 0) <= 4 then
    d("[bench] canvas not laid out yet (width=" .. tostring(cw) .. "). Make sure the graph window is visible, then re-run.")
    return
  end

  local cap = TB.capacity()
  if cap > SAFETY_MAX_SAMPLES and not force then
    d(string_format("[bench] ABORT: capacity=%d is absurdly large (fold/fill cost). Override: /verditer bench %s force", cap, label))
    return
  end

  local filled = M.stress_fill()
  local labels, vmin, vmax = Graph.bench_views()

  local human, rows = {}, {}
  local function H(s) human[#human + 1] = s end

  H(string_format("=== Verditer BENCH  run=%s ===", label))
  H(string_format("config: capacity=%d  filled=%d  reps/view=%d", cap, filled, REPS))
  H(string_format("canvas: %dx%d px   over-draw ratio = %.1f  (filled/px; >1 ⇒ drawing more bars than pixels)",
                  cw, ch, (cw > 0) and filled / cw or 0))
  H("")

  rows[#rows + 1] = "metric,view,value,unit"
  rows[#rows + 1] = string_format("capacity,ALL,%d,samples", cap)
  rows[#rows + 1] = string_format("filled,ALL,%d,samples", filled)
  rows[#rows + 1] = string_format("canvas_w,ALL,%d,px", cw)

  Prof.reset()
  for v = vmin, vmax do
    Graph.bench_set_view(v)
    for _ = 1, 2 do collectgarbage("collect") end
    local before = collectgarbage("count")
    for _ = 1, REPS do Graph.bench_render_once() end
    local after  = collectgarbage("count")
    local alloc_per = (after - before) * 1024 / REPS
    local drawn = Graph.bench_drawn()

    local r    = Prof.report()
    local zone = r["render." .. labels[v]]
    local p50  = zone and zone.p50    or 0
    local p95  = zone and zone.p95    or 0
    local mx   = zone and zone.max_ms or 0
    local cnt  = zone and zone.count  or 0

    H(string_format("%-9s render p50=%dms p95=%dms max=%dms (n=%d) | drawn=%d ctrls | alloc=%.1f B/render",
                    labels[v], p50, p95, mx, cnt, drawn, alloc_per))
    rows[#rows + 1] = string_format("render_p50,%s,%d,ms",       labels[v], p50)
    rows[#rows + 1] = string_format("render_p95,%s,%d,ms",       labels[v], p95)
    rows[#rows + 1] = string_format("render_max,%s,%d,ms",       labels[v], mx)
    rows[#rows + 1] = string_format("drawn,%s,%d,controls",      labels[v], drawn)
    rows[#rows + 1] = string_format("alloc_per_render,%s,%.1f,bytes", labels[v], alloc_per)
  end

  H("")
  H("read: drawn > canvas_w ⇒ over-draw (decimation target).  p95 > 12ms ⇒ render budget blown.")
  H("the LIVE lenses (fps, heap, pipeline timing) live in /verditer report — run it after a real fight.")
  H("")
  H("### BENCH-CSV run=" .. label)
  for _, row in ipairs(rows) do H(row) end

  TB.clear()
  Graph.bench_set_view(vmin)
  H("")
  H("(synthetic buffer cleared — /reloadui to release the controls the bench created)")

  local text = table_concat(human, "\n")
  if Verditer.CopyBox then Verditer.CopyBox.show("Verditer /bench " .. label, text) end
  for _, l in ipairs(human) do d(l) end
end
