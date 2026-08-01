local Register = LibCodesCommonCode.RegisterString

Register("SI_RCR_TITLE"                   , "Raidificator")

Register("SI_RCR_SUBTITLE_HISTORY"        , "Score History")
Register("SI_RCR_SUBTITLE_ACHIEVEMENTS"   , GetString(SI_JOURNAL_MENU_ACHIEVEMENTS))

Register("SI_RCR_MESSAGE_TRIAL_START"     , "<<1>> started; the par completion time is <<2>> minutes.")
Register("SI_RCR_MESSAGE_TRIAL_END"       , "<<1>> completed with a final score of <<2>> and with <<3>> vitality bonuses remaining. Your total time was <<4>>; it <<5>> the par completion time of <<6>> minutes by <<7>>.  [|c00FFCC|H0:rcr|hOpen History|h|r]")
Register("SI_RCR_MESSAGE_TRIAL_END1"      , "outpaced")
Register("SI_RCR_MESSAGE_TRIAL_END2"      , "exceeded")
Register("SI_RCR_MESSAGE_OBSOLETE"        , "|cFF0000Warning:|r Please uninstall the “<<1>>” addon. The “<<1>>” addon is obsolete has been discontinued because it and its features are now a part of Raidificator.")

Register("SI_RCR_HEADER_TIMESTAMP"        , "Date")
Register("SI_RCR_HEADER_CHARACTER"        , "Character")
Register("SI_RCR_HEADER_SCORE"            , "Score")
Register("SI_RCR_HEADER_DURATION"         , "Duration")
Register("SI_RCR_HEADER_NAME"             , GetString(SI_ADDON_MANAGER_NAME))
Register("SI_RCR_HEADER_CLEAR"            , "Clear")
Register("SI_RCR_HEADER_COMPLETED"        , GetString(SI_ZONECOMPLETIONTYPE_PROGRESSHEADER1))

Register("SI_RCR_COMPLETED_COUNT"         , "%d / %d completed (%d%%)")
Register("SI_RCR_LINK_INCOMPLETE"         , "Link Incomplete in Chat")

Register("SI_RCR_ALL_ACCOUNTS"            , "All Accounts")
Register("SI_RCR_GROUP_MEMBERS"           , "Group Members")

Register("SI_RCR_ACHIEVEMENT_CATEGORY1"   , GetString("SI_GUILDACTIVITYATTRIBUTEVALUE", GUILD_ACTIVITY_ATTRIBUTE_VALUE_DUNGEONS))
Register("SI_RCR_ACHIEVEMENT_CATEGORY2"   , GetString("SI_GUILDACTIVITYATTRIBUTEVALUE", GUILD_ACTIVITY_ATTRIBUTE_VALUE_TRIALS))
Register("SI_RCR_ACHIEVEMENT_CATEGORY3"   , "Arenas")

Register("SI_RCR_FILTER_HIDE_ARC_1"       , "Hide Arc 1")
Register("SI_RCR_FILTER_PLEDGES"          , "Today's Pledges")

Register("SI_RCR_DTR_TITLE"               , "Reform Group")
Register("SI_RCR_DTR_SLASH_CONFIRM"       , "Are you sure you want to disband and reform the group?")
Register("SI_RCR_DTR_DISCOVERY"           , "You can use the |c00CCFF/reformgroup|r chat command or a custom keybind to reset an instance by disbanding and reforming the group.")
Register("SI_BINDING_NAME_RCR_REFORM"     , "Raidificator: Reform Group")

Register("SI_RCR_KEYBIND_CONFIRM"         , "%s: to confirm, re-issue this command %d more time(s) within %0.1fs.")

Register("SI_RCR_PLEDGES"                 , "Undaunted Pledges")
Register("SI_RCR_PLEDGES_ACTIVE"          , "Have Pledge")
Register("SI_RCR_PLEDGES_AVAILABLE_SP"    , "Available Skill Point")
Register("SI_RCR_PLEDGES_AVAILABLE_PL"    , "<<1>> is available")

Register("SI_RCR_QUEST_COOLDOWN"          , "On Cooldown")

Register("SI_RCR_SECTION_STATUS"          , "Status Bar")
Register("SI_RCR_SETTING_BGCOLOR"         , "Background color")

Register("SI_RCR_SECTION_LOGGING"         , "Encounter Logging")
Register("SI_RCR_SETTING_LOG_DUNGEON"     , "Automatically log veteran dungeons")
Register("SI_RCR_SETTING_LOG_TRIAL"       , "Automatically log veteran trials and arenas")
Register("SI_RCR_SETTING_LOG_ENDLESS"     , "Automatically log Infinite Archive")

Register("SI_RCR_SECTION_QUESTS"          , "Joining Quests In Progress")
Register("SI_RCR_SETTING_QUESTS_DUNGEONS" , "Dungeon quests")
Register("SI_RCR_SETTING_QUESTS_TRIALS"   , "Trial quests")
Register("SI_RCR_SETTING_QUESTS_ARENAS"   , "Arena and Infinite Archive quests")
Register("SI_RCR_SETTING_QUEST_ACTION0"   , "Do nothing")
Register("SI_RCR_SETTING_QUEST_ACTION1"   , "Always accept")
Register("SI_RCR_SETTING_QUEST_ACTION2"   , "Always decline")

Register("SI_RCR_SECTION_CASTS"           , "Accidental Ability Casts")
Register("SI_RCR_SETTING_CASTS_TEXT"      , "If enabled, this feature will prevent the casting of certain abilities that are slotted for only their passive bonuses.\n\nThis feature is active only when the player is in combat inside a dungeon, trial, or arena.\n\nAffected abilities: <<1>>")
