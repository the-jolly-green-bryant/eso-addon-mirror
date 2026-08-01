-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.

HardModeReminders = HardModeReminders or {}
local HMR = HardModeReminders
local LAM = LibAddonMenu2

local SettingsMenu = {}

function SettingsMenu.CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = GetString(HMR_APP_NAME),
		displayName = GetString(HMR_APP_NAME_LONG),
		author = HMR.author,
		version = HMR.version,
		slashCommand = "/hmrs",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local indent = "     "

	local O = HMR.savedVariables.options

	local optionsTable = {
		-- General
		{
			type = "header",
			name = GetString(HMR_SETTINGS_GENERAL),
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(HMR_SETTINGS_GENERAL_UI_UNLOCK),
			-- tooltip = GetString(HMR_SETTINGS_STATUS_UI_SHOWN),
			getFunc = function() return O.uiIsLocked end,
			setFunc = function(value) HMR.LockUi(value) end,
			width = "full"
		},
		{
			type = "checkbox",
			name = indent .. GetString(HMR_SETTINGS_GENERAL_UI_SHOW),
			-- tooltip = GetString(HMR_SETTINGS_STATUS_UI_SHOWN),
			getFunc = function() return HMR.isUiShowingFromSettings end,
			setFunc = function(value) HMR.SettingsShowUi(value) end,
			disabled = function() return not O.uiIsLocked end,
			width = "full"
		},
		{
		type = "button",
		name = GetString(HMR_SETTINGS_GENERAL_UI_RESET),
		tooltip = GetString(HMR_SETTINGS_GENERAL_UI_RESET),
		func = function() HMR.ResetUiPosition() end,
		width = "full",
		},

		-- Status UI
		{
			type = "header",
			name = GetString(HMR_SETTINGS_STATUS_UI),
			width = "full",
		},
		-- {
		-- 	type = "checkbox",
		-- 	name = GetString(HMR_SETTINGS_STATUS_UI_SHOWN),
		-- 	tooltip = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- 	getFunc = function() return O.uiShown end,
		-- 	setFunc = function(value) O.uiShown = value end,
		-- 	width = "full",
		-- 	disabled = true,
		-- 	warning = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- },
		-- {
		-- 	type = "checkbox",
		-- 	name = indent .. GetString(HMR_SETTINGS_STATUS_UI_ALWAYS_VISIBLE),
		-- 	tooltip = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- 	getFunc = function() return O.uiAlwaysVisible end,
		-- 	setFunc = function(value) O.uiAlwaysVisible = value end,
		-- 	-- disabled = function() return not O.uiShown end,
		-- 	width = "full",
		-- 	disabled = true,
		-- 	warning = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- },
		-- {
		-- 	type = "checkbox",
		-- 	name = indent .. indent .. GetString(HMR_SETTINGS_STATUS_UI_VISIBLE_HM_CONTENT_ONLY),
		-- 	tooltip = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- 	getFunc = function() return O.uiVisibleHmOnly end,
		-- 	setFunc = function(value) O.uiVisibleHmOnly = value; O.uiVisibleHmOnly = false end,
		-- 	-- disabled = function() return (not O.uiAlwaysVisible) or (not O.uiShown) end,
		-- 	width = "full",
		-- 	disabled = true,
		-- 	warning = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- },
		{
			type = "checkbox",
			name = GetString(HMR_SETTINGS_STATUS_UI_CLOSE_BUTTON),
			tooltip = GetString(HMR_SETTINGS_STATUS_UI_CLOSE_BUTTON_TOOLTIP),
			getFunc = function() return O.uiShowCloseButton end,
			setFunc = function(value) HMR.SetCloseButton(value) end,
			width = "full"
		},
		{
			type = "checkbox", -- indent .. 
			name = GetString(HMR_SETTINGS_STATUS_UI_COLOR),
			-- tooltip = GetString(HMR_SETTINGS_STATUS_UI_COLOR),
			getFunc = function() return O.uiTextColored end,
			setFunc = function(value) O.uiTextColored = value end,
			disabled = function() return not O.uiShown end,
			width = "full"
		},


		-- Warning Message
		{
			type = "header",
			name = GetString(HMR_SETTINGS_WARNING),
			width = "full",
		},
		-- {
		-- 	type = "checkbox",
		-- 	name = GetString(HMR_SETTINGS_WARNING_SHOW),
		-- 	tooltip = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- 	getFunc = function() return O.largeWarning end,
		-- 	setFunc = function(value) O.largeWarning = value end,
		-- 	width = "full",
		-- 	disabled = true,
		-- 	warning = GetString(HMR_SETTINGS_NOT_YET_IMPLEMENTED),
		-- },
		{
			type = "checkbox", -- indent .. 
			name = GetString(HMR_SETTINGS_WARNING_FLASH),
			-- tooltip = GetString(HMR_SETTINGS_WARNING_FLASH),
			getFunc = function() return O.largeWarningFlashing end,
			setFunc = function(value) O.largeWarningFlashing = value end,
			disabled = function() return not O.largeWarning end,
			width = "full"
		},

		-- flash speed
		-- flash color 1
		-- flash color 2
	}

	SettingsMenu.panel = LAM:RegisterAddonPanel(HMR.name .. "_Settings", panelData)
	LAM:RegisterOptionControls(HMR.name .. "_Settings", optionsTable)
end

HardModeReminders.SettingsMenu = SettingsMenu