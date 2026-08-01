HowToKyne = HowToKyne or {}
local HowToKyne = HowToKyne

local LAM2 = LibAddonMenu2

function HowToKyne.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "HowToKyne",
		displayName = "HowTo|c989898Kyne|r",
		author = "Floliroy",
		version = HowToKyne.version,
		slashCommand = "/HowToKyne",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("HowToKyne_Settings", panelData)
	local Unlock = {
		Fog = false,
	}

	local sV = HowToKyne.savedVariables
	local optionsData = {
		{	type = "header",
			name = "General",
		},
		{	type = "description",
			text = "Notifications with |cff0000(CCA)|r are using Code Combat's Alerts, click the next button to show some notifications for 10 secondes and move them.",
		},
		{ 	type     = "button",
			name     = "Show CCA notifications",
			tooltip  = "Show the notifications used by HowToKyne to be able to move them",
			func     = function()
				CombatAlerts.Alert("Ability Name (test)", "Test announcment", 0xFF0000FF, 10000, 10000)
				CombatAlerts.CastAlertsStart(0, "Test Cast Bar", 10000, 10000, {1, 0.7, 0, 0.5}, {10000, "(Test)", 0.8, 0, 0, 0.9, nil})
			end,
			width    = "half"
		},
		{	type = "description",
			text = " ",
		},
		{	type = "header",
			name = "Yandir Notifications",
		},
		{	type = "checkbox",
			name = "Enable Chorus Totem |cff0000(CCA)|r",
			tooltip = "To enable or not the tracking of the dodge when getting poison from the chorus totem.",
			default = true,
			getFunc = function() return sV.Enable.Chorus end,
			setFunc = function(newValue)  
				sV.Enable.Chorus = newValue
			end,
		},
		{	type = "checkbox",
			name = "Enable Gargoyle Totem |cff0000(CCA)|r",
			tooltip = "To enable or not the tracking of the block when needed cause of the gargoyle totem.",
			default = true,
			getFunc = function() return sV.Enable.Gargoyle end,
			setFunc = function(newValue)  
				sV.Enable.Gargoyle = newValue
			end,
		},
		{	type = "description",
			text = " ",
		},
		{	type = "header",
			name = "Vrol Notifications",
		},
		{	type = "checkbox",
			name = "Unlock Frigid Fog",
			tooltip = "Use it to set the position of the Frigid Fog timer text.",
			default = false,
			getFunc = function() return Unlock.Fog end,
			setFunc = function(newValue)
				Unlock.Fog = newValue
				Htk_Fog:SetHidden(not newValue)  
			end,
		},
		{	type = "checkbox",
			name = "Enable Frigid Fog Tracking",
			tooltip = "To enable or not the tracking of the Frigid Fog from Vrol. Only track the first Frigid Fog !",
			default = true,
			getFunc = function() return sV.Enable.Fog end,
			setFunc = function(newValue)  
				sV.Enable.Fog = newValue
			end,
		},
		{	type = "description",
			text = " ",
		},
		{	type = "header",
			name = "Falgravn Notifications",
		},
		{	type = "checkbox",
			name = "Enable Prisoner Dodge |cff0000(CCA)|r",
			tooltip = "To enable or not the tracking of when to dodge when the prisoners are coming to the group.",
			default = true,
			getFunc = function() return sV.Enable.Prisoner end,
			setFunc = function(newValue)  
				sV.Enable.Prisoner = newValue
			end,
		},
		{	type = "checkbox",
			name = "Enable Mini Kite |cff0000(CCA)|r",
			tooltip = "To enable or not the tracking of when to start kiting due to the mini.",
			default = true,
			getFunc = function() return sV.Enable.Kite end,
			setFunc = function(newValue)  
				sV.Enable.Kite = newValue
			end,
		},
		{	type = "checkbox",
			name = "Enable Dodge for Torturer LA |cff0000(CCA)|r",
			tooltip = "To enable or not the notification to dodge if you get targeted by a torturer LA.",
			default = true,
			getFunc = function() return sV.Enable.TorturerLA end,
			setFunc = function(newValue)
				sV.Enable.TorturerLA = newValue
			end,
		},
		{	type = "checkbox",
			name = "Enable Mini Cleave |cff0000(CCA)|r",
			tooltip = "To enable or not the tracking of when to dodge if you are in the cleave of the mini.",
			default = true,
			getFunc = function() return sV.Enable.BloodCleave end,
			setFunc = function(newValue)  
				sV.Enable.BloodCleave = newValue
			end,
		},
		{	type = "checkbox",
			name = "Enable Mini Block Cast |cff0000(CCA)|r",
			tooltip = "To enable or not the tracking of when to block cast the mini if there is another mechanic.",
			default = true,
			getFunc = function() return sV.Enable.BlockCast end,
			setFunc = function(newValue)  
				sV.Enable.BlockCast = newValue
			end,
		},
	}

	LAM2:RegisterOptionControls("HowToKyne_Settings", optionsData)
end