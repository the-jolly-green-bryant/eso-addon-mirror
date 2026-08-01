if not LiveAchiever then LiveAchiever = {} end
if not LiveAchiever.Lang then LiveAchiever.Lang = {} end

LiveAchiever.Lang.ru = {
    -- HUD
    HUD_Title = "Отслеживаемые достижения",
    HUD_Completed = "Завершено",
    HUD_Crit_Default = "Критерий",
    Btn_Add_Tooltip = "Добавить недавно обновленные достижения",
    History_Instruction = "Нажмите для отслеживания:",
    
    -- Zone Guide Panel
    Zone_Panel_Title = "Достижения путеводителя",
    Zone_Panel_Empty = "Все достижения завершены.",
    
    -- Chat Messages
    Chat_Update = "Обновление:",
    Chat_Track_Btn = "[Отслеживать]",
    Chat_Progress_InProgress = "Прогресс: В процессе",
    
    -- Status Messages
    Msg_Track_Stop = "Отслеживание остановлено.",
    Msg_Track_Start = "Отслеживание начато.",
    Msg_Pos_Reset = "LiveAchiever: Позиция сброшена.",
    Msg_List_Cleared = "LiveAchiever: Список очищен.",
    Msg_Time_Set = "LiveAchiever: Время накопления установлено на: <<1>>", 
    
    -- Settings Menu
    Settings_Section_Notify = "Уведомления",
    Settings_Time_Label = "Время суммирования прогресса",
    Settings_Time_Tooltip = "Как долго суммировать прогресс (например, +5). Счетчик исчезнет по истечении этого времени.",
    Settings_Section_Manage = "Управление",
    Settings_Hide_Combat_Label = "Скрывать в бою",
    Settings_Hide_Combat_Tooltip = "Автоматически скрывать окно отслеживания при входе в бой.",
    
    -- Settings Sliders
    Settings_Slider_X_Label = "Горизонтальная позиция (X)",
    Settings_Slider_X_Tooltip = "Двигает окно влево/вправо. Полезно для геймпада.",
    Settings_Slider_Y_Label = "Вертикальная позиция (Y)",
    Settings_Slider_Y_Tooltip = "Двигает окно вверх/вниз. Полезно для геймпада.",
    
    Settings_Reset_Pos = "Позиция HUD",
    Settings_Reset_Pos_Btn = "Сбросить позицию",
    Settings_Clear_List = "Список отслеживания",
    Settings_Clear_List_Btn = "Очистить все",
    
    -- Window Context Menu
    Menu_ResetPos = "Сбросить позицию",

    -- Context Menu
    Menu_Track = "Отслеживать (LiveAchiever)",
    Menu_StopTrack = "Не отслеживать (LiveAchiever)",
    
    -- Navigation / Gamepad
    Nav_Tracked = "|c00FF00[СЛЕЖЕНИЕ]|r",
    Nav_History = "|cFFFF00[ИСТОРИЯ]|r",
    Nav_Action_Remove = "|cFF0000(Удалить)|r",
    Nav_Action_Add = "|c00FF00(Добавить)|r",
    Hist_Prev = "< Назад",
    Hist_Next = "Вперед >",
    
    -- Time Options
    Time_Opt_1 = "1. три секунды",
    Time_Opt_2 = "2. десять секунд",
    Time_Opt_3 = "3. одна минута",
    Time_Opt_4 = "4. две минуты",
    Time_Opt_5 = "5. пять минут",
    Time_Opt_6 = "6. десять минут",
    Time_Opt_7 = "7. двадцать минут",
    Time_Opt_8 = "8. тридцать минут",
    Time_Opt_9 = "9. один час",
    Time_Opt_10 = "10. два часа",
	
	-- Positioning Mode
    Settings_Unlock_Label = "Разблокировать окно (Позиционирование)",
    Settings_Unlock_Tooltip = "Показывает окно в меню. ВАЖНО: Отключите эту опцию после настройки, чтобы окно снова скрывалось в меню.",
	
	-- Внешний вид & Геймпад
    Settings_Section_Appearance = "Внешний вид",
    Settings_Font_Label = "Размер шрифта",
    Settings_Font_Tooltip = "Настройка размера текста (Диапазон: 6-28).",
    Settings_Alpha_Label = "Прозрачность фона",
    Settings_Alpha_Tooltip = "Настройка прозрачности фона окна (0% = невидимый).",
    Menu_Btn_Press = "Нажмите правый стик",
    Menu_No_History = "(Нет обновлений)",
}