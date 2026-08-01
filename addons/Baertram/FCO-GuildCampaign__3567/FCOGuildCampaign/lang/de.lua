local companionStr = GetString(SI_UNIT_FRAME_NAME_COMPANION)
local companionKeybindBaseStr = "Zeige/Verst. " .. companionStr

local campDel = FCOGC.campaignIdDelimiter

local stringsDE = {
    --Keybinds
    FCOGC_SHOW_MY_CAMPAIGN                                  = "Zeige meine Kampagne im Chat",

    FCOGC_CURRENT_CAMPAIGN_HEADER                           = "K",
    FCOGC_CURRENT_CAMPAIGN_HEADER_TT                        = "Kampagne",

    FCOGC_SAME_CAMPAIGN_TT                                  = "|c00ff00In derselben Kampagne|r",
    FCOGC_DIFFERENT_CAMPAIGN_TT                             = "|cff0000In einer anderen Kampagne!|r",
    FCOGC_CAMPAIGNID_MISSING_IN_MEMBER_NOTE_TT              = "|cADD8E6;~<campaignId>|r fehlt in Mitglied-Notiz!",

    --LAM Settings
    FCOGC_LAM_SV_MODE                                       = 'Einstellungen Sicherungs-Modus',
    FCOGC_LAM_SV_MODE_TT                                    = 'Verwende Account-weite Einstellungen (identisch für alle deine Charaktere) oder individuelle Einstellungen je Charakter?',
    FCOGC_LAM_SV_EACH_CHARACTER                             = "Jeder Charakter einzeln",
    FCOGC_LAM_SV_ACCOUNT_WIDE                               = "Account weit",

    FCOGC_LAM_SETTING_ENABLE_GUILD                          = "Aktiviere Gilde %s (%q)",

    FCOGC_LAM_SETTING_HEADER_GUILD_MEMBER_NOTES             = "Gilden Mitglied Notiz",
    FCOGC_LAM_SETTING_GMN_RESERVE_LAST_5_CHARS              = "Reserviere letzte 5 Zeichen: KampagnenID",
    FCOGC_LAM_SETTING_GMN_RESERVE_LAST_5_CHARS_TT           = "Reserviert die letzten 5 Zeichen deiner Gilden Mitglie Notiz für den "..tostring(campDel).."<KampagnenId> Identifier.\nWenn diese Einstellung aktiv ist werden die letzten 5 Zeichen deiner Gilden Mitglied Notiz überschrieben!\nIst diese Einstellung deaktiviert, so wird deine Gilden Mitglied Notiz nicht überschrieben, wenn die maximale Länge bereits verwendet wurde. Du musst dich dann manuell darum kümmern die Mitglied Notiz zu aktualisieren, außer es stehen mindestens noch 5 Zeichen zur Verfügung.",
}


for stringId, stringValue in pairs(stringsDE) do
    SafeAddString(_G[stringId], stringValue, 2)
end
