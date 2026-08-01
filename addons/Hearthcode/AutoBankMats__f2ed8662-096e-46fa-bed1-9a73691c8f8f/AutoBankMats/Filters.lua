AutoBank_Filters = {}

function AutoBank_Filters:ShouldDeposit(bagId, slotIndex, core)
    if IsItemBound(bagId, slotIndex) then return false end

    local itemType = GetItemType(bagId, slotIndex)

    -- If not using custom selection, auto-bank all crafting-related materials
    if not core.savedVars.useCustomSelection then
        return itemType == ITEMTYPE_STYLE_MATERIAL or
               itemType == ITEMTYPE_REAGENT or
               itemType == ITEMTYPE_POISON_BASE or
               itemType == ITEMTYPE_POTION_BASE or
               itemType == ITEMTYPE_INGREDIENT or
               itemType == ITEMTYPE_SPICE or
               itemType == ITEMTYPE_FLAVORING or
               itemType == ITEMTYPE_ADDITIVE or
               itemType == ITEMTYPE_FURNISHING_MATERIAL or
               itemType == ITEMTYPE_ARMOR_TRAIT or
               itemType == ITEMTYPE_ARMOR_BOOSTER or
               itemType == ITEMTYPE_WEAPON_TRAIT or
               itemType == ITEMTYPE_WEAPON_BOOSTER or
               itemType == ITEMTYPE_JEWELRY_TRAIT or
               itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
               itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or
               itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or
               itemType == ITEMTYPE_ENCHANTMENT_BOOSTER or
               itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or
               itemType == ITEMTYPE_WOODWORKING_BOOSTER or
               itemType == ITEMTYPE_WOODWORKING_MATERIAL or
               itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
               itemType == ITEMTYPE_CLOTHIER_BOOSTER or
               itemType == ITEMTYPE_CLOTHIER_MATERIAL or
               itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
               itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or
               itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or
               itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or
               itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or
               itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or
               itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or
               itemType == ITEMTYPE_JEWELRY_BOOSTER or 
               itemType == ITEMTYPE_JEWELRY_RAW_TRAIT
    end

    -- Using custom selection - check individual material settings
    local materials = core.savedVars.materials

    -- Style Materials
    if materials.styleMaterials and itemType == ITEMTYPE_STYLE_MATERIAL then
        return true
    end

    -- Alchemy Materials
    if materials.alchemyMaterials and (itemType == ITEMTYPE_REAGENT or 
                                      itemType == ITEMTYPE_POISON_BASE or 
                                      itemType == ITEMTYPE_POTION_BASE) then
        return true
    end

    -- Provisioning Materials  
    if materials.provisioningMaterials and (itemType == ITEMTYPE_INGREDIENT or
                                           itemType == ITEMTYPE_SPICE or
                                           itemType == ITEMTYPE_FLAVORING or
                                           itemType == ITEMTYPE_ADDITIVE) then
        return true
    end

    -- Furnishing Materials
    if materials.furnishingMaterials and itemType == ITEMTYPE_FURNISHING_MATERIAL then
        return true
    end

    -- Trait Materials
    if materials.traitMaterials and (itemType == ITEMTYPE_ARMOR_TRAIT or 
                                    itemType == ITEMTYPE_WEAPON_TRAIT or
                                    itemType == ITEMTYPE_JEWELRY_RAW_TRAIT or
                                    itemType == ITEMTYPE_JEWELRY_TRAIT) then
        return true
    end

    -- Enchantment Materials
    if materials.enchantmentMaterials and (itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
                                          itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or
                                          itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or
                                          itemType == ITEMTYPE_ENCHANTMENT_BOOSTER) then
        return true
    end

    -- Woodworking Materials
    if materials.woodworkingMaterials and (itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or
                                          itemType == ITEMTYPE_WOODWORKING_MATERIAL or
                                          itemType == ITEMTYPE_WEAPON_BOOSTER or
                                          itemType == ITEMTYPE_WOODWORKING_BOOSTER) then
        return true
    end
    
    -- Clothing Materials  
    if materials.clothingMaterials and (itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
                                       itemType == ITEMTYPE_CLOTHIER_MATERIAL or
                                       itemType == ITEMTYPE_CLOTHIER_BOOSTER) then
        return true
    end
    
    -- Blacksmithing Materials
    if materials.blacksmithingMaterials and (itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
                                             itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or
                                             itemType == ITEMTYPE_ARMOR_BOOSTER or
                                             itemType == ITEMTYPE_BLACKSMITHING_BOOSTER) then
        return true
    end
    
    -- Jewelry Materials
    if materials.jewelryMaterials and (itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or
                                      itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or
                                      itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or
                                      itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER or
                                      itemType == ITEMTYPE_JEWELRY_BOOSTER) then
        return true
    end

    return false
end
