
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

local ZoneCache = ZO_Object:Subclass()
Harvest.Data.ZoneCache = ZoneCache

function ZoneCache:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function ZoneCache:Initialize(zoneIndex)
	self.zoneIndex = zoneIndex
	self.zoneId = GetZoneId(zoneIndex)
	self.mapCaches = {}
end

function ZoneCache:AddCache(cache)
	local prevCache = self.mapCaches[cache.map]
	if prevCache == cache then
		return
	end
	if prevCache then
		prevCache:UnregisterAccess(self)
		self.mapCaches[cache.map] = nil
	end
	
	-- check if some nodes exist on both caches
	local pinTypeId, otherNode
	for map, otherCache in pairs(self.mapCaches) do
		assert(cache ~= otherCache)
		local isCacheLarger = cache.lastNodeId > otherCache.lastNodeId
		
		for nodeId = 1, cache.lastNodeId do
			pinTypeId = cache.pinTypeId[nodeId]
			if pinTypeId then
				otherNode = otherCache:GetMergeableNode(pinTypeId, cache.worldX[nodeId], cache.worldY[nodeId], cache.worldZ[nodeId])
				if otherNode then
					-- nodes can be merged, delete node from ancestor map
					if isCacheLarger then
						CallbackManager:FireCallbacks(Events.NODE_DELETED, otherCache, otherNode)
						otherCache:Delete(otherNode)
					else
						CallbackManager:FireCallbacks(Events.NODE_DELETED, cache, nodeId)
						cache:Delete(nodeId)
					end
				end
			end
		end
	end
	assert(self.mapCaches[cache.map] == nil)
	self.mapCaches[cache.map] = cache
	cache:RegisterAccess(self)
	CallbackManager:FireCallbacks(Events.MAP_ADDED_TO_ZONE, cache, self)
end

function ZoneCache:HasMapCache()
	return (next(self.mapCaches) ~= nil)
end

function ZoneCache:ForNearbyNodes(...)
	for _, mapCache in pairs(self.mapCaches) do
		mapCache:ForNearbyNodes(...)
	end
end

function ZoneCache:ForNodesInRange(...)
	for _, mapCache in pairs(self.mapCaches) do
		mapCache:ForNodesInRange(...)
	end
end

function ZoneCache:Dispose()
	for map, mapCache in pairs(self.mapCaches) do
		mapCache:UnregisterAccess(self)
	end
	self.mapCaches = nil
end

function ZoneCache:DoesHandleMapCache(mapCache)
	return (self.mapCaches[mapCache.map] == mapCache)
end
