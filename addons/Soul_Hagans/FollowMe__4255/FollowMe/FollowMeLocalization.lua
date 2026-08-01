-- FollowMe Localization - автоматическое определение языка
FollowMeLocales = {
    ru = {
        -- Интерфейс
        NOT_IN_GROUP = "Вы не в группе.",
        SIGNAL_SENT = "Сигнал отправлен: ",
        IGNORE_OWN_SIGNAL = "Игнорирую свой сигнал.",
        AUTO_TELEPORT = "Авто-телепорт к ",
        TELEPORTING = "Телепортируемся к ",
        
        -- Диалог (Новый кастомный интерфейс)
        DIALOG_SUMMONED = "ВАС ПРИЗЫВАЮТ",
        DIALOG_YES = "Да",
        DIALOG_NO = "Нет",
        DIALOG_TEXT = "<<1>>\n<<2>>\n\nТелепортироваться?", -- Шаблон для текста в новом окне
        
        -- Старые диалоговые ключи (оставим для совместимости)
        DIALOG_TITLE = "FollowMe",
        DIALOG_ACCEPT = "Телепорт",
        DIALOG_DECLINE = "Отказ",
        
        -- Настройки
        SETTINGS_AUTO_ACCEPT = "Авто-принятие",
        SETTINGS_AUTO_ACCEPT_TT = "Автоматически телепортироваться к лидеру без запроса.",
        SETTINGS_SHOW_OWN = "Показ своих сигналов", 
        SETTINGS_SHOW_OWN_TT = "Показывать диалог телепорта при получении своего же сигнала.",
        SETTINGS_SHOW_BUTTON = "Показывать кнопку в чате",
        SETTINGS_SHOW_BUTTON_TT = "Отображать кнопку для отправки сигнала в окне чата.",
        SETTINGS_BUTTON_X = "Позиция кнопки по X",
        SETTINGS_BUTTON_X_TT = "Регулирует горизонтальное положение кнопки в окне чата.",
        SETTINGS_RESET_BUTTON = "Сбросить позицию кнопки",
        SETTINGS_RESET_BUTTON_TT = "Сбрасывает позицию кнопки к значению по умолчанию.",
        SETTINGS_ACCOUNT_WIDE = "Сохранять настройки для аккаунта",
        SETTINGS_ACCOUNT_WIDE_TT = "Если включено, настройки будут общими для всех персонажей аккаунта.",
        
        -- Названия горячих клавиш в настройках управления игры
        BINDING_SEND = "Отправить сигнал FollowMe",
        BINDING_YES = "FollowMe: Принять призыв (Телепорт)",
        BINDING_NO = "FollowMe: Отклонить призыв (Отмена)",

        -- Команды
        HELP_TITLE = "FollowMe - команды:",
        HELP_FM = "/fm - отправить текущее местоположение",
        HELP_FMAUTO = "/fmauto - авто-принятие телепорта", 
        HELP_FMSHOW = "/fmshow - показ своих сигналов",
        HELP_FMPOS = "/fmpos [число] - установить позицию кнопки (0-500)",
        HELP_FMSETTINGS = "/fmsettings - открыть настройки",
        
        -- Статусы
        STATUS_ON = "|c00FF00ВКЛ|r",
        STATUS_OFF = "|cFF0000ВЫКЛ|r",
        ACCOUNT_WIDE = "|c00FF00для аккаунта|r",
        CHARACTER_ONLY = "|cFF0000для персонажа|r",
        
        -- Сообщения
        BUTTON_RESET = "Позиция кнопки сброшена",
        BUTTON_POSITION_SET = "Позиция кнопки установлена: ",
        BUTTON_POSITION_USAGE = "Используйте: /fmpos [0-500]",
        BUTTON_CURRENT_POSITION = "Текущая позиция кнопки: ",
        SETTINGS_APPLIED = "Настройки теперь сохраняются для: ",
        RELOAD_UI_REQUIRED = "Перезагрузите UI для применения изменений (/reloadui)",
        
        -- Tooltips
        TOOLTIP_TITLE = "|cFFFFFFFollowMe|r",
        TOOLTIP_DESC = "ЛКМ - отправить текущее местоположение",
        
        -- Загрузка
        LOADED = "Загружен! Напишите |c00FFFF/fmhelp|r для списка команд.",
        SETTINGS_COMMAND = "Настройки: |c00FFFF/fmsettings|r",
        SAVING_TYPE = "Сохранение: ",
    },
    
    en = {
        -- Interface
        NOT_IN_GROUP = "You are not in a group.",
        SIGNAL_SENT = "Signal sent: ",
        IGNORE_OWN_SIGNAL = "Ignoring own signal.",
        AUTO_TELEPORT = "Auto-teleport to ",
        TELEPORTING = "Teleporting to ",
        
        -- Dialog (New custom UI)
        DIALOG_SUMMONED = "YOU ARE SUMMONED",
        DIALOG_YES = "Yes",
        DIALOG_NO = "No",
        DIALOG_TEXT = "<<1>>\n<<2>>\n\nTeleport?", 
        
        -- Old dialogue keys (for compatibility)
        DIALOG_TITLE = "FollowMe",
        DIALOG_ACCEPT = "Teleport",
        DIALOG_DECLINE = "Decline",
        
        -- Settings
        SETTINGS_AUTO_ACCEPT = "Auto-accept",
        SETTINGS_AUTO_ACCEPT_TT = "Automatically teleport to leader without prompt.",
        SETTINGS_SHOW_OWN = "Show own signals",
        SETTINGS_SHOW_OWN_TT = "Show teleport dialog when receiving your own signal.",
        SETTINGS_SHOW_BUTTON = "Show chat button", 
        SETTINGS_SHOW_BUTTON_TT = "Display button for sending signal in chat window.",
        SETTINGS_BUTTON_X = "Button X Position",
        SETTINGS_BUTTON_X_TT = "Adjusts horizontal position of button in chat window.",
        SETTINGS_RESET_BUTTON = "Reset button position",
        SETTINGS_RESET_BUTTON_TT = "Resets button position to default value.",
        SETTINGS_ACCOUNT_WIDE = "Save settings account-wide",
        SETTINGS_ACCOUNT_WIDE_TT = "If enabled, settings will be shared across all account characters.",
        
        -- Names of hotkeys in controls settings menu
        BINDING_SEND = "Send FollowMe Signal",
        BINDING_YES = "FollowMe: Accept Summon (Teleport)",
        BINDING_NO = "FollowMe: Decline Summon (Cancel)",

        -- Commands
        HELP_TITLE = "FollowMe - commands:",
        HELP_FM = "/fm - send current location",
        HELP_FMAUTO = "/fmauto - auto-accept teleport",
        HELP_FMSHOW = "/fmshow - show own signals", 
        HELP_FMPOS = "/fmpos [number] - set button position (0-500)",
        HELP_FMSETTINGS = "/fmsettings - open settings",
        
        -- Statuses
        STATUS_ON = "|c00FF00ON|r",
        STATUS_OFF = "|cFF0000OFF|r", 
        ACCOUNT_WIDE = "|c00FF00account-wide|r",
        CHARACTER_ONLY = "|cFF0000character only|r",
        
        -- Messages
        BUTTON_RESET = "Button position reset",
        BUTTON_POSITION_SET = "Button position set: ",
        BUTTON_POSITION_USAGE = "Usage: /fmpos [0-500]",
        BUTTON_CURRENT_POSITION = "Current button position: ",
        SETTINGS_APPLIED = "Settings now save for: ",
        RELOAD_UI_REQUIRED = "Reload UI to apply changes (/reloadui)",
        
        -- Tooltips
        TOOLTIP_TITLE = "|cFFFFFFFollowMe|r",
        TOOLTIP_DESC = "LMB - send current location",
        
        -- Loading
        LOADED = "Loaded! Type |c00FFFF/fmhelp|r for command list.",
        SETTINGS_COMMAND = "Settings: |c00FFFF/fmsettings|r", 
        SAVING_TYPE = "Saving: ",
    }
}

-- Функция определения языка игры
local function GetGameLanguage()
    local lang = GetCVar("language.2")
    if lang == "ru" then
        return "ru"
    else
        return "en" -- английский по умолчанию для всех других языков
    end
end

-- Получаем текущую локаль
local CURRENT_LOCALE = GetGameLanguage()
FollowMe_L = FollowMeLocales[CURRENT_LOCALE]