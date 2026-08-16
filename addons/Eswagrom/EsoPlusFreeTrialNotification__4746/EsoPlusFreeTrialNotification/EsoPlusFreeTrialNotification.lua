-- define local variables as much as possible, so scope is local
local em       = GetEventManager()
local dx       = 1 / GetSetting(SETTING_TYPE_UI, UI_SETTING_CUSTOM_SCALE)

-- БЕЗОПАСНОЕ ПОДКЛЮЧЕНИЕ LAM
local LAM = LibAddonMenu2

-- Единая точка входа — рекомендуемый паттерн ESOUI
ESOPLUSFREETRIALNOTIFICATION_ESWAGROM = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM or {}

-- === ОПТИМИЗАЦИЯ ДОСТУПА К ГЛОБАЛЬНОЙ ТАБЛИЦЕ (_G optimization) ===
local EPFTN = ESOPLUSFREETRIALNOTIFICATION_ESWAGROM

EPFTN.name       = "EsoPlusFreeTrialNotification"
EPFTN.version    = "1.3"

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
        buffer:AddMessage(GetString(SI_ESOPLUSFREETRIALNOTIF_STRING_MENU))
        buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])
        buffer:AddMessage("|c999999История проверок пуста.|r")
        buffer:AddMessage("|c999999Статус проверяется каждые 15 минут или вручную (/esoplus).|r")
        return
    end

    -- Добавление заголовков
    buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])
    buffer:AddMessage(GetString(SI_ESOPLUSFREETRIALNOTIF_STRING_MENU))
    buffer:AddMessage([[|t230:3:/esoui/art/veterancy/vengeance_rankcomplete_bg.dds|t]])

    for i = #settings.StatusHistory, 1, -1 do
        local entry = settings.StatusHistory[i]
        local color = (entry.status == "available") and "|c00FF00" or "|cFF0000"
        local marker = (i == #settings.StatusHistory) and ">> " or "   "
        
        local line = string.format("%s[%s] %s%s|r", marker, entry.date, color, entry.status == "available" and GetString(SI_ESOPLUSFREETRIALNOTIF_AVA) or GetString(SI_ESOPLUSFREETRIALNOTIF_UNAVA))
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
                local msg = GetString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_AVAILABLE)
                if msg then d(msg) end
                g_SentNotifications.available = true
                g_SentNotifications.unavailable = false
            end
        else
            if not g_SentNotifications.unavailable then
                local msg = GetString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_UNAVAILABLE)
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
    local welcomeMsg = GetString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM)
    if welcomeMsg then d(welcomeMsg) end
    
    local hasSub = HasEsoPlusFreeTrialNotification()
    
    RecordStatus(hasSub)
    UpdateStatusLog()
    
    zo_callLater(function()
        local cMsg = GetString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_C)
        if cMsg then d(cMsg) end
    end, 1500)
    
    zo_callLater(function()
        if hasSub then
            local aMsg = GetString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_A)
            if aMsg then d(aMsg) end
        end
    end, 4500)
    
    zo_callLater(function()
        if not hasSub then
            local bMsg = GetString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_B)
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
        version = "|cff80801.3|r",
    }

local allChangelog = {

    [1] = { 
        type = "submenu", 
        name = SI_ESOPLUSFREETRIALNOTIF_CHANGELOGA, -- заголовок первого пункта меню
        controls = {
            [1] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_A, text = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_AA, },
        }
    },
    
    [2] = { 
        type = "submenu", 
        name = SI_ESOPLUSFREETRIALNOTIF_CHANGELOGB,
        controls = {
            [1] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_B, text = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_BB, },
        }
    },
    
    [3] = { 
        type = "submenu", 
        name = SI_ESOPLUSFREETRIALNOTIF_CHANGELOGC,
        controls = {
            [1] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_C, text = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_CC, },
        }
    },
    
    [4] = { 
        type = "submenu", 
        name = SI_ESOPLUSFREETRIALNOTIF_CHANGELOGD,
        controls = {
            [1] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_D, text = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_DD, },
        }
    },
}
    




    local infoOptionsData = {
        [1] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS, text = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_A, },
        [2] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AA, text = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAA, },
        [3] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AB, text = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAB, },
        [4] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AC, text = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAC, },
        [5] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AD, text = SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAD, },
    }

    local allRecords = {
[1] = {
    type = "description",
    name = "|cFFFFFFПоследние записи|r",
    text = function()
        -- Локализуем строки один раз
        local statusText = {
            available = GetString(SI_ESOPLUSFREETRIALNOTIF_AVA),
            unavailable = GetString(SI_ESOPLUSFREETRIALNOTIF_UNAVA)
        }
        
        if not settings or not settings.StatusHistory or #settings.StatusHistory == 0 then 
            return "|c999999Нет данных.|r" 
        end

        local fullText = ""
        local groupCount = 0 -- Счётчик уже сформированных групп периодов
        local history = settings.StatusHistory
        local totalEntries = #history

        -- Начинаем с самого последнего элемента (новейшая запись)
        local currentStatus = history[totalEntries].status
        local startDate = history[totalEntries].date

        -- Проходим историю НАЗАД: от предпоследней к самой первой (от новых к старым)
        for i = totalEntries - 1, 1, -1 do
            local entry = history[i]
            
            -- Если статус изменился или запись некорректна
            if not entry.status or entry.status ~= currentStatus then
                -- Закрываем текущий (более новый) период и ДОБАВЛЯЕМ его В КОНЕЦ текста
                if groupCount < 20 then
                    local periodText = string.format("[%s — %s]: %s", 
                        startDate,     -- Начало периода
                        history[i + 1].date, -- Конец периода (следующая более новая запись)
                        statusText[currentStatus]
                    )
                    
                    -- Добавляем разделитель только если это НЕ первая группа
                    if #fullText > 0 then
                        fullText = fullText .. "\n"
                    end
                    fullText = fullText .. periodText
                    groupCount = groupCount + 1
                else
                    -- Достигли лимита в 20 групп, прерываем обработку
                    break
                end

                -- Начинаем новый (более старый) период
                currentStatus = entry.status
                startDate = entry.date
            end
        end

        -- После цикла добавляем самый первый открытый период (он будет самым старым из показанных 20-ти)
        -- Проверяем лимит ещё раз на случай, если вся история состоит из одного статуса
        if groupCount < 20 then
            if #fullText > 0 then
                fullText = fullText .. "\n"
            end
            fullText = fullText .. string.format("[%s — %s]: %s", 
                history[1].date, -- Самая старая дата в истории
                startDate,       -- Дата последней смены статуса перед концом списка
                statusText[currentStatus]
            )
        end

        return tostring(fullText)
    end,
},
    }
    
    local optionsData = {
        [1] = { type = "checkbox", name = SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION, tooltip = SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION_A, getFunc = function() return settings.ChatNotificationsEnabled end, setFunc = function(value) settings.ChatNotificationsEnabled = value end, default = defaults.ChatNotificationsEnabled, },
        [2] = { type = "slider", name = SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES, tooltip = SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES_A, min = 100, max = 5000, step = 100, getFunc = function() return settings.MaxHistoryLines end, setFunc = function(value) settings.MaxHistoryLines = value while #settings.StatusHistory > settings.MaxHistoryLines do table.remove(settings.StatusHistory, 1) end UpdateStatusLog() end, default = defaults.MaxHistoryLines, },
        [3] = { type = "button", name = SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS, tooltip = SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS_A, func = ResetToDefaults, },
        [4] = { type = "submenu", name = SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_ESOPLUS, controls = infoOptionsData, },
        [5] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO, text = SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO_A, },
        [6] = { type = "submenu", name = SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME, controls = allRecords, },
        [7] = { type = "description", title = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG, text = SI_ESOPLUSFREETRIALNOTIF_CNANGEINFO, },
        [8] = { type = "submenu", name = SI_ESOPLUSFREETRIALNOTIF_CHANGELOG, controls = allChangelog, },

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