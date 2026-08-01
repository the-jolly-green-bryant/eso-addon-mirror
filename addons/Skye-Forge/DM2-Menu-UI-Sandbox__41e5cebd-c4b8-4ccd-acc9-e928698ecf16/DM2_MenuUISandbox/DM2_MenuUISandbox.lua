---------------------------------------------------------------------
-- DM2_MenuUISandbox.lua — v1.6.1
-- Gamepad menu UI proof-of-concept for DM2 Parse & Fight Stats.
-- Pattern borrowed from Battle Scrolls: ZO_Gamepad_ParametricList_Screen
-- + dedicated scene/fragment (O/back exits natively, stick scroll works).
-- v1.4.0: Native left nav rail + right content pane (port-ready shell).
-- v1.5.0: Opaque content plate, TV-safe 2-col dashboard, real trend
--         sparklines, empty bar-slot cleanup, L1/R1 section aliases.
-- v1.5.1: True dual-pane fitment — left rail = nav only, right pane =
--         metrics only, large (rail edge → near screen right).
-- v1.5.2: Plate under content (draw order), plate inset to shell chrome.
-- v1.6.0: Live F&P data bridge (read DM2_ParseFightStats history SV).
-- v1.6.1: Charcoal/bronze theme, tighter edges, L2/R2 history walk POC.
---------------------------------------------------------------------

DM2MenuUISandbox = DM2MenuUISandbox or {}
local M = DM2MenuUISandbox

M.name        = "DM2_MenuUISandbox"
M.displayName = "DM2 Menu UI Sandbox"
M.version     = "1.6.1"
M.ns          = "DM2_MenuUISandbox_SV"

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local SCENE_NAME = "dm2MenuUISandboxGamepad"
local MENU_ENTRY_ID = 99742
local PARSE_SV_NS = "DM2_ParseFightStats_SV"
local SHELL_SIDE_PAD = 28
local CONTENT_HEADER_INSET = 126
local CONTENT_FOOTER_INSET = 66
local CONTENT_PAD = 14
local NAV_CONTENT_GAP = 16
local CONTENT_PLATE_INSET = 10 -- tighter fit inside native chrome
local NAV_RAIL_FRAC = 0.24
local NAV_RAIL_MIN = 240
local NAV_RAIL_MAX = 360
local TREND_MAX_COLS = 8
local DASHBOARD_COL_GAP = 12
local BAR_ICON_SIZE = 40
local TOP_SKILL_ICON_SIZE = 30
local SPARK_MAX_BARS = 24
local SPARK_BAR_MAX_H = 48
local TREND_SPARK_MAX_BARS = 8
local TREND_SPARK_BAR_MAX_H = 36

-- Theme: charcoal canvas + warm bronze edges (less hazy blue).
local THEME = {
  plateR = 0.07, plateG = 0.06, plateB = 0.055, plateA = 0.94,
  plateEdgeR = 0.62, plateEdgeG = 0.48, plateEdgeB = 0.28, plateEdgeA = 0.72,
  railR = 0.05, railG = 0.045, railB = 0.04, railA = 0.78,
  railEdgeR = 0.50, railEdgeG = 0.40, railEdgeB = 0.24, railEdgeA = 0.45,
  cardR = 0.10, cardG = 0.09, cardB = 0.08, cardA = 0.42,
  cardEdgeR = 0.58, cardEdgeG = 0.46, cardEdgeB = 0.28, cardEdgeA = 0.55,
  titleR = 0.92, titleG = 0.78, titleB = 0.48, -- bronze titles
  accentR = 0.55, accentG = 0.78, accentB = 0.92, -- cool accent sparklines still readable
  textR = 0.94, textG = 0.93, textB = 0.90,
  mutedR = 0.72, mutedG = 0.70, mutedB = 0.66,
}

local historyOffset = 0 -- 0 = latest fight; L2 older, R2 newer (F&P-style walk)

local TAB = {
  OVERVIEW = 1,
  DASHBOARD_V2 = 2,
  SKILLS = 3,
  TRENDS = 4,
}

local NAV_ENTRIES = {
  { tab = TAB.OVERVIEW,      label = "Overview",     sub = "Encounter summary" },
  { tab = TAB.DASHBOARD_V2,  label = "Dashboard v2", sub = "Fight + build snapshot" },
  { tab = TAB.SKILLS,        label = "Skills",       sub = "Top damage skills" },
  { tab = TAB.TRENDS,        label = "Trends",       sub = "Dummy trends & history" },
}

local SPARK_LEVELS = { "_", "=", "==", "===" }

local DEMO_KPIS = {
  { label = "Fight Avg DPS", value = "42,150" },
  { label = "Peak 2s DPS", value = "68,900" },
  { label = "Crit Rate", value = "38.2%" },
  { label = "Weave Success", value = "91.4%" },
  { label = "Fight Duration", value = "3m 12s" },
  { label = "Total Damage", value = "8.1M" },
}

local DEMO_TRENDS = {
  { label = "Avg DPS", values = { 36, 39, 41, 40, 43, 45, 42, 44 } },
  { label = "Crit %", values = { 34, 35, 36, 37, 36, 38, 39, 38 } },
  { label = "Weave %", values = { 86, 88, 89, 90, 91, 90, 92, 91 } },
}

local FALLBACK_SKILLS = {
  { id = 21706, name = "Flames of Oblivion", pct = 24.1 },
  { id = 39095, name = "Eruption", pct = 18.7 },
  { id = 39028, name = "Burning Embers", pct = 16.2 },
  { id = 29091, name = "Witchfire", pct = 11.4 },
  { id = 21726, name = "Venomous Claw", pct = 9.8 },
}

-- Realistic DM2-shaped session for shell rendering tests (no DM2 code changes required).
local DEMO_SESSION = {
  lastTargetName = "Trial Dummy (*)",
  isDummy = true,
  completedAt = os.time(),
  durationMs = 192000,
  totalDamage = 8100000,
  directDamage = 5200000,
  dotDamage = 2900000,
  hitCount = 842,
  critCount = 322,
  eventCount = 842,
  weave = { onTimeCount = 41, lateCount = 6, missedCount = 3, tooFastCount = 2, laHits = 84 },
  equippedSets = { "5pc Mother's Sorrow", "5pc False God's Devotion", "2pc Slimecraw" },
  slottedAbilityBySlot = {
    ["Front:3"] = { id = 21706, name = "Flames of Oblivion" },
    ["Front:4"] = { id = 39095, name = "Eruption" },
    ["Front:5"] = { id = 39028, name = "Burning Embers" },
    ["Front:6"] = { id = 29091, name = "Witchfire" },
    ["Front:7"] = { id = 21726, name = "Venomous Claw" },
    ["Front:8"] = { id = 31816, name = "Standard of Might" },
    ["Back:3"] = { id = 39012, name = "Elemental Blockade" },
    ["Back:4"] = { id = 21706, name = "Flames of Oblivion" },
    ["Back:5"] = { id = 39028, name = "Burning Embers" },
    ["Back:6"] = { id = 29091, name = "Witchfire" },
    ["Back:7"] = { id = 21726, name = "Venomous Claw" },
    ["Back:8"] = { id = 15957, name = "Magma Shell" },
  },
  skills = {
    { id = 21706, name = "Flames of Oblivion", dmg = 1950000, hits = 48 },
    { id = 39095, name = "Eruption", dmg = 1510000, hits = 22 },
    { id = 39028, name = "Burning Embers", dmg = 1310000, hits = 36 },
    { id = 29091, name = "Witchfire", dmg = 920000, hits = 18 },
    { id = 21726, name = "Venomous Claw", dmg = 790000, hits = 14 },
  },
  buckets = {
    [1] = { dmg = 128400 }, [2] = { dmg = 137800 }, [3] = { dmg = 142100 },
    [4] = { dmg = 138900 }, [5] = { dmg = 145600 }, [6] = { dmg = 141200 },
    [7] = { dmg = 149800 }, [8] = { dmg = 136500 }, [9] = { dmg = 143200 },
    [10] = { dmg = 151000 }, [11] = { dmg = 139400 }, [12] = { dmg = 146800 },
  },
}

local DEMO_HISTORY = {
  {
    lastTargetName = "Trial Dummy (*)", isDummy = true,
    completedAt = os.time() - 3600, durationMs = 188000, totalDamage = 7900000,
    hitCount = 820, critCount = 305,
    weave = { onTimeCount = 39, lateCount = 7, missedCount = 4, tooFastCount = 2 },
  },
  {
    lastTargetName = "Bloodrake", isDummy = false,
    completedAt = os.time() - 86400, durationMs = 94000, totalDamage = 2100000,
    hitCount = 410, critCount = 148,
    weave = { onTimeCount = 22, lateCount = 5, missedCount = 6, tooFastCount = 1 },
  },
  {
    lastTargetName = "Trial Dummy (*)", isDummy = true,
    completedAt = os.time() - 172800, durationMs = 195000, totalDamage = 8050000,
    hitCount = 850, critCount = 318,
    weave = { onTimeCount = 40, lateCount = 6, missedCount = 3, tooFastCount = 2 },
  },
}

local SV = nil
local screenObject = nil
local sceneObject = nil
local fragmentObject = nil
local menuEntryAdded = false
local sceneBuildFailed = false
local keybindGroup = nil
local listPopulateWarned = false

local function isGamepadPreferred()
  if type(IsInGamepadPreferredMode) == "function" then return IsInGamepadPreferredMode() end
  if type(IsInGamepadMode) == "function" then return IsInGamepadMode() end
  if type(IsConsoleUI) == "function" then return IsConsoleUI() end
  if type(ZO_IsConsoleUI) == "function" then return ZO_IsConsoleUI() end
  return false
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
      return zo_strformat("<<1>>", name)
    end
  end
  return string.format("Skill %d", abilityId)
end

local function samplePlayerSkills()
  local rows = {}
  if type(GetSlotBoundId) == "function" and type(HOTBAR_CATEGORY_PRIMARY) ~= "nil" then
    for slot = 3, 7 do
      local ok, abilityId = pcall(GetSlotBoundId, slot, HOTBAR_CATEGORY_PRIMARY)
      abilityId = ok and tonumber(abilityId) or 0
      if abilityId > 0 then
        table.insert(rows, {
          id = abilityId,
          name = getAbilityName(abilityId),
          pct = math.max(6, 28 - (#rows * 4)),
        })
      end
    end
  end
  if #rows == 0 then
    for _, sk in ipairs(FALLBACK_SKILLS) do
      table.insert(rows, { id = sk.id, name = sk.name, pct = sk.pct })
    end
  end
  return rows
end

local function buildSparkText(values)
  local maxVal = 1
  for _, v in ipairs(values) do
    if v > maxVal then maxVal = v end
  end
  local parts = {}
  for i, v in ipairs(values) do
    local idx = zo_clamp(math.floor((v / maxVal) * #SPARK_LEVELS), 1, #SPARK_LEVELS)
    parts[i] = SPARK_LEVELS[idx]
  end
  return table.concat(parts, " ")
end

---------------------------------------------------------------------
-- DM2 parse vignette bridge (reads DM2_ParseFightStats_SV when present)
---------------------------------------------------------------------
local parseDataSource = "demo"
local parseBridgeNote = ""

local function fmtInt(n)
  n = tonumber(n) or 0
  n = math.floor(n + 0.5)
  if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(n) end
  return tostring(n)
end

local function fmtDps(dps)
  dps = tonumber(dps) or 0
  if dps < 0 then dps = 0 end
  if dps >= 1000000 then
    return string.format("%.2fm", dps / 1000000)
  elseif dps >= 1000 then
    return string.format("%.1fk", dps / 1000)
  end
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

local function isParseAddonLoaded()
  if DM2Stats ~= nil then return true end
  if type(GetAddOnMetadata) ~= "function" then return false end
  local version = GetAddOnMetadata("DM2_ParseFightStats", "Version")
  return version ~= nil and version ~= ""
end

local function isSessionRecord(session)
  if type(session) ~= "table" then return false end
  -- Live F&P sessions always have duration and damage after finalize.
  local dmg = tonumber(session.totalDamage)
  local dur = tonumber(session.durationMs)
  if dmg and dmg > 0 then return true end
  if dur and dur > 0 and dmg then return true end
  return false
end

local function looksLikeParseSV(t)
  if type(t) ~= "table" then return false end
  if type(t.history) == "table" then return true end
  if tonumber(t.lastIndex) ~= nil then return true end
  if type(t.settings) == "table" and (t.settings.historyMax or t.settings.bucketMs) then
    return true
  end
  return false
end

-- ZO_SavedVars nests as Default → account → $AccountWide → data.
-- Raw global is NOT the same table as ParseFightStats' local SV.
local function findNestedParseSV(root, depth)
  depth = (depth or 0) + 1
  if depth > 5 or type(root) ~= "table" then return nil end
  if looksLikeParseSV(root) and (type(root.history) == "table" or tonumber(root.lastIndex)) then
    return root
  end
  for k, v in pairs(root) do
    if type(v) == "table" and k ~= "__index" then
      if looksLikeParseSV(v) and (type(v.history) == "table" or tonumber(v.lastIndex)) then
        return v
      end
      local found = findNestedParseSV(v, depth)
      if found then return found end
    end
  end
  return nil
end

local function ensureParseSV(sv)
  if not sv or type(sv) ~= "table" then return nil end
  sv.settings = sv.settings or {}
  if sv.settings.historyMax == nil then sv.settings.historyMax = 20 end
  if sv.settings.bucketMs == nil then sv.settings.bucketMs = 2000 end
  sv.history = sv.history or {}
  if sv.lastIndex == nil then sv.lastIndex = 0 end
  return sv
end

local _parseSVCache = nil
local _parseSVCacheAt = 0

local function getParseSV()
  -- Cache briefly so tab switches don't re-walk the SV tree every frame.
  local now = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
  if _parseSVCache and (now - _parseSVCacheAt) < 2000 then
    return _parseSVCache
  end

  local sv = nil

  -- 1) Preferred: join same account-wide SV ParseFightStats owns.
  if isParseAddonLoaded() and type(ZO_SavedVars) == "table" and type(ZO_SavedVars.NewAccountWide) == "function" then
    local ok, joined = pcall(function()
      return ZO_SavedVars:NewAccountWide(PARSE_SV_NS, 1, nil, {
        settings = { historyMax = 20, bucketMs = 2000 },
        history = {},
        lastIndex = 0,
        ui = {},
      })
    end)
    if ok and type(joined) == "table" and looksLikeParseSV(joined) then
      sv = joined
    end
  end

  -- 2) Walk raw global root if join failed or returned shell without history.
  if not sv or (tonumber(sv.lastIndex) or 0) <= 0 then
    local root = rawget(_G, PARSE_SV_NS)
    if root == nil and type(DM2_ParseFightStats_SV) == "table" then
      root = DM2_ParseFightStats_SV
    end
    if type(root) == "table" then
      if looksLikeParseSV(root) and type(root.history) == "table" then
        sv = root
      else
        local nested = findNestedParseSV(root, 0)
        if nested then sv = nested end
      end
    end
  end

  sv = ensureParseSV(sv)
  _parseSVCache = sv
  _parseSVCacheAt = now
  return sv
end

local function getHistoryRecord(sv, slot)
  if not sv or not sv.history then return nil end
  local rec = sv.history[slot]
  if rec == nil then rec = sv.history[tostring(slot)] end
  if rec == nil and type(slot) == "string" then rec = sv.history[tonumber(slot)] end
  return rec
end

local function buildSortedHistory(sv)
  local arr = {}
  for _, session in pairs(sv and sv.history or {}) do
    if isSessionRecord(session) then
      table.insert(arr, session)
    end
  end
  table.sort(arr, function(a, b)
    local ta = tonumber(a.completedAt or a.endEpoch or a.timestamp) or 0
    local tb = tonumber(b.completedAt or b.endEpoch or b.timestamp) or 0
    if ta == tb then
      return (tonumber(a.totalDamage) or 0) > (tonumber(b.totalDamage) or 0)
    end
    return ta > tb
  end)
  return arr
end

-- Match DM2_ParseFightStats ring-buffer semantics exactly.
local function getParseHistoryCount(sv)
  if not sv then return 0 end
  local max = tonumber(sv.settings and sv.settings.historyMax) or 20
  if max < 1 then max = 20 end
  local idx = tonumber(sv.lastIndex) or 0
  if idx > 0 then return math.min(idx, max) end

  local n = 0
  for _, session in pairs(sv.history or {}) do
    if isSessionRecord(session) then n = n + 1 end
  end
  return n
end

local function getParseHistoryAt(sv, offsetFromLatest)
  offsetFromLatest = tonumber(offsetFromLatest) or 0
  if not sv then return nil end
  local max = tonumber(sv.settings and sv.settings.historyMax) or 20
  if max < 1 then max = 20 end
  local idx = tonumber(sv.lastIndex) or 0

  if idx > 0 then
    local latestSlot = ((idx - 1) % max) + 1
    local slot = latestSlot - offsetFromLatest
    while slot < 1 do slot = slot + max end
    while slot > max do slot = slot - max end
    local session = getHistoryRecord(sv, slot)
    if isSessionRecord(session) then return session end
    -- Slot empty (partial ring): fall through to sorted scan.
  end

  local sorted = buildSortedHistory(sv)
  return sorted[offsetFromLatest + 1]
end

local function getWeaveSuccessRatio(session)
  if not session or not session.weave then return 0 end
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
  if not w then return 0 end
  return tonumber(w.laCount) or tonumber(w.laPressCount) or tonumber(w.laHits) or 0
end

-- Light normalize so UI code can treat live + demo the same.
local function normalizeSession(session)
  if not session then return nil end
  session.eventCount = session.eventCount or session.hitCount
  if session.weave then
    session.weave.laHits = sessionLaHits(session)
  end
  if type(session.equippedSets) ~= "table" then
    session.equippedSets = session.equippedSets or {}
  end
  return session
end

local function sessionAvgDps(session)
  local dur = tonumber(session and session.durationMs) or 0
  if dur <= 0 then return 0 end
  return (tonumber(session.totalDamage) or 0) / (dur / 1000)
end

local function sessionPeakDps(session, sv)
  local bucketMs = tonumber(sv and sv.settings and sv.settings.bucketMs) or 2000
  if bucketMs <= 0 then bucketMs = 2000 end
  local peak = 0
  for _, b in pairs(session and session.buckets or {}) do
    local dps = (tonumber(b.dmg) or 0) / (bucketMs / 1000)
    if dps > peak then peak = dps end
  end
  if peak <= 0 then
    peak = tonumber(session and session.maxHit) or 0
  end
  return peak
end

local function sessionCritPct(session)
  local hits = tonumber(session and session.hitCount) or 0
  if hits <= 0 then return 0 end
  return (tonumber(session.critCount) or 0) / hits
end

local function formatSessionTimestampShort(session)
  local ts = session and (session.completedAt or session.endEpoch or session.timestamp)
  ts = tonumber(ts)
  if not ts or ts <= 0 then return "-" end
  return os.date("%m/%d %H:%M", ts)
end

local function collectDummyTrendParses(sv, maxCols, allowDemoFallback)
  maxCols = tonumber(maxCols) or TREND_MAX_COLS
  local arr = {}
  local count = sv and getParseHistoryCount(sv) or 0
  for offset = 0, count - 1 do
    local s = getParseHistoryAt(sv, offset)
    if s and s.isDummy then
      local dur = tonumber(s.durationMs) or 0
      local hits = tonumber(s.hitCount) or 0
      table.insert(arr, {
        dps = dur > 0 and ((tonumber(s.totalDamage) or 0) / (dur / 1000)) or 0,
        crit = hits > 0 and ((tonumber(s.critCount) or 0) / hits) or 0,
        weave = getWeaveSuccessRatio(s),
        session = s,
      })
      if #arr >= maxCols then break end
    end
  end
  if #arr == 0 and allowDemoFallback ~= false and (not sv or count <= 0) then
    table.insert(arr, {
      dps = sessionAvgDps(DEMO_SESSION),
      crit = sessionCritPct(DEMO_SESSION),
      weave = getWeaveSuccessRatio(DEMO_SESSION),
      session = DEMO_SESSION,
    })
    for _, s in ipairs(DEMO_HISTORY) do
      if s.isDummy then
        local dur = tonumber(s.durationMs) or 0
        local hits = tonumber(s.hitCount) or 0
        table.insert(arr, {
          dps = dur > 0 and ((tonumber(s.totalDamage) or 0) / (dur / 1000)) or 0,
          crit = hits > 0 and ((tonumber(s.critCount) or 0) / hits) or 0,
          weave = getWeaveSuccessRatio(s),
          session = s,
        })
      end
      if #arr >= maxCols then break end
    end
  end
  return arr
end

local function buildTopSkillRows(session, maxRows)
  maxRows = tonumber(maxRows) or 8
  local rows = {}
  if not session or not session.skills then return rows end
  local totalDamage = tonumber(session.totalDamage) or 0
  local dur = tonumber(session.durationMs) or 0
  local skillArr = {}
  for _, sk in pairs(session.skills) do
    table.insert(skillArr, sk)
  end
  table.sort(skillArr, function(a, b) return (tonumber(a.dmg) or 0) > (tonumber(b.dmg) or 0) end)
  for i = 1, math.min(maxRows, #skillArr) do
    local sk = skillArr[i]
    local dmg = tonumber(sk.dmg) or 0
    local share = totalDamage > 0 and (dmg / totalDamage) or 0
    local dps = dur > 0 and (dmg / (dur / 1000)) or 0
    local abilityId = tonumber(sk.id) or 0
    rows[i] = {
      name = sk.name or getAbilityName(abilityId),
      sub = string.format("%s share  |  %s DPS  |  %s total", fmtPct(share), fmtDps(dps), fmtInt(dmg)),
      icon = getAbilityIcon(abilityId),
      template = "ZO_GamepadItemSubEntryTemplate",
    }
  end
  return rows
end

local function buildOverviewVignette(sv, session)
  local rows = {}
  if not session then return rows end
  local target = truncateText(session.lastTargetName or "Unknown", 28)
  if session.isDummy then target = target .. " *" end
  table.insert(rows, {
    label = "Latest fight",
    sub = string.format("%s  |  %s  |  %s", target, formatSessionTimestampShort(session), fmtDur(session.durationMs)),
    template = "ZO_GamepadMenuEntryTemplate",
  })
  local directPct = (session.totalDamage or 0) > 0 and ((session.directDamage or 0) / session.totalDamage) or 0
  local dotPct = (session.totalDamage or 0) > 0 and ((session.dotDamage or 0) / session.totalDamage) or 0
  local kpis = {
    { "Fight Avg DPS", fmtDps(sessionAvgDps(session)) },
    { "Peak 2s DPS", fmtDps(sessionPeakDps(session, sv)) },
    { "Crit Rate", fmtPct(sessionCritPct(session)) },
    { "Weave Success", fmtPct(getWeaveSuccessRatio(session)) },
    { "Fight Duration", fmtDur(session.durationMs) },
    { "Total Damage", fmtInt(session.totalDamage) },
    { "Direct / DoT", string.format("%s / %s", fmtPct(directPct), fmtPct(dotPct)) },
    { "Damage Events", fmtInt(session.eventCount or session.hitCount) },
  }
  for _, kpi in ipairs(kpis) do
    table.insert(rows, { label = kpi[1], sub = kpi[2], template = "ZO_GamepadMenuEntryTemplate" })
  end
  return rows
end

local function buildTrendVignette(sv)
  local rows = {}
  local dummies = collectDummyTrendParses(sv, TREND_MAX_COLS)
  if #dummies > 0 then
    table.insert(rows, {
      label = "Dummy parse trends",
      sub = string.format("%d dummy parses (oldest left, newest right)", #dummies),
      template = "ZO_GamepadMenuEntryTemplate",
    })
    local dpsVals, critVals, weaveVals = {}, {}, {}
    for i = #dummies, 1, -1 do
      table.insert(dpsVals, math.floor(dummies[i].dps + 0.5))
      table.insert(critVals, math.floor(dummies[i].crit * 100 + 0.5))
      table.insert(weaveVals, math.floor(dummies[i].weave * 100 + 0.5))
    end
    table.insert(rows, {
      label = "Avg DPS",
      sub = string.format("%s   latest: %s", buildSparkText(dpsVals), fmtDps(dummies[1].dps)),
      template = "ZO_GamepadMenuEntryTemplate",
    })
    table.insert(rows, {
      label = "Crit %",
      sub = string.format("%s   latest: %s", buildSparkText(critVals), fmtPct(dummies[1].crit)),
      template = "ZO_GamepadMenuEntryTemplate",
    })
    table.insert(rows, {
      label = "Weave %",
      sub = string.format("%s   latest: %s", buildSparkText(weaveVals), fmtPct(dummies[1].weave)),
      template = "ZO_GamepadMenuEntryTemplate",
    })
  end

  local count = sv and getParseHistoryCount(sv) or 0
  if count > 0 then
    table.insert(rows, {
      label = "Recent fights",
      sub = string.format("%d stored parses", count),
      template = "ZO_GamepadMenuEntryTemplate",
    })
    for offset = 0, math.min(count - 1, 5) do
      local s = getParseHistoryAt(sv, offset)
      if s then
        local target = truncateText(s.lastTargetName or "?", 22)
        if s.isDummy then target = target .. " *" end
        table.insert(rows, {
          label = string.format("#%d  %s", count - offset, target),
          sub = string.format("%s  |  %s DPS  |  %s", formatSessionTimestampShort(s), fmtDps(sessionAvgDps(s)), fmtDur(s.durationMs)),
          template = "ZO_GamepadMenuEntryTemplate",
        })
      end
    end
  elseif #rows == 0 then
    table.insert(rows, {
      label = "Recent fights (demo)",
      sub = "Sample history rows for layout testing",
      template = "ZO_GamepadMenuEntryTemplate",
    })
    for i, s in ipairs(DEMO_HISTORY) do
      local target = truncateText(s.lastTargetName or "?", 22)
      if s.isDummy then target = target .. " *" end
      table.insert(rows, {
        label = string.format("#%d  %s", #DEMO_HISTORY - i + 1, target),
        sub = string.format("%s  |  %s DPS  |  %s", formatSessionTimestampShort(s), fmtDps(sessionAvgDps(s)), fmtDur(s.durationMs)),
        template = "ZO_GamepadMenuEntryTemplate",
      })
    end
  end
  return rows
end

local function buildDemoTrendVignette()
  local demoSv = { settings = { historyMax = 20, bucketMs = 2000 } }
  return buildTrendVignette(demoSv)
end

local function buildDemoVignettes()
  local demoSv = { settings = { historyMax = 20, bucketMs = 2000 } }
  return {
    overview = buildOverviewVignette(demoSv, DEMO_SESSION),
    skills = buildTopSkillRows(DEMO_SESSION, 8),
    trends = buildDemoTrendVignette(),
  }
end

local function clampHistoryOffset(offset, count)
  offset = tonumber(offset) or 0
  count = tonumber(count) or 0
  if count <= 0 then return 0 end
  if offset < 0 then offset = 0 end
  if offset > count - 1 then offset = count - 1 end
  return offset
end

local function describeBridgeState(sv, count, session, offset)
  local loaded = isParseAddonLoaded()
  local ver = ""
  if type(GetAddOnMetadata) == "function" then
    ver = GetAddOnMetadata("DM2_ParseFightStats", "Version") or ""
  end
  offset = tonumber(offset) or 0
  if count > 0 and session then
    local target = truncateText(session.lastTargetName or "fight", 16)
    local tag = session.isDummy and "dummy" or "world"
    local fightNo = count - offset
    if fightNo < 1 then fightNo = 1 end
    local when = (offset == 0) and "latest" or string.format("#%d/%d", fightNo, count)
    return string.format("LIVE F&P v%s · %s %s (%s) · L2/R2 history",
      ver ~= "" and ver or "?", when, target, tag)
  end
  if not loaded then
    return "DEMO · enable DM2 Parse & Fight Stats for live data"
  end
  if not sv then
    return "DEMO · F&P loaded but SV not found (reload UI)"
  end
  if count <= 0 then
    return string.format("DEMO · F&P v%s loaded, no stored fights yet", ver ~= "" and ver or "?")
  end
  return string.format("DEMO · F&P history unreadable (%d index)", count)
end

local function resolveVignetteData()
  local sv = getParseSV()
  local count = getParseHistoryCount(sv)
  historyOffset = clampHistoryOffset(historyOffset, count)
  local session = count > 0 and getParseHistoryAt(sv, historyOffset) or nil
  session = normalizeSession(session)

  if count > 0 and session then
    parseDataSource = "live"
    parseBridgeNote = describeBridgeState(sv, count, session, historyOffset)
    return sv, session, {
      overview = buildOverviewVignette(sv, session),
      skills = buildTopSkillRows(session, 8),
      trends = buildTrendVignette(sv),
    }
  end

  parseDataSource = "demo"
  historyOffset = 0
  parseBridgeNote = describeBridgeState(sv, count, session, 0)
  return nil, normalizeSession(DEMO_SESSION) or DEMO_SESSION, buildDemoVignettes()
end

local function makeEntry(label, subLabel, icon)
  if ZO_GamepadEntryData == nil then return nil end
  label = tostring(label or "")
  local ok, entry = pcall(function() return ZO_GamepadEntryData:New(label, icon) end)
  if not ok or not entry then return nil end
  if subLabel and subLabel ~= "" then
    subLabel = tostring(subLabel)
    if type(entry.AddSubLabel) == "function" then
      entry:AddSubLabel(subLabel)
    elseif type(entry.SetSubLabel) == "function" then
      entry:SetSubLabel(subLabel)
    end
  end
  return entry
end

local function addListEntry(list, template, label, subLabel, icon)
  if not list or not template then return false end
  local entry = makeEntry(label, subLabel, icon)
  if not entry then return false end
  local ok = pcall(function() list:AddEntry(template, entry) end)
  return ok
end

local function refreshListControl(list)
  if not list then return end
  if type(list.RefreshVisible) == "function" then
    pcall(function() list:RefreshVisible() end)
  end
  if type(list.Commit) == "function" then
    pcall(function() list:Commit() end)
  end
end

---------------------------------------------------------------------
-- Content host — tab bodies render here (not in the left parametric list)
---------------------------------------------------------------------
local function dashFont(size)
  return string.format("$(BOLD_FONT)|$(KB_%d)|thick-outline:6;soft-shadow-thick", size)
end

local function stampBackground(ctrl, level)
  if not ctrl then return end
  level = tonumber(level) or 0
  -- Stay under text: prefer BACKGROUND, never force OVERLAY on canvases.
  if type(ctrl.SetDrawLayer) == "function" then
    if type(DL_BACKGROUND) ~= "nil" then
      ctrl:SetDrawLayer(DL_BACKGROUND)
    elseif type(DL_CONTROLS) ~= "nil" then
      ctrl:SetDrawLayer(DL_CONTROLS)
    end
  end
  if type(ctrl.SetDrawTier) == "function" then
    if type(DT_LOW) ~= "nil" then
      ctrl:SetDrawTier(DT_LOW)
    elseif type(DT_MEDIUM) ~= "nil" then
      ctrl:SetDrawTier(DT_MEDIUM)
    end
  end
  if type(ctrl.SetDrawLevel) == "function" then
    ctrl:SetDrawLevel(level)
  end
end

local function stampForeground(ctrl, level)
  if not ctrl then return end
  level = tonumber(level) or 100
  if type(ctrl.SetDrawLayer) == "function" then
    if type(DL_TEXT) ~= "nil" then
      ctrl:SetDrawLayer(DL_TEXT)
    elseif type(DL_CONTROLS) ~= "nil" then
      ctrl:SetDrawLayer(DL_CONTROLS)
    end
  end
  if type(ctrl.SetDrawTier) == "function" then
    if type(DT_HIGH) ~= "nil" then
      ctrl:SetDrawTier(DT_HIGH)
    elseif type(DT_MEDIUM) ~= "nil" then
      ctrl:SetDrawTier(DT_MEDIUM)
    end
  end
  if type(ctrl.SetDrawLevel) == "function" then
    ctrl:SetDrawLevel(level)
  end
end

local function makeSectionFrame(parent, name, solid)
  local bg = WM:CreateControl(name, parent, CT_BACKDROP)
  if solid then
    bg:SetCenterColor(THEME.cardR, THEME.cardG, THEME.cardB, THEME.cardA)
    bg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, THEME.cardEdgeA)
  else
    bg:SetCenterColor(THEME.cardR, THEME.cardG, THEME.cardB, THEME.cardA * 0.55)
    bg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, THEME.cardEdgeA * 0.7)
  end
  bg:SetInsets(2, 2, -2, -2)
  stampBackground(bg, 2)
  return bg
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

local function makeTitleLabel(parent, name, size)
  return makeDashLabel(parent, name, size or 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
end

local function sparkColorForRatio(ratio)
  -- Warm-forward spark colors (bronze/amber/green) for charcoal theme.
  if ratio > 0.72 then return 0.45, 0.88, 0.48, 0.94 end
  if ratio > 0.42 then return 0.92, 0.72, 0.32, 0.92 end
  return 0.88, 0.38, 0.30, 0.90
end

local function layoutSparkBars(bars, wrap, values, wrapW, maxH, maxBars)
  maxH = maxH or SPARK_BAR_MAX_H
  maxBars = maxBars or SPARK_MAX_BARS
  local count = math.min(#values, maxBars, #(bars or {}))
  local maxVal = 1
  for i = 1, count do
    local v = tonumber(values[i]) or 0
    if v > maxVal then maxVal = v end
  end
  local barW = math.max(5, math.floor((wrapW - 4) / math.max(count, 1)) - 2)
  for i, bar in ipairs(bars or {}) do
    if i <= count then
      local v = tonumber(values[i]) or 0
      local ratio = v / maxVal
      local h = math.max(3, math.floor(ratio * maxH))
      bar:ClearAnchors()
      bar:SetDimensions(barW, h)
      bar:SetAnchor(BOTTOMLEFT, wrap, BOTTOMLEFT, (i - 1) * (barW + 2), 0)
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

local function resolveSlotIcon(abilityId)
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return nil end
  local tex = getAbilityIcon(abilityId)
  if not tex or tex == "" then return nil end
  -- Skip known invalid/placeholder markers if API returns them as paths.
  local lower = string.lower(tex)
  if string.find(lower, "question", 1, true) or string.find(lower, "unknown", 1, true) then
    return nil
  end
  return tex
end

local function collectLiveBarSlots(barLabel)
  local slots = {}
  if type(GetSlotBoundId) ~= "function" then return slots end
  local cat
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
  local hasSnapshot = session and session.slottedAbilityBySlot
  for slot = 3, 8 do
    local abilityId, name = 0, ""
    if hasSnapshot then
      local entry = session.slottedAbilityBySlot[barLabel .. ":" .. slot]
      if entry then
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
  for _, s in ipairs(slots) do if (s.id or 0) > 0 then any = true break end end
  if not any and barLabel == "Front" then
    return collectLiveBarSlots("Front")
  end
  if not any and barLabel == "Back" then
    return collectLiveBarSlots("Back")
  end
  return slots
end

local function denseSparkBuckets(session)
  local arr = {}
  for idx, b in pairs(session and session.buckets or {}) do
    table.insert(arr, { idx = tonumber(idx) or 0, dmg = tonumber(b.dmg) or 0 })
  end
  table.sort(arr, function(a, b) return a.idx < b.idx end)
  return arr
end

local function buildDashboardV2Model(sv, session)
  if not session then return nil end
  local totalDamage = tonumber(session.totalDamage) or 0
  local directPct = totalDamage > 0 and ((tonumber(session.directDamage) or 0) / totalDamage) or 0
  local dotPct = totalDamage > 0 and ((tonumber(session.dotDamage) or 0) / totalDamage) or 0
  local weave = session.weave or {}
  local target = truncateText(session.lastTargetName or "Unknown", 32)
  if session.isDummy then target = target .. " *" end
  return {
    target = target,
    meta = string.format("%s  |  %s", formatSessionTimestampShort(session), fmtDur(session.durationMs)),
    isDummy = session.isDummy == true,
    avgDps = fmtDps(sessionAvgDps(session)),
    peakDps = fmtDps(sessionPeakDps(session, sv)),
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
    gearSets = session.equippedSets or {},
    sparkBuckets = denseSparkBuckets(session),
  }
end

local function getNavListControl(screen)
  local list = screen and screen.navList
  if not list then return nil end
  return list.control or list.list or list
end

local function clampNum(v, lo, hi)
  if zo_clamp then return zo_clamp(v, lo, hi) end
  return math.max(lo, math.min(v, hi))
end

local function floorNum(v)
  if zo_floor then return zo_floor(v) end
  return math.floor(v)
end

-- Single source of truth: left rail (nav) + large right metrics pane.
local function resolveShellRects()
  local rootW = GuiRoot and GuiRoot:GetWidth() or 1920
  local rootH = GuiRoot and GuiRoot:GetHeight() or 1080
  local top = CONTENT_HEADER_INSET
  local usableH = math.max(320, rootH - top - CONTENT_FOOTER_INSET)

  local navW = floorNum(rootW * NAV_RAIL_FRAC)
  if type(ZO_GAMEPAD_CONTENT_LEFT_OFFSET) == "number" and ZO_GAMEPAD_CONTENT_LEFT_OFFSET > 120 then
    -- Prefer ZOS left-column constant when it is a true rail width, not a mid-screen offset.
    local zosW = ZO_GAMEPAD_CONTENT_LEFT_OFFSET
    if zosW < (rootW * 0.38) then
      navW = zosW
    end
  end
  navW = clampNum(navW, NAV_RAIL_MIN, NAV_RAIL_MAX)

  local navLeft = SHELL_SIDE_PAD
  local contentLeft = navLeft + navW + NAV_CONTENT_GAP
  local contentW = math.max(420, rootW - contentLeft - SHELL_SIDE_PAD)
  local contentH = usableH

  return {
    rootW = rootW,
    rootH = rootH,
    navLeft = navLeft,
    navTop = top,
    navW = navW,
    navH = usableH,
    contentLeft = contentLeft,
    contentTop = top,
    contentW = contentW,
    contentH = contentH,
  }
end

local function ensureNavRailPlate(screen)
  if screen.navRailPlate then return screen.navRailPlate end
  local parent = screen.container or screen.control
  if not parent then return nil end
  local plate = WM:CreateControl("DM2SandboxNavRailPlate", parent, CT_BACKDROP)
  plate:SetCenterColor(THEME.railR, THEME.railG, THEME.railB, THEME.railA)
  plate:SetEdgeColor(THEME.railEdgeR, THEME.railEdgeG, THEME.railEdgeB, THEME.railEdgeA)
  plate:SetInsets(2, 2, -2, -2)
  stampBackground(plate, 1)
  screen.navRailPlate = plate
  return plate
end

local function ensureContentHost(screen)
  if screen.contentHost and screen.contentPanels then return screen.contentHost, screen.contentPanels end

  local parent = screen.container or screen.control
  local host = WM:CreateControl("DM2SandboxContentHost", parent, CT_CONTROL)
  host:SetHidden(false)
  stampForeground(host, 10)

  -- Canvas UNDER metrics. Created first; background layer only; never OVERLAY.
  local plate = WM:CreateControl("DM2SandboxContentPlate", host, CT_BACKDROP)
  plate:SetCenterColor(THEME.plateR, THEME.plateG, THEME.plateB, THEME.plateA)
  plate:SetEdgeColor(THEME.plateEdgeR, THEME.plateEdgeG, THEME.plateEdgeB, THEME.plateEdgeA)
  plate:SetInsets(2, 2, -2, -2)
  local inset = CONTENT_PLATE_INSET
  plate:SetAnchor(TOPLEFT, host, TOPLEFT, inset, inset)
  plate:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, -inset, -inset)
  stampBackground(plate, 0)
  screen.contentPlate = plate

  screen.contentHost = host
  screen.contentPanels = {
    overview = WM:CreateControl("DM2SandboxOverviewPanel", host, CT_CONTROL),
    dashboard = WM:CreateControl("DM2SandboxDashboardPanel", host, CT_CONTROL),
    skills = WM:CreateControl("DM2SandboxSkillsPanel", host, CT_CONTROL),
    trends = WM:CreateControl("DM2SandboxTrendsPanel", host, CT_CONTROL),
  }
  for _, panel in pairs(screen.contentPanels) do
    panel:SetHidden(true)
    stampForeground(panel, 50)
  end
  return host, screen.contentPanels
end

local function forceControlRect(ctrl, parent, left, top, width, height)
  if not ctrl then return end
  if type(ctrl.ClearAnchors) == "function" then
    ctrl:ClearAnchors()
  end
  if type(ctrl.SetAnchor) == "function" and parent then
    ctrl:SetAnchor(TOPLEFT, parent, TOPLEFT, left, top)
  end
  if type(ctrl.SetDimensions) == "function" then
    ctrl:SetDimensions(width, height)
  else
    if type(ctrl.SetWidth) == "function" then ctrl:SetWidth(width) end
    if type(ctrl.SetHeight) == "function" then ctrl:SetHeight(height) end
  end
  if type(ctrl.SetHidden) == "function" then
    ctrl:SetHidden(false)
  end
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
    -- Pin parametric list into the left rail only (nav = sections, no metrics here).
    forceControlRect(listCtrl, parent, rect.navLeft, rect.navTop, rect.navW, rect.navH)
    stampForeground(listCtrl, 80)
  end

  -- Some gamepad list objects keep an inner scroll control that also needs width.
  local listObj = screen.navList
  if listObj then
    local inner = listObj.list
    if inner and inner ~= listCtrl and type(inner.SetWidth) == "function" then
      pcall(function()
        inner:SetWidth(rect.navW)
        if type(inner.SetHeight) == "function" then inner:SetHeight(rect.navH) end
      end)
    end
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
    -- Inset so canvas sits inside host / native bounding chrome (not overshooting sides).
    screen.contentPlate:SetAnchor(TOPLEFT, host, TOPLEFT, inset, inset)
    screen.contentPlate:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, -inset, -inset)
    screen.contentPlate:SetHidden(false)
    stampBackground(screen.contentPlate, 0)
    if type(screen.contentPlate.SetCenterColor) == "function" then
      screen.contentPlate:SetCenterColor(THEME.plateR, THEME.plateG, THEME.plateB, THEME.plateA)
      screen.contentPlate:SetEdgeColor(THEME.plateEdgeR, THEME.plateEdgeG, THEME.plateEdgeB, THEME.plateEdgeA)
    end
  end

  for _, panel in pairs(screen.contentPanels or {}) do
    panel:ClearAnchors()
    panel:SetAnchor(TOPLEFT, host, TOPLEFT, 0, 0)
    panel:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, 0, 0)
    stampForeground(panel, 50)
  end
  return rect.contentW, rect.contentH
end

local function applyDualPaneLayout(screen)
  if not screen then return end
  ensureContentHost(screen)
  layoutNavList(screen)
  layoutContentHost(screen)
end

local function refreshNavList(screen)
  local list = screen.navList
  if not list then return 0 end
  list:Clear()
  local added = 0
  for _, entry in ipairs(NAV_ENTRIES) do
    if addListEntry(list, "ZO_GamepadMenuEntryTemplate", entry.label, entry.sub, nil) then
      added = added + 1
    end
  end
  refreshListControl(list)
  if added == 0 and not listPopulateWarned then
    listPopulateWarned = true
    d("|cFFAA00DM2 Menu UI Sandbox|r: nav list rows failed to populate.")
  end
  return added
end

local function activateNavList(screen)
  if not screen or not screen.navList then return end
  screen:SetCurrentList(screen.navList)
  layoutNavList(screen)
  if type(screen.navList.RefreshVisible) == "function" then
    pcall(function() screen.navList:RefreshVisible() end)
  end
  if type(screen.navList.Activate) == "function" then
    pcall(function() screen.navList:Activate() end)
  end
end

local function showContentTab(screen, tabIndex)
  applyDualPaneLayout(screen)

  local panels = screen.contentPanels or {}
  local active = "overview"
  if tabIndex == TAB.DASHBOARD_V2 then active = "dashboard"
  elseif tabIndex == TAB.SKILLS then active = "skills"
  elseif tabIndex == TAB.TRENDS then active = "trends"
  end

  for key, panel in pairs(panels) do
    panel:SetHidden(key ~= active)
  end
  return active
end

local function createOverviewPanelUI(screen)
  if screen.overviewUI then return screen.overviewUI end
  local panels = screen.contentPanels
  local panel = panels and panels.overview
  if not panel then return nil end

  local ui = { panel = panel, kpis = {} }

  ui.card = WM:CreateControl("DM2SandboxOverviewCard", panel, CT_CONTROL)
  ui.card:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, 10)
  local cardBg = makeSectionFrame(ui.card, "DM2SandboxOverviewCardBG", true)
  cardBg:SetAnchorFill(ui.card)
  ui.cardBg = cardBg

  ui.title = makeDashLabel(ui.card, "DM2SandboxOverviewTitle", 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.card, TOPLEFT, 14, 12)
  ui.title:SetDimensions(1, 20)
  ui.title:SetText("ENCOUNTER SUMMARY")

  ui.fightLine = makeDashLabel(ui.card, "DM2SandboxOverviewFight", 22, 0.92, 0.97, 1.0, 1)
  ui.fightLine:SetAnchor(TOPLEFT, ui.card, TOPLEFT, 14, 40)
  ui.fightLine:SetDimensions(1, 28)

  ui.metaLine = makeDashLabel(ui.card, "DM2SandboxOverviewMeta", 16, 0.82, 0.88, 0.95, 1)
  ui.metaLine:SetAnchor(TOPLEFT, ui.fightLine, BOTTOMLEFT, 0, 6)
  ui.metaLine:SetDimensions(1, 22)

  for i = 1, 8 do
    local row = makeDashLabel(ui.card, "DM2SandboxOverviewKPI" .. i, 17, 0.95, 0.95, 0.95, 1)
    row:SetAnchor(TOPLEFT, ui.card, TOPLEFT, 14, 100 + ((i - 1) * 30))
    row:SetDimensions(1, 26)
    ui.kpis[i] = row
  end

  screen.overviewUI = ui
  return ui
end

local function refreshOverviewPanel(screen, sv, session)
  local ui = createOverviewPanelUI(screen)
  if not ui or not session then return end
  local hostW, hostH = layoutContentHost(screen)
  local cardW = hostW - (CONTENT_PAD * 2)
  local cardH = math.min(hostH - 20, 400)
  if ui.card then
    ui.card:SetDimensions(cardW, cardH)
  end
  local textW = cardW - 28
  ui.fightLine:SetWidth(textW)
  ui.metaLine:SetWidth(textW)
  for _, row in ipairs(ui.kpis) do row:SetWidth(textW) end

  local target = truncateText(session.lastTargetName or "Unknown", 40)
  if session.isDummy then target = target .. " *" end
  ui.fightLine:SetText(target)
  ui.metaLine:SetText(string.format("%s  |  %s", formatSessionTimestampShort(session), fmtDur(session.durationMs)))

  local directPct = (session.totalDamage or 0) > 0 and ((session.directDamage or 0) / session.totalDamage) or 0
  local dotPct = (session.totalDamage or 0) > 0 and ((session.dotDamage or 0) / session.totalDamage) or 0
  local lines = {
    string.format("Fight Avg DPS:  %s", fmtDps(sessionAvgDps(session))),
    string.format("Peak 2s DPS:  %s", fmtDps(sessionPeakDps(session, sv))),
    string.format("Crit Rate:  %s", fmtPct(sessionCritPct(session))),
    string.format("Weave Success:  %s", fmtPct(getWeaveSuccessRatio(session))),
    string.format("Fight Duration:  %s", fmtDur(session.durationMs)),
    string.format("Total Damage:  %s", fmtInt(session.totalDamage)),
    string.format("Direct / DoT:  %s / %s", fmtPct(directPct), fmtPct(dotPct)),
    string.format("Damage Events:  %s", fmtInt(session.eventCount or session.hitCount)),
  }
  for i, row in ipairs(ui.kpis) do row:SetText(lines[i] or "") end
end

local function createSkillsPanelUI(screen)
  if screen.skillsUI then return screen.skillsUI end
  local panel = screen.contentPanels and screen.contentPanels.skills
  if not panel then return nil end

  local ui = { panel = panel, rows = {} }

  ui.card = WM:CreateControl("DM2SandboxSkillsCard", panel, CT_CONTROL)
  ui.card:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, 10)
  local cardBg = makeSectionFrame(ui.card, "DM2SandboxSkillsCardBG", true)
  cardBg:SetAnchorFill(ui.card)

  ui.title = makeDashLabel(ui.card, "DM2SandboxSkillsTitle", 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, ui.card, TOPLEFT, 14, 12)
  ui.title:SetDimensions(1, 20)
  ui.title:SetText("TOP DAMAGE SKILLS")

  for i = 1, 8 do
    local row = WM:CreateControl("DM2SandboxSkillRow" .. i, ui.card, CT_CONTROL)
    row:SetAnchor(TOPLEFT, ui.card, TOPLEFT, 14, 44 + ((i - 1) * 54))
    row:SetDimensions(1, 50)
    local icon = WM:CreateControl("DM2SandboxSkillIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(42, 42)
    icon:SetAnchor(LEFT, row, LEFT, 0, 0)
    local nameLbl = makeDashLabel(row, "DM2SandboxSkillName" .. i, 18, 1, 1, 1, 1)
    nameLbl:SetAnchor(TOPLEFT, icon, TOPRIGHT, 12, 2)
    nameLbl:SetDimensions(1, 22)
    local subLbl = makeDashLabel(row, "DM2SandboxSkillSub" .. i, 14, 0.78, 0.84, 0.90, 1)
    subLbl:SetAnchor(TOPLEFT, nameLbl, BOTTOMLEFT, 0, 2)
    subLbl:SetDimensions(1, 18)
    ui.rows[i] = { row = row, icon = icon, name = nameLbl, sub = subLbl }
  end

  screen.skillsUI = ui
  return ui
end

local function refreshSkillsPanel(screen, session)
  local ui = createSkillsPanelUI(screen)
  if not ui then return end
  local hostW, hostH = layoutContentHost(screen)
  local cardW = hostW - (CONTENT_PAD * 2)
  local cardH = math.min(hostH - 20, 500)
  if ui.card then ui.card:SetDimensions(cardW, cardH) end
  local textW = cardW - 28 - 54
  for _, row in ipairs(ui.rows) do
    row.row:SetWidth(cardW - 28)
    row.name:SetWidth(textW)
    row.sub:SetWidth(textW)
  end

  local skills = buildTopSkillRows(session, 8)
  for i, rowUi in ipairs(ui.rows) do
    local sk = skills[i]
    if sk then
      rowUi.row:SetHidden(false)
      rowUi.name:SetText(sk.name or "?")
      rowUi.sub:SetText(sk.sub or "")
      if sk.icon then rowUi.icon:SetTexture(sk.icon) rowUi.icon:SetHidden(false)
      else rowUi.icon:SetHidden(true) end
    else
      rowUi.row:SetHidden(true)
    end
  end
end

local function createTrendsPanelUI(screen)
  if screen.trendsUI then return screen.trendsUI end
  local panel = screen.contentPanels and screen.contentPanels.trends
  if not panel then return nil end

  local ui = { panel = panel, metrics = {}, historyLines = {} }

  ui.title = makeDashLabel(panel, "DM2SandboxTrendsTitle", 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  ui.title:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, 12)
  ui.title:SetDimensions(1, 20)
  ui.title:SetText("DUMMY TRENDS & HISTORY")

  ui.subtitle = makeDashLabel(panel, "DM2SandboxTrendsSub", 15, 0.78, 0.84, 0.92, 1)
  ui.subtitle:SetAnchor(TOPLEFT, ui.title, BOTTOMLEFT, 0, 4)
  ui.subtitle:SetDimensions(1, 20)

  local metricDefs = {
    { key = "dps", label = "AVG DPS" },
    { key = "crit", label = "CRIT %" },
    { key = "weave", label = "WEAVE %" },
  }
  for i, def in ipairs(metricDefs) do
    local y = 56 + ((i - 1) * 86)
    local row = WM:CreateControl("DM2SandboxTrendMetric" .. i, panel, CT_CONTROL)
    row:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, y)
    row:SetDimensions(1, 78)
    local card = makeSectionFrame(row, "DM2SandboxTrendMetricBG" .. i, false)
    card:SetAnchorFill(row)
    local label = makeDashLabel(row, "DM2SandboxTrendMetricLabel" .. i, 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
    label:SetAnchor(TOPLEFT, row, TOPLEFT, 12, 8)
    label:SetText(def.label)
    local latest = makeDashLabel(row, "DM2SandboxTrendMetricLatest" .. i, 18, 0.92, 0.97, 1.0, 1)
    latest:SetAnchor(TOPRIGHT, row, TOPRIGHT, -12, 6)
    latest:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    local wrap, bars = createSparkBarPool(row, "DM2SandboxTrendSpark" .. def.key, TREND_SPARK_MAX_BARS)
    wrap:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 12, -10)
    ui.metrics[i] = { row = row, label = label, latest = latest, wrap = wrap, bars = bars, key = def.key }
  end

  ui.histTitle = makeDashLabel(panel, "DM2SandboxTrendsHistTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  ui.histTitle:SetAnchor(TOPLEFT, panel, TOPLEFT, CONTENT_PAD, 320)
  ui.histTitle:SetText("RECENT DUMMY PARSES")

  for i = 1, 5 do
    local line = makeDashLabel(panel, "DM2SandboxTrendHist" .. i, 15, 0.92, 0.94, 0.96, 1)
    line:SetAnchor(TOPLEFT, ui.histTitle, BOTTOMLEFT, 0, 6 + ((i - 1) * 24))
    line:SetDimensions(1, 22)
    ui.historyLines[i] = line
  end

  screen.trendsUI = ui
  return ui
end

local function refreshTrendsPanel(screen, sv)
  local ui = createTrendsPanelUI(screen)
  if not ui then return end
  local hostW = layoutContentHost(screen)
  local innerW = hostW - (CONTENT_PAD * 2)
  ui.subtitle:SetWidth(innerW)
  ui.histTitle:SetWidth(innerW)

  local liveCount = sv and getParseHistoryCount(sv) or 0
  local allowDemo = (liveCount <= 0)
  local dummies = collectDummyTrendParses(sv, TREND_MAX_COLS, allowDemo)
  -- Oldest → newest left-to-right for sparklines.
  local dpsVals, critVals, weaveVals = {}, {}, {}
  for i = #dummies, 1, -1 do
    table.insert(dpsVals, dummies[i].dps or 0)
    table.insert(critVals, (dummies[i].crit or 0) * 100)
    table.insert(weaveVals, (dummies[i].weave or 0) * 100)
  end

  if #dummies > 0 then
    local src = allowDemo and "demo" or "live"
    ui.subtitle:SetText(string.format("%d dummy parses (%s)  ·  oldest left → newest right", #dummies, src))
  elseif liveCount > 0 then
    ui.subtitle:SetText(string.format("No dummy parses in last %d fights — run a dummy for trends", liveCount))
  else
    ui.subtitle:SetText("No dummy parses yet")
  end

  local series = {
    dps = dpsVals,
    crit = critVals,
    weave = weaveVals,
  }
  local latestFmt = {
    dps = (#dummies > 0) and fmtDps(dummies[1].dps) or "—",
    crit = (#dummies > 0) and fmtPct(dummies[1].crit) or "—",
    weave = (#dummies > 0) and fmtPct(dummies[1].weave) or "—",
  }

  for _, metric in ipairs(ui.metrics) do
    metric.row:SetWidth(innerW)
    metric.row:SetHidden(false)
    metric.label:SetWidth(innerW * 0.45)
    metric.latest:SetWidth(innerW * 0.45)
    metric.latest:SetText("latest  " .. (latestFmt[metric.key] or "—"))
    local vals = series[metric.key] or {}
    metric.wrap:SetDimensions(innerW - 24, TREND_SPARK_BAR_MAX_H + 6)
    layoutSparkBars(metric.bars, metric.wrap, vals, innerW - 24, TREND_SPARK_BAR_MAX_H, TREND_SPARK_MAX_BARS)
  end

  -- History lines: prefer live dummy parses; show any recent fights if no dummies.
  local hist = {}
  if sv and liveCount > 0 then
    for offset = 0, math.min(liveCount - 1, 12) do
      local s = getParseHistoryAt(sv, offset)
      if s and s.isDummy then
        table.insert(hist, s)
      end
      if #hist >= 5 then break end
    end
    if #hist == 0 then
      for offset = 0, math.min(liveCount - 1, 4) do
        local s = getParseHistoryAt(sv, offset)
        if s then table.insert(hist, s) end
      end
    end
  end
  if #hist == 0 and allowDemo then
    table.insert(hist, DEMO_SESSION)
    for _, s in ipairs(DEMO_HISTORY) do
      if s.isDummy then table.insert(hist, s) end
      if #hist >= 5 then break end
    end
  end

  for i, line in ipairs(ui.historyLines) do
    line:SetWidth(innerW)
    local s = hist[i]
    if s then
      local target = truncateText(s.lastTargetName or "Fight", 22)
      if s.isDummy then target = target .. " *" end
      line:SetText(string.format(
        "#%d  %s  ·  %s DPS  ·  %s  ·  %s",
        i, target, fmtDps(sessionAvgDps(s)), fmtPct(sessionCritPct(s)), fmtDur(s.durationMs)
      ))
      line:SetHidden(false)
    else
      line:SetHidden(true)
    end
  end
end

---------------------------------------------------------------------
-- Dashboard v2 — TV-safe 2-column fight + build snapshot
---------------------------------------------------------------------
local function createDashboardV2UI(screen)
  if screen.dashboardV2 and screen.dashboardV2.panel then return screen.dashboardV2 end

  ensureContentHost(screen)
  local root = screen.contentPanels.dashboard
  local dash = { panel = nil, cols = {}, sparkBars = {}, topSkills = {}, barIcons = {}, gearLines = {}, rotLines = {} }

  local panel = root
  panel:SetHidden(true)
  dash.panel = panel

  local function makeColumn(index, titleText)
    local col = WM:CreateControl("DM2SandboxDashCol" .. index, panel, CT_CONTROL)
    local bg = makeSectionFrame(col, "DM2SandboxDashColBG" .. index, true)
    bg:SetAnchorFill(col)
    local title = makeDashLabel(col, "DM2SandboxDashColTitle" .. index, 15, THEME.titleR, THEME.titleG, THEME.titleB, 1)
    title:SetAnchor(TOPLEFT, col, TOPLEFT, 12, 10)
    title:SetDimensions(1, 20)
    title:SetText(titleText)
    dash.cols[index] = { control = col, title = title, bg = bg }
    return col
  end

  -- Col 1 = Fight/Performance (merged encounter + performance for TV width)
  -- Col 2 = Build
  local col1 = makeColumn(1, "FIGHT")
  local col2 = makeColumn(2, "BUILD")

  dash.target = makeDashLabel(col1, "DM2SandboxDashTarget", 22, 0.92, 0.97, 1.0, 1)
  dash.target:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 36)
  dash.target:SetDimensions(1, 28)

  dash.meta = makeDashLabel(col1, "DM2SandboxDashMeta", 15, 0.82, 0.88, 0.95, 1)
  dash.meta:SetAnchor(TOPLEFT, dash.target, BOTTOMLEFT, 0, 2)
  dash.meta:SetDimensions(1, 20)

  dash.dummyBadge = makeDashLabel(col1, "DM2SandboxDashDummy", 14, 1.0, 0.88, 0.45, 1)
  dash.dummyBadge:SetAnchor(TOPLEFT, dash.meta, BOTTOMLEFT, 0, 2)
  dash.dummyBadge:SetDimensions(1, 18)

  dash.heroDps = makeDashLabel(col1, "DM2SandboxDashHeroDps", 32, 0.95, 0.82, 0.45, 1)
  dash.heroDps:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 108)
  dash.heroDps:SetDimensions(1, 36)

  dash.heroSub = makeDashLabel(col1, "DM2SandboxDashHeroSub", 15, 0.90, 0.94, 0.98, 1)
  dash.heroSub:SetAnchor(TOPLEFT, dash.heroDps, BOTTOMLEFT, 0, 2)
  dash.heroSub:SetDimensions(1, 40)
  dash.heroSub:SetMaxLineCount(2)
  dash.heroSub:SetWrapMode(TEXT_WRAP_MODE_WORD)

  dash.rotLines = {}
  for i = 1, 3 do
    local line = makeDashLabel(col1, "DM2SandboxDashRot" .. i, 14, 0.88, 0.92, 0.95, 1)
    line:SetAnchor(TOPLEFT, dash.heroSub, BOTTOMLEFT, 0, 4 + ((i - 1) * 20))
    line:SetDimensions(1, 18)
    dash.rotLines[i] = line
  end

  dash.sparkTitle = makeDashLabel(col1, "DM2SandboxDashSparkTitle", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  dash.sparkTitle:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 248)
  dash.sparkTitle:SetDimensions(1, 16)
  dash.sparkTitle:SetText("DPS OVER TIME")

  local sparkWrap, sparkBars = createSparkBarPool(col1, "DM2SandboxDashSpark", SPARK_MAX_BARS)
  sparkWrap:SetAnchor(TOPLEFT, dash.sparkTitle, BOTTOMLEFT, 0, 4)
  dash.sparkWrap = sparkWrap
  dash.sparkBars = sparkBars

  dash.skillTitle = makeDashLabel(col1, "DM2SandboxDashSkillTitle", 13, THEME.titleR, THEME.titleG, THEME.titleB, 0.95)
  dash.skillTitle:SetAnchor(TOPLEFT, col1, TOPLEFT, 12, 330)
  dash.skillTitle:SetDimensions(1, 16)
  dash.skillTitle:SetText("TOP DAMAGE SKILLS")

  for i = 1, 5 do
    local row = WM:CreateControl("DM2SandboxDashSkillRow" .. i, col1, CT_CONTROL)
    row:SetAnchor(TOPLEFT, dash.skillTitle, BOTTOMLEFT, 0, 6 + ((i - 1) * 32))
    row:SetDimensions(1, 30)
    local icon = WM:CreateControl("DM2SandboxDashSkillIcon" .. i, row, CT_TEXTURE)
    icon:SetDimensions(TOP_SKILL_ICON_SIZE, TOP_SKILL_ICON_SIZE)
    icon:SetAnchor(LEFT, row, LEFT, 0, 0)
    local nameLbl = makeDashLabel(row, "DM2SandboxDashSkillName" .. i, 15, 1, 1, 1, 1)
    nameLbl:SetAnchor(TOPLEFT, icon, TOPRIGHT, 8, 0)
    nameLbl:SetDimensions(1, 16)
    local subLbl = makeDashLabel(row, "DM2SandboxDashSkillSub" .. i, 13, 0.78, 0.84, 0.90, 1)
    subLbl:SetAnchor(TOPLEFT, nameLbl, BOTTOMLEFT, 0, 0)
    subLbl:SetDimensions(1, 14)
    dash.topSkills[i] = { row = row, icon = icon, name = nameLbl, sub = subLbl }
  end

  dash.frontTitle = makeDashLabel(col2, "DM2SandboxDashFrontBar", 14, 0.55, 0.82, 0.55, 1)
  dash.frontTitle:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 38)
  dash.frontTitle:SetDimensions(1, 18)
  dash.frontTitle:SetText("FRONT BAR")

  dash.backTitle = makeDashLabel(col2, "DM2SandboxDashBackBar", 14, 0.55, 0.68, 0.88, 1)
  dash.backTitle:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 118)
  dash.backTitle:SetDimensions(1, 18)
  dash.backTitle:SetText("BACK BAR")

  dash.gearTitle = makeDashLabel(col2, "DM2SandboxDashGearTitle", 14, THEME.titleR, THEME.titleG, THEME.titleB, 1)
  dash.gearTitle:SetAnchor(TOPLEFT, col2, TOPLEFT, 12, 200)
  dash.gearTitle:SetDimensions(1, 18)
  dash.gearTitle:SetText("GEAR SETS")

  for barKey, anchorLabel in pairs({ front = dash.frontTitle, back = dash.backTitle }) do
    dash.barIcons[barKey] = {}
    for i = 1, 6 do
      local slotBg = WM:CreateControl("DM2SandboxDash" .. barKey .. "SlotBG" .. i, col2, CT_BACKDROP)
      slotBg:SetCenterColor(0.12, 0.10, 0.08, 0.92)
      slotBg:SetEdgeColor(THEME.cardEdgeR, THEME.cardEdgeG, THEME.cardEdgeB, 0.60)
      slotBg:SetAnchor(TOPLEFT, anchorLabel, BOTTOMLEFT, ((i - 1) * (BAR_ICON_SIZE + 6)), 6)
      slotBg:SetDimensions(BAR_ICON_SIZE, BAR_ICON_SIZE)
      local icon = WM:CreateControl("DM2SandboxDash" .. barKey .. "Icon" .. i, slotBg, CT_TEXTURE)
      icon:SetAnchor(CENTER, slotBg, CENTER, 0, 0)
      icon:SetDimensions(BAR_ICON_SIZE - 6, BAR_ICON_SIZE - 6)
      dash.barIcons[barKey][i] = { bg = slotBg, icon = icon }
    end
  end

  for i = 1, 4 do
    local line = makeDashLabel(col2, "DM2SandboxDashGear" .. i, 15, 0.95, 0.95, 0.95, 1)
    line:SetAnchor(TOPLEFT, dash.gearTitle, BOTTOMLEFT, 0, 8 + ((i - 1) * 24))
    line:SetDimensions(1, 22)
    dash.gearLines[i] = line
  end

  screen.dashboardV2 = dash
  return dash
end

local function layoutDashboardV2(screen)
  local dash = screen.dashboardV2
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
  -- Hide legacy third column if present from older sessions (hot reload).
  if dash.cols[3] and dash.cols[3].control then
    dash.cols[3].control:SetHidden(true)
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
  if dash.sparkWrap then
    dash.sparkWrap:SetDimensions(textW, SPARK_BAR_MAX_H + 8)
  end

  for i = 1, 5 do
    local row = dash.topSkills[i]
    if row then
      row.row:SetWidth(textW)
      if row.name then row.name:SetWidth(textW - TOP_SKILL_ICON_SIZE - 12) end
      if row.sub then row.sub:SetWidth(textW - TOP_SKILL_ICON_SIZE - 12) end
    end
  end

  if dash.frontTitle then dash.frontTitle:SetWidth(textW) end
  if dash.backTitle then dash.backTitle:SetWidth(textW) end
  if dash.gearTitle then dash.gearTitle:SetWidth(textW) end
  for _, line in ipairs(dash.gearLines or {}) do line:SetWidth(textW) end
end

local function refreshDashboardSparkline(dash, buckets, wrapW)
  local values = {}
  for _, b in ipairs(buckets or {}) do
    values[#values + 1] = tonumber(b.dmg) or 0
  end
  layoutSparkBars(dash.sparkBars, dash.sparkWrap, values, wrapW, SPARK_BAR_MAX_H, SPARK_MAX_BARS)
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
        -- Filled slot but no resolveable icon — blank chip, never show "?"
        ui.icon:SetHidden(true)
      end
    else
      if ui.bg then
        ui.bg:SetCenterColor(0.06, 0.08, 0.12, 0.80)
        ui.bg:SetEdgeColor(0.25, 0.32, 0.40, 0.40)
      end
      ui.icon:SetHidden(true)
    end
  end
end

local function refreshDashboardV2(screen, sv, session)
  local dash = createDashboardV2UI(screen)
  layoutDashboardV2(screen)
  local model = buildDashboardV2Model(sv, session)
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
  if dash.rotLines[2] then
    dash.rotLines[2]:SetText(model.weaveDetail)
  end
  if dash.rotLines[3] then
    dash.rotLines[3]:SetText("Events  " .. model.events)
  end

  local colW = dash.cols[1] and dash.cols[1].control and dash.cols[1].control:GetWidth() or 360
  refreshDashboardSparkline(dash, model.sparkBuckets, colW - 24)

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
  if #(model.gearSets or {}) == 0 then
    dash.gearLines[1]:SetHidden(false)
    dash.gearLines[1]:SetText("(sets unknown — live parse will fill)")
    for i = 2, 4 do dash.gearLines[i]:SetHidden(true) end
  end
end

local function refreshActiveContentTab(screen, tabIndex, sv, session)
  showContentTab(screen, tabIndex)
  if tabIndex == TAB.DASHBOARD_V2 then
    refreshDashboardV2(screen, sv, session)
  elseif tabIndex == TAB.SKILLS then
    refreshSkillsPanel(screen, session)
  elseif tabIndex == TAB.TRENDS then
    refreshTrendsPanel(screen, sv)
  else
    refreshOverviewPanel(screen, sv, session)
  end
end

---------------------------------------------------------------------
-- Gamepad screen (Battle Scrolls / ESO parametric list pattern)
---------------------------------------------------------------------
DM2MenuUISandbox_Gamepad = ZO_Gamepad_ParametricList_Screen:Subclass()

function DM2MenuUISandbox_Gamepad:New(control)
  local obj = ZO_Object.New(self)
  obj:Initialize(control)
  return obj
end

local function getHeaderCreateMode()
  if ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE ~= nil then
    return ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE
  end
  if ZO_GAMEPAD_HEADER_TABBAR_CREATE ~= nil then
    return ZO_GAMEPAD_HEADER_TABBAR_CREATE
  end
  return true
end

function DM2MenuUISandbox_Gamepad:Initialize(control)
  self.control = control
  self.currentTab = TAB.OVERVIEW
  self._suppressNavCallback = false

  local ACTIVATE_ON_SHOW = true
  ZO_Gamepad_ParametricList_Screen.Initialize(self, control, getHeaderCreateMode(), ACTIVATE_ON_SHOW, sceneObject)
  self:SetListsUseTriggerKeybinds(true)
end

function DM2MenuUISandbox_Gamepad:OnDeferredInitialize()
  self:InitializeLists()
  ensureContentHost(self)
  createDashboardV2UI(self)
  createOverviewPanelUI(self)
  createSkillsPanelUI(self)
  createTrendsPanelUI(self)
  self:ApplyWideLayout()
  self:RefreshHeader()
  local ok, err = pcall(function() self:RefreshCurrentList() end)
  if not ok then
    d("|cFFAA00DM2 Menu UI Sandbox|r: content panel load failed: " .. tostring(err))
  end
end

function DM2MenuUISandbox_Gamepad:ApplyWideLayout()
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
    if type(self.header.SetWidth) == "function" then
      self.header:SetWidth(rootW)
    end
  end

  -- Dual pane: left rail = section nav only; right = large metrics plate.
  applyDualPaneLayout(self)
  if self.currentTab == TAB.DASHBOARD_V2 then
    layoutDashboardV2(self)
  end
end

function DM2MenuUISandbox_Gamepad:SyncNavListSelection()
  local list = self.navList
  if not list or type(list.SetSelectedIndex) ~= "function" then return end
  self._suppressNavCallback = true
  pcall(function() list:SetSelectedIndex(self.currentTab or TAB.OVERVIEW) end)
  self._suppressNavCallback = false
end

function DM2MenuUISandbox_Gamepad:SelectTab(tabIndex, fromNav)
  tabIndex = tonumber(tabIndex) or TAB.OVERVIEW
  if tabIndex < TAB.OVERVIEW then tabIndex = TAB.OVERVIEW end
  if tabIndex > TAB.TRENDS then tabIndex = TAB.TRENDS end
  self.currentTab = tabIndex
  self:ApplyWideLayout()
  self:RefreshHeader()
  if not fromNav then
    self:SyncNavListSelection()
  end
  self:RefreshCurrentList()
end

function DM2MenuUISandbox_Gamepad:CycleTab(delta)
  delta = tonumber(delta) or 0
  if delta == 0 then return end
  local nextTab = (self.currentTab or TAB.OVERVIEW) + delta
  if nextTab < TAB.OVERVIEW then nextTab = TAB.TRENDS end
  if nextTab > TAB.TRENDS then nextTab = TAB.OVERVIEW end
  self:SelectTab(nextTab, false)
end

-- L2 = older fights (offset+), R2 = newer (offset-). Matches F&P L2/R2 history walk.
function DM2MenuUISandbox_Gamepad:CycleHistory(delta)
  delta = tonumber(delta) or 0
  if delta == 0 then return end
  local sv = getParseSV()
  local count = getParseHistoryCount(sv)
  if count <= 0 then
    d("|cFFAA00DM2 Menu UI Sandbox|r: no fight history to walk (demo mode).")
    return
  end
  local nextOffset = clampHistoryOffset((historyOffset or 0) + delta, count)
  if nextOffset == historyOffset then
    if delta > 0 then
      d("|cFFAA00DM2 Menu UI Sandbox|r: oldest fight in history.")
    else
      d("|cFFAA00DM2 Menu UI Sandbox|r: already on latest fight.")
    end
    return
  end
  historyOffset = nextOffset
  self:RefreshHeader()
  self:RefreshCurrentList()
end

function DM2MenuUISandbox_Gamepad:GetTabBarEntries()
  return {
    { text = "Overview", callback = function() self:SelectTab(TAB.OVERVIEW) end },
    { text = "Dashboard v2", callback = function() self:SelectTab(TAB.DASHBOARD_V2) end },
    { text = "Skills", callback = function() self:SelectTab(TAB.SKILLS) end },
    { text = "Trends", callback = function() self:SelectTab(TAB.TRENDS) end },
  }
end

function DM2MenuUISandbox_Gamepad:RefreshHeader()
  local subtitle = "v1.6.1 charcoal  |  L1/R1 sections  |  L2/R2 fights  |  "
    .. (parseBridgeNote ~= "" and parseBridgeNote or "demo placeholders")
  local headerData = {
    titleText = M.displayName,
    subtitleText = subtitle,
  }
  if getHeaderCreateMode() == ZO_GAMEPAD_HEADER_TABBAR_CREATE then
    headerData.tabBarEntries = self:GetTabBarEntries()
  end
  ZO_GamepadGenericHeader_Refresh(self.header, headerData, true)
  if headerData.tabBarEntries and type(ZO_GamepadGenericHeader_SetActiveTabIndex) == "function" then
    ZO_GamepadGenericHeader_SetActiveTabIndex(self.header, self.currentTab, true)
  end
  ZO_GamepadGenericHeader_Activate(self.header)
end

function DM2MenuUISandbox_Gamepad:InitializeLists()
  local screen = self
  local function setupList(list, noItemText)
    list:AddDataTemplate("ZO_GamepadMenuEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
    list:AddDataTemplate("ZO_GamepadItemSubEntryTemplate", ZO_SharedGamepadEntry_OnSetup, ZO_GamepadMenuEntryTemplateParametricListFunction)
    list:SetNoItemText(noItemText)
    list:SetReselectBehavior(ZO_PARAMETRIC_SCROLL_LIST_RESELECT_BEHAVIOR.RESELECT_OLD_INDEX)
    if type(list.SetOnSelectedDataChangedCallback) == "function" then
      list:SetOnSelectedDataChangedCallback(function()
        if screen._suppressNavCallback then return end
        local idx = nil
        if type(list.GetSelectedIndex) == "function" then
          idx = list:GetSelectedIndex()
        end
        idx = tonumber(idx)
        if idx and idx >= TAB.OVERVIEW and idx <= TAB.TRENDS then
          screen:SelectTab(idx, true)
        end
      end)
    end
  end

  self.navList = self:AddList("Navigation", function(list)
    setupList(list, "No sections")
  end)
  self:SetCurrentList(self.navList)
end

function DM2MenuUISandbox_Gamepad:RefreshCurrentList()
  if not self.contentHost then
    self:OnDeferredInitialize()
  end

  if not self._navPopulated then
    refreshNavList(self)
    self._navPopulated = true
  end
  activateNavList(self)
  self:SyncNavListSelection()

  local sv, session = resolveVignetteData()
  refreshActiveContentTab(self, self.currentTab or TAB.OVERVIEW, sv, session)
end

function DM2MenuUISandbox_Gamepad:OnBackButtonPressed()
  M:Hide()
end

function DM2MenuUISandbox_Gamepad:OnShowing()
  if ZO_Gamepad_ParametricList_Screen.OnShowing then
    pcall(function() ZO_Gamepad_ParametricList_Screen.OnShowing(self) end)
  end
  if not self.contentHost then
    self:OnDeferredInitialize()
  end
  self.currentTab = TAB.OVERVIEW
  historyOffset = 0
  self._navPopulated = false
  self:ApplyWideLayout()
  self:RefreshHeader()
  pcall(function() self:RefreshCurrentList() end)
  -- Re-apply after ZOS parametric list finishes its own anchoring.
  local function reflow()
    if screenObject and type(SCENE_MANAGER) == "table" and SCENE_MANAGER:IsShowing(SCENE_NAME) then
      pcall(function()
        screenObject:ApplyWideLayout()
        activateNavList(screenObject)
        local sv, session = resolveVignetteData()
        refreshActiveContentTab(screenObject, screenObject.currentTab or TAB.OVERVIEW, sv, session)
      end)
    end
  end
  zo_callLater(reflow, 50)
  zo_callLater(reflow, 150)
  M:RefreshKeybindStrip()
end

function DM2MenuUISandbox_Gamepad:OnHiding()
  M:ClearKeybindStrip()
  if self.header and type(ZO_GamepadGenericHeader_Deactivate) == "function" then
    pcall(function() ZO_GamepadGenericHeader_Deactivate(self.header) end)
  end
end

---------------------------------------------------------------------
-- Scene + main menu entry (Battle Scrolls journal-submenu pattern)
---------------------------------------------------------------------
local function addMainMenuEntry()
  if menuEntryAdded or not MAIN_MENU_GAMEPAD then return end

  local entry = ZO_GamepadEntryData:New(M.displayName, "EsoUI/Art/TreeIcons/Gamepad/gp_tutorial_idexIcon_combat.dds")
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

local function getGamepadControl()
  if type(GetControl) == "function" then
    local ok, control = pcall(GetControl, "DM2MenuUISandboxGamepadTopLevel")
    if ok and control then return control end
  end
  if DM2MenuUISandboxGamepadTopLevel then
    return DM2MenuUISandboxGamepadTopLevel
  end
  return nil
end

local function buildScene()
  if sceneObject then return true end
  if sceneBuildFailed then return false end

  if type(ZO_Gamepad_ParametricList_Screen) ~= "table" then
    sceneBuildFailed = true
    d("|cFFAA00DM2 Menu UI Sandbox|r: ZO_Gamepad_ParametricList_Screen unavailable on this platform.")
    return false
  end

  local control = getGamepadControl()
  if not control then
    sceneBuildFailed = true
    d("|cFFAA00DM2 Menu UI Sandbox|r: gamepad shell control missing (DM2_MenuUISandbox.xml not loaded?).")
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
      M:RefreshKeybindStrip()
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
      M:ClearKeybindStrip()
    end
  end)

  if not screenObject then
    screenObject = DM2MenuUISandbox_Gamepad:New(control)
  end

  return true
end

local function sceneIsShowing()
  return type(SCENE_MANAGER) == "table" and SCENE_MANAGER:IsShowing(SCENE_NAME)
end

local function ensureKeybindGroup()
  if keybindGroup or type(KEYBIND_STRIP) ~= "table" then return end
  keybindGroup = {
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
    {
      name = "Section Prev",
      keybind = "UI_SHORTCUT_LEFT_SHOULDER",
      order = 100,
      callback = function()
        if screenObject and type(screenObject.CycleTab) == "function" then
          screenObject:CycleTab(-1)
        end
      end,
      visible = sceneIsShowing,
    },
    {
      name = "Section Next",
      keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
      order = 110,
      callback = function()
        if screenObject and type(screenObject.CycleTab) == "function" then
          screenObject:CycleTab(1)
        end
      end,
      visible = sceneIsShowing,
    },
    {
      name = "Older Fight",
      keybind = "UI_SHORTCUT_LEFT_TRIGGER",
      order = 120,
      callback = function()
        if screenObject and type(screenObject.CycleHistory) == "function" then
          screenObject:CycleHistory(1)
        end
      end,
      visible = sceneIsShowing,
    },
    {
      name = "Newer Fight",
      keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
      order = 130,
      callback = function()
        if screenObject and type(screenObject.CycleHistory) == "function" then
          screenObject:CycleHistory(-1)
        end
      end,
      visible = sceneIsShowing,
    },
    {
      name = "Back",
      keybind = "UI_SHORTCUT_NEGATIVE",
      order = 200,
      gamepadName = (type(GetString) == "function" and SI_GAMEPAD_BACK_OPTION ~= nil) and GetString(SI_GAMEPAD_BACK_OPTION) or "Back",
      callback = function() M:Hide() end,
      visible = sceneIsShowing,
    },
  }
end

function M:RefreshKeybindStrip()
  if type(KEYBIND_STRIP) ~= "table" then return end
  ensureKeybindGroup()
  if not keybindGroup then return end
  pcall(function() KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup) end)
  if type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
    pcall(function() KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindGroup) end)
  end
end

function M:ClearKeybindStrip()
  if keybindGroup and type(KEYBIND_STRIP) == "table" then
    pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup) end)
  end
end

function M:Hide()
  self:ClearKeybindStrip()
  if type(SCENE_MANAGER) ~= "table" then return end
  if SCENE_MANAGER:IsShowing(SCENE_NAME) then
    SCENE_MANAGER:Hide(SCENE_NAME)
    return
  end
  if type(SCENE_MANAGER.HideCurrentScene) == "function" then
    pcall(function() SCENE_MANAGER:HideCurrentScene() end)
  end
end

function M:Show()
  if not isGamepadPreferred() then
    d("|cFFAA00DM2 Menu UI Sandbox|r: gamepad/console mode required for this POC.")
    return
  end
  -- Force re-resolve F&P SV each open (new parses since last open).
  _parseSVCache = nil
  _parseSVCacheAt = 0
  if not buildScene() then return end
  if type(SCENE_MANAGER) == "table" and type(SCENE_MANAGER.Show) == "function" then
    SCENE_MANAGER:Show(SCENE_NAME)
  end
end

function M:PrintBridgeStatus()
  _parseSVCache = nil
  _parseSVCacheAt = 0
  local sv = getParseSV()
  local count = getParseHistoryCount(sv)
  local session = count > 0 and normalizeSession(getParseHistoryAt(sv, 0)) or nil
  local note = describeBridgeState(sv, count, session)
  d(string.format("|c88ff88%s|r bridge: %s", M.displayName, note))
  d(string.format("  F&P loaded=%s  SV=%s  lastIndex=%s  historyMax=%s  count=%d",
    tostring(isParseAddonLoaded()),
    sv and "yes" or "no",
    sv and tostring(sv.lastIndex) or "nil",
    sv and sv.settings and tostring(sv.settings.historyMax) or "nil",
    count
  ))
  if session then
    d(string.format("  latest: %s  dps=%s  dmg=%s  dur=%s  skills=%d  dummy=%s",
      tostring(session.lastTargetName or "?"),
      fmtDps(sessionAvgDps(session)),
      fmtInt(session.totalDamage),
      fmtDur(session.durationMs),
      (function()
        local n = 0
        for _ in pairs(session.skills or {}) do n = n + 1 end
        return n
      end)(),
      tostring(session.isDummy == true)
    ))
  end
end

local function registerSlash()
  SLASH_COMMANDS["/dm2uisandbox"] = function(args)
    args = tostring(args or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if args == "bridge" or args == "status" then
      M:PrintBridgeStatus()
      return
    end
    M:Show()
  end
  SLASH_COMMANDS["/dm2menusandbox"] = function() M:Show() end
  SLASH_COMMANDS["/dm2uibridge"] = function() M:PrintBridgeStatus() end
end

local function initLAM()
  if not LibAddonMenu2 then return end

  local panelData = {
    type = "panel",
    name = M.displayName,
    displayName = M.displayName,
    author = "Skye-Forge",
    version = M.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LibAddonMenu2:RegisterAddonPanel("DM2MenuUISandboxLAM", panelData)

  LibAddonMenu2:RegisterOptionControls("DM2MenuUISandboxLAM", {
    { type = "description", text = "Native gamepad menu POC for DM2 Parse & Fight Stats. v1.6.0 reads live F&P history when available; otherwise demo placeholders." },
    {
      type = "button",
      name = "Open Gamepad Sandbox",
      tooltip = "Opens the sandbox scene (Journal menu entry on console, or use /dm2uisandbox).",
      func = function() M:Show() end,
      width = "full",
    },
    {
      type = "button",
      name = "Print Bridge Status",
      tooltip = "Chat dump: F&P SV found?, fight count, latest session summary. Or /dm2uibridge",
      func = function() M:PrintBridgeStatus() end,
      width = "full",
    },
    { type = "description", text = "Pass 2: live bridge. Header shows LIVE F&P when history is readable. /dm2uisandbox bridge for diagnostics." },
  })
end

local function onScreenResized()
  if screenObject and type(SCENE_MANAGER) == "table" and SCENE_MANAGER:IsShowing(SCENE_NAME) then
    if screenObject and type(screenObject.ApplyWideLayout) == "function" then
      pcall(function() screenObject:ApplyWideLayout() end)
    end
  end
end

function M:Initialize()
  SV = ZO_SavedVars:NewAccountWide(self.ns, 1, nil, {})
  registerSlash()
  initLAM()

  if type(EVENT_SCREEN_RESIZED) ~= "nil" then
    EM:RegisterForEvent(M.name .. "_Screen", EVENT_SCREEN_RESIZED, onScreenResized)
  end

  zo_callLater(function()
    if sceneObject or buildScene() then
      addMainMenuEntry()
    end
  end, 2000)

  d(string.format("|c88ff88%s|r v%s loaded. /dm2uisandbox  |  bridge: /dm2uibridge", self.displayName, self.version))
end

local function onAddOnLoaded(_, addonName)
  if addonName ~= M.name then return end
  EM:UnregisterForEvent(M.name, EVENT_ADD_ON_LOADED)
  M:Initialize()
end

EM:RegisterForEvent(M.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)