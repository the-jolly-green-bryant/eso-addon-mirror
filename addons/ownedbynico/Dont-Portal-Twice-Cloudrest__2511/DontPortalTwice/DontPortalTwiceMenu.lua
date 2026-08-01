function DPT.initializeSettingsMenu()

	local defaults = {
		debugd = false,
		blockPortal = false,
		showCreeperRoot = true,
		waitForTank = false,
	}

	local panelData = {
		type = "panel",
		name = "Dont Portal Twice",
		displayName = "Dont |cDC143CPortal|r Twice",
		author = "ownedbynico",
		version = DPT.version,
	}
	
	local optionsData = {
		{
			type = "description",
			text = "Prevents you from entering the portal in Cloudrest while having the debuff."
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Debug",
			tooltip = "Show debug messages",
			getFunc = function() return DPT.savedVariables.debugd end,
			setFunc = function(value) DPT.savedVariables.debugd = value end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Block Portal",
			tooltip = "Always block portal synergy",
			getFunc = function() return DPT.savedVariables.blockPortal end,
			setFunc = function(value) DPT.savedVariables.blockPortal = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Creeper Alert",
			tooltip = "Colorize borders of game if you need to dodge",
			getFunc = function() return DPT.savedVariables.showCreeperRoot end,
			setFunc = function(value) DPT.savedVariables.showCreeperRoot = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Wait-for-tank Mode",
			tooltip = "Block portal if no tank is inside",
			getFunc = function() return DPT.savedVariables.waitForTank end,
			setFunc = function(value) DPT.savedVariables.waitForTank = value end,
			width = "full",
		},
	}

	DPT.savedVariables = ZO_SavedVars:NewCharacterIdSettings("DPTSV", 1, nil, defaults)
	LibAddonMenu2:RegisterAddonPanel("DPTS", panelData)
	LibAddonMenu2:RegisterOptionControls("DPTS", optionsData)
end