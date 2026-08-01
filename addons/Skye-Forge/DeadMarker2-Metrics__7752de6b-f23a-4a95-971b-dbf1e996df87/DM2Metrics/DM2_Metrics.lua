---------------------------------------------------------------------
-- DM2_Metrics.lua — v1.1.1
-- Console-friendly metrics for DeadMarker2:
--  • Tracks deaths, rezzes-performed, TTR attribution, wipes, fastest rez.
--  • Time shown as m:ss / h:mm:ss, not raw seconds.
--  • Improved rez attribution for console (proximity + nearest fallback).
--  • Wipe detection uses active group size (all dead = wipe).
--  • Tracks "Died 1st" per boss pull; shows in table + share.
--  • Panel auto-close configurable; Lifetime/Run views, reset button, etc.
-- v1.1.0:
--    Fixed distance checks (world coords are centimetres, not metres)
--    Fixed rez attribution race: combat log now takes priority over inference
--    OnUpdate poll now detects death/revive transitions as fallback
--    ensureStats() no longer allocates on every tick
--    UI control leak fixed on panel refresh
--    Version-anchored announcement popup
-- v1.1.1:
--    Boss-seen grace window now configurable (was hardcoded 20s)
--    Companion rez tracking implemented (naughtyCompanionRezzes counter)
--    isInDungeonOrTrial() now also covers arenas via activity type check
--    getGroupParticipantsForMetrics() consistent: both paths count all members
--    Share-to-chat respects current Lifetime/Run view toggle
--    Roster rebuilt on group member join/leave events
-- v1.1.2:
--    Combat-log rez defer extended (configurable; default 750 ms, was 300 ms)
---------------------------------------------------------------------

local DM2M = {}
DM2M.name        = "DM2_Metrics"
DM2M.displayName = "DeadMarker2 Metrics"
-- AddOnVersion (manifest only) = major*10000 + minor*100 + patch  →  1.1.2 = 10102
DM2M.version     = "1.1.2"
DM2M.ns          = "DM2_Metrics_SV"

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local MAX_BOSSES = 6
local CM_PER_M   = 100   -- GetUnitWorldPosition returns centimetres

-- ====================== Version Announcements ======================
DM2M._announcements = {
  ["1.1.0"] = {
    title = "v1.1.0 — Major Accuracy Overhaul!",
    body  = "Fixed all distance / proximity checks (were 100x too tight).\n"
         .. "Rez attribution: combat-log source now beats proximity guessing.\n"
         .. "Death detection: polling loop now catches missed events.\n"
         .. "Reduced CPU/memory overhead (cached ensureStats).\n"
         .. "Fixed UI control leak on stats panel refresh.",
  },
  ["1.1.1"] = {
    title = "v1.1.1 — Polish & Companion Tracking",
    body  = "Boss grace window now configurable in settings.\n"
         .. "Companion rezzes tracked (Naughty column).\n"
         .. "Arena / solo instance detection improved.\n"
         .. "Share-to-chat now respects Lifetime vs Run view.\n"
         .. "Roster updates on group join/leave (no stale data).",
  },
  ["1.1.2"] = {
    title = "v1.1.2 — Rez Attribution Timing",
    body  = "Combat-log rez defer extended (default 750 ms, was 300 ms).\n"
         .. "Gives laggy console paths more time to supply the accurate\n"
         .. "rezzer before proximity inference runs.\n"
         .. "Tune under Settings > Rez Detection > Combat-log defer (ms).",
  },
}
DM2M._latestAnnouncementVersion = "1.1.2"

-- ======================= Safe console UI check ======================
-- Use this everywhere instead of calling IsConsoleUI()/ZO_IsConsoleUI directly.
local function isConsoleUI()
  if type(IsConsoleUI) == "function" then
    return IsConsoleUI()
  elseif type(ZO_IsConsoleUI) == "function" then
    return ZO_IsConsoleUI()
  else
    return false
  end
end

DM2M.defaults = {
  stats = {
    lifetime = {
      players = {},
      global = {
        fastestRez = nil,
        wipes = 0,
      },
    },
    run      = {
      players = {},
      global  = {
        fastestRez = nil,
        wipes = 0,
      },
      startTime = 0,
      type      = "unknown",
      zoneId    = 0,
    },
    volatile = {
      deaths      = {},   -- [@target] = { t, x,y,z }
      bossActive  = false,
      bossLastSeen= 0,    -- timestamp of last boss presence
      inDungeon   = false,
      lastAlive   = {},   -- [@handle] = bool
      near        = {},   -- [@dead] = { [@rezzer] = lastSeenTimestamp }

      -- Per-pull / wipe & "first to die" tracking
      activeGroupSize           = 0,
      activeHandles             = {},  -- [@handle] = true
      deadHandles               = {},  -- [@handle] = true
      deadCount                 = 0,
      wipeLoggedForPull         = false,
      pullId                    = 0,
      currentPullHasBoss        = false,
      firstDeathRecordedForPull = false,
      firstDeadHandleThisPull   = nil,
    },
  },
  settings = {
    enable = true,
    scopeDungeonsTrialsOnly = true,
    autoShowAtEnd = true,

    rezMaxDistM        = 25.0,
    wayshrineMinSecs   = 6.0,
    instaRezSecs       = 1.5,
    inferAttribution   = true,
    inferMinChannelSecs= 2.0,
    inferProximityM    = 7.0,
    rezCombatLogDeferMs= 750,  -- wait for ACTION_RESULT_RESURRECT before inference

    -- Wipe settings (always enabled now)
    wipeRequireBoss       = true,
    wipeAllDeadWindowSecs = 0.0,  -- 0 = instant wipe as soon as all tracked players are dead
    wipeSuppressDeaths    = true,
    firstToDieBossOnly    = false,  -- only count 'Died 1st' when a boss is present
    bossGraceSecs         = 20.0,   -- how long after last boss sighting counts as "recent"

    excludeCompanions      = true,
    trackCompanionRezzes   = true,  -- count companion rezzes in the Naughty column

    statsAutoCloseSecs  = 20,  -- default: 20s (0 = never)
    statsFontSize       = 20,
    showLifetimeByDefault = false,
    showAvgDownTimeInsteadOfTotal = false,

    battleRezIds = {},
  },
}

-- ============================ Runtime ===============================
local SV = nil
local statsWin, showLifetime = nil, nil
DM2M._autoHideTimerActive = false

-- Pending rez table: defers death-state-change rez processing so the
-- combat event (with the accurate rezzer name) can arrive first.
local _pendingRezzes = {}   -- [disp] = { pullId, curX, curY, curZ }

-- keybind group for console scrolling
local keybindGroup = nil

-- ============================= Helpers ==============================
local function now() return GetFrameTimeSeconds() end

local function deepcopy(t)
  if type(t) ~= "table" then return t end
  local n = {}
  for k,v in pairs(t) do n[k] = deepcopy(v) end
  return n
end

local function deepmerge(dst, src)
  for k,v in pairs(src) do
    if type(v) == "table" then
      if type(dst[k]) ~= "table" then dst[k] = {} end
      deepmerge(dst[k], v)
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

local function ensureStats()
  SV.metrics = SV.metrics or {}
  if not SV._statsInitialized then
    deepmerge(SV.metrics, deepcopy(DM2M.defaults.stats))
    SV._statsInitialized = true
  end
  return SV.metrics
end

--local function ensureSettings()
--  SV.settings = deepmerge(SV.settings or {}, deepcopy(DM2M.defaults.settings))
--  return SV.settings
--end
local function ensureSettings()
  SV.settings = SV.settings or {}
  if not SV._settingsInitialized then
    deepmerge(SV.settings, deepcopy(DM2M.defaults.settings))
    SV._settingsInitialized = true
  end
  return SV.settings
end

local function getSetting(k)
  if SV.settings and SV.settings[k] ~= nil then
    return SV.settings[k]
  end
  return DM2M.defaults.settings[k]
end

local function setSetting(k, v)
  SV.settings = SV.settings or {}
  SV.settings[k] = v
  if k == "enable" and v == false then DM2M:HideStatsPanel() end
end

local function isCompanionUnitTag(unitTag)
  if not unitTag then return false end
  unitTag = tostring(unitTag)
  return string.find(unitTag, "companion", 1, true) ~= nil
end

local function isRealPlayerByTag(unitTag)
  if not unitTag or not DoesUnitExist(unitTag) then return false end
  if isCompanionUnitTag(unitTag) then return false end
  return IsUnitPlayer(unitTag)
end

local function displayNameForUnit(unitTag)
  if not unitTag or not DoesUnitExist(unitTag) then return nil end
  local disp = GetUnitDisplayName(unitTag)
  if disp and disp ~= "" then return disp end
  local char = GetUnitName(unitTag)
  if char and char ~= "" then return char end
  return nil
end

local function isInDungeonOrTrial()
  if IsUnitInDungeon("player") then return true end
  -- Cover arenas (Maelstrom, Vateshran, DSA) and other group instances
  -- that IsUnitInDungeon may miss.
  local activityType = GetCurrentZoneGroupActivityType and GetCurrentZoneGroupActivityType()
  if activityType then
    return activityType == LFG_ACTIVITY_DUNGEON
        or activityType == LFG_ACTIVITY_TRIAL
        or activityType == LFG_ACTIVITY_ARENA
  end
  return false
end

local function isTrialByHeuristic()
  return (GetGroupSize() or 0) >= 12
end

local function startsWithAt(name)
  return type(name) == "string" and name ~= "" and string.sub(name,1,1) == "@"
end

-- ------------- Roster cache & char->handle resolution ---------------
local ROSTER = { byChar = {}, byHandle = {} }

local function rebuildRoster()
  ROSTER.byChar, ROSTER.byHandle = {}, {}
  local n = GetGroupSize()
  for i = 1, n do
    local tag = GetGroupUnitTagByIndex(i)
    if tag and DoesUnitExist(tag) and IsUnitPlayer(tag) then
      local handle = GetUnitDisplayName(tag) or ""
      local char   = GetUnitName(tag) or ""
      if handle ~= "" then ROSTER.byHandle[handle] = true end
      if char   ~= "" then
        local norm = zo_strformat("<<1>>", char)
        ROSTER.byChar[norm] = handle
      end
    end
  end
end

-- Metrics must be keyed by @handle ONLY (never character names).
-- Safe even if toHandle() is declared later.
local function metricKeyFromUnitTag(unitTag)
  if not unitTag or not DoesUnitExist(unitTag) then return nil end

  local h = GetUnitDisplayName(unitTag)
  if h and h ~= "" and startsWithAt(h) then
    return h
  end

  -- last resort: resolve char -> @handle using the roster map (if available)
  local c = GetUnitName(unitTag)
  if c and c ~= "" and type(ROSTER) == "table" and type(ROSTER.byChar) == "table" then
    local norm = zo_strformat("<<1>>", c)
    local mapped = ROSTER.byChar[norm]
    if mapped and startsWithAt(mapped) then
      return mapped
    end
  end

  return nil
end

-- m:ss / h:mm:ss formatter
local function fmtClock(t)
  if not t then return "-" end
  t = math.floor(t + 0.5)
  local h = math.floor(t / 3600)
  local m = math.floor((t % 3600) / 60)
  local s = t % 60
  if h > 0 then
    return string.format("%d:%02d:%02d", h, m, s)
  else
    return string.format("%d:%02d", m, s)
  end
end

local function ensurePlayer(bucket, disp)
  bucket.players[disp] = bucket.players[disp] or {
    deaths = 0,
    rezzesReceived = 0,
    timeDead = 0.0,
    rezzesPerformed = 0,
    rezTimes = {},
    fastestRez = nil,
    inferredAttributions = 0,
    naughtyCompanionRezzes = 0,
    firstToDie = 0,
  }
  return bucket.players[disp]
end

local function avg(list)
  if not list or #list == 0 then return nil end
  local s=0
  for i=1,#list do s = s + list[i] end
  return s / #list
end

local _lastRosterRebuild = 0
local function rebuildRosterThrottled(minIntervalSecs)
  minIntervalSecs = minIntervalSecs or 1.0
  local t = now()
  if (t - _lastRosterRebuild) < minIntervalSecs then return end
  _lastRosterRebuild = t
  rebuildRoster()
end

local function toHandle(name)
  if not name or name == "" then return nil end
  name = zo_strformat("<<1>>", name)
  if string.sub(name,1,1) == "@" then return name end
  return ROSTER.byChar[name]
end

-- Active group snapshot helper
-- If DM2 exposes DM2_GetActiveGroupForMetrics(), prefer that.
-- Expected (flexible) shape:
--   return {
--     ["@handle1"] = true or { alive=true/false },
--     ["@handle2"] = false or { alive=false },
--   }
local function getGroupParticipantsForMetrics()
  local handles = {}
  local count = 0

  -- Prefer DM2 helper if present
  -- Count ALL members (alive or dead) so activeGroupSize reflects the full
  -- group for accurate wipe detection, consistent with the fallback path.
  if type(DM2_GetActiveGroupForMetrics) == "function" then
    local ok, data = pcall(DM2_GetActiveGroupForMetrics)
    if ok and type(data) == "table" then
      for handle, info in pairs(data) do
        if startsWithAt(handle) then
          handles[handle] = true
          count = count + 1
        end
      end
      if count > 0 then
        return handles, count
      end
    end
  end

  -- Fallback: raw group API
  local size = GetGroupSize() or 0
  if size == 0 then return handles, 0 end

  for i=1,size do
    local tag = GetGroupUnitTagByIndex(i)
    if isRealPlayerByTag(tag) then
      local disp = displayNameForUnit(tag)
      if disp and startsWithAt(disp) then
        handles[disp] = true
        count = count + 1
      end
    end
  end

  return handles, count
end

-- ============================= Core =================================
local function resetPullState()
  local s = ensureStats()
  local v = s.volatile
  v.activeGroupSize           = 0
  v.activeHandles             = {}
  v.deadHandles               = {}
  v.deadCount                 = 0
  v.wipeLoggedForPull         = false
  v.currentPullHasBoss        = false
  v.firstDeathRecordedForPull = false
  v.firstDeadHandleThisPull   = nil
  v.pullId                    = (v.pullId or 0) + 1
  
    -- Extra safety: clear any leftover per-life tracking
  v.deaths      = {}
  v.near        = {}
  v.lastAlive   = {}
end

local function clearVolatileDeathTracking()
  local s = ensureStats()
  local v = s.volatile
  v.deaths    = {}
  v.near      = {}
  v.lastAlive = {}
end

function DM2M:StartRun()
  local s = ensureStats()
  s.run = deepcopy(DM2M.defaults.stats.run)
  s.run.startTime = now()
  s.run.type = isTrialByHeuristic() and "trial"
            or (isInDungeonOrTrial() and "dungeon" or "unknown")
  local zoneId = select(1, GetUnitWorldPosition("player"))
  s.run.zoneId = zoneId or 0

  resetPullState()
end

function DM2M:EndRun()
  if getSetting("autoShowAtEnd") then
    zo_callLater(function() DM2M:ShowStatsPanel(true) end, 10000)
  end
  resetPullState()
end

function DM2M:MaybeSetBossActive()
  local s = ensureStats()
  local seen = false
  for i=1,MAX_BOSSES do
    if DoesUnitExist("boss"..i) then
      seen = true
      break
    end
  end
  s.volatile.bossActive = seen
  if seen then
    s.volatile.bossLastSeen = now()
  end
end

local function bossSeenRecently()
  local s = ensureStats()
  local grace = tonumber(getSetting("bossGraceSecs")) or 20.0
  return (now() - (s.volatile.bossLastSeen or 0)) <= grace
end

local function snapshotActiveGroupForPull()
  rebuildRoster()

  local s = ensureStats()
  local v = s.volatile

  v.activeHandles = {}
  v.deadHandles   = {}
  v.deadCount     = 0

  local handles, count = getGroupParticipantsForMetrics()
  v.activeGroupSize = count or 0
  if handles then
    for h,_ in pairs(handles) do
      v.activeHandles[h] = true
    end
  end

  v.currentPullHasBoss        = bossSeenRecently()
  v.wipeLoggedForPull         = false
  v.firstDeathRecordedForPull = false
  v.firstDeadHandleThisPull   = nil
  v.pullId                    = (v.pullId or 0) + 1
end

function DM2M:RegisterWipe()
  local s = ensureStats()
  local v = s.volatile
  if v.wipeLoggedForPull then return end

  s.run.global.wipes      = (s.run.global.wipes or 0) + 1
  s.lifetime.global.wipes = (s.lifetime.global.wipes or 0) + 1

  v.wipeLoggedForPull = true

  -- If enabled, stop tracking corpses/rez inference during the wipe state.
  if getSetting("wipeSuppressDeaths") then
    clearVolatileDeathTracking()
  end

  -- Clear per-pull state so the next death cluster snapshots fresh.
  v.activeGroupSize           = 0
  v.activeHandles             = {}
  v.deadHandles               = {}
  v.deadCount                 = 0
  v.currentPullHasBoss        = false
  v.firstDeathRecordedForPull = false
  v.firstDeadHandleThisPull   = nil
end


function DM2M:CheckForWipe()
  local s = ensureStats()
  local v = s.volatile

  if v.wipeLoggedForPull then return end
  if (v.activeGroupSize or 0) <= 0 then return end
  if v.deadCount < v.activeGroupSize then return end

  if getSetting("wipeRequireBoss") and not bossSeenRecently() then
    return
  end

  local window = tonumber(getSetting("wipeAllDeadWindowSecs")) or 0
  if window <= 0 then
    DM2M:RegisterWipe()
    return
  end

  local thisPullId = v.pullId or 0
  zo_callLater(function()
    local s2 = ensureStats()
    local v2 = s2.volatile
    if (v2.pullId or 0) ~= thisPullId then return end
    if v2.wipeLoggedForPull then return end
    if (v2.activeGroupSize or 0) > 0
       and v2.deadCount >= v2.activeGroupSize
       and (not getSetting("wipeRequireBoss") or bossSeenRecently())
    then
      DM2M:RegisterWipe()
    end
  end, math.floor(window * 1000))
end

function DM2M:MarkDeath(disp, unitTag)
  local s = ensureStats()
  s.volatile.deaths[disp] = s.volatile.deaths[disp] or {}

  local zoneId, x, y, z = GetUnitWorldPosition(unitTag or "player")
  s.volatile.deaths[disp].t      = now()
  s.volatile.deaths[disp].zoneId = zoneId
  s.volatile.deaths[disp].x      = x
  s.volatile.deaths[disp].y      = y
  s.volatile.deaths[disp].z      = z

  -- reset proximity ledger for this corpse
  s.volatile.near[disp] = {}

  local Rrun  = ensurePlayer(s.run, disp)
  local Rlife = ensurePlayer(s.lifetime, disp)
  Rrun.deaths  = (Rrun.deaths or 0) + 1
  Rlife.deaths = (Rlife.deaths or 0) + 1
end

-- Wrap death handling to integrate per-pull logic
function DM2M:OnUnitDeath(disp, unitTag)
  local s = ensureStats()
  local v = s.volatile

  -- If we're already in a wipe state, optionally suppress further death counting.
  if v.wipeLoggedForPull and getSetting("wipeSuppressDeaths") then
    return
  end

  -- If we already have an active death record for this player,
  -- ignore duplicate death events until they have been rezzed.
  local existing = v.deaths[disp]
  if existing and existing.t then
    return
  end

  -- First death of this pull? Snapshot group participants.
  if (v.activeGroupSize or 0) == 0 then
    snapshotActiveGroupForPull()
  end

  -- Count the death once per death/rez cycle.
  DM2M:MarkDeath(disp, unitTag)

  if v.activeHandles[disp] and not v.deadHandles[disp] then
    v.deadHandles[disp] = true
    v.deadCount = (v.deadCount or 0) + 1

    -- First to die this pull (now for ANY pull, not only boss).
	local bossOnly = getSetting("firstToDieBossOnly")

	if not v.firstDeathRecordedForPull
	   and startsWithAt(disp)
	   and (not bossOnly or bossSeenRecently())
	then
	  v.firstDeathRecordedForPull = true
	  v.firstDeadHandleThisPull = disp

	  local Prun  = ensurePlayer(s.run, disp)
	  local Plife = ensurePlayer(s.lifetime, disp)
	  Prun.firstToDie  = (Prun.firstToDie or 0) + 1
	  Plife.firstToDie = (Plife.firstToDie or 0) + 1
	end

    DM2M:CheckForWipe()
  end
end


function DM2M:OnUnitRevive(disp)
  -- When a player comes back to life, update per-pull dead tracking so
  -- deadCount reflects who is currently dead for wipe detection.
  local s = ensureStats()
  local v = s.volatile

  if v.deadHandles[disp] then
    v.deadHandles[disp] = nil
    v.deadCount = math.max(0, (v.deadCount or 0) - 1)
  end
end

-- Live proximity ledger while corpses are up
local function trackProximityNearCorpses()
  local s = ensureStats()
  local radius = (getSetting("inferProximityM") or 7.0) * CM_PER_M
  local r2 = radius * radius
  local size = GetGroupSize()
  if size == 0 then return end

  local tnow = now()

  for deadDisp, d in pairs(s.volatile.deaths) do
    if startsWithAt(deadDisp) and d and d.x and d.y then
      local ledger = s.volatile.near[deadDisp] or {}

      for i=1,size do
        local tag = GetGroupUnitTagByIndex(i)
        if isRealPlayerByTag(tag) and not IsUnitDead(tag) then
          local rezzer = metricKeyFromUnitTag(tag) -- <-- IMPORTANT
          if rezzer and rezzer ~= deadDisp then
            local _, x, y, z = GetUnitWorldPosition(tag)
            if x and y then
              local dx, dy = (x - d.x), (y - d.y)
              local dist2 = dx*dx + dy*dy
              if dist2 <= r2 then
                local rec = ledger[rezzer]
                if type(rec) ~= "table" then
                  ledger[rezzer] = { first = tnow, last = tnow }
                else
                  rec.last = tnow
                end
              end
            end
          end
        end
      end

      s.volatile.near[deadDisp] = ledger
    end
  end
end

local function chooseRecentRezzer(deadDisp)
  local s = ensureStats()
  local ledger = s.volatile.near[deadDisp]
  if type(ledger) ~= "table" then return nil end

  local tnow  = now()
  local grace = 8.0
  local minCh = tonumber(getSetting("inferMinChannelSecs")) or 2.0

  local bestH, bestLast = nil, -1

  for h, rec in pairs(ledger) do
    if type(rec) == "table" then
      local first = tonumber(rec.first)
      local last  = tonumber(rec.last)
      if first and last then
        local nearDur = (last - first)
        local recent  = (tnow - last) <= grace
        if recent and nearDur >= minCh then
          if last > bestLast then
            bestLast = last
            bestH = h
          end
        end
      end
    end
  end

  return bestH
end

local function nearestLivingToDeathSpot(deadDisp, radiusM)
  local s = ensureStats()
  local d = s.volatile.deaths[deadDisp]
  if not d or not d.x or not d.y then return nil end

  local r  = (radiusM or getSetting("rezMaxDistM") or 25.0) * CM_PER_M
  local r2 = r * r

  local size = GetGroupSize()
  local best, bestD

  for i=1,size do
    local tag = GetGroupUnitTagByIndex(i)
    if isRealPlayerByTag(tag) and not IsUnitDead(tag) then
      local disp = metricKeyFromUnitTag(tag) -- <-- IMPORTANT
      if disp and disp ~= deadDisp then
        local _, x, y, z = GetUnitWorldPosition(tag)
        if x and y then
          local dx, dy = (x - d.x), (y - d.y)
          local dist2 = dx*dx + dy*dy
          if dist2 <= r2 and (not bestD or dist2 < bestD) then
            best, bestD = disp, dist2
          end
        end
      end
    end
  end

  return best
end


function DM2M:MarkRezAccept(targetDisp, rezzerDisp, opts)
  opts = opts or {}
  local s = ensureStats()
  local d = s.volatile.deaths[targetDisp]
  if not d or not d.t then return end

  local ttr = math.max(0, now() - d.t)

-- wayshrine / auto pops (smarter than time-only)
  if ttr < getSetting("wayshrineMinSecs") and not opts.force then
    -- If caller provided current position (revive path), use it to detect teleport returns.
    if opts and opts.curX and opts.curY and d.x and d.y then
      local dx, dy = (opts.curX - d.x), (opts.curY - d.y)
      local dist2 = dx*dx + dy*dy

      -- If they re-appeared far from their death spot very quickly, treat as wayshrine/auto-return.
      local FAR_CM = 40.0 * CM_PER_M
      if dist2 >= (FAR_CM * FAR_CM) then
        s.volatile.deaths[targetDisp] = nil
        s.volatile.near[targetDisp]   = nil
        return
      end
    else
      -- No position info: fall back to time-only behavior
      s.volatile.deaths[targetDisp] = nil
      s.volatile.near[targetDisp]   = nil
      return
    end
  end

  local inferred = false
  if not rezzerDisp and getSetting("inferAttribution") then
    -- 1) First try "who was standing on the corpse most recently"
    rezzerDisp = chooseRecentRezzer(targetDisp)

    -- 2) If that fails, fall back to "closest living player" within a
    --    generous rez radius (use main rezMaxDistM, not the small proximity).
    if not rezzerDisp then
      local maxDist = getSetting("rezMaxDistM") or (getSetting("inferProximityM") or 7.0) * 3.0
      rezzerDisp = nearestLivingToDeathSpot(targetDisp, maxDist)
    end

    inferred = rezzerDisp ~= nil
  end

  local Trun  = ensurePlayer(s.run, targetDisp)
  local Tlife = ensurePlayer(s.lifetime, targetDisp)
  Trun.rezzesReceived  = (Trun.rezzesReceived or 0) + 1
  Tlife.rezzesReceived = (Tlife.rezzesReceived or 0) + 1
  Trun.timeDead        = (Trun.timeDead or 0) + ttr
  Tlife.timeDead       = (Tlife.timeDead or 0) + ttr

  if rezzerDisp then
    local Rrun  = ensurePlayer(s.run, rezzerDisp)
    local Rlife = ensurePlayer(s.lifetime, rezzerDisp)
    Rrun.rezzesPerformed  = (Rrun.rezzesPerformed or 0) + 1
    Rlife.rezzesPerformed = (Rlife.rezzesPerformed or 0) + 1
    table.insert(Rrun.rezTimes,  ttr)
    table.insert(Rlife.rezTimes, ttr)
    if (not Rrun.fastestRez) or (ttr < Rrun.fastestRez) then Rrun.fastestRez = ttr end
    if (not Rlife.fastestRez) or (ttr < Rlife.fastestRez) then Rlife.fastestRez = ttr end
    if inferred then
      Rrun.inferredAttributions  = (Rrun.inferredAttributions or 0) + 1
      Rlife.inferredAttributions = (Rlife.inferredAttributions or 0) + 1
    end

    local function updFastest(fastest)
      if (not fastest) or (ttr < fastest.ttr) then
		local zoneId = select(1, GetUnitWorldPosition("player"))
		return {
		  ttr     = ttr,
		  rezzer  = rezzerDisp,
		  target  = targetDisp,
		  zoneId  = zoneId or 0,
		  context = ensureStats().run.type,
		  insta   = opts.insta or ttr <= getSetting("instaRezSecs"),
		}
      end
      return fastest
    end
    s.run.global.fastestRez      = updFastest(s.run.global.fastestRez)
    s.lifetime.global.fastestRez = updFastest(s.lifetime.global.fastestRez)
  end

  s.volatile.deaths[targetDisp] = nil
  s.volatile.near[targetDisp]   = nil
end

-- ============================= Events ===============================
local RESULT_DIED       = ACTION_RESULT_DIED
local RESULT_RES        = ACTION_RESULT_RESURRECT
local RESULT_RES_FAILED = ACTION_RESULT_RESURRECT_FAIL

function DM2M:OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                            sourceName, sourceType, targetName, targetType,
                            hitValue, powerType, damageType, log,
                            sourceUnitId, targetUnitId, abilityId)
  if not getSetting("enable") then return end
  if getSetting("scopeDungeonsTrialsOnly") and not isInDungeonOrTrial() then return end
  if result == RESULT_DIED then return end

  if result == RESULT_RES then
    -- Companion rez detection: if the source is a companion unit tag,
    -- credit the companion's owner (the target's group) with a "naughty" rez.
    local isCompanionRez = false
    if sourceName and sourceName ~= "" then
      local normSrc = zo_strformat("<<1>>", sourceName)
      -- Companions don't have @handles; if we can't resolve to a handle
      -- AND the name doesn't start with @, it's likely a companion.
      if not startsWithAt(normSrc) and not ROSTER.byChar[normSrc] then
        isCompanionRez = true
      end
    end

    if isCompanionRez and getSetting("trackCompanionRezzes") then
      local target = toHandle(targetName)
      if not target then rebuildRoster(); target = toHandle(targetName) end
      if target and startsWithAt(target) then
        local s = ensureStats()
        local Trun  = ensurePlayer(s.run, target)
        local Tlife = ensurePlayer(s.lifetime, target)
        Trun.naughtyCompanionRezzes  = (Trun.naughtyCompanionRezzes or 0) + 1
        Tlife.naughtyCompanionRezzes = (Tlife.naughtyCompanionRezzes or 0) + 1
        -- Still process as a real rez for the target's stats
        _pendingRezzes[target] = nil
        DM2M:MarkRezAccept(target, nil, { force = true })
        if statsWin and not statsWin:IsHidden() then DM2M:RefreshStatsPanel() end
      end
      return
    end

    local rezzer = toHandle(sourceName)
    local target = toHandle(targetName)

    -- If mapping failed, rebuild roster once and retry.
    if not rezzer or not target then
      rebuildRoster()
      rezzer = rezzer or toHandle(sourceName)
      target = target or toHandle(targetName)
    end

    if rezzer and target and rezzer ~= target then
      -- Cancel any deferred rez for this target — we have accurate info now
      _pendingRezzes[target] = nil

      local insta = getSetting("battleRezIds")[abilityId] or false
      DM2M:MarkRezAccept(target, rezzer, { insta = insta, force = true })
      if statsWin and not statsWin:IsHidden() then DM2M:RefreshStatsPanel() end
    end
    return
  end

  if result == RESULT_RES_FAILED then return end
end

function DM2M:OnUpdate()
  if not getSetting("enable") then return end
  if getSetting("scopeDungeonsTrialsOnly") and not isInDungeonOrTrial() then return end

  DM2M:MaybeSetBossActive()
  rebuildRosterThrottled(1.0) -- once per second is plenty
  trackProximityNearCorpses()

  local s = ensureStats()
  local size = GetGroupSize()
  if size == 0 then return end

  for i=1,size do
    local tag = GetGroupUnitTagByIndex(i)
    if isRealPlayerByTag(tag) then
      local disp = metricKeyFromUnitTag(tag) -- <-- IMPORTANT
      if disp then
        local alive = not IsUnitDead(tag)
        local wasAlive = s.volatile.lastAlive[disp]

        if wasAlive ~= nil then
          if wasAlive and not alive then
            -- Transition alive -> dead: fallback death detection
            -- Only fire if we don't already have a death record for this player
            if not s.volatile.deaths[disp] or not s.volatile.deaths[disp].t then
              DM2M:OnUnitDeath(disp, tag)
            end
          elseif not wasAlive and alive then
            -- Transition dead -> alive: fallback revive detection
            DM2M:OnUnitRevive(disp)
            -- Only process rez if no pending deferred rez is already queued
            if not _pendingRezzes[disp] then
              local _, cx, cy, cz = GetUnitWorldPosition(tag)
              DM2M:MarkRezAccept(disp, nil, { force = false, curX = cx, curY = cy, curZ = cz })
            end
          end
        end

        s.volatile.lastAlive[disp] = alive
      end
    end
  end
end

function DM2M:OnPlayerActivated()
  local inD = isInDungeonOrTrial()
  local s = ensureStats()
  if inD and not s.volatile.inDungeon then
    s.volatile.inDungeon = true
    DM2M:StartRun()
  elseif (not inD) and s.volatile.inDungeon then
    s.volatile.inDungeon = false
    DM2M:EndRun()
  end
  rebuildRoster()
end

-- ============================= UI ==================================
local COLS = {
  { key="name",      title="Name",        w=185, align=TEXT_ALIGN_LEFT },
  { key="deaths",    title="Deaths",      w=70  },
  { key="rezRcvd",   title="Rez Rcvd",    w=80  },
  { key="timeDead",  title="Time Dead",   w=100 },
  { key="rezPerf",   title="Rez’d Others",w=110 },
  { key="rezAvg",    title="Rezzing Avg", w=110 },
  { key="fastest",   title="Fastest Rez", w=110 },
  { key="inferred",  title="Inferred",    w=80  },
  { key="diedFirst", title="Died 1st",    w=100 },
}

local ROWH = 32
local PADX = 12

-- Unbroken badge (shown when a player has 0 deaths)
--local UNBROKEN_ICON = "EsoUI/Art/Miscellaneous/trophy.dds"  -- safe, readable
local UNBROKEN_ICON = "EsoUI/Art/Progression/progression_shield.dds"  
local MVP_ICON = "EsoUI/Art/Miscellaneous/trophy.dds"

local function texIcon(path, size)
  size = size or 18
  return string.format("|t%d:%d:%s|t", size, size, path)
end

local function metricRowFromPlayer(disp, P, mvpRezzer)
  local showAvgInstead = getSetting("showAvgDownTimeInsteadOfTotal")
  local avgToBe = (P.rezzesReceived or 0) > 0 and (P.timeDead / P.rezzesReceived) or nil

  local nameText = disp

  if startsWithAt(disp) then
    if (P.deaths or 0) == 0 then
      nameText = string.format("%s  %s", nameText, texIcon(UNBROKEN_ICON, 18))
    end
    if mvpRezzer and disp == mvpRezzer then
      nameText = string.format("%s  %s", nameText, texIcon(MVP_ICON, 18))
    end
  end

  return {
    name      = nameText,
    deaths    = tostring(P.deaths or 0),
    rezRcvd   = tostring(P.rezzesReceived or 0),
    timeDead  = showAvgInstead and fmtClock(avgToBe) or fmtClock(P.timeDead),
    rezPerf   = tostring(P.rezzesPerformed or 0),
    rezAvg    = fmtClock(avg(P.rezTimes)),
    fastest   = fmtClock(P.fastestRez),
    inferred  = tostring(P.inferredAttributions or 0),
    diedFirst = tostring(P.firstToDie or 0),
  }
end


-- Recursively hide and detach all children to free rendering resources.
local function DestroyChildren(ctrl)
  if not ctrl or not ctrl.GetNumChildren then return end
  for i = ctrl:GetNumChildren(), 1, -1 do
    local child = ctrl:GetChild(i)
    if child then
      DestroyChildren(child)
      child:SetHidden(true)
      child:ClearAnchors()
      child:SetParent(nil)
    end
  end
end

-- Fresh content helper: destroy old children so we don't leak controls.
local function NewContent(parent)
  local old = parent._content
  if old then
    DestroyChildren(old)
    old:SetHidden(true)
    old:ClearAnchors()
    old:SetParent(nil)
  end
  local content = WM:CreateControl(nil, parent, CT_CONTROL)
  content:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
  content:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 0, 0)
  parent._content = content
  return content
end

-- Scroll helper for keybinds
local function ScrollStatsBy(delta)
  if not statsWin or statsWin:IsHidden() then return end
  if not statsWin._scroll then return end
  ZO_Scroll_ScrollRelative(statsWin._scroll, delta)
end

function DM2M:CreateStatsPanel()
  if statsWin then return end
  local W = 980

  statsWin = WM:CreateTopLevelWindow("DM2_StatsPanel")
  statsWin:SetDimensions(W, 560)
  statsWin:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
  statsWin:SetMovable(true)
  statsWin:SetMouseEnabled(true)
  statsWin:SetClampedToScreen(true)
  statsWin:SetHidden(true)

  -- outer frame
  local frame = WM:CreateControl(nil, statsWin, CT_BACKDROP)
  frame:SetAnchorFill()
  frame:SetCenterColor(0,0,0,0.08)
  frame:SetEdgeColor(0,0,0,0.8)
  frame:SetEdgeTexture("", 1, 1, 2)

  -- header band
  local header = WM:CreateControl(nil, statsWin, CT_BACKDROP)
  header:SetAnchor(TOPLEFT, statsWin, TOPLEFT, 1, 1)
  header:SetAnchor(TOPRIGHT, statsWin, TOPRIGHT, -1, 1)
  header:SetHeight(ROWH+8)
  header:SetCenterColor(0.78,0.78,0.78,1)
  header:SetEdgeColor(0,0,0,0.9)
  header:SetEdgeTexture("", 1, 1, 1.5)

  -- header labels
  local x = PADX
  for _,c in ipairs(COLS) do
    local lbl = WM:CreateControl(nil, header, CT_LABEL)
    lbl:SetAnchor(TOPLEFT, header, TOPLEFT, x, 6)
    lbl:SetDimensions(c.w, ROWH)
    lbl:SetFont("EsoUI/Common/Fonts/univers67.otf|20|soft-shadow-thin")
    lbl:SetColor(0,0,0,1)
    lbl:SetHorizontalAlignment(c.align or TEXT_ALIGN_CENTER)
    lbl:SetText(c.title)
    x = x + c.w
  end

  -- Vertical divider between "death" metrics and "rez" metrics (after Time Dead)
  local splitIndex = 4  -- after COLS[4] = "Time Dead"
  local splitX = PADX
  for i = 1, splitIndex do
    splitX = splitX + COLS[i].w
  end

  local vlineHeader = WM:CreateControl(nil, header, CT_BACKDROP)
  vlineHeader:SetAnchor(TOPLEFT,  header, TOPLEFT, splitX - 1, 4)
  vlineHeader:SetAnchor(BOTTOMLEFT, header, BOTTOMLEFT, splitX - 1, -4)
  vlineHeader:SetWidth(2)
  vlineHeader:SetCenterColor(0,0,0,0.5)
  vlineHeader:SetEdgeColor(0,0,0,0)

  -- list area container
  local listBG = WM:CreateControl(nil, statsWin, CT_BACKDROP)
  listBG:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 4)
  listBG:SetAnchor(TOPRIGHT, header, BOTTOMRIGHT, 0, 4)
  listBG:SetHeight(410)
  listBG:SetCenterColor(0.78,0.92,1.0,0.55)
  listBG:SetEdgeColor(0,0,0,0.8)
  listBG:SetEdgeTexture("", 1, 1, 1)

  -- scroll container
  local scroll = CreateControlFromVirtual("DM2_StatsScroll", listBG, "ZO_ScrollContainer")
  scroll:SetAnchorFill(listBG)
  local scrollChild = scroll:GetNamedChild("ScrollChild")
  statsWin._scroll = scroll
  statsWin._scrollChild = scrollChild

  -- footer bar (two lines + console scroll hints)
  local footer = WM:CreateControl(nil, statsWin, CT_BACKDROP)
  footer:SetAnchor(TOPLEFT, listBG, BOTTOMLEFT, 0, 6)
  footer:SetAnchor(TOPRIGHT, listBG, BOTTOMRIGHT, 0, 6)
  footer:SetHeight(56)
  footer:SetCenterColor(0.25,0.65,0.9,0.9)
  footer:SetEdgeColor(0,0,0,0.9)
  footer:SetEdgeTexture("", 1, 1, 1.5)

  -- First footer line: left-aligned (plenty of width for long summary)
  local foot1 = WM:CreateControl(nil, footer, CT_LABEL)
  foot1:SetAnchor(TOPLEFT,  footer, TOPLEFT,  PADX + 0, 2)
  foot1:SetAnchor(TOPRIGHT, footer, TOPRIGHT, -(PADX + 0), 2)
  foot1:SetFont("EsoUI/Common/Fonts/univers67.otf|18|soft-shadow-thin")
  foot1:SetColor(0,0,0,1)
  foot1:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

  -- Second footer line: centered, for highlight stats
  local foot2 = WM:CreateControl(nil, footer, CT_LABEL)
  foot2:SetAnchor(TOPLEFT,  footer, TOPLEFT,  PADX + 40, 28)
  foot2:SetAnchor(TOPRIGHT, footer, TOPRIGHT, -(PADX + 40), 28)
  foot2:SetFont("EsoUI/Common/Fonts/univers67.otf|20|soft-shadow-thin")
  foot2:SetColor(1,1,0,1) -- yellow
  foot2:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

  statsWin._footer1 = foot1
  statsWin._footer2 = foot2

  -- Console scroll hints (L1/R1) – only on console UI
  if isConsoleUI() then
    local scrollUp = WM:CreateControl(nil, footer, CT_LABEL)
    scrollUp:SetAnchor(BOTTOMLEFT, footer, BOTTOMLEFT, PADX, -4)
    scrollUp:SetFont("EsoUI/Common/Fonts/univers67.otf|18|soft-shadow-thin")
    scrollUp:SetColor(0,0,0,1)
    scrollUp:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    scrollUp:SetText("L1 < prev")

    local scrollDown = WM:CreateControl(nil, footer, CT_LABEL)
    scrollDown:SetAnchor(BOTTOMRIGHT, footer, BOTTOMRIGHT, -PADX, -4)
    scrollDown:SetFont("EsoUI/Common/Fonts/univers67.otf|18|soft-shadow-thin")
    scrollDown:SetColor(0,0,0,1)
    scrollDown:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    scrollDown:SetText("R1 > next")

    statsWin._scrollUpHint   = scrollUp
    statsWin._scrollDownHint = scrollDown
  end

  -- Top-right buttons for non-console UI (PC users)
  if not isConsoleUI() then
    local closeBtn = CreateControlFromVirtual("DM2M_CloseBtn", statsWin, "ZO_DefaultButton")
    closeBtn:SetAnchor(TOPRIGHT, statsWin, TOPRIGHT, -12, 8)
    closeBtn:SetDimensions(96, 32)
    closeBtn:SetText("Close")
    closeBtn:SetHandler("OnClicked", function() DM2M:HideStatsPanel() end)

    local toggleBtn = CreateControlFromVirtual("DM2M_ToggleBtn", statsWin, "ZO_DefaultButton")
    toggleBtn:SetAnchor(TOPRIGHT, statsWin, TOPRIGHT, -120, 8)
    toggleBtn:SetDimensions(200, 32)
    toggleBtn:SetText("Toggle Lifetime/Run")
    toggleBtn:SetHandler("OnClicked", function()
      showLifetime = not showLifetime
      DM2M:RefreshStatsPanel()
    end)
  end
end

local function computeFooter(bucket)
  local teamDeaths, teamRezzes, teamTotalDown = 0, 0, 0
  local avgSamples, clutch, clean = {}, 0, 0
  local mvpName, mvpPerf, mvpAvg = "-", -1, 999999
  local mfLeaders, mfCount = {}, 0  -- Most First-Deaths (supports ties)

  for disp,P in pairs(bucket.players) do
    if startsWithAt(disp) then
      teamDeaths    = teamDeaths    + (P.deaths or 0)
      teamRezzes    = teamRezzes    + (P.rezzesPerformed or 0)
      teamTotalDown = teamTotalDown + (P.timeDead or 0)
      if (P.rezzesReceived or 0) > 0 then
        table.insert(avgSamples, (P.timeDead or 0) / P.rezzesReceived)
      end
      local thr = getSetting("instaRezSecs")
      if P.rezTimes then
        for i=1,#P.rezTimes do
          if P.rezTimes[i] <= thr then clutch = clutch + 1 end
        end
      end
      if (P.deaths or 0) == 0 then clean = clean + 1 end

      local perf = P.rezzesPerformed or 0
      local a = avg(P.rezTimes) or 999999
      if perf > mvpPerf or (perf == mvpPerf and a < mvpAvg) then
        mvpName, mvpPerf, mvpAvg = disp, perf, a
      end

      -- Track "Most 1st Deaths", accounting for ties.
      local ftd = P.firstToDie or 0
      if ftd > 0 then
        if ftd > mfCount then
          mfCount = ftd
          mfLeaders = { disp }
        elseif ftd == mfCount then
          table.insert(mfLeaders, disp)
        end
      end
    end
  end

  local teamAvgDown = (#avgSamples > 0) and (avg(avgSamples)) or nil
  local fr = bucket.global.fastestRez
  local l1 = string.format(
    "Wipes=%d | Team Deaths=%d | Team Rezzes Given=%d | Team Total Down=%s | Team Avg Down=%s | Fastest Rez=%s",
    bucket.global.wipes or 0,
    teamDeaths,
    teamRezzes,
    fmtClock(teamTotalDown),
    fmtClock(teamAvgDown),
    fmtClock(fr and fr.ttr or nil)
  )

  local mfPart = "-"
  if mfCount > 0 then
    if #mfLeaders == 1 then
      mfPart = string.format("%s (%d)", mfLeaders[1], mfCount)
    else
      mfPart = string.format("%d-way tie (%d)", #mfLeaders, mfCount)
    end
  end

  local l2 = string.format(
    "MVP Rezzer=%s | Clutch Rezzes=%d | Unbroken=%d | Most 1st Deaths=%s",
    mvpName, clutch, clean, mfPart
  )

  return l1, l2
end

function DM2M:RefreshStatsPanel()
  if not statsWin or not statsWin._scrollChild then return end
  local bucket = (showLifetime or getSetting("showLifetimeByDefault"))
                 and ensureStats().lifetime
                  or ensureStats().run
  -- Determine MVP Rezzer (single winner)
  local mvpRezzer = nil
  local mvpPerf   = -1
  local mvpAvg    = 999999

  for disp, P in pairs(bucket.players) do
    if startsWithAt(disp) then
      local perf = P.rezzesPerformed or 0
	  local avgT = avg(P.rezTimes) or 999999
	  if perf > mvpPerf or (perf == mvpPerf and avgT < mvpAvg) then
	    mvpRezzer = disp
	    mvpPerf   = perf
	    mvpAvg    = avgT
	  end
	end
  end
  local scrollChild = statsWin._scrollChild
  local content = NewContent(scrollChild)

  -- show @handles if there are any; else show all names
  local anyHandles = false
  for name,_ in pairs(bucket.players) do
    if startsWithAt(name) then anyHandles = true break end
  end

  local names = {}
  for disp,_ in pairs(bucket.players) do
    if anyHandles then
      if startsWithAt(disp) then table.insert(names, disp) end
    else
      table.insert(names, disp)
    end
  end
  table.sort(names, function(a,b) return tostring(a) < tostring(b) end)

  local y = 2
  for i,disp in ipairs(names) do
    local P = bucket.players[disp]
    local row = WM:CreateControl(nil, content, CT_BACKDROP)
    row:SetAnchor(TOPLEFT,  content, TOPLEFT,  1,  y)
    row:SetAnchor(TOPRIGHT, content, TOPRIGHT, -1, y)
    row:SetHeight(ROWH)
    if (i % 2) == 0 then
      row:SetCenterColor(0.78,0.92,1.0,0.35)
    else
      row:SetCenterColor(0.78,0.92,1.0,0.15)
    end
    row:SetEdgeColor(0,0,0,0.2)

    -- Vertical divider in rows (align with header split after Time Dead)
    do
      local splitIndex = 4
      local splitX = PADX
      for ci = 1, splitIndex do
        splitX = splitX + COLS[ci].w
      end

      local vlineRow = WM:CreateControl(nil, row, CT_BACKDROP)
      vlineRow:SetAnchor(TOPLEFT,  row, TOPLEFT, splitX - 1, 2)
      vlineRow:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, splitX - 1, -2)
      vlineRow:SetWidth(2)
      vlineRow:SetCenterColor(0,0,0,0.25)
      vlineRow:SetEdgeColor(0,0,0,0)
    end

    local metrics = metricRowFromPlayer(disp, P, mvpRezzer)
    local x = PADX
    for _,c in ipairs(COLS) do
      local lbl = WM:CreateControl(nil, row, CT_LABEL)
      lbl:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
      lbl:SetDimensions(c.w, ROWH)
      lbl:SetFont("EsoUI/Common/Fonts/univers57.otf|"
                  .. tostring(getSetting("statsFontSize"))
                  .. "|soft-shadow-thin")
      lbl:SetColor(0,0,0,1)
      lbl:SetHorizontalAlignment(c.align or TEXT_ALIGN_CENTER)
      lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
      lbl:SetText(metrics[c.key] or "-")
      x = x + c.w
    end

    y = y + ROWH + 2
  end
  content:SetHeight(math.max(y + 2, 412))

  local l1, l2 = computeFooter(bucket)
  statsWin._footer1:SetText(l1)
  statsWin._footer2:SetText(l2)
end

-- ============== Keybinds for console (L1 / R1 page scroll) ==========
local function EnsureKeybinds()
  if keybindGroup or not isConsoleUI() then return end

  keybindGroup = {
    alignment = KEYBIND_STRIP_ALIGN_RIGHT,
    {
      name = "Page Up",
      keybind = "UI_SHORTCUT_LEFT_SHOULDER",
      callback = function()
        ScrollStatsBy(-200)
      end,
      visible = function()
        return statsWin ~= nil and not statsWin:IsHidden()
      end,
    },
    {
      name = "Page Down",
      keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
      callback = function()
        ScrollStatsBy(200)
      end,
      visible = function()
        return statsWin ~= nil and not statsWin:IsHidden()
      end,
    },
  }
end

-- ================= Panel visibility / timing ========================
local function scheduleAutoHide()
  local secs = tonumber(getSetting("statsAutoCloseSecs")) or 0
  if secs and secs > 0 then
    DM2M._autoHideTimerActive = true
    zo_callLater(function()
      if DM2M._autoHideTimerActive then
        DM2M:HideStatsPanel()
      end
    end, math.floor(secs * 1000))
  end
end

function DM2M:ShowStatsPanel(show)
  DM2M:CreateStatsPanel()
  if show then
    statsWin:SetHidden(false)
    DM2M:RefreshStatsPanel()
    DM2M._autoHideTimerActive = false
    scheduleAutoHide()

    if isConsoleUI() then
      EnsureKeybinds()
      if keybindGroup then
        KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup)
      end
    end
  else
    DM2M:HideStatsPanel()
  end
end

function DM2M:ToggleStatsPanel()
  DM2M:CreateStatsPanel()
  DM2M:ShowStatsPanel(statsWin:IsHidden())
end

-- ====================== Announcement Popup =========================
local _announcementWin = nil
local _announcementCountdownLabel = nil
local _announcementSecondsLeft = 10

local function dismissAnnouncement()
  DM2M._announcementToken = (DM2M._announcementToken or 0) + 1
  if _announcementWin then _announcementWin:SetHidden(true) end
  EM:UnregisterForUpdate(DM2M.name .. "_AnnounceCountdown")
  if SV then SV.lastAnnouncementVersion = DM2M._latestAnnouncementVersion end
end

local function showAnnouncementPopup(title, body)
  if _announcementWin then dismissAnnouncement() end

  local win = WM:CreateTopLevelWindow("DM2M_Announcement")
  win:SetDimensions(500, 340)
  win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -60)
  win:SetDrawLayer(DL_OVERLAY)
  win:SetDrawTier(DT_HIGH)
  win:SetDrawLevel(500002)
  win:SetMouseEnabled(true)
  win:SetHidden(false)

  local bg = WM:CreateControl("DM2M_AnnouncementBG", win, CT_BACKDROP)
  bg:SetAnchorFill(win)
  bg:SetCenterColor(0.06, 0.06, 0.10, 0.92)
  bg:SetEdgeColor(0.45, 0.85, 0.55, 0.8)
  bg:SetEdgeTexture(nil, 1, 1, 2)

  local header = WM:CreateControl("DM2M_AnnouncementHeader", win, CT_LABEL)
  header:SetFont("EsoUI/Common/Fonts/univers57.otf|15|soft-shadow-thin")
  header:SetColor(0.53, 1.0, 0.53, 1)
  header:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 14)
  header:SetDimensions(450, 18)
  header:SetText(DM2M.displayName .. "  v" .. DM2M.version)

  local titleLbl = WM:CreateControl("DM2M_AnnouncementTitle", win, CT_LABEL)
  titleLbl:SetFont("EsoUI/Common/Fonts/univers67.otf|22|soft-shadow-thick")
  titleLbl:SetColor(1.0, 0.88, 0.35, 1)
  titleLbl:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 8)
  titleLbl:SetDimensions(450, 28)
  titleLbl:SetText(title or "")

  local bodyLbl = WM:CreateControl("DM2M_AnnouncementBody", win, CT_LABEL)
  bodyLbl:SetFont("EsoUI/Common/Fonts/univers57.otf|17|soft-shadow-thin")
  bodyLbl:SetColor(0.92, 0.92, 0.92, 1)
  bodyLbl:SetAnchor(TOPLEFT, titleLbl, BOTTOMLEFT, 0, 8)
  bodyLbl:SetDimensions(450, 200)
  bodyLbl:SetWrapMode(TEXT_WRAP_MODE_WORD)
  bodyLbl:SetMaxLineCount(12)
  bodyLbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
  bodyLbl:SetText(body or "")

  local btn = WM:CreateControl("DM2M_AnnouncementBtn", win, CT_LABEL)
  btn:SetFont("EsoUI/Common/Fonts/univers67.otf|18|soft-shadow-thick")
  btn:SetColor(0.4, 0.9, 1.0, 1)
  btn:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 20, -14)
  btn:SetDimensions(100, 24)
  btn:SetText("[ Got it! ]")
  btn:SetMouseEnabled(true)
  btn:SetHandler("OnMouseUp", function() dismissAnnouncement() end)
  btn:SetHandler("OnMouseEnter", function(self) self:SetColor(0.6, 1.0, 1.0, 1) end)
  btn:SetHandler("OnMouseExit",  function(self) self:SetColor(0.4, 0.9, 1.0, 1) end)

  local countdown = WM:CreateControl("DM2M_AnnouncementCountdown", win, CT_LABEL)
  countdown:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thin")
  countdown:SetColor(0.6, 0.6, 0.6, 1)
  countdown:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -16)
  countdown:SetDimensions(160, 18)
  countdown:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

  _announcementWin = win
  _announcementCountdownLabel = countdown
  _announcementSecondsLeft = 10
  countdown:SetText(string.format("Closing in %ds...", _announcementSecondsLeft))

  DM2M._announcementToken = (DM2M._announcementToken or 0) + 1
  local myToken = DM2M._announcementToken
  EM:RegisterForUpdate(DM2M.name .. "_AnnounceCountdown", 1000, function()
    if DM2M._announcementToken ~= myToken then
      EM:UnregisterForUpdate(DM2M.name .. "_AnnounceCountdown")
      return
    end
    _announcementSecondsLeft = _announcementSecondsLeft - 1
    if _announcementSecondsLeft <= 0 then
      dismissAnnouncement()
    elseif _announcementCountdownLabel then
      _announcementCountdownLabel:SetText(string.format("Closing in %ds...", _announcementSecondsLeft))
    end
  end)
end

-- ============================= Share & Scrub ========================
function DM2M:ShareStatsToChat()
  local s = ensureStats()
  local bucket = (showLifetime or getSetting("showLifetimeByDefault"))
                 and s.lifetime or s.run
  local parts, names = {}, {}
  for k in pairs(bucket.players) do
    if startsWithAt(k) then table.insert(names, k) end
  end
  table.sort(names)
  for _,disp in ipairs(names) do
    local P = bucket.players[disp]
    table.insert(parts, string.format(
      "%s: Deaths=%d RezRecv=%d RezGiven=%d TotalDown=%s Fastest=%s Died1st=%d Naughty=%d",
      disp,
      P.deaths or 0,
      P.rezzesReceived or 0,
      P.rezzesPerformed or 0,
      fmtClock(P.timeDead),
      fmtClock(P.fastestRez),
      P.firstToDie or 0,
      P.naughtyCompanionRezzes or 0
    ))
  end
  local fr = bucket.global.fastestRez
  local tail = string.format(
    "Wipes=%d Fastest=%s",
    bucket.global.wipes or 0,
    fmtClock(fr and fr.ttr or nil)
  )
  d("|c00D7FFDM2|r " .. table.concat(parts, " | ") .. " || " .. tail)
end

local function scrubNonPlayers()
  local s = ensureStats()
  local function scrubPlayers(tbl)
    for k,_ in pairs(tbl.players) do
      if not startsWithAt(k) then tbl.players[k] = nil end
    end
  end
  scrubPlayers(s.run)
  scrubPlayers(s.lifetime)
  for k,_ in pairs(s.volatile.deaths) do
    if not startsWithAt(k) then s.volatile.deaths[k] = nil end
  end
  d("[DM2 Metrics] Scrub complete: removed non-player entries.")
end

local function resetAllMetrics()
  SV.metrics = deepcopy(DM2M.defaults.stats)
  SV._statsInitialized = true  -- already fresh from deepcopy
  ensureStats()
  d("[DM2 Metrics] All metrics have been reset. (Thanks beta testers!)")
  DM2M:RefreshStatsPanel()
end

-- ============================== LAM =================================
function DM2M:RegisterLAM()
  local LAM = (LibStub and LibStub("LibAddonMenu-2.0")) or _G["LibAddonMenu2"]
  if not LAM then return end

  local panelId = DM2M.name .. "_Panel"

  local panel = {
    type = "panel",
    name = DM2M.displayName,
    displayName = DM2M.displayName,
    author = "Skye-Forge",
    version = DM2M.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local options = {
    { type="checkbox",
      name="Enable metrics",
      tooltip="Turn DM2 Metrics on or off. When off, no new deaths, rezzes, or wipes are recorded.",
      getFunc=function() return getSetting("enable") end,
      setFunc=function(v) setSetting("enable", v) end,
      default=DM2M.defaults.settings.enable
    },
    { type="checkbox",
      name="Record only in Dungeons/Trials",
      tooltip="When enabled, metrics are recorded only inside dungeons and trials.",
      getFunc=function() return getSetting("scopeDungeonsTrialsOnly") end,
      setFunc=function(v) setSetting("scopeDungeonsTrialsOnly", v) end,
      default=DM2M.defaults.settings.scopeDungeonsTrialsOnly
    },
    { type="checkbox",
      name="Auto-show stats at run end",
      tooltip="Show the stats window automatically at the end of a dungeon/trial run.",
      getFunc=function() return getSetting("autoShowAtEnd") end,
      setFunc=function(v) setSetting("autoShowAtEnd", v) end,
      default=DM2M.defaults.settings.autoShowAtEnd
    },

    { type="header", name="Display" },

    { type="checkbox",
      name="Show Avg Down Time instead of Total",
      tooltip="If enabled, Time Dead shows the average time per death. If disabled, it shows total time spent dead.",
      getFunc=function() return getSetting("showAvgDownTimeInsteadOfTotal") end,
      setFunc=function(v)
        setSetting("showAvgDownTimeInsteadOfTotal", v)
        DM2M:RefreshStatsPanel()
      end,
      default=DM2M.defaults.settings.showAvgDownTimeInsteadOfTotal
    },

    { type="slider",
      name="Stats font size",
      tooltip="Adjust the font size used in the stats table.",
      min=16, max=28, step=1,
      getFunc=function() return getSetting("statsFontSize") end,
      setFunc=function(v)
        setSetting("statsFontSize", v)
        DM2M:RefreshStatsPanel()
      end,
      default=DM2M.defaults.settings.statsFontSize
    },

    { type="slider",
      name="Stats auto-close (seconds, 0 = never)",
      tooltip="How long the stats window stays open before auto-closing. Set to 0 to keep it open until you close it.",
      min=0, max=60, step=2,
      getFunc=function() return getSetting("statsAutoCloseSecs") end,
      setFunc=function(v) setSetting("statsAutoCloseSecs", v) end,
      default=DM2M.defaults.settings.statsAutoCloseSecs
    },

    { type="checkbox",
      name="Default: show Lifetime (else Run)",
      tooltip="Choose whether the stats window shows Lifetime stats or the current Run by default.",
      getFunc=function() return getSetting("showLifetimeByDefault") end,
      setFunc=function(v) setSetting("showLifetimeByDefault", v) end,
      default=DM2M.defaults.settings.showLifetimeByDefault
    },

    { type="button",
      name="Show stats window now",
      tooltip="Open the DM2 Metrics stats window immediately.",
      func=function()
        DM2M:ShowStatsPanel(true)
      end,
    },

    { type="header", name="Rez Detection" },

    { type="slider",
      name="Max rez distance (m)",
      tooltip="Maximum distance between the dead player and the rezzer for us to credit a resurrection. Larger values are more forgiving but less precise.",
      min=5, max=40, step=1,
      getFunc=function() return getSetting("rezMaxDistM") end,
      setFunc=function(v) setSetting("rezMaxDistM", v) end,
      default=DM2M.defaults.settings.rezMaxDistM
    },

    { type="slider",
      name="Wayshrine min seconds",
      tooltip="If a player returns faster than this, it is treated as a wayshrine or automatic respawn and is NOT counted as a combat rez.",
      min=0, max=15, step=0.5,
      getFunc=function() return getSetting("wayshrineMinSecs") end,
      setFunc=function(v) setSetting("wayshrineMinSecs", v) end,
      default=DM2M.defaults.settings.wayshrineMinSecs
    },

    { type="checkbox",
      name="Infer rezzer when unknown",
      tooltip="When the game log doesn't clearly show who rezzed a player, try to guess based on who was closest to the body.",
      getFunc=function() return getSetting("inferAttribution") end,
      setFunc=function(v) setSetting("inferAttribution", v) end,
      default=DM2M.defaults.settings.inferAttribution
    },

    { type="slider",
      name="Inference: channel secs",
      tooltip="How long a rezzer needs to stay near a body before being treated as the one who resurrected that player.",
      min=1, max=4, step=0.5,
      getFunc=function() return getSetting("inferMinChannelSecs") end,
      setFunc=function(v) setSetting("inferMinChannelSecs", v) end,
      default=DM2M.defaults.settings.inferMinChannelSecs
    },

    { type="slider",
      name="Inference: proximity (m)",
      tooltip="How close a player must be to a body to be considered a possible rezzer.",
      min=2, max=12, step=0.5,
      getFunc=function() return getSetting("inferProximityM") end,
      setFunc=function(v) setSetting("inferProximityM", v) end,
      default=DM2M.defaults.settings.inferProximityM
    },

    { type="slider",
      name="Combat-log defer (ms)",
      tooltip="How long to wait for the combat log resurrect event before falling back to proximity inference. Increase on console if rezzer names are often wrong.",
      min=300, max=1500, step=50,
      getFunc=function() return getSetting("rezCombatLogDeferMs") end,
      setFunc=function(v) setSetting("rezCombatLogDeferMs", v) end,
      default=DM2M.defaults.settings.rezCombatLogDeferMs
    },

    { type="header", name="Boss Wipe Detection" },

    { type="checkbox",
      name="Require boss present (recently)",
      tooltip="Only count wipes when a boss has been active in the last few seconds. Turn this off if you also want wipes on trash pulls.",
      getFunc=function() return getSetting("wipeRequireBoss") end,
      setFunc=function(v) setSetting("wipeRequireBoss", v) end,
      default=DM2M.defaults.settings.wipeRequireBoss
    },
	{ type="checkbox",
	  name="Only count 'Died 1st' on boss pulls",
	  tooltip="When enabled, the Died 1st metric updates only when a boss has been active recently. When disabled, every pull (trash or boss) has a first death.",
	  getFunc=function() return getSetting("firstToDieBossOnly") end,
	  setFunc=function(v) setSetting("firstToDieBossOnly", v) end,
	  default=DM2M.defaults.settings.firstToDieBossOnly
	},

    { type="slider",
      name="Boss grace window (seconds)",
      tooltip="How long after the last boss sighting still counts as 'boss recently active'. Affects wipe detection and Died 1st attribution.",
      min=5, max=60, step=1,
      getFunc=function() return getSetting("bossGraceSecs") end,
      setFunc=function(v) setSetting("bossGraceSecs", v) end,
      default=DM2M.defaults.settings.bossGraceSecs
    },

    { type="slider",
      name="All-dead window (s, 0 = instant)",
      tooltip="How long the whole tracked group must be dead before we call it a wipe. Set to 0 for an instant wipe as soon as everyone is down.",
      min=0, max=10, step=0.5,
      getFunc=function() return getSetting("wipeAllDeadWindowSecs") end,
      setFunc=function(v) setSetting("wipeAllDeadWindowSecs", v) end,
      default=DM2M.defaults.settings.wipeAllDeadWindowSecs
    },

    { type="header", name="Companions" },

    { type="checkbox",
      name="Track companion rezzes (Naughty column)",
      tooltip="When a companion resurrects a player, count it in the Naughty column. The rez still counts for the target's stats.",
      getFunc=function() return getSetting("trackCompanionRezzes") end,
      setFunc=function(v) setSetting("trackCompanionRezzes", v) end,
      default=DM2M.defaults.settings.trackCompanionRezzes
    },

    { type="header", name="Maintenance" },

    { type="button",
      name="Scrub non-player entries now",
      tooltip="Remove NPC/monster rows from Run, Lifetime, and Volatile.",
      func=function()
        scrubNonPlayers()
        DM2M:RefreshStatsPanel()
      end
    },

    { type="button",
      name="Reset ALL metrics (thanks beta testers!)",
      tooltip="Clear Run, Lifetime, and volatile stats for this account.",
      func=function()
        resetAllMetrics()
      end
    },
  }

  LAM:RegisterAddonPanel(panelId, panel)
  LAM:RegisterOptionControls(panelId, options)
end

-- ============================== Slash ===============================
function DM2M:RegisterSlash()
  SLASH_COMMANDS["/dmm"] = function(arg)
    arg = (arg or ""):lower()
    if arg == "off" or arg == "hide" or arg == "close" then DM2M:HideStatsPanel() return end
    if arg == "share" then DM2M:ShareStatsToChat() return end
    if arg == "scrub" then scrubNonPlayers(); DM2M:RefreshStatsPanel() return end
    DM2M:ToggleStatsPanel()
  end
end

-- Public clear so base /dm clear (if present) can close this too
function DM2_Metrics_Clear()
  DM2M:HideStatsPanel()
end

-- ============================== Wire-up =============================
function DM2M:HideStatsPanel()
  if not statsWin then return end
  statsWin:SetHidden(true)
  DM2M._autoHideTimerActive = false

  if keybindGroup and isConsoleUI() then
    KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup)
  end
end

local function onUpdateTick()
  if not getSetting("enable") then return end
  if getSetting("scopeDungeonsTrialsOnly") and not isInDungeonOrTrial() then return end
  DM2M:OnUpdate()
end

local function OnPlayerActivated()
  DM2M:OnPlayerActivated()
end

local function OnCombatEvent(...)
  DM2M:OnCombatEvent(...)
end

local function OnGroupMemberChanged()
  rebuildRoster()
end

local function OnAddOnLoaded(_, addonName)
  if addonName ~= DM2M.name then return end
  EM:UnregisterForEvent(DM2M.name, EVENT_ADD_ON_LOADED)

  SV = ZO_SavedVars:NewAccountWide(DM2M.ns, 1, nil, {
    settings = deepcopy(DM2M.defaults.settings),
    metrics  = deepcopy(DM2M.defaults.stats),
  })
  ensureSettings()
  ensureStats()

  DM2M:RegisterLAM()
  DM2M:RegisterSlash()
  DM2M:CreateStatsPanel()

  EM:RegisterForEvent(DM2M.name.."_COMBAT",    EVENT_COMBAT_EVENT,          OnCombatEvent)
  EM:RegisterForEvent(DM2M.name.."_ACTIVATED", EVENT_PLAYER_ACTIVATED,      OnPlayerActivated)
  EM:RegisterForUpdate(DM2M.name.."_UPDATE",   200,                         onUpdateTick)
  EM:RegisterForEvent(DM2M.name.."_GRPJOIN",   EVENT_GROUP_MEMBER_JOINED,   OnGroupMemberChanged)
  EM:RegisterForEvent(DM2M.name.."_GRPLEAVE",  EVENT_GROUP_MEMBER_LEFT,     OnGroupMemberChanged)

  EM:RegisterForEvent(DM2M.name.."_DEATH", EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
    if not getSetting("enable") then return end
    if getSetting("scopeDungeonsTrialsOnly") and not isInDungeonOrTrial() then return end
    if not isRealPlayerByTag(unitTag) then return end

    local disp = metricKeyFromUnitTag(unitTag)
    if not disp or not startsWithAt(disp) then return end

    if isDead then
      DM2M:OnUnitDeath(disp, unitTag)
      if statsWin and not statsWin:IsHidden() then
        DM2M:RefreshStatsPanel()
      end
    else
      DM2M:OnUnitRevive(disp)
      -- Defer rez processing: give the combat event time to arrive with the
      -- accurate rezzer name before we fall back to proximity inference.
      local _, cx, cy, cz = GetUnitWorldPosition(unitTag)
      local pullId = (ensureStats().volatile.pullId or 0)
      _pendingRezzes[disp] = { pullId = pullId, curX = cx, curY = cy, curZ = cz }
      local deferMs = math.floor(tonumber(getSetting("rezCombatLogDeferMs")) or 750)
      zo_callLater(function()
        local pending = _pendingRezzes[disp]
        if pending and pending.pullId == pullId then
          DM2M:MarkRezAccept(disp, nil, {
            force = false,
            curX  = pending.curX,
            curY  = pending.curY,
            curZ  = pending.curZ,
          })
          _pendingRezzes[disp] = nil
          if statsWin and not statsWin:IsHidden() then
            DM2M:RefreshStatsPanel()
          end
        end
      end, deferMs)
    end
  end)

  d(string.format("|c00D7FF%s|r v%s loaded. /dmm", DM2M.displayName, DM2M.version))

  -- Version-anchored announcement popup (delayed 3s so login UI settles)
  if SV.lastAnnouncementVersion ~= DM2M._latestAnnouncementVersion then
    local ann = DM2M._announcements[DM2M._latestAnnouncementVersion]
    if ann then
      zo_callLater(function()
        showAnnouncementPopup(ann.title, ann.body)
      end, 3000)
    end
  end
end

EM:RegisterForEvent(DM2M.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
