-- Optional HarvestMap / HarvestMap-Data adapter for Resource Navigator.
-- HarvestMap owns/deserializes the community database; this file only copies
-- the currently relevant resource nodes into SatuveXboxUI's route data layer.

BUI.ResourceHarvestMap = BUI.ResourceHarvestMap or {}
local Adapter = BUI.ResourceHarvestMap
local Data = BUI.ResourceData

Adapter.Available = false
Adapter.LastNodeCount = 0
Adapter.CallbacksRegistered = false

local function CategoryForPinType(pinTypeId)
	if not Harvest then return nil end
	if pinTypeId == Harvest.BLACKSMITH or pinTypeId == Harvest.JEWELRY then return "ORE" end
	if pinTypeId == Harvest.CLOTHING then return "CLOTHING" end
	if pinTypeId == Harvest.WOODWORKING then return "WOOD" end
	if pinTypeId == Harvest.ENCHANTING or pinTypeId == Harvest.PSIJIC then return "RUNES" end
	if pinTypeId == Harvest.MUSHROOM or pinTypeId == Harvest.FLOWER or pinTypeId == Harvest.WATERPLANT or pinTypeId == Harvest.CRIMSON then return "ALCHEMY" end
	return nil
end

local function Debug(message)
	if not BUI.Vars or not BUI.Vars.ResourceDebug then return end
	local text = "[SatuveXboxUI ResourceNav] " .. tostring(message)
	if bui_pl then bui_pl(text) elseif d then d(text) end
end

function Adapter:IsAvailable()
	return type(Harvest) == "table" and type(Harvest.Data) == "table" and
		type(Harvest.mapTools) == "table" and type(Harvest.Data.GetMapCache) == "function"
end

function Adapter:GetNodes(mapId)
	if not BUI.Vars or BUI.Vars.ResourceUseHarvestMap == false or not self:IsAvailable() then
		self.Available, self.LastNodeCount = false, 0
		return {}
	end
	local result = {}
	local caches = {}
	local zoneCache = Harvest.Data.GetCurrentZoneCache and Harvest.Data:GetCurrentZoneCache() or Harvest.Data.currentZoneCache
	if zoneCache and type(zoneCache.mapCaches) == "table" then
		for _, cache in pairs(zoneCache.mapCaches) do
			caches[#caches + 1] = cache
		end
	end

	-- Older HarvestMap builds may not expose a zone cache. Fall back to their
	-- viewed-map cache, but do not reject it merely because mapId metadata is nil
	-- or stale (that was the reason visible HarvestMap pins yielded no target).
	if #caches == 0 and Harvest.mapTools.GetViewedMapMetaData then
		local mapMetaData = Harvest.mapTools:GetViewedMapMetaData()
		local cache = mapMetaData and Harvest.Data:GetMapCache(mapMetaData)
		if cache then caches[1] = cache end
	end
	local seen = {}
	for _, mapCache in ipairs(caches) do
		if type(mapCache.nodesOfPinType) == "table" then
			for pinTypeId, nodeIds in pairs(mapCache.nodesOfPinType) do
				local category = CategoryForPinType(pinTypeId)
				if category and type(nodeIds) == "table" then
					for _, nodeId in pairs(nodeIds) do
						local ok, x, y = pcall(mapCache.GetLocal, mapCache, nodeId)
						local worldX = mapCache.worldX and mapCache.worldX[nodeId]
						local worldHorizontalY = mapCache.worldY and mapCache.worldY[nodeId]
						local worldHeight = mapCache.worldZ and mapCache.worldZ[nodeId]
						local nodeKey = tostring(mapCache.map or mapId) .. ":" .. tostring(pinTypeId) .. ":" .. tostring(nodeId)
						if ok and x and y and worldX and worldHorizontalY and not seen[nodeKey] then
							seen[nodeKey] = true
							result[#result + 1] = {
								id = "harvest:" .. nodeKey,
								mapId = tonumber(mapId), x = x, y = y, type = category,
								-- HarvestMap stores world coordinates in meters. ESO's
								-- GetUnitWorldPosition uses centimetres and swaps vertical/Y.
								worldZoneId = mapCache.mapMetaData and mapCache.mapMetaData.zoneId,
								worldX = worldX * 100,
								worldY = worldHeight and worldHeight * 100 or nil,
								worldZ = worldHorizontalY * 100,
								source = "HarvestMap Community",
							}
						end
					end
				end
			end
		end
	end
	self.Available, self.LastNodeCount = true, #result
	Debug("HarvestMap community nodes loaded for this map: " .. tostring(#result))
	return result
end

function Adapter:NotifyChanged(reason)
	if Data and Data.NotifyProviderChanged then Data.NotifyProviderChanged() end
	if BUI.ResourceNavigator then
		BUI.ResourceNavigator.GridByMap = {}
		if BUI.Vars and BUI.Vars.ResourceNavigatorEnabled then
			BUI.CallLater("SatuveResourceNavigator_HarvestMap", 350, function()
				BUI.ResourceNavigator:OnZoneChanged(reason or "HarvestMap data changed")
			end)
		end
	end
end

function Adapter:RegisterCallbacks()
	if self.CallbacksRegistered or not self:IsAvailable() then return end
	local manager, events = Harvest.callbackManager, Harvest.events
	if not manager or not events or not manager.RegisterForEvent then return end
	self.CallbacksRegistered = true
	local function Changed() Adapter:NotifyChanged("HarvestMap cache changed") end
	for _, eventName in ipairs({"NODE_ADDED", "NODE_UPDATED", "NODE_DELETED", "NEW_ZONE_ENTERED", "MAP_ADDED_TO_ZONE", "MAP_REMOVED_FROM_ZONE"}) do
		local eventId = events[eventName]
		if eventId then manager:RegisterForEvent(eventId, Changed) end
	end
end

function Adapter:Initialize()
	if not Data or not Data.RegisterProvider then return end
	Data.RegisterProvider("HarvestMap Community", function(mapId) return Adapter:GetNodes(mapId) end)
	self:RegisterCallbacks()
	self.Available = self:IsAvailable()
end

Adapter:Initialize()
