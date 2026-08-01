
local PinController = Harvest.pinController
local CallbackManager = Harvest.callbackManager
local Events = Harvest.events

local MapPins = {}
Harvest:RegisterModule("mapPins", MapPins)

--[[
There are many modules that interact with pins: settings, filters, moving around, etc
This files keeps track of all the relevant settings/modes etc,
and then forwards that information to the MapPinController, which handles the actual
pin texture controls.
]]--

function MapPins:Initialize()
	-- filter profile used by map pins
	self.filterProfile = Harvest.filterProfiles:GetMapProfile()
	
	-- register callbacks for events, that affect map pins:
	-- creating/updating a node (after harvesting something) or deletion of a node (via debug tools)
	local callback = function(...) self:OnNodeChangedCallback(...) end
	CallbackManager:RegisterForEvent(Events.NODE_DELETED, callback)
	CallbackManager:RegisterForEvent(Events.NODE_UPDATED, callback)
	CallbackManager:RegisterForEvent(Events.NODE_ADDED, callback)
	CallbackManager:RegisterForEvent(Events.NODE_COMPASS_LINK_CHANGED, callback)
	-- when a map related setting is changed
	CallbackManager:RegisterForEvent(Events.SETTING_CHANGED, function(...) self:OnSettingsChanged(...) end)
	CallbackManager:RegisterForEvent(Events.FILTER_PROFILE_CHANGED, function(event, profile, pinTypeId, visible)
		if profile == self.filterProfile then
			self:RedrawPins()
		end
	end)
	
	-- switch between main and minimap
	CallbackManager:RegisterForEvent(Events.MAP_MODE_CHANGED, function(event, newMode)
		self:RedrawPins() -- some settings differ between main and minimap
		-- eg display of pins, and respawn filter
	end)
	
	-- player switched map (left/right click)
	ZO_PreHook("ZO_WorldMap_UpdateMap", function() self:RedrawPins() end)
	
	self.resourcePinTypeIds = {}
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		-- only register the resource pins, not hidden resources like psijic portals
		if not Harvest.HIDDEN_PINTYPES[pinTypeId] then
			local layout = Harvest.GetMapPinLayout(pinTypeId)
			-- create the pin type for this resource
			PinController:RegisterPinType(pinTypeId, layout)
			table.insert(self.resourcePinTypeIds, pinTypeId)
		end
	end
	
end

-- called whenever a resource is harvested (which adds a node or updates an already existing node)
-- or when a node is deleted by the debug tool
function MapPins:OnNodeChangedCallback(event, mapCache, nodeId)
	local nodeAdded = (event == Events.NODE_ADDED)
	local nodeUpdated = (event == Events.NODE_UPDATED or event == Events.NODE_COMPASS_LINK_CHANGED)
	local nodeDeleted = (event == Events.NODE_DELETED)
	
	local validMapMode = Harvest.AreMapPinsVisible() and not Harvest.mapMode:IsInMinimapMode()
	local validMinimapMode = Harvest.AreMinimapPinsVisible() and Harvest.mapMode:IsInMinimapMode()
	if not (validMapMode or validMinimapMode) then return end
	
	-- the node isn't on the currently displayed map
	if not (self.mapCache == mapCache) then
		return
	end
	
	if mapCache.mapMetaData.isBlacklisted then return end
	
	local pinTypeId = mapCache:RetrievePinTypeId(nodeId)
	assert(pinTypeId)
	-- if the node's pin type is visible, then we do not have to manipulate any pins
	if not self.filterProfile[pinTypeId] then
		return
	end
	
	-- queue the pin change
	-- refresh a single pin by removing and recreating it
	if not nodeAdded then
		--self:Info("remove single map pin")
		self:RemoveNode(nodeId, pinTypeId)
	end
	-- the (re-)creation of the pin is performed
	if not nodeDeleted then
		--self:Info("add single map pin")
		self:AddNode(nodeId, pinTypeId)
	end
end

function MapPins:RedrawPins(shouldRefreshLayout)
	self:Debug("Refresh of pins requested.")
	PinController:RemoveAllPins()
	if shouldRefreshLayout then
		PinController:RefreshLayout()
	end
	
	local validMapMode = Harvest.AreMapPinsVisible() and not Harvest.mapMode:IsInMinimapMode()
	local validMinimapMode = Harvest.AreMinimapPinsVisible() and Harvest.mapMode:IsInMinimapMode()
	if not (validMapMode or validMinimapMode) then return end
	
	local mapMetaData = Harvest.mapTools:GetViewedMapMetaData()
	local newMap = self.currentMap ~= mapMetaData.map
	-- save current map
	self.currentMap = mapMetaData.map
	-- remove old cache and load the new one
	if self.mapCache then
		self.mapCache:UnregisterAccess(self)
	end
	self.mapCache = Harvest.Data:GetMapCache(mapMetaData)
	-- if no data is available for this map, abort.
	if not self.mapCache then
		return
	end
	self.mapCache:RegisterAccess(self)
	
	-- load data if it hasn't been loaded yet
	for _, pinTypeId in ipairs(Harvest.PINTYPES) do
		if self.filterProfile[pinTypeId] then
			Harvest.Data:CheckPinTypeInCache(pinTypeId, self.mapCache)
		end
	end
	
	PinController:RemoveAllPins() -- called again because creation of new cache could have created new unknown pins
	PinController:SetMapCache(self.mapCache)
	self:DrawNodes()
	
	if newMap then
		CallbackManager:FireCallbacks(Events.MAP_CHANGE)
	end
end

function MapPins:IsActiveMap(map)
	if not self.mapCache then return false end
	return (self.mapCache.map == map)
end

function MapPins:DrawNodes()
	local PinController = PinController
	
	-- get spawn filter settings
	local showOnlySpawnedNodes = Harvest.IsMapSpawnFilterEnabled()
	if Harvest.mapMode:IsInMinimapMode() then
		showOnlySpawnedNodes = Harvest.IsMinimapSpawnFilterEnabled()
	end
	
	local mapCache = self.mapCache
	local firstOfPinType, lastOfPinType
	for _, pinTypeId in pairs(mapCache.orderedPinTypes) do
		if self.filterProfile[pinTypeId] then
			firstOfPinType = mapCache.nodesOfPinTypeStart[pinTypeId]
			lastOfPinType = mapCache.nodesOfPinTypeEnd[pinTypeId]
			if showOnlySpawnedNodes and Harvest.HARVEST_NODES[pinTypeId] then
				-- if spawn filter is used for this pin type, check if resource is spawned
				for nodeId = firstOfPinType, lastOfPinType do
					if mapCache.hasCompassPin[nodeId] then
						PinController:CreatePinForNodeId(pinTypeId, nodeId)
					end
				end
			else
				-- if spawn filter is no used, we can draw all pins directly
				for nodeId = firstOfPinType, lastOfPinType do
					PinController:CreatePinForNodeId(pinTypeId, nodeId)
				end
			end
		end
	end
	
end

function MapPins:AddNode(nodeId, pinTypeId)
	-- get spawn filter settings
	local showOnlySpawnedNodes = Harvest.IsMapSpawnFilterEnabled()
	if Harvest.mapMode:IsInMinimapMode() then
		showOnlySpawnedNodes = Harvest.IsMinimapSpawnFilterEnabled()
	end
	
	-- if we should filter by spawn and resource is not spawned, then break
	if showOnlySpawnedNodes and Harvest.HARVEST_NODES[pinTypeId] and not self.mapCache.hasCompassPin[nodeId] then
		return
	end
	-- otherwise, add the new pin
	PinController:CreatePinForNodeId(pinTypeId, nodeId)
end

function MapPins:RemoveNode(nodeId, pinTypeId)
	PinController:RemovePinForNodeId(pinTypeId, nodeId)
end


-- these settings are handled by simply refreshing the map pins.
local redrawOnSetting = {
	--hasVisibleDistance = true,
	--visibleDistance = true,
	heatmapActive = true,
	mapPinsVisible = true,
	minimapPinsVisible = true,
	mapPinTypeVisible = true,
	mapSpawnFilter = true,
	minimapSpawnFilter = true,
}
local refreshOnSetting = {
	pinTypeSize = true,
	mapPinTexture = true,
	pinTypeColor = true,
}
function MapPins:OnSettingsChanged(event, setting, ...)
	if redrawOnSetting[setting] then
		self:RedrawPins()
	elseif refreshOnSetting[setting] then
		local shouldRefreshLayout = true
		self:RedrawPins(shouldRefreshLayout)
	elseif setting == "mapFilterProfile" then
		self.filterProfile = Harvest.filterProfiles:GetMapProfile()
		self:RedrawPins()
	elseif setting == "cacheCleared" then
		local map = ...
		if map == self.currentMap or not map then
			self:RedrawPins()
		end
	end
end
