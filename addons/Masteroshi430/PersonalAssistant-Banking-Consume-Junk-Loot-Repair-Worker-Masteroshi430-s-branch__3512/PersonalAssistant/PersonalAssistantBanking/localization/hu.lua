local PAC = PersonalAssistant.Constants
local PABStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking Menu --
SI_PA_MENU_BANKING_DESCRIPTION = "A PABanking képes pénznemeket, kézműves- és egyéb tárgyakat mozgatni a karaktered hátizsákja és a bank között",

    -- Pénznemek --
    SI_PA_MENU_BANKING_CURRENCY_HEADER = GetString(SI_INVENTORY_CURRENCIES),
    SI_PA_MENU_BANKING_CURRENCY_ENABLE = table.concat({"Automatikus bankolás engedélyezése: ", GetString(SI_INVENTORY_CURRENCIES)}),
    SI_PA_MENU_BANKING_CURRENCY_MINTOKEEP = "Karakternél tartandó minimum",
    SI_PA_MENU_BANKING_CURRENCY_MAXTOKEEP = "Karakternél tartandó maximum",

    -- Kézműves tárgyak --
    SI_PA_MENU_BANKING_CRAFTING_HEADER = "Kézműves tárgyak",
    SI_PA_MENU_BANKING_CRAFTING_ENABLE = "Automatikus bankolás engedélyezése kézműves tárgyakhoz",
    SI_PA_MENU_BANKING_CRAFTING_ENABLE_T = "Automatikus bankba helyezés és kivétel engedélyezése a különböző kézműves tárgyakhoz?",
    SI_PA_MENU_BANKING_CRAFTING_DESCRIPTION = "Egyedi viselkedés definiálása (betétel, kivétel vagy semmi) a kézműves tárgyakhoz",
    SI_PA_MENU_BANKING_CRAFTING_ESOPLUS_DESC = "ESO Plus tagként a kézműves alapanyagok be-/kivétele nem releváns, mivel mindegyik végtelen mennyiségben hordozható a Kézműves táskában",
    SI_PA_MENU_BANKING_CRAFTING_GLOBAL_MOVEMODE = "Az összes fenti kézműves tárgy legördülő menüjének módosítása erre:",
    SI_PA_MENU_BANKING_CRAFTING_GLOBAL_MOVEMODE_T = "Az összes fenti kézműves tárgy legördülő menü értékének módosítása 'Bankba helyezés', 'Hátizsákba kivétel', vagy 'Ne tegyen semmit' opcióra",

    -- Speciális tárgyak --
    SI_PA_MENU_BANKING_ADVANCED_HEADER = "Speciális tárgyak",
    SI_PA_MENU_BANKING_ADVANCED_ENABLE = "Automatikus bankolás engedélyezése speciális tárgyakhoz",
    SI_PA_MENU_BANKING_ADVANCED_ENABLE_T = "Automatikus bankba helyezés és kivétel engedélyezése a különböző speciális tárgyakhoz?",
    SI_PA_MENU_BANKING_ADVANCED_DESCRIPTION = "Egyedi viselkedés definiálása (betétel, kivétel vagy semmi) a speciális tárgyakhoz",

    SI_PA_MENU_BANKING_ADVANCED_GLOBAL_MOVEMODE = "Az összes fenti speciális tárgy legördülő menüjének módosítása erre:",
    SI_PA_MENU_BANKING_ADVANCED_GLOBAL_MOVEMODE_T = "Az összes fenti speciális tárgy legördülő menü értékének módosítása 'Bankba helyezés', 'Hátizsákba kivétel', vagy 'Ne tegyen semmit' opcióra",

    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE8 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known Motifs"}), 
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE29 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known Recipes"}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3200 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3250 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3251 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY)}),
    SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE3252 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY)}),
	
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE171 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE170 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE177 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE175 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE172 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE173 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE174 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE178 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_ITEMTYPE176 = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING)}),
	
	SI_PA_MENU_BANKING_ADVANCED_KNOWN_STYLE_PAGE = table.concat({PAC.ICONS.OTHERS.KNOWN.NORMAL, " Known Style Pages"}),
	
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE8 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown Motifs"}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE29 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown Recipes"}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3200 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3250 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3251 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY)}),
    SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE3252 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY)}),
	
	
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE171 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE170 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE177 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE175 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE172 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE173 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE174 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE178 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING)}),
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_ITEMTYPE176 = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Unknown "..GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING)}),
	
	
	SI_PA_MENU_BANKING_ADVANCED_UNKNOWN_STYLE_PAGE = table.concat({PAC.ICONS.OTHERS.UNKNOWN.NORMAL, " Ismeretlen stílusoldalak"}),
	
    -- Egyedi tárgyak --
    SI_PA_MENU_BANKING_INDIVIDUAL_HEADER = "Egyedi tárgyak",
    SI_PA_MENU_BANKING_INDIVIDUAL_DISABLED_DESCRIPTION = table.concat({"Az egyéni bankolási szabályok bevezetésével az „Egyedi” beállítások átkerültek oda. ", GetString(SI_PA_MENU_RULES_HOW_TO_ADD_PAB), "\n\n", GetString(SI_PA_MENU_RULES_HOW_TO_FIND_MENU)}),

    -- AvA Tárgyak --
    SI_PA_MENU_BANKING_AVA_HEADER = "AvA Tárgyak",
    SI_PA_MENU_BANKING_AVA_ENABLE = "Automatikus bankolás engedélyezése AvA tárgyakhoz",
    SI_PA_MENU_BANKING_AVA_ENABLE_T = "Automatikus bankba helyezés és kivétel engedélyezése a különböző Alliance versus Alliance (AvA) tárgyakhoz?",
    SI_PA_MENU_BANKING_AVA_DESCRIPTION = "Add meg a készletedben tartani kívánt különböző Alliance versus Alliance (AvA) tárgyak mennyiségét",
    SI_PA_MENU_BANKING_AVA_OTHER_HEADER = "Egyéb",

    -- Egyéb beállítások --
    SI_PA_MENU_BANKING_AUTO_ITEM_TRANSFER_EXECUTION = "Tárgyak automatikus átmozgatása a PABankinggel",
    SI_PA_MENU_BANKING_AUTO_ITEM_TRANSFER_EXECUTION_T = "Automatikusan lefussanak a tárgyátmozgatások a hátizsák és a bank között a bank megnyitásakor? Ha ki van kapcsolva, akkor is manuálisan futtathatod a PABanking tárgyátmozgatást a bank kezelőfelületén",

    SI_PA_MENU_BANKING_OTHER_DEPOSIT_STACKING = "Halmozási szabály betétnél",
    SI_PA_MENU_BANKING_OTHER_DEPOSIT_STACKING_T = "Határozd meg, hogy minden tárgy bekerüljön-e, vagy csak azok, amelyekkel a meglévő halmok kiegészíthetők, vagy korlátozódjon tárgyanként egy halomra",
    SI_PA_MENU_BANKING_OTHER_WITHDRAWAL_STACKING = "Halmozási szabály kivétnél",
    SI_PA_MENU_BANKING_OTHER_WITHDRAWAL_STACKING_T = "Határozd meg, hogy minden tárgy kikerüljön-e, vagy csak azok, amelyekkel a meglévő halmok kiegészíthetők, vagy korlátozódjon tárgyanként egy halomra",

    SI_PA_MENU_BANKING_EXCLUDE_JUNK = "Ne mozgassa a szemétként megjelölt tárgyakat",

    SI_PA_MENU_BANKING_OTHER_AUTOSTACKBAGS = "Tárgyak automatikus halmozása a bank megnyitásakor",
    SI_PA_MENU_BANKING_OTHER_AUTOSTACKBAGS_T = "Automatikusan halmozza a bankban és a hátizsákban lévő összes tárgyat a bank megnyitásakor? Segít a jobb rendszerezésben",

    -- Általános definíciók minden típushoz --
    SI_PA_MENU_BANKING_ANY_CURRENCY_ENABLE = "Betétel/Kivétel %s",

    SI_PA_MENU_BANKING_ANY_KEEPINBACKPACK = "Megtartandó mennyiség",
    SI_PA_MENU_BANKING_ANY_KEEPINBACKPACK_T = "Határozd meg a mennyiséget, amelyet (a matematikai operátor alapján) a bankban vagy a hátizsákban kell tartani",

    SI_PA_MENU_BANKING_ANY_MINTOKEEP_T = "A %s minimális mennyisége, amelyet mindig a karakteren kell tartani; ha szükséges, további kivételekkel a bankból",
    SI_PA_MENU_BANKING_ANY_MAXTOKEEP_T = "A %s maximális mennyisége, amelyet mindig a karakteren kell tartani; az ezen felüli mennyiség a bankba kerül",

    SI_PA_MENU_BANKING_ANY_GLOBAL_MOVEMODE_W = "Ez nem vonható vissza; az összes egyénileg kiválasztott érték elvész",


    -- =================================================================================================================
    -- == MAIN MENU TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
-- PABanking --
    SI_PA_MAINMENU_BANKING_HEADER = "Bankolási szabályok",

    SI_PA_MAINMENU_BANKING_HEADER_CATEGORY = "K", -- Kategória kezdőbetűje
    SI_PA_MAINMENU_BANKING_HEADER_BAG = "Helyszín",
    SI_PA_MAINMENU_BANKING_HEADER_RULE = "Szabály",
    SI_PA_MAINMENU_BANKING_HEADER_AMOUNT = "Mennyiség",
    SI_PA_MAINMENU_BANKING_HEADER_ITEM = "Tárgy",
    SI_PA_MAINMENU_BANKING_HEADER_ACTIONS = "Műveletek",


    -- =================================================================================================================
    -- == EGYÉB SZÖVEGEK A MENÜHÖZ == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking egyedi szabály hozzáadása leírás --
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_PRE = "A %s-nak pontosan %d darabot kell tartalmaznia a kiválasztott tárgyból.",
    SI_PA_DIALOG_BANKING_BANK_LESSTHANOREQUAL_PRE = "A %s-nak legfeljebb (maximum) %d darabot kell tartalmaznia a kiválasztott tárgyból.",
    SI_PA_DIALOG_BANKING_BANK_GREATERTHANOREQUAL_PRE = "A %s-nak legalább (minimum) %d darabot kell tartalmaznia a kiválasztott tárgyból.",
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_NOTHING = "> %d a %s-odban => nem történik semmi.",
    SI_PA_DIALOG_BANKING_BANK_EXACTLY_DEPOSIT = "> %d a %s-odban => áthelyezi a tárgyakat a %s-ba, amíg nem lesz belőle %d.",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_NOTHING = "> %d - %d a %s-odban => nem történik semmi.",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_DEPOSIT = "> %d - %d a %s-odban => áthelyezi a tárgyakat a %s-ba, amíg nem lesz belőle %d.",
    SI_PA_DIALOG_BANKING_BANK_FROM_TO_WITHDRAW = "> %d - %d a %s-odban => kiveszi a tárgyakat a %s-ból, amíg nem marad %d.",

    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_PRE = "A %s-nak pontosan %d darabot kell tartalmaznia a kiválasztott tárgyból.",
    SI_PA_DIALOG_BANKING_BACKPACK_LESSTHANOREQUAL_PRE = "A %s-nak legfeljebb (maximum) %d darabot kell tartalmaznia a kiválasztott tárgyból.",
    SI_PA_DIALOG_BANKING_BACKPACK_GREATERTHANOREQUAL_PRE = "A %s-nak legalább (minimum) %d darabot kell tartalmaznia a kiválasztott tárgyból.",
    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_NOTHING = "> %d a %s-odban => nem történik semmi.",
    SI_PA_DIALOG_BANKING_BACKPACK_EXACTLY_DEPOSIT = "> %d a %s-odban => áthelyezi a tárgyakat a %s-ba, amíg nem lesz belőle %d.",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_NOTHING = "> %d - %d a %s-odban => nem történik semmi.",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_DEPOSIT = "> %d - %d a %s-odban => áthelyezi a tárgyakat a %s-ba, amíg nem lesz belőle %d.",
    SI_PA_DIALOG_BANKING_BACKPACK_FROM_TO_WITHDRAW = "> %d - %d a %s-odban => kiveszi a tárgyakat a %s-ból, amíg nem marad %d.",

    SI_PA_DIALOG_BANKING_EXPLANATION = "Ez azt jelenti, ha . . .",


    -- =================================================================================================================
    -- == CHAT ÜZENETEK == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_PA_CHAT_BANKING_FINISHED = "Minden tárgy átmozgatása befejeződött",

    SI_PA_CHAT_BANKING_WITHDRAWAL_COMPLETE = "%s kivéve",
    SI_PA_CHAT_BANKING_WITHDRAWAL_PARTIAL_SOURCE = "%s / %s kivéve (A bank üres)",
    SI_PA_CHAT_BANKING_WITHDRAWAL_PARTIAL_TARGET = "%s / %s kivéve (Nincs elég hely a karakternél)",

    SI_PA_CHAT_BANKING_DEPOSIT_COMPLETE = "%s betéve",
    SI_PA_CHAT_BANKING_DEPOSIT_PARTIAL_SOURCE = "%s / %s betéve (A karakter üres)",
    SI_PA_CHAT_BANKING_DEPOSIT_PARTIAL_TARGET = "%s / %s betéve (Nincs elég hely a bankban)",

    SI_PA_CHAT_BANKING_ITEMS_MOVED_COMPLETE = "%d x %s átmozgatva ide: %s",
    SI_PA_CHAT_BANKING_ITEMS_NOT_MOVED_OUTOFSPACE = "Nem sikerült %s átmozgatása ide: %s. Nincs elég hely!",
    SI_PA_CHAT_BANKING_ITEMS_NOT_MOVED_BANKCLOSED = "Nem sikerült %s átmozgatása ide: %s. Az ablak zárva volt!",
    SI_PA_CHAT_BANKING_ITEMS_SKIPPED_LWC = "Egyes tárgyak NEM lettek betéve, a Dolgubon's Lazy Writ Crafter-rel való esetleges ütközések elkerülése érdekében",

    SI_PA_CHAT_BANKING_RULES_ADDED = table.concat({"A szabály a következőhöz: %s ", PAC.COLOR.ORANGE:Colorize("hozzáadva"), "!"}),
    SI_PA_CHAT_BANKING_RULES_UPDATED = table.concat({"A szabály a következőhöz: %s ", PAC.COLOR.ORANGE:Colorize("frissítve"), "!"}),
    SI_PA_CHAT_BANKING_RULES_DELETED = table.concat({"A szabály a következőhöz: %s ", PAC.COLOR.ORANGE:Colorize("törölve"), "!"}),
    SI_PA_CHAT_BANKING_RULES_ENABLED = table.concat({"A szabály a következőhöz: %s ", PAC.COLOR.ORANGE:Colorize("engedélyezve"), "!"}),
    SI_PA_CHAT_BANKING_RULES_DISABLED = table.concat({"A szabály a következőhöz: %s ", PAC.COLOR.ORANGE:Colorize("letiltva"), "!"}),


    -- =================================================================================================================
    -- == GYORSBILLENTYŰK (KEY BINDINGS) == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking --
    SI_BINDING_NAME_PA_BANKING_EXECUTE_ITEM_TRANSFERS = "PABanking futtatása",
    SI_BINDING_NAME_PA_BANKING_EXECUTE_ITEM_TRANSFERS_PENDING = "PABanking fut folyamatban...",
}

for key, value in pairs(PABStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PABGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PABanking Menu --
    SI_PA_MENU_BANKING_CURRENCY_GOLD_HEADER = GetCurrencyName(CURT_MONEY),
    SI_PA_MENU_BANKING_CURRENCY_ALLIANCE_HEADER = GetCurrencyName(CURT_ALLIANCE_POINTS),
    SI_PA_MENU_BANKING_CURRENCY_TELVAR_HEADER = GetCurrencyName(CURT_TELVAR_STONES),
    SI_PA_MENU_BANKING_CURRENCY_WRIT_HEADER = GetCurrencyName(CURT_WRIT_VOUCHERS),

    SI_PA_MENU_BANKING_ADVANCED_MOTIF_HEADER = zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), 2),
    SI_PA_MENU_BANKING_ADVANCED_RECIPE_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_MASTER_WRITS_HEADER = zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_MASTER_WRIT), 2),
    SI_PA_MENU_BANKING_ADVANCED_HOLIDAY_WRITS_HEADER = zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT)),
    SI_PA_MENU_BANKING_ADVANCED_GLYPHS_HEADER = GetString(SI_PA_MENU_BANKING_ADVANCED_GLYPHS),
    SI_PA_MENU_BANKING_ADVANCED_LIQUIDS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_POTION), 2), " & ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_POISON), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_FOOD_DRINKS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_FOOD), 2), " & ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_DRINK), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_TROPHIES_TREASURE_MAPS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_TROPHY), 2), ": ", zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP)), " & ", zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_TRIBUTE_CLUE))}),
    SI_PA_MENU_BANKING_ADVANCED_TROPHIES_FRAGMENTS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_TROPHY), 2), ": ", zo_strformat(GetString("SI_PA_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT), 2)}),
    SI_PA_MENU_BANKING_ADVANCED_TROPHIES_SURVEY_REPORTS_HEADER = table.concat({zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_TROPHY), 2), ": ", zo_strformat("<<m:1>>", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT))}),
    SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS_HEADER = GetString(SI_PA_MENU_BANKING_ADVANCED_INTRICATE_ITEMS),
    SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS_HEADER = GetString(SI_PA_MENU_BANKING_ADVANCED_ORNATE_ITEMS),

    SI_PA_MENU_BANKING_AVA_SIEGE_BALLISTA_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_BALLISTA),
    SI_PA_MENU_BANKING_AVA_SIEGE_CATAPULT_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_CATAPULT),
    SI_PA_MENU_BANKING_AVA_SIEGE_TREBUCHET_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_TREBUCHET),
    SI_PA_MENU_BANKING_AVA_SIEGE_RAM_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_RAM),
    SI_PA_MENU_BANKING_AVA_SIEGE_OIL_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_OIL),
    SI_PA_MENU_BANKING_AVA_SIEGE_GRAVEYARD_HEADER = GetString("SI_SIEGETYPE", SIEGE_TYPE_GRAVEYARD),
    SI_PA_MENU_BANKING_AVA_REPAIR_HEADER = GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_AVA_REPAIR),


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
}

for key, value in pairs(PABGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
