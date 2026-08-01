if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.pl = {
    -- HUD
    HUD_Title = "Śledzone Osiągnięcia",
    HUD_Completed = "Zakończone",
    HUD_Crit_Default = "Kryterium",
    Btn_Add_Tooltip = "Dodaj ostatnio zaktualizowane osiągnięcia",
    History_Instruction = "Kliknij, aby śledzić:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Osiągnięcia z Przewodnika",
    Zone_Panel_Empty = "Wszystkie osiągnięcia ukończone.",
    
    -- Chat Messages
    Chat_Update = "Aktualizacja:",
    Chat_Track_Btn = "[Śledź ten postęp]",
    Chat_Progress_InProgress = "Postęp: W toku",
    
    -- Status Messages
    Msg_Track_Stop = "Przestano śledzić.",
    Msg_Track_Start = "Rozpoczęto śledzenie.",
    Msg_Pos_Reset = "LiveAchiever: Pozycja zresetowana.",
    Msg_List_Cleared = "LiveAchiever: Lista wyczyszczona.",
    Msg_Time_Set = "LiveAchiever: Ustawiono czas sumowania na: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Powiadomienia",
    Settings_Time_Label = "Czas sumowania postępów",
    Settings_Time_Tooltip = "Przez jaki czas postępy mają być sumowane (np. +5). Po upływie tego czasu licznik zniknie.",
    Settings_Section_Manage = "Zarządzanie",
    Settings_Hide_Combat_Label = "Ukryj w walce",
    Settings_Hide_Combat_Tooltip = "Automatycznie ukryj okno śledzenia, gdy wejdziesz w tryb walki.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Pozycja pozioma (X)",
    Settings_Slider_X_Tooltip = "Przesuwa okno w lewo/prawo. Przydatne w trybie Gamepada.",
    Settings_Slider_Y_Label = "Pozycja pionowa (Y)",
    Settings_Slider_Y_Tooltip = "Przesuwa okno w górę/dół. Przydatne w trybie Gamepada.",
    
    Settings_Reset_Pos = "Pozycja okna HUD",
    Settings_Reset_Pos_Btn = "Resetuj pozycję",
    Settings_Clear_List = "Lista śledzenia",
    Settings_Clear_List_Btn = "Wyczyść wszystko",
    
    -- Window Context Menu
    Menu_ResetPos = "Resetuj pozycję",

    -- Context Menu
    Menu_Track = "Śledź (LiveAchiever)",
    Menu_StopTrack = "Przestań śledzić (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[ŚLEDZONE]|r",
    Nav_History = "|cFFFF00[HISTORIA]|r",
    Nav_Action_Remove = "|cFF0000(Usuń)|r",
    Nav_Action_Add = "|c00FF00(Dodaj)|r",
    Hist_Prev = "< Poprzednie",
    Hist_Next = "Następne >",
    
    -- Time Options
    Time_Opt_1 = "1. trzy sekundy",
    Time_Opt_2 = "2. dziesięć sekund",
    Time_Opt_3 = "3. jedna minuta",
    Time_Opt_4 = "4. dwie minuty",
    Time_Opt_5 = "5. pięć minut",
    Time_Opt_6 = "6. dziesięć minut",
    Time_Opt_7 = "7. dwadzieścia minut",
    Time_Opt_8 = "8. trzydzieści minut",
    Time_Opt_9 = "9. godzina",
    Time_Opt_10 = "10. dwie godziny",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Odblokuj okno (Pozycjonowanie)",
    Settings_Unlock_Tooltip = "Pokazuje okno w menu, aby umożliwić jego przesunięcie. WAŻNE: Wyłącz tę opcję po ustawieniu pozycji, aby okno znów znikało w menu.",
	
	-- Wygląd i Gamepad
    Settings_Section_Appearance = "Wygląd",
    Settings_Font_Label = "Rozmiar czcionki",
    Settings_Font_Tooltip = "Dostosuj rozmiar tekstu (Zakres: 6-28).",
    Settings_Alpha_Label = "Przezroczystość tła",
    Settings_Alpha_Tooltip = "Dostosuj przezroczystość tła okna (0% = niewidoczne).",
    Menu_Btn_Press = "Wciśnij Prawy Drążek",
    Menu_No_History = "(Brak aktualizacji)",
}