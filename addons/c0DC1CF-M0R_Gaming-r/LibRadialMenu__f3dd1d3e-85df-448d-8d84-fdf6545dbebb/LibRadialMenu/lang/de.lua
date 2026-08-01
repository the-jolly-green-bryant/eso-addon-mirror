local LIBRADIAL_WHEEL = HOTBAR_CATEGORY_MAX_VALUE + 100
local libradialwheelcategory = string.format("SI_HOTBARCATEGORY%d",LIBRADIAL_WHEEL)
SafeAddString(_G[libradialwheelcategory], "Addon Einträge", 1)

SafeAddString(SI_LIBRADIALMENU_ASSIGN_TITLE, "Eintrag zuweisen für Slot %d", 1)
SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOT, "Slot %d: ", 1)
SafeAddString(SI_LIBRADIALMENU_ASSIGN_NOTHING, "Diesem Slot wurde noch nichts zugewiesen!", 1)
SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS, "Anzahl von Slots", 1)
SafeAddString(SI_LIBRADIALMENU_NUM_SLOTS_TOOLTIP, "Lege die Anzahl von Einträgen im Schnellzugriff fest.", 1)
SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU, "Einstellungen aktualisieren", 1)
SafeAddString(SI_LIBRADIALMENU_REFRESH_MENU_TOOLTIP, "Nachdem die Anzahl der Einträge verändert wurde, die auf dem Schnellzugriff erscheinen, drücke bitte diesen Button, um die unten zugewiesenen Buttons zu aktualisieren!", 1)
SafeAddString(SI_LIBRADIALMENU_ASSIGN_SLOTS_HEADER, "Slots zuweisen", 1)
SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS, "Einstellungen öffnen", 1)
SafeAddString(SI_LIBRADIALMENU_OPEN_SETTINGS_TOOLTIP, "Öffnet die Einstellungsseite für Lib Radial Menu", 1)

-- SafeAddString(SI_LIBRADIALMENU_TRANSLATEDBY, "", 1) -- translated by
