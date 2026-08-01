if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.it = {
    -- HUD
    HUD_Title = "Imprese Tracciate",
    HUD_Completed = "Completato",
    HUD_Crit_Default = "Criterio",
    Btn_Add_Tooltip = "Aggiungi imprese aggiornate di recente",
    History_Instruction = "Clicca per tracciare:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Imprese Guida Zona",
    Zone_Panel_Empty = "Tutte le imprese completate.",
    
    -- Chat Messages
    Chat_Update = "Aggiornamento:",
    Chat_Track_Btn = "[Traccia]",
    Chat_Progress_InProgress = "Progresso: In corso",
    
    -- Status Messages
    Msg_Track_Stop = "Tracciamento fermato.",
    Msg_Track_Start = "Tracciamento avviato.",
    Msg_Pos_Reset = "LiveAchiever: Posizione reimpostata.",
    Msg_List_Cleared = "LiveAchiever: Lista svuotata.",
    Msg_Time_Set = "LiveAchiever: Tempo di accumulo impostato a: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Notifiche",
    Settings_Time_Label = "Tempo accumulo progressi",
    Settings_Time_Tooltip = "Per quanto tempo i progressi devono essere sommati (es. +5). Il contatore sparirà dopo questo tempo.",
    Settings_Section_Manage = "Gestione",
    Settings_Hide_Combat_Label = "Nascondi in combattimento",
    Settings_Hide_Combat_Tooltip = "Nascondi automaticamente la finestra di tracciamento quando entri in combattimento.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Posizione Orizzontale (X)",
    Settings_Slider_X_Tooltip = "Sposta la finestra a sinistra/destra. Utile in modalità Gamepad.",
    Settings_Slider_Y_Label = "Posizione Verticale (Y)",
    Settings_Slider_Y_Tooltip = "Sposta la finestra su/giù. Utile in modalità Gamepad.",
    
    Settings_Reset_Pos = "Posizione HUD",
    Settings_Reset_Pos_Btn = "Reimposta",
    Settings_Clear_List = "Lista tracciamento",
    Settings_Clear_List_Btn = "Pulisci tutto",
    
    -- Window Context Menu
    Menu_ResetPos = "Reimposta posizione",

    -- Context Menu
    Menu_Track = "Traccia (LiveAchiever)",
    Menu_StopTrack = "Smetti di tracciare (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[TRACCIATI]|r",
    Nav_History = "|cFFFF00[STORICO]|r",
    Nav_Action_Remove = "|cFF0000(Rimuovi)|r",
    Nav_Action_Add = "|c00FF00(Aggiungi)|r",
    Hist_Prev = "< Precedente",
    Hist_Next = "Successivo >",
    
    -- Time Options
    Time_Opt_1 = "1. tre secondi",
    Time_Opt_2 = "2. dieci secondi",
    Time_Opt_3 = "3. un minuto",
    Time_Opt_4 = "4. due minuti",
    Time_Opt_5 = "5. cinque minuti",
    Time_Opt_6 = "6. dieci minuti",
    Time_Opt_7 = "7. venti minuti",
    Time_Opt_8 = "8. trenta minuti",
    Time_Opt_9 = "9. un'ora",
    Time_Opt_10 = "10. due ore",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Sblocca finestra (Posicionamento)",
    Settings_Unlock_Tooltip = "Mostra la finestra nei menu. IMPORTANTE: Disabilita questa opzione dopo il posizionamento per nascondere nuovamente la finestra nei menu.",
	
	-- Aspetto & Gamepad
    Settings_Section_Appearance = "Aspetto",
    Settings_Font_Label = "Dimensione carattere",
    Settings_Font_Tooltip = "Regola la dimensione del testo (Intervallo: 6-28).",
    Settings_Alpha_Label = "Opacità sfondo",
    Settings_Alpha_Tooltip = "Regola la trasparenza dello sfondo della finestra (0% = invisibile).",
    Menu_Btn_Press = "Premi levetta destra",
    Menu_No_History = "(Nessun aggiornamento)",
}