-- HealerPerformancePanel.lua  (v0.2.14)  HEADER mk.dds 256x256 (no stretch), list pushed down
HealerPerformancePanel = {}
local ADDON = "HealerPerformancePanel"
local SV_NAME = "HealerPerformancePanelSV"
local LEADER_ICON = "/esoui/art/unitframes/gamepad/gp_group_leader.dds"

local UPDATE_MS = 200
local FLASH_PERIOD_MS = 450

-- ===== Header image (mk.dds is in the same addon folder) =====
local HEADER_SIZE = 256           -- square, keeps proportions (1:1)
local HEADER_PATH = "mk.dds"      -- file in the same folder as lua/xml

local SOUND_PRESETS = {
  { key = "GENERAL_ALERT_ERROR", label = "Попередження (стандарт)" },
  { key = "ABILITY_FAILED", label = "Невдала дія" },
  { key = "DUEL_START", label = "Початок дуелі" },
  { key = "DUEL_BOUNDARY_WARNING", label = "Попередження дуелі" },
  { key = "BATTLEGROUND_MEDAL", label = "Медаль (BG)" },
  { key = "CHAMPION_POINTS_COMMITTED", label = "Champion Points" },
  { key = "QUEST_ABANDONED", label = "Квест скасовано" },
  { key = "QUEST_SHARED", label = "Квест поширено" },
  { key = "TELVAR_GAINED", label = "Tel Var +" },
  { key = "TELVAR_LOST", label = "Tel Var -" },
  { key = "NEW_TIMED_NOTIFICATION", label = "Нове сповіщення" },
  { key = "RAID_TRIAL_SCORE_ADDED", label = "Trial score" },
  { key = "DEFAULT_CLICK", label = "Клік" },
  { key = "MENU_ACCEPT", label = "Підтвердити" },
  { key = "MENU_BAR_CLICK", label = "Клік меню" },
  { key = "MARKET_PURCHASE_NOTIFICATION", label = "Покупка" },
}

local ROLE_ORDER = { TANK = 1, HEALER = 2, DPS = 3, UNKNOWN = 4 }
local ROLE_ICON = {
  TANK    = "/esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
  HEALER  = "/esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
  DPS     = "/esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
  UNKNOWN = "/esoui/art/miscellaneous/blank.dds",
}

-- ===== Need-Heal WORLD marker state (LibImplex) =====
local DEFAULT_NEEDHEAL_TEXTURE = "/esoui/art/compass/compass_waypoint.dds"
local HPP_HealMarker = {
  desired = {},
  untilMs = {}, -- [unitTag] = expiry ms
      -- [unitTag] = bool
  _warnedAt = nil,   -- chat warn throttle
  lastScanMs = 0,
  debug = false,
  testAll = false,
  testSelf = false,
  _nextDbgAt = 0,
}


local THEMES = {
  ["Skyrim Amber"] = {
    tank   = {0.20, 0.13, 0.05, 0.72},
    healer = {0.08, 0.17, 0.09, 0.72},
    dps    = {0.22, 0.05, 0.05, 0.72},
    unk    = {0.08, 0.08, 0.08, 0.72},
    edge   = {0.00, 0.00, 0.00, 0.35},
    text   = {1.00, 0.98, 0.92, 1.00},
    hptext = {1.00, 0.95, 0.78, 1.00},
    lvl    = {1.00, 0.87, 0.20, 1.00},
    hpbarTank   = {0.95, 0.62, 0.12, 0.95},
    hpbarHealer = {0.30, 0.90, 0.35, 0.95},
    hpbarDps    = {0.95, 0.28, 0.25, 0.95},
    hpbarUnk    = {0.80, 0.80, 0.80, 0.95},
    iconTank = {1.00, 0.88, 0.25, 1.00},
    iconHealer = {0.35, 0.95, 0.35, 1.00},
    iconDps = {1.00, 0.25, 0.25, 1.00},
    iconUnk = {0.85, 0.85, 0.85, 0.95},
  },
  ["Minimal Dark"] = {
    tank   = {0.05, 0.05, 0.05, 0.70},
    healer = {0.05, 0.05, 0.05, 0.70},
    dps    = {0.05, 0.05, 0.05, 0.70},
    unk    = {0.05, 0.05, 0.05, 0.70},
    edge   = {0.00, 0.00, 0.00, 0.00},
    text   = {0.96, 0.96, 0.96, 1.00},
    hptext = {0.95, 0.95, 0.95, 1.00},
    lvl    = {0.95, 0.85, 0.35, 1.00},
    hpbarTank   = {0.95, 0.75, 0.25, 0.95},
    hpbarHealer = {0.35, 0.95, 0.45, 0.95},
    hpbarDps    = {1.00, 0.35, 0.35, 0.95},
    hpbarUnk    = {0.80, 0.80, 0.80, 0.95},
    iconTank = {1.00, 0.90, 0.35, 1.00},
    iconHealer = {0.35, 1.00, 0.45, 1.00},
    iconDps = {1.00, 0.35, 0.35, 1.00},
    iconUnk = {0.90, 0.90, 0.90, 0.95},
  },
}

local TEST_GROUP_CHOICES = { "Вимкнено", "4 гравці (1Т/1Х/2ДД)", "12 гравців (2Т/2Х/8ДД)" }
local TEST_GROUP_VALUES = { 0, 4, 12 }

local function ThemeNames() local out = {} for k,_ in pairs(THEMES) do out[#out+1]=k end table.sort(out) return out end
local function GetTheme() local key = HealerPerformancePanel.settings and HealerPerformancePanel.settings.themeName or "Skyrim Amber"; return THEMES[key] or THEMES["Skyrim Amber"] end
local function CloneColor(c) return { c[1], c[2], c[3], c[4] } end

local function RolePanelColor(roleKey)
  local s = HealerPerformancePanel.settings
  if s.useCustomColors then
    if roleKey=="TANK" and s.colTank then return s.colTank end
    if roleKey=="HEALER" and s.colHealer then return s.colHealer end
    if roleKey=="DPS" and s.colDps then return s.colDps end
    if s.colUnknown then return s.colUnknown end
  end
  local t = GetTheme()
  if roleKey=="TANK" then return CloneColor(t.tank) end
  if roleKey=="HEALER" then return CloneColor(t.healer) end
  if roleKey=="DPS" then return CloneColor(t.dps) end
  return CloneColor(t.unk)
end

local function CurrentEdgeColor() local s=HealerPerformancePanel.settings; if s.useCustomColors and s.colEdge then return s.colEdge end return CloneColor(GetTheme().edge) end
local function CurrentTextColor() local s=HealerPerformancePanel.settings; if s.useCustomColors and s.colText then return s.colText end return CloneColor(GetTheme().text) end
local function CurrentHpTextColor() local s=HealerPerformancePanel.settings; if s.useCustomColors and s.colHpText then return s.colHpText end return CloneColor(GetTheme().hptext) end
local function CurrentLvlColor() local s=HealerPerformancePanel.settings; if s.useCustomColors and s.colLvl then return s.colLvl end return CloneColor(GetTheme().lvl) end

local function RoleHpBarColor(roleKey)
  local s = HealerPerformancePanel.settings
  if s.useCustomColors then
    if roleKey=="TANK" and s.colHpBarTank then return s.colHpBarTank end
    if roleKey=="HEALER" and s.colHpBarHealer then return s.colHpBarHealer end
    if roleKey=="DPS" and s.colHpBarDps then return s.colHpBarDps end
    if s.colHpBarUnknown then return s.colHpBarUnknown end
  end
  local t = GetTheme()
  if roleKey=="TANK" then return CloneColor(t.hpbarTank) end
  if roleKey=="HEALER" then return CloneColor(t.hpbarHealer) end
  if roleKey=="DPS" then return CloneColor(t.hpbarDps) end
  return CloneColor(t.hpbarUnk)
end

local function RoleIconColor(roleKey)
  local s = HealerPerformancePanel.settings
  if s.useCustomColors then
    if roleKey=="TANK" and s.colIconTank then return s.colIconTank end
    if roleKey=="HEALER" and s.colIconHealer then return s.colIconHealer end
    if roleKey=="DPS" and s.colIconDps then return s.colIconDps end
    if s.colIconUnknown then return s.colIconUnknown end
  end
  local t = GetTheme()
  if roleKey=="TANK" then return CloneColor(t.iconTank) end
  if roleKey=="HEALER" then return CloneColor(t.iconHealer) end
  if roleKey=="DPS" then return CloneColor(t.iconDps) end
  return CloneColor(t.iconUnk)
end

local function GetSoundKeys() local t={} for i=1,#SOUND_PRESETS do t[#t+1]=SOUND_PRESETS[i].key end return t end
local function GetSoundLabels() local t={} for i=1,#SOUND_PRESETS do t[#t+1]=SOUND_PRESETS[i].label end return t end
local function SafeName(unitTag) if not unitTag or not DoesUnitExist(unitTag) then return "" end local name=(GetUnitDisplayName and GetUnitDisplayName(unitTag)) or GetUnitName(unitTag); return (name and name~="") and name or tostring(unitTag) end
local function GetDisplayLevel(unitTag) local cp=(GetUnitChampionPoints and GetUnitChampionPoints(unitTag)) or nil; if cp and cp>0 then return tostring(cp) end local lvl=(GetUnitLevel and GetUnitLevel(unitTag)) or 0; return tostring(lvl) end
local function HpInfo(unitTag) if not unitTag or not DoesUnitExist(unitTag) then return nil end local cur,max=GetUnitPower(unitTag, POWERTYPE_HEALTH); if not max or max<=0 then return nil end return (cur/max)*100.0,cur,max end
local function FormatK(n) if not n then return "0" end if n>=1000 then return string.format("%.1fk", n/1000):gsub("%.", ",") end return tostring(zo_round(n)) end
local function IsGroupUnitTag(unitTag) if unitTag==nil then return false end if unitTag=="player" then return true end local n=tonumber(string.match(unitTag, "^group(%d+)$") or ""); return (n~=nil and n>=1 and n<=12) end

local function GetRoleKey(unitTag)
  local roleVal = nil
  if unitTag=="player" and GetSelectedLFGRole then roleVal = GetSelectedLFGRole() end
  if roleVal==nil and GetGroupMemberSelectedRole then pcall(function() roleVal = GetGroupMemberSelectedRole(unitTag) end) end
  if roleVal==nil and GetGroupMemberAssignedRole then pcall(function() roleVal = GetGroupMemberAssignedRole(unitTag) end) end
  if (LFG_ROLE_DPS and roleVal==LFG_ROLE_DPS) or roleVal==1 or roleVal=="DPS" then return "DPS" end
  if (LFG_ROLE_TANK and roleVal==LFG_ROLE_TANK) or roleVal==2 or roleVal=="TANK" then return "TANK" end
  if (LFG_ROLE_HEAL and roleVal==LFG_ROLE_HEAL) or roleVal==4 or roleVal=="HEAL" or roleVal=="HEALER" then return "HEALER" end
  return "UNKNOWN"
end

local function EnsureDefaults(sv)
  sv.settings = sv.settings or {}
  local s = sv.settings
  if s.showWindow == nil then s.showWindow = true end
  if s.hideSelf == nil then s.hideSelf = false end
  if s.showRole == nil then s.showRole = true end
  if s.showLevel == nil then s.showLevel = true end
  if s.showMaxHp == nil then s.showMaxHp = false end
  if s.showHpPercent == nil then s.showHpPercent = true end
if s.hpTextMode == nil then
  -- derive from legacy toggles
  if s.showHpPercent and s.showMaxHp then s.hpTextMode = "PERCENT_MAX"
  elseif s.showHpPercent then s.hpTextMode = "PERCENT"
  elseif s.showMaxHp then s.hpTextMode = "CURRENT_MAX"
  else s.hpTextMode = "PERCENT" end
end
if s.hpTextScale == nil then s.hpTextScale = 100 end -- percent
if s.hpNumberCompact == nil then s.hpNumberCompact = false end
  if s.lowHpThresholdPct == nil then s.lowHpThresholdPct = 50 end
  if s.needHealThresholdPct == nil then s.needHealThresholdPct = 65 end
  if s.enableNeedHealMarker == nil then s.enableNeedHealMarker = true end
  if s.needHealMarkerSize == nil then s.needHealMarkerSize = 26 end
  if s.needHealMarkerYOffset == nil then s.needHealMarkerYOffset = 6 end
  if s.needHealWorldZOffset == nil then s.needHealWorldZOffset = 180 end
  if s.needHealMarkerTexture == nil then s.needHealMarkerTexture = "/esoui/art/compass/compass_waypoint.dds" end
  if s.needHealMarkerAlpha == nil then s.needHealMarkerAlpha = 1.0 end
  if s.needHealPulseOnShow == nil then s.needHealPulseOnShow = true end
  if s.needHealPulseDurationMs == nil then s.needHealPulseDurationMs = 1200 end
  if s.needHealPulsePeriodMs == nil then s.needHealPulsePeriodMs = 450 end
  if s.needHealPulseScale == nil then s.needHealPulseScale = 1.35 end
  if s.needHealPulseAlphaMin == nil then s.needHealPulseAlphaMin = 0.55 end
  if s.enableFastDropAlert == nil then s.enableFastDropAlert = true end
  if s.fastDropPctPerSec == nil then s.fastDropPctPerSec = 25 end
  if s.fastDropMinHpPct == nil then s.fastDropMinHpPct = 80 end
  if s.enableHpSound == nil then s.enableHpSound = true end
  if s.hpSoundCooldownMs == nil then s.hpSoundCooldownMs = 2000 end
  if s.hpSoundKey == nil then s.hpSoundKey = "GENERAL_ALERT_ERROR" end
  if s.hpSoundVolume == nil then s.hpSoundVolume = 1 end -- 1..10 (playsound multiplier)
  if s.hpSoundRepeats == nil then s.hpSoundRepeats = 1 end -- 1..10
  if s.hpSoundRepeatDelayMs == nil then s.hpSoundRepeatDelayMs = 120 end
  if s.enableDebuffSound == nil then s.enableDebuffSound = false end
  if s.debuffSoundCooldownMs == nil then s.debuffSoundCooldownMs = 1500 end
  if s.debuffSoundKey == nil then s.debuffSoundKey = "DUEL_START" end
  if s.debugDebuffs == nil then s.debugDebuffs = false end
  if s.testMode == nil then s.testMode = false end
  if s.testPct == nil then s.testPct = 35 end
  if s.testPulse == nil then s.testPulse = false end
  if s.testGroupMode == nil then s.testGroupMode = 0 end
  if s.panelWidth == nil then s.panelWidth = 980 end
  if s.rowHeight == nil then s.rowHeight = 40 end
  if s.hpTextWidth == nil then s.hpTextWidth = 170 end
  if s.fontSize == nil then s.fontSize = 22 end
  if s.panelScale == nil then s.panelScale = 100 end
  if s.compactMode == nil then s.compactMode = true end
  if s.themeName == nil then s.themeName = "Minimal Dark" end
  if s.roleIconSize == nil then s.roleIconSize = 26 end
  if s.leaderIconSize == nil then s.leaderIconSize = 22 end
  if s.fontFace == nil then s.fontFace = "AUTO" end
  if s.useCustomColors == nil then s.useCustomColors = false end

  local t = THEMES["Skyrim Amber"]
  if s.colTank == nil then s.colTank = CloneColor(t.tank) end
  if s.colHealer == nil then s.colHealer = CloneColor(t.healer) end
  if s.colDps == nil then s.colDps = CloneColor(t.dps) end
  if s.colUnknown == nil then s.colUnknown = CloneColor(t.unk) end
  if s.colEdge == nil then s.colEdge = CloneColor(t.edge) end
  if s.colText == nil then s.colText = CloneColor(t.text) end
  if s.colHpText == nil then s.colHpText = CloneColor(t.hptext) end
  if s.colLvl == nil then s.colLvl = CloneColor(t.lvl) end
  if s.colHpBarTank == nil then s.colHpBarTank = CloneColor(t.hpbarTank) end
  if s.colHpBarHealer == nil then s.colHpBarHealer = CloneColor(t.hpbarHealer) end
  if s.colHpBarDps == nil then s.colHpBarDps = CloneColor(t.hpbarDps) end
  if s.colHpBarUnknown == nil then s.colHpBarUnknown = CloneColor(t.hpbarUnk) end
  if s.colIconTank == nil then s.colIconTank = CloneColor(t.iconTank) end
  if s.colIconHealer == nil then s.colIconHealer = CloneColor(t.iconHealer) end
  if s.colIconDps == nil then s.colIconDps = CloneColor(t.iconDps) end
  if s.colIconUnknown == nil then s.colIconUnknown = CloneColor(t.iconUnk) end
  sv.watchlist = sv.watchlist or {}
  return s
end

local function FontBySize(sz)
  if sz >= 28 then return "ZoFontHeader2" end
  if sz >= 24 then return "ZoFontHeader3" end
  if sz >= 20 then return "ZoFontWinH4" end
  return "ZoFontGameLarge"
end

local function GetFontName()
  local s = HealerPerformancePanel.settings
  local face = s and s.fontFace or "AUTO"
  if face and face ~= "AUTO" and face ~= "" then return face end
  return FontBySize((s and s.fontSize) or 22)
end

-- ===== Layout: reserve space for header image, keep list below it =====
local function ApplyLayout()
  local win = HPP_Window
  if not win then return end

  local s = HealerPerformancePanel.settings
  local bg, title, sub, list = win:GetNamedChild("Bg"), win:GetNamedChild("Title"), win:GetNamedChild("Sub"), win:GetNamedChild("List")
  if bg then bg:SetHidden(true) end
  if title then title:SetHidden(true) end
  if sub then sub:SetHidden(true) end

  local width = s.panelWidth or 980
  local rowH = s.rowHeight or 40
  local rowsPerCol = s.compactMode and 6 or 12
  local listH = (rowH + 6) * rowsPerCol + 4
  local height = HEADER_SIZE + listH

  local perColW = s.compactMode and math.floor((width - 10) / 2) or width

  win:SetDimensions(width, height)

  local header = win:GetNamedChild("HeaderImage")
  if header then
    header:ClearAnchors()
    -- square image, centered horizontally
    header:SetAnchor(TOP, win, TOP, 0, 0)
    header:SetDimensions(HEADER_SIZE, HEADER_SIZE)
    header:SetHidden(false)
    if header.SetDrawLayer then header:SetDrawLayer(DL_OVERLAY) end
  end

  if list then
    list:ClearAnchors()
    list:SetAnchor(TOPLEFT, win, TOPLEFT, 0, HEADER_SIZE)
    list:SetDimensions(width, listH)
  end

  if win.SetScale then win:SetScale((s.panelScale or 100) / 100.0) end
  HealerPerformancePanel._layoutCache = { perColW = perColW, rowsPerCol = rowsPerCol, rowH = rowH }
end

-- ===== Window position persistence (drag & remember) =====
local function HPP_SaveWindowPos()
  local win = HPP_Window
  if not win or not HealerPerformancePanel or not HealerPerformancePanel.saved then return end
  -- Store screen position (TOPLEFT offsets relative to GuiRoot)
  local left = win:GetLeft() or 0
  local top  = win:GetTop() or 0
  HealerPerformancePanel.saved.winLeft = zo_round(left)
  HealerPerformancePanel.saved.winTop  = zo_round(top)
end

local function HPP_RestoreWindowPos()
  local win = HPP_Window
  if not win or not HealerPerformancePanel or not HealerPerformancePanel.saved then return end
  local x = HealerPerformancePanel.saved.winLeft
  local y = HealerPerformancePanel.saved.winTop
  if type(x) ~= "number" or type(y) ~= "number" then return end
  win:ClearAnchors()
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function HPP_HookWindowDrag()
  local win = HPP_Window
  if not win then return end
  if win._hppDragHooked then return end
  win._hppDragHooked = true
  win:SetHandler("OnMoveStop", function()
    HPP_SaveWindowPos()
  end)
end


-- ===== rest of your code below is unchanged (copied from your v0.2.6) =====

local function GetOrCreateRow(list, idx)
  list.rows = list.rows or {}
  local row = list.rows[idx]
  if not row then
    row = CreateControlFromVirtual("HPP_Row" .. idx, list, "HPP_RowTemplate")
    list.rows[idx] = row
  end

  local s = HealerPerformancePanel.settings
  local L = HealerPerformancePanel._layoutCache or {}
  local perColW = L.perColW or (s.panelWidth or 980)
  local rowH = L.rowH or (s.rowHeight or 40)
  local rowsPerCol = L.rowsPerCol or 12
  local col = math.floor((idx - 1) / rowsPerCol)
  local rowIdx = (idx - 1) % rowsPerCol
  local x = col * (perColW + (s.compactMode and 10 or 0))
  local y = rowIdx * (rowH + 6)
  local font = GetFontName()

  row:SetHidden(false)
  row:ClearAnchors()
  row:SetAnchor(TOPLEFT, list, TOPLEFT, x, y)
  row:SetDimensions(perColW, rowH)

  local hpBar = row:GetNamedChild("HpBar")
  local level = row:GetNamedChild("Level")
  local roleIcon = row:GetNamedChild("RoleIcon")
  local leaderIcon = row:GetNamedChild("LeaderIcon")
  local name = row:GetNamedChild("Name")
  local hpText = row:GetNamedChild("HpText")
  local d1, d2, d3 = row:GetNamedChild("Debuff1"), row:GetNamedChild("Debuff2"), row:GetNamedChild("Debuff3")

  if hpBar then hpBar:ClearAnchors(); hpBar:SetAnchor(TOPLEFT,row,TOPLEFT,0,0); hpBar:SetAnchor(BOTTOMRIGHT,row,BOTTOMRIGHT,0,0); hpBar:SetMinMax(0,100) end

  local leftX = 10
  if level then
    level:SetHidden(not s.showLevel)
    level:SetFont(font)
    level:ClearAnchors()
    level:SetAnchor(LEFT, row, LEFT, leftX, 0)
    level:SetDimensions(52, rowH)
    if level.SetDrawLayer then level:SetDrawLayer(DL_OVERLAY) end
    if s.showLevel then leftX = leftX + 52 + 2 end
  end

  if leaderIcon then
    local lsz = math.max(16, s.leaderIconSize or 22)
    leaderIcon:SetDimensions(lsz, lsz)
    leaderIcon:SetTexture(LEADER_ICON)
    if leaderIcon.SetDrawLayer then leaderIcon:SetDrawLayer(DL_OVERLAY) end
  end

  if roleIcon then
    roleIcon:SetHidden(not s.showRole)
    local rsz = math.max(18, s.roleIconSize or 26)
    roleIcon:SetDimensions(rsz, rsz)
    roleIcon:ClearAnchors()
    roleIcon:SetAnchor(LEFT, row, LEFT, leftX, 0)
    if roleIcon.SetDrawLayer then roleIcon:SetDrawLayer(DL_OVERLAY) end
    if s.showRole then leftX = leftX + rsz + 4 end
  end

  local hpTextW = s.hpTextWidth or 170
  if hpText then
    hpText:SetFont(font)
    hpText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hpText:ClearAnchors()
    hpText:SetAnchor(RIGHT, row, RIGHT, -10, 0)
    hpText:SetDimensions(hpTextW, rowH)
    if hpText.SetScale then hpText:SetScale((s.hpTextScale or 100) / 100.0) end
    hpText:SetHidden((s.hpTextMode or "PERCENT") == "OFF")
    if hpText.SetDrawLayer then hpText:SetDrawLayer(DL_OVERLAY) end
  end

  if name then
    name:SetFont(font)
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:ClearAnchors()
    name:SetAnchor(LEFT, row, LEFT, leftX, 0)
    name:SetDimensions(math.max(80, perColW - leftX - hpTextW - 90), rowH)
    if name.SetDrawLayer then name:SetDrawLayer(DL_OVERLAY) end
  end

  local iconSize = math.max(14, rowH - 18)
  if d1 and d2 and d3 and hpText then
    d1:SetDimensions(iconSize, iconSize); d2:SetDimensions(iconSize, iconSize); d3:SetDimensions(iconSize, iconSize)
    d1:ClearAnchors(); d2:ClearAnchors(); d3:ClearAnchors()
    d1:SetAnchor(RIGHT, hpText, LEFT, -6, 0)
    d2:SetAnchor(RIGHT, d1, LEFT, -3, 0)
    d3:SetAnchor(RIGHT, d2, LEFT, -3, 0)
    if d1.SetDrawLayer then d1:SetDrawLayer(DL_OVERLAY); d2:SetDrawLayer(DL_OVERLAY); d3:SetDrawLayer(DL_OVERLAY) end
  end
  return row
end

local function HideExtraRows(list, used) if not list.rows then return end for i=used+1,#list.rows do if list.rows[i] then list.rows[i]:SetHidden(true) end end end

local function ThemeRowBase(row, roleKey)
  local s = HealerPerformancePanel.settings
  local bg = row:GetNamedChild("RowBg")
  local level = row:GetNamedChild("Level")
  local roleIcon = row:GetNamedChild("RoleIcon")
  local leaderIcon = row:GetNamedChild("LeaderIcon")
  local name = row:GetNamedChild("Name")
  local hpText = row:GetNamedChild("HpText")
  local hpBar = row:GetNamedChild("HpBar")
  if not bg then return end
  local panel, edge = RolePanelColor(roleKey), CurrentEdgeColor()
  local txt, hpTxt, lvlTxt = CurrentTextColor(), CurrentHpTextColor(), CurrentLvlColor()
  local hpbar, ic = RoleHpBarColor(roleKey), RoleIconColor(roleKey)

  bg:SetCenterColor(panel[1], panel[2], panel[3], panel[4])
  bg:SetEdgeColor(edge[1], edge[2], edge[3], edge[4])
  if hpBar then hpBar:SetColor(hpbar[1], hpbar[2], hpbar[3], hpbar[4]); hpBar:SetAlpha(1.0) end
  if level then level:SetColor(lvlTxt[1], lvlTxt[2], lvlTxt[3], lvlTxt[4]) end
  if name then name:SetColor(txt[1], txt[2], txt[3], txt[4]) end
  if hpText then hpText:SetColor(hpTxt[1], hpTxt[2], hpTxt[3], hpTxt[4]) end
  if leaderIcon then
    local lsz = math.max(16, s.leaderIconSize or 22)
    leaderIcon:SetDimensions(lsz, lsz)
    leaderIcon:SetTexture(LEADER_ICON)
    if leaderIcon.SetDrawLayer then leaderIcon:SetDrawLayer(DL_OVERLAY) end
  end

  if roleIcon then
    local rk = roleKey or "UNKNOWN"
    roleIcon:SetTexture(ROLE_ICON[rk] or ROLE_ICON.UNKNOWN)
    roleIcon:SetHidden((not HealerPerformancePanel.settings.showRole) or rk=="UNKNOWN")
    roleIcon:SetColor(ic[1], ic[2], ic[3], ic[4])
  end
end

local function UpdateLeaderIcon(row, unitTag, isFake)
  local ico = row:GetNamedChild("LeaderIcon")
  if not ico then return end
  if isFake or not unitTag or unitTag=="" then ico:SetHidden(true); return end
  local leaderTag = (GetGroupLeaderUnitTag and GetGroupLeaderUnitTag()) or nil
  local isLeader = false
  if leaderTag then isLeader = (leaderTag == unitTag) end
  if (not isLeader) and IsUnitGroupLeader then pcall(function() isLeader = IsUnitGroupLeader(unitTag) end) end
  ico:SetHidden(not isLeader)
end

local function SetRowAlertVisual(row, mode, flashOn, roleKey)
  local bg = row:GetNamedChild("RowBg")
  local hpBar = row:GetNamedChild("HpBar")
  ThemeRowBase(row, roleKey)
  if not bg or not hpBar then return end
  if mode == "low" then bg:SetAlpha(flashOn and 1.0 or 0.35); hpBar:SetColor(0.92, 0.15, 0.15, 1.0)
  elseif mode == "drop" then bg:SetAlpha(flashOn and 0.95 or 0.45); hpBar:SetColor(1.00, 0.55, 0.10, 1.0)
  else bg:SetAlpha(1.0) end
end

local function EnsureDebuffTable() HealerPerformancePanel.activeDebuffs = HealerPerformancePanel.activeDebuffs or {}; return HealerPerformancePanel.activeDebuffs end
local function UpdateDebuffIcons(row, unitTag, isFake)
  local tex1, tex2, tex3 = row:GetNamedChild("Debuff1"), row:GetNamedChild("Debuff2"), row:GetNamedChild("Debuff3")
  if not tex1 or not tex2 or not tex3 then return end
  tex1:SetHidden(true); tex2:SetHidden(true); tex3:SetHidden(true)
  if isFake then return end
  local watch = HealerPerformancePanel.saved.watchlist or {}
  local u = EnsureDebuffTable()[unitTag]; if not u then return end
  local nowMs = GetGameTimeMilliseconds(); local arr = {}
  for abilityId, data in pairs(u) do
    if watch[abilityId] and data and data.icon then
      local endMs = (data.endTimeS or 0) * 1000
      if endMs == 0 or endMs > nowMs - 200 then arr[#arr+1] = { icon = data.icon, endMs = endMs } end
    end
  end
  table.sort(arr, function(a,b) return (a.endMs or 0) < (b.endMs or 0) end)
  if arr[1] then tex1:SetTexture(arr[1].icon); tex1:SetHidden(false) end
  if arr[2] then tex2:SetTexture(arr[2].icon); tex2:SetHidden(false) end
  if arr[3] then tex3:SetTexture(arr[3].icon); tex3:SetHidden(false) end
end

local function CanPlay(kind, unitTag)
  HealerPerformancePanel.soundThrottle = HealerPerformancePanel.soundThrottle or {}
  HealerPerformancePanel.soundThrottle[kind] = HealerPerformancePanel.soundThrottle[kind] or {}
  local map = HealerPerformancePanel.soundThrottle[kind]
  local now = GetGameTimeMilliseconds()
  local last = map[unitTag] or 0
  local cd = (kind == "hp") and (HealerPerformancePanel.settings.hpSoundCooldownMs or 2000) or (HealerPerformancePanel.settings.debuffSoundCooldownMs or 1500)
  if (now - last) >= cd then map[unitTag] = now; return true end
  return false
end
local function PlayPresetSound(soundKey)
  if SOUNDS and soundKey and SOUNDS[soundKey] then
    PlaySound(SOUNDS[soundKey])
  end
end

-- Note: ESO does not provide per-sound volume control. A common workaround is to play the same UI sound
-- multiple times to make it louder (may not work for every sound). See ESOUI dev discussions.
local function PlayPresetSoundAdvanced(soundKey, volumeTimes, repeats, repeatDelayMs)
  if not (SOUNDS and soundKey and SOUNDS[soundKey]) then return end
  volumeTimes = zo_clamp(tonumber(volumeTimes) or 1, 1, 10)
  repeats = zo_clamp(tonumber(repeats) or 1, 1, 10)
  repeatDelayMs = zo_clamp(tonumber(repeatDelayMs) or 0, 0, 2000)

  local function DoPlayOnce()
    for _=1, volumeTimes do
      PlaySound(SOUNDS[soundKey])
    end
  end

  DoPlayOnce()
  if repeats > 1 and repeatDelayMs > 0 then
    for i=2, repeats do
      zo_callLater(DoPlayOnce, (i-1) * repeatDelayMs)
    end
  elseif repeats > 1 then
    -- No delay: just play sequentially (can be very loud)
    for _=2, repeats do DoPlayOnce() end
  end
end

local function PlayHpAlert()
  local s = HealerPerformancePanel.settings
  if s.enableHpSound then
    PlayPresetSoundAdvanced(s.hpSoundKey, s.hpSoundVolume, s.hpSoundRepeats, s.hpSoundRepeatDelayMs)
  end
end

local function PlayDebuffAlert()
  local s = HealerPerformancePanel.settings
  if s.enableDebuffSound then
    PlayPresetSoundAdvanced(s.debuffSoundKey, s.debuffSoundVolume, s.debuffSoundRepeats, s.debuffSoundRepeatDelayMs)
  end
end

local function TrackDrop(key, pct)
  HealerPerformancePanel.hpHistory = HealerPerformancePanel.hpHistory or {}
  local h = HealerPerformancePanel.hpHistory[key]; local now = GetGameTimeMilliseconds()
  if not h then HealerPerformancePanel.hpHistory[key] = { pct = pct, t = now }; return 0 end
  local dt = math.max(1, now - (h.t or now)); local dp = (h.pct or pct) - pct
  h.pct = pct; h.t = now
  return (dp * 1000.0) / dt
end

local function MakeFakeMembers(count)
  local list = {}
  local function add(role,name,lvl,maxHp,idx) list[#list+1]={ fake=true, fakeId="fake"..idx, tag="fake"..idx, name=name, roleKey=role, fakeLevel=tostring(lvl), fakeMax=maxHp, fakePct=100 } end
  if count==4 then add("TANK","@Танк_Тест",910,38500,1); add("HEALER","@Хіл_Тест",720,26000,2); add("DPS","@ДД_Тест_1",980,22000,3); add("DPS","@ДД_Тест_2",640,23500,4)
  elseif count==12 then add("TANK","@Tank_A",1000,41000,1); add("TANK","@Tank_B",880,37000,2); add("HEALER","@Heal_A",930,27000,3); add("HEALER","@Heal_B",760,25500,4); for i=1,8 do add("DPS","@DD_"..i,500+i*40,21000+i*1200,4+i) end end
  return list
end

local function BuildMemberList()
  local s = HealerPerformancePanel.settings
  if (s.testGroupMode or 0) > 0 then return MakeFakeMembers(s.testGroupMode) end
  local members, seen = {}, {}
  if not s.hideSelf and DoesUnitExist("player") then local n = SafeName("player"); members[#members+1] = { tag="player", name=n, roleKey=GetRoleKey("player") }; seen[n]=true end
  if IsUnitGrouped("player") then
    for i=1,12 do
      local tag = "group" .. tostring(i)
      if DoesUnitExist(tag) then
        -- Skip members that are offline / in another zone where HP data is unavailable.
        if IsUnitOnline == nil or IsUnitOnline(tag) then
          local hpPct = HpInfo(tag)
          if hpPct ~= nil then
            local n = SafeName(tag)
            if not (n ~= "" and seen[n]) then
              members[#members+1] = { tag=tag, name=n, roleKey=GetRoleKey(tag) }
              seen[n]=true
            end
          end
        end
      end
    end
  end
  for i=1,#members do members[i].roleOrder = ROLE_ORDER[members[i].roleKey] or 4 end
  table.sort(members, function(a,b) if a.roleOrder ~= b.roleOrder then return a.roleOrder < b.roleOrder end return (a.name or "") < (b.name or "") end)
  return members
end

local function GetDisplayPct(member)
  local s = HealerPerformancePanel.settings
  if member.fake then
    local base = 100
    local now = GetGameTimeMilliseconds()
    if s.testPulse then
      local phase = (member.roleKey=="TANK") and 0 or ((member.roleKey=="HEALER") and 1.1 or 2.2)
      local wave = (math.sin((now/420.0)+phase+(tonumber(string.match(member.fakeId,"%d+")) or 1))+1.0)*0.5
      if member.roleKey=="TANK" then base = 70 + wave*28 elseif member.roleKey=="HEALER" then base = 55 + wave*40 else base = 35 + wave*60 end
    else base = s.testPct or 35 end
    member.fakePct = zo_clamp(base,1,100); return member.fakePct
  end
  local pct = HpInfo(member.tag); if not pct then return nil end
  if member.tag == "player" and s.testMode then
    local v = s.testPct or 35
    if s.testPulse then local now = GetGameTimeMilliseconds(); local wave = (math.sin(now/350.0)+1.0)*0.5; v = math.floor((20+wave*65)+0.5) end
    return v
  end
  return pct
end

local function ComposeName(member) local text = member.fake and member.name or SafeName(member.tag); if (not member.fake) and member.tag=="player" and HealerPerformancePanel.settings.testMode then text=text.." [ТЕСТ]" end return text end
local function ComposeLevel(member) if member.fake then return tostring(member.fakeLevel or 0) end return GetDisplayLevel(member.tag) end
local function ComposeHpText(member, pct)
  local s = HealerPerformancePanel.settings
  local cur, max
  if member.fake then
    max = member.fakeMax or 26000
    cur = max * (pct / 100.0)
  else
    local _, c, m = HpInfo(member.tag)
    cur, max = c, m
    if member.tag == "player" and s.testMode then
      local fakeMax = max or 26400
      cur = fakeMax * (pct / 100.0)
      max = fakeMax
    end
  end

  local mode = s.hpTextMode or "PERCENT"
  if mode == "OFF" then return "" end

  local function HpNum(n)
    if not n then return "0" end
    if s.hpNumberCompact then return FormatK(n) end
    return tostring(zo_round(n))
  end

  local pctText = string.format("%d%%", zo_round(pct))
  local curText = cur and HpNum(cur) or nil
  local maxText = max and HpNum(max) or nil

  -- Legacy fallback if some data missing
  if not curText or not maxText then
    if mode == "CURRENT" or mode == "CURRENT_PERCENT" or mode == "CURRENT_MAX" or mode == "PERCENT_MAX" then
      return pctText
    end
  end

  if mode == "PERCENT" then
    return pctText
  elseif mode == "CURRENT" then
    return curText
  elseif mode == "CURRENT_PERCENT" then
    return string.format("%s  %s", curText, pctText)
  elseif mode == "CURRENT_MAX" then
    return string.format("%s/%s", curText, maxText)
  elseif mode == "PERCENT_MAX" then
    return string.format("%s  %s/%s", pctText, curText, maxText)
  else
    -- Safety: preserve old behavior
    local parts = {}
    if s.showHpPercent then parts[#parts+1] = pctText end
    if s.showMaxHp and curText and maxText then parts[#parts+1] = string.format("%s/%s", curText, maxText) end
    if #parts == 0 then return pctText end
    return table.concat(parts, "  ")
  end
end


local HPP_SetNeedHeal
local HPP_ScanVisibleNameplates

local function RefreshUI()
  local win = HPP_Window; if not win then return end
  win:SetHidden(not HealerPerformancePanel.settings.showWindow)
  local list = win:GetNamedChild("List"); if not list then return end
  local members = BuildMemberList()
  local now = GetGameTimeMilliseconds()
  local flashOn = (math.floor(now / FLASH_PERIOD_MS) % 2) == 0
  local lowTh = HealerPerformancePanel.settings.lowHpThresholdPct or 50
  local fastDrop = HealerPerformancePanel.settings.fastDropPctPerSec or 25
  local fastMin = HealerPerformancePanel.settings.fastDropMinHpPct or 80
  local needTh = HealerPerformancePanel.settings.needHealThresholdPct or 65
  local markerEnabled = HealerPerformancePanel.settings.enableNeedHealMarker

  local used = 0
  for i=1,#members do
    local m = members[i]
    if m.fake or DoesUnitExist(m.tag) then
      used = used + 1
      local row = GetOrCreateRow(list, used)
      UpdateLeaderIcon(row, m.tag, m.fake)
      local lvl, nameLabel, hpBar, hpText = row:GetNamedChild("Level"), row:GetNamedChild("Name"), row:GetNamedChild("HpBar"), row:GetNamedChild("HpText")
      local pct = GetDisplayPct(m)
      if lvl and HealerPerformancePanel.settings.showLevel then lvl:SetText(ComposeLevel(m)) end
      if not pct then
        if nameLabel then nameLabel:SetText(m.fake and m.name or SafeName(m.tag)) end
        if hpBar then hpBar:SetMinMax(0,100); hpBar:SetValue(0) end
        if hpText then hpText:SetText("--") end
        SetRowAlertVisual(row, "normal", flashOn, m.roleKey)
      else
        if nameLabel then nameLabel:SetText(ComposeName(m)) end
        if hpBar then hpBar:SetMinMax(0,100); hpBar:SetValue(pct) end
        if hpText then hpText:SetText(ComposeHpText(m, pct)) end
        local mode = "normal"
        local dropPerSec = TrackDrop(m.fake and m.fakeId or m.tag, pct)
        if pct <= lowTh then mode = "low"
        elseif HealerPerformancePanel.settings.enableFastDropAlert and pct <= fastMin and dropPerSec >= fastDrop then mode = "drop" end
        if (not m.fake) and mode ~= "normal" and CanPlay("hp", m.tag) then PlayHpAlert() end
        SetRowAlertVisual(row, mode, flashOn, m.roleKey)
      end
      -- Nameplate "need heal" marker (above HP bar)
      if markerEnabled and (not m.fake) then
        -- respect hideSelf (panel hides player -> marker also off)
        local allow = not (m.tag == "player" and HealerPerformancePanel.settings.hideSelf)
        local showNeed = false
        if allow and pct and pct <= needTh then showNeed = true end
        HPP_SetNeedHeal(m.tag, showNeed)
      elseif (not m.fake) then
        -- marker feature disabled -> hide if it was shown before
        HPP_SetNeedHeal(m.tag, false)
      end

      UpdateDebuffIcons(row, m.tag, m.fake)
    end
  end
  HideExtraRows(list, used)

  if markerEnabled then
    HPP_TickWorldMarkers(now)
  end
end


-- ==========================================================
-- ==========================================================
-- Need-Heal marker ABOVE CHARACTERS (world-space) via LibImplex
-- Works even when ESO nameplate UI is not accessible.
-- Requires: LibImplex (library). If missing, feature quietly disables and shows a reminder.
-- ==========================================================

local HPP_WorldMarkers = {}
local HPP_WorldMarkersVisible = {} -- [unitTag] = bool

local HPP_WorldMarkersShown = {}   -- [unitTag] = bool (requested shown last tick)
local HPP_WorldMarkersPulseStart = {} -- [unitTag] = ms when shown


local function HPP_Dbg(nowMs, msg)
  if not HPP_HealMarker.debug then return end
  if nowMs and nowMs < (HPP_HealMarker._nextDbgAt or 0) then return end
  if nowMs then HPP_HealMarker._nextDbgAt = nowMs + 1200 end
  d("|c66ccffHPP DBG|r " .. tostring(msg))
end


local function HPP_DumpImplexObjects()
  if not LibImplex or not LibImplex.Objects then
    d("|c66ccffHPP DBG|r LibImplex.Objects missing")
    return
  end
  local keys = {}
  for k,_ in pairs(LibImplex.Objects) do keys[#keys+1] = tostring(k) end
  table.sort(keys)
  d("|c66ccffHPP DBG|r LibImplex.Objects keys: " .. table.concat(keys, ", "))
end

local function HPP_HasLibImplex()
  return LibImplex and LibImplex.Objects and (LibImplex.Objects.Marker2D ~= nil or LibImplex.Objects.Marker2DWS ~= nil)
end


local HPP_MARKER_TEXTURES = {
  { name = "Waypoint", path = "/esoui/art/compass/compass_waypoint.dds" },
  { name = "Warning", path = "/esoui/art/miscellaneous/eso_icon_warning.dds" },
  { name = "Healer role", path = "/esoui/art/lfg/lfg_roleicon_healer.dds" },
  { name = "Crosshair", path = "/esoui/art/hud/gamepad/gp_crosshair.dds" },
  { name = "Star (reticle)", path = "/esoui/art/hud/reticle_star.dds" },
  { name = "Quest pin", path = "/esoui/art/compass/quest_icon_assisted.dds" },
  { name = "Skull", path = "/esoui/art/icons/mapkey/mapkey_groupboss.dds" },
  { name = "Crown", path = "/esoui/art/icons/mapkey/mapkey_groupleader.dds" },
  { name = "Shield", path = "/esoui/art/icons/mapkey/mapkey_keep.dds" },
  { name = "Plus", path = "/esoui/art/hud/gamepad/gp_plus_large.dds" },
  { name = "Square", path = "/esoui/art/miscellaneous/white_icon.dds" }, -- can be tinted
}
local function HPP_GetMarkerTexture()
  local s = HealerPerformancePanel.settings
  -- Start with a very visible system icon; can be changed in settings.
  return (s and s.needHealMarkerTexture) or "/esoui/art/compass/compass_waypoint.dds"
end

local function HPP_DeleteWorldMarker(unitTag)
  local mk = HPP_WorldMarkers[unitTag]
  if not mk then return end

  -- LibImplex Object2DWS doesn't support SetHidden/SetAlpha reliably.
  -- Instead, "park" the marker far below the world and shrink it.
  local ok = pcall(function()
    if mk.SetDimensions then mk:SetDimensions(1, 1) end
    if mk.SetTexture then mk:SetTexture("/esoui/art/blank.dds") end
    if mk.SetPosition then
      local _, px, py, pz = GetUnitWorldPosition("player")
      if px and not (px == 0 and py == 0 and pz == 0) then
        mk:SetPosition(px, py, pz - 100000)

    -- Billboard: rotate marker to face the camera so you don't see its edge/profile
    local mode = (s and s.needHealMarkerBillboardMode) or ((s and s.needHealMarkerFaceCamera) and "FULL") or "OFF"
    if mode ~= "OFF" and LibImplex and LibImplex.Camera and LibImplex.Camera.GetOrientation and mk.SetRotation then
      local pitch, yaw, roll = LibImplex.Camera.GetOrientation()
      if mode == "YAW" then
        mk:SetRotation(0, yaw, 0)
      else -- FULL
        -- roll=0 to avoid icon "spinning" when rotating camera
        mk:SetRotation(pitch, yaw, 0)
      end
    end

      else
        mk:SetPosition(0, 0, -100000)
      end
    end
  end)

  if not ok and mk.Delete then
    -- fallback if parking fails
    pcall(function() mk:Delete() end)
  end

  HPP_WorldMarkersVisible[unitTag] = false
  HPP_WorldMarkersShown[unitTag] = false
  HPP_WorldMarkersPulseStart[unitTag] = nil
end

local function HPP_DeleteAllWorldMarkers()
  for ut, mk in pairs(HPP_WorldMarkers) do
    -- try real delete when clearing
    if mk and mk.Delete then pcall(function() mk:Delete() end) end
    HPP_WorldMarkers[ut] = nil
    HPP_WorldMarkersVisible[ut] = nil
    HPP_WorldMarkersShown[ut] = nil
    HPP_WorldMarkersPulseStart[ut] = nil
  end
end

local function HPP_GetUnitWorldPos(unitTag)
  if not unitTag or not DoesUnitExist(unitTag) then return nil end
  local _, x, y, z = GetUnitWorldPosition(unitTag)
  if not x then return nil end
  if x == 0 and y == 0 and z == 0 then return nil end
  return x, y, z
end

local function HPP_EnsureWorldMarker(unitTag)
  if not HPP_HasLibImplex() then return nil end
  local mk = HPP_WorldMarkers[unitTag]
  if mk then return mk end

  local s = HealerPerformancePanel.settings
  local size = (s and s.needHealMarkerSize) or 64
  local tex  = HPP_GetMarkerTexture()

  local ctor =
      (LibImplex.Objects and (
        LibImplex.Objects.Marker2D or LibImplex.Objects.Marker2DWS or
        LibImplex.Objects.Marker2DWorld or LibImplex.Objects.Marker2D_World or
        LibImplex.Objects.Marker2DWSv2 or LibImplex.Objects.Marker2D_WS or
        LibImplex.Objects.WorldMarker2D or LibImplex.Objects.MarkerWS2D
      ))
  if not ctor then
    HPP_Dbg(GetGameTimeMilliseconds(), "No known 2D marker ctor. Use /hppmk dump")
    return nil
  end
  -- ctor may be a function or a table with :New()
  if type(ctor) == "table" and ctor.New then
    mk = ctor:New()
  else
    mk = ctor()
  end
  -- Apply appearance
  if mk and mk.SetTexture then mk:SetTexture(tex) end
  if mk and mk.SetDimensions then mk:SetDimensions(size, size) end
HPP_WorldMarkers[unitTag] = mk
  HPP_WorldMarkersVisible[unitTag] = true
  if mk and mk.SetHidden then pcall(function() mk:SetHidden(false) end) end
  if mk and mk.SetAlpha then pcall(function() mk:SetAlpha(1) end) end
  return mk
end

local function HPP_UpdateWorldMarker(unitTag, shouldShow)
  if not HPP_HasLibImplex() then return end

  local nowMs = GetGameTimeMilliseconds()
  local wasShown = (HPP_WorldMarkersShown[unitTag] == true)
  if shouldShow and (not wasShown) then
    -- first frame of showing -> start pulse
    local s = HealerPerformancePanel.settings
    if s and s.needHealPulseOnShow then
      HPP_WorldMarkersPulseStart[unitTag] = nowMs
    end
  end
  HPP_WorldMarkersShown[unitTag] = shouldShow and true or false

  if not shouldShow then
    HPP_DeleteWorldMarker(unitTag, false)
    return
  end

  local mk = HPP_EnsureWorldMarker(unitTag)
  if not mk then return end

  -- Ensure visible
  if HPP_WorldMarkersVisible[unitTag] ~= true then
    if mk.SetHidden then pcall(function() mk:SetHidden(false) end) end
    if mk.SetAlpha then pcall(function() mk:SetAlpha(1) end) end
    HPP_WorldMarkersVisible[unitTag] = true
  end

  local x, y, z = HPP_GetUnitWorldPos(unitTag)
  if not x then
    HPP_Dbg(GetGameTimeMilliseconds(), "No world pos for " .. tostring(unitTag) .. " (exists="..tostring(DoesUnitExist(unitTag))..")")
    return
  end

  local s = HealerPerformancePanel.settings
  local zOff = (s and s.needHealWorldZOffset) or 220
  local size = (s and s.needHealMarkerSize) or 64
  local tex  = HPP_GetMarkerTexture()

  -- Pulse (on show): temporary size/alpha animation for better visibility
  local baseSize = size
  local alphaMul = 1.0
  local sPulse = HealerPerformancePanel.settings
  local start = HPP_WorldMarkersPulseStart[unitTag]
  if sPulse and sPulse.needHealPulseOnShow and start then
    local dur = tonumber(sPulse.needHealPulseDurationMs) or 1200
    local per = tonumber(sPulse.needHealPulsePeriodMs) or 450
    if dur > 0 and (nowMs - start) <= dur then
      if per < 40 then per = 40 end
      local phase = ((nowMs - start) % per) / per
      local t = (math.sin(phase * 2 * math.pi) * 0.5) + 0.5 -- 0..1
      local scale = tonumber(sPulse.needHealPulseScale) or 1.35
      if scale < 1.0 then scale = 1.0 end
      size = zo_round(baseSize * (1.0 + (scale - 1.0) * t))
      local aMin = tonumber(sPulse.needHealPulseAlphaMin) or 0.55
      if aMin < 0.05 then aMin = 0.05 end
      if aMin > 1.0 then aMin = 1.0 end
      alphaMul = aMin + (1.0 - aMin) * t
    else
      HPP_WorldMarkersPulseStart[unitTag] = nil
    end
  end

  local ok, err = pcall(function()
    if mk.SetTexture then mk:SetTexture(tex) end
    if mk.SetDimensions then mk:SetDimensions(size, size) end
    if mk.SetPosition then
        local ax = (s and s.needHealMarkerVerticalAxis) or "Y"
        if ax == "Z" then
          mk:SetPosition(x, y, z + zOff)
        else
          mk:SetPosition(x, y + zOff, z)
        end
      end

    local r = (s and s.needHealMarkerColorR) or 1
    local g = (s and s.needHealMarkerColorG) or 1
    local b = (s and s.needHealMarkerColorB) or 1
    local a = (s and s.needHealMarkerColorA) or 1
    if mk.SetColor then mk:SetColor(r, g, b, a) end
    local baseAlpha = (s and s.needHealMarkerAlpha) or 1.0
    local finalAlpha = baseAlpha * alphaMul
    if mk.SetAlpha then mk:SetAlpha(finalAlpha) else
      -- fallback: bake alpha into tint (if supported)
      if mk.SetColor then mk:SetColor(r, g, b, a * finalAlpha) end
    end

  end)

  if not ok then
    HPP_Dbg(GetGameTimeMilliseconds(), "SetPosition failed for "..tostring(unitTag)..": "..tostring(err).." -> recreate")
    HPP_DeleteWorldMarker(unitTag, true)
    mk = HPP_EnsureWorldMarker(unitTag)
    if not mk then return end
    HPP_WorldMarkersVisible[unitTag] = true
    pcall(function()
      if mk.SetHidden then mk:SetHidden(false) end
      if mk.SetTexture then mk:SetTexture(tex) end
      if mk.SetDimensions then mk:SetDimensions(size, size) end
      local baseAlpha = (s and s.needHealMarkerAlpha) or 1.0
      local finalAlpha = baseAlpha * alphaMul
      if mk.SetAlpha then mk:SetAlpha(finalAlpha) end
      if mk.SetPosition then
        local ax = (s and s.needHealMarkerVerticalAxis) or "Y"
        if ax == "Z" then
          mk:SetPosition(x, y, z + zOff)
        else
          mk:SetPosition(x, y + zOff, z)
        end
      end
    end)
end
end

-- Public setter used by RefreshUI
HPP_SetNeedHeal = function(unitTag, shouldShow)
  if shouldShow then
    HPP_HealMarker.desired[unitTag] = true
    local s = HealerPerformancePanel.settings
    local linger = (s and s.needHealLingerMs) or 0
    if linger and linger > 0 then
      HPP_HealMarker.untilMs[unitTag] = GetGameTimeMilliseconds() + linger
    else
      HPP_HealMarker.untilMs[unitTag] = nil
    end
  else
    HPP_HealMarker.desired[unitTag] = nil
    HPP_HealMarker.untilMs[unitTag] = nil

  end
  if HPP_HasLibImplex() then
    HPP_UpdateWorldMarker(unitTag, shouldShow)
  end
end

-- Called each UI tick to keep markers following moving units
HPP_TickWorldMarkers = function(nowMs)
  local s = HealerPerformancePanel.settings
  if not s.enableNeedHealMarker then
    if next(HPP_WorldMarkers) ~= nil then HPP_DeleteAllWorldMarkers() end
-- Separate high-frequency updater for world markers (so the icon follows smoothly).
local function HPP_StartMarkerLoop()
  local s = HealerPerformancePanel.settings
  local ms = (s and s.needHealMarkerUpdateMs) or 50
  if ms < 1 then ms = 1 end
  if ms > 250 then ms = 250 end

  EVENT_MANAGER:UnregisterForUpdate(ADDON .. "_MARKER_UPDATE")
  EVENT_MANAGER:RegisterForUpdate(ADDON .. "_MARKER_UPDATE", ms, function()
    local now = GetGameTimeMilliseconds()
    -- While visible, keep updating positions
    for ut, mk in pairs(HPP_WorldMarkers) do
      if HPP_WorldMarkersVisible[ut] then
        HPP_UpdateWorldMarker(ut, true)
      end
    end
  end)
end

    return
  end

  if not HPP_HasLibImplex() then
    if not HPP_HealMarker._warnedAt or (nowMs - HPP_HealMarker._warnedAt) > 5000 then
      HPP_HealMarker._warnedAt = nowMs
      d("|c66ccffHPP|r Для міток над персонажами потрібна бібліотека |cffffffLibImplex|r (встанови через Minion).")
    end
    return
  end


  -- Debug/test helpers: force markers even without HP trigger
  if HPP_HealMarker.testAll then
    for i=1,12 do
      local ut = "group"..tostring(i)
      if DoesUnitExist(ut) then HPP_HealMarker.desired[ut] = true end
    end
    if DoesUnitExist("player") then HPP_HealMarker.desired["player"] = true end
  elseif HPP_HealMarker.testSelf then
    if DoesUnitExist("player") then HPP_HealMarker.desired["player"] = true end
  end

  -- Settings-based force show (no slash needed)
  local s = HealerPerformancePanel.settings
  if s and s.needHealForceShow then
    if DoesUnitExist("player") then HPP_HealMarker.desired["player"] = true end
    for i=1,12 do
      local ut = "group"..tostring(i)
      if DoesUnitExist(ut) then HPP_HealMarker.desired[ut] = true end
    end
  end

  if HPP_HealMarker.debug then
    local now = GetGameTimeMilliseconds()
    local cDesired = 0; for _,v in pairs(HPP_HealMarker.desired) do if v then cDesired = cDesired + 1 end end
    local cLive = 0; for _ in pairs(HPP_WorldMarkers) do cLive = cLive + 1 end
    HPP_Dbg(now, "LibImplex="..tostring(LibImplex~=nil).." desired="..cDesired.." live="..cLive)
  end

  for ut, _ in pairs(HPP_WorldMarkers) do
    local want = HPP_HealMarker.desired[ut]
    if not want then
      HPP_DeleteWorldMarker(ut)
    else
      HPP_UpdateWorldMarker(ut, true)
    end
  end
end


-- High-frequency updater for world markers (smooth follow).
HPP_StartMarkerLoop = function()
  local s = HealerPerformancePanel.settings
  local ms = (s and s.needHealMarkerUpdateMs) or 50
  if ms < 1 then ms = 1 end
  if ms > 250 then ms = 250 end

  EVENT_MANAGER:UnregisterForUpdate(ADDON .. "_MARKER_UPDATE")
  EVENT_MANAGER:RegisterForUpdate(ADDON .. "_MARKER_UPDATE", ms, function()
    for ut, _ in pairs(HPP_WorldMarkers) do
      if HPP_WorldMarkersVisible and HPP_WorldMarkersVisible[ut] then
        HPP_UpdateWorldMarker(ut, true)
      end
    end
  end)
end

local function StartLoop() local function tick() if HealerPerformancePanel.running then RefreshUI(); zo_callLater(tick, UPDATE_MS) end end tick() end

local function OnEffectChanged(_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
  if not IsGroupUnitTag(unitTag) then return end
  if buffType ~= BUFF_TYPE_DEBUFF then return end
  if not abilityId or abilityId == 0 then return end
  local t = EnsureDebuffTable(); t[unitTag] = t[unitTag] or {}
  if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
    local isNewWatched = (t[unitTag][abilityId] == nil) and (HealerPerformancePanel.saved.watchlist[abilityId] == true)
    t[unitTag][abilityId] = { icon = iconName, endTimeS = endTime }
    if HealerPerformancePanel.settings.debugDebuffs then d(string.format("|c66ccffHPP|r дебаф на %s: %s (id=%d)", SafeName(unitTag), tostring(effectName), abilityId)) end
    if isNewWatched and CanPlay("debuff", unitTag) then PlayDebuffAlert() end
  elseif changeType == EFFECT_RESULT_FADED then
    if t[unitTag] then t[unitTag][abilityId] = nil end
  end
end

local function Slash(text)
  local s = HealerPerformancePanel.settings
  local sv = HealerPerformancePanel.saved
  local args = {}; for w in string.gmatch(text or "", "%S+") do args[#args+1] = w end
  if #args == 0 then s.showWindow = not s.showWindow; RefreshUI(); return end
  local cmd = string.lower(args[1])
  if cmd=="testgroup4" then s.testGroupMode=4; RefreshUI(); d("|c66ccffHPP|r тест-група: 4"); return end
  if cmd=="testgroup12" then s.testGroupMode=12; RefreshUI(); d("|c66ccffHPP|r тест-рейд: 12"); return end
  if cmd=="testgroupoff" then s.testGroupMode=0; RefreshUI(); d("|c66ccffHPP|r тест-група вимкнена"); return end
  if cmd=="watch" then
    local sub = string.lower(args[2] or ""); local id = tonumber(args[3] or "")
    if sub=="add" and id then sv.watchlist[id]=true; d("|c66ccffHPP|r додано id="..id); return end
    if sub=="del" and id then sv.watchlist[id]=nil; d("|c66ccffHPP|r видалено id="..id); return end
    if sub=="list" then for k,_ in pairs(sv.watchlist or {}) do d("|c66ccffHPP|r watch id="..tostring(k)) end return end
  end
  d("|c66ccffHPP|r /hpp | /hpp testgroup4 | /hpp testgroup12 | /hpp testgroupoff")
end

local function ColorPickerOption(name, key, defaultColor)
  return {
    type = "colorpicker", name = name,
    getFunc = function() local c = HealerPerformancePanel.settings[key] or defaultColor return c[1], c[2], c[3], c[4] end,
    setFunc = function(r,g,b,a) HealerPerformancePanel.settings[key] = {r,g,b,a}; RefreshUI() end,
    disabled = function() return not HealerPerformancePanel.settings.useCustomColors end,
  }
end

-- ===== Marker Preview (in Settings) =====
-- Small live preview of the "need heal" marker icon inside LibAddonMenu settings.
local function HPP_ApplyMarkerPreview(control)
  if not control or not control.previewTex then return end
  local s = HealerPerformancePanel.settings or {}
  local size = tonumber(s.needHealMarkerSize or 26) or 26
  local alpha = tonumber(s.needHealMarkerAlpha or 1.0) or 1.0
  local tex = s.needHealMarkerTexture or DEFAULT_NEEDHEAL_TEXTURE

  control.previewTex:SetTexture(tex)
  control.previewTex:SetDimensions(size, size)
  control.previewTex:SetAlpha(alpha)

  -- Optional tint (if user changes RGBA sliders)
  local r = tonumber(s.needHealMarkerColorR or 1) or 1
  local g = tonumber(s.needHealMarkerColorG or 1) or 1
  local b = tonumber(s.needHealMarkerColorB or 1) or 1
  local a = tonumber(s.needHealMarkerColorA or 1) or 1
  if control.previewTex.SetColor then
    control.previewTex:SetColor(r, g, b, a)
  end

  if control.previewLabel then
    control.previewLabel:SetText(string.format("Preview: %dpx, A=%d%%", size, zo_round(alpha*100)))
  end
end

-- Called by LAM custom control
local function HPP_CreateMarkerPreview(container)
  if not container then return end
  container:SetDimensions(container:GetWidth() or 300, 70)

  local wm = WINDOW_MANAGER
  local bg = wm:CreateControl(nil, container, CT_BACKDROP)
  bg:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
  bg:SetAnchor(BOTTOMRIGHT, container, BOTTOMRIGHT, 0, 0)
  bg:SetCenterColor(0, 0, 0, 0.25)
  bg:SetEdgeColor(0, 0, 0, 0.6)
  bg:SetEdgeTexture("", 1, 1, 1)

  local tex = wm:CreateControl(nil, container, CT_TEXTURE)
  tex:SetAnchor(LEFT, container, LEFT, 12, 0)
  tex:SetTexture(DEFAULT_NEEDHEAL_TEXTURE)

  local label = wm:CreateControl(nil, container, CT_LABEL)
  label:SetAnchor(LEFT, tex, RIGHT, 14, 0)
  label:SetFont("ZoFontGame")
  label:SetText("Preview")

  container.previewTex = tex
  container.previewLabel = label
  HealerPerformancePanel._markerPreview = container

  HPP_ApplyMarkerPreview(container)
end

local function HPP_UpdateMarkerPreview()
  if HealerPerformancePanel and HealerPerformancePanel._markerPreview then
    HPP_ApplyMarkerPreview(HealerPerformancePanel._markerPreview)
  end
end

local function SetupLAM()
  local LAM = LibAddonMenu2
  if not LAM then d("|c66ccffHPP|r Не знайдено LibAddonMenu-2.0"); return end

  local panelData = { type="panel", name="HealerPerformancePanel", displayName="Панель хілера", author="ChatGPT", version="0.2.10", registerForRefresh=true, registerForDefaults=true }
  local soundKeys, soundLabels = GetSoundKeys(), GetSoundLabels()
  local themeNames = ThemeNames()
  local sk = THEMES["Skyrim Amber"]

  local optionsData = {
    { type="header", name="Вигляд" },
    { type="checkbox", name="Показувати панель", getFunc=function() return HealerPerformancePanel.settings.showWindow end, setFunc=function(v) HealerPerformancePanel.settings.showWindow=v; RefreshUI() end, default=true },
    { type="checkbox", name="Сховати себе", getFunc=function() return HealerPerformancePanel.settings.hideSelf end, setFunc=function(v) HealerPerformancePanel.settings.hideSelf=v; RefreshUI() end, default=false },
    { type="dropdown", name="Тема", choices=themeNames, getFunc=function() return HealerPerformancePanel.settings.themeName end, setFunc=function(v) HealerPerformancePanel.settings.themeName=v; RefreshUI() end, default="Minimal Dark" },
    { type="checkbox", name="Компактний режим (2 колонки)", getFunc=function() return HealerPerformancePanel.settings.compactMode end, setFunc=function(v) HealerPerformancePanel.settings.compactMode=v; ApplyLayout(); RefreshUI() end, default=true },
    { type="checkbox", name="Показувати рівень", getFunc=function() return HealerPerformancePanel.settings.showLevel end, setFunc=function(v) HealerPerformancePanel.settings.showLevel=v; RefreshUI() end, default=true },
    { type="checkbox", name="Показувати іконку ролі", getFunc=function() return HealerPerformancePanel.settings.showRole end, setFunc=function(v) HealerPerformancePanel.settings.showRole=v; RefreshUI() end, default=true },
    { type="slider", name="Розмір іконки ролі", min=18, max=46, step=1, getFunc=function() return HealerPerformancePanel.settings.roleIconSize end, setFunc=function(v) HealerPerformancePanel.settings.roleIconSize=v; RefreshUI() end, default=26 },
    { type="header", name="Текст HP" },
    { type="dropdown", name="Формат HP", choices={ "Waypoint", "Warning", "Healer role", "Crosshair", "Star (reticle)", "Quest pin", "Skull", "Crown", "Shield", "Plus", "Square" },
      choicesValues={ "PERCENT", "CURRENT", "CURRENT_PERCENT", "CURRENT_MAX", "PERCENT_MAX", "OFF" },
      choicesValues = { 
        "/esoui/art/compass/compass_waypoint.dds",
        "/esoui/art/miscellaneous/eso_icon_warning.dds",
        "/esoui/art/lfg/lfg_roleicon_healer.dds",
        "/esoui/art/hud/gamepad/gp_crosshair.dds",
        "/esoui/art/hud/reticle_star.dds",
        "/esoui/art/compass/quest_icon_assisted.dds",
        "/esoui/art/icons/mapkey/mapkey_groupboss.dds",
        "/esoui/art/icons/mapkey/mapkey_groupleader.dds",
        "/esoui/art/icons/mapkey/mapkey_keep.dds",
        "/esoui/art/hud/gamepad/gp_plus_large.dds",
        "/esoui/art/miscellaneous/white_icon.dds",
      },
      getFunc=function() return HealerPerformancePanel.settings.hpTextMode end,
      setFunc=function(v)
        local s = HealerPerformancePanel.settings
        s.hpTextMode = v
        -- keep legacy toggles in sync (so older code paths/settings stay consistent)
        if v == "PERCENT" then s.showHpPercent=true; s.showMaxHp=false
        elseif v == "CURRENT" then s.showHpPercent=false; s.showMaxHp=false
        elseif v == "CURRENT_PERCENT" then s.showHpPercent=true; s.showMaxHp=false
        elseif v == "CURRENT_MAX" then s.showHpPercent=false; s.showMaxHp=true
        elseif v == "PERCENT_MAX" then s.showHpPercent=true; s.showMaxHp=true
        elseif v == "OFF" then s.showHpPercent=false; s.showMaxHp=false end
        RefreshUI()
      end, default="PERCENT" },
    { type="slider", name="Масштаб тексту HP (%)", min=70, max=160, step=1,
      getFunc=function() return HealerPerformancePanel.settings.hpTextScale end,
      setFunc=function(v) HealerPerformancePanel.settings.hpTextScale=v; RefreshUI() end, default=100 },
    { type="checkbox", name="Компактні числа (k)", tooltip="Напр.: 24500 -> 24,5k",
      getFunc=function() return HealerPerformancePanel.settings.hpNumberCompact end,
      setFunc=function(v) HealerPerformancePanel.settings.hpNumberCompact=v; RefreshUI() end, default=false },
    { type="checkbox", name="Показувати % HP", getFunc=function() return HealerPerformancePanel.settings.showHpPercent end, setFunc=function(v) HealerPerformancePanel.settings.showHpPercent=v; RefreshUI() end, default=true },
    { type="checkbox", name="Показувати поточне/макс HP", getFunc=function() return HealerPerformancePanel.settings.showMaxHp end, setFunc=function(v) HealerPerformancePanel.settings.showMaxHp=v; RefreshUI() end, default=false },
    { type="slider", name="Ширина панелі", min=420, max=1600, step=10, getFunc=function() return HealerPerformancePanel.settings.panelWidth end, setFunc=function(v) HealerPerformancePanel.settings.panelWidth=v; ApplyLayout(); RefreshUI() end, default=980 },
    { type="slider", name="Висота рядка", min=24, max=60, step=1, getFunc=function() return HealerPerformancePanel.settings.rowHeight end, setFunc=function(v) HealerPerformancePanel.settings.rowHeight=v; ApplyLayout(); RefreshUI() end, default=40 },
    { type="slider", name="Ширина тексту HP", min=70, max=300, step=5, getFunc=function() return HealerPerformancePanel.settings.hpTextWidth end, setFunc=function(v) HealerPerformancePanel.settings.hpTextWidth=v; RefreshUI() end, default=170 },
    { type="slider", name="Розмір шрифту", min=16, max=32, step=1, getFunc=function() return HealerPerformancePanel.settings.fontSize end, setFunc=function(v) HealerPerformancePanel.settings.fontSize=v; RefreshUI() end, default=22 },
    { type="dropdown", name="Шрифт", choices={ "Авто (як було)", "ZoFontGameLarge", "ZoFontWinH4", "ZoFontGame", "ZoFontHeader2", "ZoFontHeader3" },
      choicesValues={ "AUTO", "ZoFontGameLarge", "ZoFontWinH4", "ZoFontGame", "ZoFontHeader2", "ZoFontHeader3" },
      getFunc=function() return HealerPerformancePanel.settings.fontFace end,
      setFunc=function(v) HealerPerformancePanel.settings.fontFace=v; RefreshUI() end,
      default="AUTO" },
    { type="header", name="Тест макета" },
    { type="dropdown", name="Тест-група", choices=TEST_GROUP_CHOICES, choicesValues=TEST_GROUP_VALUES, getFunc=function() return HealerPerformancePanel.settings.testGroupMode end, setFunc=function(v) HealerPerformancePanel.settings.testGroupMode=v; RefreshUI() end, default=0 },
    { type="checkbox", name="Пульсація в тесті", getFunc=function() return HealerPerformancePanel.settings.testPulse end, setFunc=function(v) HealerPerformancePanel.settings.testPulse=v end, default=false },
    { type="header", name="Кольори" },
    { type="checkbox", name="Власні кольори (override теми)", getFunc=function() return HealerPerformancePanel.settings.useCustomColors end, setFunc=function(v) HealerPerformancePanel.settings.useCustomColors=v; RefreshUI() end, default=false },
    ColorPickerOption("Панель: Танк", "colTank", sk.tank),
    ColorPickerOption("Панель: Хіл", "colHealer", sk.healer),
    ColorPickerOption("Панель: ДД", "colDps", sk.dps),
    ColorPickerOption("Текст імені", "colText", sk.text),
    ColorPickerOption("Текст HP", "colHpText", sk.hptext),
    ColorPickerOption("Текст рівня", "colLvl", sk.lvl),
    ColorPickerOption("HP-смужка: Танк", "colHpBarTank", sk.hpbarTank),
    ColorPickerOption("HP-смужка: Хіл", "colHpBarHealer", sk.hpbarHealer),
    ColorPickerOption("HP-смужка: ДД", "colHpBarDps", sk.hpbarDps),
    ColorPickerOption("HP-смужка: Unknown", "colHpBarUnknown", sk.hpbarUnk),
    ColorPickerOption("Іконка ролі: Танк", "colIconTank", sk.iconTank),
    ColorPickerOption("Іконка ролі: Хіл", "colIconHealer", sk.iconHealer),
    ColorPickerOption("Іконка ролі: ДД", "colIconDps", sk.iconDps),
    { type="header", name="Мітка над персонажем (need heal)" },
    { type="checkbox", name="Показувати мітку над персонажем (LibImplex)", getFunc=function() return HealerPerformancePanel.settings.enableNeedHealMarker end, setFunc=function(v) HealerPerformancePanel.settings.enableNeedHealMarker=v; RefreshUI() end, default=true },
    { type="checkbox", name="Пульсація мітки при появі", tooltip="Коротка пульсація (розмір/прозорість) коли мітка з’являється.",
      getFunc=function() return HealerPerformancePanel.settings.needHealPulseOnShow end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealPulseOnShow=v end,
      default=true },
    { type="slider", name="Тривалість пульсації (мс)", min=0, max=4000, step=50,
      getFunc=function() return HealerPerformancePanel.settings.needHealPulseDurationMs end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealPulseDurationMs=v end,
      default=1200, disabled=function() return not HealerPerformancePanel.settings.needHealPulseOnShow end },
    { type="slider", name="Період пульсації (мс)", min=100, max=1200, step=10,
      getFunc=function() return HealerPerformancePanel.settings.needHealPulsePeriodMs end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealPulsePeriodMs=v end,
      default=450, disabled=function() return not HealerPerformancePanel.settings.needHealPulseOnShow end },
    { type="slider", name="Макс. масштаб пульсації (x)", min=1.0, max=2.0, step=0.01,
      getFunc=function() return HealerPerformancePanel.settings.needHealPulseScale end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealPulseScale=v end,
      default=1.35, disabled=function() return not HealerPerformancePanel.settings.needHealPulseOnShow end },
    { type="slider", name="Мін. прозорість в пульсації", min=0.05, max=1.0, step=0.01,
      getFunc=function() return HealerPerformancePanel.settings.needHealPulseAlphaMin end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealPulseAlphaMin=v end,
      default=0.55, disabled=function() return not HealerPerformancePanel.settings.needHealPulseOnShow end },
    { type="slider", name="Поріг need heal (%)", min=1, max=99, step=1, getFunc=function() return HealerPerformancePanel.settings.needHealThresholdPct end, setFunc=function(v) HealerPerformancePanel.settings.needHealThresholdPct=v end, default=65 },
    { type="slider", name="Розмір мітки (px)", min=1, max=200, step=1, getFunc=function() return HealerPerformancePanel.settings.needHealMarkerSize end, setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerSize=v; HPP_UpdateMarkerPreview() end, default=26 },
{ type="slider", name="Висота мітки над головою (Z)", min=40, max=600, step=10,
    getFunc=function() return HealerPerformancePanel.settings.needHealWorldZOffset end,
    setFunc=function(v) HealerPerformancePanel.settings.needHealWorldZOffset=v; HPP_UpdateMarkerPreview() end, default=180 },
    { type="dropdown", name="Вісь висоти мітки", tooltip="У ESO вертикальна вісь зазвичай Y. Якщо мітка їде вбік — вибери Y.", 
      choices={"Y (висота)","Z (висота)"}, choicesValues={"Y","Z"},
      getFunc=function() return HealerPerformancePanel.settings.needHealMarkerVerticalAxis or "Y" end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerVerticalAxis=v; HPP_UpdateMarkerPreview() end, default="Y" },
    { type="dropdown", name="Поворот до камери", tooltip="FULL = завжди дивиться в камеру (без профілю). YAW = тільки по горизонталі. OFF = вимкнено.", choices={"OFF","YAW","FULL"}, choicesValues={"OFF","YAW","FULL"}, getFunc=function() return HealerPerformancePanel.settings.needHealMarkerBillboardMode or "FULL" end, setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerBillboardMode=v; HPP_UpdateMarkerPreview() end, default="FULL" },
{ type="dropdown", name="Текстура мітки (тест)", choices={ "Waypoint", "Warning", "Healer role", "Crosshair", "Star", "Quest pin", "Skull", "Crown", "Shield", "Plus", "Square" },
    choicesValues={
      "/esoui/art/compass/compass_waypoint.dds",
      "/esoui/art/miscellaneous/eso_icon_warning.dds",
      "/esoui/art/lfg/lfg_roleicon_healer.dds",
      "/esoui/art/hud/gamepad/gp_crosshair.dds",
      "/esoui/art/hud/reticle_star.dds",
      "/esoui/art/compass/quest_icon_assisted.dds",
      "/esoui/art/icons/mapkey/mapkey_groupboss.dds",
      "/esoui/art/icons/mapkey/mapkey_groupleader.dds",
      "/esoui/art/unitframes/unitframe_shield.dds",
      "/esoui/art/hud/gamepad/gp_plus_large.dds",
      "/esoui/art/miscellaneous/white_icon.dds",
    },
    getFunc=function() return HealerPerformancePanel.settings.needHealMarkerTexture end,
    setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerTexture=v; HPP_UpdateMarkerPreview() end, default="/esoui/art/compass/compass_waypoint.dds" },

{ type="custom", reference="HPP_MarkerPreview", width="full",
  createFunc=function(control) HPP_CreateMarkerPreview(control) end,
  refreshFunc=function(control) HPP_ApplyMarkerPreview(control) end },
    { type="slider", name="Оновлення позиції мітки (мс)", tooltip="Менше = плавніше, але більше навантаження. 16–33 мс дуже плавно.", min=1, max=250, step=1,
      getFunc=function() return HealerPerformancePanel.settings.needHealMarkerUpdateMs or 50 end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerUpdateMs=v; if HPP_StartMarkerLoop then HPP_StartMarkerLoop() end end, default=50 },
    { type="slider", name="Колір R", min=0, max=1, step=0.01,
      getFunc=function() return HealerPerformancePanel.settings.needHealMarkerColorR or 1 end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerColorR=v; HPP_UpdateMarkerPreview() end, default=1 },
    { type="slider", name="Колір G", min=0, max=1, step=0.01,
      getFunc=function() return HealerPerformancePanel.settings.needHealMarkerColorG or 1 end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerColorG=v; HPP_UpdateMarkerPreview() end, default=1 },
    { type="slider", name="Колір B", min=0, max=1, step=0.01,
      getFunc=function() return HealerPerformancePanel.settings.needHealMarkerColorB or 1 end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerColorB=v; HPP_UpdateMarkerPreview() end, default=1 },
    { type="slider", name="Колір A", tooltip="Якщо LibImplex підтримує tint, це прозорість саме кольору. Інакше ігнорується.", min=0, max=1, step=0.01,
      getFunc=function() return HealerPerformancePanel.settings.needHealMarkerColorA or 1 end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerColorA=v; HPP_UpdateMarkerPreview() end, default=1 },

    { type="slider", name="Відступ мітки над HP (px)", min=0, max=30, step=1, getFunc=function() return HealerPerformancePanel.settings.needHealMarkerYOffset end, setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerYOffset=v end, default=6 },
    { type="slider", name="Прозорість мітки", min=20, max=100, step=1, getFunc=function() return zo_round((HealerPerformancePanel.settings.needHealMarkerAlpha or 1.0)*100) end,
      setFunc=function(v) HealerPerformancePanel.settings.needHealMarkerAlpha = (v/100); RefreshUI(); HPP_UpdateMarkerPreview() end, default=100 },
    { type="header", name="Тривоги HP" },
    { type="slider", name="Поріг низького HP (%)", min=1, max=99, step=1, getFunc=function() return HealerPerformancePanel.settings.lowHpThresholdPct end, setFunc=function(v) HealerPerformancePanel.settings.lowHpThresholdPct=v end, default=50 },
    { type="checkbox", name="Алерт при різкому падінні", getFunc=function() return HealerPerformancePanel.settings.enableFastDropAlert end, setFunc=function(v) HealerPerformancePanel.settings.enableFastDropAlert=v end, default=true },
    { type="slider", name="Різке падіння (%/сек)", min=5, max=80, step=1, getFunc=function() return HealerPerformancePanel.settings.fastDropPctPerSec end, setFunc=function(v) HealerPerformancePanel.settings.fastDropPctPerSec=v end, default=25 },
    { type="slider", name="Fast-drop тільки якщо HP ≤ (%)", min=1, max=100, step=1, getFunc=function() return HealerPerformancePanel.settings.fastDropMinHpPct end, setFunc=function(v) HealerPerformancePanel.settings.fastDropMinHpPct=v end, default=80 },
    { type="header", name="Звук HP" },
    { type="checkbox", name="Увімкнути звук HP", getFunc=function() return HealerPerformancePanel.settings.enableHpSound end, setFunc=function(v) HealerPerformancePanel.settings.enableHpSound=v end, default=true },
    { type="dropdown", name="Звук HP", choices=soundLabels, choicesValues=soundKeys, getFunc=function() return HealerPerformancePanel.settings.hpSoundKey end, setFunc=function(v) HealerPerformancePanel.settings.hpSoundKey=v end, default="GENERAL_ALERT_ERROR" },
    { type="slider", name="Гучність (множник)", tooltip="ESO не має окремого регулятора гучності для аддон-звуків. Це множник: звук програється кілька разів підряд (не для всіх звуків працює).", min=1, max=10, step=1,
      getFunc=function() return HealerPerformancePanel.settings.hpSoundVolume end,
      setFunc=function(v) HealerPerformancePanel.settings.hpSoundVolume=v end,
      default=1 },
    { type="slider", name="Повтори", tooltip="Скільки разів повторити серію програвань.", min=1, max=10, step=1,
      getFunc=function() return HealerPerformancePanel.settings.hpSoundRepeats end,
      setFunc=function(v) HealerPerformancePanel.settings.hpSoundRepeats=v end,
      default=1 },
    { type="slider", name="Затримка між повторами (мс)", min=0, max=2000, step=10,
      getFunc=function() return HealerPerformancePanel.settings.hpSoundRepeatDelayMs end,
      setFunc=function(v) HealerPerformancePanel.settings.hpSoundRepeatDelayMs=v end,
      default=120 },
    { type="button", name="Прослухати звук HP", width="half", func=function() local s=HealerPerformancePanel.settings; PlayPresetSoundAdvanced(s.hpSoundKey, s.hpSoundVolume, s.hpSoundRepeats, s.hpSoundRepeatDelayMs) end },
    { type="slider", name="Кулдаун звуку HP (мс)", min=0, max=10000, step=50,
      getFunc=function() return HealerPerformancePanel.settings.hpSoundCooldownMs end,
      setFunc=function(v) HealerPerformancePanel.settings.hpSoundCooldownMs=v end,
      default=2000 },
    { type="header", name="Дебафи" },
    { type="checkbox", name="Увімкнути звук дебафа", getFunc=function() return HealerPerformancePanel.settings.enableDebuffSound end, setFunc=function(v) HealerPerformancePanel.settings.enableDebuffSound=v end, default=false },
    { type="dropdown", name="Звук дебафа", choices=soundLabels, choicesValues=soundKeys, getFunc=function() return HealerPerformancePanel.settings.debuffSoundKey end, setFunc=function(v) HealerPerformancePanel.settings.debuffSoundKey=v end, default="DUEL_START" },
    { type="slider", name="Гучність (множник)", tooltip="ESO не має окремого регулятора гучності для аддон-звуків. Це множник: звук програється кілька разів підряд (не для всіх звуків працює).", min=1, max=10, step=1,
      getFunc=function() return HealerPerformancePanel.settings.debuffSoundVolume end,
      setFunc=function(v) HealerPerformancePanel.settings.debuffSoundVolume=v end,
      default=1 },
    { type="slider", name="Повтори", tooltip="Скільки разів повторити серію програвань.", min=1, max=10, step=1,
      getFunc=function() return HealerPerformancePanel.settings.debuffSoundRepeats end,
      setFunc=function(v) HealerPerformancePanel.settings.debuffSoundRepeats=v end,
      default=1 },
    { type="slider", name="Затримка між повторами (мс)", min=0, max=2000, step=10,
      getFunc=function() return HealerPerformancePanel.settings.debuffSoundRepeatDelayMs end,
      setFunc=function(v) HealerPerformancePanel.settings.debuffSoundRepeatDelayMs=v end,
      default=120 },
    { type="button", name="Прослухати звук дебафа", width="half", func=function() local s=HealerPerformancePanel.settings; PlayPresetSoundAdvanced(s.debuffSoundKey, s.debuffSoundVolume, s.debuffSoundRepeats, s.debuffSoundRepeatDelayMs) end },
    { type="slider", name="Кулдаун звуку дебафа (мс)", min=0, max=10000, step=50,
      getFunc=function() return HealerPerformancePanel.settings.debuffSoundCooldownMs end,
      setFunc=function(v) HealerPerformancePanel.settings.debuffSoundCooldownMs=v end,
      default=1500 },
    { type="checkbox", name="Debug дебафів (чат)", getFunc=function() return HealerPerformancePanel.settings.debugDebuffs end, setFunc=function(v) HealerPerformancePanel.settings.debugDebuffs=v end, default=false },
  }

  LAM:RegisterAddonPanel("HealerPerformancePanelOptions", panelData)
  LAM:RegisterOptionControls("HealerPerformancePanelOptions", optionsData)
end

function HealerPerformancePanel:Initialize()
  self.saved = ZO_SavedVars:NewAccountWide(SV_NAME, 1, nil, {})
  self.settings = EnsureDefaults(self.saved)
  self.running = true
  SLASH_COMMANDS["/hpp"] = Slash
  SLASH_COMMANDS["/hppmk"] = function(text)
    local args = {}; for w in string.gmatch(text or "", "%S+") do args[#args+1] = w end
    local sub = string.lower(args[1] or "")
    if sub == "" or sub == "help" then
      d("|c66ccffHPP|r /hppmk debug on|off  |  /hppmk self  |  /hppmk all  |  /hppmk clear")
      return
    end
    if sub == "debug" then
      local v = string.lower(args[2] or "")
      HPP_HealMarker.debug = (v == "on" or v == "1" or v == "true")
      d("|c66ccffHPP|r marker debug = "..tostring(HPP_HealMarker.debug))
      return
    end
    if sub == "dump" then HPP_DumpImplexObjects(); return end
    if sub == "self" then
      HPP_HealMarker.testSelf = true; HPP_HealMarker.testAll = false
      d("|c66ccffHPP|r marker test: SELF")
      return
    end
    if sub == "all" then
      HPP_HealMarker.testAll = true; HPP_HealMarker.testSelf = false
      d("|c66ccffHPP|r marker test: ALL")
      return
    end
    if sub == "clear" or sub == "off" then
      HPP_HealMarker.testAll = false; HPP_HealMarker.testSelf = false
      for k in pairs(HPP_HealMarker.desired) do HPP_HealMarker.desired[k] = nil end
      if HPP_DeleteAllWorldMarkers then HPP_DeleteAllWorldMarkers() end
      d("|c66ccffHPP|r marker test cleared")
      return
    end
  end
  EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_EFFECT_CHANGED, OnEffectChanged)
  ApplyLayout()
  HPP_RestoreWindowPos()
  HPP_HookWindowDrag()
  SetupLAM()
  StartLoop()
  RefreshUI()
  if HPP_StartMarkerLoop then HPP_StartMarkerLoop() end
  d("|c66ccffHPP|r завантажено. /hpp")
end

local function OnLoaded(_, name)
  if name ~= ADDON then return end
  EVENT_MANAGER:UnregisterForEvent(ADDON, EVENT_ADD_ON_LOADED)
  HealerPerformancePanel:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ADD_ON_LOADED, OnLoaded)
