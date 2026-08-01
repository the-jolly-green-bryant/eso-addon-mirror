ADR = ADR or {}

function ADR.SetupPCSettings()

	local panelName = "AlternateDeathRecap"
	local panelData = {
		type = "panel",
		name = "AlternateDeathRecap",
		author = "Shienar",
	}

	local optionsTable = {
		{
			type = "description",
			title = "[General]",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Compact Mode",
			tooltip = "Replaces the default death recap format with a more compact version.",
			width = "full",
			getFunc = function() return ADR.savedVariables.isCompact end,
			setFunc = function(value) ADR.savedVariables.isCompact = value end,
		},
		{
			type = "checkbox",
			name = "Show Animation",
			tooltip = "Shows the death recap animation. Disable to fully turn off the animation.",
			width = "full",
			getFunc = function() return ADR.savedVariables.animationsEnabled end,
			setFunc = function(value) ADR.savedVariables.animationsEnabled = value end,
		},

		{
			type = "slider",
			name = "Animation Length (ms)",
			tooltip = "Set the length the animation in the death recap.",
			min = 10,
			max = 1000,
			step = 10,
			width = "full",
			getFunc = function() return ADR.savedVariables.animationSpeed end,
			setFunc = function(value) 
				ADR.savedVariables.animationSpeed = value 
				EVENT_MANAGER:RegisterForUpdate(ADR.name.."Post Settings Change", 1500, function()
					ADR.updateExistingAnimations()
					EVENT_MANAGER:UnregisterForUpdate(ADR.name.."Post Settings Change")
				end)
			end,
		},
		{
			type = "slider",
			name = "Max Attacks",
			tooltip = "Set the limit on how many attacks this addon will keep track of.",
			min = 1,
			max = 50,
			step = 1,
			width = "full",
			getFunc = function() return ADR.savedVariables.maxAttacks end,
			setFunc = function(value)
				ADR.savedVariables.maxAttacks = value
				
				while ADR.attackList.size > ADR.savedVariables.maxAttacks do
					ADR.DequeueAttack()
				end
			end,
		},
		{
			type = "slider",
			name = "Max Time",
			tooltip = "The addon will only display attacks that occurred within the last X seconds.",
			min = 1,
			max = 60,
			step = 1,
			width = "full",
			getFunc = function() return ADR.savedVariables.timeLength end,
			setFunc = function(value) ADR.savedVariables.timeLength = value end,
		},
		{
			type = "slider",
			name = "Scroll Boost",
			tooltip = "Increases the death recap's scrolling speed by X%.",
			min = 0,
			max = 1000,
			step = 10,
			width = "full",
			getFunc = function() return ADR.savedVariables.scrollSensitivityBoost end,
			setFunc = function(value) ADR.savedVariables.scrollSensitivityBoost = value end,
		},

		
		{
			type = "dropdown",
			name = "Health Display",
			tooltip = "How would you like your saved current/max health to be displayed per attack in the recap?.",
			choices = {"Current/Max", "Current", "Percentage", "None"},
			getFunc = function() return ADR.savedVariables.healthDisplay or "Current/Max" end,
			setFunc = function(var) ADR.savedVariables.healthDisplay = var end,
			width = "full",
		},

		{
			type = "divider",
		},

		{
			type = "description",
			title = "[Filters]",
			width = "full",
		},


		{
			type = "checkbox",
			name = "Heals",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackHeals end,
			setFunc = function(value) ADR.savedVariables.trackHeals = value end,
		},
		{
			type = "checkbox",
			name = "Heal Absorb",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackHealAbsorb end,
			setFunc = function(value) ADR.savedVariables.trackHealAbsorb = value end,
		},
		{
			type = "checkbox",
			name = "Dodge",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackDodged end,
			setFunc = function(value) ADR.savedVariables.trackDodged = value end,
		},
		{
			type = "checkbox",
			name = "Interrupted",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackInterrupted end,
			setFunc = function(value) ADR.savedVariables.trackInterrupted = value end,
		},
		{
			type = "checkbox",
			name = "Rooted",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackRooted end,
			setFunc = function(value) ADR.savedVariables.trackRooted = value end,
		},
		{
			type = "checkbox",
			name = "Snared",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackSnared end,
			setFunc = function(value) ADR.savedVariables.trackSnared = value end,
		},
		{
			type = "checkbox",
			name = "Silenced",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackSilenced end,
			setFunc = function(value) ADR.savedVariables.trackSilenced = value end,
		},
		{
			type = "checkbox",
			name = "Stunned",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackStunned end,
			setFunc = function(value) ADR.savedVariables.trackStunned = value end,
		},
		{
			type = "checkbox",
			name = "Feared",
			tooltip = "Only show this event in recap when this option is set to ON.",
			width = "half",
			getFunc = function() return ADR.savedVariables.trackFeared end,
			setFunc = function(value) ADR.savedVariables.trackFeared = value end,
		}

	}

	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end