HOTwindow = HOTwindow or {}
local HOTwindow = HOTwindow

function HOTwindow.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Makos's HOTwindow",
		displayName	 = "|cFF00F7Makos's HOTwindow|r",
		author			 = HOTwindow.author,
		version			 = HOTwindow.version,
		slashCommand = "/msc",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
	
---------------------------------------------------
---------------------------------------------------
----------- Main window settings
---------------------------------------------------
---------------------------------------------------
		{
			type = "header",
			name = "|cFFFACDSettings|r",
		},
		
		{
			type    = "checkbox",
			name    = "Hide Window",
			tooltip = "Enable if you want to hide HOTwindow",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.windowToggle end,
			setFunc = function(value)
				HOTwindow.savedVariables.windowToggle = value
				HOTwindow.UpdateWindow()
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Lock Window",
			tooltip = "Enable if you want to lock HOTwindow",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.locked end,
			setFunc = function(value)
				HOTwindow.savedVariables.locked = value
				HOTwindow.UpdateWindow()
			end,
		},
		
---------------------------------------------------
---------------------------------------------------
----------- Main Window Customization
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "divider",
		},
		
		{
			type = "description",
			text = "You need to reload UI in order to see changes for the setting below",
		},
		
		{
			type = "divider",
		},
		
		
		{
			type    = "checkbox",
			name    = "Vigor",
			tooltip = "Enable if you want to track Echoing Vigor",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.vigorT end,
			setFunc = function(value)
				HOTwindow.savedVariables.vigorT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Regen",
			tooltip = "Enable if you want to track Radiating Regeneration",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.regenT end,
			setFunc = function(value)
				HOTwindow.savedVariables.regenT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Burst",
			tooltip = "Enable if you want to track Warding Burst",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.burstT end,
			setFunc = function(value)
				HOTwindow.savedVariables.burstT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Contingency",
			tooltip = "Enable if you want to track Warding Contingency",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.wardT end,
			setFunc = function(value)
				HOTwindow.savedVariables.wardT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Prayer",
			tooltip = "Enable if you want to track Combat Prayer",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.prayerT end,
			setFunc = function(value)
				HOTwindow.savedVariables.prayerT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "PA",
			tooltip = "Enable if you want to track Powerful Assault",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.paT end,
			setFunc = function(value)
				HOTwindow.savedVariables.paT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "MC",
			tooltip = "Enable if you want to track Major Courage",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.mcT end,
			setFunc = function(value)
				HOTwindow.savedVariables.mcT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "MR",
			tooltip = "Enable if you want to track Major Resolve",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.mrT end,
			setFunc = function(value)
				HOTwindow.savedVariables.mrT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Pillager (not working)",
			tooltip = "Enable if you want to track Pillagers Profit",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.pilT end,
			setFunc = function(value)
				HOTwindow.savedVariables.pilT = value
			end,
		},
		{
			type = "divider",
		},
		
---------------------------------------------------
---------------------------------------------------
----------- Main Window Custom IDs
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "header",
			name = "|cFFFACDCUSTOM IDs|r",
		},
		{
			type = "divider",
		},
		
		{
			type = "description",
			text = "You need to reload UI in order to see changes for the setting below",
		},
		
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Custom 1",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT1 end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT1 = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 1 ID",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom1ID or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom1ID = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 1 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom1icon end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom1icon = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 2",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT2 end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT2 = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 2 ID",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom2ID or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom2ID = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 2 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom2icon end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom2icon = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 3",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT3 end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT3 = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 3 ID",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom3ID or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom3ID = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 3 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom3icon end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom3icon = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 4",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT4 end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT4 = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 4 ID",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom4ID or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom4ID = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 4 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom4icon end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom4icon = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 5",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT5 end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT5 = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 5 ID",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom5ID or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom5ID = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 5 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom5icon end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom5icon = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type = "divider",
		},
		
---------------------------------------------------
---------------------------------------------------
----------- PvP Window Settings
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "header",
			name = "|cFF00F7NEW|r |cFFA500PvP Window|r",
		},
		
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Hide Window",
			tooltip = "Enable if you want to hide PVP HOTwindow",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.windowTogglePVP end,
			setFunc = function(value)
				HOTwindow.savedVariables.windowTogglePVP = value
				HOTwindow.UpdateWindowPVP()
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Show in PvP only",
			tooltip = "Enable if you want to show PvP HOTwindow in PvP areas only",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.toggleInPVP end,
			setFunc = function(value)
				HOTwindow.savedVariables.toggleInPVP = value
				HOTwindow.UpdateWindowPVP()
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Lock Window",
			tooltip = "Enable if you want to lock PVP HOTwindow",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.lockedPVP end,
			setFunc = function(value)
				HOTwindow.savedVariables.lockedPVP = value
				HOTwindow.UpdateWindowPVP()
			end,
		},
		
		
---------------------------------------------------
---------------------------------------------------
----------- PvP Window Customization
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "divider",
		},
		
		{
			type = "description",
			text = "You need to reload UI in order to see changes for the setting below",
		},
		
		{
			type = "divider",
		},
		
		
		{
			type    = "checkbox",
			name    = "Vigor",
			tooltip = "Enable if you want to track Echoing Vigor",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.vigorTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.vigorT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Regen",
			tooltip = "Enable if you want to track Radiating Regeneration",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.regenTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.regenT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Burst",
			tooltip = "Enable if you want to track Warding Burst",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.burstTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.burstT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Contingency",
			tooltip = "Enable if you want to track Warding Contingency",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.wardTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.wardT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "PA",
			tooltip = "Enable if you want to track Powerful Assault",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.paTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.paT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Major Courage",
			tooltip = "Enable if you want to track Major Courage",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.mcTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.mcT = value
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Major Resolve",
			tooltip = "Enable if you want to track Major Resolve",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.mrTpvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.mrT = value
			end,
		},
		
		{
			type = "divider",
		},
		
---------------------------------------------------
---------------------------------------------------
----------- PvP Window Custom IDs
---------------------------------------------------
---------------------------------------------------

		{
			type = "header",
			name = "|cFFA500CUSTOM IDs PvP|r",
		},
		{
			type = "divider",
		},
		
		{
			type = "description",
			text = "You need to reload UI in order to see changes for the setting below",
		},
		
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Custom 1 PvP",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT1pvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT1pvp = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 1 ID PvP",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom1IDpvp or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom1IDpvp = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 1 Texture PvP",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom1iconpvp end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom1iconpvp = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 2 PvP",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT2pvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT2pvp = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 2 ID PvP",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom2IDpvp or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom2IDpvp = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 2 Texture PvP",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom2iconpvp end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom2iconpvp = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 3 PvP",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT3pvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT3pvp = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 3 ID PvP",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom3IDpvp or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom3IDpvp = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 3 Texture PvP",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom3iconpvp end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom3iconpvp = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 4 PvP",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT4pvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT4pvp = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 4 ID PvP",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom4IDpvp or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom4IDpvp = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 4 Texture PvP",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom4iconpvp end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom4iconpvp = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 5 PvP",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT5pvp end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT5pvp = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 5 ID PvP",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom5IDpvp or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom5IDpvp = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 5 Texture PvP",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom5iconpvp end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom5iconpvp = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type = "divider",
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(HOTwindow.name .. "Options2", menuOptions )
	LAM:RegisterOptionControls(HOTwindow.name .. "Options2", dataTable )
end