local companionStr = GetString(SI_UNIT_FRAME_NAME_COMPANION)
local companionKeybindBaseStr = "Show/hide " .. companionStr

local stringsEN = {
    FCOCO_NO_COMPANION_UNLOCKED_YET                         = "[FCOCompanion]You did not unlock any " .. GetString(SI_UNIT_FRAME_NAME_COMPANION) .. " yet. Please finish and turn in any of the unlock quests first and reload the UI afterwards!",
    --FCOCO_SHOW_COMPANION_MENU                             = "Show \'" .. GetString(SI_INTERACT_OPTION_COMPANION_MENU) .. "\'",
    FCOCO_TOGGLE_COMPANION                                  = companionKeybindBaseStr .. " (last)",

    --LAM Settings
    FCOCO_LAM_SV_MODE                                       = 'Settings save mode',
    FCOCO_LAM_SV_MODE_TT                                    = 'Use account wide settings (the same for all your characters) or save them individually for each character?',
    FCOCO_LAM_SV_EACH_CHARACTER                             = "Each character",
    FCOCO_LAM_SV_ACCOUNT_WIDE                               = "Account wide",

    FCOCO_LAM_SETTING_HEADER_JUNK                           = GetString(SI_ITEMTYPEDISPLAYCATEGORY9),
    FCOCO_LAM_SETTING_ENABLE_ACCOUNT_WIDE_JUNK              = "Enable account wide Companion junk",
    FCOCO_LAM_SETTING_ENABLE_ACCOUNT_WIDE_JUNK_TT           = "Enable this to make the Companion junk items and settings saved account-wide. If disabled each character can use it's own settings.",
    FCOCO_LAM_SETTING_ENABLE_JUNK                           = "Companion items->junk",
    FCOCO_LAM_SETTING_ENABLE_JUNK_TT                        = "Enable this to add the contextmenu entry \'Add to junk\' to companion items. If marked as junk they will be shown at the Junk tab in your inventory then.",
    FCOCO_LAM_SETTING_AUTO_JUNK_SAME_ITEMS                  = "Auto-mark same items in bags",
    FCOCO_LAM_SETTING_AUTO_JUNK_SAME_ITEMS_TT               = "Automatially detect if you got the same companion item, that you currently mark/unmark as junk, multiple times in your same bag, and apply/remove the junk mark on these too.",
    FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC                   = "Migr. Junk Char.->Acc.",
    FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC_TT                = "Attention: Migrate the currently saved character's Companion Junk items to the account. This will try to merge the saved Companion Junk items which weren't already added to the account wide companion junk items.",
    FCOCO_LAM_JUNK_MIGRATE_TO_ACC_STR                       = "Migrated %s from character to account wide companion junk",
    FCOCO_LAM_JUNK_MIGRATE_TO_ACC_TOTAL_STR                 = "%s items migrated from character to account wide companion junk",

    FCOCO_LAM_SETTING_HEADER_CRAFTING                       = GetString(SI_SKILLTYPE8),
    FCOCO_LAM_SETTING_UNSUMMON_AT_CRAFTING_TABLE            = "Dismiss at crafting table",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CRAFTING_TABLE_TT         = "Hide your active companion if you interact with a crafting table",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CRAFTING_TABLE         = "Re-summon after crafting table",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CRAFTING_TABLE_TT      = "Summon your last active companion again after leaving the crafting table",

    FCOCO_LAM_SETTING_HEADER_BANKS                          = GetString(SI_CURRENCYLOCATION1),
    FCOCO_LAM_SETTING_UNSUMMON_AT_BANK                      = "Dismiss at bank",
    FCOCO_LAM_SETTING_UNSUMMON_AT_BANK_TT                   = "Hide your active companion if you interact with a bank",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_BANK                   = "Re-summon after bank",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_BANK_TT                = "Summon your last active companion again after leaving the bank",

    FCOCO_LAM_SETTING_HEADER_VENDORS                        = GetString(SI_MAPDISPLAYFILTER2),
    FCOCO_LAM_SETTING_UNSUMMON_AT_VENDOR                    = "Dismiss at vendor/fence",
    FCOCO_LAM_SETTING_UNSUMMON_AT_VENDOR_TT                 = "Hide your active companion if you interact with a vendor/fence",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_VENDOR                 = "Re-summon after vendor/fence",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_VENDOR_TT              = "Summon your last active companion again after leaving the vendor/fence",

    FCOCO_LAM_SETTING_HEADER_FISHING                        = GetString(SI_GUILDACTIVITYATTRIBUTEVALUE9),
    FCOCO_LAM_SETTING_UNSUMMON_AT_FISHING                   = "Dismiss at Fish hole",
    FCOCO_LAM_SETTING_UNSUMMON_AT_FISHING_TT                = "Hide your active companion if you interact with a fish hole",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING                = "Re-summon after fishing",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_TT             = "Summon your last active companion again after leaving the fish hole.\n\'Leaving the fish hole\' means at the end of a fishing attempt, after the delay of milliseconds you setup below. If a new fishing attempt is started before the delay was met, the re-summon will be aborted.",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_DELAY          = "Re-summon delay after fishing",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_DELAY_TT       = "Delay the re-summoning after ending the fishing hole interaction with this milliseconds value (1000 = 1 second)",

    FCOCO_LAM_SETTING_HEADER_CROUCH                         = GetString(SI_BINDING_NAME_SPECIAL_MOVE_CROUCH),
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING                 = "Dismiss at crouching",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_TT              = "Hide your active companion if you start to crouch",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_NO_COMBAT       = "Not in combat",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_NO_COMBAT_TT    = "Only hide the companion if you are not in combat, as you start to crouch",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING              = "Re-summon after crouching",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_TT           = "Summon your last active companion again after leaving the crouched state.\n\'Leaving the crouched state\' means as you get unhidden or stop to crouch the delay of milliseconds you setup below will be waited until the re-summon takes place. If you start to crouch again before the delay was met, the re-summon will be aborted.",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_DELAY        = "Re-summon delay after crouching",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_DELAY_TT     = "Delay the re-summoning after end of crouching with this milliseconds value (1000 = 1 second)",

    
    FCOCO_LAM_SETTING_HEADER_COMPASS                        = GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1304),
    FCOCO_LAM_SETTING_DISABLE_PIN_AT_COMPASS                = "Disable pin at compass",
    FCOCO_LAM_SETTING_DISABLE_PIN_AT_COMPASS_TT             = "Disable the companion's pin at the compass",
}

local companionInfo = FCOCO.companionInfo
for companionDefId, companionCollectibleId in pairs(companionInfo) do
    --local companionCollectibleId = GetCompanionCollectibleId(companionDefId)
    if companionCollectibleId ~= nil then
        local companionName = GetCollectibleName(companionCollectibleId)
        local companionNameClean = ZO_CachedStrFormat(SI_UNIT_NAME, companionName)
        stringsEN["FCOCO_TOGGLE_COMPANION_" .. tostring(companionDefId)]     = companionKeybindBaseStr .. ": \'" .. companionNameClean .. "\'"
    end
end

for stringId, stringValue in pairs(stringsEN) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end