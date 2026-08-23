Verdant = Verdant or {}
local Verdant = Verdant

Verdant.AutoRecord = {}
local M = Verdant.AutoRecord

local log = Verdant.Log.for_module("auto_record")

local MODE_OFF    = "off"
local MODE_BOSS   = "boss"
local MODE_COMBAT = "combat"

local MODES = { MODE_OFF, MODE_BOSS, MODE_COMBAT }

local GRACE_MS  = 5000
local TICK_MS   = 1000
local TICK_NAME = "VerdantAutoRecTick"
local HIST_CAP  = 12

local mode           = MODE_OFF
local in_combat      = false
local boss_present   = false
local boss_name      = nil
local auto_active    = false
local session_auto   = false
local grace_deadline = nil
local hist           = {}
local hist_n         = 0

local function bump(key) Verdant.Diagnostics.bump(key) end

local function now_ms()
  return Verdant.zenimax.api.GetGameTimeMilliseconds()
end

local function push_hist(what)
  hist_n = hist_n + 1
  local slot = ((hist_n - 1) % HIST_CAP) + 1
  local rec = hist[slot]
  if not rec then rec = {}; hist[slot] = rec end
  rec.t = now_ms()
  rec.what = what
end

local function scan_bosses()
  local api = Verdant.zenimax.api
  local zc  = Verdant.zenimax.constants
  local found, name = false, nil
  for i = zc.BOSS_RANK_ITERATION_BEGIN, zc.BOSS_RANK_ITERATION_END do
    local tag = "boss" .. i
    if api.DoesUnitExist(tag) then
      found = true
      if name == nil then name = api.GetUnitName(tag) end
    end
  end
  return found, name
end

local function should_record()
  if mode == MODE_COMBAT then return in_combat end
  if mode == MODE_BOSS then return in_combat and boss_present end
  return false
end

local function try_start()
  local TB = Verdant.TemporalBuffer
  if TB.is_recording() then
    bump("autorec.blocked_recording")
    return
  end
  if TB.count() > 0 and not session_auto then
    bump("autorec.blocked_manual_session")
    push_hist("blocked_manual_session")
    log:info("auto-start blocked: manual frozen session present")
    return
  end
  bump("autorec.start")
  push_hist(boss_present and ("start boss=" .. tostring(boss_name)) or "start combat")
  log:info("auto-start", boss_present and boss_name or "combat")
  Verdant.Graph.on_record_click()
  auto_active  = true
  session_auto = true
end

local function do_stop(reason)
  bump("autorec.stop_" .. reason)
  push_hist("stop " .. reason)
  log:info("auto-stop:", reason)
  auto_active    = false
  grace_deadline = nil
  Verdant.Graph.on_stop_click()
end

local function evaluate()
  if mode == MODE_OFF then return end
  if should_record() then
    if grace_deadline then
      bump("autorec.grace_cancelled")
      push_hist("grace cancelled")
      grace_deadline = nil
    end
    if not Verdant.TemporalBuffer.is_recording() then
      try_start()
    end
  else
    if auto_active and Verdant.TemporalBuffer.is_recording() and grace_deadline == nil then
      grace_deadline = now_ms() + GRACE_MS
      push_hist("grace armed")
      bump("autorec.grace_armed")
    end
  end
end

function M.on_combat_state(inCombat)
  in_combat = inCombat and true or false
  bump(in_combat and "autorec.combat_in" or "autorec.combat_out")
  evaluate()
end

function M.on_bosses_changed()
  local found, name = scan_bosses()
  bump("autorec.bosses_changed")
  if found ~= boss_present then
    bump(found and "autorec.boss_appeared" or "autorec.boss_cleared")
    push_hist(found and ("boss+ " .. tostring(name)) or "boss-")
    log:info("boss roster:", found and name or "(cleared)")
  end
  boss_present = found
  boss_name    = name
  evaluate()
end

function M.on_zone_changed()
  if auto_active and Verdant.TemporalBuffer.is_recording() then
    do_stop("zone")
  end
  in_combat    = false
  boss_present = false
  boss_name    = nil
  grace_deadline = nil
end

local function tick()
  if mode == MODE_OFF then return end
  local api = Verdant.zenimax.api
  local live = api.IsUnitInCombat("player") and true or false
  if live ~= in_combat then
    bump("autorec.combat_poll_fix")
    in_combat = live
    evaluate()
  end
  if grace_deadline and now_ms() >= grace_deadline then
    if auto_active and Verdant.TemporalBuffer.is_recording() then
      do_stop("grace")
    else
      grace_deadline = nil
    end
  end
end

function M.notify_manual_record()
  auto_active    = false
  session_auto   = false
  grace_deadline = nil
end

function M.notify_manual_stop()
  if auto_active then
    bump("autorec.manual_stop_override")
    push_hist("manual stop")
  end
  auto_active    = false
  grace_deadline = nil
end

function M.is_auto_session() return session_auto end
function M.is_auto_active()  return auto_active end
function M.get_mode()        return mode end
function M.modes()           return MODES end

function M.set_mode(m)
  local valid = false
  for i = 1, #MODES do
    if MODES[i] == m then valid = true break end
  end
  if not valid then return false end
  if m == mode then return true end
  log:info("mode:", mode, "->", m)
  push_hist("mode " .. m)
  mode = m
  local zev = Verdant.zenimax.events
  if mode == MODE_OFF then
    zev.unregister_update(TICK_NAME)
    if auto_active and Verdant.TemporalBuffer.is_recording() then
      do_stop("disabled")
    end
    grace_deadline = nil
  else
    zev.register_update(TICK_NAME, TICK_MS, tick)
    local found, name = scan_bosses()
    boss_present = found
    boss_name    = name
    in_combat    = Verdant.zenimax.api.IsUnitInCombat("player") and true or false
    evaluate()
  end
  local sv = Verdant.SavedVars
  if sv then
    sv.settings = sv.settings or {}
    sv.settings.auto_record = mode
  end
  return true
end

function M.report_lines()
  local lines = {}
  lines[#lines + 1] = string.format(
    "mode=%s  state=%s  in_combat=%s  boss=%s  grace=%s",
    mode,
    auto_active and (grace_deadline and "GRACE" or "RECORDING") or "IDLE",
    tostring(in_combat),
    boss_present and tostring(boss_name) or "none",
    grace_deadline and string.format("%.1fs", (grace_deadline - now_ms()) / 1000) or "-")
  local n_show = (hist_n < HIST_CAP) and hist_n or HIST_CAP
  for i = hist_n - n_show + 1, hist_n do
    local rec = hist[((i - 1) % HIST_CAP) + 1]
    lines[#lines + 1] = string.format("t=%d  %s", rec.t, rec.what)
  end
  if hist_n == 0 then lines[#lines + 1] = "(no transitions yet)" end
  return lines
end

function M.snapshot()
  return {
    mode = mode, in_combat = in_combat, boss_present = boss_present,
    boss_name = boss_name, auto_active = auto_active,
    session_auto = session_auto, grace_deadline = grace_deadline,
    transitions = hist_n,
  }
end

function M.init()
  local sv = Verdant.SavedVars
  local zev = Verdant.zenimax.events
  local zc  = Verdant.zenimax.constants

  zev.register("Verdant_AR_Combat", zc.EVENT_PLAYER_COMBAT_STATE, function(inCombat)
    M.on_combat_state(inCombat)
  end)
  zev.register("Verdant_AR_Bosses", zc.EVENT_BOSSES_CHANGED, M.on_bosses_changed)
  zev.register("Verdant_AR_Zone", zc.EVENT_PLAYER_ACTIVATED, M.on_zone_changed)

  local saved = sv and sv.settings and sv.settings.auto_record or MODE_OFF
  mode = MODE_OFF
  M.set_mode(saved)
  log:info("init: mode=", mode)
end
