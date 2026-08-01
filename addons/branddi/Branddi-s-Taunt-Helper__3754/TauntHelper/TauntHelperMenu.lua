TauntHelper = TauntHelper or { }
local TauntHelper = TauntHelper

local fontsDefined = LibMediaProvider:List('font')

function TauntHelper.setupMenu()
	local LAM = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = "Branddi's Taunt Helper", --TauntHelper.name,
		displayName = "|cff2424B|r|cff4949r|r|cff6d6da|r|cff9292n|r|cffb6b6d|r|cffdbdbd|r|cffffffi|r's Taunt Helper",
		author = "Branddi",
		version = ""..TauntHelper.version,
		registerForRefresh = true,
		website = "https://www.esoui.com/downloads/info3754-BranddisTauntHelper.html",
        feedback = "https://www.esoui.com/downloads/info3754-BranddisTauntHelper.html#comments",

	}

	LAM:RegisterAddonPanel(TauntHelper.name.."Options", panelData)

	local options = {}


    table.insert (options,{
            type = "description",
            title = "DESCRIPTION",	--(optional)
            text = "Taunt Helper assists in micromanaging your taunt list so you can put more focus on tanking, buffing and staying alive.",
            width = "full",	--or "half" (optional)
        })


    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "- uses colors and blinking to provide an intuitive taunt status",
            width = "full",	--or "half" (optional)
        })

    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "- taunts are displayed showing when they need to be refreshed",
            width = "full",	--or "half" (optional)
        })

    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "- filtering taunt list displays only priority mobs",
            width = "full",	--or "half" (optional)
        })


    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "- removes dead mobs from your taunt list",
            width = "full",	--or "half" (optional)
        })

    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "- removes mobs based on content specific mechanics",
            width = "full",	--or "half" (optional)
        })


    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "- loose mob detection is a best effort system for locating untaunted priority mobs",
            width = "full",	--or "half" (optional)
        })

    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
                text = "- visual taunt expiration blink warnings for recent mobs for which taunt was lost",
            width = "full",	--or "half" (optional)
        })


    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
                text = "- visual over-taunted indication",
            width = "full",	--or "half" (optional)
        })

    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
                text = "- visual stolen taunt indication",
            width = "full",	--or "half" (optional)
        })


	table.insert (options,{
			type = "header",
			name = "Settings"
		})
	table.insert (options,{
			type = "checkbox",
			name = "Account Wide",
			tooltip = "Use account wide settings",
			getFunc = function() return TauntHelper.savedVars.global end,
			setFunc = function(value)
			    if TauntHelper.savedVars.global== value then return end

                if value then
                    TauntHelper.savedVars.global = true
                    TauntHelper.savedVars = ZO_SavedVars:NewAccountWide(TauntHelper.name.."SavedVars",  TauntHelper.varVersion, nil, TauntHelper.defaults)
                    TauntHelper.savedVars.global = true
                else
                    TauntHelper.savedVars = ZO_SavedVars:NewCharacterIdSettings(TauntHelper.name.."SavedVars",  TauntHelper.varVersion, nil, TauntHelper.defaults)
                    TauntHelper.savedVars.global = false
                end
                TauntHelper.savedVars.global = value
                TauntHelper.setupUI()
			end
		})

	table.insert (options,{
            type = "button",
            name = "Reset to Default",
            func = function() TauntHelper.resetVariables() end,
            width = "half"

        })


	table.insert (options,{
			type = "header",
			name = "Positioning"
		})
	table.insert (options,{
			type = "checkbox",
			name = "Lock UI",
			tooltip = "Unlock to position of taunt progress bars",
			getFunc = function() return TauntHelper.LockedUI end,
			setFunc = function(value)
				if not value then
				    --d("unlock ui")
					TauntHelper.LockedUI=false
					TauntHelperFrame:SetMovable(true)
					TauntHelperFrame:SetMouseEnabled(true)

					TauntHelperTauntStacksFrame:SetMovable(true)
					TauntHelperTauntStacksFrame:SetMouseEnabled(true)

					TauntHelper.MovingUI=true
					TauntHelper.updateUI()
				else
				    --d("lock ui")
				    TauntHelper.LockedUI=true
					TauntHelperFrame:SetMovable(false)
					TauntHelperFrame:SetMouseEnabled(false)
					TauntHelper.updateUI()
				end
			end
		})

	table.insert (options,{
			type = "header",
			name = "Taunt Tracking"
		})

	table.insert (options,{
			type = "checkbox",
			name = "Priority mobs only",
			tooltip = "Taunt Helper can cleanup your taunt list by showing you only the priority taunt targets (default ON) when OFF all mobs will appear in taunt list similar to Untaunted.",
			getFunc = function() return  not TauntHelper.savedVars.tantTrackingAllMobs end,
			setFunc = function(value)
				 TauntHelper.savedVars.tantTrackingAllMobs = not value
			end
		})


	table.insert (options,{
			type = "colorpicker",
			name = "Recent taunt color",
			tooltip = "More than 7.5 seconds remaining",
			getFunc = function() return unpack(TauntHelper.savedVars.goodTauntColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.goodTauntColor = {r,g,b,1} end,
		})

	table.insert (options,{
			type = "colorpicker",
			name = "Aging taunt",
			tooltip = "7.5 to 3 seconds remaining",
			getFunc = function() return unpack(TauntHelper.savedVars.mediumTauntColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.mediumTauntColor = {r,g,b,1} end,
		})

	table.insert (options,{
			type = "colorpicker",
			name = "Late or expired taunt color",
			tooltip = "Less than 3 seconds remaining",
			getFunc = function() return unpack(TauntHelper.savedVars.badTauntColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.badTauntColor = {r,g,b,1} end,
		})




	table.insert (options,{
            type = "slider",
            name = "Seconds mob remains after taunt expires",
            tooltip = "Mobs for which taunt was lost will remain in your taunt list for this amount of time as a reminder to try to retrieve taunt",
            min = 1,
            max = 10,
            step = 1,
            getFunc = function() return TauntHelper.savedVars.afterTauntSeconds end,
            setFunc = function(value)
                TauntHelper.savedVars.afterTauntSeconds = value
            end,
        })

    table.insert (options,{
			type = "checkbox",
			name = "Blink lost taunts",
			--tooltip = "Taunt Helper can cleanup your taunt list by showing you only the priority taunt targets (default ON) when OFF all mobs will appear in taunt list similar to Untaunted.",
			getFunc = function() return TauntHelper.savedVars.blinkLostTaunt end,
			setFunc = function(value)
				 TauntHelper.savedVars.blinkLostTaunt = value
			end
		})


	table.insert (options,{
			type = "checkbox",
			name = "Display mob difficulty",
			tooltip = "(default OFF) Start the mob name with 0 to 4 depending on the difficulty of the mob.  Since the game doesn't know the difficulty until you target the mob after it has been taunted some mobs will appear with no number until this happens.",
			getFunc = function() return TauntHelper.savedVars.displayMobDifficulty end,
			setFunc = function(value)
				TauntHelper.savedVars.displayMobDifficulty = value
			end
		})

    table.insert (options,{
			type = "header",
			name = "Stolen Taunts"
		})
	table.insert (options,{
			type = "checkbox",
			name = "Show stolen taunts",
			tooltip = "Display stolen taunts with the blue colour when someone takes taunt away from you using a taunt skill",
			getFunc = function() return  TauntHelper.savedVars.displayStolenMobs end,
			setFunc = function(value)
				 TauntHelper.savedVars.displayStolenMobs = value
			end
		})


	table.insert (options,{
			type = "colorpicker",
			name = "Stolen taunt color",
			tooltip = "Color for stolen taunts",
			getFunc = function() return unpack(TauntHelper.savedVars.stolenTauntColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.stolenTauntColor = {r,g,b,1} end,
		})

    table.insert (options,{
			type = "checkbox",
			name = "Blink stolen taunts",
			--tooltip = "Taunt Helper can cleanup your taunt list by showing you only the priority taunt targets (default ON) when OFF all mobs will appear in taunt list similar to Untaunted.",
			getFunc = function() return TauntHelper.savedVars.blinkStolenTaunt end,
			setFunc = function(value)
				 TauntHelper.savedVars.blinkStolenTaunt = value
			end
		})











	table.insert (options,{
			type = "header",
			name = "Loose Mobs"
		})
	table.insert (options,{
			type = "checkbox",
			name = "Attempt to detect loose mobs",
			tooltip = "Loose priority mobs is one which has been detected but has no current taunt.  This can be useful for tanks as a warning to find the add to taunt. (PLEASE NOTE: ESO API does not provide a method of detecting of all mobs when not engaged in combat with you directly, this means that not all loose mobs may appear in your loose mob list)",
			getFunc = function() return  TauntHelper.savedVars.detectSpawnedAdds end,
			setFunc = function(value)
				 TauntHelper.savedVars.detectSpawnedAdds = value
				 if TauntHelper.savedVars.detectSpawnedAdds==false then
				    TauntHelper.savedVars.dpsDisplayLooseAdds = false
				 end
			end
		})

	table.insert (options,{
			type = "checkbox",
			name = "Show loose mobs when not tanking",
			tooltip = "Display loose mobs when you have no taunt slotted on your skills. This can be useful as DPS/Healer especially in no death content in the event that a mob is taunted late, or allowed to drop off",
			getFunc = function() return  TauntHelper.savedVars.dpsDisplayLooseAdds end,
			setFunc = function(value)
				 --TauntHelper.savedVars.dpsDisplayLooseAdds = value
				 if TauntHelper.savedVars.detectSpawnedAdds == false then
				    TauntHelper.savedVars.dpsDisplayLooseAdds = false
				 else
				    TauntHelper.savedVars.dpsDisplayLooseAdds = value
				 end
			end
		})



	table.insert (options,{
			type = "colorpicker",
			name = "Loose mob color",
			getFunc = function() return unpack(TauntHelper.savedVars.looseTauntColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.looseTauntColor = {r,g,b,1} end,
		})

	table.insert (options,{
            type = "slider",
            name = "Seconds detected loose mobs remain in list",
            min = 1,
            max = 10,
            step = 1,
            getFunc = function() return TauntHelper.savedVars.detectSpawnedAddsSeconds end,
            setFunc = function(value)
                TauntHelper.savedVars.detectSpawnedAddsSeconds = value
            end,
        })




    table.insert (options,{
			type = "checkbox",
			name = "Blink loose mobs",
			--tooltip = "Taunt Helper can cleanup your taunt list by showing you only the priority taunt targets (default ON) when OFF all mobs will appear in taunt list similar to Untaunted.",
			getFunc = function() return TauntHelper.savedVars.blinkLooseMob end,
			setFunc = function(value)
				 TauntHelper.savedVars.blinkLooseMob = value
			end
		})

		table.insert (options,{
			type = "header",
			name = "Taunt Counter"
		})

	    table.insert (options,{
            type = "description",
            title = nil,	--(optional)
            text = "Update 41 includes a taunt counter, these settings affect how taunt counter stacks are displayed.  All 5 stacks will be visible once update 41 becomes live.",
            width = "full",	--or "half" (optional)
        })

		table.insert (options,{
			type = "colorpicker",
			name = "Targeting mob border color (1 stack)",
			tooltip = "Due to limitations with ESO the current target border only functions under the following conditions.  You have a taunt slotted, and the current mob has an active taunt.",
			getFunc = function() return unpack(TauntHelper.savedVars.reticleOverColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.reticleOverColor = {r,g,b,1} end,
		})





		--[[
		table.insert (options,{
			type = "checkbox",
			name = "Display Taunt Counter number",
			tooltip = "(default OFF) Only available in update 41, display taunt counter 2 and above",
			getFunc = function() return TauntHelper.savedVars.enableTauntStacks end,
			setFunc = function(value)
				TauntHelper.savedVars.enableTauntStacks = value
				TauntHelper.setupUI()
			end
		})
		--]]

		table.insert (options,{
			type = "colorpicker",
			name = "Taunt Counter border color (2 stacks)",
			tooltip = "Color for the border of a targeted mob for which has 2 stacks of taunt",
			getFunc = function() return unpack(TauntHelper.savedVars.tauntCounter2ImmunityColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.tauntCounter2ImmunityColor = {r,g,b,1} end,
		})

		table.insert (options,{
			type = "colorpicker",
			name = "Taunt Counter border color (3 stacks)",
			tooltip = "Color for the border of a targeted mob for which has 3 stacks of taunt",
			getFunc = function() return unpack(TauntHelper.savedVars.tauntCounter3ImmunityColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.tauntCounter3ImmunityColor = {r,g,b,1} end,
		})

		table.insert (options,{
			type = "colorpicker",
			name = "Taunt Counter border color (4 stacks)",
			tooltip = "Color for the border of a targeted mob for which has 4 stacks of taunt and close to being over taunted",
			getFunc = function() return unpack(TauntHelper.savedVars.tauntCounter4ImmunityColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.tauntCounter4ImmunityColor = {r,g,b,1} end,
		})




		table.insert (options,{
			type = "colorpicker",
			name = "Over taunted border color (5 stacks)",
			tooltip = "Only appears if you have a taunt sloted, and the current mob is over taunted.  This occures in situations when multiple players have taunt slotted and pass taunt between each other until ESO applies taunt immunity to the mob",
			getFunc = function() return unpack(TauntHelper.savedVars.tauntImmunityColor) end,
			setFunc = function(r,g,b,a) TauntHelper.savedVars.tauntImmunityColor = {r,g,b,1} end,
		})



	table.insert (options,{
			type = "header",
			name = "UI Customization"
		})




    table.insert (options,{
			type = "checkbox",
			name = "Taunts start from the bottom row",
			tooltip = "(default OFF) list of taunted mobs start at the bottom and the second mob appears above the first",
			getFunc = function() return TauntHelper.savedVars.risingTauntBars end,
			setFunc = function(value)
				 TauntHelper.savedVars.risingTauntBars = value
			end
		})




    table.insert (options,{
            type = "dropdown",
            name = "Taunt bar font style",
            tooltip = "(default Univers 57) mob names in taunt bars will use this style",
            choices = fontsDefined,
            width = "full",
            getFunc = function() return TauntHelper.savedVars.fontTauntBars end, --TauntHelper.savedVars.fontTauntBars end,
            setFunc = function(choice)
                TauntHelper.savedVars.fontTauntBars = choice
                TauntHelper.setupUI()
            end,
            scrollable = true,
        })



	table.insert (options,{
            type = "slider",
            name = "Taunt bar width",
             tooltip = "(default 226) width of taunt bars",
            min = 175,
            max = 300,
            step = 1,
            getFunc = function() return TauntHelper.savedVars.widthOfTauntBars end,
            setFunc = function(value)
                TauntHelper.savedVars.widthOfTauntBars = value
                TauntHelper.setupUI()
            end,
        })

	table.insert (options,{
            type = "slider",
            name = "Taunt bar height",
             tooltip = "(default 34) height of taunt bars",
            min = 24,
            max = 38,
            step = 1,
            getFunc = function() return TauntHelper.savedVars.heightOfTauntBars end,
            setFunc = function(value)
                TauntHelper.savedVars.heightOfTauntBars = value
                TauntHelper.setupUI()
            end,
        })


	table.insert (options,{
            type = "slider",
            name = "Taunt font size",
             tooltip = "(default 18) size of mob names in taunt bars",
            min = 8,
            max = 24,
            step = 1,
            getFunc = function() return TauntHelper.savedVars.fontSizeTauntBars end,
            setFunc = function(value)
                TauntHelper.savedVars.fontSizeTauntBars = value
                TauntHelper.setupUI()
            end,
        })




	table.insert (options,{
            type = "slider",
            name = "Taunt bar border size",
             tooltip = "(default 4) border of taunt bars which indicates overtaunt, and current target",
            min = 1,
            max = 4,
            step = 1,
            getFunc = function() return TauntHelper.savedVars.borderOfTauntBars end,
            setFunc = function(value)
                TauntHelper.savedVars.borderOfTauntBars = value
                TauntHelper.setupUI()
            end,
        })

    table.insert (options,{
			type = "checkbox",
			name = "Reverse Taunt Progression",
			tooltip = "(default OFF) when changed to ON taunt progression is reversed taunt gets smaller as it about to run out",
			getFunc = function() return TauntHelper.savedVars.reverseTauntBarDirection end,
			setFunc = function(value)
				 TauntHelper.savedVars.reverseTauntBarDirection = value
			end
		})

	table.insert (options,{
			type = "checkbox",
			name = "Normal Taunt Direction",
			tooltip = "(default ON) when changed to OFF taunt bar growth is left to right",
			getFunc = function() return TauntHelper.savedVars.normalDirectionOfTauntBars end,
			setFunc = function(value)
				TauntHelper.savedVars.normalDirectionOfTauntBars = value
				TauntHelper.setupUI()
			end
		})






	LAM:RegisterOptionControls(TauntHelper.name.."Options", options)
end
