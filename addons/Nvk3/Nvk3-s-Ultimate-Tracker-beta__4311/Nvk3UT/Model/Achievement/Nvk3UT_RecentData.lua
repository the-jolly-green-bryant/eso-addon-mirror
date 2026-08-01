Nvk3UT = Nvk3UT or {}

local Utils = Nvk3UT and Nvk3UT.Utils

local RecentData = {}
Nvk3UT.RecentData = RecentData

local defaults = { progress = {} }

local cachedIds
local cachedProgress

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
    cachedIds = nil
    cachedProgress = nil
end

local function ensureSavedVars()
    if not Nvk3UT._recentSV then
        Nvk3UT._recentSV = ZO_SavedVars:NewAccountWide("Nvk3UT_Data_Recent", 1, nil, defaults)
    end

    local saved = Nvk3UT._recentSV
    if type(saved.progress) ~= "table" then
        saved.progress = {}
    end

    return saved
end

local function now()
    if Utils and Utils.now then
        local ok, value = pcall(Utils.now)
        if ok and value ~= nil then
            return value
        end
    end

    if GetTimeStamp then
        return GetTimeStamp()
    end

    return nil
end

local function isDebugEnabled()
    local utils = Utils or Nvk3UT_Utils
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

local function emitDebugMessage(...)
    if not isDebugEnabled() then
        return
    end

    if Utils and Utils.d then
        Utils.d("[Nvk3UT][Recent]", ...)
    elseif d then
        d("[Nvk3UT][Recent]", ...)
    end
end

local function collectCandidateKeys(id)
    local keys = {}
    local seen = {}

    local function push(value)
        if value == nil or seen[value] then
            return
        end
        seen[value] = true
        keys[#keys + 1] = value
    end

    push(id)

    if type(id) == "number" then
        push(tostring(id))
    elseif type(id) == "string" then
        local numeric = tonumber(id)
        if numeric then
            push(numeric)
        end
    end

    if Utils and Utils.NormalizeAchievementId then
        local ok, normalized = pcall(Utils.NormalizeAchievementId, id)
        if ok and normalized ~= nil then
            push(normalized)
            if type(normalized) == "number" then
                push(tostring(normalized))
            elseif type(normalized) == "string" then
                local numeric = tonumber(normalized)
                if numeric then
                    push(numeric)
                end
            end
        end
    end

    return keys
end

local function normalizeIdForStorage(id)
    if id == nil then
        return nil
    end

    if Utils and Utils.NormalizeAchievementId then
        local ok, normalized = pcall(Utils.NormalizeAchievementId, id)
        if ok and normalized ~= nil then
            id = normalized
        end
    end

    if type(id) == "number" then
        return id
    end

    local numeric = tonumber(id)
    if numeric then
        return numeric
    end

    return id
end

-- Migration: merge all character buckets into the account-wide bucket
function RecentData.MigrateToAccountWide()
    local raw = _G["Nvk3UT_Data_Recent"]
    local accountName = (GetDisplayName and GetDisplayName()) or nil
    if not (raw and raw["Default"] and accountName and raw["Default"][accountName]) then
        return 0
    end

    local root = raw["Default"][accountName]
    local accNode = root["$AccountWide"] or {}
    accNode["progress"] = accNode["progress"] or {}
    local accProg = accNode["progress"]
    local moved = 0

    for key, node in pairs(root) do
        if key ~= "$AccountWide" and type(key) == "string" and key:match("^%d+$") then
            local prog = node and node["progress"]
            if type(prog) == "table" then
                for storedId, ts in pairs(prog) do
                    if ts then
                        if not accProg[storedId] or (type(ts) == "number" and ts > accProg[storedId]) then
                            accProg[storedId] = ts
                        end
                        prog[storedId] = nil
                        moved = moved + 1
                    end
                end
            end
        end
    end

    root["$AccountWide"] = accNode
    return moved
end

function RecentData.InitSavedVars()
    local sv = ensureSavedVars()
    if RecentData.MigrateToAccountWide then
        pcall(RecentData.MigrateToAccountWide)
    end
    return sv
end

local function IsOpen(id)
    if not id then
        return false
    end

    if Utils and Utils.IsMultiStageAchievement then
        local okMulti, isMulti = pcall(Utils.IsMultiStageAchievement, id)
        if okMulti and isMulti and Utils.IsAchievementFullyComplete then
            local okComplete, fullyComplete = pcall(Utils.IsAchievementFullyComplete, id)
            if okComplete then
                return fullyComplete == false
            end
        end
    end

    if type(GetAchievementInfo) ~= "function" then
        return false
    end

    local infoOk, _, _, _, completedOrErr = pcall(GetAchievementInfo, id)
    if not infoOk then
        if isDebugEnabled() then
            emitDebugMessage("IsOpen failed", "id:", tostring(id), "error:", tostring(completedOrErr))
        end
        return false
    end

    return completedOrErr == false
end

function RecentData.Touch(id, timestamp)
    if not id then
        return
    end

    invalidateCache()
    local sv = ensureSavedVars()
    local storeId = normalizeIdForStorage(id)
    if not storeId then
        return
    end

    sv.progress[storeId] = timestamp or now() or GetTimeStamp()

    local cache = Nvk3UT and Nvk3UT.AchievementCache
    if cache and cache.MarkDirty then
        cache.MarkDirty("Recent")
    end
end

function RecentData.Clear(id)
    if not id then
        return
    end

    invalidateCache()
    local sv = ensureSavedVars()
    local storeId = normalizeIdForStorage(id)
    if not storeId then
        return
    end

    sv.progress[storeId] = nil

    local cache = Nvk3UT and Nvk3UT.AchievementCache
    if cache and cache.MarkDirty then
        cache.MarkDirty("Recent")
    end
end

function RecentData.GetTimestamp(id)
    if not id then
        return nil
    end

    local sv = ensureSavedVars()
    local progress = sv.progress
    local keys = collectCandidateKeys(id)

    for index = 1, #keys do
        local key = keys[index]
        if key ~= nil and progress[key] ~= nil then
            return progress[key]
        end
    end

    return nil
end

function RecentData.Contains(id)
    local ts = RecentData.GetTimestamp(id)
    return ts ~= nil
end

function RecentData.IterateProgress()
    local sv = ensureSavedVars()
    return next, sv.progress, nil
end

-- Build a sorted list of IDs by timestamp (desc); optional sinceTs and maxCount
function RecentData.List(maxCount, sinceTs)
    local sv = ensureSavedVars()
    local t = {}

    for id, ts in pairs(sv.progress) do
        if (not sinceTs) or (type(ts) == "number" and ts >= sinceTs) then
            t[#t + 1] = { id = id, ts = ts or 0 }
        end
    end

    table.sort(t, function(a, b)
        return a.ts > b.ts
    end)

    local res = {}
    local limit = tonumber(maxCount) or 0
    local removed = 0

    for i = 1, #t do
        local entryId = t[i].id
        local open = IsOpen(entryId)
        if open then
            if limit == 0 or #res < limit then
                res[#res + 1] = entryId
            end
        elseif entryId then
            RecentData.Clear(entryId)
            removed = removed + 1
        end
    end

    if removed > 0 then
        emitDebugMessage("List filtered", "removed:", removed)
    end

    return res
end

local function getConfigWindow()
    local sv = Nvk3UT and Nvk3UT.sv or { General = {} }
    local general = sv.General or {}
    local win = general.recentWindow or 0
    local maxc = general.recentMax or 100
    local sinceTs = nil

    if win == 7 then
        sinceTs = (GetTimeStamp() - 7 * 24 * 60 * 60)
    elseif win == 30 then
        sinceTs = (GetTimeStamp() - 30 * 24 * 60 * 60)
    end

    return maxc, sinceTs
end

function RecentData.ListConfigured()
    RecentData.InitSavedVars()
    local maxc, sinceTs = getConfigWindow()
    return RecentData.List(maxc, sinceTs)
end

function RecentData.CountConfigured()
    RecentData.InitSavedVars()
    local maxc, sinceTs = getConfigWindow()
    local list = RecentData.List(maxc, sinceTs)
    return (list and #list) or 0
end

-- Seed the account-wide recent list with up to 50 entries (only if empty)
function RecentData.BuildInitial()
    local sv = ensureSavedVars()
    if next(sv.progress) ~= nil then
        return 0
    end

    invalidateCache()
    local INIT_CAP = 50
    local stamp = now() or GetTimeStamp()

    local function hasPartialProgress(id)
        if not id or not IsOpen(id) then
            return false
        end

        local inspectIds = { id }
        if Utils and Utils.NormalizeAchievementId then
            local normalized = Utils.NormalizeAchievementId(id)
            if normalized and normalized ~= id then
                inspectIds[#inspectIds + 1] = normalized
            end
        end

        local getState = Utils and Utils.GetAchievementCriteriaState
        if type(getState) == "function" then
            for _, inspectId in ipairs(inspectIds) do
                local state = getState(inspectId)
                if state and type(state.total) == "number" and state.total > 0 then
                    local total = state.total
                    local completed = tonumber(state.completed) or 0
                    if completed > 0 and completed < total then
                        return true
                    end
                end
            end
        end

        if type(GetAchievementProgress) == "function" then
            local ok, completed, total = pcall(GetAchievementProgress, id)
            if ok and type(total) == "number" and total > 0 and type(completed) == "number" then
                if completed > 0 and completed < total then
                    return true
                end
            end
        end

        return false
    end

    local function getRandom(minValue, maxValue)
        if type(zo_random) == "function" then
            return zo_random(minValue, maxValue)
        end
        if type(math.random) == "function" then
            if maxValue then
                return math.random(minValue, maxValue)
            end
            return math.random(minValue)
        end
        return minValue
    end

    local function shuffle(list)
        for i = #list, 2, -1 do
            local swapIndex = getRandom(1, i)
            list[i], list[swapIndex] = list[swapIndex], list[i]
        end
    end

    local candidates = {}
    local seen = {}

    local function collect(id)
        if not id then
            return
        end

        local okPartial, hasProgress = pcall(hasPartialProgress, id)
        if not okPartial then
            if isDebugEnabled() then
                emitDebugMessage("Seed partial check failed", "id:", tostring(id), "error:", tostring(hasProgress))
            end
            return
        end
        if not hasProgress then
            return
        end

        local storeId = id
        if Utils and Utils.NormalizeAchievementId then
            storeId = Utils.NormalizeAchievementId(id) or id
        end

        if not storeId or seen[storeId] then
            return
        end

        seen[storeId] = true
        candidates[#candidates + 1] = storeId
    end

    local numCats = GetNumAchievementCategories and GetNumAchievementCategories() or 0
    for top = 1, numCats do
        local _, numSub, numAch = GetAchievementCategoryInfo(top)
        for a = 1, (numAch or 0) do
            collect(GetAchievementId(top, nil, a))
        end
        for sub = 1, (numSub or 0) do
            local _, numAch2 = GetAchievementSubCategoryInfo(top, sub)
            for a = 1, (numAch2 or 0) do
                collect(GetAchievementId(top, sub, a))
            end
        end
    end

    if #candidates == 0 then
        return 0
    end

    shuffle(candidates)

    local added = 0
    for index = 1, math.min(INIT_CAP, #candidates) do
        local storeId = candidates[index]
        if storeId then
            if sv.progress[storeId] == nil then
                added = added + 1
            end
            sv.progress[storeId] = stamp
        end
    end

    return added
end

-- Event wiring: keep list fresh passively
function RecentData.RegisterEvents()
    local em = EVENT_MANAGER
    if not em then
        return
    end

    em:UnregisterForEvent("Nvk3UT_RecentData", EVENT_ACHIEVEMENT_UPDATED)
    em:UnregisterForEvent("Nvk3UT_RecentData", EVENT_ACHIEVEMENT_AWARDED)

    em:RegisterForEvent("Nvk3UT_RecentData", EVENT_ACHIEVEMENT_UPDATED, function(_, achievementId)
        if IsOpen(achievementId) then
            RecentData.Touch(achievementId)
        else
            RecentData.Clear(achievementId)
        end
    end)

    em:RegisterForEvent("Nvk3UT_RecentData", EVENT_ACHIEVEMENT_AWARDED, function(_, _, _, achievementId)
        if IsOpen(achievementId) then
            RecentData.Touch(achievementId)
        else
            RecentData.Clear(achievementId)
        end
    end)
end

function RecentData.ApplyCacheSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end

    invalidateCache()

    local sv = ensureSavedVars()
    if type(snapshot.progress) == "table" then
        cachedProgress = DeepCopy(snapshot.progress)
        for key in pairs(sv.progress) do
            sv.progress[key] = nil
        end
        for key, value in pairs(cachedProgress) do
            sv.progress[key] = value
        end
    else
        cachedProgress = nil
    end

    if type(snapshot.ids) == "table" then
        cachedIds = DeepCopy(snapshot.ids)
    else
        cachedIds = nil
    end

    return true
end

function RecentData.ExportCacheSnapshot()
    local sv = ensureSavedVars()
    local snapshot = { ids = {}, progress = {} }

    if type(cachedIds) == "table" then
        snapshot.ids = DeepCopy(cachedIds)
    else
        local list = RecentData.ListConfigured()
        if type(list) == "table" then
            snapshot.ids = DeepCopy(list)
        end
    end

    if type(cachedProgress) == "table" then
        snapshot.progress = DeepCopy(cachedProgress)
    else
        for key, value in pairs(sv.progress) do
            snapshot.progress[key] = value
        end
    end

    return snapshot
end

return RecentData
