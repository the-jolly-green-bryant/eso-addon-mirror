Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Mode = {}

local M = Verditer.Mode

local METRICS = {
  ITP       = { dmg_in = true,  abs_in = true  },   -- default (DTPS + ABS)
  DTPS_only = { dmg_in = true,  abs_in = false },
  ABS_only  = { dmg_in = false, abs_in = true  },
}

local active = "ITP"
local log = Verditer.Log.for_module("mode")

function M.set(name)
  if METRICS[name] == nil then
    log:warn("set: unknown metric", name)
    return false
  end
  if name ~= active then
    log:info("changed", active, "->", name)
  end
  active = name
  return true
end

function M.get()     return active end
function M.current() return active end

function M.uses(class)
  local m = METRICS[active]
  return m and m[class] == true
end

function M.list()
  local out = {}
  for k in pairs(METRICS) do out[#out + 1] = k end
  return out
end

function M.snapshot()
  local flags = {}
  local m = METRICS[active]
  if m then
    for cls, v in pairs(m) do flags[cls] = v end
  end
  return { active = active, flags = flags }
end
