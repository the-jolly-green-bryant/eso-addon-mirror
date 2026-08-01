local ArchEnhancedMap = {}

--local gps = LibStub("LibGPS2")
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

local ORIGINAL_ESO_MAP_PINS = {
	[MAP_PIN_TYPE_PLAYER] = true,
	[MAP_PIN_TYPE_PING] = true,
	[MAP_PIN_TYPE_RALLY_POINT] = true,
	[MAP_PIN_TYPE_PLAYER_WAYPOINT] = true,
	[MAP_PIN_TYPE_GROUP_LEADER] = true,
	[MAP_PIN_TYPE_GROUP] = true,
	[MAP_PIN_TYPE_DRAGON_COMBAT_HEALTHY] = true,
	[MAP_PIN_TYPE_DRAGON_COMBAT_WEAK] = true,
	[MAP_PIN_TYPE_DRAGON_IDLE_HEALTHY] = true,
	[MAP_PIN_TYPE_DRAGON_IDLE_WEAK] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_OFFER_ZONE_STORY] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_ENDING] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_ENDING] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_ENDING] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_ENDING] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_ENDING] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_ENDING] = true,
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION] = true,
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_QUEST_ZONE_STORY_ENDING] = true,
	[MAP_PIN_TYPE_QUEST_CONDITION] = true,
	[MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_QUEST_ENDING] = true,
	[MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION] = true,
	[MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION] = true,
	[MAP_PIN_TYPE_QUEST_REPEATABLE_ENDING] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC] = true,
	[MAP_PIN_TYPE_FORWARD_CAMP_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_FORWARD_CAMP_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_FORWARD_CAMP_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_ARTIFACT_ALDMERI_OFFENSIVE] = true,
	[MAP_PIN_TYPE_ARTIFACT_ALDMERI_DEFENSIVE] = true,
	[MAP_PIN_TYPE_ARTIFACT_EBONHEART_OFFENSIVE] = true,
	[MAP_PIN_TYPE_ARTIFACT_EBONHEART_DEFENSIVE] = true,
	[MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_OFFENSIVE] = true,
	[MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_DEFENSIVE] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_NEUTRAL] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_ALDMERI] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_EBONHEART] = true,
	[MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_DAGGERFALL] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_FIRE_DRAKES_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_PIT_DAEMONS_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_STORM_LORDS_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_NEUTRAL_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_A_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_B_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_C_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_D_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_A_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_B_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_C_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_D_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_MOBILE_CAPTURE_AREA_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_CAPTURE_AREA_AURA] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_STORM_LORDS] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_SPAWN_NEUTRAL] = true,
	[MAP_PIN_TYPE_BGPIN_MURDERBALL_SPAWN_NEUTRAL] = true,
	[MAP_PIN_TYPE_ARTIFACT_RETURN_ALDMERI] = true,
	[MAP_PIN_TYPE_ARTIFACT_RETURN_EBONHEART] = true,
	[MAP_PIN_TYPE_ARTIFACT_RETURN_DAGGERFALL] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_RETURN_FIRE_DRAKES] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_RETURN_PIT_DAEMONS] = true,
	[MAP_PIN_TYPE_BGPIN_FLAG_RETURN_STORM_LORDS] = true,
	[MAP_PIN_TYPE_TRI_BATTLE_SMALL] = true,
	[MAP_PIN_TYPE_TRI_BATTLE_MEDIUM] = true,
	[MAP_PIN_TYPE_TRI_BATTLE_LARGE] = true,
	[MAP_PIN_TYPE_ALDMERI_VS_EBONHEART_SMALL] = true,
	[MAP_PIN_TYPE_ALDMERI_VS_EBONHEART_MEDIUM] = true,
	[MAP_PIN_TYPE_ALDMERI_VS_EBONHEART_LARGE] = true,
	[MAP_PIN_TYPE_ALDMERI_VS_DAGGERFALL_SMALL] = true,
	[MAP_PIN_TYPE_ALDMERI_VS_DAGGERFALL_MEDIUM] = true,
	[MAP_PIN_TYPE_ALDMERI_VS_DAGGERFALL_LARGE] = true,
	[MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_SMALL] = true,
	[MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_MEDIUM] = true,
	[MAP_PIN_TYPE_EBONHEART_VS_DAGGERFALL_LARGE] = true,
	[MAP_PIN_TYPE_FARM_NEUTRAL] = true,
	[MAP_PIN_TYPE_FARM_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_FARM_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_FARM_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_MINE_NEUTRAL] = true,
	[MAP_PIN_TYPE_MINE_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_MINE_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_MINE_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_MILL_NEUTRAL] = true,
	[MAP_PIN_TYPE_MILL_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_MILL_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_MILL_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_KEEP_NEUTRAL] = true,
	[MAP_PIN_TYPE_KEEP_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_KEEP_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_KEEP_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_IMPERIAL_DISTRICT_NEUTRAL] = true,
	[MAP_PIN_TYPE_IMPERIAL_DISTRICT_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_IMPERIAL_DISTRICT_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_IMPERIAL_DISTRICT_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_AVA_TOWN_NEUTRAL] = true,
	[MAP_PIN_TYPE_AVA_TOWN_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_AVA_TOWN_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_AVA_TOWN_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_OUTPOST_NEUTRAL] = true,
	[MAP_PIN_TYPE_OUTPOST_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_OUTPOST_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_OUTPOST_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_BORDER_KEEP_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_BORDER_KEEP_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_BORDER_KEEP_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_ARTIFACT_KEEP_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_ARTIFACT_KEEP_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_ARTIFACT_KEEP_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_ARTIFACT_GATE_CLOSED_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_POI_SUGGESTED] = true,
	[MAP_PIN_TYPE_POI_SEEN] = true,
	[MAP_PIN_TYPE_POI_COMPLETE] = true,
	[MAP_PIN_TYPE_LOCATION] = true,
	[MAP_PIN_TYPE_FORWARD_CAMP_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_KEEP_GRAVEYARD_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_IMPERIAL_DISTRICT_GRAVEYARD_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_AVA_TOWN_GRAVEYARD_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_KEEP_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_BORDER_KEEP_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_RESPAWN_BORDER_KEEP_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_FAST_TRAVEL_OUTPOST_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_OUTPOST_GRAVEYARD_ACCESSIBLE] = true,
	[MAP_PIN_TYPE_KEEP_ATTACKED_LARGE] = true,
	[MAP_PIN_TYPE_KEEP_ATTACKED_SMALL] = true,
	[MAP_PIN_TYPE_RESTRICTED_LINK_ALDMERI_DOMINION] = true,
	[MAP_PIN_TYPE_RESTRICTED_LINK_EBONHEART_PACT] = true,
	[MAP_PIN_TYPE_RESTRICTED_LINK_DAGGERFALL_COVENANT] = true,
	[MAP_PIN_TYPE_KEEP_BRIDGE] = true,
	[MAP_PIN_TYPE_KEEP_BRIDGE_IMPASSABLE] = true,
	[MAP_PIN_TYPE_KEEP_MILEGATE] = true,
	[MAP_PIN_TYPE_KEEP_MILEGATE_CENTER_DESTROYED] = true,
	[MAP_PIN_TYPE_KEEP_MILEGATE_IMPASSABLE] = true,
	[MAP_PIN_TYPE_AUTO_MAP_NAVIGATION_PING] = true,
	[MAP_PIN_TYPE_QUEST_PING] = true
}
--[[ Mappings for pin data ]]--

function ArchEnhancedMap:SetupOptions()
	local addonDisplayName = "|c0066FFArch's|r Enhanced Map"
	
	local panelData = {
		type = "panel",
		name = addonDisplayName,
		displayName = addonDisplayName,
		author = "|c0066FFArchitecture|r",
		--version = self.version,
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local optionsTable = {
		{
			type = "header",
			name = GetString(SI_ARCHEM_MAP_ENHANCEMENTS),
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SI_ARCHEM_PIN_SCALING),
			tooltip = GetString(SI_ARCHEM_PIN_SCALING_TOOLTIP),
			getFunc = function() return self.sv.mapPinScaleEnabled end,
			setFunc = function(value)
				self.sv.mapPinScaleEnabled = value
				
				self:ScaleMapPins()
			end,
			width = "full",
		},
		{
			type = "slider",
			name = GetString(SI_ARCHEM_PIN_SCALE_FACTOR),
			tooltip = GetString(SI_ARCHEM_PIN_SCALE_FACTOR_TOOLTIP),
			min = 0.1,
			max = 3.0,
			step = 0.1,
			disabled = function()
				return not self.sv.mapPinScaleEnabled
			end,
			getFunc = function()
				return self.sv.mapPinScale
			end,
			setFunc = function(value)
				self.sv.mapPinScale = value
				
				if self.sv.mapPinScale <= 0 then
					self.sv.mapPinScaleEnabled = false
				end
				
				if self.sv.mapPinScaleEnabled or self.sv.mapPinScale <= 0 then
					if self.sv.mapPinScale <= 0 then
						self.sv.mapPinScale = 1
					end
					
					self:ScaleMapPins()
				end
			end,
		},
		{
			-- Only ESO Map Pins
			type = "checkbox",
			name = GetString(SI_ARCHEM_ONLY_ESO_MAP_PINS),
			tooltip = GetString(SI_ARCHEM_ONLY_ESO_MAP_PINS_TOOLTIP),
			warning = GetString(SI_ARCHEM_MENU_WARNING),
			getFunc = function() return self.sv.mapPinScaleOnlyFactoryDefault end,
			setFunc = function(value)
				self.sv.mapPinScaleOnlyFactoryDefault = value
				ReloadUI()
			end,
			disabled = function()
				return not self.sv.mapPinScaleEnabled
			end,
			width = "full",
		},
		{
			-- Clear Pin Data
			type = "button",
			name = GetString(SI_ARCHEM_CLEAR_PIN_DATA),
			tooltip = GetString(SI_ARCHEM_CLEAR_PIN_DATA_TOOLTIP),
			func = function()
				self:ResetOriginalMapPins()
			end,
			width = "full",
		},
		{
			-- Location Teleport
			type = "checkbox",
			name = GetString(SI_ARCHEM_LOCATION_TELEPORT),
			tooltip = GetString(SI_ARCHEM_LOCATION_TELEPORT_TOOLTIP),
			warning = GetString(SI_ARCHEM_MENU_WARNING),
			getFunc = function() return self.sv.teleportEnabled end,
			setFunc = function(value)
				self.sv.teleportEnabled = value
				
				if value then
					self:TeleportInitialize()
				else
					ReloadUI()
				end
			end,
			width = "full",
		},
		--{
		--	type = "checkbox",
		--	name = "Location Order By Recent",
		--	tooltip = "Displays the most recently used teleport locations at the top",
		--	getFunc = function() return self.sv.locationSortEnabled end,
		--	setFunc = function(value)
		--		self.sv.locationSortEnabled = value
		--
		--		if value then
		--			ArchEnhancedMap:LocationDataInitialize()
		--		else
		--			ArchEnhancedMap:LocationDataReset()
		--		end
		--	end,
		--	width = "full",
		--},
		{
			-- Location Teleport Status
			type = "checkbox",
			name = GetString(SI_ARCHEM_LOCATION_TELEPORT_STATUS),
			tooltip = GetString(SI_ARCHEM_LOCATION_TELEPORT_STATUS_TOOLTIP),
			warning = GetString(SI_ARCHEM_MENU_WARNING),
			getFunc = function() return self.sv.locationSortEnabled end,
			setFunc = function(value)
				self.sv.locationSortEnabled = value
				
				if value then
					self:LocationDataInitialize()
				else
					self:LocationDataReset()
				end
			end,
			width = "full",
		},
	}
	
	LAM:RegisterAddonPanel(self.name, panelData)
	LAM:RegisterOptionControls(self.name, optionsTable)
end

function ArchEnhancedMap:HookShowOnMap()
	local origShowOnMapFunc = ZO_WorldMap_ShowQuestOnMap
	
	ZO_WorldMap_ShowQuestOnMap = function(questIndex)
		if not EvalQuestForCraftingSetName(questIndex) then
			origShowOnMapFunc(questIndex)
		end
	end
end

function ArchEnhancedMap:RegisterSlashCommands()
	SLASH_COMMANDS["/findset"] = function (setName)
		OpenMapToSet(setName)
	end
end

function ArchEnhancedMap:ResetOriginalMapPins()
	self.sv.mapPinsOriginalAreSaved = false
	self.sv.mapPinsOriginalSize = {} --purge table
	
	self.sv.mapPinScale = 1.0
	
	self:ScaleMapPins()
	
	self.sv.mapPinScaleEnabled = false
	
	-- Reload UI
	ReloadUI()
end

function ArchEnhancedMap:ScaleMapPins()
	for k, v in pairs(ZO_MapPin.PIN_DATA) do
		if v and v.size ~= nil and (not self.sv.mapPinScaleOnlyFactoryDefault or ORIGINAL_ESO_MAP_PINS[k]) then
			if not self.sv.mapPinsOriginalAreSaved then
				-- First time, must backup pin sizes
				self.sv.mapPinsOriginalSize[k] = v.size
			end
			
			if self.sv.mapPinsOriginalSize[k] ~= nil then
				if self.sv.mapPinScaleEnabled then
					local scaledSize = math.floor(self.sv.mapPinScale * self.sv.mapPinsOriginalSize[k])
					
					if scaledSize > self.sv.mapPinScaleMaxValue then
						scaledSize = self.sv.mapPinScaleMaxValue
					end
					
					if scaledSize > 0 and scaledSize ~= 1 then
						ZO_MapPin.PIN_DATA[k].size = scaledSize
					else
						--Supplemental Fallback
						ZO_MapPin.PIN_DATA[k].size = self.sv.mapPinsOriginalSize[k]
					end
				else
					ZO_MapPin.PIN_DATA[k].size = self.sv.mapPinsOriginalSize[k]
				end
			end
		end
	end
	
	self.sv.mapPinsOriginalAreSaved = true
end

function ArchEnhancedMap:LocationDataInitialize()
	if (WORLD_MAP_LOCATIONS_DATA and WORLD_MAP_LOCATIONS_DATA.RefreshLocationList) then
		self.OrigRefreshLocationList = WORLD_MAP_LOCATIONS_DATA.RefreshLocationList
		
		WORLD_MAP_LOCATIONS_DATA.RefreshLocationList = function()
			local mapData = {}
			for i = 1, GetNumMaps() do
				local mapName, mapType, mapContentType, zoneId, description = GetMapInfo(i)
				
				if mapName == "Gold Coast" then
					mapName = "The Gold Coast"
				end
				if mapName == "Elsweyr" then
					mapName = "Northern Elsweyr"
				end
				
				local targetLocationName = zo_strformat(SI_ZONE_NAME, mapName)
				local isPortable = true
				local isTargetOption = false
				if mapName ~= "Cyrodiil" and mapName ~= "Imperial City" and mapName ~= "Tamriel" and mapName ~= "The Aurbis" then
					if (EasyTravel_AEM) then
						EasyTravel_AEM.TargetHelper:SetTargetZone(mapName)
						EasyTravel_AEM.TargetHelper:RebuildTargetList()
						isTargetOption = #EasyTravel_AEM.TargetHelper.jumpTargets > 0
					end
				else
					isPortable = false
					
					targetLocationName = ZO_ERROR_COLOR:Colorize(targetLocationName)
				end
				
				--if not isTargetOption then
				--	targetLocationName = ZO_ERROR_COLOR:Colorize(targetLocationName)
				--end
				
				if isTargetOption then
					targetLocationName = ZO_SUCCEEDED_TEXT:Colorize(targetLocationName)
				end
				
				mapData[#mapData + 1] = { locationName = targetLocationName, originalLocationName = zo_strformat(SI_ZONE_NAME, mapName), description = description, index = i, totalJumpTargets = #EasyTravel_AEM.TargetHelper.jumpTargets, isTargetOption = isTargetOption, isPortable = isPortable }
			end
			
			table.sort(mapData, function(a, b)
				--return a.originalLocationName < b.originalLocationName
				return (a.isPortable and not b.isPortable) or (a.isPortable and b.isPortable and a.originalLocationName < b.originalLocationName)
			end)
			
			-- Fix descriptions
			for i = 1, #mapData do
				local mapName, mapType, mapContentType, zoneId, description = GetMapInfo(i)
				
				if mapData[i].description == nil then
					-- correct because the mapData would be sorted at this point
					mapData[i].description = WORLD_MAP_LOCATIONS_DATA.mapData[i].description
				end
			end
			
			WORLD_MAP_LOCATIONS_DATA.mapData = mapData
		end
		
		if (not self.registeredWorldMapLocationsRefresh) then
			GAMEPAD_WORLD_MAP_LOCATIONS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
				if (newState == SCENE_SHOWING) then
					WORLD_MAP_LOCATIONS_DATA:RefreshLocationList()
					GAMEPAD_WORLD_MAP_LOCATIONS:BuildLocationList()
				elseif (newState == SCENE_HIDDEN) then
				end
			end)
			self.registeredWorldMapLocationsRefresh = true
		end
		
		--WORLD_MAP_LOCATIONS_DATA:RefreshLocationList()
	end
end

function ArchEnhancedMap:LocationDataReset()
	if (WORLD_MAP_LOCATIONS_DATA and WORLD_MAP_LOCATIONS_DATA.mapData) then
		if (self.OrigRefreshLocationList) then
			WORLD_MAP_LOCATIONS_DATA.RefreshLocationList = self.OrigRefreshLocationList
		else
			ReloadUI()
		end
	end
end

function ArchEnhancedMap:TeleportInitialize()
	-- BEGIN EasyTravel (Permission granted by author)
	local L = EasyTravel_AEM.Localization
	local JumpHelper = EasyTravel_AEM.JumpHelper
	
	local CANNOT_JUMP_TO = {
		[1] = true, -- Tamriel
		[24] = true, -- The Aurbis
		[GetCyrodiilMapIndex()] = true,
		[GetImperialCityMapIndex()] = true,
	}
	
	local function AttemptJumpTo(mapIndex)
		if(CANNOT_JUMP_TO[mapIndex]) then
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, L["INVALID_TARGET_ZONE"])
			return false
		end
		
		ZO_WorldMap_SetMapByIndex(mapIndex)
		local targetZone = GetZoneNameByIndex(GetCurrentMapZoneIndex())
		JumpHelper:JumpTo(targetZone)
		
		return true
	end
	
	EasyTravel_AEM.JumpTo = AttemptJumpTo
	-- END of EasyTravel

	local WORLD_MAP_LOCATIONS_JUMP_LIST_TRIGGER = 4 --7
	
	GAMEPAD_WORLD_MAP_LOCATIONS.InitializeKeybindDescriptor = function()
		GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor =
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			{
				alignment = KEYBIND_STRIP_ALIGN_LEFT,
				keybind = "UI_SHORTCUT_PRIMARY",
				name = GetString(SI_GAMEPAD_SELECT_OPTION),
				callback = function()
					if GAMEPAD_WORLD_MAP_LOCATIONS.selectedData then
						ZO_WorldMap_SetMapByIndex(GAMEPAD_WORLD_MAP_LOCATIONS.selectedData.index)
						PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
					end
				end,
				visible = function()
					return GAMEPAD_WORLD_MAP_LOCATIONS.selectedData ~= nil
				end
			},
			{
				alignment = KEYBIND_STRIP_ALIGN_RIGHT,
				keybind = "UI_SHORTCUT_TERTIARY",
				name = "Scroll To Zone",
				callback = function()
					OpenEnhancedMapLocations()
				
					ChangeSelectedLocationsListToCurrentMap()
				end
			},
			alignment = KEYBIND_STRIP_ALIGN_RIGHT,
			{
				alignment = KEYBIND_STRIP_ALIGN_RIGHT,
				keybind = "UI_SHORTCUT_LEFT_STICK",
				name = "Refresh", --GetString(SI_GAMEPAD_WORLD_SELECT_REFRESH),
				callback = function()
					PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
					GAMEPAD_WORLD_MAP_LOCATIONS:SetListDisabled(true)
					WORLD_MAP_LOCATIONS_DATA:RefreshLocationList()
					GAMEPAD_WORLD_MAP_LOCATIONS:BuildLocationList()
					GAMEPAD_WORLD_MAP_LOCATIONS:SetListDisabled(false)
					PlaySound(SOUNDS.DIALOG_SHOW)
				end,
				visible = function()
					return GAMEPAD_WORLD_MAP_LOCATIONS.selectedData ~= nil
				end
			},
			{
				alignment = KEYBIND_STRIP_ALIGN_RIGHT,
				keybind = "UI_SHORTCUT_SECONDARY",
				name = "Teleport", --GetString(SI_GAMEPAD_SELECT_OPTION),
				callback = function()
					if GAMEPAD_WORLD_MAP_LOCATIONS.selectedData then
						PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
						
						if (EasyTravel_AEM) then
							if (not IsInCampaign() and EasyTravel_AEM.JumpTo(GAMEPAD_WORLD_MAP_LOCATIONS.selectedData.index)) then
								--SCENE_MANAGER:Hide(GAMEPAD_WORLD_MAP_SCENE:GetName())
							elseif (IsInCampaign()) then
								CHAT_SYSTEM:AddMessage(ZO_ERROR_COLOR:Colorize(GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA)))
								
								PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
							end
						elseif (not EasyTravel_AEM) then
							-- No EasyTravel_AEM
						end
					end
				end,
				visible = function()
					return GAMEPAD_WORLD_MAP_LOCATIONS.selectedData ~= nil and not IsInCampaign()
				end
			},
			{
				keybind = "UI_SHORTCUT_LEFT_TRIGGER",
				ethereal = true,
				callback = function()
					if GAMEPAD_WORLD_MAP_LOCATIONS.list.selectedIndex == nil then return end
					
					local newSelectedIndex = (GAMEPAD_WORLD_MAP_LOCATIONS.list.selectedIndex - WORLD_MAP_LOCATIONS_JUMP_LIST_TRIGGER)
				
					if newSelectedIndex < 1 then
						newSelectedIndex = 1
					elseif newSelectedIndex > #GAMEPAD_WORLD_MAP_LOCATIONS.list.dataList then
						newSelectedIndex = #GAMEPAD_WORLD_MAP_LOCATIONS.list.dataList
					end
					
					GAMEPAD_WORLD_MAP_LOCATIONS.list:SetSelectedIndex(newSelectedIndex)
				end,
			},
			{
				keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
				ethereal = true,
				callback = function()
					if GAMEPAD_WORLD_MAP_LOCATIONS.list.selectedIndex == nil then return end
					
					local newSelectedIndex = (GAMEPAD_WORLD_MAP_LOCATIONS.list.selectedIndex + WORLD_MAP_LOCATIONS_JUMP_LIST_TRIGGER)
					
					if newSelectedIndex < 1 then
						newSelectedIndex = 1
					elseif newSelectedIndex > #GAMEPAD_WORLD_MAP_LOCATIONS.list.dataList then
						newSelectedIndex = #GAMEPAD_WORLD_MAP_LOCATIONS.list.dataList
					end
					
					GAMEPAD_WORLD_MAP_LOCATIONS.list:SetSelectedIndex(newSelectedIndex)
				end,
			},
		}
		ZO_Gamepad_AddBackNavigationKeybindDescriptors(GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, ZO_WorldMapInfo_OnBackPressed)
	end
	
	GAMEPAD_WORLD_MAP_LOCATIONS_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
		if (newState == SCENE_SHOWING) then
			if not GAMEPAD_WORLD_MAP_LOCATIONS.listDisabled then
				GAMEPAD_WORLD_MAP_LOCATIONS.list:Activate()
			end
			GAMEPAD_WORLD_MAP_LOCATIONS.list:RefreshVisible()
			
			KEYBIND_STRIP:RemoveKeybindButtonGroup(GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor)
			GAMEPAD_WORLD_MAP_LOCATIONS:InitializeKeybindDescriptor()
			
			KEYBIND_STRIP:AddKeybindButtonGroup(GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor)
		elseif (newState == SCENE_HIDDEN) then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(GAMEPAD_WORLD_MAP_LOCATIONS.keybindStripDescriptor)
			GAMEPAD_WORLD_MAP_LOCATIONS.list:Deactivate()
		end
	end)
end

function ArchEnhancedMap:HousesInitialize()
	GAMEPAD_WORLD_MAP_HOUSES.InitializeKeybindDescriptor = function()
		GAMEPAD_WORLD_MAP_HOUSES.keybindStripDescriptor =
		{
			alignment = KEYBIND_STRIP_ALIGN_LEFT,
			
			{
				keybind = "UI_SHORTCUT_PRIMARY",
				
				name = GetString(SI_GAMEPAD_SELECT_OPTION),
				
				callback = function()
					local targetData = GAMEPAD_WORLD_MAP_HOUSES.list:GetTargetData()
					ZO_WorldMap_SetMapByIndex(targetData.mapIndex)
					ZO_WorldMap_PanToWayshrine(targetData.nodeIndex)
					PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
				end,
				
				visible = function()
					local targetData = GAMEPAD_WORLD_MAP_HOUSES.list:GetTargetData()
					return targetData ~= nil
				end
			},
			
			{
				keybind = "UI_SHORTCUT_SECONDARY",
				
				name = GetString(SI_GAMEPAD_WORLD_MAP_TRAVEL),
				
				callback = function()
					local targetData = GAMEPAD_WORLD_MAP_HOUSES.list:GetTargetData()
					ZO_WorldMap_SetMapByIndex(targetData.mapIndex)
					ZO_WorldMap_PanToWayshrine(targetData.nodeIndex)
					
					RequestJumpToHouse(targetData.houseId)
				
					PlaySound(SOUNDS.MAP_LOCATION_CLICKED)
					
					ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat("Traveling to <<1>> (in zone <<2>>)", targetData.houseName, targetData.foundInZoneName))
				end,
				
				visible = function()
					local targetData = GAMEPAD_WORLD_MAP_HOUSES.list:GetTargetData()
					return targetData ~= nil
				end
			},
		}
		
		ZO_Gamepad_AddBackNavigationKeybindDescriptors(GAMEPAD_WORLD_MAP_HOUSES.keybindStripDescriptor, GAME_NAVIGATION_TYPE_BUTTON, ZO_WorldMapInfo_OnBackPressed)
	end
	
	GAMEPAD_WORLD_MAP_HOUSES:GetFragment():RegisterCallback("StateChange", function(oldState, newState)
		if (newState == SCENE_SHOWING) then
			if not GAMEPAD_WORLD_MAP_HOUSES.listDisabled then
				GAMEPAD_WORLD_MAP_HOUSES.list:Activate()
			end
			GAMEPAD_WORLD_MAP_HOUSES.list:RefreshVisible()
			
			KEYBIND_STRIP:RemoveKeybindButtonGroup(GAMEPAD_WORLD_MAP_HOUSES.keybindStripDescriptor)
			GAMEPAD_WORLD_MAP_HOUSES:InitializeKeybindDescriptor()
			
			KEYBIND_STRIP:AddKeybindButtonGroup(GAMEPAD_WORLD_MAP_HOUSES.keybindStripDescriptor)
		elseif (newState == SCENE_HIDDEN) then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(GAMEPAD_WORLD_MAP_HOUSES.keybindStripDescriptor)
			GAMEPAD_WORLD_MAP_HOUSES.list:Deactivate()
		end
	end)
end

function ChangeSelectedLocationsListToCurrentMap()
	--local mapZoneIndex = GetCurrentMapZoneIndex()
	local mapZoneName = GetZoneNameByIndex(GetCurrentMapZoneIndex())
	for i = 1, #GAMEPAD_WORLD_MAP_LOCATIONS.list.dataList do
		local entry = GAMEPAD_WORLD_MAP_LOCATIONS.list.dataList[i]
		if (entry ~= nil and entry.dataSource ~= nil and entry.dataSource.index ~= nil and entry.dataSource.originalLocationName ~= nil and mapZoneName == entry.dataSource.originalLocationName --[[entry.dataSource.index == mapZoneIndex]]) then
			GAMEPAD_WORLD_MAP_LOCATIONS.list:SetSelectedIndex(i)
			break
		end
	end
end

function ArchEnhancedMap:DefineColors()
	self.color = {}
	self.color.yellow = "|cFFFF00"
	self.color.lightYellow = "|cFFFFCC"
	self.color.green = "|c00FF00"
	self.color.magenta = "|cFF00FF"
	self.color.red = "|cFF0000"
	self.color.darkOrange = "|cFFA500"
	self.color.iconYellow = "|cFFFF33"
	self.color.iconOrange = "|cFF6600"
	self.color.grey = "|c626255"
	self.color.brightOrange = "|cE68A00"
end

function ArchEnhancedMap:Initialize(addonName)
	self:DefineColors()
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHENHANCEDMAP_REM_WP", self.color.darkOrange .. "Remove Waypoint|r " .. self.color.magenta .. "- Remove Waypoint")
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHENHANCEDMAP_TOG_WP", self.color.darkOrange .. "Toggle Waypoint|r " .. self.color.magenta .. "- Toggle Waypoint (via Waypointit)")
	
	ZO_CreateStringId("SI_BINDING_NAME_ARCHENHANCEDMAP_OPEN_LOC_WP", self.color.darkOrange .. "Open Map Locations|r " .. self.color.magenta .. "- Open Map to the locations selector (teleport).")
	
	self.name = addonName
	
	self.sv = {}
	
	local defaults = {
		mapPinScale = 1.0,
		mapPinScaleEnabled = false,
		mapPinScaleMaxValue = 128,
		mapPinsOriginalSize = {},
		mapPinsOriginalAreSaved = false,
		mapPinScaleOnlyFactoryDefault = true,
		teleportEnabled = true,
		locationSortEnabled = true,
	}
	
	self.sv = ZO_SavedVars:New(self.name .. "_SavedVariables", 1.1, nil, defaults)
	
	self:SetupOptions(self.name)
	
	self.registeredWorldMapLocationsRefresh = false
	
	if self.sv.mapPinScaleEnabled then
		self:ScaleMapPins()
	end
	
	if self.sv.teleportEnabled then
		self:TeleportInitialize()
	end
	
	if self.sv.locationSortEnabled then
		self:LocationDataInitialize()
	end
	
	self:HookShowOnMap()
	
	self:HousesInitialize()
	
	self:RegisterSlashCommands()
end

local function ArchEnhancedMap_Init(eventType, addonName)
	if addonName ~= "ArchEnhancedMap" then
		return
	end
	
	ArchEnhancedMap:Initialize(addonName)
end

EVENT_MANAGER:RegisterForEvent("ArchEnhancedMapInit", EVENT_ADD_ON_LOADED, ArchEnhancedMap_Init)
