local SCB = SatuveCoordinateBridge

SCB.Motion = SCB.Motion or {}
local Motion = SCB.Motion

function Motion:Reset(sample)
	self.Anchor = sample
	self.DirectionValid = false
	self.SpeedValid = false
	self.Direction = self.Direction or 0
	self.Speed = 0
	self.DirectionVectorX = nil
	self.DirectionVectorY = nil
end

local function Distance2D(ax, ay, bx, by)
	local dx = ax - bx
	local dy = ay - by
	return math.sqrt(dx * dx + dy * dy)
end

local function HasWorldPosition(sample)
	return sample and tonumber(sample.worldZoneId) and tonumber(sample.worldZoneId) > 0 and
		type(sample.worldX) == "number" and type(sample.worldZ) == "number"
end

function Motion:GetState()
	return {
		direction = self.Direction or 0,
		directionValid = self.DirectionValid == true,
		speed = self.Speed or 0,
		speedValid = self.SpeedValid == true,
	}
end

function Motion:Update(sample)
	if not sample or not sample.coordinatesValid then
		self:Reset(nil)
		return self:GetState()
	end

	local anchor = self.Anchor
	if not anchor then
		self:Reset(sample)
		return self:GetState()
	end

	if anchor.mapId ~= sample.mapId or
		(HasWorldPosition(anchor) and HasWorldPosition(sample) and anchor.worldZoneId ~= sample.worldZoneId) then
		self:Reset(sample)
		return self:GetState()
	end

	local elapsedMs = sample.timeMs - anchor.timeMs
	if elapsedMs < SCB.Constants.MOTION_SAMPLE_MS then return self:GetState() end
	if elapsedMs <= 0 or elapsedMs > 1000 then
		self:Reset(sample)
		return self:GetState()
	end

	local mapDx = sample.x - anchor.x
	local mapDy = sample.y - anchor.y
	local mapDistance = math.sqrt(mapDx * mapDx + mapDy * mapDy)
	if mapDistance > SCB.Constants.MAX_MAP_JUMP then
		self:Reset(sample)
		return self:GetState()
	end

	local worldDistanceUnits
	if HasWorldPosition(anchor) and HasWorldPosition(sample) and anchor.worldZoneId == sample.worldZoneId then
		worldDistanceUnits = Distance2D(anchor.worldX, anchor.worldZ, sample.worldX, sample.worldZ)
		if worldDistanceUnits > SCB.Constants.MAX_WORLD_JUMP_UNITS then
			self:Reset(sample)
			return self:GetState()
		end
	end

	local elapsedSeconds = elapsedMs / 1000
	if worldDistanceUnits then
		local distanceMeters = worldDistanceUnits / SCB.Constants.WORLD_UNITS_PER_METER
		local rawSpeed = distanceMeters / elapsedSeconds
		self.SpeedValid = true
		if distanceMeters < SCB.Constants.STATIONARY_METERS then
			self.Speed = 0
		else
			local alpha = 0.55
			self.Speed = self.Speed and (self.Speed + (rawSpeed - self.Speed) * alpha) or rawSpeed
		end
	else
		self.Speed = 0
		self.SpeedValid = false
	end

	local movingEnough = mapDistance >= SCB.Constants.MIN_MAP_DISPLACEMENT
	if worldDistanceUnits then
		movingEnough = movingEnough and
			(worldDistanceUnits / SCB.Constants.WORLD_UNITS_PER_METER >= SCB.Constants.STATIONARY_METERS)
	end

	if movingEnough then
		local rawAngle = SCB.NormalizeAngle(math.atan2(mapDx, -mapDy))
		local vectorX = math.cos(rawAngle)
		local vectorY = math.sin(rawAngle)
		if self.DirectionVectorX then
			local alpha = 0.65
			self.DirectionVectorX = self.DirectionVectorX + (vectorX - self.DirectionVectorX) * alpha
			self.DirectionVectorY = self.DirectionVectorY + (vectorY - self.DirectionVectorY) * alpha
		else
			self.DirectionVectorX = vectorX
			self.DirectionVectorY = vectorY
		end
		self.Direction = SCB.NormalizeAngle(math.atan2(self.DirectionVectorY, self.DirectionVectorX))
		self.DirectionValid = true
	else
		self.DirectionValid = false
	end

	self.Anchor = sample
	return self:GetState()
end
