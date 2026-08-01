CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.UI = {}

local ZO_CheckButton_IsChecked        = ZO_CheckButton_IsChecked
local ZO_CheckButton_SetCheckState    = ZO_CheckButton_SetCheckState
local ZO_CheckButton_SetToggleFunction = ZO_CheckButton_SetToggleFunction
local ZO_AlphaAnimation               = ZO_AlphaAnimation
local PlaySound                       = PlaySound

local M = CDescriptor.UI
local C
local Controls = {}

function M.init()
  C = CDescriptor.Constants
  local names = C.CONTROLS
  Controls.window    = _G[names.WINDOW]
  Controls.output    = _G[names.OUTPUT_BOX]
  Controls.scrollbar = _G[names.SCROLLBAR]
  Controls.status    = _G[names.STATUS_LABEL]
  Controls.generate  = _G[names.GENERATE_BUTTON]
  Controls.copy      = _G[names.COPY_BUTTON]
  Controls.clear     = _G[names.CLEAR_BUTTON]
  Controls.check_sets     = _G[names.CHECK_SETS]
  Controls.check_stats    = _G[names.CHECK_STATS]
  Controls.check_buffs    = _G[names.CHECK_BUFFS]
  Controls.check_passives = _G[names.CHECK_PASSIVES]
  Controls.check_cp       = _G[names.CHECK_CP]
  Controls.check_prompt   = _G[names.CHECK_PROMPT]

  Controls.generate:SetText(C.UI.GENERATE_BUTTON)
  Controls.copy:SetText(C.UI.COPY_BUTTON)
  Controls.clear:SetText(C.UI.CLEAR_BUTTON)
  Controls.output:SetFont("ZoFontChat")

  -- Set checkbox labels
  _G[names.CHECK_SETS     .. "Label"]:SetText(C.UI.CHECK_SETS_LABEL)
  _G[names.CHECK_STATS    .. "Label"]:SetText(C.UI.CHECK_STATS_LABEL)
  _G[names.CHECK_BUFFS    .. "Label"]:SetText(C.UI.CHECK_BUFFS_LABEL)
  _G[names.CHECK_PASSIVES .. "Label"]:SetText(C.UI.CHECK_PASSIVES_LABEL)
  _G[names.CHECK_CP       .. "Label"]:SetText(C.UI.CHECK_CP_LABEL)
  _G[names.CHECK_PROMPT   .. "Label"]:SetText(C.UI.CHECK_PROMPT_LABEL)

  -- Restore saved checkbox states
  local SV = C.SAVED_VARS
  ZO_CheckButton_SetCheckState(Controls.check_sets,     CDescriptor.Settings.get(SV.INCLUDE_SETS))
  ZO_CheckButton_SetCheckState(Controls.check_stats,    CDescriptor.Settings.get(SV.INCLUDE_STATS))
  ZO_CheckButton_SetCheckState(Controls.check_buffs,    CDescriptor.Settings.get(SV.INCLUDE_BUFFS))
  ZO_CheckButton_SetCheckState(Controls.check_passives, CDescriptor.Settings.get(SV.INCLUDE_PASSIVES))
  ZO_CheckButton_SetCheckState(Controls.check_cp,       CDescriptor.Settings.get(SV.INCLUDE_CP))
  ZO_CheckButton_SetCheckState(Controls.check_prompt,   CDescriptor.Settings.get(SV.INCLUDE_PROMPT))

  -- Persist state on click
  ZO_CheckButton_SetToggleFunction(Controls.check_sets,     function(_, checked) M.on_checkbox_changed(SV.INCLUDE_SETS,     checked) end)
  ZO_CheckButton_SetToggleFunction(Controls.check_stats,    function(_, checked) M.on_checkbox_changed(SV.INCLUDE_STATS,    checked) end)
  ZO_CheckButton_SetToggleFunction(Controls.check_buffs,    function(_, checked) M.on_checkbox_changed(SV.INCLUDE_BUFFS,    checked) end)
  ZO_CheckButton_SetToggleFunction(Controls.check_passives, function(_, checked) M.on_checkbox_changed(SV.INCLUDE_PASSIVES, checked) end)
  ZO_CheckButton_SetToggleFunction(Controls.check_cp,       function(_, checked) M.on_checkbox_changed(SV.INCLUDE_CP,       checked) end)
  ZO_CheckButton_SetToggleFunction(Controls.check_prompt,   function(_, checked) M.on_prompt_checkbox_changed(checked)              end)

  local ver_label = _G[names.VERSION_LABEL]
  if ver_label then
    ver_label:SetText("API " .. tostring(GetAPIVersion()) .. "  ·  CDescriptor v" .. C.VERSION)
  end

  Controls.scrollbar:SetMinMax(1, 1)
  Controls.scrollbar:SetValue(1)

  local w = CDescriptor.Settings.get(SV.WINDOW_W)
  local h = CDescriptor.Settings.get(SV.WINDOW_H)
  if w and h then Controls.window:SetDimensions(w, h) end
  Controls.window:SetDimensionConstraints(450, 460, 0, 0)

  CDescriptor.PromptUI.init()

  if CDescriptor.Settings.get(SV.INCLUDE_PROMPT) then
    Controls.window:SetDimensionConstraints(450, 560, 0, 0)
    CDescriptor.PromptUI.show()
  end
end

local status_pulse = nil

local function set_status(msg, highlight)
  if status_pulse then
    status_pulse:Stop()
    status_pulse = nil
    Controls.status:SetAlpha(1)
  end
  Controls.status:SetText(msg or "")
  if highlight then
    Controls.status:SetColor(0.3, 1, 0.3, 1)    -- green
    status_pulse = ZO_AlphaAnimation:New(Controls.status)
    status_pulse:SetMinMaxAlpha(0.4, 1)
    status_pulse:PingPong(0, 1, 500, 4)          -- 500ms per half-cycle, 4 loops
  else
    Controls.status:SetColor(0.7, 0.7, 0.7, 1)  -- default gray
  end
end

local function set_output(text)
  Controls.output:SetText(text)
end

local function update_scrollbar()
  local extents = Controls.output:GetScrollExtents()
  if extents and extents > 0 then
    Controls.scrollbar:SetMinMax(1, 1 + extents)
    Controls.scrollbar:SetValue(1)
    Controls.scrollbar:SetHidden(false)
  else
    Controls.scrollbar:SetHidden(true)
  end
end

function M.on_checkbox_changed(saved_var_key, checked)
  CDescriptor.Settings.set(saved_var_key, checked)
end

function M.on_prompt_checkbox_changed(checked)
  CDescriptor.Settings.set(C.SAVED_VARS.INCLUDE_PROMPT, checked)
  if checked then
    Controls.window:SetDimensionConstraints(450, 560, 0, 0)
    CDescriptor.PromptUI.show()
  else
    Controls.window:SetDimensionConstraints(450, 460, 0, 0)
    CDescriptor.PromptUI.hide()
  end
end

function M.on_generate()
  PlaySound(SOUNDS.DIALOG_ACCEPT)
  set_status(C.UI.STATUS_EXTRACT)
  set_output(C.UI.STATUS_IDLE)

  local adapters = {
    character = CDescriptor.Adapters.Character,
    skills    = CDescriptor.Adapters.Skills,
    gear      = CDescriptor.Adapters.Gear,
    sets      = CDescriptor.Adapters.Sets,
    stats     = CDescriptor.Adapters.Stats,
    buffs     = CDescriptor.Adapters.Buffs,
    passives        = CDescriptor.Adapters.Passives,
    champion_points = CDescriptor.Adapters.ChampionPoints,
  }

  local ok, raw = pcall(CDescriptor.Extractor.extract, adapters)
  if not ok then
    set_status(C.UI.STATUS_ERROR .. tostring(raw))
    return
  end

  local config = {
    include_sets     = ZO_CheckButton_IsChecked(Controls.check_sets),
    include_stats    = ZO_CheckButton_IsChecked(Controls.check_stats),
    include_buffs    = ZO_CheckButton_IsChecked(Controls.check_buffs),
    include_passives = ZO_CheckButton_IsChecked(Controls.check_passives),
    include_cp       = ZO_CheckButton_IsChecked(Controls.check_cp),
  }

  local ok2, transformed = pcall(CDescriptor.Transformer.transform, raw, config)
  if not ok2 then
    set_status(C.UI.STATUS_ERROR .. tostring(transformed))
    return
  end

  local prompt_text = nil
  if ZO_CheckButton_IsChecked(Controls.check_prompt) then
    local settings = CDescriptor.PromptUI.build_prompt_settings()
    prompt_text = CDescriptor.Prompt.build_prompt(settings)
  end

  local ok3, output_str = pcall(CDescriptor.Serializer.serialize, transformed, prompt_text)
  if not ok3 then
    set_status(C.UI.STATUS_ERROR .. tostring(output_str))
    return
  end

  set_output(output_str)
  update_scrollbar()
  set_status("Done. (" .. #output_str .. " chars)")
end

function M.on_clear()
  PlaySound(SOUNDS.CHAMPION_STAR_SLOT_CLEARED)
  set_output("")
  set_status(C.UI.STATUS_IDLE)
  Controls.scrollbar:SetHidden(true)
end

function M.on_copy()
  PlaySound(SOUNDS.NEW_TIMED_NOTIFICATION)
  Controls.output:TakeFocus()
  Controls.output:SelectAll()
  set_status(C.UI.STATUS_COPY, true)
end

function M.on_scroll(value)
  Controls.output:SetTopLineIndex(math.floor(value))
end

function M.on_editbox_scroll(lineIndex)
  Controls.scrollbar:SetValue(lineIndex)
end

function M.on_move_stop()
  local x, y = Controls.window:GetScreenRect()
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_X, x)
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_Y, y)
end

function M.on_resize_stop()
  local w, h = Controls.window:GetDimensions()
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_W, w)
  CDescriptor.Settings.set(C.SAVED_VARS.WINDOW_H, h)
  CDescriptor.PromptUI.set_panel_width(w - 40)
end

function M.toggle()
  local hidden = Controls.window:IsHidden()
  Controls.window:SetHidden(not hidden)
  PlaySound(hidden and SOUNDS.ARMORY_OPEN or SOUNDS.ADVENTURE_ZONE_OVERVIEW_CLOSED)
end
