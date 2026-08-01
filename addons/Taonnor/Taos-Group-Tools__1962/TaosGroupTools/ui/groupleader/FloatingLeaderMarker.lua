--[[
	Addon: Taos Group Tools
	Author: TProg Taonnor
	Created by @Taonnor
]]--

--[[
	Local variables
]]--
local _logger = nil
local _settingsHandler = TGT_SettingsHandler

local _name = "TGT-FloatingLeaderMarker"

--[[
	Table TGT_FloatingLeaderMarker
]]--
TGT_FloatingLeaderMarker = {}
TGT_FloatingLeaderMarker.__index = TGT_FloatingLeaderMarker

--[[
	===============
    PRIVATE METHODS
    ===============
]]--

--[[
	ShowMarker shows additional leader marker
]]--
local function ShowMarker()
    local iconSize = _settingsHandler.SavedVariables.IconSize
    local iconPath = _settingsHandler.Icons[_settingsHandler.SavedVariables.Icon].path

    SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, iconSize, iconPath)
end

--[[
	HideMarker hides additional leader marker
]]--
local function HideMarker()
    SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, nil, nil)
end

--[[
	SetControlActive sets isActive on control
]]--
local function SetControlActive()
    if (_settingsHandler.SavedVariables.IsLeaderIconActive) then
        ShowMarker()

        CALLBACK_MANAGER:RegisterCallback(TGT_LEADER_ICON_PROPERTIES_CHANGED, ShowMarker)
        EVENT_MANAGER:RegisterForEvent(_name, EVENT_COMBAT_EVENT, ShowMarker)
    else
        CALLBACK_MANAGER:UnregisterCallback(TGT_LEADER_ICON_PROPERTIES_CHANGED, ShowMarker)
        EVENT_MANAGER:UnregisterForEvent(_name, EVENT_COMBAT_EVENT)

        HideMarker()
    end
end

--[[
	==============
    PUBLIC METHODS
    ==============
]]--

--[[
	Initialize initializes TGT_FloatingLeaderMarker
]]--
function TGT_FloatingLeaderMarker.Initialize(logger)
    _logger = TGT_LOGGER

    SetControlActive()
    
    CALLBACK_MANAGER:RegisterCallback(TGT_LEADER_ICON_ACTIVE_CHANGED, SetControlActive)

    _logger:logTrace("TGT_FloatingLeaderMarker -> Initialized")
end