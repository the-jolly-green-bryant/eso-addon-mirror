-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

--[[
EASLoreLibraryData[zoneId] is a string encoding every book in that zone.
Each book is 8 bytes: 2 bytes worldX, 2 bytes worldY, 2 bytes worldZ, 4 bytes bookId.
Coordinates are stored as (highByte * 256 + lowByte) * 0.2, i.e. in meters with 0.2m resolution.
bookId is stored unscaled.
]]--

local Serialization = {}
EASLoreLibrary:RegisterModule("serialization", Serialization)

function Serialization:Initialize()
	--[[
	self.childZoneIds = {}
	local parentZoneId, list
	for zoneId, data in pairs(EASLoreLibraryData) do
		parentZoneId = GetParentZoneId(zoneId)
		if parentZoneId ~= 0 then
			if not self.childZoneIds[parentZoneId] then
				self.childZoneIds[parentZoneId] = {}
			end
			list = self.childZoneIds[parentZoneId]
			list[#list + 1] = zoneId
		end
	end
	]]--
end

function Serialization:LoadZoneToCache(zoneCache)
	local data = EASLoreLibraryData[zoneCache.zoneId]
	if not data then
		return 0
	end

	assert(#data % 10 == 0, "corrupt EASLoreLibraryData entry: length is not a multiple of 10")

	local numAddedNodes = 0
	local x1, x2, y1, y2, z1, z2, b1, b2, b3, b4
	local worldX, worldY, worldZ, bookId
	for dataIndex = 1, #data, 10 do
		x1, x2, y1, y2, z1, z2, b1, b2, b3, b4 = data:byte(dataIndex, dataIndex + 9)

		worldX = (x1 * 256 + x2) * 0.2
		worldY = (y1 * 256 + y2) * 0.2
		worldZ = (z1 * 256 + z2) * 0.2
		bookId = ((b1 * 256 + b2) * 256 + b3) * 256 + b4

		if zoneCache:AddBook(bookId, worldX, worldY, worldZ) then
			numAddedNodes = numAddedNodes + 1
		end
	end

	self:Debug("loaded %d books for zone id %d", numAddedNodes, zoneCache.zoneId)

	return numAddedNodes
end

-- returns an array of {zoneId, worldX, worldY, worldZ} for every zone whose
-- encoded data contains searchedBookId (one entry per zone, using the first
-- matching record), without deserializing/caching the zones involved.
-- Searches for the raw 4-byte encoding of the bookId via string.find (a
-- C-side substring search) rather than manually walking every 10-byte record
-- in Lua, then discards any coincidental match that isn't aligned to a
-- record's bookId field.
function Serialization:FindBookLocations(searchedBookId)
	local bookId = searchedBookId
	local b4 = bookId % 256
	bookId = (bookId - b4) / 256
	local b3 = bookId % 256
	bookId = (bookId - b3) / 256
	local b2 = bookId % 256
	local b1 = (bookId - b2) / 256
	local pattern = string.char(b1, b2, b3, b4)

	local locations = {}
	for zoneId, data in pairs(EASLoreLibraryData) do
		local searchIndex = 1
		while true do
			local foundIndex = data:find(pattern, searchIndex, true)
			if not foundIndex then
				break
			end
			if (foundIndex - 1) % 10 == 6 then
				local dataIndex = foundIndex - 6
				local x1, x2, y1, y2, z1, z2 = data:byte(dataIndex, dataIndex + 5)
				table.insert(locations, {
					zoneId = zoneId,
					worldX = (x1 * 256 + x2) * 0.2,
					worldY = (y1 * 256 + y2) * 0.2,
					worldZ = (z1 * 256 + z2) * 0.2,
				})
				break
			end
			searchIndex = foundIndex + 1
		end
	end
	return locations
end
