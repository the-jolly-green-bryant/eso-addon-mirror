SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_LOADED, "Bibliothek \'%s\' wurde bereits geladen.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIBRARY_CONSTANTS_MISSING, "Fehler: Bibliothek \'%s\' Konstanten fehlen!", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIB_ASYNC_NEEDED, "Fehler: Bibliothek \'LibAsync\' nicht geladen!", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_RELOAD, "Eure Benutzeroberfläche wird in |cFF00005 Sekunden|r neu geladen!", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START, "Die Durchsuchung von Speisen / Getränke wurde gestartet. Das kann einige Sekunden dauern...", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, "Die Durchsuchung ist beendet. Es wurden keine Speisen oder Getränke exportiert.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, "<<1>>!\nArgument |cFFFFFF/dumpfdb|r fehlt!\nBenutze |cFFFFFFall|r - komplette Liste generieren\noder |cFFFFFFnew|r - nur neue Speisen/Getränke generieren", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS, "Es gibt keinen aktiven Buff.", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT, "<<1>> Speisen / Getränke gefunden.\n\nDamit Eure SavedVariables Datei aktualisiert wird, muss die Benutzeroberfläche neu geladen werden.\n\nBenutzeroberfläche jetzt neu laden?", 0)

--Create blacklisted buff names
local blacklistedBuffNamesDE = {
    "Seelenbeschwörung", "Erfahrungs", "Pelinal", "MillionHealth", "Ambrosia"
}
--Add the constant for the number of blacklisted buff names
_LIB_FOOD_DRINK_BUFF_BLACKLISTED = blacklistedBuffNamesDE