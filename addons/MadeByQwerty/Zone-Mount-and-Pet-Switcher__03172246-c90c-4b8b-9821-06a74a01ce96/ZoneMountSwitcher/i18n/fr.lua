-- i18n/fr.lua

-- chargé
ZO_CreateStringId("ZMS_LOADED",        "|c87CEEBZone Mount Switcher chargé.|r Tape /zms pour l’aide.")

-- aide
ZO_CreateStringId("ZMS_HELP_TITLE",       "|c87CEEBSwitcher de Monture par Zone|r : commandes")
ZO_CreateStringId("ZMS_HELP_SETMOUNT",    "/zms setmount <Groupe>   — ajoute la |c87CEEBmonture actuellement active|r au groupe.")
ZO_CreateStringId("ZMS_HELP_CLEARMOUNT",  "/zms clearmount <Groupe> — supprime toutes les montures du groupe.")
ZO_CreateStringId("ZMS_HELP_SETPET",      "/zms setpet <Groupe>     — ajoute le |c87CEEBfamilier actuellement actif|r au groupe.")
ZO_CreateStringId("ZMS_HELP_CLEARPET",    "/zms clearpet <Groupe>   — supprime tous les familiers du groupe.")
ZO_CreateStringId("ZMS_HELP_SETALL",      "/zms setall <Groupe>     — ajoute la monture et le familier actifs au groupe.")
ZO_CreateStringId("ZMS_HELP_CLEARALL",    "/zms clearall <Groupe>   — supprime montures et familiers du groupe.")
ZO_CreateStringId("ZMS_HELP_TEST",        "/zms test                — applique la configuration pour la zone courante.")
ZO_CreateStringId("ZMS_HELP_DEBUG",       "/zms debug               — bascule le mode debug.")
ZO_CreateStringId("ZMS_HELP_LIST",        "/zms list [Groupe]       — affiche les zones associées et la liste des montures/familiers (tous ou un groupe).")
ZO_CreateStringId("ZMS_HELP_RESETDEFAULTS","/zms resetdefaults       — réinitialise les zones selon le pack par défaut.")
ZO_CreateStringId("ZMS_HELP_GROUPS",      "Groupes disponibles : %s")

-- mots / commun
ZO_CreateStringId("ZMS_WORD_MOUNT",       "Monture")
ZO_CreateStringId("ZMS_WORD_PET",         "Familier")
ZO_CreateStringId("ZMS_EMPTY",            "vide")
ZO_CreateStringId("ZMS_NONE",             "aucune")

-- ok / erreurs (monture)
ZO_CreateStringId("ZMS_ERR_UNKNOWN",      "Groupe inconnu : %s")
ZO_CreateStringId("ZMS_ERR_READMOUNT",    "Impossible de lire la monture active. Ouvre |c87CEEBCollections > Montures|r, active celle que tu veux, puis refais la commande.")
ZO_CreateStringId("ZMS_OK_SETMOUNT",      "OK : « %s » → monture id %d ajoutée")
ZO_CreateStringId("ZMS_OK_CLEARMOUNT",    "Toutes les montures ont été supprimées pour « %s ».")
ZO_CreateStringId("ZMS_NO_CLEARMOUNT",    "Aucune monture à supprimer pour « %s ».")
ZO_CreateStringId("ZMS_DEBUG_TOGGLE",     "Debug = %s")

-- ok / erreurs (familier)
ZO_CreateStringId("ZMS_ERR_READPET",      "Impossible de lire le familier actif. Ouvre |c87CEEBCollections > Animaux non-combattants|r, active celui que tu veux, puis refais la commande.")
ZO_CreateStringId("ZMS_OK_SETPET",        "OK : « %s » → familier %s ajouté")
ZO_CreateStringId("ZMS_OK_CLEARPET",      "Tous les familiers ont été supprimés pour « %s ».")
ZO_CreateStringId("ZMS_NO_CLEARPET",      "Aucun familier à supprimer pour « %s ».")

-- ok / erreurs (setall/clearall)
ZO_CreateStringId("ZMS_OK_SETALL",        "OK : « %s » → Monture=%s ajoutée, Familier=%s ajouté")
ZO_CreateStringId("ZMS_OK_CLEARALL",      "Montures et familiers supprimés pour « %s ».")
ZO_CreateStringId("ZMS_ERR_READALL",      "Impossible de lire la monture ou le familier actif. Ouvre |c87CEEBCollections|r, active ceux que tu veux, puis refais la commande.")

-- reset defaults
ZO_CreateStringId("ZMS_OK_RESETDEFAULTS", "Zones réinitialisées au pack par défaut (v%s).")
ZO_CreateStringId("ZMS_ERR_NODEFAULTS",   "Aucun pack par défaut disponible.")

-- logs groupe/zone
ZO_CreateStringId("ZMS_LOG_NOGROUP_FOR_ZONE", "Aucun groupe pour la zone %s (%d)")
ZO_CreateStringId("ZMS_LOG_APPLY_MOUNT",      "Application MONTURE : %s → %s (id %d)")
ZO_CreateStringId("ZMS_LOG_PET_LOCKED",       "SetActivePet : familier %d non débloqué")
ZO_CreateStringId("ZMS_LOG_APPLY_PET",        "Application FAMILIER : %s → %s (id %d)")
ZO_CreateStringId("ZMS_LOG_PET_ALREADY",      "Familier déjà actif")
ZO_CreateStringId("ZMS_LOG_ALREADY",          "Monture déjà active")
ZO_CreateStringId("ZMS_LOG_UNLOCKED",         "SetActiveMount : monture %d non débloquée")
ZO_CreateStringId("ZMS_LOG_NOAPI",            "Aucune API dispo pour activer une monture")
ZO_CreateStringId("ZMS_LOG_NOMOUNT",          "Aucune monture définie pour le groupe « %s ».")
ZO_CreateStringId("ZMS_LOG_NOPET",            "Aucun familier défini pour le groupe « %s ».")
ZO_CreateStringId("ZMS_LOG_ALREADY_BOUND",    "Zone %d déjà liée à %s")
ZO_CreateStringId("ZMS_LOG_BOUND",            "Lien zone %d (%s) → %s")
ZO_CreateStringId("ZMS_LOG_UNBOUND",          "Déliaison zone %d de %s")

-- list
ZO_CreateStringId("ZMS_LIST_HEADER",          "|c87CEEBAssociations actuelles (zones par groupe) :|r")
ZO_CreateStringId("ZMS_LIST_MOUNTSPETS",      "|c87CEEBListes montures / familiers :|r")
ZO_CreateStringId("ZMS_LIST_GROUP_HEADER",    "|c87CEEBZones liées à %s :|r")

-- noms localisés des groupes
ZO_CreateStringId("ZMS_GROUP_NORDIC",    "Nordique")
ZO_CreateStringId("ZMS_GROUP_TEMPERATE", "Tempéré")
ZO_CreateStringId("ZMS_GROUP_COASTAL",   "Côtière")
ZO_CreateStringId("ZMS_GROUP_FOREST",    "Forestière")
ZO_CreateStringId("ZMS_GROUP_ARID",      "Aride")
ZO_CreateStringId("ZMS_GROUP_MARSH",     "Marécageux")
ZO_CreateStringId("ZMS_GROUP_VOLCANIC",  "Volcanique")
ZO_CreateStringId("ZMS_GROUP_OBLIVION",  "Oblivion")
