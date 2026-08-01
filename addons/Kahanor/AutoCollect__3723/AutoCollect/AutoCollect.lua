-- Fonction pour lier un objet s'il n'est pas déjà lié
local function AutoCollectItem(bagId, slotIndex)
    local isBound = IsItemBound(bagId, slotIndex)
    local itemType = GetItemType(bagId, slotIndex) -- Obtenez le type de l'objet
    
    -- Vérifiez si l'objet n'est pas déjà lié et s'il s'agit d'un équipement
    if not isBound and itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
        local itemName = GetItemName(bagId, slotIndex)
        
        -- Liez automatiquement l'objet
        BindItem(bagId, slotIndex)
        
    end
end

-- Enregistrez l'événement de chargement de l'interface utilisateur
EVENT_MANAGER:RegisterForEvent("AutoCollect_OnLoad", EVENT_ADD_ON_LOADED,
    function(eventCode, addOnName)
        -- Vérifiez si c'est votre addon qui est chargé
        if addOnName == "AutoCollect" then

            -- Configurez les gestionnaires d'événements avec le filtre REGISTER_FILTER_IS_NEW_ITEM
            EVENT_MANAGER:AddFilterForEvent("AutoCollect_OnItemAddedToInventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM)

            -- Enregistrez l'événement de ramassage d'objet
            EVENT_MANAGER:RegisterForEvent("AutoCollect_OnItemAddedToInventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
               function(eventCode, bagId, slotIndex, itemSoundCategory, updateReason)
                   AutoCollectItem(bagId, slotIndex)
               end)

            -- Désenregistrez l'événement de chargement une fois que tout est configuré
            EVENT_MANAGER:UnregisterForEvent("AutoCollect_OnLoad", EVENT_ADD_ON_LOADED)
        end
    end)