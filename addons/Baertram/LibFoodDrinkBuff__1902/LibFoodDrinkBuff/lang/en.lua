local lib = _G[LFDB_LIB_IDENTIFIER]

-- internal strings
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_LIB_ASYNC_NEEDED", "Error: Library \'LibAsync\' missing!")

ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_EXPORT_START", "Searching food / drinks has begun. This may take several seconds...")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH", "The search is over. No food / drinks were exported.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING", "<<1>>!\nArgument for |cFFFFFF/dumpfdb|r is missing!\nuse |cFFFFFFall|r - dumps the full list\nor |cFFFFFFnew|r - only dump new foods / drinks")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS", "There is no active buff.")

ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT", "<<1>> food / drinks were found.\n\nYou have to reload the UI to update your SavedVariables file.\n\nDo you want to ReloadUI now?")

-- internal strings collector
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_EXCEL", "[<<1>>] = true, -- <<2>>")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_ABILITY_NAME", "<<C:1>>")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_DIALOG_TITLE", "Lib Food Drink Buff")

-- API
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_GENERAL_NO_BUFF_ACTIVE", "There is no food or drink buff active.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_GENERAL_EXPIRES_SOON", "Your food or drink buff will expire soon.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_GENERAL_EXPIRES_SOON_TIME", "Your food or drink buff will expire in <<X:1>>.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_GENERAL_REMAINING", "<<X:1>> remaining for your food or drink buff.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_CUSTOM_NO_BUFF_ACTIVE", "<<C:1>> is not active.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_CUSTOM_EXPIRES_SOON", "<<C:1>> will expire soon.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_CUSTOM_EXPIRES_SOON_TIME", "<<C:1>> will expire in <<X:2>>.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_CUSTOM_REMAINING", "<<C:1>> remaining for <<X:2>>.")

-- Blacklist
lib.BLACKLIST_STRING_PATTERN =
{
	"Soul Summons",
	"Experience",
	"EXP Buff",
	"Pelinal",
	"MillionHealth",
	"Ambrosia",
	"Alliance Skill Gain",
}