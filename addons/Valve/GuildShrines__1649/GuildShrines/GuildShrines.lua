local addon = {
	name = "GuildShrines",
	title = "GuildShrines",
	version = "1.7.1",
	author = "Valve",
	defaults = { 
		showWayshrines = false,
		showDungeons = false,
		showTrials = false,
		showUnknownPOI = false,
		showUnknownHouses = false,
		showUnownedHouses = true,
		showUncollected = false,
		worldHideWayshrines = false
	},
}

-- tamriel map index
local TAMRIEL_MAP = 1

local function OnAddonLoaded(event, name)
	if name ~= addon.name then return end
	EVENT_MANAGER:UnregisterForEvent(addon.name, EVENT_ADD_ON_LOADED)
	addon.sv = ZO_SavedVars:NewAccountWide(addon.name .. "_dat", 1, nil, addon.defaults)
	addon:Initialise()
end

function addon:ShrineEnabled(poiType)
	-- only set wayshrines as known for the world map, otherwise use the poi pins
	if poiType ~= POI_TYPE_HOUSE and GetCurrentMapIndex() ~= TAMRIEL_MAP then return false end
	if poiType == POI_TYPE_GROUP_DUNGEON or poiType == POI_TYPE_STANDARD then 
		return self.sv.showDungeons
	elseif poiType == POI_TYPE_OBJECTIVE or poiType == POI_TYPE_ACHIEVEMENT then
		return self.sv.showTrials
	elseif poiType == POI_TYPE_WAYSHRINE then
		-- only enable unknown wayshrines for the Tamriel (world map) otherwise use the poi interest pins
		return self.sv.showWayshrines and GetCurrentMapIndex() == TAMRIEL_MAP
	elseif poiType == POI_TYPE_HOUSE then
		return self.sv.showUnownedHouses and self.sv.showUnknownHouses
	else return true end
end

function addon:PoiEnabled(icon, actualValue)
	-- some houses, dungeons and trials (but not all) have a POI pin beneath them
	-- we can use display these (when enabled) for when we're not on the Tamriel (world) map
	if not icon then return actualValue end
	if string.find(icon, "poi_groupinstance") then
		return self.sv.showDungeons or acualValue
	elseif string.find(icon, "poi_raiddungeon") or string.find(icon, "poi_solotrial") then
		return self.sv.showTrials or actualValue
	elseif string.find(icon, "poi_group_house") then
		return false
	elseif string.find(icon, "poi_wayshrine") then
		return self.sv.showWayshrines or actualValue 
	else
		return self.sv.showUnknownPOI or actualValue
	end
end

function addon:Initialise()
	if not LibAddonMenu2 then return end
	local LAM2 = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = addon.name,
		displayName = addon.title,
		author = addon.author,
		version = addon.version,
		registerForRefresh = true,
		registerForDefaults = true,
		website = "http://www.esoui.com/downloads/info1649-GuildShrines.html"
	}
	LAM2:RegisterAddonPanel(addon.name, panelData)
	
	local optionsTable = {}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_GS_DESC_HEADER)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_GS_ADDON_DESC)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_GS_ADDON_WARNING)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_GS_EYEVEA_HEADER)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_GS_EYEVEA_DESC)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_GS_FORGE_HEADER)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_GS_FORGE_DESC)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_GS_WAYSHRINES_HEADER)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_GS_WAYSHRINES_DESC)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNKNOWN_WAYSHRINES_OPT),
			tooltip = GetString(SI_GS_UNKNOWN_WAYSHRINES_OPT_TOOLTIP),
			getFunc = function() return self.sv.showWayshrines end,
			setFunc = function(value) self.sv.showWayshrines = value end,
			default = self.defaults.showWayshrines
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNKNOWN_DUNGEONS_OPT),
			tooltip = GetString(SI_GS_UNKNOWN_DUNGEONS_OPT_TOOLTIP),
			getFunc = function() return self.sv.showDungeons end,
			setFunc = function(value) self.sv.showDungeons = value end,
			default = self.defaults.showDungeons
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNKNOWN_TRIALS_OPT),
			tooltip = GetString(SI_GS_UNKNOWN_TRIALS_OPT_TOOLTIP),
			getFunc = function() return self.sv.showTrials end,
			setFunc = function(value) self.sv.showTrials = value end,
			default = self.defaults.showTrials
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNKNOWN_HOUSE_OPT),
			tooltip = GetString(SI_GS_UNKNOWN_HOUSE_OPT_TOOLTIP),
			getFunc = function() return self.sv.showUnknownHouses end,
			setFunc = function(value) self.sv.showUnknownHouses = value end,
			default = self.defaults.showUnknownHouses
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNOWNED_HOUSES_OPT),
			tooltip = GetString(SI_GS_UNOWNED_HOUSES_OPT_TOOLTIP),
			getFunc = function() return self.sv.showUnownedHouses end,
			setFunc = function(value) self.sv.showUnownedHouses = value end,
			default = self.defaults.showUnownedHouses
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_WORLD_HIDE_SHRINES_OPT),
			tooltip = GetString(SI_GS_WORLD_HIDE_SHRINES_OPT_TOOLTIP),
			getFunc = function() return self.sv.worldHideWayshrines end,
			setFunc = function(value) self.sv.worldHideWayshrines = value end,
			default = self.defaults.worldHideWayshrines
		}
	optionsTable[#optionsTable+1] =
		{
			type = "header",
			name = GetString(SI_GS_OBJECTIVES_HEADER)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "description",
			text = GetString(SI_GS_OBJECTIVES_DESC)
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNKNOWN_OBJECTIVES_OPT),
			tooltip = GetString(SI_GS_UNKNOWN_OBJECTIVES_OPT_TOOLTIP),
			getFunc = function() return self.sv.showUnknownPOI end,
			setFunc = function(value) self.sv.showUnknownPOI = value end,
			default = self.defaults.showUnknownPOI
		}
	optionsTable[#optionsTable+1] =
		{
			type = "checkbox",
			name = GetString(SI_GS_UNDISCOVERED_SKYSHARDS_OBJECTIVES_OPT),
			tooltip = GetString(SI_GS_UNDISCOVERED_SKYSHARDS_OPT_TOOLTIP),
			getFunc = function() return self.sv.showUncollected end,
			setFunc = function(value) self.sv.showUncollected = value end,
			default = self.defaults.showUncollected
		}
	LAM2:RegisterOptionControls(addon.name, optionsTable)

	-- lookup tables
	local unknownIcons = {
		[POI_TYPE_OBJECTIVE] = "esoui/art/icons/poi/poi_solotrial_incomplete.dds",
		[POI_TYPE_WAYSHRINE] = "esoui/art/icons/poi/poi_wayshrine_incomplete.dds",
		[POI_TYPE_STANDARD] = "esoui/art/icons/poi/poi_groupinstance_incomplete.dds",
		[POI_TYPE_ACHIEVEMENT] = "esoui/art/icons/poi/poi_raiddungeon_incomplete.dds",
		[POI_TYPE_ACHIEVEMENT_COMPONENT] = "",--unused as of now?
		[POI_TYPE_PUBLIC_DUNGEON] = "esoui/art/icons/poi/poi_publicdungeon_incomplete.dds",
		[POI_TYPE_GROUP_DUNGEON] = "esoui/art/icons/poi/poi_groupinstance_incomplete.dds",
		[POI_TYPE_HOUSE] = "/esoui/art/icons/poi/poi_group_house_unowned.dds"
	}

	local cyrodiilWayshrines = {
		[199] = ALLIANCE_DAGGERFALL_COVENANT,
		[170] = ALLIANCE_DAGGERFALL_COVENANT,
		[202] = ALLIANCE_EBONHEART_PACT,
		[203] = ALLIANCE_EBONHEART_PACT,
		[200] = ALLIANCE_ALDMERI_DOMINION,
		[201] = ALLIANCE_ALDMERI_DOMINION
	}

	local harborages = {
		[210] = true,
		[211] = true,
		[212] = true
	}
	
	local dungeonShrines = {
		[POI_TYPE_GROUP_DUNGEON] = true,
		[POI_TYPE_OBJECTIVE] = true,
		[POI_TYPE_ACHIEVEMENT] = true,
		[POI_TYPE_STANDARD] = true
	}

	-- zos utility functions
	local zos_GetSkyshardDiscoveryStatus = GetSkyshardDiscoveryStatus
	local zos_GetPOIMapInfo = GetPOIMapInfo
	local zos_GetFastTravelNodeInfo = GetFastTravelNodeInfo

	-- wayshrine pin functions
	local zos_wayshrineRecallName = ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][1].name
	local zos_wayshrineRecallCallback = ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][1].callback
	local zos_wayshrineFastTravelName = ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][2].name
	local zos_wayshrineFastTravelCallback = ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][2].callback
	local zos_wayshrineTooltipCreator = ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator

	-- constants
	-- guild wayshrine nodeIndexes
	local EYEVEA_SHRINE = 215
	local EARTH_FORGE_SHRINE = 221

	GetSkyshardDiscoveryStatus = function(...) -- skyshardId
		local values = {zos_GetSkyshardDiscoveryStatus(...)} -- skyshardDiscoveryStatus
		if self.sv.showUncollected and values[1] == SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED then
			values[1] = SKYSHARD_DISCOVERY_STATUS_DISCOVERED
		end
		return unpack(values)
	end

	-- zoneIndex, poiIndex
	GetPOIMapInfo = function(...)
		-- xLoc, zLoc, poiPinType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby
		local values = {zos_GetPOIMapInfo(...)}
		values[7] = self:PoiEnabled(values[4], values[7])
		values[8] = self:PoiEnabled(values[4], values[8])
		return unpack(values)
	end

	GetFastTravelNodeInfo = function(...)
		local nodeIndex = select(1, ...)
		-- known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap, linkedCollectibleIsLocked
		local values = {zos_GetFastTravelNodeInfo(...)}
		-- if it is non-discoverable or is a harborage, early out
		if harborages[nodeIndex] then return unpack(values) end
		if not values[1] and not values[6] and values[7] == POI_TYPE_OBJECTIVE then return unpack(values) end
		if nodeIndex == EYEVEA_SHRINE then --Eyevea node index
			if GetCurrentMapIndex() == TAMRIEL_MAP then --Tamriel map
				values[8] = true
				-- Note: the original Tamriel coordinates (x: 0.071474000811577, y: 0.6091747879982)
				-- have been shifted to be off the map as part of the High Isle update
				if not AWM then -- don't update wayshrine positioning if AccurateWorldMap is installed
					values[3] = 0.08398
					values[4] = 0.6077
				end
			end
		elseif nodeIndex == EARTH_FORGE_SHRINE then --The Earth Forge node index
			if GetCurrentMapIndex() == TAMRIEL_MAP then --Tamriel map
				values[8] = true
				if not AWM then -- don't update wayshrine positioning if AccurateWorldMap is installed
					values[3] = 0.3337188065052
					values[4] = 0.27581998705864
				end
			end
		end
		if not values[1] and self:ShrineEnabled(values[7]) then
			if not cyrodiilWayshrines[nodeIndex] or cyrodiilWayshrines[nodeIndex] == GetUnitAlliance("player") then
				values[1] = true
				values[5] = unknownIcons[values[7]]
				-- remove glow from all undiscovered non-house wayshrines since they cannot be travelled to
				if values[7] ~= POI_TYPE_HOUSE then
					values[6] = nil
				end
			end
		elseif values[7] == POI_TYPE_HOUSE then
			-- we can always recall to unknown houses so mark these as known if enabled
			-- although we do have to manually set the icon for undiscovered houses
			if not values[1] and self.sv.showUnknownHouses then
				values[1] = true
				values[5] = unknownIcons[POI_TYPE_HOUSE]
			elseif values[1] and not self.sv.showUnownedHouses then
				if values[5] == unknownIcons[POI_TYPE_HOUSE] then
					values[1] = false
				end
			end
		end
		if (self.sv.worldHideWayshrines and GetCurrentMapIndex() == TAMRIEL_MAP and nodeIndex ~= EYEVEA_SHRINE and nodeIndex ~= EARTH_FORGE_SHRINE) then
			if not dungeonShrines[values[7]] then
				values[1] = false
			end
		end
		return unpack(values)
	end

	ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][1].name = function(...) --Recall
		local pin = select(1, ...)
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local known, recallLocationName = zos_GetFastTravelNodeInfo(nodeIndex)
		if known and nodeIndex ~= EYEVEA_SHRINE and nodeIndex ~= EARTH_FORGE_SHRINE then
			return zos_wayshrineRecallName(...)
		else
			return recallLocationName
		end
	end

	ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][1].callback = function(...) --Recall
		local pin = select(1, ...)
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local known = zos_GetFastTravelNodeInfo(nodeIndex)
		-- Eyevea and the Earth Forge can only be travelled to from wayshrines!
		if nodeIndex == EYEVEA_SHRINE or nodeIndex == EARTH_FORGE_SHRINE or not known then return
		else zos_wayshrineRecallCallback(...) end
	end

	ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][2].name = function(...) --Fast Travel
		local pin = select(1, ...)
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local known = zos_GetFastTravelNodeInfo(nodeIndex)
		if known then return zos_wayshrineFastTravelName(...)
		else return travelLocationName end
	end

	ZO_MapPin.PIN_CLICK_HANDLERS[1][MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE][2].callback = function(...) --Fast Travel
		local pin = select(1, ...)
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local known = zos_GetFastTravelNodeInfo(nodeIndex)
		if not known then return end
		zos_wayshrineFastTravelCallback(...)
	end
		
	ZO_MapPin.TOOLTIP_CREATORS[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE].creator = function(...)
		local pin = select(1, ...)
		local nodeIndex = pin:GetFastTravelNodeIndex()
		local known, name, _, _, _, _, poiType = zos_GetFastTravelNodeInfo(nodeIndex)
		if (nodeIndex ~= EYEVEA_SHRINE and nodeIndex ~= EARTH_FORGE_SHRINE and known) or (ZO_Map_GetFastTravelNode() and known) then
			return zos_wayshrineTooltipCreator(...)
		end
		if not known then
			InformationTooltip:AddLine(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, name), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()) -- Wayshrine Name Only (unknown wayshrine)
			return
		end
		local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
		ZO_WorldMapMouseoverName.owner = "fastTravelWayshrine"
		ZO_WorldMapMouseoverName:SetText(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, name))
		if not IsInGamepadPreferredMode() then
			InformationTooltip:AddLine(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, name), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
			if nodeIndex == EYEVEA_SHRINE then
				InformationTooltip:AddLine(GetString(SI_GS_EYEVEA_RECALL), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
			else
				InformationTooltip:AddLine(GetString(SI_GS_FORGE_RECALL), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
			end
		else
			local lineSection = ZO_MapLocationTooltip_Gamepad.tooltip:AcquireSection(ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapMoreQuestsContentSection"))
			lineSection:AddLine(name, ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapLocationTooltipContentLabel"), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("gamepadElderScrollTooltipContent"))
			if nodeIndex == EYEVEA_SHRINE then
				lineSection:AddLine(GetString(SI_GS_EYEVEA_RECALL), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapLocationTooltipContentLabel"), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("gamepadElderScrollTooltipContent"))
			else
				lineSection:AddLine(GetString(SI_GS_FORGE_RECALL), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("mapLocationTooltipContentLabel"), ZO_MapLocationTooltip_Gamepad.tooltip:GetStyle("gamepadElderScrollTooltipContent"))
			end
			ZO_MapLocationTooltip_Gamepad.tooltip:AddSection(lineSection)
		end
	end
end

EVENT_MANAGER:RegisterForEvent(addon.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

GUILD_SHRINES = addon