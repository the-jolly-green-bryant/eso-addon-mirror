local DD = DailyDeeds

function DD.RegisterLAMPanel()
	local LAM = LibAddonMenu2

	local optionsData = {}

	local trackers = {
		{
			id = "XP",
			name = "Experience Points",
			icon = "/esoui/art/icons/icon_experience.dds",
			settings = {
				{
					type = "checkbox",
					name = "Disable Enlightenment at 3600 CP",
					tooltip = "When enabled, enlightened XP bonus is disabled at max champion points (3600)",
					getFunc = function()
						local settings = DD.GetSettings("XP")
						return settings.disableEnlightenmentAtMaxCP ~= false
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("XP")
						settings.disableEnlightenmentAtMaxCP = value
					end,
					default = true,
				},
			},
		},
		{
			id = "Gold",
			name = "Gold",
			icon = "/esoui/art/currency/currency_gold.dds",
			settings = {
				{
					type = "checkbox",
					name = "Track Negative Changes",
					tooltip = "When disabled, only gold gains will be tracked (spending will be ignored)",
					getFunc = function()
						local settings = DD.GetSettings("Gold")
						return settings.trackNegatives ~= false
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("Gold")
						settings.trackNegatives = value
					end,
					default = true,
				},
			},
		},
		{
			id = "AP",
			name = "Alliance Points",
			icon = GetCurrencyKeyboardIcon(CURT_ALLIANCE_POINTS),
			settings = {
				{
					type = "checkbox",
					name = "Track Negative Changes",
					tooltip = "When disabled, only AP gains will be tracked (spending will be ignored)",
					getFunc = function()
						local settings = DD.GetSettings("AP")
						return settings.trackNegatives ~= false
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("AP")
						settings.trackNegatives = value
					end,
					default = true,
				},
				{
					type = "checkbox",
					name = "Show In All Zones",
					tooltip = "When enabled, tracker will be visible in all zones (ignores zone restrictions)",
					getFunc = function()
						local settings = DD.GetSettings("AP")
						return settings.showInAllZones == true
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("AP")
						settings.showInAllZones = value
						local ui = DD.ui["AP"]
						if ui and ui.fragment then
							if not settings.isHidden and (value or DD.IsInAPZone()) then
								ui.fragment:Show(true)
							else
								ui.fragment:Hide()
							end
						end
					end,
					default = false,
				},
			},
		},
		{
			id = "Telvar",
			name = "Telvar Stones",
			icon = GetCurrencyKeyboardIcon(CURT_TELVAR_STONES),
			settings = {
				{
					type = "checkbox",
					name = "Track Negative Changes",
					tooltip = "When disabled, only Telvar gains will be tracked (losses will be ignored)",
					getFunc = function()
						local settings = DD.GetSettings("Telvar")
						return settings.trackNegatives ~= false
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("Telvar")
						settings.trackNegatives = value
					end,
					default = true,
				},
				{
					type = "checkbox",
					name = "Show In All Zones",
					tooltip = "When enabled, tracker will be visible in all zones (ignores zone restrictions)",
					getFunc = function()
						local settings = DD.GetSettings("Telvar")
						return settings.showInAllZones == true
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("Telvar")
						settings.showInAllZones = value
						local ui = DD.ui["Telvar"]
						if ui and ui.fragment then
							if not settings.isHidden and (value or DD.IsInTelvarZone()) then
								ui.fragment:Show(true)
							else
								ui.fragment:Hide()
							end
						end
					end,
					default = false,
				},
			},
		},
		{
			id = "TradeBars",
			name = "Trade Bars",
			icon = GetCurrencyKeyboardIcon(CURT_TRADE_BARS),
			settings = {},
		},
		{
			id = "Fortunes",
			name = "Archival Fortunes",
			icon = GetCurrencyKeyboardIcon(CURT_ARCHIVAL_FORTUNES),
			settings = {
				{
					type = "checkbox",
					name = "Track Negative Changes",
					tooltip = "When disabled, only Fortunes gains will be tracked (spending will be ignored)",
					getFunc = function()
						local settings = DD.GetSettings("Fortunes")
						return settings.trackNegatives ~= false
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("Fortunes")
						settings.trackNegatives = value
					end,
					default = true,
				},
				{
					type = "checkbox",
					name = "Show In All Zones",
					tooltip = "When enabled, tracker will be visible in all zones (ignores zone restrictions)",
					getFunc = function()
						local settings = DD.GetSettings("Fortunes")
						return settings.showInAllZones == true
					end,
					setFunc = function(value)
						local settings = DD.GetSettings("Fortunes")
						settings.showInAllZones = value
						local ui = DD.ui["Fortunes"]
						if ui and ui.fragment then
							if not settings.isHidden and (value or DD.IsInFortunesZone()) then
								ui.fragment:Show(true)
							else
								ui.fragment:Hide()
							end
						end
					end,
					default = false,
				},
			},
		},
	}

	for _, tracker in ipairs(trackers) do
		table.insert(optionsData, {
			type = "header",
			name = string.format("|t16:16:%s|t %s", tracker.icon, tracker.name),
		})

		table.insert(optionsData, {
			type = "checkbox",
			name = "Enable Tracker",
			getFunc = function()
				local settings = DD.GetSettings(tracker.id)
				return not settings.isHidden
			end,
			setFunc = function(value)
				local settings = DD.GetSettings(tracker.id)
				settings.isHidden = not value
			end,
			default = true,
			requiresReload = true,
			width = "full",
		})

		for _, setting in ipairs(tracker.settings) do
			table.insert(optionsData, setting)
		end

		table.insert(optionsData, {
			type = "button",
			name = "Reset",
			func = function()
				DD.ResetTracker(tracker.id)
			end,
			width = "half",
		})
	end

	local panelData = {
		type = "panel",
		name = "Daily Deeds",
		displayName = "|cFFD700Daily Deeds|r",
		author = "|cFFD700@Atharti|r",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel("DailyDeedsPanel", panelData)
	LAM:RegisterOptionControls("DailyDeedsPanel", optionsData)
end