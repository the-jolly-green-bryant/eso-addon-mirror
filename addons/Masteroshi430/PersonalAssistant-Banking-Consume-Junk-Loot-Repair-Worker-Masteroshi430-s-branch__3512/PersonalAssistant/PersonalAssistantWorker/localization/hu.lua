local PAC = PersonalAssistant.Constants
local PAWStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
-- PAWorker Menü --
    SI_PA_MENU_WORKER_DESCRIPTION = "A PAWorker képes automatikusan szétszedni tárgyakat, finomítani alapanyagokat és kutatni tulajdonságokat.",
	
	SI_PA_MENU_WORKER_METICULOUS_ENABLE = "Aprólékos Szétszedés (Meticulous Disassembly) ellenőrzése",
	SI_PA_MENU_WORKER_METICULOUS_ENABLE_T = "Megakadályozza a szétszedést/finomítást, ha az Aprólékos Szétszedés passzív nincs kimaxolva",
	SI_PA_MENU_WORKER_CHECK_EXTRACTION_ENABLE = "Kinyerési passzív ellenőrzése",
	SI_PA_MENU_WORKER_CHECK_EXTRACTION_ENABLE_T = "Megakadályozza a szétszedést/finomítást, ha a kézműves szakmához tartozó kinyerési passzív nincs kimaxolva",

    -- Automatikus finomítás --
    SI_PA_MENU_WORKER_AUTOREFINE_HEADER = "Alapanyagok Automatikus Finomítása",
    SI_PA_MENU_WORKER_AUTOREFINE_ENABLE = "Alapanyagok Automatikus Finomításának engedélyezése",
	SI_PA_MENU_WORKER_AUTOREFINE_ENABLE_T = "Alapanyagok automatikus finomítása",
	
	-- Automatikus szétszedés --
    SI_PA_MENU_WORKER_AUTODECONSTRUCT_HEADER = "Tárgyak Automatikus Szétszedése",
    SI_PA_MENU_WORKER_AUTODECONSTRUCT_ENABLE = "Tárgyak Automatikus Szétszedésének engedélyezése",
	SI_PA_MENU_WORKER_AUTODECONSTRUCT_ENABLE_T = "Tárgyak automatikus szétszedése",
	
	SI_PA_MENU_WORKER_PROTECT_BANK_ENABLE = "Bankban lévő tárgyak védelme",
	SI_PA_MENU_WORKER_PROTECT_BANK_ENABLE_T = "Másodlagos védelem a bankban tárolt tárgyaknak",
	
	SI_PA_MENU_WORKER_PROTECT_UNCOLLECTED_SET_ITEMS_ENABLE = "Nem gyűjtött Szett tárgyak védelme",
	SI_PA_MENU_WORKER_PROTECT_UNCOLLECTED_SET_ITEMS_ENABLE_T = "Nem gyűjtött szett tárgyak védelme az automatikus szétszedéstől",
	
	-- Tulajdonságok automatikus kutatása --
	SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_HEADER = "Tulajdonságok Automatikus Kutatása",
    SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_ENABLE = "Tulajdonságok Automatikus Kutatásának engedélyezése",
	SI_PA_MENU_WORKER_AUTORESEARCHTRAITS_ENABLE_T = "Tulajdonságok automatikus kutatása",
	
	-- Általános szövegek: Fegyverek, Páncél, Ékszerek --
    SI_PA_MENU_WORKER_AUTOMARK_QUALITY_THRESHOLD = "Automatikus szétszedés: %s, minőség: ez vagy alacsonyabb",
    SI_PA_MENU_WORKER_AUTOMARK_QUALITY_THRESHOLD_T = "Automatikus szétszedés: %s, ha a kiválasztott minőségű vagy annál alacsonyabb",
    SI_PA_MENU_WORKER_AUTOMARK_INTRICATE = table.concat({"Automatikus szétszedés: %s, [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE),"] tulajdonsággal"}),
    SI_PA_MENU_WORKER_AUTOMARK_INTRICATE_T = table.concat({"Automatikus szétszedés: %s [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_INTRICATE), "] tulajdonsággal (megnövelt inspiráció)?"}),
    SI_PA_MENU_WORKER_AUTOMARK_ORNATE = table.concat({"Automatikus szétszedés: %s, [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE),"] tulajdonsággal"}),
    SI_PA_MENU_WORKER_AUTOMARK_ORNATE_T = table.concat({"Automatikus szétszedés: %s [", GetString("SI_ITEMTRAITTYPE", ITEM_TRAIT_TYPE_ARMOR_ORNATE), "] tulajdonsággal (megnövelt eladási ár)?"}),
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_SETS = "Szintén szétszedje azokat a %s tárgyakat, amelyek részei egy Szettnek",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_SETS_T = "Ha KI van kapcsolva, csak azok a %s tárgyak lesznek szétszedve, amelyek NEM részei egy szettnek",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_KNOWN_TRAITS = "Szintén szétszedje azokat a %s tárgyakat, amiknek ismert a Tulajdonsága",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_KNOWN_TRAITS_T = "Ha KI van kapcsolva, csak azok a %s tárgyak lesznek szétszedve, amelyeknek nincs vagy ismeretlen a Tulajdonsága",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_UNKNOWN_TRAITS = "Szintén szétszedje azokat a %s tárgyakat, amiknek ismeretlen a Tulajdonsága",
    SI_PA_MENU_WORKER_AUTOMARK_INCLUDE_UNKNOWN_TRAITS_T = "Ha KI van kapcsolva, csak azok a %s tárgyak lesznek szétszedve, amelyeknek nincs vagy ismert a Tulajdonsága",



    -- =================================================================================================================
    -- == CSEVEGŐ KIMENETEK == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAWorker szétszedés --
    SI_PA_CHAT_ITEM_DECONSTRUCTED = "%s szétszedve",
	SI_PA_CHAT_ALREADY_GOT_ITEM_WITH_TRAIT = "Egy másik %s már rendelkezik a %s kutatható tulajdonsággal, ezért inkább azt szedjük szét",
	SI_PA_CHAT_ITEM_REFINED = "%s finomítva",
	SI_PA_CHAT_ITEM_RESEARCHED = "%s felhasználva a %s (%s) tulajdonság kutatására: %s",
	SI_PA_CHAT_RESEARCH_FULL = "Nem sikerült kutatni a %s tulajdonságot a %s-nél, mert %s/%s kutatási slot használatban van",
	SI_PA_CHAT_RESEARCH_BUSY = "Nem sikerült kutatni a %s tulajdonságot, mert már kutatsz egy másik tulajdonságot a %s-nél",
	SI_PA_CHAT_NO_METICULOUS = "Automatikus szétszedés/finomítás blokkolva, mert az Aprólékos Szétszedés passzív nincs kiválasztva",
	SI_PA_CHAT_NO_EXTRACTION = "Automatikus szétszedés/finomítás blokkolva, mert a %s nincs kimaxolva",
	SI_PA_CHAT_NO_EXTRACTION_FOR_ITEM = "A %s nincs kimaxolva, ezért a %s nem lett automatikusan szétszedve",
	SI_PA_CHAT_CRAFTING_QUEST = "Automatikus szétszedés/finomítás/kutatás blokkolva, mert folyamatban lévő %s küldetésed van",
}

for key, value in pairs(PAWStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PAWGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    --SI_PA_CHAT_Consume_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PAWGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
