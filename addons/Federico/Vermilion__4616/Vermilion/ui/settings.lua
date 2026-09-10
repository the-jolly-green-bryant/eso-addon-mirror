Vermilion = Vermilion or {}
local Vermilion = Vermilion

Vermilion.Settings = {}
local M = Vermilion.Settings
local Sound = Vermilion.Sound

local api = Vermilion.zenimax.api
local zui = Vermilion.zenimax.ui
local zc  = Vermilion.zenimax.constants
local Scene = Vermilion.zenimax.scene
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
local TOPRIGHT    = zc.TOPRIGHT
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
  for s = 15, 600, 15 do p[#p + 1] = s end
  for s = 660, 1200, 60 do p[#p + 1] = s end
  for _, s in ipairs(p) do
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

local LIGHTA_PRESETS = {}
local LIGHTA_LABELS  = {}
for pct = 10, 90, 5 do
  LIGHTA_PRESETS[#LIGHTA_PRESETS + 1] = pct
  LIGHTA_LABELS[pct] = pct .. "%"
end
local LIGHTA_DEFAULT = 40

local USER_PREFIX = "user:"

local function is_user_profile(id)
  return type(id) == "string" and id:sub(1, #USER_PREFIX) == USER_PREFIX
end

local function user_profile_name(id)
  return id:sub(#USER_PREFIX + 1)
end

local function profile_label_for(id)
  if is_user_profile(id) then return "* " .. user_profile_name(id) end
  return GetString(VERMILION_PROFILE_CUSTOM)
end

local PROFILE_DEFAULT = "custom"

local function user_profiles()
  local sv = Vermilion.SavedVars
  if not sv then return nil end
  sv.settings = sv.settings or {}
  sv.settings.user_profiles = sv.settings.user_profiles or {}
  return sv.settings.user_profiles
end

local function user_profile_names_sorted()
  local out = {}
  local up = user_profiles()
  if up then
    for name in pairs(up) do out[#out + 1] = name end
    table.sort(out)
  end
  return out
end

local function profile_by_id(id)
  if id == PROFILE_DEFAULT then return { id = id } end
  if is_user_profile(id) then
    local up = user_profiles()
    local vals = up and up[user_profile_name(id)]
    if vals then
      return { id = id, sample = vals.sample, twindow = vals.twindow,
               vpalpha = vals.vpalpha, critthresh = vals.critthresh }
    end
  end
  return nil
end

local controls           = {}
local current_sample     = SAMPLE_DEFAULT
local current_twindow    = TWINDOW_DEFAULT
local current_vpalpha    = VPALPHA_DEFAULT
local current_critthresh = CRITTHRESH_DEFAULT
local current_profile    = PROFILE_DEFAULT
local current_lighta     = LIGHTA_DEFAULT
local profile_combo

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
  fill:SetColor(0.88, 0.30, 0.26, 0.92)
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

local function persist_profile(id)
  local sv = Vermilion.SavedVars
  if sv then sv.settings = sv.settings or {} ; sv.settings.profile = id end
end

local CAPACITY_WARN_THRESHOLD = 1500

local function capacity_of(sample_ms, twindow_s)
  return twindow_s * math_floor(1000 / sample_ms)
end

local function is_heavy(sample_ms, twindow_s)
  return capacity_of(sample_ms, twindow_s) > CAPACITY_WARN_THRESHOLD
end

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

local C_FILL_OK     = { 0.88, 0.30, 0.26, 0.92 }
local C_FILL_HEAVY  = { 1.00, 0.55, 0.10, 0.92 }
local C_LABEL_OK    = { 0.95, 0.80, 0.20, 1 }
local C_LABEL_HEAVY = { 1.00, 0.62, 0.25, 1 }

local function tint_temporal()
  local heavy = is_heavy(current_sample, current_twindow)
  local f = heavy and C_FILL_HEAVY or C_FILL_OK
  local l = heavy and C_LABEL_HEAVY or C_LABEL_OK
  for _, k in ipairs({ "sample", "twindow" }) do
    local fill, label = controls["fill_" .. k], controls["label_" .. k]
    if fill then fill:SetColor(f[1], f[2], f[3], f[4]) end
    if label then label:SetColor(l[1], l[2], l[3], l[4]) end
  end
end

function M.is_heavy_combo() return is_heavy(current_sample, current_twindow) end

local confirm = { kind = nil }

local function show_confirm(kind, title, msg, yes, no)
  confirm.kind = kind
  controls.confirm_title:SetText(GetString(title))
  controls.confirm_msg:SetText(msg)
  controls.confirm_yes:SetText(GetString(yes))
  controls.confirm_no:SetText(GetString(no))
  controls.confirm:SetHidden(false)
  Sound.play("deny")
end

local function ask_heavy(prev_sample, prev_twindow)
  local was_heavy = is_heavy(prev_sample, prev_twindow)
  local heavy = is_heavy(current_sample, current_twindow)
  if not heavy then return end
  if was_heavy and capacity_of(current_sample, current_twindow) <= capacity_of(prev_sample, prev_twindow) then return end
  confirm.prev_sample  = prev_sample
  confirm.prev_twindow = prev_twindow
  local hz = math_floor(1000 / current_sample)
  show_confirm("heavy", VERMILION_SETTINGS_HEAVY_TITLE,
    string.format(GetString(VERMILION_SETTINGS_HEAVY_MSG), TWINDOW_LABELS[current_twindow] or (current_twindow .. "s"), hz,
      capacity_of(current_sample, current_twindow)),
    VERMILION_SETTINGS_HEAVY_YES, VERMILION_SETTINGS_HEAVY_NO)
end

local function mark_custom()
  if current_profile == PROFILE_DEFAULT then return end
  current_profile = PROFILE_DEFAULT
  persist_profile(PROFILE_DEFAULT)
  if profile_combo then
    profile_combo:SetSelectedItemText(profile_label_for(PROFILE_DEFAULT))
  end
end

local function apply_values(sample, twindow, vpalpha, critthresh)
  current_sample     = SAMPLE_PRESETS[nearest_idx(SAMPLE_PRESETS, sample or SAMPLE_DEFAULT)]
  current_twindow    = TWINDOW_PRESETS[nearest_idx(TWINDOW_PRESETS, twindow or TWINDOW_DEFAULT)]
  current_vpalpha    = VPALPHA_PRESETS[nearest_idx(VPALPHA_PRESETS, vpalpha or VPALPHA_DEFAULT)]
  current_critthresh = CRITTHRESH_PRESETS[nearest_idx(CRITTHRESH_PRESETS, critthresh or CRITTHRESH_DEFAULT)]
  persist_temporal("sample_rate_ms", current_sample)
  persist_temporal("time_window_s",  current_twindow)
  persist_graph("viewport_alpha_pct", current_vpalpha)
  persist_graph("crit_threshold_pct", current_critthresh)
  reinit_buffer()
  Vermilion.Graph.set_viewport_alpha(current_vpalpha / 100)
  Vermilion.Graph.set_crit_threshold(current_critthresh)
end

local function apply_profile(id)
  local p = profile_by_id(id)
  if not p or not p.sample then return false end
  apply_values(p.sample, p.twindow, p.vpalpha, p.critthresh)
  current_profile = id
  persist_profile(id)
  log:info("profile ->", profile_label_for(id))
  return true
end

local function refresh_all_sliders()
  local c = controls
  update_slider(c.track_sample,  c.fill_sample,  c.thumb_sample,  c.label_sample,  SAMPLE_PRESETS,  SAMPLE_LABELS,  current_sample)
  update_slider(c.track_twindow, c.fill_twindow, c.thumb_twindow, c.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
  update_slider(c.track_vpalpha, c.fill_vpalpha, c.thumb_vpalpha, c.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
  update_slider(c.track_critthresh, c.fill_critthresh, c.thumb_critthresh, c.label_critthresh, CRITTHRESH_PRESETS, CRITTHRESH_LABELS, current_critthresh)
  update_slider(c.track_lighta, c.fill_lighta, c.thumb_lighta, c.label_lighta, LIGHTA_PRESETS, LIGHTA_LABELS, current_lighta)
  tint_temporal()
end

function M.refresh_unknown_count()
  local SC = Vermilion.SkillColors
  local n = (SC and SC.unknown_count and SC.unknown_count()) or 0
  local text = GetString(VERMILION_SETTINGS_UNKNOWN)
  if n > 0 then text = text .. " (" .. n .. ")" end
  controls.unknown_label:SetText(text)
end

local function dock_window()
  local win = controls.window
  local host = VermilionGraphWindow
  if not host or host:IsHidden() then return end
  local screen_w = GuiRoot:GetWidth()
  local panel_w  = win:GetWidth()
  win:ClearAnchors()
  if host:GetRight() + panel_w + 16 <= screen_w then
    win:SetAnchor(TOPLEFT, host, TOPRIGHT, 8, 0)
  else
    win:SetAnchor(TOPRIGHT, host, TOPLEFT, -8, 0)
  end
end

function M.toggle()
  local win    = controls.window
  local hidden = win:IsHidden()
  if hidden then
    dock_window()
    Scene.show_top_level(win)
    refresh_all_sliders()
    M.refresh_unknown_count()
    Sound.play("open")
  else
    Scene.hide_top_level(win)
    controls.confirm:SetHidden(true)
    confirm.kind = nil
    Sound.play("close")
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
  Sound.play(now and "on" or "off")
  controls.logo_btn:SetText(now and GetString(VERMILION_SETTINGS_LOGO_ON)
                                 or GetString(VERMILION_SETTINGS_LOGO_OFF))
  if not now then d("[Vm] " .. GetString(VERMILION_LOGO_HINT)) end
end

local function track_pick(control, presets)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return nil end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#presets, math_floor(pct * (#presets - 1) + 0.5) + 1))
  return presets[idx]
end

function M.on_sample_track_click(control)
  local v = track_pick(control, SAMPLE_PRESETS)
  if not v then return end
  local prev_sample, prev_twindow = current_sample, current_twindow
  current_sample = v
  log:info("sample_rate ->", current_sample, "ms")
  persist_temporal("sample_rate_ms", current_sample)
  reinit_buffer()
  mark_custom()
  update_slider(controls.track_sample, controls.fill_sample, controls.thumb_sample, controls.label_sample, SAMPLE_PRESETS, SAMPLE_LABELS, current_sample)
  tint_temporal()
  ask_heavy(prev_sample, prev_twindow)
end

function M.on_twindow_track_click(control)
  local v = track_pick(control, TWINDOW_PRESETS)
  if not v then return end
  local prev_sample, prev_twindow = current_sample, current_twindow
  current_twindow = v
  log:info("time_window ->", current_twindow, "s")
  persist_temporal("time_window_s", current_twindow)
  reinit_buffer()
  mark_custom()
  update_slider(controls.track_twindow, controls.fill_twindow, controls.thumb_twindow, controls.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
  tint_temporal()
  ask_heavy(prev_sample, prev_twindow)
end

function M.on_vpalpha_track_click(control)
  local v = track_pick(control, VPALPHA_PRESETS)
  if not v then return end
  current_vpalpha = v
  log:info("viewport_alpha ->", current_vpalpha, "%")
  persist_graph("viewport_alpha_pct", current_vpalpha)
  Vermilion.Graph.set_viewport_alpha(current_vpalpha / 100)
  mark_custom()
  update_slider(controls.track_vpalpha, controls.fill_vpalpha, controls.thumb_vpalpha, controls.label_vpalpha, VPALPHA_PRESETS, VPALPHA_LABELS, current_vpalpha)
end

function M.on_critthresh_track_click(control)
  local v = track_pick(control, CRITTHRESH_PRESETS)
  if not v then return end
  current_critthresh = v
  log:info("crit_threshold ->", current_critthresh, "%")
  persist_graph("crit_threshold_pct", current_critthresh)
  Vermilion.Graph.set_crit_threshold(current_critthresh)
  mark_custom()
  update_slider(controls.track_critthresh, controls.fill_critthresh, controls.thumb_critthresh, controls.label_critthresh, CRITTHRESH_PRESETS, CRITTHRESH_LABELS, current_critthresh)
end

local function light_label(on)
  return on and GetString(VERMILION_SETTINGS_LIGHT_ON) or GetString(VERMILION_SETTINGS_LIGHT_OFF)
end

function M.on_light_click()
  local sv = Vermilion.SavedVars
  sv.settings = sv.settings or {}
  local now = not (sv.settings.light_mode == true)
  sv.settings.light_mode = now
  Sound.play(now and "on" or "off")
  controls.light_btn:SetText(light_label(now))
  Vermilion.Graph.set_light_enabled(now)
end

function M.on_lightalpha_track_click(control)
  local v = track_pick(control, LIGHTA_PRESETS)
  if not v then return end
  current_lighta = v
  log:info("light_alpha ->", current_lighta, "%")
  local sv = Vermilion.SavedVars
  sv.settings = sv.settings or {}
  sv.settings.light_alpha_pct = current_lighta
  Vermilion.Graph.set_light_alpha(current_lighta / 100)
  update_slider(controls.track_lighta, controls.fill_lighta, controls.thumb_lighta, controls.label_lighta, LIGHTA_PRESETS, LIGHTA_LABELS, current_lighta)
end

function M.on_confirm_yes()
  local kind = confirm.kind
  confirm.kind = nil
  controls.confirm:SetHidden(true)
  Sound.play("confirm")
  if kind == "pdelete" then M.delete_profile_now() end
end

function M.on_confirm_no()
  local kind = confirm.kind
  confirm.kind = nil
  controls.confirm:SetHidden(true)
  Sound.play("discard")
  if kind == "heavy" then
    current_sample  = confirm.prev_sample
    current_twindow = confirm.prev_twindow
    persist_temporal("sample_rate_ms", current_sample)
    persist_temporal("time_window_s", current_twindow)
    reinit_buffer()
    refresh_all_sliders()
  end
end

function M.on_pname_focus(on)
  local box = VermilionSettingsPanelPNameBox
  if on then
    box:SetEdgeColor(1.00, 0.62, 0.58, 0.95)
    if controls.pname_edit.SelectAll then controls.pname_edit:SelectAll() end
  else
    box:SetEdgeColor(1.00, 0.45, 0.40, 0.45)
  end
end

function M.on_profile_selected(id)
  if id == PROFILE_DEFAULT then
    current_profile = PROFILE_DEFAULT
    persist_profile(PROFILE_DEFAULT)
    return
  end
  if apply_profile(id) then
    Sound.play("page")
    refresh_all_sliders()
  end
end

local function rebuild_profile_combo()
  if not profile_combo then return end
  profile_combo:ClearItems()
  local entry = profile_combo:CreateItemEntry(profile_label_for(PROFILE_DEFAULT),
    function() M.on_profile_selected(PROFILE_DEFAULT) end)
  profile_combo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  for _, name in ipairs(user_profile_names_sorted()) do
    local id = USER_PREFIX .. name
    local e = profile_combo:CreateItemEntry(profile_label_for(id),
      function() M.on_profile_selected(id) end)
    profile_combo:AddItem(e, ZO_COMBOBOX_SUPPRESS_UPDATE)
  end
  profile_combo:UpdateItems()
  profile_combo:SetSelectedItemText(profile_label_for(current_profile))
end

function M.on_profile_save_click()
  local up = user_profiles()
  if not up then return end
  local name = controls.pname_edit:GetText() or ""
  name = name:match("^%s*(.-)%s*$")
  if name == "" and is_user_profile(current_profile) then
    name = user_profile_name(current_profile)
  end
  if name == "" then
    Sound.play("deny")
    d("[Vm] " .. GetString(VERMILION_PROFILE_NAME_HINT))
    return
  end
  name = name:sub(1, 20)
  up[name] = {
    sample     = current_sample,
    twindow    = current_twindow,
    vpalpha    = current_vpalpha,
    critthresh = current_critthresh,
  }
  current_profile = USER_PREFIX .. name
  persist_profile(current_profile)
  controls.pname_edit:SetText("")
  rebuild_profile_combo()
  Sound.play("confirm")
  log:info("user profile saved:", name)
  d("[Vm] " .. string.format(GetString(VERMILION_PROFILE_SAVED), name))
end

function M.on_profile_delete_click()
  if not is_user_profile(current_profile) then
    Sound.play("deny")
    d("[Vm] " .. GetString(VERMILION_PROFILE_DELETE_HINT))
    return
  end
  show_confirm("pdelete", VERMILION_SETTINGS_PDEL_TITLE,
    string.format(GetString(VERMILION_SETTINGS_PDEL_MSG), user_profile_name(current_profile)),
    VERMILION_SETTINGS_PDEL_YES, VERMILION_SETTINGS_PDEL_NO)
end

function M.delete_profile_now()
  if not is_user_profile(current_profile) then return end
  local up = user_profiles()
  if not up then return end
  local name = user_profile_name(current_profile)
  up[name] = nil
  current_profile = PROFILE_DEFAULT
  persist_profile(PROFILE_DEFAULT)
  rebuild_profile_combo()
  log:info("user profile deleted:", name)
  d("[Vm] " .. string.format(GetString(VERMILION_PROFILE_DELETED), name))
end

local function autorec_label(m)
  if m == "boss"   then return GetString(VERMILION_SETTINGS_AUTOREC_BOSS)   end
  if m == "combat" then return GetString(VERMILION_SETTINGS_AUTOREC_COMBAT) end
  return GetString(VERMILION_SETTINGS_AUTOREC_OFF)
end

local function autosave_label(on)
  return on and GetString(VERMILION_SETTINGS_AUTOSAVE_ON) or GetString(VERMILION_SETTINGS_AUTOSAVE_OFF)
end

local function autostop_label(on)
  return on and GetString(VERMILION_SETTINGS_AUTOSTOP_ON) or GetString(VERMILION_SETTINGS_AUTOSTOP_OFF)
end

local function sounds_on()
  local sv = Vermilion.SavedVars
  return not (sv and sv.settings and sv.settings.sounds == false)
end

local function sounds_label(on)
  return on and GetString(VERMILION_SETTINGS_SOUNDS_ON) or GetString(VERMILION_SETTINGS_SOUNDS_OFF)
end

function M.on_autorec_click()
  local AR    = Vermilion.AutoRecord
  local modes = AR.modes()
  local cur   = AR.get_mode()
  local idx   = 1
  for i = 1, #modes do
    if modes[i] == cur then idx = i break end
  end
  local nxt = modes[(idx % #modes) + 1]
  Sound.play("page")
  AR.set_mode(nxt)
  controls.autorec_btn:SetText(autorec_label(nxt))
end

function M.on_autosave_click()
  local sv = Vermilion.SavedVars
  sv.settings = sv.settings or {}
  local now = not (sv.settings.session_autosave == true)
  sv.settings.session_autosave = now
  Sound.play(now and "on" or "off")
  controls.autosave_btn:SetText(autosave_label(now))
end

function M.on_autostop_click()
  local now = not Vermilion.AutoRecord.get_auto_stop()
  Vermilion.AutoRecord.set_auto_stop(now)
  Sound.play(now and "on" or "off")
  controls.autostop_btn:SetText(autostop_label(now))
end

function M.on_sounds_click()
  local sv = Vermilion.SavedVars
  sv.settings = sv.settings or {}
  local now = not sounds_on()
  sv.settings.sounds = now
  controls.sounds_btn:SetText(sounds_label(now))
  if now then Sound.play("confirm") end
end

function M.on_reset_click()
  log:info("reset to defaults")
  Sound.play("confirm")
  apply_values(SAMPLE_DEFAULT, TWINDOW_DEFAULT, VPALPHA_DEFAULT, CRITTHRESH_DEFAULT)
  current_profile = PROFILE_DEFAULT
  persist_profile(PROFILE_DEFAULT)
  local sv = Vermilion.SavedVars
  if sv and sv.settings then
    Vermilion.AutoRecord.set_mode("off")
    controls.autorec_btn:SetText(autorec_label("off"))
    sv.settings.session_autosave = false
    controls.autosave_btn:SetText(autosave_label(false))
    Vermilion.AutoRecord.set_auto_stop(false)
    controls.autostop_btn:SetText(autostop_label(false))
    sv.settings.sounds = nil
    controls.sounds_btn:SetText(sounds_label(true))
    sv.settings.light_mode = false
    sv.settings.light_alpha_pct = nil
    controls.light_btn:SetText(light_label(false))
    Vermilion.Graph.set_light_enabled(false)
  end
  current_lighta = LIGHTA_DEFAULT
  if profile_combo then
    profile_combo:SetSelectedItemText(profile_label_for(PROFILE_DEFAULT))
  end
  refresh_all_sliders()
end

function M.snapshot()
  local hz       = math_floor(1000 / current_sample)
  local capacity = current_twindow * hz
  return {
    profile_id          = current_profile,
    profile_label       = profile_label_for(current_profile),
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
    string.format("[config] profile=%s", s.profile_label),
    string.format("[config] graph: sample=%dms (%dHz) window=%ds capacity=%d%s",
      s.sample_rate_ms, s.sample_rate_hz, s.time_window_s, s.temporal_capacity, heavy),
    string.format("[config] viewport_alpha=%d%%  crit_threshold=%d%%", s.viewport_alpha_pct, s.crit_threshold_pct),
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
  current_profile    = profile_by_id(sv.settings.profile or PROFILE_DEFAULT) and (sv.settings.profile or PROFILE_DEFAULT) or PROFILE_DEFAULT

  reinit_buffer()
  Vermilion.Graph.set_crit_threshold(current_critthresh)

  controls.window         = VermilionSettingsPanel
  controls.window:SetHidden(true)
  Scene.register_top_level(controls.window)
  controls.window_title   = VermilionSettingsPanelWindowTitle
  controls.confirm        = VermilionSettingsConfirm
  controls.confirm_title  = VermilionSettingsConfirmTitle
  controls.confirm_msg    = VermilionSettingsConfirmMsg
  controls.confirm_yes    = VermilionSettingsConfirmYesBtn
  controls.confirm_no     = VermilionSettingsConfirmNoBtn
  controls.confirm:SetHidden(true)
  controls.confirm:SetDrawTier(DT_HIGH)
  VermilionSettingsConfirmBg:SetCenterColor(1.00, 0.62, 0.58, 1.0)
  VermilionSettingsConfirmBg:SetEdgeColor(1.00, 0.45, 0.40, 1.0)
  controls.confirm_title:SetColor(0.95, 0.55, 0.50, 1)
  controls.confirm_msg:SetColor(0.90, 0.90, 0.90, 1)

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
  controls.autorec_btn    = VermilionSettingsPanelAutoRecBtn
  controls.autosave_btn   = VermilionSettingsPanelAutosaveBtn
  controls.autostop_btn   = VermilionSettingsPanelAutoStopBtn
  controls.sounds_btn     = VermilionSettingsPanelSoundsBtn
  controls.light_btn      = VermilionSettingsPanelLightBtn
  controls.title_lighta   = VermilionSettingsPanelLightAlphaTitle
  controls.label_lighta   = VermilionSettingsPanelLightAlphaLabel
  controls.track_lighta   = VermilionSettingsPanelSliderTrackLightAlpha
  controls.profile_label  = VermilionSettingsPanelProfileLabel
  controls.profile_combo  = VermilionSettingsPanelProfileDropdown
  controls.pname_edit     = VermilionSettingsPanelPNameBoxEdit
  controls.psave_btn      = VermilionSettingsPanelPSaveBtn
  controls.pdelete_btn    = VermilionSettingsPanelPDeleteBtn

  zui.tooltip(controls.psave_btn,    VERMILION_TIP_PSAVE)
  zui.tooltip(controls.pdelete_btn,  VERMILION_TIP_PDELETE)
  zui.tooltip(controls.autorec_btn,  VERMILION_TIP_AUTOREC)
  zui.tooltip(controls.autosave_btn, VERMILION_TIP_AUTOSAVE)
  zui.tooltip(controls.autostop_btn, VERMILION_TIP_AUTOSTOP)
  zui.tooltip(controls.sounds_btn,   VERMILION_TIP_SOUNDS)
  zui.tooltip(controls.light_btn,    VERMILION_TIP_LIGHT)
  zui.tooltip(controls.unknown_btn,  VERMILION_TIP_UNKNOWN)
  zui.tooltip(controls.logo_btn,     VERMILION_TIP_LOGO)
  zui.tooltip(controls.reset_btn,    VERMILION_TIP_RESET)
  zui.tooltip(VermilionSettingsPanelCloseBtn, VERMILION_TIP_CLOSE)

  controls.psave_btn:SetText(GetString(VERMILION_SETTINGS_SAVE_PROFILE))
  controls.pdelete_btn:SetText(GetString(VERMILION_SETTINGS_DELETE_PROFILE))
  controls.pname_edit:SetDefaultText(GetString(VERMILION_PROFILE_NAME_DEFAULT))
  controls.pname_edit:SetDefaultTextColor(0.70, 0.62, 0.62, 0.45)
  VermilionSettingsPanelPNameBox:SetCenterColor(0, 0, 0, 0)
  M.on_pname_focus(false)

  controls.window_title:SetText(GetString(VERMILION_SETTINGS_TITLE))
  VermilionSettingsPanelVersionLabel:SetText("v" .. Vermilion.Constants.VERSION)
  VermilionSettingsPanelVersionLabel:SetColor(0.55, 0.46, 0.45, 0.9)
  controls.reset_btn:SetText(GetString(VERMILION_SETTINGS_RESET))
  controls.profile_label:SetText(GetString(VERMILION_SETTINGS_PROFILE))
  controls.profile_label:SetColor(0.75, 0.75, 0.75, 1)
  M.refresh_unknown_count()
  controls.unknown_label:SetColor(0.80, 0.80, 0.80, 1)

  local SEC = {
    { VermilionSettingsPanelSecProfile,   VermilionSettingsPanelSepProfile,   VERMILION_SETTINGS_SEC_PROFILE },
    { VermilionSettingsPanelSecGraph,     VermilionSettingsPanelSepGraph,     VERMILION_SETTINGS_SEC_GRAPH },
    { VermilionSettingsPanelSecRecording, VermilionSettingsPanelSepRecording, VERMILION_SETTINGS_SEC_RECORDING },
    { VermilionSettingsPanelSecGeneral,   VermilionSettingsPanelSepGeneral,   VERMILION_SETTINGS_SEC_GENERAL },
  }
  for _, sec in ipairs(SEC) do
    sec[1]:SetText(GetString(sec[3]))
    sec[1]:SetColor(0.95, 0.42, 0.34, 0.90)
    sec[2]:SetTexture(FILL_TEXTURE)
    sec[2]:SetTextureCoords(0, 1, 0, 0.05)
    sec[2]:SetColor(0.95, 0.42, 0.34, 0.22)
  end
  VermilionSettingsPanelSepColumns:SetTexture(FILL_TEXTURE)
  VermilionSettingsPanelSepColumns:SetTextureCoords(0, 0.05, 0, 1)
  VermilionSettingsPanelSepColumns:SetColor(0.95, 0.42, 0.34, 0.12)

  controls.logo_btn:SetText(Vermilion.Logo.is_enabled()
    and GetString(VERMILION_SETTINGS_LOGO_ON) or GetString(VERMILION_SETTINGS_LOGO_OFF))
  controls.autorec_btn:SetText(autorec_label(sv.settings.auto_record or "off"))
  controls.autosave_btn:SetText(autosave_label(sv.settings.session_autosave == true))
  controls.autostop_btn:SetText(autostop_label(sv.settings.auto_stop == true))
  controls.sounds_btn:SetText(sounds_label(sounds_on()))
  controls.light_btn:SetText(light_label(sv.settings.light_mode == true))
  current_lighta = LIGHTA_PRESETS[nearest_idx(LIGHTA_PRESETS, sv.settings.light_alpha_pct or LIGHTA_DEFAULT)]

  profile_combo = ZO_ComboBox_ObjectFromContainer(controls.profile_combo)
  profile_combo:SetSortsItems(false)
  rebuild_profile_combo()

  for _, k in ipairs({ "sample", "twindow", "vpalpha", "critthresh", "lighta" }) do
    controls["title_" .. k]:SetColor(0.75, 0.75, 0.75, 1)
    controls["label_" .. k]:SetColor(0.95, 0.80, 0.20, 1)
  end
  controls.title_sample:SetText(GetString(VERMILION_SETTING_SAMPLE_RATE))
  controls.title_twindow:SetText(GetString(VERMILION_SETTING_TIME_WINDOW))
  controls.title_vpalpha:SetText(GetString(VERMILION_SETTING_VIEWPORT_ALPHA))
  controls.title_critthresh:SetText(GetString(VERMILION_SETTING_CRIT_THRESHOLD))
  controls.title_lighta:SetText(GetString(VERMILION_SETTING_LIGHT_ALPHA))

  local c = controls
  c.fill_sample,  c.thumb_sample  = setup_slider_visuals(c.track_sample,  "VermilionSettingsSample")
  c.fill_twindow, c.thumb_twindow = setup_slider_visuals(c.track_twindow, "VermilionSettingsTWindow")
  c.fill_vpalpha, c.thumb_vpalpha = setup_slider_visuals(c.track_vpalpha, "VermilionSettingsVPAlpha")
  c.fill_critthresh, c.thumb_critthresh = setup_slider_visuals(c.track_critthresh, "VermilionSettingsCritThresh")
  c.fill_lighta, c.thumb_lighta = setup_slider_visuals(c.track_lighta, "VermilionSettingsLightA")

  if sv.settings.x and sv.settings.y then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.x, sv.settings.y)
  else
    controls.window:ClearAnchors()
    controls.window:SetAnchor(zc.CENTER, GuiRoot, zc.CENTER, 0, 0)
  end

  for _, line in ipairs(M.report_lines()) do log:info(line) end
end
