WayshrineTabSelector = {}
WayshrineTabSelector.variableVersion = 2 
WayshrineTabSelector.Default = {
	DropdownMenuIndex = SI_MAP_INFO_MODE_LOCATIONS,
	Automode = false
}

local _events = {}

local function GetUniqueEventId(id)
    local count = _events[id] or 0
    count = count + 1
    _events[id] = count
    return count
end

local function GetEventName(id)
    return table.concat({ "WayshrineTabSelector_", tostring(id), "_", tostring(GetUniqueEventId(id)) })
end

local otherAddons = {}

local function addEvent(id, func)
    local name = GetEventName(id)
    EVENT_MANAGER:RegisterForEvent(name, id, func)
end

local function init(func, ...)
    local arg = { ... }
    addEvent(EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
	if (addOnName ~= "WayshrineTabSelector") then
		if addOnName == "FasterTravel" then
			otherAddons["FasterTravel"] = true
		end
	    return
	end
	func(unpack(arg))
    end)
end

local panelData = {
    type = "panel",
    name = "Wayshrine Tab Selector",
    displayName = "Wayshrine Tab Selector",
    author = "Kulturnilpferd",
    version = "1.3",
    slashCommand = "/wayshrinetabselector",	
    registerForRefresh = true,	
    registerForDefaults = true,
}

local choicesTabs = {
    GetString(SI_MAP_INFO_MODE_QUESTS),
    GetString(SI_MAP_INFO_MODE_KEY),
    GetString(SI_MAP_INFO_MODE_FILTERS),
    GetString(SI_MAP_INFO_MODE_LOCATIONS),
    GetString(SI_MAP_INFO_MODE_HOUSES)
	}

local choicesTabsValues = {
    SI_MAP_INFO_MODE_QUESTS,
    SI_MAP_INFO_MODE_KEY,
    SI_MAP_INFO_MODE_FILTERS,
    SI_MAP_INFO_MODE_LOCATIONS,
    SI_MAP_INFO_MODE_HOUSES,
}

local optionsTable = {
    [1] = {
        type = "header",
        name = "",
        width = "full",
    },
    [2] = {
        type = "description",
        title = nil,
        text = "Choose a custom default tab on wayshrine menu",
        width = "full",
    },
    [3] = {
        type = "dropdown",
        name = "Default Wayshrine Tab",
        choices = choicesTabs,
		choicesValues   = choicesTabsValues,
        getFunc = function() 
			return WayshrineTabSelector.savedVariables.DropdownMenuIndex end,
        setFunc = function(var)
			WayshrineTabSelector.savedVariables.DropdownMenuIndex = var	
			end,
        width = "full",
    },
	[4] = {
		type = "checkbox",
		name = "Auto Mode",
		tooltip = "Will open the last used tab when visit a wayshrine",
		getFunc = function()
			if WayshrineTabSelector.savedVariables.Automode then
				return true
			else
				return false
			end
		end,
		setFunc = function(value) 
			WayshrineTabSelector.savedVariables.Automode = value 
		end,
		width = "full",	--or "half" (optional)
		warning = "Override default tab when enabled but more comfortable",	--(optional)
	},
}

local LAM = LibStub("LibAddonMenu-2.0")

init(function()
	-- Quest
	ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton1, "OnMouseUp", function(control, button, upInside)
		if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
			WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_QUESTS
		end
		return false
	end)
	
	-- Key
	ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton2, "OnMouseUp", function(control, button, upInside)
		if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
			WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_KEY
		end
		return false
	end)
	
	-- Filters
	ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton3, "OnMouseUp", function(control, button, upInside)
		if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
			WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_FILTERS
		end
		return false
	end)
	
	-- Locations
	ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton4, "OnMouseUp", function(control, button, upInside)
		if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
			WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_LOCATIONS
		end
		return false
	end)
	
	-- Houses
	ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton5, "OnMouseUp", function(control, button, upInside)
		if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
			WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_HOUSES
		end	
		return false
	end)
	
	-- Support for FasterTravel
	if otherAddons["FasterTravel"] then	
		optionsTable[3].choices = {
			GetString(SI_MAP_INFO_MODE_QUESTS),
			GetString(SI_MAP_INFO_MODE_KEY),
			GetString(SI_MAP_INFO_MODE_FILTERS),
			GetString(SI_MAP_INFO_MODE_LOCATIONS),
			GetString(SI_MAP_INFO_MODE_HOUSES),
			GetString(SI_MAP_INFO_MODE_WAYSHRINES),
			GetString(SI_MAP_INFO_MODE_PLAYERS)
		}
		
		optionsTable[3].choicesValues = {
			SI_MAP_INFO_MODE_QUESTS,
			SI_MAP_INFO_MODE_KEY,
			SI_MAP_INFO_MODE_FILTERS,
			SI_MAP_INFO_MODE_LOCATIONS,
			SI_MAP_INFO_MODE_HOUSES,
			SI_MAP_INFO_MODE_WAYSHRINES,
			SI_MAP_INFO_MODE_PLAYERS
		}
		
		ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton6, "OnMouseUp", function(control, button, upInside)
			if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
				WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_WAYSHRINES
			end
			return false
		end)

		ZO_PreHookHandler(ZO_WorldMapInfoMenuBarButton7, "OnMouseUp", function(control, button, upInside)
			if WayshrineTabSelector.savedVariables.Automode and button == MOUSE_BUTTON_INDEX_LEFT then
				WayshrineTabSelector.savedVariables.DropdownMenuIndex = SI_MAP_INFO_MODE_PLAYERS
			end
			return false
		end)
	end
	
	local WayshrineTrigger = false
	addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function()
		WayshrineTrigger = true
    end)

    addEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function()
		WayshrineTrigger = true
    end)
	
	ZO_PreHookHandler(ZO_WorldMapInfoMenuBar, "OnUpdate", function()
		if WayshrineTabSelector.savedVariables.DropdownMenuIndex and WayshrineTrigger then
           WORLD_MAP_INFO:SelectTab(WayshrineTabSelector.savedVariables.DropdownMenuIndex)
		   WayshrineTrigger = false
        end
		return false
	end)

	WayshrineTabSelector.savedVariables = ZO_SavedVars:NewAccountWide("WayshrineTabSelectorDB", WayshrineTabSelector.variableVersion, nil, WayshrineTabSelector.Default)
	LAM:RegisterAddonPanel("MyAddon", panelData)
	LAM:RegisterOptionControls("MyAddon", optionsTable)
end)