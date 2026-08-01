--en

local strings = {
    --Addon Menu
    aTIM99_NLF_MENU_TITLE               = "NewLife-Festival",

    aTIM99_NLF_MENU_HEADER1_HEADER      = "Infos for fast porting...",
    aTIM99_NLF_MENU_HEADER1_DESCR_1     = "Leftclick on quest to teleport to a wayshrine of 1st quest-location",
    aTIM99_NLF_MENU_HEADER1_DESCR_2     = "Rightclick on quest starts teleport to 2nd Location -IF- there is one",
    aTIM99_NLF_MENU_HEADER1_DESCR_3     = "Set Hotkey to port to SnowGlobe-Home (Owner:outside, else inside)",
    aTIM99_NLF_MENU_HEADER2_HEADER      = "Infos on miscellaneous...(also see /tnl)",
    aTIM99_NLF_MENU_HEADER2_DESCR_1     = "Meadmug ico glows if XP-buff ran out",   --as short as possible
    aTIM99_NLF_MENU_HEADER2_DESCR_2     = "Click on meadmug icon to use it",        --as short as possible
    aTIM99_NLF_MENU_HEADER2_DESCR_3     = "Stops at quests if you loose tickets",   --as short as possible
    aTIM99_NLF_MENU_HEADER2_DESCR_4     = "Marks white quest rewards as junk",      --as short as possible
    aTIM99_NLF_MENU_SHOWWINDOW_TEXT     = "Window is shown/controlled in/by:",
    aTIM99_NLF_MENU_SHOWWINDOW_OPT1     = "user via keybind",                       --option in combobox
    aTIM99_NLF_MENU_SHOWWINDOW_OPT2     = "both game- & cursor-mode",               --option in combobox
    aTIM99_NLF_MENU_SHOWWINDOW_OPT3     = "only game-mode (cursor not active)",     --option in combobox
    aTIM99_NLF_MENU_SHOWWINDOW_OPT4     = "only cursor-mode (cursor is active)",    --option in combobox
    aTIM99_NLF_MENU_SKIPDIALOGS_TEXT    = "Skip quest dialogues:",
    aTIM99_NLF_MENU_SKIPDIALOGS_ERR     = "Wrong value return from LAM: %s",
    aTIM99_NLF_MENU_USEXPBUFF_TEXT      = "Use XP-Buff automatically:",
    aTIM99_NLF_MENU_SHOWDEBUG_TEXT      = "Show debug messages:",
    aTIM99_NLF_MENU_AUTOFOLLOWQ_TEXT    = "Accept Breda's follow-up quest:",
    aTIM99_NLF_MENU_TRACKEDQUEST_TEXT   = "Mark tracked quest:",
    aTIM99_NLF_MENU_SHOWSHRINE_TEXT     = "Show wayshrine icon:",
	aTIM99_NLF_MENU_JUNKITEMS_LIST      = "concerns the following items:",
	aTIM99_NLF_MENU_MARKJUNK            = "Mark junk",
	aTIM99_NLF_MENU_DELETEJUNK          = "Delete junk",
	aTIM99_NLF_MENU_PORTRAWLHOME_TEXT   = "Port to Reaper's-M. house instead of wayshrine",
	aTIM99_NLF_MENU_GETFISHBANK_TEXT    = "Get fish for quest from bank",
	aTIM99_NLF_MENU_CLOSEBANK_TEXT      = "then close Bank",
	aTIM99_NLF_MENU_DISMISBANK_TEXT     = "and despawn bank",
	aTIM99_NLF_MENU_SHOWTICKETS_TEXT    = "Show amount of tickets in window",
	aTIM99_NLF_MENU_FASTWAYSHRINE_TEXT  = "Enable wayshrine fast-travel",
	aTIM99_NLF_MENU_FASTWAYSHRINE_TTIP  = "When an event quest is active and tracked (the marked one), you get automatically ported FOR FREE to the next quest location when interacting with a wayshrine",
	aTIM99_NLF_MENU_CHATMARKJUNK_TEXT   = "Chat message for marking",
	aTIM99_NLF_MENU_CHATDELJUNK_TEXT    = "Chat message for deleting",
	aTIM99_NLF_MENU_CHATTRAVEL_TEXT     = "Chat message for porting",
	aTIM99_NLF_MENU_TIPORKILL_TEXT      = "Grahtwood: tip or kill",
	aTIM99_NLF_MENU_TIPORKILL_OPT1      = "donate",                                 --option in combobox
    aTIM99_NLF_MENU_TIPORKILL_OPT2      = "kill",                                   --option in combobox
    aTIM99_NLF_MENU_TIPORKILL_OPT3      = "ask me each time",                       --option in combobox
	aTIM99_NLF_MENU_ALLGOLDONOFF_TEXT   = "switch ALL on (or off)",
	aTIM99_NLF_MENU_DELITEM_TEXT        = "delete items:",
	aTIM99_NLF_MENU_MAIN_SETTINGS       = "Settings",
	aTIM99_NLF_MENU_MAIN_WHITEJUNK      = "White Junk",
	aTIM99_NLF_MENU_MAIN_GOLDENJUNK     = "Golden Junk",
	aTIM99_NLF_MENU_MAIN_VISUALS        = "Visuals",
	aTIM99_NLF_MENU_MAIN_OTHERS         = "Others",
	aTIM99_NLF_MENU_AUTOTRACKQUEST      = "Switch on automatic quest tracking",
	
    --Ingame
    aTIM99_NLF_INGAME_ERR_USEBUFF       = "Could not drink, something went wrong. Pls try again/yourself",
    aTIM99_NLF_INGAME_LOOSETICKETS      = "Loosing tickets",
    aTIM99_NLF_INGAME_NUMTICKETS        = "Tickets",
    aTIM99_NLF_INGAME_MARKJUNK          = "Junk",
	aTIM99_NLF_INGAME_DELJUNK           = "Deleted",
	aTIM99_NLF_INGAME_USEMUGNOW         = "Use Mug now",
	aTIM99_NLF_INGAME_JUMPBREDAHOUSE    = "Jump to Bredas house",
	aTIM99_NLF_INGAME_JUMPBREDAWS       = "Jump to Bredas wayhrine",
	aTIM99_NLF_INGAME_GRAHTINFO_DONATE  = "You donated and can return now",
	aTIM99_NLF_INGAME_GRAHTINFO_KILL    = "You chose violence. Go and kill",
	aTIM99_NLF_INGAME_GRAHTINFO_ASK     = "Make your decision",
	aTIM99_NLF_INGAME_FISHTAKEN         = "retrieved fish (or not possible/needed)", --as short as possible to keep it in one line
	
    --Keybindungs
    aTIM99_NLF_KEYBIND_2                = "Toggle Main Window",
    aTIM99_NLF_KEYBIND_1                = "Port to Snow-Globe-House",
    aTIM99_NLF_KEYBIND_3                = "Port to Bredas Wayshrine",

    --Chat-Commands (/slash)
    -- ### Guess noone really wants them translated as there are as much as hell...
    -- and will propably never used, so lets wait and do them on request

    --Debug messages
    -- ### Guess noone really wants them translated as there are as much as hell...
    -- and will for sure never used, so lets wait and do them on request
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end