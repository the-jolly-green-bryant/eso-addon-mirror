local PAC = PersonalAssistant.Constants
local PARStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
-- PARepair Menü --
    SI_PA_MENU_REPAIR_DESCRIPTION = "A PARepair & Restock automatikusan megjavítja a felszerelésedet és újratölti a fegyvereidet, legyen szó kereskedőről vagy a terepről; emellett automatikusan feltölti a hasznos tárgyakat a kereskedőknél.",

    -- Felszerelt tárgyak --
    SI_PA_MENU_REPAIR_EQUIPPED_HEADER = "Felszerelt tárgyak",
    SI_PA_MENU_REPAIR_ENABLE = "Automatikus javítás engedélyezése felszerelt tárgyakon",

    SI_PA_MENU_REPAIR_GOLD_HEADER = table.concat({"Javítás ezzel: ", GetCurrencyName(CURT_MONEY)}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE = table.concat({"Felszerelt tárgyak javítása ezzel: ", GetCurrencyName(CURT_MONEY), "?"}),
    SI_PA_MENU_REPAIR_GOLD_ENABLE_T = "Kereskedő meglátogatásakor minden felszerelt tárgy, ami a megadott küszöbértéken van vagy azalatt, automatikusan javításra kerül",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY = "Tartóssági küszöb %-ban",
    SI_PA_MENU_REPAIR_GOLD_DURABILITY_T = "Felszerelt tárgyak javítása csak akkor, ha a tartósságuk a megadott küszöbértéken van vagy azalatt",

    SI_PA_MENU_REPAIR_REPAIRKIT_HEADER = table.concat({"Javítás ezzel: ", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE = table.concat({"Felszerelt tárgyak javítása ezzel: ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), "?"}),
    SI_PA_MENU_REPAIR_REPAIRKIT_ENABLE_T = "Terepen történő kalandozáskor minden felszerelt tárgy, ami a megadott küszöbértéken van vagy azalatt, automatikusan javításra kerül",
    SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT = "Alapértelmezett javítókészlet",
    SI_PA_MENU_REPAIR_REPAIRKIT_DEFAULT_KIT_T = "A tárgyak javításakor az alapértelmezett javítókészleted lesz használva először",
	SI_PA_MENU_REPAIR_REPAIRKIT_GROUP = "Csoportos javítókészletek használata",
    SI_PA_MENU_REPAIR_REPAIRKIT_GROUP_T = "Csoportban történő javításkor a csoportos javítókészletek lesznek előnyben részesítve",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY = "Tartóssági küszöb %-ban",
    SI_PA_MENU_REPAIR_REPAIRKIT_DURABILITY_T = "Felszerelt tárgyak javítása csak akkor, ha a tartósságuk a megadott küszöbértéken van vagy azalatt",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING = table.concat({"Figyelmeztetés, ha kevés a ", GetString(SI_PA_MENU_BANKING_REPAIRKIT)}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_WARNING_T = table.concat({"Figyelmeztetés a csevegőablakban, ha kevés a ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), ". Ha elfogyott, 10 percenként legfeljebb egyszer figyelmeztet."}),
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD = "Javítókészlet küszöbérték",
    SI_PA_MENU_REPAIR_REPAIRKIT_LOW_KIT_THRESHOLD_T = table.concat({"Ha a fennmaradó ", GetString(SI_PA_MENU_BANKING_REPAIRKIT), " mennyisége a küszöbérték alatt van, üzenet jelenik meg a csevegőablakban"}),

    SI_PA_MENU_REPAIR_RECHARGE_HEADER = table.concat({"Fegyverek újratöltése ezzel: ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE = table.concat({"Felszerelt fegyverek újratöltése ezzel: ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), "?"}),
    SI_PA_MENU_REPAIR_RECHARGE_ENABLE_T = "Felszerelt fegyverek újratöltése, amikor a töltöttségi szint nullára csökken. Először az alább kiválasztott alapértelmezett lélekköveket használja.",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM = "Alapértelmezett lélekkő",
    SI_PA_MENU_REPAIR_RECHARGE_DEFAULT_GEM_T = "A fegyverek újratöltésekor az alapértelmezett lélekköved lesz használva először.",
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING = table.concat({"Figyelmeztetés, ha kevés a ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2)}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_WARNING_T = table.concat({"Figyelmeztetés a csevegőablakban, ha kevés a ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), ". Ha elfogyott, 10 percenként legfeljebb egyszer figyelmeztet."}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD = table.concat({GetString("SI_ITEMTYPE", ITEMTYPE_SOUL_GEM), " küszöbérték"}),
    SI_PA_MENU_REPAIR_RECHARGE_LOW_GEM_THRESHOLD_T = table.concat({"Ha a fennmaradó ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_SOUL_GEM), 2), " mennyisége a küszöbérték alatt van, üzenet jelenik meg a csevegőablakban"}),

    -- Leltárban lévő tárgyak --
    SI_PA_MENU_REPAIR_INVENTORY_HEADER = "Leltárban lévő tárgyak",
    SI_PA_MENU_REPAIR_INVENTORY_ENABLE = "Automatikus javítás engedélyezése a leltárban lévő tárgyakon",

    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE = table.concat({"Leltárban lévő tárgyak javítása ezzel: ", GetCurrencyName(CURT_MONEY), "?"}),
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_ENABLE_T = "Kereskedő meglátogatásakor minden leltárban lévő tárgy, ami a megadott küszöbértéken van vagy azalatt, automatikusan javításra kerül",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY = "Tartóssági küszöb %-ban",
    SI_PA_MENU_REPAIR_GOLD_INVENTORY_DURABILITY_T = "Leltárban lévő tárgyak javítása csak akkor, ha a tartósságuk a megadott küszöbértéken van vagy azalatt",
	
	-- Javítókészletek vásárlása --
	SI_PA_MENU_BUY_REPAIR_KITS_HEADER = "Javítókészletek vásárlása",
    SI_PA_MENU_BUY_REPAIR_KITS_ENABLE = "Automatikus javítókészlet-vásárlás engedélyezése",
	
	-- Dinamikus tárgyvásárlási menük --
	SI_PA_MENU_BUY_ITEM_HEADER = "Vásárlás: %s",
    SI_PA_MENU_BUY_ITEM_ENABLE = "Automatikus vásárlás: %s?",
    SI_PA_MENU_BUY_ITEM_ENABLE_T = "Kereskedő meglátogatásakor a hiányzó %s automatikusan megvásárlásra kerül",
    SI_PA_MENU_BUY_ITEM_THRESHOLD = "%s Leltár küszöbérték",
    SI_PA_MENU_BUY_ITEM_THRESHOLD_T = "Amikor a %s mennyisége a küszöbérték alá esik, a hiányzó mennyiség megvásárlásra kerül",
	SI_PA_MENU_BUY_ITEM_PRIORITY = "%s Valuta prioritás",
	SI_PA_MENU_BUY_ITEM_PRIORITY_T = "Válaszd ki, melyik valutát használd először a %s megvásárlásához",	
	
	-- Lélekkövek vásárlása --
	SI_PA_MENU_BUY_SOUL_GEMS_HEADER = "Lélekkövek és zárfeltörők vásárlása",
    SI_PA_MENU_BUY_SOUL_GEMS_ENABLE = "Automatikus lélekkő és zárfeltörő vásárlás engedélyezése",	
	
	-- Ostromeszközök vásárlása -- 
	SI_PA_MENU_BUY_SIEGE_ITEMS_HEADER = "Ostromeszközök vásárlása "..GetString(SI_ITEMTYPEDISPLAYCATEGORY32),
	SI_PA_MENU_BUY_SIEGE_ITEMS_ENABLE = "Automatikus ostromeszköz-vásárlás engedélyezése "..GetString(SI_ITEMTYPEDISPLAYCATEGORY32),
	
	

    -- =================================================================================================================
    -- == CSEVEGŐ KIMENETEK == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PARepair --
    SI_PA_CHAT_REPAIR_SUMMARY_FULL = "Felszerelt tárgyak javítva: %s",
    SI_PA_CHAT_REPAIR_SUMMARY_PARTIAL = "Felszerelt tárgyak javítva: %s (%s hiányzik)",

    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_FULL = "Leltárban lévő tárgyak javítva: %s",
    SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_PARTIAL = "Leltárban lévő tárgyak javítva: %s (%s hiányzik)",

    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED = table.concat({"%s javítva ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " ezzel: %s"}),
    SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED_ALL = table.concat({"%s javítva ", PAC.COLORS.WHITE, "(%d%%)", PAC.COLORS.DEFAULT, " és az összes többi tárgy ezzel: %s"}),
	
	SI_PA_CHAT_BUY_SUMMARY_BOUGHT = "%s x %s megvásárolva: %s",
    SI_PA_CHAT_BUY_SUMMARY_MISSING = "Nem sikerült megvásárolni: %s (%s hiányzik)",
	
}

for key, value in pairs(PARStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PARGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_CHAT_REPAIR_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PARGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
