local localization = { -- provided by Ayantir
    JUMP_FAILED_UNHANDLED = "La téléportation a été interrompu, erreur inconnue: %d, %s",

    STATUS_TEXT_READY = "Préparation au saut",
    STATUS_TEXT_JUMP_REQUESTED = "Téléportation initialisée",
    STATUS_TEXT_JUMP_STARTED = "Téléportation en cours (<<1>> secondes restantes)",
    STATUS_TEXT_JUMP_REQUEST_FAILED = "Téléportation échouée",
    STATUS_TEXT_NO_JUMP_TARGETS = "Aucun joueur n'a été trouvé pour voyager\nEn attente de nouveaux joueurs",

    DIALOG_TITLE = "Voyage vers <<1>>",

    INVALID_TARGET_ZONE = "La destination ne peut être atteinte par une téléportation",

    AUTOCOMPLETE_ZONE_LABEL_TEMPLATE = "<<1>> -|caaaaaa <<2[Aucun joueur/$d joueur/$d joueurs]>>",
}
ZO_ShallowTableCopy(localization, EasyTravel_AEM.Localization)
