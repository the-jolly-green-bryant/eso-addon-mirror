-- Copyright 2021 (C) @Ellimist_Entreri All Rights Reserved

-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and\or other countries. All rights reserved.
-- You can read the full terms at:
-- https:\\account.elderscrollsonline.com\add-on-terms

-- Initial Setup
InCombatMenuBlock = {
	name = "InCombatMenuBlock",
	version = "0.2.4"
}

InCombatMenuBlock.name = "InCombatMenuBlock"
--ICMBSavedVars
local ICMB_SAVE = {
	["blockacti"] = false,
	["blockalli"] = false,
	["blockchamp"] = false,
	["blockchar"] = false,
	["blockcoll"] = false,
	["blockcont"] = false,
	["blockcrown"] = false,
	["blockmarket"] = false,
	["blockcursor"] = false,
	["blockenterchat"] = false,
	["blockgift"] = false,
	["blockgroup"] = false,
	["blockguild"] = false,
	["blockhelp"] = false,
	["blockinv"] = false,
	["blockjourn"] = false,
	["blocklast"] = false,
	["blockmail"] = false,
	["blockmain"] = false,
	["blockmap"] = false,
	["blocknoti"] = false,
	["blockpov"] = false,
	["blocksheathe"] = false,
	["blockskill"] = false,

	["useawsave"] = true,
	["icmbactive"] = true,
	["allowwhendead"] = true
}
-- Function Definitions
function InCombatMenuBlock:Initialize()
	self.inCombat = IsUnitInCombat("player")
	self.isDead = IsUnitDead("player")
	self.openCategory = 0
	self.didBlockLast = false

	self.config = ZO_SavedVars:NewCharacterIdSettings("InCombatMenuBlockSavedVars", 1, nil, ICMB_SAVE, GetWorldName())
	if self.config.useawsave == true then
		self.config = ZO_SavedVars:NewAccountWide("InCombatMenuBlockSavedVars", 1, nil, ICMB_SAVE, GetWorldName())
		self.config.useawsave = true
	end

	ZO_CreateStringId("SI_BINDING_NAME_ICMB_TOGGLE", "Toggle ICMB")
	
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_DEAD, self.OnPlayerDead)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ALIVE, self.OnPlayerAlive)

	self.CreateMenu()
end

function InCombatMenuBlock.OnAddOnLoaded(event, addonName)
	if addonName == InCombatMenuBlock.name then
		EVENT_MANAGER:UnregisterForEvent(InCombatMenuBlock.name, EVENT_ADD_ON_LOADED)
		InCombatMenuBlock:Initialize()
	end
end

function InCombatMenuBlock.OnPlayerCombatState(event, inCombat)
	if inCombat ~= InCombatMenuBlock.inCombat then
		InCombatMenuBlock.inCombat = inCombat
		InCombatMenuBlock:CheckMenus()
	end
end

function InCombatMenuBlock.OnPlayerDead(event)
	InCombatMenuBlock.isDead = true
end

function InCombatMenuBlock.OnPlayerAlive(event)
	InCombatMenuBlock.isDead = false
end

function InCombatMenuBlock.UpdateCurrentCategory(category)
	InCombatMenuBlock.openCategory = category
end

function InCombatMenuBlock.CheckMenus()
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if InCombatMenuBlock.openCategory == 17 then
				if InCombatMenuBlock.config.blockacti == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 13 then
				if InCombatMenuBlock.config.blockalli == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 6 then
				if InCombatMenuBlock.config.blockchamp == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 4 then
				if InCombatMenuBlock.config.blockchar == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 8 then
				if InCombatMenuBlock.config.blockcoll == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 11 then
				if InCombatMenuBlock.config.blockcont == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 2 then
				if InCombatMenuBlock.config.blockcrown == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 1 then
				if InCombatMenuBlock.config.blockmarket == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 18 then
				if InCombatMenuBlock.config.blockgift == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 10 then
				if InCombatMenuBlock.config.blockgroup == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 12 then
				if InCombatMenuBlock.config.blockguild == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 16 then
				if InCombatMenuBlock.config.blockhelp == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 3 then
				if InCombatMenuBlock.config.blockinv == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 7 then
				if InCombatMenuBlock.config.blockjourn == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 14 then
				if InCombatMenuBlock.config.blockmail == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 9 then
				if InCombatMenuBlock.config.blockmap == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 15 then
				if InCombatMenuBlock.config.blocknoti == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == 5 then
				if InCombatMenuBlock.config.blockskill == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == "Cursor" then
				if InCombatMenuBlock.config.blockcursor == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			elseif InCombatMenuBlock.openCategory == "Main" then
				if InCombatMenuBlock.config.blockmain == true then
					SCENE_MANAGER:ShowBaseScene()
				else
				end
			end
		else
		end
	else
	end
end

function InCombatMenuBlock.AllBlocksOn()
	InCombatMenuBlock.config.blockacti = true
	InCombatMenuBlock.config.blockalli = true
	InCombatMenuBlock.config.blockchamp = true
	InCombatMenuBlock.config.blockchar = true
	InCombatMenuBlock.config.blockcoll = true
	InCombatMenuBlock.config.blockcont = true
	InCombatMenuBlock.config.blockcrown = true
	InCombatMenuBlock.config.blockmarket = true
	InCombatMenuBlock.config.blockcursor = true
	InCombatMenuBlock.config.blockenterchat = true
	InCombatMenuBlock.config.blockgift = true
	InCombatMenuBlock.config.blockgroup = true
	InCombatMenuBlock.config.blockguild = true
	InCombatMenuBlock.config.blockhelp = true
	InCombatMenuBlock.config.blockinv = true
	InCombatMenuBlock.config.blockjourn = true
	InCombatMenuBlock.config.blocklast = true
	InCombatMenuBlock.config.blocklast = true
	InCombatMenuBlock.config.blockmail = true
	InCombatMenuBlock.config.blockmain = true
	InCombatMenuBlock.config.blockmap = true
	InCombatMenuBlock.config.blocknoti = true
	InCombatMenuBlock.config.blockpov = true
	InCombatMenuBlock.config.blocksheathe = true
	InCombatMenuBlock.config.blockskill = true
	SCENE_MANAGER:ShowBaseScene()
end

function InCombatMenuBlock.AllBlocksOff()
	InCombatMenuBlock.config.blockacti = false
	InCombatMenuBlock.config.blockalli = false
	InCombatMenuBlock.config.blockchamp = false
	InCombatMenuBlock.config.blockchar = false
	InCombatMenuBlock.config.blockcoll = false
	InCombatMenuBlock.config.blockcont = false
	InCombatMenuBlock.config.blockcrown = false
	InCombatMenuBlock.config.blockmarket = false
	InCombatMenuBlock.config.blockcursor = false
	InCombatMenuBlock.config.blockenterchat = false
	InCombatMenuBlock.config.blockgift = false
	InCombatMenuBlock.config.blockgroup = false
	InCombatMenuBlock.config.blockguild = false
	InCombatMenuBlock.config.blockhelp = false
	InCombatMenuBlock.config.blockinv = false
	InCombatMenuBlock.config.blocklast = false
	InCombatMenuBlock.config.blockjourn = false
	InCombatMenuBlock.config.blocklast = false
	InCombatMenuBlock.config.blockmail = false
	InCombatMenuBlock.config.blockmain = false
	InCombatMenuBlock.config.blockmap = false
	InCombatMenuBlock.config.blocknoti = false
	InCombatMenuBlock.config.blockpov = false
	InCombatMenuBlock.config.blocksheathe = false
	InCombatMenuBlock.config.blockskill = false
	SCENE_MANAGER:ShowBaseScene()
end

function InCombatMenuBlock.TurnOffUIMode()
	if InCombatMenuBlock.didBlockLast == true then
		SCENE_MANAGER:SetInUIMode(false)
	else
	end
end
-- Slash Command
-- Add-On Override
function InCombatMenuBlock.ForceToggle()
	InCombatMenuBlock.config.icmbactive = not InCombatMenuBlock.config.icmbactive
	SCENE_MANAGER:ShowBaseScene()
	if InCombatMenuBlock.config.icmbactive == true then
		d("In Combat Menu Block Activated")
	else
		d("In Combat Menu Block Deactivated")
	end
end

SLASH_COMMANDS["/icmbft"] = InCombatMenuBlock.ForceToggle
-- PreHooks (Add-on Functionality)
-- Keyboard PreHooks
ZO_PreHook(MAIN_MENU_KEYBOARD, "ToggleCategory", function(o, category)
	InCombatMenuBlock.UpdateCurrentCategory(category)
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if category == MENU_CATEGORY_ACTIVITY_FINDER then
				if InCombatMenuBlock.config.blockacti == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_ALLIANCE_WAR then
				if InCombatMenuBlock.config.blockalli == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_CHAMPION then
				if InCombatMenuBlock.config.blockchamp == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_CHARACTER then
				if InCombatMenuBlock.config.blockchar == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_COLLECTIONS then
				if InCombatMenuBlock.config.blockcoll == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_CONTACTS then
				if InCombatMenuBlock.config.blockcont == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_CROWN_CRATES then
				if InCombatMenuBlock.config.blockcrown == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_MARKET then
				if InCombatMenuBlock.config.blockmarket == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_GIFT_INVENTORY then
				if InCombatMenuBlock.config.blockgift == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_GUILDS then
				if InCombatMenuBlock.config.blockguild == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_HELP then
				if InCombatMenuBlock.config.blockhelp == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_INVENTORY then
				if InCombatMenuBlock.config.blockinv == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_JOURNAL then
				if InCombatMenuBlock.config.blockjourn == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_MAIL then
				if InCombatMenuBlock.config.blockmail == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_MAP then
				if InCombatMenuBlock.config.blockmap == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_NOTIFICATIONS then
				if InCombatMenuBlock.config.blocknoti == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			elseif category == MENU_CATEGORY_SKILLS then
				if InCombatMenuBlock.config.blockskill == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			else
			end
		else
		end
	else
	end
end)
--Last Menu Prehook
ZO_PreHook(MAIN_MENU_KEYBOARD, "ShowLastCategory", function()
	if InCombatMenuBlock.config.icmbactive == true then
		InCombatMenuBlock.didBlockLast = false
		if InCombatMenuBlock.inCombat == true then
			if 	InCombatMenuBlock.config.blocklast == true then
				if InCombatMenuBlock.isDead == true then
					if InCombatMenuBlock.config.allowwhendead == false then
						InCombatMenuBlock.didBlockLast = true
						InCombatMenuBlock:TurnOffUIMode()
						return true
					else
					end
				else
					InCombatMenuBlock.didBlockLast = true
					InCombatMenuBlock:TurnOffUIMode()
					return true
				end
			else
			end
		else
		end
	else
	end
end)
--Enter Chat Prehook
ZO_PreHook("StartChatInput", function(text, channel, target)
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if InCombatMenuBlock.config.blockenterchat == true then
				if InCombatMenuBlock.isDead == false then
					return true
				else
				end
			else
			end
		else
		end
	else
	end
end)
-- end Keyboard PreHooks
-- GamePad PreHooks
-- PreHook: Map
ZO_PreHook(MAIN_MENU_GAMEPAD, "ToggleCategory", function(o, category)
	InCombatMenuBlock.UpdateCurrentCategory(category)
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if 	InCombatMenuBlock.config.blockmap == true then
				if category == MENU_CATEGORY_MAP then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				end
			else
			end
		else
		end
	else
	end
end)
-- end GamePad PreHooks
-- Generic PreHooks
-- PreHook: Cursor Mode
ZO_PreHook(SCENE_MANAGER, "OnToggleHUDUIBinding", function()
	InCombatMenuBlock.UpdateCurrentCategory("Cursor")
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if 	InCombatMenuBlock.config.blockcursor == true then
				if InCombatMenuBlock.isDead == true then
					if InCombatMenuBlock.config.allowwhendead == false then
						return true
					else
					end
				else
					return true
				end
			else
			end
		else
		end
	else
	end
end)
-- PreHook: Main Menu
ZO_PreHook("ZO_SceneManager_ToggleGameMenuBinding", function()
	if IsGameCameraUIModeActive() == false then
		InCombatMenuBlock.UpdateCurrentCategory("Main")
		if InCombatMenuBlock.config.icmbactive == true then
			if InCombatMenuBlock.inCombat == true then
				if 	InCombatMenuBlock.config.blockmain == true then
					if InCombatMenuBlock.isDead == true then
						if InCombatMenuBlock.config.allowwhendead == false then
							return true
						else
						end
					else
						return true
					end
				else
				end
			else
			end
		else
		end
	else
		SCENE_MANAGER:ShowBaseScene()
	end
end)
-- PreHook: Point of View
ZO_PreHook("ToggleGameCameraFirstPerson", function()
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if 	InCombatMenuBlock.config.blockpov == true then
				if InCombatMenuBlock.isDead == true then
					if InCombatMenuBlock.config.allowwhendead == false then
						return true
					else
					end
				else
					return true
				end
			else
			end
		else
		end
	else
	end
end)
-- PreHook: Sheathe Weapon
ZO_PreHook("TogglePlayerWield", function()
	if InCombatMenuBlock.config.icmbactive == true then
		if InCombatMenuBlock.inCombat == true then
			if InCombatMenuBlock.config.blocksheathe == true then
				if InCombatMenuBlock.isDead == false then
					return true
				else
				end
			else
			end
		else
		end
	else
	end
end)
-- end Generic PreHooks
-- LAM Code
function InCombatMenuBlock.CreateMenu()
	local menu = LibAddonMenu2
	-- addon menu panel information
	local panel = {
		type = "panel",
		name = "In Combat Menu Block",
		displayName = "|cFF9900In Combat Menu Block|r ",
		author = "|c33cc33@Ellimist_Entreri|r",
		version = ""..InCombatMenuBlock.version,
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
			tooltip = "Option to use Account-Wide Settings for In Combat Menu Block!",
			getFunc = function() return InCombatMenuBlock.config.useawsave end,
			setFunc = function(value)
				if InCombatMenuBlock.config.useawsave == value then
					return
				end

				if value == true then
					InCombatMenuBlock.config.useawsave = true
					InCombatMenuBlock.config = ZO_SavedVars:NewAccountWide(
						"InCombatMenuBlockSavedVars", 1, nil, InCombatMenuBlock.config, GetWorldName()
					)
					InCombatMenuBlock.config.useawsave = true
				else
					InCombatMenuBlock.config.useawsave = false
					InCombatMenuBlock.config = ZO_SavedVars:NewCharacterIdSettings(
						"InCombatMenuBlockSavedVars", 1, nil, InCombatMenuBlock.config, GetWorldName()
					)
					InCombatMenuBlock.config.useawsave = false
				end
				InCombatMenuBlock.config.useawsave = value
			end,
			default = true,
			reference = "InCombatMenuBlockUSEAWSAVE",
		},
		{
			type = "checkbox",
			name = "Add-On Activated",
			tooltip = "When set to off the add-on is effectively disabled, allowing normal menu usage.",
			getFunc = function() return InCombatMenuBlock.config.icmbactive end,
			setFunc = function(value)
				InCombatMenuBlock.config.icmbactive = value,
				SCENE_MANAGER:ShowBaseScene()
			end,
			default = true,
			warning = "Will close settings menu to prevent potential lock during combat",
			reference = "InCombatMenuBlockICMBActive",
		},
		{
			type = "checkbox",
			name = "Allow Use When Dead",
			tooltip = "Override all blocked menus and allow normal use while dead?",
			getFunc = function() return InCombatMenuBlock.config.allowwhendead end,
			setFunc = function(value)
				InCombatMenuBlock.config.allowwhendead = value
			end,
			default = true,
			reference = "InCombatMenuBlockallowwhendead",
		},
		{ 
			type = "submenu",
				name = "Menus/Keys to Block In Combat",
				controls = {
		{
			type = "button",
			name = "All On",
			tooltip = "Toggle all available blocks to On",
			func = function()
				InCombatMenuBlock.AllBlocksOn()
			end,
			width = "half",
			warning = "Will close settings menu to refresh displayed values",
		},
		{
			type = "button",
			name = "All Off",
			tooltip = "Toggle all available blocks to Off",
			func = function()
				InCombatMenuBlock.AllBlocksOff()
			end,
			width = "half",
			warning = "Will close settings menu to refresh displayed values",
		},
		{
			type = "checkbox",
			name = "Activity Finder",
			tooltip = "Prevent opening the Activity Finder during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockacti end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockacti = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockACTI",
		},
		{
			type = "checkbox",
			name = "Alliance War",
			tooltip = "Prevent opening the Alliance War menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockalli end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockalli = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockALLI",
		},
		{
			type = "checkbox",
			name = "Champion Points",
			tooltip = "Prevent opening the Champion Point Screen during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockchamp end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockchamp = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockCHAMP",
		},
		{
			type = "checkbox",
			name = "Character Sheet",
			tooltip = "Prevent opening the Character Sheet during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockchar end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockchar = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockCHAR",
		},
		{
			type = "checkbox",
			name = "Collections",
			tooltip = "Prevent opening the Collections Screen during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockcoll end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockcoll = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockCOLL",
		},
		{
			type = "checkbox",
			name = "Contacts",
			tooltip = "Prevent opening the Contacts Screen during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockcont end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockcont = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockCONT",
		},
		{
			type = "checkbox",
			name = "Crown Crates",
			tooltip = "Prevent opening the Crown Crates Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockcrown end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockcrown = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockCROWN",
		},
		{
			type = "checkbox",
			name = "Crown Market",
			tooltip = "Prevent opening the Crown Market Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockmarket end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockmarket = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockMARKET",
		},
		{
			type = "checkbox",
			name = "Cursor Mode",
			tooltip = "Prevent toggling Cursor Mode during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockcursor end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockcursor = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockCURSORM",
		},
		{
			type = "checkbox",
			name = "Enter Chat",
			tooltip = "Prevent entering chat while alive during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockenterchat end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockenterchat = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockENTERCHAT",
		},
		{
			type = "checkbox",
			name = "Gift Inventory",
			tooltip = "Prevent opening the Gift Inventory during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockgift end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockgift = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockGIFT",
		},
		{
			type = "checkbox",
			name = "Group",
			tooltip = "Prevent opening the Group Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockgroup end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockgroup = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockGROUP",
		},
		{
			type = "checkbox",
			name = "Guild",
			tooltip = "Prevent opening the Guild Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockguild end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockguild = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockGUILD",
		},
		{
			type = "checkbox",
			name = "Help",
			tooltip = "Prevent opening the Help Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockhelp end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockhelp = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockHELP",
		},
		{
			type = "checkbox",
			name = "Inventory",
			tooltip = "Prevent opening the Inventory Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockinv end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockinv = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockINV",
		},
		{
			type = "checkbox",
			name = "Journal",
			tooltip = "Prevent opening the Journal Screen during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockjourn end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockjourn = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockJOURN",
		},
		{
			type = "checkbox",
			name = "Last",
			tooltip = "Prevent opening the Last Open Menu (ALT Key) during combat?",
			getFunc = function() return InCombatMenuBlock.config.blocklast end,
			setFunc = function(value)
				InCombatMenuBlock.config.blocklast = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockLAST",
		},
		{
			type = "checkbox",
			name = "Mail",
			tooltip = "Prevent opening the Mail Screen during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockmail end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockmail = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockMAIL",
		},
		{
			type = "checkbox",
			name = "Main Menu",
			tooltip = "Prevent opening the Main Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockmain end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockmain = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockMAIN",
		},
		{
			type = "checkbox",
			name = "Map",
			tooltip = "Prevent opening the Map during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockmap end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockmap = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockMAP",
		},
		{
			type = "checkbox",
			name = "Notifications",
			tooltip = "Prevent opening the Notifications Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blocknoti end,
			setFunc = function(value)
				InCombatMenuBlock.config.blocknoti = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockNOTI",
		},
		{
			type = "checkbox",
			name = "Point of View",
			tooltip = "Prevent changing the Point of View during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockpov end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockpov = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockPOV",
		},
		{
			type = "checkbox",
			name = "Sheathe Weapon",
			tooltip = "Prevent sheathing your weapon during combat?",
			getFunc = function() return InCombatMenuBlock.config.blocksheathe end,
			setFunc = function(value)
				InCombatMenuBlock.config.blocksheathe = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockSHEATHE",
		},
		{
			type = "checkbox",
			name = "Skill",
			tooltip = "Prevent opening the Skill Menu during combat?",
			getFunc = function() return InCombatMenuBlock.config.blockskill end,
			setFunc = function(value)
				InCombatMenuBlock.config.blockskill = value
			end,
			default = false,
			width = "half",
			reference = "InCombatMenuBlockSKILL",
		},
		},
	},
},

	menu:RegisterAddonPanel("InCombatMenuBlock_Options", panel)
	menu:RegisterOptionControls("InCombatMenuBlock_Options", options)

end
-- Event Registration
EVENT_MANAGER:RegisterForEvent(InCombatMenuBlock.name, EVENT_ADD_ON_LOADED, InCombatMenuBlock.OnAddOnLoaded)