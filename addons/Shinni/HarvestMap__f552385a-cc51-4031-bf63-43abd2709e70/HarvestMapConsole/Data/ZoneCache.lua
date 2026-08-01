
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

function ZoneCache:AddCache(mapCache)
	local prevCache = self.mapCaches[mapCache.map]
	if prevCache == mapCache then
		return
	end
	if prevCache then
		prevCache:UnregisterAccess(self)
		self.mapCaches[mapCache.map] = nil
	end
	
	-- add mapCache
	self.mapCaches[mapCache.map] = mapCache
	mapCache:RegisterAccess(self)
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
