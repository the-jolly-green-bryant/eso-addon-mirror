Verditer = Verditer or {}
Verditer.Graph = {}
local M = Verditer.Graph

local api  = Verditer.zenimax.api
local zui  = Verditer.zenimax.ui
local zc   = Verditer.zenimax.constants
local zev  = Verditer.zenimax.events
local WINDOW_MANAGER             = zui.WINDOW_MANAGER
local GetGameTimeMilliseconds    = api.GetGameTimeMilliseconds
local GetString                  = api.GetString
local math_max                   = math.max
local math_min                   = math.min
local math_floor                 = math.floor
local string_format              = string.format

local log               = Verditer.Log.for_module("graph")
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
local TEXT_ALIGN_BOTTOM = zc.TEXT_ALIGN_BOTTOM


local C_DTPS      = { r = 0.90, g = 0.30, b = 0.25, a = 0.92 }
local C_ABS       = { r = 0.18, g = 0.42, b = 0.88, a = 0.90 }
local C_LINE_DTPS = { r = 1.00, g = 0.46, b = 0.40, a = 1.00 }
local C_LINE_ABS  = { r = 0.44, g = 0.66, b = 1.00, a = 1.00 }
local C_LINE_TOP  = { r = 0.80, g = 0.88, b = 1.00, a = 1.00 }
local C_BASELINE  = { r = 0.78, g = 0.86, b = 1.00, a = 0.55 }
local C_CHROME    = Verditer.Constants.BRAND.CHROME
local C_EDGE      = Verditer.Constants.BRAND.EDGE
local C_VIEWPORT  = { r = 0.30, g = 0.45, b = 0.85 }

local C_HP        = { r = 0.30, g = 0.80, b = 0.45, a = 0.92 }
local C_HP_LOST   = { r = 0.42, g = 0.44, b = 0.50, a = 0.80 }
local C_HP_FRESH  = { r = 0.90, g = 0.30, b = 0.25, a = 0.92 }
local C_FULL_LINE = { r = 0.55, g = 0.95, b = 0.65, a = 0.45 }

local FILL_TEXTURE   = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local FILL_T, FILL_B = 0, 0.53125
local LINE_THICKNESS = 2

local N_HGRID      = 3
local N_VGRID      = 3
local TIME_STRIP_H = 18

local LEGEND_MAX   = 8
local LEGEND_SHOW  = 5
local LEGEND_W     = 122
local LEGEND_ROW_H = 14
local LEGEND_PAD   = 4
local C_LEGEND_BG  = { r = 0.04, g = 0.06, b = 0.12, a = 0.58 }
local C_LEGEND_LBL = { r = 0.88, g = 0.91, b = 0.97, a = 1.0 }
local C_LEGEND_ROLL = { r = 0.55, g = 0.55, b = 0.58, a = 1.0 }
local C_GRID_LINE = { r = 0.55, g = 0.58, b = 0.70, a = 0.25 }
local C_GRID_LBL  = { r = 0.82, g = 0.85, b = 0.90, a = 0.92 }
local C_TIME_LBL  = { r = 0.68, g = 0.70, b = 0.75, a = 0.85 }
local controls           = {}
local recording_start_ms = 0
local VIEW_OUTCOME        = 1
local VIEW_BY_DAMAGE_TYPE = 2
local VIEW_SURVIVAL       = 3
local VIEW_BY_SOURCE      = 4
local VIEW_MIN, VIEW_MAX  = VIEW_OUTCOME, VIEW_BY_SOURCE
local VIEW_LABELS         = { "OUTCOME", "TYPE", "SURVIVAL", "SOURCE" }
local current_view        = VIEW_OUTCOME
local prof_enter   = Verditer.Profiler.enter
local prof_exit    = Verditer.Profiler.exit
local RENDER_ZONE  = { "render.OUTCOME", "render.TYPE", "render.SURVIVAL", "render.SOURCE" }
local prev_hp = -1
local hover_key  = nil
local hit = { cols = {}, n = 0 }
local C_DIM_BIAS = 0.05
local render_current_view
local FADE_MS = 120
local card_fader, crosshair_fader
local CARD_W, CARD_H = 196, 56
local C_CARD_BG     = { r = 0.04, g = 0.06, b = 0.12, a = 0.96 }
local C_CARD_ACCENT = { r = 0.18, g = 0.42, b = 0.88, a = 1.0 }
local C_CARD_STAT   = { r = 0.80, g = 0.84, b = 0.92, a = 1.0 }
local C_CARD_NAME   = { r = 0.85, g = 0.90, b = 1.00, a = 1.0 }
local C_CARD_TIME   = { r = 0.60, g = 0.64, b = 0.72, a = 1.0 }
local C_CROSSHAIR   = { r = 0.44, g = 0.66, b = 1.00, a = 0.50 }

local function fmt_val(v)
  return ZO_AbbreviateAndLocalizeNumber(math_floor(v), 0, false)
end

local function fmt_secs(ms)
  local s = math_floor(ms / 1000)
  if s >= 60 then return string_format("%d:%02d", math_floor(s / 60), s % 60) end
  return s .. "s"
end

local function fmt_readout(v)
  return ZO_AbbreviateAndLocalizeNumber(math_floor(v + 0.5), 1, false)
end

local ITP_ICON_IDLE   = "/esoui/art/treeicons/collection_indexicon_armor_up.dds"
local ITP_ICON_ACTIVE = "/esoui/art/treeicons/collection_indexicon_armor_down.dds"

local function update_header(dtps, abs)
  dtps = dtps or 0
  abs  = abs  or 0
  local itp = dtps + abs
  controls.readout:SetText(fmt_readout(itp))
  controls.itp_icon:SetTexture(itp > 0 and ITP_ICON_ACTIVE or ITP_ICON_IDLE)
  if controls.mit then
    if itp > 0 then
      controls.mit:SetText(string_format("Mit %d%%", math_floor(abs / itp * 100 + 0.5)))
    else
      controls.mit:SetText("")
    end
  end
end

local function header_tick()
  if controls.window:IsHidden() then return end
  local now = GetGameTimeMilliseconds()
  update_header(Verditer.Metrics.DTPS(now), Verditer.Metrics.ABS(now))
end

local Pool = Verditer.lib.plot.Pool

local function fill_factory(c)
  c:SetTexture(FILL_TEXTURE)
  c:SetTextureCoords(0, 1, FILL_T, FILL_B)
  c:SetPixelRoundingEnabled(false)
end

local function fill_reset(c) c:SetHidden(true) end

local function line_factory(line) line:SetThickness(LINE_THICKNESS) end

local function line_reset(line)
  line:SetHidden(true)
  line:ClearAnchors()
end

local function make_fill_pool(name_prefix)
  return Pool.new(name_prefix, controls.canvas, CT_TEXTURE, fill_factory, fill_reset)
end

local function make_line_pool(name_prefix)
  return Pool.new_virtual(name_prefix, controls.canvas, "VerditerGraphLineTemplate", line_factory, line_reset)
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
  for i = 1, N_VGRID do grid.vlines[i]:SetHidden(true) end
  grid.time_l:SetHidden(true)
  grid.time_m:SetHidden(true)
  grid.time_r:SetHidden(true)
end

local function draw_time_strip(grid, canvas, span_ms)
  if span_ms > 0 then
    grid.time_l:ClearAnchors()
    grid.time_l:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, 0)
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

local function draw_grid(grid, canvas, max_val, span_ms)
  local cw = canvas:GetWidth()
  local ch = canvas:GetHeight()
  if cw <= 0 or ch <= 0 then hide_grid(grid) return end

  local has_y    = (max_val > 0)
  local has_time = (span_ms > 0)
  if not has_y and not has_time then hide_grid(grid) return end

  local y_base  = has_time and TIME_STRIP_H or 0
  local ch_plot = math_max(1, ch - y_base)

  if has_y then
    for i = 1, N_HGRID do
      local frac = i / (N_HGRID + 1)
      local y    = y_base + math_floor(ch_plot * frac)
      local gl = grid.hlines[i]
      gl:ClearAnchors()
      gl:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT,  0, -y)
      gl:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, 0, -y)
      gl:SetColor(C_GRID_LINE.r, C_GRID_LINE.g, C_GRID_LINE.b, C_GRID_LINE.a)
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

  draw_time_strip(grid, canvas, span_ms)
end

local function draw_grid_diverging(grid, canvas, baseline_y, half, max_dtps, max_abs, span_ms)
  local cw = canvas:GetWidth()
  local ch = canvas:GetHeight()
  if cw <= 0 or ch <= 0 then hide_grid(grid) return end

  local function hline(i, y, c)
    local gl = grid.hlines[i]
    gl:ClearAnchors()
    gl:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT,  0, -y)
    gl:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, 0, -y)
    gl:SetColor(c.r, c.g, c.b, c.a)
    gl:SetHidden(false)
  end

  hline(1, baseline_y, C_BASELINE)
  hline(2, baseline_y + math_floor(half * 0.5), C_GRID_LINE)
  hline(3, baseline_y - math_floor(half * 0.5), C_GRID_LINE)

  grid.ylabels[1]:ClearAnchors()
  grid.ylabels[1]:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -(baseline_y + 1))
  grid.ylabels[1]:SetText("0")
  grid.ylabels[1]:SetHidden(false)

  grid.ylabels[2]:ClearAnchors()
  grid.ylabels[2]:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -(baseline_y + half))
  grid.ylabels[2]:SetText(max_dtps > 0 and fmt_val(max_dtps) or "")
  grid.ylabels[2]:SetHidden(false)

  grid.ylabels[3]:ClearAnchors()
  grid.ylabels[3]:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -(baseline_y - half + 10))
  grid.ylabels[3]:SetText(max_abs > 0 and fmt_val(max_abs) or "")
  grid.ylabels[3]:SetHidden(false)

  for i = 1, N_VGRID do
    local frac = i / (N_VGRID + 1)
    local x    = math_floor(cw * frac)
    local vl = grid.vlines[i]
    vl:ClearAnchors()
    vl:SetAnchor(TOPLEFT,    canvas, TOPLEFT,    x, 0)
    vl:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
    vl:SetHidden(false)
  end

  draw_time_strip(grid, canvas, span_ms)
end

local function release_all_pools()
  controls.pool_type_seg:ReleaseAllObjects()
  controls.pool_type_line:ReleaseAllObjects()
  controls.pool_up:ReleaseAllObjects()
  controls.pool_down:ReleaseAllObjects()
  controls.pool_line_up:ReleaseAllObjects()
  controls.pool_line_down:ReleaseAllObjects()
end

local MIN_COL_PX = 2
local dec_cols   = {}

local function decimate(cw)
  local TB       = Verditer.TemporalBuffer
  local capacity = TB.capacity()
  local n        = TB.count()
  local num_cols = math_floor(cw / MIN_COL_PX)
  if num_cols < 1 then num_cols = 1 end
  if num_cols > capacity then num_cols = capacity end
  local offset   = capacity - n
  local m, cur_c = 0, -1
  local col
  TB.iterate(function(i, s)
    local c = math_floor((offset + i - 1) * num_cols / capacity)
    if c ~= cur_c then
      m = m + 1
      col = dec_cols[m]
      if not col then col = {}; dec_cols[m] = col end
      col.c = c
      col.DTPS = s.DTPS; col.ABS = s.ABS
      col.hp_pct = s.hp_pct; col.hp_drop = s.hp_drop
      col.t = s.t
      col.type_groups = s.type_groups
      col.source_groups = s.source_groups
      cur_c = c
    else
      if s.DTPS > col.DTPS then
        col.DTPS = s.DTPS
        col.type_groups = s.type_groups
        col.source_groups = s.source_groups
      end
      if s.ABS > col.ABS then col.ABS = s.ABS end
      if s.hp_pct >= 0 and (col.hp_pct < 0 or s.hp_pct < col.hp_pct) then col.hp_pct = s.hp_pct end
      if s.hp_drop > col.hp_drop then col.hp_drop = s.hp_drop end
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

local function extent_dtps()
  local max_dtps = 0
  local t_first, t_last = 0, 0
  Verditer.TemporalBuffer.iterate(function(i, s)
    if s.DTPS > max_dtps then max_dtps = s.DTPS end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end)
  return max_dtps, (t_last - t_first)
end

local function extent_outcome()
  local max_dtps, max_abs = 0, 0
  local t_first, t_last = 0, 0
  Verditer.TemporalBuffer.iterate(function(i, s)
    if s.DTPS > max_dtps then max_dtps = s.DTPS end
    if s.ABS  > max_abs  then max_abs  = s.ABS  end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end)
  return max_dtps, max_abs, (t_last - t_first)
end

local rt_xs, rt_top_hs              = {}, {}
local ro_xs, ro_up_hs, ro_down_ys   = {}, {}, {}

local name_cache = {}
local function clean_name(raw)
  if raw == nil or raw == "" then return "" end
  local c = name_cache[raw]
  if c == nil then
    c = zo_strformat(SI_UNIT_NAME, raw)
    name_cache[raw] = c
  end
  return c
end

local function source_label(grp)
  if grp.uid == -1 then return "Other" end
  if grp.uid == 0  then return "Environment" end
  local nm = clean_name(grp.name)
  if nm == "" then return "Unknown" end
  return nm
end

local function create_legend(prefix, parent)
  local WM = WINDOW_MANAGER
  local L  = { rows = {} }

  L.bg = WM:CreateControl(prefix .. "Bg", parent, CT_TEXTURE)
  L.bg:SetTexture(FILL_TEXTURE)
  L.bg:SetTextureCoords(0, 1, 0, 0.05)
  L.bg:SetColor(C_LEGEND_BG.r, C_LEGEND_BG.g, C_LEGEND_BG.b, C_LEGEND_BG.a)
  L.bg:SetDrawLevel(5)
  L.bg:SetHidden(true)

  for i = 1, LEGEND_MAX do
    local sw = WM:CreateControl(prefix .. "Sw" .. i, parent, CT_TEXTURE)
    sw:SetTexture(FILL_TEXTURE)
    sw:SetTextureCoords(0, 1, 0, 0.05)
    sw:SetDimensions(10, 10)
    sw:SetDrawLevel(6)
    sw:SetHidden(true)

    local lbl = WM:CreateControl(prefix .. "Lbl" .. i, parent, CT_LABEL)
    lbl:SetFont("ZoFontGameSmall")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetColor(C_LEGEND_LBL.r, C_LEGEND_LBL.g, C_LEGEND_LBL.b, C_LEGEND_LBL.a)
    lbl:SetDimensions(LEGEND_W - 22, LEGEND_ROW_H)
    lbl:SetDrawLevel(7)
    lbl:SetHidden(true)

    L.rows[i] = { sw = sw, lbl = lbl }
  end
  return L
end

local function hide_legend()
  local L = controls.legend
  if not L then return end
  L.bg:SetHidden(true)
  for i = 1, LEGEND_MAX do
    L.rows[i].sw:SetHidden(true)
    L.rows[i].lbl:SetHidden(true)
  end
end

local function update_legend(groups)
  local L = controls.legend
  if not L then return end
  local total = (groups and (groups.count or 0)) or 0
  if total == 0 then hide_legend() return end

  local rows   = (total < LEGEND_SHOW) and total or LEGEND_SHOW
  local rolled = total > LEGEND_SHOW

  local canvas  = controls.canvas
  local block_h = LEGEND_PAD * 2 + rows * LEGEND_ROW_H
  L.bg:ClearAnchors()
  L.bg:SetAnchor(TOPRIGHT, canvas, TOPRIGHT, -2, 2)
  L.bg:SetDimensions(LEGEND_W, block_h)
  L.bg:SetHidden(false)

  for i = 1, rows do
    local row = L.rows[i]
    local y   = LEGEND_PAD + (i - 1) * LEGEND_ROW_H

    row.sw:ClearAnchors()
    row.sw:SetAnchor(TOPLEFT, L.bg, TOPLEFT, LEGEND_PAD, y + 2)
    row.lbl:ClearAnchors()
    row.lbl:SetAnchor(TOPLEFT, L.bg, TOPLEFT, LEGEND_PAD + 16, y)

    if rolled and i == rows then
      local rest = 0
      for g = rows, total do rest = rest + (groups[g].share or 0) end
      row.sw:SetColor(C_LEGEND_ROLL.r, C_LEGEND_ROLL.g, C_LEGEND_ROLL.b, 1.0)
      row.lbl:SetText(string_format("Other +%d  %d%%", total - rows + 1,
                                    math_floor(rest * 100 + 0.5)))
    else
      local grp = groups[i]
      row.sw:SetColor(grp.r, grp.g, grp.b, 1.0)
      row.lbl:SetText(string_format("%s  %d%%", source_label(grp),
                                    math_floor(grp.share * 100 + 0.5)))
    end
    row.sw:SetHidden(false)
    row.lbl:SetHidden(false)
  end

  for i = rows + 1, LEGEND_MAX do
    L.rows[i].sw:SetHidden(true)
    L.rows[i].lbl:SetHidden(true)
  end
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
  f.anim:FadeOut(0, FADE_MS, nil, function()
    control:SetHidden(true)
  end)
end

local function hover_allowed()
  return not Verditer.TemporalBuffer.is_recording()
     and Verditer.TemporalBuffer.count() > 0
     and not controls.window:IsHidden()
end

local function hover_label(band)
  if current_view == VIEW_BY_SOURCE then
    if band.key == -1 then return "Other" end
    if band.key == 0  then return "Environment" end
    local nm = clean_name(band.name)
    return nm ~= "" and nm or "Unknown"
  end
  local DTC = Verditer.DamageTypeColors
  return (DTC and DTC.name) and DTC.name(band.key) or "Damage"
end

local function stop_hover_poll() zev.unregister_update("VerditerHoverPoll") end

local function hide_hover_ui()
  fade_out(card_fader)
  fade_out(crosshair_fader)
end

local function build_hover_card()
  local WM   = WINDOW_MANAGER
  local root = WM:CreateControl("VerditerHoverCard", controls.window, zc.CT_CONTROL)
  root:SetDimensions(CARD_W, CARD_H)
  root:SetMouseEnabled(false)
  root:SetDrawLevel(20)
  root:SetAlpha(0)
  root:SetHidden(true)

  local bg = WM:CreateControl("VerditerHoverCardBg", root, CT_TEXTURE)
  bg:SetTexture(FILL_TEXTURE)
  bg:SetTextureCoords(0, 1, 0, 0.05)
  bg:SetAnchor(TOPLEFT,     root, TOPLEFT,     0, 0)
  bg:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
  bg:SetColor(C_CARD_BG.r, C_CARD_BG.g, C_CARD_BG.b, C_CARD_BG.a)

  local accent = WM:CreateControl("VerditerHoverCardAccent", root, CT_TEXTURE)
  accent:SetTexture(FILL_TEXTURE)
  accent:SetTextureCoords(0, 0.05, 0, 1)
  accent:SetAnchor(TOPLEFT,    root, TOPLEFT,    0, 0)
  accent:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 0, 0)
  accent:SetWidth(3)
  accent:SetColor(C_CARD_ACCENT.r, C_CARD_ACCENT.g, C_CARD_ACCENT.b, 1.0)

  local swatch = WM:CreateControl("VerditerHoverCardSwatch", root, CT_TEXTURE)
  swatch:SetTexture(FILL_TEXTURE)
  swatch:SetTextureCoords(0, 1, 0, 0.05)
  swatch:SetDimensions(10, 10)
  swatch:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 9)

  local name = WM:CreateControl("VerditerHoverCardName", root, CT_LABEL)
  name:SetFont("ZoFontGameBold")
  name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  name:SetAnchor(TOPLEFT, root, TOPLEFT, 28, 6)
  name:SetDimensions(CARD_W - 36, 16)

  local stat = WM:CreateControl("VerditerHoverCardStat", root, CT_LABEL)
  stat:SetFont("ZoFontGameSmall")
  stat:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  stat:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  stat:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
  stat:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 24)
  stat:SetDimensions(CARD_W - 20, 14)

  local time = WM:CreateControl("VerditerHoverCardTime", root, CT_LABEL)
  time:SetFont("ZoFontGameSmall")
  time:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  time:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  time:SetColor(C_CARD_TIME.r, C_CARD_TIME.g, C_CARD_TIME.b, 1.0)
  time:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 40)
  time:SetDimensions(CARD_W - 20, 12)

  controls.card = { root = root, swatch = swatch, name = name, stat = stat, time = time }
end

local function hexc(c)
  return string_format("%02x%02x%02x",
    math_floor(c.r * 255 + 0.5), math_floor(c.g * 255 + 0.5), math_floor(c.b * 255 + 0.5))
end

local function position_card(mx, my)
  local card = controls.card
  local sw, sh = GuiRoot:GetDimensions()
  local x = mx + 16
  local y = my + 18
  if x + CARD_W > sw - 4 then x = mx - CARD_W - 16 end
  if x < 4 then x = 4 end
  if y + CARD_H > sh - 4 then y = my - CARD_H - 18 end
  if y < 4 then y = 4 end
  card.root:ClearAnchors()
  card.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  fade_in(card_fader)
end

local function show_card(band, mx, my, elapsed_ms)
  local card = controls.card
  if not card then return end
  card.swatch:SetColor(band.r, band.g, band.b, 1.0)
  card.name:SetColor(band.r, band.g, band.b, 1.0)
  card.name:SetText(hover_label(band))
  local pct = math_floor((band.share or 0) * 100 + 0.5)
  local val = (band.share or 0) * (band.dtps or 0)   -- this group's DTPS at the instant
  card.stat:SetText(string_format("%s DTPS  ·  %d%%", fmt_readout(val), pct))
  card.time:SetText("t  " .. fmt_secs(elapsed_ms or 0))
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
  position_card(mx, my)
end

local function hover_pick(rel_x, height_above)
  if hit.n == 0 then return nil, nil end
  local col = nil
  for i = 1, hit.n do
    local c = hit.cols[i]
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

local function hover_poll()
  if not hover_allowed() then
    if hover_key ~= nil then hover_key = nil; render_current_view() end
    hide_hover_ui()
    return
  end
  local canvas = controls.canvas
  local mx, my = GetUIMousePosition()
  local rel_x  = mx - canvas:GetLeft()
  local above  = canvas:GetBottom() - my
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()

  local band, col = nil, nil
  if rel_x >= 0 and rel_x <= cw and above >= 0 and above <= ch then
    band, col = hover_pick(rel_x, above)
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

  local elapsed = (col.t and hit.t0) and (col.t - hit.t0) or 0
  if band then
    show_card(band, mx, my, elapsed)
  elseif current_view == VIEW_OUTCOME then
    show_moment_card(C_DTPS, "Incoming",
      string_format("|c%s%s DTPS|r  ·  |c%s%s ABS|r",
        hexc(C_DTPS), fmt_readout(col.dtps or 0), hexc(C_ABS), fmt_readout(col.abs or 0)),
      elapsed, mx, my)
  elseif current_view == VIEW_SURVIVAL then
    local hp = col.hp or 0
    if hp < 0 then hp = 0 end
    show_moment_card(C_HP, "Survival",
      string_format("|c%sHP  %d%%|r", hexc(C_HP), math_floor(hp * 100 + 0.5)),
      elapsed, mx, my)
  else
    fade_out(card_fader)
  end
end

local function update_hover_gate()
  local on = hover_allowed()
  if controls.hit then
    controls.hit:SetMouseEnabled(on)
    controls.hit:SetHidden(not on)
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

local function hit_begin(n)
  hit.n = n
end

local function hit_col(i, x, bw, s)
  if i == 1 then hit.t0 = s.t end
  local col = hit.cols[i]
  if not col then col = { bands = {} }; hit.cols[i] = col end
  col.x0 = x; col.x1 = x + bw; col.nb = 0; col.t = s.t
  col.dtps = s.DTPS; col.abs = s.ABS; col.hp = s.hp_pct
  return col
end

local function render_stacked(groups_field, key_field)
  release_all_pools()

  local n = Verditer.TemporalBuffer.count()
  if n == 0 then
    controls.no_data:SetHidden(false)
    hide_grid(controls.grid)
    return
  end
  controls.no_data:SetHidden(true)

  local canvas = controls.canvas
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  if cw <= 4 or ch <= 4 then return end
  local ch_plot = math_max(4, ch - TIME_STRIP_H)

  local max_dtps, span_ms = extent_dtps()
  if max_dtps <= 0 then hide_grid(controls.grid) return end
  draw_grid(controls.grid, canvas, max_dtps, span_ms)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs, top_hs = rt_xs, rt_top_hs

  local capture = not Verditer.TemporalBuffer.is_recording()
  local hk = hover_key
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x   = left
    local bw  = math_max(1, right - left - bar_gap)
    local col_h = math_max(0, math_floor(ch_plot * (s.DTPS / max_dtps) + 0.5))
    xs[i]     = x + bw * 0.5
    top_hs[i] = col_h

    local col = capture and hit_col(i, left, right - left, s) or nil

    local y_off  = 0
    local groups = s[groups_field]
    for g = 1, (groups.count or 0) do
      local grp   = groups[g]
      local seg_h = math_max(1, math_floor(col_h * grp.share + 0.5))
      local t = controls.pool_type_seg:AcquireObject()
      t:ClearAnchors()
      t:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(y_off + TIME_STRIP_H))
      t:SetWidth(bw)
      t:SetHeight(seg_h)
      if hk ~= nil and grp[key_field] ~= hk then
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
        band.key   = grp[key_field]
        band.lo    = TIME_STRIP_H + y_off
        band.hi    = TIME_STRIP_H + y_off + seg_h
        band.share = grp.share
        band.dtps  = s.DTPS
        band.name  = grp.name
        band.r = grp.r; band.g = grp.g; band.b = grp.b
        col.nb = nb
      end

      y_off = y_off + seg_h
    end
  end

  if col_w >= 3 then
    for i = 2, m do
      local lt = controls.pool_type_line:AcquireObject()
      lt:ClearAnchors()
      lt:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(top_hs[i-1] + TIME_STRIP_H))
      lt:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(top_hs[i]   + TIME_STRIP_H))
      lt:SetColor(C_LINE_TOP.r, C_LINE_TOP.g, C_LINE_TOP.b, C_LINE_TOP.a)
      lt:SetThickness(LINE_THICKNESS)
      lt:SetHidden(false)
    end
  end
end

local function render_by_damage_type() render_stacked("type_groups", "dt") end

local function render_by_source()
  render_stacked("source_groups", "uid")
  if Verditer.TemporalBuffer.count() > 0 then
    local s = Verditer.TemporalBuffer.latest()
    update_legend(s and s.source_groups)
  else
    hide_legend()
  end
end

local function render_outcome()
  release_all_pools()

  local n = Verditer.TemporalBuffer.count()
  if n == 0 then
    controls.no_data:SetHidden(false)
    hide_grid(controls.grid)
    return
  end
  controls.no_data:SetHidden(true)

  local canvas = controls.canvas
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  if cw <= 4 or ch <= 4 then return end
  local ch_plot = math_max(4, ch - TIME_STRIP_H)
  local half       = math_floor(ch_plot / 2)
  local baseline_y = TIME_STRIP_H + half

  local max_dtps, max_abs, span_ms = extent_outcome()
  if max_dtps <= 0 and max_abs <= 0 then hide_grid(controls.grid) return end
  draw_grid_diverging(controls.grid, canvas, baseline_y, half, max_dtps, max_abs, span_ms)

  local up_scale   = (max_dtps > 0) and (half / max_dtps) or 0
  local down_scale = (max_abs  > 0) and (half / max_abs)  or 0

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs, up_hs, down_ys = ro_xs, ro_up_hs, ro_down_ys

  local capture = not Verditer.TemporalBuffer.is_recording()
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x  = left
    local bw = math_max(1, right - left - bar_gap)
    if capture then hit_col(i, left, right - left, s) end
    local up_h    = math_min(half, math_max(0, math_floor(s.DTPS * up_scale   + 0.5)))
    local down_h  = math_min(half, math_max(0, math_floor(s.ABS  * down_scale + 0.5)))
    xs[i]      = x + bw * 0.5
    up_hs[i]   = up_h
    down_ys[i] = baseline_y - down_h

    if up_h > 0 then
      local tu = controls.pool_up:AcquireObject()
      tu:ClearAnchors()
      tu:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -baseline_y)
      tu:SetWidth(bw)
      tu:SetHeight(up_h)
      tu:SetColor(C_DTPS.r, C_DTPS.g, C_DTPS.b, C_DTPS.a)
      tu:SetHidden(false)
    end

    if down_h > 0 then
      local td = controls.pool_down:AcquireObject()
      td:ClearAnchors()
      td:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(baseline_y - down_h))
      td:SetWidth(bw)
      td:SetHeight(down_h)
      td:SetColor(C_ABS.r, C_ABS.g, C_ABS.b, C_ABS.a)
      td:SetHidden(false)
    end
  end

  if col_w >= 3 then
    for i = 2, m do
      local lu = controls.pool_line_up:AcquireObject()
      lu:ClearAnchors()
      lu:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(baseline_y + up_hs[i-1]))
      lu:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(baseline_y + up_hs[i]))
      lu:SetColor(C_LINE_DTPS.r, C_LINE_DTPS.g, C_LINE_DTPS.b, C_LINE_DTPS.a)
      lu:SetThickness(LINE_THICKNESS)
      lu:SetHidden(false)

      local ld = controls.pool_line_down:AcquireObject()
      ld:ClearAnchors()
      ld:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -down_ys[i-1])
      ld:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -down_ys[i])
      ld:SetColor(C_LINE_ABS.r, C_LINE_ABS.g, C_LINE_ABS.b, C_LINE_ABS.a)
      ld:SetThickness(LINE_THICKNESS)
      ld:SetHidden(false)
    end
  end
end

local function render_survival_bars()
  release_all_pools()

  local n = Verditer.TemporalBuffer.count()
  if n == 0 then controls.no_data:SetHidden(false); hide_grid(controls.grid); return end
  controls.no_data:SetHidden(true)

  local canvas = controls.canvas
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  if cw <= 4 or ch <= 4 then return end

  local ch_plot = math_max(4, ch - TIME_STRIP_H)
  local hp_zone = math_max(4, ch_plot - 12)
  local y100    = TIME_STRIP_H + hp_zone

  local _, span_ms = extent_dtps()

  hide_grid(controls.grid)
  local g = controls.grid
  g.hlines[1]:ClearAnchors()
  g.hlines[1]:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT,  0, -y100)
  g.hlines[1]:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, 0, -y100)
  g.hlines[1]:SetColor(C_FULL_LINE.r, C_FULL_LINE.g, C_FULL_LINE.b, C_FULL_LINE.a)
  g.hlines[1]:SetHidden(false)
  local y50 = TIME_STRIP_H + math_floor(hp_zone * 0.5)
  g.hlines[2]:ClearAnchors()
  g.hlines[2]:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT,  0, -y50)
  g.hlines[2]:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, 0, -y50)
  g.hlines[2]:SetColor(C_GRID_LINE.r, C_GRID_LINE.g, C_GRID_LINE.b, C_GRID_LINE.a)
  g.hlines[2]:SetHidden(false)
  g.ylabels[1]:ClearAnchors()
  g.ylabels[1]:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -(y100 + 1))
  g.ylabels[1]:SetText("100%")
  g.ylabels[1]:SetHidden(false)
  draw_time_strip(g, canvas, span_ms)

  local m, num_cols, _, bar_gap = decimate(cw)

  local capture = not Verditer.TemporalBuffer.is_recording()
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x  = left
    local bw = math_max(1, right - left - bar_gap)
    if capture then hit_col(i, left, right - left, s) end
    local hp = s.hp_pct
    if hp < 0 then hp = 1 elseif hp > 1 then hp = 1 end
    local drop = s.hp_drop or 0
    if drop < 0 then drop = 0 end

    local green_h = math_max(0, math_floor(hp * hp_zone + 0.5))
    local deficit = 1 - hp
    local red_f   = math_min(drop, deficit)
    local red_h   = math_max(0, math_floor(red_f * hp_zone + 0.5))
    local grey_h  = math_max(0, math_floor((deficit - red_f) * hp_zone + 0.5))

    if green_h > 0 then
      local t = controls.pool_type_seg:AcquireObject()
      t:ClearAnchors(); t:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
      t:SetWidth(bw); t:SetHeight(green_h)
      t:SetColor(C_HP.r, C_HP.g, C_HP.b, C_HP.a); t:SetHidden(false)
    end
    if red_h > 0 then
      local t = controls.pool_type_seg:AcquireObject()
      t:ClearAnchors(); t:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(TIME_STRIP_H + green_h))
      t:SetWidth(bw); t:SetHeight(red_h)
      t:SetColor(C_HP_FRESH.r, C_HP_FRESH.g, C_HP_FRESH.b, C_HP_FRESH.a); t:SetHidden(false)
    end
    if grey_h > 0 then
      local t = controls.pool_type_seg:AcquireObject()
      t:ClearAnchors(); t:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(TIME_STRIP_H + green_h + red_h))
      t:SetWidth(bw); t:SetHeight(grey_h)
      t:SetColor(C_HP_LOST.r, C_HP_LOST.g, C_HP_LOST.b, C_HP_LOST.a); t:SetHidden(false)
    end
  end
end

function render_current_view()
  prof_enter(RENDER_ZONE[current_view])
  if current_view ~= VIEW_BY_SOURCE then hide_legend() end
  if current_view == VIEW_OUTCOME then
    render_outcome()
  elseif current_view == VIEW_BY_DAMAGE_TYPE then
    render_by_damage_type()
  elseif current_view == VIEW_BY_SOURCE then
    render_by_source()
  else
    render_survival_bars()
  end
  prof_exit(RENDER_ZONE[current_view])
end

local function refresh_button_colors()
  local recording = Verditer.TemporalBuffer.is_recording()
  controls.btn_record:SetEnabled(not recording)
  controls.btn_stop:SetEnabled(recording)
  if controls.btn_export then
    controls.btn_export:SetHidden(recording or Verditer.TemporalBuffer.count() == 0)
  end
  M.notify_deaths_changed()
  update_hover_gate()
end

local function persist_view()
  local sv = Verditer.SavedVars
  if sv then sv.graph = sv.graph or {} ; sv.graph.view_idx = current_view end
end

local function set_view(v)
  current_view = v
  controls.view_label:SetText(VIEW_LABELS[v])
  persist_view()
  hover_key = nil
  if Verditer.TemporalBuffer.count() == 0 then
    controls.no_data:SetHidden(false)
    update_hover_gate()
    return
  end
  controls.no_data:SetHidden(true)
  render_current_view()
  update_hover_gate()
end

local sample_type_scratch   = { count = 0 }
local sample_source_scratch = { count = 0 }

local function on_sample_update()
  prof_enter("graph.sample_tick")
  local now  = GetGameTimeMilliseconds()
  local dtps = Verditer.Metrics.DTPS(now)
  local abs  = Verditer.Metrics.ABS(now)
  Verditer.Metrics.type_groups_into(sample_type_scratch, now)
  Verditer.Metrics.source_groups_into(sample_source_scratch, now)

  local hp_pct  = Verditer.Metrics.hp_sample()
  local hp_drop = (prev_hp >= 0 and hp_pct >= 0) and math_max(0, prev_hp - hp_pct) or 0
  prev_hp = hp_pct
  Verditer.TemporalBuffer.push(now, dtps, abs, sample_type_scratch, hp_pct, hp_drop, sample_source_scratch)

  update_header(dtps, abs)

  local elapsed = math_floor((now - recording_start_ms) / 1000)
  controls.status:SetText(string_format("%d:%02d", math_floor(elapsed / 60), elapsed % 60))

  if not controls.window:IsHidden() then
    render_current_view()
  end
  prof_exit("graph.sample_tick")
end

function M.current_view() return current_view end

function M.bench_set_view(v) set_view(v) end
function M.bench_render_once() render_current_view() end
function M.bench_drawn()
  local c = controls
  return c.pool_type_seg:GetActiveObjectCount()
       + c.pool_type_line:GetActiveObjectCount()
       + c.pool_up:GetActiveObjectCount()
       + c.pool_down:GetActiveObjectCount()
       + c.pool_line_up:GetActiveObjectCount()
       + c.pool_line_down:GetActiveObjectCount()
end
function M.bench_canvas()
  local cv = controls.canvas
  return cv:GetWidth(), cv:GetHeight()
end
function M.bench_views() return VIEW_LABELS, VIEW_MIN, VIEW_MAX end
function M.bench_ensure_open()
  if controls.window and controls.window:IsHidden() then M.toggle() end
  return controls.window ~= nil and not controls.window:IsHidden()
end

function M.on_record_click()
  if Verditer.TemporalBuffer.is_recording() then return end
  Verditer.Sound.play("RECORD")
  log:info("record click")
  Verditer.TemporalBuffer.clear()
  release_all_pools()
  hide_grid(controls.grid)
  hide_legend()
  controls.no_data:SetHidden(false)
  Verditer.TemporalBuffer.start_recording()
  recording_start_ms = GetGameTimeMilliseconds()
  Verditer.Metrics.hp_reset()
  prev_hp = -1
  local sv       = Verditer.SavedVars
  local interval = (sv and sv.temporal and sv.temporal.sample_rate_ms)
                   or Verditer.Constants.TEMPORAL.SAMPLE_RATE_DEFAULT
  zev.register_update(Verditer.Constants.TEMPORAL.UPDATE_NAME, interval, on_sample_update)
  refresh_button_colors()
  controls.status:SetText("0:00")
end

function M.on_stop_click()
  if not Verditer.TemporalBuffer.is_recording() then return end
  Verditer.Sound.play("STOP")
  log:info("stop click")
  Verditer.TemporalBuffer.stop_recording()
  zev.unregister_update(Verditer.Constants.TEMPORAL.UPDATE_NAME)
  refresh_button_colors()
  render_current_view()
end

function M.on_flush_click()
  Verditer.Sound.play("FLUSH")
  if Verditer.TemporalBuffer.is_recording() then
    zev.unregister_update(Verditer.Constants.TEMPORAL.UPDATE_NAME)
    Verditer.TemporalBuffer.stop_recording()
  end
  Verditer.TemporalBuffer.clear()
  if Verditer.DeathRecap and Verditer.DeathRecap.clear then Verditer.DeathRecap.clear() end
  release_all_pools()
  hide_grid(controls.grid)
  hide_legend()
  refresh_button_colors()
  controls.status:SetText("")
  update_header(0, 0)
  controls.no_data:SetHidden(false)
end

function M.on_close_click()
  Verditer.Sound.play("WINDOW_CLOSE")
  Verditer.Visibility.set("graph", false)
  release_all_pools()
  hide_legend()
  stop_hover_poll(); hide_hover_ui(); hover_key = nil
  if controls.hit then controls.hit:SetMouseEnabled(false); controls.hit:SetHidden(true) end
end

function M.on_export_click()
  Verditer.Export.show_session()
end

function M.on_deaths_click()
  if not (Verditer.DeathRecap and Verditer.DeathRecap.count() > 0) then return end
  if Verditer.Recap and Verditer.Recap.toggle then Verditer.Recap.toggle() end
end

function M.notify_deaths_changed()
  if controls.btn_deaths then
    local has = Verditer.DeathRecap and Verditer.DeathRecap.count() > 0
    controls.btn_deaths:SetHidden(not has)
  end
end

function M.on_move_stop()
  local sv = Verditer.SavedVars
  if not sv then return end
  sv.graph = sv.graph or {}
  local x, y = controls.window:GetCenter()
  sv.graph.x = x
  sv.graph.y = y
end

function M.on_resize_stop()
  local sv = Verditer.SavedVars
  if sv then
    sv.graph = sv.graph or {}
    local w, h = controls.window:GetDimensions()
    sv.graph.w = w
    sv.graph.h = h
  end
  if not controls.window:IsHidden() then render_current_view() end
end

function M.prev_view()
  local v = current_view - 1
  if v < VIEW_MIN then v = VIEW_MAX end
  release_all_pools()
  set_view(v)
end

function M.next_view()
  local v = current_view + 1
  if v > VIEW_MAX then v = VIEW_MIN end
  release_all_pools()
  set_view(v)
end

function M.set_viewport_alpha(a)
  VerditerGraphWindowViewportBg:SetCenterColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, a)
end

function M.toggle()
  local now_visible = not Verditer.Visibility.get("graph")
  log:info("toggle ->", now_visible and "show" or "hide")
  Verditer.Visibility.set("graph", now_visible)
  Verditer.Sound.play(now_visible and "WINDOW_OPEN" or "WINDOW_CLOSE")
  if now_visible then
    render_current_view()
    update_hover_gate()
  else
    release_all_pools()
    hide_legend()
    stop_hover_poll(); hide_hover_ui(); hover_key = nil
    if controls.hit then controls.hit:SetMouseEnabled(false); controls.hit:SetHidden(true) end
  end
end

function M.init()
  controls.window        = VerditerGraphWindow
  controls.title         = VerditerGraphWindowTitleLabel
  controls.btn_record    = VerditerGraphWindowRecordBtn
  controls.btn_stop      = VerditerGraphWindowStopBtn
  controls.btn_flush     = VerditerGraphWindowFlushBtn
  controls.status        = VerditerGraphWindowStatusLabel
  controls.btn_prev_view = VerditerGraphWindowPrevViewBtn
  controls.view_label    = VerditerGraphWindowViewLabel
  controls.btn_next_view = VerditerGraphWindowNextViewBtn
  controls.viewport      = VerditerGraphWindowViewport
  controls.canvas        = VerditerGraphWindowViewportCanvas
  controls.no_data       = VerditerGraphWindowViewportNoDataLabel
  controls.readout       = VerditerGraphWindowReadoutLabel
  controls.itp_icon      = VerditerGraphWindowItpIcon
  controls.mit           = VerditerGraphWindowMitLabel
  controls.btn_export    = VerditerGraphWindowExportBtn
  controls.btn_deaths    = VerditerGraphWindowDeathsBtn

  local sv = Verditer.SavedVars
  sv.graph = sv.graph or {}
  if sv.graph.view_idx and sv.graph.view_idx >= VIEW_MIN
     and sv.graph.view_idx <= VIEW_MAX then
    current_view = sv.graph.view_idx
  end
  if sv.graph.x then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(CENTER, GuiRoot, TOPLEFT, sv.graph.x, sv.graph.y)
  end
  if sv.graph.w then
    controls.window:SetDimensions(sv.graph.w, sv.graph.h)
  end
  controls.window:SetDimensionConstraints(360, 240, 1000, 700)

  VerditerGraphWindowBg:SetCenterColor(0, 0, 0, 0)
  VerditerGraphWindowChromeTop   :SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VerditerGraphWindowChromeBottom:SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VerditerGraphWindowChromeLeft  :SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VerditerGraphWindowChromeRight :SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VerditerGraphWindowBg:SetEdgeColor(C_EDGE.r, C_EDGE.g, C_EDGE.b, 1.0)
  local sv_a = (sv.graph and sv.graph.viewport_alpha_pct) or 30
  VerditerGraphWindowViewportBg:SetCenterColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, sv_a / 100)

  controls.grid   = create_grid("VerditerGrid", controls.canvas)
  controls.legend = create_legend("VerditerLegend", controls.canvas)

  controls.hit = WINDOW_MANAGER:CreateControl("VerditerGraphHit", controls.canvas, zc.CT_CONTROL)
  controls.hit:ClearAnchors()
  controls.hit:SetAnchor(TOPLEFT,     controls.canvas, TOPLEFT,     0, 0)
  controls.hit:SetAnchor(BOTTOMRIGHT, controls.canvas, BOTTOMRIGHT, 0, 0)
  controls.hit:SetDrawLevel(3)
  controls.hit:SetMouseEnabled(false)
  controls.hit:SetHidden(true)
  controls.hit:SetHandler("OnMouseEnter", function()
    if hover_allowed() then zev.register_update("VerditerHoverPoll", 50, hover_poll) end
  end)
  controls.hit:SetHandler("OnMouseExit", function()
    stop_hover_poll()
    hide_hover_ui()
    if hover_key ~= nil then hover_key = nil; render_current_view() end
  end)

  controls.crosshair = WINDOW_MANAGER:CreateControl("VerditerGraphCrosshair", controls.canvas, CT_TEXTURE)
  controls.crosshair:SetTexture(FILL_TEXTURE)
  controls.crosshair:SetTextureCoords(0, 0.05, 0, 1)
  controls.crosshair:SetWidth(1)
  controls.crosshair:SetColor(C_CROSSHAIR.r, C_CROSSHAIR.g, C_CROSSHAIR.b, C_CROSSHAIR.a)
  controls.crosshair:SetDrawLevel(4)
  controls.crosshair:SetAlpha(0)
  controls.crosshair:SetHidden(true)

  build_hover_card()

  card_fader      = make_fader(controls.card.root)
  crosshair_fader = make_fader(controls.crosshair)

  controls.pool_type_seg  = make_fill_pool("VerditerTypeSeg")
  controls.pool_type_line = make_line_pool("VerditerTypeLine")
  controls.pool_up        = make_fill_pool("VerditerUpFill")
  controls.pool_down      = make_fill_pool("VerditerDownFill")
  controls.pool_line_up   = make_line_pool("VerditerLineUp")
  controls.pool_line_down = make_line_pool("VerditerLineDown")

  controls.title:SetText(GetString(VERDITER_GRAPH_TITLE))
  controls.title:SetColor(0.78, 0.84, 0.95, 1)
  controls.btn_record:SetText(GetString(VERDITER_GRAPH_RECORD))
  controls.btn_stop:SetText(GetString(VERDITER_GRAPH_STOP))
  controls.btn_flush:SetText(GetString(VERDITER_GRAPH_FLUSH))
  local function tint_btn(btn, r, g, b)
    btn:SetNormalFontColor(r, g, b, 1)
    btn:SetMouseOverFontColor(math_min(1, r + 0.12), math_min(1, g + 0.12), math_min(1, b + 0.12), 1)
    btn:SetPressedFontColor(r * 0.85, g * 0.85, b * 0.85, 1)
  end
  tint_btn(controls.btn_record, 0.44, 0.70, 1.00)
  tint_btn(controls.btn_stop,   0.96, 0.80, 0.34)
  tint_btn(controls.btn_flush,  0.93, 0.40, 0.34)
  controls.status:SetText("")
  controls.status:SetColor(0.65, 0.65, 0.65, 1)
  controls.no_data:SetText(GetString(VERDITER_GRAPH_NO_DATA))
  controls.no_data:SetColor(0.45, 0.45, 0.45, 1)
  controls.no_data:SetHidden(false)
  controls.view_label:SetText(VIEW_LABELS[current_view])
  controls.view_label:SetColor(0.78, 0.84, 0.95, 1)

  controls.readout:SetColor(C_LINE_ABS.r, C_LINE_ABS.g, C_LINE_ABS.b, 0.95)
  controls.mit:SetColor(C_LINE_ABS.r, C_LINE_ABS.g, C_LINE_ABS.b, 0.72)
  update_header(0, 0)
  zev.register_update("VerditerHeaderTick", 1000, header_tick)
  refresh_button_colors()
end
