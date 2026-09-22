local ua = UAssistant
local merchant = ua.Merchant

merchant.traitMaterialDefinitions = merchant.traitMaterialDefinitions or {}
merchant.traitMaterialDefinitions.weapon = {
    { itemId = 23203, traitType = ITEM_TRAIT_TYPE_WEAPON_POWERED },
    { itemId = 23204, traitType = ITEM_TRAIT_TYPE_WEAPON_CHARGED },
    { itemId = 4486, traitType = ITEM_TRAIT_TYPE_WEAPON_PRECISE },
    { itemId = 810, traitType = ITEM_TRAIT_TYPE_WEAPON_INFUSED },
    { itemId = 813, traitType = ITEM_TRAIT_TYPE_WEAPON_DEFENDING },
    { itemId = 23165, traitType = ITEM_TRAIT_TYPE_WEAPON_TRAINING },
    { itemId = 23149, traitType = ITEM_TRAIT_TYPE_WEAPON_SHARPENED },
    { itemId = 16291, traitType = ITEM_TRAIT_TYPE_WEAPON_DECISIVE },
    { itemId = 56863, traitType = ITEM_TRAIT_TYPE_WEAPON_NIRNHONED },
}

local function CreateDefaults()
    return {
        enabled = false,
        maxQuality = ITEM_QUALITY_NORMAL,
        noTrait = false,
        ornate = false,
        intricate = false,
        tradable = false,
        researchMode = "none",
        traitMaterialsEnabled = false,
        traitMaterials = {},
    }
end

local function InitializeProfile(profile)
    local validResearchModes = {
        none = true,
        all = true,
        keep_lowest_unresearched = true,
    }

    if not validResearchModes[profile.researchMode] then
        profile.researchMode = "none"
    end

    if type(profile.traitMaterials) ~= "table" then
        profile.traitMaterials = {}
    end
    for _, definition in ipairs(merchant.traitMaterialDefinitions.weapon) do
        if profile.traitMaterials[definition.itemId] == nil then
            profile.traitMaterials[definition.itemId] = false
        end
    end
end

local function IsSelectedTraitMaterial(profile, itemLink)
    if not profile.traitMaterialsEnabled or type(profile.traitMaterials) ~= "table" then
        return false
    end
    local itemId = GetItemLinkItemId(itemLink)
    if profile.traitMaterials[itemId] ~= true then
        return false
    end
    for _, definition in ipairs(merchant.traitMaterialDefinitions.weapon) do
        if definition.itemId == itemId then
            return true
        end
    end
    return false
end

merchant.RegisterProfile("weapon", CreateDefaults, InitializeProfile)

local function IsShield(itemLink)
    return GetItemLinkItemType(itemLink) == ITEMTYPE_ARMOR
        and GetItemLinkEquipType(itemLink) == EQUIP_TYPE_OFF_HAND
end

local function IsWeaponOrShield(itemLink)
    return GetItemLinkItemType(itemLink) == ITEMTYPE_WEAPON or IsShield(itemLink)
end

local protectedResearchSlots = {}

local function IsResearchableTrait(traitType)
    return traitType == ITEM_TRAIT_TYPE_WEAPON_POWERED
        or traitType == ITEM_TRAIT_TYPE_WEAPON_CHARGED
        or traitType == ITEM_TRAIT_TYPE_WEAPON_PRECISE
        or traitType == ITEM_TRAIT_TYPE_WEAPON_INFUSED
        or traitType == ITEM_TRAIT_TYPE_WEAPON_DEFENDING
        or traitType == ITEM_TRAIT_TYPE_WEAPON_TRAINING
        or traitType == ITEM_TRAIT_TYPE_WEAPON_SHARPENED
        or traitType == ITEM_TRAIT_TYPE_WEAPON_DECISIVE
        or traitType == ITEM_TRAIT_TYPE_WEAPON_NIRNHONED
        or traitType == ITEM_TRAIT_TYPE_ARMOR_STURDY
        or traitType == ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE
        or traitType == ITEM_TRAIT_TYPE_ARMOR_REINFORCED
        or traitType == ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED
        or traitType == ITEM_TRAIT_TYPE_ARMOR_TRAINING
        or traitType == ITEM_TRAIT_TYPE_ARMOR_INFUSED
        or traitType == ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS
        or traitType == ITEM_TRAIT_TYPE_ARMOR_DIVINES
        or traitType == ITEM_TRAIT_TYPE_ARMOR_NIRNHONED
end

local function GetResearchKey(itemLink, traitType)
    local itemType = IsShield(itemLink) and "shield" or GetItemLinkWeaponType(itemLink)

    return tostring(itemType) .. ":" .. tostring(traitType)
end

local function PrepareResearchProtection(profile)
    protectedResearchSlots = {}

    if not profile.enabled or profile.researchMode ~= "keep_lowest_unresearched" then
        return
    end

    local lowestByTrait = {}
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local safe, itemLink = merchant.IsSafeToSell(BAG_BACKPACK, slotIndex)

        if
            safe
            and IsWeaponOrShield(itemLink)
            and merchant.PassesEquipmentFilters(profile, BAG_BACKPACK, slotIndex, itemLink)
            and CanItemLinkBeTraitResearched(itemLink)
        then
            local traitType = GetItemLinkTraitType(itemLink)

            if IsResearchableTrait(traitType) then
                local key = GetResearchKey(itemLink, traitType)
                local quality = merchant.GetItemQuality(BAG_BACKPACK, slotIndex)
                local current = lowestByTrait[key]

                if not current or quality < current.quality then
                    lowestByTrait[key] = {
                        slotIndex = slotIndex,
                        quality = quality,
                    }
                end
            end
        end
    end

    for _, candidate in pairs(lowestByTrait) do
        protectedResearchSlots[candidate.slotIndex] = true
    end
end

local function PassesResearchMode(profile, slotIndex, itemLink)
    local traitType = GetItemLinkTraitType(itemLink)

    if not IsResearchableTrait(traitType) then
        return true
    end

    if profile.researchMode == "all" then
        return true
    end

    if profile.researchMode == "keep_lowest_unresearched" then
        return not protectedResearchSlots[slotIndex]
    end

    return false
end

merchant.RegisterCategory("weapon", function(profile, bagId, slotIndex, itemLink)
    if IsSelectedTraitMaterial(profile, itemLink) then
        return true
    end

    return profile.enabled
        and IsWeaponOrShield(itemLink)
        and merchant.PassesEquipmentFilters(profile, bagId, slotIndex, itemLink)
        and PassesResearchMode(profile, slotIndex, itemLink)
end, PrepareResearchProtection)
