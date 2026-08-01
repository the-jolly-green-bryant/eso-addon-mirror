Outkasted = Outkasted or {}

function Outkasted.initMenu()

	local defaults = {
		accountWide = true,
	}

	local panelData = {
		type = "panel",
		name = "Outkasted",
		displayName = "Outkasted",
		author = "Flightkick",
		version = Outkasted.version,
		registerForRefresh = true,
		website = "https://github.com/Flightkick/eso-outkasted-guild-addon",
	}

	local optionsData = {
		{
			type = "checkbox",
			name = "Account-wide settings",
			getFunc = function() return Outkasted.savedVariablesChar.accountWide end,
			setFunc = function(value)
				Outkasted.savedVariablesChar.accountWide = value
				Outkasted.savedVariables = value and Outkasted.savedVariablesAccount or Outkasted.savedVariablesChar
			end,
			width = "full",
		},
	}

	Outkasted.savedVariablesAccount = ZO_SavedVars:NewAccountWide("OutkastedSavedVars", 1, nil, defaults)
	Outkasted.savedVariablesChar = ZO_SavedVars:NewCharacterIdSettings("OutkastedSavedVars", 1, nil, defaults)

	Outkasted.savedVariables = Outkasted.savedVariablesChar
	if Outkasted.savedVariablesChar.accountWide == true then
		Outkasted.savedVariables = Outkasted.savedVariablesAccount
	end
	
	LibAddonMenu2:RegisterAddonPanel("OUTKASTEDS", panelData)
	LibAddonMenu2:RegisterOptionControls("OUTKASTEDS", optionsData)
end
