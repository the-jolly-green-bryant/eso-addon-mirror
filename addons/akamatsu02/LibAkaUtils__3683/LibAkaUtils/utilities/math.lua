LibAkaUtils = LibAkaUtils or {}

local MAX_DISTANCE = 5000

function math.clamp(self, min, max)
    if self < min then self = min end
    if self > max then self = max end
    return self
end

function math.increase(self)
	if self == nil then 
		self = 0
	end
	self = self + 1
	return self
end

function math.decrease(self)
	if self == nil then 
		self = 0
	end
	self = self - 1
	return self
end

function LibAkaUtils.getCircleCoordinates(x, y, z, radius, size)
	local tab = {}
    local vara = radius
    local varb = 0
    local varc = 0
 
	while vara >= varb do
		if vara % 2 == 0 and varb % 2 == 0 then
			table.insert(tab, {x = x + vara, y = y, z = z + varb})
			table.insert(tab, {x = x + varb, y = y, z = z + vara})
			table.insert(tab, {x = x - varb, y = y, z = z + vara})
			table.insert(tab, {x = x - vara, y = y, z = z + varb})
			table.insert(tab, {x = x - vara, y = y, z = z - varb})
			table.insert(tab, {x = x - varb, y = y, z = z - vara})
			table.insert(tab, {x = x + varb, y = y, z = z - vara})
			table.insert(tab, {x = x + vara, y = y, z = z - varb})
		end
		if varc <= 0 then
			varb = varb + size
			varc = varc + 2 * varb + 1
		end
		
		if varc > 0 then
			vara = vara - size
			varc = varc - 2 * vara + 1
		end
    end
	return tab
end

function LibAkaUtils.getLineCoordinates(x1, y1, z1, x2, y2, z2, pointDistance, amountOfPoints)
	if amountOfPoints == nil then
		pointDistance = pointDistance or 200
		local distance = LibAkaUtils.getDistance(x1, y1, z1, x2, y2, z2)
		amountOfPoints = math.floor(distance / pointDistance)
	end
	if amountOfPoints < 1 then return {} end
	local ix = (x2 - x1)/amountOfPoints
	local iy = (y2 - y1)/amountOfPoints
	local iz = (z2 - z1)/amountOfPoints
	local tab = {}
	LibAkaUtils.forLoopToEnd(amountOfPoints - 1, function(i)
		table.insert(tab, {
			x = x1 + ix * i, 
			y = y1 + iy * i, 
			z = z1 + iz * i
		})
	end)
	return tab
end

function LibAkaUtils.rotationsToPointInDistance(camVector, yaw, pitch, distance)
	if distance > MAX_DISTANCE then 
		distance = MAX_DISTANCE 
	end
	if distance <= 0 then 
		distance = 0.1
	end
	local directionVector = Vector:new((math.cos(pitch) * math.cos(yaw)), math.sin(pitch / 2), math.sin(yaw) * math.cos(pitch)):normalize():mul(distance)
	local addVector = Vector:new(directionVector.z, -directionVector.y, directionVector.x)
	return camVector:subVector(addVector)
end

function LibAkaUtils.viewPointToTargetPointSameHeight(playerY, camVector, yaw, pitch)
	local directionVector = Vector:new((math.cos(pitch) * math.cos(yaw)), math.sin(pitch / 2), math.sin(yaw) * math.cos(pitch)):normalize()
	local distance = (playerY - camVector.y) / directionVector.y
	if distance > MAX_DISTANCE then 
		distance = MAX_DISTANCE 
	end
	if distance <= 0 then 
		distance = 0.1
	end
	return Vector:new(camVector.x - directionVector.z * distance, playerY, camVector.z - directionVector.x * distance)
end

function LibAkaUtils.getPlayerPosition()
	local _, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
	return worldX, worldY, worldZ
end

function math.round(self, decimals)
    decimals = math.pow(10, decimals or 0)
    self = self * decimals
    if self >= 0 then self = math.floor(self + 0.5) else self = math.ceil(self - 0.5) end
	self = self / decimals
    return self
end