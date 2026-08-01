local AST = AsylumTracker
AST.lang.ru = {}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Настройка Asylum Tracker",
     ["AST_SETT_INFO"] = "Описание Asylum Tracker",
     ["AST_SETT_DESCRIPTION"] = "Добавляет подсказки для помощи в Изоляционном санктуарии.",
     ["AST_SETT_NOTIFICATIONS"] = "Оповещения",
     ["AST_SETT_LANGUAGE"] = "Язык",
     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Основной язык",
     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Игнорировать локализацию игры и загрузить выбранный язык для аддона",
     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Выбрать язык для загрузки",

     ["AST_SETT_TIMERS"] = "Настройки таймера(BETA)",
     ["AST_SETT_OLMS_ADJUST"] = "Adjust Olms' timers",
     ["AST_SETT_LLOTHIS_ADJUST"] = "Adjust Llothis' timers",
     ["AST_SETT_OLMS_ADJUST_DESC"] = "Adjust Olms' timers to account for other mechanics happening when a timer reaches 0",
     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Adjust Oppressive Bolts timer to account for Defiling Blast happening when the oppressive bolts timer reaches 0",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "Разблокировать",
     ["AST_SETT_LOCK"] = "Заблокировать",
     ["AST_SETT_UNLOCK_TOOL"] = "Показывает все элементы и делает их подвижными",

     -- Generics
     ["AST_SETT_YOU"] = "ТЫ",
     ["AST_SETT_SOON"] = "СКОРО",
     ["AST_SETT_NOW"] = "СЕЙЧАС",
     ["AST_SETT_COLOR"] = "Цвет",
     ["AST_SETT_COLOR_1"] = "Основной цвет",
     ["AST_SETT_COLOR_2"] = "Дополнительный цвет",
     ["AST_SETT_FONT_SIZE"] = "Размер шрифта",
     ["AST_SETT_SCALE"] = "Размер",
     ["AST_SETT_SCALE_WARN"] = "При настройке этого параметра, оповещения станут размытыми. Сначала настройте размер шрифта.",
     ["AST_SETT_TIMER_COLOR"] = "Цвет таймера",
     ["AST_SETT_TIMER_COLOR_TOOL"] = "Цвет для обратного отсчета, отоброжаемого на таймерах",

     -- Center Notifications Button
     ["AST_SETT_CENTER_NOTIF"] = "Сбросить позиции",
     ["AST_SETT_CENTER_NOTIF_TOOL"] = "Сбрасывает оповещения до их стандартной позиции",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "Звук",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "Звук для механик Defiling Blast и Storm the Heavens",

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "Оповещения для Ллотиса", -- Notifications for Llothis
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "Добавляет оповещения о том, когда Ллотис собирается встать, когда он встает и когда он падает",
     ["AST_SETT_FELMS_NOTIF"] = "Оповещения для Фелмса", -- Notifications for Felms
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "Добовляет оповещения о том, когда Фелмс собирается встать, когда он встает и когда он падает",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "Здоровье Олмса: Размер шрифта", -- Font Size for Olms' HP Notification
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "Размер шрифта для отображаемого здоровья Олмса",
     ["AST_SETT_OLMS_HP_SCALE"] = "Здоровье Олмса: Размер отображения",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "Размер отображения здоровья Олмса",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "Цвет, когда до прыжков Олмса осталось меньше 5%",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "Цвет, когда до прыжков Олмса осталось меньше 2%",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "Storm the Heavens", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_STORM_TOOL"] = "Фаза кайта Олмса",
     ["AST_SETT_STORM_SIZE_TOOL"] = "Размер шрифта оповещения для Storm the Heavens",
     ["AST_SETT_STORM_SCALE_TOOL"] = "Размер оповещения для Storm the Heavens",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "Первый мигающий цвет",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "Второй мигающий цвет",
     ["AST_SETT_STORM_SOUND_EFFECT"] = "Звук",
     ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "Звук, который будет использоваться для Storm the Heavens.",
     ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "Громкость звука",
     ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "Громкость звука для Storm the Heavens",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "Defiling Blast", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_BLAST_TOOL"] = "Defiling Blast Ллотиса",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "Размер шрифта оповещения для Defiling Blast",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "Размер оповещения для Defiling Blast",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "Цвет оповещения атаки Defiling Blast Ллотиса",
     ["AST_SETT_BLAST_SOUND_EFFECT"] = "Звук",
     ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "Звук, который будет использоваться для Defiling Blast.",
     ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "Громкость звука",
     ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "Громкость звука для Defiling Blast.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "Сферы", -- The little sphere's the shield Olms
     ["AST_SETT_PROTECT_TOOL"] = "Сферы, которые защищают Олмса",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "Размер шрифта оповещения для Сфер",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "Размер оповещения для Сфер",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "First Color for Protector shielding Olms",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "Second Color for Protector shielding Olms",
     ["AST_SETT_PROTECT_MESSAGE"] = "Sphere Text",
     ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Set Custom text for the protector",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "Teleport Strike", -- Felms' jumping mechanic
     ["AST_SETT_JUMP_TOOL"] = "Прыжок Фелмса",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "Размер шрифта оповещения для Telport Strike",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "Размер оповещения для Teleport Strike",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "Цвет оповещения для Teleport Strike",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "Oppressive Bolts", -- Llothis' attack that needs to be interrupted
     ["AST_SETT_BOLTS_TOOL"] = "Прерываемая атака Ллотиса",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "Размер шрифта оповещения для Oppressive Bolts",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "Размер оповещения для Oppressive Bolts",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "Цвет оповещения для Oppressive Bolts Ллотиса",
     ["AST_SETT_INTTERUPT"] = "Сообщение о прерывании",
     ["AST_SETT_INTTERUPT_TOOL"] = "Отображает сообщение, когда атака Ллотиса прервана",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "Steam Breath", -- Olms' steam breath attack
     ["AST_SETT_STEAM_TOOL"] = "Дыхание Олмса",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "Размер шрифта оповещения для Steam Breath",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "Размер оповещения для Steam Breath",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "Цвет оповещения для Steam Breath",

     -- Exhaustive Charges
     ["AST_SETT_CHARGES"] = "Exhaustive Charges",
     ["AST_SETT_CHARGES_TOOL"] = "Электрическая атака Олмса",
     ["AST_SETT_CHARGES_SIZE_TOOL"] = "Размер шрифта оповещения для Exhaustive Charges",
     ["AST_SETT_CHARGES_SCALE_TOOL"] = "Размер оповещения для Exhaustive Charges",
     ["AST_SETT_CHARGES_COLOR_TOOL"] = "Цвет оповещения для Exhaustive Charges",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "Trial By Fire", -- Olms' Fire mechanic below 25% HP
     ["AST_SETT_FIRE_TOOL"] = "Огненная атака Олмса, когда его здоровье <25%",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "Размер шрифта оповещения для Trial By Fire",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "Размер оповещения для Trial By Fire",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "Цвет оповещения для Trial By Fire",

     -- Maim
     ["AST_SETT_MAIM"] = "Maim", -- Felms' Maim debuff
     ["AST_SETT_MAIM_TOOL"] = "Felms' Maim",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "Change the Font Size for Maim",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "Change the Scale for Maim",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "Color for Felms' Maim",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "LLOTHIS IN 10 SECONDS", -- Llothis will be back up in 10 seconds (because when he gets killed in the fight, he doesn't die, he goes dormant and then gets back up after ~35s)
     ["AST_NOTIF_LLOTHIS_IN_5"] = "LLOTHIS IN 5 SECONDS",
     ["AST_NOTIF_LLOTHIS_UP"] = "LLOTHIS IS UP", -- Llothis stands back up
     ["AST_NOTIF_LLOTHIS_DOWN"] = "LLOTHIS IS DOWN", -- llothis goes dormant.
     ["AST_NOTIF_FELMS_IN_10"] = "FELMS IN 10 SECONDS",
     ["AST_NOTIF_FELMS_IN_5"] = "FELMS IN 5 SECONDS",
     ["AST_NOTIF_FELMS_UP"] = "FELMS IS UP",
     ["AST_NOTIF_FELMS_DOWN"] = "FELMS IS DOWN",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "JUMPING", -- For when Olms jumps at 90/75/50/25% HP
     ["AST_NOTIF_PROTECTOR"] = "SPHERE", -- Referring to the protectors
     ["AST_NOTIF_KITE"] = "KITE: ", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_KITE_NOW"] = "KITE NOW", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_BLAST"] = "BLAST: ", -- Referring to Llothis' Cone attack. (Cone would probably be a better word to translate than blast)
     ["AST_NOTIF_JUMP"] = "FELMS JUMP: ",
     ["AST_NOTIF_BOLTS"] = "BOLTS: ", -- Referring to Llothis' Oppressive bolts attack
     ["AST_NOTIF_INTERRUPT"] = "INTERRUPT", -- For when you need to Interrupt Llothis' oppressive bolts attack
     ["AST_NOTIF_FIRE"] = "FIRE: ",
     ["AST_NOTIF_STEAM"] = "STEAM: ", -- Referring to Olms' Steam breath
     ["AST_NOTIF_MAIM"] = "MAIM: ", -- Referring to Felms' Maim
     ["AST_NOTIF_CHARGES"] = "CHARGES: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "OLMS",
     ["AST_PREVIEW_OLMS_HP_2"] = "HP",
     ["AST_PREVIEW_STORM_1"] = "KITE",
     ["AST_PREVIEW_STORM_2"] = "NOW",
     ["AST_PREVIEW_SPHERE_1"] = "SPH",
     ["AST_PREVIEW_SPHERE_2"] = "ERE",
     ["AST_PREVIEW_BLAST"] = "BLAST",
     ["AST_PREVIEW_JUMP"] = "FELMS JUMP",
     ["AST_PREVIEW_BOLTS"] = "BOLTS",
     ["AST_PREVIEW_FIRE"] = "FIRE",
     ["AST_PREVIEW_STEAM"] = "STEAM",
     ["AST_PREVIEW_MAIM"] = "MAIM",
     ["AST_PREVIEW_CHARGES"] = "CHARGES",
}

function AST.lang.ru.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
