
local CompassPins = LoreLibrary.ProximityPinSet:Subclass()
LoreLibrary:RegisterModule("compassPins", CompassPins)

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
	composite:SetDrawLevel(1)
	self.composite = composite

	if layout.tint then
		self.r, self.g, self.b = layout.tint:UnpackRGB()
	else
		self.r, self.g, self.b = 1, 1, 1
	end

	self.freeIndices = {}
end

-- acquires a surface index from the free-list, or creates a new one
function CompassPinManager:AcquireNode()
	local index = table.remove(self.freeIndices)
	if not index then
		index = self.composite:AddSurface(0, 1, 0, 1)
	end
	self.composite:SetSurfaceHidden(index, false)
	return index
end

-- hides the surface and returns its index to the free-list
function CompassPinManager:ReleaseNode(pinIndex)
	self.composite:SetSurfaceHidden(pinIndex, true)
	table.insert(self.freeIndices, pinIndex)
end

function CompassPinManager:ReleaseAllNodes()
	self.composite:ClearAllSurfaces()
	ZO_ClearTable(self.freeIndices)
end

function CompassPinManager:UpdateNode(pinIndex, offsetX, alpha)
	self.composite:SetInsets(pinIndex, offsetX, offsetX, 0, 0)
	self.composite:SetColor(pinIndex, self.r, self.g, self.b, alpha)
end

-----------------------------------------------------------

function CompassPins:Initialize()
	self.pinManagers = {}
	for _, pinTypeId in ipairs(LoreLibrary.PINTYPES) do
		self.pinManagers[pinTypeId] = CompassPinManager:New(LoreLibrary.mapPinLayout[pinTypeId])
	end
	self.pinIndex = {} -- nodeId -> pinIndex within its pin type's composite

	self:InitializeBase({
		enabledSettingKey = "compassPinsEnabled",
		distanceSettingKey = "compassPinsDistance",
		spawnUpdateName = "LoreLibrary-CompassPinsSpawn",
		tickUpdateName = "LoreLibrary-CompassPinsUpdate",
		spawnIntervalMs = SPAWN_INTERVAL_MS,
		tickIntervalMs = 30,
	})

	EVENT_MANAGER:RegisterForEvent("LoreLibrary-CompassPins", EVENT_PLAYER_ACTIVATED, function()
		self:RefreshZoneCache()
	end)

	self:UpdateEnabled()
end

function CompassPins:AcquireNode(pinTypeId, nodeId)
	self.pinIndex[nodeId] = self.pinManagers[pinTypeId]:AcquireNode()
end

function CompassPins:ReleaseNode(nodeId, pinTypeId)
	self.pinManagers[pinTypeId]:ReleaseNode(self.pinIndex[nodeId])
	self.pinIndex[nodeId] = nil
end

function CompassPins:ReleaseAllPins()
	for _, manager in pairs(self.pinManagers) do
		manager:ReleaseAllNodes()
	end
	ZO_ClearTable(self.pinIndex)
	ZO_ClearTable(self.acquired)
end

-- repositions only the surfaces that are currently acquired
function CompassPins:Tick()
	if not self.zoneCache then return end

	local playerX, playerY = LoreLibrary.GetPlayer3DPosition()
	local heading = GetPlayerCameraHeading()
	if heading > pi then
		heading = heading - 2 * pi
	end

	local compassRange2 = self.range * self.range
	local compassWidth = PARENT:GetWidth()

	local zoneCache = self.zoneCache
	for nodeId, pinTypeId in pairs(self.acquired) do
		local pinIndex = self.pinIndex[nodeId]
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

		local manager = self.pinManagers[pinTypeId]
		if normalizedDistance >= 1 or zo_abs(normalizedAngle) > 1 then
			manager:UpdateNode(pinIndex, 0, 0)
		else
			local offsetX = 0.5 * compassWidth * normalizedAngle
			local alpha = 1 - normalizedDistance * normalizedDistance * normalizedDistance * normalizedDistance
			manager:UpdateNode(pinIndex, offsetX, alpha)
		end
	end
end
