-- -----------------------------------------------------------------------------
-- Lang/de.lua
-- -----------------------------------------------------------------------------
local strings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "Alle entsperren",
    SKILLBLOCKER_NJ_UNLOCKED                           = "Entsperrt",
    SKILLBLOCKER_NJ_LOCKED                             = "Gesperrt",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "Im Kampf gesperrt",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "Gesperrt wenn aktiv",
    SKILLBLOCKER_NJ_LOADED                             = "Erfolgreich geladen",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "In Werwolfgestalt gesperrt",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "Sperreinstellungen",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "Sperren wenn Stapel <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "Sperren wenn Crux <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "Blockieren, wenn Crux ≥",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "Blockieren bis zum <<1>> proc",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "Sperren wenn Ziel-LP >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "Sperren wenn < <<1>> Punkte",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "Für <<1>> Sek. sperren",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "Sperren bis zur <<1>> Explosion",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "Allgemeine Einstellungen",
    SKILLBLOCKER_NJ_REMEMBER                           = "Gesperrte Skills merken?",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "Warnung anzeigen",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "Zeigt eine Systemwarnung an, wenn versucht wird, einen gesperrten Skill zu nutzen",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "Schutz vor Doppelaktivierung",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "Schutz nach leichtem Angriff zurücksetzen",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "Wenn aktiviert, entfernt ein leichter Angriff (LMB) sofort den Schutz vor Doppelaktivierung.",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "Schutzdauer",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "Zeit in Sekunden, in der die Fähigkeit nach Nutzung inaktiv bleibt (0 = ∞).",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "Meine Liste gesperrter Fähigkeiten:",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "Hauptleiste:",
    SKILLBLOCKER_NJ_BACK_BAR                           = "Zweitleiste:",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "Aktivieren",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "Deaktivieren",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "Doppelnutzung sperren",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "Sperre nach Stapeln",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "Sperre nach Crux",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "Sperre nach Proc",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "Sperre nach «Explosion»",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "Sperre nach Ultimative Punkte",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "Sperre nach Dauer",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "Sperre nach Ziel-LP",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "«Verbrechen» blockieren",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "Aus Slot entfernen",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "Alle Fähigkeiten freischalten",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "Sperre umschalten: Slot 1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "Sperre umschalten: Slot 2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "Sperre umschalten: Slot 3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "Sperre umschalten: Slot 4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "Sperre umschalten: Slot 5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "Sperre umschalten: Ulti",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end