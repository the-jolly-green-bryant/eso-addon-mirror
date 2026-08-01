-- StickerbookPlus – TreeProgress (progress text + coloring in the category tree)

local Addon = StickerbookPlus
local TreeProgress = {}
Addon.TreeProgress = TreeProgress

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function IsSelectableLabel(label)
    return label ~= nil
        and label.normalColor ~= nil
        and label.GetTextColor ~= nil
        and label.RefreshTextColor ~= nil
end

local function GetLabelControl(control)
    if control.text and IsSelectableLabel(control.text) then
        return control.text
    end
    if IsSelectableLabel(control) then
        return control
    end
    return nil
end

local function GetCategoryProgress(categoryData)
    local ds = categoryData.GetDataSource and categoryData:GetDataSource()
    if ds and ds.GetNumUnlockedAndTotalPieces then
        return ds:GetNumUnlockedAndTotalPieces()
    end
    if categoryData.GetNumUnlockedAndTotalPieces then
        return categoryData:GetNumUnlockedAndTotalPieces()
    end
    return nil, nil
end

local function IsTopLevelNode(node)
    return node.parentNode ~= nil and node.parentNode.parentNode == nil
end

local function IsSubcategoryNode(node)
    return node.parentNode ~= nil
        and node.parentNode.parentNode ~= nil
        and node.parentNode.parentNode.parentNode == nil
end

local function IsNodeSelected(node, isTop, selectedNode)
    return (node == selectedNode)
        or (isTop and selectedNode ~= nil and selectedNode.parentNode == node)
end

-- ── Pick color ────────────────────────────────────────────────────────────────

local function PickColor(unlocked, total, selected, db)
    if total == nil or total == 0 then return nil end

    if selected and db.colorSelectedEnabled then
        return db.colorSelected
    end
    if unlocked >= total then
        return db.colorCompleteEnabled and db.colorComplete or nil
    elseif unlocked == 0 then
        return db.colorMissingEnabled and db.colorMissing or nil
    else
        return db.colorPartialEnabled and db.colorPartial or nil
    end
end


-- Only removes the selected-state GetTextColor override, not the normalColor
-- progress coloring — a label that's no longer selected still keeps its
-- complete/partial/missing color, it just stops forcing the selected color.
local function ClearLabelColorOverride(label)
    if label._sbpOriginalGetTextColor then
        label.GetTextColor = label._sbpOriginalGetTextColor
        label._sbpOriginalGetTextColor = nil
        label:RefreshTextColor()
    end
end

-- Tracks the labels currently colored as "selected" per tree, keyed by the
-- tree's categoryTree table (a node can have more than one selected label at
-- once: the selected node itself plus its top-level parent header, see
-- IsNodeSelected). A stray selected-label override can otherwise survive on a
-- pooled control that a later refresh never revisits (e.g. Achievements,
-- whose category tree can be deferred-initialized by another addon before
-- this addon's own hook is installed, silently dropping the SelectNode hook
-- for the rest of the session) — so RefreshXTree brackets its full-tree pass
-- with BeginTreeSelectionRefresh/EndTreeSelectionRefresh, and any label that
-- was selected on the previous refresh but not the current one is explicitly
-- cleared, regardless of whether its node was revisited this time.
local g_selectedLabelsByTree = setmetatable({}, { __mode = "k" })

local function BeginTreeSelectionRefresh(treeKey)
    if not treeKey then return end
    g_selectedLabelsByTree[treeKey] = { previous = g_selectedLabelsByTree[treeKey] and g_selectedLabelsByTree[treeKey].current, current = {} }
end

local function EndTreeSelectionRefresh(treeKey)
    if not treeKey then return end
    local state = g_selectedLabelsByTree[treeKey]
    if not state then return end
    if state.previous then
        for label in pairs(state.previous) do
            if not state.current[label] then
                ClearLabelColorOverride(label)
            end
        end
    end
    state.previous = nil
end

-- Sets normalColor for normal state; selected state overrides GetTextColor when enabled
local function ApplyLabelColor(label, c, isSelected, db, treeKey)
    -- Remove previous GetTextColor override, restore original
    if label._sbpOriginalGetTextColor then
        label.GetTextColor = label._sbpOriginalGetTextColor
        label._sbpOriginalGetTextColor = nil
    end

    if treeKey and isSelected then
        local state = g_selectedLabelsByTree[treeKey]
        if state then
            state.current[label] = true
        end
    end

    if not c then
        if label._sbpOriginalColor then
            label.normalColor = label._sbpOriginalColor
            label._sbpOriginalColor = nil
            label:RefreshTextColor()
        end
        return
    end

    if not label._sbpOriginalColor then
        label._sbpOriginalColor = label.normalColor
    end
    label.normalColor = ZO_ColorDef:New(c.r, c.g, c.b, c.a or 1)

    -- Override GetTextColor so ESO's selected state shows our color
    if isSelected and db and db.colorSelectedEnabled then
        local sc = db.colorSelected
        label._sbpOriginalGetTextColor = label.GetTextColor
        label.GetTextColor = function(self)
            if self.mouseover then
                return ZO_HIGHLIGHT_TEXT:UnpackRGBA()
            end
            return sc.r, sc.g, sc.b, sc.a or 1
        end
    end

    label:RefreshTextColor()
end

-- ── Compute text suffix ───────────────────────────────────────────────────────

local function GetProgressSuffix(unlocked, total)
    if total == nil or total == 0 then return "" end
    local missing = total - unlocked
    if missing <= 0 then return "" end
    return " (" .. missing .. ")"
end

-- Combines two independent missing-counters per setting: first only "(3)", second only
-- "(150)", both "(3/150)". Shared by Achievements (count/points) and Antiquities (found/codex).
local function GetTwoCounterSuffix(missingFirst, missingSecond, showFirst, showSecond)
    if showFirst and showSecond then
        if missingFirst <= 0 and missingSecond <= 0 then return "" end
        return " (" .. missingFirst .. "/" .. missingSecond .. ")"
    elseif showFirst then
        if missingFirst <= 0 then return "" end
        return " (" .. missingFirst .. ")"
    elseif showSecond then
        if missingSecond <= 0 then return "" end
        return " (" .. missingSecond .. ")"
    end
    return ""
end

local function GetBaseName(categoryData, label)
    local name = categoryData.GetFormattedName and categoryData:GetFormattedName()
    if not name then
        name = label:GetText() or ""
        name = name:gsub("%s*%(%d+%)$", "")
    end
    return name
end

local ELLIPSIS = "..."

local function GetSubcatMaxWidth(node)
    local scrollW = node.tree and node.tree.scrollControl and node.tree.scrollControl:GetWidth() or 0
    local containerIndent = node:ComputeTotalIndentFrom(node.parentNode)
    local labelIndent = node.childIndent or 0
    return scrollW - containerIndent - labelIndent + 5
end

-- Achievement tree needs a wider margin than Sets/Lore (own indent/icons); see AGENTS.md.
local function GetAchievementSubcatMaxWidth(node)
    local scrollW = node.tree and node.tree.scrollControl and node.tree.scrollControl:GetWidth() or 0
    local containerIndent = node:ComputeTotalIndentFrom(node.parentNode)
    local labelIndent = node.childIndent or 0
    return scrollW - containerIndent - labelIndent + 20
end

local function MeasureText(fontObject, text)
    return GetStringWidthScaled(fontObject, text, 1, SPACE_INTERFACE)
end

local function ApplyTruncation(label, fullText, maxWidth)
    label._sbpFullText = nil
    if maxWidth <= 0 then
        label:SetText(fullText)
        return
    end
    local fontObject = _G[label:GetFont()]
    if not fontObject then
        label:SetText(fullText)
        return
    end
    if MeasureText(fontObject, fullText) <= maxWidth then
        label:SetText(fullText)
        return
    end
    -- Text too wide: truncate character by character
    local truncated = ""
    for i = 1, #fullText do
        if MeasureText(fontObject, fullText:sub(1, i) .. ELLIPSIS) > maxWidth then
            break
        end
        truncated = fullText:sub(1, i)
    end
    label:SetText(truncated .. ELLIPSIS)
    label._sbpFullText = fullText
end

local function InstallSubcatTooltip(label)
    if label._sbpTooltipInstalled then return end
    label._sbpTooltipInstalled = true
    label:SetHandler("OnMouseEnter", function(self)
        ZO_SelectableLabel_OnMouseEnter(self)
        if self._sbpFullText then
            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 0, TOP)
            SetTooltipText(InformationTooltip, self._sbpFullText)
        end
    end)
    label:SetHandler("OnMouseExit", function(self)
        ZO_SelectableLabel_OnMouseExit(self)
        ClearTooltip(InformationTooltip)
    end)
end

-- ── Shared helpers for area submodules (TreeProgress/*.lua) ───────────────────
-- Internal use only between TreeProgress files, not part of the public API.

TreeProgress.Helpers = {
    GetLabelControl = GetLabelControl,
    PickColor = PickColor,
    ApplyLabelColor = ApplyLabelColor,
    BeginTreeSelectionRefresh = BeginTreeSelectionRefresh,
    EndTreeSelectionRefresh = EndTreeSelectionRefresh,
    GetProgressSuffix = GetProgressSuffix,
    GetTwoCounterSuffix = GetTwoCounterSuffix,
    GetBaseName = GetBaseName,
    GetSubcatMaxWidth = GetSubcatMaxWidth,
    GetAchievementSubcatMaxWidth = GetAchievementSubcatMaxWidth,
    ApplyTruncation = ApplyTruncation,
    InstallSubcatTooltip = InstallSubcatTooltip,
    IsTopLevelNode = IsTopLevelNode,
    IsSubcategoryNode = IsSubcategoryNode,
    IsNodeSelected = IsNodeSelected,
    GetCategoryProgress = GetCategoryProgress,
}


-- ── Public interface ──────────────────────────────────────────────────────────

function TreeProgress.Refresh()
    TreeProgress.RefreshTree()
    TreeProgress.RefreshSetHeaders()
    TreeProgress.RefreshSetSort()
    TreeProgress.RefreshOutfitTree()
    TreeProgress.RefreshOutfitSort()
    TreeProgress.RefreshCollectionsTree()
    TreeProgress.RefreshLoreTree()
    TreeProgress.RefreshLoreSort()
    TreeProgress.RefreshAchievementsTree()
    TreeProgress.RefreshAchievementLineThumbs()
    TreeProgress.RefreshAchievementsSort()
    TreeProgress.RefreshAntiquitiesTree()
    TreeProgress.RefreshAntiquitiesSort()
end

function TreeProgress.Reset()
    TreeProgress.ResetTree()
    TreeProgress.ResetOutfitTree()
    TreeProgress.ResetCollectionsTree()
    TreeProgress.ResetLoreTree()
    TreeProgress.ResetAchievementsTree()
    TreeProgress.ResetAntiquitiesTree()
end

-- ── Install hooks ─────────────────────────────────────────────────────────────

function TreeProgress.Initialize()
    TreeProgress.InitializeSets()
    TreeProgress.InitializeOutfits()
    TreeProgress.InitializeCollections()
    TreeProgress.InitializeLore()
    TreeProgress.InitializeAchievements()
    TreeProgress.InitializeAntiquities()
end
