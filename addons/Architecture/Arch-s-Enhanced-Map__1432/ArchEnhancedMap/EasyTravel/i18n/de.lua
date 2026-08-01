local localization = {
    JUMP_FAILED_UNHANDLED = "Sprung wurde unterbrochen, unbehandeltes Resultat: %d, %s",

    STATUS_TEXT_READY = "Vorbereitung auf Sprung",
    STATUS_TEXT_JUMP_REQUESTED = "Sprung angefordert",
    STATUS_TEXT_JUMP_STARTED = "Sprung läuft (<<1>> Sekunden verbleibend)",
    STATUS_TEXT_JUMP_REQUEST_FAILED = "Sprung fehlgeschlagen",
    STATUS_TEXT_NO_JUMP_TARGETS = "Keine passenden Spieler gefunden\nWarte auf neue Ziele",

    DIALOG_TITLE = "Reise nach <<1>>",

    INVALID_TARGET_ZONE = "Ziel kann nicht durch einen Sprung erreicht werden"
}
ZO_ShallowTableCopy(localization, EasyTravel_AEM.Localization)
