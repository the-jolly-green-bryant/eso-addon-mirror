Verdant = Verdant or {}
local Verdant = Verdant

Verdant.SessionStore = {}
local M = Verdant.SessionStore

local math_floor = math.floor
local table_remove = table.remove

local CAP = 24

local DESC = {
  series = {
    { name = "t",       width = 4, delta = true },
    { name = "eHPS",    width = 4, scale = 10 },
    { name = "MPS",     width = 4, scale = 10 },
    { name = "crit",    width = 4, scale = 10 },
    { name = "noncrit", width = 4, scale = 10 },
    { name = "d",       width = 4, scale = 10 },
  },
  steps = {
    { name = "b", width = 1 },
    { name = "t", width = 4 },
    { name = "c", width = 1 },
  },
  episodes = {
    { name = "slot", width = 1 },
    { name = "ts",   width = 4 },
    { name = "dur",  width = 4 },
    { name = "cls",  width = 1 },
    { name = "rt1",  width = 3 },
    { name = "rho",  width = 2, scale = 1000 },
    { name = "resp", width = 1 },
    { name = "star", width = 1 },
  },
  markers = {
    { name = "t",     width = 4 },
    { name = "death", width = 1 },
    { name = "who",   width = 1 },
  },
  shares = {
    { name = "si",  width = 2 },
    { name = "ch",  width = 1 },
    { name = "key", width = 1 },
    { name = "sh",  width = 3, scale = 10000 },
  },
  abilities = {
    { name = "si", width = 2 },
    { name = "ch", width = 1 },
    { name = "id", width = 4 },
    { name = "sh", width = 2, scale = 1000 },
  },
}

M.DESC = DESC

local log
local api
local start_zone  = ""
local start_group = 0

function M.on_session_start()
  start_zone  = api.GetUnitZone("player") or ""
  start_group = api.GetGroupSize() or 0
end

local function lib_root()
  local sv = Verdant.SavedVars
  if not sv then return nil end
  sv.library = sv.library or { version = 1, sessions = {} }
  sv.library.sessions = sv.library.sessions or {}
  return sv.library
end

function M.capture()
  local TB = Verdant.TemporalBuffer
  local BT = Verdant.BuffTracker
  local T  = Verdant.Triage
  local vsf = Verdant.lib.vsf

  if TB.count() == 0 then return nil end
  local t0 = BT.session_start()
  local t_end = BT.session_end()
  local tb_sum = TB.summary()
  local tri = T.summary()

  local series = {}
  local share_recs = {}
  local gkeys = {}
  local gkey_idx = {}
  local function key_of(k)
    local idx = gkey_idx[k]
    if not idx then
      gkeys[#gkeys + 1] = k
      idx = #gkeys - 1
      gkey_idx[k] = idx
    end
    return idx
  end
  local function harvest(si, ch, groups)
    if si > 4095 then return end
    local n = (groups and groups.count) or 0
    for g = 1, n do
      local e = groups[g]
      share_recs[#share_recs + 1] = {
        si = si, ch = ch, key = key_of(e.key or "other"), sh = e.share or 0,
      }
    end
  end
  local ability_recs = {}
  local function harvest_abilities(si, ch, abilities)
    if si > 4095 then return end
    local n = (abilities and abilities.count) or 0
    for a = 1, n do
      local e = abilities[a]
      ability_recs[#ability_recs + 1] = {
        si = si, ch = ch, id = e.id or 0, sh = e.share or 0,
      }
    end
  end
  TB.iterate(function(i, s)
    series[#series + 1] = {
      t = s.t - t0, eHPS = s.eHPS, MPS = s.MPS,
      crit = s.crit, noncrit = s.noncrit, d = s.d,
    }
    harvest(#series, 0, s.ehps_groups)
    harvest(#series, 1, s.mps_groups)
    harvest_abilities(#series, 0, s.ehps_abilities)
    harvest_abilities(#series, 1, s.mps_abilities)
  end)

  local buffs_meta = {}
  local steps = {}
  local n_buffs = BT.count()
  if n_buffs > 64 then n_buffs = 64 end
  for i = 1, n_buffs do
    local rec = BT.get(i)
    buffs_meta[i] = {
      name = rec.name, id = rec.id, grp = rec.group,
      desc = rec.desc, uptime_ms = rec.uptime_ms,
      max_conc = rec.max_conc, only_self = rec.only_self or false,
      vetoed = rec.vetoed or false,
      unique_units = rec.unique_units or 0,
      applications = rec.applications or 0,
      conc_avg = rec.conc_avg or 0,
      longest_gap_ms = rec.longest_gap_ms or 0,
    }
    for k = 1, rec.n_steps do
      steps[#steps + 1] = {
        b = i - 1,
        t = rec.step_t[k] - t0,
        c = rec.step_c[k],
      }
    end
  end

  local eps, n_eps = T.episodes()
  local ep_recs = {}
  for i = 1, n_eps do
    local e = eps[i]
    ep_recs[i] = {
      slot = e.slot,
      ts   = e.t_start - t0,
      dur  = e.t_end - e.t_start,
      cls  = e.class,
      rt1  = (e.rt >= 0) and (e.rt + 1) or 0,
      rho  = e.min_rho,
      resp = e.responded and 1 or 0,
      star = e.star and 1 or 0,
    }
  end

  local ms, mn = TB.markers()
  local mk_recs = {}
  for i = 1, mn do
    local m = ms[i]
    local who = 0
    if m.who then
      who = tonumber(tostring(m.who):match("group(%d+)")) or 0
    end
    mk_recs[i] = { t = m.t - t0, death = m.death and 1 or 0, who = who }
  end

  local roster = {}
  for i = 1, 12 do
    local nm = T.slot_name(i)
    if nm then
      roster[#roster + 1] = { slot = i, name = nm, icon = T.slot_icon(i) }
    end
  end

  local sv = Verdant.SavedVars
  local theta = (sv and sv.settings and sv.settings.triage_theta) or 0.50

  local session = {
    v = 1,
    head = {
      ts = api.GetTimeStamp(),
      zone = (start_zone ~= "") and start_zone or (api.GetUnitZone("player") or ""),
      dur_ms = t_end - t0,
      group_size = math.max(start_group, api.GetGroupSize() or 0, #roster),
      build = Verdant.Constants.BUILD,
      api = api.GetAPIVersion(),
      locked = false,
      player_slot = T.player_slot(),
      sum = {
        avg = math_floor(tb_sum.avg_ems + 0.5),
        peak = math_floor(tb_sum.peak_ems + 0.5),
        crit_pct = tb_sum.crit_pct,
        active_pct = tb_sum.active_pct,
        total_heal = tb_sum.total_heal,
        total_shield = tb_sum.total_shield,
        saves = tri.counts.s, s_star = tri.counts.s_star,
        o = tri.counts.o, l = tri.counts.l, m = tri.counts.m,
        oneshot = tri.counts.oneshot, x = tri.counts.x,
        eps = tri.episodes, rt50 = tri.rt50, rt95 = tri.rt95,
      },
      cfg = { theta = theta, ping = T.avg_latency() },
    },
    roster = roster,
    buffs = buffs_meta,
    gkeys = gkeys,
    desc = DESC,
    streams = {
      series    = vsf.pack(series, DESC.series),
      steps     = vsf.pack(steps, DESC.steps),
      episodes  = vsf.pack(ep_recs, DESC.episodes),
      markers   = vsf.pack(mk_recs, DESC.markers),
      shares    = vsf.pack(share_recs, DESC.shares),
      abilities = vsf.pack(ability_recs, DESC.abilities),
    },
  }
  return session
end

function M.store(session)
  local lib = lib_root()
  if not lib then return false end
  local sessions = lib.sessions
  sessions[#sessions + 1] = session
  local i = 1
  while #sessions > CAP and i <= #sessions do
    if not (sessions[i].head and sessions[i].head.locked) then
      table_remove(sessions, i)
    else
      i = i + 1
    end
  end
  Verdant.Diagnostics.bump("library.session_stored")
  return true
end

function M.on_session_stop()
  local sv = Verdant.SavedVars
  if not (sv and sv.settings and sv.settings.session_autosave) then return end
  local session = M.capture()
  if session then
    M.store(session)
    if log then
      log:info("session autosaved: zone=", session.head.zone,
               "dur=", session.head.dur_ms, "ms")
    end
  end
end

function M.count()
  local lib = lib_root()
  return lib and #lib.sessions or 0
end

function M.get(i)
  local lib = lib_root()
  return lib and lib.sessions[i] or nil
end

function M.delete(i)
  local lib = lib_root()
  if lib and lib.sessions[i] then
    table_remove(lib.sessions, i)
    return true
  end
  return false
end

function M.set_locked(i, locked)
  local s = M.get(i)
  if s and s.head then
    s.head.locked = locked and true or false
    return true
  end
  return false
end

local function session_bytes(s)
  local total = 0
  for _, st in pairs(s.streams or {}) do
    for _, c in ipairs(st.data or {}) do total = total + #c end
  end
  return total
end

function M.report_lines()
  local lib = lib_root()
  local lines = {}
  local sv = Verdant.SavedVars
  local auto = sv and sv.settings and sv.settings.session_autosave and "ON" or "off"
  local n = lib and #lib.sessions or 0
  local total = 0
  local locked = 0
  for i = 1, n do
    total = total + session_bytes(lib.sessions[i])
    if lib.sessions[i].head and lib.sessions[i].head.locked then locked = locked + 1 end
  end
  lines[#lines + 1] = string.format(
    "sessions=%d/%d (locked=%d)  packed=%.1f KB  autosave=%s",
    n, CAP, locked, total / 1024, auto)
  for i = math.max(1, n - 4), n do
    local h = lib.sessions[i].head
    lines[#lines + 1] = string.format(
      "  [%d] %s  %ds  grp=%d  avg=%d peak=%d  S=%d/%d%s",
      i, h.zone, math_floor(h.dur_ms / 1000), h.group_size,
      h.sum.avg, h.sum.peak, h.sum.saves,
      h.sum.saves + h.sum.o + h.sum.l + h.sum.m,
      h.locked and "  LOCKED" or "")
  end
  return lines
end

function M.init()
  log = Verdant.Log.for_module("session_store")
  api = Verdant.zenimax.api
end
