function LH.initializeSettingsMenu()

	local defaults = {
		lockui = false,
	}

	local panelData = {
		type = "panel",
		name = "Llothis",
		displayName = "Llothis",
		author = "ownedbynico",
		version = LH.version,
	}
	
	local optionsData = {
		{
			type = "checkbox",
			name = "Lock UI",
			getFunc = function() return LH.savedVariables.lockui end,
			setFunc = function(value)
						LH.savedVariables.lockui = value
						LlothisTracker:SetMovable(not value)
					  end,
			width = "full",
		},
	}

	LH.savedVariables = ZO_SavedVars:NewAccountWide("LHSV", 1, nil, defaults)
	LibAddonMenu2:RegisterAddonPanel("LHS", panelData)
	LibAddonMenu2:RegisterOptionControls("LHS", optionsData)
end