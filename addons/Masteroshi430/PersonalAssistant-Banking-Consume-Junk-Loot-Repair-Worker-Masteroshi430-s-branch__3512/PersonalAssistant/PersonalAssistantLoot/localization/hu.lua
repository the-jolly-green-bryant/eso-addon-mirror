local PAC = PersonalAssistant.Constants
local PALStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_MENU_LOOT_DESCRIPTION = "PALoot can inform you about items of special interest such as unknown recipes, motifs, or traits",

-- PALoot Loot Events --
    SI_PA_MENU_LOOT_EVENTS_HEADER = "Zsákmány események (műveletek fosztogatáskor...)",
    SI_PA_MENU_LOOT_EVENTS_ENABLE = "Zsákmány események engedélyezése",
	
	-- PALoot Loot Auto Loot --
    SI_PA_MENU_AUTO_LOOT_HEADER = "Intelligens Automatikus Zsákmányszerzés (kevés hely, lopott tárgyak)",
    SI_PA_MENU_AUTO_LOOT_ENABLE = "Automatikus zsákmányszerzés engedélyezése",

    -- Loot Recipes
    SI_PA_MENU_LOOT_RECIPES_HEADER = table.concat({"Fosztogatáskor: ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), 2)}),
    SI_PA_MENU_LOOT_RECIPES_UNKNOWN_MSG = table.concat({"> egy ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), " ismeretlen"}),
    SI_PA_MENU_LOOT_RECIPES_UNKNOWN_MSG_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE).."/"..GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), "-t fosztogatsz, amit a karaktered még nem ismer, megjelenik egy üzenet a csevegőablakban"}),
    
	SI_PA_MENU_LOOT_AUTO_LEARN_RECIPES = table.concat({"Automatikus tanulás: ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_RECIPES_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), "-t fosztogatsz, amit a karaktered még nem ismer, automatikusan megtanulja"}),	
	
	SI_PA_MENU_LOOT_AUTO_LEARN_FURNISHING_PLAN = table.concat({"Automatikus tanulás: ", GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_FURNISHING_PLAN_T = table.concat({"Amikor olyan ", GetString(SI_PROVISIONERSPECIALINGREDIENTTYPE_TRADINGHOUSERECIPECATEGORY3), "-t fosztogatsz, amit a karaktered még nem ismer, automatikusan megtanulja"}),
	
    -- Loot Scribing Scripts & Grimoires
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_HEADER = table.concat({"Fosztogatáskor: ", zo_strformat(GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT),2),"/",zo_strformat(GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY, 2))}),
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_UNKNOWN_MSG = table.concat({"> egy ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT).."/"..GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), " ismeretlen"}),
    SI_PA_MENU_LOOT_SCRIBING_SCRIPTS_UNKNOWN_MSG_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT).."/"..GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), "-t fosztogatsz, amit a karaktered még nem ismer, megjelenik egy üzenet a csevegőablakban"}),
    
	SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_SCRIPTS = table.concat({"Automatikus tanulás: ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_SCRIPTS_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY_SCRIPT), "-t fosztogatsz, amit a karaktered még nem ismer, automatikusan megtanulja"}),
	
	SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_GRIMOIRES = table.concat({"Automatikus tanulás: ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY)}),
    SI_PA_MENU_LOOT_AUTO_LEARN_SCRIBING_GRIMOIRES_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_CRAFTED_ABILITY), "-t fosztogatsz, amit a karaktered még nem ismer, automatikusan megtanulja"}),

    -- Loot Motifs & Style Pages
    SI_PA_MENU_LOOT_STYLES_HEADER = "Stílusok fosztogatása",
	
    SI_PA_MENU_LOOT_MOTIFS_UNKNOWN_MSG = table.concat({"> egy ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " ismeretlen"}),
    SI_PA_MENU_LOOT_MOTIFS_UNKNOWN_MSG_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), "-t fosztogatsz, amit a karaktered még nem ismer, megjelenik egy üzenet a csevegőablakban"}),
 
    SI_PA_MENU_LOOT_STYLEPAGES_UNKNOWN_MSG = table.concat({"> egy ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), " ismeretlen"}),
    SI_PA_MENU_LOOT_STYLEPAGES_UNKNOWN_MSG_T = table.concat({"Amikor olyan ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), "-t fosztogatsz, amit a karaktered még nem ismer, megjelenik egy üzenet a csevegőablakban"}), 
	
	SI_PA_MENU_LOOT_AUTO_LEARN_MOTIFS = table.concat({"Automatikus tanulás: ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF)}),
	SI_PA_MENU_LOOT_AUTO_LEARN_MOTIFS_T = table.concat({"Amikor olyan ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), "-t fosztogatsz, amit a karaktered még nem ismer, automatikusan megtanulja"}),

    SI_PA_MENU_LOOT_AUTO_LEARN_STYLEPAGES = table.concat({"Automatikus tanulás: ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE)}),
	SI_PA_MENU_LOOT_AUTO_LEARN_STYLEPAGES_T = table.concat({"Amikor olyan ", GetString("SI_SPECIALIZEDITEMTYPE", SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE), "-t fosztogatsz, amit a karaktered még nem ismer, automatikusan megtanulja"}),

-- Loot Equipment (Apparel, Weapons & Jewelries)
    SI_PA_MENU_LOOT_APPARELWEAPONS_HEADER = "Felszerelés fosztogatásakor",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNKNOWN_MSG = "> a tulajdonság még nincs kikutatva",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNKNOWN_MSG_T = table.concat({"Amikor olyan ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), ", ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), " vagy ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " kerül zsákmányolásra, aminek a tulajdonsága még nincs kikutatva a karaktered által, egy üzenet jelenik meg a csevegőablakban"}),
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNCOLLECTED_MSG = "> a szett tárgy még nincs begyűjtve",
    SI_PA_MENU_LOOT_APPARELWEAPONS_UNCOLLECTED_MSG_T = table.concat({"Amikor olyan ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), ", ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), " vagy ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " kerül zsákmányolásra, ami része egy szettnek és még nincs hozzáadva a szettgyűjteményhez, egy üzenet jelenik meg a csevegőablakban"}),
    SI_PA_MENU_LOOT_APPARELWEAPONS_AUTOBIND = "Begyűjtetlen szett tárgyak automatikus kötése",
    SI_PA_MENU_LOOT_APPARELWEAPONS_AUTOBIND_T = table.concat({"Amikor olyan ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_ARMOR), ", ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_WEAPONS), " vagy ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_JEWELRY), " kerül zsákmányolásra, ami része egy szettnek és még nincs hozzáadva a szettgyűjteményhez, az automatikusan kötődik"}),

    -- Loot Companion Items
    SI_PA_MENU_LOOT_COMPANION_ITEMS_HEADER = table.concat({"Kísérő tárgyak fosztogatásakor ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION)}),
    SI_PA_MENU_LOOT_COMPANION_ITEMS_QUALITY_THRESHOLD = table.concat({"> kísérő tárgy zsákmányolása legalább ilyen minőségben"}),
    SI_PA_MENU_LOOT_COMPANION_ITEMS_QUALITY_THRESHOLD_T = table.concat({"Amikor a kiválasztott vagy annál magasabb minőségű ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION), " kerül zsákmányolásra, egy üzenet jelenik meg a csevegőablakban"}),

    -- Auto Fillet common fish
    SI_PA_MENU_LOOT_AUTO_FILLET_HEADER = table.concat({"Halak fosztogatásakor ", GetString("SI_ITEMTYPE", ITEMTYPE_FISH)}),
    SI_PA_MENU_LOOT_AUTO_FILLET = "Közönséges halak automatikus filézése",
    SI_PA_MENU_LOOT_AUTO_FILLET_T = "Közönséges halak automatikus filézése Hal vagy Tökéletes Ikra szerzéséhez",
	
	-- Auto Combine collectibles
    SI_PA_MENU_LOOT_AUTO_COMBINE_HEADER = table.concat({"Gyűjteménydarabok fosztogatásakor ", GetString(SI_SPECIALIZEDITEMTYPE109)}),
    SI_PA_MENU_LOOT_AUTO_COMBINE = "Zárolt gyűjteménydarabok automatikus kombinálása",
    SI_PA_MENU_LOOT_AUTO_COMBINE_T = "Darabok automatikus kombinálása a gyűjtemény feloldásához",


    -- Inventory space warning --
    SI_PA_MENU_LOOT_LOW_INVENTORY_WARNING = "Figyelmeztetés kevés leltárhely esetén",
    SI_PA_MENU_LOOT_LOW_INVENTORY_WARNING_T = "Figyelmeztetés a csevegőablakban, ha kevés a leltárhely",
    SI_PA_MENU_LOOT_LOW_INVENTORY_THRESHOLD = "Leltárhely küszöbérték",
    SI_PA_MENU_LOOT_LOW_INVENTORY_THRESHOLD_T = "Ha a fennmaradó szabad leltárhely ezen a küszöbértéken van vagy azalatt, egy üzenet jelenik meg a csevegőablakban",

    -- PALoot Mark Items --
    SI_PA_MENU_LOOT_ICONS_HEADER = "Tárgyikonok",
    SI_PA_MENU_LOOT_ICONS_ENABLE = "Tárgyikonok engedélyezése",
    SI_PA_MENU_LOOT_ICONS_ANY_SHOW_TOOLTIP = "Ikon leírásának megjelenítése",
	
	-- mark known as junk --
	SI_PA_MENU_LOOT_AUTO_MARK_AS_JUNK_KNOWN = "Ismertek automatikus megjelölése szemétként",
	SI_PA_MENU_LOOT_AUTO_MARK_AS_JUNK_KNOWN_T = "Ismertek automatikus megjelölése szemétként, hogy automatikusan eladhatók legyenek a kereskedőnek",

    -- Mark Recipes --
    SI_PA_MENU_LOOT_ICONS_RECIPES_HEADER = table.concat({"Receptek megjelölése ", zo_strformat(GetString("SI_PA_ITEMTYPE", ITEMTYPE_RECIPE), 2)}),
    SI_PA_MENU_LOOT_ICONS_RECIPE_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "ha a recept már ismert"}),
    SI_PA_MENU_LOOT_ICONS_RECIPE_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "ha a recept még ismeretlen"}),
	
    -- Mark scribing --
    SI_PA_MENU_LOOT_ICONS_SCRIBING_HEADER = table.concat({"Írás megjelölése ", GetString(SI_NOTIFICATIONTYPE20), " ", GetString(SI_ITEMTYPE73), "/", GetString(SI_ITEMTYPE72)}),
    SI_PA_MENU_LOOT_ICONS_SCRIBING_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "ha az írás/képesség már ismert"}),
    SI_PA_MENU_LOOT_ICONS_SCRIBING_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "ha az írás/képesség még ismeretlen"}),

    -- Mark Motifs and Style Page Containers --
    SI_PA_MENU_LOOT_ICONS_STYLES_HEADER = "Stílusok megjelölése",
    SI_PA_MENU_LOOT_ICONS_MOTIFS_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "ha a motívum már ismert"}),
    SI_PA_MENU_LOOT_ICONS_MOTIFS_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "ha a motívum még ismeretlen"}),
    SI_PA_MENU_LOOT_ICONS_STYLEPAGES_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "ha a stílusoldal már ismert"}),
    SI_PA_MENU_LOOT_ICONS_STYLEPAGES_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.UNKNOWN.NORMAL, "ha a stílusoldal még ismeretlen"}),

    -- Mark Equipment (Apparel, Weapons & Jewelries) --
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_HEADER = "Felszerelés megjelölése",
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SHOW_KNOWN = table.concat({">", PAC.ICONS.OTHERS.KNOWN.NORMAL, "ha a tárgy tulajdonsága már kikutatott"}),
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SHOW_UNKNOWN = table.concat({">", PAC.ICONS.OTHERS.NOT_RESEARCHED.NORMAL, "ha a tárgy tulajdonsága még ismeretlen"}),
    SI_PA_MENU_LOOT_ICONS_APPARELWEAPONS_SET_UNCOLLECTED = table.concat({">", PAC.ICONS.OTHERS.UNCOLLECTED.NORMAL, "ha a tárgy hiányzik a szettgyűjteményből"}),

    -- Mark Companion Items --
    SI_PA_MENU_LOOT_ICONS_MARK_COMPANION_ITEMS_HEADER = table.concat({"Kísérő tárgyak megjelölése ", GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION)}),
    SI_PA_MENU_LOOT_ICONS_MARK_COMPANION_ITEMS_SHOW_ALL = table.concat({">", PAC.ICONS.OTHERS.COMPANION.NORMAL, "ha a tárgy kísérő tárgy"}),

    -- Item Icon Positioning --
    SI_PA_MENU_LOOT_ICONS_POSITIONING_DESCRIPTION = "Alább módosíthatod a tárgyikonok pozícióját és méretét",
    SI_PA_MENU_LOOT_ICONS_KNOWN_UNKNOWN_HEADER = "Ismert/Ismeretlen",
    SI_PA_MENU_LOOT_ICONS_SET_COLLECTION_HEADER = "Begyűjtetlen szettek",
    SI_PA_MENU_LOOT_ICONS_COMPANION_ITEMS_HEADER = GetString("SI_ITEMFILTERTYPE", ITEMFILTERTYPE_COMPANION),

    SI_PA_MENU_LOOT_ICONS_SIZE_LIST = "Ikonméret (Listanézet)",
    SI_PA_MENU_LOOT_ICONS_SIZE_LIST_T = "Ikonok méretének meghatározása listanézetben",
    SI_PA_MENU_LOOT_ICONS_SIZE_GRID = "Ikonméret (Rácsnézet)",
    SI_PA_MENU_LOOT_ICONS_SIZE_GRID_T = "Ikonok méretének meghatározása rácsnézetben",

    SI_PA_MENU_LOOT_ICONS_X_OFFSET_LIST = "Ikon X eltolás (Listanézet)",
    SI_PA_MENU_LOOT_ICONS_X_OFFSET_LIST_T = "Ikon vízszintes eltolásának meghatározása listanézetben",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_LIST = "Ikon Y eltolás (Listanézet)",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_LIST_T = "Ikon függőleges eltolásának meghatározása listanézetben",

    SI_PA_MENU_LOOT_ICONS_X_OFFSET_GRID = "Ikon X eltolás (Rácsnézet)",
    SI_PA_MENU_LOOT_ICONS_X_OFFSET_GRID_T = "Ikon vízszintes eltolásának meghatározása rácsnézetben",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_GRID = "Ikon Y eltolás (Rácsnézet)",
    SI_PA_MENU_LOOT_ICONS_Y_OFFSET_GRID_T = "Ikon függőleges eltolásának meghatározása rácsnézetben",


    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PALoot --
    SI_PA_CHAT_LOOT_RECIPE_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s megtanulható!"}),
    SI_PA_CHAT_LOOT_MOTIF_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s megtanulható!"}),
	SI_PA_CHAT_LOOT_SCRIBING_SCRIPT_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s megtanulható!"}),
    SI_PA_CHAT_LOOT_TRAIT_UNKNOWN = table.concat({PAC.ICONS.OTHERS.UNKNOWN.SMALL, "%s olyan [%s] tulajdonsággal bír, amely kikutatható!"}),
    SI_PA_CHAT_LOOT_SET_UNCOLLECTED = table.concat({PAC.ICONS.OTHERS.UNCOLLECTED.SMALL, "%s hiányzik a szettgyűjteményből!"}),
    SI_PA_CHAT_LOOT_COMPANION_ITEM = table.concat({PAC.ICONS.OTHERS.COMPANION.SMALL, "%s új kísérő tárgy, %s tulajdonsággal!"}),
	SI_PA_CHAT_LOOT_AUTO_FILLET = "%s automatikusan filézve.",
	

    SI_PA_PATTERN_INVENTORY_COUNT = table.concat({"%sMár csak <<1[nincs/%d db/%d db]>> %s <<1[leltárhelyed/leltárhelyed/leltárhelyed]>> maradt!"}),
    SI_PA_PATTERN_REPAIRKIT_COUNT = table.concat({"%sMár csak <<1[nincs/%d db/%d db]>> %s <<1[javítókészleted/javítókészleted/javítókészleted]>> maradt!"}),
    SI_PA_PATTERN_SOULGEM_COUNT = table.concat({"%sMár csak <<1[nincs/%d db/%d db]>> %s <<1[lélekköved/lélekköved/lélekköved]>> maradt!"}),


    -- =================================================================================================================
    -- == OTHER STRINGS FOR MENU == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PALoot --
    SI_PA_DISPLAY_A_MESSAGE_WHEN = "Üzenet megjelenítése, amikor . . .",
    SI_PA_MARK_WITH = "Megjelölés ezzel . . .",
    SI_PA_ITEM_KNOWN = "Már ismert",
    SI_PA_ITEM_UNKNOWN = "Ismeretlen",
	SI_PA_ITEM_OTHERUNKNOWN = "Más karakter számára ismeretlen",
    SI_PA_ITEM_UNCOLLECTED = "Begyűjtetlen",
    SI_PA_ITEM_COMPANION_ITEM = "Kísérő tárgy"
}

for key, value in pairs(PALStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
