Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.SessionStore = {}
local M = Vermilion.SessionStore

local math_floor = math.floor
local table_remove = table.remove

local CAP = 24

local DESC = {
  series = {
    { name = "t",       width = 4, delta = true },
    { name = "eDPS",    width = 4, scale = 10 },
    { name = "ShDPS",   width = 4, scale = 10 },
    { name = "crit",    width = 4, scale = 10 },
    { name = "noncrit", width = 4, scale = 10 },
  },
  steps = {
    { name = "b", width = 1 },
    { name = "t", width = 4 },
    { name = "c", width = 1 },
  },
  shares = {
    { name = "si",  width = 2 },
    { name = "ch",  width = 1 },
    { name = "key", width = 1 },
    { name = "sh",  width = 3, scale = 10000 },
  },
  abilities = {
    { name = "si",  width = 2 },
    { name = "ch",  width = 1 },
    { name = "id",  width = 4 },
    { name = "key", width = 1 },
    { name = "sh",  width = 2, scale = 1000 },
  },
}

M.DESC = DESC
M.CH_SKILL = 0
M.CH_DTYPE = 1

local log
local api
local start_zone  = ""
local start_group = 0
local start_diff  = 0
local start_kind  = nil
local start_ms    = nil
local end_ms      = nil

function M.on_session_start()
  start_zone  = api.GetUnitZone("player") or ""
  start_group = api.GetGroupSize() or 0
  start_diff  = api.GetCurrentZoneDungeonDifficulty and api.GetCurrentZoneDungeonDifficulty() or 0
  start_kind  = Vermilion.ContentKind and Vermilion.ContentKind.detect() or nil
  start_ms    = api.GetGameTimeMilliseconds()
  end_ms      = nil
end

function M.session_start() return start_ms end

local function lib_root()
  local sv = Vermilion.SavedVars
  if not sv then return nil end
  sv.library = sv.library or { version = 1, sessions = {} }
  sv.library.sessions = sv.library.sessions or {}
  return sv.library
end

local YIELD_EVERY = 40

function M.capture(cooperative)
  local ye = cooperative and YIELD_EVERY or nil
  local coroutine_yield = coroutine.yield
  local TB = Vermilion.TemporalBuffer
  local vsf = Vermilion.lib.vsf

  local n_series = TB.count()
  if n_series == 0 then return nil end
  local first_t = TB.at(1).t
  local t0 = start_ms or first_t
  if first_t < t0 then t0 = first_t end
  local t_end = end_ms or api.GetGameTimeMilliseconds()
  local last_t = TB.at(n_series).t
  if t_end < last_t then t_end = last_t end

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
        si = si, ch = ch, key = key_of(e.key == nil and "other" or e.key), sh = e.share or 0,
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
        si = si, ch = ch, id = e.id or 0, key = key_of(e.key == nil and "other" or e.key), sh = e.share or 0,
      }
    end
  end

  local sum_eos, peak_eos = 0, 0
  local sum_edps, peak_edps = 0, 0
  local sum_crit, sum_noncrit = 0, 0
  local active = 0
  for i = 1, n_series do
    local s = TB.at(i)
    local eos = s.eDPS + s.ShDPS
    sum_eos = sum_eos + eos
    if eos > peak_eos then peak_eos = eos end
    sum_edps = sum_edps + s.eDPS
    if s.eDPS > peak_edps then peak_edps = s.eDPS end
    sum_crit = sum_crit + (s.crit or 0)
    sum_noncrit = sum_noncrit + (s.noncrit or 0)
    if s.eDPS > 0 then active = active + 1 end
    harvest(i, 0, s.eos_groups)
    harvest(i, 1, s.dtype_groups)
    harvest_abilities(i, 0, s.eos_abilities)
    harvest_abilities(i, 1, s.dtype_abilities)
    if ye and i % ye == 0 then coroutine_yield() end
  end
  local function series_get(r, name)
    local s = TB.at(r)
    if name == "t" then return s.t - t0 end
    return s[name] or 0
  end

  local DT = Vermilion.DebuffTracker
  local debuffs_meta = {}
  local steps = {}
  local n_debuffs = DT and DT.count() or 0
  if n_debuffs > 64 then n_debuffs = 64 end
  for i = 1, n_debuffs do
    local rec = DT.get(i)
    debuffs_meta[i] = {
      name = rec.name, id = rec.id, grp = rec.group, desc = rec.desc,
      uptime_ms = rec.uptime_ms, max_conc = rec.max_conc,
      unique_units = rec.unique_units or 0, applications = rec.applications or 0,
      conc_avg = DT.avg_concurrency(rec), longest_gap_ms = rec.longest_gap_ms or 0,
    }
    for k = 1, rec.n_steps do
      local rel = rec.step_t[k] - t0
      if rel < 0 then rel = 0 end
      steps[#steps + 1] = { b = i - 1, t = rel, c = rec.step_c[k] }
    end
  end

  local total_damage, total_shield, total_crit, hits = Vermilion.Metrics.totals()
  local sv = Vermilion.SavedVars
  local temporal = sv and sv.temporal or {}
  local C = Vermilion.Constants

  local session = {
    v = 1,
    head = {
      ts = api.GetTimeStamp(),
      zone = (start_zone ~= "") and start_zone or (api.GetUnitZone("player") or ""),
      dur_ms = t_end - t0,
      group_size = math.max(start_group, api.GetGroupSize() or 0),
      build = C.VERSION,
      api = api.GetAPIVersion(),
      locked = false,
      difficulty = start_diff or 0,
      kind = start_kind,
      sum = {
        avg = math_floor(sum_eos / n_series + 0.5),
        peak = math_floor(peak_eos + 0.5),
        avg_edps = math_floor(sum_edps / n_series + 0.5),
        peak_edps = math_floor(peak_edps + 0.5),
        crit_pct = (sum_crit + sum_noncrit) > 0 and (sum_crit / (sum_crit + sum_noncrit)) or 0,
        active_pct = active / n_series,
        total_damage = total_damage,
        total_shield = total_shield,
        total_crit = total_crit,
        hits = hits,
      },
      cfg = {
        window_ms = math_floor(Vermilion.Metrics.window_seconds() * 1000 + 0.5),
        shield_window_ms = math_floor(Vermilion.Metrics.shield_window_seconds() * 1000 + 0.5),
        sample_rate_ms = temporal.sample_rate_ms or C.TEMPORAL.SAMPLE_RATE_DEFAULT,
      },
    },
    gkeys = gkeys,
    debuffs = debuffs_meta,
    desc = DESC,
    streams = {
      series    = vsf.pack(series_get, DESC.series, n_series, ye),
      steps     = vsf.pack(steps, DESC.steps, nil, ye),
      shares    = vsf.pack(share_recs, DESC.shares, nil, ye),
      abilities = vsf.pack(ability_recs, DESC.abilities, nil, ye),
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
  Vermilion.Diagnostics.bump("library.session_stored")
  return true
end

local autosave_co = nil
local autosave_frames = 0
local manual_pending = false

local function autosave_finish(session)
  Vermilion.zenimax.events.unregister_update("VermilionAutosave")
  autosave_co = nil
  if M.on_save_end then M.on_save_end(session ~= nil) end
  if session then
    if manual_pending then session.head.manual = true end
    manual_pending = false
    M.store(session)
    if log then
      log:info("session autosaved: zone=", session.head.zone,
               "dur=", session.head.dur_ms, "ms", "frames=", autosave_frames)
    end
    if M.on_saved then M.on_saved(session) end
  end
end

local function autosave_step()
  if not autosave_co then return end
  if Vermilion.Hitch then Vermilion.Hitch.mark("stop") end
  autosave_frames = autosave_frames + 1
  local ok, res = coroutine.resume(autosave_co)
  if not ok then
    if log then log:warn("autosave failed:", tostring(res)) end
    autosave_finish(nil)
    return
  end
  if coroutine.status(autosave_co) == "dead" then
    autosave_finish(res)
  end
end

local function begin_capture()
  M.finish_autosave()
  autosave_frames = 0
  autosave_co = coroutine.create(function() return M.capture(true) end)
  Vermilion.zenimax.events.register_update("VermilionAutosave", 1, autosave_step)
  if M.on_save_begin then M.on_save_begin() end
end

function M.on_session_stop()
  end_ms = api.GetGameTimeMilliseconds()
  local sv = Vermilion.SavedVars
  if not (sv and sv.settings and sv.settings.session_autosave) then return end
  manual_pending = false
  begin_capture()
end

function M.save_now()
  if Vermilion.TemporalBuffer.count() == 0 then return false end
  begin_capture()
  manual_pending = true
  return true
end

function M.autosave_pending()
  return autosave_co ~= nil
end

function M.finish_autosave()
  local guard = 0
  while autosave_co and guard < 10000 do
    autosave_step()
    guard = guard + 1
  end
end

function M.set_label(idx, text)
  local lib = lib_root()
  local s = lib and lib.sessions[idx]
  if not s or not s.head then return false end
  text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if text == "" then s.head.label = nil else s.head.label = text end
  return true
end

function M.count()
  local lib = lib_root()
  return lib and #lib.sessions or 0
end

function M.cap() return CAP end

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
  local sv = Vermilion.SavedVars
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
      "  [%d] %s  %ds  grp=%d  avg=%d peak=%d  dmg=%d%s",
      i, h.zone, math_floor(h.dur_ms / 1000), h.group_size,
      h.sum.avg, h.sum.peak, h.sum.total_damage or 0,
      h.locked and "  LOCKED" or "")
  end
  return lines
end

function M.init()
  log = Vermilion.Log.for_module("session_store")
  api = Vermilion.zenimax.api
end
