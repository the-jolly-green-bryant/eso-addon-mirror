local Register = LibCombatAlerts.RegisterString

Register("SI_CA_TITLE"                          , "Combat Alerts")

Register("SI_CA_MODULE_LOAD"                    , "Loaded module [<<1>>].")
Register("SI_CA_MODULE_UNLOAD"                  , "Unloaded module [<<1>>].")
Register("SI_CA_CORRUPTED"                      , "|cFF0000ERROR:|r Your installation of Combat Alerts appears to be corrupted, likely due to a bad Minion update. |cFF0000You must delete and reinstall the addon.|r")

Register("SI_CA_PURGEABLE_EFFECTS"              , "Purgeable Effects")
Register("SI_CA_NEARBY"                         , "Nearby Players")
Register("SI_CA_NEARBY_EMPTY"                   , "No Players Nearby")

Register("SI_CA_SETTINGS_SUPPRESS"              , "Suppress module load and unload messages")
Register("SI_CA_SETTINGS_DISABLE_ANNOYING"      , "Suppress annoying base-game messages")
Register("SI_CA_SETTINGS_BYPASS_PURGE_CHECK"    , "Always track purgeable effects")
Register("SI_CA_SETTINGS_BYPASS_PURGE_CHECK_TT" , "By default, the group-wide tracking of purgeable effects is disabled if the player does not have an AoE purge ability slotted; enabling this option will bypass that requirement.")
Register("SI_CA_SETTINGS_NEARBY"                , "Show nearby players")

Register("SI_CA_SETTINGS_MODULES"               , "Modules")
Register("SI_CA_SETTINGS_MODULE_INFO"           , "Zones: <<1>>\nAuthor: <<2>>")
Register("SI_CA_SETTINGS_MODULE_ABILITY"        , "Enable alert for <<1>>")
Register("SI_CA_SETTINGS_MODULE_ABILITY_NEARBY" , "Enable alert for nearby <<1>>")
Register("SI_CA_SETTINGS_MODULE_RAID_LEAD"      , "Enable raid lead mode")
Register("SI_CA_SETTINGS_MODULE_RAID_LEAD_TT"   , "Normally, some alerts are visible only to certain relevant players; this is done to reduce the distraction of irrelevant alerts.\n\nEnabling this mode will bypass these limitations and is intended to help with providing guidance to other players.")

Register("SI_CA_SETTINGS_REPOSITION"            , "Reposition UI Elements")
Register("SI_CA_SETTINGS_MOVE_ELEMENTS"         , "Reposition elements")
Register("SI_CA_SETTINGS_MOVE_ELEMENTS_TT"      , "A number of UI elements can be moved at any time using your mouse, without using the settings panel. However, most UI elements are hidden outside of combat, and this will allow you to reposition UI elements outside of combat.")
Register("SI_CA_SETTINGS_RESET_ELEMENTS"        , "Reset all elements")
Register("SI_CA_SETTINGS_GAMEPAD_MOVE"          , "Start reposition")
Register("SI_CA_SETTINGS_GAMEPAD_MOVE_TT"       , "This starts movement mode.\n\nUse the right stick <<1>> to move the panel.\n\nSpeed is scaled with stick position, so for small precise movements, use a light touch.\n\nAfter 3s of no movement input, movement mode will end.")

Register("SI_CA_MOVE_STATUS"                    , "Status Panel")
Register("SI_CA_MOVE_GROUP_PANEL"               , "Group Panel")
Register("SI_CA_MOVE_NEARBY"                    , "Nearby")

Register("SI_CA_LEGACY_HOF"                     , "The “Halls of Fabrication Status Panel” addon has been retired and should be uninstalled; its features have been merged into this addon.")
