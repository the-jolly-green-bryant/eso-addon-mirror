
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.DeathRecap = {}
local M = Verditer.DeathRecap

local api = Verditer.zenimax.api
local zc  = Verditer.zenimax.constants
local ev  = Verditer.zenimax.events
local C   = Verditer.Constants

local GetGameTimeMilliseconds       = api.GetGameTimeMilliseconds
local GetNumKillingAttacks          = api.GetNumKillingAttacks
local GetKillingAttackInfo          = api.GetKillingAttackInfo
local DoesKillingAttackHaveAttacker = api.DoesKillingAttackHaveAttacker
local GetKillingAttackerInfo        = api.GetKillingAttackerInfo
local IsUnitDead                    = api.IsUnitDead
local GetCurrentMapZoneIndex        = api.GetCurrentMapZoneIndex
local GetZoneNameByIndex            = api.GetZoneNameByIndex

local table_sort  = table.sort
local table_remove = table.remove
local math_max    = math.max
local math_floor  = math.floor
local math_ceil   = math.ceil

local log = Verditer.Log.for_module("death_recap")

local deaths  = {}    -- recent deaths, oldest..newest, capped at RECAP.MAX_DEATHS
local sel_idx = 0     -- index currently shown in the window (1..#deaths)
local enabled = true  -- Death Recap on/off (SavedVar, default on). When off the lead
                      -- ring + death/respawn hooks are UNREGISTERED → genuinely zero cost.

local lead_ring = {}
local lead_cap, lead_ms = 0, 250
local lead_w, lead_n = 1, 0

local type_scratch = { count = 0 }
local src_scratch  = { count = 0 }

local function current_zone()
  if GetCurrentMapZoneIndex and GetZoneNameByIndex then
    local idx = GetCurrentMapZoneIndex()
    if idx then
      local n = GetZoneNameByIndex(idx)
      if n and n ~= "" then return zo_strformat("<<1>>", n) end
    end
  end
  return ""
end

local function count_attackers(scratch)
  local c = 0
  for i = 1, (scratch.count or 0) do
    local g = scratch[i]
    if g and g.uid ~= 0 then c = c + 1 end
  end
  return c
end

local function copy_types(out_arr, scratch)
  local n = scratch.count or 0
  for i = 1, n do
    local s = scratch[i]
    local dst = out_arr[i]
    if not dst then dst = {}; out_arr[i] = dst end
    dst.r = s.r; dst.g = s.g; dst.b = s.b; dst.a = s.a; dst.share = s.share; dst.dt = s.dt
  end
  out_arr.count = n
end

local function attacker_name(i)
  local rawName, _cp, _lvl, _ava, isPlayer, _isBoss, _alliance, minionName, displayName
        = GetKillingAttackerInfo(i)
  local nm
  if isPlayer and ZO_GetPrimaryPlayerName then
    nm = ZO_GetPrimaryPlayerName(displayName, rawName)
  else
    nm = rawName
  end
  nm = nm or ""
  if nm ~= "" then nm = zo_strformat(SI_UNIT_NAME, nm) end
  if (minionName or "") ~= "" then
    nm = nm .. " (" .. zo_strformat(SI_UNIT_NAME, minionName) .. ")"
  end
  return nm
end

local function lead_tick()
  local now     = GetGameTimeMilliseconds()
  local Metrics = Verditer.Metrics
  local slot    = lead_ring[lead_w]
  slot.t    = now
  slot.hp   = Metrics.hp_current()
  slot.dtps = Metrics.DTPS(now)
  slot.abs  = Metrics.ABS(now)
  lead_w = (lead_w % lead_cap) + 1
  if lead_n < lead_cap then lead_n = lead_n + 1 end
end


local function freeze_lead(rec)
  local lead   = rec.lead
  local n      = lead_n
  local cap    = lead_cap
  local oldest = (n >= cap) and lead_w or 1
  local peak, last_shield, peak_idx = 0, 0, 0
  local prev_hp = -1
  for i = 1, n do
    local idx = ((oldest - 1 + i - 1) % cap) + 1
    local s   = lead_ring[idx]
    local d   = lead[i]
    if not d then d = {}; lead[i] = d end
    d.t = s.t; d.hp = s.hp; d.dtps = s.dtps; d.abs = s.abs
    local hp = s.hp or 0
    d.hp_drop = (prev_hp >= 0 and hp >= 0) and math_max(0, prev_hp - hp) or 0
    prev_hp = hp
    if (s.dtps or 0) > peak then peak = s.dtps; peak_idx = i end   -- argmax frame for the marker
    if (s.abs or 0) > 0 then last_shield = i end
  end

  if n > 0 then
    local last = lead[n]
    local zi   = n + 1
    local d    = lead[zi]
    if not d then d = {}; lead[zi] = d end
    d.t       = (last.t or 0) + lead_ms
    d.hp      = 0
    d.dtps    = last.dtps or 0
    d.abs     = 0
    d.hp_drop = math_max(0, last.hp or 0)
    n = zi
  end

  lead.count        = n
  lead.shield_break = (last_shield > 0 and last_shield < n) and last_shield or nil
  lead.peak_idx     = (peak_idx > 0) and peak_idx or nil
  if peak > 0 and rec.pressure then rec.pressure.peak_dtps = peak end
end

local function commit(rec)
  deaths[#deaths + 1] = rec
  while #deaths > (C.RECAP.MAX_DEATHS or 5) do table_remove(deaths, 1) end
  sel_idx = #deaths
  log:info("death committed: attacks=", #rec.attacks, " killer=",
           rec.killer and rec.killer.name or "?")
  if Verditer.Recap then
    if Verditer.Sound then Verditer.Sound.play("WINDOW_OPEN") end
    Verditer.Recap.show_record(sel_idx)
  end
  if Verditer.Graph and Verditer.Graph.notify_deaths_changed then
    Verditer.Graph.notify_deaths_changed()
  end
end

local function finalize(rec)
  local n = GetNumKillingAttacks and GetNumKillingAttacks() or 0
  local cap = C.RECAP.MAX_ATTACKS or 6
  for i = 1, n do
    local name, dmg, icon, kb, _castAgo, _dur, hits = GetKillingAttackInfo(i)
    local who = ""
    if DoesKillingAttackHaveAttacker and DoesKillingAttackHaveAttacker(i) then
      who = attacker_name(i)
    end
    rec.attacks[#rec.attacks + 1] = {
      name     = name or "",
      icon     = icon,
      dmg      = dmg or 0,
      kb       = kb and true or false,
      hits     = hits or 1,
      attacker = who,
    }
  end

  table_sort(rec.attacks, function(a, b) return a.dmg > b.dmg end)
  while #rec.attacks > cap do table_remove(rec.attacks) end

  local verdict
  for i = 1, #rec.attacks do
    if rec.attacks[i].kb then verdict = rec.attacks[i]; break end
  end
  rec.killer = verdict or rec.attacks[1]

  commit(rec)
end

local function on_player_dead()
  if not (IsUnitDead and IsUnitDead("player")) then return end
  local now     = GetGameTimeMilliseconds()
  local Metrics = Verditer.Metrics

  Metrics.type_groups_into(type_scratch, now)
  Metrics.source_groups_into(src_scratch, now)
  local maxhp    = Metrics.max_health()
  local overkill = Metrics.recent_overflow(now, 3000)

  local rec = {
    ts           = now,
    zone         = current_zone(),
    overkill_pct = (maxhp > 0 and overkill > 0) and (overkill / maxhp) or 0,
    pressure     = {
      dtps      = Metrics.DTPS(now),
      abs       = Metrics.ABS(now),
      peak_dtps = Metrics.DTPS(now),     -- true peak needs the lead ring (incr. 2)
      attackers = count_attackers(src_scratch),   -- enemies only (env bucket excluded)
      types     = {},
    },
    attacks = {},
    killer  = nil,
    lead    = {},
  }
  copy_types(rec.pressure.types, type_scratch)
  freeze_lead(rec)

  ev.register_update("VerditerRecapServerRead", C.RECAP.SERVER_DELAY_MS, function()
    ev.unregister_update("VerditerRecapServerRead")
    finalize(rec)
  end)
end

function M.count()        return #deaths        end
function M.get(idx)       return deaths[idx]    end
function M.selected_idx() return sel_idx        end
function M.select(idx)
  if idx >= 1 and idx <= #deaths then sel_idx = idx; return true end
  return false
end

function M.clear()
  for i = #deaths, 1, -1 do deaths[i] = nil end
  sel_idx = 0
  if Verditer.Recap and Verditer.Recap.on_close then Verditer.Recap.on_close() end
  if Verditer.Graph and Verditer.Graph.notify_deaths_changed then
    Verditer.Graph.notify_deaths_changed()
  end
  log:info("deaths cleared")
end

local function on_player_alive()
  if Verditer.Recap and Verditer.Recap.on_close then Verditer.Recap.on_close() end
end

function M.simulate()
  local now = GetGameTimeMilliseconds()
  local DTC = Verditer.DamageTypeColors
  local function tcol(dt, share)
    local c = DTC.lookup(dt)
    return { r = c.r, g = c.g, b = c.b, a = c.a, share = share, dt = dt }
  end
  local ICON_KB = "/esoui/art/treeicons/collection_indexicon_armor_down.dds"
  local ICON    = "/esoui/art/treeicons/collection_indexicon_armor_up.dds"

  local rec = {
    ts = now, zone = "Cyrodiil",
    overkill_pct = 1.40,
    pressure = {
      dtps = 14213, abs = 2105, peak_dtps = 18420, attackers = 3,
      types = {
        tcol(zc.DAMAGE_TYPE_SHOCK,    0.44),
        tcol(zc.DAMAGE_TYPE_MAGIC,    0.31),
        tcol(zc.DAMAGE_TYPE_PHYSICAL, 0.18),
        tcol(zc.DAMAGE_TYPE_POISON,   0.07),
      },
    },
    attacks = {
      { name = "Crushing Shock",  icon = ICON_KB, dmg = 8420, kb = true,  hits = 1, attacker = "Nightblade Assassin" },
      { name = "Surprise Attack", icon = ICON,    dmg = 6110, kb = false, hits = 2, attacker = "Nightblade Assassin" },
      { name = "Soul Assault",    icon = ICON,    dmg = 4300, kb = false, hits = 4, attacker = "Sorcerer Bomber"     },
      { name = "Fall Damage",     icon = ICON,    dmg = 1200, kb = false, hits = 1, attacker = ""                    },
    },
    lead = {},
  }
  rec.pressure.types.count = 4
  rec.killer = rec.attacks[1]

  local N = 40
  local prev = -1
  local peak, peak_idx = 0, 0
  for i = 1, N do
    local f  = i / N
    local hp = math_max(0, 1.0 - f * f * 1.05)
    if i == N then hp = 0 end
    local dt = 4000 + 14000 * math_min(f / 0.85, 1.0)
    rec.lead[i] = {
      t       = now - (N - i) * 250,
      hp      = hp,
      dtps    = dt,
      abs     = (f < 0.7) and (2000 * (1 - f)) or 0,
      hp_drop = (prev >= 0) and math_max(0, prev - hp) or 0,
    }
    if dt > peak then peak = dt; peak_idx = i end
    prev = hp
  end
  rec.lead.count        = N
  rec.lead.shield_break = math_floor(N * 0.7)
  rec.lead.peak_idx     = peak_idx

  commit(rec)
end

local function start()
  lead_w, lead_n = 1, 0
  ev.register_update("VerditerRecapLead", lead_ms, lead_tick)
  ev.register("VerditerRecapDead",  zc.EVENT_PLAYER_DEAD,  on_player_dead)
  ev.register("VerditerRecapAlive", zc.EVENT_PLAYER_ALIVE, on_player_alive)
end

local function stop()
  ev.unregister_update("VerditerRecapLead")
  ev.unregister("VerditerRecapDead",  zc.EVENT_PLAYER_DEAD)
  ev.unregister("VerditerRecapAlive", zc.EVENT_PLAYER_ALIVE)
end

function M.is_enabled() return enabled end

function M.set_enabled(e)
  e = not not e
  if e == enabled then return end
  enabled = e
  local sv = Verditer.SavedVars
  if sv then sv.recap = sv.recap or {}; sv.recap.enabled = e end
  if e then
    start()
    log:info("death recap enabled")
  else
    stop()
    M.clear()
    log:info("death recap disabled")
  end
end

function M.init()
  lead_ms  = C.RECAP.LEAD_SAMPLE_MS or 250
  lead_cap = math_max(2, math_ceil((C.RECAP.LEAD_SECONDS or 10) * 1000 / lead_ms))
  for i = 1, lead_cap do lead_ring[i] = { t = 0, hp = -1, dtps = 0, abs = 0 } end
  lead_w, lead_n = 1, 0

  local sv = Verditer.SavedVars
  if sv then sv.recap = sv.recap or {}; if sv.recap.enabled == nil then sv.recap.enabled = true end end
  enabled = (not sv) or (sv.recap.enabled ~= false)

  if enabled then start() end
  log:info("init: lead ring cap=", lead_cap, " @", lead_ms, "ms enabled=", tostring(enabled))
end
