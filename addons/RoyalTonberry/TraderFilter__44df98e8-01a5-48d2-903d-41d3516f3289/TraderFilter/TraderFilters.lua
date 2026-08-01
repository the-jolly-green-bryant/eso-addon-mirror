local ADDON_NAME = 'TraderFilter'
local TraderFilter = TraderFilter or {}

---------------------------------------------------------
-- FILTER LOGIC
---------------------------------------------------------
function TraderFilter.filterKnownRecipes(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    local itemType = GetItemLinkItemType(itemData.itemLink)
    if itemType == ITEMTYPE_RECIPE then
        return IsItemLinkRecipeKnown(itemData.itemLink)
    end
    return false
end

function TraderFilter.filterKnownMotifs(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    local itemType = GetItemLinkItemType(itemData.itemLink)
    if itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        return IsItemLinkBookKnown(itemData.itemLink)
    end
    return false
end

function TraderFilter.filterKnownStylePages(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    local itemType = GetItemLinkItemType(itemData.itemLink)
    if itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_COLLECTIBLE or itemType == ITEMTYPE_STYLE_PAGE then
        local collectibleId = GetItemLinkContainerCollectibleId(itemData.itemLink)
        if collectibleId and collectibleId > 0 then
            return IsCollectibleOwnedByDefId(collectibleId)
        end
    end
    return false
end

function TraderFilter.filterCollectedGear(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    if IsItemLinkSetCollectionPiece(itemData.itemLink) then
        local hasSet = GetItemLinkSetInfo(itemData.itemLink)
        if not hasSet then return false end
        local itemId = GetItemLinkItemId(itemData.itemLink)
        if not itemId or itemId == 0 then return false end
        return IsItemSetCollectionPieceUnlocked(itemId)
    end
    return false
end

function TraderFilter.filterCompanionGear(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    if GetItemLinkActorCategory(itemData.itemLink) == GAMEPLAY_ACTOR_CATEGORY_COMPANION then
        local itemType = GetItemLinkItemType(itemData.itemLink)
        if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_JEWELRY or itemType == ITEMTYPE_WEAPON then
            if not IsItemLinkSetCollectionPiece(itemData.itemLink) then return true end
        end
    end
    return false
end

function TraderFilter.filterNonCollectionsGear(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    if GetItemLinkActorCategory(itemData.itemLink) ~= GAMEPLAY_ACTOR_CATEGORY_COMPANION then
        local itemType = GetItemLinkItemType(itemData.itemLink)
        if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_JEWELRY or itemType == ITEMTYPE_WEAPON then
            if not IsItemLinkSetCollectionPiece(itemData.itemLink) then return true end
        end
    end

    return false
end

function TraderFilter.filterTreasureMaps(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    local itemType, specializedType = GetItemLinkItemType(itemData.itemLink)

    if itemType == ITEMTYPE_TROPHY and specializedType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP then return true end
    return false
end

function TraderFilter.filterSurveys(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    local itemType, specializedType = GetItemLinkItemType(itemData.itemLink)
    local unopened_ids = {
        [219853] = true, --alchemist
        [219849] = true, --blacksmith
        [219850] = true, --clother
        [219852] = true, --enchanter
        [219854] = true, --jewlery
        [219851] = true, --woodworker
    }

    if itemType == ITEMTYPE_TROPHY and specializedType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then return true end
    if unopened_ids[tonumber(itemId)] then return true end
    return false
end

function TraderFilter.filterCollectedFragmentsAlt(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    --d("------filterCollectedFragmentsAlt------")
    local collectibleId = GetItemLinkContainerCollectibleId(itemData.itemLink)
    --d(itemData)
    --d(collectibleId)
    if collectibleId ~= nil and collectibleId > 0 then
        local collectibleCategory = GetCollectibleCategoryType(collectibleId)
        --d(collectibleCategory)
        if IsCollectibleOwnedByDefId(collectibleId) then
            --d("collected 1")
            return true
        elseif collectibleCategory == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT and not CanCombinationFragmentBeUnlocked(collectibleId) then
--            d("collected 2")
            return true
        end
        local achievementId = GetCollectibleLinkedAchievement(collectibleId)
--        d(achievementId)
        local _, _, _, _, completed, _, _ = GetAchievementInfo(achievementId)
--        d(completed)
        if completed then
            return true
        end
    end

    return false
end

function TraderFilter.filterAchievementScraperItems(itemData, itemId)
    if TraderFilter.achievementScraper and TraderFilter.achievementScraper.hide[itemData.name] then return true end
    return TraderFilter.filterCollectedFragments(itemData, itemId)
end

function TraderFilter.filterCollectedFragments(itemData, itemId)
    if not itemData.itemLink or itemData.itemLink == "" then return false end
    --d("------filterCollectedFragments------")
    local collectibleId = GetCollectibleIdFromLink(itemData.itemLink)
--    d(itemData)
--    d(collectibleId)
--    d(collectibleId2)
    if collectibleId ~= nil and collectibleId > 0 then
        local collectibleCategory = GetCollectibleCategoryType(collectibleId)
        --d(collectibleCategory)
        if IsCollectibleOwnedByDefId(collectibleId) then
            --d("collected 1")
            return true
        elseif collectibleCategory == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT and not CanCombinationFragmentBeUnlocked(collectibleId) then
--            d("collected 2")
            return true
        end
        local achievementId = GetCollectibleLinkedAchievement(collectibleId)
        --d(achievementId)
        local _, _, _, _, completed, _, _ = GetAchievementInfo(achievementId)
--        d(completed)
        if completed then
            return true
        end
    end

    return TraderFilter.filterCollectedFragmentsAlt(itemData, itemId)
end

_G[ADDON_NAME] = TraderFilter