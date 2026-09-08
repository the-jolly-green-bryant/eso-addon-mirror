local owa = OWAssistant
owa.Merchant = owa.Merchant or {}
local merchant = owa.Merchant

local EVENT_NAMESPACE = "OWMerchant"
local SALE_DELAY_MS = 50

merchant.categoryMatchers = {}
merchant.categoryOrder = {}
merchant.saleQueue = {}
merchant.saleGeneration = 0
merchant.storeOpen = false
merchant.pendingSale = nil
merchant.soldQuantity = 0
merchant.soldMoney = 0
merchant.saleFinished = true

merchant.traitMaterialDefinitions = {
    weapon = {
        { itemId = 23203, name = "Chysolite", trait = "Powered" },
        { itemId = 23204, name = "Amethyst", trait = "Charged" },
        { itemId = 4486, name = "Ruby", trait = "Precise" },
        { itemId = 810, name = "Jade", trait = "Infused" },
        { itemId = 813, name = "Turquoise", trait = "Defending" },
        { itemId = 23165, name = "Carnelian", trait = "Training" },
        { itemId = 23149, name = "Fire Opal", trait = "Sharpened" },
        { itemId = 16291, name = "Citrine", trait = "Decisive" },
        { itemId = 56863, name = "Potent Nirncrux", trait = "Nirnhoned" },
    },
    clothing = {
        { itemId = 4456, name = "Quartz", trait = "Sturdy" },
        { itemId = 23219, name = "Diamond", trait = "Impenetrable" },
        { itemId = 30221, name = "Sardonyx", trait = "Reinforced" },
        { itemId = 23221, name = "Almandine", trait = "Well-fitted" },
        { itemId = 4442, name = "Emerald", trait = "Training" },
        { itemId = 30219, name = "Bloodstone", trait = "Infused" },
        { itemId = 23171, name = "Garnet", trait = "Prosperous" },
        { itemId = 23173, name = "Sapphire", trait = "Divines" },
        { itemId = 56862, name = "Fortified Nirncrux", trait = "Nirnhoned" },
    },
    jewelry = {
        { itemId = 135156, name = "Antimony", trait = "Healthy" },
        { itemId = 135155, name = "Cobalt", trait = "Arcane" },
        { itemId = 135157, name = "Zinc", trait = "Robust" },
        { itemId = 139409, name = "Dawn-Prism", trait = "Triune" },
        { itemId = 139413, name = "Dibellium", trait = "Harmony" },
        { itemId = 139412, name = "Gilding Wax", trait = "Swift" },
        { itemId = 139411, name = "Aurbic Amber", trait = "Infused" },
        { itemId = 139410, name = "Titanium", trait = "Protective" },
        { itemId = 139414, name = "Slaughterstone", trait = "Bloodthirsty" },
    },
}

merchant.enchantingRuneDefinitions = {
    potency = {
        { itemId = 45855, name = "Jora", level = "1-10", polarity = "ADDITIVE" },
        { itemId = 45817, name = "Jode", level = "1-10", polarity = "SUBTRACTIVE" },
        { itemId = 45856, name = "Porade", level = "5-15", polarity = "ADDITIVE" },
        { itemId = 45818, name = "Notade", level = "5-15", polarity = "SUBTRACTIVE" },
        { itemId = 45857, name = "Jera", level = "10-20", polarity = "ADDITIVE" },
        { itemId = 45819, name = "Ode", level = "10-20", polarity = "SUBTRACTIVE" },
        { itemId = 45806, name = "Jejora", level = "15-25", polarity = "ADDITIVE" },
        { itemId = 45820, name = "Tade", level = "15-25", polarity = "SUBTRACTIVE" },
        { itemId = 45807, name = "Odra", level = "20-30", polarity = "ADDITIVE" },
        { itemId = 45821, name = "Jayde", level = "20-30", polarity = "SUBTRACTIVE" },
        { itemId = 45808, name = "Pojora", level = "25-35", polarity = "ADDITIVE" },
        { itemId = 45822, name = "Edode", level = "25-35", polarity = "SUBTRACTIVE" },
        { itemId = 45809, name = "Edora", level = "30-40", polarity = "ADDITIVE" },
        { itemId = 45823, name = "Pojode", level = "30-40", polarity = "SUBTRACTIVE" },
        { itemId = 45810, name = "Jaera", level = "35-45", polarity = "ADDITIVE" },
        { itemId = 45824, name = "Rekude", level = "35-45", polarity = "SUBTRACTIVE" },
        { itemId = 45811, name = "Pora", level = "40-50", polarity = "ADDITIVE" },
        { itemId = 45825, name = "Hade", level = "40-50", polarity = "SUBTRACTIVE" },
        { itemId = 45812, name = "Denara", level = "CP 10", polarity = "ADDITIVE" },
        { itemId = 45826, name = "Idode", level = "CP 10", polarity = "SUBTRACTIVE" },
        { itemId = 45813, name = "Rera", level = "CP 30", polarity = "ADDITIVE" },
        { itemId = 45827, name = "Pode", level = "CP 30", polarity = "SUBTRACTIVE" },
        { itemId = 45814, name = "Derado", level = "CP 50", polarity = "ADDITIVE" },
        { itemId = 45828, name = "Kedeko", level = "CP 50", polarity = "SUBTRACTIVE" },
        { itemId = 45815, name = "Rekura", level = "CP 70", polarity = "ADDITIVE" },
        { itemId = 45829, name = "Rede", level = "CP 70", polarity = "SUBTRACTIVE" },
        { itemId = 45816, name = "Kura", level = "CP 100", polarity = "ADDITIVE" },
        { itemId = 45830, name = "Kude", level = "CP 100", polarity = "SUBTRACTIVE" },
        { itemId = 64509, name = "Rejera", level = "CP 150", polarity = "ADDITIVE" },
        { itemId = 64508, name = "Jehade", level = "CP 150", polarity = "SUBTRACTIVE" },
        { itemId = 68341, name = "Repora", level = "CP 160", polarity = "ADDITIVE" },
        { itemId = 68340, name = "Itade", level = "CP 160", polarity = "SUBTRACTIVE" },
    },
    essence = {
        { itemId = 45839, name = "Dekeipa", effectKey = "RUNE_EFFECT_FROST" },
        { itemId = 45833, name = "Deni", effectKey = "RUNE_EFFECT_STAMINA" },
        { itemId = 45836, name = "Denima", effectKey = "RUNE_EFFECT_STAMINA_RECOVERY" },
        { itemId = 45842, name = "Deteri", effectKey = "RUNE_EFFECT_ARMOR" },
        { itemId = 45841, name = "Haoko", effectKey = "RUNE_EFFECT_DISEASE" },
        { itemId = 68342, name = "Hakeijo", effectKey = "RUNE_EFFECT_PRISMATIC_DEFENSE" },
        { itemId = 166045, name = "Indeko", effectKey = "RUNE_EFFECT_PRISMATIC_RECOVERY" },
        { itemId = 45849, name = "Kaderi", effectKey = "RUNE_EFFECT_SHIELD" },
        { itemId = 45837, name = "Kuoko", effectKey = "RUNE_EFFECT_POISON" },
        { itemId = 45848, name = "Makderi", effectKey = "RUNE_EFFECT_SPELL_HARM" },
        { itemId = 45832, name = "Makko", effectKey = "RUNE_EFFECT_MAGICKA" },
        { itemId = 45835, name = "Makkoma", effectKey = "RUNE_EFFECT_MAGICKA_RECOVERY" },
        { itemId = 45840, name = "Meip", effectKey = "RUNE_EFFECT_SHOCK" },
        { itemId = 45831, name = "Oko", effectKey = "RUNE_EFFECT_HEALTH" },
        { itemId = 45834, name = "Okoma", effectKey = "RUNE_EFFECT_HEALTH_RECOVERY" },
        { itemId = 45843, name = "Okori", effectKey = "RUNE_EFFECT_POWER" },
        { itemId = 45846, name = "Oru", effectKey = "RUNE_EFFECT_ALCHEMIST" },
        { itemId = 45838, name = "Rakeipa", effectKey = "RUNE_EFFECT_FLAME" },
        { itemId = 45847, name = "Taderi", effectKey = "RUNE_EFFECT_PHYSICAL_HARM" },
    },
    aspect = {
        { itemId = 45850, name = "Ta", qualityKey = "QUALITY_NORMAL" },
        { itemId = 45851, name = "Jejota", qualityKey = "QUALITY_FINE" },
        { itemId = 45852, name = "Denata", qualityKey = "QUALITY_SUPERIOR" },
        { itemId = 45853, name = "Rekuta", qualityKey = "QUALITY_EPIC" },
        { itemId = 45854, name = "Kuta", qualityKey = "QUALITY_LEGENDARY" },
    },
}

merchant.enchantingRuneGroupsByItemId = {}

for groupName, definitions in pairs(
    merchant.enchantingRuneDefinitions
) do
    for _, definition in ipairs(definitions) do
        merchant.enchantingRuneGroupsByItemId[
            definition.itemId
        ] = groupName
    end
end

merchant.resourceIngredientDefinitions = {
    provisioning = {

        { itemId = 64222, quality = ITEM_QUALITY_LEGENDARY },
        { itemId = 120894, quality = ITEM_QUALITY_LEGENDARY },
        { itemId = 115026, quality = ITEM_QUALITY_LEGENDARY },
        { itemId = 120078, quality = ITEM_QUALITY_LEGENDARY },
        { itemId = 171326, quality = ITEM_QUALITY_LEGENDARY },
        { itemId = 171328, quality = ITEM_QUALITY_LEGENDARY },
        { itemId = 171433, quality = ITEM_QUALITY_LEGENDARY },

        { itemId = 26802, quality = ITEM_QUALITY_ARTIFACT },
        { itemId = 27059, quality = ITEM_QUALITY_ARTIFACT },
        { itemId = 225210, quality = ITEM_QUALITY_ARTIFACT },
        { itemId = 224836, quality = ITEM_QUALITY_ARTIFACT },
        { itemId = 224837, quality = ITEM_QUALITY_ARTIFACT },
        { itemId = 224838, quality = ITEM_QUALITY_ARTIFACT },

        { itemId = 33753 }, { itemId = 28609 },
        { itemId = 34321 }, { itemId = 33752 },
        { itemId = 33756 }, { itemId = 33754 },
        { itemId = 34311 }, { itemId = 33755 },
        { itemId = 28610 }, { itemId = 34308 },
        { itemId = 34305 }, { itemId = 28603 },
        { itemId = 34309 }, { itemId = 34324 },
        { itemId = 34323 }, { itemId = 28604 },
        { itemId = 33758 }, { itemId = 34307 },
        { itemId = 27057 }, { itemId = 27100 },
        { itemId = 26954 }, { itemId = 27064 },
        { itemId = 27063 }, { itemId = 27058 },

        { itemId = 34329 }, { itemId = 29030 },
        { itemId = 28639 }, { itemId = 34345 },
        { itemId = 34348 }, { itemId = 33774 },
        { itemId = 34334 }, { itemId = 33768 },
        { itemId = 33771 }, { itemId = 34330 },
        { itemId = 33773 }, { itemId = 28636 },
        { itemId = 34349 }, { itemId = 33772 },
        { itemId = 34346 }, { itemId = 34347 },
        { itemId = 34333 }, { itemId = 34335 },
        { itemId = 27052 }, { itemId = 27043 },
        { itemId = 27035 }, { itemId = 27049 },
        { itemId = 27048 }, { itemId = 28666 },
    },
    alchemy = {
        { itemId = 77583 }, { itemId = 30157 },
        { itemId = 30148 }, { itemId = 30160 },
        { itemId = 77585 }, { itemId = 150669 },
        { itemId = 139020 }, { itemId = 30164 },
        { itemId = 30161 }, { itemId = 150672 },
        { itemId = 150789 }, { itemId = 150731 },
        { itemId = 150671 }, { itemId = 30162 },
        { itemId = 30151 }, { itemId = 77587 },
        { itemId = 30156 },
        { itemId = 30158 }, { itemId = 30155 },
        { itemId = 30163 }, { itemId = 77591 },
        { itemId = 30153 }, { itemId = 77590 },
        { itemId = 30165 }, { itemId = 139019 },
        { itemId = 77589 }, { itemId = 77584 },
        { itemId = 30149 }, { itemId = 77581 },
        { itemId = 150670 }, { itemId = 30152 },
        { itemId = 30166 }, { itemId = 30154 },
        { itemId = 30159 },
    },
}

merchant.resourceIngredientGroupsByItemId = {}

for groupName, definitions in pairs(
    merchant.resourceIngredientDefinitions
) do
    for _, definition in ipairs(definitions) do
        merchant.resourceIngredientGroupsByItemId[
            definition.itemId
        ] = groupName
    end
end

merchant.alchemySolventDefinitions = {
    { itemId = 883, level = "3" },
    { itemId = 75357, level = "3" },
    { itemId = 1187, level = "10" },
    { itemId = 75358, level = "10" },
    { itemId = 4570, level = "20" },
    { itemId = 75359, level = "20" },
    { itemId = 23265, level = "30" },
    { itemId = 75360, level = "30" },
    { itemId = 23266, level = "40" },
    { itemId = 75361, level = "40" },
    { itemId = 23267, level = "CP 10" },
    { itemId = 75362, level = "CP 10" },
    { itemId = 23268, level = "CP 50" },
    { itemId = 75363, level = "CP 50" },
    { itemId = 64500, level = "CP 100" },
    { itemId = 75364, level = "CP 100" },
    { itemId = 64501, level = "CP 150" },
    { itemId = 75365, level = "CP 150" },
}

merchant.alchemySolventItemIds = {}

for _, definition in ipairs(
    merchant.alchemySolventDefinitions
) do
    merchant.alchemySolventItemIds[
        definition.itemId
    ] = true
end

merchant.furnishingMaterialDefinitions = {
    { itemId = 114889 },
    { itemId = 114890 },
    { itemId = 114891 },
    { itemId = 114892 },
    { itemId = 114893 },
    { itemId = 114894 },
    { itemId = 114895 },
    { itemId = 135161 },
}

merchant.furnishingMaterialItemIds = {}

for _, definition in ipairs(
    merchant.furnishingMaterialDefinitions
) do
    merchant.furnishingMaterialItemIds[
        definition.itemId
    ] = true
end

local function CreateEquipmentDefaults()
    return {
        enabled = false,
        maxQuality = ITEM_QUALITY_NORMAL,
        noTrait = false,
        ornate = false,
        intricate = false,
        tradable = false,
        traitMaterialsEnabled = false,
        traitMaterials = {},
    }
end

local function CreateEnchantingDefaults()
    return {
        enabled = false,
        maxQuality = ITEM_QUALITY_NORMAL,
        potencyRunesEnabled = false,
        potencyRunes = {},
        essenceRunesEnabled = false,
        essenceRunes = {},
        aspectRunesEnabled = false,
        aspectRunes = {},
    }
end

local function CreateConsumablesDefaults()
    return {
        enabled = true,
        foodDrinkEnabled = false,
        foodDrinkMaxQuality = ITEM_QUALITY_NORMAL,
        excludeFoodDrinkCP150 = false,
        nonCraftedFoodDrink = false,

        potionPoisonEnabled = false,
        excludePotionPoisonCP150 = false,
        nonCraftedPotionPoison = false,

        knownRecipesEnabled = false,
        recipeMaxQuality = ITEM_QUALITY_NORMAL,

        knownHousingPatternsEnabled = false,
        housingPatternMaxQuality = ITEM_QUALITY_NORMAL,
    }
end

local function CreateMaterialsDefaults()
    return {
        blacksmithingEnabled = false,
        blacksmithingRawEnabled = false,
        clothingMaterialsEnabled = false,
        clothingRawMaterialsEnabled = false,
        leatherMaterialsEnabled = false,
        leatherRawMaterialsEnabled = false,
        woodworkingEnabled = false,
        woodworkingRawEnabled = false,
        jewelryMaterialsEnabled = false,
        jewelryRawMaterialsEnabled = false,
        furnishingMaterialsEnabled = false,
        furnishingMaterials = {},
        styleMaterialsEnabled = false,
        styleMaterials = {},
    }
end

local function CreateResourcesDefaults()
    return {
        provisioningEnabled = false,
        provisioningIngredients = {},
        alchemyEnabled = false,
        alchemyIngredients = {},
        alchemySolventsEnabled = false,
        alchemySolvents = {},
    }
end

local function CreateOtherDefaults()
    return {
        emptySoulGemsEnabled = false,
        fishingBaitEnabled = false,
        trophyFishEnabled = false,
    }
end

local MOTIF_STYLE_IDS = {
    7, 4, 8, 5, 1, 2, 9, 3, 6, 34,
    15, 17, 19, 20, 14, 28, 29, 33, 26, 35,
    22, 21, 13, 47, 25, 23, 24, 44, 30, 43,
    42, 41, 11, 46, 45, 12, 40, 31, 39, 16,
    27, 59, 58, 56, 57, 53, 52, 54, 50, 51,
    49, 48, 38, 61, 62, 65, 66, 69, 70, 55,
    71, 72, 74, 75, 77, 78, 73, 80, 79, 81,
    82, 83, 84, 85, 86, 92, 89, 93, 60, 95,
    94, 97, 98, 100, 101, 102, 103, 105, 104, 106,
    107, 108, 109, 110, 111, 112, 113, 114, 117, 116,
    121, 122, 120, 119, 123, 124, 125, 126,

    128,

    129, 130, 131, 132, 135, 136, 138, 139, 141,
    140, 142, 143, 144, 145, 146, 147, 148, 149, 151,
    153, 154, 155, 156, 157, 158, 159, 162,
}

function merchant.GetStyleMaterialDefinitions()
    if merchant.styleMaterialDefinitions then
        return merchant.styleMaterialDefinitions
    end

    local definitions = {}
    local itemIds = {}
    local highestStyleId = GetHighestItemStyleId()
    local motifNumber = 0

    for _, styleId in ipairs(MOTIF_STYLE_IDS) do
        motifNumber = motifNumber + 1
        if motifNumber == 109 or motifNumber == 111 then
            motifNumber = motifNumber + 1
        end

        local itemLink = styleId <= highestStyleId
            and GetItemStyleMaterialLink(styleId)

        if itemLink and itemLink ~= "" then
            local itemId = GetItemLinkItemId(itemLink)

            if itemId and itemId > 0 and not itemIds[itemId] then
                itemIds[itemId] = true

                table.insert(definitions, {
                    itemId = itemId,
                    itemLink = itemLink,
                    name = zo_strformat(
                        SI_TOOLTIP_ITEM_NAME,
                        GetItemLinkName(itemLink)
                    ),
                    styleName = GetItemStyleName(styleId),
                    motifNumber = motifNumber,
                })
            end
        end
    end

    merchant.styleMaterialDefinitions = definitions
    merchant.styleMaterialItemIds = itemIds

    return definitions
end

function merchant.GetProfileDefaults(profileName)
    if profileName == "enchanting" then
        return CreateEnchantingDefaults()
    elseif profileName == "consumables" then
        return CreateConsumablesDefaults()
    elseif profileName == "resources" then
        return CreateResourcesDefaults()
    elseif profileName == "materials" then
        return CreateMaterialsDefaults()
    elseif profileName == "other" then
        return CreateOtherDefaults()
    end

    return CreateEquipmentDefaults()
end

function merchant.GetProfile(profileName)
    local savedVariables = owa.savedVariables

    savedVariables.merchantProfiles =
        savedVariables.merchantProfiles or {}

    local profiles = savedVariables.merchantProfiles
    profiles[profileName] = profiles[profileName] or {}

    local profile = profiles[profileName]
    local defaults = merchant.GetProfileDefaults(profileName)

    for field, defaultValue in pairs(defaults) do
        if profile[field] == nil then
            profile[field] = defaultValue
        end
    end

    local qualityFields = {
        "maxQuality",
        "foodDrinkMaxQuality",
        "recipeMaxQuality",
        "housingPatternMaxQuality",
    }

    for _, field in ipairs(qualityFields) do
        if defaults[field] ~= nil
            and type(profile[field]) ~= "number"
        then
            profile[field] = ITEM_QUALITY_NORMAL
        end
    end

    local definitions =
        merchant.traitMaterialDefinitions[profileName]

    if definitions then
        if type(profile.traitMaterials) ~= "table" then
            profile.traitMaterials = {}
        end

        for _, definition in ipairs(definitions) do
            if profile.traitMaterials[definition.itemId] == nil then
                profile.traitMaterials[definition.itemId] = false
            end
        end
    end

    if profileName == "enchanting" then
        for groupName, runeDefinitions in pairs(
            merchant.enchantingRuneDefinitions
        ) do
            local field = groupName .. "Runes"

            if type(profile[field]) ~= "table" then
                profile[field] = {}
            end

            for _, definition in ipairs(runeDefinitions) do
                if profile[field][definition.itemId] == nil then
                    profile[field][definition.itemId] = false
                end
            end
        end
    end

    if profileName == "materials" then
        if type(profile.furnishingMaterials) ~= "table" then
            profile.furnishingMaterials = {}
        end

        for _, definition in ipairs(
            merchant.furnishingMaterialDefinitions
        ) do
            if profile.furnishingMaterials[definition.itemId] == nil then
                profile.furnishingMaterials[definition.itemId] = false
            end
        end

        if type(profile.styleMaterials) ~= "table" then
            profile.styleMaterials = {}
        end

        for _, definition in ipairs(
            merchant.GetStyleMaterialDefinitions()
        ) do
            if profile.styleMaterials[definition.itemId] == nil then
                profile.styleMaterials[definition.itemId] = false
            end
        end
    end

    if profileName == "resources" then
        for groupName, ingredientDefinitions in pairs(
            merchant.resourceIngredientDefinitions
        ) do
            local field = groupName .. "Ingredients"

            if type(profile[field]) ~= "table" then
                profile[field] = {}
            end

            for _, definition in ipairs(
                ingredientDefinitions
            ) do
                if profile[field][definition.itemId] == nil then
                    profile[field][definition.itemId] = false
                end
            end
        end

        if type(profile.alchemySolvents) ~= "table" then
            profile.alchemySolvents = {}
        end

        for _, definition in ipairs(
            merchant.alchemySolventDefinitions
        ) do
            if profile.alchemySolvents[definition.itemId] == nil then
                profile.alchemySolvents[definition.itemId] = false
            end
        end
    end

    return profile
end

function merchant.IsSelectedResourceIngredient(
    profile,
    itemLink
)
    local itemId = GetItemLinkItemId(itemLink)
    local groupName =
        merchant.resourceIngredientGroupsByItemId[itemId]

    if not groupName then
        return false
    end

    local enabledField = groupName .. "Enabled"
    local selectionField = groupName .. "Ingredients"
    local selectedIngredients = profile[selectionField]

    return profile[enabledField] == true
        and type(selectedIngredients) == "table"
        and selectedIngredients[itemId] == true
end

function merchant.IsSelectedAlchemySolvent(profile, itemLink)
    if not profile.alchemySolventsEnabled
        or type(profile.alchemySolvents) ~= "table"
    then
        return false
    end

    local itemId = GetItemLinkItemId(itemLink)

    return merchant.alchemySolventItemIds[itemId] == true
        and profile.alchemySolvents[itemId] == true
end

function merchant.IsSelectedFurnishingMaterial(
    profile,
    itemLink
)
    if not profile.furnishingMaterialsEnabled
        or type(profile.furnishingMaterials) ~= "table"
    then
        return false
    end

    local itemId = GetItemLinkItemId(itemLink)

    return merchant.furnishingMaterialItemIds[itemId] == true
        and profile.furnishingMaterials[itemId] == true
end

function merchant.IsSelectedStyleMaterial(profile, itemLink)
    if not profile.styleMaterialsEnabled
        or type(profile.styleMaterials) ~= "table"
    then
        return false
    end

    merchant.GetStyleMaterialDefinitions()

    local itemId = GetItemLinkItemId(itemLink)

    return merchant.styleMaterialItemIds[itemId] == true
        and profile.styleMaterials[itemId] == true
end

function merchant.IsSelectedEnchantingRune(profile, itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    local groupName =
        merchant.enchantingRuneGroupsByItemId[itemId]

    if not groupName then
        return false
    end

    local enabledField = groupName .. "RunesEnabled"
    local selectionField = groupName .. "Runes"
    local selectedRunes = profile[selectionField]

    return profile[enabledField] == true
        and type(selectedRunes) == "table"
        and selectedRunes[itemId] == true
end

function merchant.IsSelectedTraitMaterial(
    profile,
    profileName,
    itemLink
)
    if not profile.traitMaterialsEnabled
        or type(profile.traitMaterials) ~= "table"
    then
        return false
    end

    local itemId = GetItemLinkItemId(itemLink)
    local definitions =
        merchant.traitMaterialDefinitions[profileName]

    if not definitions
        or profile.traitMaterials[itemId] ~= true
    then
        return false
    end

    for _, definition in ipairs(definitions) do
        if definition.itemId == itemId then
            return true
        end
    end

    return false
end

function merchant.GetItemQuality(bagId, slotIndex)
    local _, _, _, _, _, _, _, _, quality =
        GetItemInfo(bagId, slotIndex)

    return quality
end

function merchant.GetItemSellPrice(bagId, slotIndex)
    local _, _, sellPrice = GetItemInfo(
        bagId,
        slotIndex
    )

    return sellPrice or 0
end

function merchant.IsOrnate(itemLink, traitInformation)
    local traitType = GetItemLinkTraitType(itemLink)

    return traitInformation == ITEM_TRAIT_INFORMATION_ORNATE
        or traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE
        or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE
end

function merchant.IsIntricate(itemLink, traitInformation)
    local traitType = GetItemLinkTraitType(itemLink)

    return traitInformation == ITEM_TRAIT_INFORMATION_INTRICATE
        or traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE
        or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE
end

function merchant.PassesEquipmentFilters(
    profile,
    bagId,
    slotIndex,
    itemLink
)
    local quality = merchant.GetItemQuality(
        bagId,
        slotIndex
    )

    if not quality or quality > profile.maxQuality then
        return false
    end

    local traitType = GetItemLinkTraitType(itemLink)
    local traitInformation =
        GetItemTraitInformationFromItemLink(itemLink)

    if traitType == ITEM_TRAIT_TYPE_NONE
        and not profile.noTrait
    then
        return false
    end

    if merchant.IsOrnate(itemLink, traitInformation)
        and not profile.ornate
    then
        return false
    end

    if merchant.IsIntricate(itemLink, traitInformation)
        and not profile.intricate
    then
        return false
    end

    if IsItemBoPAndTradeable(bagId, slotIndex)
        and not profile.tradable
    then
        return false
    end

    return true
end

function merchant.IsSafeToSell(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then
        return false
    end

    local itemLink = GetItemLink(
        bagId,
        slotIndex,
        LINK_STYLE_DEFAULT
    )

    if not itemLink or itemLink == "" then
        return false
    end

    if GetItemLinkSellInformation(itemLink)
        == ITEM_SELL_INFORMATION_CANNOT_SELL
    then
        return false
    end

    local stackCount = GetSlotStackSize(
        bagId,
        slotIndex
    ) or 0

    if stackCount <= 0
        or merchant.GetItemSellPrice(bagId, slotIndex) <= 0
        or IsItemPlayerLocked(bagId, slotIndex)
        or IsItemStolen(bagId, slotIndex)
        or IsItemInArmory(bagId, slotIndex)
    then
        return false
    end

    return true, itemLink, stackCount
end

function merchant.RegisterCategory(
    categoryName,
    matcher
)
    if type(matcher) ~= "function" then
        return
    end

    if not merchant.categoryMatchers[categoryName] then
        table.insert(
            merchant.categoryOrder,
            categoryName
        )
    end

    merchant.categoryMatchers[categoryName] = matcher
end

function merchant.ShouldSellItem(bagId, slotIndex)
    local safe, itemLink, stackCount =
        merchant.IsSafeToSell(bagId, slotIndex)

    if not safe then
        return false
    end

    for _, categoryName in ipairs(
        merchant.categoryOrder
    ) do
        local profile = merchant.GetProfile(categoryName)
        local matcher = merchant.categoryMatchers[categoryName]

        if matcher(
                profile,
                bagId,
                slotIndex,
                itemLink
            )
        then
            return true, itemLink, stackCount
        end
    end

    return false
end

function merchant.BuildSaleQueue()
    merchant.saleQueue = {}

    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local shouldSell, itemLink, stackCount =
            merchant.ShouldSellItem(
                BAG_BACKPACK,
                slotIndex
            )

        if shouldSell then
            table.insert(merchant.saleQueue, {
                slotIndex = slotIndex,
                itemLink = itemLink,
                stackCount = stackCount,
            })
        end
    end
end

local function FormatMoney(amount)
    return ZO_Currency_FormatPlatform(
        CURT_MONEY,
        amount or 0,
        ZO_CURRENCY_FORMAT_AMOUNT_ICON
    )
end

local function Chat(message)
    if owa.savedVariables.merchantChatMessages == false then
        return
    end

    d("[OWMerchant] " .. message)
end

local function FinishSelling(expectedGeneration)
    if merchant.saleGeneration ~= expectedGeneration
        or merchant.saleFinished
    then
        return
    end

    merchant.saleFinished = true
    merchant.pendingSale = nil

    if merchant.soldQuantity > 0 then
        Chat(string.format(
            owa.GetString("MERCHANT_CHAT_SUMMARY"),
            merchant.soldQuantity,
            FormatMoney(merchant.soldMoney)
        ))
    end
end

function merchant.StopSelling()
    FinishSelling(merchant.saleGeneration)
    merchant.saleGeneration = merchant.saleGeneration + 1
    merchant.saleQueue = {}
    merchant.pendingSale = nil
    merchant.storeOpen = false
end

local ProcessNextSale

ProcessNextSale = function(expectedGeneration)
    if not merchant.storeOpen
        or merchant.saleGeneration ~= expectedGeneration
        or GetInteractionType() ~= INTERACTION_VENDOR
    then
        return
    end

    local candidate = table.remove(merchant.saleQueue, 1)

    if not candidate then
        FinishSelling(expectedGeneration)
        return
    end

    if GetCurrencyAmount(
        CURT_MONEY,
        CURRENCY_LOCATION_CHARACTER
    ) >= GetMaxPossibleCurrency(
        CURT_MONEY,
        CURRENCY_LOCATION_CHARACTER
    ) then
        FinishSelling(expectedGeneration)
        return
    end

    local shouldSell, currentItemLink, stackCount =
        merchant.ShouldSellItem(
            BAG_BACKPACK,
            candidate.slotIndex
        )

    if shouldSell
        and currentItemLink == candidate.itemLink
    then
        local pendingSale = {
            generation = expectedGeneration,
            itemLink = currentItemLink,
        }
        merchant.pendingSale = pendingSale

        SellInventoryItem(
            BAG_BACKPACK,
            candidate.slotIndex,
            stackCount
        )

        zo_callLater(function()
            if merchant.pendingSale == pendingSale then
                merchant.pendingSale = nil
                ProcessNextSale(expectedGeneration)
            end
        end, 2000)

        return
    end

    zo_callLater(function()
        ProcessNextSale(expectedGeneration)
    end, SALE_DELAY_MS)
end

function merchant.OnSellReceipt(
    eventCode,
    itemName,
    itemQuantity,
    money
)
    local pendingSale = merchant.pendingSale

    if not pendingSale
        or pendingSale.generation ~= merchant.saleGeneration
    then
        return
    end

    merchant.pendingSale = nil

    local quantity = tonumber(itemQuantity) or 0
    local saleMoney = tonumber(money) or 0

    merchant.soldQuantity =
        merchant.soldQuantity + quantity
    merchant.soldMoney = merchant.soldMoney + saleMoney

    if quantity > 0
        and owa.savedVariables.merchantChatMode == "detailed"
    then
        Chat(string.format(
            owa.GetString("MERCHANT_CHAT_SOLD_ITEM"),
            pendingSale.itemLink,
            quantity,
            FormatMoney(saleMoney)
        ))
    end

    zo_callLater(function()
        ProcessNextSale(pendingSale.generation)
    end, SALE_DELAY_MS)
end

function merchant.StartSelling()
    if not owa.savedVariables.merchantEnabled
        or GetInteractionType() ~= INTERACTION_VENDOR
        or GetCurrencyAmount(
            CURT_MONEY,
            CURRENCY_LOCATION_CHARACTER
        ) == GetMaxPossibleCurrency(
            CURT_MONEY,
            CURRENCY_LOCATION_CHARACTER
        )
    then
        return
    end

    merchant.saleGeneration = merchant.saleGeneration + 1
    merchant.storeOpen = true
    merchant.pendingSale = nil
    merchant.soldQuantity = 0
    merchant.soldMoney = 0
    merchant.saleFinished = false

    merchant.BuildSaleQueue()
    ProcessNextSale(merchant.saleGeneration)
end

function merchant.Initialize()
    if owa.savedVariables.merchantChatMessages == nil then
        owa.savedVariables.merchantChatMessages = true
    end

    if owa.savedVariables.merchantChatMode ~= "summary"
        and owa.savedVariables.merchantChatMode ~= "detailed"
    then
        owa.savedVariables.merchantChatMode = "summary"
    end

    merchant.GetProfile("weapon")
    merchant.GetProfile("clothing")
    merchant.GetProfile("jewelry")
    merchant.GetProfile("enchanting")
    merchant.GetProfile("consumables")
    merchant.GetProfile("resources")
    merchant.GetProfile("materials")
    merchant.GetProfile("other")

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Receipt",
        EVENT_SELL_RECEIPT,
        merchant.OnSellReceipt
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Open",
        EVENT_OPEN_STORE,
        function()
            zo_callLater(function()
                merchant.StartSelling()
            end, 100)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Close",
        EVENT_CLOSE_STORE,
        function()
            merchant.StopSelling()
        end
    )
end
