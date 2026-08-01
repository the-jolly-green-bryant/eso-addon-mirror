if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.fr = {
    -- HUD
    HUD_Title = "Succès Suivis",
    HUD_Completed = "Terminé",
    HUD_Crit_Default = "Critère",
    Btn_Add_Tooltip = "Ajouter des succès récemment mis à jour",
    History_Instruction = "Cliquez pour suivre :",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Succès du Guide de zone",
    Zone_Panel_Empty = "Tous les succès terminés.",
    
    -- Chat Messages
    Chat_Update = "Mise à jour :",
    Chat_Track_Btn = "[Suivre ce progrès]",
    Chat_Progress_InProgress = "Progrès : En cours",
    
    -- Status Messages
    Msg_Track_Stop = "Suivi arrêté.",
    Msg_Track_Start = "Suivi commencé.",
    Msg_Pos_Reset = "LiveAchiever : Position réinitialisée.",
    Msg_List_Cleared = "LiveAchiever : Liste effacée.",
    Msg_Time_Set = "LiveAchiever : Temps de cumul réglé sur : <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Notifications",
    Settings_Time_Label = "Temps de cumul des progrès",
    Settings_Time_Tooltip = "Combien de temps les progrès doivent être additionnés (ex. +5). Le compteur disparaîtra après ce temps.",
    Settings_Section_Manage = "Gestion",
    Settings_Hide_Combat_Label = "Masquer en combat",
    Settings_Hide_Combat_Tooltip = "Masquer automatiquement la fenêtre de suivi lorsque vous entrez en combat.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Position horizontale (X)",
    Settings_Slider_X_Tooltip = "Déplace la fenêtre vers la gauche/droite. Utile en mode Manette.",
    Settings_Slider_Y_Label = "Position verticale (Y)",
    Settings_Slider_Y_Tooltip = "Déplace la fenêtre vers le haut/bas. Utile en mode Manette.",
    
    Settings_Reset_Pos = "Position du HUD",
    Settings_Reset_Pos_Btn = "Réinitialiser la position",
    Settings_Clear_List = "Liste de suivi",
    Settings_Clear_List_Btn = "Tout effacer",
    
    -- Window Context Menu
    Menu_ResetPos = "Réinitialiser la position",

    -- Context Menu
    Menu_Track = "Suivre (LiveAchiever)",
    Menu_StopTrack = "Arrêter le suivi (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[SUIVI]|r",
    Nav_History = "|cFFFF00[HISTORIQUE]|r",
    Nav_Action_Remove = "|cFF0000(Retirer)|r",
    Nav_Action_Add = "|c00FF00(Ajouter)|r",
    Hist_Prev = "< Précédent",
    Hist_Next = "Suivant >",
    
    -- Time Options
    Time_Opt_1 = "1. trois secondes",
    Time_Opt_2 = "2. dix secondes",
    Time_Opt_3 = "3. une minute",
    Time_Opt_4 = "4. deux minutes",
    Time_Opt_5 = "5. cinq minutes",
    Time_Opt_6 = "6. dix minutes",
    Time_Opt_7 = "7. vingt minutes",
    Time_Opt_8 = "8. trente minutes",
    Time_Opt_9 = "9. une heure",
    Time_Opt_10 = "10. deux heures",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Déverrouiller la fenêtre (Positionnement)",
    Settings_Unlock_Tooltip = "Affiche la fenêtre dans les menus. IMPORTANT : Désactivez cette option après le positionnement pour masquer à nouveau la fenêtre dans les menus.",
	
	-- Apparence & Gamepad
    Settings_Section_Appearance = "Apparence",
    Settings_Font_Label = "Taille de la police",
    Settings_Font_Tooltip = "Ajuste la taille du texte (Plage : 6-28).",
    Settings_Alpha_Label = "Opacité du fond",
    Settings_Alpha_Tooltip = "Ajuste la transparence du fond de la fenêtre (0% = invisible).",
    Menu_Btn_Press = "Appuyer sur le stick droit",
    Menu_No_History = "(Pas de mises à jour)",
}