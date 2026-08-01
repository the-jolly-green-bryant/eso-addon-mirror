local function hookUpHouses()
	ZO_PreHook("ZO_WorldMapHouseRow_OnMouseUp", function(label, button, upInside)
		if(upInside and button == MOUSE_BUTTON_INDEX_RIGHT) then
			local data = ZO_ScrollList_GetData(label:GetParent())
			RequestJumpToHouse(data.houseId)
			PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
			return true
		end
	end)
end

function MapClickHouse_Initialize(eventCode, addOnName)
	
	if (addOnName ~= "MapRightClickHouse") then return end	
	hookUpHouses()
	EVENT_MANAGER:UnregisterForEvent("MapRightClickHouse")

end

EVENT_MANAGER:RegisterForEvent("MapRightClickHouse", EVENT_ADD_ON_LOADED, MapClickHouse_Initialize)
