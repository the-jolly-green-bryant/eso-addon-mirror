local localizationStrings = {
    VOLETTE_YES = "Да",
    VOLETTE_NO = "Нет",

    VOLETTE_REQUIRES_RELOADUI = "Требуется перезагрузка пользовательского интерфейса.",
    VOLETTE_RELOADUI_DIALOG_TITLE = "Перезагрузить интерфейс",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "Изменение вступит в силу после следующей перезагрузки интерфейса. Хотите сделать это сейчас?",

    VOLETTE_CONFIRM_DIALOG_TITLE = "Подтверждение",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "Вы подтверждаете это действие?",

    VOLETTE_HQ_OWNER_CRAFT = "Владелец QG для крафта",
    VOLETTE_HQ_OWNER_PARSE = "Владелец QG для тренировки",
    VOLETTE_HQ_OWNER_MISSING = "Вы должны выбрать владельца штаб-квартиры в настройках.",

    VOLETTE_CONTACTS_ENABLE = "Включить меню Контактов",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "Включите, чтобы получить дополнительное меню контактов рядом с вашим списком друзей",
    VOLETTE_CONTACTS_ADDED = "<<1>> был добавлен в контакты.",
    VOLETTE_CONTACTS_REMOVED = "<<1>> был удалён из контактов.",
    VOLETTE_CONTACTS_EXISTS = "<<1>> уже в контактах.",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> был приглашен.",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "Шепнуть",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "Пригласить",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "Удалить из списка",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "Закрепить",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "Открепить",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "Выберите дом рядом с путевым светилищем",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "Попытка телепортации к этому дому при использовании команды |cffcc00/v-wayshrine|r. Если этот дом не принадлежит вам, будет использоваться другой.",
    VOLETTE_TRAVEL_AUTO = "Авто",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "Вы должны владеть одним из совместимых домов. Рекомендуется \"<<1>>\".",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "Телепортация вне \"<<1>>\".",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "Вы должны владеть \"<<1>>\". Пытаюсь найти другой дом...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "Сбережения",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "Не позволяйте своему богатству простаивать на альтах! Автоматически переводите валюты в банк, когда они начинают накапливаться.",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ffВключить|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "Минимальная сумма",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "Максимальная сумма",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "Ваши персонажи всегда будут иметь в своих сумках как минимум эту сумму.",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "Ваши персонажи никогда не будут держать в своих сумках сумму больше этой.",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "Включить для следующих персонажей:",
    VOLETTE_SAVINGS_DEPOSIT = "Депозит: <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "Снятие: <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "Не удалось найти <<1>> в банке.",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "Телепортироваться в основное жилище",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "Телепортироваться в ремесленную штаб-квартиру",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "Телепортироваться в тренировочную штаб-квартиру",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "Телепортироваться к светилищу",

}

for stringId, stringValue in pairs(localizationStrings) do
    SafeAddString(_G[stringId], stringValue, 7)
end
