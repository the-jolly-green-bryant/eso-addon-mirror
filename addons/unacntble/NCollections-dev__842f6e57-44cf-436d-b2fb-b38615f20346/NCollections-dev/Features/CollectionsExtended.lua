NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local browser = NCollections.Features.CollectionsCollectibleBrowser
local dynamicData = NCollections.Features.CollectionsDynamicData

local function GetCollectibleTypeName(collectibleData, fallback)
    if not collectibleData or not collectibleData.GetCategoryType or not GetString then return fallback end
    local name = GetString("SI_COLLECTIBLECATEGORYTYPE", collectibleData:GetCategoryType())
    return name ~= "" and name or fallback
end

local function GetSpecializedCollectibleTypeName(collectibleData, fallback)
    if not collectibleData or not collectibleData.GetSpecializedCategoryType or not GetString then return fallback end
    local name = GetString("SI_SPECIALIZEDCOLLECTIBLETYPE", collectibleData:GetSpecializedCategoryType())
    return name ~= "" and name or fallback
end

local function GetOutfitStyleGroupName(collectibleData, fallback)
    if not collectibleData or not collectibleData.GetOutfitStyleItemStyleName then return fallback end
    local name = collectibleData:GetOutfitStyleItemStyleName()
    return name and name ~= "" and name or fallback
end

local furnishingSpecializations = {
    [SPECIALIZED_COLLECTIBLE_TYPE_BUST] = true,
    [SPECIALIZED_COLLECTIBLE_TYPE_TOOL] = true,
    [SPECIALIZED_COLLECTIBLE_TYPE_KEEPSAKE] = true,
    [SPECIALIZED_COLLECTIBLE_TYPE_HOUSEGUEST] = true,
}

local function IsBrowsableCollectibleFurnishing(collectibleData)
    if not collectibleData or not collectibleData.GetSpecializedCategoryType then return false end
    if not furnishingSpecializations[collectibleData:GetSpecializedCategoryType()] then return false end
    return not collectibleData.IsPlaceableFurniture or collectibleData:IsPlaceableFurniture()
end

NCollections.Features.CollectionsAppearance = browser.Create({
    singularKey = "collections.appearance_collectible",
    pluralKey = "collections.appearance",
    settingsKey = "appearance",
    categoryTypes = {
        COLLECTIBLE_CATEGORY_TYPE_COSTUME,
        COLLECTIBLE_CATEGORY_TYPE_HAT,
        COLLECTIBLE_CATEGORY_TYPE_PERSONALITY,
        COLLECTIBLE_CATEGORY_TYPE_POLYMORPH,
        COLLECTIBLE_CATEGORY_TYPE_HAIR,
        COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS,
        COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY,
        COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY,
        COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING,
        COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING,
    },
    groupByCategory = true,
    getCategoryName = GetCollectibleTypeName,
    searchDialogName = "NCollections_COLLECTIONS_APPEARANCE_SEARCH",
    controlName = "NCollectionsCollectionsAppearance",
    supportsActive = true,
})

NCollections.Features.CollectionsAssistants = browser.Create({
    singularKey = "collections.assistant",
    pluralKey = "collections.assistants",
    settingsKey = "assistants",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_ASSISTANT,
    searchDialogName = "NCollections_COLLECTIONS_ASSISTANTS_SEARCH",
    controlName = "NCollectionsCollectionsAssistants",
    supportsActive = true,
    showNickname = true,
})

NCollections.Features.CollectionsSkillStyles = browser.Create({
    singularKey = "collections.skill_style",
    pluralKey = "collections.skill_styles",
    settingsKey = "skillStyles",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE,
    groupByCategory = true,
    getCategoryName = dynamicData.GetSkillStyleCategoryName,
    searchDialogName = "NCollections_COLLECTIONS_SKILL_STYLES_SEARCH",
    controlName = "NCollectionsCollectionsSkillStyles",
    supportsActive = false,
    supportsActions = false,
    showActiveStatus = false,
})

NCollections.Features.CollectionsOutfitStyles = browser.Create({
    singularKey = "collections.outfit_style",
    pluralKey = "collections.outfit_styles",
    settingsKey = "outfitStyles",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE,
    groupByCategory = true,
    getCategoryName = GetOutfitStyleGroupName,
    searchDialogName = "NCollections_COLLECTIONS_OUTFIT_STYLES_SEARCH",
    controlName = "NCollectionsCollectionsOutfitStyles",
    supportsActive = false,
    supportsActions = false,
    showActiveStatus = false,
})

NCollections.Features.CollectionsAntiquities = browser.Create({
    singularKey = "collections.antiquity",
    pluralKey = "collections.antiquities",
    settingsKey = "antiquities",
    enumerateKeys = dynamicData.EnumerateAntiquityKeys,
    buildRecord = dynamicData.BuildAntiquityRecord,
    isAcquiredKey = dynamicData.IsAntiquityAcquired,
    groupByCategory = true,
    groupedInputHintKey = "collections.input_hint_grouped_areas",
    searchDialogName = "NCollections_COLLECTIONS_ANTIQUITIES_SEARCH",
    controlName = "NCollectionsCollectionsAntiquities",
    supportsActive = false,
    supportsActions = false,
    showActiveStatus = false,
    showPurchasable = false,
})

NCollections.Features.CollectionsDyes = browser.Create({
    singularKey = "collections.dye",
    pluralKey = "collections.dyes",
    settingsKey = "dyes",
    enumerateKeys = dynamicData.EnumerateDyeKeys,
    buildRecord = dynamicData.BuildDyeRecord,
    isAcquiredKey = dynamicData.IsDyeAcquired,
    groupByCategory = true,
    searchDialogName = "NCollections_COLLECTIONS_DYES_SEARCH",
    controlName = "NCollectionsCollectionsDyes",
    supportsActive = false,
    supportsActions = false,
    showActiveStatus = false,
    showPurchasable = false,
})

NCollections.Features.CollectionsScribing = browser.Create({
    singularKey = "collections.scribing_entry",
    pluralKey = "collections.scribing",
    settingsKey = "scribing",
    enumerateKeys = dynamicData.EnumerateScribingKeys,
    buildRecord = dynamicData.BuildScribingRecord,
    isAcquiredKey = dynamicData.IsScribingAcquired,
    groupByCategory = true,
    searchDialogName = "NCollections_COLLECTIONS_SCRIBING_SEARCH",
    controlName = "NCollectionsCollectionsScribing",
    supportsActive = false,
    supportsActions = false,
    showActiveStatus = false,
    showPurchasable = false,
})

NCollections.Features.CollectionsCollectibleFurnishings = browser.Create({
    singularKey = "collections.collectible_furnishing",
    pluralKey = "collections.collectible_furnishings",
    settingsKey = "collectibleFurnishings",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_FURNITURE,
    collectibleFilter = IsBrowsableCollectibleFurnishing,
    groupByCategory = true,
    getCategoryName = GetSpecializedCollectibleTypeName,
    searchDialogName = "NCollections_COLLECTIONS_COLLECTIBLE_FURNISHINGS_SEARCH",
    controlName = "NCollectionsCollectionsCollectibleFurnishings",
    supportsActive = false,
    supportsActions = false,
    showActiveStatus = false,
})

NCollections.Features.CollectionsEmotesAndActions = browser.Create({
    singularKey = "collections.emote_or_action",
    pluralKey = "collections.emotes_and_actions",
    settingsKey = "emotesAndActions",
    categoryTypes = {
        COLLECTIBLE_CATEGORY_TYPE_EMOTE,
        COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE,
    },
    groupByCategory = true,
    getCategoryName = GetCollectibleTypeName,
    searchDialogName = "NCollections_COLLECTIONS_EMOTES_ACTIONS_SEARCH",
    controlName = "NCollectionsCollectionsEmotesAndActions",
    supportsActive = true,
})

NCollections.Features.ExtendedCollectionFeatures = {
    NCollections.Features.CollectionsAppearance,
    NCollections.Features.CollectionsAssistants,
    NCollections.Features.CollectionsSkillStyles,
    NCollections.Features.CollectionsOutfitStyles,
    NCollections.Features.CollectionsAntiquities,
    NCollections.Features.CollectionsDyes,
    NCollections.Features.CollectionsScribing,
    NCollections.Features.CollectionsCollectibleFurnishings,
    NCollections.Features.CollectionsEmotesAndActions,
}
