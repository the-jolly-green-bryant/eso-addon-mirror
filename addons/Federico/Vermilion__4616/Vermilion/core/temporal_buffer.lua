Vermilion = Vermilion or {}
Vermilion.TemporalBuffer = {}
local M = Vermilion.TemporalBuffer

local math_floor = math.floor
local log        = Vermilion.Log.for_module("temporal_buffer")

--* state
local state = {
  data      = {},
  capacity  = 0,
  write     = 1,
  count     = 0,
  recording = false,
}

--* public API ────────────────────────────────────────────────────────────────
function M.init(capacity)
  capacity       = math_floor(capacity)
  if capacity < 1 then capacity = 1 end
  state.capacity = capacity
  state.write    = 1
  state.count    = 0
  state.data     = {}
  for i = 1, capacity do
    state.data[i] = {
      t = 0, eDPS = 0, ShDPS = 0, crit = 0, noncrit = 0,
      eos_groups     = { count = 0 },
      eos_abilities  = { count = 0 },
      dtype_groups   = { count = 0 },
      dtype_abilities = { count = 0 },
    }
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

function M.push(timestamp, eDPS, ShDPS, crit, noncrit,
                src_groups, eos_abilities, dtype_groups, dtype_abilities)
  local slot   = state.data[state.write]
  slot.t       = timestamp
  slot.eDPS    = eDPS
  slot.ShDPS   = ShDPS
  slot.crit    = crit or 0
  slot.noncrit = noncrit or 0

  copy_groups(slot.eos_groups,       src_groups)
  copy_abilities(slot.eos_abilities, eos_abilities)
  copy_groups(slot.dtype_groups,     dtype_groups)
  copy_abilities(slot.dtype_abilities, dtype_abilities)

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
