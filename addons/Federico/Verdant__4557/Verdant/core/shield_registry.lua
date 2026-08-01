Verdant = Verdant or {}
local Verdant = Verdant

Verdant.ShieldRegistry = {}

local M = Verdant.ShieldRegistry

local pairs    = pairs
local tostring = tostring
local log      = Verdant.Log.for_module("shield_registry")

local C = Verdant.zenimax.constants
local COMBAT_UNIT_TYPE_PLAYER    = C.COMBAT_UNIT_TYPE_PLAYER
local EFFECT_RESULT_GAINED       = C.EFFECT_RESULT_GAINED
local EFFECT_RESULT_UPDATED      = C.EFFECT_RESULT_UPDATED
local EFFECT_RESULT_FULL_REFRESH = C.EFFECT_RESULT_FULL_REFRESH
local EFFECT_RESULT_TRANSFER     = C.EFFECT_RESULT_TRANSFER
local EFFECT_RESULT_FADED        = C.EFFECT_RESULT_FADED

local function key(abilityId, targetUnitId)
  return tostring(abilityId or 0) .. ":" .. tostring(targetUnitId or 0)
end

local active = {}
local stats  = { gained = 0, faded = 0, hits = 0, misses = 0 }

function M.on_effect(changeType, abilityId, targetUnitId, sourceType, endTime)
  if not abilityId or abilityId == 0 then return end
  if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
  if not targetUnitId or targetUnitId == 0 then return end

  local k = key(abilityId, targetUnitId)
  if changeType == EFFECT_RESULT_GAINED
     or changeType == EFFECT_RESULT_UPDATED
     or changeType == EFFECT_RESULT_FULL_REFRESH
     or changeType == EFFECT_RESULT_TRANSFER then
    active[k] = { abilityId = abilityId, targetUnitId = targetUnitId, endTime = endTime }
    stats.gained = stats.gained + 1
  elseif changeType == EFFECT_RESULT_FADED then
    active[k] = nil
    stats.faded = stats.faded + 1
  end
end

function M.is_self_cast(abilityId, targetUnitId)
  local k = key(abilityId, targetUnitId)
  if active[k] ~= nil then
    stats.hits = stats.hits + 1
    return true
  end
  stats.misses = stats.misses + 1
  return false
end

function M.expire_stale(now_ms)
  for k, v in pairs(active) do
    if v.endTime and v.endTime > 0 and (v.endTime * 1000) < now_ms then
      active[k] = nil
    end
  end
end

function M.reset()
  local n = 0
  for _ in pairs(active) do n = n + 1 end
  log:info("reset: cleared", n, "active shields,",
           "gained=", stats.gained, "faded=", stats.faded,
           "hits=", stats.hits, "misses=", stats.misses)
  active = {}
  stats  = { gained = 0, faded = 0, hits = 0, misses = 0 }
end

function M.snapshot()
  local n = 0
  for _ in pairs(active) do n = n + 1 end
  return { active = n, gained = stats.gained, faded = stats.faded,
           hits = stats.hits, misses = stats.misses }
end
