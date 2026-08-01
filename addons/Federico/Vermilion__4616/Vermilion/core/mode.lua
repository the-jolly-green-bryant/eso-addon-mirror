Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Mode = {}

local M = Vermilion.Mode

local METRICS = {
  EOS        = { damage = true,  shield = true  },
  eDPS_only  = { damage = true,  shield = false },
  ShDPS_only = { damage = false, shield = true  },
}

local active = "EOS"
local log = Vermilion.Log.for_module("mode")

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
