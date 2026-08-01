SurgingWater = SurgingWater or {}

function SurgingWater.AddonMenu()
	--Header above options menu
	local r, g, b, a = unpack(SurgingWater.warnColor)
	local menuOptions = {
		type = "panel",
		name = SurgingWater.name,
		displayName = "Surging Waters Synergy Warning",
		author = SurgingWater.author,
		version = SurgingWater.version,
		slashCommand = "/sw",
		registerForRefreshh = true,
		registerForDefaults = true,
	}
	--Options Menu. GetFunc populates the menu field, SetFunc passes new value to function when a change is made to setting
	local dataTable = {
		{
			type = "description",
			text = "A simple warning to prevent players from taking the Surging Waters synergy on Reef Guardian too early if they intend on staying downstairs for another portal.",
		},
		{
			type = "header",
			name = "Options",
			width = "full",
		},
		{
			type    = "checkbox",
			name    = "Unlock UI",
			tooltip = "Toggle 'On' to move warning's on screen position",
			default = false,
			getFunc = function() return false end,
			setFunc = function(newVal) SurgingWater.MoveWarning() SurgingWater.unlockedUI = not newVal; end,
		},
		{
			type = "slider",
			name = "Warning Threshold",
			tooltip = "Set the % threshold at which the synergy warning is triggered",
			min = 0,
			max = 100,
			step = 1,	
			getFunc = function() return SurgingWater.threshold end,
			setFunc = function(value) SurgingWater.EditThreshold(value) SurgingWater.threshold = value end,
			width = "full",	
			--default = 15,	
		},
		{
			type = "divider"
		},		
		{
			type = "editbox",
			name = "Warning Text",
			tooltip = "Edit the warning that displays when Reef Heart health gets low",
			getFunc = function() return SurgingWater.warnText end,
			setFunc = function(newText) SurgingWater.EditWarning(newText) SurgingWater.warnText = newText end,
			isMultiline = false,
			width = "full",
			--default = "BEWARE SYNERGY!",
		},
		{
			type = "slider",
			name = "Warning Size",
			tooltip = "Set the size of the warning",
			min = 25,
			max = 72,
			step = 1,	
			getFunc = function() return SurgingWater.warnSize end,
			setFunc = function(size) SurgingWater.EditSize(size) SurgingWater.warnSize = size end,
			width = "full",	
			--default = 15,	
		},
		{
			type = "colorpicker",
			name = "Warning Color",
			tooltip = "Set the color of the warning message",
			getFunc = function() return unpack(SurgingWater.warnColor) end,
			setFunc = function(r,g,b,a) SurgingWater.WarnColor(r, g, b, a) SurgingWater.warnColor = {r, g, b, a} end,
			width = "full",
			warning = "Color will update next time text is displayed",
		},
	}

	--Instantiate LAM2
	LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(SurgingWater.name .. "Options", menuOptions)
	LAM:RegisterOptionControls(SurgingWater.name .. "Options", dataTable)
end