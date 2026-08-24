Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Triage = {}
local M = Verdant.Triage

local math_floor  = math.floor
local table_sort  = table.sort
local pairs       = pairs
local string_find = string.find
local string_sub  = string.sub

local THETA          = 0.50
local THETA_EXIT     = 0.55
local THETA_MIN      = 0.30
local THETA_MAX      = 0.75
local THETA_HYST     = 0.05
local DELTA_MS       = 1000
local GRACE_RES_MS   = 3000
local SIGMA_MS       = 2000
local MIN_EPISODE_MS = 400
local LOG_CAP        = 128
local MAX_SLOTS      = 12
local CENSOR_TICK_MS = 1000

local CLASS_S       = 1
local CLASS_O       = 2
local CLASS_L       = 3
local CLASS_M       = 4
local CLASS_X       = 5
local CLASS_ONESHOT = 6

M.CLASS_S       = CLASS_S
M.CLASS_O       = CLASS_O
M.CLASS_L       = CLASS_L
M.CLASS_M       = CLASS_M
M.CLASS_X       = CLASS_X
M.CLASS_ONESHOT = CLASS_ONESHOT

local TAG_SLOT = {}
for i = 1, MAX_SLOTS do TAG_SLOT["group" .. i] = i end

local slots = {}
for i = 1, MAX_SLOTS do
  slots[i] = {
    open = false, dead = false,
    start = 0, last_t = 0, grace_until = 0,
    rt = -1, responded = false, overflow = false,
    last_heal_t = -1, min_rho = 1,
    p_active = false, p_start = 0, p_end = 0,
    p_rt = -1, p_responded = false, p_overflow = false,
    p_last_heal = -1, p_min_rho = 1,
  }
end

local ep_log = { n = 0 }
local ep_dropped = 0

local name_slot = {}
local slot_names = {}
local slot_icons = {}
local name_count = 0
local names_dirty = false
local player_slot_i = 0
local session_active = false
local pu_count = 0
local pu_first_t = 0
local pu_last_t = 0
local lat_sum = 0
local lat_n = 0
local heal_matched = 0
local heal_unmatched = 0

local log
local api
local GetGameTimeMilliseconds

local function bump(k) Verdant.Diagnostics.bump(k) end

local function log_episode(slot_i, s, t_end, class, star)
  if ep_log.n >= LOG_CAP then
    ep_dropped = ep_dropped + 1
    return
  end
  ep_log.n = ep_log.n + 1
  local e = ep_log[ep_log.n]
  if not e then e = {}; ep_log[ep_log.n] = e end
  e.slot      = slot_i
  e.t_start   = s.start
  e.t_end     = t_end
  e.class     = class
  e.star      = star or false
  e.rt        = s.rt
  e.min_rho   = s.min_rho
  e.responded = s.responded
end

local ep_scratch = {}

local function finalize_pending(slot_i, s)
  if not s.p_active then return end
  s.p_active = false
  local class, star
  if s.p_responded then
    class = CLASS_S
    star  = s.p_overflow or (s.p_last_heal >= 0 and (s.p_end - s.p_last_heal) <= DELTA_MS)
  else
    class, star = CLASS_O, false
  end
  ep_scratch.start     = s.p_start
  ep_scratch.rt        = s.p_rt
  ep_scratch.min_rho   = s.p_min_rho
  ep_scratch.responded = s.p_responded
  log_episode(slot_i, ep_scratch, s.p_end, class, star)
  bump("triage.episode.closed")
end

local function close_episode(slot_i, s, now, kind)
  s.open = false
  if kind == 1 then
    finalize_pending(slot_i, s)
    s.p_active    = true
    s.p_start     = s.start
    s.p_end       = now
    s.p_rt        = s.rt
    s.p_responded = s.responded
    s.p_overflow  = s.overflow
    s.p_last_heal = s.last_heal_t
    s.p_min_rho   = s.min_rho
    return
  end
  local class, star = CLASS_X, false
  if kind == 2 then
    if s.responded then
      class = CLASS_L
    elseif (now - s.start) < MIN_EPISODE_MS then
      class = CLASS_ONESHOT
    else
      class = CLASS_M
    end
  end
  log_episode(slot_i, s, now, class, star)
  bump("triage.episode.closed")
end

function M.on_power(unitTag, _idx, _ptype, value, _max, effMax)
  pu_count = pu_count + 1
  local now = GetGameTimeMilliseconds()
  if pu_first_t == 0 then pu_first_t = now end
  pu_last_t = now
  if not session_active then return end
  local i = TAG_SLOT[unitTag]
  if not i then return end
  if not slot_names[i] then names_dirty = true end
  local s = slots[i]
  s.last_t = now
  if s.dead or now < s.grace_until then return end
  if not effMax or effMax <= 0 then return end
  local rho = value / effMax
  if s.open then
    if rho < s.min_rho then s.min_rho = rho end
    if rho >= THETA_EXIT then close_episode(i, s, now, 1) end
  elseif rho < THETA then
    finalize_pending(i, s)
    s.open        = true
    s.start       = now
    s.rt          = -1
    s.responded   = false
    s.overflow    = false
    s.last_heal_t = -1
    s.min_rho     = rho
    bump("triage.episode.opened")
  end
end

local CU_PLAYER, CU_GROUP, AR_HEAL, AR_CRIT_HEAL

local function base_name(name)
  local p = string_find(name, "^", 1, true)
  if p then return string_sub(name, 1, p - 1) end
  return name
end

function M.on_own_heal(targetName, hit, overflow, now, targetType, result)
  if not session_active or name_count == 0 then return end
  if targetType ~= CU_GROUP and targetType ~= CU_PLAYER then return end
  if not targetName or targetName == "" then return end
  local i = name_slot[targetName]
  if not i then i = name_slot[base_name(targetName)] end
  if not i then
    heal_unmatched = heal_unmatched + 1
    return
  end
  heal_matched = heal_matched + 1
  local s = slots[i]
  if s.open then
    if hit and hit > 0 then
      s.responded   = true
      s.last_heal_t = now
      if s.rt < 0 and (result == AR_HEAL or result == AR_CRIT_HEAL) then
        s.rt = now - s.start
      end
    end
    if overflow and overflow > 0 then s.overflow = true end
    return
  end
  if s.p_active and (now - s.p_end) <= DELTA_MS then
    if hit and hit > 0 then
      s.p_responded = true
      s.p_last_heal = now
      if s.p_rt < 0 and (result == AR_HEAL or result == AR_CRIT_HEAL) then
        s.p_rt = now - s.p_start
      end
      bump("triage.episode.late_attribution")
    end
    if overflow and overflow > 0 then s.p_overflow = true end
  end
end

function M.on_unit_death(unitTag, isDead)
  if not session_active then return end
  local i = TAG_SLOT[unitTag]
  if not i then return end
  local s = slots[i]
  local now = GetGameTimeMilliseconds()
  if isDead then
    finalize_pending(i, s)
    if s.open then close_episode(i, s, now, 2) end
    s.dead = true
  else
    s.dead = false
    s.grace_until = now + GRACE_RES_MS
  end
end

local function censor_tick()
  if not session_active then return end
  if names_dirty then
    names_dirty = false
    M.refresh_names()
  end
  local lat = api.GetLatency and api.GetLatency()
  if lat and lat > 0 then
    lat_sum = lat_sum + lat
    lat_n = lat_n + 1
  end
  local now = GetGameTimeMilliseconds()
  for i = 1, MAX_SLOTS do
    local s = slots[i]
    if s.p_active and (now - s.p_end) > DELTA_MS then
      finalize_pending(i, s)
    end
    if s.open and (now - s.last_t) > SIGMA_MS then
      close_episode(i, s, now, 3)
      bump("triage.episode.censored_stale")
    end
  end
end

local function reset_roster()
  for k in pairs(name_slot) do name_slot[k] = nil end
  name_count = 0
  player_slot_i = 0
  for i = 1, MAX_SLOTS do
    slot_names[i] = nil
    slot_icons[i] = nil
  end
end

function M.refresh_names()
  if not session_active then return end
  for i = 1, MAX_SLOTS do
    local nm = api.GetUnitName("group" .. i)
    if nm and nm ~= "" then
      local base = base_name(nm)
      local old = slot_names[i]
      if old and old ~= base and name_slot[old] == i then
        name_slot[old] = nil
      end
      slot_names[i] = base
      name_slot[base] = i
      local cid = api.GetUnitClassId("group" .. i)
      if cid and cid > 0 then
        slot_icons[i] = api.ZO_GetClassIcon(cid)
      end
    end
    if api.AreUnitsEqual("group" .. i, "player") then player_slot_i = i end
  end
  name_count = 0
  for i = 1, MAX_SLOTS do
    if slot_names[i] then name_count = name_count + 1 end
  end
end

function M.slot_name(i)
  return slot_names[i]
end

function M.slot_icon(i)
  return slot_icons[i]
end

function M.player_slot()
  return player_slot_i
end

function M.set_theta(v)
  if type(v) ~= "number" then return false end
  if v < THETA_MIN then v = THETA_MIN end
  if v > THETA_MAX then v = THETA_MAX end
  THETA      = v
  THETA_EXIT = v + THETA_HYST
  return true
end

function M.theta() return THETA end

function M.on_session_start()
  local sv = Verdant.SavedVars
  M.set_theta((sv and sv.settings and sv.settings.triage_theta) or 0.50)
  reset_roster()
  session_active = true
  ep_log.n = 0
  ep_dropped = 0
  pu_count = 0
  pu_first_t = 0
  pu_last_t = 0
  heal_matched = 0
  heal_unmatched = 0
  lat_sum = 0
  lat_n = 0
  for i = 1, MAX_SLOTS do
    local s = slots[i]
    s.open = false
    s.dead = false
    s.grace_until = 0
    s.last_t = 0
    s.p_active = false
  end
  M.refresh_names()
  Verdant.zenimax.events.register_update("Verdant_TriageCensor", CENSOR_TICK_MS, censor_tick)
end

function M.on_session_stop()
  if not session_active then return end
  local now = GetGameTimeMilliseconds()
  for i = 1, MAX_SLOTS do
    local s = slots[i]
    finalize_pending(i, s)
    if s.open then close_episode(i, s, now, 3) end
  end
  session_active = false
  Verdant.zenimax.events.unregister_update("Verdant_TriageCensor")
end

local rt_scratch = {}

function M.summary()
  local c = { s = 0, s_star = 0, o = 0, l = 0, m = 0, x = 0, oneshot = 0 }
  local rn = 0
  local resp = 0
  for i = 1, ep_log.n do
    local e = ep_log[i]
    if e.class == CLASS_S then
      c.s = c.s + 1
      if e.star then c.s_star = c.s_star + 1 end
    elseif e.class == CLASS_O then c.o = c.o + 1
    elseif e.class == CLASS_L then c.l = c.l + 1
    elseif e.class == CLASS_M then c.m = c.m + 1
    elseif e.class == CLASS_X then c.x = c.x + 1
    elseif e.class == CLASS_ONESHOT then c.oneshot = c.oneshot + 1
    end
    if e.responded then resp = resp + 1 end
    if e.rt >= 0 then
      rn = rn + 1
      rt_scratch[rn] = e.rt
    end
  end
  for i = rn + 1, #rt_scratch do rt_scratch[i] = nil end
  table_sort(rt_scratch)
  local rt50, rt95 = -1, -1
  if rn > 0 then
    local i50 = math_floor(rn * 0.50 + 0.5)
    local i95 = math_floor(rn * 0.95 + 0.5)
    if i50 < 1 then i50 = 1 end
    if i95 < 1 then i95 = 1 end
    rt50 = rt_scratch[i50]
    rt95 = rt_scratch[i95]
  end
  local denom = c.s + c.o + c.l + c.m
  return {
    episodes  = ep_log.n,
    dropped   = ep_dropped,
    counts    = c,
    responded = resp,
    rt_n      = rn,
    rt50      = rt50,
    rt95      = rt95,
    coverage  = (denom > 0) and (c.s / denom) or -1,
  }
end

function M.episodes() return ep_log, ep_log.n end
function M.is_active() return session_active end

function M.load_session(eps_list, roster, pslot)
  session_active = false
  Verdant.zenimax.events.unregister_update("Verdant_TriageCensor")
  for i = 1, MAX_SLOTS do
    local s = slots[i]
    s.open = false
    s.dead = false
    s.p_active = false
    slot_names[i] = nil
    slot_icons[i] = nil
  end
  for k in pairs(name_slot) do name_slot[k] = nil end
  name_count = 0
  for i = 1, #(roster or {}) do
    local r = roster[i]
    if r.slot and r.name then
      slot_names[r.slot] = r.name
      slot_icons[r.slot] = r.icon
      name_slot[r.name] = r.slot
      name_count = name_count + 1
    end
  end
  player_slot_i = pslot or 0
  ep_log.n = 0
  ep_dropped = 0
  for i = 1, #eps_list do
    local e = eps_list[i]
    ep_log.n = i
    local rec = ep_log[i]
    if not rec then rec = {}; ep_log[i] = rec end
    rec.slot      = e.slot
    rec.t_start   = e.ts
    rec.t_end     = e.ts + e.dur
    rec.class     = e.cls
    rec.star      = e.star == 1
    rec.rt        = (e.rt1 and e.rt1 > 0) and (e.rt1 - 1) or -1
    rec.min_rho   = e.rho
    rec.responded = e.resp == 1
  end
end

function M.power_stats()
  local dur = (pu_last_t > pu_first_t) and (pu_last_t - pu_first_t) or 0
  return {
    count = pu_count,
    rate  = (dur > 0) and (pu_count / (dur / 1000)) or 0,
    matched = heal_matched,
    unmatched = heal_unmatched,
  }
end

function M.avg_latency()
  return (lat_n > 0) and math_floor(lat_sum / lat_n + 0.5) or 0
end

function M.report_lines()
  local lines = {}
  local ps = M.power_stats()
  lines[#lines + 1] = string.format(
    "params: theta=%.2f exit=%.2f delta=%dms grace=%dms sigma=%dms min_ep=%dms",
    THETA, THETA_EXIT, DELTA_MS, GRACE_RES_MS, SIGMA_MS, MIN_EPISODE_MS)
  lines[#lines + 1] = string.format(
    "power_updates=%d  rate=%.1f/s  heals matched=%d unmatched=%d",
    ps.count, ps.rate, ps.matched, ps.unmatched)
  lines[#lines + 1] = string.format(
    "session_active=%s  name_map=%d entries", tostring(session_active), name_count)
  local s = M.summary()
  lines[#lines + 1] = string.format(
    "episodes=%d (dropped=%d)  S=%d (S*=%d)  O=%d  L=%d  M=%d  X=%d  oneshot=%d",
    s.episodes, s.dropped, s.counts.s, s.counts.s_star, s.counts.o,
    s.counts.l, s.counts.m, s.counts.x, s.counts.oneshot)
  if s.rt_n > 0 then
    lines[#lines + 1] = string.format(
      "RT50=%dms  RT95=%dms  measured=%d  responded=%d  coverage=%.0f%%  @ ping avg %dms",
      s.rt50, s.rt95, s.rt_n, s.responded,
      (s.coverage >= 0) and s.coverage * 100 or 0, M.avg_latency())
  else
    lines[#lines + 1] = "RT: no direct-heal responses measured (hot ticks never count)"
  end
  for i = 1, MAX_SLOTS do
    local sl = slots[i]
    if sl.open or sl.dead or sl.last_t > 0 then
      lines[#lines + 1] = string.format(
        "  group%d: open=%s dead=%s last_t=%d min_rho=%.2f",
        i, tostring(sl.open), tostring(sl.dead), sl.last_t, sl.min_rho)
    end
  end
  return lines
end

function M.init()
  log = Verdant.Log.for_module("triage")
  api = Verdant.zenimax.api
  GetGameTimeMilliseconds = api.GetGameTimeMilliseconds
  local C = Verdant.zenimax.constants
  CU_PLAYER    = C.COMBAT_UNIT_TYPE_PLAYER
  CU_GROUP     = C.COMBAT_UNIT_TYPE_GROUP
  AR_HEAL      = C.ACTION_RESULT_HEAL
  AR_CRIT_HEAL = C.ACTION_RESULT_CRITICAL_HEAL
  log:info("init: theta=", THETA, "exit=", THETA_EXIT, "slots=", MAX_SLOTS)
end
