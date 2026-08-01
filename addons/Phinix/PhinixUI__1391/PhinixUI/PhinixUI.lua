-------------------------------------------------------------------------------
-- PhinixUI
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

local PUIAddon = _G['PUIAddon']
local L = PUIAddon:GetLanguage()

-- Global functions:
local pST = PUIAddon.GetSorted
local pTC = PUIAddon.TColor

----------------------------------------------------------------------------------------------------------------------------------------
-- Database setup.
----------------------------------------------------------------------------------------------------------------------------------------
local IconStrings = {[1]='|t16:16:/PhinixUI/bin/load.dds|t ',[2]='|t16:16:/PhinixUI/bin/noload.dds|t '}
local AccountDefaults = { reCount = 0, defaultSelect = {}, tempSelect = {}, xpos = nil, ypos = nil }

local sortedValues = {}

----------------------------------------------------------------------------------------------------------------------------------------
-- PUI functions.
----------------------------------------------------------------------------------------------------------------------------------------
function LoadUI()
	local defaultSelect = PUIAddon.ASV.defaultSelect
	local tempSelect = PUIAddon.ASV.tempSelect
	local addons = {}
	sortedValues = {}

-- Detect installed supported addons and initialize
	for i = 1, #PUIAddon.AddonDB do
		if (PUIAddon.AddonDB[i].vars()) then
			addons[i] = PUIAddon.AddonDB[i].name
		end
	end

-- Sort temp addon table alphabetically
	for _, key in ipairs(pST(addons, nil, function(a, b) return a < b end)) do
		if (PUIAddon.DefaultOff[tostring(addons[key])]) then
			table.insert(sortedValues, #sortedValues + 1, {name = addons[key], val = 0, pos = key})
		else
			table.insert(sortedValues, #sortedValues + 1, {name = addons[key], val = 1, pos = key})
		end
	end

-- Handle loading the addon or user defaults
	if next(defaultSelect) ~= nil then
		for i = 1, #sortedValues do
			if defaultSelect[sortedValues[i].pos] ~= nil then
				sortedValues[i].val = defaultSelect[sortedValues[i].pos]
			else
				sortedValues[i].val = 0
			end
		end
	end

	PUIAddon.ASV.tempSelect = {}
	PUIAddon_MainFrameListFrameRunLabel:SetText(L.PUIAddon_RUN)

end

----------------------------------------------------------------------------------------------------------------------------------------
-- Initialize the scrollable list and handle various related functions.
----------------------------------------------------------------------------------------------------------------------------------------
local function SetListItem(control,data) -- Hook the ScrollList data table.
	local listitemtext = control:GetNamedChild( 'Name' )
	listitemtext:SetText( data.SelectedAddons )
end

local function InitMain()
	local control = GetControl('PUIAddon_MainFrameListFrameList')
	ZO_ScrollList_AddDataType(control, 1 , 'PUIAddon_ListItemTemplate', 20,  SetListItem)
end

local function ScrollList() -- Populate addon list
	local datalist = ZO_ScrollList_GetDataList(PUIAddon_MainFrameListFrameList)
	ZO_ScrollList_Clear(PUIAddon_MainFrameListFrameList)
	
	local select
	local text

	for i = 1, #sortedValues do
		if sortedValues[i].val == 0 then
			select = IconStrings[2]
			text = pTC("808080", sortedValues[i].name)
		else
			select = IconStrings[1]
			text = pTC("FFFFFF", sortedValues[i].name)
		end
		datalist[i] = ZO_ScrollList_CreateDataEntry( 1, 
		{
			SelectedAddons = select .. text,
		}
		)
	end
	ZO_ScrollList_Commit(PUIAddon_MainFrameListFrameList, datalist)
end

local function ListHover(control, text, option)
	if option == 1 then
		control:SetAlpha(.5)
	elseif option == 2 then
		control:SetAlpha(1)
	end
end

local function ListClick(clicktext) -- Handles clicking and shift-clicking of list items.
--	local Dependencies = PUIAddon.Dependencies

--	local function checkDep(pos,val)
--		if Dependencies[tostring(sortedValues[pos].name:gsub("%W",''))] ~= nil then
--			for c = 1, #sortedValues do
--				if string.find(sortedValues[c].name:gsub("%W",''),Dependencies[tostring(sortedValues[pos].name:gsub("%W",''))]) ~= nil then
--					if sortedValues[c].val == 1 and val == 0 then
--						sortedValues[c].val = val
--					end
--				end
--			end
--		end
--	end

	for i = 1, #sortedValues do
		if string.find(clicktext:gsub("%W",''),sortedValues[i].name:gsub("%W",'')) ~= nil then
			if sortedValues[i].val == 0 then
				sortedValues[i].val = 1
			--	checkDep(i,0)
			else
				sortedValues[i].val = 0
			--	checkDep(i,1)
			end
		end
	end
	ScrollList()
end

local function RunSelected()
	local count = 0

-- Set essential game settings to work with the UI
--https://wiki.esoui.com/Globals#SettingSystemType
--/script d(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR))

	SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0)
	SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_WEAPON_INDICATOR, 0)
	SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR, 1)
--	SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_LEADERBOARD_NOTIFICATIONS, 0)
--	SetSetting(SETTING_TYPE_TUTORIAL, TUTORIAL_ENABLED_SETTING_ID, 0)
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_LOOT_HISTORY, 0)
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, 1)
	SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AOE_LOOT, 1)
--	SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_HEALTHBAR_CHASE_BAR, 0)
--	SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_HEALTHBAR_FRAME_BORDER, 1)
--	SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FRIENDLY_NPC_HEALTHBARS, 3)
--	SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FRIENDLY_NPC_HEALTHBARS_HIGHLIGHT, 9)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_DAMAGE_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_DOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_HEALING_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_HOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_STATUS_EFFECTS_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_PET_DAMAGE_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_PET_DOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_PET_HEALING_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_OUTGOING_PET_HOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_DAMAGE_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_DOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_HEALING_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_HOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_STATUS_EFFECTS_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_PET_DAMAGE_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_PET_DOT_ENABLED, 1)
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCT_INCOMING_POINT_GAINS_ENABLED, 1)
	ApplySettings()

-- Save current addon selection in case of reload needed
	PUIAddon.ASV.tempSelect = {}
	for i = 1, #PUIAddon.AddonDB do
		for v = 1, #sortedValues do
			if sortedValues[v].pos == i then
				PUIAddon.ASV.tempSelect[i] = sortedValues[v].val
			end
		end
	end

-- Run the selected config files (with any special initializations) and gather information for reboot
	for i = 1, #sortedValues do
		local pos = sortedValues[i].pos
		if sortedValues[i].val == 1 then
			PUIAddon.AddonDB[pos].run()
			count = count + 1
		end
	end

-- Tally the addons and flag to init after reload
	PUIAddon.ASV.reCount = count

-- Initial reload to init changes
	ReloadUI()

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Main window control and tooltips.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function ClearSelection(control, option)
	if option == 1 then
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.PUIAddon_CLEAR)
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		for i = 1, #sortedValues do
			sortedValues[i].val = 0
		end
		ScrollList()
	end
end

local function AddonDefault(control, option)
	if option == 1 then
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.PUIAddon_DEFAULT)
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		for i = 1, #sortedValues do
			if (PUIAddon.DefaultOff[tostring(sortedValues[i].name)]) then
				sortedValues[i].val = 0
			else
				sortedValues[i].val = 1
			end
		end
		ScrollList()
	end
end

local function RestorePosition()
	if PUIAddon.ASV.xpos ~= nil then
		local left = PUIAddon.ASV.xpos
		local top = PUIAddon.ASV.ypos
		PUIAddon_MainFrame:ClearAnchors()
		PUIAddon_MainFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
	end
end

local function OnMoveStop()
	PUIAddon.ASV.xpos = PUIAddon_MainFrame:GetLeft()
	PUIAddon.ASV.ypos = PUIAddon_MainFrame:GetTop()
end

local function ShowMain()
	local control = GetControl('PUIAddon_MainFrame')
	if ( control:IsHidden() ) then
		SCENE_MANAGER:ToggleTopLevel(PUIAddon_MainFrame)
		RestorePosition()
	else
		SCENE_MANAGER:ToggleTopLevel(PUIAddon_MainFrame)
	end
	ScrollList()
	AddonDefault(nil, 3)
end

local function CloseMain(control, option)
	if option == 1 then
		InitializeTooltip(InformationTooltip, control, TOPLEFT, 8, -44, BOTTOMRIGHT)
		SetTooltipText(InformationTooltip, L.PUIAddon_CLOSE)
	elseif option == 2 then
		ClearTooltip(InformationTooltip)
	elseif option == 3 then
		SCENE_MANAGER:ToggleTopLevel(PUIAddon_MainFrame)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------
-- Handle function calls from XML.
----------------------------------------------------------------------------------------------------------------------------------------
function PUIAddon.XMLNavigation(option, control, text, n1)
-- List click and tooltips.
	if option == 001 then
		ListHover(control, text, n1)
	elseif option == 002 then
		ListClick(text)
-- Main Frame functions.
	elseif option == 101 then
		OnMoveStop()
	elseif option == 102 then
		InitMain()
	elseif option == 103 then
		CloseMain(control, n1)
	elseif option == 104 then
		ClearSelection(control, n1)
	elseif option == 105 then
		AddonDefault(control, n1)
	elseif option == 106 then
		RunSelected()
	elseif option == 107 then
		ShowMain()
	end
end

----------------------------------------------------------------------------------------------------------------------------------------
-- Init and result display
----------------------------------------------------------------------------------------------------------------------------------------
local function OnPlayerActivated()
	local count = PUIAddon.ASV.reCount

	if count > 0 then
		local result = L.PUIAddon_SUCCESS..tostring(count)..L.PUIAddon_ADDONS
		d(L.PUIAddon_COMPLETE)
		d(result)
		d("==============================================================")
		PUIAddon.ASV.reCount = 0
	end
end

local function OnAddonLoaded(event, addonName)
	if addonName ~= 'PhinixUI' then return end
	EVENT_MANAGER:UnregisterForEvent('PhinixUI', EVENT_ADD_ON_LOADED)
	SCENE_MANAGER:RegisterTopLevel(PUIAddon_MainFrame, false)
	PUIAddon.ASV = ZO_SavedVars:NewAccountWide('PhinixUI', 1.15, 'AccountSettings', AccountDefaults)
	ZO_CreateStringId('SI_BINDING_NAME_TOGGLE_PUI_WINDOW', 'Show PhinixUI Config')

	LoadUI()
end

SLASH_COMMANDS['/pui'] = ShowMain
EVENT_MANAGER:RegisterForEvent('PhinixUI', EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent('PhinixUI', EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
