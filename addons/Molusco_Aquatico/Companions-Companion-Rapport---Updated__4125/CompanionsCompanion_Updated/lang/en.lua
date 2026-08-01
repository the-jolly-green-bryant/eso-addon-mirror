local englishStrings = {

    --[[
        UI Gamepad
    ]]
    CC_UI_RAPPORT_TITLE = "Rapport",

    --[[
        General
    ]]
    CC_TEXT_GOOD_RAPPORT       = "Good Rapport", -- Title
    CC_TEXT_BAD_RAPPORT        = "Bad Rapport",  -- Title
    CC_REMINDER_BTN            = "Remind",       -- Remind btn text
    CC_CANCEL_BTN              = "Cancel",       -- Cancel btn text
    CC_ERROR_START_TIMER       = "Failed to start the timer",
    CC_RESET_MODAL_TITLE       = "Reset Timer",
    CC_RESET_MODAL_DESCRIPTION = "Are you sure you want to reset the timer for this event?",

    --[[
        Notifications
    ]]
    CC_NOTIFICATION_TIMER_FINISH_MAIN   = "<<1>> Rapport", -- Screen top notification
    CC_NOTIFICATION_TIMER_FINISH_SECOND = "<<1>>",         -- Screen bottom notification
    CC_CHAT_TIMER_FINISH                = "You can now perform \"<<1>>\" with <<2>>.",
    CC_CHAT_TIMER_START                 = "Reminder for \"<<1>>\" set in <<2>>.",
    CC_CHAT_TIMER_CANCEL                = "You have cancelled the \"<<1>>\" reminder.",

    --[[
        Time
    ]]
    CC_TIME_STRING                       = "Reminder in <<1>> <<2>> <<3>> <<4>>", -- Format of time strings e.g. 2 hours
    CC_TIME_SECONDS                      = "seconds",
    CC_TIME_MINUTES                      = "minutes",
    CC_TIME_HOURS                        = "hours",
    CC_TIME_DAYS                         = "days",

    CC_UNKNOWN_TIME                      = "unknown",
    CC_1_MINUTE                          = "1 minute",
    CC_2_MINUTES                         = "2 minutes",
    CC_3_MINUTES                         = "3 minutes",
    CC_5_MINUTES                         = "5 minutes",
    CC_10_MINUTES                        = "10 minutes",
    CC_15_MINUTES                        = "15 minutes",
    CC_30_MINUTES                        = "30 minutes",
    CC_1_HOUR                            = "1 hour",
    CC_2_HOURS                           = "2 hours",
    CC_3_HOURS                           = "3 hours",
    CC_5_HOURS                           = "5 hours",
    CC_20_HOURS                          = "20 hours",
    CC_24_HOURS                          = "daily (24 hours)",
    CC_FIRST_TIME                        = "first time",
    CC_OTHER_TIMES                       = "other times",
    CC_NO_COOLDOWN                       = "no cooldown",
    CC_OFF_COOLDOWN                      = "off cooldown",
    CC_DURING_COOLDOWN                   = "during cooldown",
    CC_SHARED_BASTIAN_MIRRI              = "at 1000 and 2000 rapport",
    CC_SHARED_PERSONAL_QUEST_RAPPORT     = "at 1000, 2000, and 3000 rapport",
    CC_ISOBEL_LEADERS                    = "1 hour (shared with the other leaders rapports)",

    --[[
        Shared
    ]]
    CC_SHARED_COMPLETE_PERSONAL_QUEST  = "Complete a personal quest",
    CC_SHARED_DARK_BROTHERHOOD         = "Enter the Dark Brotherhood Sanctuary in the Gold Coast",
    CC_SHARED_USE_BLADE_OF_WOE_NPC     = "Use the Blade of Woe on any NPC, including enemies",
    CC_SHARED_COMPLETE_MAGES_DAILY     = "Complete a daily Mages Guild quest offered by Alvur Baren",
    CC_SHARED_COMPLETE_ASHLANDER_DAILY = "Complete a daily Ashlander hunt quest",
    CC_SHARED_LOOTING_PSIJIC_PORTAL    = "Loot a Psijic portal",
    CC_SHARED_PICKPOCKET_GUARD         = "Pickpocket a Guard",
    CC_SHARED_MUNDUS_STONE             = "Visit any Mundus Stone",
    CC_SHARED_TRESPASS                 = "Tresspass in a restricted area",
    CC_SHARED_FLEE_GUARD               = "Successfully flee from a guard",
    CC_SHARED_MURDER                   = "Murder an innocent NPC", -- Bastian 1 hour?
    CC_SHARED_HEAVY_SACK               = "Loot a Heavy Sack",

    --[[
        Bastian
    ]]
    -- Good
    CC_GOOD_BASTIAN_TEXT_2 = "Enter a Mages Guild guildhall located within Alliance zones",
    CC_GOOD_BASTIAN_TEXT_3 = "Visit Eyevea or Artaeum",
    CC_GOOD_BASTIAN_TEXT_4 = "Complete a random encounter that helps people (e.g. rescuing merchants from bandits, summoners from Daedra, and travelers during Ambushes)",
    CC_GOOD_BASTIAN_TEXT_6 = "Scry for an antiquity",
    CC_GOOD_BASTIAN_TEXT_7 = "Visit a crafting station", -- Needs to be veryfied (no mention on UESP)
    CC_GOOD_BASTIAN_TEXT_8 = "Read any book",
    CC_GOOD_BASTIAN_TEXT_9 = "Kill a Worm Cultist at the start of a Dark Anchor",
    CC_GOOD_BASTIAN_TEXT_10 = "Kill a bandit",
    CC_GOOD_BASTIAN_TEXT_12 = "Kill any cultist",

    -- Bad
    CC_BAD_BASTIAN_TEXT_1 = "Get caught stealing or pickpocketing",
    CC_BAD_BASTIAN_TEXT_3 = "Pickpocket",
    CC_BAD_BASTIAN_TEXT_5 = "Kill livestock (e.g. chickens, frogs, etc)",
    CC_BAD_BASTIAN_TEXT_6 = "Steal",
    CC_BAD_BASTIAN_TEXT_7 = "Choose the flee option when accosted by a guard",
    CC_BAD_BASTIAN_TEXT_8 = "Cook any food using cheese",
    CC_BAD_BASTIAN_TEXT_9 = "Attack innocent NPCs",



    --[[
        Mirri
    ]]
    -- Good
    CC_GOOD_MIRRI_TEXT_1  = "Complete a daily Ashlander Quest for Numani-Rasi in Vvardenfell",
    CC_GOOD_MIRRI_TEXT_2  = "Complete a daily Fighters Guild quest offered by Cardea Gallus",
    CC_GOOD_MIRRI_TEXT_3  = "View a completed Library of Vivec in Vivec City",
    CC_GOOD_MIRRI_TEXT_4  = "View a completed Kari's Hit List in the Abah's Landing Thieves Den",
    CC_GOOD_MIRRI_TEXT_5  = "Enter a daedric-themed delve or public dungeon (e.g. Ashalmawia, Broken Tusk, Mehrunes' Spite, Sanguine's Demesne, The Cave of Trophies and The Grotto of Depravity)",
    CC_GOOD_MIRRI_TEXT_6  = "Visit the Clockwork City (except Brass Fortress unless through front gate)",
    CC_GOOD_MIRRI_TEXT_7  = "Excavate an Antiquity",
    CC_GOOD_MIRRI_TEXT_8  = "Talk to Sotha Sil",
    CC_GOOD_MIRRI_TEXT_9  = "View a completed Khajiit of the Moons in Senchal",
    CC_GOOD_MIRRI_TEXT_10 = "View a completed Rithana-di-Renada in Riverhold",
    CC_GOOD_MIRRI_TEXT_11 = "View a completed House of Orsimer Glories in Orsinium",
    CC_GOOD_MIRRI_TEXT_12 = "View a completed Vault of Moawita on Artaeum",
    CC_GOOD_MIRRI_TEXT_14 = "Kill a goblin",
    CC_GOOD_MIRRI_TEXT_15 = "Kill a snake (including critters)",
    CC_GOOD_MIRRI_TEXT_16 = "Craft an alcoholic beverage",
    CC_GOOD_MIRRI_TEXT_17 = "Read a book from a bookshelf",             -- 5:34pm -6:36 -7:36 -9:44 >2hour
    CC_GOOD_MIRRI_TEXT_18 = "Summon the Daemon Chicken non-combat pet", -- TODO
    CC_GOOD_MIRRI_TEXT_19 = "Take all loot from a treasure chest",
    CC_GOOD_MIRRI_TEXT_20 = "Kill a riekling",

    -- Bad
    CC_BAD_MIRRI_TEXT_1 = "Complete a Dark Brotherhood Black Sacrament quest",
    CC_BAD_MIRRI_TEXT_2 = "Collect a torchbug, butterfly or honey bee",


    --[[
        Ember
    ]]
    --
    -- Good
    CC_GOOD_EMBER_TEXT_1  = "Complete a Thieves Guild Heist quest", -- Information taken from UESP and tested by myself (Molusco Aquático)
    CC_GOOD_EMBER_TEXT_2  = "Complete a daily High Isle delve quest offered by Wayllod",
    CC_GOOD_EMBER_TEXT_3  = "Sell a stolen purple-quality item to a Fence",
    CC_GOOD_EMBER_TEXT_4  = "Begin a Black Sacrament", -- Needs checking (got only +1 two days in a row, but remember getting +10 once)
    CC_GOOD_EMBER_TEXT_5  =
    "Choose the Clemency option when accosted by a guard (requires Thieves Guild skill line passive)",
    CC_GOOD_EMBER_TEXT_6  = "Win a Tales of Tribute match",
    CC_GOOD_EMBER_TEXT_8  = "Loot a safebox or Thieves Trove", --10:35 -10:47 - 11:35 > 10
    CC_GOOD_EMBER_TEXT_9  = "Complete a quest from the Tip Board in the Abah's Landing Thieves Den",
    CC_GOOD_EMBER_TEXT_10 = "Use a Counterfeit Pardon Edict",  -- 2:44 4:53 (<2 hours)   4:53 - 5:41 (>1 hour) (Probs 2 hours)
    CC_GOOD_EMBER_TEXT_11 = "Harvest a runestone",
    CC_GOOD_EMBER_TEXT_12 = "Kill wolves",
    CC_GOOD_EMBER_TEXT_13 = "Kill werewolves",
    CC_GOOD_EMBER_TEXT_15 = "Sell a purple-quality item to any NPC vendor",                                -- TODO
    CC_GOOD_EMBER_TEXT_16 = "Enter an Outlaws Refuge or the Abah's Landing Thieves Den",
    CC_GOOD_EMBER_TEXT_17 = "Summon the Witch's Infernal Familiar non-combat pet",
    CC_GOOD_EMBER_TEXT_18 = "Summon the Big-Eared Ginger Kitten non-combat pet",

    -- Bad
    CC_BAD_EMBER_TEXT_1   = "Get caught committing a crime (stealing, pickpocketing, or murdering/attacking an innocent NPC)",
    CC_BAD_EMBER_TEXT_2   = "Willingly pay a bounty when accosted by a guard",
    CC_BAD_EMBER_TEXT_3   = "Get spotted while trespassing in a restricted area",
    CC_BAD_EMBER_TEXT_4   = "Get killed by a guard", -- No mention on the wiki, needs testing
    CC_BAD_EMBER_TEXT_5   = "Start fishing",
    CC_BAD_EMBER_TEXT_6   = "Enter The Halls of Colossus",


    --[[
        Isobel
    ]]
    -- Good
    CC_GOOD_ISOBEL_TEXT_1  = "Kill a delve boss or group dungeon boss (Isobel needs to be present in the group dungeon)",
    CC_GOOD_ISOBEL_TEXT_2  = "Complete a daily Undaunted quest for Bolgrul",
    CC_GOOD_ISOBEL_TEXT_3  = "Complete a daily High Isle world boss quest",
    CC_GOOD_ISOBEL_TEXT_4  = "Kill a world boss",
    CC_GOOD_ISOBEL_TEXT_6  = "Kill a boss-type Daedra (e.g. Harvester)",
    CC_GOOD_ISOBEL_TEXT_7  = "Kill Daedra",
    CC_GOOD_ISOBEL_TEXT_8  = "Craft any sweet food or fruit dishes (e.g. grape preserves)",
    CC_GOOD_ISOBEL_TEXT_9  = "Craft anything at a blacksmithing station",
    CC_GOOD_ISOBEL_TEXT_10 = "Complete a Volcanic Vent in High Isle",
    CC_GOOD_ISOBEL_TEXT_11 = "Visit an Undaunted Enclave",
    CC_GOOD_ISOBEL_TEXT_12 = "Talk to Dagerfall Covenant leader King Emeric",
    CC_GOOD_ISOBEL_TEXT_13 = "Talk to Aldmeri Dominion leader Queen Ayrenn",
    CC_GOOD_ISOBEL_TEXT_14 = "Talk to Ebonheart Pact leader King Jorunn",
    CC_GOOD_ISOBEL_TEXT_15 = "Talk to Lyris Titanborn", -- 6:00 -- 7:00
    CC_GOOD_ISOBEL_TEXT_16 = "Use a repair kit",
    CC_GOOD_ISOBEL_TEXT_17 = "Accept an invitation to a duel from another player",
    CC_GOOD_ISOBEL_TEXT_18 = "Summon the Druadach Mountain Dog or Bravil Retriever non-combat pets",

    -- Bad
    CC_BAD_ISOBEL_TEXT_1   = "Steal, loot a Thieves Trove, or loot the corpse of an innocent NPC",
    CC_BAD_ISOBEL_TEXT_2   = "Enter an Outlaws Refuge or the Abah's Landing Thieves Den",


    --[[
        Sharp-As-Night
    ]]

    -- Good
    CC_GOOD_SHARP_TEXT_2 = "Repair gear (including recharging weapon)",
    CC_GOOD_SHARP_TEXT_3 = "Harvest a plant-based material",
    CC_GOOD_SHARP_TEXT_4 = "Start fishing",
    CC_GOOD_SHARP_TEXT_5 = "Catch a non-common fish",
    CC_GOOD_SHARP_TEXT_6 = "Recharge your Weapon with a Soul Gem",
    CC_GOOD_SHARP_TEXT_9 = "Complete a daily quest for Ordinator Neyln in Necrom",
    CC_GOOD_SHARP_TEXT_10 = "Kill a ghost",
    CC_GOOD_SHARP_TEXT_11 = "Visit any of Hist Tree sapplings located at Ebonheart, Hatching Pools or Haj Uxith",
    CC_GOOD_SHARP_TEXT_12 = "Talking to M'aiq the Liar",
    CC_GOOD_SHARP_TEXT_13 = "Eat a meal",
    CC_GOOD_SHARP_TEXT_14 = "Craft a poison",
    CC_GOOD_SHARP_TEXT_15 = "Kill a Fabricant or Dwarven construct",
    CC_GOOD_SHARP_TEXT_16 = "Dig up a treasure map chest",
    CC_GOOD_SHARP_TEXT_17 = "Obtain a monster trophy",

    -- Bad
    CC_BAD_SHARP_TEXT_1 = "Visit an outfit station",
    CC_BAD_SHARP_TEXT_2 = "Willingly pay a bounty when accosted by a guard",
    CC_BAD_SHARP_TEXT_3 = "Pickpocket a begger, laborer or fisher",
    CC_BAD_SHARP_TEXT_4 = "Destorying an item from inventory or multiple items of the same type worth over 20 gold",
    CC_BAD_SHARP_TEXT_5 = "Let your gear break",


    --[[
        Azandar Al-Cybiades
    ]]

    -- Good
    CC_GOOD_AZANDAR_TEXT_1                    = "Complete a daily Enchanter Writ quest",
    CC_GOOD_AZANDAR_TEXT_16                   = "Complete a daily quest for Ordinator Tilena in Necrom",
    CC_GOOD_AZANDAR_TEXT_3                    = "Scry for an antiquity",
    CC_GOOD_AZANDAR_TEXT_4                    = "Find a lead",
    CC_GOOD_AZANDAR_TEXT_5                    = "Read a lorebook",
    CC_GOOD_AZANDAR_TEXT_6                    = "Activating an Ayleid well (except for Aetherial Wells on Auridon)",
    CC_GOOD_AZANDAR_TEXT_7                    = "Read a new mages guild book",
    CC_GOOD_AZANDAR_TEXT_8                    = "Craft any tea or tea type beverage",
    CC_GOOD_AZANDAR_TEXT_9                    = "Kill mudcrabs, dreughs, chaurus, ogres, trolls, harpies, nix-oxen, or dunerippers",
    CC_GOOD_AZANDAR_TEXT_10                   = "Complete a Master Enchanter Writ",
    CC_GOOD_AZANDAR_TEXT_11                   = "Upgrade an item",
    CC_GOOD_AZANDAR_TEXT_12                   = "Steal treasure of the Magic Curiosities, Maps, Writings or Ritual Objects types",
    CC_GOOD_AZANDAR_TEXT_18                   = "Visit the Brass Fortress, The Hollow City, or Fargrave City District",
    CC_GOOD_AZANDAR_TEXT_19                   = "Complete an Oblivion Portal",
    CC_GOOD_AZANDAR_TEXT_20                   = "Consume any tea type beverage",

    -- Bad
    CC_BAD_AZANDAR_TEXT_1                     = "Visting Artaeum or Eyevea",
    CC_BAD_AZANDAR_TEXT_2                     = "Crafting any coffee or beverage containing coffee", -- > 4
    CC_BAD_AZANDAR_TEXT_3                     = "Harvesting any mushroom",
    CC_BAD_AZANDAR_TEXT_4                     = "Play Tales of Tribute",


    --[[
        Tanlorin
    ]]

    -- Good
    CC_GOOD_TANLORIN_TEXT_1                   = "Complete a daily Alchemy Writ daily quest",
    CC_GOOD_TANLORIN_TEXT_2                   = "Complete a Dark Anchor contract offered by Cardea Gallus in Fighters Guild",
    CC_GOOD_TANLORIN_TEXT_3                   = "Scribe a Spell",
    CC_GOOD_TANLORIN_TEXT_4                   = "Use a Mystery Transformation Verse in the Infinite Archive",
    CC_GOOD_TANLORIN_TEXT_5                   = 'Choose a "Persuade" option in dialogue',
    CC_GOOD_TANLORIN_TEXT_6                   = "Pickpocket an aristocrat",
    CC_GOOD_TANLORIN_TEXT_7                   = "Visit Alinor",
    CC_GOOD_TANLORIN_TEXT_8                   = "Use the Campfire Kit memento",
    CC_GOOD_TANLORIN_TEXT_9                   = "Use the Glanir's Smoke Bomb memento",
    CC_GOOD_TANLORIN_TEXT_10                  = "Drink wine",
    CC_GOOD_TANLORIN_TEXT_11                  = "Successfully lockpick a container or a door",
    CC_GOOD_TANLORIN_TEXT_12                  = "Hide in a basket while trespassing",
    CC_GOOD_TANLORIN_TEXT_13                  = "Use an Ayleid well",
    CC_GOOD_TANLORIN_TEXT_14                  = "Obtain a skyshard",
    CC_GOOD_TANLORIN_TEXT_15                  = "Gain a skill point from obtaining skyshards", -- Possibly from any skill point gain
    CC_GOOD_TANLORIN_TEXT_16                  = "Use the Antiquarian's Eye at a dig site",
    CC_GOOD_TANLORIN_TEXT_17                  = "Obtain a vision in the Infinite Archive",
    CC_GOOD_TANLORIN_TEXT_18                  = "Harvest a flower",
    CC_GOOD_TANLORIN_TEXT_19                  = "Fill a Soul Gem using the Soul Trap Skill or it's morphs",
    CC_GOOD_TANLORIN_TEXT_20                  = "Loot a Scribing script",
    CC_GOOD_TANLORIN_TEXT_21                  = "Complete a a Witches Festival Writ or Imperial Charity Writ",
    CC_GOOD_TANLORIN_TEXT_22                  = "Pet or dance with an animal",
    CC_GOOD_TANLORIN_TEXT_23                  = "Craft a Furnishing",
    CC_GOOD_TANLORIN_TEXT_24                  = "Complete a New Life Festival quest",
    CC_GOOD_TANLORIN_TEXT_25                  = "Learn a furnishing plan",
    CC_GOOD_TANLORIN_TEXT_26                  = "Craft a wine",
    CC_GOOD_TANLORIN_TEXT_27                  = "Mount an Indrik",
    CC_GOOD_TANLORIN_TEXT_28                  = "Kill a hostile daedra",
    CC_GOOD_TANLORIN_TEXT_29                  = "Kill a hostile Maormer (Sea Elf)",
    CC_GOOD_TANLORIN_TEXT_30                  = "Obtain a verse in the Infinite Archive",
    CC_GOOD_TANLORIN_TEXT_31                  = "Loot a Plunder Skull",

    -- Bad
    CC_BAD_TANLORIN_TEXT_1                    = "Visit Artaeum",
    CC_BAD_TANLORIN_TEXT_2                    = "Kill a Gryphon, Indrik, or Chimera",
    CC_BAD_TANLORIN_TEXT_3                    = "Harvest Nirnroot or Crimson Nirnroot",
    CC_BAD_TANLORIN_TEXT_4                    = "Visit a Mages Guild guildhall",
    CC_BAD_TANLORIN_TEXT_5                    = "Read a lorebook",
    CC_BAD_TANLORIN_TEXT_6                    = "Steal treasure of the Children's Toys or Dolls types",

    
    --[[
        Zerith-var
    ]]

    -- Good
    CC_GOOD_ZERITH_TEXT_1                     = "Complete a Defense Force quest offered by Zahari at Grahtwood Northern Gate",
    CC_GOOD_ZERITH_TEXT_2                     = "Complete a Tales of Tribute daily quest",
    CC_GOOD_ZERITH_TEXT_3                     = "Complete an Antiquity that has multiple pieces, such as a Mythic item",
    CC_GOOD_ZERITH_TEXT_4                     = "Complete a Dark Anchor encounter",
    CC_GOOD_ZERITH_TEXT_5                     = "Kill a Dragon",
    CC_GOOD_ZERITH_TEXT_6                     = "Complete a Tales of Tribute match",
    CC_GOOD_ZERITH_TEXT_7                     = "Complete The Demon Weapon or The Halls of Colossus",
    CC_GOOD_ZERITH_TEXT_8                     = "Kill a Marauder in the Infinite Archive",
    CC_GOOD_ZERITH_TEXT_9                     = "Cure yourself of Vampirism",
    CC_GOOD_ZERITH_TEXT_10                    = "Drink a Purifying Bloody Mara",
    CC_GOOD_ZERITH_TEXT_11                    = "Excavate an Antiquity whose codex is incomplete",
    CC_GOOD_ZERITH_TEXT_12                    = "Give to a beggar",
    CC_GOOD_ZERITH_TEXT_13                    = "Heal yourself in combat while below 25%",
    CC_GOOD_ZERITH_TEXT_14                    = "Visit Baandari Trading Post",
    CC_GOOD_ZERITH_TEXT_16                    = "Harvest a water node",
    CC_GOOD_ZERITH_TEXT_17                    = "Defeat Tho'at Replicanum in the Infinite Archive",
    CC_GOOD_ZERITH_TEXT_18                    = "Defeat Aramril in the Infinite Archive",
    CC_GOOD_ZERITH_TEXT_19                    = "Kill an undead enemy (Vampire or Skeleton)",
    CC_GOOD_ZERITH_TEXT_20                    = "Kill a dro-m'Athra",
    CC_GOOD_ZERITH_TEXT_21                    = "Defeat a boss in the Infinite Archive",

    -- Bad
    CC_BAD_ZERITH_TEXT_1                      = "Complete the Scion of the Blood Matron quest to become a vampire",
    CC_BAD_ZERITH_TEXT_2                      = "Infect another player with Vampirism",
    CC_BAD_ZERITH_TEXT_3                      = "Soultrap someone with the Soul Trap skill",
    CC_BAD_ZERITH_TEXT_4                      = "Steal a medicinal, religious, or sentimental item",
    CC_BAD_ZERITH_TEXT_5                      = "Use a Counterfeit Pardon Edict or Leniency Edict",
    CC_BAD_ZERITH_TEXT_6                      = "Fence stolen goods",
    CC_BAD_ZERITH_TEXT_7                      = "Drink a Corrupting Bloody Mara",
    CC_BAD_ZERITH_TEXT_8                      = "Travel to the Hollow City in Coldharbour",
    CC_BAD_ZERITH_TEXT_9                      = "Speak to Cadwell",
    CC_BAD_ZERITH_TEXT_10                     = "Get a bounty",
    CC_BAD_ZERITH_TEXT_11                     = "Equip the Dro-m'Athra skin",
    CC_BAD_ZERITH_TEXT_12                     = "Murder an innocent",
    CC_BAD_ZERITH_TEXT_13                     = "Feed as a vampire, including on hostile NPCs",

    ------------------------
    -- Settings Menu Text --
    ------------------------

    CC_SETTINGS_TITLE                         = "About",
    CC_SETTINGS_MENU_DESCRIPTION              =
    "This addon adds rapport information to the companion overview screen. It also adds notification timers which, when set, will notify you after the allotted time.\n\nThanks to @NextTuesday for help with the English translation.\nThanks to @Baryzard for the French translation.\nThanks to @Neverlands for the German translation.\n\nOriginal AddOn by AnotherORC, updated by Molusco_Aquatico.\n\nIf you have any suggestions, bug reports or new info about the companions, please leave a comment on the AddOn page or PM me directly (Molusco_Aquatico)!",
    CC_SETTINGS_NOTIFICATION_SECTION          = "Notification Options",
    CC_SETTINGS_CHAT_REMINDER_NAME            = "Send reminder to chat",
    CC_SETTINGS_CHAT_REMINDER_TOOLTIP         = "Should the reminder be sent to your chat box?",
    CC_SETTINGS_NOTIFICATION_NAME             = "Send reminder to screen",
    CC_SETTINGS_NOTIFICATION_TOOLTIP          = "Should the reminder popup on your screen?",
    CC_SETTINGS_OTHER_SECTION                 = "Other Options",
    CC_SETTINGS_OTHER_TIMER_S_NAME            = "Notify on timer start",
    CC_SETTINGS_OTHER_TIMER_S_TOOLTIP         = "When you start a timer, should a message be sent to your chat?",
    CC_SETTINGS_OTHER_TIMER_R_NAME            = "Notify on timer reset",
    CC_SETTINGS_OTHER_TIMER_R_TOOLTIP         = "When you reset a timer, should a message be sent to your chat?",
    CC_SETTINGS_OTHER_COUNTDOWN_NAME          = "Show countdowns",
    CC_SETTINGS_OTHER_COUNTDOWN_TOOLTIP       = "Shows the time remaining before a notification.",

    CC_SETTINGS_OTHER_RAPPORT_IN_CHAT_NAME    = "Show rapport in chat",
    CC_SETTINGS_OTHER_RAPPORT_IN_CHAT_TOOLTIP =
    "Should a message be sent to the chat everytime your characters rapport changes?",

    ------------------------
    --   Chat Messages    --
    ------------------------
    CC_CHAT_GAINED_RAPPORT                    = "<<1>> has gained <<2>> rapport.",
    CC_CHAT_LOST_RAPPORT                      = "<<1>> has lost <<2>> rapport."

}

-- Load all the english words in as default
for index, value in pairs(englishStrings) do
    ZO_CreateStringId(index, value)
    SafeAddVersion(index, 1)
end
