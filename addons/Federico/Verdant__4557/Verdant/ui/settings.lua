Verdant = Verdant or {}
local Verdant = Verdant

Verdant.Settings = {}
local M = Verdant.Settings

local api = Verdant.zenimax.api
local zui = Verdant.zenimax.ui
local PlaySound = zui.PlaySound
local zc  = Verdant.zenimax.constants
local Scene = Verdant.zenimax.scene
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
  end
  for s = 660, 1200, 60 do
    p[#p + 1] = s
  end
  for _, s in ipairs(p) do
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

local LIGHTA_PRESETS = {}
local LIGHTA_LABELS  = {}
for pct = 10, 90, 5 do
  LIGHTA_PRESETS[#LIGHTA_PRESETS + 1] = pct
  LIGHTA_LABELS[pct] = pct .. "%"
end
local LIGHTA_DEFAULT = 40

local THETA_PRESETS = {}
local THETA_LABELS  = {}
for pct = 30, 75, 5 do
  THETA_PRESETS[#THETA_PRESETS + 1] = pct
  THETA_LABELS[pct] = pct .. "%"
end
local THETA_DEFAULT = 50

local USER_PREFIX = "user:"

local function is_user_profile(id)
  return type(id) == "string" and id:sub(1, #USER_PREFIX) == USER_PREFIX
end

local function user_profile_name(id)
  return id:sub(#USER_PREFIX + 1)
end

local function profile_label_for(id)
  if is_user_profile(id) then return "* " .. user_profile_name(id) end
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

local function user_profiles()
  local sv = Verdant.SavedVars
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
  if is_user_profile(id) then
    local up = user_profiles()
    local vals = up and up[user_profile_name(id)]
    if vals then
      return { id = id, rate = vals.rate, heal = vals.heal, shield = vals.shield,
               sample = vals.sample, twindow = vals.twindow }
    end
    return nil
  end
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
local current_theta   = THETA_DEFAULT
local current_lighta  = LIGHTA_DEFAULT
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

local C_FILL_OK     = { 0.40, 0.82, 0.50, 0.92 }
local C_FILL_HEAVY  = { 0.92, 0.30, 0.28, 0.92 }
local C_LABEL_OK    = { 0.75, 0.75, 0.75, 1 }
local C_LABEL_HEAVY = { 1.00, 0.45, 0.42, 1 }

local function capacity_of(sample_ms, twindow_s)
  return twindow_s * math_floor(1000 / sample_ms)
end

local function is_heavy(sample_ms, twindow_s)
  return capacity_of(sample_ms, twindow_s) > CAPACITY_WARN_THRESHOLD
end

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
  PlaySound(SOUNDS.NEGATIVE_CLICK)
end

local function ask_heavy(prev_sample, prev_twindow)
  local was_heavy = is_heavy(prev_sample, prev_twindow)
  local heavy = is_heavy(current_sample, current_twindow)
  if not heavy then return end
  if was_heavy and capacity_of(current_sample, current_twindow) <= capacity_of(prev_sample, prev_twindow) then return end
  confirm.prev_sample  = prev_sample
  confirm.prev_twindow = prev_twindow
  local hz = math_floor(1000 / current_sample)
  show_confirm("heavy", VERDANT_SETTINGS_HEAVY_TITLE,
    string.format(GetString(VERDANT_SETTINGS_HEAVY_MSG), TWINDOW_LABELS[current_twindow] or (current_twindow .. "s"), hz,
      capacity_of(current_sample, current_twindow)),
    VERDANT_SETTINGS_HEAVY_YES, VERDANT_SETTINGS_HEAVY_NO)
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
  update_slider(c.track_triage,  c.fill_triage,  c.thumb_triage,  c.label_triage,  THETA_PRESETS,   THETA_LABELS,   current_theta)
  update_slider(c.track_lighta,  c.fill_lighta,  c.thumb_lighta,  c.label_lighta,  LIGHTA_PRESETS,  LIGHTA_LABELS,  current_lighta)
  tint_temporal()
end

function M.refresh_unknown_count()
  local n = (Verdant.SkillColors and Verdant.SkillColors.unknown_count
             and Verdant.SkillColors.unknown_count()) or 0
  local text = GetString(VERDANT_SETTINGS_UNKNOWN)
  if n > 0 then text = text .. " (" .. n .. ")" end
  controls.unknown_label:SetText(text)
end

local function dock_window()
  local win = controls.window
  local host = VerdantGraphWindow
  if not host or host:IsHidden() then host = VerdantBarWindow end
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
    PlaySound(SOUNDS.ARMORY_OPEN)
  else
    Scene.hide_top_level(win)
    controls.confirm:SetHidden(true)
    confirm.kind = nil
    PlaySound(SOUNDS.ADVENTURE_ZONE_OVERVIEW_CLOSED)
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

local function sounds_on()
  local sv = Verdant.SavedVars
  return not (sv and sv.settings and sv.settings.sounds == false)
end

function M.on_sounds_click()
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  local now = not sounds_on()
  sv.settings.sounds = now
  controls.sounds_btn:SetText(now and GetString(VERDANT_SETTINGS_SOUNDS_ON)
                                   or GetString(VERDANT_SETTINGS_SOUNDS_OFF))
  if now then PlaySound(SOUNDS.DIALOG_ACCEPT) end
end

function M.on_bars_click()
  local now = not Verdant.Visibility.is_bar_enabled()
  Verdant.Visibility.set_bar_enabled(now)
  controls.bars_btn:SetText(now and GetString(VERDANT_SETTINGS_BARS_ON)
                                 or GetString(VERDANT_SETTINGS_BARS_OFF))
end

function M.on_light_click()
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  local now = not (sv.settings.light_mode == true)
  sv.settings.light_mode = now
  controls.light_btn:SetText(now and GetString(VERDANT_SETTINGS_LIGHT_ON)
                                 or GetString(VERDANT_SETTINGS_LIGHT_OFF))
  Verdant.Graph.set_light_enabled(now)
end

function M.on_lightalpha_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#LIGHTA_PRESETS, math_floor(pct * (#LIGHTA_PRESETS - 1) + 0.5) + 1))
  current_lighta = LIGHTA_PRESETS[idx]
  log:info("light_alpha ->", current_lighta, "%")
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  sv.settings.light_alpha_pct = current_lighta
  Verdant.Graph.set_light_alpha(current_lighta / 100)
  update_slider(controls.track_lighta, controls.fill_lighta, controls.thumb_lighta, controls.label_lighta, LIGHTA_PRESETS, LIGHTA_LABELS, current_lighta)
end

function M.on_autosave_click()
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  local now = not (sv.settings.session_autosave == true)
  sv.settings.session_autosave = now
  controls.autosave_btn:SetText(now and GetString(VERDANT_SETTINGS_AUTOSAVE_ON)
                                    or GetString(VERDANT_SETTINGS_AUTOSAVE_OFF))
end

function M.on_gdm_click()
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  local now = not (sv.settings.group_death_markers == true)
  sv.settings.group_death_markers = now
  controls.gdm_btn:SetText(now and GetString(VERDANT_SETTINGS_GDM_ON)
                               or GetString(VERDANT_SETTINGS_GDM_OFF))
end

local SHIELDDIR_LABEL = {
  [true]  = GetString(VERDANT_SETTINGS_SHIELD_DOWN),
  [false] = GetString(VERDANT_SETTINGS_SHIELD_UP),
}

local function autorec_label(m)
  if m == "boss"   then return GetString(VERDANT_SETTINGS_AUTOREC_BOSS)   end
  if m == "combat" then return GetString(VERDANT_SETTINGS_AUTOREC_COMBAT) end
  return GetString(VERDANT_SETTINGS_AUTOREC_OFF)
end

function M.on_autorec_click()
  local AR    = Verdant.AutoRecord
  local modes = AR.modes()
  local cur   = AR.get_mode()
  local idx   = 1
  for i = 1, #modes do
    if modes[i] == cur then idx = i break end
  end
  local nxt = modes[(idx % #modes) + 1]
  AR.set_mode(nxt)
  controls.autorec_btn:SetText(autorec_label(nxt))
end

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

local function rebuild_profile_combo()
  if not profile_combo then return end
  profile_combo:ClearItems()
  for _, p in ipairs(PROFILES) do
    local id = p.id
    local entry = profile_combo:CreateItemEntry(profile_label_for(id),
      function() M.on_profile_selected(id) end)
    profile_combo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  end
  for _, name in ipairs(user_profile_names_sorted()) do
    local id = USER_PREFIX .. name
    local entry = profile_combo:CreateItemEntry(profile_label_for(id),
      function() M.on_profile_selected(id) end)
    profile_combo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
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
    d("[V] " .. GetString(VERDANT_PROFILE_NAME_HINT))
    return
  end
  name = name:sub(1, 20)
  up[name] = {
    rate    = current_rate,
    heal    = current_heal,
    shield  = current_shield,
    sample  = current_sample,
    twindow = current_twindow,
  }
  current_profile = USER_PREFIX .. name
  persist_profile(current_profile)
  controls.pname_edit:SetText("")
  rebuild_profile_combo()
  log:info("user profile saved:", name)
  d("[V] " .. string.format(GetString(VERDANT_PROFILE_SAVED), name))
end

function M.on_profile_delete_click()
  if not is_user_profile(current_profile) then
    d("[V] " .. GetString(VERDANT_PROFILE_DELETE_HINT))
    return
  end
  show_confirm("pdelete", VERDANT_SETTINGS_PDEL_TITLE,
    string.format(GetString(VERDANT_SETTINGS_PDEL_MSG), user_profile_name(current_profile)),
    VERDANT_SETTINGS_PDEL_YES, VERDANT_SETTINGS_PDEL_NO)
end

local function delete_profile_now()
  if not is_user_profile(current_profile) then return end
  local up = user_profiles()
  if not up then return end
  local name = user_profile_name(current_profile)
  up[name] = nil
  current_profile = "custom"
  persist_profile("custom")
  rebuild_profile_combo()
  log:info("user profile deleted:", name)
  d("[V] " .. string.format(GetString(VERDANT_PROFILE_DELETED), name))
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
  local prev_sample, prev_twindow = current_sample, current_twindow
  current_sample = SAMPLE_PRESETS[idx]
  log:info("sample_rate ->", current_sample, "ms")
  persist_temporal("sample_rate_ms", current_sample)
  reinit_buffer()
  mark_custom()
  update_slider(controls.track_sample, controls.fill_sample, controls.thumb_sample, controls.label_sample, SAMPLE_PRESETS, SAMPLE_LABELS, current_sample)
  tint_temporal()
  ask_heavy(prev_sample, prev_twindow)
end

function M.on_twindow_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#TWINDOW_PRESETS, math_floor(pct * (#TWINDOW_PRESETS - 1) + 0.5) + 1))
  local prev_sample, prev_twindow = current_sample, current_twindow
  current_twindow = TWINDOW_PRESETS[idx]
  log:info("time_window ->", current_twindow, "s")
  persist_temporal("time_window_s", current_twindow)
  reinit_buffer()
  mark_custom()
  update_slider(controls.track_twindow, controls.fill_twindow, controls.thumb_twindow, controls.label_twindow, TWINDOW_PRESETS, TWINDOW_LABELS, current_twindow)
  tint_temporal()
  ask_heavy(prev_sample, prev_twindow)
end

function M.on_confirm_yes()
  local kind = confirm.kind
  confirm.kind = nil
  controls.confirm:SetHidden(true)
  PlaySound(SOUNDS.DIALOG_ACCEPT)
  if kind == "pdelete" then delete_profile_now() end
end

function M.on_confirm_no()
  local kind = confirm.kind
  confirm.kind = nil
  controls.confirm:SetHidden(true)
  PlaySound(SOUNDS.DIALOG_DECLINE)
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
  local box = VerdantSettingsPanelPNameBox
  if on then
    box:SetEdgeColor(0.62, 1.00, 0.74, 0.95)
    if controls.pname_edit.SelectAll then controls.pname_edit:SelectAll() end
  else
    box:SetEdgeColor(0.42, 1.00, 0.60, 0.45)
  end
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

function M.on_triage_track_click(control)
  local cx      = GetUIMousePosition()
  local track_w = control:GetWidth()
  if track_w <= 0 then return end
  local pct = math_max(0, math_min(1, (cx - control:GetLeft()) / track_w))
  local idx = math_max(1, math_min(#THETA_PRESETS, math_floor(pct * (#THETA_PRESETS - 1) + 0.5) + 1))
  current_theta = THETA_PRESETS[idx]
  log:info("triage_theta ->", current_theta, "%")
  local sv = Verdant.SavedVars
  sv.settings = sv.settings or {}
  sv.settings.triage_theta = current_theta / 100
  update_slider(controls.track_triage, controls.fill_triage, controls.thumb_triage, controls.label_triage, THETA_PRESETS, THETA_LABELS, current_theta)
end

function M.on_reset_click()
  log:info("reset to defaults")
  apply_profile(PROFILE_DEFAULT)

  current_vpalpha = VPALPHA_DEFAULT
  persist_temporal("viewport_alpha_pct", current_vpalpha)
  Verdant.Graph.set_viewport_alpha(current_vpalpha / 100)

  local sv = Verdant.SavedVars
  if sv and sv.settings then
    sv.settings.group_death_markers = false
    controls.gdm_btn:SetText(GetString(VERDANT_SETTINGS_GDM_OFF))
    sv.settings.triage_theta = nil
    sv.settings.session_autosave = false
    controls.autosave_btn:SetText(GetString(VERDANT_SETTINGS_AUTOSAVE_OFF))
    sv.settings.light_mode = false
    sv.settings.light_alpha_pct = nil
    controls.light_btn:SetText(GetString(VERDANT_SETTINGS_LIGHT_OFF))
    Verdant.Graph.set_light_enabled(false)
  end
  current_theta = THETA_DEFAULT
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
  Scene.register_top_level(controls.window)
  controls.confirm        = VerdantSettingsConfirm
  controls.confirm_title  = VerdantSettingsConfirmTitle
  controls.confirm_msg    = VerdantSettingsConfirmMsg
  controls.confirm_yes    = VerdantSettingsConfirmYesBtn
  controls.confirm_no     = VerdantSettingsConfirmNoBtn
  controls.confirm:SetDrawTier(DT_HIGH)
  VerdantSettingsConfirmBg:SetCenterColor(0.62, 1.00, 0.74, 1.0)
  VerdantSettingsConfirmBg:SetEdgeColor(0.42, 1.00, 0.60, 1.0)
  controls.confirm_title:SetColor(0.55, 0.85, 0.55, 1)
  controls.confirm_msg:SetColor(0.90, 0.90, 0.90, 1)

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
  controls.title_triage   = VerdantSettingsPanelTriageTitle
  controls.label_triage   = VerdantSettingsPanelTriageLabel
  controls.track_triage   = VerdantSettingsPanelSliderTrackTriage
  controls.title_lighta   = VerdantSettingsPanelLightAlphaTitle
  controls.label_lighta   = VerdantSettingsPanelLightAlphaLabel
  controls.track_lighta   = VerdantSettingsPanelSliderTrackLightAlpha
  controls.light_btn      = VerdantSettingsPanelLightBtn
  controls.window_title   = VerdantSettingsPanelWindowTitle
  controls.reset_btn      = VerdantSettingsPanelResetBtn
  controls.profile_label  = VerdantSettingsPanelProfileLabel
  controls.profile_combo  = VerdantSettingsPanelProfileDropdown
  controls.unknown_btn    = VerdantSettingsPanelUnknownBtn
  controls.unknown_label  = VerdantSettingsPanelUnknownLabel
  controls.logo_btn       = VerdantSettingsPanelLogoBtn
  controls.bars_btn       = VerdantSettingsPanelBarsBtn
  controls.shielddir_btn  = VerdantSettingsPanelShieldDirBtn
  controls.autorec_btn    = VerdantSettingsPanelAutoRecBtn
  controls.gdm_btn        = VerdantSettingsPanelGdmBtn
  controls.autosave_btn   = VerdantSettingsPanelAutosaveBtn
  controls.pname_edit     = VerdantSettingsPanelPNameBoxEdit
  controls.psave_btn      = VerdantSettingsPanelPSaveBtn
  controls.pdelete_btn    = VerdantSettingsPanelPDeleteBtn
  controls.sounds_btn     = VerdantSettingsPanelSoundsBtn
  zui.tooltip(controls.psave_btn,     VERDANT_TIP_PSAVE)
  zui.tooltip(controls.pdelete_btn,   VERDANT_TIP_PDELETE)
  zui.tooltip(controls.autorec_btn,   VERDANT_TIP_AUTOREC)
  zui.tooltip(controls.autosave_btn,  VERDANT_TIP_AUTOSAVE)
  zui.tooltip(controls.light_btn,     VERDANT_TIP_LIGHT)
  zui.tooltip(controls.shielddir_btn, VERDANT_TIP_SHIELDDIR)
  zui.tooltip(controls.gdm_btn,       VERDANT_TIP_GDM)
  zui.tooltip(controls.unknown_btn,   VERDANT_TIP_UNKNOWN)
  zui.tooltip(controls.logo_btn,      VERDANT_TIP_LOGO)
  zui.tooltip(controls.bars_btn,      VERDANT_TIP_BARS)
  zui.tooltip(controls.reset_btn,     VERDANT_TIP_RESET)
  zui.tooltip(controls.sounds_btn,    VERDANT_TIP_SOUNDS)
  zui.tooltip(VerdantSettingsPanelCloseBtn, VERDANT_TIP_CLOSE)
  controls.psave_btn:SetText(GetString(VERDANT_SETTINGS_SAVE_PROFILE))
  controls.pdelete_btn:SetText(GetString(VERDANT_SETTINGS_DELETE_PROFILE))
  controls.pname_edit:SetDefaultText(GetString(VERDANT_PROFILE_NAME_DEFAULT))
  controls.pname_edit:SetDefaultTextColor(0.62, 0.70, 0.64, 0.45)
  VerdantSettingsPanelPNameBox:SetCenterColor(0, 0, 0, 0)
  M.on_pname_focus(false)

  controls.window_title:SetText(GetString(VERDANT_SETTINGS_TITLE))
  VerdantSettingsPanelVersionLabel:SetText("v" .. Verdant.Constants.VERSION)
  VerdantSettingsPanelVersionLabel:SetColor(0.45, 0.50, 0.46, 0.9)
  controls.reset_btn:SetText(GetString(VERDANT_SETTINGS_RESET))
  controls.profile_label:SetText(GetString(VERDANT_SETTINGS_PROFILE))
  controls.profile_label:SetColor(0.75, 0.75, 0.75, 1)

  M.refresh_unknown_count()
  controls.unknown_label:SetColor(0.80, 0.80, 0.80, 1)

  local SEC = {
    { VerdantSettingsPanelSecProfile,   VerdantSettingsPanelSepProfile,   VERDANT_SETTINGS_SEC_PROFILE },
    { VerdantSettingsPanelSecBar,       VerdantSettingsPanelSepBar,       VERDANT_SETTINGS_SEC_BAR },
    { VerdantSettingsPanelSecGraph,     VerdantSettingsPanelSepGraph,     VERDANT_SETTINGS_SEC_GRAPH },
    { VerdantSettingsPanelSecRecording, VerdantSettingsPanelSepRecording, VERDANT_SETTINGS_SEC_RECORDING },
    { VerdantSettingsPanelSecGeneral,   VerdantSettingsPanelSepGeneral,   VERDANT_SETTINGS_SEC_GENERAL },
  }
  for _, sec in ipairs(SEC) do
    sec[1]:SetText(GetString(sec[3]))
    sec[1]:SetColor(0.46, 0.86, 0.58, 0.90)
    sec[2]:SetTexture("EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds")
    sec[2]:SetTextureCoords(0, 1, 0, 0.05)
    sec[2]:SetColor(0.46, 0.86, 0.58, 0.22)
  end
  VerdantSettingsPanelSepColumns:SetTexture(FILL_TEXTURE)
  VerdantSettingsPanelSepColumns:SetTextureCoords(0, 0.05, 0, 1)
  VerdantSettingsPanelSepColumns:SetColor(0.46, 0.86, 0.58, 0.12)
  controls.logo_btn:SetText(Verdant.Logo.is_enabled()
    and GetString(VERDANT_SETTINGS_LOGO_ON) or GetString(VERDANT_SETTINGS_LOGO_OFF))
  controls.sounds_btn:SetText(sounds_on()
    and GetString(VERDANT_SETTINGS_SOUNDS_ON) or GetString(VERDANT_SETTINGS_SOUNDS_OFF))

  local bars_on = not (Verdant.SavedVars and Verdant.SavedVars.bar
                       and Verdant.SavedVars.bar.enabled == false)
  controls.bars_btn:SetText(bars_on and GetString(VERDANT_SETTINGS_BARS_ON)
                                     or GetString(VERDANT_SETTINGS_BARS_OFF))

  local shield_down = (sv.settings.shield_down == true)
  controls.shielddir_btn:SetText(SHIELDDIR_LABEL[shield_down])
  controls.autorec_btn:SetText(autorec_label(sv.settings.auto_record or "off"))
  controls.gdm_btn:SetText((sv.settings.group_death_markers == true)
    and GetString(VERDANT_SETTINGS_GDM_ON) or GetString(VERDANT_SETTINGS_GDM_OFF))
  controls.autosave_btn:SetText((sv.settings.session_autosave == true)
    and GetString(VERDANT_SETTINGS_AUTOSAVE_ON) or GetString(VERDANT_SETTINGS_AUTOSAVE_OFF))
  controls.light_btn:SetText((sv.settings.light_mode == true)
    and GetString(VERDANT_SETTINGS_LIGHT_ON) or GetString(VERDANT_SETTINGS_LIGHT_OFF))
  current_lighta = LIGHTA_PRESETS[nearest_idx(LIGHTA_PRESETS, sv.settings.light_alpha_pct or LIGHTA_DEFAULT)]
  Verdant.Graph.set_shield_down(shield_down)

  profile_combo = ZO_ComboBox_ObjectFromContainer(controls.profile_combo)
  profile_combo:SetSortsItems(false)
  rebuild_profile_combo()

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

  controls.title_triage:SetText(GetString(VERDANT_SETTING_TRIAGE_THETA))
  controls.title_triage:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_triage:SetColor(0.95, 0.80, 0.20, 1)

  controls.title_lighta:SetText(GetString(VERDANT_SETTING_LIGHT_ALPHA))
  controls.title_lighta:SetColor(0.75, 0.75, 0.75, 1)
  controls.label_lighta:SetColor(0.95, 0.80, 0.20, 1)

  if sv.settings.triage_theta then
    current_theta = math_floor(sv.settings.triage_theta * 100 + 0.5)
  end

  local c = controls
  c.fill_rate,    c.thumb_rate    = setup_slider_visuals(c.track_rate,    "VerdantSettingsRate")
  c.fill_heal,    c.thumb_heal    = setup_slider_visuals(c.track_heal,    "VerdantSettingsHeal")
  c.fill_shield,  c.thumb_shield  = setup_slider_visuals(c.track_shield,  "VerdantSettingsShield")
  c.fill_sample,  c.thumb_sample  = setup_slider_visuals(c.track_sample,  "VerdantSettingsSample")
  c.fill_twindow, c.thumb_twindow = setup_slider_visuals(c.track_twindow, "VerdantSettingsTWindow")
  c.fill_vpalpha, c.thumb_vpalpha = setup_slider_visuals(c.track_vpalpha, "VerdantSettingsVPAlpha")
  c.fill_triage,  c.thumb_triage  = setup_slider_visuals(c.track_triage,  "VerdantSettingsTriage")
  c.fill_lighta,  c.thumb_lighta  = setup_slider_visuals(c.track_lighta,  "VerdantSettingsLightA")

  if sv.settings.x and sv.settings.y then
    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.settings.x, sv.settings.y)
  else
    controls.window:ClearAnchors()
    controls.window:SetAnchor(zc.CENTER, GuiRoot, zc.CENTER, 0, 0)
  end

  for _, line in ipairs(M.report_lines()) do log:info(line) end
end
