-- StickerbookPlus – TreeProgress: Collections (tree progress, hooks)

local Addon = StickerbookPlus
local TreeProgress = Addon.TreeProgress
local Helpers = TreeProgress.Helpers

local GetLabelControl = Helpers.GetLabelControl
local PickColor = Helpers.PickColor
local ApplyLabelColor = Helpers.ApplyLabelColor
local BeginTreeSelectionRefresh = Helpers.BeginTreeSelectionRefresh
local EndTreeSelectionRefresh = Helpers.EndTreeSelectionRefresh
local GetProgressSuffix = Helpers.GetProgressSuffix
local IsTopLevelNode = Helpers.IsTopLevelNode
local IsSubcategoryNode = Helpers.IsSubcategoryNode
local IsNodeSelected = Helpers.IsNodeSelected

-- ── Compute collections progress ──────────────────────────────────────────────

-- Returns unlocked/total for text AND color in one pass. Completed combination
-- fragments: ignored for text, counted as done for color. See AGENTS.md.
local function CountCollectibles(categoryData, uText, tText, uColor, tColor)
    local db = Addon.db
    local countHidden = db and db.countHiddenCollectibles
    for _, collectibleData in categoryData:CollectibleIterator() do
        if countHidden or collectibleData:IsShownInCollection() then
            if collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT)
                    and not CanCombinationFragmentBeUnlocked(collectibleData:GetId()) then
                tColor   = tColor + 1
                uColor   = uColor + 1
            else
                tText  = tText + 1
                tColor = tColor + 1
                if collectibleData:IsUnlocked() then
                    uText  = uText + 1
                    uColor = uColor + 1
                end
            end
        end
    end
    return uText, tText, uColor, tColor
end

local function GetCollectionsCategoryProgress(categoryData)
    -- Top-level: CollectibleIterator aggregates all subcats; iterate subcats instead,
    -- except top-level categories without subcats (use CollectibleIterator directly).
    if categoryData.isTopLevelCategory then
        local hasSubcats = categoryData:GetNumSubcategories() > 0
        local uText, tText, uColor, tColor = 0, 0, 0, 0
        if hasSubcats then
            for _, subcatData in categoryData:SubcategoryIterator() do
                uText, tText, uColor, tColor = CountCollectibles(subcatData, uText, tText, uColor, tColor)
            end
        else
            uText, tText, uColor, tColor = CountCollectibles(categoryData, 0, 0, 0, 0)
        end
        return uText, tText, uColor, tColor
    else
        return CountCollectibles(categoryData, 0, 0, 0, 0)
    end
end

-- ── Collections tree nodes ────────────────────────────────────────────────────
-- node.data is directly ZO_CollectibleCategoryData (no referenceData wrapper like Outfits)

local function ProcessCollectionsNode(node, db, selectedNode)
    local control = node:GetControl()
    if not control then return end

    local categoryData = node.data
    if not categoryData or not categoryData.CollectibleIterator then return end

    local label = GetLabelControl(control)
    if not label then return end

    local isTop    = IsTopLevelNode(node)
    local isSubcat = IsSubcategoryNode(node)
    if not isTop and not isSubcat then return end

    local collectionsEnabled = db.enableCollections
    local showColor = collectionsEnabled and db.colorCollections
    local showText  = collectionsEnabled and db.textCollections

    local uText, tText, uColor, tColor = GetCollectionsCategoryProgress(categoryData)
    local unlockedText,  totalText  = uText,  tText
    local unlockedColor, totalColor = showColor and uColor or uText, showColor and tColor or tText

    local baseName = categoryData.GetFormattedName and categoryData:GetFormattedName()
        or (label:GetText() or ""):gsub("%s*%(%d+%)$", "")
    if baseName == "" or baseName == nil then return end

    local fullText = baseName .. (showText and unlockedText ~= nil and GetProgressSuffix(unlockedText, totalText) or "")

    if isTop then
        label:SetText(fullText)
        ZO_IconHeader_UpdateSize(control)
    else
        label:SetText(fullText)
    end

    local isSelected = IsNodeSelected(node, isTop, selectedNode)

    local c = showColor and PickColor(unlockedColor, totalColor, isSelected, db) or nil
    ApplyLabelColor(label, c, isSelected, db, COLLECTIONS_BOOK.categoryTree)
end

local function ResetCollectionsNode(node)
    local control = node:GetControl()
    if not control then return end

    local categoryData = node.data
    if not categoryData or not categoryData.CollectibleIterator then return end

    local label = GetLabelControl(control)
    if not label then return end

    ApplyLabelColor(label, nil, false, nil)

    local baseName = categoryData.GetFormattedName and categoryData:GetFormattedName()
        or (label:GetText() or ""):gsub("%s*%(%d+%)$", "")
    if baseName then label:SetText(baseName) end

    if IsTopLevelNode(node) then
        ZO_IconHeader_UpdateSize(control)
    end
end

function TreeProgress.RefreshCollectionsTree()
    local db = Addon.db
    if not db or not db.enabled then return end

    local book = COLLECTIONS_BOOK
    if not book or not book.categoryTree then return end

    local selectedNode = book.categoryTree.selectedNode
    BeginTreeSelectionRefresh(book.categoryTree)
    book.categoryTree:ExecuteOnSubTree(nil, function(node)
        ProcessCollectionsNode(node, db, selectedNode)
    end)
    EndTreeSelectionRefresh(book.categoryTree)

    book.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
end

function TreeProgress.ResetCollectionsTree()
    local book = COLLECTIONS_BOOK
    if not book or not book.categoryTree then return end

    book.categoryTree:ExecuteOnSubTree(nil, function(node)
        ResetCollectionsNode(node)
    end)

    book.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

function TreeProgress.InitializeCollections()
    -- Collections tree: after BuildCategories and SelectNode on instance
    SecurePostHook(ZO_CollectionsBook, "BuildCategories", function(self)
        if self == COLLECTIONS_BOOK then
            zo_callLater(TreeProgress.RefreshCollectionsTree, 0)
        end
    end)

    SecurePostHook(ZO_CollectionsBook, "BuildContentList", function(self)
        if self == COLLECTIONS_BOOK then
            zo_callLater(TreeProgress.RefreshCollectionsTree, 0)
        end
    end)

    -- On first scene open
    EVENT_MANAGER:RegisterForEvent("SBPTreeProgressCollections", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("SBPTreeProgressCollections", EVENT_PLAYER_ACTIVATED)
        if COLLECTIONS_BOOK_SCENE then
            COLLECTIONS_BOOK_SCENE:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWN then
                    TreeProgress.RefreshCollectionsTree()
                end
            end)
        end
    end)
end
