-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.

SkillPointAlerts = SkillPointAlerts or {}
local SPA = SkillPointAlerts
local LAM = LibAddonMenu2

local SettingsMenu = {}

function SettingsMenu.CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = GetString(SPA_APP_NAME),
		displayName = GetString(SPA_APP_NAME_LONG),
		author = SPA.author,
		version = SPA.version,
		slashCommand = "/spa",	
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local indent = "     "

	local optionsTable = {
		-- UI settings
		{
			type = "header",
			name = GetString(SPA_SETTINGS_UI),
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_UI_HIDE_IN_COMBAT),
			tooltip = GetString(SPA_SETTINGS_UI_HIDE_IN_COMBAT_TOOLTIP),
			getFunc = function() return SPA.savedVariables.uiHideInCombat end,
			setFunc = function(value) SPA.savedVariables.uiHideInCombat = value; SPA.wasUiHiddenByCombat = false end,
			width = "full"
		},
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_UI_HIDE_WHEN_EMPTY),
			tooltip = GetString(SPA_SETTINGS_UI_HIDE_WHEN_EMPTY_TOOLTIP),
			getFunc = function() return SPA.savedVariables.uiHideEmpty end,
			setFunc = function(value) SPA.savedVariables.uiHideEmpty = value end,
			width = "full"
		},	
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_UI_SHOW_NEW),
			tooltip = GetString(SPA_SETTINGS_UI_SHOW_NEW_TOOLTIP),
			getFunc = function() return SPA.savedVariables.uiShowOnNewTarget end,
			setFunc = function(value) SPA.savedVariables.uiShowOnNewTarget = value end,
			width = "full"
		},	
		{
			type = "checkbox",
			name = indent .. GetString(SPA_SETTINGS_UI_SHOW_ONLY_FIRST),
			tooltip = GetString(SPA_SETTINGS_UI_SHOW_ONLY_FIRST_TOOLTIP),
			getFunc = function() return SPA.savedVariables.uiShowFirstTargetOnly end,
			setFunc = function(value) SPA.savedVariables.uiShowFirstTargetOnly = value end,
			disabled = function() return not SPA.savedVariables.uiShowOnNewTarget end,
			width = "full"
		},	

		-- Sound settings
		{
			type = "header",
			name = GetString(SPA_SETTINGS_SOUNDS),
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_SOUNDS),
			tooltip = GetString(SPA_SETTINGS_SOUNDS_TOOLTIP),
			getFunc = function() return SPA.savedVariables.notificationSounds end,
			setFunc = function(value) SPA.savedVariables.notificationSounds = value end,
			width = "full"
		},	
		{
			type = "checkbox",
			name = indent .. GetString(SPA_SETTINGS_SOUND_ONLY_FIRST),
			tooltip = GetString(SPA_SETTINGS_SOUND_ONLY_FIRST_TOOLTIP),
			getFunc = function() return SPA.savedVariables.notificationFirstOnly end,
			setFunc = function(value) SPA.savedVariables.notificationFirstOnly = value end,
			disabled = function() return not SPA.savedVariables.notificationSounds end,
			width = "full"
		},	
		{
			type = "checkbox",
			name = indent .. GetString(SPA_SETTINGS_SOUND_UI_HIDDEN),
			tooltip = GetString(SPA_SETTINGS_SOUND_UI_HIDDEN_TOOLTIP),
			getFunc = function() return SPA.savedVariables.notificationWhenUiIsHidden end,
			setFunc = function(value) SPA.savedVariables.notificationWhenUiIsHidden = value end,
			disabled = function() return not SPA.savedVariables.notificationSounds end,
			width = "full"
		},			

		-- Teleport
		{
			type = "header",
			name = GetString(SPA_SETTINGS_TELEPORT),
			width = "full",
		},
		-- {
		-- 	type = "checkbox",
		-- 	name = GetString(SPA_SETTINGS_PRIORITY_FRIEND),
		-- 	tooltip = GetString(SPA_SETTINGS_PRIORITY_FRIEND_TOOLTIP),
		-- 	getFunc = function() return SPA.savedVariables.friendPriority end,
		-- 	setFunc = function(value) SPA.savedVariables.friendPriority = value end,
		-- 	width = "full"
		-- },
		{
			type = "dropdown",
			name = GetString(SPA_SETTINGS_PRIORITY_DROPDOWN),
			tooltip = GetString(SPA_SETTINGS_PRIORITY_DROPDOWN_TOOLTIP),
			choices = {
				GetString(SPA_SETTINGS_PRIORITY_DROPDOWN_GROUP),
				GetString(SPA_SETTINGS_PRIORITY_DROPDOWN_FRIENDS),
				GetString(SPA_SETTINGS_PRIORITY_DROPDOWN_GUILDIES),
				GetString(SPA_SETTINGS_PRIORITY_DROPDOWN_NONE),
			},
			getFunc = function() return SPA.GetTeleportPriorityString() end,
			setFunc = function(var) SPA.SetTeleportPriority(var) end,
			width = "full",	--or "full" (optional)
		},


		-- Progress Information window
		{
			type = "header",
			name = GetString(SPA_SETTINGS_CONTENT),
			width = "full",
		},
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_INFO_COUNT_LOCKED),
			tooltip = GetString(SPA_SETTINGS_INFO_COUNT_LOCKED_TOOLTIP),
			getFunc = function() return SPA.savedVariables.infoStatsIncludeLocked end,
			setFunc = function(value) 
				SPA.savedVariables.infoStatsIncludeLocked = value
				SPA.UpdateInfoWindow()
			end,
			width = "full"
		},		
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_INFO_SHOW_LOCKED),
			tooltip = GetString(SPA_SETTINGS_INFO_SHOW_LOCKED_TOOLTIP),
			getFunc = function() return SPA.savedVariables.infoListsIncludeLocked end,
			setFunc = function(value)
				SPA.savedVariables.infoListsIncludeLocked = value
				SPA.UpdateInfoWindow()
			end,
			width = "full"
		},	
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_INFO_PAN_AND_ZOOM),
			tooltip = GetString(SPA_SETTINGS_INFO_PAN_AND_ZOOM_TOOLTOP),
			getFunc = function() return SPA.savedVariables.mapZoomToTarget end,
			setFunc = function(value)
				SPA.savedVariables.mapZoomToTarget = value
			end,
			width = "full"
		},	
		{
			type = "checkbox",
			name = GetString(SPA_SETTINGS_INFO_WAYPOINT),
			tooltip = GetString(SPA_SETTINGS_INFO_WAYPOINT_TOOLTOP),
			getFunc = function() return SPA.savedVariables.mapCreateWaypoint end,
			setFunc = function(value)
				SPA.savedVariables.mapCreateWaypoint = value
			end,
			width = "full"
		},

	}

	LAM:RegisterAddonPanel(SPA.name .. "_Settings", panelData)
	LAM:RegisterOptionControls(SPA.name .. "_Settings", optionsTable)
end





SkillPointAlerts.SettingsMenu = SettingsMenu
