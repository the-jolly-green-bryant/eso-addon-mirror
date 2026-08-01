if not VOTANS_ACHIEVEMENT_FAVORITES then return end

local compatibility = {
    VotansFavorites = "VotansFavorites"
}

local SUMMARY_ICONS =
{
    "esoui/art/market/keyboard/giftmessageicon_up.dds",
    "esoui/art/market/keyboard/giftmessageicon_down.dds",
    "esoui/art/market/keyboard/giftmessageicon_over.dds",
}

function compatibility:AddTopLevelCategory(self)
    local lookup, tree = self.nodeLookupData, self.categoryTree
    local normalIcon, pressedIcon, mouseoverIcon = unpack(SUMMARY_ICONS)
    local parentNode = self:AddCategory(lookup, tree, "ZO_IconChildlessHeader", nil, VotansFavorites, "Favorites", false, normalIcon, pressedIcon, mouseoverIcon, true, true)
end

function compatibility:GetCategoryInfoFromData(ACHIEVEMENTS, data, parentData)
    local numAchievements, earnedPoints, totalPoints = 0, 0, 0
    local favorites, GetAchievementInfo = VOTANS_ACHIEVEMENT_FAVORITES.favorites, GetAchievementInfo
    local id, points, _, completed
    for id in pairs(favorites) do
        numAchievements = numAchievements + 1
        points, _, completed = select(3, GetAchievementInfo(id))
        totalPoints = totalPoints + points
        if completed then earnedPoints = earnedPoints + points end
    end
    local hidesPoints = totalPoints == 0
    return numAchievements, earnedPoints, totalPoints, hidesPoints
end

function compatibility:ZO_GetAchievementIds(categoryIndex, subcategoryIndex, numAchievements, considerSearchResult)
    local result = { }
    local searchResults = considerSearchResults and ACHIEVEMENTS_MANAGER:GetSearchResults()
    if searchResults then
        local GetCategoryInfoFromAchievementId = GetCategoryInfoFromAchievementId
        local categoryIndex, subcategoryIndex, achievementIndex, searchResult
        for id in pairs(VOTANS_ACHIEVEMENT_FAVORITES.favorites) do
            categoryIndex, subcategoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)
            searchResult = searchResults[categoryIndex]
            if searchResult then
                searchResult = searchResult[subcategoryIndex or ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY]
                if searchResult and searchResult[achievementIndex] then
                    result[#result + 1] = id
                end
            end
        end
    else
        for id in pairs(VOTANS_ACHIEVEMENT_FAVORITES.favorites) do
            result[#result + 1] = id
        end
    end
    table.sort(result, sortByName)
    return result
end

QUANTUMPIES_GA_COMPATIBILITY_VOTANS_FAV = compatibility