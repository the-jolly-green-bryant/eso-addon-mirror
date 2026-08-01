
local zo_min = _G["zo_min"]
local zo_max = _G["zo_max"]
local zo_ceil = _G["zo_ceil"]
local zo_floor = _G["zo_floor"]
local pairs = _G["pairs"]
local ipairs = _G["ipairs"]

local MapCache = Harvest.MapCache

function MapCache:ForNodesInRange(worldX, worldY, heading, visibleDistanceInMeters, callback, ...)
	local DivisionWidthInMeters = self.DivisionWidthInMeters
	local maxDistance = visibleDistanceInMeters + 0.71 * DivisionWidthInMeters
	local maxDistanceSquared = maxDistance * maxDistance
	local distToCenter = 0.71 * DivisionWidthInMeters
	
	local startX = zo_floor((worldX - visibleDistanceInMeters) / DivisionWidthInMeters)
	local startY = zo_floor((worldY - visibleDistanceInMeters) / DivisionWidthInMeters)
	local endX = (worldX + visibleDistanceInMeters) / DivisionWidthInMeters
	local endY = (worldY + visibleDistanceInMeters) / DivisionWidthInMeters

	local range = zo_ceil(visibleDistanceInMeters / DivisionWidthInMeters)
	
	local dirX = math.sin(heading)
	local dirY = math.cos(heading)
	
	local numDivisions = self.numDivisions

	local division, dx, dy, divisions
	local centerX, centerY, index
	
	for j = startY, endY do
		centerY = (j+0.5) * DivisionWidthInMeters
		dy = centerY - worldY
		for i = startX, endX do
			centerX = (i+0.5) * DivisionWidthInMeters
			dx = centerX - worldX
			if dx * dirX + dy * dirY < distToCenter and dx * dx + dy * dy < maxDistanceSquared then
				index = (i + j * numDivisions) % self.TotalNumDivisions
				callback(index, ...)
			end
		end
	end
end
