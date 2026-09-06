
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

local owned = {}
local escape_pressed = false
local hooked = false

local function ensure_hooks(s)
    if hooked then return end
    if type(ZO_PreHook) ~= "function" or type(ZO_PostHook) ~= "function" then return end
    hooked = true
    ZO_PreHook(s, "OnToggleGameMenuBinding", function()
        escape_pressed = true
        if BGMeter.Log then BGMeter.Log.debug("escape binding") end
    end)
    ZO_PostHook(s, "OnToggleGameMenuBinding", function() escape_pressed = false end)
    ZO_PreHook(s, "HideTopLevel", function(_, control)
        local on_escape = owned[control]
        if not on_escape then return false end
        if BGMeter.Log then
            BGMeter.Log.debug("HideTopLevel %s escape=%s hidden=%s",
                tostring(control.GetName and control:GetName() or "?"), tostring(escape_pressed), tostring(control:IsHidden()))
        end
        if escape_pressed and not control:IsHidden() then on_escape() end
        return true
    end)
end

function M.register_top_level(control, on_escape)
    local s = SCENE_MANAGER
    if not s or type(s.RegisterTopLevel) ~= "function" then return false end
    owned[control] = on_escape
    ensure_hooks(s)
    return pcall(function() s:RegisterTopLevel(control, false) end)
end

function M.enter_ui_mode()
    local s = SCENE_MANAGER
    if not s or type(s.SetInUIMode) ~= "function" then return false end
    return pcall(function() s:SetInUIMode(true) end)
end

function M.escape_pressed() return escape_pressed end

function M.push(name)
    local s = SCENE_MANAGER
    if not s or type(s.Push) ~= "function" then return false end
    return pcall(function() s:Push(name) end)
end

function M.next_is_hud()
    local sm = SCENE_MANAGER
    if not sm or type(sm.GetNextScene) ~= "function" then return false end
    local ok, nxt = pcall(function() return sm:GetNextScene() end)
    if not ok or not nxt or type(nxt.GetName) ~= "function" then return false end
    local name = nxt:GetName()
    return name == "hud" or name == "hudui"
end

BGMeter.zenimax.scene = M
