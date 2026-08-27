-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local CompassPins = EASLoreLibrary.ProximityPinSet:Subclass()
EASLoreLibrary:RegisterModule("compassPins", CompassPins)

--[[
Compass pins for books near the player: acquires/releases a surface on its
pin type's CT_TEXTURECOMPOSITE for every undiscovered book within
compassPinsDistance (see ProximityPinSet for the shared acquire/release/
distance-scan lifecycle).

Drawn via one CT_TEXTURECOMPOSITE per pin type (same approach as the 2D map
pins in MapPinController.lua), since composites are far cheaper than many
individual texture controls. Since CT_TEXTURECOMPOSITE has no acquire/release
API of its own, each CompassPinManager keeps a small free-list of surface
indices to emulate one: acquiring reuses a released index (or adds a new
surface if none is free), releasing hides the surface and returns its index
to the free-list.
]]--

local PARENT = COMPASS.container
local pi = math.pi
local atan2 = math.atan2
local zo_abs = zo_abs

local FOV = pi * 0.6
local SPAWN_INTERVAL_MS = 3000

-----------------------------------------------------------
-- CompassPinManager: one CT_TEXTURECOMPOSITE per pin type
-----------------------------------------------------------

local CompassPinManager = ZO_Object:Subclass()

function CompassPinManager:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function CompassPinManager:Initialize(layout)
	local composite = PARENT:CreateControl(nil, CT_TEXTURECOMPOSITE)
	composite:SetAnchor(CENTER, PARENT, CENTER, 0, 0)
	composite:SetPixelRoundingEnabled(false)
	composite:SetTexture(layout.texture)
	composite:SetDimensions(layout.size, layout.size)
	-- MARKER's layout.level (see Main/PinTypes.lua) is set higher than
	-- LOREBOOK/EIDETICBOOK's, so the tracked-book compass pin draws above the
	-- ambient ones when they'd otherwise overlap (same reasoning as
	-- WorldPins:AcquireNode's SetDrawLevel call)
	composite:SetDrawLevel(layout.level)
	self.composite = composite

	if layout.tint then
		self.r, self.g, self.b = layout.tint:UnpackRGB()
	else
		self.r, self.g, self.b = 1, 1, 1
	end

	self.freeIndices = {}
	self.distanceLabels = {}
end

-- acquires a surface index from the free-list, or creates a new one
function CompassPinManager:AcquireNode()
	local index = table.remove(self.freeIndices)
	if not index then
		index = self.composite:AddSurface(0, 1, 0, 1)
	end
	self.composite:SetSurfaceHidden(index, false)
	local label = self.distanceLabels[index]
	if not label then
		label = WINDOW_MANAGER:CreateControl(nil, PARENT, CT_LABEL)
		label:SetFont("ZoFontGameSmall")
		label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		label:SetDimensions(72, 18)
		label:SetColor(self.r, self.g, self.b, 1)
		self.distanceLabels[index] = label
	end
	label:SetHidden(false)
	return index
end

-- hides the surface and returns its index to the free-list
function CompassPinManager:ReleaseNode(pinIndex)
	self.composite:SetSurfaceHidden(pinIndex, true)
	local label = self.distanceLabels[pinIndex]
	if label then label:SetHidden(true) end
	table.insert(self.freeIndices, pinIndex)
end

function CompassPinManager:ReleaseAllNodes()
	self.composite:ClearAllSurfaces()
	for _, label in pairs(self.distanceLabels) do
		label:SetHidden(true)
	end
	ZO_ClearTable(self.freeIndices)
end

function CompassPinManager:UpdateNode(pinIndex, offsetX, alpha, distanceMeters)
	self.composite:SetInsets(pinIndex, offsetX, offsetX, 0, 0)
	self.composite:SetColor(pinIndex, self.r, self.g, self.b, alpha)
	local label = self.distanceLabels[pinIndex]
	if label then
		if alpha <= 0 or not distanceMeters then
			label:SetHidden(true)
		else
			label:ClearAnchors()
			label:SetAnchor(CENTER, PARENT, CENTER, offsetX, 18)
			label:SetText(string.format("%dm", zo_round(distanceMeters)))
			label:SetAlpha(alpha)
			label:SetHidden(false)
		end
	end
end

-----------------------------------------------------------

function CompassPins:Initialize()
	self.pinManagers = {} -- cache key -> manager; ambient books are grouped by native texture
	self.markerManager = CompassPinManager:New(EASLoreLibrary.mapPinLayout[EASLoreLibrary.MARKER])
	self.pinRef = {} -- nodeId -> { manager, pinIndex }
	self.pinIndex = {} -- retained for compatibility/debugging
	self.markerPinIndex = {} -- index into self.markerLocations -> pinIndex
	self.markerLocations = {}
	self.markerEnabled = EASLoreLibrary.settings:IsPinTypeEnabled(EASLoreLibrary.MARKER)

	self:InitializeBase({
		enabledSettingKey = "compassPinsEnabled",
		distanceSettingKey = "compassPinsDistance",
		spawnUpdateName = "EASLoreLibrary-CompassPinsSpawn",
		tickUpdateName = "EASLoreLibrary-CompassPinsUpdate",
		spawnIntervalMs = SPAWN_INTERVAL_MS,
		tickIntervalMs = 30,
	})

	EVENT_MANAGER:RegisterForEvent("EASLoreLibrary-CompassPins", EVENT_PLAYER_ACTIVATED, function()
		self:RefreshZoneCache()
	end)

	EASLoreLibrary.markerPin:RegisterCallback("LocationsChanged", function(locations)
		self:ResetMarker()
		self.markerLocations = locations
	end)
	EASLoreLibrary.settings:RegisterCallback("FilterChanged", function(pinTypeId, enabled)
		if pinTypeId ~= EASLoreLibrary.MARKER then return end
		self.markerEnabled = enabled
		if not enabled then
			self:ResetMarker()
		end
	end)

	self:UpdateEnabled()
end

function CompassPins:GetAmbientManager(pinTypeId, nodeId)
	local layout = EASLoreLibrary.mapPinLayout[pinTypeId]
	local bookId = self.zoneCache and self.zoneCache.bookId[nodeId]
	local texture = EASLoreLibrary.GetBookIcon(bookId, layout.texture)
	local key = tostring(pinTypeId) .. "|" .. tostring(texture)
	local manager = self.pinManagers[key]
	if not manager then
		manager = CompassPinManager:New({ texture = texture, size = layout.size, level = layout.level })
		self.pinManagers[key] = manager
	end
	return manager
end

function CompassPins:AcquireNode(pinTypeId, nodeId)
	local manager = self:GetAmbientManager(pinTypeId, nodeId)
	local pinIndex = manager:AcquireNode()
	self.pinRef[nodeId] = { manager = manager, pinIndex = pinIndex }
	self.pinIndex[nodeId] = pinIndex
end

function CompassPins:ReleaseNode(nodeId, pinTypeId)
	local ref = self.pinRef[nodeId]
	if ref then ref.manager:ReleaseNode(ref.pinIndex) end
	self.pinRef[nodeId] = nil
	self.pinIndex[nodeId] = nil
end

function CompassPins:ReleaseAllPins()
	for _, manager in pairs(self.pinManagers) do manager:ReleaseAllNodes() end
	self.markerManager:ReleaseAllNodes()
	ZO_ClearTable(self.pinRef)
	ZO_ClearTable(self.pinIndex)
	ZO_ClearTable(self.acquired)
	ZO_ClearTable(self.markerPinIndex)
end

-- releases every currently shown tracked-book compass pin; called whenever
-- MarkerPin fires "LocationsChanged" or the MARKER filter gets disabled,
-- since a stale index left over from a previous, longer locations array
-- would otherwise never get released
function CompassPins:ResetMarker()
	local manager = self.markerManager
	for _, pinIndex in pairs(self.markerPinIndex) do
		manager:ReleaseNode(pinIndex)
	end
	ZO_ClearTable(self.markerPinIndex)
end

-- repositions only the surfaces that are currently acquired
function CompassPins:Tick()
	local playerX, playerY, playerZ = EASLoreLibrary.GetPlayer3DPosition()
	local heading = GetPlayerCameraHeading()
	if heading > pi then
		heading = heading - 2 * pi
	end

	local compassWidth = PARENT:GetWidth()

	if self.zoneCache then
		local compassRange2 = self.range * self.range
		local zoneCache = self.zoneCache
		for nodeId, pinTypeId in pairs(self.acquired) do
			local ref = self.pinRef[nodeId]
			local pinIndex = ref and ref.pinIndex
			local dx = playerX - zoneCache.worldX[nodeId]
			local dy = playerY - zoneCache.worldY[nodeId]
			local distance2 = dx * dx + dy * dy

			local angle = -atan2(dx, dy) + heading
			if angle > pi then
				angle = angle - 2 * pi
			elseif angle < -pi then
				angle = angle + 2 * pi
			end
			local normalizedAngle = 2 * angle / FOV
			local normalizedDistance = distance2 / compassRange2

			local manager = ref and ref.manager
			if manager and pinIndex then
				if normalizedDistance >= 1 or zo_abs(normalizedAngle) > 1 then
					manager:UpdateNode(pinIndex, 0, 0, nil)
				else
					local offsetX = 0.5 * compassWidth * normalizedAngle
					local alpha = 1 - normalizedDistance * normalizedDistance * normalizedDistance * normalizedDistance
					manager:UpdateNode(pinIndex, offsetX, alpha, math.sqrt(distance2))
				end
			end
		end
	end

	self:TickMarker(playerX, playerY, playerZ, heading, compassWidth)
end

-- shows/hides/positions a compass pin for each of the tracked book's
-- locations that are in the player's current zone or its parent zone (a
-- delve/sub-zone location displayed while standing in its parent open-world
-- zone - see Pins/MarkerPin.lua and Data:GetBookLocations' own use of
-- GetParentZoneId for the same "sub-zone shown on the parent map" idea).
-- Unlike the ambient book pins above, not gated by compassPinsEnabled/
-- compassPinsDistance - an explicitly tracked book always shows on the
-- compass (subject to the pin type's own filter toggle), faded only by
-- facing (behind-you clipping), not by distance.
function CompassPins:TickMarker(playerX, playerY, playerZ, heading, compassWidth)
	if not self.markerEnabled or #self.markerLocations == 0 then return end

	local manager = self.markerManager
	local playerZoneId = EASLoreLibrary.GetPlayerZoneId()
	-- used only by the "parent zone" branch below, but computed once here
	-- rather than per-location, since it's the same for all of them
	local playerNormX, playerNormY = GetNormalizedWorldPosition(playerZoneId, playerX * 100, playerZ * 100, playerY * 100)

	for locationIndex, location in ipairs(self.markerLocations) do
		local sameZone = location.zoneId == playerZoneId
		local relevant = sameZone or GetParentZoneId(location.zoneId) == playerZoneId
		local pinIndex = self.markerPinIndex[locationIndex]

		if relevant then
			if not pinIndex then
				pinIndex = manager:AcquireNode()
				self.markerPinIndex[locationIndex] = pinIndex
			end

			local dx, dy
			local distanceMeters
			if sameZone then
				-- player and location share a coordinate space - compare
				-- raw world positions directly
				dx = playerX - location.worldX
				dy = playerY - location.worldY
				distanceMeters = math.sqrt(dx * dx + dy * dy)
			else
				-- location.worldX/Y/Z are expressed in the delve's own
				-- coordinate space, which isn't comparable to the player's
				-- raw world position while standing in the parent zone (see
				-- MarkerPin.lua's GetLocalByNode for the same issue on the 2D
				-- map). Project both onto the currently viewed map's
				-- normalized space instead, where they ARE comparable, and
				-- use that delta for bearing (only the direction matters
				-- here, not the absolute normalized-space "distance").
				local locationNormX, locationNormY = GetNormalizedWorldPosition(location.zoneId, location.worldX * 100, location.worldZ * 100, location.worldY * 100)
				dx = playerNormX - locationNormX
				dy = playerNormY - locationNormY
			end

			local angle = -atan2(dx, dy) + heading
			if angle > pi then
				angle = angle - 2 * pi
			elseif angle < -pi then
				angle = angle + 2 * pi
			end
			local normalizedAngle = 2 * angle / FOV

			if zo_abs(normalizedAngle) > 1 then
				manager:UpdateNode(pinIndex, 0, 0, nil)
			else
				local offsetX = 0.5 * compassWidth * normalizedAngle
				manager:UpdateNode(pinIndex, offsetX, 1, distanceMeters)
			end
		elseif pinIndex then
			manager:ReleaseNode(pinIndex)
			self.markerPinIndex[locationIndex] = nil
		end
	end
end
