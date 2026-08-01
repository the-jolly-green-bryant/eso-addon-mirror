QuickMenu = {}; 
QuickMenu.name = "QuickMenu";
QuickMenu.version = "1.03";
QuickMenu.settingName = "Quick Menu"
QuickMenu.settingDisplayName = "RockingDice's QuickMenu"
QuickMenu.author = "RockingDice"

QuickMenu.presets8 = { 
	slots = {
		[1] = SI_MAIN_MENU_INVENTORY,
		[2] = SI_MAIN_MENU_SKILLS,
		[3] = SI_MAIN_MENU_GROUP,
		[4] = SI_MAIN_MENU_ACTIVITY_FINDER,
		[5] = SI_MAIN_MENU_MAIL,
		[6] = SI_JOURNAL_MENU_QUESTS,
		[7] = SI_MAIN_MENU_MAP, 
	},
	slotsCount = 7
}
 
QuickMenu.presets12 = { 
	slots = {
		[1] = SI_MAIN_MENU_INVENTORY,
		[2] = SI_MAIN_MENU_SKILLS,
		[3] = SI_MAIN_MENU_GROUP,
		[4] = SI_MAIN_MENU_ACTIVITY_FINDER,
		[5] = SI_MAIN_MENU_MAIL,
		[6] = SI_JOURNAL_MENU_QUESTS,
		[7] = SI_MAIN_MENU_MAP, 
		[8] = SI_MAIN_MENU_GUILDS, 
		[9] = SI_MAIN_MENU_NOTIFICATIONS, 
		[10] = SI_MAIN_MENU_COLLECTIONS, 
		[11] = SI_JOURNAL_MENU_ACHIEVEMENTS, 
	},
	slotsCount = 11
}

QuickMenu.menuChoices = { 
	SI_JOURNAL_MENU_QUESTS,
	SI_JOURNAL_MENU_CADWELLS_ALMANAC,
	SI_JOURNAL_MENU_LORE_LIBRARY,
	SI_JOURNAL_MENU_ACHIEVEMENTS,
	SI_JOURNAL_MENU_LEADERBOARDS,
	SI_MAIN_MENU_CHARACTER,
	SI_MAIN_MENU_SKILLS,
	SI_MAIN_MENU_CHAMPION,
	SI_MAIN_MENU_MARKET,
	SI_MAIN_MENU_INVENTORY, 
	SI_MAIN_MENU_ALLIANCE_WAR,
	SI_MAIN_MENU_MAP,
	SI_WINDOW_TITLE_FRIENDS_LIST,
	SI_IGNORE_LIST_PANEL_TITLE,
	SI_MAIN_MENU_GUILDS,
	SI_MAIN_MENU_MAIL,
	SI_MAIN_MENU_NOTIFICATIONS,
	SI_MAIN_MENU_GROUP,
	SI_MAIN_MENU_COLLECTIONS,
	SI_MAIN_MENU_ACTIVITY_FINDER,
	SI_MAIN_MENU_CROWN_CRATES,
	SI_GAME_MENU_LOGOUT,
	SI_GAME_MENU_QUIT,
}
 
QuickMenu.menuChoicesShowNames = {}
for k, v in ipairs(QuickMenu.menuChoices) do
	table.insert(QuickMenu.menuChoicesShowNames, GetString(v))
end 

QuickMenu.KEYBOARD_MENU_ENTRIES =
{
    [SI_JOURNAL_MENU_QUESTS] =
    {
        scenegroup = "journalSceneGroup",
		descriptor = "questJournal",
		enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_quest_up.dds", 
		enabledSelected = "EsoUI/Art/Journal/journal_tabIcon_quest_up.dds",
    },  
	[SI_JOURNAL_MENU_CADWELLS_ALMANAC] =
    {
        scenegroup = "journalSceneGroup",
		descriptor = "cadwellsAlmanac",
		enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_cadwell_up.dds", 
		enabledSelected = "EsoUI/Art/Journal/journal_tabIcon_cadwell_up.dds",
	},
	[SI_JOURNAL_MENU_LORE_LIBRARY] =
    {
        scenegroup = "journalSceneGroup",
		descriptor = "loreLibrary",
        enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_up.dds",
        enabledSelected = "EsoUI/Art/Journal/journal_tabIcon_loreLibrary_up.dds", 
    }, 
	[SI_JOURNAL_MENU_ACHIEVEMENTS] =
    {
        scenegroup = "journalSceneGroup",
		descriptor = "achievements",
        enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_achievements_up.dds",
        enabledSelected = "EsoUI/Art/Journal/journal_tabIcon_achievements_up.dds", 
    }, 
	[SI_JOURNAL_MENU_LEADERBOARDS] =
    {
        scenegroup = "journalSceneGroup",
		descriptor = "leaderboards",
        enabledNormal = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds",
        enabledSelected = "EsoUI/Art/Journal/journal_tabIcon_leaderboard_up.dds", 
    }, 
	[SI_MAIN_MENU_CHARACTER] =
    {
        scene = "stats",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_character_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_character_up.dds", 
	}, 
	[SI_MAIN_MENU_SKILLS] =
    {
        scene = "skills",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_skills_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_skills_up.dds", 
    }, 
	[SI_MAIN_MENU_CHAMPION] =
    {
        scene = "championPerks",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_champion_up.dds", 
    }, 
	[SI_MAIN_MENU_MARKET] =
    {
        scene = "market",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_market_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_market_up.dds", 
    }, 
	[SI_MAIN_MENU_INVENTORY] =
    {
        scene = "inventory",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_inventory_up.dds", 
    }, 
	[SI_MAIN_MENU_ALLIANCE_WAR] =
    {
        scenegroup = "allianceWarSceneGroup",
		descriptor = "campaignOverview",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_ava_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_ava_up.dds", 
    }, 
	[SI_MAIN_MENU_MAP] =
    {
        scene = "worldMap",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_map_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_map_up.dds", 
    }, 
	[SI_WINDOW_TITLE_FRIENDS_LIST] =
    {
        scenegroup = "contactsSceneGroup",
		descriptor = "friendsList",
        enabledNormal = "EsoUI/Art/Contacts/tabIcon_friends_up.dds",
        enabledSelected = "EsoUI/Art/Contacts/tabIcon_friends_up.dds", 
    }, 
	[SI_IGNORE_LIST_PANEL_TITLE] =
    {
        scenegroup = "contactsSceneGroup",
		descriptor = "ignoreList",
        enabledNormal = "EsoUI/Art/Contacts/tabIcon_ignored_up.dds",
        enabledSelected = "EsoUI/Art/Contacts/tabIcon_ignored_up.dds", 
    }, 
	[SI_MAIN_MENU_GUILDS] =
    {
        scenegroup = "guildsSceneGroup",
		descriptor = "guildHome",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_guilds_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_guilds_up.dds", 
    }, 
	[SI_MAIN_MENU_MAIL] =
    {
        scene = "mailInbox",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_mail_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_mail_up.dds", 
    }, 
	[SI_MAIN_MENU_NOTIFICATIONS] =
    {
        scene = "notifications",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_notifications_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_notifications_up.dds", 
    }, 
	[SI_MAIN_MENU_GROUP] =
    {
        scene = "groupMenuKeyboard",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_group_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_group_up.dds", 
    }, 
	[SI_MAIN_MENU_COLLECTIONS] =
    {
        scene = "collectionsBook",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_collections_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_collections_up.dds", 
    }, 
	[SI_MAIN_MENU_ACTIVITY_FINDER] =
    {
        scene = "groupMenuKeyboard",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_group_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_group_up.dds", 
    }, 
	[SI_MAIN_MENU_CROWN_CRATES] =
    {
        scene = "crownCrateKeyboard",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_crownCrates_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_crownCrates_up.dds", 
    },  
	[SI_RADIAL_MENU_CANCEL_BUTTON] =
    {
        enabledNormal = "EsoUI/Art/HUD/radialIcon_cancel_up.dds",
        enabledSelected = "EsoUI/Art/HUD/radialIcon_cancel_up.dds",
    }, 
	[SI_QUICKSLOTS_EMPTY] =
    {
        enabledNormal = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds",
        enabledSelected = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds", 
    }, 
	[SI_GAME_MENU_LOGOUT] =
	{
		callback = function()
			ZO_Dialogs_ShowPlatformDialog("LOG_OUT")
		end,
        enabledNormal = "esoui/art/tutorial/menubar_voip_up.dds",
        enabledSelected = "esoui/art/tutorial/menubar_voip_up.dds", 
	},
	[SI_GAME_MENU_QUIT] =
	{
		callback = function()
			ZO_Dialogs_ShowDialog("QUIT")
		end,
        enabledNormal = "esoui/art/mainmenu/menubar_system_up.dds",
        enabledSelected = "esoui/art/mainmenu/menubar_system_up.dds", 
	}
}


QuickMenu.GAMEPAD_MENU_ENTRIES =
{
    [SI_JOURNAL_MENU_QUESTS] =
    {
        scene = "gamepad_quest_journal",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_quests.dds", 
    },
	[SI_JOURNAL_MENU_CADWELLS_ALMANAC] =
    {
        scene = "cadwellGamepad",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_cadwell.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_cadwell.dds", 
    }, 
	[SI_JOURNAL_MENU_LORE_LIBRARY] =
    {
        scene = "loreLibraryGamepad",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_loreLibrary.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_loreLibrary.dds", 
    }, 
	[SI_JOURNAL_MENU_ACHIEVEMENTS] =
    {
        scene = "achievementsGamepad",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_achievements.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_achievements.dds", 
    }, 
	[SI_JOURNAL_MENU_LEADERBOARDS] =
    {
        scene = "gamepad_leaderboards",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_leaderBoards.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_leaderBoards.dds", 
    }, 
	
	[SI_MAIN_MENU_CHARACTER] =
    {
        scene = "gamepad_stats_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds", 
    }, 
	[SI_MAIN_MENU_SKILLS] =
    {
        scene = "gamepad_skills_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_skills.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_skills.dds", 
		disabledNormal = "esoui/art/mainmenu/menubar_skills_disabled.dds",
		disabledSelected = "esoui/art/mainmenu/menubar_skills_disabled.dds",
    }, 
	[SI_MAIN_MENU_CHAMPION] =
    {
        scene = "gamepad_championPerks_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_champion.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_champion.dds", 
    }, 
	[SI_MAIN_MENU_MARKET] =
    {
        scene = "gamepad_market_pre_scene",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_PlayerMenu_icon_store.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_PlayerMenu_icon_store.dds", 
    }, 
	[SI_MAIN_MENU_INVENTORY] =
    {
        scene = "gamepad_inventory_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds", 
		disabledNormal = "esoui/art/mainmenu/menuBar_inventory_disabled.dds",
		disabledSelected = "esoui/art/mainmenu/menuBar_inventory_disabled.dds",
    }, 
	[SI_MAIN_MENU_ALLIANCE_WAR] =
    {
        scene = "gamepad_campaign_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_allianceWar.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_allianceWar.dds", 
    }, 
	[SI_MAIN_MENU_MAP] =
    {
        scene = "gamepad_worldMap",
        enabledNormal = "EsoUI/Art/MainMenu/menuBar_map_up.dds",
        enabledSelected = "EsoUI/Art/MainMenu/menuBar_map_up.dds", 
    }, 
	[SI_WINDOW_TITLE_FRIENDS_LIST] =
    {
        scene = "gamepad_friends",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_contacts.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_contacts.dds", 
    }, 
	[SI_IGNORE_LIST_PANEL_TITLE] =
    {
        scene = "gamepad_ignored",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_contacts.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_contacts.dds", 
    }, 
	[SI_MAIN_MENU_GUILDS] =
    {
        scene = "gamepad_guild_hub",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_guilds.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_guilds.dds", 
    }, 
	[SI_MAIN_MENU_MAIL] =
    {
        scene = "mailManagerGamepad",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_mail.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_mail.dds", 
    }, 
	[SI_MAIN_MENU_NOTIFICATIONS] =
    {
        scene = "gamepad_notifications_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_notifications.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_notifications.dds", 
    }, 
	[SI_MAIN_MENU_GROUP] =
    {
        scene = "gamepad_groupList",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_groups.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_groups.dds", 
    }, 
	[SI_MAIN_MENU_COLLECTIONS] =
    {
        scene = "gamepadCollectionsBook",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_collections.dds", 
    }, 
	[SI_MAIN_MENU_ACTIVITY_FINDER] =
    {
        scene = "gamepad_activity_finder_root",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_activityFinder.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_activityFinder.dds", 
    }, 
	[SI_MAIN_MENU_CROWN_CRATES] =
    {
        scene = "crownCrateGamepad",
        enabledNormal = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_crownCrates.dds",
        enabledSelected = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_crownCrates.dds", 
    },  
	[SI_RADIAL_MENU_CANCEL_BUTTON] =
    {
        enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",
        enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds", 
    }, 
	[SI_QUICKSLOTS_EMPTY] =
    {
        enabledNormal = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds",
        enabledSelected = "EsoUI/Art/Quickslots/quickslot_emptySlot.dds", 
    }, 
	[SI_GAME_MENU_LOGOUT] =
	{
		callback = function()
			ZO_Dialogs_ShowPlatformDialog("LOG_OUT")
		end,
        enabledNormal = "esoui/art/menubar/gamepad/gp_playermenu_icon_logout.dds",
        enabledSelected = "esoui/art/menubar/gamepad/gp_playermenu_icon_logout.dds", 
	},
	[SI_GAME_MENU_QUIT] =
	{
		callback = function()
			ZO_Dialogs_ShowDialog("QUIT")
		end,
        enabledNormal = "esoui/art/tutorial/gamepad/gp_playermenu_icon_settings.dds",
        enabledSelected = "esoui/art/menubar/gamepad/gp_playermenu_icon_settings.dds", 
	}
}
