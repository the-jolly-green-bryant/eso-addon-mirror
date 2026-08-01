--[[
LibLootSummary German Localization (Deutsche Übersetzung)

German translations for all LibLootSummary UI strings and messages.
Maintains structural compatibility with the English reference file
while providing proper German localization.

Translation Notes:
- Uses formal German ("Sie" form) for user interface text
- Technical terms follow ESO's German client conventions
- Placeholder syntax (<<1>>, <<X:1>>) preserved for ESO formatting
- String constants match English file for cross-language consistency
]]

ZO_CreateStringId("SI_LLS_ITEM_SUMMARY", "Zusammenfassung Gegenstände")
ZO_CreateStringId("SI_LLS_ITEM_SUMMARY_TOOLTIP", "<<1>> wird Euch eine Zusammenfassung von Gegenständen anzeigen.")
ZO_CreateStringId("SI_LLS_LOOT_SUMMARY", "Zusammenfassung erbeutete Gegenstände")
ZO_CreateStringId("SI_LLS_LOOT_SUMMARY_TOOLTIP", "<<1>> wird Euch eine Zusammenfassung von erbeuteten Gegenständen anzeigen.")
ZO_CreateStringId("SI_LLS_MIN_ITEM_QUALITY", "Qualitätsanforderung von Gegenständen")
ZO_CreateStringId("SI_LLS_MIN_ITEM_QUALITY_TOOLTIP", "Alle Gegenstände mit einer kleineren Qualität werden nicht in der Zusammenfassung angezeigt.")
ZO_CreateStringId("SI_LLS_MIN_LOOT_QUALITY", "Qualitätsanforderung von erbeuteten Gegenständen")
ZO_CreateStringId("SI_LLS_MIN_LOOT_QUALITY_TOOLTIP", "Alle erbeuteten Gegenstände mit einer kleineren Qualität werden nicht in der Zusammenfassung angezeigt.")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_ICONS", "Icons von Gegenständen")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_ICONS_TOOLTIP", "Zeigt ein Icon des Gegenstandes vor dessen Name an.")
ZO_CreateStringId("SI_LLS_ICON_SIZE", "Icongrösse von Gegenständen")
ZO_CreateStringId("SI_LLS_ICON_SIZE_TOOLTIP", "Bestimmt die Grösse des Icons in Prozent.")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_ICONS", "Icons von erbeuteten Gegenständen")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_ICONS_TOOLTIP", "Zeigt ein Icon des erbeuteten Gegenstandes vor dessen Name an.")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_TRAITS", "Eigenschaften von Gegenständen")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_TRAITS_TOOLTIP", "Zeigt die Eigenschaften eines Gegenstandes hinter dessen Name in Klammern an.")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_TRAITS", "Eigenschaften von erbeuteten Gegenständen")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_TRAITS_TOOLTIP", "Zeigt die Eigenschaften eines erbeuteten Gegenstandes hinter dessen Name in Klammern an.")
ZO_CreateStringId("SI_LLS_HIDE_ITEM_SINGLE_QTY", "Anzahl einzelner Gegenstände")
ZO_CreateStringId("SI_LLS_HIDE_ITEM_SINGLE_QTY_TOOLTIP", "Die Anzahl rechts vom Name wird nur angezeigt, wenn die Menge grösser als eins ist.")
ZO_CreateStringId("SI_LLS_HIDE_LOOT_SINGLE_QTY", "Anzahl einzelner erbeuteten Gegenstände")
ZO_CreateStringId("SI_LLS_HIDE_LOOT_SINGLE_QTY_TOOLTIP", "Die Anzahl rechts vom Name wird nur angezeigt, wenn die Menge grösser als eins ist.")
ZO_CreateStringId("SI_LLS_COMBINE_DUPLICATES", "Kombinieren wiederholte Gegenstände")
ZO_CreateStringId("SI_LLS_COMBINE_DUPLICATES_TOOLTIP", "Gleiche Gegenstände werden summiert dargestellt und nicht einzeln aufgelistet.")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_NOT_COLLECTED", "<<1>> Icon Sammlung")
ZO_CreateStringId("SI_LLS_SHOW_ITEM_NOT_COLLECTED_TOOLTIP", "Zeigt hinter dem Namen ein Icon, wenn der Gegenstand noch nicht gesammelt ist.")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_NOT_COLLECTED", "<<1>> Icon Sammlung")
ZO_CreateStringId("SI_LLS_SHOW_LOOT_NOT_COLLECTED_TOOLTIP", "Zeigt hinter dem Namen ein Icon, wenn der erbeutete Gegenstand noch nicht gesammelt ist.")
ZO_CreateStringId("SI_LLS_SORT_ORDER_TOOLTIP", "Wählt eine Reihenfolge der Einträge aus, wie diese in der Zusammenfassung sortiert werden sollen.")
ZO_CreateStringId("SI_LLS_DELIMITER", "Trennzeichen")
ZO_CreateStringId("SI_LLS_DELIMITER_TOOLTIP", "Wählt ein Trennzeichen, welche Eure Gegenstände untereinander abtrennt. \"\\n\" bedeutet, dass alle Einträge in einer neuen Zeile angezeigt werden.")
ZO_CreateStringId("SI_LLS_LINK_STYLE", "Darstellung Links")
ZO_CreateStringId("SI_LLS_LINK_STYLE_TOOLTIP", "Wählt die Darstellung von Links aus.")
ZO_CreateStringId("SI_LLS_QUOTES", "\"<<X:1>>\"")
ZO_CreateStringId("SI_LLS_SHOW_COUNTER", "Anzahl der <<1>>")
ZO_CreateStringId("SI_LLS_SHOW_COUNTER_TOOLTIP", "Zeigt eine Anzahl von <<1>> am Ende der Zusammenfassung an.")
ZO_CreateStringId("SI_LLS_COUNTER_FORMAT_SINGLE", "(<<1>> <<2>>)")
ZO_CreateStringId("SI_LLS_COUNTER_FORMAT_PLURAL", "(<<1*2>>)")
ZO_CreateStringId("SI_LLS_PLURAL", "<<1*2>>")

-- Fallback strings for error conditions and missing localization
ZO_CreateStringId("SI_LLS_FALLBACK_SHOW_UNCOLLECTED", "Ungesammelte Set-Symbole anzeigen")
ZO_CreateStringId("SI_LLS_FALLBACK_SETTINGS_FOR", "Einstellungen für")
ZO_CreateStringId("SI_LLS_FALLBACK_SHOW_COUNTER", "Zähler anzeigen")
ZO_CreateStringId("SI_LLS_FALLBACK_SHOW_COUNT_OF", "Anzahl anzeigen von")
ZO_CreateStringId("SI_LLS_FALLBACK_ITEMS", "Gegenstände")
ZO_CreateStringId("SI_LLS_FALLBACK_ITEMS_LOWER", "gegenstände")
ZO_CreateStringId("SI_LLS_ERROR_CONSTANTS_NOT_DEFINED", "String-Konstanten nicht definiert")
ZO_CreateStringId("SI_LLS_ERROR_VALUES_NOT_LOADED", "String-Werte nicht geladen")