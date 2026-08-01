if RFT == nil then RFT = { } end

local RFT = RFT

function RFT.MakeMenu()
	local menu = LibStub("LibAddonMenu-2.0")
	local set = RFT.settings

	local panel = {
		type = "panel",
		name = "Rare Fish Tracker",
		displayName = "Rare Fish Tracker",
		author = "katkat42 & votan",
		version = "1.23",
		registerForRefresh = true,
		registerForDefaults = true,
		slashCommand = "/rft",
	}

	local options = {
		{
			type = "header",
			name = GetString(SI_RARE_FISH_TRACKER_WINDOW_SETTINGS),
		},
		{
			type = "slider",
			name = GetString(SI_RARE_FISH_TRACKER_WINDOW_BACKGROUND_ALPHA),
			tooltip = GetString(SI_RARE_FISH_TRACKER_WINDOW_BACKGROUND_ALPHA_TOOLTIP),
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return set.alpha end,
			setFunc = function(value)
				set.alpha = value
				RFT.window.bg:SetCenterColor(0, 0, 0, set.alpha / 100)
				RFT.window.bg:SetEdgeColor(0, 0, 0, set.alpha / 100)
			end,
			default = 60,
		},
		{
			type = "slider",
			name = GetString(SI_RARE_FISH_TRACKER_WATER_TYPE_BACKGROUND_ALPHA),
			tooltip = GetString(SI_RARE_FISH_TRACKER_WATER_TYPE_BACKGROUND_ALPHA_TOOLTIP),
			min = 0,
			max = 100,
			step = 5,
			getFunc = function() return set.waterTypeAlpha end,
			setFunc = function(value)
				set.waterTypeAlpha = value
				local function SetupWaterType(control)
					control:SetCenterColor(0, 0, 0, set.waterTypeAlpha / 100)
					control:SetEdgeColor(0, 0, 0, set.waterTypeAlpha / 100)
				end
				local entries = RFT.window.entries
				SetupWaterType(entries.ocean.bd)
				SetupWaterType(entries.lake.bd)
				SetupWaterType(entries.river.bd)
				SetupWaterType(entries.foul.bd)
			end,
			default = 0,
		},
		{
			type = "checkbox",
			name = GetString(SI_RARE_FISH_TRACKER_SHOW_MUNGE),
			tooltip = GetString(SI_RARE_FISH_TRACKER_FISH_SHOW_MUNGE_TOOLTIP),
			getFunc = function() return set.showMunge end,
			setFunc = function(value)
				set.showMunge = value
				RFT.RefreshWindow()
			end,
			default = RFT.defaults.showMunge,
		},
		{
			type = "checkbox",
			name = GetString(SI_RARE_FISH_TRACKER_USE_DEFAULT_COLORS),
			tooltip = GetString(SI_RARE_FISH_TRACKER_USE_DEFAULT_COLORS_TOOLTIP),
			getFunc = function() return set.useDefaultColors end,
			setFunc = function(value)
				set.useDefaultColors = value
				RFT.RefreshWindow()
			end,
			default = RFT.defaults.useDefaultColors,
		},
		{
			type = "checkbox",
			name = GetString(SI_RARE_FISH_TRACKER_SHOW_TITLE),
			tooltip = GetString(SI_RARE_FISH_TRACKER_SHOW_TITLE_TOOLTIP),
			getFunc = function() return set.showtitle end,
			setFunc = function(value)
				set.showtitle = value
				RFT.window.title:SetHidden(not set.showtitle)
				if (set.showtitle) then
					RFT.window.zone:ClearAnchors()
					RFT.window.zone:SetAnchor(TOP, RFT.window.title, BOTTOM, 0, 5)
				else
					RFT.window.zone:ClearAnchors()
					RFT.window.zone:SetAnchor(TOP, RFT.window, TOP, 0, 5)
				end
			end,
			default = RFT.defaults.showtitle,
		},
		{
			type = "dropdown",
			name = GetString(SI_RARE_FISH_TRACKER_FISH_TO_HIGHLIGHT),
			tooltip = GetString(SI_RARE_FISH_TRACKER_FISH_TO_HIGHLIGHT_TOOLTIP),
			choices = { GetString(SI_RARE_FISH_TRACKER_CAUGHT), GetString(SI_RARE_FISH_TRACKER_UNCAUGHT) },
			getFunc = function() return set.highlight == "Caught" and GetString(SI_RARE_FISH_TRACKER_CAUGHT) or GetString(SI_RARE_FISH_TRACKER_UNCAUGHT) end,
			setFunc = function(value)
				set.highlight = value == GetString(SI_RARE_FISH_TRACKER_CAUGHT) and "Caught" or "Uncaught"
				RFT.RefreshWindow()
			end,
			default = RFT.defaults.highlight,
		},
		{
			type = "checkbox",
			name = GetString(SI_RARE_FISH_TRACKER_SHOW_HUD),
			tooltip = GetString(SI_RARE_FISH_TRACKER_FISH_SHOW_HUD_TOOLTIP),
			getFunc = function() return set.shown end,
			setFunc = function(value)
				set.shown = value
				RFT.RefreshWindow()
			end,
			default = RFT.defaults.shown,
		},
		{
			type = "checkbox",
			name = GetString(SI_RARE_FISH_TRACKER_AUTO_SHOW_HIDE_HUD),
			tooltip = GetString(SI_RARE_FISH_TRACKER_AUTO_SHOW_HIDE_HUD_TOOLTIP),
			getFunc = function() return set.autoShowHide end,
			setFunc = function(value)
				set.autoShowHide = value
				RFT.RefreshWindow()
			end,
			default = RFT.defaults.autoShowHide,
		},
		{
			type = "checkbox",
			name = GetString(SI_RARE_FISH_TRACKER_SHOW_WORLD_MAP),
			tooltip = GetString(SI_RARE_FISH_TRACKER_FISH_SHOW_WORLD_MAP_TOOLTIP),
			getFunc = function() return set.shown_world end,
			setFunc = function(value)
				set.shown_world = value
				RFT.RefreshWindow()
			end,
			default = RFT.defaults.shown,
		},
	}

	menu:RegisterAddonPanel("RareFish", panel)
	menu:RegisterOptionControls("RareFish", options)
end