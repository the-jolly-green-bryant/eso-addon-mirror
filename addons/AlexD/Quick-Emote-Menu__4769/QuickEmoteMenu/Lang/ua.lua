local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "Категорії",
    SI_QUICKEMOTEMENU_FAVORITES             = "Обране",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(порожньо)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "Перемкнути",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "Затримка наведення підменю (мс)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = відкривати лише кліком",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "Показувати кнопку лише в режимі UI",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "Показує головну кнопку лише коли курсор миші активний (режим UI). Вона приховується після повернення до звичайного режиму гри/взаємодії.",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "Від’єднати кнопку від чату",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP = "Переміщує кнопку за межі вікна чату. Кнопку можна вільно перетягувати.",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "Налаштування",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "Приєднати кнопку",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "Від’єднати кнопку",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "Показати панель налаштувань",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "Закривати меню після емоції (ЛКМ)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "Скинути позицію кнопки",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X         = "Зміщення кнопки чату по X",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X_TOOLTIP = "Горизонтальне зміщення кнопки відносно кнопки параметрів вікна чату. Застосовується лише коли кнопку прикріплено до вікна чату.",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFМОЖЛИВОСТІ|r
• Швидкий доступ до емоцій за допомогою категорій та обраного
• Категорії та емоції завантажуються безпосередньо з даних гри
• Нові емоції, додані до гри, автоматично з'являтимуться у списку

|c3399FFКЕРУВАННЯ|r
• ЛКМ по кнопці — відкрити або закрити меню
• ПКМ і перетягування — перемістити кнопку
• ЛКМ по емоції — відтворити
• ПКМ по емоції — додати або прибрати з Обраного

|c3399FFМЕНЮ|r
• Категорії — перегляд емоцій за категоріями
• Обране — швидкий доступ до збережених емоцій
• Підменю відкриваються при наведенні або кліку (див. затримку)
• Меню відкриваються зверху/знизу та зліва/справа залежно від позиції кнопки

|c3399FFПОРАДИ|r
• Використовуйте прив’язку клавіш для перемикання меню
• /qempanel відкриває цю панель налаштувань
• Обране зберігається на весь акаунт
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
