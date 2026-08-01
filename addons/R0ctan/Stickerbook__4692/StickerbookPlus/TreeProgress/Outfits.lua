-- StickerbookPlus – TreeProgress: Outfits (tree progress, sorting, hooks)

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

-- ── Compute outfit progress ───────────────────────────────────────────────────

local function CountOutfitCollectibles(categoryData, unlocked, total)
    local db = Addon.db
    local countHidden = db and db.countHiddenCollectibles
    for _, collectibleData in categoryData:CollectibleIterator() do
        if countHidden or collectibleData:IsShownInCollection() then
            total = total + 1
            if collectibleData:IsUnlocked() then unlocked = unlocked + 1 end
        end
    end
    return unlocked, total
end

local function GetOutfitCategoryProgress(categoryData)
    local unlocked, total = 0, 0
    if categoryData.isTopLevelCategory then
        -- Top-level: CollectibleIterator aggregates all subcats; iterate subcats instead
        local hasSubcats = categoryData:GetNumSubcategories() > 0
        if hasSubcats then
            for _, subcatData in categoryData:SubcategoryIterator() do
                unlocked, total = CountOutfitCollectibles(subcatData, unlocked, total)
            end
        else
            unlocked, total = CountOutfitCollectibles(categoryData, 0, 0)
        end
    else
        unlocked, total = CountOutfitCollectibles(categoryData, 0, 0)
    end
    return unlocked, total
end

-- ── Outfit tree nodes ──────────────────────────────────────────────────────────

local function ProcessOutfitNode(node, db, selectedNode)
    local control = node:GetControl()
    if not control then return end

    local nodeData = node.data
    if not nodeData then return end

    local referenceData = nodeData.referenceData
    if not referenceData then return end

    if not referenceData.CollectibleIterator then return end

    local label = GetLabelControl(control)
    if not label then return end

    local isTop    = IsTopLevelNode(node)
    local isSubcat = IsSubcategoryNode(node)
    if not isTop and not isSubcat then return end

    local outfitsEnabled = db.enableOutfits
    local showColor = outfitsEnabled and db.colorOutfits
    local showText  = outfitsEnabled and db.textOutfits

    local unlocked, total = GetOutfitCategoryProgress(referenceData)

    local baseName = nodeData.name or (label:GetText() or ""):gsub("%s*%(%d+%)$", "")
    if baseName == "" then return end

    local fullText = baseName .. (showText and unlocked ~= nil and GetProgressSuffix(unlocked, total) or "")

    if isTop then
        label:SetText(fullText)
        ZO_IconHeader_UpdateSize(control)
    else
        label:SetText(fullText)
    end

    local isSelected = IsNodeSelected(node, isTop, selectedNode)

    local c = showColor and PickColor(unlocked, total, isSelected, db) or nil
    ApplyLabelColor(label, c, isSelected, db, ZO_OUTFIT_STYLES_BOOK_KEYBOARD.categoryTree)
end

local function ResetOutfitNode(node)
    local control = node:GetControl()
    if not control then return end

    local nodeData = node.data
    if not nodeData then return end

    local referenceData = nodeData.referenceData
    if not referenceData or not referenceData.CollectibleIterator then return end

    local label = GetLabelControl(control)
    if not label then return end

    ApplyLabelColor(label, nil, false, nil)

    if IsTopLevelNode(node) then
        ZO_IconHeader_UpdateSize(control)
    end
end

function TreeProgress.RefreshOutfitTree()
    local db = Addon.db
    if not db or not db.enabled then return end

    local book = ZO_OUTFIT_STYLES_BOOK_KEYBOARD
    if not book or not book.categoryTree then return end

    local selectedNode = book.categoryTree.selectedNode
    BeginTreeSelectionRefresh(book.categoryTree)
    book.categoryTree:ExecuteOnSubTree(nil, function(node)
        ProcessOutfitNode(node, db, selectedNode)
    end)
    EndTreeSelectionRefresh(book.categoryTree)

    book.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
end

function TreeProgress.ResetOutfitTree()
    local book = ZO_OUTFIT_STYLES_BOOK_KEYBOARD
    if not book or not book.categoryTree then return end

    book.categoryTree:ExecuteOnSubTree(nil, function(node)
        ResetOutfitNode(node)
    end)

    book.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
    TreeProgress.RefreshOutfitSort()
end

-- ── Sort outfit tile list (missing first, per equipment slot) ────────────────
-- Full function replacement on ZO_SpecializedSortedOutfitStyles.RefreshSort. See AGENTS.md.

-- Must mark dirty before every RefreshVisible() call, not just on settings toggle. See AGENTS.md.
local function MarkOutfitSortersDirty()
    local panel = ZO_OUTFIT_STYLES_PANEL_KEYBOARD
    if not panel or not panel.collectibleCategoryData then return end
    local sortedByType = panel.collectibleCategoryData:GetSpecializedSortedCollectiblesObject()
    if sortedByType and sortedByType.sortedCollectibles then
        for _, sortedStyles in pairs(sortedByType.sortedCollectibles) do
            sortedStyles.dirty = true
        end
    end
end

local function InstallOutfitSortHook()
    ZO_PreHook(ZO_OutfitStylesPanel_Keyboard, "RefreshVisible", function(self)
        local db = Addon.db
        if db and db.enabled and db.enableOutfits and db.sortMissingOutfits then
            MarkOutfitSortersDirty()
        end
        return false
    end)

    local originalRefreshSort = ZO_SpecializedSortedOutfitStyles.RefreshSort

    ZO_SpecializedSortedOutfitStyles.RefreshSort = function(self, ...)
        local db = Addon.db
        if not db or not db.enabled or not db.enableOutfits or not db.sortMissingOutfits then
            return originalRefreshSort(self, ...)
        end

        if self.dirty then
            local itemStyleNameLookupTable = self.owner.itemStyleNameLookupTable
            local collectibleNameLookupTable = self.collectibleNameLookupTable
            table.sort(self.sortedCollectibles, function(left, right)
                local leftMissing = Addon.Overlay.IsOutfitCollectibleMissing(left, db)
                local rightMissing = Addon.Overlay.IsOutfitCollectibleMissing(right, db)
                if leftMissing ~= rightMissing then
                    return leftMissing
                end

                local leftIsValidForCharacter = IsCollectibleValidForPlayer(left:GetId())
                local rightIsValidForCharacter = IsCollectibleValidForPlayer(right:GetId())
                if leftIsValidForCharacter ~= rightIsValidForCharacter then
                    return leftIsValidForCharacter
                end

                local leftOutfitStyleItemStyleId = left:GetOutfitStyleItemStyleId()
                local rightOutfitStyleItemStyleId = right:GetOutfitStyleItemStyleId()
                if leftOutfitStyleItemStyleId ~= rightOutfitStyleItemStyleId then
                    return itemStyleNameLookupTable[leftOutfitStyleItemStyleId] < itemStyleNameLookupTable[rightOutfitStyleItemStyleId]
                end

                local leftSortOrder = left:GetSortOrder()
                local rightSortOrder = right:GetSortOrder()
                if leftSortOrder ~= rightSortOrder then
                    return leftSortOrder < rightSortOrder
                else
                    return collectibleNameLookupTable[left:GetId()] < collectibleNameLookupTable[right:GetId()]
                end
            end)
        end

        self.dirty = false
    end
end

function TreeProgress.RefreshOutfitSort()
    local panel = ZO_OUTFIT_STYLES_PANEL_KEYBOARD
    if not panel then return end
    MarkOutfitSortersDirty()
    panel:RefreshVisible()
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

-- See the equivalent guard in TreeProgress/Achievements.lua: hooking SelectNode
-- only inside a one-time OnDeferredInitialize PostHook misses the tree entirely
-- if another addon deferred-initializes this scene before this addon's own
-- hook is installed.
local g_outfitSelectNodeHooked = false

local function EnsureOutfitSelectNodeHook()
    if g_outfitSelectNodeHooked then return end
    if not ZO_OUTFIT_STYLES_BOOK_KEYBOARD or not ZO_OUTFIT_STYLES_BOOK_KEYBOARD.categoryTree then return end

    g_outfitSelectNodeHooked = true
    SecurePostHook(ZO_OUTFIT_STYLES_BOOK_KEYBOARD.categoryTree, "SelectNode", function()
        zo_callLater(TreeProgress.RefreshOutfitTree, 0)
    end)
end

function TreeProgress.InitializeOutfits()
    -- Outfit tree: after BuildCategories (zo_callLater so ESO finishes building the tree)
    SecurePostHook(ZO_RestyleCommon_Keyboard, "BuildCategories", function(self)
        if self == ZO_OUTFIT_STYLES_BOOK_KEYBOARD then
            EnsureOutfitSelectNodeHook()
            zo_callLater(TreeProgress.RefreshOutfitTree, 0)
        end
    end)

    SecurePostHook(ZO_RestyleCommon_Keyboard, "OnDeferredInitialize", function(self)
        if self == ZO_OUTFIT_STYLES_BOOK_KEYBOARD then
            EnsureOutfitSelectNodeHook()
        end
    end)

    EnsureOutfitSelectNodeHook()

    InstallOutfitSortHook()

    -- On first scene open
    EVENT_MANAGER:RegisterForEvent("SBPTreeProgressOutfits", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("SBPTreeProgressOutfits", EVENT_PLAYER_ACTIVATED)
        if ZO_OUTFIT_STYLES_BOOK_SCENE then
            ZO_OUTFIT_STYLES_BOOK_SCENE:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWN then
                    TreeProgress.RefreshOutfitTree()
                end
            end)
        end
    end)
end
