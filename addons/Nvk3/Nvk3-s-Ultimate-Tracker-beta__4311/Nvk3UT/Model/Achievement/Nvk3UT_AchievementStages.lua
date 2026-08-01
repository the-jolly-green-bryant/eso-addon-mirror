-- Model/Achievement/Nvk3UT_AchievementStages.lua
-- Stage-aware helpers for multi-stage achievements.

local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}
local StageHelper = Nvk3UT.AchievementStages or {}
Nvk3UT.AchievementStages = StageHelper

local function getRoot()
    local root = rawget(_G, addonName)
    if type(root) == "table" then
        return root
    end
    return Nvk3UT
end

local function isDebugEnabled()
    local root = getRoot()
    if root and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(root.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = root and root.Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(diagnostics.IsDebugEnabled, diagnostics)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local utils = (root and root.Utils) or _G.Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    return false
end

local function debugLog(fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local Utils = getRoot() and getRoot().Utils
    local ok, message = pcall(string.format, tostring(fmt), ...)
    if not ok then
        message = tostring(fmt)
    end

    if Utils and Utils.d then
        Utils.d("[Nvk3UT][AchievementStages] %s", message)
    elseif d then
        d(string.format("[Nvk3UT][AchievementStages] %s", message))
    end
end

local function normalizeId(value)
    if type(value) == "number" then
        if value > 0 then
            return math.floor(value)
        end
        return nil
    end

    if type(value) == "string" then
        local numeric = tonumber(value)
        if numeric and numeric > 0 then
            return math.floor(numeric)
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

local function resolveBaseId(achievementId)
    local normalized = normalizeId(achievementId)
    if not normalized then
        return nil
    end

    local firstInLine = safeCall(GetFirstAchievementInLine, normalized)
    if firstInLine and firstInLine > 0 then
        return firstInLine
    end

    return normalized
end

local function buildChain(baseAchievementId)
    local baseId = resolveBaseId(baseAchievementId)
    if not baseId then
        return {}, 0
    end

    local chain = {}
    local seen = {}
    local current = baseId

    while current and not seen[current] do
        seen[current] = true
        chain[#chain + 1] = current
        local nextId = safeCall(GetNextAchievementInLine, current)
        if not nextId or nextId <= 0 or seen[nextId] then
            break
        end
        current = nextId
    end

    local finalIndex = #chain
    if finalIndex > 1 then
        debugLog("Chain detected for %d => %s", baseId, table.concat(chain, " -> "))
    end

    return chain, finalIndex
end

local function isAchievementComplete(achievementId)
    if not achievementId then
        return false
    end

    local result = safeCall(IsAchievementComplete, achievementId)
    if result ~= nil then
        return result == true
    end

    local infoName, _, _, _, _, completed = safeCallMulti(GetAchievementInfo, achievementId)
    if completed ~= nil then
        return completed == true
    end

    return false
end

local function findCurrentStageIndex(chain)
    local count = #chain
    if count == 0 then
        return nil
    end

    for index = 1, count do
        local stageId = chain[index]
        if not isAchievementComplete(stageId) then
            return index
        end
    end

    return count
end

function StageHelper.IsMultiStageAchievement(baseAchievementId)
    local chain, finalIndex = buildChain(baseAchievementId)
    return finalIndex > 1, finalIndex
end

function StageHelper.GetStageChain(baseAchievementId)
    local chain, finalIndex = buildChain(baseAchievementId)
    return { stages = chain, finalStageIndex = finalIndex }
end

function StageHelper.GetCurrentStageInfo(baseAchievementId)
    local chain, finalIndex = buildChain(baseAchievementId)
    if finalIndex == 0 then
        return nil
    end

    local currentIndex = findCurrentStageIndex(chain)
    if not currentIndex then
        return nil
    end

    local currentStageId = chain[currentIndex]
    local nextIndex = (currentIndex < finalIndex) and (currentIndex + 1) or nil
    local nextStageId = nextIndex and chain[nextIndex] or nil
    local allCompleted = (currentIndex == finalIndex) and isAchievementComplete(currentStageId) == true

    if finalIndex > 1 then
        debugLog(
            "Stage info base=%d current=%d/%d currentId=%d nextId=%s complete=%s",
            baseAchievementId or -1,
            currentIndex,
            finalIndex,
            currentStageId or -1,
            tostring(nextStageId),
            tostring(allCompleted)
        )
    end

    return {
        stages = chain,
        finalStageIndex = finalIndex,
        currentStageIndex = currentIndex,
        currentStageAchievementId = currentStageId,
        nextStageIndex = nextIndex,
        nextStageAchievementId = nextStageId,
        isChainComplete = allCompleted,
    }
end

function StageHelper.ResolveBaseId(achievementId)
    return resolveBaseId(achievementId)
end

return StageHelper
