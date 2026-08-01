Verditer = Verditer or {}
Verditer.Recap = {}
local M = Verditer.Recap

local api = Verditer.zenimax.api
local zc  = Verditer.zenimax.constants
local WM  = Verditer.zenimax.ui.WINDOW_MANAGER

local GetString               = api.GetString
local GetGameTimeMilliseconds = api.GetGameTimeMilliseconds
local math_floor    = math.floor
local math_max      = math.max
local math_min      = math.min
local string_format = string.format

local TOPLEFT     = zc.TOPLEFT
local TOPRIGHT    = zc.TOPRIGHT
local TOP         = zc.TOP
local BOTTOMLEFT  = zc.BOTTOMLEFT
local CENTER      = zc.CENTER
local GuiRoot     = zc.GuiRoot
local CT_TEXTURE  = zc.CT_TEXTURE
local CT_LABEL    = zc.CT_LABEL
local CT_CONTROL  = zc.CT_CONTROL
local TEXT_ALIGN_LEFT   = zc.TEXT_ALIGN_LEFT
local TEXT_ALIGN_RIGHT  = zc.TEXT_ALIGN_RIGHT
local TEXT_ALIGN_CENTER = zc.TEXT_ALIGN_CENTER

local log  = Verditer.Log.for_module("recap")
local TINT = Verditer.Constants.BRAND.TINT

local FILL = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"

-- palette
local C_DIED   = { r = 0.92, g = 0.30, b = 0.25, a = 1.00 }
local C_TITLE  = { r = 0.82, g = 0.88, b = 1.00, a = 1.00 }
local C_SUB    = { r = 0.72, g = 0.76, b = 0.84, a = 1.00 }
local C_HEADER = { r = 0.55, g = 0.70, b = 1.00, a = 0.90 }
local C_DMG    = { r = 0.95, g = 0.85, b = 0.55, a = 1.00 }
local C_KB     = { r = 0.96, g = 0.36, b = 0.30, a = 1.00 }
local C_NAME   = { r = 0.90, g = 0.92, b = 0.96, a = 1.00 }
local C_HP     = { r = 0.30, g = 0.80, b = 0.45, a = 0.95 }
local C_SHIELD = { r = 0.44, g = 0.66, b = 1.00, a = 0.95 }
local C_PEAK   = { r = 0.97, g = 0.74, b = 0.30, a = 0.90 }
local C_CHROME = Verditer.Constants.BRAND.CHROME
local C_GRID   = { r = 0.55, g = 0.58, b = 0.70, a = 0.25 }


local ICON_SZ   = 54
local ATTACK_Y0 = 112
local ROW_H     = 20
local MAX_ROWS  = 6
local LEAD_HDR_Y = 238
local FILM_Y     = 252
local FILM_H     = 52
local FILM_X0    = 28
local LEAD_BARS  = 80
local PRESS_Y    = 324
local TYPE_HDR_Y = 346
local TYPE_Y     = 364
local MAX_TYPES  = 6

local controls = {}

local function abbr(v)
  return ZO_AbbreviateAndLocalizeNumber(math_floor(v + 0.5), 1, false)
end

local function ago_text(ts)
  if not ts or ts <= 0 then return "" end
  local s = math_floor((GetGameTimeMilliseconds() - ts) / 1000)
  if s < 0 then s = 0 end
  if s < 60 then return string_format(GetString(VERDITER_RECAP_AGO_SEC), s) end
  return string_format(GetString(VERDITER_RECAP_AGO_MIN), math_floor(s / 60), s % 60)
end

local function commafy(n)
  n = math_floor(n + 0.5)
  if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(n) end
  return tostring(n)
end

local function mk_label(name, font, col, align)
  local l = WM:CreateControl(name, controls.content, CT_LABEL)
  l:SetFont(font)
  l:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
  l:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  l:SetColor(col.r, col.g, col.b, col.a)
  return l
end

local function mk_tex(name)
  local t = WM:CreateControl(name, controls.content, CT_TEXTURE)
  t:SetTexture(FILL)
  t:SetHidden(true)
  return t
end

local C_HP_FULL = { 0.30, 0.80, 0.45 }
local C_HP_MID  = { 0.95, 0.78, 0.30 }
local C_HP_LOW  = { 0.92, 0.26, 0.22 }
local C_FRESH   = { 0.95, 0.25, 0.22 }
local function hp_color(hp)
  local a, b, t
  if hp >= 0.5 then a, b, t = C_HP_MID, C_HP_FULL, (hp - 0.5) * 2
  else              a, b, t = C_HP_LOW, C_HP_MID,  hp * 2 end
  return a[1] + (b[1] - a[1]) * t,
         a[2] + (b[2] - a[2]) * t,
         a[3] + (b[3] - a[3]) * t
end

local function hexcol(r, g, b)
  return string_format("%02x%02x%02x",
    math_floor((r or 1) * 255 + 0.5), math_floor((g or 1) * 255 + 0.5), math_floor((b or 1) * 255 + 0.5))
end

local function build_content()
  local content = controls.content

  controls.killer_icon = WM:CreateControl("VerditerRecapKillerIcon", content, CT_TEXTURE)
  controls.killer_icon:SetDimensions(ICON_SZ, ICON_SZ)
  controls.killer_icon:SetAnchor(TOPLEFT, content, TOPLEFT, 2, 6)

  controls.died = mk_label("VerditerRecapDied", "ZoFontWinH1", C_DIED, TEXT_ALIGN_LEFT)
  controls.died:SetAnchor(TOPLEFT, content, TOPLEFT, 66, 0)
  controls.died:SetDimensions(220, 30)
  controls.died:SetText(GetString(VERDITER_RECAP_DIED))

  controls.k_ability = mk_label("VerditerRecapAbility", "ZoFontWinH4", C_NAME, TEXT_ALIGN_LEFT)
  controls.k_ability:SetAnchor(TOPLEFT, content, TOPLEFT, 66, 32)
  controls.k_ability:SetDimensions(300, 20)

  controls.k_from = mk_label("VerditerRecapFrom", "ZoFontGame", C_SUB, TEXT_ALIGN_LEFT)
  controls.k_from:SetAnchor(TOPLEFT, content, TOPLEFT, 66, 54)
  controls.k_from:SetDimensions(360, 18)

  controls.overkill = mk_label("VerditerRecapOverkill", "ZoFontGameBold", C_DIED, TEXT_ALIGN_RIGHT)
  controls.overkill:SetAnchor(TOPRIGHT, content, TOPRIGHT, 0, 6)
  controls.overkill:SetDimensions(180, 20)

  controls.fb_hdr = mk_label("VerditerRecapFbHdr", "ZoFontGameSmall", C_HEADER, TEXT_ALIGN_LEFT)
  controls.fb_hdr:SetAnchor(TOPLEFT, content, TOPLEFT, 2, 90)
  controls.fb_hdr:SetDimensions(460, 16)
  controls.fb_hdr:SetText(GetString(VERDITER_RECAP_FINAL_BLOWS))

  controls.rows = {}
  for i = 1, MAX_ROWS do
    local y = ATTACK_Y0 + (i - 1) * ROW_H
    local icon = WM:CreateControl("VerditerRecapRow" .. i .. "Icon", content, CT_TEXTURE)
    icon:SetDimensions(18, 18)
    icon:SetAnchor(TOPLEFT, content, TOPLEFT, 4, y)
    icon:SetHidden(true)

    local nm = mk_label("VerditerRecapRow" .. i .. "Name", "ZoFontGame", C_NAME, TEXT_ALIGN_LEFT)
    nm:SetAnchor(TOPLEFT, content, TOPLEFT, 28, y)
    nm:SetDimensions(176, ROW_H)

    local dmg = mk_label("VerditerRecapRow" .. i .. "Dmg", "ZoFontGame", C_DMG, TEXT_ALIGN_RIGHT)
    dmg:SetAnchor(TOPLEFT, content, TOPLEFT, 196, y)
    dmg:SetDimensions(74, ROW_H)

    local kb = mk_label("VerditerRecapRow" .. i .. "Kb", "ZoFontGameSmall", C_KB, TEXT_ALIGN_CENTER)
    kb:SetAnchor(TOPLEFT, content, TOPLEFT, 274, y)
    kb:SetDimensions(26, ROW_H)

    local who = mk_label("VerditerRecapRow" .. i .. "Who", "ZoFontGameSmall", C_SUB, TEXT_ALIGN_LEFT)
    who:SetAnchor(TOPLEFT, content, TOPLEFT, 304, y)
    who:SetDimensions(180, ROW_H)

    controls.rows[i] = { icon = icon, name = nm, dmg = dmg, kb = kb, who = who }
  end

  controls.lead_hdr = mk_label("VerditerRecapLeadHdr", "ZoFontGameSmall", C_HEADER, TEXT_ALIGN_LEFT)
  controls.lead_hdr:SetAnchor(TOPLEFT, content, TOPLEFT, 2, LEAD_HDR_Y)
  controls.lead_hdr:SetDimensions(460, 16)
  controls.lead_hdr:SetText(GetString(VERDITER_RECAP_LEAD_UP))

  controls.lead_base = mk_tex("VerditerRecapLeadBase")
  controls.lead_base:SetColor(C_GRID.r, C_GRID.g, C_GRID.b, C_GRID.a)
  controls.shield_line = mk_tex("VerditerRecapShieldLine")
  controls.shield_line:SetColor(C_SHIELD.r, C_SHIELD.g, C_SHIELD.b, C_SHIELD.a)

  controls.shield_hit = mk_tex("VerditerRecapShieldHit")
  controls.shield_hit:SetColor(0, 0, 0, 0)
  controls.shield_hit:SetMouseEnabled(true)
  controls.shield_hit:SetDrawLevel(10)
  controls.shield_hit:SetHandler("OnMouseEnter", function(self)
    ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(VERDITER_TT_SHIELD_BREAK))
  end)
  controls.shield_hit:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)

  controls.peak_line = mk_tex("VerditerRecapPeakLine")
  controls.peak_line:SetColor(C_PEAK.r, C_PEAK.g, C_PEAK.b, C_PEAK.a)
  controls.peak_hit = mk_tex("VerditerRecapPeakHit")
  controls.peak_hit:SetColor(0, 0, 0, 0)
  controls.peak_hit:SetMouseEnabled(true)
  controls.peak_hit:SetDrawLevel(10)
  controls.peak_hit:SetHandler("OnMouseEnter", function(self)
    ZO_Tooltips_ShowTextTooltip(self, TOP, GetString(VERDITER_TT_PEAK))
  end)
  controls.peak_hit:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)

  controls.lead_bars = {}
  controls.lead_reds = {}
  for i = 1, LEAD_BARS do
    controls.lead_bars[i] = mk_tex("VerditerRecapLeadBar" .. i)
    controls.lead_reds[i] = mk_tex("VerditerRecapLeadRed" .. i)
  end

  controls.lead_hp100  = mk_label("VerditerRecapHp100", "ZoFontGameSmall", C_SUB, TEXT_ALIGN_RIGHT)
  controls.lead_hp0    = mk_label("VerditerRecapHp0",   "ZoFontGameSmall", C_SUB, TEXT_ALIGN_RIGHT)
  controls.lead_tright = mk_label("VerditerRecapTRight","ZoFontGameSmall", C_KB,  TEXT_ALIGN_RIGHT)
  controls.lead_hp100:SetDimensions(FILM_X0 - 3, 12)
  controls.lead_hp0:SetDimensions(FILM_X0 - 3, 12)
  controls.lead_tright:SetDimensions(60, 12)

  controls.pressure = mk_label("VerditerRecapPressure", "ZoFontGameSmall", C_SUB, TEXT_ALIGN_LEFT)
  controls.pressure:SetAnchor(TOPLEFT, content, TOPLEFT, 2, PRESS_Y)
  controls.pressure:SetDimensions(480, 16)

  controls.types_hdr = mk_label("VerditerRecapTypesHdr", "ZoFontGameSmall", C_HEADER, TEXT_ALIGN_LEFT)
  controls.types_hdr:SetAnchor(TOPLEFT, content, TOPLEFT, 2, TYPE_HDR_Y)
  controls.types_hdr:SetDimensions(460, 16)
  controls.types_hdr:SetText(GetString(VERDITER_RECAP_BREAKDOWN))

  controls.types = {}
  for i = 1, MAX_TYPES do
    local sw = WM:CreateControl("VerditerRecapType" .. i .. "Sw", content, CT_TEXTURE)
    sw:SetTexture(FILL)
    sw:SetDimensions(10, 10)
    sw:SetHidden(true)
    local lbl = mk_label("VerditerRecapType" .. i .. "Lbl", "ZoFontGameSmall", C_SUB, TEXT_ALIGN_LEFT)
    lbl:SetDimensions(40, 14)
    lbl:SetHidden(true)

    local hit = WM:CreateControl("VerditerRecapType" .. i .. "Hit", content, CT_CONTROL)
    hit:SetMouseEnabled(true)
    hit:SetHidden(true)
    local slot = { sw = sw, lbl = lbl, hit = hit, tip = "" }
    hit:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, slot.tip) end)
    hit:SetHandler("OnMouseExit",  function() ZO_Tooltips_HideTextTooltip() end)
    controls.types[i] = slot
  end
end

local function hide_film_labels()
  controls.lead_hp100:SetHidden(true); controls.lead_hp0:SetHidden(true)
  controls.lead_tright:SetHidden(true)
end

local function render_lead(rec)
  local content = controls.content
  local cw = content:GetWidth()
  local n  = (rec.lead and rec.lead.count) or 0
  local baseline_y = FILM_Y + FILM_H

  controls.lead_base:ClearAnchors()
  controls.lead_base:SetAnchor(TOPLEFT, content, TOPLEFT, FILM_X0, baseline_y)
  controls.lead_base:SetHeight(1)
  controls.lead_base:SetWidth((cw - FILM_X0) > 1 and (cw - FILM_X0) or 1)
  controls.lead_base:SetHidden(n == 0)

  for i = 1, LEAD_BARS do
    controls.lead_bars[i]:SetHidden(true)
    controls.lead_reds[i]:SetHidden(true)
  end
  controls.shield_line:SetHidden(true)
  controls.shield_hit:SetHidden(true)
  controls.peak_line:SetHidden(true)
  controls.peak_hit:SetHidden(true)
  if n == 0 or cw <= FILM_X0 + 4 then hide_film_labels(); return end

  local film_w = cw - FILM_X0
  local slot   = film_w / n
  local draw   = math_min(n, LEAD_BARS)
  for i = 1, draw do
    local s    = rec.lead[i]
    local left = FILM_X0 + math_floor((i - 1) * slot + 0.5)
    local rite = FILM_X0 + math_floor(i * slot + 0.5)
    local bw   = math_max(1, rite - left)
    local hp   = s.hp or 0
    if hp < 0 then hp = 0 elseif hp > 1 then hp = 1 end
    local h    = math_max(1, math_floor(hp * FILM_H + 0.5))
    local r, g, bl = hp_color(hp)
    local b = controls.lead_bars[i]
    b:SetColor(r, g, bl, 0.95)
    b:ClearAnchors()
    b:SetAnchor(BOTTOMLEFT, content, TOPLEFT, left, baseline_y)
    b:SetDimensions(bw, h)
    b:SetHidden(false)

    local drop = s.hp_drop or 0
    if drop < 0 then drop = 0 end
    local deficit = 1 - hp
    if drop > deficit then drop = deficit end
    local rh = math_floor(drop * FILM_H + 0.5)
    if rh > 0 then
      local rd = controls.lead_reds[i]
      rd:SetColor(C_FRESH[1], C_FRESH[2], C_FRESH[3], 0.95)
      rd:ClearAnchors()
      rd:SetAnchor(BOTTOMLEFT, content, TOPLEFT, left, baseline_y - h)
      rd:SetDimensions(bw, rh)
      rd:SetHidden(false)
    end
  end

  local sb = rec.lead.shield_break
  if sb and sb >= 1 and sb <= n then
    local x = FILM_X0 + math_floor((sb - 0.5) * slot + 0.5)
    controls.shield_line:ClearAnchors()
    controls.shield_line:SetAnchor(TOPLEFT, content, TOPLEFT, x, FILM_Y)
    controls.shield_line:SetDimensions(1, FILM_H)
    controls.shield_line:SetHidden(false)
    controls.shield_hit:ClearAnchors()
    controls.shield_hit:SetAnchor(TOPLEFT, content, TOPLEFT, x - 4, FILM_Y)
    controls.shield_hit:SetDimensions(9, FILM_H)
    controls.shield_hit:SetHidden(false)
  end

  local pk = rec.lead.peak_idx
  if pk and pk >= 1 and pk <= n then
    local px = FILM_X0 + math_floor((pk - 0.5) * slot + 0.5)
    controls.peak_line:ClearAnchors()
    controls.peak_line:SetAnchor(TOPLEFT, content, TOPLEFT, px, FILM_Y)
    controls.peak_line:SetDimensions(1, FILM_H)
    controls.peak_line:SetHidden(false)
    controls.peak_hit:ClearAnchors()
    controls.peak_hit:SetAnchor(TOPLEFT, content, TOPLEFT, px - 4, FILM_Y)
    controls.peak_hit:SetDimensions(9, FILM_H)
    controls.peak_hit:SetHidden(false)
  end

  controls.lead_hp100:ClearAnchors()
  controls.lead_hp100:SetAnchor(TOPLEFT, content, TOPLEFT, 0, FILM_Y - 1)
  controls.lead_hp100:SetText("100%"); controls.lead_hp100:SetHidden(false)
  controls.lead_hp0:ClearAnchors()
  controls.lead_hp0:SetAnchor(TOPLEFT, content, TOPLEFT, 0, baseline_y - 11)
  controls.lead_hp0:SetText("0%"); controls.lead_hp0:SetHidden(false)

  controls.lead_tright:ClearAnchors()
  controls.lead_tright:SetAnchor(TOPRIGHT, content, TOPRIGHT, -2, baseline_y + 3)
  controls.lead_tright:SetText("death"); controls.lead_tright:SetHidden(false)
end

local function render_types(rec)
  local content = controls.content
  local groups  = rec.pressure and rec.pressure.types
  local n = (groups and groups.count) or 0
  if n > MAX_TYPES then n = MAX_TYPES end
  local DTC = Verditer.DamageTypeColors
  local CELL = 13 + 34
  local x = 2
  for i = 1, MAX_TYPES do
    local t = controls.types[i]
    if i <= n then
      local g     = groups[i]
      local share = math_floor((g.share or 0) * 100 + 0.5)
      t.sw:ClearAnchors()
      t.sw:SetAnchor(TOPLEFT, content, TOPLEFT, x, TYPE_Y + 1)
      t.sw:SetColor(g.r, g.g, g.b, 1.0)
      t.sw:SetHidden(false)
      t.lbl:ClearAnchors()
      t.lbl:SetAnchor(TOPLEFT, content, TOPLEFT, x + 13, TYPE_Y)
      t.lbl:SetText(string_format("%d%%", share))
      t.lbl:SetHidden(false)
      local tnm = (DTC and DTC.name) and DTC.name(g.dt) or "Damage"
      t.tip = string_format("|c%s%s|r  —  %d%%", hexcol(g.r, g.g, g.b), tnm, share)
      t.hit:ClearAnchors()
      t.hit:SetAnchor(TOPLEFT, content, TOPLEFT, x, TYPE_Y - 1)
      t.hit:SetDimensions(CELL, 16)
      t.hit:SetHidden(false)
      x = x + CELL
    else
      t.sw:SetHidden(true)
      t.lbl:SetHidden(true)
      t.hit:SetHidden(true)
    end
  end
end

local function populate(rec)
  local k = rec.killer
  controls.killer_icon:SetTexture(k and k.icon or FILL)
  controls.k_ability:SetText(k and k.name ~= "" and k.name or GetString(VERDITER_RECAP_UNKNOWN))

  local from = (k and k.attacker ~= "" and k.attacker) or nil
  controls.k_from:SetText(from and (GetString(VERDITER_RECAP_FROM) .. " " .. from)
                               or GetString(VERDITER_RECAP_FROM_ENV))

  if (rec.overkill_pct or 0) > 0 then
    controls.overkill:SetText(string_format(GetString(VERDITER_RECAP_OVERKILL),
                                            math_floor(rec.overkill_pct * 100 + 0.5)))
    controls.overkill:SetHidden(false)
  else
    controls.overkill:SetHidden(true)
  end

  local zone = rec.zone or ""
  local ago  = ago_text(rec.ts)
  if zone ~= "" and ago ~= "" then
    controls.zone:SetText(zone .. "  ·  " .. ago)
  else
    controls.zone:SetText(ago ~= "" and ago or zone)
  end

  for i = 1, MAX_ROWS do
    local row = controls.rows[i]
    local a   = rec.attacks[i]
    if a then
      row.icon:SetTexture(a.icon or FILL)
      row.icon:SetHidden(false)
      local nm = a.name
      if a.hits and a.hits > 1 then nm = nm .. " x" .. a.hits end
      row.name:SetText(nm)
      row.dmg:SetText(commafy(a.dmg))
      row.kb:SetText(a.kb and GetString(VERDITER_RECAP_KB) or "")
      row.who:SetText(a.attacker or "")
      row.name:SetHidden(false); row.dmg:SetHidden(false)
      row.kb:SetHidden(false);   row.who:SetHidden(false)
    else
      row.icon:SetHidden(true)
      row.name:SetHidden(true); row.dmg:SetHidden(true)
      row.kb:SetHidden(true);   row.who:SetHidden(true)
    end
  end

  local p = rec.pressure or {}
  local total = (p.abs or 0) + (p.dtps or 0)
  local mit   = (total > 0) and math_floor((p.abs or 0) / total * 100 + 0.5) or 0
  controls.pressure:SetText(string_format(GetString(VERDITER_RECAP_PRESSURE),
                            abbr(p.peak_dtps or 0), p.attackers or 0, abbr(p.abs or 0), mit))

  render_lead(rec)
  render_types(rec)

  local idx, total = Verditer.DeathRecap.selected_idx(), Verditer.DeathRecap.count()
  controls.index:SetText(string_format("%d / %d", idx, total))
end

function M.show_record(idx)
  if not Verditer.DeathRecap.select(idx) then return end
  controls.window:SetHidden(false)
  populate(Verditer.DeathRecap.get(idx))
end

function M.on_prev()
  local i = Verditer.DeathRecap.selected_idx() - 1
  if i >= 1 then Verditer.Sound.play("PAGE"); M.show_record(i) end
end

function M.on_next()
  local i = Verditer.DeathRecap.selected_idx() + 1
  if i <= Verditer.DeathRecap.count() then Verditer.Sound.play("PAGE"); M.show_record(i) end
end

function M.on_close()
  Verditer.Sound.play("WINDOW_CLOSE")
  controls.window:SetHidden(true)
end

function M.on_export()
  Verditer.Export.show_text(
    "Per-death export is coming. For now this is the recorded session from the graph window.",
    (Verditer.Export.build_csv()) or "")
end

function M.on_move_stop()
  local sv = Verditer.SavedVars
  if not sv then return end
  sv.recap = sv.recap or {}
  sv.recap.x, sv.recap.y = controls.window:GetCenter()
end

function M.on_resize_stop()
  local sv = Verditer.SavedVars
  if sv then
    sv.recap = sv.recap or {}
    sv.recap.w, sv.recap.h = controls.window:GetDimensions()
  end
  if not controls.window:IsHidden() and Verditer.DeathRecap.count() > 0 then
    populate(Verditer.DeathRecap.get(Verditer.DeathRecap.selected_idx()))
  end
end

function M.toggle()
  if controls.window:IsHidden() then
    if Verditer.DeathRecap.count() > 0 then
      Verditer.Sound.play("WINDOW_OPEN")
      M.show_record(Verditer.DeathRecap.selected_idx())
    end
  else
    Verditer.Sound.play("WINDOW_CLOSE")
    controls.window:SetHidden(true)
  end
end

function M.init()
  controls.window  = VerditerRecap
  controls.content = VerditerRecapContent
  controls.title   = VerditerRecapTitleLabel
  controls.zone    = VerditerRecapZoneLabel
  controls.index   = VerditerRecapIndexLabel
  controls.export  = VerditerRecapExportBtn

  controls.title:SetText(GetString(VERDITER_RECAP_TITLE))
  controls.title:SetColor(C_TITLE.r, C_TITLE.g, C_TITLE.b, C_TITLE.a)
  controls.zone:SetColor(C_SUB.r, C_SUB.g, C_SUB.b, C_SUB.a)
  controls.index:SetColor(C_SUB.r, C_SUB.g, C_SUB.b, C_SUB.a)
  controls.export:SetText(GetString(VERDITER_RECAP_EXPORT))

  local EDGE = Verditer.Constants.BRAND.EDGE
  VerditerRecapBg:SetCenterColor(TINT.r, TINT.g, TINT.b, 0.92)
  VerditerRecapBg:SetEdgeColor(EDGE.r, EDGE.g, EDGE.b, 1.0)

  controls.window:SetMovable(true)
  controls.window:SetResizeHandleSize(8)
  controls.window:SetDimensionConstraints(460, 470, 1000, 760)

  build_content()

  local sv = Verditer.SavedVars
  if sv then
    sv.recap = sv.recap or {}
    if sv.recap.w then controls.window:SetDimensions(sv.recap.w, sv.recap.h) end
    if sv.recap.x then
      controls.window:ClearAnchors()
      controls.window:SetAnchor(CENTER, GuiRoot, TOPLEFT, sv.recap.x, sv.recap.y)
    end
  end

  log:info("init")
end
