
local WorldPins = LoreLibrary.ProximityPinSet:Subclass()
LoreLibrary:RegisterModule("worldPins", WorldPins)

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
local SPAWN_INTERVAL_MS = 3000

function WorldPins:Initialize()
	self.pool = ZO_ControlPool:New("LL_WorldPin", LL_WorldPins, "LL_WorldPin")
	LL_WorldPins:Create3DRenderSpace()

	self.fragment = ZO_SimpleSceneFragment:New(LL_WorldPins)
	HUD_UI_SCENE:AddFragment(self.fragment)
	HUD_SCENE:AddFragment(self.fragment)
	LOOT_SCENE:AddFragment(self.fragment)

	self:InitializeBase({
		enabledSettingKey = "worldPinsEnabled",
		distanceSettingKey = "worldPinsDistance",
		spawnUpdateName = "LoreLibrary-WorldPinsSpawn",
		tickUpdateName = "LoreLibrary-WorldPinsUpdate",
		spawnIntervalMs = SPAWN_INTERVAL_MS,
		tickIntervalMs = 30,
	})

	EVENT_MANAGER:RegisterForEvent("LoreLibrary-WorldPins", EVENT_PLAYER_ACTIVATED, function()
		local worldX, worldZ, worldY = WorldPositionToGuiRender3DPosition(0, 0, 0)
		LL_WorldPins:Set3DRenderSpaceOrigin(worldX, worldZ, worldY)
		self:RefreshZoneCache()
	end)

	self:UpdateEnabled()
end

function WorldPins:AcquireNode(pinTypeId, nodeId)
	local layout = LoreLibrary.mapPinLayout[pinTypeId]
	local control = self.pool:AcquireObject(nodeId)
	if not control:Has3DRenderSpace() then
		control:Create3DRenderSpace()
	end
	control:Set3DRenderSpaceUsesDepthBuffer(WORLD_PIN_USE_DEPTH)
	control:SetTexture(layout.texture)
	control:Set3DLocalDimensions(WORLD_PIN_BASE_SIZE, WORLD_PIN_BASE_SIZE)
	local tint = layout.tint or ZO_ColorDef:New(1, 1, 1, 1)
	control:SetColor(tint:UnpackRGBA())

	local worldX, worldY, worldZ = self.zoneCache.worldX[nodeId], self.zoneCache.worldY[nodeId], self.zoneCache.worldZ[nodeId] + 2
	control:Set3DRenderSpaceOrigin(worldX, worldZ, worldY)
end

function WorldPins:ReleaseNode(nodeId)
	self.pool:ReleaseObject(nodeId)
end

function WorldPins:ReleaseAllPins()
	self.pool:ReleaseAllObjects()
	ZO_ClearTable(self.acquired)
end

-- re-orients, and rescales for the far-range effect (see file header), only
-- the controls that are currently acquired from the pool
function WorldPins:Tick()
	if self.fragment:IsHidden() then return end
	if not self.zoneCache then return end

	local playerX, playerY = LoreLibrary.GetPlayer3DPosition()
	local heading = GetPlayerCameraHeading()
	local farRange = self.range * FAR_RANGE_FRACTION
	local zoneCache = self.zoneCache

	for nodeId in pairs(self.acquired) do
		local control = self.pool:GetActiveObject(nodeId)
		control:Set3DRenderSpaceOrientation(0, heading, 0)

		local dx = playerX - zoneCache.worldX[nodeId]
		local dy = playerY - zoneCache.worldY[nodeId]
		local distance = math.sqrt(dx * dx + dy * dy)
		if distance > farRange then
			local size = WORLD_PIN_BASE_SIZE * (distance / farRange)
			control:Set3DLocalDimensions(size, size)
		else
			control:Set3DLocalDimensions(WORLD_PIN_BASE_SIZE, WORLD_PIN_BASE_SIZE)
		end
	end
end
