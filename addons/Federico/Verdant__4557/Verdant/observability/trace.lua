Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Trace = {}
local M = Verdant.Trace

local NOOP = function() end
M.start       = NOOP
M.stop        = NOOP
M.save        = NOOP
M.clear       = NOOP
M.init        = NOOP
M.status_line = function() return "trace disabled (DEBUG=false)" end

if not Verdant.Constants.DEBUG then return end

local d       = d
local select  = select
local type    = type
local api     = Verdant.zenimax.api
local zev     = Verdant.zenimax.events
local C       = Verdant.zenimax.constants
local GetGameTimeMilliseconds = api.GetGameTimeMilliseconds

local CAP       = 40000
local CHUNK_MAX = 1800

local CONST_NAMES = {
  "ACTION_RESULT_HEAL", "ACTION_RESULT_CRITICAL_HEAL", "ACTION_RESULT_HOT_TICK",
  "ACTION_RESULT_HOT_TICK_CRITICAL", "ACTION_RESULT_HEAL_ABSORBED",
  "ACTION_RESULT_DAMAGE", "ACTION_RESULT_CRITICAL_DAMAGE", "ACTION_RESULT_DOT_TICK",
  "ACTION_RESULT_DOT_TICK_CRITICAL", "ACTION_RESULT_BLOCKED_DAMAGE",
  "ACTION_RESULT_FALL_DAMAGE", "ACTION_RESULT_DAMAGE_SHIELDED",
  "EFFECT_RESULT_GAINED", "EFFECT_RESULT_FADED", "EFFECT_RESULT_UPDATED",
  "EFFECT_RESULT_FULL_REFRESH", "EFFECT_RESULT_TRANSFER",
  "POWERTYPE_HEALTH", "BUFF_EFFECT_TYPE_BUFF", "BUFF_EFFECT_TYPE_DEBUFF",
  "ABILITY_TYPE_HEAL", "COMBAT_UNIT_TYPE_PLAYER", "COMBAT_UNIT_TYPE_PLAYER_PET",
  "COMBAT_UNIT_TYPE_GROUP", "COMBAT_UNIT_TYPE_OTHER",
}

local lines  = {}
local n      = 0
local active = false

local function fld(v)
  local tv = type(v)
  if v == nil then return "" end
  if tv == "boolean" then return v and "T" or "F" end
  if tv == "number" then return tostring(v) end
  return (tostring(v):gsub("[\t\n]", " "))
end

local function rec(tag, ...)
  if not active then return end
  if n >= CAP then
    active = false
    d("[trace] capacity reached (" .. CAP .. "), capture stopped")
    return
  end
  local parts = { tag, tostring(GetGameTimeMilliseconds()) }
  local argc = select("#", ...)
  for i = 1, argc do
    parts[#parts + 1] = fld((select(i, ...)))
  end
  n = n + 1
  lines[n] = table.concat(parts, "\t")
end

local function rec_group()
  local names = {}
  local n = api.GetGroupSize() or 0
  local player_slot = 0
  for i = 1, n do
    names[i] = (api.GetUnitName("group" .. i) or ""):gsub("[|\t\n]", " ")
    if api.AreUnitsEqual("group" .. i, "player") then player_slot = i end
  end
  rec("GR", api.IsUnitGrouped("player"), n, table.concat(names, "|"), player_slot)
end

local function rec_bosses()
  local names = {}
  for i = C.BOSS_RANK_ITERATION_BEGIN, C.BOSS_RANK_ITERATION_END do
    local tag = "boss" .. i
    if api.DoesUnitExist(tag) then
      names[#names + 1] = (api.GetUnitName(tag) or ""):gsub("[|\t\n]", " ")
    end
  end
  rec("BO", table.concat(names, "|"))
end

function M.start()
  active = true
  rec_group()
  rec_bosses()
  d("[trace] capturing (" .. n .. "/" .. CAP .. " events)")
end

function M.stop()
  active = false
  d("[trace] stopped at " .. n .. " events")
end

function M.clear(sv)
  lines  = {}
  n      = 0
  active = false
  if sv then sv.trace = nil end
end

function M.save(sv)
  local chunks = {}
  local buf, blen = {}, 0
  for i = 1, n do
    local llen = #lines[i] + 1
    if blen + llen > CHUNK_MAX and #buf > 0 then
      chunks[#chunks + 1] = table.concat(buf, "\n")
      buf, blen = {}, 0
    end
    buf[#buf + 1] = lines[i]
    blen = blen + llen
  end
  if #buf > 0 then chunks[#chunks + 1] = table.concat(buf, "\n") end
  local consts = { API_VERSION = api.GetAPIVersion() }
  for _, k in ipairs(CONST_NAMES) do
    consts[k] = rawget(_G, k)
  end
  sv.trace = {
    version   = 2,
    build     = Verdant.Constants.BUILD,
    world     = api.GetWorldName(),
    count     = n,
    chunks    = chunks,
    constants = consts,
  }
  d("[trace] " .. n .. " events staged to SavedVars; /reloadui to flush to disk")
end

function M.status_line()
  return "trace " .. (active and "ACTIVE" or "idle") .. "  events=" .. n .. "/" .. CAP
end

function M.init()
  zev.register("Verdant_Trace_CE", C.EVENT_COMBAT_EVENT, function(...) rec("CE", ...) end)
  zev.register("Verdant_Trace_EF", C.EVENT_EFFECT_CHANGED, function(...) rec("EF", ...) end)
  zev.register("Verdant_Trace_CS", C.EVENT_PLAYER_COMBAT_STATE, function(in_combat) rec("CS", in_combat) end)
  zev.register("Verdant_Trace_DE", C.EVENT_UNIT_DEATH_STATE_CHANGED, function(tag, dead) rec("DE", tag, dead) end)
  zev.register("Verdant_Trace_WP", C.EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() rec("WP") end)
  zev.register("Verdant_Trace_BO", C.EVENT_BOSSES_CHANGED, rec_bosses)
  zev.register("Verdant_Trace_PU", C.EVENT_POWER_UPDATE, function(...) rec("PU", ...) end)
  zev.add_filter("Verdant_Trace_PU", C.EVENT_POWER_UPDATE,
    C.REGISTER_FILTER_POWER_TYPE, C.POWERTYPE_HEALTH)
  zev.add_filter("Verdant_Trace_PU", C.EVENT_POWER_UPDATE,
    C.REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
  zev.register("Verdant_Trace_GJ", C.EVENT_GROUP_MEMBER_JOINED, rec_group)
  zev.register("Verdant_Trace_GL", C.EVENT_GROUP_MEMBER_LEFT, rec_group)
  zev.register("Verdant_Trace_GU", C.EVENT_GROUP_UPDATE, rec_group)
end
