-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    SI_WHH_RINGNAME = "Кольцо Дикой охоты", --Кольцо Дикой охоты

    --Settings
    SI_WHH_SETTINGS_ICONLABEL = "Настройка иконки",
    SI_WHH_SETTINGS_ICONLABEL_DESCRIPTION = "Настройка отображения иконки.",
    SI_WHH_SETTINGS_ICONLOCK = "Заблокировать иконку",
    SI_WHH_SETTINGS_ICONLOCK_TP = "Блокирует возможность перемещать иконку",
    SI_WHH_SETTINGS_ICONDEFAULT = "Сбросить иконку",
    SI_WHH_SETTINGS_ICONDEFAULT_TP = "Сбрасывает положение иконки",
    SI_WHH_SETTINGS_ICONTRANSPARENCY = "Прозрачность иконки",
    SI_WHH_SETTINGS_ICONTRANSPARENCY_TP = "Настраивает прозрачность всей иконки.\n\nЗаметка: По умолчанию 1",
    SI_WHH_SETTINGS_BGICONTRANSPARENCY = "Прозрачность фона",
    SI_WHH_SETTINGS_BGICONTRANSPARENCY_TP = "Настраивает прозрачность фона иконки. \n\nЗаметка: По умолчанию 0.5",
    --Ring Name init
    SI_WHH_SETTINGS_CRINGNAME_TITLE = "Имя кольца",
    SI_WHH_SETTINGS_CRINGNAME_DESCRIPTION = "Данный раздел поможет вам настроить аддон если он не поддерживает ваш язык. В иных случаях лучше тут ничего не трогать!", -- Данный раздел поможет вам настроить аддон если он не поддерживает ваш язык. В иных случаях лучше тут ничего не трогать!
    SI_WHH_SETTINGS_CRINGNAME_ENABLE = "Включить кастомное имя",
    SI_WHH_SETTINGS_CRINGNAME_ENABLE_TP = "Включить проверку имени кольца заданным в этом разделе.\n\nПримечание: Не трогайте эту настройку если ваш язык поддерживается аддоном!", --Включить проверку имени кольца заданным в этом разделе.\n\nПримечание: Не трогайте эту настройку если ваш язык поддерживается аддоном!
    SI_WHH_SETTINGS_CRINGNAME_BUTTONNAME = "Получить имя",
    SI_WHH_SETTINGS_CRINGNAME_BUTTONNAME_TP = "Получает имя кольца которое одето в первый слот.", --Получает имя кольца которое одето в первый слот.
    SI_WHH_SETTINGS_CRINGNAME_EDITBOXNAME = "Имя кольца",
    SI_WHH_SETTINGS_CRINGNAME_EDITBOXNAME_TP = "Содержит имя кольца которое ищет аддон. Советую не вводить тут ничего самостоятельно, а воспользоваться кнопкой выше.", -- Содержит имя кольца которое ищет аддон. Советую не вводить тут ничего самостоятельно, а воспользоваться кнопкой выше.
    --Message
    SI_WHH_MESSAGE_OLDRINGUNKNOWN = "Аддону неизвестно какое на вас было кольцо. Оденьте обычное кольцо, а после нажмите на кнопку смены кольца на дикую охоту.", -- Аддону неизвестно какое на вас было кольцо. Оденьте обычное кольцо, а после нажмите на кнопку смены кольца на дикую охоту.
    SI_WHH_MESSAGE_OLDRINGUNNOTFOUND = "Не удалось найти старое кольцо. Оденьте обычное кольцо, а после нажмите на кнопку смены кольца на дикую охоту.", --Не удалось найти старое кольцо. Оденьте обычное кольцо, а после нажмите на кнопку смены кольца на дикую охоту.
    SI_WHH_MESSAGE_WILDHUNTRINGNOTFOUNT = "Не удалось найти кольцо дикой охоты в инвентаре. Если у вас есть в инвентаре кольцо дикой охоты, то проверьте настройки аддона.", --Не удалось найти кольцо дикой охоты в инвентаре. Если у вас есть в инвентаре кольцо дикой охоты, то проверьте настройки аддона.
    -- Keybindings.
    SI_BINDING_NAME_WildHuntHelper_SWITCH = "Переключить кольцо Дикой охоты",

    --Other
    SI_WHH_INFO_WEBSITE = "https://steelsword.ru/",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end