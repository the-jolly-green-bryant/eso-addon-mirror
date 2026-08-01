-- -----------------------------------------------------------------------------
-- Lang/fr.lua
-- -----------------------------------------------------------------------------
local strings = {
    SKILLBLOCKER_NJ_UNLOCK_ALL                         = "Tout débloquer",
    SKILLBLOCKER_NJ_UNLOCKED                           = "Débloqué",
    SKILLBLOCKER_NJ_LOCKED                             = "Verrouillé",
    SKILLBLOCKER_NJ_LOCKED_COMBAT                      = "Verrouillé en combat",
    SKILLBLOCKER_NJ_LOCKED_ACTIVE                      = "Verrouillé si actif",
    SKILLBLOCKER_NJ_LOADED                             = "Chargé avec succès",
    SKILLBLOCKER_NJ_LOCKED_WEREWOLF                    = "Verrouillé sous forme de loup-garou",

    SKILLBLOCKER_NJ_BLOCK_SETTINGS                     = "Paramètres de blocage",
    SKILLBLOCKER_NJ_BLOCK_STACKS                       = "Bloquer si cumuls <",
    SKILLBLOCKER_NJ_BLOCK_CRUX                         = "Bloquer si Crux <",
    SKILLBLOCKER_NJ_BLOCK_REVERSE                      = "Bloquer si Crux ≥",
    SKILLBLOCKER_NJ_BLOCK_PROC                         = "Bloquer jusqu'au <<1>> proc",
    SKILLBLOCKER_NJ_BLOCK_HP                           = "Bloquer si PV cible >",
    SKILLBLOCKER_NJ_BLOCK_ULTIMATE                     = "Bloquer si < <<1>> points",
    SKILLBLOCKER_NJ_BLOCK_DURATION                     = "Bloquer pendant <<1>> sec",
    SKILLBLOCKER_NJ_BLOCK_DEBUFF                       = "Bloquer jusqu'à l'<<1>> explosion",

    SKILLBLOCKER_NJ_GENERAL_SETTINGS                   = "Paramètres généraux",
    SKILLBLOCKER_NJ_REMEMBER                           = "Mémoriser les verrouillages ?",
    SKILLBLOCKER_NJ_SHOW_ALERT                         = "Afficher l'alerte",
    SKILLBLOCKER_NJ_ALERT_TOOLTIP                      = "Afficher un avertissement système lors de la tentative d'utilisation d'une compétence bloquée",

    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_SETTINGS         = "Protection contre double activation",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA               = "Réinit. protection après attaque légère",
    SKILLBLOCKER_NJ_RESET_DOUBLE_CAST_LA_TOOLTIP       = "Si activé, une attaque légère (clic gauche) supprime instantanément la protection contre la double activation.",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION         = "Durée de la protection",
    SKILLBLOCKER_NJ_DOUBLE_CAST_BLOCK_DURATION_TOOLTIP = "Temps en secondes pendant lequel la compétence reste inactive après utilisation (0 = ∞).",

    SKILLBLOCKER_NJ_MENU_ACTIVE_BLOCKS_TITLE           = "Ma liste de compétences bloquées:",
    SKILLBLOCKER_NJ_MAIN_BAR                           = "Barre principale:",
    SKILLBLOCKER_NJ_BACK_BAR                           = "Barre secondaire:",

    SKILLBLOCKER_NJ_ACTION_ENABLE                      = "Activer",
    SKILLBLOCKER_NJ_ACTION_DISABLE                     = "Désactiver",

    SKILLBLOCKER_NJ_MENU_DOUBLE_CAST_TITLE             = "Blocage double activation",
    SKILLBLOCKER_NJ_MENU_STACK_TITLE                   = "Blocage par cumuls",
    SKILLBLOCKER_NJ_MENU_CRUX_TITLE                    = "Blocage par Crux",
    SKILLBLOCKER_NJ_MENU_PROC_TITLE                    = "Blocage par déclenchement (Proc)",
    SKILLBLOCKER_NJ_MENU_DEBUFF_TITLE                  = "Blocage par «explosion» de compétence",
    SKILLBLOCKER_NJ_MENU_ULTIMATE_TITLE                = "Blocage par points d'ultime",
    SKILLBLOCKER_NJ_MENU_DURATION_TITLE                = "Blocage par durée",
    SKILLBLOCKER_NJ_MENU_HP_TITLE                      = "Blocage par santé de la cible",
    SKILLBLOCKER_NJ_MENU_CRIMINAL_TITLE                = "Bloquer «Acte criminel»",

    SKILLBLOCKER_NJ_DELETE_FROM_SLOT                   = "Supprimer de l'emplacement",

    SI_BINDING_NAME_SKILLBLOCKER_NJ_UNLOCK_ALL         = "Débloquer toutes les compétences",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_1      = "Basculer verrou: Emplacement 1",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_2      = "Basculer verrou: Emplacement 2",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_3      = "Basculer verrou: Emplacement 3",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_4      = "Basculer verrou: Emplacement 4",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_5      = "Basculer verrou: Emplacement 5",
    SI_BINDING_NAME_SKILLBLOCKER_NJ_TOGGLE_SLOT_6      = "Basculer verrou: Ultime",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end