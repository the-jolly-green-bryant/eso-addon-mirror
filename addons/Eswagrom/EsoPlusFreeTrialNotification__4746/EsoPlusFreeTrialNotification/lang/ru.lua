-- Локальная таблица всех строк — ТРЕБОВАНИЕ ESOUI!
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Подписка доступна|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Подписка недоступна|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r Не найдена LibAddonMenu-2.0. Проверьте и установите её.",
    
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
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00Если что-то забаговало в окне таблице истории - обновите, может это поможет вам.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "|c00FF00доступно|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "|cFF0000недоступно|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Количество строк для записи",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00Сколько строк будет сохранено в истории SavedVariables афйла [влияет на размер файла и длительности записи, по достижению лимита будет перезапись] (от 100 до 5000 количество возможных строк)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Позиция окна сброшена.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00Записи EsoPlus|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347Сбросить Настройки!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Вернуть все настройки аддона к состоянию 'только что установлен'. Сбрасывает положение окна, размер, прозрачность, шрифт, видимость, количество строк (удалит строки свыше записанного лимита!!! изначально 2000 строк) и историю.|r",
    
    -- Информационное сабменю
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00Информация про аддон|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347напишите в чат для ручной проверки!|r Этот аддон сохраняет записи о получении бесплатной подписки, поэтому вы всегда будете точно знать, в какой день она была активирована или отсутствовала. По умолчанию история хранит до 2000 записей. Что это значит на практике? Каждая запись в таблице занимает одну строку за один день. Таким образом, лимит в 2000 строк охватывает период примерно в 2000/365≈5,48 лет. Иными словами, аддон будет хранить историю ваших подписок почти пять с половиной лет.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00api которые использует данный аддон|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "API (Application Programming Interface) — это набор правил, по которым ваш аддон взаимодействует с сервером игры. Проще говоря, это перечень разрешённых команд, которые определяют рамки его возможностей. Для реализации были использованы следующие методы:",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "У данного аддона нет функции привязки кнопки для вызова пользовательской таблицы с историей записей, поскольку аддон носит исключительно информационный характер. Эта таблица вам почти никогда не понадобится. Автор сознательно не добавил такую кнопку из-за ограничения в игре: доступно всего 100 слотов под пользовательские клавиши, поэтому занимать их ненужными элементами нецелесообразно.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00Функция автоматической проверки!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFАвтоматические проверки статуса подписки происходит каждые 15 минут, независимо от настроек аддона, это нужно для того, чтобы вы не пропустили статус подписки, если она будет активирована чуть позже этим же днём, функция проверки не нагружает вашу систему. Такой таймер совершенно безопасен для производительности. Вот почему:|r |cFFFFC5Частота выполнения Раз в 15 минут — это крайне редко для игрового движка. Для сравнения: сам клиент ESO обрабатывает десятки тысяч событий каждую секунду (анимация, рендеринг, сетевые пакеты). Одна функция раз в 15 минут — капля в море. - Все операции здесь — чисто логические: чтение статуса аккаунта через встроенный API (HasEsoPlus...), работа с локальной таблицей (Lua table) и вывод сообщения в чат (d()). Здесь нет тяжёлых вычислений, циклов по большим массивам, обращений к файлам или сети. Вызовы вроде ZO_SavedVars, d(), ClearEsoPlus... оптимизированы разработчиками ZOS и выполняются за микросекунды.|r |cffd700Пинг|r определяется качеством интернет-соединения и нагрузкой на серверы ESO. Локальный Lua-таймер клиента никак не отправляет данные на сервер чаще, чем это уже делает сама игра. Функция HasEsoPlusFreeTrialNotification() использует кэшированный статус аккаунта — она не создаёт дополнительного сетевого трафика. |c1E90FFСравнение с другими аддонами.|r Многие популярные аддоны используют гораздо более частые таймеры: |cADD8E6- Inventory Insight|r — проверяет инвентарь при каждом открытии; |cADD8E6- Combat Metrics|r — анализирует каждый тик боя (десятки раз в секунду); - даже стандартные UI-элементы обновляются 60+ раз в секунду. Этот |cADD8E6таймер|r в 900 секунд выглядит как «раз в эпоху» на этом фоне.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION"] ="|cFF6347Таблица теперь тут ниже:|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION_A"] ="|c9999FFПри отображении большого количества записей (2000 по умолчанию) таблица может открыться с секундной задержкой, это нормально.|r |cFFFFC5Откройте таблицу:|r",

    ["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION__ALLRECORDS"] = "|ccdfff3Все записи|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION_ESOPLUS"] = "|ccdfff3ИНФОРМАЦИЯ|r"

}

-- Регистрация ВСЕХ строк одним циклом — соответствует требованиям ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end