------------------------------------------------
-- French localization
------------------------------------------------
-- Courtesy of fzr6n7
local strings = {
    SI_IJA_DIWM_Title               = "|cFF00FFIsJusta|r |cffffffDésactivation des interactions lors des déplacements|r",
 
    SI_IJA_DIWM_DISABLEINTERACT     = "Interaction avec les compagnons",
    SI_IJA_DIWM_DISABLEINTERACT_TIP = "Désactive les interactions avec les compagnons lorsque le joueur se déplace.",
 
    SI_IJA_DIWM_DISABLEMORE         = "Autres interactions",
    SI_IJA_DIWM_DISABLEMORE_TIP     = "Désactiver les autres interactions lorsque le joueur se déplace.",
    SI_IJA_DIWM_DISABLEMORE_HEADER  = "Sélection des autres interactions à désactiver",
    
    SI_IJA_DIWM_OPTIONAL            = "Fonctionnalités optionnelles",
    
    SI_IJA_DIWM_OPTIONAL1           = "Active le visuel sur le réticule",
    SI_IJA_DIWM_OPTIONAL_TIP1       = "Activé: le reticule devient rouge lorsqu'une interaction est bloquée.",
 
    SI_IJA_DIWM_OPTIONAL2           = "Désactiver quand accroupi",
    SI_IJA_DIWM_OPTIONAL_TIP2       = "Activé: désactive le blocage des interactions lorsque le joueur est accroupi.",
    
    SI_IJA_DIWM_OPTIONAL3           = "Désactiver dans les Donjons/Epreuves",
    SI_IJA_DIWM_OPTIONAL_TIP3       = "Activé: désactive le blocage des interactions dans les Donjons/Epreuves",
    
    SI_IJA_DIWM_OPTIONAL4           = "Désactiver en zones PVP (JCJ)",
    SI_IJA_DIWM_OPTIONAL_TIP4       = "Activé: désactive le blocage des interactions dans les zones PVP (JCJ).",
	
	SI_IJA_DIWM_OPTIONAL5			= "Masquer les interactions lors du temps de recharge",
	SI_IJA_DIWM_OPTIONAL_TIP5		= "Activé: masquera complètement l'invite d'interaction.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(_G[stringId], 1)
end
