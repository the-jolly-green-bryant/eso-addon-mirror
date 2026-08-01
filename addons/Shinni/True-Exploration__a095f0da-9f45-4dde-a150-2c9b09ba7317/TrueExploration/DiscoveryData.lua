
local DiscoveryData = ZO_Object:Subclass()
TrueExplor = TrueExplor or {}
TrueExplor.discoveryData = DiscoveryData

local NUM_UNITS = TrueExplor.total_units
local UNITS_PER_NUMBER = TrueExplor.unitsPerNumber
local BITS = 7

local zo_floor = zo_floor
local zo_min = zo_min
local zo_max = zo_max

function DiscoveryData:Load(data)
	setmetatable(data, self)
	return data
end

function DiscoveryData:PreFill(data, mapId)
	setmetatable(data, self)
	data:Initialize(mapId)
	return data
end

DiscoveryData.validPinTypes = {
	[MAP_PIN_TYPE_POI_SUGGESTED] = true,
	[MAP_PIN_TYPE_POI_SEEN] = true,
	[MAP_PIN_TYPE_POI_COMPLETE] = true,
	[MAP_PIN_TYPE_SKYSHARD_SEEN] = true,
	[MAP_PIN_TYPE_SKYSHARD_SUGGESTED] = true,
	[MAP_PIN_TYPE_SKYSHARD_COMPLETE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC] = true,
}

function DiscoveryData:Initialize(mapId)
	local currentMapId = GetCurrentMapId()
	SetMapToMapId(mapId)
	local units = NUM_UNITS
	local zoneIndex = GetCurrentMapZoneIndex()
	local numPOI = GetNumPOIs(zoneIndex)
	local POIsX = {}
	local POIsY = {}
	local POIdiscovered = {}
	local numValidPOI = 0
	for poiIndex = 1, numPOI do
		local x, y, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, poiIndex)
		if isShownInCurrentMap and self.validPinTypes[poiPinType] then
			numValidPOI = numValidPOI + 1
			POIsX[numValidPOI] = x * units
			POIsY[numValidPOI] = y * units
			POIdiscovered[numValidPOI] = isDiscovered
		end
	end
	
	local smallestDist, dx, dy, dist, closestPOI
	for x = 0, units-1 do
		for y = 0, units-1 do
			smallestDist = math.huge
			for i = 1, numValidPOI do
				dx = x - POIsX[i]
				dy = y - POIsY[i]
				dist = dx * dx + dy * dy
				if dist < smallestDist then
					smallestDist = dist
					closestPOI = i
				end
			end
			if POIdiscovered[closestPOI] then
				self:Discover(x, y)
			end
		end
	end
	
	SetMapToMapId(currentMapId)
end

function DiscoveryData:IsCompletelyDiscovered()
	return self.discovered
end

function DiscoveryData:SetCompletelyDiscovered(isDicovered)
	isDicovered = not not isDicovered -- force boolean because this is serialized
	self.discovered = isDicovered
end

function DiscoveryData:UndiscoverInRadius(x, y, radius)
	assert(not self.discovered)
	local hasChanged = false
	
	local unit
	local num, bit
	local units = NUM_UNITS
	local unitsPerNumber = UNITS_PER_NUMBER
	for i = x - radius, x + radius do
		for j = y - radius, y + radius do
			if self:IsDiscovered(i, j) then
				hasChanged = true
				unit = i + j * units
				num = zo_floor(unit / unitsPerNumber)
				bit = unit % unitsPerNumber
				self[num] = self[num] - (2^bit)
			end
		end
	end
	return hasChanged
end

function DiscoveryData:Discover(x, y)
	local hasChanged = false
	
	if not self:IsDiscovered(x, y) then
		hasChanged = true
		local unitId = (y * NUM_UNITS + x)
		local num = zo_floor(unitId / UNITS_PER_NUMBER)
		local bit = unitId % UNITS_PER_NUMBER
		self[num] = (self[num] or 0) + (2^bit)
	end
	return hasChanged
end

function DiscoveryData:IsDiscovered(x, y)
	if self.discovered then return true end
	if x < 0 or x > NUM_UNITS or y < 0 or y > NUM_UNITS then return false end
	local unit = x + y * NUM_UNITS
	local num = zo_floor(unit / UNITS_PER_NUMBER)
	local bit = unit % UNITS_PER_NUMBER
	local save = self[num]
	if save then
		return ((save / (2^bit)) % 2 >= 1)
	end
	return false
end

function DiscoveryData:AnyDiscoveredInVerticalLine(x, y, length)
	local numUnits = NUM_UNITS
	if x > numUnits or x < 0 then return 0 end
	local unit, num, bit, save
	local unitsPerNumber = UNITS_PER_NUMBER
	for j = zo_max(0, y - length), zo_min(y + length, numUnits-1) do
		unit = x + j * numUnits
		num = zo_floor(unit / unitsPerNumber)
		bit = unit % unitsPerNumber
		save = self[num]
		if save and ((save / (2^bit)) % 2 >= 1) then
			return 1
		end
	end
	return 0
end

function DiscoveryData:IsAnyDiscoveredInRadius(x, y, radius)
	local num, bit
	local numUnits = NUM_UNITS
	local unitsPerNumber = UNITS_PER_NUMBER
	if radius == 1 then
		unit = x + y * numUnits
		num = zo_floor(unit / unitsPerNumber)
		bit = unit % unitsPerNumber
		save = self[num]
		if save and ((save / (2^bit)) % 2 >= 1) then
			return true
		end
		unit = (x-1) + y * numUnits
		num = zo_floor(unit / unitsPerNumber)
		bit = unit % unitsPerNumber
		save = self[num]
		if save and ((save / (2^bit)) % 2 >= 1) then
			return true
		end
		unit = (x+1) + y * numUnits
		num = zo_floor(unit / unitsPerNumber)
		bit = unit % unitsPerNumber
		save = self[num]
		if save and ((save / (2^bit)) % 2 >= 1) then
			return true
		end
		unit = x + (y-1) * numUnits
		num = zo_floor(unit / unitsPerNumber)
		bit = unit % unitsPerNumber
		save = self[num]
		if save and ((save / (2^bit)) % 2 >= 1) then
			return true
		end
		unit = x + (y+1) * numUnits
		num = zo_floor(unit / unitsPerNumber)
		bit = unit % unitsPerNumber
		save = self[num]
		if save and ((save / (2^bit)) % 2 >= 1) then
			return true
		end
		return false
	end
	if radius > 1 then
		radius = radius - 1
	end
	local startX = zo_max(0,x - radius)
	local endX = zo_min(x + radius, numUnits)
	for j = zo_max(0, y - radius), zo_min(y + radius, numUnits) do
		for i = startX, endX do
			unit = i + j * numUnits
			num = zo_floor(unit / unitsPerNumber)
			bit = unit % unitsPerNumber
			save = self[num]
			if save and ((save / (2^bit)) % 2 >= 1) then
				return true
			end
		end
	end
	return false
end
