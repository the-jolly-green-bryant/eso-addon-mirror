local ua = UAssistant
local merchant = ua.Merchant

merchant.traitMaterialDefinitions = merchant.traitMaterialDefinitions or {}
merchant.traitMaterialDefinitions.jewelry = {
    { itemId = 135156, traitType = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY },
    { itemId = 135155, traitType = ITEM_TRAIT_TYPE_JEWELRY_ARCANE },
    { itemId = 135157, traitType = ITEM_TRAIT_TYPE_JEWELRY_ROBUST },
    { itemId = 139409, traitType = ITEM_TRAIT_TYPE_JEWELRY_TRIUNE },
    { itemId = 139413, traitType = ITEM_TRAIT_TYPE_JEWELRY_HARMONY },
    { itemId = 139412, traitType = ITEM_TRAIT_TYPE_JEWELRY_SWIFT },
    { itemId = 139411, traitType = ITEM_TRAIT_TYPE_JEWELRY_INFUSED },
    { itemId = 139410, traitType = ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE },
    { itemId = 139414, traitType = ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY },
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
        basic_traits = true,
        keep_lowest_unresearched = true,
    }

    if not validResearchModes[profile.researchMode] then
        profile.researchMode = "none"
    end

    if type(profile.traitMaterials) ~= "table" then
        profile.traitMaterials = {}
    end
    for _, definition in ipairs(merchant.traitMaterialDefinitions.jewelry) do
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
    for _, definition in ipairs(merchant.traitMaterialDefinitions.jewelry) do
        if definition.itemId == itemId then
            return true
        end
    end
    return false
end

merchant.RegisterProfile("jewelry", CreateDefaults, InitializeProfile)

local function IsJewelry(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)

    return equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK
end

local protectedResearchSlots = {}

local function IsBasicTrait(traitType)
    return traitType == ITEM_TRAIT_TYPE_JEWELRY_ROBUST
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_ARCANE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_HEALTHY
end

local function IsResearchableTrait(traitType)
    return IsBasicTrait(traitType)
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_TRIUNE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_INFUSED
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_SWIFT
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_HARMONY
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY
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
            and IsJewelry(itemLink)
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

    if profile.researchMode == "basic_traits" then
        return IsBasicTrait(traitType)
    end

    if profile.researchMode == "keep_lowest_unresearched" then
        return not protectedResearchSlots[slotIndex]
    end

    return false
end

merchant.RegisterCategory("jewelry", function(profile, bagId, slotIndex, itemLink)
    if IsSelectedTraitMaterial(profile, itemLink) then
        return true
    end

    return profile.enabled
        and IsJewelry(itemLink)
        and merchant.PassesEquipmentFilters(profile, bagId, slotIndex, itemLink)
        and PassesResearchMode(profile, slotIndex, itemLink)
end, PrepareResearchProtection)
