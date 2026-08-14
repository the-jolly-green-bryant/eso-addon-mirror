local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Категорії",
    SI_QUICKEMOTEMENU_FAVORITES            = "Обране",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(порожньо)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Перемкнути",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Затримка наведення підменю (мс)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = відкривати лише кліком",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Закривати меню після емоції (ЛКМ)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Скинути позицію кнопки",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFКЕРУВАННЯ|r
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
• Обране зберігається на весь акаунт]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
