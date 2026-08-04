-- CharacterMarkdown - API Layer - Achievements
-- Abstraction for achievement points and categories

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.achievements = {}

local api = CM.api.achievements

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetPoints()
    local earned = CM.SafeCall(GetEarnedAchievementPoints) or 0
    local total = CM.SafeCall(GetTotalAchievementPoints) or 0
    return {
        earned = earned,
        total = total,
    }
end

function api.GetNumCategories()
    return CM.SafeCall(GetNumAchievementCategories) or 0
end

function api.GetCategoryInfo(catIndex)
    local success, name, numSubCats, numAch, earned, total, hidesPoints =
        CM.SafeCallMulti(GetAchievementCategoryInfo, catIndex)

    return {
        name = name,
        earned = earned,
        total = total,
        numSubCategories = numSubCats,
        numAchievements = numAch,
    }
end

function api.GetSubCategoryInfo(catIndex, subCatIndex)
    local success, name, numAch, earned, total = CM.SafeCallMulti(GetAchievementSubCategoryInfo, catIndex, subCatIndex)
    return {
        name = name,
        earned = earned,
        total = total,
        numAchievements = numAch,
    }
end

function api.GetRecent()
    local success, id1, id2, id3, id4, id5 = CM.SafeCallMulti(GetRecentlyCompletedAchievements, 5)
    local ids = {}
    if success then
        for _, id in ipairs({ id1, id2, id3, id4, id5 }) do
            if id and type(id) == "number" then
                table.insert(ids, id)
            end
        end
    end
    local recent = {}
    for _, id in ipairs(ids) do
        if type(id) == "number" then
            local ok, name, desc, points, icon, completed, date, time = CM.SafeCallMulti(GetAchievementInfo, id)
            if name then
                table.insert(recent, {
                    id = id,
                    name = name,
                    date = date,
                    time = time,
                })
            end
        end
    end
    return recent
end

---Optional criterion detail for a single achievement (P50 GetAchievementCriterion / Progress).
function api.GetAchievementDetail(achievementId)
    if not achievementId then
        return nil
    end
    local ok, name, description, points, icon, completed =
        CM.SafeCallMulti(GetAchievementInfo, achievementId)
    if not ok or not name then
        return nil
    end

    local progress = nil
    if GetAchievementProgress then
        progress = CM.SafeCall(GetAchievementProgress, achievementId)
    end

    local criteria = {}
    local numCriteria = CM.SafeCall(GetAchievementNumCriteria, achievementId) or 0
    for i = 1, numCriteria do
        local cok, descriptionText, numCompleted, numRequired =
            CM.SafeCallMulti(GetAchievementCriterion, achievementId, i)
        if cok and descriptionText then
            table.insert(criteria, {
                description = descriptionText,
                completed = numCompleted or 0,
                required = numRequired or 0,
            })
        end
    end

    local timestamp = nil
    if GetAchievementTimestamp then
        timestamp = CM.SafeCall(GetAchievementTimestamp, achievementId)
    end

    return {
        id = achievementId,
        name = name,
        description = description,
        points = points,
        completed = completed,
        progress = progress,
        criteria = criteria,
        timestamp = timestamp,
    }
end
