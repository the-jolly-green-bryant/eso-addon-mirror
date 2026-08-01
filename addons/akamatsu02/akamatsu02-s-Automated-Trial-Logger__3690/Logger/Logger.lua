EncounterLogger = {
    name = "Logger",
	loggingZone = 0,
	logging = false,
	waiting = false
}

local ZONES = {
	[636] = true,
	[638] = true,
	[639] = true,
	[725] = true,
	[975] = true,
	[1000] = true,
	[1051] = true,
	[1121] = true,
	[1196] = true,
	[1263] = true,
	[1344] = true,
	[1427] = true,
	[1478] = true
}

local function startLog(zoneId) 
	if EncounterLogger.waiting == true then return end
	SetEncounterLogEnabled(true)
	EncounterLogger.logging = true
	EncounterLogger.loggingZone = zoneId
	d("Log gestartet!")
end

local function endLog() 
	SetEncounterLogEnabled(false)
	EncounterLogger.logging = false
	EncounterLogger.loggingZone = 0
	d("Log beendet!")
end

local function endLogIfEnabled()
	if IsEncounterLogEnabled() == true and EncounterLogger.logging == true then
		endLog()
	end
end

local function onZoneChange(_, _)
	if GetCurrentZoneDungeonDifficulty() ~= DUNGEON_DIFFICULTY_VETERAN then 
		endLogIfEnabled()
		return 
	end
	local zoneId = GetUnitRawWorldPosition("player")
	if ZONES[zoneId] == true then
		if IsEncounterLogEnabled() == true and zoneId == EncounterLogger.loggingZone then return end
		
		if IsEncounterLogEnabled() == true then 
			endLog()
			EncounterLogger.waiting = true
			zo_callLater(function () 
				EncounterLogger.waiting = false
				startLog(zoneId)
			end, 15000)
		else 
			startLog(zoneId)
		end
	else
		endLogIfEnabled()
	end
end

local function start( eventCode, addonName )
	if (addonName ~= EncounterLogger.name) then return end
	EVENT_MANAGER:RegisterForEvent(EncounterLogger.name.."_ZC", EVENT_PLAYER_ACTIVATED, onZoneChange)
	EVENT_MANAGER:UnregisterForEvent(EncounterLogger.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(EncounterLogger.name, EVENT_ADD_ON_LOADED, start)