
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.zenimax = BGMeter.zenimax or {}

local M = {}

function M.current_name()
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene()
    return scene and scene:GetName() or nil
end

function M.is_hud_scene()
    local name = M.current_name()
    return name == "hud" or name == "hudui"
end

BGMeter.zenimax.scene = M
