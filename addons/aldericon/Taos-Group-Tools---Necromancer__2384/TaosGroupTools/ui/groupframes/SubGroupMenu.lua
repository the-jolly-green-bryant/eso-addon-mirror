--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Global callbacks
]]--
TGT_SHOW_SUB_GROUP_MENU = "TGT-ShowSubGroupMenu"
TGT_SET_SUB_GROUP = "TGT-SetSubGroup"

--[[
	Local variables
]]--
local _logger = nil
local _settingsHandler = TGT_SettingsHandler

--[[
	Table TGT_SubGroupMenu
]]--
TGT_SubGroupMenu = {}
TGT_SubGroupMenu.__index = TGT_SubGroupMenu

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	SetSubGroup shows Sub group menu
]]--
local function SetSubGroup(group, arg)
    FireCallbacksAsync(TGT_SET_SUB_GROUP, group, arg)
end

--[[
	AddSubGroupMenu adds menu item
]]--
local function AddSubGroupMenu(identifier, group, arg)
    if (string.len(group.Name) > 0) then
        AddMenuItem(zo_strformat("<<1>> - <<2>>", identifier, group.Name), function() SetSubGroup(identifier, arg) end)
    else
        AddMenuItem(identifier, function() SetSubGroup(identifier, arg) end)
    end
end

--[[
	ShowSubGroupMenu shows Sub group menu
]]--
local function ShowSubGroupMenu(control, arg)
    if (control ~= nil) then
        ClearMenu()

        -- Add menu sorted
        local subGroups = _settingsHandler.SavedVariables.GroupFrameGroups
        AddSubGroupMenu("MainGroup", subGroups["MainGroup"], arg)
        AddSubGroupMenu("SubGroup1", subGroups["SubGroup1"], arg)
        AddSubGroupMenu("SubGroup2", subGroups["SubGroup2"], arg)
        AddSubGroupMenu("SubGroup3", subGroups["SubGroup3"], arg)
        AddSubGroupMenu("SubGroup4", subGroups["SubGroup4"], arg)
        AddSubGroupMenu("SubGroup5", subGroups["SubGroup5"], arg)

        ShowMenu(control)
    else
        _logger:logError("GroupFrames -> ShowSubGroupMenu; control nil")
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Initialize initializes TGT_SubGroupMenu
]]--
function TGT_SubGroupMenu.Initialize()
    _logger = TGT_LOGGER

    CALLBACK_MANAGER:RegisterCallback(TGT_SHOW_SUB_GROUP_MENU, ShowSubGroupMenu)

    _logger:logTrace("TGT_SubGroupMenu -> Initialized")
end