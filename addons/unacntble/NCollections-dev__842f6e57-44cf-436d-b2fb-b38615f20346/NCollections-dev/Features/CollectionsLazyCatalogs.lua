NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local Browser = NCollections.Features.CollectionsCollectibleBrowser
local Util = NCollections.Util

local function Format(formatter, value)
    if zo_strformat and formatter then return zo_strformat(formatter, value or "") end
    return tostring(value or "")
end

local function GetCollectibleData(collectibleId)
    if not ZO_COLLECTIBLE_DATA_MANAGER or not ZO_COLLECTIBLE_DATA_MANAGER.GetCollectibleDataById then return nil end
    return ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectibleId)
end

local function Detail(key, value)
    return { label = NCollections.L(key), value = value }
end

local function BooleanText(value)
    return value and NCollections.L("common.yes") or NCollections.L("common.no")
end

local function EnumerateHouseKeys()
    local keys = {}
    if not ZO_COLLECTIBLE_DATA_MANAGER or not ZO_CollectibleCategoryData or not ZO_CollectibleCategoryData.IsHousingCategory then return keys end
    Util.ForEachCollectibleDataObject(ZO_COLLECTIBLE_DATA_MANAGER, { ZO_CollectibleCategoryData.IsHousingCategory }, nil, function(data)
        if (data:GetReferenceId() or 0) > 0 then keys[#keys + 1] = data:GetId() end
    end)
    return keys
end

local function IsHouseAcquired(collectibleId)
    local data = GetCollectibleData(collectibleId)
    return data and data:IsUnlocked() or false
end

local function GetHouseType(houseId)
    if not GetHouseCategoryType or not GetString then return NCollections.L("features.collections_housing.house") end
    local value = GetString("SI_HOUSECATEGORYTYPE", GetHouseCategoryType(houseId))
    return value and value ~= "" and value or NCollections.L("features.collections_housing.house")
end

local function BuildHouseRecord(collectibleId, includeDetails)
    local data = GetCollectibleData(collectibleId)
    if not data then return nil end
    local houseId = data:GetReferenceId()
    local acquired = data:IsUnlocked()
    local category = GetHouseType(houseId)
    local zoneId = GetHouseFoundInZoneId and GetHouseFoundInZoneId(houseId) or 0
    local location = zoneId ~= 0 and GetZoneNameById and Format(SI_ZONE_NAME, GetZoneNameById(zoneId)) or NCollections.L("features.collections_housing.unknown_location")
    local record = {
        collectibleId = collectibleId,
        houseId = houseId,
        name = Format(SI_COLLECTIBLE_NAME_FORMATTER, data:GetName()),
        categoryName = category .. " · " .. location,
        isAcquired = acquired,
        searchExtra = location,
        hasAction = true,
        actionLabel = acquired and NCollections.L("features.collections_housing.travel_to_house") or NCollections.L("features.collections_housing.preview_house"),
    }
    if includeDetails then
        record.description = data:GetDescription() or ""
        record.hint = not acquired and data:GetHint() or ""
        record.extraDetails = {
            Detail("features.collections_housing.nickname", acquired and data:GetNickname() or ""),
            Detail("features.collections_housing.primary_residence", BooleanText(acquired and data:IsPrimaryResidence() or false)),
        }
    end
    return record
end

local function CanVisitHouse(record)
    if CanJumpToHouseFromCurrentLocation and not CanJumpToHouseFromCurrentLocation() then
        local stringId = record.isAcquired and SI_COLLECTIONS_CANNOT_JUMP_TO_HOUSE_FROM_LOCATION or SI_COLLECTIONS_CANNOT_PREVIEW_HOUSE_FROM_LOCATION
        return false, GetString and stringId and GetString(stringId) or NCollections.L(record.isAcquired and "features.collections_housing.cannot_travel_here" or "features.collections_housing.cannot_preview_here")
    end
    return true
end

local function VisitHouse(record)
    if record.isAcquired then
        local data = GetCollectibleData(record.collectibleId)
        if data and ZO_Dialogs_ShowGamepadDialog then
            ZO_Dialogs_ShowGamepadDialog("GAMEPAD_TRAVEL_TO_HOUSE_OPTIONS_DIALOG", data)
            return
        end
    end
    if RequestJumpToHouse then RequestJumpToHouse(record.houseId) end
    if SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then SCENE_MANAGER:ShowBaseScene() end
end

local housing = Browser.Create({
    singularKey = "features.collections_housing.house",
    pluralKey = "collections.housing.title",
    settingsKey = "housing",
    enumerateKeys = EnumerateHouseKeys,
    buildRecord = BuildHouseRecord,
    isAcquiredKey = IsHouseAcquired,
    searchDialogName = "NCollections_COLLECTIONS_HOUSING_SEARCH",
    supportsActive = false,
    hasAction = function() return true end,
    canUseRecord = CanVisitHouse,
    useRecord = VisitHouse,
    showPurchasable = false,
})

local mounts = Browser.Create({
    singularKey = "collections.mount",
    pluralKey = "collections.mounts",
    settingsKey = "mounts",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_MOUNT,
    searchDialogName = "NCollections_COLLECTIONS_MOUNTS_SEARCH",
    supportsActive = true,
    showNickname = true,
})

local skins = Browser.Create({
    singularKey = "collections.skin",
    pluralKey = "collections.skins",
    settingsKey = "skins",
    categoryType = COLLECTIBLE_CATEGORY_TYPE_SKIN,
    searchDialogName = "NCollections_COLLECTIONS_SKINS_SEARCH",
    supportsActive = true,
})

local function EnumerateSetKeys(crafted)
    local keys = {}
    if crafted then
        local data = NCollections.Features.CollectionsGearData
        if data then data.AppendCraftedSetIds(keys) end
        return keys
    end
    if not GetNextItemSetCollectionId then return keys end
    local setId = GetNextItemSetCollectionId(nil)
    local processed = 0
    while setId do
        processed = processed + 1
        if not GetNumItemSetCollectionPieces or (GetNumItemSetCollectionPieces(setId) or 0) > 0 then keys[#keys + 1] = setId end
        Util.FrameTaskCheckpoint(processed, 1)
        setId = GetNextItemSetCollectionId(setId)
    end
    return keys
end

local function IsSetComplete(setId, crafted)
    if crafted then return true end
    local total = GetNumItemSetCollectionPieces and GetNumItemSetCollectionPieces(setId) or 0
    local unlocked = GetNumItemSetCollectionSlotsUnlocked and GetNumItemSetCollectionSlotsUnlocked(setId) or 0
    return total > 0 and unlocked >= total
end

local function GetSetCategory(setId, crafted)
    if crafted then return NCollections.L("features.collections_gear.type_crafted") end
    if not GetItemSetCollectionCategoryId or not GetItemSetCollectionCategoryName then return NCollections.L("features.collections_gear.set_collection") end
    local categoryId = GetItemSetCollectionCategoryId(setId)
    local value = categoryId and GetItemSetCollectionCategoryName(categoryId) or ""
    return value and value ~= "" and value or NCollections.L("features.collections_gear.set_collection")
end

local function BuildSetRecord(setId, crafted, includeDetails, feature)
    if not GetItemSetName then return nil end
    local total = crafted and 0 or (GetNumItemSetCollectionPieces and GetNumItemSetCollectionPieces(setId) or 0)
    local unlocked = crafted and 0 or (GetNumItemSetCollectionSlotsUnlocked and GetNumItemSetCollectionSlotsUnlocked(setId) or 0)
    local record = {
        collectibleId = setId,
        name = Format(SI_ITEM_SET_NAME_FORMATTER, GetItemSetName(setId)),
        categoryName = GetSetCategory(setId, crafted),
        isAcquired = crafted or (total > 0 and unlocked >= total),
    }
    if not includeDetails then return record end
    local lines = {}
    if not crafted and GetItemSetCollectionPieceInfo then
        for pieceIndex = 1, total do
            local pieceId, slot = GetItemSetCollectionPieceInfo(setId, pieceIndex)
            local itemLink = pieceId and GetItemSetCollectionPieceItemLink and GetItemSetCollectionPieceItemLink(pieceId, LINK_STYLE_DEFAULT, ITEM_TRAIT_TYPE_NONE, nil) or ""
            local pieceName = itemLink ~= "" and GetItemLinkName and Format(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)) or NCollections.L("features.collections_gear.unknown_piece")
            local pieceAcquired = slot and IsItemSetCollectionSlotUnlocked and IsItemSetCollectionSlotUnlocked(setId, slot)
            lines[#lines + 1] = "• " .. pieceName .. "  |cA1B8D1· " .. NCollections.L(pieceAcquired and "common.acquired" or "common.missing") .. "|r"
            Util.FrameTaskCheckpoint(pieceIndex, 1)
        end
    end
    if feature and feature.GetExtraSetting("setCard") and GetItemSetInfo and GetItemSetBonusInfo then
        local hasSet, _, bonuses = GetItemSetInfo(setId)
        if hasSet then
            lines[#lines + 1] = ""
            lines[#lines + 1] = NCollections.L((bonuses or 0) == 1 and "features.collections_gear.set_bonus" or "features.collections_gear.set_bonuses")
            for bonusIndex = 1, bonuses or 0 do
                local _, description = GetItemSetBonusInfo(setId, bonusIndex)
                if description and description ~= "" then lines[#lines + 1] = description end
                Util.FrameTaskCheckpoint(bonusIndex, 1)
            end
        end
    end
    record.description = table.concat(lines, "\n")
    record.searchExtra = string.format("%d/%d", unlocked, total)
    return record
end

local gearSet
gearSet = Browser.Create({
    singularKey = "common.item_set",
    pluralKey = "features.collections_gear.sets_cba9e41",
    settingsKey = "gearSet",
    enumerateKeys = function() return EnumerateSetKeys(false) end,
    buildRecord = function(key, details) return BuildSetRecord(key, false, details, gearSet) end,
    isAcquiredKey = function(key) return IsSetComplete(key, false) end,
    searchDialogName = "NCollections_COLLECTIONS_GEAR_SEARCH",
    supportsActive = false,
    supportsActions = false,
    showPurchasable = false,
    extraDefaults = { setCard = true, showWatermark = false },
})

local gearCrafted
gearCrafted = Browser.Create({
    singularKey = "common.item_set",
    pluralKey = "features.collections_gear.crafted_sets",
    settingsKey = "gearCrafted",
    enumerateKeys = function() return EnumerateSetKeys(true) end,
    buildRecord = function(key, details) return BuildSetRecord(key, true, details, gearCrafted) end,
    isAcquiredKey = function() return true end,
    searchDialogName = "NCollections_COLLECTIONS_GEAR_CRAFTED_SEARCH",
    supportsActive = false,
    supportsActions = false,
    showPurchasable = false,
    extraDefaults = { setCard = true },
})

local PLAN_CRAFT_TYPES = {
    [CRAFTING_TYPE_WOODWORKING] = true, [CRAFTING_TYPE_BLACKSMITHING] = true,
    [CRAFTING_TYPE_CLOTHIER] = true, [CRAFTING_TYPE_ALCHEMY] = true,
    [CRAFTING_TYPE_ENCHANTING] = true, [CRAFTING_TYPE_PROVISIONING] = true,
    [CRAFTING_TYPE_JEWELRYCRAFTING] = true,
}

local function EncodeRecipeKey(listIndex, recipeIndex)
    return (listIndex * 10000) + recipeIndex
end

local function DecodeRecipeKey(key)
    return math.floor(key / 10000), key % 10000
end

local function RecipeBelongsToPage(pageKey, listIndex, specialType, stationType)
    if pageKey == "plans" then return listIndex >= 17 and PLAN_CRAFT_TYPES[stationType] == true end
    if listIndex >= 17 or stationType ~= CRAFTING_TYPE_PROVISIONING then return false end
    if pageKey == "food" then return specialType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES end
    return specialType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING
end

local function EnumerateRecipeKeys(pageKey)
    local keys = {}
    if not GetNumRecipeLists or not GetRecipeListInfo or not GetRecipeInfo then return keys end
    for listIndex = 1, GetNumRecipeLists() do
        local _, count = GetRecipeListInfo(listIndex)
        for recipeIndex = 1, count or 0 do
            local _, _, _, _, _, specialType, stationType = GetRecipeInfo(listIndex, recipeIndex)
            if RecipeBelongsToPage(pageKey, listIndex, specialType, stationType) then
                keys[#keys + 1] = EncodeRecipeKey(listIndex, recipeIndex)
            end
            Util.FrameTaskCheckpoint(recipeIndex, 1)
        end
    end
    return keys
end

local function IsRecipeKnown(key)
    if not GetRecipeInfo then return false end
    local listIndex, recipeIndex = DecodeRecipeKey(key)
    local known = GetRecipeInfo(listIndex, recipeIndex)
    return known == true
end

local function BuildRecipeRecord(key, includeDetails, feature)
    if not GetRecipeInfo then return nil end
    local listIndex, recipeIndex = DecodeRecipeKey(key)
    local known, recipeName, ingredientCount = GetRecipeInfo(listIndex, recipeIndex)
    local listName = GetRecipeListInfo and Format(SI_TOOLTIP_ITEM_NAME, GetRecipeListInfo(listIndex)) or NCollections.L("collections.recipes.items")
    local resultName = GetRecipeResultItemInfo and GetRecipeResultItemInfo(listIndex, recipeIndex) or recipeName
    local record = {
        collectibleId = key,
        name = Format(SI_TOOLTIP_ITEM_NAME, resultName and resultName ~= "" and resultName or recipeName),
        categoryName = listName,
        isAcquired = known == true,
    }
    if includeDetails and feature and feature.GetExtraSetting("recipeCard") then
        local lines = { NCollections.L("features.collections_recipes.ingredients_6a78277") }
        for ingredientIndex = 1, ingredientCount or 0 do
            local ingredientName, _, quantity = GetRecipeIngredientItemInfo and GetRecipeIngredientItemInfo(listIndex, recipeIndex, ingredientIndex)
            ingredientName = ingredientName and ingredientName ~= "" and Format(SI_TOOLTIP_ITEM_NAME, ingredientName) or NCollections.L("collections.recipes.unknown_ingredient")
            lines[#lines + 1] = string.format("• %s × %d", ingredientName, tonumber(quantity) or 0)
            Util.FrameTaskCheckpoint(ingredientIndex, 1)
        end
        record.description = table.concat(lines, "\n")
    end
    return record
end

local recipeFeatures = {}
local recipeDefinitions = {
    food = { singular = "collections.recipes.recipe", plural = "features.collections_recipes.food_recipes_ccd936f" },
    drink = { singular = "collections.recipes.recipe", plural = "features.collections_recipes.drink_recipes_3128a30" },
    plans = { singular = "collections.recipes.plan", plural = "features.collections_recipes.plans_cf2e5f2" },
}
for pageKey, definition in pairs(recipeDefinitions) do
    local currentPageKey = pageKey
    local feature
    feature = Browser.Create({
        singularKey = definition.singular,
        pluralKey = definition.plural,
        settingsKey = "recipes",
        enumerateKeys = function() return EnumerateRecipeKeys(currentPageKey) end,
        buildRecord = function(key, details) return BuildRecipeRecord(key, details, feature) end,
        isAcquiredKey = IsRecipeKnown,
        searchDialogName = "NCollections_COLLECTIONS_RECIPE_" .. NCollections.Util.Upper(currentPageKey) .. "_SEARCH",
        supportsActive = false,
        supportsActions = false,
        showPurchasable = false,
        extraDefaults = { recipeCard = true },
    })
    recipeFeatures[currentPageKey] = feature
end

local recipes = {}
function recipes.InitializeSavedVariables()
    for _, feature in pairs(recipeFeatures) do feature.InitializeSavedVariables() end
end
function recipes.Initialize()
    for _, feature in pairs(recipeFeatures) do feature.Initialize() end
end
function recipes.SetSettingsPanelVisible(pageKey)
    for key, feature in pairs(recipeFeatures) do feature.SetSettingsPanelVisible(key == pageKey) end
end

local recipeSettingsFeature = recipeFeatures.food
for _, method in ipairs({
    "GetHorizontalPosition", "GetVerticalPosition", "GetFontChoices", "GetFontChoiceNames", "GetFont",
    "GetScale", "GetScaleMin", "GetScaleMax", "GetBackgroundOpacity",
    "GetBackgroundOpacityMin", "GetBackgroundOpacityMax", "GetHorizontalPositionLabel",
    "GetHorizontalPositionTooltip", "GetVerticalPositionLabel", "GetVerticalPositionTooltip",
    "GetFontLabel", "GetFontTooltip", "GetScaleLabel", "GetScaleTooltip",
    "GetBackgroundOpacityLabel", "GetBackgroundOpacityTooltip",
}) do recipes[method] = recipeSettingsFeature[method] end
for _, method in ipairs({
    "SetHorizontalPosition", "SetVerticalPosition", "SetFont", "SetScale", "SetBackgroundOpacity",
}) do
    recipes[method] = function(value)
        for _, feature in pairs(recipeFeatures) do feature[method](value) end
    end
end
function recipes.GetRecipeCard() return recipeSettingsFeature.GetExtraSetting("recipeCard") end
function recipes.SetRecipeCard(value)
    for _, feature in pairs(recipeFeatures) do feature.SetExtraSetting("recipeCard", value == true) end
end
function recipes.GetRecipeCardLabel() return NCollections.L("features.collections_recipes.recipe_card_label") end
function recipes.GetRecipeCardTooltip() return NCollections.L("features.collections_recipes.recipe_card_tooltip") end

function gearSet.GetSetCard() return gearSet.GetExtraSetting("setCard") end
function gearSet.SetSetCard(value) gearSet.SetExtraSetting("setCard", value == true) end
function gearSet.GetSetCardLabel() return NCollections.L("features.collections_gear.set_card_label") end
function gearSet.GetSetCardTooltip() return NCollections.L("features.collections_gear.set_card_tooltip") end
function gearSet.GetShowWatermark() return gearSet.GetExtraSetting("showWatermark") end
function gearSet.SetShowWatermark(value) gearSet.SetExtraSetting("showWatermark", value == true) end
function gearSet.GetShowWatermarkDefault() return false end
function gearSet.GetShowWatermarkLabel() return NCollections.L("features.collections_gear.show_watermark_label") end
function gearSet.GetShowWatermarkTooltip() return NCollections.L("features.collections_gear.show_watermark_tooltip") end

NCollections.Features.CollectionsHousing = housing
NCollections.Features.CollectionsMounts = mounts
NCollections.Features.CollectionsSkins = skins
NCollections.Features.CollectionsGear = gearSet
NCollections.Features.CollectionsGearCrafted = gearCrafted
NCollections.Features.CollectionsRecipes = recipes
