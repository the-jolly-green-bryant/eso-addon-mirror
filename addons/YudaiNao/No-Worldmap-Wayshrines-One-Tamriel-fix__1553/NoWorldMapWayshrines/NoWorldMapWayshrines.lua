NoWorldMapWayshrines = {
	name = "NoWorldMapWayshrines",
	version = 1.0
}

EVENT_MANAGER:RegisterForEvent(NoWorldMapWayshrines.name, EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == NoWorldMapWayshrines.name then
        EVENT_MANAGER:UnregisterForEvent(NoWorldMapWayshrines.name, EVENT_ADD_ON_LOADED)

        -- ZO_WorldMapMouseoverName:SetColor(0, 0, 0, 1.0)
        -- ZO_WorldMapMouseoverName:SetStyleColor(0, 0, 0, 0.35)
        -- ZO_WorldMapMouseOverDescription:SetColor(0, 0, 0, 1.0)
        -- ZO_WorldMapMouseOverDescription:SetStyleColor(0, 0, 0, 0.35)

        local function OnMapChange()
        	local wayshrinesShown = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES)

        	-- only run on worldmap/tamriel view
        	if GetMapType() == 3 then
        		-- disable wayshrines
        		if wayshrinesShown then ZO_CheckButton_OnClicked(ZO_WorldMapFiltersPvECheckBox2) end
        	else
        		-- enable wayshrines
        		if not wayshrinesShown then ZO_CheckButton_OnClicked(ZO_WorldMapFiltersPvECheckBox2) end
        	end
        end

        CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChange)
    end
end)