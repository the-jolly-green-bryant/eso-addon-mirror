Dizzy = {}

-- This is a comprehensive list of menu scenes where we might want to prevent camera rotation
-- Grouped by Keyboard (PC/Mac) and Gamepad (Console) interfaces
Dizzy.menuScenes = {
    -- Keyboard (PC/Mac) Interface Scenes
    "skills",                           -- Keyboard / Skills Menu
    "questJournal",                     -- Keyboard / Quest Journal Menu
    "collectionsBook",                  -- Keyboard / Collections
    "dlcBook",                          -- Keyboard / Collections > Stories
    "housingBook",                      -- Keyboard / Collections > Housing
    "itemSetsBook",                     -- Keyboard / Collections > Set Items
    "tributePatronBook",                -- Keyboard / Collections > ToT Patrons
    "groupMenuKeyboard",                -- Keyboard / Group & Activity Finder
    "friendsList",                      -- Keyboard / Friends
    "ignoreList",                       -- Keyboard / Friends > Ignored
    "guildHome",                        -- Keyboard / Guilds
    "guildRoster",                      -- Keyboard / Guilds > Roster
    "guildRanks",                       -- Keyboard / Guilds > Ranks
    "guildRecruitmentKeyboard",         -- Keyboard / Guilds > Recruitment
    "guildHistory",                     -- Keyboard / Guilds > History
    "guildBrowserKeyboard",             -- Keyboard / Guilds > Guild Finder
    "guildCreate",                      -- Keyboard / Guilds > Create Guild
    "mailInbox",                        -- Keyboard / Mail > Inbox
    "mailSend",                         -- Keyboard / Mail > Send
    "notifications",                    -- Keyboard / Notifications
    "scribingLibraryKeyboard",          -- Keyboard / Skills / Scribing
    "antiquityJournalKeyboard",         -- Keyboard / Quest Journal > Antiquities Codex
    "loreLibrary",                      -- Keyboard / Quest Journal > Lore Library
    "achievements",                     -- Keyboard / Quest Journal > Achievements
    "leaderboards",                     -- Keyboard / Quest Journal > Leaderboards
    "helpTutorials",                    -- Keyboard / Help > Tutorials
    "helpCustomerSupport",              -- Keyboard / Help > Customer Support
    "helpEmotes",                       -- Keyboard / Help > Emotes
    "campaignBrowser",                  -- Keyboard / Campaigns > Browser
    "campaignOverview",                 -- Keyboard / Campaigns > Overview
    "giftInventoryKeyboard",            -- Keyboard / Crown Store > Gift Inventory

    -- Gamepad (Console) Interface Scenes
    "helpRootGamepad",                          -- Gamepad / Help
    "helpCustomerServiceGamepad",               -- Gamepad / Help > Customer Service
    "helpTutorialsCategoriesGamepad",           -- Gamepad / Help > Tutorials
    "helpTutorialsEntriesGamepad",              -- Gamepad / Help > Tutorials > Entries
    "helpSubmitFeedbackGamepad",                -- Gamepad / Help > Feedback/Bug
    "helpQuestAssistanceGamepad",               -- Gamepad / Help > Quest Assistance
    "helpItemAssistanceGamepad",                -- Gamepad / Help > Item Assistance
    "mainMenuGamepad",                          -- Gamepad / Main Menu
    "playerSubmenu",                            -- Gamepad / Main Menu > Submenus
    "gamepad_quest_journal",                    -- Gamepad / Journal > Quests
    "gamepad_antiquity_journal",                -- Gamepad / Journal > Antiquities
    "loreLibraryGamepad",                       -- Gamepad / Journal > Lore Library
    "achievementsGamepad",                      -- Gamepad / Journal > Achievements
    "gamepad_leaderboards",                     -- Gamepad / Journal > Leaderboards
    "gamepadChatMenu",                          -- Gamepad / Social > Text Chat
    "gamepad_player_emote",                     -- Gamepad / Social > Emotes
    "gamepad_groupList",                        -- Gamepad / Social > Group
    "gamepad_guild_hub",                        -- Gamepad / Social > Guilds
    "gamepad_friends",                          -- Gamepad / Social > Friends
    "gamepad_ignored",                          -- Gamepad / Social > Ignored
    "mailGamepad",                              -- Gamepad / Social > Mail
    "gamepad_activity_finder_root",             -- Gamepad / Activity Finder
    "GroupFinderGamepad",                       -- Gamepad / Activity Finder > Group Finder 
    "group_finder_gamepad_list",                -- Gamepad / Activity Finder > ? (Not Verified)
    "TimedActivitiesGamepad",                   -- Gamepad / Activity Finder > Endeavors
    "zoneStoriesGamepad",                       -- Gamepad / Activity Finder > Zone Stories
    "gamepadDungeonFinder",                     -- Gamepad / Activity Finder > Dungeon Finder
    "gamepadBattlegroundFinder",                -- Gamepad / Activity Finder > Battlegrounds
    "gamepadTributeFinder",                     -- Gamepad / Activity Finder > Tales of Tribute
    "houseToursGamepad",                        -- Gamepad / Activity Finder > Home Tours
    "gamepad_options_root",                     -- Gamepad / Options
    "giftInventoryGamepad",                     -- Gamepad / Crown Store > Gift Inventory
    "gamepad_skills_root",                      -- Gamepad / Skills
    "gamepad_skills_line_filter",               -- Gamepad / Skills > Skill Lines
    "gamepad_skills_scribing_library_root",     -- Gamepad / Skills > Scribing
    "gamepad_campaign_root",                    -- Gamepad / Campaigns

    -- Known non-working scenes (these will force camera rotation regardless)
    --List of non-working scenes. Forces the camera spin regardless.
    -- "gamepadCollectionsBook",
    -- "gamepad_options_panel",
}
