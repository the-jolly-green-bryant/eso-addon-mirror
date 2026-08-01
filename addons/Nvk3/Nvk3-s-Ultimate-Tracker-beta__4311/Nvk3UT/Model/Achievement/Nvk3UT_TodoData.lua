-- Model/Achievement/Nvk3UT_TodoData.lua
-- Aggregates "To-Do" achievement candidates (open achievements) from the base game APIs.

Nvk3UT = Nvk3UT or {}

local TodoData = {}
Nvk3UT.TodoData = TodoData

local Utils = Nvk3UT and Nvk3UT.Utils

local EMPTY_TABLE = {}

local cachedAllOpen
local cachedNames
local cachedKeys
local cachedTopIds
local cachedListsByTop = {}
local cachedPointsByTop = {}

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

local function invalidateCache()
    cachedAllOpen = nil
    cachedNames = nil
    cachedKeys = nil
    cachedTopIds = nil
    cachedListsByTop = {}
    cachedPointsByTop = {}
end

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils:IsDebugEnabled()
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

    local ok, message = pcall(string.format, fmt, ...)
    if not ok then
        message = tostring(fmt)
    end

    if Utils and Utils.d then
        Utils.d("[Nvk3UT][TodoData] %s", message)
    elseif d then
        d(string.format("[Nvk3UT][TodoData] %s", message))
    end
end

local function formatDisplayString(text)
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

local function normalizeId(id)
    if id == nil then
        return nil
    end

    if type(id) == "number" then
        if id > 0 then
            return math.floor(id)
        end
        return nil
    end

    if type(id) == "string" then
        local numeric = tonumber(id)
        if numeric and numeric > 0 then
            return math.floor(numeric)
        end
    end

    return nil
end

local function isFullyComplete(id)
    if not id then
        return false
    end

    if Utils and Utils.IsMultiStageAchievement and Utils.IsMultiStageAchievement(id) then
        if Utils.IsAchievementFullyComplete then
            local ok, result = pcall(Utils.IsAchievementFullyComplete, id)
            if ok then
                return result and true or false
            end
        end
    end

    local _, _, _, _, completed = GetAchievementInfo(id)
    return completed == true
end

local function addRange(result, topIndex, subIndex, numAchievements, searchMap)
    for achievementIndex = 1, (numAchievements or 0) do
        local achievementId = GetAchievementId(topIndex, subIndex, achievementIndex)
        if achievementId and not isFullyComplete(achievementId) then
            if searchMap then
                local categoryIndex, subCategoryIndex, achievementListIndex = GetCategoryInfoFromAchievementId(achievementId)
                local bucket = searchMap[categoryIndex]
                if bucket then
                    bucket = bucket[subCategoryIndex or ZO_ACHIEVEMENTS_ROOT_SUBCATEGORY]
                    if bucket and bucket[achievementListIndex] then
                        result[#result + 1] = achievementId
                    end
                end
            else
                result[#result + 1] = achievementId
            end
        end
    end
end

local function buildSearchMap()
    local results = ACHIEVEMENTS_MANAGER and ACHIEVEMENTS_MANAGER.GetSearchResults and ACHIEVEMENTS_MANAGER:GetSearchResults()
    if not (results and next(results)) then
        return nil
    end

    local topCategoryCount = 0
    for _ in pairs(results) do
        topCategoryCount = topCategoryCount + 1
    end

    emitDebugMessage("Search map generated (%d top categories)", topCategoryCount)

    if Nvk3UT and Nvk3UT.UI and Nvk3UT.UI.UpdateStatus then
        pcall(Nvk3UT.UI.UpdateStatus)
    end

    return results
end

local function sortIdsByName(ids)
    local idToName = {}
    local gender = GetUnitGender and GetUnitGender("player") or 0

    local function resolveName(id)
        local cached = idToName[id]
        if cached ~= nil then
            return cached
        end

        local name = GetAchievementInfo(id)
        if type(zo_strformat) == 'function' then
            name = zo_strformat(name, gender)
        end
        idToName[id] = name
        return name
    end

    table.sort(ids, function(left, right)
        return resolveName(left) < resolveName(right)
    end)
end

local function collectOpenAchievementsForTop(topIndex, searchMap, output)
    output = output or {}

    if not topIndex then
        return output
    end

    local ok, _, numSubCategories, numAchievements = pcall(GetAchievementCategoryInfo, topIndex)
    if not ok then
        return output
    end

    if numAchievements and numAchievements > 0 then
        addRange(output, topIndex, nil, numAchievements, searchMap)
    end

    for subCategoryIndex = 1, (numSubCategories or 0) do
        local subOk, _, subNumAchievements = pcall(GetAchievementSubCategoryInfo, topIndex, subCategoryIndex)
        if subOk and subNumAchievements and subNumAchievements > 0 then
            addRange(output, topIndex, subCategoryIndex, subNumAchievements, searchMap)
        end
    end

    sortIdsByName(output)
    return output
end

local function copyFirstN(source, limit)
    if not limit or limit <= 0 or #source <= limit then
        return source
    end

    local result = {}
    for index = 1, limit do
        result[index] = source[index]
    end
    return result
end

function TodoData.NormalizeId(id)
    return normalizeId(id)
end

function TodoData.ListAllOpen(maxCount, respectSearch)
    emitDebugMessage("ListAllOpen start (max=%s, respectSearch=%s)", tostring(maxCount), tostring(respectSearch))

    local useCache = respectSearch ~= true
    if useCache and type(cachedAllOpen) == "table" and #cachedAllOpen > 0 then
        local copy = DeepCopy(cachedAllOpen)
        local limit = tonumber(maxCount)
        if limit and limit > 0 and #copy > limit then
            local trimmed = {}
            for index = 1, limit do
                trimmed[index] = copy[index]
            end
            return trimmed
        end
        return copy
    end

    if useCache then
        invalidateCache()
    end

    local results = {}
    local searchMap = respectSearch and buildSearchMap() or nil
    local numCategories = GetNumAchievementCategories and GetNumAchievementCategories() or 0

    for topIndex = 1, numCategories do
        local topResults = collectOpenAchievementsForTop(topIndex, searchMap, {})
        for i = 1, #topResults do
            results[#results + 1] = topResults[i]
        end
    end

    sortIdsByName(results)

    local limited = copyFirstN(results, tonumber(maxCount))
    if useCache then
        cachedAllOpen = DeepCopy(results)
    end
    emitDebugMessage("ListAllOpen done (count=%d)", #(limited or results))
    return limited or results
end

function TodoData.ListOpenForTop(topIndex, respectSearch)
    local diagnostics = Nvk3UT and Nvk3UT.Diagnostics
    if diagnostics and diagnostics.Debug_Todo_ListOpenForTop then
        diagnostics.Debug_Todo_ListOpenForTop(topIndex, 0, "start")
    else
        emitDebugMessage("ListOpenForTop start (top=%s, respectSearch=%s)", tostring(topIndex), tostring(respectSearch))
    end

    if not topIndex then
        return {}
    end

    local useCache = respectSearch ~= true
    if useCache and cachedListsByTop[topIndex] then
        return DeepCopy(cachedListsByTop[topIndex])
    end

    local searchMap = respectSearch and buildSearchMap() or nil
    local results = collectOpenAchievementsForTop(topIndex, searchMap, {})
    local resultCount = type(results) == "table" and #results or 0
    if diagnostics and diagnostics.Debug_Todo_ListOpenForTop then
        diagnostics.Debug_Todo_ListOpenForTop(topIndex, resultCount, "done")
    else
        emitDebugMessage("ListOpenForTop done (top=%s, count=%d)", tostring(topIndex), resultCount)
    end
    if useCache then
        cachedListsByTop[topIndex] = DeepCopy(results)
    end
    return results
end

function TodoData.CountOpen(respectSearch)
    local list = TodoData.ListAllOpen(nil, respectSearch)
    return type(list) == "table" and #list or 0
end

function TodoData.GetAllTodo(maxCount, respectSearch)
    return TodoData.ListAllOpen(maxCount, respectSearch)
end

function TodoData.IsInTodo(achievementId, respectSearch)
    local normalized = normalizeId(achievementId)
    if not normalized then
        return false
    end

    local list = TodoData.ListAllOpen(nil, respectSearch)
    if type(list) ~= "table" then
        return false
    end

    for index = 1, #list do
        if list[index] == normalized then
            return true
        end
    end

    return false
end

local function summarizeTodoSet()
    local names, keys, topIds = {}, {}, {}
    local numCategories = GetNumAchievementCategories and GetNumAchievementCategories() or 0

    for topIndex = 1, numCategories do
        local ok, name = pcall(GetAchievementCategoryInfo, topIndex)
        if ok and name then
            local openList = collectOpenAchievementsForTop(topIndex, nil, {})
            if #openList > 0 then
                names[#names + 1] = formatDisplayString(name) or name
                keys[#keys + 1] = topIndex
                topIds[#topIds + 1] = topIndex
            end
        end
    end

    return names, keys, topIds
end

function TodoData.GetSubcategoryList(respectSearch)
    local useCache = respectSearch ~= true
    if useCache and cachedNames and cachedKeys and cachedTopIds then
        return DeepCopy(cachedNames), DeepCopy(cachedKeys), DeepCopy(cachedTopIds)
    end

    local names, keys, topIds
    if respectSearch then
        names, keys, topIds = {}, {}, {}
        local searchMap = buildSearchMap()
        local numCategories = GetNumAchievementCategories and GetNumAchievementCategories() or 0
        for topIndex = 1, numCategories do
            local ok, name = pcall(GetAchievementCategoryInfo, topIndex)
            if ok and name then
                local openList = collectOpenAchievementsForTop(topIndex, searchMap, {})
                if #openList > 0 then
                    names[#names + 1] = formatDisplayString(name) or name
                    keys[#keys + 1] = topIndex
                    topIds[#topIds + 1] = topIndex
                end
            end
        end
    else
        names, keys, topIds = summarizeTodoSet()
    end

    if useCache then
        cachedNames = DeepCopy(names or {})
        cachedKeys = DeepCopy(keys or {})
        cachedTopIds = DeepCopy(topIds or {})
    end

    return names or EMPTY_TABLE, keys or EMPTY_TABLE, topIds or EMPTY_TABLE
end

function TodoData.PointsForSubcategory(topIndex, respectSearch)
    if respectSearch ~= true and cachedPointsByTop[topIndex] then
        return cachedPointsByTop[topIndex]
    end

    local ids = TodoData.ListOpenForTop(topIndex, respectSearch)
    if type(ids) ~= "table" then
        return 0
    end

    local points = 0
    for idx = 1, #ids do
        local achievementId = ids[idx]
        local ok, _name, _desc, score = pcall(GetAchievementInfo, achievementId)
        if ok and tonumber(score) then
            points = points + score
        end
    end

    if respectSearch ~= true then
        cachedPointsByTop[topIndex] = points
    end

    return points
end

function TodoData.MaxPointsForTopCategory(topIndex)
    if not topIndex then
        return 0
    end

    local ok, _name, _numSubCategories, _numAchievements, totalPoints = pcall(GetAchievementCategoryInfo, topIndex)
    if ok and tonumber(totalPoints) then
        return totalPoints
    end

    return 0
end

local function handleUnsupportedWrite(operation, achievementId, source)
    emitDebugMessage(
        "%s(%s) ignored (To-Do derives from open achievements)",
        tostring(operation),
        tostring(achievementId)
    )
    return false
end

function TodoData.AddToTodo(achievementId, source)
    return handleUnsupportedWrite("AddToTodo", achievementId, source)
end

function TodoData.RemoveFromTodo(achievementId, source)
    return handleUnsupportedWrite("RemoveFromTodo", achievementId, source)
end

function TodoData.ToggleTodo(achievementId, source)
    return handleUnsupportedWrite("ToggleTodo", achievementId, source)
end

function TodoData.ApplyCacheSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end

    invalidateCache()

    if type(snapshot.allOpen) == "table" then
        cachedAllOpen = DeepCopy(snapshot.allOpen)
    end

    if type(snapshot.names) == "table" then
        cachedNames = DeepCopy(snapshot.names)
    end
    if type(snapshot.keys) == "table" then
        cachedKeys = DeepCopy(snapshot.keys)
    end
    if type(snapshot.topIds) == "table" then
        cachedTopIds = DeepCopy(snapshot.topIds)
    end

    if type(snapshot.lists) == "table" then
        for key, list in pairs(snapshot.lists) do
            cachedListsByTop[key] = DeepCopy(list)
        end
    end

    if type(snapshot.points) == "table" then
        cachedPointsByTop = DeepCopy(snapshot.points)
    end

    if type(snapshot.counts) == "table" and type(snapshot.topIds) == "table" then
        for index = 1, #snapshot.topIds do
            local topId = snapshot.topIds[index]
            if cachedListsByTop[topId] then
                local count = snapshot.counts[topId]
                if type(count) == "number" and count < #cachedListsByTop[topId] then
                    -- Trim cached list to match stored count to avoid stale entries.
                    local trimmed = {}
                    for i = 1, count do
                        trimmed[i] = cachedListsByTop[topId][i]
                    end
                    cachedListsByTop[topId] = trimmed
                end
            end
        end
    end

    return true
end

function TodoData.ExportCacheSnapshot()
    local names, keys, topIds = TodoData.GetSubcategoryList(false)
    local snapshot = {
        names = DeepCopy(names or {}),
        keys = DeepCopy(keys or {}),
        topIds = DeepCopy(topIds or {}),
        lists = {},
        counts = {},
        points = {},
        allOpen = {},
    }

    local all = cachedAllOpen or TodoData.ListAllOpen(nil, false)
    if type(all) == "table" then
        snapshot.allOpen = DeepCopy(all)
    end

    if type(topIds) == "table" then
        for index = 1, #topIds do
            local topId = topIds[index]
            local list = cachedListsByTop[topId] or TodoData.ListOpenForTop(topId, false)
            snapshot.lists[topId] = DeepCopy(list)
            snapshot.counts[topId] = type(list) == "table" and #list or 0
            snapshot.points[topId] = cachedPointsByTop[topId] or TodoData.PointsForSubcategory(topId, false)
        end
    end

    return snapshot
end

return TodoData
