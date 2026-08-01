--[[
-------------------------------------------------------------------------------
-- World Map Wayshrines Controller, by Erian Kalil (& TaxTalis)
-------------------------------------------------------------------------------

This software is based on the addon NoThankYou, by Ayantir ( https://www.esoui.com/downloads/info865-Nothankyou.html ) . 

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

local ADDON_NAME = "WorldMapWayshrinesController"
local ADDON_VERSION = "1.8"
local ADDON_AUTHOR = "|c66ccffErian Kalil|r & TaxTalis, |ccc0000t|r.vicson"
local ADDON_WEBSITE = "https://www.esoui.com/downloads/info2381-WorldMapWayshrinesController.html"

local SV

local defaults = {
	hideTamrielWayhsrines = 0,
	hideTamrielDungeons = false,
	hideTamrielTrials = false,
	unownedHouses = 0,
	ownedHouses = 0,
	hideTamriel = false,
	NodeOverwrite = {}
}

local arena = {
	[250] = true, -- Maelstrom Arena
	[270] = true, -- Dragonstar Arena
	[378] = true, -- Blackrose Prison
	[457] = true, -- Vateshran Hollows
}

local function RemovePinsFromMaps()

	local isCapitalWayshrine = {
		[28]  = true, -- Deshaan: Mournhold
		[33]  = true, -- Bangkorai: Evermore
		[43]  = true, -- Alik'r Desert: Sentinel
		[48]  = true, -- Shadowfen: Stormhold
		[55]  = true, -- Rivenspire: Stornhelm
		[56]  = true, -- Stormhaven: Wayrest
		[62]  = true, -- Glenumbra: Daggerfall
		[65]  = true, -- Stonefalls: Davon's Watch
		[67]  = true, -- Stonefalls: Ebonheart
		[87]  = true, -- Eastmarch: Windhelm
		[102] = true, -- Malabal Tor: Velyn Harbor
		[106] = true, -- Malabal Tor: Baandari TradingPost
		[109] = true, -- The Rift: Riften
		[121] = true, -- Auridon: Skywatch
		[138] = true, -- Stros M'Kai: Port Hunding
		[142] = true, -- Khenarthi's Roost: Mistral
		[143] = true, -- Greenshade: Marbruk
		[162] = true, -- Reaper's March: Rawl'kha
		[172] = true, -- Bleakrock Isle: Bleakrock
		[173] = true, -- Bal Foyen: Dhalmora
		[177] = true, -- Auridon: Vulkheel Guard
		[181] = true, -- Betnikh: Stonetooth
		[214] = true, -- Grahtwood: Elden Root
		[215] = true, -- Eyevea: Eyevea
		[220] = true, -- Craglorn: Belkarth
		[244] = true, -- Wrothgar: Orsinium
		[251] = true, -- Gold Coast: Anvil
		[252] = true, -- Gold Coast: Kvatch
		[255] = true, -- Hew's Bane: Abah's Landing
		[284] = true, -- Vvardenfell: Vivec City
		[355] = true, -- Summerset: Alinor
		[374] = true, -- Murkmire: Lilmoth
		[382] = true, -- Northern Elsweyr: Rimmen
		[402] = true, -- Southern Elsweyr: Senchal
		[421] = true, -- Western Skyrim: Solitude
		[449] = true, -- Reach: Markarth
		[458] = true, -- BlackWood: Leyawiin
		[513] = true, -- High Isle: Gonfalon Square Wayshrine
		[536] = true, -- Telvanni Peninsula: Necrom
		[558] = true, -- West Weald: Skingrad City
	}

	local unownedHouse = "/esoui/art/icons/poi/poi_group_house_unowned.dds"
    local   ownedHouse = "/esoui/art/icons/poi/poi_group_house_owned.dds"
    local    glowHouse = "/esoui/art/icons/poi/poi_group_house_glow.dds"

	local originalTravelNodeFun = GetFastTravelNodeInfo
	local originalPOIFun = GetPOIMapInfo

	GetFastTravelNodeInfo = function(nodeIndex, ...)
	
		local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = originalTravelNodeFun(nodeIndex, ...)

		if GetMapType() == MAPTYPE_WORLD then
			-- check if node is known and in overwrite
			if(SV.NodeOverwrite ~= nil and SV.NodeOverwrite[nodeIndex] ~= nil) then
				isShownInCurrentMap = known and SV.NodeOverwrite[nodeIndex]
			else
				-- Hide everything on Tamriel map
				if SV.hideTamriel then
					isShownInCurrentMap = false
				else
					if(poiType == POI_TYPE_WAYSHRINE) then
						-- Wayshrines on Tamrial map
						if ((SV.hideTamrielWayhsrines == 1 and not isCapitalWayshrine[nodeIndex]) -- hide execpt capitals
							or SV.hideTamrielWayhsrines == 2) then -- hide all 
					-- Wayshrines on Tamriel map
						isShownInCurrentMap = false
						end
					elseif(poiType == POI_TYPE_GROUP_DUNGEON or (arena[nodeIndex] ~= nil and arena[nodeIndex])) then
						-- Dungeons (and arenas) on Tamriel map
						if(SV.hideTamrielDungeons) then
							isShownInCurrentMap = false
						end
					elseif(poiType == POI_TYPE_ACHIEVEMENT) then -- POI_TYPE_ACHIEVEMENT = trials
						-- Trials on Tamriel map
						if(SV.hideTamrielTrials == true) then 
							isShownInCurrentMap = false
						end
					elseif(poiType == POI_TYPE_HOUSE) then
						-- Unowned Houses
						if(SV.ownedHouses > 0 and icon == ownedHouse) then
							isShownInCurrentMap = false
						end
						-- Owned Houses
						if(SV.unownedHouses > 0 and icon == unownedHouse) then
							isShownInCurrentMap = false
						end
					end
				end
			end
		else
			--	Hide houses even on zone map
			if(poiType == POI_TYPE_HOUSE) then
				if(SV.NodeOverwrite ~= nil and SV.NodeOverwrite[nodeIndex] ~= nil) then
					isShownInCurrentMap = known and SV.NodeOverwrite[nodeIndex]
				else
					-- Owned Houses
					if SV.ownedHouses == 2 and icon == ownedHouse then
						isShownInCurrentMap = false
					end
					-- Unowned Houses
					if SV.unownedHouses == 2 and icon == unownedHouse then
						isShownInCurrentMap = false
					end
				end
			end
		end
		
		
		return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked
	end
	
	GetPOIMapInfo = function(zoneIndex, poiIndex, ...)
	
		local normalizedX, normalizedZ, poiType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby = originalPOIFun(zoneIndex, poiIndex, ...)
		
		--Unowned Houses
			--Hide Everything
		if SV.unownedHouses == 2 and icon == unownedHouse then
			isDiscovered = false
			isNearby = false
		end

		return normalizedX, normalizedZ, poiType, icon, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered, isNearby
	end
end

local function BuildSettingsMenu()

	local panelData = {
		type = "panel",
		name = "World Map Wayshrines Controller",
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		slashCommand = "/wmwc",
		registerForRefresh = true,
		registerForDefaults = true,
		website = ADDON_WEBSITE,
	}

	local optionsData = {
		{
			type = "checkbox",
			name = GetString(WMWC_TAMRIEL),
			tooltip = GetString(WMWC_TAMRIEL_TOOLTIP),
			getFunc = function() return SV.hideTamriel end,
			setFunc = function(value) SV.hideTamriel = value end,
			default = defaults.hideTamriel,
		},
		{
			type = "checkbox",
			name = GetString(WMWC_DUNGEONS),
			tooltip = GetString(WMWC_DUNGEONS_TOOLTIP),
			getFunc = function() return SV.hideTamrielDungeons end,
			setFunc = function(value) SV.hideTamrielDungeons = value end,
			default = defaults.hideTamrielDungeons,
			disabled = function() return SV.hideTamriel end,
		},
		{
			type = "checkbox",
			name = GetString(WMWC_TRIALS),
			tooltip = GetString(WMWC_TRIALS_TOOLTIP),
			getFunc = function() return SV.hideTamrielTrials end,
			setFunc = function(value) SV.hideTamrielTrials = value end,
			default = defaults.hideTamrielTrials,
			disabled = function() return SV.hideTamriel end,
		},
		{
			type = "dropdown",
			name = GetString(WMWC_WAYSHRINES),
			tooltip = GetString(WMWC_WAYSHRINES_TOOLTIP),
			choices = {GetString(WMWC_WAYSHRINE_OPTION_0), GetString(WMWC_WAYSHRINE_OPTION_1), GetString(WMWC_WAYSHRINE_OPTION_2)},
			choicesValues = {0, 1, 2},
			getFunc = function() return SV.hideTamrielWayhsrines end,
			setFunc = function(value) SV.hideTamrielWayhsrines = value end,
			default = defaults.hideTamrielWayhsrines,
			disabled = function() return SV.hideTamriel end,
		},
		{
			type = "dropdown",
			name = GetString(WMWC_UNOWNED_HOUSES),
			tooltip = GetString(WMWC_UNOWNED_HOUSES_TOOLTIP),
			choices = {GetString(WMWC_HOUSES_OPTION_0), GetString(WMWC_HOUSES_OPTION_1), GetString(WMWC_HOUSES_OPTION_2)},
			choicesValues = {0, 1, 2},
			getFunc = function() return SV.unownedHouses end,
			setFunc = function(value) SV.unownedHouses = value end,
			default = defaults.unownedHouses,
		},
		{
			type = "dropdown",
			name = GetString(WMWC_OWNED_HOUSES),
			tooltip = GetString(WMWC_OWNED_HOUSES_TOOLTIP),
			choices = {GetString(WMWC_HOUSES_OPTION_0), GetString(WMWC_HOUSES_OPTION_1), GetString(WMWC_HOUSES_OPTION_2)},
			choicesValues = {0, 1, 2},
			getFunc = function() return SV.ownedHouses end,
			setFunc = function(value) SV.ownedHouses = value end,
			default = defaults.ownedHouses,
		},

	}
	
	-- Create NodeOverwrite dropdown lists
	local Wayshrines = {}
	Wayshrines.NodeIndex = {}
	Wayshrines.Names = {}
	local Dungeons = {}
	Dungeons.NodeIndex = {}
	Dungeons.Names = {}
	local Houses = {}
	Houses.NodeIndex = {}
	Houses.Names = {}
	local nodeIndex 
	for nodeIndex = 0, GetNumFastTravelNodes() do
		local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(nodeIndex)
		--	Wayshrines
		if(poiType == POI_TYPE_WAYSHRINE) then
			table.insert(Wayshrines.NodeIndex, nodeIndex)
			table.insert(Wayshrines.Names, name)
		-- trials, dungeons, arenas
		elseif(poiType == POI_TYPE_GROUP_DUNGEON or poiType == POI_TYPE_ACHIEVEMENT or (arena[nodeIndex] ~= nil and arena[nodeIndex])) then 
			table.insert(Dungeons.NodeIndex, nodeIndex)
			if(arena[nodeIndex] ~= nil and arena[nodeIndex]) then
				name = GetString(WMWC_ARENA) .. name
			end
			table.insert(Dungeons.Names, name)
		-- houses
		elseif(poiType == POI_TYPE_HOUSE) then 
			table.insert(Houses.NodeIndex, nodeIndex)
			table.insert(Houses.Names, name)
		end
	end
	
	local NodeOverwrite = {}
	NodeOverwrite.type = 'submenu'
	NodeOverwrite.name = GetString(WMWC_OVERWRITE)					
	NodeOverwrite.controls = {}
	local controls = {}
	controls = {
		type = "dropdown",
		name = GetString(WMWC_WSHonWM),
		choices = Wayshrines.Names,
		choicesValues = Wayshrines.NodeIndex,
		sort = "name-up",
		scrollable = true,
		getFunc = function() return WMWC_MENU_WAYSHRINE.data.selected end,
		setFunc = function(value) WMWC_MENU_WAYSHRINE.data.selected = value end,
		reference = "WMWC_MENU_WAYSHRINE"
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {
		type = "checkbox",
		name = GetString(WMWC_SHOW),
		tooltip = "",
		getFunc = function() return SV.NodeOverwrite[WMWC_MENU_WAYSHRINE.data.selected] == true end,
		setFunc = function(value) if(value) then SV.NodeOverwrite[WMWC_MENU_WAYSHRINE.data.selected] = true else SV.NodeOverwrite[WMWC_MENU_WAYSHRINE.data.selected] = nil end end,
		width = 'half',
		default = false,
		disabled = function() return WMWC_MENU_WAYSHRINE.data.selected == nil end
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {
		type = "checkbox",
		name = GetString(WMWC_HIDE),
		tooltip = "",
		getFunc = function() return SV.NodeOverwrite[WMWC_MENU_WAYSHRINE.data.selected] == false end,
		setFunc = function(value) if(value) then SV.NodeOverwrite[WMWC_MENU_WAYSHRINE.data.selected] = false else SV.NodeOverwrite[WMWC_MENU_WAYSHRINE.data.selected] = nil end end,
		width = 'half',
		default = false,
		disabled = function() return WMWC_MENU_WAYSHRINE.data.selected == nil end
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {}
	controls = {
		type = "dropdown",
		name = GetString(WMWC_DTAonWM),
		choices = Dungeons.Names,
		choicesValues = Dungeons.NodeIndex,
		sort = "name-up",
		scrollable = true,
		getFunc = function() return WMWC_MENU_DUNGEONS.data.selected end,
		setFunc = function(value) WMWC_MENU_DUNGEONS.data.selected = value end,
		reference = "WMWC_MENU_DUNGEONS"
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {
		type = "checkbox",
		name = GetString(WMWC_SHOW),
		tooltip = "",
		getFunc = function() return SV.NodeOverwrite[WMWC_MENU_DUNGEONS.data.selected] == true end,
		setFunc = function(value) if(value) then SV.NodeOverwrite[WMWC_MENU_DUNGEONS.data.selected] = true else SV.NodeOverwrite[WMWC_MENU_DUNGEONS.data.selected] = nil end end,
		width = 'half',
		default = false,
		disabled = function() return WMWC_MENU_DUNGEONS.data.selected == nil end
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {
		type = "checkbox",
		name = GetString(WMWC_HIDE),
		tooltip = "",
		getFunc = function() return SV.NodeOverwrite[WMWC_MENU_DUNGEONS.data.selected] == false end,
		setFunc = function(value) if(value) then SV.NodeOverwrite[WMWC_MENU_DUNGEONS.data.selected] = false else SV.NodeOverwrite[WMWC_MENU_DUNGEONS.data.selected] = nil end end,
		width = 'half',
		default = false,
		disabled = function() return WMWC_MENU_DUNGEONS.data.selected == nil end
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {}
	controls = {
		type = "dropdown",
		name = GetString(WMWC_HonWZM),
		choices = Houses.Names,
		choicesValues = Houses.NodeIndex,
		sort = "name-up",
		scrollable = true,
		getFunc = function() return WMWC_MENU_HOUSES.data.selected end,
		setFunc = function(value) WMWC_MENU_HOUSES.data.selected = value end,
		reference = "WMWC_MENU_HOUSES"
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {
		type = "checkbox",
		name = GetString(WMWC_SHOW),
		tooltip = "",
		getFunc = function() return SV.NodeOverwrite[WMWC_MENU_HOUSES.data.selected] == true end,
		setFunc = function(value) if(value) then SV.NodeOverwrite[WMWC_MENU_HOUSES.data.selected] = true else SV.NodeOverwrite[WMWC_MENU_HOUSES.data.selected] = nil end end,
		width = 'half',
		default = false,
		disabled = function() return WMWC_MENU_HOUSES.data.selected == nil end
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	controls = {
		type = "checkbox",
		name = GetString(WMWC_HIDE),
		tooltip = "",
		getFunc = function() return SV.NodeOverwrite[WMWC_MENU_HOUSES.data.selected] == false end,
		setFunc = function(value) if(value) then SV.NodeOverwrite[WMWC_MENU_HOUSES.data.selected] = false else SV.NodeOverwrite[WMWC_MENU_HOUSES.data.selected] = nil end end,
		width = 'half',
		default = false,
		disabled = function() return WMWC_MENU_HOUSES.data.selected == nil end
	}
	table.insert(NodeOverwrite.controls, controls) 
	
	table.insert(optionsData, NodeOverwrite)
	

	local LAM = LibAddonMenu2
	local panel = LAM:RegisterAddonPanel("WMWC_Panel", panelData)
	LAM:RegisterOptionControls("WMWC_Panel", optionsData)
	
end

local function OnAddonLoaded(event, name)
	if name == ADDON_NAME then
	
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, event)
		
		SV = ZO_SavedVars:NewAccountWide("WorldMapWayshrinesController_SavedVariables", 1, defaults)
		
		-- remapp old SV to new SV
		if(SV.hideTamrielDungeons == 0) then
			SV.hideTamrielDungeons = false
			SV.hideTamrielTrials = false
		elseif(SV.hideTamrielDungeons == 1) then
			SV.hideTamrielDungeons = true
			SV.hideTamrielTrials = false
		elseif(SV.hideTamrielDungeons == 2) then
			SV.hideTamrielDungeons = true
			SV.hideTamrielTrials = true
		end
		
		RemovePinsFromMaps()
		
		BuildSettingsMenu()
	end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
