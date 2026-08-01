local AST = AsylumTracker
AST.lang.ru = {}

-- Имена боссов на русском клиенте (ищутся как подстрока в имени юнита: "Святой Ллотис Благочестивый" и т.п.)
AST.lang.ru.bossNames = {
     llothis = { "Ллотис" },
     felms = { "Фелмс" },
}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Настройка Asylum Tracker",
     ["AST_SETT_INFO"] = "Описание Asylum Tracker",
     ["AST_SETT_DESCRIPTION"] = "Оповещения механик в триале Изоляционный санктуарий.",
     ["AST_SETT_NOTIFICATIONS"] = "Оповещения",
     ["AST_SETT_LANGUAGE"] = "Язык",
     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Основной язык",
     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Игнорировать локализацию игры и загрузить выбранный язык для аддона",
     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Выбрать язык для загрузки",

     ["AST_SETT_TIMERS"] = "Настройки таймера(BETA)",
     ["AST_SETT_OLMS_ADJUST"] = "Адаптация таймеров Олмса",
     ["AST_SETT_LLOTHIS_ADJUST"] = "Адаптация таймеров Ллотиса",
     ["AST_SETT_OLMS_ADJUST_DESC"] = "Адаптация таймеров Олмса на аккаунте, когда время других механик достигает 0",
     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Адаптация таймера Прерывания атаки Ллотиса, после механики Конуса",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "Разблокировать",
     ["AST_SETT_LOCK"] = "Заблокировать",
     ["AST_SETT_UNLOCK_TOOL"] = "Показывает все элементы и делает их подвижными",

     -- Generics
     ["AST_SETT_YOU"] = "|cB22222 НА ТЕБЕ|r", --cB22222 красный
     ["AST_SETT_SOON"] = "СКОРО",
     ["AST_SETT_NOW"] = "СЕЙЧАС",
     ["AST_SETT_COLOR"] = "Цвет",
     ["AST_SETT_COLOR_1"] = "Основной цвет",
     ["AST_SETT_COLOR_2"] = "Дополнительный цвет",
     ["AST_SETT_FONT_SIZE"] = "Размер шрифта",
     ["AST_SETT_SCALE"] = "Размер",
     ["AST_SETT_SCALE_WARN"] = "При настройке этого параметра, оповещения станут размытыми. Сначала настройте размер шрифта.",
     ["AST_SETT_TIMER_COLOR"] = "Цвет таймера",
     ["AST_SETT_TIMER_COLOR_TOOL"] = "Цвет для обратного отсчета, отображаемого на таймерах",

     -- Center Notifications Button
     ["AST_SETT_CENTER_NOTIF"] = "Позиция по умолчанию",
     ["AST_SETT_CENTER_NOTIF_TOOL"] = "Возвращает местоположение оповещений на стандартное",

     -- OdySupportIcons Support
     ["AST_SETT_OSI_SUPPORT"] = "Поддержка OdySupportIcons",
     ["AST_SETT_OSI_SUPPORT_TOOL"] = "Показывать метки над головами игроков через OdySupportIcons для механик боссов. Требуется аддон OdySupportIcons",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "Звук",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "Звук для механик Оскверняющий взрыв (Конус) и Небесная буря (Кайт)",

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "Оповещения для Ллотиса", -- Notifications for Llothis
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "Добавляет оповещения, когда Ллотис собирается встать, когда он встает и когда он падает",
     ["AST_SETT_FELMS_NOTIF"] = "Оповещения для Фелмса", -- Notifications for Felms
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "Добавляет оповещения, когда Фелмс собирается встать, когда он встает и когда он падает",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "Здоровье Олмса: размер шрифта", -- Font Size for Olms' HP Notification
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "Размер шрифта для отображаемого здоровья Олмса",
     ["AST_SETT_OLMS_HP_SCALE"] = "Здоровье Олмса: масштаб",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "Изменить масштаб здоровья Олмса",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "Цвет, когда до прыжков Олмса осталось меньше 5%",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "Цвет, когда до прыжков Олмса осталось меньше 2%",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "|c87CEEB    НЕБЕСНАЯ БУРЯ|r",
     ["AST_SETT_STORM_TOOL"] = "Storm the Heavens.\nФаза кайта, когда по вам бьет молнией несколько раз.\n|cFF7F50 Для всех|r",
     ["AST_SETT_STORM_SIZE_TOOL"] = "Размер шрифта",
     ["AST_SETT_STORM_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "Первый мигающий цвет",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "Второй мигающий цвет",
     ["AST_SETT_STORM_SOUND_EFFECT"] = "Звук",
     ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "Звук, который будет использоваться для Storm the Heavens.",
     ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "Громкость звука",
     ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "Громкость звука для Storm the Heavens",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "|c87CEEB    ОСКВЕРНЯЮЩИЙ ВЗРЫВ|r", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_BLAST_TOOL"] = "Defiling Dye Blast.\nКонусная ядовитая атака Ллотиса, принимать в блок, если вы цель.\n|cFF7F50 Для всех|r",
     ["AST_SETT_BLAST_OSI"] = "Иконка OdySI",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "Размер шрифта",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "Цвет оповещения атаки",
     ["AST_SETT_BLAST_SOUND_EFFECT"] = "Звук",
     ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "Звук, который будет использоваться для Оскверняющий взрыв.",
     ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "Громкость звука",
     ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "Громкость звука для Оскверняющий взрыв.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "|c87CEEB    ОРГАНИЗОВАННЫЙ ЗАЩИТНИК|r", -- The little sphere's the shield Olms
     ["AST_SETT_PROTECT_TOOL"] = "Protectors.\nСферы, которые защищают Олмса щитами\n|cFF7F50 Для ДД и Хила|r",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "Размер шрифта",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "масштаб оповещения для Сфер",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "Основной цвет",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "Второй цвет",
     ["AST_SETT_PROTECT_MESSAGE"] = "Свое сообщение",
     ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Введите сообщение, которое желаете видеть во время сфер",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "|c87CEEB    ТЕЛЕПОРТИРУЮЩИЙ УДАР|r", -- Felms' jumping mechanic
     ["AST_SETT_JUMP_TOOL"] = "Teleport Strike.\nПрыжок Фелмса, оставляет после приземления большое АОЕ\n|cFF7F50 Для хилов|r",
     ["AST_SETT_JUMP_OSI"] = "Иконка OdySI",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "Размер шрифта",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "Цвет оповещения для Телепортирующий удар",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "|c87CEEB    СКВЕРНА НЕЧИСТОЙ ДУШИ|r", -- Llothis' attack that needs to be interrupted
     ["AST_SETT_BOLTS_TOOL"] = "Oppressive Bolts.\nПрерываемая атака Ллотиса, массовый урон по группе ядовитыми каплями\n|cFF7F50 Для ДД|r",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "Размер шрифта оповещения",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "Цвет оповещения для Скверна нечистой души",
     ["AST_SETT_INTTERUPT"] = "Сообщение о прерывании",
     ["AST_SETT_INTTERUPT_TOOL"] = "Отображает сообщение, когда атака Ллотиса прервана",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "|c87CEEB    ОБЖИГАЮЩИЙ РЕВ|r", -- Olms' steam breath attack
     ["AST_SETT_STEAM_TOOL"] = "Steam Breath.\nДыхание Олмса, направлено в текущую цель (танка)\n|cFF7F50 Для танка и фронт хила|r",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "Размер шрифта оповещения",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "Цвет оповещения для Обжигающий рев",

     -- Exhaustive Charges
     ["AST_SETT_CHARGES"] = "|c87CEEB    ИЗНУРЯЮЩИЕ ЗАРЯДЫ|r",
     ["AST_SETT_CHARGES_TOOL"] = "Exhaustive Charges.\nЭлектрическая атака Олмса, на дополнительные цели перед собой\n|cFF7F50 Для фронт хила и возможно танка|r",
     ["AST_SETT_CHARGES_SIZE_TOOL"] = "Размер шрифта оповещения",
     ["AST_SETT_CHARGES_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_CHARGES_COLOR_TOOL"] = "Цвет оповещения для Изнуряющие заряды",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "|c87CEEB    ИСПЫТАНИЕ ОГНЕМ|r", -- Olms' Fire mechanic below 25% HP
     ["AST_SETT_FIRE_TOOL"] = "Trial By Fire.\nАтака Олмса, гигантские красные огненные лужи, которые заполнят большую часть арены когда его здоровье <25%, отойти в безопасное место\n|cFF7F50 Для всех|r",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "Размер шрифта оповещения",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "Цвет оповещения для Испытание огнем",

     -- Maim
     ["AST_SETT_MAIM"] = "|c87CEEB    ВОПЛОЩЕНИЕ ГНЕВА|r", -- Felms' Maim debuff
     ["AST_SETT_MAIM_TOOL"] = "Manifest Wrath.\nАтака Фелмса, после детонации оставляет расходящиеся в стороны красные волны.\n|cFF7F50 Для всех|r",
     ["AST_SETT_MAIM_OSI"] = "Иконка OdySI",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "Размер шрифта оповещения",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "масштаб оповещения",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "Цвет оповещения для Воплощение гнева",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "ЛЛОТИС ВСТАНЕТ ЧЕРЕЗ 10 СЕКУНД", -- Llothis will be back up in 10 seconds (because when he gets killed in the fight, he doesn't die, he goes dormant and then gets back up after ~35s)
     ["AST_NOTIF_LLOTHIS_IN_5"] = "ЛЛОТИС ВСТАНЕТ ЧЕРЕЗ 5 СЕКУНД",
     ["AST_NOTIF_LLOTHIS_UP"] = "ЛЛОТИС АКТИВЕН", -- Llothis stands back up
     ["AST_NOTIF_LLOTHIS_DOWN"] = "ЛЛОТИС ПОВЕРЖЕН", -- llothis goes dormant.
     ["AST_NOTIF_FELMS_IN_10"] = "ФЕЛМС ВСТАНЕТ ЧЕРЕЗ 10 СЕКУНД",
     ["AST_NOTIF_FELMS_IN_5"] = "ФЕЛМС ВСТАНЕТ ЧЕРЕЗ 5 СЕКУНД",
     ["AST_NOTIF_FELMS_UP"] = "ФЕЛМС АКТИВЕН",
     ["AST_NOTIF_FELMS_DOWN"] = "ФЕЛМС ПОВЕРЖЕН",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "ПРЫЖКИ, В СТОРОНЫ!", -- For when Olms jumps at 90/75/50/25% HP
     ["AST_NOTIF_PROTECTOR"] = "БЕЙ СФЕРУ", -- Referring to the protectors
     ["AST_NOTIF_KITE"] = "Кайт: ", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_KITE_NOW"] = "К А Й Т СЕЙЧАС", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_BLAST"] = "Конус: ", -- Referring to Llothis' Cone attack. (Cone would probably be a better word to translate than blast)
     ["AST_NOTIF_JUMP"] = "Прыжок Фелмса: ",
     ["AST_NOTIF_BOLTS"] = "Прерви Ллотиса:  ", -- Referring to Llothis' Oppressive bolts attack
     ["AST_NOTIF_INTERRUPT"] = "ПРЕРВИ СЕЙЧАС ", -- For when you need to Interrupt Llothis' oppressive bolts attack
     ["AST_NOTIF_FIRE"] = "ОГОНЬ, ИЗБЕГАЙ: ",
     ["AST_NOTIF_STEAM"] = "ДЫХАНИЕ! В Ы Й Д И:  ", -- Referring to Olms' Steam breath
     ["AST_NOTIF_MAIM"] = "Гнев: ", -- Referring to Felms' Maim
     ["AST_NOTIF_CHARGES"] = "Заряды: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "ОЛМС",
     ["AST_PREVIEW_OLMS_HP_2"] = "ХП",
     ["AST_PREVIEW_STORM_1"] = "КАЙТ",
     ["AST_PREVIEW_STORM_2"] = "СЕЙЧАС",
     ["AST_PREVIEW_SPHERE_1"] = "СФЕРА",
     ["AST_PREVIEW_SPHERE_2"] = "#",
     ["AST_PREVIEW_BLAST"] = "КОНУС",
     ["AST_PREVIEW_JUMP"] = "ПРЫЖОК ФЕЛМСА",
     ["AST_PREVIEW_BOLTS"] = "СКВЕРНА",
     ["AST_PREVIEW_FIRE"] = "ОГОНЬ",
     ["AST_PREVIEW_STEAM"] = "ДЫХАНИЕ",
     ["AST_PREVIEW_MAIM"] = "ГНЕВ",
     ["AST_PREVIEW_CHARGES"] = "ЗАРЯДЫ",
}

function AST.lang.ru.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
