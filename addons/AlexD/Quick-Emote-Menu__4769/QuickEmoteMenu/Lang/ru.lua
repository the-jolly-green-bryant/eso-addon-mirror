local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Категории",
    SI_QUICKEMOTEMENU_FAVORITES            = "Избранное",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(пусто)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Переключить",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Задержка наведения подменю (мс)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = открывать только по клику",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Закрывать меню после эмоции (ЛКМ)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Сбросить позицию кнопки",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFУПРАВЛЕНИЕ|r
• ЛКМ по кнопке — открыть или закрыть меню
• ПКМ и перетаскивание — переместить кнопку
• ЛКМ по эмоции — воспроизвести
• ПКМ по эмоции — добавить или убрать из Избранного

|c3399FFМЕНЮ|r
• Категории — просмотр эмоций по категориям
• Избранное — быстрый доступ к сохранённым эмоциям
• Подменю открываются при наведении или клике (см. задержку)
• Меню открываются сверху/снизу и слева/справа в зависимости от позиции кнопки

|c3399FFСОВЕТЫ|r
• Используйте привязку клавиш для переключения меню
• /qempanel открывает эту панель настроек
• Избранное сохраняется на весь аккаунт]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
