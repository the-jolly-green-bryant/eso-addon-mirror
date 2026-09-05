Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Hitch = {}
local M = Verdant.Hitch

local THRESHOLD_MS = 80
local KEEP         = 12

local last_frame = 0
local frames     = 0
local n_hitch    = 0
local worst_ms   = 0
local marks      = 0
local ring_t     = {}
local ring_ms    = {}
local ring_mark  = {}
local ring_n     = 0
local ring_w     = 0

local MARK_TICK   = 1
local MARK_RENDER = 2
local MARK_STOP   = 4

local function now_ms()
  return Verdant.zenimax.api.GetGameTimeMilliseconds()
end

function M.mark(what)
  if what == "tick" then marks = marks + MARK_TICK
  elseif what == "render" then marks = marks + MARK_RENDER
  elseif what == "stop" then marks = marks + MARK_STOP
  end
end

function M.observe(now)
  if last_frame > 0 then
    local dt = now - last_frame
    frames = frames + 1
    if dt >= THRESHOLD_MS then
      n_hitch = n_hitch + 1
      if dt > worst_ms then worst_ms = dt end
      ring_w = (ring_w % KEEP) + 1
      ring_t[ring_w]    = now
      ring_ms[ring_w]   = dt
      ring_mark[ring_w] = marks
      if ring_n < KEEP then ring_n = ring_n + 1 end
    end
  end
  last_frame = now
  marks = 0
end

local function on_frame()
  M.observe(now_ms())
end

local function describe(mask)
  if mask == 0 then return "idle" end
  local parts = {}
  if mask % 2 >= 1 then parts[#parts + 1] = "tick" end
  if mask % 4 >= 2 then parts[#parts + 1] = "render" end
  if mask >= 4 then parts[#parts + 1] = "stop" end
  return table.concat(parts, "+")
end

function M.lines()
  local out = {
    string.format("frames=%d hitches(>=%dms)=%d worst=%dms", frames, THRESHOLD_MS, n_hitch, worst_ms),
  }
  local now = now_ms()
  for i = ring_n, 1, -1 do
    local idx = ((ring_w - ring_n + i - 1) % KEEP) + 1
    out[#out + 1] = string.format("  %5.1fs ago  %4dms  verdant: %s",
      (now - ring_t[idx]) / 1000, ring_ms[idx], describe(ring_mark[idx]))
  end
  return out
end

function M.stats()
  return frames, n_hitch, worst_ms
end

function M.reset()
  frames, n_hitch, worst_ms, ring_n, ring_w = 0, 0, 0, 0, 0
  last_frame = 0
end

function M.init()
  last_frame = 0
  Verdant.zenimax.events.register_update("VerdantHitch", 0, on_frame)
end
