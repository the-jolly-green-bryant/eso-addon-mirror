-- SatuveXboxUI Resource Navigator
-- Manual navigation only: target selection, route, HUD and minimap pins.

BUI.ResourceNavigator = BUI.ResourceNavigator or {}
local Nav = BUI.ResourceNavigator
local Data = BUI.ResourceData

local UPDATE_NAME = "SatuveXboxUI_ResourceNavigator_Fast"
local EVENT_NAME = "SatuveXboxUI_ResourceNavigator"
local TARGET_PIN_NAME = "SatuveXboxUI_RESOURCE_TARGET_PIN"
local ROUTE_PIN_NAME = "SatuveXboxUI_RESOURCE_ROUTE_PIN"
local TWO_PI = math.pi * 2
local GRID_SIZE = .025
local DEFAULT_MAP_METERS = 10000
local LEARN_MERGE_RADIUS = .0015
local MAX_ROUTE_CANDIDATES = 80

Nav.Target = nil
Nav.Route = {}
Nav.RouteMapId = nil
Nav.GridByMap = {}
Nav.Runtime = {}
Nav.LearnedRevision = 0
Nav.CurrentArrowAngle = 0
Nav.LastVisualTime = 0
Nav.LastMapId = nil
Nav.LastPosition = nil
Nav.PendingInteract = nil
Nav.Initialized = false

Nav.Defaults = {
	ResourceNavigatorEnabled = false,
	ResourceUseHarvestMap = true,
	ResourceFilters = {ore=true, wood=false, clothing=false, alchemy=true, runes=true},
	ResourceNavigationMode = "Nearest Node",
	ResourceShowArrow = true,
	ResourceShowDistance = true,
	ResourceShowTargetOnMap = true,
	ResourceShowRouteNodes = true,
	ResourceAutoSkipRadius = 12,
	ResourceNodeCooldown = 420,
	ResourceRouteLength = 7,
	ResourceDebug = false,
	ResourceNavigatorNodes = {},
	ResourceNavigatorMapScales = {},
}
BUI:JoinTables(BUI.Defaults, Nav.Defaults)

local categoryFilterKeys = {
	ORE="ore", WOOD="wood", CLOTHING="clothing", ALCHEMY="alchemy", RUNES="runes",
}

local function Now()
	return GetTimeStamp and GetTimeStamp() or 0
end

local function Milliseconds()
	return GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or GetGameTimeMilliseconds()
end

local function NormalizeAngle(angle)
	while angle > math.pi do angle = angle - TWO_PI end
	while angle < -math.pi do angle = angle + TWO_PI end
	return angle
end

local function Clamp(value, minimum, maximum)
	if value < minimum then return minimum end
	if value > maximum then return maximum end
	return value
end

local function Debug(message)
	if not BUI.Vars or not BUI.Vars.ResourceDebug then return end
	local text = "[SatuveXboxUI ResourceNav] " .. tostring(message)
	if bui_pl then bui_pl(text) elseif d then d(text) end
end

local function NodeId(mapId, category, x, y)
	return string.format("learned:%d:%s:%d:%d", tonumber(mapId) or 0, category or "?", math.floor(x * 100000 + .5), math.floor(y * 100000 + .5))
end

local function Distance2D(ax, ay, bx, by)
	local dx, dy = ax - bx, ay - by
	return math.sqrt(dx * dx + dy * dy)
end

local function CategoryEnabled(category)
	local filters = BUI.Vars and BUI.Vars.ResourceFilters
	local key = categoryFilterKeys[category]
	return filters and key and filters[key] == true
end

local function EnsureSavedTables()
	BUI.Vars.ResourceFilters = BUI.Vars.ResourceFilters or {ore=true, wood=false, clothing=false, alchemy=true, runes=true}
	local filterDefaults = {ore=true, wood=false, clothing=false, alchemy=true, runes=true}
	for key, value in pairs(filterDefaults) do
		if BUI.Vars.ResourceFilters[key] == nil then BUI.Vars.ResourceFilters[key] = value end
	end
	BUI.Vars.ResourceNavigatorNodes = BUI.Vars.ResourceNavigatorNodes or {}
	BUI.Vars.ResourceNavigatorMapScales = BUI.Vars.ResourceNavigatorMapScales or {}
end

function Nav:GetMapScale(mapId)
	EnsureSavedTables()
	return tonumber(BUI.Vars.ResourceNavigatorMapScales[mapId] or BUI.Vars.ResourceNavigatorMapScales[tostring(mapId)]) or DEFAULT_MAP_METERS
end

function Nav:CalibrateMapScale(position)
	local previous = self.LastPosition
	if not previous or previous.mapId ~= position.mapId then self.LastPosition = position return end
	if not previous.worldZoneId or previous.worldZoneId ~= position.worldZoneId then self.LastPosition = position return end
	local mapDelta = Distance2D(previous.x, previous.y, position.x, position.y)
	local worldDelta = Distance2D(previous.worldX or 0, previous.worldZ or 0, position.worldX or 0, position.worldZ or 0) / 100
	if mapDelta < .00005 or worldDelta < 2 then return end
	self.LastPosition = position
	local measured = worldDelta / mapDelta
	if measured < 200 or measured > 100000 then return end
	local old = tonumber(BUI.Vars.ResourceNavigatorMapScales[position.mapId])
	BUI.Vars.ResourceNavigatorMapScales[position.mapId] = old and (old * .85 + measured * .15) or measured
end

function Nav:GetPlayerPosition()
	if not GetCurrentMapId or not GetMapPlayerPosition then return nil end
	local mapId = tonumber(GetCurrentMapId())
	local x, y, heading, shown = GetMapPlayerPosition("player")
	if not mapId or mapId <= 0 or not x or not y or shown == false then return nil end
	local worldZoneId, worldX, worldY, worldZ
	if GetUnitWorldPosition then worldZoneId, worldX, worldY, worldZ = GetUnitWorldPosition("player") end
	local position = {
		mapId=mapId, x=x, y=y, heading=heading,
		worldZoneId=worldZoneId, worldX=worldX, worldY=worldY, worldZ=worldZ,
	}
	self:CalibrateMapScale(position)
	return position
end

function Nav:GetNodeDistance(position, node)
	if position.worldZoneId and node.worldZoneId and position.worldZoneId == node.worldZoneId and
		position.worldX and position.worldZ and node.worldX and node.worldZ then
		return Distance2D(position.worldX, position.worldZ, node.worldX, node.worldZ) / 100, false
	end
	return Distance2D(position.x, position.y, node.x, node.y) * self:GetMapScale(position.mapId), true
end

-- Read-only state for a possible later external controller script.  It exposes
-- navigation intent without adding movement, key injection or gathering logic.
function Nav:GetNavigationState()
	local position = self:GetPlayerPosition()
	local distance, approximate
	if position and self.Target and position.mapId == self.Target.mapId then
		distance, approximate = self:GetNodeDistance(position, self.Target)
	end
	return {
		enabled = BUI.Vars.ResourceNavigatorEnabled == true,
		mapId = position and position.mapId or self.RouteMapId,
		player = position,
		target = self.Target,
		route = self.Route,
		distance = distance,
		approximateDistance = approximate,
		relativeDirection = self.CurrentArrowAngle,
	}
end

function Nav:GetAllNodes(mapId)
	local learned = BUI.Vars.ResourceNavigatorNodes[mapId] or BUI.Vars.ResourceNavigatorNodes[tostring(mapId)] or {}
	local nodes = Data and Data.GetNodes and Data.GetNodes(mapId) or {}
	for index, node in ipairs(learned) do
		if type(node) == "table" and node.x and node.y and Data.NormalizeCategory(node.type) then
			node.mapId = tonumber(mapId)
			node.type = Data.NormalizeCategory(node.type)
			node.id = node.id or NodeId(mapId, node.type, node.x, node.y)
			node.source = "learned"
			nodes[#nodes + 1] = node
		end
	end
	return nodes
end

function Nav:BuildSpatialGrid(mapId)
	local datasetRevision = Data and Data.GetRevision and Data.GetRevision() or 0
	local signature = tostring(datasetRevision) .. ":" .. tostring(self.LearnedRevision)
	local cached = self.GridByMap[mapId]
	if cached and cached.signature == signature then return cached end
	local grid = {signature=signature, buckets={}, count=0}
	for _, node in ipairs(self:GetAllNodes(mapId)) do
		local gx, gy = math.floor(node.x / GRID_SIZE), math.floor(node.y / GRID_SIZE)
		local key = gx .. ":" .. gy
		grid.buckets[key] = grid.buckets[key] or {}
		grid.buckets[key][#grid.buckets[key] + 1] = node
		grid.count = grid.count + 1
	end
	self.GridByMap[mapId] = grid
	return grid
end

function Nav:GetNearbyNodes(position)
	local grid = self:BuildSpatialGrid(position.mapId)
	if grid.count == 0 then return {} end
	local result, seen = {}, {}
	local centerX, centerY = math.floor(position.x / GRID_SIZE), math.floor(position.y / GRID_SIZE)
	for radius = 0, 40 do
		for gx = centerX - radius, centerX + radius do
			for gy = centerY - radius, centerY + radius do
				if radius == 0 or gx == centerX - radius or gx == centerX + radius or gy == centerY - radius or gy == centerY + radius then
					for _, node in ipairs(grid.buckets[gx .. ":" .. gy] or {}) do
						if not seen[node.id] then seen[node.id] = true result[#result + 1] = node end
					end
				end
			end
		end
		if #result >= MAX_ROUTE_CANDIDATES and radius >= 2 then break end
	end
	return result
end

function Nav:GetCandidateNodes(position)
	local candidates, now = {}, Now()
	for _, node in ipairs(self:GetNearbyNodes(position)) do
		local runtime = self.Runtime[node.id] or {}
		local ignoredUntil = math.max(tonumber(node.ignoredUntil) or 0, tonumber(runtime.ignoredUntil) or 0)
		if node.mapId == position.mapId and CategoryEnabled(node.type) and ignoredUntil <= now then
			node._distance, node._approximate = self:GetNodeDistance(position, node)
			candidates[#candidates + 1] = node
		end
	end
	return candidates
end

function Nav:CalculateNodeScore(position, node)
	local distance = node._distance or self:GetNodeDistance(position, node)
	local runtime, now = self.Runtime[node.id] or {}, Now()
	local lastVisited = math.max(tonumber(node.lastVisited) or 0, tonumber(runtime.lastVisited) or 0)
	local lastChecked = tonumber(runtime.lastChecked) or 0
	local cooldown = tonumber(BUI.Vars.ResourceNodeCooldown) or 420
	local visitedPenalty = lastVisited > 0 and math.max(0, cooldown - (now - lastVisited)) * 2 or 0
	local checkedPenalty = lastChecked > 0 and math.max(0, 90 - (now - lastChecked)) * 3 or 0
	local dx, dy = node.x - position.x, node.y - position.y
	local bearing = math.atan2(-dx, -dy)
	local heading = GetPlayerCameraHeading and GetPlayerCameraHeading() or position.heading or 0
	local directionPenalty = distance * .12 * (1 - math.cos(NormalizeAngle(bearing - heading)))
	return distance + visitedPenalty + checkedPenalty + directionPenalty
end

function Nav:SelectNextNode(position, excluded)
	local best, bestScore
	for _, node in ipairs(self:GetCandidateNodes(position)) do
		if not excluded or not excluded[node.id] then
			local score = self:CalculateNodeScore(position, node)
			if not bestScore or score < bestScore then best, bestScore = node, score end
		end
	end
	return best
end

function Nav:BuildRoute(position)
	if not position then position = self:GetPlayerPosition() end
	if not position then self:SetTarget(nil, {}) return {} end
	local route, excluded = {}, {}
	local length = BUI.Vars.ResourceNavigationMode == "Farm Route" and Clamp(tonumber(BUI.Vars.ResourceRouteLength) or 7, 5, 10) or 1
	local candidates = self:GetCandidateNodes(position)
	local cursor = {mapId=position.mapId, x=position.x, y=position.y, worldZoneId=position.worldZoneId, worldX=position.worldX, worldZ=position.worldZ}
	for routeIndex = 1, length do
		local best, bestScore
		for _, node in ipairs(candidates) do
			if not excluded[node.id] then
				node._distance = self:GetNodeDistance(cursor, node)
				local score = self:CalculateNodeScore(cursor, node)
				if not bestScore or score < bestScore then best, bestScore = node, score end
			end
		end
		if not best then break end
		route[#route + 1] = best
		excluded[best.id] = true
		cursor = {mapId=position.mapId, x=best.x, y=best.y, worldZoneId=best.worldZoneId, worldX=best.worldX, worldZ=best.worldZ}
	end
	self:SetTarget(route[1], route)
	self.TargetBestDistance = route[1] and self:GetNodeDistance(position, route[1]) or nil
	self.LastDeviationCheck = Milliseconds()
	return route
end

function Nav:SetTarget(target, route)
	local oldId = self.Target and self.Target.id
	self.Target = target
	self.Route = route or (target and {target} or {})
	self.RouteMapId = target and target.mapId or nil
	if oldId ~= (target and target.id) then
		if target then
			Debug(string.format("Map %s, target %s at %.4f / %.4f, route nodes %d", tostring(target.mapId), target.type, target.x, target.y, #self.Route))
		else
			Debug("No usable target on the current map")
		end
	end
	self:RefreshPins()
	self:UpdateHUD(true)
end

function Nav:MarkNodeVisited(node, gathered)
	if not node then return end
	local now = Now()
	self.Runtime[node.id] = self.Runtime[node.id] or {}
	self.Runtime[node.id].lastVisited = now
	self.Runtime[node.id].lastChecked = now
	self.Runtime[node.id].ignoredUntil = now + (tonumber(BUI.Vars.ResourceNodeCooldown) or 420)
	if node.source == "learned" then
		node.lastVisited = now
		node.ignoredUntil = self.Runtime[node.id].ignoredUntil
		if gathered then node.lastGathered = now end
	end
	Debug((gathered and "Gathered " or "Reached ") .. tostring(node.type) .. "; choosing next target")
	self:BuildRoute(self:GetPlayerPosition())
end

function Nav:LearnNode(category, x, y, mapId, worldPosition)
	category = Data and Data.NormalizeCategory(category)
	mapId = tonumber(mapId)
	if not category or not mapId or not x or not y then return nil end
	EnsureSavedTables()
	local list = BUI.Vars.ResourceNavigatorNodes[mapId]
	if type(list) ~= "table" then list = {} BUI.Vars.ResourceNavigatorNodes[mapId] = list end
	local nearest, nearestDistance
	for _, node in ipairs(list) do
		if Data.NormalizeCategory(node.type) == category then
			local distance = Distance2D(x, y, tonumber(node.x) or 0, tonumber(node.y) or 0)
			if distance <= LEARN_MERGE_RADIUS and (not nearestDistance or distance < nearestDistance) then nearest, nearestDistance = node, distance end
		end
	end
	local node = nearest
	if node then
		node.x, node.y = (node.x * 3 + x) / 4, (node.y * 3 + y) / 4
		node.lastSeen = Now()
		node.learnCount = (tonumber(node.learnCount) or 1) + 1
	else
		node = {mapId=mapId, x=x, y=y, type=category, firstSeen=Now(), lastSeen=Now(), learnCount=1, source="learned"}
		node.id = NodeId(mapId, category, x, y)
		list[#list + 1] = node
	end
	if worldPosition then
		node.worldZoneId, node.worldX, node.worldY, node.worldZ = worldPosition.worldZoneId, worldPosition.worldX, worldPosition.worldY, worldPosition.worldZ
	end
	self.LearnedRevision = self.LearnedRevision + 1
	self.GridByMap[mapId] = nil
	Debug(string.format("Learned %s at %.4f / %.4f", category, x, y))
	return node
end

function Nav:ClassifyItemLink(itemLink)
	if not itemLink or itemLink == "" then return nil end
	local itemType = GetItemLinkItemType and GetItemLinkItemType(itemLink)
	if itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then return "ORE" end
	if itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL then return "WOOD" end
	if itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL then return "CLOTHING" end
	if itemType == ITEMTYPE_REAGENT then return "ALCHEMY" end
	if itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY then return "RUNES" end
	local craftingType = GetItemLinkCraftingSkillType and GetItemLinkCraftingSkillType(itemLink)
	if craftingType == CRAFTING_TYPE_BLACKSMITHING or craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then return "ORE" end
	if craftingType == CRAFTING_TYPE_WOODWORKING then return "WOOD" end
	if craftingType == CRAFTING_TYPE_CLOTHIER then return "CLOTHING" end
	if craftingType == CRAFTING_TYPE_ALCHEMY then return "ALCHEMY" end
	if craftingType == CRAFTING_TYPE_ENCHANTING or (IsItemLinkEnchantingRune and IsItemLinkEnchantingRune(itemLink)) then return "RUNES" end
	return nil
end

function Nav:LearnAtPlayer(category)
	local position = self:GetPlayerPosition()
	if not position then return end
	local targetBeforeLearning = self.Target
	local learned = self:LearnNode(category, position.x, position.y, position.mapId, position)
	if learned and targetBeforeLearning and Distance2D(learned.x, learned.y, targetBeforeLearning.x, targetBeforeLearning.y) <= LEARN_MERGE_RADIUS * 3 then
		self:MarkNodeVisited(targetBeforeLearning, true)
	elseif learned and BUI.Vars.ResourceNavigatorEnabled then
		self:BuildRoute(position)
	end
end

function Nav:OnLootUpdated()
	if not GetNumLootItems or not GetLootItemInfo or not GetLootItemLink then return end
	local learned = {}
	for index = 1, GetNumLootItems() do
		local lootId = GetLootItemInfo(index)
		local link = lootId and GetLootItemLink(lootId, LINK_STYLE_DEFAULT)
		local category = self:ClassifyItemLink(link)
		if category and not learned[category] then learned[category] = true self:LearnAtPlayer(category) end
	end
end

function Nav:CaptureInteractable()
	if not GetGameCameraInteractableActionInfo then return end
	local action, name, blocked, owned, additionalInfo, contextualInfo, contextualLink = GetGameCameraInteractableActionInfo()
	local category = self:ClassifyItemLink(contextualLink)
	if category then self.PendingInteract = {category=category, time=Milliseconds()} end
end

function Nav:OnInventorySlotUpdate(bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
	if not stackCountChange or stackCountChange <= 0 or not GetItemLink then return end
	local category = self:ClassifyItemLink(GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT))
	if not category then return end
	local pending = self.PendingInteract
	local recentInteract = pending and Milliseconds() - pending.time < 5000
	if (IsLooting and IsLooting()) or (recentInteract and pending.category == category) then
		self:LearnAtPlayer(category)
		self.PendingInteract = nil
	end
end

function Nav:UpdateDirection(position)
	if not self.Target or not position then return nil end
	local dx, dy = self.Target.x - position.x, self.Target.y - position.y
	local bearing = math.atan2(-dx, -dy)
	local heading = GetPlayerCameraHeading and GetPlayerCameraHeading() or position.heading or 0
	local targetAngle = NormalizeAngle(bearing - heading)
	local now = Milliseconds()
	local elapsed = self.LastVisualTime > 0 and math.min(100, now - self.LastVisualTime) or 40
	self.LastVisualTime = now
	local alpha = 1 - math.exp(-elapsed / 110)
	self.CurrentArrowAngle = NormalizeAngle(self.CurrentArrowAngle + NormalizeAngle(targetAngle - self.CurrentArrowAngle) * alpha)
	return self.CurrentArrowAngle
end

function Nav:UpdateHUD(force)
	if not self.HUD then return end
	local enabled = BUI.Vars.ResourceNavigatorEnabled and self.Target ~= nil
	local mapScene = BUI.MiniMap and BUI.MiniMap.MapSceneIsShowing
	local combatHidden = BUI.MiniMap and BUI.MiniMap.CombatHidden
	if not enabled or mapScene or combatHidden then self.HUD:SetHidden(true) return end
	local position = self:GetPlayerPosition()
	if not position or position.mapId ~= self.Target.mapId then self.HUD:SetHidden(true) return end
	local distance, approximate = self:GetNodeDistance(position, self.Target)
	local angle = self:UpdateDirection(position)
	self.HUD:SetHidden(false)
	self.HUD.arrow:SetHidden(not BUI.Vars.ResourceShowArrow)
	if angle then self.HUD.arrow:SetTextureRotation(angle, .5, .5) end
	self.HUD.distance:SetHidden(not BUI.Vars.ResourceShowDistance)
	self.HUD.distance:SetText((approximate and "~" or "") .. tostring(math.floor(distance + .5)) .. " m")
	self.HUD.kind:SetText((Data.CategoryNames and Data.CategoryNames[self.Target.type]) or self.Target.type)
	if distance <= (tonumber(BUI.Vars.ResourceAutoSkipRadius) or 12) then
		self:MarkNodeVisited(self.Target, false)
		return
	end
	-- Route calculation stays out of the 40 ms visual path.  Only a coarse
	-- two-second check requests a rebuild after a clear departure from target.
	self.TargetBestDistance = math.min(tonumber(self.TargetBestDistance) or distance, distance)
	local now = Milliseconds()
	if BUI.Vars.ResourceNavigationMode == "Farm Route" and now - (self.LastDeviationCheck or 0) >= 2000 then
		self.LastDeviationCheck = now
		if distance > self.TargetBestDistance + 150 then self:BuildRoute(position) end
	end
end

function Nav:CreateHUD()
	local hud = BUI.UI.Control("BUI_ResourceNavigatorHUD", GuiRoot, {240, 126}, {TOP,TOP,0,145}, true)
	hud:SetDrawTier(DT_HIGH)
	hud.backdrop = BUI.UI.Backdrop("$(parent)_Backdrop", hud, "inherit", {TOPLEFT,TOPLEFT,0,0}, {0,0,0,.42}, {.72,.68,.25,.7})
	hud.arrow = BUI.UI.Texture("$(parent)_Arrow", hud, {62,62}, {TOP,TOP,0,4}, "/SatuveXboxUI/textures/arrow.dds")
	hud.arrow:SetColor(1,.86,.16,1)
	hud.distance = BUI.UI.Label("$(parent)_Distance", hud, {230,31}, {TOP,TOP,0,64}, BUI.UI.Font("esobold",25,true), {1,1,1,1}, {1,1}, "")
	hud.kind = BUI.UI.Label("$(parent)_Kind", hud, {230,25}, {TOP,TOP,0,96}, BUI.UI.Font("standard",19,true), {.95,.88,.48,1}, {1,1}, "")
	self.HUD = hud
end

function Nav:RegisterPins()
	local manager = ZO_WorldMap_GetPinManager and ZO_WorldMap_GetPinManager()
	if not manager or not manager.AddCustomPin then return false end
	self.PinManager = manager
	if not _G[TARGET_PIN_NAME] then
		manager:AddCustomPin(TARGET_PIN_NAME, function(pinManager)
			local node = Nav.Target
			if node and BUI.Vars.ResourceNavigatorEnabled and BUI.Vars.ResourceShowTargetOnMap and GetCurrentMapId() == Nav.RouteMapId then
				pinManager:CreatePin(_G[TARGET_PIN_NAME], node.id, node.x, node.y)
			end
		end, nil, {level=60, size=52, texture="/SatuveXboxUI/textures/marker.dds"})
	end
	if not _G[ROUTE_PIN_NAME] then
		manager:AddCustomPin(ROUTE_PIN_NAME, function(pinManager)
			if BUI.Vars.ResourceNavigatorEnabled and BUI.Vars.ResourceShowRouteNodes and GetCurrentMapId() == Nav.RouteMapId then
				for index = 2, math.min(#Nav.Route, 6) do
					local node = Nav.Route[index]
					pinManager:CreatePin(_G[ROUTE_PIN_NAME], node.id, node.x, node.y)
				end
			end
		end, nil, {level=55, size=28, texture="/esoui/art/compass/quest_icon_assisted.dds"})
	end
	manager:SetCustomPinEnabled(_G[TARGET_PIN_NAME], true)
	manager:SetCustomPinEnabled(_G[ROUTE_PIN_NAME], true)
	return true
end

function Nav:RefreshPins()
	if not self.PinManager and not self:RegisterPins() then return end
	if _G[TARGET_PIN_NAME] then self.PinManager:RefreshCustomPins(_G[TARGET_PIN_NAME]) end
	if _G[ROUTE_PIN_NAME] then self.PinManager:RefreshCustomPins(_G[ROUTE_PIN_NAME]) end
end

function Nav:OnZoneChanged(reason)
	if not BUI.Vars.ResourceNavigatorEnabled then self:SetTarget(nil, {}) return end
	if BUI.MiniMap and BUI.MiniMap.MapSceneIsShowing then self:RefreshPins() return end
	local position = self:GetPlayerPosition()
	if not position then
		BUI.CallLater("SatuveResourceNavigator_Context", 700, function() Nav:OnZoneChanged("delayed") end)
		return
	end
	local changed = self.LastMapId ~= position.mapId
	self.LastMapId = position.mapId
	if changed then self.Target, self.Route, self.RouteMapId = nil, {}, nil end
	self:BuildRoute(position)
	Debug("Map context " .. tostring(position.mapId) .. " (" .. tostring(reason or "refresh") .. ")")
end

function Nav:OnSettingsChanged(rebuild)
	if not BUI.Vars.ResourceNavigatorEnabled then
		EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
		self:SetTarget(nil, {})
		return
	end
	EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 40, function() Nav:UpdateHUD() end)
	if rebuild ~= false then self:OnZoneChanged("settings") else self:UpdateHUD(true) self:RefreshPins() end
end

function Nav:PrintStatus()
	local position = self:GetPlayerPosition()
	local harvestAdapter = BUI.ResourceHarvestMap
	local providerError = BUI.ResourceData and BUI.ResourceData.ProviderErrors and BUI.ResourceData.ProviderErrors["HarvestMap Community"]
	local lines = {
		"[SatuveXboxUI ResourceNav] enabled=" .. tostring(BUI.Vars.ResourceNavigatorEnabled),
		"map=" .. tostring(position and position.mapId or "unavailable") .. ", target=" .. tostring(self.Target and self.Target.type or "none"),
		"HarvestMap=" .. tostring(harvestAdapter and harvestAdapter:IsAvailable() or false) .. ", imported nodes=" .. tostring(harvestAdapter and harvestAdapter.LastNodeCount or 0),
	}
	if providerError then lines[#lines + 1] = "provider error=" .. tostring(providerError) end
	for _, line in ipairs(lines) do if bui_pl then bui_pl(line) elseif d then d(line) end end
end

function Nav:Settings_Init()
	local function Rebuild() Nav:OnSettingsChanged(true) end
	local function Visual() Nav:OnSettingsChanged(false) end
	local options = {
		{type="header", name="RESOURCE NAVIGATION"},
		{type="checkbox", name="Enable Resource Navigator", getFunc=function() return BUI.Vars.ResourceNavigatorEnabled end, setFunc=function(v) BUI.Vars.ResourceNavigatorEnabled=v Rebuild() end},
		{type="checkbox", name="Use HarvestMap Community Data", getFunc=function() return BUI.Vars.ResourceUseHarvestMap end, setFunc=function(v) BUI.Vars.ResourceUseHarvestMap=v if BUI.ResourceData then BUI.ResourceData.NotifyProviderChanged() end Nav.GridByMap={} Rebuild() end},
		{type="header", name="Resource Types"},
		{type="checkbox", name="Ore / Blacksmithing", getFunc=function() return BUI.Vars.ResourceFilters.ore end, setFunc=function(v) BUI.Vars.ResourceFilters.ore=v Rebuild() end},
		{type="checkbox", name="Alchemy Plants", getFunc=function() return BUI.Vars.ResourceFilters.alchemy end, setFunc=function(v) BUI.Vars.ResourceFilters.alchemy=v Rebuild() end},
		{type="checkbox", name="Runestones", getFunc=function() return BUI.Vars.ResourceFilters.runes end, setFunc=function(v) BUI.Vars.ResourceFilters.runes=v Rebuild() end},
		{type="checkbox", name="Wood", getFunc=function() return BUI.Vars.ResourceFilters.wood end, setFunc=function(v) BUI.Vars.ResourceFilters.wood=v Rebuild() end},
		{type="checkbox", name="Clothing", getFunc=function() return BUI.Vars.ResourceFilters.clothing end, setFunc=function(v) BUI.Vars.ResourceFilters.clothing=v Rebuild() end},
		{type="dropdown", name="Navigation Mode", choices={"Nearest Node","Farm Route"}, getFunc=function() return BUI.Vars.ResourceNavigationMode end, setFunc=function(v) BUI.Vars.ResourceNavigationMode=v Rebuild() end},
		{type="checkbox", name="Show Navigation Arrow", getFunc=function() return BUI.Vars.ResourceShowArrow end, setFunc=function(v) BUI.Vars.ResourceShowArrow=v Visual() end},
		{type="checkbox", name="Show Distance", getFunc=function() return BUI.Vars.ResourceShowDistance end, setFunc=function(v) BUI.Vars.ResourceShowDistance=v Visual() end},
		{type="checkbox", name="Show Target On Minimap", getFunc=function() return BUI.Vars.ResourceShowTargetOnMap end, setFunc=function(v) BUI.Vars.ResourceShowTargetOnMap=v Visual() end},
		{type="checkbox", name="Show Route Nodes", getFunc=function() return BUI.Vars.ResourceShowRouteNodes end, setFunc=function(v) BUI.Vars.ResourceShowRouteNodes=v Visual() end},
		{type="slider", name="Auto Skip Radius (m)", min=8, max=20, step=1, getFunc=function() return BUI.Vars.ResourceAutoSkipRadius end, setFunc=function(v) BUI.Vars.ResourceAutoSkipRadius=v Visual() end},
		{type="dropdown", name="Node Cooldown", choices={"5 minutes","7 minutes","10 minutes"}, getFunc=function() local s=BUI.Vars.ResourceNodeCooldown return s==300 and "5 minutes" or s==600 and "10 minutes" or "7 minutes" end, setFunc=function(v) BUI.Vars.ResourceNodeCooldown=(v=="5 minutes" and 300 or v=="10 minutes" and 600 or 420) Rebuild() end},
		{type="checkbox", name="Debug Output", getFunc=function() return BUI.Vars.ResourceDebug end, setFunc=function(v) BUI.Vars.ResourceDebug=v end},
	}
	local name = "22.  |t32:32:/esoui/art/icons/poi/poi_crafting_complete.dds|tResource Navigation"
	if BUI.SettingsBridge and BUI.SettingsBridge.AddGroupedSection then
		BUI.SettingsBridge.AddGroupedSection("BUI_BanditUI", {id="ResourceNavigation", name=name, order=22, options=options, controllerSafeSliders=true})
	end
	BUI.Menu.RegisterPanel("BUI_MenuResourceNavigation", {type="panel", name=name})
	BUI.Menu.RegisterOptions("BUI_MenuResourceNavigation", options)
end

function Nav:Initialize()
	if self.Initialized then return end
	self.Initialized = true
	EnsureSavedTables()
	self:CreateHUD()
	self:Settings_Init()
	self:RegisterPins()
	EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_PLAYER_ACTIVATED, function() BUI.CallLater("SatuveResourceNavigator_Activated", 900, function() Nav:OnZoneChanged("player activated") end) end)
	EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_ZONE_CHANGED, function() BUI.CallLater("SatuveResourceNavigator_Zone", 500, function() Nav:OnZoneChanged("zone changed") end) end)
	EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_LOOT_UPDATED, function() Nav:OnLootUpdated() end)
	EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, ...) Nav:OnInventorySlotUpdate(...) end)
	EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_RETICLE_TARGET_CHANGED, function() Nav:CaptureInteractable() end)
	EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_CLIENT_INTERACT_RESULT, function() Nav:CaptureInteractable() end)
	if CALLBACK_MANAGER then CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() Nav:OnZoneChanged("map changed") end) end
	SLASH_COMMANDS["/rnav"] = function() Nav:PrintStatus() end
	self:OnSettingsChanged(true)
end
