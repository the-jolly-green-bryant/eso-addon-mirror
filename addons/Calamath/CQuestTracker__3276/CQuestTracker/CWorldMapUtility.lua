--
-- Calamath's Quest Tracker [CQT]
--
-- Copyright (c) 2022 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CQuestTracker then return end
local CQT = CQuestTracker:SetSharedEnvironment()
local g_mapPinManager = ZO_WorldMap_GetPinManager()
local g_mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
local INVALID_ZONE_INDEX = INVALID_ZONE_INDEX or 1
local INVALID_ZONE_ID = INVALID_ZONE_ID or 2

local function ZoneStoryZoneIdIterator(_, lastZoneId)
	return GetNextZoneStoryZoneId(lastZoneId)
end

-- ---------------------------------------------------------------------------------------
-- WorldMap Utility Class (CWorldMapUtility)
-- ---------------------------------------------------------------------------------------
-- Scope: This utility class provides useful functions for manipulating the world map class object and its variants.
--
local CWorldMapUtility = ZO_InitializingObject:Subclass()
function CWorldMapUtility:Initialize()
	self.name = "CWorldMapUtility"
	self.poiDatabase = {}
	self.poiIdToNodeIndex = {}
	self.dungeonNameToPoiId = {}

	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_LOADED, function(_, addonName)
		if addonName ~= CQT.name then return end
--		CQT.LDL:Debug("CWorldMapUtility:EVENT_ADD_ON_LOADED")
		EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
		self:RebuildPoiIdCache()
		self:RebuildRootZoneMapList()
		self:InitializePoiDatabase()
		self:AppendPoiDatabaseExceptions()
	end)
end


-- [Root Zone Map management] --
-- We defined the root zone map as the widest area map of each zone that includes the fast travel wayshrines. These are often used by players to move between zones.
--
function CWorldMapUtility:RebuildRootZoneMapList()
-- The set of maps whose UIMapType is MAPTYPE_ZONE with a mapIndex value is a de facto collection of in-game root zone maps.
	local rootZoneMapId = {}
	for mapIndex = 1, GetNumMaps() do
		local _, mapType = GetMapInfoByIndex(mapIndex)
		if mapType == MAPTYPE_ZONE then
			local mapId = GetMapIdByIndex(mapIndex)
			rootZoneMapId[mapId] = true
		end
	end
-- However, with principles come exceptions.
	rootZoneMapId[1552] = nil	-- Norg-Tzel (mapId=1552) is excluded because the zoneStoryZoneId and fast-travel wayshrine are also not present.
	rootZoneMapId[660] = true	-- Imperial City (mapId=660) is included because it is a subzone map with a unique zoneStoryZoneId.
	self.rootZoneMapId = rootZoneMapId

	local rootZoneIdToMapId = {}
	for mapId in pairs(rootZoneMapId) do
		local _, _, _, zoneIndex = GetMapInfoById(mapId)
		rootZoneIdToMapId[GetZoneId(zoneIndex)] = mapId
	end
	self.rootZoneIdToMapId = rootZoneIdToMapId
end

function CWorldMapUtility:IsRootZoneMap(mapId)
	return self.rootZoneMapId[mapId or 0] or false
end

function CWorldMapUtility:RootZoneMapIdIterator()
	local t = self.rootZoneMapId
	local mapId
	return function()
		mapId = next(t, mapId)
		if mapId then
			return mapId
		else
			return nil
		end
	end
	-- We know this is the same as pairs(t)
end

function CWorldMapUtility:IsRootZoneId(zoneId)
	return self.rootZoneIdToMapId[zoneId or 0] or false
end

function CWorldMapUtility:IsRootZoneCityDetailedMap(mapId)
	local _, mapType, mapContentType, _, zoneId = self:GetMapInfoById_Fixed(mapId)
	return self:IsRootZoneId(zoneId) and mapType == MAPTYPE_SUBZONE and mapContentType == MAP_CONTENT_NONE
end


-- [POI cache management] --

function CWorldMapUtility:RebuildPoiIdCache()
	local poiIdBreadcrumbs = {
		[INVALID_ZONE_INDEX] = { 0 }
	}
	for i = 1, UPPER_LIMIT_OF_ASSUMED_POI_ID do
		local zoneIndex, poiIndex = GetPOIIndices(i)
		if zoneIndex ~= INVALID_ZONE_INDEX then
			if not poiIdBreadcrumbs[zoneIndex] then
				poiIdBreadcrumbs[zoneIndex] = {}
			end
			poiIdBreadcrumbs[zoneIndex][poiIndex] = i
		end
	end
	self.poiIdBreadcrumbs = poiIdBreadcrumbs
end

function CWorldMapUtility:GetPoiId(zoneIndex, poiIndex)
	local zonePoiIdData = self.poiIdBreadcrumbs[zoneIndex or INVALID_ZONE_INDEX] or self.poiIdBreadcrumbs[INVALID_ZONE_INDEX]
	return zonePoiIdData[poiIndex or 0] or 0
end


-- [POI database management] --
local dungeonNodePoiTypes = {
	[POI_TYPE_OBJECTIVE]				= POI_DB_TYPE_ARENA_DUNGEON,	 	-- arena POIs
	[POI_TYPE_STANDARD]					= POI_DB_TYPE_ARENA_DUNGEON, 		-- arena POIs
	[POI_TYPE_ACHIEVEMENT]				= POI_DB_TYPE_TRIAL_DUNGEON, 		-- trial POIs
	[POI_TYPE_ACHIEVEMENT_COMPONENT]	= POI_DB_TYPE_NODE, 
	[POI_TYPE_PUBLIC_DUNGEON]			= POI_DB_TYPE_PUBLIC_DUNGEON, 
	[POI_TYPE_GROUP_DUNGEON]			= POI_DB_TYPE_GROUP_DUNGEON, 		-- group dungeon POIs
}
local wayshrineNodePoiTypes = {
	[POI_TYPE_WAYSHRINE]				= POI_DB_TYPE_WAYSHRINE, 
}
local houseNodePoiTypes = {
	[POI_TYPE_HOUSE]					= POI_DB_TYPE_HOUSE, 
}
function CWorldMapUtility:InitializePoiDatabase()
	local poiIdToNodeIndex = self.poiIdToNodeIndex
	local poiDatabase = self.poiDatabase
	-- First, we build a database of non-node POIs.
	-- This is essentially the same as copying the zoneStoryActivity breadcrumb list for the required zoneCompletionType.
	local requiredPoiZoneCompletionTypes = {
		[ZONE_COMPLETION_TYPE_DELVES]			= POI_DB_TYPE_DELVE, 
		[ZONE_COMPLETION_TYPE_GROUP_DELVES]		= POI_DB_TYPE_GROUP_DELVE, 
		[ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS]	= POI_DB_TYPE_PUBLIC_DUNGEON, 
	}
	for zoneStoryZoneId in ZoneStoryZoneIdIterator do
		for zoneCompletionType, poiDatabaseType in pairs(requiredPoiZoneCompletionTypes) do
			local numActivities = GetNumZoneActivitiesForZoneCompletionType(zoneStoryZoneId, zoneCompletionType)
			if numActivities > 0 then
				if not poiDatabase[zoneStoryZoneId] then
					poiDatabase[zoneStoryZoneId] = {}
				end
				if not poiDatabase[zoneStoryZoneId][poiDatabaseType] then
					poiDatabase[zoneStoryZoneId][poiDatabaseType] = {}
				end
			end
			for i = 1, numActivities do
				local activityId = GetZoneActivityIdForZoneCompletionType(zoneStoryZoneId, zoneCompletionType, i)
				poiDatabase[zoneStoryZoneId][poiDatabaseType][i] = activityId

				local name = GetZoneStoryActivityNameByActivityIndex(zoneStoryZoneId, zoneCompletionType, i)
				self.dungeonNameToPoiId[name] = activityId
			end
		end
	end

	-- Then we add node POIs.
	for nodeIndex = 1, GetNumFastTravelNodes() do
		local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
		local _, poiName, _, _, _, _, poiType = GetFastTravelNodeInfo(nodeIndex)
		local zoneCompletionType = GetPOIZoneCompletionType(zoneIndex, poiIndex)
		local zoneStoryZoneId = GetZoneStoryZoneIdForZoneId(GetZoneId(zoneIndex))
		local poiId = self:GetPoiId(zoneIndex, poiIndex)
		local poiDatabaseType = dungeonNodePoiTypes[poiType] or POI_DB_TYPE_NODE
		if poiId ~= 0 then
			poiIdToNodeIndex[poiId] = nodeIndex
			if not poiDatabase[zoneStoryZoneId] then
				poiDatabase[zoneStoryZoneId] = {}
			end
			if not poiDatabase[zoneStoryZoneId][poiDatabaseType] then
				poiDatabase[zoneStoryZoneId][poiDatabaseType] = {}
			end
			table.insert(poiDatabase[zoneStoryZoneId][poiDatabaseType], poiId)

			if dungeonNodePoiTypes[poiType] then
				self.dungeonNameToPoiId[poiName] = poiId
				-- Unfortunately, most group/trial dungeon POI names have a prefix, while map/zone names do not.
				local found, _, formattedName = string.find(poiName, ":%s*(.*)")
				if found and formattedName ~= "" then
					self.dungeonNameToPoiId[formattedName] = poiId
				end
				found, _, formattedName = string.find(poiName, "：(.*)")
				if found and formattedName ~= "" then
					self.dungeonNameToPoiId[formattedName] = poiId
				end
			end
		end
	end
end

function CWorldMapUtility:AppendPoiDatabaseExceptions()
-- We hard-code only for very specific cases.
	self.dungeonNameToPoiId[GetMapNameById(2354)] = function()		-- Bastion Nymic
		return HasQuest(7013) and 2671 
			or HasQuest(7056) and 2670 
			or HasQuest(7057) and 2672 
			or HasQuest(7058) and 2673 
			or 0
	end
end


-- [parent map table management] --
-- The reference to a parent-child map here is to the correspondence between two discontinuous maps.
-- A good example is a detailed map of a dungeon and a larger zone map of the dungeon doorway.
local playerAlliance = GetUnitAlliance("player")
local function GetFixedValue(value, ...)
	if type(value) == "function" then
		return value(...)
	elseif type(value) == "table" then
		return value[playerAlliance]
	else
		return value
	end
end

-- fixedMapZoneIdTable[mapId] = zoneId
-- Typically, we can get the zoneId associated with an individual map via GetMapInfoById API.
-- Unfortunately, there are some unzoned maps with undefined zoneId, and in rare cases, there are even maps that yield incorrect zoneId.
-- We created this table as a countermeasure to the above problem. However, we are not trying to be perfect in our map correspondence, 
-- nor are we trying to hard-code thousands of maps. We are simply providing a means of correcting what we notice.
local fixedMapZoneIdTable = {
	[65]	= 284, 			-- Bad Man's Hallows
--	[2096]	= 1274, 		-- Garden of Shadows
}
local function GetMapZoneInfoById_Fixed(mapId)
	local _, _, _, zoneIndex = GetMapInfoById(mapId)
	return GetFixedValue(fixedMapZoneIdTable[mapId or 0]) or GetZoneId(zoneIndex)
end

function CWorldMapUtility:GetMapInfoById_Fixed(mapId)
	local name, mapType, mapContentType, zoneIndex = GetMapInfoById(mapId)
	local zoneId = GetFixedValue(fixedMapZoneIdTable[mapId or 0])
	if zoneId then
		zoneIndex = GetZoneIndex(zoneId)
	else
		zoneId = GetZoneId(zoneIndex)
	end
	return name, mapType, mapContentType, zoneIndex, zoneId
end


-- fixedParentZoneTable[zoneId] = fixedParentZoneId
-- No API is available to get the correspondence between the dungeon entrances on the root zone map and the detailed dungeon map, but in most cases, we can substitute it in the parent zone table.
-- This table is intended to redefine some exceptional correspondences and override the parent zone table for the above purposes.
-- Note: This is slightly different from the geographic correspondence, since dungeon entrances sometimes represent portals that warp between two geographically distant points.
local fixedParentZoneTable = {
	-- Main Quest
	[1429]	= { [ALLIANCE_ALDMERI_DOMINION] = 381, [ALLIANCE_EBONHEART_PACT] = 41, [ALLIANCE_DAGGERFALL_COVENANT] = 3, }, 		-- The Harborage
	-- Fighters Guild Places
	[207]	= { [ALLIANCE_ALDMERI_DOMINION] = 383, [ALLIANCE_EBONHEART_PACT] = 57, [ALLIANCE_DAGGERFALL_COVENANT] = 19, }, 		-- Mzeneldt
	[208]	= { [ALLIANCE_ALDMERI_DOMINION] = 108, [ALLIANCE_EBONHEART_PACT] = 117, [ALLIANCE_DAGGERFALL_COVENANT] = 20, }, 	-- The Earth Forge (solo instance : The Prismatic Core)
	[209]	= 642, 			-- Halls of Submission
	[385]	= { [ALLIANCE_ALDMERI_DOMINION] = 58, [ALLIANCE_EBONHEART_PACT] = 101, [ALLIANCE_DAGGERFALL_COVENANT] = 104, }, 	-- Ragnthar
	[542]	= 381, 			-- Buraniim
	[543]	= 3, 			-- Dourstone Vault
	[544]	= 41, 			-- Stonefang Cavern
	[595]	= { [ALLIANCE_ALDMERI_DOMINION] = 108, [ALLIANCE_EBONHEART_PACT] = 117, [ALLIANCE_DAGGERFALL_COVENANT] = 20, }, 	-- Abagarlas
	[642]	= { [ALLIANCE_ALDMERI_DOMINION] = 382, [ALLIANCE_EBONHEART_PACT] = 103, [ALLIANCE_DAGGERFALL_COVENANT] = 92, }, 	-- The Earth Forge (after Fighters Guild Quests)
	-- Imperial City Dungeon fix
	[678]	= 181, 			-- Imperial City Prison
	[688]	= 181, 			-- White-Gold Tower
	-- Mages Guild Places
	[203]	= { [ALLIANCE_ALDMERI_DOMINION] = 381, [ALLIANCE_EBONHEART_PACT] = 41,  [ALLIANCE_DAGGERFALL_COVENANT] = 3, }, 		-- Cheesemonger's Hollow
	[218]	= { [ALLIANCE_ALDMERI_DOMINION] = 108, [ALLIANCE_EBONHEART_PACT] = 117, [ALLIANCE_DAGGERFALL_COVENANT] = 20, }, 	-- Circus of Cheerful Slaughter
	[219]	= { [ALLIANCE_ALDMERI_DOMINION] = 58, [ALLIANCE_EBONHEART_PACT] = 101, [ALLIANCE_DAGGERFALL_COVENANT] = 104, }, 	-- Chateau of the Ravenous Rodent
	[541]	= { [ALLIANCE_ALDMERI_DOMINION] = 383, [ALLIANCE_EBONHEART_PACT] = 57, [ALLIANCE_DAGGERFALL_COVENANT] = 19, }, 		-- Glade of the Divines
	[267]	= { [ALLIANCE_ALDMERI_DOMINION] = 382, [ALLIANCE_EBONHEART_PACT] = 103, [ALLIANCE_DAGGERFALL_COVENANT] = 92, }, 	-- Eyevea (after Mages Guild Quests)
	-- The Reach special places with another entrance leading to Blackreach.
							-- Gloomreach
	[1209]	= function() return GetParentZoneId(GetUnitWorldPosition("player")) == 1208 and 1208 end, 		-- don't worry otherwise, it will be 1207.
	-- Apocrypha fix ---------------------- Oh man. The Necrom chapter seems to have all the wrong data for the zones located in Apocrypha.
	[1393]	= 1413, 		-- The Tranquil Catalog
	[1394]	= 1413, 		-- The Infinite Panopticon
	[1395]	= 1413, 		-- The Infinite Panopticon
	[1398]	= 1413, 		-- Quires Wind
	[1399]	= 1413, 		-- The Disquiet Study
	[1400]	= 1413, 		-- Fathoms Drift
	[1401]	= 1413, 		-- Apogee of the Tormenting Eye
	[1409]	= 1413, 		-- The Sidereal Cloisters
	[1410]	= 1413, 		-- Cenotaph of the Remnants
	[1411]	= 1413, 		-- The Rectory Corporea
	[1416]	= 1413, 		-- The Underweave
	[1417]	= 1413, 		-- The Mythos
							-- Bastion Nymic
	[1420]	= function() return HasQuest(7057) and 1413 or HasQuest(7058) and 1413 end,		-- don't worry about questId 7013 and 7056, it will be 1414.
	[1421]	= 1413, 		-- The Forbidden Exhibit
	[1424]	= 1413, 		-- Obscured Forum
	-- The Scholarium
	[1457]	= 1443, 		-- Scholarium Outer Ruins (Sunnamere)
	-- Event Hubs
--	[1274]	= { [ALLIANCE_ALDMERI_DOMINION] = 381, [ALLIANCE_EBONHEART_PACT] = 41, [ALLIANCE_DAGGERFALL_COVENANT] = 3, }, 		-- Garden of Shadows
}
local function GetParentZoneId_Fixed(zoneId)
-- Unfortunately, there are some errors in the parent zone id table that need to be corrected for certain applications.
	return GetFixedValue(fixedParentZoneTable[zoneId or 0]) or GetParentZoneId(zoneId)
end

function CWorldMapUtility:GetParentZoneIdForZoneMap(zoneId)
	local parentZoneIdCandidate = GetParentZoneId_Fixed(zoneId)
	return self:IsRootZoneId(zoneId) and zoneId or parentZoneIdCandidate
end

function CWorldMapUtility:GetParentMapId(mapId)
	local mapZoneId = self:GetMapZoneInfoById_Fixed(mapId)
	return GetMapIdByZoneId(self:GetParentZoneIdForZoneMap(mapZoneId))
end

function CWorldMapUtility:GetPoiIdForDungeon(mapId)
	local mapName, mapType, mapContentType, _, mapZoneId = self:GetMapInfoById_Fixed(mapId)
	return GetFixedValue(self.dungeonNameToPoiId[mapName]) or mapType == MAPTYPE_SUBZONE and mapContentType == MAP_CONTENT_DUNGEON and GetFixedValue(self.dungeonNameToPoiId[GetZoneNameById(mapZoneId)]) or 0
end

function CWorldMapUtility:GetParentMapIdForDungeon(mapId)
-- This method returns the parent map of the dungeon map, using the localized POI name of the POI database as a clue.
	local poiId = self:GetPoiIdForDungeon(mapId)
	local poiMapId = GetMapIdByZoneId(GetZoneId(GetPOIIndices(poiId or 0)))
	return poiMapId
end

-- ---------------------------------------------------------------------------------------

-- [World Map manipulating utility] --

local voidSetMapFloor = function() return SET_MAP_RESULT_MAP_CHANGED end	-- void but always return successful
local voidCALLBACK_MANAGER = { FireCallbacks = function() end, }	-- void FireCallbacks method
-- Unfortunately PlayerChosenMapUpdate is a local function in 'worldmap.lua', so we assign true to g_playerChoseCurrentMap by ZO_WorldMapManager.ChangeFloor under special circumstance.
function CWorldMapUtility:SetWorldMapPlayerChoseCurrentMap()
	local DIRECTION = 0 -- must be a number
	-- backup some apis
	local orgSetMapFloor = SetMapFloor
	local orgCALLBACK_MANAGER = CALLBACK_MANAGER
	-- equivalent operation of g_playerChoseCurrentMap = true
	_G["SetMapFloor"] = voidSetMapFloor
	_G["CALLBACK_MANAGER"] = voidCALLBACK_MANAGER
	ZO_WorldMapManager:ChangeFloor(DIRECTION)
	-- restore apis
	_G["SetMapFloor"] = orgSetMapFloor
	_G["CALLBACK_MANAGER"] = orgCALLBACK_MANAGER
	-- validation
	if ZO_WorldMap_DidPlayerChooseCurrentMap() then
--		CQT.LDL:Debug("QuestPingSingleton: SetWorldMapPlayerChoseCurrentMap [successful]")
	else
		CQT.LDL:Error("QuestPingSingleton: SetWorldMapPlayerChoseCurrentMap [failed]")
	end
end

function CWorldMapUtility:GetWorldMapQuestConditionPin(journalIndex, stepIndex, conditionIndex)
	local journalIndex = journalIndex or 0
	local isJournalQuestStepEnding = IsJournalQuestStepEnding(journalIndex, stepIndex)
	local questMapPins = {}
	g_mapPinManager:AddPinsToArray(questMapPins, "quest", journalIndex)
	for _, questPin in ipairs(questMapPins) do
		local pinJournalIndex, pinStepIndex, pinConditionIndex = questPin:GetQuestData()
		if pinJournalIndex == journalIndex and pinStepIndex == stepIndex and (isJournalQuestStepEnding or pinConditionIndex == conditionIndex) then
			return questPin
		end
	end
	-- If no pins match the exact criteria, return the result of querying mapPinManager.
	return g_mapPinManager:FindPin("quest", journalIndex)
end

function CWorldMapUtility:GetWorldMapQuestPins(journalIndex)
	local journalIndex = journalIndex or 0
	local questMapPins = {}	 -- numerically indexed table
	g_mapPinManager:AddPinsToArray(questMapPins, "quest", journalIndex)
	return questMapPins
end

function CWorldMapUtility:GetWorldMapQuestPingPins()
	local questMapPingPins = {}	 -- numerically indexed table
	g_mapPinManager:AddPinsToArray(questMapPingPins, "pings", MAP_PIN_TYPE_QUEST_PING)
	return questMapPingPins
end

function CWorldMapUtility:GetJournalQuestConditionForDestination(journalIndex)
-- Search journal quest conditions and determine the best destination for display on the map.
-- Start with the main step.
-- (1) non-complete condition nodes for the quest.
-- (2) ending step.
-- (3) first discovered complete condition node.
-- NOTE: Each quest condition node does not always have positional data. Therefore, we need to perform such a traversal.
	local journalIndex = journalIndex or 0
	local completedQuestConditionCandidate
	for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(journalIndex) do
		-- looking for non-complete quest conditions
		for conditionIndex = 1, GetJournalQuestNumConditions(journalIndex, stepIndex) do
			if DoesJournalQuestConditionHavePosition(journalIndex, stepIndex, conditionIndex) then
				local isComplete = select(4, GetJournalQuestConditionValues(journalIndex, stepIndex, conditionIndex))
				if isComplete then
					if not completedQuestConditionCandidate then
						completedQuestConditionCandidate = {
							stepIndex = stepIndex, 
							conditionIndex = conditionIndex, 
						}
					end
				else
					return journalIndex, stepIndex, conditionIndex, false
				end
			end
		end
		-- if no conditions, trying to check quest step ending location.
		if IsJournalQuestStepEnding(journalIndex, stepIndex) and DoesJournalQuestConditionHavePosition(journalIndex, stepIndex, nil) then
			return journalIndex, stepIndex, nil, true
		end
	end
	-- No non-complete conditions were found, but found a complete condition
	if completedQuestConditionCandidate then
		return journalIndex, completedQuestConditionCandidate.stepIndex, completedQuestConditionCandidate.conditionIndex, true
	end
end

function CWorldMapUtility:SetMapToQuestCondition(journalIndex, stepIndex, conditionIndex)
-- ** _Returns:_ *[SetMapResultCode|#SetMapResultCode]* _setMapResult_
-- This method attempts to change the world map to the destination of a specific quest condition. Unlike SetMapToQuestDestination method, there is no fallback.
-- no refresh for the QuestPing pins. You will need to properly fire callbacks later.
	local result = SET_MAP_RESULT_FAILED
	local journalIndex = journalIndex or 0
	if WORLD_MAP_MANAGER:IsMapChangingAllowed() then
		result = SetMapToQuestCondition(journalIndex, stepIndex, conditionIndex)
--		CQT.LDL:Debug("SetMapToQuestCondition (%s:%s:%s) : hasPos=%s, result=%s", tostring(journalIndex), tostring(stepIndex), tostring(conditionIndex), tostring(DoesJournalQuestConditionHavePosition(journalIndex, stepIndex, conditionIndex)), tostring(result))
		if result == SET_MAP_RESULT_FAILED and IsJournalQuestStepEnding(journalIndex, stepIndex) then
			result = SetMapToQuestStepEnding(journalIndex, stepIndex)
--			CQT.LDL:Debug("SetMapToStepEnding (%s:%s) : result=%s", tostring(journalIndex), tostring(stepIndex), tostring(result))
		end
	end
	return result
end

function CWorldMapUtility:SetMapToQuestZone(journalIndex)
-- ** _Returns:_ *[SetMapResultCode|#SetMapResultCode]* _setMapResult_
-- This method attempts to change the world map to the questZone. You will need to properly fire callbacks later.
	local result = SET_MAP_RESULT_FAILED
	local journalIndex = journalIndex or 0
	if WORLD_MAP_MANAGER:IsMapChangingAllowed() then
		result = SetMapToQuestZone(journalIndex)
--		CQT.LDL:Debug("SetMapToQuestZone (%s) : result=%s", tostring(journalIndex), tostring(result))
	end
	return result
end

function CWorldMapUtility:SetMapToQuestDestination(journalIndex)
-- ** _Returns:_ *[SetMapResultCode|#SetMapResultCode]* _setMapResult_
-- This method attempts to change the world map to the optimal destination of the quest.
-- We will attempt to change the world map to the quest destination with the following priorities:
-- Start with the main step.
-- (1) Map of non-complete condition nodes for the quest.
-- (2) Map of the ending step.
-- (3) First discovered map of complete condition node.
-- We will not change the map to the quest zone. Because it often doesn't make sense. no refresh for the QuestPing pins. You will need to properly fire callbacks later.
	local result = SET_MAP_RESULT_FAILED
	local journalIndex = journalIndex or 0
	if WORLD_MAP_MANAGER:IsMapChangingAllowed() then
		local destinationQuestIndex, destinationStepIndex, destinationConditionIndex, isComplete = self:GetJournalQuestConditionForDestination(journalIndex)
		if destinationQuestIndex then
			result = SetMapToQuestCondition(destinationQuestIndex, destinationStepIndex, destinationConditionIndex)
--			CQT.LDL:Debug("SetMapToQuestCondition (%s:%s:%s)[%s] : result=%s", tostring(destinationQuestIndex), tostring(destinationStepIndex), tostring(destinationConditionIndex), tostring(isComplete), tostring(result))
		end
	end
	return result
end

local MAX_NUM_ADJUSTMENTS = 3
function CWorldMapUtility:AdjustQuestDestinationMapByPlayerLocation()
-- ** _Returns:_ *[SetMapResultCode|#SetMapResultCode]* _setMapResult_
-- If the current map is inside a dungeon, we prefer to display the zone map unless the player character enters the dungeon.
	local numAdjustments = 0
	local result = SET_MAP_RESULT_CURRENT_MAP_UNCHANGED
	local playerZoneId = GetUnitWorldPosition("player")
	local isPlayerInDungeon = IsUnitInDungeon("player")
	repeat
		local mapId = GetCurrentMapId()
		local _, mapType, mapContentType, _, mapZoneId = self:GetMapInfoById_Fixed(mapId)
		-- Check prerequisites
		if mapZoneId == INVALID_ZONE_ID then break end
		if isPlayerInDungeon and mapZoneId == playerZoneId then break end
		if DoesCurrentMapMatchMapForPlayerLocation() then break end
		if mapContentType ~= MAP_CONTENT_DUNGEON then break end
		if self:IsRootZoneMap(mapId) then break end
		-- Adjustments
		mapZoneId = self:GetParentZoneIdForZoneMap(mapZoneId)
		result = SetMapToMapId(GetMapIdByZoneId(mapZoneId))
		numAdjustments = numAdjustments + 1
--		CQT.LDL:Debug("ShowQuestOnMap:Adjusted(%d) - mapId = %s (%s) ==> %s (%s)",numAdjustments, tostring(mapId), tostring(GetMapNameById(mapId)), tostring(GetCurrentMapId()), tostring(GetMapNameById(GetCurrentMapId())))
	until numAdjustments >= MAX_NUM_ADJUSTMENTS		-- Avoiding infinite loops when the map does not change due to unforeseen reasons.
	return result
end

function CWorldMapUtility:FireWorldMapChangedCallbacksIfNeeded(setMapResult, wasNavigateIn)
	if setMapResult == SET_MAP_RESULT_MAP_CHANGED then
		CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged", wasNavigateIn)
	end
end

function CWorldMapUtility:OpenWorldMapScene()
-- NOTE: This is the magic code to remove the impacts of the four major minimap addons and safely transition into the world map scene.
--       Although seemingly meaningless, each line has a meaning and should never be modified unless you know what it means. Replacing with an equivalent code is also unacceptable.
	if not ZO_WorldMap_IsWorldMapShowing() then
		if SCENE_MANAGER:IsShowingBaseScene() then
			ZO_WorldMap:SetHidden(ZO_WorldMap:IsHidden())
			if not WORLD_MAP_FRAGMENT:IsShowing() and not ZO_WorldMap:IsHidden() then
--				CQT.LDL:Warn("OpenWorldMapScene : ZO_WorldMap is showing.")
				ZO_WorldMap:SetHidden(true)
			end
			ZO_WorldMap_ShowWorldMap()
--			if not WORLD_MAP_MANAGER:IsInMode(MAP_MODE_LARGE_CUSTOM) then
--				CQT.LDL:Debug("OpenWorldMapScene : [FAILSAFE] changing map mode")
--				WORLD_MAP_MANAGER:SetToMode(MAP_MODE_LARGE_CUSTOM)
--			end
		else
			-- If the transition is not from the base scene, return to the previous scene when the map scene is hidden.
			if IsInGamepadPreferredMode() then
				SCENE_MANAGER:Push("gamepad_worldMap")
			else
				SCENE_MANAGER:Push("worldMap")
    		end
		end
	end
end

function CWorldMapUtility:JumpToQuestConditionPinWhenAvailable(journalIndex, stepIndex, conditionIndex)
	g_mapPanAndZoom:JumpToPinWhenAvailable(function() return self:GetWorldMapQuestConditionPin(journalIndex, stepIndex, conditionIndex) end)
end

function CWorldMapUtility:ShowQuestOnMap(journalIndex, stepIndex, conditionIndex)
-- ** _Returns:_ *[SetMapResultCode|#SetMapResultCode]* _setMapResult_
-- This is very similar to the ZO_WorldMap_ShowQuestOnMap algorithm. But there are a few differences that should be known.
-- (1) We do not switch scenes if no location data exists for the quest destination.
-- (2) We do not show the area map of the quest zone. Because it often doesn't make sense.
-- (3) If the quest condition's destination is inside a dungeon, we prefer to display the zone map unless the player character enters the dungeon. It will be easier to find your destination.
-- (4) We prefer to transition to the world map scene first in environments where minimap add-ons are running, to avoid the impact of them automatically updating the map to the player's position periodically.
--
	local result = SET_MAP_RESULT_FAILED
	local journalIndex = journalIndex or 0
--	CQT.LDL:Debug("ShowQuestOnMap:Begin - mapId = %s (%s)",tostring(GetCurrentMapId()), tostring(GetMapNameById(GetCurrentMapId())))
	if WORLD_MAP_MANAGER:IsMapChangingAllowed() then
		local destinationQuestIndex, destinationStepIndex, destinationConditionIndex = self:GetJournalQuestConditionForDestination(journalIndex)
		if destinationQuestIndex then
			-- transition to map scene first
			self:OpenWorldMapScene()
			-- if disired to show on map a specific quest condition, we try it.
			if stepIndex and conditionIndex and DoesJournalQuestConditionHavePosition(journalIndex, stepIndex, conditionIndex) then
				result = self:SetMapToQuestCondition(journalIndex, stepIndex, conditionIndex)
				if result ~= SET_MAP_RESULT_FAILED then
					destinationStepIndex = stepIndex
					destinationConditionIndex = conditionIndex
				end
			end
			-- Normally, we would switch to the destination map here.
			if result == SET_MAP_RESULT_FAILED then
				result = self:SetMapToQuestCondition(destinationQuestIndex, destinationStepIndex, destinationConditionIndex)
			end
			-- Then, we adjust to show an appropriate zone map instead of a dungeon map, depending on the current position of the player character.
			if result ~= SET_MAP_RESULT_FAILED then
				self:AdjustQuestDestinationMapByPlayerLocation()
			end
			-- Finally, we let the map redraw.
			if result ~= SET_MAP_RESULT_FAILED then
				self:SetWorldMapPlayerChoseCurrentMap()	-- g_playerChoseCurrentMap = true
			end
			if result == SET_MAP_RESULT_MAP_CHANGED then
				CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")	-- wasNavigate = false
			end
		end
	end
--	CQT.LDL:Debug("ShowQuestOnMap:End - mapId = %s (%s)",tostring(GetCurrentMapId()), tostring(GetMapNameById(GetCurrentMapId())))
	return result
end

-- ---------------------------------------------------------------------------------------

function CWorldMapUtility:FindQuestPositions(journalIndex)
	for questStepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(journalIndex) do
		for questConditionIndex = 1, GetJournalQuestNumConditions(journalIndex, questStepIndex) do
			if DoesJournalQuestConditionHavePosition(journalIndex, questStepIndex, questConditionIndex) then
				CQT.LDL:Debug("(%s : %s : %s) - %s", tostring(journalIndex), tostring(questStepIndex), tostring(questConditionIndex), tostring(select(4, GetJournalQuestConditionValues(journalIndex, questStepIndex, questConditionIndex))))
			end
		end
		if IsJournalQuestStepEnding(journalIndex, questStepIndex) then
			-- GetJournalQuestNumConditions return 0 when step ending.
			CQT.LDL:Debug("(%s : %s) - Ending (found = %s)", tostring(journalIndex), tostring(questStepIndex), tostring(DoesJournalQuestConditionHavePosition(journalIndex, questStepIndex, nil)))
		end
	end
end
-- ---------------------------------------------------------------------------------------

local CQT_WORLD_MAP_UTILITY = CWorldMapUtility:New()	-- Never do this more than once!
CQT:RegisterSharedObject("CQT_WORLD_MAP_UTILITY", CQT_WORLD_MAP_UTILITY)

