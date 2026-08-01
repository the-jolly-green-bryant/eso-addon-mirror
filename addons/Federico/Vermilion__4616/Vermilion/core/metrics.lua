Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Metrics = {}

local M = Vermilion.Metrics
local W_MS        = 5000
local W_SHIELD_MS = 30000

local damage_out_buf  -- (eDPS)
local shield_out_buf  -- (ShDPS)
local event_pool
local log = Vermilion.Log.for_module("metrics")

local SkillColors
local DamageTypeColors

local CRIT_DMG, CRIT_DOT

local function is_crit(e)
  local r = e.result
  return r == CRIT_DMG or r == CRIT_DOT
end

function M.acquire_event()  return event_pool:acquire()   end
function M.release_event(ev) event_pool:release(ev)       end
function M.pool_in_use()    return event_pool:in_use()    end
function M.pool_capacity()  return event_pool:capacity()  end

local function release_to_pool(entry) event_pool:release(entry) end

function M.init()
  local MC = Vermilion.Constants.METRICS or {}
  W_MS        = MC.DAMAGE_WINDOW_MS or 5000
  W_SHIELD_MS = MC.SHIELD_WINDOW_MS or 30000

  local cap  = (Vermilion.Constants.POOL and Vermilion.Constants.POOL.EVENT_CAPACITY) or 4096
  event_pool = Vermilion.lib.mem.BufferPool.new(Vermilion.lib.mem.Event.factory, cap, "event_pool")

  local RingBuffer = Vermilion.lib.mem.RingBuffer
  damage_out_buf = RingBuffer.new(W_MS,        2048, release_to_pool)
  shield_out_buf = RingBuffer.new(W_SHIELD_MS,  512, release_to_pool)

  SkillColors     = Vermilion.SkillColors
  DamageTypeColors = Vermilion.DamageTypeColors

  local zc = Vermilion.zenimax.constants
  CRIT_DMG = zc.ACTION_RESULT_CRITICAL_DAMAGE
  CRIT_DOT = zc.ACTION_RESULT_DOT_TICK_CRITICAL

  log:info("init: dmg_window=", W_MS, "ms shield_window=", W_SHIELD_MS, "ms pool=", cap)
end

function M.set_window(ms)
  W_MS = ms or 5000
  damage_out_buf.window_ms = W_MS
  log:info("dmg window ->", W_MS, "ms")
end

function M.set_shield_window(ms)
  W_SHIELD_MS = ms or 30000
  shield_out_buf.window_ms = W_SHIELD_MS
  log:info("shield window ->", W_SHIELD_MS, "ms")
end

function M.window_seconds() return W_MS / 1000 end

function M.ingest_damage_out(ev)
  if ev.amount > 0 then damage_out_buf:push(ev) else event_pool:release(ev) end
end

function M.ingest_shield_out(ev)
  if ev.amount > 0 then shield_out_buf:push(ev) else event_pool:release(ev) end
end

function M.eDPS(now_ms)  return damage_out_buf:sum(now_ms, "amount") / (W_MS / 1000)        end
function M.ShDPS(now_ms) return shield_out_buf:sum(now_ms, "amount") / (W_SHIELD_MS / 1000) end
function M.EOS(now_ms)   return M.eDPS(now_ms) + M.ShDPS(now_ms)                            end

function M.crit_split(now_ms)
  damage_out_buf:trim(now_ms)
  local ws    = W_MS / 1000
  local crit  = 0
  local total = 0
  for i = damage_out_buf.head, damage_out_buf.tail do
    local e   = damage_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      total = total + amt
      if is_crit(e) then crit = crit + amt end
    end
  end
  crit = crit / ws
  return crit, (total / ws) - crit
end

local accum_buckets = {}

local function accumulate(now_ms, buckets)
  for k in pairs(buckets) do buckets[k] = nil end   --* reset in place for zero alloc !!
  local ws  = W_MS / 1000
  local wss = W_SHIELD_MS / 1000
  local total = 0

  damage_out_buf:trim(now_ms)
  for i = damage_out_buf.head, damage_out_buf.tail do
    local e   = damage_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      local r = amt / ws
      local g = SkillColors.group_of(e.ability_id)
      buckets[g] = (buckets[g] or 0) + r
      total = total + r
    end
  end

  shield_out_buf:trim(now_ms)
  for i = shield_out_buf.head, shield_out_buf.tail do
    local e   = shield_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      local r = amt / wss
      local g = SkillColors.group_of(e.ability_id)
      buckets[g] = (buckets[g] or 0) + r
      total = total + r
    end
  end

  return total
end

function M.eos_groups_into(out, now_ms)
  local buckets = accum_buckets
  local total   = accumulate(now_ms, buckets)
  local n = 0
  if total > 0 then
    for g, val in pairs(buckets) do
      n = n + 1
      local slot = out[n]
      if not slot then slot = {}; out[n] = slot end
      local c = SkillColors.group_color(g)
      slot.r = c.r; slot.g = c.g; slot.b = c.b; slot.a = c.a
      slot.share = val / total
      slot.key = g   -- stable group id (string) for the hover highlight + card name
    end

    -- out is reused, so its tail holds stale slots from bigger calls.
    -- sort by hand over 1..n; table.sort would order #out and drag the tail in.
    for i = 2, n do
      local key = out[i]
      local j = i - 1
      while j >= 1 and out[j].share < key.share do
        out[j + 1] = out[j]
        j = j - 1
      end
      out[j + 1] = key
    end
  end
  out.count = n   -- readers loop 1..count, never #out
  return n
end

local function sort_shares_desc(out, n)
  for i = 2, n do
    local key = out[i]
    local ks  = key.share
    local j   = i - 1
    while j >= 1 and out[j].share < ks do
      out[j + 1] = out[j]
      j = j - 1
    end
    out[j + 1] = key
  end
end

local ab_amt = {}
local ab_grp = {}

function M.eos_abilities_into(out, now_ms)
  for k in pairs(ab_amt) do ab_amt[k] = nil end
  for k in pairs(ab_grp) do ab_grp[k] = nil end
  local ws    = W_MS / 1000
  local wss   = W_SHIELD_MS / 1000
  local total = 0

  damage_out_buf:trim(now_ms)
  for i = damage_out_buf.head, damage_out_buf.tail do
    local e   = damage_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      local id = e.ability_id or 0
      local r  = amt / ws
      ab_amt[id] = (ab_amt[id] or 0) + r
      if ab_grp[id] == nil then ab_grp[id] = SkillColors.group_of(id) end
      total = total + r
    end
  end

  shield_out_buf:trim(now_ms)
  for i = shield_out_buf.head, shield_out_buf.tail do
    local e   = shield_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      local id = e.ability_id or 0
      local r  = amt / wss
      ab_amt[id] = (ab_amt[id] or 0) + r
      if ab_grp[id] == nil then ab_grp[id] = SkillColors.group_of(id) end
      total = total + r
    end
  end

  local n = 0
  if total > 0 then
    for id, amt in pairs(ab_amt) do
      n = n + 1
      local slot = out[n]
      if not slot then slot = {}; out[n] = slot end
      local g = ab_grp[id] or "other"
      local c = SkillColors.group_color(g)
      slot.id = id; slot.share = amt / total; slot.key = g
      slot.r = c.r; slot.g = c.g; slot.b = c.b; slot.a = c.a
    end
    sort_shares_desc(out, n)
  end
  out.count = n
  return n
end

local dt_buckets = {}

function M.dtype_groups_into(out, now_ms)
  for k in pairs(dt_buckets) do dt_buckets[k] = nil end
  local ws    = W_MS / 1000
  local total = 0
  damage_out_buf:trim(now_ms)
  for i = damage_out_buf.head, damage_out_buf.tail do
    local e   = damage_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      local r  = amt / ws
      local dt = e.damage_type or 0
      dt_buckets[dt] = (dt_buckets[dt] or 0) + r
      total = total + r
    end
  end
  local n = 0
  if total > 0 then
    for dt, val in pairs(dt_buckets) do
      n = n + 1
      local slot = out[n]
      if not slot then slot = {}; out[n] = slot end
      local c = DamageTypeColors.lookup(dt)
      slot.r = c.r; slot.g = c.g; slot.b = c.b; slot.a = c.a
      slot.share = val / total
      slot.key = dt
    end
    sort_shares_desc(out, n)
  end
  out.count = n
  return n
end

local dta_amt = {}
local dta_dt  = {}

function M.dtype_abilities_into(out, now_ms)
  for k in pairs(dta_amt) do dta_amt[k] = nil end
  for k in pairs(dta_dt)  do dta_dt[k]  = nil end
  local ws    = W_MS / 1000
  local total = 0
  damage_out_buf:trim(now_ms)
  for i = damage_out_buf.head, damage_out_buf.tail do
    local e   = damage_out_buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 then
      local id = e.ability_id or 0
      local r  = amt / ws
      dta_amt[id] = (dta_amt[id] or 0) + r
      if dta_dt[id] == nil then dta_dt[id] = e.damage_type or 0 end
      total = total + r
    end
  end
  local n = 0
  if total > 0 then
    for id, amt in pairs(dta_amt) do
      n = n + 1
      local slot = out[n]
      if not slot then slot = {}; out[n] = slot end
      local dt = dta_dt[id] or 0
      local c  = DamageTypeColors.lookup(dt)
      slot.id = id; slot.share = amt / total; slot.key = dt
      slot.r = c.r; slot.g = c.g; slot.b = c.b; slot.a = c.a
    end
    sort_shares_desc(out, n)
  end
  out.count = n
  return n
end

function M.reset()
  log:info("reset: damage=", damage_out_buf:size(), "shield=", shield_out_buf:size(),
           "pool_in_use=", event_pool:in_use())
  damage_out_buf:reset()
  shield_out_buf:reset()
end

function M.size_snapshot()
  return {
    damage = damage_out_buf:size(),
    shield = shield_out_buf:size(),
  }
end
