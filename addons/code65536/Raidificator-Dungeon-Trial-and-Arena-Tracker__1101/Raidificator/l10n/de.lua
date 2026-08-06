-- Translated by: @ninibini

local Register = LibCodesCommonCode.RegisterString

Register("SI_RCR_SUBTITLE_HISTORY"        , "Ergebnishistorie")

Register("SI_RCR_MESSAGE_TRIAL_START"     , "<<1>> gestartet; die ParZeit ist <<2>> Minuten.")
Register("SI_RCR_MESSAGE_TRIAL_END"       , "<<1>> mit einem Punktestand von <<2>> und Vitalitätsbonus von <<3>> beendet. Die benötigte Zeit war <<4>>. Das ist <<7>> <<5>> der ParZeit von <<6>> Minuten.  [|c00FFCC|H0:rcr|hHistorie öffnen|h|r]")
Register("SI_RCR_MESSAGE_TRIAL_END1"      , "unter")
Register("SI_RCR_MESSAGE_TRIAL_END2"      , "über")
Register("SI_RCR_MESSAGE_OBSOLETE"        , "|cFF0000Warnung:|r Bitte das Addon „<<1>>“ deinstallieren. Das Addon „<<1>>“ ist obsolete und wird nicht weiter entwickelt, da es in Raidificator integriert wurde.")

Register("SI_RCR_HEADER_TIMESTAMP"        , "Datum")
Register("SI_RCR_HEADER_CHARACTER"        , "Charakter")
Register("SI_RCR_HEADER_SCORE"            , "Punkte")
Register("SI_RCR_HEADER_DURATION"         , "Dauer")
Register("SI_RCR_HEADER_CLEAR"            , "Clear")

Register("SI_RCR_COMPLETED_COUNT"         , "%d / %d abgeschlossen (%d%%)")
Register("SI_RCR_LINK_INCOMPLETE"         , "Nicht abgeschlossene im Chat einfügen")

Register("SI_RCR_ALL_ACCOUNTS"            , "Alle Accounts")
Register("SI_RCR_GROUP_MEMBERS"           , "Gruppenmitglieder")

Register("SI_RCR_FILTER_HIDE_ARC_1"       , "Schleife 1 verbergen")
Register("SI_RCR_FILTER_PLEDGES"          , "Heutige Gelöbnisse")

Register("SI_RCR_DTR_TITLE"               , "Gruppe neu formieren")
Register("SI_RCR_DTR_SLASH_CONFIRM"       , "Bist Du sicher, dass Du die Gruppe auflösen und neu formieren möchtest?")
Register("SI_RCR_DTR_DISCOVERY"           , "Du kannst den Chat-Befehl |c00CCFF/reformgroup|r oder eine benutzerdefinierte Tastenkombination verwenden, um eine Instanz zurückzusetzen, indem du die Gruppe auflöst und neu bildest.")
Register("SI_BINDING_NAME_RCR_REFORM"     , "Raidificator: Gruppe neu formieren")

Register("SI_RCR_KEYBIND_CONFIRM"         , "%s: zur Bestätigung, diesen Befehl noch %d mal in den nächsten %0.1fs eingeben.")

Register("SI_RCR_PLEDGES"                 , "Gelöbnisse der Unerschrockenen")
Register("SI_RCR_PLEDGES_ACTIVE"          , "Gelöbnis angenommen")
Register("SI_RCR_PLEDGES_AVAILABLE_SP"    , "Fertigkeitspunkt verfügbar")
Register("SI_RCR_PLEDGES_AVAILABLE_PL"    , "<<1>> ist verfügbar")

Register("SI_RCR_QUEST_COOLDOWN"          , "Auf Cooldown")

Register("SI_RCR_SECTION_STATUS"          , "Statuszeile")
Register("SI_RCR_SETTING_BGCOLOR"         , "Hintergrundfarbe")

Register("SI_RCR_SECTION_LOGGING"         , "Protokollierung mit ESO Logs")
Register("SI_RCR_SETTING_LOG_DUNGEON"     , "Vet Verliese automatisch prokollieren")
Register("SI_RCR_SETTING_LOG_TRIAL"       , "Vet Prüfungen und Arenas automatisch prokollieren")
Register("SI_RCR_SETTING_LOG_ENDLESS"     , "Endloses Archiv automatisch prokollieren")

Register("SI_RCR_SECTION_QUESTS"          , "Annahme von gestarteten Quests")
Register("SI_RCR_SETTING_QUESTS_DUNGEONS" , "Quests von Verliesen")
Register("SI_RCR_SETTING_QUESTS_TRIALS"   , "Quests von Prüfungen")
Register("SI_RCR_SETTING_QUESTS_ARENAS"   , "Quests von Arenas und Endlosen Archiv")
Register("SI_RCR_SETTING_QUEST_ACTION0"   , "Nichts machen")
Register("SI_RCR_SETTING_QUEST_ACTION1"   , "Immer annehmen")
Register("SI_RCR_SETTING_QUEST_ACTION2"   , "Immer ablehnen")

Register("SI_RCR_SECTION_CASTS"           , "Versehentliche Casts von Fähigkeiten")
Register("SI_RCR_SETTING_CASTS_TEXT"      , "Wenn diese Funktion aktiviert ist, verhindert sie das Wirken bestimmter Fähigkeiten, die nur für ihren passiven Slot-Bonus eingesetzt werden.\n\nDiese Funktion ist nur aktiv, wenn sich der Spieler in einer Instanz, einer Prüfung oder einer Arena im Kampf befindet.\n\nBetroffene Fähigkeiten: <<1>>")
