------------------------------------------------
-- French localization
------------------------------------------------
-- Courtesy of fzr6n7
local strings = {
    SI_IJA_MCF_Title                    = "|cFF00FFIsJusta|r |cffffffAméliorations des UI de compagnons|r",
    
    SI_IJA_MCF_ACCOUNT                  = "Propager au compte",
    SI_IJA_MCF_ACCOUNT_TOOLTIP          = "Activer pour utiliser ces paramètres sur tous les personnages du compte. Désactiver sauvegarde les réglages par personnage",
 
    SI_IJA_MCF_RAPPORTPROGRESS          = "Progression du rapport",
    SI_IJA_MCF_RAPPORTPERCENT           = "<<1>>/<<2>> (<<3>>%)",
 
-- PRI
    SI_IJA_MCF_INDICATOR_HEADER         = "Indicateur de compagnon",
    SI_IJA_MCF_INDICATOR_HEADER_TOOLTIP = "Requiert le mod: Player Role Indicator.",
    SI_IJA_MCF_INDICATOR                = "Indicateur",
    SI_IJA_MCF_INDICATOR_TOOLTIP        = "Activé: Affiche un icone au dessus du compagnon. \n\nAjuster son apparence dans les options du mod: Player Role Indicator.",
 
    SI_IJA_MCF_HIDECOMBAT               = "Icone de combat",
    SI_IJA_MCF_HIDECOMBAT_TOOLTIP       = "Activé: Affiche un icone au dessus du compagnon uniquement en combat.",
 
    SI_IJA_MCF_UPDATEDELAY              = "Délai de rafraichissement",
    SI_IJA_MCF_UPDATEDELAY_TOOLTIP      = "Ajuste le temps, en millisecondes, du rafraichissement de l'indicateur.\n\nCela affecte aussi tous les icones de groupe du mod Player Role Indicator.",
 
-- frames
    SI_IJA_MCF_FRAME_HEADER             = "Utiliser le cadre personalisé",
    SI_IJA_MCF_ZOS_HEADER               = "Réglages pour le cadre de compagnon",
    SI_IJA_MCF_BUI_HEADER               = "Réglages pour le style BUI",
 
    SI_IJA_MCF_FRAME                    = "Activé",
    SI_IJA_MCF_FRAME_TOOLTIP            = "Activé: Permet l'utilisation du cadre personalisé ou du cadre du mod Bandit UI.",
 
    SI_IJA_MCF_GRADEINT_HEALTH_LEFT     = "Dégradé de la barre de vie, Gauche",
    SI_IJA_MCF_GRADEINT_HEALTH_RIGHT    = "Dégradé de la barre de vie, Droite",
    SI_IJA_MCF_GRADEINT_HEALTH_RESET    = "Réinitialiser le dégradé",
    
    SI_IJA_MCF_GRADEINT_SHEILD_LEFT     = "Dégradé de la barre de bouclier, Gauche",
    SI_IJA_MCF_GRADEINT_SHEILD_RIGHT    = "Dégradé de la barre de bouclier, Droite",
    SI_IJA_MCF_GRADEINT_SHEILD_RESET    = "Réinitialiser le dégradé",
 
    SI_IJA_MCF_SHOWLEVEL                = "Afficher le niveau",
    SI_IJA_MCF_SHOWLEVEL_TOOLTIP        = "Activé: Affiche le niveau du compagnon avant son nom.",
 
    SI_IJA_MCF_GROUPFRAME               = "Utiliser le cadre de groupe",
    SI_IJA_MCF_GROUPFRAME_TOOLTIP       = "Activé: Dans un groupe, ajoute le compagnon à la liste du groupe et cache le cadre de compagnon.",
 
    SI_IJA_MCF_HIDEBARBG                = "Cache les bords de la barre de vie",
    SI_IJA_MCF_HIDEBARBG_TOOLTIP        = "Activé: les bords de la barre de vie sont cachés.",
 
    SI_IJA_MCF_FRAMESTYLE               = "Style du cadre",
    SI_IJA_MCF_FRAMESTYLE_TOOLTIP       = "",
    
    SI_IJA_MCF_HEALTHSTYLE              = "Style des chiffres de la barre de vie",
    SI_IJA_MCF_HEALTHSTYLE_TOOLTIP      = "",
    SI_IJA_MCF_HEALTHFORMAT             = "Format des chiffres de la barre de vie",
 
    SI_IJA_MCF_LOCK                     = "<<1>> Verrouillage",
    SI_IJA_MCF_LOCK_TOOLTIP             = "Verrouille le cadre pour ne pas pouvoir le bouger.",
 
    SI_IJA_MCF_OCCUPANCY                = "Transparence",
    SI_IJA_MCF_OCCUPANCY_TOOLTIP        = "Règle la transparence du fond du cadre.",
 
    SI_IJA_MCF_SCALE                    = "Echelle",
    SI_IJA_MCF_SCALE_TOOLTIP            = "Règle la taille du cadre.",
 
    SI_IJA_MCF_BUI                      = "Utiliser le cadre BUI",
    SI_IJA_MCF_BUI_TOOLTIP              = "Utilise le cadre de groupe et les réglages du mod Bandit UI.",
    
    SI_IJA_MCF_BUI_USEFANCY             = "Utiliser le cadre Fantasie",
    SI_IJA_MCF_BUI_USEFANCY_TOOLTIP     = "Utilise la barre de vie brillante pour le cadre Bandit UI.",
    
    SI_IJA_MCF_COMPANIONFRAME_RESET     = "Réinitialiser la position",
    SI_IJA_MCF_COMPANIONFRAME_RESET_TOOLTIP = "Réinitialise la position du cadre de compagnon.",
}
 
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
