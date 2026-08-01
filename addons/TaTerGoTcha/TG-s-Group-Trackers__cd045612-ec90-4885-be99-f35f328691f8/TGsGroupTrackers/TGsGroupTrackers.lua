-- TGsGroupTrackers v0.6.0
-- Per-client timing; broadcast DPS/tHPS/eHPS only; freeze until next encounter.
-- UI: ON by default in HUD; Preview toggle for menus; default bottom-left clamped; X/Y sliders step=5.
-- Heals: tHPS/eHPS logic preserved incl. shield->eHPS.

TGsGroupTrackers = TGsGroupTrackers or {}
local Addon = TGsGroupTrackers
Addon.name    = "TGsGroupTrackers"
Addon.version = "0.6.0"

------------------------------------------------------------
-- Defaults & SavedVars
------------------------------------------------------------
local defaults = {
  posX = nil,  -- set to bottom-left on first run
  posY = nil,
  width = 560,
  scale = 0.90,
  fontSize = 24,
  opacity = 1.0,
  isShown = true,
  showWhenSolo = true,
  sortBy = "DPS",               -- DPS | tHPS | eHPS
  previewWhileAdjusting = false,
}
Addon.saved = {}

------------------------------------------------------------
-- Utils
------------------------------------------------------------
local function Clamp(n, lo, hi)
  if n < lo then return lo elseif n > hi then return hi else return n end
end
local function nowMs() return GetGameTimeMilliseconds() end
local function formatInt(n)
  n = zo_floor(tonumber(n) or 0)
  local s, k = tostring(n), nil
  repeat s,k = s:gsub("^(-?%d+)(%d%d%d)","%1,%2") until k==0
  return s
end
local function GetMyDisplayKey()
  local disp = GetUnitDisplayName("player")
  local char = GetUnitName("player")
  if disp and disp ~= "" then return zo_strformat("<<1>>", disp) end
  if char and char ~= "" then return zo_strformat("<<1>>", char) end
  return nil
end
local function IsHudShown()
  local SM = SCENE_MANAGER
  if not SM then return true end
  return SM:IsShowing("hud") or SM:IsShowing("hudui") or Addon.saved.previewWhileAdjusting
end
local function norm(s) return zo_strlower(zo_strformat("<<1>>", s or "")) end

------------------------------------------------------------
-- UI state
------------------------------------------------------------
local rowCtrls = {}
local labelsName, labelsDps, labelsTHps, labelsEHps = {}, {}, {}, {}
Addon.headerLabel, Addon.headerDpsLabel, Addon.headerTHpsLabel, Addon.headerEHpsLabel = nil,nil,nil,nil

local MAX_GROUP_SIZE=12
local GAP, PADDING, COL_GAP, RIGHT_PAD = 2, 8, 8, 12
local MIN_W, MAX_W = 320, 1200
local MIN_S, MAX_S = 0.70, 1.80
local MIN_FS, MAX_FS = 14, 48
local MIN_OP, MAX_OP = 0.20, 1.00

local function fontDesc(sz,bold) return string.format("%s|%d|soft-shadow-thin", bold and "$(BOLD_FONT)" or "$(MEDIUM_FONT)", zo_round(sz)) end
local function headerFontSize() return Clamp(zo_round((Addon.saved.fontSize or defaults.fontSize) - 2), 14, 48) end
local function headerHeightPx() return headerFontSize() + 8 end
local function lineHeight() return zo_round((Addon.saved.fontSize or defaults.fontSize) + 6) end

function Addon.OnWindowMoveStop()
  if not TGsGroupTrackers_Window then return end
  Addon.saved.posX = zo_round(TGsGroupTrackers_Window:GetLeft())
  Addon.saved.posY = zo_round(TGsGroupTrackers_Window:GetTop())
end

local function EnsureWindow()
  if TGsGroupTrackers_Window then return end
  local win = WINDOW_MANAGER:CreateTopLevelWindow("TGsGroupTrackers_Window")
  win:SetMovable(true); win:SetMouseEnabled(true); win:SetClampedToScreen(true)
  win:SetDimensions(Addon.saved.width or 560, 360)
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 40, 40)
  local cont = WINDOW_MANAGER:CreateControl("TGsGroupTrackers_WindowContainer", win, CT_CONTROL)
  cont:SetResizeToFitDescendents(true)
  cont:SetAnchor(TOPLEFT,  win, TOPLEFT,  8, 48)
  cont:SetAnchor(TOPRIGHT, win, TOPRIGHT, -12, 48)
  win:SetHandler("OnMoveStop", function() Addon.OnWindowMoveStop() end)
end

function Addon._ApplySavedAnchor()
  if not TGsGroupTrackers_Window then return end
  local uiW, uiH = GuiRoot:GetDimensions()
  local w, h  = TGsGroupTrackers_Window:GetDimensions()
  if w<=0 or h<=0 then w=560; h=360 end
  local x = tonumber(Addon.saved.posX)
  local y = tonumber(Addon.saved.posY)
  if not x or not y then
    -- default bottom-left (clamped so bottom never overflows)
    x = 40
    y = math.max(0, uiH - h - 40)
  else
    x = Clamp(zo_round(x), 0, math.max(0, uiW - w))
    y = Clamp(zo_round(y), 0, math.max(0, uiH - h))
  end
  Addon.saved.posX, Addon.saved.posY = x, y
  TGsGroupTrackers_Window:ClearAnchors()
  TGsGroupTrackers_Window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function _EnsureHeader()
  if not Addon.headerLabel then
    local h = WINDOW_MANAGER:CreateControl(TGsGroupTrackers_Window:GetName().."Hdr", TGsGroupTrackers_Window, CT_LABEL)
    h:SetHorizontalAlignment(TEXT_ALIGN_LEFT); h:SetVerticalAlignment(TEXT_ALIGN_TOP)
    h:SetAnchor(TOPLEFT,  TGsGroupTrackers_Window, TOPLEFT,  PADDING, PADDING)
    h:SetAnchor(TOPRIGHT, TGsGroupTrackers_Window, TOPRIGHT, -PADDING, PADDING)
    Addon.headerLabel = h
  end
  Addon.headerLabel:SetFont(fontDesc(headerFontSize(), true))

  local function ensureOne(refName, suffix, text)
    if not Addon[refName] then
      local r = WINDOW_MANAGER:CreateControl(TGsGroupTrackers_Window:GetName()..suffix, TGsGroupTrackers_Window, CT_LABEL)
      r:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); r:SetVerticalAlignment(TEXT_ALIGN_TOP)
      Addon[refName] = r
    end
    Addon[refName]:SetFont(fontDesc(headerFontSize(), true))
    Addon[refName]:SetText(text)
  end
  ensureOne("headerDpsLabel",  "HdrDps",  "DPS")
  ensureOne("headerTHpsLabel", "HdrTHps", "tHPS")
  ensureOne("headerEHpsLabel", "HdrEHps", "eHPS")
end

local function _EnsureRows()
  for i=1,MAX_GROUP_SIZE do
    if not rowCtrls[i] then
      local row = WINDOW_MANAGER:CreateControl(TGsGroupTrackers_WindowContainer:GetName().."Row"..i, TGsGroupTrackers_WindowContainer, CT_CONTROL)
      rowCtrls[i] = row
      local n = WINDOW_MANAGER:CreateControl(row:GetName().."Name", row, CT_LABEL)
      n:SetHorizontalAlignment(TEXT_ALIGN_LEFT);  n:SetVerticalAlignment(TEXT_ALIGN_TOP)
      labelsName[i]=n
      local d = WINDOW_MANAGER:CreateControl(row:GetName().."Dps", row, CT_LABEL)
      d:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); d:SetVerticalAlignment(TEXT_ALIGN_TOP)
      labelsDps[i]=d
      local t = WINDOW_MANAGER:CreateControl(row:GetName().."THps", row, CT_LABEL)
      t:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); t:SetVerticalAlignment(TEXT_ALIGN_TOP)
      labelsTHps[i]=t
      local e = WINDOW_MANAGER:CreateControl(row:GetName().."EHps", row, CT_LABEL)
      e:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); e:SetVerticalAlignment(TEXT_ALIGN_TOP)
      labelsEHps[i]=e
    end
  end
end

local function _ApplyFonts()
  local fs = Clamp(zo_round(Addon.saved.fontSize or defaults.fontSize), MIN_FS, MAX_FS)
  Addon.saved.fontSize = fs
  for i=1,MAX_GROUP_SIZE do
    if labelsName[i] then labelsName[i]:SetFont(fontDesc(fs,false)) end
    if labelsDps[i]  then labelsDps[i] :SetFont(fontDesc(fs,true))  end
    if labelsTHps[i] then labelsTHps[i]:SetFont(fontDesc(fs,true)) end
    if labelsEHps[i] then labelsEHps[i]:SetFont(fontDesc(fs,true)) end
  end
end

local function _ApplyOpacity()
  TGsGroupTrackers_Window:SetAlpha(Clamp(Addon.saved.opacity or defaults.opacity, MIN_OP, MAX_OP))
end

local function _ApplyLayout()
  local headerH = headerHeightPx()
  local w = Clamp(zo_round(tonumber(Addon.saved.width) or defaults.width), MIN_W, MAX_W)
  local s = Clamp(tonumber(Addon.saved.scale) or defaults.scale, MIN_S, MAX_S)
  TGsGroupTrackers_Window:SetScale(s)

  local fs  = Addon.saved.fontSize or defaults.fontSize
  local charPx = fs * 0.62
  local numMin  = zo_round(charPx * 9)
  local NAME_MIN = zo_round(math.max(160, fs * 8.5))
  local cwMin = NAME_MIN + (numMin*3) + (COL_GAP*3)
  local wRequired = cwMin + (PADDING * 2) + RIGHT_PAD
  if w < wRequired then w = Clamp(wRequired, MIN_W, MAX_W) end
  Addon.saved.width = w

  local cw = w - (PADDING * 2) - RIGHT_PAD
  local nameW = zo_round(math.max(NAME_MIN, cw * 0.46))
  local spaceLeft = cw - nameW - (COL_GAP*3)
  local eachNumW = zo_round(math.max(numMin, spaceLeft / 3))
  local x1 = nameW + COL_GAP
  local x2 = nameW + COL_GAP + eachNumW + COL_GAP
  local x3 = nameW + COL_GAP + eachNumW + COL_GAP + eachNumW + COL_GAP

  local function place(lbl, x)
    lbl:ClearAnchors()
    lbl:SetAnchor(TOPLEFT, TGsGroupTrackers_Window, TOPLEFT, PADDING + x, PADDING)
    lbl:SetDimensions(eachNumW, headerH)
  end
  place(Addon.headerDpsLabel,  x1)
  place(Addon.headerTHpsLabel, x2)
  place(Addon.headerEHpsLabel, x3)

  TGsGroupTrackers_WindowContainer:ClearAnchors()
  TGsGroupTrackers_WindowContainer:SetAnchor(TOPLEFT,  TGsGroupTrackers_Window, TOPLEFT,  PADDING, PADDING + headerH + GAP)
  TGsGroupTrackers_WindowContainer:SetAnchor(TOPRIGHT, TGsGroupTrackers_Window, TOPRIGHT, -RIGHT_PAD, PADDING + headerH + GAP)

  local lh = lineHeight()
  for i=1,MAX_GROUP_SIZE do
    local row=rowCtrls[i]
    row:ClearAnchors()
    if i==1 then
      row:SetAnchor(TOPLEFT,  TGsGroupTrackers_WindowContainer, TOPLEFT,  0, 0)
      row:SetAnchor(TOPRIGHT, TGsGroupTrackers_WindowContainer, TOPRIGHT, 0, 0)
    else
      row:SetAnchor(TOPLEFT,  rowCtrls[i-1], BOTTOMLEFT,  0, GAP)
      row:SetAnchor(TOPRIGHT, rowCtrls[i-1], BOTTOMRIGHT, 0, GAP)
    end
    row:SetDimensions(cw, lh)
    local x = 0
    local n = labelsName[i]; if n then n:ClearAnchors(); n:SetDimensions(nameW, lh); n:SetAnchor(LEFT, row, LEFT, x, 0); end; x = x + nameW + COL_GAP
    local d = labelsDps[i];  if d then d:ClearAnchors(); d:SetDimensions(eachNumW,  lh); d:SetAnchor(LEFT, row, LEFT, x, 0); end; x = x + eachNumW + COL_GAP
    local t = labelsTHps[i]; if t then t:ClearAnchors(); t:SetDimensions(eachNumW,  lh); t:SetAnchor(LEFT, row, LEFT, x, 0); end; x = x + eachNumW + COL_GAP
    local e = labelsEHps[i]; if e then e:ClearAnchors(); e:SetDimensions(eachNumW,  lh); e:SetAnchor(LEFT, row, LEFT, x, 0); end
  end

  TGsGroupTrackers_Window:SetDimensions(w, headerH + GAP + (PADDING + (lh+GAP)*MAX_GROUP_SIZE - GAP + PADDING))
  Addon._ApplySavedAnchor()
end

------------------------------------------------------------
-- Encounter / Totals
------------------------------------------------------------
local encounterActive=false
local firstHitMs, lastHitMs, myFinalDurationMs=nil,nil,nil
Addon.playerInCombat=false
local dmgTotals, healTotTotal, healTotEff = {}, {}, {}
local activeTargets = {} -- unitId -> { lastHitMs, dead }

local IDLE_END_MS = 1500
local GRACE_MS    = 600

-- Final snapshot & debounce (A + C)
Addon._finalSnap = nil
Addon._finalizedAt = nil
Addon._noRecalcUntil = nil

local SHIELD_ABILITY_IDS = { [38565]=true,[28306]=true,[29489]=true,[20492]=true,[29482]=true,[22234]=true }
local myActiveShields = {} -- unitTag -> abilityId -> { endAt }

local CUT_PLAYER     = rawget(_G,"COMBAT_UNIT_TYPE_PLAYER") or 1
local CUT_PLAYER_PET = rawget(_G,"COMBAT_UNIT_TYPE_PLAYER_PET") or 2

local function isMySource(sourceName, sourceType)
  if sourceType==CUT_PLAYER or sourceType==CUT_PLAYER_PET then return true end
  local meDisp=zo_strformat("<<1>>", GetUnitDisplayName("player") or "")
  local meChar=zo_strformat("<<1>>", GetUnitName("player") or "")
  local key=zo_strformat("<<1>>", sourceName or "")
  return key==meDisp or key==meChar
end

local function unitTagForDisplay(displayName)
  local size=GetGroupSize()
  for i=1,size do
    local tag=GetGroupUnitTagByIndex(i)
    if tag then
      local disp=norm(GetUnitDisplayName(tag)); local char=norm(GetUnitName(tag))
      if displayName==disp or displayName==char then return tag end
    end
  end
end

local function isGroupTarget(targetName, targetType)
  if targetType==COMBAT_UNIT_TYPE_PLAYER or targetType==COMBAT_UNIT_TYPE_PLAYER_PET then return true end
  local size=GetGroupSize()
  local tNorm = norm(targetName)
  for i=1,size do
    local tag=GetGroupUnitTagByIndex(i)
    if tag then
      local disp=norm(GetUnitDisplayName(tag)); local char=norm(GetUnitName(tag))
      if tNorm==disp or tNorm==char then return true end
    end
  end
  return false
end

local DAMAGE_RESULTS = {
  [ACTION_RESULT_DAMAGE]=true,
  [ACTION_RESULT_BLOCKED_DAMAGE]=true,
  [ACTION_RESULT_PRECISE_DAMAGE]=true,
  [ACTION_RESULT_WRECKING_DAMAGE]=true,
  [ACTION_RESULT_CRITICAL_DAMAGE]=true,
  [ACTION_RESULT_DOT_TICK]=true,
  [ACTION_RESULT_DOT_TICK_CRITICAL]=true,
}
local KILL_RESULTS = {
  [ACTION_RESULT_DIED]=true,
  [ACTION_RESULT_DIED_XP]=true,
  [ACTION_RESULT_KILLING_BLOW]=true,
}
local function isHealResult(result)
  return result==ACTION_RESULT_HEAL
      or result==ACTION_RESULT_HEAL_CRITICAL
      or result==ACTION_RESULT_HOT_TICK
      or result==ACTION_RESULT_HOT_TICK_CRITICAL
end

local function markShieldGained(unitTag, abilityId, endTimeMs)
  if not unitTag then return end
  myActiveShields[unitTag] = myActiveShields[unitTag] or {}
  myActiveShields[unitTag][abilityId or 0] = { endAt = endTimeMs or (nowMs()+6000) }
end
local function hasMyActiveShield(unitTag)
  local t = myActiveShields[unitTag]; if not t then return false end
  local tnow = nowMs()
  for _, data in pairs(t) do if data and (not data.endAt or data.endAt>tnow) then return true end end
  return false
end
local function CullExpiredShields()
  local tnow=nowMs()
  for unitTag, tbl in pairs(myActiveShields) do
    for k,v in pairs(tbl) do if v and v.endAt and v.endAt <= tnow then tbl[k]=nil end end
    if next(tbl)==nil then myActiveShields[unitTag]=nil end
  end
end

local function looksLikeDummy(name)
  name = zo_strlower(tostring(name or "")); return name:find("target") and (name:find("skeleton") or name:find("dummy"))
end

local function startEncounterAt(ms)
  encounterActive=true
  firstHitMs = ms; lastHitMs  = ms; myFinalDurationMs=nil
  dmgTotals, healTotTotal, healTotEff = {}, {}, {}
  activeTargets = {}
  -- clear remote snapshot so nothing carries over
  lgbRx = {}
  -- clear final snapshot/debounce
  Addon._finalSnap, Addon._finalizedAt, Addon._noRecalcUntil = nil,nil,nil
end

local function finalizeEncounter(endAtMs)
if not encounterActive or not firstHitMs then return end
  endAtMs = endAtMs or lastHitMs or nowMs()
  if endAtMs < firstHitMs then endAtMs = firstHitMs end
  myFinalDurationMs = math.max(1000, endAtMs - firstHitMs)
  encounterActive=false

  -- cache final snapshot (A)
  local me = GetMyDisplayKey()
  if me and myFinalDurationMs and myFinalDurationMs>0 then
    local durSec = math.max(0.01, myFinalDurationMs/1000)
    Addon._finalSnap = {
      durMs = myFinalDurationMs,
      me   = me,
      dps  = zo_floor((dmgTotals[me] or 0)/durSec + 0.5),
      tHps = zo_floor((healTotTotal[me] or 0)/durSec + 0.5),
      eHps = zo_floor((healTotEff[me]   or 0)/durSec + 0.5),
    }
    Addon._finalizedAt = GetGameTimeMilliseconds()/1000
    blockStartUntilMs = nowMs() + (GRACE_MS or 1200)
    -- debounce right after finalize (C)
    Addon._noRecalcUntil = GetGameTimeMilliseconds() + 900
  end
end

local function OnCombatEvent(_, result, isError, abilityName, abilityGraphic, abilityActionSlotType,
  sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
  sourceUnitId, targetUnitId, abilityId, overflow)

  if isError then return end

  -- Start/extend encounter on any valid outgoing damage
  if DAMAGE_RESULTS[result] and (hitValue or 0) > 0 and isMySource(sourceName, sourceType) then
    local tms = nowMs()
    if not encounterActive then
      if blockStartUntilMs and tms < blockStartUntilMs then return end
      startEncounterAt(tms)
    else
      lastHitMs = tms
    end
    if targetUnitId and targetUnitId ~= 0 then
      local info = activeTargets[targetUnitId] or {}
      info.lastHitMs = tms; info.dead = info.dead or false
      activeTargets[targetUnitId] = info
      if looksLikeDummy(targetName) then end
    end
    local me=GetMyDisplayKey(); if not me then return end
    dmgTotals[me] = (dmgTotals[me] or 0) + hitValue
    return
  end

  -- Track our shield gains on group targets
  if (result==ACTION_RESULT_EFFECT_GAINED or result==ACTION_RESULT_EFFECT_CHANGED) then
    if Addon.playerInCombat and isMySource(sourceName, sourceType) and isGroupTarget(targetName, targetType) then
      local tag = unitTagForDisplay(norm(targetName))
      if tag and (SHIELD_ABILITY_IDS[abilityId] or zo_strlower(tostring(abilityName or "")):find("shield") or zo_strlower(tostring(abilityName or "")):find("ward")) then
        markShieldGained(tag, abilityId, nowMs()+6000)
      end
    end
  end

  -- Shield absorbs -> eHPS (our shield only)
  if result==ACTION_RESULT_DAMAGE_SHIELDED and hitValue and hitValue>0 then
    if Addon.playerInCombat and isGroupTarget(targetName, targetType) then
      local tag = unitTagForDisplay(norm(targetName))
      if tag and hasMyActiveShield(tag) then
        local me=GetMyDisplayKey(); if not me then return end
        healTotEff[me]   = (healTotEff[me]   or 0) + hitValue
        healTotTotal[me] = (healTotTotal[me] or 0) + hitValue
      end
    end
  end

  -- Heals (count only while active)
  if isHealResult(result) then
    if not isMySource(sourceName, sourceType) then return end
    if not isGroupTarget(targetName, targetType) then return end
    if not encounterActive then return end
    local eff  = math.max(0, hitValue  or 0)
    local over = math.max(0, overflow  or 0)
    local tot  = eff + over
    local me=GetMyDisplayKey(); if not me then return end
    healTotEff[me]   = (healTotEff[me]   or 0) + eff
    healTotTotal[me] = (healTotTotal[me] or 0) + tot
    return
  end

  -- Deaths: finalize when all our hit targets are dead
  if KILL_RESULTS[result] and encounterActive then
    if targetUnitId and activeTargets[targetUnitId] then
      local tms=nowMs()
      local info = activeTargets[targetUnitId]; info.dead = true; activeTargets[targetUnitId]=info
      local allDead=true; local any=false
      for _,inf in pairs(activeTargets) do any=true; if not inf.dead then allDead=false break end end
      if any and allDead then
        local endAt = (lastHitMs and math.max(lastHitMs, tms) or tms)
        if (lastHitMs and (tms - lastHitMs) <= GRACE_MS) then endAt = lastHitMs end
        finalizeEncounter(endAt)
      end
    end
  end
end

local function OnPlayerCombatState(_, inCombat)
  Addon.playerInCombat = inCombat and true or false
  if not inCombat and encounterActive and firstHitMs and lastHitMs then
    finalizeEncounter(lastHitMs)
  end
  if not inCombat then myActiveShields = {} end
end

------------------------------------------------------------
-- LGB (broadcast only DPS/tHPS/eHPS)
------------------------------------------------------------
local LGB = rawget(_G, "LibGroupBroadcast")
local lgbRx = {}
local V7_BASE, V7_MAX = 100,(100^3)-1
local function v7Encode(n)
  n = math.max(0, math.min(zo_floor(n or 0), V7_MAX))
  local a = zo_floor(n / (V7_BASE*V7_BASE))
  local r = n - a*(V7_BASE*V7_BASE)
  local b = zo_floor(r / V7_BASE)
  local c = r - b*V7_BASE
  return a,b,c
end
local function v7Decode(a,b,c)
  a = Clamp(zo_round((a or 0)*99), 0, 99)
  b = Clamp(zo_round((b or 0)*99), 0, 99)
  c = Clamp(zo_round((c or 0)*99), 0, 99)
  return ((a*V7_BASE)+b)*V7_BASE+c
end

local function rxName(tag) local d=GetUnitDisplayName(tag) if not d or d=="" then return nil end return zo_strformat("<<1>>",d) end
local function LGB_OnDps(tag,data)  local d=rxName(tag); if not d or d==GetMyDisplayKey() then return end; local r=lgbRx[d] or {}; r.dps = v7Decode(data.a,data.b,data.c); lgbRx[d]=r end
local function LGB_OnTHPS(tag,data) local d=rxName(tag); if not d or d==GetMyDisplayKey() then return end; local r=lgbRx[d] or {}; r.tHps= v7Decode(data.a,data.b,data.c); lgbRx[d]=r end
local function LGB_OnEHPS(tag,data) local d=rxName(tag); if not d or d==GetMyDisplayKey() then return end; local r=lgbRx[d] or {}; r.eHps= v7Decode(data.a,data.b,data.c); lgbRx[d]=r end

local function LGB_Init()
  if not LGB then return end
  local h=LGB:RegisterHandler(Addon.name.."Handler"); if not h then return end
  if h.SetDisplayName then h:SetDisplayName("TG's Group Trackers") end
  if h.SetDescription then h:SetDescription("Shares DPS/tHPS/eHPS snapshots") end

  local p  = h:DeclareProtocol(108, "TGT_DPSv7")
  p:AddField(LGB.CreatePercentageField("a")); p:AddField(LGB.CreatePercentageField("b")); p:AddField(LGB.CreatePercentageField("c"))
  p:OnData(LGB_OnDps);  p:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=true }); Addon._p=p

  local pt = h:DeclareProtocol(208, "TGT_THPSv7")
  pt:AddField(LGB.CreatePercentageField("a")); pt:AddField(LGB.CreatePercentageField("b")); pt:AddField(LGB.CreatePercentageField("c"))
  pt:OnData(LGB_OnTHPS); pt:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=true }); Addon._pt=pt

  local pe = h:DeclareProtocol(209, "TGT_EHPSv7")
  pe:AddField(LGB.CreatePercentageField("a")); pe:AddField(LGB.CreatePercentageField("b")); pe:AddField(LGB.CreatePercentageField("c"))
  pe:OnData(LGB_OnEHPS); pe:Finalize({ isRelevantInCombat=false, replaceQueuedMessages=true }); Addon._pe=pe

  EVENT_MANAGER:UnregisterForUpdate(Addon.name.."LGB_TX")
  EVENT_MANAGER:RegisterForUpdate(Addon.name.."LGB_TX", 1000, function()
    -- identity + table guards
    local me = GetMyDisplayKey(); if not me or me=="" then return end
    if type(dmgTotals)~='table' then dmgTotals={} end
    if type(healTotTotal)~='table' then healTotTotal={} end
    if type(healTotEff)~='table' then healTotEff={} end

    if GetGroupSize()<=0 then return end

    -- Debounce after finalize (C)
    if Addon._noRecalcUntil and GetFrameTimeMilliseconds() < Addon._noRecalcUntil then return end

    -- Send cached final snapshot if present (A)
    if not encounterActive and Addon._finalSnap and Addon._finalSnap.me then
      local fs = Addon._finalSnap
      if Addon._p  and Addon._p.Send  then local a,b,c=v7Encode(fs.dps);  Addon._p:Send({a=a/99,b=b/99,c=c/99}) end
      if Addon._pt and Addon._pt.Send then local a,b,c=v7Encode(fs.tHps); Addon._pt:Send({a=a/99,b=b/99,c=c/99}) end
      if Addon._pe and Addon._pe.Send then local a,b,c=v7Encode(fs.eHps); Addon._pe:Send({a=a/99,b=b/99,c=c/99}) end
      lgbRx[fs.me] = { dps=fs.dps, tHps=fs.tHps, eHps=fs.eHps }

      -- stop sending after 5s settle window
      if Addon._finalizedAt and (GetGameTimeMilliseconds()/1000 - Addon._finalizedAt) > 5 then
        Addon._finalSnap, Addon._finalizedAt = nil, nil
      end
      return
    end

    -- Normal compute + send
    local durSec
    if encounterActive and firstHitMs then durSec = math.max(0.01, (nowMs() - firstHitMs)/1000)
    else durSec = math.max(0.01, (myFinalDurationMs or 0)/1000) end

    local dpsInt = Clamp(zo_floor((dmgTotals[me] or 0)/durSec + 0.5), 0, V7_MAX)
    local tInt   = Clamp(zo_floor((healTotTotal[me] or 0)/durSec + 0.5), 0, V7_MAX)
    local eInt   = Clamp(zo_floor((healTotEff[me]   or 0)/durSec + 0.5), 0, V7_MAX)

    if Addon._p  and Addon._p.Send  then local a,b,c=v7Encode(dpsInt); Addon._p:Send({a=a/99,b=b/99,c=c/99}) end
    if Addon._pt and Addon._pt.Send then local a,b,c=v7Encode(tInt);  Addon._pt:Send({a=a/99,b=b/99,c=c/99}) end
    if Addon._pe and Addon._pe.Send then local a,b,c=v7Encode(eInt);  Addon._pe:Send({a=a/99,b=b/99,c=c/99}) end

    -- Local snapshot for self too
    lgbRx[me] = { dps=dpsInt, tHps=tInt, eHps=eInt }
  end)
end

------------------------------------------------------------
-- Header text, list & sorting, compute display
------------------------------------------------------------
local function headerText()
  local durMs
  if encounterActive and firstHitMs then durMs = nowMs() - firstHitMs else durMs = myFinalDurationMs or 0 end
  durMs = (durMs and durMs>0) and durMs or 0
  local totalSec = zo_floor(durMs/1000)
  return string.format("Time: %d:%02d", zo_floor(totalSec/60), totalSec % 60)
end

local function buildNameList()
  local names, size = {}, GetGroupSize()
  if size>0 then
    for i=1,size do
      local tag=GetGroupUnitTagByIndex(i)
      if tag then
        local disp=GetUnitDisplayName(tag); local char=GetUnitName(tag)
        if disp and disp~="" then table.insert(names, zo_strformat("<<1>>",disp))
        elseif char and char~="" then table.insert(names, zo_strformat("<<1>>",char)) end
      end
    end
    table.sort(names,function(a,b) return zo_strlower(a)<zo_strlower(b) end)
  elseif Addon.saved.showWhenSolo or Addon.saved.previewWhileAdjusting then
    local disp=GetUnitDisplayName("player"); local char=GetUnitName("player")
    if disp and disp~="" then table.insert(names, zo_strformat("<<1>>",disp))
    elseif char and char~="" then table.insert(names, zo_strformat("<<1>>",char)) end
  end
  return names,size
end

local function computeCombined(displayName, key)
  local me=GetMyDisplayKey()
  if displayName==me then
    if encounterActive and firstHitMs then
      local durMs = nowMs() - firstHitMs
      if durMs<=0 then return 0 end
      if key=="dps" then return (dmgTotals[displayName] or 0)/(durMs/1000)
      elseif key=="tHps" then return (healTotTotal[displayName] or 0)/(durMs/1000)
      else return (healTotEff[displayName] or 0)/(durMs/1000) end
    elseif Addon._finalSnap then
      if key=="dps" then return Addon._finalSnap.dps or 0
      elseif key=="tHps" then return Addon._finalSnap.tHps or 0
      else return Addon._finalSnap.eHps or 0 end
    else
      local durMs = myFinalDurationMs or 0
      if durMs<=0 then return 0 end
      if key=="dps" then return (dmgTotals[displayName] or 0)/(durMs/1000)
      elseif key=="tHps" then return (healTotTotal[displayName] or 0)/(durMs/1000)
      else return (healTotEff[displayName] or 0)/(durMs/1000) end
    end
  end
  local r=lgbRx[displayName]; if not r then return 0 end
  if key=="dps" then return r.dps or 0
  elseif key=="tHps" then return r.tHps or 0
  else return r.eHps or 0 end
end

local function sortNames(names)
  local key = Addon.saved.sortBy or "DPS"
  table.sort(names, function(a,b)
    local da, db
    if key=="tHPS" then da, db = computeCombined(a,"tHps"), computeCombined(b,"tHps")
    elseif key=="eHPS" then da, db = computeCombined(a,"eHps"), computeCombined(b,"eHps")
    else da, db = computeCombined(a,"dps"), computeCombined(b,"dps") end
    if da==db then return zo_strlower(a)<zo_strlower(b) end
    return da>db
  end)
end

------------------------------------------------------------
-- Refresh / Updater
------------------------------------------------------------
function Addon.Refresh()
  EnsureWindow()
  _EnsureHeader()
  _EnsureRows()
  _ApplyFonts()

  if Addon.headerLabel and Addon.headerLabel.SetText then Addon.headerLabel:SetText(headerText()) end

  local names,groupSize=buildNameList()
  sortNames(names)
  local count=#names
  for i=1,MAX_GROUP_SIZE do
    local row=rowCtrls[i]
    if i<=count then
      local disp=names[i]
      labelsName[i]:SetText(zo_strformat("<<1>>",disp))
      labelsDps[i] :SetText(formatInt(computeCombined(disp,"dps")))
      labelsTHps[i]:SetText(formatInt(computeCombined(disp,"tHps")))
      labelsEHps[i]:SetText(formatInt(computeCombined(disp,"eHps")))
      row:SetHidden(false)
    else
      row:SetHidden(true)
    end
  end

  _ApplyLayout(); _ApplyOpacity()

    local reticle = not IsReticleHidden()
  local shouldShow = Addon.saved.isShown and (reticle or Addon.saved.previewWhileAdjusting or Addon.saved.showWhenSolo or (Addon._finalSnap~=nil))
  TGsGroupTrackers_Window:SetHidden(not shouldShow)
end

------------------------------------------------------------
-- Updater (UI refresh + idle finalizer + shield GC)
------------------------------------------------------------
local function StartUpdater()
  EVENT_MANAGER:UnregisterForUpdate(Addon.name.."UI")
  EVENT_MANAGER:RegisterForUpdate(Addon.name.."UI", 250, function()
    if encounterActive and lastHitMs and (nowMs() - lastHitMs >= IDLE_END_MS) then
      finalizeEncounter(lastHitMs)
    end
    Addon.Refresh()
    CullExpiredShields()
  end)
end

------------------------------------------------------------
-- Settings (LibAddonMenu-2.0)
------------------------------------------------------------
local function InitLAM()
  local LAM = rawget(_G, "LibAddonMenu2"); if not LAM then return end
  local panelData = { type="panel", name="TG's Group Trackers", displayName="TG's Group Trackers", author="@TG", version=Addon.version, registerForRefresh=true }
  LAM:RegisterAddonPanel(Addon.name.."_Options", panelData)

  local opts = {
    { type="dropdown", name="Sort by", tooltip="Default sort column", choices={"DPS","tHPS","eHPS"},
      getFunc=function() return Addon.saved.sortBy or "DPS" end,
      setFunc=function(v) Addon.saved.sortBy=v or "DPS" end },

    { type="slider", name="Font size", min=14, max=48, step=1,
      getFunc=function() return Addon.saved.fontSize or defaults.fontSize end,
      setFunc=function(v) Addon.saved.fontSize=Clamp(v,14,48) end },

    { type="slider", name="Width", min=320, max=1200, step=10,
      getFunc=function() return Addon.saved.width or defaults.width end,
      setFunc=function(v) Addon.saved.width=Clamp(v,320,1200) end },

    { type="slider", name="UI Scale", min=0.70, max=1.80, step=0.05,
      getFunc=function() return Addon.saved.scale or defaults.scale end,
      setFunc=function(v) Addon.saved.scale=Clamp(v,0.70,1.80) end },

    { type="slider", name="Opacity", min=20, max=100, step=5,
      getFunc=function() return zo_round((Addon.saved.opacity or defaults.opacity)*100) end,
      setFunc=function(v) Addon.saved.opacity=Clamp(v/100, MIN_OP, MAX_OP) end },

    { type="slider", name="X Position", min=0, max=2000, step=5,
      getFunc=function() return zo_round(Addon.saved.posX or 40) end,
      setFunc=function(v) Addon.saved.posX=v; Addon._ApplySavedAnchor() end },

    { type="slider", name="Y Position", min=0, max=2000, step=5,
      getFunc=function() return zo_round(Addon.saved.posY or 40) end,
      setFunc=function(v) Addon.saved.posY=v; Addon._ApplySavedAnchor() end },

    { type="checkbox", name="Show when solo",
      getFunc=function() return Addon.saved.showWhenSolo end,
      setFunc=function(v) Addon.saved.showWhenSolo = (v and true or false) end },

    { type="checkbox", name="Preview While Adjusting (show in menus)",
      getFunc=function() return Addon.saved.previewWhileAdjusting end,
      setFunc=function(v) Addon.saved.previewWhileAdjusting = (v and true or false) end },
  }
  LAM:RegisterOptionControls(Addon.name.."_Options", opts)
end

------------------------------------------------------------
-- Init
------------------------------------------------------------
local function OnAddOnLoaded(_, addonName)
  if addonName ~= Addon.name then return end
  EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)

  Addon.saved = ZO_SavedVars:NewAccountWide("TGsGroupTrackers_SavedVariables", 1, nil, defaults)
  for k,v in pairs(defaults) do if Addon.saved[k]==nil then Addon.saved[k]=v end end

  EnsureWindow()
  Addon._ApplySavedAnchor()
  InitLAM()
  StartUpdater()

  if rawget(_G, "LibGroupBroadcast") then LGB_Init() end

  EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
  EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_COMBAT_EVENT, OnCombatEvent)

  d(string.format("[TG's Group Trackers] v%s loaded.", Addon.version))
end
EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)