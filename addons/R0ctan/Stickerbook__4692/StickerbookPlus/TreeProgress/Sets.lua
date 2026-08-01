-- StickerbookPlus – TreeProgress: Sets (tree progress, set headers, sorting, hooks)

local Addon = StickerbookPlus
local TreeProgress = Addon.TreeProgress
local Helpers = TreeProgress.Helpers

local GetLabelControl = Helpers.GetLabelControl
local PickColor = Helpers.PickColor
local ApplyLabelColor = Helpers.ApplyLabelColor
local BeginTreeSelectionRefresh = Helpers.BeginTreeSelectionRefresh
local EndTreeSelectionRefresh = Helpers.EndTreeSelectionRefresh
local GetProgressSuffix = Helpers.GetProgressSuffix
local GetBaseName = Helpers.GetBaseName
local GetSubcatMaxWidth = Helpers.GetSubcatMaxWidth
local ApplyTruncation = Helpers.ApplyTruncation
local InstallSubcatTooltip = Helpers.InstallSubcatTooltip
local IsTopLevelNode = Helpers.IsTopLevelNode
local IsSubcategoryNode = Helpers.IsSubcategoryNode
local IsNodeSelected = Helpers.IsNodeSelected
local GetCategoryProgress = Helpers.GetCategoryProgress

-- ── Tree nodes (left side) ────────────────────────────────────────────────────

local function ProcessNode(node, db, selectedNode)
    local control = node:GetControl()
    if not control then return end

    local categoryData = node.data
    if not categoryData then return end

    local label = GetLabelControl(control)
    if not label then return end

    local isTop    = IsTopLevelNode(node)
    local isSubcat = IsSubcategoryNode(node)

    if not isTop and not isSubcat then return end

    local setsEnabled = db.enableSets
    local showColor = (isTop and db.colorCategories and setsEnabled) or (isSubcat and db.colorSubcats and setsEnabled)
    local showText  = (isTop and db.textCategories  and setsEnabled) or (isSubcat and db.textSubcats  and setsEnabled)

    local unlocked, total = GetCategoryProgress(categoryData)
    local baseName = GetBaseName(categoryData, label)

    if baseName == "" or baseName == nil then return end

    local fullText = baseName .. (showText and unlocked ~= nil and GetProgressSuffix(unlocked, total) or "")

    if isTop then
        label:SetText(fullText)
        ZO_IconHeader_UpdateSize(control)
    elseif isSubcat then
        InstallSubcatTooltip(label)
        ApplyTruncation(label, fullText, GetSubcatMaxWidth(node))
    else
        label:SetText(fullText)
    end

    local isSelected = IsNodeSelected(node, isTop, selectedNode)
    local c = showColor and PickColor(unlocked or 0, total or 0, isSelected, db) or nil
    ApplyLabelColor(label, c, isSelected, db, ITEM_SET_COLLECTIONS_BOOK_KEYBOARD.categoryTree)
end

local function ResetNode(node)
    local control = node:GetControl()
    if not control then return end

    if not IsTopLevelNode(node) and not IsSubcategoryNode(node) then return end

    local categoryData = node.data
    local label = GetLabelControl(control)
    if not label then return end

    ApplyLabelColor(label, nil, false, nil)

    local baseName = GetBaseName(categoryData, label)
    label._sbpFullText = nil
    label:SetText(baseName)

    if IsTopLevelNode(node) then
        ZO_IconHeader_UpdateSize(control)
    end
end

-- ── Set header (right side) ───────────────────────────────────────────────────

local g_activeSetHeaders = {}

local function ApplySetHeaderColor(control, db)
    local nameLabel = control.nameLabel
    if not nameLabel then return end

    local headerData = control.dataEntry and control.dataEntry.data and control.dataEntry.data.header
    if not headerData then return end

    local unlocked = headerData:GetNumUnlockedPieces()
    local total    = headerData:GetNumPieces()

    local baseName = headerData:GetFormattedName()
    if db.textSets and db.enableSets then
        nameLabel:SetText(baseName .. GetProgressSuffix(unlocked, total))
    else
        nameLabel:SetText(baseName)
    end

    -- Set header uses direct SetColor, not ZO_SelectableLabel
    local c = (db.colorSets and db.enableSets) and PickColor(unlocked, total, false, db) or nil
    if c then
        nameLabel:SetColor(c.r, c.g, c.b, c.a or 1)
        nameLabel._sbpColored = true
    elseif nameLabel._sbpColored then
        nameLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
        nameLabel._sbpColored = nil
    end
end

local function ResetSetHeaderColor(control)
    local nameLabel = control.nameLabel
    if not nameLabel then return end
    if nameLabel._sbpColored then
        nameLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
        nameLabel._sbpColored = nil
    end
    local headerData = control.dataEntry and control.dataEntry.data and control.dataEntry.data.header
    if headerData then
        nameLabel:SetText(headerData:GetFormattedName())
    end
end

function TreeProgress.RefreshTree()
    local db = Addon.db
    if not db or not db.enabled then return end

    local book = ITEM_SET_COLLECTIONS_BOOK_KEYBOARD
    if not book or not book.categoryTree then return end

    local selectedNode = book.categoryTree.selectedNode
    BeginTreeSelectionRefresh(book.categoryTree)
    book.categoryTree:ExecuteOnSubTree(nil, function(node)
        ProcessNode(node, db, selectedNode)
    end)
    EndTreeSelectionRefresh(book.categoryTree)

    book.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
end

function TreeProgress.RefreshSetHeaders()
    local db = Addon.db
    for control in pairs(g_activeSetHeaders) do
        ApplySetHeaderColor(control, db)
    end
end

local function ResetSetHeaders()
    for control in pairs(g_activeSetHeaders) do
        ResetSetHeaderColor(control)
    end
end

function TreeProgress.ResetTree()
    local book = ITEM_SET_COLLECTIONS_BOOK_KEYBOARD
    if not book or not book.categoryTree then return end

    book.categoryTree:ExecuteOnSubTree(nil, function(node)
        ResetNode(node)
    end)

    book.categoryTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()

    ResetSetHeaders()
    TreeProgress.RefreshSetSort()
end

-- ── Sort set tile list (missing first, per set) ───────────────────────────────
-- Full function replacement, not a hook — duplicates ESO code. See AGENTS.md.

local function InstallSetSortHook()
    local originalRefreshCategoryContentList = ZO_ItemSetsBook_Shared.RefreshCategoryContentList

    ZO_ItemSetsBook_Shared.RefreshCategoryContentList = function(self)
        local db = Addon.db
        if not db or not db.enabled or not db.enableSets or not db.sortMissingSets then
            return originalRefreshCategoryContentList(self)
        end

        local gridListPanelList = self.gridListPanelList
        local entryDataObjectPool = self:GetGridEntryDataObjectPool()
        local headerEntryDataObjectPool = self:GetGridHeaderEntryDataObjectPool()
        local tempUnlockedEntriesForRefresh = self.tempUnlockedEntriesForRefresh
        local tempLockedEntriesForRefresh = self.tempLockedEntriesForRefresh

        gridListPanelList:ClearGridList()
        entryDataObjectPool:ReleaseAllObjects()
        headerEntryDataObjectPool:ReleaseAllObjects()

        local itemSetCollectionCategoryData = self:GetSelectedCategory()
        if itemSetCollectionCategoryData then
            for _, itemSetCollectionData in itemSetCollectionCategoryData:CollectionIterator(self.setFilters) do
                local headerEntryData = headerEntryDataObjectPool:AcquireObject()
                headerEntryData:SetDataSource(itemSetCollectionData)
                headerEntryData.collapsed = self:IsSetHeaderCollapsed(itemSetCollectionData:GetId())
                headerEntryData.headerNarrationFunction = function(...) return self:GetItemSetHeaderNarrationText(...) end
                ZO_ClearNumericallyIndexedTable(tempUnlockedEntriesForRefresh)
                ZO_ClearNumericallyIndexedTable(tempLockedEntriesForRefresh)
                for _, itemSetCollectionPieceData in itemSetCollectionData:PieceIterator(self.pieceFilters) do
                    local entryData = entryDataObjectPool:AcquireObject()
                    entryData:SetDataSource(itemSetCollectionPieceData)
                    entryData.gridHeaderData = headerEntryData
                    if itemSetCollectionPieceData:IsUnlocked() then
                        table.insert(tempUnlockedEntriesForRefresh, entryData)
                    else
                        table.insert(tempLockedEntriesForRefresh, entryData)
                    end
                end

                -- StickerbookPlus: missing (locked) first instead of unlocked first
                for _, entryData in ipairs(tempLockedEntriesForRefresh) do
                    gridListPanelList:AddEntry(entryData)
                end
                for _, entryData in ipairs(tempUnlockedEntriesForRefresh) do
                    gridListPanelList:AddEntry(entryData)
                end
            end
        end

        gridListPanelList:CommitGridList()
    end
end

function TreeProgress.RefreshSetSort()
    local book = ITEM_SET_COLLECTIONS_BOOK_KEYBOARD
    if not book or not book.categoryContentRefreshGroup then return end
    book.categoryContentRefreshGroup:MarkDirty("List")
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

function TreeProgress.InitializeSets()
    InstallSetSortHook()

    -- Tree nodes: after visible refresh and after category selection
    SecurePostHook(ZO_ItemSetsBook_Keyboard, "RefreshVisibleCategories", function()
        TreeProgress.RefreshTree()
    end)

    SecurePostHook(ZO_ItemSetsBook_Keyboard, "RefreshCategoryProgress", function()
        TreeProgress.RefreshTree()
    end)

    -- Set header: after each grid header setup
    SecurePostHook(ZO_ItemSetsBook_Keyboard, "SetupGridHeaderEntry", function(_, control)
        g_activeSetHeaders[control] = true
        local db = Addon.db
        if not db or not db.enabled then
            ResetSetHeaderColor(control)
            return
        end
        ApplySetHeaderColor(control, db)
    end)

    -- On first scene open
    EVENT_MANAGER:RegisterForEvent("SBPTreeProgressSets", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("SBPTreeProgressSets", EVENT_PLAYER_ACTIVATED)
        if ITEM_SETS_BOOK_SCENE then
            ITEM_SETS_BOOK_SCENE:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWN then
                    TreeProgress.RefreshTree()
                end
            end)
        end
    end)
end
