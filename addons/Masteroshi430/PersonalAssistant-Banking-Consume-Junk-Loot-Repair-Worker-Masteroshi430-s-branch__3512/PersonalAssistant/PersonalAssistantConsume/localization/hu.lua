local PAC = PersonalAssistant.Constants
local PACOStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

    -- =================================================================================================================
    -- == MENU/PANEL TEXTS == --
    -- -----------------------------------------------------------------------------------------------------------------
-- PAConsume Menü --
    SI_PA_MENU_CONSUME_DESCRIPTION = "A PAConsume képes mérget alkalmazni, főzetet használni, vagy ételt/italt és EXP tekercseket fogyasztani",

    -- Automatikus méreg --
    SI_PA_MENU_CONSUME_POISON_HEADER = "Automatikus méregalkalmazás",
    SI_PA_MENU_CONSUME_POISON_ENABLE = "Automatikus méregalkalmazás engedélyezése",
    SI_PA_MENU_CONSUME_POISON_ENABLE_T = "Automatikus méregalkalmazás harc után, ha már nincs a fegyveren",
    SI_PA_MENU_CONSUME_POISON_SMALL_STACKS_FIRST = "Kisebb csomagok használata először",
    SI_PA_MENU_CONSUME_POISON_SMALL_STACKS_FIRST_T = "A kisebb méregcsomagok használata először, a leltárhelyek felszabadítása érdekében",
    
    -- Automatikus főzet --
    SI_PA_MENU_CONSUME_POTION_HEADER = "Főzet automatikus gyorsslotba helyezése",
    SI_PA_MENU_CONSUME_POTION_ENABLE = "Automatikus gyorsslotba helyezés engedélyezése",
    SI_PA_MENU_CONSUME_POTION_ENABLE_T = "Automatikus gyorsslotba helyezés harc után, ha a kiválasztott gyorsslot üres",
    SI_PA_MENU_CONSUME_POTION_SMALL_STACKS_FIRST = "Kisebb csomagok használata először",
    SI_PA_MENU_CONSUME_POTION_SMALL_STACKS_FIRST_T = "A kisebb főzetcsomagok használata először, a leltárhelyek felszabadítása érdekében",
	
	-- Automatikus étel & exp fogyasztás --
	SI_PA_MENU_CONSUME_FOOD_HEADER = "Automatikus étel/ital fogyasztás",
	SI_PA_MENU_CONSUME_EXP_HEADER = "Automatikus EXP tekercs fogyasztás",
	SI_PA_MENU_CONSUME_CURRENT_FOOD_BUFF = "Jelenlegi ételbónusz ehhez a karakterhez: ",
	SI_PA_MENU_CONSUME_CURRENT_EXP_BUFF = "Jelenlegi EXP bónusz ehhez a karakterhez: ",
    SI_PA_MENU_CONSUME_LABEL_ON = "Automatikus fogyasztás",
    SI_PA_MENU_CONSUME_LABEL_OFF = "Automatikus fogyasztás leállítása",
	SI_PA_MENU_CONSUME_USE_NUMBER_FOOD = "Puffer (másodperccel előtte)",
	SI_PA_MENU_CONSUME_USE_NUMBER_FOOD_T =  "Ennyi másodperccel azelőtt fogyassza el az ételt, mielőtt a jelenlegi lejárna. Használj egy 0 és 600 közötti számot a puffer idő módosításához.",
	SI_PA_MENU_CONSUME_USE_NUMBER_EXP = "Puffer (másodperccel utána)",
    SI_PA_MENU_CONSUME_USE_NUMBER_EXP_T =  "Ennyi másodperccel azután fogyassza el az EXP bónuszt, hogy a jelenlegi lejárt. Használj egy 0 és 600 közötti számot a puffer idő módosításához.",
    SI_PA_MENU_CONSUME_TURN_OFF_FOOD = "Felfüggesztés",
    SI_PA_MENU_CONSUME_TURN_OFF_FOOD_T = "Az adott étel/ital automatikus fogyasztásának leállítása",
    SI_PA_MENU_CONSUME_TURN_OFF_EXP = "Felfüggesztés",
    SI_PA_MENU_CONSUME_TURN_OFF_EXP_T = "Az adott EXP bónusz automatikus fogyasztásának leállítása",



    -- =================================================================================================================
    -- == CSEVEGŐ KIMENETEK == --
    -- -----------------------------------------------------------------------------------------------------------------
    -- PAConsume méreg --
    SI_PA_CHAT_CONSUME_POISON_MAIN = "A fő fegyver átitatva ezzel: ",
    SI_PA_CHAT_CONSUME_POISON_BACKUP = "A másodlagos fegyver átitatva ezzel: ",
    
    -- PAConsume főzet --
    SI_PA_CHAT_CONSUME_POTION = "A jelenlegi gyorsslot felszerelve ezzel: ",
    
	
	-- PAConsume étel & exp --
	SI_PA_CHAT_CONSUME_NO_FOOD = "Még nincs kiválasztva étel. Nyisd meg a leltárat, kattints jobb gombbal a kívánt ételre vagy italra, és válaszd az 'Automatikus fogyasztás' opciót.",
	SI_PA_CHAT_CONSUME_AUTO_EATING_OFF_BUT = "Az automatikus evés ki van kapcsolva. De a(z) <<1>> ételt választottad kedvencként.",
	SI_PA_CHAT_CONSUME_TO_ENABLE_EATING = "Az automatikus evés engedélyezéséhez nyisd meg a leltárat, kattints jobb gombbal a kívánt ételre vagy italra, és válaszd az 'Automatikus fogyasztás' opciót.",
	SI_PA_CHAT_CONSUME_LOOKS_LIKE = "Úgy tűnik, a(z) <<1>> van az étlapon.",
	SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_MINUTES = "Ez a jelenlegi étel lejárta előtt <<1[akkor/$d perccel/$d perccel]>> lesz elfogyasztva.",
	SI_PA_CHAT_CONSUME_THIS_FOOD_WILL_BE_SECONDS = "Ez a jelenlegi étel lejárta előtt <<1[akkor/$d másodperccel/$d másodperccel]>> lesz elfogyasztva.",
	SI_PA_CHAT_CONSUME_YOU_HAVE_ONLY = "Már csak <<1>> maradt a táskádban.",
	SI_PA_CHAT_CONSUME_YOU_HAVE = "<<1>> maradt a táskádban.",
	SI_PA_CHAT_CONSUME_WISH_STOP_EATING = "Ha szeretnéd leállítani az automatikus evést ennél a karakternél, használd a PAconsume menüt.",
	
	SI_PA_CHAT_CONSUME_NO_EXP = "Még nincs EXP bónusz kiválasztva. Nyisd meg a leltárat, kattints jobb gombbal a kívánt EXP tekercsre, és válaszd az 'Automatikus fogyasztás' opciót.",
	SI_PA_CHAT_CONSUME_AUTO_EXPING_OFF_BUT = "Az automatikus EXP bónusz fogyasztás ki van kapcsolva. De a(z) <<1>> van kiválasztva kedvenc EXP bónuszként.",
    SI_PA_CHAT_CONSUME_TO_ENABLE_EXPING = "Az automatikus EXP bónusz engedélyezéséhez nyisd meg a leltárat, kattints jobb gombbal a kívánt EXP tekercsre, és válaszd az 'Automatikus fogyasztás' opciót.",
    SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_MINUTES = "Ez a jelenlegi EXP bónusz lejárta után <<1[akkor/$d perccel/$d perccel]>> lesz elfogyasztva.",
    SI_PA_CHAT_CONSUME_THIS_EXP_WILL_BE_SECONDS = "Ez a jelenlegi EXP bónusz lejárta után <<1[akkor/$d másodperccel/$d másodperccel]>> lesz elfogyasztva.",
    SI_PA_CHAT_CONSUME_WISH_STOP_EXPING = "Ha szeretnéd leállítani az automatikus EXP bónusz fogyasztást ennél a karakternél, használd a PAconsume menüt.",

    SI_PA_CHAT_CONSUME_FOOD_WILL_BE_CONSUMED = "Az étel a jelenlegi lejárta előtt <<1>> másodperccel lesz elfogyasztva.",
    SI_PA_CHAT_CONSUME_EXP_WILL_BE_CONSUMED = "Az EXP bónusz a jelenlegi lejárta után <<1>> másodperccel lesz elfogyasztva.",
    
	SI_PA_CHAT_CONSUME_HAS_BEEN_AUTOMATICALLY_CONSUMED = " automatikusan el lett fogyasztva.",
	SI_PA_CHAT_CONSUME_BUT_HAVE_ZERO = "Beállítottad a(z) <<1>>-t automatikus fogyasztásra, de 0 db van a táskádban.",

	SI_PA_CHAT_CONSUME_FOOD_EXPIRE_SECONDS = "A jelenlegi étel lejár: <<1[$d másodperc múlva./$d másodperc múlva./$d másodperc múlva.]>>",
	SI_PA_CHAT_CONSUME_FOOD_EXPIRE_MINUTES = "A jelenlegi étel lejár: <<1[$d perc múlva./$d perc múlva./$d perc múlva.]>>",
	SI_PA_CHAT_CONSUME_EXP_EXPIRE_SECONDS = "A jelenlegi EXP bónusz lejár: <<1[$d másodperc múlva./$d másodperc múlva./$d másodperc múlva.]>>",
	SI_PA_CHAT_CONSUME_EXP_EXPIRE_MINUTES = "A jelenlegi EXP bónusz lejár: <<1[$d perc múlva./$d perc múlva./$d perc múlva.]>>",
	
}

for key, value in pairs(PACOStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end


local PACOGenericStrings = {
    -- =================================================================================================================
    -- Language independent texts (do not need to be translated/copied to other languages --

    -- =================================================================================================================
    -- == CHAT OUTPUTS == --
    -- -----------------------------------------------------------------------------------------------------------------
    --SI_PA_CHAT_Consume_CHARGE_WEAPON = "%s (%d%% --> %d%%) - %s",
}

for key, value in pairs(PACOGenericStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end
