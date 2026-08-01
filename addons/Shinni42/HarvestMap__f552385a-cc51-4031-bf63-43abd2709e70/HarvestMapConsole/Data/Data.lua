
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events
local SubmoduleManager = Harvest.submoduleManager
local Serialization = Harvest.serialization

local Data = {}
Harvest:RegisterModule("Data", Data)

function Data:Initialize()
	-- cache the deserialized nodes
	-- this way changing maps multiple times will create less lag
	self.mapCaches = {}
	self.numMapCaches = 0
	self.currentZoneCache = nil
	
	EVENT_MANAGER:RegisterForEvent("HarvestMap-Data", EVENT_PLAYER_ACTIVATED, function()
			-- loading the zone cache is the last thing to complete
			-- for the data module to have finished initialization
			self:Info("player activated, check zone change")
			self:RefreshZoneCacheForNewZone()
			self:RemoveOldCaches()
		end)
end

local function clearMemory()
	EVENT_MANAGER:UnregisterForUpdate("HarvestMap-GC")
	collectgarbage()
	collectgarbage() -- somehow the first sweep doesn't clear everything
end

function Data:RemoveOldCaches()
	--if self.numMapCaches <= 5 then return end
	self:Info("remove old caches")
	local oldestCache
	local oldestTime = math.huge
	local wasCacheRemoved = false
	while true do
		for mapMetaData, cache in pairs(self.mapCaches) do
			if cache.time < oldestTime and cache.accessed == 0 then
				oldestCache = cache
				oldestTime = cache.time
			end
		end
		
		if not oldestCache then break end
		
		self:Info("Clear cache for map ", oldestCache.map)
		oldestCache:Dispose()
		self.mapCaches[oldestCache.mapMetaData] = nil
		self.numMapCaches = self.numMapCaches - 1
		oldestCache = nil
		oldestTime = math.huge
		wasCacheRemoved = true
	end
	if wasCacheRemoved then
		-- delay to next frame, because when other addons are active, a lot of calculation 
		-- may happen during the player activated event.
		-- there is a limist of 1s calculation per frame.
		EVENT_MANAGER:RegisterForUpdate("HarvestMap-GC", 0, clearMemory)
	end
end

function Data:CreateNewCache(mapMetaData)
	local cache = Harvest.MapCache:New(mapMetaData)	
	self.mapCaches[mapMetaData] = cache
	self.numMapCaches = self.numMapCaches + 1
	self:Info("new map cache for map", mapMetaData.map, mapMetaData.zoneId)
	
	if self.currentZoneCache and mapMetaData.zoneId == self.currentZoneCache.zoneId then
		self:Info("add map cache to current zone cache with zone id ", self.currentZoneCache.zoneId)
		self.currentZoneCache:AddCache(cache)
		CallbackManager:FireCallbacks(Events.MAP_ADDED_TO_ZONE, cache, self.currentZoneCache)
	end
	
	return cache
end


-- loads the nodes to cache and returns them
function Data:GetMapCache(mapMetaData)
	-- if the current map isn't in the cache, create the cache
	local mapCache = self.mapCaches[mapMetaData]
	if not mapCache then
		if not SubmoduleManager:GetSubmoduleForMap(mapMetaData.map) then return end
		mapCache = self:CreateNewCache(mapMetaData)
		self.mapCaches[mapMetaData] = mapCache
	end
	
	assert(mapCache.mapMetaData == mapMetaData, "MapMetaData of the zone cache does not match!")

	return mapCache
end

function Data:GetCurrentZoneCache()
	return self.currentZoneCache
end

function Data:RefreshZoneCacheForNewZone()
	local zoneIndex = GetUnitZoneIndex("player")
	if self.currentZoneCache and self.currentZoneCache.zoneIndex == zoneIndex then
		self:Info("Player did not enter a new zone (%d)", zoneIndex)
		return
	end
	
	local oldZoneCache = self.currentZoneCache
	
	self.currentZoneCache = self.ZoneCache:New(zoneIndex)
	self:Info("new zone cache for zone id ", self.currentZoneCache.zoneId)
	
	-- add already loaded data, if it belongs to this zone
	for mapMetaData, mapCache in pairs(self.mapCaches) do
		if mapMetaData.zoneId == self.currentZoneCache.zoneId then
			self.currentZoneCache:AddCache(mapCache)
			self:Info("add cached map to zone cache ", mapCache.map)
		end
	end
	
	-- load data for current map
	local mapMetaData = Harvest.mapTools:GetPlayerMapMetaData()
	self:GetMapCache(mapMetaData)
	
	-- try to load data for other maps in this zone
	local submodule = SubmoduleManager:GetSubmoduleForMap(mapMetaData.map)
	if submodule then
		local data = submodule.downloadedVars[mapMetaData.zoneId]
		if data then
			for map in pairs(data) do
				self:GetMapCache(Harvest.mapTools:GetMapMetaDataForZoneIndexAndMap(mapMetaData.zoneIndex, map))
				self:Info("add downloaded map to zone cache ", mapMetaData.map)
			end
		end
	end
	
	-- inform other modules about the new zone cache
	CallbackManager:FireCallbacks(Events.NEW_ZONE_ENTERED, self.currentZoneCache)
	-- at this point, nothing should access the zone cache anymore, so let's delete it
	if oldZoneCache then
		oldZoneCache:Dispose()
	end
end

function Data:CheckPinTypeInCache(pinTypeId, mapCache)
	if not mapCache:DoesHandlePinType(pinTypeId) then
		Serialization:LoadNodesOfPinTypeToCache(pinTypeId, mapCache)
	end
end
