Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Settings = {}
local M = Vermilion.Settings

local api = Vermilion.zenimax.api
local zui = Vermilion.zenimax.ui
local zc  = Vermilion.zenimax.constants
local GetUIMousePosition = api.GetUIMousePosition
local GetString          = api.GetString
local d                  = d
local WINDOW_MANAGER     = zui.WINDOW_MANAGER
local math_max           = math.max
local math_min           = math.min
local math_floor         = math.floor

local log         = Vermilion.Log.for_module("settings")
local TOP         = zc.TOP
local TOPLEFT     = zc.TOPLEFT
local BOTTOM      = zc.BOTTOM
local BOTTOMLEFT  = zc.BOTTOMLEFT
local CT_TEXTURE  = zc.CT_TEXTURE
local GuiRoot     = zc.GuiRoot

local FILL_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local FILL_T, FILL_B = 0, 0.53125

-- Sample-rate cap 5 Hz (ported from Verditer). Nyquist: combat is ~1s-scale and the
-- per-second metrics are already windowed, so >5 Hz only adds redundant bars. Old 10 Hz
-- SavedVars clamp to 5 Hz via nearest_idx on load.
local SAMPLE_MAX_HZ  = 5
local SAMPLE_PRESETS = {}
local SAMPLE_LABELS  = {}
for hz = 1, SAMPLE_MAX_HZ do
  local ms = math_floor(1000 / hz + 0.5)
  SAMPLE_PRESETS[#SAMPLE_PRESETS + 1] = ms
  SAMPLE_LABELS[ms] = hz .. " Hz"
end
local SAMPLE_DEFAULT = 1000

local function twindow_presets()
  local p, lbls = {}, {}
  for s = 15, 600, 15 do
    p[#p + 1] = s
    if s % 60 == 0 then
      lbls[s] = (s / 60) .. "m"
    elseif s < 60 then
      lbls[s] = s .. "s"
    else
      lbls[s] = string.format("%d:%02d", math_floor(s / 60), s % 60)
    end
  end
  return p, lbls
end
local TWINDOW_PRESETS, TWINDOW_LABELS = twindow_presets()
local TWINDOW_DEFAULT = 60

local VPALPHA_PRESETS = {}
local VPALPHA_LABELS  = {}
for pct = 0, 100, 5 do
  VPALPHA_PRESETS[#VPALPHA_PRESETS + 1] = pct
  VPALPHA_LABELS[pct] = pct .. "%"
end
local VPALPHA_DEFAULT = 30

local CRITTHRESH_PRESETS = {}
local CRITTHRESH_LABELS  = {}
for pct = 0, 100, 5 do
  CRITTHRESH_PRESETS[#CRITTHRESH_PRESETS + 1] = pct
  CRITTHRESH_LABELS[pct] = pct .. "%"
end
local CRITTHRESH_DEFAULT = 50

local controls          = {}
local current_sample    = SAMPLE_DEFAULT
local current_twindow   = TWINDOW_DEFAULT
local current_vpalpha   = VPALPHA_DEFAULT
local current_critthresh = CRITTHRESH_DEFAULT

local function nearest_idx(presets, ms)
  local bi, bd = 1, math.huge
  for i, p in ipairs(presets) do
    local diff = math.abs(p - ms)
    if diff < bd then bi, bd = i, diff end
  end
  return bi
end

local function update_slider(track, fill, thumb, label, presets, labels, ms)
  local w = track:GetWidth()
  if w <= 0 then return end
  local idx = nearest_idx(presets, ms)
  local pct = (idx - 1) / (#presets - 1)
  fill:SetWidth(math_max(2, w * pct))
  fill:SetHeight(track:GetHeight())
  thumb:ClearAnchors()
  thumb:SetAnchor(TOP,    track, TOPLEFT,    w * pct, -1)
  thumb:SetAnchor(BOTTOM, track, BOTTOMLEFT, w * pct,  1)
  thumb:SetWidth(3)
  label:SetText(labels[ms] or (math_floor(ms / 1000) .. "s"))
end

local TRACK_BG_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_frame_bg.dds"

local function setup_slider_visuals(track, name_prefix)
  local WM = WINDOW_MANAGER

  local bg = WM:CreateControl(name_prefix .. "Bg", track, CT_TEXTURE)
  bg:SetAnchorFill(track)
  bg:SetTexture(TRACK_BG_TEXTURE)
  bg:SetColor(0.55, 0.55, 0.55, 0.85)
  bg:SetDrawLevel(0)

  local fill = WM:CreateControl(name_prefix .. "Fill", track, CT_TEXTURE)
  fill:ClearAnchors()
  fill:SetAnchor(BOTTOMLEFT, track, BOTTOMLEFT, 0, 0)
  fill:SetTexture(FILL_TEXTURE)
  fill:SetTextureCoords(0, 1, FILL_T, FILL_B)
  fill:SetColor(0.88, 0.30, 0.26, 0.92)   -- VERMILION crimson (brand colour propagated)
  fill:SetDrawLevel(1)

  local thumb = WM:CreateControl(name_prefix .. "Thumb", track, CT_TEXTURE)
  thumb:SetTexture(FILL_TEXTURE)
  thumb:SetTextureCoords(0, 1, FILL_T, FILL_B)
  thumb:SetColor(1, 1, 1, 1)
  thumb:SetDrawLevel(2)

  return fill, thumb
end

local function persist_temporal(key, val)
  local sv = Vermilion.SavedVars
  if sv then sv.temporal = sv.temporal or {} ; sv.temporal[key] = val end
end

local function persist_graph(key, val)
  local sv = Vermilion.SavedVars
  if sv then sv.graph = sv.graph or {} ; sv.graph[key] = val end
end

local CAPACITY_WARN_THRESHOLD = 1500

local function warn_if_heavy(capacity, twindow_s, hz)
  if capacity <= CAPACITY_WARN_THRESHOLD then return end
  local msg = string.format(GetString(VERMILION_WARN_HEAVY_BUFFER), twindow_s, hz, capacity)
  d("|cFF4444[Vm] WARNING:|r " .. msg)
  log:warn("heavy combo:", msg)
end

local function reinit_buffer()
  local hz       = math_floor(1000 / current_sample)
  local capacity = current_twindow * hz
  Vermilion.TemporalBuffer.init(capacity)
  warn_if_heavy(capacity, current_twindow, hz)
end

local function refresh_all_sliders()
  local c = controls
  update_slider(c.track_sample,  c.fill_sample,  c.thumb_sample,  c.label_sample,  SAMPLE_PRESETS,  SAMPLE_LABELS,  current_sample)
  update_slider(c.track_twindow, c.fill_twindow, c.thumb_twindow, c.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
  update_slider(c.track_vpalpha, c.fill_vpalpha, c.thumb_vpalpha, c.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
  update_slider(c.track_critthresh, c.fill_critthresh, c.thumb_critthresh, c.label_critthresh, CRITTHRESH_PRESETS, CRITTHRESH_LABELS, current_critthresh)
end

function M.toggle()
  local win    = controls.window
  local hidden = win:IsHidden()
  if hidden then
    win:SetHidden(false)
    refresh_all_sliders()
  else
    win:SetHidden(true)
  end
end

function M.on_move_stop()
  local sv = Vermilion.SavedVars
  if not sv or not controls.window then return end
  sv.settings = sv.settings or {}
  sv.settings.x = controls.window:GetLeft()
  sv.settings.y = controls.window:GetTop()
end

function M.on_unknown_click()
  controls.window:SetHidden(true)
  Vermilion.Assign.show()
end

function M.on_logo_click()
  local now = not Vermilion.Logo.is_enabled()
  Vermilion.Logo.set_enabled(now)
  controls.logo_btn:SetText(now and GetString(VERMILION_SETTINGS_LOGO_ON)
                                 or GetString(VERMILION_SETTINGS_LOGO_OFF))
  if not now then d("[Vm] " .. GetString(VERMILION_LOGO_HINT)) end
end

function M.on_sample_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#SAMPLE_PRESETS, math_floor(pct * (#SAMPLE_PRESETS - 1) + 0.5) + 1))
  current_sample = SAMPLE_PRESETS[idx]
  log:info("sample_rate ->", current_sample, "ms")
  persist_temporal("sample_rate_ms", current_sample)
  reinit_buffer()
  update_slider(controls.track_sample, controls.fill_sample, controls.thumb_sample, controls.label_sample, SAMPLE_PRESETS, SAMPLE_LABELS, current_sample)
end

function M.on_twindow_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#TWINDOW_PRESETS, math_floor(pct * (#TWINDOW_PRESETS - 1) + 0.5) + 1))
  current_twindow = TWINDOW_PRESETS[idx]
  log:info("time_window ->", current_twindow, "s")
  persist_temporal("time_window_s", current_twindow)
  reinit_buffer()
  update_slider(controls.track_twindow, controls.fill_twindow, controls.thumb_twindow, controls.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
end

function M.on_vpalpha_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#VPALPHA_PRESETS, math_floor(pct * (#VPALPHA_PRESETS - 1) + 0.5) + 1))
  current_vpalpha = VPALPHA_PRESETS[idx]
  log:info("viewport_alpha ->", current_vpalpha, "%")
  persist_graph("viewport_alpha_pct", current_vpalpha)
  Vermilion.Graph.set_viewport_alpha(current_vpalpha / 100)
  update_slider(controls.track_vpalpha, controls.fill_vpalpha, controls.thumb_vpalpha, controls.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
end

function M.on_critthresh_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#CRITTHRESH_PRESETS, math_floor(pct * (#CRITTHRESH_PRESETS - 1) + 0.5) + 1))
  current_critthresh = CRITTHRESH_PRESETS[idx]
  log:info("crit_threshold ->", current_critthresh, "%")
  persist_graph("crit_threshold_pct", current_critthresh)
  Vermilion.Graph.set_crit_threshold(current_critthresh)
  update_slider(controls.track_critthresh, controls.fill_critthresh, controls.thumb_critthresh, controls.label_critthresh, CRITTHRESH_PRESETS, CRITTHRESH_LABELS, current_critthresh)
end

function M.on_reset_click()
  log:info("reset to defaults")
  current_sample     = SAMPLE_DEFAULT
  current_twindow    = TWINDOW_DEFAULT
  current_vpalpha    = VPALPHA_DEFAULT
  current_critthresh = CRITTHRESH_DEFAULT
  persist_temporal("sample_rate_ms", current_sample)
  persist_temporal("time_window_s",  current_twindow)
  persist_graph("viewport_alpha_pct", current_vpalpha)
  persist_graph("crit_threshold_pct", current_critthresh)
  reinit_buffer()
  Vermilion.Graph.set_viewport_alpha(current_vpalpha / 100)
  Vermilion.Graph.set_crit_threshold(current_critthresh)
  refresh_all_sliders()
end

function M.snapshot()
  local hz       = math_floor(1000 / current_sample)
  local capacity = current_twindow * hz
  return {
    sample_rate_ms      = current_sample,
    sample_rate_hz      = hz,
    time_window_s       = current_twindow,
    viewport_alpha_pct  = current_vpalpha,
    crit_threshold_pct  = current_critthresh,
    temporal_capacity   = capacity,
    capacity_warn_above = CAPACITY_WARN_THRESHOLD,
  }
end

function M.report_lines()
  local s = M.snapshot()
  local heavy = (s.temporal_capacity > s.capacity_warn_above) and "  [HEAVY]" or ""
  return {
    string.format("[config] graph: sample=%dms (%dHz) window=%ds capacity=%d%s",
      s.sample_rate_ms, s.sample_rate_hz, s.time_window_s, s.temporal_capacity, heavy),
    string.format("[config] viewport_alpha=%d%%", s.viewport_alpha_pct),
  }
end

function M.init()
  local sv = Vermilion.SavedVars
  sv.temporal = sv.temporal or {}
  sv.settings = sv.settings or {}
  sv.graph    = sv.graph    or {}

  current_sample     = SAMPLE_PRESETS [nearest_idx(SAMPLE_PRESETS,  sv.temporal.sample_rate_ms     or SAMPLE_DEFAULT)]
  current_twindow    = TWINDOW_PRESETS[nearest_idx(TWINDOW_PRESETS, sv.temporal.time_window_s      or TWINDOW_DEFAULT)]
  current_vpalpha    = VPALPHA_PRESETS[nearest_idx(VPALPHA_PRESETS, sv.graph.viewport_alpha_pct    or VPALPHA_DEFAULT)]
  current_critthresh = CRITTHRESH_PRESETS[nearest_idx(CRITTHRESH_PRESETS, sv.graph.crit_threshold_pct or CRITTHRESH_DEFAULT)]

  reinit_buffer()
  Vermilion.Graph.set_crit_threshold(current_critthresh)

  controls.window         = VermilionSettingsPanel
  controls.window_title   = VermilionSettingsPanelWindowTitle

  VermilionSettingsPanelBg:SetCenterColor(1.00, 0.62, 0.58, 1.0)
  VermilionSettingsPanelBg:SetEdgeColor(1.00, 0.45, 0.40, 1.0)
  controls.title_sample   = VermilionSettingsPanelSampleTitle
  controls.label_sample   = VermilionSettingsPanelSampleLabel
  controls.track_sample   = VermilionSettingsPanelSliderTrackSample
  controls.title_twindow  = VermilionSettingsPanelTWindowTitle
  controls.label_twindow  = VermilionSettingsPanelTWindowLabel
  controls.track_twindow  = VermilionSettingsPanelSliderTrackTWindow
  controls.title_vpalpha  = VermilionSettingsPanelVPAlphaTitle
  controls.label_vpalpha  = VermilionSettingsPanelVPAlphaLabel
  controls.track_vpalpha  = VermilionSettingsPanelSliderTrackVPAlpha
  controls.title_critthresh = VermilionSettingsPanelCritThreshTitle
  controls.label_critthresh = VermilionSettingsPanelCritThreshLabel
  controls.track_critthresh = VermilionSettingsPanelSliderTrackCritThresh
  controls.reset_btn      = VermilionSettingsPanelResetBtn
  controls.unknown_btn    = VermilionSettingsPanelUnknownBtn
  controls.unknown_label  = VermilionSettingsPanelUnknownLabel
  controls.logo_btn       = VermilionSettingsPanelLogoBtn

  controls.window_title:SetText(GetString(VERMILION_SETTINGS_TITLE))
  controls.reset_btn:SetText(GetString(VERMILION_SETTINGS_RESET))
  controls.unknown_label:SetText(GetString(VERMILION_SETTINGS_UNKNOWN))
  controls.unknown_label:SetColor(0.80, 0.80, 0.80, 1)
  controls.logo_btn:SetText(Vermilion.Logo.is_enabled()
    and GetString(VERMILION_SETTINGS_LOGO_ON) or GetString(VERMILION_SETTINGS_LOGO_OFF))

  controls.title_sample:SetText(GetString(VERMILION_SETTING_SAMPLE_RATE))
  controls.title_sample:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_sample:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_twindow:SetText(GetString(VERMILION_SETTING_TIME_WINDOW))
  controls.title_twindow:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_twindow:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_vpalpha:SetText(GetString(VERMILION_SETTING_VIEWPORT_ALPHA))
  controls.title_vpalpha:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_vpalpha:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_critthresh:SetText(GetString(VERMILION_SETTING_CRIT_THRESHOLD))
  controls.title_critthresh:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_critthresh:SetColor(0.95, 0.80, 0.20, 1)

  local c = controls
  c.fill_sample,  c.thumb_sample  = setup_slider_visuals(c.track_sample,  "VermilionSettingsSample")
  c.fill_twindow, c.thumb_twindow = setup_slider_visuals(c.track_twindow, "VermilionSettingsTWindow")
  c.fill_vpalpha, c.thumb_vpalpha = setup_slider_visuals(c.track_vpalpha, "VermilionSettingsVPAlpha")
  c.fill_critthresh, c.thumb_critthresh = setup_slider_visuals(c.track_critthresh, "VermilionSettingsCritThresh")

  if sv.settings.x and sv.settings.y then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.x, sv.settings.y)
  else
    controls.window:ClearAnchors()
    controls.window:SetAnchor(zc.CENTER, GuiRoot, zc.CENTER, 0, 0)
  end

  for _, line in ipairs(M.report_lines()) do log:info(line) end
end
