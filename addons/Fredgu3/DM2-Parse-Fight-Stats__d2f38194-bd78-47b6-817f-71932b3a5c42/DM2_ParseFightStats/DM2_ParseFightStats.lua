---------------------------------------------------------------------
-- DM2_ParseFightStats.lua — v3.9.0 (menu is default stats viewer; overlay optional)
-- "DM2 Parse & Fight Stats" — post-fight stats window with history
--
-- Goals (v1):
--  • Track fight sessions (outgoing damage), store history (ring buffer, default 20)
--  • 2s rolling buckets to find top 2 spikes and bottom 2 dips
--  • Crit sustain overall + per spike/dip bucket
--  • Skill damage breakdown grid (amount, hits, avg hit, crit%, dps, dot/direct split)
--  • Buff uptime grid with source hints (Skill/Set/Self/External) for player's effects
--  • Light attack weaving readout using confirmed LA-hit rhythm and interval health
--  • Slash commands: /dm2stats, /dm2statsshow, /dm2statshide, /dm2statsclear
--
-- Notes:
--  • Set attribution (armor/weapon sets) is non-trivial; v1 focuses on skill/ability IDs.
--  • LAW uses server-confirmed light attack hit timing; skill timing remains approximate.
---------------------------------------------------------------------

DM2Stats = DM2Stats or {}
local R = DM2Stats

R.name        = "DM2_ParseFightStats"
R.displayName = "DM2 Parse & Fight Stats"
R.version     = "3.9.11"

-- User-facing debug log page (slash toggles still work; set true to restore in UI)
local DEBUG_UI_ENABLED = false
local TREND_MAX_COLS = 12
local TREND_FIGHT_HEADER_H = 34
local TREND_ROW_H = 38
local COMP_FIGHT_HEADER_H = 46
local COMP_SPARKLINE_H = 30
local COMP_SPARKLINE_BARS = 10
local HISTORY_SCROLL_TOP_Y = 236
local HISTORY_CONTENT_PAD_Y = 8
local HISTORY_LIST_MAX_ROWS = 14
local HISTORY_COMP_MAX_ROWS = 8
local HISTORY_COMP_LIST_GAP = 20
local HISTORY_TREND_GAP = 14
local HISTORY_BOTTOM_PAD = 16
local LIST_BOTTOM_PAD = 16       -- space below last row so rows aren't clipped and scrollbar stays usable
local SCROLL_BOTTOM_INSET = 18   -- gap above footer (was 28; slightly taller list viewport)
local LIST_CONTENT_TAIL_PAD = 24 -- padding below scroll content (was 20)

local function trendPanelHeight()
  return 6 + 18 + 2 + 14 + 6 + TREND_FIGHT_HEADER_H + 4 + (3 * (TREND_ROW_H + 4)) + 10
end
R.ns          = "DM2_ParseFightStats_SV"

local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER

-- ----------------------------
-- Safe console UI check
-- ----------------------------
local function isConsoleUI()
  -- Console/gamepad detection differs a bit across platforms/builds.
  if type(IsConsoleUI) == "function" then return IsConsoleUI() end
  if type(ZO_IsConsoleUI) == "function" then return ZO_IsConsoleUI() end
  -- Fallback for gamepad-mode UIs (works on PC gamepad + consoles)
  if type(IsInGamepadPreferredMode) == "function" then return IsInGamepadPreferredMode() end
  if type(IsInGamepadMode) == "function" then return IsInGamepadMode() end
  return false
end

-- ----------------------------
-- Defaults / SavedVars
-- ----------------------------
R.defaults = {
  settings = {
    enable = true,
    autoPopupAfterParse = true,
    resultsPopupDelaySecs = 2, -- delay stats popup after fight ends (0-5)
    autoCloseSecs = 0,    -- 0 = never (menu uses O/back; legacy overlay optional timer)

    historyMax = 20,
    bucketMs = 2000,

    -- Heuristics
    minFightMs = 8000,      -- ignore tiny skirmishes
    minDamage = 50000,

    -- Spike detection window exclusions
    ignoreFirstMs = 2000,
    ignoreLastMs  = 1500,

    -- Weaving heuristics
    weaveFollowMs = 1500,
    weavePocketMinMs = 350,
    weavePocketMaxMs = 900,


    -- Weave detection tuning (latency-adjusted)
    weaveMinLeadMs = 30,
    weaveWindowMaxMs = 0,      -- 0 = auto (1000ms + latency pad)
    queueOverwriteMs = 450,
    -- Dummy/parse detection
    dummyStrict = false,    -- false = name OR housing; true = name AND housing
    debugRotation = false,  -- show rotation capture debug log page
    showWeaveFlash = false, -- real-time weave quality flash at screen center during combat
    weaveFlashSize = 36,    -- font size for weave flash (20-52)
    weaveFlashDuration = 500, -- flash duration in ms (200-800)
    weaveFlashSound = false,  -- play a sound cue on each weave result
    -- v3.5.0: gamepad menu shell entry in Journal (still used)
    experimentalGamepadMenu = true,
    -- v3.9.0: default stats viewer — "menu" (MenuShell) or "overlay" (legacy window)
    statsViewer = "menu",
  },
  ui = {
    x = 120,
    y = 120,
    w = 1400,
    h = 920,
    locked = false,
    bgAlpha = 0.65,   -- background opacity (0.0 = transparent, 1.0 = solid)
  },
  history = {},
  lastIndex = 0,
  lastAnnouncementVersion = "",
}

local SV = nil

-- Weave timeline symbols (ESO color markup, ASCII-safe)
local SYM_OK        = "+"       -- good weave
local SYM_LATE      = "~"       -- late weave
local SYM_MISS      = "x"       -- missed weave
local SYM_FAST      = ">>"      -- too fast
local SYM_EXTRA     = "*"       -- extra LA
local SYM_CHANNEL   = "---"     -- channel pause
local SYM_POST_OK   = "+"       -- post-channel recovered
local SYM_POST_MISS = "x"       -- post-channel missed

-- ----------------------------
-- Runtime state
-- ----------------------------
R.inCombat = false
R.session = nil
R._pendingPopupToken = 0
R._autoHideActive = false
R._autoHideEndMs = 0
R._showInteractiveHint = false
R._keybindsAdded = false
R._interactiveMode = false
R._autoHidePaused = false
R._autoHideRemainingMs = 0
R._weaveFlashToken = 0    -- debounce token for timed flash hide
R._announcementToken = 0  -- debounce token for announcement auto-dismiss

-- ----------------------------
-- Version announcements (shown once per version string at login)
-- To add a future announcement: add an entry below and update _latestAnnouncementVersion.
-- ----------------------------
R._announcements = {
  ["3.2.0"] = {
    title = "NEW: Weave Flash Training!",
    body = "Real-time Good / Late / Missed feedback flashes at\nscreen center during combat. Great for learning\nthe LA weave rhythm.\n\nEnable in addon Settings > Weave Flash.",
  },
  ["3.2.2"] = {
    title = "NEW: Visual Upgrades & Analytics!",
    body = "Pulse Strip: colored blocks show weave health at a glance.\nDPS Sparkline: bar chart of DPS over time on Summary page.\nPer-Skill Weave: see which skills you weave best/worst.\nDOT Uptime: tracks how well you maintain your DOTs.\nBar-colored skills: Front bar green, Back bar blue in timeline.",
  },
  ["3.2.7"] = {
    title = "NEW: Sound Cues, Chat Export & More!",
    body = "Weave Sound Cue: optional audio chime/alert per weave result.\nEnable in Settings > Weave Flash > Sound Cue.\n\nExport to Chat: /dm2stats share posts a parse summary.\n\nWeave Analysis: per-skill and DOT tables now on their own page.",
  },
  ["3.2.15"] = {
    title = "FIX & NEW: Set Contribution + Skill Icons!",
    body = "Null Arca / Sliver Assault now shows correctly in Set Contribution.\n\nSkill icons: the Overview Top Damage Skills table now shows ability icons.\nMore visual polish is coming in future updates.",
  },
  ["3.2.16"] = {
    title = "FIX: Top Skills Table Alignment",
    body = "Skill names were missing from the Overview Top Damage Skills table\nafter icons were added. Columns are aligned again.\n\nIcons on that table are unchanged.",
  },
  ["3.2.17"] = {
    title = "NEW: Skill Icons on More Tables!",
    body = "Ability icons now appear on:\n• Damage Breakdown\n• Buffs / Uptime\n• Weave Analysis (per-skill + DOT uptime)\n\nOverview Top Damage Skills already had icons from 3.2.15.",
  },
  ["3.2.18"] = {
    title = "FIX: UI Error on Parse Open",
    body = "Fixed a crash when opening the stats viewer after a parse.\n\nSkill icons on all tables from 3.2.17 are unchanged.",
  },
  ["3.2.19"] = {
    title = "NEW: Front / Back Bar Chips!",
    body = "Skill rows now show a small color chip:\nGreen = front bar, Blue = back bar.\n\nA legend appears above each skill table.\nMatches the timeline colors on Rotation Diagnostics.",
  },
  ["3.2.20"] = {
    title = "FIX: Back Bar Chips & Legend!",
    body = "Back bar (blue) chips now appear reliably on all skill tables,\nincluding buffs, DOTs, and damage from alternate ability IDs.\n\nLegend uses real color swatches instead of missing font glyphs.",
  },
  ["3.2.21"] = {
    title = "FIX: Combat Start Crash!",
    body = "Fixed a crash on first hit when capturing slotted ability bars.\n\nBar chips and legend from 3.2.20 are unchanged.",
  },
  ["3.2.22"] = {
    title = "FIX: Weave Skill Names [7] / [12]",
    body = "Weave Analysis no longer shows bracketed slot placeholders\nwhen the console API returns [N] instead of a skill name.\n\nNames re-resolve after the fight using the captured ability ID.",
  },
  ["3.2.23"] = {
    title = "FIX: Last Missing Weave Skill Name",
    body = "Console placeholders like [7] are no longer cached as skill names.\n\nWeave rows now fall back to the fight-start bar snapshot\n(slot + bar) when ability lookup still fails.",
  },
  ["3.3.5"] = {
    title = "NEW: Damage Share Bars!",
    body = "Contribution columns now show proportional share bars\nbehind the percentage on skill and set proc tables.\n\nOverview top skills, Damage Breakdown, Set Contribution,\nand Proc Analysis all updated.",
  },
  ["3.4.0"] = {
    title = "NEW: 3-Hub Navigation + Parse Trends!",
    body = "L1/R1 now switches 3 hubs: Overview, Combat Analysis,\nand Build & History (scroll for sub-sections).\n\nDummy parse trend chart below the comparison table.\nCircle/O closes the viewer. Debug log hidden from UI.",
  },
  ["3.4.1"] = {
    title = "FIX: Console Page Navigation Restored!",
    body = "L1/R1 again steps through all 8 sections (one page each),\nlike before 3.4.0 — works on PS5 without scrolling.\n\nKeeps: dummy parse trend chart, history list fix,\nCircle/O close, and hidden debug UI.",
  },
  ["3.4.9"] = {
    title = "FIX: List Rows No Longer Cut Off!",
    body = "List panels are slightly taller at the bottom so the last\nrow or two is not clipped with a dead scrollbar.\n\nApplies to Damage Breakdown, Buffs, Gear, and other tables.",
  },
  ["3.5.0"] = {
    title = "NEW: Experimental Gamepad Menu!",
    body = "Open stats in a native gamepad menu scene:\n/dm2stats menu  (console gamepad mode)\n\nPhase 1: Overview + L2/R2 fight history + O/back.\nExisting post-parse overlay is unchanged.",
  },
  ["3.5.1"] = {
    title = "NEW: Menu Skills + Layout Polish!",
    body = "Gamepad menu Phase 2:\n• Skills section — top damage skills with icons\n• Stick select Overview / Skills on the left rail\n• Content plate nudged right (less left-edge bleed)\n\nL2/R2 history and O/back unchanged.",
  },
  ["3.6.0"] = {
    title = "NEW: Full Gamepad Menu Review Build!",
    body = "Experimental menu now has all four sections:\n• Overview — encounter KPIs\n• Dashboard — fight + bars + gear snapshot\n• Skills — top damage with icons\n• Trends — dummy sparklines + recent list\n\nOpen: /dm2stats menu  (gamepad mode)\nL2/R2 fights · O/back · overlay unchanged.",
  },
  ["3.7.0"] = {
    title = "NEW: Full Menu Content Preview!",
    body = "Experimental gamepad menu now covers the full parse surface:\n• Overview, Dashboard, Damage, Weave, Buffs\n• Gear, Procs, Rotation, History\n\nStill preview-only (settings button / /dm2stats menu).\nPost-parse overlay is unchanged and remains the default.",
  },
  ["3.7.1"] = {
    title = "FIX: Menu Open Freeze!",
    body = "Fixed experimental gamepad menu locking up on open\n(CPU time budget exceeded while building all panels).\n\nPanels now load one-at-a-time when you select them.\nOverlay path unchanged.",
  },
  ["3.7.2"] = {
    title = "NEW: Dense Menu Overview!",
    body = "Experimental menu Overview now mirrors Summary:\nKPI tiles, rotation health, burst/drop, DPS sparkline,\nset contribution, and top skills with bar chips.\n\nStill preview-only. Overlay unchanged.",
  },
  ["3.7.3"] = {
    title = "FIX: Menu L2/R2 History + Overview Layout!",
    body = "L2/R2 again walk fight history (nav list was stealing triggers).\nOverview KPI/rotation/burst alignment and sizing polished.\n\nOverlay path unchanged.",
  },
  ["3.7.4"] = {
    title = "NEW: Dense Menu Damage + Weave!",
    body = "Experimental menu now has dense pages for:\n• Overview (Summary)\n• Damage Breakdown (skill table)\n• Weave Analysis (KPIs + per-skill + DoT)\n\nAlso: L2/R2 history walk fixed.\nStill preview-only. Overlay unchanged.",
  },
  ["3.7.5"] = {
    title = "FIX: Menu Layout + More Rows!",
    body = "Tables no longer push metrics to the far right.\nDamage shows more skills; Weave/Buffs fill height.\nGear page denser (bars + two-col worn list).\n\nPreview-only. Overlay unchanged.",
  },
  ["3.7.6"] = {
    title = "NEW: All Menu Pages Enriched!",
    body = "Experimental menu dense pages now include:\nBuffs, Procs, Gear, Rotation, History\n(plus Overview/Damage/Weave from earlier).\n\nL2/R2 history walk validated.\nStill preview-only. Overlay default.",
  },
  ["3.7.7"] = {
    title = "FIX: Rotation Colors + History Layout!",
    body = "Rotation timeline is color-coded (+ ~ x >)\nand KPIs are no longer scrunched boxes.\n\nHistory: fight cards, trend bars in the middle,\nand a real comparison table at the bottom.\n\nPreview-only. Overlay unchanged.",
  },
  ["3.8.0"] = {
    title = "NEW: Insights + Menu Polish!",
    body = "• Content plate no longer bleeds past edges\n• Rotation: skill icons + fine pulse + patterns\n• History bars labeled with values\n• Gear: worn + enchant formatting\n• Weave: full column words + tip line\n• NEW Insights page for coaching patterns\n\nL2/R2 history still works. Overlay default.",
  },
  ["3.8.1"] = {
    title = "FIX: Menu Layout Polish!",
    body = "• Weave tip no longer merges into skill list\n• Gear worn is a real table with slot icons\n• Rotation icons use thick color rings\n• History stats sit right of target name\n• Fight # once above trend columns\n\nPreview-only. Overlay default.",
  },
  ["3.8.2"] = {
    title = "FIX: History Order + Clarity!",
    body = "• Fight #1 is always newest\n• Trend bars newest→oldest like comparison\n• Buff tiers: Always-on / Sustained / Situational\n• U chip for ultimates; E for effects\n• Longer names; enchant effect text\n\nPreview-only. Overlay default.",
  },
  ["3.8.3"] = {
    title = "NEW: Buff Hybrid + Dmg Split!",
    body = "• Buffs: Always-on left + Sustained/Situational right\n• Damage contribution on Damage/Dashboard/Overview\n• U/S/E chips (Ult/Set/Effect) with clearer colors\n• Insights: comparative last-20% rush only\n• Bar snapshot icons for scribed skills\n\nPreview-only. Overlay default.",
  },
  ["3.9.0"] = {
    title = "NEW: Menu is Default!",
    body = "The dual-pane gamepad menu is now the default stats viewer.\n\n• Post-parse opens the menu (not the old overlay)\n• /dm2stats show / toggle use the menu\n• Settings: Stats viewer = menu | overlay (rollback)\n• /dm2stats legacy still opens the old window\n\nOverlay code kept for one cycle — not deleted.",
  },
  ["3.9.1"] = {
    title = "NEW: Parse Diagnosis!",
    body = "Insights is now a DPS coach:\n\n• Ranked “Where Did My DPS Go?” opportunities\n• Estimates from YOUR parse (DoTs, missed LAs, cadence…)\n• Personal best / recent average comparison\n• Opener · sustained · late phase breakdown\n• One clear next drill to practice\n\nMenu remains the default viewer.",
  },
  ["3.9.2"] = {
    title = "CLEANUP: Menu-First Settings!",
    body = "• Overlay page buttons removed from settings\n• Legacy overlay only under Advanced\n• Auto-close defaults off (use O/back)\n• Insights layout denser + clearer columns\n\nMenu stays the default stats viewer.",
  },
  ["3.9.3"] = {
    title = "Dashboard CP + Insights polish",
    body = "• Dashboard Build column: slotted Champion Points\n• Insights column headers: gold title color + spacing\n\nParse Diagnosis opportunities still need a parse with data to populate.",
  },
  ["3.9.4"] = {
    title = "NEW: Insights Build Fit!",
    body = "Juggle CP against your actual parse:\n\n• Top damage sources ranked with F/B/U/S chips\n• Slotted CP scored Strong / OK / Soft vs this fight’s Direct·DoT·crit mix\n• Heuristic fit — not A/B tested free DPS\n• Same live CP list as Dashboard\n\nParse Diagnosis + Build Fit on Insights.",
  },
  ["3.9.5"] = {
    title = "FIX: Champion bar CP read",
    body = "Slotted CP was empty on console/PC because we used the wrong API.\n\n• Now reads HOTBAR_CATEGORY_CHAMPION via GetSlotBoundId (ESOUI path)\n• Dashboard + Insights Build Fit share the fixed collector\n• Empty state text clarified\n\nReload and check Dashboard / Insights CP lists.",
  },
  ["3.9.6"] = {
    title = "Dashboard CP by constellation",
    body = "Slotted Champion Points on Dashboard are grouped and tinted:\n\n• |cE85D5DCombat|r (Warfare / red)\n• |c5B9BD5Fitness|r (blue)\n• |c6FBF73Craft|r (green)\n\nSame live champion bar read as 3.9.5.",
  },
  ["3.9.7"] = {
    title = "FIX: CP tree labels",
    body = "Combat / Fitness / Craft headers were rotated.\n\n• Discipline APIs need disciplineId (not index)\n• Prefer each slot’s required constellation + name\n• Known-star name fallback (Thaumaturge→Combat, Boundless→Fitness…)\n\nReload Dashboard and confirm groups match your CP bar.",
  },
  ["3.9.8"] = {
    title = "Insights: hide Craft CP",
    body = "Insights Build Fit no longer lists Craft/world stars (Gifted Rider, Master Gatherer, etc.).\n\nDashboard still shows all slotted CP by constellation.",
  },
  ["3.9.9"] = {
    title = "Stats, Mundus, Buff sources",
    body = "• Insights: longer text; Sets% fixed; CHAR STATS column (base→buffed)\n• Dashboard: Mundus stone + Crit/Pen/Power/HP\n• Buffs: Source (Skill/Set/Group/External…) + Major/Minor effect text\n• Fight-end stat snapshot; trial support tips when you bring Major/Minor\n\nNew parses get full snapshots; older history may show live stats.",
  },
  ["3.9.10"] = {
    title = "NEW: Target debuffs / status",
    body = "Buffs page is now Buffs / Debuffs:\n\n• Right panel: enemy status you applied (Off Balance, Concussed, Breach…)\n• Apps = how many times applied · Up% ≈ active window\n• Captured from combat effect events + known status names\n• Left = your buffs (Always-on, then Sustained)\n\nNeeds a new parse after reload — old history has no debuff table.",
  },
  ["3.9.11"] = {
    title = "FIX: Char stats + 3-col buffs",
    body = "• CHAR STATS: columns Now | +buffs (green = from food/skills/sets — not stacked twice)\n• Crit% from rating (was stuck at 0%)\n• Stam + phys/spell pen + resists\n• Build Fit CP reason text wider\n• Buffs: Always-on | Sustained/Sit | Target debuffs\n\nLegend under stats explains Now vs +buffs.",
  },
}
R._latestAnnouncementVersion = "3.9.11"

R._pageIndex = 1
R._lastBarSwapMs = 0          -- debounce EVENT_ACTIVE_WEAPON_PAIR_CHANGED (fires up to 3x per swap)
R._activeBar = nil             -- HOTBAR_CATEGORY_PRIMARY / HOTBAR_CATEGORY_BACKUP (set on init + swap)
R.pages = {
  { id = "summary",      title = "Summary" },
  { id = "damage",       title = "Damage Breakdown" },
  { id = "rotationdiag", title = "Rotation Diagnostics" },
  { id = "weavedetail",  title = "Weave Analysis" },
  { id = "gear",         title = "Gear Summary" },
  { id = "setdetails",   title = "Proc Analysis" },
  { id = "buffs",        title = "Buffs / Uptime" },
  { id = "history",      title = "History" },
}

-- UI refs
R.ui = {
  win = nil,
  bg = nil,

  header = nil,
  sub = nil,
  modeNotice = nil,

  kpi = {},
  pageTitle = nil,
  pageIndicator = nil,

  -- summary page sections
  summaryPanel = nil,
  rotPanel = nil,
  burstPanel = nil,
  setPanel = nil,
  summarySkillsPanel = nil,
  spikesList = nil,
  dipsList = nil,
  setsList = nil,
  summarySkillsList = nil,

  -- paged content area
  scrollWrap = nil,
  skillsPanel = nil,
  skillsList = nil,
  rotationDiagPanel = nil,
  rotationDiagSummary = nil,
  rotationDiagHint = nil,
  rotationDiagTimelineLines = nil,  -- v3.2.0: array of 16 CT_LABEL controls
  pulseStrip = nil,                 -- v3.2.0: array of 80 CT_BACKDROP blocks
  pulseContainer = nil,
  perSkillWeaveList = nil,          -- v3.2.0: per-skill weave breakdown list
  sparklinePanel = nil,             -- v3.2.0: DPS sparkline panel
  sparklineBars = nil,              -- v3.2.0: array of CT_BACKDROP bar chart elements
  dotUptimeList = nil,              -- v3.2.2: DOT uptime tracking list (on Weave Analysis page)
  weaveDetailPanel = nil,           -- v3.2.2: Weave Analysis page panel
  comparisonList = nil,             -- v3.2.7: fight comparison table
  comparisonHeaders = nil,          -- v3.2.7: date/time headers for comparison columns
  comparisonFightHeaders = nil,     -- v3.4.2: per-parse fight context above comparison cols
  comparisonSparklines = nil,       -- v3.4.2: per-parse DPS mini sparklines
  comparisonNote = nil,
  historyNote = nil,
  trendPanel = nil,
  trendFightHeaders = nil,
  trendMetricRows = nil,
  gearPanel = nil,
  gearList = nil,
  setDetailPanel = nil,
  setDetailList = nil,
  buffsPanel = nil,
  buffsList = nil,
  historyPanel = nil,
  historyList = nil,
  snapshotPanel = nil,
  snapshotList = nil,

  footer = nil,
  footerLabel = nil,
  weaveFlash = nil,   -- screen-center flash label for real-time weave feedback
}

-- keybind group for console (plain KEYBIND_STRIP, same as DM2_Metrics — no scenes)
local keybindGroup = nil

-- abilityId -> name cache (combat-event sourced; more reliable than GetAbilityName on console)
local ABILITY_NAME_CACHE = {}
local ABILITY_ICON_CACHE = {}

local ICON_SIZE = 26
local BAR_CHIP_LEGEND_H = 14

local function barChipLegendText()
  return "|c88DDAA|F|r Front bar   |c88AADD|B|r Back bar"
end

local function isBadAbilityIconTex(tex)
  if not tex or tex == "" then return true end
  local lower = string.lower(tostring(tex))
  if string.find(lower, "question", 1, true) then return true end
  if string.find(lower, "unknown", 1, true) then return true end
  if string.find(lower, "missing", 1, true) then return true end
  if string.find(lower, "icon_missing", 1, true) then return true end
  if string.find(lower, "ability_none", 1, true) then return true end
  return false
end

local function getAbilityIcon(abilityId)
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return nil end
  local cached = ABILITY_ICON_CACHE[abilityId]
  if cached ~= nil then
    if cached == false then return nil end
    return cached
  end
  local icon
  if type(GetAbilityIcon) == "function" then
    local ok, tex = pcall(GetAbilityIcon, abilityId)
    if ok and tex and tex ~= "" and not isBadAbilityIconTex(tex) then icon = tex end
  end
  -- Cache misses as false so we don't re-query every frame
  ABILITY_ICON_CACHE[abilityId] = icon or false
  return icon
end

local function richRow(cols, meta)
  if meta then
    return {
      cols = cols,
      abilityId = meta.abilityId,
      bar = meta.bar,
      sharePct = meta.sharePct,
    }
  end
  return { cols = cols }
end

local function isPlaceholderAbilityLabel(name)
  if not name or name == "" then return true end
  name = zo_strformat("<<1>>", name)
  if name == "?" then return true end
  if string.find(name, "^%[%d+%]$") then return true end      -- [7]
  if string.find(name, "^%[#%d+%]$") then return true end     -- [#7] (console)
  if string.find(name, "^Ability %d+$") then return true end
  if string.find(name, "^Skill %d+$") then return true end
  return false
end

local function slotBarKey(barLabel, slot)
  return tostring(barLabel or "?") .. ":" .. tostring(tonumber(slot) or 0)
end

local function cacheAbilityName(abilityId, name)
  abilityId = tonumber(abilityId) or 0
  if abilityId > 0 and name and name ~= "" and not isPlaceholderAbilityLabel(name) then
    ABILITY_NAME_CACHE[abilityId] = name
  end
end

local function scanSlotNamesForAbilityId(abilityId)
  if type(GetSlotBoundId) ~= "function" or type(GetSlotName) ~= "function" then return nil end
  local categories = {}
  if type(HOTBAR_CATEGORY_PRIMARY) ~= "nil" then table.insert(categories, HOTBAR_CATEGORY_PRIMARY) end
  if type(HOTBAR_CATEGORY_BACKUP) ~= "nil" then table.insert(categories, HOTBAR_CATEGORY_BACKUP) end
  if #categories == 0 then table.insert(categories, nil) end

  for _, cat in ipairs(categories) do
    for slot = 3, 8 do
      local ok, sid
      if cat ~= nil then ok, sid = pcall(GetSlotBoundId, slot, cat)
      else ok, sid = pcall(GetSlotBoundId, slot) end
      if ok and tonumber(sid) == abilityId then
        local ok2, sn
        if cat ~= nil then ok2, sn = pcall(GetSlotName, slot, cat)
        else ok2, sn = pcall(GetSlotName, slot) end
        if ok2 and sn and sn ~= "" then
          local n = zo_strformat("<<1>>", sn)
          if n ~= "" and not isPlaceholderAbilityLabel(n) then return n end
        end
      end
    end
  end
  return nil
end

local function resolveAbilityName(abilityId, abilityName)
  -- 1. Combat event gave us a name (never cache or return console placeholders like [7])
  if abilityName and abilityName ~= "" then
    local n = zo_strformat("<<1>>", abilityName)
    if n ~= "" and not isPlaceholderAbilityLabel(n) then
      cacheAbilityName(abilityId, n)
      return n
    end
  end
  abilityId = tonumber(abilityId) or 0
  if abilityId <= 0 then return "Ability" end
  local cached = ABILITY_NAME_CACHE[abilityId]
  if cached and cached ~= "" and not isPlaceholderAbilityLabel(cached) then return cached end

  -- 2. GetAbilityName
  if type(GetAbilityName) == "function" then
    local ok, nm = pcall(GetAbilityName, abilityId)
    if ok and nm and nm ~= "" then
      local n2 = zo_strformat("<<1>>", nm)
      if n2 ~= "" and not isPlaceholderAbilityLabel(n2) then
        cacheAbilityName(abilityId, n2)
        return n2
      end
    end
  end
  -- 3. GetFormattedAbilityName (sometimes works when GetAbilityName doesn't)
  if type(GetFormattedAbilityName) == "function" then
    local ok, nm = pcall(GetFormattedAbilityName, abilityId)
    if ok and nm and nm ~= "" and not isPlaceholderAbilityLabel(nm) then
      cacheAbilityName(abilityId, nm)
      return nm
    end
  end
  -- 4. Match against front + back action bar slots
  local slotName = scanSlotNamesForAbilityId(abilityId)
  if slotName then
    cacheAbilityName(abilityId, slotName)
    return slotName
  end
  return "Ability " .. tostring(abilityId)
end

local function lookupSlottedAbilityBySlot(session, bar, slot)
  if not session or not session.slottedAbilityBySlot then return nil end
  slot = tonumber(slot) or 0
  if slot < 3 then return nil end
  return session.slottedAbilityBySlot[slotBarKey(bar, slot)]
end

-- Retry name resolution after combat ends (API may work better out of combat)
local function retryAbilityNames(session)
  if not session then return end
  if session.skills then
    for id, sk in pairs(session.skills) do
      if sk.name and isPlaceholderAbilityLabel(sk.name) then
        local resolved = resolveAbilityName(id, nil)
        if resolved and not isPlaceholderAbilityLabel(resolved) then
          sk.name = resolved
        end
      end
    end
  end
  if session.dotTicks then
    for id, entry in pairs(session.dotTicks) do
      if entry and entry.name and isPlaceholderAbilityLabel(entry.name) then
        local resolved = resolveAbilityName(id, nil)
        if resolved and not isPlaceholderAbilityLabel(resolved) then
          entry.name = resolved
        end
      end
    end
  end
end

local function resolveWeaveSkillDisplayName(session, item)
  if not item then return "?" end
  local name = item.skillName or item.label or "?"
  if not isPlaceholderAbilityLabel(name) then return name end
  local id = tonumber(item.abilityId) or 0
  if id > 0 then
    local resolved = resolveAbilityName(id)
    if not isPlaceholderAbilityLabel(resolved) then return resolved end
  end
  if session and session.skills and id > 0 and session.skills[id] then
    local skName = session.skills[id].name
    if skName and not isPlaceholderAbilityLabel(skName) then return skName end
  end
  local slot = tonumber(item.slot) or 0
  local bar = item.bar
  if slot >= 3 then
    local slotted = lookupSlottedAbilityBySlot(session, bar, slot)
    if slotted then
      local snapId = tonumber(slotted.id) or 0
      if snapId > 0 then
        local resolved = resolveAbilityName(snapId)
        if not isPlaceholderAbilityLabel(resolved) then return resolved end
      end
      if slotted.name and not isPlaceholderAbilityLabel(slotted.name) then return slotted.name end
    end
  end
  if id > 0 then return "Ability " .. tostring(id) end
  if slot >= 3 then return string.format("Slot %d (%s)", slot, bar or "?") end
  return name
end

local function reconcileWeaveTimelineNames(session)
  if not session or not session.weave or not session.weave.timeline then return end
  for _, item in ipairs(session.weave.timeline) do
    if item then
      local resolved = resolveWeaveSkillDisplayName(session, item)
      if resolved and not isPlaceholderAbilityLabel(resolved) then
        item.skillName = resolved
        item.label = resolved
      end
      if (tonumber(item.abilityId) or 0) <= 0 then
        local slot = tonumber(item.slot) or 0
        if slot >= 3 then
          local slotted = lookupSlottedAbilityBySlot(session, item.bar, slot)
          if slotted and (tonumber(slotted.id) or 0) > 0 then
            item.abilityId = slotted.id
          end
        end
      end
    end
  end
end

-- ----------------------------
-- Utility
-- ----------------------------
local function NowMs() return GetGameTimeMilliseconds() end

local function latencyPadMs()
  if type(GetLatency) == "function" then
    local p = tonumber(GetLatency()) or 0
    if p < 0 then p = 0 end
    local pad = math.floor(math.max(80, math.min(300, p * 1.2)))
    return pad
  end
  return 120
end


local function startsWithAt(s)
  return type(s) == "string" and s ~= "" and string.sub(s,1,1) == "@"
end

local function playerDisplayName()
  local dn = GetUnitDisplayName("player")
  if dn and dn ~= "" then return dn end
  return "player"
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
  if dps >= 1000000 then
    return string.format("%.2fm", dps/1000000)
  elseif dps >= 1000 then
    return string.format("%.1fk", dps/1000)
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
  local m = math.floor(total / 60)
  local s = total - (m * 60)
  return string.format("%d:%04.1f", m, s)
end

local function safeLower(s)
  if type(s) ~= "string" then return "" end
  return string.lower(s)
end

local function isInHousingHeuristic()
  -- Method 1: GetCurrentZoneHouseId — most reliable on console
  if type(GetCurrentZoneHouseId) == "function" then
    local ok, hid = pcall(GetCurrentZoneHouseId)
    if ok and tonumber(hid) and tonumber(hid) > 0 then
      return true
    end
  end
  -- Method 2: IsOwnerOfCurrentHouse (only true in YOUR house)
  if type(IsOwnerOfCurrentHouse) == "function" then
    local ok, res = pcall(IsOwnerOfCurrentHouse)
    if ok and res == true then return true end
  end
  -- Method 3: Housing editor mode active = definitely in a house
  if type(GetHousingEditorMode) == "function" then
    local ok, mode = pcall(GetHousingEditorMode)
    if ok and mode and mode ~= 0 then return true end
  end
  -- Method 4: Map content type
  if type(GetMapContentType) == "function" then
    local ok, ct = pcall(GetMapContentType)
    -- MAP_CONTENT_HOUSING = 4 (define locally in case constant not available)
    if ok and ct and (ct == 4 or (type(MAP_CONTENT_HOUSING) ~= "nil" and ct == MAP_CONTENT_HOUSING)) then
      return true
    end
  end
  return false
end

local DUMMY_KEYWORDS = {
  "target skeleton",
  "trial dummy",
  "iron atronach",
  "training dummy",
  "target",
  "serpent",
}

local function isDummyName(targetName)
  local n = safeLower(zo_strformat("<<1>>", targetName or ""))
  if n == "" then return false end

  -- extra heuristic: many trial dummies include both "target" and "trial"
  if string.find(n, "target", 1, true) and string.find(n, "trial", 1, true) then
    return true
  end
  for _, kw in ipairs(DUMMY_KEYWORDS) do
    if string.find(n, kw, 1, true) then return true end
  end
  return false
end

local function isDummyParseConfidence(targetName)
  local nameHit = isDummyName(targetName)
  local inHouse = isInHousingHeuristic()

  if SV.settings.dummyStrict then
    return nameHit and inHouse
  end
  return nameHit or inHouse
end

-- ----------------------------
-- Session model
-- ----------------------------
local function newSession()
  return {
    started = false,
    startMs = 0,
    endMs = 0,
    durationMs = 0,

    -- raw totals
    totalDamage = 0,
    directDamage = 0,
    dotDamage = 0,
    totalHealing = 0,
    effectiveHealing = 0,

    hitCount = 0,
    critCount = 0,
    dotTicks = {},    -- v3.2.0: [abilityId] = { name, ticks={ms,...} } for DOT uptime
    maxHit = 0,

    -- buckets (2s)
    buckets = {},     -- [bucketIndex] = { dmg, direct, dot, hits, crit, skills = { [abilityId]=dmg } }

    -- skills
    skills = {},      -- [abilityId] = { name, dmg, hits, crit, direct, dot }

    -- buffs (player)
    buffs = {},       -- [abilityId] = { name, applied=cnt, activeMs=0, activeStartMs=nil }

    -- debuffs / status effects applied to enemies (by you / pet)
    -- [key] = { id, name, kind, applied, activeMs, activeStartMs, lastTarget }
    targetDebuffs = {},

    -- weaving (v3.0.25: input-based via EVENT_ACTION_SLOT_ABILITY_USED)
    weave = {
      laCount = 0,
      lastLaHitMs = nil,
      laIntervals = {},

      tooFastCount = 0,
      onTimeCount = 0,
      lateCount = 0,
      missedCount = 0,
      extraLAs = 0,

      fastSkillPresses = 0,
      skillEventCount = 0,
      lastSkillEventMs = nil,

      timeline = {},
      pendingSkill = nil,
      pendingPostChannel = nil,

      -- input-based tracking (new in v3.0.25)
      laPressCount = 0,            -- LA button presses (slot 1) from input
      lastLaPressMs = nil,         -- timestamp of last LA button press (for weave gap + LA intervals)
      lastInputSlot = nil,         -- last slot index from EVENT_ACTION_SLOT_ABILITY_USED
      lastInputAbilityId = nil,    -- ability ID resolved at input time
      lastInputBar = nil,          -- HOTBAR_CATEGORY at input time
      lastInputMs = nil,           -- timestamp of last input event
      inputSkillPresses = 0,       -- total skill button presses captured
      barSwapCount = 0,            -- number of bar swaps during the fight
    },

    -- metadata
    lastTargetName = nil,
    isDummy = false,
    slottedAbilityIds = {},
    slottedAbilityNames = {},
    slottedAbilityBar = {},       -- [abilityIdStr] = "Front" | "Back"
    slottedAbilityBarByName = {}, -- [normalizedName] = "Front" | "Back" (slotted snapshot)
    slottedAbilityBySlot = {},    -- ["Front:5"] = { id, name } fight-start snapshot
    rotationDebug = {},
  }
end

local function bucketIndexFor(session, tMs)
  if not session.started then return 0 end
  local rel = tMs - session.startMs
  if rel < 0 then rel = 0 end
  return math.floor(rel / SV.settings.bucketMs)
end

local function ensureBucket(session, idx)
  local b = session.buckets[idx]
  if not b then
    b = { dmg=0, direct=0, dot=0, hits=0, crit=0, skills={} }
    session.buckets[idx] = b
  end
  return b
end

local function ensureSkill(session, abilityId, abilityName)
  abilityId = tonumber(abilityId) or 0
  local resolved = resolveAbilityName(abilityId, abilityName)
  local s = session.skills[abilityId]
  if not s then
    s = {
      id = abilityId,
      name = resolved,
      dmg = 0,
      hits = 0,
      crit = 0,
      direct = 0,
      dot = 0,
      max = 0,
    }
    session.skills[abilityId] = s
  else
    -- If the stored name is still a fallback like "Ability 12345" and we
    -- now have a real name from a later hit or the cache, update it.
    if resolved and resolved ~= "" and s.name ~= resolved then
      local isFallback = (s.name == ("Ability " .. tostring(abilityId))) or (s.name == "Ability")
          or isPlaceholderAbilityLabel(s.name)
      if isFallback and not isPlaceholderAbilityLabel(resolved) then
        s.name = resolved
      end
    end
  end
  return s
end


-- ----------------------------
-- Set proc attribution (lightweight + scalable)
-- ----------------------------
-- Primary: curated abilityId -> setName map (fast, accurate when populated)
-- Secondary fallback: if an outgoing damage ability name matches an equipped set name, attribute to that set.
-- This catches common procs like "Aegis Caller" out-of-the-box without needing IDs.
local SET_PROC_BY_ABILITY_ID = {
  -- Populate over time as you learn proc IDs.
  -- Example:
  -- [123456] = "Pillar of Nirn",
  -- [234567] = "Whorl of the Depths",
}

-- Curated proc-ability-NAME -> setName map.
-- Use when a set's damage proc has an ability name that differs from the set
-- name itself, so the ability-name == equipped-set-name fallback cannot catch
-- it (and we don't have a stable abilityId, e.g. pet/summon-sourced procs
-- whose id isn't surfaced in the UI). Keys must be lowercased and
-- whitespace-trimmed name keys.
local SET_PROC_BY_ABILITY_NAME = {
  ["sliver assault"] = "Slivers of the Null Arca",   -- 5pc proc crystal ("Sliver Assault")
  ["silver assault"] = "Slivers of the Null Arca",   -- common combat-log typo
}

local function normalizeNameKey(s)
  s = zo_strformat("<<1>>", s or "")
  s = safeLower(s)
  s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
  return s
end

local function findSkillAbilityId(session, skillName)
  if not session or not session.skills or not skillName then return 0 end
  local key = normalizeNameKey(skillName)
  if key == "" then return 0 end
  for id, sk in pairs(session.skills) do
    if normalizeNameKey(sk.name) == key then return tonumber(id) or 0 end
  end
  return 0
end

local function abilityBarKey(abilityId)
  local id = tonumber(abilityId) or 0
  if id <= 0 then return nil end
  return tostring(id)
end

local ROTATION_ABILITY_ALIASES = {
  ["pragmatic fatecarver"] = "fatecarver",
  ["exhausting fatecarver"] = "fatecarver",
  ["fatecarver"] = "fatecarver",
  ["unstable wall of fire"] = "wall of elements",
  ["wall of fire"] = "wall of elements",
  ["unstable wall of storms"] = "wall of elements",
  ["wall of storms"] = "wall of elements",
  ["unstable wall of frost"] = "wall of elements",
  ["wall of frost"] = "wall of elements",
  ["cephaliarch's flail"] = "flail",
  ["tentacular dread"] = "flail",
  ["escalating runeblades"] = "runeblades",
  ["writhing runeblades"] = "runeblades",
  ["inspired scholarship"] = "scholarship",
  ["scholarship"] = "scholarship",
  ["rending slashes"] = "rending slashes",
  ["the imperfect ring"] = "imperfect ring",
  ["imperfect ring"] = "imperfect ring",
  ["soul of flame"] = "soul of flame",
}

local function canonicalizeRotationName(name)
  local key = normalizeNameKey(name)
  if key == "" then return "" end
  for pattern, canonical in pairs(ROTATION_ABILITY_ALIASES) do
    if string.find(key, pattern, 1, true) then
      return canonical
    end
  end
  return key
end

local function captureEquippedSets()
  -- Best-effort snapshot of currently equipped set names.
  -- Works even if we don't map procs perfectly; helps detect swaps between parses.
  local sets, setMap = {}, {}
  if type(GetItemLink) ~= "function" or type(BAG_WORN) == "nil" then
    return sets, setMap
  end

  local function addSetName(setName)
    if not setName or setName == "" then return end
    local key = normalizeNameKey(setName)
    if key == "" or setMap[key] then return end
    setMap[key] = setName
    table.insert(sets, setName)
  end

  -- Typical equipment slots. (Defensive: only add those constants that exist.)
  local slots = {}
  local function pushSlot(slotConstName)
    local v = _G[slotConstName]
    if type(v) == "number" then table.insert(slots, v) end
  end

  -- armor
  pushSlot("EQUIP_SLOT_HEAD"); pushSlot("EQUIP_SLOT_CHEST"); pushSlot("EQUIP_SLOT_SHOULDERS")
  pushSlot("EQUIP_SLOT_HAND"); pushSlot("EQUIP_SLOT_WAIST"); pushSlot("EQUIP_SLOT_LEGS"); pushSlot("EQUIP_SLOT_FEET")
  -- jewelry
  pushSlot("EQUIP_SLOT_NECK"); pushSlot("EQUIP_SLOT_RING1"); pushSlot("EQUIP_SLOT_RING2")
  -- weapons
  pushSlot("EQUIP_SLOT_MAIN_HAND"); pushSlot("EQUIP_SLOT_OFF_HAND")
  pushSlot("EQUIP_SLOT_BACKUP_MAIN"); pushSlot("EQUIP_SLOT_BACKUP_OFF")

  for _,slotId in ipairs(slots) do
    local okLink, link = pcall(GetItemLink, BAG_WORN, slotId)
    if okLink and link and link ~= "" then
      -- API differences across versions: try a couple common signatures.
      local okSet, hasSet, setName = pcall(function()
        local a,b,c = GetItemLinkSetInfo(link)
        -- Some versions return (hasSet, setName, numBonuses, maxEquipped, ...)
        -- Others may return more. We'll interpret safely.
        if type(a) == "boolean" then return a, b end
        if type(a) == "number" then return a ~= 0, b end
        return false, nil
      end)
      if okSet and hasSet and setName and setName ~= "" then
        addSetName(setName)
      end
    end
  end

  return sets, setMap
end

local function captureSlottedAbilities()
  local ids = {}
  local names = {}
  local bars = {}
  local barsByName = {}
  local bySlot = {}
  if type(GetSlotBoundId) ~= "function" then return ids, names, bars, barsByName, bySlot end

  local function rememberBarForName(nm, barLabel)
    if not barLabel or not nm or nm == "" then return end
    local key = normalizeNameKey(nm)
    if key ~= "" then barsByName[key] = barLabel end
    local canon = canonicalizeRotationName(nm)
    if canon ~= "" then barsByName[canon] = barLabel end
  end

  local function addSlot(slot, hotbarCategory, barLabel)
    if type(slot) ~= "number" then return end
    local ok, id
    if hotbarCategory ~= nil then
      ok, id = pcall(GetSlotBoundId, slot, hotbarCategory)
    else
      ok, id = pcall(GetSlotBoundId, slot)
    end
    id = tonumber(id) or 0
    if ok and id > 0 then
      ids[id] = true
      local key = abilityBarKey(id)
      if barLabel and key then bars[key] = barLabel end
      local nm = resolveAbilityName(id)
      -- Prefer live slot name (scribed skills often resolve better from hotbar).
      if type(GetSlotName) == "function" then
        local okN, sn
        if hotbarCategory ~= nil then okN, sn = pcall(GetSlotName, slot, hotbarCategory)
        else okN, sn = pcall(GetSlotName, slot) end
        if okN and sn and sn ~= "" and not isPlaceholderAbilityLabel(sn) then
          nm = (type(zo_strformat) == "function") and zo_strformat("<<1>>", sn) or sn
        end
      end
      -- Snapshot icon texture at capture (scribed / console-safe).
      local iconTex = nil
      if type(GetSlotTexture) == "function" then
        local okT, tex
        if hotbarCategory ~= nil then okT, tex = pcall(GetSlotTexture, slot, hotbarCategory)
        else okT, tex = pcall(GetSlotTexture, slot) end
        if okT and tex and tex ~= "" then
          local lower = string.lower(tostring(tex))
          if not string.find(lower, "question", 1, true)
              and not string.find(lower, "missing", 1, true)
              and not string.find(lower, "unknown", 1, true) then
            iconTex = tex
          end
        end
      end
      if not iconTex then iconTex = getAbilityIcon(id) end
      bySlot[slotBarKey(barLabel, slot)] = {
        id = id,
        name = (nm and not isPlaceholderAbilityLabel(nm)) and nm or nil,
        icon = iconTex,
        isUlt = (slot == 8) or nil,
      }
      if nm and nm ~= "" and not isPlaceholderAbilityLabel(nm) then
        names[normalizeNameKey(nm)] = true
        rememberBarForName(nm, barLabel)
      end
    end
  end

  -- Try explicit hotbar categories first (available in modern API)
  if type(HOTBAR_CATEGORY_PRIMARY) ~= "nil" and type(HOTBAR_CATEGORY_BACKUP) ~= "nil" then
    for slot = 3, 8 do addSlot(slot, HOTBAR_CATEGORY_PRIMARY, "Front") end
    for slot = 3, 8 do addSlot(slot, HOTBAR_CATEGORY_BACKUP, "Back") end
  else
    -- Fallback: old-style slot ranges
    for slot = 3, 8 do addSlot(slot, nil, "Front") end
    for slot = 20, 25 do addSlot(slot, nil, "Back") end
  end
  return ids, names, bars, barsByName, bySlot
end

local function ensureSet(session, setName)
  if not session or not setName or setName == "" then return nil end
  session.sets = session.sets or {}
  local s = session.sets[setName]
  if not s then
    s = { name=setName, dmg=0, hits=0, crit=0, direct=0, dot=0 }
    session.sets[setName] = s
  end
  return s
end

local function rotationNameMatchesSlotted(session, abilityName)
  if not session or not session.slottedAbilityNames then return false end
  local key = normalizeNameKey(abilityName)
  local canon = canonicalizeRotationName(abilityName)
  if key ~= "" and session.slottedAbilityNames[key] then return true end
  if canon ~= "" and session.slottedAbilityNames[canon] then return true end
  for slottedName,_ in pairs(session.slottedAbilityNames) do
    if slottedName == key or slottedName == canon then
      return true
    end
    if canon ~= "" and string.find(slottedName, canon, 1, true) then
      return true
    end
    if slottedName ~= "" and key ~= "" and string.find(key, slottedName, 1, true) then
      return true
    end
  end
  return false
end

local function matchEquippedSetName(session, aliasName)
  if not aliasName or aliasName == "" then return aliasName end
  if not session or not session.equippedSetMap then return aliasName end

  local aliasKey = normalizeNameKey(aliasName)
  if aliasKey == "" then return aliasName end
  if session.equippedSetMap[aliasKey] then return session.equippedSetMap[aliasKey] end

  -- Fuzzy match: "Null Arca" -> "Slivers of the Null Arca", perfected variants, etc.
  for key, name in pairs(session.equippedSetMap) do
    if key:find(aliasKey, 1, true) or aliasKey:find(key, 1, true) then
      return name
    end
  end
  return aliasName
end

local function lookupSetNameByAbilityLabel(session, abilityName)
  if not abilityName or abilityName == "" then return nil end

  local key = normalizeNameKey(abilityName)
  local byName = SET_PROC_BY_ABILITY_NAME[key]
  if byName then return matchEquippedSetName(session, byName) end

  -- Partial match for curated proc aliases (handles minor name variants from API/log)
  for procKey, setAlias in pairs(SET_PROC_BY_ABILITY_NAME) do
    if key:find(procKey, 1, true) or procKey:find(key, 1, true) then
      return matchEquippedSetName(session, setAlias)
    end
  end

  -- fallback: ability name matches an equipped set name
  key = canonicalizeRotationName(abilityName)
  if key ~= "" and session.equippedSetMap and session.equippedSetMap[key] then
    return session.equippedSetMap[key]
  end

  return nil
end

local function resolveSetName(session, abilityId, abilityName)
  abilityId = tonumber(abilityId) or 0

  local byId = SET_PROC_BY_ABILITY_ID[abilityId]
  if byId then return matchEquippedSetName(session, byId) end

  local result = lookupSetNameByAbilityLabel(session, abilityName)
  if result then return result end

  -- Combat events often omit abilityName; resolve via API/cache before giving up.
  local resolved = resolveAbilityName(abilityId, abilityName)
  if resolved and resolved ~= "" then
    result = lookupSetNameByAbilityLabel(session, resolved)
    if result then return result end
  end

  return nil
end

-- Rebuild set contribution totals from resolved per-skill damage.
-- Per-hit attribution can miss procs whose names only resolve after combat ends.
local function reconcileSetContributions(session)
  if not session or not session.skills then return end

  local sets = {}
  for abilityId, sk in pairs(session.skills) do
    local setName = resolveSetName(session, abilityId, sk.name)
    if setName then
      local ps = sets[setName]
      if not ps then
        ps = { name = setName, dmg = 0, hits = 0, crit = 0, direct = 0, dot = 0 }
        sets[setName] = ps
      end
      ps.dmg = ps.dmg + (tonumber(sk.dmg) or 0)
      ps.hits = ps.hits + (tonumber(sk.hits) or 0)
      ps.crit = ps.crit + (tonumber(sk.crit) or 0)
      ps.direct = ps.direct + (tonumber(sk.direct) or 0)
      ps.dot = ps.dot + (tonumber(sk.dot) or 0)
    end
  end
  session.sets = sets
end

local function classifyBuffSource(session, buff)
  if not buff then return "Unknown" end
  local abilityId = tonumber(buff.id) or 0
  local buffName = buff.name or ""

  if abilityId > 0 and session and session.slottedAbilityIds and session.slottedAbilityIds[abilityId] then
    return "Skill"
  end

  local setName = resolveSetName(session, abilityId, buffName)
  if setName then
    return "Set"
  end

  if abilityId > 0 and session and session.skills and session.skills[abilityId] then
    return "Self"
  end

  local key = normalizeNameKey(buffName)
  if key ~= "" and session and session.equippedSetMap and session.equippedSetMap[key] then
    return "Set"
  end

  return "External"
end

local function classifyDamageSource(session, skill)
  if not skill then return "Unknown" end
  local abilityId = tonumber(skill.id) or 0
  local skillName = skill.name or ""
  local key = normalizeNameKey(skillName)

  if abilityId > 0 and session and session.slottedAbilityIds and session.slottedAbilityIds[abilityId] then
    return "Skill"
  end

  local setName = resolveSetName(session, abilityId, skillName)
  if setName then
    return "Set"
  end

  if key:find("light attack", 1, true) or key:find("heavy attack", 1, true) then
    return "Weapon"
  end

  if key:find("bash", 1, true) then
    return "Weapon"
  end

  if abilityId > 0 then
    return "Self"
  end

  return "Other"
end

local function classifyAoeSkill(session, skill)
  if not skill then return "?" end
  local name = normalizeNameKey(skill.name or "")
  local source = classifyDamageSource(session, skill)
  if source == "Set" then return "Yes" end
  if name == "" then return "?" end

  local aoeHints = {
    "wall", "hail", "volley", "trap", "stampede", "whorl", "aegis", "deep fissure",
    "eruption", "claw", "cleave", "carve", "blade cloak", "hurricane", "twister",
    "fatecarver", "beam", "sweep", "shards", "orb", "barrage", "splash", "blast",
    "meteor", "standard", "banner", "runeblades", "tentacular", "frost blockade",
    "unstable wall", "wall of", "incinerate", "burning", "poison injection", "soul trap"
  }
  local singleHints = {
    "merciless", "killer", "relentless", "flail", "concealed", "surprise attack",
    "force pulse", "swallow soul", "crushing shock", "execute", "spammable", "silver shards"
  }

  for _,hint in ipairs(aoeHints) do
    if name:find(hint, 1, true) then return "Yes" end
  end
  for _,hint in ipairs(singleHints) do
    if name:find(hint, 1, true) then return "No" end
  end
  if name:find("light attack", 1, true) or name:find("heavy attack", 1, true) then return "No" end
  return "?"
end

local function isCritResult(result)
  return result == ACTION_RESULT_CRITICAL_DAMAGE
      or result == ACTION_RESULT_DOT_TICK_CRITICAL
      or result == ACTION_RESULT_DAMAGE_SHIELDED_CRITICAL
      or result == ACTION_RESULT_BLOCKED_DAMAGE_CRITICAL
end

local function isDotResult(result)
  return result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DOT_TICK_CRITICAL
end

local function isDirectDamageResult(result)
  return result == ACTION_RESULT_DAMAGE
      or result == ACTION_RESULT_CRITICAL_DAMAGE
      or result == ACTION_RESULT_BLOCKED_DAMAGE
      or result == ACTION_RESULT_BLOCKED_DAMAGE_CRITICAL
      or result == ACTION_RESULT_DAMAGE_SHIELDED
      or result == ACTION_RESULT_DAMAGE_SHIELDED_CRITICAL
end

local function isOutgoingDamageEvent(result)
  return isDirectDamageResult(result) or isDotResult(result)
end

-- Combat-log results that mean an effect was applied/removed (not pure damage)
local function isEffectApplyResult(result)
  if result == nil then return false end
  if type(ACTION_RESULT_EFFECT_GAINED) == "number" and result == ACTION_RESULT_EFFECT_GAINED then return true end
  if type(ACTION_RESULT_EFFECT_GAINED_DURATION) == "number" and result == ACTION_RESULT_EFFECT_GAINED_DURATION then return true end
  if type(ACTION_RESULT_EFFECT_FADED) == "number" and result == ACTION_RESULT_EFFECT_FADED then return true end
  return false
end

-- Known enemy status / control / common debuffs (parse-visible names)
local TARGET_STATUS_KIND = {
  ["off balance"] = "CC",
  ["off-balance"] = "CC",
  ["concussed"] = "Status",
  ["concussion"] = "Status",
  ["burning"] = "Status",
  ["chilled"] = "Status",
  ["chill"] = "Status",
  ["sundered"] = "Status",
  ["diseased"] = "Status",
  ["hemorrhaging"] = "Status",
  ["poisoned"] = "Status",
  ["poison"] = "Status",
  ["bleed"] = "Status",
  ["bleeding"] = "Status",
  ["overcharged"] = "Status",
  ["frozen"] = "Status",
  ["major breach"] = "Debuff",
  ["minor breach"] = "Debuff",
  ["major fracture"] = "Debuff",
  ["minor fracture"] = "Debuff",
  ["major maim"] = "Debuff",
  ["minor maim"] = "Debuff",
  ["major defile"] = "Debuff",
  ["minor defile"] = "Debuff",
  ["major vulnerability"] = "Debuff",
  ["minor vulnerability"] = "Debuff",
  ["major cowardice"] = "Debuff",
  ["minor cowardice"] = "Debuff",
  ["minor brittle"] = "Debuff",
  ["major brittle"] = "Debuff",
  ["crusader"] = "Debuff", -- crusher enchant often shows as named proc
  ["crusader's resolve"] = "Debuff",
  ["alkosh"] = "Debuff",
  ["roar of alkosh"] = "Debuff",
  ["tremorscale"] = "Debuff",
  ["crystal weapon"] = "Debuff",
  ["weakening"] = "Debuff",
}

local function classifyTargetStatusKind(name)
  local n = safeLower(zo_strformat("<<1>>", name or ""))
  if n == "" then return nil end
  if TARGET_STATUS_KIND[n] then return TARGET_STATUS_KIND[n] end
  for key, kind in pairs(TARGET_STATUS_KIND) do
    if string.find(n, key, 1, true) then return kind end
  end
  -- Generic major/minor enemy debuffs
  if string.find(n, "major ", 1, true) or string.find(n, "minor ", 1, true) then
    if string.find(n, "breach", 1, true) or string.find(n, "fracture", 1, true)
        or string.find(n, "maim", 1, true) or string.find(n, "defile", 1, true)
        or string.find(n, "cowardice", 1, true) or string.find(n, "vulnerability", 1, true)
        or string.find(n, "brittle", 1, true) or string.find(n, "breach", 1, true) then
      return "Debuff"
    end
  end
  return nil
end

local function targetDebuffKey(abilityId, name)
  abilityId = tonumber(abilityId) or 0
  if abilityId > 0 then return "id:" .. tostring(abilityId) end
  local n = safeLower(zo_strformat("<<1>>", name or ""))
  if n ~= "" then return "name:" .. n end
  return nil
end

local function ensureTargetDebuff(session, abilityId, name)
  if not session then return nil end
  session.targetDebuffs = session.targetDebuffs or {}
  local key = targetDebuffKey(abilityId, name)
  if not key then return nil end
  local d = session.targetDebuffs[key]
  if not d then
    local resolved = (name and name ~= "") and zo_strformat("<<1>>", name) or ("Effect " .. tostring(abilityId or "?"))
    d = {
      id = tonumber(abilityId) or 0,
      name = resolved,
      kind = classifyTargetStatusKind(resolved) or "Effect",
      applied = 0,
      activeMs = 0,
      activeStartMs = nil,
      lastTarget = nil,
    }
    session.targetDebuffs[key] = d
  end
  return d
end

local function recordTargetDebuffApply(session, abilityId, name, tMs, targetName)
  local d = ensureTargetDebuff(session, abilityId, name)
  if not d then return end
  d.applied = (d.applied or 0) + 1
  d.activeStartMs = tMs or NowMs()
  if targetName and targetName ~= "" then
    d.lastTarget = zo_strformat("<<1>>", targetName)
  end
  -- Upgrade kind if we learn a better classification
  local k = classifyTargetStatusKind(d.name)
  if k then d.kind = k end
end

local function recordTargetDebuffFade(session, abilityId, name, tMs)
  local d = ensureTargetDebuff(session, abilityId, name)
  if not d then return end
  tMs = tMs or NowMs()
  if d.activeStartMs then
    d.activeMs = (d.activeMs or 0) + math.max(0, tMs - d.activeStartMs)
    d.activeStartMs = nil
  end
end

local function isLightAttack(abilityId, abilityName, abilityActionSlotType)
  if abilityActionSlotType ~= nil and type(ACTION_SLOT_TYPE_LIGHT_ATTACK) ~= "nil" then
    if abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK then return true end
  end
  local resolved = resolveAbilityName(abilityId, abilityName)
  local n = safeLower(resolved or "")
  if n ~= "" and string.find(n, "light attack", 1, true) then return true end
  if type(GetSlotBoundId) == "function" then
    local ok, laId = pcall(GetSlotBoundId, 1)
    if ok and laId and laId == abilityId then return true end
  end
  return false
end

-- ----------------------------
-- Rotation diagnostics helpers
-- ----------------------------
-- Classify the weave gap: time from skill button press to next LA button press.
-- In ESO, the weave rhythm is: LA → Skill (fast, ~50-150ms) → wait GCD → LA.
-- So skill-to-next-LA gap is roughly 600-1100ms for a good weave (GCD remainder).
local function classifyWeaveGap(deltaMs)
  deltaMs = tonumber(deltaMs) or 0
  if deltaMs <= 0 then return SYM_MISS, "Missed" end
  if deltaMs < 400 then return SYM_FAST, "Too Fast" end
  if deltaMs <= 1200 then return SYM_OK, "Good" end
  if deltaMs <= 1800 then return SYM_LATE, "Late" end
  return SYM_MISS, "Missed"
end

-- ----------------------------
-- Real-time weave flash (v3.2.0)
-- Shows a brief color-coded result at screen center during combat.
-- ----------------------------
local function ensureWeaveFlashUI()
  if R.ui.weaveFlash then return end
  local flash = WM:CreateTopLevelWindow("DM2StatsWeaveFlash")
  flash:SetDimensions(400, 70)
  flash:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
  flash:SetHidden(true)
  flash:SetDrawLayer(DL_OVERLAY)
  flash:SetDrawTier(DT_HIGH)
  flash:SetDrawLevel(500001)
  flash:SetMouseEnabled(false)

  local fontSize = (SV and SV.settings and SV.settings.weaveFlashSize) or 36
  local lbl = WM:CreateControl("DM2StatsWeaveFlashLabel", flash, CT_LABEL)
  lbl:SetFont(string.format("EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick", fontSize))
  lbl:SetColor(1, 1, 1, 1)
  lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  lbl:SetAnchorFill(flash)
  lbl:SetText("")
  flash.label = lbl

  R.ui.weaveFlash = flash
end

local function updateWeaveFlashFont()
  if not R.ui.weaveFlash or not R.ui.weaveFlash.label then return end
  local fontSize = (SV and SV.settings and SV.settings.weaveFlashSize) or 36
  R.ui.weaveFlash.label:SetFont(string.format("EsoUI/Common/Fonts/univers67.otf|%d|soft-shadow-thick", fontSize))
end

local function playWeaveSound(resultLabel)
  if not SV or not SV.settings.weaveFlashSound then return end
  if type(PlaySound) ~= "function" then return end
  local rl = safeLower(resultLabel or "")
  if rl == "good" then
    PlaySound(SOUNDS.QUEST_STEP_ADVANCED)
  elseif rl == "late" then
    PlaySound(SOUNDS.ABILITY_TARGET_OUT_OF_RANGE)
  elseif rl == "missed" then
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
  end
end

local function flashWeaveResult(resultLabel)
  -- Sound cue runs independently of visual flash
  if R.inCombat then playWeaveSound(resultLabel) end

  if not SV or not SV.settings.showWeaveFlash then return end
  if not R.inCombat then return end

  ensureWeaveFlashUI()
  local flash = R.ui.weaveFlash
  if not flash then return end

  -- Set color and text based on result
  local r, g, b = 1, 1, 1
  local text = resultLabel or ""
  local rl = safeLower(resultLabel or "")
  if rl == "good" then
    r, g, b = 0.4, 1.0, 0.4
    text = "Good!"
  elseif rl == "late" then
    r, g, b = 1.0, 0.8, 0.3
    text = "Late"
  elseif rl == "missed" then
    r, g, b = 1.0, 0.3, 0.3
    text = "Missed"
  elseif rl == "too fast" then
    r, g, b = 0.4, 0.7, 1.0
    text = "Too Fast"
  end

  flash.label:SetColor(r, g, b, 1)
  flash.label:SetText(text)
  flash:SetHidden(false)

  -- Auto-hide after configured duration (debounced via token)
  local durationMs = (SV and SV.settings and SV.settings.weaveFlashDuration) or 500
  R._weaveFlashToken = (R._weaveFlashToken or 0) + 1
  local myToken = R._weaveFlashToken
  zo_callLater(function()
    if R._weaveFlashToken == myToken and R.ui.weaveFlash then
      R.ui.weaveFlash:SetHidden(true)
    end
  end, durationMs)
end

local function hideWeaveFlash()
  R._weaveFlashToken = (R._weaveFlashToken or 0) + 1
  if R.ui.weaveFlash then R.ui.weaveFlash:SetHidden(true) end
end

-- ----------------------------
-- Version announcement popup (v3.2.0)
-- Styled screen-center popup shown once per version at login.
-- ----------------------------
local _announcementWin = nil
local _announcementCountdownLabel = nil
local _announcementSecondsLeft = 10

local function dismissAnnouncement()
  R._announcementToken = (R._announcementToken or 0) + 1
  if _announcementWin then _announcementWin:SetHidden(true) end
  EM:UnregisterForUpdate(R.name .. "_AnnounceCountdown")
  if SV then SV.lastAnnouncementVersion = R._latestAnnouncementVersion end
end

local function showAnnouncementPopup(title, body)
  if _announcementWin then dismissAnnouncement() end

  local win = WM:CreateTopLevelWindow("DM2StatsAnnouncement")
  win:SetDimensions(480, 260)
  win:SetAnchor(CENTER, GuiRoot, CENTER, 0, -60)
  win:SetDrawLayer(DL_OVERLAY)
  win:SetDrawTier(DT_HIGH)
  win:SetDrawLevel(500002)
  win:SetMouseEnabled(true)
  win:SetHidden(false)

  -- Backdrop
  local bg = WM:CreateControl("DM2StatsAnnouncementBG", win, CT_BACKDROP)
  bg:SetAnchorFill(win)
  bg:SetCenterColor(0.06, 0.06, 0.10, 0.92)
  bg:SetEdgeColor(0.45, 0.85, 0.55, 0.8)
  bg:SetEdgeTexture(nil, 1, 1, 2)

  -- Header: addon name (green, small)
  local header = WM:CreateControl("DM2StatsAnnouncementHeader", win, CT_LABEL)
  header:SetFont("EsoUI/Common/Fonts/univers57.otf|15|soft-shadow-thin")
  header:SetColor(0.53, 1.0, 0.53, 1)
  header:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 14)
  header:SetDimensions(420, 18)
  header:SetText(R.displayName .. "  v" .. R.version)

  -- Title (gold, large, bold)
  local titleLbl = WM:CreateControl("DM2StatsAnnouncementTitle", win, CT_LABEL)
  titleLbl:SetFont("EsoUI/Common/Fonts/univers67.otf|22|soft-shadow-thick")
  titleLbl:SetColor(1.0, 0.88, 0.35, 1)
  titleLbl:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 8)
  titleLbl:SetDimensions(420, 28)
  titleLbl:SetText(title or "")

  -- Body (white, word-wrap)
  local bodyLbl = WM:CreateControl("DM2StatsAnnouncementBody", win, CT_LABEL)
  bodyLbl:SetFont("EsoUI/Common/Fonts/univers57.otf|17|soft-shadow-thin")
  bodyLbl:SetColor(0.92, 0.92, 0.92, 1)
  bodyLbl:SetAnchor(TOPLEFT, titleLbl, BOTTOMLEFT, 0, 8)
  bodyLbl:SetDimensions(420, 100)
  bodyLbl:SetWrapMode(TEXT_WRAP_MODE_WORD)
  bodyLbl:SetMaxLineCount(5)
  bodyLbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
  bodyLbl:SetText(body or "")

  -- "Got it!" dismiss button (clickable label)
  local btn = WM:CreateControl("DM2StatsAnnouncementBtn", win, CT_LABEL)
  btn:SetFont("EsoUI/Common/Fonts/univers67.otf|18|soft-shadow-thick")
  btn:SetColor(0.4, 0.9, 1.0, 1)
  btn:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 20, -14)
  btn:SetDimensions(100, 24)
  btn:SetText("[ Got it! ]")
  btn:SetMouseEnabled(true)
  btn:SetHandler("OnMouseUp", function() dismissAnnouncement() end)
  btn:SetHandler("OnMouseEnter", function(self) self:SetColor(0.6, 1.0, 1.0, 1) end)
  btn:SetHandler("OnMouseExit", function(self) self:SetColor(0.4, 0.9, 1.0, 1) end)

  -- Countdown label (gray, right-aligned)
  local countdown = WM:CreateControl("DM2StatsAnnouncementCountdown", win, CT_LABEL)
  countdown:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thin")
  countdown:SetColor(0.6, 0.6, 0.6, 1)
  countdown:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -20, -16)
  countdown:SetDimensions(160, 18)
  countdown:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

  _announcementWin = win
  _announcementCountdownLabel = countdown
  _announcementSecondsLeft = 10
  countdown:SetText(string.format("Closing in %ds...", _announcementSecondsLeft))

  -- Countdown timer: tick every 1s, dismiss at 0
  R._announcementToken = (R._announcementToken or 0) + 1
  local myToken = R._announcementToken
  EM:RegisterForUpdate(R.name .. "_AnnounceCountdown", 1000, function()
    if R._announcementToken ~= myToken then
      EM:UnregisterForUpdate(R.name .. "_AnnounceCountdown")
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

local function pushTimelineToken(session, label, symbol, result, meta)
  if not session or not session.weave then return end
  session.weave.timeline = session.weave.timeline or {}
  local item = {
    label = label or "?",
    symbol = symbol or "",
    result = result or "Info",
  }
  if meta then
    for k,v in pairs(meta) do item[k] = v end
  end
  table.insert(session.weave.timeline, item)
end

local CHANNEL_DASH_COUNTS = {
  ["fatecarver"]            = 4,
  ["pragmatic fatecarver"]  = 4,
  ["exhausting fatecarver"] = 4,
  ["engulfing dragonfire"]  = 5,
  ["radiant destruction"]   = 3,
  ["radiant glory"]         = 3,
  ["radiant oppression"]    = 3,
  ["soul strike"]           = 3,
  ["soul assault"]          = 3,
  ["shatter soul"]          = 3,
  ["biting jabs"]           = 1,
  ["puncturing sweep"]      = 1,
  ["rapid strikes"]         = 1,
  ["bloodthirst"]           = 1,
}

local function getChannelDashCount(label)
  local n = safeLower(label or "")
  for key, count in pairs(CHANNEL_DASH_COUNTS) do
    if string.find(n, key, 1, true) then return count end
  end
  return 3
end

local function isChannelAbilityLabel(label)
  local n = safeLower(label or "")
  return string.find(n, "fatecarver", 1, true) ~= nil
      -- Templar beam (Radiant Destruction line)
      or string.find(n, "radiant destruction", 1, true) ~= nil
      or string.find(n, "radiant glory", 1, true) ~= nil
      or string.find(n, "radiant oppression", 1, true) ~= nil
      -- Templar jabs (short channel, locks out weaving)
      or string.find(n, "biting jabs", 1, true) ~= nil
      or string.find(n, "puncturing sweep", 1, true) ~= nil
      -- DW flurry (short channel, locks out weaving)
      or string.find(n, "rapid strikes", 1, true) ~= nil
      or string.find(n, "bloodthirst", 1, true) ~= nil
      -- DK channeled breath (Update 49, 4.8s channel)
      or string.find(n, "engulfing dragonfire", 1, true) ~= nil
      -- Soul Magic ultimate (long channel)
      or string.find(n, "soul strike", 1, true) ~= nil
      or string.find(n, "soul assault", 1, true) ~= nil
      or string.find(n, "shatter soul", 1, true) ~= nil
      -- Generic fallbacks
      or string.find(n, "beam", 1, true) ~= nil
      or string.find(n, "channel", 1, true) ~= nil
end

local function trimSkillLabel(label, maxLen)
  label = zo_strformat("<<1>>", label or "?")
  maxLen = tonumber(maxLen) or 22
  if string.len(label) > maxLen then
    return string.sub(label, 1, math.max(1, maxLen - 2)) .. ".."
  end
  return label
end

local function stripColorMarkup(text)
  text = tostring(text or "")
  text = text:gsub("|c%x%x%x%x%x%x", "")
  text = text:gsub("|r", "")
  return text
end

local function colorizeTimelineSymbol(symbol, result)
  symbol = tostring(symbol or "")
  local r = safeLower(result or "")
  if symbol == "" then return "" end
  if r == "good" then return "|c66FF66" .. symbol .. "|r" end
  if r == "late" then return "|cFFCC66" .. symbol .. "|r" end
  if r == "missed" then return "|cFF6666" .. symbol .. "|r" end
  if r == "too fast" then return "|c66AAFF" .. symbol .. "|r" end
  if r == "extra" then return "|cCC88FF" .. symbol .. "|r" end
  if r == "channel" then return "|c6699FF" .. symbol .. "|r" end
  return symbol
end

local function timelineTokenText(item)
  if not item then return "|r?|r" end
  local kind = item.kind or "skill"
  local label = stripColorMarkup(zo_strformat("<<1>>", item.label or "?"))
  local symbol = colorizeTimelineSymbol(item.symbol or "", item.result)

  -- v3.2.0: Color skill names by bar (Front=soft green, Back=soft blue)
  local bar = item.bar or ""
  local labelColored
  if kind == "postchannel" then
    label = trimSkillLabel(label ~= "" and label or "Post-Channel", 18)
    labelColored = "|cCCCCCC" .. label .. "|r"
  elseif kind == "channel" then
    label = trimSkillLabel(label, 18)
    local dashCount = tonumber(item.dashes) or 3
    local dashes = string.rep("-", dashCount)
    if bar == "Front" then labelColored = "|c88DDAA" .. label .. "|r"
    elseif bar == "Back" then labelColored = "|c88AADD" .. label .. "|r"
    else labelColored = label end
    return labelColored .. " " .. colorizeTimelineSymbol(dashes, "Channel")
  else
    label = trimSkillLabel(label, 18)
    if bar == "Front" then labelColored = "|c88DDAA" .. label .. "|r"
    elseif bar == "Back" then labelColored = "|c88AADD" .. label .. "|r"
    else labelColored = label end
  end

  if symbol ~= "" then
    return string.format("%s %s", labelColored, symbol)
  end
  return labelColored
end

local function finalizePendingWeave(session, forcedMiss)
  if not session or not session.weave or not session.weave.pendingSkill then return end
  local pending = session.weave.pendingSkill
  if forcedMiss then
    pushTimelineToken(session, pending.label, SYM_MISS, "Missed", { skillName = pending.skillName or pending.label, kind = "skill", missed = true })
  end
  session.weave.pendingSkill = nil
end

local function buildRotationSummary(session)
  local out = {}
  if not session or not session.weave then return out end
  local countsBySkill = {}
  local missAfterChannel = 0
  local missTotal = 0
  for _,item in ipairs(session.weave.timeline or {}) do
    if item.missed then
      missTotal = missTotal + 1
      if item.kind == "postchannel" then
        missAfterChannel = missAfterChannel + 1
      end
      local key = item.skillName or item.label or "?"
      countsBySkill[key] = (countsBySkill[key] or 0) + 1
    end
  end
  local worstSkill, worstCount = "-", 0
  for k,v in pairs(countsBySkill) do
    if v > worstCount then worstSkill, worstCount = k, v end
  end

  local w = session.weave or {}
  local good = tonumber(w.onTimeCount) or 0
  local late = tonumber(w.lateCount) or 0
  local missed = tonumber(w.missedCount) or 0
  local tooFast = tonumber(w.tooFastCount) or 0
  local total = good + late + missed + tooFast
  local weaveRatio = (total > 0) and math.max(0, math.min(1, (good + late) / total)) or 0

  -- v3.2.2: Condensed to single row — detail moved to per-skill table
  table.insert(out, string.format("Weave Success: %s", fmtPct(weaveRatio)))
  table.insert(out, string.format("Skill Presses: %d", tonumber(w.inputSkillPresses) or tonumber(w.skillEventCount) or 0))
  table.insert(out, string.format("Bar Swaps: %d", tonumber(w.barSwapCount) or 0))
  return out
end

-- ----------------------------
-- Context-sensitive rotation hints (v3.1.0)
-- Picks the most relevant tip based on the observed rotation issues.
-- ----------------------------
local function buildRotationHint(session)
  if not session or not session.weave then return "" end
  local w = session.weave
  local timeline = w.timeline or {}
  if #timeline == 0 then return "" end

  local good = tonumber(w.onTimeCount) or 0
  local late = tonumber(w.lateCount) or 0
  local missed = tonumber(w.missedCount) or 0
  local tooFast = tonumber(w.tooFastCount) or 0
  local total = good + late + missed + tooFast
  local weaveRatio = (total > 0) and ((good + late) / total) or 0

  -- Count post-channel misses
  local postChannelMisses = 0
  local postChannelTotal = 0
  for _,item in ipairs(timeline) do
    if item.kind == "postchannel" then
      postChannelTotal = postChannelTotal + 1
      if item.missed then postChannelMisses = postChannelMisses + 1 end
    end
  end

  -- Count back-to-back skill misses (two skills without LA between them)
  local consecutiveSkillMisses = 0
  local prevWasSkillMiss = false
  for _,item in ipairs(timeline) do
    if item.kind == "skill" and item.missed then
      if prevWasSkillMiss then
        consecutiveSkillMisses = consecutiveSkillMisses + 1
      end
      prevWasSkillMiss = true
    else
      prevWasSkillMiss = false
    end
  end

  -- Pick the most impactful hint based on what's actually going wrong
  -- Priority: post-channel recovery > consecutive misses > too many lates > general tips

  -- 1. Post-channel recovery issues (very common confusion)
  if postChannelMisses > 0 and postChannelMisses >= (postChannelTotal / 2) then
    return "|cAADDFFTip:|r After a channel (Fatecarver, Beam, Jabs) ends, press |cFFFF88Light Attack|r first, then your next skill. " ..
           "Channels pause the LA weave — resume with LA to keep the rhythm going."
  end

  -- 2. Too many fast presses (mashing buttons before GCD is ready)
  if tooFast > 3 and tooFast > good then
    return "|cAADDFFTip:|r Several weaves were |c66AAFFtoo fast|r — you're pressing LA before the GCD allows it. " ..
           "Wait for your skill's animation to nearly finish (~0.8s), then press LA."
  end

  -- 3. Lots of consecutive skill misses (forgetting to LA between skills)
  if consecutiveSkillMisses >= 3 then
    return "|cAADDFFTip:|r Multiple skills fired back-to-back without Light Attacks between them. " ..
           "The weave pattern is: |cFFFF88LA -> Skill -> LA -> Skill|r. Every skill press should be preceded by a Light Attack."
  end

  -- 4. Many lates (GCD management)
  if late > 4 and late > good then
    return "|cAADDFFTip:|r Many |cFFCC66late|r weaves detected — the gap between skill and next LA was too long. " ..
           "Try pressing LA sooner after each skill. Aim for a steady ~1s rhythm: LA, Skill, LA, Skill."
  end

  -- 5. Many misses overall
  if missed > 5 and weaveRatio < 0.6 then
    return "|cAADDFFTip:|r Weave success is below 60%. Focus on the basic pattern: |cFFFF88LA -> Skill -> LA -> Skill|r. " ..
           "Press LA (R2 tap) between every single skill activation. Consistency matters more than speed."
  end

  -- 6. Post-channel tip (even if not missing, if channels are present)
  if postChannelTotal > 0 and postChannelMisses > 0 then
    return "|cAADDFFTip:|r You missed " .. postChannelMisses .. " post-channel weave(s). " ..
           "After a channel ends, immediately tap |cFFFF88LA -> Skill|r to resume the weave cycle."
  end

  -- 7. Good performance encouragement
  if weaveRatio >= 0.85 and total >= 8 then
    return "|c66FF66Nice rotation!|r " .. string.format("%.0f%%", weaveRatio * 100) ..
           " weave success. Keep the rhythm steady. Watch for any |cFF6666x|r misses in the timeline to find remaining gaps."
  end

  -- 8. General tips (rotate through based on fight timestamp for variety)
  local generalTips = {
    "|cAADDFFTip:|r The ideal weave pattern is |cFFFF88LA -> Skill -> LA -> Skill|r, with ~1 second per cycle. " ..
    "Tap R2 (Light Attack) between every skill for maximum DPS.",
    "|cAADDFFTip:|r |c66FF66+|r = good weave, |cFFCC66~|r = late (slow but counted), |cFF6666x|r = missed (no LA detected). " ..
    "Aim for all green in the timeline.",
    "|cAADDFFTip:|r Bar swap resets the weave. After swapping, start fresh: |cFFFF88LA -> first skill on new bar -> LA -> next skill|r.",
    "|cAADDFFTip:|r DOTs and ground effects (Wall of Fire, Barbed Trap) still need an LA weave. " ..
    "Even though they tick automatically, you must LA before casting them.",
  }
  local tipIdx = (math.floor((session.completedAt or 0) / 10) % #generalTips) + 1
  return generalTips[tipIdx]
end

-- v3.2.0: Returns an ARRAY of line strings (one per label) instead of a single string.
-- Uses visible-character budgeting (strips color markup for length measurement) to maximize
-- content per line and avoid ESO's per-string color markup processing limit.
local function buildTimelineLines(session, visibleCharLimit)
  visibleCharLimit = tonumber(visibleCharLimit) or 160
  if not session or not session.weave or not session.weave.timeline or #session.weave.timeline == 0 then
    return { "No rotation timeline captured yet. Run a fight, then open this page to see where your weaves held or slipped." }
  end

  local lines, current, currentVisible = {}, "", 0
  local prevToken, repeatCount = nil, 0

  local function flushToken(token)
    if not token or token == "" then return end
    local tokenVisible = string.len(stripColorMarkup(token))
    if current == "" then
      current = token
      currentVisible = tokenVisible
    elseif currentVisible + 3 + tokenVisible > visibleCharLimit then
      table.insert(lines, current)
      current = token
      currentVisible = tokenVisible
    else
      current = current .. "   " .. token
      currentVisible = currentVisible + 3 + tokenVisible
    end
  end

  local function pushMaybeGrouped(token)
    if prevToken == nil then
      prevToken = token
      repeatCount = 1
      return
    end
    if token == prevToken then
      repeatCount = repeatCount + 1
      return
    end
    if repeatCount > 1 then
      flushToken(string.format("%s x%d", prevToken, repeatCount))
    else
      flushToken(prevToken)
    end
    prevToken = token
    repeatCount = 1
  end

  for _,item in ipairs(session.weave.timeline) do
    pushMaybeGrouped(timelineTokenText(item))
  end

  if prevToken ~= nil then
    if repeatCount > 1 then
      flushToken(string.format("%s x%d", prevToken, repeatCount))
    else
      flushToken(prevToken)
    end
  end

  if current ~= "" then table.insert(lines, current) end
  return lines
end

local ROTATION_EXCLUDE_NAMES = {
  -- weapon enchant procs
  ["poisoned weapon"] = true,
  ["fiery weapon"] = true,
  ["overcharged"] = true,
  ["befouled weapon"] = true,
  ["frozen weapon"] = true,
  ["charged weapon"] = true,
  ["hardening"] = true,
  -- status effects / debuffs
  ["chill"] = true,
  ["chilled"] = true,
  ["burning"] = true,
  ["concussion"] = true,
  ["concussed"] = true,
  ["sundered"] = true,
  ["off balance"] = true,
  ["diseased"] = true,
  ["hemorrhaging"] = true,
  ["defile"] = true,
  ["breach"] = true,
  ["fracture"] = true,
  ["maim"] = true,
  ["empower"] = true,
  -- class passives / procs (not player-cast)
  ["fated fortune"] = true,
}

-- v3.0.25: ROTATION_CAPTURE_COOLDOWN_MS, ROTATION_CAPTURE_NAME_OVERRIDES_MS,
-- and ROTATION_EFFECT_ALLOWLIST removed. No longer needed with input-based capture.

local ROTATION_ALIAS_PATTERNS = {
  { "pragmatic fatecarver", "fatecarver" },
  { "exhausting fatecarver", "fatecarver" },
  { "fatecarver", "fatecarver" },
  { "unstable wall of fire", "unstable wall" },
  { "wall of fire", "unstable wall" },
  { "unstable wall", "unstable wall" },
  { "barbed trap", "barbed trap" },
  { "lightweight beast trap", "barbed trap" },
  { "trap beast", "barbed trap" },
  { "cephaliarch", "flail" },
  { "flail", "flail" },
  { "escalating runeblades", "runeblades" },
  { "writhing runeblades", "runeblades" },
  { "runeblades", "runeblades" },
  { "inspired scholarship", "scholarship" },
  { "scholarship", "scholarship" },
  { "soul of flame", "soul of flame" },
  { "rending slashes", "rending slashes" },
  { "the imperfect ring", "the imperfect ring" },
}

local function compactRotationName(s)
  s = normalizeNameKey(s)
  if s == "" then return "" end
  s = s:gsub("[^%a%d]", "")
  return s
end

local function canonicalRotationNameKey(name)
  local key = normalizeNameKey(name)
  if key == "" then return "" end
  for _, pair in ipairs(ROTATION_ALIAS_PATTERNS) do
    if key:find(pair[1], 1, true) then
      return pair[2]
    end
  end
  return key
end

local function findMatchingSlottedNameKey(session, abilityName)
  if not session or not session.slottedAbilityNames then return nil end
  local raw = normalizeNameKey(abilityName)
  if raw ~= "" and session.slottedAbilityNames[raw] then return raw end
  local canon = canonicalRotationNameKey(abilityName)
  if canon ~= "" and session.slottedAbilityNames[canon] then return canon end
  local compact = compactRotationName(abilityName)
  if compact == "" then return nil end
  for slottedKey,_ in pairs(session.slottedAbilityNames) do
    local sc = compactRotationName(slottedKey)
    if sc ~= "" and (sc == compact or (string.len(sc) >= 6 and (sc:find(compact, 1, true) or compact:find(sc, 1, true)))) then
      return slottedKey
    end
    local slottedCanon = canonicalRotationNameKey(slottedKey)
    if slottedCanon ~= "" and slottedCanon == canon then
      return slottedKey
    end
  end
  return nil
end

local function buildWeaveSkillBarMap(session)
  local map = {}
  if not session or not session.weave or not session.weave.timeline then return map end
  for _, item in ipairs(session.weave.timeline) do
    if item and (item.bar == "Front" or item.bar == "Back") then
      local name = item.skillName or item.label
      if name and name ~= "" then
        local key = normalizeNameKey(name)
        if key ~= "" then map[key] = item.bar end
        local canon = canonicalRotationNameKey(name)
        if canon ~= "" then map[canon] = item.bar end
      end
    end
  end
  return map
end

local function rememberSkillBarName(session, abilityName, barLabel)
  if not session or not abilityName or abilityName == "" then return end
  if barLabel ~= "Front" and barLabel ~= "Back" then return end
  session.slottedAbilityBarByName = session.slottedAbilityBarByName or {}
  local key = normalizeNameKey(abilityName)
  if key ~= "" then session.slottedAbilityBarByName[key] = barLabel end
  local canon = canonicalRotationNameKey(abilityName)
  if canon ~= "" then session.slottedAbilityBarByName[canon] = barLabel end
  if session.weave then
    session.weave.skillBarByName = session.weave.skillBarByName or {}
    if key ~= "" then session.weave.skillBarByName[key] = barLabel end
    if canon ~= "" then session.weave.skillBarByName[canon] = barLabel end
  end
end

local function lookupBarByName(session, abilityName)
  if not session or not abilityName or abilityName == "" then return nil end
  local byName = session.slottedAbilityBarByName
  if byName then
    local slottedKey = findMatchingSlottedNameKey(session, abilityName)
    if slottedKey and byName[slottedKey] then return byName[slottedKey] end
    local key = normalizeNameKey(abilityName)
    if key ~= "" and byName[key] then return byName[key] end
    local canon = canonicalRotationNameKey(abilityName)
    if canon ~= "" and byName[canon] then return byName[canon] end
  end
  if session.weave and session.weave.timeline then
    if not session.weave.skillBarByName then
      session.weave.skillBarByName = buildWeaveSkillBarMap(session)
    end
    local weaveBars = session.weave.skillBarByName or {}
    local key = normalizeNameKey(abilityName)
    if key ~= "" and weaveBars[key] then
      return weaveBars[key]
    end
    local canon = canonicalRotationNameKey(abilityName)
    if canon ~= "" and weaveBars[canon] then
      return weaveBars[canon]
    end
  end
  return nil
end

local function ensureBarByNameMap(session)
  if not session or type(session.slottedAbilityBar) ~= "table" then return end
  if session.slottedAbilityBarByName and next(session.slottedAbilityBarByName) then return end
  session.slottedAbilityBarByName = session.slottedAbilityBarByName or {}
  for idKey, bar in pairs(session.slottedAbilityBar) do
    if bar == "Front" or bar == "Back" then
      local id = tonumber(idKey) or 0
      if id > 0 then rememberSkillBarName(session, resolveAbilityName(id), bar) end
    end
  end
end

local function getSkillBar(session, abilityId, abilityName)
  if not session then return nil end
  ensureBarByNameMap(session)
  local barMap = session.slottedAbilityBar
  if type(barMap) ~= "table" then return lookupBarByName(session, abilityName) end

  local key = abilityBarKey(abilityId)
  if key and barMap[key] then return barMap[key] end
  if key and barMap[tonumber(key)] then return barMap[tonumber(key)] end

  if abilityName and abilityName ~= "" then
    local byName = lookupBarByName(session, abilityName)
    if byName then return byName end
    local targetKey = normalizeNameKey(abilityName)
    if targetKey ~= "" and session.skills then
      for slotKey, bar in pairs(barMap) do
        local slotId = tonumber(slotKey) or 0
        if slotId > 0 then
          local sk = session.skills[slotId]
          if sk and normalizeNameKey(sk.name) == targetKey then return bar end
          if normalizeNameKey(resolveAbilityName(slotId)) == targetKey then return bar end
        end
      end
    end
  end
  return nil
end

local function recordSkillBar(session, abilityId, barLabel, abilityName)
  if not session or not abilityId or abilityId <= 0 then return end
  if barLabel ~= "Front" and barLabel ~= "Back" then return end
  local key = abilityBarKey(abilityId)
  if not key then return end
  session.slottedAbilityBar = session.slottedAbilityBar or {}
  session.slottedAbilityBar[key] = barLabel
  rememberSkillBarName(session, abilityName, barLabel)
end

-- v3.2.0: DOT uptime calculation
-- Estimates uptime by looking at tick regularity. If ticks are regular (~2s apart),
-- gaps > 4s indicate the DOT dropped. Uptime = time covered by ticks / fight duration.
local function buildDotUptimeRows(session, maxRows)
  maxRows = tonumber(maxRows) or 6
  if not session or not session.dotTicks then return {} end
  local dur = (session.durationMs or 0)
  if dur <= 0 then return {} end

  local arr = {}
  for id, entry in pairs(session.dotTicks) do
    local ticks = entry and entry.ticks
    if ticks and #ticks >= 2 then
      -- Calculate median tick interval
      local intervals = {}
      for i = 2, #ticks do
        table.insert(intervals, ticks[i] - ticks[i-1])
      end
      table.sort(intervals)
      local medianInterval = intervals[math.ceil(#intervals / 2)] or 2000

      -- Count "covered" time: each tick covers up to 2x the median interval (generous)
      local maxGap = math.max(medianInterval * 2.5, 4000)
      local coveredMs = 0
      for i = 2, #ticks do
        local gap = ticks[i] - ticks[i-1]
        if gap <= maxGap then
          coveredMs = coveredMs + gap
        end
      end
      -- Add one interval for the last tick
      coveredMs = coveredMs + medianInterval

      local uptimePct = math.min(1.0, coveredMs / dur)
      table.insert(arr, { id = id, name = entry.name, uptime = uptimePct, ticks = #ticks })
    end
  end

  table.sort(arr, function(a,b) return a.uptime < b.uptime end)  -- worst uptime first
  local rows = {}
  for i = 1, math.min(maxRows, #arr) do
    local d = arr[i]
    rows[i] = richRow({
      trimSkillLabel(d.name, 22),
      string.format("%.0f%%", d.uptime * 100),
      tostring(d.ticks) .. " ticks",
    }, { abilityId = tonumber(d.id) or 0, bar = getSkillBar(session, d.id, d.name) })
  end
  return rows
end

-- v3.2.0: Per-skill weave breakdown — aggregate Good/Late/Miss per skill
local function buildPerSkillWeaveRows(session, maxRows)
  maxRows = tonumber(maxRows) or 6
  if not session or not session.weave or not session.weave.timeline then return {} end
  local bySkill = {}
  for _,item in ipairs(session.weave.timeline) do
    if item and (item.kind == "skill" or item.kind == "postchannel") then
      local displayName = resolveWeaveSkillDisplayName(session, item)
      local abilityId = tonumber(item.abilityId) or 0
      if abilityId <= 0 and not isPlaceholderAbilityLabel(displayName) then
        abilityId = findSkillAbilityId(session, displayName)
      end
      local key = abilityId > 0 and ("id:" .. tostring(abilityId)) or safeLower(displayName)
      if not bySkill[key] then
        bySkill[key] = { name = displayName, abilityId = abilityId, good = 0, late = 0, missed = 0, fast = 0, total = 0 }
      end
      local r = safeLower(item.result or "")
      if r == "good" then bySkill[key].good = bySkill[key].good + 1
      elseif r == "late" then bySkill[key].late = bySkill[key].late + 1
      elseif r == "missed" then bySkill[key].missed = bySkill[key].missed + 1
      elseif r == "too fast" then bySkill[key].fast = bySkill[key].fast + 1 end
      bySkill[key].total = bySkill[key].total + 1
    end
  end
  local arr = {}
  for _,v in pairs(bySkill) do table.insert(arr, v) end
  table.sort(arr, function(a,b) return a.total > b.total end)
  local rows = {}
  for i = 1, math.min(maxRows, #arr) do
    local s = arr[i]
    local goodPct = s.total > 0 and math.floor(s.good / s.total * 100 + 0.5) or 0
    local abilityId = tonumber(s.abilityId) or 0
    if abilityId <= 0 then abilityId = findSkillAbilityId(session, s.name) end
    rows[i] = richRow({
      trimSkillLabel(s.name, 22),
      string.format("%d%%", goodPct),
      tostring(s.good),
      tostring(s.late),
      tostring(s.missed),
    }, { abilityId = abilityId, bar = getSkillBar(session, abilityId, s.name) })
  end
  return rows
end

local function getRotationCaptureKey(session, abilityId, abilityName)
  local slottedNameKey = findMatchingSlottedNameKey(session, abilityName)
  if slottedNameKey then return "slot:" .. slottedNameKey end
  local canon = canonicalRotationNameKey(abilityName)
  if canon ~= "" then return "name:" .. canon end
  local keyId = tonumber(abilityId) or 0
  if keyId > 0 then return "id:" .. tostring(keyId) end
  return "name:" .. normalizeNameKey(abilityName)
end

-- v3.0.25: isDebugRelevantRotationSkill, getRotationCaptureCooldownMs,
-- shouldCaptureRotationEvent, markRotationEventCaptured removed.
-- Input-based capture doesn't need these filters — each button press is a single event.

local function trackRotationDebug(session, abilityId, abilityName, captured, reason)
  if not SV or not SV.settings.debugRotation then return end
  if not session then return end
  -- v3.0.25: with input-based capture, log all skill presses unconditionally when debug is on.
  -- The old isDebugRelevantRotationSkill filter was needed for damage-event inference;
  -- input events are already pre-filtered (only action bar slot presses fire the event).
  session.rotationDebug = session.rotationDebug or {}
  local displayName = resolveAbilityName(abilityId, abilityName)
  local key = getRotationCaptureKey(session, abilityId, displayName)
  if key == "" then key = tostring(abilityId or 0) end
  local entry = session.rotationDebug[key]
  if not entry then
    entry = { id = tonumber(abilityId) or 0, name = displayName or "?", captured = 0, skipped = 0, lastReason = "" }
    session.rotationDebug[key] = entry
  end
  if captured then
    entry.captured = entry.captured + 1
    -- v3.0.25: store slot/bar info from input-based capture as reason
    if reason and reason ~= "" then entry.lastReason = reason end
  else
    entry.skipped = entry.skipped + 1
    entry.lastReason = reason or ""
  end
end

-- v3.0.25: isRotationEligibleSkill, captureRotationSkillEvent, shouldTrackRotationDebugEvent,
-- shouldCaptureRotationEvent, markRotationEventCaptured, getRotationCaptureCooldownMs all removed.
-- Rotation capture is now input-based via EVENT_ACTION_SLOT_ABILITY_USED in OnActionSlotAbilityUsed().
-- The old damage-inference approach with cooldown deduplication, name matching, and eligibility
-- filtering is no longer needed — each button press from the action bar is a discrete event.

-- ----------------------------
-- History management
-- ----------------------------
local function ensureSV()
  if not SV then return end
  SV.settings = SV.settings or {}
  SV.ui = SV.ui or {}
  SV.history = SV.history or {}
  if SV.lastIndex == nil then SV.lastIndex = 0 end

  -- one-time merge defaults
  if not SV._init then
    -- shallow merge is fine for our v1 structure
    for k,v in pairs(R.defaults.settings) do if SV.settings[k] == nil then SV.settings[k] = v end end
    for k,v in pairs(R.defaults.ui) do if SV.ui[k] == nil then SV.ui[k] = v end end
    SV._init = true
  end

  -- one-time size migration for the expanded layout
  if not SV._layout_195b then
    local curW = tonumber(SV.ui.w) or 0
    local curH = tonumber(SV.ui.h) or 0
    if curW < 1300 then SV.ui.w = 1400 end
    if curH < 850 then SV.ui.h = 920 end
    SV._layout_195b = true
  end
end

local function clearHistory()
  SV.history = {}
  SV.lastIndex = 0
end

local function pushHistory(session)
  local max = tonumber(SV.settings.historyMax) or 20
  if max < 1 then max = 20 end

  -- ring buffer at 1..max
  SV.lastIndex = (SV.lastIndex or 0) + 1
  local slot = ((SV.lastIndex - 1) % max) + 1
  SV.history[slot] = session
end

local function getHistoryCount()
  local max = tonumber(SV.settings.historyMax) or 20
  local idx = tonumber(SV.lastIndex) or 0
  return math.min(idx, max)
end

local function getHistoryAt(offsetFromLatest)
  offsetFromLatest = tonumber(offsetFromLatest) or 0
  local max = tonumber(SV.settings.historyMax) or 20
  local idx = tonumber(SV.lastIndex) or 0
  if idx <= 0 then return nil end

  local latestSlot = ((idx - 1) % max) + 1
  local slot = latestSlot - offsetFromLatest
  while slot < 1 do slot = slot + max end
  while slot > max do slot = slot - max end
  return SV.history[slot]
end

-- Public history API for experimental gamepad menu shell (MenuShell.lua).
function R:GetMenuHistoryCount()
  if not SV then return 0 end
  return getHistoryCount()
end

function R:GetMenuHistoryAt(offsetFromLatest)
  if not SV then return nil end
  return getHistoryAt(offsetFromLatest)
end

function R:GetMenuBucketMs()
  if not SV or not SV.settings then return 2000 end
  return tonumber(SV.settings.bucketMs) or 2000
end

local function getViewedHistoryIndex(offsetFromLatest)
  local count = getHistoryCount()
  if count <= 0 then return 0, 0 end
  local offset = tonumber(offsetFromLatest) or 0
  local idx = count - offset
  if idx < 1 then idx = 1 end
  if idx > count then idx = count end
  return idx, count
end

local function ordinalDay(n)
  n = tonumber(n) or 0
  local mod100 = n % 100
  if mod100 >= 11 and mod100 <= 13 then return tostring(n) .. "th" end
  local mod10 = n % 10
  if mod10 == 1 then return tostring(n) .. "st" end
  if mod10 == 2 then return tostring(n) .. "nd" end
  if mod10 == 3 then return tostring(n) .. "rd" end
  return tostring(n) .. "th"
end

local function formatClock12(hour, min, sec)
  hour = tonumber(hour) or 0
  min = tonumber(min) or 0
  sec = tonumber(sec) or 0
  local suffix = (hour >= 12) and "PM" or "AM"
  local h12 = hour % 12
  if h12 == 0 then h12 = 12 end
  return string.format("%d:%02d:%02d %s", h12, min, sec, suffix)
end

local function formatSessionTimestamp(session)
  local ts = session and (session.completedAt or session.endEpoch or session.timestamp)
  ts = tonumber(ts)
  if not ts or ts <= 0 then return "-" end
  local t = os.date("*t", ts)
  if not t then return "-" end
  return string.format("%s, %s %s, %d @ %s", os.date("%A", ts), os.date("%B", ts), ordinalDay(t.day), t.year, formatClock12(t.hour, t.min, t.sec))
end

-- Short format for compact lists: "03/29 20:34"
local function formatSessionTimestampShort(session)
  local ts = session and (session.completedAt or session.endEpoch or session.timestamp)
  ts = tonumber(ts)
  if not ts or ts <= 0 then return "-" end
  return os.date("%m/%d %H:%M", ts)
end

local function truncateText(text, maxLen)
  text = tostring(text or "?")
  maxLen = tonumber(maxLen) or 14
  if #text <= maxLen then return text end
  return string.sub(text, 1, maxLen - 1) .. "…"
end

local function formatFightHeaderLabel(session)
  if not session then return "" end
  local target = truncateText(session.lastTargetName or "Unknown", 18)
  if session.isDummy then target = target .. " *" end
  local when = formatSessionTimestampShort(session)
  local dur = fmtDur(tonumber(session.durationMs) or 0)
  local durSec = (tonumber(session.durationMs) or 0) / 1000
  local dps = durSec > 0 and fmtDps((tonumber(session.totalDamage) or 0) / durSec) or "-"
  return string.format("%s\n%s  %s\n%s DPS", target, when, dur, dps)
end

local function formatFightHeaderCompact(session)
  if not session then return "" end
  local target = truncateText(session.lastTargetName or "?", 12)
  if session.isDummy then target = target .. " *" end
  return string.format("%s\n%s", target, formatSessionTimestampShort(session))
end

local function sessionDenseBuckets(session)
  local denseBuckets = {}
  if not session or not session.buckets then return denseBuckets end
  for idx, b in pairs(session.buckets) do
    table.insert(denseBuckets, { idx = idx, dmg = tonumber(b.dmg) or 0 })
  end
  table.sort(denseBuckets, function(a, b) return a.idx < b.idx end)
  return denseBuckets
end

-- ----------------------------
-- Spike/dip analysis
-- ----------------------------
local function analyzeBuckets(session)
  local ignoreFirst = tonumber(SV.settings.ignoreFirstMs) or 0
  local ignoreLast  = tonumber(SV.settings.ignoreLastMs) or 0

  local startMs = session.startMs
  local endMs   = session.endMs
  local bucketMs = tonumber(SV.settings.bucketMs) or 2000

  local candidates = {}
  for idx, b in pairs(session.buckets) do
    local bucketStart = startMs + (idx * bucketMs)
    local bucketEnd   = bucketStart + bucketMs

    if bucketEnd <= (startMs + ignoreFirst) then
      -- ignore early ramp
    elseif bucketStart >= (endMs - ignoreLast) then
      -- ignore tail
    else
      table.insert(candidates, { idx=idx, dmg=b.dmg, crit=b.crit, hits=b.hits, direct=b.direct, dot=b.dot, skills=b.skills })
    end
  end

  table.sort(candidates, function(a,b) return a.dmg > b.dmg end)

  local peaks = {}
  local dips = {}

  for i=1, math.min(3, #candidates) do peaks[i] = candidates[i] end

  -- dips: sort ascending but ignore zero windows if possible
  table.sort(candidates, function(a,b) return a.dmg < b.dmg end)
  local found = 0
  for i=1, #candidates do
    if candidates[i].dmg > 0 then
      found = found + 1
      dips[found] = candidates[i]
      if found >= 3 then break end
    end
  end

  return peaks, dips
end

local function topSkillsInWindow(skillsMap, n, session)
  n = n or 3
  local arr = {}
  for abilityId, dmg in pairs(skillsMap or {}) do
    table.insert(arr, { id = abilityId, dmg = dmg })
  end
  table.sort(arr, function(a,b) return a.dmg > b.dmg end)
  local out = {}
  for i=1, math.min(n, #arr) do
    local id = arr[i].id
    local s = session and session.skills and session.skills[id] or nil
    local name = (s and s.name) or resolveAbilityName(id, nil)
    table.insert(out, { id=id, dmg=arr[i].dmg, name = name })
  end
  return out
end

-- ----------------------------
-- Weaving stats
-- ----------------------------
local function weaveSummary(session)
  local w = session.weave or {}
  local intervals = {}
  for _,d in ipairs(w.laIntervals or {}) do
    if d and d > 0 then table.insert(intervals, d) end
  end

  local n = #intervals
  local laCount = tonumber(w.laCount) or 0
  local durMs = tonumber(session and session.durationMs) or 0
  local laPerSec = (durMs > 0) and (laCount / (durMs / 1000)) or 0

  if n == 0 then
    return {
      laHits = laCount,
      laPerSec = laPerSec,
      avgGap = 0,
      bestGap = 0,
      worstGap = 0,
      goodTiming = 0,
      tooFast = tonumber(w.tooFastCount) or 0,
      onTime = tonumber(w.onTimeCount) or 0,
      late = tonumber(w.lateCount) or 0,
      missed = tonumber(w.missedCount) or 0,
      extraLAs = tonumber(w.extraLAs) or 0,
      fastSkillPresses = tonumber(w.fastSkillPresses) or 0,
      samples = 0,
    }
  end

  table.sort(intervals)
  local sum = 0
  local best = nil
  local worst = 0
  for _,d in ipairs(intervals) do
    sum = sum + d
    if (not best) and d >= 250 then best = d end
    if d > worst then worst = d end
  end
  if not best then best = intervals[1] end

  local onTime = tonumber(w.onTimeCount) or 0

  return {
    laHits = laCount,
    laPerSec = laPerSec,
    avgGap = sum / n,
    bestGap = best or 0,
    worstGap = worst or 0,
    goodTiming = (n > 0) and (onTime / n) or 0,
    tooFast = tonumber(w.tooFastCount) or 0,
    onTime = onTime,
    late = tonumber(w.lateCount) or 0,
    missed = tonumber(w.missedCount) or 0,
    extraLAs = tonumber(w.extraLAs) or 0,
    fastSkillPresses = tonumber(w.fastSkillPresses) or 0,
    samples = n,
  }
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

-- ----------------------------
-- Export parse to chat (v3.2.2)
-- ----------------------------
local function exportParseToChat(session)
  if not session then
    d("|c88ff88DM2 Stats|r: no fight data to share.")
    return
  end
  local dur = (session.durationMs or 0)
  local durSec = dur > 0 and (dur / 1000) or 0
  local avgDps = durSec > 0 and (session.totalDamage / durSec) or 0
  local hitCount = session.hitCount or 0
  local critCount = session.critCount or 0
  local critPct = hitCount > 0 and (critCount / hitCount) or 0
  local weaveRatio = getWeaveSuccessRatio(session)
  local ws = weaveSummary(session)
  local target = session.lastTargetName or "?"
  local dummy = session.isDummy and "Dummy" or "Live"

  -- Format duration as M:SS
  local mins = math.floor(durSec / 60)
  local secs = math.floor(durSec % 60)
  local durStr = string.format("%d:%02d", mins, secs)

  local line = string.format(
    "|c88ff88[DM2]|r %s | %s %s | Avg %s | Peak %s | Crit %s | Weave %s | LA/s %.1f",
    target, durStr, dummy,
    fmtDps(avgDps),
    fmtDps(ws.laHits > 0 and ((session.maxHit or 0)) or 0),
    fmtPct(critPct),
    fmtPct(weaveRatio),
    ws.laPerSec or 0
  )
  d(line)
end

-- ----------------------------
-- UI helpers
-- ----------------------------
local function applyBarChip(chip, bar)
  if not chip then return end
  if bar == "Front" then
    chip:SetCenterColor(0.35, 0.85, 0.55, 1)
    chip:SetHidden(false)
  elseif bar == "Back" then
    chip:SetCenterColor(0.40, 0.62, 1.00, 1)
    chip:SetHidden(false)
  else
    chip:SetHidden(true)
  end
end

local function applyShareBar(backdrop, sharePct)
  if not backdrop then return end
  sharePct = math.max(0, math.min(1, tonumber(sharePct) or 0))
  local fullW = tonumber(backdrop.fullW) or backdrop:GetWidth() or 0
  if sharePct <= 0.001 or fullW <= 0 then
    backdrop:SetHidden(true)
    return
  end
  local barW = math.max(2, math.floor(fullW * sharePct + 0.5))
  backdrop:SetWidth(barW)
  backdrop:SetHidden(false)
end

local function font(size, weight)
  weight = weight or 57
  return string.format("EsoUI/Common/Fonts/univers%d.otf|%d|soft-shadow-thin", weight, size)
end

local function setLabel(ctrl, text)
  if ctrl and ctrl.SetText then ctrl:SetText(text or "") end
end

local function makeLabel(parent, name, size, r, g, b, a)
  local l = WM:CreateControl(name, parent, CT_LABEL)
  l:SetFont(font(size or 18))
  l:SetColor(r or 1, g or 1, b or 1, a or 1)
  l:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  l:SetText("")
  return l
end

local function makeBarChipLegend(parent, name, width)
  local c = WM:CreateControl(name, parent, CT_CONTROL)
  c:SetDimensions(width or 400, BAR_CHIP_LEGEND_H)
  local x = 0
  local function addEntry(barLabel, textLabel)
    local chip = WM:CreateControl(name .. "_Chip" .. barLabel, c, CT_BACKDROP)
    if not chip then return end
    chip:SetDimensions(8, 12)
    chip:SetAnchor(LEFT, c, LEFT, x, math.floor((BAR_CHIP_LEGEND_H - 12) / 2))
    chip:SetEdgeColor(0, 0, 0, 0)
    applyBarChip(chip, barLabel)
    x = x + 12
    local l = makeLabel(c, name .. "_Lbl" .. barLabel, 13, 0.65, 0.75, 0.75, 1)
    l:SetAnchor(LEFT, c, LEFT, x, 0)
    l:SetDimensions(96, BAR_CHIP_LEGEND_H)
    l:SetText(textLabel)
    l:SetMaxLineCount(1)
    x = x + 100
  end
  addEntry("Front", "Front bar")
  addEntry("Back", "Back bar")
  return c
end

local function makeSectionTitle(parent, name, size)
  local l = makeLabel(parent, name, size or 17, 0.42, 0.92, 0.88, 1)
  l:SetFont(font(size or 17, 67))
  return l
end

local function makeBackdrop(parent, name)
  local bg = WM:CreateControl(name, parent, CT_BACKDROP)
  local alpha = (SV and SV.ui and SV.ui.bgAlpha) or 0.65
  bg:SetCenterColor(0,0,0,1)
  bg:SetEdgeColor(1,1,1,0.35)
  bg:SetEdgeTexture(nil, 1, 1, 2)
  bg:SetAlpha(alpha)
  return bg
end

local function createPanel(parent, name)
  local p = WM:CreateControl(name, parent, CT_CONTROL)
  p.bg = makeBackdrop(p, name.."_BG")
  p.bg:SetAnchorFill(p)
  return p
end

local function createKpiBlock(parent, name)
  local c = WM:CreateControl(name, parent, CT_CONTROL)
  c:SetDimensions(1,1)
  c.bg = makeBackdrop(c, name.."_BG")
  c.bg:SetAnchorFill(c)

  c.value = makeLabel(c, name.."_Val", 26, 1,1,1,1)
  c.value:SetAnchor(TOPLEFT, c, TOPLEFT, 12, 8)
  c.value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

  c.label = makeLabel(c, name.."_Lab", 16, 0.85,0.85,0.85,1)
  c.label:SetAnchor(TOPLEFT, c.value, BOTTOMLEFT, 0, 2)

  return c
end

local function createRow(parent, name, cols, opts)
  opts = opts or {}
  local rowH = opts.rowH or 28
  local isHeader = opts.isHeader
  local headerRowH = opts.headerRowH or 30
  local headerCellH = isHeader and headerRowH or rowH
  local row = WM:CreateControl(name, parent, CT_CONTROL)
  row:SetHeight(isHeader and headerRowH or rowH)
  row.cols = {}
  row.icons = {}
  row.barChips = {}
  row.shareBars = {}
  local x = 0
  for i,col in ipairs(cols) do
    local w = col.w
    local kind = col.kind or "text"
    if kind == "icon" then
      if isHeader then
        local spacer = makeLabel(row, string.format("%s_C%d", name, i), 14, 0.9,0.9,0.9,1)
        spacer:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
        spacer:SetDimensions(w, headerCellH)
        row.cols[i] = spacer
      else
        local icon = WM:CreateControl(string.format("%s_I%d", name, i), row, CT_TEXTURE)
        icon:SetDimensions(ICON_SIZE, ICON_SIZE)
        icon:SetAnchor(LEFT, row, LEFT, x + 2, math.max(0, math.floor((rowH - ICON_SIZE) / 2)))
        icon:SetHidden(true)
        row.icons[i] = icon
      end
      x = x + w
    elseif kind == "bar" then
      if isHeader then
        local spacer = makeLabel(row, string.format("%s_C%d", name, i), 14, 0.9,0.9,0.9,1)
        spacer:SetAnchor(TOPLEFT, row, TOPLEFT, x, 0)
        spacer:SetDimensions(w, headerCellH)
        row.cols[i] = spacer
      else
        local chip = WM:CreateControl(string.format("%s_B%d", name, i), row, CT_BACKDROP)
        chip:SetDimensions(6, 18)
        chip:SetAnchor(LEFT, row, LEFT, x + 2, math.max(0, math.floor((rowH - 18) / 2)))
        chip:SetCenterColor(0.4, 0.4, 0.4, 0.25)
        chip:SetEdgeColor(0, 0, 0, 0)
        chip:SetHidden(true)
        row.barChips[i] = chip
      end
      x = x + w
    else
      local padL = col.padL or 8
      local padR = col.padR or 8
      local cellW = w - padL - padR
      if col.shareBar and not isHeader then
        local barBg = WM:CreateControl(string.format("%s_SB%d", name, i), row, CT_BACKDROP)
        barBg:SetAnchor(TOPLEFT, row, TOPLEFT, x + 2, 3)
        barBg:SetDimensions(cellW, math.max(8, rowH - 6))
        barBg:SetCenterColor(0.22, 0.52, 0.82, 0.32)
        barBg:SetEdgeColor(0, 0, 0, 0)
        barBg.fullW = cellW
        barBg:SetHidden(true)
        row.shareBars[i] = barBg
      end
      local l = makeLabel(row, string.format("%s_C%d", name, i), isHeader and 13 or 16, 1,1,1,1)
      l:SetAnchor(TOPLEFT, row, TOPLEFT, x + padL, 0)
      l:SetDimensions(cellW, headerCellH)
      l:SetHorizontalAlignment(col.align or TEXT_ALIGN_LEFT)
      if isHeader and headerRowH > 30 then
        l:SetVerticalAlignment(TEXT_ALIGN_TOP)
        l:SetWrapMode(TEXT_WRAP_MODE_WORD)
        l:SetMaxLineCount(3)
      else
        l:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        l:SetMaxLineCount(1)
      end
      row.cols[i] = l
      x = x + w
    end
  end
  row:SetWidth(x)
  return row
end

local function createList(parent, name, cols, maxRows, opts)
  maxRows = maxRows or 14
  opts = opts or {}
  local rowH = opts.rowH or 28
  local headerRowH = opts.headerRowH or 30
  local wrap = WM:CreateControl(name, parent, CT_CONTROL)
  wrap:SetDimensions(1,1)

  local header = createRow(wrap, name.."_Header", cols, { rowH = rowH, headerRowH = headerRowH, isHeader = true })
  header:SetAnchor(TOPLEFT, wrap, TOPLEFT, 0, 0)
  for i,col in ipairs(cols) do
    if header.cols[i] then
      header.cols[i]:SetFont(font(16, 67))
      header.cols[i]:SetColor(0.9,0.9,0.9,1)
      header.cols[i]:SetText(col.title or "")
    end
  end

  -- v3.2.2: Thin divider line below header for visual separation
  local divider = WM:CreateControl(name.."_Divider", wrap, CT_BACKDROP)
  divider:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 2)
  divider:SetDimensions(header:GetWidth(), 1)
  divider:SetCenterColor(0.5, 0.8, 0.9, 0.4)
  divider:SetEdgeColor(0, 0, 0, 0)

  local body = WM:CreateControl(name.."_Body", wrap, CT_CONTROL)
  body:SetAnchor(TOPLEFT, divider, BOTTOMLEFT, 0, 3)

  local rows = {}
  for i=1, maxRows do
    local r = createRow(body, string.format("%s_R%d", name, i), cols, { rowH = rowH })
    r:SetAnchor(TOPLEFT, body, TOPLEFT, 0, (i-1)*rowH)
    rows[i] = r
  end

  wrap.header = header
  wrap.body = body
  wrap.rows = rows
  wrap.cols = cols
  wrap.maxRows = maxRows
  wrap.rowH = rowH

  local totalW = header:GetWidth()
  wrap:SetWidth(totalW)
  wrap:SetHeight(headerRowH + 6 + (maxRows * rowH) + LIST_BOTTOM_PAD)
  body:SetHeight(maxRows * rowH)
  wrap.headerRowH = headerRowH

  return wrap
end


local updateCountdownLabel

local function pageCount()
  return #(R.pages or {})
end

function R:GetPage(pageIndex)
  local pages = self.pages or {}
  local count = #pages
  if count <= 0 then return nil, 0 end
  pageIndex = tonumber(pageIndex) or 1
  if pageIndex < 1 then pageIndex = 1 end
  if pageIndex > count then pageIndex = count end
  return pages[pageIndex], pageIndex
end

function R:SetPage(pageIndex)
  local page, idx = self:GetPage(pageIndex)
  if not page then return end
  self._pageIndex = idx
  if self.ui and self.ui.win and not self.ui.win:IsHidden() then
    self:RefreshPageState()
  end
end

function R:RefreshPageState()
  local ui = self.ui
  if not ui then return end
  local page, idx = self:GetPage(self._pageIndex or 1)
  if not page then return end

  if ui.pageTitle then
    ui.pageTitle:SetText(string.format("Page %d/%d  •  %s", idx, pageCount(), page.title or ""))
  end
  if ui.pageIndicator then
    local dots = {}
    for i = 1, pageCount() do
      dots[i] = (i == idx) and "●" or "○"
    end
    ui.pageIndicator:SetText(table.concat(dots, " "))
  end

  local isSummary = (page.id == "summary")
  local isDamage = (page.id == "damage")
  local isRotationDiag = (page.id == "rotationdiag")
  local isWeaveDetail = (page.id == "weavedetail")
  local isGear = (page.id == "gear")
  local isSetDetails = (page.id == "setdetails")
  local isBuffs = (page.id == "buffs")
  local isHistory = (page.id == "history")
  local isDebugLog = DEBUG_UI_ENABLED and (page.id == "debuglog")

  local fightOffset = tonumber(self._offset) or 0
  if self._lastPageIndex ~= idx or (isHistory and self._lastFightOffset ~= fightOffset) then
    self._lastPageIndex = idx
    if isHistory then self._lastFightOffset = fightOffset end
    if ui._scroll and type(ZO_Scroll_SetScrollOffset) == "function" then
      pcall(function() ZO_Scroll_SetScrollOffset(ui._scroll, 0) end)
    end
  end

  if ui.summaryPanel then ui.summaryPanel:SetHidden(not isSummary) end
  if ui.rotPanel then ui.rotPanel:SetHidden(not isSummary) end
  if ui.burstPanel then ui.burstPanel:SetHidden(not isSummary) end
  if ui.setPanel then ui.setPanel:SetHidden(not isSummary) end
  if ui.summarySkillsPanel then ui.summarySkillsPanel:SetHidden(not isSummary) end
  if ui.sparklinePanel then ui.sparklinePanel:SetHidden(not isSummary) end

  if ui.scrollWrap then ui.scrollWrap:SetHidden(isSummary or isWeaveDetail) end
  if ui.skillsPanel then ui.skillsPanel:SetHidden(not isDamage) end
  if ui.rotationDiagPanel then ui.rotationDiagPanel:SetHidden(not isRotationDiag) end
  if ui.weaveDetailPanel then ui.weaveDetailPanel:SetHidden(not isWeaveDetail) end
  if ui.gearPanel then ui.gearPanel:SetHidden(not isGear) end
  if ui.setDetailPanel then ui.setDetailPanel:SetHidden(not isSetDetails) end
  if ui.buffsPanel then ui.buffsPanel:SetHidden(not isBuffs) end
  if ui.historyPanel then ui.historyPanel:SetHidden(not isHistory) end
  if ui.trendPanel then ui.trendPanel:SetHidden(not isHistory) end
  if ui.snapshotPanel then ui.snapshotPanel:SetHidden(true) end
  if ui.debugPanel then ui.debugPanel:SetHidden(not isDebugLog) end

  if ui.scrollWrap and not isSummary and not isWeaveDetail then
    local scrollTopY = isHistory and HISTORY_SCROLL_TOP_Y or 186
    ui.scrollWrap:ClearAnchors()
    ui.scrollWrap:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, scrollTopY)
    ui.scrollWrap:SetAnchor(BOTTOMRIGHT, ui.win, BOTTOMRIGHT, -18, -SCROLL_BOTTOM_INSET)
  end

  if ui.skillsPanel then
    ui.skillsPanel:ClearAnchors()
    ui.skillsPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end
  if ui.rotationDiagPanel then
    ui.rotationDiagPanel:ClearAnchors()
    ui.rotationDiagPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end
  if ui.weaveDetailPanel then
    ui.weaveDetailPanel:ClearAnchors()
    ui.weaveDetailPanel:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, 186)
    ui.weaveDetailPanel:SetAnchor(BOTTOMRIGHT, ui.win, BOTTOMRIGHT, -18, -SCROLL_BOTTOM_INSET)
  end
  if ui.gearPanel then
    ui.gearPanel:ClearAnchors()
    ui.gearPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end
  if ui.setDetailPanel then
    ui.setDetailPanel:ClearAnchors()
    ui.setDetailPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end
  if ui.buffsPanel then
    ui.buffsPanel:ClearAnchors()
    ui.buffsPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end
  if ui.historyPanel then
    ui.historyPanel:ClearAnchors()
    ui.historyPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end
  local trendH = trendPanelHeight()
  local trendReserve = trendH + (isHistory and HISTORY_TREND_GAP or 0)
  if ui._scroll and ui.scrollWrap then
    ui._scroll:ClearAnchors()
    if isHistory then
      ui._scroll:SetAnchor(TOPLEFT, ui.scrollWrap, TOPLEFT, 0, 0)
      ui._scroll:SetAnchor(BOTTOMRIGHT, ui.scrollWrap, BOTTOMRIGHT, 0, -trendReserve)
    else
      ui._scroll:SetAnchorFill(ui.scrollWrap)
    end
  end
  if ui.trendPanel and ui.scrollWrap then
    ui.trendPanel:ClearAnchors()
    if isHistory then
      ui.trendPanel:SetAnchor(BOTTOMLEFT, ui.scrollWrap, BOTTOMLEFT, 0, 0)
      ui.trendPanel:SetAnchor(BOTTOMRIGHT, ui.scrollWrap, BOTTOMRIGHT, 0, 0)
      ui.trendPanel:SetHeight(trendH)
    end
  end

  if ui.snapshotPanel then
    ui.snapshotPanel:ClearAnchors()
    ui.snapshotPanel:SetAnchor(TOPLEFT, ui.historyPanel or ui._content, BOTTOMLEFT, 0, 12)
  end
  if ui.debugPanel then
    ui.debugPanel:ClearAnchors()
    ui.debugPanel:SetAnchor(TOPLEFT, ui._content, TOPLEFT, 0, 0)
  end

  local totalH = LIST_CONTENT_TAIL_PAD
  if isDamage and ui.skillsPanel then
    totalH = math.max(totalH, ui.skillsPanel:GetHeight() + LIST_CONTENT_TAIL_PAD)
  elseif isRotationDiag and ui.rotationDiagPanel then
    totalH = math.max(totalH, ui.rotationDiagPanel:GetHeight() + LIST_CONTENT_TAIL_PAD)
  elseif isGear and ui.gearPanel then
    totalH = math.max(totalH, ui.gearPanel:GetHeight() + LIST_CONTENT_TAIL_PAD)
  elseif isSetDetails and ui.setDetailPanel then
    totalH = math.max(totalH, ui.setDetailPanel:GetHeight() + LIST_CONTENT_TAIL_PAD)
  elseif isBuffs and ui.buffsPanel and ui.buffsList then
    local contentH = 36 + BAR_CHIP_LEGEND_H + 2 + 10 + ui.buffsList:GetHeight()
    local wrapH = ui.scrollWrap and ui.scrollWrap:GetHeight() or 0
    local h = math.max(contentH, wrapH - LIST_CONTENT_TAIL_PAD)
    ui.buffsPanel:SetHeight(h)
    totalH = math.max(totalH, h + LIST_CONTENT_TAIL_PAD)
  elseif isHistory and ui.historyPanel then
    totalH = math.max(totalH, ui.historyPanel:GetHeight())
  elseif isDebugLog and ui.debugPanel then
    totalH = math.max(totalH, ui.debugPanel:GetHeight() + LIST_CONTENT_TAIL_PAD)
  end
  if ui._content then ui._content:SetHeight(totalH) end

  if ui._scroll and ui._scroll.GetNamedChild then
    local sb = ui._scroll:GetNamedChild("ScrollBar")
    if sb then sb:SetHidden(false) end
  end

  updateCountdownLabel()
end

-- ----------------------------
-- UI build — Phase I paged viewer shell
-- Uses plain KEYBIND_STRIP (same pattern as DM2_Metrics)
-- NO scenes — scenes get killed by joystick movement on PS5
-- ----------------------------

function R:BuildUI()
  if self.ui.win then return end

  local ui = self.ui
  local x, y, w, h = SV.ui.x or 120, SV.ui.y or 120, SV.ui.w or 1160, SV.ui.h or 760

  ui.win = WM:CreateTopLevelWindow("DM2StatsWin")
  ui.win:SetClampedToScreen(true)
  ui.win:SetDimensions(w, h)
  ui.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  ui.win:SetHidden(true)
  ui.win:SetDrawLayer(DL_OVERLAY)
  ui.win:SetDrawTier(DT_HIGH)
  ui.win:SetDrawLevel(500000)
  ui.win:SetMovable(true)
  ui.win:SetMouseEnabled(true)

  ui.bg = makeBackdrop(ui.win, "DM2StatsBG")
  ui.bg:SetAnchorFill(ui.win)

  ui.header = makeLabel(ui.win, "DM2StatsHeader", 26, 1,1,1,1)
  ui.header:SetFont(font(26, 67))
  ui.header:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, 14)
  ui.header:SetText(self.displayName)

  ui.closeBtn = WM:CreateControl("DM2StatsCloseBtn", ui.win, CT_LABEL)
  ui.closeBtn:SetFont(font(18, 67))
  ui.closeBtn:SetColor(0.6, 0.6, 0.6, 1)
  ui.closeBtn:SetAnchor(TOPRIGHT, ui.win, TOPRIGHT, -10, 8)
  ui.closeBtn:SetDimensions(28, 24)
  ui.closeBtn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  ui.closeBtn:SetText("X")
  ui.closeBtn:SetMouseEnabled(true)
  ui.closeBtn:SetHandler("OnMouseUp", function() R:Hide() end)
  ui.closeBtn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 0.35, 0.35, 1) end)
  ui.closeBtn:SetHandler("OnMouseExit",  function(self) self:SetColor(0.6, 0.6, 0.6, 1) end)

  ui.countdown = makeLabel(ui.win, "DM2StatsCountdown", 16, 0.92,0.92,0.92,1)
  ui.countdown:SetFont(font(16, 67))
  ui.countdown:SetAnchor(TOPRIGHT, ui.win, TOPRIGHT, -40, 28)
  ui.countdown:SetDimensions(260, 22)
  ui.countdown:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.countdown:SetHidden(true)

  ui.sub = makeLabel(ui.win, "DM2StatsSub", 16, 0.85,0.85,0.85,1)
  ui.sub:SetAnchor(TOPLEFT, ui.header, BOTTOMLEFT, 0, 4)
  ui.sub:SetWidth(w-320)
  ui.sub:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  ui.sub:SetMaxLineCount(5)

  ui.modeNotice = makeLabel(ui.win, "DM2StatsModeNotice", 16, 1.0, 0.92, 0.45, 1)
  ui.modeNotice:SetFont(font(16, 67))
  ui.modeNotice:SetAnchor(TOPLEFT, ui.sub, BOTTOMLEFT, 0, 8)
  ui.modeNotice:SetDimensions(w-36, 24)
  ui.modeNotice:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  ui.modeNotice:SetMaxLineCount(1)
  ui.modeNotice:SetHidden(true)

  ui.pageTitle = makeSectionTitle(ui.win, "DM2StatsPageTitle", 17)
  ui.pageTitle:SetAnchor(TOPLEFT, ui.modeNotice, BOTTOMLEFT, 0, 4)
  ui.pageTitle:SetDimensions(w-220, 20)
  ui.pageTitle:SetText("Page 1/8  •  Summary")
  ui.pageTitle:SetColor(0.70, 0.95, 1.00, 1)

  ui.pageIndicator = makeLabel(ui.win, "DM2StatsPageIndicator", 18, 0.92, 0.92, 0.92, 1)
  ui.pageIndicator:SetFont(font(18, 67))
  ui.pageIndicator:SetAnchor(TOPRIGHT, ui.win, TOPRIGHT, -18, 122)
  ui.pageIndicator:SetDimensions(160, 20)
  ui.pageIndicator:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  ui.pageIndicator:SetText("● ○ ○ ○ ○ ○ ○ ○")

  local topY = 186
  local fullW = w - 36

  -- Layout flow constants
  local sectionGapY = 6
  local summaryPanelH = 160
  local midPanelH = 148
  local setPanelH = 122
  local summarySkillsPanelH = 200

  local summaryPanel = createPanel(ui.win, "DM2StatsSummaryPanel")
  summaryPanel:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, topY)
  summaryPanel:SetDimensions(fullW, summaryPanelH)
  ui.summaryPanel = summaryPanel

  -- v3.2.2: "Parse Snapshot" title removed to save vertical space
  local kpiWrap = WM:CreateControl("DM2StatsKPIWrap", summaryPanel, CT_CONTROL)
  kpiWrap:SetAnchor(TOPLEFT, summaryPanel, TOPLEFT, 10, 6)
  kpiWrap:SetDimensions(fullW-20, 124)

  local kpiGapX, kpiGapY, kpiCols = 10, 6, 5
  local kpiW = math.floor((fullW-20-(kpiGapX*(kpiCols-1))) / kpiCols)
  local kpiH = 44
  local kpiKeys = {
    { key="avg", label="Fight Avg DPS" },
    { key="peak", label="Peak 2s DPS" },
    { key="total", label="Fight Total" },
    { key="dur", label="Fight Duration" },
    { key="crit", label="Crit Rate" },
    { key="maxhit", label="Max Hit" },
    { key="split", label="Direct vs DoT" },
    { key="events", label="Damage Events" },
    { key="epm", label="Dmg Events / Min" },
    { key="weave", label="Weave Success" },
    { key="avglag", label="Avg LA Gap" },
    { key="setpct", label="Set Proc Share" },
    { key="heal", label="Total Healing" },
    { key="hps", label="Effective HPS" },
    { key="overheal", label="Overheal %" },
  }
  for i,k in ipairs(kpiKeys) do
    local c = createKpiBlock(kpiWrap, "DM2StatsKPI_"..k.key)
    local col = ((i-1) % kpiCols)
    local row = math.floor((i-1)/kpiCols)
    c:SetDimensions(kpiW, kpiH)
    c:SetAnchor(TOPLEFT, kpiWrap, TOPLEFT, col*(kpiW+kpiGapX), row*(kpiH+kpiGapY))
    c.value:SetFont(font(20, 67))
    c.value:SetAnchor(TOPLEFT, c, TOPLEFT, 10, 2)
    c.label:SetFont(font(13, 57))
    c.label:SetAnchor(TOPLEFT, c.value, BOTTOMLEFT, 0, -1)
    c.label:SetText(k.label)
    ui.kpi[k.key] = c
  end

  local midY = topY + summaryPanelH + sectionGapY
  local midGap = 12
  local leftW = 350
  local rightW = fullW - leftW - midGap

  local rotPanel = createPanel(ui.win, "DM2StatsRotationPanel")
  rotPanel:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, midY)
  rotPanel:SetDimensions(leftW, midPanelH)
  ui.rotPanel = rotPanel

  local rotTitle = makeSectionTitle(rotPanel, "DM2StatsRotationTitle", 18)
  rotTitle:SetAnchor(TOPLEFT, rotPanel, TOPLEFT, 10, 6)
  rotTitle:SetText("Rotation Health")
  rotTitle:SetDimensions(220, 20)
  rotTitle:SetColor(0.58, 0.86, 1.00, 1)

  local rotHelp = makeLabel(rotPanel, "DM2StatsRotationHelp", 13, 0.78,0.78,0.78,1)
  rotHelp:SetAnchor(TOPLEFT, rotTitle, BOTTOMLEFT, 0, 1)
  rotHelp:SetDimensions(leftW-20, 16)
  rotHelp:SetText("Light attack timing, misses, and rhythm health")
  ui.weaveHelp = rotHelp

  ui.rotLines = {}
  local lineW = math.floor((leftW - 26) / 2)
  for i=1,4 do
    local l1 = makeLabel(rotPanel, "DM2StatsRotL"..i, 15, 1,1,1,1)
    l1:SetAnchor(TOPLEFT, rotPanel, TOPLEFT, 10, 40 + ((i-1) * 25))
    l1:SetDimensions(lineW, 20)
    local l2 = makeLabel(rotPanel, "DM2StatsRotR"..i, 15, 1,1,1,1)
    l2:SetAnchor(TOPLEFT, rotPanel, TOPLEFT, 14 + lineW, 40 + ((i-1) * 25))
    l2:SetDimensions(lineW, 20)
    ui.rotLines[i] = { l1, l2 }
  end

  local burstPanel = createPanel(ui.win, "DM2StatsBurstPanel")
  burstPanel:SetAnchor(TOPLEFT, rotPanel, TOPRIGHT, midGap, 0)
  burstPanel:SetDimensions(rightW, midPanelH)
  ui.burstPanel = burstPanel

  -- v3.2.2: "Burst / Drop Windows" title removed — column headers are sufficient
  local halfGap = 14
  local halfW = math.floor((rightW - 20 - halfGap) / 2)
  local function makeBucketCols(totalW)
    local c1, c2, c3 = 84, 106, 84
    local c4 = math.max(178, totalW - (c1 + c2 + c3))
    return {
      { title="Bucket", w=c1, align=TEXT_ALIGN_LEFT },
      { title="Window", w=c2, align=TEXT_ALIGN_LEFT },
      { title="DPS", w=c3, align=TEXT_ALIGN_RIGHT },
      { title="Top Skill", w=c4, align=TEXT_ALIGN_LEFT },
    }
  end
  -- v3.2.2: Sub-titles removed — column headers ("Bucket","Window","DPS","Top Skill") are sufficient
  ui.spikesList = createList(burstPanel, "DM2StatsPeaks", makeBucketCols(halfW), 3)
  ui.spikesList:SetAnchor(TOPLEFT, burstPanel, TOPLEFT, 10, 6)
  ui.dipsList = createList(burstPanel, "DM2StatsDips", makeBucketCols(halfW), 3)
  ui.dipsList:SetAnchor(TOPLEFT, burstPanel, TOPLEFT, 10 + halfW + halfGap, 6)

  -- DPS Sparkline (v3.2.0): bar chart of 2s bucket DPS over fight duration
  local sparklineH = 60
  local sparklineY = midY + midPanelH + sectionGapY
  local sparklinePanel = createPanel(ui.win, "DM2StatsSparklinePanel")
  sparklinePanel:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, sparklineY)
  sparklinePanel:SetDimensions(fullW, sparklineH)
  ui.sparklinePanel = sparklinePanel
  local sparklineTitle = makeSectionTitle(sparklinePanel, "DM2StatsSparklineTitle", 14)
  sparklineTitle:SetAnchor(TOPLEFT, sparklinePanel, TOPLEFT, 10, 4)
  sparklineTitle:SetDimensions(200, 16)
  sparklineTitle:SetText("DPS Over Time")
  sparklineTitle:SetColor(0.72, 0.95, 1.00, 1)
  local SPARKLINE_MAX_BARS = 40
  local sparkBarH = sparklineH - 24  -- room for title
  ui.sparklineBars = {}
  for i = 1, SPARKLINE_MAX_BARS do
    local bar = WM:CreateControl(string.format("DM2StatsSparkBar%d", i), sparklinePanel, CT_BACKDROP)
    bar:SetCenterColor(0.3, 0.7, 1.0, 0.9)
    bar:SetEdgeColor(0, 0, 0, 0)
    bar:SetHidden(true)
    ui.sparklineBars[i] = bar
  end

  local setY = sparklineY + sparklineH + sectionGapY
  local setPanel = createPanel(ui.win, "DM2StatsSetPanel")
  setPanel:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, setY)
  setPanel:SetDimensions(fullW, setPanelH)
  ui.setPanel = setPanel
  local setsTitle = makeSectionTitle(setPanel, "DM2StatsSetsTitle", 18)
  setsTitle:SetAnchor(TOPLEFT, setPanel, TOPLEFT, 10, 6)
  setsTitle:SetText("Set Contribution")
  setsTitle:SetDimensions(240, 20)
  setsTitle:SetColor(1.00, 0.90, 0.50, 1)
  local colsSets = {
    { title="Set Proc", w=390, align=TEXT_ALIGN_LEFT },
    { title="Amount", w=145, align=TEXT_ALIGN_RIGHT },
    { title="Share", w=96, align=TEXT_ALIGN_RIGHT, shareBar=true },
    { title="Crit%", w=82, align=TEXT_ALIGN_RIGHT },
    { title="Type", w=88, align=TEXT_ALIGN_RIGHT },
    { title="DPS", w=112, align=TEXT_ALIGN_RIGHT },
  }
  ui.setsList = createList(setPanel, "DM2StatsSetProcs", colsSets, 3)
  ui.setsList:SetAnchor(TOPLEFT, setsTitle, BOTTOMLEFT, 0, 3)

  local summarySkillsY = setY + setPanelH + sectionGapY
  local summarySkillsPanel = createPanel(ui.win, "DM2StatsSummarySkillsPanel")
  summarySkillsPanel:SetAnchor(TOPLEFT, ui.win, TOPLEFT, 18, summarySkillsY)
  summarySkillsPanel:SetDimensions(fullW, summarySkillsPanelH)
  ui.summarySkillsPanel = summarySkillsPanel
  local summarySkillsTitle = makeSectionTitle(summarySkillsPanel, "DM2StatsSummarySkillsTitle", 18)
  summarySkillsTitle:SetAnchor(TOPLEFT, summarySkillsPanel, TOPLEFT, 10, 6)
  summarySkillsTitle:SetText("Top Damage Skills")
  summarySkillsTitle:SetDimensions(260, 20)
  summarySkillsTitle:SetColor(0.86, 0.94, 1.00, 1)
  ui.summarySkillsLegend = makeBarChipLegend(summarySkillsPanel, "DM2StatsSummarySkillsLegend", fullW - 20)
  ui.summarySkillsLegend:SetAnchor(TOPLEFT, summarySkillsTitle, BOTTOMLEFT, 0, 2)
  local colsSummarySkills = {
    { title="", w=34, kind="icon" },
    { title="", w=10, kind="bar" },
    { title="Skill", w=386, align=TEXT_ALIGN_LEFT },
    { title="DPS", w=130, align=TEXT_ALIGN_RIGHT },
    { title="Share", w=110, align=TEXT_ALIGN_RIGHT, shareBar=true },
    { title="Crit%", w=100, align=TEXT_ALIGN_RIGHT },
    { title="Max Hit", w=130, align=TEXT_ALIGN_RIGHT },
  }
  ui.summarySkillsList = createList(summarySkillsPanel, "DM2StatsSummarySkills", colsSummarySkills, 4, { rowH = 30 })
  ui.summarySkillsList:SetAnchor(TOPLEFT, ui.summarySkillsLegend, BOTTOMLEFT, 0, 3)

  local scrollWrap = WM:CreateControl("DM2StatsScrollWrap", ui.win, CT_CONTROL)
  ui.scrollWrap = scrollWrap
  scrollWrap:SetAnchor(TOPLEFT, summarySkillsPanel, BOTTOMLEFT, 0, 10)
  scrollWrap:SetAnchor(BOTTOMRIGHT, ui.win, BOTTOMRIGHT, -18, -SCROLL_BOTTOM_INSET)
  local scroll = CreateControlFromVirtual("DM2StatsScroll", scrollWrap, "ZO_ScrollContainer")
  scroll:SetAnchorFill(scrollWrap)
  local scrollChild = scroll:GetNamedChild("ScrollChild")
  local contentCtrl = WM:CreateControl("DM2StatsContent", scrollChild, CT_CONTROL)
  contentCtrl:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, 0)
  contentCtrl:SetAnchor(TOPRIGHT, scrollChild, TOPRIGHT, 0, 0)
  ui._scroll = scroll
  ui._scrollChild = scrollChild
  ui._content = contentCtrl
  local scrollBar = scroll:GetNamedChild("ScrollBar")
  if scrollBar then scrollBar:SetHidden(false) end
  local cW = w - 64

  local skillsPanel = createPanel(contentCtrl, "DM2StatsSkillsPanel")
  skillsPanel:SetAnchor(TOPLEFT, contentCtrl, TOPLEFT, 0, 0)
  skillsPanel:SetDimensions(cW, 0)
  ui.skillsPanel = skillsPanel
  local skillsTitle = makeSectionTitle(skillsPanel, "DM2StatsSkillsTitle", 18)
  skillsTitle:SetAnchor(TOPLEFT, skillsPanel, TOPLEFT, 10, 6)
  skillsTitle:SetDimensions(cW-20, 24)
  skillsTitle:SetText("Skill Breakdown")
  skillsTitle:SetColor(0.90, 0.96, 1.00, 1)
  ui.skillsLegend = makeBarChipLegend(skillsPanel, "DM2StatsSkillsLegend", cW - 20)
  ui.skillsLegend:SetAnchor(TOPLEFT, skillsTitle, BOTTOMLEFT, 0, 2)
  local colsSkills = {
    { title="", w=34, kind="icon" },
    { title="", w=10, kind="bar" },
    { title="Name", w=200, align=TEXT_ALIGN_LEFT },
    { title="Amount", w=108, align=TEXT_ALIGN_RIGHT },
    { title="Events", w=74, align=TEXT_ALIGN_RIGHT },
    { title="Avg Hit", w=88, align=TEXT_ALIGN_RIGHT },
    { title="Contrib %", w=96, align=TEXT_ALIGN_RIGHT, shareBar=true },
    { title="Crit%", w=70, align=TEXT_ALIGN_RIGHT },
    { title="AOE", w=52, align=TEXT_ALIGN_CENTER },
    { title="Source", w=78, align=TEXT_ALIGN_LEFT },
    { title="Type", w=64, align=TEXT_ALIGN_RIGHT },
    { title="DPS", w=82, align=TEXT_ALIGN_RIGHT },
  }
  ui.skillsList = createList(skillsPanel, "DM2StatsSkills", colsSkills, 21, { rowH = 30 })
  ui.skillsList:SetAnchor(TOPLEFT, ui.skillsLegend, BOTTOMLEFT, 0, 3)


  local rotationDiagPanel = createPanel(contentCtrl, "DM2StatsRotationDiagPanel")
  rotationDiagPanel:SetAnchor(TOPLEFT, skillsPanel, BOTTOMLEFT, 0, 12)
  rotationDiagPanel:SetDimensions(cW, 0)
  ui.rotationDiagPanel = rotationDiagPanel
  local rotationDiagTitle = makeSectionTitle(rotationDiagPanel, "DM2StatsRotationDiagTitle", 18)
  rotationDiagTitle:SetAnchor(TOPLEFT, rotationDiagPanel, TOPLEFT, 10, 6)
  rotationDiagTitle:SetDimensions(cW-20, 24)
  rotationDiagTitle:SetText("Rotation Diagnostics")
  rotationDiagTitle:SetColor(0.88, 0.94, 1.00, 1)

  -- v3.2.2: Condensed summary — single row of 3 stats
  local sumY = 38
  ui.rotationDiagSummary = {}
  for i=1,3 do
    local lbl = makeLabel(rotationDiagPanel, "DM2StatsRotationDiagSummary"..i, 16, 1,1,1,1)
    lbl:SetAnchor(TOPLEFT, rotationDiagPanel, TOPLEFT, 12 + ((i-1) * math.floor((cW-30)/3)), sumY)
    lbl:SetDimensions(math.floor((cW-40)/3), 20)
    ui.rotationDiagSummary[i] = lbl
  end

  local legendY = sumY + 26
  ui.rotationDiagLegend = makeLabel(rotationDiagPanel, "DM2StatsRotationDiagLegend", 14, 0.7, 0.7, 0.7, 1)
  ui.rotationDiagLegend:SetAnchor(TOPLEFT, rotationDiagPanel, TOPLEFT, 12, legendY)
  ui.rotationDiagLegend:SetDimensions(cW-24, 18)
  ui.rotationDiagLegend:SetText(SYM_OK .. " Good   " .. SYM_LATE .. " Late   " .. SYM_MISS .. " Miss   " .. SYM_FAST .. " Fast   " .. SYM_EXTRA .. " Extra   " .. SYM_CHANNEL .. " Channel   " .. barChipLegendText())

  local hintY = legendY + 20
  ui.rotationDiagHint = makeLabel(rotationDiagPanel, "DM2StatsRotationDiagHint", 15, 0.65, 0.90, 1.0, 1)
  ui.rotationDiagHint:SetAnchor(TOPLEFT, rotationDiagPanel, TOPLEFT, 12, hintY)
  ui.rotationDiagHint:SetDimensions(cW-24, 36)
  ui.rotationDiagHint:SetWrapMode(TEXT_WRAP_MODE_WORD)
  ui.rotationDiagHint:SetMaxLineCount(2)
  ui.rotationDiagHint:SetVerticalAlignment(TEXT_ALIGN_TOP)
  ui.rotationDiagHint:SetText("")

  -- Pulse strip directly after hint (tables moved to Weave Analysis page)
  local pulseStripY = hintY + 40
  local pulseContainer = WM:CreateControl("DM2StatsPulseStrip", rotationDiagPanel, CT_CONTROL)
  pulseContainer:SetAnchor(TOPLEFT, rotationDiagPanel, TOPLEFT, 12, pulseStripY)
  pulseContainer:SetDimensions(cW-24, 18)
  ui.pulseStrip = {}
  ui.pulseContainer = pulseContainer
  local PULSE_BLOCK_W = 10
  local PULSE_BLOCK_H = 16
  local PULSE_MAX_BLOCKS = 80
  for i = 1, PULSE_MAX_BLOCKS do
    local block = WM:CreateControl(string.format("DM2StatsPulseBlock%d", i), pulseContainer, CT_BACKDROP)
    block:SetDimensions(PULSE_BLOCK_W, PULSE_BLOCK_H)
    block:SetAnchor(TOPLEFT, pulseContainer, TOPLEFT, (i-1) * (PULSE_BLOCK_W + 1), 0)
    block:SetCenterColor(1, 1, 1, 1)
    block:SetEdgeColor(0, 0, 0, 0)
    block:SetHidden(true)
    ui.pulseStrip[i] = block
  end

  local rotationTimelineTitle = makeSectionTitle(rotationDiagPanel, "DM2StatsRotationTimelineTitle", 16)
  rotationTimelineTitle:SetAnchor(TOPLEFT, rotationDiagPanel, TOPLEFT, 12, pulseStripY + 22)
  rotationTimelineTitle:SetDimensions(cW-24, 20)
  rotationTimelineTitle:SetText("Timeline")
  rotationTimelineTitle:SetColor(1.00, 0.90, 0.58, 1)

  -- v3.2.0: Multi-label timeline (16 labels) — each line gets its own fresh markup
  -- to avoid ESO's per-string color markup limit that caused colors to grey out midway.
  local TIMELINE_LINE_COUNT = 16
  local TIMELINE_LINE_H = 22
  ui.rotationDiagTimelineLines = {}
  for i = 1, TIMELINE_LINE_COUNT do
    local lbl = makeLabel(rotationDiagPanel,
      string.format("DM2StatsRotationDiagTL%d", i), 16, 1, 1, 1, 1)
    lbl:SetAnchor(TOPLEFT, rotationTimelineTitle, BOTTOMLEFT, 0, 6 + (i-1) * TIMELINE_LINE_H)
    lbl:SetDimensions(cW-24, TIMELINE_LINE_H)
    lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    lbl:SetMaxLineCount(1)
    lbl:SetVerticalAlignment(TEXT_ALIGN_TOP)
    lbl:SetHidden(true)
    ui.rotationDiagTimelineLines[i] = lbl
  end

  local gearPanel = createPanel(contentCtrl, "DM2StatsGearPanel")
  gearPanel:SetAnchor(TOPLEFT, rotationDiagPanel, BOTTOMLEFT, 0, 12)
  gearPanel:SetDimensions(cW, 0)
  ui.gearPanel = gearPanel
  local gearTitle = makeSectionTitle(gearPanel, "DM2StatsGearTitle", 18)
  gearTitle:SetAnchor(TOPLEFT, gearPanel, TOPLEFT, 10, 6)
  gearTitle:SetDimensions(cW-20, 24)
  gearTitle:SetText("Gear Summary")
  gearTitle:SetColor(0.86, 0.96, 0.90, 1)
  local colsGear = {
    { title="Slot", w=90, align=TEXT_ALIGN_LEFT },
    { title="Equipped", w=240, align=TEXT_ALIGN_LEFT },
    { title="Trait", w=400, align=TEXT_ALIGN_LEFT },
    { title="Enchantment", w=570, align=TEXT_ALIGN_LEFT },
  }
  ui.gearList = createList(gearPanel, "DM2StatsGear", colsGear, 18)
  ui.gearList:SetAnchor(TOPLEFT, gearTitle, BOTTOMLEFT, 0, 3)

  local setDetailPanel = createPanel(contentCtrl, "DM2StatsSetDetailPanel")
  setDetailPanel:SetAnchor(TOPLEFT, gearPanel, BOTTOMLEFT, 0, 12)
  setDetailPanel:SetDimensions(cW, 0)
  ui.setDetailPanel = setDetailPanel
  local setDetailTitle = makeSectionTitle(setDetailPanel, "DM2StatsSetDetailTitle", 18)
  setDetailTitle:SetAnchor(TOPLEFT, setDetailPanel, TOPLEFT, 10, 6)
  setDetailTitle:SetDimensions(cW-20, 24)
  setDetailTitle:SetText("Proc Analysis")
  setDetailTitle:SetColor(1.00, 0.92, 0.62, 1)
  local colsSetDetail = {
    { title="Set Proc", w=360, align=TEXT_ALIGN_LEFT },
    { title="Amount", w=145, align=TEXT_ALIGN_RIGHT },
    { title="Share", w=96, align=TEXT_ALIGN_RIGHT, shareBar=true },
    { title="Hits", w=80, align=TEXT_ALIGN_RIGHT },
    { title="Crit%", w=82, align=TEXT_ALIGN_RIGHT },
    { title="Type", w=88, align=TEXT_ALIGN_RIGHT },
    { title="DPS", w=112, align=TEXT_ALIGN_RIGHT },
  }
  ui.setDetailList = createList(setDetailPanel, "DM2StatsSetDetail", colsSetDetail, 16)
  ui.setDetailList:SetAnchor(TOPLEFT, setDetailTitle, BOTTOMLEFT, 0, 3)

  local buffsPanel = createPanel(contentCtrl, "DM2StatsBuffsPanel")
  buffsPanel:SetAnchor(TOPLEFT, setDetailPanel, BOTTOMLEFT, 0, 12)
  buffsPanel:SetDimensions(cW, 0)
  ui.buffsPanel = buffsPanel
  local buffsTitle = makeSectionTitle(buffsPanel, "DM2StatsBuffsTitle", 18)
  buffsTitle:SetAnchor(TOPLEFT, buffsPanel, TOPLEFT, 10, 6)
  buffsTitle:SetDimensions(cW-20, 24)
  buffsTitle:SetText("Buffs / Uptime")
  buffsTitle:SetColor(0.92, 0.88, 1.00, 1)
  ui.buffsLegend = makeBarChipLegend(buffsPanel, "DM2StatsBuffsLegend", cW - 20)
  ui.buffsLegend:SetAnchor(TOPLEFT, buffsTitle, BOTTOMLEFT, 0, 2)
  local colsBuffs = {
    { title="", w=34, kind="icon" },
    { title="", w=10, kind="bar" },
    { title="Buff", w=256, align=TEXT_ALIGN_LEFT },
    { title="Source", w=110, align=TEXT_ALIGN_LEFT },
    { title="Uptime", w=100, align=TEXT_ALIGN_RIGHT },
    { title="Active", w=120, align=TEXT_ALIGN_RIGHT },
    { title="Applies", w=90, align=TEXT_ALIGN_RIGHT },
    { title="Type", w=120, align=TEXT_ALIGN_LEFT },
  }
  ui.buffsList = createList(buffsPanel, "DM2StatsBuffs", colsBuffs, 18, { rowH = 30 })
  ui.buffsList:SetAnchor(TOPLEFT, ui.buffsLegend, BOTTOMLEFT, 0, 3)

  -- v3.2.7: History page — compact fight list (left) + comparison table (right)
  local historyPanel = createPanel(contentCtrl, "DM2StatsHistoryPanel")
  historyPanel:SetAnchor(TOPLEFT, buffsPanel, BOTTOMLEFT, 0, 12)
  historyPanel:SetDimensions(cW, 0)
  ui.historyPanel = historyPanel

  local historyTitle = makeSectionTitle(historyPanel, "DM2StatsHistoryTitle", 18)
  historyTitle:SetAnchor(TOPLEFT, historyPanel, TOPLEFT, 10, 6 + HISTORY_CONTENT_PAD_Y)
  historyTitle:SetDimensions(cW-20, 24)
  historyTitle:SetText("Fight History & Comparison")
  historyTitle:SetColor(0.82, 0.94, 0.74, 1)

  ui.historyNote = makeLabel(historyPanel, "DM2StatsHistoryNote", 13, 0.6, 0.75, 0.6, 1)
  ui.historyNote:SetAnchor(TOPLEFT, historyTitle, BOTTOMLEFT, 0, 2)
  ui.historyNote:SetDimensions(cW-20, 18)
  ui.historyNote:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  ui.historyNote:SetMaxLineCount(1)
  ui.historyNote:SetText("L2/R2: change fight (list recenters, trends highlight). Right: last 4 dummy parses. Bottom: trends newest→oldest (left→right).")

  -- Left: compact fight list (* = dummy parse)
  local histListW = math.floor(cW * 0.30)
  local histNumW = 40
  local histTargetW = math.floor(histListW * 0.50)
  local histDpsW = math.floor(histListW * 0.24)
  local histWhenW = histListW - histNumW - histTargetW - histDpsW
  local colsHistory = {
    { title="#", w=histNumW, align=TEXT_ALIGN_LEFT, padL=2, padR=4 },
    { title="Target", w=histTargetW, align=TEXT_ALIGN_LEFT },
    { title="DPS", w=histDpsW, align=TEXT_ALIGN_RIGHT },
    { title="When", w=histWhenW, align=TEXT_ALIGN_LEFT },
  }
  ui.historyList = createList(historyPanel, "DM2StatsHistory", colsHistory, HISTORY_LIST_MAX_ROWS)
  ui.historyList:SetAnchor(TOPLEFT, ui.historyNote, BOTTOMLEFT, 0, 6)

  -- Right: comparison table (up to 4 dummy parses, newest → oldest left to right)
  local compX = ui.historyList:GetWidth() + 12
  local compW = cW - compX - 6
  local metricW = 100
  local compColW = math.floor((compW - metricW) / 4)
  ui.comparisonNote = makeLabel(historyPanel, "DM2StatsCompNote", 14, 0.7, 0.95, 1.0, 1)
  ui.comparisonNote:SetAnchor(TOPLEFT, ui.historyNote, BOTTOMLEFT, compX, 6)
  ui.comparisonNote:SetDimensions(compW, 18)
  ui.comparisonNote:SetFont(font(14, 67))
  ui.comparisonNote:SetText("Dummy Parse Comparison (newest → oldest)")

  -- Fight context headers above each parse column
  ui.comparisonFightHeaders = {}
  local compFightHdrAnchor = WM:CreateControl("DM2StatsCompFightHdrAnchor", historyPanel, CT_CONTROL)
  compFightHdrAnchor:SetAnchor(TOPLEFT, ui.comparisonNote, BOTTOMLEFT, metricW, 4)
  compFightHdrAnchor:SetDimensions(1, COMP_FIGHT_HEADER_H)
  for i = 1, 4 do
    local hdr = makeLabel(historyPanel, "DM2StatsCompFightHdr_" .. i, 12, 0.82, 0.96, 0.78, 1)
    hdr:SetAnchor(TOPLEFT, compFightHdrAnchor, TOPLEFT, (i - 1) * compColW + 2, 0)
    hdr:SetDimensions(compColW - 4, COMP_FIGHT_HEADER_H)
    hdr:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hdr:SetVerticalAlignment(TEXT_ALIGN_TOP)
    hdr:SetWrapMode(TEXT_WRAP_MODE_WORD)
    hdr:SetMaxLineCount(3)
    ui.comparisonFightHeaders[i] = hdr
  end

  -- Per-parse DPS mini sparklines (2s buckets)
  ui.comparisonSparklines = {}
  local compSparkAnchor = WM:CreateControl("DM2StatsCompSparkAnchor", historyPanel, CT_CONTROL)
  compSparkAnchor:SetAnchor(TOPLEFT, compFightHdrAnchor, BOTTOMLEFT, 0, 2)
  compSparkAnchor:SetDimensions(1, COMP_SPARKLINE_H)
  for i = 1, 4 do
    local sparkW = compColW - 4
    local baseline = WM:CreateControl("DM2StatsCompSparkBase_" .. i, historyPanel, CT_BACKDROP)
    baseline:SetAnchor(BOTTOMLEFT, compSparkAnchor, TOPLEFT, (i - 1) * compColW + 2, COMP_SPARKLINE_H - 2)
    baseline:SetDimensions(sparkW, 1)
    baseline:SetCenterColor(0.45, 0.65, 0.85, 0.45)
    baseline:SetEdgeColor(0, 0, 0, 0)
    local bars = {}
    for b = 1, COMP_SPARKLINE_BARS do
      local bar = WM:CreateControl(string.format("DM2StatsCompSpark_%d_%d", i, b), historyPanel, CT_BACKDROP)
      bar:SetEdgeColor(0, 0, 0, 0)
      bar:SetHidden(true)
      bars[b] = bar
    end
    ui.comparisonSparklines[i] = { bars = bars, baseline = baseline, colW = compColW, sparkW = sparkW, anchor = compSparkAnchor, colIndex = i }
  end

  -- Metric label column + 4 value columns
  local colsComp = {
    { title="Metric", w=metricW, align=TEXT_ALIGN_LEFT },
    { title="#1", w=compColW, align=TEXT_ALIGN_RIGHT },
    { title="#2", w=compColW, align=TEXT_ALIGN_RIGHT },
    { title="#3", w=compColW, align=TEXT_ALIGN_RIGHT },
    { title="#4", w=compColW, align=TEXT_ALIGN_RIGHT },
  }
  ui.comparisonList = createList(historyPanel, "DM2StatsComparison", colsComp, HISTORY_COMP_MAX_ROWS, { rowH = 24 })
  ui.comparisonList:SetAnchor(TOPLEFT, compSparkAnchor, BOTTOMLEFT, 0, HISTORY_COMP_LIST_GAP)
  ui.comparisonList.body:SetAnchor(TOPLEFT, ui.comparisonList.header, BOTTOMLEFT, 0, 2)

  ui.comparisonHeaders = {}
  for i = 1, 4 do
    ui.comparisonHeaders[i] = ui.comparisonList.header.cols[i + 1]
  end

  -- Dummy parse trends: pinned to bottom of scroll viewport (console cannot scroll)
  local trendPanel = createPanel(scrollWrap, "DM2StatsTrendPanel")
  trendPanel:SetAnchor(BOTTOMLEFT, scrollWrap, BOTTOMLEFT, 0, 0)
  trendPanel:SetAnchor(BOTTOMRIGHT, scrollWrap, BOTTOMRIGHT, 0, 0)
  trendPanel:SetDimensions(cW, trendPanelHeight())
  trendPanel:SetHidden(true)
  ui.trendPanel = trendPanel

  local trendTitle = makeSectionTitle(trendPanel, "DM2StatsTrendTitle", 16)
  trendTitle:SetAnchor(TOPLEFT, trendPanel, TOPLEFT, 10, 6)
  trendTitle:SetDimensions(cW - 20, 18)
  trendTitle:SetText("Dummy Parse Trends")
  trendTitle:SetColor(0.72, 0.95, 1.00, 1)

  local trendHelp = makeLabel(trendPanel, "DM2StatsTrendHelp", 12, 0.6, 0.75, 0.6, 1)
  trendHelp:SetAnchor(TOPLEFT, trendTitle, BOTTOMLEFT, 0, 2)
  trendHelp:SetDimensions(cW - 20, 14)
  trendHelp:SetText("Each column = one dummy parse (newest → oldest, left → right). Cyan column = fight you are viewing.")

  local trendMetricW = 72
  local trendColW = math.max(44, math.floor((cW - 20 - trendMetricW - 8) / TREND_MAX_COLS))
  local trendHdrAnchor = WM:CreateControl("DM2StatsTrendHdrAnchor", trendPanel, CT_CONTROL)
  trendHdrAnchor:SetAnchor(TOPLEFT, trendHelp, BOTTOMLEFT, trendMetricW + 8, 6)
  trendHdrAnchor:SetDimensions(1, TREND_FIGHT_HEADER_H)

  ui.trendFightHeaders = {}
  for i = 1, TREND_MAX_COLS do
    local hdr = makeLabel(trendPanel, "DM2StatsTrendFightHdr_" .. i, 11, 0.82, 0.96, 0.78, 1)
    hdr:SetAnchor(TOPLEFT, trendHdrAnchor, TOPLEFT, (i - 1) * trendColW + 1, 0)
    hdr:SetDimensions(trendColW - 2, TREND_FIGHT_HEADER_H)
    hdr:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hdr:SetVerticalAlignment(TEXT_ALIGN_TOP)
    hdr:SetWrapMode(TEXT_WRAP_MODE_WORD)
    hdr:SetMaxLineCount(2)
    ui.trendFightHeaders[i] = hdr
  end

  ui.trendMetricRows = {}
  local trendGridAnchor = WM:CreateControl("DM2StatsTrendGridAnchor", trendPanel, CT_CONTROL)
  trendGridAnchor:SetAnchor(TOPLEFT, trendHdrAnchor, BOTTOMLEFT, -(trendMetricW + 8), 4)
  trendGridAnchor:SetDimensions(cW - 20, 1)

  local trendMetrics = {
    { key = "dps", label = "Avg DPS" },
    { key = "crit", label = "Crit %" },
    { key = "weave", label = "Weave %" },
  }
  for mi, m in ipairs(trendMetrics) do
    local rowAnchor = WM:CreateControl("DM2StatsTrendRow_" .. m.key, trendPanel, CT_CONTROL)
    rowAnchor:SetAnchor(TOPLEFT, trendGridAnchor, BOTTOMLEFT, 0, (mi - 1) * (TREND_ROW_H + 4))
    rowAnchor:SetDimensions(cW - 20, TREND_ROW_H)

    local rowLabel = makeLabel(trendPanel, "DM2StatsTrendLbl_" .. m.key, 12, 0.85, 0.85, 0.85, 1)
    rowLabel:SetAnchor(LEFT, rowAnchor, LEFT, 0, 0)
    rowLabel:SetDimensions(trendMetricW, TREND_ROW_H)
    rowLabel:SetText(m.label)

    local cells = {}
    for i = 1, TREND_MAX_COLS do
      local cellX = trendMetricW + 8 + (i - 1) * trendColW
      local baseline = WM:CreateControl(string.format("DM2StatsTrendCellBase_%s_%d", m.key, i), trendPanel, CT_BACKDROP)
      baseline:SetAnchor(TOPLEFT, rowAnchor, TOPLEFT, cellX, TREND_ROW_H - 16)
      baseline:SetDimensions(trendColW - 4, 1)
      baseline:SetCenterColor(0.45, 0.65, 0.85, 0.35)
      baseline:SetEdgeColor(0, 0, 0, 0)
      local bar = WM:CreateControl(string.format("DM2StatsTrendCellBar_%s_%d", m.key, i), trendPanel, CT_BACKDROP)
      bar:SetEdgeColor(0, 0, 0, 0)
      bar:SetHidden(true)
      local val = makeLabel(trendPanel, string.format("DM2StatsTrendCellVal_%s_%d", m.key, i), 10, 0.92, 0.96, 1.0, 1)
      val:SetAnchor(TOPLEFT, rowAnchor, TOPLEFT, cellX, TREND_ROW_H - 13)
      val:SetDimensions(trendColW - 4, 12)
      val:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
      val:SetMaxLineCount(1)
      cells[i] = { bar = bar, value = val, baseline = baseline, colW = trendColW, cellX = cellX }
    end
    ui.trendMetricRows[m.key] = { label = rowLabel, cells = cells, rowAnchor = rowAnchor, trendColW = trendColW, trendMetricW = trendMetricW }
  end

  local snapPanel = createPanel(contentCtrl, "DM2StatsSnapshotPanel")
  snapPanel:SetAnchor(TOPLEFT, historyPanel, BOTTOMLEFT, 0, 12)
  snapPanel:SetDimensions(cW, 0)
  ui.snapshotPanel = snapPanel
  local snapTitle = makeSectionTitle(snapPanel, "DM2StatsSnapshotTitle", 18)
  snapTitle:SetAnchor(TOPLEFT, snapPanel, TOPLEFT, 10, 6)
  snapTitle:SetDimensions(cW-20, 24)
  snapTitle:SetText("Stats Snapshot")
  snapTitle:SetColor(0.88, 0.84, 1.00, 1)
  local colsSnap = {
    { title="Metric", w=280, align=TEXT_ALIGN_LEFT },
    { title="Value", w=420, align=TEXT_ALIGN_LEFT },
  }
  ui.snapshotList = createList(snapPanel, "DM2StatsSnapshot", colsSnap, 6)
  ui.snapshotList:SetAnchor(TOPLEFT, snapTitle, BOTTOMLEFT, 0, 3)

  local debugPanel = createPanel(contentCtrl, "DM2StatsDebugPanel")
  debugPanel:SetAnchor(TOPLEFT, contentCtrl, TOPLEFT, 0, 0)
  debugPanel:SetDimensions(cW, 0)
  ui.debugPanel = debugPanel
  local debugTitle = makeSectionTitle(debugPanel, "DM2StatsDebugTitle", 18)
  debugTitle:SetAnchor(TOPLEFT, debugPanel, TOPLEFT, 10, 6)
  debugTitle:SetDimensions(cW-20, 24)
  debugTitle:SetText("Rotation Capture Debug Log (Input-Based)")
  debugTitle:SetColor(1.00, 0.80, 0.60, 1)
  local colsDebug = {
    { title="Skill", w=300, align=TEXT_ALIGN_LEFT },
    { title="ID", w=90, align=TEXT_ALIGN_RIGHT },
    { title="Presses", w=90, align=TEXT_ALIGN_RIGHT },
    { title="Skipped", w=90, align=TEXT_ALIGN_RIGHT },
    { title="Slot / Bar Info", w=270, align=TEXT_ALIGN_LEFT },
  }
  ui.debugList = createList(debugPanel, "DM2StatsDebug", colsDebug, 24)
  ui.debugList:SetAnchor(TOPLEFT, debugTitle, BOTTOMLEFT, 0, 3)

  -- Weave Analysis page — own full-screen panel (console R1 page flip)
  local weaveDetailPanel = createPanel(ui.win, "DM2StatsWeaveDetailPanel")
  weaveDetailPanel:SetHidden(true)
  ui.weaveDetailPanel = weaveDetailPanel

  local wdTitle = makeSectionTitle(weaveDetailPanel, "DM2StatsWeaveDetailTitle", 18)
  wdTitle:SetAnchor(TOPLEFT, weaveDetailPanel, TOPLEFT, 12, 6)
  wdTitle:SetDimensions(300, 22)
  wdTitle:SetText("Weave Analysis")
  wdTitle:SetColor(0.72, 0.95, 1.00, 1)
  ui.weaveDetailLegend = makeBarChipLegend(weaveDetailPanel, "DM2StatsWeaveDetailLegend", cW - 24)
  ui.weaveDetailLegend:SetAnchor(TOPLEFT, wdTitle, BOTTOMLEFT, 0, 2)

  local wdHalfW = math.floor((cW - 30) / 2)
  local wdListY = 6 + 22 + 2 + BAR_CHIP_LEGEND_H + 4

  local colsPerSkill = {
    { title="", w=30, kind="icon" },
    { title="", w=8, kind="bar" },
    { title="Skill", w=math.floor(wdHalfW * 0.44) - 38, align=TEXT_ALIGN_LEFT },
    { title="Weave%", w=math.floor(wdHalfW * 0.18), align=TEXT_ALIGN_RIGHT },
    { title="Good", w=math.floor(wdHalfW * 0.13), align=TEXT_ALIGN_RIGHT },
    { title="Late", w=math.floor(wdHalfW * 0.13), align=TEXT_ALIGN_RIGHT },
    { title="Miss", w=math.floor(wdHalfW * 0.12), align=TEXT_ALIGN_RIGHT },
  }
  ui.perSkillWeaveList = createList(weaveDetailPanel, "DM2StatsPerSkillWeave", colsPerSkill, 10, { rowH = 30 })
  ui.perSkillWeaveList.header:SetAnchor(TOPLEFT, weaveDetailPanel, TOPLEFT, 12, wdListY)
  ui.perSkillWeaveList.body:SetAnchor(TOPLEFT, ui.perSkillWeaveList.header, BOTTOMLEFT, 0, 2)

  local colsDotUptime = {
    { title="", w=30, kind="icon" },
    { title="", w=8, kind="bar" },
    { title="DOT Skill", w=math.floor(wdHalfW * 0.50) - 38, align=TEXT_ALIGN_LEFT },
    { title="Uptime", w=math.floor(wdHalfW * 0.25), align=TEXT_ALIGN_RIGHT },
    { title="Activity", w=math.floor(wdHalfW * 0.25), align=TEXT_ALIGN_RIGHT },
  }
  ui.dotUptimeList = createList(weaveDetailPanel, "DM2StatsDotUptime", colsDotUptime, 10, { rowH = 30 })
  ui.dotUptimeList.header:SetAnchor(TOPLEFT, weaveDetailPanel, TOPLEFT, 12 + wdHalfW + 6, wdListY)
  ui.dotUptimeList.body:SetAnchor(TOPLEFT, ui.dotUptimeList.header, BOTTOMLEFT, 0, 2)

  ui.footer = WM:CreateControl("DM2StatsFooter", ui.win, CT_CONTROL)
  ui.footer:SetAnchor(BOTTOMLEFT, ui.win, BOTTOMLEFT, 0, 0)
  ui.footer:SetDimensions(w, 34)
  ui.footerLabel = makeLabel(ui.footer, "DM2StatsFooterLabel", 14, 0.85,0.85,0.85,1)
  ui.footerLabel:SetAnchor(LEFT, ui.footer, LEFT, 18, 0)

  ui.win:SetHandler("OnMoveStop", function()
    SV.ui.x = ui.win:GetLeft()
    SV.ui.y = ui.win:GetTop()
  end)

  if isConsoleUI() and type(KEYBIND_STRIP) == "table" then
    keybindGroup = {
      alignment = KEYBIND_STRIP_ALIGN_RIGHT,
      { name="Prev Page", gamepadName="Prev Page", order=1, keybind="UI_SHORTCUT_LEFT_SHOULDER",
        callback=function() R:SetPage((R._pageIndex or 1) - 1) end,
        visible=function() return R._interactiveMode and ui.win and not ui.win:IsHidden() end },
      { name="Next Page", gamepadName="Next Page", order=2, keybind="UI_SHORTCUT_RIGHT_SHOULDER",
        callback=function() R:SetPage((R._pageIndex or 1) + 1) end,
        visible=function() return R._interactiveMode and ui.win and not ui.win:IsHidden() end },
      { name="Prev Fight", gamepadName="Prev Fight", order=3, keybind="UI_SHORTCUT_LEFT_TRIGGER",
        callback=function()
          local cur = R._offset or 0
          if cur < getHistoryCount() - 1 then R:ShowOffset(cur + 1, { autoPopup = false, interactive = true, preserveTimer = true }) end
        end,
        visible=function() return R._interactiveMode and ui.win and not ui.win:IsHidden() end },
      { name="Next Fight", gamepadName="Next Fight", order=4, keybind="UI_SHORTCUT_RIGHT_TRIGGER",
        callback=function()
          local cur = R._offset or 0
          if cur > 0 then R:ShowOffset(cur - 1, { autoPopup = false, interactive = true, preserveTimer = true }) end
        end,
        visible=function() return R._interactiveMode and ui.win and not ui.win:IsHidden() end },
      { name="Close", gamepadName="Close", order=5, keybind="UI_SHORTCUT_NEGATIVE",
        callback=function() R:Hide() end,
        visible=function() return R._interactiveMode and ui.win and not ui.win:IsHidden() end },
    }
  end
end


-- ----------------------------
-- Render helpers
-- ----------------------------
local function setKpi(key, valueText)
  local c = R.ui.kpi[key]
  if not c then return end
  c.value:SetText(valueText or "")
end

local function fillList(listCtrl, rows)
  local maxRows = listCtrl.maxRows
  local rowH = listCtrl.rowH or 28
  local visibleCount = 0
  for i=1, maxRows do
    local r = listCtrl.rows[i]
    if not r then break end
    local raw = rows[i]
    local data = raw
    local texts = raw
    if type(raw) == "table" and raw.cols then
      data = raw
      texts = raw.cols
    end
    if texts then
      local textIdx = 0
      for ci,col in ipairs(listCtrl.cols or {}) do
        local kind = col.kind or "text"
        if kind == "icon" or kind == "bar" then
          -- non-text columns
        else
          textIdx = textIdx + 1
          if r.cols[ci] then r.cols[ci]:SetText(texts[textIdx] or "") end
        end
      end
      if r.icons then
        for _,icon in pairs(r.icons) do
          local tex = data.abilityId and getAbilityIcon(data.abilityId)
          if tex then icon:SetTexture(tex); icon:SetHidden(false)
          else icon:SetHidden(true) end
        end
      end
      if r.barChips then
        local bar = (type(data) == "table" and data.bar) or nil
        for _,chip in pairs(r.barChips) do applyBarChip(chip, bar) end
      end
      if r.shareBars then
        local sharePct = (type(data) == "table" and data.sharePct) or nil
        for _,backdrop in pairs(r.shareBars) do applyShareBar(backdrop, sharePct) end
      end
      r:SetHidden(false)
      visibleCount = i
    else
      for ci=1, #r.cols do if r.cols[ci] then r.cols[ci]:SetText("") end end
      if r.icons then for _,icon in pairs(r.icons) do icon:SetHidden(true) end end
      if r.barChips then for _,chip in pairs(r.barChips) do chip:SetHidden(true) end end
      if r.shareBars then for _,backdrop in pairs(r.shareBars) do backdrop:SetHidden(true) end end
      r:SetHidden(true)
    end
  end
  local headerH = listCtrl.headerRowH or 30
  listCtrl:SetHeight(headerH + 6 + (visibleCount * rowH) + LIST_BOTTOM_PAD)
  if listCtrl.body then listCtrl.body:SetHeight(visibleCount * rowH) end
end


-- EnsureScene removed. Custom scene creation caused persistent UI errors on console
-- (ZO_SceneManager_Leader operator< crashes, input never routing to addon callbacks).
-- Console input is now handled by pushing the game's own gamepad menu to get ESO's
-- native input routing, then layering our keybind group on top. See ShowOffset/Hide.



local function buildDebugRows(session, maxRows)
  maxRows = tonumber(maxRows) or 24
  local rows = {}
  if not session or not session.rotationDebug then return rows end
  local arr = {}
  for _, entry in pairs(session.rotationDebug) do
    table.insert(arr, entry)
  end
  table.sort(arr, function(a, b) return (a.captured + a.skipped) > (b.captured + b.skipped) end)
  for i = 1, math.min(maxRows, #arr) do
    local e = arr[i]
    rows[i] = {
      e.name or "?",
      tostring(e.id or 0),
      tostring(e.captured or 0),
      tostring(e.skipped or 0),
      e.lastReason or "",  -- now shows "slot N Front/Back bar" for input-based captures
    }
  end
  return rows
end

local function buildSetRows(session, maxRows)
  maxRows = tonumber(maxRows) or 10
  local rows = {}
  if not session then return rows end
  local dur = tonumber(session.durationMs) or 0
  local totalDamage = tonumber(session.totalDamage) or 0
  local setArr = {}
  for _,ps in pairs(session.sets or {}) do table.insert(setArr, ps) end
  table.sort(setArr, function(a,b) return (tonumber(a.dmg) or 0) > (tonumber(b.dmg) or 0) end)
  for i = 1, math.min(maxRows, #setArr) do
    local ps = setArr[i]
    local dmg = tonumber(ps.dmg) or 0
    local hits = tonumber(ps.hits) or 0
    local avgCrit = (hits > 0) and ((tonumber(ps.crit) or 0) / hits) or 0
    local dotp = (dmg > 0) and ((tonumber(ps.dot) or 0) / dmg) or 0
    local share = (totalDamage > 0) and (dmg / totalDamage) or 0
    local dps = (dur > 0) and (dmg / (dur/1000)) or 0
    rows[i] = richRow({
      ps.name or "?",
      fmtInt(dmg),
      fmtPct(share),
      tostring(hits),
      fmtPct(avgCrit),
      (dotp > 0.95) and "DoT" or (dotp < 0.05) and "Direct" or "Mixed",
      fmtDps(dps),
    }, { sharePct = share })
  end
  return rows
end

local function buildHistoryRows(activeOffset)
  local rows = {}
  local count = getHistoryCount()
  if count <= 0 then return rows end

  activeOffset = tonumber(activeOffset) or 0
  local maxRows = HISTORY_LIST_MAX_ROWS
  local halfWindow = math.floor(maxRows / 2)
  local startOffset = math.max(0, activeOffset - halfWindow)
  local endOffset = math.min(count - 1, startOffset + maxRows - 1)
  if (endOffset - startOffset + 1) < maxRows then
    startOffset = math.max(0, endOffset - maxRows + 1)
  end

  local rowIdx = 0
  for offset = startOffset, endOffset do
    local s = getHistoryAt(offset)
    if s then
      rowIdx = rowIdx + 1
      local dur = tonumber(s.durationMs) or 0
      local avgDps = (dur > 0) and ((tonumber(s.totalDamage) or 0) / (dur / 1000)) or 0
      local marker = (offset == activeOffset) and ">" or " "
      local dpsStr = fmtDps(avgDps)
      if s.isDummy then dpsStr = dpsStr .. " *" end
      local viewedIndex = count - offset
      local target = truncateText(s.lastTargetName or "?", 26)
      if s.isDummy then target = target .. " *" end
      rows[rowIdx] = {
        string.format("%s%d", marker, viewedIndex),
        target,
        dpsStr,
        formatSessionTimestampShort(s),
      }
    end
  end
  return rows
end

local function collectDummyTrendParses(maxCols)
  maxCols = tonumber(maxCols) or TREND_MAX_COLS
  local count = getHistoryCount()
  local arr = {}
  -- Newest dummy first (offset 0 = latest fight) so column 1 matches history list order.
  for offset = 0, count - 1 do
    local s = getHistoryAt(offset)
    if s and s.isDummy then
      local dur = tonumber(s.durationMs) or 0
      local hits = tonumber(s.hitCount) or 0
      table.insert(arr, {
        offset = offset,
        session = s,
        dps = dur > 0 and ((tonumber(s.totalDamage) or 0) / (dur / 1000)) or 0,
        crit = hits > 0 and ((tonumber(s.critCount) or 0) / hits) or 0,
        weave = getWeaveSuccessRatio(s),
      })
    end
  end
  if #arr > maxCols then
    local trimmed = {}
    for i = 1, maxCols do
      trimmed[i] = arr[i]
    end
    return trimmed
  end
  return arr
end

local function renderMiniSparkline(row, denseBuckets, barMaxH, highlight)
  if not row or not row.bars then return end
  local barCount = math.min(#denseBuckets, #row.bars)
  local gap = 2
  local barW = math.max(2, math.floor((row.sparkW - math.max(0, barCount - 1) * gap) / math.max(barCount, 1)))
  local anchor = row.anchor
  local colOffset = ((row.colIndex or 1) - 1) * (row.colW or row.sparkW)
  for i, bar in ipairs(row.bars) do
    if i <= barCount and denseBuckets[i] then
      local dmg = denseBuckets[i].dmg
      local maxDmg = row._maxDmg or 1
      local ratio = dmg / maxDmg
      local h = math.max(2, math.floor(ratio * barMaxH))
      bar:ClearAnchors()
      bar:SetDimensions(barW, h)
      bar:SetAnchor(BOTTOMLEFT, anchor, TOPLEFT, colOffset + 2 + (i - 1) * (barW + gap), barMaxH - 2)
      if highlight then
        bar:SetCenterColor(0.55, 0.95, 1.0, 0.95)
        bar:SetEdgeColor(0.9, 1.0, 1.0, 0.7)
      elseif ratio > 0.7 then
        bar:SetCenterColor(0.35, 0.92, 0.55, 0.88)
        bar:SetEdgeColor(0, 0, 0, 0)
      elseif ratio > 0.4 then
        bar:SetCenterColor(0.95, 0.82, 0.35, 0.88)
        bar:SetEdgeColor(0, 0, 0, 0)
      else
        bar:SetCenterColor(0.95, 0.45, 0.35, 0.82)
        bar:SetEdgeColor(0, 0, 0, 0)
      end
      bar:SetHidden(false)
    else
      bar:SetHidden(true)
    end
  end
end

local function renderComparisonSparklines(ui, dummies, activeOffset)
  if not ui or not ui.comparisonSparklines then return end
  activeOffset = tonumber(activeOffset) or 0
  for i = 1, 4 do
    local row = ui.comparisonSparklines[i]
    local session = dummies and dummies[i]
    if row and row.baseline then row.baseline:SetHidden(not session) end
    if session then
      local denseBuckets = sessionDenseBuckets(session)
      local maxDmg = 1
      for _, b in ipairs(denseBuckets) do
        if b.dmg > maxDmg then maxDmg = b.dmg end
      end
      row._maxDmg = maxDmg
      local activeSession = getHistoryAt(activeOffset)
      local highlight = (activeSession ~= nil and session == activeSession)
      renderMiniSparkline(row, denseBuckets, COMP_SPARKLINE_H - 6, highlight)
    elseif row and row.bars then
      for _, bar in ipairs(row.bars) do bar:SetHidden(true) end
    end
  end
end

local function renderTrendGrid(ui, trendData, activeOffset)
  if not ui then return end
  activeOffset = tonumber(activeOffset) or 0

  if ui.trendFightHeaders then
    for i = 1, TREND_MAX_COLS do
      local hdr = ui.trendFightHeaders[i]
      local entry = trendData[i]
      if hdr then
        if entry and entry.session then
          hdr:SetText(formatFightHeaderCompact(entry.session))
          local highlight = (entry.offset == activeOffset)
          if highlight then
            hdr:SetColor(0.55, 0.98, 1.0, 1)
          else
            hdr:SetColor(0.82, 0.96, 0.78, 1)
          end
          hdr:SetHidden(false)
        else
          hdr:SetText("")
          hdr:SetHidden(true)
        end
      end
    end
  end

  local metricDefs = {
    dps = {
      extract = function(d) return d.dps end,
      format = function(v) return fmtDps(v) end,
    },
    crit = {
      extract = function(d) return d.crit end,
      format = function(v) return fmtPct(v) end,
    },
    weave = {
      extract = function(d) return d.weave end,
      format = function(v) return fmtPct(v) end,
    },
  }

  for key, def in pairs(metricDefs) do
    local row = ui.trendMetricRows and ui.trendMetricRows[key]
    if row and row.cells then
      local maxVal = 0.001
      for _, d in ipairs(trendData) do
        local v = def.extract(d)
        if v > maxVal then maxVal = v end
      end
      local barMaxH = TREND_ROW_H - 18
      local barW = math.max(8, (row.trendColW or 44) - 10)
      for i, cell in ipairs(row.cells) do
        local entry = trendData[i]
        if entry then
          local v = def.extract(entry)
          local ratio = v / maxVal
          local h = math.max(3, math.floor(ratio * barMaxH))
          local highlight = (entry.offset == activeOffset)
          cell.bar:ClearAnchors()
          cell.bar:SetDimensions(barW, h)
          cell.bar:SetAnchor(BOTTOMLEFT, row.rowAnchor, TOPLEFT, cell.cellX + math.floor(((row.trendColW or 44) - barW) / 2), barMaxH + 2)
          if highlight then
            cell.bar:SetCenterColor(0.55, 0.95, 1.0, 0.95)
            cell.bar:SetEdgeColor(0.9, 1.0, 1.0, 0.8)
            if cell.value then cell.value:SetColor(0.75, 1.0, 1.0, 1) end
          elseif ratio > 0.7 then
            cell.bar:SetCenterColor(0.35, 0.92, 0.55, 0.88)
            cell.bar:SetEdgeColor(0, 0, 0, 0)
            if cell.value then cell.value:SetColor(0.92, 0.96, 1.0, 1) end
          elseif ratio > 0.4 then
            cell.bar:SetCenterColor(0.95, 0.82, 0.35, 0.88)
            cell.bar:SetEdgeColor(0, 0, 0, 0)
            if cell.value then cell.value:SetColor(0.92, 0.96, 1.0, 1) end
          else
            cell.bar:SetCenterColor(0.95, 0.45, 0.35, 0.82)
            cell.bar:SetEdgeColor(0, 0, 0, 0)
            if cell.value then cell.value:SetColor(0.92, 0.96, 1.0, 1) end
          end
          cell.bar:SetHidden(false)
          if cell.baseline then cell.baseline:SetHidden(false) end
          if cell.value then
            cell.value:SetText(def.format(v))
            cell.value:SetHidden(false)
          end
        else
          cell.bar:SetHidden(true)
          if cell.baseline then cell.baseline:SetHidden(true) end
          if cell.value then
            cell.value:SetText("")
            cell.value:SetHidden(true)
          end
        end
      end
    end
  end
end

-- v3.2.7: Fight comparison — find last N dummy parses and build comparison data
local function getRecentDummyParses(maxCount)
  maxCount = tonumber(maxCount) or 4
  local count = getHistoryCount()
  local dummies = {}
  for i = 0, count - 1 do
    local s = getHistoryAt(i)
    if s and s.isDummy then
      table.insert(dummies, s)
      if #dummies >= maxCount then break end
    end
  end
  return dummies
end

local function fmtDelta(cur, prev, fmt, invert)
  if not prev or not cur then return "" end
  local diff = cur - prev
  if math.abs(diff) < 0.001 then return "" end
  local better = invert and (diff < 0) or (diff > 0)
  local arrow = better and "|c66FF66^|r" or "|cFF6666v|r"
  return arrow
end

local function buildComparisonRows(dummies)
  local rows = {}
  if not dummies or #dummies == 0 then return rows end

  local function val(s, field)
    if not s then return 0 end
    return tonumber(s[field]) or 0
  end

  local function sessionDps(s)
    local dur = val(s, "durationMs")
    return dur > 0 and (val(s, "totalDamage") / (dur / 1000)) or 0
  end

  local function sessionCrit(s)
    local hits = val(s, "hitCount")
    return hits > 0 and (val(s, "critCount") / hits) or 0
  end

  local function sessionWeave(s)
    return getWeaveSuccessRatio(s)
  end

  local function sessionLaPerSec(s)
    local w = s and s.weave or {}
    local dur = val(s, "durationMs")
    local laCount = tonumber(w.laCount) or 0
    return dur > 0 and (laCount / (dur / 1000)) or 0
  end

  local function sessionDotPct(s)
    local total = val(s, "totalDamage")
    return total > 0 and (val(s, "dotDamage") / total) or 0
  end

  -- Build metric definitions: { label, extractFn, formatFn, invert? }
  local metrics = {
    { "Avg DPS",     sessionDps,    function(v) return fmtDps(v) end, false },
    { "Duration",    function(s) return val(s, "durationMs") end, function(v) return fmtDur(v) end, false },
    { "Total Dmg",   function(s) return val(s, "totalDamage") end, function(v) return fmtInt(v) end, false },
    { "Max Hit",     function(s) return val(s, "maxHit") end, function(v) return fmtInt(v) end, false },
    { "Crit %",      sessionCrit,   function(v) return fmtPct(v) end, false },
    { "Weave %",     sessionWeave,  function(v) return fmtPct(v) end, false },
    { "LA/s",        sessionLaPerSec, function(v) return string.format("%.2f", v) end, false },
    { "DOT %",       sessionDotPct, function(v) return fmtPct(v) end, false },
    { "Skill Presses", function(s) local w = s and s.weave or {} return tonumber(w.inputSkillPresses) or tonumber(w.skillEventCount) or 0 end, function(v) return tostring(math.floor(v)) end, false },
    { "Bar Swaps",   function(s) local w = s and s.weave or {} return tonumber(w.barSwapCount) or 0 end, function(v) return tostring(math.floor(v)) end, false },
  }

  local n = #dummies
  for _, m in ipairs(metrics) do
    local row = { m[1] }  -- metric label
    for i = 1, math.min(n, 4) do
      local curVal = m[2](dummies[i])
      local prevVal = (i < n) and m[2](dummies[i + 1]) or nil
      local delta = fmtDelta(curVal, prevVal, nil, m[4])
      table.insert(row, m[3](curVal) .. " " .. delta)
    end
    table.insert(rows, row)
  end
  return rows
end



local function extractEnchantText(itemLink)
  if not itemLink or itemLink == "" then return "-" end

  if type(GetItemLinkEnchantDescription) == "function" then
    local ok, desc = pcall(GetItemLinkEnchantDescription, itemLink)
    if ok and desc and desc ~= "" then
      desc = zo_strformat("<<1>>", desc)
      if desc ~= "" and desc ~= "-" then return desc end
    end
  end

  if type(GetItemLinkEnchantInfo) == "function" then
    local ok, a,b,c,d,e,f = pcall(GetItemLinkEnchantInfo, itemLink)
    if ok then
      local candidates = {a,b,c,d,e,f}
      local best = nil
      for _,v in ipairs(candidates) do
        if type(v) == "string" and v ~= "" then
          local s = zo_strformat("<<1>>", v)
          if s ~= "" and s ~= "-" then
            if (not best) or string.len(s) > string.len(best) then best = s end
          end
        end
      end
      if best then return best end
    end
  end

  if type(GetItemLinkEnchantId) == "function" then
    local ok, enchantId = pcall(GetItemLinkEnchantId, itemLink)
    enchantId = tonumber(enchantId) or 0
    if ok and enchantId > 0 then return "Enchanted" end
  end

  return "-"
end

local function extractTraitText(itemLink)
  if not itemLink or itemLink == "" then return "-" end

  local function bestString(...)
    local best = nil
    for i = 1, select("#", ...) do
      local v = select(i, ...)
      if type(v) == "string" and v ~= "" then
        local s = zo_strformat("<<1>>", v)
        if s ~= "" and s ~= "-" then
          if (not best) or string.len(s) > string.len(best) then best = s end
        end
      end
    end
    return best
  end

  if type(GetItemLinkTraitInfo) == "function" then
    local ok, a,b,c,d,e,f = pcall(GetItemLinkTraitInfo, itemLink)
    if ok then
      local best = bestString(a,b,c,d,e,f)
      if best then return best end
      local idx = tonumber(a) or tonumber(b) or tonumber(c) or 0
      if idx > 0 then return "Trait " .. tostring(idx) end
    end
  end

  if type(GetItemLinkTrait) == "function" then
    local ok, a,b,c,d = pcall(GetItemLinkTrait, itemLink)
    if ok then
      local best = bestString(a,b,c,d)
      if best then return best end
      local idx = tonumber(a) or tonumber(b) or 0
      if idx > 0 then return "Trait " .. tostring(idx) end
    end
  end

  return "-"
end

local function buildGearRows()
  local rows = {}
  if type(GetItemLink) ~= "function" or type(BAG_WORN) == "nil" then
    return { {"Gear", "Equipment APIs unavailable on this platform/state.", "-", "-"} }
  end
  local slotDefs = {
    {"Head", "EQUIP_SLOT_HEAD"}, {"Shoulders", "EQUIP_SLOT_SHOULDERS"}, {"Chest", "EQUIP_SLOT_CHEST"},
    {"Hands", "EQUIP_SLOT_HAND"}, {"Waist", "EQUIP_SLOT_WAIST"}, {"Legs", "EQUIP_SLOT_LEGS"}, {"Feet", "EQUIP_SLOT_FEET"},
    {"Neck", "EQUIP_SLOT_NECK"}, {"Ring 1", "EQUIP_SLOT_RING1"}, {"Ring 2", "EQUIP_SLOT_RING2"},
    {"Front Bar", "EQUIP_SLOT_MAIN_HAND"}, {"Off Hand", "EQUIP_SLOT_OFF_HAND"}, {"Back Bar", "EQUIP_SLOT_BACKUP_MAIN"},
    {"Back Off", "EQUIP_SLOT_BACKUP_OFF"},
  }
  for _,def in ipairs(slotDefs) do
    local slotId = _G[def[2]]
    if type(slotId) == "number" then
      local ok, link = pcall(GetItemLink, BAG_WORN, slotId)
      local name, trait, enchant = "-", "-", "-"
      if ok and link and link ~= "" and type(GetItemLinkName) == "function" then
        local okName, n = pcall(GetItemLinkName, link)
        if okName and n and n ~= "" then name = zo_strformat("<<1>>", n) end
        trait = extractTraitText(link)
        enchant = extractEnchantText(link)
      end
      table.insert(rows, { def[1], name, trait, enchant })
    end
  end
  return rows
end

local function buildBuffRows(session, maxRows)
  maxRows = tonumber(maxRows) or 16
  local rows = {}
  if not session or not session.buffs then return rows end
  local dur = tonumber(session.durationMs) or 0
  local arr = {}
  for _,b in pairs(session.buffs) do table.insert(arr, b) end
  table.sort(arr, function(a,b) return (tonumber(a.activeMs) or 0) > (tonumber(b.activeMs) or 0) end)
  for i=1, math.min(maxRows, #arr) do
    local b = arr[i]
    local activeMs = tonumber(b.activeMs) or 0
    local uptime = (dur > 0) and (activeMs / dur) or 0
    rows[i] = richRow({
      b.name or "?",
      classifyBuffSource(session, b),
      fmtPct(uptime),
      fmtDur(activeMs),
      fmtInt(b.applied or 0),
      (uptime >= 0.95) and "Core" or (uptime >= 0.50) and "Maintained" or "Situational",
    }, { abilityId = tonumber(b.id) or 0, bar = getSkillBar(session, b.id, b.name or "?") })
  end
  return rows
end

-- ----------------------------
-- Main render
-- ----------------------------

function R:RenderSession(session)
  if not session then
    setLabel(self.ui.sub, "No fights recorded yet.")
    for _,k in ipairs({"avg","peak","total","dur","crit","maxhit","split","events","epm","weave","avglag","setpct","heal","hps","overheal"}) do setKpi(k, "-") end
    if self.ui.modeNotice then self.ui.modeNotice:SetHidden(true) end
    if self.ui.spikesList then fillList(self.ui.spikesList, {}) end
    if self.ui.dipsList then fillList(self.ui.dipsList, {}) end
    if self.ui.sparklineBars then
      for _,bar in ipairs(self.ui.sparklineBars) do bar:SetHidden(true) end
    end
    if self.ui.setsList then fillList(self.ui.setsList, {}) end
    if self.ui.summarySkillsList then fillList(self.ui.summarySkillsList, {}) end
    if self.ui.setDetailList then fillList(self.ui.setDetailList, {}) end
    if self.ui.skillsList then fillList(self.ui.skillsList, {}) end
    if self.ui.rotationDiagSummary then
      for _,lbl in ipairs(self.ui.rotationDiagSummary) do lbl:SetText("") end
    end
    if self.ui.historyList then fillList(self.ui.historyList, {}) end
    if self.ui.comparisonList then fillList(self.ui.comparisonList, {}) end
    if self.ui.comparisonHeaders then
      for _,h in ipairs(self.ui.comparisonHeaders) do h:SetText("") end
    end
    if self.ui.comparisonFightHeaders then
      for _,h in ipairs(self.ui.comparisonFightHeaders) do h:SetText("") end
    end
    if self.ui.comparisonSparklines then
      for _, row in ipairs(self.ui.comparisonSparklines) do
        if row.baseline then row.baseline:SetHidden(true) end
        if row.bars then for _, bar in ipairs(row.bars) do bar:SetHidden(true) end end
      end
    end

    if self.ui.gearList then fillList(self.ui.gearList, {}) end
    if self.ui.buffsList then fillList(self.ui.buffsList, {}) end
    if self.ui.rotationDiagHint then self.ui.rotationDiagHint:SetText("") end
    if self.ui.perSkillWeaveList then fillList(self.ui.perSkillWeaveList, {}) end
    if self.ui.dotUptimeList then fillList(self.ui.dotUptimeList, {}) end
    if self.ui.rotationDiagTimelineLines then
      for _,lbl in ipairs(self.ui.rotationDiagTimelineLines) do lbl:SetText(""); lbl:SetHidden(true) end
    end
    if self.ui.pulseStrip then
      for _,block in ipairs(self.ui.pulseStrip) do block:SetHidden(true) end
    end
    if self.ui.snapshotList then fillList(self.ui.snapshotList, {}) end
    if self.ui.debugList then fillList(self.ui.debugList, {}) end
    if self.ui.trendFightHeaders then
      for _, hdr in ipairs(self.ui.trendFightHeaders) do hdr:SetText(""); hdr:SetHidden(true) end
    end
    if self.ui.trendMetricRows then
      for _, row in pairs(self.ui.trendMetricRows) do
        if row.cells then
          for _, cell in ipairs(row.cells) do
            if cell.bar then cell.bar:SetHidden(true) end
            if cell.baseline then cell.baseline:SetHidden(true) end
            if cell.value then cell.value:SetText(""); cell.value:SetHidden(true) end
          end
        end
      end
    end
    self:RefreshPageState()
    for _,pair in ipairs(self.ui.rotLines or {}) do
      pair[1]:SetText("")
      pair[2]:SetText("")
    end
    return
  end

  local dur = tonumber(session.durationMs) or 0
  local totalDamage = tonumber(session.totalDamage) or 0
  local directDamage = tonumber(session.directDamage) or 0
  local dotDamage = tonumber(session.dotDamage) or 0
  local hitCount = tonumber(session.hitCount) or 0
  local critCount = tonumber(session.critCount) or 0
  local skills = session.skills or {}
  local buffs = session.buffs or {}
  local sets = session.sets or {}

  local avgDps = (dur > 0) and (totalDamage / (dur/1000)) or 0
  local directPct = (totalDamage > 0) and (directDamage / totalDamage) or 0
  local dotPct = (totalDamage > 0) and (dotDamage / totalDamage) or 0
  local critPct = (hitCount > 0) and (critCount / hitCount) or 0
  local setDamage = 0
  for _,ps in pairs(sets) do setDamage = setDamage + (tonumber(ps.dmg) or 0) end
  local setPct = (totalDamage > 0) and (setDamage / totalDamage) or 0

  local peaks, dips = analyzeBuckets(session)
  local peakDps = 0
  if peaks[1] then peakDps = (tonumber(peaks[1].dmg) or 0) / ((SV.settings.bucketMs or 2000)/1000) end

  -- v3.2.0: DPS Sparkline rendering
  -- Note: session.buckets is sparse and 0-indexed. Must convert to dense array first.
  if self.ui.sparklineBars and session.buckets then
    local denseBuckets = {}
    for idx, b in pairs(session.buckets) do
      table.insert(denseBuckets, { idx = idx, dmg = b.dmg or 0 })
    end
    table.sort(denseBuckets, function(a, b) return a.idx < b.idx end)

    local maxDmg = 1
    for _, b in ipairs(denseBuckets) do
      if b.dmg > maxDmg then maxDmg = b.dmg end
    end
    local barCount = math.min(#denseBuckets, #self.ui.sparklineBars)
    local panelW = self.ui.sparklinePanel and self.ui.sparklinePanel:GetWidth() or 1000
    local barW = math.max(4, math.floor((panelW - 20) / math.max(barCount, 1)) - 1)
    local barMaxH = 32
    for i, bar in ipairs(self.ui.sparklineBars) do
      if i <= barCount and denseBuckets[i] then
        local dmg = denseBuckets[i].dmg
        local ratio = dmg / maxDmg
        local h = math.max(2, math.floor(ratio * barMaxH))
        bar:ClearAnchors()
        bar:SetDimensions(barW, h)
        bar:SetAnchor(BOTTOMLEFT, self.ui.sparklinePanel, BOTTOMLEFT, 10 + (i-1) * (barW + 1), -4)
        if ratio > 0.7 then bar:SetCenterColor(0.4, 1.0, 0.5, 0.9)
        elseif ratio > 0.4 then bar:SetCenterColor(1.0, 0.85, 0.3, 0.9)
        else bar:SetCenterColor(1.0, 0.4, 0.3, 0.8) end
        bar:SetHidden(false)
      else
        bar:SetHidden(true)
      end
    end
  end

  local ws = weaveSummary(session)
  local weaveSuccess = getWeaveSuccessRatio(session)
  local eventsPerMin = (dur > 0) and ((hitCount / (dur/1000)) * 60) or 0
  local totalHeal = tonumber(session.totalHealing) or 0
  local effectiveHeal = tonumber(session.effectiveHealing) or totalHeal
  local overHeal = math.max(0, totalHeal - effectiveHeal)
  local healPerSec = (dur > 0) and (effectiveHeal / (dur/1000)) or 0
  local overHealPct = (totalHeal > 0) and (overHeal / totalHeal) or 0

  local eq = (session.equippedSets and #session.equippedSets > 0) and table.concat(session.equippedSets, ", ") or "(unknown)"
  local viewedIndex, historyCount = getViewedHistoryIndex(self._offset or 0)
  local stampText = formatSessionTimestamp(session)
  local subText = string.format("Target: %s\nHistory: %d/%d • %s\nSets: %s\nDummy parse: %s", session.lastTargetName or "?", viewedIndex, historyCount, stampText, eq, session.isDummy and "Yes" or "No")
  setLabel(self.ui.sub, subText)
  if self.ui.modeNotice then
    local showNotice = self._showInteractiveHint == true
    self.ui.modeNotice:SetHidden(not showNotice)
    if showNotice then
      self.ui.modeNotice:SetText("Post-Parse Summary: Open from menu for full details, page navigation, and history.")
    else
      self.ui.modeNotice:SetText("")
    end
  end

  setKpi("avg", fmtDps(avgDps))
  setKpi("peak", fmtDps(peakDps))
  setKpi("total", fmtInt(totalDamage))
  setKpi("dur", fmtDur(dur))
  setKpi("crit", fmtPct(critPct))
  setKpi("maxhit", fmtInt(tonumber(session.maxHit) or 0))
  setKpi("split", string.format("%s / %s", fmtPct(directPct), fmtPct(dotPct)))
  setKpi("events", fmtInt(hitCount))
  setKpi("epm", string.format("%.0f", eventsPerMin))
  setKpi("weave", ((tonumber(ws.samples) or 0) > 0) and fmtPct(weaveSuccess) or "-")
  setKpi("avglag", (ws.samples > 0) and string.format("%.0f ms", ws.avgGap or 0) or "-")
  setKpi("setpct", fmtPct(setPct))
  setKpi("heal", fmtInt(totalHeal))
  setKpi("hps", fmtDps(healPerSec))
  setKpi("overheal", fmtPct(overHealPct))

  local rot = self.ui.rotLines or {}
  local avgGapTxt = (ws.samples > 0) and string.format("Avg LA Gap: %.0f ms", ws.avgGap or 0) or "Avg LA Gap: -"
  local bestGapTxt = (ws.samples > 0) and string.format("Best Gap: %.0f ms", ws.bestGap or 0) or "Best Gap: -"
  local worstGapTxt = (ws.samples > 0) and string.format("Worst Gap: %.0f ms", ws.worstGap or 0) or "Worst Gap: -"
  local rotText = {
    { string.format("LA Hits: %d", ws.laHits or 0), string.format("LA/s: %.2f", ws.laPerSec or 0) },
    { avgGapTxt, string.format("Weave Timing: %s", fmtPct(weaveSuccess or 0)) },
    { bestGapTxt, worstGapTxt },
    { string.format("Missed: %d | Late: %d", ws.missed or 0, ws.late or 0), string.format("Fast Presses: %d", ws.fastSkillPresses or 0) },
  }
  for i,pair in ipairs(rot) do
    pair[1]:SetText(rotText[i] and rotText[i][1] or "")
    pair[2]:SetText(rotText[i] and rotText[i][2] or "")
  end

  local bucketMs = SV.settings.bucketMs or 2000
  local function bucketTopAbilityText(b)
    if not b or not b.skills then return "-" end
    local top = topSkillsInWindow(b.skills, 1, session)
    if not top or not top[1] then return "-" end
    local s = top[1]
    local dps = (tonumber(s.dmg) or 0) / (bucketMs/1000)
    return string.format("%s (%s)", s.name or "-", fmtDps(dps))
  end
  local function bucketRow(title, b)
    if not b then return { title, "-", "-", "-" } end
    local dps = (tonumber(b.dmg) or 0) / (bucketMs/1000)
    local t0 = (tonumber(b.idx) or 0) * bucketMs
    local t1 = t0 + bucketMs
    local win = string.format("%.1f-%.1fs", t0 / 1000, t1 / 1000)
    return { title, win, fmtDps(dps), bucketTopAbilityText(b) }
  end
  fillList(self.ui.spikesList, { bucketRow("Burst 1", peaks[1]), bucketRow("Burst 2", peaks[2]), bucketRow("Burst 3", peaks[3]) })
  fillList(self.ui.dipsList, { bucketRow("Drop 1", dips[1]), bucketRow("Drop 2", dips[2]), bucketRow("Drop 3", dips[3]) })

  local setArr = {}
  for _,ps in pairs(sets) do table.insert(setArr, ps) end
  table.sort(setArr, function(a,b) return (tonumber(a.dmg) or 0) > (tonumber(b.dmg) or 0) end)
  local srows = {}
  local showS = self.ui.setsList.maxRows
  for i=1, math.min(showS, #setArr) do
    local ps = setArr[i]
    local dmg = tonumber(ps.dmg) or 0
    local hits = tonumber(ps.hits) or 0
    local avgCrit = (hits > 0) and ((tonumber(ps.crit) or 0) / hits) or 0
    local dotp = (dmg > 0) and ((tonumber(ps.dot) or 0) / dmg) or 0
    local share = (totalDamage > 0) and (dmg / totalDamage) or 0
    local dps = (dur > 0) and (dmg / (dur/1000)) or 0
    srows[i] = richRow({
      ps.name or "?",
      fmtInt(dmg),
      fmtPct(share),
      fmtPct(avgCrit),
      (dotp > 0.95) and "DoT" or (dotp < 0.05) and "Direct" or "Mixed",
      fmtDps(dps),
    }, { sharePct = share })
  end
  fillList(self.ui.setsList, srows)

  local skillArr = {}
  for _,s in pairs(skills) do table.insert(skillArr, s) end
  table.sort(skillArr, function(a,b) return (tonumber(a.dmg) or 0) > (tonumber(b.dmg) or 0) end)
  local rows = {}
  local showN = self.ui.skillsList.maxRows
  for i=1, math.min(showN, #skillArr) do
    local s = skillArr[i]
    local hits = tonumber(s.hits) or 0
    local dmg = tonumber(s.dmg) or 0
    local crits = tonumber(s.crit) or 0
    local avgHit = (hits > 0) and (dmg / hits) or 0
    local c = (hits > 0) and (crits / hits) or 0
    local share = (totalDamage > 0) and (dmg / totalDamage) or 0
    local dotp = (dmg > 0) and ((tonumber(s.dot) or 0) / dmg) or 0
    local dps = (dur > 0) and (dmg / (dur/1000)) or 0
    rows[i] = richRow({
      s.name or "?",
      fmtInt(dmg),
      tostring(hits),
      fmtInt(avgHit),
      fmtPct(share),
      fmtPct(c),
      classifyAoeSkill(session, s),
      classifyDamageSource(session, s),
      (dotp > 0.95) and "DoT" or (dotp < 0.05) and "Direct" or "Mixed",
      fmtDps(dps),
    }, { abilityId = tonumber(s.id) or 0, bar = getSkillBar(session, s.id, s.name), sharePct = share })
  end
  fillList(self.ui.skillsList, rows)

  local historyRows = buildHistoryRows(self._offset or 0)
  fillList(self.ui.historyList, historyRows)
  if self.ui.historyList and self.ui.historyList.rows then
    for _, r in ipairs(self.ui.historyList.rows) do
      if not r:IsHidden() and r.cols then
        local markerText = (r.cols[1] and r.cols[1]:GetText()) or ""
        local active = (string.sub(markerText, 1, 1) == ">")
        local cr, cg, cb = active and 0.55 or 1, active and 0.98 or 1, active and 1.0 or 1
        for _, col in pairs(r.cols) do
          if col and col.SetColor then col:SetColor(cr, cg, cb, 1) end
        end
      end
    end
  end

  -- v3.2.7: Fight comparison
  if self.ui.comparisonList then
    local dummies = getRecentDummyParses(4)
    local compRows = buildComparisonRows(dummies)
    fillList(self.ui.comparisonList, compRows)

    if self.ui.comparisonFightHeaders then
      for i = 1, 4 do
        if dummies[i] then
          self.ui.comparisonFightHeaders[i]:SetText(formatFightHeaderLabel(dummies[i]))
        else
          self.ui.comparisonFightHeaders[i]:SetText("")
        end
      end
    end
    if self.ui.comparisonHeaders then
      for i = 1, 4 do
        if dummies[i] then
          self.ui.comparisonHeaders[i]:SetText(string.format("#%d newest", i))
        else
          self.ui.comparisonHeaders[i]:SetText("")
        end
      end
    end
    renderComparisonSparklines(self.ui, dummies, self._offset or 0)
  end

  if self.ui.trendMetricRows then
    local trendData = collectDummyTrendParses(TREND_MAX_COLS)
    renderTrendGrid(self.ui, trendData, self._offset or 0)
  end

  local summarySkillRows = {}
  for i=1, math.min(5, #skillArr) do
    local s = skillArr[i]
    local dmg = tonumber(s.dmg) or 0
    local hits = tonumber(s.hits) or 0
    local crits = tonumber(s.crit) or 0
    local dps = (dur > 0) and (dmg / (dur/1000)) or 0
    local share = (totalDamage > 0) and (dmg / totalDamage) or 0
    local critPctSkill = (hits > 0) and (crits / hits) or 0
    summarySkillRows[i] = richRow({
      s.name or "?",
      fmtDps(dps),
      fmtPct(share),
      fmtPct(critPctSkill),
      fmtInt(tonumber(s.max) or 0),
    }, { abilityId = tonumber(s.id) or 0, bar = getSkillBar(session, s.id, s.name), sharePct = share })
  end
  if self.ui.summarySkillsList then fillList(self.ui.summarySkillsList, summarySkillRows) end
  if self.ui.gearList then fillList(self.ui.gearList, buildGearRows()) end
  if self.ui.setDetailList then fillList(self.ui.setDetailList, buildSetRows(session, self.ui.setDetailList.maxRows or 14)) end
  if self.ui.buffsList then fillList(self.ui.buffsList, buildBuffRows(session, self.ui.buffsList.maxRows or 16)) end
  if self.ui.rotationDiagSummary then
    local diagLines = buildRotationSummary(session)
    for i,lbl in ipairs(self.ui.rotationDiagSummary) do
      lbl:SetText(diagLines[i] or "")
    end
  end
  if self.ui.rotationDiagHint then
    self.ui.rotationDiagHint:SetText(buildRotationHint(session))
  end
  -- v3.2.0: Per-skill weave breakdown
  if self.ui.perSkillWeaveList then
    fillList(self.ui.perSkillWeaveList, buildPerSkillWeaveRows(session, 10))
  end

  -- v3.2.0: DOT uptime
  if self.ui.dotUptimeList then
    fillList(self.ui.dotUptimeList, buildDotUptimeRows(session, 10))
  end

  -- v3.2.0: Multi-label timeline rendering
  if self.ui.rotationDiagTimelineLines then
    local tLines = buildTimelineLines(session, 195)
    for i, lbl in ipairs(self.ui.rotationDiagTimelineLines) do
      if tLines[i] then
        lbl:SetText(tLines[i])
        lbl:SetHidden(false)
      else
        lbl:SetText("")
        lbl:SetHidden(true)
      end
    end
  end

  -- v3.2.0: Pulse strip rendering
  if self.ui.pulseStrip and session and session.weave and session.weave.timeline then
    local timeline = session.weave.timeline
    for i, block in ipairs(self.ui.pulseStrip) do
      local item = timeline[i]
      if item then
        local r = safeLower(item.result or "")
        if r == "good" then block:SetCenterColor(0.4, 1.0, 0.4, 1)
        elseif r == "late" then block:SetCenterColor(1.0, 0.8, 0.3, 1)
        elseif r == "missed" then block:SetCenterColor(1.0, 0.3, 0.3, 1)
        elseif r == "too fast" then block:SetCenterColor(0.4, 0.7, 1.0, 1)
        elseif r == "extra" then block:SetCenterColor(0.8, 0.53, 1.0, 1)
        elseif r == "channel" then block:SetCenterColor(0.4, 0.6, 1.0, 1)
        else block:SetCenterColor(0.5, 0.5, 0.5, 1) end
        block:SetHidden(false)
      else
        block:SetHidden(true)
      end
    end
  end

  local snapRows = {
    { "Target", session.lastTargetName or "?" },
    { "Viewed History", string.format("%d/%d", viewedIndex, historyCount) },
    { "Captured", stampText },
    { "Dummy Parse", session.isDummy and "Yes" or "No" },
    { "Damage Events", fmtInt(hitCount) },
    { "Critical Events", fmtInt(critCount) },
    { "LA Hits", fmtInt(ws.laHits or 0) },
    { "Weave Samples", fmtInt(ws.samples or 0) },
  }
  fillList(self.ui.snapshotList, snapRows)

  if self.ui.debugList then
    if SV.settings.debugRotation then
      fillList(self.ui.debugList, buildDebugRows(session, self.ui.debugList.maxRows or 24))
    else
      fillList(self.ui.debugList, { { "Debug mode is off.", "-", "-", "-", "Enable in settings" } })
    end
  end

  local listSectionChrome = 36 + BAR_CHIP_LEGEND_H + 2 + 10
  if self.ui.skillsPanel then self.ui.skillsPanel:SetHeight(listSectionChrome + self.ui.skillsList:GetHeight() + 10) end
  if self.ui.rotationDiagPanel then self.ui.rotationDiagPanel:SetHeight(660) end
  if self.ui.gearPanel then self.ui.gearPanel:SetHeight(36 + self.ui.gearList:GetHeight() + 10) end
  if self.ui.setDetailPanel then self.ui.setDetailPanel:SetHeight(36 + self.ui.setDetailList:GetHeight() + 10) end
  if self.ui.buffsPanel then
    self.ui.buffsPanel:SetHeight(listSectionChrome + self.ui.buffsList:GetHeight() + 10)
  end
  if self.ui.historyPanel then
    local noteH = 32
    local leftH = noteH + 6 + self.ui.historyList:GetHeight()
    local rightH = 18 + 4 + COMP_FIGHT_HEADER_H + 2 + COMP_SPARKLINE_H + HISTORY_COMP_LIST_GAP + (self.ui.comparisonList and self.ui.comparisonList:GetHeight() or 0)
    local calcH = HISTORY_CONTENT_PAD_Y + 6 + 24 + math.max(leftH, rightH) + HISTORY_BOTTOM_PAD
    self.ui.historyPanel:SetHeight(calcH)
  end
  if self.ui.trendPanel then
    self.ui.trendPanel:SetHeight(trendPanelHeight())
  end
  if self.ui.snapshotPanel then self.ui.snapshotPanel:SetHeight(36 + self.ui.snapshotList:GetHeight() + 10) end
  if self.ui.debugPanel and self.ui.debugList then self.ui.debugPanel:SetHeight(36 + self.ui.debugList:GetHeight() + 10) end

  local hint
  if isConsoleUI() then
    if self._interactiveMode then
      local page = (self.pages and self.pages[self._pageIndex or 1]) or nil
      local pageName = page and page.title or "Summary"
      hint = string.format("L1/R1 Pages | L2/R2 Fights | O Close | %s", pageName)
    elseif self._showInteractiveHint then
      hint = "Post-Parse Summary: Open from menu for full details, page navigation, and history"
    else
      hint = "Open from menu for full details | /dm2stats show | hide | clear"
    end
  else
    hint = "Commands: /dm2stats show | hide | clear"
  end
  setLabel(self.ui.footerLabel, hint)
  self:RefreshPageState()
end


updateCountdownLabel = function()
  if not (R.ui and R.ui.countdown) then return end
  local secs = tonumber(SV.settings.autoCloseSecs) or 0
  local isVisible = R.ui.win and (not R.ui.win:IsHidden())
  local show = isVisible and (secs > 0)
  R.ui.countdown:SetHidden(not show)
  if not show then
    R.ui.countdown:SetText("")
    return
  end
  if R._autoHidePaused then
    local rem = math.max(0, tonumber(R._autoHideRemainingMs) or 0)
    R.ui.countdown:SetText(string.format("Auto-close: Paused (%.1fs)", rem / 1000))
  elseif R._autoHideActive and R._autoHideEndMs then
    local rem = math.max(0, R._autoHideEndMs - NowMs())
    R.ui.countdown:SetText(string.format("Auto-close: %.1fs", rem / 1000))
  else
    local rem = math.max(0, tonumber(R._autoHideRemainingMs) or 0)
    if rem > 0 then
      R.ui.countdown:SetText(string.format("Auto-close: %.1fs", rem / 1000))
    else
      R.ui.countdown:SetText(string.format("Auto-close: %.1fs", secs))
    end
  end
end

local function stopAutoCloseTimer(keepRemaining)
  if keepRemaining and R._autoHideActive and R._autoHideEndMs then
    R._autoHideRemainingMs = math.max(0, R._autoHideEndMs - NowMs())
  elseif not keepRemaining then
    R._autoHideRemainingMs = 0
  end
  R._autoHideActive = false
  R._autoHideEndMs = nil
  EM:UnregisterForUpdate(R.name.."_AutoClose")
  updateCountdownLabel()
end

local function startAutoCloseTimer(durationMs)
  local ms = math.max(0, tonumber(durationMs) or 0)
  if ms <= 0 then
    stopAutoCloseTimer(false)
    return
  end
  R._autoHidePaused = false
  R._autoHideRemainingMs = ms
  R._autoHideActive = true
  R._autoHideEndMs = NowMs() + ms
  updateCountdownLabel()
  EM:RegisterForUpdate(R.name.."_AutoClose", 250, function()
    if not R._autoHideActive then
      EM:UnregisterForUpdate(R.name.."_AutoClose")
      updateCountdownLabel()
      return
    end
    updateCountdownLabel()
    if NowMs() >= R._autoHideEndMs then
      R:Hide()
    end
  end)
end

local function cancelQueuedResultsPopup()
  R._pendingPopupToken = (tonumber(R._pendingPopupToken) or 0) + 1
end

local function queueResultsPopup()
  cancelQueuedResultsPopup()
  local delaySecs = tonumber(SV and SV.settings and SV.settings.resultsPopupDelaySecs) or 2
  if delaySecs < 0 then delaySecs = 0 end
  if delaySecs > 5 then delaySecs = 5 end
  local delayMs = math.floor(delaySecs * 1000)
  local myToken = tonumber(R._pendingPopupToken) or 0

  if delayMs <= 0 then
    R:ShowStats({ offset = 0, autoPopup = true })
    return
  end

  zo_callLater(function()
    if (tonumber(R._pendingPopupToken) or 0) ~= myToken then return end
    if R.inCombat then return end
    R:ShowStats({ offset = 0, autoPopup = true })
  end, delayMs)
end

-- ----------------------------
-- Show/Hide
-- ----------------------------
local function refreshKeybindGroupSafe()
  if keybindGroup and type(KEYBIND_STRIP) == "table" and KEYBIND_STRIP.UpdateKeybindButtonGroup then
    pcall(function() KEYBIND_STRIP:UpdateKeybindButtonGroup(keybindGroup) end)
  end
end

local function addKeybindGroupSafe()
  if not isConsoleUI() then return end
  if not keybindGroup or type(KEYBIND_STRIP) ~= "table" then return end
  if R._keybindsAdded then
    refreshKeybindGroupSafe()
    return
  end
  pcall(function() KEYBIND_STRIP:AddKeybindButtonGroup(keybindGroup) end)
  R._keybindsAdded = true
  refreshKeybindGroupSafe()
end

local function removeKeybindGroupSafe()
  if not R._keybindsAdded then return end
  if keybindGroup and type(KEYBIND_STRIP) == "table" then
    pcall(function() KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindGroup) end)
  end
  R._keybindsAdded = false
end

function R:SetInteractiveMode(enabled)
  self._interactiveMode = (enabled == true)
  if not isConsoleUI() then return end
  if self._interactiveMode then
    addKeybindGroupSafe()
    if self._showInteractiveHint and self._autoHideActive then
      self._autoHidePaused = true
      stopAutoCloseTimer(true)
    end
  else
    removeKeybindGroupSafe()
    if self.ui and self.ui.win and not self.ui.win:IsHidden() then
      if self._autoHidePaused and (tonumber(self._autoHideRemainingMs) or 0) > 0 then
        self._autoHidePaused = false
        startAutoCloseTimer(self._autoHideRemainingMs)
      else
        self._autoHidePaused = false
        updateCountdownLabel()
      end
    end
  end
  if self.ui and self.ui.win and not self.ui.win:IsHidden() and self._offset ~= nil then
    self:RenderSession(getHistoryAt(self._offset or 0))
  else
    refreshKeybindGroupSafe()
    updateCountdownLabel()
  end
end

function R:ShowOffset(offset, opts)
  offset = tonumber(offset) or 0
  opts = opts or {}
  local wasVisible = self.ui and self.ui.win and (not self.ui.win:IsHidden())
  local preserveTimer = (opts.preserveTimer == true)
  local preservedRemaining = 0
  local preservedPaused = false
  if preserveTimer and wasVisible then
    if self._autoHideActive and self._autoHideEndMs then
      preservedRemaining = math.max(0, self._autoHideEndMs - NowMs())
    else
      preservedRemaining = math.max(0, tonumber(self._autoHideRemainingMs) or 0)
    end
    preservedPaused = (self._autoHidePaused == true)
  end

  self._showInteractiveHint = (opts.autoPopup == true)
  self._offset = offset
  self:BuildUI()

  if opts.pageIndex ~= nil then
    local _, pageIdx = self:GetPage(opts.pageIndex)
    self._pageIndex = pageIdx
  elseif opts.autoPopup == true then
    self._pageIndex = 1
  elseif not self._pageIndex then
    self._pageIndex = 1
  end

  if opts.interactive ~= nil then
    self._interactiveMode = (opts.interactive == true)
  elseif opts.autoPopup == true then
    self._interactiveMode = false
  else
    self._interactiveMode = true
  end

  local s = getHistoryAt(offset)
  self:RenderSession(s)

  -- Show the window directly — no scene forcing.
  self.ui.win:SetHidden(false)

  if isConsoleUI() then
    if self._interactiveMode then
      addKeybindGroupSafe()
    else
      removeKeybindGroupSafe()
    end
  end

  -- auto-close for any visible window when configured
  local secs = tonumber(SV.settings.autoCloseSecs) or 0
  self._autoHidePaused = false
  if secs > 0 then
    if preserveTimer and preservedRemaining > 0 then
      self._autoHidePaused = preservedPaused
      if preservedPaused then
        self._autoHideActive = false
        self._autoHideEndMs = nil
        self._autoHideRemainingMs = preservedRemaining
        EM:UnregisterForUpdate(R.name.."_AutoClose")
      else
        startAutoCloseTimer(preservedRemaining)
      end
    else
      startAutoCloseTimer(secs * 1000)
    end
  else
    stopAutoCloseTimer(false)
  end
  updateCountdownLabel()
end

function R:Show()
  self:ShowStats({ offset = 0, autoPopup = false, interactive = true, pageIndex = self._pageIndex or 1 })
end

-- Prefer MenuShell when statsViewer=="menu" (default) and gamepad path is available.
function R:PreferMenuViewer()
  if type(self.ShowMenu) ~= "function" then return false end
  local mode = SV and SV.settings and SV.settings.statsViewer
  if mode == "overlay" then return false end
  -- Menu requires gamepad preferred mode (console always; PC when gamepad UI on).
  local gamepadOk = isConsoleUI()
      or (type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode())
      or (type(IsInGamepadMode) == "function" and IsInGamepadMode())
  if not gamepadOk then return false end
  if mode == "menu" or mode == nil or mode == "" then return true end
  return false
end

-- Single entry for post-parse, slash, and LAM. Menu is default (v3.9.0).
function R:ShowStats(opts)
  opts = opts or {}
  if self:PreferMenuViewer() then
    -- Hide legacy overlay if it was open so we don't stack two UIs.
    if self.ui and self.ui.win and not self.ui.win:IsHidden() then
      -- Don't call full Hide() — that also closes menu. Just hide the window.
      pcall(function()
        self.ui.win:SetHidden(true)
        if isConsoleUI() then removeKeybindGroupSafe() end
      end)
    end
    self:ShowMenu()
    return true
  end
  self:ShowOffset(opts.offset or 0, {
    autoPopup = opts.autoPopup,
    interactive = opts.interactive,
    pageIndex = opts.pageIndex,
    preserveTimer = opts.preserveTimer,
  })
  return false
end

function R:Hide()
  cancelQueuedResultsPopup()
  -- Always try to close menu shell if open
  if type(self.HideMenu) == "function" then
    pcall(function() self:HideMenu() end)
  end
  if not self.ui or not self.ui.win then return end
  stopAutoCloseTimer(false)
  self._autoHidePaused = false
  self._interactiveMode = false
  self._showInteractiveHint = false

  if isConsoleUI() then
    removeKeybindGroupSafe()
  end

  updateCountdownLabel()
  self.ui.win:SetHidden(true)
end


function R:Toggle()
  if type(self.HideMenu) == "function" and DM2StatsMenuShell and type(DM2StatsMenuShell.IsShowing) == "function"
      and DM2StatsMenuShell.IsShowing() then
    self:HideMenu()
    return
  end
  self:BuildUI()
  if self.ui.win:IsHidden() then self:Show() else self:Hide() end
end

-- ----------------------------
-- Combat capture
-- ----------------------------
local function ensureSession()
  if not R.session then R.session = newSession() end
  return R.session
end

local function startIfNeeded(session, tMs, targetName)
  if session.started then return end
  session.started = true
  session.startMs = tMs
  session.lastTargetName = targetName

  -- snapshot currently equipped sets (for swap detection + proc attribution fallback)
  local sets, setMap = captureEquippedSets()
  session.equippedSets = sets
  session.equippedSetMap = setMap
  local slotIds, slotNames, slotBars, slotBarsByName, slotBySlot = captureSlottedAbilities()
  session.slottedAbilityIds = slotIds
  session.slottedAbilityNames = slotNames
  session.slottedAbilityBar = slotBars or {}
  session.slottedAbilityBarByName = slotBarsByName or {}
  session.slottedAbilityBySlot = slotBySlot or {}
end

local function closeActiveBuffs(session)
  -- close any active buff windows at endMs
  for _,b in pairs(session.buffs) do
    if b.activeStartMs then
      b.activeMs = (b.activeMs or 0) + math.max(0, session.endMs - b.activeStartMs)
      b.activeStartMs = nil
    end
  end
  -- close open enemy debuff windows
  if type(session.targetDebuffs) == "table" then
    for _, d in pairs(session.targetDebuffs) do
      if type(d) == "table" and d.activeStartMs then
        d.activeMs = (d.activeMs or 0) + math.max(0, session.endMs - d.activeStartMs)
        d.activeStartMs = nil
      end
    end
  end
end

local function finalizeSession(session)
  session.endMs = NowMs()
  session.durationMs = math.max(0, session.endMs - session.startMs)
  closeActiveBuffs(session)
  finalizePendingWeave(session, true)
  if session.weave and session.weave.pendingPostChannel then
    pushTimelineToken(session, session.weave.pendingPostChannel, SYM_POST_MISS, "Missed", { kind = "postchannel", skillName = session.weave.pendingPostChannel, missed = true })
    session.weave.pendingPostChannel = nil
  end
  retryAbilityNames(session)
  reconcileWeaveTimelineNames(session)
  reconcileSetContributions(session)
  if session.weave then
    session.weave.skillBarByName = buildWeaveSkillBarMap(session)
  end

  session.isDummy = isDummyParseConfidence(session.lastTargetName)
  session.completedAt = os.time()

  -- Snapshot character stats (base vs buffed) at fight end for Insights / Dashboard
  if DM2StatsMenuShell and type(DM2StatsMenuShell.CapturePlayerStats) == "function" then
    local okSnap, snap = pcall(DM2StatsMenuShell.CapturePlayerStats)
    if okSnap and type(snap) == "table" then
      session.playerStats = snap
    end
  end
  if DM2StatsMenuShell and type(DM2StatsMenuShell.CaptureActiveMundus) == "function" then
    local okM, mundus = pcall(DM2StatsMenuShell.CaptureActiveMundus)
    if okM and mundus and mundus ~= "" then
      session.mundus = mundus
    end
  end

  local minMs = tonumber(SV.settings.minFightMs) or 0
  local minDmg = tonumber(SV.settings.minDamage) or 0

  if session.durationMs < minMs or session.totalDamage < minDmg then
    return nil
  end

  return session
end

function R:OnCombatState(_, inCombat)
  self.inCombat = (inCombat == true)

  if inCombat then
    cancelQueuedResultsPopup()
    -- reset runtime capture
    self.session = newSession()
    return
  end

  -- combat ended — hide any active weave flash
  hideWeaveFlash()
  if not self.session or not self.session.started then return end

  local s = finalizeSession(self.session)
  if not s then
    self.session = nil
    return
  end

  pushHistory(s)

  -- auto-popup only for dummy parses
  if SV.settings.enable and SV.settings.autoPopupAfterParse and s.isDummy then
    queueResultsPopup()
  end

  self.session = nil
end

-- ----------------------------
-- Input-based rotation capture (v3.0.25)
-- Fires the instant the player presses ANY action bar button (LA, skill, ultimate).
-- Both LA presses and skill presses are captured here for accurate weave timing.
-- The weave gap is measured as: skill press → next LA press (all input-based).
-- ----------------------------
function R:OnActionSlotAbilityUsed(_, actionSlotIndex)
  if not SV or not SV.settings.enable then return end
  actionSlotIndex = tonumber(actionSlotIndex) or 0
  if actionSlotIndex < 1 then return end

  -- Must be in combat or have an active session
  local session = self.session
  if not session or not session.started then return end

  local tMs = NowMs()
  local w = session.weave
  if not w then return end

  -- Slots: 1=LA, 2=HA, 3-8=abilities (3=square, 4=triangle, 5=circle, 6=L1, 7=R1), 8+=ultimate/other
  local isLA = (actionSlotIndex == 1)
  local isHA = (actionSlotIndex == 2)

  -- -------------------------------------------------------
  -- LIGHT ATTACK pressed (slot 1): resolve pending weave
  -- -------------------------------------------------------
  if isLA then
    w.laPressCount = (w.laPressCount or 0) + 1

    -- Resolve post-channel: LA after a channel = good recovery
    if w.pendingPostChannel then
      pushTimelineToken(session, w.pendingPostChannel, SYM_POST_OK, "Good",
        { kind = "postchannel", skillName = w.pendingPostChannel })
      w.pendingPostChannel = nil
      flashWeaveResult("Good")

    -- Resolve pending skill: measure gap from skill press to this LA press
    elseif w.pendingSkill then
      local gap = tMs - (w.pendingSkill.tMs or tMs)
      local symbol, resultLabel = classifyWeaveGap(gap)
      if symbol == SYM_FAST then w.tooFastCount = (w.tooFastCount or 0) + 1 end
      if symbol == SYM_LATE then w.lateCount = (w.lateCount or 0) + 1 end
      if symbol == SYM_MISS then w.missedCount = (w.missedCount or 0) + 1 end
      if symbol == SYM_OK then w.onTimeCount = (w.onTimeCount or 0) + 1 end
      pushTimelineToken(session, w.pendingSkill.label, symbol, resultLabel,
        { kind = "skill", skillName = w.pendingSkill.skillName or w.pendingSkill.label,
          gapMs = gap, missed = (symbol == SYM_MISS),
          slot = w.pendingSkill.slot, bar = w.pendingSkill.bar,
          abilityId = w.pendingSkill.abilityId })
      w.pendingSkill = nil
      flashWeaveResult(resultLabel)
    end

    -- Track LA-to-LA intervals from input presses
    if w.lastLaPressMs then
      local delta = tMs - w.lastLaPressMs
      if delta > 0 then
        table.insert(w.laIntervals, delta)
      end
    end
    w.lastLaPressMs = tMs
    return  -- done handling LA
  end

  -- Heavy attack: just note it, don't drive weave logic
  if isHA then return end

  -- -------------------------------------------------------
  -- SKILL pressed (slot 3-8): capture for rotation timeline
  -- -------------------------------------------------------

  -- Resolve which ability is in this slot right now
  local abilityId = 0
  local abilityName = ""
  local barCategory = nil

  if type(GetActiveHotbarCategory) == "function" then
    local ok, cat = pcall(GetActiveHotbarCategory)
    if ok then barCategory = cat end
  end

  if type(GetSlotBoundId) == "function" then
    local ok, id
    if barCategory ~= nil then
      ok, id = pcall(GetSlotBoundId, actionSlotIndex, barCategory)
    else
      ok, id = pcall(GetSlotBoundId, actionSlotIndex)
    end
    if ok then abilityId = tonumber(id) or 0 end
  end

  if abilityId <= 0 then return end  -- empty slot or failed lookup

  abilityName = resolveAbilityName(abilityId)
  if not abilityName or abilityName == "" then abilityName = "Ability " .. tostring(abilityId) end

  -- Determine bar label for debug
  local barLabel = "?"
  if barCategory ~= nil then
    if type(HOTBAR_CATEGORY_PRIMARY) ~= "nil" and barCategory == HOTBAR_CATEGORY_PRIMARY then
      barLabel = "Front"
    elseif type(HOTBAR_CATEGORY_BACKUP) ~= "nil" and barCategory == HOTBAR_CATEGORY_BACKUP then
      barLabel = "Back"
    end
  elseif self._activeBar ~= nil then
    if type(HOTBAR_CATEGORY_PRIMARY) ~= "nil" and self._activeBar == HOTBAR_CATEGORY_PRIMARY then
      barLabel = "Front"
    elseif type(HOTBAR_CATEGORY_BACKUP) ~= "nil" and self._activeBar == HOTBAR_CATEGORY_BACKUP then
      barLabel = "Back"
    end
  end

  -- Check if this is a channel ability
  local isChannel = isChannelAbilityLabel(abilityName)

  -- Debug logging: log every skill button press
  trackRotationDebug(session, abilityId, abilityName, true,
    string.format("slot %d %s bar", actionSlotIndex, barLabel))

  -- Handle pending post-channel recovery: skill after channel without LA = miss
  if w.pendingPostChannel then
    if not isChannel then
      pushTimelineToken(session, w.pendingPostChannel, SYM_POST_MISS, "Missed",
        { kind = "postchannel", skillName = w.pendingPostChannel, missed = true })
      w.pendingPostChannel = nil
      flashWeaveResult("Missed")
    end
  end

  -- If there was already a pending skill waiting for a LA weave, mark it missed
  -- (two skills in a row without a LA between them)
  if w.pendingSkill then
    pushTimelineToken(session, w.pendingSkill.label, SYM_MISS, "Missed",
      { kind = "skill", skillName = w.pendingSkill.skillName or w.pendingSkill.label, missed = true,
        abilityId = w.pendingSkill.abilityId, slot = w.pendingSkill.slot, bar = w.pendingSkill.bar })
    w.missedCount = (w.missedCount or 0) + 1
    w.pendingSkill = nil
    flashWeaveResult("Missed")
  end

  -- Push channel or normal skill onto timeline
  if isChannel then
    if not w.pendingPostChannel then
      local channelLabel = trimSkillLabel(abilityName)
      pushTimelineToken(session, channelLabel, "", "Channel",
        { kind = "channel", skillName = abilityName, dashes = getChannelDashCount(abilityName), bar = barLabel })
      w.pendingPostChannel = "Post-" .. trimSkillLabel(abilityName, 14)
    end
  else
    w.pendingSkill = {
      label = trimSkillLabel(abilityName),
      skillName = abilityName,
      abilityId = abilityId,
      tMs = tMs,
      slot = actionSlotIndex,
      bar = barLabel,
    }
  end

  -- Track fast skill presses (queue overwrites)
  local minSkillGap = 120
  local fastSkillGap = tonumber(SV.settings.queueOverwriteMs) or 450
  if w.lastSkillEventMs then
    local skillDelta = tMs - w.lastSkillEventMs
    if skillDelta >= minSkillGap then
      w.skillEventCount = (w.skillEventCount or 0) + 1
      if skillDelta < fastSkillGap then
        w.fastSkillPresses = (w.fastSkillPresses or 0) + 1
      end
    end
  else
    w.skillEventCount = (w.skillEventCount or 0) + 1
  end
  w.lastSkillEventMs = tMs

  -- Store input metadata
  w.lastInputSlot = actionSlotIndex
  w.lastInputAbilityId = abilityId
  w.lastInputBar = barLabel
  w.lastInputMs = tMs
  w.inputSkillPresses = (w.inputSkillPresses or 0) + 1
  recordSkillBar(session, abilityId, barLabel, abilityName)
end

-- ----------------------------
-- Bar swap detection (v3.0.25)
-- ----------------------------
function R:OnActiveWeaponPairChanged(_, activeWeaponPair, locked)
  if not SV or not SV.settings.enable then return end

  -- Debounce: this event fires up to 3 times per swap
  local tMs = NowMs()
  if (tMs - self._lastBarSwapMs) < 100 then return end
  self._lastBarSwapMs = tMs

  -- Update active bar tracking
  if type(GetActiveHotbarCategory) == "function" then
    local ok, cat = pcall(GetActiveHotbarCategory)
    if ok then self._activeBar = cat end
  end

  -- Refresh slotted abilities on the session (captures the new bar's skills)
  local session = self.session
  if session and session.started then
    local slotIds, slotNames, slotBars, slotBarsByName, slotBySlot = captureSlottedAbilities()
    session.slottedAbilityIds = slotIds
    session.slottedAbilityNames = slotNames
    session.slottedAbilityBar = session.slottedAbilityBar or {}
    for id, bar in pairs(slotBars or {}) do
      session.slottedAbilityBar[id] = bar
    end
    session.slottedAbilityBarByName = session.slottedAbilityBarByName or {}
    for nameKey, bar in pairs(slotBarsByName or {}) do
      session.slottedAbilityBarByName[nameKey] = bar
    end
    session.slottedAbilityBySlot = slotBySlot or {}
    if not session.weave then session.weave = {} end
    session.weave.barSwapCount = (session.weave.barSwapCount or 0) + 1
  end
end

function R:OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                          sourceName, sourceType, targetName, targetType, hitValue, powerType,
                          damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  if not SV.settings.enable then return end
  if isError then return end

  -- player's (and player's pet/summon) outgoing healing (best-effort effective
  -- heal capture). This is your TOTAL contribution, so a matriarch's / companion's
  -- heals count toward your healing just like ESO credits them to you.
  if (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET)
     and (result == ACTION_RESULT_HEAL or result == ACTION_RESULT_CRITICAL_HEAL) then
    local heal = tonumber(hitValue) or 0
    if heal > 0 then
      local session = ensureSession()
      startIfNeeded(session, NowMs(), targetName)
      session.totalHealing = (session.totalHealing or 0) + heal
      session.effectiveHealing = (session.effectiveHealing or 0) + heal
    end
    return
  end

  -- only player's (and player's pet/summon) outgoing damage.
  -- ESO's official parse credits your pet/summon damage (sorc familiar/matriarch,
  -- atronachs, Warden bear, companion, etc.) to you. Dropping PLAYER_PET made
  -- totals read a few % low whenever a pet was active — same accuracy fix shipped
  -- in DM2 Simple DPS 1.0.10. COMBAT_UNIT_TYPE_PLAYER_PET is YOUR pets only, not
  -- groupmates'. Pet hits flow through the same damage/skill/bucket accounting, so
  -- the breakdown still sums to the total and matches the in-game posted DPS.
  if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET then
    return
  end

  local tMs = NowMs()
  local session = ensureSession()
  startIfNeeded(session, tMs, targetName)
  session.lastTargetName = targetName or session.lastTargetName
  local resolvedAbilityName = resolveAbilityName(abilityId, abilityName)

  -- Enemy status / debuff applications (Off Balance, Concussed, Major Breach, …)
  -- Track before the damage-only early-out so pure effect events are kept.
  if isEffectApplyResult(result) then
    if type(ACTION_RESULT_EFFECT_FADED) == "number" and result == ACTION_RESULT_EFFECT_FADED then
      recordTargetDebuffFade(session, abilityId, resolvedAbilityName, tMs)
    else
      recordTargetDebuffApply(session, abilityId, resolvedAbilityName, tMs, targetName)
    end
    -- Effect-only events stop here (no damage accounting)
    if not isOutgoingDamageEvent(result) then return end
  elseif classifyTargetStatusKind(resolvedAbilityName) then
    -- Some clients only emit status as named combat events (0 or small hitValue)
    local dmgProbe = tonumber(hitValue) or 0
    if dmgProbe <= 0 or not isOutgoingDamageEvent(result) then
      recordTargetDebuffApply(session, abilityId, resolvedAbilityName, tMs, targetName)
      if not isOutgoingDamageEvent(result) then return end
    end
  end

  -- v3.0.25: rotation capture is now driven by EVENT_ACTION_SLOT_ABILITY_USED (input-based).
  if not isOutgoingDamageEvent(result) then
    return
  end

  local dmg = tonumber(hitValue) or 0
  if dmg <= 0 then return end

  local dot = isDotResult(result)
  local crit = (result == ACTION_RESULT_CRITICAL_DAMAGE) or (result == ACTION_RESULT_DOT_TICK_CRITICAL) or (result == ACTION_RESULT_DAMAGE_SHIELDED_CRITICAL) or (result == ACTION_RESULT_BLOCKED_DAMAGE_CRITICAL)

  session.totalDamage = session.totalDamage + dmg
  if dot then
    session.dotDamage = session.dotDamage + dmg
    -- v3.2.2: Record DOT tick for uptime tracking (exclude set procs)
    -- DOT ticks often use different abilityIds than the slotted skill, so we track all
    -- player DOTs EXCEPT known set procs (which have their own tracking).
    if not resolveSetName(session, abilityId, resolvedAbilityName) then
      local dt = session.dotTicks
      if not dt[abilityId] then
        dt[abilityId] = { name = resolveAbilityName(abilityId, abilityName), ticks = {} }
      end
      table.insert(dt[abilityId].ticks, tMs)
    end
  else
    session.directDamage = session.directDamage + dmg
  end

  session.hitCount = session.hitCount + 1
  if crit then session.critCount = session.critCount + 1 end
  if dmg > (session.maxHit or 0) then session.maxHit = dmg end

  -- bucket
  local idx = bucketIndexFor(session, tMs)
  local b = ensureBucket(session, idx)
  b.dmg = b.dmg + dmg
  if dot then b.dot = b.dot + dmg else b.direct = b.direct + dmg end
  b.hits = b.hits + 1
  if crit then b.crit = b.crit + 1 end
  b.skills[abilityId] = (b.skills[abilityId] or 0) + dmg

  -- skill
  local s = ensureSkill(session, abilityId, resolvedAbilityName)
  s.dmg = s.dmg + dmg
  s.hits = s.hits + 1
  if crit then s.crit = s.crit + 1 end
  if dmg > (s.max or 0) then s.max = dmg end
  if dot then s.dot = s.dot + dmg else s.direct = s.direct + dmg end

  local bar = getSkillBar(session, abilityId, resolvedAbilityName)
  if bar then
    recordSkillBar(session, abilityId, bar, resolvedAbilityName)
  end

  -- armor/weapon set proc grouping (abilityId map or equipped set-name match)
  local setName = resolveSetName(session, abilityId, resolvedAbilityName)
  if setName then
    local ps = ensureSet(session, setName)
    if ps then
      ps.dmg = ps.dmg + dmg
      ps.hits = ps.hits + 1
      if crit then ps.crit = ps.crit + 1 end
      if dot then ps.dot = ps.dot + dmg else ps.direct = ps.direct + dmg end
    end
  end

  -- LA hit confirmation: count server-confirmed LA hits for summary stats.
  -- v3.0.25: weave timing is now fully input-based (OnActionSlotAbilityUsed handles
  -- both LA presses and skill presses). This section only counts confirmed hits.
  local la = isLightAttack(abilityId, abilityName, abilityActionSlotType)
  if la then
    local w = session.weave
    w.laCount = (w.laCount or 0) + 1
    w.lastLaHitMs = tMs
  end
end

function R:OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime,
                           stackCount, iconName, buffType, effectType, abilityType, statusEffectType,
                           unitName, unitId, abilityId, sourceType)
  if not SV.settings.enable then return end
  if not self.session or not self.session.started then return end

  local session = self.session
  abilityId = tonumber(abilityId) or 0
  local tMs = NowMs()
  local resolvedEffectName = resolveAbilityName(abilityId, effectName)
  if (not resolvedEffectName or resolvedEffectName == "") and effectName and effectName ~= "" then
    resolvedEffectName = zo_strformat("<<1>>", effectName)
  end

  ------------------------------------------------------------------
  -- Target / enemy debuffs (reticle target or any non-player unit)
  -- Prefer effects you (or pet) applied; also keep known status names.
  ------------------------------------------------------------------
  if unitTag ~= "player" then
    local fromUs = false
    if type(COMBAT_UNIT_TYPE_PLAYER) == "number" and sourceType == COMBAT_UNIT_TYPE_PLAYER then fromUs = true end
    if type(COMBAT_UNIT_TYPE_PLAYER_PET) == "number" and sourceType == COMBAT_UNIT_TYPE_PLAYER_PET then fromUs = true end
    local knownStatus = classifyTargetStatusKind(resolvedEffectName) ~= nil
    -- reticleover / target tags are the usual dummy parse path
    local tag = tostring(unitTag or "")
    local isTargetTag = (tag == "reticleover" or tag == "reticleoverplayer"
      or string.find(tag, "boss", 1, true) == 1 or string.find(tag, "target", 1, true) == 1)
    if (fromUs or knownStatus) and (isTargetTag or fromUs) and abilityId > 0 then
      if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        recordTargetDebuffApply(session, abilityId, resolvedEffectName, tMs, unitName or session.lastTargetName)
      elseif changeType == EFFECT_RESULT_FADED then
        recordTargetDebuffFade(session, abilityId, resolvedEffectName, tMs)
      end
    end
    return
  end

  ------------------------------------------------------------------
  -- Player buffs (existing path)
  ------------------------------------------------------------------
  if abilityId == 0 then return end

  local b = session.buffs[abilityId]
  if not b then
    b = { id=abilityId, name = (effectName and effectName ~= "") and zo_strformat("<<1>>", effectName) or ("Buff "..tostring(abilityId)), applied=0, activeMs=0, activeStartMs=nil }
    session.buffs[abilityId] = b
  end

  -- sourceType: COMBAT_UNIT_TYPE_PLAYER / GROUP / OTHER / … (when API provides it)
  if sourceType ~= nil then
    b.sourceType = sourceType
    if type(COMBAT_UNIT_TYPE_PLAYER) == "number" and sourceType == COMBAT_UNIT_TYPE_PLAYER then
      b.fromSelf = true
    elseif type(COMBAT_UNIT_TYPE_PLAYER_PET) == "number" and sourceType == COMBAT_UNIT_TYPE_PLAYER_PET then
      b.fromSelf = true
      b.fromPet = true
    elseif type(COMBAT_UNIT_TYPE_GROUP) == "number" and sourceType == COMBAT_UNIT_TYPE_GROUP then
      b.fromGroup = true
    elseif type(COMBAT_UNIT_TYPE_OTHER) == "number" and sourceType == COMBAT_UNIT_TYPE_OTHER then
      b.fromExternal = true
    end
  end

  -- changeType: EFFECT_RESULT_GAINED, EFFECT_RESULT_FADED, EFFECT_RESULT_UPDATED
  if changeType == EFFECT_RESULT_GAINED then
    b.applied = (b.applied or 0) + 1
    b.activeStartMs = tMs
  elseif changeType == EFFECT_RESULT_FADED then
    if b.activeStartMs then
      b.activeMs = (b.activeMs or 0) + math.max(0, tMs - b.activeStartMs)
      b.activeStartMs = nil
    end
  elseif changeType == EFFECT_RESULT_UPDATED then
    if b.activeStartMs then
      b.activeMs = (b.activeMs or 0) + math.max(0, tMs - b.activeStartMs)
    end
    b.applied = (b.applied or 0) + 1
    b.activeStartMs = tMs
  end
end

-- ----------------------------
-- Slash commands
-- ----------------------------
local function slashHandler(text)
  text = safeLower(text or "")
  text = zo_strformat("<<1>>", text)

  if text == "" or text == "toggle" then
    -- Toggle: if menu showing hide; if overlay showing hide; else ShowStats
    if type(R.HideMenu) == "function" and DM2StatsMenuShell and type(DM2StatsMenuShell.IsShowing) == "function"
        and DM2StatsMenuShell.IsShowing() then
      R:HideMenu()
      return
    end
    if R.ui and R.ui.win and not R.ui.win:IsHidden() then
      R:Hide()
      return
    end
    R:ShowStats({ autoPopup = false, interactive = true })
    return
  end

  if text == "show" then
    R:ShowStats({ autoPopup = false, interactive = true })
    return
  end

  if text == "hide" then
    R:Hide()
    return
  end

  if text == "clear" then
    clearHistory()
    R:Hide()
    d("|c88ff88DM2 Stats|r: history cleared")
    return
  end

  if text == "share" then
    exportParseToChat(getHistoryAt(0))
    return
  end

  if text == "menu" or text == "shell" then
    if type(R.ShowMenu) == "function" then
      R:ShowMenu()
    else
      d("|cFFAA00DM2 Stats|r: gamepad menu shell not loaded.")
    end
    return
  end

  if text == "legacy" or text == "overlay" then
    R:ShowOffset(0, { autoPopup = false, interactive = true })
    return
  end

  if text == "dump" or text == "dumpids" then
    local s = getHistoryAt(0)
    if not s then d("|c88ff88DM2 Stats|r: no fights in history") return end
    local dur = s.durationMs or 0
    local avg = (dur > 0) and (s.totalDamage / (dur/1000)) or 0
    d(string.format("|c88ff88DM2 Stats|r: unmapped abilityId dump (top damage, last fight)  Avg DPS: %s", fmtDps(avg)))
    local arr = {}
    for _,sk in pairs(s.skills or {}) do
      local setName = resolveSetName(s, sk.id, sk.name)
      if not setName then
        table.insert(arr, sk)
      end
    end
    table.sort(arr, function(a,b) return (a.dmg or 0) > (b.dmg or 0) end)
    local maxLines = 20
    for i=1, math.min(maxLines, #arr) do
      local sk = arr[i]
      local share = (s.totalDamage > 0) and ((sk.dmg or 0) / s.totalDamage) or 0
      if share < 0.005 then break end
      d(string.format("  %2d) %s  (id=%d)  %s  (%s)", i, sk.name or "?", tonumber(sk.id) or 0, fmtInt(sk.dmg or 0), fmtPct(share)))
    end
    d("|c88ff88DM2 Stats|r: add abilityId->setName entries to SET_PROC_BY_ABILITY_ID in the addon to group set procs.")
    return
  end

  -- allow /dm2stats 3 to show 3-back
  local n = tonumber(text)
  if n and n >= 0 then
    R:ShowOffset(n, { autoPopup = false })
    return
  end

  d("|c88ff88DM2 Stats|r commands: /dm2stats [toggle|show|hide|clear|share|menu|legacy|dump|N]")
end

local function registerSlash()
  SLASH_COMMANDS["/dm2stats"] = function(arg)
    arg = zo_strlower((arg or ""):gsub("^%s+", ""):gsub("%s+$", ""))
    if arg == "debug" then
      SV.settings.debugRotation = not SV.settings.debugRotation
      d(string.format("DM2Stats: rotation debug log %s.", SV.settings.debugRotation and "enabled" or "disabled"))
      if DEBUG_UI_ENABLED then
        R:ShowOffset(0, { autoPopup = false, interactive = true, pageIndex = 9 })
      end
      return
    end
    slashHandler(arg)
  end
  SLASH_COMMANDS["/dm2statsshow"] = function() R:ShowStats({ autoPopup = false, interactive = true }) end
  SLASH_COMMANDS["/dm2statshide"] = function() R:Hide() end
  SLASH_COMMANDS["/dm2statsclear"] = function() clearHistory(); R:Hide(); d("|c88ff88DM2 Stats|r: history cleared") end
  SLASH_COMMANDS["/dm2statsdebug"] = function()
    SV.settings.debugRotation = not SV.settings.debugRotation
    d(string.format("DM2Stats: rotation debug log %s.", SV.settings.debugRotation and "enabled" or "disabled"))
    if DEBUG_UI_ENABLED then
      R:ShowOffset(0, { autoPopup = false, interactive = true, pageIndex = 9 })
    end
  end
end

-- ----------------------------
-- (Optional) LibAddonMenu settings
-- ----------------------------
local function initLAM()
  if not LibAddonMenu2 then return end

  local LAM = LibAddonMenu2
  local panelData = {
    type = "panel",
    name = R.displayName,
    displayName = R.displayName,
    author = "Fred + ChatGPT",
    version = R.version,
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local panel = LAM:RegisterAddonPanel("DM2StatsLAMPanel", panelData)

  local options = {
    -- =============================================
    -- QUICK OPEN (menu is the only first-class UI)
    -- =============================================
    { type = "header", name = "Quick Open" },
    {
      type = "button",
      name = "Open Stats",
      tooltip = "Open the dual-pane stats menu. Gamepad mode. L2/R2 fight history. O/back to close. /dm2stats show",
      func = function()
        R:ShowStats({ autoPopup = false, interactive = true })
      end,
      width = "full",
    },
    {
      type = "checkbox",
      name = "Journal gamepad menu entry",
      tooltip = "When on, adds DM2 Stats under the gamepad Journal menu.",
      getFunc = function() return SV.settings.experimentalGamepadMenu ~= false end,
      setFunc = function(v) SV.settings.experimentalGamepadMenu = v and true or false end,
      default = true,
    },

    -- =============================================
    -- GENERAL
    -- =============================================
    { type = "header", name = "General" },
    {
      type = "checkbox",
      name = "Enable",
      getFunc = function() return SV.settings.enable end,
      setFunc = function(v) SV.settings.enable = v end,
      default = R.defaults.settings.enable,
    },
    {
      type = "checkbox",
      name = "Auto-popup after dummy parse",
      tooltip = "Opens the stats menu after a dummy parse ends.",
      getFunc = function() return SV.settings.autoPopupAfterParse end,
      setFunc = function(v) SV.settings.autoPopupAfterParse = v end,
      default = R.defaults.settings.autoPopupAfterParse,
    },
    {
      type = "slider",
      name = "Results popup delay (seconds)",
      tooltip = "Delays the post-fight stats menu after combat ends. Helpful for lingering animations, DoTs, and video capture.",
      min = 0, max = 5, step = 1,
      getFunc = function() return SV.settings.resultsPopupDelaySecs or 2 end,
      setFunc = function(v) SV.settings.resultsPopupDelaySecs = v end,
      default = R.defaults.settings.resultsPopupDelaySecs,
    },
    {
      type = "slider",
      name = "History size",
      min = 5, max = 50, step = 1,
      getFunc = function() return SV.settings.historyMax end,
      setFunc = function(v) SV.settings.historyMax = v end,
      default = R.defaults.settings.historyMax,
    },
    {
      type = "button",
      name = "Clear history",
      func = function() clearHistory(); R:Hide() end,
      width = "half",
    },
    {
      type = "checkbox",
      name = "Dummy detection strict (name AND housing)",
      getFunc = function() return SV.settings.dummyStrict end,
      setFunc = function(v) SV.settings.dummyStrict = v end,
      default = R.defaults.settings.dummyStrict,
    },

    -- =============================================
    -- WEAVE FLASH (Training)
    -- =============================================
    { type = "header", name = "Weave Flash (Training)" },
    {
      type = "checkbox",
      name = "Enable weave flash",
      tooltip = "Flashes Good/Late/Missed at screen center during combat after each weave. Great for learning the LA weave rhythm. Turn off once comfortable.",
      getFunc = function() return SV.settings.showWeaveFlash end,
      setFunc = function(v) SV.settings.showWeaveFlash = v end,
      default = R.defaults.settings.showWeaveFlash,
    },
    {
      type = "slider",
      name = "Flash text size",
      tooltip = "Font size for the weave flash text (default 36).",
      min = 20, max = 52, step = 2,
      getFunc = function() return SV.settings.weaveFlashSize or 36 end,
      setFunc = function(v) SV.settings.weaveFlashSize = v; updateWeaveFlashFont() end,
      default = R.defaults.settings.weaveFlashSize,
    },
    {
      type = "slider",
      name = "Flash duration (ms)",
      tooltip = "How long the flash text stays on screen (200-800ms, default 500).",
      min = 200, max = 800, step = 50,
      getFunc = function() return SV.settings.weaveFlashDuration or 500 end,
      setFunc = function(v) SV.settings.weaveFlashDuration = v end,
      default = R.defaults.settings.weaveFlashDuration,
    },
    {
      type = "checkbox",
      name = "Weave sound cue",
      tooltip = "Plays a subtle sound on each weave: chime for Good, alert for Late, error for Missed. Works independently of the visual flash.",
      getFunc = function() return SV.settings.weaveFlashSound end,
      setFunc = function(v) SV.settings.weaveFlashSound = v end,
      default = R.defaults.settings.weaveFlashSound,
    },

    -- =============================================
    -- ADVANCED / LEGACY (overlay retained for rollback only)
    -- =============================================
    { type = "header", name = "Advanced / Legacy" },
    {
      type = "dropdown",
      name = "Stats viewer",
      tooltip = "Menu = dual-pane (default, recommended). Overlay = old window (rollback only). Prefer O/back on menu; no countdown required.",
      choices = { "menu", "overlay" },
      getFunc = function()
        local v = SV.settings.statsViewer
        if v == "overlay" then return "overlay" end
        return "menu"
      end,
      setFunc = function(v)
        SV.settings.statsViewer = (v == "overlay") and "overlay" or "menu"
      end,
      default = "menu",
    },
    {
      type = "button",
      name = "Open legacy overlay",
      tooltip = "Force-open the old multi-page window. Prefer menu for normal use. /dm2stats legacy",
      func = function() R:ShowOffset(0, { autoPopup = false, interactive = true, pageIndex = 1 }) end,
      width = "half",
    },
    {
      type = "button",
      name = "Close any open viewer",
      tooltip = "Closes menu and/or legacy overlay.",
      func = function() R:Hide() end,
      width = "half",
    },
    {
      type = "slider",
      name = "Legacy overlay auto-close (0 = never)",
      tooltip = "Only applies when Stats viewer = overlay. Menu closes with O/back.",
      min = 0, max = 60, step = 1,
      getFunc = function() return SV.settings.autoCloseSecs or 0 end,
      setFunc = function(v) SV.settings.autoCloseSecs = v end,
      default = 0,
    },
  }

  if DEBUG_UI_ENABLED then
    table.insert(options, {
      type = "header",
      name = "Debug",
    })
    table.insert(options, {
      type = "checkbox",
      name = "Enable rotation debug log",
      tooltip = "Shows per-skill capture/skip counts on the Debug Log page. Helps diagnose rotation tracker issues.",
      getFunc = function() return SV.settings.debugRotation end,
      setFunc = function(v) SV.settings.debugRotation = v end,
      default = R.defaults.settings.debugRotation,
    })
  end

  LAM:RegisterOptionControls("DM2StatsLAMPanel", options)
end

-- ----------------------------
-- Init
-- ----------------------------
function R:Initialize()
  SV = ZO_SavedVars:NewAccountWide(self.ns, 1, nil, self.defaults)
  ensureSV()

  registerSlash()
  initLAM()

  -- MenuShell is the default stats viewer (v3.9.0). Always init when available so
  -- post-parse popup and /dm2stats show can open it. Journal entry still gated.
  if DM2StatsMenuShell and type(DM2StatsMenuShell.Initialize) == "function" then
    pcall(function() DM2StatsMenuShell.Initialize() end)
  end

  EM:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(...) self:OnCombatState(...) end)
  EM:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)

  -- v3.0.25: Input-based rotation capture — fires the instant a skill button is pressed.
  -- This replaces damage-event inference for the rotation timeline and weave analysis.
  if type(EVENT_ACTION_SLOT_ABILITY_USED) ~= "nil" then
    EM:RegisterForEvent(self.name .. "_SlotUsed", EVENT_ACTION_SLOT_ABILITY_USED,
      function(...) self:OnActionSlotAbilityUsed(...) end)
  end

  -- v3.0.25: Bar swap tracking — refresh slot mappings and count swaps.
  if type(EVENT_ACTIVE_WEAPON_PAIR_CHANGED) ~= "nil" then
    EM:RegisterForEvent(self.name .. "_BarSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED,
      function(...) self:OnActiveWeaponPairChanged(...) end)
  end

  -- Capture initial active bar
  if type(GetActiveHotbarCategory) == "function" then
    local ok, cat = pcall(GetActiveHotbarCategory)
    if ok then self._activeBar = cat end
  end

  EM:RegisterForEvent(self.name, EVENT_EFFECT_CHANGED, function(...) self:OnEffectChanged(...) end)

  if type(SCENE_MANAGER) == "table" and SCENE_MANAGER.RegisterCallback then
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, oldState, newState)
      if not (self.ui and self.ui.win and not self.ui.win:IsHidden()) then return end
      if not isConsoleUI() then return end
      if scene == nil then return end
      local sceneName = nil
      if type(scene.GetName) == "function" then
        local ok, n = pcall(function() return scene:GetName() end)
        if ok then sceneName = n end
      end
      if sceneName == "gameMenuGamepad" and newState == SCENE_SHOWING then
        self:SetInteractiveMode(true)
      elseif sceneName == "gameMenuGamepad" and (newState == SCENE_HIDDEN or newState == SCENE_HIDING) then
        if self._showInteractiveHint then
          self:SetInteractiveMode(false)
        end
      end
    end)
  end

  d(string.format("|c88ff88%s|r v%s loaded. /dm2stats  |  menu: /dm2stats menu", self.displayName, self.version))

  -- Version announcement popup (delayed 3s so login UI settles)
  if SV.lastAnnouncementVersion ~= self._latestAnnouncementVersion then
    local ann = self._announcements[self._latestAnnouncementVersion]
    if ann then
      zo_callLater(function()
        showAnnouncementPopup(ann.title, ann.body)
      end, 3000)
    end
  end
end

local function OnAddOnLoaded(event, addonName)
  if addonName ~= R.name then return end
  EM:UnregisterForEvent(R.name, EVENT_ADD_ON_LOADED)
  R:Initialize()
end

EM:RegisterForEvent(R.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
