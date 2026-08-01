Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Coverage = {}

local M = Verdant.Coverage

local pairs            = pairs
local api              = Verdant.zenimax.api
local IsUnitGrouped    = api.IsUnitGrouped
local GetGroupSize     = api.GetGroupSize
local log              = Verdant.Log.for_module("coverage")

local C = Verdant.zenimax.constants
local COMBAT_UNIT_TYPE_PLAYER     = C.COMBAT_UNIT_TYPE_PLAYER
local COMBAT_UNIT_TYPE_GROUP      = C.COMBAT_UNIT_TYPE_GROUP
local COMBAT_UNIT_TYPE_PLAYER_PET = C.COMBAT_UNIT_TYPE_PLAYER_PET

local W_COV_MS = 10000

local coverage = {}
local mode_grouped = false

local function is_group_target_type(targetType)
  return targetType == COMBAT_UNIT_TYPE_PLAYER
      or targetType == COMBAT_UNIT_TYPE_GROUP
      or targetType == COMBAT_UNIT_TYPE_PLAYER_PET
end

function M.set_window(ms)
  W_COV_MS = ms or 10000
end

function M.touch(targetUnitId, now_ms)
  if not targetUnitId or targetUnitId == 0 then return end
  coverage[targetUnitId] = now_ms
end

function M.expire(now_ms)
  local cutoff = now_ms - W_COV_MS
  for k, t in pairs(coverage) do
    if t <= cutoff then coverage[k] = nil end
  end
end

function M.size(now_ms)
  M.expire(now_ms)
  local n = 0
  for _ in pairs(coverage) do n = n + 1 end
  return n
end

function M.refresh_mode()
  local prev = mode_grouped
  mode_grouped = IsUnitGrouped("player") and (GetGroupSize() or 0) > 1
  if prev ~= mode_grouped then
    log:info("mode change ->", mode_grouped and "group" or "solo",
             "size=", GetGroupSize() or 0)
  end
  return mode_grouped
end

function M.is_grouped()
  return mode_grouped
end

function M.is_in_M(targetType)
  if mode_grouped then
    return is_group_target_type(targetType)
  end
  return true
end

M.is_group_target_type = is_group_target_type

function M.snapshot()
  local units = {}
  for uid, t in pairs(coverage) do
    units[#units + 1] = { uid = uid, last_t = t }
  end
  return { mode_grouped = mode_grouped, coverage_sz = #units, units = units }
end

function M.reset()
  coverage = {}
  mode_grouped = false
end
