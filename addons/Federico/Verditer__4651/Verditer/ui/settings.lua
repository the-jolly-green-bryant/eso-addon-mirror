Verditer = Verditer or {}
local Verditer = Verditer

Verditer.Settings = {}
local M = Verditer.Settings

local api = Verditer.zenimax.api
local zui = Verditer.zenimax.ui
local zc  = Verditer.zenimax.constants
local GetUIMousePosition = api.GetUIMousePosition
local GetString          = api.GetString
local d                  = d
local WINDOW_MANAGER     = zui.WINDOW_MANAGER
local math_max           = math.max
local math_min           = math.min
local math_floor         = math.floor

local log         = Verditer.Log.for_module("settings")
local TOP         = zc.TOP
local TOPLEFT     = zc.TOPLEFT
local BOTTOM      = zc.BOTTOM
local BOTTOMLEFT  = zc.BOTTOMLEFT
local CT_TEXTURE  = zc.CT_TEXTURE
local GuiRoot     = zc.GuiRoot

local FILL_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local FILL_T, FILL_B = 0, 0.53125

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

local controls        = {}
local current_sample  = SAMPLE_DEFAULT
local current_twindow = TWINDOW_DEFAULT
local current_vpalpha = VPALPHA_DEFAULT

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
  fill:SetColor(0.30, 0.50, 0.92, 0.90)
  fill:SetDrawLevel(1)

  local thumb = WM:CreateControl(name_prefix .. "Thumb", track, CT_TEXTURE)
  thumb:SetTexture(FILL_TEXTURE)
  thumb:SetTextureCoords(0, 1, FILL_T, FILL_B)
  thumb:SetColor(1, 1, 1, 1)
  thumb:SetDrawLevel(2)

  return fill, thumb
end

local function persist_temporal(key, val)
  local sv = Verditer.SavedVars
  if sv then sv.temporal = sv.temporal or {} ; sv.temporal[key] = val end
end

local function persist_graph(key, val)
  local sv = Verditer.SavedVars
  if sv then sv.graph = sv.graph or {} ; sv.graph[key] = val end
end

local CAPACITY_WARN_THRESHOLD = 1500

local function warn_if_heavy(capacity, twindow_s, hz)
  if capacity <= CAPACITY_WARN_THRESHOLD then return end
  local msg = string.format(GetString(VERDITER_WARN_HEAVY_BUFFER), twindow_s, hz, capacity)
  d("|cFF4444[Vd] WARNING:|r " .. msg)
  log:warn("heavy combo:", msg)
end

local function reinit_buffer()
  local hz       = math_floor(1000 / current_sample)
  local capacity = current_twindow * hz
  Verditer.TemporalBuffer.init(capacity)
  warn_if_heavy(capacity, current_twindow, hz)
end

local function refresh_all_sliders()
  local c = controls
  update_slider(c.track_sample,  c.fill_sample,  c.thumb_sample,  c.label_sample,  SAMPLE_PRESETS,  SAMPLE_LABELS,  current_sample)
  update_slider(c.track_twindow, c.fill_twindow, c.thumb_twindow, c.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
  update_slider(c.track_vpalpha, c.fill_vpalpha, c.thumb_vpalpha, c.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
end

function M.toggle()
  local win    = controls.window
  local hidden = win:IsHidden()
  if hidden then
    Verditer.Sound.play("WINDOW_OPEN")
    win:SetHidden(false)
    refresh_all_sliders()
  else
    Verditer.Sound.play("WINDOW_CLOSE")
    win:SetHidden(true)
  end
end

function M.on_move_stop()
  local sv = Verditer.SavedVars
  if not sv or not controls.window then return end
  sv.settings = sv.settings or {}
  sv.settings.x = controls.window:GetLeft()
  sv.settings.y = controls.window:GetTop()
end

function M.on_recap_click()
  local now = not Verditer.DeathRecap.is_enabled()
  Verditer.DeathRecap.set_enabled(now)
  Verditer.Sound.play("CLICK")
  controls.recap_btn:SetText(now and GetString(VERDITER_SETTINGS_RECAP_ON)
                                 or GetString(VERDITER_SETTINGS_RECAP_OFF))
end

function M.on_logo_click()
  local now = not Verditer.Logo.is_enabled()
  Verditer.Logo.set_enabled(now)
  controls.logo_btn:SetText(now and GetString(VERDITER_SETTINGS_LOGO_ON)
                                 or GetString(VERDITER_SETTINGS_LOGO_OFF))
  if not now then d("[Vd] " .. GetString(VERDITER_LOGO_HINT)) end
end

function M.on_sample_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#SAMPLE_PRESETS, math_floor(pct * (#SAMPLE_PRESETS - 1) + 0.5) + 1))
  current_sample = SAMPLE_PRESETS[idx]
  Verditer.Sound.slider()
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
  Verditer.Sound.slider()
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
  Verditer.Sound.slider()
  log:info("viewport_alpha ->", current_vpalpha, "%")
  persist_graph("viewport_alpha_pct", current_vpalpha)
  Verditer.Graph.set_viewport_alpha(current_vpalpha / 100)
  update_slider(controls.track_vpalpha, controls.fill_vpalpha, controls.thumb_vpalpha, controls.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
end

function M.on_reset_click()
  Verditer.Sound.play("CLICK")
  log:info("reset to defaults")
  current_sample  = SAMPLE_DEFAULT
  current_twindow = TWINDOW_DEFAULT
  current_vpalpha = VPALPHA_DEFAULT
  persist_temporal("sample_rate_ms", current_sample)
  persist_temporal("time_window_s",  current_twindow)
  persist_graph("viewport_alpha_pct", current_vpalpha)
  reinit_buffer()
  Verditer.Graph.set_viewport_alpha(current_vpalpha / 100)
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
  local sv = Verditer.SavedVars
  sv.temporal = sv.temporal or {}
  sv.settings = sv.settings or {}
  sv.graph    = sv.graph    or {}

  current_sample  = SAMPLE_PRESETS [nearest_idx(SAMPLE_PRESETS,  sv.temporal.sample_rate_ms     or SAMPLE_DEFAULT)]
  current_twindow = TWINDOW_PRESETS[nearest_idx(TWINDOW_PRESETS, sv.temporal.time_window_s      or TWINDOW_DEFAULT)]
  current_vpalpha = VPALPHA_PRESETS[nearest_idx(VPALPHA_PRESETS, sv.graph.viewport_alpha_pct    or VPALPHA_DEFAULT)]

  reinit_buffer()

  controls.window         = VerditerSettingsPanel
  controls.window_title   = VerditerSettingsPanelWindowTitle

  local EDGE = Verditer.Constants.BRAND.EDGE
  VerditerSettingsPanelBg:SetCenterColor(0.043, 0.063, 0.125, 1.0)  -- VERDITER tint
  VerditerSettingsPanelBg:SetEdgeColor(EDGE.r, EDGE.g, EDGE.b, 1.0)
  controls.title_sample   = VerditerSettingsPanelSampleTitle
  controls.label_sample   = VerditerSettingsPanelSampleLabel
  controls.track_sample   = VerditerSettingsPanelSliderTrackSample
  controls.title_twindow  = VerditerSettingsPanelTWindowTitle
  controls.label_twindow  = VerditerSettingsPanelTWindowLabel
  controls.track_twindow  = VerditerSettingsPanelSliderTrackTWindow
  controls.title_vpalpha  = VerditerSettingsPanelVPAlphaTitle
  controls.label_vpalpha  = VerditerSettingsPanelVPAlphaLabel
  controls.track_vpalpha  = VerditerSettingsPanelSliderTrackVPAlpha
  controls.reset_btn      = VerditerSettingsPanelResetBtn
  controls.logo_btn       = VerditerSettingsPanelLogoBtn
  controls.recap_btn      = VerditerSettingsPanelRecapBtn

  controls.window_title:SetText(GetString(VERDITER_SETTINGS_TITLE))
  controls.reset_btn:SetText(GetString(VERDITER_SETTINGS_RESET))
  controls.logo_btn:SetText(Verditer.Logo.is_enabled()
    and GetString(VERDITER_SETTINGS_LOGO_ON) or GetString(VERDITER_SETTINGS_LOGO_OFF))
  controls.recap_btn:SetText(Verditer.DeathRecap.is_enabled()
    and GetString(VERDITER_SETTINGS_RECAP_ON) or GetString(VERDITER_SETTINGS_RECAP_OFF))

  controls.title_sample:SetText(GetString(VERDITER_SETTING_SAMPLE_RATE))
  controls.title_sample:SetColor(0.78, 0.84, 0.95, 1)
  controls.label_sample:SetColor(0.44, 0.66, 1.00, 1)

  controls.title_twindow:SetText(GetString(VERDITER_SETTING_TIME_WINDOW))
  controls.title_twindow:SetColor(0.78, 0.84, 0.95, 1)
  controls.label_twindow:SetColor(0.44, 0.66, 1.00, 1)

  controls.title_vpalpha:SetText(GetString(VERDITER_SETTING_VIEWPORT_ALPHA))
  controls.title_vpalpha:SetColor(0.78, 0.84, 0.95, 1)
  controls.label_vpalpha:SetColor(0.44, 0.66, 1.00, 1)

  local c = controls
  c.fill_sample,  c.thumb_sample  = setup_slider_visuals(c.track_sample,  "VerditerSettingsSample")
  c.fill_twindow, c.thumb_twindow = setup_slider_visuals(c.track_twindow, "VerditerSettingsTWindow")
  c.fill_vpalpha, c.thumb_vpalpha = setup_slider_visuals(c.track_vpalpha, "VerditerSettingsVPAlpha")

  if sv.settings.x and sv.settings.y then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.x, sv.settings.y)
  else
    controls.window:ClearAnchors()
    controls.window:SetAnchor(zc.CENTER, GuiRoot, zc.CENTER, 0, 0)
  end

  for _, line in ipairs(M.report_lines()) do log:info(line) end
end
