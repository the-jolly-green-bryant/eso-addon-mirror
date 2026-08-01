if not TrueExplor then
	TrueExplor = {}
end
local TrueExplor = _G["TrueExplor"]
local GPS = LibGPS2

-- settings
TrueExplor.radius = {
	[768] = 4, --dungeon
	[1280] = 3, --city
	[1536] = 2, --starter island, larger cities
	[2048] = 1, --zones
	[5120] = 1,--96, -- cyrodiil (more than 50 panels will result in too much lag)
}
TrueExplor.total_units = 48 --needs to be divisible by all radii. number of height/width divisions on the worldmap
TrueExplor.discoveredColor = { 1, 1, 1, 0 } -- rgba format
TrueExplor.undiscoveredColor = { 1, 1, 1, 1 }
TrueExplor.dontHideMapTypes = {
	--MAPTYPE_SUBZONE, --cities but some dungeons as well
	MAPTYPE_COSMIC,
	MAPTYPE_WORLD,
	MAPTYPE_ALLIANCE -- the tamriel map is no longer maptype_world but _alliance...
	-- probably some bug on ZOS' side
}

--internal stuff
TrueExplor.unitsPerTile = 1
TrueExplor.mapTiles = {}
TrueExplor.dataVersion = 1
TrueExplor.delay = 1000 --num of milliseconds until addon tries to discover current position
-- to prevent the save file from bloating up, i save the discovered flag from multiple units as bits in a large integer.
TrueExplor.unitsPerNumber = 31 --number of units to be saved in one integer
-- eso can't save integers larger than 2^31 (or they'll become floats and i lose the lsb information)
TrueExplor.lastTime = 0

local SavedMaps

-- help function to check if a table (array) contains a certain value
function TrueExplor.contains(table, value)
	for key, val in pairs(table) do
		if val == value then
			return key
		end
	end
	return nil
end

-- each MapTile represents the point, where 4 units meet (or less if at the map's edge)
-- self.unit = the Unit at the bottom left corner
-- the other corners have the color of the respective neighbors of self.unit
local MapTile = ZO_Object:Subclass()
function MapTile:New( ... )
	local result = ZO_Object.New(self)
	result:Initialize( ... )
	return result
end

function MapTile:Initialize( index )
	self.index = index -- the number of this tile (tiles are line-wise numbered)
	self.control = CreateControlFromVirtual("TE_Unit"..tostring(index), ZO_WorldMapContainer, "TE_MapTile")

	-- calculate x and y position of this tile
	self.x = zo_mod(index, TrueExplor.total_units + 1)
	self.y = zo_floor(index / (TrueExplor.total_units + 1))
	-- self.unit = the Unit at the bottom left corner of this tile
	-- the most left/bottom tiles don't have a unit associated with
	if self.x < TrueExplor.total_units and self.y < TrueExplor.total_units then
		self.unit = self.y * TrueExplor.total_units + self.x
	end
	-- translate this tile a bit to the righttop as each tile will display a value depending on 4 surrounding units
	self.x = self.x - 0.5
	self.y = self.y - 0.5

	-- add the correct adjacent tiles that change their graphic depending on this tile's unit
	self.left = self
	self.top = self
	self.topleft = self
	
	if self.y > 0 then
		self.top = TrueExplor.mapTiles[index - TrueExplor.total_units - 1]
	end
	if self.x > 0 then
		self.left = TrueExplor.mapTiles[index - 1]
	end
	if self.y > 0 and self.x > 0 then
		self.topleft = TrueExplor.mapTiles[index - TrueExplor.total_units - 2]
	end
	
	self.color = {0, 0, 0, 1}
end

-- sets the layout of this tiles texture
-- sets, position, width, height and the correct parent (needed for minimap - worldmap transition)
function MapTile:SetLayout( width, height, parent )
	self.control:SetAnchor(TOPLEFT, parent, TOPLEFT, self.x * width, self.y * height)
	self.control:SetParent(parent)
	self.control:SetDimensions(width, height)
	-- sets the u/v coordinates of the texture
	self.control:SetTextureCoords(self.x / TrueExplor.total_units,
								 (self.x+1) / TrueExplor.total_units,
								  self.y / TrueExplor.total_units,
								 (self.y+1) / TrueExplor.total_units)
end

-- refreshes this tile's color value depending on the discovered flag
function MapTile:RefreshColor( mapName )
	if not self.unit then
		return
	end
	
	if self:IsDiscovered( mapName ) then
		self.color = TrueExplor.discoveredColor
	else
		self.color = TrueExplor.undiscoveredColor
	end
end

-- returns true if this tile should be displayed as discovered (ie opacity = 0)
function MapTile:IsDiscovered( mapName )
	-- some fancy calculation because different map sizes result in different view radii
	-- the view radius is actually a square, baseUnit is the unit at the center of the square this tile belongs to
	local baseUnit = self.unit - zo_floor(TrueExplor.unitsPerTile / 2) - zo_floor(TrueExplor.unitsPerTile / 2) * TrueExplor.total_units
	for i = 0, (TrueExplor.unitsPerTile - 1) do
		for j = 0, (TrueExplor.unitsPerTile - 1) do
			if TrueExplor.IsDiscovered( mapName, baseUnit + i + j * TrueExplor.total_units ) then
				return true
			end
		end
	end
	return false
	
end

-- sets the color/opacity of the 4 corners of this tile's texture
-- the color is used from the MapTile.color field and should be calculated earlier!
-- (i.e. call RefreshColor before calling SetTileColor)
function MapTile:SetTileColor()
	-- color of this tile
	self.control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT , unpack(self.color) )
	-- color of the tile's neigbors for gradient effect
	self.control:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT , unpack(self.left.color) )
	self.control:SetVertexColors(VERTEX_POINTS_TOPRIGHT , unpack(self.top.color) )
	self.control:SetVertexColors(VERTEX_POINTS_TOPLEFT , unpack(self.topleft.color) )
end

-- set every corner of this tile's texture as undiscovered (needed during the map opening/closing animation)
function MapTile:SetUndiscovered()
	-- color of my tile
	self.control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT , unpack(TrueExplor.undiscoveredColor) )
	-- color of my neigbors for gradient effect
	self.control:SetVertexColors(VERTEX_POINTS_BOTTOMLEFT , unpack(TrueExplor.undiscoveredColor) )
	self.control:SetVertexColors(VERTEX_POINTS_TOPRIGHT , unpack(TrueExplor.undiscoveredColor) )
	self.control:SetVertexColors(VERTEX_POINTS_TOPLEFT , unpack(TrueExplor.undiscoveredColor) )
end

-- set all tiles as hidden (so the entire map becomes visible)
function TrueExplor.HideTiles()
	for _, control in pairs( TrueExplor.mapTiles ) do
		control.control:SetHidden(true)
	end
end

function TrueExplor.RefreshSingleTile(unitX, unitY)
	--TrueExplor.RefreshTiles()
	--if true then return end
	
	-- if this map isn't supposed to be hidden (ie cosmic map )
	if TrueExplor.contains(TrueExplor.dontHideMapTypes, GetMapType()) then
		return
	end
	-- if this map's texture is already loaded, update the tiles
	-- otherwise remember that the tiles have to be updated
	if not ZO_WorldMapContainer1 then return end
	if not ZO_WorldMapContainer1:IsTextureLoaded() then return end
	
	if not TrueExplor.unitsPerTile then return end
	
	
	local baseIndex = unitX + unitY * (TrueExplor.total_units+1)
	local topLeftIndex = baseIndex - zo_floor(TrueExplor.unitsPerTile / 2) - zo_floor(TrueExplor.unitsPerTile / 2) * (TrueExplor.total_units+1)
	
	--d(baseUnit, topLeft)
	
	local mapName = GetMapTileTexture()
	local control, index
	for i = 0, TrueExplor.unitsPerTile+1 do
		for j = 0, TrueExplor.unitsPerTile+1 do
			control = TrueExplor.mapTiles[topLeftIndex + i + j * (TrueExplor.total_units+1)]
			if control then
				control:RefreshColor( mapName )
			end
		end
	end
	for i = 0, TrueExplor.unitsPerTile+1 do
		for j = 0, TrueExplor.unitsPerTile+1 do
			control = TrueExplor.mapTiles[topLeftIndex + i + j * (TrueExplor.total_units+1)]
			if control then
				control:SetTileColor()
				--control.control:SetVertexColors(VERTEX_POINTS_BOTTOMRIGHT , 1,0,0,1 )
			end
			--TrueExplor.mapTiles[topLeft + i + j * (TrueExplor.total_units+1)].
		end
	end
end

-- called when map changes, refreshes data and visuals of all MapTiles
-- the actual update of the MapTiles may be delayed as the current map's texture has to be loaded first.
function TrueExplor.RefreshTiles()
	-- if this map isn't supposed to be hidden (ie cosmic map )
	if TrueExplor.contains(TrueExplor.dontHideMapTypes, GetMapType()) then
		TrueExplor.HideTiles()
		return
	end
	-- if this map's texture is already loaded, update the tiles
	-- otherwise remember that the tiles have to be updated
	if ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded() then
		TrueExplor.UpdateTiles()
	else
		TrueExplor.needUpdate = true
	end
end

-- update all MapTiles' data and visuals
function TrueExplor.UpdateTiles()
	TrueExplor.needUpdate = false
	TrueExplor.unitsPerTile = nil
	local numTiles = GetMapNumTiles()
	local tileSize = ZO_WorldMapContainer1:GetTextureFileDimensions()

	-- calculate the unit per tile / view radius for the current map
	if tileSize ~= nil and numTiles ~= nil then
		local mapSize = tileSize * numTiles
		local smallestSize = math.huge
		for size, radius in pairs( TrueExplor.radius) do
			if size < smallestSize and size >= mapSize then
				smallestSize = size
				TrueExplor.unitsPerTile = radius
			end
		end
	end
	if not TrueExplor.unitsPerTile then
		TrueExplor.unitsPerTile = 1
	end

	-- update the color field of all the map tiles
	local mapName = GetMapTileTexture()
	for _, control in pairs( TrueExplor.mapTiles ) do
		control.control:SetHidden(false)
		control:RefreshColor( mapName )
	end
	-- adopt the color for all MapTile's textures
	for _, control in pairs( TrueExplor.mapTiles ) do
		control:SetTileColor()
	end
end

-- first argument = control, 2nd argument the game time (in milliseconds)
function TrueExplor.OnUpdate( time )
	if TrueExplor.needUpdate then
		if ZO_WorldMapContainer1 and ZO_WorldMapContainer1:IsTextureLoaded() then
			TrueExplor.UpdateTiles()
		else
			return
		end
	end
	
	-- debug mode ((un)discover via mouse clicks
	if ZO_WorldMap_IsWorldMapShowing() then
		if TrueExplor.pressed then
			if TrueExplor.contains(TrueExplor.dontHideMapTypes, GetMapType()) then
				return
			end
			local x, y = GetUIMousePosition()
			local currentOffsetX = ZO_WorldMapContainer:GetLeft()
			local currentOffsetY = ZO_WorldMapContainer:GetTop()
			local parentOffsetX = ZO_WorldMap:GetLeft()
			local parentOffsetY = ZO_WorldMap:GetTop()
			local mouseX, mouseY = GetUIMousePosition()
			local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
			local parentWidth, parentHeight = ZO_WorldMap:GetDimensions()

			x = zo_floor(((x - currentOffsetX) / mapWidth) * TrueExplor.total_units)
			y = zo_floor(((y - currentOffsetY) / mapHeight) * TrueExplor.total_units)
			if x >= 0 and y >= 0 and x < TrueExplor.total_units and y < TrueExplor.total_units then
				if TrueExplor.DiscoverCurrentMapOnly( x, y, TrueExplor.pressed) == (TrueExplor.pressed == 1) then
					if TrueExplor.pressed == 1 then
						d("discover " .. tostring(x) .. ":" .. tostring(y) )
					else
						d("undiscover " .. tostring(x) .. ":" .. tostring(y) )
					end
					--TrueExplor.RefreshTiles()
					TrueExplor.RefreshSingleTile(x, y)
				end
			end
		end
		-- don't do any other updates while the map is open
		-- to many map settings are changed during the update process
		-- there will probably a bunch of bugs when updating while the map is open
		return
	end
	-- real update stuff
	if time - TrueExplor.lastTime < TrueExplor.delay then
		return
	end
	TrueExplor.lastTime = time
	
	TrueExplor.Discover()
end

function TrueExplor.Discover()
	--local startTime = GetGameTimeMilliseconds()
	
	local mapChanged = (SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED)
	local mapName = GetMapTileTexture()
	local map = TrueExplor.hierarchy[mapName]
	if not map then
		--d("build hierachy")
		local measurement = GPS:GetCurrentMapMeasurements()
		if not measurement then
			if mapChanged then
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			end
			return
		end
		
		map = {measurement = measurement}
		TrueExplor.hierarchy[mapName] = map
		
		local lastParentMapName, newParentMapName
		local childMap = map
		while (MapZoomOut() == SET_MAP_RESULT_MAP_CHANGED) do
			newParentMapName = GetMapTileTexture()
			--d("check " .. newParentMapName)
			if lastParentMapName == newParentMapName then break end -- failsave for possible gps bugs
			
			measurement = GPS:GetCurrentMapMeasurements()
			if not measurement then break end
			
			childMap.parent = newParentMapName
			lastParentMapName = newParentMapName
			
			if TrueExplor.hierarchy[newParentMapName] then break end
			childMap = {measurement = measurement}
			TrueExplor.hierarchy[newParentMapName] = childMap
		end
		SetMapToPlayerLocation()
	end
	
	--local buildTime = GetGameTimeMilliseconds()
	
	local globalX, globalY = GPS:LocalToGlobal(GetMapPlayerPosition("player"))
	if not globalX then -- aurbis map
		return
	end
	
	local x, y
	local tileX, tileY, firstTileX, firstTileY
	local measurement
	local wasAnyChanged, wasChanged
	while map do
		--d("uncover " .. mapName)
		measurement = map.measurement
		-- get local coords
		x = (globalX - measurement.offsetX) / measurement.scaleX
		y = (globalY - measurement.offsetY) / measurement.scaleY
		-- get tile coords
		tileX = zo_floor(x * TrueExplor.total_units)
		tileY = zo_floor(y * TrueExplor.total_units)
		firstTileX = firstTileX or tileX
		firstTileY = firstTileY or tileY
		-- set to discovered
		wasChanged = TrueExplor.DiscoverTileOnMap(tileX, tileY, mapName)
		if not wasChanged then
			break -- if nothing was discovered on small scale, we don't have to look at larger scale maps
		end
		wasAnyChanged = true
		-- get parent map and repeat
		mapName = map.parent
		map = TrueExplor.hierarchy[mapName]
	end
	
	--local discoverTime = GetGameTimeMilliseconds()
	
	if mapChanged then
		--d("map change triggered")
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	elseif wasAnyChanged then
		if AUI_MapContainer or WORLD_MAP_FRAGMENT:IsShowing() then
			--d("refresh tiles")
			TrueExplor.RefreshSingleTile(firstTileX, firstTileY)
		end
	end
	
	--local refreshTime = GetGameTimeMilliseconds()
	--d("Time", buildTime - startTime, discoverTime - buildTime, refreshTime - discoverTime)
end

function TrueExplor.DiscoverTileOnMap(x, y, mapName, undiscover)
	
	if not SavedMaps[mapName] then
		SavedMaps[mapName] = {}
	end
	
	local unitId = (y * TrueExplor.total_units + x)
	local result = false
	
	if undiscover then
		local tempId
		for i=0,(TrueExplor.unitsPerTile - 1) do
			for j=0,(TrueExplor.unitsPerTile -1) do
				tempId = unitId + i + j * TrueExplor.total_units
				if TrueExplor.IsDiscovered( mapName, tempId ) then
					result = true
					y = zo_floor(tempId / TrueExplor.unitsPerNumber)
					x = zo_mod(tempId, TrueExplor.unitsPerNumber)
					SavedMaps[mapName][y] = (SavedMaps[mapName][y] or 0) - (2^x)
				end
			end
		end
	else
		result = TrueExplor.IsDiscovered( mapName, unitId )
		if not result then
			y = zo_floor(unitId / TrueExplor.unitsPerNumber)
			x = zo_mod(unitId, TrueExplor.unitsPerNumber)
			SavedMaps[mapName][y] = (SavedMaps[mapName][y] or 0) + (2^x)
		end
	end
	return (not result)
end

function TrueExplor.DiscoverCurrentMapOnly( tileX, tileY, button)
	local mapName = GetMapTileTexture() --multiple maps can have the same mapname, so use the map's texture instead
	
	return TrueExplor.DiscoverTileOnMap(tileX, tileY, mapName, button == 2)
end

function TrueExplor.IsDiscovered( mapName, unit )
	if not SavedMaps[mapName] then
		return false
	end
	if SavedMaps[mapName].discovered then
		return true
	end
	local y = zo_floor(unit / TrueExplor.unitsPerNumber)
	local x = zo_mod(unit, TrueExplor.unitsPerNumber)
	local save = SavedMaps[mapName][y]
	if save then
		return ((save / (2^x)) % 2 >= 1)
	end
	return false
end

-- debug functions:
local oldMouseDown = ZO_WorldMap_MouseDown
ZO_WorldMap_MouseDown = function(button, ctrl, alt, shift)
	if TrueExplor.debug then
		TrueExplor.pressed = button
		return
	else
		oldMouseDown(button, ctrl, alt, shift)
	end
end

local oldMouseUp = ZO_WorldMap_MouseUp
ZO_WorldMap_MouseUp = function(mapControl, mouseButton, upInside)
	TrueExplor.pressed = nil
	if not TrueExplor.debug then --prevent zoom in/out while debug
		oldMouseUp(mapControl, mouseButton, upInside)
	end
end

function TrueExplor.Debug(argument)
	argument = tonumber(argument)
	if argument == 1 then
		d("TrueExploration Debug-mode enabled.")
		TrueExplor.debug = true
	elseif argument == 0 then
		d("TrueExploration Debug-mode disabled.")
		TrueExplor.debug = nil
	else
		d("TrueExploration Debug-mode")
		d("/tedebug 1 - activate debug mode")
		d("/tedebug 0 - deactivate debug mode")
		d("Open the map and hold left mouse button to discover areas under your cursor.")
		d("(right mouse button to undiscover)")
	end
end

function TrueExplor.DiscoverAll()
	if not ZO_WorldMap_IsWorldMapShowing() then
		d("Please open the worldmap.")
		return
	end
	local mapName = GetMapTileTexture()
	if not SavedMaps[mapName] then
		SavedMaps[mapName] = {}
	end
	d("set this map to discovered")
	SavedMaps[mapName].discovered = true
	TrueExplor.RefreshTiles()
end

function TrueExplor.ClearMap()
	if not ZO_WorldMap_IsWorldMapShowing() then
		d("Please open the worldmap.")
		return
	end
	local mapName = GetMapTileTexture()
	d("cleared data for this map")
	SavedMaps[mapName] = {}
	TrueExplor.RefreshTiles()
end

function TrueExplor.UndiscoverAll()
	if not ZO_WorldMap_IsWorldMapShowing() then
		d("Please open the worldmap.")
		return
	end
	local mapName = GetMapTileTexture()
	if SavedMaps[mapName] then
		if SavedMaps[mapName].discovered then
			d("reset discovered mode")
			d("call /clearmap to remove data for this map completely.")
			SavedMaps[mapName].discovered = nil
			TrueExplor.RefreshTiles()
			return
		end
	end
end

function TrueExplor.UpdateVer1()
	local newData, smallData
	local y
	for map, data in pairs(SavedMaps) do
		 -- change size to 48x48 (cut 0 and 49)
		smallData = {}
		for i, found in pairs(data) do
			if type(i) == "number"then
				if found then
					y = zo_floor(i / 50)
					x = zo_mod(i, 50)
					if x > 0 and x < 49 and y > 0 and y < 49 then
						x = x - 1
						y = y - 1
						smallData[y * 48 + x] = true
					end
				end
			else
				smallData[i] = found
			end
		end
		--convert to int saving system
		newData = {}
		for i=0,(zo_ceil(48*48/TrueExplor.unitsPerNumber)) do
			newData[i] = 0
		end
		for i, found in pairs(smallData) do
			if found then
			if type(i) == "number"then
			y = zo_floor(i / TrueExplor.unitsPerNumber)
			x = zo_mod(i, TrueExplor.unitsPerNumber)
			newData[y] = newData[y] + ( 2^x ) --set i-th bit to 1
			end
			end
		end
		SavedMaps[map] = newData
	end
	
	TrueExplor.save.dataVersion = 1
end

function TrueExplor.UpdateDataVersion()
	if not TrueExplor.save.dataVersion then
		TrueExplor.UpdateVer1()
	end
	--[[
	if TrueExplor.save.dataVersion < 2 then
		TrueExplor.UpdateVer2()
	end
	etc
	--]]
end

function TrueExplor.OnAddonLoaded( _, addon )
	if addon ~= "TrueExploration" then
		return
	end
	
	-- load save files
	TrueExplor.save = ZO_SavedVars:New("TE_SavedVars", 1, "save", { maps = {} })
	SavedMaps = TrueExplor.save.maps
	
	TrueExplor.settings = ZO_SavedVars:New("TE_SavedVars", 1, "save", {
		radius = TrueExplor.radius,
		units = TrueExplor.total_units,
		discoveredColor = TrueExplor.discoveredColor,
		undiscoveredColor = TrueExplor.undiscoveredColor,
		dontHideMapTypes = TrueExplor.dontHideMapTypes,
	})

	-- get current settings
	TrueExplor.radius = TrueExplor.settings.radius
	TrueExplor.total_units =  TrueExplor.settings.units
	TrueExplor.discoveredColor =  TrueExplor.settings.discoveredColor
	TrueExplor.undiscoveredColor =  TrueExplor.settings.undiscoveredColor
	TrueExplor.dontHideMapTypes =  TrueExplor.settings.dontHideMapTypes
	TrueExplor.hierarchy = {}
	-- initialize options menu (see TrueExplorationOptions.lua)
	TrueExplor.setupOptions()
	-- add debug chat commands
	SLASH_COMMANDS["/tedebug"] = TrueExplor.Debug
	SLASH_COMMANDS["/discover"] = TrueExplor.DiscoverAll
	SLASH_COMMANDS["/undiscover"] = TrueExplor.UndiscoverAll
	SLASH_COMMANDS["/clearmap"] = TrueExplor.ClearMap
	
	-- create mapTiles
	for index = 0, ((TrueExplor.total_units+1)*(TrueExplor.total_units+1) - 1) do
		TrueExplor.mapTiles[index] = MapTile:New( index )
	end
	
	-- update the MapTile objects, when a new map is displayed
	CALLBACK_MANAGER:RegisterCallback( "OnWorldMapChanged",TrueExplor.RefreshTiles)
	
	-- there is a short blending animation, which resets the alpha values for the texture's vertices
	-- so let the worldmap appear instantly instead
	WORLD_MAP_FRAGMENT.Show = ZO_SimpleSceneFragment.Show
	WORLD_MAP_FRAGMENT.Hide = ZO_SimpleSceneFragment.Hide
	-- when the map is opened/closed, the tiles need to be refreshed
	local callback = function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			if AUI_MapContainer then
				-- the tiles need to be placed onto the real map, when it is opened
				local width, height = ZO_WorldMapContainer:GetDimensions()
				local unitWidth = width / TrueExplor.total_units
				local unitHeight = height / TrueExplor.total_units
				for index = 0, ((TrueExplor.total_units+1)*(TrueExplor.total_units+1) - 1) do
					TrueExplor.mapTiles[index]:SetLayout( unitWidth, unitHeight, ZO_WorldMapContainer )
				end
			end
			TrueExplor.RefreshTiles()
		elseif newState == SCENE_HIDING then
			if AUI_MapContainer then
				-- the tiles need to be placed onto the minimap map, when the default map is closed
				local width, height = AUI_MapContainer:GetDimensions()
				local unitWidth = width / TrueExplor.total_units
				local unitHeight = height / TrueExplor.total_units
				for index = 0, ((TrueExplor.total_units+1)*(TrueExplor.total_units+1) - 1) do
					TrueExplor.mapTiles[index]:SetLayout( unitWidth, unitHeight, AUI_MapContainer )
				end
				TrueExplor.RefreshTiles()
			end
		end
	end
	local mapscene = SCENE_MANAGER:GetScene("worldMap")
	mapscene:RegisterCallback("StateChange", callback)
	mapscene = SCENE_MANAGER:GetScene("gamepad_worldMap")
	mapscene:RegisterCallback("StateChange", callback)
	
	-- add update handler after addon has finished loading,
	-- otherwise the update method coul've been called too early
	EVENT_MANAGER:RegisterForUpdate("TrueExploration", 0, TrueExplor.OnUpdate)
	
	-- add zoom function for the tiles. when the map is zoomed into, the tiles need to scale as well
	local oldDimensions = ZO_WorldMapContainer.SetDimensions
	ZO_WorldMapContainer.SetDimensions = function(self, width, height, ...)
		local unitWidth = width / TrueExplor.total_units
		local unitHeight = height / TrueExplor.total_units
		for index = 0, ((TrueExplor.total_units+1)*(TrueExplor.total_units+1) - 1) do
			TrueExplor.mapTiles[index]:SetLayout( unitWidth, unitHeight, self )
		end
		oldDimensions(self, width, height, ...)
	end
	-- add the same scaling code to the minimap
	if AUI_MapContainer then
		local oldDimensionsMM = AUI_MapContainer.SetDimensions
		AUI_MapContainer.SetDimensions = function(self, width, height, ...)
			if not ZO_WorldMap_IsWorldMapShowing() then
				local unitWidth = width / TrueExplor.total_units
				local unitHeight = height / TrueExplor.total_units
				local x, y
				for index = 0, ((TrueExplor.total_units+1)*(TrueExplor.total_units+1) - 1) do
					TrueExplor.mapTiles[index]:SetLayout( unitWidth, unitHeight, self )
				end
			end
			oldDimensionsMM(self, width, height, ...)
		end
		-- the minimap needs some time to be fully initialized
		-- dirty hack :/
		-- without this, the map may be fully hidden upon login
		zo_callLater(function() TrueExplor.needUpdate = true end, 1000)
	end
	
	-- a long time ago, this addon used to save data in a different structure
	-- if someone is still using such an old save file, refactor the contained data
	TrueExplor.UpdateDataVersion()
	
	LibDAU:VerifyAddon("TrueExploration")
end

EVENT_MANAGER:RegisterForEvent("TrueExploration", EVENT_ADD_ON_LOADED , TrueExplor.OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent("TrueExploration", EVENT_PLAYER_ACTIVATED, TrueExplor.RefreshTiles)