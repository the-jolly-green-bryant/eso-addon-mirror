
TrueExplor = TrueExplor or {}

-- settings
TrueExplor.total_units = 48

TrueExplor.defaultSettings = {
	retroactive = false,
	discoveredColor = { 1, 1, 1, 0 }, -- rgba format
	undiscoveredColor = { 1, 1, 1, 1 },
	dontHideMapTypes = {
		--MAPTYPE_SUBZONE, --cities but some dungeons as well
		[MAPTYPE_COSMIC] = true,
		[MAPTYPE_WORLD] = true,
	},
	radiusForMapSize = {
		[768] = 4, --dungeon
		[1280] = 4, --city
		[1536] = 2, --starter island, larger cities
		[2048] = 1, --zones
		[5120] = 0,--96, -- cyrodiil (more than 50 panels will result in too much lag)
	}
}

--internal stuff
TrueExplor.radius = 1
TrueExplor.dataVersion = 1
local UPDATE_DELAY_IN_MS = 500 --num of milliseconds until addon tries to discover current position
-- to prevent the save file from bloating up, i save the discovered flag from multiple units as bits in a large integer.
TrueExplor.unitsPerNumber = 31 --number of units to be saved in one integer
-- eso can't save integers larger than 2^31 (or they'll become floats and i lose the lsb information)
TrueExplor.lastTime = 0

-- GetUniversallyNormalizedMapInfo


function TrueExplor:IsCurrentMapSkipped()
	return self.settings.dontHideMapTypes[GetMapType()]
end

function TrueExplor:RefreshRadius()
	local numTiles = GetMapNumTiles()
	-- might not be loaded yet!
	local tileSize = ZO_WorldMapContainer1:GetTextureFileDimensions()

	if tileSize ~= nil and numTiles ~= nil then
		local mapSize = tileSize * numTiles
		local smallestSize = math.huge
		local r
		for size, radius in pairs(self.settings.radiusForMapSize) do
			if size < smallestSize and size >= mapSize then
				smallestSize = size
				r = radius
			end
		end
		self.tileDisplay:SetRadius(r)
		return
	end
	self.tileDisplay:SetRadius(1)
end

function TrueExplor:MarkForRefresh()
	self.needUpdate = true
	EVENT_MANAGER:RegisterForUpdate("TrueExploration-Delay", 0, self.delay)
end

function TrueExplor:Refresh(skipIfSameData)
	if self:IsCurrentMapSkipped() then
		self.tileDisplay:HideTiles()
		return
	end
	if not (ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded()) then
		self:MarkForRefresh()
		return
	end
	self:RefreshRadius()
	self.needUpdate = false
	local mapId = GetCurrentMapId()
	local discoveryData = self:GetDiscoveryDataForMapId(mapId)
	assert(discoveryData)
	if skipIfSameData and (discoveryData == self.tileDisplay.discoveryData) then
		return
	end
	self.tileDisplay:SetDiscoveryData(discoveryData)
	self.tileDisplay:Refresh()
end
TrueExplor.delay = function() 
	if ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded() then 
		TrueExplor:Refresh()
		EVENT_MANAGER:UnregisterForUpdate("TrueExploration-Delay")
	end
end

function TrueExplor:GetDiscoveryDataForMapId(mapId, empty)
	local discoveryData = self.loadedData[mapId]
	if not discoveryData then
		local data = self.maps[mapId]
		if not data then
			data = self.maps[GetMapTileTexture()]
			self.maps[GetMapTileTexture()] = nil
		end
		if data then
			discoveryData = self.discoveryData:Load(data)
		else
			data = {}
			if empty == nil then empty = not self.settings.retroactive end
			if empty then
				discoveryData = self.discoveryData:Load(data)
			else
				discoveryData = self.discoveryData:PreFill(data, mapId)
			end
		end
		self.maps[mapId] = data
		self.loadedData[mapId] = discoveryData
	end
	return discoveryData
end

function TrueExplor:DiscoverForMapId(tileX, tileY, mapId)
	local discoveryData = self:GetDiscoveryDataForMapId(mapId)
	return discoveryData:Discover(tileX, tileY)
end

function TrueExplor:BuildHierarchy()
	local lastMapId = GetCurrentMapId()
	local newParentMapId
	
	while (MapZoomOut() == SET_MAP_RESULT_MAP_CHANGED) do
		newParentMapId = GetCurrentMapId()
		if lastMapId == newParentMapId then
			break
		end
		self.hierarchy[lastMapId] = newParentMapId
	end
	SetMapToPlayerLocation()
end

function TrueExplor:DiscoverCurrentLocation()
	local originalMapId = GetCurrentMapId()
	SetMapToPlayerLocation()
	
	local mapId = GetCurrentMapId()
	local parentMapId = self.hierarchy[mapId]
	if not parentMapId then
		self:BuildHierarchy()
		parentMapId = self.hierarchy[mapId]
	end
	
	local x, y = GetMapPlayerPosition("player")
	local discoveredTileX = zo_floor(x * TrueExplor.total_units)
	local discoveredTileY = zo_floor(y * TrueExplor.total_units)
	
	local offsetX, offsetY, scaleX, scaleY = GetUniversallyNormalizedMapInfo(mapId)
	
	local globalX = x * scaleX + offsetX
	local globalY = y * scaleY + offsetY
	
	local tileX, tileY
	local wasAnyChanged, wasChanged
	while mapId do
		--d("uncover " .. mapName)
		offsetX, offsetY, scaleX, scaleY = GetUniversallyNormalizedMapInfo(mapId)
		-- get local coords
		x = (globalX - offsetX) / scaleX
		y = (globalY - offsetY) / scaleY
		-- get tile coords
		tileX = zo_floor(x * TrueExplor.total_units)
		tileY = zo_floor(y * TrueExplor.total_units)
		-- set to discovered
		wasChanged = self:DiscoverForMapId(tileX, tileY, mapId)
		if not wasChanged then
			break -- if nothing was discovered on small scale, we don't have to look at larger scale maps
		end
		wasAnyChanged = true
		-- get parent map and repeat
		mapId = self.hierarchy[mapId]
	end
	
	if originalMapId ~= GetCurrentMapId() then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	elseif wasAnyChanged then
		if AUI_MapContainer or WORLD_MAP_FRAGMENT:IsShowing() then
			self.tileDisplay:OnDiscoveryStatusChanged(discoveredTileX, discoveredTileY)
		end
	end
end

function TrueExplor:SetCompletelyDiscoverForCurrentMap(isDiscover)
	if not ZO_WorldMap_IsWorldMapShowing() then
		d("Please open the worldmap.")
		return
	end
	local discoveryData = self:GetDiscoveryDataForMapId(GetCurrentMapId())
	discoveryData:SetCompletelyDiscovered(isDiscover)
	self:Refresh()
end

function TrueExplor:ClearDataForCurrentMap(isEmpty)
	if not ZO_WorldMap_IsWorldMapShowing() then
		d("Please open the worldmap.")
		return
	end
	
	local mapId = GetCurrentMapId()
	self.loadedData[mapId] = nil
	self.maps[mapId] = nil
	self:GetDiscoveryDataForMapId(mapId, not not isEmpty)
	self:Refresh()
end

function TrueExplor:SetDebugEnabled(isEnabled)
	self.isDebugEnabled = isEnabled
	if isEnabled then
		
	end
end

function TrueExplor:IsDebugEnabled(isEnabled)
	return self.isDebugEnabled
end

function TrueExplor:AddCustomDialog(tag, dialog)
	local buttons = dialog.buttons
	dialog.buttons = nil
	dialog.OnShownCallback = function(dialog)
		local g_keybindState = KEYBIND_STRIP:GetTopKeybindStateIndex()
		local g_keybindGroupDesc = {
			{
				alignment = KEYBIND_STRIP_ALIGN_LEFT,
				name = buttons[1].text or buttons[1].name,
				keybind = "DIALOG_PRIMARY",
				order = -500,
				callback = buttons[1].callback,
			},
			{
				alignment = KEYBIND_STRIP_ALIGN_LEFT,
				name = buttons[2].text or buttons[2].name,
				keybind = "DIALOG_NEGATIVE",
				callback = buttons[2].callback,
			}
		}
		KEYBIND_STRIP:AddKeybindButtonGroup(g_keybindGroupDesc, g_keybindState)
	end
	ESO_Dialogs[tag] = dialog
end

function TrueExplor:Initialize()
	-- load save files
	self.isFirstStartUp = false
	if not TE_SavedVars then
		self.isFirstStartUp = true
	end
	self.save = ZO_SavedVars:New("TE_SavedVars", 1, "save", { maps = {} })
	self.maps = self.save.maps
	self.settings = ZO_SavedVars:New("TE_SavedVars", 1, "save", self.defaultSettings)
	
	self.hierarchy = {}
	self.loadedData = {}
	self.isDebugEnabled = false
	-- initialize options menu (see TrueExplorationOptions.lua)
	TrueExplor.menu:Initialize()
	TrueExplor.filterMenu:Initialize()
	--self.settingsMenu:Initialize()
	self.tileDisplay:Initialize(ZO_WorldMapContainer, 0)--self.settings.radius)
	self.tileDisplay:SetColors(self.settings.discoveredColor, self.settings.undiscoveredColor)
	-- add debug chat commands
	if not IsConsoleUI() then
		SLASH_COMMANDS["/tedebug"] = function(s) TrueExplor:SetDebugEnabled(tonumber(s)==1) end
		SLASH_COMMANDS["/discover"] = function() TrueExplor:SetCompletelyDiscoverForCurrentMap(true) end
		SLASH_COMMANDS["/undiscover"] = function() TrueExplor:SetCompletelyDiscoverForCurrentMap(false) end
		SLASH_COMMANDS["/clearmap"] = function() TrueExplor:ClearDataForCurrentMap() end
	end
	--if true then return end
	-- update the MapTile objects, when a new map is displayed
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:Refresh() end)
	
	-- there is a short blending animation, which resets the alpha values for the texture's vertices
	-- so let the worldmap appear instantly instead
	WORLD_MAP_FRAGMENT.Show = ZO_SimpleSceneFragment.Show
	WORLD_MAP_FRAGMENT.Hide = ZO_SimpleSceneFragment.Hide
	-- when the map is opened/closed, the tiles need to be refreshed
	local callback = function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			if AUI_MapContainer then
				self.tileDisplay:SetContainer(ZO_WorldMapContainer)
			end
			self.tileDisplay:Refresh()
		elseif newState == SCENE_HIDING then
			if AUI_MapContainer then
				self.tileDisplay:SetContainer(AUI_MapContainer)
			end
			self:SetDebugEnabled(false)
		end
	end
	local mapscene = SCENE_MANAGER:GetScene("worldMap")
	mapscene:RegisterCallback("StateChange", callback)
	mapscene = SCENE_MANAGER:GetScene("gamepad_worldMap")
	mapscene:RegisterCallback("StateChange", callback)
	
	EVENT_MANAGER:RegisterForUpdate("TrueExploration", UPDATE_DELAY_IN_MS, function()
		if ZO_WorldMap_IsWorldMapShowing() then return end
		
		TrueExplor:DiscoverCurrentLocation()
	end)
	
	CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
		local skipIfSameData = true
		self:Refresh(skipIfSameData)
	end)
	
	-- add zoom function for the tiles. when the map is zoomed into, the tiles need to scale as well
	local oldDimensions = ZO_WorldMapContainer.SetDimensions
	ZO_PreHook(ZO_WorldMapContainer, "SetDimensions", function(container, width, height, ...)
		if self.tileDisplay.container == container then
			self.tileDisplay:UpdateSize(width, height)
		end
	end)
	
	-- add the same scaling code to the minimap
	if AUI_MapContainer then
		ZO_PreHook(AUI_MapContainer, "SetDimensions", function(container, width, height, ...)
			if self.tileDisplay.container == container then
				self.tileDisplay:UpdateSize(width, height)
			end
		end)
	end
	
	if self.isFirstStartUp then
		local lang = self.lang
		self:AddCustomDialog("INIT_EXPLORATION", {
			canQueue = true,
			mustChoose = true,
			gamepadInfo = {dialogType = GAMEPAD_DIALOGS.BASIC},
			title = {text = lang.initTitle}, 
			mainText = {text = lang.initBody},
			buttons = {
				{
					text = lang.empty,
					callback = function(dialog)
						TrueExplor.settings.retroactive = false
						ZO_ClearTable(self.loadedData)
						ZO_ClearTable(self.maps)
						self:Refresh()
					end,
				},
				{
					text = lang.guessExploration,
					callback = function(dialog)
						TrueExplor.settings.retroactive = true
						local nonEmpty = true
						ZO_ClearTable(self.loadedData)
						ZO_ClearTable(self.maps)
						self:Refresh()
					end,
				},
			},
		})
		EVENT_MANAGER:RegisterForEvent("TrueExploration", EVENT_PLAYER_ACTIVATED, function() 
			EVENT_MANAGER:UnregisterForEvent("TrueExploration", EVENT_PLAYER_ACTIVATED) 
			ZO_Dialogs_ShowPlatformDialog("INIT_EXPLORATION", {}) 
		end)
	end
	
end

EVENT_MANAGER:RegisterForEvent("TrueExploration", EVENT_ADD_ON_LOADED, function(_, addon)
	if addon ~= "TrueExploration" then
		return
	end
	TrueExplor:Initialize()
end)