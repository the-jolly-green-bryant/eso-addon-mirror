local companionStr = GetString(SI_UNIT_FRAME_NAME_COMPANION)
local companionKeybindBaseStr = "Zeige/Verst. " .. companionStr

local stringsDE = {
    FCOCO_NO_COMPANION_UNLOCKED_YET                    = "[FCOCompanion]Du hast noch keinen " .. GetString(SI_UNIT_FRAME_NAME_COMPANION) .. " freigeschaltet. Bitte schließe eine der Freischalt-Quests zuerst ab und lade danach die Benutzeroberfläche neu!",

    --FCOCO_SHOW_COMPANION_MENU   = "Zeige \'" .. GetString(SI_INTERACT_OPTION_COMPANION_MENU) .. "\'",
    FCOCO_TOGGLE_COMPANION                             = companionKeybindBaseStr .. " (letzten)",

    --LAM Settings
    FCOCO_LAM_SV_MODE                                  = 'Einstellungen Sicherungs-Modus',
    FCOCO_LAM_SV_MODE_TT                               = 'Verwende Account-weite Einstellungen (identisch für alle deine Charaktere) oder individuelle Einstellungen je Charakter?',
    FCOCO_LAM_SV_EACH_CHARACTER                        = "Jeder Charakter einzeln",
    FCOCO_LAM_SV_ACCOUNT_WIDE                          = "Account weit",

    FCOCO_LAM_SETTING_HEADER_JUNK                      = GetString(SI_ITEMTYPEDISPLAYCATEGORY9),
    FCOCO_LAM_SETTING_ENABLE_ACCOUNT_WIDE_JUNK         = "Aktiviere Account weiten Gefährten Trödel",
    FCOCO_LAM_SETTING_ENABLE_ACCOUNT_WIDE_JUNK_TT      = "Aktiviere diese Option damit die Gefährten Trödel Markierungen, und die Einstellungen, für den gesamten Account gleich gespeichert werden. Ist diese Option deaktiviert, so werden die Einstellungen und Gegenstände je Charakter unterschiedlich gespeichert.",
    FCOCO_LAM_SETTING_ENABLE_JUNK                      = "Gefährten Gegenstände->Trödel",
    FCOCO_LAM_SETTING_ENABLE_JUNK_TT                   = "Aktiviere diese Option damit dein Inventar Kontextmenü den \'Markiere als Trödel\' Eintrag bei Gefährten Gegenständen anzeigt. Als Trödel markierte Gefährten Gegenstände werden dann auch auf dem Trödel Inventar Reiter angezeigt.",
    FCOCO_LAM_SETTING_AUTO_JUNK_SAME_ITEMS             = "Auto-Markierung für gleiche Gegenstände im Beutel",
    FCOCO_LAM_SETTING_AUTO_JUNK_SAME_ITEMS_TT          = "Erkennt automatisch, ob der gleiche Gefährten Gegenstand noch einmal in deinem Beutel ist, und markiert/entfernt die Markierung bei diesem genau wie beim aktuell veränderten Gefährten Gegenstand.",
    FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC              = "Migr. Trödel Char.->Acc.",
    FCOCO_LAM_SETTING_JUNK_MIGRATE_TO_ACC_TT           = "Achtung: Migriert die Gefährten Trödel Gegenstände des aktuell eingeloggten Charakters zu den Account weiten. Es wird versucht die Gegenstände zu ergänzen, welche noch nicht im Account Weiten Gefährten Trödel vorhanden sind.",
    FCOCO_LAM_JUNK_MIGRATE_TO_ACC_STR                  = "%s vom Charakter zum Account weiten Gefährten Trödel migriert",
    FCOCO_LAM_JUNK_MIGRATE_TO_ACC_TOTAL_STR            = "Es wurden %s Gegenstände vom Charakter zum Account weiten Gefährten Trödel migriert",

    FCOCO_LAM_SETTING_UNSUMMON_AT_CRAFTING_TABLE       = "Wegschicken an Handwerksstationen",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CRAFTING_TABLE_TT    = "Schickt deinen Begleiter an einer Handwerksstation fort, wenn du mit dieser interagierst",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CRAFTING_TABLE    = "Wieder beschwören nach der Handwerksstation",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CRAFTING_TABLE_TT = "Beschwört den zuletzt aktiven Begleiter, wenn du die Handwerksstation wieder verlässt",

    FCOCO_LAM_SETTING_UNSUMMON_AT_BANK                  = "Wegschicken an Banken",
    FCOCO_LAM_SETTING_UNSUMMON_AT_BANK_TT               = "Schickt deinen Begleiter an einer Bank fort, wenn du mit dieser interagierst",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_BANK               = "Wieder beschwören nach der Bank",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_BANK_TT            = "Beschwört den zuletzt aktiven Begleiter, wenn du die Bank wieder verlässt",

    FCOCO_LAM_SETTING_UNSUMMON_AT_VENDOR                = "Wegschicken beim Händler/Hehler",
    FCOCO_LAM_SETTING_UNSUMMON_AT_VENDOR_TT             = "Schickt deinen Begleiter bei einem Händler/Hehler fort, wenn du mit diesem interagierst",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_VENDOR             = "Wieder beschwören nach dem Händler/Hehler",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_VENDOR_TT          = "Beschwört den zuletzt aktiven Begleiter, wenn du den Händler/Hehler wieder verlässt",

    FCOCO_LAM_SETTING_UNSUMMON_AT_FISHING               = "Wegschicken am Fischrgrund",
    FCOCO_LAM_SETTING_UNSUMMON_AT_FISHING_TT            = "Schickt deinen Begleiter bei einem Fischgrund fort, wenn du mit diesem interagierst",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING            = "Wieder beschwören nach dem Fischen",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_TT         = "Beschwört den zuletzt aktiven Begleiter, wenn du das Fischen beendet hast.\n\'Fischen beenden\' bedeutet nach dem Einholen der Angel wird die unten gesetzte Verzögerung in Millisekunden abgewartet, bis der Gefährte neu gerufen wird. Wird während der Verzögerung wieder gefischt, so wird das Beschwören abgebrochen.",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_DELAY      = "Wieder Beschwören Verzögerung",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_FISHING_DELAY_TT   = "Verzögert das Beschwören des Gefährten nach dem Beenden des Fishens um diese Anzahl Millisekunden (1000 = 1 Sekunde)",

    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING             = "Wegschicken beim Schleichen",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_TT          = "Schickt deinen Begleiter beim Schleichen fort",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_NO_COMBAT   = "Nicht im Kampf",
    FCOCO_LAM_SETTING_UNSUMMON_AT_CROUCHING_NO_COMBAT_TT= "Schickt den Begleiter nur dann weg, wenn du gerade nicht im Kampf bist, als du zu schleichen beginnst.",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING          = "Wieder beschwören nach dem Schleichen",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_TT       = "Beschwört den zuletzt aktiven Begleiter, wenn du den Schleich Modus verlässt.\n\'Schleich Modus verlassen\' bedeutet nach dem du aus dem Schleichen aufgedeckt wirst/herauskommts wird die unten gesetzte Verzögerung in Millisekunden abgewartet, bis der Gefährte neu gerufen wird. Wird während der Verzögerung wieder geschlichen, so wird das Beschwören abgebrochen.",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_DELAY    = "Wieder Beschwören Verzögerung",
    FCOCO_LAM_SETTING_RESUMMON_AFTER_CROUCHING_DELAY_TT = "Verzögert das Beschwören des Gefährten nach dem Schleichen um diese Anzahl Millisekunden (1000 = 1 Sekunde)",

    FCOCO_LAM_SETTING_DISABLE_PIN_AT_COMPASS            = "Kompass Pin verstecken",
    FCOCO_LAM_SETTING_DISABLE_PIN_AT_COMPASS_TT         = "Verstecke den Gefährten Pin auf dem Kompass",
}

local companionInfo = FCOCO.companionInfo
for companionDefId, companionCollectibleId in pairs(companionInfo) do
    --local companionCollectibleId = GetCompanionCollectibleId(companionDefId)
    if companionCollectibleId ~= nil then
        local companionName = GetCollectibleName(companionCollectibleId)
        local companionNameClean = ZO_CachedStrFormat(SI_UNIT_NAME, companionName)
        stringsDE["FCOCO_TOGGLE_COMPANION_" .. tostring(companionDefId)]     = companionKeybindBaseStr .. ": \'" .. companionNameClean .. "\'"
    end
end

for stringId, stringValue in pairs(stringsDE) do
    SafeAddString(_G[stringId], stringValue, 2)
end
