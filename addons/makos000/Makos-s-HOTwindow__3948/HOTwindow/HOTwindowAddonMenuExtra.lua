HOTwindow = HOTwindow or {}
local HOTwindow = HOTwindow

function HOTwindow.AddonMenuExtra()
	local menuOptions = {
		type				 = "panel",
		name				 = "Makos's HOTwindow Extra",
		displayName	 = "|cFF00F7Makos's HOTwindow Extra|r",
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
		
---------------------------------------------------
---------------------------------------------------
----------- Debuff Window Settings
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "header",
			name = "|cFF0000NEW EXPERIMENTAL|r |cFFFACDPvP debuff Window|r",
		},
		
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Hide Window",
			tooltip = "Enable if you want to hide PVP HOTwindow",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.windowTogglePVPdebuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.windowTogglePVPdebuff = value
				HOTwindow.UpdateWindowPVPdebuff()
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Show in PvP only",
			tooltip = "Enable if you want to show PvP debuff HOTwindow in PvP areas only",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.toggleInPVPdebuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.toggleInPVPdebuff = value
				HOTwindow.UpdateWindowPVPdebuff()
			end,
		},
		
		{
			type    = "checkbox",
			name    = "Lock Window",
			tooltip = "Enable if you want to lock PVP debuff HOTwindow",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.lockedPVPdebuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.lockedPVPdebuff = value
				HOTwindow.UpdateWindowPVPdebuff()
			end,
		},
		
		{
			type = "divider",
		},
		
---------------------------------------------------
---------------------------------------------------
----------- Debuff Window Custom IDs
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "header",
			name = "|cFF0000CUSTOM debuff IDs PvP|r",
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
			name    = "Custom 1 PvP debuff",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT1debuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT1debuff = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 1 ID PvP debuff",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom1IDdebuff or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom1IDdebuff = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 1 Texture PvP debuff",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom1icondebuff end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom1icondebuff = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 2 PvP debuff",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT2debuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT2debuff = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 2 ID PvP debuff",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom2IDdebuff or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom2IDdebuff = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 2 Texture PvP debuff",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom2icondebuff end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom2icondebuff = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 3 PvP debuff",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT3debuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT3debuff = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 3 ID PvP debuff",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom3IDdebuff or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom3IDdebuff = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 3 Texture PvP debuff",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom3icondebuff end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom3icondebuff = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 4 PvP debuff",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT4debuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT4debuff = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 4 ID PvP debuff",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom4IDdebuff or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom4IDdebuff = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 4 Texture PvP debuff",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom4icondebuff end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom4icondebuff = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type    = "checkbox",
			name    = "Custom 5 PvP debuff",
			tooltip = "Enable if you want to track your custom ID",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.customT5debuff end,
			setFunc = function(value)
				HOTwindow.savedVariables.customT5debuff = value
			end,
			width = "half",
		},
		
		{
			type = "editbox",
                name = "Custom 5 ID PvP debuff",
                tooltip = "Enter here the your custom ID",
                getFunc = function() return HOTwindow.savedVariables.custom5IDdebuff or "" end,
                setFunc = function(text)
					HOTwindow.savedVariables.custom5IDdebuff = text
				end,
                isMultiline = false,	--boolean
				width = "half",
		},
		
		{
                type       = "iconpicker",
                name       = "Custom 5 Texture PvP debuff",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.custom5icondebuff end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.custom5icondebuff = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type = "divider",
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(HOTwindow.name .. "Options3", menuOptions )
	LAM:RegisterOptionControls(HOTwindow.name .. "Options3", dataTable )
end