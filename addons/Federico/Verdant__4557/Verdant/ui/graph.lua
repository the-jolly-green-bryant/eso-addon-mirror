Verdant = Verdant or {}
Verdant.Graph = {}
local M = Verdant.Graph

local api  = Verdant.zenimax.api
local zui  = Verdant.zenimax.ui
local zc   = Verdant.zenimax.constants
local zev  = Verdant.zenimax.events
local WINDOW_MANAGER             = zui.WINDOW_MANAGER
local GetGameTimeMilliseconds    = api.GetGameTimeMilliseconds
local GetString                  = api.GetString
local math_max                   = math.max
local math_floor                 = math.floor
local string_format              = string.format

local log               = Verdant.Log.for_module("graph")
local TOPLEFT           = zc.TOPLEFT
local TOPRIGHT          = zc.TOPRIGHT
local BOTTOMLEFT        = zc.BOTTOMLEFT
local BOTTOM            = zc.BOTTOM
local BOTTOMRIGHT       = zc.BOTTOMRIGHT
local CENTER            = zc.CENTER
local GuiRoot           = zc.GuiRoot
local CT_TEXTURE        = zc.CT_TEXTURE
local CT_LABEL          = zc.CT_LABEL
local TEXT_ALIGN_LEFT   = zc.TEXT_ALIGN_LEFT
local TEXT_ALIGN_CENTER = zc.TEXT_ALIGN_CENTER
local TEXT_ALIGN_RIGHT  = zc.TEXT_ALIGN_RIGHT
local TEXT_ALIGN_BOTTOM = zc.TEXT_ALIGN_BOTTOM

-- Colors matching bar.lua
local C_EHPS      = { r = 0.55, g = 0.92, b = 0.62, a = 0.90 }  -- pastel green fill
local C_MPS       = { r = 0.95, g = 0.68, b = 0.83, a = 0.90 }  -- pastel pink fill
local C_LINE_EHPS = { r = 0.65, g = 1.00, b = 0.72, a = 1.00 }  -- brighter green line
local C_LINE_EMS  = { r = 1.00, g = 0.78, b = 0.90, a = 1.00 }  -- brighter pink line

local C_NONCRIT   = { r = 0.34, g = 0.55, b = 0.40, a = 0.90 }  -- muted green base
local C_CRIT      = { r = 1.00, g = 0.85, b = 0.40, a = 0.96 }  -- bright gold (crit pops)

local C_VIEWPORT  = { r = 0.78, g = 1.00, b = 0.86 }

local FILL_TEXTURE   = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local FILL_T, FILL_B = 0, 0.53125
local LINE_THICKNESS = 2
local LABEL_H        = 12
local N_HGRID      = 3
local N_VGRID      = 3
local TIME_STRIP_H = 18
local C_GRID_LINE = { r = 0.55, g = 0.58, b = 0.70, a = 0.25 }
local C_GRID_LBL  = { r = 0.82, g = 0.85, b = 0.90, a = 0.92 }
local C_TIME_LBL  = { r = 0.68, g = 0.70, b = 0.75, a = 0.85 }


local controls           = {}
local recording_start_ms = 0

local VIEW_EMS    = 1
local VIEW_SKILL  = 2
local VIEW_CRIT   = 3
local VIEW_LABELS = { "EMS", "SKILL", "CRIT" }
local current_view = VIEW_EMS

-- SKILL view shield orientation: false = shields grow UP from the subplot floor
-- (default); true = shields hang DOWN from the ceiling, mirroring the healing bars
-- above them (Verditer-OUTCOME-style diverging look). Toggled from settings.
local shield_down = false

-- ── Hover (Datadog-style, ported from Verditer) ───────────────────────────────
-- Verdant has THREE canvases: the main one (VIEW_EMS / VIEW_CRIT) and the SKILL
-- view's split top (eHPS) + bottom (MPS). Each gets its own hit index. Frozen-session
-- only. hover_key (a group-key string) is applied to BOTH skill stacks.
local GetUIMousePosition = api.GetUIMousePosition
local hover_key  = nil
local hit_main = { cols = {}, n = 0 }
local hit_top  = { cols = {}, n = 0 }
local hit_bot  = { cols = {}, n = 0 }
local C_DIM_BIAS = 0.05
local render_current_view

local FADE_MS = 120
local card_fader, crosshair_fader

local CARD_W, CARD_H = 210, 56
local CARD_ROW_H     = 16
local CARD_MAX_ROWS  = 5
local CARD_ROWS_Y0   = 54
local C_CARD_BG     = { r = 0.05, g = 0.11, b = 0.07, a = 0.96 }
local C_CARD_ACCENT = { r = 0.40, g = 0.85, b = 0.52, a = 1.0 }
local C_CARD_STAT   = { r = 0.84, g = 0.92, b = 0.86, a = 1.0 }
local C_CARD_NAME   = { r = 0.90, g = 1.00, b = 0.92, a = 1.0 }
local C_CARD_TIME   = { r = 0.64, g = 0.72, b = 0.66, a = 1.0 }
local C_CROSSHAIR   = { r = 0.50, g = 1.00, b = 0.62, a = 0.50 }

local function fmt_val(v)
  return ZO_AbbreviateAndLocalizeNumber(math_floor(v), 0, false)
end

local function fmt_secs(ms)
  local s = math_floor(ms / 1000)
  if s >= 60 then return string_format("%d:%02d", math_floor(s / 60), s % 60) end
  return s .. "s"
end

local Pool = Verdant.lib.plot.Pool

local function fill_factory(c)
  c:SetTexture(FILL_TEXTURE)
  c:SetTextureCoords(0, 1, FILL_T, FILL_B)
  c:SetPixelRoundingEnabled(false)
end

local function fill_reset(c)
  c:SetHidden(true)
end

local function line_factory(line)
  line:SetThickness(LINE_THICKNESS)
end

local function line_reset(line)
  line:SetHidden(true)
  line:ClearAnchors()
end

local function make_fill_pool(name_prefix)
  return Pool.new(name_prefix, controls.canvas, CT_TEXTURE, fill_factory, fill_reset)
end

local function make_skill_fill_pool(name_prefix, canvas_key)
  return Pool.new(name_prefix, controls[canvas_key], CT_TEXTURE, fill_factory, fill_reset)
end

local function make_line_pool(name_prefix)
  return Pool.new_virtual(name_prefix, controls.canvas, "VerdantGraphLineTemplate", line_factory, line_reset)
end

local function make_skill_line_pool(name_prefix, canvas_key)
  return Pool.new_virtual(name_prefix, controls[canvas_key], "VerdantGraphLineTemplate", line_factory, line_reset)
end

local function create_grid(prefix, parent_ctrl)
  local WM  = WINDOW_MANAGER
  local obj = { hlines = {}, vlines = {}, ylabels = {} }

  for i = 1, N_HGRID do
    local gl = WM:CreateControl(prefix .. "H" .. i, parent_ctrl, CT_TEXTURE)
    gl:SetTexture(FILL_TEXTURE)
    gl:SetTextureCoords(0, 1, 0, 0.05)
    gl:SetHeight(1)
    gl:SetColor(C_GRID_LINE.r, C_GRID_LINE.g, C_GRID_LINE.b, C_GRID_LINE.a)
    gl:SetHidden(true)
    obj.hlines[i] = gl

    local lbl = WM:CreateControl(prefix .. "YL" .. i, parent_ctrl, CT_LABEL)
    lbl:SetFont("ZoFontGameSmall")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    lbl:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    lbl:SetColor(C_GRID_LBL.r, C_GRID_LBL.g, C_GRID_LBL.b, C_GRID_LBL.a)
    lbl:SetDimensions(54, 10)
    lbl:SetHidden(true)
    obj.ylabels[i] = lbl
  end

  for i = 1, N_VGRID do
    local vl = WM:CreateControl(prefix .. "V" .. i, parent_ctrl, CT_TEXTURE)
    vl:SetTexture(FILL_TEXTURE)
    vl:SetTextureCoords(0, 0.05, 0, 1)
    vl:SetWidth(1)
    vl:SetColor(C_GRID_LINE.r, C_GRID_LINE.g, C_GRID_LINE.b, C_GRID_LINE.a)
    vl:SetHidden(true)
    obj.vlines[i] = vl
  end

  local function make_time_lbl(name, align)
    local t = WM:CreateControl(name, parent_ctrl, CT_LABEL)
    t:SetFont("ZoFontGameSmall")
    t:SetHorizontalAlignment(align)
    t:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    t:SetColor(C_TIME_LBL.r, C_TIME_LBL.g, C_TIME_LBL.b, C_TIME_LBL.a)
    t:SetDimensions(44, 10)
    t:SetHidden(true)
    return t
  end
  obj.time_l = make_time_lbl(prefix .. "TL", TEXT_ALIGN_LEFT)
  obj.time_m = make_time_lbl(prefix .. "TM", TEXT_ALIGN_CENTER)
  obj.time_r = make_time_lbl(prefix .. "TR", TEXT_ALIGN_RIGHT)

  return obj
end

local function hide_grid(grid)
  for i = 1, N_HGRID do
    grid.hlines[i]:SetHidden(true)
    grid.ylabels[i]:SetHidden(true)
  end
  for i = 1, N_VGRID do
    grid.vlines[i]:SetHidden(true)
  end
  grid.time_l:SetHidden(true)
  grid.time_m:SetHidden(true)
  grid.time_r:SetHidden(true)
end

local function draw_grid(grid, canvas, max_val, span_ms, flip)
  local cw = canvas:GetWidth()
  local ch = canvas:GetHeight()
  if cw <= 0 or ch <= 0 then
    hide_grid(grid)
    return
  end

  local has_y    = (max_val > 0)
  local has_time = (span_ms > 0)
  if not has_y and not has_time then
    hide_grid(grid)
    return
  end

  local y_base   = has_time and TIME_STRIP_H or 0
  local ch_plot  = math_max(1, ch - y_base)

  if has_y then
    for i = 1, N_HGRID do
      local frac = i / (N_HGRID + 1)
      local pos  = flip and (1 - frac) or frac
      local y    = y_base + math_floor(ch_plot * pos)

      local gl = grid.hlines[i]
      gl:ClearAnchors()
      gl:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT,  0, -y)
      gl:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, 0, -y)
      gl:SetHidden(false)

      local lbl = grid.ylabels[i]
      lbl:ClearAnchors()
      lbl:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -(y + 1))
      lbl:SetText(fmt_val(max_val * frac))
      lbl:SetHidden(false)
    end
  else
    for i = 1, N_HGRID do
      grid.hlines[i]:SetHidden(true)
      grid.ylabels[i]:SetHidden(true)
    end
  end

  for i = 1, N_VGRID do
    local frac = i / (N_VGRID + 1)
    local x    = math_floor(cw * frac)

    local vl = grid.vlines[i]
    vl:ClearAnchors()
    vl:SetAnchor(TOPLEFT,    canvas, TOPLEFT,    x, 0)
    vl:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -y_base)
    vl:SetHidden(false)
  end

  if has_time then
    grid.time_l:ClearAnchors()
    grid.time_l:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT,  2, 0)
    grid.time_l:SetText("0s")
    grid.time_l:SetHidden(false)

    grid.time_m:ClearAnchors()
    grid.time_m:SetAnchor(BOTTOM, canvas, BOTTOM, 0, 0)
    grid.time_m:SetText(fmt_secs(span_ms / 2))
    grid.time_m:SetHidden(false)

    grid.time_r:ClearAnchors()
    grid.time_r:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, -2, 0)
    grid.time_r:SetText(fmt_secs(span_ms))
    grid.time_r:SetHidden(false)
  else
    grid.time_l:SetHidden(true)
    grid.time_m:SetHidden(true)
    grid.time_r:SetHidden(true)
  end
end

local function release_all_pools()
  controls.pool_ehps:ReleaseAllObjects()
  controls.pool_mps:ReleaseAllObjects()
  controls.pool_line_ehps:ReleaseAllObjects()
  controls.pool_line_ems:ReleaseAllObjects()
  controls.pool_skill_top:ReleaseAllObjects()
  controls.pool_skill_bot:ReleaseAllObjects()
  controls.pool_line_skill_top:ReleaseAllObjects()
  controls.pool_line_skill_bot:ReleaseAllObjects()
end

local function hide_all_grids()
  hide_grid(controls.grid_ems)
  hide_grid(controls.grid_top)
  hide_grid(controls.grid_bot)
end

local function layout_skill_area()
  local sa = controls.skill_area
  local sw = sa:GetWidth()
  local sh = sa:GetHeight()
  if sw <= 0 or sh <= 0 then return end

  local usable = sh - LABEL_H * 2 - 4
  if usable < 2 then return end
  local top_h = math_floor(usable / 2)
  local bot_h = usable - top_h
  local mid_y = LABEL_H + top_h + 2

  controls.ehps_label:ClearAnchors()
  controls.ehps_label:SetAnchor(TOPLEFT, sa, TOPLEFT, 0, 0)
  controls.ehps_label:SetDimensions(sw, LABEL_H)

  controls.ehps_canvas:ClearAnchors()
  controls.ehps_canvas:SetAnchor(TOPLEFT, sa, TOPLEFT, 0, LABEL_H)
  controls.ehps_canvas:SetDimensions(sw, top_h)

  if shield_down then
    controls.mps_canvas:ClearAnchors()
    controls.mps_canvas:SetAnchor(TOPLEFT, sa, TOPLEFT, 0, LABEL_H + top_h)
    controls.mps_canvas:SetDimensions(sw, bot_h)

    controls.mps_label:ClearAnchors()
    controls.mps_label:SetAnchor(TOPLEFT, sa, TOPLEFT, 0, LABEL_H + top_h + bot_h + 2)
    controls.mps_label:SetDimensions(sw, LABEL_H)
  else
    controls.mps_label:ClearAnchors()
    controls.mps_label:SetAnchor(TOPLEFT, sa, TOPLEFT, 0, mid_y)
    controls.mps_label:SetDimensions(sw, LABEL_H)

    controls.mps_canvas:ClearAnchors()
    controls.mps_canvas:SetAnchor(TOPLEFT, sa, TOPLEFT, 0, mid_y + LABEL_H)
    controls.mps_canvas:SetDimensions(sw, bot_h)
  end
end

local r1_xs, r1_ehps_hs, r1_ems_hs = {}, {}, {}
local r2_xs_top, r2_colh_top       = {}, {}
local r2_xs_bot, r2_colh_bot       = {}, {}
local r3_xs, r3_top_hs             = {}, {}

local MIN_COL_PX = 2
local dec_cols   = {}

local function decimate(cw)
  local TB       = Verdant.TemporalBuffer
  local capacity = TB.capacity()
  local n        = TB.count()
  local num_cols = math_floor(cw / MIN_COL_PX)
  if num_cols < 1 then num_cols = 1 end
  if num_cols > capacity then num_cols = capacity end
  local offset   = capacity - n
  local m, cur_c = 0, -1
  local col
  TB.iterate(function(i, s)
    local c   = math_floor((offset + i - 1) * num_cols / capacity)
    local ems = s.eHPS + s.MPS
    if c ~= cur_c then
      m = m + 1
      col = dec_cols[m]
      if not col then col = {}; dec_cols[m] = col end
      col.c = c; col.t = s.t
      col.ems_peak = ems; col.e1 = s.eHPS; col.m1 = s.MPS
      col.eHPS = s.eHPS; col.ehps_groups = s.ehps_groups; col.ehps_abilities = s.ehps_abilities
      col.noncrit = s.noncrit; col.crit = s.crit
      col.MPS = s.MPS; col.mps_groups = s.mps_groups; col.mps_abilities = s.mps_abilities
      cur_c = c
    else
      if ems > col.ems_peak then col.ems_peak = ems; col.e1 = s.eHPS; col.m1 = s.MPS end
      if s.eHPS > col.eHPS then    -- eHPS-peak: drives VIEW2-top stack + VIEW3 crit split
        col.eHPS = s.eHPS; col.ehps_groups = s.ehps_groups; col.ehps_abilities = s.ehps_abilities
        col.noncrit = s.noncrit; col.crit = s.crit
      end
      if s.MPS > col.MPS then col.MPS = s.MPS; col.mps_groups = s.mps_groups; col.mps_abilities = s.mps_abilities end  -- MPS-peak
      col.t = s.t
    end
  end)
  local col_w   = cw / num_cols
  local bar_gap = (col_w > 3) and 1 or 0
  return m, num_cols, col_w, bar_gap
end

local function dec_rect(c, num_cols, cw)
  local left  = math_floor(c       * cw / num_cols + 0.5)
  local right = math_floor((c + 1) * cw / num_cols + 0.5)
  return left, right
end

local function make_fader(control)
  return { anim = ZO_AlphaAnimation:New(control), control = control, visible = false }
end
local function fade_in(f)
  if not f or f.visible then return end
  f.visible = true
  f.anim:FadeIn(0, FADE_MS)
end
local function fade_out(f)
  if not f or not f.visible then return end
  f.visible = false
  local control = f.control
  f.anim:FadeOut(0, FADE_MS, nil, function() control:SetHidden(true) end)
end

local function hexc(c)
  return string_format("%02x%02x%02x",
    math_floor(c.r * 255 + 0.5), math_floor(c.g * 255 + 0.5), math_floor(c.b * 255 + 0.5))
end

local function hover_allowed()
  return not Verdant.TemporalBuffer.is_recording()
     and Verdant.TemporalBuffer.count() > 0
     and not controls.window:IsHidden()
end

local function hover_label(key)
  if not key or key == "" then return "Skill" end
  if key == "other" then return "Other" end
  return (tostring(key):gsub("_", " "))
end

local function stop_hover_poll() zev.unregister_update("VerdantHoverPoll") end

local function hide_hover_ui()
  fade_out(card_fader)
  fade_out(crosshair_fader)
end

local function build_hover_card()
  local WM   = WINDOW_MANAGER
  local root = WM:CreateControl("VerdantHoverCard", controls.window, zc.CT_CONTROL)
  root:SetDimensions(CARD_W, CARD_H)
  root:SetMouseEnabled(false)
  root:SetDrawLevel(20)
  root:SetAlpha(0)
  root:SetHidden(true)

  local bg = WM:CreateControl("VerdantHoverCardBg", root, CT_TEXTURE)
  bg:SetTexture(FILL_TEXTURE)
  bg:SetTextureCoords(0, 1, 0, 0.05)
  bg:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
  bg:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
  bg:SetColor(C_CARD_BG.r, C_CARD_BG.g, C_CARD_BG.b, C_CARD_BG.a)

  local accent = WM:CreateControl("VerdantHoverCardAccent", root, CT_TEXTURE)
  accent:SetTexture(FILL_TEXTURE)
  accent:SetTextureCoords(0, 0.05, 0, 1)
  accent:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
  accent:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 0, 0)
  accent:SetWidth(3)
  accent:SetColor(C_CARD_ACCENT.r, C_CARD_ACCENT.g, C_CARD_ACCENT.b, 1.0)

  local swatch = WM:CreateControl("VerdantHoverCardSwatch", root, CT_TEXTURE)
  swatch:SetTexture(FILL_TEXTURE)
  swatch:SetTextureCoords(0, 1, 0, 0.05)
  swatch:SetDimensions(10, 10)
  swatch:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 9)

  local name = WM:CreateControl("VerdantHoverCardName", root, CT_LABEL)
  name:SetFont("ZoFontGameBold")
  name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  name:SetAnchor(TOPLEFT, root, TOPLEFT, 28, 6)
  name:SetDimensions(CARD_W - 36, 16)

  local stat = WM:CreateControl("VerdantHoverCardStat", root, CT_LABEL)
  stat:SetFont("ZoFontGameSmall")
  stat:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  stat:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  stat:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
  stat:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 24)
  stat:SetDimensions(CARD_W - 20, 14)

  local time = WM:CreateControl("VerdantHoverCardTime", root, CT_LABEL)
  time:SetFont("ZoFontGameSmall")
  time:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  time:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  time:SetColor(C_CARD_TIME.r, C_CARD_TIME.g, C_CARD_TIME.b, 1.0)
  time:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 40)
  time:SetDimensions(CARD_W - 20, 12)

  local rows = {}
  for i = 1, CARD_MAX_ROWS do
    local y = CARD_ROWS_Y0 + (i - 1) * CARD_ROW_H

    local icon = WM:CreateControl("VerdantHoverCardIcon" .. i, root, CT_TEXTURE)
    icon:SetDimensions(13, 13)
    icon:SetAnchor(TOPLEFT, root, TOPLEFT, 12, y + 1)
    icon:SetHidden(true)

    local rn = WM:CreateControl("VerdantHoverCardRowName" .. i, root, CT_LABEL)
    rn:SetFont("ZoFontGameSmall")
    rn:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    rn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rn:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
    rn:SetAnchor(TOPLEFT, root, TOPLEFT, 30, y)
    rn:SetDimensions(108, CARD_ROW_H)
    rn:SetHidden(true)

    local rv = WM:CreateControl("VerdantHoverCardRowVal" .. i, root, CT_LABEL)
    rv:SetFont("ZoFontGameSmall")
    rv:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    rv:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rv:SetColor(C_CARD_TIME.r, C_CARD_TIME.g, C_CARD_TIME.b, 1.0)
    rv:SetAnchor(TOPRIGHT, root, TOPRIGHT, -8, y)
    rv:SetDimensions(60, CARD_ROW_H)
    rv:SetHidden(true)

    rows[i] = { icon = icon, name = rn, val = rv }
  end

  controls.card = { root = root, swatch = swatch, name = name, stat = stat, time = time, rows = rows }
end

local function clear_card_rows(card)
  local rows = card.rows
  if not rows then return end
  for i = 1, CARD_MAX_ROWS do
    local r = rows[i]
    r.icon:SetHidden(true); r.name:SetHidden(true); r.val:SetHidden(true)
  end
end

local function position_card(mx, my)
  local card = controls.card
  local sw, sh = GuiRoot:GetDimensions()
  local h = card.root:GetHeight()
  local x = mx + 16
  local y = my + 18
  if x + CARD_W > sw - 4 then x = mx - CARD_W - 16 end
  if x < 4 then x = 4 end
  if y + h > sh - 4 then y = my - h - 18 end
  if y < 4 then y = 4 end
  card.root:ClearAnchors()
  card.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  fade_in(card_fader)
end

local function show_card(band, col, unit, mx, my, elapsed_ms)
  local card = controls.card
  if not card then return end
  local total = band.total or 0
  card.swatch:SetColor(band.r, band.g, band.b, 1.0)
  card.name:SetColor(band.r, band.g, band.b, 1.0)
  card.name:SetText(hover_label(band.key))
  local pct = math_floor((band.share or 0) * 100 + 0.5)
  local val = (band.share or 0) * total
  card.stat:SetText(string_format("%s %s  ·  %d%%", fmt_val(val), unit, pct))
  card.time:SetText("t  " .. fmt_secs(elapsed_ms or 0))

  clear_card_rows(card)
  local shown = 0
  local list = nil
  if current_view == VIEW_SKILL and col then
    list = (unit == "MPS") and col.mps_abilities or col.ehps_abilities
  end
  if list and (list.count or 0) > 0 then
    local SC      = Verdant.SkillColors
    local n       = list.count
    local matched = 0
    for a = 1, n do
      local ab = list[a]
      if ab and ab.key == band.key then matched = matched + 1 end
    end
    for a = 1, n do
      if shown >= CARD_MAX_ROWS then break end
      local ab = list[a]
      if ab and ab.key == band.key then
        shown = shown + 1
        local row = card.rows[shown]
        if shown == CARD_MAX_ROWS and matched > CARD_MAX_ROWS then
          row.icon:SetHidden(true)
          row.name:SetText(string_format("+%d more", matched - (CARD_MAX_ROWS - 1)))
          row.name:SetColor(C_CARD_TIME.r, C_CARD_TIME.g, C_CARD_TIME.b, 1.0)
          row.name:SetHidden(false)
          row.val:SetText("")
          row.val:SetHidden(false)
          break
        end
        row.icon:SetTexture(SC.ability_icon(ab.id))
        row.icon:SetHidden(false)
        row.name:SetText(SC.ability_name(ab.id))
        row.name:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
        row.name:SetHidden(false)
        local av = (ab.share or 0) * total
        local ap = math_floor((ab.share or 0) * 100 + 0.5)
        row.val:SetText(string_format("%s · %d%%", fmt_val(av), ap))
        row.val:SetHidden(false)
      end
    end
  end
  card.root:SetHeight((shown > 0) and (CARD_ROWS_Y0 + shown * CARD_ROW_H + 4) or CARD_H)

  position_card(mx, my)
end

local function show_moment_card(swatch_c, name_text, stat_text, elapsed_ms, mx, my)
  local card = controls.card
  if not card then return end
  card.swatch:SetColor(swatch_c.r, swatch_c.g, swatch_c.b, 1.0)
  card.name:SetColor(C_CARD_NAME.r, C_CARD_NAME.g, C_CARD_NAME.b, 1.0)
  card.name:SetText(name_text)
  card.stat:SetText(stat_text)
  card.time:SetText("t  " .. fmt_secs(elapsed_ms or 0))
  clear_card_rows(card)
  card.root:SetHeight(CARD_H)
  position_card(mx, my)
end

local function hit_begin(H, n) H.n = n end

local function hit_col(H, i, x, bw, s)
  if i == 1 then H.t0 = s.t end
  local col = H.cols[i]
  if not col then col = { bands = {} }; H.cols[i] = col end
  col.x0 = x; col.x1 = x + bw; col.nb = 0; col.t = s.t
  col.ehps = s.e1; col.mps = s.m1; col.crit = s.crit; col.noncrit = s.noncrit
  col.ehps_abilities = s.ehps_abilities; col.mps_abilities = s.mps_abilities
  return col
end

local function hover_pick(H, rel_x, height_above)
  if H.n == 0 then return nil, nil end
  local col = nil
  for i = 1, H.n do
    local c = H.cols[i]
    if c and rel_x >= c.x0 and rel_x <= c.x1 then col = c; break end
  end
  if not col then return nil, nil end
  local band = nil
  for b = 1, col.nb do
    local bd = col.bands[b]
    if height_above >= bd.lo and height_above <= bd.hi then band = bd; break end
  end
  return band, col
end

local function probe(canvas, H, mx, my)
  local rel_x = mx - canvas:GetLeft()
  local above = canvas:GetBottom() - my
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  if rel_x < 0 or rel_x > cw or above < 0 or above > ch then return false end
  local band, col = hover_pick(H, rel_x, above)
  return true, band, col
end

local function hover_poll()
  if not hover_allowed() then
    if hover_key ~= nil then hover_key = nil; render_current_view() end
    hide_hover_ui()
    return
  end
  local mx, my = GetUIMousePosition()
  local band, col, canvas, H, unit
  if current_view == VIEW_SKILL then
    local inside, b, c = probe(controls.ehps_canvas, hit_top, mx, my)
    if inside then band, col, canvas, H, unit = b, c, controls.ehps_canvas, hit_top, "HPS" end
    if not inside then
      inside, b, c = probe(controls.mps_canvas, hit_bot, mx, my)
      if inside then band, col, canvas, H, unit = b, c, controls.mps_canvas, hit_bot, "MPS" end
    end
  else
    local inside, b, c = probe(controls.canvas, hit_main, mx, my)
    if inside then band, col, canvas, H = b, c, controls.canvas, hit_main end
  end

  local new = band and band.key or nil
  if new ~= hover_key then hover_key = new; render_current_view() end

  if not col then hide_hover_ui(); return end

  if controls.crosshair then
    local cx = math_floor((col.x0 + col.x1) * 0.5)
    controls.crosshair:ClearAnchors()
    controls.crosshair:SetAnchor(TOPLEFT,    canvas, TOPLEFT,    cx, 0)
    controls.crosshair:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, cx, 0)
    fade_in(crosshair_fader)
  end

  local elapsed = (col.t and H.t0) and (col.t - H.t0) or 0
  if band then
    show_card(band, col, unit or "HPS", mx, my, elapsed)
  elseif current_view == VIEW_EMS then
    show_moment_card(C_EHPS, "Healing",
      string_format("|c%s%s HPS|r  ·  |c%s%s MPS|r",
        hexc(C_EHPS), fmt_val(col.ehps or 0), hexc(C_MPS), fmt_val(col.mps or 0)),
      elapsed, mx, my)
  elseif current_view == VIEW_CRIT then
    local tot = (col.crit or 0) + (col.noncrit or 0)
    local cp  = (tot > 0) and math_floor((col.crit or 0) / tot * 100 + 0.5) or 0
    show_moment_card(C_CRIT, "Crit",
      string_format("|c%s%d%% crit|r  ·  %s HPS", hexc(C_CRIT), cp, fmt_val(tot)),
      elapsed, mx, my)
  else
    fade_out(card_fader)
  end
end

local function update_hover_gate()
  local on    = hover_allowed()
  local skill = (current_view == VIEW_SKILL)
  if controls.hit_main then
    controls.hit_main:SetMouseEnabled(on and not skill)
    controls.hit_main:SetHidden(not (on and not skill))
  end
  if controls.hit_top then
    controls.hit_top:SetMouseEnabled(on and skill)
    controls.hit_top:SetHidden(not (on and skill))
  end
  if controls.hit_bot then
    controls.hit_bot:SetMouseEnabled(on and skill)
    controls.hit_bot:SetHidden(not (on and skill))
  end
  if not on then
    stop_hover_poll()
    hide_hover_ui()
    if hover_key ~= nil then
      hover_key = nil
      if not controls.window:IsHidden() then render_current_view() end
    end
  end
end

local function render_view1()
  controls.pool_ehps:ReleaseAllObjects()
  controls.pool_mps:ReleaseAllObjects()
  controls.pool_line_ehps:ReleaseAllObjects()
  controls.pool_line_ems:ReleaseAllObjects()

  local n = Verdant.TemporalBuffer.count()
  if n == 0 then
    controls.no_data:SetHidden(false)
    hide_grid(controls.grid_ems)
    return
  end
  controls.no_data:SetHidden(true)

  local canvas  = controls.canvas
  local cw      = canvas:GetWidth()
  local ch      = canvas:GetHeight()
  if cw <= 4 or ch <= 4 then return end

  local ch_plot = math_max(4, ch - TIME_STRIP_H)

  local max_ems = 0
  local t_first, t_last = 0, 0
  Verdant.TemporalBuffer.iterate(function(i, s)
    local ems = s.eHPS + s.MPS
    if ems > max_ems then max_ems = ems end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end)
  if max_ems <= 0 then return end

  draw_grid(controls.grid_ems, canvas, max_ems, t_last - t_first)


  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs          = r1_xs
  local ehps_hs     = r1_ehps_hs
  local ems_hs      = r1_ems_hs
  local capture = not Verdant.TemporalBuffer.is_recording()
  if capture then hit_begin(hit_main, m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x  = left
    local bw = math_max(1, right - left - bar_gap)
    if capture then hit_col(hit_main, i, left, right - left, s) end
    local xc = x + bw * 0.5

    local ehps_h = math_max(0, math_floor(ch_plot * (s.e1 / max_ems) + 0.5))
    local mps_h  = math_max(0, math_floor(ch_plot * (s.m1 / max_ems) + 0.5))

    xs[i]      = xc
    ehps_hs[i] = ehps_h
    ems_hs[i]  = ehps_h + mps_h

    if ehps_h > 0 then
      local te = controls.pool_ehps:AcquireObject()
      te:ClearAnchors()
      te:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
      te:SetWidth(bw)
      te:SetHeight(ehps_h)
      te:SetColor(C_EHPS.r, C_EHPS.g, C_EHPS.b, C_EHPS.a)
      te:SetHidden(false)
    end

    if mps_h > 0 then
      local tm = controls.pool_mps:AcquireObject()
      tm:ClearAnchors()
      tm:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(TIME_STRIP_H + ehps_h))
      tm:SetWidth(bw)
      tm:SetHeight(mps_h)
      tm:SetColor(C_MPS.r, C_MPS.g, C_MPS.b, C_MPS.a)
      tm:SetHidden(false)
    end
  end

  if col_w >= 3 then
    for i = 2, m do
      local x1, x2 = xs[i-1], xs[i]

      local le = controls.pool_line_ehps:AcquireObject()
      le:ClearAnchors()
      le:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, x1, -(ehps_hs[i-1] + TIME_STRIP_H))
      le:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, x2, -(ehps_hs[i]   + TIME_STRIP_H))
      le:SetColor(C_LINE_EHPS.r, C_LINE_EHPS.g, C_LINE_EHPS.b, C_LINE_EHPS.a)
      le:SetThickness(LINE_THICKNESS)
      le:SetHidden(false)

      local lm = controls.pool_line_ems:AcquireObject()
      lm:ClearAnchors()
      lm:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, x1, -(ems_hs[i-1] + TIME_STRIP_H))
      lm:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, x2, -(ems_hs[i]   + TIME_STRIP_H))
      lm:SetColor(C_LINE_EMS.r, C_LINE_EMS.g, C_LINE_EMS.b, C_LINE_EMS.a)
      lm:SetThickness(LINE_THICKNESS)
      lm:SetHidden(false)
    end
  end
end

local function render_view2()
  controls.pool_skill_top:ReleaseAllObjects()
  controls.pool_skill_bot:ReleaseAllObjects()
  controls.pool_line_skill_top:ReleaseAllObjects()
  controls.pool_line_skill_bot:ReleaseAllObjects()

  local n = Verdant.TemporalBuffer.count()
  if n == 0 then
    controls.no_data:SetHidden(false)
    hide_grid(controls.grid_top)
    hide_grid(controls.grid_bot)
    return
  end
  controls.no_data:SetHidden(true)

  local ec = controls.ehps_canvas
  local mc = controls.mps_canvas
  local cw = ec:GetWidth()
  if cw <= 0 then return end

  local max_ehps, max_mps = 0, 0
  local t_first, t_last   = 0, 0
  Verdant.TemporalBuffer.iterate(function(i, s)
    if s.eHPS > max_ehps then max_ehps = s.eHPS end
    if s.MPS  > max_mps  then max_mps  = s.MPS  end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end)
  local span_ms    = t_last - t_first
  draw_grid(controls.grid_top, ec, max_ehps, 0)
  draw_grid(controls.grid_bot, mc, max_mps, span_ms, shield_down)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local capture = not Verdant.TemporalBuffer.is_recording()
  local hk = hover_key

  if max_ehps > 0 then
    local ch     = ec:GetHeight()
    local xs     = r2_xs_top
    local col_hs = r2_colh_top
    if capture then hit_begin(hit_top, m) end

    for i = 1, m do
      local s = dec_cols[i]
      local left, right = dec_rect(s.c, num_cols, cw)
      local x     = left
      local bw    = math_max(1, right - left - bar_gap)
      local col_h = math_max(0, math_floor(ch * (s.eHPS / max_ehps) + 0.5))
      xs[i]      = x + bw * 0.5
      col_hs[i]  = col_h

      local col = capture and hit_col(hit_top, i, left, right - left, s) or nil

      local y_off   = 0
      local egroups = s.ehps_groups
      for gi = 1, egroups.count do
        local grp   = egroups[gi]
        local seg_h = math_max(1, math_floor(col_h * grp.share + 0.5))
        local t = controls.pool_skill_top:AcquireObject()
        t:ClearAnchors()
        t:SetAnchor(BOTTOMLEFT, ec, BOTTOMLEFT, x, -y_off)
        t:SetWidth(bw)
        t:SetHeight(seg_h)
        if hk ~= nil and grp.key ~= hk then
          t:SetColor(grp.r * 0.30 + C_DIM_BIAS, grp.g * 0.30 + C_DIM_BIAS,
                     grp.b * 0.30 + C_DIM_BIAS, 0.28)
        else
          t:SetColor(grp.r, grp.g, grp.b, grp.a)
        end
        t:SetHidden(false)

        if capture then
          local nb   = col.nb + 1
          local band = col.bands[nb]
          if not band then band = {}; col.bands[nb] = band end
          band.key   = grp.key
          band.lo    = y_off
          band.hi    = y_off + seg_h
          band.share = grp.share
          band.total = s.eHPS
          band.r = grp.r; band.g = grp.g; band.b = grp.b
          col.nb = nb
        end

        y_off = y_off + seg_h
      end
    end

    if col_w >= 3 then
      for i = 2, m do
        local le = controls.pool_line_skill_top:AcquireObject()
        le:ClearAnchors()
        le:SetAnchor(BOTTOMLEFT,  ec, BOTTOMLEFT, xs[i-1], -col_hs[i-1])
        le:SetAnchor(BOTTOMRIGHT, ec, BOTTOMLEFT, xs[i],   -col_hs[i])
        le:SetColor(C_LINE_EHPS.r, C_LINE_EHPS.g, C_LINE_EHPS.b, C_LINE_EHPS.a)
        le:SetThickness(LINE_THICKNESS)
        le:SetHidden(false)
      end
    end
  end

  if max_mps > 0 then
    local mc_h    = mc:GetHeight()
    local ch_plot = math_max(1, mc_h - TIME_STRIP_H)
    local xs      = r2_xs_bot
    local col_hs  = r2_colh_bot
    if capture then hit_begin(hit_bot, m) end

    for i = 1, m do
      local s = dec_cols[i]
      local left, right = dec_rect(s.c, num_cols, cw)
      local x     = left
      local bw    = math_max(1, right - left - bar_gap)
      local col_h = math_max(0, math_floor(ch_plot * (s.MPS / max_mps) + 0.5))
      xs[i]      = x + bw * 0.5
      col_hs[i]  = col_h

      local col = capture and hit_col(hit_bot, i, left, right - left, s) or nil

      local y_off   = 0
      local mgroups = s.mps_groups
      for gi = 1, mgroups.count do
        local grp   = mgroups[gi]
        local seg_h = math_max(1, math_floor(col_h * grp.share + 0.5))
        local t = controls.pool_skill_bot:AcquireObject()
        t:ClearAnchors()
        if shield_down then
          t:SetAnchor(TOPLEFT, mc, TOPLEFT, x, y_off)
        else
          t:SetAnchor(BOTTOMLEFT, mc, BOTTOMLEFT, x, -(y_off + TIME_STRIP_H))
        end
        t:SetWidth(bw)
        t:SetHeight(seg_h)
        if hk ~= nil and grp.key ~= hk then
          t:SetColor(grp.r * 0.30 + C_DIM_BIAS, grp.g * 0.30 + C_DIM_BIAS,
                     grp.b * 0.30 + C_DIM_BIAS, 0.28)
        else
          t:SetColor(grp.r, grp.g, grp.b, grp.a)
        end
        t:SetHidden(false)

        if capture then
          local nb   = col.nb + 1
          local band = col.bands[nb]
          if not band then band = {}; col.bands[nb] = band end
          band.key   = grp.key
          if shield_down then
            band.lo  = mc_h - (y_off + seg_h)
            band.hi  = mc_h - y_off
          else
            band.lo  = TIME_STRIP_H + y_off
            band.hi  = TIME_STRIP_H + y_off + seg_h
          end
          band.share = grp.share
          band.total = s.MPS
          band.r = grp.r; band.g = grp.g; band.b = grp.b
          col.nb = nb
        end

        y_off = y_off + seg_h
      end
    end

    if col_w >= 3 then
      for i = 2, m do
        local lm = controls.pool_line_skill_bot:AcquireObject()
        lm:ClearAnchors()
        if shield_down then
          lm:SetAnchor(BOTTOMLEFT,  mc, BOTTOMLEFT, xs[i-1], -(mc_h - col_hs[i-1]))
          lm:SetAnchor(BOTTOMRIGHT, mc, BOTTOMLEFT, xs[i],   -(mc_h - col_hs[i]))
        else
          lm:SetAnchor(BOTTOMLEFT,  mc, BOTTOMLEFT, xs[i-1], -(col_hs[i-1] + TIME_STRIP_H))
          lm:SetAnchor(BOTTOMRIGHT, mc, BOTTOMLEFT, xs[i],   -(col_hs[i]   + TIME_STRIP_H))
        end
        lm:SetColor(C_LINE_EMS.r, C_LINE_EMS.g, C_LINE_EMS.b, C_LINE_EMS.a)
        lm:SetThickness(LINE_THICKNESS)
        lm:SetHidden(false)
      end
    end
  end
end

local function render_view3()
  controls.pool_ehps:ReleaseAllObjects()
  controls.pool_mps:ReleaseAllObjects()
  controls.pool_line_ehps:ReleaseAllObjects()
  controls.pool_line_ems:ReleaseAllObjects()

  local n = Verdant.TemporalBuffer.count()
  if n == 0 then
    controls.no_data:SetHidden(false)
    hide_grid(controls.grid_ems)
    return
  end
  controls.no_data:SetHidden(true)

  local canvas  = controls.canvas
  local cw      = canvas:GetWidth()
  local ch      = canvas:GetHeight()
  if cw <= 4 or ch <= 4 then return end
  local ch_plot = math_max(4, ch - TIME_STRIP_H)

  local max_ehps = 0
  local t_first, t_last = 0, 0
  Verdant.TemporalBuffer.iterate(function(i, s)
    if s.eHPS > max_ehps then max_ehps = s.eHPS end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end)
  if max_ehps <= 0 then
    hide_grid(controls.grid_ems)
    return
  end

  draw_grid(controls.grid_ems, canvas, max_ehps, t_last - t_first)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs          = r3_xs
  local top_hs      = r3_top_hs
  local capture = not Verdant.TemporalBuffer.is_recording()
  if capture then hit_begin(hit_main, m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x  = left
    local bw = math_max(1, right - left - bar_gap)
    if capture then hit_col(hit_main, i, left, right - left, s) end
    local noncrit_h = math_max(0, math_floor(ch_plot * (s.noncrit / max_ehps) + 0.5))
    local crit_h    = math_max(0, math_floor(ch_plot * (s.crit    / max_ehps) + 0.5))
    xs[i]     = x + bw * 0.5
    top_hs[i] = noncrit_h + crit_h


    if noncrit_h > 0 then
      local tn = controls.pool_ehps:AcquireObject()
      tn:ClearAnchors()
      tn:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
      tn:SetWidth(bw)
      tn:SetHeight(noncrit_h)
      tn:SetColor(C_NONCRIT.r, C_NONCRIT.g, C_NONCRIT.b, C_NONCRIT.a)
      tn:SetHidden(false)
    end


    if crit_h > 0 then
      local tc = controls.pool_mps:AcquireObject()
      tc:ClearAnchors()
      tc:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(TIME_STRIP_H + noncrit_h))
      tc:SetWidth(bw)
      tc:SetHeight(crit_h)
      tc:SetColor(C_CRIT.r, C_CRIT.g, C_CRIT.b, C_CRIT.a)
      tc:SetHidden(false)
    end
  end


  if col_w >= 3 then
    for i = 2, m do
      local lt = controls.pool_line_ehps:AcquireObject()
      lt:ClearAnchors()
      lt:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(top_hs[i-1] + TIME_STRIP_H))
      lt:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(top_hs[i]   + TIME_STRIP_H))
      lt:SetColor(C_LINE_EHPS.r, C_LINE_EHPS.g, C_LINE_EHPS.b, C_LINE_EHPS.a)
      lt:SetThickness(LINE_THICKNESS)
      lt:SetHidden(false)
    end
  end
end

function render_current_view()
  if current_view == VIEW_EMS then
    render_view1()
  elseif current_view == VIEW_CRIT then
    render_view3()
  else
    layout_skill_area()
    render_view2()
  end
end

local function refresh_button_colors()
  local recording = Verdant.TemporalBuffer.is_recording()
  controls.btn_record:SetEnabled(not recording)
  controls.btn_stop:SetEnabled(recording)
  update_hover_gate()
end

local function set_view(v)
  current_view = v
  controls.view_label:SetText(VIEW_LABELS[v])
  hover_key = nil

  local use_main_canvas = (v == VIEW_EMS or v == VIEW_CRIT)
  controls.canvas:SetHidden(not use_main_canvas)
  controls.skill_area:SetHidden(use_main_canvas)

  if Verdant.TemporalBuffer.count() == 0 then
    controls.no_data:SetHidden(false)
    update_hover_gate()
    return
  end
  controls.no_data:SetHidden(true)

  render_current_view()
  update_hover_gate()
end

local prof_enter = Verdant.Profiler.enter
local prof_exit  = Verdant.Profiler.exit

local sample_ehps_groups = { count = 0 }
local sample_mps_groups  = { count = 0 }
local sample_ehps_abilities = { count = 0 }
local sample_mps_abilities  = { count = 0 }

local function on_sample_update()
  prof_enter("graph.sample_tick")
  local now  = GetGameTimeMilliseconds()
  local ehps = Verdant.Metrics.eHPS(now)
  local mps  = Verdant.Metrics.MPS(now)
  local crit, noncrit = Verdant.Metrics.eHPS_crit_split(now)
  Verdant.Metrics.eHPS_by_group_into(sample_ehps_groups, now)
  Verdant.Metrics.MPS_by_group_into(sample_mps_groups, now)
  Verdant.Metrics.eHPS_by_ability_into(sample_ehps_abilities, now)
  Verdant.Metrics.MPS_by_ability_into(sample_mps_abilities, now)
  Verdant.TemporalBuffer.push(now, ehps, mps, crit, noncrit,
                              sample_ehps_groups, sample_mps_groups,
                              sample_ehps_abilities, sample_mps_abilities)

  local elapsed = math_floor((now - recording_start_ms) / 1000)
  controls.status:SetText(string_format("%d:%02d", math_floor(elapsed / 60), elapsed % 60))

  if not controls.window:IsHidden() then
    render_current_view()
  end
  prof_exit("graph.sample_tick")
end

function M.on_record_click()
  if Verdant.TemporalBuffer.is_recording() then return end
  log:info("record click")
  Verdant.TemporalBuffer.clear()
  release_all_pools()
  hide_all_grids()
  controls.no_data:SetHidden(false)
  Verdant.TemporalBuffer.start_recording()
  recording_start_ms = GetGameTimeMilliseconds()
  local sv       = Verdant.SavedVars
  local interval = (sv and sv.temporal and sv.temporal.sample_rate_ms)
                   or Verdant.Constants.TEMPORAL.SAMPLE_RATE_DEFAULT
  zev.register_update(Verdant.Constants.TEMPORAL.UPDATE_NAME, interval, on_sample_update)
  refresh_button_colors()
  controls.status:SetText("0:00")
end

function M.on_stop_click()
  if not Verdant.TemporalBuffer.is_recording() then return end
  log:info("stop click")
  Verdant.TemporalBuffer.stop_recording()
  zev.unregister_update(Verdant.Constants.TEMPORAL.UPDATE_NAME)
  refresh_button_colors()
  render_current_view()
end

function M.on_flush_click()
  if Verdant.TemporalBuffer.is_recording() then
    zev.unregister_update(Verdant.Constants.TEMPORAL.UPDATE_NAME)
    Verdant.TemporalBuffer.stop_recording()
  end
  Verdant.TemporalBuffer.clear()
  release_all_pools()
  hide_all_grids()
  refresh_button_colors()
  controls.status:SetText("")
  controls.no_data:SetHidden(false)
end

function M.on_close_click()
  Verdant.Visibility.set("graph", false)
  stop_hover_poll(); hide_hover_ui(); hover_key = nil
  release_all_pools()
end

function M.on_move_stop()
  local sv = Verdant.SavedVars
  if not sv then return end
  sv.temporal = sv.temporal or {}
  local x, y = controls.window:GetCenter()
  sv.temporal.graph_x = x
  sv.temporal.graph_y = y
end

function M.on_resize_stop()
  local sv = Verdant.SavedVars
  if sv then
    sv.temporal = sv.temporal or {}
    local w, h = controls.window:GetDimensions()
    sv.temporal.graph_w = w
    sv.temporal.graph_h = h
  end
  if not controls.window:IsHidden() then
    render_current_view()
  end
end

function M.prev_view()
  local v = current_view - 1
  if v < VIEW_EMS then v = VIEW_CRIT end
  release_all_pools()
  set_view(v)
end

function M.next_view()
  local v = current_view + 1
  if v > VIEW_CRIT then v = VIEW_EMS end
  release_all_pools()
  set_view(v)
end

function M.set_viewport_alpha(a)
  VerdantGraphWindowViewportBg:SetCenterColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, a)
end

function M.set_shield_down(on)
  shield_down = on and true or false
  if current_view == VIEW_SKILL and controls.window and not controls.window:IsHidden() then
    render_current_view()
  end
end

function M.get_shield_down() return shield_down end

function M.toggle()
  local now_visible = not Verdant.Visibility.get("graph")
  log:info("toggle ->", now_visible and "show" or "hide")
  Verdant.Visibility.set("graph", now_visible)
  if now_visible then
    local use_main_canvas = (current_view == VIEW_EMS or current_view == VIEW_CRIT)
    controls.canvas:SetHidden(not use_main_canvas)
    controls.skill_area:SetHidden(use_main_canvas)
    render_current_view()
    update_hover_gate()
  else
    stop_hover_poll(); hide_hover_ui(); hover_key = nil
    release_all_pools()
  end
end


function M.init()
  local WM = WINDOW_MANAGER

  controls.window        = VerdantGraphWindow
  controls.title         = VerdantGraphWindowTitleLabel
  controls.btn_record    = VerdantGraphWindowRecordBtn
  controls.btn_stop      = VerdantGraphWindowStopBtn
  controls.btn_flush     = VerdantGraphWindowFlushBtn
  controls.status        = VerdantGraphWindowStatusLabel
  controls.btn_prev_view = VerdantGraphWindowPrevViewBtn
  controls.view_label    = VerdantGraphWindowViewLabel
  controls.btn_next_view = VerdantGraphWindowNextViewBtn
  controls.viewport      = VerdantGraphWindowViewport
  controls.canvas        = VerdantGraphWindowViewportCanvas
  controls.no_data       = VerdantGraphWindowViewportNoDataLabel
  controls.skill_area    = VerdantGraphWindowViewportSkillArea
  controls.ehps_label    = VerdantGraphWindowViewportSkillAreaEhpsLabel
  controls.ehps_canvas   = VerdantGraphWindowViewportSkillAreaEhpsCanvas
  controls.mps_label     = VerdantGraphWindowViewportSkillAreaMpsLabel
  controls.mps_canvas    = VerdantGraphWindowViewportSkillAreaMpsCanvas

  local sv = Verdant.SavedVars
  sv.temporal = sv.temporal or {}
  if sv.temporal.graph_x then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(CENTER, GuiRoot, TOPLEFT, sv.temporal.graph_x, sv.temporal.graph_y)
  end
  if sv.temporal.graph_w then
    controls.window:SetDimensions(sv.temporal.graph_w, sv.temporal.graph_h)
  end

  controls.window:SetDimensionConstraints(360, 240, 1000, 700)

  VerdantGraphWindowBg:SetCenterColor(0, 0, 0, 0)
  VerdantGraphWindowChromeTop   :SetColor(0.62, 1.00, 0.74, 0.82)
  VerdantGraphWindowChromeBottom:SetColor(0.62, 1.00, 0.74, 0.82)
  VerdantGraphWindowChromeLeft  :SetColor(0.62, 1.00, 0.74, 0.82)
  VerdantGraphWindowChromeRight :SetColor(0.62, 1.00, 0.74, 0.82)
  VerdantGraphWindowBg:SetEdgeColor(0.42, 1.00, 0.60, 1.0)

  local sv_a = (Verdant.SavedVars and Verdant.SavedVars.temporal
                and Verdant.SavedVars.temporal.viewport_alpha_pct) or 30
  VerdantGraphWindowViewportBg:SetCenterColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, sv_a / 100)


  controls.grid_ems = create_grid("VerdantGridEms", controls.canvas)
  controls.grid_top = create_grid("VerdantGridTop", controls.ehps_canvas)
  controls.grid_bot = create_grid("VerdantGridBot", controls.mps_canvas)


  controls.pool_ehps           = make_fill_pool("VerdantGraphFillEhps")
  controls.pool_mps            = make_fill_pool("VerdantGraphFillMps")
  controls.pool_line_ehps      = make_line_pool("VerdantGraphLineEhps")
  controls.pool_line_ems       = make_line_pool("VerdantGraphLineEms")
  controls.pool_skill_top      = make_skill_fill_pool("VerdantSkillFillTop", "ehps_canvas")
  controls.pool_skill_bot      = make_skill_fill_pool("VerdantSkillFillBot", "mps_canvas")
  controls.pool_line_skill_top = make_skill_line_pool("VerdantSkillLineTop", "ehps_canvas")
  controls.pool_line_skill_bot = make_skill_line_pool("VerdantSkillLineBot", "mps_canvas")

  controls.title:SetText(GetString(VERDANT_GRAPH_TITLE))
  controls.title:SetColor(0.75, 0.75, 0.75, 1)

  controls.btn_record:SetText(GetString(VERDANT_GRAPH_RECORD))
  controls.btn_stop:SetText(GetString(VERDANT_GRAPH_STOP))
  controls.btn_flush:SetText(GetString(VERDANT_GRAPH_FLUSH))

  local function tint_btn(btn, r, g, b)
    btn:SetNormalFontColor(r, g, b, 1)
    btn:SetMouseOverFontColor(math.min(1, r + 0.12), math.min(1, g + 0.12), math.min(1, b + 0.12), 1)
    btn:SetPressedFontColor(r * 0.85, g * 0.85, b * 0.85, 1)
  end
  tint_btn(controls.btn_record, 0.46, 0.86, 0.55)
  tint_btn(controls.btn_stop,   0.96, 0.80, 0.34)
  tint_btn(controls.btn_flush,  0.90, 0.40, 0.36)

  controls.status:SetText("")
  controls.status:SetColor(0.65, 0.65, 0.65, 1)

  controls.no_data:SetText(GetString(VERDANT_GRAPH_NO_DATA))
  controls.no_data:SetColor(0.45, 0.45, 0.45, 1)
  controls.no_data:SetHidden(false)


  controls.view_label:SetText(VIEW_LABELS[current_view])
  controls.view_label:SetColor(0.75, 0.75, 0.75, 1)

  controls.ehps_label:SetText("eHPS")
  controls.ehps_label:SetColor(C_LINE_EHPS.r, C_LINE_EHPS.g, C_LINE_EHPS.b, 0.80)
  controls.mps_label:SetText("MPS")
  controls.mps_label:SetColor(C_LINE_EMS.r, C_LINE_EMS.g, C_LINE_EMS.b, 0.80)

  build_hover_card()
  card_fader = make_fader(controls.card.root)

  local crosshair = WINDOW_MANAGER:CreateControl("VerdantGraphCrosshair", controls.window, CT_TEXTURE)
  crosshair:SetTexture(FILL_TEXTURE)
  crosshair:SetTextureCoords(0, 0.05, 0, 1)
  crosshair:SetWidth(1)
  crosshair:SetColor(C_CROSSHAIR.r, C_CROSSHAIR.g, C_CROSSHAIR.b, C_CROSSHAIR.a)
  crosshair:SetDrawLevel(15)
  crosshair:SetAnchor(TOPLEFT,    controls.canvas, TOPLEFT,    0, 0)
  crosshair:SetAnchor(BOTTOMLEFT, controls.canvas, BOTTOMLEFT, 0, 0)
  crosshair:SetAlpha(0)
  crosshair:SetHidden(true)
  controls.crosshair = crosshair
  crosshair_fader = make_fader(crosshair)

  local function make_hit(name, canvas)
    local h = WINDOW_MANAGER:CreateControl(name, canvas, zc.CT_CONTROL)
    h:SetAnchorFill(canvas)
    h:SetMouseEnabled(false)
    h:SetHidden(true)
    h:SetHandler("OnMouseEnter", function()
      if hover_allowed() then zev.register_update("VerdantHoverPoll", 50, hover_poll) end
    end)
    h:SetHandler("OnMouseExit", function()
      stop_hover_poll(); hide_hover_ui()
      if hover_key ~= nil then hover_key = nil; render_current_view() end
    end)
    return h
  end
  controls.hit_main = make_hit("VerdantGraphHitMain", controls.canvas)
  controls.hit_top  = make_hit("VerdantGraphHitTop",  controls.ehps_canvas)
  controls.hit_bot  = make_hit("VerdantGraphHitBot",  controls.mps_canvas)

  refresh_button_colors()
end
