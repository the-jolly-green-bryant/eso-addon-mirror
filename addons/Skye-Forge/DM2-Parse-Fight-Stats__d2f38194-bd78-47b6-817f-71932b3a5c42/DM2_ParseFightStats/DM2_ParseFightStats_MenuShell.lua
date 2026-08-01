---------------------------------------------------------------------
-- DM2_ParseFightStats_MenuShell.lua — experimental gamepad menu viewer
-- v3.7.7: Rotation timeline colors + readable KPIs; History redesign (cards + table).
-- Overlay (BuildUI / RenderSession) is unchanged and remains the default path.
-- Data via DM2Stats public history API only. Locals top-down (console-safe).
---------------------------------------------------------------------

DM2Stats = DM2Stats or {}
local R = DM2Stats

DM2StatsMenuShell = DM2StatsMenuShell or {}
local M = DM2StatsMenuShell

M.name    = "DM2StatsMenuShell"
M.version = "3.7.7"

local WM = WINDOW_MANAGER
local SCENE_NAME = "dm2StatsMenuShellGamepad"
local MENU_ENTRY_ID = 99743

-- Layout: side pad + nav/content gap tuned to avoid left plate bleed on TV.
local SHELL_SIDE_PAD = 42
local CONTENT_HEADER_INSET = 126
local CONTENT_FOOTER_INSET = 66
local CONTENT_PAD = 14
local NAV_CONTENT_GAP = 28
local CONTENT_PLATE_INSET = 12
local NAV_RAIL_FRAC = 0.22
local NAV_RAIL_MIN = 220
local NAV_RAIL_MAX = 340

local LIST_ICON = 32
local LIST_ROW_H = 42
local LIST_MAX_ROWS = 14         -- fill vertical space on buffs/procs
local DASH_TOP_SKILL_ICON = 28
local DASHBOARD_COL_GAP = 12
local BAR_ICON_SIZE = 36
local SPARK_MAX_BARS = 16
local SPARK_BAR_MAX_H = 40
local TREND_MAX_COLS = 8
local TREND_SPARK_MAX_BARS = 8
local TREND_SPARK_BAR_MAX_H = 32
local TREND_HIST_LINES = 7
local COMP_COLS = 4
local COMP_METRICS = 7
local ROT_TIMELINE_LINES = 14
local PULSE_BLOCKS = 40
local BUFF_MAX_ROWS = 14
local PROC_MAX_ROWS = 12

local THEME = {
  plateR = 0.07, plateG = 0.06, plateB = 0.055, plateA = 0.94,
  plateEdgeR = 0.62, plateEdgeG = 0.48, plateEdgeB = 0.28, plateEdgeA = 0.72,
  railR = 0.05, railG = 0.045, railB = 0.04, railA = 0.78,
  railEdgeR = 0.50, railEdgeG = 0.40, railEdgeB = 0.24, railEdgeA = 0.45,
  cardR = 0.10, cardG = 0.09, cardB = 0.08, cardA = 0.42,
  cardEdgeR = 0.58, cardEdgeG = 0.46, cardEdgeB = 0.28, cardEdgeA = 0.55,
  titleR = 0.92, titleG = 0.78, titleB = 0.48,
  textR = 0.94, textG = 0.93, textB = 0.90,
  mutedR = 0.72, mutedG = 0.70, mutedB = 0.66,
  frontR = 0.53, frontG = 0.87, frontB = 0.67,
  backR = 0.53, backG = 0.67, backB = 0.87,
}

-- Full section set (preview only — does not replace overlay pages).
local TAB = {
  OVERVIEW  = 1,
  DASHBOARD = 2,
  DAMAGE    = 3,
  WEAVE     = 4,
  BUFFS     = 5,
  GEAR      = 6,
  PROCS     = 7,
  ROTATION  = 8,
  HISTORY   = 9,
}

local NAV_ENTRIES = {
  { tab = TAB.OVERVIEW,  label = "Overview",  sub = "Full summary" },
  { tab = TAB.DASHBOARD, label = "Dashboard", sub = "At-a-glance" },
  { tab = TAB.DAMAGE,    label = "Damage",    sub = "Full skill table" },
  { tab = TAB.WEAVE,     label = "Weave",     sub = "Per-skill + DoT" },
  { tab = TAB.BUFFS,     label = "Buffs",     sub = "Uptime table" },
  { tab = TAB.GEAR,      label = "Gear",      sub = "Bars + worn" },
  { tab = TAB.PROCS,     label = "Procs",     sub = "Set contribution" },
  { tab = TAB.ROTATION,  label = "Rotation",  sub = "Timeline + pulse" },
  { tab = TAB.HISTORY,   label = "History",   sub = "Trends + compare" },
}

local TAB_MAX = TAB.HISTORY
local TAB_KEY = {
  [TAB.OVERVIEW] = "overview",
  [TAB.DASHBOARD] = "dashboard",
  [TAB.DAMAGE] = "damage",
  [TAB.WEAVE] = "weave",
  [TAB.BUFFS] = "buffs",
  [TAB.GEAR] = "gear",
  [TAB.PROCS] = "procs",
  [TAB.ROTATION] = "rotation",
  [TAB.HISTORY] = "history",
}

local historyOffset = 0
local screenObject = nil
local sceneObject = nil
local fragmentObject = nil
local keybindGroup = nil
local menuEntryAdded = false
local sceneBuildFailed = false
local listPopulateWarned = false
local headerNote = ""

---------------------------------------------------------------------
-- Platform / format helpers (Tier 0)
---------------------------------------------------------------------
local function isGamepadPreferred()
  if type(IsInGamepadPreferredMode) == "function" then return IsInGamepadPreferredMode() end
  if type(IsInGamepadMode) == "function" then return IsInGamepadMode() end
  if type(IsConsoleUI) == "function" then return IsConsoleUI() end
  if type(ZO_IsConsoleUI) == "function" then return ZO_IsConsoleUI() end
  return false
end

local function clampNum(v, lo, hi)
  if zo_clamp then return zo_clamp(v, lo, hi) end
  return math.max(lo, math.min(v, hi))
end

local function floorNum(v)
  if zo_floor then return zo_floor(v) end
  return math.floor(v)
end

local function fmtInt(n)
  n = tonumber(n) or 0
  n = math.floor(n + 0.5)
  if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(n) end
  return tostring(n)
end

local function fmtDps(dps)
  dps = tonumber(dps) or 0
  if dps < 0 then dps = 0 end
  if dps >= 1000000 then return string.format("%.2fm", dps / 1000000) end
  if dps >= 1000 then return string.format("%.1fk", dps / 1000) end
  return string.format("%.0f", dps)
end

local function fmtPct(x)
  x = tonumber(x) or 0
  return string.format("%.1f%%", x * 100)
end

local function fmtDur(ms)
  ms = tonumber(ms) or 0
  if ms < 0 then ms = 0 end
  local total = ms / 1000
  local mins = math.floor(total / 60)
  local secs = total - (mins * 60)
  return string.format("%d:%04.1f", mins, secs)
end

local function truncateText(text, maxLen)
  text = tostring(text or "?")
  maxLen = tonumber(maxLen) or 18
  if #text <= maxLen then return text end
  return string.sub(text, 1, maxLen - 1) .. "…"
end

local function dashFont(size)
  return string.format("$(BOLD_FONT)|$(KB_%d)|thick-outline:6;soft-shadow-thick", size)
end

local function getAbilityIcon(abilityId)
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return nil end
  if type(GetAbilityIcon) == "function" then
    local ok, tex = pcall(GetAbilityIcon, abilityId)
    if ok and tex and tex ~= "" then return tex end
  end
  return nil
end

local function getAbilityName(abilityId)
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return "Unknown Skill" end
  if type(GetAbilityName) == "function" then
    local ok, name = pcall(GetAbilityName, abilityId)
    if ok and name and name ~= "" then
      if type(zo_strformat) == "function" then
        return zo_strformat("<<1>>", name)
      end
      return name
    end
  end
  return string.format("Skill %d", abilityId)
end

local function resolveSlotIcon(abilityId)
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return nil end
  local tex = getAbilityIcon(abilityId)
  if not tex or tex == "" then return nil end
  local lower = string.lower(tex)
  if string.find(lower, "question", 1, true) or string.find(lower, "unknown", 1, true) then
    return nil
  end
  return tex
end

---------------------------------------------------------------------
-- History bridge (via R public API — no SV nesting hacks)
---------------------------------------------------------------------
local function historyCount()
  if type(R.GetMenuHistoryCount) == "function" then
    local ok, n = pcall(function() return R:GetMenuHistoryCount() end)
    if ok then return tonumber(n) or 0 end
  end
  return 0
end

local function historyAt(offset)
  if type(R.GetMenuHistoryAt) == "function" then
    local ok, s = pcall(function() return R:GetMenuHistoryAt(offset) end)
    if ok and type(s) == "table" then return s end
  end
  return nil
end

local function bucketMs()
  if type(R.GetMenuBucketMs) == "function" then
    local ok, n = pcall(function() return R:GetMenuBucketMs() end)
    if ok and tonumber(n) and tonumber(n) > 0 then return tonumber(n) end
  end
  return 2000
end

local function clampHistoryOffset(offset, count)
  offset = tonumber(offset) or 0
  count = tonumber(count) or 0
  if count <= 0 then return 0 end
  if offset < 0 then offset = 0 end
  if offset > count - 1 then offset = count - 1 end
  return offset
end

local function sessionAvgDps(session)
  local dur = tonumber(session and session.durationMs) or 0
  if dur <= 0 then return 0 end
  return (tonumber(session.totalDamage) or 0) / (dur / 1000)
end

local function sessionPeakDps(session)
  local bms = bucketMs()
  local peak = 0
  if session and type(session.buckets) == "table" then
    for _, b in pairs(session.buckets) do
      if type(b) == "table" then
        local dps = (tonumber(b.dmg) or 0) / (bms / 1000)
        if dps > peak then peak = dps end
      end
    end
  end
  if peak <= 0 then peak = tonumber(session and session.maxHit) or 0 end
  return peak
end

local function sessionCritPct(session)
  local hits = tonumber(session and session.hitCount) or 0
  if hits <= 0 then return 0 end
  return (tonumber(session.critCount) or 0) / hits
end

local function getWeaveSuccessRatio(session)
  if not session or type(session.weave) ~= "table" then return 0 end
  local w = session.weave
  local good = tonumber(w.onTimeCount) or 0
  local late = tonumber(w.lateCount) or 0
  local missed = tonumber(w.missedCount) or 0
  local tooFast = tonumber(w.tooFastCount) or 0
  local total = good + late + missed + tooFast
  if total <= 0 then return 0 end
  return math.max(0, math.min(1, (good + late) / total))
end

local function sessionLaHits(session)
  local w = session and session.weave
  if type(w) ~= "table" then return 0 end
  return tonumber(w.laCount) or tonumber(w.laPressCount) or tonumber(w.laHits) or 0
end

local function formatSessionTimestampShort(session)
  local ts = session and (session.completedAt or session.endEpoch or session.timestamp)
  ts = tonumber(ts)
  if not ts or ts <= 0 then return "-" end
  return os.date("%m/%d %H:%M", ts)
end

local function getSkillBar(session, abilityId)
  if not session or type(session.slottedAbilityBar) ~= "table" then return nil end
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return nil end
  local bar = session.slottedAbilityBar[tostring(abilityId)] or session.slottedAbilityBar[abilityId]
  if bar == "Front" or bar == "Back" then return bar end
  return nil
end

local function barChipLabel(bar)
  if bar == "Front" then return "F" end
  if bar == "Back" then return "B" end
  return ""
end

local function barChipColor(bar)
  if bar == "Front" then return THEME.frontR, THEME.frontG, THEME.frontB, 1 end
  if bar == "Back" then return THEME.backR, THEME.backG, THEME.backB, 1 end
  return THEME.mutedR, THEME.mutedG, THEME.mutedB, 0.4
end

---------------------------------------------------------------------
-- View models (menu-only; do not refactor overlay)
---------------------------------------------------------------------
local function buildTopSkillRows(session, maxRows)
  maxRows = tonumber(maxRows) or LIST_MAX_ROWS
  local rows = {}
  if not session or type(session.skills) ~= "table" then return rows end
  local totalDamage = tonumber(session.totalDamage) or 0
  local dur = tonumber(session.durationMs) or 0
  local skillArr = {}
  for id, sk in pairs(session.skills) do
    if type(sk) == "table" then
      local abilityId = tonumber(sk.id) or tonumber(id) or 0
      table.insert(skillArr, {
        id = abilityId,
        name = sk.name,
        dmg = tonumber(sk.dmg) or 0,
        hits = tonumber(sk.hits) or 0,
        crit = tonumber(sk.crit) or 0,
        max = tonumber(sk.max) or 0,
        dot = tonumber(sk.dot) or 0,
      })
    end
  end
  table.sort(skillArr, function(a, b) return (a.dmg or 0) > (b.dmg or 0) end)
  for i = 1, math.min(maxRows, #skillArr) do
    local sk = skillArr[i]
    local dmg = sk.dmg or 0
    local hits = sk.hits or 0
    local share = totalDamage > 0 and (dmg / totalDamage) or 0
    local dps = dur > 0 and (dmg / (dur / 1000)) or 0
    local critPct = hits > 0 and ((sk.crit or 0) / hits) or 0
    local avgHit = hits > 0 and (dmg / hits) or 0
    local dotp = dmg > 0 and ((sk.dot or 0) / dmg) or 0
    local kind = (dotp > 0.95) and "DoT" or (dotp < 0.05) and "Direct" or "Mixed"
    local abilityId = sk.id or 0
    local name = sk.name
    if not name or name == "" then name = getAbilityName(abilityId) end
    local bar = getSkillBar(session, abilityId)
    rows[i] = {
      name = name,
      sub = string.format(
        "%s share · %s DPS · %s hits · crit %s · avg %s · %s",
        fmtPct(share), fmtDps(dps), tostring(hits), fmtPct(critPct), fmtInt(avgHit), kind
      ),
      icon = getAbilityIcon(abilityId),
      bar = bar,
      share = share,
      -- dense Damage table columns
      amountTxt = fmtInt(dmg),
      hitsTxt = tostring(hits),
      avgTxt = fmtInt(avgHit),
      shareTxt = fmtPct(share),
      critTxt = fmtPct(critPct),
      kindTxt = kind,
      dpsTxt = fmtDps(dps),
      maxTxt = fmtInt(sk.max),
    }
  end
  return rows
end

local function buildBuffModelRows(session, maxRows)
  maxRows = tonumber(maxRows) or LIST_MAX_ROWS
  local rows = {}
  if not session or type(session.buffs) ~= "table" then return rows end
  local dur = tonumber(session.durationMs) or 0
  local arr = {}
  for _, b in pairs(session.buffs) do
    if type(b) == "table" then table.insert(arr, b) end
  end
  table.sort(arr, function(a, b) return (tonumber(a.activeMs) or 0) > (tonumber(b.activeMs) or 0) end)
  for i = 1, math.min(maxRows, #arr) do
    local b = arr[i]
    local activeMs = tonumber(b.activeMs) or 0
    local uptime = dur > 0 and (activeMs / dur) or 0
    local abilityId = tonumber(b.id) or 0
    local tier = (uptime >= 0.95) and "Core" or (uptime >= 0.50) and "Maintained" or "Situational"
    local source = "Buff"
    if abilityId > 0 and session.slottedAbilityIds and session.slottedAbilityIds[abilityId] then
      source = "Skill"
    elseif abilityId > 0 and session.skills and session.skills[abilityId] then
      source = "Self"
    end
    rows[i] = {
      name = b.name or "?",
      sub = string.format("%s · %s up · active %s · x%s · %s", source, fmtPct(uptime), fmtDur(activeMs), fmtInt(b.applied or 0), tier),
      icon = getAbilityIcon(abilityId),
      bar = getSkillBar(session, abilityId),
      share = uptime,
      sourceTxt = source,
      uptimeTxt = fmtPct(uptime),
      activeTxt = fmtDur(activeMs),
      appsTxt = tostring(tonumber(b.applied) or 0),
      tierTxt = tier,
    }
  end
  return rows
end

local function buildProcModelRows(session, maxRows)
  maxRows = tonumber(maxRows) or LIST_MAX_ROWS
  local rows = {}
  if not session or type(session.sets) ~= "table" then return rows end
  local totalDamage = tonumber(session.totalDamage) or 0
  local dur = tonumber(session.durationMs) or 0
  local arr = {}
  for _, ps in pairs(session.sets) do
    if type(ps) == "table" then table.insert(arr, ps) end
  end
  table.sort(arr, function(a, b) return (tonumber(a.dmg) or 0) > (tonumber(b.dmg) or 0) end)
  for i = 1, math.min(maxRows, #arr) do
    local ps = arr[i]
    local dmg = tonumber(ps.dmg) or 0
    local hits = tonumber(ps.hits) or 0
    local share = totalDamage > 0 and (dmg / totalDamage) or 0
    local dps = dur > 0 and (dmg / (dur / 1000)) or 0
    local critPct = hits > 0 and ((tonumber(ps.crit) or 0) / hits) or 0
    local dotp = dmg > 0 and ((tonumber(ps.dot) or 0) / dmg) or 0
    local kind = (dotp > 0.95) and "DoT" or (dotp < 0.05) and "Direct" or "Mixed"
    rows[i] = {
      name = ps.name or "?",
      sub = string.format("%s share · %s DPS · %s hits · crit %s · %s · total %s",
        fmtPct(share), fmtDps(dps), tostring(hits), fmtPct(critPct), kind, fmtInt(dmg)),
      icon = nil,
      bar = nil,
      share = share,
      amountTxt = fmtInt(dmg),
      hitsTxt = tostring(hits),
      shareTxt = fmtPct(share),
      critTxt = fmtPct(critPct),
      kindTxt = kind,
      dpsTxt = fmtDps(dps),
    }
  end
  return rows
end

local function buildPerSkillWeaveModel(session, maxRows)
  maxRows = tonumber(maxRows) or 8
  local rows = {}
  if not session or type(session.weave) ~= "table" or type(session.weave.timeline) ~= "table" then
    return rows
  end
  local bySkill = {}
  for _, item in ipairs(session.weave.timeline) do
    if item and (item.kind == "skill" or item.kind == "postchannel") then
      local abilityId = tonumber(item.abilityId) or 0
      local displayName = item.skillName or item.label or "?"
      local key = abilityId > 0 and ("id:" .. tostring(abilityId)) or string.lower(displayName)
      if not bySkill[key] then
        bySkill[key] = { name = displayName, abilityId = abilityId, good = 0, late = 0, missed = 0, fast = 0, total = 0 }
      end
      local r = string.lower(tostring(item.result or ""))
      if r == "good" then bySkill[key].good = bySkill[key].good + 1
      elseif r == "late" then bySkill[key].late = bySkill[key].late + 1
      elseif r == "missed" then bySkill[key].missed = bySkill[key].missed + 1
      elseif r == "too fast" then bySkill[key].fast = bySkill[key].fast + 1 end
      bySkill[key].total = bySkill[key].total + 1
    end
  end
  local arr = {}
  for _, v in pairs(bySkill) do table.insert(arr, v) end
  table.sort(arr, function(a, b) return a.total > b.total end)
  for i = 1, math.min(maxRows, #arr) do
    local s = arr[i]
    local goodPct = s.total > 0 and (s.good / s.total) or 0
    rows[i] = {
      name = s.name or "?",
      sub = string.format("good %s · G %d · L %d · M %d · F %d · n=%d",
        fmtPct(goodPct), s.good, s.late, s.missed, s.fast, s.total),
      icon = getAbilityIcon(s.abilityId),
      bar = getSkillBar(session, s.abilityId),
      share = goodPct,
      goodTxt = fmtPct(goodPct),
      gTxt = tostring(s.good),
      lTxt = tostring(s.late),
      mTxt = tostring(s.missed),
      fTxt = tostring(s.fast),
      nTxt = tostring(s.total),
    }
  end
  return rows
end

local function buildDotUptimeModel(session, maxRows)
  maxRows = tonumber(maxRows) or 6
  local rows = {}
  if not session or type(session.dotTicks) ~= "table" then return rows end
  local dur = tonumber(session.durationMs) or 0
  if dur <= 0 then return rows end
  local arr = {}
  for id, entry in pairs(session.dotTicks) do
    local ticks = entry and entry.ticks
    if type(ticks) == "table" and #ticks >= 2 then
      local intervals = {}
      for i = 2, #ticks do table.insert(intervals, ticks[i] - ticks[i - 1]) end
      table.sort(intervals)
      local medianInterval = intervals[math.ceil(#intervals / 2)] or 2000
      local maxGap = math.max(medianInterval * 2.5, 4000)
      local coveredMs = 0
      for i = 2, #ticks do
        local gap = ticks[i] - ticks[i - 1]
        if gap <= maxGap then coveredMs = coveredMs + gap end
      end
      coveredMs = coveredMs + medianInterval
      local uptimePct = math.min(1.0, coveredMs / dur)
      table.insert(arr, {
        id = tonumber(id) or tonumber(entry.id) or 0,
        name = entry.name or "?",
        uptime = uptimePct,
        ticks = #ticks,
      })
    end
  end
  table.sort(arr, function(a, b) return a.uptime < b.uptime end)
  for i = 1, math.min(maxRows, #arr) do
    local d = arr[i]
    rows[i] = {
      name = d.name or "?",
      sub = string.format("%s uptime · %d ticks", fmtPct(d.uptime), d.ticks or 0),
      icon = getAbilityIcon(d.id),
      bar = getSkillBar(session, d.id),
      share = d.uptime,
    }
  end
  return rows
end

local function denseSparkBuckets(session)
  local arr = {}
  if not session or type(session.buckets) ~= "table" then return arr end
  for idx, b in pairs(session.buckets) do
    if type(b) == "table" then
      table.insert(arr, { idx = tonumber(idx) or 0, dmg = tonumber(b.dmg) or 0 })
    end
  end
  table.sort(arr, function(a, b) return a.idx < b.idx end)
  return arr
end

local function collectLiveBarSlots(barLabel)
  local slots = {}
  if type(GetSlotBoundId) ~= "function" then return slots end
  local cat = nil
  if barLabel == "Front" and type(HOTBAR_CATEGORY_PRIMARY) ~= "nil" then
    cat = HOTBAR_CATEGORY_PRIMARY
  elseif barLabel == "Back" and type(HOTBAR_CATEGORY_BACKUP) ~= "nil" then
    cat = HOTBAR_CATEGORY_BACKUP
  end
  for slot = 3, 8 do
    local abilityId = 0
    if cat ~= nil then
      local ok, id = pcall(GetSlotBoundId, slot, cat)
      abilityId = ok and (tonumber(id) or 0) or 0
    else
      local mapped = (barLabel == "Back") and (slot + 17) or slot
      local ok, id = pcall(GetSlotBoundId, mapped)
      abilityId = ok and (tonumber(id) or 0) or 0
    end
    slots[#slots + 1] = {
      slot = slot,
      id = abilityId,
      name = abilityId > 0 and getAbilityName(abilityId) or "",
      icon = resolveSlotIcon(abilityId),
      filled = abilityId > 0,
    }
  end
  return slots
end

local function collectBarSlots(session, barLabel)
  local slots = {}
  local hasSnapshot = session and type(session.slottedAbilityBySlot) == "table"
  for slot = 3, 8 do
    local abilityId, name = 0, ""
    if hasSnapshot then
      local entry = session.slottedAbilityBySlot[barLabel .. ":" .. slot]
      if type(entry) == "table" then
        abilityId = tonumber(entry.id) or 0
        name = entry.name or ""
      end
    end
    slots[#slots + 1] = {
      slot = slot,
      id = abilityId,
      name = (name ~= "" and name) or (abilityId > 0 and getAbilityName(abilityId) or ""),
      icon = resolveSlotIcon(abilityId),
      filled = abilityId > 0,
    }
  end
  local any = false
  for _, s in ipairs(slots) do
    if (s.id or 0) > 0 then any = true break end
  end
  if not any then return collectLiveBarSlots(barLabel) end
  return slots
end

local function buildDashboardModel(session)
  if not session then return nil end
  local totalDamage = tonumber(session.totalDamage) or 0
  local directPct = totalDamage > 0 and ((tonumber(session.directDamage) or 0) / totalDamage) or 0
  local dotPct = totalDamage > 0 and ((tonumber(session.dotDamage) or 0) / totalDamage) or 0
  local weave = type(session.weave) == "table" and session.weave or {}
  local target = truncateText(session.lastTargetName or "Unknown", 32)
  if session.isDummy then target = target .. " *" end
  local gearSets = {}
  if type(session.equippedSets) == "table" then
    for i, name in ipairs(session.equippedSets) do gearSets[i] = name end
  end
  return {
    target = target,
    meta = string.format("%s  |  %s", formatSessionTimestampShort(session), fmtDur(session.durationMs)),
    isDummy = session.isDummy == true,
    avgDps = fmtDps(sessionAvgDps(session)),
    peakDps = fmtDps(sessionPeakDps(session)),
    totalDamage = fmtInt(totalDamage),
    critPct = fmtPct(sessionCritPct(session)),
    directDot = string.format("%s direct  |  %s DoT", fmtPct(directPct), fmtPct(dotPct)),
    weavePct = fmtPct(getWeaveSuccessRatio(session)),
    laHits = tostring(sessionLaHits(session)),
    weaveDetail = string.format(
      "Missed %d  |  Late %d  |  Fast %d",
      tonumber(weave.missedCount) or 0,
      tonumber(weave.lateCount) or 0,
      tonumber(weave.tooFastCount) or 0
    ),
    events = fmtInt(session.eventCount or session.hitCount),
    topSkills = buildTopSkillRows(session, 5),
    frontBar = collectBarSlots(session, "Front"),
    backBar = collectBarSlots(session, "Back"),
    gearSets = gearSets,
    sparkBuckets = denseSparkBuckets(session),
  }
end

-- Menu-side weave summary (mirrors overlay weaveSummary; no SV coupling).
local function weaveSummaryLocal(session)
  local w = (session and type(session.weave) == "table") and session.weave or {}
  local intervals = {}
  if type(w.laIntervals) == "table" then
    for _, d in ipairs(w.laIntervals) do
      if d and d > 0 then intervals[#intervals + 1] = d end
    end
  end
  local n = #intervals
  local laCount = tonumber(w.laCount) or 0
  local durMs = tonumber(session and session.durationMs) or 0
  local laPerSec = (durMs > 0) and (laCount / (durMs / 1000)) or 0
  local late = tonumber(w.lateCount) or 0
  local missed = tonumber(w.missedCount) or 0
  local onTime = tonumber(w.onTimeCount) or 0
  local tooFast = tonumber(w.tooFastCount) or 0
  local fastSkill = tonumber(w.fastSkillPresses) or tooFast
  if n == 0 then
    return {
      laHits = laCount, laPerSec = laPerSec, avgGap = 0, bestGap = 0, worstGap = 0,
      late = late, missed = missed, onTime = onTime, fastSkillPresses = fastSkill, samples = 0,
    }
  end
  table.sort(intervals)
  local sum, best, worst = 0, nil, 0
  for _, d in ipairs(intervals) do
    sum = sum + d
    if (not best) and d >= 250 then best = d end
    if d > worst then worst = d end
  end
  if not best then best = intervals[1] end
  return {
    laHits = laCount, laPerSec = laPerSec, avgGap = sum / n, bestGap = best or 0, worstGap = worst or 0,
    late = late, missed = missed, onTime = onTime, fastSkillPresses = fastSkill, samples = n,
  }
end

-- Simple burst/drop windows from buckets (menu-local; ignore windows approx).
local function analyzeBucketsLocal(session)
  local peaks, dips, candidates = {}, {}, {}
  if not session or type(session.buckets) ~= "table" then return peaks, dips end
  for idx, b in pairs(session.buckets) do
    if type(b) == "table" then
      candidates[#candidates + 1] = {
        idx = tonumber(idx) or 0,
        dmg = tonumber(b.dmg) or 0,
        skills = b.skills,
      }
    end
  end
  table.sort(candidates, function(a, b) return a.dmg > b.dmg end)
  for i = 1, math.min(3, #candidates) do peaks[i] = candidates[i] end
  table.sort(candidates, function(a, b) return a.dmg < b.dmg end)
  local found = 0
  for i = 1, #candidates do
    if candidates[i].dmg > 0 then
      found = found + 1
      dips[found] = candidates[i]
      if found >= 3 then break end
    end
  end
  return peaks, dips
end

local function bucketTopSkillName(session, bucket, bms)
  if not bucket or type(bucket.skills) ~= "table" then return "-" end
  local bestId, bestDmg = nil, -1
  for id, dmg in pairs(bucket.skills) do
    local v = tonumber(dmg) or 0
    if v > bestDmg then bestDmg = v bestId = id end
  end
  if not bestId then return "-" end
  local abilityId = tonumber(bestId) or 0
  local name = nil
  if session and type(session.skills) == "table" then
    local sk = session.skills[abilityId] or session.skills[bestId]
    if type(sk) == "table" then name = sk.name end
  end
  if not name or name == "" then name = getAbilityName(abilityId) end
  local dps = (bms > 0) and (bestDmg / (bms / 1000)) or 0
  return string.format("%s (%s)", truncateText(name, 14), fmtDps(dps))
end

-- Full Summary model for dense Overview (parity target with overlay Summary page).
local function buildSummaryModel(session)
  if not session then return nil end
  local dur = tonumber(session.durationMs) or 0
  local total = tonumber(session.totalDamage) or 0
  local direct = tonumber(session.directDamage) or 0
  local dot = tonumber(session.dotDamage) or 0
  local hits = tonumber(session.hitCount) or 0
  local crits = tonumber(session.critCount) or 0
  local directPct = total > 0 and (direct / total) or 0
  local dotPct = total > 0 and (dot / total) or 0
  local critPct = hits > 0 and (crits / hits) or 0
  local setDamage = 0
  if type(session.sets) == "table" then
    for _, ps in pairs(session.sets) do
      if type(ps) == "table" then setDamage = setDamage + (tonumber(ps.dmg) or 0) end
    end
  end
  local setPct = total > 0 and (setDamage / total) or 0
  local peaks, dips = analyzeBucketsLocal(session)
  local bms = bucketMs()
  local peakDps = 0
  if peaks[1] then peakDps = (tonumber(peaks[1].dmg) or 0) / (bms / 1000) end
  if peakDps <= 0 then peakDps = sessionPeakDps(session) end
  local ws = weaveSummaryLocal(session)
  local weaveSuccess = getWeaveSuccessRatio(session)
  local epm = (dur > 0) and ((hits / (dur / 1000)) * 60) or 0
  local totalHeal = tonumber(session.totalHealing) or 0
  local effectiveHeal = tonumber(session.effectiveHealing) or totalHeal
  local overHeal = math.max(0, totalHeal - effectiveHeal)
  local healPerSec = (dur > 0) and (effectiveHeal / (dur / 1000)) or 0
  local overHealPct = (totalHeal > 0) and (overHeal / totalHeal) or 0
  local sets = {}
  if type(session.sets) == "table" then
    local arr = {}
    for _, ps in pairs(session.sets) do
      if type(ps) == "table" then arr[#arr + 1] = ps end
    end
    table.sort(arr, function(a, b) return (tonumber(a.dmg) or 0) > (tonumber(b.dmg) or 0) end)
    for i = 1, math.min(3, #arr) do
      local ps = arr[i]
      local dmg = tonumber(ps.dmg) or 0
      local phits = tonumber(ps.hits) or 0
      local share = total > 0 and (dmg / total) or 0
      local dps = dur > 0 and (dmg / (dur / 1000)) or 0
      local crit = phits > 0 and ((tonumber(ps.crit) or 0) / phits) or 0
      local dotp = dmg > 0 and ((tonumber(ps.dot) or 0) / dmg) or 0
      local kind = (dotp > 0.95) and "DoT" or (dotp < 0.05) and "Direct" or "Mixed"
      sets[i] = {
        name = ps.name or "?",
        line = string.format("%s   %s   %s share   crit %s   %s DPS",
          truncateText(ps.name or "?", 28), fmtInt(dmg), fmtPct(share), fmtPct(crit), fmtDps(dps)),
        share = share,
      }
    end
  end
  local topSkills = {}
  if type(session.skills) == "table" then
    local arr = {}
    for id, sk in pairs(session.skills) do
      if type(sk) == "table" then
        arr[#arr + 1] = {
          id = tonumber(sk.id) or tonumber(id) or 0,
          name = sk.name,
          dmg = tonumber(sk.dmg) or 0,
          hits = tonumber(sk.hits) or 0,
          crit = tonumber(sk.crit) or 0,
          max = tonumber(sk.max) or 0,
        }
      end
    end
    table.sort(arr, function(a, b) return a.dmg > b.dmg end)
    for i = 1, math.min(5, #arr) do
      local s = arr[i]
      local dmg = s.dmg
      local shits = s.hits
      local share = total > 0 and (dmg / total) or 0
      local dps = dur > 0 and (dmg / (dur / 1000)) or 0
      local crit = shits > 0 and ((s.crit or 0) / shits) or 0
      local name = s.name
      if not name or name == "" then name = getAbilityName(s.id) end
      topSkills[i] = {
        name = name,
        icon = getAbilityIcon(s.id),
        bar = getSkillBar(session, s.id),
        share = share,
        sub = string.format("%s DPS · %s share · crit %s · max %s",
          fmtDps(dps), fmtPct(share), fmtPct(crit), fmtInt(s.max)),
      }
    end
  end
  local function bucketLine(title, b)
    if not b then return title .. "  —" end
    local dps = (tonumber(b.dmg) or 0) / (bms / 1000)
    local t0 = (tonumber(b.idx) or 0) * bms
    local t1 = t0 + bms
    -- Compact for side-by-side Burst|Drop columns.
    return string.format("%s  %.0f-%.0fs  %s\n%s",
      title, t0 / 1000, t1 / 1000, fmtDps(dps), bucketTopSkillName(session, b, bms))
  end
  local equipped = ""
  if type(session.equippedSets) == "table" and #session.equippedSets > 0 then
    equipped = table.concat(session.equippedSets, ", ")
  else
    equipped = "(sets unknown)"
  end
  return {
    target = truncateText(session.lastTargetName or "Unknown", 40) .. (session.isDummy and " *" or ""),
    meta = string.format("%s  ·  %s  ·  dummy %s  ·  %s",
      formatSessionTimestampShort(session), fmtDur(dur),
      session.isDummy and "Yes" or "No", truncateText(equipped, 48)),
    kpis = {
      { key = "avg", label = "Fight Avg DPS", value = fmtDps(sessionAvgDps(session)) },
      { key = "peak", label = "Peak 2s DPS", value = fmtDps(peakDps) },
      { key = "total", label = "Fight Total", value = fmtInt(total) },
      { key = "dur", label = "Fight Duration", value = fmtDur(dur) },
      { key = "crit", label = "Crit Rate", value = fmtPct(critPct) },
      { key = "maxhit", label = "Max Hit", value = fmtInt(session.maxHit) },
      { key = "split", label = "Direct vs DoT", value = string.format("%s / %s", fmtPct(directPct), fmtPct(dotPct)) },
      { key = "events", label = "Damage Events", value = fmtInt(hits) },
      { key = "epm", label = "Dmg Events / Min", value = string.format("%.0f", epm) },
      { key = "weave", label = "Weave Success", value = (ws.samples > 0 or (ws.onTime + ws.late + ws.missed) > 0) and fmtPct(weaveSuccess) or "-" },
      { key = "avglag", label = "Avg LA Gap", value = (ws.samples > 0) and string.format("%.0f ms", ws.avgGap or 0) or "-" },
      { key = "setpct", label = "Set Proc Share", value = fmtPct(setPct) },
      { key = "heal", label = "Total Healing", value = fmtInt(totalHeal) },
      { key = "hps", label = "Effective HPS", value = fmtDps(healPerSec) },
      { key = "overheal", label = "Overheal %", value = fmtPct(overHealPct) },
    },
    rot = {
      { string.format("LA Hits: %d", ws.laHits or 0), string.format("LA/s: %.2f", ws.laPerSec or 0) },
      {
        (ws.samples > 0) and string.format("Avg LA Gap: %.0f ms", ws.avgGap or 0) or "Avg LA Gap: -",
        string.format("Weave Timing: %s", fmtPct(weaveSuccess)),
      },
      {
        (ws.samples > 0) and string.format("Best Gap: %.0f ms", ws.bestGap or 0) or "Best Gap: -",
        (ws.samples > 0) and string.format("Worst Gap: %.0f ms", ws.worstGap or 0) or "Worst Gap: -",
      },
      {
        string.format("Missed: %d | Late: %d", ws.missed or 0, ws.late or 0),
        string.format("Fast Presses: %d", ws.fastSkillPresses or 0),
      },
    },
    spikes = {
      bucketLine("Burst 1", peaks[1]),
      bucketLine("Burst 2", peaks[2]),
      bucketLine("Burst 3", peaks[3]),
    },
    dips = {
      bucketLine("Drop 1", dips[1]),
      bucketLine("Drop 2", dips[2]),
      bucketLine("Drop 3", dips[3]),
    },
    spark = denseSparkBuckets(session),
    sets = sets,
    topSkills = topSkills,
  }
end

local function buildGearLines(session)
  local lines = {}
  if session and type(session.equippedSets) == "table" and #session.equippedSets > 0 then
    for i, name in ipairs(session.equippedSets) do
      lines[#lines + 1] = string.format("Set %d:  %s", i, tostring(name))
    end
  end
  -- Live worn: full common slots (still pcall-safe). Shown as two-col text in gear UI.
  if type(GetItemLink) == "function" and type(BAG_WORN) ~= "nil" then
    local slotDefs = {
      { "Head", "EQUIP_SLOT_HEAD" }, { "Shoulders", "EQUIP_SLOT_SHOULDERS" },
      { "Chest", "EQUIP_SLOT_CHEST" }, { "Hands", "EQUIP_SLOT_HAND" },
      { "Waist", "EQUIP_SLOT_WAIST" }, { "Legs", "EQUIP_SLOT_LEGS" },
      { "Feet", "EQUIP_SLOT_FEET" }, { "Neck", "EQUIP_SLOT_NECK" },
      { "Ring 1", "EQUIP_SLOT_RING1" }, { "Ring 2", "EQUIP_SLOT_RING2" },
      { "Front MH", "EQUIP_SLOT_MAIN_HAND" }, { "Front OH", "EQUIP_SLOT_OFF_HAND" },
      { "Back MH", "EQUIP_SLOT_BACKUP_MAIN" }, { "Back OH", "EQUIP_SLOT_BACKUP_OFF" },
    }
    local worn = {}
    for _, def in ipairs(slotDefs) do
      local slotId = _G[def[2]]
      if type(slotId) == "number" then
        local ok, link = pcall(GetItemLink, BAG_WORN, slotId)
        local name = "(empty)"
        if ok and link and link ~= "" and type(GetItemLinkName) == "function" then
          local okName, n = pcall(GetItemLinkName, link)
          if okName and n and n ~= "" then
            name = (type(zo_strformat) == "function") and zo_strformat("<<1>>", n) or n
          end
        end
        worn[#worn + 1] = string.format("%s:  %s", def[1], truncateText(name, 40))
      end
    end
    if #worn > 0 then
      lines[#lines + 1] = "— Live worn (current loadout) —"
      for i = 1, #worn do lines[#lines + 1] = worn[i] end
    end
  end
  return lines
end

local function stripColorLocal(text)
  text = tostring(text or "")
  text = text:gsub("|c%x%x%x%x%x%x", "")
  text = text:gsub("|r", "")
  return text
end

-- Colorized timeline tokens (matches overlay legend): green good, gold late, red miss, blue fast.
local function timelineTokenColored(item)
  if not item then return "|cAAAAAA?|r" end
  local kind = item.kind or ""
  if kind == "la" or kind == "light" then
    return "|cAADDFFLA|r"
  end
  local r = string.lower(tostring(item.result or ""))
  local mark, col = "·", "CCCCCC"
  if r == "good" then mark, col = "+", "66FF66"
  elseif r == "late" then mark, col = "~", "FFCC66"
  elseif r == "missed" then mark, col = "x", "FF6666"
  elseif r == "too fast" then mark, col = ">", "66AAFF"
  elseif r == "extra" then mark, col = "*", "CC88FF" end
  local raw = item.skillName or item.label or "?"
  local name = truncateText(raw, 14)
  -- Bar tint on name when known (Front soft green, Back soft blue).
  local bar = item.bar or ""
  local nameCol = "EEEEEE"
  if bar == "Front" then nameCol = "88DDAA"
  elseif bar == "Back" then nameCol = "88AADD" end
  return string.format("|c%s%s|r|c%s%s|r", col, mark, nameCol, name)
end

local function buildTimelineLines(session, maxLines, visibleCharLimit)
  maxLines = tonumber(maxLines) or ROT_TIMELINE_LINES
  visibleCharLimit = tonumber(visibleCharLimit) or 90
  if not session or type(session.weave) ~= "table" or type(session.weave.timeline) ~= "table"
      or #session.weave.timeline == 0 then
    return { "|cAAAAAANo rotation timeline yet — complete a parse with weave tracking.|r" }
  end
  local tokens = {}
  for _, item in ipairs(session.weave.timeline) do
    if item then tokens[#tokens + 1] = timelineTokenColored(item) end
  end
  local lines, cur, curVis = {}, "", 0
  for _, tok in ipairs(tokens) do
    local vis = #stripColorLocal(tok)
    if cur == "" then
      cur, curVis = tok, vis
    elseif curVis + 2 + vis > visibleCharLimit then
      lines[#lines + 1] = cur
      cur, curVis = tok, vis
      if #lines >= maxLines then break end
    else
      cur = cur .. "  " .. tok
      curVis = curVis + 2 + vis
    end
  end
  if cur ~= "" and #lines < maxLines then lines[#lines + 1] = cur end
  if #lines == 0 then lines[1] = "|cAAAAAATimeline empty.|r" end
  return lines
end

local function buildPulseRatios(session, maxBlocks)
  maxBlocks = tonumber(maxBlocks) or PULSE_BLOCKS
  local ratios = {}
  if not session or type(session.weave) ~= "table" or type(session.weave.timeline) ~= "table" then
    return ratios
  end
  local tl = session.weave.timeline
  local n = #tl
  if n <= 0 then return ratios end
  local step = math.max(1, math.ceil(n / maxBlocks))
  for i = 1, n, step do
    local item = tl[i]
    local r = string.lower(tostring(item and item.result or ""))
    local score = 0.35
    if r == "good" then score = 1.0
    elseif r == "late" then score = 0.65
    elseif r == "too fast" then score = 0.45
    elseif r == "missed" then score = 0.15 end
    ratios[#ratios + 1] = score
    if #ratios >= maxBlocks then break end
  end
  return ratios
end

local function collectDummyTrendParses(maxCols)
  maxCols = tonumber(maxCols) or TREND_MAX_COLS
  local arr = {}
  local count = historyCount()
  for offset = 0, count - 1 do
    local s = historyAt(offset)
    if s and s.isDummy then
      local dur = tonumber(s.durationMs) or 0
      local hits = tonumber(s.hitCount) or 0
      table.insert(arr, {
        offset = offset,
        dps = dur > 0 and ((tonumber(s.totalDamage) or 0) / (dur / 1000)) or 0,
        crit = hits > 0 and ((tonumber(s.critCount) or 0) / hits) or 0,
        weave = getWeaveSuccessRatio(s),
        session = s,
      })
      if #arr >= maxCols then break end
    end
  end
  return arr
end

-- Structured history cards for decorated list UI.
local function buildHistoryCards(activeOffset, maxCards)
  maxCards = tonumber(maxCards) or TREND_HIST_LINES
  activeOffset = tonumber(activeOffset) or 0
  local cards = {}
  local count = historyCount()
  if count <= 0 then return cards end
  local startOffset = math.max(0, activeOffset - 2)
  local endOffset = math.min(count - 1, startOffset + maxCards - 1)
  for offset = startOffset, endOffset do
    local s = historyAt(offset)
    if s then
      local fightNo = count - offset
      local target = truncateText(s.lastTargetName or "?", 26)
      cards[#cards + 1] = {
        offset = offset,
        selected = (offset == activeOffset),
        fightNo = fightNo,
        target = target,
        isDummy = s.isDummy == true,
        dps = fmtDps(sessionAvgDps(s)),
        crit = fmtPct(sessionCritPct(s)),
        weave = fmtPct(getWeaveSuccessRatio(s)),
        dur = fmtDur(s.durationMs),
        when = formatSessionTimestampShort(s),
        tag = s.isDummy and "DUMMY" or "WORLD",
      }
    end
  end
  return cards
end

-- Comparison as row-major table model: headers[1..n], rows[{label, cells[1..n]}]
local function buildComparisonTable(maxCols)
  maxCols = tonumber(maxCols) or COMP_COLS
  local dummies = {}
  local count = historyCount()
  for offset = 0, count - 1 do
    local s = historyAt(offset)
    if s and s.isDummy then
      dummies[#dummies + 1] = s
      if #dummies >= maxCols then break end
    end
  end
  local headers = {}
  for i, s in ipairs(dummies) do
    headers[i] = string.format("#%d %s", i, truncateText(s.lastTargetName or "dummy", 12))
  end
  if #dummies == 0 then
    return headers, { { label = "No dummy parses yet", cells = {} } }
  end
  local metrics = {
    { "Avg DPS", function(s) return fmtDps(sessionAvgDps(s)) end },
    { "Crit %", function(s) return fmtPct(sessionCritPct(s)) end },
    { "Weave %", function(s) return fmtPct(getWeaveSuccessRatio(s)) end },
    { "Duration", function(s) return fmtDur(s.durationMs) end },
    { "Total Dmg", function(s) return fmtInt(s.totalDamage) end },
    { "LA Hits", function(s) return tostring(sessionLaHits(s)) end },
    { "Max Hit", function(s) return fmtInt(s.maxHit) end },
  }
  local rows = {}
  for _, m in ipairs(metrics) do
    local cells = {}
    for i, s in ipairs(dummies) do cells[i] = m[2](s) end
    rows[#rows + 1] = { label = m[1], cells = cells }
  end
  return headers, rows
end

local function resolveSession()
  local count = historyCount()
  historyOffset = clampHistoryOffset(historyOffset, count)
  local session = count > 0 and historyAt(historyOffset) or nil
  if type(session) ~= "table" then
    headerNote = "No fights in history — parse a dummy, then reopen"
    return nil, 0
  end
  local target = truncateText(session.lastTargetName or "fight", 16)
  local tag = session.isDummy and "dummy" or "world"
  local fightNo = count - historyOffset
  if fightNo < 1 then fightNo = 1 end
  local when = (historyOffset == 0) and "latest" or string.format("#%d/%d", fightNo, count)
  headerNote = string.format("%s %s (%s) · L2/R2 history", when, target, tag)
  return session, count
end

local function sectionLabelForTab(tabIndex)
  tabIndex = tonumber(tabIndex) or TAB.OVERVIEW
  for _, entry in ipairs(NAV_ENTRIES) do
    if entry.tab == tabIndex then return entry.label end
  end
  return "Overview"
end

---------------------------------------------------------------------
-- Draw / layout helpers
---------------------------------------------------------------------
local function stampBackground(ctrl, level)
  if not ctrl then return end
  level = tonumber(level) or 0
  if type(ctrl.SetDrawLayer) == "function" then
    if type(DL_BACKGROUND) ~= "nil" then ctrl:SetDrawLayer(DL_BACKGROUND)
    elseif type(DL_CONTROLS) ~= "nil" then ctrl:SetDrawLayer(DL_CONTROLS) end
  end
  if type(ctrl.SetDrawTier) == "function" then
    if type(DT_LOW) ~= "nil" then ctrl:SetDrawTier(DT_LOW)
    elseif type(DT_MEDIUM) ~= "nil" then ctrl:SetDrawTier(DT_MEDIUM) end
  end
  if type(ctrl.SetDrawLevel) == "function" then ctrl:SetDrawLevel(level) end
end

local function stampForeground(ctrl, level)
  if not ctrl then return end
  level = tonumber(level) or 100
  if type(ctrl.SetDrawLayer) == "function" then
    if type(DL_TEXT) ~= "nil" then ctrl:SetDrawLayer(DL_TEXT)
    elseif type(DL_CONTROLS) ~= "nil" then ctrl:SetDrawLayer(DL_CONTROLS) end
  end
  if type(ctrl.SetDrawTier) == "function" then
    if type(DT_HIGH) ~= "nil" then ctrl:SetDrawTier(DT_HIGH)
    elseif type(DT_MEDIUM) ~= "nil" then ctrl:SetDrawTier(DT_MEDIUM) end
  end
  if type(ctrl.SetDrawLevel) == "function" then ctrl:SetDrawLevel(level) end
end

local function makeDashLabel(parent, name, size, r, g, b, a)
  local lbl = WM:CreateControl(name, parent, CT_LABEL)
  if type(lbl.SetFont) == "function" then lbl:SetFont(dashFont(size)) end
  lbl:SetColor(r or THEME.textR, g or THEME.textG, b or THEME.textB, a or 1)
  lbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
  lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  stampForeground(lbl, 120)
  return lbl
end

local function makeSectionFrame(parent, name, solid)
  local bg = WM:CreateControl(name, parent, CT_BACKDROP)
  if solid == false then
    bg:SetCenterColor(THEME.cardR, THEME.cardG, THEME.cardB, THEME.cardA * 0.55)
    bg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, THEME.cardEdgeA * 0.7)
  else
    bg:SetCenterColor(THEME.cardR, THEME.cardG, THEME.cardB, THEME.cardA)
    bg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, THEME.cardEdgeA)
  end
  bg:SetInsets(2, 2, -2, -2)
  stampBackground(bg, 2)
  return bg
end

local function forceControlRect(ctrl, parent, left, top, width, height)
  if not ctrl then return end
  if type(ctrl.ClearAnchors) == "function" then ctrl:ClearAnchors() end
  if type(ctrl.SetAnchor) == "function" and parent then
    ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, left, top)
  end
  if type(ctrl.SetDimensions) == "function" then
    ctrl:SetDimensions(width, height)
  else
    if type(ctrl.SetWidth) == "function" then ctrl:SetWidth(width) end
    if type(ctrl.SetHeight) == "function" then ctrl:SetHeight(height) end
  end
  if type(ctrl.SetHidden) == "function" then ctrl:SetHidden(false) end
end

local function sparkColorForRatio(ratio)
  if ratio > 0.72 then return 0.45, 0.88, 0.48, 0.94 end
  if ratio > 0.42 then return 0.92, 0.72, 0.32, 0.92 end
  return 0.88, 0.38, 0.30, 0.90
end

local function layoutSparkBars(bars, wrap, values, wrapW, maxH, maxBars)
  maxH = maxH or SPARK_BAR_MAX_H
  maxBars = maxBars or SPARK_MAX_BARS
  bars = bars or {}
  values = values or {}
  wrapW = tonumber(wrapW) or 200
  local count = math.min(#values, maxBars, #bars)
  local maxVal = 1
  for i = 1, count do
    local v = tonumber(values[i]) or 0
    if v > maxVal then maxVal = v end
  end
  local barW = math.max(5, math.floor((wrapW - 4) / math.max(count, 1)) - 2)
  for i, bar in ipairs(bars) do
    if not bar then
      -- skip
    elseif i <= count then
      local v = tonumber(values[i]) or 0
      local ratio = (maxVal > 0) and (v / maxVal) or 0
      local h = math.max(3, math.floor(ratio * maxH))
      bar:ClearAnchors()
      bar:SetDimensions(barW, h)
      if wrap then bar:SetAnchor(BOTTOMLEFT, wrap, BOTTOMLEFT, (i - 1) * (barW + 2), 0) end
      local r, g, b, a = sparkColorForRatio(ratio)
      bar:SetCenterColor(r, g, b, a)
      bar:SetHidden(false)
    else
      bar:SetHidden(true)
    end
  end
end

local function createSparkBarPool(parent, namePrefix, count)
  local wrap = WM:CreateControl(namePrefix .. "Wrap", parent, CT_CONTROL)
  stampForeground(wrap, 90)
  local bars = {}
  for i = 1, count do
    local bar = WM:CreateControl(namePrefix .. i, wrap, CT_BACKDROP)
    bar:SetCenterColor(0.3, 0.7, 1.0, 0.9)
    bar:SetEdgeColor(0, 0, 0, 0)
    bar:SetHidden(true)
    stampForeground(bar, 95)
    bars[i] = bar
  end
  return wrap, bars
end

local function resolveShellRects()
  local rootW = GuiRoot and GuiRoot:GetWidth() or 1920
  local rootH = GuiRoot and GuiRoot:GetHeight() or 1080
  local top = CONTENT_HEADER_INSET
  local usableH = math.max(320, rootH - top - CONTENT_FOOTER_INSET)
  local navW = floorNum(rootW * NAV_RAIL_FRAC)
  if type(ZO_GAMEPAD_CONTENT_LEFT_OFFSET) == "number" and ZO_GAMEPAD_CONTENT_LEFT_OFFSET > 120
      and ZO_GAMEPAD_CONTENT_LEFT_OFFSET < (rootW * 0.38) then
    navW = ZO_GAMEPAD_CONTENT_LEFT_OFFSET
  end
  navW = clampNum(navW, NAV_RAIL_MIN, NAV_RAIL_MAX)
  local navLeft = SHELL_SIDE_PAD
  local contentLeft = navLeft + navW + NAV_CONTENT_GAP
  local contentW = math.max(420, rootW - contentLeft - SHELL_SIDE_PAD)
  return {
    rootW = rootW, rootH = rootH,
    navLeft = navLeft, navTop = top, navW = navW, navH = usableH,
    contentLeft = contentLeft, contentTop = top, contentW = contentW, contentH = usableH,
  }
end

local function getNavListControl(screen)
  local list = screen and screen.navList
  if not list then return nil end
  return list.control or list.list or list
end

---------------------------------------------------------------------
-- Generic icon+meta list (shared by Damage / Buffs / Procs / Weave)
---------------------------------------------------------------------
local function createIconRowList(parent, namePrefix, maxRows, iconSize)
  maxRows = tonumber(maxRows) or LIST_MAX_ROWS
  iconSize = tonumber(iconSize) or LIST_ICON
  local ui = { rows = {}, maxRows = maxRows, iconSize = iconSize }
  ui.title = makeDashLabel(parent, namePrefix .. "Title", 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, parent, TOPLEFT, CONTENT_PAD, 8)
  ui.meta = makeDashLabel(parent, namePrefix .. "Meta", 14, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 4)
  ui.legend = makeDashLabel(parent, namePrefix .. "Legend", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.legend:SetAnchor(TOPLEFT, ui.meta, BOTTOMLEFT, 0, 2)
  ui.legend:SetText("|c88DDAAF|r Front bar   |c88AADDB|r Back bar")
  local y0 = 58
  for i = 1, maxRows do
    local row = WM:CreateControl(namePrefix .. "Row" .. i, parent, CT_CONTROL)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, CONTENT_PAD, y0 + ((i - 1) * LIST_ROW_H))
    row:SetDimensions(400, LIST_ROW_H - 4)
    local chip = makeDashLabel(row, namePrefix .. "Chip" .. i, 14, THEME.frontR, THEME.frontG, THEME.frontB, 1)
    chip:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 10)
    chip:SetDimensions(16, 18)
    local icon = WM:CreateControl(namePrefix .. "Icon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(TOPLEFT, row, TOPLEFT, 20, 4)
    stampForeground(icon, 110)
    local shareBg = WM:CreateControl(namePrefix .. "ShareBg" .. i, row, CT_BACKDROP)
    shareBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    shareBg:SetEdgeColor(0, 0, 0, 0)
    shareBg:SetAnchor(TOPLEFT, row, TOPLEFT, 20 + iconSize + 8, 36)
    shareBg:SetDimensions(200, 6)
    stampBackground(shareBg, 5)
    local shareFg = WM:CreateControl(namePrefix .. "ShareFg" .. i, shareBg, CT_BACKDROP)
    shareFg:SetCenterColor(0.55, 0.78, 0.42, 0.9)
    shareFg:SetEdgeColor(0, 0, 0, 0)
    shareFg:SetAnchor(TOPLEFT, shareBg, TOPLEFT, 0, 0)
    shareFg:SetDimensions(2, 6)
    stampForeground(shareFg, 100)
    local nameLbl = makeDashLabel(row, namePrefix .. "Name" .. i, 16, THEME.textR, THEME.textG, THEME.textB, 1)
    nameLbl:SetAnchor(TOPLEFT, row, TOPLEFT, 20 + iconSize + 8, 2)
    local subLbl = makeDashLabel(row, namePrefix .. "Sub" .. i, 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    subLbl:SetAnchor(TOPLEFT, nameLbl, BOTTOMLEFT, 0, 1)
    ui.rows[i] = {
      row = row, chip = chip, icon = icon, name = nameLbl, sub = subLbl,
      shareBg = shareBg, shareFg = shareFg,
    }
  end
  ui.empty = makeDashLabel(parent, namePrefix .. "Empty", 16, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, parent, TOPLEFT, CONTENT_PAD, y0)
  ui.empty:SetHidden(true)
  return ui
end

local function layoutIconRowList(ui, hostW, hostH)
  if not ui then return end
  local pad = CONTENT_PAD
  local W = math.max(400, (hostW or 800) - pad * 2)
  local H = math.max(300, (hostH or 600) - 12)
  if ui.title then ui.title:SetWidth(W) end
  if ui.meta then ui.meta:SetWidth(W) end
  if ui.legend then ui.legend:SetWidth(W) end
  if ui.empty then ui.empty:SetWidth(W) end

  -- Pack: icon+name | sub metrics | share bar (no giant empty middle).
  local iconSize = ui.iconSize or LIST_ICON
  local leftX = 20 + iconSize + 8
  local nameW = math.min(300, math.max(170, math.floor(W * 0.32)))
  local barW = math.min(240, math.max(140, math.floor(W * 0.24)))
  local subW = math.max(140, W - leftX - nameW - barW - 28)
  local y0 = 56
  local maxRows = ui.maxRows or LIST_MAX_ROWS
  local avail = H - y0 - 8
  local rowH = math.floor(avail / maxRows)
  if rowH < 34 then rowH = 34 end
  if rowH > 44 then rowH = 44 end

  for i, r in ipairs(ui.rows or {}) do
    if r.row then
      local parent = r.row:GetParent()
      r.row:ClearAnchors()
      if parent then
        r.row:SetAnchor(TOPLEFT, parent, TOPLEFT, pad, y0 + (i - 1) * rowH)
      end
      r.row:SetDimensions(W, rowH - 2)
    end
    if r.name then
      r.name:ClearAnchors()
      r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, leftX, 2)
      r.name:SetWidth(nameW)
      r.name:SetMaxLineCount(1)
    end
    if r.sub then
      r.sub:ClearAnchors()
      r.sub:SetAnchor(TOPLEFT, r.row, TOPLEFT, leftX + nameW + 8, 4)
      r.sub:SetWidth(subW)
      r.sub:SetMaxLineCount(2)
    end
    if r.shareBg then
      r.shareBg:ClearAnchors()
      r.shareBg:SetAnchor(TOPRIGHT, r.row, TOPRIGHT, -6, math.floor((rowH - 10) / 2))
      r.shareBg:SetDimensions(barW, 10)
    end
  end
end

local function refreshIconRowList(ui, items, emptyText)
  if not ui then return end
  items = items or {}
  if #items == 0 then
    if ui.empty then
      ui.empty:SetText(emptyText or "No data for this fight.")
      ui.empty:SetHidden(false)
    end
    for _, r in ipairs(ui.rows or {}) do
      if r.row then r.row:SetHidden(true) end
    end
    return
  end
  if ui.empty then ui.empty:SetHidden(true) end
  for i, r in ipairs(ui.rows or {}) do
    local item = items[i]
    if item and r.row then
      r.row:SetHidden(false)
      if r.name then r.name:SetText(item.name or "?") end
      if r.sub then r.sub:SetText(item.sub or "") end
      if r.icon then
        if item.icon then
          r.icon:SetTexture(item.icon)
          r.icon:SetHidden(false)
          r.icon:SetColor(1, 1, 1, 1)
        else
          r.icon:SetHidden(true)
        end
      end
      if r.chip then
        local chip = barChipLabel(item.bar)
        r.chip:SetText(chip)
        local cr, cg, cb, ca = barChipColor(item.bar)
        r.chip:SetColor(cr, cg, cb, ca)
        r.chip:SetHidden(chip == "")
      end
      if r.shareBg and r.shareFg then
        local share = tonumber(item.share) or 0
        if share < 0 then share = 0 end
        if share > 1 then share = 1 end
        local bgW = r.shareBg:GetWidth() or 200
        if bgW < 10 then bgW = 200 end
        local fgW = math.max(2, math.floor(bgW * share))
        r.shareFg:SetDimensions(fgW, 6)
        r.shareBg:SetHidden(false)
        r.shareFg:SetHidden(false)
      end
    elseif r.row then
      r.row:SetHidden(true)
    end
  end
end

---------------------------------------------------------------------
-- Content host + panels
---------------------------------------------------------------------
local function ensureNavRailPlate(screen)
  if screen.navRailPlate then return screen.navRailPlate end
  local parent = screen.container or screen.control
  if not parent then return nil end
  local plate = WM:CreateControl("DM2StatsMenuNavRailPlate", parent, CT_BACKDROP)
  plate:SetCenterColor(THEME.railR, THEME.railG, THEME.railB, THEME.railA)
  plate:SetEdgeColor(THEME.railEdgeR, THEME.railEdgeG, THEME.railEdgeB, THEME.railEdgeA)
  plate:SetInsets(2, 2, -2, -2)
  stampBackground(plate, 1)
  screen.navRailPlate = plate
  return plate
end

local function ensureContentHost(screen)
  if screen.contentHost and screen.contentPanels then
    return screen.contentHost, screen.contentPanels
  end
  local parent = screen.container or screen.control
  local host = screen.contentHost
  if not host then
    host = WM:CreateControl("DM2StatsMenuContentHost", parent, CT_CONTROL)
    host:SetHidden(false)
    stampForeground(host, 10)
    screen.contentHost = host
  end

  if not screen.contentPlate then
    local plate = WM:CreateControl("DM2StatsMenuContentPlate", host, CT_BACKDROP)
    plate:SetCenterColor(THEME.plateR, THEME.plateG, THEME.plateB, THEME.plateA)
    plate:SetEdgeColor(THEME.plateEdgeR, THEME.plateEdgeG, THEME.plateEdgeB, THEME.plateEdgeA)
    plate:SetInsets(2, 2, -2, -2)
    local inset = CONTENT_PLATE_INSET
    plate:SetAnchor(TOPLEFT, host, TOPLEFT, inset, inset)
    plate:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, -inset, -inset)
    stampBackground(plate, 0)
    screen.contentPlate = plate
  end

  if not screen.contentPanels then
    local panels = {
      overview  = WM:CreateControl("DM2StatsMenuOverviewPanel", host, CT_CONTROL),
      dashboard = WM:CreateControl("DM2StatsMenuDashboardPanel", host, CT_CONTROL),
      damage    = WM:CreateControl("DM2StatsMenuDamagePanel", host, CT_CONTROL),
      weave     = WM:CreateControl("DM2StatsMenuWeavePanel", host, CT_CONTROL),
      buffs     = WM:CreateControl("DM2StatsMenuBuffsPanel", host, CT_CONTROL),
      gear      = WM:CreateControl("DM2StatsMenuGearPanel", host, CT_CONTROL),
      procs     = WM:CreateControl("DM2StatsMenuProcsPanel", host, CT_CONTROL),
      rotation  = WM:CreateControl("DM2StatsMenuRotationPanel", host, CT_CONTROL),
      history   = WM:CreateControl("DM2StatsMenuHistoryPanel", host, CT_CONTROL),
    }
    for _, panel in pairs(panels) do
      panel:SetHidden(true)
      stampForeground(panel, 50)
    end
    screen.contentPanels = panels
  end

  return host, screen.contentPanels
end

local function layoutNavList(screen)
  local rect = resolveShellRects()
  local parent = screen.container or screen.control
  if not parent then return rect end
  local rail = ensureNavRailPlate(screen)
  if rail then
    forceControlRect(rail, parent, rect.navLeft, rect.navTop, rect.navW, rect.navH)
    stampBackground(rail, 1)
  end
  local listCtrl = getNavListControl(screen)
  if listCtrl then
    forceControlRect(listCtrl, parent, rect.navLeft, rect.navTop, rect.navW, rect.navH)
    stampForeground(listCtrl, 80)
  end
  local listObj = screen.navList
  if listObj and listObj.list and listObj.list ~= listCtrl then
    pcall(function()
      listObj.list:SetWidth(rect.navW)
      if type(listObj.list.SetHeight) == "function" then listObj.list:SetHeight(rect.navH) end
    end)
  end
  return rect
end

local function layoutContentHost(screen)
  local host = screen.contentHost
  if not host then
    local rect = resolveShellRects()
    return rect.contentW, rect.contentH
  end
  local rect = resolveShellRects()
  local parent = screen.container or screen.control
  forceControlRect(host, parent, rect.contentLeft, rect.contentTop, rect.contentW, rect.contentH)
  stampForeground(host, 10)
  if screen.contentPlate then
    local inset = CONTENT_PLATE_INSET
    screen.contentPlate:ClearAnchors()
    screen.contentPlate:SetAnchor(TOPLEFT, host, TOPLEFT, inset, inset)
    screen.contentPlate:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, -inset, -inset)
    screen.contentPlate:SetHidden(false)
    stampBackground(screen.contentPlate, 0)
    screen.contentPlate:SetCenterColor(THEME.plateR, THEME.plateG, THEME.plateB, THEME.plateA)
    screen.contentPlate:SetEdgeColor(THEME.plateEdgeR, THEME.plateEdgeG, THEME.plateEdgeB, THEME.plateEdgeA)
  end
  local panels = screen.contentPanels or {}
  for _, panel in pairs(panels) do
    if panel then
      panel:ClearAnchors()
      panel:SetAnchor(TOPLEFT, host, TOPLEFT, 0, 0)
      panel:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, 0, 0)
      stampForeground(panel, 50)
    end
  end
  return rect.contentW, rect.contentH
end

local function applyDualPaneLayout(screen)
  if not screen then return end
  ensureContentHost(screen)
  layoutNavList(screen)
  layoutContentHost(screen)
end

local function showContentTab(screen, tabIndex)
  applyDualPaneLayout(screen)
  local panels = screen.contentPanels or {}
  local active = TAB_KEY[tabIndex] or "overview"
  for key, panel in pairs(panels) do
    if panel then panel:SetHidden(key ~= active) end
  end
  return active
end

---------------------------------------------------------------------
-- Overview = overlay Summary page (dense; lazy-created once)
-- Structure: header → KPI grid → rotation + burst/drop → sparkline →
--            set contribution → top damage skills
---------------------------------------------------------------------
local OV_KPI_COLS = 5
local OV_KPI_KEYS = {
  { key = "avg", label = "Fight Avg DPS" },
  { key = "peak", label = "Peak 2s DPS" },
  { key = "total", label = "Fight Total" },
  { key = "dur", label = "Fight Duration" },
  { key = "crit", label = "Crit Rate" },
  { key = "maxhit", label = "Max Hit" },
  { key = "split", label = "Direct vs DoT" },
  { key = "events", label = "Damage Events" },
  { key = "epm", label = "Dmg Events / Min" },
  { key = "weave", label = "Weave Success" },
  { key = "avglag", label = "Avg LA Gap" },
  { key = "setpct", label = "Set Proc Share" },
  { key = "heal", label = "Total Healing" },
  { key = "hps", label = "Effective HPS" },
  { key = "overheal", label = "Overheal %" },
}
local OV_SPARK_BARS = 20
local OV_TOP_SKILLS = 5
local OV_SET_ROWS = 3

local function createOverviewUI(screen)
  if screen.overviewUI then return screen.overviewUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.overview
  if not panel then return nil end

  local ui = {
    panel = panel,
    kpi = {},
    rotLines = {},
    spikes = {},
    dips = {},
    setRows = {},
    skillRows = {},
    sparkBars = {},
  }

  -- Root fills the content plate; sections stack top→bottom.
  ui.root = WM:CreateControl("DM2StatsMenuOvRoot", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, 6)
  stampForeground(ui.root, 55)

  ui.fightLine = makeDashLabel(ui.root, "DM2StatsMenuOvFight", 20, 0.95, 0.92, 0.86, 1)
  ui.fightLine:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)

  ui.metaLine = makeDashLabel(ui.root, "DM2StatsMenuOvMeta", 14, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.metaLine:SetAnchor(TOPLEFT, ui.fightLine, BOTTOMLEFT, 0, 2)

  -- KPI panel
  ui.kpiPanel = WM:CreateControl("DM2StatsMenuOvKpiPanel", ui.root, CT_CONTROL)
  ui.kpiPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 48)
  local kpiBg = makeSectionFrame(ui.kpiPanel, "DM2StatsMenuOvKpiBG", true)
  kpiBg:SetAnchorFill(ui.kpiPanel)
  for i, def in ipairs(OV_KPI_KEYS) do
    local block = WM:CreateControl("DM2StatsMenuOvKpi_" .. def.key, ui.kpiPanel, CT_CONTROL)
    local bg = makeSectionFrame(block, "DM2StatsMenuOvKpiBG_" .. def.key, false)
    bg:SetAnchorFill(block)
    local value = makeDashLabel(block, "DM2StatsMenuOvKpiVal_" .. def.key, 16, THEME.textR, THEME.textG, THEME.textB, 1)
    value:SetAnchor(TOPLEFT, block, TOPLEFT, 8, 4)
    local label = makeDashLabel(block, "DM2StatsMenuOvKpiLab_" .. def.key, 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    label:SetAnchor(TOPLEFT, value, BOTTOMLEFT, 0, 0)
    label:SetText(def.label)
    ui.kpi[def.key] = { block = block, value = value, label = label, bg = bg }
  end

  -- Mid: Rotation Health | Burst / Drop
  ui.rotPanel = WM:CreateControl("DM2StatsMenuOvRotPanel", ui.root, CT_CONTROL)
  local rotBg = makeSectionFrame(ui.rotPanel, "DM2StatsMenuOvRotBG", true)
  rotBg:SetAnchorFill(ui.rotPanel)
  ui.rotTitle = makeDashLabel(ui.rotPanel, "DM2StatsMenuOvRotTitle", 14, 0.58, 0.86, 1.0, 1)
  ui.rotTitle:SetAnchor(TOPLEFT, ui.rotPanel, TOPLEFT, 10, 6)
  ui.rotTitle:SetText("Rotation Health")
  ui.rotHelp = makeDashLabel(ui.rotPanel, "DM2StatsMenuOvRotHelp", 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.rotHelp:SetAnchor(TOPLEFT, ui.rotTitle, BOTTOMLEFT, 0, 1)
  ui.rotHelp:SetText("Light attack timing, misses, and rhythm health")
  for i = 1, 4 do
    local l1 = makeDashLabel(ui.rotPanel, "DM2StatsMenuOvRotL" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    local l2 = makeDashLabel(ui.rotPanel, "DM2StatsMenuOvRotR" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    ui.rotLines[i] = { l1, l2 }
  end

  ui.burstPanel = WM:CreateControl("DM2StatsMenuOvBurstPanel", ui.root, CT_CONTROL)
  local burstBg = makeSectionFrame(ui.burstPanel, "DM2StatsMenuOvBurstBG", true)
  burstBg:SetAnchorFill(ui.burstPanel)
  ui.burstTitle = makeDashLabel(ui.burstPanel, "DM2StatsMenuOvBurstTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.burstTitle:SetAnchor(TOPLEFT, ui.burstPanel, TOPLEFT, 10, 6)
  ui.burstTitle:SetText("Burst / Drop Windows")
  ui.spikeHead = makeDashLabel(ui.burstPanel, "DM2StatsMenuOvSpikeHead", 12, 0.72, 0.95, 1.0, 1)
  ui.spikeHead:SetText("Bursts")
  ui.dipHead = makeDashLabel(ui.burstPanel, "DM2StatsMenuOvDipHead", 12, 1.0, 0.72, 0.55, 1)
  ui.dipHead:SetText("Drops")
  for i = 1, 3 do
    ui.spikes[i] = makeDashLabel(ui.burstPanel, "DM2StatsMenuOvSpike" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    ui.dips[i] = makeDashLabel(ui.burstPanel, "DM2StatsMenuOvDip" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
  end

  -- Sparkline
  ui.sparkPanel = WM:CreateControl("DM2StatsMenuOvSparkPanel", ui.root, CT_CONTROL)
  local sparkBg = makeSectionFrame(ui.sparkPanel, "DM2StatsMenuOvSparkBG", true)
  sparkBg:SetAnchorFill(ui.sparkPanel)
  ui.sparkTitle = makeDashLabel(ui.sparkPanel, "DM2StatsMenuOvSparkTitle", 13, 0.72, 0.95, 1.0, 1)
  ui.sparkTitle:SetAnchor(TOPLEFT, ui.sparkPanel, TOPLEFT, 10, 4)
  ui.sparkTitle:SetText("DPS Over Time")
  ui.sparkWrap = WM:CreateControl("DM2StatsMenuOvSparkWrap", ui.sparkPanel, CT_CONTROL)
  ui.sparkWrap:SetAnchor(TOPLEFT, ui.sparkPanel, TOPLEFT, 10, 22)
  for i = 1, OV_SPARK_BARS do
    local bar = WM:CreateControl("DM2StatsMenuOvSparkBar" .. i, ui.sparkWrap, CT_BACKDROP)
    bar:SetCenterColor(0.3, 0.7, 1.0, 0.9)
    bar:SetEdgeColor(0, 0, 0, 0)
    bar:SetHidden(true)
    stampForeground(bar, 95)
    ui.sparkBars[i] = bar
  end

  -- Set contribution
  ui.setPanel = WM:CreateControl("DM2StatsMenuOvSetPanel", ui.root, CT_CONTROL)
  local setBg = makeSectionFrame(ui.setPanel, "DM2StatsMenuOvSetBG", true)
  setBg:SetAnchorFill(ui.setPanel)
  ui.setTitle = makeDashLabel(ui.setPanel, "DM2StatsMenuOvSetTitle", 14, 1.0, 0.90, 0.50, 1)
  ui.setTitle:SetAnchor(TOPLEFT, ui.setPanel, TOPLEFT, 10, 6)
  ui.setTitle:SetText("Set Contribution")
  for i = 1, OV_SET_ROWS do
    local row = WM:CreateControl("DM2StatsMenuOvSetRow" .. i, ui.setPanel, CT_CONTROL)
    local shareBg = WM:CreateControl("DM2StatsMenuOvSetShareBg" .. i, row, CT_BACKDROP)
    shareBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    shareBg:SetEdgeColor(0, 0, 0, 0)
    shareBg:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
    shareBg:SetDimensions(200, 5)
    local shareFg = WM:CreateControl("DM2StatsMenuOvSetShareFg" .. i, shareBg, CT_BACKDROP)
    shareFg:SetCenterColor(0.92, 0.78, 0.40, 0.9)
    shareFg:SetEdgeColor(0, 0, 0, 0)
    shareFg:SetAnchor(TOPLEFT, shareBg, TOPLEFT, 0, 0)
    shareFg:SetDimensions(2, 5)
    local line = makeDashLabel(row, "DM2StatsMenuOvSetLine" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    line:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    ui.setRows[i] = { row = row, line = line, shareBg = shareBg, shareFg = shareFg }
  end

  -- Top damage skills
  ui.skillsPanel = WM:CreateControl("DM2StatsMenuOvSkillsPanel", ui.root, CT_CONTROL)
  local skBg = makeSectionFrame(ui.skillsPanel, "DM2StatsMenuOvSkillsBG", true)
  skBg:SetAnchorFill(ui.skillsPanel)
  ui.skillsTitle = makeDashLabel(ui.skillsPanel, "DM2StatsMenuOvSkillsTitle", 14, 0.86, 0.94, 1.0, 1)
  ui.skillsTitle:SetAnchor(TOPLEFT, ui.skillsPanel, TOPLEFT, 10, 6)
  ui.skillsTitle:SetText("Top Damage Skills")
  ui.skillsLegend = makeDashLabel(ui.skillsPanel, "DM2StatsMenuOvSkillsLegend", 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.skillsLegend:SetAnchor(TOPLEFT, ui.skillsTitle, BOTTOMLEFT, 0, 1)
  ui.skillsLegend:SetText("|c88DDAAF|r Front bar   |c88AADDB|r Back bar   ·  share bar under name")
  for i = 1, OV_TOP_SKILLS do
    local row = WM:CreateControl("DM2StatsMenuOvSkillRow" .. i, ui.skillsPanel, CT_CONTROL)
    local chip = makeDashLabel(row, "DM2StatsMenuOvSkillChip" .. i, 12, THEME.frontR, THEME.frontG, THEME.frontB, 1)
    chip:SetAnchor(LEFT, row, LEFT, 0, 0)
    chip:SetDimensions(14, 16)
    local icon = WM:CreateControl("DM2StatsMenuOvSkillIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(26, 26)
    icon:SetAnchor(LEFT, row, LEFT, 16, 0)
    stampForeground(icon, 110)
    local name = makeDashLabel(row, "DM2StatsMenuOvSkillName" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    name:SetAnchor(TOPLEFT, row, TOPLEFT, 48, 0)
    local sub = makeDashLabel(row, "DM2StatsMenuOvSkillSub" .. i, 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    sub:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, 0)
    local shareBg = WM:CreateControl("DM2StatsMenuOvSkillShareBg" .. i, row, CT_BACKDROP)
    shareBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    shareBg:SetEdgeColor(0, 0, 0, 0)
    shareBg:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 48, 0)
    shareBg:SetDimensions(220, 5)
    local shareFg = WM:CreateControl("DM2StatsMenuOvSkillShareFg" .. i, shareBg, CT_BACKDROP)
    shareFg:SetCenterColor(0.55, 0.78, 0.42, 0.9)
    shareFg:SetEdgeColor(0, 0, 0, 0)
    shareFg:SetAnchor(TOPLEFT, shareBg, TOPLEFT, 0, 0)
    shareFg:SetDimensions(2, 5)
    ui.skillRows[i] = {
      row = row, chip = chip, icon = icon, name = name, sub = sub,
      shareBg = shareBg, shareFg = shareFg,
    }
  end

  ui.empty = makeDashLabel(ui.root, "DM2StatsMenuOvEmpty", 16, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 48)
  ui.empty:SetHidden(true)

  screen.overviewUI = ui
  return ui
end

local function layoutOverviewUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  -- Content plate already includes pad; don't double-subtract so tiles get full width.
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(420, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.fightLine:SetWidth(W - 4)
  ui.metaLine:SetWidth(W - 4)
  ui.empty:SetWidth(W - 4)

  -- Fixed section heights that fit ~1080p plate without overlapping.
  local headerH = 44
  local kpiH = 148
  local midH = 150
  local sparkH = 58
  local setH = 78
  local used = headerH + kpiH + 6 + midH + 6 + sparkH + 6 + setH + 6
  local skillsH = math.max(140, H - used - 4)
  if skillsH > 200 then skillsH = 200 end

  ui.kpiPanel:ClearAnchors()
  ui.kpiPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, headerH)
  ui.kpiPanel:SetDimensions(W, kpiH)

  local gapX, gapY = 6, 6
  local cols = OV_KPI_COLS
  local pad = 8
  local kpiInnerW = W - pad * 2
  local kpiW = math.floor((kpiInnerW - gapX * (cols - 1)) / cols)
  local rows = 3
  local kpiBlockH = math.floor((kpiH - pad * 2 - gapY * (rows - 1)) / rows)
  if kpiBlockH < 38 then kpiBlockH = 38 end
  if kpiBlockH > 44 then kpiBlockH = 44 end
  for i, def in ipairs(OV_KPI_KEYS) do
    local cell = ui.kpi[def.key]
    local block = cell and cell.block
    if block then
      local col = (i - 1) % cols
      local row = math.floor((i - 1) / cols)
      block:ClearAnchors()
      block:SetDimensions(kpiW, kpiBlockH)
      block:SetAnchor(TOPLEFT, ui.kpiPanel, TOPLEFT, pad + col * (kpiW + gapX), pad + row * (kpiBlockH + gapY))
      if cell.value then
        cell.value:ClearAnchors()
        cell.value:SetAnchor(TOPLEFT, block, TOPLEFT, 8, 4)
        cell.value:SetWidth(kpiW - 14)
        cell.value:SetMaxLineCount(1)
      end
      if cell.label then
        cell.label:ClearAnchors()
        cell.label:SetAnchor(BOTTOMLEFT, block, BOTTOMLEFT, 8, -4)
        cell.label:SetWidth(kpiW - 14)
        cell.label:SetMaxLineCount(1)
      end
    end
  end

  local midY = headerH + kpiH + 6
  local leftW = math.floor(W * 0.34)
  if leftW < 240 then leftW = 240 end
  if leftW > 320 then leftW = 320 end
  local rightW = W - leftW - 8

  ui.rotPanel:ClearAnchors()
  ui.rotPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, midY)
  ui.rotPanel:SetDimensions(leftW, midH)
  ui.rotTitle:SetWidth(leftW - 20)
  ui.rotHelp:SetWidth(leftW - 20)
  -- Single column of rotation lines (avoids cramped dual-col wrap).
  for i = 1, 4 do
    local pair = ui.rotLines[i]
    if pair then
      pair[1]:ClearAnchors()
      pair[1]:SetAnchor(TOPLEFT, ui.rotPanel, TOPLEFT, 10, 42 + (i - 1) * 24)
      pair[1]:SetWidth(leftW - 20)
      pair[1]:SetMaxLineCount(1)
      pair[2]:ClearAnchors()
      pair[2]:SetAnchor(TOPRIGHT, ui.rotPanel, TOPRIGHT, -10, 42 + (i - 1) * 24)
      pair[2]:SetWidth(math.floor((leftW - 24) / 2))
      pair[2]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
      pair[2]:SetMaxLineCount(1)
    end
  end

  ui.burstPanel:ClearAnchors()
  ui.burstPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, leftW + 8, midY)
  ui.burstPanel:SetDimensions(rightW, midH)
  ui.burstTitle:SetWidth(rightW - 20)
  -- Side-by-side Bursts | Drops (matches overlay intent; no vertical collision).
  local colW = math.floor((rightW - 28) / 2)
  ui.spikeHead:ClearAnchors()
  ui.spikeHead:SetAnchor(TOPLEFT, ui.burstPanel, TOPLEFT, 10, 28)
  ui.spikeHead:SetWidth(colW)
  ui.dipHead:ClearAnchors()
  ui.dipHead:SetAnchor(TOPLEFT, ui.burstPanel, TOPLEFT, 14 + colW, 28)
  ui.dipHead:SetWidth(colW)
  for i = 1, 3 do
    ui.spikes[i]:ClearAnchors()
    ui.spikes[i]:SetAnchor(TOPLEFT, ui.burstPanel, TOPLEFT, 10, 48 + (i - 1) * 28)
    ui.spikes[i]:SetWidth(colW)
    ui.spikes[i]:SetMaxLineCount(2)
    ui.dips[i]:ClearAnchors()
    ui.dips[i]:SetAnchor(TOPLEFT, ui.burstPanel, TOPLEFT, 14 + colW, 48 + (i - 1) * 28)
    ui.dips[i]:SetWidth(colW)
    ui.dips[i]:SetMaxLineCount(2)
  end

  local sparkY = midY + midH + 6
  ui.sparkPanel:ClearAnchors()
  ui.sparkPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, sparkY)
  ui.sparkPanel:SetDimensions(W, sparkH)
  ui.sparkTitle:SetWidth(W - 20)
  ui.sparkWrap:ClearAnchors()
  ui.sparkWrap:SetAnchor(TOPLEFT, ui.sparkPanel, TOPLEFT, 10, 22)
  ui.sparkWrap:SetDimensions(W - 20, sparkH - 28)

  local setY = sparkY + sparkH + 6
  ui.setPanel:ClearAnchors()
  ui.setPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, setY)
  ui.setPanel:SetDimensions(W, setH)
  ui.setTitle:SetWidth(W - 20)
  local setLineW = math.min(560, math.max(280, math.floor((W - 40) * 0.70)))
  local setBarW = math.min(160, math.max(80, W - 40 - setLineW - 20))
  for i = 1, OV_SET_ROWS do
    local r = ui.setRows[i]
    if r and r.row then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.setPanel, TOPLEFT, 10, 26 + (i - 1) * 16)
      r.row:SetDimensions(W - 20, 15)
      if r.line then
        r.line:ClearAnchors()
        r.line:SetAnchor(TOPLEFT, r.row, TOPLEFT, 0, 0)
        r.line:SetWidth(setLineW)
        r.line:SetMaxLineCount(1)
      end
      if r.shareBg then
        r.shareBg:ClearAnchors()
        r.shareBg:SetAnchor(TOPLEFT, r.row, TOPLEFT, setLineW + 12, 5)
        r.shareBg:SetDimensions(setBarW, 5)
      end
    end
  end

  local skillsY = setY + setH + 6
  ui.skillsPanel:ClearAnchors()
  ui.skillsPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, skillsY)
  ui.skillsPanel:SetDimensions(W, skillsH)
  ui.skillsTitle:SetWidth(W - 20)
  ui.skillsLegend:SetWidth(W - 20)
  local rowH = math.floor((skillsH - 38) / OV_TOP_SKILLS)
  if rowH < 30 then rowH = 30 end
  if rowH > 34 then rowH = 34 end
  local skNameW = math.min(280, math.max(180, math.floor((W - 40) * 0.32)))
  local skSubW = math.min(420, math.max(200, math.floor((W - 40) * 0.40)))
  local skBarW = math.min(180, math.max(100, math.floor((W - 40) * 0.18)))
  for i = 1, OV_TOP_SKILLS do
    local r = ui.skillRows[i]
    if r and r.row then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.skillsPanel, TOPLEFT, 10, 34 + (i - 1) * rowH)
      r.row:SetDimensions(W - 20, rowH - 2)
      if r.name then
        r.name:ClearAnchors()
        r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, 48, 0)
        r.name:SetWidth(skNameW)
        r.name:SetMaxLineCount(1)
      end
      if r.sub then
        r.sub:ClearAnchors()
        r.sub:SetAnchor(TOPLEFT, r.row, TOPLEFT, 48 + skNameW + 8, 2)
        r.sub:SetWidth(skSubW)
        r.sub:SetMaxLineCount(1)
      end
      if r.shareBg then
        r.shareBg:ClearAnchors()
        r.shareBg:SetAnchor(TOPLEFT, r.row, TOPLEFT, 48 + skNameW + skSubW + 16, math.floor((rowH - 8) / 2))
        r.shareBg:SetDimensions(skBarW, 6)
      end
    end
  end
end

local function setOverviewBodyHidden(ui, hidden)
  if not ui then return end
  if ui.kpiPanel then ui.kpiPanel:SetHidden(hidden) end
  if ui.rotPanel then ui.rotPanel:SetHidden(hidden) end
  if ui.burstPanel then ui.burstPanel:SetHidden(hidden) end
  if ui.sparkPanel then ui.sparkPanel:SetHidden(hidden) end
  if ui.setPanel then ui.setPanel:SetHidden(hidden) end
  if ui.skillsPanel then ui.skillsPanel:SetHidden(hidden) end
end

local function refreshOverviewUI(screen, session)
  local ui = createOverviewUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutOverviewUI(ui, hostW, hostH)

  if not session then
    ui.fightLine:SetText("No fight selected")
    ui.metaLine:SetText("Complete a parse, then open this menu again")
    ui.empty:SetText("History is empty — run a parse, then reopen.")
    ui.empty:SetHidden(false)
    setOverviewBodyHidden(ui, true)
    return
  end

  ui.empty:SetHidden(true)
  setOverviewBodyHidden(ui, false)

  local model = buildSummaryModel(session)
  if not model then return end

  ui.fightLine:SetText(model.target or "?")
  ui.metaLine:SetText(model.meta or "")

  for _, def in ipairs(OV_KPI_KEYS) do
    local cell = ui.kpi[def.key]
    local data = nil
    for _, k in ipairs(model.kpis or {}) do
      if k.key == def.key then data = k break end
    end
    if cell and cell.value then
      cell.value:SetText(data and data.value or "-")
    end
  end

  for i = 1, 4 do
    local pair = ui.rotLines[i]
    local rot = model.rot and model.rot[i]
    if pair then
      pair[1]:SetText(rot and rot[1] or "")
      pair[2]:SetText(rot and rot[2] or "")
    end
  end

  for i = 1, 3 do
    if ui.spikes[i] then ui.spikes[i]:SetText((model.spikes and model.spikes[i]) or "") end
    if ui.dips[i] then ui.dips[i]:SetText((model.dips and model.dips[i]) or "") end
  end

  local sparkVals = {}
  for _, b in ipairs(model.spark or {}) do
    sparkVals[#sparkVals + 1] = tonumber(b.dmg) or 0
  end
  local sparkW = ui.sparkWrap and ui.sparkWrap:GetWidth() or 400
  if sparkW < 50 then sparkW = math.max(200, (hostW or 600) - 40) end
  layoutSparkBars(ui.sparkBars, ui.sparkWrap, sparkVals, sparkW, 28, OV_SPARK_BARS)

  for i = 1, OV_SET_ROWS do
    local r = ui.setRows[i]
    local s = model.sets and model.sets[i]
    if r then
      if s then
        r.row:SetHidden(false)
        r.line:SetText(s.line or "")
        local share = tonumber(s.share) or 0
        local bgW = r.shareBg:GetWidth() or 200
        if bgW < 10 then bgW = 200 end
        r.shareFg:SetDimensions(math.max(2, math.floor(bgW * math.min(1, share))), 4)
      else
        r.row:SetHidden(i ~= 1)
        if i == 1 then
          r.row:SetHidden(false)
          r.line:SetText("No set/proc contribution recorded.")
          r.shareFg:SetDimensions(2, 4)
        end
      end
    end
  end

  for i = 1, OV_TOP_SKILLS do
    local r = ui.skillRows[i]
    local sk = model.topSkills and model.topSkills[i]
    if r then
      if sk then
        r.row:SetHidden(false)
        r.name:SetText(sk.name or "?")
        r.sub:SetText(sk.sub or "")
        local chip = barChipLabel(sk.bar)
        r.chip:SetText(chip)
        local cr, cg, cb, ca = barChipColor(sk.bar)
        r.chip:SetColor(cr, cg, cb, ca)
        r.chip:SetHidden(chip == "")
        if sk.icon then
          r.icon:SetTexture(sk.icon)
          r.icon:SetHidden(false)
          r.icon:SetColor(1, 1, 1, 1)
        else
          r.icon:SetHidden(true)
        end
        local share = tonumber(sk.share) or 0
        local bgW = r.shareBg:GetWidth() or 220
        if bgW < 10 then bgW = 220 end
        r.shareFg:SetDimensions(math.max(2, math.floor(bgW * math.min(1, share))), 4)
      else
        r.row:SetHidden(true)
      end
    end
  end
end

---------------------------------------------------------------------
-- Damage = overlay Skill Breakdown (dense table; lazy)
---------------------------------------------------------------------
local DMG_MAX_ROWS = 16
local DMG_ROW_H = 34

local function createDamageUI(screen)
  if screen.damageUI then return screen.damageUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.damage
  if not panel then return nil end

  local ui = { panel = panel, rows = {}, headers = {} }

  ui.root = WM:CreateControl("DM2StatsMenuDmgRoot", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)

  ui.title = makeDashLabel(ui.root, "DM2StatsMenuDmgTitle", 16, 0.90, 0.96, 1.0, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("DAMAGE BREAKDOWN")

  ui.meta = makeDashLabel(ui.root, "DM2StatsMenuDmgMeta", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)

  ui.legend = makeDashLabel(ui.root, "DM2StatsMenuDmgLegend", 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.legend:SetAnchor(TOPLEFT, ui.meta, BOTTOMLEFT, 0, 2)
  ui.legend:SetText("|c88DDAAF|r Front bar   |c88AADDB|r Back bar   ·  share bar under skill name")

  ui.table = WM:CreateControl("DM2StatsMenuDmgTable", ui.root, CT_CONTROL)
  ui.table:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 58)
  local tableBg = makeSectionFrame(ui.table, "DM2StatsMenuDmgTableBG", true)
  tableBg:SetAnchorFill(ui.table)

  -- Header labels (metric columns)
  local hdrY = 8
  ui.hdrSkill = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrSkill", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrSkill:SetAnchor(TOPLEFT, ui.table, TOPLEFT, 48, hdrY)
  ui.hdrSkill:SetText("Skill")
  ui.hdrAmount = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrAmt", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrAmount:SetText("Amount")
  ui.hdrAmount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrHits = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrHits", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrHits:SetText("Hits")
  ui.hdrHits:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrAvg = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrAvg", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrAvg:SetText("Avg")
  ui.hdrAvg:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrShare = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrShare", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrShare:SetText("Share")
  ui.hdrShare:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrCrit = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrCrit", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrCrit:SetText("Crit")
  ui.hdrCrit:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrType = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrType", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrType:SetText("Type")
  ui.hdrType:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrDps = makeDashLabel(ui.table, "DM2StatsMenuDmgHdrDps", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrDps:SetText("DPS")
  ui.hdrDps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

  for i = 1, DMG_MAX_ROWS do
    local row = WM:CreateControl("DM2StatsMenuDmgRow" .. i, ui.table, CT_CONTROL)
    local chip = makeDashLabel(row, "DM2StatsMenuDmgChip" .. i, 12, THEME.frontR, THEME.frontG, THEME.frontB, 1)
    chip:SetDimensions(14, 16)
    local icon = WM:CreateControl("DM2StatsMenuDmgIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(26, 26)
    stampForeground(icon, 110)
    local name = makeDashLabel(row, "DM2StatsMenuDmgName" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    local shareBg = WM:CreateControl("DM2StatsMenuDmgShareBg" .. i, row, CT_BACKDROP)
    shareBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    shareBg:SetEdgeColor(0, 0, 0, 0)
    shareBg:SetDimensions(120, 4)
    local shareFg = WM:CreateControl("DM2StatsMenuDmgShareFg" .. i, shareBg, CT_BACKDROP)
    shareFg:SetCenterColor(0.55, 0.78, 0.42, 0.9)
    shareFg:SetEdgeColor(0, 0, 0, 0)
    shareFg:SetAnchor(TOPLEFT, shareBg, TOPLEFT, 0, 0)
    shareFg:SetDimensions(2, 4)
    local amount = makeDashLabel(row, "DM2StatsMenuDmgAmt" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    amount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local hits = makeDashLabel(row, "DM2StatsMenuDmgHits" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    hits:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local avg = makeDashLabel(row, "DM2StatsMenuDmgAvg" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    avg:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local share = makeDashLabel(row, "DM2StatsMenuDmgShare" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    share:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local crit = makeDashLabel(row, "DM2StatsMenuDmgCrit" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    crit:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local kind = makeDashLabel(row, "DM2StatsMenuDmgType" .. i, 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    kind:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local dps = makeDashLabel(row, "DM2StatsMenuDmgDps" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    dps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ui.rows[i] = {
      row = row, chip = chip, icon = icon, name = name,
      shareBg = shareBg, shareFg = shareFg,
      amount = amount, hits = hits, avg = avg, share = share, crit = crit, kind = kind, dps = dps,
    }
  end

  ui.empty = makeDashLabel(ui.root, "DM2StatsMenuDmgEmpty", 15, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 70)
  ui.empty:SetHidden(true)

  screen.damageUI = ui
  return ui
end

local function layoutDamageUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.meta:SetWidth(W)
  ui.legend:SetWidth(W)
  ui.empty:SetWidth(W)

  local tableH = H - 58
  ui.table:ClearAnchors()
  ui.table:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 52)
  ui.table:SetDimensions(W, tableH)

  -- Pack columns after a bounded skill name — fill plate, no extreme-right void.
  local pad = 10
  local iconX = 18
  local nameX = 48
  local nameW = math.min(300, math.max(200, math.floor(W * 0.28)))
  local gap = 6
  local metricStart = nameX + nameW + 10
  local metricSpan = (W - pad) - metricStart
  -- Preferred metric widths; scale to fit remaining span.
  local prefs = { 86, 46, 70, 58, 54, 56, 68 } -- amt hits avg share crit type dps
  local prefSum = 0
  for _, w in ipairs(prefs) do prefSum = prefSum + w end
  prefSum = prefSum + gap * (#prefs - 1)
  local scale = metricSpan / math.max(1, prefSum)
  if scale > 1.35 then scale = 1.35 end
  if scale < 0.75 then scale = 0.75 end
  local widths = {}
  for i, w in ipairs(prefs) do widths[i] = math.floor(w * scale) end
  local xs = {}
  local x = metricStart
  for i = 1, #widths do
    xs[i] = x
    x = x + widths[i] + gap
  end
  local xAmt, xHits, xAvg, xShare, xCrit, xType, xDps = xs[1], xs[2], xs[3], xs[4], xs[5], xs[6], xs[7]
  local amtW, hitsW, avgW, shareW, critW, typeW, dpsW =
    widths[1], widths[2], widths[3], widths[4], widths[5], widths[6], widths[7]

  local function placeHdr(lbl, hx, hw)
    if not lbl then return end
    lbl:ClearAnchors()
    lbl:SetAnchor(TOPLEFT, ui.table, TOPLEFT, hx, 8)
    lbl:SetWidth(hw)
  end
  placeHdr(ui.hdrSkill, nameX, nameW)
  placeHdr(ui.hdrAmount, xAmt, amtW)
  placeHdr(ui.hdrHits, xHits, hitsW)
  placeHdr(ui.hdrAvg, xAvg, avgW)
  placeHdr(ui.hdrShare, xShare, shareW)
  placeHdr(ui.hdrCrit, xCrit, critW)
  placeHdr(ui.hdrType, xType, typeW)
  placeHdr(ui.hdrDps, xDps, dpsW)

  local rowTop = 28
  local avail = tableH - rowTop - 6
  local rowH = math.floor(avail / DMG_MAX_ROWS)
  if rowH < 28 then rowH = 28 end
  if rowH > DMG_ROW_H then rowH = DMG_ROW_H end

  for i = 1, DMG_MAX_ROWS do
    local r = ui.rows[i]
    if r and r.row then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.table, TOPLEFT, pad, rowTop + (i - 1) * rowH)
      r.row:SetDimensions(W - pad * 2, rowH - 2)
      r.chip:ClearAnchors()
      r.chip:SetAnchor(LEFT, r.row, LEFT, 0, 0)
      r.icon:ClearAnchors()
      r.icon:SetAnchor(LEFT, r.row, LEFT, iconX - pad, 0)
      r.name:ClearAnchors()
      r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, nameX - pad, 2)
      r.name:SetWidth(nameW)
      r.name:SetMaxLineCount(1)
      r.shareBg:ClearAnchors()
      r.shareBg:SetAnchor(BOTTOMLEFT, r.row, BOTTOMLEFT, nameX - pad, -2)
      r.shareBg:SetDimensions(math.min(nameW - 4, 160), 4)
      local function placeCell(lbl, cx, cw)
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, r.row, TOPLEFT, cx - pad, 6)
        lbl:SetWidth(cw)
        lbl:SetMaxLineCount(1)
      end
      placeCell(r.amount, xAmt, amtW)
      placeCell(r.hits, xHits, hitsW)
      placeCell(r.avg, xAvg, avgW)
      placeCell(r.share, xShare, shareW)
      placeCell(r.crit, xCrit, critW)
      placeCell(r.kind, xType, typeW)
      placeCell(r.dps, xDps, dpsW)
    end
  end
end

local function refreshDamageUI(screen, session)
  local ui = createDamageUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutDamageUI(ui, hostW, hostH)

  if not session then
    ui.meta:SetText("No fight selected")
    ui.empty:SetText("History is empty.")
    ui.empty:SetHidden(false)
    ui.table:SetHidden(true)
    return
  end
  ui.empty:SetHidden(true)
  ui.table:SetHidden(false)

  local rows = buildTopSkillRows(session, DMG_MAX_ROWS)
  ui.meta:SetText(string.format(
    "%s  ·  %s DPS  ·  total %s  ·  showing %d skills",
    truncateText(session.lastTargetName or "fight", 28),
    fmtDps(sessionAvgDps(session)),
    fmtInt(session.totalDamage),
    #rows
  ))

  for i = 1, DMG_MAX_ROWS do
    local r = ui.rows[i]
    local sk = rows[i]
    if r then
      if sk then
        r.row:SetHidden(false)
        r.name:SetText(sk.name or "?")
        r.amount:SetText(sk.amountTxt or "")
        r.hits:SetText(sk.hitsTxt or "")
        r.avg:SetText(sk.avgTxt or "")
        r.share:SetText(sk.shareTxt or "")
        r.crit:SetText(sk.critTxt or "")
        r.kind:SetText(sk.kindTxt or "")
        r.dps:SetText(sk.dpsTxt or "")
        local chip = barChipLabel(sk.bar)
        r.chip:SetText(chip)
        local cr, cg, cb, ca = barChipColor(sk.bar)
        r.chip:SetColor(cr, cg, cb, ca)
        r.chip:SetHidden(chip == "")
        if sk.icon then
          r.icon:SetTexture(sk.icon)
          r.icon:SetHidden(false)
          r.icon:SetColor(1, 1, 1, 1)
        else
          r.icon:SetHidden(true)
        end
        local share = tonumber(sk.share) or 0
        local bgW = r.shareBg:GetWidth() or 120
        if bgW < 10 then bgW = 120 end
        r.shareFg:SetDimensions(math.max(2, math.floor(bgW * math.min(1, share))), 4)
      else
        r.row:SetHidden(true)
      end
    end
  end
end

---------------------------------------------------------------------
-- Buffs (dense table)
---------------------------------------------------------------------
local function createBuffsUI(screen)
  if screen.buffsUI then return screen.buffsUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.buffs
  if not panel then return nil end
  local ui = { panel = panel, rows = {} }

  ui.root = WM:CreateControl("DM2StatsMenuBuffRoot", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)
  ui.title = makeDashLabel(ui.root, "DM2StatsMenuBuffTitle", 16, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("BUFFS / UPTIME")
  ui.meta = makeDashLabel(ui.root, "DM2StatsMenuBuffMeta", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)
  ui.legend = makeDashLabel(ui.root, "DM2StatsMenuBuffLegend", 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.legend:SetAnchor(TOPLEFT, ui.meta, BOTTOMLEFT, 0, 2)
  ui.legend:SetText("|c88DDAAF|r Front   |c88AADDB|r Back   ·  Core ≥95% · Maintained ≥50% · Situational <50%")

  ui.table = WM:CreateControl("DM2StatsMenuBuffTable", ui.root, CT_CONTROL)
  ui.table:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 52)
  local tbg = makeSectionFrame(ui.table, "DM2StatsMenuBuffTableBG", true)
  tbg:SetAnchorFill(ui.table)

  ui.hdrName = makeDashLabel(ui.table, "DM2StatsMenuBuffHdrName", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrName:SetText("Buff")
  ui.hdrSrc = makeDashLabel(ui.table, "DM2StatsMenuBuffHdrSrc", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrSrc:SetText("Source")
  ui.hdrUp = makeDashLabel(ui.table, "DM2StatsMenuBuffHdrUp", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrUp:SetText("Uptime")
  ui.hdrUp:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrAct = makeDashLabel(ui.table, "DM2StatsMenuBuffHdrAct", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrAct:SetText("Active")
  ui.hdrAct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrApps = makeDashLabel(ui.table, "DM2StatsMenuBuffHdrApps", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrApps:SetText("Apps")
  ui.hdrApps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrTier = makeDashLabel(ui.table, "DM2StatsMenuBuffHdrTier", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrTier:SetText("Tier")
  ui.hdrTier:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

  for i = 1, BUFF_MAX_ROWS do
    local row = WM:CreateControl("DM2StatsMenuBuffRow" .. i, ui.table, CT_CONTROL)
    local chip = makeDashLabel(row, "DM2StatsMenuBuffChip" .. i, 12, THEME.frontR, THEME.frontG, THEME.frontB, 1)
    chip:SetDimensions(14, 16)
    local icon = WM:CreateControl("DM2StatsMenuBuffIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(26, 26)
    stampForeground(icon, 110)
    local name = makeDashLabel(row, "DM2StatsMenuBuffName" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    local barBg = WM:CreateControl("DM2StatsMenuBuffBarBg" .. i, row, CT_BACKDROP)
    barBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    barBg:SetEdgeColor(0, 0, 0, 0)
    local barFg = WM:CreateControl("DM2StatsMenuBuffBarFg" .. i, barBg, CT_BACKDROP)
    barFg:SetCenterColor(0.55, 0.78, 0.42, 0.9)
    barFg:SetEdgeColor(0, 0, 0, 0)
    barFg:SetAnchor(TOPLEFT, barBg, TOPLEFT, 0, 0)
    barFg:SetDimensions(2, 6)
    local src = makeDashLabel(row, "DM2StatsMenuBuffSrc" .. i, 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    local up = makeDashLabel(row, "DM2StatsMenuBuffUp" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    up:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local act = makeDashLabel(row, "DM2StatsMenuBuffAct" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    act:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local apps = makeDashLabel(row, "DM2StatsMenuBuffApps" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    apps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local tier = makeDashLabel(row, "DM2StatsMenuBuffTier" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    tier:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ui.rows[i] = {
      row = row, chip = chip, icon = icon, name = name, barBg = barBg, barFg = barFg,
      src = src, up = up, act = act, apps = apps, tier = tier,
    }
  end
  ui.empty = makeDashLabel(ui.root, "DM2StatsMenuBuffEmpty", 15, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 60)
  ui.empty:SetHidden(true)
  screen.buffsUI = ui
  return ui
end

local function layoutBuffsUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.meta:SetWidth(W)
  ui.legend:SetWidth(W)
  ui.empty:SetWidth(W)
  local tableH = H - 52
  ui.table:ClearAnchors()
  ui.table:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 52)
  ui.table:SetDimensions(W, tableH)

  local pad, nameX = 10, 48
  local nameW = math.min(300, math.max(180, math.floor(W * 0.30)))
  local prefs = { 80, 70, 70, 50, 90 } -- src up act apps tier
  local metricStart = nameX + nameW + 12
  local span = (W - pad) - metricStart
  local prefSum = 0
  for _, p in ipairs(prefs) do prefSum = prefSum + p end
  prefSum = prefSum + 6 * (#prefs - 1)
  local scale = span / math.max(1, prefSum)
  if scale > 1.4 then scale = 1.4 end
  if scale < 0.75 then scale = 0.75 end
  local widths, xs = {}, {}
  local x = metricStart
  for i, p in ipairs(prefs) do
    widths[i] = math.floor(p * scale)
    xs[i] = x
    x = x + widths[i] + 6
  end
  local function placeHdr(lbl, hx, hw)
    lbl:ClearAnchors()
    lbl:SetAnchor(TOPLEFT, ui.table, TOPLEFT, hx, 8)
    lbl:SetWidth(hw)
  end
  placeHdr(ui.hdrName, nameX, nameW)
  placeHdr(ui.hdrSrc, xs[1], widths[1])
  placeHdr(ui.hdrUp, xs[2], widths[2])
  placeHdr(ui.hdrAct, xs[3], widths[3])
  placeHdr(ui.hdrApps, xs[4], widths[4])
  placeHdr(ui.hdrTier, xs[5], widths[5])

  local rowTop = 28
  local rowH = math.floor((tableH - rowTop - 6) / BUFF_MAX_ROWS)
  if rowH < 28 then rowH = 28 end
  if rowH > 36 then rowH = 36 end
  for i = 1, BUFF_MAX_ROWS do
    local r = ui.rows[i]
    if r then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.table, TOPLEFT, pad, rowTop + (i - 1) * rowH)
      r.row:SetDimensions(W - pad * 2, rowH - 2)
      r.chip:ClearAnchors()
      r.chip:SetAnchor(LEFT, r.row, LEFT, 0, 0)
      r.icon:ClearAnchors()
      r.icon:SetAnchor(LEFT, r.row, LEFT, 18 - pad + 8, 0)
      r.name:ClearAnchors()
      r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, nameX - pad, 2)
      r.name:SetWidth(nameW)
      r.barBg:ClearAnchors()
      r.barBg:SetAnchor(BOTTOMLEFT, r.row, BOTTOMLEFT, nameX - pad, -2)
      r.barBg:SetDimensions(math.min(140, nameW), 5)
      local function place(lbl, cx, cw)
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, r.row, TOPLEFT, cx - pad, 6)
        lbl:SetWidth(cw)
      end
      place(r.src, xs[1], widths[1])
      place(r.up, xs[2], widths[2])
      place(r.act, xs[3], widths[3])
      place(r.apps, xs[4], widths[4])
      place(r.tier, xs[5], widths[5])
    end
  end
end

local function refreshBuffsUI(screen, session)
  local ui = createBuffsUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutBuffsUI(ui, hostW, hostH)
  if not session then
    ui.meta:SetText("No fight selected")
    ui.empty:SetText("History is empty.")
    ui.empty:SetHidden(false)
    ui.table:SetHidden(true)
    return
  end
  ui.empty:SetHidden(true)
  ui.table:SetHidden(false)
  local rows = buildBuffModelRows(session, BUFF_MAX_ROWS)
  local totalBuffs = 0
  if type(session.buffs) == "table" then
    for _ in pairs(session.buffs) do totalBuffs = totalBuffs + 1 end
  end
  ui.meta:SetText(string.format("%d buffs tracked · showing top %d by active time", totalBuffs, #rows))
  for i = 1, BUFF_MAX_ROWS do
    local r = ui.rows[i]
    local b = rows[i]
    if r then
      if b then
        r.row:SetHidden(false)
        r.name:SetText(b.name or "?")
        r.src:SetText(b.sourceTxt or "")
        r.up:SetText(b.uptimeTxt or "")
        r.act:SetText(b.activeTxt or "")
        r.apps:SetText(b.appsTxt or "")
        r.tier:SetText(b.tierTxt or "")
        local chip = barChipLabel(b.bar)
        r.chip:SetText(chip)
        local cr, cg, cb, ca = barChipColor(b.bar)
        r.chip:SetColor(cr, cg, cb, ca)
        r.chip:SetHidden(chip == "")
        if b.icon then
          r.icon:SetTexture(b.icon)
          r.icon:SetHidden(false)
          r.icon:SetColor(1, 1, 1, 1)
        else
          r.icon:SetHidden(true)
        end
        local share = tonumber(b.share) or 0
        local bgW = r.barBg:GetWidth() or 120
        if bgW < 10 then bgW = 120 end
        r.barFg:SetDimensions(math.max(2, math.floor(bgW * math.min(1, share))), 5)
      else
        r.row:SetHidden(true)
      end
    end
  end
end

---------------------------------------------------------------------
-- Procs (dense set contribution table)
---------------------------------------------------------------------
local function createProcsUI(screen)
  if screen.procsUI then return screen.procsUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.procs
  if not panel then return nil end
  local ui = { panel = panel, rows = {} }

  ui.root = WM:CreateControl("DM2StatsMenuProcRoot", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)
  ui.title = makeDashLabel(ui.root, "DM2StatsMenuProcTitle", 16, 1.0, 0.90, 0.50, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("SET / PROC CONTRIBUTION")
  ui.meta = makeDashLabel(ui.root, "DM2StatsMenuProcMeta", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)
  ui.legend = makeDashLabel(ui.root, "DM2StatsMenuProcLegend", 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.legend:SetAnchor(TOPLEFT, ui.meta, BOTTOMLEFT, 0, 2)
  ui.legend:SetText("Share = % of fight damage attributed to set/proc groups")

  ui.table = WM:CreateControl("DM2StatsMenuProcTable", ui.root, CT_CONTROL)
  ui.table:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 52)
  local tbg = makeSectionFrame(ui.table, "DM2StatsMenuProcTableBG", true)
  tbg:SetAnchorFill(ui.table)

  ui.hdrName = makeDashLabel(ui.table, "DM2StatsMenuProcHdrName", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrName:SetText("Set / Proc")
  ui.hdrAmt = makeDashLabel(ui.table, "DM2StatsMenuProcHdrAmt", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrAmt:SetText("Amount")
  ui.hdrAmt:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrHits = makeDashLabel(ui.table, "DM2StatsMenuProcHdrHits", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrHits:SetText("Hits")
  ui.hdrHits:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrShare = makeDashLabel(ui.table, "DM2StatsMenuProcHdrShare", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrShare:SetText("Share")
  ui.hdrShare:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrCrit = makeDashLabel(ui.table, "DM2StatsMenuProcHdrCrit", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrCrit:SetText("Crit")
  ui.hdrCrit:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrType = makeDashLabel(ui.table, "DM2StatsMenuProcHdrType", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrType:SetText("Type")
  ui.hdrType:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrDps = makeDashLabel(ui.table, "DM2StatsMenuProcHdrDps", 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrDps:SetText("DPS")
  ui.hdrDps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

  for i = 1, PROC_MAX_ROWS do
    local row = WM:CreateControl("DM2StatsMenuProcRow" .. i, ui.table, CT_CONTROL)
    local name = makeDashLabel(row, "DM2StatsMenuProcName" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    local barBg = WM:CreateControl("DM2StatsMenuProcBarBg" .. i, row, CT_BACKDROP)
    barBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    barBg:SetEdgeColor(0, 0, 0, 0)
    local barFg = WM:CreateControl("DM2StatsMenuProcBarFg" .. i, barBg, CT_BACKDROP)
    barFg:SetCenterColor(0.92, 0.78, 0.40, 0.9)
    barFg:SetEdgeColor(0, 0, 0, 0)
    barFg:SetAnchor(TOPLEFT, barBg, TOPLEFT, 0, 0)
    barFg:SetDimensions(2, 5)
    local amt = makeDashLabel(row, "DM2StatsMenuProcAmt" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    amt:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local hits = makeDashLabel(row, "DM2StatsMenuProcHits" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    hits:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local share = makeDashLabel(row, "DM2StatsMenuProcShare" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    share:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local crit = makeDashLabel(row, "DM2StatsMenuProcCrit" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    crit:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local kind = makeDashLabel(row, "DM2StatsMenuProcType" .. i, 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    kind:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local dps = makeDashLabel(row, "DM2StatsMenuProcDps" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    dps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ui.rows[i] = {
      row = row, name = name, barBg = barBg, barFg = barFg,
      amt = amt, hits = hits, share = share, crit = crit, kind = kind, dps = dps,
    }
  end
  ui.empty = makeDashLabel(ui.root, "DM2StatsMenuProcEmpty", 15, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 60)
  ui.empty:SetHidden(true)
  screen.procsUI = ui
  return ui
end

local function layoutProcsUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.meta:SetWidth(W)
  ui.legend:SetWidth(W)
  ui.empty:SetWidth(W)
  local tableH = H - 52
  ui.table:ClearAnchors()
  ui.table:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 52)
  ui.table:SetDimensions(W, tableH)

  local pad, nameX = 10, 14
  local nameW = math.min(320, math.max(200, math.floor(W * 0.32)))
  local prefs = { 90, 50, 64, 58, 58, 72 }
  local metricStart = nameX + nameW + 12
  local span = (W - pad) - metricStart
  local prefSum = 0
  for _, p in ipairs(prefs) do prefSum = prefSum + p end
  prefSum = prefSum + 6 * (#prefs - 1)
  local scale = span / math.max(1, prefSum)
  if scale > 1.35 then scale = 1.35 end
  if scale < 0.75 then scale = 0.75 end
  local widths, xs = {}, {}
  local x = metricStart
  for i, p in ipairs(prefs) do
    widths[i] = math.floor(p * scale)
    xs[i] = x
    x = x + widths[i] + 6
  end
  local function placeHdr(lbl, hx, hw)
    lbl:ClearAnchors()
    lbl:SetAnchor(TOPLEFT, ui.table, TOPLEFT, hx, 8)
    lbl:SetWidth(hw)
  end
  placeHdr(ui.hdrName, nameX, nameW)
  placeHdr(ui.hdrAmt, xs[1], widths[1])
  placeHdr(ui.hdrHits, xs[2], widths[2])
  placeHdr(ui.hdrShare, xs[3], widths[3])
  placeHdr(ui.hdrCrit, xs[4], widths[4])
  placeHdr(ui.hdrType, xs[5], widths[5])
  placeHdr(ui.hdrDps, xs[6], widths[6])

  local rowTop = 28
  local rowH = math.floor((tableH - rowTop - 6) / PROC_MAX_ROWS)
  if rowH < 28 then rowH = 28 end
  if rowH > 36 then rowH = 36 end
  for i = 1, PROC_MAX_ROWS do
    local r = ui.rows[i]
    if r then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.table, TOPLEFT, pad, rowTop + (i - 1) * rowH)
      r.row:SetDimensions(W - pad * 2, rowH - 2)
      r.name:ClearAnchors()
      r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, nameX - pad, 2)
      r.name:SetWidth(nameW)
      r.barBg:ClearAnchors()
      r.barBg:SetAnchor(BOTTOMLEFT, r.row, BOTTOMLEFT, nameX - pad, -2)
      r.barBg:SetDimensions(math.min(160, nameW), 5)
      local function place(lbl, cx, cw)
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, r.row, TOPLEFT, cx - pad, 6)
        lbl:SetWidth(cw)
      end
      place(r.amt, xs[1], widths[1])
      place(r.hits, xs[2], widths[2])
      place(r.share, xs[3], widths[3])
      place(r.crit, xs[4], widths[4])
      place(r.kind, xs[5], widths[5])
      place(r.dps, xs[6], widths[6])
    end
  end
end

local function refreshProcsUI(screen, session)
  local ui = createProcsUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutProcsUI(ui, hostW, hostH)
  if not session then
    ui.meta:SetText("No fight selected")
    ui.empty:SetText("History is empty.")
    ui.empty:SetHidden(false)
    ui.table:SetHidden(true)
    return
  end
  ui.empty:SetHidden(true)
  ui.table:SetHidden(false)
  local rows = buildProcModelRows(session, PROC_MAX_ROWS)
  ui.meta:SetText(string.format("%d set/proc sources · total damage %s", #rows, fmtInt(session.totalDamage)))
  for i = 1, PROC_MAX_ROWS do
    local r = ui.rows[i]
    local p = rows[i]
    if r then
      if p then
        r.row:SetHidden(false)
        r.name:SetText(p.name or "?")
        r.amt:SetText(p.amountTxt or "")
        r.hits:SetText(p.hitsTxt or "")
        r.share:SetText(p.shareTxt or "")
        r.crit:SetText(p.critTxt or "")
        r.kind:SetText(p.kindTxt or "")
        r.dps:SetText(p.dpsTxt or "")
        local share = tonumber(p.share) or 0
        local bgW = r.barBg:GetWidth() or 140
        if bgW < 10 then bgW = 140 end
        r.barFg:SetDimensions(math.max(2, math.floor(bgW * math.min(1, share))), 5)
      else
        r.row:SetHidden(true)
      end
    end
  end
end

---------------------------------------------------------------------
-- Weave = overlay Weave Analysis (summary + per-skill + DoT; lazy)
---------------------------------------------------------------------
local WEAVE_SKILL_ROWS = 10
local WEAVE_DOT_ROWS = 8

local function createWeaveUI(screen)
  if screen.weaveUI then return screen.weaveUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.weave
  if not panel then return nil end

  local ui = {
    panel = panel,
    kpi = {},
    skillRows = {},
    dotRows = {},
  }

  ui.root = WM:CreateControl("DM2StatsMenuWeaveRoot", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)

  ui.title = makeDashLabel(ui.root, "DM2StatsMenuWeaveTitle", 16, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("WEAVE ANALYSIS")

  ui.meta = makeDashLabel(ui.root, "DM2StatsMenuWeaveMeta", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)

  -- Summary KPI strip (6 tiles)
  ui.sumPanel = WM:CreateControl("DM2StatsMenuWeaveSumPanel", ui.root, CT_CONTROL)
  ui.sumPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 44)
  local sumBg = makeSectionFrame(ui.sumPanel, "DM2StatsMenuWeaveSumBG", true)
  sumBg:SetAnchorFill(ui.sumPanel)
  local kpiDefs = {
    { key = "success", label = "Weave Success" },
    { key = "good", label = "Good" },
    { key = "late", label = "Late" },
    { key = "missed", label = "Missed" },
    { key = "fast", label = "Too Fast" },
    { key = "la", label = "LA Hits" },
    { key = "presses", label = "Skill Presses" },
    { key = "swaps", label = "Bar Swaps" },
  }
  ui.kpiDefs = kpiDefs
  for _, def in ipairs(kpiDefs) do
    local block = WM:CreateControl("DM2StatsMenuWeaveKpi_" .. def.key, ui.sumPanel, CT_CONTROL)
    local bg = makeSectionFrame(block, "DM2StatsMenuWeaveKpiBG_" .. def.key, false)
    bg:SetAnchorFill(block)
    local value = makeDashLabel(block, "DM2StatsMenuWeaveKpiVal_" .. def.key, 16, THEME.textR, THEME.textG, THEME.textB, 1)
    value:SetAnchor(TOPLEFT, block, TOPLEFT, 8, 4)
    local label = makeDashLabel(block, "DM2StatsMenuWeaveKpiLab_" .. def.key, 11, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    label:SetAnchor(BOTTOMLEFT, block, BOTTOMLEFT, 8, -4)
    label:SetText(def.label)
    ui.kpi[def.key] = { block = block, value = value, label = label }
  end

  -- Per-skill weave table
  ui.skillPanel = WM:CreateControl("DM2StatsMenuWeaveSkillPanel", ui.root, CT_CONTROL)
  local skBg = makeSectionFrame(ui.skillPanel, "DM2StatsMenuWeaveSkillBG", true)
  skBg:SetAnchorFill(ui.skillPanel)
  ui.skillTitle = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveSkillTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.skillTitle:SetAnchor(TOPLEFT, ui.skillPanel, TOPLEFT, 10, 6)
  ui.skillTitle:SetText("PER-SKILL WEAVE")
  ui.skillLegend = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveSkillLegend", 11, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.skillLegend:SetAnchor(TOPLEFT, ui.skillTitle, BOTTOMLEFT, 0, 1)
  ui.skillLegend:SetText("|c88DDAAF|r Front   |c88AADDB|r Back   ·  Good%  G / L / M / F  ·  n=casts")

  ui.hdrName = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrName", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrName:SetText("Skill")
  ui.hdrGood = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrGood", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrGood:SetText("Good%")
  ui.hdrGood:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrG = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrG", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrG:SetText("G")
  ui.hdrG:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrL = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrL", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrL:SetText("L")
  ui.hdrL:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrM = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrM", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrM:SetText("M")
  ui.hdrM:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrF = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrF", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrF:SetText("F")
  ui.hdrF:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.hdrN = makeDashLabel(ui.skillPanel, "DM2StatsMenuWeaveHdrN", 11, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.hdrN:SetText("n")
  ui.hdrN:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

  for i = 1, WEAVE_SKILL_ROWS do
    local row = WM:CreateControl("DM2StatsMenuWeaveSkRow" .. i, ui.skillPanel, CT_CONTROL)
    local chip = makeDashLabel(row, "DM2StatsMenuWeaveSkChip" .. i, 11, THEME.frontR, THEME.frontG, THEME.frontB, 1)
    chip:SetDimensions(12, 14)
    local icon = WM:CreateControl("DM2StatsMenuWeaveSkIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(22, 22)
    stampForeground(icon, 110)
    local name = makeDashLabel(row, "DM2StatsMenuWeaveSkName" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    local barBg = WM:CreateControl("DM2StatsMenuWeaveSkBarBg" .. i, row, CT_BACKDROP)
    barBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    barBg:SetEdgeColor(0, 0, 0, 0)
    barBg:SetDimensions(100, 4)
    local barFg = WM:CreateControl("DM2StatsMenuWeaveSkBarFg" .. i, barBg, CT_BACKDROP)
    barFg:SetCenterColor(0.45, 0.88, 0.48, 0.9)
    barFg:SetEdgeColor(0, 0, 0, 0)
    barFg:SetAnchor(TOPLEFT, barBg, TOPLEFT, 0, 0)
    barFg:SetDimensions(2, 4)
    local good = makeDashLabel(row, "DM2StatsMenuWeaveSkGood" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    good:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local g = makeDashLabel(row, "DM2StatsMenuWeaveSkG" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    g:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local l = makeDashLabel(row, "DM2StatsMenuWeaveSkL" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    l:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local m = makeDashLabel(row, "DM2StatsMenuWeaveSkM" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    m:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local f = makeDashLabel(row, "DM2StatsMenuWeaveSkF" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    f:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local n = makeDashLabel(row, "DM2StatsMenuWeaveSkN" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    n:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ui.skillRows[i] = {
      row = row, chip = chip, icon = icon, name = name,
      barBg = barBg, barFg = barFg,
      good = good, g = g, l = l, m = m, f = f, n = n,
    }
  end

  -- DoT uptime panel
  ui.dotPanel = WM:CreateControl("DM2StatsMenuWeaveDotPanel", ui.root, CT_CONTROL)
  local dotBg = makeSectionFrame(ui.dotPanel, "DM2StatsMenuWeaveDotBG", true)
  dotBg:SetAnchorFill(ui.dotPanel)
  ui.dotTitle = makeDashLabel(ui.dotPanel, "DM2StatsMenuWeaveDotTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.dotTitle:SetAnchor(TOPLEFT, ui.dotPanel, TOPLEFT, 10, 6)
  ui.dotTitle:SetText("DOT UPTIME (worst first)")
  ui.dotHelp = makeDashLabel(ui.dotPanel, "DM2StatsMenuWeaveDotHelp", 11, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.dotHelp:SetAnchor(TOPLEFT, ui.dotTitle, BOTTOMLEFT, 0, 1)
  ui.dotHelp:SetText("Estimated from tick gaps · lower uptime needs attention")
  for i = 1, WEAVE_DOT_ROWS do
    local row = WM:CreateControl("DM2StatsMenuWeaveDotRow" .. i, ui.dotPanel, CT_CONTROL)
    local icon = WM:CreateControl("DM2StatsMenuWeaveDotIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(22, 22)
    stampForeground(icon, 110)
    local name = makeDashLabel(row, "DM2StatsMenuWeaveDotName" .. i, 13, THEME.textR, THEME.textG, THEME.textB, 1)
    local sub = makeDashLabel(row, "DM2StatsMenuWeaveDotSub" .. i, 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    local barBg = WM:CreateControl("DM2StatsMenuWeaveDotBarBg" .. i, row, CT_BACKDROP)
    barBg:SetCenterColor(0.12, 0.12, 0.14, 0.55)
    barBg:SetEdgeColor(0, 0, 0, 0)
    barBg:SetDimensions(160, 5)
    local barFg = WM:CreateControl("DM2StatsMenuWeaveDotBarFg" .. i, barBg, CT_BACKDROP)
    barFg:SetCenterColor(0.92, 0.72, 0.32, 0.9)
    barFg:SetEdgeColor(0, 0, 0, 0)
    barFg:SetAnchor(TOPLEFT, barBg, TOPLEFT, 0, 0)
    barFg:SetDimensions(2, 5)
    ui.dotRows[i] = { row = row, icon = icon, name = name, sub = sub, barBg = barBg, barFg = barFg }
  end

  ui.empty = makeDashLabel(ui.root, "DM2StatsMenuWeaveEmpty", 15, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 50)
  ui.empty:SetHidden(true)

  screen.weaveUI = ui
  return ui
end

local function layoutWeaveUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.meta:SetWidth(W)
  ui.empty:SetWidth(W)

  local sumH = 88
  ui.sumPanel:ClearAnchors()
  ui.sumPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 42)
  ui.sumPanel:SetDimensions(W, sumH)
  local cols, rows = 4, 2
  local gap = 6
  local pad = 8
  local cellW = math.floor((W - pad * 2 - gap * (cols - 1)) / cols)
  local cellH = math.floor((sumH - pad * 2 - gap) / rows)
  for i, def in ipairs(ui.kpiDefs or {}) do
    local cell = ui.kpi[def.key]
    if cell and cell.block then
      local col = (i - 1) % cols
      local row = math.floor((i - 1) / cols)
      cell.block:ClearAnchors()
      cell.block:SetDimensions(cellW, cellH)
      cell.block:SetAnchor(TOPLEFT, ui.sumPanel, TOPLEFT, pad + col * (cellW + gap), pad + row * (cellH + gap))
      if cell.value then cell.value:SetWidth(cellW - 12) end
      if cell.label then cell.label:SetWidth(cellW - 12) end
    end
  end

  local midY = 42 + sumH + 6
  local skillH = math.floor((H - midY - 6) * 0.58)
  if skillH < 180 then skillH = 180 end
  local dotH = H - midY - skillH - 6
  if dotH < 120 then
    skillH = H - midY - 126
    dotH = 120
  end

  ui.skillPanel:ClearAnchors()
  ui.skillPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, midY)
  ui.skillPanel:SetDimensions(W, skillH)
  ui.skillTitle:SetWidth(W - 20)
  ui.skillLegend:SetWidth(W - 20)

  -- Bounded skill name, metrics packed immediately after (not flush-right).
  local nameX = 44
  local nameW = math.min(280, math.max(180, math.floor(W * 0.30)))
  local gap = 8
  local metricStart = nameX + nameW + 12
  local prefs = { 70, 40, 40, 40, 40, 40 } -- good% G L M F n
  local prefSum = 0
  for _, pw in ipairs(prefs) do prefSum = prefSum + pw end
  prefSum = prefSum + gap * (#prefs - 1)
  local span = (W - 14) - metricStart
  local scale = span / math.max(1, prefSum)
  if scale > 1.4 then scale = 1.4 end
  if scale < 0.8 then scale = 0.8 end
  local widths, xs = {}, {}
  local x = metricStart
  for i, pw in ipairs(prefs) do
    widths[i] = math.floor(pw * scale)
    xs[i] = x
    x = x + widths[i] + gap
  end
  local xGood, xG, xL, xM, xF, xN = xs[1], xs[2], xs[3], xs[4], xs[5], xs[6]
  local nW, gW, lW, mW, fW, nnW = widths[1], widths[2], widths[3], widths[4], widths[5], widths[6]

  local function placeHdr(lbl, hx, hw)
    lbl:ClearAnchors()
    lbl:SetAnchor(TOPLEFT, ui.skillPanel, TOPLEFT, hx, 36)
    lbl:SetWidth(hw)
  end
  placeHdr(ui.hdrName, nameX, nameW)
  placeHdr(ui.hdrGood, xGood, nW)
  placeHdr(ui.hdrG, xG, gW)
  placeHdr(ui.hdrL, xL, lW)
  placeHdr(ui.hdrM, xM, mW)
  placeHdr(ui.hdrF, xF, fW)
  placeHdr(ui.hdrN, xN, nnW)

  local rowTop = 52
  local rowH = math.floor((skillH - rowTop - 6) / WEAVE_SKILL_ROWS)
  if rowH < 24 then rowH = 24 end
  if rowH > 30 then rowH = 30 end
  for i = 1, WEAVE_SKILL_ROWS do
    local r = ui.skillRows[i]
    if r then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.skillPanel, TOPLEFT, 10, rowTop + (i - 1) * rowH)
      r.row:SetDimensions(W - 20, rowH - 2)
      r.chip:ClearAnchors()
      r.chip:SetAnchor(LEFT, r.row, LEFT, 0, 0)
      r.icon:ClearAnchors()
      r.icon:SetAnchor(LEFT, r.row, LEFT, 14, 0)
      r.name:ClearAnchors()
      r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, nameX - 10, 2)
      r.name:SetWidth(nameW)
      r.name:SetMaxLineCount(1)
      r.barBg:ClearAnchors()
      r.barBg:SetAnchor(BOTTOMLEFT, r.row, BOTTOMLEFT, nameX - 10, -2)
      r.barBg:SetDimensions(math.min(120, nameW), 4)
      local function place(lbl, cx, cw)
        lbl:ClearAnchors()
        lbl:SetAnchor(TOPLEFT, r.row, TOPLEFT, cx - 10, 4)
        lbl:SetWidth(cw)
      end
      place(r.good, xGood, nW)
      place(r.g, xG, gW)
      place(r.l, xL, lW)
      place(r.m, xM, mW)
      place(r.f, xF, fW)
      place(r.n, xN, nnW)
    end
  end

  ui.dotPanel:ClearAnchors()
  ui.dotPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, midY + skillH + 6)
  ui.dotPanel:SetDimensions(W, dotH)
  ui.dotTitle:SetWidth(W - 20)
  ui.dotHelp:SetWidth(W - 20)
  local dTop = 36
  local dH = math.floor((dotH - dTop - 4) / WEAVE_DOT_ROWS)
  if dH < 22 then dH = 22 end
  if dH > 28 then dH = 28 end
  local nameColW = math.min(260, math.max(160, math.floor(W * 0.28)))
  local subColW = math.min(200, math.max(120, math.floor(W * 0.22)))
  local barColW = math.min(200, math.max(100, math.floor(W * 0.20)))
  for i = 1, WEAVE_DOT_ROWS do
    local r = ui.dotRows[i]
    if r then
      r.row:ClearAnchors()
      r.row:SetAnchor(TOPLEFT, ui.dotPanel, TOPLEFT, 10, dTop + (i - 1) * dH)
      r.row:SetDimensions(W - 20, dH - 2)
      r.icon:ClearAnchors()
      r.icon:SetAnchor(LEFT, r.row, LEFT, 0, 0)
      r.name:ClearAnchors()
      r.name:SetAnchor(TOPLEFT, r.row, TOPLEFT, 28, 2)
      r.name:SetWidth(nameColW)
      r.name:SetMaxLineCount(1)
      r.sub:ClearAnchors()
      r.sub:SetAnchor(TOPLEFT, r.row, TOPLEFT, 28 + nameColW + 10, 2)
      r.sub:SetWidth(subColW)
      r.sub:SetMaxLineCount(1)
      r.barBg:ClearAnchors()
      r.barBg:SetAnchor(TOPLEFT, r.row, TOPLEFT, 28 + nameColW + subColW + 20, math.floor((dH - 8) / 2))
      r.barBg:SetDimensions(barColW, 8)
    end
  end
end

local function refreshWeaveUI(screen, session)
  local ui = createWeaveUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutWeaveUI(ui, hostW, hostH)

  if not session then
    ui.meta:SetText("No fight selected")
    ui.empty:SetText("History is empty.")
    ui.empty:SetHidden(false)
    ui.sumPanel:SetHidden(true)
    ui.skillPanel:SetHidden(true)
    ui.dotPanel:SetHidden(true)
    return
  end
  ui.empty:SetHidden(true)
  ui.sumPanel:SetHidden(false)
  ui.skillPanel:SetHidden(false)
  ui.dotPanel:SetHidden(false)

  local w = type(session.weave) == "table" and session.weave or {}
  local good = tonumber(w.onTimeCount) or 0
  local late = tonumber(w.lateCount) or 0
  local missed = tonumber(w.missedCount) or 0
  local tooFast = tonumber(w.tooFastCount) or 0
  local success = getWeaveSuccessRatio(session)
  ui.meta:SetText(string.format(
    "%s  ·  %s  ·  overall weave %s",
    truncateText(session.lastTargetName or "fight", 28),
    fmtDur(session.durationMs),
    fmtPct(success)
  ))

  local kpiVals = {
    success = fmtPct(success),
    good = tostring(good),
    late = tostring(late),
    missed = tostring(missed),
    fast = tostring(tooFast),
    la = tostring(sessionLaHits(session)),
    presses = tostring(tonumber(w.inputSkillPresses) or tonumber(w.skillEventCount) or 0),
    swaps = tostring(tonumber(w.barSwapCount) or 0),
  }
  for key, val in pairs(kpiVals) do
    local cell = ui.kpi[key]
    if cell and cell.value then cell.value:SetText(val) end
  end

  local skillRows = buildPerSkillWeaveModel(session, WEAVE_SKILL_ROWS)
  for i = 1, WEAVE_SKILL_ROWS do
    local r = ui.skillRows[i]
    local item = skillRows[i]
    if r then
      if item then
        r.row:SetHidden(false)
        r.name:SetText(item.name or "?")
        r.good:SetText(item.goodTxt or "")
        r.g:SetText(item.gTxt or "")
        r.l:SetText(item.lTxt or "")
        r.m:SetText(item.mTxt or "")
        r.f:SetText(item.fTxt or "")
        r.n:SetText(item.nTxt or "")
        local chip = barChipLabel(item.bar)
        r.chip:SetText(chip)
        local cr, cg, cb, ca = barChipColor(item.bar)
        r.chip:SetColor(cr, cg, cb, ca)
        r.chip:SetHidden(chip == "")
        if item.icon then
          r.icon:SetTexture(item.icon)
          r.icon:SetHidden(false)
          r.icon:SetColor(1, 1, 1, 1)
        else
          r.icon:SetHidden(true)
        end
        local share = tonumber(item.share) or 0
        local bgW = r.barBg:GetWidth() or 100
        if bgW < 10 then bgW = 100 end
        r.barFg:SetDimensions(math.max(2, math.floor(bgW * math.min(1, share))), 4)
      else
        r.row:SetHidden(i ~= 1 or #skillRows > 0)
        if i == 1 and #skillRows == 0 then
          r.row:SetHidden(false)
          r.name:SetText("No per-skill weave samples (need timeline data).")
          r.good:SetText("")
          r.g:SetText("")
          r.l:SetText("")
          r.m:SetText("")
          r.f:SetText("")
          r.n:SetText("")
          r.chip:SetHidden(true)
          r.icon:SetHidden(true)
          r.barFg:SetDimensions(2, 4)
        end
      end
    end
  end

  local dots = buildDotUptimeModel(session, WEAVE_DOT_ROWS)
  for i = 1, WEAVE_DOT_ROWS do
    local r = ui.dotRows[i]
    local item = dots[i]
    if r then
      if item then
        r.row:SetHidden(false)
        r.name:SetText(item.name or "?")
        r.sub:SetText(item.sub or "")
        if item.icon then
          r.icon:SetTexture(item.icon)
          r.icon:SetHidden(false)
          r.icon:SetColor(1, 1, 1, 1)
        else
          r.icon:SetHidden(true)
        end
        local share = tonumber(item.share) or 0
        local bgW = r.barBg:GetWidth() or 160
        if bgW < 10 then bgW = 160 end
        local ratio = math.min(1, share)
        r.barFg:SetDimensions(math.max(2, math.floor(bgW * ratio)), 5)
        if ratio < 0.5 then
          r.barFg:SetCenterColor(0.88, 0.38, 0.30, 0.9)
        elseif ratio < 0.8 then
          r.barFg:SetCenterColor(0.92, 0.72, 0.32, 0.9)
        else
          r.barFg:SetCenterColor(0.45, 0.88, 0.48, 0.9)
        end
      else
        r.row:SetHidden(i ~= 1 or #dots > 0)
        if i == 1 and #dots == 0 then
          r.row:SetHidden(false)
          r.name:SetText("No DoT tick data for this fight.")
          r.sub:SetText("")
          r.icon:SetHidden(true)
          r.barFg:SetDimensions(2, 5)
        end
      end
    end
  end
end

---------------------------------------------------------------------
-- Gear
---------------------------------------------------------------------
local GEAR_LINE_MAX = 20

local function createGearUI(screen)
  if screen.gearUI then return screen.gearUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.gear
  if not panel then return nil end
  local ui = { panel = panel, lines = {}, barIcons = { front = {}, back = {} } }

  ui.root = WM:CreateControl("DM2StatsMenuGearRoot", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)

  ui.title = makeDashLabel(ui.root, "DM2StatsMenuGearTitle", 16, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("GEAR SUMMARY")

  ui.meta = makeDashLabel(ui.root, "DM2StatsMenuGearMeta", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)
  ui.meta:SetText("Bars + sets from parse snapshot · worn slots are live (current character)")

  ui.barsPanel = WM:CreateControl("DM2StatsMenuGearBars", ui.root, CT_CONTROL)
  local barsBg = makeSectionFrame(ui.barsPanel, "DM2StatsMenuGearBarsBG", true)
  barsBg:SetAnchorFill(ui.barsPanel)
  ui.barHead = makeDashLabel(ui.barsPanel, "DM2StatsMenuGearBarHead", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.barHead:SetAnchor(TOPLEFT, ui.barsPanel, TOPLEFT, 10, 6)
  ui.barHead:SetText("ACTION BARS (parse snapshot)")
  ui.frontTitle = makeDashLabel(ui.barsPanel, "DM2StatsMenuGearFront", 13, THEME.frontR, THEME.frontG, THEME.frontB, 1)
  ui.frontTitle:SetText("Front")
  ui.backTitle = makeDashLabel(ui.barsPanel, "DM2StatsMenuGearBack", 13, THEME.backR, THEME.backG, THEME.backB, 1)
  ui.backTitle:SetText("Back")

  for _, barKey in ipairs({ "front", "back" }) do
    for i = 1, 6 do
      local slotBg = WM:CreateControl("DM2StatsMenuGear" .. barKey .. "Slot" .. i, ui.barsPanel, CT_BACKDROP)
      slotBg:SetDimensions(BAR_ICON_SIZE + 4, BAR_ICON_SIZE + 4)
      slotBg:SetCenterColor(0.14, 0.12, 0.09, 0.95)
      slotBg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, 0.75)
      stampBackground(slotBg, 4)
      local icon = WM:CreateControl("DM2StatsMenuGear" .. barKey .. "Icon" .. i, slotBg, CT_TEXTURE)
      icon:SetDimensions(BAR_ICON_SIZE, BAR_ICON_SIZE)
      icon:SetAnchor(CENTER, slotBg, CENTER, 0, 0)
      stampForeground(icon, 110)
      local name = makeDashLabel(ui.barsPanel, "DM2StatsMenuGear" .. barKey .. "Name" .. i, 11, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
      name:SetMaxLineCount(2)
      ui.barIcons[barKey][i] = { bg = slotBg, icon = icon, name = name }
    end
  end

  ui.listPanel = WM:CreateControl("DM2StatsMenuGearList", ui.root, CT_CONTROL)
  local listBg = makeSectionFrame(ui.listPanel, "DM2StatsMenuGearListBG", true)
  listBg:SetAnchorFill(ui.listPanel)
  ui.listTitle = makeDashLabel(ui.listPanel, "DM2StatsMenuGearListTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.listTitle:SetAnchor(TOPLEFT, ui.listPanel, TOPLEFT, 10, 6)
  ui.listTitle:SetText("SETS + WORN GEAR")

  for i = 1, GEAR_LINE_MAX do
    local line = makeDashLabel(ui.listPanel, "DM2StatsMenuGearLine" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    ui.lines[i] = line
  end

  ui.empty = makeDashLabel(ui.root, "DM2StatsMenuGearEmpty", 15, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.empty:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 48)
  ui.empty:SetHidden(true)

  screen.gearUI = ui
  return ui
end

local function layoutGearUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.meta:SetWidth(W)
  ui.empty:SetWidth(W)

  local barsH = 128
  ui.barsPanel:ClearAnchors()
  ui.barsPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 44)
  ui.barsPanel:SetDimensions(W, barsH)
  ui.barHead:SetWidth(W - 20)
  ui.frontTitle:ClearAnchors()
  ui.frontTitle:SetAnchor(TOPLEFT, ui.barsPanel, TOPLEFT, 10, 28)
  ui.backTitle:ClearAnchors()
  ui.backTitle:SetAnchor(TOPLEFT, ui.barsPanel, TOPLEFT, 10, 78)
  local slotGap = 8
  local slotStep = BAR_ICON_SIZE + 4 + slotGap
  for _, barKey in ipairs({ "front", "back" }) do
    local y = (barKey == "front") and 28 or 78
    for i = 1, 6 do
      local slot = ui.barIcons[barKey][i]
      if slot and slot.bg then
        slot.bg:ClearAnchors()
        slot.bg:SetAnchor(TOPLEFT, ui.barsPanel, TOPLEFT, 70 + (i - 1) * slotStep, y)
        if slot.name then
          slot.name:ClearAnchors()
          slot.name:SetAnchor(TOPLEFT, ui.barsPanel, TOPLEFT, 70 + (i - 1) * slotStep, y + BAR_ICON_SIZE + 6)
          slot.name:SetWidth(BAR_ICON_SIZE + 8)
          slot.name:SetHidden(true) -- names optional; icons primary
        end
      end
    end
  end

  local listY = 44 + barsH + 6
  local listH = H - listY - 4
  ui.listPanel:ClearAnchors()
  ui.listPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, listY)
  ui.listPanel:SetDimensions(W, listH)
  ui.listTitle:SetWidth(W - 20)

  -- Two columns of gear lines to fill width.
  local colW = math.floor((W - 36) / 2)
  local rowH = 20
  local top = 28
  local rowsPerCol = math.floor((listH - top - 6) / rowH)
  if rowsPerCol < 8 then rowsPerCol = 8 end
  for i = 1, GEAR_LINE_MAX do
    local line = ui.lines[i]
    if line then
      local col = (i <= rowsPerCol) and 0 or 1
      local row = (i - 1) % rowsPerCol
      if i > rowsPerCol * 2 then
        line:SetHidden(true)
      else
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, ui.listPanel, TOPLEFT, 12 + col * (colW + 12), top + row * rowH)
        line:SetWidth(colW)
        line:SetMaxLineCount(1)
      end
    end
  end
  ui._gearRowsPerCol = rowsPerCol
end

local function refreshBarIcons(iconRows, slots)
  for i = 1, 6 do
    local ui = iconRows and iconRows[i]
    local slot = slots and slots[i]
    if not ui then
      -- continue
    elseif slot and (slot.filled or (slot.id or 0) > 0) then
      if ui.bg then
        ui.bg:SetCenterColor(0.14, 0.12, 0.09, 0.95)
        ui.bg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, 0.75)
      end
      if slot.icon then
        ui.icon:SetTexture(slot.icon)
        ui.icon:SetHidden(false)
        ui.icon:SetColor(1, 1, 1, 1)
      else
        ui.icon:SetHidden(true)
      end
    else
      if ui.bg then
        ui.bg:SetCenterColor(0.06, 0.08, 0.12, 0.80)
        ui.bg:SetEdgeColor(0.25, 0.32, 0.40, 0.40)
      end
      if ui.icon then ui.icon:SetHidden(true) end
    end
  end
end

local function refreshGearUI(screen, session)
  local ui = createGearUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutGearUI(ui, hostW, hostH)

  if not session then
    ui.empty:SetText("History is empty.")
    ui.empty:SetHidden(false)
    ui.barsPanel:SetHidden(true)
    ui.listPanel:SetHidden(true)
    for _, line in ipairs(ui.lines) do line:SetHidden(true) end
    refreshBarIcons(ui.barIcons.front, {})
    refreshBarIcons(ui.barIcons.back, {})
    return
  end
  ui.empty:SetHidden(true)
  ui.barsPanel:SetHidden(false)
  ui.listPanel:SetHidden(false)
  refreshBarIcons(ui.barIcons.front, collectBarSlots(session, "Front"))
  refreshBarIcons(ui.barIcons.back, collectBarSlots(session, "Back"))

  local lines = buildGearLines(session)
  if #lines == 0 then
    lines = { "No set names on this parse snapshot.", "Live worn gear unavailable or empty." }
  end
  local maxShow = math.min(GEAR_LINE_MAX, (ui._gearRowsPerCol or 10) * 2)
  for i, line in ipairs(ui.lines) do
    if lines[i] and i <= maxShow then
      line:SetHidden(false)
      line:SetText(lines[i])
    else
      line:SetHidden(true)
    end
  end
end

---------------------------------------------------------------------
-- Rotation: readable KPIs + colored timeline + pulse
---------------------------------------------------------------------
local function createRotationUI(screen)
  -- Force rebuild if older structure (no _v377)
  if screen.rotationUI and not screen.rotationUI._v377 then screen.rotationUI = nil end
  if screen.rotationUI then return screen.rotationUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.rotation
  if not panel then return nil end
  local ui = { panel = panel, kpis = {}, timeline = {}, pulse = {}, _v377 = true }

  ui.root = WM:CreateControl("DM2StatsMenuRotRootV7", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)
  ui.title = makeDashLabel(ui.root, "DM2StatsMenuRotTitleV7", 16, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("ROTATION DIAGNOSTICS")
  ui.meta = makeDashLabel(ui.root, "DM2StatsMenuRotMetaV7", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.meta:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)
  -- Color legend in header (readable on TV)
  ui.meta:SetText("|c66FF66+ good|r   |cFFCC66~ late|r   |cFF6666x missed|r   |c66AAFF> too fast|r   |cAADDFFLA|r light attack")

  ui.sumPanel = WM:CreateControl("DM2StatsMenuRotSumV7", ui.root, CT_CONTROL)
  local sbg = makeSectionFrame(ui.sumPanel, "DM2StatsMenuRotSumBGV7", true)
  sbg:SetAnchorFill(ui.sumPanel)
  -- Single-line stats strip (avoids scrunched 8-box grid)
  ui.sumLine1 = makeDashLabel(ui.sumPanel, "DM2StatsMenuRotSum1V7", 18, THEME.textR, THEME.textG, THEME.textB, 1)
  ui.sumLine1:SetAnchor(TOPLEFT, ui.sumPanel, TOPLEFT, 14, 12)
  ui.sumLine2 = makeDashLabel(ui.sumPanel, "DM2StatsMenuRotSum2V7", 16, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.sumLine2:SetAnchor(TOPLEFT, ui.sumPanel, TOPLEFT, 14, 40)

  ui.pulsePanel = WM:CreateControl("DM2StatsMenuRotPulsePanelV7", ui.root, CT_CONTROL)
  local pbg = makeSectionFrame(ui.pulsePanel, "DM2StatsMenuRotPulseBGV7", true)
  pbg:SetAnchorFill(ui.pulsePanel)
  ui.pulseTitle = makeDashLabel(ui.pulsePanel, "DM2StatsMenuRotPulseTitleV7", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.pulseTitle:SetAnchor(TOPLEFT, ui.pulsePanel, TOPLEFT, 10, 6)
  ui.pulseTitle:SetText("WEAVE PULSE")
  ui.pulseWrap = WM:CreateControl("DM2StatsMenuRotPulseWrapV7", ui.pulsePanel, CT_CONTROL)
  for i = 1, PULSE_BLOCKS do
    local block = WM:CreateControl("DM2StatsMenuRotPulseV7_" .. i, ui.pulseWrap, CT_BACKDROP)
    block:SetEdgeColor(0, 0, 0, 0)
    block:SetHidden(true)
    stampForeground(block, 100)
    ui.pulse[i] = block
  end

  ui.tlPanel = WM:CreateControl("DM2StatsMenuRotTlPanelV7", ui.root, CT_CONTROL)
  local tbg = makeSectionFrame(ui.tlPanel, "DM2StatsMenuRotTlBGV7", true)
  tbg:SetAnchorFill(ui.tlPanel)
  ui.tlTitle = makeDashLabel(ui.tlPanel, "DM2StatsMenuRotTlTitleV7", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.tlTitle:SetAnchor(TOPLEFT, ui.tlPanel, TOPLEFT, 10, 6)
  ui.tlTitle:SetText("TIMELINE")
  for i = 1, ROT_TIMELINE_LINES do
    ui.timeline[i] = makeDashLabel(ui.tlPanel, "DM2StatsMenuRotTlV7_" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
  end

  screen.rotationUI = ui
  return ui
end

local function layoutRotationUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.meta:SetWidth(W)

  local sumH = 72
  ui.sumPanel:ClearAnchors()
  ui.sumPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 44)
  ui.sumPanel:SetDimensions(W, sumH)
  ui.sumLine1:SetWidth(W - 28)
  ui.sumLine2:SetWidth(W - 28)

  local pulseH = 52
  local pulseY = 44 + sumH + 6
  ui.pulsePanel:ClearAnchors()
  ui.pulsePanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, pulseY)
  ui.pulsePanel:SetDimensions(W, pulseH)
  ui.pulseTitle:SetWidth(W - 20)
  ui.pulseWrap:ClearAnchors()
  ui.pulseWrap:SetAnchor(TOPLEFT, ui.pulsePanel, TOPLEFT, 10, 26)
  ui.pulseWrap:SetDimensions(W - 20, 22)

  local tlY = pulseY + pulseH + 6
  local tlH = H - tlY - 4
  ui.tlPanel:ClearAnchors()
  ui.tlPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, tlY)
  ui.tlPanel:SetDimensions(W, tlH)
  ui.tlTitle:SetWidth(W - 20)
  local lineH = math.floor((tlH - 30) / ROT_TIMELINE_LINES)
  if lineH < 17 then lineH = 17 end
  if lineH > 22 then lineH = 22 end
  for i = 1, ROT_TIMELINE_LINES do
    local line = ui.timeline[i]
    if line then
      line:ClearAnchors()
      line:SetAnchor(TOPLEFT, ui.tlPanel, TOPLEFT, 12, 28 + (i - 1) * lineH)
      line:SetWidth(W - 28)
      line:SetMaxLineCount(1)
    end
  end
end

local function refreshRotationUI(screen, session)
  local ui = createRotationUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutRotationUI(ui, hostW, hostH)
  local textW = math.max(400, hostW - 16)

  if not session then
    ui.meta:SetText("|c66FF66+ good|r   |cFFCC66~ late|r   |cFF6666x missed|r   |c66AAFF> too fast|r   |cAADDFFLA|r")
    ui.sumLine1:SetText("No fight selected")
    ui.sumLine2:SetText("")
    for _, b in ipairs(ui.pulse) do b:SetHidden(true) end
    for _, l in ipairs(ui.timeline) do l:SetText("") end
    return
  end

  local w = type(session.weave) == "table" and session.weave or {}
  ui.meta:SetText(string.format(
    "%s  ·  %s  ·  |c66FF66+ good|r  |cFFCC66~ late|r  |cFF6666x miss|r  |c66AAFF> fast|r  |cAADDFFLA|r",
    truncateText(session.lastTargetName or "fight", 28), fmtDur(session.durationMs)
  ))
  ui.sumLine1:SetText(string.format(
    "Weave  |c66FF66%s|r     Good |c66FF66%d|r     Late |cFFCC66%d|r     Missed |cFF6666%d|r     Fast |c66AAFF%d|r",
    fmtPct(getWeaveSuccessRatio(session)),
    tonumber(w.onTimeCount) or 0,
    tonumber(w.lateCount) or 0,
    tonumber(w.missedCount) or 0,
    tonumber(w.tooFastCount) or 0
  ))
  ui.sumLine2:SetText(string.format(
    "LA hits %s    Skill presses %s    Bar swaps %s",
    tostring(sessionLaHits(session)),
    tostring(tonumber(w.inputSkillPresses) or tonumber(w.skillEventCount) or 0),
    tostring(tonumber(w.barSwapCount) or 0)
  ))

  local ratios = buildPulseRatios(session, PULSE_BLOCKS)
  local wrapW = ui.pulseWrap:GetWidth() or textW
  if wrapW < 50 then wrapW = textW end
  local blockW = math.max(5, math.floor((wrapW - 4) / math.max(#ui.pulse, 1)) - 2)
  for i, block in ipairs(ui.pulse) do
    local ratio = ratios[i]
    if ratio then
      block:ClearAnchors()
      block:SetDimensions(blockW, 18)
      block:SetAnchor(TOPLEFT, ui.pulseWrap, TOPLEFT, (i - 1) * (blockW + 2), 0)
      local r, g, b, a = sparkColorForRatio(ratio)
      block:SetCenterColor(r, g, b, a)
      block:SetHidden(false)
    else
      block:SetHidden(true)
    end
  end

  -- Wide budget so tokens are not truncated; color markup stripped for length only.
  local lines = buildTimelineLines(session, ROT_TIMELINE_LINES, math.max(100, math.floor(textW / 5.5)))
  for i, l in ipairs(ui.timeline) do
    l:SetText(lines[i] or "")
  end
end

---------------------------------------------------------------------
-- History redesign: fight cards → trend bars (middle) → comparison table
---------------------------------------------------------------------
local function createHistoryUI(screen)
  if screen.historyUI and not screen.historyUI._v377 then screen.historyUI = nil end
  if screen.historyUI then return screen.historyUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.history
  if not panel then return nil end
  local ui = {
    panel = panel,
    metrics = {
      { key = "dps", label = "DPS" },
      { key = "crit", label = "CRIT" },
      { key = "weave", label = "WEAVE" },
    },
    metricRows = {},
    cards = {},
    compHdr = {},
    compRows = {},
    _v377 = true,
  }

  ui.root = WM:CreateControl("DM2StatsMenuHistRootV7", panel, CT_CONTROL)
  ui.root:SetAnchor(TOPLEFT, panel, TOPLEFT, 8, 4)
  stampForeground(ui.root, 55)
  ui.title = makeDashLabel(ui.root, "DM2StatsMenuHistTitleV7", 16, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, 0)
  ui.title:SetText("HISTORY")
  ui.subtitle = makeDashLabel(ui.root, "DM2StatsMenuHistSubV7", 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.subtitle:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 2)

  -- 1) Fight cards (top)
  ui.listPanel = WM:CreateControl("DM2StatsMenuHistListV7", ui.root, CT_CONTROL)
  local lbg = makeSectionFrame(ui.listPanel, "DM2StatsMenuHistListBGV7", true)
  lbg:SetAnchorFill(ui.listPanel)
  ui.histTitle = makeDashLabel(ui.listPanel, "DM2StatsMenuHistListTitleV7", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  ui.histTitle:SetAnchor(TOPLEFT, ui.listPanel, TOPLEFT, 10, 6)
  ui.histTitle:SetText("RECENT FIGHTS  ·  L2 older  ·  R2 newer")
  for i = 1, TREND_HIST_LINES do
    local card = WM:CreateControl("DM2StatsMenuHistCardV7_" .. i, ui.listPanel, CT_CONTROL)
    local bg = makeSectionFrame(card, "DM2StatsMenuHistCardBGV7_" .. i, false)
    bg:SetAnchorFill(card)
    local sel = WM:CreateControl("DM2StatsMenuHistCardSelV7_" .. i, card, CT_BACKDROP)
    sel:SetCenterColor(0.35, 0.85, 0.95, 0.95)
    sel:SetEdgeColor(0, 0, 0, 0)
    sel:SetAnchor(TOPLEFT, card, TOPLEFT, 0, 0)
    sel:SetDimensions(5, 40)
    stampForeground(sel, 110)
    local num = makeDashLabel(card, "DM2StatsMenuHistCardNumV7_" .. i, 15, 0.55, 0.95, 1.0, 1)
    num:SetAnchor(TOPLEFT, card, TOPLEFT, 12, 6)
    local tag = makeDashLabel(card, "DM2StatsMenuHistCardTagV7_" .. i, 12, 1.0, 0.88, 0.45, 1)
    tag:SetAnchor(TOPLEFT, card, TOPLEFT, 56, 8)
    local target = makeDashLabel(card, "DM2StatsMenuHistCardTgtV7_" .. i, 15, THEME.textR, THEME.textG, THEME.textB, 1)
    target:SetAnchor(TOPLEFT, card, TOPLEFT, 120, 6)
    local dps = makeDashLabel(card, "DM2StatsMenuHistCardDpsV7_" .. i, 18, 0.95, 0.82, 0.45, 1)
    dps:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local meta = makeDashLabel(card, "DM2StatsMenuHistCardMetaV7_" .. i, 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    meta:SetAnchor(TOPLEFT, card, TOPLEFT, 120, 26)
    ui.cards[i] = { card = card, bg = bg, sel = sel, num = num, tag = tag, target = target, dps = dps, meta = meta }
  end

  -- 2) Trend bars (middle — between list and comparison)
  ui.trendPanel = WM:CreateControl("DM2StatsMenuHistTrendV7", ui.root, CT_CONTROL)
  local tbg = makeSectionFrame(ui.trendPanel, "DM2StatsMenuHistTrendBGV7", true)
  tbg:SetAnchorFill(ui.trendPanel)
  ui.trendTitle = makeDashLabel(ui.trendPanel, "DM2StatsMenuHistTrendTitleV7", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  ui.trendTitle:SetAnchor(TOPLEFT, ui.trendPanel, TOPLEFT, 10, 4)
  ui.trendTitle:SetText("DUMMY TRENDS  (oldest → newest)")
  for i, def in ipairs(ui.metrics) do
    local row = WM:CreateControl("DM2StatsMenuHistMetricV7_" .. i, ui.trendPanel, CT_CONTROL)
    local label = makeDashLabel(row, "DM2StatsMenuHistMetricLabelV7_" .. def.key, 13, THEME.titleR, THEME.titleG, THEME.titleB, 1)
    label:SetAnchor(LEFT, row, LEFT, 0, 0)
    label:SetText(def.label)
    local latest = makeDashLabel(row, "DM2StatsMenuHistMetricLatestV7_" .. def.key, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    latest:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local wrap, bars = createSparkBarPool(row, "DM2StatsMenuHistSparkV7_" .. def.key, TREND_SPARK_MAX_BARS)
    ui.metricRows[i] = { row = row, label = label, latest = latest, wrap = wrap, bars = bars, key = def.key }
  end

  -- 3) Comparison table (bottom)
  ui.compPanel = WM:CreateControl("DM2StatsMenuHistCompV7", ui.root, CT_CONTROL)
  local cbg = makeSectionFrame(ui.compPanel, "DM2StatsMenuHistCompBGV7", true)
  cbg:SetAnchorFill(ui.compPanel)
  ui.compTitle = makeDashLabel(ui.compPanel, "DM2StatsMenuHistCompTitleV7", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  ui.compTitle:SetAnchor(TOPLEFT, ui.compPanel, TOPLEFT, 10, 4)
  ui.compTitle:SetText("DUMMY COMPARISON  (columns = newest → older)")
  ui.compCorner = makeDashLabel(ui.compPanel, "DM2StatsMenuHistCompCornerV7", 12, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  ui.compCorner:SetText("Metric")
  for c = 1, COMP_COLS do
    ui.compHdr[c] = makeDashLabel(ui.compPanel, "DM2StatsMenuHistCompHdrV7_" .. c, 12, THEME.titleR, THEME.titleG, THEME.titleB, 1)
    ui.compHdr[c]:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  end
  for r = 1, COMP_METRICS do
    local row = { label = nil, cells = {} }
    row.label = makeDashLabel(ui.compPanel, "DM2StatsMenuHistCompLabV7_" .. r, 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    for c = 1, COMP_COLS do
      local cell = makeDashLabel(ui.compPanel, "DM2StatsMenuHistCompCellV7_" .. r .. "_" .. c, 13, THEME.textR, THEME.textG, THEME.textB, 1)
      cell:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
      row.cells[c] = cell
    end
    ui.compRows[r] = row
  end

  screen.historyUI = ui
  return ui
end

local function layoutHistoryUI(ui, hostW, hostH)
  if not ui or not ui.root then return end
  local W = math.max(480, (hostW or 900) - 8)
  local H = math.max(400, (hostH or 700) - 8)
  ui.root:ClearAnchors()
  ui.root:SetAnchor(TOPLEFT, ui.panel, TOPLEFT, 8, 4)
  ui.root:SetDimensions(W, H)
  ui.title:SetWidth(W)
  ui.subtitle:SetWidth(W)

  -- Vertical split: cards ~42% | trends ~22% | table ~rest
  local y0 = 42
  local listH = math.floor((H - y0) * 0.40)
  if listH < 160 then listH = 160 end
  local trendH = math.floor((H - y0) * 0.22)
  if trendH < 90 then trendH = 90 end
  local compH = H - y0 - listH - trendH - 12
  if compH < 130 then
    listH = H - y0 - trendH - 142
    compH = 130
  end

  ui.listPanel:ClearAnchors()
  ui.listPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, y0)
  ui.listPanel:SetDimensions(W, listH)
  ui.histTitle:SetWidth(W - 20)
  local cardH = math.floor((listH - 30) / TREND_HIST_LINES)
  if cardH < 36 then cardH = 36 end
  if cardH > 48 then cardH = 48 end
  for i = 1, TREND_HIST_LINES do
    local c = ui.cards[i]
    if c and c.card then
      c.card:ClearAnchors()
      c.card:SetAnchor(TOPLEFT, ui.listPanel, TOPLEFT, 8, 26 + (i - 1) * cardH)
      c.card:SetDimensions(W - 16, cardH - 4)
      c.sel:SetDimensions(5, cardH - 8)
      c.num:SetWidth(44)
      c.tag:SetWidth(58)
      c.target:SetWidth(math.min(340, math.floor((W - 16) * 0.38)))
      c.dps:ClearAnchors()
      c.dps:SetAnchor(TOPRIGHT, c.card, TOPRIGHT, -12, 4)
      c.dps:SetWidth(90)
      c.meta:SetWidth(math.min(420, math.floor((W - 16) * 0.50)))
    end
  end

  local trendY = y0 + listH + 6
  ui.trendPanel:ClearAnchors()
  ui.trendPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, trendY)
  ui.trendPanel:SetDimensions(W, trendH)
  ui.trendTitle:SetWidth(W - 20)
  local rowH = math.floor((trendH - 24) / 3)
  if rowH < 22 then rowH = 22 end
  for i, row in ipairs(ui.metricRows) do
    row.row:ClearAnchors()
    row.row:SetAnchor(TOPLEFT, ui.trendPanel, TOPLEFT, 12, 22 + (i - 1) * rowH)
    row.row:SetDimensions(W - 24, rowH - 2)
    row.label:SetWidth(56)
    row.latest:ClearAnchors()
    row.latest:SetAnchor(LEFT, row.row, LEFT, 60, 0)
    row.latest:SetWidth(70)
    row.wrap:ClearAnchors()
    row.wrap:SetAnchor(LEFT, row.row, LEFT, 140, 0)
    row.wrap:SetDimensions(W - 24 - 150, math.min(TREND_SPARK_BAR_MAX_H, rowH - 6))
  end

  local compY = trendY + trendH + 6
  ui.compPanel:ClearAnchors()
  ui.compPanel:SetAnchor(TOPLEFT, ui.root, TOPLEFT, 0, compY)
  ui.compPanel:SetDimensions(W, compH)
  ui.compTitle:SetWidth(W - 20)

  local labelW = math.min(110, math.floor(W * 0.14))
  local colW = math.floor((W - 28 - labelW) / COMP_COLS)
  local top = 24
  ui.compCorner:ClearAnchors()
  ui.compCorner:SetAnchor(TOPLEFT, ui.compPanel, TOPLEFT, 12, top)
  ui.compCorner:SetWidth(labelW)
  for c = 1, COMP_COLS do
    local hdr = ui.compHdr[c]
    if hdr then
      hdr:ClearAnchors()
      hdr:SetAnchor(TOPLEFT, ui.compPanel, TOPLEFT, 12 + labelW + (c - 1) * colW, top)
      hdr:SetWidth(colW - 6)
    end
  end
  local rh = math.floor((compH - top - 20) / COMP_METRICS)
  if rh < 16 then rh = 16 end
  if rh > 22 then rh = 22 end
  for r = 1, COMP_METRICS do
    local row = ui.compRows[r]
    if row then
      local y = top + 18 + (r - 1) * rh
      row.label:ClearAnchors()
      row.label:SetAnchor(TOPLEFT, ui.compPanel, TOPLEFT, 12, y)
      row.label:SetWidth(labelW)
      for c = 1, COMP_COLS do
        local cell = row.cells[c]
        if cell then
          cell:ClearAnchors()
          cell:SetAnchor(TOPLEFT, ui.compPanel, TOPLEFT, 12 + labelW + (c - 1) * colW, y)
          cell:SetWidth(colW - 6)
        end
      end
    end
  end
end

local function refreshHistoryUI(screen)
  local ui = createHistoryUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  layoutHistoryUI(ui, hostW, hostH)

  local trends = collectDummyTrendParses(TREND_MAX_COLS)
  local liveCount = historyCount()
  if liveCount <= 0 then
    ui.subtitle:SetText("No fights in history yet — complete a parse")
  else
    ui.subtitle:SetText(string.format(
      "%d fights stored · offset %d · %d dummy(s) for trends/compare · L2/R2 to walk",
      liveCount, historyOffset, #trends
    ))
  end

  -- Cards
  local cards = buildHistoryCards(historyOffset, TREND_HIST_LINES)
  for i = 1, TREND_HIST_LINES do
    local c = ui.cards[i]
    local d = cards[i]
    if c then
      if d then
        c.card:SetHidden(false)
        c.num:SetText(string.format("#%d", d.fightNo))
        c.tag:SetText(d.tag or "")
        if d.isDummy then
          c.tag:SetColor(1.0, 0.88, 0.45, 1)
        else
          c.tag:SetColor(0.70, 0.78, 0.90, 1)
        end
        c.target:SetText(d.target or "?")
        c.dps:SetText(d.dps or "—")
        c.meta:SetText(string.format("crit %s · weave %s · %s · %s",
          d.crit or "—", d.weave or "—", d.dur or "—", d.when or "—"))
        if d.selected then
          c.sel:SetHidden(false)
          c.bg:SetCenterColor(0.12, 0.18, 0.22, 0.75)
          c.bg:SetEdgeColor(0.40, 0.80, 0.90, 0.65)
          c.num:SetColor(0.55, 0.98, 1.0, 1)
        else
          c.sel:SetHidden(true)
          c.bg:SetCenterColor(THEME.cardR, THEME.cardG, THEME.cardB, THEME.cardA * 0.55)
          c.bg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, THEME.cardEdgeA * 0.7)
          c.num:SetColor(0.72, 0.78, 0.84, 1)
        end
      else
        c.card:SetHidden(true)
      end
    end
  end

  -- Trend bars
  local valuesByKey = { dps = {}, crit = {}, weave = {} }
  for _, t in ipairs(trends) do
    table.insert(valuesByKey.dps, 1, t.dps)
    table.insert(valuesByKey.crit, 1, t.crit)
    table.insert(valuesByKey.weave, 1, t.weave)
  end
  local latest = trends[1]
  for _, row in ipairs(ui.metricRows) do
    local wrapW = row.wrap:GetWidth() or 200
    if wrapW < 40 then wrapW = 200 end
    layoutSparkBars(row.bars, row.wrap, valuesByKey[row.key] or {}, wrapW, TREND_SPARK_BAR_MAX_H, TREND_SPARK_MAX_BARS)
    if latest then
      if row.key == "dps" then row.latest:SetText(fmtDps(latest.dps))
      elseif row.key == "crit" then row.latest:SetText(fmtPct(latest.crit))
      else row.latest:SetText(fmtPct(latest.weave)) end
    else
      row.latest:SetText("—")
    end
  end

  -- Comparison table
  local headers, rows = buildComparisonTable(COMP_COLS)
  for c = 1, COMP_COLS do
    local hdr = ui.compHdr[c]
    if hdr then
      if headers[c] then
        hdr:SetHidden(false)
        hdr:SetText(headers[c])
      else
        hdr:SetText("")
        hdr:SetHidden(true)
      end
    end
  end
  for r = 1, COMP_METRICS do
    local row = ui.compRows[r]
    local data = rows[r]
    if row then
      if data then
        row.label:SetHidden(false)
        row.label:SetText(data.label or "")
        for c = 1, COMP_COLS do
          local cell = row.cells[c]
          if cell then
            if data.cells and data.cells[c] then
              cell:SetHidden(false)
              cell:SetText(data.cells[c])
            else
              cell:SetText("")
              cell:SetHidden(true)
            end
          end
        end
      else
        row.label:SetHidden(true)
        for c = 1, COMP_COLS do
          if row.cells[c] then row.cells[c]:SetHidden(true) end
        end
      end
    end
  end
end

---------------------------------------------------------------------
-- Dashboard (2-col fight + build)
---------------------------------------------------------------------
local function createDashboardUI(screen)
  if screen.dashboardUI and screen.dashboardUI.panel then return screen.dashboardUI end
  ensureContentHost(screen)
  local panel = screen.contentPanels and screen.contentPanels.dashboard
  if not panel then return nil end

  local dash = {
    panel = panel,
    cols = {},
    topSkills = {},
    barIcons = { front = {}, back = {} },
    gearLines = {},
    rotLines = {},
  }

  for index = 1, 2 do
    local col = WM:CreateControl("DM2StatsMenuDashCol" .. index, panel, CT_CONTROL)
    local bg = makeSectionFrame(col, "DM2StatsMenuDashColBG" .. index, true)
    bg:SetAnchorFill(col)
    local title = makeDashLabel(col, "DM2StatsMenuDashColTitle" .. index, 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
    title:SetAnchor(TOPLEFT, col, TOPLEFT, 12, 10)
    title:SetText(index == 1 and "FIGHT" or "BUILD")
    dash.cols[index] = { control = col, title = title }
  end

  local col1 = dash.cols[1].control
  local col2 = dash.cols[2].control

  dash.target = makeDashLabel(col1, "DM2StatsMenuDashTarget", 22, 0.95, 0.92, 0.86, 1)
  dash.target:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 40)

  dash.meta = makeDashLabel(col1, "DM2StatsMenuDashMeta", 15, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  dash.meta:SetAnchor(TOPLEFT, dash.target, BOTTOMLEFT, 0, 4)

  dash.dummyBadge = makeDashLabel(col1, "DM2StatsMenuDashDummy", 14, 1.0, 0.88, 0.45, 1)
  dash.dummyBadge:SetAnchor(TOPLEFT, dash.meta, BOTTOMLEFT, 0, 4)

  dash.heroDps = makeDashLabel(col1, "DM2StatsMenuDashHeroDps", 32, 0.95, 0.82, 0.45, 1)
  dash.heroDps:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 110)

  dash.heroSub = makeDashLabel(col1, "DM2StatsMenuDashHeroSub", 15, THEME.textR, THEME.textG, THEME.textB, 1)
  dash.heroSub:SetAnchor(TOPLEFT, dash.heroDps, BOTTOMLEFT, 0, 4)
  dash.heroSub:SetMaxLineCount(3)

  for i = 1, 3 do
    local line = makeDashLabel(col1, "DM2StatsMenuDashRot" .. i, 14, THEME.textR, THEME.textG, THEME.textB, 1)
    line:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 210 + ((i - 1) * 22))
    dash.rotLines[i] = line
  end

  dash.sparkTitle = makeDashLabel(col1, "DM2StatsMenuDashSparkTitle", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  dash.sparkTitle:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 290)
  dash.sparkTitle:SetText("DPS OVER TIME")

  local sparkWrap, sparkBars = createSparkBarPool(col1, "DM2StatsMenuDashSpark", SPARK_MAX_BARS)
  sparkWrap:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 312)
  dash.sparkWrap = sparkWrap
  dash.sparkBars = sparkBars

  dash.skillTitle = makeDashLabel(col1, "DM2StatsMenuDashSkillTitle", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  dash.skillTitle:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 380)
  dash.skillTitle:SetText("TOP DAMAGE SKILLS")

  for i = 1, 5 do
    local row = WM:CreateControl("DM2StatsMenuDashSkillRow" .. i, col1, CT_CONTROL)
    row:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 402 + ((i - 1) * 36))
    row:SetDimensions(360, 34)
    local icon = WM:CreateControl("DM2StatsMenuDashSkillIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(DASH_TOP_SKILL_ICON, DASH_TOP_SKILL_ICON)
    icon:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 2)
    stampForeground(icon, 110)
    local nameLbl = makeDashLabel(row, "DM2StatsMenuDashSkillName" .. i, 15, THEME.textR, THEME.textG, THEME.textB, 1)
    nameLbl:SetAnchor(TOPLEFT, row, TOPLEFT, DASH_TOP_SKILL_ICON + 8, 0)
    local subLbl = makeDashLabel(row, "DM2StatsMenuDashSkillSub" .. i, 13, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
    subLbl:SetAnchor(TOPLEFT, nameLbl, BOTTOMLEFT, 0, 0)
    dash.topSkills[i] = { row = row, icon = icon, name = nameLbl, sub = subLbl }
  end

  dash.frontTitle = makeDashLabel(col2, "DM2StatsMenuDashFrontBar", 14, THEME.frontR, THEME.frontG, THEME.frontB, 1)
  dash.frontTitle:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 40)
  dash.frontTitle:SetText("FRONT BAR")

  dash.backTitle = makeDashLabel(col2, "DM2StatsMenuDashBackBar", 14, THEME.backR, THEME.backG, THEME.backB, 1)
  dash.backTitle:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 120)
  dash.backTitle:SetText("BACK BAR")

  dash.gearTitle = makeDashLabel(col2, "DM2StatsMenuDashGearTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  dash.gearTitle:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 210)
  dash.gearTitle:SetText("EQUIPPED SETS")

  for _, barKey in ipairs({ "front", "back" }) do
    local y = (barKey == "front") and 64 or 144
    for i = 1, 6 do
      local slotBg = WM:CreateControl("DM2StatsMenuDash" .. barKey .. "SlotBG" .. i, col2, CT_BACKDROP)
      slotBg:SetDimensions(BAR_ICON_SIZE + 4, BAR_ICON_SIZE + 4)
      slotBg:SetAnchor(TOPLEFT, col2, TOPLEFT, 12 + ((i - 1) * (BAR_ICON_SIZE + 8)), y)
      slotBg:SetCenterColor(0.14, 0.12, 0.09, 0.95)
      slotBg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, 0.75)
      stampBackground(slotBg, 4)
      local icon = WM:CreateControl("DM2StatsMenuDash" .. barKey .. "Icon" .. i, slotBg, CT_TEXTURE)
      icon:SetDimensions(BAR_ICON_SIZE, BAR_ICON_SIZE)
      icon:SetAnchor(CENTER, slotBg, CENTER, 0, 0)
      stampForeground(icon, 110)
      dash.barIcons[barKey][i] = { bg = slotBg, icon = icon }
    end
  end

  for i = 1, 4 do
    local line = makeDashLabel(col2, "DM2StatsMenuDashGear" .. i, 15, THEME.textR, THEME.textG, THEME.textB, 1)
    line:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 240 + ((i - 1) * 26))
    dash.gearLines[i] = line
  end

  dash.empty = makeDashLabel(panel, "DM2StatsMenuDashEmpty", 16, THEME.mutedR, THEME.mutedG, THEME.mutedB, 1)
  dash.empty:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, 20)
  dash.empty:SetHidden(true)

  screen.dashboardUI = dash
  return dash
end

local function layoutDashboardUI(screen)
  local dash = screen.dashboardUI
  if not dash or not dash.panel then return end

  local hostW, hostH = layoutContentHost(screen)
  local innerW = hostW - (CONTENT_PAD * 2)
  local colW = math.floor((innerW - DASHBOARD_COL_GAP) / 2)
  local colH = hostH - 16

  for i = 1, 2 do
    local col = dash.cols[i]
    if col and col.control then
      col.control:ClearAnchors()
      col.control:SetAnchor(TOPLEFT, dash.panel, TOPLEFT, CONTENT_PAD + ((i - 1) * (colW + DASHBOARD_COL_GAP)), 8)
      col.control:SetDimensions(colW, colH)
      if col.title then col.title:SetWidth(colW - 24) end
    end
  end

  local textW = colW - 24
  if dash.target then dash.target:SetWidth(textW) end
  if dash.meta then dash.meta:SetWidth(textW) end
  if dash.dummyBadge then dash.dummyBadge:SetWidth(textW) end
  if dash.heroDps then dash.heroDps:SetWidth(textW) end
  if dash.heroSub then dash.heroSub:SetWidth(textW) end
  for _, line in ipairs(dash.rotLines or {}) do line:SetWidth(textW) end
  if dash.sparkTitle then dash.sparkTitle:SetWidth(textW) end
  if dash.skillTitle then dash.skillTitle:SetWidth(textW) end
  if dash.sparkWrap then dash.sparkWrap:SetDimensions(textW, SPARK_BAR_MAX_H + 8) end
  if dash.empty then dash.empty:SetWidth(innerW) end

  for i = 1, 5 do
    local row = dash.topSkills[i]
    if row then
      row.row:SetWidth(textW)
      if row.name then row.name:SetWidth(textW - DASH_TOP_SKILL_ICON - 12) end
      if row.sub then row.sub:SetWidth(textW - DASH_TOP_SKILL_ICON - 12) end
    end
  end

  if dash.frontTitle then dash.frontTitle:SetWidth(textW) end
  if dash.backTitle then dash.backTitle:SetWidth(textW) end
  if dash.gearTitle then dash.gearTitle:SetWidth(textW) end
  for _, line in ipairs(dash.gearLines or {}) do line:SetWidth(textW) end
end

local function refreshDashboardUI(screen, session)
  local dash = createDashboardUI(screen)
  if not dash then return end
  layoutDashboardUI(screen)

  if not session then
    if dash.empty then
      dash.empty:SetText("History is empty — complete a parse, then reopen.")
      dash.empty:SetHidden(false)
    end
    for i = 1, 2 do
      if dash.cols[i] and dash.cols[i].control then dash.cols[i].control:SetHidden(true) end
    end
    return
  end

  if dash.empty then dash.empty:SetHidden(true) end
  for i = 1, 2 do
    if dash.cols[i] and dash.cols[i].control then dash.cols[i].control:SetHidden(false) end
  end

  local model = buildDashboardModel(session)
  if not model then return end

  dash.target:SetText(model.target)
  dash.meta:SetText(model.meta)
  dash.dummyBadge:SetText(model.isDummy and "Dummy parse" or "")
  dash.dummyBadge:SetHidden(not model.isDummy)

  dash.heroDps:SetText(model.avgDps .. " DPS")
  dash.heroSub:SetText(string.format(
    "Peak %s  ·  Total %s  ·  Crit %s\n%s",
    model.peakDps, model.totalDamage, model.critPct, model.directDot
  ))

  if dash.rotLines[1] then
    dash.rotLines[1]:SetText(string.format("Weave %s  ·  LA %s", model.weavePct, model.laHits))
  end
  if dash.rotLines[2] then dash.rotLines[2]:SetText(model.weaveDetail) end
  if dash.rotLines[3] then dash.rotLines[3]:SetText("Events  " .. model.events) end

  local colW = 360
  if dash.cols[1] and dash.cols[1].control and type(dash.cols[1].control.GetWidth) == "function" then
    colW = dash.cols[1].control:GetWidth() or colW
  end
  local values = {}
  for _, b in ipairs(model.sparkBuckets or {}) do
    values[#values + 1] = tonumber(b.dmg) or 0
  end
  layoutSparkBars(dash.sparkBars, dash.sparkWrap, values, colW - 24, SPARK_BAR_MAX_H, SPARK_MAX_BARS)

  for i = 1, 5 do
    local row = dash.topSkills[i]
    local sk = model.topSkills[i]
    if row then
      if sk then
        row.row:SetHidden(false)
        row.name:SetText(sk.name or "?")
        row.sub:SetText(sk.sub or "")
        if sk.icon then
          row.icon:SetTexture(sk.icon)
          row.icon:SetHidden(false)
        else
          row.icon:SetHidden(true)
        end
      else
        row.row:SetHidden(true)
      end
    end
  end

  refreshBarIcons(dash.barIcons.front, model.frontBar)
  refreshBarIcons(dash.barIcons.back, model.backBar)

  for i = 1, 4 do
    local line = dash.gearLines[i]
    local setName = model.gearSets[i]
    if line then
      if setName and setName ~= "" then
        line:SetText(setName)
        line:SetHidden(false)
      else
        line:SetHidden(true)
      end
    end
  end
  if #(model.gearSets or {}) == 0 and dash.gearLines[1] then
    dash.gearLines[1]:SetHidden(false)
    dash.gearLines[1]:SetText("(sets unknown — live parse will fill)")
    for i = 2, 4 do
      if dash.gearLines[i] then dash.gearLines[i]:SetHidden(true) end
    end
  end
end

local function refreshActiveContentTab(screen, tabIndex, session)
  showContentTab(screen, tabIndex)
  if tabIndex == TAB.DASHBOARD then
    refreshDashboardUI(screen, session)
  elseif tabIndex == TAB.DAMAGE then
    refreshDamageUI(screen, session)
  elseif tabIndex == TAB.WEAVE then
    refreshWeaveUI(screen, session)
  elseif tabIndex == TAB.BUFFS then
    refreshBuffsUI(screen, session)
  elseif tabIndex == TAB.GEAR then
    refreshGearUI(screen, session)
  elseif tabIndex == TAB.PROCS then
    refreshProcsUI(screen, session)
  elseif tabIndex == TAB.ROTATION then
    refreshRotationUI(screen, session)
  elseif tabIndex == TAB.HISTORY then
    refreshHistoryUI(screen)
  else
    refreshOverviewUI(screen, session)
  end
end

---------------------------------------------------------------------
-- List / entry helpers
---------------------------------------------------------------------
local function makeEntry(label, subLabel, tabIndex)
  if ZO_GamepadEntryData == nil then return nil end
  local ok, entry = pcall(function() return ZO_GamepadEntryData:New(tostring(label or "")) end)
  if not ok or not entry then return nil end
  if subLabel and subLabel ~= "" then
    if type(entry.AddSubLabel) == "function" then entry:AddSubLabel(tostring(subLabel))
    elseif type(entry.SetSubLabel) == "function" then entry:SetSubLabel(tostring(subLabel)) end
  end
  entry.dm2Tab = tabIndex
  return entry
end

local function refreshNavList(screen)
  local list = screen.navList
  if not list then return 0 end
  list:Clear()
  local added = 0
  for _, entry in ipairs(NAV_ENTRIES) do
    local e = makeEntry(entry.label, entry.sub, entry.tab)
    if e then
      local ok = pcall(function() list:AddEntry("ZO_GamepadMenuEntryTemplate", e) end)
      if ok then added = added + 1 end
    end
  end
  if type(list.Commit) == "function" then pcall(function() list:Commit() end) end
  if type(list.RefreshVisible) == "function" then pcall(function() list:RefreshVisible() end) end
  if added == 0 and not listPopulateWarned then
    listPopulateWarned = true
    d("|cFFAA00DM2 Stats Menu|r: nav list failed to populate.")
  end
  return added
end

local function activateNavList(screen)
  if not screen or not screen.navList then return end
  screen:SetCurrentList(screen.navList)
  layoutNavList(screen)
  if type(screen.navList.RefreshVisible) == "function" then pcall(function() screen.navList:RefreshVisible() end) end
  if type(screen.navList.Activate) == "function" then pcall(function() screen.navList:Activate() end) end
end

---------------------------------------------------------------------
-- Gamepad screen
---------------------------------------------------------------------
if type(ZO_Gamepad_ParametricList_Screen) == "table" and type(ZO_Gamepad_ParametricList_Screen.Subclass) == "function" then
  DM2StatsMenuShell_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()
else
  DM2StatsMenuShell_Gamepad = {}
end

function DM2StatsMenuShell_Gamepad:New(control)
  local obj = ZO_Object.New(self)
  obj:Initialize(control)
  return obj
end

local function getHeaderCreateMode()
  if ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE ~= nil then return ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE end
  if ZO_GAMEPAD_HEADER_TABBAR_CREATE ~= nil then return ZO_GAMEPAD_HEADER_TABBAR_CREATE end
  return true
end

function DM2StatsMenuShell_Gamepad:Initialize(control)
  self.control = control
  self.currentTab = TAB.OVERVIEW
  self._suppressNavCallback = false
  local ACTIVATE_ON_SHOW = true
  ZO_Gamepad_ParametricList_Screen.Initialize(self, control, getHeaderCreateMode(), ACTIVATE_ON_SHOW, sceneObject)
  -- MUST stay false: true steals L2/R2 for nav-list jump top/bottom and breaks fight history.
  self:SetListsUseTriggerKeybinds(false)
end

function DM2StatsMenuShell_Gamepad:OnDeferredInitialize()
  -- CRITICAL: do NOT create all content panels here.
  -- Creating 9 heavy UIs in one frame exceeds console CPU budget (1000ms) and freezes UI.
  -- Panels are lazy-created on first visit in refreshActiveContentTab.
  if self._deferredInitDone then return end
  self._deferredInitDone = true
  if not self.navList then
    self:InitializeLists()
  end
  -- Re-assert: list must not own L2/R2 (history walk).
  if type(self.SetListsUseTriggerKeybinds) == "function" then
    self:SetListsUseTriggerKeybinds(false)
  end
  ensureContentHost(self)
  self:ApplyWideLayout()
end

function DM2StatsMenuShell_Gamepad:ApplyWideLayout()
  local control = self.control
  if not control then return end
  local rootW = GuiRoot and GuiRoot:GetWidth() or 1920
  local rootH = GuiRoot and GuiRoot:GetHeight() or 1080
  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
  control:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)

  local container = self.container
  if not container and type(control.GetNamedChild) == "function" then
    container = control:GetNamedChild("Container")
  end
  if container then
    self.container = container
    container:ClearAnchors()
    container:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    container:SetDimensions(rootW, rootH)
    container:SetHidden(false)
  end
  if self.header and type(self.header.ClearAnchors) == "function" then
    self.header:ClearAnchors()
    self.header:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    if type(self.header.SetWidth) == "function" then self.header:SetWidth(rootW) end
  end
  applyDualPaneLayout(self)
  if self.currentTab == TAB.DASHBOARD then
    layoutDashboardUI(self)
  end
end

function DM2StatsMenuShell_Gamepad:RefreshHeader()
  if not self.header then return end
  local section = sectionLabelForTab(self.currentTab)
  local subtitle = "v3.7.7 menu preview  |  L2/R2 fights  |  "
    .. (headerNote ~= "" and headerNote or section)
  local headerData = {
    titleText = R.displayName or "DM2 Parse & Fight Stats",
    subtitleText = subtitle,
  }
  pcall(function()
    ZO_GamepadGenericHeader_Refresh(self.header, headerData, true)
    ZO_GamepadGenericHeader_Activate(self.header)
  end)
end

function DM2StatsMenuShell_Gamepad:SyncNavListSelection()
  local list = self.navList
  if not list or type(list.SetSelectedIndex) ~= "function" then return end
  self._suppressNavCallback = true
  pcall(function() list:SetSelectedIndex(self.currentTab or TAB.OVERVIEW) end)
  self._suppressNavCallback = false
end

function DM2StatsMenuShell_Gamepad:SelectTab(tabIndex, fromNav)
  tabIndex = tonumber(tabIndex) or TAB.OVERVIEW
  if tabIndex < TAB.OVERVIEW then tabIndex = TAB.OVERVIEW end
  if tabIndex > TAB_MAX then tabIndex = TAB_MAX end
  if self.currentTab == tabIndex and fromNav and self._contentReady then
    -- same tab re-select from stick: only ensure visible, skip full rebuild
    return
  end
  self.currentTab = tabIndex
  if self._refreshing then return end
  if not fromNav then
    self:SyncNavListSelection()
  end
  -- Tab switch: only refresh active content (lazy create that panel).
  self:_RefreshContentLight()
end

function DM2StatsMenuShell_Gamepad:InitializeLists()
  if self.navList then return end
  local screen = self
  local function setupList(list)
    list:AddDataTemplate("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
    list:SetNoItemText("No sections")
    list:SetReselectBehavior(ZO_PARAMETRIC_SCROLL_LIST_RESELECT_BEHAVIOR.RESELECT_OLD_INDEX)
    if type(list.SetOnSelectedDataChangedCallback) == "function" then
      list:SetOnSelectedDataChangedCallback(function()
        if screen._suppressNavCallback then return end
        if screen._refreshing then return end
        local idx = nil
        if type(list.GetSelectedIndex) == "function" then
          idx = list:GetSelectedIndex()
        end
        idx = tonumber(idx)
        if not idx and type(list.GetTargetData) == "function" then
          local data = list:GetTargetData()
          if data and data.dm2Tab then idx = tonumber(data.dm2Tab) end
        end
        if idx and idx >= TAB.OVERVIEW and idx <= TAB_MAX then
          screen:SelectTab(idx, true)
        end
      end)
    end
  end
  self.navList = self:AddList("Navigation", function(list) setupList(list) end)
  self:SetCurrentList(self.navList)
end

-- Light refresh: active tab only (used for nav stick / history cycle).
function DM2StatsMenuShell_Gamepad:_RefreshContentLight()
  if self._refreshing then return end
  self._refreshing = true
  local ok, err = pcall(function()
    if not self._deferredInitDone then self:OnDeferredInitialize() end
    local session = resolveSession()
    self:RefreshHeader()
    refreshActiveContentTab(self, self.currentTab or TAB.OVERVIEW, session)
    self._contentReady = true
  end)
  self._refreshing = false
  if not ok then
    d("|cFFAA00DM2 Stats Menu|r: content refresh failed: " .. tostring(err))
  end
end

-- Full refresh: nav list + active tab (open scene / history walk).
function DM2StatsMenuShell_Gamepad:RefreshContent()
  if self._refreshing then return end
  self._refreshing = true
  local ok, err = pcall(function()
    if not self._deferredInitDone then self:OnDeferredInitialize() end
    if not self._navPopulated then
      refreshNavList(self)
      self._navPopulated = true
    end
    activateNavList(self)
    self:SyncNavListSelection()
    local session = resolveSession()
    self:RefreshHeader()
    refreshActiveContentTab(self, self.currentTab or TAB.OVERVIEW, session)
    self._contentReady = true
  end)
  self._refreshing = false
  if not ok then
    d("|cFFAA00DM2 Stats Menu|r: content load failed: " .. tostring(err))
  end
end

function DM2StatsMenuShell_Gamepad:CycleHistory(delta)
  delta = tonumber(delta) or 0
  if delta == 0 then return end
  local count = historyCount()
  if count <= 0 then
    d("|cFFAA00DM2 Stats Menu|r: no fight history yet.")
    return
  end
  local nextOffset = clampHistoryOffset((historyOffset or 0) + delta, count)
  if nextOffset == historyOffset then
    if delta > 0 then d("|cFFAA00DM2 Stats Menu|r: oldest fight.")
    else d("|cFFAA00DM2 Stats Menu|r: already on latest fight.") end
    return
  end
  historyOffset = nextOffset
  self:_RefreshContentLight()
  M.RefreshKeybindStrip()
end

function DM2StatsMenuShell_Gamepad:OnBackButtonPressed()
  M.Hide()
end

function DM2StatsMenuShell_Gamepad:OnShowing()
  if ZO_Gamepad_ParametricList_Screen.OnShowing then
    pcall(function() ZO_Gamepad_ParametricList_Screen.OnShowing(self) end)
  end
  -- Lightweight setup only on the showing frame — heavy work next frame.
  self.currentTab = TAB.OVERVIEW
  historyOffset = 0
  self._navPopulated = false
  self._contentReady = false
  self._showGen = (self._showGen or 0) + 1
  local gen = self._showGen

  pcall(function() self:OnDeferredInitialize() end)
  if type(self.SetListsUseTriggerKeybinds) == "function" then
    pcall(function() self:SetListsUseTriggerKeybinds(false) end)
  end
  pcall(function() self:ApplyWideLayout() end)
  M.RefreshKeybindStrip()

  -- Spread work: next frame = nav + Overview only (lazy create one panel).
  zo_callLater(function()
    if not screenObject or screenObject._showGen ~= gen then return end
    if type(SCENE_MANAGER) ~= "table" or not SCENE_MANAGER:IsShowing(SCENE_NAME) then return end
    pcall(function()
      screenObject:ApplyWideLayout()
      screenObject:RefreshContent()
    end)
  end, 1)

  -- Layout settle only — do NOT rebuild content a third time.
  zo_callLater(function()
    if not screenObject or screenObject._showGen ~= gen then return end
    if type(SCENE_MANAGER) ~= "table" or not SCENE_MANAGER:IsShowing(SCENE_NAME) then return end
    pcall(function() screenObject:ApplyWideLayout() end)
  end, 100)
end

function DM2StatsMenuShell_Gamepad:OnHiding()
  M.ClearKeybindStrip()
  if self.header and type(ZO_GamepadGenericHeader_Deactivate) == "function" then
    pcall(function() ZO_GamepadGenericHeader_Deactivate(self.header) end)
  end
end

---------------------------------------------------------------------
-- Scene / menu entry / keybinds
---------------------------------------------------------------------
local function getGamepadControl()
  if type(GetControl) == "function" then
    local ok, control = pcall(GetControl, "DM2StatsMenuShellGamepadTopLevel")
    if ok and control then return control end
  end
  if DM2StatsMenuShellGamepadTopLevel then return DM2StatsMenuShellGamepadTopLevel end
  return nil
end

local function addMainMenuEntry()
  if menuEntryAdded or not MAIN_MENU_GAMEPAD then return end
  if ZO_GamepadEntryData == nil then return end

  local entry = ZO_GamepadEntryData:New(R.displayName or "DM2 Parse Stats", "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds")
  entry:SetIconTintOnSelection(true)
  entry:SetIconDisabledTintOnSelection(true)
  entry.data = { scene = SCENE_NAME }
  entry.id = MENU_ENTRY_ID

  local journalEntry = nil
  if type(ZO_MENU_ENTRIES) == "table" and type(ZO_MENU_MAIN_ENTRIES) == "table" then
    for _, v in ipairs(ZO_MENU_ENTRIES) do
      if v.id == ZO_MENU_MAIN_ENTRIES.JOURNAL then
        journalEntry = v
        break
      end
    end
  end
  if journalEntry and journalEntry.subMenu then
    table.insert(journalEntry.subMenu, entry)
  elseif type(ZO_MENU_ENTRIES) == "table" then
    table.insert(ZO_MENU_ENTRIES, entry)
  end
  MAIN_MENU_GAMEPAD:RefreshLists()
  MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
  menuEntryAdded = true
end

local function buildScene()
  if sceneObject then return true end
  if sceneBuildFailed then return false end
  if type(ZO_Gamepad_ParametricList_Screen) ~= "table" then
    sceneBuildFailed = true
    d("|cFFAA00DM2 Stats Menu|r: gamepad parametric screen unavailable.")
    return false
  end
  local control = getGamepadControl()
  if not control then
    sceneBuildFailed = true
    d("|cFFAA00DM2 Stats Menu|r: shell control missing (MenuShell.xml not loaded?).")
    return false
  end
  control:SetHidden(true)

  fragmentObject = ZO_FadeSceneFragment:New(control)
  fragmentObject:RegisterCallback("StateChange", function(_, newState)
    if not screenObject then return end
    if newState == SCENE_FRAGMENT_SHOWING then
      screenObject:OnShowing()
    elseif newState == SCENE_FRAGMENT_HIDING then
      screenObject:OnHiding()
    end
  end)

  sceneObject = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
  sceneObject:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
  sceneObject:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
  if type(GAMEPAD_NAV_QUADRANT_1_3_BACKGROUND_FRAGMENT) ~= "nil" then
    sceneObject:AddFragment(GAMEPAD_NAV_QUADRANT_1_3_BACKGROUND_FRAGMENT)
  else
    sceneObject:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
  end
  if type(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT) ~= "nil" then
    sceneObject:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_BACKGROUND_FRAGMENT)
  end
  if type(KEYBIND_STRIP_GAMEPAD_FRAGMENT) ~= "nil" then
    sceneObject:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
  end
  sceneObject:AddFragment(GAMEPAD_GENERIC_FOOTER_FRAGMENT)
  sceneObject:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
  sceneObject:AddFragment(FRAME_EMOTE_FRAGMENT_SOCIAL)
  sceneObject:AddFragment(fragmentObject)

  sceneObject:RegisterCallback("StateChange", function(_, newState)
    if newState == SCENE_SHOWING then
      M.RefreshKeybindStrip()
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
      M.ClearKeybindStrip()
    end
  end)

  if not screenObject then
    screenObject = DM2StatsMenuShell_Gamepad:New(control)
  end
  return true
end

local function sceneIsShowing()
  return type(SCENE_MANAGER) == "table" and SCENE_MANAGER:IsShowing(SCENE_NAME)
end

local function ensureKeybindGroup()
  if keybindGroup or type(KEYBIND_STRIP) ~= "table" then return end
  local function historyEnabled()
    return sceneIsShowing() and historyCount() > 1
  end
  keybindGroup = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
      name = "Older Fight",
      keybind = "UI_SHORTCUT_LEFT_TRIGGER",
      order = 100,
      callback = function()
        if screenObject and type(screenObject.CycleHistory) == "function" then
          screenObject:CycleHistory(1)
        end
      end,
      visible = sceneIsShowing,
      enabled = historyEnabled,
    },
    {
      name = "Newer Fight",
      keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
      order = 110,
      callback = function()
        if screenObject and type(screenObject.CycleHistory) == "function" then
          screenObject:CycleHistory(-1)
        end
      end,
      visible = sceneIsShowing,
      enabled = historyEnabled,
    },
    {
      name = "Back",
      keybind = "UI_SHORTCUT_NEGATIVE",
      order = 200,
      gamepadName = (type(GetString) == "function" and SI_GAMEPAD_BACK_OPTION ~= nil) and GetString(SI_GAMEPAD_BACK_OPTION) or "Back",
      callback = function() M.Hide() end,
      visible = sceneIsShowing,
    },
  }
end

function M.RefreshKeybindStrip()
  if type(KEYBIND_STRIP) ~= "table" then return end
  ensureKeybindGroup()
  if not keybindGroup then return end
  pcall(function() KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup) end)
  if type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
    pcall(function() KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindGroup) end)
  end
end

function M.ClearKeybindStrip()
  if keybindGroup and type(KEYBIND_STRIP) == "table" then
    pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup) end)
  end
end

function M.Hide()
  M.ClearKeybindStrip()
  if type(SCENE_MANAGER) ~= "table" then return end
  if SCENE_MANAGER:IsShowing(SCENE_NAME) then
    SCENE_MANAGER:Hide(SCENE_NAME)
    return
  end
  if type(SCENE_MANAGER.HideCurrentScene) == "function" then
    pcall(function() SCENE_MANAGER:HideCurrentScene() end)
  end
end

function M.Show()
  if not isGamepadPreferred() then
    d("|cFFAA00DM2 Stats Menu|r: gamepad/console mode required.")
    return
  end
  if not buildScene() then return end
  historyOffset = 0
  if type(SCENE_MANAGER) == "table" and type(SCENE_MANAGER.Show) == "function" then
    SCENE_MANAGER:Show(SCENE_NAME)
  end
end

function M.Initialize()
  zo_callLater(function()
    if sceneObject or buildScene() then
      addMainMenuEntry()
    end
  end, 2500)
end

function R:ShowMenu()
  M.Show()
end

function R:HideMenu()
  M.Hide()
end
