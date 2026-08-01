--- @class (partial) CollectiblesTrackerAllTheThings
--- Keyboard icon paths for Collectibles Tracker source labels (verified *_up.dds in eso_esoui_art_texturelist).
---
local CollectiblesTrackerAllTheThings = CollectiblesTrackerAllTheThings

local TREE_ICONS = "EsoUI/Art/TreeIcons/"
local COLLECTIONS_ART = "EsoUI/Art/Collections/"

CollectiblesTrackerAllTheThings.COLLECTIBLE_CATEGORY_TYPE_KEYBOARD_ICON_UP =
{
    [COLLECTIBLE_CATEGORY_TYPE_DLC] = COLLECTIONS_ART .. "collections_tabIcon_DLC_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_MOUNT] = TREE_ICONS .. "store_indexicon_mounts_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_VANITY_PET] = TREE_ICONS .. "store_indexicon_vanitypets_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_COSTUME] = TREE_ICONS .. "store_indexicon_costumes_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_MEMENTO] = TREE_ICONS .. "collection_indexicon_allies_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_UPGRADE] = TREE_ICONS .. "collection_indexicon_upgrade_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_ACCOUNT_SERVICE] = TREE_ICONS .. "collection_indexicon_service_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_ASSISTANT] = TREE_ICONS .. "collection_indexicon_assistants_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_PERSONALITY] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_HAT] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_SKIN] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_POLYMORPH] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_HAIR] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING] = TREE_ICONS .. "collection_indexicon_styleparlor_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_HOUSE] = TREE_ICONS .. "collection_indexicon_housing_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_FURNITURE] = TREE_ICONS .. "collection_indexicon_furnishings_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_EMOTE] = TREE_ICONS .. "collection_indexicon_customaction_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_CHAPTER] = COLLECTIONS_ART .. "collections_tabIcon_DLC_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_OUTFIT_STYLE] = COLLECTIONS_ART .. "collections_tabIcon_outfitStyles_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_HOUSE_BANK] = TREE_ICONS .. "collection_indexicon_housing_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT] = TREE_ICONS .. "store_indexicon_fragments_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_COMPANION] = TREE_ICONS .. "collection_indexicon_companions_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_TRIBUTE_PATRON] = COLLECTIONS_ART .. "collections_tabIcon_tributePatrons_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE] = TREE_ICONS .. "collection_indexicon_abilityskins_up.dds",
    [COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE] = TREE_ICONS .. "collection_indexicon_abilityskins_up.dds",
}

local collectibleCategoryTypeKeyboardIconByType = nil

local function NormalizeCollectibleCategoryKeyboardIconPath(iconPath)
    if (type(iconPath) ~= "string") then
        return nil
    end

    iconPath = iconPath:gsub("\\", "/")
    if (iconPath == "") then
        return nil
    end

    local lowerPath = zo_strformat("<<z:1>>", iconPath)
    if (lowerPath:find("_disabled%.dds", 1, true)) then
        return nil
    end

    return iconPath
end

function CollectiblesTrackerAllTheThings.IsValidCategorySourceLabelIconPath(iconPath)
    iconPath = NormalizeCollectibleCategoryKeyboardIconPath(iconPath)
    if (iconPath == nil) then
        return false
    end
    return true
end

local function CategoryTreeNameMatchesCollectibleCategoryType(treeName, categoryType)
    if (treeName == nil or treeName == "") then
        return false
    end
    local categoryLabel = GetString("SI_COLLECTIBLECATEGORYTYPE", categoryType)
    return zo_strformat("<<z:1>>", treeName) == zo_strformat("<<z:1>>", categoryLabel)
end

local function AssignIconForTreeName(iconByCategoryType, treeName, normalIcon)
    normalIcon = NormalizeCollectibleCategoryKeyboardIconPath(normalIcon)
    if (normalIcon == nil) then
        return
    end

    for categoryType = COLLECTIBLE_CATEGORY_TYPE_ITERATION_BEGIN, COLLECTIBLE_CATEGORY_TYPE_ITERATION_END do
        if (CategoryTreeNameMatchesCollectibleCategoryType(treeName, categoryType)) then
            iconByCategoryType[categoryType] = normalIcon
        end
    end
end

local function BuildNameMatchedCollectibleCategoryTypeIconMap()
    local iconByCategoryType = {}

    for topLevelIndex = 1, GetNumCollectibleCategories() do
        local topLevelName = GetCollectibleCategoryInfo(topLevelIndex)
        local numSubcategories = GetNumSubcategoriesInCollectibleCategory(topLevelIndex)

        if (numSubcategories == 0) then
            local normalIcon = GetCollectibleCategoryKeyboardIcons(topLevelIndex, nil)
            AssignIconForTreeName(iconByCategoryType, topLevelName, normalIcon)
        else
            for subcategoryIndex = 1, numSubcategories do
                local subcategoryName = GetCollectibleSubCategoryInfo(topLevelIndex, subcategoryIndex)
                local normalIcon = GetCollectibleCategoryKeyboardIcons(topLevelIndex, subcategoryIndex)
                AssignIconForTreeName(iconByCategoryType, subcategoryName, normalIcon)
            end
        end
    end

    return iconByCategoryType
end

function CollectiblesTrackerAllTheThings.GetCollectibleCategoryTypeKeyboardIconMap()
    if (collectibleCategoryTypeKeyboardIconByType == nil) then
        local mergedIconByCategoryType = BuildNameMatchedCollectibleCategoryTypeIconMap()
        local staticIconByCategoryType = CollectiblesTrackerAllTheThings.COLLECTIBLE_CATEGORY_TYPE_KEYBOARD_ICON_UP

        for categoryType, iconPath in pairs(staticIconByCategoryType) do
            local mergedPath = mergedIconByCategoryType[categoryType]
            if (not CollectiblesTrackerAllTheThings.IsValidCategorySourceLabelIconPath(mergedPath)) then
                mergedPath = nil
                mergedIconByCategoryType[categoryType] = nil
            end
            if (mergedPath == nil) then
                local normalizedPath = NormalizeCollectibleCategoryKeyboardIconPath(iconPath)
                if (normalizedPath ~= nil) then
                    mergedIconByCategoryType[categoryType] = normalizedPath
                end
            end
        end

        collectibleCategoryTypeKeyboardIconByType = mergedIconByCategoryType
    end

    return collectibleCategoryTypeKeyboardIconByType
end

function CollectiblesTrackerAllTheThings.GetCollectibleCategoryTypeKeyboardIcon(categoryType)
    if (categoryType == COLLECTIBLE_CATEGORY_TYPE_INVALID) then
        return CollectiblesTrackerAllTheThings.INVALID_CATEGORY_SOURCE_ICON
    end
    return CollectiblesTrackerAllTheThings.GetCollectibleCategoryTypeKeyboardIconMap()[categoryType]
end

function CollectiblesTrackerAllTheThings.FormatInvalidCategorySourceLabel(labelText)
    local iconPath = CollectiblesTrackerAllTheThings.INVALID_CATEGORY_SOURCE_ICON
    local iconSize = CollectiblesTrackerAllTheThings.INVALID_CATEGORY_SOURCE_LABEL_ICON_SIZE
    local iconMarkup = ZO_ERROR_COLOR:Colorize(zo_iconFormatInheritColor(iconPath, iconSize, iconSize))
    local formattedLabel = ZO_ERROR_COLOR:Colorize(labelText)
    return zo_strformat("<<1>> <<2>>", iconMarkup, formattedLabel)
end

function CollectiblesTrackerAllTheThings.FormatCategorySourceLabel(categoryType, labelText)
    if (categoryType == COLLECTIBLE_CATEGORY_TYPE_INVALID) then
        return CollectiblesTrackerAllTheThings.FormatInvalidCategorySourceLabel(labelText)
    end
    local iconPath = CollectiblesTrackerAllTheThings.GetCollectibleCategoryTypeKeyboardIcon(categoryType)
    return CollectiblesTrackerAllTheThings.FormatWhiteCategorySourceLabel(labelText, iconPath)
end

function CollectiblesTrackerAllTheThings.FormatWhiteCategorySourceLabel(labelText, iconPath)
    local formattedLabel = zo_strformat("|cFFFFFF<<1>>|r", labelText)
    local iconSize = CollectiblesTrackerAllTheThings.CATEGORY_SOURCE_LABEL_ICON_SIZE

    if (CollectiblesTrackerAllTheThings.IsValidCategorySourceLabelIconPath(iconPath)) then
        iconPath = NormalizeCollectibleCategoryKeyboardIconPath(iconPath)
        local iconMarkup = zo_iconFormatInheritColor(iconPath, iconSize, iconSize)
        return string.format("%s %s", iconMarkup, formattedLabel)
    end

    return formattedLabel
end
