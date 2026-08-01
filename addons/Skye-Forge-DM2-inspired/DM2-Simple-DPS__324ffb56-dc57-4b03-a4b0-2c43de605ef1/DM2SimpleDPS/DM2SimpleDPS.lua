-- -----------------------------------------------------------------------------
-- DM2 Simple DPS
-- Description: A simple, libHarvens-free app for tracking DPS during fights/parses
-- Current Version: 1.0.12
-- Release Notes: Fight and Session columns nudged left so 9-figure comma-
--                delimited totals fit without clipping (HM vet boss fights).
-- Prior Notes:  1.0.11 -- Panel reorganized into Live / Fight / Session columns
--                with Session Total and Total DPS Time (active damage seconds
--                only). Location-aware subtitle plus bottom-left branding.
--                1.0.10 -- Accuracy fix: pet/summon damage now included.
--                1.0.9 -- Sustained DPS became a SESSION metric: it accumulates
--                across a whole dungeon run / parse session (resets on entering a
--                dungeon/trial or home -- toggles in settings -- or via the Reset
--                Meter button / renamed /dpsreset; /dpsresetpos moves the panel).
--                1.0.8 -- Added Sustained DPS (damage / active seconds, idle
--                excluded). Earlier: real-time, fight avg/total/duration display.
-- -----------------------------------------------------------------------------

DM2SimpleDPS = DM2SimpleDPS or {}
local ADDON = DM2SimpleDPS
ADDON.name = "DM2SimpleDPS"

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

-- Sustained DPS: the SESSION is sliced into fixed buckets; a bucket counts as
-- "active" only if a damage tick landed in it. Sustained = session damage divided
-- by active seconds, so all the downtime between pulls (and within a pull) is
-- excluded. Fixed at 1s -- no user-facing knob (yet).
local SUSTAINED_BUCKET_MS = 1000

-- Zone classification for the Sustained session-reset triggers.
local ZONE_OVERLAND = "overland"
local ZONE_DUNGEON  = "dungeon"   -- group dungeons, trials, arenas
local ZONE_HOME     = "home"

-- Bump this when you want the one-time upgrade notice to fire again.
-- AddOnVersion (manifest only) = major*10000 + minor*100 + patch  →  1.0.12 = 10012
-- ESO compares that integer monotonically; never publish a lower AddOnVersion than live.
local VERSION = "1.0.12"

-- Compact 3-column layout: Live | Fight | Session
local PANEL_W = 480
local PANEL_H = 96
local COL_LIVE = 12
local COL_FIGHT = 148
local COL_SESSION = 312
local ROW_SUBTITLE_Y = 4
local ROW1_Y = 22
local ROW2_Y = 44
local ROW3_Y = 66

-- Brand watermark (fixed gold; KPI rows use user text color)
local BRAND_R, BRAND_G, BRAND_B = 1, 0.84, 0

local function PrintToChat(msg)
  if CHAT_ROUTER then
    CHAT_ROUTER:AddSystemMessage(msg)
  elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
    CHAT_SYSTEM:AddMessage(msg)
  else
    d(msg)
  end
end

-- ----------------------------
-- Defaults / SavedVars
-- ----------------------------
ADDON.defaults = {
  x = 10,
  y = 10,
  locked = false,

  textR = 1,
  textG = 1,
  textB = 1,
  textA = 1,

  panelAlpha = 0.55,
  border = true,

  rollingWindowMs = 3000,
  refreshMs = 100,

  -- smaller by default (tweak #1)
  fontSize = 16,

  visible = true,

  -- Sustained session-reset triggers (reset on ENTER only; never on leave)
  resetSustainOnDungeon = true,
  resetSustainOnHome = true,

  -- internal: last zone kind we saw, persisted so a /reloadui inside an instance
  -- doesn't count as a fresh "entry" and wrongly wipe the session
  lastZoneKind = "",

  -- internal: last version we showed the upgrade notice for (one-time per version)
  lastSeenVersion = "",
}

-- Runtime fight state
ADDON.inCombat = false
ADDON.fightStartMs = 0          -- set on first outgoing damage
ADDON.fightEndMs = 0            -- set on combat end (fallback only)
ADDON.fightLastDamageMs = 0     -- NEW: end fight at last outgoing damage for better alignment
ADDON.fightDamage = 0
ADDON.damageEvents = {}

-- Sustained DPS accounting (session-scoped active-second bucketing). Unlike the
-- fight state above, this is NOT cleared on each pull -- only by ResetSession
-- (manual reset or a zone trigger), so it spans a whole dungeon run / parse.
ADDON.sessionStartMs = 0         -- set on first outgoing damage of the session
ADDON.sessionDamage = 0          -- cumulative damage since the session began
ADDON.sessionActiveBuckets = 0   -- count of distinct 1s buckets that had damage
ADDON.sessionLastBucket = -1     -- index of the most recent counted bucket

ADDON.frozenFightTotal = 0
ADDON.frozenFightDurMs = 0

ADDON.frozenCurrentDps = 0
ADDON.frozenFightDps = 0
ADDON.hasFrozen = false
ADDON.lastUiUpdateMs = 0

ADDON.isUpdateRunning = false

-- UI refs
ADDON.ui = {
  win = nil,
  bg = nil,
  brandLabel = nil,
  subtitleLabel = nil,
  rtLabel = nil,
  avgLabel = nil,
  sustLabel = nil,
  totalLabel = nil,
  sessTotalLabel = nil,
  durLabel = nil,
  sessTimeLabel = nil,
}

-- ----------------------------
-- Utility
-- ----------------------------
local function NowMs()
  return GetGameTimeMilliseconds()
end

local function Clamp01(x)
  if x == nil then return 0 end
  if x < 0 then return 0 end
  if x > 1 then return 1 end
  return x
end

local function FormatDps(dps)
  if not dps or dps < 0 then dps = 0 end
  if dps >= 1000000 then
    return string.format("%.2fm", dps / 1000000)
  elseif dps >= 1000 then
    return string.format("%.1fk", dps / 1000)
  else
    return string.format("%.0f", dps)
  end
end

local function FormatInt(n)
  n = tonumber(n) or 0
  n = math.floor(n + 0.5)
  if ZO_CommaDelimitNumber then
    return ZO_CommaDelimitNumber(n)
  end
  local s = tostring(n)
  local sep = ","
  local out = s
  while true do
    out, k = out:gsub("^(%-?%d+)(%d%d%d)", "%1" .. sep .. "%2")
    if k == 0 then break end
  end
  return out
end

local function FormatDurMs(ms)
  ms = tonumber(ms) or 0
  if ms < 0 then ms = 0 end
  local totalSeconds = ms / 1000
  local minutes = math.floor(totalSeconds / 60)
  local seconds = totalSeconds - (minutes * 60)
  return string.format("%d:%04.1f", minutes, seconds)
end

local function GetRollingDamageSum(nowMs, windowMs)
  local q = ADDON.damageEvents
  local cutoff = nowMs - windowMs

  local i = 1
  while q[i] and q[i].t < cutoff do
    i = i + 1
  end

  if i > 1 then
    local newLen = #q - (i - 1)
    for j = 1, newLen do
      q[j] = q[j + (i - 1)]
    end
    for j = newLen + 1, #q do
      q[j] = nil
    end
  end

  local sum = 0
  for _, e in ipairs(q) do
    sum = sum + e.d
  end
  return sum
end

-- ----------------------------
-- Zone classification + session subtitle
-- ----------------------------
local function GetZoneKind()
  if GetCurrentZoneHouseId and GetCurrentZoneHouseId() ~= 0 then
    return ZONE_HOME
  end
  -- MAP_CONTENT_DUNGEON covers group dungeons, trials, and arenas.
  if GetMapContentType and GetMapContentType() == MAP_CONTENT_DUNGEON then
    return ZONE_DUNGEON
  end
  return ZONE_OVERLAND
end

local function GetSessionSubtitlePrefix(kind)
  if kind == ZONE_DUNGEON then
    return "Instance session"
  elseif kind == ZONE_HOME then
    return "Parse session"
  end
  return "Overland session"
end

local function GetSessionSubtitleResetSuffix(kind, vars)
  if kind == ZONE_DUNGEON then
    if vars.resetSustainOnDungeon then
      return "resets when you enter a dungeon/trial"
    end
    return "manual reset only"
  elseif kind == ZONE_HOME then
    if vars.resetSustainOnHome then
      return "resets when you enter your home"
    end
    return "manual reset only"
  end
  local onDungeon = vars.resetSustainOnDungeon
  local onHome = vars.resetSustainOnHome
  if onDungeon and onHome then
    return "resets on dungeon or home entry"
  elseif onDungeon then
    return "resets on dungeon entry"
  elseif onHome then
    return "resets on home entry"
  end
  return "manual reset only (/dpsreset or Settings)"
end

local function GetSessionSubtitle(vars)
  local kind = GetZoneKind()
  return GetSessionSubtitlePrefix(kind) .. " · " .. GetSessionSubtitleResetSuffix(kind, vars)
end

-- ----------------------------
-- Fonts
-- ----------------------------
local function _fontRow(size)
  return string.format("EsoUI/Common/Fonts/univers57.otf|%d|soft-shadow-thin", size)
end

local function CreateDPSFonts(vars)
  if not DM2SimpleDPS_BrandFont then DM2SimpleDPS_BrandFont = CreateFont("DM2SimpleDPS_BrandFont") end
  DM2SimpleDPS_BrandFont:SetFont("EsoUI/Common/Fonts/univers67.otf|14|soft-shadow-thick")

  if not DM2SimpleDPS_SubtitleFont then DM2SimpleDPS_SubtitleFont = CreateFont("DM2SimpleDPS_SubtitleFont") end
  DM2SimpleDPS_SubtitleFont:SetFont("EsoUI/Common/Fonts/univers57.otf|13|soft-shadow-thin")

  if not DM2SimpleDPS_RowFont then DM2SimpleDPS_RowFont = CreateFont("DM2SimpleDPS_RowFont") end
  local size = vars.fontSize or 16
  DM2SimpleDPS_RowFont:SetFont(_fontRow(size))
end

local function ApplyRowFont(ui)
  if not ui then return end
  local font = "DM2SimpleDPS_RowFont"
  if ui.rtLabel then ui.rtLabel:SetFont(font) end
  if ui.avgLabel then ui.avgLabel:SetFont(font) end
  if ui.sustLabel then ui.sustLabel:SetFont(font) end
  if ui.totalLabel then ui.totalLabel:SetFont(font) end
  if ui.sessTotalLabel then ui.sessTotalLabel:SetFont(font) end
  if ui.durLabel then ui.durLabel:SetFont(font) end
  if ui.sessTimeLabel then ui.sessTimeLabel:SetFont(font) end
end

-- ----------------------------
-- Update loop control
-- ----------------------------
function ADDON:StartUpdateLoop()
  if self.isUpdateRunning then return end
  self.isUpdateRunning = true
  EM:RegisterForUpdate(self.name .. "_Update", self.vars.refreshMs, function() self:UpdateUI(false) end)
end

function ADDON:StopUpdateLoop()
  if not self.isUpdateRunning then return end
  self.isUpdateRunning = false
  EM:UnregisterForUpdate(self.name .. "_Update")
end

function ADDON:RefreshUpdateLoopState()
  local shouldRun = (self.vars.visible == true) and (self.inCombat == true)
  if shouldRun then
    self:StartUpdateLoop()
  else
    self:StopUpdateLoop()
  end
end

-- ----------------------------
-- UI
-- ----------------------------
function ADDON:ApplyStyles()
  local vars = self.vars
  local ui = self.ui
  if not ui.win then return end

  ui.win:ClearAnchors()
  ui.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, vars.x, vars.y)

  local a = Clamp01(vars.panelAlpha or 0.55)
  ui.bg:SetCenterColor(0, 0, 0, a)

  if vars.border then
    ui.bg:SetEdgeColor(1, 1, 1, a)
    ui.bg:SetEdgeTexture(nil, 1, 1, 3)
  else
    ui.bg:SetEdgeColor(1, 1, 1, 0)
    ui.bg:SetEdgeTexture(nil, 1, 1, 0)
  end

  local r,g,b,ta = vars.textR, vars.textG, vars.textB, vars.textA
  if ui.subtitleLabel then
    ui.subtitleLabel:SetColor(r * 0.85, g * 0.85, b * 0.85, (ta or 1) * 0.75)
  end
  if ui.brandLabel then
    ui.brandLabel:SetColor(BRAND_R, BRAND_G, BRAND_B, ta or 1)
  end
  ui.rtLabel:SetColor(r,g,b,ta)
  ui.avgLabel:SetColor(r,g,b,ta)
  ui.sustLabel:SetColor(r,g,b,ta)
  ui.totalLabel:SetColor(r,g,b,ta)
  ui.sessTotalLabel:SetColor(r,g,b,ta)
  ui.durLabel:SetColor(r,g,b,ta)
  ui.sessTimeLabel:SetColor(r,g,b,ta)

  self:UpdateSessionSubtitle()

  ui.win:SetMouseEnabled(not vars.locked)
  ui.win:SetMovable(not vars.locked)
  ui.win:SetHidden(not vars.visible)
end

function ADDON:UpdateSessionSubtitle()
  local ui = self.ui
  if not ui.subtitleLabel or not self.vars then return end
  ui.subtitleLabel:SetText(GetSessionSubtitle(self.vars))
end

function ADDON:CreateUI()
  local vars = self.vars
  CreateDPSFonts(vars)

  local win = WM:CreateTopLevelWindow("DM2SimpleDPS_Win")
  win:SetDimensions(PANEL_W, PANEL_H)

  win:SetClampedToScreen(true)
  win:SetMovable(true)
  win:SetMouseEnabled(true)
  win:SetHidden(false)

  win:SetHandler("OnMoveStop", function()
    vars.x = win:GetLeft()
    vars.y = win:GetTop()
  end)

  local back = WM:CreateControl("$(parent)Backdrop", win, CT_BACKDROP)
  back:SetAnchorFill()
  back:SetDrawLayer(DL_OVERLAY)
  back:SetDrawTier(DT_HIGH)
  back:SetDrawLevel(340000)

  local subtitle = WM:CreateControl("$(parent)Subtitle", win, CT_LABEL)
  subtitle:SetFont("DM2SimpleDPS_SubtitleFont")
  subtitle:SetAnchor(TOPLEFT, win, TOPLEFT, COL_LIVE, ROW_SUBTITLE_Y)
  subtitle:SetText("Overland session")
  subtitle:SetDrawLayer(DL_OVERLAY); subtitle:SetDrawTier(DT_HIGH); subtitle:SetDrawLevel(340010)

  -- Row 1: Live | Fight | Session
  local rt = WM:CreateControl("$(parent)RT", win, CT_LABEL)
  rt:SetFont("DM2SimpleDPS_RowFont")
  rt:SetAnchor(TOPLEFT, win, TOPLEFT, COL_LIVE, ROW1_Y)
  rt:SetText("Real-time: 0")
  rt:SetDrawLayer(DL_OVERLAY); rt:SetDrawTier(DT_HIGH); rt:SetDrawLevel(340010)

  local avg = WM:CreateControl("$(parent)Avg", win, CT_LABEL)
  avg:SetFont("DM2SimpleDPS_RowFont")
  avg:SetAnchor(TOPLEFT, win, TOPLEFT, COL_FIGHT, ROW1_Y)
  avg:SetText("Fight Avg: 0")
  avg:SetDrawLayer(DL_OVERLAY); avg:SetDrawTier(DT_HIGH); avg:SetDrawLevel(340010)

  local sust = WM:CreateControl("$(parent)Sust", win, CT_LABEL)
  sust:SetFont("DM2SimpleDPS_RowFont")
  sust:SetAnchor(TOPLEFT, win, TOPLEFT, COL_SESSION, ROW1_Y)
  sust:SetText("Session DPS: 0")
  sust:SetDrawLayer(DL_OVERLAY); sust:SetDrawTier(DT_HIGH); sust:SetDrawLevel(340010)

  -- Row 2: Fight Total | Session Total
  local total = WM:CreateControl("$(parent)Total", win, CT_LABEL)
  total:SetFont("DM2SimpleDPS_RowFont")
  total:SetAnchor(TOPLEFT, win, TOPLEFT, COL_FIGHT, ROW2_Y)
  total:SetText("Fight Total: 0")
  total:SetDrawLayer(DL_OVERLAY); total:SetDrawTier(DT_HIGH); total:SetDrawLevel(340010)

  local sessTotal = WM:CreateControl("$(parent)SessTotal", win, CT_LABEL)
  sessTotal:SetFont("DM2SimpleDPS_RowFont")
  sessTotal:SetAnchor(TOPLEFT, win, TOPLEFT, COL_SESSION, ROW2_Y)
  sessTotal:SetText("Session Total: 0")
  sessTotal:SetDrawLayer(DL_OVERLAY); sessTotal:SetDrawTier(DT_HIGH); sessTotal:SetDrawLevel(340010)

  -- Row 3: Brand | Duration | Total DPS Time
  local brand = WM:CreateControl("$(parent)Brand", win, CT_LABEL)
  brand:SetFont("DM2SimpleDPS_BrandFont")
  brand:SetAnchor(TOPLEFT, win, TOPLEFT, COL_LIVE, ROW3_Y)
  brand:SetText("(DM2 Simple DPS)")
  brand:SetDrawLayer(DL_OVERLAY); brand:SetDrawTier(DT_HIGH); brand:SetDrawLevel(340010)

  local dur = WM:CreateControl("$(parent)Dur", win, CT_LABEL)
  dur:SetFont("DM2SimpleDPS_RowFont")
  dur:SetAnchor(TOPLEFT, win, TOPLEFT, COL_FIGHT, ROW3_Y)
  dur:SetText("Duration: 0:00.0")
  dur:SetDrawLayer(DL_OVERLAY); dur:SetDrawTier(DT_HIGH); dur:SetDrawLevel(340010)

  local sessTime = WM:CreateControl("$(parent)SessTime", win, CT_LABEL)
  sessTime:SetFont("DM2SimpleDPS_RowFont")
  sessTime:SetAnchor(TOPLEFT, win, TOPLEFT, COL_SESSION, ROW3_Y)
  sessTime:SetText("Total DPS Time: 0:00.0")
  sessTime:SetDrawLayer(DL_OVERLAY); sessTime:SetDrawTier(DT_HIGH); sessTime:SetDrawLevel(340010)

  self.ui.win = win
  self.ui.bg = back
  self.ui.brandLabel = brand
  self.ui.subtitleLabel = subtitle
  self.ui.rtLabel = rt
  self.ui.avgLabel = avg
  self.ui.sustLabel = sust
  self.ui.totalLabel = total
  self.ui.sessTotalLabel = sessTotal
  self.ui.durLabel = dur
  self.ui.sessTimeLabel = sessTime

  self:ApplyStyles()
end

function ADDON:FreezeAtCombatEnd()
  -- Only freeze if we actually started a fight
  if not self.fightStartMs or self.fightStartMs <= 0 then
    return
  end

  -- Prefer ending the fight at last outgoing damage for better alignment with parse recaps
  local endMs =
    (self.fightLastDamageMs and self.fightLastDamageMs > 0 and self.fightLastDamageMs)
    or (self.fightEndMs > 0 and self.fightEndMs)
    or NowMs()

  local durMs = math.max(1, endMs - self.fightStartMs)
  self.frozenFightDps = (self.fightDamage * 1000) / durMs
  self.frozenFightTotal = self.fightDamage
  self.frozenFightDurMs = durMs

  local windowMs = math.max(250, self.vars.rollingWindowMs or 3000)
  local rollingSum = GetRollingDamageSum(endMs, windowMs)
  self.frozenCurrentDps = (rollingSum * 1000) / windowMs

  -- Sustained is session-scoped and read live from the accumulator, so there is
  -- nothing to freeze here -- it simply stops moving once damage stops.
  self.hasFrozen = true
end

function ADDON:UpdateSessionMetrics()
  local sessionDps = 0
  local sessionTimeMs = 0
  if self.sessionActiveBuckets > 0 then
    sessionTimeMs = self.sessionActiveBuckets * SUSTAINED_BUCKET_MS
    sessionDps = (self.sessionDamage * 1000) / sessionTimeMs
  end
  self.ui.sustLabel:SetText("Session DPS: " .. FormatDps(sessionDps))
  self.ui.sessTotalLabel:SetText("Session Total: " .. FormatInt(self.sessionDamage))
  self.ui.sessTimeLabel:SetText("Total DPS Time: " .. FormatDurMs(sessionTimeMs))
end

function ADDON:UpdateUI(force)
  if not self.vars.visible then return end

  local now = NowMs()
  local vars = self.vars

  if not force then
    if (now - (self.lastUiUpdateMs or 0)) < (vars.refreshMs or 100) then
      return
    end
  end
  self.lastUiUpdateMs = now

  -- Session column is always live (spans pulls; not frozen at combat end).
  self:UpdateSessionMetrics()

  if (not self.inCombat) and self.hasFrozen then
    self.ui.rtLabel:SetText("Real-time: " .. FormatDps(self.frozenCurrentDps))
    self.ui.avgLabel:SetText("Fight Avg: " .. FormatDps(self.frozenFightDps))
    self.ui.totalLabel:SetText("Fight Total: " .. FormatInt(self.frozenFightTotal))
    self.ui.durLabel:SetText("Duration: " .. FormatDurMs(self.frozenFightDurMs))
    return
  end

  -- If we haven't started the fight yet, don't show ramp numbers
  if not self.fightStartMs or self.fightStartMs <= 0 then
    self.ui.rtLabel:SetText("Real-time: 0")
    self.ui.avgLabel:SetText("Fight Avg: 0")
    self.ui.totalLabel:SetText("Fight Total: 0")
    self.ui.durLabel:SetText("Duration: 0:00.0")
    return
  end

  local durMs = math.max(1, now - self.fightStartMs)
  local fightDps = (self.fightDamage * 1000) / durMs

  local windowMs = math.max(250, vars.rollingWindowMs or 3000)
  local rollingSum = GetRollingDamageSum(now, windowMs)
  local currentDps = (rollingSum * 1000) / windowMs

  self.ui.rtLabel:SetText("Real-time: " .. FormatDps(currentDps))
  self.ui.avgLabel:SetText("Fight Avg: " .. FormatDps(fightDps))
  self.ui.totalLabel:SetText("Fight Total: " .. FormatInt(self.fightDamage))
  self.ui.durLabel:SetText("Duration: " .. FormatDurMs(durMs))
end

-- ----------------------------
-- Combat tracking
-- ----------------------------
function ADDON:ResetFight()
  -- Arm fight, but don't set start time until first outgoing damage.
  -- NOTE: this does NOT touch session state -- Sustained spans pulls.
  self.fightStartMs = 0
  self.fightEndMs = 0
  self.fightLastDamageMs = 0
  self.fightDamage = 0
  self.damageEvents = {}

  self.frozenCurrentDps = 0
  self.frozenFightDps = 0
  self.frozenFightTotal = 0
  self.frozenFightDurMs = 0
  self.hasFrozen = false
end

function ADDON:ResetSession()
  -- Clears only the Sustained (session) accumulator. Called by a manual reset and
  -- by the zone-entry triggers; leaves the per-fight numbers alone.
  self.sessionStartMs = 0
  self.sessionDamage = 0
  self.sessionActiveBuckets = 0
  self.sessionLastBucket = -1
  if self.vars.visible then self:UpdateUI(true) end
end

function ADDON:ResetMeter()
  -- Full manual clear: current pull AND the session. Repaints immediately so the
  -- panel zeroes out even when we're sitting idle out of combat.
  self:ResetFight()
  self:ResetSession()
  if self.vars.visible then self:UpdateUI(true) end
end

function ADDON:OnCombatState(_, inCombat)
  self.inCombat = inCombat

  if inCombat then
    self:ResetFight()
  else
    self.fightEndMs = NowMs() -- fallback only; freeze prefers last outgoing damage
    self:FreezeAtCombatEnd()
    self:UpdateUI(true)
  end

  self:RefreshUpdateLoopState()
end

local DAMAGE_RESULTS = {
  [ACTION_RESULT_DAMAGE] = true,
  [ACTION_RESULT_CRITICAL_DAMAGE] = true,
  [ACTION_RESULT_DOT_TICK] = true,
  [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
}

function ADDON:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
                            sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType,
                            log, sourceUnitId, targetUnitId, abilityId, overflow)
  if not self.inCombat then return end
  -- NOTE: We intentionally do NOT gate damage collection on panel visibility,
  -- so /dm2dpsoff stops UI polling but doesn't break fight accounting.
  if not DAMAGE_RESULTS[result] then return end
  if not hitValue or hitValue <= 0 then return end

  local now = NowMs()

  -- Start fight clock on first real outgoing damage
  if not self.fightStartMs or self.fightStartMs <= 0 then
    self.fightStartMs = now
  end

  -- Start the session clock on the first damage since the last session reset.
  if not self.sessionStartMs or self.sessionStartMs <= 0 then
    self.sessionStartMs = now
  end

  -- Sustained DPS: credit the 1s session bucket this hit falls in, once. Events
  -- arrive in time order, so the bucket index is non-decreasing -- comparing to
  -- the last one counted tallies distinct active buckets in O(1), no storage.
  -- Buckets with no damage (downtime between pulls) are simply never counted.
  local bucket = math.floor((now - self.sessionStartMs) / SUSTAINED_BUCKET_MS)
  if bucket ~= self.sessionLastBucket then
    self.sessionActiveBuckets = self.sessionActiveBuckets + 1
    self.sessionLastBucket = bucket
  end
  self.sessionDamage = self.sessionDamage + hitValue

  self.fightLastDamageMs = now
  self.fightDamage = self.fightDamage + hitValue
  self.damageEvents[#self.damageEvents + 1] = { t = now, d = hitValue }
end

-- ----------------------------
-- Zone-based session resets
-- ----------------------------
-- One-time-per-version chat notice. Fired from OnPlayerActivated (not addon-load)
-- so the chat window actually exists to receive it.
function ADDON:MaybeShowVersionNotice()
  if self.vars.lastSeenVersion == VERSION then return end
  self.vars.lastSeenVersion = VERSION

  local g, r = "|cFFD700", "|r"  -- gold highlight / reset
  PrintToChat(g .. "DM2 Simple DPS v" .. VERSION .. r .. " -- Fight and Session columns shifted left so " ..
    g .. "9-figure comma totals" .. r .. " fit without clipping.")
end

-- Fires on every zone load (and login/reloadui). We reset the Sustained session
-- only on a *transition into* a dungeon or home, per the user's toggles. Comparing
-- against the persisted lastZoneKind means a /reloadui inside an instance is a
-- no-op (same kind), and zoning OUT never clears anything.
function ADDON:OnPlayerActivated()
  self:MaybeShowVersionNotice()

  local kind = GetZoneKind()
  local prev = self.vars.lastZoneKind

  if kind ~= prev then
    if kind == ZONE_DUNGEON and self.vars.resetSustainOnDungeon then
      self:ResetSession()
    elseif kind == ZONE_HOME and self.vars.resetSustainOnHome then
      self:ResetSession()
    end
    self.vars.lastZoneKind = kind
  end

  self:UpdateSessionSubtitle()
end

-- ----------------------------
-- Visibility / Position helpers
-- ----------------------------
function ADDON:SetVisible(v)
  self.vars.visible = (v == true)
  self:ApplyStyles()
  if self.vars.visible then
    self:UpdateUI(true)
  end
  self:RefreshUpdateLoopState()
end

function ADDON:SetPosition(x, y)
  x = tonumber(x)
  y = tonumber(y)
  if not x or not y then return false end
  self.vars.x = math.floor(x)
  self.vars.y = math.floor(y)
  self:ApplyStyles()
  return true
end

function ADDON:ResetPosition()
  self.vars.x = self.defaults.x
  self.vars.y = self.defaults.y
  self:ApplyStyles()
end

function ADDON:ToggleLock()
  self.vars.locked = not self.vars.locked
  self:ApplyStyles()
end

-- ----------------------------
-- Slash Commands
-- ----------------------------
function ADDON:RegisterSlashCommands()
  SLASH_COMMANDS["/dpslock"] = function() self:ToggleLock() end
  -- /dpsreset now clears the meter (was: reset position -- see /dpsresetpos)
  SLASH_COMMANDS["/dpsreset"] = function() self:ResetMeter() end
  SLASH_COMMANDS["/dpsresetpos"] = function() self:ResetPosition() end

  SLASH_COMMANDS["/dpsposition"] = function(arg)
    if not arg or arg == "" then return end
    local a = arg:gsub(",", " ")
    local x, y = a:match("^%s*([%-%.%d]+)%s+([%-%.%d]+)%s*$")
    self:SetPosition(x, y)
  end

  SLASH_COMMANDS["/dm2dpson"] = function() self:SetVisible(true) end
  SLASH_COMMANDS["/dm2dpsoff"] = function() self:SetVisible(false) end
end

-- ----------------------------
-- Settings (LAM optional)
-- ----------------------------
function ADDON:TryRegisterLAM()
  local LAM = LibAddonMenu2 or LibAddonMenu
  if not LAM then return end

  local panelData = {
    type = "panel",
    name = "DM2 Simple DPS",
    displayName = "DM2 Simple DPS",
    author = "DM2-inspired",
    version = VERSION,
    registerForRefresh = true,
    registerForDefaults = true,
  }

  local options = {
    {
      type = "checkbox",
      name = "Visible",
      getFunc = function() return self.vars.visible end,
      setFunc = function(v) self:SetVisible(v) end,
      default = self.defaults.visible,
    },
    {
      type = "button",
      name = "Reset Meter",
      tooltip = "Clear the current fight AND the session metrics now.",
      func = function() self:ResetMeter() end,
      width = "half",
    },
    {
      type = "header",
      name = "Session Metrics",
    },
    {
      type = "description",
      text = "Session DPS, Session Total, and Total DPS Time span the whole session (e.g. a full dungeon run). Only seconds with damage count toward Session DPS and Total DPS Time. The panel subtitle shows your session type and reset rules. Session resets on the triggers below or via Reset Meter -- never when you leave.",
    },
    {
      type = "checkbox",
      name = "Reset session on entering a dungeon/trial",
      getFunc = function() return self.vars.resetSustainOnDungeon end,
      setFunc = function(v) self.vars.resetSustainOnDungeon = v; self:UpdateSessionSubtitle() end,
      default = self.defaults.resetSustainOnDungeon,
    },
    {
      type = "checkbox",
      name = "Reset session on entering a home",
      tooltip = "Handy for parsing -- walking into your house starts a fresh session.",
      getFunc = function() return self.vars.resetSustainOnHome end,
      setFunc = function(v) self.vars.resetSustainOnHome = v; self:UpdateSessionSubtitle() end,
      default = self.defaults.resetSustainOnHome,
    },
    {
      type = "header",
      name = "Panel",
    },
    {
      type = "checkbox",
      name = "Lock Panel",
      getFunc = function() return self.vars.locked end,
      setFunc = function(v) self.vars.locked = v; self:ApplyStyles() end,
      default = self.defaults.locked,
      width = "half",
    },
    {
      type = "button",
      name = "Reset Position",
      func = function() self:ResetPosition() end,
      width = "half",
    },
    {
      type = "slider",
      name = "X Position",
      min = 0, max = 4000, step = 5,
      getFunc = function() return self.vars.x end,
      setFunc = function(v) self.vars.x = v; self:ApplyStyles() end,
      default = self.defaults.x,
      width = "half",
    },
    {
      type = "slider",
      name = "Y Position",
      min = 0, max = 2500, step = 5,
      getFunc = function() return self.vars.y end,
      setFunc = function(v) self.vars.y = v; self:ApplyStyles() end,
      default = self.defaults.y,
      width = "half",
    },
    {
      type = "slider",
      name = "Panel Opacity",
      min = 0, max = 1, step = 0.05,
      getFunc = function() return self.vars.panelAlpha end,
      setFunc = function(v) self.vars.panelAlpha = v; self:ApplyStyles() end,
      default = self.defaults.panelAlpha,
    },
    {
      type = "checkbox",
      name = "Show Border",
      getFunc = function() return self.vars.border end,
      setFunc = function(v) self.vars.border = v; self:ApplyStyles() end,
      default = self.defaults.border,
    },
    {
      type = "colorpicker",
      name = "Text Color",
      getFunc = function()
        local v = self.vars
        return v.textR, v.textG, v.textB, v.textA
      end,
      setFunc = function(r,g,b,a)
        local v = self.vars
        v.textR, v.textG, v.textB, v.textA = r,g,b,a
        self:ApplyStyles()
      end,
      default = { self.defaults.textR, self.defaults.textG, self.defaults.textB, self.defaults.textA },
    },
    {
      type = "slider",
      name = "Font Size",
      min = 14, max = 26, step = 1,
      getFunc = function() return self.vars.fontSize end,
      setFunc = function(v)
        self.vars.fontSize = v
        CreateDPSFonts(self.vars)
        ApplyRowFont(self.ui)
      end,
      default = self.defaults.fontSize,
    },
    {
      type = "slider",
      name = "Rolling Window (Current DPS)",
      min = 500, max = 8000, step = 250,
      getFunc = function() return self.vars.rollingWindowMs end,
      setFunc = function(v) self.vars.rollingWindowMs = v end,
      default = self.defaults.rollingWindowMs,
    },
    {
      type = "slider",
      name = "Refresh Rate (ms)",
      min = 50, max = 500, step = 25,
      getFunc = function() return self.vars.refreshMs end,
      setFunc = function(v)
        self.vars.refreshMs = v
        if self.isUpdateRunning then
          self:StopUpdateLoop()
          self:StartUpdateLoop()
        end
      end,
      default = self.defaults.refreshMs,
    },
  }

  LAM:RegisterAddonPanel(self.name .. "_Panel", panelData)
  LAM:RegisterOptionControls(self.name .. "_Panel", options)
end

-- ----------------------------
-- Init
-- ----------------------------
function ADDON:Initialize()
  self.vars = ZO_SavedVars:NewAccountWide("DM2SimpleDPSVars", 1, nil, self.defaults)

  self:CreateUI()
  self:RegisterSlashCommands()
  self:TryRegisterLAM()

  EM:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, function(...) self:OnCombatState(...) end)

  -- Count damage from BOTH the player and the player's pets/summons (familiar,
  -- atronach, bear, etc.) -- ESO's official parse credits pet damage to you, and
  -- omitting it makes our totals read a few % low. The per-event source filter
  -- only accepts one unit type, so we subscribe once per type (distinct names)
  -- into the same handler. Unit types are from the local player's perspective, so
  -- PLAYER_PET is YOUR pets only, not groupmates'.
  local sourceTypes = { COMBAT_UNIT_TYPE_PLAYER, COMBAT_UNIT_TYPE_PLAYER_PET }
  for i = 1, #sourceTypes do
    local regName = self.name .. "_Combat" .. i
    EM:RegisterForEvent(regName, EVENT_COMBAT_EVENT, function(...) self:OnCombatEvent(...) end)
    EM:AddFilterForEvent(regName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, sourceTypes[i])
  end

  -- Zone changes drive the Sustained session-reset triggers
  EM:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...) self:OnPlayerActivated(...) end)

  self:ApplyStyles()
  self:UpdateUI(true)
  self:RefreshUpdateLoopState()
end

local function OnAddOnLoaded(_, addonName)
  if addonName ~= ADDON.name then return end
  EM:UnregisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED)
  ADDON:Initialize()
end

EM:RegisterForEvent(ADDON.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
