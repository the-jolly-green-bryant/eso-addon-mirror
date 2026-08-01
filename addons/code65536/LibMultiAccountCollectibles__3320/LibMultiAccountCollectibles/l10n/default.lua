local Register = LibCodesCommonCode.RegisterString

Register("SI_LMAC_SETTINGS_CHATCOMMAND"    , "This addon settings panel can also be accessed via the |c00CCFF/lmac|r chat command.")

Register("SI_LMAC_SETTINGS_SHARE_SECTION"  , "Share Account Data")
Register("SI_LMAC_SETTINGS_SHARE_CAPTION"  , "Export and copy, or paste and import, to share data")
Register("SI_LMAC_SETTINGS_SHARE_EXPORTC"  , "Export Current")
Register("SI_LMAC_SETTINGS_SHARE_EXPORTCT" , "Export item set collection data for the current account")
Register("SI_LMAC_SETTINGS_SHARE_EXPORTA"  , "Export All")
Register("SI_LMAC_SETTINGS_SHARE_EXPORTAT" , "Export item set collection data for every saved account")
Register("SI_LMAC_SETTINGS_SHARE_EXPORTS"  , "Export Selected (%d)")
Register("SI_LMAC_SETTINGS_SHARE_EXPORTST" , "Export item set collection data for the accounts listed below")
Register("SI_LMAC_SETTINGS_SHARE_IMPORT"   , "Import")
Register("SI_LMAC_SETTINGS_SHARE_CLEAR"    , "Clear")
Register("SI_LMAC_SETTINGS_SHARE_SELECT"   , "Accounts Selected for Export")
Register("SI_LMAC_SETTINGS_SHARE_SELECTT"  , "List of account names, separated by commas, for \"Export Selected\"")

Register("SI_LMAC_SETTINGS_DELETE_SECTION" , "Delete Account Data")
Register("SI_LMAC_SETTINGS_DELETE_BUTTON"  , "Delete")
Register("SI_LMAC_SETTINGS_DELETE_WARNING" , "This will delete all of the accumulated data for all accounts and reload the UI.")

Register("SI_LMAC_SETTINGS_NOSAVE_SECTION" , "Excluded Accounts")
Register("SI_LMAC_SETTINGS_NOSAVE_CAPTION" , "List of account names, separated by commas, to exclude from being saved")

Register("SI_LMAC_SHARE_EXPORT_LIMIT"      , "Skipped [<<1>>/<<2>>]; data limit reached.")
Register("SI_LMAC_SHARE_IMPORT_STALE"      , "Skipped [<<1>>/<<2>>]; current data is more recent.")
Register("SI_LMAC_SHARE_IMPORT_DONE"       , "Imported [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LMAC_SHARE_IMPORT_INVALID"    , "Aborting import; corrupted data encountered.")
Register("SI_LMAC_SHARE_IMPORT_BADVERSION" , "Imported data was encoded by an incompatible version of LibMultiAccountCollectibles; please ensure that both users have updated to the latest version of LibMultiAccountCollectibles.")
Register("SI_LMAC_SHARE_IMPORT_NEWACCOUNT" , "You have imported one or more new accounts that did not previously exist in the database; |c00CCFF/reloadui|r may be necessary for newly-added accounts to appear in menus and settings.")
Register("SI_LMAC_SHARE_IMPORT_TALLY"      , "<<1>> accounts imported.")

Register("SI_MACTT_TITLE"                  , "Multi-Account Collectibles Tooltip Extension")
Register("SI_MACTT_ENABLE_SETTING"         , "Show accounts in item tooltips")
Register("SI_MACTT_MULTI_SERVER"           , "Show all servers")
Register("SI_MACTT_COLLECTED_BY"           , "Collected By")

Register("SI_MACAF_COLLECTIBLE"            , "Collectible")
Register("SI_MACAF_ANY_ACCOUNT"            , "(Any)")
