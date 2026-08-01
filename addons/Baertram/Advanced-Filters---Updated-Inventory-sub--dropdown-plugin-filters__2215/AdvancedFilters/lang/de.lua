local util = AdvancedFilters.util
local enStrings = AdvancedFilters.ENstrings

local afPrefixNormal    = enStrings.AFPREFIXNORMAL
local afPrefixError     = string.format(enStrings.AFPREFIX, " FEHLER")

local strings = {
    TwoHandAxe = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE1))),
    TwoHandSword = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE3))),
    TwoHandHammer = util.Localize(zo_strformat("<<1>> <<2>>", GetString(SI_EQUIPTYPE6), GetString(SI_WEAPONTYPE2))),
    Shield = zo_strformat("<<m:1>>", GetString(SI_ITEMSTYLECHAPTER13)),

    ResetToAll           = util.Localize(SI_ITEMFILTERTYPE0) .. " anzeigen",
    InvertDropdownFilter = "Filter umdrehen: %s",

    --LAM settings menu
    lamDescription = "Zeige zusätzliche Filter Kategorien in den Inventaren, um Gegenstandstypen zu unterscheiden",
    lamHideItemCount = "Verstecke Gegenstand Anzahl",
    lamHideItemCountTT = "Versteckt die Gegenstand Anzahl, welche als \"(...)\" am unteren Inventar Rand angezeigt wird",
    lamHideItemCountColor = "Farbe der Gegenstand Anzahl",
    lamHideItemCountColorTT = "Setze die Farbe der Gegenstand Anzahl",
    lamHideSubFilterLabel = "Verstecke Filter Kategorie Label",
    lamHideSubFilterLabelTT = "Versteckt den Filter Kategorie Beschreibungstext Label, welcher sich links am Inventar Rand befindet",
    lamGrayOutSubFiltersWithNoItems = "Deaktiviere Kategorien ohne Gegenstände",
    lamGrayOutSubFiltersWithNoItemsTT = "Deaktiviert die Filter Kategorien, welche aktuell keine Gegegnstände besitzen.",
    lamShowIconsInFilterDropdowns = "Zeige Symbole in Filter Boxen",
    lamShowIconsInFilterDropdownsTT = "Zeige Symbole in den Filter Aufklapp Boxen an",
    lamShowSubMenuHeaderlinesInFilterDropdowns = "Zeige Unter-Filter Überschr. in Filter Boxen",
    lamShowSubMenuHeaderlinesInFilterDropdownsTT = "Zeige Unter-Filter Überschriften in Aufklapp Filter Boxen an",
    lamRememberFilterDropdownsLastSelection = "Merke letzte Filter Box Auswahl",
    lamRememberFilterDropdownsLastSelectionTT = "Merkt sich je Unterfilter und Filter Panel (Inventar, Mail senden, Handerksstation, ...) die letzte Filter Box Auswahl und stellt diese wieder her, wenn du den Unterfilter auf diesem Filter Panel das nächste mal besuchst.\nDies wird NICHT über eine Ausloggen/Benutzeroberfläche Neuladen hinweg gemerkt!",
    lamShowDropdownSelectedReminderAnimation = "Filter Box Auswahl Aufleuchten",
    lamShowDropdownSelectedReminderAnimationTT = "Lässt die Filter Auswahlbox aufleuchten, wenn auf eine Unterfilter Leiste gewechselt wird, auf welcher die Auswahl Box nicht den Eintrag \'".. util.Localize(SI_ITEMFILTERTYPE0) .. "\' ausgewählt hat.",
    lamShowDropdownLastSelectedEntries = "Zeige Filter Box Auswahl Historie",
    lamShowDropdownLastSelectedEntriesTT = "Klicke rechts auf die Filter Auswahl Box, um die Historie der letzten 10 ausgewählten Einträge aus den Filter Auswahl Boxen anzuzeigen (unterhalb der standard Einträge des Kontextmenüs). Klicke auf einen der Historien Einträge, um diesen erneut auszuwählen, sofern die Filter Auswahlbox der aktuellen Unterfilter Leiste diesen Eintrag besitzt (da die Historie übergreifend über alle zuletzt verwendeten Auswahl Filter Boxen funktioniert).",
    lamHideCharBoundAtBankDeposit = "Bank: Char. gebundene Gegenst. verstecken",
    lamHideCharBoundAtBankDepositTT = "Versteckt Charakter gebundene Gegenstände auf dem Bank Einlagern Reiter",
    lamShowFilterDropdownMenuOnRightMouse   = "|t150.000000%:150.000000%:EsoUI/Art/Miscellaneous/icon_RMB.dds|t: Zeige Aufklapp-Box Filter am Knopf",
    lamShowFilterDropdownMenuOnRightMouseTT = "Zeige dieselben Plugin Filter am aktuellen Unterfilter Knopf an, als ob du auf die Aufklapp-Box geklickt hättest.\n\n|t100.000000%:100.000000%:EsoUI/Art/Miscellaneous/icon_RMB.dds|t: Zeige das normale Plugin Filter Menü\nSHIFT Taste + |t100.000000%:100.000000%:EsoUI/Art/Miscellaneous/icon_RMB.dds|t: Zeige das Rechtsklick Filter Plugin Menü",
    lamHeaderVisual = "Darstellung",
    lamHeaderFilterCategory = "Filter Kategorien",
    lamHeaderSubfilter = "Unter-Filter Knöpfe",
    lamHeaderDropdownFilterbox = "Filter Aufklapp-Boxen",
    lamDebugOutput = "Debug",
    lamDebugOutputTT = "Zeigt Debugging Nachrichten im Chat/DebugLogViewer UI. an",
    lamDebugSpamOutput = "Debug Spam",
    lamDebugSpamOutputTT = "Achtung: Dies aktiviert sehr viele Debugging Nachrichten von AdvancedFilters im Chat/DebugLogViewer UI an. Aktiviere diese Einstellung NUR wenn du darum gebeten wirst!",
    lamDebugSpamExcludeRefreshSubfilterBar = "Ausschließen: \'RefreshSubfilterBar\'",
    lamDebugSpamExcludeDropdownBoxFilters = "Ausschließen: \'Dropdownbox Filter\'",

    lamDropdownVisibleRows = "Filter Box: Sichtbare Haupt Zeilen",
    lamDropdownVisibleRowsTT = "Anzahl der sichtbare Haupt Zeilen in den Auswahl Filter Boxen",
    lamDropdownVisibleSubmenuRows = "Filter Box: Sichtbare Untermenü Zeilen",
    lamDropdownVisibleSubmenuRowsTT = "Anzahl der sichtbare Untermenü Zeilen in den Auswahl Filter Boxen",

    --Error messages
    errorCheckChatPlease    = afPrefixError .. " Bitte lese die Fehlermeldung im Chat!",
    errorLibraryMissing     = afPrefixError .. " Benötigte Bibliothek \'%s\' ist nicht aktiviert. Dieses AddOn funktioniert nicht ohne diese!",
    errorWhatToDo1          = "!> Bitte beantworte die folgenden 4 Fragen und schreibe die Antworten (und wenn verfügbar: die Variablen, welche in den Chat Zeilen nach den Fragen mit -> beginnen) in den AddOn Kommentaren von AdvancedFilters @www.esoui.com:\nhttps://bit.ly/2lSbb2A",
    errorWhatToDo2          = "1) Was hast du gemacht als der Fehler auftrat?\n2)Wo hast du es gemacht?\n3)Hast du ausprobiert, ob der Fehler auch auftritt, wenn NUR das AddOn AdvancedFilters und die Bibliotheken aktiv sind (Bitte teste dies unbedingt!)?\n4)Wenn der Fehler mit anderen AddOns aktiv auftritt: Welche anderen AddOns waren aktiv, und kannst du eingrenzen welches es verursacht?",

    --Errors because of other addons
    errorOtherAddonsMulticraft = afPrefixError .. "Ein anderes AddOn stört \'" .. afPrefixNormal .. "\' -> BITTE DEAKTIVIER DAS FOLGENDE AddOn: \'MultiCraft\'!",
    errorOtherAddonsMulticraftLong = "BITTE DEAKTIVIERE DAS ADDON \'MultiCraft\'! " .. afPrefixNormal .. " funktioniert nicht wenn dieses AddOn aktiviert ist. \'Multicraft\' wurde außerdem durch die ZOs eigene Multi-Craft Handwerks UI ersetzt und wird daher nicht mehr benötigt!"
}
--QuickSlots
strings.BodyMarking = "Körper"
strings.JewelryPiercing  = strings.Jewelry
strings.HeadMarking = strings.Head
strings.Facial = "Gesicht"
strings.Hair = "Haar"
strings.Hat = "Hut"
strings.Skin = "Haut"
strings.Polymorph = "Verwandlung"
strings.Personality = "Persönlichkeit"
strings.StackableContainer = "Stapelbare Container",



setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings
