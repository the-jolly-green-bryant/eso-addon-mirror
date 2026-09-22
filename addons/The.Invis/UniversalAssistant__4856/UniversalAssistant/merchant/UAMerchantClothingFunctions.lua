local ua = UAssistant
local merchant = ua.Merchant

merchant.traitMaterialDefinitions = merchant.traitMaterialDefinitions or {}
merchant.traitMaterialDefinitions.clothing = {
    { itemId = 4456, traitType = ITEM_TRAIT_TYPE_ARMOR_STURDY },
    { itemId = 23219, traitType = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE },
    { itemId = 30221, traitType = ITEM_TRAIT_TYPE_ARMOR_REINFORCED },
    { itemId = 23221, traitType = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED },
    { itemId = 4442, traitType = ITEM_TRAIT_TYPE_ARMOR_TRAINING },
    { itemId = 30219, traitType = ITEM_TRAIT_TYPE_ARMOR_INFUSED },
    { itemId = 23171, traitType = ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS },
    { itemId = 23173, traitType = ITEM_TRAIT_TYPE_ARMOR_DIVINES },
    { itemId = 56862, traitType = ITEM_TRAIT_TYPE_ARMOR_NIRNHONED },
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
    for _, definition in ipairs(merchant.traitMaterialDefinitions.clothing) do
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
    for _, definition in ipairs(merchant.traitMaterialDefinitions.clothing) do
        if definition.itemId == itemId then
            return true
        end
    end
    return false
end

merchant.RegisterProfile("clothing", CreateDefaults, InitializeProfile)

local function IsClothing(itemLink)
    if GetItemLinkItemType(itemLink) ~= ITEMTYPE_ARMOR then
        return false
    end

    local armorType = GetItemLinkArmorType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)

    return equipType ~= EQUIP_TYPE_OFF_HAND
        and (
            armorType == ARMORTYPE_LIGHT
            or armorType == ARMORTYPE_MEDIUM
            or armorType == ARMORTYPE_HEAVY
        )
end

local protectedResearchSlots = {}

local function IsResearchableTrait(traitType)
    return traitType == ITEM_TRAIT_TYPE_ARMOR_STURDY
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
    return tostring(GetItemLinkEquipType(itemLink)) .. ":" .. tostring(traitType)
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
            and IsClothing(itemLink)
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

merchant.RegisterCategory("clothing", function(profile, bagId, slotIndex, itemLink)
    if IsSelectedTraitMaterial(profile, itemLink) then
        return true
    end

    return profile.enabled
        and IsClothing(itemLink)
        and merchant.PassesEquipmentFilters(profile, bagId, slotIndex, itemLink)
        and PassesResearchMode(profile, slotIndex, itemLink)
end, PrepareResearchProtection)
