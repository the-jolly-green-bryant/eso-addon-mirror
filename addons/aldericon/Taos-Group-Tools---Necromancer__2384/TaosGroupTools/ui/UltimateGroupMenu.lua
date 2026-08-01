--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global callbacks
]]--
TGT_SHOW_ULTIMATE_GROUP_MENU = "TGT-ShowUltimateGroupMenu"
TGT_SET_ULTIMATE_GROUP = "TGT-SetUltimateGroup"

--[[
	Local variables
]]--
local _logger = nil

--[[
	Table TGT_UltimateGroupMenu
]]--
TGT_UltimateGroupMenu = {}
TGT_UltimateGroupMenu.__index = TGT_UltimateGroupMenu

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	SetUltimateGroup shows ultimate group menu
]]--
local function SetUltimateGroup(group, arg)
    FireCallbacksAsync(TGT_SET_ULTIMATE_GROUP, group, arg)
end

--[[
	ShowUltimateGroupMenu shows ultimate group menu
]]--
local function ShowUltimateGroupMenu(control, arg)
    if (control ~= nil) then
        ClearMenu()

        local ultimateGroups = TGT_UltimateGroupHandler.GetUltimateGroups()

        for i, group in pairs(ultimateGroups) do
            AddMenuItem(group.GroupName .. " - " .. group.GroupDescription, function() SetUltimateGroup(group, arg) end)
        end

        ShowMenu(control)
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Initialize initializes TGT_UltimateGroupMenu
]]--
function TGT_UltimateGroupMenu.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_SHOW_ULTIMATE_GROUP_MENU, ShowUltimateGroupMenu)

    _logger:logTrace("TGT_UltimateGroupMenu -> Initialized")
end