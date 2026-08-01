--* core/gc.lua  (ported from Verditer — APOD GC-pacing lever)
--*
--* Lua's incremental collector only steps when the heap crosses a threshold, so it
--* bursts into multi-ms atomic pauses that land inside render frames (visible hitch).
--* Driving a small step every frame keeps it ahead so it never needs a big pause
--* (lua-users "GC In Real-Time Games"). Conservative + tunable (Constants.GC); ships
--* in release (it's a real optimization). Flip Constants.GC.PACING=false to A/B.

Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.GC = {}
local M = Vermilion.GC

local collectgarbage = collectgarbage

local C        = Vermilion.Constants.GC or {}
local ENABLED  = (C.PACING ~= false)
local STEP_KB  = C.STEP_KB     or 2
local INTERVAL = C.INTERVAL_MS or 0

local steps, cycles = 0, 0

local function tick()
  steps = steps + 1
  if collectgarbage("step", STEP_KB) then cycles = cycles + 1 end
end

function M.init()
  steps, cycles = 0, 0
  if not ENABLED then return end
  Vermilion.zenimax.events.register_update("VermilionGCStep", INTERVAL, tick)
end

function M.stats() return steps, cycles, ENABLED end

function M.report_lines()
  return { string.format("[gc] pacing=%s step=%dKB interval=%dms  steps=%d cycles=%d",
                         tostring(ENABLED), STEP_KB, INTERVAL, steps, cycles) }
end
