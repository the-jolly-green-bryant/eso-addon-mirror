local lib = {}
lib.name = "LibGamepadTooltipFilters"
lib.tooltip = { }
--[[
--ToolTip Format
lib.tooltip ={
	[mapPinGroup] = {
		text--display text
		extra--for if you have some data you want to refrance later like a custom index
	}
}
--]]
--mapPinGroup: pinTypeId or _G[pinTypeString]
--text: Text youy want to Display
--extra(optional): what ever you want. I use it for my custom indexing my SaveVars
function lib:AddTooltip(mapPinGroup,text,extra)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	assert(type(text) == "string", "Parameter text is not a string.")
	assert(not lib.tooltip[mapPinGroup], "tootip already extst's use SetTooltip")
	lib.tooltip[mapPinGroup] = { }
	lib.tooltip[mapPinGroup].text = text
	if extra then lib.tooltip[mapPinGroup].extra = extra end
end

--Returns values of requested tooltip
--text, extra
function lib:GetTooltipSpit(mapPinGroup)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	local tooltip = lib.tooltip[mapPinGroup]
	local text, extra
	if tooltip then 
		if tooltip.text then text = tooltip.text end
		if tooltip.extra then extra = tooltip.extra end
	end
	return text, extra
end
--Returns requested tooltip or nil
function lib:GetTooltip(mapPinGroup)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	local tooltip = lib.tooltip[mapPinGroup]
	return tooltip
end

--Returns text of requested tooltip
function lib:GetTooltipText(mapPinGroup)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	local tooltip = lib.tooltip[mapPinGroup]
	if tooltip and tooltip.text then return tooltip.text end
	return nil
end
--Returns extra of requested tooltip
function lib:GetTooltipExtra(mapPinGroup)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	local tooltip = lib.tooltip[mapPinGroup]
	if tooltip and tooltip.extra then return tooltip.extra end
	return nil
end




--use if tooltip has been added
function lib:SetTooltip(mapPinGroup,text,extra)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	assert(type(text) == "string", "Parameter text is not a string.")
	lib.tooltip[mapPinGroup].text = text
	if extra then lib.tooltip[mapPinGroup].extra = extra end
end


function lib:SetTooltipExtra(mapPinGroup,extra)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	if not lib.tooltip[mapPinGroup] then lib.tooltip[mapPinGroup] = {} end
	lib.tooltip[mapPinGroup].extra = extra
end
function lib:SetTooltipText(mapPinGroup,text)
	assert(type(mapPinGroup) == "number", "Parameter mapPinGroup is not a number.")
	assert(type(text) == "string", "Parameter text is not a string.")
	if not lib.tooltip[mapPinGroup] then lib.tooltip[mapPinGroup] = {} end
	lib.tooltip[mapPinGroup].text = text
end

local function GetCurrentGamepadMapFilterPanel()
  return GAMEPAD_WORLD_MAP_FILTERS and GAMEPAD_WORLD_MAP_FILTERS.currentPanel
end

local function UpdateFilterTooltip()
	local tooltip = lib.tooltip[GetCurrentGamepadMapFilterPanel().list:GetTargetData().mapPinGroup]
	local text =""
	if tooltip then text = tooltip.text end
	Lib_Gamepad_Tooltip_FiltersToolTip:SetText(text)	
end

local function TooltipSetHidden(state)
	ZO_SharedGamepadNavQuadrant_4_Background:SetHidden(state)
	Lib_Gamepad_Tooltip_FiltersToolTip:SetHidden(state)
end

local function OnMapChanged()
	GetCurrentGamepadMapFilterPanel().list:SetOnTargetDataChangedCallback(function() UpdateFilterTooltip()end) 
end

local function Initialize()
	--Hide Tooltip just incase
	Lib_Gamepad_Tooltip_FiltersToolTip:SetHidden(true)
	--Toggles for the tooltip background
	ZO_WorldMapFilters_GamepadTL:SetHandler("OnHide",function() TooltipSetHidden(true)end)
	ZO_WorldMapFilters_GamepadTL:SetHandler("OnShow",function() TooltipSetHidden(false)end)
	OnMapChanged()
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
end

local function OnAddOnLoaded(event, addonName)
	if addonName == lib.name then
		EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)
		Initialize()
	end
end
LibGamepadTooltipFilters = lib
EVENT_MANAGER:RegisterForEvent(lib.name,EVENT_ADD_ON_LOADED,OnAddOnLoaded)