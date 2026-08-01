function ROTracker.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "RO Tracker",
		displayName = "|cFFD700RO Tracker|r",
		author = "Kalinfe",
		version = "1.0.0",
		registerForRefresh = true
	}
	
	-- List taken from Combat Metronome as a list of sounds that hopefully aren't too annoying
	local sounds = {
		"Justice_PickpocketFailed",
		"Dialog_Decline",
		"Ability_Ultimate_Ready_Sound", 
		"Quest_Shared", 
		"Champion_PointsCommitted", 
		"GroupElection_Requested", 
		"Duel_Boundary_Warning",
	}
	
	LAM:RegisterAddonPanel("ROTrackerOptions", panelData)

	local options = {
		{
			type = "header",
			name = "Options"
		},
		{
			type = "checkbox",
			name = "Given Slayer Only",
			tooltip = "Only displays procs caused by yourself if turned on",
			getFunc = function() return ROTracker.vars.givenSlayer end,
			setFunc = function(value) ROTracker.vars.givenSlayer = value end,
		},
		{
            type = "checkbox",
            name = "Single Column",
            tooltip = "Converts the two column layout into a single column layout - REQUIRES RELOAD",
			warning = "REQUIRES UI RELOAD",
            getFunc = function() return ROTracker.vars.maxRows == 12 end,
            setFunc = function(state)
				if(state) then
					ROTracker.vars.maxRows = 12
				else
					ROTracker.vars.maxRows = 6
				end
            end,
        },
		{
			type = "colorpicker",
			name = "Slayer Color",
			tooltip = "Color of the player when they have Major Slayer",
			warning = "Color changes go into effect next time Major Slayer is lost or gained",
			getFunc = function() return unpack(ROTracker.vars.colors.slayer) end,
			setFunc = function(r,g,b,a) ROTracker.vars.colors.slayer = {r,g,b,a} end,
		},
		{
			type = "colorpicker",
			name = "Cooldown Color",
			tooltip = "Color of the player when they are on Major Slayer Cooldown (But do not currently have slayer)",
			warning = "Color changes go into effect next time Major Slayer is lost or gained",
			getFunc = function() return unpack(ROTracker.vars.colors.cooldown) end,
			setFunc = function(r,g,b,a) ROTracker.vars.colors.cooldown = {r,g,b,a} end,
		},
		{
                    type = "slider",
                    name = "RO Timer Text Size",
                    tooltip = "Size of the timers above the player list",
                    min = 0,
                    max = 100,
                    step = 1,
                    getFunc = function() return ROTracker.vars.cooldownTextSize end,
                    setFunc = function(value)
                        ROTracker.vars.cooldownTextSize = value
                        ROTracker.UpdateFont(value)
                    end
        },
		{
            type = "checkbox",
            name = "Play Sound Notification",
            tooltip = "Plays a sound a second before you need to proc RO",
            getFunc = function() return ROTracker.vars.playSound end,
            setFunc = function(state)
                ROTracker.vars.playSound = state
            end,
        },
		{
            type = "dropdown",
            name = "Proc RO Notification Sound",
            choices = {
				"Justice_PickpocketFailed",
				"Dialog_Decline",
				"Ability_Ultimate_Ready_Sound", 
				"Quest_Shared", 
				"Champion_PointsCommitted", 
				"GroupElection_Requested", 
				"Duel_Boundary_Warning",
			},
            getFunc = function() return ROTracker.vars.sound end,
            setFunc = function(value)
                ROTracker.vars.sound = value
                PlaySound(value)
            end,
        },
		{
            type = "slider",
            name = "RO Notification Delay",
            tooltip = "Increase/decrease the time at which you recieve a notification sound to proc heavy attack. 0 = as soon as you need to, 1 = 1 second before you can HA",
            min = 0,
            max = 20,
            step = 1,
            getFunc = function() return ROTracker.vars.soundDelay end,
            setFunc = function(value) 
                ROTracker.vars.soundDelay = value 
            end
        },
	}

	LAM:RegisterOptionControls("ROTrackerOptions", options)
end
