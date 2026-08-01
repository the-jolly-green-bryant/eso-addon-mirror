-- sentry to make sure SW is declared before use
if SW == nil then SW = {} end

--
-- Register with LibMenu and ESO
--
function SW.MakeMenu()
    -- load the settings->addons menu library
	local LAM = LibAddonMenu2
	local saveData = SW.settings
	local panelName = "SheathWeaponPanel"

    -- the panelData for the addons menu
	local panelData = {
		type = "panel",
		name = "Sheath Weapon",
		displayName = "Sheath Weapon",
		author = "GlassHalfFull",
        version = "" .. SW.version,
	}

    -- this addons entries in the addon menu
	local optionsData = {
		{
			type = "header",
			name = "Timing Settings",
		},
		{
			type = "slider",
			name = "Time to wait to check combat state.",
			getFunc = function() return saveData.timeToCheckCombatState end,
			setFunc = function(newValue) saveData.timeToCheckCombatState = newValue end,
			min = 0,
			max = 6000,
			step = 250,
			decimals = 0,
			-- warning = "Will need to reload the UI.",	--(optional)
            requiresReload = true, -- replaces the warning property
			tooltip = "Time to wait to check if player is out of combat.",
			default = SW.defaults.timeToCheckCombatState,	--(optional)
		},
		{
			type = "slider",
			name = "Time to wait before sheathing player weapon.",
			getFunc = function() return saveData.timeToWaitBeforeSheathing end,
			setFunc = function(newValue) saveData.timeToWaitBeforeSheathing = newValue end,
			min = 0,
			max = 6000,
			step = 250,
			decimals = 0,
			-- warning = "Will need to reload the UI.",	--(optional)
            requiresReload = true, -- replaces the warning property
			tooltip = "Time to wait before sheathing player weapon.",
			default = SW.defaults.timeToWaitBeforeSheathing,	--(optional)
		},
		{
			type = "slider",
			name = "Time to loop when player is out of combat.",
			getFunc = function() return saveData.timeToLoop end,
			setFunc = function(newValue) saveData.timeToLoop = newValue end,
			min = 0,
			max = 7500,
			step = 250,
			decimals = 0,
--			width = "half",
			-- warning = "Will need to reload the UI.",	--(optional)
            requiresReload = true, -- replaces the warning property
			tooltip = "Time to loop when player is out of combat.",
			default = SW.defaults.timeToLoop,	--(optional)
		},
	}

	local registeredPanel = LAM:RegisterAddonPanel(panelName, panelData)
	LAM:RegisterOptionControls(panelName, optionsData)
end