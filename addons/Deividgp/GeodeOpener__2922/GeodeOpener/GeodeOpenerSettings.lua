local LAM = LibAddonMenu2

function GO.CreateSettingsMenu()

    local panelData = {
        type                = "panel",
        name                = GO.name,
        displayName         = GO.name,
        author              = GO.author,
        version             = GO.version,
        slashCommand        = "gosettings",
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    local SettingsPanel = LAM:RegisterAddonPanel(GO.name, panelData)

	local SettingsData = {
		{
			type = "header",
			name = GO.name .. " settings",
		},
		{
			type = "checkbox",
			name = "Automatic opener",
			tooltip = "Open geodes everytime a loading screen ends",
			getFunc = function() return GO.vars.autoOpener end,
			setFunc = function(newValue) GO.vars.autoOpener = newValue end,
            warning = "Will need to reload the UI",
		},
        {
			type = "checkbox",
			name = "Open mail geodes",
			tooltip = "Open geodes everytime you take from the mail",
			getFunc = function() return GO.vars.openMailGeode end,
			setFunc = function(newValue) GO.vars.openMailGeode = newValue end,
            warning = "Will need to reload the UI",
		},
        {
			type = "checkbox",
			name = "Open quest geodes",
			tooltip = "Open geodes from quests everytime you finish one such as a pledge",
			getFunc = function() return GO.vars.openQuestGeode end,
			setFunc = function(newValue) GO.vars.openQuestGeode = newValue end,
            warning = "Will need to reload the UI",
		},
    }
    LAM:RegisterOptionControls(GO.name, SettingsData)
	
end