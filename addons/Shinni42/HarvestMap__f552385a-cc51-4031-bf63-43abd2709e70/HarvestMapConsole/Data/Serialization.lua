
local tonumber = _G["tonumber"]
local assert = _G["assert"]
local gmatch = string.gmatch
local tostring = _G["tostring"]
local insert = table.insert
local format = string.format
local concat = table.concat



local Serialization = {}
Harvest:RegisterModule("serialization", Serialization)
--arvest.serialization = Serialization

local CallbackManager = Harvest.callbackManager
local Events = Harvest.events
local SubmoduleManager = Harvest.submoduleManager

function Serialization:Initialize()
end

function Serialization:LoadNodesOfPinTypeToCache(pinTypeId, mapCache)
	
	mapCache:InitializePinType(pinTypeId)
	local mapMetaData = mapCache.mapMetaData
	local map = mapMetaData.map
	local zoneId = mapMetaData.zoneId

	local submodule = SubmoduleManager:GetSubmoduleForMap(map)
	if not submodule then
		return
	end
	
	self.isMapCurrentlyViewed = (map == Harvest.mapTools:GetMap())
	
	self:Debug("filling cache for map %s, pinTypeId %d, from file %s",
			map, pinTypeId, submodule.savedVarsName)
	
	
	local numAddedNodes = 0
	
	local downloadedVars = submodule.downloadedVars
	if downloadedVars[zoneId] and downloadedVars[zoneId][map] and downloadedVars[zoneId][map][pinTypeId] then
		self.downloadedData = downloadedVars[zoneId][map][pinTypeId]
		numAddedNodes = numAddedNodes + self:LoadDownloadedData(mapCache, pinTypeId)
	end
	
	mapCache:FinalizePinType(pinTypeId)
	
	--d("loaded", pinTypeId)
	
	if numAddedNodes > 0 then
		CallbackManager:FireCallbacks(Events.NEW_NODES_LOADED_TO_CACHE, mapCache, pinTypeId, numAddedNodes)
	end
end


function Serialization:LoadDownloadedData(mapCache, pinTypeId)
	
	local minDiscoveryDay = -math.huge
	if Harvest.GetMaxTimeDifference() > 0 then
		local currentDay = GetTimeStamp() / (60 * 60 * 24)
		minDiscoveryDay = currentDay - Harvest.GetMaxTimeDifference() / 24
	end
	
	local x1, x2, y1, y2, d1, d2
	local worldX, worldY, worldZ, discoveryDay
	
	local numAddedNodes = 0
	local downloadedData = self.downloadedData
	assert(#downloadedData % 8 == 0)
	for dataIndex = 1, #downloadedData, 8 do
		x1, x2, y1, y2, z1, z2, d1, d2 = downloadedData:byte(dataIndex, dataIndex+7)
		
		discoveryDay = d1 * 256 + d2
		if discoveryDay >= minDiscoveryDay then
			worldX = (x1 * 256 + x2) * 0.2
			worldY = (y1 * 256 + y2) * 0.2
			worldZ = (z1 * 256 + z2) * 0.2
			mapCache:Add(worldX, worldY, worldZ)
			numAddedNodes = numAddedNodes + 1
		end
	end
	
	self:Debug("added %d nodes", numAddedNodes)
	
	return numAddedNodes
end
