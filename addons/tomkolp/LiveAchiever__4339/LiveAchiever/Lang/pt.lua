if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.pt = {
    -- HUD
    HUD_Title = "Conquistas Seguidas",
    HUD_Completed = "Concluído",
    HUD_Crit_Default = "Critério",
    Btn_Add_Tooltip = "Adicionar conquistas atualizadas recentemente",
    History_Instruction = "Clique para rastrear:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Conquistas do Guia de Zona",
    Zone_Panel_Empty = "Todas as conquistas concluídas.",
    
    -- Chat Messages
    Chat_Update = "Atualização:",
    Chat_Track_Btn = "[Seguir]",
    Chat_Progress_InProgress = "Progresso: Em curso",
    
    -- Status Messages
    Msg_Track_Stop = "Seguimento parado.",
    Msg_Track_Start = "Seguimento iniciado.",
    Msg_Pos_Reset = "LiveAchiever: Posição redefinida.",
    Msg_List_Cleared = "LiveAchiever: Lista limpa.",
    Msg_Time_Set = "LiveAchiever: Tempo de acumulação definido para: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Notificações",
    Settings_Time_Label = "Tempo de acumulação",
    Settings_Time_Tooltip = "Por quanto tempo o progresso deve ser somado (ex: +5). O contador desaparecerá após este tempo.",
    Settings_Section_Manage = "Gestão",
    Settings_Hide_Combat_Label = "Ocultar em combate",
    Settings_Hide_Combat_Tooltip = "Ocultar automaticamente a janela de seguimento ao entrar em combate.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Posição Horizontal (X)",
    Settings_Slider_X_Tooltip = "Move a janela para esquerda/direita. Útil no modo Gamepad.",
    Settings_Slider_Y_Label = "Posição Vertical (Y)",
    Settings_Slider_Y_Tooltip = "Move a janela para cima/baixo. Útil no modo Gamepad.",
    
    Settings_Reset_Pos = "Posição do HUD",
    Settings_Reset_Pos_Btn = "Redefinir Posição",
    Settings_Clear_List = "Lista de Seguimento",
    Settings_Clear_List_Btn = "Limpar Tudo",
    
    -- Window Context Menu
    Menu_ResetPos = "Redefinir Posição",

    -- Context Menu
    Menu_Track = "Seguir (LiveAchiever)",
    Menu_StopTrack = "Parar de seguir (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[SEGUIDO]|r",
    Nav_History = "|cFFFF00[HISTÓRICO]|r",
    Nav_Action_Remove = "|cFF0000(Remover)|r",
    Nav_Action_Add = "|c00FF00(Adicionar)|r",
    Hist_Prev = "< Anterior",
    Hist_Next = "Seguinte >",
    
    -- Time Options
    Time_Opt_1 = "1. três segundos",
    Time_Opt_2 = "2. dez segundos",
    Time_Opt_3 = "3. um minuto",
    Time_Opt_4 = "4. dois minutos",
    Time_Opt_5 = "5. cinco minutos",
    Time_Opt_6 = "6. dez minutos",
    Time_Opt_7 = "7. vinte minutos",
    Time_Opt_8 = "8. trinta minutos",
    Time_Opt_9 = "9. uma hora",
    Time_Opt_10 = "10. duas horas",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Desbloquear Janela (Posicionamento)",
    Settings_Unlock_Tooltip = "Mostra a janela nos menus. IMPORTANTE: Desative isto após o posicionamento para ocultar a janela nos menus novamente.",
	
	-- Aparência & Gamepad
    Settings_Section_Appearance = "Aparência",
    Settings_Font_Label = "Tamanho da Fonte",
    Settings_Font_Tooltip = "Ajustar tamanho do texto (Faixa: 6-28).",
    Settings_Alpha_Label = "Opacidade do Fundo",
    Settings_Alpha_Tooltip = "Ajustar transparência do fundo da janela (0% = invisível).",
    Menu_Btn_Press = "Pressionar Stick Direito",
    Menu_No_History = "(Sem atualizações)",
}