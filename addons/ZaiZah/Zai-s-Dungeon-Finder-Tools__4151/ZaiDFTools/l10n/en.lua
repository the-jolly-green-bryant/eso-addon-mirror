------------------------------------------------------------------------------------------------------------------
-- English (en)
-- Format and phrasing by ZaiZah
-- version 1.0
------------------------------------------------------------------------------------------------------------------
-- Every variable must start with this addon's unique ID, as each is a global. 
-- ZDFT_
local strings = {
    -- Addon name
    ["ZDFT_NAME"] = "Zai's Dungeon Finder Tools",

    -- Error Strings
    ["ZDFT_LAM2_NOT_FOUND"] = "LibAddonMenu2 not found. Settings panel could not be created.",
    ["ZDFT_INVALID_DUNGEON_DATA"] = "Invalid Dungeon Data",
    ["ZDFT_INVALID_DUNGEON_DATA_TEXT"] = "Invalid dungeon data",
    ["ZDFT_COULD_NOT_FIND_FILTER"] = "Could not find filter dropdown",
    ["ZDFT_COULD_NOT_ACCESS_DROPDOWN"] = "Could not access dropdown items",

    -- Dungeon Types
    ["ZDFT_DLC_DUNGEON_TEXT"] = "DLC Dungeon",
    ["ZDFT_BASE_GAME_TEXT"] = "Base Game",
    
    -- Difficulty Types
    ["ZDFT_NORMAL_VETERAN"] = "Normal & Veteran",

    -- Achievement Categories
    ["ZDFT_VETERAN_ACHIEVEMENTS"] = "Veteran Achievements",
    ["ZDFT_TRIFECTA_TEXT"] = "Trifecta",
    ["ZDFT_HARDMODE_TEXT"] = "Hard Mode",
    ["ZDFT_SPEEDRUN_TEXT"] = "Speedrun",
    ["ZDFT_NODEATH_TEXT"] = "No Death",
    ["ZDFT_ALL_3_VETERAN"] = "All 3 Veteran achievements",
    
    -- Pledge Givers
    ["ZDFT_MAJ_AL_RAGATH"] = "Maj al-Ragath",
    ["ZDFT_GLIRION_REDBEARD"] = "Glirion the Redbeard",
    ["ZDFT_URGARLAG_CHIEF"] = "Urgarlag Chief-bane",
    
    -- Pledge Quest Status
    ["ZDFT_DAILY_PLEDGE"] = "Daily Pledge",
    ["ZDFT_TODAYS_PLEDGE_QUESTS"] = "Today's Pledge Quests",
    ["ZDFT_TODAYS_PLEDGE_STATUS"] = "Today's Pledge Status",
    ["ZDFT_READY_TO_TURN_IN"] = "Ready to Turn In",
    ["ZDFT_QUEST_IN_PROGRESS"] = "Quest In Progress",
    ["ZDFT_ALREADY_COMPLETED_TODAY"] = "Already Completed Today",
    ["ZDFT_AVAILABLE_TO_ACCEPT"] = "Available to Accept",
    ["ZDFT_NO_ACTIVE_QUEST"] = "No active quest",

    -- Pledge Actions & Results
    ["ZDFT_SELECT_PLEDGES_BUTTON"] = "Select Today's Pledges",
    ["ZDFT_NO_PLEDGES_FOUND"] = "No pledges found for the selected difficulty.",
    ["ZDFT_NO_PLEDGES_FOUND_TEXT"] = "No pledges found for the selected difficulty.",
    ["ZDFT_SELECTED_PLEDGES_FORMAT"] = "Selected %d %s pledges",
    ["ZDFT_DESELECTED_PLEDGES_TEXT"] = "Deselected %d pledges",
    
    -- Collections
    ["ZDFT_SETTINGS_COLLECTIONS"] = "Collections",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON"] = "Show Collection Button",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON_TT"] = "Show a button to quickly select dungeons with incomplete set pieces or motif collections",
    ["ZDFT_SETTINGS_COLLECTION_TYPE"] = "Collection Type",
    ["ZDFT_SETTINGS_COLLECTION_TYPE_TT"] = "Choose what type of collections to check for when selecting dungeons",
    ["ZDFT_SETTINGS_COLLECTION_SETS"] = "Set Pieces",
    ["ZDFT_SETTINGS_COLLECTION_MOTIFS"] = "Motif Styles", 
    ["ZDFT_SETTINGS_COLLECTION_BOTH"] = "Both",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY"] = "Collection Button Difficulty",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY_TT"] = "Choose which difficulty dungeons to select for collections",
    
    -- Collection Button Text and Messages
    ["ZDFT_SELECT_COLLECTIONS_BUTTON"] = "Select Collections",
    ["ZDFT_SELECT_COLLECTIONS_BUTTON_FORMAT"] = "Select %s",
    ["ZDFT_SETS_TEXT"] = "Sets",
    ["ZDFT_MOTIFS_TEXT"] = "Motifs",

    -- Collection Button Alert Messages
    ["ZDFT_NO_COLLECTIONS_FOUND_TEXT"] = "No dungeons found with incomplete %s",
    ["ZDFT_DESELECTED_COLLECTIONS_TEXT"] = "Deselected %d collections",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT"] = "Selected %d %s dungeons with incomplete collections",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT_NO_DIFFICULTY"] = "Selected %d dungeons with incomplete %s",

    -- Color Legend
    ["ZDFT_COLOR_LEGEND_TITLE"] = "Pledge Color Legend",
    ["ZDFT_COLOR_LEGEND_BLUE"] = "Blue: Available to Accept",
    ["ZDFT_COLOR_LEGEND_ORANGE"] = "Orange: Quest In Progress",
    ["ZDFT_COLOR_LEGEND_GREEN"] = "Green: Ready to Turn In",
    ["ZDFT_COLOR_LEGEND_GREY"] = "Grey: Already Completed Today",
    
    -- Settings - Achievement Icons
    ["ZDFT_SETTINGS_ACHIEVEMENT_ICONS"] = "Achievement Icons",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA"] = "Show Trifecta Icon",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA_TT"] = "Display trifecta achievement icon",
    ["ZDFT_SETTINGS_SHOW_HARDMODE"] = "Show Hard Mode Icon",
    ["ZDFT_SETTINGS_SHOW_HARDMODE_TT"] = "Display hard mode achievement icon",
    ["ZDFT_SETTINGS_SHOW_NODEATH"] = "Show No Death Icon",
    ["ZDFT_SETTINGS_SHOW_NODEATH_TT"] = "Display no death achievement icon",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN"] = "Show Speed Run Icon",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN_TT"] = "Display speed run achievement icon",
    ["ZDFT_SETTINGS_SHOW_CLEARED"] = "Show Cleared Icon",
    ["ZDFT_SETTINGS_SHOW_CLEARED_TT"] = "Display dungeon completion icon",
    ["ZDFT_SETTINGS_SHOW_MOTIF"] = "Show Motif Icon",
    ["ZDFT_SETTINGS_SHOW_MOTIF_TT"] = "Display motif achievement icon",
    ["ZDFT_SETTINGS_SHOW_SET"] = "Show Set Collection Icon",
    ["ZDFT_SETTINGS_SHOW_SET_TT"] = "Display set collection icon",
    
    -- Settings - Pledge
    ["ZDFT_SETTINGS_PLEDGE"] = "Pledge Settings",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES"] = "Highlight Pledge Dungeons",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES_TT"] = "Color pledge dungeon names to indicate their status",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON"] = "Show Pledge Icon",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON_TT"] = "Show Undaunted key icon next to pledge dungeons",
    
    -- Settings - UI
    ["ZDFT_SETTINGS_UI"] = "UI Settings",
    ["ZDFT_SETTINGS_SHOW_BUTTON"] = "Show 'Select Today's Pledges' Button",
    ["ZDFT_SETTINGS_SHOW_BUTTON_TT"] = "Display button to automatically select today's pledges",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY"] = "Pledge Difficulty",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY_TT"] = "Which difficulty to use when selecting pledges",
    ["ZDFT_SETTINGS_FOLLOW_FINDER"] = "Follow Group Finder",
    ["ZDFT_SETTINGS_ALWAYS_NORMAL"] = "Always Normal",
    ["ZDFT_SETTINGS_ALWAYS_VETERAN"] = "Always Veteran",
    ["ZDFT_SETTINGS_BOTH_DIFFICULTIES"] = "Both Difficulties",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end