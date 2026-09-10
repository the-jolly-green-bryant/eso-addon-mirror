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
local ZO_AbbreviateAndLocalizeNumber = ZO_AbbreviateAndLocalizeNumber

local log               = Vermilion.Log.for_module("graph")
local Sound             = Vermilion.Sound
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
local summary_text       = nil
local CHIP               = { H = 0, W = 0 }
local SCR                = { hex = setmetatable({}, { __mode = "k" }) }
local VIEW_TIPS
local last_readout, last_crit_pct, last_elapsed = nil, nil, nil

local VIEW_BY_SKILL   = 1
local VIEW_BY_TYPE    = 2
local VIEW_BY_OUTCOME = 3
local VIEW_BY_CRIT    = 4
local VIEW_BY_CONTRIB = 5
local VIEW_BY_DEBUFFS = 6
local VIEW_LABELS     = { "SKILL", "TYPE", "OUTCOME", "CRIT", "CONTRIB", "DEBUFFS" }
local VIEW_MIN, VIEW_MAX = VIEW_BY_SKILL, VIEW_BY_DEBUFFS

local function view_tips()
  if not VIEW_TIPS then
    VIEW_TIPS = { VERMILION_VIEWTIP_SKILL, VERMILION_VIEWTIP_TYPE, VERMILION_VIEWTIP_OUTCOME, VERMILION_VIEWTIP_CRIT, VERMILION_VIEWTIP_CONTRIB, VERMILION_VIEWTIP_DEBUFFS }
  end
  return VIEW_TIPS
end
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
local CARD_MAX_ROWS  = 7
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
  local idle = eos <= 0 and not Vermilion.TemporalBuffer.is_recording()
  local v = idle and -1 or math_floor(eos + 0.5)
  if v == last_readout then return end
  local was_idle = (last_readout == -1)
  last_readout = v
  if idle then
    controls.readout:SetText(GetString(VERMILION_READOUT_IDLE))
    controls.readout:SetColor(0.52, 0.48, 0.48, 0.85)
  else
    controls.readout:SetText(fmt_readout(eos))
    if was_idle or last_readout == nil then
      controls.readout:SetColor(C_LINE_EOS.r, C_LINE_EOS.g, C_LINE_EOS.b, 0.95)
    end
  end
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
    if last_crit_pct ~= -1 then
      last_crit_pct = -1
      apply_crit(C_CRIT_IDLE, "—")
    end
    return
  end
  local pct = math_floor(crit / tot * 100 + 0.5)
  if pct == last_crit_pct then return end
  last_crit_pct = pct
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
  local ymax = WM:CreateControl(prefix .. "YMax", parent_ctrl, CT_LABEL)
  ymax:SetFont("ZoFontGameSmall")
  ymax:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  ymax:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
  ymax:SetColor(C_GRID_LBL.r, C_GRID_LBL.g, C_GRID_LBL.b, C_GRID_LBL.a)
  ymax:SetDimensions(54, 10)
  ymax:SetHidden(true)
  obj.ymax = ymax

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
  grid.ymax:SetHidden(true)
  grid.time_l:SetHidden(true)
  grid.time_m:SetHidden(true)
  grid.time_r:SetHidden(true)
end

local function draw_grid(grid, canvas, max_val, span_ms, flip, lookback, top_inset)
  local cw = canvas:GetWidth()
  local ch = canvas:GetHeight()
  if cw <= 0 or ch <= 0 then hide_grid(grid) return end

  local has_y    = (max_val > 0)
  local has_time = (span_ms > 0)
  if not has_y and not has_time then hide_grid(grid) return end

  local y_base  = has_time and TIME_STRIP_H or 0
  local ch_plot = math_max(1, ch - y_base - (top_inset or 0))

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
      local spacing = ch_plot / (N_HGRID + 1)
      lbl:SetHidden(spacing < 14 and (spacing * 2 < 14 or i ~= 2))
    end
    if ch_plot >= 96 then
      local ymax_y = flip and (y_base + 2) or (y_base + ch_plot - 12)
      grid.ymax:ClearAnchors()
      grid.ymax:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, -ymax_y)
      grid.ymax:SetText(fmt_val(max_val))
      grid.ymax:SetHidden(false)
    else
      grid.ymax:SetHidden(true)
    end
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
    grid.time_l:SetAnchor(BOTTOMLEFT, canvas, BOTTOMLEFT, 2, 0)
    grid.time_l:SetText(lookback and ("-" .. fmt_secs(span_ms)) or "0s")
    grid.time_l:SetHidden(false)
    grid.time_m:ClearAnchors()
    grid.time_m:SetAnchor(BOTTOM, canvas, BOTTOM, 0, 0)
    grid.time_m:SetText(lookback and ("-" .. fmt_secs(span_ms / 2)) or fmt_secs(span_ms / 2))
    grid.time_m:SetHidden(false)
    grid.time_r:ClearAnchors()
    grid.time_r:SetAnchor(BOTTOMRIGHT, canvas, BOTTOMRIGHT, -2, 0)
    grid.time_r:SetText(lookback and GetString(VERMILION_GRAPH_NOW) or fmt_secs(span_ms))
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
  if controls.pool_c_seg then
    controls.pool_c_seg:ReleaseAllObjects()
    controls.pool_c_rim:ReleaseAllObjects()
    controls.pool_c_icon:ReleaseAllObjects()
    controls.pool_c_lbl:ReleaseAllObjects()
  end
  if controls.pool_d_seg then
    controls.pool_d_seg:ReleaseAllObjects()
    controls.pool_d_rim:ReleaseAllObjects()
    controls.pool_d_icon:ReleaseAllObjects()
    controls.pool_d_lbl:ReleaseAllObjects()
  end
end

local MIN_COL_PX = 6
local dec_cols   = { denom = 1 }

local function grid_geometry(cw, denom, sc, base)
  local cw_p = math_floor(cw * sc)
  local minp = math_floor(MIN_COL_PX * sc + 0.5)
  if minp < 2 then minp = 2 end
  local n = math_floor(cw_p / minp)
  if n < 1 then n = 1 end
  if n > denom then n = denom end
  local P = math_floor(cw_p / n)
  if P < 1 then P = 1 end
  local x0 = cw_p - n * P
  local gap = (P > 3) and 1 or 0
  return n, P, x0, (P - gap) / sc, math_floor(base * sc + 0.5)
end

local function decimate(cw)
  local TB       = Vermilion.TemporalBuffer
  local capacity = TB.capacity()
  local n        = TB.count()
  local denom    = capacity
  if n > 0 and not TB.is_recording() then
    denom = n
  else
    while true do
      local h = math_floor(denom / 2)
      if h >= n and h >= 15 then denom = h else break end
    end
  end
  dec_cols.denom = denom
  local grid = dec_cols.grid
  if grid == nil then grid = (Vermilion.Constants.PIXEL_GRID ~= false) end
  local num_cols
  if grid then
    local sc = api.GetUIGlobalScale and api.GetUIGlobalScale() or 1
    if not sc or sc <= 0 then sc = 1 end
    local base = controls.canvas and controls.canvas:GetLeft() or 0
    local nc, P, x0, bw, base_p = grid_geometry(cw, denom, sc, base)
    num_cols = nc
    dec_cols.pitch  = P
    dec_cols.x0     = x0
    dec_cols.scale  = sc
    dec_cols.base   = base
    dec_cols.base_p = base_p
    dec_cols.bw     = bw
  else
    local max_cols = math_floor(cw / MIN_COL_PX)
    if max_cols < 1 then max_cols = 1 end
    local per = math.ceil(denom / max_cols)
    if per < 1 then per = 1 end
    num_cols = math.ceil(denom / per)
    if num_cols < 1 then num_cols = 1 end
    dec_cols.pitch = nil
    dec_cols.bw    = nil
  end
  local offset   = denom - n
  local m, cur_c = 0, -1
  local col
  for i = 1, n do
    local s   = TB.at(i)
    local c   = math_floor((offset + i - 1) * num_cols / denom)
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
  end
  local col_w   = dec_cols.pitch and (dec_cols.pitch / dec_cols.scale) or (cw / num_cols)
  local bar_gap = (col_w > 3) and 1 or 0
  return m, num_cols, col_w, bar_gap
end

local function dec_rect(c, num_cols, cw)
  local P = dec_cols.pitch
  if P then
    local sc     = dec_cols.scale
    local left_p = dec_cols.base_p + dec_cols.x0 + c * P
    local left   = left_p / sc - dec_cols.base
    return left, left + P / sc
  end
  local left  = math_floor(c       * cw / num_cols + 0.5)
  local right = math_floor((c + 1) * cw / num_cols + 0.5)
  return left, right
end

local function axis_span(span_ms, n)
  if n < 2 or n >= dec_cols.denom then return span_ms end
  return span_ms * dec_cols.denom / (n - 1)
end

local function window_extent(n)
  local TB = Vermilion.TemporalBuffer
  local max_eos, t_first, t_last = 0, 0, 0
  for i = 1, n do
    local s = TB.at(i)
    local eos = s.eDPS + s.ShDPS
    if eos > max_eos then max_eos = eos end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end
  return max_eos, (t_last - t_first)
end

local function edps_extent(n)
  local TB = Vermilion.TemporalBuffer
  local max_edps, t_first, t_last = 0, 0, 0
  for i = 1, n do
    local s = TB.at(i)
    if s.eDPS > max_edps then max_edps = s.eDPS end
    if i == 1 then t_first = s.t end
    t_last = s.t
  end
  return max_edps, (t_last - t_first)
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
  local control = f.control
  if control:GetAlpha() >= 0.99 then
    f.anim:Stop()
    control:SetAlpha(1)
    control:SetHidden(false)
  else
    f.anim:FadeIn(0, FADE_MS)
  end
end
local function fade_out(f)
  if not f or not f.visible then return end
  f.visible = false
  local control = f.control
  if control:GetAlpha() <= 0.01 then
    f.anim:Stop()
    control:SetAlpha(0)
    control:SetHidden(true)
  else
    f.anim:FadeOut(0, FADE_MS, nil, function() if not f.visible then control:SetHidden(true) end end)
  end
end

local function hexc(c)
  local cache = SCR.hex
  local e = cache[c]
  if e and e.r == c.r and e.g == c.g and e.b == c.b then return e.hex end
  local hex = string_format("%02x%02x%02x",
    math_floor(c.r * 255 + 0.5), math_floor(c.g * 255 + 0.5), math_floor(c.b * 255 + 0.5))
  if e then
    e.r, e.g, e.b, e.hex = c.r, c.g, c.b, hex
  else
    cache[c] = { r = c.r, g = c.g, b = c.b, hex = hex }
  end
  return hex
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

  local desc = WM:CreateControl("VermilionHoverCardDesc", root, CT_LABEL)
  desc:SetFont("ZoFontGameSmall")
  desc:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
  desc:SetVerticalAlignment(zc.TEXT_ALIGN_TOP)
  desc:SetMaxLineCount(0)
  desc:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 0.92)
  desc:SetHidden(true)

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

  controls.card = { root = root, swatch = swatch, name = name, stat = stat, time = time, rows = rows, desc = desc }
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

local function desc_height(desc)
  local w = desc:GetWidth()
  if not w or w < 40 then w = CARD_W - 20 end
  local text = desc:GetText() or ""
  local lines = math_floor((#text * 6.4) / w) + 1
  local est = lines * 14 + 2
  local dh = desc:GetTextHeight() or 0
  if dh < est then dh = est end
  if dh < 12 then dh = 12 end
  return dh
end

local function card_guard()
  local f = card_fader
  local root = f.control
  if root:IsHidden() then
    zev.unregister_update("VermilionCardGuard")
    return
  end
  if f.visible then
    if f.report and not api.MouseIsOver(controls.summary.hit) then fade_out(f) end
    return
  end
  if f.anim:IsPlaying() then return end
  log:info("card guard forced a hide: alpha=", root:GetAlpha(), "report=", tostring(f.report))
  root:SetAlpha(0)
  root:SetHidden(true)
  zev.unregister_update("VermilionCardGuard")
end

local function position_card(mx, my)
  local card = controls.card
  local sw, sh = GuiRoot:GetDimensions()
  local w = card.root:GetWidth()
  local h = card.root:GetHeight()
  local x = mx + 16
  local y = my + 18
  if x + w > sw - 4 then x = mx - w - 16 end
  if x < 4 then x = 4 end
  if y + h > sh - 4 then y = my - h - 18 end
  if y < 4 then y = 4 end
  card.root:ClearAnchors()
  card.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
  card_fader.report = false
  fade_in(card_fader)
  zev.register_update("VermilionCardGuard", 100, card_guard)
end

local function size_card(w)
  local card = controls.card
  if card.width == w then return end
  card.width = w
  card.root:SetWidth(w)
  card.time:SetWidth(w - 20)
  for i = 1, CARD_MAX_ROWS do
    card.rows[i].name:SetWidth(w - 102)
  end
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
  size_card(CARD_W)
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

local SHIELD_ICON = "EsoUI/Art/Inventory/inventory_tabIcon_shield_up.dds"

local function show_moment_card(swatch_c, name_text, stat_text, elapsed_ms, mx, my, icon_path)
  local card = controls.card
  if not card then return end
  size_card(CARD_W)
  if icon_path then
    swatch_icon(card, icon_path)
  else
    swatch_solid(card, swatch_c.r, swatch_c.g, swatch_c.b)
  end
  card.name:SetColor(C_CARD_NAME.r, C_CARD_NAME.g, C_CARD_NAME.b, 1.0)
  card.name:SetText(name_text)
  card.stat:SetText(stat_text)
  card.time:SetText("t  " .. fmt_secs(elapsed_ms or 0))
  clear_card_rows(card)
  card.root:SetHeight(CARD_H)
  position_card(mx, my)
end

local function show_rows_card(color, name_text, stat_text, time_text, rows, n_rows, desc_text, mx, my)
  local card = controls.card
  if not card then return end
  size_card(CARD_W)
  swatch_solid(card, color.r, color.g, color.b)
  card.name:SetColor(color.r, color.g, color.b, 1.0)
  card.name:SetText(name_text)
  card.stat:SetText(stat_text)
  card.time:SetText(time_text)
  clear_card_rows(card)
  local n = (n_rows < CARD_MAX_ROWS) and n_rows or CARD_MAX_ROWS
  for i = 1, n do
    local row = card.rows[i]
    row.icon:SetHidden(true)
    row.name:SetText(rows[i][1])
    row.name:SetColor(C_CARD_STAT.r, C_CARD_STAT.g, C_CARD_STAT.b, 1.0)
    row.name:SetHidden(false)
    row.val:SetText(rows[i][2])
    row.val:SetHidden(false)
  end
  local h = CARD_ROWS_Y0 + n * CARD_ROW_H + 4
  if desc_text and desc_text ~= "" then
    local desc = card.desc
    desc:ClearAnchors()
    desc:SetAnchor(TOPLEFT, card.root, TOPLEFT, 12, h + 2)
    desc:SetWidth(CARD_W - 20)
    desc:SetHeight(400)
    desc:SetText(desc_text)
    desc:SetHidden(false)
    local dh = desc_height(desc)
    desc:SetHeight(dh)
    h = h + dh + 10
  end
  card.root:SetHeight(h)
  position_card(mx, my)
end

local SUM = { count = 0 }
local DOM = {}

local function session_summary()
  local TB = Vermilion.TemporalBuffer
  local n = TB.count()
  SUM.count = n
  local sum_eos, peak, peak_t, first_t = 0, 0, 0, 0
  local sum_crit, sum_noncrit, active = 0, 0, 0
  for k in pairs(DOM) do DOM[k] = nil end
  local dom_total, prev_t = 0, nil
  for i = 1, n do
    local s = TB.at(i)
    local eos = s.eDPS + s.ShDPS
    sum_eos = sum_eos + eos
    if i == 1 then first_t = s.t end
    if prev_t then
      local dv = s.eDPS * (s.t - prev_t) / 1000
      local dg = s.dtype_groups
      for g = 1, (dg and dg.count or 0) do
        local e = dg[g]
        local key = e.key or 0
        local v = (e.share or 0) * dv
        DOM[key] = (DOM[key] or 0) + v
        dom_total = dom_total + v
      end
    end
    prev_t = s.t
    if eos > peak then peak = eos; peak_t = s.t end
    sum_crit = sum_crit + (s.crit or 0)
    sum_noncrit = sum_noncrit + (s.noncrit or 0)
    if s.eDPS > 0 then active = active + 1 end
  end
  SUM.avg = (n > 0) and (sum_eos / n) or 0
  SUM.peak = peak
  SUM.peak_t_off = peak_t - first_t
  SUM.crit_pct = (sum_crit + sum_noncrit) > 0 and (sum_crit / (sum_crit + sum_noncrit)) or 0
  SUM.active_pct = (n > 0) and (active / n) or 0
  SUM.dom_type, SUM.dom_pct = nil, 0
  if dom_total > 0 then
    local best, best_v = nil, 0
    for key, v in pairs(DOM) do
      if v > best_v then best, best_v = key, v end
    end
    SUM.dom_type = best
    SUM.dom_pct = best_v / dom_total
  end
  SUM.total_damage, SUM.total_shield, SUM.total_crit, SUM.hits = Vermilion.Metrics.totals()
  local ls = controls.loaded_sum
  if ls then
    SUM.total_damage = ls.total_damage or 0
    SUM.total_shield = ls.total_shield or 0
    SUM.total_crit   = ls.total_crit or 0
    SUM.hits         = ls.hits or 0
  end
  return SUM
end

local C_SUM = {
  AVG    = C_LINE_EOS,
  PEAK   = C_LINE_EDPS,
  CRIT   = C_CRIT,
  VAL    = { r = 0.95, g = 0.90, b = 0.90 },
  ACTIVE = { r = 0.92, g = 0.72, b = 0.60 },
  SHIELD = C_SHDPS,
}

local function build_summary_text()
  local sm = session_summary()
  if sm.count == 0 then return nil end
  local vc = hexc(C_SUM.VAL)
  local parts = {
    string_format("|c%s%s|r |c%s%s|r", hexc(C_SUM.AVG),  GetString(VERMILION_SUMMARY_AVG),  vc, fmt_val(sm.avg)),
    string_format("|c%s%s|r |c%s%s|r", hexc(C_SUM.PEAK), GetString(VERMILION_SUMMARY_PEAK), vc, fmt_val(sm.peak)),
    string_format("|c%s%s|r |c%s%d%%|r", hexc(C_SUM.CRIT), GetString(VERMILION_SUMMARY_CRIT), vc, math_floor(sm.crit_pct * 100 + 0.5)),
    string_format("|c%s%s|r |c%s%d%%|r", hexc(C_SUM.ACTIVE), GetString(VERMILION_SUMMARY_ACTIVE), vc, math_floor(sm.active_pct * 100 + 0.5)),
  }
  local out_total = sm.total_damage + sm.total_shield
  if sm.total_shield > 0 and out_total > 0 then
    parts[#parts + 1] = string_format("|c%s%s|r |c%s%d%%|r",
      hexc(C_SUM.SHIELD), GetString(VERMILION_SUMMARY_SHIELD), vc,
      math_floor(sm.total_shield / out_total * 100 + 0.5))
  end
  if sm.dom_type ~= nil and DTYPE_ICON[sm.dom_type] then
    parts[#parts + 1] = string_format("|t14:14:%s|t |c%s%d%%|r", DTYPE_ICON[sm.dom_type], vc,
      math_floor(sm.dom_pct * 100 + 0.5))
  end
  return parts
end

local function compose_summary(label, parts, avail)
  local lines, widest = 1, 0
  local text = ""
  local line = ""
  for i = 1, #parts do
    local candidate = (line == "") and parts[i] or (line .. "   " .. parts[i])
    label:SetText(candidate)
    local w = label:GetTextWidth()
    if w <= avail or line == "" then
      line = candidate
      if w > widest then widest = w end
    else
      text = (text == "") and line or (text .. "\n" .. line)
      lines = lines + 1
      line = parts[i]
      label:SetText(line)
      local lw = label:GetTextWidth()
      if lw > widest then widest = lw end
    end
  end
  text = (text == "") and line or (text .. "\n" .. line)
  return text, widest, lines
end

local function report_text()
  local card = controls.card
  local function plain(t)
    return (tostring(t or ""):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", ""))
  end
  local lines = { GetString(VERMILION_REPORT_TITLE) }
  if summary_text then lines[#lines + 1] = plain(table.concat(summary_text, "   ")) end
  lines[#lines + 1] = plain(card.stat:GetText())
  for i = 1, CARD_MAX_ROWS do
    local r = card.rows[i]
    if not r.name:IsHidden() then
      lines[#lines + 1] = plain(r.name:GetText()) .. ": " .. plain(r.val:GetText())
    end
  end
  return table.concat(lines, "\n")
end

local function show_report_card()
  local card = controls.card
  local chip = controls.summary
  if not card or not chip then return end
  local sm = session_summary()
  if sm.count == 0 then return end
  size_card(250)
  clear_card_rows(card)
  swatch_solid(card, C_CRIT.r, C_CRIT.g, C_CRIT.b)
  card.name:SetColor(C_CARD_NAME.r, C_CARD_NAME.g, C_CARD_NAME.b, 1.0)
  card.name:SetText(GetString(VERMILION_REPORT_TITLE))
  local total = sm.total_damage + sm.total_shield
  card.stat:SetText(string_format(GetString(VERMILION_REPORT_STAT),
    hexc(C_CRIT), math_floor(sm.crit_pct * 100 + 0.5), fmt_val(total)))
  card.time:SetText(GetString(VERMILION_REPORT_COPY_HINT))

  local rows = card.rows
  local n_rows = 0
  local function add_row(label, value, col)
    if n_rows >= CARD_MAX_ROWS then return end
    n_rows = n_rows + 1
    local r = rows[n_rows]
    r.name:SetText(label)
    r.name:SetColor(col.r, col.g, col.b, 1.0)
    r.name:SetHidden(false)
    r.val:SetText(value)
    r.val:SetHidden(false)
  end
  add_row(GetString(VERMILION_REPORT_DAMAGE), fmt_val(sm.total_damage), C_LINE_EDPS)
  add_row(GetString(VERMILION_REPORT_SHIELDED),
    (total > 0) and string_format("%s  ·  %d%%", fmt_val(sm.total_shield), math_floor(sm.total_shield / total * 100 + 0.5)) or "-",
    C_SHDPS)
  add_row(GetString(VERMILION_REPORT_HITS),
    (sm.hits > 0) and string_format(GetString(VERMILION_REPORT_HITS_AVG), sm.hits, fmt_val(sm.total_damage / sm.hits)) or "0",
    C_CARD_STAT)
  if sm.peak > 0 then
    add_row(GetString(VERMILION_REPORT_PEAK), fmt_secs(sm.peak_t_off), C_CARD_STAT)
  end
  add_row(GetString(VERMILION_REPORT_ACTIVE), string_format("%d%%", math_floor(sm.active_pct * 100 + 0.5)), C_SUM.ACTIVE)
  if sm.dom_type ~= nil and DamageTypeColors then
    local dc = DamageTypeColors.lookup(sm.dom_type)
    add_row(GetString(VERMILION_REPORT_MAIN_TYPE),
      string_format("%s  ·  %d%%", DamageTypeColors.name(sm.dom_type) or "?", math_floor(sm.dom_pct * 100 + 0.5)), dc or C_CARD_STAT)
  end

  card.root:SetHeight(CARD_ROWS_Y0 + n_rows * CARD_ROW_H + 6)
  position_card(chip.bg:GetLeft() - 16, chip.bg:GetBottom() - 14)
  card_fader.report = true
end

local function update_summary_chip()
  local chip = controls.summary
  if not chip then return end
  local show = summary_text ~= nil
            and not Vermilion.TemporalBuffer.is_recording()
            and Vermilion.TemporalBuffer.count() > 0
  if show then
    local avail = controls.window:GetWidth() - 36 - 34
    local text, w, lines = compose_summary(chip.label, summary_text, avail)
    chip.label:SetText(text)
    chip.label:SetWidth(w)
    chip.label:SetHeight(18 * lines + 2)
    chip.bg:SetWidth(w + 34)
    chip.bg:SetHeight(18 * lines + 2)
    chip.bg:SetHidden(false)
    chip.label:SetHidden(false)
    chip.help:SetHidden(false)
    chip.hit:SetHidden(false)
    CHIP.H = 18 * lines + 2 + 8
    CHIP.W = w + 34
  else
    chip.bg:SetHidden(true)
    chip.label:SetHidden(true)
    chip.help:SetHidden(true)
    chip.hit:SetHidden(true)
    CHIP.H = 0
  end
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
  if current_view == VIEW_BY_CONTRIB then
    Vermilion.ContribView.hover(mx, my)
    return
  end
  if current_view == VIEW_BY_DEBUFFS then
    Vermilion.DebuffsView.hover(mx, my)
    return
  end
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

local light = { active = false, hover = false }

function light.alpha_pct()
  local sv = Vermilion.SavedVars
  return (sv and sv.settings and sv.settings.light_alpha_pct) or 40
end

function light.enabled()
  local sv = Vermilion.SavedVars
  return (sv and sv.settings and sv.settings.light_mode) == true
end

function light.chrome(hidden)
  VermilionGraphWindowBg:SetHidden(hidden)
  VermilionGraphWindowChromeTop:SetHidden(hidden)
  VermilionGraphWindowChromeBottom:SetHidden(hidden)
  VermilionGraphWindowChromeLeft:SetHidden(hidden)
  VermilionGraphWindowChromeRight:SetHidden(hidden)
  VermilionGraphWindowBrandLogo:SetHidden(hidden)
  VermilionGraphWindowSettingsBtn:SetHidden(hidden)
  VermilionGraphWindowCloseBtn:SetHidden(hidden)
  controls.title:SetHidden(hidden)
  controls.btn_record:SetHidden(hidden)
  controls.btn_flush:SetHidden(hidden)
  controls.btn_lib:SetHidden(hidden)
  controls.btn_save:SetHidden(hidden)
  controls.dps_icon:SetHidden(hidden)
  controls.readout:SetHidden(hidden)
  controls.crit:SetHidden(hidden)
  if controls.icon then controls.icon:SetHidden(hidden) end
end

function light.minimal(hidden)
  controls.btn_stop:SetHidden(hidden)
  if controls.tabs then controls.tabs.strip:SetHidden(hidden) end
  controls.status:SetHidden(hidden)
end

function light.apply_hover(hover)
  light.hover = hover
  if hover then
    controls.window:SetAlpha(1)
    light.minimal(false)
  else
    controls.window:SetAlpha(light.alpha_pct() / 100)
    light.minimal(true)
  end
end

function light.poll()
  local mx, my = GetUIMousePosition()
  local w = controls.window
  local inside = mx >= w:GetLeft() and mx <= w:GetRight()
             and my >= w:GetTop() and my <= w:GetBottom()
  if inside ~= light.hover then light.apply_hover(inside) end
end

function light.enter()
  if light.active then return end
  light.active = true
  Vermilion.Diagnostics.bump("graph.light.enter")
  light.chrome(true)
  light.apply_hover(false)
  zev.register_update("VermilionLightPoll", 150, light.poll)
end

function light.exit()
  if not light.active then return end
  light.active = false
  zev.unregister_update("VermilionLightPoll")
  controls.window:SetAlpha(1)
  light.chrome(false)
  light.minimal(false)
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
  local ch_plot = math_max(4, ch - TIME_STRIP_H - CHIP.H)

  local max_eos, span_ms = window_extent(n)
  if max_eos <= 0 then hide_grid(controls.grid) return end
  local m, num_cols, col_w, bar_gap = decimate(cw)
  draw_grid(controls.grid, canvas, max_eos, axis_span(span_ms, n), nil, true, CHIP.H)
  local xs, eos_hs = rsk_xs, rsk_eos_hs
  local bwu = dec_cols.bw or math_max(1, math_floor(col_w) - bar_gap)
  local capture = not Vermilion.TemporalBuffer.is_recording()
  local hk = hover_key
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x   = left
    local bw  = bwu
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
  local ch_plot = math_max(4, ch - TIME_STRIP_H - CHIP.H)

  local max_edps, span_ms = edps_extent(n)
  if max_edps <= 0 then hide_grid(controls.grid) return end
  local m, num_cols, col_w, bar_gap = decimate(cw)
  draw_grid(controls.grid, canvas, max_edps, axis_span(span_ms, n), nil, true, CHIP.H)
  local xs, edps_hs = rty_xs, rty_edps_hs
  local bwu = dec_cols.bw or math_max(1, math_floor(col_w) - bar_gap)
  local capture = not Vermilion.TemporalBuffer.is_recording()
  local hk = hover_key
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x    = left
    local bw   = bwu
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
  local ch_plot = math_max(4, ch - TIME_STRIP_H - CHIP.H)

  local max_eos, span_ms = window_extent(n)
  if max_eos <= 0 then hide_grid(controls.grid) return end
  local m, num_cols, col_w, bar_gap = decimate(cw)
  draw_grid(controls.grid, canvas, max_eos, axis_span(span_ms, n), nil, true, CHIP.H)
  local xs, edps_hs, eos_hs = rout_xs, rout_edps_hs, rout_eos_hs
  local bwu = dec_cols.bw or math_max(1, math_floor(col_w) - bar_gap)
  local capture = not Vermilion.TemporalBuffer.is_recording()
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x       = left
    local bw      = bwu
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
  local ch_plot = math_max(4, ch - TIME_STRIP_H - CHIP.H)

  local max_edps, span_ms = edps_extent(n)
  if max_edps <= 0 then hide_grid(controls.grid) return end
  local m, num_cols, col_w, bar_gap = decimate(cw)
  draw_grid(controls.grid, canvas, max_edps, axis_span(span_ms, n), nil, true, CHIP.H)
  local xs, top_hs = rcr_xs, rcr_top_hs
  local bwu = dec_cols.bw or math_max(1, math_floor(col_w) - bar_gap)
  local capture = not Vermilion.TemporalBuffer.is_recording()
  if capture then hit_begin(m) end

  for i = 1, m do
    local s = dec_cols[i]
    local left, right = dec_rect(s.c, num_cols, cw)
    local x         = left
    local bw        = bwu
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
  if current_view == VIEW_BY_CONTRIB then
    release_all_pools()
    Vermilion.ContribView.render()
    return
  end
  if current_view == VIEW_BY_DEBUFFS then
    release_all_pools()
    Vermilion.DebuffsView.render()
    return
  end
  if controls.pool_c_seg then
    controls.pool_c_seg:ReleaseAllObjects()
    controls.pool_c_rim:ReleaseAllObjects()
    controls.pool_c_icon:ReleaseAllObjects()
    controls.pool_c_lbl:ReleaseAllObjects()
  end
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

function M.save_available()
  local TB = Vermilion.TemporalBuffer
  local n = TB.count()
  if TB.is_recording() or n == 0 or controls.save_locked then return false end
  return not (controls.saved_start == recording_start_ms and controls.saved_count == n)
end

function M.pulse(btn, name)
  if not btn then return end
  controls.pulse_t = controls.pulse_t or {}
  controls.pulse_t[name] = 0
  zev.register_update(name, 16, function()
    local t = controls.pulse_t[name] + 16
    controls.pulse_t[name] = t
    if t >= 720 then
      btn:SetAlpha(1)
      zev.unregister_update(name)
      return
    end
    btn:SetAlpha(0.35 + 0.65 * math.abs(math.cos((t % 360) / 360 * math.pi)))
  end)
end

function M.pulse_lib() M.pulse(controls.btn_lib, "VermilionLibPulse") end

function M.on_shown()
  if not controls.window or light.active then return end
  local f = controls.win_fader
  if not f then return end
  f.visible = false
  controls.window:SetAlpha(0)
  fade_in(f)
end

local function refresh_button_colors()
  local recording = Vermilion.TemporalBuffer.is_recording()
  controls.btn_record:SetEnabled(not recording)
  controls.btn_stop:SetEnabled(recording)
  if controls.btn_save then controls.btn_save:SetEnabled(M.save_available()) end
  update_hover_gate()
  update_summary_chip()
end

local function persist_view()
  local sv = Vermilion.SavedVars
  if sv then sv.graph = sv.graph or {} ; sv.graph.view_idx = current_view end
end

local function style_tabs()
  local tabs = controls.tabs
  if not tabs then return end
  for v = 1, #VIEW_LABELS do
    local t = tabs[v]
    local on = (v == current_view)
    t.label:SetColor(on and 0.98 or 0.66, on and 0.90 or 0.58, on and 0.88 or 0.56, 1)
    t.line:SetHidden(not on)
    t.line:SetColor(C_LINE_EDPS.r, C_LINE_EDPS.g, C_LINE_EDPS.b, 0.9)
    t.band:SetHidden(not on)
  end
end

local function layout_tabs()
  local tabs = controls.tabs
  if not tabs then return end
  local strip = tabs.strip
  local n = #VIEW_LABELS
  local w = strip:GetWidth()
  local tw = math_floor(w / n)
  for v = 1, n do
    local t = tabs[v]
    local x = (v - 1) * tw
    t.hit:ClearAnchors()
    t.hit:SetAnchor(TOPLEFT, strip, TOPLEFT, x, 0)
    t.hit:SetDimensions(tw, 20)
    t.label:ClearAnchors()
    t.label:SetAnchor(TOPLEFT, strip, TOPLEFT, x, 0)
    t.label:SetDimensions(tw, 18)
    t.line:ClearAnchors()
    t.line:SetAnchor(TOPLEFT, strip, TOPLEFT, x + 4, 18)
    t.line:SetDimensions(tw - 8, 2)
    t.band:ClearAnchors()
    t.band:SetAnchor(TOPLEFT, strip, TOPLEFT, x + 2, 1)
    t.band:SetDimensions(tw - 4, 17)
  end
end

local function set_view(v)
  current_view = v
  controls.view_label:SetText(VIEW_LABELS[v])
  style_tabs()
  persist_view()
  hover_key = nil
  Vermilion.ContribView.reset_scroll()
  Vermilion.DebuffsView.reset_scroll()
  Vermilion.DebuffsView.clear_hover()
  controls.no_data:SetText(GetString((v == VIEW_BY_DEBUFFS) and VERMILION_GRAPH_NO_DEBUFFS or VERMILION_GRAPH_NO_DATA))
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
  Vermilion.DebuffTracker.expire_stale(now)

  update_header(edps + shdps)
  update_crit(now)

  local elapsed = math_floor((now - recording_start_ms) / 1000)
  if elapsed ~= last_elapsed then
    last_elapsed = elapsed
    local prefix = Vermilion.AutoRecord.is_auto_session() and "AUTO " or ""
    controls.status:SetText(string_format("%s%d:%02d", prefix, math_floor(elapsed / 60), elapsed % 60))
  end

  if not controls.window:IsHidden() then
    render_current_view()
  end
  prof_exit("graph.sample_tick")
end

function M.current_view() return current_view end

function M.on_record_click()
  if Vermilion.TemporalBuffer.is_recording() then return end
  log:info("record click")
  Sound.play("record")
  if not Vermilion.AutoRecord.is_auto_active() then
    Vermilion.AutoRecord.notify_manual_record()
  end
  Vermilion.SessionStore.finish_autosave()
  controls.save_locked = false
  controls.loaded_sum = nil
  controls.saved_start, controls.saved_count = nil, nil
  Vermilion.TemporalBuffer.clear()
  Vermilion.Metrics.session_mark()
  release_all_pools()
  hide_grid(controls.grid)
  controls.no_data:SetHidden(false)
  Vermilion.TemporalBuffer.start_recording()
  Vermilion.SessionStore.on_session_start()
  Vermilion.Trace.on_record(Vermilion.SavedVars)
  recording_start_ms = GetGameTimeMilliseconds()
  Vermilion.DebuffTracker.start_session(recording_start_ms)
  local sv       = Vermilion.SavedVars
  local interval = (sv and sv.temporal and sv.temporal.sample_rate_ms)
                   or Vermilion.Constants.TEMPORAL.SAMPLE_RATE_DEFAULT
  zev.register_update(Vermilion.Constants.TEMPORAL.UPDATE_NAME, interval, on_sample_update)
  summary_text = nil
  last_elapsed = nil
  refresh_button_colors()
  controls.status:SetText("0:00")
  controls.status:SetColor(0.65, 0.65, 0.65, 1)
  if light.enabled() then light.enter() end
end

function M.on_stop_click()
  if not Vermilion.TemporalBuffer.is_recording() then return end
  log:info("stop click")
  Sound.play("stop")
  light.exit()
  Vermilion.AutoRecord.notify_manual_stop()
  Vermilion.TemporalBuffer.stop_recording()
  Vermilion.Trace.on_stop(Vermilion.SavedVars)
  zev.unregister_update(Vermilion.Constants.TEMPORAL.UPDATE_NAME)
  Vermilion.DebuffTracker.finalize(GetGameTimeMilliseconds())
  Vermilion.SessionStore.on_session_stop()
  summary_text = build_summary_text()
  if not Vermilion.SessionStore.autosave_pending() then
    controls.status:SetText(GetString(VERMILION_SAVE_STATUS_UNSAVED))
    controls.status:SetColor(0.93, 0.72, 0.36, 1)
    M.pulse(controls.btn_save, "VermilionSavePulse")
  end
  refresh_button_colors()
  render_current_view()
end

function M.on_flush_click()
  Sound.play("discard")
  Vermilion.SessionStore.finish_autosave()
  light.exit()
  summary_text = nil
  last_readout, last_crit_pct, last_elapsed = nil, nil, nil
  if Vermilion.TemporalBuffer.is_recording() then
    zev.unregister_update(Vermilion.Constants.TEMPORAL.UPDATE_NAME)
    Vermilion.TemporalBuffer.stop_recording()
  end
  Vermilion.TemporalBuffer.clear()
  Vermilion.DebuffTracker.reset()
  controls.save_locked = false
  controls.loaded_sum = nil
  controls.saved_start, controls.saved_count = nil, nil
  release_all_pools()
  hide_grid(controls.grid)
  refresh_button_colors()
  controls.status:SetText("")
  controls.status:SetColor(0.65, 0.65, 0.65, 1)
  update_header(0)
  if controls.crit then apply_crit(C_CRIT_IDLE, "—") end
  controls.no_data:SetHidden(false)
end

function M.on_close_click()
  Sound.play("close")
  light.exit()
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
  layout_tabs()
  if not controls.window:IsHidden() then
    update_summary_chip()
    render_current_view()
  end
end

function M.card_state()
  local f = card_fader
  if not f then return "no card" end
  local root = f.control
  return string_format("hidden=%s alpha=%.2f flag=%s report=%s playing=%s over_chip=%s",
    tostring(root:IsHidden()), root:GetAlpha(), tostring(f.visible), tostring(f.report),
    tostring(f.anim:IsPlaying()), tostring(controls.summary ~= nil and api.MouseIsOver(controls.summary.hit)))
end

function M.on_title_double_click()
  local _, my = GetUIMousePosition()
  if my - controls.window:GetTop() > 30 then return end
  local C = Vermilion.Constants
  local w, h = controls.window:GetDimensions()
  if w == C.GRAPH_DEFAULT_W and h == C.GRAPH_DEFAULT_H then return end
  Sound.play("click")
  controls.window:SetDimensions(C.GRAPH_DEFAULT_W, C.GRAPH_DEFAULT_H)
  M.on_resize_stop()
end

function M.on_move_start()
  stop_hover_poll()
  hide_hover_ui()
  if hover_key ~= nil then hover_key = nil; render_current_view() end
end

function M.pixel_grid()
  local g = dec_cols.grid
  if g == nil then g = (Vermilion.Constants.PIXEL_GRID ~= false) end
  return g
end

function M.set_pixel_grid(on)
  dec_cols.grid = on and true or false
  M.on_resize_stop()
end

function M.column_geometry(cw, denom, sc, base)
  return grid_geometry(cw, denom, sc or 1, base or 0)
end

function M.step_view(dir)
  if not controls.window or controls.window:IsHidden() then return false end
  if dir and dir < 0 then M.prev_view() else M.next_view() end
  return true
end

function M.set_light_enabled(on)
  if not on then
    light.exit()
  elseif Vermilion.TemporalBuffer.is_recording() and not controls.window:IsHidden() then
    light.enter()
  end
end

function M.set_light_alpha(a)
  if light.active and not light.hover then
    controls.window:SetAlpha(a)
  end
end

function M.is_light_active() return light.active end

function M.prev_view()
  local v = current_view - 1
  if v < VIEW_BY_SKILL then v = VIEW_BY_DEBUFFS end
  Sound.play("page")
  release_all_pools()
  set_view(v)
end

function M.next_view()
  local v = current_view + 1
  if v > VIEW_BY_DEBUFFS then v = VIEW_BY_SKILL end
  Sound.play("page")
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
  Sound.play(now_visible and "open" or "close")
  if now_visible then
    render_current_view()
    update_hover_gate()
    if Vermilion.TemporalBuffer.is_recording() and light.enabled() then light.enter() end
  else
    light.exit()
    stop_hover_poll(); hide_hover_ui(); hover_key = nil
    release_all_pools()
  end
end


function M.on_save_click()
  local TB = Vermilion.TemporalBuffer
  if TB.is_recording() then
    Sound.play("deny")
    d("[Vm] " .. GetString(VERMILION_SAVE_BUSY))
    return false
  end
  if TB.count() == 0 then
    Sound.play("deny")
    d("[Vm] " .. GetString(VERMILION_SAVE_NOTHING))
    return false
  end
  Vermilion.SessionStore.finish_autosave()
  if not M.save_available() then
    Sound.play("deny")
    d("[Vm] " .. GetString(VERMILION_SAVE_ALREADY))
    return false
  end
  log:info("manual save")
  Sound.play("confirm")
  Vermilion.SessionStore.save_now()
  Vermilion.Diagnostics.bump("library.manual_save")
  return true
end

function M.toggle_record()
  if Vermilion.TemporalBuffer.is_recording() then
    M.on_stop_click()
  else
    M.on_record_click()
  end
end

local function corrupt(reason)
  d("[Vm] " .. string_format(GetString(VERMILION_LIB_CORRUPT), tostring(reason)))
  return false
end

local function attach_shares(series, sess, vsf)
  local gkeys = sess.gkeys or {}
  local SC = Vermilion.SkillColors
  local DTC = Vermilion.DamageTypeColors
  local shares = sess.streams.shares and sess.desc.shares and vsf.unpack(sess.streams.shares, sess.desc.shares)
  for i = 1, (shares and #shares or 0) do
    local r = shares[i]
    local sample = series[r.si]
    if sample then
      local key = gkeys[r.key + 1]
      local field = (r.ch == 0) and "eg" or "dg"
      local tbl = sample[field]
      if not tbl then tbl = { count = 0 }; sample[field] = tbl end
      local c = (r.ch == 0) and SC.group_color(key or "other") or DTC.lookup(key or 0)
      tbl.count = tbl.count + 1
      tbl[tbl.count] = { r = c.r, g = c.g, b = c.b, a = c.a, share = r.sh, key = (r.ch == 0) and (key or "other") or (key or 0) }
    end
  end
  local abilities = sess.streams.abilities and sess.desc.abilities and vsf.unpack(sess.streams.abilities, sess.desc.abilities)
  for i = 1, (abilities and #abilities or 0) do
    local r = abilities[i]
    local sample = series[r.si]
    if sample then
      local field = (r.ch == 0) and "ea" or "da"
      local tbl = sample[field]
      if not tbl then tbl = { count = 0 }; sample[field] = tbl end
      local key = (r.key ~= nil) and gkeys[r.key + 1] or nil
      local c
      if r.ch == 0 then
        key = key or SC.group_of(r.id)
        c = SC.group_color(key)
      else
        key = key or 0
        c = DTC.lookup(key)
      end
      tbl.count = tbl.count + 1
      tbl[tbl.count] = { id = r.id, share = r.sh, key = key, r = c.r, g = c.g, b = c.b, a = c.a }
    end
  end
end

function M.load_session(sess)
  if Vermilion.TemporalBuffer.is_recording() then
    d("[Vm] " .. GetString(VERMILION_LIB_BUSY))
    return false
  end
  Vermilion.SessionStore.finish_autosave()
  if not (sess and sess.streams and sess.desc and sess.head) then
    return corrupt("missing structure")
  end
  local vsf = Vermilion.lib.vsf
  local series, err = vsf.unpack(sess.streams.series, sess.desc.series)
  if not series then return corrupt(err) end
  attach_shares(series, sess, vsf)

  release_all_pools()
  hide_grid(controls.grid)
  Vermilion.TemporalBuffer.load_session(series)
  local steps = (sess.streams.steps and sess.desc.steps) and vsf.unpack(sess.streams.steps, sess.desc.steps) or nil
  Vermilion.DebuffTracker.load_session(sess.debuffs or {}, steps or {}, 0, sess.head.dur_ms or 0)
  hover_key = nil
  summary_text = build_summary_text()
  controls.status:SetText(string_format(GetString(VERMILION_LIB_LOADED), sess.head.zone or "?"))
  controls.status:SetColor(0.65, 0.65, 0.65, 1)
  controls.save_locked = true
  controls.loaded_sum = sess.head.sum
  controls.no_data:SetHidden(true)
  Vermilion.Visibility.set("graph", true)
  refresh_button_colors()
  render_current_view()
  Vermilion.Diagnostics.bump("library.session_loaded")
  return true
end

local function wire_save_hooks()
  local SS = Vermilion.SessionStore
  controls.saving_frames = { "SAVING", "SAVING ·", "SAVING · ·", "SAVING · · ·" }
  SS.on_save_begin = function()
    controls.saving_t = 0
    controls.status:SetText(controls.saving_frames[1])
    controls.status:SetColor(0.65, 0.65, 0.65, 1)
    if controls.btn_save then controls.btn_save:SetAlpha(0.45) end
    zev.register_update("VermilionSavingSpin", 150, function()
      local t = controls.saving_t + 1
      controls.saving_t = t
      controls.status:SetText(controls.saving_frames[(t % 4) + 1])
    end)
  end
  SS.on_save_end = function(stored)
    zev.unregister_update("VermilionSavingSpin")
    if controls.btn_save then controls.btn_save:SetAlpha(1) end
    if not stored then
      controls.status:SetText(GetString(VERMILION_SAVE_STATUS_UNSAVED))
      controls.status:SetColor(0.93, 0.72, 0.36, 1)
    end
  end
  SS.on_saved = function(session)
    d("[Vm] " .. string_format(GetString(VERMILION_LIB_SAVED),
      session.head.zone or "?", fmt_secs(session.head.dur_ms or 0)))
    controls.saved_start, controls.saved_count = recording_start_ms, Vermilion.TemporalBuffer.count()
    controls.status:SetText(string_format(GetString(VERMILION_SAVE_STATUS), session.head.zone or "?"))
    controls.status:SetColor(0.65, 0.65, 0.65, 1)
    if session.head.manual then Sound.play("save") end
    refresh_button_colors()
    M.pulse_lib()
    if Vermilion.Library and Vermilion.Library.on_session_saved then
      Vermilion.Library.on_session_saved(session.head.manual == true)
    end
  end
end

function M.init()
  controls.window        = VermilionGraphWindow
  controls.title         = VermilionGraphWindowTitleLabel
  controls.btn_record    = VermilionGraphWindowRecordBtn
  controls.btn_stop      = VermilionGraphWindowStopBtn
  controls.btn_flush     = VermilionGraphWindowFlushBtn
  controls.btn_lib       = VermilionGraphWindowLibBtn
  controls.btn_save      = VermilionGraphWindowSaveBtn
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
     and sv.graph.view_idx <= VIEW_BY_DEBUFFS then
    current_view = sv.graph.view_idx
  end
  if sv.graph.x then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(CENTER, GuiRoot, TOPLEFT, sv.graph.x, sv.graph.y)
  end
  if sv.graph.w then
    controls.window:SetDimensions(sv.graph.w, sv.graph.h)
  end
  controls.window:SetDimensionConstraints(400, 240, 1000, 700)

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
  controls.pool_c_seg = Pool.new("VermilionContribSeg", controls.canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(2)
    end,
    function(c)
      c:SetHidden(true)
      c:SetDrawLevel(2)
    end)
  controls.pool_c_rim = Pool.new("VermilionContribRim", controls.canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(3)
    end, fill_reset)
  controls.pool_c_icon = Pool.new("VermilionContribIcon", controls.canvas, CT_TEXTURE,
    function(c) c:SetPixelRoundingEnabled(false) end,
    function(c) c:SetHidden(true) end)
  controls.pool_c_lbl = Pool.new("VermilionContribLbl", controls.canvas, CT_LABEL,
    function(c)
      c:SetFont("ZoFontGameSmall")
      c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
      c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end,
    function(c) c:SetHidden(true) end)
  controls.pool_d_seg = Pool.new("VermilionDebuffSeg", controls.canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(2)
    end,
    function(c)
      c:SetHidden(true)
      c:SetDrawLevel(2)
    end)
  controls.pool_d_rim = Pool.new("VermilionDebuffRim", controls.canvas, CT_TEXTURE,
    function(c)
      fill_factory(c)
      c:SetDrawLevel(3)
    end, fill_reset)
  controls.pool_d_icon = Pool.new("VermilionDebuffIcon", controls.canvas, CT_TEXTURE,
    function(c) c:SetPixelRoundingEnabled(false) end,
    function(c) c:SetHidden(true) end)
  controls.pool_d_lbl = Pool.new("VermilionDebuffLbl", controls.canvas, CT_LABEL,
    function(c)
      c:SetFont("ZoFontGameSmall")
      c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
      c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end,
    function(c) c:SetHidden(true) end)

  controls.title:SetText(GetString(VERMILION_GRAPH_TITLE))
  controls.title:SetColor(0.75, 0.75, 0.75, 1)
  controls.btn_record:SetText("|t10:10:Vermilion/assets/rec.dds|t " .. GetString(VERMILION_GRAPH_RECORD))
  controls.btn_stop:SetText("|t9:9:Vermilion/assets/stop.dds|t " .. GetString(VERMILION_GRAPH_STOP))
  controls.btn_flush:SetText(GetString(VERMILION_GRAPH_FLUSH))

  local function tint_btn(btn, r, g, b)
    btn:SetNormalFontColor(r, g, b, 1)
    btn:SetMouseOverFontColor(math.min(1, r + 0.12), math.min(1, g + 0.12), math.min(1, b + 0.12), 1)
    btn:SetPressedFontColor(r * 0.85, g * 0.85, b * 0.85, 1)
  end
  tint_btn(controls.btn_record, 0.95, 0.42, 0.34)
  tint_btn(controls.btn_stop,   0.96, 0.80, 0.34)
  tint_btn(controls.btn_flush,  0.80, 0.30, 0.28)
  zui.tooltip(controls.btn_record,    VERMILION_TIP_RECORD)
  zui.tooltip(controls.btn_stop,      VERMILION_TIP_STOP)
  zui.tooltip(controls.btn_flush,     VERMILION_TIP_FLUSH)
  zui.tooltip(controls.btn_lib,       VERMILION_TIP_LIB)
  zui.tooltip(controls.btn_save,      VERMILION_TIP_SAVE)
  zui.tooltip(controls.btn_prev_view, VERMILION_TIP_PREV_VIEW)
  zui.tooltip(controls.btn_next_view, VERMILION_TIP_NEXT_VIEW)
  zui.tooltip(VermilionGraphWindowSettingsBtn, VERMILION_TIP_SETTINGS)
  zui.tooltip(VermilionGraphWindowCloseBtn, VERMILION_TIP_CLOSE)
  wire_save_hooks()

  local strip = VermilionGraphWindowTabs
  controls.tabs = { strip = strip }
  for v = 1, #VIEW_LABELS do
    local hit_c = WINDOW_MANAGER:CreateControl("VermilionGraphTab" .. v, strip, zc.CT_CONTROL)
    hit_c:SetMouseEnabled(true)
    hit_c:SetDrawLevel(3)
    local label = WINDOW_MANAGER:CreateControl("VermilionGraphTab" .. v .. "Label", strip, CT_LABEL)
    label:SetFont("ZoFontGameSmall")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetText(VIEW_LABELS[v])
    label:SetDrawLevel(2)
    local line = WINDOW_MANAGER:CreateControl("VermilionGraphTab" .. v .. "Line", strip, CT_TEXTURE)
    line:SetTexture(FILL_TEXTURE)
    line:SetTextureCoords(0, 1, 0, 0.05)
    line:SetDrawLevel(2)
    local band = WINDOW_MANAGER:CreateControl("VermilionGraphTab" .. v .. "Band", strip, CT_TEXTURE)
    band:SetTexture(FILL_TEXTURE)
    band:SetTextureCoords(0, 1, 0, 0.05)
    band:SetDrawLevel(1)
    band:SetColor(C_VIEWPORT.r, C_VIEWPORT.g, C_VIEWPORT.b, 0.10)
    local view = v
    hit_c:SetHandler("OnMouseUp", function(_, _, upInside)
      if upInside == false or view == current_view then return end
      Sound.play("page")
      release_all_pools()
      set_view(view)
    end)
    hit_c:SetHandler("OnMouseEnter", function(self)
      label:SetColor(1, 1, 1, 1)
      ZO_Tooltips_ShowTextTooltip(self, BOTTOM, GetString(view_tips()[view]))
    end)
    hit_c:SetHandler("OnMouseExit", function()
      style_tabs()
      ZO_Tooltips_HideTextTooltip()
    end)
    controls.tabs[v] = { hit = hit_c, label = label, line = line, band = band }
  end
  layout_tabs()
  style_tabs()

  local sum_bg = WINDOW_MANAGER:CreateControl("VermilionGraphSummaryBg", controls.window, CT_TEXTURE)
  sum_bg:SetTexture(FILL_TEXTURE)
  sum_bg:SetTextureCoords(0, 1, 0, 0.05)
  sum_bg:SetColor(0.10, 0.04, 0.04, 0.55)
  sum_bg:SetAnchor(TOPRIGHT, controls.viewport, TOPRIGHT, -4, 4)
  sum_bg:SetHeight(20)
  sum_bg:SetDrawLevel(11)
  sum_bg:SetHidden(true)

  local sum_label = WINDOW_MANAGER:CreateControl("VermilionGraphSummaryLabel", controls.window, CT_LABEL)
  sum_label:SetFont("ZoFontGameSmall")
  sum_label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  sum_label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
  sum_label:SetAnchor(TOPRIGHT, controls.viewport, TOPRIGHT, -30, 4)
  sum_label:SetHeight(20)
  sum_label:SetDrawLevel(12)
  sum_label:SetHidden(true)

  local sum_help = WINDOW_MANAGER:CreateControl("VermilionGraphSummaryHelp", controls.window, CT_TEXTURE)
  sum_help:SetTexture("EsoUI/Art/Miscellaneous/help_icon.dds")
  sum_help:SetDimensions(16, 16)
  sum_help:SetAnchor(TOPRIGHT, controls.viewport, TOPRIGHT, -8, 6)
  sum_help:SetColor(0.95, 0.78, 0.74, 0.9)
  sum_help:SetDrawLevel(12)
  sum_help:SetHidden(true)

  local sum_hit = WINDOW_MANAGER:CreateControl("VermilionGraphSummaryHit", controls.window, zc.CT_CONTROL)
  sum_hit:SetAnchorFill(sum_bg)
  sum_hit:SetMouseEnabled(true)
  sum_hit:SetDrawLevel(13)
  sum_hit:SetHidden(true)
  sum_hit:SetHandler("OnMouseEnter", function() show_report_card() end)
  sum_hit:SetHandler("OnMouseExit", function() fade_out(card_fader) end)
  sum_hit:SetHandler("OnMouseUp", function(_, _, upInside)
    if upInside == false then return end
    show_report_card()
    Sound.play("click")
    Vermilion.CopyBox.show(GetString(VERMILION_REPORT_COPY_TITLE), report_text())
  end)
  controls.summary = { bg = sum_bg, label = sum_label, help = sum_help, hit = sum_hit }
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
  controls.card.root:SetDrawTier(DT_HIGH)
  controls.win_fader = make_fader(controls.window)
  controls.win_fader.visible = true

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
  hit_layer:SetHandler("OnMouseWheel", function(_, delta)
    local dir = (delta and delta < 0) and 1 or -1
    if current_view == VIEW_BY_CONTRIB then
      if Vermilion.ContribView.scroll(dir) then
        hide_hover_ui()
        render_current_view()
      end
    elseif current_view == VIEW_BY_DEBUFFS then
      if Vermilion.DebuffsView.scroll(dir) then
        hide_hover_ui()
        render_current_view()
      end
    end
  end)
  hit_layer:SetHandler("OnMouseUp", function(_, _, upInside)
    if upInside == false or current_view ~= VIEW_BY_DEBUFFS then return end
    local mx, my = GetUIMousePosition()
    if Vermilion.DebuffsView.click(mx, my) then
      Sound.play(Vermilion.DebuffsView.unfolded() and "on" or "off")
      hide_hover_ui()
      release_all_pools()
      render_current_view()
    end
  end)
  Vermilion.DebuffsView.attach({
    canvas = controls.canvas, grid = controls.grid, no_data = controls.no_data,
    seg = controls.pool_d_seg, rim = controls.pool_d_rim, icon = controls.pool_d_icon, lbl = controls.pool_d_lbl,
    layout = CHIP, time_strip = TIME_STRIP_H, fmt_secs = fmt_secs, hide_grid = hide_grid, draw_grid = draw_grid,
    now = GetGameTimeMilliseconds,
    show_card = show_rows_card,
    hide_card = function() hide_hover_ui() end,
    crosshair = function(cx)
      if not controls.crosshair then return end
      controls.crosshair:ClearAnchors()
      controls.crosshair:SetAnchor(TOPLEFT,    controls.canvas, TOPLEFT,    cx, 0)
      controls.crosshair:SetAnchor(BOTTOMLEFT, controls.canvas, BOTTOMLEFT, cx, 0)
      fade_in(crosshair_fader)
    end,
    hit_reset = function() hit_begin(0) end,
    rerender = function() render_current_view() end,
  })
  Vermilion.ContribView.attach({
    canvas = controls.canvas, grid = controls.grid, no_data = controls.no_data,
    seg = controls.pool_c_seg, rim = controls.pool_c_rim, icon = controls.pool_c_icon, lbl = controls.pool_c_lbl,
    layout = CHIP, fmt_val = fmt_val, hexc = hexc, hide_grid = hide_grid,
    type_icon = function(ch)
      if ch == -1 then return SHIELD_ICON end
      return DTYPE_ICON[ch] or DTYPE_ICON[zc.DAMAGE_TYPE_GENERIC]
    end,
    show_card = show_moment_card,
    hide_card = function() fade_out(card_fader) end,
    hit_reset = function() hit_begin(0) end,
    rerender = function() render_current_view() end,
  })

  update_header(0)
  zev.register_update("VermilionHeaderTick", 1000, header_tick)
  refresh_button_colors()
end
