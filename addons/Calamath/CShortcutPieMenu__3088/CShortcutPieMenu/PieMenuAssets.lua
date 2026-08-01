--
-- Calamath's Shortcut Pie Menu [CSPM]
--
-- Copyright (c) 2021 Calamath
--
-- This software is released under the Artistic License 2.0
-- https://opensource.org/licenses/Artistic-2.0
--

if not CShortcutPieMenu then return end
local CSPM = CShortcutPieMenu:SetSharedEnvironment()
-- ---------------------------------------------------------------------------------------
local L = GetString

local pieMenuAssets = {
	["!CSPM_mainmenu"] = {
		id = "!CSPM_mainmenu", 
		name = L(SI_CSPM_COMMON_MAIN_MENU), 
		menuItemsCount = 13, 
		tooltip = table.concat({ L(SI_CSPM_PIE_MAIN_MENU_TIPS1), "\n\n", L(SI_CSPM_PIE_MAIN_MENU_TIPS2), }), 
		icon = "EsoUI/Art/Menubar/menubar_mainmenu_down.dds", 
		visual = {
			showIconFrame = true, 
			showSlotLabel = true, 
			showPresetName = true, 
			style = "gamepad", 
			size = 500, 
		}, 
		slot = {
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_notifications", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_mail", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_alliance_war", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_guilds", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_friends", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_group", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_map", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_collections", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_journal", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_champion", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_skill", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_character", 
			}, 
			{
				type = "shortcut", 
				value = "!CSPM_mainmenu_inventory", 
			}, 
		}, 
		hidden = false, 
	}, 
}
local pieMenuDataManager = GetPieMenuDataManager()
for presetId, pieMenuData in pairs(pieMenuAssets) do
	pieMenuDataManager:RegisterPieMenu(presetId, pieMenuData)
end

