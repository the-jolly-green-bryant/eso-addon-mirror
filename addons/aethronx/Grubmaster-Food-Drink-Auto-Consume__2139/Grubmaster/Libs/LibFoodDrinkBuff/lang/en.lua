--English texts
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_LIBRARY_LOADED", "Library \'%s\' was already loaded.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_LIBRARY_CONSTANTS_MISSING", "Error: Library \'%s\' constants are missing!")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_LIB_ASYNC_NEEDED", "Error: Library \'LibAsync\' missing!")

ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_EXCEL", "[<<1>>] = true, -- <<2>>")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_ABILITY_NAME", "<<C:1>>")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_DIALOG_TITLE", "Lib Food Drink Buff")

ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_RELOAD", "The user interface will be reloaded in |cFF00005 seconds|r!")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_EXPORT_START", "Searching food / drinks has begun. This may take several seconds...")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH", "The search is over. No food / drinks were exported.")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING", "<<1>>!\nArgument for |cFFFFFF/dumpfdb|r is missing!\nuse |cFFFFFFall|r - dumps the full list\nor |cFFFFFFnew|r - only dump new foods / drinks")
ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_NO_BUFFS", "There is no active buff.")

ZO_CreateStringId("SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT", "<<1>> food / drinks were found.\n\nYou have to reload the UI to update your SavedVariables file.\n\nDo you want to ReloadUI now?")


--Create blacklisted buff names
local blacklistedBuffNamesEN = {
    "Soul Summons", "Experience", "EXP Buff", "Pelinal", "MillionHealth", "Ambrosia"
}
--Add temporary global variable
_LIB_FOOD_DRINK_BUFF_BLACKLISTED = blacklistedBuffNamesEN