function ICT.initializeSettingsMenu()

	local defaults = {
		timetable = true,
		timetableTop = 0,
		timetableLeft = 0,
		eventtimers = false,
		maptimers = true,
		chatdebug = false,
		reduced = false,
		locked = false,
		-- Default width honours the per-locale GUI_WIDTH hint (e.g. wider for RU)
		-- but never narrower than 230, so longer non-English names aren't cramped
		-- on first load, then scaled 1.5x for a roomier default box (345 en/fr,
		-- 405 ru). Overridden as soon as the user drag-resizes the box.
		boxWidth = math.floor(math.max(tonumber(GetString(SI_ICTHENEXTBOSS_GUI_WIDTH)) or 230, 230) * 1.5),
		rowHeight = 26,
		opacity = 60,
		hideInCombat = false,
		hideMoving = false,
		saved_timers = {}
	}

	local panelData = {
		type = "panel",
		name = "IC The Next Boss",
		displayName = "|c1E90FFIC|r The Next Boss",
		author = "ownedbynico, akamatsu02, einar21121",
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
						else
							HUD_SCENE:RemoveFragment(ICT.ui.timetable)
							HUD_UI_SCENE:RemoveFragment(ICT.ui.timetable)
						end
						ICT.refreshVisibility()
					  end,
			width = "full"
		},
		{
			type = "slider",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_OPACITY),
			tooltip = GetString(SI_ICTHENEXTBOSS_OPTION_OPACITY_TOOLTIP),
			min = 10, max = 100, step = 5,
			getFunc = function() return ICT.savedVariables.opacity end,
			setFunc = function(value)
				ICT.savedVariables.opacity = value
				ICT.refreshAlpha()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_HIDE_COMBAT),
			getFunc = function() return ICT.savedVariables.hideInCombat end,
			setFunc = function(value)
				ICT.savedVariables.hideInCombat = value
				ICT.refreshVisibility()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_HIDE_MOVING),
			getFunc = function() return ICT.savedVariables.hideMoving end,
			setFunc = function(value)
				ICT.savedVariables.hideMoving = value
				ICT.refreshVisibility()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_REDUCED),
			tooltip = GetString(SI_ICTHENEXTBOSS_OPTION_REDUCED_TOOLTIP),
			getFunc = function() return ICT.savedVariables.reduced end,
			setFunc = function(value)
				ICT.savedVariables.reduced = value
				ICT.applyDisplayMode()
			end,
			width = "full",
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
			name = GetString(SI_ICTHENEXTBOSS_OPTION_EVENT_TIMERS),
			getFunc = function() return ICT.savedVariables.eventtimers end,
			setFunc = function(value) 
				ICT.savedVariables.eventtimers = value
				ICT.editSpawnTime()
			end,
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SI_ICTHENEXTBOSS_OPTION_DEBUG),
			getFunc = function() return ICT.savedVariables.chatdebug end,
			setFunc = function(value) ICT.savedVariables.chatdebug = value end,
			width = "full",
		},
	}

	ICT.savedVariables = ZO_SavedVars:NewAccountWide("ICTSV", 1, nil, defaults)
	ICT.settingsPanel = LibAddonMenu2:RegisterAddonPanel("ICTS", panelData)
	LibAddonMenu2:RegisterOptionControls("ICTS", optionsData)
end