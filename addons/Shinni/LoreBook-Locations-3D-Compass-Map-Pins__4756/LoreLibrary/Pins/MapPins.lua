
local PinController = LoreLibrary.pinController

local MapPins = {}
LoreLibrary:RegisterModule("mapPins", MapPins)

--[[
Draws a pin for every book in the zone of the currently viewed map
(LoreLibraryData is keyed by zoneId, not by individual map/sub-map).

GetCurrentMapZoneIndex() (the API behind GetViewedZoneId) is occasionally
wrong for a given map - when that happens, the viewed zone's cache is missing
or empty even though the player is actually standing right there, so pins
still show up correctly on the compass and in the 3D world (which key off
GetPlayerZoneId instead) but not on the map. Since the player's zone is never
wrong, we display both the viewed zone's cache and the player's zone's cache
on the map - when they agree (the common case) the player slot is simply left
empty instead of drawing the same pins twice.

Each pin type gets two PinTypeManagers/composites in PinController (see
Pins/MapPinController.lua): one bound to the viewed zone's cache, one bound to
the player's zone's cache, identified by the SLOT_VIEWED/SLOT_PLAYER keys below.
]]--

local SLOT_VIEWED = "viewed"
local SLOT_PLAYER = "player"

-- on these two top-level overview maps, "the player's zone" isn't a
-- meaningful place to draw zone-local book positions (there's no sensible
-- projection from zone-relative coordinates onto a whole-continent or
-- whole-world map), so both slots stay empty here rather than falling back
-- to the player's zone the way GetPlayerZoneId normally would elsewhere.
-- The tracked-book marker pin (Pins/MarkerPin.lua) is unaffected - it uses
-- the game's own custom pin API, not these ZoneCache-driven pin types.
local MAP_TYPES_WITHOUT_BOOK_PINS = {
	[MAPTYPE_COSMIC] = true,
	[MAPTYPE_WORLD] = true,
}

function MapPins:Initialize()

	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		-- MARKER (the tracked-book pin) is drawn via the game's own custom
		-- pin API instead - see Pins/MarkerPin.lua
		if pinTypeId ~= LoreLibrary.MARKER then
			PinController:RegisterPinType(pinTypeId, SLOT_VIEWED, LoreLibrary.mapPinLayout[pinTypeId])
			PinController:RegisterPinType(pinTypeId, SLOT_PLAYER, LoreLibrary.mapPinLayout[pinTypeId])
		end
	end

	-- player switched map (left/right click, zoom, initial map open)
	ZO_PreHook("ZO_WorldMap_UpdateMap", function() self:RedrawPins() end)

	LoreLibrary.data:RegisterCallback("BookRemoved", function(zoneId, nodeId, pinTypeId) self:RemovePin(zoneId, nodeId, pinTypeId) end)
	LoreLibrary.settings:RegisterCallback("FilterChanged", function() self:RedrawPins() end)
end

-- drops the pin for a node that was removed from its ZoneCache (e.g. the book was just discovered)
function MapPins:RemovePin(zoneId, nodeId, pinTypeId)
	if self.viewedZoneId == zoneId then
		PinController:RemovePinForNodeId(pinTypeId, SLOT_VIEWED, nodeId)
	end
	if self.playerZoneCache and self.playerZoneId == zoneId then
		PinController:RemovePinForNodeId(pinTypeId, SLOT_PLAYER, nodeId)
	end
end

function MapPins:RedrawPins()
	self:Debug("Refresh of pins requested.")
	PinController:RemoveAllPins()

	if MAP_TYPES_WITHOUT_BOOK_PINS[GetMapType()] then
		self:SetZoneCaches(nil, nil)
	else
		self:SetZoneCaches(LoreLibrary.GetViewedZoneId(), LoreLibrary.GetPlayerZoneId())
	end

	PinController:RemoveAllPins() -- called again because creation of the caches could have created unknown pins
	self:DrawNodes()
end

-- binds the viewed zone's cache and the player's zone's cache (only if it's a
-- different zone) to their respective PinController cache slots, and updates
-- our own access registration to match. Either or both may be nil (see
-- MAP_TYPES_WITHOUT_BOOK_PINS above), in which case that slot is left empty.
function MapPins:SetZoneCaches(viewedZoneId, playerZoneId)
	local viewedZoneCache = viewedZoneId and LoreLibrary.data:GetZoneCache(viewedZoneId) or nil
	local playerZoneCache = (playerZoneId ~= viewedZoneId) and LoreLibrary.data:GetZoneCache(playerZoneId) or nil

	if self.viewedZoneCache then
		self.viewedZoneCache:UnregisterAccess(self)
	end
	if self.playerZoneCache then
		self.playerZoneCache:UnregisterAccess(self)
	end

	self.viewedZoneId = viewedZoneId
	self.playerZoneId = playerZoneId
	self.viewedZoneCache = viewedZoneCache
	self.playerZoneCache = playerZoneCache

	if viewedZoneCache then
		viewedZoneCache:RegisterAccess(self)
	end
	if playerZoneCache then
		playerZoneCache:RegisterAccess(self)
	end

	PinController:SetZoneCache(SLOT_VIEWED, viewedZoneCache)
	PinController:SetZoneCache(SLOT_PLAYER, playerZoneCache)
end

function MapPins:DrawNodes()
	if self.viewedZoneCache then
		self:DrawNodesForSlot(SLOT_VIEWED, self.viewedZoneCache)
	end
	if self.playerZoneCache then
		self:DrawNodesForSlot(SLOT_PLAYER, self.playerZoneCache)
	end
end

function MapPins:DrawNodesForSlot(cacheSlot, zoneCache)
	local previousPinTypeId
	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		if LoreLibrary.settings:IsPinTypeEnabled(pinTypeId) then
			local firstNodeId, lastNodeId = zoneCache:GetNodeIdRange(pinTypeId, previousPinTypeId)
			for nodeId = firstNodeId, lastNodeId do
				if zoneCache.bookId[nodeId] then
					PinController:CreatePinForNodeId(pinTypeId, cacheSlot, nodeId)
				end
			end
		end
		previousPinTypeId = pinTypeId
	end
end
