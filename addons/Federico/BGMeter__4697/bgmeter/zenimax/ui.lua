
BGMeter = BGMeter or {}
local BGMeter = BGMeter
BGMeter.zenimax = BGMeter.zenimax or {}

local WM = WINDOW_MANAGER
local M = {}

M.wm = WM

local _seq = 0
local function auto_name(name)
    if name and name ~= "" then return name end
    _seq = _seq + 1
    return "BGMeterAnon" .. _seq
end

function M.create_control(name, parent, ctype)
    return WM:CreateControl(auto_name(name), parent, ctype)
end

function M.create_from_virtual(name, parent, template)
    return WM:CreateControlFromVirtual(auto_name(name), parent, template)
end

function M.get_control(name)
    return WM:GetControlByName(name)
end

function M.new_pool(factory_fn, reset_fn)
    return ZO_ObjectPool:New(factory_fn, reset_fn)
end

BGMeter.zenimax.ui = M
