-- define local variables as much as possible, so scope is local
local em       = GetEventManager()
local dx       = 1 / GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

-- БЕЗОПАСНОЕ ПОДКЛЮЧЕНИЕ LAM БЕЗ LIBSTUB
local LAM = LibAddonMenu2
if not LAM then 
    d("|cFF0000[ERROR] LibAddonMenu-2.0 unavailable! Please install LibAddonMenu-2.0>= 43.|r")
    return 
end

-- Единая точка входа — рекомендуемый паттерн ESOUI
ESOPLUSFREETRIALNOTIFICATION_ESWAGROM = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM or {}
local Addon = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM

Addon.name       = "EsoPlusFreeTrialNotification"
Addon.version    = "1.1"

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
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00Если ВЫКЛ., сообщение в чат про подписку автоматически не будет приходить, останется только ручная проверка /esoplus.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "Размер шрифта в таблице",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00Изменяет размер шрифта окне истории статусов (от 8 до 24)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY"] = "Таблица записи подписки",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00Открывает отдельное окно с информацией о бесплатной подписке.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "Заблокировать положение окна",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00Запретит перетаскивать окно по экрану|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "Прозрачность фона",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "Сбросить позицию окна",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "Обновить историю статусов",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00Если что-то забаговало в окне таблице истории — обновите, может это поможет вам.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "доступно",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "недоступно",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Количество строк для записи",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00Сколько строк будет сохранено в истории SavedVariables [влияет на размер файла и длительность записи, по достижению лимита будет перезапись] (от 100 до 5000 количество возможных строк)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Позиция окна сброшена.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00Записи EsoPlus|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347Сбросить Настройки!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Вернуть все настройки аддона к состоянию 'только что установлен'. Сбрасывает положение окна, размер, прозрачность, шрифт, видимость, количество строк (удалит строки свыше записанного лимита!!! изначально 2000 строк) и историю.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00Информация про аддон|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347напишите в чат для ручной проверки!|r Этот аддон сохраняет записи о получении бесплатной подписки, поэтому вы всегда будете точно знать, в какой день она была активирована или отсутствовала. По умолчанию история хранит до 2000 записей. Что это значит на практике? Каждая запись в таблице занимает одну строку за один день. Таким образом, лимит в 2000 строк охватывает период примерно в 2000/365≈5,48 лет. Иными словами, аддон будет хранить историю ваших подписок почти пять с половиной лет.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00api которые использует данный аддон|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "API (Application Programming Interface) — это набор правил, по которым ваш аддон взаимодействует с сервером игры. Проще говоря, это перечень разрешённых команд, которые определяют рамки его возможностей. Для реализации были использованы следующие методы:",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "У данного аддона нет функции привязки кнопки для вызова пользовательской таблицы с историей записей, поскольку аддон носит исключительно информационный характер. Эта таблица вам почти никогда не понадобится. Автор сознательно не добавил такую кнопку из-за ограничения в игре: доступно всего 100 слотов под пользовательские клавиши, поэтому занимать их ненужными элементами нецелесообразно.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00Функция автоматической проверки!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFAвтоматические проверки статуса подписки происходит каждые 15 минут, независимо от настроек аддона, это нужно для того, чтобы вы не пропустили статус подписки, если она будет активирована чуть позже этим же днём, функция проверки не нагружает вашу систему. Такой таймер совершенно безопасен для производительности. Вот почему:|r |cFFFFC5Частота выполнения Раз в 15 минут — это крайне редко для игрового движка. Для сравнения: сам клиент ESO обрабатывает десятки тысяч событий каждую секунду (анимация, рендеринг, сетевые пакеты). Одна функция раз в 15 минут — капля в море. - Все операции здесь — чисто логические: чтение статуса аккаунта через встроенный API (HasEsoPlus...), работа с локальной таблицей (Lua table) и вывод сообщения в чат (d()). Здесь нет тяжёлых вычислений, циклов по большим массивам, обращений к файлам или сети. Вызовы вроде ZO_SavedVars, d(), ClearEsoPlus... оптимизированы разработчиками ZOS и выполняются за микросекунды.|r |cffd700Ping|r определяется качеством интернет-соединения и нагрузкой на серверы ESO. Локальный Lua-таймер клиента никак не отправляет данные на сервер чаще, чем это уже делает сама игра. Функция HasEsoPlusFreeTrialNotification() использует кэшированный статус аккаунта — она не создаёт дополнительного сетевого трафика. |c1E90FFСравнение с другими аддонами.|r Многие популярные аддоны используют гораздо более частые таймеры: |cADD8E6- Inventory Insight|r — проверяет инвентарь при каждом открытии; |cADD8E6- Combat Metrics|r — анализирует каждый тик боя (десятки раз в секунду); - даже стандартные UI-элементы обновляются 60+ раз в секунду. Этот |cADD8E6таймер|r в 900 секунд выглядит как «раз в эпоху» на этом фоне."
}

-- Регистрация ВСЕХ строк одним циклом — ТРЕБОВАНИЕ ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end

-- Теперь можно безопасно использовать GetString()

local settings
local defaults =
{
    WinWidth = 400,
    WinHeight = 200,
    WinPos = { TOPRIGHT, GuiRoot, TOPRIGHT, -10, 10 },
    WinLock = false,
    WinOpacity = 50,
    LogWindowVisible = false,
    StatusHistory = {},
    FontSize = 24,
    ChatNotificationsEnabled = true,
    MaxHistoryLines = 2000
}

-- Локальные переменные сессии
local g_NotificationShownThisSession = false
local g_SentNotifications = { available = false, unavailable = false }

-- ===================================================================
-- ОБЪЯВЛЕНИЕ ВСЕХ ФУНКЦИЙ ДО ТОГО, КАК ОНИ БУДУТ ВЫЗВАНЫ
-- ===================================================================

local function UpdateStatusLog()
    if not Addon.window then return end
    local buffer = Addon.window:GetNamedChild("Buffer")
    if not buffer then return end
    
    buffer:SetFont(string.format("$(GAMEPAD_BOLD_FONT)|%d", settings.FontSize))
    buffer:Clear()
    
    if #settings.StatusHistory == 0 then
        buffer:AddMessage("|c999999История проверок пуста.|r")
        buffer:AddMessage("|c999999Статус проверяется каждые 15 минут или вручную (/esoplus).|r")
        return
    end
    
    buffer:AddMessage("|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t")
    buffer:AddMessage(GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU))
    buffer:AddMessage("|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t")
    
    for i = #settings.StatusHistory, 1, -1 do
        local entry = settings.StatusHistory[i]
        local color = (entry.status == "available") and "|c00FF00" or "|cFF0000"
        local marker = (i == #settings.StatusHistory) and ">> " or "   "
        
        local line = string.format("%s[%s] %s%s|r", 
            marker, entry.date, color, 
            (entry.status == "available") and (GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_AVA)) or (GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA))
        )
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
    if #settings.StatusHistory > settings.MaxHistoryLines then 
        table.remove(settings.StatusHistory, 1) 
    end
end

-- РУЧНАЯ ПРОВЕРКА
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

-- Функции управления окном
local function HideWindow()
    if not Addon.window then return end
    em:UnregisterForUpdate("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_Hide")
    Addon.window:SetHidden(true)
end
Addon.Hide = HideWindow

function Addon.Toggle()
    if not Addon.window then return end
    em:UnregisterForUpdate("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_Hide")
    Addon.window:SetHidden(not Addon.window:IsControlHidden())
end

local function ShowWindow()
    if not Addon.window then return end
    em:UnregisterForUpdate("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_Hide")
    Addon.window:SetHidden(false)
end

function Addon.MoveWin()
    if not Addon.window then return end
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = Addon.window:GetAnchor()
    local width, height = Addon.window:GetDimensions()
    if (isValidAnchor) then settings.WinPos = { point, relativeTo, relativePoint, offsetX, offsetY } end
    settings.WinWidth = width
    settings.WinHeight = height
end

local function ToggleStatusWindow(isVisible)
    if isVisible then
        ShowWindow()
        UpdateStatusLog()
    else
        HideWindow()
    end
end

-- Slash Commands
local function InitializeSlashCommand()
    SLASH_COMMANDS["/esoplus"] = function()
        Addon.ManualCheckAndPrint()
    end
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

    if Addon.window then
        Addon.window:ClearAnchors()
        Addon.window:SetAnchor(unpack(settings.WinPos))
        Addon.window:SetDimensions(settings.WinWidth, settings.WinHeight)
        
        local bg = Addon.window:GetNamedChild("Bg")
        if bg then
            bg:SetAlpha(settings.WinOpacity / 100)
        end
        
        Addon.window:SetMouseEnabled(not settings.WinLock)
        
        local title = Addon.window:GetNamedChild("Title")
        if title then
            title:SetText(GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME))
        end
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
        version = "|cff80801.1|r",
    }
    
    local infoOptionsData = {
        [1] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A, },
        [2] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA, },
        [3] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB, },
        [4] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC, },
        [5] = { type = "description", title = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD, text = STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD, },
    }
    
    local optionsData = {
        [1] = { type = "checkbox", name = STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A, getFunc = function() return settings.ChatNotificationsEnabled end, setFunc = function(value) settings.ChatNotificationsEnabled = value end, default = defaults.ChatNotificationsEnabled, },
        [2] = { type = "slider", name = STRING_ESOPLUSFREETRIALNOTIFICATION_FONT, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A, min = 8, max = 24, step = 1, getFunc = function() return settings.FontSize end, setFunc = function(value) settings.FontSize = value UpdateStatusLog() end, default = defaults.FontSize, },
        [3] = { type = "slider", name = STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A, min = 100, max = 5000, step = 100, getFunc = function() return settings.MaxHistoryLines end, setFunc = function(value) settings.MaxHistoryLines = value while #settings.StatusHistory > settings.MaxHistoryLines do table.remove(settings.StatusHistory, 1) end UpdateStatusLog() end, default = defaults.MaxHistoryLines, },
        [4] = { type = "checkbox", name = STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A, getFunc = function() return settings.LogWindowVisible end, setFunc = function(value) settings.LogWindowVisible = value ToggleStatusWindow(value) end, default = defaults.LogWindowVisible, },
        [5] = { type = "checkbox", name = STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A, getFunc = function() return settings.WinLock end, setFunc = function(value) if Addon.window then Addon.window:SetMouseEnabled(not value) end end, default = defaults.WinLock, },
        [6] = { type = "slider", name = STRING_ESOPLUSFREETRIALNOTIFICATION_AAA, min = 0, max = 100, step = 5, getFunc = function() return settings.WinOpacity end, setFunc = function(value) if Addon.window then Addon.window:GetNamedChild("Bg"):SetAlpha(value / 100) end end, default = defaults.WinOpacity, },
        [7] = { type = "button", name = STRING_ESOPLUSFREETRIALNOTIFICATION_BBB, func = function() settings.WinPos = {TOPRIGHT, GuiRoot, TOPRIGHT, -10, 10} if Addon.window then Addon.window:ClearAnchors() Addon.window:SetAnchor(unpack(settings.WinPos)) end d(GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW)) end, },
        [8] = { type = "button", name = STRING_ESOPLUSFREETRIALNOTIFICATION_CCC, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H, func = function() if settings.LogWindowVisible then UpdateStatusLog() end end, },
        [9] = { type = "button", name = STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS, tooltip = STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A, func = ResetToDefaults, },
        [10] = { type = "submenu", name = STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION_ESOPLUS, controls = infoOptionsData, },
    }
    
    LAM:RegisterAddonPanel("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_Panel", panelData)
    LAM:RegisterOptionControls("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_Panel", optionsData)
    LAM:RegisterOptionControls("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_InfoSubmenu", infoOptionsData)
end

-- Event Handlers
local function OnPlayerActivated(eventCode)
    zo_callLater(function()
        ToggleStatusWindow(settings.LogWindowVisible)
        CheckStatus()  -- Используем напрямую, а не через Addon.CheckStatus
    end, 2000)
    
    em:RegisterForUpdate("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_PeriodicCheck", 900000, function() CheckStatus() end)
end

local function OnLogoutAttempt()
    em:UnregisterForUpdate("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_PeriodicCheck")
end

-- Initialization — ГЛАВНАЯ ФУНКЦИЯ ЗАГРУЗКИ АДДОНА
function Addon:Initialize(event, addon)
    if addon ~= Addon.name then return end
    em:UnregisterForEvent("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_load", EVENT_ADD_ON_LOADED)
    
    settings = ZO_SavedVars:NewAccountWide("EsoPlusFreeTrialNotificationSavedVariables", 3, nil, defaults)
    Addon.window = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_TLW2
    
    em:RegisterForEvent("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_player_activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    em:RegisterForEvent("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_logout_attempt", EVENT_LOGOUT_ATTEMPT, OnLogoutAttempt)
    
    if Addon.window then
        Addon.window:ClearAnchors()
        Addon.window:SetAnchor(unpack(settings.WinPos))
        Addon.window:SetDimensions(settings.WinWidth, settings.WinHeight)
        Addon.window:GetNamedChild("Title"):SetText(GetString(STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME))
        Addon.window:GetNamedChild("Bg"):SetAlpha(settings.WinOpacity / 100)
        Addon.window:SetMouseEnabled(not settings.WinLock)
    end
    
    zo_callLater(CreateSettingsPanel, 1000)
    InitializeSlashCommand()
end

em:RegisterForEvent("ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_load", EVENT_ADD_ON_LOADED, function(...) 
    Addon:Initialize(...) 
end)