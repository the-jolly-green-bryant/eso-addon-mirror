local ST = SphereTips
local LAM = LibAddonMenu2


ST.FontData = {
	Fonts = { -- stolen from Urichs skill point finder, big thank
		Names = {"ProseAntique", "Consolas", "Futura Condensed", "Futura Condensed Bold", "Futura Condensed Light", "Skyrim Handwritten", "Trajan Pro", "Univers 55", "Univers 57", "Univers 67"},
		["ProseAntique"]			= ZoFontBookPaper:GetFontInfo(),					--ANTIQUE_FONT
		["Consolas"]				= "/EsoUI/Common/Fonts/consola.ttf",				--
		["Futura Condensed"]		= "/EsoUI/Common/Fonts/FTN57.otf",					--GAMEPAD_MEDIUM_FONT
		["Futura Condensed Bold"]	= "/EsoUI/Common/Fonts/FTN87.otf",					--GAMEPAD_BOLD_FONT
		["Futura Condensed Light"]	= "/EsoUI/Common/Fonts/FTN47.otf",					--GAMEPAD_LIGHT_FONT
		["Skyrim Handwritten"]		= ZoFontBookLetter:GetFontInfo(),					--HANDWRITTEN_FONT
		["Trajan Pro"]				= ZoFontBookTablet:GetFontInfo(),					--STONE_TABLET_FONT
		["Univers 55"]				= "/EsoUI/Common/Fonts/univers55.otf",				--
		["Univers 57"]				= ZoFontGame:GetFontInfo(),							--MEDIUM_FONT/CHAT_FONT
		["Univers 67"]				= ZoFontGameBold:GetFontInfo(),						--BOLD_FONT
	},
	Outlines = {"thick-outline", "soft-shadow-thick", "soft-shadow-thin", "none" },
}

function SphereTips_LoadSettings()
	local panelData = {
		type = "panel",
		name = "SphereTips",
		displayName = "SphereTips",
		author = "Shadowwolf136",
		version = "0.3",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	LAM:RegisterAddonPanel("SphereTips", panelData)
	
	local optionsTable = {
		{
			type = "button",
			name = "Preview UI",
			tooltip = "Preview the UI size and location.",
			func = function()
				ST.ToggleUI()
			end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "UI Lock",
			tooltip = "Lock the UI so you don't move it by accident.",
			getFunc = function() return ST.SavedVars.isUIlocked end,
			setFunc = function(value)
				ST.SavedVars.isUIlocked = value
				SphereTipsUI:SetMovable(not value)
				SphereTipsUI:SetMouseEnabled(not value)
				SphereTipsTimerUI:SetMovable(not value)
				SphereTipsTimerUI:SetMouseEnabled(not value)
			end,
			width = "full",
			default = ST.defaults.isUIlocked,
		},
		{
			type = "header",
			name = "Health bars",
		},
		{
			type = "colorpicker",
			name = "Health bar color",
			tooltip = "Change the color of the health bars.",
			getFunc = function() return unpack(ST.SavedVars.barColor) end,
			setFunc = function(r, g, b)
				ST.SavedVars.barColor = {r, g, b}
				ST.SetBarColor()
			end,
			width = "full",
			default = ST.RepackColor(ST.defaults.barColor),
		},
		{
			type = "slider",
			name = "Health bar height",
			tooltip = "Change the size of the health bars.",
			min = 10,
			max = 50,
			step = 1,
			getFunc = function() return ST.SavedVars.barHeight end,
			setFunc = function(value)
				ST.SavedVars.barHeight = value
				ST.ResizeUI()
			end,
			width = "full",
			default = ST.defaults.barHeight,
		},
		{
			type = "slider",
			name = "Health bar length",
			tooltip = "Change the size of the health bars.",
			min = 100,
			max = 500,
			step = 1,
			getFunc = function() return ST.SavedVars.barWidth end,
			setFunc = function(value)
				ST.SavedVars.barWidth = value
				ST.ResizeUI()
			end,
			width = "full",
			default = ST.defaults.barWidth,
		},
		{
			type = "slider",
			name = "Health bar offset",
			tooltip = "Change the distance between the health bars.",
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return ST.SavedVars.barOffset end,
			setFunc = function(value)
				ST.SavedVars.barOffset = value
				ST.OffsetBars()
			end,
			width = "full",
			default = ST.defaults.barOffset,
		},
		{
			type = "checkbox",
			name = "Invert bar order",
			tooltip = "Use health bars bottom to top instead of top to bottom.",
			getFunc = function() return ST.SavedVars.invertBarOrder end,
			setFunc = function(value)
				ST.SavedVars.invertBarOrder = value
			end,
			width = "full",
			default = ST.defaults.invertBarOrder,
		},
		{
			type = "checkbox",
			name = "Rainbow mode",
			tooltip = "Randomizes the color of each health bar each time it takes damage.",
			getFunc = function() return ST.SavedVars.rainbowMode end,
			setFunc = function(value)
				ST.SavedVars.rainbowMode = value
				ST.SetBarColor()
			end,
			width = "full",
			warning = "Could create bright flashing lights!",
			default = ST.defaults.rainbowMode,
		},
		{
			type = "colorpicker",
			name = "Health font color",
			tooltip = "Change the color of the health percentage.",
			getFunc = function() return unpack(ST.SavedVars.healthTextColor) end,
			setFunc = function(r, g, b)
				ST.SavedVars.healthTextColor = {r, g, b}
				ST.SetHealthTextColor()
			end,
			width = "full",
			default = ST.RepackColor(ST.defaults.healthTextColor),
		},
		{
			type = "dropdown",
			name = "Health font",
			tooltip = "Change the font of the health percentage.",
			choices = ST.FontData.Fonts.Names,
			getFunc = function() return ST.SavedVars.healthTextFont end,
			setFunc = function(var)
				ST.SavedVars.healthTextFont = var
				ST.SetHealthTextFont()
			end,
			width = "full",
			default = ST.defaults.healthTextFont,
		},
		{
			type = "dropdown",
			name = "Health font outline",
			tooltip = "Change the outline of the health percentage.",
			choices = ST.FontData.Outlines,
			getFunc = function() return ST.SavedVars.healthTextFontOutline end,
			setFunc = function(var)
				ST.SavedVars.healthTextFontOutline = var
				ST.SetHealthTextFont()
			end,
			width = "full",
			default = ST.defaults.healthTextFontOutline,
		},
		{
			type = "slider",
			name = "Health font size",
			tooltip = "Change the size of the health percentage.",
			min = 10,
			max = 50,
			step = 1,
			getFunc = function() return tonumber(ST.SavedVars.healthTextFontSize) end,
			setFunc = function(value)
				ST.SavedVars.healthTextFontSize = tostring(value)
				ST.SetHealthTextFont()
			end,
			width = "full",
			default = ST.defaults.healthTextFontSize,
		},
		{
			type = "header",
			name = "Timers",
		},
		{
			type = "checkbox",
			name = "Print sphere kill time",
			tooltip = "When a sphere dies, post the time it took for it to be killed in chat.",
			getFunc = function() return ST.SavedVars.killTimePrint end,
			setFunc = function(value)
				ST.SavedVars.killTimePrint = value
			end,
			width = "full",
			default = ST.defaults.killTimePrint,
		},
		{
			type = "checkbox",
			name = "Show next sphere countdown",
			tooltip = "Show how long it will take for the next sphere to spawn after a sphere dies.",
			getFunc = function() return ST.SavedVars.showNextSphereTimer end,
			setFunc = function(value)
				ST.SavedVars.showNextSphereTimer = value
			end,
			width = "full",
			default = ST.defaults.showNextSphereTimer,
		},
		{
			type = "checkbox",
			name = "Show penalty sphere countdown",
			tooltip = "Show how long it will take for an extra sphere to spawn if you don't kill spheres.",
			getFunc = function() return ST.SavedVars.showPenaltySphereTimer end,
			setFunc = function(value)
				ST.SavedVars.showPenaltySphereTimer = value
			end,
			width = "full",
			default = ST.defaults.showPenaltySphereTimer,
		},
		{
			type = "colorpicker",
			name = "Timer color",
			tooltip = "Change the color of the timer.",
			getFunc = function() return unpack(ST.SavedVars.timerColor) end,
			setFunc = function(r, g, b)
				ST.SavedVars.timerColor = {r, g, b}
				ST.SetTimerColor()
			end,
			width = "full",
			default = ST.RepackColor(ST.defaults.timerColor),
		},
		{
			type = "dropdown",
			name = "Timer font",
			tooltip = "Change the font of the timer.",
			choices = ST.FontData.Fonts.Names,
			getFunc = function() return ST.SavedVars.timerFont end,
			setFunc = function(var)
				ST.SavedVars.timerFont = var
				ST.SetTimerFont()
			end,
			width = "full",
			default = ST.defaults.timerFont,
		},
		{
			type = "dropdown",
			name = "Timer font outline",
			tooltip = "Change the outline of the timer.",
			choices = ST.FontData.Outlines,
			getFunc = function() return ST.SavedVars.timerFontOutline end,
			setFunc = function(var)
				ST.SavedVars.timerFontOutline = var
				ST.SetTimerFont()
			end,
			width = "full",
			default = ST.defaults.timerFontOutline,
		},
		{
			type = "slider",
			name = "Timer font size",
			tooltip = "Change the size of the timer.",
			min = 10,
			max = 50,
			step = 1,
			getFunc = function() return tonumber(ST.SavedVars.timerFontSize) end,
			setFunc = function(value)
				ST.SavedVars.timerFontSize = tostring(value)
				ST.SetTimerFont()
			end,
			width = "full",
			default = ST.defaults.timerFontSize,
		},
	}
	
	LAM:RegisterOptionControls("SphereTips", optionsTable)
	
end