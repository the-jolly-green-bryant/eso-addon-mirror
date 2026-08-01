-- StickerbookPlus – TreeProgress: Achievements (tree progress, line thumbs, sorting, hooks)

local Addon = StickerbookPlus
local TreeProgress = Addon.TreeProgress
local Helpers = TreeProgress.Helpers

local GetLabelControl = Helpers.GetLabelControl
local PickColor = Helpers.PickColor
local ApplyLabelColor = Helpers.ApplyLabelColor
local BeginTreeSelectionRefresh = Helpers.BeginTreeSelectionRefresh
local EndTreeSelectionRefresh = Helpers.EndTreeSelectionRefresh
local GetTwoCounterSuffix = Helpers.GetTwoCounterSuffix
local GetAchievementSubcatMaxWidth = Helpers.GetAchievementSubcatMaxWidth
local ApplyTruncation = Helpers.ApplyTruncation
local InstallSubcatTooltip = Helpers.InstallSubcatTooltip
local IsTopLevelNode = Helpers.IsTopLevelNode
local IsSubcategoryNode = Helpers.IsSubcategoryNode
local IsNodeSelected = Helpers.IsNodeSelected

-- ── Compute achievement progress ──────────────────────────────────────────────

-- node.data category-index semantics documented in AGENTS.md.
local function GetAchievementNodeCategoryInfo(data)
    if data.summary or data.categoryIndex == nil then return nil end
    if data.parentData == nil then
        return data.categoryIndex, nil, false
    end
    if data.isFakedSubcategory then
        return data.parentData.categoryIndex, nil, true
    end
    return data.parentData.categoryIndex, data.categoryIndex, false
end

-- Finds the last stage of a chain (or itself if not chained).
local function GetLastAchievementInLine(achievementId)
    local lastInLine = achievementId
    local nextId = GetNextAchievementInLine(achievementId)
    while nextId ~= 0 do
        lastInLine = nextId
        nextId = GetNextAchievementInLine(nextId)
    end
    return lastInLine
end

-- Chain dedup and faked-subcategory rationale documented in AGENTS.md.
local function GetTopLevelOnlyPointsProgress(topLevelIndex)
    local _, _, numAchievements = GetAchievementCategoryInfo(topLevelIndex)
    local earnedPoints, totalPoints = 0, 0
    local seen = {}
    for i = 1, numAchievements do
        local achievementId = GetAchievementId(topLevelIndex, nil, i)
        local lastInLine = GetLastAchievementInLine(achievementId)
        if not seen[lastInLine] then
            seen[lastInLine] = true
            local _, _, points, _, completed = GetAchievementInfo(lastInLine)
            totalPoints = totalPoints + points
            if completed then
                earnedPoints = earnedPoints + points
            end
        end
    end
    return earnedPoints, totalPoints
end

local function GetAchievementPointsProgress(data)
    local topLevelIndex, subCategoryIndex, isFakedSubcategory = GetAchievementNodeCategoryInfo(data)
    if topLevelIndex == nil then return nil, nil end
    if isFakedSubcategory then
        return GetTopLevelOnlyPointsProgress(topLevelIndex)
    end
    if subCategoryIndex == nil then
        local _, _, _, earnedPoints, totalPoints = GetAchievementCategoryInfo(topLevelIndex)
        return earnedPoints, totalPoints
    end
    local _, _, earnedPoints, totalPoints = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
    return earnedPoints, totalPoints
end

-- Counts missing chains for one (sub-)list; subCategoryIndex nil means "top-level
-- achievements without subcat", not the whole category. seen is shared by the caller
-- across subcategories to avoid double-counting a chain.
local function CountMissingInList(topLevelIndex, subCategoryIndex, numAchievements, seen)
    local missing = 0
    for i = 1, numAchievements do
        local achievementId = GetAchievementId(topLevelIndex, subCategoryIndex, i)
        local lastInLine = GetLastAchievementInLine(achievementId)
        if not seen[lastInLine] then
            seen[lastInLine] = true
            local _, _, _, _, completed = GetAchievementInfo(lastInLine)
            if not completed then
                missing = missing + 1
            end
        end
    end
    return missing
end

local function CountMissingAchievements(topLevelIndex, subCategoryIndex)
    local numAchievements
    if subCategoryIndex == nil then
        local _, _, n = GetAchievementCategoryInfo(topLevelIndex)
        numAchievements = n
    else
        local _, n = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
        numAchievements = n
    end
    return CountMissingInList(topLevelIndex, subCategoryIndex, numAchievements, {})
end

-- Missing count for the entire top-level node: own achievements plus all subcategories.
local function CountMissingAchievementsForTopLevel(topLevelIndex)
    local _, numSubCategories, numOwnAchievements = GetAchievementCategoryInfo(topLevelIndex)
    local seen = {}
    local missing = CountMissingInList(topLevelIndex, nil, numOwnAchievements, seen)
    for subCategoryIndex = 1, numSubCategories do
        local _, numSubAchievements = GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)
        missing = missing + CountMissingInList(topLevelIndex, subCategoryIndex, numSubAchievements, seen)
    end
    return missing
end

-- ── Color achievement chain stages (line thumbs) ──────────────────────────────
-- Must actively reset to ESO's own colors when disabled, not just skip. See AGENTS.md.
local function ResetLineThumbColor(lineThumb)
    local _, _, _, _, completed = GetAchievementInfo(lineThumb.achievementId)
    if completed then
        lineThumb.label:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    else
        lineThumb.label:SetColor(ZO_ACHIEVEMENT_DISABLED_COLOR:UnpackRGBA())
    end
end

local function ApplyLineThumbColors(self)
    local db = Addon.db
    if not db or not db.enabled or not db.enableAchievements or not db.colorAchievementLineThumbs then
        for _, lineThumb in ipairs(self.lineThumbs) do
            ResetLineThumbColor(lineThumb)
        end
        return
    end
    for _, lineThumb in ipairs(self.lineThumbs) do
        local _, _, _, _, completed = GetAchievementInfo(lineThumb.achievementId)
        local c = PickColor(completed and 1 or 0, 1, false, db)
        if c then
            lineThumb.label:SetColor(c.r, c.g, c.b, c.a or 1)
        else
            ResetLineThumbColor(lineThumb)
        end
    end
end

function TreeProgress.RefreshAchievementLineThumbs()
    if not ACHIEVEMENTS or not ACHIEVEMENTS.achievementsById then return end
    for _, achievement in pairs(ACHIEVEMENTS.achievementsById) do
        if achievement.lineThumbs and #achievement.lineThumbs > 0 then
            ApplyLineThumbColors(achievement)
        end
    end
end

-- ── Achievement tree nodes ─────────────────────────────────────────────────────

local function ProcessAchievementNode(node, db, selectedNode)
    local control = node:GetControl()
    if not control then return end

    local data = node.data
    if not data then return end

    local label = GetLabelControl(control)
    if not label then return end

    local isTop    = IsTopLevelNode(node)
    local isSubcat = IsSubcategoryNode(node)
    if not isTop and not isSubcat then return end

    local topLevelIndex, subCategoryIndex = GetAchievementNodeCategoryInfo(data)
    if topLevelIndex == nil then return end

    local achievementsEnabled = db.enableAchievements
    local showColor = achievementsEnabled and db.colorAchievements
    local showText  = achievementsEnabled and db.textAchievements
        and (db.textAchievementsCount or db.textAchievementsPoints)

    local earnedPoints, totalPoints = GetAchievementPointsProgress(data)

    local baseName = data.name
    if not baseName or baseName == "" then return end

    local isRealTopLevel = data.parentData == nil

    local fullText = baseName
    if showText then
        local missingCount = 0
        if db.textAchievementsCount then
            missingCount = isRealTopLevel
                and CountMissingAchievementsForTopLevel(topLevelIndex)
                or CountMissingAchievements(topLevelIndex, subCategoryIndex)
        end
        local missingPoints = db.textAchievementsPoints and (totalPoints or 0) - (earnedPoints or 0) or 0
        fullText = baseName .. GetTwoCounterSuffix(missingCount, missingPoints, db.textAchievementsCount, db.textAchievementsPoints)
    end

    if isTop then
        label:SetText(fullText)
        ZO_IconHeader_UpdateSize(control)
    else
        InstallSubcatTooltip(label)
        ApplyTruncation(label, fullText, GetAchievementSubcatMaxWidth(node))
    end

    local isSelected = IsNodeSelected(node, isTop, selectedNode)

    local c = showColor and PickColor(earnedPoints or 0, totalPoints or 0, isSelected, db) or nil
    ApplyLabelColor(label, c, isSelected, db, ACHIEVEMENTS.categoryTree)
end

function TreeProgress.RefreshAchievementsTree()
    local db = Addon.db
    if not db or not db.enabled or not db.enableAchievements then return end

    if not ACHIEVEMENTS or not ACHIEVEMENTS.categoryTree then return end

    local selectedNode = ACHIEVEMENTS.categoryTree.selectedNode
    BeginTreeSelectionRefresh(ACHIEVEMENTS.categoryTree)
    ACHIEVEMENTS.categoryTree:ExecuteOnSubTree(nil, function(node)
        ProcessAchievementNode(node, db, selectedNode)
    end)
    EndTreeSelectionRefresh(ACHIEVEMENTS.categoryTree)

    ACHIEVEMENTS.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
end

function TreeProgress.ResetAchievementsTree()
    if not ACHIEVEMENTS or not ACHIEVEMENTS.categoryTree then return end
    ACHIEVEMENTS.categoryTree:ExecuteOnSubTree(nil, function(node)
        local control = node:GetControl()
        if not control then return end
        local label = GetLabelControl(control)
        if not label then return end
        label._sbpFullText = nil
        ApplyLabelColor(label, nil, false, nil)
    end)
    ACHIEVEMENTS:BuildCategories()
    TreeProgress.RefreshAchievementLineThumbs()
    TreeProgress.RefreshAchievementsSort()
end

-- ── Sort achievement list (missing → started → complete) ──────────────────────
-- PreHook on LayoutAchievements itself (PostHook would be one category-change too
-- late). See AGENTS.md.

local g_achievementSortStatusCache = nil
local g_lastSelectedAchievementCategoryData = nil

-- Deliberately separate from Overlay.ShouldMarkMissing: sorting works from raw
-- achievement IDs at LayoutAchievements time (before tileObj._sbpIsUnlocked
-- exists) and needs a 3-way status (missing / started / complete) for chains,
-- not just a missing/not-missing bool.
local function GetAchievementSortStatus(id)
    if g_achievementSortStatusCache[id] then return g_achievementSortStatusCache[id] end

    local firstId = GetFirstAchievementInLine(id)
    local status
    if firstId == 0 then
        local completed = select(5, GetAchievementInfo(id))
        status = completed and 3 or 1
    else
        local completedCount, totalCount = 0, 0
        local currentId = firstId
        while currentId ~= 0 do
            totalCount = totalCount + 1
            if select(5, GetAchievementInfo(currentId)) then
                completedCount = completedCount + 1
            end
            currentId = GetNextAchievementInLine(currentId)
        end
        if completedCount == 0 then
            status = 1
        elseif completedCount == totalCount then
            status = 3
        else
            status = 2
        end
    end

    g_achievementSortStatusCache[id] = status
    return status
end

local function InstallAchievementSortHook()
    ZO_PreHook(Achievements, "OnCategorySelected", function(self, data)
        if data and not data.summary then
            g_lastSelectedAchievementCategoryData = data
        end
        return false
    end)

    ZO_PreHook(Achievements, "LayoutAchievements", function(self, achievements)
        local db = Addon.db
        if not db or not db.enabled or not db.enableAchievements or not db.sortMissingAchievements then
            return false
        end

        g_achievementSortStatusCache = {}
        local sortIndex = {}
        for i, id in ipairs(achievements) do
            sortIndex[id] = i
        end

        table.sort(achievements, function(leftId, rightId)
            local leftStatus = GetAchievementSortStatus(leftId)
            local rightStatus = GetAchievementSortStatus(rightId)
            if leftStatus ~= rightStatus then
                return leftStatus < rightStatus
            end
            return sortIndex[leftId] < sortIndex[rightId]
        end)

        g_achievementSortStatusCache = nil
        return false
    end)
end

function TreeProgress.RefreshAchievementsSort()
    if not ACHIEVEMENTS or not g_lastSelectedAchievementCategoryData then return end
    ACHIEVEMENTS:BuildContentList(g_lastSelectedAchievementCategoryData, true)
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

-- Hooking SelectNode only inside a one-time OnDeferredInitialize PostHook misses
-- the tree entirely if Achievements was already deferred-initialized before this
-- addon's own EVENT_ADD_ON_LOADED handler ran. Confirmed with addon PerfectPixel,
-- which touches ACHIEVEMENTS via its own OnDeferredInitialize hook and loads
-- alphabetically before StickerbookPlus — by the time our OnDeferredInitialize
-- PostHook is registered, Achievements has already deferred-initialized and our
-- hook is installed on a callback that will never fire again. Installed
-- defensively wherever the tree is first seen to exist instead, with a guard
-- against double-installation.
local g_achievementSelectNodeHooked = false

local function EnsureAchievementSelectNodeHook()
    if g_achievementSelectNodeHooked then return end
    if not ACHIEVEMENTS or not ACHIEVEMENTS.categoryTree then return end

    g_achievementSelectNodeHooked = true
    SecurePostHook(ACHIEVEMENTS.categoryTree, "SelectNode", function()
        zo_callLater(TreeProgress.RefreshAchievementsTree, 0)
    end)
end

function TreeProgress.InitializeAchievements()
    -- Achievement tree: after BuildCategories and SelectNode on instance
    SecurePostHook(Achievements, "BuildCategories", function(self)
        if self == ACHIEVEMENTS then
            EnsureAchievementSelectNodeHook()
            zo_callLater(TreeProgress.RefreshAchievementsTree, 0)
        end
    end)

    SecurePostHook(Achievements, "OnDeferredInitialize", function(self)
        if self == ACHIEVEMENTS then
            EnsureAchievementSelectNodeHook()
        end
    end)

    -- Covers the case where OnDeferredInitialize already ran before this addon
    -- loaded (e.g. another addon triggered it at login).
    EnsureAchievementSelectNodeHook()

    local achievementsScene = SCENE_MANAGER:GetScene("achievements")
    if achievementsScene then
        achievementsScene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                TreeProgress.RefreshAchievementsTree()
            end
        end)
    end

    -- Color chain-stage line thumbs after ESO rebuilds them
    SecurePostHook(Achievement, "RefreshExpandedLineView", ApplyLineThumbColors)

    InstallAchievementSortHook()
end
