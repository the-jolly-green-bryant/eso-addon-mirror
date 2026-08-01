local strings = {
    SI_ACTIVITY_FINDER_PLUS_LANG            = "en",

    SI_ACTIVITY_FINDER_PLUS_HEADER_LFG    = "Ready Check",
    SI_ACTIVITY_FINDER_PLUS_HEADER_FINDER = "Activity Finder",
    SI_ACTIVITY_FINDER_PLUS_HEADER_OTHER  = "Other",

    SI_ACTIVITY_FINDER_PLUS_SOUND           = "Enhanced Sound",
    SI_ACTIVITY_FINDER_PLUS_SCREEN          = "Enhanced Visuals",
    SI_ACTIVITY_FINDER_PLUS_ENHANCE         = "Enhanced Activity Finder",
    SI_ACTIVITY_FINDER_PLUS_ACCEPT          = "Auto-Accept Ready Checks",
    SI_ACTIVITY_FINDER_PLUS_RELEASE         = "Auto-Release in Battlegrounds",
    SI_ACTIVITY_FINDER_PLUS_DELAY           = "Sound Notification Delay",

    SI_ACTIVITY_FINDER_PLUS_LFG_CHAT        = "Ready Check!",
    SI_ACTIVITY_FINDER_PLUS_LFG_CHAT_A      = "Ready check auto-accepted!",
    SI_ACTIVITY_FINDER_PLUS_LFG_SCREEN      = "Group Ready Check!",

    SI_ACTIVITY_FINDER_PLUS_SOUND_TT        = "Play a louder, repeating sound when a ready check appears.",
    SI_ACTIVITY_FINDER_PLUS_SCREEN_TT       = "Show a large on-screen alert when a ready check appears.",
    SI_ACTIVITY_FINDER_PLUS_ENHANCE_TT      = "Show pledge and quest status, set collection progress, and achievement icons. Adds quick-select buttons for pledges, skill quests, and incomplete sets. On gamepad, assign Quick Select under Controls > Activity Finder (only active in the dungeon finder), or use /afpqs.",
    SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION  = "Set Collection Progress",
    SI_ACTIVITY_FINDER_PLUS_SET_COLLECTION_TT = "Show unlocked and total set collection pieces for each dungeon. Requires LibSets.",
    SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE = "Achievement Info in Separate Window",
    SI_ACTIVITY_FINDER_PLUS_KEYBOARD_TOOLTIP_MODE_TT = "Keyboard mode only. When checked, dungeon achievement info shows in its own window below the game's tooltip, avoiding overlap with other addons. When unchecked, it's written directly into the game's tooltip instead, which may overlap with other addons that also customize it (e.g. DungeonTracker).",
    SI_ACTIVITY_FINDER_PLUS_ACCEPT_TT       = "Automatically accept the ready check when a group is found.",
    SI_ACTIVITY_FINDER_PLUS_RELEASE_TT      = "Automatically release after dying in a Battleground.",
    SI_ACTIVITY_FINDER_PLUS_SLASH_TT        = "Slash commands:\nSettings  /afp\nQuick select  /afpqs\nDaily pledges  /pl  /pledge\nLeave group  /lv  /leave",
    SI_ACTIVITY_FINDER_PLUS_DELAY_TT        = "Seconds between repeated sound notifications during a ready check.",

    SI_ACTIVITY_FINDER_PLUS_PLEDGE_DAILY    = "Pledge",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_QUEST    = "Quest",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_DONE     = "Done",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_SLASH    = "DAILY PLEDGES",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC1     = "Maj al-Ragath",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC2     = "Glirion the Redbeard",
    SI_ACTIVITY_FINDER_PLUS_PLEDGE_NPC3     = "Urgarlag Chief-bane",
    SI_ACTIVITY_FINDER_PLUS_CHECK_QUESTS    = "Check Active Quests",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SETS      = "Check Incomplete Sets",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS = "Select Incomplete Quests",
    SI_ACTIVITY_FINDER_PLUS_CHECK_SKILL_QUESTS_TT = "Select dungeons for which the current character has not yet completed the skill point quest.",
    SI_ACTIVITY_FINDER_PLUS_QUICK_SELECT    = "Quick Select",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_LABEL = "Veteran Mode",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE    = "Veteran Mode:",
    SI_ACTIVITY_FINDER_PLUS_VETERAN_MODE_TT = "When checked, quick-select buttons target veteran dungeons instead of normal.",
    SI_ACTIVITY_FINDER_PLUS_ACHIEVEMENTS_HEADER = "Veteran Challenges",
    SI_ACTIVITY_FINDER_PLUS_VET_CLEAR       = "Veteran Clear",
    SI_ACTIVITY_FINDER_PLUS_NORMAL_CLEAR    = "Normal Clear",

    SI_BINDING_NAME_ACTIVITY_FINDER_PLUS_QUICK_SELECT = "Quick Select",
    SI_KEYBINDINGS_LAYER_ACTIVITY_FINDER_PLUS       = "Activity Finder",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
