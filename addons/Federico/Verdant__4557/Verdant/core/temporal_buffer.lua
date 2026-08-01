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
    state.data[i] = { t = 0, eHPS = 0, MPS = 0, crit = 0, noncrit = 0,
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


function M.push(timestamp, eHPS, MPS, crit, noncrit, ehps_groups, mps_groups, ehps_abilities, mps_abilities)
  local slot   = state.data[state.write]
  slot.t       = timestamp
  slot.eHPS    = eHPS
  slot.MPS     = MPS
  slot.crit    = crit or 0
  slot.noncrit = noncrit or 0
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

function M.count()        return state.count     end
function M.capacity()     return state.capacity  end
function M.is_recording() return state.recording end

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
