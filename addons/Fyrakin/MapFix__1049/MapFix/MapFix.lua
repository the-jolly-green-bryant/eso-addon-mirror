local _SetMapToPlayerLocation = SetMapToPlayerLocation
local _ZO_WorldMap_PanToPlayer = ZO_WorldMap_PanToPlayer
local _ZO_WorldMap_PushSpecialMode = ZO_WorldMap_PushSpecialMode
local _ZO_WorldMap_PopSpecialMode = ZO_WorldMap_PopSpecialMode
local map_mode
local MapFix_Switch = true
local MapFix_Safe = false
local _GetPinFilter = _G["ZO_WorldMapFilterPanel_Shared"].GetPinFilter

local function GetPinFilter (obj, mapPinGroup)
	if MapFix_Switch then
		if obj.modeVars then
			if obj.modeVars.filters and obj.mapFilterType then
				if obj.modeVars.filters[obj.mapFilterType] then
					return obj.modeVars.filters[obj.mapFilterType][mapPinGroup]
				end
			end
		end
		return nil
	else
		_GetPinFilter(obj, mapPinGroup)
	end
end
_G["ZO_WorldMapFilterPanel_Shared"].GetPinFilter = GetPinFilter

function ZO_WorldMap_PushSpecialMode(mode)
	map_mode = mode
    _ZO_WorldMap_PushSpecialMode(mode)
end

function ZO_WorldMap_PopSpecialMode()
	map_mode = 0
	_ZO_WorldMap_PopSpecialMode()
end

function ZO_WorldMap_PanToPlayer()
	if MapFix_Switch then
		if map_mode ~= 3 then		
			if(_SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED) then
				if map_mode == 4 and GetMapType() == 1 then
					MapZoomOut()
				end
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			end
		end
	end
	_ZO_WorldMap_PanToPlayer()
end

function SetMapToPlayerLocation()
	if ZO_WorldMap:IsHidden() or not MapFix_Switch or (MapFix_Switch and MapFix_Safe and map_mode ~=3 and map_mode ~= 4) then
		return _SetMapToPlayerLocation()
	end
	return SET_MAP_RESULT_CURRENT_MAP_UNCHANGED
end

function MapFix_SlashHandler(command)
	if command == "help" or command == "" or command == nil then
		if MapFix_Switch then
			if MapFix_Safe then
				d("MapFix is running in safe mode")
			else
				d("MapFix is enabled")
			end
		else
			d("MapFix is disabled")
		end
		d("Slash commands:")
		d("/mfix on	  - Enable MapFix")
		d("/mfix off  - Disable MapFix")
		d("/mfix safe - Enabel MapFix for Transitus/Wayshrines only")
	end
	if command == "off" then MapFix_Safe = false MapFix_Switch = false d("MapFix disabled") end
	if command == "on" then MapFix_Safe = false MapFix_Switch = true d("MapFix enabled") end
	if command == "safe" then MapFix_Safe = true MapFix_Switch = true d("MapFix safe mode enabled") end
end

SLASH_COMMANDS["/mfix"] = MapFix_SlashHandler