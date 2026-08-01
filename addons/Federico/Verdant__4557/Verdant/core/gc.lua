
Verdant = Verdant or {}
local Verdant = Verdant

Verdant.GC = {}
local M = Verdant.GC

local collectgarbage = collectgarbage

local C        = Verdant.Constants.GC or {}
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
  Verdant.zenimax.events.register_update("VerdantGCStep", INTERVAL, tick)
end

function M.stats() return steps, cycles, ENABLED end

function M.report_lines()
  return { string.format("[gc] pacing=%s step=%dKB interval=%dms  steps=%d cycles=%d",
                         tostring(ENABLED), STEP_KB, INTERVAL, steps, cycles) }
end
