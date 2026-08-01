-- CharacterMarkdown - Achievements Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectAchievementsData()
    -- Use API layer granular functions (composition at collector level)
    local points = CM.api.achievements.GetPoints()
    local recent = CM.api.achievements.GetRecent()

    -- Collect category data
    local categories = {}
    local numCategories = CM.api.achievements.GetNumCategories()

    for i = 1, numCategories do
        local info = CM.api.achievements.GetCategoryInfo(i)
        if info and info.name then
            local subcategories = {}
            if info.numSubCategories and info.numSubCategories > 0 then
                for j = 1, info.numSubCategories do
                    local subInfo = CM.api.achievements.GetSubCategoryInfo(i, j)
                    if subInfo and subInfo.name then
                        table.insert(subcategories, {
                            name = subInfo.name,
                            earned = subInfo.earned or 0,
                            total = subInfo.total or 0,
                            percent = (subInfo.total and subInfo.total > 0)
                                    and math.floor((subInfo.earned / subInfo.total) * 100)
                                or 0,
                        })
                    end
                end
            end

            table.insert(categories, {
                name = info.name,
                earned = info.earned or 0,
                total = info.total or 0,
                percent = (info.total and info.total > 0) and math.floor((info.earned / info.total) * 100) or 0,
                numAchievements = info.numAchievements or 0,
                subcategories = subcategories,
            })
        end
    end

    local achievements = {}

    -- Transform API data to expected format (backward compatibility)
    achievements.points = points.earned or 0
    achievements.total = points.total or 0
    achievements.recent = recent or {}
    achievements.categories = categories

    -- Add computed fields
    local totalAchievements = 0

    for _, cat in ipairs(categories) do
        totalAchievements = totalAchievements + (cat.numAchievements or 0)
    end

    achievements.summary = {
        completionPercent = achievements.total > 0 and math.floor((achievements.points / achievements.total) * 100)
            or 0,
        recentCount = recent and #recent or 0,
        categoryCount = #categories,
        totalAchievements = totalAchievements,
        earnedPoints = achievements.points,
        totalPoints = achievements.total,
    }

    return achievements
end

CM.collectors.CollectAchievementsData = CollectAchievementsData

CM.DebugPrint("COLLECTOR", "Achievements collector module loaded")
