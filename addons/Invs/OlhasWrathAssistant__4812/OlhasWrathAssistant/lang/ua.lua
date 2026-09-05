local strings = {

    ADDON_NAME = "Olha's Wrath Assistant",

    SETTINGS = "Налаштування",

    LANGUAGE = "Мова",
    ENGLISH = "Англійська",
    UKRAINIAN = "Українська",

    ACCOUNT_WIDE = "Налаштування на весь аккаунт",

    REPAIR = "Ремонт і заряджання",
    REPAIR_TOOLTIP = "Вмикає автоматичний ремонт екіпіровки та заряджання зброї.",
    REPAIR_PANEL = "OWRepair & Recharge",
    DECONSTRUCT = "Розбірник",
    DECONSTRUCTOR_PANEL = "OWDeconstructor",
    MERCHANT = "Торговець",
    BANKING = "Банкір",

    MASS_DECONSTRUCT = "Масовий розбір",

    RELOAD_UI_WARNING = "Для застосування цієї зміни необхідно перезавантажити інтерфейс.",

    MODULE_IN_DEVELOPMENT = "Цей модуль перебуває в розробці та буде доступний у наступних версіях.",
    ACCOUNT_WIDE_IN_DEVELOPMENT = "У тестовій версії налаштування завжди зберігаються для всього облікового запису.",

}

local owa = OWAssistant
owa.RegisterLanguage("ua", "Українська", strings)
