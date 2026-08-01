Verditer = Verditer or {}
Verditer.TemporalBuffer = {}
local M = Verditer.TemporalBuffer

local math_floor = math.floor
local log        = Verditer.Log.for_module("temporal_buffer")

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
    state.data[i] = { t = 0, DTPS = 0, ABS = 0, hp_pct = -1, hp_drop = 0,
                      type_groups = { count = 0 }, source_groups = { count = 0 } }
  end
  log:info("init: capacity=", capacity)
end

function M.push(timestamp, DTPS, ABS, type_groups, hp_pct, hp_drop, source_groups)
  local slot   = state.data[state.write]
  slot.t       = timestamp
  slot.DTPS    = DTPS
  slot.ABS     = ABS
  slot.hp_pct  = hp_pct or -1
  slot.hp_drop = hp_drop or 0

  local dst = slot.type_groups
  local n   = (type_groups and (type_groups.count or #type_groups)) or 0
  for i = 1, n do
    local s = type_groups[i]
    local d = dst[i]
    if d == nil then d = {}; dst[i] = d end
    d.r = s.r; d.g = s.g; d.b = s.b; d.a = s.a; d.share = s.share
    d.dt = s.dt
  end
  dst.count = n

  local sdst = slot.source_groups
  local sn   = (source_groups and (source_groups.count or #source_groups)) or 0
  for i = 1, sn do
    local s = source_groups[i]
    local d = sdst[i]
    if d == nil then d = {}; sdst[i] = d end
    d.r = s.r; d.g = s.g; d.b = s.b; d.a = s.a; d.share = s.share
    d.uid = s.uid; d.name = s.name
  end
  sdst.count = sn

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

function M.count()        return state.count     end
function M.capacity()     return state.capacity  end
function M.is_recording() return state.recording end

function M.latest()
  if state.count == 0 then return nil end
  local idx = state.write - 1
  if idx < 1 then idx = state.capacity end
  return state.data[idx]
end

function M.start_recording()
  state.recording = true
  log:info("start_recording")
end

function M.stop_recording()
  state.recording = false
  log:info("stop_recording: count=", state.count, "/", state.capacity)
end

function M.clear()
  log:info("clear: discarding", state.count, "samples")
  state.write = 1
  state.count = 0
end
