
local Location = FasterTravel.Location or {}

local function DistanceSquared(x1,y1,x2,y2)
	x1,y1 = (x1 or 0),(y1 or 0)
	x2,y2 = (x2 or 0),(y2 or 0)
	local dx,dy = (x2-x1),(y2-y1)
	return (dx * dx)+(dy * dy)
end

local function GetClosestLocation(normalizedX,normalizedY,locations)
	if normalizedX == nil or normalizedY == nil or locations == nil then return end
	
	local count = #locations 
	
	if count <= 1 then return locations[1] end 
	
	local closest = locations[1]
	
	local loc
	local cur
	local x,y = closest.normalizedX,closest.normalizedY
	local dist = DistanceSquared(normalizedX,normalizedY,x,y)

	for i=2, count do 
		loc = locations[i]
		
		x,y = loc.normalizedX,loc.normalizedY

		cur = DistanceSquared(normalizedX,normalizedY,x,y)
		
		if cur < dist then
			closest = loc 
			dist = cur
		end

	end
	
	return closest
end


local function IsCyrodiil(loc)
	if loc == nil then return false end
	return loc.zone == "cyrodiil"
end

Location.GetClosestLocation = GetClosestLocation
Location.IsCyrodil = IsCyrodiil

FasterTravel.Location = Location 