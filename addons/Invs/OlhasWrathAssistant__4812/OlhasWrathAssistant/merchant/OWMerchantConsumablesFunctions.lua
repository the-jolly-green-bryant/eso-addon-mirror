local owa = OWAssistant
local merchant = owa.Merchant

local HOUSING_RECIPE_TYPES = {
    [SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] = true,
}

local STANDARD_RECIPE_TYPES = {
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK] = true,
    [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD] = true,
}

local function PassesQuality(
    profile,
    qualityField,
    bagId,
    slotIndex
)
    local quality = merchant.GetItemQuality(
        bagId,
        slotIndex
    )

    return quality ~= nil
        and quality <= profile[qualityField]
end

local function IsProtectedCP150(
    profile,
    excludeField,
    itemLink
)
    if not profile[excludeField] then
        return false
    end

    local championPoints =
        GetItemLinkRequiredChampionPoints(itemLink)

    return championPoints ~= nil
        and championPoints >= 150
end

local function PassesCraftedFilter(
    profile,
    nonCraftedField,
    itemLink
)
    return IsItemLinkCrafted(itemLink)
        or profile[nonCraftedField]
end

local function IsFoodOrDrink(itemType)
    return itemType == ITEMTYPE_FOOD
        or itemType == ITEMTYPE_DRINK
end

local function IsPotionOrPoison(itemType)
    return itemType == ITEMTYPE_POTION
        or itemType == ITEMTYPE_POISON
end

merchant.RegisterCategory(
    "consumables",
    function(profile, bagId, slotIndex, itemLink)
        if not profile.enabled then
            return false
        end

        local itemType, specializedItemType =
            GetItemLinkItemType(itemLink)

        if IsFoodOrDrink(itemType) then
            return profile.foodDrinkEnabled
                and PassesQuality(
                    profile,
                    "foodDrinkMaxQuality",
                    bagId,
                    slotIndex
                )
                and not IsProtectedCP150(
                    profile,
                    "excludeFoodDrinkCP150",
                    itemLink
                )
                and PassesCraftedFilter(
                    profile,
                    "nonCraftedFoodDrink",
                    itemLink
                )
        end

        if IsPotionOrPoison(itemType) then
            return profile.potionPoisonEnabled
                and not IsProtectedCP150(
                    profile,
                    "excludePotionPoisonCP150",
                    itemLink
                )
                and PassesCraftedFilter(
                    profile,
                    "nonCraftedPotionPoison",
                    itemLink
                )
        end

        if itemType ~= ITEMTYPE_RECIPE
            or not IsItemLinkRecipeKnown(itemLink)
        then
            return false
        end

        if STANDARD_RECIPE_TYPES[specializedItemType] then
            return profile.knownRecipesEnabled
                and PassesQuality(
                    profile,
                    "recipeMaxQuality",
                    bagId,
                    slotIndex
                )
        end

        if HOUSING_RECIPE_TYPES[specializedItemType] then
            return profile.knownHousingPatternsEnabled
                and PassesQuality(
                    profile,
                    "housingPatternMaxQuality",
                    bagId,
                    slotIndex
                )
        end

        return false
    end
)
