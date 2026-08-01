
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Diagnostics = {}
local M = Verditer.Diagnostics

local NOOP = function() end
M.bump        = NOOP
M.get         = function() return 0 end
M.log_event   = NOOP
M.snapshot    = function() return {} end
M.print_diag  = function() d("[diag] disabled (DEBUG=false)") end
M.full_report = function() d("[report] disabled (DEBUG=false)") end
M.reset       = NOOP
M.init        = NOOP

if not Verditer.Constants.DEBUG then return end

-- ── below this line only parses / runs when DEBUG=true
--! "You shall not pass!!!"

local GetGameTimeMilliseconds = Verditer.zenimax.api.GetGameTimeMilliseconds
local GetFramerate = Verditer.zenimax.api.GetFramerate
local collectgarbage = collectgarbage
local d           = d
local pairs       = pairs
local tostring    = tostring
local math_min    = math.min
local math_max    = math.max
local table_sort  = table.sort

-- ── config
local EVENT_CAP   = 200
local TS_CAP      = 120
local TICK_MS     = 1000

-- ── state
local counters    = {}
local ev_buf      = {}
local ev_head     = 0
local ev_count    = 0
local ts_buf      = {}
local ts_head     = 0
local ts_count    = 0
local start_time  = 0

local fps_min     = 0
local fps_sum     = 0
local fps_count   = 0
local gc_base_kb  = 0     -- heap at last reset
local gc_peak_kb  = 0     -- max heap seen in the window

-- ── counters
function M.bump(key, n)
  counters[key] = (counters[key] or 0) + (n or 1)
end

function M.get(key)
  return counters[key] or 0
end

-- ── event log
function M.log_event(cat, payload)
  ev_head = (ev_head % EVENT_CAP) + 1
  ev_buf[ev_head] = { t = GetGameTimeMilliseconds(), cat = cat, p = payload }
  ev_count = ev_count + 1
end

-- ── timeseries
local function ts_sample()
  local now = GetGameTimeMilliseconds()
  local snap = {
    t       = now,
    damage  = counters["engine.dmg_in.accepted"] or 0,
    shield  = counters["engine.abs_in.accepted"] or 0,
    metric  = (function()
      if not Verditer.Metrics or not Verditer.Metrics.DTPS then return nil end
      local ok, dtps = pcall(Verditer.Metrics.DTPS, now)
      if not ok then return nil end
      local _, abs = pcall(Verditer.Metrics.ABS, now)
      dtps = dtps or 0
      abs  = abs  or 0
      return { DTPS = dtps, ABS = abs, ITP = dtps + abs }
    end)(),
  }
  ts_head = (ts_head % TS_CAP) + 1
  ts_buf[ts_head] = snap
  ts_count = ts_count + 1

  -- graphics lens: fps min/avg over the window
  if GetFramerate then
    local fps = GetFramerate() or 0
    if fps > 0 then
      if fps_count == 0 or fps < fps_min then fps_min = fps end
      fps_sum   = fps_sum + fps
      fps_count = fps_count + 1
    end
  end
  -- memory lens: heap watermark (KB). Net retention is gc_now - gc_base.
  local heap = collectgarbage("count")
  if heap > gc_peak_kb then gc_peak_kb = heap end
end

function M.snapshot()
  local events = {}
  if ev_count <= EVENT_CAP then
    for i = 1, ev_count do events[i] = ev_buf[i] end
  else
    local n = 0
    for i = 1, EVENT_CAP do
      local idx = (ev_head - 1 + i) % EVENT_CAP + 1
      n = n + 1
      events[n] = ev_buf[idx]
    end
  end

  local ts = {}
  local ts_len = math.min(ts_count, TS_CAP)
  if ts_count <= TS_CAP then
    for i = 1, ts_count do ts[i] = ts_buf[i] end
  else
    local n = 0
    for i = 1, TS_CAP do
      local idx = (ts_head - 1 + i) % TS_CAP + 1
      n = n + 1
      ts[n] = ts_buf[idx]
    end
  end

  local mode_snap    = Verditer.Mode    and Verditer.Mode.snapshot()          or {}
  local metrics_snap = (Verditer.Metrics and Verditer.Metrics.size_snapshot)
                       and Verditer.Metrics.size_snapshot() or {}

  return {
    start_time  = start_time,
    counters    = counters,
    events      = events,
    ev_total    = ev_count,
    timeseries  = ts,
    ts_total    = ts_count,
    mode        = mode_snap,
    metrics     = metrics_snap,
  }
end

local function build_diag_lines()
  local lines = {}
  lines[#lines+1] = "[diag] uptime=" .. (GetGameTimeMilliseconds() - start_time)
                    .. "ms  ev_total=" .. ev_count .. "  ts_samples=" .. ts_count

  -- perf lenses (live window): fps (graphics) + heap (memory)
  local fps_avg = (fps_count > 0) and (fps_sum / fps_count) or 0
  local heap_now = collectgarbage("count")
  lines[#lines+1] = string.format("[perf] fps min=%.1f avg=%.1f (n=%d)  |  heap now=%.0fKB peak=%.0fKB netΔ=%.0fKB (since reset)",
                    fps_min, fps_avg, fps_count, heap_now, gc_peak_kb, heap_now - gc_base_kb)
  lines[#lines+1] = "[diag] counters:"
  local keys = {}
  for k in pairs(counters) do keys[#keys+1] = k end
  table_sort(keys)
  for _, k in ipairs(keys) do
    lines[#lines+1] = "  " .. k .. " = " .. tostring(counters[k])
  end
  lines[#lines+1] = "[diag] last events (up to 10):"
  local n_show = math_min(ev_count, 10)
  local base   = math_min(ev_count, EVENT_CAP)
  for i = base - n_show + 1, base do
    local idx = (ev_head - base + i - 1 + EVENT_CAP) % EVENT_CAP + 1
    local e = ev_buf[idx]
    if e then
      lines[#lines+1] = "  t=" .. e.t .. " [" .. (e.cat or "?") .. "] " .. tostring(e.p)
    end
  end
  if Verditer.Mode then
    lines[#lines+1] = "[diag] mode=" .. tostring(Verditer.Mode.current())
  end
  if Verditer.Metrics and Verditer.Metrics.pool_capacity then
    lines[#lines+1] = "[diag] event_pool=" .. Verditer.Metrics.pool_in_use()
                      .. "/" .. Verditer.Metrics.pool_capacity()
  end
  if Verditer.Log and Verditer.Log.size then
    local cur, cap = Verditer.Log.size()
    lines[#lines+1] = "[diag] log_ring=" .. cur .. "/" .. cap
  end
  if Verditer.Validation and Verditer.Validation.run_all_checks then
    local v = Verditer.Validation.run_all_checks()
    lines[#lines+1] = "[diag] validation: failures=" .. v.failure_count
                      .. " pool_outstanding=" .. v.pool_outstanding
  end
  if Verditer.Profiler and Verditer.Profiler.report then
    local r, window_s = Verditer.Profiler.report()
    local stages = {}
    for k in pairs(r) do stages[#stages+1] = k end
    if #stages > 0 then
      lines[#lines+1] = "[diag] profiler window=" .. string.format("%.1fs", window_s)
                        .. " stages=" .. #stages .. " (use /Verditer prof for detail)"
    end
  end
  return lines
end

function M.print_diag()
  local lines = build_diag_lines()
  if Verditer.Constants.DEBUG and Verditer.CopyBox then
    Verditer.CopyBox.show("Verditer /diag", table.concat(lines, "\n"))
  else
    for _, line in ipairs(lines) do d(line) end
  end
end


function M.full_report(include_gc)
  if not Verditer.Constants.DEBUG then
    d("[report] disabled (DEBUG=false)")
    return
  end
  local out = {}
  local function section(title, lines)
    out[#out+1] = ""
    out[#out+1] = "═══ " .. title .. " ═══"
    for _, l in ipairs(lines) do out[#out+1] = l end
  end
  out[#out+1] = "Verditer full report — uptime "
                .. (GetGameTimeMilliseconds() - start_time) .. "ms"
  if Verditer.Settings and Verditer.Settings.report_lines then
    section("config", Verditer.Settings.report_lines())
  end
  section("diagnostics", build_diag_lines())
  if Verditer.Profiler and Verditer.Profiler.report_lines then
    section("profiler",   Verditer.Profiler.report_lines())
  end
  if Verditer.GC and Verditer.GC.report_lines then
    section("gc pacing",  Verditer.GC.report_lines())
  end
  if Verditer.Validation and Verditer.Validation.report_lines then
    section("validation", Verditer.Validation.report_lines())
  end
  if Verditer.SkillColors and Verditer.SkillColors.unknown_lines then
    section("unclassified abilities", Verditer.SkillColors.unknown_lines())
  end
  if Verditer.Probe and Verditer.Probe.suspects_report then
    section("source audit", { Verditer.Probe.suspects_report() })
  end
  if Verditer.Log and Verditer.Log.recent_lines then
    section("log (last 20)", Verditer.Log.recent_lines(20))
  end
  if include_gc and M.gc_probe_lines then
    section("gcprobe  (WARNING: this CLEARED the recording buffer)", M.gc_probe_lines())
  end
  if Verditer.CopyBox and Verditer.CopyBox.show then
    Verditer.CopyBox.show("Verditer /report", table.concat(out, "\n"))
  else
    for _, l in ipairs(out) do d(l) end
  end
end

-- ── reset
function M.reset()
  counters = {}
  ev_buf   = {}
  ev_head  = 0
  ev_count = 0
  ts_buf   = {}
  ts_head  = 0
  ts_count = 0
  fps_min   = 0
  fps_sum   = 0
  fps_count = 0
  gc_base_kb = collectgarbage("count")
  gc_peak_kb = gc_base_kb
  start_time = GetGameTimeMilliseconds()
end

-- ── init
function M.init()
  start_time = GetGameTimeMilliseconds()
  gc_base_kb = collectgarbage("count")
  gc_peak_kb = gc_base_kb
  Verditer.zenimax.events.register_update("Verditer_DiagTick", TICK_MS, ts_sample)
end

local gcprobe_scratch = { count = 0 }
local gcprobe_sink

function M.gc_probe_lines(n)
  n = n or 1000
  local Metrics = Verditer.Metrics
  local TB      = Verditer.TemporalBuffer
  local now     = GetGameTimeMilliseconds()


  local lines = {}
  local function emit(s) lines[#lines + 1] = s; d("[gcprobe] " .. s) end

  local function measure(label, body)
    for _ = 1, 64 do body() end
    for _ = 1, 2 do collectgarbage("collect") end
    local before = collectgarbage("count")
    for _ = 1, n do body() end
    local after  = collectgarbage("count")
    local bytes  = (after - before) * 1024 / n
    emit(string.format("%-26s %9.2f bytes/sample", label, bytes))
    return bytes
  end

  emit(string.format("=== Verditer gcprobe  N=%d  (ZOS double-collect) ===", n))
  measure("control (1 table/iter)", function()
    gcprobe_sink = { r = 0, g = 0, b = 0, a = 0, share = 0 }
  end)
  local dp = measure("data path (M1)", function()
    local dtps = Metrics.DTPS(now)
    local abs  = Metrics.ABS(now)
    Metrics.type_groups_into(gcprobe_scratch, now)
    TB.push(now, dtps, abs, gcprobe_scratch, -1)
  end)

  TB.clear()
  emit(dp < 1 and "VERDICT: data path ~0 -> ZERO-ALLOC CONFIRMED"
               or "VERDICT: data path NONZERO -> an alloc leaked, investigate")
  emit("(temporal buffer cleared)")
  return lines
end

function M.gc_probe(n)
  local lines = M.gc_probe_lines(n)
  if Verditer.CopyBox then
    Verditer.CopyBox.show("Verditer gcprobe", table.concat(lines, "\n"))
  end
end
