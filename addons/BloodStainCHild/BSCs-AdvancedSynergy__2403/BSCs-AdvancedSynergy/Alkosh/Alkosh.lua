-- =====================================================================
-- BSCs Advanced Synergy – Alkosh (ScrollList)
-- =====================================================================
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

-- Row-Template-Name (muss in der XML existieren)
local ROW_TEMPLATE = "BSCASAlkoshUIVirtual"

-- interner State
local ALKOSH = {
  frame       = nil,   -- BSCASAlkoshUI (TopLevel aus XML)
  list        = nil,   -- ZO_ScrollList
  fragment    = nil,   -- Scene-Fragment
  rows        = {},    -- map[id] = { id, unitTag, begin, ends, name, isBoss, playSound, _remain }
  order       = {},    -- sortierte Array derselben Strukturen
  needRebuild = false, -- ob vollständiger Commit nötig ist
  dragBar     = nil,   -- unsichtbarer Drag-Handle
}

local bossUnitTags = {}
local debug_mode   = false
local ALKOSH_HITVAL = 0
BSCAS.AlkoshBuffActive = false

-- ---------------------------------------------------------
-- util
-- ---------------------------------------------------------
local function IsUnitBoss(unitTag)
  return unitTag and bossUnitTags[unitTag] == true
end

local function DebugPrintf(fmt, ...)
  if not debug_mode then return end
  BSCAS:PrintDebug(string.format(fmt, ...))
end

function BSCAS.AlkoshDebugMode()
  debug_mode = not debug_mode
  BSCAS:PrintDebug("Debug Mode (Alkosh) " ..
    zo_strformat("<<1>>[<<2>><<3>><<4>>]",
      "|cb3b6b7",
      (debug_mode and BSCAS.color_red or BSCAS.color_green),
      (debug_mode and 'Enabled' or 'Disabled'),
      "|cb3b6b7"
    )
  )
end

local function AlkoshCheckAllowed()
  if not BSCAS.SV_acc or not BSCAS.SV or not BSCAS.SV.SELECTED_PRESET then return true end
  local preset = BSCAS.SV_acc.SETTING and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET]
  return not preset or preset.ALKOSHCHECK ~= false
end
local function CheckTargetBossOption()
  if not AlkoshCheckAllowed() then return end
  if not BSCAS.SV_acc or not BSCAS.SV or not BSCAS.SV.SELECTED_PRESET then return true end
  local preset = BSCAS.SV_acc.SETTING and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET]
  return not preset or preset.ALKOSH_BOSS_TARGET ~= false
end

local function SetAlkoshMode(enable, unitTag)
  if not AlkoshCheckAllowed() then return end  
  if BSCAS.AlkoshBuffActive == enable then return end
  BSCAS.AlkoshBuffActive = enable
  BSCAS:OSAC()
  DebugPrintf("AlkoshBuffActive -> %s UnitTag[%s]", tostring(enable), unitTag)
end

-- zentrale Metriken
local function GetMetrics()
  local W   = (BSCAS.SV and BSCAS.SV.UI_WIDTH) or 250
  local RH  = (BSCAS.SV and BSCAS.SV.UI_HIGHT) or 28
  RH = math.max(22, RH) -- harte Untergrenze
  local MH  = (BSCAS.SV and BSCAS.SV.UI_MAX_HEIGHT) or 260
  return W, RH, MH
end

local function CalcolatePlayerStat()
  local WP = GetPlayerStat(STAT_POWER)
  local SP = GetPlayerStat(STAT_SPELL_POWER)
  ALKOSH_HITVAL = (WP > SP) and WP or SP
end

-- ---------------------------------------------------------
-- ScrollList Row-Setup
-- ---------------------------------------------------------
local function SetupRow(control, data)
  local W, RH = GetMetrics()
  control:SetHeight(RH)

  local back   = control:GetNamedChild("Back")
  local icon   = control:GetNamedChild("Icon")
  local bar    = control:GetNamedChild("Bar")
  local marker = control:GetNamedChild("Marker")
  local label  = control:GetNamedChild("Label")
  local timer  = control:GetNamedChild("Timer")

  -- Backdrop füllt die komplette Row
  back:ClearAnchors()
  back:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
  back:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
  back:SetCenterColor(0, 0, 0, data.alt and 0.22 or 0.14)
  back:SetEdgeColor(1, 1, 1, 0.35)

  -- Icon
  local iconW = math.max(16, RH - 4)
  icon:SetTexture(GetAbilityIcon(BSCAS.ALKOSH_DBUFF_ID))
  icon:SetDimensions(iconW, iconW)

  -- Platz für Scrollbar (ca. 18 px) + Innenabstand
  local SCROLLBAR_PAD = 18
  local RIGHT_INSET   = 10 + SCROLLBAR_PAD

  -- Timer rechts (mit Abstand zur Scrollbar)
  local timerW = 48
  timer:ClearAnchors()
  timer:SetAnchor(RIGHT, back, RIGHT, -RIGHT_INSET, 0)
  timer:SetDimensions(timerW, RH)
  timer:SetFont("$(BOLD_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(RH * 0.75)) .. ")|soft-shadow-thick)")

  -- Bar zwischen Icon und Timer
  local barLeftPad = 4
  local labelPad   = 8
  local barW = math.max(
    40,
    W - (iconW + 2 + barLeftPad + labelPad + timerW + RIGHT_INSET + 10)
  )
  bar:ClearAnchors()
  bar:SetAnchor(LEFT, icon, RIGHT, barLeftPad, 0)
  bar:SetDimensions(barW, math.max(1, RH - 4))
  bar:SetMinMax(0, 1)

  -- Label (über dem Bar-Bereich)
  local labelW = math.max(40, W - (iconW + labelPad + timerW + RIGHT_INSET + 10))
  label:ClearAnchors()
  label:SetAnchor(LEFT, icon, RIGHT, labelPad, 0)
  label:SetDimensions(labelW, RH)
  label:SetFont("$(MEDIUM_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(RH * 0.6)) .. ")|soft-shadow-thin")
  label:SetText(data.name or "?")

  -- Live-Countdown
  local now    = GetGameTimeMilliseconds() / 1000
  local total  = math.max(0.001, data.ends - data.begin)
  local remain = math.max(0, data.ends - now)
  local ratio  = math.max(0, math.min(1, remain / total))

  bar:SetValue(ratio)
  local r = 1 - ratio
  local g = ratio
  bar:SetGradientColors(r, g, 0, 0.8, r * 0.5, g * 0.5, 0, 0.8)
  timer:SetText(string.format("%.1f", remain))

  -- Marker (knallrot, undurchsichtig, über der Bar)
  if data.isBoss and (BSCAS.SV and BSCAS.SV.ALKOSH_ENABLE_MARK) then
    local threshold = (BSCAS.SV.ALKOSH_SOUND_INC or 3)
    local frac      = math.max(0, math.min(1, threshold / total))
    marker:ClearAnchors()
    marker:SetAnchor(LEFT, bar, LEFT, math.floor(barW * frac), 0)
    marker:SetDimensions(5, math.max(1, RH - 2))
    marker:SetHidden(false)
    marker:SetColor(1, 0, 0, 1)
    marker:SetAlpha(1)
    marker:SetDrawTier(DT_HIGH)
    marker:SetDrawLayer(DL_OVERLAY)
    marker:SetDrawLevel(10)
  else
    marker:SetHidden(true)
  end
end

-- ---------------------------------------------------------
-- Datentyp sicherstellen (Fix: height & uniformControlHeight gesetzt)
-- ---------------------------------------------------------
local function EnsureDataType(list, RH)
  local dt = ZO_ScrollList_GetDataTypeTable(list, 1)
  if not dt then
    ZO_ScrollList_AddDataType(list, 1, ROW_TEMPLATE, RH, SetupRow)
  else
    dt.height = RH
  end
  -- robust: Mode und Uniform-Höhe explizit setzen
  list.mode = 1                    -- ZO_SCROLL_LIST_UNIFORM_SIZE
  list.uniformControlHeight = RH   -- verhindert nil in Commit
end

-- ---------------------------------------------------------
-- Build / Commit / Dynamic Height
-- ---------------------------------------------------------
local function SortOrder()
  local now = GetGameTimeMilliseconds() / 1000
  for _, d in ipairs(ALKOSH.order) do
    d._remain = math.max(0, d.ends - now)
  end
  table.sort(ALKOSH.order, function(a, b)
    if a.isBoss ~= b.isBoss then return a.isBoss end
    if a._remain ~= b._remain then return a._remain < b._remain end
    return (a.name or "") < (b.name or "")
  end)
end

local function BuildOrder()
  local arr = {}
  local now = GetGameTimeMilliseconds() / 1000
  for _, d in pairs(ALKOSH.rows) do
    local remain = d.ends - now
    if remain > 0.001 then
      d._remain = remain
      table.insert(arr, d)
    end
  end
  ALKOSH.order = arr
  SortOrder()
end

local function VisibleCap()
  return (BSCAS.SV and tonumber(BSCAS.SV.ALKOSH_LIST_COUNT)) or 10
end

-- Höhe der Listbox exakt als Vielfaches der Row-Höhe setzen
local function UpdateListHeight()
  if not ALKOSH.list then return end
  local _, RH, MH = GetMetrics()

  RH = math.floor(RH + 0.5) -- ganzzahlig
  local rows       = math.min(#ALKOSH.order, VisibleCap())
  local maxByMH    = math.max(1, math.floor(MH / RH))
  local showRows   = math.min(rows, maxByMH)

  ALKOSH.list:SetHeight(showRows * RH)
end

local function PositionListBelowHeader()
  if not (ALKOSH.frame and ALKOSH.list) then return end
  local W, _, MH = GetMetrics()
  local valueLbl = ALKOSH.frame:GetNamedChild("Value")

  ALKOSH.list:ClearAnchors()
  if valueLbl and not valueLbl:IsHidden() then
    ALKOSH.list:SetAnchor(TOPLEFT, valueLbl, BOTTOMLEFT, 0, 4)
  else
    ALKOSH.list:SetAnchor(TOPLEFT, ALKOSH.frame, TOPLEFT, 0, 4)
  end
  ALKOSH.list:SetDimensions(W, MH)
end

-- ---------- Frame/Bg auf Listengröße ziehen ----------
local function ResizeFrameToList()
  if not (ALKOSH.frame and ALKOSH.list) then return end
  local W, _, MH = GetMetrics()
  local listH   = ALKOSH.list:GetHeight() or 0
  local headerH = 0
  local valueLbl = ALKOSH.frame:GetNamedChild("Value")
  if valueLbl and not valueLbl:IsHidden() then
    headerH = valueLbl:GetHeight() or 0
  end

  local H = math.max(1, math.min(MH, listH + headerH))
  ALKOSH.frame:SetDimensions(W, H)

  local bg = ALKOSH.frame:GetNamedChild("Bg")
  if bg then
    bg:ClearAnchors()
    bg:SetAnchor(TOPLEFT, ALKOSH.frame, TOPLEFT, 0, 0)
    bg:SetAnchor(BOTTOMRIGHT, ALKOSH.frame, BOTTOMRIGHT, 0, 0)
    bg:SetMouseEnabled(false) -- Bg blockiert keine Maus
  end
end


-- ---------- Drag-Handle bereitstellen ----------
local function EnsureDragHandle()
  if ALKOSH.dragBar or not ALKOSH.frame then return end
  local drag = WINDOW_MANAGER:CreateControl("BSCAS_Alkosh_DragBar", ALKOSH.frame, CT_CONTROL)
  drag:ClearAnchors()
  drag:SetAnchor(TOPLEFT,  ALKOSH.frame, TOPLEFT,  0, 0)
  drag:SetAnchor(TOPRIGHT, ALKOSH.frame, TOPRIGHT, 0, 0)
  drag:SetHeight(22)           -- 22px hohe, unsichtbare Griffleiste
  drag:SetAlpha(0)
  drag:SetDrawLayer(DL_OVERLAY)
  drag:SetDrawLevel(5000)
  drag:SetMouseEnabled(true)

  drag:SetHandler("OnMouseDown", function(_, btn)
    if btn == MOUSE_BUTTON_INDEX_LEFT and not (BSCAS.SV and BSCAS.SV.ALKOSH_LOCK_UI) then
      ALKOSH.frame:StartMoving()
    end
  end)
  drag:SetHandler("OnMouseUp", function()
    if not (BSCAS.SV and BSCAS.SV.ALKOSH_LOCK_UI) then
      ALKOSH.frame:StopMovingOrResizing()
      BSCAS.AlkoshOnMoveStop()
    end
  end)

  ALKOSH.dragBar = drag
end

local function UpdateDragState()
  if not ALKOSH.frame then return end
  local locked = (BSCAS.SV and BSCAS.SV.ALKOSH_LOCK_UI) or false
  ALKOSH.frame:SetMovable(not locked)
  if ALKOSH.dragBar then
    ALKOSH.dragBar:SetHidden(locked)
    ALKOSH.dragBar:SetMouseEnabled(not locked)
  end
end

-- eigentlicher Commit
local function CommitList()
  if not ALKOSH.list then return end

  -- Sicherheitsnetz: Datentyp/Height vorhanden?
  local _, RH = GetMetrics()
  EnsureDataType(ALKOSH.list, RH)

  local dataList = ZO_ScrollList_GetDataList(ALKOSH.list)
  ZO_ClearNumericallyIndexedTable(dataList)

  local cap = VisibleCap()
  for i = 1, math.min(#ALKOSH.order, cap) do
    local rec = ALKOSH.order[i]
    if rec then
      table.insert(dataList, ZO_ScrollList_CreateDataEntry(1, {
        id     = rec.id,
        name   = rec.name,
        begin  = rec.begin,
        ends   = rec.ends,
        isBoss = rec.isBoss,
      }))
    end
  end

  ZO_ScrollList_Commit(ALKOSH.list)
  UpdateListHeight()
  ResizeFrameToList()

  local valueLbl = ALKOSH.frame and ALKOSH.frame:GetNamedChild("Value")
  if valueLbl then
    valueLbl:SetHidden(#ALKOSH.order == 0)
    if #ALKOSH.order > 0 then
      valueLbl:SetText(zo_strformat("Pen. Value <<1>>", ALKOSH_HITVAL))
    end
  end
end

-- ---------------------------------------------------------
-- Tick-Update (leicht)
-- ---------------------------------------------------------
local function UpdateTickLight()
  if not ALKOSH.list then return end
  local now       = GetGameTimeMilliseconds() / 1000
  local threshold = (BSCAS.SV and BSCAS.SV.ALKOSH_SOUND_INC) or 3
  local changed   = false
  local anyActive = false

  for _, d in ipairs(ALKOSH.order) do
    local remain = math.max(0, d.ends - now)
    if d._remain ~= remain then
      d._remain = remain
      if remain <= 0.0001 then
        changed = true
      end
    end
    if d.isBoss and remain <= threshold and d.playSound and (BSCAS.SV and BSCAS.SV.ALKOSH_SOUND_PLAY) then
      d.playSound = false
      if BSCAS.PlaySound then
        BSCAS.PlaySound(BSCAS.SV.ALKOSH_SOUND_LOOP, BSCAS.SV.ALKOSH_SOUND_ID)
      end
    end
    anyActive = anyActive or (remain > 0)
  end

  local valueLbl = ALKOSH.frame:GetNamedChild("Value")
  valueLbl:SetHidden(not anyActive)
  if anyActive then
    valueLbl:SetText(zo_strformat("Pen. Value <<1>>", ALKOSH_HITVAL))
  end
	PositionListBelowHeader()

  if changed then
    ALKOSH.needRebuild = true
  else
    ZO_ScrollList_RefreshVisible(ALKOSH.list)
  end
end

local function OnTick()
  if ALKOSH.needRebuild then
    BuildOrder()
    CommitList()
    ALKOSH.needRebuild = false
  else
    UpdateTickLight()
  end
end

-- ---------------------------------------------------------
-- Reapply-Check
-- ---------------------------------------------------------
local function GetAlkoshReapplySeconds()
  if not BSCAS.SV_acc or not BSCAS.SV or not BSCAS.SV.SELECTED_PRESET then return nil end
  local preset = BSCAS.SV_acc.SETTING and BSCAS.SV_acc.SETTING[BSCAS.SV.SELECTED_PRESET]
  if not preset then return nil end
  return preset.ALKOSH_REAPPLY
end

local function ReApplyAlkosh()
  if not AlkoshCheckAllowed() then return end
  local reapply = GetAlkoshReapplySeconds()
  if reapply == nil then return end

  local now = GetGameTimeMilliseconds() / 1000
  for ident, row in pairs(ALKOSH.rows) do
    if row.isBoss then
      local remain = row.ends - now
	  if remain > 0 and remain <= reapply then
		DebugPrintf("remain=%s ALKOSH_REAPPLY=%s", remain, reapply)
        SetAlkoshMode(false, row.unitTag)
        return
      end
    end
  end
end

-- ---------------------------------------------------------
-- EFFECT_CHANGED
-- ---------------------------------------------------------
local function AlkoshOnEffectChanged(_, changeType, _, _, unitTag, beginTime, endTime, _, _, _, _, _, _, unitName, unitId, abilityId, sourceType)
  if CheckTargetBossOption() and sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
  local ident  = zo_strformat("<<1>><<2>>", unitId, abilityId)
  local isBoss = IsUnitBoss(unitTag)

  if changeType == EFFECT_RESULT_FADED then
    if ALKOSH.rows[ident] then
      ALKOSH.rows[ident] = nil
      ALKOSH.needRebuild = true
    end
    if isBoss then SetAlkoshMode(false, unitTag) end
    DebugPrintf("FADED id=%s tag=%s name=%s", ident, tostring(unitTag), tostring(unitName))

  elseif changeType == EFFECT_RESULT_UPDATED then
    local row = ALKOSH.rows[ident]
    if row then
      row.begin     = beginTime
      row.ends      = endTime
      row.name      = zo_strformat("<<!aC:1>>", unitName)
      row.unitTag   = unitTag
      row.isBoss    = isBoss
      row.playSound = true
    else
      ALKOSH.rows[ident] = {
        id        = ident,
        unitTag   = unitTag,
        begin     = beginTime,
        ends      = endTime,
        name      = zo_strformat("<<!aC:1>>", unitName),
        isBoss    = isBoss,
        playSound = true,
        _remain   = 0,
      }
      ALKOSH.needRebuild = true
    end
    DebugPrintf("UPDATED id=%s tag=%s name=%s", ident, tostring(unitTag), tostring(unitName))

  else -- EFFECT_RESULT_GAINED
    ALKOSH.rows[ident] = {
      id        = ident,
      unitTag   = unitTag,
      begin     = beginTime,
      ends      = endTime,
      name      = zo_strformat("<<!aC:1>>", unitName),
      isBoss    = isBoss,
      playSound = true,
      _remain   = 0,
    }
    if isBoss then SetAlkoshMode(true, unitTag) end
    ALKOSH.needRebuild = true
    DebugPrintf("GAINED id=%s tag=%s name=%s", ident, tostring(unitTag), tostring(unitName))
  end

  CalcolatePlayerStat()
end

-- ---------------------------------------------------------
-- UI / Metrics / Position
-- ---------------------------------------------------------
local function ApplyUIMetrics()
  if not ALKOSH.frame or not ALKOSH.list then return end
  local W, RH, MH = GetMetrics()

  -- Value-Label
  local valueLbl = ALKOSH.frame:GetNamedChild("Value")
  if valueLbl then
    valueLbl:SetWidth(W)
    valueLbl:SetFont("$(BOLD_FONT)|$(KB_" .. BSCAS.FontCheck(math.floor(RH * 0.75)) .. ")|soft-shadow-thick")
	valueLbl:ClearAnchors()
    valueLbl:SetAnchor(TOPLEFT, ALKOSH.frame, TOPLEFT, 0, -4)
  end

  -- ScrollList Maße
  PositionListBelowHeader()


  -- Datentyp & Height erzwingen (Fix gegen nil-height)
  EnsureDataType(ALKOSH.list, RH)

  -- Pools leeren + sauber neu aufbauen
  ZO_ScrollList_Clear(ALKOSH.list)
  CommitList()
  ZO_ScrollList_ResetToTop(ALKOSH.list)

  ResizeFrameToList()
end

function BSCAS.AlkoshOnMoveStop()
  if not ALKOSH.frame then return end
  BSCAS.SV.UI_LEFT = ALKOSH.frame:GetLeft()
  BSCAS.SV.UI_TOP  = ALKOSH.frame:GetTop()
end

local function RestorePosition()
  if not ALKOSH.frame then return end
  ALKOSH.frame:ClearAnchors()
  local L = (BSCAS.SV and BSCAS.SV.UI_LEFT) or 200
  local T = (BSCAS.SV and BSCAS.SV.UI_TOP)  or 200
  ALKOSH.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, L, T)

  UpdateDragState()
end

local function CreateUI()
  bossUnitTags = {}
  for i = 1, (tonumber(MAX_BOSSES) or 5) do bossUnitTags["boss"..i] = true end

  ALKOSH.frame = BSCASAlkoshUI  -- aus XML
  -- OnMoveStop kommt aus XML: <OnMoveStop> BSCASynergy.AlkoshOnMoveStop() </OnMoveStop>

  -- ScrollList anlegen
  ALKOSH.list = WINDOW_MANAGER:CreateControlFromVirtual("BSCAS_Alkosh_List", ALKOSH.frame, "ZO_ScrollList")
  ZO_ScrollList_EnableHighlight(ALKOSH.list, "ZO_ThinListHighlight")

  ALKOSH.fragment = ZO_SimpleSceneFragment:New(ALKOSH.frame)

  ApplyUIMetrics()
  RestorePosition()
  EnsureDragHandle()
  UpdateDragState()

  -- Sicherheit: Bg soll keine Maus abfangen
  local bg = ALKOSH.frame:GetNamedChild("Bg")
  if bg then bg:SetMouseEnabled(false) end
end

-- ---------------------------------------------------------
-- Public API
-- ---------------------------------------------------------
function BSCAS.AlkoshEnable()
  if not BSCAS.SV or not BSCAS.SV.ALKOSH_CHECK then return end
  if not ALKOSH.frame then CreateUI() end

  ALKOSH.frame:SetHidden(false)
  SCENE_MANAGER:GetScene("hud"):AddFragment(ALKOSH.fragment)
  SCENE_MANAGER:GetScene("hudui"):AddFragment(ALKOSH.fragment)

  EVENT_MANAGER:RegisterForUpdate('BSCAS_Alkosh_Tick', BSCAS.UPDATE_INTERVAL, OnTick)
end

function BSCAS.AlkoshDisable()
  if not BSCAS.SV or not BSCAS.SV.ALKOSH_CHECK then return end
  if not ALKOSH.frame then return end

  ALKOSH.frame:SetHidden(true)
  EVENT_MANAGER:UnregisterForUpdate('BSCAS_Alkosh_Tick')

  SCENE_MANAGER:GetScene("hud"):RemoveFragment(ALKOSH.fragment)
  SCENE_MANAGER:GetScene("hudui"):RemoveFragment(ALKOSH.fragment)
end

local function BuffTest()	
	local unitTag = "reticleover"	
	for buffIndex = 1, GetNumBuffs(unitTag) do
		local abilityId = select(11, GetUnitBuffInfo(unitTag, buffIndex))
		if abilityId == BSCAS.ALKOSH_DBUFF_ID then
			d(abilityId)
		end
	end	
end

function BSCAS.AlkoshInit()
  CreateUI()
  BuildOrder()
  CommitList()

  EVENT_MANAGER:RegisterForEvent("BSCAS_Alkosh_Effect", EVENT_EFFECT_CHANGED, AlkoshOnEffectChanged)
  EVENT_MANAGER:AddFilterForEvent("BSCAS_Alkosh_Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, BSCAS.ALKOSH_DBUFF_ID)

  EVENT_MANAGER:RegisterForUpdate('BSCAS_Alkosh_Reapply', BSCAS.UPDATE_INTERVAL, ReApplyAlkosh)

  CalcolatePlayerStat()
  ApplyUIMetrics()

  if BSCAS.SV.ALKOSH_CHECK then
    BSCAS.AlkoshEnable()
  else
    BSCAS.AlkoshDisable()
  end
    
  --EVENT_MANAGER:RegisterForUpdate('BSCAS_Alkosh_BuffTest', 5000, BuffTest)
end

-- von außen bei Settings-Änderungen
function BSCAS.AlkoshApplyMetrics()
  ApplyUIMetrics()  
  RestorePosition()
  UpdateDragState()
end

function BSCAS.AlkoshSetHidden(hidden)
  if not ALKOSH.frame then return end
  if hidden then BSCAS.AlkoshDisable() else BSCAS.AlkoshEnable() end
end

-- öffentlich, falls das Menü direkt nur Lock toggelt
function BSCAS.AlkoshUpdateDragState()
  UpdateDragState()
end

-- ---------------------------------------------------------
-- Dummy-Daten
-- ---------------------------------------------------------
function BSCAS.AlkoshDummyList(count, duration)
  count    = tonumber(count)    or 12
  duration = tonumber(duration) or 20

  local nBosses = tonumber(MAX_BOSSES) or 5

  if not ALKOSH or not ALKOSH.frame then
    if CreateUI then CreateUI() end
  end
  bossUnitTags = bossUnitTags or {}
  if not next(bossUnitTags) then
    for i = 1, nBosses do bossUnitTags["boss"..i] = true end
  end

  ALKOSH.rows = {}
  local now = GetGameTimeMilliseconds() / 1000
  local hasBoss = false

  for i = 1, count do
    local isBoss  = (i <= nBosses)
    local unitTag = isBoss and ("boss"..i) or ("TestUnit_"..(i - nBosses))
    local ident   = "DUMMY"..i

    local dur = math.max(3, duration - (i - 1) * 0.7)
    local b   = now
    local e   = now + dur

    ALKOSH.rows[ident] = {
      id        = ident,
      unitTag   = unitTag,
      begin     = b,
      ends      = e,
      name      = unitTag,
      isBoss    = isBoss,
      playSound = isBoss,
      _remain   = dur,
    }
    hasBoss = hasBoss or isBoss
  end

  SetAlkoshMode(hasBoss, "boss1")
  CalcolatePlayerStat()

  BuildOrder()
  CommitList()

  if BSCAS.SV and BSCAS.SV.ALKOSH_CHECK then
    BSCAS.AlkoshEnable()
  else
    if ALKOSH and ALKOSH.frame then ALKOSH.frame:SetHidden(false) end
    EVENT_MANAGER:RegisterForUpdate('BSCAS_Alkosh_Tick', BSCAS.UPDATE_INTERVAL, OnTick)
  end
end

function BSCAS.ClearDummyList()
  ALKOSH.rows        = {}
  ALKOSH.order       = {}
  ALKOSH.needRebuild = false
  SetAlkoshMode(false, "boss1")

  if ALKOSH and ALKOSH.list then
    ZO_ScrollList_Clear(ALKOSH.list)
    ZO_ScrollList_Commit(ALKOSH.list)
    ALKOSH.list:SetHeight(0)
  end
  PositionListBelowHeader()
  ResizeFrameToList()

  local valueLbl = ALKOSH and ALKOSH.frame and ALKOSH.frame:GetNamedChild("Value")
  if valueLbl then valueLbl:SetHidden(true) end
end

-- Layout/Größen & Alpha live anwenden (vom Menü)
function BSCAS.AlkoshRefreshLayout()
  if not ALKOSH.frame or not ALKOSH.list then return end
  local W, RH = GetMetrics()

  ALKOSH.frame:SetAlpha((BSCAS.SV and BSCAS.SV.UI_ALPHA) or 1)
  ALKOSH.list:SetWidth(W)

  EnsureDataType(ALKOSH.list, RH)

  ZO_ScrollList_Clear(ALKOSH.list)
  CommitList()
  ZO_ScrollList_ResetToTop(ALKOSH.list)

  ResizeFrameToList()
  UpdateDragState()
end
