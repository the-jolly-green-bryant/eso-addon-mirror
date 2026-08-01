Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Settings = {}
local M = Verdant.Settings

local api = Verdant.zenimax.api
local zui = Verdant.zenimax.ui
local zc  = Verdant.zenimax.constants
local GetUIMousePosition = api.GetUIMousePosition
local GetString          = api.GetString
local WINDOW_MANAGER     = zui.WINDOW_MANAGER
local math_max           = math.max
local math_min           = math.min
local math_floor         = math.floor

local log         = Verdant.Log.for_module("settings")
local TOP         = zc.TOP
local TOPLEFT     = zc.TOPLEFT
local BOTTOM      = zc.BOTTOM
local BOTTOMLEFT  = zc.BOTTOMLEFT
local CT_TEXTURE  = zc.CT_TEXTURE
local GuiRoot     = zc.GuiRoot

local FILL_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local FILL_T, FILL_B = 0, 0.53125

local RATE_PRESETS   = { 50, 100, 200, 500, 1000, 2000 }
local RATE_LABELS    = {
  [50]   = "20 Hz", [100] = "10 Hz", [200] = "5 Hz",
  [500]  = "2 Hz",  [1000] = "1 Hz", [2000] = "0.5 Hz",
}
local RATE_DEFAULT   = 1000

local function range_presets(start_s, end_s)
  local p, lbls = {}, {}
  for s = start_s, end_s do
    local ms = s * 1000
    p[#p + 1]   = ms
    lbls[ms]    = s .. "s"
  end
  return p, lbls
end

local HEAL_PRESETS,   HEAL_LABELS   = range_presets(1, 30)
local SHIELD_PRESETS, SHIELD_LABELS = range_presets(1, 30)
local HEAL_DEFAULT   = 5000
local SHIELD_DEFAULT = 10000
local SAMPLE_MAX_HZ  = 5
local SAMPLE_PRESETS = {}
local SAMPLE_LABELS  = {}
for hz = 1, SAMPLE_MAX_HZ do
  local ms = math.floor(1000 / hz + 0.5)
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
      lbls[s] = string.format("%d:%02d", math.floor(s / 60), s % 60)
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

local function profile_label_for(id)
  if id == "solo"     then return GetString(VERDANT_PROFILE_SOLO)     end
  if id == "dungeons" then return GetString(VERDANT_PROFILE_DUNGEONS) end
  if id == "trials"   then return GetString(VERDANT_PROFILE_TRIALS)   end
  if id == "pvp"      then return GetString(VERDANT_PROFILE_PVP)      end
  if id == "custom"   then return GetString(VERDANT_PROFILE_CUSTOM)   end
  return id
end

local PROFILES = {
  { id = "solo",     rate = 1000, heal = 5000, shield = 10000, sample = 1000, twindow = 60  },
  { id = "dungeons", rate = 500,  heal = 5000, shield = 7000,  sample = 1000, twindow = 180 },
  { id = "trials",   rate = 1000, heal = 5000, shield = 7000,  sample = 1000, twindow = 600 },
  { id = "pvp",      rate = 200,  heal = 3000, shield = 5000,  sample = 200,  twindow = 30  },
  { id = "custom"    },
}
local PROFILE_DEFAULT = "solo"

local function profile_by_id(id)
  for _, p in ipairs(PROFILES) do
    if p.id == id then return p end
  end
  return nil
end

local controls       = {}
local current_rate    = RATE_DEFAULT
local current_heal    = HEAL_DEFAULT
local current_shield  = SHIELD_DEFAULT
local current_sample  = SAMPLE_DEFAULT
local current_twindow = TWINDOW_DEFAULT
local current_vpalpha = VPALPHA_DEFAULT
local current_profile = PROFILE_DEFAULT

local function nearest_idx(presets, ms)
  local bi, bd = 1, math.huge
  for i, p in ipairs(presets) do
    local d = math.abs(p - ms)
    if d < bd then bi, bd = i, d end
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
  fill:SetColor(0.40, 0.82, 0.50, 0.92)   -- VERDANT green (brand colour propagated)
  fill:SetDrawLevel(1)

  local thumb = WM:CreateControl(name_prefix .. "Thumb", track, CT_TEXTURE)
  thumb:SetTexture(FILL_TEXTURE)
  thumb:SetTextureCoords(0, 1, FILL_T, FILL_B)
  thumb:SetColor(1, 1, 1, 1)
  thumb:SetDrawLevel(2)

  return fill, thumb
end

local function persist(key, val)
  local sv = Verdant.SavedVars
  if sv then sv.bar = sv.bar or {} ; sv.bar[key] = val end
end

local function persist_temporal(key, val)
  local sv = Verdant.SavedVars
  if sv then sv.temporal = sv.temporal or {} ; sv.temporal[key] = val end
end

local CAPACITY_WARN_THRESHOLD = 1500

local function warn_if_heavy(capacity, twindow_s, hz)
  if capacity <= CAPACITY_WARN_THRESHOLD then return end
  local msg = string.format(GetString(VERDANT_WARN_HEAVY_BUFFER), twindow_s, hz, capacity)
  d("|cFF4444[V] WARNING:|r " .. msg)
  log:warn("heavy combo:", msg)
end

local function reinit_buffer()
  local hz       = math_floor(1000 / current_sample)
  local capacity = current_twindow * hz
  Verdant.TemporalBuffer.init(capacity)
  warn_if_heavy(capacity, current_twindow, hz)
end

local profile_combo

local function persist_profile(id)
  local sv = Verdant.SavedVars
  if sv then sv.settings = sv.settings or {} ; sv.settings.profile = id end
end

local function mark_custom()
  if current_profile == "custom" then return end
  current_profile = "custom"
  persist_profile("custom")
  if profile_combo then
    profile_combo:SetSelectedItemText(profile_label_for("custom"))
  end
end

local function apply_profile(id)
  local p = profile_by_id(id)
  if not p or not p.rate then return false end

  current_rate    = p.rate
  current_heal    = p.heal
  current_shield  = p.shield
  current_sample  = p.sample
  current_twindow = p.twindow

  persist("rate_ms",          current_rate)
  persist("heal_window_ms",   current_heal)
  persist("shield_window_ms", current_shield)
  persist_temporal("sample_rate_ms", current_sample)
  persist_temporal("time_window_s",  current_twindow)

  Verdant.Bar.set_rate(current_rate)
  Verdant.Metrics.set_window(current_heal)
  Verdant.Metrics.set_shield_window(current_shield)
  reinit_buffer()

  current_profile = id
  persist_profile(id)
  log:info("profile ->", profile_label_for(id))
  return true
end

local function refresh_all_sliders()
  local c = controls
  update_slider(c.track_rate,    c.fill_rate,    c.thumb_rate,    c.label_rate,    RATE_PRESETS,    RATE_LABELS,    current_rate)
  update_slider(c.track_heal,    c.fill_heal,    c.thumb_heal,    c.label_heal,    HEAL_PRESETS,    HEAL_LABELS,    current_heal)
  update_slider(c.track_shield,  c.fill_shield,  c.thumb_shield,  c.label_shield,  SHIELD_PRESETS,  SHIELD_LABELS,  current_shield)
  update_slider(c.track_sample,  c.fill_sample,  c.thumb_sample,  c.label_sample,  SAMPLE_PRESETS,  SAMPLE_LABELS,  current_sample)
  update_slider(c.track_twindow, c.fill_twindow, c.thumb_twindow, c.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
  update_slider(c.track_vpalpha, c.fill_vpalpha, c.thumb_vpalpha, c.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
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
  local sv = Verdant.SavedVars
  if not sv or not controls.window then return end
  sv.settings = sv.settings or {}
  sv.settings.x = controls.window:GetLeft()
  sv.settings.y = controls.window:GetTop()
end

function M.on_unknown_click()
  controls.window:SetHidden(true)
  Verdant.Assign.show()
end

function M.on_logo_click()
  local now = not Verdant.Logo.is_enabled()
  Verdant.Logo.set_enabled(now)
  controls.logo_btn:SetText(now and GetString(VERDANT_SETTINGS_LOGO_ON)
                                 or GetString(VERDANT_SETTINGS_LOGO_OFF))
  if not now then d("[V] " .. GetString(VERDANT_LOGO_HINT)) end
end

function M.on_bars_click()
  local now = not Verdant.Visibility.is_bar_enabled()
  Verdant.Visibility.set_bar_enabled(now)
  controls.bars_btn:SetText(now and GetString(VERDANT_SETTINGS_BARS_ON)
                                 or GetString(VERDANT_SETTINGS_BARS_OFF))
end

local SHIELDDIR_LABEL = { [true] = "Shields: hang down", [false] = "Shields: grow up" }

function M.on_shielddir_click()
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  local now = not (sv.settings.shield_down == true)
  sv.settings.shield_down = now
  controls.shielddir_btn:SetText(SHIELDDIR_LABEL[now])
  Verdant.Graph.set_shield_down(now)
end

function M.on_profile_selected(id)
  if id == "custom" then
    current_profile = "custom"
    persist_profile("custom")
    return
  end
  if apply_profile(id) then refresh_all_sliders() end
end

function M.on_rate_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#RATE_PRESETS, math_floor(pct * (#RATE_PRESETS - 1) + 0.5) + 1))
  current_rate = RATE_PRESETS[idx]
  log:info("rate ->", current_rate, "ms")
  Verdant.Bar.set_rate(current_rate)
  persist("rate_ms", current_rate)
  mark_custom()
  update_slider(controls.track_rate, controls.fill_rate, controls.thumb_rate, controls.label_rate, RATE_PRESETS, RATE_LABELS, current_rate)
end

function M.on_heal_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#HEAL_PRESETS, math_floor(pct * (#HEAL_PRESETS - 1) + 0.5) + 1))
  current_heal = HEAL_PRESETS[idx]
  log:info("heal_window ->", current_heal, "ms")
  Verdant.Metrics.set_window(current_heal)
  persist("heal_window_ms", current_heal)
  mark_custom()
  update_slider(controls.track_heal, controls.fill_heal, controls.thumb_heal, controls.label_heal, HEAL_PRESETS, HEAL_LABELS, current_heal)
end

function M.on_shield_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#SHIELD_PRESETS, math_floor(pct * (#SHIELD_PRESETS - 1) + 0.5) + 1))
  current_shield = SHIELD_PRESETS[idx]
  log:info("shield_window ->", current_shield, "ms")
  Verdant.Metrics.set_shield_window(current_shield)
  persist("shield_window_ms", current_shield)
  mark_custom()
  update_slider(controls.track_shield, controls.fill_shield, controls.thumb_shield, controls.label_shield, SHIELD_PRESETS, SHIELD_LABELS, current_shield)
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
  mark_custom()
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
  mark_custom()
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
  persist_temporal("viewport_alpha_pct", current_vpalpha)
  Verdant.Graph.set_viewport_alpha(current_vpalpha / 100)
  update_slider(controls.track_vpalpha, controls.fill_vpalpha, controls.thumb_vpalpha, controls.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
end

function M.on_reset_click()
  log:info("reset to defaults")
  apply_profile(PROFILE_DEFAULT)

  current_vpalpha = VPALPHA_DEFAULT
  persist_temporal("viewport_alpha_pct", current_vpalpha)
  Verdant.Graph.set_viewport_alpha(current_vpalpha / 100)

  if profile_combo then
    profile_combo:SetSelectedItemText(profile_label_for(PROFILE_DEFAULT))
  end
  refresh_all_sliders()
end

function M.snapshot()
  local hz       = math_floor(1000 / current_sample)
  local capacity = current_twindow * hz
  return {
    profile_id           = current_profile,
    profile_label        = profile_label_for(current_profile),
    rate_ms              = current_rate,
    heal_window_ms       = current_heal,
    shield_window_ms     = current_shield,
    sample_rate_ms       = current_sample,
    sample_rate_hz       = hz,
    time_window_s        = current_twindow,
    viewport_alpha_pct   = current_vpalpha,
    temporal_capacity    = capacity,
    capacity_warn_above  = CAPACITY_WARN_THRESHOLD,
  }
end

function M.report_lines()
  local s = M.snapshot()
  local heavy = (s.temporal_capacity > s.capacity_warn_above) and "  [HEAVY]" or ""
  return {
    string.format("[config] profile=%s", s.profile_label),
    string.format("[config] bar: refresh=%dms heal_window=%dms shield_window=%dms",
      s.rate_ms, s.heal_window_ms, s.shield_window_ms),
    string.format("[config] graph: sample=%dms (%dHz) window=%ds capacity=%d%s",
      s.sample_rate_ms, s.sample_rate_hz, s.time_window_s, s.temporal_capacity, heavy),
    string.format("[config] viewport_alpha=%d%%", s.viewport_alpha_pct),
  }
end

function M.init()
  local sv = Verdant.SavedVars
  sv.bar      = sv.bar      or {}
  sv.temporal = sv.temporal or {}

  sv.settings = sv.settings or {}

  current_rate    = RATE_PRESETS   [nearest_idx(RATE_PRESETS,    sv.bar.rate_ms             or RATE_DEFAULT)]
  current_heal    = HEAL_PRESETS   [nearest_idx(HEAL_PRESETS,    sv.bar.heal_window_ms      or HEAL_DEFAULT)]
  current_shield  = SHIELD_PRESETS [nearest_idx(SHIELD_PRESETS,  sv.bar.shield_window_ms    or SHIELD_DEFAULT)]
  current_sample  = SAMPLE_PRESETS [nearest_idx(SAMPLE_PRESETS,  sv.temporal.sample_rate_ms    or SAMPLE_DEFAULT)]
  current_twindow = TWINDOW_PRESETS[nearest_idx(TWINDOW_PRESETS, sv.temporal.time_window_s     or TWINDOW_DEFAULT)]
  current_vpalpha = VPALPHA_PRESETS[nearest_idx(VPALPHA_PRESETS, sv.temporal.viewport_alpha_pct or VPALPHA_DEFAULT)]

  current_profile = profile_by_id(sv.settings.profile or PROFILE_DEFAULT) and (sv.settings.profile or PROFILE_DEFAULT) or PROFILE_DEFAULT

  Verdant.Metrics.set_window(current_heal)
  Verdant.Metrics.set_shield_window(current_shield)

  reinit_buffer()

  controls.window         = VerdantSettingsPanel

  VerdantSettingsPanelBg:SetCenterColor(0.62, 1.00, 0.74, 1.0)
  VerdantSettingsPanelBg:SetEdgeColor(0.42, 1.00, 0.60, 1.0)

  controls.title_rate     = VerdantSettingsPanelTitle
  controls.label_rate     = VerdantSettingsPanelRateLabel
  controls.track_rate     = VerdantSettingsPanelSliderTrack
  controls.title_heal     = VerdantSettingsPanelHealTitle
  controls.label_heal     = VerdantSettingsPanelHealLabel
  controls.track_heal     = VerdantSettingsPanelSliderTrackHeal
  controls.title_shield   = VerdantSettingsPanelShieldTitle
  controls.label_shield   = VerdantSettingsPanelShieldLabel
  controls.track_shield   = VerdantSettingsPanelSliderTrackShield
  controls.title_sample   = VerdantSettingsPanelSampleTitle
  controls.label_sample   = VerdantSettingsPanelSampleLabel
  controls.track_sample   = VerdantSettingsPanelSliderTrackSample
  controls.title_twindow  = VerdantSettingsPanelTWindowTitle
  controls.label_twindow  = VerdantSettingsPanelTWindowLabel
  controls.track_twindow  = VerdantSettingsPanelSliderTrackTWindow
  controls.title_vpalpha  = VerdantSettingsPanelVPAlphaTitle
  controls.label_vpalpha  = VerdantSettingsPanelVPAlphaLabel
  controls.track_vpalpha  = VerdantSettingsPanelSliderTrackVPAlpha
  controls.window_title   = VerdantSettingsPanelWindowTitle
  controls.reset_btn      = VerdantSettingsPanelResetBtn
  controls.profile_label  = VerdantSettingsPanelProfileLabel
  controls.profile_combo  = VerdantSettingsPanelProfileDropdown
  controls.unknown_btn    = VerdantSettingsPanelUnknownBtn
  controls.unknown_label  = VerdantSettingsPanelUnknownLabel
  controls.logo_btn       = VerdantSettingsPanelLogoBtn
  controls.bars_btn       = VerdantSettingsPanelBarsBtn
  controls.shielddir_btn  = VerdantSettingsPanelShieldDirBtn

  controls.window_title:SetText(GetString(VERDANT_SETTINGS_TITLE))
  controls.reset_btn:SetText(GetString(VERDANT_SETTINGS_RESET))
  controls.profile_label:SetText(GetString(VERDANT_SETTINGS_PROFILE))
  controls.profile_label:SetColor(0.75, 0.75, 0.75, 1)

  controls.unknown_label:SetText(GetString(VERDANT_SETTINGS_UNKNOWN))
  controls.unknown_label:SetColor(0.80, 0.80, 0.80, 1)
  controls.logo_btn:SetText(Verdant.Logo.is_enabled()
    and GetString(VERDANT_SETTINGS_LOGO_ON) or GetString(VERDANT_SETTINGS_LOGO_OFF))

  local bars_on = not (Verdant.SavedVars and Verdant.SavedVars.bar
                       and Verdant.SavedVars.bar.enabled == false)
  controls.bars_btn:SetText(bars_on and GetString(VERDANT_SETTINGS_BARS_ON)
                                     or GetString(VERDANT_SETTINGS_BARS_OFF))

  local shield_down = (sv.settings.shield_down == true)
  controls.shielddir_btn:SetText(SHIELDDIR_LABEL[shield_down])
  Verdant.Graph.set_shield_down(shield_down)

  profile_combo = ZO_ComboBox_ObjectFromContainer(controls.profile_combo)
  profile_combo:SetSortsItems(false)
  profile_combo:ClearItems()
  for _, p in ipairs(PROFILES) do
    local id = p.id
    local entry = profile_combo:CreateItemEntry(profile_label_for(id),
      function() M.on_profile_selected(id) end)
    profile_combo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  end
  profile_combo:UpdateItems()
  profile_combo:SetSelectedItemText(profile_label_for(current_profile))

  controls.title_rate:SetText(GetString(VERDANT_SETTING_REFRESH_RATE))
  controls.title_rate:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_rate:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_heal:SetText(GetString(VERDANT_SETTING_HEAL_WINDOW))
  controls.title_heal:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_heal:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_shield:SetText(GetString(VERDANT_SETTING_SHIELD_WINDOW))
  controls.title_shield:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_shield:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_sample:SetText(GetString(VERDANT_SETTING_SAMPLE_RATE))
  controls.title_sample:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_sample:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_twindow:SetText(GetString(VERDANT_SETTING_TIME_WINDOW))
  controls.title_twindow:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_twindow:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_vpalpha:SetText(GetString(VERDANT_SETTING_VIEWPORT_ALPHA))
  controls.title_vpalpha:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_vpalpha:SetColor(0.95, 0.80, 0.20, 1)

  local c = controls
  c.fill_rate,    c.thumb_rate    = setup_slider_visuals(c.track_rate,    "VerdantSettingsRate")
  c.fill_heal,    c.thumb_heal    = setup_slider_visuals(c.track_heal,    "VerdantSettingsHeal")
  c.fill_shield,  c.thumb_shield  = setup_slider_visuals(c.track_shield,  "VerdantSettingsShield")
  c.fill_sample,  c.thumb_sample  = setup_slider_visuals(c.track_sample,  "VerdantSettingsSample")
  c.fill_twindow, c.thumb_twindow = setup_slider_visuals(c.track_twindow, "VerdantSettingsTWindow")
  c.fill_vpalpha, c.thumb_vpalpha = setup_slider_visuals(c.track_vpalpha, "VerdantSettingsVPAlpha")

  if sv.settings.x and sv.settings.y then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.x, sv.settings.y)
  else
    controls.window:ClearAnchors()
    controls.window:SetAnchor(zc.CENTER, GuiRoot, zc.CENTER, 0, 0)
  end

  for _, line in ipairs(M.report_lines()) do log:info(line) end
end
