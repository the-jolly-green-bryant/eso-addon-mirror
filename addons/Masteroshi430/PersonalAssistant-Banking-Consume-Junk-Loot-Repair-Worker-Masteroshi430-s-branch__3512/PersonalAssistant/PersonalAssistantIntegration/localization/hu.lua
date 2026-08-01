local PAIStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
 -- PAIntegration Menü --
    SI_PA_MENU_INTEGRATION_DESCRIPTION = "A PAIntegration képes integrálni a PersonalAssistant kiegészítők funkcionalitását más külső kiegészítőkkel, mint például a Dolgubon's Lazy Writ Crafter vagy az FCO ItemSaver.",
    SI_PA_MENU_INTEGRATION_NOTHING_AVAILABLE = "Jelenleg nincsenek olyan telepített/engedélyezett kiegészítőid, amelyeket a PAIntegration támogat.",
	
    -- Character Knowledge --
    SI_PA_MENU_INTEGRATION_CK_CHARACTER = "Ismertnek tekinti, ha ismeri:",
    SI_PA_MENU_INTEGRATION_CK_ENABLE = "Character Knowledge integráció engedélyezése",
    SI_PA_MENU_INTEGRATION_CK_ENABLE_T = table.concat({"Használd a Character Knowledge-t annak meghatározására, hogy egy ", GetString("SI_ITEMTYPE", ITEMTYPE_RECIPE), " vagy ", GetString("SI_ITEMTYPE", ITEMTYPE_RACIAL_STYLE_MOTIF), " ismert-e"}),
    SI_PA_MENU_INTEGRATION_CK_INITIALIZING = "Character Knowledge inicializálása...",

    -- Dolgubon's Lazy Writ Crafter --
    SI_PA_MENU_INTEGRATION_LWC_COMPATIBILITY = "Kompatibilitás a Dolgubon's Lazy Writ Crafterrel",
    SI_PA_MENU_INTEGRATION_LWC_COMPATIBILITY_T = "Ha aktív Writ küldetéseid vannak, és a 'Withdraw writ items' engedélyezve van a Dolgubon's Lazy Writ Crafterben, akkor ezeknél a tárgyaknál a 'Deposit to Bank' (Bankba helyezés) beállítás figyelmen kívül lesz hagyva. Ezzel elkerülhető, hogy a kivett tárgyak azonnal vissza legyenek helyezve a bankba.",

    -- FCO ItemSaver --
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_SELLING = "Zárolt tárgyak automatikus eladásának megelőzése",
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_MOVING = "Zárolt tárgyak mozgatásának megelőzése",
    SI_PA_MENU_INTEGRATION_FCOIS_LOCKED_PREVENT_MOVING_T = "Ha BE van kapcsolva, az FCO ItemSaverrel zárolt tárgyak nem lesznek bankba helyezve, sem onnan kivéve.",
    SI_PA_MENU_INTEGRATION_FCOIS_SELL_AUTOSELL_MARKED = "Megjelölt tárgyak automatikus eladása kereskedőknél/orgazdáknál?",
    SI_PA_MENU_INTEGRATION_FCOIS_ITEM_MOVE_MARKED = "Megjelölt tárgyak mozgatása a bank megnyitásakor?",


    -- =================================================================================================================
    -- == CSEVEGŐ KIMENETEK == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAIntegration --


    -- =================================================================================================================
    -- == EGYÉB SZÖVEGEK A MENÜHÖZ == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAIntegration Menü --
    SI_PA_MENU_INTEGRATION_PAB_REQUIRED = "További beállítások válnak láthatóvá, ha a PABanking engedélyezve van",
    SI_PA_MENU_INTEGRATION_PAJ_REQUIRED = "További beállítások válnak láthatóvá, ha a PAJunk engedélyezve van",

    SI_PA_MENU_INTEGRATION_MORE_TO_COME = "További FCO ItemSaver integrációk érkeznek a jövőbeli frissítésekkel",
}

for key, value in pairs(PAIStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PAIGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------

    -- Character Knowledge
    SI_PA_MENU_INTEGRATION_CK_HEADER = "Character Knowledge",
	
	-- Dolgubon's Lazy Writ Crafter --
    SI_PA_MENU_INTEGRATION_LWC_HEADER = "Dolgubon's Lazy Writ Crafter",

    -- FCO ItemSaver --
    SI_PA_MENU_INTEGRATION_FCOIS_HEADER = "FCO Item Saver",
}

for key, value in pairs(PAIGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
