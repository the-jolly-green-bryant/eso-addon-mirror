NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local browser = NQOL.Features.CollectionsCollectibleBrowser
local companionDetails = NQOL.Features.CollectionsCompanionDetails

NQOL.Features.CollectionsPets = browser.Create({
    singularKey = "collections.non_combat_pet",
    pluralKey = "collections.non_combat_pets",
    settingsKey = "pets",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_VANITY_PET,
    searchDialogName = "NQOL_COLLECTIONS_PETS_SEARCH",
    controlName = "NQOLCollectionsPets",
    supportsActive = true,
    showNickname = true,
    dismissLabelKey = "collections.dismiss_pet",
    useLabelKey = "collections.summon_pet",
})

NQOL.Features.CollectionsMementos = browser.Create({
    singularKey = "collections.memento",
    pluralKey = "collections.mementos",
    settingsKey = "mementos",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_MEMENTO,
    searchDialogName = "NQOL_COLLECTIONS_MEMENTOS_SEARCH",
    controlName = "NQOLCollectionsMementos",
    supportsActive = false,
    useLabelKey = "common.use",
})

NQOL.Features.CollectionsCompanions = browser.Create({
    singularKey = "collections.companion",
    pluralKey = "collections.companions",
    settingsKey = "companions",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_COMPANION,
    searchDialogName = "NQOL_COLLECTIONS_COMPANIONS_SEARCH",
    controlName = "NQOLCollectionsCompanions",
    supportsActive = true,
    showLetterGroups = false,
    showActiveStatus = false,
    showQuestState = true,
    appendDetailLines = companionDetails.AppendDetailLines,
    allowUnacquiredUse = true,
    dismissLabelKey = "collections.dismiss_companion",
    useLabelKey = "collections.summon_companion",
})
