local RK = RhalyfsKeybindings

function RK.LoadSavedSettings()
	local defaultSettings = {
  		notifications = true,
  	}
  	-- Documentation: ZO_SavedVars:NewAccountWide(savedVariableName, settingsVersion, settingsNamespace, defaultSettings, settingsProfile)
  	RK.savedSettings = ZO_SavedVars:NewAccountWide("RK_SavedSettings", 1, GetWorldName(), defaultSettings, nil, nil)
end

function RK.InitAddOnSettings()
	local LAM2 = LibAddonMenu2
	local lamPanelName = RK.SHORTNAME.."Options"

	local panelData = {
		type = "panel",
		name = RK.LONGNAME,
		displayName = RK.COLORS.BLUE..RK.LONGNAME,
		author = RK.AUTHOR,
		version = RK.VERSION,
	}

	LAM2:RegisterAddonPanel(lamPanelName, panelData)

	local optionsData = {
		[1] = {
			type = "description",
			text = "Please set the QuickSlot keybindings via ESO's built-in Keybindings controller by selecting 'CONTROLS' in the Settings List.",
		},
		[2] = {
			type = "description",
			text = "Note: Keybindings are not Account-wide but the below settings are.",
		},
        [3] = {
			type = "checkbox",
			name = "Display QuickSlot Swap Notifications",
			tooltip = "Recieve notification from "..RK.LONGNAME.." when QuickSlot is changed via Keybindings",
			getFunc = function() return RK.getSavedSetting("notifications") end,
			setFunc = function(state) RK.setSavedSetting("notifications", state) end,
        },
    }

	LAM2:RegisterOptionControls(lamPanelName, optionsData)
end

function RK.getSavedSetting(setting)
	return RK.savedSettings[setting]
end

function RK.setSavedSetting(setting, state)
	RK.savedSettings[setting] = state
end