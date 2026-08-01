HOTwindow = HOTwindow or {}
local HOTwindow = HOTwindow

function HOTwindow.AddonMenuRange()
	local menuOptions = {
		type				 = "panel",
		name				 = "Makos's HOTwindow Range",
		displayName	 = "|cFF00F7Makos's HOTwindow Range|r",
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
----------- Ability range settings
---------------------------------------------------
---------------------------------------------------
		
		{
			type = "header",
			name = "|cFF00F7NEW|r |c00FFFFDisplay Ability range for:|r",
		},
		
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Echoing Vigor",
			tooltip = "Enable if you want to see range of Echoing Vigor 15m",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.EVR end,
			setFunc = function(value)
				HOTwindow.savedVariables.EVR = value
				if value == false then
					    if HOTwindow.iconsEV then
							for _, icon in ipairs(HOTwindow.iconsEV) do
								OSI.DiscardPositionIcon(icon)
							end
						end
				end
			end,
		},
		
		{
			type    = "slider",
			min = 10,
			max = 360,
			name    = "Echoing Vigor cone angle",
			tooltip = "Enable if you want to see range of Warding Contingency only in cone angle in front of you",
			getFunc = function() return HOTwindow.savedVariables.EVRconeangle end,
			setFunc = function(value)
				HOTwindow.savedVariables.EVRconeangle = value
			end,
		},
		
		{
			type = "slider",
			name = "Echoing Vigor icon Size",
			tooltip = "Change this to adjust icon size (Default: 50)",
			min = 1,
			max = 300,
			getFunc = function() return HOTwindow.savedVariables.EVRsize end,
			setFunc = function(value) HOTwindow.savedVariables.EVRsize = value end,
		},
		
		{
			type = "slider",
			name = "Echoing Vigor count",
			tooltip = "Change this to adjust icon count (Default: 1). Can significantly impact performance at high count",
			min = 1,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.EVRcount end,
			setFunc = function(value) HOTwindow.savedVariables.EVRcount = value end,
		},
		
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Combat Prayer",
			tooltip = "Enable if you want to see range of Combat Prayer 20m",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.CPR end,
			setFunc = function(value)
				HOTwindow.savedVariables.CPR = value
				if value == false then
					if HOTwindow.iconsCP then
						for _, icon in ipairs(HOTwindow.iconsCP) do
							OSI.DiscardPositionIcon(icon)
						end
					end
				end
			end,
		},
		
		{
			type    = "slider",
			min = 10,
			max = 360,
			name    = "Combat Prayer cone angle",
			tooltip = "Enable if you want to see range of Warding Contingency only in cone angle in front of you",
			getFunc = function() return HOTwindow.savedVariables.CPRconeangle end,
			setFunc = function(value)
				HOTwindow.savedVariables.CPRconeangle = value
			end,
		},
		
		{
			type = "slider",
			name = "Combat Prayer icon Size",
			tooltip = "Change this to adjust icon size (Default: 50)",
			min = 1,
			max = 300,
			getFunc = function() return HOTwindow.savedVariables.CPRsize end,
			setFunc = function(value) HOTwindow.savedVariables.CPRsize = value end,
		},
		
		{
			type = "slider",
			name = "Combat Prayer count",
			tooltip = "Change this to adjust icon count (Default: 1). Can significantly impact performance at high count",
			min = 1,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CPRcount end,
			setFunc = function(value) HOTwindow.savedVariables.CPRcount = value end,
		},
		
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Warding Contingency",
			tooltip = "Enable if you want to see range of Warding Contingency 8m",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.WCR end,
			setFunc = function(value)
				HOTwindow.savedVariables.WCR = value
				if value == false then
					if HOTwindow.iconsWC then
						for _, icon in ipairs(HOTwindow.iconsWC) do
							OSI.DiscardPositionIcon(icon)
						end
					end
				end
			end,
		},
		
		{
			type    = "slider",
			min = 10,
			max = 360,
			name    = "Warding Contingency cone angle",
			tooltip = "Enable if you want to see range of Warding Contingency only in cone angle in front of you",
			getFunc = function() return HOTwindow.savedVariables.WCRconeangle end,
			setFunc = function(value)
				HOTwindow.savedVariables.WCRconeangle = value
			end,
		},
		
		{
			type = "slider",
			name = "Warding Contingency icon Size",
			tooltip = "Change this to adjust icon size (Default: 50)",
			min = 1,
			max = 300,
			getFunc = function() return HOTwindow.savedVariables.WCRsize end,
			setFunc = function(value) HOTwindow.savedVariables.WCRsize = value end,
		},
		
		{
			type = "slider",
			name = "Warding Contingency count",
			tooltip = "Change this to adjust icon count (Default: 1). Can significantly impact performance at high count",
			min = 1,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.WCRcount end,
			setFunc = function(value) HOTwindow.savedVariables.WCRcount = value end,
		},
		
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Custom Range 1",
			tooltip = "Enable if you want to see range of Custom Range 1",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.CM1 end,
			setFunc = function(value)
				HOTwindow.savedVariables.CM1 = value
				if value == false then
				    if HOTwindow.iconsCM1 then
						for _, icon in ipairs(HOTwindow.iconsCM1) do
							OSI.DiscardPositionIcon(icon)
						end
					end
				end
			end,
		},
		
		{
			type    = "slider",
			min = 10,
			max = 360,
			name    = "Custom Range 1 cone angle",
			tooltip = "Enable if you want to see range of Custom Range 1 only in cone angle in front of you",
			getFunc = function() return HOTwindow.savedVariables.CM1coneangle end,
			setFunc = function(value)
				HOTwindow.savedVariables.CM1coneangle = value
			end,
		},
		
		{
                type       = "iconpicker",
                name       = "Custom Range 1 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.CM1tex end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.CM1tex = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type = "slider",
			name = "Custom Range 1 icon Size",
			tooltip = "Change this to adjust icon size (Default: 50)",
			min = 1,
			max = 300,
			getFunc = function() return HOTwindow.savedVariables.CM1size end,
			setFunc = function(value) HOTwindow.savedVariables.CM1size = value end,
		},
		
		{
			type = "slider",
			name = "Custom Range 1 count",
			tooltip = "Change this to adjust icon count (Default: 1). Can significantly impact performance at high count",
			min = 1,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CM1count end,
			setFunc = function(value) HOTwindow.savedVariables.CM1count = value end,
		},
		
		{
			type = "slider",
			name = "Custom Range 1 range",
			tooltip = "Change this to adjust icon range",
			min = 0,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CM1range end,
			setFunc = function(value) HOTwindow.savedVariables.CM1range = value end,
		},
		
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Custom Range 2",
			tooltip = "Enable if you want to see range of Custom Range 2",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.CM2 end,
			setFunc = function(value)
				HOTwindow.savedVariables.CM2 = value
				if value == false then
				    if HOTwindow.iconsCM2 then
						for _, icon in ipairs(HOTwindow.iconsCM2) do
							OSI.DiscardPositionIcon(icon)
						end
					end
				end
			end,
		},
		
		{
			type    = "slider",
			min = 10,
			max = 360,
			name    = "Custom Range 2 cone angle",
			tooltip = "Enable if you want to see range of Custom Range 2 only in cone angle in front of you",
			getFunc = function() return HOTwindow.savedVariables.CM2coneangle end,
			setFunc = function(value)
				HOTwindow.savedVariables.CM2coneangle = value
			end,
		},
		
		{
                type       = "iconpicker",
                name       = "Custom Range 2 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.CM2tex end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.CM2tex = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type = "slider",
			name = "Custom Range 2 icon Size",
			tooltip = "Change this to adjust icon size (Default: 50)",
			min = 1,
			max = 300,
			getFunc = function() return HOTwindow.savedVariables.CM2size end,
			setFunc = function(value) HOTwindow.savedVariables.CM2size = value end,
		},
		
		{
			type = "slider",
			name = "Custom Range 2 count",
			tooltip = "Change this to adjust icon count (Default: 1). Can significantly impact performance at high count",
			min = 1,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CM2count end,
			setFunc = function(value) HOTwindow.savedVariables.CM2count = value end,
		},
		
		{
			type = "slider",
			name = "Custom Range 2 range",
			tooltip = "Change this to adjust icon range",
			min = 0,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CM2range end,
			setFunc = function(value) HOTwindow.savedVariables.CM2range = value end,
		},
		
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		{
			type = "divider",
		},
		
		{
			type    = "checkbox",
			name    = "Custom Range 3",
			tooltip = "Enable if you want to see range of Custom Range 3",
			default = true,
			getFunc = function() return HOTwindow.savedVariables.CM3 end,
			setFunc = function(value)
				HOTwindow.savedVariables.CM3 = value
				if value == false then
				    if HOTwindow.iconsCM3 then
						for _, icon in ipairs(HOTwindow.iconsCM3) do
							OSI.DiscardPositionIcon(icon)
						end
					end
				end
			end,
		},
		
		{
			type    = "slider",
			min = 10,
			max = 360,
			name    = "Custom Range 3 cone angle",
			tooltip = "Enable if you want to see range of Custom Range 3 only in cone angle in front of you",
			getFunc = function() return HOTwindow.savedVariables.CM3coneangle end,
			setFunc = function(value)
				HOTwindow.savedVariables.CM3coneangle = value
			end,
		},
		
		{
                type       = "iconpicker",
                name       = "Custom Range 3 Texture",
                iconSize   = 48,
                maxColumns = 10,
                getFunc    = function() return HOTwindow.savedVariables.CM3tex end,
                setFunc    = function( newValue ) HOTwindow.savedVariables.CM3tex = newValue end,
                choices    = HOTwindow.defaultIcons,
        },
		
		{
			type = "slider",
			name = "Custom Range 3 icon Size",
			tooltip = "Change this to adjust icon size (Default: 50)",
			min = 1,
			max = 300,
			getFunc = function() return HOTwindow.savedVariables.CM3size end,
			setFunc = function(value) HOTwindow.savedVariables.CM3size = value end,
		},
		
		{
			type = "slider",
			name = "Custom Range 3 count",
			tooltip = "Change this to adjust icon count (Default: 1). Can significantly impact performance at high count",
			min = 1,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CM3count end,
			setFunc = function(value) HOTwindow.savedVariables.CM3count = value end,
		},
		
		{
			type = "slider",
			name = "Custom Range 3 range",
			tooltip = "Change this to adjust icon range",
			min = 0,
			max = 50,
			getFunc = function() return HOTwindow.savedVariables.CM3range end,
			setFunc = function(value) HOTwindow.savedVariables.CM3range = value end,
		},
		
		{
			type = "divider",
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(HOTwindow.name .. "Options4", menuOptions )
	LAM:RegisterOptionControls(HOTwindow.name .. "Options4", dataTable )
end