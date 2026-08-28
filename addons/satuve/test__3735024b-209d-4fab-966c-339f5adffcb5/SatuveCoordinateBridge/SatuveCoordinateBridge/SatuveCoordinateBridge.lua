SatuveCoordinateBridge = SatuveCoordinateBridge or {}

local SCB = SatuveCoordinateBridge

SCB.name = "SatuveCoordinateBridge"
SCB.displayName = "Satuve Coordinate Bridge"
SCB.version = "2.0.1"
SCB.protocolVersion = 2
SCB.savedVariableName = "SatuveCoordinateBridgeSavedVariables"

SCB.Defaults = {
	enabled = true,
	offsetX = 5,
	offsetY = 5,
	cellSize = 3,
	updateMs = 50,
	showDebugText = false,
}

SCB.Constants = {
	SYNC = 0xA55A,
	GRID_COLUMNS = 20,
	GRID_ROWS = 8,
	BIT_COUNT = 160,
	POSITION_SCALE = 1000000,
	WORLD_UNITS_PER_METER = 100,
	MOTION_SAMPLE_MS = 100,
	STATIONARY_METERS = 0.03,
	MIN_MAP_DISPLACEMENT = 0.0000005,
	MAX_WORLD_JUMP_UNITS = 5000,
	MAX_MAP_JUMP = 0.08,
}

function SCB.Clamp(value, minimum, maximum)
	value = tonumber(value) or minimum
	if value < minimum then return minimum end
	if value > maximum then return maximum end
	return value
end

function SCB.Round(value)
	return math.floor((tonumber(value) or 0) + 0.5)
end

function SCB.NowMilliseconds()
	if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
	if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
	return (GetTimeStamp and GetTimeStamp() or 0) * 1000
end

function SCB.NormalizeAngle(angle)
	local twoPi = math.pi * 2
	angle = tonumber(angle) or 0
	while angle < 0 do angle = angle + twoPi end
	while angle >= twoPi do angle = angle - twoPi end
	return angle
end

function SCB.Print(message)
	if d then d("[SatuveCoordinateBridge] " .. tostring(message)) end
end
