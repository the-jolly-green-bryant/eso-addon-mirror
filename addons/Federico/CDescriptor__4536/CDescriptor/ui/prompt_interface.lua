-- Manages the inline prompt configuration panel.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.PromptUI = {}

local M        = CDescriptor.PromptUI
local C        -- set in M.init()
local Controls = {}

local PANEL_HEIGHT = 110

-- ── Content type lookup ───────────────────────────────────────────────────────

local CONTENT_TYPES = {
  ["PvE:Solo"]                       = "PvE solo content.",
  ["PvE:Dungeons"]                   = "PvE group dungeon content.",
  ["PvE:Dungeons:Normal"]            = "PvE group dungeon content, normal difficulty.",
  ["PvE:Dungeons:Veteran"]           = "PvE group dungeon content, veteran difficulty.",
  ["PvE:Dungeons:Veteran Hard Mode"] = "PvE group dungeon content, veteran hard mode difficulty.",
  ["PvE:Trials"]                     = "PvE Trial content (12-player).",
  ["PvE:Trials:Normal"]              = "PvE Trial content (12-player), normal difficulty.",
  ["PvE:Trials:Veteran"]             = "PvE Trial content (12-player), veteran difficulty.",
  ["PvE:Trials:Veteran Hard Mode"]   = "PvE Trial content (12-player), veteran hard mode — hardest PvE content in the game.",
  ["PvP:Cyrodiil"]                   = "PvP open world (Cyrodiil).",
  ["PvP:Imperial City"]              = "PvP Imperial City.",
  ["PvP:Battlegrounds"]              = "PvP instanced (Battlegrounds).",
}

local LANGUAGES = {
  { label = "English",   value = "English."              },
  { label = "Espanol",   value = "Spanish."              },
  { label = "Francais",  value = "French."               },
  { label = "Deutsch",   value = "German."               },
  { label = "Italiano",  value = "Italian."              },
  { label = "Portugues", value = "Portuguese."           },
  { label = "Japanese",  value = "Japanese."             },
  { label = "Korean",    value = "Korean."               },
  { label = "Chinese",   value = "Chinese (Simplified)." },
  { label = "Russian",   value = "Russian."              },
}

local ROLE_TYPES = {
  [""]       = "Full analysis: damage, survivability, and support.",
  ["DPS"]    = "Prioritize maximizing damage output.",
  ["Tank"]   = "Prioritize maximizing survivability and damage mitigation.",
  ["Healer"] = "Prioritize maximizing support and healing output.",
  ["Hybrid"] = "Hybrid role: balance between damage and survivability or support.",
}

local SUBCATS = {
  PvE = { "", "Solo", "Dungeons", "Trials" },
  PvP = { "", "Cyrodiil", "Imperial City", "Battlegrounds" },
}
local DIFFS_FOR = { Dungeons = true, Trials = true }
local DIFFS     = { "", "Normal", "Veteran", "Veteran Hard Mode" }

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function sv(key)      return CDescriptor.Settings.get(key) end
local function sv_set(k, v) CDescriptor.Settings.set(k, v)       end
local function combo(ctrl)  return ctrl.m_comboBox               end

local function get_content_type_str()
  local cat  = sv(C.SAVED_VARS.PROMPT_CAT)  or ""
  local sub  = sv(C.SAVED_VARS.PROMPT_SUB)  or ""
  local diff = sv(C.SAVED_VARS.PROMPT_DIFF) or ""
  if cat == "" then return "Infer from the build data provided." end
  local key = diff ~= "" and (cat..":"..sub..":"..diff)
           or sub  ~= "" and (cat..":"..sub)
           or nil
  if not key then return "Infer from the build data provided." end
  return CONTENT_TYPES[key] or "Infer from the build data provided."
end

local function get_language_str()
  local saved = sv(C.SAVED_VARS.PROMPT_LANG) or "English"
  for _, lang in ipairs(LANGUAGES) do
    if lang.label == saved then return lang.value end
  end
  return "English."
end

local function get_role_str()
  local role = sv(C.SAVED_VARS.PROMPT_ROLE) or ""
  return ROLE_TYPES[role] or ROLE_TYPES[""]
end

-- ── ComboBox population ───────────────────────────────────────────────────────

local sub_combo_cb
local diff_combo_cb

local function populate_diff()
  local diff_combo = combo(Controls.content_diff)
  diff_combo:ClearItems()
  for _, name in ipairs(DIFFS) do
    diff_combo:AddItem(diff_combo:CreateItemEntry(name == "" and "-- select --" or name,
      function() diff_combo_cb(name) end))
  end
  local saved = sv(C.SAVED_VARS.PROMPT_DIFF) or ""
  Controls.content_diff:GetNamedChild("SelectedItemText"):SetText(saved == "" and "-- select --" or saved)
end

local function populate_sub(cat)
  local sub_combo = combo(Controls.content_sub)
  sub_combo:ClearItems()
  local options = SUBCATS[cat]
  if not options then
    Controls.content_sub:SetHidden(true)
    Controls.content_diff:SetHidden(true)
    return
  end
  Controls.content_sub:SetHidden(false)
  for _, name in ipairs(options) do
    sub_combo:AddItem(sub_combo:CreateItemEntry(name == "" and "-- select --" or name,
      function() sub_combo_cb(name) end))
  end
  local saved = sv(C.SAVED_VARS.PROMPT_SUB) or ""
  Controls.content_sub:GetNamedChild("SelectedItemText"):SetText(saved == "" and "-- select --" or saved)
  local show_diff = DIFFS_FOR[saved] == true
  Controls.content_diff:SetHidden(not show_diff)
end

sub_combo_cb = function(name)
  sv_set(C.SAVED_VARS.PROMPT_SUB,  name)
  sv_set(C.SAVED_VARS.PROMPT_DIFF, "")
  local show_diff = DIFFS_FOR[name] == true
  Controls.content_diff:SetHidden(not show_diff)
  if show_diff then populate_diff() end
end

diff_combo_cb = function(name)
  sv_set(C.SAVED_VARS.PROMPT_DIFF, name)
end

-- ── Init ──────────────────────────────────────────────────────────────────────

function M.init()
  C = CDescriptor.Constants
  local names = C.CONTROLS
  local SV    = C.SAVED_VARS

  Controls.panel        = _G[names.PROMPT_PANEL]
  Controls.lang         = _G[names.PROMPT_LANG]
  Controls.content_cat  = _G[names.PROMPT_CONTENT_CAT]
  Controls.content_sub  = _G[names.PROMPT_CONTENT_SUB]
  Controls.content_diff = _G[names.PROMPT_CONTENT_DIFF]
  Controls.role         = _G[names.PROMPT_ROLE]

  -- Ensure panel starts collapsed so DividerBottom sits flush below checkboxes
  if Controls.panel then
    Controls.panel:SetHeight(0)
    Controls.panel:SetHidden(true)
  end

  -- Language combo
  if Controls.lang then
    local lang_combo = combo(Controls.lang)
    lang_combo:SetSortsItems(false)
    for _, lang in ipairs(LANGUAGES) do
      local label = lang.label
      lang_combo:AddItem(lang_combo:CreateItemEntry(label, function()
        sv_set(SV.PROMPT_LANG, label)
      end))
    end
    Controls.lang:GetNamedChild("SelectedItemText"):SetText(sv(SV.PROMPT_LANG) or "English")
  end

  -- Category combo
  if Controls.content_cat then
    local cat_combo = combo(Controls.content_cat)
    cat_combo:SetSortsItems(false)
    cat_combo:AddItem(cat_combo:CreateItemEntry("-- select --", function()
      sv_set(SV.PROMPT_CAT,  "")
      sv_set(SV.PROMPT_SUB,  "")
      sv_set(SV.PROMPT_DIFF, "")
      Controls.content_sub:SetHidden(true)
      Controls.content_diff:SetHidden(true)
    end))
    cat_combo:AddItem(cat_combo:CreateItemEntry("PvE", function()
      sv_set(SV.PROMPT_CAT,  "PvE")
      sv_set(SV.PROMPT_SUB,  "")
      sv_set(SV.PROMPT_DIFF, "")
      populate_sub("PvE")
    end))
    cat_combo:AddItem(cat_combo:CreateItemEntry("PvP", function()
      sv_set(SV.PROMPT_CAT,  "PvP")
      sv_set(SV.PROMPT_SUB,  "")
      sv_set(SV.PROMPT_DIFF, "")
      populate_sub("PvP")
    end))
    local saved_cat = sv(SV.PROMPT_CAT) or ""
    Controls.content_cat:GetNamedChild("SelectedItemText"):SetText(saved_cat == "" and "-- select --" or saved_cat)
    if saved_cat ~= "" then
      populate_sub(saved_cat)
      if DIFFS_FOR[sv(SV.PROMPT_SUB) or ""] then populate_diff() end
    else
      Controls.content_sub:SetHidden(true)
      Controls.content_diff:SetHidden(true)
    end
  end

  -- Role combo
  if Controls.role then
    local role_combo = combo(Controls.role)
    role_combo:SetSortsItems(false)
    local roles       = { "",               "DPS",  "Tank",  "Healer",  "Hybrid"  }
    local role_labels = { "-- full analysis --", "DPS",  "Tank",  "Healer",  "Hybrid"  }
    for i, key in ipairs(roles) do
      local label = role_labels[i]
      role_combo:AddItem(role_combo:CreateItemEntry(label, function()
        sv_set(SV.PROMPT_ROLE, key)
      end))
    end
    local saved_role = sv(SV.PROMPT_ROLE) or ""
    Controls.role:GetNamedChild("SelectedItemText"):SetText(saved_role == "" and "-- full analysis --" or saved_role)
  end
end

-- ── Show / Hide ───────────────────────────────────────────────────────────────

function M.set_panel_width(w)
  if Controls.panel then Controls.panel:SetWidth(w) end
end

function M.show()
  if not Controls.panel then return end
  Controls.panel:SetHeight(PANEL_HEIGHT)
  Controls.panel:SetHidden(false)
end

function M.hide()
  if not Controls.panel then return end
  Controls.panel:SetHidden(true)
  Controls.panel:SetHeight(0)
end

-- ── Build prompt settings for core/prompt.lua ─────────────────────────────────

function M.build_prompt_settings()
  return {
    patch          = tostring(GetAPIVersion()),
    content_type   = get_content_type_str(),
    analysis_focus = get_role_str(),
    language       = get_language_str(),
  }
end
