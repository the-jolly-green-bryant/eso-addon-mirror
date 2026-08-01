-- Déclaration globale de la table MyAddOn avant toute utilisation
MyAddOn = {
    Active = false
}

local ADDON_NAME = "Iconoxe"
local MY_TEXTURES = {
    "Iconoxe/OSI/MainTank.dds",
    "Iconoxe/OSI/OffTank.dds",
}

-- Enregistrement de l'événement ADD_ON_LOADED
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= ADDON_NAME then return end
    
    -- Désenregistrement de l'événement après chargement
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    
    -- Marquer l'addon comme chargé
    MyAddOn.Active = true
    
    -- Vérification et ajout des icônes personnalisées
    if OSI and OSI.AddCustomIconPack then
        OSI.AddCustomIconPack(MY_TEXTURES)
    end
end)

-- Commande slash pour vérifier le statut de l'addon
SLASH_COMMANDS["/is_my_AddOn_loaded"] = function()
    if MyAddOn.Active then
        d("Iconoxe AddOn is loaded and active")
    else
        d("Iconoxe AddOn is NOT loaded or inactive")
    end
end