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
local table_sort                 = table.sort

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
local C_LINE_DMG  = { r = 0.93, g = 0.44, b = 0.38, a = 0.60 }
local C_FILL_DMG  = { r = 0.90, g = 0.38, b = 0.32, a = 0.10 }
local C_MARK_DEATH     = { r = 0.92, g = 0.88, b = 0.84, a = 0.55 }
local C_MARK_DEATH_OWN = { r = 0.95, g = 0.34, b = 0.28, a = 0.65 }
local C_MARK_RES       = { r = 0.45, g = 1.00, b = 0.62, a = 0.55 }
local TEX_SKULL    = "EsoUI/Art/TargetMarkers/Target_White_Skull_64.dds"
local TEX_RES      = "EsoUI/Art/Notifications/notificationIcon_resurrect.dds"
local MARK_ICON_SZ     = 16
local MARK_ICON_SZ_GRP = 11

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
local VIEW_BUFFS  = 4
local VIEW_TRIAGE = 5
local VIEW_LABELS = { "EMS", "SKILL", "CRIT", "BUFFS", "TRIAGE" }
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
local buff_hit = { n = 0, y0 = {}, y1 = {}, rec = {}, lane_x = 0, lane_w = 0, t0 = 0, span = 0 }
local buff_vis = {}
local C_BUFF_FALLBACK = { r = 0.55, g = 0.92, b = 0.62, a = 0.95 }

local function buff_color(rec)
  if rec.group and rec.group ~= "other" then
    return Verdant.SkillColors.group_color(rec.group)
  end
  return C_BUFF_FALLBACK
end

local function buff_description(rec)
  local d = rec.desc
  if d and d ~= "" then return d end
  Verdant.Diagnostics.bump("buffs.desc_miss")
  return nil
end
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
  return ZO_AbbreviateAndLocalizeNumber(math_floor(v), NUMBER_ABBREVIATION_PRECISION_TENTHS, false)
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

local function make_fill_pool(name_prefix, draw_level)
  return Pool.new(name_prefix, controls.canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(draw_level or 2)
    end,
    fill_reset)
end

local function make_skill_fill_pool(name_prefix, canvas_key)
  return Pool.new(name_prefix, controls[canvas_key], CT_TEXTURE, fill_factory, fill_reset)
end

local function make_line_pool(name_prefix)
  return Pool.new_virtual(name_prefix, controls.canvas, "VerdantGraphLineTemplate",
    function(c)
      line_factory(c)
      c:SetDrawLevel(3)
    end,
    line_reset)
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

  local ymax = WM:CreateControl(prefix .. "YMax", parent_ctrl, CT_LABEL)
  ymax:SetFont("ZoFontGameSmall")
  ymax:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  ymax:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
  ymax:SetColor(C_GRID_LBL.r, C_GRID_LBL.g, C_GRID_LBL.b, C_GRID_LBL.a)
  ymax:SetDimensions(54, 10)
  ymax:SetHidden(true)
  obj.ymax = ymax

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
  grid.ymax:SetHidden(true)
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
    local ymax_y = flip and (y_base + 2) or (y_base + ch_plot - 12)
    grid.ymax:ClearAnchors()
    grid.ymax:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -ymax_y)
    grid.ymax:SetText(fmt_val(max_val))
    grid.ymax:SetHidden(false)
  else
    for i = 1, N_HGRID do
      grid.hlines[i]:SetHidden(true)
      grid.ylabels[i]:SetHidden(true)
    end
    grid.ymax:SetHidden(true)
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
  if controls.pool_marker_line then
    controls.pool_marker_line:ReleaseAllObjects()
    controls.pool_marker_icon:ReleaseAllObjects()
    controls.pool_marker_line_top:ReleaseAllObjects()
    controls.pool_marker_icon_top:ReleaseAllObjects()
  end
  if controls.pool_buff_seg then
    controls.pool_buff_seg:ReleaseAllObjects()
    controls.pool_buff_icon:ReleaseAllObjects()
    controls.pool_buff_lbl:ReleaseAllObjects()
  end
  controls.pool_ehps:ReleaseAllObjects()
  controls.pool_mps:ReleaseAllObjects()
  controls.pool_line_ehps:ReleaseAllObjects()
  controls.pool_line_ems:ReleaseAllObjects()
  controls.pool_line_dmg:ReleaseAllObjects()
  controls.pool_dmg_fill:ReleaseAllObjects()
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
local r1_d_hs = {}
local r2_xs_top, r2_colh_top       = {}, {}
local r2_xs_bot, r2_colh_bot       = {}, {}
local r3_xs, r3_top_hs             = {}, {}

local MIN_COL_PX = 4
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
      col.d = s.d or 0
      cur_c = c
    else
      if ems > col.ems_peak then col.ems_peak = ems; col.e1 = s.eHPS; col.m1 = s.MPS end
      if s.eHPS > col.eHPS then    -- eHPS-peak: drives VIEW2-top stack + VIEW3 crit split
        col.eHPS = s.eHPS; col.ehps_groups = s.ehps_groups; col.ehps_abilities = s.ehps_abilities
        col.noncrit = s.noncrit; col.crit = s.crit
      end
      if s.MPS > col.MPS then col.MPS = s.MPS; col.mps_groups = s.mps_groups; col.mps_abilities = s.mps_abilities end  -- MPS-peak
      if (s.d or 0) > col.d then col.d = s.d end
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

  local base = WM:CreateControl("VerdantHoverCardBase", root, CT_TEXTURE)
  base:SetTexture(FILL_TEXTURE)
  base:SetTextureCoords(0, 1, 0, 0.05)
  base:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
  base:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
  base:SetColor(0.045, 0.05, 0.042, 0.97)

  local border_top = WM:CreateControl("VerdantHoverCardBTop", root, CT_TEXTURE)
  border_top:SetTexture(FILL_TEXTURE)
  border_top:SetTextureCoords(0, 1, 0, 0.05)
  border_top:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
  border_top:SetAnchor(TOPRIGHT, root, TOPRIGHT, 0, 0)
  border_top:SetHeight(1)
  border_top:SetColor(0.42, 1.00, 0.60, 0.30)
  local border_bot = WM:CreateControl("VerdantHoverCardBBot", root, CT_TEXTURE)
  border_bot:SetTexture(FILL_TEXTURE)
  border_bot:SetTextureCoords(0, 1, 0, 0.05)
  border_bot:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 0, 0)
  border_bot:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
  border_bot:SetHeight(1)
  border_bot:SetColor(0.42, 1.00, 0.60, 0.30)
  local border_r = WM:CreateControl("VerdantHoverCardBR", root, CT_TEXTURE)
  border_r:SetTexture(FILL_TEXTURE)
  border_r:SetTextureCoords(0, 1, 0, 0.05)
  border_r:SetAnchor(TOPRIGHT, root, TOPRIGHT, 0, 0)
  border_r:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
  border_r:SetWidth(1)
  border_r:SetColor(0.42, 1.00, 0.60, 0.30)

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

  local desc = WM:CreateControl("VerdantHoverCardDesc", root, CT_LABEL)
  desc:SetFont("ZoFontGameSmall")
  desc:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  desc:SetVerticalAlignment(TEXT_ALIGN_TOP)
  desc:SetMaxLineCount(0)
  desc:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 0.92)
  desc:SetHidden(true)

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

  controls.card = { root = root, swatch = swatch, name = name, stat = stat, time = time, desc = desc, rows = rows }
end

local function clear_card_rows(card)
  local rows = card.rows
  if not rows then return end
  for i = 1, CARD_MAX_ROWS do
    local r = rows[i]
    r.icon:SetHidden(true); r.name:SetHidden(true); r.val:SetHidden(true)
  end
  if card.desc then card.desc:SetHidden(true) end
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

local C_TRI_CLASS = {
  { r = 0.55, g = 0.92, b = 0.62 },
  { r = 0.55, g = 0.66, b = 0.82 },
  { r = 0.95, g = 0.42, b = 0.34 },
  { r = 0.62, g = 0.22, b = 0.22 },
  { r = 0.55, g = 0.55, b = 0.55 },
  { r = 0.50, g = 0.38, b = 0.38 },
}
local C_TRI_NAME   = { r = 0.86, g = 0.92, b = 0.88, a = 1.0 }
local C_TRI_DIM    = { r = 0.60, g = 0.64, b = 0.61, a = 0.95 }
local C_TRI_TIME   = { r = 0.48, g = 0.46, b = 0.42, a = 1.0 }
local C_TRI_DEPTH  = { r = 0.91, g = 0.72, b = 0.29, a = 1.0 }
local C_TRI_DEEP   = { r = 0.95, g = 0.42, b = 0.34, a = 1.0 }
local C_TRI_STRIP  = { r = 0.16, g = 0.15, b = 0.13, a = 0.90 }
local C_TRI_FAST   = { r = 0.58, g = 0.85, b = 0.92 }
local C_TRI_MID    = { r = 0.92, g = 0.95, b = 0.93 }
local C_TRI_SLOW   = { r = 0.91, g = 0.58, b = 0.42 }
local TRI_HEADER_H = 20
local TRI_STRIP_H  = 14
local TRI_STRIP_GAP = 10
local TRI_ROW_H    = 24
local TRI_ROW_GAP  = 2
local TRI_RT_FAST_MS = 1000
local TRI_RT_SLOW_MS = 2500

local TRI_CHIP_KEY = {
  "VERDANT_TRI_CHIP_SAVE",
  "VERDANT_TRI_CHIP_RECOVERED",
  "VERDANT_TRI_CHIP_DIED",
  "VERDANT_TRI_CHIP_MISSED",
  "VERDANT_TRI_CHIP_CUT",
  "VERDANT_TRI_CHIP_ONESHOT",
}

local TRI_TIP_KEY = {
  "VERDANT_TRI_TIP_SAVE",
  "VERDANT_TRI_TIP_RECOVERED",
  "VERDANT_TRI_TIP_DIED",
  "VERDANT_TRI_TIP_MISSED",
  "VERDANT_TRI_TIP_CUT",
  "VERDANT_TRI_TIP_ONESHOT",
}

local function tri_rt_color(rt)
  if rt < TRI_RT_FAST_MS then return C_TRI_FAST end
  if rt > TRI_RT_SLOW_MS then return C_TRI_SLOW end
  return C_TRI_MID
end

local function tri_time_str(off_ms)
  local s = math_floor(off_ms / 1000)
  return string_format("%d:%02d", math_floor(s / 60), s % 60)
end

local tri_hit = { n = 0, y0 = {}, y1 = {}, ep = {} }
local tri_dot_lastx = {}
local TRI_GLYPH_GAP = 6

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
  col.d = s.d or 0
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

local function show_buff_card(rec, t_at, conc_at, mx, my)
  local card = controls.card
  if not card then return end
  local BT  = Verdant.BuffTracker
  local c   = buff_color(rec)
  local dur = BT.session_end() - BT.session_start()
  local pct = (dur > 0) and math_floor(rec.uptime_ms / dur * 100 + 0.5) or 0

  card.swatch:SetColor(c.r, c.g, c.b, 1.0)
  card.name:SetColor(c.r, c.g, c.b, 1.0)
  card.name:SetText(rec.name or tostring(rec.id))
  card.stat:SetText(string_format("%s %d%%  ·  %s", GetString(VERDANT_BUFFH_UPTIME), pct, fmt_secs(rec.uptime_ms)))
  card.time:SetText(string_format("t  %s  ·  %d %s", fmt_secs(t_at), conc_at, GetString(VERDANT_BUFFH_HOLDERS)))

  clear_card_rows(card)
  local rows = {
    { GetString(VERDANT_BUFFH_PLAYERS), tostring(rec.unique_units) },
    { GetString(VERDANT_BUFFH_MAXC),    tostring(rec.max_conc) },
    { GetString(VERDANT_BUFFH_AVGC),    string_format("%.1f", BT.avg_concurrency(rec)) },
    { GetString(VERDANT_BUFFH_APPS),    tostring(rec.applications) },
    { GetString(VERDANT_BUFFH_GAP),     fmt_secs(rec.longest_gap_ms) },
  }
  for i = 1, #rows do
    local row = card.rows[i]
    row.icon:SetHidden(true)
    row.name:SetText(rows[i][1])
    row.name:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
    row.name:SetHidden(false)
    row.val:SetText(rows[i][2])
    row.val:SetHidden(false)
  end
  local h = CARD_ROWS_Y0 + #rows * CARD_ROW_H + 4
  local d = buff_description(rec)
  if not d and rec.group == "item" then
    d = GetString(VERDANT_BUFFH_SET_NO_TOOLTIP)
  end
  if d then
    local desc = card.desc
    desc:ClearAnchors()
    desc:SetAnchor(TOPLEFT, card.root, TOPLEFT, 12, h + 2)
    desc:SetWidth(CARD_W - 20)
    desc:SetHeight(400)
    desc:SetText(d)
    desc:SetHidden(false)
    local dh = desc:GetTextHeight()
    if dh < 12 then dh = 12 end
    desc:SetHeight(dh)
    h = h + dh + 10
  end
  card.root:SetHeight(h)
  position_card(mx, my)
end

local function buff_hover_poll(mx, my)
  local canvas = controls.canvas
  local rel_x  = mx - canvas:GetLeft()
  local rel_y  = my - canvas:GetTop()
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  local inside = rel_x >= 0 and rel_x <= cw and rel_y >= 0 and rel_y <= ch

  local rec = nil
  if inside then
    for i = 1, buff_hit.n do
      if rel_y >= buff_hit.y0[i] and rel_y <= buff_hit.y1[i] then
        rec = buff_hit.rec[i]
        break
      end
    end
  end

  local new = rec and rec.id or nil
  if new ~= hover_key then hover_key = new; render_current_view() end

  if not rec or buff_hit.span <= 0 then
    hide_hover_ui()
    return
  end

  local frac = (rel_x - buff_hit.lane_x) / buff_hit.lane_w
  if frac < 0 then frac = 0 end
  if frac > 1 then frac = 1 end
  local t_abs = buff_hit.t0 + frac * buff_hit.span
  local conc  = Verdant.BuffTracker.concurrency_at(rec, t_abs)

  if controls.crosshair then
    local cx = math_floor(rel_x)
    controls.crosshair:ClearAnchors()
    controls.crosshair:SetAnchor(TOPLEFT,    canvas, TOPLEFT,    cx, 0)
    controls.crosshair:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, cx, 0)
    fade_in(crosshair_fader)
  end

  show_buff_card(rec, t_abs - buff_hit.t0, conc, mx, my)
end

local function hover_poll()
  if not hover_allowed() then
    if hover_key ~= nil then hover_key = nil; render_current_view() end
    hide_hover_ui()
    return
  end
  local mx, my = GetUIMousePosition()
  if current_view == VIEW_BUFFS then
    buff_hover_poll(mx, my)
    return
  end
  if current_view == VIEW_TRIAGE then
    local canvas = controls.canvas
    local rel_y  = my - canvas:GetTop()
    local rel_x  = mx - canvas:GetLeft()
    local inside = rel_x >= 0 and rel_x <= canvas:GetWidth()
    local e = nil
    if inside then
      for i = 1, tri_hit.n do
        if rel_y >= tri_hit.y0[i] and rel_y <= tri_hit.y1[i] then
          e = tri_hit.ep[i]
          break
        end
      end
    end
    if e then
      local T = Verdant.Triage
      local c = C_TRI_CLASS[e.class] or C_TRI_CLASS[5]
      local who = T.slot_name(e.slot) or ("group" .. e.slot)
      local depth = math_floor(e.min_rho * 100 + 0.5)
      local facts = string_format("|c%s%d%%|r %s",
        hexc((e.min_rho < 0.15) and C_TRI_DEEP or C_TRI_DEPTH), depth,
        GetString(VERDANT_TRI_TIP_MINHP))
      if e.rt >= 0 then
        facts = facts .. string_format("  ·  |c%s%s|r",
          hexc(tri_rt_color(e.rt)), string_format(GetString(VERDANT_TRI_TIP_RT), e.rt / 1000))
      elseif e.responded then
        facts = facts .. "  ·  |c" .. hexc(C_TRI_FAST) .. GetString(VERDANT_TRI_RT_HOTS) .. "|r"
      end
      show_moment_card(c, who, facts, e.t_start - tri_hit.t0, mx, my)
      local card = controls.card
      if card and card.desc then
        local desc = card.desc
        desc:ClearAnchors()
        desc:SetAnchor(TOPLEFT, card.root, TOPLEFT, 12, CARD_H - 4)
        desc:SetWidth(CARD_W - 20)
        desc:SetHeight(400)
        desc:SetText(GetString(rawget(_G, TRI_TIP_KEY[e.class] or TRI_TIP_KEY[5])))
        desc:SetHidden(false)
        local dh = desc:GetTextHeight()
        if dh < 12 then dh = 12 end
        desc:SetHeight(dh)
        card.root:SetHeight(CARD_H - 4 + dh + 8)
      end
    else
      fade_out(card_fader)
    end
    return
  end
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
    local dmg_part = ""
    if (col.d or 0) > 0 then
      dmg_part = string_format("  ·  |c%s%s dmg|r", hexc(C_LINE_DMG), fmt_val(col.d))
    end
    show_moment_card(C_EHPS, "Healing",
      string_format("|c%s%s HPS|r  ·  |c%s%s MPS|r%s",
        hexc(C_EHPS), fmt_val(col.ehps or 0), hexc(C_MPS), fmt_val(col.mps or 0), dmg_part),
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
  local main  = (current_view ~= VIEW_SKILL)
  if controls.hit_main then
    controls.hit_main:SetMouseEnabled(on and main)
    controls.hit_main:SetHidden(not (on and main))
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

local function draw_one_marker(pool_line, pool_icon, canvas, m, x, is_group)
  local c
  if m.death then
    c = is_group and C_MARK_DEATH or C_MARK_DEATH_OWN
  else
    c = C_MARK_RES
  end
  local sz = is_group and MARK_ICON_SZ_GRP or MARK_ICON_SZ

  local ln = pool_line:AcquireObject()
  ln:ClearAnchors()
  ln:SetAnchor(TOPLEFT,    canvas, TOPLEFT,    x, 0)
  ln:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, 0)
  ln:SetWidth(1)
  ln:SetColor(c.r, c.g, c.b, is_group and c.a * 0.45 or c.a)
  ln:SetHidden(false)

  local ic = pool_icon:AcquireObject()
  ic:ClearAnchors()
  ic:SetTexture(m.death and TEX_SKULL or TEX_RES)
  ic:SetDimensions(sz, sz)
  ic:SetAnchor(TOPLEFT, canvas, TOPLEFT, x - math_floor(sz / 2), is_group and 4 or 1)
  ic:SetColor(c.r, c.g, c.b, is_group and 0.50 or 0.95)
  ic:SetHidden(false)
end

local function draw_markers(pool_line, pool_icon, canvas, t0, span, lane_x, lane_w)
  if span <= 0 then return end
  local ms, n = Verdant.TemporalBuffer.markers()
  for i = 1, n do
    local m = ms[i]
    if m.who and m.t >= t0 and m.t <= t0 + span then
      local x = lane_x + math_floor((m.t - t0) / span * lane_w + 0.5)
      draw_one_marker(pool_line, pool_icon, canvas, m, x, true)
    end
  end
  for i = 1, n do
    local m = ms[i]
    if not m.who and m.t >= t0 and m.t <= t0 + span then
      local x = lane_x + math_floor((m.t - t0) / span * lane_w + 0.5)
      draw_one_marker(pool_line, pool_icon, canvas, m, x, false)
    end
  end
end

local function render_view1()
  controls.pool_ehps:ReleaseAllObjects()
  controls.pool_mps:ReleaseAllObjects()
  controls.pool_line_ehps:ReleaseAllObjects()
  controls.pool_line_ems:ReleaseAllObjects()
  controls.pool_line_dmg:ReleaseAllObjects()
  controls.pool_dmg_fill:ReleaseAllObjects()

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
  local max_d   = 0
  local t_first, t_last = 0, 0
  Verdant.TemporalBuffer.iterate(function(i, s)
    local ems = s.eHPS + s.MPS
    if ems > max_ems then max_ems = ems end
    if (s.d or 0) > max_d then max_d = s.d end
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
    r1_d_hs[i] = (max_d > 0) and math_floor(ch_plot * 0.92 * (s.d / max_d) + 0.5) or 0

    if r1_d_hs[i] > 0 then
      local df = controls.pool_dmg_fill:AcquireObject()
      df:ClearAnchors()
      df:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
      df:SetWidth(bw)
      df:SetHeight(r1_d_hs[i])
      df:SetColor(C_FILL_DMG.r, C_FILL_DMG.g, C_FILL_DMG.b, C_FILL_DMG.a)
      df:SetHidden(false)
    end

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

  if col_w >= 3 and max_d > 0 then
    for i = 2, m do
      local ld = controls.pool_line_dmg:AcquireObject()
      ld:ClearAnchors()
      ld:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(r1_d_hs[i-1] + TIME_STRIP_H))
      ld:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(r1_d_hs[i]   + TIME_STRIP_H))
      ld:SetColor(C_LINE_DMG.r, C_LINE_DMG.g, C_LINE_DMG.b, C_LINE_DMG.a)
      ld:SetThickness(1)
      ld:SetHidden(false)
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

  draw_markers(controls.pool_marker_line, controls.pool_marker_icon,
               canvas, t_first, t_last - t_first, 0, cw)
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
  draw_markers(controls.pool_marker_line_top, controls.pool_marker_icon_top,
               ec, t_first, span_ms, 0, cw)
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
  draw_markers(controls.pool_marker_line, controls.pool_marker_icon,
               canvas, t_first, t_last - t_first, 0, cw)
end

local BUFF_MAX_ROW_H = 26
local BUFF_GUTTER_W = 140
local BUFF_ROW_GAP  = 3
local BUFF_MIN_ROW  = 10
local BUFF_PCT_W    = 34
local C_BUFF_NAME   = { r = 0.86, g = 0.92, b = 0.88, a = 1.0 }
local C_BUFF_MORE   = { r = 0.60, g = 0.66, b = 0.62, a = 0.90 }
local C_BUFF_PCT    = { r = 0.64, g = 0.72, b = 0.66, a = 1.0 }
local C_BUFF_LANE   = { r = 0.62, g = 1.00, b = 0.74, a = 0.05 }

local function seg_alpha(conc, max_conc)
  if max_conc <= 1 then return 0.90 end
  return 0.40 + 0.55 * (conc / max_conc)
end




local function render_view4()
  controls.pool_buff_seg:ReleaseAllObjects()
  controls.pool_buff_icon:ReleaseAllObjects()
  controls.pool_buff_lbl:ReleaseAllObjects()

  local BT    = Verdant.BuffTracker
  local n_all = BT.count()
  local vis   = buff_vis
  local n     = 0
  for i = 1, n_all do
    local rec = BT.get(i)
    if not (rec.only_self and rec.desc == "" and rec.group ~= "item" and not rec.vetoed) then
      n = n + 1
      vis[n] = rec
    end
  end

  if n == 0 then
    controls.no_data:SetHidden(false)
    hide_grid(controls.grid_ems)
    return
  end
  controls.no_data:SetHidden(true)

  local canvas = controls.canvas
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  if cw <= BUFF_GUTTER_W + 40 or ch <= 4 then return end

  local recording = Verdant.TemporalBuffer.is_recording()
  local t0   = BT.session_start()
  local t_hi = recording and GetGameTimeMilliseconds() or BT.session_end()
  local span = t_hi - t0
  if span <= 0 then return end

  Verdant.Diagnostics.bump("graph.view_buffs.renders")
  draw_grid(controls.grid_ems, canvas, 0, span)

  local ch_plot = math_max(4, ch - TIME_STRIP_H)
  local rows    = n
  local extra   = 0
  local row_h   = math_floor(ch_plot / rows) - BUFF_ROW_GAP
  if row_h < BUFF_MIN_ROW then
    rows  = math_max(1, math_floor(ch_plot / (BUFF_MIN_ROW + BUFF_ROW_GAP)) - 1)
    if rows > n then rows = n end
    extra = (n > rows) and 1 or 0
    row_h = math_floor(ch_plot / (rows + extra)) - BUFF_ROW_GAP
    if row_h < 6 then return end
  elseif row_h > BUFF_MAX_ROW_H then
    row_h = BUFF_MAX_ROW_H
  end
  if n > rows then Verdant.Diagnostics.bump("graph.view_buffs.overflow") end

  local SC     = Verdant.SkillColors
  local lane_x = BUFF_GUTTER_W
  local lane_w = cw - BUFF_GUTTER_W
  local isz    = (row_h < 20) and row_h or 20

  local capture = not recording
  buff_hit.n = capture and rows or 0
  buff_hit.lane_x = lane_x
  buff_hit.lane_w = lane_w
  buff_hit.t0     = t0
  buff_hit.span   = span
  local hk = hover_key
  local dur = capture and (BT.session_end() - BT.session_start()) or 0

  for i = 1, rows do
    local rec = vis[i]
    local y   = (i - 1) * (row_h + BUFF_ROW_GAP)
    local c   = buff_color(rec)
    if capture then
      buff_hit.y0[i]  = y
      buff_hit.y1[i]  = y + row_h
      buff_hit.rec[i] = rec
    end

    local lane = controls.pool_buff_seg:AcquireObject()
    lane:ClearAnchors()
    lane:SetAnchor(TOPLEFT, canvas, TOPLEFT, lane_x, y)
    lane:SetWidth(lane_w)
    lane:SetHeight(row_h)
    lane:SetColor(C_BUFF_LANE.r, C_BUFF_LANE.g, C_BUFF_LANE.b, C_BUFF_LANE.a)
    lane:SetHidden(false)

    local icon = controls.pool_buff_icon:AcquireObject()
    icon:ClearAnchors()
    icon:SetTexture(SC.ability_icon(rec.id))
    icon:SetDimensions(isz, isz)
    icon:SetColor(1, 1, 1, 1)
    icon:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, y + math_floor((row_h - isz) / 2))
    icon:SetHidden(false)

    local name_w = capture and (BUFF_GUTTER_W - isz - BUFF_PCT_W - 12)
                            or (BUFF_GUTTER_W - isz - 10)
    local lbl = controls.pool_buff_lbl:AcquireObject()
    lbl:ClearAnchors()
    lbl:SetText(rec.name or tostring(rec.id))
    lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if hk ~= nil and rec.id ~= hk then
      lbl:SetColor(C_BUFF_NAME.r * 0.45, C_BUFF_NAME.g * 0.45, C_BUFF_NAME.b * 0.45, 0.6)
    else
      lbl:SetColor(C_BUFF_NAME.r, C_BUFF_NAME.g, C_BUFF_NAME.b, C_BUFF_NAME.a)
    end
    lbl:SetDimensions(name_w, row_h)
    lbl:SetAnchor(TOPLEFT, canvas, TOPLEFT, isz + 4, y)
    lbl:SetHidden(false)

    if capture and dur > 0 then
      local pct = controls.pool_buff_lbl:AcquireObject()
      pct:ClearAnchors()
      pct:SetText(string_format("%d%%", math_floor(rec.uptime_ms / dur * 100 + 0.5)))
      pct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
      if hk ~= nil and rec.id ~= hk then
        pct:SetColor(C_BUFF_PCT.r * 0.45, C_BUFF_PCT.g * 0.45, C_BUFF_PCT.b * 0.45, 0.6)
      else
        pct:SetColor(C_BUFF_PCT.r, C_BUFF_PCT.g, C_BUFF_PCT.b, C_BUFF_PCT.a)
      end
      pct:SetDimensions(BUFF_PCT_W, row_h)
      pct:SetAnchor(TOPLEFT, canvas, TOPLEFT, BUFF_GUTTER_W - BUFF_PCT_W - 6, y)
      pct:SetHidden(false)
    end

    local n_steps = rec.n_steps
    local run_x0, run_x1, run_conc
    local function flush_run()
      if not run_x0 then return end
      local seg = controls.pool_buff_seg:AcquireObject()
      seg:ClearAnchors()
      seg:SetAnchor(TOPLEFT, canvas, TOPLEFT, run_x0, y)
      seg:SetWidth(math_max(1, run_x1 - run_x0))
      seg:SetHeight(row_h)
      local a = seg_alpha(run_conc, rec.max_conc)
      if hk ~= nil and rec.id ~= hk then
        seg:SetColor(c.r * 0.30 + C_DIM_BIAS, c.g * 0.30 + C_DIM_BIAS,
                     c.b * 0.30 + C_DIM_BIAS, 0.25)
      else
        seg:SetColor(c.r, c.g, c.b, a)
      end
      seg:SetHidden(false)
      run_x0 = nil
    end
    for k = 1, n_steps do
      local conc = rec.step_c[k]
      if conc > 0 then
        local st = rec.step_t[k]
        local en = (k < n_steps) and rec.step_t[k + 1] or t_hi
        if en > t_hi then en = t_hi end
        if en > st then
          local x0 = lane_x + math_floor((st - t0) / span * lane_w + 0.5)
          local x1 = lane_x + math_floor((en - t0) / span * lane_w + 0.5)
          if x1 <= x0 then x1 = x0 + 1 end
          if run_x0 and x0 <= run_x1 then
            if x1 > run_x1 then run_x1 = x1 end
            if conc > run_conc then run_conc = conc end
          else
            flush_run()
            run_x0, run_x1, run_conc = x0, x1, conc
          end
        end
      end
    end
    flush_run()
  end

  draw_markers(controls.pool_marker_line, controls.pool_marker_icon,
               canvas, t0, span, lane_x, lane_w)

  if n > rows then
    local more = controls.pool_buff_lbl:AcquireObject()
    more:ClearAnchors()
    more:SetText(string_format(GetString(VERDANT_BUFFS_MORE), n - rows))
    more:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    more:SetColor(C_BUFF_MORE.r, C_BUFF_MORE.g, C_BUFF_MORE.b, C_BUFF_MORE.a)
    more:SetDimensions(cw, row_h)
    more:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, rows * (row_h + BUFF_ROW_GAP))
    more:SetHidden(false)
  end
end

local function render_view5()
  controls.pool_buff_seg:ReleaseAllObjects()
  controls.pool_buff_icon:ReleaseAllObjects()
  controls.pool_buff_lbl:ReleaseAllObjects()
  hide_grid(controls.grid_ems)

  local T = Verdant.Triage
  local eps, n_eps = T.episodes()

  if n_eps == 0 then
    controls.no_data:SetHidden(false)
    return
  end
  controls.no_data:SetHidden(true)

  local canvas = controls.canvas
  local cw, ch = canvas:GetWidth(), canvas:GetHeight()
  if cw <= 180 or ch <= TRI_HEADER_H + TRI_STRIP_H + TRI_ROW_H then return end

  local BT = Verdant.BuffTracker
  local recording = Verdant.TemporalBuffer.is_recording()
  local t0   = BT.session_start()
  local t_hi = recording and GetGameTimeMilliseconds() or BT.session_end()
  local span = t_hi - t0
  if span <= 0 then return end

  Verdant.Diagnostics.bump("graph.view_triage.renders")
  hit_begin(hit_main, 0)

  local capture = not recording
  tri_hit.n  = 0
  tri_hit.t0 = t0

  local s = T.summary()
  local head = controls.pool_buff_lbl:AcquireObject()
  head:ClearAnchors()
  local head_text
  if s.rt_n > 0 then
    head_text = string_format("%s |cebf2ed%d/%d|r    RT50 |cebf2ed%.1fs|r    RT95 |cebf2ed%.1fs|r",
      GetString(VERDANT_TRI_HEAD_SAVES), s.counts.s,
      s.counts.s + s.counts.o + s.counts.l + s.counts.m,
      s.rt50 / 1000, s.rt95 / 1000)
  else
    head_text = string_format("%s |cebf2ed%d/%d|r",
      GetString(VERDANT_TRI_HEAD_SAVES), s.counts.s,
      s.counts.s + s.counts.o + s.counts.l + s.counts.m)
  end
  head:SetText(head_text)
  head:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  head:SetColor(C_TRI_DIM.r, C_TRI_DIM.g, C_TRI_DIM.b, C_TRI_DIM.a)
  head:SetDimensions(cw, TRI_HEADER_H)
  head:SetAnchor(TOPLEFT, canvas, TOPLEFT, 2, 0)
  head:SetHidden(false)

  local strip_y = TRI_HEADER_H
  local strip = controls.pool_buff_seg:AcquireObject()
  strip:ClearAnchors()
  strip:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, strip_y)
  strip:SetWidth(cw)
  strip:SetHeight(TRI_STRIP_H)
  strip:SetColor(C_TRI_STRIP.r, C_TRI_STRIP.g, C_TRI_STRIP.b, C_TRI_STRIP.a)
  strip:SetHidden(false)

  local s_top = controls.pool_buff_seg:AcquireObject()
  s_top:ClearAnchors()
  s_top:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, strip_y - 1)
  s_top:SetWidth(cw)
  s_top:SetHeight(1)
  s_top:SetColor(0, 0, 0, 0.45)
  s_top:SetHidden(false)
  local s_bot = controls.pool_buff_seg:AcquireObject()
  s_bot:ClearAnchors()
  s_bot:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, strip_y + TRI_STRIP_H)
  s_bot:SetWidth(cw)
  s_bot:SetHeight(1)
  s_bot:SetColor(1, 1, 1, 0.05)
  s_bot:SetHidden(false)

  for k in pairs(tri_dot_lastx) do tri_dot_lastx[k] = nil end
  for i = 1, n_eps do
    local e = eps[i]
    if e.t_start >= t0 and e.t_start <= t_hi then
      local x = math_floor((e.t_start - t0) / span * (cw - 8) + 0.5)
      local lx = tri_dot_lastx[e.class]
      if lx == nil or (x - lx) >= TRI_GLYPH_GAP then
        tri_dot_lastx[e.class] = x
        local c = C_TRI_CLASS[e.class] or C_TRI_CLASS[5]
        local rim = controls.pool_buff_seg:AcquireObject()
        rim:ClearAnchors()
        rim:SetAnchor(TOPLEFT, canvas, TOPLEFT, x, strip_y + 2)
        rim:SetWidth(10)
        rim:SetHeight(10)
        rim:SetColor(0.04, 0.04, 0.035, 0.95)
        rim:SetHidden(false)
        local dot = controls.pool_buff_seg:AcquireObject()
        dot:ClearAnchors()
        dot:SetAnchor(TOPLEFT, canvas, TOPLEFT, x + 1, strip_y + 3)
        dot:SetWidth(8)
        dot:SetHeight(8)
        dot:SetColor(c.r, c.g, c.b, e.class == T.CLASS_O and 0.55 or 1.0)
        dot:SetHidden(false)
      end
    end
  end

  local tl = controls.pool_buff_lbl:AcquireObject()
  tl:ClearAnchors()
  tl:SetText("0:00")
  tl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  tl:SetColor(C_TRI_TIME.r, C_TRI_TIME.g, C_TRI_TIME.b, 0.75)
  tl:SetDimensions(50, TRI_STRIP_H)
  tl:SetAnchor(TOPLEFT, canvas, TOPLEFT, 3, strip_y)
  tl:SetHidden(false)
  local tr = controls.pool_buff_lbl:AcquireObject()
  tr:ClearAnchors()
  tr:SetText(tri_time_str(span))
  tr:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
  tr:SetColor(C_TRI_TIME.r, C_TRI_TIME.g, C_TRI_TIME.b, 0.75)
  tr:SetDimensions(50, TRI_STRIP_H)
  tr:SetAnchor(TOPLEFT, canvas, TOPLEFT, cw - 53, strip_y)
  tr:SetHidden(false)

  local ms, mn = Verdant.TemporalBuffer.markers()
  local last_own_x, last_grp_x
  for i = 1, mn do
    local m = ms[i]
    if m.death and m.t >= t0 and m.t <= t_hi then
      local x = math_floor((m.t - t0) / span * (cw - 8) + 0.5)
      local lx = m.who and last_grp_x or last_own_x
      if lx == nil or (x - lx) >= TRI_GLYPH_GAP then
        if m.who then last_grp_x = x else last_own_x = x end
        local ic = controls.pool_marker_icon:AcquireObject()
        ic:ClearAnchors()
        ic:SetTexture(TEX_SKULL)
        ic:SetDimensions(10, 10)
        ic:SetAnchor(TOPLEFT, canvas, TOPLEFT, x, strip_y + 2)
        local mc = m.who and C_MARK_DEATH or C_MARK_DEATH_OWN
        ic:SetColor(mc.r, mc.g, mc.b, m.who and 0.5 or 0.95)
        ic:SetHidden(false)
      end
    end
  end

  local list_y = strip_y + TRI_STRIP_H + TRI_STRIP_GAP
  local fit = math_floor((ch - list_y) / (TRI_ROW_H + TRI_ROW_GAP))
  if fit < 1 then return end
  local first = (n_eps > fit) and (n_eps - fit + 1) or 1
  local pslot = T.player_slot()

  if first > 1 then
    local more = controls.pool_buff_lbl:AcquireObject()
    more:ClearAnchors()
    more:SetText(string_format(GetString(VERDANT_TRI_MORE), first - 1))
    more:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    more:SetColor(C_TRI_TIME.r, C_TRI_TIME.g, C_TRI_TIME.b, 0.9)
    more:SetDimensions(160, TRI_HEADER_H)
    more:SetAnchor(TOPLEFT, canvas, TOPLEFT, cw - 164, 0)
    more:SetHidden(false)
  end

  local row_i = 0
  for i = first, n_eps do
    local e = eps[i]
    local y = list_y + row_i * (TRI_ROW_H + TRI_ROW_GAP)
    row_i = row_i + 1
    local c = C_TRI_CLASS[e.class] or C_TRI_CLASS[5]

    if capture then
      tri_hit.n = tri_hit.n + 1
      tri_hit.y0[tri_hit.n] = y
      tri_hit.y1[tri_hit.n] = y + TRI_ROW_H
      tri_hit.ep[tri_hit.n] = e
    end

    local bg = controls.pool_buff_seg:AcquireObject()
    bg:ClearAnchors()
    bg:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, y)
    bg:SetWidth(cw)
    bg:SetHeight(TRI_ROW_H)
    bg:SetColor(c.r, c.g, c.b, e.class == T.CLASS_O and 0.03 or 0.07)
    bg:SetHidden(false)

    local hl = controls.pool_buff_seg:AcquireObject()
    hl:ClearAnchors()
    hl:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, y)
    hl:SetWidth(cw)
    hl:SetHeight(1)
    hl:SetColor(1, 1, 1, 0.05)
    hl:SetHidden(false)

    local sep = controls.pool_buff_seg:AcquireObject()
    sep:ClearAnchors()
    sep:SetAnchor(TOPLEFT, canvas, TOPLEFT, 0, y + TRI_ROW_H)
    sep:SetWidth(cw)
    sep:SetHeight(1)
    sep:SetColor(0, 0, 0, 0.40)
    sep:SetHidden(false)

    local tlbl = controls.pool_buff_lbl:AcquireObject()
    tlbl:ClearAnchors()
    tlbl:SetText(tri_time_str(e.t_start - t0))
    tlbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    tlbl:SetColor(C_TRI_TIME.r, C_TRI_TIME.g, C_TRI_TIME.b, C_TRI_TIME.a)
    tlbl:SetDimensions(38, TRI_ROW_H)
    tlbl:SetAnchor(TOPLEFT, canvas, TOPLEFT, 6, y)
    tlbl:SetHidden(false)

    local icon_path = T.slot_icon(e.slot)
    if icon_path then
      local ci = controls.pool_buff_icon:AcquireObject()
      ci:ClearAnchors()
      ci:SetTexture(icon_path)
      ci:SetDimensions(16, 16)
      ci:SetAnchor(TOPLEFT, canvas, TOPLEFT, 46, y + 4)
      ci:SetColor(1, 1, 1, e.class == T.CLASS_O and 0.55 or 0.95)
      ci:SetHidden(false)
    end

    local pname = T.slot_name(e.slot) or ("group" .. e.slot)
    if e.slot == pslot then pname = pname .. GetString(VERDANT_TRI_YOU) end
    local nlbl = controls.pool_buff_lbl:AcquireObject()
    nlbl:ClearAnchors()
    nlbl:SetText(pname)
    nlbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if e.class == T.CLASS_O then
      nlbl:SetColor(C_TRI_DIM.r, C_TRI_DIM.g, C_TRI_DIM.b, 0.85)
    else
      nlbl:SetColor(C_TRI_NAME.r, C_TRI_NAME.g, C_TRI_NAME.b, C_TRI_NAME.a)
    end
    local name_w = math_max(60, cw - 320)
    nlbl:SetDimensions(name_w, TRI_ROW_H)
    nlbl:SetAnchor(TOPLEFT, canvas, TOPLEFT, 66, y)
    nlbl:SetHidden(false)

    local dx = 66 + name_w
    local depth = math_floor(e.min_rho * 100 + 0.5)
    local dc = (e.min_rho < 0.15) and C_TRI_DEEP or C_TRI_DEPTH
    local bar_y = y + math_floor((TRI_ROW_H - 8) / 2)
    local bbg = controls.pool_buff_seg:AcquireObject()
    bbg:ClearAnchors()
    bbg:SetAnchor(TOPLEFT, canvas, TOPLEFT, dx, bar_y)
    bbg:SetWidth(36)
    bbg:SetHeight(8)
    bbg:SetColor(0.05, 0.05, 0.045, 0.90)
    bbg:SetHidden(false)
    local fill_w = math_floor(36 * e.min_rho + 0.5)
    if fill_w < 1 then fill_w = 1 end
    local bfill = controls.pool_buff_seg:AcquireObject()
    bfill:ClearAnchors()
    bfill:SetAnchor(TOPLEFT, canvas, TOPLEFT, dx, bar_y)
    bfill:SetWidth(fill_w)
    bfill:SetHeight(8)
    bfill:SetColor(dc.r, dc.g, dc.b, 0.95)
    bfill:SetHidden(false)
    local dlbl = controls.pool_buff_lbl:AcquireObject()
    dlbl:ClearAnchors()
    dlbl:SetText(string_format("%d%%", depth))
    dlbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    dlbl:SetColor(dc.r, dc.g, dc.b, 0.95)
    dlbl:SetDimensions(34, TRI_ROW_H)
    dlbl:SetAnchor(TOPLEFT, canvas, TOPLEFT, dx + 40, y)
    dlbl:SetHidden(false)

    local chip_x = dx + 78
    local chip_text = GetString(rawget(_G, TRI_CHIP_KEY[e.class] or TRI_CHIP_KEY[5]))
    local chip_w = #chip_text * 7 + 14
    local frame = controls.pool_buff_seg:AcquireObject()
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, canvas, TOPLEFT, chip_x, y + 3)
    frame:SetWidth(chip_w)
    frame:SetHeight(TRI_ROW_H - 6)
    frame:SetColor(c.r, c.g, c.b, e.class == T.CLASS_O and 0.30 or 0.60)
    frame:SetHidden(false)
    local chip = controls.pool_buff_seg:AcquireObject()
    chip:ClearAnchors()
    chip:SetAnchor(TOPLEFT, canvas, TOPLEFT, chip_x + 1, y + 4)
    chip:SetWidth(chip_w - 2)
    chip:SetHeight(TRI_ROW_H - 8)
    chip:SetColor(0.09, 0.085, 0.075, 0.92)
    chip:SetHidden(false)
    local clbl = controls.pool_buff_lbl:AcquireObject()
    clbl:ClearAnchors()
    clbl:SetText(chip_text)
    clbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    clbl:SetColor(c.r, c.g, c.b, 1)
    clbl:SetDimensions(chip_w, TRI_ROW_H)
    clbl:SetAnchor(TOPLEFT, canvas, TOPLEFT, chip_x, y)
    clbl:SetHidden(false)

    local rlbl = controls.pool_buff_lbl:AcquireObject()
    rlbl:ClearAnchors()
    if e.rt >= 0 then
      local rc = tri_rt_color(e.rt)
      rlbl:SetText(string_format("RT %.1fs", e.rt / 1000))
      rlbl:SetColor(rc.r, rc.g, rc.b, 1)
    elseif e.responded then
      rlbl:SetText(GetString(VERDANT_TRI_RT_HOTS))
      rlbl:SetColor(C_TRI_FAST.r, C_TRI_FAST.g, C_TRI_FAST.b, 0.55)
    else
      rlbl:SetText("RT -")
      rlbl:SetColor(C_TRI_TIME.r, C_TRI_TIME.g, C_TRI_TIME.b, 0.8)
    end
    rlbl:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    rlbl:SetDimensions(70, TRI_ROW_H)
    rlbl:SetAnchor(TOPLEFT, canvas, TOPLEFT, cw - 76, y)
    rlbl:SetHidden(false)
  end
end

function render_current_view()
  if controls.pool_marker_line then
    controls.pool_marker_line:ReleaseAllObjects()
    controls.pool_marker_icon:ReleaseAllObjects()
    controls.pool_marker_line_top:ReleaseAllObjects()
    controls.pool_marker_icon_top:ReleaseAllObjects()
  end
  if current_view == VIEW_EMS then
    render_view1()
  elseif current_view == VIEW_CRIT then
    render_view3()
  elseif current_view == VIEW_BUFFS then
    render_view4()
  elseif current_view == VIEW_TRIAGE then
    render_view5()
  else
    layout_skill_area()
    render_view2()
  end
end

local summary_text = nil

local C_SUM_AVG  = C_LINE_EHPS
local C_SUM_PEAK = C_LINE_EMS
local C_SUM_CRIT = C_CRIT
local C_SUM_VAL  = { r = 0.92, g = 0.95, b = 0.93 }

local C_SUM_RT = { r = 0.58, g = 0.85, b = 0.92 }

local function build_summary_text()
  local s = Verdant.TemporalBuffer.summary()
  if s.count == 0 then return nil end
  local vc = hexc(C_SUM_VAL)
  local crit_pct = math_floor(s.crit_pct * 100 + 0.5)
  local text = string_format(
    "|c%s%s|r |c%s%s|r   |c%s%s|r |c%s%s|r   |c%s%s|r |c%s%d%%|r",
    hexc(C_SUM_AVG),  GetString(VERDANT_SUMMARY_AVG),  vc, fmt_val(s.avg_ems),
    hexc(C_SUM_PEAK), GetString(VERDANT_SUMMARY_PEAK), vc, fmt_val(s.peak_ems),
    hexc(C_SUM_CRIT), GetString(VERDANT_SUMMARY_CRIT), vc, crit_pct)
  local ts = Verdant.Triage.summary()
  if ts.rt_n > 0 then
    text = text .. string_format("   |c%s%s|r |c%s%.1fs|r",
      hexc(C_SUM_RT), GetString(VERDANT_SUMMARY_RT), vc, ts.rt50 / 1000)
  end
  return text
end

local function update_summary_chip()
  local chip = controls.summary
  if not chip then return end
  local show = summary_text ~= nil
            and not Verdant.TemporalBuffer.is_recording()
            and Verdant.TemporalBuffer.count() > 0
  if show then
    chip.label:SetText(summary_text)
    chip.bg:SetWidth(chip.label:GetTextWidth() + 16)
    chip.bg:SetHidden(false)
    chip.label:SetHidden(false)
  else
    chip.bg:SetHidden(true)
    chip.label:SetHidden(true)
  end
end

local function refresh_button_colors()
  local recording = Verdant.TemporalBuffer.is_recording()
  controls.btn_record:SetEnabled(not recording)
  controls.btn_stop:SetEnabled(recording)
  update_hover_gate()
  update_summary_chip()
end

local function set_view(v)
  current_view = v
  controls.view_label:SetText(VIEW_LABELS[v])
  hover_key = nil
  if v == VIEW_BUFFS then
    controls.no_data:SetText(GetString(VERDANT_GRAPH_NO_BUFFS))
  elseif v == VIEW_TRIAGE then
    controls.no_data:SetText(GetString(VERDANT_GRAPH_NO_TRIAGE))
  else
    controls.no_data:SetText(GetString(VERDANT_GRAPH_NO_DATA))
  end

  local use_main_canvas = (v ~= VIEW_SKILL)
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
  local d_group = Verdant.Metrics.D_group(now)
  Verdant.TemporalBuffer.push(now, ehps, mps, crit, noncrit,
                              sample_ehps_groups, sample_mps_groups,
                              sample_ehps_abilities, sample_mps_abilities, d_group)
  Verdant.BuffTracker.expire_stale(now)

  local elapsed = math_floor((now - recording_start_ms) / 1000)
  local prefix  = Verdant.AutoRecord.is_auto_session() and "AUTO " or ""
  controls.status:SetText(string_format("%s%d:%02d", prefix, math_floor(elapsed / 60), elapsed % 60))

  if not controls.window:IsHidden() then
    render_current_view()
  end
  prof_exit("graph.sample_tick")
end

function M.on_record_click()
  if Verdant.TemporalBuffer.is_recording() then return end
  log:info("record click")
  if not Verdant.AutoRecord.is_auto_active() then
    Verdant.AutoRecord.notify_manual_record()
  end
  summary_text = nil
  Verdant.TemporalBuffer.clear()
  release_all_pools()
  hide_all_grids()
  controls.no_data:SetHidden(false)
  Verdant.TemporalBuffer.start_recording()
  recording_start_ms = GetGameTimeMilliseconds()
  Verdant.BuffTracker.start_session(recording_start_ms)
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
  Verdant.AutoRecord.notify_manual_stop()
  Verdant.TemporalBuffer.stop_recording()
  zev.unregister_update(Verdant.Constants.TEMPORAL.UPDATE_NAME)
  Verdant.BuffTracker.finalize(GetGameTimeMilliseconds())
  Verdant.SessionStore.on_session_stop()
  summary_text = build_summary_text()
  local s = Verdant.TemporalBuffer.summary()
  Verdant.Diagnostics.bump("graph.summary.computed")
  log:info("session summary: samples=", s.count, "dur_ms=", s.dur_ms,
           "avg_ems=", math_floor(s.avg_ems), "peak_ems=", math_floor(s.peak_ems),
           "crit_pct=", math_floor(s.crit_pct * 100 + 0.5))
  refresh_button_colors()
  render_current_view()
end

function M.load_session(sess)
  if Verdant.TemporalBuffer.is_recording() then
    d("[V] " .. GetString(VERDANT_LIB_BUSY))
    return false
  end
  if not (sess and sess.streams and sess.desc and sess.head) then
    d("[V] " .. string_format(GetString(VERDANT_LIB_CORRUPT), "missing structure"))
    return false
  end
  local vsf = Verdant.lib.vsf
  local series, e1 = vsf.unpack(sess.streams.series,   sess.desc.series)
  local steps,  e2 = vsf.unpack(sess.streams.steps,    sess.desc.steps)
  local eps,    e3 = vsf.unpack(sess.streams.episodes, sess.desc.episodes)
  local mks,    e4 = vsf.unpack(sess.streams.markers,  sess.desc.markers)
  if not (series and steps and eps and mks) then
    d("[V] " .. string_format(GetString(VERDANT_LIB_CORRUPT),
      tostring(e1 or e2 or e3 or e4)))
    return false
  end

  if sess.streams.shares and sess.desc.shares then
    local shares = vsf.unpack(sess.streams.shares, sess.desc.shares)
    if shares then
      local gkeys = sess.gkeys or {}
      local SC = Verdant.SkillColors
      for i = 1, #shares do
        local r = shares[i]
        local sample = series[r.si]
        if sample then
          local field = (r.ch == 0) and "eg" or "mg"
          local tbl = sample[field]
          if not tbl then tbl = { count = 0 }; sample[field] = tbl end
          local key = gkeys[r.key + 1] or "other"
          local c = SC.group_color(key)
          tbl.count = tbl.count + 1
          tbl[tbl.count] = {
            r = c.r, g = c.g, b = c.b, a = c.a,
            share = r.sh, key = key,
          }
        end
      end
    end
  end

  if sess.streams.abilities and sess.desc.abilities then
    local abilities = vsf.unpack(sess.streams.abilities, sess.desc.abilities)
    if abilities then
      local SC = Verdant.SkillColors
      for i = 1, #abilities do
        local r = abilities[i]
        local sample = series[r.si]
        if sample then
          local field = (r.ch == 0) and "ea" or "ma"
          local tbl = sample[field]
          if not tbl then tbl = { count = 0 }; sample[field] = tbl end
          local key = SC.ability_group(r.id)
          local c = SC.group_color(key)
          tbl.count = tbl.count + 1
          tbl[tbl.count] = {
            id = r.id, share = r.sh, key = key,
            r = c.r, g = c.g, b = c.b, a = c.a,
          }
        end
      end
    end
  end

  release_all_pools()
  hide_all_grids()

  local markers = {}
  for i = 1, #mks do
    local m = mks[i]
    markers[i] = {
      t = m.t, death = m.death == 1,
      who = (m.who > 0) and ("group" .. m.who) or nil,
    }
  end
  Verdant.TemporalBuffer.load_session(series, markers)
  Verdant.BuffTracker.load_session(sess.buffs or {}, steps, 0, sess.head.dur_ms or 0)
  Verdant.Triage.load_session(eps, sess.roster, sess.head.player_slot)

  summary_text = build_summary_text()
  controls.status:SetText(string_format(GetString(VERDANT_LIB_LOADED),
    sess.head.zone or "?"))
  Verdant.Visibility.set("graph", true)
  refresh_button_colors()
  render_current_view()
  Verdant.Diagnostics.bump("library.session_loaded")
  return true
end

function M.on_flush_click()
  if Verdant.TemporalBuffer.is_recording() then
    zev.unregister_update(Verdant.Constants.TEMPORAL.UPDATE_NAME)
    Verdant.TemporalBuffer.stop_recording()
  end
  Verdant.BuffTracker.reset()
  summary_text = nil
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
  if v < VIEW_EMS then v = VIEW_TRIAGE end
  release_all_pools()
  set_view(v)
end

function M.next_view()
  local v = current_view + 1
  if v > VIEW_TRIAGE then v = VIEW_EMS end
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
    local use_main_canvas = (current_view ~= VIEW_SKILL)
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
  controls.btn_lib       = VerdantGraphWindowLibBtn
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
  controls.pool_line_dmg       = make_line_pool("VerdantGraphLineDmg")
  controls.pool_dmg_fill       = make_fill_pool("VerdantGraphDmgFill", 1)
  controls.pool_marker_line = Pool.new("VerdantMarkerLine", controls.canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(4)
    end, fill_reset)
  controls.pool_marker_icon = Pool.new("VerdantMarkerIcon", controls.canvas, CT_TEXTURE,
    function(c)
      c:SetPixelRoundingEnabled(false)
      c:SetDrawLevel(5)
    end,
    function(c) c:SetHidden(true) end)
  controls.pool_marker_line_top = Pool.new("VerdantMarkerLineTop", controls.ehps_canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(4)
    end, fill_reset)
  controls.pool_marker_icon_top = Pool.new("VerdantMarkerIconTop", controls.ehps_canvas, CT_TEXTURE,
    function(c)
      c:SetPixelRoundingEnabled(false)
      c:SetDrawLevel(5)
    end,
    function(c) c:SetHidden(true) end)
  controls.pool_skill_top      = make_skill_fill_pool("VerdantSkillFillTop", "ehps_canvas")
  controls.pool_skill_bot      = make_skill_fill_pool("VerdantSkillFillBot", "mps_canvas")
  controls.pool_line_skill_top = make_skill_line_pool("VerdantSkillLineTop", "ehps_canvas")
  controls.pool_line_skill_bot = make_skill_line_pool("VerdantSkillLineBot", "mps_canvas")

  controls.pool_buff_seg = make_fill_pool("VerdantBuffSeg")
  controls.pool_buff_icon = Pool.new("VerdantBuffIcon", controls.canvas, CT_TEXTURE,
    function(c) c:SetPixelRoundingEnabled(false) end,
    function(c) c:SetHidden(true) end)
  controls.pool_buff_lbl = Pool.new("VerdantBuffLbl", controls.canvas, CT_LABEL,
    function(c)
      c:SetFont("ZoFontGameSmall")
      c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
      c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end,
    function(c) c:SetHidden(true) end)

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

  local sum_bg = WM:CreateControl("VerdantGraphSummaryBg", controls.window, CT_TEXTURE)
  sum_bg:SetTexture(FILL_TEXTURE)
  sum_bg:SetTextureCoords(0, 1, 0, 0.05)
  sum_bg:SetColor(0.04, 0.09, 0.06, 0.55)
  sum_bg:SetAnchor(TOPRIGHT, controls.window, TOPRIGHT, -14, 61)
  sum_bg:SetHeight(20)
  sum_bg:SetDrawLevel(11)
  sum_bg:SetHidden(true)

  local sum_label = WM:CreateControl("VerdantGraphSummaryLabel", controls.window, CT_LABEL)
  sum_label:SetFont("ZoFontGameSmall")
  sum_label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  sum_label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  sum_label:SetAnchor(TOPRIGHT, controls.window, TOPRIGHT, -22, 61)
  sum_label:SetHeight(20)
  sum_label:SetDrawLevel(12)
  sum_label:SetHidden(true)

  controls.summary = { bg = sum_bg, label = sum_label }

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
