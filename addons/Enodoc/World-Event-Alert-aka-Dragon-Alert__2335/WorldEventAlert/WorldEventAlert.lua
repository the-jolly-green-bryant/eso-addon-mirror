WEAlert = {}

WEAlert.name = "WorldEventAlert"
WEAlert.version = "1.6.0"
WEAlert.initialised = false
WEAlert.defaults = {
	chat = false,
	notify = true,
	silent = false,
	dragons = true,
	anchors = true,
	cyrodiil = true,
	geysers = true,
	harrowstorms = true,
	vents = true,
	mosaics = true,
	writhing = true,
	unknown = true,
}

local LAM = LibAddonMenu2

function WEAlert.CreateConfigMenu()
    local panelData = {
        type                = "panel",
        name                = WEAlert.name,
        displayName         = "World Event Alert",
        author              = "Enodoc",
        version             = WEAlert.version,
        slashCommand        = nil,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
	local ConfigPanel = LAM:RegisterAddonPanel(panelData.name.."Config", panelData)

	local ConfigData = {
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_ANCHORS),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_ANCHORS_TOOLTIP),
			getFunc = function() return WEAlert.vars.anchors end,
			setFunc = function(newValue) WEAlert.vars.anchors = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_CYRODIIL),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_CYRODIIL_TOOLTIP),
			getFunc = function() return WEAlert.vars.cyrodiil end,
			setFunc = function(newValue) WEAlert.vars.cyrodiil = newValue end,
			disabled = function() return not WEAlert.vars.anchors end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_GEYSERS),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_GEYSERS_TOOLTIP),
			getFunc = function() return WEAlert.vars.geysers end,
			setFunc = function(newValue) WEAlert.vars.geysers = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_DRAGONS),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_DRAGONS_TOOLTIP),
			getFunc = function() return WEAlert.vars.dragons end,
			setFunc = function(newValue) WEAlert.vars.dragons = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_HARROWSTORMS),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_HARROWSTORMS_TOOLTIP),
			getFunc = function() return WEAlert.vars.harrowstorms end,
			setFunc = function(newValue) WEAlert.vars.harrowstorms = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_VENTS),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_VENTS_TOOLTIP),
			getFunc = function() return WEAlert.vars.vents end,
			setFunc = function(newValue) WEAlert.vars.vents = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_MOSAICS),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_MOSAICS_TOOLTIP),
			getFunc = function() return WEAlert.vars.mosaics end,
			setFunc = function(newValue) WEAlert.vars.mosaics = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_WRITHING),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_WRITHING_TOOLTIP),
			getFunc = function() return WEAlert.vars.writhing end,
			setFunc = function(newValue) WEAlert.vars.writhing = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_UNKNOWN),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_UNKNOWN_TOOLTIP),
			getFunc = function() return WEAlert.vars.unknown end,
			setFunc = function(newValue) WEAlert.vars.unknown = newValue end,
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_NOTIFY),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_NOTIFY_TOOLTIP),
			getFunc = function() return WEAlert.vars.notify end,
			setFunc = function(newValue) WEAlert.vars.notify = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_SILENT),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_SILENT_TOOLTIP),
			getFunc = function() return WEAlert.vars.silent end,
			setFunc = function(newValue) WEAlert.vars.silent = newValue end,
			disabled = function() return not WEAlert.vars.notify end,
		},
		{
			type = "checkbox",
			name = GetString(SI_WORLD_EVENT_ALERT_CONFIG_CHAT),
			tooltip = GetString(SI_WORLD_EVENT_ALERT_CONFIG_CHAT_TOOLTIP),
			getFunc = function() return WEAlert.vars.chat end,
			setFunc = function(newValue) WEAlert.vars.chat = newValue end,
		},
	}
	LAM:RegisterOptionControls(panelData.name.."Config", ConfigData)	
end

function WEAlert.Initialise(eventCode, addOnName)

	-- Initialize self only.
	if (WEAlert.name ~= addOnName) then return end

    -- Event registration.    
	EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_WORLD_EVENT_ACTIVATED, WEAlert.OnWEActivate)
	EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED, WEAlert.OnWELocation)
	EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_WORLD_EVENT_DEACTIVATED, WEAlert.OnWEDeactivate)
	--EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE, WEAlert.OnWEUnitPin)
	EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_WORLD_EVENT_UNIT_CREATED, WEAlert.OnWEUnitCreate)
	EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_WORLD_EVENT_UNIT_DESTROYED, WEAlert.OnWEUnitDestroy)

	WEAlert.colGry = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_CON_COLORS,CON_TRIVIAL))
	WEAlert.colRed = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_CON_COLORS,CON_IMPOSSIBLE))
	WEAlert.colWht = ZO_ColorDef:New(0.9,0.9,0.9,1)
	
	WEAlert.vars = ZO_SavedVars:NewAccountWide("WorldEventAlert_SavedVariables", 1, nil, WEAlert.defaults)
		
	WEAlert.CreateConfigMenu()
	
	WEAlert.instance = {
	[1]=GetString(SI_WORLD_EVENT_ALERT_DRAGON_INSTANCE1),
	[2]=GetString(SI_WORLD_EVENT_ALERT_DRAGON_INSTANCE2),
	[3]=GetString(SI_WORLD_EVENT_ALERT_DRAGON_INSTANCE3),
	[12]=GetString(SI_WORLD_EVENT_ALERT_DRAGON_INSTANCE12),
	[13]=GetString(SI_WORLD_EVENT_ALERT_DRAGON_INSTANCE13),
	}
	
	WEAlert.initialised = true   
--	d("WEAlert Debug: Ran Through Init. Remember to disable debug!") 

end

-- icon in string == |t16:16:icon/path.dds|t
-- Instance 1: Sandblown Dragonscour
-- Instance 2: Prowl's Edge Dragonscour
-- Instance 3: Scab Ridge Dragonscour
-- Instance 12: North Dragonscour
-- Instance 13: South Dragonscour
-- Instance 16: All Harrowstorms in The Reach
---- Location 30: Witchborne Ritual Site
---- Location 31: Ragnvald Ritual Site
---- Location 32: Reachwind Ritual Site
---- Location 33: Harrowed Haunt Ritual Site
-- Instance 17: All Harrowstorms in Western Skyrim
---- Location 34: Old Karth Ritual Site
---- Location 35: Black Morass Ritual Site
---- Location 36: Giant's Coast Ritual Site
---- Location 37: Chilblain Peak Ritual Site
---- Location 38: Hailstone Valley Ritual Site
---- Location 39: Northern Watch Ritual Site
-- Instance 18: All Harrowstorms in Blackreach
---- Location 40: Gloomforest Ritual Site
---- Location 41: Dwarf's Bane Ritual Site
---- Location 42: Miner's Lament Ritual Site
---- Location 43: Nightstone Ritual Site
-- Instance 20: All Abyssal Geysers in Summerset
---- Location 47: Direnni Abyssal Geyser
---- Location 48: Sil-Var-Woad Abyssal Geyser
---- Location 49: Rellenthil Abyssal Geyser
---- Location 50: Corgrad Abyssal Geyser
---- Location 51: Welenkin Abyssal Geyser
---- Location 52: Sunhold Abyssal Geyser
-- Instance 21: All Dark Anchors in Rivenspire
---- Location 53: Eyebright Feld Dolmen
---- Location 54: Westmark Moor Dolmen
---- Location 55: Boralis Dolmen
-- Instance 22: All Dark Anchors in Bangkorai
---- Location 56: Mournoth Dolmen
---- Location 57: Fallen Wastes Dolmen
---- Location 58: Ephesus Dolmen (?)
-- Instance 23: All Dark Anchors in Cyrodiil
---- Location 63: Winter's Reach Dolmen
-- Instance 24: All Dark Anchors in Shadowfen
---- Location 69: Venomous Fens Dolmen (?)
---- Location 70: Leafwater Dolmen
---- Location 71: Reticulated Spine Dolmen
-- Instance 25: All Dark Anchors in Stonefalls
---- Location 72: Varanis Dolmen
---- Location 73: Zabamat Dolmen (?)
---- Location 74: Daen Seeth Dolmen
-- Instance 26: All Dark Anchors in Malabal Tor
---- Location 75: Broken Coast Dolmen
---- Location 76: Silvenar Vale Dolmen (?)
---- Location 77: Xylo River Basin Dolmen
-- Instance 27: All Dark Anchors in Deshaan
---- Location 78: Redolent Loam Dolmen (?)
---- Location 79: Lagomere Dolmen
---- Location 80: Siltreen Dolmen
-- Instance 28: All Dark Anchors in Auridon
---- Location 81: Iluvamir Dolmen
---- Location 82: Calambar Dolmen
---- Location 83: Vafe Dolmen (?)
-- Instance 29: All Dark Anchors in The Rift
---- Location 84: Stony Basin Dolmen (?)
---- Location 85: Ragged Hills Dolmen
---- Location 86: Smokefrost Peaks Dolmen
-- Instance 30: All Dark Anchors in Glenumbra
---- Location 87: Daenia Dolmen
---- Location 88: Cambray Hills Dolmen
---- Location 89: King's Guard Dolmen (?)
-- Instance 31: All Dark Anchors in Eastmarch
---- Location 90: Giant's Run Dolmen (?)
---- Location 91: Frostwater Tundra Dolmen
---- Location 92: Icewind Peaks Dolmen (?)
-- Instance 32: All Dark Anchors in Stormhaven
---- Location 93: Alcaire Dolmen (?)
---- Location 94: Menevia Dolmen
---- Location 95: Gavaudon Dolmen
-- Instance 33: All Dark Anchors in Alik'r Desert
---- Location 96: Myrkwasa Dolmen
---- Location 97: Hollow Waste Dolmen (?)
---- Location 98: Tigonus Dolmen
-- Instance 34: All Dark Anchors in Reaper's March
---- Location 99: Northern Woods Dolmen
---- Location 100: Jodewood Dolmen
---- Location 101: Dawnmead Dolmen (?)
-- Instance 35: All Dark Anchors in Greenshade
---- Location 102: Wilderking Court Dolmen (?)
---- Location 103: Drowned Coast Dolmen (?)
---- Location 104: Green's Marrow Dolmem
-- Instance 36: All Dark Anchors in Grahtwood
---- Location 105: Long Coast Dolmen
---- Location 106: Green Hall Dolmen (?)
---- Location 107: Tarlain Heights Dolmen
-- Instance 37: All Volcanic Vents in High Isle and Amenos
---- Location 108: Sapphire Point Volcanic Vent
---- Location 109: Navire Volcanic Vent
---- Location 110: Feywatch Isle Volcanic Vent
---- Location 111: Garick's Rise Volcanic Vent
---- Location 112: Serpents Hollow Volcanic Vent
---- Location 113: Haunted Coast Volcanic Vent
---- Location 114: Flooded Coast Volcanic Vent
-- Instance 39: All Volcanic Vents in Galen
---- Location 115: Vastyr Outskirts Volcanic Vent
---- Location 116: Farpoint Volcanic Vent
---- Location 117: Llanshara Volcanic Vent
---- Location 119: Eastern Shores Volcanic Vent
---- Location 118: Telling Stone Volcanic Vent
-- Instance 44: All Mirrormoor Mosaics in West Weald
---- Location 132: Ostumir Mirrormoor Mosaic
---- Location 133: Sutch Mirrormoor Mosaic
---- Location 134: Colovia Mirrormoor Mosaic
---- Location 135: Silorn Mirrormoor Mosaic


EVENT_MANAGER:RegisterForEvent("WEAlert", EVENT_ADD_ON_LOADED, WEAlert.Initialise)

function WEAlert.OnWEActivate(eventCode, worldEventInstanceId)
--	d(WEAlert.colRed:Colorize("EVENT: World Event Activated"))
	local numUnits = GetNumWorldEventInstanceUnits(worldEventInstanceId)
	local eventId = GetWorldEventId(worldEventInstanceId)
	local eventType = GetWorldEventType(eventId)
	local locationName = GetPOIInfo(GetWorldEventPOIInfo(worldEventInstanceId))
--	d("    World Event Instance:" .. worldEventInstanceId)
--	d("    Location Name:" .. locationName)
--	d("    World Event ID:" .. eventId)
--	d("    World Event Type:" .. eventType)
--	d("    Number of Units:" .. numUnits)
	if (worldEventInstanceId == 1 or worldEventInstanceId == 2 or worldEventInstanceId == 3 or worldEventInstanceId == 12 or worldEventInstanceId == 13) and WEAlert.vars.dragons then
		local category = CSA_CATEGORY_LARGE_TEXT
		local sound
		if not WEAlert.vars.silent then sound = "SkillXP_DarkAnchorClosed" end
		local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
		local alert = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_EVENT_ACTIVATED))
		local message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_DRAGON_APPEARED),WEAlert.instance[worldEventInstanceId])
		params:SetText(alert, message)
		params:SetPriority(1)
		if WEAlert.vars.notify then CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params) end
		if WEAlert.vars.chat then d(alert .. ": " .. message) end
	end
end

function WEAlert.OnWELocation(eventCode, worldEventInstanceId, oldWorldEventLocationId, newWorldEventLocationId)
--	d(WEAlert.colRed:Colorize("EVENT: World Event Location Changed"))
	local numUnits = GetNumWorldEventInstanceUnits(worldEventInstanceId)
	local eventId = GetWorldEventId(worldEventInstanceId)
	local eventType = GetWorldEventType(eventId)
	local locationName = GetPOIInfo(GetWorldEventPOIInfo(worldEventInstanceId))
--	d("    World Event Instance:" .. worldEventInstanceId)
--	d("    Old Location:" .. oldWorldEventLocationId)
--	d("    New Location:" .. newWorldEventLocationId)
--	d("    Location Name:" .. locationName)
--	d("    World Event ID:" .. eventId)
--	d("    World Event Type:" .. eventType)
--	d("    Number of Units:" .. numUnits)
	if (worldEventInstanceId >= 16 and worldEventInstanceId <= 18 and WEAlert.vars.harrowstorms) or (worldEventInstanceId == 20 and WEAlert.vars.geysers) or (worldEventInstanceId >= 21 and worldEventInstanceId <= 36 and worldEventInstanceId ~= 23 and WEAlert.vars.anchors) or (worldEventInstanceId == 23 and WEAlert.vars.anchors and WEAlert.vars.cyrodiil) or (worldEventInstanceId == 37 and WEAlert.vars.vents) or (worldEventInstanceId == 39 and WEAlert.vars.vents) or (worldEventInstanceId == 44 and WEAlert.vars.mosaics) or (worldEventInstanceId == 51 and WEAlert.vars.writhing) or (WEAlert.vars.unknown and not (worldEventInstanceId == 1 or worldEventInstanceId == 2 or worldEventInstanceId == 3 or worldEventInstanceId == 12 or worldEventInstanceId == 13 or (worldEventInstanceId >= 16 and worldEventInstanceId <= 18) or worldEventInstanceId == 20 or (worldEventInstanceId >= 21 and worldEventInstanceId <= 36) or (worldEventInstanceId >= 37 and worldEventInstanceId <= 39) or worldEventInstanceId == 44)) then
		local category = CSA_CATEGORY_LARGE_TEXT
		local sound
		if not WEAlert.vars.silent then sound = "SkillXP_DarkAnchorClosed" end
		local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
		local alert = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_EVENT_ACTIVATED))
		local message 
		if worldEventInstanceId >= 16 and worldEventInstanceId <= 18 then
			message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_HARROWSTORM_APPEARED),locationName)
		elseif worldEventInstanceId == 20 then
			message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_GEYSER_APPEARED),locationName)
		elseif worldEventInstanceId >= 21 and worldEventInstanceId <= 36 then
			message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_ANCHOR_APPEARED),locationName)
		elseif worldEventInstanceId >= 37 and worldEventInstanceId <= 39 then
			message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_VENT_APPEARED),locationName)
		elseif worldEventInstanceId == 44 then
			message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_MOSAIC_APPEARED),locationName)
		else
			message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_INCURSION_APPEARED),locationName)
		end
		params:SetText(alert, message)
		params:SetPriority(1)
		if WEAlert.vars.notify then CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params) end
		if WEAlert.vars.chat then d(alert .. ": " .. message) end
	end
end

function WEAlert.OnWEDeactivate(eventCode, worldEventInstanceId)
--	d(WEAlert.colRed:Colorize("EVENT: World Event Deactivated"))
	local numUnits = GetNumWorldEventInstanceUnits(worldEventInstanceId)
	local eventId = GetWorldEventId(worldEventInstanceId)
	local eventType = GetWorldEventType(eventId)
	local locationName = GetPOIInfo(GetWorldEventPOIInfo(worldEventInstanceId))
--	d("    World Event Instance:" .. worldEventInstanceId)
--	d("    Location Name:" .. locationName)
--	d("    World Event ID:" .. eventId)
--	d("    World Event Type:" .. eventType)
--	d("    Number of Units:" .. numUnits)
end

function WEAlert.OnWEUnitCreate(eventCode, worldEventInstanceId, unitTag)
--	d(WEAlert.colRed:Colorize("EVENT: World Event Unit Created"))
	local numUnits = GetNumWorldEventInstanceUnits(worldEventInstanceId)
	local eventId = GetWorldEventId(worldEventInstanceId)
	local eventType = GetWorldEventType(eventId)
	local locationName = GetPOIInfo(GetWorldEventPOIInfo(worldEventInstanceId))
--	d("    World Event Instance:" .. worldEventInstanceId)
--	d("    Location Name:" .. locationName)
--	d("    Unit Created:" .. unitTag)
--	d("    World Event ID:" .. eventId)
--	d("    World Event Type:" .. eventType)
--	d("    Number of Units:" .. numUnits)
end

function WEAlert.OnWEUnitDestroy(eventCode, worldEventInstanceId, unitTag)
--	d(WEAlert.colRed:Colorize("EVENT: World Event Unit Destroyed"))
	local numUnits = GetNumWorldEventInstanceUnits(worldEventInstanceId)
	local eventId = GetWorldEventId(worldEventInstanceId)
	local eventType = GetWorldEventType(eventId)
	local locationName = GetPOIInfo(GetWorldEventPOIInfo(worldEventInstanceId))
--	d("    World Event Instance:" .. worldEventInstanceId)
--	d("    Location Name:" .. locationName)
--	d("    Unit Destroyed:" .. unitTag)
--	d("    World Event ID:" .. eventId)
--	d("    World Event Type:" .. eventType)
--	d("    Number of Units:" .. numUnits)
end

local function slashcommands(text)
	if (text == "chat") then
		WEAlert.vars.chat = not WEAlert.vars.chat
		local state
		if WEAlert.vars.chat then state = GetString(SI_WORLD_EVENT_ALERT_CHAT_STATE1) elseif not WEAlert.vars.chat then state = GetString(SI_WORLD_EVENT_ALERT_CHAT_STATE0) end
		local message = zo_strformat(GetString(SI_WORLD_EVENT_ALERT_CHAT),state)
		d(message)
	end
end

SLASH_COMMANDS["/worldevents"] = slashcommands
