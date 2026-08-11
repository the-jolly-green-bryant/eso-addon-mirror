-- define local variables as much as possible, so scope is local
local em       = GetEventManager()
local dx       = 1 / GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

-- БЕЗОПАСНОЕ ПОДКЛЮЧЕНИЕ LAM И ПРОВЕРКА ВЕРСИИ
local LAM = LibAddonMenu2
if not LAM then 
    d("|cFF0000[ERROR] LibAddonMenu-2.0 unavailable! Please install LibAddonMenu-2.0>= 43.|r")
    return 
end

-- Проверка версии LibAddonMenu-2.0 
if LAM.GetAPIVersion and LAM:GetAPIVersion() < 43 then
    d("|cFF0000[ERROR] EsoPlusFreeTrialNotification requires LibAddonMenu-2.0 version 43 or higher.|r")
    d("|cFF0000Please update or install the LibAddonMenu-2.0 from Minion or esoui.com.|r")
    return -- Останавливаем загрузку, чтобы избежать ошибок выполнения
end

-- Проверка версии LibAddonMenu-2.0 (Критическое требование от модератора!)
if LAM.GetAPIVersion and LAM:GetAPIVersion() < 43 then
    d("|cFF0000[ERROR] EsoPlusFreeTrialNotification requires LibAddonMenu-2.0 version 43 or higher.|r")
    d("|cFF0000Please update or install the LibAddonMenu-2.0 from Minion or esoui.com.|r")
    return -- Останавливаем загрузку, чтобы избежать ошибок выполнения
end

-- Единая точка входа — рекомендуемый паттерн ESOUI
ESOPLUSFREETRIALNOTIFICATION_ESWAGROM = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM or {}

-- === ОПТИМИЗАЦИЯ ДОСТУПА К ГЛОБАЛЬНОЙ ТАБЛИЦЕ (_G optimization) ===
local EPFTN = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM

EPFTN.name       = "EsoPlusFreeTrialNotification"
EPFTN.version    = "1.2"

-- ===================================================================
-- РЕГИСТРАЦИЯ ЛОКАЛИЗАЦИИ — ВЫНЕСЕНА НАВЕРХ!
-- Это гарантирует, что GetString() работает везде ниже
-- ===================================================================
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Подписка доступна|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Подписка недоступна|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 не найдена. Проверьте и установите её.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU"] = "|cCCECC0Дата|r                |c98FB98Статус|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM"] = "|cEEEE00Давайте спросим у @Eswagrom...|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A"] = "|c2DF5F8[@Eswagrom] шепчет: Привет, сейчас подписка доступна ИСПОЛЬЗУЙ ЕЁ|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C"] = "|c5EB9D7[@Eswagrom]: Привет, что насчёт бесплатной подписки?|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B"] = "|c2DF5F8[@Eswagrom] шепчет: Привет, сейчас подписка недоступна -_-|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION"] = "Отправлять уведомления в чат",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00Если ВЫКЛ., сообщение в чат про подписку автоматически не будет приходить, останется только ручная проверка /esoplus.|r", -- Исправлена опечатка в ключе
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "Размер шрифта в таблице",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00Изменяет размер шрифта окне истории статусов (от 8 до 24)|r",
    

    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00Открывает отдельное окно с информацией о бесплатной подписке.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "Заблокировать положение окна",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00Запретит перетаскивать окно по экрану|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "Прозрачность фона",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "Сбросить позицию окна",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "Обновить историю статусов",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00Если что-то забаговало в окне таблице истории — обновите, может это поможет вам.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "доступно",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "недоступно", -- Исправлена опечатка в UNAVA
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Количество строк для записи",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00Сколько строк будет сохранено в истории SavedVariables [влияет на размер файла и длительность записи, по достижению лимита будет перезапись] (от 100 до 5000 количество возможных строк)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Позиция окна сброшена.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00Записи ESO Plus|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347Сбросить Настройки!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Вернуть все настройки аддона к состоянию 'только что установлен'. Сбрасывает положение окна, размер, прозрачность, шрифт, видимость, количество строк (удалит строки свыше записанного лимита!!! изначально 2000 строк) и историю.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00Информация про аддон|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347напишите в чат для ручной проверки!|r Этот аддон сохраняет записи о получении бесплатной подписки, поэтому вы всегда будете точно знать, в какой день она была активирована или отсутствовала. По умолчанию история хранит до 2000 записей. Что это значит на практике? Каждая запись в таблице занимает одну строку за один день. Таким образом, лимит в 2000 строк охватывает период примерно в 2000/365≈5,48 лет. Иными словами, аддон будет хранить историю ваших подписок почти пять с половиной лет.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00api которые использует данный аддон|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = [[API (Application Programming Interface) — это набор правил, по которым ваш аддон взаимодействует с сервером игры. Проще говоря, это перечень разрешённых команд, которые определяют рамки его возможностей. Для реализации были использованы следующие методы:]],
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "У данного аддона нет функции привязки кнопки для вызова пользовательской таблицы с историей записей, поскольку аддон носит исключительно информационный характер. Эта таблица вам почти никогда не понадобится. Автор сознательно не добавил такую кнопку из-за ограничения в игре: доступно всего 100 слотов под пользовательские клавиши, поэтому занимать их ненужными элементами нецелесообразно.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION"] ="|cFF6347Таблица теперь тут ниже:|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION_A"] ="|c9999FFПри отображении большого количества записей (2000 по умолчанию) таблица может открыться с секундной задержкой, это нормально.|r |cFFFFC5Откройте таблицу:|r",

    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c0000FFФункция автоматической проверки!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFAвтоматические проверки статуса подписки происходит каждые 15 минут, независимо от настроек аддона, это нужно для того, чтобы вы не пропустили статус подписки, если она будет активирована чуть позже этим же днём, функция проверки не нагружает вашу систему. Такой таймер совершенно безопасен для производительности. Вот почему: |cFFFFC5Частота выполнения Раз в 15 минут — это крайне редко для игрового движка. Для сравнения: сам клиент ESO обрабатывает десятки тысяч событий каждую секунду (анимация, рендеринг, сетевые пакеты). Одна функция раз в 15 минут — капля в море. - Все операции здесь — чисто логические: чтение статуса аккаунта через встроенный API (HasEsoPlus...), работа с локальной таблицей (Lua table) и вывод сообщения в чат (d()). Здесь нет тяжёлых вычислений, циклов по большим массивам, обращений к файлам или сети. Вызовы вроде ZO_SavedVars, d(), ClearEsoPlus... оптимизированы разработчиками ZOS и выполняются за микросекунды.| |cffd700Ping|r определяется качеством интернет-соединения и нагрузкой на серверы ESO. Локальный Lua-таймер клиента никак не отправляет данные на сервер чаще, чем это уже делает сама игра. Функция HasEsoPlusFreeTrialNotification() использует кэшированный статус аккаунта — она не создаёт дополнительного сетевого трафика. | |c1E90FFСравнение с другими аддонами.|r Многие популярные аддоны используют гораздо более частые таймеры: |cADD8E6- Inventory Insight|r — проверяет инвентарь при каждом открытии; |cADD8E6- Combat Metrics|r — анализирует каждый тик боя (десятки раз в секунду); - даже стандартные UI-элементы обновляются 60+ раз в секунду. Этот |cADD8E6таймер|r в 900 секунд выглядит как «раз в эпоху» на этом фоне."
}

-- Регистрация ВСЕХ строк одним циклом — ТРЕБОВАНИЕ ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end

-- Теперь можно безопасно использовать GetString()

local settings
local defaults =
{
    StatusHistory = {},
    ChatNotificationsEnabled = true,
    MaxHistoryLines = 2000
}

-- Локальные переменные сессии
local g_NotificationShownThisSession = false
local g_SentNotifications = { available = false, unavailable = false }

-- ОБЪЯВЛЕНИЕ ВСЕХ ФУНКЦИЙ ДО ТОГО, КАК ОНИ БУДУТ ВЫЗВАНЫ
local function UpdateStatusLog()
    if not EPFTN.window then return end
    local buffer = EPFTN.window:GetNamedChild("Buffer") -- Получаем наш TextBuffer
    if not buffer then return end

    buffer:Clear()

    if #settings.StatusHistory == 0 then
        buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])
        buffer:AddMessage(GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU))
        buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])
        buffer:AddMessage("|c999999История проверок пуста.|r")
        buffer:AddMessage("|c999999Статус проверяется каждые 15 минут или вручную (/esoplus).|r")
        return
    end

    -- Добавление заголовков
    buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])
    buffer:AddMessage(GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU))
    buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])

    for i = #settings.StatusHistory, 1, -1 do
        local entry = settings.StatusHistory[i]
        local color = (entry.status == "available") and "|c00FF00" or "|cFF0000"
        local marker = (i == #settings.StatusHistory) and ">> " or "   "
        
        local line = string.format("%s[%s] %s%s|r", marker, entry.date, color, entry.status == "available" and GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_AVA) or GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA))
        buffer:AddMessage(line)
    end
end

local function SendAutoNotification(hasSub)
    local currentDate = string.sub(GetDateStringFromTimestamp(GetTimeStamp()), 1, 10)
    if settings.LastCheckDate ~= currentDate then
        settings.SentAvailableToday = false
        settings.SentUnavailableToday = false
        settings.LastCheckDate = currentDate
    end
    
    if not settings.ChatNotificationsEnabled then
        return
    end
    
    zo_callLater(function() 
        if hasSub then
            if not g_SentNotifications.available then
                local msg = GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE)
                if msg then d(msg) end
                g_SentNotifications.available = true
                g_SentNotifications.unavailable = false
            end
        else
            if not g_SentNotifications.unavailable then
                local msg = GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE)
                if msg then d(msg) end
                g_SentNotifications.unavailable = true
                g_SentNotifications.available = false
            end
        end
    end, 300) 
end

local function RecordStatus(hasSub)
    local status = hasSub and "available" or "unavailable"
    local dateString = GetDateStringFromTimestamp(GetTimeStamp())
    local day = string.sub(dateString, 1, 2)
    local month = string.sub(dateString, 4, 5)
    local year = string.sub(dateString, 7, 8)
    local formattedDate = year .. "." .. month .. "." .. day

    local lastEntry = settings.StatusHistory[#settings.StatusHistory]
    if lastEntry and string.sub(lastEntry.date, 1, 8) == string.sub(formattedDate, 1, 8) and lastEntry.status == status then return end
    table.insert(settings.StatusHistory, {date = formattedDate, status = status})
    
    while #settings.StatusHistory > settings.MaxHistoryLines do
        table.remove(settings.StatusHistory, 1)
    end
end

-- Ручная проверка
local function ManualCheckAndPrint()
    local welcomeMsg = GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM)
    if welcomeMsg then d(welcomeMsg) end
    
    local hasSub = HasEsoPlusFreeTrialNotification()
    
    RecordStatus(hasSub)
    UpdateStatusLog()
    
    zo_callLater(function()
        local cMsg = GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C)
        if cMsg then d(cMsg) end
    end, 1500)
    
    zo_callLater(function()
        if hasSub then
            local aMsg = GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A)
            if aMsg then d(aMsg) end
        end
    end, 4500)
    
    zo_callLater(function()
        if not hasSub then
            local bMsg = GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B)
            if bMsg then d(bMsg) end
        end
    end, 4500)
    
    -- Безопасная очистка стандартного уведомления
    if type(ClearEsoPlusFreeTrialNotification) == "function" then
        ClearEsoPlusFreeTrialNotification()
    end
end

-- Основная логика АВТО-проверки
local function CheckStatus()
    local hasSub = HasEsoPlusFreeTrialNotification()
    
    SendAutoNotification(hasSub) 
    RecordStatus(hasSub)
    
    -- Безопасная очистка — только если функция существует
    if type(ClearEsoPlusFreeTrialNotification) == "function" then
        ClearEsoPlusFreeTrialNotification()
    end
end



-- Slash Commands теперь регистрируются прямо здесь
SLASH_COMMANDS["/esoplus"] = function()
    ManualCheckAndPrint()
end

-- Сброс настроек
local function ResetToDefaults()
    local currentHistory = settings.StatusHistory

    for key, value in pairs(defaults) do
        if key ~= "StatusHistory" then
            settings[key] = value
        end
    end

    settings.StatusHistory = {}
    local linesToKeep = math.min(#currentHistory, settings.MaxHistoryLines)
    for i = #currentHistory - linesToKeep + 1, #currentHistory do
        table.insert(settings.StatusHistory, currentHistory[i])
    end

    UpdateStatusLog()
    d("|cFFFF00[EsoPlus] /reloadui...|r")
    
    zo_callLater(function()
        ReloadUI()
    end, 1000)
end

-- Панель настроек
local function CreateSettingsPanel()
    local panelData = {
        type = "panel",
        name = "|c98fb98Eso Plus Free Trial Notification|r",
        author = "|c00FF00@Eswagrom|r",
        version = "|cff80801.2|r",
    }
    
    local infoOptionsData = {
        [1] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A, },
        [2] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA, },
        [3] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB, },
        [4] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC, },
        [5] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD, },
    }

    local allRecords = {
[1] = { 
    type = "description", 
    name = "|cFFFFFFПоследние записи|r",
    text = function() 
        local fullText = ""
        for i = #settings.StatusHistory, math.max(1, #settings.StatusHistory - 4999), -1 do
            local entry = settings.StatusHistory[i]
            
            -- Добавляем стрелку ТОЛЬКО к последней записи
            local prefix = (i == #settings.StatusHistory) and ">> " or "   "
            
            if entry.date and entry.status then
                fullText = fullText .. string.format(
                   -- "|cFFFFFF%s[%s]|r %s|r\n", -- ЗДЕСЬ ИЗМЕНЕНИЕ
                 --   "%s[%s] %s|r\n",
                    "%s[%s] %s\n",
                    prefix,
                    entry.date,
                    entry.status == "available" 
                        and GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_AVA) 
                        or GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA))
            end
        end
        return fullText ~= "" and fullText or "|c999999Нет данных.|r" 
    end,
},
    }
    
    local optionsData = {
        [1] = { type = "checkbox", name = STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A, getFunc = function() return settings.ChatNotificationsEnabled end, setFunc = function(value) settings.ChatNotificationsEnabled = value end, default = defaults.ChatNotificationsEnabled, },
        [2] = { type = "slider", name = STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A, min = 100, max = 5000, step = 100, getFunc = function() return settings.MaxHistoryLines end, setFunc = function(value) settings.MaxHistoryLines = value while #settings.StatusHistory > settings.MaxHistoryLines do table.remove(settings.StatusHistory, 1) end UpdateStatusLog() end, default = defaults.MaxHistoryLines, },
        [3] = { type = "button", name = STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A, func = ResetToDefaults, },
        [4] = { type = "submenu", name = STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION_ESOPLUS, controls = infoOptionsData, },
        [5] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION, text = STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION_A, },
        [6] = { type = "submenu", name = STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME, controls = allRecords, },

    }
    
    LAM:RegisterAddonPanel("EPFTN_Panel", panelData)
    LAM:RegisterOptionControls("EPFTN_Panel", optionsData)
    LAM:RegisterOptionControls("EPFTN_InfoSubmenu", infoOptionsData)
end

-- Event Handlers
  local function OnPlayerActivated(eventCode)
    zo_callLater(function()
        CheckStatus()  
    end, 2000)
    
    em:RegisterForUpdate("EPFTN_PeriodicCheck", 900000, function() CheckStatus() end)
  end

local function OnLogoutAttempt()
    em:UnregisterForUpdate("EPFTN_PeriodicCheck")
end

-- Initialization — ГЛАВНАЯ ФУНКЦИЯ ЗАГРУЗКИ АДДОНА
function EPFTN:Initialize(event, addon)
    if addon ~= EPFTN.name then return end
    em:UnregisterForEvent("EPFTN_load", EVENT_ADD_ON_LOADED)
    
    settings = ZO_SavedVars:NewAccountWide("EsoPlusFreeTrialNotificationSavedVariables", 3, nil, defaults)
    
    
    em:RegisterForEvent("EPFTN_player_activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    em:RegisterForEvent("EPFTN_logout_attempt", EVENT_LOGOUT_ATTEMPT, OnLogoutAttempt)
    
    
    zo_callLater(CreateSettingsPanel, 1000)

    -- **Здесь мы сразу регистрируем команду**
    SLASH_COMMANDS["/esoplus"] = function()
        ManualCheckAndPrint()
    end
end

em:RegisterForEvent("EPFTN_load", EVENT_ADD_ON_LOADED, function(...) 
    EPFTN:Initialize(...) 
end)