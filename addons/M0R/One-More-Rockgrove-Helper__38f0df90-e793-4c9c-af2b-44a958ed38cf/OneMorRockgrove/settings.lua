local omr = OneMorRockgrove

function omr.settings.createSettings()
	local vars = omr.vars

	local panelName = "OneMorRockgroveSettingsPanel"
	local panelData = {
		type = "panel",
		name = "|cEFEBBEOne M0R Rockgrove Helper|r",
		author = "|c0DC1CF@M0R_Gaming|r",
		slashCommand = "/omr"
	}

	local bahseicorners = {
		"Banner",
		"Portal",
		"Boring Corner",
		"Entrance"
	}

	local optionsTable = {
		{
			type = "header",
			name = "|cFFD700Oaxiltso|r",
		},
		{
			type = "checkbox",
			name = "Enable Oax Safe Zone Indicator",
			tooltip = "If this is enabled, being outside of a safe zone for oax poisons will tint the edge of your screen red.",
			getFunc = function() return vars.enableRedIndicator end,
			setFunc = function(value) vars.enableRedIndicator = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Swap Oax Safe Zone Indicator",
			tooltip = "If this is enabled, being inside of a safe zone will turn your screen red instead of the other way around.",
			getFunc = function() return vars.reverseRed end,
			setFunc = function(value) vars.reverseRed = value end,
			width = "half",
		},
		{
			type = "description",
			text = "The following settings will show the Oax safe zones, which are areas where people standing within them will not "..
				"get poison. Only the people outside of the safe zones will get poison on them without considering any distances like previously "..
				"believed. If there are not enough people outside of a safe zone, then a random person in the safe zone will get it."
		},
		{
			type = "checkbox",
			name = "Show Oax Safe Zone Borders",
			tooltip = "If this is enabled, the safe zone boundaries for oax will show up little markers on the ground",
			getFunc = function() return vars.showSafeBorders end,
			setFunc = function(value) vars.showSafeBorders = value end,
		},

		{
			type = "checkbox",
			name = "Draw Safe Zones with Lines",
			tooltip = "If this is enabled, the safe zone boundaries for oax will show up lines on the ground, in a pre-rendered image." ..
				"\n\n|cFF0000This feature will use up about 1mb of ram.|r\nThe 'draw with breadcrumbs' feature will take priority over this.",
			getFunc = function() return vars.customOaxLines end,
			setFunc = function(value) vars.customOaxLines = value end,
		},
		{
			type = "checkbox",
			name = "Draw Safe Zones with Breadcrumbs",
			tooltip = "If this is enabled, the safe zone boundaries for oax will show up lines on the ground."..
				"\n\nThis feature requires Breadcrumbs to be installed. Enabling this will take priority over 'draw with lines'.",
			getFunc = function() return vars.breadcrumbsOaxLines end,
			setFunc = function(value) vars.breadcrumbsOaxLines = value end,
			disabled = function() if Breadcrumbs then return false else return true end end,
		},
		{
			type = "description",
			text = "The following buttons can be used to temporarily show or hide oax borders outside of combat. In a future update "..
				"this will be a toggle but for now it is just a button."
		},
		{
			type = "button",
			name = "Display Oax Borders",
			width = "half",
			func = function() omr.EnableSafeZones() end,
		},
		{
			type = "button",
			name = "Hide Oax Borders",
			width = "half",
			func = function() omr.destroySafeBorders() end,
		},
		{
			type = "header",
			name = "|cFFD700Bahsei|r",
		},
		{
			type = "checkbox",
			name = "Enable Bahsei Good Cone Prediction",
			tooltip = "Plays a notification based on if bahsei's cone is probably a good cone or not.",
			getFunc = function() return vars.goodConePrediction end,
			setFunc = function(value) vars.goodConePrediction = value end,
		},

		{
			type = "description",
			text = "The following settings are relavent for the first cone that Bahsei spawns during hardmode. This should be configured "..
			"depending on how your group is holding bahsei, and as such it is disabled by default."
		},

		{
			type = "checkbox",
			name = "Enable Bahsei Initial Cone Positioning",
			tooltip = "Plays a notification when the first cone goes out for bahsei indicating where to go.",
			getFunc = function() return vars.initialConeIndicator end,
			setFunc = function(value) vars.initialConeIndicator = value end,
		},
		{
			type = "dropdown",
			name = "Initial CW Position",
			tooltip = "Which corner should pop up if Bahsei does a clockwise cone to start.",
			choices = bahseicorners,
			getFunc = function() return vars.bahseiInitialCW end,
			setFunc = function(value) vars.bahseiInitialCW = value end,
			width = "half",
		},
		{
			type = "dropdown",
			name = "Initial CCW Position",
			tooltip = "Which corner should pop up if Bahsei does a counter-clockwise cone to start.",
			choices = bahseicorners,
			getFunc = function() return vars.bahseiInitialCCW end,
			setFunc = function(value) vars.bahseiInitialCCW = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Bahsei Initial Cone Arrows",
			tooltip = "Creates arrows on the ground directing you towards the quadrant you need to be in for first cone.",
			getFunc = function() return vars.bahseiInitialGroundArrows end,
			setFunc = function(value) vars.bahseiInitialGroundArrows = value end,
		},
		{
			type = "checkbox",
			name = "Draw Bahsei Initial Cone Line",
			tooltip = "If this is enabled, a line will be drawn to the initial bahsei cone location. [Bahsei Initial Cone Arrows] must also be enabled.",
			getFunc = function() return vars.breadcrumbsBahseiInitialLine end,
			setFunc = function(value) vars.breadcrumbsBahseiInitialLine = value end,
			disabled = function() if Breadcrumbs then return false else return true end end,
			warning = "This feature requires Breadcrumbs to be installed."
		},
		{
			type = "description",
			text = "The following settings are relavent for people inside of portal."
		},
		{
			type = "checkbox",
			name = "Display Group location when Beaming",
			tooltip = "If this is enabled, a marker will be placed at the group's average position upstairs when you beam for portal.",
			getFunc = function() return vars.bahseiPortalIcon end,
			setFunc = function(value) vars.bahseiPortalIcon = value end,
		},
		{
			type = "checkbox",
			name = "Draw Bahsei Group Location Line",
			tooltip = "If this is enabled, a line will be drawn to where the group is standing while beaming. [Display Group location when Beaming] must also be enabled.",
			getFunc = function() return vars.breadcrumbsBahseiPortalLine end,
			setFunc = function(value) vars.breadcrumbsBahseiPortalLine = value end,
			disabled = function() if Breadcrumbs then return false else return true end end,
			warning = "This feature requires Breadcrumbs to be installed."
		},
		{
			type = "header",
			name = "|cFFD700Experimental|r",
		},
		{
			type = "description",
			text = "The following settings are Experimental and may or may not work/cause UI errors."
		},
		{
			type = "checkbox",
			name = "Draw Bahsei Portal Segments",
			tooltip = "If this is enabled, when inside of Bahsei's Portal, the arena will be split into 3 labelled segment via lines on the ground.",
			getFunc = function() return vars.bahseiPortalSegments end,
			setFunc = function(value) vars.bahseiPortalSegments = value end,
			disabled = function() if Breadcrumbs then return false else return true end end,
			warning = "This feature requires Breadcrumbs to be installed."
		},
	}


	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end