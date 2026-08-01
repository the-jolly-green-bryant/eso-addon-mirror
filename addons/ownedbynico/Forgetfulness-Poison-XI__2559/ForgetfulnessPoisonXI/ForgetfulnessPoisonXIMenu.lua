function FPXI.initializeSettingsMenu()

	local defaults = {
		debugd = false,
		raidonly = true,
		alert = false,
		alertInterval = 30,
		refill = false,
		crownPoisons = true,
		prefCrownPoisons = true,
	}

	local panelData = {
		type = "panel",
		name = "Forgetfulness Poison XI",
		displayName = "Forgetfulness |c32CD32Poison|r XI",
		author = "ownedbynico",
		version = FPXI.version,
		registerForRefresh = true,
	}
	
	local optionsData = {
		{
			type = "description",
			text = "Reminds you to equip poisons or even automatically equips them for you."
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Debug",
			getFunc = function() return FPXI.savedVariables.debugd end,
			setFunc = function(value) FPXI.savedVariables.debugd = value end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Raid-only mode",
			tooltip = "All of the lower features only work while being in a raid zone.",
			getFunc = function() return FPXI.savedVariables.raidonly end,
			setFunc = function(value)
						FPXI.savedVariables.raidonly = value
						FPXI.onZoneChange(_, _)
						FPXI.onInventoryChange(_, _, EQUIP_SLOT_POISON, _, _, _, _)
					  end,
			width = "full",
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Alert if poisons are empty",
			tooltip = "If refill option is enabled this will only notify you if you dont have any poisons at all.",
			getFunc = function() return FPXI.savedVariables.alert end,
			setFunc = function(value)
						FPXI.savedVariables.alert = value
						-- refresh alert loop
						FPXI.onInventoryChange(_, _, EQUIP_SLOT_POISON, _, _, _, _)
					  end,
			width = "full",
		},
		{
			type = "slider",
			name = "Alert interval",
			getFunc = function() return FPXI.savedVariables.alertInterval end,
			setFunc = function(value)
						FPXI.savedVariables.alertInterval = value
						-- unregister old loop and refresh it
						EVENT_MANAGER:UnregisterForUpdate(FPXI.name .. "Loop")
						FPXI.onInventoryChange(_, _, EQUIP_SLOT_POISON, _, _, _, _)
					  end,
			min = 10,
			max = 120,
			step = 10,
			default = 30,
			disabled = function() return not FPXI.savedVariables.alert end,
			width = "full"
		},
		{
			type = "divider",
		},
		{
			type = "checkbox",
			name = "Auto-refill poisons",
			getFunc = function() return FPXI.savedVariables.refill end,
			setFunc = function(value) FPXI.savedVariables.refill = value end,
			width = "full",
		},
		{
			type = "checkbox",
			name = "Use crown poisons",
			getFunc = function() return FPXI.savedVariables.crownPoisons end,
			setFunc = function(value) FPXI.savedVariables.crownPoisons = value end,
			disabled = function() return not FPXI.savedVariables.refill end,
			width = "full"
		},
		{
			type = "checkbox",
			name = "Prefer over crafted ones",
			getFunc = function() return FPXI.savedVariables.prefCrownPoisons end,
			setFunc = function(value) FPXI.savedVariables.prefCrownPoisons = value end,
			disabled = function() return not FPXI.savedVariables.crownPoisons or not FPXI.savedVariables.refill end,
			width = "full"
		},
	}

	FPXI.savedVariables = ZO_SavedVars:NewCharacterIdSettings("FPXISV", 1, nil, defaults)
	LibAddonMenu2:RegisterAddonPanel("FPXIS", panelData)
	LibAddonMenu2:RegisterOptionControls("FPXIS", optionsData)
end