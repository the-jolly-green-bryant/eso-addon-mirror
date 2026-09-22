local strings = {

    ADDON_NAME = "Universal Assistant",

    SHOW_WELCOME = "Показувати повідомлення привітання",
    SHOW_WELCOME_TOOLTIP = "Показує привітання в чаті після входу персонажем.",
    WELCOME_MESSAGE = "|cFFFFFF[|r|c3A92FFU|r|cFFFFFFniversal|r|cFFFF00A|r|cFFFFFFssistant]|r до ваших послуг!",

    LANGUAGE = "Мова",

    ACCOUNT_WIDE = "Налаштування на весь аккаунт",
    ACCOUNT_WIDE_TOOLTIP = "Використовує один набір налаштувань для всіх персонажів. Новий персональний профіль створюється зі стандартними вимкненими налаштуваннями.",
    PROFILE_SETTINGS = "Профілі налаштувань",
    PROFILE_SETTINGS_TOOLTIP = "Керування налаштуваннями для всього аккаунта або окремих персонажів.",
    PROFILE_ACCOUNT_WIDE = "Весь аккаунт",

    ACTIVE_PROFILE = "Активний профіль",
    ACTIVE_PROFILE_TOOLTIP = "Профіль налаштувань, який зараз використовується.",

    COPY_SETTINGS_FROM = "Скопіювати налаштування з",
    COPY_SETTINGS_FROM_TOOLTIP = "Виберіть профіль іншого персонажа, налаштування якого потрібно скопіювати.",
    CONFIRM_COPY = "Підтвердити копіювання",
    CONFIRM_COPY_TOOLTIP = "Відкриває підтвердження копіювання вибраного профілю.",
    PROFILE_COPY_CONFIRM_TITLE = "Копіювання налаштувань",
    PROFILE_COPY_CONFIRM_TEXT = "Скопіювати налаштування з профілю «%s» до профілю «%s»? Поточні налаштування профілю «%s» буде перезаписано.",

    DELETE_PROFILE = "Видалення профілю налаштувань",
    DELETE_PROFILE_TOOLTIP = "Виберіть профіль іншого персонажа, який потрібно видалити.",
    CONFIRM_DELETE = "Підтвердити видалення",
    CONFIRM_DELETE_TOOLTIP = "Відкриває підтвердження видалення вибраного профілю.",
    PROFILE_DELETE_CONFIRM_TITLE = "Видалення профілю",
    PROFILE_DELETE_CONFIRM_TEXT = "Видалити профіль налаштувань «%s»? Цю дію неможливо скасувати.",

    MASS_DECONSTRUCT = "Масовий розбір",
}

local ua = UAssistant
ua.RegisterLanguage("ua", "Українська", strings)
