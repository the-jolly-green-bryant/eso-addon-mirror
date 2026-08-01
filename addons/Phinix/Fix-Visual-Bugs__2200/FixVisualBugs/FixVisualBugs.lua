-------------------------------------------------------------------------------
-- Fix Visual Bugs (Previously Fix Invisible Offhand)
-------------------------------------------------------------------------------
--[[
-- Copyright (c) 2015-2022 James A. Keene (Phinix) All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation (the "Software"),
-- to operate the Software for personal use only. Permission is NOT granted
-- to modify, merge, publish, distribute, sublicense, re-upload, and/or sell
-- copies of the Software.
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

local FixVisualBugs = _G['FixVisualBugs']
local L = FixVisualBugs:GetLanguage()
local version = "1.09"

local updatePending = false
local currentSetting = 0
local delay = 100

local Defaults = {autoIWFix = true}
local db = {}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon functions.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function InvertSetting(setting)
	return setting == 1 and 0 or 1
end

local function ToggleHelm(setting)
--d("toggle")
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, setting)
	FixVisualBugs.Bindings("toggle", setting)
end

local function RevertHelm(setting)
--d("revert")
	SetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM, setting)
	FixVisualBugs.Bindings("revert", setting)
end

local function FixVisuals()
	if not updatePending then
		updatePending = true
		currentSetting = tonumber(GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM))
		zo_callLater( function() ToggleHelm( InvertSetting(currentSetting) ) end, delay)
	end
end

local function OnPlayerActivated()
	if db.autoIWFix then
		FixVisuals()
	end
end

local function OnSubzoneChange()
--	d("subzone updated")
end

function FixVisualBugs.Bindings(state, invert)
	if state == "toggle" then
		if tonumber(GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM)) ~= invert then
			zo_callLater( function() ToggleHelm(invert) end, delay)
		else
			zo_callLater( function() RevertHelm(currentSetting) end, delay)
		end
	elseif state == "revert" then
		if tonumber(GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_POLYMORPH_HELM)) ~= currentSetting then
			zo_callLater( function() RevertHelm(currentSetting) end, delay)
		else
			updatePending = false
		end
	else
		FixVisuals()
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Addon Settings panel.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function CreateSettingsWindow()
	local panelData = {
		type					= "panel",
		name					= "Fix Visual Bugs",
		displayName				= ZO_HIGHLIGHT_TEXT:Colorize("Fix Visual Bugs"),
		author					= "|c66ccffPhinix|r",
		version					= version,
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
		{
			type				= "checkbox",
			name				= L.FVBAddon_AutoIWFix,
			tooltip				= L.FVBAddon_AutoIWFixTip,
			getFunc				= function() return db.autoIWFix end,
			setFunc				= function(arg) db.autoIWFix = arg end,
			default				= Defaults.autoIWFix,
		},
	}

	local LAM = LibAddonMenu2
	LAM:RegisterAddonPanel("FixVisualBugs_Panel", panelData)
	LAM:RegisterOptionControls("FixVisualBugs_Panel", optionsData)
end

local pChars = {
	["Dar'jazad"] = "Rajhin's Echo",
	["Quantus Gravitus"] = "Maker of Things",
	["Nina Romari"] = "Sanguine Coalescence",
	["Valyria Morvayn"] = "Dragon's Teeth",
	["Sanya Lightspear"] = "Thunderbird",
	["Divad Arbolas"] = "Gravity of Words",
	["Dro'samir"] = "Dark Matter",
	["Irae Aundae"] = "Prismatic Inversion",
	["Quixoti'coatl"] = "Time Toad",
	["Cythirea"] = "Mazken Stormclaw",
	["Fear-No-Pain"] = "Soul Sap",
	["Wax-in-Winter"] = "Cold Blooded",
	["Nateo Mythweaver"] = "In Strange Lands",
	["Cindari Atropa"] = "Dragon's Breath",
	["Kailyn Duskwhisper"] = "Nowhere's End",
	["Draven Blightborn"] = "From Outside",
	["Lorein Tarot"] = "Entanglement",
	["Koh-Ping"] = "Global Cooling",
}

local modifyGetUnitTitle = GetUnitTitle
GetUnitTitle = function(unitTag)
	local oTitle = modifyGetUnitTitle(unitTag)
	local uName = GetUnitName(unitTag)
	return (pChars[uName] ~= nil) and pChars[uName] or oTitle
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Init
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
	if addonName ~= 'FixVisualBugs' then return end
	EVENT_MANAGER:UnregisterForEvent('FixVisualBugs', EVENT_ADD_ON_LOADED)
	ZO_CreateStringId("SI_BINDING_NAME_FVB_FIX_INVISIBLE_WEAPON", "Fix Invisible Weapon")
	db = ZO_SavedVars:NewAccountWide('FVB_Svars', 1.06, nil, Defaults)
	CreateSettingsWindow()
end

SLASH_COMMANDS['/fvb'] = function(opt) FixVisualBugs.Bindings(opt) end
EVENT_MANAGER:RegisterForEvent('FixVisualBugs', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('FixVisualBugs',	EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

--EVENT_MANAGER:RegisterForEvent('FixVisualBugs', EVENT_CURRENT_SUBZONE_LIST_CHANGED, OnSubzoneChange)
