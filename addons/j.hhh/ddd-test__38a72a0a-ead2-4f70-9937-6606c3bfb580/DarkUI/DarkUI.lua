darkui = {}
darkui.appName = "DarkUI"
darkui.version = "2.76 HUD"

local eso_root = "esoui/art/"
local ui_root = "darkui/"
local SAVEDVARIABLES_VERSION = 4

-- PS5 HUD-only redirects. Menus, windows, inventory, journal, map and tooltips are intentionally untouched.
local common_textures = {
  { "hud/gamepad/gp_infamy_meter-back-grey_px_per.dds", "blank.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_dynamic_invulnerable.dds", "blank.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_dynamic_invulnerable_munge.dds", "blank.dds" },
  { "unitattributevisualizer/gamepad/gp_targetbar_dynamic_invulnerable.dds", "blank.dds" },
}

local theme_textures = {
  { "actionbar/gamepad/gp_abilityframe64.dds", "gamepad/gp_abilityframe64.dds" },
  { "actionbar/gamepad/gp_abilityframe_buff.dds", "gamepad/gp_abilityframe_buff.dds" },
  { "bossbar/gamepad/gp_bossbar_bracket.dds", "gamepad/gp_bossbar_bracket.dds" },
  { "hud/gamepad/gp_infamy_meter-frame-generic.dds", "gamepad/gp_infamy_meter-frame-generic.dds" },
  { "hud/gamepad/gp_telvar_meter_frame.dds", "gamepad/gp_telvar_meter_frame.dds" },
  { "hud/gamepad/gp_ultimateframe_edge.dds", "gamepad/gp_ultimateframe_edge.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_dynamic_frame.dds", "gamepad/gp_attributebar_dynamic_frame.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_dynamic_increasedarmor_frame.dds", "gamepad/gp_attributebar_dynamic_increasedarmor_frame.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_small_frame.dds", "gamepad/gp_attributebar_small_frame.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_small_frame_center.dds", "gamepad/gp_attributebar_small_frame_center.dds" },
  { "unitattributevisualizer/gamepad/gp_targetbar_dynamic_frame.dds", "gamepad/gp_targetbar_dynamic_frame.dds" },
  { "unitattributevisualizer/gamepad/gp_targetbar_dynamic_increasedarmor_frame.dds", "gamepad/gp_targetbar_dynamic_increasedarmor_frame.dds" },
  { "unitframes/gamepad/gp_targetunitframe_bracket_level2.dds", "gamepad/gp_targetunitframe_bracket_level2.dds" },
  { "unitframes/gamepad/gp_targetunitframe_bracket_level3.dds", "gamepad/gp_targetunitframe_bracket_level3.dds" },
  { "unitframes/gamepad/gp_targetunitframe_bracket_level4.dds", "gamepad/gp_targetunitframe_bracket_level4.dds" },
  { "compass/gamepad/gp_compass.dds", "gamepad/gp_compass.dds" },
}

local gloss_textures = {
  "unitattributevisualizer/gamepad/gp_attributebar_dynamic_fill_gloss.dds",
  "unitattributevisualizer/gamepad/gp_attributebar_dynamic_leadingedge_gloss.dds",
  "unitattributevisualizer/gamepad/gp_attributebar_small_fill_center_gloss.dds",
  "unitattributevisualizer/gamepad/gp_attributebar_small_fill_leadingedge_gloss.dds",
  "unitattributevisualizer/gamepad/gp_targetbar_dynamic_fill_gloss.dds",
  "unitattributevisualizer/gamepad/gp_targetbar_dynamic_leadingedge_gloss.dds",
}

local darker_bars = {
  { "unitattributevisualizer/gamepad/gp_attributebar_dynamic_fill.dds", "gamepad/gp_attributebar_dynamic_fill_darker.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_dynamic_leadingedge.dds", "gamepad/gp_attributebar_dynamic_leadingedge_darker.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_small_fill_center.dds", "gamepad/gp_attributebar_small_fill_center_darker.dds" },
  { "unitattributevisualizer/gamepad/gp_attributebar_small_fill_leadingedge.dds", "gamepad/gp_attributebar_small_fill_leadingedge_darker.dds" },
  { "unitattributevisualizer/gamepad/gp_targetbar_dynamic_fill.dds", "gamepad/gp_targetbar_dynamic_fill_darker.dds" },
  { "unitattributevisualizer/gamepad/gp_targetbar_dynamic_leadingedge.dds", "gamepad/gp_targetbar_dynamic_leadingedge_darker.dds" },
}

local function OnAddOnLoaded(_, addOnName)
  if addOnName ~= darkui.appName then return end

  local defaults = { Icon = GetString(DARKUI_DARK), Darker_Bars = false, Hide_Group_Frame_Background = false, Hide_Status_Meter_Background = false }
  darkui.SV = ZO_SavedVars:NewAccountWide("DarkUI_SavedVariables", SAVEDVARIABLES_VERSION, nil, defaults)

  local theme = "dark"
  if darkui.SV.Icon == GetString(DARKUI_LIGHT) then theme = "light"
  elseif darkui.SV.Icon == GetString(DARKUI_MIXED) then theme = "mixed" end

  -- Gamepad HUD only.
  if ZO_ActionBar1KeybindBG then ZO_ActionBar1KeybindBG:SetAlpha(0) end
  for _, t in ipairs(common_textures) do RedirectTexture(eso_root .. t[1], ui_root .. "common_textures/" .. t[2]) end
  for _, t in ipairs(theme_textures) do RedirectTexture(eso_root .. t[1], ui_root .. "theme_" .. theme .. "/" .. t[2]) end
  for _, path in ipairs(gloss_textures) do RedirectTexture(eso_root .. path, ui_root .. "common_textures/blank.dds") end

  if darkui.SV.Darker_Bars then
    for _, t in ipairs(darker_bars) do RedirectTexture(eso_root .. t[1], ui_root .. "common_textures/" .. t[2]) end
  end

  -- Keep group/status HUD cleanup, but no menu/background replacements.
  RedirectTexture(eso_root .. "unitframes/unitframe_group_right.dds", ui_root .. "common_textures/blank.dds")
  if darkui.SV.Hide_Group_Frame_Background then
    RedirectTexture(eso_root .. "unitframes/unitframe_group_left.dds", ui_root .. "common_textures/blank.dds")
  else
    RedirectTexture(eso_root .. "unitframes/unitframe_group_left.dds", ui_root .. "common_textures/unitframe_group_left.dds")
  end
  if darkui.SV.Hide_Status_Meter_Background then
    RedirectTexture(eso_root .. "performance/statusmetermunge.dds", ui_root .. "common_textures/blank.dds")
  else
    RedirectTexture(eso_root .. "performance/statusmetermunge.dds", ui_root .. "common_textures/statusmetermunge.dds")
  end

  darkui:initLAM()
end

EVENT_MANAGER:RegisterForEvent(darkui.appName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
