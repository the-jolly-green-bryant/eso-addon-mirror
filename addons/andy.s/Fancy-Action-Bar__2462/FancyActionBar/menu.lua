local FAB = FancyActionBar
local LAM = LibAddonMenu2

function FAB.BuildMenu(SV, defaults)

	local panel = {
		type = 'panel',
		name = 'Fancy Action Bar',
		displayName = 'Fancy Action Bar',
		author = '|cFFFF00@andy.s|r',
		version = string.format('|c00FF00%s|r', FAB.GetVersion()),
		website = 'https://www.esoui.com/downloads/fileinfo.php?id=2462',
		--donation = 'https://www.esoui.com/downloads/info2311-HodorReflexes-DPSampUltimateShare.html#donate',
		registerForRefresh = true,
	}

	local options = {
		{
			type = "header",
			name = "|cFFFACDGeneral|r",
		},
		{
			type = "checkbox",
			name = "Static bar positions",
			tooltip = "Front bar and back bar won't switch places on weapon swap.",
			default = defaults.staticBars,
			getFunc = function() return SV.staticBars end,
			setFunc = function(value)
				SV.staticBars = value or false
			end,
			requiresReload = true,
		},
		{
			type = "checkbox",
			name = "Show hotkeys",
			tooltip = "Show hotkeys under the action bar.",
			default = defaults.showHotkeys,
			getFunc = function() return SV.showHotkeys end,
			setFunc = function(value)
				SV.showHotkeys = value or false
				FAB.ToggleHotkeys()
			end,
			width = 'half',
		},
		{
			type = "checkbox",
			name = "Show highlight",
			tooltip = "Active skills will be highlighted.",
			default = defaults.showHighlight,
			getFunc = function() return SV.showHighlight end,
			setFunc = function(value)
				SV.showHighlight = value or false
			end,
			width = 'half',
		},
		{
			type = "checkbox",
			name = "Show arrow",
			tooltip = "Show an arrow pointing at the current bar (only for static bars).",
			default = defaults.showArrow,
			getFunc = function() return SV.showArrow end,
			setFunc = function(value)
				SV.showArrow = value or false
				FAB_ActionBarArrow:SetHidden(not SV.showArrow)
			end,
			width = 'half',
			disabled = function() return not SV.staticBars end,
		},
		{
			type = "colorpicker",
			name = "Arrow color",
			default = ZO_ColorDef:New(unpack(defaults.arrowColor)),
			getFunc = function() return unpack(SV.arrowColor) end,
			setFunc = function(r, g, b)
				SV.arrowColor = {r, g, b}
				FAB_ActionBarArrow:SetColor(unpack(SV.arrowColor))
			end,
			width = 'half',
			disabled = function() return not SV.staticBars end,
		},
		{
			type = "header",
			name = "|cFFFACDBackbar|r",
		},
		{
			type = "slider",
			name = "Button alpha",
			tooltip = "Lower value = less visible backbar.",
			min = 0.2,
			max = 1,
			step = 0.01,
			decimals = 2,
			clampInput = true,
			default = defaults.backBarAlpha,
			getFunc = function() return SV.backBarAlpha end,
			setFunc = function(value)
				FAB.SetBackBarAlphaAndDesaturation(value, SV.backBarDesaturation)
			end,
			width = 'half',
		},
		{
			type = "slider",
			name = "Button desaturation",
			tooltip = "Lower value = more colorful backbar.",
			min = 0,
			max = 1,
			step = 0.01,
			decimals = 2,
			clampInput = true,
			default = defaults.backBarDesaturation,
			getFunc = function() return SV.backBarDesaturation end,
			setFunc = function(value)
				FAB.SetBackBarAlphaAndDesaturation(SV.backBarAlpha, value)
			end,
			width = 'half',
		},
		{
			type = "header",
			name = "|cFFFACDNumbers|r",
		},
		{
			type = "colorpicker",
			name = "Default color",
			tooltip = "Default color for skills duration.",
			default = ZO_ColorDef:New(unpack(defaults.timerColor)),
			getFunc = function() return unpack(SV.timerColor) end,
			setFunc = function(r, g, b)
				SV.timerColor = {r, g, b}
			end,
			width = 'half',
		},
		{
			type = "colorpicker",
			name = "Zero color",
			tooltip = "Color of the number 0, when a skill duration ends.",
			default = ZO_ColorDef:New(unpack(defaults.zeroColor)),
			getFunc = function() return unpack(SV.zeroColor) end,
			setFunc = function(r, g, b)
				SV.zeroColor = {r, g, b}
			end,
			width = 'half',
		},
		{
			type = "slider",
			name = "Decimal threshold",
			tooltip = "Any number lower than this will be displayed as a decimal. Set to 0 to disable.",
			min = 0,
			max = 10,
			step = 0.1,
			decimals = 1,
			clampInput = true,
			default = defaults.decimalThreshold,
			getFunc = function() return SV.decimalThreshold end,
			setFunc = function(value)
				SV.decimalThreshold = value
			end,
			width = 'half',
		},
		{
			type = "colorpicker",
			name = "Decimal color",
			tooltip = "Color of decimal numbers.",
			default = ZO_ColorDef:New(unpack(defaults.decimalColor)),
			getFunc = function() return unpack(SV.decimalColor) end,
			setFunc = function(r, g, b)
				SV.decimalColor = {r, g, b}
			end,
			width = 'half',
		},
		{
			type = "header",
			name = "|cFFFACDSkills|r",
		},
		{
			type = "checkbox",
			name = "6s Power of the Light",
			default = defaults.potlfix,
			getFunc = function() return SV.potlfix end,
			setFunc = function(value)
				SV.potlfix = value or false
			end,
		},
		{
			type = "header",
			name = "|cFFFACDMisc|r",
		},
		{
			type = "checkbox",
			name = "Debug mode",
			tooltip = "Display internal events in the game chat.",
			default = false,
			getFunc = function() return FAB.IsDebugMode() end,
			setFunc = function(value)
				FAB.SetDebugMode(value or false)
			end,
		},
	}

	local name = FAB.GetName() .. 'Menu'
    LAM:RegisterAddonPanel(name, panel)
    LAM:RegisterOptionControls(name, options)

end