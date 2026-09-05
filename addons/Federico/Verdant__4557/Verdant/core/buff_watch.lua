Verdant = Verdant or {}
local Verdant = Verdant

Verdant.BuffWatch = {}
local M = Verdant.BuffWatch

local pairs      = pairs
local math_huge  = math.huge
local log        = Verdant.Log.for_module("buff_watch")

local TICK_NAME = "VerdantBuffWatch"
local TICK_MS   = 250
local THR_CYCLE = { 3, 5, 8 }
local ALERT_CAP = 4

local C

local watched    = {}
local watch_list = {}
local n_watched  = 0
local id_cache   = {}

local alerts = { n = 0 }
for i = 1, ALERT_CAP do alerts[i] = { name = "", id = 0, remaining = 0 } end

local function bump(key) Verdant.Diagnostics.bump(key) end

local function wipe(t)
  for k in pairs(t) do t[k] = nil end
end

local function sv_root()
  local sv = Verdant.SavedVars
  if not sv then return nil end
  sv.settings = sv.settings or {}
  sv.settings.buff_watch = sv.settings.buff_watch or {}
  return sv.settings.buff_watch
end

local function tick()
  local api   = Verdant.zenimax.api
  local now_s = api.GetGameTimeMilliseconds() / 1000
  local in_combat = api.IsUnitInCombat("player") and true or false
  local n = 0
  local chime = 0
  for i = 1, n_watched do
    local w = watch_list[i]
    local stage = 0
    if w.seen and w.end_s ~= math_huge and n < ALERT_CAP then
      local remaining = w.end_s - now_s
      local firing = false
      if remaining <= 0 then
        firing = in_combat
        remaining = 0
        if firing then stage = 2 end
      elseif remaining <= w.thr then
        firing = true
        stage = 1
      end
      if firing then
        n = n + 1
        local a = alerts[n]
        a.name = w.name
        a.id = w.id
        a.remaining = remaining
      end
    end
    if stage > (w.stage or 0) and stage > chime then chime = stage end
    w.stage = stage
  end
  alerts.chime = chime
  for i = 2, n do
    local j = i
    while j > 1 and alerts[j].remaining < alerts[j - 1].remaining do
      alerts[j], alerts[j - 1] = alerts[j - 1], alerts[j]
      j = j - 1
    end
  end
  alerts.n = n
  if Verdant.Watch then Verdant.Watch.render(alerts) end
end

local function sync_tick()
  local zev = Verdant.zenimax.events
  if n_watched > 0 then
    zev.register_update(TICK_NAME, TICK_MS, tick)
  else
    zev.unregister_update(TICK_NAME)
    alerts.n = 0
    if Verdant.Watch then Verdant.Watch.render(alerts) end
  end
end

local function rebuild_list()
  n_watched = 0
  for _, w in pairs(watched) do
    n_watched = n_watched + 1
    watch_list[n_watched] = w
  end
  for i = n_watched + 1, #watch_list do watch_list[i] = nil end
  wipe(id_cache)
  sync_tick()
end

function M.toggle(name, id)
  if not name or name == "" then return nil end
  local store = sv_root()
  local w = watched[name]
  local thr
  if not w then
    thr = THR_CYCLE[1]
  else
    local idx
    for i = 1, #THR_CYCLE do
      if THR_CYCLE[i] == w.thr then idx = i break end
    end
    thr = idx and THR_CYCLE[idx + 1] or nil
  end
  if thr then
    if w then
      w.thr = thr
    else
      watched[name] = { name = name, thr = thr, id = id or 0, end_s = 0, seen = false }
    end
    if store then store[name] = thr end
    bump("watch.armed")
    log:info("watch", name, "-> <", thr, "s")
  else
    watched[name] = nil
    if store then store[name] = nil end
    bump("watch.disarmed")
    log:info("watch", name, "-> off")
  end
  rebuild_list()
  return thr
end

function M.thr(name)
  local w = watched[name]
  return w and w.thr or nil
end

function M.on_effect(changeType, abilityId, unitId, endTime, now_ms, unitTag)
  if n_watched == 0 then return end
  if not abilityId or abilityId == 0 then return end
  if unitTag ~= "player" and unitId ~= Verdant.GroupSet.player_id() then return end

  local w = id_cache[abilityId]
  if w == nil then
    w = watched[Verdant.SkillColors.ability_name(abilityId)] or false
    id_cache[abilityId] = w
  end
  if w == false then return end

  w.id = abilityId
  w.seen = true
  if changeType == C.EFFECT_RESULT_FADED then
    w.end_s = 0
  else
    w.end_s = (endTime and endTime > 0) and endTime or math_huge
  end
end

function M.count() return n_watched end

function M.snapshot()
  local list = {}
  for i = 1, n_watched do
    local w = watch_list[i]
    list[i] = { name = w.name, thr = w.thr, id = w.id, end_s = w.end_s, seen = w.seen }
  end
  return { watched = n_watched, alerts = alerts.n, list = list }
end

function M.report_lines()
  local lines = {}
  lines[#lines + 1] = string.format("watched=%d alerts=%d", n_watched, alerts.n)
  for i = 1, n_watched do
    local w = watch_list[i]
    lines[#lines + 1] = string.format("  %-28s thr=%ds end_s=%s seen=%s",
      w.name, w.thr, (w.end_s == math_huge) and "inf" or string.format("%.1f", w.end_s),
      tostring(w.seen))
  end
  return lines
end

function M.init()
  C = Verdant.zenimax.constants
  local store = sv_root()
  if store then
    for name, thr in pairs(store) do
      if type(thr) == "number" then
        watched[name] = { name = name, thr = thr, id = 0, end_s = 0, seen = false }
      end
    end
  end
  rebuild_list()
  log:info("init: watched=", n_watched)
end
