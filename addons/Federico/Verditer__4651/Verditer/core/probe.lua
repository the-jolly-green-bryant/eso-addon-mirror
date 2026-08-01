
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Probe = {}
local M = Verditer.Probe

local d                       = d
local string_format           = string.format
local table_concat            = table.concat
local pairs                   = pairs
local api                     = Verditer.zenimax.api
local GetGameTimeMilliseconds = api.GetGameTimeMilliseconds
local GetAPIVersion           = api.GetAPIVersion

local C  = Verditer.zenimax.constants
local EVENT_COMBAT_EVENT       = C.EVENT_COMBAT_EVENT
local REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE = C.REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE
local REGISTER_FILTER_IS_ERROR = C.REGISTER_FILTER_IS_ERROR
local COMBAT_UNIT_TYPE_PLAYER     = C.COMBAT_UNIT_TYPE_PLAYER
local COMBAT_UNIT_TYPE_PLAYER_PET = C.COMBAT_UNIT_TYPE_PLAYER_PET

local RESULT_LABELS, DT_LABELS

local function build_labels()
  RESULT_LABELS, DT_LABELS = {}, {}
  local function rput(code, name) if code ~= nil then RESULT_LABELS[code] = name end end
  local function dput(code, name) if code ~= nil then DT_LABELS[code]     = name end end

  rput(C.ACTION_RESULT_DAMAGE,            "DAMAGE")
  rput(C.ACTION_RESULT_DOT_TICK,          "DOT_TICK")
  rput(C.ACTION_RESULT_CRITICAL_DAMAGE,   "CRIT_DAMAGE")
  rput(C.ACTION_RESULT_DOT_TICK_CRITICAL, "DOT_CRIT")
  rput(C.ACTION_RESULT_BLOCKED_DAMAGE,    "BLOCKED_DMG")
  rput(C.ACTION_RESULT_DAMAGE_SHIELDED,   "SHIELDED")
  rput(C.ACTION_RESULT_FALL_DAMAGE,       "FALL")
  rput(C.ACTION_RESULT_DODGED,            "DODGED")
  rput(C.ACTION_RESULT_MISS,              "MISS")
  rput(C.ACTION_RESULT_IMMUNE,            "IMMUNE")
  rput(C.ACTION_RESULT_BLOCKED,           "BLOCKED")
  rput(C.ACTION_RESULT_REFLECTED,         "REFLECTED")
  rput(C.ACTION_RESULT_PARRIED,           "PARRIED")
  rput(C.ACTION_RESULT_DIED,              "DIED")
  rput(C.ACTION_RESULT_KILLING_BLOW,      "KILLING_BLOW")

  dput(C.DAMAGE_TYPE_NONE,     "NONE")
  dput(C.DAMAGE_TYPE_GENERIC,  "GENERIC")
  dput(C.DAMAGE_TYPE_PHYSICAL, "PHYSICAL")
  dput(C.DAMAGE_TYPE_FIRE,     "FIRE")
  dput(C.DAMAGE_TYPE_SHOCK,    "SHOCK")
  dput(C.DAMAGE_TYPE_OBLIVION, "OBLIVION")
  dput(C.DAMAGE_TYPE_COLD,     "COLD")
  dput(C.DAMAGE_TYPE_EARTH,    "EARTH")
  dput(C.DAMAGE_TYPE_MAGIC,    "MAGIC")
  dput(C.DAMAGE_TYPE_DROWN,    "DROWN")
  dput(C.DAMAGE_TYPE_DISEASE,  "DISEASE")
  dput(C.DAMAGE_TYPE_POISON,   "POISON")
  dput(C.DAMAGE_TYPE_BLEED,    "BLEED")
end

local function rlabel(r)  return RESULT_LABELS[r] or ("r" .. tostring(r)) end
local function dtlabel(t) return DT_LABELS[t]     or ("dt" .. tostring(t)) end

local state = {
  enabled    = false,
  rows       = {},
  w          = 1,
  n          = 0,
  cap        = 0,
  events     = 0,
  results    = {},
  dtypes     = {},
  env        = 0,
  pet        = 0,
  overflow_n = 0,
}

local function now() return GetGameTimeMilliseconds() end

local function on_combat(result, _isError, abilityName, _g, _slot,
                         sourceName, _srcType, _tgtName, targetType, hitValue,
                         _pt, damageType, _log, sourceUnitId, _tgtUid, abilityId, overflow)
  if not state.enabled then return end
  state.events  = state.events + 1
  state.results[result]      = (state.results[result] or 0) + 1
  state.dtypes[damageType or 0] = (state.dtypes[damageType or 0] or 0) + 1
  if (sourceUnitId or 0) == 0 then state.env = state.env + 1 end
  if targetType == COMBAT_UNIT_TYPE_PLAYER_PET then state.pet = state.pet + 1 end
  if (overflow or 0) ~= 0 then state.overflow_n = state.overflow_n + 1 end

  local line = string_format("%d,%s,%d,%s,%d,%d,%d,%d,%q,%d",
    now(), rlabel(result), hitValue or 0, dtlabel(damageType or 0),
    sourceUnitId or 0, _srcType or 0, targetType or 0, abilityId or 0,
    abilityName or "", overflow or 0)

  state.rows[state.w] = line
  state.w = (state.w % state.cap) + 1
  if state.n < state.cap then state.n = state.n + 1 end
end

function M.set_enabled(v)
  state.enabled = v and true or false
  d("[Vd] probe " .. (state.enabled and "ON — taking hits to capture" or "OFF"))
end

function M.is_enabled() return state.enabled end

function M.clear()
  state.rows = {}; state.w = 1; state.n = 0
  state.events = 0; state.results = {}; state.dtypes = {}
  state.env = 0; state.pet = 0; state.overflow_n = 0
  d("[Vd] probe cleared")
end

function M.print_stats()
  d(string_format("[Vd] probe: %d events, %d rows held | env(suid=0)=%d pet=%d overflow!=0=%d",
    state.events, state.n, state.env, state.pet, state.overflow_n))
end

function M.dump_report()
  local L = {}
  L[#L+1] = "=== Verditer acquisition probe (TARGET=PLAYER) ==="
  L[#L+1] = string_format("api=%d  events=%d  rows=%d  env(suid=0)=%d  pet=%d  overflow!=0=%d",
    GetAPIVersion(), state.events, state.n, state.env, state.pet, state.overflow_n)

  L[#L+1] = "-- result codes seen --"
  for r, c in pairs(state.results) do
    L[#L+1] = string_format("  %-12s (%d) : %d", rlabel(r), r, c)
  end
  L[#L+1] = "-- damage types seen --"
  for t, c in pairs(state.dtypes) do
    L[#L+1] = string_format("  %-10s (%d) : %d", dtlabel(t), t, c)
  end

  L[#L+1] = "-- engine / perf (production pipeline) --"
  if Verditer.Metrics and Verditer.Metrics.pool_in_use then
    L[#L+1] = string_format("  pool: in_use=%d / cap=%d",
      Verditer.Metrics.pool_in_use(), Verditer.Metrics.pool_capacity())
    local ms = Verditer.Metrics.size_snapshot and Verditer.Metrics.size_snapshot() or {}
    L[#L+1] = string_format("  buffers: dmg_in=%d  abs_in=%d", ms.dmg_in or 0, ms.abs_in or 0)
  end
  if Verditer.Diagnostics and Verditer.Diagnostics.snapshot then
    local c = (Verditer.Diagnostics.snapshot() or {}).counters or {}
    L[#L+1] = string_format("  dmg_in: in=%d accepted=%d dropped_noise=%d dropped_mode=%d",
      c["engine.dmg_in.in"] or 0, c["engine.dmg_in.accepted"] or 0,
      c["engine.dmg_in.dropped_noise"] or 0, c["engine.dmg_in.dropped_mode"] or 0)
    L[#L+1] = string_format("  abs_in: in=%d accepted=%d", c["engine.abs_in.in"] or 0, c["engine.abs_in.accepted"] or 0)
    L[#L+1] = string_format("  POOL.EXHAUSTED=%d   filter.env_self=%d   damage_type_fallback=%d",
      c["engine.pool.exhausted"] or 0, c["filter.env_self"] or 0, c["metrics.damage_type_fallback"] or 0)
  end

  L[#L+1] = "-- rows: t,result,hit,dmgType,srcUid,srcType,tgtType,abilityId,abilityName,overflow --"
  if state.n == 0 then
    L[#L+1] = "(no rows — enable with /verditer probe on, then take some hits)"
  else
    local cap = state.cap
    local oldest = (state.n >= cap) and state.w or 1
    for i = 1, state.n do
      local idx = ((oldest - 1 + i - 1) % cap) + 1
      L[#L+1] = state.rows[idx]
    end
  end
  return table_concat(L, "\n")
end

function M.dump()
  if Verditer.CopyBox then
    Verditer.CopyBox.show("Verditer Probe", M.dump_report())
  else
    d(M.dump_report())
  end
end

function M.init()
  build_labels()
  state.cap = (Verditer.Constants.PROBE and Verditer.Constants.PROBE.ROW_LIMIT) or 6000

  local E = Verditer.zenimax.events
  E.register("Verditer_Probe", EVENT_COMBAT_EVENT, on_combat)
  E.add_filter("Verditer_Probe", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
  E.add_filter("Verditer_Probe", EVENT_COMBAT_EVENT,
    REGISTER_FILTER_IS_ERROR, false)
end
