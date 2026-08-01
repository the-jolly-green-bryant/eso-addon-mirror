local Register = LibCodesCommonCode.RegisterString

Register("SI_LQS_SETTINGS_CHATCOMMAND"    , "This addon settings panel can also be accessed via the |c00CCFF/lqs|r chat command.")

Register("SI_LQS_SETTINGS_SHARE_SECTION"  , "Data Export/Import")
Register("SI_LQS_SETTINGS_SHARE_CAPTION"  , "Export and copy, or paste and import, to share data")
Register("SI_LQS_SETTINGS_SHARE_EXPORTC"  , "Export Current")
Register("SI_LQS_SETTINGS_SHARE_EXPORTCT" , "Export item set collection data for the current character")
Register("SI_LQS_SETTINGS_SHARE_EXPORTA"  , "Export All")
Register("SI_LQS_SETTINGS_SHARE_EXPORTAT" , "Export item set collection data for every saved character")
Register("SI_LQS_SETTINGS_SHARE_IMPORT"   , "Import")
Register("SI_LQS_SETTINGS_SHARE_CLEAR"    , "Clear")

Register("SI_LQS_SETTINGS_RESET_SECTION"  , "Reset Data")
Register("SI_LQS_SETTINGS_RESET_WARNING"  , "This will reset all settings, delete all data associated with LibQuestStatus, and reload the UI.")

Register("SI_LQS_SETTINGS_NOSAVE_SECTION" , "Excluded Accounts")
Register("SI_LQS_SETTINGS_NOSAVE_CAPTION" , "List of account names, separated by commas, to exclude from being saved")

Register("SI_LQS_SHARE_EXPORT_LIMIT"      , "Skipped [<<1>>/<<2>>]; data limit reached.")
Register("SI_LQS_SHARE_IMPORT_STALE"      , "Skipped [<<1>>/<<2>>]; current data is more recent.")
Register("SI_LQS_SHARE_IMPORT_DONE"       , "Imported [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LQS_SHARE_IMPORT_INVALID"    , "Aborting import; corrupted data encountered.")
Register("SI_LQS_SHARE_IMPORT_BADVERSION" , "Imported data was encoded by an incompatible version of LibQuestStatus; please ensure that both users have updated to the latest version of LibQuestStatus.")
Register("SI_LQS_SHARE_IMPORT_TALLY"      , "<<1>> characters imported.")
