CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Settings = {}

local M = CDescriptor.Settings

local SV_TABLE   = "CDescriptorSavedVars"
local SV_VERSION = 1

local DEFAULTS = {
  window_x      = nil,
  window_y      = nil,
  window_w      = 620,
  window_h      = 530,
  include_sets     = true,
  include_stats    = false,
  include_buffs    = false,
  include_passives = false,
  include_cp       = false,
  include_prompt   = false,
  prompt_cat       = "",
  prompt_sub       = "",
  prompt_diff      = "",
  prompt_role      = "",
  prompt_lang      = "English",
}

local sv_obj

function M.load()
  sv_obj = ZO_SavedVars:NewAccountWide(SV_TABLE, SV_VERSION, nil, DEFAULTS)
end

function M.get(key)
  return sv_obj and sv_obj[key]
end

function M.set(key, value)
  if sv_obj then sv_obj[key] = value end
end
