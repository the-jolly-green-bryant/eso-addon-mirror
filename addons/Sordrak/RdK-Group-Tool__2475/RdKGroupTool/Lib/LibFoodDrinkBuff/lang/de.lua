local lib = _G[LFDB_LIB_IDENTIFIER]

-- internal strings
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_LIB_ASYNC_NEEDED, "Fehler: Bibliothek \'LibAsync\' nicht geladen!", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START, "Die Durchsuchung von Speisen / Getränke wurde gestartet. Das kann einige Sekunden dauern...", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, "Die Durchsuchung ist beendet. Es wurden keine Speisen oder Getränke exportiert.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, "<<1>>!\nArgument |cFFFFFF/dumpfdb|r fehlt!\nBenutze |cFFFFFFall|r - komplette Liste generieren\noder |cFFFFFFnew|r - nur neue Speisen/Getränke generieren", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS, "Es gibt keinen aktiven Buff.", 0)

SafeAddString(SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT, "<<1>> Speisen / Getränke gefunden.\n\nDamit Eure SavedVariables Datei aktualisiert wird, muss die Benutzeroberfläche neu geladen werden.\n\nBenutzeroberfläche jetzt neu laden?", 0)

-- API
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_NO_BUFF_ACTIVE, "There is no food or drink buff active.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_EXPIRES_SOON, "Your food or drink buff will expire soon.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_EXPIRES_SOON_TIME, "Your food or drink buff will expire in <<X:1>>.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_GENERAL_REMAINING, "<<X:1>> remaining for your food or drink buff.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_NO_BUFF_ACTIVE, "<<C:1>> is not active.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_EXPIRES_SOON, "<<C:1>> will expire soon.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_EXPIRES_SOON_TIME, "<<C:1>> will expire in <<X:2>>.", 0)
SafeAddString(SI_LIB_FOOD_DRINK_BUFF_CUSTOM_REMAINING, "<<C:1>> remaining for <<X:2>>.", 0)

-- Blacklist
lib.BLACKLIST_STRING_PATTERN =
{
	"Seelenbeschwörung",
	"Erfahrungs",
	"Pelinal",
	"MillionHealth",
	"Ambrosia",
	"Allianzkriegssegen",
}