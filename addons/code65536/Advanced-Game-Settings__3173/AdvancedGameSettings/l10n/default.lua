local Register = ZO_CreateStringId

Register("SI_ADVSET_TITLE"         , "Advanced Game Settings")

Register("SI_ADVSET_PREAMBLE"      , "Changes made to these settings will persist on this computer (in UserSettings.txt) even if the Advanced Game Settings addon is disabled or uninstalled.\n\nThis addon settings panel can also be accessed via the |c00CCFF/advset|r chat command.")
Register("SI_ADVSET_FRAMECAP"      , "Set a maximum frame rate limit")
Register("SI_ADVSET_FRAMECAP_TT"   , "Frame rates will be uncapped if no limit is set. This limit will also affect the login and character select screens.\n\nNote: Changes to the frame rate limit will persist permanently only after logging out to character select.\n\nDefault: Off")
Register("SI_ADVSET_SKIPLOGOS"     , "Skip startup logos")
Register("SI_ADVSET_SKIPLOGOS_TT"  , "This will take the user directly to the login screen when the game is launched.\n\nDefault: Off")
Register("SI_ADVSET_SUSTAIN"       , "Energy sustainability measures")
Register("SI_ADVSET_DETAILMAP"     , "Disable detail texture maps")
Register("SI_ADVSET_DETAILMAP_TT"  , "Some users find Felms' Manifest Wrath to be more conspicuous with detail texture maps disabled.\n\nDefault: Off")
Register("SI_ADVSET_LANGUAGE"      , GetString("SI_GUILDMETADATAATTRIBUTE", GUILD_META_DATA_ATTRIBUTE_LANGUAGES))
Register("SI_ADVSET_LANGUAGE_TT"   , "This will change the game-wide client language.\n\nNote: Languages marked by (*) are usually not available and will not work for most game clients.")
Register("SI_ADVSET_LANGUAGE_WARN" , "Changing the language will reload your UI.")
