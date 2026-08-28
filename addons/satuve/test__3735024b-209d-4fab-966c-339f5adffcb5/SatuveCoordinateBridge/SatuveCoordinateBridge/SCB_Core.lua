local SCB = SatuveCoordinateBridge

SCB.Core = SCB.Core or {}
local Core = SCB.Core

local LOAD_EVENT = "SatuveCoordinateBridge_Loaded"
local PLAYER_EVENT = "SatuveCoordinateBridge_Player"
local UPDATE_EVENT = "SatuveCoordinateBridge_Update"

function Core:ReadPosition()
	local sample = {coordinatesValid = false, timeMs = SCB.NowMilliseconds()}
	if not GetCurrentMapId or not GetMapPlayerPosition then return sample end

	local mapId = tonumber(GetCurrentMapId())
	local x, y, _, shown = GetMapPlayerPosition("player")
	x, y = tonumber(x), tonumber(y)
	if mapId and mapId > 0 and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 and shown ~= false then
		sample.coordinatesValid = true
		sample.mapId = mapId
		sample.x = x
		sample.y = y
	end

	if GetUnitWorldPosition then
		local zoneId, worldX, worldY, worldZ = GetUnitWorldPosition("player")
		sample.worldZoneId = tonumber(zoneId)
		sample.worldX = tonumber(worldX)
		sample.worldY = tonumber(worldY)
		sample.worldZ = tonumber(worldZ)
	end
	return sample
end

function Core:PublishFrame()
	if not SCB.SV or not SCB.SV.enabled then return end
	self.Sequence = ((self.Sequence or 0) + 1) % 65536
	local position = self:ReadPosition()
	local motion = SCB.Motion:Update(position)
	local frame = SCB.Encoder:BuildFrame(position, motion, self.Sequence)
	SCB.Display:Publish(frame)
	self.LastFrame = frame
end

function Core:ResetMotion()
	SCB.Motion:Reset(nil)
end

function Core:ApplySettings()
	if not SCB.SV then return end
	SCB.SV.cellSize = SCB.Clamp(SCB.SV.cellSize, 3, 12)
	local updateMs = tonumber(SCB.SV.updateMs)
	if updateMs ~= 25 and updateMs ~= 50 and updateMs ~= 100 then updateMs = 50 end
	SCB.SV.updateMs = updateMs
	SCB.Display:ApplySettings()
	EVENT_MANAGER:UnregisterForUpdate(UPDATE_EVENT)
	if SCB.SV.enabled then
		EVENT_MANAGER:RegisterForUpdate(UPDATE_EVENT, updateMs, function() Core:PublishFrame() end)
		self:PublishFrame()
	end
	if SCB.Menu then SCB.Menu:Refresh() end
end

function Core:RegisterEvents()
	EVENT_MANAGER:RegisterForEvent(PLAYER_EVENT, EVENT_PLAYER_ACTIVATED, function()
		Core:ResetMotion()
		if SCB.SV and SCB.SV.enabled then Core:PublishFrame() end
	end)
	EVENT_MANAGER:RegisterForEvent(PLAYER_EVENT, EVENT_PLAYER_DEACTIVATED, function()
		Core:ResetMotion()
	end)
	if EVENT_ZONE_CHANGED then
		EVENT_MANAGER:RegisterForEvent(PLAYER_EVENT, EVENT_ZONE_CHANGED, function()
			Core:ResetMotion()
		end)
	end
end

function Core:Initialize()
	if self.Initialized then return end
	self.Initialized = true
	self.Sequence = 0
	SCB.SV = ZO_SavedVars:NewAccountWide(SCB.savedVariableName, 2, nil, SCB.Defaults)
	-- Migrate only the original 2.0.0 default layout. Custom positions and
	-- custom cell sizes remain untouched.
	if tonumber(SCB.SV.cellSize) == 6 and tonumber(SCB.SV.offsetX) == 20 and tonumber(SCB.SV.offsetY) == 20 then
		SCB.SV.cellSize = 3
		SCB.SV.offsetX = 5
		SCB.SV.offsetY = 5
	end
	SCB.Display:Initialize()
	SCB.Menu:Initialize()
	self:RegisterEvents()
	local selfTestOk, selfTestCrc = SCB.Encoder:SelfTest()
	self.SelfTestCRC = selfTestCrc
	if not selfTestOk then SCB.Print("ENCODER SELF-TEST FAILED") end
	self:ResetMotion()
	self:ApplySettings()
end

EVENT_MANAGER:RegisterForEvent(LOAD_EVENT, EVENT_ADD_ON_LOADED, function(_, addOnName)
	if addOnName ~= SCB.name then return end
	EVENT_MANAGER:UnregisterForEvent(LOAD_EVENT, EVENT_ADD_ON_LOADED)
	Core:Initialize()
end)
