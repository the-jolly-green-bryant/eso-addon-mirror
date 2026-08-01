AAI = AAI or {}
local AAI = AAI

function AAI.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Asquart's Authentic Icons",
		displayName	 = "|c24abfeAsquart's Authentic Icons|r",
		author			 = AAI.author,
		version			 = AAI.version,
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "description",
			text = "Icons quality settings",
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Use high resolution icons (x2)",
			default = false,
			getFunc = function() return AAI.savedVariables.use128Version end,
			setFunc = function( newValue ) AAI.savedVariables.use128Version = newValue end,
			warning = "Requires /reloadui to apply the changes",
		},
    	{
			type = "button",
			name = "Reload UI",
			width = "full",
			func = function() ReloadUI("ingame") end,
			disabled = function() return AAI.settings.use128Version == AAI.savedVariables.use128Version end
		},
	}

	LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(AAI.name .. "Options", menuOptions )
	LAM:RegisterOptionControls(AAI.name .. "Options", dataTable )
end
