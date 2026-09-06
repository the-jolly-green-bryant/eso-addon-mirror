-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local WorldPins = EASLoreLibrary.ProximityPinSet:Subclass()
EASLoreLibrary:RegisterModule("worldPins", WorldPins)

--[[
In-world (3D) pins for books near the player: acquires/releases a 3D control
from a pool for every undiscovered book within worldPinsDistance (see
ProximityPinSet for the shared acquire/release/distance-scan lifecycle).

Each pin needs its own 3D render space, so unlike the compass pins these
cannot be merged into a single composite control.

Screen size of a fixed-size 3D control is antiproportional to its distance
from the camera (basic projective geometry), so beyond FAR_RANGE_FRACTION of
the current worldPinsDistance, the fast per-frame tick scales each control's
actual size up proportionally to its distance, canceling out the perspective
shrink so pins hold roughly the screen size they had at that threshold
instead of dwindling to a speck near the edge of visibility. Closer than
that, controls use their normal base size and shrink with distance as usual.
]]--

local WORLD_PIN_WIDTH = 1 -- meters
local WORLD_PIN_HEIGHT = 2 -- meters
local WORLD_PIN_BASE_SIZE = 0.25 * WORLD_PIN_HEIGHT + 0.5
local WORLD_PIN_USE_DEPTH = false -- false = beams are visible through walls
local FAR_RANGE_FRACTION = 0.25
local SPAWN_INTERVAL_MS = 6000
local WORLD_PIN_VERTICAL_OFFSET = 3.0 -- meters above the collectible

-- The lore database stores persistent world coordinates in meters, while
-- 3D GUI controls live in GUI render-space coordinates.  Older builds fed
-- the raw meter values directly to Set3DRenderSpaceOrigin; that is close
-- enough to look plausible, but can introduce a visible horizontal drift
-- from the actual collectible. Convert the exact world point into GUI 3D
-- space first, then express it relative to the root render-space origin.
-- This changes X/Y alignment only; WORLD_PIN_VERTICAL_OFFSET remains the
-- same height above the book/scroll.
local function SetControlWorldOrigin(self, control, worldX, worldY, worldZ)
	local guiX, guiZ, guiY = WorldPositionToGuiRender3DPosition(worldX * 100, worldZ * 100, worldY * 100)
	if self.renderOriginX then
		guiX = guiX - self.renderOriginX
		guiZ = guiZ - self.renderOriginZ
		guiY = guiY - self.renderOriginY
	end
	control:Set3DRenderSpaceOrigin(guiX, guiZ, guiY)
end

-- 3D world pins intentionally show the icon only. Distance belongs on the
-- compass, where it is useful without adding floating-world text clutter.
local function HideDistanceLabel(control) end

function WorldPins:Initialize()
	self.pool = ZO_ControlPool:New("EASLL_WorldPin", EASLL_WorldPins, "EASLL_WorldPin")
	EASLL_WorldPins:Create3DRenderSpace()
	self.markerAcquired = {} -- index into self.markerLocations -> true, while shown
	self.markerLocations = {}
	self.markerEnabled = EASLoreLibrary.settings:IsPinTypeEnabled(EASLoreLibrary.MARKER)

	self.fragment = ZO_SimpleSceneFragment:New(EASLL_WorldPins)
	HUD_UI_SCENE:AddFragment(self.fragment)
	HUD_SCENE:AddFragment(self.fragment)
	LOOT_SCENE:AddFragment(self.fragment)

	self:InitializeBase({
		enabledSettingKey = "worldPinsEnabled",
		distanceSettingKey = "worldPinsDistance",
		spawnUpdateName = "EASLoreLibrary-WorldPinsSpawn",
		tickUpdateName = "EASLoreLibrary-WorldPinsUpdate",
		spawnIntervalMs = SPAWN_INTERVAL_MS,
		tickIntervalMs = 750,
	})

	EVENT_MANAGER:RegisterForEvent("EASLoreLibrary-WorldPins", EVENT_PLAYER_ACTIVATED, function()
		local worldX, worldZ, worldY = WorldPositionToGuiRender3DPosition(0, 0, 0)
		self.renderOriginX, self.renderOriginZ, self.renderOriginY = worldX, worldZ, worldY
		EASLL_WorldPins:Set3DRenderSpaceOrigin(worldX, worldZ, worldY)
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
	EASLoreLibrary.settings:RegisterCallback("SettingChanged", function(key)
		if key == "hideQuestDependentWorldPins" then
			self:ResetMarker()
			if self.running then self:RefreshPins() end
		end
	end)

	self:UpdateEnabled()
end

function WorldPins:ShouldAcquireNode(pinTypeId, nodeId)
	if EASLoreLibrary.settings:Get("hideQuestDependentWorldPins") ~= true then return true end
	local bookId = self.zoneCache and self.zoneCache.bookId[nodeId]
	return not EASLoreLibrary.IsQuestDependentBook(bookId)
end

function WorldPins:AcquireNode(pinTypeId, nodeId)
	local layout = EASLoreLibrary.mapPinLayout[pinTypeId]
	local control = self.pool:AcquireObject(nodeId)
	if not control:Has3DRenderSpace() then
		control:Create3DRenderSpace()
	end
	control:Set3DRenderSpaceUsesDepthBuffer(WORLD_PIN_USE_DEPTH)
	local bookId = self.zoneCache and self.zoneCache.bookId[nodeId]
	control:SetTexture(EASLoreLibrary.GetBookIcon(bookId, layout.texture))
	control:Set3DLocalDimensions(WORLD_PIN_BASE_SIZE, WORLD_PIN_BASE_SIZE)
	-- an undiscovered book that's also the tracked one gets both an ambient
	-- pin (this one) and a marker pin (see TickMarker) at the exact same 3D
	-- origin - with depth testing off (WORLD_PIN_USE_DEPTH), whichever one
	-- draws is otherwise a coin flip, so layout.level (MARKER is set higher
	-- than LOREBOOK/EIDETICBOOK in Main/PinTypes.lua) breaks the tie in the
	-- marker's favor
	control:SetDrawLevel(layout.level)
	control:SetColor(1, 1, 1, 1)

	local worldX = self.zoneCache.worldX[nodeId]
	local worldY = self.zoneCache.worldY[nodeId]
	local worldZ = self.zoneCache.worldZ[nodeId] + WORLD_PIN_VERTICAL_OFFSET
	SetControlWorldOrigin(self, control, worldX, worldY, worldZ)
end

function WorldPins:ReleaseNode(nodeId)
	local control = self.pool:GetActiveObject(nodeId)
	HideDistanceLabel(control)
	self.pool:ReleaseObject(nodeId)
end

function WorldPins:ReleaseAllPins()
	for _, control in pairs(self.pool:GetActiveObjects()) do
		HideDistanceLabel(control)
	end
	self.pool:ReleaseAllObjects()
	ZO_ClearTable(self.acquired)
	ZO_ClearTable(self.markerAcquired)
end

-- releases every currently shown tracked-book 3D pin; called whenever
-- MarkerPin fires "LocationsChanged" or the MARKER filter gets disabled,
-- since a stale index left over from a previous, longer locations array
-- would otherwise never get released
function WorldPins:ResetMarker()
	for locationIndex in pairs(self.markerAcquired) do
		local control = self.pool:GetActiveObject("marker-" .. locationIndex)
		HideDistanceLabel(control)
		self.pool:ReleaseObject("marker-" .. locationIndex)
	end
	ZO_ClearTable(self.markerAcquired)
end

-- re-orients, and rescales for the far-range effect (see file header), only
-- the controls that are currently acquired from the pool
function WorldPins:Tick()
	if self.fragment:IsHidden() then return end
	if not self.zoneCache then return end
	-- v0.29.341: when no ambient or tracked lore marker is currently active,
	-- skip player-position/camera reads entirely until the slower spawn scan
	-- acquires something.
	if next(self.acquired) == nil and (not self.markerEnabled or #self.markerLocations == 0) then return end

	local playerX, playerY = EASLoreLibrary.GetPlayer3DPosition()
	local heading = GetPlayerCameraHeading()
	local farRange = self.range * FAR_RANGE_FRACTION
	local zoneCache = self.zoneCache

	local lastHeading = tonumber(self.lastWorldHeading029315)
	local headingChanged = lastHeading == nil
	if not headingChanged then
		local delta = math.abs(heading - lastHeading)
		if delta > math.pi then delta = (math.pi * 2) - delta end
		headingChanged = delta >= 0.010
	end
	if headingChanged then self.lastWorldHeading029315 = heading end

	for nodeId in pairs(self.acquired) do
		local control = self.pool:GetActiveObject(nodeId)
		if headingChanged then control:Set3DRenderSpaceOrientation(0, heading, 0) end

		local dx = playerX - zoneCache.worldX[nodeId]
		local dy = playerY - zoneCache.worldY[nodeId]
		local distance = math.sqrt(dx * dx + dy * dy)
		local size = distance > farRange and (WORLD_PIN_BASE_SIZE * (distance / farRange)) or WORLD_PIN_BASE_SIZE
		local previousSize = tonumber(control.easLoreSize029315)
		if not previousSize or math.abs(size - previousSize) >= 0.03 then
			control.easLoreSize029315 = size
			control:Set3DLocalDimensions(size, size)
		end
	end

	self:TickMarker(heading)
end

-- shows/hides a 3D pin for each of the tracked book's locations that match
-- the player's CURRENT zone exactly (see Pins/MarkerPin.lua). Unlike the 2D
-- map/compass, which can approximate a sub-zone location by projecting it
-- onto its parent zone's map, a 3D render space origin only makes sense
-- within the zone the player is actually standing in, so - unlike
-- CompassPins:TickMarker - there's no "parent zone" case here. Not gated by
-- worldPinsEnabled/worldPinsDistance - an explicitly tracked book always
-- shows in the world (subject to the pin type's own filter toggle).
function WorldPins:TickMarker(heading)
	if not self.markerEnabled or #self.markerLocations == 0 then return end
	if EASLoreLibrary.settings:Get("hideQuestDependentWorldPins") == true
		and EASLoreLibrary.markerPin and EASLoreLibrary.IsQuestDependentBook(EASLoreLibrary.markerPin.bookId) then
		self:ResetMarker()
		return
	end

	local layout = EASLoreLibrary.mapPinLayout[EASLoreLibrary.MARKER]
	local playerZoneId = EASLoreLibrary.GetPlayerZoneId()

	for locationIndex, location in ipairs(self.markerLocations) do
		local key = "marker-" .. locationIndex

		if location.zoneId == playerZoneId then
			local control
			if not self.markerAcquired[locationIndex] then
				control = self.pool:AcquireObject(key)
				if not control:Has3DRenderSpace() then
					control:Create3DRenderSpace()
				end
				control:Set3DRenderSpaceUsesDepthBuffer(WORLD_PIN_USE_DEPTH)
				control:SetTexture(layout.texture)
				control:SetDrawLevel(layout.level)
				local tint = layout.tint or ZO_ColorDef:New(1, 1, 1, 1)
				control:SetColor(tint:UnpackRGBA())
				SetControlWorldOrigin(self, control, location.worldX, location.worldY, location.worldZ + WORLD_PIN_VERTICAL_OFFSET)
				self.markerAcquired[locationIndex] = true
			else
				control = self.pool:GetActiveObject(key)
			end
			control:Set3DRenderSpaceOrientation(0, heading, 0)
			control:Set3DLocalDimensions(WORLD_PIN_BASE_SIZE, WORLD_PIN_BASE_SIZE)
		elseif self.markerAcquired[locationIndex] then
			local control = self.pool:GetActiveObject(key)
			HideDistanceLabel(control)
			self.pool:ReleaseObject(key)
			self.markerAcquired[locationIndex] = nil
		end
	end
end
