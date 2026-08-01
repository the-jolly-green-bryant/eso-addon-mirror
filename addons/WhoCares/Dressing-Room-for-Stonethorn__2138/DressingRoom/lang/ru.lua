ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE", "Показать/Скрыть окно")
for i = 1, 24 do
  ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_SET_"..i, "Использовать набор "..i)
end
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_UNDRESS", "Снять все снаряжение")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_PREVIOUS", "Выбрать предыдущий профиль")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_PAGE_SELECT_NEXT", "Выбрать следующий профиль")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_CANCEL_PENDING_LOAD", "Cancel Pending Load")
ZO_CreateStringId("SI_BINDING_NAME_DRESSINGROOM_TOGGLE_GROUP_ROLE", "Toggle Group Role")

DressingRoom._msg = {
  weaponType = {
    [WEAPONTYPE_AXE] = "Топор",
    [WEAPONTYPE_BOW] = "Лук",
    [WEAPONTYPE_DAGGER] = "Кинжал",
    [WEAPONTYPE_FIRE_STAFF] = "Посох Огня",
    [WEAPONTYPE_FROST_STAFF] = "Посох Мороза",
    [WEAPONTYPE_HAMMER] = "Молот",
    [WEAPONTYPE_HEALING_STAFF] = "Посох Лечения",
    [WEAPONTYPE_LIGHTNING_STAFF] = "Посох Молний",
    [WEAPONTYPE_NONE] = "Ничего",
    [WEAPONTYPE_RUNE] = "Руна",
    [WEAPONTYPE_SHIELD] = "Щит",
    [WEAPONTYPE_SWORD] = "Меч",
    [WEAPONTYPE_TWO_HANDED_AXE] = "Топор 2H",
    [WEAPONTYPE_TWO_HANDED_HAMMER] = "Булава 2H",
    [WEAPONTYPE_TWO_HANDED_SWORD] = "Меч 2H",
  },
  
  loadingSet = "Загружаем набор %s...",
  skillBarSaved = "SET %d [Панель способностей %d изменена]",
  skillBarLoaded = "SET %d [Панель способностей %d загружена]",
  skillBarDeleted = "SET %d [Панель способностей %d удалена]",
  gearSetSaved = "SET %d [Комплект экипировки изменен]",
  gearSetLoaded = "SET %d [Комплект экипировки загружен]",
  gearSetDeleted = "SET %d [Комплект экипировки удален]",
  noGearSaved = "Нет экипировки для загрузки набора SET %d",

  options = {
    reloadUIWarning = "Требуется перезагрузка UI",
    autoReloadUIWarning = "Эта опция автоматически перезагрузит ваш интерфейс!",
    reloadUI = "Reload UI",
    accountWideSettings = {
      name = "Account-wide settings",
      tooltip = "Use the same behaviour and UI settings for each character\nChanging this will not affect your saved presets",
    },
    sectionBehaviour = "Behaviour settings",
    autoRechargeWeapons = {
      name = "Автоматически перезаряжает оружие",
      tooltip = "Когда загружается комплект экипировки\nс пустыми слотами, снимает с себя ранее используемые предметы",
    },
    clearEmptyGear = {
      name = "Освободить слоты экипировки",
      tooltip = "Когда загружается пустой набор одежды, снимает с себя предметы что использовались ранее",
    },
    clearEmptyPoisons = {
      name = "Освободить слоты яда",
      tooltip = "Когда загружается компмлект экипировки\nс оружием без наложенного яда, снимает ранее используемые яды",
    },
    clearEmptySkill = {
      name = "Освободить слоты способностей",
      tooltip = "Когда загружается панель способностей\nс пустыми слотами, снимает ранее используемые способности",
    },
    ignoreAppearanceSlot = {
      name = "Ignore appearance slot",
      tooltip = "Do not equip or unequip disguises or guild tabards",
    },
    enableOutfits = {
      name = "Save/load outfits",
      tooltip = "Save and load the active outfit with gear presets",
    },
    disableInCombat = {
      name = "Disable in combat",
      tooltip = "Disable loading skill and/or gear sets while in combat, instead of postponing the action until combat has ended",
    },
    sectionUI = "UI settings",
    showNotificationArea = {
      name = "Show notification area",
      tooltip = "Display the notification area and the name of the currently loaded preset",
    },
    lockNotificationArea = {
      name = "Lock notification area",
      tooltip = "Lock the UI position of the notification area",
    },
    activeBarOnly = {
      name = "Активная панель способностей",
      tooltip = "Показывает активную панель способностей, в интерфейсе аддона",
    },
    lockWindowPosition = {
      name = "Закрепить положение окна",
      tooltip = "Фиксирует положение окна аддона, чтобы его нельзя было переместить",
    },
    fontSize = {
      name = "Размер шрифта",
      tooltip = "Размер шрифта интерфейса",
    },
    btnSize = {
      name = "Размер иконок",
      tooltip = "Размер иконок интерфейса",
    },
    columnMajorOrder = {
      name = "Сортировать наборы по столбцу",
      tooltip = "Использовать основной [вертикальный] порядок столбцов, вместо основного [горизонтального] порядка строк для наборов в интерфейсе",
    },
    openWithSkillsWindow = {
      name = "Открывать вместе с окном навыков",
      tooltip = "Автоматически показывает интерфейс аддона, когда открыто окно с навыками",
    },
    openWithInventoryWindow = {
      name = "Открывать вместе с инвентарем",
      tooltip = "Автоматически показывает интерфейс аддона, когда открыто окно с инвентарем",
    },
    numRows = {
      name = "Количество строк",
      tooltip = "Количество комплектов в столбце окна",
    },
    numCols = {
      name = "Количество столбцов",
      tooltip = "Количество комплектов в ряду окна",
    },
    showChatMessages = {
      name = "Уведомление в чате",
      tooltip = "Показывает сообщение в чат когда загружаются, сохраняются или удаляются наборы экипировки & способностей",
    },
    singleBarToCurrent = {
      name = "Загрузка способностей в активную панель",
      tooltip = "Загрузка набора с одной панелью способностей без экипировки, обновит текущею активную панель, и проигнорирует пустые слоты",
    },
    autoCloseOnMovement = {
      name = "Закрытие окна при передвижении",
      tooltip = "Автоматически закрывает окно\nDressing Room когда персонаж начинает двигаться",
    },
    enablePages = {
      name = "Отображение профилей",
      tooltip = "Отключение этого параметра не удалит ваши профили, они будут скрыты до тех пор пока не включите эту настройку",
    },
    confirmPageDelete = {
      name = "Запрашивать удаление профиля",
      tooltip = "Отображает запрос подтверждения при удалении профиля",
    },
    alwaysChangePageOnZoneChanged = {
      name = "Переключать профиль при смене зоны",
      tooltip = "Если нет предустановки с именем новый зоны в которую вы прибыли, загрузится основной (первый) профиль",
    },
    useOldUI = {
      name = "Use old UI",
      tooltip = "Use the original page picker",
    },
    roleSpecificPresets = {
      name = "Enable role-specific pages",
      tooltip = "Display separate alternative pages for each group role",
    },
    roleFromLFGTool = {
      name = "Auto-select role by LFG tool",
      tooltip = "Select the appropriate alternative page automatically upon changing your group role in the LFG tool",
    },
    autoSaveChangesOnClose = {
      name = "Auto save changes on window close",
      tooltip = "Automatically save all your changes when you close the Dressing Room window.\n|cff8000Note that you always need to reload UI or log out to save data to disk.|r",
    },
    expertFeatures = "Экспертные функции",
    enableExpertFeatures = {
      name = "Включить экспертные функции",
      tooltip = "Я прочитал все предупреждения, и сделал резервную копию файлов аддона",
    },
    changeDefaultRole = {
      name = "Change default role",
      tooltip = "You can use this if you selected a wrong default role.",
    },
    exchangePages = {
      name = "Exchange pages",
      tooltip = "This will *swap* all your \"%s\" presets with the selected one.",
    },
    purgeCharacterData = {
      name = "|cff0000Purge character data|r",
      tooltip = "Delete all pages and presets, and reset all settings for this character\n\nKey bindings will not be changed",
    },
    importPresetsFromCharacter = {
      name = "Import presets from character",
      tooltip = "This will not delete your current presets if the option below isn't enabled, only add the new pages to the end of the list.",
    },
    purgePresetsBeforeImporting = {
      name = "Purge presets before importing",
      tooltip = "Copy presets from another character without keeping the old ones.",
    },
    importAlphaGear = "|cff0000Import from AlphaGear|r",
    importAlphaGearWarning = "|cff0000WARNING - EXPERIMENTAL FEATURE! - read carefully before pressing this button!|r\n\nThis will delete ALL your existing Dressing Room pages and overwrite ALL your existing Dressing Room presets (and key bindings if you choose the option below). If you have already been using this addon, please backup your saved variables file before using this. All your current Dressing Room data WILL be overwritten.\n\nThis version is compatible with '|cFFAA33AlphaGear 2 %s|r', and it is not guaranteed to work with any other version. Use at your own risk.%s\n\nThis option will also reload your UI automatically.",
    importAlphaGearVersionMismatchWarning = "Your installed version:",
    importAlphaGearNotDetected = "AlphaGear not detected, please enable it in order to use this option",
    importAlphaGearRebindKeys = {
      name = "Переназначить кнопки",
      tooltip = "Рекомендуется держать выключенным и сперва вручную проверить ваши настройки, прежде чем это включать",
    },
  },

  setupWindowText = "Выберите главную роль этого персонажа:",
  setupWindowText2 = "Это можно изменить позже в настройках.",

  confirmDeletePagePromptOld = "Really delete page?",
  confirmDeletePagePrompt = "Really delete page \"<<1>>\"?",
  editPageNamePrompt = "Enter new name for \"<<1>>\":",

  changesSave = "Confirm Changes",
  changesUndo = "Cancel All Changes",

  barBtnText = "Панель способностей\nClick - Загрузить\nShift + Click - Изменить\nCtrl + Click - Удалить",
  gearBtnText = "Комплект экипировки\nClick - Загрузить\nShift + Click - Изменить\nCtrl + Click - Удалить",
  setBtnText = "Click - Загрузить набор",

  bttnUndressText = "Раздеться",
  undressClicked = "Снаряжение полностью снято",

  set = "Набор настроек",
  usedBy = "Используется:",

  rechargedWeapon = "Перезаряжен |cff0000%s|r использовался |c00ff00%s|r",

  waitingForWeaponSwap = "Waiting for bar swap",
  waitingForOutOfCombat = "Waiting for out of combat",
}

