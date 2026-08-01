------------------------------------------------
-- French localization for IsJustaDeconCarriedList
------------------------------------------------
-- Courtesy of fzr6n7
local strings = {
    SI_IJADECON_CARRIED = "Transportés",
    
    SI_IJADECON_USE_CLEAN_REFINMENT_TAB = "Onglet de raffinage optimisée",
    SI_IJADECON_USE_CLEAN_REFINMENT_TOOLTIP = "Activé: affiche uniquement les matériaux prêts à être raffinés (10 ou plus) dans l'onglet de raffinage",
    SI_IJADECON_AUTOADD = "Tout Ajouter",
    SI_IJADECON_AUTOADD_HEADER = "Inclure dans \"Tout Ajouter\".",
    SI_IJADECON_AUTOADD_TOOLTIP = "Activé: Inclure <<1>> dans \"Tout Ajouter\".",
    SI_IJADECON_OPEN_TO_DECON_TAB = "Ouvrir sur Démontage",
    SI_IJADECON_OPEN_TO_DECON_TAB_TOOLTIP = "Activé: Ouvre automatiquement sur l'onglet Démontage sur les station de craft. \n\nUtiliser avec précautions.",
    SI_IJADECON_USE_ADDALL_FOR_OTHERS= "Utiliser \"Tout Ajouter\" pour les autres",
    SI_IJADECON_USE_ADDALL_FOR_OTHERS_TOOLTIP = "Activé: active le bouton  \"Tout Ajouter\" pour ".. GetString(SI_SMITHINGFILTERTYPE2) .. " / " .. GetString(SI_SMITHINGFILTERTYPE4) .. " / " .. GetString(SI_SMITHINGFILTERTYPE6) .. ".",
}
 
-- Dynamically create variable to allow changes by ZOS
IJA_SMITHING_FILTER_TYPE_CARRIED = SMITHING_FILTER_TYPE_MAX_VALUE + 1
-- Appending variable to sting id for use as GetString("SI_SMITHINGFILTERTYPE_EXTRACTNONE", filterType)
strings["SI_SMITHINGFILTERTYPE_EXTRACTNONE" .. IJA_SMITHING_FILTER_TYPE_CARRIED] = "Pas d'item à déconstruire dans l'inventaire."
 
for stringId, stringValue in pairs(strings) do
    SafeAddString(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end