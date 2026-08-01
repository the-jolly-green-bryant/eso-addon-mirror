
local PinController = LoreLibrary.pinController

local MapPins = {}
LoreLibrary:RegisterModule("mapPins", MapPins)

--[[
Draws a pin for every book in the zone of the currently viewed map
(LoreLibraryData is keyed by zoneId, not by individual map/sub-map).

Keyboard-only (see MapPinController.lua): IsConsoleUI() is true on console,
where Initialize bails out immediately.
]]--

function MapPins:Initialize()

	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		PinController:RegisterPinType(pinTypeId, LoreLibrary.mapPinLayout[pinTypeId])
	end

	-- player switched map (left/right click, zoom, initial map open)
	ZO_PreHook("ZO_WorldMap_UpdateMap", function() self:RedrawPins() end)

	LoreLibrary.data:RegisterCallback("BookRemoved", function(zoneId, nodeId, pinTypeId) self:RemovePin(zoneId, nodeId, pinTypeId) end)
	LoreLibrary.settings:RegisterCallback("FilterChanged", function() self:RedrawPins() end)
end

-- drops the pin for a node that was removed from its ZoneCache (e.g. the book was just discovered)
function MapPins:RemovePin(zoneId, nodeId, pinTypeId)
	if not self.zoneCache or self.zoneCache.zoneId ~= zoneId then return end
	PinController:RemovePinForNodeId(pinTypeId, nodeId)
end

function MapPins:RedrawPins()
	self:Debug("Refresh of pins requested.")
	PinController:RemoveAllPins()

	local zoneId = LoreLibrary.GetViewedZoneId()

	if self.zoneCache then
		self.zoneCache:UnregisterAccess(self)
	end
	self.zoneCache = LoreLibrary.data:GetZoneCache(zoneId)
	self.zoneCache:RegisterAccess(self)

	PinController:RemoveAllPins() -- called again because creation of the cache could have created unknown pins
	PinController:SetZoneCache(self.zoneCache)
	self:DrawNodes()
end

function MapPins:DrawNodes()
	local zoneCache = self.zoneCache
	local previousPinTypeId
	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		if LoreLibrary.settings:IsPinTypeEnabled(pinTypeId) then
			local firstNodeId, lastNodeId = zoneCache:GetNodeIdRange(pinTypeId, previousPinTypeId)
			for nodeId = firstNodeId, lastNodeId do
				if zoneCache.bookId[nodeId] then
					PinController:CreatePinForNodeId(pinTypeId, nodeId)
				end
			end
		end
		previousPinTypeId = pinTypeId
	end
end
