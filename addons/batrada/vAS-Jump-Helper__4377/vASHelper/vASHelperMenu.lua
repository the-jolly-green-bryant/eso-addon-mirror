vASHelper = vASHelper or { }
local vASHelper = vASHelper


function vASHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = vASHelper.name,
		displayName = "|cFFD700vAS Helper|r",
		author = "Branddi and Immortalized007",
		version = ""..vASHelper.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(vASHelper.name.."Options", panelData)

	local options = {
		{
			type = "header",
			name = "Positioning"
		},

        {
			type = "checkbox",
			name = "Show Olms Jump Zones",
			tooltip = "Zone where olms can jump to handy when learning to kite jumps in the middle (as opposed to entrance/exit).",
			getFunc = function() return vASHelper.savedVars.displayOlhmsJumpZone end,
			setFunc = function(value)
				if not value then
					vASHelper.savedVars.displayOlhmsJumpZone = false
					vASHelper.refreshIcons()
				else
					vASHelper.savedVars.displayOlhmsJumpZone = true
					vASHelper.refreshIcons()
				end
			end
		},

		{
			type = "checkbox",
			name = "Show Healer Zone",
			tooltip = "Zone from which you can reach entrance or exit with illustrious or budding seeds - especially useful when solo healing.",
			getFunc = function() return vASHelper.savedVars.displayHealerZone end,
			setFunc = function(value)
				if not value then
					vASHelper.savedVars.displayHealerZone = false
					vASHelper.refreshIcons()
				else
					vASHelper.savedVars.displayHealerZone = true
					vASHelper.refreshIcons()
				end
			end
		},



		{
			type = "checkbox",
			name = "Show Tank Positions",
			tooltip = "Display the location from where you tank olms, and where to back up to during kite",
			getFunc = function() return vASHelper.savedVars.displayMtLocation end,
			setFunc = function(value)
				if not value then
					vASHelper.savedVars.displayMtLocation = false
					vASHelper.refreshIcons()
				else
					vASHelper.savedVars.displayMtLocation = true
					vASHelper.refreshIcons()
				end
			end
		},
		{
			type = "checkbox",
			name = "Show selfish Purge",
			tooltip = "Display when you should purge yourself of BLEEDING or TRIAL BY FIRE, useful for TH and GH",
			getFunc = function() return vASHelper.savedVars.selfishPurge end,
			setFunc = function(value)
				if not value then
					vASHelper.savedVars.selfishPurge = false

				else
					vASHelper.savedVars.selfishPurge = true

				end
			end
		},

--""]=100,

	{
            type = "slider",
            name = "Icon Size %",
             tooltip = "(default 100) adjust the percentage size of the icons - you will have to walk into the hall and back into Olms arena to see the new icon sizes.",
            min = 30,
            max = 150,
            step = 10,
            getFunc = function() return vASHelper.savedVars.iconSize end,
            setFunc = function(value)
                vASHelper.savedVars.iconSize = value
            end,
        },

	}

	LAM:RegisterOptionControls(vASHelper.name.."Options", options)
end
