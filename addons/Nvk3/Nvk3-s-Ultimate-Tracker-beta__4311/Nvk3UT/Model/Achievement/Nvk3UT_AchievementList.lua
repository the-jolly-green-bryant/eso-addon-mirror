-- Model/Achievement/Nvk3UT_AchievementList.lua
-- Thin raw list provider for achievement entries used by trackers and models.

Nvk3UT = Nvk3UT or {}
Nvk3UT.AchievementList = Nvk3UT.AchievementList or {}

local AchievementList = Nvk3UT.AchievementList

local rawData

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end

    local result = {}
    for key, val in pairs(value) do
        result[key] = DeepCopy(val)
    end
    return result
end

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local root = Nvk3UT
    if root and type(root.IsDebugEnabled) == "function" then
        return root:IsDebugEnabled()
    end
    return false
end

local function emitDebugMessage(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local Utils = Nvk3UT and Nvk3UT.Utils
    local ok, message = pcall(string.format, fmt, ...)
    if not ok then
        message = tostring(fmt)
    end

    if Utils and Utils.d then
        Utils.d("[Nvk3UT][AchievementList] %s", message)
    elseif d then
        d(string.format("[Nvk3UT][AchievementList] %s", message))
    end
end

local function SafeCall(func, ...)
    if type(func) ~= "function" then
        return nil
    end

    local ok, value = pcall(func, ...)
    if ok then
        return value
    end

    return nil
end

local function SafeCallMulti(func, ...)
    if type(func) ~= "function" then
        return nil
    end

    local results = { pcall(func, ...) }
    if not results[1] then
        return nil
    end

    table.remove(results, 1)
    return unpack(results)
end

local function FormatDisplayString(text)
    if text == nil then
        return nil
    end

    if type(text) ~= "string" then
        return text
    end

    if text == "" then
        return ""
    end

    if type(ZO_CachedStrFormat) == "function" then
        local ok, formatted = pcall(ZO_CachedStrFormat, "<<1>>", text)
        if ok and formatted ~= nil then
            return formatted
        end
    end

    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", text)
        if ok and formatted ~= nil then
            return formatted
        end
    end

    return text
end

local function NormalizeAchievementId(value)
    if type(value) == "number" then
        return value
    end

    if type(value) == "string" then
        local numeric = tonumber(value)
        if numeric then
            return numeric
        end
    end

    return nil
end

local function BuildFavoriteScopes()
    local scope = "account"
    local general = Nvk3UT and Nvk3UT.sv and Nvk3UT.sv.General
    if general and type(general.favScope) == "string" and general.favScope ~= "" then
        scope = general.favScope
    end

    local ordered = {}
    local seen = {}

    local function addScope(value)
        if not value or seen[value] then
            return
        end
        seen[value] = true
        ordered[#ordered + 1] = value
    end

    addScope(scope)
    addScope("account")
    addScope("character")

    return ordered
end

local function CollectFavoriteIds()
    local Fav = Nvk3UT and Nvk3UT.FavoritesData
    if not (Fav and Fav.GetAllFavorites) then
        return {}
    end

    local scopes = BuildFavoriteScopes()
    local lookup = {}
    local ids = {}

    for index = 1, #scopes do
        local scope = scopes[index]
        local iterator, state, key = Fav.GetAllFavorites(scope)
        if type(iterator) == "function" then
            for rawId, flagged in iterator, state, key do
                if flagged then
                    local normalizedId = NormalizeAchievementId(rawId)
                    if normalizedId then
                        if not lookup[normalizedId] then
                            lookup[normalizedId] = true
                            ids[#ids + 1] = normalizedId
                        end
                    else
                        emitDebugMessage(
                            "Skipping invalid favorite id %s (scope=%s)",
                            tostring(rawId),
                            tostring(scope)
                        )
                    end
                end
            end
        else
            emitDebugMessage("Unable to iterate favorites for scope %s", tostring(scope))
        end
    end

    return ids
end

local function CollectRecentIds()
    local RecentData = Nvk3UT and Nvk3UT.RecentData
    if not RecentData then
        return {}
    end

    local result
    if type(RecentData.ListConfigured) == "function" then
        local ok, list = pcall(RecentData.ListConfigured)
        if ok and type(list) == "table" then
            result = list
        end
    end

    if not result and type(RecentData.List) == "function" then
        local ok, list = pcall(RecentData.List)
        if ok and type(list) == "table" then
            result = list
        end
    end

    if type(result) ~= "table" then
        return {}
    end

    local copy = {}
    for index = 1, #result do
        copy[index] = result[index]
    end

    return copy
end

local function CollectTodoData()
    local Todo = Nvk3UT and Nvk3UT.TodoData
    if not Todo then
        return {}, {}, {}, {}
    end

    local todoIds = {}
    if type(Todo.ListAllOpen) == "function" then
        local ok, list = pcall(Todo.ListAllOpen, nil, false)
        if ok and type(list) == "table" then
            todoIds = list
        end
    end

    local todoNames, todoKeys, todoTopIds = {}, {}, {}
    if type(Todo.GetSubcategoryList) == "function" then
        local ok, names, keys, topIds = pcall(Todo.GetSubcategoryList)
        if ok then
            if type(names) == "table" then
                todoNames = names
            end
            if type(keys) == "table" then
                todoKeys = keys
            end
            if type(topIds) == "table" then
                todoTopIds = topIds
            end
        end
    end

    return todoIds, todoNames, todoKeys, todoTopIds
end

local function BuildObjectiveData(achievementId)
    local objectives = {}

    local numCriteria = SafeCall(GetAchievementNumCriteria, achievementId)
    if not numCriteria or numCriteria <= 0 then
        return objectives
    end

    for criterionIndex = 1, numCriteria do
        local description, numCompleted, numRequired, isFailCondition, isVisible, isComplete = SafeCallMulti(
            GetAchievementCriterion,
            achievementId,
            criterionIndex
        )

        description = FormatDisplayString(description)

        objectives[#objectives + 1] = {
            description = description,
            current = numCompleted,
            max = numRequired,
            isComplete = isComplete
                or (numRequired ~= nil and numRequired > 0 and numCompleted ~= nil and numCompleted >= numRequired)
                or false,
            isFailCondition = isFailCondition or false,
            isVisible = isVisible ~= false,
        }
    end

    return objectives
end

local function DetermineCategoryInfo(categoryIndex, subCategoryIndex, achievementIndex)
    if not categoryIndex then
        return nil
    end

    local categoryName
    if GetAchievementCategoryInfo then
        local infoName = SafeCallMulti(GetAchievementCategoryInfo, categoryIndex)
        if infoName ~= nil then
            categoryName = FormatDisplayString(infoName)
        end
    end

    local subCategoryName
    if subCategoryIndex and GetAchievementSubCategoryInfo then
        local infoName = SafeCallMulti(GetAchievementSubCategoryInfo, categoryIndex, subCategoryIndex)
        if infoName ~= nil then
            subCategoryName = FormatDisplayString(infoName)
        end
    end

    return {
        categoryIndex = categoryIndex,
        subCategoryIndex = subCategoryIndex,
        achievementIndex = achievementIndex,
        categoryName = categoryName,
        subCategoryName = subCategoryName,
    }
end

local function BuildAchievementEntry(baseAchievementId, stageInfo)
    local targetAchievementId = stageInfo and stageInfo.displayId or baseAchievementId
    if not targetAchievementId then
        return nil
    end

    local name
    local description
    local points
    local icon
    local isComplete
    local completedTimestamp

    if GetAchievementInfo then
        local ok, infoName, infoDescription, infoPoints, infoIcon, infoCompleted, infoDate, infoTimeStamp = pcall(
            GetAchievementInfo,
            targetAchievementId
        )
        if ok then
            name = infoName
            description = infoDescription
            points = infoPoints
            icon = infoIcon
            isComplete = infoCompleted
            completedTimestamp = infoTimeStamp or infoDate
        end
    end

    local Completed = Nvk3UT and Nvk3UT.CompletedData
    if Completed then
        local meta
        if type(Completed.GetCompletedMeta) == "function" then
            local ok, result = pcall(Completed.GetCompletedMeta, targetAchievementId)
            if ok and type(result) == "table" then
                meta = result
            end
        end

        if (not meta) and type(Completed.IsCompleted) == "function" then
            local ok, completed = pcall(Completed.IsCompleted, targetAchievementId)
            if ok and completed ~= nil then
                meta = meta or {}
                meta.isComplete = completed and true or false
            end
        end

        if meta and meta.isComplete ~= nil then
            isComplete = meta.isComplete and true or false
        end

        if meta and meta.timestamp ~= nil then
            completedTimestamp = meta.timestamp
        elseif type(Completed.GetCompletedTimestamp) == "function" then
            local ok, ts = pcall(Completed.GetCompletedTimestamp, targetAchievementId)
            if ok and ts ~= nil then
                completedTimestamp = ts
            end
        end

        if meta and meta.points ~= nil and points == nil then
            points = meta.points
        end
    end

    name = FormatDisplayString(name)
    description = FormatDisplayString(description)

    local current
    local maximum
    local progressPercent

    if GetAchievementProgress then
        local ok, completed, total = pcall(GetAchievementProgress, targetAchievementId)
        if ok then
            current = completed
            maximum = total
            if total and total > 0 and completed then
                local percent = (completed / total) * 100
                if zo_roundToNearest then
                    progressPercent = zo_roundToNearest(percent, 0.1)
                else
                    progressPercent = math.floor(percent * 10 + 0.5) / 10
                end
            end
        end
    end

    local objectives = BuildObjectiveData(targetAchievementId)

    local timestamp = completedTimestamp or SafeCall(GetAchievementTimestamp, targetAchievementId)

    local categoryIndex
    local subCategoryIndex
    local achievementIndex

    if GetCategoryInfoFromAchievementId then
        categoryIndex, subCategoryIndex, achievementIndex = SafeCallMulti(GetCategoryInfoFromAchievementId, targetAchievementId)
    end

    local categoryInfo = DetermineCategoryInfo(categoryIndex, subCategoryIndex, achievementIndex)

    if (not categoryInfo or not categoryInfo.categoryName) and GetAchievementCategoryInfoFromAchievementId then
        local ok, fallbackCategoryIndex, fallbackSubCategoryIndex =
            pcall(GetAchievementCategoryInfoFromAchievementId, targetAchievementId)
        if ok then
            categoryInfo = DetermineCategoryInfo(
                fallbackCategoryIndex,
                fallbackSubCategoryIndex,
                achievementIndex
            )
        end
    end

    local entry = {
        id = baseAchievementId,
        displayAchievementId = targetAchievementId ~= baseAchievementId and targetAchievementId or nil,
        name = (name and name ~= "" and name) or string.format("Achievement %d", targetAchievementId),
        description = description,
        icon = icon,
        points = points,
        progress = {
            current = current,
            max = maximum,
            percent = progressPercent,
        },
        objectives = objectives,
        earnedTimestamp = timestamp,
        flags = {
            isComplete = isComplete == true,
            isTracked = true,
            isFavorite = true,
        },
        category = categoryInfo,
        stage = stageInfo,
    }

    return entry
end

local function SortAchievements(entries)
    table.sort(entries, function(left, right)
        local leftCategory = left.category or {}
        local rightCategory = right.category or {}

        local leftCategoryIndex = leftCategory.categoryIndex
        local rightCategoryIndex = rightCategory.categoryIndex
        if leftCategoryIndex ~= rightCategoryIndex then
            if leftCategoryIndex == nil then
                return false
            elseif rightCategoryIndex == nil then
                return true
            end
            return leftCategoryIndex < rightCategoryIndex
        end

        local leftSubCategoryIndex = leftCategory.subCategoryIndex
        local rightSubCategoryIndex = rightCategory.subCategoryIndex
        if leftSubCategoryIndex ~= rightSubCategoryIndex then
            if leftSubCategoryIndex == nil then
                return false
            elseif rightSubCategoryIndex == nil then
                return true
            end
            return leftSubCategoryIndex < rightSubCategoryIndex
        end

        local leftAchievementIndex = leftCategory.achievementIndex
        local rightAchievementIndex = rightCategory.achievementIndex
        if leftAchievementIndex ~= rightAchievementIndex then
            if leftAchievementIndex == nil then
                return false
            elseif rightAchievementIndex == nil then
                return true
            end
            return leftAchievementIndex < rightAchievementIndex
        end

        if left.name ~= right.name then
            return (left.name or "") < (right.name or "")
        end

        return (left.id or 0) < (right.id or 0)
    end)
end

local function ResolveStageInfo(achievementId)
    local Fav = Nvk3UT and Nvk3UT.FavoritesData
    if not (Fav and Fav.GetStageDisplayInfo) then
        return nil
    end

    local ok, info = pcall(Fav.GetStageDisplayInfo, achievementId)
    if ok then
        return info
    end

    return nil
end

local function BuildRawData()
    local favoriteIds = CollectFavoriteIds()
    local recentIds = CollectRecentIds()
    local todoIds, todoNames, todoKeys, todoTopIds = CollectTodoData()
    local entries = {}
    local completeCount = 0

    for index = 1, #favoriteIds do
        local achievementId = favoriteIds[index]
        local stageInfo = ResolveStageInfo(achievementId)
        local entry = BuildAchievementEntry(achievementId, stageInfo)
        if entry then
            entries[#entries + 1] = entry
            if entry.flags.isComplete then
                completeCount = completeCount + 1
            end

            local category = entry.category or {}
            emitDebugMessage(
                "Favorite entry %d (cat=%s sub=%s ach=%s)",
                achievementId,
                tostring(category.categoryIndex),
                tostring(category.subCategoryIndex),
                tostring(category.achievementIndex)
            )
        end
    end

    SortAchievements(entries)

    local todoTotal = (type(todoIds) == "table") and #todoIds or 0

    return {
        achievements = entries,
        total = #entries,
        totalComplete = completeCount,
        totalIncomplete = #entries - completeCount,
        hasIncomplete = (#entries - completeCount) > 0,
        favoriteIds = favoriteIds,
        recentIds = recentIds,
        recentTotal = #recentIds,
        todoIds = todoIds,
        todoTotal = todoTotal,
        todoNames = todoNames,
        todoKeys = todoKeys,
        todoTopIds = todoTopIds,
    }
end

function AchievementList:Init()
    rawData = nil
end

function AchievementList:RefreshFromGame()
    emitDebugMessage("RefreshFromGame start")
    rawData = BuildRawData()
    emitDebugMessage(
        "RefreshFromGame done (favorites=%d complete=%d incomplete=%d recent=%d todo=%d)",
        rawData.total or 0,
        rawData.totalComplete or 0,
        rawData.totalIncomplete or 0,
        rawData.recentTotal or (rawData.recentIds and #rawData.recentIds) or 0,
        rawData.todoTotal or (rawData.todoIds and #rawData.todoIds) or 0
    )
    return rawData
end

function AchievementList:GetRaw()
    if not rawData then
        return self:RefreshFromGame()
    end
    return rawData
end

function AchievementList:GetSection(name)
    if name == "favorites" then
        local raw = self:GetRaw()
        if not raw then
            return nil
        end
        return {
            ids = raw.favoriteIds,
            total = raw.total,
            complete = raw.totalComplete,
            incomplete = raw.totalIncomplete,
        }
    end

    if name == "recent" then
        local raw = self:GetRaw()
        if not raw then
            return nil
        end
        return {
            ids = raw.recentIds,
            total = raw.recentTotal,
        }
    end

    if name == "todo" then
        local raw = self:GetRaw()
        if not raw then
            return nil
        end
        return {
            ids = raw.todoIds,
            total = raw.todoTotal,
            names = raw.todoNames,
            keys = raw.todoKeys,
            topIds = raw.todoTopIds,
        }
    end

    return nil
end

function AchievementList.ApplyCacheSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end

    rawData = DeepCopy(snapshot)
    return true
end

function AchievementList.ExportCacheSnapshot()
    if type(rawData) ~= "table" then
        return nil
    end

    return DeepCopy(rawData)
end

return AchievementList
