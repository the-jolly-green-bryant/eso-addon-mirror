function MIB.initializeSettingsMenu()

	local defaults = {
		lockui = false,
	}

	local panelData = {
		type = "panel",
		name = "May I Bash?",
		displayName = "May I |cFFA500Bash|r?",
		author = "ownedbynico",
		version = MIB.version,
		registerForRefresh = true,
	}
	
	local optionsData = {
		{
			type = "checkbox",
			name = "Lock UI",
			getFunc = function() return MIB.savedVariables.lockui end,
			setFunc = function(value)
						MIB.savedVariables.lockui = value
						MIBTracker:SetMovable(not value)
					  end,
			width = "full",
		},
	}

	MIB.savedVariables = ZO_SavedVars:NewAccountWide("MIBSV", 1, nil, defaults)
	LibAddonMenu2:RegisterAddonPanel("MIBS", panelData)
	LibAddonMenu2:RegisterOptionControls("MIBS", optionsData)
end