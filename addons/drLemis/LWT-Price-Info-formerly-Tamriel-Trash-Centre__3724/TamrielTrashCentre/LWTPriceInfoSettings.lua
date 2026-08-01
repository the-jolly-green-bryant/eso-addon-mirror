local LAM = LibAddonMenu2

local ANCHOR_CHOICES = { "Top Left", "Top Right", "Bottom Left", "Bottom Right" }
local ANCHOR_VALUES = {
	["Top Left"] = TOPLEFT,
	["Top Right"] = TOPRIGHT,
	["Bottom Left"] = BOTTOMLEFT,
	["Bottom Right"] = BOTTOMRIGHT,
}
local ANCHOR_NAMES = {}
for name, val in pairs(ANCHOR_VALUES) do
	ANCHOR_NAMES[val] = name
end

local defaultColors = {
	colorBad = { r = 1.0, g = 0.0, b = 0.0, a = 1.0 },
	colorGood = { r = 0.0, g = 1.0, b = 0.0, a = 1.0 },
	colorProfitable = { r = 0.5, g = 0.5, b = 1.0, a = 1.0 },
	colorGuildBadStart = { r = 1.0, g = 0.75, b = 0.0, a = 1.0 },
	colorGuildBadEnd = { r = 0.75, g = 0.0, b = 1.0, a = 1.0 },
	colorGuildGoodStart = { r = 0.75, g = 1.0, b = 0.0, a = 1.0 },
	colorGuildGoodEnd = { r = 0.0, g = 1.0, b = 1.0, a = 1.0 },
}

local function copyDefaultColors()
	local copy = {}
	for key, color in pairs(defaultColors) do
		copy[key] = { r = color.r, g = color.g, b = color.b, a = color.a }
	end
	return copy
end

LWTPriceInfo.defaults = {
	gamepad = {
		displayMode     = "always",
		priceProvider   = function() return LWTPriceInfo.GetAvailablePriceProvider() end,
		priceType       = "Sale Avg",
		stackMultiplier = true,
		ignoreBound     = true,
		setsOnly        = false,
		guildPriceDelta = true,
		guildFee        = false,
	},
	topMarker    = {
		enabled         = true,
		minPrice        = 800,
		maxPrice        = 2500,
		visibilityType  = "Always",
		priceProvider   = function () return LWTPriceInfo.GetAvailablePriceProvider() end,
		priceType       = "Sale Avg",
		priceShorten    = 1000,
		stackMultiplier = true,
		setsOnly        = false,
		ignoreBound     = true,
		showAmount      = true,
		colorAmount     = "Separate",
		countMin        = 5,
		countMax        = 50,
		textScale       = 14,
		textBold        = true,
		xOffsetInv      = 0,
		yOffsetInv      = -2,
		xOffsetGuild    = 0,
		yOffsetGuild    = -7,
		textScaleCraft  = 14,
		xOffsetCraft    = 0,
		yOffsetCraft    = 35,
		anchor          = TOPRIGHT,
		anchorCraft     = TOPRIGHT,
		childName       = "_top",
		profitableColor = true,
		colors          = copyDefaultColors(),
		guildPriceDelta = true,
		guildFee        = false
	},
}

function LWTPriceInfo.GetMarkerSettings()
	return LWTPriceInfo.vars.topMarker
end

function LWTPriceInfo.GetMarkerDefaults()
	return LWTPriceInfo.defaults.topMarker
end

function LWTPriceInfo.CreateSettingsUI()
	local Panel = {
		type = "panel",
		name = zo_strformat(LWTPriceInfo.nameLoc),
		displayName = zo_strformat(LWTPriceInfo.nameLoc),
		website = zo_strformat(LWTPriceInfo.website),
		author = LWTPriceInfo.author,
		version = LWTPriceInfo.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}

	LAM:RegisterAddonPanel(LWTPriceInfo.name .. "_LibAddonMenu2", Panel)

	local PanelData = {}

	LWTPriceInfo.CreateHelpSettings(PanelData, GetString(LWT_PI_S_HELP));
	LWTPriceInfo.CreateErrorsSettings(PanelData, GetString(LWT_PI_ERRORS));
	LWTPriceInfo.CreateSettings(PanelData, GetString(LWT_PI_GENERAL_SUBMENU));
	LWTPriceInfo.CreateGamepadSettings(PanelData, GetString(LWT_PI_CONTROLLER_SUBMENU));

	LAM:RegisterOptionControls(LWTPriceInfo.name .. "_LibAddonMenu2", PanelData)
end

function LWTPriceInfo.CreateGamepadSettings(data, name)
	local settings = LWTPriceInfo.vars.gamepad
	local defaults = LWTPriceInfo.defaults.gamepad
	local displayModeChoices = { "always", "ui", "tooltip" }
	local displayModeNames = {
		GetString(LWT_PI_S_GAMEPAD_MODE_ALWAYS),
		GetString(LWT_PI_S_GAMEPAD_MODE_UI),
		GetString(LWT_PI_S_GAMEPAD_MODE_TOOLTIP),
	}
	local displayModeMap = {}
	for i, key in ipairs(displayModeChoices) do
		displayModeMap[key] = displayModeNames[i]
		displayModeMap[displayModeNames[i]] = key
	end

	table.insert(data,
		{
			type = "submenu",
			name = name,
			controls = {
				{
					type = "dropdown",
					name = GetString(LWT_PI_S_GAMEPAD_MODE),
					tooltip = GetString(LWT_PI_S_GAMEPAD_MODE_T),
					choices = displayModeNames,
					getFunc = function()
						return displayModeMap[settings.displayMode] or displayModeNames[1]
					end,
					setFunc = function(value)
						settings.displayMode = displayModeMap[value] or "always"
					end,
					default = function()
						return displayModeMap[defaults.displayMode] or displayModeNames[1]
					end,
				},
			{
				type = "dropdown",
				name = GetString(LWT_PI_S_PRICE_PROVIDER),
				tooltip = GetString(LWT_PI_S_PRICE_PROVIDER_T),
				choices = LWTPriceInfo.ProviderNames,
				getFunc = function() return settings.priceProvider end,
				setFunc = function(value) settings.priceProvider = value end,
				default = function() return LWTPriceInfo.GetAvailablePriceProvider() end,
			},
			{
				type = "dropdown",
				name = GetString(LWT_PI_S_P_TYPE),
				tooltip = GetString(LWT_PI_S_P_TYPE_T),
				choicesTooltips = {
					GetString(LWT_PI_S_P_TYPE_LISTED_AVG_T),
					GetString(LWT_PI_S_P_TYPE_SALE_AVG_T),
					GetString(LWT_PI_S_P_TYPE_SUGGESTED_T),
				},
				choices = { "Listed Avg", "Sale Avg", "Suggested" },
				getFunc = function() return settings.priceType end,
				setFunc = function(value) settings.priceType = value end,
				default = defaults.priceType,
			},
			{
				type = "checkbox",
				name = GetString(LWT_PI_S_AMOUNT_MULT),
				tooltip = GetString(LWT_PI_S_AMOUNT_MULT_T),
				getFunc = function() return settings.stackMultiplier end,
				setFunc = function(value) settings.stackMultiplier = value end,
				default = defaults.stackMultiplier,
			},
			{
				type = "checkbox",
				name = GetString(LWT_PI_S_IGNORE_BOUND),
				tooltip = GetString(LWT_PI_S_IGNORE_BOUND_T),
				getFunc = function() return settings.ignoreBound end,
				setFunc = function(value) settings.ignoreBound = value end,
				default = defaults.ignoreBound,
			},
			{
				type = "checkbox",
				name = GetString(LWT_PI_S_SETS_ONLY),
				tooltip = GetString(LWT_PI_S_SETS_ONLY_T),
				getFunc = function() return settings.setsOnly end,
				setFunc = function(value) settings.setsOnly = value end,
				default = defaults.setsOnly,
			},
			{
				type = "divider",
			},
			{
				type = "description",
				text = function() return GetString(LWT_PI_S_CHAPTER_GUILD) end,
				width = "full",
			},
			{
				type = "checkbox",
				name = GetString(LWT_PI_S_GUILD_DELTA),
				tooltip = GetString(LWT_PI_S_GUILD_DELTA_T),
				getFunc = function() return settings.guildPriceDelta end,
				setFunc = function(value) settings.guildPriceDelta = value end,
				default = defaults.guildPriceDelta,
			},
			{
				type = "checkbox",
				name = GetString(LWT_PI_S_GUILD_DELTA_FEE),
				tooltip = GetString(LWT_PI_S_GUILD_DELTA_FEE_T),
				getFunc = function() return settings.guildFee end,
				setFunc = function(value) settings.guildFee = value end,
				disabled = function() return not settings.guildPriceDelta end,
				default = defaults.guildFee,
			},
		}
	})
	table.insert(data, { type = "divider" })
end

function LWTPriceInfo.CreateSettings(data, name)
	local settings = LWTPriceInfo.GetMarkerSettings()
	local defaults = LWTPriceInfo.GetMarkerDefaults()
	table.insert(data,
		{
			type = "submenu",
			name = name,
			controls = {
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_ENABLE),
					tooltip = GetString(LWT_PI_S_USE_MARKER),
					getFunc = function() return settings.enabled end,
					setFunc = function(value) settings.enabled = value end,
					default = defaults.enabled
				},
				{
					type = "divider",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_CHAPTER_PRICING) end,
					width = "full",
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_PRICE_MIN),
					tooltip = GetString(LWT_PI_S_PRICE_MIN_T),
					getFunc = function() return settings.minPrice end,
					setFunc = function(value)
						settings.minPrice = value
						if settings.maxPrice <= value then
							settings.maxPrice = value + 1
						end
					end,
					min = 0,
					max = 100000,
					default = defaults.minPrice,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_PRICE_MAX),
					tooltip = GetString(LWT_PI_S_PRICE_MAX_T),
					getFunc = function() return settings.maxPrice end,
					setFunc = function(value)
						settings.maxPrice = value
						if settings.minPrice >= value then
							settings.minPrice = value - 1
						end
					end,
					min = 1,
					max = 100001,
					default = defaults.maxPrice,
					warning = GetString(LWT_PI_S_PRICE_MAX_W)
				},
				{
					type = "dropdown",
					name = GetString(LWT_PI_S_PRICE_PROVIDER),
					tooltip = GetString(LWT_PI_S_PRICE_PROVIDER_T),
					choices = LWTPriceInfo.ProviderNames,
					getFunc = function() return settings.priceProvider end,
					setFunc = function(value) settings.priceProvider = value end,
					default = function() return LWTPriceInfo.GetAvailablePriceProvider() end,
				},
				{
					type = "dropdown",
					name = GetString(LWT_PI_S_P_TYPE),
					tooltip = GetString(LWT_PI_S_P_TYPE_T),
					choicesTooltips = {
						GetString(LWT_PI_S_P_TYPE_LISTED_AVG_T),
						GetString(LWT_PI_S_P_TYPE_SALE_AVG_T),
						GetString(LWT_PI_S_P_TYPE_SUGGESTED_T)
					},
					choices = { "Listed Avg", "Sale Avg", "Suggested" },
					getFunc = function() return settings.priceType end,
					setFunc = function(value) settings.priceType = value end,
					default = defaults.priceType
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_PRICE_SHORTEN),
					tooltip = GetString(LWT_PI_S_PRICE_SHORTEN_T),
					getFunc = function() return settings.priceShorten end,
					setFunc = function(value) settings.priceShorten = value end,
					min = 0,
					max = 100000,
					default = defaults.priceShorten
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_AMOUNT_MULT),
					tooltip = GetString(LWT_PI_S_AMOUNT_MULT_T),
					getFunc = function() return settings.stackMultiplier end,
					setFunc = function(value) settings.stackMultiplier = value end,
					default = defaults.stackMultiplier
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_SETS_ONLY),
					tooltip = GetString(LWT_PI_S_SETS_ONLY_T),
					getFunc = function() return settings.setsOnly end,
					setFunc = function(value) settings.setsOnly = value end,
					default = defaults.setsOnly
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_IGNORE_BOUND),
					tooltip = GetString(LWT_PI_S_IGNORE_BOUND_T),
					getFunc = function() return settings.ignoreBound end,
					setFunc = function(value) settings.ignoreBound = value end,
					default = defaults.ignoreBound
				},
				{
					type = "divider",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_CHAPTER_DISPLAY) end,
					width = "full",
				},
				{
					type = "dropdown",
					name = GetString(LWT_PI_S_ANCHOR),
					tooltip = GetString(LWT_PI_S_ANCHOR_T),
					choices = ANCHOR_CHOICES,
					getFunc = function() return ANCHOR_NAMES[settings.anchor] or "Top Right" end,
					setFunc = function(value) settings.anchor = ANCHOR_VALUES[value] end,
					default = function() return ANCHOR_NAMES[defaults.anchor] or "Top Right" end,
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_AMOUNT_SHOW),
					tooltip = GetString(LWT_PI_S_AMOUNT_SHOW_T),
					getFunc = function() return settings.showAmount end,
					setFunc = function(value) settings.showAmount = value end,
					default = defaults.showAmount
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_AMOUNT_TEXT_SCALE),
					tooltip = GetString(LWT_PI_S_AMOUNT_TEXT_SCALE_T),
					getFunc = function() return settings.textScale end,
					setFunc = function(value) settings.textScale = value end,
					min = 1,
					max = 150,
					default = defaults.textScale,
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_AMOUNT_TEXT_BOLD),
					tooltip = GetString(LWT_PI_S_AMOUNT_TEXT_BOLD_T),
					getFunc = function() return settings.textBold end,
					setFunc = function(value) settings.textBold = value end,
					default = defaults.textBold,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_AMOUNT_OFFSET_X),
					tooltip = GetString(LWT_PI_S_AMOUNT_OFFSET_X_T),
					getFunc = function() return settings.xOffsetInv end,
					setFunc = function(value) settings.xOffsetInv = value end,
					min = -500,
					max = 500,
					disabled = function() return not settings.showAmount end,
					default = defaults.xOffsetInv,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_AMOUNT_OFFSET_Y),
					tooltip = GetString(LWT_PI_S_AMOUNT_OFFSET_Y_T),
					getFunc = function() return settings.yOffsetInv end,
					setFunc = function(value) settings.yOffsetInv = value end,
					min = -500,
					max = 500,
					disabled = function() return not settings.showAmount end,
					default = defaults.yOffsetInv,
				},
				{
					type = "dropdown",
					name = GetString(LWT_PI_S_AMOUNT_COLOR),
					tooltip = GetString(LWT_PI_S_AMOUNT_COLOR_T),
					choicesTooltips = {
						GetString(LWT_PI_S_AMOUNT_COLOR_WHITE),
						GetString(LWT_PI_S_AMOUNT_COLOR_SAME),
						GetString(LWT_PI_S_AMOUNT_COLOR_INTER)
					},
					choices = { "Base", "Same", "Separate" },
					getFunc = function() return settings.colorAmount end,
					setFunc = function(value) settings.colorAmount = value end,
					disabled = function() return not settings.showAmount end,
					default = defaults.colorAmount
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_COUNT_MIN),
					tooltip = GetString(LWT_PI_S_COUNT_MIN_T),
					getFunc = function() return settings.countMin end,
					setFunc = function(value)
						settings.countMin = value
						if settings.countMax <= value then
							settings.countMax = value + 1
						end
					end,
					min = 1,
					max = 500,
					disabled = function() return not settings.showAmount end,
					default = defaults.countMin,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_COUNT_MAX),
					tooltip = GetString(LWT_PI_S_COUNT_MAX_T),
					getFunc = function() return settings.countMax end,
					setFunc = function(value)
						settings.countMax = value
						if settings.countMin >= value then
							settings.countMin = value - 1
						end
					end,
					min = 2,
					max = 1000,
					disabled = function() return not settings.showAmount end,
					default = defaults.countMax,
				},
				{
					type = "dropdown",
					name = GetString(LWT_PI_S_VISIBILITY),
					tooltip = GetString(LWT_PI_S_VISIBILITY_T),
					choicesTooltips = {
						GetString(LWT_PI_S_VISIBILITY_ALWAYS),
						GetString(LWT_PI_S_VISIBILITY_OVER_MIN),
						GetString(LWT_PI_S_VISIBILITY_OVER_MED),
						GetString(LWT_PI_S_VISIBILITY_OVER_MAX)
					},
					choices = { "Always", "Over min price", "Over mid price", "Over max price" },
					getFunc = function() return settings.visibilityType end,
					setFunc = function(value) settings.visibilityType = value end,
					default = defaults.visibilityType
				},
				{
					type = "divider",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_CHAPTER_COLORS) end,
					width = "full",
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_BAD),
					getFunc = function()
						return
							settings.colors.colorBad.r,
							settings.colors.colorBad.g,
							settings.colors.colorBad.b,
							settings.colors.colorBad.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorBad.r = r
						settings.colors.colorBad.g = g
						settings.colors.colorBad.b = b
						settings.colors.colorBad.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorBad.r,
						g = defaults.colors.colorBad.g,
						b = defaults.colors.colorBad.b,
						a = defaults.colors.colorBad.a
					}
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_GOOD),
					getFunc = function()
						return
							settings.colors.colorGood.r,
							settings.colors.colorGood.g,
							settings.colors.colorGood.b,
							settings.colors.colorGood.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorGood.r = r
						settings.colors.colorGood.g = g
						settings.colors.colorGood.b = b
						settings.colors.colorGood.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorGood.r,
						g = defaults.colors.colorGood.g,
						b = defaults.colors.colorGood.b,
						a = defaults.colors.colorGood.a
					}
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_COLOR_PROFIT_USE),
					tooltip = GetString(LWT_PI_S_COLOR_PROFIT_USE_T),
					getFunc = function() return settings.profitableColor end,
					setFunc = function(value) settings.profitableColor = value end,
					default = defaults.profitableColor
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_PROFIT),
					disabled = function() return not settings.profitableColor end,
					getFunc = function()
						return
							settings.colors.colorProfitable.r,
							settings.colors.colorProfitable.g,
							settings.colors.colorProfitable.b,
							settings.colors.colorProfitable.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorProfitable.r = r
						settings.colors.colorProfitable.g = g
						settings.colors.colorProfitable.b = b
						settings.colors.colorProfitable.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorProfitable.r,
						g = defaults.colors.colorProfitable.g,
						b = defaults.colors.colorProfitable.b,
						a = defaults.colors.colorProfitable.a
					}
				},
				{
					type = "divider",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_CHAPTER_CRAFT) end,
					width = "full",
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_CRAFT_OFFSET_X),
					tooltip = GetString(LWT_PI_S_CRAFT_OFFSET_X_T),
					getFunc = function() return settings.xOffsetCraft end,
					setFunc = function(value) settings.xOffsetCraft = value end,
					min = -500,
					max = 500,
					default = defaults.xOffsetCraft,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_CRAFT_OFFSET_Y),
					tooltip = GetString(LWT_PI_S_CRAFT_OFFSET_Y_T),
					getFunc = function() return settings.yOffsetCraft end,
					setFunc = function(value) settings.yOffsetCraft = value end,
					min = -500,
					max = 500,
					default = defaults.yOffsetCraft,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_CRAFT_TEXT_SCALE),
					tooltip = GetString(LWT_PI_S_CRAFT_TEXT_SCALE_T),
					getFunc = function() return settings.textScaleCraft end,
					setFunc = function(value) settings.textScaleCraft = value end,
					min = 1,
					max = 150,
					default = defaults.textScaleCraft,
				},
				{
					type = "divider",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_CHAPTER_GUILD) end,
					width = "full",
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_GUILD_OFFSET_X),
					tooltip = GetString(LWT_PI_S_GUILD_OFFSET_X_T),
					getFunc = function() return settings.xOffsetGuild end,
					setFunc = function(value) settings.xOffsetGuild = value end,
					min = -500,
					max = 500,
					default = defaults.xOffsetGuild,
				},
				{
					type = "slider",
					name = GetString(LWT_PI_S_GUILD_OFFSET_Y),
					tooltip = GetString(LWT_PI_S_GUILD_OFFSET_Y_T),
					getFunc = function() return settings.yOffsetGuild end,
					setFunc = function(value) settings.yOffsetGuild = value end,
					min = -500,
					max = 500,
					default = defaults.yOffsetGuild,
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_GUILD_DELTA),
					tooltip = GetString(LWT_PI_S_GUILD_DELTA_T),
					getFunc = function() return settings.guildPriceDelta end,
					setFunc = function(value) settings.guildPriceDelta = value end,
					default = defaults.guildPriceDelta
				},
				{
					type = "checkbox",
					name = GetString(LWT_PI_S_GUILD_DELTA_FEE),
					tooltip = GetString(LWT_PI_S_GUILD_DELTA_FEE_T),
					getFunc = function() return settings.guildFee end,
					setFunc = function(value) settings.guildFee = value end,
					disabled = function() return not settings.guildPriceDelta end,
					default = defaults.guildFee
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_GUILD_BAD_START),
					disabled = function() return not settings.guildPriceDelta end,
					getFunc = function()
						return
							settings.colors.colorGuildBadStart.r,
							settings.colors.colorGuildBadStart.g,
							settings.colors.colorGuildBadStart.b,
							settings.colors.colorGuildBadStart.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorGuildBadStart.r = r
						settings.colors.colorGuildBadStart.g = g
						settings.colors.colorGuildBadStart.b = b
						settings.colors.colorGuildBadStart.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorGuildBadStart.r,
						g = defaults.colors.colorGuildBadStart.g,
						b = defaults.colors.colorGuildBadStart.b,
						a = defaults.colors.colorGuildBadStart.a
					}
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_GUILD_BAD_END),
					disabled = function() return not settings.guildPriceDelta end,
					getFunc = function()
						return
							settings.colors.colorGuildBadEnd.r,
							settings.colors.colorGuildBadEnd.g,
							settings.colors.colorGuildBadEnd.b,
							settings.colors.colorGuildBadEnd.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorGuildBadEnd.r = r
						settings.colors.colorGuildBadEnd.g = g
						settings.colors.colorGuildBadEnd.b = b
						settings.colors.colorGuildBadEnd.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorGuildBadEnd.r,
						g = defaults.colors.colorGuildBadEnd.g,
						b = defaults.colors.colorGuildBadEnd.b,
						a = defaults.colors.colorGuildBadEnd.a
					}
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_GUILD_GOOD_START),
					disabled = function() return not settings.guildPriceDelta end,
					getFunc = function()
						return
							settings.colors.colorGuildGoodStart.r,
							settings.colors.colorGuildGoodStart.g,
							settings.colors.colorGuildGoodStart.b,
							settings.colors.colorGuildGoodStart.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorGuildGoodStart.r = r
						settings.colors.colorGuildGoodStart.g = g
						settings.colors.colorGuildGoodStart.b = b
						settings.colors.colorGuildGoodStart.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorGuildGoodStart.r,
						g = defaults.colors.colorGuildGoodStart.g,
						b = defaults.colors.colorGuildGoodStart.b,
						a = defaults.colors.colorGuildGoodStart.a
					}
				},
				{
					type = "colorpicker",
					name = GetString(LWT_PI_S_COLOR_GUILD_GOOD_END),
					disabled = function() return not settings.guildPriceDelta end,
					getFunc = function()
						return
							settings.colors.colorGuildGoodEnd.r,
							settings.colors.colorGuildGoodEnd.g,
							settings.colors.colorGuildGoodEnd.b,
							settings.colors.colorGuildGoodEnd.a
					end,
				setFunc = function(r, g, b, a)
						settings.colors.colorGuildGoodEnd.r = r
						settings.colors.colorGuildGoodEnd.g = g
						settings.colors.colorGuildGoodEnd.b = b
						settings.colors.colorGuildGoodEnd.a = a
						LWTPriceInfo.InvalidateColorCache()
					end,
					default =
					{
						r = defaults.colors.colorGuildGoodEnd.r,
						g = defaults.colors.colorGuildGoodEnd.g,
						b = defaults.colors.colorGuildGoodEnd.b,
						a = defaults.colors.colorGuildGoodEnd.a
					}
				},
			}
		})
	table.insert(data, { type = "divider" })
end

function LWTPriceInfo.CreateErrorsSettings(data, name)
	if (string.len(LWTPriceInfo.errorLog) > 0) then
		table.insert(data,
			{
				type = "submenu",
				name = name,
				controls = {
					{
						type = "description",
						text = function() return LWTPriceInfo.errorLog end,
						width = "full",
					}
				}
			})
		table.insert(data, { type = "divider" })
	end
end

function LWTPriceInfo.CreateHelpSettings(data, name)
	table.insert(data,
		{
			type = "submenu",
			name = name,
			controls = {
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_INFO_1) end,
					width = "full",
				},
				{
					type = "divider"
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_MARKER_1) end,
					width = "full",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_MARKER_2) end,
					width = "full",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_MARKER_3) end,
					width = "full",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_MARKER_4) end,
					width = "full",
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_MARKER_5) end,
					width = "full",
				},
				{
					type = "divider"
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_ERRORS) end,
					width = "full",
				},
				{
					type = "divider"
				},
				{
					type = "description",
					text = function() return GetString(LWT_PI_S_HELP_TBC) end,
					width = "full",
				},
			}
		})
	table.insert(data, { type = "divider" })
end

function LWTPriceInfo.RGBA2HSLA(r, g, b, a)
	local min = math.min(r, g, b)
	local max = math.max(r, g, b)
	local delta = max - min

	local h, s, l = 0, 0, (min + max) / 2

	if l > 0 and l < 0.5 then s = delta / (max + min) end
	if l >= 0.5 and l < 1 then s = delta / (2 - max - min) end

	if delta > 0 then
		if max == r and max ~= g then h = h + (g-b) / delta end
		if max == g and max ~= b then h = h + 2 + (b-r) / delta end
		if max == b and max ~= r then h = h + 4 + (r-g) / delta end
		h = h / 6
	end

	if h < 0 then h = h + 1 end
	if h > 1 then h = h - 1 end

	return h * 360, s, l, a
end

function LWTPriceInfo.HSLA2RGBA(h, s, l, a)
	local C = ( 1 - math.abs( l + l - 1 ))*s
	local m = l - 0.5*C
	local r, g, b = m, m, m
	if h == h then
		local h_ = (h / 360.0 % 1.0) * 6.0
		local X = C * (1 - math.abs(h_ % 2 - 1))
		C, X = C + m, X + m
		if     h_ < 1 then r, g, b = C, X, m
		elseif h_ < 2 then r, g, b = X, C, m
		elseif h_ < 3 then r, g, b = m, C, X
		elseif h_ < 4 then r, g, b = m, X, C
		elseif h_ < 5 then r, g, b = X, m, C
		else               r, g, b = C, m, X
		end
	end

	return r, g, b, a
end

local hslCache = {}

local function getHSLCached(color)
	local key = color
	if not hslCache[key] then
		local h, s, l, a = LWTPriceInfo.RGBA2HSLA(color.r, color.g, color.b, color.a)
		hslCache[key] = { h = h, s = s, l = l, a = a }
	end
	return hslCache[key]
end

function LWTPriceInfo.InvalidateColorCache()
	hslCache = {}
end

function LWTPriceInfo.ColorInterpolateHSL(value, min, max, colorA, colorB)
	value = math.min(math.max(value, min), max)

	local proportion = (value - min) / (max - min)

	local cA = getHSLCached(colorA)
	local cB = getHSLCached(colorB)
	local hA, sA, lA, aA = cA.h, cA.s, cA.l, cA.a
	local hB, sB, lB, aB = cB.h, cB.s, cB.l, cB.a

	if (hA > 180 and hB < hA - 180) then
		hB = hB + 360
	end
	if (hA < 180 and hB > hA + 180) then
		hA = hA + 360
	end

	local hInterpolated = hA + (hB - hA) * proportion
	local sInterpolated = sA + (sB - sA) * proportion
	local lInterpolated = lA + (lB - lA) * proportion
	local aInterpolated = aA + (aB - aA) * proportion

	hInterpolated = hInterpolated % 360.0

	local colorC = {}
	colorC.r, colorC.g, colorC.b, colorC.a = LWTPriceInfo.HSLA2RGBA(hInterpolated, sInterpolated, lInterpolated, aInterpolated)

	return colorC
end

function LWTPriceInfo.RGB2HEX(r, g, b)
	return string.format("%02x%02x%02x",
		math.floor(r * 255),
		math.floor(g * 255),
		math.floor(b * 255))
end
