function ICT.initializeSettingsMenu()

	local defaults = {
		timetable = true,
		timetableTop = 0,
		timetableLeft = 0,
		maptimers = true,
		chatdebug = false,
	}

	local panelData = {
		type = "panel",
		name = "IC The Next Boss",
		displayName = "|c1E90FFIC|r The Next Boss",
		author = "Potato787",
		version = ICT.version,
	}
	
	local optionsData = {
		{
			type = "description",
			text = GetString(SI_ICTHENEXTBOSS_OPTION_DESCRIPTION)
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_TIMETABLE),
			getFunc = function() return ICT.savedVariables.timetable end,
			setFunc = function(value)
						ICT.savedVariables.timetable = value
						if value == true then
							HUD_SCENE:AddFragment(ICT.ui.timetable)
							HUD_UI_SCENE:AddFragment(ICT.ui.timetable)
							ICTTimeTable:SetHidden(false)
						else
							ICTTimeTable:SetHidden(true)
							HUD_SCENE:RemoveFragment(ICT.ui.timetable)
							HUD_UI_SCENE:RemoveFragment(ICT.ui.timetable)
						end
					  end,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_MAPTIMERS),
			tooltip = GetString(SI_ICTHENEXTBOSS_OPTION_MAPTIMERS_TOOLTIP),
			getFunc = function() return ICT.savedVariables.maptimers end,
			setFunc = function(value) ICT.savedVariables.maptimers = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Debug",
			getFunc = function() return ICT.savedVariables.chatdebug end,
			setFunc = function(value) ICT.savedVariables.chatdebug = value end,
			width = "full",
		},
	}

	ICT.savedVariables = ZO_SavedVars:NewAccountWide("ICTSV", 1, nil, defaults)
	LibAddonMenu2:RegisterAddonPanel("ICTS", panelData)
	LibAddonMenu2:RegisterOptionControls("ICTS", optionsData)
end