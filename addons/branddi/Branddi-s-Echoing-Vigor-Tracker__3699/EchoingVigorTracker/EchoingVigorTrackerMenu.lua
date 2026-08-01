
--[[
function EVT_LoadSettings()
    local panelData = {
        type = "panel",
        name = "Echoing Vigor Tracker",
        displayName = "Echoing Vigor Tracker",
        author = "branddi",
        version = "1.0.2",
        --website = "",
		--feedback = "",
		--donation = "",
        --slashCommand = "/ev",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel("Echoing Vigor Tracker", panelData)

    local optionsTable = {}

      table.insert(optionsTable, {
        type = "button",
        name = "Show/Hide UI",
        func = function() EVT_showUI() end,
        width = "half"

    })
	  table.insert(optionsTable, {

                type = "checkbox",
                name = "Turn off Echoing Vigor Tracker",
                getFunc = function() return EchoingVigorTracker.savedVars.onlyTrackWhenWearing end,
                setFunc = function(value) EchoingVigorTracker.savedVars.onlyTrackWhenWearing = value
				EVT_updateShowHide()
				end,
                width = "full",	--or "half" (optional)

            })


   	  table.insert(optionsTable, {

                type = "checkbox",
                name = "Turn off in trials",
                getFunc = function() return EchoingVigorTracker.savedVars.disableInTrials end,
                setFunc = function(value) EchoingVigorTracker.savedVars.disableInTrials = value
				EVT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })


	table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only in combat",
                getFunc = function() return EchoingVigorTracker.savedVars.showOnlyInCombat end,
                setFunc = function(value) EchoingVigorTracker.savedVars.showOnlyInCombat = value
				EVT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })
    table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only on Damage Dealers",
                getFunc = function() return EchoingVigorTracker.savedVars.trackOnlyDD end,
                setFunc = function(value) EchoingVigorTracker.savedVars.trackOnlyDD = value
				end,
                width = "full",	--or "half" (optional)

            })


    LibAddonMenu2:RegisterOptionControls("Echoing Vigor Tracker", optionsTable)
end


--]]


EchoingVigorTracker = EchoingVigorTracker or { }
local EchoingVigorTracker = EchoingVigorTracker




function EchoingVigorTracker.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Branddi's Echoing Vigor Tracker",
		displayName = "|cff2424B|r|cff4949r|r|cff6d6da|r|cff9292n|r|cffb6b6d|r|cffdbdbd|r|cffffffi|r's Echoing Vigor Tracker",
		author = "Branddi",
		website = "https://www.esoui.com/downloads/info3699-EchoingVigorTracker.html",
		feedback = "https://www.esoui.com/downloads/info3699-EchoingVigorTracker.html",
		version = ""..EchoingVigorTracker.version,
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel(EchoingVigorTracker.name.."Options", panelData)

	local options = {}


	table.insert (options,{
		type = "header",
		name = "Settings"
	})
	table.insert (options,{
		type = "checkbox",
		name = "Account Wide",
		tooltip = "Use account wide settings",
		getFunc = function() return EchoingVigorTracker.savedVars.global end,
		setFunc = function(value)
			if EchoingVigorTracker.savedVars.global== value then return end

			if value then
				EchoingVigorTracker.savedVars.global = true
				EchoingVigorTracker.savedVars = ZO_SavedVars:NewAccountWide(EchoingVigorTracker.name.."SavedVars",  EchoingVigorTracker.varVersion, nil, EchoingVigorTracker.defaults)
				EchoingVigorTracker.savedVars.global = true
			else
				EchoingVigorTracker.savedVars = ZO_SavedVars:NewCharacterIdSettings(EchoingVigorTracker.name.."SavedVars",  EchoingVigorTracker.varVersion, nil, EchoingVigorTracker.defaults)
				EchoingVigorTracker.savedVars.global = false
			end
			EchoingVigorTracker.savedVars.global = value

			EchoingVigorTracker.adjustFrameLocation()
		end
	})


	table.insert (options,{
		type = "header",
		name = "UI Positioning"
	})



	table.insert (options,{
		type = "button",
		name = "Show/Hide UI",
		func = function() EchoingVigorTracker.showUI() end,
 		width = "full"

	})


		table.insert (options,{
			type = "checkbox",
			name = "Enabled",
			tooltip = "(DEFAULT ON) use this setting to turn off the addon",
			getFunc = function() return EchoingVigorTracker.savedVars.enabled end,
			setFunc = function(value)
				EchoingVigorTracker.savedVars.enabled = value
				EchoingVigorTracker.checkIfAddonNeedsToBeLoadedOrUnloaded()
			end
		})


	table.insert (options,{
			type = "checkbox",
			name = "In Combat Only",
			tooltip = "(DEFAULT ON) only display addon while in combat",
			getFunc = function() return EchoingVigorTracker.savedVars.showOnlyInCombat end,
			setFunc = function(value)
				EchoingVigorTracker.savedVars.showOnlyInCombat = value
				EchoingVigorTracker.updateUi()
			end
		})

		table.insert (options,{
			type = "header",
			name = "Players with active Echoing Vigor"
		})

		table.insert (options,{
			type = "colorpicker",
			name = "In range < 15 meters",
			tooltip = "",
			getFunc = function() return unpack(EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor) end,
			setFunc = function(r,g,b,a) EchoingVigorTracker.savedVars.activeEchoingVigorInRangeColor = {r,g,b,a} end,
		})

		table.insert (options,{
			type = "colorpicker",
			name = "Out of range > 15 meters",
			tooltip = "",
			getFunc = function() return unpack(EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor) end,
			setFunc = function(r,g,b,a) EchoingVigorTracker.savedVars.activeEchoingVigorOutsideRangeColor = {r,g,b,a} end,
		})

		table.insert (options,{
			type = "header",
			name = "Players without Echoing Vigor"
		})

		table.insert (options,{
			type = "colorpicker",
			name = "Eligible receive the heal",
			tooltip = "In range, and eligible to recieve EV when cast as there aren't already 6 people with EV within 15m of you.",
			getFunc = function() return unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor) end,
			setFunc = function(r,g,b,a) EchoingVigorTracker.savedVars.inactiveEchoingVigorCanReceieveColor = {r,g,b,a} end,
		})


		table.insert (options,{
			type = "colorpicker",
			name = "Ineligible to receive the heal",
			tooltip = "Due to the way EV works, if 6 people within 15m of you already have EV, if you re-cast it will go to the same 6 people again instead of this new target.",
			getFunc = function() return unpack(EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor) end,
			setFunc = function(r,g,b,a) EchoingVigorTracker.savedVars.inactiveEchoingVigorCannotReceieveColor = {r,g,b,a} end,
		})

		table.insert (options,{
			type = "header",
			name = "Background"
		})

		table.insert (options,{
			type = "colorpicker",
			name = "Normal",
			tooltip = "",
			getFunc = function() return unpack(EchoingVigorTracker.savedVars.normalBackgroundColor) end,
			setFunc = function(r,g,b,a) EchoingVigorTracker.savedVars.normalBackgroundColor = {r,g,b,a} end,
		})


		table.insert (options,{
			type = "colorpicker",
			name = "Recommend casting color",
			tooltip = "",
			getFunc = function() return unpack(EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor) end,
			setFunc = function(r,g,b,a) EchoingVigorTracker.savedVars.recommendCastingEchoingVigorBackgroundColor = {r,g,b,a} end,
		})


		table.insert (options,{
            type = "button",
            name = "Reset to Default",
            func = function() EchoingVigorTracker.resetVariables() end,
            width = "full"

        })

		table.insert (options,{
			type = "header",
			name = "Guaranteed Target Casting Recommendation"
		})

		table.insert (options,{
			type = "checkbox",
			name = "Enable recommended casting",
			tooltip = "(DEFAULT ON) recommend casting Echoing Vigor when the following criteria is met",
			getFunc = function() return EchoingVigorTracker.savedVars.recommendCastingEnabled end,
			setFunc = function(value)
				EchoingVigorTracker.savedVars.recommendCastingEnabled = value
			end
		})


		table.insert (options,{
            type = "slider",
            name = "Targets in Dungeons",
             tooltip = "(DEFAULT 1) a minimum number players that do not have Echoing Vigor to recommend casting",
            min = 1,
            max = 4,
            step = 1,
            getFunc = function() return EchoingVigorTracker.savedVars.requiredTargetsToRecommendCastingDungeons end,
            setFunc = function(value)
                EchoingVigorTracker.savedVars.requiredTargetsToRecommendCastingDungeons = value
            end,
        })


		table.insert (options,{
            type = "slider",
            name = "Targets in Trials",
             tooltip = "(DEFAULT 2) a minimum number of guaranteed new Echoing Vigor targets before recommending casting.  The way the game assigns new casts of Echoing Vigor is goofy, and will re-apply to existing targets before applying to new targets.",
            min = 1,
            max = 5,
            step = 1,
            getFunc = function() return EchoingVigorTracker.savedVars.requiredTargetsToRecommendCastingTrials end,
            setFunc = function(value)
                EchoingVigorTracker.savedVars.requiredTargetsToRecommendCastingTrials = value
            end,
        })


		table.insert (options,{
			type = "checkbox",
			name = "Consider missing HP",
			tooltip = "(DEFAULT ON) in trials Echoing Vigor can apply to someone if their HP is lower than others who already have Echoing Vigor",
			getFunc = function() return EchoingVigorTracker.savedVars.includeMissingHpWhenRecommending end,
			setFunc = function(value)
				EchoingVigorTracker.savedVars.includeMissingHpWhenRecommending = value
			end
		})

	LAM:RegisterOptionControls(EchoingVigorTracker.name.."Options", options)
end




