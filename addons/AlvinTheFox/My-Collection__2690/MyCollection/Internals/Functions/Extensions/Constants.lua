local Extensions = MyCollection.Internals.Functions.Extensions
local Constants = MyCollection.Internals.Constants

Extensions.Constants = {}

Extensions.Constants.IsEquipment = function (equipType)    
    return 
        Extensions.Constants.IsArmor(equipType) or
        Extensions.Constants.IsJewellery(equipType) or
        Extensions.Constants.IsWeaponOrShield(equipType)
end

Extensions.Constants.IsArmor = function (equipType)
    for key, id in pairs(Constants.EquipTypes.Armors) do
        if (id == equipType) then
            return true
        end
    end
    return false
end

Extensions.Constants.GetEquipTypeOfWeapon = function (weaponType)
    if weaponType == Constants.WeaponTypes.Axe then                 return Constants.EquipTypes.Weapons.OneHand end
    if weaponType == Constants.WeaponTypes.Hammer then              return Constants.EquipTypes.Weapons.OneHand end
    if weaponType == Constants.WeaponTypes.Sword then               return Constants.EquipTypes.Weapons.OneHand end
    if weaponType == Constants.WeaponTypes.TwoHandedSword then      return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.TwoHandedAxe then        return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.TwoHandedHammer then     return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.Bow then                 return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.HealingStaff then        return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.Dagger then              return Constants.EquipTypes.Weapons.OneHand end
    if weaponType == Constants.WeaponTypes.FireStaff then           return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.FrostStaff then          return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.LightningStaff then      return Constants.EquipTypes.Weapons.TwoHand end
    if weaponType == Constants.WeaponTypes.Shield then              return Constants.EquipTypes.Weapons.OffHand end
end

Extensions.Constants.IsWeaponOrShield = function (equipType)
    for key, id in pairs(Constants.EquipTypes.Weapons) do
        if (id == equipType) then
            return true
        end
    end
    return false
end

Extensions.Constants.IsJewellery = function (equipType)
    for key, id in pairs(Constants.EquipTypes.Jewelleries) do
        if (id == equipType) then
            return true
        end
    end
    return false
end

Extensions.Constants.IsCharacterBag = function (bagId)
    if 
        bagId == Constants.BagTypes.Worn
        or bagId == Constants.BagTypes.Backpack
        --or bagId == Constants.BagTypes.BuyBack 
    then
        return true
    end
    return false
end

Extensions.Constants.IsBank = function (bagId)
    if 
        bagId == Constants.BagTypes.Bank or
        bagId == Constants.BagTypes.SubscriberBank 
    then
        return true
    end
    return false
end

Extensions.Constants.GetTraitName = function (traitId)
    if traitId == 0 or traitId == nil then
        return GetString(MYCOLLECTION_TRAIT_NONE)
    else
        for key, trait in pairs(Constants.TraitTypes.Armor) do
            if (traitId == trait) then
                local traitTextId = _G["MYCOLLECTION_TRAIT_ARMOR_" .. key:upper()]
                return GetString(traitTextId)
            end
        end 
        for key, trait in pairs(Constants.TraitTypes.Jewelleries) do
            if (traitId == trait) then
                local traitTextId = _G["MYCOLLECTION_TRAIT_JEWELLERY_" .. key:upper()]
                return GetString(traitTextId)
            end
        end 
        for key, trait in pairs(Constants.TraitTypes.Weapons) do
            if (traitId == trait) then
                local traitTextId = _G["MYCOLLECTION_TRAIT_WEAPON_" .. key:upper()]
                return GetString(traitTextId)
            end
        end 
    end
end