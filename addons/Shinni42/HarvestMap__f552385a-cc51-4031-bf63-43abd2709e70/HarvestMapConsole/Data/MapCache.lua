
local zo_min = _G["zo_min"]
local zo_max = _G["zo_max"]
local zo_ceil = _G["zo_ceil"]
local zo_floor = _G["zo_floor"]
local pairs = _G["pairs"]
local ipairs = _G["ipairs"]

local TYPED = false
--[[
Each MapCache stores deserialized nodes for the given map.
--]]
local MapCache = ZO_Object:Subclass()
Harvest.MapCache = MapCache

MapCache.DivisionWidthInMeters = 100
MapCache.numDivisions = 40
MapCache.TotalNumDivisions = MapCache.numDivisions * MapCache.numDivisions
MapCache.MergeDistanceInMeters = 7
MapCache.MergeDistanceSquared = MapCache.MergeDistanceInMeters * MapCache.MergeDistanceInMeters

function MapCache:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function MapCache:Initialize(mapMetaData)
	self.time = GetFrameTimeSeconds()
	self.accessed = 0
	
	self.map = mapMetaData.map
	self.lastNodeId = 0
	self.mapMetaData = mapMetaData
	
	self.worldX = {}
	self.worldY = {}
	self.worldZ = {}
	
	self.hasCompassPin = {}
	
	self.nodesOfPinTypeStart = {}
	self.nodesOfPinTypeEnd = {}
	self.orderedPinTypes = {}
	
	self:RefreshNearestNeighborLookupTable()
	
	--self.maxDensity = 0
end

function MapCache:RegisterAccess(accessor)
	self.accessed = self.accessed + 1
end

function MapCache:UnregisterAccess(accessor)
	self.accessed = self.accessed - 1
end

function MapCache:RefreshNearestNeighborLookupTable()
	
	self.divisions = {}
	if TYPED then self.typedDivisions = {} end
	for nodeId in pairs(self.worldX) do
		self:InsertNodeIntoDivision(nodeId)
	end
end

function MapCache:Dispose()
	assert(self.accessed == 0, "num accesses is " .. tostring(self.accessed))
	ZO_ClearTable(self.worldX)
	ZO_ClearTable(self.worldY)
	ZO_ClearTable(self.worldZ)
	ZO_ClearTable(self.hasCompassPin)
	ZO_ClearTable(self.nodesOfPinTypeEnd)
	ZO_ClearTable(self.nodesOfPinTypeStart)
	ZO_ClearTable(self.orderedPinTypes)
	if TYPED then
		for pinTypeId, divisions in pairs(self.typedDivisions) do
			ZO_ClearTable(divisions)
		end
		ZO_ClearTable(self.typedDivisions)
		self.typedDivisions = nil
	end
	ZO_ClearTable(self.divisions)
	
	self.worldX = nil
	self.worldY = nil
	self.worldZ = nil
	self.hasCompassPin = nil
	self.nodesOfPinTypeStart = nil
	self.nodesOfPinTypeEnd = nil
	self.orderedPinTypes = nil
	self.divisions = nil
end

function MapCache:InsertNodeIntoDivision(nodeId)
	local worldX, worldY = self.worldX[nodeId], self.worldY[nodeId]
		
	local index = (zo_floor(worldX / self.DivisionWidthInMeters) + zo_floor(worldY / self.DivisionWidthInMeters) * self.numDivisions) % self.TotalNumDivisions
	local division = self.divisions[index] or {}
	self.divisions[index] = division
	division[#division+1] = nodeId
	
	--[[
	local density = 0
	for x = zo_floor(worldX / self.DivisionWidthInMeters) - 2, zo_floor(worldX / self.DivisionWidthInMeters) + 2 do
		for y = zo_floor(worldY / self.DivisionWidthInMeters) - 2, zo_floor(worldY / self.DivisionWidthInMeters) + 2 do
			local index = (x + y * self.numDivisions) % self.TotalNumDivisions
			density = density + #(self.divisions[index] or {})
		end
	end
	self.maxDensity = zo_max(self.maxDensity, density)
	]]--
	
	if TYPED then
		local pinTypeId = self.initializingPinType --self:RetrievePinTypeId(nodeId)
		division = self.typedDivisions[pinTypeId][index] or {}
		self.typedDivisions[pinTypeId][index] = division
		division[#division+1] = nodeId
	end
end

function MapCache:InitializePinType(pinTypeId)
	self.nodesOfPinTypeStart[pinTypeId] = self.lastNodeId + 1
	assert(self.initializingPinType == nil, "Did not finish initializing previous pintype")
	self.initializingPinType = pinTypeId
	table.insert(self.orderedPinTypes, pinTypeId)
	if TYPED then
		self.typedDivisions[pinTypeId] = {}
	end
end

function MapCache:FinalizePinType(pinTypeId)
	assert(self.initializingPinType == pinTypeId)
	self.initializingPinType = nil
	self.nodesOfPinTypeEnd[pinTypeId] = self.lastNodeId
end

function MapCache:DoesHandlePinType(pinTypeId)
	return (self.nodesOfPinTypeEnd[pinTypeId] ~= nil)
end

function MapCache:RetrievePinTypeId(nodeId)
	for pinTypeId, start in pairs(self.nodesOfPinTypeStart) do
		if nodeId >= start and nodeId <= self.nodesOfPinTypeEnd[pinTypeId] then
			return pinTypeId
		end
	end
end

-----------------------------------------------------------
-- Methods to add, delete and update data in the cache
-----------------------------------------------------------

function MapCache:Add(worldX, worldY, worldZ)
	assert(self.initializingPinType ~= nil, "Cannot delete pin after initialization")
	
	self.lastNodeId = self.lastNodeId + 1
	local nodeId = self.lastNodeId

	self.worldX[nodeId] = worldX
	self.worldY[nodeId] = worldY
	self.worldZ[nodeId] = worldZ
	
	self:InsertNodeIntoDivision(nodeId)

	return nodeId
end

local GetNormalizedWorldPosition = GetNormalizedWorldPosition
function MapCache:GetLocal(nodeId)
	assert(nodeId)
	local zoneId = self.mapMetaData.zoneId
	return GetNormalizedWorldPosition(zoneId, self.worldX[nodeId] * 100, (self.worldZ[nodeId] or 0) * 100, self.worldY[nodeId] * 100)
end

function MapCache:GetMergeableNode(pinTypeId, worldX, worldY, worldZ, bestDistanceSquared)
	self.time = GetFrameTimeSeconds()
	
	local useWorldZ = 1
	if not worldZ then
		worldZ = 0
		useWorldZ = 0
	end
	
	local divisions = self.divisions
	if not divisions then return end
	
	local division, dx, dy, dz, distanceSquared
	local MergeDistanceInMeters = self.MergeDistanceInMeters
	local InverseDivisionWidthInMeters = 1 / self.DivisionWidthInMeters
	local startX = zo_floor((worldX - MergeDistanceInMeters) * InverseDivisionWidthInMeters)
	local startY = zo_floor((worldY - MergeDistanceInMeters) * InverseDivisionWidthInMeters)
	local endX = (worldX + MergeDistanceInMeters) * InverseDivisionWidthInMeters
	local endY = (worldY + MergeDistanceInMeters) * InverseDivisionWidthInMeters
	
	local bestDistanceSquared = bestDistanceSquared or self.MergeDistanceSquared
	local bestNodeId = nil
	
	for i = startX, endX do
		for j = startY, endY do
			division = divisions[(i + j * self.numDivisions) % self.TotalNumDivisions]
			if division then
				for _, nodeId in pairs(division) do
					dx = self.worldX[nodeId] - worldX
					dy = self.worldY[nodeId] - worldY
					dz = self.worldZ[nodeId] - worldZ
					distanceSquared = dx * dx + dy * dy + dz * dz * useWorldZ
					if distanceSquared < bestDistanceSquared then
						if (not pinTypeId) or (pinTypeId == self:RetrievePinTypeId(nodeId)) then
							bestNodeId = nodeId
							bestDistanceSquared = distanceSquared
						end
					end
				end
			end
		end
	end
	
	--d(bestDistance)
	if bestDistanceSquared < self.MergeDistanceSquared then
		return bestNodeId, bestDistanceSquared
	end
	
	return nil--bestNodeId
end
