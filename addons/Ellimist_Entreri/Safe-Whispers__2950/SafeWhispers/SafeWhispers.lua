-- Copyright 2021 (C) @Ellimist_Entreri All Rights Reserved

-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and\or other countries. All rights reserved.
-- You can read the full terms at:
-- https:\\account.elderscrollsonline.com\add-on-terms

-- Initial Setup
SafeWhispers = {
	name = "SafeWhispers",
	version = "0.0.5"
}

SafeWhispers.name = "SafeWhispers"
--SafeWhispers SavedVars--
local SW_SAVE = {
	["useawsave"] = true,
	["swactive"] = true,
	["autoonline"] = true
}
-- Function Definitions
function SafeWhispers:Initialize()
	self.config = ZO_SavedVars:NewCharacterIdSettings("SafeWhispersSavedVars", 1, nil, SW_SAVE, GetWorldName())
	if self.config.useawsave == true then
		self.config = ZO_SavedVars:NewAccountWide("SafeWhispersSavedVars", 1, nil, SW_SAVE, GetWorldName())
		self.config.useawsave = true
	end

	ZO_CreateStringId("SI_BINDING_NAME_SW_TOGGLE", "Toggle Safe Whispers")

	self.CreateMenu()
end

function SafeWhispers.OnAddOnLoaded(event, addonName)
	if addonName == SafeWhispers.name then
		EVENT_MANAGER:UnregisterForEvent(SafeWhispers.name, EVENT_ADD_ON_LOADED)
		SafeWhispers:Initialize()
	end
end

function SafeWhispers.UpdateStatus()
	local mystatus = GetPlayerStatus()
	if mystatus == 3 then
		if SafeWhispers.config.autoonline == true then
			SelectPlayerStatus(1)
			d("Safe Whispers - Player Status set to Online, replies will be received!")
		else
			d("Safe Whispers - WARNING STATUS IS DO-NOT-DISTURB, REPLIES WILL NOT BE RECEIVED!")
		end
	elseif mystatus == 4 then
		if SafeWhispers.config.autoonline == true then
			SelectPlayerStatus(1)
			d("Safe Whispers - Player Status set to Online, replies will be received!")
		else
			d("Safe Whispers - WARNING STATUS IS OFFLINE, REPLIES WILL NOT BE RECEIVED!")
		end
	end
end
-- Slash Command
-- Add-On Override
function SafeWhispers.ForceToggle()
	SafeWhispers.config.swactive = not SafeWhispers.config.swactive
	SCENE_MANAGER:ShowBaseScene()
	if SafeWhispers.config.swactive == true then
		d("Safe Whispers Activated")
	else
		d("Safe Whispers Deactivated")
	end
end

SLASH_COMMANDS["/swft"] = SafeWhispers.ForceToggle
-- PreHooks
ZO_PreHook(SharedChatSystem, "SetChannel", function(o, newChannel, channelTarget)
	if SafeWhispers.config.swactive == true then
		if channelTarget ~= nil then
			SafeWhispers:UpdateStatus()
		else
		end
	else
	end
end)
-- LAM Code
function SafeWhispers.CreateMenu()
	local menu = LibAddonMenu2
	-- addon menu panel information
	local panel = {
		type = "panel",
		name = "Safe Whispers",
		displayName = "|cFF9900Safe Whispers|r ",
		author = "|c33cc33@Ellimist_Entreri|r",
		version = ""..SafeWhispers.version,
		registerForRefresh = true,
		registerForDefaults = true,
	}
	-- addon settings (displayed in options panel)
	local options = {
		{
			type = "header",
			name = "General Options"
		},
		{
			type = "checkbox",
			name = "Use Account-Wide Settings",
			tooltip = "Option to use Account-Wide Settings for Safe Whispers!",
			getFunc = function() return SafeWhispers.config.useawsave end,
			setFunc = function(value)
				if SafeWhispers.config.useawsave == value then
					return
				end

				if value == true then
					SafeWhispers.config.useawsave = true
					SafeWhispers.config = ZO_SavedVars:NewAccountWide(
						"SafeWhispersSavedVars", 1, nil, SafeWhispers.config, GetWorldName()
					)
					SafeWhispers.config.useawsave = true
				else
					SafeWhispers.config.useawsave = false
					SafeWhispers.config = ZO_SavedVars:NewCharacterIdSettings(
						"SafeWhispersSavedVars", 1, nil, SafeWhispers.config, GetWorldName()
					)
					SafeWhispers.config.useawsave = false
				end
				SafeWhispers.config.useawsave = value
			end,
			default = true,
			reference = "SafeWhispersUSEAWSAVE",
		},
		{
			type = "checkbox",
			name = "Add-On Activated",
			tooltip = "When set to off the add-on is effectively disabled, allowing the user to send messages while offline without having their status changed or being notified.",
			getFunc = function() return SafeWhispers.config.swactive end,
			setFunc = function(value)
				SafeWhispers.config.swactive = value
			end,
			default = true,
			reference = "SafeWhispersswActive",
		},
		{
			type = "checkbox",
			name = "Auto-Online",
			tooltip = "Automatically switch to online status when you send a whisper while set to offline/do-not-disturb?",
			getFunc = function() return SafeWhispers.config.autoonline end,
			setFunc = function(value)
				SafeWhispers.config.autoonline = value
			end,
			default = true,
			reference = "SafeWhispersautoonline",
		},
	},

	menu:RegisterAddonPanel("SafeWhispers_Options", panel)
	menu:RegisterOptionControls("SafeWhispers_Options", options)

end
-- EVENT REGISTRATION
EVENT_MANAGER:RegisterForEvent(SafeWhispers.name, EVENT_ADD_ON_LOADED, SafeWhispers.OnAddOnLoaded)