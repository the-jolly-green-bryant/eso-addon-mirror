local PAC = PersonalAssistant.Constants
local PAStrings = {
    -- =================================================================================================================
    -- Language specific texts that need to be translated --

-- Üdvözlő üzenetek --
    SI_PA_WELCOME_NO_SUPPORT = "a szolgálatodban!   -   a [%s] nyelvhez (még) nincs fordítás",
    SI_PA_WELCOME_SUPPORT = "a szolgálatodban!",
    SI_PA_WELCOME_PLEASE_SELECT_PROFILE = table.concat({"üdvözöl! A kezdéshez kérlek lépj be az Addon beállításokba és válassz egy profilt. Köszönöm :-)"}),


    -- =================================================================================================================
    -- == MENÜ/PANEL SZÖVEGEK == --
    -- -----------------------------------------------------------------------------------------------------------------
    SI_PA_MENU_GENERAL_DESCRIPTION = "A PersonalAssistant különféle funkciók gyűjteménye, amelyek célja, hogy kényelmesebbé tegyék az ESO-val való játékot.\n\nMinden modul saját fiókszintű profillistával rendelkezik, ahol karakterenként kiválaszthatod, melyik legyen az aktív.",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Általános beállítások --
    SI_PA_MENU_GENERAL_HEADER = "Általános beállítások",
    SI_PA_MENU_GENERAL_SHOW_WELCOME = "Üdvözlő üzenet mutatása",

    SI_PA_MENU_GENERAL_TELEPORT_HEADER = "Lakhatás",
    SI_PA_MENU_GENERAL_TELEPORT_PRIMARY_HOUSE = table.concat({PAC.ICONS.OTHERS.HOME.NORMAL, " Utazás a házba"}),
    SI_PA_MENU_GENERAL_TELEPORT_PRIMARY_HOUSE_W = "Ha az aktuális helyszín lehetővé teszi a gyorsutazást, ez elindítja a teleportálást az elsődleges házadba!",
    SI_PA_MENU_GENERAL_TELEPORT_OUTSIDE = "Utazás a ház elé",
    SI_PA_MENU_GENERAL_TELEPORT_OUTSIDE_T = "Ha KI van kapcsolva, akkor a ház belsejébe utazol",

    -- -----------------------------------------------------------------------------------------------------------------
    -- Admin beállítások --
    SI_PA_MENU_ADMIN_HEADER = "Admin beállítások",
}

for key, value in pairs(PAStrings) do
    ZO_CreateStringId(key, value)
    SafeAddVersion(key, 1)
end