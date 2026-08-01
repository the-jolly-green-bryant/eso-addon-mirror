-- Settings menu.


local barChoices = {
	[1] = "|t160:20:PRadiatingRegenTracker/icons/gradientProgressBar.dds|t",
	[2] = "|t160:20:RadiatingRegenTracker/icons/gradientProgressBarFlipped.dds|t",
	[3] = "|t160:20:RadiatingRegenTracker/icons/gradientProgressBar2.dds|t",
	[4] = "|t160:20:RadiatingRegenTracker/icons/gradientProgressBar2Flipped.dds|t",
    [5] = "|t160:20:RadiatingRegenTracker/icons/progressBar.dds|t",
}


function RRT_LoadSettings()
    local panelData = {
        type = "panel",
        name = "Radiating Regen Tracker",
        displayName = "Radiating Regen Tracker",
        author = "branddi",
        version = "1.0",
        --website = "",
		--feedback = "",
		--donation = "",
        --slashCommand = "/rr",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel("Radiating Regen Tracker", panelData)

    local optionsTable = {}

      table.insert(optionsTable, {
        type = "button",
        name = "Show/Hide UI",
        func = function() RRT_showUI() end,
        width = "half"

    })
	  table.insert(optionsTable, {

                type = "checkbox",
                name = "Turn off Radiating Regen",
                getFunc = function() return RRTsavedVars.onlyTrackWhenWearing end,
                setFunc = function(value) RRTsavedVars.onlyTrackWhenWearing = value 
				RRT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })

    	  table.insert(optionsTable, {

                type = "checkbox",
                name = "Turn off Radiating Regen in trials",
                getFunc = function() return RRTsavedVars.disableInTrials end,
                setFunc = function(value) RRTsavedVars.disableInTrials = value
				RRT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })


	table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only in combat",
                getFunc = function() return RRTsavedVars.showOnlyInCombat end,
                setFunc = function(value) RRTsavedVars.showOnlyInCombat = value
				RRT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })
    table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only on Damage Dealers",
                getFunc = function() return RRTsavedVars.trackOnlyDD end,
                setFunc = function(value) RRTsavedVars.trackOnlyDD = value 
				end,
                width = "full",	--or "half" (optional)

            })

--
--   table.insert(optionsTable, {
--                type = "dropdown",
--                name = "Bar Texture",
--                choices = barChoices,
--                getFunc = function() return RRTsavedVars.barTexture end,
--                setFunc = function(var) RRTsavedVars.barTexture = string.gsub(string.gsub(var,"|t",""),"160:20:","")
--                for n=1, 12 do
--                    local bar = RadiatingRegenTrackerUI:GetNamedChild("RRDurationBar"..n)
--                    bar:SetTexture(RRTsavedVars.barTexture)
 --               end
 --
 --               end,
  --              width = "half",	--or "half" (optional)
  --          })


    LibAddonMenu2:RegisterOptionControls("Radiating Regen Tracker", optionsTable)
end