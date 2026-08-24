Verdant = Verdant or {}
Verdant.TemporalBuffer = {}
local M = Verdant.TemporalBuffer

local math_floor = math.floor
local log        = Verdant.Log.for_module("temporal_buffer")

local state = {
  data      = {},
  capacity  = 0,
  write     = 1,
  count     = 0,
  recording = false,
}

function M.init(capacity)
  capacity       = math_floor(capacity)
  if capacity < 1 then capacity = 1 end
  state.capacity = capacity
  state.write    = 1
  state.count    = 0
  state.data     = {}
  for i = 1, capacity do
    state.data[i] = { t = 0, eHPS = 0, MPS = 0, crit = 0, noncrit = 0, d = 0,
                      ehps_groups = { count = 0 }, mps_groups = { count = 0 },
                      ehps_abilities = { count = 0 }, mps_abilities = { count = 0 } }
  end
  log:info("init: capacity=", capacity)
end

local function copy_groups(dst, src)
  local n = (src and (src.count or #src)) or 0
  for i = 1, n do
    local s = src[i]
    local d = dst[i]
    if d == nil then d = {}; dst[i] = d end
    d.r = s.r; d.g = s.g; d.b = s.b; d.a = s.a; d.share = s.share
    d.key = s.key
  end
  dst.count = n
end

local function copy_abilities(dst, src)
  local n = (src and (src.count or #src)) or 0
  for i = 1, n do
    local s = src[i]
    local d = dst[i]
    if d == nil then d = {}; dst[i] = d end
    d.id = s.id; d.share = s.share; d.key = s.key
    d.r = s.r; d.g = s.g; d.b = s.b; d.a = s.a
  end
  dst.count = n
end


function M.push(timestamp, eHPS, MPS, crit, noncrit, ehps_groups, mps_groups, ehps_abilities, mps_abilities, d_group)
  local slot   = state.data[state.write]
  slot.t       = timestamp
  slot.eHPS    = eHPS
  slot.MPS     = MPS
  slot.crit    = crit or 0
  slot.noncrit = noncrit or 0
  slot.d       = d_group or 0
  copy_groups(slot.ehps_groups, ehps_groups)
  copy_groups(slot.mps_groups,  mps_groups)
  copy_abilities(slot.ehps_abilities, ehps_abilities)
  copy_abilities(slot.mps_abilities,  mps_abilities)
  state.write = (state.write % state.capacity) + 1
  if state.count < state.capacity then
    state.count = state.count + 1
  end
end

function M.iterate(fn)
  local n   = state.count
  if n == 0 then return end
  local cap = state.capacity
  local oldest = (n >= cap) and state.write or 1
  for i = 1, n do
    local idx = ((oldest - 1 + i - 1) % cap) + 1
    fn(i, state.data[idx])
  end
end

local markers = { n = 0 }
local MARKER_CAP       = 80
local MARKER_GROUP_CAP = 60
local group_marker_n   = 0

function M.add_marker(t, is_death, who)
  if markers.n >= MARKER_CAP then return end
  if who then
    if group_marker_n >= MARKER_GROUP_CAP then return end
    group_marker_n = group_marker_n + 1
  end
  markers.n = markers.n + 1
  local m = markers[markers.n]
  if not m then m = {}; markers[markers.n] = m end
  m.t = t
  m.death = is_death and true or false
  m.who = who
end

function M.markers() return markers, markers.n end

function M.count()        return state.count     end
function M.capacity()     return state.capacity  end
function M.is_recording() return state.recording end

function M.start_recording()
  state.recording = true
  log:info("start_recording")
  if Verdant.Triage then Verdant.Triage.on_session_start() end
  if Verdant.SessionStore then Verdant.SessionStore.on_session_start() end
end

function M.stop_recording()
  state.recording = false
  log:info("stop_recording: count=", state.count, "/", state.capacity)
  if Verdant.Triage then Verdant.Triage.on_session_stop() end
end

local summary_scratch = {
  count = 0, dur_ms = 0, avg_ems = 0, peak_ems = 0, peak_t_off = 0,
  crit_pct = 0, active_pct = 0, total_heal = 0, total_shield = 0,
}

function M.summary()
  local s = summary_scratch
  s.count = state.count
  s.dur_ms = 0; s.avg_ems = 0; s.peak_ems = 0; s.peak_t_off = 0
  s.crit_pct = 0; s.active_pct = 0; s.total_heal = 0; s.total_shield = 0
  if state.count == 0 then return s end

  local t0, t_prev = 0, 0
  local sum_ems, peak_ems, peak_t = 0, 0, 0
  local sum_crit, sum_noncrit = 0, 0
  local active_n = 0

  M.iterate(function(i, sample)
    local ems = sample.eHPS + sample.MPS
    sum_ems = sum_ems + ems
    if ems > peak_ems then peak_ems = ems; peak_t = sample.t end
    sum_crit    = sum_crit    + sample.crit
    sum_noncrit = sum_noncrit + sample.noncrit
    if ems > 0 then active_n = active_n + 1 end
    if i == 1 then t0 = sample.t end
    if i > 1 then
      local dt = (sample.t - t_prev) / 1000
      s.total_heal   = s.total_heal   + sample.eHPS * dt
      s.total_shield = s.total_shield + sample.MPS  * dt
    end
    t_prev = sample.t
  end)

  s.dur_ms     = t_prev - t0
  s.avg_ems    = sum_ems / state.count
  s.peak_ems   = peak_ems
  s.peak_t_off = (peak_ems > 0) and (peak_t - t0) or 0
  s.active_pct = active_n / state.count
  local heal_total = sum_crit + sum_noncrit
  if heal_total > 0 then s.crit_pct = sum_crit / heal_total end
  return s
end

local EMPTY_SHARES = { count = 0 }

function M.load_session(samples, marker_list)
  M.clear()
  for i = 1, #samples do
    local s = samples[i]
    M.push(s.t, s.eHPS, s.MPS, s.crit, s.noncrit,
           s.eg or EMPTY_SHARES, s.mg or EMPTY_SHARES,
           s.ea or EMPTY_SHARES, s.ma or EMPTY_SHARES, s.d)
  end
  for i = 1, #marker_list do
    local m = marker_list[i]
    M.add_marker(m.t, m.death, m.who)
  end
  state.recording = false
  log:info("session loaded: samples=", #samples, "markers=", #marker_list)
end

function M.clear()
  log:info("clear: discarding", state.count, "samples")
  state.write = 1
  state.count = 0
  markers.n = 0
  group_marker_n = 0
end
