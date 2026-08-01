--[[###############################################################################################################################

MapTables - A standalone support add-on to create and maintain Map tables
	by Drakanwulf and Hawkeye1889

A standalone support add-on to create and initialize or to retrieve and update Map information for all accounts and characters on 
any game megaserver.

WARNING: This add-on is a standalone library. Do NOT embed its folder within any other add-on!

###############################################################################################################################--]]

--[[-------------------------------------------------------------------------------------------------------------------------------
Local variables shared by multiple functions within this add-on.
---------------------------------------------------------------------------------------------------------------------------------]]
local ADDON_NAME = "MapTables"			-- The name of this add-on
local addon = {}						-- Every add-on control entry begins as an empty table

--[[-------------------------------------------------------------------------------------------------------------------------------
Bootstrap code to load this add-on.
---------------------------------------------------------------------------------------------------------------------------------]]
assert( not _G[ADDON_NAME], ADDON_NAME.. ": This add-on is already loaded. Do NOT load it multiple times!" )
 
_G[ADDON_NAME] = addon
assert( _G[ADDON_NAME], ADDON_NAME.. ": the game failed to create a control entry!" )

--[[-------------------------------------------------------------------------------------------------------------------------------
Define local variables and tables including a "defaults" Saved Variables table.
---------------------------------------------------------------------------------------------------------------------------------]]
-- Map information, reference, and cross-reference tables by mapIndex and mapId
local coordByIndex = {}			-- Global x,y coordinates (topleft corner) by mapIndex
local indexById = {}			-- Map Index cross-reference by mapId
local indexByName = {}			-- Mapindex by Map Name
local infoByIndex = {}			-- Map information by mapIndex
local mapIdByIndex = {}			-- Map Identifier cross-reference by mapIndex
local mapIdByName = {}			-- Map Identifier by mapName
local nameById = {}				-- Map Name by mapId

-- Zone information by mapIndex. This top-down view is how MapTables sees the world's Zone maps
local zoneIdByIndex = {}		-- Zone Identifier cross-reference by mapIndex

-- This Saved Variables "defaults" table contains pointers to all the Maps tables
local defaults = {
	-- Table control values
	addOnVersion = 0,				-- AddOnVersion value in use the last time these tables were loaded
	apiVersion = 0,					-- ESO API Version in use the last time these tables were loaded
	numMaps = 0,					-- Number of maps in the world the last time these tables were loaded
	-- Reference tables
	coord = coordByIndex,
	info = infoByIndex,
	inxmid = indexById,
	inxnam = indexByName,
	midinx = mapIdByIndex,
	midnam = mapIdByName,
	nammid = nameByMapId,
	zidinx = zoneIdByIndex,
}

--[[-------------------------------------------------------------------------------------------------------------------------------
Get the MapTables manifest information and update our control entry with it. Necessary to get the AddOnVersion: directive value.
---------------------------------------------------------------------------------------------------------------------------------]]
local LM = LibManifest
assert( LM, ADDON_NAME.. ": The game refused to create a link to LibManifest!" )

local manifest = {
	-- These values are retrieved from existing manifest directives
	author,			-- From the Author: directive Without any special characters
	description,	-- From the Description: directive
	fileName,		-- The name of this add-on's folder and manifest file
	isEnabled,		-- ESO boolean value
	isOutOfDate,	-- ESO boolean value
	loadState,		-- ESO load state (i.e. loaded; not loaded)
	title,			-- From the Title: directive without any special characters

	-- These values are retrieved from 100026 manifest directives
	addOnVersion,	-- From the AddOnVersion: directive
	filePath,		-- Path to this add-on's folder/directory

	-- These values are retrieved from 100027 manifest directives
	isLibrary,		-- From the IsLibrary: directive
}
				
manifest = LM:Create( ADDON_NAME )
assert( manifest, ADDON_NAME.. ": LibManifest did not return an information table!" )

-- Update the global control entry
addon.manifest = manifest
_G[ADDON_NAME] = addon

--[[-------------------------------------------------------------------------------------------------------------------------------
Obtain a local link to "LibGPS2" and define a measurements table for its use.
---------------------------------------------------------------------------------------------------------------------------------]]
local GPS = LibGPS2
if not GPS and LibStub then
	GPS = LibStub:GetLibrary( "LibGPS2", SILENT )
end
assert( GPS, ADDON_NAME.. ": LibStub refused to create a link to LibGPS2!" )

local measurement = {
	scaleX = 0,
	scaleY = 0,
	offsetX = 0,
	offsetY = 0,
	mapIndex = 0,
	zoneIndex = 0,
}

--[[-------------------------------------------------------------------------------------------------------------------------------
Local functions to load the Maps reference tables and to measure the global x,y coordinates for all zones in this Map.
---------------------------------------------------------------------------------------------------------------------------------]]
-- Local references to game and/or Library API functions for speed
local GMI = GetMapInfo
local GCMId = GetCurrentMapId
local SM2MLI = SetMapToMapListIndex

-- Resets and loads the reference tables for every Map in the world that has valid information for it
local function LoadAllMaps( tmax: number )		-- tmax := The number of maps in the world
	-- Reset the reference tables
	coordByIndex = {}
	indexById = {}
	indexByName = {}
	infoByIndex = {}
	mapIdByIndex = {}
	mapIdByName = {}
	nameById = {}
	zoneIdByIndex = {}
	-- Loop through all the maps
	local mdx									-- mapIndex
	for mdx = 1, tmax do
		-- Get the reference information for this mapIndex
		local name, mtype, ctype, zid = GMI( mdx )
		-- Load the reference tables for this Map
		indexByName[name] = mdx										-- Indexes table
		infoByIndex[mdx] = { mapType = mtype, content = ctype }		-- Info table
		if zid and type( zid ) == "number" and zid > 0 then			-- Map Index to Zone Identifier xref table
			zoneIdByIndex[mdx] = zid
		end
		-- Get the global x,y coordinate values
		SM2MLI( mdx )					-- Change maps
		measurement = GPS:GetCurrentMapMeasurements() or {}			-- "or {}" because The Aurbis map returns nil!
		coordByIndex[mdx] = { measurement.offsetX or 0, measurement.offsetY or 0 }
		-- Generate the Map Identifier reference and cross-reference tables
		local mid = GCMId()				-- Must be executed after we change game maps!
		if mid and mid > 0 then			-- Generate table entries only for valid Map Identifiers!
			indexById[mid] = mdx
			mapIdByIndex[mdx] = mid
			mapIdByName[name] = mid
			nameById[mid] = name
		end
	end
end

--[[-------------------------------------------------------------------------------------------------------------------------------
The "OnAddonLoaded" function reads the saved variables table (sv) from the saved variables file, "...\SavedVariables\MapTables.lua"
if the file exists; otherwise, the function loads partially filled, default tables into the "sv" variable. Finally, the function
links everything in its local tables to their equivalent MapTables table entries.
---------------------------------------------------------------------------------------------------------------------------------]]
local function OnAddonLoaded( event, name )
	if name ~= ADDON_NAME then
		return
	end
	EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED )

	-- Define megaserver constants and a saved variables filenames table. Default is the PTS megaserver.
	local SERVER_EU = "EU Megaserver" 
	local SERVER_NA = "NA Megaserver"
	local SERVER_PTS = "PTS"

	local savedVarsNameTable = {
		[SERVER_EU] = "MapTables_EU_Vars",
		[SERVER_NA] = "MapTables_NA_Vars",
		[SERVER_PTS] = "MapTables_PTS_Vars",
	}	 	

	-- Retrieve the saved variables data or load their default values
	local savedVarsFile = savedVarsNameTable[GetWorldName()] or savedVarsNameTable[SERVER_PTS]
	local sv = _G[savedVarsFile] or defaults
	
	--Update the Maps reference tables from their Saved Data variables
	coordByIndex = sv.coord
	infoByIndex = sv.info
	indexById = sv.inxmid
	indexByName = sv.inxnam
	mapIdByIndex = sv.midinx
	mapIdByName = sv.midnam
	nameById = sv.nammid
	zoneIdByIndex = sv.zidinx

	-- Wait for a player to become active; LibGPS2 needs this
	EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_PLAYER_ACTIVATED,
		function( event, initial )
			EVENT_MANAGER:UnregisterForEvent( ADDON_NAME, EVENT_PLAYER_ACTIVATED )
		end
	)
	assert( GPS:IsReady(), ADDON_NAME.. ": LibGPS2 cannot function until a player is active!" )

	-- Get the current values for the AddOnVersion, APIVersion, and number of maps
	local addOnVersion = manifest.addOnVersion
	local currentAPI = GetAPIVersion()
	local numMaps = GetNumMaps()

	-- If the AddOnVersion, the APIVersion, or the number of maps has changed, reload all the tables
	if currentAPI ~= sv.apiVersion
	or addOnVersion ~= sv.addOnVersion
	or numMaps ~= sv.numMaps
	-- If any Maps tables are missing or empty, reload all of the Maps tables
	or not coordByIndex or coordByIndex == {}
	or not indexById or indexById == {}
	or not indexByName or indexByName == {}
	or not infoByIndex or infoByIndex == {}
	or not mapIdByIndex or mapIdByIndex == {}
	or not mapIdByName or mapIdByName == {}
	or not nameById or nameById == {}
	or not zoneIdByIndex or zoneIdByIndex == {} then
		-- Save wherever we are in the world
		SetMapToPlayerLocation()		-- Set the current map to wherever we are in the world
		GPS:PushCurrentMap()			-- Save the current map settings
		-- Reload all the Map tables
		LoadAllMaps( numMaps )
		-- Put us back to wherever we were in the world
		GPS:PopCurrentMap()
		-- Update the Saved Data control variables
		sv.addOnVersion = addOnVersion
		sv.apiVersion = currentAPI
		sv.numMaps = numMaps
		-- Transfer the loaded reference tables back into their Saved Data variables
		sv.coord = coordByIndex
		sv.info = infoByIndex
		sv.inxmid = indexById
		sv.inxnam = indexByName
		sv.midinx = mapIdByIndex
		sv.midnam = mapIdByName
		sv.nammid = nameById
		sv.zidinx = zoneIdByIndex
		-- Create new or update existing Saved Variables tables in the "...\SavedVariables\MapTables.lua" file
		_G[savedVarsFile] = sv
	end
end

--[[-------------------------------------------------------------------------------------------------------------------------------
MapTables public API function definitions. MapTables does not duplicate any of the game API functions listed below:

The game API documentation defines these Map Index API functions.
	* GetCyrodiilMapIndex()
	* GetImperialCityMapIndex()
	* GetMapNameByIndex(*luaindex* _mapIndex_)
	* GetAutoMapNavigationCommonZoomOutMapIndex()

The game API documentation defines these Map Identifer API functions.
	* GetMapNumTilesForMapId(*integer* _mapId_)
	* GetMapTileTextureForMapId(*integer* _mapId_, *luaindex* _tileIndex_)

The game API documentation defines these functions for getting the identifier, index, and/or name values from the current Map. 
	* GetCurrentMapIndex()
	* GetCurrentMapId()
	* GetCurrentMapZoneIndex()
	* GetCurrentSubZonePOIIndices()
	* GetMapName()
	* GetMapType()
	* GetMapContentType()
	* GetMapFilterType()

MapTables uses the "SetMapToMapListIndex()" game API function to traverse game Maps by their Map Indexes.
---------------------------------------------------------------------------------------------------------------------------------]]

-- Get the content type for this map
function MapTables:GetContentType( mapIndex: number )
	return infoByIndex[mapIndex].content or nil
end

-- Get the global x,y coordinates for this Map
function MapTables:GetCoord( mapIndex: number )
	return coordByIndex[mapIndex][1] or nil, coordByIndex[mapIndex][2] or nil
end

-- Get the Map Identifier for this Map Index
function MapTables:GetIdByIndex( mapIndex: number )
	return mapIdByIndex[mapIndex] or nil
end

-- Get the Map Identifier for this Map Name
function MapTables:GetIdByName( mapName: string )
	return mapIdByName[mapName] or nil
end

-- Get the Map Index for this Map Name
function MapTables:GetIndex( mapName: string )
	return indexByName[mapName] or nil
end

-- Get the Map Index for this Map Identifier
function MapTables:GetIndexById( mapId: number )
	return indexById[mapId] or nil
end

-- Get the map type for this Map
function MapTables:GetMapType( mapIndex: number )
	return infoByIndex[mapIndex].mapType or nil
end

-- Get the Map Name for this Map Identifier
function MapTables:GetNameById( mapId: number )
	return nameById[mapId] or nil
end

-- Get the equivalent Zone Identifier for this Map
function MapTables:GetZoneId( mapIndex: number )
	return zoneIdByIndex[mapIndex] or nil
end

--[[-------------------------------------------------------------------------------------------------------------------------------
And the last thing we do in this add-on is to wait for ESO to notify us that our add-on modules and support add-ons (i.e. libraries) have been loaded.
---------------------------------------------------------------------------------------------------------------------------------]]
EVENT_MANAGER:RegisterForEvent( ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded )
