Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Bar = {}
local M = Verdant.Bar

local api  = Verdant.zenimax.api
local zui  = Verdant.zenimax.ui
local zc   = Verdant.zenimax.constants
local GetGameTimeMilliseconds = api.GetGameTimeMilliseconds
local GetAPIVersion           = api.GetAPIVersion
local PlaySound               = zui.PlaySound
local WINDOW_MANAGER          = zui.WINDOW_MANAGER
local string_format           = string.format
local math_max                = math.max
local math_min                = math.min
local math_floor              = math.floor

local log              = Verdant.Log.for_module("bar")
local TOPLEFT          = zc.TOPLEFT
local TOP              = zc.TOP
local TOPRIGHT         = zc.TOPRIGHT
local BOTTOMLEFT       = zc.BOTTOMLEFT
local BOTTOM           = zc.BOTTOM
local BOTTOMRIGHT      = zc.BOTTOMRIGHT
local CT_TEXTURE       = zc.CT_TEXTURE
local CT_LABEL         = zc.CT_LABEL
local CT_CONTROL       = zc.CT_CONTROL
local TEXT_ALIGN_CENTER = zc.TEXT_ALIGN_CENTER
local GuiRoot          = zc.GuiRoot
local SOUNDS           = zc.SOUNDS

local DISPLAY_METRICS = { "EMS", "eHPS", "MPS", "ALL" }

local COLORS = {
  EMS  = { r = 0.95, g = 0.80, b = 0.20, a = 0.92 },
  eHPS = { r = 0.55, g = 0.92, b = 0.62, a = 0.90 },
  MPS  = { r = 0.95, g = 0.68, b = 0.83, a = 0.90 },
}

local FILL_TEXTURE  = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local GLOSS_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill_gloss.dds"
local FILL_T, FILL_B = 0, 0.53125


local BORDER_COLOR = { r = 0.75, g = 0.62, b = 0.38, a = 0.90 }
local BORDER_SIZE  = 2


local MIN_W_SINGLE, MAX_W_SINGLE = 60,  140
local MIN_W_ALL,    MAX_W_ALL    = 110, 200
local MIN_H,        MAX_H        = 200, 440


local TRI_COL_W   = 26
local TRI_COL_GAP = 8
local TRI_COLS    = { "EMS", "eHPS", "MPS" }
local TRI_COL_X   = { EMS = 0, eHPS = TRI_COL_W + TRI_COL_GAP, MPS = (TRI_COL_W + TRI_COL_GAP) * 2 }
local TRI_TOTAL_W = TRI_COL_W * 3 + TRI_COL_GAP * 2   -- 94 px

local StackedBar = Verdant.lib.plot.StackedBar

local STACKED_BAR_OPTS = {
  texture        = FILL_TEXTURE,
  texture_coords = { 0, 1, FILL_T, FILL_B },
}

local function make_stacked_bar(parent, name_prefix)
  return StackedBar.new(parent, name_prefix, STACKED_BAR_OPTS)
end

local PEAK_DECAY_MS = 60000
local peaks = { EMS = { frac=0, t=0 }, eHPS = { frac=0, t=0 }, MPS = { frac=0, t=0 } }

local function update_peak(key, frac, now)
  local p = peaks[key]
  if frac >= p.frac then
    p.frac = frac ; p.t = now
  elseif (now - p.t) > PEAK_DECAY_MS then
    p.frac = frac ; p.t = now
  end
end

local function render_peak_line(line, parent, area_w, area_h, peak_frac)
  if peak_frac < 0.01 then line:SetHidden(true) ; return end
  local y = -math_floor(area_h * math_min(1, peak_frac))
  line:ClearAnchors()
  line:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, y)
  line:SetWidth(area_w)
  line:SetHidden(false)
end


local metric_idx  = 1
local segs_ehps   = { count = 0 }
local segs_mps    = { count = 0 }
local ALL_VALS    = { EMS = { frac = 0, raw = 0 }, eHPS = { frac = 0, raw = 0 }, MPS = { frac = 0, raw = 0 } }
local display_pct = false
local controls    = {}

local function current_metric() return DISPLAY_METRICS[metric_idx] end

local function contribution_values(r)
  local m = current_metric()
  if m == "EMS"  then return r.C_self,   r.EMS,  "EMS" end
  if m == "eHPS" then return r.C_heal,   r.eHPS, "HPS" end
  if m == "MPS"  then return r.C_shield, r.MPS,  "MPS" end
  return 0, 0, ""
end

local function save_state()
  local sv = Verdant.SavedVars
  if not sv then return end
  sv.bar = sv.bar or {}
  local b = sv.bar
  b.metric_idx  = metric_idx
  b.display_pct = display_pct
end

local function apply_size_constraints()
  local is_all = (current_metric() == "ALL")
  local min_w  = is_all and MIN_W_ALL or MIN_W_SINGLE
  local max_w  = is_all and MAX_W_ALL or MAX_W_SINGLE
  controls.window:SetDimensionConstraints(min_w, MIN_H, max_w, MAX_H)
  if is_all then
    local w, h = controls.window:GetDimensions()
    if w < MIN_W_ALL then controls.window:SetDimensions(MIN_W_ALL, h) end
  end
end

local function make_border(parent, name)
  local WM  = WINDOW_MANAGER
  local r, g, b, a = BORDER_COLOR.r, BORDER_COLOR.g, BORDER_COLOR.b, BORDER_COLOR.a
  local B   = BORDER_SIZE

  local function strip(suffix, a1, rp1, x1, y1, a2, rp2, x2, y2)
    local t = WM:CreateControl(name .. suffix, parent, CT_TEXTURE)
    t:ClearAnchors()
    t:SetAnchor(a1, parent, rp1, x1, y1)
    t:SetAnchor(a2, parent, rp2, x2, y2)
    t:SetTexture(FILL_TEXTURE)
    t:SetTextureCoords(0, 1, FILL_T, FILL_B)
    t:SetColor(r, g, b, a)
  end

  strip("T", TOPLEFT, TOPLEFT, 0, 0, BOTTOMRIGHT, TOPRIGHT,    0,  B)
  strip("B", TOPLEFT, BOTTOMLEFT, 0, -B, BOTTOMRIGHT, BOTTOMRIGHT, 0, 0)
  strip("L", TOPLEFT, TOPLEFT, 0, 0, BOTTOMRIGHT, BOTTOMLEFT, B, 0)
  strip("R", TOPLEFT, TOPRIGHT, -B, 0, BOTTOMRIGHT, BOTTOMRIGHT, 0, 0)
end

local function setup_single_bar()
  local WM   = WINDOW_MANAGER
  local area = controls.bar_area

  local fill = WM:CreateControl("VerdantBarFill", area, CT_TEXTURE)
  fill:ClearAnchors()
  fill:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
  fill:SetTexture(FILL_TEXTURE)
  fill:SetTextureCoords(0, 1, FILL_T, FILL_B)
  fill:SetColor(COLORS.EMS.r, COLORS.EMS.g, COLORS.EMS.b, COLORS.EMS.a)
  controls.fill = fill

  local fh = WM:CreateControl("VerdantBarFillHeal", area, CT_TEXTURE)
  fh:ClearAnchors()
  fh:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
  fh:SetTexture(FILL_TEXTURE)
  fh:SetTextureCoords(0, 1, FILL_T, FILL_B)
  fh:SetColor(COLORS.eHPS.r, COLORS.eHPS.g, COLORS.eHPS.b, COLORS.eHPS.a)
  fh:SetHidden(true)
  controls.fill_heal = fh

  local fs = WM:CreateControl("VerdantBarFillShield", area, CT_TEXTURE)
  fs:ClearAnchors()
  fs:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
  fs:SetTexture(FILL_TEXTURE)
  fs:SetTextureCoords(0, 1, FILL_T, FILL_B)
  fs:SetColor(COLORS.MPS.r, COLORS.MPS.g, COLORS.MPS.b, COLORS.MPS.a)
  fs:SetHidden(true)
  controls.fill_shield = fs

  controls.bar_ehps = make_stacked_bar(area, "VerdantBarSkillEhps")
  controls.bar_mps  = make_stacked_bar(area, "VerdantBarSkillMps")

  local gloss = WM:CreateControl("VerdantBarGloss", area, CT_TEXTURE)
  gloss:ClearAnchors()
  gloss:SetAnchor(TOPLEFT,     area, TOPLEFT,     0, 0)
  gloss:SetAnchor(BOTTOMRIGHT, area, BOTTOMRIGHT, 0, 0)
  gloss:SetTexture(GLOSS_TEXTURE)
  gloss:SetTextureCoords(0, 1, FILL_T, FILL_B)
  gloss:SetColor(1, 1, 1, 0.25)
  controls.gloss = gloss

  local pl = WM:CreateControl("VerdantBarPeakLine", area, CT_TEXTURE)
  pl:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
  pl:SetTexture(FILL_TEXTURE)
  pl:SetTextureCoords(0, 1, FILL_T, FILL_B)
  pl:SetDimensions(0, 2)
  pl:SetColor(1, 1, 1, 0.92)
  pl:SetHidden(true)
  controls.peak_line = pl

  make_border(area, "VerdantBarBorder")
end

local function setup_triple_view()
  local WM  = WINDOW_MANAGER
  local win = controls.window

  local container = WM:CreateControl("VerdantBarTriContainer", win, CT_CONTROL)
  container:ClearAnchors()
  container:SetAnchor(TOP,    win, TOP,    0, 78)
  container:SetAnchor(BOTTOM, win, BOTTOM, 0, -70)
  container:SetWidth(TRI_TOTAL_W)
  container:SetHidden(true)
  controls.tri_container = container

  controls.tri = {}

  for _, m in ipairs(TRI_COLS) do
    local x   = TRI_COL_X[m]
    local col = {}
    controls.tri[m] = col

    local lbl = WM:CreateControl("VerdantBarTriLabel" .. m, container, CT_LABEL)
    lbl:ClearAnchors()
    lbl:SetAnchor(TOPLEFT, container, TOPLEFT, x, 0)
    lbl:SetDimensions(TRI_COL_W, 14)
    lbl:SetFont("ZoFontGameSmall")
    lbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    lbl:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    col.label = lbl

    local area = WM:CreateControl("VerdantBarTriArea" .. m, container, CT_CONTROL)
    area:ClearAnchors()
    area:SetAnchor(TOPLEFT,    container, TOPLEFT,    x, 18)
    area:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, x, -18)
    area:SetWidth(TRI_COL_W)
    col.area = area

    local fill = WM:CreateControl("VerdantBarTriFill" .. m, area, CT_TEXTURE)
    fill:ClearAnchors()
    fill:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
    fill:SetTexture(FILL_TEXTURE)
    fill:SetTextureCoords(0, 1, FILL_T, FILL_B)
    local c = COLORS[m]
    fill:SetColor(c.r, c.g, c.b, c.a)
    col.fill = fill

    if m == "EMS" then
      fill:SetHidden(true)

      local fh = WM:CreateControl("VerdantBarTriFillHeal" .. m, area, CT_TEXTURE)
      fh:ClearAnchors()
      fh:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
      fh:SetTexture(FILL_TEXTURE)
      fh:SetTextureCoords(0, 1, FILL_T, FILL_B)
      fh:SetColor(COLORS.eHPS.r, COLORS.eHPS.g, COLORS.eHPS.b, COLORS.eHPS.a)
      fh:SetHidden(true)
      col.fill_heal = fh

      local fs = WM:CreateControl("VerdantBarTriFillShield" .. m, area, CT_TEXTURE)
      fs:ClearAnchors()
      fs:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
      fs:SetTexture(FILL_TEXTURE)
      fs:SetTextureCoords(0, 1, FILL_T, FILL_B)
      fs:SetColor(COLORS.MPS.r, COLORS.MPS.g, COLORS.MPS.b, COLORS.MPS.a)
      fs:SetHidden(true)
      col.fill_shield = fs
    end

    if m ~= "EMS" then
      col.bar = make_stacked_bar(area, "VerdantBarTriSkill" .. m)
    end

    local gloss = WM:CreateControl("VerdantBarTriGloss" .. m, area, CT_TEXTURE)
    gloss:ClearAnchors()
    gloss:SetAnchor(TOPLEFT,     area, TOPLEFT,     0, 0)
    gloss:SetAnchor(BOTTOMRIGHT, area, BOTTOMRIGHT, 0, 0)
    gloss:SetTexture(GLOSS_TEXTURE)
    gloss:SetTextureCoords(0, 1, FILL_T, FILL_B)
    gloss:SetColor(1, 1, 1, 0.25)

    local tpl = WM:CreateControl("VerdantBarTriPeak" .. m, area, CT_TEXTURE)
    tpl:SetAnchor(BOTTOMLEFT, area, BOTTOMLEFT, 0, 0)
    tpl:SetTexture(FILL_TEXTURE)
    tpl:SetTextureCoords(0, 1, FILL_T, FILL_B)
    tpl:SetDimensions(0, 2)
    tpl:SetColor(1, 1, 1, 0.92)
    tpl:SetHidden(true)
    col.peak_line = tpl

    make_border(area, "VerdantBarTriBorder" .. m)

    local val = WM:CreateControl("VerdantBarTriValue" .. m, container, CT_LABEL)
    val:ClearAnchors()
    val:SetAnchor(BOTTOMLEFT, container, BOTTOMLEFT, x, 0)
    val:SetDimensions(TRI_COL_W, 14)
    val:SetFont("ZoFontGameSmall")
    val:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    val:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    col.value = val
  end
end

local prof_enter = Verdant.Profiler.enter
local prof_exit  = Verdant.Profiler.exit

local function refresh()
  if controls.window:IsHidden() then return end
  prof_enter("bar.refresh")
  local now = GetGameTimeMilliseconds()
  local r   = Verdant.Metrics.contribution(now)
  local m   = current_metric()

  controls.mode_btn:SetText(display_pct and "#" or "%")

  if m == "ALL" then
    controls.bar_area:SetHidden(true)
    controls.metric_label:SetHidden(true)
    controls.value_label:SetHidden(true)
    controls.tri_container:SetHidden(false)

    local vals = ALL_VALS
    vals.EMS.frac,  vals.EMS.raw  = r.C_self   or 0, r.EMS  or 0
    vals.eHPS.frac, vals.eHPS.raw = r.C_heal   or 0, r.eHPS or 0
    vals.MPS.frac,  vals.MPS.raw  = r.C_shield or 0, r.MPS  or 0

    for _, cm in ipairs(TRI_COLS) do
      local col   = controls.tri[cm]
      local v     = vals[cm]
      local col_c = COLORS[cm]
      local frac  = math_max(0, math_min(1, v.frac))

      col.label:SetText(cm)
      col.label:SetColor(col_c.r, col_c.g, col_c.b, 1)

      if display_pct then
        col.value:SetText(string_format("%.0f%%", frac * 100))
      else
        col.value:SetText(ZO_CommaDelimitNumber(math_floor(v.raw)))
      end
      col.value:SetColor(1, 1, 1, 1)

      update_peak(cm, frac, now)

      local area_w = col.area:GetWidth()
      local area_h = col.area:GetHeight()
      if area_h > 4 then
        if cm == "eHPS" then
          col.fill:SetHidden(true)
          local segs = Verdant.Metrics.eHPS_by_group_into(segs_ehps, now)
          col.bar:render(col.area, segs, area_w, area_h, frac)
        elseif cm == "MPS" then
          col.fill:SetHidden(true)
          local segs = Verdant.Metrics.MPS_by_group_into(segs_mps, now)
          col.bar:render(col.area, segs, area_w, area_h, frac)
        else
          col.fill:SetHidden(true)
          local heal_frac   = math_max(0, math_min(1, r.C_heal   or 0))
          local shield_frac = math_max(0, math_min(1, r.C_shield or 0))
          local heal_h      = (heal_frac   > 0.005) and math_max(2, area_h * heal_frac)   or 0
          local shield_h    = (shield_frac > 0.005) and math_max(2, area_h * shield_frac) or 0

          local fh = col.fill_heal
          fh:SetHidden(false)
          fh:SetWidth(area_w)
          fh:SetHeight(heal_h)

          local fs = col.fill_shield
          fs:ClearAnchors()
          fs:SetAnchor(BOTTOMLEFT, col.area, BOTTOMLEFT, 0, -heal_h)
          fs:SetHidden(false)
          fs:SetWidth(area_w)
          fs:SetHeight(shield_h)
        end
        render_peak_line(col.peak_line, col.area, area_w, area_h, peaks[cm].frac)
      end
    end

  else
    controls.bar_area:SetHidden(false)
    controls.metric_label:SetHidden(false)
    controls.value_label:SetHidden(false)
    controls.tri_container:SetHidden(true)

    local frac, raw, suffix = contribution_values(r)
    frac = math_max(0, math_min(1, frac or 0))
    raw  = raw or 0
    local color = COLORS[m]

    controls.metric_label:SetText(m)
    controls.metric_label:SetColor(color.r, color.g, color.b, 1)

    if display_pct then
      controls.value_label:SetText(string_format("%.0f%%", frac * 100))
    else
      controls.value_label:SetText(ZO_CommaDelimitNumber(math_floor(raw)) .. " " .. suffix)
    end
    controls.value_label:SetColor(1, 1, 1, 1)

    local area_w = controls.bar_area:GetWidth()
    local area_h = controls.bar_area:GetHeight()
    if area_h <= 4 then return end

    update_peak(m, frac, now)

    if m == "EMS" then
      controls.fill:SetHidden(true)
      controls.bar_ehps:release()
      controls.bar_mps:release()

      local heal_frac   = math_max(0, math_min(1, r.C_heal   or 0))
      local shield_frac = math_max(0, math_min(1, r.C_shield or 0))
      local heal_h      = (heal_frac   > 0.005) and math_max(2, area_h * heal_frac)   or 0
      local shield_h    = (shield_frac > 0.005) and math_max(2, area_h * shield_frac) or 0

      local fh = controls.fill_heal
      fh:SetHidden(false)
      fh:SetWidth(area_w)
      fh:SetHeight(heal_h)

      local fs = controls.fill_shield
      fs:ClearAnchors()
      fs:SetAnchor(BOTTOMLEFT, controls.bar_area, BOTTOMLEFT, 0, -heal_h)
      fs:SetHidden(false)
      fs:SetWidth(area_w)
      fs:SetHeight(shield_h)

    elseif m == "eHPS" then
      controls.fill:SetHidden(true)
      controls.fill_heal:SetHidden(true)
      controls.fill_shield:SetHidden(true)
      controls.bar_mps:release()
      local segs = Verdant.Metrics.eHPS_by_group_into(segs_ehps, now)
      controls.bar_ehps:render(controls.bar_area, segs, area_w, area_h, frac)

    elseif m == "MPS" then
      controls.fill:SetHidden(true)
      controls.fill_heal:SetHidden(true)
      controls.fill_shield:SetHidden(true)
      controls.bar_ehps:release()
      local segs = Verdant.Metrics.MPS_by_group_into(segs_mps, now)
      controls.bar_mps:render(controls.bar_area, segs, area_w, area_h, frac)
    end

    render_peak_line(controls.peak_line, controls.bar_area, area_w, area_h, peaks[m].frac)
  end
  if controls.rec_dot then
    controls.rec_dot:SetHidden(not Verdant.TemporalBuffer.is_recording())
  end
  prof_exit("bar.refresh")
end

function M.prev_metric()
  metric_idx = ((metric_idx - 2) % #DISPLAY_METRICS) + 1
  PlaySound(SOUNDS.DIALOG_ACCEPT)
  apply_size_constraints()
  save_state()
  refresh()
end

function M.next_metric()
  metric_idx = (metric_idx % #DISPLAY_METRICS) + 1
  PlaySound(SOUNDS.DIALOG_ACCEPT)
  apply_size_constraints()
  save_state()
  refresh()
end

function M.toggle_display_mode()
  display_pct = not display_pct
  log:info("display_mode ->", display_pct and "%" or "#")
  PlaySound(SOUNDS.DIALOG_ACCEPT)
  save_state()
  refresh()
end

function M.toggle()
  local now_visible = not Verdant.Visibility.get("bar")
  log:info("toggle ->", now_visible and "show" or "hide")
  Verdant.Visibility.set("bar", now_visible)
  PlaySound(now_visible and SOUNDS.ARMORY_OPEN or SOUNDS.ADVENTURE_ZONE_OVERVIEW_CLOSED)
end

function M.on_close_click()
  Verdant.Visibility.set("bar", false)
  PlaySound(SOUNDS.ADVENTURE_ZONE_OVERVIEW_CLOSED)
end

function M.set_rate(ms)
  log:info("set_rate ->", ms, "ms")
  Verdant.zenimax.events.unregister_update("Verdant_BarTick")
  Verdant.zenimax.events.register_update("Verdant_BarTick", ms, refresh)
end

function M.on_move_stop()
  local left, top = controls.window:GetScreenRect()
  local sv = Verdant.SavedVars
  if sv then sv.bar = sv.bar or {} ; sv.bar.x, sv.bar.y = left, top end
end

function M.reset_peaks()
  for k in pairs(peaks) do peaks[k].frac = 0 ; peaks[k].t = 0 end
end

function M.on_resize_stop()
  local w, h = controls.window:GetDimensions()
  local is_all = (current_metric() == "ALL")
  local min_w  = is_all and MIN_W_ALL or MIN_W_SINGLE
  local max_w  = is_all and MAX_W_ALL or MAX_W_SINGLE
  w = math_max(min_w, math_min(max_w, w))
  h = math_max(MIN_H, math_min(MAX_H, h))
  controls.window:SetDimensions(w, h)
  local sv = Verdant.SavedVars
  if sv then sv.bar = sv.bar or {} ; sv.bar.w, sv.bar.h = w, h end
end

function M.init()
  local C  = Verdant.Constants
  local sv = Verdant.SavedVars
  sv.bar = sv.bar or {}
  local b = sv.bar

  metric_idx  = b.metric_idx  or 1
  display_pct = b.display_pct or false

  controls.window        = VerdantBarWindow

  VerdantBarWindowBg:SetCenterColor(0.62, 1.00, 0.74, 1.0)
  VerdantBarWindowBg:SetEdgeColor(0.42, 1.00, 0.60, 1.0)

  controls.metric_label  = VerdantBarWindowMetricLabel
  controls.value_label   = VerdantBarWindowValueLabel
  controls.bar_area      = VerdantBarWindowBarArea
  controls.mode_btn      = VerdantBarWindowModeBtn
  controls.version_label = VerdantBarWindowVersionLabel
  controls.api_label     = VerdantBarWindowApiLabel
  controls.prev_btn      = VerdantBarWindowPrevBtn
  controls.next_btn      = VerdantBarWindowNextBtn
  controls.settings_btn  = VerdantBarWindowSettingsBtn
  controls.metric_label:SetMouseEnabled(true)
  controls.metric_label:SetHandler("OnMouseUp", function(_, _, upInside)
    if upInside ~= false then M.next_metric() end
  end)
  zui.tooltip(controls.metric_label, VERDANT_TIP_BAR_METRIC)
  local rec_dot = zui.WINDOW_MANAGER:CreateControl("VerdantBarWindowRecDot", VerdantBarWindow, CT_TEXTURE)
  rec_dot:SetTexture("Verdant/assets/rec.dds")
  rec_dot:SetDimensions(8, 8)
  rec_dot:SetAnchor(TOPRIGHT, VerdantBarWindow, TOPRIGHT, -6, 6)
  rec_dot:SetDrawLevel(6)
  rec_dot:SetHidden(true)
  controls.rec_dot = rec_dot
  zui.tooltip(controls.prev_btn,     VERDANT_TIP_BAR_PREV)
  zui.tooltip(controls.next_btn,     VERDANT_TIP_BAR_NEXT)
  zui.tooltip(controls.mode_btn,     VERDANT_TIP_BAR_MODE)
  zui.tooltip(controls.settings_btn, VERDANT_TIP_SETTINGS)
  zui.tooltip(VerdantBarWindowGraphBtn, VERDANT_TIP_GRAPH)
  zui.tooltip(VerdantBarWindowCloseBtn, VERDANT_TIP_CLOSE)

  controls.api_label:SetHidden(true)
  if C.DEBUG then
    controls.version_label:SetText(string_format("v%s  API %d", C.VERSION, GetAPIVersion()))
  else
    controls.version_label:SetText("v" .. C.VERSION)
  end
  controls.version_label:SetColor(0.40, 0.40, 0.40, 1)

  local is_all = (DISPLAY_METRICS[metric_idx] == "ALL")
  local min_w  = is_all and MIN_W_ALL or MIN_W_SINGLE
  local max_w  = is_all and MAX_W_ALL or MAX_W_SINGLE
  controls.window:SetDimensionConstraints(min_w, MIN_H, max_w, MAX_H)
  controls.window:SetDimensions(b.w or 70, b.h or 240)

  if b.x and b.y then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, b.x, b.y)
  end

  setup_single_bar()
  setup_triple_view()

  local visible = (b.visible == nil) and true or b.visible
  controls.window:SetHidden(not visible)

  local rate_ms = b.rate_ms or 1000
  Verdant.zenimax.events.register_update("Verdant_BarTick", rate_ms, refresh)
  refresh()
end
