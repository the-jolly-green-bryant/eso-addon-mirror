-------------------------------------------------------------------------------
-- Loot Shift
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2017-2022 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software. Additionally, licensed use of the Software
-- will be subject to the following:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--]]

local LSAddon = _G['LSAddon']
local L = LSAddon:GetLanguage()
local aOpts = {initALNormal = false, initALStolen = false, stateALNormal = 1, stateALStolen = 1}
local stringOpts = {[1] = 'Off', [2] = 'On'}

LSAddon.Version = '1.08'

local lootSetting
local reset = 0

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Main LoosShit functions.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function SetLootSetting() -- reset the loot setting to the stored actual value 'lootSetting'
	if reset ~= 2 then -- wait for lockpicking to finish so looting locked chests uses alternate loot mode when toggled
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, lootSetting)
		reset = 0
	end
end

local function OnInventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason) -- reset loot setting when looting
	if reset == 0 then return end -- only run if setting has been toggled, needed for auto-loot when no loot window is shown to fire close event
	reset = 1
	SetLootSetting()
end

local function lootClosed(oldState, newState) -- reset the loot setting when the loot window is closed
	if newState == SCENE_HIDDEN and reset ~= 0 then -- only run when closed (not on opening) and when loot setting has been toggled
		reset = 1
		SetLootSetting()
	end
end

local function OnLockpickFail(eventCode) -- reset the loot setting if lockpicking fails
	if reset == 2 then -- since lockpicking disables the 5-second loot setting reset, reset manually
		reset = 1
		SetLootSetting()
	end
end

local function OnLockpickSucceed(eventCode) -- reset the loot setting if lockpicking succeeds (needed when alt mode is auto-loot)
	if reset == 2 then -- since lockpicking disables the 5-second loot setting reset, reset manually
		reset = 1
		SetLootSetting()
	end
end

local function OnBeginLockpick(eventCode) -- prevent 5-second reset to default loot setting while picking lock
	if reset == 1 then -- only run when the loot setting has actually been changed with the keybind
		reset = 2 -- prevents the 5 second timer from running while lockpicking so the alt loot setting is used upon completion
	end
end

function LSAddon.AltLootMode() -- function to run when hitting keybind (set in bindings.xml)
	if reset == 0 then -- anti-spam prevents repeat pressing of keybind changing loot setting over and over
		lootSetting = tonumber(GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)) -- store the actual value of the loot setting
		local lootShift = (lootSetting == 1) and 0 or 1 -- get the opposite value of current loot setting
		SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, lootShift) -- switch loot setting to opposite for this loot session
		zo_callLater(SetLootSetting, 5000) -- switch back after 5 seconds (failsafe, will switch faster on different events)
		reset = 1 -- state value for controlling behavior of other functions based on status of loot shift
	end
end

function LSAddon.ToggleLootMode()
	local lootShift = (tonumber(GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)) == 1) and 0 or 1
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, lootShift)
	lootSetting = lootShift
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up the Addon Settings options panel.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow()
	local LAM = LibAddonMenu2

	local panelData = {
		type					= "panel",
		name					= 'LootShift',
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize('LootShift'),
		author					= '|c66ccffPhinix|r',
		version					= LSAddon.Version,
		registerForRefresh		= true,
		registerForDefaults		= true,
	}

	local optionsData = {
		{
			type = "header",
			name = ZO_HIGHLIGHT_TEXT:Colorize(L.AutoLootNConfig),
		},
		{
				type			= "checkbox",
				name			= L.AutoLootNDefault,
				tooltip			= L.AutoLootNDefaultTip,
				getFunc			= function() return LSAddon.ASV.initALNormal end,
				setFunc			= function(value) LSAddon.ASV.initALNormal = value end,
				width			= "full",
				default			= aOpts.initALNormal,
		},
		{
				type			= 'dropdown',
				name			= L.ReloadState,
				tooltip			= L.AutoLootNReloadTip,
				choices			= stringOpts,
				getFunc			= function() return stringOpts[LSAddon.ASV.stateALNormal + 1] end,
				setFunc			= function(selected)
									for k,v in pairs(stringOpts) do
										if v == selected then
											LSAddon.ASV.stateALNormal = k - 1
											SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, LSAddon.ASV.stateALNormal)
											break
										end
									end
								end,
				default			= 1,
				disabled		= function() return LSAddon.ASV.initALNormal == false end,
		},
		{
			type = "header",
			name = ZO_HIGHLIGHT_TEXT:Colorize(L.AutoLootSConfig),
		},
		{
				type			= "checkbox",
				name			= L.AutoLootSDefault,
				tooltip			= L.AutoLootSDefaultTip,
				getFunc			= function() return LSAddon.ASV.initALStolen end,
				setFunc			= function(value) LSAddon.ASV.initALStolen = value end,
				width			= "full",
				default			= aOpts.initALStolen,
		},
		{
				type			= 'dropdown',
				name			= L.ReloadState,
				tooltip			= L.AutoLootSReloadTip,
				choices			= stringOpts,
				getFunc			= function() return stringOpts[LSAddon.ASV.stateALStolen + 1] end,
				setFunc			= function(selected)
									for k,v in pairs(stringOpts) do
										if v == selected then
											LSAddon.ASV.stateALStolen = k - 1
											SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, LSAddon.ASV.stateALStolen)
											break
										end
									end
								end,
				default			= 1,
				disabled		= function() return LSAddon.ASV.initALStolen == false end,
		},
	}

	LAM:RegisterAddonPanel("LootShift_Panel", panelData)
	LAM:RegisterOptionControls("LootShift_Panel", optionsData)
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'LootShift' then return end
	EVENT_MANAGER:UnregisterForEvent('LootShift', EVENT_ADD_ON_LOADED)
	LSAddon.ASV = ZO_SavedVars:NewAccountWide('LootShit_Vars', 1.0, 'AccountSettings', aOpts)
	ZO_CreateStringId('SI_BINDING_NAME_ALT_LOOT_MODE', L.AltLootMode)
	ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_LOOT_MODE', L.ToggleLootMode)
	local lootScene = SCENE_MANAGER:GetScene("loot") -- get the UI scene for the loot window
	lootScene:RegisterCallback("StateChange", lootClosed) -- register a callback function to fire on loot window state change
	-- Set initial Auto Loot and Auto Loot Stolen Items game settings based on saved variable options and create Addon Settings
	if LSAddon.ASV.initALNormal  then SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, LSAddon.ASV.stateALNormal) end
	if LSAddon.ASV.initALStolen  then SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN, LSAddon.ASV.stateALStolen) end
	CreateSettingsWindow()
end

EVENT_MANAGER:RegisterForEvent('LootShift', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('LootShift', EVENT_BEGIN_LOCKPICK, OnBeginLockpick)
EVENT_MANAGER:RegisterForEvent('LootShift', EVENT_LOCKPICK_FAILED, OnLockpickFail)
EVENT_MANAGER:RegisterForEvent('LootShift', EVENT_LOCKPICK_SUCCESS, OnLockpickSucceed)
EVENT_MANAGER:RegisterForEvent('LootShift', EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
