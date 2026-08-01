local Options = {}
FasterTravel.Options = Options

local predefined_aliases = {
	["al"] = "Alik'r Desert",
	["ar"] = "Artaeum",
	["au"] = "Auridon",
	["bf"] = "The Brass Fortress",
	["br"] = "The Brass Fortress",
	["bk"] = "Bangkorai",
	["cr"] = "Craglorn",
	["ch"] = "Coldharbour",
	["co"] = "Coldharbour",
	["cc"] = "Clockwork City",
	["cl"] = "Clockwork City",
	["cwc"] = "Clockwork City",
	["de"] = "Deshaan",
	["ea"] = "Eastmarch",
	["em"] = "Eastmarch",
	["ne"] = "Northern Elsweyr",
	["gl"] = "Glenumbra",
	["gc"] = "Gold Coast",
	["go"] = "Gold Coast",
	["gra"] = "Grahtwood",
	["gw"] = "Grahtwood",
	["gs"] = "Greenshade",
	["he"] = "Hew's Bane",
	["hb"] = "Hew's Bane",
	["ma"] = "Malabal Tor",
	["mt"] = "Malabal Tor",
	["mm"] = "Murkmire",
	["mu"] = "Murkmire",
	["re"] = "Reaper's March",
	["rm"] = "Reaper's March",
	["rif"] = "The Rift",
	["tr"] = "The Rift",
	["riv"] = "Rivenspire",
	["rs"] = "Rivenspire",
	["se"] = "Southern Elsweyr",
	["sf"] = "Stonefalls",
	["sh"] = "Stormhaven",
	["sm"] = "Stros M'Kai",
	["ss"] = "Summerset",
	["su"] = "Summerset",
	["ws"] = "Western Skyrim",
}

-- constants
Options.LocationOrder = {
	ZONE_NAME = 0,
	ZONE_LEVEL = 2,
}

Options.LocationDirection = {
	ASCENDING = 0,
	DESCENDING = 1,
}

Options.AllWSOrder = {
	NAME = 1,
	TRADERS = 2,
}

Options.JumpHereBehaviour = {
	NEVER = 0,
	ASK = 1,
	ALWAYS = 2,
}

Options.Verbosity = {
	QUIET = 0,
	NORMAL = 1,
	VERBOSE = 2,
	DEBUG = 3,
	MOREDEBUG = 4,
}

-- default settings
Options.defaults = {
	recentsEnabled = true,
	recentsPosition = 1,
	recent = {},
	favourites = {},
	aliases = predefined_aliases,
	locationOrder = Options.LocationOrder.ZONE_NAME +
					Options.LocationDirection.ASCENDING,
	ws_order = Options.AllWSOrder.NAME,
	jumpHereBehaviour = Options.JumpHereBehaviour.ASK,
	verbosity = 1,
	listlen = 10,
	all_ws_hidden = true,
	dungeons_hidden = true,
	initial_tab = 1,
	sortFav = false,
	colors = {
	},
	signs = {
		surveys		  = "+",
		treasures	  = "*",
		leads		  = ">",
	},
}

local _initial_tab = { 
	{ id = 1, value = FASTER_TRAVEL_SETTINGS_INITIAL_TAB_AUTO, text = GetString(FASTER_TRAVEL_SETTINGS_INITIAL_TAB_AUTO), },
	{ id = 2, value = FASTER_TRAVEL_SETTINGS_INITIAL_TAB_LAST, text = GetString(FASTER_TRAVEL_SETTINGS_INITIAL_TAB_LAST), },
	{ id = 3, value = FASTER_TRAVEL_MODE_PLAYERS,              text = GetString(FASTER_TRAVEL_MODE_PLAYERS),              },
	{ id = 4, value = FASTER_TRAVEL_MODE_WAYSHRINES,           text = GetString(FASTER_TRAVEL_MODE_WAYSHRINES),           },
	{ id = 5, value = SI_MAP_INFO_MODE_QUESTS,                 text = GetString(SI_MAP_INFO_MODE_QUESTS),                 },
	{ id = 6, value = SI_MAP_INFO_MODE_KEY,                    text = GetString(SI_MAP_INFO_MODE_KEY),                    },
	{ id = 7, value = SI_MAP_INFO_MODE_FILTERS,                text = GetString(SI_MAP_INFO_MODE_FILTERS),                },
	{ id = 8, value = SI_MAP_INFO_MODE_LOCATIONS,              text = GetString(SI_MAP_INFO_MODE_LOCATIONS),              },
	{ id = 9, value = SI_MAP_INFO_MODE_HOUSES,                 text = GetString(SI_MAP_INFO_MODE_HOUSES),                 },
}

Options.initial_tab = _initial_tab		

local function MakeSortOrdersDropdownLabels()
	-- dropdown labels for Wayshrines tab / Options menu
	local function DropdownLabel(id, x, y)
		return { id = id, text = string.format("%s %s", x, y) }
	end
	local s1, s2, s3, s4, s5, s6
	s1, s2 = string.match(GetString(SI_GAMEPAD_BANK_SORT_ORDER_UP_TEXT), "(.+)/(.+)")
	s3, s4 = string.match(GetString(SI_GAMEPAD_BANK_SORT_ORDER_DOWN_TEXT), "(.+)/(.+)")
	s5 = GetString(SI_CHAT_CHANNEL_NAME_ZONE)
	s6 = GetString(SI_FRIENDS_LIST_PANEL_TOOLTIP_LEVEL)
	return {
		DropdownLabel(Options.LocationOrder.ZONE_NAME + Options.LocationDirection.ASCENDING,   s5, s2),
		DropdownLabel(Options.LocationOrder.ZONE_NAME + Options.LocationDirection.DESCENDING,  s5, s4),
		DropdownLabel(Options.LocationOrder.ZONE_LEVEL + Options.LocationDirection.ASCENDING,  s6, s1),
		DropdownLabel(Options.LocationOrder.ZONE_LEVEL + Options.LocationDirection.DESCENDING, s6, s3),
	}
end

local _sortOrders = MakeSortOrdersDropdownLabels()

local _sortAllWSOrders = {
	{ id = Options.AllWSOrder.NAME, text = GetString(SI_INVENTORY_SORT_TYPE_NAME) },
	{ id = Options.AllWSOrder.TRADERS, text = GetString(FASTER_TRAVEL_TRADERS) },
}

Options._sortAllWSOrders = _sortAllWSOrders
Options._sortOrders = _sortOrders

local function CompareById(a, b)
	return a.id < b.id
end

local _jumpHereBehaviours = { }
for k, v in pairs(Options.JumpHereBehaviour) do
	table.insert(_jumpHereBehaviours, {
		id = v,
		text = GetString("FASTER_TRAVEL_SETTINGS_JUMPHERE_CHOICE", v),
	})
end
table.sort(_jumpHereBehaviours, CompareById)

local _verbosity = { }
for k, v in pairs(Options.Verbosity) do
	table.insert(_verbosity, {
		id = v,
		text = GetString("FASTER_TRAVEL_SETTINGS_VERBOSITY_CHOICE", v),
	})
end
table.sort(_verbosity, CompareById)

function Options.Initialize(addon, refresh1)
	local savedVars = addon.name .. "_Data"
	local LSV = LibSavedVars
	local defaults = Options.defaults
	-- Fetch the saved variables
	local settings = LSV:NewAccountWide(savedVars, "Account", defaults):
		AddCharacterSettingsToggle(savedVars, "Character"):
		EnableDefaultsTrimming()
	FasterTravel.settings = settings
	if settings.initial_tab > 10 then settings.initial_tab = 1 end -- temporary fix for leftover initial_tab values from 3.0.8

	local function getFields(t, field)
		local result = {}
		local i, x
		for i, x in ipairs(t) do
			table.insert(result, x[field])
		end
		return result
	end

	local function ColorPickerFactory(tag, name, tooltip, default)
		return {
			type = "colorpicker",
			name = name,
			tooltip = tooltip,
			default = default,
			--width = "full",
			getFunc = function()
				local t = FasterTravel.settings.colors[tag]
				return t.r, t.g, t.b
			end,
			setFunc = function(r, g, b)
				FasterTravel.settings.colors[tag] = ZO_ColorDef:New(r, g, b)
				--FasterTravel.SetPlayersDirty()
				refresh1()
			end,
		}
	end

	if settings.colors == nil then
		settings.colors = { }
	end
	local colorsMenu = {
		{ tag = "surveys",	 name = GetString(FASTER_TRAVEL_SURVEY_MAPS_COUNT_COLOR),	tooltip = "",	default = ZO_ColorDef:New("00ff80"), },
		{ tag = "treasures", name = GetString(FASTER_TRAVEL_TREASURE_MAPS_COUNT_COLOR),	tooltip = "",	default = ZO_ColorDef:New("ffff00"), },
		{ tag = "leads",	 name = GetString(FASTER_TRAVEL_LEADS_COUNT_COLOR),			tooltip = "",	default = ZO_ColorDef:New("00c0ff"), },
	}
	local colorPickers = {}
	for k, v in ipairs(colorsMenu) do
		local tag = v.tag
		local color = settings.colors[tag] -- SV contains just a table, NOT a ZO_ColorDef object
		settings.colors[tag] = color and ZO_ColorDef:New(color.r, color.g, color.b) or v.default -- now a ZO_ColorDef, ready to use
		table.insert(colorPickers, ColorPickerFactory(tag, v.name, v.tooltip, v.default))
	end

	local panelData = {
		type = "panel",
		name = addon.name,
		displayName = addon.displayName,
		author = addon.author,
		version = addon.version,
		website = addon.website,
		slashCommand = "/ft",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local optionsTable = {
		-- Account-wide settings
		settings:GetLibAddonMenuAccountCheckbox(),
		{
			type = "divider",
		},
		--[[
		{
			type = "description",
			-- title = "Explanation",
			text = GetString(FASTER_TRAVEL_SETTINGS_DESC),
		},
		]]--
		{
			type = "checkbox",
			name = GetString(FASTER_TRAVEL_SETTINGS_RECENTS),
			default = defaults.recentsEnabled,
			warning = GetString(SI_ADDON_MANAGER_RELOAD),
			requiresReload = true,
			getFunc = function() return settings.recentsEnabled end,
			setFunc = function(newValue)
				settings.recentsEnabled = newValue
			end,
		},
		{
			type = "slider",
			name = GetString(FASTER_TRAVEL_SETTINGS_LISTLEN),
			default = defaults.listlen,
			min = 1,
			max = 100,
			getFunc = function() return settings.listlen end,
			setFunc = function(newValue)
				settings.listlen = newValue
			end,
		},
		{
			type = "dropdown",
			name = GetString(FASTER_TRAVEL_SETTINGS_RECENTS_POS),
			default = defaults.recentsPosition,
			choices = {
				GetString("FASTER_TRAVEL_SETTINGS_RECENTS_POS_CHOICE", 1),
				GetString("FASTER_TRAVEL_SETTINGS_RECENTS_POS_CHOICE", 2),
			},
			choicesValues = { 1, 2 },
			getFunc = function()
				return settings.recentsPosition
			end,
			setFunc = function(choice)
				settings.recentsPosition = choice
			end,
		},
		{
			type = "dropdown",
			name = GetString(FASTER_TRAVEL_SETTINGS_VERBOSITY),
			default = defaults.verbosity,
			choices = getFields(_verbosity, "text"),
			choicesValues = getFields(_verbosity, "id"),
			getFunc = function()
				return settings.verbosity
			end,
			setFunc = function(choice)
				settings.verbosity = choice
			end,
		},
		{
			type = "dropdown",
			name = GetString(FASTER_TRAVEL_SETTINGS_INITIAL_TAB),
			default = defaults.initial_tab,
			choices = getFields(_initial_tab, "text"),
			choicesValues = getFields(_initial_tab, "id"),
			getFunc = function()
				return settings.initial_tab
			end,
			setFunc = function(choice)
				settings.initial_tab = choice
			end,
			tooltip = GetString(FASTER_TRAVEL_SETTINGS_INITIAL_TAB_TOOLTIP),
		},
		{
			type = "dropdown",
			name = GetString(FASTER_TRAVEL_SETTINGS_JUMPHERE),
			default = defaults.jumpHereBehaviour,
			choices = getFields(_jumpHereBehaviours, "text"),
			choicesValues = getFields(_jumpHereBehaviours, "id"),
			getFunc = function()
				return settings.jumpHereBehaviour
			end,
			setFunc = function(choice)
				settings.jumpHereBehaviour = choice
			end,
		},
		{
			type = "dropdown",
			name = GetString(FASTER_TRAVEL_SETTINGS_WS_ORDER),
			default = defaults.ws_order,
			choices = getFields(_sortAllWSOrders, "text"),
			choicesValues = getFields(_sortAllWSOrders, "id"),
			getFunc = function()
				return settings.ws_order
			end,
			setFunc = function(choice)
				settings.ws_order = tonumber(choice)
				refresh1()
			end,
		},
		{
			type = "dropdown",
			name = GetString(FASTER_TRAVEL_SETTINGS_LOCATION_ORDER),
			default = defaults.locationOrder,
			choices = getFields(_sortOrders, "text"),
			choicesValues = getFields(_sortOrders, "id"),
			getFunc = function()
				return settings.locationOrder
			end,
			setFunc = function(choice)
				settings.locationOrder = tonumber(choice)
				refresh1()
			 end,
		},
		{
			type = "checkbox",
			name = GetString(FASTER_TRAVEL_SETTINGS_SORTFAV),
			default = defaults.sortFav,
			getFunc = function() return settings.sortFav end,
			setFunc = function(newValue)
				settings.sortFav = newValue
				refresh1()
			end,
		},
		{
			type = "submenu",
			name = GetString(FASTER_TRAVEL_CUSTOMCOLORS),
			controls = colorPickers,
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(addon.name .. "Options", panelData)
	LAM:RegisterOptionControls(addon.name .. "Options", optionsTable)
	Options.OptionsTable = optionsTable

	return settings
end
