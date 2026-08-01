-- StickerbookPlus – TreeProgress: Antiquities codex (tree progress, sorting, hooks)

local Addon = StickerbookPlus
local TreeProgress = Addon.TreeProgress
local Helpers = TreeProgress.Helpers

local GetLabelControl = Helpers.GetLabelControl
local PickColor = Helpers.PickColor
local ApplyLabelColor = Helpers.ApplyLabelColor
local BeginTreeSelectionRefresh = Helpers.BeginTreeSelectionRefresh
local EndTreeSelectionRefresh = Helpers.EndTreeSelectionRefresh
local IsTopLevelNode = Helpers.IsTopLevelNode
local IsSubcategoryNode = Helpers.IsSubcategoryNode
local IsNodeSelected = Helpers.IsNodeSelected
local GetTwoCounterSuffix = Helpers.GetTwoCounterSuffix

-- ── Compute antiquities progress ──────────────────────────────────────────────

-- Two independent progress values: "found" (discovered) and "codex" (lore knowledge).
-- Hidden/undiscovered antiquities (IsVisible() == false) are excluded from tree counts.
-- Codex counted per fragment, not aggregated per set. See AGENTS.md for full rationale.
local function CountAntiquities(categoryData, foundU, foundT, codexU, codexT)
    for _, antiquityData in categoryData:AntiquityIterator() do
        if antiquityData:IsVisible() then
            foundT = foundT + 1
            if antiquityData:HasDiscovered() then
                foundU = foundU + 1
            end

            local numLore = antiquityData:GetNumLoreEntries()
            if numLore > 0 then
                codexT = codexT + numLore
                codexU = codexU + antiquityData:GetNumUnlockedLoreEntries()
            end
        end
    end
    return foundU, foundT, codexU, codexT
end

-- Cache filled once per tree refresh to avoid recursive recounting. See AGENTS.md.
local g_antiquityProgressCache = nil

local function CountAntiquityCategoryProgress(categoryData)
    if g_antiquityProgressCache then
        local cached = g_antiquityProgressCache[categoryData]
        if cached then
            return cached[1], cached[2], cached[3], cached[4]
        end
    end

    local foundU, foundT, codexU, codexT = 0, 0, 0, 0
    foundU, foundT, codexU, codexT = CountAntiquities(categoryData, foundU, foundT, codexU, codexT)
    for _, subcatData in categoryData:SubcategoryIterator() do
        local subU, subT, subCU, subCT = CountAntiquityCategoryProgress(subcatData)
        foundU, foundT = foundU + subU, foundT + subT
        codexU, codexT = codexU + subCU, codexT + subCT
    end

    if g_antiquityProgressCache then
        g_antiquityProgressCache[categoryData] = { foundU, foundT, codexU, codexT }
    end
    return foundU, foundT, codexU, codexT
end

-- Scryable area has no ready-made count API; filter by IsVisible() like ESO itself does.
local function CountScryableAntiquities(categoryData)
    local count = 0
    for _, antiquityData in categoryData:AntiquityIterator() do
        if antiquityData:IsVisible() then
            count = count + 1
        end
    end
    return count
end

-- ── Antiquity tree nodes ───────────────────────────────────────────────────────
-- node.data is directly the ZO_AntiquityCategory instance (also for scryable filter categories)

local function ProcessAntiquityNode(node, db, selectedNode)
    local control = node:GetControl()
    if not control then return end

    local categoryData = node.data
    if not categoryData or not categoryData.AntiquityIterator then return end

    local label = GetLabelControl(control)
    if not label then return end

    local isTop    = IsTopLevelNode(node)
    local isSubcat = IsSubcategoryNode(node)
    if not isTop and not isSubcat then return end

    local antiquitiesEnabled = db.enableAntiquities
    -- ZO_AntiquityCategory has no GetFormattedName() (unlike Sets/Collections)
    local baseName = categoryData.GetName and categoryData:GetName()
    if baseName == "" or baseName == nil then return end

    local isScryable = (isTop and ZO_IsAntiquityScryableCategory(categoryData))
        or (isSubcat and ZO_IsAntiquityScryableSubcategory(categoryData))

    local fullText
    if isScryable then
        -- Count only, never color (scope decision, see AGENTS.md). Only subcategories
        -- have a filter function; the "Scryable" top-level node itself would count
        -- all antiquities in the game unfiltered.
        if isSubcat and antiquitiesEnabled and db.textAntiquitiesScryable then
            local count = CountScryableAntiquities(categoryData)
            fullText = baseName .. (count > 0 and (" (" .. count .. ")") or "")
        else
            fullText = baseName
        end
        label:SetText(fullText)
        if isTop then ZO_IconHeader_UpdateSize(control) end
        ApplyLabelColor(label, nil, false, nil)
        return
    end

    local showColor = antiquitiesEnabled and db.colorAntiquities
    local showText  = antiquitiesEnabled and db.textAntiquities
        and (db.textAntiquitiesFound or db.textAntiquitiesCodex)

    local foundU, foundT, codexU, codexT = CountAntiquityCategoryProgress(categoryData)

    fullText = baseName
    if showText then
        local missingFound = db.textAntiquitiesFound and (foundT - foundU) or 0
        local missingCodex = db.textAntiquitiesCodex and (codexT - codexU) or 0
        fullText = baseName .. GetTwoCounterSuffix(missingFound, missingCodex, db.textAntiquitiesFound, db.textAntiquitiesCodex)
    end

    if isTop then
        label:SetText(fullText)
        ZO_IconHeader_UpdateSize(control)
    else
        label:SetText(fullText)
    end

    local isSelected = IsNodeSelected(node, isTop, selectedNode)

    -- Coloring basis switchable: default "found", optionally "codex" (colorAntiquitiesBasis)
    local colorU, colorT = foundU, foundT
    if db.colorAntiquitiesBasis == Addon.ANTIQUITY_COLOR_BASIS_CODEX then
        colorU, colorT = codexU, codexT
    end
    local c = showColor and PickColor(colorU, colorT, isSelected, db) or nil
    ApplyLabelColor(label, c, isSelected, db, ANTIQUITY_JOURNAL_KEYBOARD.categoryTree)
end

local function ResetAntiquityNode(node)
    local control = node:GetControl()
    if not control then return end

    local categoryData = node.data
    if not categoryData or not categoryData.AntiquityIterator then return end

    local label = GetLabelControl(control)
    if not label then return end

    ApplyLabelColor(label, nil, false, nil)

    local baseName = categoryData.GetName and categoryData:GetName()
    if baseName then label:SetText(baseName) end

    if IsTopLevelNode(node) then
        ZO_IconHeader_UpdateSize(control)
    end
end

function TreeProgress.RefreshAntiquitiesTree()
    local db = Addon.db
    if not db or not db.enabled or not db.enableAntiquities then return end

    if not ANTIQUITY_JOURNAL_KEYBOARD or not ANTIQUITY_JOURNAL_KEYBOARD.categoryTree then return end

    g_antiquityProgressCache = {}

    local selectedNode = ANTIQUITY_JOURNAL_KEYBOARD.categoryTree.selectedNode
    BeginTreeSelectionRefresh(ANTIQUITY_JOURNAL_KEYBOARD.categoryTree)
    ANTIQUITY_JOURNAL_KEYBOARD.categoryTree:ExecuteOnSubTree(nil, function(node)
        ProcessAntiquityNode(node, db, selectedNode)
    end)
    EndTreeSelectionRefresh(ANTIQUITY_JOURNAL_KEYBOARD.categoryTree)

    ANTIQUITY_JOURNAL_KEYBOARD.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()

    g_antiquityProgressCache = nil
end

function TreeProgress.ResetAntiquitiesTree()
    if not ANTIQUITY_JOURNAL_KEYBOARD or not ANTIQUITY_JOURNAL_KEYBOARD.categoryTree then return end
    ANTIQUITY_JOURNAL_KEYBOARD.categoryTree:ExecuteOnSubTree(nil, function(node)
        ResetAntiquityNode(node)
    end)
    ANTIQUITY_JOURNAL_KEYBOARD.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
    TreeProgress.RefreshAntiquitiesSort()
end

-- ── Sort antiquity tile list (undiscovered → open codex → complete) ──────────
-- Function replacement on the global comparator. See AGENTS.md.

local g_antiquitySortHookInstalled = false
local g_lastSelectedAntiquityCategoryData = nil

-- Deliberately separate from Overlay.ShouldMarkMissing: sorting needs a 3-way
-- status (undiscovered / partial / complete) to order "not discovered" before
-- "open codex" before "complete", not just a missing/not-missing bool.
local function GetAntiquityOrSetSortStatus(data)
    if not data:HasDiscovered() then
        return 1
    end
    local total = data:GetNumLoreEntries()
    local unlocked = data:GetNumUnlockedLoreEntries()
    if total > 0 and unlocked < total then
        return 2
    end
    return 3
end

local function SBPMissingFirstAntiquityOrSetComparator(leftAntiquityOrSetData, rightAntiquityOrSetData)
    local leftData = leftAntiquityOrSetData:GetAntiquitySetData() or leftAntiquityOrSetData
    local rightData = rightAntiquityOrSetData:GetAntiquitySetData() or rightAntiquityOrSetData

    local leftStatus = GetAntiquityOrSetSortStatus(leftData)
    local rightStatus = GetAntiquityOrSetSortStatus(rightData)
    if leftStatus ~= rightStatus then
        return leftStatus < rightStatus
    end

    return ZO_Antiquity.CompareSetAndNameTo(leftAntiquityOrSetData, rightAntiquityOrSetData)
end

local function InstallAntiquitySortHook()
    if g_antiquitySortHookInstalled then return end
    g_antiquitySortHookInstalled = true

    local originalComparison = ZO_DefaultAntiquityOrSetSortComparison

    ZO_DefaultAntiquityOrSetSortComparison = function(leftAntiquityOrSetData, rightAntiquityOrSetData)
        local db = Addon.db
        if not db or not db.enabled or not db.enableAntiquities or not db.sortMissingAntiquities then
            return originalComparison(leftAntiquityOrSetData, rightAntiquityOrSetData)
        end
        return SBPMissingFirstAntiquityOrSetComparator(leftAntiquityOrSetData, rightAntiquityOrSetData)
    end
end

function TreeProgress.RefreshAntiquitiesSort()
    if not ANTIQUITY_DATA_MANAGER or not ANTIQUITY_JOURNAL_KEYBOARD then return end
    ANTIQUITY_DATA_MANAGER:SortTopLevelAntiquityCategories()
    if g_lastSelectedAntiquityCategoryData then
        ANTIQUITY_JOURNAL_KEYBOARD:BuildCategoryAntiquityTiles(g_lastSelectedAntiquityCategoryData)
    end
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

-- See the equivalent guard in TreeProgress/Achievements.lua: hooking SelectNode
-- only inside a one-time OnDeferredInitialize PostHook misses the tree entirely
-- if another addon deferred-initializes this scene before this addon's own
-- hook is installed.
local g_antiquitySelectNodeHooked = false

local function EnsureAntiquitySelectNodeHook()
    if g_antiquitySelectNodeHooked then return end
    if not ANTIQUITY_JOURNAL_KEYBOARD or not ANTIQUITY_JOURNAL_KEYBOARD.categoryTree then return end

    g_antiquitySelectNodeHooked = true
    SecurePostHook(ANTIQUITY_JOURNAL_KEYBOARD.categoryTree, "SelectNode", function()
        zo_callLater(TreeProgress.RefreshAntiquitiesTree, 0)
    end)
end

function TreeProgress.InitializeAntiquities()
    -- Antiquity tree: after RefreshCategories and SelectNode on instance
    SecurePostHook(ANTIQUITY_JOURNAL_KEYBOARD, "RefreshCategories", function()
        EnsureAntiquitySelectNodeHook()
        zo_callLater(TreeProgress.RefreshAntiquitiesTree, 0)
    end)

    SecurePostHook(ANTIQUITY_JOURNAL_KEYBOARD, "OnDeferredInitialize", function()
        EnsureAntiquitySelectNodeHook()
    end)

    EnsureAntiquitySelectNodeHook()

    InstallAntiquitySortHook()
    -- PreHook, not PostHook: OnCategorySelected calls BuildCategoryAntiquityTiles inside
    -- its own function, so SortAntiquities() must run before the original.
    ZO_PreHook(ANTIQUITY_JOURNAL_KEYBOARD, "OnCategorySelected", function(self, categoryData)
        if categoryData and not ZO_IsAntiquityScryableCategory(categoryData) and not ZO_IsAntiquityScryableSubcategory(categoryData) then
            g_lastSelectedAntiquityCategoryData = categoryData
            categoryData:SortAntiquities()
        end
        return false
    end)

    local antiquityJournalScene = SCENE_MANAGER:GetScene("antiquityJournalKeyboard")
    if antiquityJournalScene then
        antiquityJournalScene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWN then
                TreeProgress.RefreshAntiquitiesTree()
            end
        end)
    end
end
