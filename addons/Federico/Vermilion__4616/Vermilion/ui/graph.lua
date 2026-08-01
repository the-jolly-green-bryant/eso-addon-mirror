Vermilion = Vermilion or {}
Vermilion.Graph = {}
local M = Vermilion.Graph

local api  = Vermilion.zenimax.api
local zui  = Vermilion.zenimax.ui
local zc   = Vermilion.zenimax.constants
local zev  = Vermilion.zenimax.events
local WINDOW_MANAGER             = zui.WINDOW_MANAGER
local GetGameTimeMilliseconds    = api.GetGameTimeMilliseconds
local GetString                  = api.GetString
local math_max                   = math.max
local math_floor                 = math.floor
local string_format              = string.format

local log               = Vermilion.Log.for_module("graph")
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

local DamageTypeColors  = nil

local C_EDPS      = { r = 0.88, g = 0.24, b = 0.18, a = 0.92 }  -- deep crimson (HP work)
local C_SHDPS     = { r = 0.85, g = 0.40, b = 0.75, a = 0.90 }  -- pink-magenta (shield work)
local C_LINE_EDPS = { r = 1.00, g = 0.42, b = 0.32, a = 1.00 }  -- brighter crimson frontier
local C_LINE_EOS  = { r = 1.00, g = 0.92, b = 0.96, a = 1.00 }  -- bright EOS frontier
local C_CHROME    = { r = 1.00, g = 0.62, b = 0.58, a = 0.82 }  -- pronounced crimson wash

local C_NONCRIT   = { r = 0.55, g = 0.22, b = 0.18, a = 0.90 }  -- muted crimson base
local C_CRIT      = { r = 1.00, g = 0.82, b = 0.28, a = 0.96 }  -- bright gold (crit pops)

local C_VIEWPORT  = { r = 1.00, g = 0.78, b = 0.75 }

local FILL_TEXTURE   = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local FILL_T, FILL_B = 0, 0.53125
local LINE_THICKNESS = 2

local N_HGRID      = 3
local N_VGRID      = 3
local TIME_STRIP_H = 18
local C_GRID_LINE = { r = 0.55, g = 0.58, b = 0.70, a = 0.25 }
local C_GRID_LBL  = { r = 0.82, g = 0.85, b = 0.90, a = 0.92 }
local C_TIME_LBL  = { r = 0.68, g = 0.70, b = 0.75, a = 0.85 }

-- state
local controls           = {}
local recording_start_ms = 0

local VIEW_BY_SKILL   = 1
local VIEW_BY_TYPE    = 2
local VIEW_BY_OUTCOME = 3
local VIEW_BY_CRIT    = 4
local VIEW_LABELS     = { "SKILL", "TYPE", "OUTCOME", "CRIT" }
local VIEW_MIN, VIEW_MAX = VIEW_BY_SKILL, VIEW_BY_CRIT
local current_view    = VIEW_BY_SKILL

local crit_threshold_pct = 50

local DT_ICON_DIR = "Vermilion/assets/dtype/"
local DTYPE_ICON = {}
local function map_icon(dt, file) if dt ~= nil then DTYPE_ICON[dt] = DT_ICON_DIR .. file end end
map_icon(zc.DAMAGE_TYPE_FIRE,     "fire.dds")
map_icon(zc.DAMAGE_TYPE_COLD,     "cold.dds")
map_icon(zc.DAMAGE_TYPE_SHOCK,    "shock.dds")
map_icon(zc.DAMAGE_TYPE_POISON,   "poison.dds")
map_icon(zc.DAMAGE_TYPE_DISEASE,  "disease.dds")
map_icon(zc.DAMAGE_TYPE_BLEED,    "bleed.dds")
map_icon(zc.DAMAGE_TYPE_PHYSICAL, "physical.dds")
map_icon(zc.DAMAGE_TYPE_MAGIC,    "magic.dds")
map_icon(zc.DAMAGE_TYPE_OBLIVION, "oblivion.dds")
map_icon(zc.DAMAGE_TYPE_EARTH,    "earth.dds")
map_icon(zc.DAMAGE_TYPE_DROWN,    "drown.dds")
map_icon(zc.DAMAGE_TYPE_GENERIC,  "generic.dds")
map_icon(zc.DAMAGE_TYPE_NONE,     "generic.dds")

local GetUIMousePosition = api.GetUIMousePosition
local hover_key  = nil
local hit = { cols = {}, n = 0 }
local C_DIM_BIAS = 0.05
local render_current_view

local FADE_MS = 120
local card_fader, crosshair_fader

local CARD_W, CARD_H = 210, 56
local CARD_ROW_H     = 16
local CARD_MAX_ROWS  = 5
local CARD_ROWS_Y0   = 54
local C_CARD_BG     = { r = 0.10, g = 0.04, b = 0.05, a = 0.96 }
local C_CARD_ACCENT = { r = 0.88, g = 0.24, b = 0.18, a = 1.0 }
local C_CARD_STAT   = { r = 0.92, g = 0.84, b = 0.82, a = 1.0 }
local C_CARD_NAME   = { r = 1.00, g = 0.90, b = 0.88, a = 1.0 }
local C_CARD_TIME   = { r = 0.72, g = 0.64, b = 0.62, a = 1.0 }
local C_CROSSHAIR   = { r = 1.00, g = 0.50, b = 0.42, a = 0.50 }

local C_CRIT_IDLE  = { r = 0.55, g = 0.55, b = 0.55, a = 0.85 }
local C_CRIT_BELOW = { r = 0.90, g = 0.32, b = 0.28, a = 1.0 }
local C_CRIT_ON    = { r = 0.95, g = 0.78, b = 0.30, a = 1.0 }
local C_CRIT_ABOVE = { r = 0.42, g = 0.85, b = 0.45, a = 1.0 }
local CRIT_MARGIN  = 5

-- small helpers
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


local DPS_ICON_IDLE   = "/esoui/art/treeicons/collection_indexicon_weapons_up.dds"
local DPS_ICON_ACTIVE = "/esoui/art/treeicons/collection_indexicon_weapons_down.dds"

local function update_header(eos)
  controls.readout:SetText(fmt_readout(eos))
  controls.dps_icon:SetTexture(eos > 0 and DPS_ICON_ACTIVE or DPS_ICON_IDLE)
end

local function apply_crit(c, txt)
  controls.crit:SetText(txt)
  controls.crit:SetColor(c.r, c.g, c.b, c.a)
  if controls.icon then controls.icon:SetColor(c.r, c.g, c.b, c.a) end
end

local function update_crit(now)
  if not controls.crit then return end
  local crit, noncrit = Vermilion.Metrics.crit_split(now)
  local tot = crit + noncrit
  if tot <= 0 then
    apply_crit(C_CRIT_IDLE, "—")
    return
  end
  local pct = math_floor(crit / tot * 100 + 0.5)
  local c
  if pct < crit_threshold_pct - CRIT_MARGIN then
    c = C_CRIT_BELOW
  elseif pct > crit_threshold_pct + CRIT_MARGIN then
    c = C_CRIT_ABOVE
  else
    c = C_CRIT_ON
  end
  apply_crit(c, pct .. "%")
end

local function header_tick()
  if controls.window:IsHidden() then return end
  local now = GetGameTimeMilliseconds()
  update_header(Vermilion.Metrics.eDPS(now) + Vermilion.Metrics.ShDPS(now))
  update_crit(now)
end

local Pool = Vermilion.lib.plot.Pool

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
  return Pool.new_virtual(name_prefix, controls.canvas, "VermilionGraphLineTemplate", line_factory, line_reset)
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

local function release_all_pools()
  controls.pool_eos_segments:ReleaseAllObjects()
  controls.pool_eos_line:ReleaseAllObjects()
  controls.pool_edps:ReleaseAllObjects()
  controls.pool_shdps:ReleaseAllObjects()
  controls.pool_line_edps:ReleaseAllObjects()
  controls.pool_line_eos:ReleaseAllObjects()
end

local MIN_COL_PX = 2
local dec_cols   = {}

local function decimate(cw)
  local TB       = Vermilion.TemporalBuffer
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
    local eos = s.eDPS + s.ShDPS
    if c ~= cur_c then
      m = m + 1
      col = dec_cols[m]
      if not col then col = {}; dec_cols[m] = col end
      col.c = c; col.t = s.t
      col.eos_peak = eos;    col.eDPS = s.eDPS; col.ShDPS = s.ShDPS
      col.eos_groups = s.eos_groups; col.eos_abilities = s.eos_abilities
      col.edps_peak = s.eDPS; col.noncrit = s.noncrit; col.crit = s.crit
      col.dtype_groups = s.dtype_groups; col.dtype_abilities = s.dtype_abilities
      cur_c = c
    else
      if eos > col.eos_peak then
        col.eos_peak = eos; col.eDPS = s.eDPS; col.ShDPS = s.ShDPS
        col.eos_groups = s.eos_groups; col.eos_abilities = s.eos_abilities
      end
      if s.eDPS > col.edps_peak then
        col.edps_peak = s.eDPS; col.noncrit = s.noncrit; col.crit = s.crit
        col.dtype_groups = s.dtype_groups; col.dtype_abilities = s.dtype_abilities
      end
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

local function window_extent()
  local max_eos = 0
  local t_first, t_last = 0, 0
  Vermilion.TemporalBuffer.iterate(function(i, s)
    local eos = s.eDPS + s.ShDPS
    if eos > max_eos then max_eos = eos end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end)
  return max_eos, (t_last - t_first)
end

local rsk_xs, rsk_eos_hs                  = {}, {}
local rty_xs, rty_edps_hs                 = {}, {}
local rout_xs, rout_edps_hs, rout_eos_hs  = {}, {}, {}
local rcr_xs, rcr_top_hs                  = {}, {}

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
  return not Vermilion.TemporalBuffer.is_recording()
     and Vermilion.TemporalBuffer.count() > 0
     and not controls.window:IsHidden()
end

local function hover_label(band)
  if current_view == VIEW_BY_TYPE then
    return (DamageTypeColors and DamageTypeColors.name(band.key)) or "Damage"
  end
  local k = band.key
  if not k or k == "" then return "Skill" end
  if k == "other" then return "Other" end
  return (tostring(k):gsub("_", " "))
end

local function stop_hover_poll() zev.unregister_update("VermilionHoverPoll") end

local function hide_hover_ui()
  fade_out(card_fader)
  fade_out(crosshair_fader)
end


local function build_hover_card()
  local WM   = WINDOW_MANAGER
  local root = WM:CreateControl("VermilionHoverCard", controls.window, zc.CT_CONTROL)
  root:SetDimensions(CARD_W, CARD_H)
  root:SetMouseEnabled(false)
  root:SetDrawLevel(20)
  root:SetAlpha(0)
  root:SetHidden(true)

  local bg = WM:CreateControl("VermilionHoverCardBg", root, CT_TEXTURE)
  bg:SetTexture(FILL_TEXTURE)
  bg:SetTextureCoords(0, 1, 0, 0.05)
  bg:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
  bg:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
  bg:SetColor(C_CARD_BG.r, C_CARD_BG.g, C_CARD_BG.b, C_CARD_BG.a)

  local accent = WM:CreateControl("VermilionHoverCardAccent", root, CT_TEXTURE)
  accent:SetTexture(FILL_TEXTURE)
  accent:SetTextureCoords(0, 0.05, 0, 1)
  accent:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
  accent:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 0, 0)
  accent:SetWidth(3)
  accent:SetColor(C_CARD_ACCENT.r, C_CARD_ACCENT.g, C_CARD_ACCENT.b, 1.0)

  local swatch = WM:CreateControl("VermilionHoverCardSwatch", root, CT_TEXTURE)
  swatch:SetTexture(FILL_TEXTURE)
  swatch:SetTextureCoords(0, 1, 0, 0.05)
  swatch:SetDimensions(14, 14)
  swatch:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 7)

  local name = WM:CreateControl("VermilionHoverCardName", root, CT_LABEL)
  name:SetFont("ZoFontGameBold")
  name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  name:SetAnchor(TOPLEFT, root, TOPLEFT, 28, 6)
  name:SetDimensions(CARD_W - 36, 16)

  local stat = WM:CreateControl("VermilionHoverCardStat", root, CT_LABEL)
  stat:SetFont("ZoFontGameSmall")
  stat:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  stat:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  stat:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
  stat:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 24)
  stat:SetDimensions(CARD_W - 20, 14)

  local time = WM:CreateControl("VermilionHoverCardTime", root, CT_LABEL)
  time:SetFont("ZoFontGameSmall")
  time:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  time:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  time:SetColor(C_CARD_TIME.r, C_CARD_TIME.g, C_CARD_TIME.b, 1.0)
  time:SetAnchor(TOPLEFT, root, TOPLEFT, 12, 40)
  time:SetDimensions(CARD_W - 20, 12)

  local rows = {}
  for i = 1, CARD_MAX_ROWS do
    local y = CARD_ROWS_Y0 + (i - 1) * CARD_ROW_H

    local icon = WM:CreateControl("VermilionHoverCardIcon" .. i, root, CT_TEXTURE)
    icon:SetDimensions(13, 13)
    icon:SetAnchor(TOPLEFT, root, TOPLEFT, 12, y + 1)
    icon:SetHidden(true)

    local rn = WM:CreateControl("VermilionHoverCardRowName" .. i, root, CT_LABEL)
    rn:SetFont("ZoFontGameSmall")
    rn:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    rn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rn:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
    rn:SetAnchor(TOPLEFT, root, TOPLEFT, 30, y)
    rn:SetDimensions(108, CARD_ROW_H)
    rn:SetHidden(true)

    local rv = WM:CreateControl("VermilionHoverCardRowVal" .. i, root, CT_LABEL)
    rv:SetFont("ZoFontGameSmall")
    rv:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    rv:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rv:SetColor(C_CARD_TIME.r, C_CARD_TIME.g, C_CARD_TIME.b, 1.0)
    rv:SetAnchor(TOPRIGHT, root, TOPRIGHT, -8, y)
    rv:SetDimensions(64, CARD_ROW_H)
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

local function card_layout(card, iconMode)
  if card.iconMode == iconMode then return end
  card.iconMode = iconMode
  local s = iconMode and 28 or 14
  local textX = iconMode and 46 or 28
  card.swatch:SetDimensions(s, s)
  card.swatch:ClearAnchors()
  card.swatch:SetAnchor(TOPLEFT, card.root, TOPLEFT, iconMode and 10 or 12, iconMode and 6 or 7)
  card.name:ClearAnchors()
  card.name:SetAnchor(TOPLEFT, card.root, TOPLEFT, textX, 6)
  card.name:SetDimensions(CARD_W - textX - 8, 16)
  card.stat:ClearAnchors()
  card.stat:SetAnchor(TOPLEFT, card.root, TOPLEFT, iconMode and textX or 12, 24)
  card.stat:SetDimensions(CARD_W - (iconMode and textX or 12) - 8, 14)
end

local function swatch_solid(card, r, g, b)
  card_layout(card, false)
  card.swatch:SetTexture(FILL_TEXTURE)
  card.swatch:SetTextureCoords(0, 1, 0, 0.05)
  card.swatch:SetColor(r, g, b, 1.0)
end

local function swatch_icon(card, path)
  card_layout(card, true)
  card.swatch:SetTexture(path)
  card.swatch:SetTextureCoords(0, 1, 0, 1)
  card.swatch:SetColor(1, 1, 1, 1)
end

local function show_card(band, col, mx, my, elapsed_ms)
  local card = controls.card
  if not card then return end
  local total = band.eos or 0
  local ticon = (current_view == VIEW_BY_TYPE) and DTYPE_ICON[band.key] or nil
  if ticon then swatch_icon(card, ticon) else swatch_solid(card, band.r, band.g, band.b) end
  card.name:SetColor(band.r, band.g, band.b, 1.0)
  card.name:SetText(hover_label(band))
  local pct = math_floor((band.share or 0) * 100 + 0.5)
  local val = (band.share or 0) * total
  card.stat:SetText(string_format("%s DPS  ·  %d%%", fmt_readout(val), pct))
  card.time:SetText("t  " .. fmt_secs(elapsed_ms or 0))

  clear_card_rows(card)
  local shown = 0
  local list = nil
  if col then
    if current_view == VIEW_BY_SKILL then list = col.eos_abilities
    elseif current_view == VIEW_BY_TYPE then list = col.dtype_abilities end
  end
  if list and (list.count or 0) > 0 then
    local SC = Vermilion.SkillColors
    local n  = list.count
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
        row.val:SetText(string_format("%s · %d%%", fmt_readout(av), ap))
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
  swatch_solid(card, swatch_c.r, swatch_c.g, swatch_c.b)
  card.name:SetColor(C_CARD_NAME.r, C_CARD_NAME.g, C_CARD_NAME.b, 1.0)
  card.name:SetText(name_text)
  card.stat:SetText(stat_text)
  card.time:SetText("t  " .. fmt_secs(elapsed_ms or 0))
  clear_card_rows(card)
  card.root:SetHeight(CARD_H)
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
    show_card(band, col, mx, my, elapsed)
  elseif current_view == VIEW_BY_OUTCOME then
    show_moment_card(C_EDPS, "Outgoing",
      string_format("|c%s%s DPS|r  ·  |c%s%s Shld|r",
        hexc(C_EDPS), fmt_readout(col.edps or 0), hexc(C_SHDPS), fmt_readout(col.shdps or 0)),
      elapsed, mx, my)
  elseif current_view == VIEW_BY_CRIT then
    local tot = (col.crit or 0) + (col.noncrit or 0)
    local cp  = (tot > 0) and math_floor((col.crit or 0) / tot * 100 + 0.5) or 0
    show_moment_card(C_CRIT, "Crit",
      string_format("|c%s%d%% crit|r  ·  %s DPS", hexc(C_CRIT), cp, fmt_readout(tot)),
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

local function hit_begin(n) hit.n = n end

local function hit_col(i, x, bw, s)
  if i == 1 then hit.t0 = s.t end
  local col = hit.cols[i]
  if not col then col = { bands = {} }; hit.cols[i] = col end
  col.x0 = x; col.x1 = x + bw; col.nb = 0; col.t = s.t
  col.edps = s.eDPS; col.shdps = s.ShDPS; col.crit = s.crit; col.noncrit = s.noncrit
  col.eos_abilities = s.eos_abilities; col.dtype_abilities = s.dtype_abilities
  return col
end

local function render_by_skill()
  controls.pool_eos_segments:ReleaseAllObjects()
  controls.pool_eos_line:ReleaseAllObjects()
  controls.pool_edps:ReleaseAllObjects()
  controls.pool_shdps:ReleaseAllObjects()
  controls.pool_line_edps:ReleaseAllObjects()
  controls.pool_line_eos:ReleaseAllObjects()

  local n = Vermilion.TemporalBuffer.count()
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

  local max_eos, span_ms = window_extent()
  if max_eos <= 0 then hide_grid(controls.grid) return end
  draw_grid(controls.grid, canvas, max_eos, span_ms)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs, eos_hs = rsk_xs, rsk_eos_hs
  local capture = not Vermilion.TemporalBuffer.is_recording()
  local hk = hover_key
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x   = left
    local bw  = math_max(1, right - left - bar_gap)
    local eos = s.eDPS + s.ShDPS
    local col_h = math_max(0, math_floor(ch_plot * (eos / max_eos) + 0.5))
    xs[i]     = x + bw * 0.5
    eos_hs[i] = col_h

    local col = capture and hit_col(i, left, right - left, s) or nil

    local y_off = 0
    local groups = s.eos_groups
    for g = 1, (groups.count or 0) do
      local grp   = groups[g]
      local seg_h = math_max(1, math_floor(col_h * grp.share + 0.5))
      local t = controls.pool_eos_segments:AcquireObject()
      t:ClearAnchors()
      t:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(y_off + TIME_STRIP_H))
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
        band.lo    = TIME_STRIP_H + y_off
        band.hi    = TIME_STRIP_H + y_off + seg_h
        band.share = grp.share
        band.eos   = eos
        band.r = grp.r; band.g = grp.g; band.b = grp.b
        col.nb = nb
      end

      y_off = y_off + seg_h
    end
  end

  if col_w >= 3 then
    for i = 2, m do
      local le = controls.pool_eos_line:AcquireObject()
      le:ClearAnchors()
      le:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(eos_hs[i-1] + TIME_STRIP_H))
      le:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(eos_hs[i]   + TIME_STRIP_H))
      le:SetColor(C_LINE_EOS.r, C_LINE_EOS.g, C_LINE_EOS.b, C_LINE_EOS.a)
      le:SetThickness(LINE_THICKNESS)
      le:SetHidden(false)
    end
  end
end

local function render_by_type()
  controls.pool_eos_segments:ReleaseAllObjects()
  controls.pool_eos_line:ReleaseAllObjects()
  controls.pool_edps:ReleaseAllObjects()
  controls.pool_shdps:ReleaseAllObjects()
  controls.pool_line_edps:ReleaseAllObjects()
  controls.pool_line_eos:ReleaseAllObjects()

  local n = Vermilion.TemporalBuffer.count()
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

  local max_edps, span_ms = 0, 0
  do
    local t_first, t_last = 0, 0
    Vermilion.TemporalBuffer.iterate(function(i, s)
      if s.eDPS > max_edps then max_edps = s.eDPS end
      if i == 1 then t_first = s.t end
      t_last = s.t
    end)
    span_ms = t_last - t_first
  end
  if max_edps <= 0 then hide_grid(controls.grid) return end
  draw_grid(controls.grid, canvas, max_edps, span_ms)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs, edps_hs = rty_xs, rty_edps_hs
  local capture = not Vermilion.TemporalBuffer.is_recording()
  local hk = hover_key
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x    = left
    local bw   = math_max(1, right - left - bar_gap)
    local edps = s.edps_peak or 0
    local col_h = math_max(0, math_floor(ch_plot * (edps / max_edps) + 0.5))
    xs[i]      = x + bw * 0.5
    edps_hs[i] = col_h

    local col = capture and hit_col(i, left, right - left, s) or nil

    local y_off  = 0
    local groups = s.dtype_groups
    for g = 1, (groups and groups.count or 0) do
      local grp   = groups[g]
      local seg_h = math_max(1, math_floor(col_h * grp.share + 0.5))
      local t = controls.pool_eos_segments:AcquireObject()
      t:ClearAnchors()
      t:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(y_off + TIME_STRIP_H))
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
        band.lo    = TIME_STRIP_H + y_off
        band.hi    = TIME_STRIP_H + y_off + seg_h
        band.share = grp.share
        band.eos   = edps
        band.r = grp.r; band.g = grp.g; band.b = grp.b
        col.nb = nb
      end

      y_off = y_off + seg_h
    end
  end

  if col_w >= 3 then
    for i = 2, m do
      local le = controls.pool_eos_line:AcquireObject()
      le:ClearAnchors()
      le:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(edps_hs[i-1] + TIME_STRIP_H))
      le:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(edps_hs[i]   + TIME_STRIP_H))
      le:SetColor(C_LINE_EDPS.r, C_LINE_EDPS.g, C_LINE_EDPS.b, C_LINE_EDPS.a)
      le:SetThickness(LINE_THICKNESS)
      le:SetHidden(false)
    end
  end
end

local function render_by_outcome()
  controls.pool_eos_segments:ReleaseAllObjects()
  controls.pool_eos_line:ReleaseAllObjects()
  controls.pool_edps:ReleaseAllObjects()
  controls.pool_shdps:ReleaseAllObjects()
  controls.pool_line_edps:ReleaseAllObjects()
  controls.pool_line_eos:ReleaseAllObjects()

  local n = Vermilion.TemporalBuffer.count()
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

  local max_eos, span_ms = window_extent()
  if max_eos <= 0 then hide_grid(controls.grid) return end
  draw_grid(controls.grid, canvas, max_eos, span_ms)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs, edps_hs, eos_hs = rout_xs, rout_edps_hs, rout_eos_hs
  local capture = not Vermilion.TemporalBuffer.is_recording()
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x       = left
    local bw      = math_max(1, right - left - bar_gap)
    if capture then hit_col(i, left, right - left, s) end
    local edps_h  = math_max(0, math_floor(ch_plot * (s.eDPS  / max_eos) + 0.5))
    local shdps_h = math_max(0, math_floor(ch_plot * (s.ShDPS / max_eos) + 0.5))
    xs[i]      = x + bw * 0.5
    edps_hs[i] = edps_h
    eos_hs[i]  = edps_h + shdps_h

    if edps_h > 0 then
      local te = controls.pool_edps:AcquireObject()
      te:ClearAnchors()
      te:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
      te:SetWidth(bw)
      te:SetHeight(edps_h)
      te:SetColor(C_EDPS.r, C_EDPS.g, C_EDPS.b, C_EDPS.a)
      te:SetHidden(false)
    end

    if shdps_h > 0 then
      local ts = controls.pool_shdps:AcquireObject()
      ts:ClearAnchors()
      ts:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -(TIME_STRIP_H + edps_h))
      ts:SetWidth(bw)
      ts:SetHeight(shdps_h)
      ts:SetColor(C_SHDPS.r, C_SHDPS.g, C_SHDPS.b, C_SHDPS.a)
      ts:SetHidden(false)
    end
  end

  if col_w >= 3 then
    for i = 2, m do
      local le = controls.pool_line_edps:AcquireObject()
      le:ClearAnchors()
      le:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(edps_hs[i-1] + TIME_STRIP_H))
      le:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(edps_hs[i]   + TIME_STRIP_H))
      le:SetColor(C_LINE_EDPS.r, C_LINE_EDPS.g, C_LINE_EDPS.b, C_LINE_EDPS.a)
      le:SetThickness(LINE_THICKNESS)
      le:SetHidden(false)

      local lo = controls.pool_line_eos:AcquireObject()
      lo:ClearAnchors()
      lo:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(eos_hs[i-1] + TIME_STRIP_H))
      lo:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(eos_hs[i]   + TIME_STRIP_H))
      lo:SetColor(C_LINE_EOS.r, C_LINE_EOS.g, C_LINE_EOS.b, C_LINE_EOS.a)
      lo:SetThickness(LINE_THICKNESS)
      lo:SetHidden(false)
    end
  end
end

local function render_by_crit()
  controls.pool_eos_segments:ReleaseAllObjects()
  controls.pool_eos_line:ReleaseAllObjects()
  controls.pool_edps:ReleaseAllObjects()
  controls.pool_shdps:ReleaseAllObjects()
  controls.pool_line_edps:ReleaseAllObjects()
  controls.pool_line_eos:ReleaseAllObjects()

  local n = Vermilion.TemporalBuffer.count()
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

  local max_edps, span_ms = 0, 0
  do
    local t_first, t_last = 0, 0
    Vermilion.TemporalBuffer.iterate(function(i, s)
      if s.eDPS > max_edps then max_edps = s.eDPS end
      if i == 1 then t_first = s.t end
      t_last = s.t
    end)
    span_ms = t_last - t_first
  end
  if max_edps <= 0 then hide_grid(controls.grid) return end
  draw_grid(controls.grid, canvas, max_edps, span_ms)

  local m, num_cols, col_w, bar_gap = decimate(cw)
  local xs, top_hs = rcr_xs, rcr_top_hs
  local capture = not Vermilion.TemporalBuffer.is_recording()
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x         = left
    local bw        = math_max(1, right - left - bar_gap)
    if capture then hit_col(i, left, right - left, s) end
    local noncrit_h = math_max(0, math_floor(ch_plot * (s.noncrit / max_edps) + 0.5))
    local crit_h    = math_max(0, math_floor(ch_plot * (s.crit    / max_edps) + 0.5))
    xs[i]     = x + bw * 0.5
    top_hs[i] = noncrit_h + crit_h

    if noncrit_h > 0 then
      local tn = controls.pool_edps:AcquireObject()
      tn:ClearAnchors()
      tn:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, x, -TIME_STRIP_H)
      tn:SetWidth(bw)
      tn:SetHeight(noncrit_h)
      tn:SetColor(C_NONCRIT.r, C_NONCRIT.g, C_NONCRIT.b, C_NONCRIT.a)
      tn:SetHidden(false)
    end

    if crit_h > 0 then
      local tc = controls.pool_shdps:AcquireObject()
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
      local lt = controls.pool_line_edps:AcquireObject()
      lt:ClearAnchors()
      lt:SetAnchor(BOTTOMLEFT,  canvas, BOTTOMLEFT, xs[i-1], -(top_hs[i-1] + TIME_STRIP_H))
      lt:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMLEFT, xs[i],   -(top_hs[i]   + TIME_STRIP_H))
      lt:SetColor(C_LINE_EDPS.r, C_LINE_EDPS.g, C_LINE_EDPS.b, C_LINE_EDPS.a)
      lt:SetThickness(LINE_THICKNESS)
      lt:SetHidden(false)
    end
  end
end

function render_current_view()
  if current_view == VIEW_BY_SKILL then
    render_by_skill()
  elseif current_view == VIEW_BY_TYPE then
    render_by_type()
  elseif current_view == VIEW_BY_OUTCOME then
    render_by_outcome()
  else
    render_by_crit()
  end
end

local function refresh_button_colors()
  local recording = Vermilion.TemporalBuffer.is_recording()
  controls.btn_record:SetEnabled(not recording)
  controls.btn_stop:SetEnabled(recording)
  update_hover_gate()
end

local function persist_view()
  local sv = Vermilion.SavedVars
  if sv then sv.graph = sv.graph or {} ; sv.graph.view_idx = current_view end
end

local function set_view(v)
  current_view = v
  controls.view_label:SetText(VIEW_LABELS[v])
  persist_view()
  hover_key = nil
  if Vermilion.TemporalBuffer.count() == 0 then
    controls.no_data:SetHidden(false)
    update_hover_gate()
    return
  end
  controls.no_data:SetHidden(true)
  render_current_view()
  update_hover_gate()
end

local prof_enter = Vermilion.Profiler.enter
local prof_exit  = Vermilion.Profiler.exit

local sample_eos_scratch       = { count = 0 }
local sample_eos_abilities     = { count = 0 }
local sample_dtype_groups      = { count = 0 }
local sample_dtype_abilities   = { count = 0 }

local function on_sample_update()
  prof_enter("graph.sample_tick")
  local now   = GetGameTimeMilliseconds()
  local edps  = Vermilion.Metrics.eDPS(now)
  local shdps = Vermilion.Metrics.ShDPS(now)
  local crit, noncrit = Vermilion.Metrics.crit_split(now)
  Vermilion.Metrics.eos_groups_into(sample_eos_scratch, now)
  Vermilion.Metrics.eos_abilities_into(sample_eos_abilities, now)
  Vermilion.Metrics.dtype_groups_into(sample_dtype_groups, now)
  Vermilion.Metrics.dtype_abilities_into(sample_dtype_abilities, now)
  Vermilion.TemporalBuffer.push(now, edps, shdps, crit, noncrit,
                                sample_eos_scratch, sample_eos_abilities,
                                sample_dtype_groups, sample_dtype_abilities)

  update_header(edps + shdps)
  update_crit(now)

  local elapsed = math_floor((now - recording_start_ms) / 1000)
  controls.status:SetText(string_format("%d:%02d", math_floor(elapsed / 60), elapsed % 60))

  if not controls.window:IsHidden() then
    render_current_view()
  end
  prof_exit("graph.sample_tick")
end

function M.current_view() return current_view end

function M.on_record_click()
  if Vermilion.TemporalBuffer.is_recording() then return end
  log:info("record click")
  Vermilion.TemporalBuffer.clear()
  release_all_pools()
  hide_grid(controls.grid)
  controls.no_data:SetHidden(false)
  Vermilion.TemporalBuffer.start_recording()
  recording_start_ms = GetGameTimeMilliseconds()
  local sv       = Vermilion.SavedVars
  local interval = (sv and sv.temporal and sv.temporal.sample_rate_ms)
                   or Vermilion.Constants.TEMPORAL.SAMPLE_RATE_DEFAULT
  zev.register_update(Vermilion.Constants.TEMPORAL.UPDATE_NAME, interval, on_sample_update)
  refresh_button_colors()
  controls.status:SetText("0:00")
end

function M.on_stop_click()
  if not Vermilion.TemporalBuffer.is_recording() then return end
  log:info("stop click")
  Vermilion.TemporalBuffer.stop_recording()
  zev.unregister_update(Vermilion.Constants.TEMPORAL.UPDATE_NAME)
  refresh_button_colors()
  render_current_view()
end

function M.on_flush_click()
  if Vermilion.TemporalBuffer.is_recording() then
    zev.unregister_update(Vermilion.Constants.TEMPORAL.UPDATE_NAME)
    Vermilion.TemporalBuffer.stop_recording()
  end
  Vermilion.TemporalBuffer.clear()
  release_all_pools()
  hide_grid(controls.grid)
  refresh_button_colors()
  controls.status:SetText("")
  update_header(0)
  if controls.crit then apply_crit(C_CRIT_IDLE, "—") end
  controls.no_data:SetHidden(false)
end

function M.on_close_click()
  Vermilion.Visibility.set("graph", false)
  stop_hover_poll(); hide_hover_ui(); hover_key = nil
  release_all_pools()
end

function M.on_move_stop()
  local sv = Vermilion.SavedVars
  if not sv then return end
  sv.graph = sv.graph or {}
  local x, y = controls.window:GetCenter()
  sv.graph.x = x
  sv.graph.y = y
end

function M.on_resize_stop()
  local sv = Vermilion.SavedVars
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
  if v < VIEW_BY_SKILL then v = VIEW_BY_CRIT end
  release_all_pools()
  set_view(v)
end

function M.next_view()
  local v = current_view + 1
  if v > VIEW_BY_CRIT then v = VIEW_BY_SKILL end
  release_all_pools()
  set_view(v)
end

function M.set_viewport_alpha(a)
  VermilionGraphWindowViewportBg:SetCenterColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, a)
end

function M.set_crit_threshold(pct)
  crit_threshold_pct = pct or 50
end

function M.get_crit_threshold() return crit_threshold_pct end

function M.toggle()
  local now_visible = not Vermilion.Visibility.get("graph")
  log:info("toggle ->", now_visible and "show" or "hide")
  Vermilion.Visibility.set("graph", now_visible)
  if now_visible then
    render_current_view()
    update_hover_gate()
  else
    stop_hover_poll(); hide_hover_ui(); hover_key = nil
    release_all_pools()
  end
end


function M.init()
  controls.window        = VermilionGraphWindow
  controls.title         = VermilionGraphWindowTitleLabel
  controls.btn_record    = VermilionGraphWindowRecordBtn
  controls.btn_stop      = VermilionGraphWindowStopBtn
  controls.btn_flush     = VermilionGraphWindowFlushBtn
  controls.status        = VermilionGraphWindowStatusLabel
  controls.btn_prev_view = VermilionGraphWindowPrevViewBtn
  controls.view_label    = VermilionGraphWindowViewLabel
  controls.btn_next_view = VermilionGraphWindowNextViewBtn
  controls.viewport      = VermilionGraphWindowViewport
  controls.canvas        = VermilionGraphWindowViewportCanvas
  controls.no_data       = VermilionGraphWindowViewportNoDataLabel
  controls.readout       = VermilionGraphWindowReadoutLabel
  controls.dps_icon      = VermilionGraphWindowDpsIcon
  controls.crit          = VermilionGraphWindowCritLabel
  controls.icon          = VermilionGraphWindowCritIcon

  DamageTypeColors = Vermilion.DamageTypeColors

  local sv = Vermilion.SavedVars
  sv.graph = sv.graph or {}
  if sv.graph.view_idx and sv.graph.view_idx >= VIEW_BY_SKILL
     and sv.graph.view_idx <= VIEW_BY_CRIT then
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

  VermilionGraphWindowBg:SetCenterColor(0, 0, 0, 0)
  VermilionGraphWindowChromeTop   :SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VermilionGraphWindowChromeBottom:SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VermilionGraphWindowChromeLeft  :SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VermilionGraphWindowChromeRight :SetColor(C_CHROME.r, C_CHROME.g, C_CHROME.b, C_CHROME.a)
  VermilionGraphWindowBg:SetEdgeColor(1.00, 0.45, 0.40, 1.0)
  local sv_a = (sv.graph and sv.graph.viewport_alpha_pct) or 30
  VermilionGraphWindowViewportBg:SetCenterColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, sv_a / 100)

  controls.grid = create_grid("VermilionGrid", controls.canvas)

  controls.pool_eos_segments = make_fill_pool("VermilionEosSeg")
  controls.pool_eos_line     = make_line_pool("VermilionEosLine")
  controls.pool_edps         = make_fill_pool("VermilionEdpsFill")
  controls.pool_shdps        = make_fill_pool("VermilionShdpsFill")
  controls.pool_line_edps    = make_line_pool("VermilionLineEdps")
  controls.pool_line_eos     = make_line_pool("VermilionLineEos")

  controls.title:SetText(GetString(VERMILION_GRAPH_TITLE))
  controls.title:SetColor(0.75, 0.75, 0.75, 1)
  controls.btn_record:SetText(GetString(VERMILION_GRAPH_RECORD))
  controls.btn_stop:SetText(GetString(VERMILION_GRAPH_STOP))
  controls.btn_flush:SetText(GetString(VERMILION_GRAPH_FLUSH))

  local function tint_btn(btn, r, g, b)
    btn:SetNormalFontColor(r, g, b, 1)
    btn:SetMouseOverFontColor(math.min(1, r + 0.12), math.min(1, g + 0.12), math.min(1, b + 0.12), 1)
    btn:SetPressedFontColor(r * 0.85, g * 0.85, b * 0.85, 1)
  end
  tint_btn(controls.btn_record, 0.95, 0.42, 0.34)
  tint_btn(controls.btn_stop,   0.96, 0.80, 0.34)
  tint_btn(controls.btn_flush,  0.80, 0.30, 0.28)
  controls.status:SetText("")
  controls.status:SetColor(0.65, 0.65, 0.65, 1)
  controls.no_data:SetText(GetString(VERMILION_GRAPH_NO_DATA))
  controls.no_data:SetColor(0.45, 0.45, 0.45, 1)
  controls.no_data:SetHidden(false)
  controls.view_label:SetText(VIEW_LABELS[current_view])
  controls.view_label:SetColor(0.75, 0.75, 0.75, 1)

  controls.readout:SetColor(C_LINE_EOS.r, C_LINE_EOS.g, C_LINE_EOS.b, 0.95)

  crit_threshold_pct = sv.graph.crit_threshold_pct or crit_threshold_pct
  apply_crit(C_CRIT_IDLE, "—")

  build_hover_card()
  card_fader = make_fader(controls.card.root)

  local crosshair = WINDOW_MANAGER:CreateControl("VermilionGraphCrosshair", controls.canvas, CT_TEXTURE)
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

  local hit_layer = WINDOW_MANAGER:CreateControl("VermilionGraphHit", controls.canvas, zc.CT_CONTROL)
  hit_layer:SetAnchorFill(controls.canvas)
  hit_layer:SetMouseEnabled(false)
  hit_layer:SetHidden(true)
  hit_layer:SetHandler("OnMouseEnter", function()
    if hover_allowed() then zev.register_update("VermilionHoverPoll", 50, hover_poll) end
  end)
  hit_layer:SetHandler("OnMouseExit", function()
    stop_hover_poll(); hide_hover_ui()
    if hover_key ~= nil then hover_key = nil; render_current_view() end
  end)
  controls.hit = hit_layer

  update_header(0)
  zev.register_update("VermilionHeaderTick", 1000, header_tick)
  refresh_button_colors()
end
