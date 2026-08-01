
Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Export = {}
local M = Verditer.Export

local zui = Verditer.zenimax.ui
local zc  = Verditer.zenimax.constants
local WINDOW_MANAGER           = zui.WINDOW_MANAGER
local CreateControlFromVirtual = zui.CreateControlFromVirtual

local TOPLEFT     = zc.TOPLEFT
local TOPRIGHT    = zc.TOPRIGHT
local BOTTOMLEFT  = zc.BOTTOMLEFT
local BOTTOMRIGHT = zc.BOTTOMRIGHT
local CT_LABEL    = zc.CT_LABEL
local CT_TEXTURE  = zc.CT_TEXTURE
local CT_BACKDROP = zc.CT_BACKDROP
local GuiRoot     = zc.GuiRoot

local math_floor    = math.floor
local table_concat  = table.concat
local string_format = string.format

local TINT     = Verditer.Constants.BRAND.TINT
local C_TITLE  = { r = 0.82, g = 0.88, b = 1.00, a = 1.00 }
local C_HINT   = { r = 0.66, g = 0.72, b = 0.82, a = 1.00 }
local C_EDGE   = Verditer.Constants.BRAND.EDGE
local MAX_CHARS = 500000


local DT_NAME = {}
local function dn(k, v) if k ~= nil then DT_NAME[k] = v end end
dn(zc.DAMAGE_TYPE_GENERIC, "Generic")  dn(zc.DAMAGE_TYPE_PHYSICAL, "Physical")
dn(zc.DAMAGE_TYPE_FIRE,    "Fire")     dn(zc.DAMAGE_TYPE_SHOCK,    "Shock")
dn(zc.DAMAGE_TYPE_OBLIVION,"Oblivion") dn(zc.DAMAGE_TYPE_COLD,     "Cold")
dn(zc.DAMAGE_TYPE_EARTH,   "Earth")    dn(zc.DAMAGE_TYPE_MAGIC,    "Magic")
dn(zc.DAMAGE_TYPE_DROWN,   "Drown")    dn(zc.DAMAGE_TYPE_DISEASE,  "Disease")
dn(zc.DAMAGE_TYPE_POISON,  "Poison")   dn(zc.DAMAGE_TYPE_BLEED,    "Bleed")
dn(zc.DAMAGE_TYPE_NONE,    "None")

local controls

local function pct(x) return math_floor((x or 0) * 100 + 0.5) end

local function type_cell(groups)
  local n = (groups and groups.count) or 0
  if n == 0 then return "" end
  local parts = {}
  for i = 1, n do
    local g = groups[i]
    parts[i] = (DT_NAME[g.dt] or ("dt" .. tostring(g.dt))) .. ":" .. pct(g.share)
  end
  return table_concat(parts, "|")
end

local function source_cell(groups)
  local n = (groups and groups.count) or 0
  if n == 0 then return "" end
  local parts = {}
  for i = 1, n do
    local g = groups[i]
    local nm
    if g.uid == -1 then nm = "Other"
    elseif g.uid == 0 then nm = "Env"
    else nm = (g.name and g.name ~= "" and zo_strformat(SI_UNIT_NAME, g.name)) or "Unknown" end
    parts[i] = nm .. ":" .. pct(g.share)
  end
  return table_concat(parts, "|")
end

local function build_line(s, t0)
  local t_s = string_format("%.2f", (s.t - (t0 or s.t)) / 1000)
  local hp  = (s.hp_pct and s.hp_pct >= 0) and tostring(pct(s.hp_pct)) or ""
  return table_concat({
    t_s,
    tostring(math_floor((s.DTPS or 0) + 0.5)),
    tostring(math_floor((s.ABS or 0) + 0.5)),
    hp,
    tostring(pct(s.hp_drop)),
    type_cell(s.type_groups),
    source_cell(s.source_groups),
  }, ",")
end

function M.build_csv()
  local TB = Verditer.TemporalBuffer
  if not TB or TB.count() == 0 then return nil, 0, 0, false end

  local header = "t_s,DTPS,ABS,HP_pct,HP_drop,types,sources"
  local budget = MAX_CHARS - 2048
  local lines  = { header }
  local total_len = #header
  local t0
  local rows_total, rows_written, stop = 0, 0, false

  TB.iterate(function(i, s)
    if i == 1 then t0 = s.t end
    rows_total = rows_total + 1
    if stop then return end
    local line = build_line(s, t0)
    if total_len + #line + 1 > budget then stop = true; return end
    lines[#lines + 1] = line
    total_len = total_len + #line + 1
    rows_written = rows_written + 1
  end)

  local truncated = rows_written < rows_total
  if truncated then
    lines[#lines + 1] = string_format("# TRUNCATED: %d of %d samples (char cap %d). Lower sample rate / time window for a full export.",
                                      rows_written, rows_total, MAX_CHARS)
  end
  return table_concat(lines, "\n"), rows_written, rows_total, truncated
end

local function build()
  local win = WINDOW_MANAGER:CreateTopLevelWindow("VerditerExportWindow")
  win:SetDimensions(580, 420)
  win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 240, 140)
  win:SetClampedToScreen(true)
  win:SetMovable(true)
  win:SetMouseEnabled(true)
  win:SetResizeHandleSize(8)
  win:SetHandler("OnMoveStop", function()
    local sv = Verditer.SavedVars
    if sv then sv.export = sv.export or {}; sv.export.x = win:GetLeft(); sv.export.y = win:GetTop() end
  end)

  local bg = WINDOW_MANAGER:CreateControl("$(parent)Bg", win, CT_BACKDROP)
  bg:SetAnchorFill(win)
  bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 8)
  bg:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
  bg:SetInsets(6, 6, -6, -6)
  bg:SetCenterColor(TINT.r, TINT.g, TINT.b, 0.94)
  bg:SetEdgeColor(C_EDGE.r, C_EDGE.g, C_EDGE.b, 1.0)

  local logo = WINDOW_MANAGER:CreateControl("$(parent)Logo", win, CT_TEXTURE)
  logo:SetTexture("Verditer/assets/logo.dds")
  logo:SetDimensions(26, 26)
  logo:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 10)

  local title = WINDOW_MANAGER:CreateControl("$(parent)Title", win, CT_LABEL)
  title:SetFont("ZoFontWinH3")
  title:SetColor(C_TITLE.r, C_TITLE.g, C_TITLE.b, C_TITLE.a)
  title:SetAnchor(TOPLEFT, win, TOPLEFT, 46, 14)
  title:SetText("Verditer — Export")

  local hint = WINDOW_MANAGER:CreateControl("$(parent)Hint", win, CT_LABEL)
  hint:SetFont("ZoFontGameSmall")
  hint:SetColor(C_HINT.r, C_HINT.g, C_HINT.b, C_HINT.a)
  hint:SetAnchor(TOPLEFT, win, TOPLEFT, 14, 40)
  hint:SetText("Recorded session (CSV). Select All, then Ctrl+C to copy.")

  local close = CreateControlFromVirtual("$(parent)Close", win, "ZO_CloseButton")
  close:SetAnchor(TOPRIGHT, win, TOPRIGHT, -8, 10)
  close:SetHandler("OnClicked", function() M.hide() end)

  local ebbg = CreateControlFromVirtual("$(parent)EBBg", win, "ZO_MultiLineEditBackdrop_Keyboard")
  ebbg:SetAnchor(TOPLEFT,     win, TOPLEFT,      14, 60)
  ebbg:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -14, -52)

  local edit = CreateControlFromVirtual("VerditerExportEdit", ebbg, "ZO_DefaultEditMultiLineForBackdrop")
  edit:SetMaxInputChars(MAX_CHARS)
  edit:SetHandler("OnMouseWheel", function(self, delta, ctrl, alt, shift)
    local cur = self:GetTopLineIndex()
    if shift then delta = delta * 10 end
    self:SetTopLineIndex(zo_clamp(cur - delta, 1, self:GetScrollExtents() + 1))
  end)

  local selall = CreateControlFromVirtual("$(parent)SelAll", win, "ZO_DefaultButton")
  selall:SetDimensions(120, 26)
  selall:SetAnchor(BOTTOMLEFT, win, BOTTOMLEFT, 14, -16)
  selall:SetText("Select All")
  selall:SetHandler("OnClicked", function() edit:TakeFocus(); edit:SelectAll() end)

  local closebtn = CreateControlFromVirtual("$(parent)CloseBtn", win, "ZO_DefaultButton")
  closebtn:SetDimensions(120, 26)
  closebtn:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, -14, -16)
  closebtn:SetText("Close")
  closebtn:SetHandler("OnClicked", function() M.hide() end)

  controls = { window = win, edit = edit, hint = hint }

  local sv = Verditer.SavedVars and Verditer.SavedVars.export
  if sv and sv.x then win:ClearAnchors(); win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.x, sv.y) end
  win:SetHidden(true)
end

local function ensure_built() if not controls then build() end end

function M.show_text(hint, text)
  ensure_built()
  if hint then controls.hint:SetText(hint) end
  controls.edit:SetText(text or "")
  controls.window:SetHidden(false)
  controls.window:BringWindowToTop()
  if Verditer.Sound then Verditer.Sound.play("WINDOW_OPEN") end
end

function M.show_session()
  local csv, written, total, truncated = M.build_csv()
  if not csv then
    M.show_text("No recorded data. Press Record, take some hits, then Stop — then Export.", "")
    return false
  end
  local hint
  if truncated then
    hint = string_format(
      "[!] Session too large: exported %d of %d samples (~%dK char cap). Lower the sample rate or time window for a full export.",
      written, total, math_floor(MAX_CHARS / 1000))
  else
    hint = string_format("Recorded session: %d samples (CSV). Select All, then Ctrl+C.", written)
  end
  M.show_text(hint, csv)
  return not truncated
end

function M.hide()
  if controls then
    if Verditer.Sound then Verditer.Sound.play("WINDOW_CLOSE") end
    controls.window:SetHidden(true)
  end
end
function M.is_visible() return controls ~= nil and not controls.window:IsHidden() end
