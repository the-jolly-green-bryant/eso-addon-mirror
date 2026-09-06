-- Integrated into ESO Adventurer Suite; original data/marker architecture retained and namespaced.

local PinController = {}
EASLoreLibrary:RegisterModule("pinController", PinController)

--[[
This file handles creation and maintenance of texture controls, i.e., map pins.
It also handles compatibility between different kind of maps, such as
main map or the various minimap addons.
Adapted from the reference map system's Pins/MapPinController.lua.
]]--

local NO_MAP_MODE, MAIN_MAP_MODE, VOTAN_MODE, FYR_MODE, AUI_MODE

local PinTypeManager = ZO_Object:Subclass()

function PinController:Initialize()

	self.MAP_WIDTH = 0
	self.MAP_HEIGHT = 0
	self.pinTypeManagers = {}

	self.scroll = CreateControl("EASLL_Scroll", ZO_WorldMap, CT_SCROLL)
	self.scroll:SetAnchor(TOPLEFT, ZO_WorldMapScroll, TOPLEFT, 0, 0)
	self.scroll:SetAnchor(BOTTOMRIGHT, ZO_WorldMapScroll, BOTTOMRIGHT, 0, 0)

	self.container = CreateControl("EASLL_Container", self.scroll, CT_CONTROL)
	self.container:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, 0, 0)

	self.zoom = ZO_WorldMap_GetPanAndZoom()
	PinController.minZoom, PinController.maxZoom = self.zoom.minZoom, self.zoom.maxZoom

	ZO_PreHook(ZO_WorldMapPins_Manager, "UpdatePinsForMapSizeChange", function()
		PinController:OnMapSizeChange(ZO_WorldMapContainer:GetDimensions())
	end)
	ZO_PreHook(PinController.zoom, "SetZoomMinMax", function(self, min, max)
		PinController.minZoom = min
		PinController.maxZoom = max
		PinController:OnMapSizeChange(ZO_WorldMapContainer:GetDimensions())
	end)

	WORLD_MAP_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_FRAGMENT_HIDDEN then
			self:CheckMapMode()
			local width, height = self.activeMode:GetDimensions()
			if self.MAP_WIDTH ~= width or self.MAP_HEIGHT ~= height then
				PinController:OnMapSizeChange(width, height)
			end
		end
	end)

	self:InitializeFyr()
	self:InitializeAUI()

	self:InitializeMouseHandling()
	--self:InitializeGamepadMagnetism()
end

function PinController:InitializeMouseHandling()
	self.onClickHandlers = {}

	-- UI controls survive /reloadui and can also be left behind by an older
	-- version of the Lore Library. Never blindly CreateControl() with a
	-- global name, or ESO will throw a duplicate-control error.
	self.mouseOverPin = GetControl("EASLL-mouseover")
	if not self.mouseOverPin then
		self.mouseOverPin = GetControl("LL-mouseover")
	end
	if not self.mouseOverPin then
		self.mouseOverPin = CreateControl("EASLL-mouseover", self.container, CT_TEXTURE)
	end

	self.mouseOverPin:SetHidden(true)
	self.mouseOverPin:SetDrawTier(DT_HIGH)
	self.mouseOverPin:SetPixelRoundingEnabled(false)
	
	if ZO_IsConsoleOrGameCoreUI() then return end
	
	ZO_PreHook("ZO_WorldMap_MouseEnter", function()

		-- check 10/second if mouse is over a pin; avoids burning map frames on a static cursor
		EVENT_MANAGER:RegisterForUpdate("EASLoreLibrary-MouseOver", 150, function()
			local pinIndex, pinTypeId = self:GetMouseOverPinIndexAndType()
			if not pinIndex then return end
			self:ShowSelectionControl(pinIndex, pinTypeId)
		end)
	end)

	ZO_PreHook("ZO_WorldMap_MouseExit", function()
		EVENT_MANAGER:UnregisterForUpdate("EASLoreLibrary-MouseOver")
	end)

	self.mouseOverPin:SetHandler("OnMouseEnter", function()
		self.mouseOverPin:SetScale(1.3)
		local nodeId = self:GetNodeId(self.mouseOverPin.pinIndex, self.mouseOverPin.pinTypeId)
		local title = self:GetBookTitle(self.mouseOverPin.pinTypeId, nodeId)
		if title then
			ZO_Tooltips_ShowTextTooltip(self.mouseOverPin, TOP, title)
		end
	end)
	self.mouseOverPin:SetHandler("OnMouseExit", function()
		self.mouseOverPin:SetScale(1)
		self.mouseOverPin:SetHidden(true)
		self.mouseOverPin:SetMouseEnabled(false)
		ZO_Tooltips_HideTextTooltip()
	end)
	self.mouseOverPin:SetHandler("OnMouseUp", function(control, button)
		if button ~= MOUSE_BUTTON_INDEX_LEFT then
			return
		end

		local pinIndex, pinTypeId = self:GetMouseOverPinIndexAndType()
		if not pinIndex then return end

		for i, handler in ipairs(self.onClickHandlers) do
			if (not handler.isActive) or handler.isActive() then
				if (not handler.show) or handler.show(pinIndex, pinTypeId, self) then
					handler.callback(pinIndex, pinTypeId, self)
					return
				end
			end
		end
	end)
end

function PinController:SetClickHandlers(handlers)
	self.onClickHandlers = handlers
end

function PinController:GetNodeId(pinIndex, pinTypeId)
	return self.pinTypeManagers[pinTypeId].nodeId[pinIndex]
end

-- returns the title of the book at nodeId, or nil if it can't be resolved
function PinController:GetBookTitle(pinTypeId, nodeId)
	local zoneCache = self.pinTypeManagers[pinTypeId].zoneCache
	local bookId = zoneCache and zoneCache.bookId[nodeId]
	if not bookId then return nil end
	return EASLoreLibrary.GetBookTitle(bookId)
end

function PinController:ShowSelectionControl(pinIndex, pinTypeId)
	local manager = self.pinTypeManagers[pinTypeId]
	local composite = manager:GetPinComposite(pinIndex)
	local x, _, y, _ = manager:GetPinInsets(pinIndex)
	self.mouseOverPin:SetAnchor(CENTER, self.container, TOPLEFT, x, y)
	self.mouseOverPin:SetDimensions(composite:GetDimensions())
	local inset = self.mouseOverPin:GetWidth() * 0.25
	self.mouseOverPin:SetHitInsets(inset, inset, -inset, -inset)
	self.mouseOverPin:SetHidden(false)
	self.mouseOverPin:SetTexture(composite:GetTextureFileName())
	self.mouseOverPin:SetColor(self.pinTypeManagers[pinTypeId]:GetPinColor(pinIndex))
	self.mouseOverPin:SetDrawLevel(composite:GetDrawLevel() + 1)
	self.mouseOverPin:SetMouseEnabled(true)
	self.mouseOverPin.pinTypeId = pinTypeId
	self.mouseOverPin.pinIndex = pinIndex
end

function PinController:GetMouseOverPinIndexAndType()
	local x, y = GetUIMousePosition()
	x = x - ZO_WorldMapContainer:GetLeft()
	y = y - ZO_WorldMapContainer:GetTop()
	local minPinDistance = math.huge
	local minPinTypeId, minPinIndex
	for pinTypeId, pinTypeManager in pairs(self.pinTypeManagers) do
		local pinIndex, pinDist = pinTypeManager:GetMouseOverPinAndDistance(x, y)
		if pinDist then
			if pinDist < minPinDistance then
				minPinDistance = pinDist
				minPinTypeId = pinTypeId
				minPinIndex = pinIndex
			end
		end
	end
	return minPinIndex, minPinTypeId
end

--[[
Gamepad/console equivalent of the mouse-hover handling above: in gamepad
mode, ZO_WorldMapPins_Manager:BuildMouseOverPinLists (mappin_manager.lua)
re-checks proximity to the fixed reticle (ZO_WorldMapScroll's center) every
time it runs, drives the native "sticky pin" magnetism (panning the map onto
whatever's nearest) and feeds the gamepad info tooltip - but only for real
ZO_MapPin objects registered with the pin manager, which our composite-based
pins aren't. Rather than duck-typing a full ZO_MapPin (a large, fragile
surface used every frame for every pin on the map), we hook that same
function to additionally run our own equivalent proximity check afterward,
using the exact cursor position it already computed, and drive the same two
public effects (pan to it, show its title in the gamepad tooltip) ourselves.
If a real pin already won magnetism this frame, we defer to it.
]]--

-- like GetMouseOverPinIndexAndType above, but takes container-relative
-- coordinates directly instead of always reading the mouse position, has no
-- small icon-radius gate (uses GetNearestPinAndDistance, not
-- GetMouseOverPinAndDistance), and also returns the winning (squared,
-- screen-pixel) distance - so callers can apply their own, much larger,
-- magnetism threshold and compare against the native sticky pin's candidate
function PinController:FindNearestPinAt(x, y)
	local minPinDistance = math.huge
	local minPinTypeId, minPinIndex
	for pinTypeId, pinTypeManager in pairs(self.pinTypeManagers) do
		local pinIndex, pinDist = pinTypeManager:GetNearestPinAndDistance(x, y)
		if pinDist then
			if pinDist < minPinDistance then
				minPinDistance = pinDist
				minPinTypeId = pinTypeId
				minPinIndex = pinIndex
			end
		end
	end
	return minPinIndex, minPinTypeId, minPinDistance
end

--[[
A time-based cooldown on its own only delays the chain, it doesn't stop it:
BuildMouseOverPinLists recomputes the native sticky candidate every ~0.3s
using the CURRENT (screen-fixed) reticle position, so once we've panned onto
one of our own book pins, a real pin that happens to sit close to it on the
map will legitimately become the new nearest-candidate a tick or two later -
and after any fixed cooldown expires, GamepadMap:UpdateDirectionalInput's own
idle loop will snap onto it via MoveToStickyPin, same as it always does once
idle+settled. That data point (a real pin near where WE just parked the view)
only exists because of our own pan, not because the player asked to go there.

So instead of a timer, track *who currently holds gamepad map focus* - "ours"
or "native" - and simply don't let the other side contest it. Once the player
actually moves the stick, native's own ClearStickyPin call (hooked below)
naturally releases "native"; our own re-evaluation naturally releases "ours"
once nothing of ours is within range any more (see ClearGamepadFocus). Only
when nobody currently holds focus can either side claim it.
]]--
function PinController:InitializeGamepadMagnetism()
	ZO_PostHook(ZO_WorldMapPins_Manager, "BuildMouseOverPinLists", function(mgr, cursorPositionX, cursorPositionY)
		self:OnGamepadMouseOverPinsBuilt(cursorPositionX, cursorPositionY)
	end)

	local stickyPin = ZO_WorldMap_GetStickyPin()

	local originalMoveToStickyPin = stickyPin.MoveToStickyPin
	stickyPin.MoveToStickyPin = function(pinSelf, ...)
		if self.gamepadFocusOwner == "ours" then
			return -- we're still holding focus on one of our own pins; don't let native steal it back
		end
		self.gamepadFocusOwner = "native"
		return originalMoveToStickyPin(pinSelf, ...)
	end

	local originalClearStickyPin = stickyPin.ClearStickyPin
	stickyPin.ClearStickyPin = function(pinSelf, ...)
		if self.gamepadFocusOwner == "native" then
			self.gamepadFocusOwner = nil
		end
		return originalClearStickyPin(pinSelf, ...)
	end
end

function PinController:OnGamepadMouseOverPinsBuilt(cursorPositionX, cursorPositionY)
	if not IsInGamepadPreferredMode() then return end
	if not self.zoom:ReachedTargetOffset() then return end
	if self.gamepadFocusOwner == "native" then return end -- native currently holds focus; don't contest it

	local x = cursorPositionX - ZO_WorldMapContainer:GetLeft()
	local y = cursorPositionY - ZO_WorldMapContainer:GetTop()
	local pinIndex, pinTypeId, pinDistance = self:FindNearestPinAt(x, y)

	local stickyPin = ZO_WorldMap_GetStickyPin()
	if pinIndex and pinDistance > stickyPin.thresholdDistanceSq then
		-- outside the native magnetism radius (the same one real pins use,
		-- which already scales with zoom) - too far to count as "nearby"
		pinIndex = nil
	end

	if pinIndex then
		-- at most zoom levels some real pin (a zone label, POI, wayshrine...)
		-- is within the native sticky-pin radius almost all the time, so only
		-- defer to it if it's actually closer to the reticle than ours is
		if stickyPin:GetStickyPin() and stickyPin.nearestCandidateDistanceSq < pinDistance then
			pinIndex = nil
		end
	end

	if not pinIndex then
		self:ClearGamepadFocus()
		return
	end

	local nodeId = self:GetNodeId(pinIndex, pinTypeId)
	if self.gamepadFocusedNodeId == nodeId then
		return -- already focused on this one; don't keep re-panning/re-showing every tick
	end
	self.gamepadFocusedNodeId = nodeId
	self.gamepadFocusOwner = "ours"

	-- reuse the same mouseOverPin highlight control the keyboard hover uses
	-- (created in InitializeMouseHandling regardless of ZO_IsConsoleOrGameCoreUI), so the
	-- currently-focused pin is visibly highlighted in gamepad mode too
	self:ShowSelectionControl(pinIndex, pinTypeId)
	self.mouseOverPin:SetScale(1.3)

	local zoneCache = self.pinTypeManagers[pinTypeId].zoneCache
	local normalizedX, normalizedY = zoneCache:GetLocal(nodeId)
	ZO_WorldMap_PanToNormalizedPosition(normalizedX, normalizedY)

	local title = self:GetBookTitle(pinTypeId, nodeId)
	if title then
		-- ZO_WorldMap_ShowGamepadTooltip returns ZO_MapLocationTooltip_Gamepad,
		-- which lays out content as sections (AcquireSection/AddSection) via
		-- its .tooltip sub-object and ZO_MapInformationTooltip_Gamepad_Mixin,
		-- not a plain AddLine - mirrors maptooltips.lua's AppendSkyshardHint.
		-- It only clears its own previous content the first time it's shown
		-- (or after being fully hidden), so hopping from one of our pins
		-- straight to another needs an explicit ClearLines or the new title
		-- just gets appended below the old one.
		local mapTooltip = ZO_WorldMap_ShowGamepadTooltip(true)
		if mapTooltip and mapTooltip.tooltip then
			local RESET_SCROLL = true
			mapTooltip:ClearLines(RESET_SCROLL)
			local section = mapTooltip.tooltip:AcquireSection(mapTooltip.tooltip:GetStyle("skyshardMainSection"))
			mapTooltip:LayoutStringLine(section, title, mapTooltip.tooltip:GetStyle("skyshardHint"))
			mapTooltip.tooltip:AddSection(section)
		end
	end
end

function PinController:ClearGamepadFocus()
	if not self.gamepadFocusedNodeId then return end
	self.gamepadFocusedNodeId = nil
	if self.gamepadFocusOwner == "ours" then
		self.gamepadFocusOwner = nil
	end
	self.mouseOverPin:SetScale(1)
	self.mouseOverPin:SetHidden(true)
	ZO_WorldMap_HideAllTooltips()
end

function PinController:InitializeFyr()
	if not Fyr_MM then return end
	self:HookMinimap(Fyr_MM_Scroll_Map)

	local orig = FyrMM.UpdateMapTiles
	function FyrMM.UpdateMapTiles(...)
		orig(...)
		if self.activeMode == FYR_MODE and FyrMM.SV.RotateMap and FyrMM.currentMap.Heading then
			FYR_MODE.cos = math.cos(-FyrMM.currentMap.Heading)
			FYR_MODE.sin = math.sin(-FyrMM.currentMap.Heading)
			FYR_MODE.offsetX = FyrMM.currentMap.PlayerX
			FYR_MODE.offsetY = FyrMM.currentMap.PlayerY
		end
	end
end

function PinController:InitializeAUI()
	if not (AUI and AUI.Minimap) then return end
	self:HookMinimap(AUI_MapContainer)

	ZO_PreHook(AUI.Minimap.Pin, "UpdateAllLocations", function()
		if self.activeMode == AUI_MODE and AUI.Settings.Minimap.rotate then
			AUI_MODE.cos = math.cos(-AUI.MapData.heading)
			AUI_MODE.sin = math.sin(-AUI.MapData.heading)
			AUI_MODE.offsetX = AUI.MapData.mapContainerSize * AUI.MapData.playerX
			AUI_MODE.offsetY = AUI.MapData.mapContainerSize * AUI.MapData.playerY

			for pinTypeId, pinManager in pairs(self.pinTypeManagers) do
				for pinIndex, nodeId in pairs(pinManager.nodeId) do
					pinManager:UpdateLocationOfPinWithIndex(pinIndex)
				end
			end
		end
	end)
end

function PinController:SetMode(mode)
	assert(mode)
	local previousMode = self.activeMode
	self.activeMode = mode
	if self.activeMode ~= previousMode then
		self.activeMode:Activate()
	end
end

function PinController:CheckMapMode()
	local mode = MAIN_MAP_MODE
	if not ZO_WorldMap_IsWorldMapShowing() then -- minimap
		mode = NO_MAP_MODE
		if FyrMM then
			mode = FYR_MODE
		end
		if (AUI and AUI.Minimap:IsEnabled()) then
			mode = AUI_MODE
		end
		if VOTANS_MINIMAP then
			mode = VOTAN_MODE
		end
	end
	self:SetMode(mode)
end

function PinController:OnMapSizeChange(width, height)
	assert(width and height)
	self.MAP_WIDTH = width
	self.MAP_HEIGHT = height
	self:CheckMapMode()

	for pinTypeId, pinManager in pairs(self.pinTypeManagers) do
		pinManager:UpdateSize()
		for pinIndex, nodeId in pairs(pinManager.nodeId) do
			pinManager:UpdateLocationOfPinWithIndex(pinIndex)
		end
	end

	-- OnMapSizeChange can fire while the module is initializing. If another
	-- addon/old version prevented mouse handling from finishing, the hover
	-- control may not exist yet. Do not let that break the map pin system.
	if self.mouseOverPin and not self.mouseOverPin:IsHidden() then
		local manager = self.pinTypeManagers[self.mouseOverPin.pinTypeId]
		if manager and self.mouseOverPin.pinIndex then
			local x, _, y, _ = manager:GetPinInsets(self.mouseOverPin.pinIndex)
			self.mouseOverPin:SetAnchor(CENTER, self.container, TOPLEFT, x, y)
		end
	end
end

function PinController:RemoveAllPins()
	for pinTypeId, pinTypeManager in pairs(self.pinTypeManagers) do
		pinTypeManager:RemoveAllPins()
	end
end

function PinController:RefreshLayout()
	for pinTypeId, pinTypeManager in pairs(self.pinTypeManagers) do
		pinTypeManager:RefreshLayout()
	end
end

function PinController:RegisterPinType(pinTypeId, layout)
	local pinTypeManager = PinTypeManager:New(layout, pinTypeId)
	self.pinTypeManagers[pinTypeId] = pinTypeManager
end

function PinController:CreatePinForNodeId(pinTypeId, nodeId)
	self.pinTypeManagers[pinTypeId]:GetNewPinForNodeId(nodeId)
end

function PinController:SetZoneCache(zoneCache)
	for pinTypeId, pinTypeManager in pairs(self.pinTypeManagers) do
		pinTypeManager:SetZoneCache(zoneCache)
	end
end

function PinController:RemovePinForNodeId(pinTypeId, nodeId)
	self.pinTypeManagers[pinTypeId]:RemovePinForNodeId(nodeId)
end

function PinController:HookMinimap(minimapContainer)
	local oldDimensions = minimapContainer.SetDimensions
	minimapContainer.SetDimensions = function(self, width, height, ...)
		if not ZO_WorldMap_IsWorldMapShowing() then
			PinController:OnMapSizeChange(width, height)
		end
		oldDimensions(self, width, height, ...)
	end
end

PinTypeManager.lastPinId = 0

function PinTypeManager:New(...)
	local obj = ZO_Object.New(self)
	obj:Initialize(...)
	return obj
end

function PinTypeManager:Initialize(layout, pinTypeId)
	self.layout = layout
	self.pinTypeId = pinTypeId
	self.nodeId = {}            -- logical pinIndex -> nodeId
	self.pinSurface = {}        -- logical pinIndex -> { composite, surfaceIndex }
	self.composites = {}        -- texture path -> CT_TEXTURECOMPOSITE
	self.lastPinIndex = 0
end

function PinTypeManager:GetCompositeForTexture(texture)
	texture = texture or self.layout.texture
	local composite = self.composites[texture]
	if composite then return composite end
	composite = PinController.container:CreateControl(nil, CT_TEXTURECOMPOSITE)
	composite:SetDrawTier(2)
	composite:SetAnchor(CENTER, PinController.container, TOPLEFT, 0, 0)
	composite:SetPixelRoundingEnabled(false)
	composite:SetDrawLevel(zo_max(self.layout.level, 1))
	composite:SetTexture(texture)
	self.composites[texture] = composite
	self:UpdateSize()
	return composite
end

function PinTypeManager:GetPinComposite(pinIndex)
	local ref = self.pinSurface[pinIndex]
	return ref and ref.composite
end

function PinTypeManager:GetPinInsets(pinIndex)
	local ref = self.pinSurface[pinIndex]
	if not ref then return nil end
	return ref.composite:GetInsets(ref.surfaceIndex)
end

function PinTypeManager:GetPinColor(pinIndex)
	local ref = self.pinSurface[pinIndex]
	if not ref then return 1,1,1,1 end
	return ref.composite:GetColor(ref.surfaceIndex)
end

function PinTypeManager:RefreshLayout()
	for _, composite in pairs(self.composites) do
		composite:SetDrawLevel(zo_max(self.layout.level, 1))
	end
	self:UpdateSize()
	for pinIndex in pairs(self.nodeId) do
		self:RefreshLayoutOfPin(pinIndex)
	end
end

function PinTypeManager:RefreshLayoutOfPin(pinIndex)
	local ref = self.pinSurface[pinIndex]
	if not ref then return end
	-- Native lore-entry textures already contain their intended color. Do not
	-- tint them or purple/green/white-gold/black/crimson/blue all collapse to
	-- one addon color.
	ref.composite:SetColor(ref.surfaceIndex, 1, 1, 1, 1)
	self:UpdateLocationOfPinWithIndex(pinIndex)
end

function PinTypeManager:SetPinInsets(pinIndex, x, y)
	local ref = self.pinSurface[pinIndex]
	if not ref then return end
	ref.composite:SetInsets(ref.surfaceIndex, x, x, y, y)
end

function PinTypeManager:UpdateLocationOfPinWithIndex(pinIndex)
	local nodeId = self.nodeId[pinIndex]
	if not nodeId then return end
	local x, y = self.zoneCache:GetLocal(nodeId)
	self:SetPinInsets(pinIndex, x * PinController.MAP_WIDTH, y * PinController.MAP_WIDTH)
end
local OriginalUpdateLocation = PinTypeManager.UpdateLocationOfPinWithIndex

function PinTypeManager:UpdateSize()
	local layout = self.layout
	local size = layout.size / GetUICustomScale()
	if VOTANS_MINIMAP and VOTANS_MINIMAP.scale and WORLD_MAP_MANAGER:IsInMode(MAP_MODE_VOTANS_MINIMAP) then
		size = size * VOTANS_MINIMAP:CalculateScale("Others")
	elseif FyrMM and not ZO_WorldMap_IsWorldMapShowing() then
		size = size * FyrMM.pScalePercent
	end
	layout.currentPinSize = size
	for _, composite in pairs(self.composites) do
		composite:SetDimensions(size, size)
	end
end

function PinTypeManager:GetMouseOverPinAndDistance(x, y)
	local size = self.layout.currentPinSize or self.layout.size
	local minDist = math.huge
	local minPinIndex
	for pinIndex in pairs(self.nodeId) do
		local pinX, _, pinY = self:GetPinInsets(pinIndex)
		if pinX then
			local dist = (x - pinX) * (x - pinX) + (y - pinY) * (y - pinY)
			if dist < minDist then minDist, minPinIndex = dist, pinIndex end
		end
	end
	if minPinIndex and minDist < (size / 2) * (size / 2) then
		return minPinIndex, minDist
	end
end

function PinTypeManager:GetNearestPinAndDistance(x, y)
	local minDist = math.huge
	local minPinIndex
	for pinIndex in pairs(self.nodeId) do
		local pinX, _, pinY = self:GetPinInsets(pinIndex)
		if pinX then
			local dist = (x - pinX) * (x - pinX) + (y - pinY) * (y - pinY)
			if dist < minDist then minDist, minPinIndex = dist, pinIndex end
		end
	end
	if minPinIndex then return minPinIndex, minDist end
end

function PinTypeManager:RemoveAllPins()
	for _, composite in pairs(self.composites) do
		composite:ClearAllSurfaces()
	end
	ZO_ClearTable(self.nodeId)
	ZO_ClearTable(self.pinSurface)
	self.lastPinIndex = 0
end

function PinTypeManager:RemovePinForNodeId(nodeId)
	local removePinIndex
	for pinIndex, pinNodeId in pairs(self.nodeId) do
		if nodeId == pinNodeId then removePinIndex = pinIndex break end
	end
	if not removePinIndex then return end
	local ref = self.pinSurface[removePinIndex]
	local composite, surfaceIndex = ref.composite, ref.surfaceIndex
	local lastSurface = composite:GetNumSurfaces()
	if surfaceIndex ~= lastSurface then
		-- CT_TEXTURECOMPOSITE can only remove its last surface. Move the logical
		-- pin using that last surface into this slot first.
		for otherPinIndex, otherRef in pairs(self.pinSurface) do
			if otherPinIndex ~= removePinIndex and otherRef.composite == composite and otherRef.surfaceIndex == lastSurface then
				otherRef.surfaceIndex = surfaceIndex
				local x1,x2,y1,y2 = composite:GetInsets(lastSurface)
				composite:SetInsets(surfaceIndex, x1,x2,y1,y2)
				local r,g,b,a = composite:GetColor(lastSurface)
				composite:SetColor(surfaceIndex, r,g,b,a)
				break
			end
		end
	end
	composite:RemoveSurface(lastSurface)
	self.nodeId[removePinIndex] = nil
	self.pinSurface[removePinIndex] = nil
end

function PinTypeManager:SetZoneCache(zoneCache)
	for _, composite in pairs(self.composites) do
		assert(composite:GetNumSurfaces() == 0, "still displaying pins of previous cache!")
	end
	if self.zoneCache then self.zoneCache:UnregisterAccess(self) end
	self.zoneCache = zoneCache
	if self.zoneCache then self.zoneCache:RegisterAccess(self) end
end

function PinTypeManager:GetNewPinForNodeId(nodeId)
	local bookId = self.zoneCache and self.zoneCache.bookId[nodeId]
	local texture = EASLoreLibrary.GetBookIcon(bookId, self.layout.texture)
	local composite = self:GetCompositeForTexture(texture)
	local surfaceIndex = composite:AddSurface(0, 1, 0, 1)
	self.lastPinIndex = self.lastPinIndex + 1
	local pinIndex = self.lastPinIndex
	self.nodeId[pinIndex] = nodeId
	self.pinSurface[pinIndex] = { composite = composite, surfaceIndex = surfaceIndex }
	self:RefreshLayoutOfPin(pinIndex)
end

MAIN_MAP_MODE = {
	Activate = function(self)
		PinController.container:ClearAnchors()
		PinController.container:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, 0, 0)
		PinController.container:SetParent(ZO_WorldMapContainer)
		PinTypeManager.UpdateLocationOfPinWithIndex = OriginalUpdateLocation
	end,
	GetDimensions = function(self)
		return ZO_WorldMapContainer:GetDimensions()
	end,
}
NO_MAP_MODE = {
	Activate = function(self) end,
	GetDimensions = function(self)
		return ZO_WorldMapContainer:GetDimensions()
	end,
}
VOTAN_MODE = {
	Activate = function(self)
		PinController.container:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, 0, 0)
		PinController.container:SetParent(ZO_WorldMapContainer)
	end,
	GetDimensions = function(self)
		return ZO_WorldMapContainer:GetDimensions()
	end,
}
FYR_MODE = {
	Activate = function(self)
		if FyrMM.SV.WheelMap then
			PinController.container:SetParent(PinController.scroll)
			PinController.scroll:SetParent(Fyr_MM_Scroll_CW_Map_Pins)
			PinController.scroll:SetAnchor(TOPLEFT, Fyr_MM_Scroll_WheelCenter, TOPLEFT, 0, 0)
			PinController.scroll:SetAnchor(BOTTOMRIGHT, Fyr_MM_Scroll_WheelCenter, BOTTOMRIGHT, 0, 0)
		else
			PinController.container:SetParent(Fyr_MM_Scroll_Map)
		end
		if FyrMM.SV.RotateMap then
			PinController.container:ClearAnchors()
			PinController.container:SetAnchor(CENTER, Fyr_MM_Scroll, CENTER, 0, 0)
			PinTypeManager.UpdateLocationOfPinWithIndex = self.UpdateLocationOfPinWithIndex
			if FyrMM.currentMap.Heading then
				FYR_MODE.cos = math.cos(-FyrMM.currentMap.Heading)
				FYR_MODE.sin = math.sin(-FyrMM.currentMap.Heading)
				FYR_MODE.offsetX = FyrMM.currentMap.PlayerX
				FYR_MODE.offsetY = FyrMM.currentMap.PlayerY
			else
				FYR_MODE.cos = 0
				FYR_MODE.sin = 0
				FYR_MODE.offsetX = 0
				FYR_MODE.offsetY = 0
			end
		else
			PinController.container:ClearAnchors()
			PinController.container:SetAnchor(TOPLEFT, Fyr_MM_Scroll_Map, TOPLEFT, 0, 0)
			PinTypeManager.UpdateLocationOfPinWithIndex = OriginalUpdateLocation
		end
	end,
	GetDimensions = function(self)
		return Fyr_MM_Scroll_Map:GetDimensions()
	end,
	UpdateLocationOfPinWithIndex = function(self, pinIndex)
		local x, y = self.zoneCache:GetLocal(self.nodeId[pinIndex])
		x = x * PinController.MAP_WIDTH - FYR_MODE.offsetX
		y = y * PinController.MAP_WIDTH - FYR_MODE.offsetY
		local rotatedX = FYR_MODE.cos * x - FYR_MODE.sin * y
		local rotatedY = FYR_MODE.sin * x + FYR_MODE.cos * y
		self:SetPinInsets(pinIndex, rotatedX, rotatedY)
	end,
}
AUI_MODE = {
	Activate = function(self)
		PinController.container:SetParent(AUI_MapContainer)
		if AUI.Settings.Minimap.rotate then
			PinController.container:ClearAnchors()
			PinController.container:SetAnchor(CENTER, AUI_Minimap_Map_Scroll, CENTER, 0, 0)
			PinTypeManager.UpdateLocationOfPinWithIndex = self.UpdateLocationOfPinWithIndex
			if AUI.MapData.heading then
				AUI_MODE.cos = math.cos(-AUI.MapData.heading)
				AUI_MODE.sin = math.sin(-AUI.MapData.heading)
				AUI_MODE.offsetX = AUI.MapData.mapContainerSize * AUI.MapData.playerX
				AUI_MODE.offsetY = AUI.MapData.mapContainerSize * AUI.MapData.playerY
			else
				AUI_MODE.cos = 0
				AUI_MODE.sin = 0
				AUI_MODE.offsetX = 0
				AUI_MODE.offsetY = 0
			end
		else
			PinController.container:ClearAnchors()
			PinController.container:SetAnchor(TOPLEFT, AUI_MapContainer, TOPLEFT, 0, 0)
			PinTypeManager.UpdateLocationOfPinWithIndex = OriginalUpdateLocation
		end
	end,
	GetDimensions = function(self)
		return AUI_MapContainer:GetDimensions()
	end,
	UpdateLocationOfPinWithIndex = function(self, pinIndex)
		local x, y = self.zoneCache:GetLocal(self.nodeId[pinIndex])
		x = x * PinController.MAP_WIDTH - AUI_MODE.offsetX
		y = y * PinController.MAP_WIDTH - AUI_MODE.offsetY
		local rotatedX = AUI_MODE.cos * x - AUI_MODE.sin * y
		local rotatedY = AUI_MODE.sin * x + AUI_MODE.cos * y
		self:SetPinInsets(pinIndex, rotatedX, rotatedY)
	end,
}
