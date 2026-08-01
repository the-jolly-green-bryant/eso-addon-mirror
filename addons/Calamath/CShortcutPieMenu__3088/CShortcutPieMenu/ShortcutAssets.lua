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

local shortcutAssets = {
	["!CSPM_invalid_slot"] = {
		name = L(SI_QUICKSLOTS_EMPTY), 
		icon = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds", 
		callback = function() return end, 
		category = CATEGORY_NOTHING, 
		showSlotLabel = false, 
	}, 
	["!CSPM_invalid_slot_thus_open_piemenu_editor"] = {
		name = L(SI_QUICKSLOTS_EMPTY), 
		icon = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds", 
		callback = function(data)
			local activePresetId = CShortcutPieMenu:GetActivePresetId()
			if IsUserPieMenu(activePresetId) then
				CShortcutPieMenu:OpenPieMenuEditorPanel(activePresetId, data.index)
			end
			return
		end, 
		category = CATEGORY_NOTHING, 
		showSlotLabel = false, 
		activeStatusIcon = function()
			local selectionButton = IsInGamepadPreferredMode() and UI_Icon.GAMEPAD_1 or UI_Icon.MOUSE_LMB
			return { selectionButton, selectionButton, }
		end, 
	}, 
	["!CSPM_cancel_slot"] = {
		name = L(SI_RADIAL_MENU_CANCEL_BUTTON), 
		icon = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds", 
		callback = function() return end, 
		category = CATEGORY_NOTHING, 
		showSlotLabel = false, 
	}, 
	["!CSPM_open_piemenu_editor"] = {
		name = zo_strformat(L("SI_CSPM_COMMON_UI_ACTION", UI_OPEN), "PieMenu Editor"), 
		tooltip = L(SI_CSPM_UI_PANEL_HEADER2_TEXT), 
		icon = "EsoUI/Art/Icons/crafting_dwemer_shiny_gear.dds", 
		callback = function() CShortcutPieMenu:OpenPieMenuEditorPanel() end, 
		category = CATEGORY_S_PIE_MENU_ADDON, 
	}, 
	["!CSPM_open_piemenu_manager"] = {
		name = zo_strformat(L("SI_CSPM_COMMON_UI_ACTION", UI_OPEN), "PieMenu Manager"), 
		tooltip = L(SI_CSPM_UI_PANEL_HEADER3_TEXT), 
		icon = "EsoUI/Art/Icons/crafting_dwemer_shiny_gear.dds", 
		callback = function() CShortcutPieMenu:OpenPieMenuManagerPanel() end, 
		category = CATEGORY_S_PIE_MENU_ADDON, 
	}, 
	["!CSPM_reloadui"] = {
		name = L(SI_ADDON_MANAGER_RELOAD), 
		tooltip = L(SI_CSPM_SHORTCUT_RELOADUI_TIPS), 
		icon = "Esoui/Art/Login/link_loginlogo_eso.dds", 
		callback = function()
			local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
			messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
			messageParams:SetText(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", ACTION_TYPE_SHORTCUT), L(SI_ADDON_MANAGER_RELOAD)))
			CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
			zo_callLater(function() ReloadUI("ingame") end, 1)
		end, 
		category = CATEGORY_S_SYSTEM_MENU, 
	}, 
	["!CSPM_logout"] = {
		name = L(SI_DIALOG_TITLE_LOGOUT), 
		tooltip = L(SI_CSPM_SHORTCUT_LOGOUT_TIPS), 
		icon = "Esoui/Art/Menubar/Gamepad/gp_playermenu_icon_logout.dds", 
		callback = function()
			local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.NONE)
			messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
			messageParams:SetText(zo_strformat(L("SI_CSPM_SLOT_ACTION_TOOLTIP", ACTION_TYPE_SHORTCUT), L(SI_DIALOG_TITLE_LOGOUT)))
			CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
			Logout()
		end, 
		category = CATEGORY_S_SYSTEM_MENU, 
	}, 
	["!CSPM_mainmenu_inventory"] = {
		name = L(SI_MAIN_MENU_INVENTORY), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_INVENTORY)), 
		icon = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_inventory_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_INVENTORY) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_character"] = {
		name = L(SI_MAIN_MENU_CHARACTER), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_CHARACTER)), 
		icon = "EsoUI/Art/MainMenu/menuBar_character_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_character_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_CHARACTER) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_skill"] = {
		name = L(SI_MAIN_MENU_SKILLS), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_SKILLS)), 
		icon = "EsoUI/Art/MainMenu/menuBar_skills_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_skills_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_SKILLS) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_champion"] = {
		name = L(SI_MAIN_MENU_CHAMPION), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_CHAMPION)), 
		icon = "EsoUI/Art/MainMenu/menuBar_champion_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_champion_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_CHAMPION) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_journal"] = {
		name = L(SI_MAIN_MENU_JOURNAL), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_JOURNAL)), 
		icon = "EsoUI/Art/MainMenu/menuBar_journal_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_journal_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_JOURNAL) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_collections"] = {
		name = L(SI_MAIN_MENU_COLLECTIONS), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_COLLECTIONS)), 
		icon = "EsoUI/Art/MainMenu/menuBar_collections_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_collections_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_COLLECTIONS) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_map"] = {
		name = L(SI_MAIN_MENU_MAP), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_MAP)), 
		icon = "EsoUI/Art/MainMenu/menuBar_map_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_map_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_MAP) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_group"] = {
		name = L(SI_MAIN_MENU_GROUP), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_GROUP)), 
		icon = "EsoUI/Art/MainMenu/menuBar_group_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_group_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_GROUP) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_friends"] = {
		name = L(SI_MAIN_MENU_CONTACTS), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_CONTACTS)), 
		icon = "EsoUI/Art/MainMenu/menuBar_social_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_social_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_CONTACTS) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_guilds"] = {
		name = L(SI_MAIN_MENU_GUILDS), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_GUILDS)), 
		icon = "EsoUI/Art/MainMenu/menuBar_guilds_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_guilds_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_GUILDS) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_alliance_war"] = {
		name = L(SI_MAIN_MENU_ALLIANCE_WAR), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_ALLIANCE_WAR)), 
		icon = "EsoUI/Art/MainMenu/menuBar_ava_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_ava_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_ALLIANCE_WAR) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_mail"] = {
		name = L(SI_MAIN_MENU_MAIL), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_MAIL)), 
		icon = "EsoUI/Art/MainMenu/menuBar_mail_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_mail_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_MAIL) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_notifications"] = {
		name = L(SI_MAIN_MENU_NOTIFICATIONS), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_NOTIFICATIONS)), 
		icon = "EsoUI/Art/MainMenu/menuBar_notifications_up.dds", 
		activeIcon = "EsoUI/Art/MainMenu/menuBar_notifications_down.dds", 
		callback = function() SYSTEMS:GetObject("mainMenu"):ToggleCategory(MENU_CATEGORY_NOTIFICATIONS) end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
	["!CSPM_mainmenu_help"] = {
		name = L(SI_MAIN_MENU_HELP), 
		tooltip = zo_strformat(L(SI_CSPM_SHORTCUT_MAIN_MENU_ITEMS_TIPS), L(SI_MAIN_MENU_HELP)), 
		icon = "EsoUI/Art/MenuBar/menuBar_help_up.dds", 
		activeIcon = "EsoUI/Art/MenuBar/menuBar_help_down.dds", 
		callback = function() HELP_MANAGER:ToggleHelp() end, 
		category = CATEGORY_S_MAIN_MENU, 
	}, 
}
local shortcutDataManager = GetShortcutDataManager()
for shortcutId, shortcutData in pairs(shortcutAssets) do
	shortcutDataManager:RegisterShortcutData(shortcutId, shortcutData)
end

