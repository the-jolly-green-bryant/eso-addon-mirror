-- lib3D by Shinni
-- this library keeps 3D controls at their world location
-- even if the world's origin moves (happens after teleporting or when moving 1km away from the last origin)

local LIB_NAME = "Lib3D"
local VERSION = 14
local lib, version = LibStub:NewLibrary(LIB_NAME, VERSION)
if not lib then return end
if version and version < VERSION then
	EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_PLAYER_ALIVE)
	EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
end

local GPS = LibStub("LibGPS2")
local LMP = LibStub("LibMapPing")

local d = function() end
if false then -- set to true for debug output
	d = _G["d"]
	function GlobalPos()
		local x, y = GetMapPlayerPosition("player")
		x, y = GPS:LocalToGlobal(x, y)
		d(x,y)
	end
end

local MAXIMUM_CAMERA_DISTANCE = 10 * 10
local VALID_ORIGIN_RANGE = 1000 * 1000
local CRITICAL_LEVELS = {
	{	-- normal state, call OnUpdate ocasionally
		range = -1,
		frameTime = 1500, -- 1.5 seconds
	},
	{	-- critical state, call OnUpdate more often, but not every frame
		range = 800 * 800,
		frameTime = 100, -- 0.1 seconds
	},
	{	-- emergency state, call OnUpdate every single frame
		range = 950 * 950,
		frameTime = 0, -- every frame
	},
}
local NUM_CRITICAL_LEVELS = #CRITICAL_LEVELS

-- control which is used to take 3d world coordinate measurements
local measurementControl = _G[LIB_NAME .. "MeasurementControl"]
if not measurementControl then
	measurementControl = CreateControl(LIB_NAME .. "MeasurementControl", GuiRoot, CT_CONTROL)
	measurementControl:Create3DRenderSpace()
end
-- the current critical level
local currentLevel = 1
-- registered callbacks and controls
local worldChangeCallbacks = {}
local registeredControls = {}
local worldMoveCallbacks = {}

local currentOriginGlobalX
local currentOriginGlobalY

local initialized = false
lib.computedFactors = {}

-- the passed zoneId should be the player's current zoneId
local function ComputeGlobalToWorldFactor(zoneId)
	if not SetPlayerWaypointByWorldLocation then return end -- pre-housing API
	if lib.computedFactors[zoneId] then
		return lib.computedFactors[zoneId]
	end
	local result = nil
	
	local match = DoesCurrentMapMatchMapForPlayerLocation()
	SetMapToMapListIndex(TAMRIEL_MAP_INDEX)
	
	-- save current map ping, so we can restore it later
	local hasMapPing = LMP:HasMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	local originalX, originalY = LMP:GetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	
	-- set two waypoints that are 25 km in X and Y direction apart from each other
	LMP:SuppressPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	local success = SetPlayerWaypointByWorldLocation(-125000, 0, -125000)
	if success then
		local firstX, firstY = LMP:GetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
		success = SetPlayerWaypointByWorldLocation(125000, 0, 125000)
		if success then
			local secondX, secondY = LMP:GetMapPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
			result = 2 * 2500 / (secondX - firstX + secondY - firstY)
			if firstX == secondX or firstY == secondY then result = nil end
		end
	end
	LMP:UnsuppressPing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	
	-- restore waypoint
	LMP:MutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	if hasMapPing then
		PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, originalX, originalY)
	else
		RemovePlayerWaypoint()
	end
	LMP:UnmutePing(MAP_PIN_TYPE_PLAYER_WAYPOINT)
	
	SetMapToPlayerLocation()
	if not match then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
	end
	
	lib.computedFactors[zoneId] = result
	return result
end

local function UpdateOriginOfControls(dx, dy)
	d("move control by", dx, dy)
	local worldX, worldY, worldZ
	for control, _ in pairs(registeredControls) do
		d(control)
		worldX, worldY, worldZ = control:Get3DRenderSpaceOrigin()
		control:Set3DRenderSpaceOrigin(worldX + dx, worldY, worldZ + dy)
	end
end

local function SetOriginOfControls(x, y)
	d("set control to", x, y)
	local worldX, worldY, worldZ
	for control, _ in pairs(registeredControls) do
		d(control)
		worldX, worldY, worldZ = control:Get3DRenderSpaceOrigin()
		control:Set3DRenderSpaceOrigin(-x, worldY, -y)
	end
end

local lastX, lastY
local function OnUpdate()
	local x, y = GetMapPlayerPosition("player")
	x, y = GPS:LocalToGlobal(x, y)
	if not x then return end -- universe map is open :(
	
	local dx = (currentOriginGlobalX - x) * currentGlobalToWorldFactor
	local dy = (currentOriginGlobalY - y) * currentGlobalToWorldFactor
	local dist2 = dx * dx + dy * dy
	-- the barrier was crossed and the game has set a new origin to the player's current location
	if currentLevel >= NUM_CRITICAL_LEVELS then
		Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
		local worldX, worldY, worldZ = measurementControl:Get3DRenderSpaceOrigin()
		local len2 = worldX * worldX + worldZ * worldZ
		if len2 < 500 then
			d(len2)
			
			SetOriginOfControls(
				x * currentGlobalToWorldFactor,
				y * currentGlobalToWorldFactor)
			d("new origin", x, y)
			currentOriginGlobalX = x--lastX
			currentOriginGlobalY = y--lastY
			
			currentLevel = 1
			EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
			EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
			
			for identifier, callback in pairs(worldMoveCallbacks) do
				callback(identifier)
			end
			return
		end
	end
	-- update the critical levels
	
	local range 
	if currentLevel > 1 then
		range = CRITICAL_LEVELS[currentLevel].range
		if dist2 < range then
			currentLevel = currentLevel - 1
			d("level lower", currentLevel)
			EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
			EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
		end
	end
	
	if currentLevel < NUM_CRITICAL_LEVELS then
		range = CRITICAL_LEVELS[currentLevel+1].range
		if dist2 > range then
			currentLevel  = currentLevel + 1
			d("level up", currentLevel)
			EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
			EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
		end
	end
	
	lastX = x
	lastY = y
end

local function OnPlayerActivated()
	-- check if the player entered a new world
	local zoneIndex = GetUnitZoneIndex("player")
	local newWorld = currentZoneIndex ~= zoneIndex
	-- get first person camera coordinates in 3d world
	local worldX, worldY, worldZ = lib:GetPlayerCurrentWorldCoordsApproximation()
	d("world camera coords", worldX, worldY, worldZ)
	local closeOrigin = (worldX * worldX + worldZ * worldZ < MAXIMUM_CAMERA_DISTANCE + 1)--MAXIMUM_CAMERA_DISTANCE + 1)
	d("new World", newWorld, "close Origin", closeOrigin)
	if newWorld then
		currentZoneIndex = zoneIndex
		currentZoneId = GetZoneId(zoneIndex)
		currentGlobalToWorldFactor = ComputeGlobalToWorldFactor(currentZoneId)
		d("calculated factor", currentGlobalToWorldFactor)
		if not currentGlobalToWorldFactor then -- fallback
			currentGlobalToWorldFactor = lib.SPECIAL_GLOBAL_TO_WORLD_FACTORS[currentZoneId] or lib.DEFAULT_GLOBAL_TO_WORLD_FACTOR
			d("used fallback global to world factor", currentGlobalToWorldFactor)
		end
		currentWorldToGlobalFactor = 1 / currentGlobalToWorldFactor
	end
	if not IsMounted() then -- we only received first person coords, if the player isn't mounted
		local x, y = GetMapPlayerPosition("player")
		
		if not x then
			SetMapToPlayerLocation()
			x, y = GetMapPlayerPosition("player")
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
		end
		
		x, y = GPS:LocalToGlobal(x, y)
		d("new origin global coords", x, y)
		
		x = x - worldX * currentWorldToGlobalFactor
		y = y - worldZ * currentWorldToGlobalFactor
		
		if not newWorld then
			SetOriginOfControls(
					x * currentGlobalToWorldFactor,
					y * currentGlobalToWorldFactor)
		end
		currentOriginGlobalX = x
		currentOriginGlobalY = y
		
		local dist2 = worldX * worldX + worldZ * worldZ
		for level = 1, NUM_CRITICAL_LEVELS do
			if dist2 > CRITICAL_LEVELS[level].range then
				currentLevel = level
			end
		end
		EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
		EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
		d("initialized with level", currentLevel)
	else
		local data = ZO_Ingame_SavedVariables["Lib3D_12"]
		if data then
			currentOriginGlobalX = data[1]
			currentOriginGlobalY = data[2]
			
			d("loaded previous origin")
			d(currentOriginGlobalX, currentOriginGlobalY)
			
			currentLevel = data[3]
			EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
			EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
			d("initialized with level", currentLevel)
		else
			if closeOrigin then
				local x, y = GetMapPlayerPosition("player")
		
				if not x then
					SetMapToPlayerLocation()
					x, y = GetMapPlayerPosition("player")
					CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
				end
				
				x, y = GPS:LocalToGlobal(x, y)
				currentOriginGlobalX = x
				currentOriginGlobalY = y
				
				currentLevel = 1
				EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
				EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
				d("initialized with level", currentLevel)
			else
				--error
				d("could not reconstruct origin, use inaccurate camera coordinates")
				-- this will be wrong, but the shift is at most 10 meters
				local x, y = GetMapPlayerPosition("player")
				
				if not x then
					SetMapToPlayerLocation()
					x, y = GetMapPlayerPosition("player")
					CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
				end
				
				x, y = GPS:LocalToGlobal(x, y)
				d("new origin global coords", x, y)
				
				x = x - worldX * currentWorldToGlobalFactor
				y = y - worldZ * currentWorldToGlobalFactor
				
				if not newWorld then
					SetOriginOfControls(
							x * currentGlobalToWorldFactor,
							y * currentGlobalToWorldFactor)
				end
				currentOriginGlobalX = x
				currentOriginGlobalY = y
				
				local dist2 = worldX * worldX + worldZ * worldZ
				for level = 1, NUM_CRITICAL_LEVELS do
					if dist2 > CRITICAL_LEVELS[level].range then
						currentLevel = level
					end
				end
				EVENT_MANAGER:UnregisterForUpdate(LIB_NAME)
				EVENT_MANAGER:RegisterForUpdate(LIB_NAME, CRITICAL_LEVELS[currentLevel].frameTime, OnUpdate)
				d("initialized with level", currentLevel)
			end
		end
	end
		
	ZO_Ingame_SavedVariables["Lib3D"] = nil
	ZO_Ingame_SavedVariables["Lib3D_12"] = nil
	
	if newWorld then
		if not initialized then
			-- when the UI is reloaded, the origin is not reset, so we need to save the origin coordinates
			ZO_PreHook("ReloadUI", function()
				ZO_Ingame_SavedVariables["Lib3D"] = nil
				ZO_Ingame_SavedVariables["Lib3D_12"] = {currentOriginGlobalX, currentOriginGlobalY, currentLevel}
			end)
		end
		
		initialized = true
		registeredControls = {}
		local wasReload = newWorld and closeOrigin
		for identifier, callback in pairs(worldChangeCallbacks) do
			callback(identifier, zoneIndex, currentZoneId, wasReload)
		end
	end
end
EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_PLAYER_ALIVE, OnPlayerActivated)

---
-- This function expects an identifier in addition to the callback. The identifier can be
-- used to unregister the callback.
-- The registered callback will be fired when the player enters a new 3d world. (e.g. a delve is entered)
-- The callbacks arguments are the identifier and the current 3d world's zoneIndex and zoneId
function lib:RegisterWorldChangeCallback(identifier, callback)
	worldChangeCallbacks[identifier] = callback
end

---
-- Unregisters the callback which belongs to the given identifier
function lib:UnregisterWorldChangeCallback(identifier)
	worldChangeCallbacks[identifier] = nil
end

---
-- Registers a callback, which is called whenever the world origin changes
function lib:RegisterWorldMoveCallback(identifier, callback)
	worldMoveCallbacks[identifier] = callback
end

function lib:UnregisterWorldMoveCallback(identifier)
	worldMoveCallbacks[identifier] = nil
end

---
-- Registers the control.
-- Registered controls will stay at their location even if the world's origin moves.
-- The control will be unregistered when a new 3d world is entered.
-- Register a WorldChangeCallback to get notified when this is the case.
function lib:RegisterControl(control)
	registeredControls[control] = true
	local x, z = self:GetPersistentWorldOrigin()
	control:Set3DRenderSpaceOrigin(x, 0, z)
end

---
-- Unregisters the control.
-- This addon will no longer translate the pin when the world origin moves.
function lib:UnregisterControl(control)
	registeredControls[control] = nil
end

---
-- Returns the global coordsystem to world system factor for the current zone.
-- Returns nil if the factor isn't known.
-- The 2nd return value tells you, if the value was computed or if it is a hardcoded fallback value
-- This factor can be used to convert distances between global coords to distances in meters.
function lib:GetGlobalToWorldFactor(zoneId)
	local result = lib.computedFactors[zoneId]
	if result then
		return result, true
	end
	return lib.SPECIAL_GLOBAL_TO_WORLD_FACTORS[zoneId], false
end

---------------------------------------------------------------------
-- coordinate conversion functions
-- first map to world coords
-- then world coords to map coords further below
---------------------------------------------------------------------

---
-- Expects a point given in global map coordinates and returns
-- the point's world x and z coords in relation to the current world origin.
function lib:GetCurrentWorldCoordsFromGlobal(x, y)
	x = x - currentOriginGlobalX
	y = y - currentOriginGlobalY
	x = x * currentGlobalToWorldFactor
	y = y * currentGlobalToWorldFactor
	return x, y
end

---
-- Expects a point given in local map coordinates and returns
-- the point's world x and z coords in relation to the current world origin.
function lib:GetCurrentWorldCoordsFromLocal(x, y)
	x, y = GPS:LocalToGlobal(x, y)
	return self:GetCurrentWorldCoordsFromGlobal(x, y)
end

---
-- Expects a point given in global map coordinates and returns
-- the point's world x and z coords in relation to an origin at the north eastern corner of the tamriel map
function lib:GetPersistentWorldCoordsFromGlobal(x, y)
	x = x * currentGlobalToWorldFactor
	y = y * currentGlobalToWorldFactor
	return x, y
end

---
-- Expects a point given in local map coordinates and returns
-- the point's world x and z coords in relation to an origin at the north eastern corner of the tamriel map
function lib:GetPersistentWorldCoordsFromLocal(x, y)
	x, y = GPS:LocalToGlobal(x, y)
	return self:GetPersistentWorldCoordsFromGlobal(x, y)
end


---
-- Expects a point given in world x and z coords in relation to the current world origin
-- and returns the point in global map coordinates
function lib:GetGlobalFromCurrentWorldCoords(x, z)
	x = x * currentWorldToGlobalFactor
	z = z * currentWorldToGlobalFactor
	x = x + currentOriginGlobalX
	z = z + currentOriginGlobalY
	return x, y
end

---
-- Expects a point given in world x and z coords in relation to the current world origin
-- and returns the point in local map coordinates
function lib:GetLocalFromCurrentWorldCoords(x, z)
	x, z = self:GetGlobalFromCurrentWorldCoords(x, z)
	x, z = GPS:GlobalToLocal(x, z)
	return x, z
end

---
-- Expects a point given in world x and z coords in relation to an origin in the north eastern corner of the tamriel map
-- and returns the point in global map coordinates
function lib:GetGlobalFromPersistentWorldCoords(x, z)
	x = x * currentWorldToGlobalFactor
	z = z * currentWorldToGlobalFactor
	return x, z
end

---
-- Expects a point given in world x and z coords in relation to an origin in the north eastern corner of the tamriel map
-- and returns the point in local map coordinates
function lib:GetLocalFromPersistentWorldCoords(x, z)
	x, z = self:GetGlobalFromPersistentWorldCoords(x, z)
	x, z = GPS:GlobalToLocal(x, z)
	return x, z
end

---
-- Returns the position of the persistant world origin in relation to the current world origin
function lib:GetPersistentWorldOrigin()
	local x = -currentOriginGlobalX * currentGlobalToWorldFactor
	local z = -currentOriginGlobalY * currentGlobalToWorldFactor
	return x, z
end

---
-- Returns the camera position in world coordinates in relation to the current world origin.
function lib:GetCameraCurrentWorldCoords()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	return measurementControl:Get3DRenderSpaceOrigin()
end

---
-- Returns position, and the three basis vectors of the camera's render space (forward, right, up)
function lib:GetCameraCurrentWorldRenderSpace()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local x, y, z = measurementControl:Get3DRenderSpaceOrigin()
	local forwardX, forwardY, forwardZ = measurementControl:Get3DRenderSpaceForward()
	local rightX, rightY, rightZ = measurementControl:Get3DRenderSpaceRight()
	local upX, upY, upZ = measurementControl:Get3DRenderSpaceUp()
	return x, y, z, forwardX, forwardY, forwardZ, rightX, rightY, rightZ, upX, upY, upZ
end

---
-- Returns an approximation of the player's current world coordinates in relation to the current world origin
-- The returned values are the position of the first person camera.
-- If the toggle between first and third person camera doesn't work (i.e the player is mounted), then the third person camera's cooridnates are returned.
-- Note that calling this function will toggle the camera twice, which can result in screen flickering when called outside of a key <Down> or <Up> callback.
-- Use with care!
function lib:GetPlayerCurrentWorldCoordsApproximation()
	if IsMounted() then return self:GetCameraCurrentWorldCoords() end
	
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local preToggleX, preToggleY, preToggleZ = measurementControl:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local toggledX, toggledY, toggledZ = measurementControl:Get3DRenderSpaceOrigin()
	ToggleGameCameraFirstPerson()
	Set3DRenderSpaceToCurrentCamera(measurementControl:GetName())
	local reToggleX, reToggleY, reToggleZ = measurementControl:Get3DRenderSpaceOrigin()
	
	local resultX, resultY, resultZ
	-- unfortunately there is no api function to get the current camera state (first person or third person)
	-- but for some reason the distance between the camera position before the first toggle and after the 2nd toggle
	-- is only zero, if the camera toggled from first person to third person to first person
	if preToggleX == reToggleX and preToggleY == reToggleY and preToggleZ == reToggleZ then
		-- the camera toggled from first person to third person to first person
		resultX, resultY, resultZ = preToggleX, preToggleY, preToggleZ -- first person coords
	else
		-- the camera toggled from third person to first person to third person
		resultX, resultY, resultZ = toggledX, toggledY, toggledZ -- first person coords
	end
	
	if initialized then
		local x, y = GetMapPlayerPosition("player")
		x, y = GPS:LocalToGlobal(x, y)
		-- since we were able to get an accurate camera position, use this chance to update the camera position
		if x then
			x = x - resultX * currentWorldToGlobalFactor
			y = y - resultZ * currentWorldToGlobalFactor
			
			SetOriginOfControls(
				x * currentGlobalToWorldFactor,
				y * currentGlobalToWorldFactor)
			currentOriginGlobalX = x
			currentOriginGlobalY = y
			
			d("new origin global coords", x, y)
		end
	end
	
	return resultX, resultY, resultZ
end

---
-- Returns true when the addon is initialized. Calling library function earlier can result in errors.
-- Initialization is performed during the player activated event.
function lib:IsInitialized()
	return initialized
end
