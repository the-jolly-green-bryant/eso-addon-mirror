CBHMenu = CBHMenu or {}

function CBHMenu.createSettingsMenu()
	local LAM = LibAddonMenu2
	--Register the Options panel with LAM
	local panelData =
	{
		type = "panel",
		name = CBH.name,
		author = CBH.author,
		version = CBH.version,
	}
	LAM:RegisterAddonPanel("CBH_Settings", panelData)

	local notificationOptionChoices = {
		[1] = GetString(COMINGBACKHOME_MENU_NOTIFICATIONS_OPTION1),
		[2] = GetString(COMINGBACKHOME_MENU_NOTIFICATIONS_OPTION2),
		[3] = GetString(COMINGBACKHOME_MENU_NOTIFICATIONS_OPTION3),
	}

	--Set the actual panel data
	local optionsData = {
		{
			type = "checkbox",
			name = GetString(COMINGBACKHOME_MENU_USE_ACCOUNTWIDE),
			warning = GetString(COMINGBACKHOME_MENU_WILL_RELOADUI),
			getFunc = function() return ComingBackHomeSavedVariables.Default[GetDisplayName()]['$AccountWide'].useAccountWide end,
			setFunc = function(value)
				ComingBackHomeSavedVariables.Default[GetDisplayName()]['$AccountWide'].useAccountWide = value
				ReloadUI()
			end,
		},
		{
			type = "divider",
			width = "full",
			height = 20,
			alpha = 0.25,
		},
		{
			type = "checkbox",
			name = GetString(COMINGBACKHOME_MENU_AUTO_TELEPORTATION_TITLE),
			tooltip = GetString(COMINGBACKHOME_MENU_AUTO_TELEPORTATION_POP_UP),
			getFunc = function()
				if CBH.savedVars.autoTeleportation ~= nil then
					return CBH.savedVars.autoTeleportation
				else return true
				end
			end,
			setFunc = function(value)
				CBH.savedVars.autoTeleportation = value
				end,
		},
		{
			type = "dropdown",
			name = GetString(COMINGBACKHOME_MENU_NOTIFICATIONS_TITLE),
			tooltip = GetString(COMINGBACKHOME_MENU_NOTIFICATIONS_POP_UP),
			choices = notificationOptionChoices,
			getFunc = function()
				return notificationOptionChoices[CBH.savedVars.notificationOption]
			end,
			setFunc = function(selectedChoice)
				for index, name in ipairs(notificationOptionChoices) do
					if name == selectedChoice then
						CBH.savedVars.notificationOption = index
						break
					end
				end
			end,
		},
		{
			type = "divider",
			width = "full",
			height = 20,
			alpha = 0.25,
		},
		{
			type = "checkbox",
			name = GetString(COMINGBACKHOME_MENU_ALLOW_PREVIEW_HOUSES_TITLE),
			tooltip = GetString(COMINGBACKHOME_MENU_ALLOW_PREVIEW_HOUSES_POP_UP),
			getFunc = function()
				if CBH.savedVars.includePreviewHouses ~= nil then
					return CBH.savedVars.includePreviewHouses
				else return true
				end
			end,
			setFunc = function(value)
				CBH.savedVars.includePreviewHouses = value
			end,
		},
		{
			type = "checkbox",
			name = GetString(COMINGBACKHOME_MENU_ALLOW_OTHER_PLAYERS_HOUSES_TITLE),
			tooltip = GetString(COMINGBACKHOME_MENU_ALLOW_OTHER_PLAYERS_HOUSES_POP_UP),
			getFunc = function()
				if CBH.savedVars.includeOtherPlayersHouses ~= nil then
					return CBH.savedVars.includeOtherPlayersHouses
				else return true
				end
			end,
			setFunc = function(value)
				CBH.savedVars.includeOtherPlayersHouses = value
			end,
		},
		{
			type = "divider",
			width = "full",
			height = 20,
			alpha = 0.25,
		},
		{
			type = "description",
			text = zo_strformat("Tip: type /cbh to port to the last visited house.", "\n", "Controls settings: bind a key in game's controls settings to port to the last visited house"), -- or string id or function returning a string
			width = "full",
		}
	}
	LAM:RegisterOptionControls("CBH_Settings", optionsData)
end
