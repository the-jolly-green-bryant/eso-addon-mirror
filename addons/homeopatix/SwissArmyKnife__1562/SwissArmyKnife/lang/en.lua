-- SwissArmyKnife English Localization File
-- Last Updated 14-10-2017
-- Written Decembre 2016 by Tristan Carron (@homeopatix)
-- Released under terms in license accompanying this file.

-- Options Menu
ZO_CreateStringId("KF_KEY_TO_SEARCH", "SwissArmyKnife")

-- KeyBindings
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeTEXT", "Display SwissArmyKnife")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeJUMP", "Traveling to main house")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeJUNK", "Set Junk")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeLOCK", "Lock or Unlock")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeBAND", "Change the band display")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeHELMET", "Display or Hide helmet")

-- Slash commande
SAK.lang = {
		KF_SLASH_1 = "Slash command for ",
		KF_SLASH_2 = "Display slash command",
		KF_SLASH_3 = "Show graphic addon",
		KF_SLASH_4 = "hide graphic addon",
		KF_SLASH_5 = "Show all the ",
		KF_SLASH_5_2 = " in the chat",
		KF_SLASH_7 = "Nothing to show in the chat (default)",

		KF_SLASH_8 = "Show all the ",
		KF_SLASH_8_2 = " looted activated",
		KF_SLASH_10 = "Show the ",
		KF_SLASH_10_2 = " and the ",
		KF_SLASH_10_3 = " desactivated",
		KF_GOOD = "************ Good farming !!! *************",

		KF_INITIALIZED = "is initialized !!",
		-- money deposit
		KF_RAD = "Deposed in bank ",
		KF_RAD_1 = "Nothing to depose in bank",
		KF_RAD_2 = "Left : ",
		KF_RAD_3 = " and ",
		KF_RAD_4 = " on the character",
		KF_SLASH_18 = "Money min to keep on you",
		KF_SLASH_19 = "Tel Var stones min to keep on you",

		KF_SLASH_20 = "Money min to keep in the bag defined on ",
		KF_SLASH_21 = "Tel Var min to keep in the bag defined on ",
		KF_SLASH_22 = "Slash command to leave a group",
		KF_SLASH_23 = "You are not grouped !!!!",
		KF_SLASH_24 = "You are leaving the group !!!!",

		KF_SETTINGS_1 = "Display",
		KF_SETTINGS_2 = "Money Bank",
		KF_SETTINGS_21 = "Auto deposit settings",
		KF_SETTINGS_3 = "Display Settings",

		KF_COST_REPAIR = "Repair Cost :",
		KF_SEUIL_REP_1 = "Repair",
		KF_SEUIL_REP_2 = "Threshold",
		KF_SEUIL_REP_3 = "Threshold for armor repair or weapon reload",
		KF_SEUIL_REP_4 = "Define repair threshold",
		KF_SEUIL_REP_5 = "Repair threshold define on ",

		KF_SEUIL_REP_6 = "Border highlight color",
		KF_SEUIL_REP_6_2 = "Display color of the Border durability",
		KF_SEUIL_REP_7 = "Text highlight color",
		KF_SEUIL_REP_7_2 = "Text color of durability",
	
		KF_SEUIL_REPA_1 = "Charges",
		KF_SEUIL_REPA_2 = "Threshold Charges",
		KF_SEUIL_REPA_3 = "Threshold of weapon charge",
		KF_SEUIL_REPA_4 = "Define charge Threshold",
		KF_SEUIL_REPA_5 = "Charge Threshold define on ",
		
		KF_SEUIL_REPA_6 = "Border highlight color",
		KF_SEUIL_REPA_6_2 = "Display color of the Border for charge",
		KF_SEUIL_REPA_7 = "Text highlight color",
		KF_SEUIL_REPA_7_2 = "Text color of charge",
		KF_REPAIR_1 = "Gear repared for",
		KF_REPAIR_2 = "Not enough money to repair",
		KF_AUTO_REPA_1 = "Auto repair",
		KF_AUTO_REPA_2 = "Use Auto repair",
		KF_AUTO_REPA_4 = "Display auto repair in chat",
		KF_AUTO_REPA_6 = "Auto reload",
		KF_AUTO_REPA_7 = "Usage of auto reload",
		KF_AUTO_REPA_9 = "Display auto reload in chat",
		KF_AUTO_REPA_10 = "Define the auto reload treshold",
		KF_AUTO_REPA_11 = "Auto reload treshold define on",
		KF_AUTO_REPA_12 = "Reloaded with",
		KF_AUTO_REPA_13 = "Activated",
		KF_AUTO_REPA_14 = "Desactivated",

		KF_GENERAL_ST_1 = "General",
		KF_GENERAL_ST_2 = "Multi-account",
		KF_GENERAL_ST_2_1 = "Saving settings for all characters",
		KF_GENERAL_ST_3 = "This change will reload the user interface",
		KF_GENERAL_ST_4 = "Display experience",
		KF_GENERAL_ST_4_1 = "Display experience and level",
		KF_GENERAL_ST_8 = "Display the enlighted pool",
		KF_GENERAL_ST_8_1 = "Display the enlighted pool or the xp needed",
		KF_GENERAL_ST_8_2 = "Display the enlightement bar",
		KF_GENERAL_ST_8_3 = "Display the enlightement bar or not",

		KF_LANG_1 = "Say Hello to group",
		KF_LANG_2 = "Say Thank you and bye to group",
		KF_LANG_3 = "Answer a friend",
		KF_LANG_4 = "Say hello to guild1",
		KF_LANG_5 = "Say hello to guild2",
		KF_LANG_6 = "Say hello to guild3",
		KF_LANG_7 = "Say hello to guild4",
		KF_LANG_8 = "Say hello to guild5",
		KF_LANG_10 = "Display slash command for language",
		KF_SLASH_11 = "Slash command language for ",

		KF_SETTINGS_1_1 = "Repair and Charges",
		KF_SETTINGS_2_1 = "Automatic text",
		KF_SETTINGS_3_1 = "!!!! WE CAN NOT SEND DIRECT CHAT MESSAGE, SO THE MESSAGE IS WRITTEN FOR YOU IN THE CHAT AND YOU JUST HAVE TO PRESS ENTER TO POST IT !!!!",
		KF_SETTINGS_4 = "Group",
		KF_SETTINGS_5 = "Welcome text               /kh =",
		KF_SETTINGS_6 = "Bye bye text               /kt =",
		KF_SETTINGS_7 = "Friends",
		KF_SETTINGS_8 = "Answer for friends               /kr =",
		KF_SETTINGS_9 = "Guild",
		KF_SETTINGS_10 = "Guild 1               /kg1 =",
		KF_SETTINGS_11 = "Guild 2               /kg2 =",
		KF_SETTINGS_12 = "Guild 3               /kg3 =",
		KF_SETTINGS_13 = "Guild 4               /kg4 =",
		KF_SETTINGS_14 = "Guild 5               /kg5 =",
		KF_SETTINGS_15 = "Press the button to validate your choices",
		KF_SETTINGS_16 = "Validate",
		KF_SETTINGS_17 = "Display Mail Icon",
		KF_TRAVEL_1 = "Display the travel cost",
		KF_TRAVEL_2 = "Display the travel cost or not",
		KF_STATS_4 = "Experience",

		KF_TIME_PLAYED_1 = "Display Played Time",
		KF_TIME_PLAYED_2 = "Display your total and session time played",
		KF_TIME_PLAYED_3 = " day(s)",
		KF_TIME_PLAYED_4 = " hour(s)",
		KF_TIME_PLAYED_5 = " minute(s)",
		KF_TIME_PLAYED_6 = " second(s)",
		KF_TIME_PLAYED_7 = "Display Gold won",
		KF_TIME_PLAYED_8 = "Gold won for the session and gold per hour",

		KF_TIME_PLAYED_9_1 = "Gold per Hour",
		KF_TIME_PLAYED_9 = "Repair included",
		KF_TIME_PLAYED_10 = "Included repair cost in gold per hour gain",
		KF_TIME_PLAYED_11 = "Display the champion lvl",
		KF_TIME_PLAYED_12 = "Display the champion lvl or not",

		KF_STATS_1 = "Statistics",
		KF_STATS_2 = "Reset",
		KF_STATS_3 = "Reset of the gold per hour gain and time played",

		KF_HOUSE_1 = "Housing",
		KF_HOUSE_2 = "Main House",
		KF_HOUSE_3 = "Travel to house",
		KF_HOUSE_4 = "Preparaing the travel to ",
		KF_HOUSE_5 = "Can not Travel home from Cyrodiil",
		KF_HOUSE_6 = "Change the Band",

		KF_SMALL_ADDON_1 = "Potions display",
		KF_SMALL_ADDON_2 = "Display potions or soulgem outside the imperial city",
		
		KF_THIEF_1 = "Thief",
		KF_THIEF_2 = "Change your name in blinking warning when gardes are looking for you",
		KF_THIEF_3 = "Do not show the Warning",
		KF_THIEF_4 = "Addon Thief",
		KF_THIEF_5 = "Switch off thief addon",
		KF_THIEF_6 = "Display the heat",
		KF_THIEF_7 = "Display de bounty lvl",

		KF_DIS_START_1 = "Full display",
		KF_DIS_START_2 = "Full display at start",

		KF_DONATE_1 = "You can send me comment or in game gold directly, by advance thank you !!!!",
		KF_DONATE_2 = "Donat by mal",
		KF_DONATE_3 = "Give 100 Gold",
		KF_DONATE_4 = "Give 1000 Gold",
		KF_DONATE_5 = "Give 10000 Gold",
		KF_DONATE_6 = "Give 100000 Gold",
		KF_DONATE_7 = "Send a comment",

		KF_BAG_1 ="Bag size threshold",
		KF_BAG_2 ="Space left in bag for alert",

		KF_REPAIRCOST_1 = "Display the repair cost",
		KF_REPAIRCOST_2 = "Display or not the repair cost",

		KF_BAGBANK_1 = "Display the size of bag and bank",
		KF_BAGBANK_2 = "Display or not the size of bag and bank",

		KF_COMBAT_1 = "Display in fight",
		KF_COMBAT_2 = "Display in fight or not",

		KF_TELVAR = "TelVar Stone Alarm",
		KF_TELVAR_1 = "Activated alarm for TelVar stone",
		KF_TELVAR_2 = "TelVar stone max before alarm",
		KF_TELVAR_3 = "Define alarm threshold",
		KF_TELVAR_4 = "Threshold alarm define on ",
		KF_ALLI_1 = "Alliance points min to keep in the bag",
		KF_ALLI_2 = "Alliance points min to keep in the bag defined on",
		KF_ALLI_3 = "Writ Voucher min to keep in the bag",
		KF_ALLI_4 = "Writ Voucher min to keep in the bag defined on",

		KF_MONEY_1 = "Show the money won",
		KF_MONEY_2 = "Show the TelVar stone won",
		KF_MONEY_3 = "Show the Alliance points won",

		KF_MOUNT_1 = "Display the stable timer",
		KF_MOUNT_2 = "Display time before training",
		KF_MOUNT_3 = "Available",
		KF_VAMP_1 = "Vampire Bite available",
		KF_VAMP_2 = "Vampire Bite available in",
		KF_VAMP_3 = "WereWolf Bite available",
		KF_VAMP_4 = "WereWolf Bite available in",

		KF_CRYSTAL_1 = "Display Crystal transmute",
		KF_CRYSTAL_2 = "Display Writ Voucher",

		KF_JUNK_1 = "Items Junk sold",
		KF_JUNK_2 = "No junk items to sold",
		KF_JUNK_3 = "Junk items in bag",
		KF_JUNK_4 = "Auto sold junk",
		KF_JUNK_5 = "Display junk",
		KF_JUNK_6 = "Display junk or not",
		KF_JUNK_7 = "JUNK & LOCK",
		KF_JUNK_8 = "Display Junk in chat",
		KF_JUNK_9 = "Display Lock in chat",
		KF_JUNK_10 = "Display auto set Junk",
		KF_JUNK_11 = "Display loot in chat",
		KF_JUNK_12 = "has been UnSet to Junk",
		KF_JUNK_13 = "has been Set to Junk",
		KF_JUNK_14 = "has been Locked",
		KF_JUNK_15 = "has been UnLocked",

		KF_BANDEAU_1 = "Band Display",
		KF_BANDEAU_2 = "Display deadricAmbers",
		KF_BANDEAU_3 = "Display potions",
		KF_BANDEAU_4 = "Display SoulGems",
		KF_BANDEAU_5 = "Display WritCrafting",
		KF_BANDEAU_6 = "Choice display",
		KF_BANDEAU_7 = "Display combat potions",
		KF_BANDEAU_8 = "Display Stealing helper",

		KF_WRIT_HELPER_1 = "Display Writ helper window",
		KF_WRIT_HELPER_2 = "Display Writ helper window or not",
		KF_WRIT_HELPER_3 = "Display Writ helper window when thief warning",
		KF_WRIT_HELPER_4 = "Display Writ helper window when thief warning or not",
		KF_WRIT_HELPER_5 = "Display Writ helper window when looking for group",
		KF_WRIT_HELPER_6 = "Display Writ helper window when looking for group or not",
		KF_WRIT_HELPER_7 = "Looking for group",
		KF_WRIT_HELPER_8 = "Estimated",
		KF_WRIT_HELPER_9 = "Real",

		KF_USE_BANK = "Use the Auto Deposit",

		KF_DEPOSIT_MONEY = "Auto deposit for Money",
		KF_DEPOSIT_TELVAR = "Auto deposit for Tel Var Stone",
		KF_DEPOSIT_ALLIANCE = "Auto deposit for Alliance points",
		KF_DEPOSIT_WRIT = "Auto deposit for Writ Voucher",
}


