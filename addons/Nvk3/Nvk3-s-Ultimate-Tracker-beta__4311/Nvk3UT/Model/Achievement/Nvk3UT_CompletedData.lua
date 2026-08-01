Nvk3UT = Nvk3UT or {}

local CompletedData = {}
Nvk3UT.CompletedData = CompletedData

local MONTH_STRING_IDS = {
    [1] = SI_NVK3UT_COMPLETED_MONTH_JANUARY,
    [2] = SI_NVK3UT_COMPLETED_MONTH_FEBRUARY,
    [3] = SI_NVK3UT_COMPLETED_MONTH_MARCH,
    [4] = SI_NVK3UT_COMPLETED_MONTH_APRIL,
    [5] = SI_NVK3UT_COMPLETED_MONTH_MAY,
    [6] = SI_NVK3UT_COMPLETED_MONTH_JUNE,
    [7] = SI_NVK3UT_COMPLETED_MONTH_JULY,
    [8] = SI_NVK3UT_COMPLETED_MONTH_AUGUST,
    [9] = SI_NVK3UT_COMPLETED_MONTH_SEPTEMBER,
    [10] = SI_NVK3UT_COMPLETED_MONTH_OCTOBER,
    [11] = SI_NVK3UT_COMPLETED_MONTH_NOVEMBER,
    [12] = SI_NVK3UT_COMPLETED_MONTH_DECEMBER,
}

local LAST50_KEY = 90000

local built = false
local last50 = {}
local monthKeys = {}
local keyToName = {}
local keyToList = {}

local cachedSnapshot

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

local function push(list, value)
    list[#list + 1] = value
end

-- Normalize any timestamp-like value to a unix number (seconds)
local function asUnix(ts)
    local n = tonumber(ts)
    if n and n > 0 then
        return math.floor(n)
    end
    return nil
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

    local message
    local ok, formatted = pcall(string.format, fmt, ...)
    if ok then
        message = formatted
    else
        message = tostring(fmt)
    end

    local Utils = Nvk3UT and Nvk3UT.Utils
    if Utils and Utils.d then
        Utils.d("[Nvk3UT][CompletedData] %s", message)
    elseif d then
        d(string.format("[Nvk3UT][CompletedData] %s", message))
    end
end

local function normalizeId(value)
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

local function safeCall(func, ...)
    if type(func) ~= "function" then
        return nil
    end

    local ok, result = pcall(func, ...)
    if ok then
        return result
    end

    return nil
end

local function safeCallMulti(func, ...)
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

local function collectCompletionMeta(achievementId)
    if not achievementId then
        return false, nil, nil
    end

    local infoPoints
    local infoComplete
    local infoTimestamp

    if type(GetAchievementInfo) == "function" then
        local ok, _, _, points, _, completed, _, timestamp = pcall(GetAchievementInfo, achievementId)
        if ok then
            infoPoints = points
            infoComplete = completed
            infoTimestamp = timestamp
        end
    end

    local isComplete
    if infoComplete ~= nil then
        isComplete = infoComplete == true
    elseif type(IsAchievementComplete) == "function" then
        local ok, completed = pcall(IsAchievementComplete, achievementId)
        if ok then
            isComplete = completed == true
        end
    end

    local timestamp = asUnix(infoTimestamp)
    if (not timestamp or timestamp == 0) and type(GetAchievementTimestamp) == "function" then
        local ok, value = pcall(GetAchievementTimestamp, achievementId)
        timestamp = asUnix(ok and value or nil) or 0
    else
        timestamp = timestamp or 0
    end

    local points
    if type(infoPoints) == "number" then
        points = infoPoints
    else
        points = tonumber(infoPoints)
    end

    return isComplete == true, timestamp, points
end

local function addIdToMonth(achievementId, timestamp)
    local t = asUnix(timestamp)
    if not (achievementId and t) then
        return
    end

    local dateTable = os.date("*t", t)
    if not dateTable then
        return
    end

    local key = dateTable.year * 100 + dateTable.month
    keyToList[key] = keyToList[key] or {}
    push(keyToList[key], achievementId)

    if not keyToName[key] then
        local monthStringId = MONTH_STRING_IDS[dateTable.month]
        local monthName = monthStringId and GetString(monthStringId)
        if not monthName or monthName == "" then
            monthName = tostring(dateTable.month)
        end
        keyToName[key] = string.format("%s %d", monthName, dateTable.year)
        push(monthKeys, key)
    end
end

local function fetchCompletionForScan(achievementId)
    if not achievementId then
        return false, nil
    end

    local infoCompleted
    local infoTimestamp
    if type(GetAchievementInfo) == "function" then
        local ok, _, _, _, _, completed, _, timeStamp = pcall(GetAchievementInfo, achievementId)
        if ok then
            infoCompleted = completed
            infoTimestamp = timeStamp
        end
    end

    local isComplete
    if type(IsAchievementComplete) == "function" then
        local ok, result = pcall(IsAchievementComplete, achievementId)
        if ok and result ~= nil then
            isComplete = result == true
        end
    end

    if isComplete == nil and infoCompleted ~= nil then
        isComplete = infoCompleted == true
    end

    local timestamp = asUnix(infoTimestamp)
    if (not timestamp or timestamp == 0) and type(GetAchievementTimestamp) == "function" then
        local ok, value = pcall(GetAchievementTimestamp, achievementId)
        timestamp = asUnix(ok and value or nil) or 0
    else
        timestamp = timestamp or 0
    end

    return isComplete == true, timestamp
end

local function processAchievements(ids)
    if type(ids) ~= "table" then
        return
    end

    for index = 1, #ids do
        local normalized = normalizeId(ids[index])
        if normalized then
            local completed, timestamp = fetchCompletionForScan(normalized)
            if completed and timestamp and timestamp ~= 0 then
                push(last50, normalized)
                addIdToMonth(normalized, timestamp)
            end
        end
    end
end

local function collectAchievementIds(categoryIndex, subCategoryIndex, total)
    if type(ZO_GetAchievementIds) ~= "function" then
        return
    end

    local ok, ids = pcall(ZO_GetAchievementIds, categoryIndex, subCategoryIndex, total, false)
    if ok then
        processAchievements(ids)
    end
end

local function scanAllAchievements()
    emitDebugMessage("Scanning achievements for completion data")

    last50 = {}
    monthKeys = {}
    keyToName = {}
    keyToList = {}

    local numTop = safeCall(GetNumAchievementCategories) or 0
    for categoryIndex = 1, numTop do
        local _, numSubCategories, numAchievements = safeCallMulti(GetAchievementCategoryInfo, categoryIndex)
        if numAchievements and numAchievements > 0 then
            collectAchievementIds(categoryIndex, nil, numAchievements)
        end

        numSubCategories = numSubCategories or 0
        for subCategoryIndex = 1, numSubCategories do
            local _, subNumAchievements = safeCallMulti(GetAchievementSubCategoryInfo, categoryIndex, subCategoryIndex)
            if subNumAchievements and subNumAchievements > 0 then
                collectAchievementIds(categoryIndex, subCategoryIndex, subNumAchievements)
            end
        end
    end

    table.sort(last50, function(a, b)
        local ta = asUnix(safeCall(GetAchievementTimestamp, a)) or 0
        local tb = asUnix(safeCall(GetAchievementTimestamp, b)) or 0
        return ta > tb
    end)

    if #last50 > 50 then
        local trimmed = {}
        for index = 1, 50 do
            trimmed[index] = last50[index]
        end
        last50 = trimmed
    end

    table.sort(monthKeys, function(left, right)
        return left > right
    end)

    cachedSnapshot = nil
    emitDebugMessage("Completed scan (months=%d, last50=%d)", #monthKeys, #last50)
end

local function ensureBuilt()
    if built then
        return
    end

    scanAllAchievements()
    built = true
end

function CompletedData.Rebuild()
    emitDebugMessage("Rebuild requested")
    built = false
    cachedSnapshot = nil
end

function CompletedData.GetSubcategoryList()
    ensureBuilt()

    local names = {}
    local ids = {}

    push(names, (GetString and GetString(SI_NVK3UT_JOURNAL_SUBCATEGORY_COMPLETED_LAST50)) or "Letzte 50")
    push(ids, LAST50_KEY)

    for index = 1, #monthKeys do
        local key = monthKeys[index]
        if key ~= LAST50_KEY then
            push(names, keyToName[key])
            push(ids, key)
            if Nvk3UT.debugEnabled then
                Nvk3UT.Diagnostics:Debug("[CompletedData:GetSubcategoryList:MONTH] index=%d key=%s name=%s",
                    index, tostring(key), tostring(keyToName[key])
                )
            end
        else
            if Nvk3UT.debugEnabled then
                Nvk3UT.Diagnostics:Debug("[CompletedData] skipped duplicate LAST50_KEY in month list (index=%d)", index)
            end
        end
    end

    return names, ids
end

function CompletedData.ListForKey(key)
    ensureBuilt()
    if key == LAST50_KEY then
        return last50
    end

    return keyToList[key] or {}
end

local function normalizePoints(value)
    if type(value) == "number" then
        return value
    end

    return tonumber(value) or 0
end

function CompletedData.SummaryCountAndPointsForKey(key)
    local ids = CompletedData.ListForKey(key)
    local count = #ids
    local points = 0

    for index = 1, count do
        local _, _, achievementPoints = safeCallMulti(GetAchievementInfo, ids[index])
        points = points + normalizePoints(achievementPoints)
    end

    return count, points
end

function CompletedData.Constants()
    return { LAST50_KEY = LAST50_KEY }
end

local function buildMeta(achievementId)
    local normalized = normalizeId(achievementId)
    if not normalized then
        return nil
    end

    local isComplete, timestamp, points = collectCompletionMeta(normalized)

    if timestamp == 0 then
        timestamp = nil
    end

    return {
        id = normalized,
        isComplete = isComplete,
        timestamp = timestamp,
        points = points,
    }
end

function CompletedData.IsCompleted(achievementId)
    local meta = buildMeta(achievementId)
    return meta and meta.isComplete == true or false
end

function CompletedData.GetCompletedTimestamp(achievementId)
    local meta = buildMeta(achievementId)
    return meta and meta.timestamp or nil
end

function CompletedData.GetCompletedMeta(achievementId)
    return buildMeta(achievementId)
end

function CompletedData.ApplyCacheSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end

    cachedSnapshot = nil

    if type(snapshot.constants) == "table" and snapshot.constants.LAST50_KEY then
        LAST50_KEY = snapshot.constants.LAST50_KEY
    end

    last50 = {}
    monthKeys = {}
    keyToName = {}
    keyToList = {}

    if type(snapshot.keys) == "table" then
        monthKeys = DeepCopy(snapshot.keys)
        table.sort(monthKeys, function(left, right)
            return left > right
        end)
    end

    if type(snapshot.names) == "table" and type(snapshot.keys) == "table" then
        for index = 1, #snapshot.keys do
            local key = snapshot.keys[index]
            keyToName[key] = snapshot.names[index]
        end
    end

    if type(snapshot.lists) == "table" then
        for key, list in pairs(snapshot.lists) do
            keyToList[key] = DeepCopy(list)
        end
    end

    if type(snapshot.last50) == "table" then
        last50 = DeepCopy(snapshot.last50)
    elseif type(keyToList[LAST50_KEY]) == "table" then
        last50 = DeepCopy(keyToList[LAST50_KEY])
    end

    cachedSnapshot = {
        names = DeepCopy(snapshot.names or {}),
        keys = DeepCopy(snapshot.keys or {}),
        lists = DeepCopy(snapshot.lists or {}),
        counts = DeepCopy(snapshot.counts or {}),
        points = DeepCopy(snapshot.points or {}),
        constants = DeepCopy(snapshot.constants or {}),
        last50 = DeepCopy(snapshot.last50 or {}),
    }

    built = true
    return true
end

function CompletedData.ExportCacheSnapshot()
    ensureBuilt()

    local snapshot = {
        names = {},
        keys = {},
        lists = {},
        counts = {},
        points = {},
        constants = CompletedData.Constants(),
        last50 = DeepCopy(last50),
    }

    local names, keys = CompletedData.GetSubcategoryList()
    if type(names) == "table" then
        snapshot.names = DeepCopy(names)
    end
    if type(keys) == "table" then
        snapshot.keys = DeepCopy(keys)
        for index = 1, #keys do
            local key = keys[index]
            snapshot.lists[key] = DeepCopy(CompletedData.ListForKey(key))
            local count, score = CompletedData.SummaryCountAndPointsForKey(key)
            snapshot.counts[key] = count or 0
            snapshot.points[key] = score or 0
        end
    end

    return snapshot
end

return CompletedData
