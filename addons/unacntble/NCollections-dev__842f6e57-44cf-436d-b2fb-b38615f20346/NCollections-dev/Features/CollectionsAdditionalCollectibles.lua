NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local browser = NCollections.Features.CollectionsCollectibleBrowser
local companionDetails = NCollections.Features.CollectionsCompanionDetails

NCollections.Features.CollectionsPets = browser.Create({
    singularKey = "collections.non_combat_pet",
    pluralKey = "collections.non_combat_pets",
    settingsKey = "pets",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
    searchDialogName = "NCollections_COLLECTIONS_PETS_SEARCH",
    controlName = "NCollectionsCollectionsPets",
    supportsActive = true,
    showNickname = true,
    dismissLabelKey = "collections.dismiss_pet",
    useLabelKey = "collections.summon_pet",
})

NCollections.Features.CollectionsMementos = browser.Create({
    singularKey = "collections.memento",
    pluralKey = "collections.mementos",
    settingsKey = "mementos",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_MEMENTO,
    searchDialogName = "NCollections_COLLECTIONS_MEMENTOS_SEARCH",
    controlName = "NCollectionsCollectionsMementos",
    supportsActive = false,
    useLabelKey = "common.use",
})

NCollections.Features.CollectionsCompanions = browser.Create({
    singularKey = "collections.companion",
    pluralKey = "collections.companions",
    settingsKey = "companions",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_COMPANION,
    searchDialogName = "NCollections_COLLECTIONS_COMPANIONS_SEARCH",
    controlName = "NCollectionsCollectionsCompanions",
    supportsActive = true,
    showLetterGroups = false,
    showActiveStatus = false,
    showQuestState = true,
    appendDetailLines = companionDetails.AppendDetailLines,
    buildDetailColumns = companionDetails.BuildRapportColumns,
    releaseData = companionDetails.ReleaseTransientData,
    heightRatio = 1,
    maxHeight = 1200,
    allowUnacquiredUse = true,
    dismissLabelKey = "collections.dismiss_companion",
    useLabelKey = "collections.summon_companion",
})
