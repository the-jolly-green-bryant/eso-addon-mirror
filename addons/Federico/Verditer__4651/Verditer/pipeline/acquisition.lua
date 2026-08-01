
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Pipeline = Verditer.Pipeline or {}
Verditer.Pipeline.Acquisition = {}
local M = Verditer.Pipeline.Acquisition

local AK = Verditer.Constants.ABILITY_KIND
local KIND_DMG_IN = AK.DMG_IN
local KIND_ABS_IN = AK.ABS_IN

local DAMAGE_SHIELDED = Verditer.zenimax.constants.ACTION_RESULT_DAMAGE_SHIELDED
local GetGameTimeMilliseconds = Verditer.zenimax.api.GetGameTimeMilliseconds

local function acquire()
  return Verditer.Metrics.acquire_event()
end


function M.acquire_dmg_in(t, hit, sourceUnitId, sourceName, damageType, abilityId, result, overflow)
  if (hit or 0) <= 0 then return nil end
  local ev = acquire()
  if not ev then return nil end
  ev.t              = t
  ev.kind           = KIND_DMG_IN
  ev.result         = result       or 0
  ev.amount         = hit
  ev.damage_type    = damageType   or 0
  ev.ability_id     = abilityId    or 0
  ev.source_unit_id = sourceUnitId or 0
  ev.source_name    = sourceName   or ""
  ev.overflow       = overflow     or 0
  return ev
end

-- incoming damage absorbed by the player's own shield
function M.acquire_abs_in(t, hit, sourceUnitId, sourceName, damageType, abilityId)
  if (hit or 0) <= 0 then return nil end
  local ev = acquire()
  if not ev then return nil end
  ev.t              = t
  ev.kind           = KIND_ABS_IN
  ev.result         = DAMAGE_SHIELDED
  ev.amount         = hit
  ev.damage_type    = damageType   or 0
  ev.ability_id     = abilityId    or 0
  ev.source_unit_id = sourceUnitId or 0
  ev.source_name    = sourceName   or ""
  ev.overflow       = 0
  return ev
end

function M.now()
  return GetGameTimeMilliseconds()
end
