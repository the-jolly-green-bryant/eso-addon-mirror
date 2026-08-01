-- StickerbookPlus – TreeProgress: Lore library (tree progress, sorting, hooks)

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

-- ── Compute lore progress ─────────────────────────────────────────────────────

local function GetLoreNodeProgress(node)
    local data = node.data
    if not data then return nil, nil end

    if data.mailListIndex ~= nil then
        -- Disabled mail entries (not yet unlocked): don't count
        if (data.numUnlocked or 0) == 0 then return nil, nil end
        return data.numUnlocked, data.total
    end

    if data.collectionIndex ~= nil then
        return data.numKnownBooks, data.totalBooks
    end

    -- Top-level node (category): aggregate over child nodes (book collections + mail lists)
    local unlocked, total = 0, 0
    local hasChildren = false
    for _, child in ipairs(node.children or {}) do
        local cd = child.data
        if cd then
            if cd.collectionIndex ~= nil then
                unlocked = unlocked + (cd.numKnownBooks or 0)
                total    = total    + (cd.totalBooks    or 0)
                hasChildren = true
            elseif cd.mailListIndex ~= nil and (cd.numUnlocked or 0) > 0 then
                unlocked = unlocked + cd.numUnlocked
                total    = total    + (cd.total or 0)
                hasChildren = true
            end
        end
    end
    if not hasChildren then return nil, nil end
    return unlocked, total
end

-- ── Lore hover fix ────────────────────────────────────────────────────────────
-- ZO_LoreLibraryNavigationEntry has no native OnMouseEnter/Exit; install once per label
-- so hover behaves consistently with Outfits/Collections/Sets.

local function InstallLoreHoverHandlers(label)
    if label._sbpHoverInstalled then return end
    label._sbpHoverInstalled = true
    label:SetHandler("OnMouseEnter", function(self)
        ZO_SelectableLabel_OnMouseEnter(self)
    end)
    label:SetHandler("OnMouseExit", function(self)
        ZO_SelectableLabel_OnMouseExit(self)
    end)
end

-- ── Lore tree nodes ────────────────────────────────────────────────────────────

local function ProcessLoreNode(node, db, selectedNode)
    local control = node:GetControl()
    if not control then return end

    local data = node.data
    if not data then return end

    local label = GetLabelControl(control)
    if not label then return end

    local isTop    = IsTopLevelNode(node)
    local isSubcat = IsSubcategoryNode(node)
    if not isTop and not isSubcat then return end

    -- Disabled mail entries: ESO already grays them out itself
    if isSubcat and data.mailListIndex ~= nil and (data.numUnlocked or 0) == 0 then return end

    if isSubcat then
        InstallLoreHoverHandlers(label)
    end

    local loreEnabled = db.enableLore
    local showColor = loreEnabled and db.colorLore
    local showText  = loreEnabled and db.textLore

    local unlocked, total = GetLoreNodeProgress(node)

    local baseName = data.name
    if not baseName or baseName == "" then return end

    local fullText = baseName .. (showText and unlocked ~= nil and GetProgressSuffix(unlocked, total) or "")
    label:SetText(fullText)

    local isSelected = IsNodeSelected(node, isTop, selectedNode)

    local c = showColor and PickColor(unlocked or 0, total or 0, isSelected, db) or nil
    ApplyLabelColor(label, c, isSelected, db, LORE_LIBRARY.navigationTree)
end


local function RefreshLoreTotalLabel()
    local lib = LORE_LIBRARY
    if not lib then return end
    local label = lib.totalCollectedLabel
    if not label then return end
    local possible  = lib.totalPossibleCollected
    local collected = lib.totalCurrentlyCollected
    if type(possible) ~= "number" or type(collected) ~= "number" then return end
    label:SetText(zo_strformat(SI_LORE_LIBRARY_TOTAL_COLLECTED, collected, possible))
    local db = Addon.db
    if not db or not db.enabled or not db.enableLore or not db.textLore then return end
    local missing = possible - collected
    if missing > 0 then
        label:SetText(label:GetText() .. zo_strformat(GetString(SBP_LORE_TOTAL_MISSING_SUFFIX), missing))
    end
end

function TreeProgress.RefreshLoreTree()
    local db = Addon.db
    if not db or not db.enabled or not db.enableLore then return end

    if not LORE_LIBRARY or not LORE_LIBRARY.navigationTree then return end

    local selectedNode = LORE_LIBRARY.navigationTree.selectedNode
    BeginTreeSelectionRefresh(LORE_LIBRARY.navigationTree)
    LORE_LIBRARY.navigationTree:ExecuteOnSubTree(nil, function(node)
        ProcessLoreNode(node, db, selectedNode)
    end)
    EndTreeSelectionRefresh(LORE_LIBRARY.navigationTree)

    LORE_LIBRARY.navigationTree.rootNode:UpdateAllChildrenHeightsAndCurrentHeights()
    RefreshLoreTotalLabel()
end

-- ── Sort lore book list (missing first) ───────────────────────────────────────
-- Patches the LORE_LIBRARY.list instance directly; the class itself is file-local
-- in ESO source and unreachable. See AGENTS.md.
-- Deliberately separate from Overlay.ShouldMarkMissing: reads GetLoreBookInfo()
-- directly rather than tileObj._sbpIsUnlocked, since sorting runs at a
-- different point in the scroll-list lifecycle than the overlay refresh.

local function SBPMissingFirstBookComparator(leftScrollData, rightScrollData)
    local leftData = leftScrollData.data
    local rightData = rightScrollData.data
    local leftTitle, _, leftKnown = GetLoreBookInfo(leftData.categoryIndex, leftData.collectionIndex, leftData.bookIndex)
    local rightTitle, _, rightKnown = GetLoreBookInfo(rightData.categoryIndex, rightData.collectionIndex, rightData.bookIndex)

    if leftKnown == rightKnown then
        return leftTitle < rightTitle
    end

    return not leftKnown
end

local function InstallLoreSortHook()
    local lib = LORE_LIBRARY
    local scrollListInstance = lib and lib.list
    if not scrollListInstance or scrollListInstance._sbpSortHooked then return end
    scrollListInstance._sbpSortHooked = true

    local originalSortScrollList = scrollListInstance.SortScrollList

    scrollListInstance.SortScrollList = function(self, ...)
        local db = Addon.db
        if not db or not db.enabled or not db.enableLore or not db.sortMissingLore then
            return originalSortScrollList(self, ...)
        end

        local scrollData = ZO_ScrollList_GetDataList(self.list)
        local categoryData = self.owner.navigationTree:GetSelectedData()
        if categoryData and categoryData.mailListIndex == nil then
            table.sort(scrollData, SBPMissingFirstBookComparator)
        end
    end
end

function TreeProgress.RefreshLoreSort()
    -- Before the library's first visit, the book list isn't initialized yet;
    -- RefreshSort() would fail on a never-shown ScrollList.
    if not LORE_LIBRARY or not LORE_LIBRARY.list or not LORE_LIBRARY.navigationTree then return end
    if not LORE_LIBRARY.navigationTree:GetSelectedData() then return end
    LORE_LIBRARY.list:RefreshSort()
end

function TreeProgress.ResetLoreTree()
    if not LORE_LIBRARY or not LORE_LIBRARY.navigationTree then return end
    LORE_LIBRARY.navigationTree:ExecuteOnSubTree(nil, function(node)
        local control = node:GetControl()
        if not control then return end
        local label = GetLabelControl(control)
        if not label then return end
        if label._sbpHoverInstalled then
            label._sbpHoverInstalled = nil
            label:SetHandler("OnMouseEnter", nil)
            label:SetHandler("OnMouseExit", nil)
            label.mouseover = false
            label:RefreshTextColor()
        end
        ApplyLabelColor(label, nil, false, nil)
    end)
    LORE_LIBRARY:BuildCategoryList()
    TreeProgress.RefreshLoreSort()
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

-- ZO_LoreLibrary_OnInitialize runs before EVENT_ADD_ON_LOADED, so our hook on it only
-- fires on next call; check on EVENT_PLAYER_ACTIVATED whether LORE_LIBRARY already exists.
function TreeProgress.InitializeLore()
    local function InstallLoreLibraryHooks()
        local lib = LORE_LIBRARY
        if not lib then return end

        InstallLoreSortHook()

        SecurePostHook(lib, "BuildCategoryList", function()
            zo_callLater(TreeProgress.RefreshLoreTree, 0)
            if lib.navigationTree and not lib.navigationTree._sbpSelectHook then
                lib.navigationTree._sbpSelectHook = true
                -- Select the first enabled child when a header is expanded
                SecurePostHook(lib.navigationTree, "SetNodeOpen", function(tree, treeNode, open, userRequested)
                    if open and userRequested then
                        local children = treeNode:GetChildren()
                        if children then
                            for _, child in ipairs(children) do
                                if child:IsEnabled() then
                                    tree:SelectNode(child)
                                    break
                                end
                            end
                        end
                    end
                end)
                SecurePostHook(lib.navigationTree, "SelectNode", function()
                    zo_callLater(TreeProgress.RefreshLoreTree, 0)
                end)
            end
        end)

        SecurePostHook(lib, "RefreshCollectedInfo", function(self)
            if self ~= LORE_LIBRARY then return end
            RefreshLoreTotalLabel()
        end)

        if LORE_LIBRARY_SCENE then
            LORE_LIBRARY_SCENE:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWN then
                    TreeProgress.RefreshLoreTree()
                end
            end)
        end
    end

    SecurePostHook("ZO_LoreLibrary_OnInitialize", function()
        if LORE_LIBRARY and not LORE_LIBRARY._sbpHooked then
            LORE_LIBRARY._sbpHooked = true
            InstallLoreLibraryHooks()
        end
    end)

    -- Normal case: LORE_LIBRARY already exists by now, install hooks immediately
    if LORE_LIBRARY and not LORE_LIBRARY._sbpHooked then
        LORE_LIBRARY._sbpHooked = true
        InstallLoreLibraryHooks()
    end

    -- Fallback in case LORE_LIBRARY is created later
    EVENT_MANAGER:RegisterForEvent("SBPTreeProgressLore", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent("SBPTreeProgressLore", EVENT_PLAYER_ACTIVATED)
        if LORE_LIBRARY and not LORE_LIBRARY._sbpHooked then
            LORE_LIBRARY._sbpHooked = true
            InstallLoreLibraryHooks()
        end
        zo_callLater(TreeProgress.RefreshLoreTree, 0)
    end)
end
