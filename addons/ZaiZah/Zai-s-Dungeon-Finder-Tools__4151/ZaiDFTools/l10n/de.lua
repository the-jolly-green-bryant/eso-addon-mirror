------------------------------------------------------------------------------------------------------------------
-- German (de)
-- Format and phrasing by ZaiZah
-- German is not my native language, this is largely done with what i know, Google Translate and ChatGPT
-- so please let me know if you have any suggestions.
-- version 1.0
------------------------------------------------------------------------------------------------------------------
-- Every variable must start with this addon's unique ID, as each is a global. 
-- BGMT_
local strings = {
    -- Addon name
    ["ZDFT_NAME"] = "Zai's Verlies-Finder-Tools",

    -- Error Strings
    ["ZDFT_INVALID_DUNGEON_DATA"] = "Ungültige Verlies-Daten",
    ["ZDFT_INVALID_DUNGEON_DATA_TEXT"] = "Ungültige Verlies-Daten",
    ["ZDFT_COULD_NOT_FIND_FILTER"] = "Filter-Dropdown nicht gefunden",
    ["ZDFT_COULD_NOT_ACCESS_DROPDOWN"] = "Dropdown-Elemente nicht zugänglich",

    -- Dungeon Types
    ["ZDFT_DLC_DUNGEON_TEXT"] = "DLC-Verlies",
    ["ZDFT_BASE_GAME_TEXT"] = "Basisspiel",

    -- Difficulty Types
    ["ZDFT_NORMAL_VETERAN"] = "Normal und Veteran",

    -- Achievement Categories
    ["ZDFT_VETERAN_ACHIEVEMENTS_TEXT"] = "Veteran-Errungenschaften",
    ["ZDFT_TRIFECTA_TEXT"] = "Trifecta",
    ["ZDFT_HARDMODE_TEXT"] = "Schwerer Modus",
    ["ZDFT_SPEEDRUN_TEXT"] = "Speedrun",
    ["ZDFT_NODEATH_TEXT"] = "Kein Tod",
    ["ZDFT_ALL_3_VETERAN"] = "Alle 3 Veteran-Errungenschaften",
    
    -- Pledge Givers
    ["ZDFT_MAJ_AL_RAGATH"] = "Maj al-Ragath",
    ["ZDFT_GLIRION_REDBEARD"] = "Glirion der Rotbart",
    ["ZDFT_URGARLAG_CHIEF"] = "Urgarlag Häuptlingsfluch",
    
    -- Pledge Quest Status
    ["ZDFT_DAILY_PLEDGE"] = "Täglicher Schwur",
    ["ZDFT_TODAYS_PLEDGE_QUESTS"] = "Heutige Schwur-Quests",
    ["ZDFT_TODAYS_PLEDGE_STATUS"] = "Heutiger Schwur-Status",
    ["ZDFT_READY_TO_TURN_IN"] = "Bereit zur Abgabe",
    ["ZDFT_QUEST_IN_PROGRESS"] = "Quest läuft",
    ["ZDFT_ALREADY_COMPLETED_TODAY"] = "Heute bereits abgeschlossen",
    ["ZDFT_AVAILABLE_TO_ACCEPT"] = "Verfügbar zum Annehmen",
    ["ZDFT_NO_ACTIVE_QUEST"] = "Keine aktive Quest",
    
    -- Pledge Actions & Results
    ["ZDFT_SELECT_PLEDGES_BUTTON"] = "Heutige Schwüre auswählen",
    ["ZDFT_NO_PLEDGES_FOUND"] = "Keine Schwüre für den gewählten Schwierigkeitsgrad gefunden.",
    ["ZDFT_NO_PLEDGES_FOUND_TEXT"] = "Keine Schwüre für den gewählten Schwierigkeitsgrad gefunden.",
    ["ZDFT_SELECTED_PLEDGES_FORMAT"] = "%d %s Schwüre ausgewählt",
    ["ZDFT_DESELECTED_PLEDGES_TEXT"] = "%d Schwüre abgewählt",

    -- Collections
    ["ZDFT_SETTINGS_COLLECTIONS"] = "Sammlungen",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON"] = "Sammlungs-Schaltfläche anzeigen",
    ["ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON_TT"] = "Schaltfläche anzeigen um schnell Verliese mit unvollständigen Set-Teilen oder Motiv-Sammlungen auszuwählen",
    ["ZDFT_SETTINGS_COLLECTION_TYPE"] = "Sammlungstyp",
    ["ZDFT_SETTINGS_COLLECTION_TYPE_TT"] = "Wählen Sie aus, welche Art von Sammlungen bei der Auswahl von Verliesen überprüft werden sollen",
    ["ZDFT_SETTINGS_COLLECTION_SETS"] = "Set-Teile",
    ["ZDFT_SETTINGS_COLLECTION_MOTIFS"] = "Motiv-Stile",
    ["ZDFT_SETTINGS_COLLECTION_BOTH"] = "Beides",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY"] = "Schwierigkeitsgrad der Sammlungs-Schaltfläche",
    ["ZDFT_SETTINGS_COLLECTION_DIFFICULTY_TT"] = "Wählen Sie aus, welche Schwierigkeitsgrade für Sammlungen ausgewählt werden sollen",
    
    -- Collection Button Text and Messages
    ["ZDFT_SELECT_COLLECTIONS_BUTTON"] = "Sammlungen auswählen",
    ["ZDFT_SELECT_COLLECTIONS_BUTTON_FORMAT"] = "Wählen Sie %s aus",
    ["ZDFT_SETS_TEXT"] = "Sets",
    ["ZDFT_MOTIFS_TEXT"] = "Motivs",

    -- Collection Button Alert Messages
    ["ZDFT_NO_COLLECTIONS_FOUND_TEXT"] = "Keine Verliese mit unvollständigen %s gefunden",
    ["ZDFT_DESELECTED_COLLECTIONS_TEXT"] = "Abgewählte %d Sammlungen",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT"] = "Ausgewählte %d %s Verliese mit unvollständigen Sammlungen",
    ["ZDFT_SELECTED_COLLECTIONS_FORMAT_NO_DIFFICULTY"] = "Ausgewählte %d Verliese mit unvollständigen %s",

    -- Color Legend
    ["ZDFT_COLOR_LEGEND_TITLE"] = "Schwur-Farblegende",
    ["ZDFT_COLOR_LEGEND_BLUE"] = "Blau: Verfügbar zum Annehmen",
    ["ZDFT_COLOR_LEGEND_ORANGE"] = "Orange: Quest läuft",
    ["ZDFT_COLOR_LEGEND_GREEN"] = "Grün: Bereit zur Abgabe",
    ["ZDFT_COLOR_LEGEND_GREY"] = "Grau: Heute bereits abgeschlossen",
    
    -- Settings - Achievement Icons
    ["ZDFT_SETTINGS_ACHIEVEMENT_ICONS"] = "Errungenschaften-Symbole",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA"] = "Trifecta-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_TRIFECTA_TT"] = "Trifecta-Errungenschaften-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_HARDMODE"] = "Schwerer Modus-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_HARDMODE_TT"] = "Schwerer Modus-Errungenschaften-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_NODEATH"] = "Kein Tod-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_NODEATH_TT"] = "Kein Tod-Errungenschaften-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN"] = "Speedrun-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_SPEEDRUN_TT"] = "Speedrun-Errungenschaften-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_CLEARED"] = "Abgeschlossen-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_CLEARED_TT"] = "Verlies-Abschluss-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_MOTIF"] = "Motiv-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_MOTIF_TT"] = "Motiv-Errungenschaften-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_SET"] = "Set-Sammlungs-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_SET_TT"] = "Set-Sammlungs-Icon anzeigen",

    -- Settings - Pledge
    ["ZDFT_SETTINGS_PLEDGE"] = "Schwur-Einstellungen",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES"] = "Schwur-Verliese hervorheben",
    ["ZDFT_SETTINGS_HIGHLIGHT_PLEDGES_TT"] = "Schwur-Verlies-Namen farbig markieren um ihren Status anzuzeigen",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON"] = "Schwur-Symbol anzeigen",
    ["ZDFT_SETTINGS_SHOW_PLEDGE_ICON_TT"] = "Unerschrockenen-Schlüssel-Symbol neben Schwur-Verliesen anzeigen",
    
    -- Settings - UI
    ["ZDFT_SETTINGS_UI"] = "UI-Einstellungen",
    ["ZDFT_SETTINGS_SHOW_BUTTON"] = "'Heutige Schwüre auswählen'-Schaltfläche anzeigen",
    ["ZDFT_SETTINGS_SHOW_BUTTON_TT"] = "Schaltfläche anzeigen um automatisch heutige Schwüre auszuwählen",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY"] = "Schwur-Schwierigkeitsgrad",
    ["ZDFT_SETTINGS_PLEDGE_DIFFICULTY_TT"] = "Welcher Schwierigkeitsgrad beim Auswählen von Schwüren verwendet werden soll",
    ["ZDFT_SETTINGS_FOLLOW_FINDER"] = "Gruppen-Finder folgen",
    ["ZDFT_SETTINGS_ALWAYS_NORMAL"] = "Immer Normal",
    ["ZDFT_SETTINGS_ALWAYS_VETERAN"] = "Immer Veteran",
    ["ZDFT_SETTINGS_BOTH_DIFFICULTIES"] = "Beide Schwierigkeitsgrade",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue, 1)
end