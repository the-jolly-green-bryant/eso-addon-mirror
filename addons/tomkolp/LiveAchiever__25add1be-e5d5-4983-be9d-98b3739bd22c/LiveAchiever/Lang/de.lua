if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.de = {
    -- HUD
    HUD_Title = "Verfolgte Erfolge",
    HUD_Completed = "Abgeschlossen",
    HUD_Crit_Default = "Kriterium",
    Btn_Add_Tooltip = "Kürzlich aktualisierte Erfolge hinzufügen",
    History_Instruction = "Klicken zum Verfolgen:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Gebietsleitfaden-Erfolge",
    Zone_Panel_Empty = "Alle Erfolge abgeschlossen.",
    
    -- Chat Messages
    Chat_Update = "Update:",
    Chat_Track_Btn = "[Fortschritt verfolgen]",
    Chat_Progress_InProgress = "Fortschritt: In Arbeit",
    
    -- Status Messages
    Msg_Track_Stop = "Verfolgung gestoppt.",
    Msg_Track_Start = "Verfolgung gestartet.",
    Msg_Pos_Reset = "LiveAchiever: Position zurückgesetzt.",
    Msg_List_Cleared = "LiveAchiever: Liste geleert.",
    Msg_Time_Set = "LiveAchiever: Zählzeit gesetzt auf: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Benachrichtigungen",
    Settings_Time_Label = "Zeitraum der Zusammenfassung",
    Settings_Time_Tooltip = "Wie lange Fortschritte zusammengefasst werden (z. B. +5). Der Zähler verschwindet nach dieser Zeit.",
    Settings_Section_Manage = "Verwaltung",
    Settings_Hide_Combat_Label = "Im Kampf verbergen",
    Settings_Hide_Combat_Tooltip = "Das Tracker-Fenster automatisch verbergen, wenn Sie den Kampf betreten.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Horizontale Position (X)",
    Settings_Slider_X_Tooltip = "Bewegt das Fenster nach links/rechts. Nützlich im Gamepad-Modus.",
    Settings_Slider_Y_Label = "Vertikale Position (Y)",
    Settings_Slider_Y_Tooltip = "Bewegt das Fenster nach oben/unten. Nützlich im Gamepad-Modus.",
    
    Settings_Reset_Pos = "HUD Position",
    Settings_Reset_Pos_Btn = "Position zurücksetzen",
    Settings_Clear_List = "Verfolgungsliste",
    Settings_Clear_List_Btn = "Alles löschen",
    
    -- Window Context Menu
    Menu_ResetPos = "Position zurücksetzen",

    -- Context Menu
    Menu_Track = "Verfolgen (LiveAchiever)",
    Menu_StopTrack = "Verfolgung stoppen (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[VERFOLGT]|r",
    Nav_History = "|cFFFF00[HISTORIE]|r",
    Nav_Action_Remove = "|cFF0000(Entfernen)|r",
    Nav_Action_Add = "|c00FF00(Hinzufügen)|r",
    Hist_Prev = "< Zurück",
    Hist_Next = "Weiter >",
    
    -- Time Options
    Time_Opt_1 = "1. drei Sekunden",
    Time_Opt_2 = "2. zehn Sekunden",
    Time_Opt_3 = "3. eine Minute",
    Time_Opt_4 = "4. zwei Minuten",
    Time_Opt_5 = "5. fünf Minuten",
    Time_Opt_6 = "6. zehn Minuten",
    Time_Opt_7 = "7. zwanzig Minuten",
    Time_Opt_8 = "8. dreißig Minuten",
    Time_Opt_9 = "9. eine Stunde",
    Time_Opt_10 = "10. zwei Stunden",
    
    -- Positioning Mode
    Settings_Unlock_Label = "Fenster entsperren (Positionierung)",
    Settings_Unlock_Tooltip = "Zeigt das Fenster in Menüs an. WICHTIG: Deaktivieren Sie dies nach der Positionierung, damit das Fenster in Menüs wieder ausgeblendet wird.",
    
    -- Aussehen & Gamepad
    Settings_Section_Appearance = "Aussehen",
    Settings_Font_Label = "Schriftgröße",
    Settings_Font_Tooltip = "Passt die Textgröße an (Bereich: 6-28).",
    Settings_Alpha_Label = "Hintergrundtransparenz",
    Settings_Alpha_Tooltip = "Passt die Transparenz des Hintergrunds an (0% = unsichtbar).",
    Menu_Btn_Press = "Rechten Stick drücken",
    Menu_No_History = "(Keine Updates)",
}