-- Settings menu.


local barChoices = {
	[1] = "|t160:20:PowerfulAssaultTracker/icons/gradientProgressBar.dds|t",
	[2] = "|t160:20:PowerfulAssaultTracker/icons/gradientProgressBarFlipped.dds|t",
	[3] = "|t160:20:PowerfulAssaultTracker/icons/gradientProgressBar2.dds|t",
	[4] = "|t160:20:PowerfulAssaultTracker/icons/gradientProgressBar2Flipped.dds|t",
    [5] = "|t160:20:PowerfulAssaultTracker/icons/progressBar.dds|t",
}


function PAT_LoadSettings()
    local panelData = {
        type = "panel",
        name = "Powerful Assault Tracker",
        displayName = "Powerful Assault Tracker",
        author = "Hyperioxes",
        version = "1.5a",
        website = "https://www.esoui.com/downloads/info2814-PowerfulAssaultTracker.html",
		feedback = "https://www.esoui.com/downloads/info2814-PowerfulAssaultTracker.html#comments",
		donation = "https://www.esoui.com/downloads/info2814-PowerfulAssaultTracker.html#donate",
        slashCommand = "/pat",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel("Powerful Assault Tracker", panelData)

    local optionsTable = {}

      table.insert(optionsTable, {
        type = "button",
        name = "Show/Hide UI",
        func = function() PAT_showUI() end,
        width = "half"

    })
	  table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only when you're wearing Powerful Assault",
                getFunc = function() return PATsavedVars.onlyTrackWhenWearing end,
                setFunc = function(value) PATsavedVars.onlyTrackWhenWearing = value 
				PAT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })
	table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only in combat",
                getFunc = function() return PATsavedVars.showOnlyInCombat end,
                setFunc = function(value) PATsavedVars.showOnlyInCombat = value
				PAT_combatSwitch()
				end,
                width = "full",	--or "half" (optional)

            })
    table.insert(optionsTable, {

                type = "checkbox",
                name = "Track only on Damage Dealers",
                getFunc = function() return PATsavedVars.trackOnlyDD end,
                setFunc = function(value) PATsavedVars.trackOnlyDD = value 
				end,
                width = "full",	--or "half" (optional)

            })

   table.insert(optionsTable, {
                type = "dropdown",
                name = "Bar Texture",
                choices = barChoices,
                getFunc = function() return PATsavedVars.barTexture end,
                setFunc = function(var) PATsavedVars.barTexture = string.gsub(string.gsub(var,"|t",""),"160:20:","")
                for n=1, 12 do
                    local bar = PowerfulAssaultTrackerUI:GetNamedChild("PADurationBar"..n)
                    bar:SetTexture(PATsavedVars.barTexture)
                end
                
                end,
                width = "half",	--or "half" (optional)
            })


    
    LibAddonMenu2:RegisterOptionControls("Powerful Assault Tracker", optionsTable)
end