local Register = LibCodesCommonCode.RegisterString

Register("SI_CK_TITLE"                    , "Character Knowledge")

Register("SI_CK_HEADER_NAME"              , "Name")
Register("SI_CK_HEADER_QUALITY"           , "Quality")
Register("SI_CK_HEADER_KNOWN"             , "Known")
Register("SI_CK_HEADER_CHARACTERS"        , "Characters")

Register("SI_CK_SINGLE_ACCOUNT"           , "Single-account mode")
Register("SI_CK_KNOWN_COUNT"              , "%d / %d known (%d%%)")

Register("SI_CK_GRIMOIRE_FILTER"          , "Filter for Compatible Scripts")
Register("SI_CK_LINK_RESULT"              , "Link Result in Chat")

Register("SI_CK_TT_HEADER"                , "Known By")
Register("SI_CK_TT_HEADER_RESULT"         , "Craftable By")

Register("SI_CK_AF_PLUGIN_LEARNABLE"      , "Learnable")
Register("SI_CK_AF_PLUGIN_UNKNOWN"        , "Unknown")
Register("SI_CK_AF_PLUGIN_RECIPE_LEVEL"   , "Recipe Level")
Register("SI_CK_AF_PLUGIN_ANY"            , "(Anyone)")

Register("SI_CK_LEARN_KEYBIND"            , "Learn Items")
Register("SI_CK_LEARNED_MESSAGE"          , "Items learned: <<1>>")

Register("SI_CK_SETTINGS_DESCRIPTION"     , "Data management and settings for character tracking and priority ranking are handled in a |c00FFCC|H0:cklck|hseparate settings panel|h|r.")

Register("SI_CK_SETTINGS_SECTION_TTCHAP"  , "Tooltips: Motif Chapters")
Register("SI_CK_SETTINGS_SECTION_TTCHAR"  , "Tooltips: Characters")
Register("SI_CK_SETTINGS_SECTION_TTEXT"   , "External Tooltips")

Register("SI_CK_SETTINGS_SETTING_PINNED"  , "Pinned characters")
Register("SI_CK_SETTINGS_TOOLTIP_PINNED"  , "For chaptered motifs, chapter knowledge information for the current character will be shown in the tooltips. Additionally, information for the highest-priority characters will be shown as well. For example, a setting of 2 will show chapter knowledge information for up to three characters: the two highest-priority characters and the current character.")
Register("SI_CK_SETTINGS_SETTING_KNOWN"   , "Known")
Register("SI_CK_SETTINGS_SETTING_UNKNOWN" , "Unknown")
Register("SI_CK_SETTINGS_SETTING_NODATA"  , "No Data")
Register("SI_CK_SETTINGS_SETTING_TT"      , "Add information to external item tooltips")
Register("SI_CK_SETTINGS_SETTING_SCRIPT"  , "Show detailed scribing script information")
Register("SI_CK_SETTINGS_SETTING_RGRIDFL" , "Flag other characters in grid cells")
Register("SI_CK_SETTINGS_TOOLTIP_RGRIDFL" , "This will place a flag in the corner of each research grid cell if the trait can be researched by tracked characters other than the currently-selected character.\n\nAdditionally, the flag's color indicates the percentage of characters who have learned the trait.")

Register("SI_CK_WELCOME"                  , "You have installed |cCC33FFCharacter Knowledge|r. Please take a moment to look over the |c00FFCC|H0:cklck|hdata settings|h|r to adjust character priority and tracking. The |c00FFCC|H0:ckbrowser|hsearchable browser|h|r can be accessed by opening the Extended Journal or via the |c00CCFF/characterknowledge|r (or |c00CCFF/ck|r) chat command.")
