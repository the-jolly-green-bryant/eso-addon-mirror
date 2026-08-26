-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

--[[
Each ZoneCache stores the deserialized book nodes for one zone (EASLoreLibraryData[zoneId]).

Books can arrive in any order (however they happen to be encoded in
EASLoreLibraryData), but AddBook always inserts each node right at the end of
its own pin type's block, keeping every pin type's nodeIds contiguous without
a separate sort pass. Making room is a cascade: whatever already occupied the
insertion slot is carried forward to the end of the next pin type's block,
displacing whatever was there in turn, and so on, until a genuinely free slot
is reached (guaranteed by the time the last pin type is processed, since that
slot is the newly created one). Once the carried node lands, every pin type
after it still has its end bumped up to match (even though nothing physically
moves there) - otherwise a pin type that stayed empty while an earlier one
grew past it would fall behind, and a later insertion straight into it would
compute a stale, wrong position. That's O(#PINTYPES) work, trivial since
there are only 2 pin types. A node's pin type can then be found with a
threshold comparison instead of a nodeId -> pinTypeId lookup table.
--]]
local ZoneCache = ZO_Object:Subclass()
EASLoreLibrary.ZoneCache = ZoneCache

function ZoneCache:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function ZoneCache:Initialize(zoneId)
	self.time = GetFrameTimeSeconds()
	self.accessed = 0
	self.lastNodeId = 0
	self.zoneId = zoneId

	self.bookId = {}
	self.worldX = {}
	self.worldY = {}
	self.worldZ = {}

	-- pinTypeId -> nodeId of the last node in that pin type's contiguous
	-- block; a block spans (previous pin type's end + 1) .. this end
	self.pinTypeEnd = {}
	for _, pinTypeId in ipairs(EASLoreLibrary.PINTYPES) do
		self.pinTypeEnd[pinTypeId] = 0
	end
end

function ZoneCache:RegisterAccess(accessor)
	self.accessed = self.accessed + 1
end

function ZoneCache:UnregisterAccess(accessor)
	self.accessed = self.accessed - 1
end

local GetNormalizedWorldPosition = GetNormalizedWorldPosition
function ZoneCache:GetLocal(nodeId)
	return GetNormalizedWorldPosition(self.zoneId, self.worldX[nodeId] * 100, self.worldZ[nodeId] * 100, self.worldY[nodeId] * 100)
end

function ZoneCache:Dispose()
	assert(self.accessed == 0, "attempted to dispose of zone cache, but something is still accessing it")
	ZO_ClearTable(self.bookId)
	ZO_ClearTable(self.worldX)
	ZO_ClearTable(self.worldY)
	ZO_ClearTable(self.worldZ)
	self.bookId = nil
	self.worldX = nil
	self.worldY = nil
	self.worldZ = nil
	self.pinTypeEnd = nil
end

-----------------------------------------------------------
-- Methods to add and query data in the cache
-----------------------------------------------------------

-- returns nil without adding a node if the bookId does not belong to a lore
-- category we display pins for. Otherwise inserts it at the end of
-- pinTypeId's block, cascading any displaced node forward (see file header)
-- to keep every pin type's nodeIds contiguous.
function ZoneCache:AddBook(bookId, worldX, worldY, worldZ)
	local pinTypeId = EASLoreLibrary.GetPinTypeForBookId(bookId)
	if not pinTypeId then
		return nil
	end

	local oldLastNodeId = self.lastNodeId
	self.lastNodeId = oldLastNodeId + 1

	local insertNodeId
	local carryBookId, carryWorldX, carryWorldY, carryWorldZ = bookId, worldX, worldY, worldZ
	local carrying = true

	local growing = false
	for _, otherPinTypeId in ipairs(EASLoreLibrary.PINTYPES) do
		growing = growing or (otherPinTypeId == pinTypeId)
		if growing then
			if carrying then
				local targetNodeId = self.pinTypeEnd[otherPinTypeId] + 1
				insertNodeId = insertNodeId or targetNodeId

				local occupied = targetNodeId <= oldLastNodeId
				local displacedBookId, displacedWorldX, displacedWorldY, displacedWorldZ
				if occupied then
					displacedBookId, displacedWorldX, displacedWorldY, displacedWorldZ =
						self.bookId[targetNodeId], self.worldX[targetNodeId], self.worldY[targetNodeId], self.worldZ[targetNodeId]
				end

				self.bookId[targetNodeId] = carryBookId
				self.worldX[targetNodeId] = carryWorldX
				self.worldY[targetNodeId] = carryWorldY
				self.worldZ[targetNodeId] = carryWorldZ
				self.pinTypeEnd[otherPinTypeId] = targetNodeId

				if occupied then
					carryBookId, carryWorldX, carryWorldY, carryWorldZ = displacedBookId, displacedWorldX, displacedWorldY, displacedWorldZ
				else
					carrying = false
				end
			else
				-- nothing left to carry, but this pin type's end must still
				-- keep pace with the type(s) before it (it may have been
				-- lagging behind if it had zero nodes while an earlier type
				-- just grew past it), or a future insertion directly into
				-- this type would compute the wrong position
				self.pinTypeEnd[otherPinTypeId] = self.lastNodeId
			end
		end
	end

	return insertNodeId
end

-- returns the inclusive [firstNodeId, lastNodeId] range for pinTypeId; the
-- range may contain holes (nil bookId) for nodes removed via RemoveNodeId.
-- previousPinTypeId is the pin type immediately before this one in
-- EASLoreLibrary.PINTYPES order (nil if pinTypeId is the first one) - callers
-- already iterate EASLoreLibrary.PINTYPES in order, so they can track it
-- themselves instead of having this function re-scan PINTYPES every time.
function ZoneCache:GetNodeIdRange(pinTypeId, previousPinTypeId)
	local firstNodeId = previousPinTypeId and (self.pinTypeEnd[previousPinTypeId] + 1) or 1
	return firstNodeId, self.pinTypeEnd[pinTypeId]
end

-- returns an array of every nodeId in this cache whose book is
-- searchedBookId - usually one, but the same book can be findable more than
-- once within a single zone
function ZoneCache:GetNodeIdsForBookId(searchedBookId)
	local nodeIds = {}
	for nodeId, bookId in pairs(self.bookId) do
		if bookId == searchedBookId then
			table.insert(nodeIds, nodeId)
		end
	end
	return nodeIds
end

function ZoneCache:GetPinTypeIdForNodeId(searchedNodeId)
	for _, pinTypeId in ipairs(EASLoreLibrary.PINTYPES) do
		if searchedNodeId <= self.pinTypeEnd[pinTypeId] then
			return pinTypeId
		end
	end
	return nil
end

function ZoneCache:RemoveNodeId(nodeId)
	self.bookId[nodeId] = nil
	self.worldX[nodeId] = nil
	self.worldY[nodeId] = nil
	self.worldZ[nodeId] = nil
end
