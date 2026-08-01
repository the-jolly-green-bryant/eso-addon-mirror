local SlowDialogs = SlowDialogsGlobal
local panelData = {
	type = "panel",
	name = "Slow Dialogs",
	displayName = SlowDialogs.displayName,
	author = "Shinni",
	version = "1.13",
	registerForRefresh = true,
	registerForDefaults = false,
}

local optionsTable = {
	{
		type = "slider",
		name = SlowDialogs.delayOption,
		tooltip = SlowDialogs.delayTooltip,
		min = 1,
		step = 1,
		max = 100,
		getFunc = function() return SlowDialogs.settings.speed end,
		setFunc = function(value) SlowDialogs.settings.speed = value end,
		width = "half",
		default = 30,
	},
	{
		type = "slider",
		name = SlowDialogs.startDelayOption,
		tooltip = SlowDialogs.startDelayTooltip,
		min = 1,
		step = 1,
		max = 1200,
		getFunc = function() return SlowDialogs.settings.start_delay end,
		setFunc = function(value) SlowDialogs.settings.start_delay = value end,
		width = "half",
		default = 5,
	},
	{
		type = "slider",
		name = SlowDialogs.fadeLengthOption,
		tooltip = SlowDialogs.fadeLengthTooltip,
		min = 1,
		step = 1,
		max = 100,
		getFunc = function() return SlowDialogs.settings.animation_length end,
		setFunc = function(value) SlowDialogs.settings.animation_length = value end,
		width = "half",
		default = 20,
	},
}

function SlowDialogsGlobal.InitOptions()
	LibAddonMenu2:RegisterAddonPanel("SlowDialogsControl", panelData)
	LibAddonMenu2:RegisterOptionControls("SlowDialogsControl", optionsTable)
end