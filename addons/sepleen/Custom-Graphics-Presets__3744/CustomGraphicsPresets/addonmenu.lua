function GP.InitAddonMenu()
    local addon_menu_panel_data = {
        type = "panel",
        name = "Custom Graphics Presets",
        displayName = "Custom Graphics Presets",
        author = "sepleen",
        version = "1.0.2",
        registerForRefresh = true,
    }

    LibAddonMenu2:RegisterAddonPanel(GP.name, addon_menu_panel_data)

    local options = {
		{
			type = "header",
			name = "Graphics Presets Options",
		},
		{
			type = "slider",
			name = "Maximum number of presets",
			min      = 10,
            max      = 20,
            step     = 1,
            default  = 10,
			--tooltip = "Set the maximum number of presets",
			getFunc = function() return GP.savedVariables.maxPresets end,
			setFunc = function(value)
				GP.savedVariables.maxPresets = value
			end,
		},
	}

	LibAddonMenu2:RegisterOptionControls(GP.name, options)
end