-- en.lua
ZO_CreateStringId("SI_SYNERGY_ALERT_UPDATE_INFO", "Please review your Advanced Synergy block add-on settings!")
ZO_CreateStringId("SI_SYNERGY_ALERT_UPDATE_TOP", "Update")
ZO_CreateStringId("SI_SYNERGY_CHAT_PRESET_INFO", "Print Preset Loaded info into Chat")

-- preset (account wide)
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_EB", "Presets – Synergy Configuration")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_EB_I", "Export or import your settings for the currently selected preset.")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_IMP", "Import synergy settings")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_W", "Import settings and overwrite the currently selected preset?")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE", "Preset")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_H", "Preset (account-wide)")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_N", "Preset name:")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_S", "Selected preset:")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_B_S", "Add new preset")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_B_D", "Delete selected preset")
ZO_CreateStringId("SI_SYNERGY_NAME_PRE_B_L", "Load selected preset")
ZO_CreateStringId("SI_SYNERGY_ERROR_NOTDELETE", "Preset [Default] cannot be deleted!")
ZO_CreateStringId("SI_SYNERGY_ERROR_DELETE", "Preset does not exist!")
ZO_CreateStringId("SI_SYNERGY_INFO_RELOAD", "This will force a ReloadUI!")
ZO_CreateStringId("SI_SYNERGY_NAME_HOTBAR", "Hotbar settings")

-- base (char bound)
ZO_CreateStringId("SI_SYNERGY_NAME_BASE", "Block synergy settings (character-bound)")
ZO_CreateStringId("SI_SYNERGY_NAME_BAR", "Synergy only on primary hotbar")
ZO_CreateStringId("SI_SYNERGY_NAME_USEPVP", "Use this add-on in PvP?")
ZO_CreateStringId("SI_SYNERGY_NAME_LOKKE_CHECK", "Check for Lokke set 5-piece bonus")
ZO_CreateStringId("SI_SYNERGY_NAME_LOKKE_INFO", "The \"Primary hotbar\" option is not required!\nIf Lokke is not equipped, this option is ignored.")
ZO_CreateStringId("SI_SYNERGY_NAME_ALKOSH_CHECK", "Check for Alkosh set 5-piece bonus")
ZO_CreateStringId("SI_SYNERGY_NAME_ALKOSH_INFO", "The \"Primary hotbar\" option is not required!\nIf Alkosh is not equipped, this option is ignored.")
ZO_CreateStringId("SI_SYNERGY_NAME_ONLY_COMBAT", "Synergy only during combat")
ZO_CreateStringId("SI_SYNERGY_INFO_ONLY_COMBAT", "Synergies can only be used in combat. (Does not work in ready check)")
ZO_CreateStringId("SI_SYNERGY_NAME_BERSERK", "Automatically block Atro synergy")
ZO_CreateStringId("SI_SYNERGY_INFO_BERSERK", "Automatically blocks the Atro synergy while the \"Major Berserk\" buff is active.")
ZO_CreateStringId("SI_SYNERGY_NAME_ONLY_OUT_COMBAT", "Synergy only out of combat")
ZO_CreateStringId("SI_SYNERGY_INFO_ONLY_OUT_COMBAT", "Synergies can only be used out of combat.")

-- submenu names
ZO_CreateStringId("SI_SYNERGY_NAME_CLASSES", "Class synergies")
ZO_CreateStringId("SI_SYNERGY_NAME_RAID", "Trial synergies")
ZO_CreateStringId("SI_SYNERGY_NAME_TRANSFORM", "Transformations (Werewolf & Vampire)")
ZO_CreateStringId("SI_SYNERGY_NAME_ITEMS", "Armor set synergies")

-- Resources 
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE", "Resources")
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE_ENABLE", "Enable resource check")
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE_SLIDER", "Resource threshold")
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE_SLIDER_M", "Magicka threshold")
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE_SLIDER_S", "Stamina threshold")
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE_TIP", "If you fall below the threshold (of your maximum Stamina/Magicka), unblocked synergies become available again.")
ZO_CreateStringId("SI_SYNERGY_NAME_RESOURCE_TIP_SET", "If these sets are equipped, resource checking is enabled.")

-- Alkosh
ZO_CreateStringId("SI_SYNERGY_NAME_ALKOSH", "Alkosh settings")
ZO_CreateStringId("SI_SYNERGY_ALKOSHUI", "Enable Alkosh UI")
ZO_CreateStringId("SI_SYNERGY_ALKOSH_LIST", "Alkosh list")
ZO_CreateStringId("SI_SYNERGY_ALKOSH_COUNT", "Min. "..(MAX_BOSSES-1).." = Bosses only")
ZO_CreateStringId("SI_SYNERGY_SOUND_VOLL", "Volume")
ZO_CreateStringId("SI_SYNERGY_SOUND_TEST", "Test sound")
ZO_CreateStringId("SI_SYNERGY_UI_MARK_BOSS", " (bosses only)")
ZO_CreateStringId("SI_SYNERGY_ALKOSH_PRINT", "Show Alkosh value in chat")
ZO_CreateStringId("SI_SYNERGY_ALKOSH_PRINT_INFO", "Displays the Alkosh value in chat after the fight.")
ZO_CreateStringId("SI_SYNERGY_ALKOSHUI_AUTO", "Auto-enable Alkosh UI")
ZO_CreateStringId("SI_SYNERGY_ALKOSHUI_AUTO_DESC", "Automatically enable the UI when you have Alkosh slotted.")
ZO_CreateStringId("SI_SYNERGY_NAME_ALKOSH_REAPPLY", "Allow reapply")
ZO_CreateStringId("SI_SYNERGY_NAME_ALKOSH_REAPPLY_TIP", "Allows refreshing the Alkosh debuff XX seconds before it expires.")

-- Target Tracking
ZO_CreateStringId("SI_SYNERGY_TARGET_ENABLE", "Enable target tracking")
ZO_CreateStringId("SI_SYNERGY_TARGET_ACCOUNT", "Use account name?")
ZO_CreateStringId("SI_SYNERGY_TARGET_PGROUP", "Current players in group")
ZO_CreateStringId("SI_SYNERGY_TARGET_BUTTON_ADD", "Add player to tracking")
ZO_CreateStringId("SI_SYNERGY_TARGET_BUTTON_REMOVE", "Remove player from tracking")
ZO_CreateStringId("SI_SYNERGY_TARGET_ENABLE_CHAR", "Enable target tracking for this player")

-- synergy tooltip
ZO_CreateStringId("SI_SYNERGY_TOOLTIP", "ON = synergy can be used!")
ZO_CreateStringId("SI_SYNERGY_IGNORE", "Ignore checks")
ZO_CreateStringId("SI_SYNERGY_IGNORE_TT", "Ignores in-combat, hotbar, Lokke, Alkosh, and resource checks for this synergy.")
ZO_CreateStringId("SI_SYNERGY_MI_HOTBAR_INFO", "Use synergy only on a specific hotbar. ALL = All, PRIMARY = \"Primary hotbar\", BACKUP = \"Secondary hotbar\"")

-- Major Slayer UI
ZO_CreateStringId("SI_SYNERGY_NAME_MSLAYER", "Major Slayer settings")
ZO_CreateStringId("SI_SYNERGY_MSLAYERUI", "Enable Major Slayer UI")
ZO_CreateStringId("SI_SYNERGY_SLAYER_DNAME", "Show name")
ZO_CreateStringId("SI_SYNERGY_SLAYER_DICON", "Show icon")
ZO_CreateStringId("SI_SYNERGY_SLAYER_HIDE", "Hide when buff is inactive")

-- UI Settings
ZO_CreateStringId("SI_SYNERGY_SETTING_ACC", "Use account-wide settings")
ZO_CreateStringId("SI_SYNERGY_MENU_NAME", "Advanced Synergy")
ZO_CreateStringId("SI_SYNERGY_NAME_SOUND_ON_OFF", "Play sound")
ZO_CreateStringId("SI_SYNERGY_NAME_SOUND_CHOOSE", "Choose sound")
ZO_CreateStringId("SI_SYNERGY_NAME_SOUND_TIME", "Play at x seconds remaining / marker position")
ZO_CreateStringId("SI_SYNERGY_UI_WIDTH", "UI width")
ZO_CreateStringId("SI_SYNERGY_UI_HIGHT", "UI height")
ZO_CreateStringId("SI_SYNERGY_UI_HIGHT_MAX", "UI height Total")
ZO_CreateStringId("SI_SYNERGY_UI_ALPHA", "UI transparency")
ZO_CreateStringId("SI_SYNERGY_UI_SHOW", "Show UI")
ZO_CreateStringId("SI_SYNERGY_UI_MARK", "Show marker")
ZO_CreateStringId("SI_SYNERGY_UI_MARK_DESC", "A thin marker indicating when you want to refresh the buff.")
ZO_CreateStringId("SI_SYNERGY_UI_RESET", "Reset UI")
ZO_CreateStringId("SI_SYNERGY_UI_LOCK", "Lock UI")
ZO_CreateStringId("SI_SYNERGY_UI_NAME_WWPLUGIN", "Enable WW plugin")
ZO_CreateStringId("SI_SYNERGY_UI_DESC_WWPLUGIN", "Requires Reload UI! Enables the Wizard's Wardrobe integration to load presets.")

ZO_CreateStringId("SI_SYNERGY_CB_ENABLE_S", "Auto-enable after xx seconds")
ZO_CreateStringId("SI_SYNERGY_CB_ENABLE_TT_S", "Automatically enable the synergy after xx seconds")
ZO_CreateStringId("SI_SYNERGY_CB_ENABLE_MS", "Auto-enable after xx ms")
ZO_CreateStringId("SI_SYNERGY_CB_ENABLE_TT_MS", "Automatically enable the synergy after xx ms")
ZO_CreateStringId("SI_SYNERGY_CB_ENABLE_STACKS", "Auto-enable after xx stacks")
ZO_CreateStringId("SI_SYNERGY_CB_ENABLE_TT_STACKS", "Automatically enable the synergy after xx stacks")
ZO_CreateStringId("SI_SYNERGY_CB_ALERT_BLOP", "Show warning to drop the blob")
ZO_CreateStringId("SI_SYNERGY_CB_ALERT_BLOP_TT", "")

-- UI Tracking
ZO_CreateStringId("SI_SYNERGY_UI_TRACK_SETTINGS", "Tracking settings")
ZO_CreateStringId("SI_SYNERGY_UI_TRACK_ENABLE", "Enable tracking")
ZO_CreateStringId("SI_SYNERGY_UI_TRACK_ORIENT", "Orientation")
ZO_CreateStringId("SI_SYNERGY_UI_TRACK_SIZE", "Size")
ZO_CreateStringId("SI_SYNERGY_UI_TRACK_SIZE_OUTLINE", "Background size")
ZO_CreateStringId("SI_SYNERGY_UI_TRACK_ONLY_ACTIVE", "Only show Active cooldowns")

-- UI Priority
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_KNOWN", "Known synergies")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_UNKNOWN", "No known synergies")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_REMOVE", "Remove selected")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_ADD", "Add selected")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_NS", "No synergies in preset")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_APP" , "Priority groups (active preset)")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_SPO" , "Synergy Priority Override")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_UI" , "Show current Synergy UI")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_MENU" , "Synergy priority settings")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_PRIO_TITLE_ADD", "Add new group")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_PRIO_TEXT", "Enter a unique name for the new group:")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_PRIO_ALERT", "Group name already exists!")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_PRIO_SELECT_TITLE", "Selected group")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_NO_GROUPS", "No groups defined")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_NO_GROUPS_A", "No groups available")
ZO_CreateStringId("SI_SYNERGY_UI_PRIO_UI_NAME", "Current Synergys")

------------------------------------------------------------------------------
-- Undaunted
------------------------------------------------------------------------------
ZO_CreateStringId("SI_SYNERGY_NAME_TREE_UNDAUNTED", "Undaunted")

------------------------------------------------------------------------------
-- Trials
------------------------------------------------------------------------------
ZO_CreateStringId("SI_SYNERGY_DEBUFF_TRAIL_CR", "Auto-block while debuffed")
ZO_CreateStringId("SI_SYNERGY_DEBUFF_TRAIL_CR_DESC", "Blocks the synergy while you have the debuff and re-enables it when it fades.")

-- Trial HRC
ZO_CreateStringId("SI_SYNERGY_ALERT_HRC", "Press Confirm to enable the synergy")
ZO_CreateStringId("SI_SYNERGY_NAME_DESTRUCTIVE_OUTBREAK", "Outbreak confirmation dialog")

-- Menu 
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_BLOCK", "Synergy Blocking")
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_ALKOSH", "Alkosh")
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_SLAYER", "Slayer")
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_TRACKING", "Tracking")
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_GTRACKING", "Group Tracking")
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_TTRACKING", "Target Tracking")
ZO_CreateStringId("SI_SYNERGY_MENU_TITLE_PRIORITY", "Priority")
