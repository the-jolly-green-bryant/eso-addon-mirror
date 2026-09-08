local owa = OWAssistant

local function CreateDeconstructProfile()
    return {
        enabled = false,
        maxQuality = ITEM_QUALITY_NORMAL,

        noTrait = false,
        crafted = false,
        ornate = false,
        intricate = false,
        reconstructed = false,
        tradable = false,
        fromBank = false,
        nirnhoned = false,

        researchMode = "none",
    }
end

local function CreateMerchantEquipmentProfile()
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

local function CreateMerchantEnchantingProfile()
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

local function CreateMerchantConsumablesProfile()
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

local function CreateMerchantMaterialsProfile()
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

local function CreateMerchantResourcesProfile()
    return {
        provisioningEnabled = false,
        provisioningIngredients = {},
        alchemyEnabled = false,
        alchemyIngredients = {},
        alchemySolventsEnabled = false,
        alchemySolvents = {},
    }
end

local function CreateMerchantOtherProfile()
    return {
        emptySoulGemsEnabled = false,
        fishingBaitEnabled = false,
        trophyFishEnabled = false,
    }
end

local function GetSavedVariableDefaults()
    local defaults = owa.GetAccountDefaults()
    local savedRoot = _G["OWAssistantSavedVariables"]

    if not savedRoot then
        return defaults
    end

    local displayName = GetDisplayName()
    local worldName = GetWorldName()
    local profileData = savedRoot["Default"]
    local displayData = profileData
        and profileData[displayName]
    local accountData = displayData
        and displayData["$AccountWide"]
    local currentSettings = accountData
        and accountData[worldName]

    if currentSettings then
        return defaults
    end

    local oldSettings = accountData

    if not oldSettings then
        return defaults
    end

    local migratedDefaults = defaults
    local migratableKeys = {
        "language",
        "accountWide",
        "repairEnabled",
        "deconstructEnabled",
        "merchantEnabled",
        "merchantChatMessages",
        "merchantChatMode",
        "deconstructChatMessages",
        "repairAndRecharge",
        "deconstructProfiles",
        "merchantProfiles",
    }

    for _, key in ipairs(migratableKeys) do
        local value = rawget(oldSettings, key)

        if value ~= nil then
            if type(value) == "table" then
                migratedDefaults[key] =
                    ZO_DeepTableCopy(value)
            else
                migratedDefaults[key] = value
            end
        end
    end

    return migratedDefaults
end

function owa.Initialize()
    owa.savedVariables = ZO_SavedVars:NewAccountWide(
        "OWAssistantSavedVariables",
        1,
        GetWorldName(),
        GetSavedVariableDefaults()
    )

    if not owa.savedVariables.language then
        owa.savedVariables.language = owa.GetLanguageCode()
    end

    SafeAddString(
        SI_OWA_ADDON_NAME,
        owa.GetString("ADDON_NAME"),
        1
    )
    SafeAddString(
        SI_BINDING_NAME_OWA_DECONSTRUCT,
        owa.GetString("MASS_DECONSTRUCT"),
        1
    )

    owa.LoadModules()
    owa.CreateSettings()
end

function owa.GetAccountDefaults()
    return {
        language = owa.GetLanguageCode(),
        accountWide = true,

        repairEnabled = false,
        deconstructEnabled = true,
        merchantEnabled = false,
        merchantChatMessages = true,
        merchantChatMode = "summary",
        deconstructChatMessages = true,

        repairAndRecharge = {
            autoRepair = false,
            repairThreshold = 10,
            useCrownRepairKitsFirst = false,
            repairInCombat = false,
            repairResourceTracking = true,
            repairResourceThreshold = 10,
            repairChatMessages = true,

            autoRecharge = false,
            rechargeThreshold = 10,
            useCrownSoulGemsFirst = false,
            rechargeInCombat = false,
            rechargeResourceTracking = true,
            rechargeResourceThreshold = 10,
            rechargeChatMessages = true,
        },

        deconstructProfiles = {
            weapon = CreateDeconstructProfile(),
            clothing = CreateDeconstructProfile(),
            jewelry = CreateDeconstructProfile(),
            enchanting = CreateDeconstructProfile(),
        },

        merchantProfiles = {
            weapon = CreateMerchantEquipmentProfile(),
            clothing = CreateMerchantEquipmentProfile(),
            jewelry = CreateMerchantEquipmentProfile(),
            enchanting = CreateMerchantEnchantingProfile(),
            consumables = CreateMerchantConsumablesProfile(),
            resources = CreateMerchantResourcesProfile(),
            materials = CreateMerchantMaterialsProfile(),
            other = CreateMerchantOtherProfile(),
        },
    }
end

function owa.LoadModules()
    local savedVariables = owa.savedVariables

    if savedVariables.repairEnabled then
        owa.Repair.Initialize()
        owa.Repair.CreateSettings()
    end

    if savedVariables.deconstructEnabled then
        owa.Deconstruct.Initialize()
        owa.Deconstruct.CreateSettings()
    end

    if savedVariables.merchantEnabled then
        owa.Merchant.Initialize()
        owa.Merchant.CreateSettings()
    end
end
