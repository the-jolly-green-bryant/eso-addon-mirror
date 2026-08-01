AUI.Minimap.Map = {}

local isLoaded = false
local indexToTile = {}
local currentZoomValue = 0

AUI.MapData = {}
AUI.MapData.tileCountX = 0
AUI.MapData.tileCountY = 0
AUI.MapData.tileWidth = 0
AUI.MapData.tileHeight = 0
AUI.MapData.playerX = 0
AUI.MapData.playerY = 0
AUI.MapData.lastPlayerX = -1
AUI.MapData.lastPlayerY = -1
AUI.MapData.heading = 0
AUI.MapData.lastHeading = 0
AUI.MapData.mapContainerSize = 0
AUI.MapData.forcePlayerCenter = false
AUI.MapData.heightAsWidth = false

AUI_ZOOM_STEP_ZONE = 1.0
AUI_ZOOM_STEP_SUBZONE = 0.4
AUI_ZOOM_STEP_DUNGEON = 0.5
AUI_ZOOM_STEP_ARENA = 0.5

AUI_MINIMAP_MIN_ZOOM_ZONE = 1.0
AUI_MINIMAP_MAX_ZOOM_ZONE = 15
AUI_MINIMAP_MIN_ZOOM_SUBZONE = 1.0
AUI_MINIMAP_MAX_ZOOM_SUBZONE = 8
AUI_MINIMAP_MIN_ZOOM_DUNGEON = 1.0
AUI_MINIMAP_MAX_ZOOM_DUNGEON = 4
AUI_MINIMAP_MIN_ZOOM_ARENA = 1.0
AUI_MINIMAP_MAX_ZOOM_ARENA = 4

local function GetMapIndexList()
	local mapIndexList = 
	{
		["zone"] = {
			[0] = 0,
			[1] = 1,
			[2] = 20,
			[3] = 21,
			[4] = 30,
			[5] = 31,
			[6] = 40,
			[7] = 41,
			[8] = 50,
			[9] = 51
		},
		["subzone"] = {
			[0] = 10,
			[1] = 11
		},
		["dungeon"] = {
			[0] = 2,
			[1] = 12,
			[2] = 22,
			[3] = 32,
			[4] = 42,
			[5] = 52
		},
		["arena"] = {
			[0] = 13,
		}		
	}
	
	return mapIndexList
end

local function AUI_Minimap_SetMapContainerSize()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_SetMapContainerSize")
	end
	--/DebugMessage--

	AUI.Minimap.SetCurrentZoomValue()

	local mapWidth = AUI.Settings.Minimap.width
	local mapHeight = AUI.Settings.Minimap.height	
	
	local mapSize = zo_max(mapHeight, mapWidth) * currentZoomValue
	
	AUI.MapData.mapContainerSize = mapSize
	
	AUI_MapContainer:SetDimensions(mapSize, mapSize)
end

--Zoom

local function AUI_Minimap_GetMapZoneTyp()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_GetMapZoneTyp")
	end
	--/DebugMessage--

	local mapIndex = AUI_Minimap_GetCurrentMapTypeID()

	for typ, mv in pairs(GetMapIndexList()) do
		for e, sv in pairs(mv) do
			if mapIndex == sv then
				return typ			
			end
		end
	end
		
	return nil
end

function AUI.Minimap.SetCurrentZoomValue()
	if not AUI.Minimap.IsLoaded() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.GetCurrentZoomValue")
	end
	--/DebugMessage--	
	
	currentMapZoneTyp = AUI_Minimap_GetMapZoneTyp()
	
	local zoomValue = AUI.Settings.Minimap.zoom[currentMapZoneTyp]	
	if not zoomValue then
		zoomValue = 1		
	end
	
	currentZoomValue = zoomValue
end

function AUI.Minimap.GetCurrentZoomValue()
	return currentZoomValue
end

function AUI_Minimap_ReleaseTiles()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_ReleaseTiles")
	end
	--/DebugMessage--

    for k, tile in ipairs(indexToTile) do
        tile:SetHidden(true)
    end
end

function AUI_Minimap_GetTile(i)
    local tile = indexToTile[i]
    if(tile == nil) then
        tile = CreateControlFromVirtual(AUI_MapContainer:GetName(), AUI_MapContainer, "AUI_MapTile", i)
        indexToTile[i] = tile
    end
    tile:SetHidden(false)
    return tile
end

function AUI_Minimap_GetTileAnchor(iX, iY)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_GetTileAnchor")
	end
	--/DebugMessage--

	local offsetX = 0
	local offsetY = 0		
	local relToControl = nil
		
	if AUI.Settings.Minimap.rotate then
		local x = ((iX-0.5) * AUI.MapData.tileWidth) - (AUI.MapData.mapContainerSize * AUI.MapData.playerX)
		local y = ((iY-0.5) * AUI.MapData.tileHeight) - (AUI.MapData.mapContainerSize * AUI.MapData.playerY)						

		offsetX = (math.cos(-AUI.MapData.heading) * x) - (math.sin(-AUI.MapData.heading) * y)
		offsetY = (math.sin(-AUI.MapData.heading) * x) + (math.cos(-AUI.MapData.heading) * y)
				
		relToControl = AUI_MapContainer
	else
		offsetX = ((iX-0.5) * AUI.MapData.tileWidth) - AUI.MapData.mapContainerSize / 2
		offsetY = ((iY-0.5) * AUI.MapData.tileHeight) - AUI.MapData.mapContainerSize / 2	
		relToControl = AUI_MapContainer	
	end

	return CENTER, relToControl, CENTER, offsetX, offsetY
end

function AUI_Minimap_UpdateRotateTiles()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_UpdateRotateTiles")
	end
	--/DebugMessage--

	local i = 1
	for iY=1, AUI.MapData.tileCountX do
		for iX=1, AUI.MapData.tileCountY do	
			local tileControl = AUI_Minimap_GetTile(i)

			tileControl:ClearAnchors()
			tileControl:SetAnchor(AUI_Minimap_GetTileAnchor(iX, iY))
			tileControl:SetTextureRotation(AUI.MapData.heading, 0.5, 0.5);	
			
			i = i + 1
		end
	end		
end

function AUI_Minimap_SetTiles()
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_SetTiles")
	end
	--/DebugMessage--

	AUI.MapData.tileCountX, AUI.MapData.tileCountY = GetMapNumTiles()	
	AUI.MapData.tileWidth = AUI.MapData.mapContainerSize / AUI.MapData.tileCountX
	AUI.MapData.tileHeight = AUI.MapData.mapContainerSize / AUI.MapData.tileCountY
			
	AUI_Minimap_ReleaseTiles()	
	
	local i = 1
	for iY=1, AUI.MapData.tileCountX do
		for iX=1, AUI.MapData.tileCountY do	
			local tileControl = AUI_Minimap_GetTile(i)
	
			if AUI.Settings.Minimap.rotate then
				tileControl:SetTextureRotation(AUI.MapData.heading, 0.5, 0.5);		
			else
				tileControl:SetTextureRotation(0);
			end
		
			tileControl:SetDimensions(AUI.MapData.tileWidth, AUI.MapData.tileHeight)
			tileControl:ClearAnchors()
			tileControl:SetAnchor(AUI_Minimap_GetTileAnchor(iX, iY))
			tileControl:SetTexture(GetMapTileTexture(i))		
			i = i + 1
		end
	end					
end

local function AUI_Minimap_UpdatePlayerPin()
	local playerPin = AUI.Minimap.Pin.GetPlayerPin()

	AUI.MapData.playerX, AUI.MapData.playerY = GetMapPlayerPosition("player")
	
	if AUI.Settings.Minimap.rotate then
		AUI.MapData.heading = -GetPlayerCameraHeading()
	
		playerPin:SetLocation(AUI.MapData.playerX, AUI.MapData.playerY)	
		playerPin:SetRotation(0)	
	else
		AUI.MapData.heading = GetPlayerCameraHeading()
	
		playerPin:SetLocation(AUI.MapData.playerX, AUI.MapData.playerY)
		playerPin:SetRotation(AUI.MapData.heading)	
	end
end

local function AUI_Minimap_SetMapToPlayer(_force)
	AUI_Minimap_UpdatePlayerPin()

	if _force or AUI.MapData.lastHeading ~= AUI.MapData.heading or AUI.MapData.lastPlayerX ~= AUI.MapData.playerX or AUI.MapData.lastPlayerY ~= AUI.MapData.playerY then
		if AUI.Settings.Minimap.rotate then		
			AUI_Minimap_UpdateRotateTiles()	
			AUI.Minimap.Pin.UpdatePinLocations()
			AUI_Minimap_MainWindow_Map_Rotate:SetTextureRotation(AUI.MapData.heading)
		else
			local offsetX = AUI.MapData.mapContainerSize * AUI.MapData.playerX
			local offsetY = AUI.MapData.mapContainerSize * AUI.MapData.playerY

			local mapHalfWidth = AUI.Settings.Minimap.width / 2
			local mapHalfHeight = AUI.Settings.Minimap.height / 2
			
			if not AUI.MapData.forcePlayerCenter then
				if offsetX <= mapHalfWidth then
					offsetX = mapHalfWidth
				elseif offsetX >= AUI.MapData.mapContainerSize - mapHalfWidth then
					offsetX = AUI.MapData.mapContainerSize - mapHalfWidth
				end			
		
				if offsetY <= mapHalfHeight then
					offsetY = mapHalfHeight
				elseif offsetY >= AUI.MapData.mapContainerSize - mapHalfHeight then
					offsetY = AUI.MapData.mapContainerSize - mapHalfHeight
				end		
			end
			
			AUI_MapContainer:ClearAnchors()
			AUI_MapContainer:SetAnchor(TOPLEFT, nil, CENTER, -offsetX, -offsetY)
		end
		
		AUI.MapData.lastHeading = AUI.MapData.heading
		AUI.MapData.lastPlayerX = AUI.MapData.playerX
		AUI.MapData.lastPlayerY = AUI.MapData.playerY		
	end
end

local function RefreshMap()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end
	
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("RefreshMap")
	end
	--/DebugMessage--	
	
	AUI_Minimap_SetMapContainerSize()
	AUI_Minimap_SetTiles()
	AUI_Minimap_SetMapToPlayer(true)

	if AUI.Settings.Minimap.rotate then
		AUI_MapContainer:ClearAnchors()
		AUI_MapContainer:SetAnchor(CENTER, nil, CENTER, 0, 0)		
	end
end

local function AUI_Minimap_SetZoom(zoomValue)
	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI_Minimap_SetZoom")
	end
	--/DebugMessage--	

	AUI.Settings.Minimap.zoom[currentMapZoneTyp] = zoomValue

	RefreshMap()
	AUI.Minimap.Pin.UpdatePins()
end

local function AUI_Minimap_GetZoomStep()
	local zoomStep = 1

	local mapZoneTyp = AUI_Minimap_GetMapZoneTyp()
				
	if mapZoneTyp == "zone" then
		zoomStep = AUI_ZOOM_STEP_ZONE
	elseif mapZoneTyp == "subzone" then
		zoomStep = AUI_ZOOM_STEP_SUBZONE
	elseif mapZoneTyp == "dungeon" then	
		zoomStep = AUI_ZOOM_STEP_DUNGEON
	elseif mapZoneTyp == "arena" then	
		zoomStep = AUI_ZOOM_STEP_ARENA		
	end

	return zoomStep
end

local function AUI_Minimap_SetZoomByStep(step)
	local zoom = AUI.Settings.Minimap.zoom[currentMapZoneTyp] + step
	
	local minZoom = AUI_MINIMAP_MIN_ZOOM_ZONE
	local maxZoom = AUI_MINIMAP_MAX_ZOOM_ZONE

	if currentMapZoneTyp == "subzone" then
		minZoom = AUI_MINIMAP_MIN_ZOOM_SUBZONE 
		maxZoom = AUI_MINIMAP_MAX_ZOOM_SUBZONE 
	elseif currentMapZoneTyp == "dungeon" then
		minZoom = AUI_MINIMAP_MIN_ZOOM_DUNGEON
		maxZoom = AUI_MINIMAP_MAX_ZOOM_DUNGEON	
	elseif currentMapZoneTyp == "arena" then
		minZoom = AUI_MINIMAP_MIN_ZOOM_ARENA
		maxZoom = AUI_MINIMAP_MAX_ZOOM_ARENA			
	end

	if zoom > maxZoom then
		zoom = maxZoom
	end
	
	if zoom < minZoom then
		zoom = minZoom
	end	
	
	if zoom >= minZoom and zoom <= maxZoom then	
		AUI_Minimap_SetZoom(zoom)
	end		
end

function AUI_Minimap_GetCurrentMapTypeID()
	return tonumber(GetMapType() .. GetMapContentType())
end

function AUI.Minimap.GetCurrentMapIndex()
	local tileTexture = GetMapTileTexture()
	
	return AUI.String.ToNumber(tileTexture)
end

function AUI.Minimap.Map.Update()
	if not isLoaded or not AUI.Minimap.IsLoaded() or not AUI.Minimap.IsEnabled() or ZO_WorldMap_IsWorldMapShowing() or not AUI.Minimap.IsShow() then
		return
	end

	if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then	
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")		
	else
		AUI_Minimap_SetMapToPlayer()
	end
end

function AUI.Minimap.Map.Refresh()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end

	--DebugMessage--
	if AUI_DEBUG then
		AUI.DebugMessage("AUI.Minimap.Map.Refresh")
	end
	--/DebugMessage--		
	
	RefreshMap()
	AUI.Minimap.Pin.RefreshPins()
end

function AUI.Minimap.Map.ZoomIn()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end

	if AUI.Minimap.IsShow() then
		local zoomStep = AUI_Minimap_GetZoomStep()

		AUI_Minimap_SetZoomByStep(-zoomStep)
	end
end

function AUI.Minimap.Map.ZoomOut()
	if not isLoaded or not AUI.Minimap.IsLoaded() then
		return
	end

	if AUI.Minimap.IsShow() then
		local zoomStep = AUI_Minimap_GetZoomStep()								
				
		AUI_Minimap_SetZoomByStep(zoomStep)
	end
end

function AUI.Minimap.Map.Init()
	if isLoaded then
		return
	end

	isLoaded = true	
end