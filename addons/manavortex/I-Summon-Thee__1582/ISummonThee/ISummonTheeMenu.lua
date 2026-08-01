local IST = IST

function IST.CreateMenu(savedVars, defaults)
	
	local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	local panelData = {
		type = "panel",
		name = "ISummonThee",
		displayName = name,
	 	author = "manavortex",
		version = IST.version,
		registerForRefresh = true,
		slashCommand = "/summons",	}

	LAM:RegisterAddonPanel("ISummonThee_OptionsPanel", panelData)

	local optionsData = { -- optionsData		
		{ -- Activate
			type 	= "checkbox",
			name 	= "Activate?",
			getFunc = function() return IST.GetActive() end,
			setFunc = function(value) IST.SetActive(value) end,
			default = defaults.active
		},
		{ -- Delay
			type 	= "slider",
			name 	= "Delay between tries (in seconds)",
			min		= 6,
			max		= 10,
			getFunc = function() return IST.GetDelay() end,
			setFunc = function(value) IST.SetDelay(value) end,
			default = defaults.delay
		},
		{ -- max tries
			type 	= "slider",
			name 	= "Try how often?",
			min		= 1,
			max		= 5,
			getFunc = function() return IST.GetMaxTries() end,
			setFunc = function(value) IST.SetMaxTries(value) end,
			default = defaults.maxTries
		},
		{ -- max tries
			type 	= "editbox",
			name 	= "Invite people on command",
			tooltip = "Will try invite everyone who whispers this to you to your group.", 
			getFunc = function() return IST.GetTrigger() end,
			setFunc = function(value) IST.SetTrigger(value) end,
			default = defaults.trigger
		},
	}
	
	LAM:RegisterOptionControls("ISummonThee_OptionsPanel", optionsData)
end