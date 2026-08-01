DoubleCastProtection = DoubleCastProtection or {}
local DoubleCastProtection = DoubleCastProtection

function DoubleCastProtection.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Makos's Double Cast Protection",
		displayName	 = "|cFF00F7Makos's Double Cast Protection|r",
		author			 = DoubleCastProtection.author,
		version			 = DoubleCastProtection.version,
		slashCommand = "/msc",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "header",
			name = "|cFFFACDSettings|r",
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Block ground double cast",
			tooltip = "Prevents ground abilities for being queued/buffered during GCD",
			default = true,
			getFunc = function() return DoubleCastProtection.savedVariables.blockGround end,
			setFunc = function(value)
				DoubleCastProtection.savedVariables.blockGround = value
			end,
		},
		{
			type = "slider",
			name = "Buffer Lock (ms)",
			tooltip = "Duration in ms which defines for how long you want to be locked from casting ground abilities after ground ability has been pressed",
			min = 1,
			max = 1000,
			clampInput = true,
			getFunc = function() return DoubleCastProtection.savedVariables.lockms end,
			setFunc = function(value)
				DoubleCastProtection.savedVariables.lockms = value
			end,
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(DoubleCastProtection.name .. "Options2", menuOptions )
	LAM:RegisterOptionControls(DoubleCastProtection.name .. "Options2", dataTable )
end
