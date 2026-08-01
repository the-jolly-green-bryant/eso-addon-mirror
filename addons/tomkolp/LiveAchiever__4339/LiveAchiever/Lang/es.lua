if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.es = {
    -- HUD
    HUD_Title = "Logros Seguidos",
    HUD_Completed = "Completado",
    HUD_Crit_Default = "Criterio",
    Btn_Add_Tooltip = "Añadir logros actualizados recientemente",
    History_Instruction = "Clic para rastrear:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Logros de la Guía de zona",
    Zone_Panel_Empty = "Todos los logros completados.",
    
    -- Chat Messages
    Chat_Update = "Actualización:",
    Chat_Track_Btn = "[Seguir progreso]",
    Chat_Progress_InProgress = "Progreso: En curso",
    
    -- Status Messages
    Msg_Track_Stop = "Seguimiento detenido.",
    Msg_Track_Start = "Seguimiento iniciado.",
    Msg_Pos_Reset = "LiveAchiever: Posición restablecida.",
    Msg_List_Cleared = "LiveAchiever: Lista borrada.",
    Msg_Time_Set = "LiveAchiever: Tiempo de acumulación establecido en: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Notificaciones",
    Settings_Time_Label = "Tiempo de acumulación",
    Settings_Time_Tooltip = "¿Cuánto tiempo se debe sumar el progreso (ej. +5)? El contador desaparecerá después de este tiempo.",
    Settings_Section_Manage = "Gestión",
    Settings_Hide_Combat_Label = "Ocultar en combate",
    Settings_Hide_Combat_Tooltip = "Ocultar automáticamente la ventana de seguimiento al entrar en combate.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Posición Horizontal (X)",
    Settings_Slider_X_Tooltip = "Mueve la ventana a izquierda/derecha. Útil en modo Mando.",
    Settings_Slider_Y_Label = "Posición Vertical (Y)",
    Settings_Slider_Y_Tooltip = "Mueve la ventana arriba/abajo. Útil en modo Mando.",
    
    Settings_Reset_Pos = "Posición del HUD",
    Settings_Reset_Pos_Btn = "Restablecer",
    Settings_Clear_List = "Lista de seguimiento",
    Settings_Clear_List_Btn = "Borrar todo",
    
    -- Window Context Menu
    Menu_ResetPos = "Restablecer posición",

    -- Context Menu
    Menu_Track = "Seguir (LiveAchiever)",
    Menu_StopTrack = "Dejar de seguir (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[SEGUIDO]|r",
    Nav_History = "|cFFFF00[HISTORIAL]|r",
    Nav_Action_Remove = "|cFF0000(Quitar)|r",
    Nav_Action_Add = "|c00FF00(Añadir)|r",
    Hist_Prev = "< Anterior",
    Hist_Next = "Siguiente >",
    
    -- Time Options
    Time_Opt_1 = "1. tres segundos",
    Time_Opt_2 = "2. diez segundos",
    Time_Opt_3 = "3. un minuto",
    Time_Opt_4 = "4. dos minutos",
    Time_Opt_5 = "5. cinco minutos",
    Time_Opt_6 = "6. diez minutos",
    Time_Opt_7 = "7. veinte minutos",
    Time_Opt_8 = "8. treinta minutos",
    Time_Opt_9 = "9. una hora",
    Time_Opt_10 = "10. dos horas",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Desbloquear ventana (Posicionamiento)",
    Settings_Unlock_Tooltip = "Muestra la ventana en los menús. IMPORTANTE: Desactiva esto tras posicionar para ocultar la ventana en los menús de nuevo.",
	
	-- Apariencia & Gamepad
    Settings_Section_Appearance = "Apariencia",
    Settings_Font_Label = "Tamaño de fuente",
    Settings_Font_Tooltip = "Ajustar tamaño del texto (Rango: 6-28).",
    Settings_Alpha_Label = "Opacidad del fondo",
    Settings_Alpha_Tooltip = "Ajusta la transparencia del fondo (0% = invisible).",
    Menu_Btn_Press = "Presionar Stick Derecho",
    Menu_No_History = "(Sin actualizaciones)",
}