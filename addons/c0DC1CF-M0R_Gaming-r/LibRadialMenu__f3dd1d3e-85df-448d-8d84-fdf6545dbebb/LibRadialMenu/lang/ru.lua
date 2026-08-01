local LIBRADIAL_WHEEL = HOTBAR_CATEGORY_MAX_VALUE + 100
local libradialwheelcategory = string.format("SI_HOTBARCATEGORY%d",LIBRADIAL_WHEEL)
SafeAddString(_G[libradialwheelcategory], "Ячейки быстрого доступа", 1) --Аддон Ячейки на колесе быстрого доступа

SafeAddString(SI_LIBRADIALMENU_ASSIGN_TITLE, "Назначьте действие для слота %d.", 1)
SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOT, "Слот %d: ", 1)
SafeAddString(SI_LIBRADIALMENU_ASSIGN_NOTHING, "Для этого слота ничего не назначено!", 1)
SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS, "Количество слотов", 1)
SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS_TOOLTIP, "Установите количество ячеек на колесе быстрого доступа.", 1)
SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU, "Обновить меню настроек", 1)
SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU_TOOLTIP, "После изменения количества ячеек на колесе быстрого доступа, нажмите на эту кнопку чтобы обновить кнопки привязки ниже!", 1)
SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOTS_HEADER, "Назначить слоты")
SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS, "Открыть настройки")
SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS_TOOLTIP, "Открывает страницу настроек для Lib Radial Menu.")

SafeAddString(SI_LIBRADIALMENU_TRANSLATEDBY, "Translation by: Artistvs67", 1) -- translated by
