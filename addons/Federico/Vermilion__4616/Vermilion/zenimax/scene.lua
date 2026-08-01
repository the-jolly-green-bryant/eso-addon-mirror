
Vermilion = Vermilion or {}
Vermilion.zenimax = Vermilion.zenimax or {}
local Vermilion = Vermilion

Vermilion.zenimax.scene = {}
local M = Vermilion.zenimax.scene

local SCENE_MANAGER = SCENE_MANAGER

M.SCENE_SHOWN  = SCENE_SHOWN
M.SCENE_HIDDEN = SCENE_HIDDEN

function M.register_callback(event_name, callback)
  SCENE_MANAGER:RegisterCallback(event_name, callback)
end

function M.unregister_callback(event_name, callback)
  SCENE_MANAGER:UnregisterCallback(event_name, callback)
end

function M.is_hud_scene(name)
  return name == "hud" or name == "hudui"
end
