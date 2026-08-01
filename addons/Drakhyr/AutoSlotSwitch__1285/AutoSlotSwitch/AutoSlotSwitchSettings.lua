ASS_panelData = {
	type = "panel",
	name = "AutoSlotSwitch",
	displayName = "AutoSlotSwitch",
	author = "Drakhyr",
	--version = "0.6",
	registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
	registerForDefaults = true	--boolean (optional) (will set all options controls back to default values)
}

ASS_optionsTable = {
	[1] = {
		type = "description",
		title = "|c749cc9Switches slots automatically when entering and leaving combat|r",	--(optional)
		text = "Reminder: Combat state is defined by the game and it can take a while to get out of combat.",
		width = "full",	--or "half" (optional)
	},
	[2] = {
		type = "description",
		name = "",
		width = "full",
		-- type = "checkbox",
		-- name = "Auto Slot Switch",
		-- tooltip = "",
		-- --default = true,
		-- getFunc = function() return AutoSlotSwitch.savedVariables.Enabled end,
		-- setFunc = function(value) 
		-- 	AutoSlotSwitch.toggle()
		-- end,
		-- --width = "full",	--or "half" (optional)
		-- --warning = "Will need to reload the UI.",	--(optional)
	},
	[3] = {
		type = "header",
		name = "",
		width = "full",
	},
	[4] = {
		type = "slider",
		name = "Temporary lock duration (seconds)",
		tooltip = "How many seconds to stay on manual slot until changing back to combat slot",
		min = 1,
		max = 15,
		step = 1,	--(optional)
		getFunc = function() return AutoSlotSwitch.savedVariables.TempDuration end,
		setFunc = function(value) AutoSlotSwitch.setTempDuration(value) end,
		width = "full",	--or "half" (optional)
		default = 6,	--(optional)
	},
	[5] = {
		type = "description",
		text = "When you manually switch to another slot (e.g. siege) during combat it will be locked for the set seconds until it switches back. If you have 'only if actually taking damage' activated it will stay on the current slot until you receive damage.",
		width = "full",
	},
	[6] = {
		type = "checkbox",
		name = "Play sound if past temporary lock",
		tooltip = "Plays a sound if the temporary lock is over",
		default = false,
		getFunc = function() return AutoSlotSwitch.savedVariables.LockNotification end,
		setFunc = function(value) 
			AutoSlotSwitch.LockNotification = value
			AutoSlotSwitch.savedVariables.LockNotification = value
		end,
		width = "full",	--or "half" (optional)
	},
	[7] = {
		type = "header",
		name = "",
		width = "full",
	},
	[8] = {
		type = "checkbox",
		name = "Only if actually taking damage",
		tooltip = "Does not switch slots on entering or leaving combat including after temporary lock.\nInstead switches only on actual damage when in combat. Health has to go down for it to react.",
		default = false,
		getFunc = function() return AutoSlotSwitch.savedVariables.UnderAttackEnabled end,
		setFunc = function(value) AutoSlotSwitch.toggleUnderAttack(value) end,
		width = "full",	--or "half" (optional)
	},
	[9] = {
		type = "checkbox",
		name = "    Use Health Threshold",
		tooltip = "Will only react if HP went below threshold and using 'only if actually taking damage'-option.",
		default = false,
		getFunc = function() return AutoSlotSwitch.savedVariables.HealthThresholdEnabled end,
		setFunc = function(value) AutoSlotSwitch.toggleHealthThreshold(value) end,
		width = "full",	--or "half" (optional)
	},
	[10] = {
		type = "slider",
		name = "    Health Threshold Percentage",
		tooltip = "Choose threshold from 1 to 100 percent",
		min = 1,
		max = 100,
		step = 1,	--(optional)
		getFunc = function() return AutoSlotSwitch.savedVariables.HealthThreshold *100 end,
		setFunc = function(value) AutoSlotSwitch.setHealthThreshold(value) end,
		width = "full",	--or "half" (optional)
		default = 6,	--(optional)
	},
	[11] = {
		--type = "description",
		--text = "",
		type = "header",
		name = "",
		width = "full",
	},
	[12] = {
		type = "checkbox",
		name = "Reset temporary lock duration (recommended)",
		--tooltip = "As long as you use (or try and fail to use) a siege or repair kit the temporary lock duration will be reset, giving you time to continue.",
		default = false,
		getFunc = function() return AutoSlotSwitch.savedVariables.RestartTempLock end,
		setFunc = function(value) AutoSlotSwitch.toggleRestartTempLock(value) end,
		width = "full",	--or "half" (optional)
		--warning = "Will need to reload the UI.",	--(optional)
	},
	[13] = {
		type = "description",
		text = "As long as you use (or try and fail to use) a siege or repair kit the temporary lock duration will be reset, giving you time to continue (repairing a wall until it's fully repaired, or placing a siege engine after a few failed attempts).",
		width = "full",
		--type = "slider",
		--name = "Temporary lock duration (seconds)",
		--tooltip = "How many seconds to stay on manual slot until changing back to combat slot",
		--min = 1,
		--max = 15,
		--step = 1,	--(optional)
		--getFunc = function() return AutoSlotSwitch.savedVariables.TempDuration end,
		--setFunc = function(value) AutoSlotSwitch.savedVariables.TempDuration = value end,
		--width = "full",	--or "half" (optional)
		--default = 6,	--(optional)
	},
	[14] = {
		type = "header",
		name = "",
		width = "full",
		--name = "ReloadUI",
		--tooltip = "Do this after you enabled/disabled the addon",
		--func = function() ReloadUI() end,
		--width = "half",	--or "half" (optional)
		--warning = "Will need to reload the UI.",	--(optional)
	},
	[15] = {
		type = "description",
		title = "",	--(optional)
		text = "|c749cc9With the slider (in the submenus) you can select your target quickslot to switch to (1 equals 12 o'clock, going clockwise). You can select different slots for PvP worlds or dungeons. If you don't need a special setting for dungeons, pve or pvp you can just set the general setting which includes everything and leave the others on 'off'.|r",
		width = "full",	--or "half" (optional)
	},
	[16] = {
		type = "submenu",
		name = "General Quickslot Switch",
		tooltip = "Switches slots automatically when entering and leaving combat",	--(optional)
		controls = {
			[1] = {
				type = "description",
				title = "|c749cc9Will just refer to PVE-non-dungeon areas if PvP or dungeon settings are enabled. FYI: Public dungeons are not 'dungeons' but count as normal 'zone' and the general setting is used.|r",	--(optional)
				--title = nil,	--(optional)
				text = "",
				width = "full",	--or "half" (optional)
			},
			[2] = {
				type = "slider",
				name = "General Quickslot Selector",
				tooltip = "Choose the quickslot that you wish to automatically switch to (e.g. 5 for the bottom slot)",
				min = 1,
				max = ACTION_BAR_UTILITY_BAR_SIZE,
				step = 1,	--(optional)
				getFunc = function() return AutoSlotSwitch.remapGET(AutoSlotSwitch.savedVariables.SlotPos) end,
				setFunc = function(value) AutoSlotSwitch.remapSET("SlotPos", value) end,
				width = "full",	--or "half" (optional)
				default = 5,	--(optional)
			},
			[3] = {
				type = "checkbox",
				name = "Search other slots if empty",
				tooltip = "Toggle the search. If disabled, it won't search and just switch to the empty slot.",
				default = true,
				getFunc = function() return AutoSlotSwitch.savedVariables.SearchEnabled end,
				setFunc = function(value) 
					AutoSlotSwitch.SearchEnabled = value
					AutoSlotSwitch.savedVariables.SearchEnabled = value
				end,
				width = "half",	--or "half" (optional)
				--warning = "Will need to reload the UI.",	--(optional)
			},
			[4] = {
				type = "editbox",
				name = "Search word",
				tooltip = "If your target slot is empty then search in other slots for something containing that search word (case sensitive)",
				getFunc = function() return AutoSlotSwitch.savedVariables.DesiredPotionType end,
				setFunc = function(value) 
					AutoSlotSwitch.savedVariables.DesiredPotionType = value 
					AutoSlotSwitch.DesiredPotionType = value
					end,
				isMultiline = false,	--boolean
				width = "half",	--or "half" (optional)
				default = "health",	--(optional)
			}
		}
	},
	[17] = {
		type = "submenu",
		name = "Dungeon Quickslot Switch",
		tooltip = "Switches slots automatically when entering and leaving combat",	--(optional)
		controls = {
			[1] = {
				type = "description",
				title = "",	--(optional)
				text = "",
				width = "full",	--or "half" (optional)
			},
			[2] = {
				type = "checkbox",
				name = "Enable",
				tooltip = "will be used over general setting when inside a dungeon",
				default = false,
				getFunc = function() return AutoSlotSwitch.savedVariables.DungeonEnabled end,
				setFunc = function(value) AutoSlotSwitch.DungeonToggle() end,
				width = "full"	--or "half" (optional)
			},
			[3] = {
				type = "slider",
				name = "Dungeon Quickslot Selector",
				tooltip = "Choose the quickslot that you wish to automatically switch to (e.g. 5 for the bottom slot)",
				min = 1,
				max = ACTION_BAR_UTILITY_BAR_SIZE,
				step = 1,	--(optional)
				getFunc = function() return AutoSlotSwitch.remapGET(AutoSlotSwitch.savedVariables.DungeonSlotPos ) end,
				setFunc = function(value) AutoSlotSwitch.remapSET("DungeonSlotPos", value) end,
				width = "full",	--or "half" (optional)
				default = 6,	--(optional)
			},
			[4] = {
				type = "checkbox",
				name = "Search other slots if empty",
				tooltip = "Toggle the search. If disabled, it won't search and just switch to the empty slot.",
				default = true,
				getFunc = function() return AutoSlotSwitch.savedVariables.DungeonSearchEnabled end,
				setFunc = function(value) 
					AutoSlotSwitch.DungeonSearchEnabled = value
					AutoSlotSwitch.savedVariables.DungeonSearchEnabled = value
				end,
				width = "half",	--or "half" (optional)
				--warning = "Will need to reload the UI.",	--(optional)
			},
			[5] = {
				type = "editbox",
				name = "Desired quickslot item to search for",
				tooltip = "If your target slot is empty then search in other slots for something containing that search word",
				getFunc = function() return AutoSlotSwitch.savedVariables.DungeonDesiredPotionType end,
				setFunc = function(value) 
					AutoSlotSwitch.savedVariables.DungeonDesiredPotionType = value 
					AutoSlotSwitch.DungeonDesiredPotionType = value
					end,
				isMultiline = false,	--boolean
				width = "half",	--or "half" (optional)
				default = "damage",	--(optional)
			},
			[6] = {
				type = "checkbox",
				name = "Ignore PvP dungeons",
				tooltip = "Use the PvP setting if you are in a PvP dungeon. This should only be relevant to the Imperial City DLC, but I can't test this atm.",
				default = false,
				getFunc = function() return AutoSlotSwitch.savedVariables.DungeonIgnore end,
				setFunc = function(value) 
					AutoSlotSwitch.savedVariables.DungeonIgnore = value 
					AutoSlotSwitch.DungeonIgnore = value
					end,
				width = "full"	--or "half" (optional)
			}
		}
	},
	[18] = {
		type = "submenu",
		name = "PvP Quickslot Switch",
		tooltip = "Switches slots automatically when entering and leaving combat",	--(optional)
		controls = {
			[1] = {
				type = "description",
				title = "",	--(optional)
				--title = nil,	--(optional)
				text = "",
				width = "full",	--or "half" (optional)
			},
			[2] = {
				type = "checkbox",
				name = "Enable",
				tooltip = "will be used over general setting when inside PvP world",
				default = false,
				getFunc = function() return AutoSlotSwitch.savedVariables.PVPEnabled end,
				setFunc = function(value) AutoSlotSwitch.PVPToggle() end,
				width = "full"	--or "half" (optional)
			},
			[3] = {
				type = "slider",
				name = "PvP Quickslot Selector",
				tooltip = "Choose the quickslot that you wish to automatically switch to (e.g. 5 for the bottom slot)",
				min = 1,
				max = ACTION_BAR_UTILITY_BAR_SIZE,
				step = 1,	--(optional)
				getFunc = function() return AutoSlotSwitch.remapGET(AutoSlotSwitch.savedVariables.PVPSlotPos) end,
				setFunc = function(value) AutoSlotSwitch.remapSET("PVPSlotPos", value) end,
				width = "full",	--or "half" (optional)
				default = 7,	--(optional)
			},
			[4] = {
				type = "checkbox",
				name = "Search other slots if empty",
				tooltip = "Toggle the search. If disabled, it won't search and just switch to the empty slot.",
				default = true,
				getFunc = function() return AutoSlotSwitch.savedVariables.PVPSearchEnabled end,
				setFunc = function(value) 
					AutoSlotSwitch.PVPSearchEnabled = value
					AutoSlotSwitch.savedVariables.PVPSearchEnabled = value
				end,
				width = "half",	--or "half" (optional)
				--warning = "Will need to reload the UI.",	--(optional)
			},
			[5] = {
				type = "editbox",
				name = "Desired quickslot item to search for",
				tooltip = "If your target slot is empty then search in other slots for something containing that search word",
				getFunc = function() return AutoSlotSwitch.savedVariables.PVPDesiredPotionType end,
				setFunc = function(value) 
					AutoSlotSwitch.savedVariables.PVPDesiredPotionType = value 
					AutoSlotSwitch.PVPDesiredPotionType = value
					end,
				isMultiline = false,	--boolean
				width = "half",	--or "half" (optional)
				default = "health",	--(optional)
			}
		}
	},
	[19] = {
		type = "description",
		title = "",	--(optional)
		text = "",
		width = "full",	--or "half" (optional)
	},
	--[[[18] = {
		type = "checkbox",
		name = "Debug",
		tooltip = "",
		default = false,
		getFunc = function() return AutoSlotSwitch.savedVariables.Debug end,
		setFunc = function(value) 
			AutoSlotSwitch.savedVariables.Debug = value 
			AutoSlotSwitch.Debug = value 
		end,
		width = "full",	--or "half" (optional)
		--warning = "Will need to reload the UI.",	--(optional)
	}--]]
}