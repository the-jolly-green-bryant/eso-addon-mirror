-- =============================================================================
-- === OptimalWeave Language File: English (en.lua)                          ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/en.lua
    Description:        English localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Information & README")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "Global cooldown (GCD) is 1000ms. OptimalWeave helps manage ability queuing based on the selected mode to optimize weaving. Use the settings below to customize its behavior.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Core Mechanics")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Activation Rules")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Advanced Controls")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Performance Settings")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Addon active")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Addon inactive")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "This option is currently disabled")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Warning: High latency values may cause input lag!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Disclaimer|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000Disclaimer:|r This add-on is not created by, affiliated with, or supported by ZeniMax Media Inc. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Core Settings")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Operating Mode")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Sequential:|r Allows ability usage only after a Light Attack has been performed.\n|cFF0000Strict:|r Strict blocking. No skill queuing during GCD.\n|cFFFF00Intelligent:|r Smart blocking. Skill queuing allowed only if no Light Attack is queued.\n|c00FFFFDisabled:|r Disabled.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Sequential")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Strict")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Intelligent")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Disabled")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Active Only in Combat")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "If checked, OptimalWeave will only manage ability queuing while in combat.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Active Only with Hostile Target")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Requires a hostile target to manage queuing.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Ignore While Blocking")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Disables controls during blocking.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Block Ground Ability Double Cast")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Prevents accidental double-casting of ground-targeted abilities.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Disable as Tank")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Auto-disable when Tank role is active")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Disable as Healer")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Auto-disable when Healer role is active")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Disable features on backbar")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Disables most addon features on the backbar.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Disable weave assist on backbar")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Disables the weave assist (GCD management) on the backbar.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "PvP Deactivation")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Disable features in PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Disables most addon features in PvP areas")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Disable weave assist in PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Disables the weave assist (GCD management) in PvP areas")

ZO_CreateStringId("OW_MENU_BLOCKAOEIFNOTARGET_LABEL", "Block AoE Without Target")
ZO_CreateStringId("OW_MENU_BLOCKAOEIFNOTARGET_TOOLTIP", "Blocks ground-targeted abilities when no target is selected")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Blocked Abilities")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Block New ID")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Enter an Ability ID (e.g., 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "Currently Blocked IDs")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Click to remove")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Instant Cast Buffer (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Safety margin for instant abilities (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Channeled Buffer (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Buffer for channeled skills (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "GCD Tracking Slot")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Action bar slot for GCD detection (3-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Min GCD Threshold (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Minimum GCD duration to recognize (0-20ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Base Queue Time (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Default input queue window (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Reset on bar swap")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Resets the GCD on bar swap")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Reset on dodge roll")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Resets the GCD on Dodge roll")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Reset time (seconds)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Resets tracking after not casting anything for this many seconds.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Auto GCD Tracking Slot")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Automatically select the best GCD tracking slot from slots 3-8")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Auto-Draw Weapon")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Automatically draw weapons when in combat")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Reset All")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Reset all settings to default values")
ZO_CreateStringId("OW_MENU_DYNAMIC_QUEUE_TIME_LABEL", "Dynamic Queue Time (GCD)")
ZO_CreateStringId("OW_MENU_DYNAMIC_QUEUE_TIME_TOOLTIP", "Uses the current GCD (1000 ms) instead of the fixed value.")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Latency Compensation")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Automatic Latency Adjustment")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Automatically adjust timing based on current latency. Recommended for stable connections.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Manual Input Latency (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Fixed latency value (0-200ms). Only used when automatic mode is disabled.")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

-- == Grim Focus SETTINGS ======================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Class and Guild Specific Settings")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Grim Focus")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Required Stacks")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Number of stacks required before Grim Focus becomes activatable (recommended: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Block All Grim Focus Morphs")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Relentless Focus:|r Always blocked\n|cFFFF00• Grim Focus and Merciless Resolve:|r Only usable at 10 stacks\n|cAAAAAADisable:|r Default behavior for all morphs")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Enable Custom Stacks")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Enabled:|r Uses custom stack setting \n" ..
                  "|cAAAAAADisabled:|r Always blocks Grim Focus and Merciless Resolve up to 10 stacks, and always blocks Relentless Focus\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Guilds")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Block Fighter's Guild Hunter Skills")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Blocks all morphs of Fighter's Guild hunter skills (Expert Hunter, Camouflaged Hunter & Evil Hunter)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Block Mage's Guild Light Skills")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Blocks all morphs of Light skills (Magelight, Inner Light & Radiant Magelight)")   

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "Disable in PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Disables Hunter/Light ability blocking in PvP areas")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Molten Whip")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Block Molten Whip Skill")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Blocks the Molten Whip skill to prevent losing the three stacks")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Arcanist Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Block Fatecarver Casting")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Prevent casting Fatecarver until conditions are met.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Required Crux Stacks")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Minimum Crux stacks before Fatecarver can be cast (Recommended: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "HP Threshold (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Disable Fatecarver blocking when HP is below this value")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Enable HP check for Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Disables Fatecarver blocking when your health is low")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Stamina Threshold (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Disable Fatecarver blocking when Stamina is below this value")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Enable Stamina check for Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Disables Fatecarver blocking when your stamina is low")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Cephaliarch's Flail")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Block Cephaliarch's Flail")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Block Cephaliarch's Flail when you have 3 Crux stacks")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Block Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Blocks the Tentacular Dread skill until conditions are met.")


-- == Execute Check Settings ================================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Execute Check")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Enable Execute Check")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Enable or disable the execute check feature")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Execute Threshold (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Target health percentage below which execute spells are allowed")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Execute Spells")

-- == Grouped Execute Spells ================================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Radiant Destruction, Radiant Glory, Radiant Oppression")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Block Radiant Destruction morphs until target is in execute range")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Assassin's Blade, Impale, Killer's Blade")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Block Assassin's Blade morphs until target is in execute range")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Mages' Wrath, Mages' Fury, Endless Fury")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Block Mages' Fury morphs until target is in execute range")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Reverse Slash, Reverse Slice, Executioner")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Block Reverse Slash morphs until target is in execute range")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Deactivate Based on Weapon Type")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Disable Weave Assist on Weapon Type")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Disables only the weave assist (GCD management) for selected weapon types")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Disable Features on Weapon Type")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Disables most addon features for selected weapon types")

-- One-handed weapons
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Axe")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Deactivate when axe is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Hammer")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Deactivate when hammer is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Sword")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Deactivate when sword is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Dagger")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Deactivate when dagger is equipped")

-- Two-handed weapons
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Two-Handed Sword")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Deactivate when two-handed sword is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Two-Handed Axe")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Deactivate when two-handed axe is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Two-Handed Hammer")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Deactivate when two-handed hammer is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Bow")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Deactivate when bow is equipped")

-- Staves
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Fire Staff")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Deactivate when fire staff is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Frost Staff")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Deactivate when frost staff is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Lightning Staff")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Deactivate when lightning staff is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Healing Staff")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Deactivate when healing staff is equipped")

-- Other weapons
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Shield")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Deactivate when shield is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Rune")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Deactivate when rune is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "No Weapon")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Deactivate when no weapon is equipped")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Reserved Weapon")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Deactivate when reserved weapon type is equipped")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Custom Block Lists")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Custom Block List")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Add spell IDs to block them from being used. You can also add spells by right-clicking on the action bar slot (requires reload)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "Spell ID")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Enter the numeric spell ID (e.g., 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Add to Block List")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Blocked Spells:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Enable Custom Block List")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Enable or disable the custom block list functionality")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Check your SavedVariables file:\n customBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Enable Health Check for Block List")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "When enabled, spells in the block list will only be blocked if your health is above the threshold.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Health Threshold for Block List (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Block list spells are only blocked when your health is above this percentage.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Custom Recast Block List")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Add spell IDs to block them from being recast until the remaining effect time is below the threshold. You can also add spells by right-clicking on the action bar slot (requires reload).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "Spell ID")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Enter the numeric spell ID (e.g., 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Add to Recast Block List")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Recast Blocked Spells:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Enable Custom Recast Block List")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Enable or disable the custom recast block list functionality")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Recast Block Time (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Time in seconds below which a spell in the recast block list can be cast again (1.0 = 1 second)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Check your SavedVariables file:\n customRecastBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Enable Health Check for Recast Block List")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "When enabled, spells in the recast block list will only be blocked if your health is above the threshold.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Health Threshold for Recast Block List (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Recast block list spells are only blocked when your health is above this percentage.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "Spell ID has been added/removed. If you do not want to add any more spells, please reload the UI so that the spells can be displayed")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Reload UI")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Later")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Error: Please enter a valid spell ID")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "Spell ID does not exist")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT",  "Spell ID is already in the block list")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Resource-Based Block List")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Add spell IDs to block them when your primary resource (Magicka or Stamina) is below the threshold. You can also add spells by right-clicking on the action bar slot (requires reload).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Enable Resource-Based Block List")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Enable or disable the resource-based block list functionality")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Enable Resource Check")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "When enabled, spells in the resource block list will only be blocked if your primary resource (Magicka or Stamina) is above the threshold.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Resource Threshold (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Resource block list spells are only blocked when your primary resource (Magicka or Stamina) is above this percentage.")

ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Spell: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Magicka Check")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Enable magicka-based blocking for this spell")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Block when Magicka below threshold")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Block spell when magicka is below threshold (uncheck to allow only when below)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Magicka Threshold (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Magicka percentage threshold")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Stamina Check")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Enable stamina-based blocking for this spell")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Block when Stamina below threshold")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Block spell when stamina is below threshold (uncheck to allow only when below)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Stamina Threshold (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Stamina percentage threshold")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Toggle Mode (Strict/Intelligent/Disabled)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Toggle Custom Block List")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Toggle Custom Recast Block List")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Toggle Backbar Features Deactivation")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Toggle Backbar Weave Assist Deactivation")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Toggle Execute Check")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Remove")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Remove this spell from the block list (/reloadui required)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Settings Mode")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Choose whether settings are shared across all characters on this account (Account-wide) or stored separately for each character (Per Character).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Account-wide")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Per Character")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "Settings mode changed. Reload UI to apply changes?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Block Last Menu in combat")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Prevents opening the last menu (ALT) while in combat.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Block Character Menu in combat")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Prevents opening the character menu (c) while in combat.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Show Global Cooldown (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Displays the GCD indicator (provided by ZOS) above the action bar.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Blocklists only in Combat")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "All custom block lists are only active while you are in combat. Outside of combat, all block lists are disabled.")

-- =============================================================================
-- === END OF ENGLISH LOCALIZATION =============================================
-- =============================================================================