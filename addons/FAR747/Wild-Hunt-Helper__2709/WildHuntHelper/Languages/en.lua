-- Every variable must start with this addon's unique ID, as each is a global.
local localization_strings = {
    SI_WHH_RINGNAME = "Ring of the Wild Hunt", --Кольцо Дикой охоты

    --Settings
    SI_WHH_SETTINGS_ICONLABEL = "Icon Settings",
    SI_WHH_SETTINGS_ICONLABEL_DESCRIPTION = "Display icon customization.",
    SI_WHH_SETTINGS_ICONLOCK = "Lock Icon",
    SI_WHH_SETTINGS_ICONLOCK_TP = "Blocks the ability to move the icon",
    SI_WHH_SETTINGS_ICONDEFAULT = "Reset icon",
    SI_WHH_SETTINGS_ICONDEFAULT_TP = "Resets the icon to its original position.",
    SI_WHH_SETTINGS_ICONTRANSPARENCY = "Transparency icon",
    SI_WHH_SETTINGS_ICONTRANSPARENCY_TP = "Adjust the transparency of the entire icon. \n\nNote: Default is 1",
    SI_WHH_SETTINGS_BGICONTRANSPARENCY = "Background transparency",
    SI_WHH_SETTINGS_BGICONTRANSPARENCY_TP = "Sets the background transparency of the icon. \n\nNote: Default is 0.5",
    --Ring Name init
    SI_WHH_SETTINGS_CRINGNAME_TITLE = "Ring Name",
    SI_WHH_SETTINGS_CRINGNAME_DESCRIPTION = "This section will help you configure the addon if it does not support your language. In other cases, it’s better not to touch anything!", -- Данный раздел поможет вам настроить аддон если он не поддерживает ваш язык. В иных случаях лучше тут ничего не трогать!
    SI_WHH_SETTINGS_CRINGNAME_ENABLE = "Enable custom name",
    SI_WHH_SETTINGS_CRINGNAME_ENABLE_TP = "Enable ring name verification specified in this section.\n\nNote: Do not touch this setting if your language is supported by the add-on!", --Включить проверку имени кольца заданным в этом разделе.\n\nПримечание: Не трогайте эту настройку если ваш язык поддерживается аддоном!
    SI_WHH_SETTINGS_CRINGNAME_BUTTONNAME = "Get name automatically",
    SI_WHH_SETTINGS_CRINGNAME_BUTTONNAME_TP = "Gets the name of the ring that is dressed in the first slot.", --Получает имя кольца которое одето в первый слот.
    SI_WHH_SETTINGS_CRINGNAME_EDITBOXNAME = "Ring Name",
    SI_WHH_SETTINGS_CRINGNAME_EDITBOXNAME_TP = "Contains the name of the ring that the addon is looking for. I advise you not to enter anything here yourself, but use the button above.", -- Содержит имя кольца которое ищет аддон. Советую не вводить тут ничего самостоятельно, а воспользоваться кнопкой выше.
    --Message
    SI_WHH_MESSAGE_OLDRINGUNKNOWN = "Addon doesn't know which ring was on you. Put on a regular ring, and then press the button to change the ring to a wild hunt.", -- Аддону неизвестно какое на вас было кольцо. Оденьте обычное кольцо, а после нажмите на кнопку смены кольца на дикую охоту.
    SI_WHH_MESSAGE_OLDRINGUNNOTFOUND = "Could not find the old ring. Put on the regular ring, and then press the button to change the ring to a wild hunt.", --Не удалось найти старое кольцо. Оденьте обычное кольцо, а после нажмите на кнопку смены кольца на дикую охоту.
    SI_WHH_MESSAGE_WILDHUNTRINGNOTFOUNT = "Could not find wild hunt ring in inventory. If you have a wild hunt ring in your inventory, then check the addon settings.", --Не удалось найти кольцо дикой охоты в инвентаре. Если у вас есть в инвентаре кольцо дикой охоты, то проверьте настройки аддона.
    -- Keybindings.
    SI_BINDING_NAME_WildHuntHelper_SWITCH = "Switch Wild Hunt Ring",

    --Other
    SI_WHH_INFO_WEBSITE = "https://www.esoui.com/portal.php?uid=53863",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end