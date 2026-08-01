function OpenEnhancedMapLocations()
	if (not ZO_WorldMap_IsWorldMapShowing()) then
		ZO_WorldMap_ShowWorldMap()
	end
	
	if (IsInGamepadPreferredMode()) then
		ZO_WorldMap_SetGamepadKeybindsShown(false)
		
		ZO_WorldMapGamepadInteractKeybind:SetHidden(true)
		
		-- Hide Legend if it is showing
		SCENE_MANAGER:RemoveFragment(GAMEPAD_WORLD_MAP_KEY_FRAGMENT)
		ZO_WorldMap_HideAllTooltips()
		
		-- Add the World Map Info
		GAMEPAD_WORLD_MAP_INFO:Show()
		
		-- Second tab of map info
		local baseHeaderDataLocationIndex = 3 -- usually 2 if no zone guide
		
		if GAMEPAD_WORLD_MAP_INFO.header.tabBar[2] ~= nil and GAMEPAD_WORLD_MAP_INFO.header.tabBar[2].text == "Locations" then -- TODO: Localization for this check -- although it will fallback on tab 3
			baseHeaderDataLocationIndex = 2
		end
	
		GAMEPAD_WORLD_MAP_INFO.header.tabBar:SetSelectedIndex(baseHeaderDataLocationIndex)
	end
end

function ToggleCustomPlayerWaypoint()
	local normX, normY = GetMapPlayerWaypoint()
	if (normX > 0 and normY > 0) then
		zo_callLater(function() RemovePlayerWaypoint() end, 100)
		RemovePlayerWaypoint()
	else
		RemovePlayerWaypoint()
		zo_callLater(function()
			if WAYPOINTIT and WAYPOINTIT.TryAutoMarkNearestQuest then
				WAYPOINTIT:TryAutoMarkNearestQuest()
			end
		end, 500)
	end
end
