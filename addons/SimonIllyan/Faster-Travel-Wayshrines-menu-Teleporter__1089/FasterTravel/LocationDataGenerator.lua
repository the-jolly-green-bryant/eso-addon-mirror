local CALLBACK_ID_ON_WORLDMAP_CHANGED = "OnWorldMapChanged"

local Utils = FasterTravel.Utils

local function AddManualLocations(locations)

	local loc = {
		["zoneIndex"] = 99,
		["tile"] = "art/maps/guildmaps/eyevea_base_0.dds"
	}

	table.insert(locations,loc)
end 

local function GetLocations(callback)
	local locations = {}

	for i = 1, GetNumMaps() do
		local mapName, mapType, mapContentType, zoneId = GetMapInfo(i)
		if Utils.stringIsEmpty(mapName) == false then
			table.insert(locations,{mapIndex = i, zoneIndex=zoneId + 1 })
		end
	end

	AddManualLocations(locations)

	local curIndex
	local curZoneIndex
	local curZoneKey
	
	local cur = 0
	local count = #locations
	local mouseClickQuest,mouseDownLoc,mouseUpLoc=WORLD_MAP_QUESTS.QuestHeader_OnClicked,WORLD_MAP_LOCATIONS.RowLocation_OnMouseDown,WORLD_MAP_LOCATIONS.RowLocation_OnMouseUp

	local done = false 
	local complete = false 

	return function()

		if complete == true then 
			return 
		end
		
		if done == true then 
			complete = true 
			ZO_WorldMap_SetMapByIndex(curIndex)
			callback(locations) -- ensure callback is called
			return 
		end
		
		if cur == 0 then
			
			curIndex = GetCurrentMapIndex()
			curZoneIndex = GetCurrentMapZoneIndex()
			curZoneKey = GetMapTileTexture()
			cur = cur + 1
			
			ZO_WorldMap_SetMapByIndex(locations[cur].mapIndex)
			
			return
		end
		
		local item = locations[cur]
		
		local path = GetMapTileTexture()
	
		item.tile = item.tile or path
		
		if cur >= count then
			done = true 
			
			ZO_WorldMap_SetMapByIndex(curIndex)
			
		elseif cur > 0 and cur < count then 
			cur = cur + 1

			ZO_WorldMap_SetMapByIndex(locations[cur].mapIndex or -1)
		end
		 
		
	end
	
end


local function Generate(callback)
	local locationFunc  
	-- hack for zone keys
	locationFunc = GetLocations(function(...)   
		FasterTravel.removeCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,locationFunc)
		callback(...)
	end)

	FasterTravel.addCallback(CALLBACK_ID_ON_WORLDMAP_CHANGED,locationFunc)
	ZO_WorldMap_SetMapByIndex(nil)
end

FasterTravel.LocationDataGenerator = {
	Generate = Generate,
	GetLocations = GetLocations,
}
