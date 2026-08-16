
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_AVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Подписка доступна|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_UNAVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Подписка недоступна|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_LIBADDOMENU, "|cFF0000SafeAddString[ESO Plus]|r Не найдена LibAddonMenu-2.0. Проверьте и установите её.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_STRING_MENU, "|cCCECC0Дата|r                |c98FB98Статус|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM, "|cEEEE00Давайте спросим у @Eswagrom...|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_A, "|c2DF5F8SafeAddString[@Eswagrom] шепчет: Привет, сейчас подписка доступна ИСПОЛЬЗУЙ ЕЁ|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_C, "|c5EB9D7SafeAddString[@Eswagrom]: Привет, что насчёт бесплатной подписки?|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_B, "|c2DF5F8SafeAddString[@Eswagrom] шепчет: Привет, сейчас подписка недоступна -_-|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION, "Отправлять уведомления в чат", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION_A, "|c00FF00Если ВЫКЛ., сообщение в чат про подписку автоматически не будет приходить, останется только ручная проверка /esoplus.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT, "Размер шрифта в таблице", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT_A, "|c00FF00Изменяет размер шрифта окне истории статусов (от 8 до 24)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY, "Таблица записи подписки", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_A, "|c00FF00Открывает отдельное окно с информацией о бесплатной подписке.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_AVA, "|t15:15:/esoui/art/interaction/accept.dds|t |c00FF00доступно|r |t15:15:/esoui/art/interaction/accept.dds|t", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_UNAVA, "|cFF0000X|r |cFF0000недоступно|r |cFF0000X|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES, "Количество строк для записи", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES_A, "|c00FF00Сколько строк будет сохранено в истории SavedVariables файла (влияет на размер файла и длительности записи, по достижению лимита будет перезапись (от 100 до 5000 количество возможных строк)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_RESET_WINDOW, "|cEEEE00Позиция окна сброшена.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME, "|c00FF00Записи EsoPlus|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS, "|cFF6347Сбросить Настройки!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS_A, "|cFF6347Вернуть все настройки аддона к состоянию 'только что установлен'. Сбрасывает положение окна, размер, прозрачность, шрифт, видимость, количество строк (удалит строки свыше записанного лимита!!! изначально 2000 строк) и историю.|r", 1)
    
    -- Информационное сабменю
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS, "|c00FF00Информация про аддон|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_A, "|c9999FF/esoplus|r |cFF6347напишите в чат для ручной проверки!|r Этот аддон сохраняет записи о получении бесплатной подписки, поэтому вы всегда будете точно знать, в какой день она была активирована или отсутствовала. По умолчанию история хранит до 2000 записей. Что это значит на практике? Каждая запись в таблице занимает одну строку за один день. Таким образом, лимит в 2000 строк охватывает период примерно в 2000/365≈5,48 лет. Иными словами, аддон будет хранить историю ваших подписок почти пять с половиной лет.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AA, "|c00FF00api которые использует данный аддон|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAA, "API (Application Programming Interface) — это набор правил, по которым ваш аддон взаимодействует с сервером игры. Проще говоря, это перечень разрешённых команд, которые определяют рамки его возможностей. Для реализации были использованы следующие методы:", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AB, "|c00FF00* HasEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAB, "** _Returns:_ *bool* _hasFreeTrialNotification_", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AC, "|c00FF00* ClearEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAC, "У данного аддона нет функции привязки кнопки для вызова пользовательской таблицы с историей записей, поскольку аддон носит исключительно информационный характер. Эта таблица вам почти никогда не понадобится. Автор сознательно не добавил такую кнопку из-за ограничения в игре: доступно всего 100 слотов под пользовательские клавиши, поэтому занимать их ненужными элементами нецелесообразно.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AD, "|c00FF00Функция автоматической проверки!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAD, "|c9999FFАвтоматические проверки статуса подписки происходит каждые 15 минут, независимо от настроек аддона, это нужно для того, чтобы вы не пропустили статус подписки, если она будет активирована чуть позже этим же днём, функция проверки не нагружает вашу систему. Такой таймер совершенно безопасен для производительности. Вот почему:|r |cFFFFC5Частота выполнения Раз в 15 минут — это крайне редко для игрового движка. Для сравнения: сам клиент ESO обрабатывает десятки тысяч событий каждую секунду (анимация, рендеринг, сетевые пакеты). Одна функция раз в 15 минут — капля в море. - Все операции здесь — чисто логические: чтение статуса аккаунта через встроенный API (HasEsoPlus...), работа с локальной таблицей (Lua table) и вывод сообщения в чат (d()). Здесь нет тяжёлых вычислений, циклов по большим массивам, обращений к файлам или сети. Вызовы вроде ZO_SavedVars, d(), ClearEsoPlus... оптимизированы разработчиками ZOS и выполняются за микросекунды.|r |cffd700Пинг|r определяется качеством интернет-соединения и нагрузкой на серверы ESO. Локальный Lua-таймер клиента никак не отправляет данные на сервер чаще, чем это уже делает сама игра. Функция HasEsoPlusFreeTrialNotification() использует кэшированный статус аккаунта — она не создаёт дополнительного сетевого трафика. |c1E90FFСравнение с другими аддонами.|r Многие популярные аддоны используют гораздо более частые таймеры: |cADD8E6- Inventory Insight|r — проверяет инвентарь при каждом открытии; |cADD8E6- Combat Metrics|r — анализирует каждый тик боя (десятки раз в секунду); - даже стандартные UI-элементы обновляются 60+ раз в секунду. Этот |cADD8E6таймер|r в 900 секунд выглядит как «раз в эпоху» на этом фоне.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO, "|cFF6347Таблица ниже:|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO_A, "|c9999FFТаблица показывает до 20 циклов записией, с какого числа по какое число EsoPlus была доступна или недоступна.|r |cFFFFC5Откройте таблицу:|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_RECORDS, "|ccdfff3Все записи|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_ESOPLUS, "|ccdfff3ИНФОРМАЦИЯ|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG, "список изменений", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGA, "EsoPlusFreeTrialNotification V1.0", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_A, "первая версия", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_AA, "со старой библиотекой LibStub", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGB, "EsoPlusFreeTrialNotification v1.1", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_B, "для ESOUI изменения:", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_BB, "1 удалено подключение к LibStub, добавлено подключеник к LibAddonMenu-2.0\n 2 все языковые файлы с локальными строками\n 3 Исправлены глобальные переменные без локальной ссылки для ускорения доступа к таблице _G\n 4 исправлены некоторые незначительные изменения, подобные описанным выше.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGC, "EsoPlusFreeTrialNotification v1.2", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_C, "Оптимизация кода, часть первая", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_CC, "**1. Единая глобальная таблица Unified Namespace\n **Реализована корректно.\n Используется только одна глобальная таблица: ESOPLUSFREETRIALNOTIFICATION_ESWAGROM с локальным псевдонимом EPFTN.\n 2. Оптимизация доступа G optimization\n Использование local EPFTN ... считается очень хорошим стилем кодирования. Это ускоряет доступ к таблице на микроуровне за счет кэширования ссылки в стеке Lua, что позволяет избежать повторного поиска в медленной глобальной таблице G при каждом вызове функции. 3.\n интегрированное меню настроек: Внешний файл настроек .xml был полностью удален. Все настройки и записи теперь обрабатываются внутри системы, и для удобства работы с ними используется современная библиотека LibAddonMenu-2.0.\n 4. Изменено\n Оптимизация кода:\n Удалены все неиспользуемые настройки и удалено примерно большинство строк устаревшего кода, чтобы значительно уменьшить его размер.\n Значительно оптимизирована оставшаяся кодовая база; логика теперь минимальна, понятна и проста в обслуживании.\n 5. Исправлено\n Пользовательский интерфейс таблицы с возможностью прокрутки: Устранена проблема с внутренней таблицей данных. Реализована полнофункциональная вертикальная полоса прокрутки, позволяющая пользователям легко перемещаться по записям.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGD, "EsoPlusFreeTrialNotification v1.3", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_D, "оптимизация таблицы", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_DD, "1). Оптимизация таблицы истории\n * ** Что изменилось:\n Логика отображения записей в таблице истории была полностью переработана. Ранее каждая строка представляла собой отдельный элемент пользовательского интерфейса с индивидуальным форматированием, что приводило к визуальным ошибкам и задержкам при обработке больших объемов данных.\n Исправлены проблемы со слиянием цветов текста.\n странена секундная задержка при открытии окна дополнения.\n> Почему это произошло?\n Это классическая проблема оптимизации игрового интерфейса:\n Оптимизация памяти: каждое изменение цвета увеличивает нагрузку на процессор и оперативную память. Движок группирует элементы с одинаковыми стилями, чтобы уменьшить количество визуализируемых объектов.\n Ограничение движка (ZO_ScrollList): API ESO имеет ограничение на количество уникальных текстовых форматов в пределах одного прокручиваемого списка. После достижения порогового значения, равного примерно 128 строкам, движок прекращает обработку отдельных цветовых меток (|c...) и начинает применять стиль предыдущей группы ко всем последующим записям.\n Объединение по умолчанию: поскольку многие строки имеют одинаковое форматирование, пользовательский интерфейс рассматривает их как единый логический блок и применяет единый стиль снизу вверх.\n Новое решение:\n В истории теперь хранятся только последние 20 периодов доступности/недоступности EsoPlus. Это обеспечивает достаточный объем информации и гарантирует мгновенное открытие таблицы без каких-либо задержек.\n Важное примечание: Объем данных в файле SavedVariables (даже если он содержит 2000-5000 записей) никак не влияет на производительность в игре. Ограничение распространяется исключительно на визуализацию пользовательского интерфейса.\n **2). Безопасная загрузка локализации\n * ** Улучшена система языкового перевода. Английский теперь служит безопасным базовым якорем (основным языком), после чего выбранная пользователем локализация загружается сверху. Это делает процесс инициализации текста более стабильным и предсказуемым.\n **3). Очистка кода\n * **Все неиспользуемые функции и переменные были удалены из основного файла модификации. Кодовая база теперь стала более чистой, легкой и простой в обслуживании.", 1)
