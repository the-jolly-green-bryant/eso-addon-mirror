
local Serialization = LoreLibrary.serialization

local Data = {}
zo_mixin(Data, ZO_CallbackObject)
LoreLibrary:RegisterModule("data", Data)

--[[
Keeps one ZoneCache per zoneId, so re-entering a zone does not require
re-parsing LoreLibraryData every time.

Fires the "BookRemoved" callback (zoneId, nodeId, pinTypeId, bookId) whenever
a cached book is removed, e.g. because the player just discovered it. Pin
modules listen for this to drop any pin they've drawn for that node.
]]--

function Data:Initialize()
	self.zoneCaches = {}

	EVENT_MANAGER:RegisterForEvent("LoreLibrary-Data", EVENT_LORE_BOOK_LEARNED, function(eventCode, categoryIndex, collectionIndex, bookIndex)
		local _, _, _, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
		if bookId then
			self:RemoveBook(bookId)
		end
	end)

	EVENT_MANAGER:RegisterForEvent("LoreLibrary-Data", EVENT_PLAYER_ACTIVATED, function()
		self:PruneUnaccessedCaches()
	end)
end

-- disposes of and forgets every cached zone that nothing is currently accessing
function Data:PruneUnaccessedCaches()
	for zoneId, zoneCache in pairs(self.zoneCaches) do
		if zoneCache.accessed == 0 then
			zoneCache:Dispose()
			self.zoneCaches[zoneId] = nil
		end
	end
end

-- removes every cached node for bookId (it can be findable more than once,
-- even within the same zone) from whichever ZoneCaches hold it, and fires
-- "BookRemoved" per removed node so pin modules can drop the pin drawn for it
function Data:RemoveBook(bookId)
	for zoneId, zoneCache in pairs(self.zoneCaches) do
		local nodeIds = zoneCache:GetNodeIdsForBookId(bookId)
		for _, nodeId in pairs(nodeIds) do
			local pinTypeId = zoneCache:GetPinTypeIdForNodeId(nodeId)
			self:FireCallbacks("BookRemoved", zoneId, nodeId, pinTypeId, bookId)
		end
		for _, nodeId in pairs(nodeIds) do
			zoneCache:RemoveNodeId(nodeId)
		end
	end
end

function Data:CreateNewCache(zoneId)
	local zoneCache = LoreLibrary.ZoneCache:New(zoneId)
	self.zoneCaches[zoneId] = zoneCache
	self:Info("new zone cache for zone id %d", zoneId)

	Serialization:LoadZoneToCache(zoneCache)

	return zoneCache
end

-- returns the (lazily created and loaded) ZoneCache for the given zoneId
function Data:GetZoneCache(zoneId)
	local zoneCache = self.zoneCaches[zoneId]
	if not zoneCache then
		zoneCache = self:CreateNewCache(zoneId)
	end
	return zoneCache
end

-- returns an array of {zoneId, worldX, worldY, worldZ, mapId, zoneName,
-- inSubZone} for every zone that has a copy of bookId, without
-- deserializing/caching every zone just to answer the query. mapId falls
-- back to the parent zone's map for zones with no map of their own (e.g.
-- delves/dungeons), with inSubZone set so callers can list those last.
-- Sorted alphabetically by zoneName, ordinary zones before sub-zones.
function Data:GetBookLocations(bookId)
	local locations = Serialization:FindBookLocations(bookId)

	for _, location in pairs(locations) do
		location.mapId = GetMapIdByZoneId(location.zoneId)
		location.zoneName = GetZoneNameById(location.zoneId)
		if location.mapId == 0 then
			location.mapId = GetMapIdByZoneId(GetParentZoneId(location.zoneId))
			location.inSubZone = true
		end
	end

	table.sort(locations, function(a, b)
		if a.inSubZone == b.inSubZone then
			return a.zoneName < b.zoneName
		end
		return not a.inSubZone
	end)

	return locations
end
