
Verdant = Verdant or {}
Verdant.zenimax = Verdant.zenimax or {}
local Verdant = Verdant

Verdant.zenimax.scene = {}
local M = Verdant.zenimax.scene

local SCENE_MANAGER = SCENE_MANAGER

M.SCENE_SHOWN  = SCENE_SHOWN
M.SCENE_HIDDEN = SCENE_HIDDEN

function M.register_callback(event_name, callback)
  SCENE_MANAGER:RegisterCallback(event_name, callback)
end

function M.unregister_callback(event_name, callback)
  SCENE_MANAGER:UnregisterCallback(event_name, callback)
end

function M.register_top_level(control)
  SCENE_MANAGER:RegisterTopLevel(control, false)
end

function M.show_top_level(control)
  SCENE_MANAGER:ShowTopLevel(control)
end

function M.hide_top_level(control)
  SCENE_MANAGER:HideTopLevel(control)
end

function M.is_hud_scene(name)
  return name == "hud" or name == "hudui"
end
