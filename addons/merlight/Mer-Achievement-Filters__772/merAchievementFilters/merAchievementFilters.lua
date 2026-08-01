local myNAME = "merAchievementFilters"


local function df(fmt, ...)
    --d(zo_strformat(fmt, ...))
end


local function isAchievementPartiallyCompleted(id)
    local name, _, _, _, completed = GetAchievementInfo(id)
    while completed do
        id = GetNextAchievementInLine(id)
        if id == 0 then
            -- either this wasn't a line, or everything in it was completed
            return false
        end
        name, _, _, _, completed = GetAchievementInfo(id)
    end
    local totalCompleted = 0
    local totalRequired = 0
    local numCriteria = GetAchievementNumCriteria(id)
    for crit = 1, numCriteria do
        local _, numCompleted, numRequired = GetAchievementCriterion(id, crit)
        totalCompleted = totalCompleted + numCompleted
        totalRequired = totalRequired + numRequired
    end
    df("|caaaaaa<<1>>: <<2>> (<<3>>/<<4>>)", id, name, totalCompleted, totalRequired)
    return totalCompleted > 0 and totalCompleted < totalRequired
end


local function onAddOnLoaded(eventCode, addOnName)
    if addOnName ~= myNAME then return end
    EVENT_MANAGER:UnregisterForEvent(myNAME, EVENT_ADD_ON_LOADED)

    local comboBox = ZO_ComboBox_ObjectFromContainer(ACHIEVEMENTS.categoryFilter)
    local comboItems = comboBox:GetItems()
    local filterCallback = (comboItems[1] and comboItems[1].callback)
    if not filterCallback then return end

    -- Hook ZO_ShouldShowAchievement before adding any filters. This is
    -- a minor safety measure, because given an unrecognized filterType,
    -- it would bounce indefinitely on partially completed achievements.
    local zorgShouldShowAchievement = ZO_ShouldShowAchievement

    function ZO_ShouldShowAchievement(filterType, id)
        if filterType == SI_MER_ACHIEVEMENT_FILTER_SHOW_STARTED then
            return isAchievementPartiallyCompleted(id)
        elseif filterType == SI_MER_ACHIEVEMENT_FILTER_WITH_TITLE then
            return (GetAchievementRewardTitle(id))
        elseif filterType == SI_MER_ACHIEVEMENT_FILTER_WITH_DYE then
            return (GetAchievementRewardDye(id))
        elseif filterType == SI_MER_ACHIEVEMENT_FILTER_WITH_ITEM then
            return (GetAchievementRewardItem(id))
        else
            return zorgShouldShowAchievement(filterType, id)
        end
    end

    local function insertFilter(index, stringId)
        local name = GetString(stringId)
        local entry = comboBox:CreateItemEntry(name, filterCallback)
        entry.filterType = stringId
        table.insert(comboItems, index, entry)
    end

    for index, entry in ipairs(comboItems) do
        if entry.filterType == SI_ACHIEVEMENT_FILTER_SHOW_UNEARNED then
            -- insert STARTED before UNEARNED
            insertFilter(index, SI_MER_ACHIEVEMENT_FILTER_SHOW_STARTED)
            break -- out! or this loop would never end
        end
    end

    -- append additional filters in the order the reward types were introduced
    insertFilter(#comboItems + 1, SI_MER_ACHIEVEMENT_FILTER_WITH_TITLE)
    insertFilter(#comboItems + 1, SI_MER_ACHIEVEMENT_FILTER_WITH_DYE)
    insertFilter(#comboItems + 1, SI_MER_ACHIEVEMENT_FILTER_WITH_ITEM)

    comboBox:UpdateItems()
end


EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)
