Nvk3UT = Nvk3UT or {}

local Journal = {}
Nvk3UT.AchievementsJournal = Journal

local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics

local Utils = Nvk3UT and Nvk3UT.Utils

local FavoritesCategory = Nvk3UT and Nvk3UT.FavoritesCategory
local CompletedSummary = Nvk3UT and Nvk3UT.CompletedSummary
local CompletedCategory = Nvk3UT and Nvk3UT.CompletedCategory
local RecentSummary = Nvk3UT and Nvk3UT.RecentSummary
local RecentCategory = Nvk3UT and Nvk3UT.RecentCategory
local TodoSummary = Nvk3UT and Nvk3UT.TodoSummary
local TodoCategory = Nvk3UT and Nvk3UT.TodoCategory

local state = {
    parent = nil,
    favorites = nil,
    completedSummary = nil,
    completed = nil,
    recentSummary = nil,
    recent = nil,
    todoSummary = nil,
    todo = nil,
}

local function logShim(action)
    if Diagnostics and Diagnostics.Debug then
        Diagnostics.Debug("Journal SHIM -> %s", tostring(action))
    end
end

local function safeCall(func, ...)
    local SafeCall = Nvk3UT and Nvk3UT.SafeCall
    if type(SafeCall) == "function" then
        return SafeCall(func, ...)
    end

    if type(func) ~= "function" then
        return nil
    end

    local ok, result = pcall(func, ...)
    if ok then
        return result
    end
end

local function isDebugEnabled()
    local utils = Utils or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    return false
end

local function buildCriteriaSnapshot(achievementId)
    if type(GetAchievementNumCriteria) ~= "function" or type(GetAchievementCriterion) ~= "function" then
        return nil
    end

    local okCount, total = pcall(GetAchievementNumCriteria, achievementId)
    if not okCount or type(total) ~= "number" or total < 0 then
        return nil
    end

    if total == 0 then
        return { total = 0, completed = 0, allComplete = false }
    end

    local completed = 0
    for index = 1, total do
        local okCrit, _, numCompleted, numRequired = pcall(GetAchievementCriterion, achievementId, index)
        if okCrit then
            local completedValue = tonumber(numCompleted) or 0
            local requiredValue = tonumber(numRequired) or 0
            local achieved
            if requiredValue > 0 then
                achieved = completedValue >= requiredValue
            else
                achieved = completedValue > 0
            end
            if achieved then
                completed = completed + 1
            end
        else
            return { total = total, completed = completed, allComplete = false }
        end
    end

    return {
        total = total,
        completed = completed,
        allComplete = (completed >= total and total > 0),
    }
end

local function ensureCompletionFromInfo(achievementId)
    if type(GetAchievementInfo) ~= "function" then
        return false
    end
    local okInfo, _, _, _, completed = pcall(GetAchievementInfo, achievementId)
    if not okInfo then
        return false
    end
    return completed == true
end

---Initialize the journal view host reference.
---@param parentOrSceneFragment any
function Journal:Init(parentOrSceneFragment)
    state.parent = parentOrSceneFragment
    if FavoritesCategory and type(FavoritesCategory.Init) == "function" then
        local ok, result = pcall(FavoritesCategory.Init, FavoritesCategory, parentOrSceneFragment)
        if ok then
            state.favorites = result or parentOrSceneFragment
        else
            state.favorites = parentOrSceneFragment
        end
    end
    if CompletedSummary and type(CompletedSummary.Init) == "function" then
        local ok, result = pcall(CompletedSummary.Init, CompletedSummary, parentOrSceneFragment)
        if ok then
            state.completedSummary = result or parentOrSceneFragment
        else
            state.completedSummary = parentOrSceneFragment
        end
    end
    if CompletedCategory and type(CompletedCategory.Init) == "function" then
        local ok, result = pcall(CompletedCategory.Init, CompletedCategory, parentOrSceneFragment)
        if ok then
            state.completed = result or parentOrSceneFragment
        else
            state.completed = parentOrSceneFragment
        end
    end
    if RecentSummary and type(RecentSummary.Init) == "function" then
        local ok, result = pcall(RecentSummary.Init, RecentSummary, parentOrSceneFragment)
        if ok then
            state.recentSummary = result or parentOrSceneFragment
        else
            state.recentSummary = parentOrSceneFragment
        end
    end
    if RecentCategory and type(RecentCategory.Init) == "function" then
        local ok, result = pcall(RecentCategory.Init, RecentCategory, parentOrSceneFragment)
        if ok then
            state.recent = result or parentOrSceneFragment
        else
            state.recent = parentOrSceneFragment
        end
    end
    if TodoSummary and type(TodoSummary.Init) == "function" then
        local ok, result = pcall(TodoSummary.Init, TodoSummary, parentOrSceneFragment)
        if ok then
            state.todoSummary = result or parentOrSceneFragment
        else
            state.todoSummary = parentOrSceneFragment
        end
    end
    if TodoCategory and type(TodoCategory.Init) == "function" then
        local ok, result = pcall(TodoCategory.Init, TodoCategory, parentOrSceneFragment)
        if ok then
            state.todo = result or parentOrSceneFragment
        else
            state.todo = parentOrSceneFragment
        end
    end
    return state.favorites
        or state.completedSummary
        or state.completed
        or state.recentSummary
        or state.recent
        or state.todoSummary
        or state.todo
        or parentOrSceneFragment
end

---Refresh the journal view.
---@return any
function Journal:Refresh()
    if FavoritesCategory and type(FavoritesCategory.Refresh) == "function" then
        local ok = pcall(FavoritesCategory.Refresh, FavoritesCategory)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] FavoritesCategory.Refresh failed")
        end
    end
    if CompletedSummary and type(CompletedSummary.Refresh) == "function" then
        local ok = pcall(CompletedSummary.Refresh, CompletedSummary)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] CompletedSummary.Refresh failed")
        end
    end
    if CompletedCategory and type(CompletedCategory.Refresh) == "function" then
        local ok = pcall(CompletedCategory.Refresh, CompletedCategory)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] CompletedCategory.Refresh failed")
        end
    end
    if RecentSummary and type(RecentSummary.Refresh) == "function" then
        local ok = pcall(RecentSummary.Refresh, RecentSummary)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] RecentSummary.Refresh failed")
        end
    end
    if RecentCategory and type(RecentCategory.Refresh) == "function" then
        local ok = pcall(RecentCategory.Refresh, RecentCategory)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] RecentCategory.Refresh failed")
        end
    end
    if TodoSummary and type(TodoSummary.Refresh) == "function" then
        local ok = pcall(TodoSummary.Refresh, TodoSummary)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] TodoSummary.Refresh failed")
        end
    end
    if TodoCategory and type(TodoCategory.Refresh) == "function" then
        local ok = pcall(TodoCategory.Refresh, TodoCategory)
        if not ok and Utils and Utils.d and isDebugEnabled() then
            Utils.d("[Ach][Journal] TodoCategory.Refresh failed")
        end
    end
    return state.parent
end

---Determine whether an achievement is fully complete, including multi-stage chains.
---@param achievementId number
---@return boolean
function Journal.IsComplete(achievementId)
    if type(achievementId) ~= "number" then
        return false
    end

    local helper = _G.Nvk3UT_MultiStage
    local helperResult
    if helper and type(helper.IsMultiStageComplete) == "function" then
        local okHelper, result = pcall(helper.IsMultiStageComplete, achievementId, false)
        if okHelper then
            helperResult = result
        end
    end

    local snapshot = buildCriteriaSnapshot(achievementId)
    local resolved

    if type(helperResult) == "boolean" then
        resolved = helperResult
    elseif helper and type(helper.GetMultiStageProgress) == "function" then
        local okProgress, progress = pcall(helper.GetMultiStageProgress, achievementId)
        if okProgress and type(progress) == "table" then
            local total = tonumber(progress.total) or tonumber(progress.totalStages)
            local done = tonumber(progress.completed) or tonumber(progress.completedStages)
            if total and done and total > 0 then
                snapshot = snapshot or { total = total, completed = done }
                snapshot.total = total
                snapshot.completed = done
                snapshot.allComplete = done >= total
                resolved = snapshot.allComplete
            end
        end
    end

    if resolved == nil then
        if snapshot and snapshot.total > 0 then
            resolved = snapshot.allComplete == true
        else
            resolved = ensureCompletionFromInfo(achievementId)
        end
    end

    if snapshot and snapshot.total == 0 then
        snapshot.completed = resolved and 1 or 0
    end

    if isDebugEnabled() then
        local total = snapshot and snapshot.total or 0
        local completed = snapshot and snapshot.completed or (resolved and total) or 0
        Utils.d(string.format("[Ach] %d complete=%s (stages %d/%d)", achievementId, tostring(resolved == true), completed, total))
    end

    return resolved == true
end

local Shim = {}
Nvk3UT.Achievements = Shim

function Shim.Init(...)
    logShim("Init")
    if type(Journal.Init) ~= "function" then
        return nil
    end
    return safeCall(Journal.Init, Journal, ...)
end

function Shim.Refresh(...)
    logShim("Refresh")
    if type(Journal.Refresh) ~= "function" then
        return nil
    end
    return safeCall(Journal.Refresh, Journal, ...)
end

function Shim.IsComplete(...)
    if type(Journal.IsComplete) ~= "function" then
        return false
    end
    return safeCall(Journal.IsComplete, ...)
end

return Journal
