
local ProximityPinSet = ZO_Object:Subclass()
LoreLibrary.ProximityPinSet = ProximityPinSet

--[[
Shared lifecycle for WorldPins and CompassPins: both continuously show a
visual for every undiscovered book within some distance of the player,
acquiring/releasing it as the player moves and as filters/settings change.
This class owns starting/stopping the periodic ticks, the acquired-node
bookkeeping, the zone-cache refresh, and the PINTYPES x nodeId distance scan
that decides what should be acquired/released. Subclasses call InitializeBase
from their own Initialize() and supply:
- AcquireNode(pinTypeId, nodeId): create/show the visual for a node that just
  came into range
- ReleaseNode(nodeId, pinTypeId): hide/return it once out of range, removed,
  or its pin type got disabled
- Tick(): the fast per-frame update (repositioning etc) for self.acquired
- optionally ReleaseAllPins(): a bulk-release override, since the default
  here (call ReleaseNode for every acquired node) is correct but not as cheap
  as e.g. releasing an entire pool/composite at once
]]--

-- config = {
--   enabledSettingKey, distanceSettingKey: e.g. "worldPinsEnabled"/"worldPinsDistance"
--   spawnUpdateName, tickUpdateName: unique EVENT_MANAGER update handler names
--   spawnIntervalMs, tickIntervalMs
-- }
function ProximityPinSet:InitializeBase(config)
	self.config = config
	self.acquired = {} -- nodeId -> pinTypeId, for nodes currently shown
	self.range = LoreLibrary.settings:Get(config.distanceSettingKey)

	LoreLibrary.data:RegisterCallback("BookRemoved", function(zoneId, nodeId, pinTypeId) 
		self:RemovePin(zoneId, nodeId, pinTypeId) 
	end)
	LoreLibrary.settings:RegisterCallback("FilterChanged", function()
		if self.running then
			self:RefreshPins()
		end
	end)
	LoreLibrary.settings:RegisterCallback("SettingChanged", function(key, value)
		if key == config.enabledSettingKey then
			self:UpdateEnabled()
		elseif key == config.distanceSettingKey then
			self.range = value
			self:RefreshPins()
		end
	end)
end

-- starts/stops the periodic ticks and releases everything based on whether
-- this pin set is currently enabled in settings, so a disabled one costs
-- nothing (no periodic scan, no per-frame tick)
function ProximityPinSet:UpdateEnabled()
	local config = self.config
	if LoreLibrary.settings:Get(config.enabledSettingKey) then
		if not self.running then
			self.running = true
			EVENT_MANAGER:RegisterForUpdate(config.spawnUpdateName, config.spawnIntervalMs, function() self:RefreshPins() end)
			EVENT_MANAGER:RegisterForUpdate(config.tickUpdateName, config.tickIntervalMs, function() self:Tick() end)
			self:RefreshPins()
		end
	else
		if self.running then
			self.running = false
			EVENT_MANAGER:UnregisterForUpdate(config.spawnUpdateName)
			EVENT_MANAGER:UnregisterForUpdate(config.tickUpdateName)
			self:ReleaseAllPins()
		end
	end
end

-- drops the node that was removed from its ZoneCache (e.g. the book was just discovered)
function ProximityPinSet:RemovePin(zoneId, nodeId, pinTypeId)
	if not self.zoneCache or self.zoneCache.zoneId ~= zoneId then return end
	if self.acquired[nodeId] then
		self:ReleaseNode(nodeId, pinTypeId)
		self.acquired[nodeId] = nil
	end
end

function ProximityPinSet:RefreshZoneCache()
	self:ReleaseAllPins()

	if self.zoneCache then
		self.zoneCache:UnregisterAccess(self)
	end
	local zoneId = LoreLibrary.GetPlayerZoneId()
	self.zoneCache = LoreLibrary.data:GetZoneCache(zoneId)
	self.zoneCache:RegisterAccess(self)

	if self.running then
		self:RefreshPins()
	end
end

-- default bulk release; subclasses may override with something cheaper than
-- releasing node by node (e.g. releasing an entire pool/composite at once)
function ProximityPinSet:ReleaseAllPins()
	for nodeId, pinTypeId in pairs(self.acquired) do
		self:ReleaseNode(nodeId, pinTypeId)
	end
	ZO_ClearTable(self.acquired)
end

-- acquires/releases nodes for the current ZoneCache based on distance to the player
function ProximityPinSet:RefreshPins()
	if not self.zoneCache then return end

	local playerX, playerY = LoreLibrary.GetPlayer3DPosition()
	local range2 = self.range * self.range
	local zoneCache = self.zoneCache

	local previousPinTypeId
	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		local enabled = LoreLibrary.settings:IsPinTypeEnabled(pinTypeId)
		local firstNodeId, lastNodeId = zoneCache:GetNodeIdRange(pinTypeId, previousPinTypeId)
		previousPinTypeId = pinTypeId
		for nodeId = firstNodeId, lastNodeId do
			if zoneCache.bookId[nodeId] then
				local acquired = self.acquired[nodeId]
				local withinRange = false
				if enabled then
					local dx = playerX - zoneCache.worldX[nodeId]
					local dy = playerY - zoneCache.worldY[nodeId]
					withinRange = (dx * dx + dy * dy) < range2
				end

				if withinRange and not acquired then
					self:AcquireNode(pinTypeId, nodeId)
					self.acquired[nodeId] = pinTypeId
				elseif not withinRange and acquired then
					self:ReleaseNode(nodeId, acquired)
					self.acquired[nodeId] = nil
				end
			end
		end
	end
end
