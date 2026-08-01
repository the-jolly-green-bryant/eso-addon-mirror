LootLog = LootLog or {}
local LL = LootLog

local LOOTLOG_LIST_ENTRY_TYPE = 1
local UI_MAX_VISIBLE_ITEMS = 200

local UI_SCOPE_ORDER = { "session", "manual", "lifetime" }
local UI_SCOPE_LABELS = {
    session = "Session",
    manual = "Last reset",
    lifetime = "All time",
}
local QUALITY_NORMAL = ITEM_DISPLAY_QUALITY_NORMAL or 1
local QUALITY_GREEN = ITEM_DISPLAY_QUALITY_MAGIC or 2
local QUALITY_BLUE = ITEM_DISPLAY_QUALITY_ARCANE or 3
local QUALITY_LILA = ITEM_DISPLAY_QUALITY_ARTIFACT or 4
local QUALITY_GOLD = ITEM_DISPLAY_QUALITY_LEGENDARY or 5
local ACTIVE_EDGE_COLOR = { 1.0, 1.0, 1.0, 1.0 }
local ACTIVE_FILL_COLOR = { 0.96, 0.96, 0.96, 0.99 }
local ACTIVE_ACTION_TEXT_COLOR = { 1.0, 1.0, 1.0, 1.0 }
local ACTIVE_LABEL_COLOR = { 1.0, 0.88, 0.36, 1.0 }
local INACTIVE_EDGE_COLOR = { 0.24, 0.24, 0.24, 0.75 }
local INACTIVE_FILL_COLOR = { 0.03, 0.03, 0.03, 0.72 }
local INACTIVE_TEXT_COLOR = { 0.74, 0.74, 0.74, 1.0 }
local RARITY_FILTER_OPTIONS = {
    { label = "All", quality = nil },
    { label = "White", quality = QUALITY_NORMAL },
    { label = "Green", quality = QUALITY_GREEN },
    { label = "Blue", quality = QUALITY_BLUE },
    { label = "Lila", quality = QUALITY_LILA },
    { label = "Gold", quality = QUALITY_GOLD },
}

local function NormalizeScope(scope)
    for _, candidate in ipairs(UI_SCOPE_ORDER) do
        if scope == candidate then
            return candidate
        end
    end
    return "session"
end

local function GetUIScopeLabel(scope)
    return UI_SCOPE_LABELS[NormalizeScope(scope)] or UI_SCOPE_LABELS.session
end

local function GetScopeBucket(scope)
    local normalizedScope = NormalizeScope(scope)
    if normalizedScope == "lifetime" then
        return LL.saved and LL.saved.lifetime or nil
    end
    if normalizedScope == "manual" then
        return LL.saved and LL.saved.manual or nil
    end
    return LL.session
end

local function GetRelativeScope(currentScope, direction)
    local normalizedScope = NormalizeScope(currentScope)
    local currentIndex = 1
    for index, scopeName in ipairs(UI_SCOPE_ORDER) do
        if scopeName == normalizedScope then
            currentIndex = index
            break
        end
    end

    local step = direction and tonumber(direction) or 0
    if step == 0 then
        return normalizedScope
    end

    local nextIndex = ((currentIndex - 1 + step) % #UI_SCOPE_ORDER) + 1
    return UI_SCOPE_ORDER[nextIndex]
end

local function CountKeys(t)
    local count = 0
    if t then
        for _ in pairs(t) do
            count = count + 1
        end
    end
    return count
end

local function GetNowMilliseconds()
    if type(GetGameTimeMilliseconds) == "function" then
        return tonumber(GetGameTimeMilliseconds())
    end
    if type(GetFrameTimeMilliseconds) == "function" then
        return tonumber(GetFrameTimeMilliseconds())
    end
    return nil
end

local function MeasureCallMilliseconds(callback)
    local startedAt = GetNowMilliseconds()
    local results = { callback() }
    local finishedAt = GetNowMilliseconds()
    local elapsedMs = 0
    if startedAt ~= nil and finishedAt ~= nil then
        elapsedMs = math.max(0, finishedAt - startedAt)
    end
    return elapsedMs, unpack(results)
end

local function BuildSummaryText(scope)
    local bucket = GetScopeBucket(scope) or {}
    local items = bucket.items or {}
    local instances = bucket.instances or {}
    local startedAtText = LL.FormatTimestamp(bucket.startedAt)
    local uniqueItems = CountKeys(items)
    local totalInteractions = tonumber(instances.Total) or 0
    local itemSummary = string.format("Unique items: %d", uniqueItems)

    if uniqueItems > UI_MAX_VISIBLE_ITEMS then
        itemSummary = string.format("Unique items: %d (display limited to %d)", uniqueItems, UI_MAX_VISIBLE_ITEMS)
    end

    return string.format(
        "Started: %s   %s   Interactions: %d",
        startedAtText,
        itemSummary,
        totalInteractions
    )
end

local function GetNoResultsText()
    if SI_SORT_FILTER_LIST_NO_RESULTS and type(GetString) == "function" then
        return GetString(SI_SORT_FILTER_LIST_NO_RESULTS)
    end
    return "No results."
end

local function GetDefaultEmptyStateText()
    return "No loot entries yet."
end

local function NormalizeFilterText(rawText)
    local text = rawText or ""
    if type(zo_strtrim) == "function" then
        text = zo_strtrim(text)
    end
    text = text:gsub("%c", "")

    if LL.uiSearchBox and type(LL.uiSearchBox.GetDefaultText) == "function" then
        local defaultText = LL.uiSearchBox:GetDefaultText()
        if defaultText and text == defaultText then
            return ""
        end
    end

    return text
end

local function LowerText(text)
    if text == nil then
        return ""
    end

    local rawText = tostring(text)
    local normalized = rawText

    -- Strip ESO color markup wrappers before matching.
    normalized = normalized:gsub("|c%x%x%x%x%x%x", "")
    normalized = normalized:gsub("|r", "")

    -- Prefer API name extraction for item links; fallback to display segment only if non-empty.
    if string.find(normalized, "|H", 1, true) ~= nil then
        local resolvedFromApi = nil
        if type(GetItemLinkName) == "function" then
            resolvedFromApi = GetItemLinkName(normalized)
        end
        if resolvedFromApi and resolvedFromApi ~= "" then
            normalized = tostring(resolvedFromApi)
        else
            local displaySegment = normalized:match("|H.-|h(.-)|h")
            if displaySegment and displaySegment ~= "" then
                normalized = displaySegment
            end
        end
    end

    -- Remove ESO grammar suffix markers (for example "^Mx", "^n").
    normalized = normalized:gsub("%^[%a]+", "")

    if normalized == "" and rawText ~= "" then
        normalized = rawText
    end

    -- Deterministic ASCII fold so filtering is stable across runtime/locale quirks.
    normalized = normalized:gsub("[A-Z]", function(char)
        return string.char(string.byte(char) + 32)
    end)

    return normalized
end

local function ResolveItemLinkQuality(itemKey)
    if type(itemKey) ~= "string" or itemKey == "" then
        return nil
    end

    local quality = nil
    if type(GetItemLinkDisplayQuality) == "function" then
        quality = GetItemLinkDisplayQuality(itemKey)
    elseif type(GetItemLinkQuality) == "function" then
        quality = GetItemLinkQuality(itemKey)
    end

    local numeric = tonumber(quality)
    if not numeric then
        return nil
    end
    return math.floor(numeric)
end

local function ResolveItemLinkItemType(itemKey)
    if type(itemKey) ~= "string" or itemKey == "" then
        return nil
    end

    if type(GetItemLinkItemType) ~= "function" then
        return nil
    end

    local itemType = GetItemLinkItemType(itemKey)
    local numeric = tonumber(itemType)
    if not numeric then
        return nil
    end
    return math.floor(numeric)
end

local function GetEntrySearchName(entry)
    if not entry then
        return ""
    end
    if entry.searchName == nil then
        entry.searchName = LowerText(entry.itemName or "")
    end
    return entry.searchName or ""
end

local function GetEntryQuality(entry)
    if not entry then
        return nil
    end
    if entry.quality == nil then
        entry.quality = ResolveItemLinkQuality(entry.itemName)
    end
    return entry.quality
end

local function GetEntryItemType(entry)
    if not entry then
        return nil
    end
    if entry.itemType == nil then
        entry.itemType = ResolveItemLinkItemType(entry.itemName)
    end
    return entry.itemType
end

local function IsEntryBetterByCount(left, right)
    if right == nil then
        return true
    end

    local leftCount = tonumber(left and left.count) or 0
    local rightCount = tonumber(right and right.count) or 0
    if leftCount ~= rightCount then
        return leftCount > rightCount
    end

    return tostring(left and left.itemName or "") < tostring(right and right.itemName or "")
end

local function IsEntryWorseByCount(left, right)
    return IsEntryBetterByCount(right, left)
end

local function FindWorstEntry(entries)
    local worstIndex = nil
    local worstEntry = nil

    for index = 1, #entries do
        local entry = entries[index]
        if worstIndex == nil or IsEntryWorseByCount(entry, worstEntry) then
            worstIndex = index
            worstEntry = entry
        end
    end

    return worstIndex, worstEntry
end

local function AddEntryToVisibleSelection(selectedEntries, entry, maxVisibleCount, worstIndex, worstEntry)
    local visibleLimit = tonumber(maxVisibleCount) or 0

    if visibleLimit <= 0 then
        return worstIndex, worstEntry
    end

    if #selectedEntries < visibleLimit then
        selectedEntries[#selectedEntries + 1] = entry
        if worstIndex == nil or IsEntryWorseByCount(entry, worstEntry) then
            worstIndex = #selectedEntries
            worstEntry = entry
        end
    elseif worstEntry and IsEntryBetterByCount(entry, worstEntry) then
        selectedEntries[worstIndex] = entry
        worstIndex, worstEntry = FindWorstEntry(selectedEntries)
    end

    return worstIndex, worstEntry
end

local function FinalizeVisibleEntriesByCount(selectedEntries)
    table.sort(selectedEntries, function(left, right)
        return IsEntryBetterByCount(left, right)
    end)
end

local function SelectVisibleEntriesByCount(entries, maxVisibleCount, includeEntry)
    local visibleEntries = {}
    local worstVisibleIndex = nil
    local worstVisibleEntry = nil
    local filteredCount = 0

    if not entries then
        return visibleEntries, filteredCount
    end

    for _, entry in ipairs(entries) do
        if includeEntry(entry) then
            filteredCount = filteredCount + 1
            worstVisibleIndex, worstVisibleEntry = AddEntryToVisibleSelection(
                visibleEntries,
                entry,
                maxVisibleCount,
                worstVisibleIndex,
                worstVisibleEntry
            )
        end
    end

    FinalizeVisibleEntriesByCount(visibleEntries)
    return visibleEntries, filteredCount
end

local function GetItemTypeDisplayName(itemType)
    local numeric = tonumber(itemType)
    if not numeric then
        return "All"
    end

    if type(GetString) == "function" then
        local ok, displayName = pcall(GetString, "SI_ITEMTYPE", numeric)
        if ok and type(displayName) == "string" and displayName ~= "" then
            return displayName
        end
    end

    return tostring(numeric)
end

local function BuildItemTypeFilterOptions(scope)
    local options = {
        { label = "All", itemType = nil },
    }
    local seen = {}
    local bucket = GetScopeBucket(scope)
    local items = bucket and bucket.items or nil
    if not items then
        return options
    end

    for itemKey in pairs(items) do
        local itemType = ResolveItemLinkItemType(itemKey)
        if itemType ~= nil and not seen[itemType] then
            seen[itemType] = true
            options[#options + 1] = {
                label = GetItemTypeDisplayName(itemType),
                itemType = itemType,
            }
        end
    end

    table.sort(options, function(left, right)
        if left.itemType == nil then
            return true
        end
        if right.itemType == nil then
            return false
        end

        local leftLabel = LowerText(left.label)
        local rightLabel = LowerText(right.label)
        if leftLabel == rightLabel then
            return left.itemType < right.itemType
        end
        return leftLabel < rightLabel
    end)

    return options
end

local LootLogItemList = ZO_SortFilterList:Subclass()

function LootLogItemList:New(...)
    return ZO_SortFilterList.New(self, ...)
end

function LootLogItemList:Initialize(control)
    ZO_SortFilterList.Initialize(self, control)

    self.scope = "session"
    self.searchTerm = ""
    self.rarityQuality = nil
    self.itemType = nil

    ZO_ScrollList_AddDataType(self.list, LOOTLOG_LIST_ENTRY_TYPE, "LootLogItemRow", 48, function(rowControl, data) self:SetupRow(rowControl, data) end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    self:SetAlternateRowBackgrounds(true)
    self:SetEmptyText("")
    self.emptyStateText = GetDefaultEmptyStateText()
    self.lastFilteredCount = 0
end

function LootLogItemList:SetScope(scope)
    self.scope = NormalizeScope(scope)
end

function LootLogItemList:SetSearchTerm(searchTerm)
    self.searchTerm = searchTerm or ""
end

function LootLogItemList:SetRarityQuality(quality)
    local numeric = tonumber(quality)
    if numeric == nil then
        self.rarityQuality = nil
        return
    end
    self.rarityQuality = math.floor(numeric)
end

function LootLogItemList:SetItemType(itemType)
    local numeric = tonumber(itemType)
    if numeric == nil then
        self.itemType = nil
        return
    end
    self.itemType = math.floor(numeric)
end

function LootLogItemList:BuildMasterList()
    self.masterList = {}
    local bucket = GetScopeBucket(self.scope)
    local items = bucket and bucket.items or nil
    if not items then
        return
    end

    for itemName, count in pairs(items) do
        self.masterList[#self.masterList + 1] = {
            itemName = itemName,
            count = tonumber(count) or 0,
        }
    end
end

function LootLogItemList:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local normalizeSearchMs, normalizedSearchTerm = MeasureCallMilliseconds(function()
        return LowerText(NormalizeFilterText(self.searchTerm or ""))
    end)
    local hasSearch = normalizedSearchTerm ~= ""
    local selectedRarityQuality = self.rarityQuality
    local selectedItemType = self.itemType
    local hasAnyFilter = hasSearch or selectedRarityQuality ~= nil or selectedItemType ~= nil
    if not self.masterList then
        self.lastFilteredCount = 0
        self.lastNormalizeSearchMs = normalizeSearchMs
        return
    end

    local visibleEntries, filteredCount = SelectVisibleEntriesByCount(self.masterList, UI_MAX_VISIBLE_ITEMS, function(entry)
        local include = true
        if hasSearch then
            local normalizedItemName = GetEntrySearchName(entry)
            include = string.find(normalizedItemName, normalizedSearchTerm, 1, true) ~= nil
        end
        if include and selectedRarityQuality ~= nil then
            local quality = GetEntryQuality(entry)
            include = quality ~= nil and quality == selectedRarityQuality
        end
        if include and selectedItemType ~= nil then
            local itemType = GetEntryItemType(entry)
            include = itemType ~= nil and itemType == selectedItemType
        end
        return include
    end)

    for index = 1, #visibleEntries do
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(LOOTLOG_LIST_ENTRY_TYPE, visibleEntries[index])
    end

    if #scrollData == 0 and hasAnyFilter then
        self.emptyStateText = GetNoResultsText()
    else
        self.emptyStateText = GetDefaultEmptyStateText()
    end

    self.lastFilteredCount = filteredCount
    self.lastNormalizeSearchMs = normalizeSearchMs
end

function LootLogItemList:ApplyDataNow()
    local buildMs = MeasureCallMilliseconds(function()
        self:BuildMasterList()
    end)
    local filterMs = MeasureCallMilliseconds(function()
        self:FilterScrollList()
    end)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    for i, dataEntry in ipairs(scrollData) do
        if dataEntry and dataEntry.data then
            dataEntry.data.sortIndex = i
            dataEntry.data.dataIndex = i
        end
    end
    local commitMs = 0
    if self.list and type(ZO_ScrollList_Commit) == "function" then
        commitMs = MeasureCallMilliseconds(function()
            ZO_ScrollList_Commit(self.list)
        end)
    end

    self.lastRenderMetrics = {
        buildMs = buildMs,
        filterMs = filterMs,
        commitMs = commitMs,
        itemCount = self.masterList and #self.masterList or 0,
        filteredCount = tonumber(self.lastFilteredCount) or 0,
        visibleCount = #scrollData,
        normalizeSearchMs = tonumber(self.lastNormalizeSearchMs) or 0,
    }
end

function LootLogItemList:GetCustomEmptyStateText()
    return self.emptyStateText or GetDefaultEmptyStateText()
end

function LootLogItemList:IsCustomEmptyStateVisible()
    return (tonumber(self.lastFilteredCount) or 0) == 0
end

function LootLogItemList:SetupRow(control, data)
    ZO_SortFilterList.SetupRow(self, control, data)
    control:GetNamedChild("Item"):SetText(data.itemName)
    control:GetNamedChild("Count"):SetText(tostring(data.count))
end

function LootLogItemList:SetDirectionalInputEnabled(enabled)
    if self.directionalInputEnabled == enabled then
        return
    end
    self.directionalInputEnabled = enabled

    if enabled and DIRECTIONAL_INPUT then
        DIRECTIONAL_INPUT:Activate(self, self.control)
    elseif DIRECTIONAL_INPUT then
        DIRECTIONAL_INPUT:Deactivate(self)
    end
end

function LootLogItemList:UpdateDirectionalInput()
    if not DIRECTIONAL_INPUT or not self.list then
        return
    end

    local magnitude = DIRECTIONAL_INPUT:GetY(ZO_DI_RIGHT_STICK)
    if zo_abs(magnitude) > 0.05 then
        local ANIMATE_INSTANTLY = true
        local NO_ON_COMPLETE_CALLBACK = nil
        ZO_ScrollList_ScrollRelative(self.list, -magnitude * 1000 * GetFrameDeltaSeconds(), NO_ON_COMPLETE_CALLBACK, ANIMATE_INSTANTLY)
    end
end

local function SetHeaderActionText(actionControl, text)
    if not actionControl then
        return
    end
    local label = actionControl:GetNamedChild("Label")
    if label and type(label.SetText) == "function" then
        label:SetText(text)
    end
end

local function SetLabelColor(label, color)
    if not label or not color or type(label.SetColor) ~= "function" then
        return
    end
    label:SetColor(color[1], color[2], color[3], color[4])
end

local function SetBackdropColors(backdrop, fillColor, edgeColor)
    if not backdrop then
        return
    end
    if fillColor and type(backdrop.SetCenterColor) == "function" then
        backdrop:SetCenterColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4])
    end
    if edgeColor and type(backdrop.SetEdgeColor) == "function" then
        backdrop:SetEdgeColor(edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
    end
end

local function SetHeaderActionVisualState(actionControl, isActive)
    if not actionControl then
        return
    end

    local label = actionControl:GetNamedChild("Label")
    local backdrop = actionControl:GetNamedChild("BG")
    if isActive then
        SetLabelColor(label, ACTIVE_ACTION_TEXT_COLOR)
        SetBackdropColors(backdrop, ACTIVE_FILL_COLOR, ACTIVE_EDGE_COLOR)
    else
        SetLabelColor(label, INACTIVE_TEXT_COLOR)
        SetBackdropColors(backdrop, INACTIVE_FILL_COLOR, INACTIVE_EDGE_COLOR)
    end
end

local function SetSearchVisualState(isActive)
    if LL.uiSearchLabel then
        SetLabelColor(LL.uiSearchLabel, isActive and ACTIVE_LABEL_COLOR or INACTIVE_TEXT_COLOR)
    end
    SetBackdropColors(LL.uiSearchBackdrop, isActive and ACTIVE_FILL_COLOR or INACTIVE_FILL_COLOR, isActive and ACTIVE_EDGE_COLOR or INACTIVE_EDGE_COLOR)
end

local function UpdateScopeButtonState()
    if not LL.uiControl then
        return
    end

    local scope = LL.uiScope or "session"
    local sessionButton = LL.uiControl:GetNamedChild("SessionTab")
    local manualButton = LL.uiControl:GetNamedChild("ManualTab")
    local lifetimeButton = LL.uiControl:GetNamedChild("LifetimeTab")

    local onLabel = " (active)"
    local sessionLabel = GetUIScopeLabel("session")
    local manualLabel = GetUIScopeLabel("manual")
    local lifetimeLabel = GetUIScopeLabel("lifetime")
    SetHeaderActionText(sessionButton, scope == "session" and (sessionLabel .. onLabel) or sessionLabel)
    SetHeaderActionText(manualButton, scope == "manual" and (manualLabel .. onLabel) or manualLabel)
    SetHeaderActionText(lifetimeButton, scope == "lifetime" and (lifetimeLabel .. onLabel) or lifetimeLabel)
    SetHeaderActionVisualState(sessionButton, scope == "session")
    SetHeaderActionVisualState(manualButton, scope == "manual")
    SetHeaderActionVisualState(lifetimeButton, scope == "lifetime")
end

local function GetCurrentRarityOptionIndex()
    local index = tonumber(LL.uiRarityFilterIndex)
    if not index or index < 1 or index > #RARITY_FILTER_OPTIONS then
        return 1
    end
    return math.floor(index)
end

local function GetCurrentRarityOption()
    return RARITY_FILTER_OPTIONS[GetCurrentRarityOptionIndex()] or RARITY_FILTER_OPTIONS[1]
end

local function GetCurrentRarityQuality()
    local option = GetCurrentRarityOption()
    return option and option.quality or nil
end

local function RefreshItemTypeFilterOptions()
    LL.uiItemTypeOptions = BuildItemTypeFilterOptions(LL.uiScope or "session")

    local currentItemType = tonumber(LL.uiItemTypeFilter)
    if currentItemType == nil then
        return
    end

    for _, option in ipairs(LL.uiItemTypeOptions) do
        if option.itemType == currentItemType then
            return
        end
    end

    LL.uiItemTypeFilter = nil
end

local function GetCurrentItemTypeOptionIndex()
    local options = LL.uiItemTypeOptions or { { label = "All", itemType = nil } }
    local currentItemType = tonumber(LL.uiItemTypeFilter)
    if currentItemType == nil then
        return 1
    end

    for index, option in ipairs(options) do
        if option.itemType == currentItemType then
            return index
        end
    end

    return 1
end

local function GetCurrentItemTypeOption()
    local options = LL.uiItemTypeOptions or { { label = "All", itemType = nil } }
    return options[GetCurrentItemTypeOptionIndex()] or options[1]
end

local function GetCurrentItemTypeValue()
    local option = GetCurrentItemTypeOption()
    return option and option.itemType or nil
end

local function UpdateItemTypeFilterDisplay()
    if LL.uiItemTypeLabel then
        LL.uiItemTypeLabel:SetText("Type:")
        SetLabelColor(LL.uiItemTypeLabel, GetCurrentItemTypeValue() ~= nil and ACTIVE_LABEL_COLOR or INACTIVE_TEXT_COLOR)
    end
    if LL.uiItemTypeSelector then
        local option = GetCurrentItemTypeOption()
        SetHeaderActionText(LL.uiItemTypeSelector, option and option.label or "All")
        SetHeaderActionVisualState(LL.uiItemTypeSelector, GetCurrentItemTypeValue() ~= nil)
    end
end

local function UpdateRarityFilterDisplay()
    if LL.uiRarityLabel then
        LL.uiRarityLabel:SetText("Rarity:")
        SetLabelColor(LL.uiRarityLabel, GetCurrentRarityQuality() ~= nil and ACTIVE_LABEL_COLOR or INACTIVE_TEXT_COLOR)
    end
    if LL.uiRaritySelector then
        local option = GetCurrentRarityOption()
        SetHeaderActionText(LL.uiRaritySelector, option and option.label or "All")
        SetHeaderActionVisualState(LL.uiRaritySelector, GetCurrentRarityQuality() ~= nil)
    end
end

local function UpdateSummary()
    if not LL.uiSummaryLabel then
        return
    end
    LL.uiSummaryLabel:SetText(BuildSummaryText(LL.uiScope))
end

local function UpdateCustomEmptyState()
    if not LL.uiEmptyStateLabel then
        return
    end

    local listObject = LL.uiList
    if not listObject then
        LL.uiEmptyStateLabel:SetHidden(true)
        return
    end

    local visible = type(listObject.IsCustomEmptyStateVisible) == "function"
        and listObject:IsCustomEmptyStateVisible()
        or false

    LL.uiEmptyStateLabel:SetHidden(not visible)
    if visible and type(listObject.GetCustomEmptyStateText) == "function" then
        LL.uiEmptyStateLabel:SetText(listObject:GetCustomEmptyStateText())
    end
end

local function GetActiveFilterText()
    return LL.uiFilterText or ""
end

local function HasActiveFilters()
    return GetActiveFilterText() ~= ""
        or GetCurrentRarityQuality() ~= nil
        or GetCurrentItemTypeValue() ~= nil
end

local function UpdateFilterDisplay()
    if not LL.uiSearchLabel then
        return
    end

    LL.uiSearchLabel:SetText("Filter by item name:")
    SetSearchVisualState(GetActiveFilterText() ~= "")
end

local function SelectRelativeScope(direction)
    local nextScope = GetRelativeScope(LL.uiScope or "session", direction)
    LL.SelectUIScope(nextScope)
end

local function SetRarityOptionIndex(index)
    local count = #RARITY_FILTER_OPTIONS
    if count <= 0 then
        return
    end

    local numeric = tonumber(index) or 1
    local normalized = ((math.floor(numeric) - 1) % count) + 1
    if LL.uiRarityFilterIndex ~= normalized then
        LL.uiRarityFilterIndex = normalized
        LL.RefreshUI()
        return
    end
    UpdateRarityFilterDisplay()
end

local function CycleRarityOption(step)
    local direction = tonumber(step) or 1
    if direction == 0 then
        direction = 1
    end
    SetRarityOptionIndex(GetCurrentRarityOptionIndex() + direction)
end

local function SetItemTypeOptionIndex(index)
    local options = LL.uiItemTypeOptions or { { label = "All", itemType = nil } }
    local count = #options
    if count <= 0 then
        return
    end

    local numeric = tonumber(index) or 1
    local normalized = ((math.floor(numeric) - 1) % count) + 1
    local option = options[normalized] or options[1]
    local nextItemType = option and option.itemType or nil
    if LL.uiItemTypeFilter ~= nextItemType then
        LL.uiItemTypeFilter = nextItemType
        LL.RefreshUI()
        return
    end
    UpdateItemTypeFilterDisplay()
end

local function CycleItemTypeOption(step)
    local direction = tonumber(step) or 1
    if direction == 0 then
        direction = 1
    end
    SetItemTypeOptionIndex(GetCurrentItemTypeOptionIndex() + direction)
end

local function CanListScroll()
    local listControl = LL.uiList and LL.uiList.list
    if not listControl or not listControl.scroll or type(listControl.scroll.GetScrollExtents) ~= "function" then
        return false
    end
    local _, verticalExtents = listControl.scroll:GetScrollExtents()
    return (tonumber(verticalExtents) or 0) > 0
end

local function GetCurrentFilterText()
    if LL.uiSearchBox and type(LL.uiSearchBox.GetText) == "function" then
        return NormalizeFilterText(LL.uiSearchBox:GetText())
    end
    return ""
end

local function SetFilterTextAndRefresh(nextFilterText)
    local normalized = NormalizeFilterText(nextFilterText)
    if LL.uiFilterText ~= normalized then
        LL.uiFilterText = normalized
        LL.RefreshUI()
    end
end

local function AttachHandler(control, handlerName, callback)
    if not control or type(callback) ~= "function" then
        return
    end

    if type(ZO_PreHookHandler) == "function" then
        ZO_PreHookHandler(control, handlerName, callback)
    elseif type(control.SetHandler) == "function" then
        control:SetHandler(handlerName, callback)
    end
end

local function ApplyFilterText(filterText)
    local normalized = NormalizeFilterText(filterText)
    LL.uiFilterText = normalized

    if LL.uiSearchBox and type(LL.uiSearchBox.GetText) == "function" and type(LL.uiSearchBox.SetText) == "function" then
        if LL.uiSearchBox:GetText() ~= normalized then
            LL.uiSearchBox:SetText(normalized)
        end
    end

    LL.RefreshUI()
end

local function OpenFilterInput()
    if not LL.uiSearchBox then
        return
    end

    if type(LL.uiSearchBox.TakeFocus) == "function" then
        LL.uiSearchBox:TakeFocus()
    end
end

local function ClearFilter()
    if not LL.uiSearchBox then
        return
    end

    ApplyFilterText("")
    if type(LL.uiSearchBox.LoseFocus) == "function" then
        LL.uiSearchBox:LoseFocus()
    end
end

local function ResetFiltersFromUI()
    LL.uiFilterText = ""
    LL.uiRarityFilterIndex = 1
    LL.uiItemTypeFilter = nil

    if LL.uiSearchBox and type(LL.uiSearchBox.GetText) == "function" and type(LL.uiSearchBox.SetText) == "function" then
        if LL.uiSearchBox:GetText() ~= "" then
            LL.uiSearchBox:SetText("")
        end
    end

    if LL.uiSearchBox and type(LL.uiSearchBox.LoseFocus) == "function" then
        LL.uiSearchBox:LoseFocus()
    end

    LL.RefreshUI()
end

local function ResetManualFromUI()
    LL.EnsureSaved()
    LL.ResetBucket(LL.saved.manual)
    LL.RefreshUI()
    LL.Print("Manual counters reset.")
end

local function ActivateGamepadScrollInput()
    if LL.uiGamepadScrollInputActive then
        return
    end
    if not LL.uiList then
        return
    end
    if type(LL.uiList.SetDirectionalInputEnabled) ~= "function" then
        return
    end

    LL.uiList:SetDirectionalInputEnabled(true)
    LL.uiGamepadScrollInputActive = true
end

local function DeactivateGamepadScrollInput()
    if not LL.uiGamepadScrollInputActive then
        return
    end

    if LL.uiList and type(LL.uiList.SetDirectionalInputEnabled) == "function" then
        LL.uiList:SetDirectionalInputEnabled(false)
    end
    LL.uiGamepadScrollInputActive = false
end

local function EnsureUIKeybindDescriptor()
    if LL.uiKeybindDescriptor then
        return
    end

    LL.uiKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = "Filter",
            keybind = "UI_SHORTCUT_PRIMARY",
            callback = function()
                OpenFilterInput()
            end,
            visible = function()
                return LL.uiControl ~= nil
                    and not LL.uiControl:IsHidden()
            end,
        },
        {
            name = "Type",
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                CycleItemTypeOption(1)
            end,
            visible = function()
                return LL.uiControl ~= nil
                    and not LL.uiControl:IsHidden()
            end,
        },
        {
            name = "Rarity",
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function()
                CycleRarityOption(1)
            end,
            visible = function()
                return LL.uiControl ~= nil
                    and not LL.uiControl:IsHidden()
            end,
        },
        {
            name = "Reset This Tab",
            keybind = "UI_SHORTCUT_QUATERNARY",
            callback = function()
                ResetManualFromUI()
            end,
            visible = function()
                return LL.uiControl ~= nil
                    and not LL.uiControl:IsHidden()
                    and LL.uiScope == "manual"
            end,
        },
        {
            name = "Previous Tab",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            callback = function()
                SelectRelativeScope(-1)
            end,
            visible = function()
                return LL.uiControl ~= nil and not LL.uiControl:IsHidden()
            end,
        },
        {
            name = "Next Tab",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            callback = function()
                SelectRelativeScope(1)
            end,
            visible = function()
                return LL.uiControl ~= nil and not LL.uiControl:IsHidden()
            end,
        },
        {
            name = "Close",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                LL.HideUI()
            end,
            visible = function()
                return LL.uiControl ~= nil and not LL.uiControl:IsHidden()
            end,
        },
        {
            name = "Reset Filters",
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            callback = function()
                ResetFiltersFromUI()
            end,
            visible = function()
                return LL.uiControl ~= nil
                    and not LL.uiControl:IsHidden()
                    and HasActiveFilters()
            end,
        },
    }
end

local function AddUIKeybinds()
    if not KEYBIND_STRIP or LL.uiKeybindActive then
        return
    end

    EnsureUIKeybindDescriptor()
    LL.uiKeybindId = KEYBIND_STRIP:PushKeybindGroupState()
    KEYBIND_STRIP:AddKeybindButtonGroup(LL.uiKeybindDescriptor, LL.uiKeybindId)
    LL.uiKeybindActive = true
end

local function RemoveUIKeybinds()
    if not KEYBIND_STRIP or not LL.uiKeybindActive then
        return
    end

    KEYBIND_STRIP:RemoveKeybindButtonGroup(LL.uiKeybindDescriptor, LL.uiKeybindId)
    KEYBIND_STRIP:PopKeybindGroupState()
    LL.uiKeybindId = nil
    LL.uiKeybindActive = false
end

local function WithUIRootScenes(callback)
    if not callback then
        return
    end

    if HUD_SCENE then
        callback(HUD_SCENE)
    end

    if HUD_UI_SCENE and HUD_UI_SCENE ~= HUD_SCENE then
        callback(HUD_UI_SCENE)
    end
end

local function AddFragmentIfAvailable(fragment, flagName)
    if not fragment then
        return
    end

    local added = false
    WithUIRootScenes(function(scene)
        if type(scene.AddTemporaryFragment) == "function" then
            scene:AddTemporaryFragment(fragment)
            added = true
        end
    end)

    -- Fallback for contexts where HUD scenes are not available.
    if (not added) and SCENE_MANAGER and type(SCENE_MANAGER.AddFragment) == "function" then
        SCENE_MANAGER:AddFragment(fragment)
        added = true
    end

    LL[flagName] = added
end

local function RemoveFragmentIfAdded(fragment, flagName)
    if not LL[flagName] then
        return
    end

    WithUIRootScenes(function(scene)
        if fragment and type(scene.RemoveTemporaryFragment) == "function" then
            scene:RemoveTemporaryFragment(fragment)
        end
    end)

    if fragment and SCENE_MANAGER and type(SCENE_MANAGER.RemoveFragment) == "function" then
        SCENE_MANAGER:RemoveFragment(fragment)
    end
    LL[flagName] = false
end

local function GetUIShortcutsActionLayerName()
    if type(GetString) == "function" and SI_KEYBINDINGS_LAYER_USER_INTERFACE_SHORTCUTS then
        return GetString(SI_KEYBINDINGS_LAYER_USER_INTERFACE_SHORTCUTS)
    end
    return nil
end

local function AddTemporaryUIInputFragments()
    local inGamepadMode = type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode()

    if inGamepadMode then
        AddFragmentIfAvailable(GAMEPAD_UI_MODE_FRAGMENT, "uiAddedGamepadModeFragment")
        AddFragmentIfAvailable(KEYBIND_STRIP_GAMEPAD_FRAGMENT, "uiAddedKeybindStripFragment")
    else
        AddFragmentIfAvailable(MOUSE_UI_MODE_FRAGMENT, "uiAddedMouseModeFragment")
        AddFragmentIfAvailable(KEYBIND_STRIP_FADE_FRAGMENT, "uiAddedKeybindStripFragment")
    end

    if UI_SHORTCUTS_ACTION_LAYER_FRAGMENT then
        AddFragmentIfAvailable(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT, "uiAddedShortcutsActionLayerFragment")
    else
        local actionLayerName = GetUIShortcutsActionLayerName()
        if actionLayerName and type(PushActionLayerByName) == "function" then
            PushActionLayerByName(actionLayerName)
            LL.uiActionLayerPushed = true
        end
    end
end

local function RemoveTemporaryUIInputFragments()
    RemoveFragmentIfAdded(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT, "uiAddedShortcutsActionLayerFragment")
    RemoveFragmentIfAdded(GAMEPAD_UI_MODE_FRAGMENT, "uiAddedGamepadModeFragment")
    RemoveFragmentIfAdded(MOUSE_UI_MODE_FRAGMENT, "uiAddedMouseModeFragment")
    RemoveFragmentIfAdded(KEYBIND_STRIP_GAMEPAD_FRAGMENT, "uiAddedKeybindStripFragment")
    RemoveFragmentIfAdded(KEYBIND_STRIP_FADE_FRAGMENT, "uiAddedKeybindStripFragment")

    if LL.uiActionLayerPushed then
        local actionLayerName = GetUIShortcutsActionLayerName()
        if actionLayerName and type(RemoveActionLayerByName) == "function" then
            RemoveActionLayerByName(actionLayerName)
        end
        LL.uiActionLayerPushed = false
    end
end

function LL.RefreshUI()
    if not LL.uiList then
        return
    end
    if LL.uiControl and LL.uiControl:IsHidden() then
        return
    end

    local totalStartedAt = GetNowMilliseconds()
    local preListMs = MeasureCallMilliseconds(function()
        LL.uiList:SetScope(LL.uiScope)
        LL.uiList:SetSearchTerm(GetActiveFilterText())
        RefreshItemTypeFilterOptions()
        LL.uiList:SetRarityQuality(GetCurrentRarityQuality())
        LL.uiList:SetItemType(GetCurrentItemTypeValue())
    end)
    local listApplyMs = 0
    if type(LL.uiList.ApplyDataNow) == "function" then
        listApplyMs = MeasureCallMilliseconds(function()
            LL.uiList:ApplyDataNow()
        end)
    else
        listApplyMs = MeasureCallMilliseconds(function()
            LL.uiList:RefreshData()
        end)
    end
    local postListMs = MeasureCallMilliseconds(function()
        UpdateScopeButtonState()
        UpdateSummary()
        UpdateFilterDisplay()
        UpdateRarityFilterDisplay()
        UpdateItemTypeFilterDisplay()
        UpdateCustomEmptyState()
        ActivateGamepadScrollInput()
    end)

    local keybindMs = 0
    if KEYBIND_STRIP and LL.uiKeybindActive then
        keybindMs = MeasureCallMilliseconds(function()
            KEYBIND_STRIP:UpdateKeybindButtonGroup(LL.uiKeybindDescriptor, LL.uiKeybindId)
        end)
    end

    local totalMs = 0
    local totalFinishedAt = GetNowMilliseconds()
    if totalStartedAt ~= nil and totalFinishedAt ~= nil then
        totalMs = math.max(0, totalFinishedAt - totalStartedAt)
    else
        totalMs = preListMs + listApplyMs + postListMs + keybindMs
    end

    if LL.saved and LL.saved.settings and LL.saved.settings.debug then
        local metrics = LL.uiList.lastRenderMetrics or {}
        LL.DebugPrint(string.format(
            "ui_render scope=%s total=%dms pre=%dms list=%dms post=%dms keybind=%dms build=%dms filter=%dms (normalize=%dms) commit=%dms items=%d filtered=%d visible=%d typeOptions=%d",
            tostring(LL.uiScope),
            totalMs,
            preListMs,
            listApplyMs,
            postListMs,
            keybindMs,
            tonumber(metrics.buildMs) or 0,
            tonumber(metrics.filterMs) or 0,
            tonumber(metrics.normalizeSearchMs) or 0,
            tonumber(metrics.commitMs) or 0,
            tonumber(metrics.itemCount) or 0,
            tonumber(metrics.filteredCount) or 0,
            tonumber(metrics.visibleCount) or 0,
            LL.uiItemTypeOptions and #LL.uiItemTypeOptions or 0
        ))
    end
end

function LL.SelectUIScope(scope)
    LL.uiScope = NormalizeScope(scope)
    LL.RefreshUI()
end

function LL.ShowUI()
    if not LL.uiControl then
        LL.Print("UI not initialized yet.")
        return
    end

    if LL.uiSearchBox and type(LL.uiSearchBox.LoseFocus) == "function" then
        LL.uiSearchBox:LoseFocus()
    end

    LL.uiControl:SetHidden(false)
    AddTemporaryUIInputFragments()
    AddUIKeybinds()
    ActivateGamepadScrollInput()
    LL.RefreshUI()
end

function LL.HideUI()
    if LL.uiControl then
        LL.uiControl:SetHidden(true)
    end
    DeactivateGamepadScrollInput()
    RemoveUIKeybinds()
    RemoveTemporaryUIInputFragments()
end

function LL.ToggleUI()
    if not LL.uiControl then
        LL.Print("UI not initialized yet.")
        return
    end

    if LL.uiControl:IsHidden() then
        LL.ShowUI()
    else
        LL.HideUI()
    end
end

function LL.SetUIScale(scale)
    local numericScale = tonumber(scale)
    if not numericScale then
        return
    end

    if numericScale < 0.8 then
        numericScale = 0.8
    elseif numericScale > 2.0 then
        numericScale = 2.0
    end

    if LL.uiControl then
        LL.uiControl:SetScale(numericScale)
    end
    if LL.saved and LL.saved.settings then
        LL.saved.settings.uiScale = numericScale
    end
end

function LL.OnUIInitialized(control)
    LL.uiControl = control
    LL.uiScope = "session"
    LL.uiSearchBox = control:GetNamedChild("Search"):GetNamedChild("Box")
    LL.uiSearchBackdrop = control:GetNamedChild("Search")
    LL.uiSearchLabel = control:GetNamedChild("SearchLabel")
    LL.uiRarityLabel = control:GetNamedChild("RarityLabel")
    LL.uiRaritySelector = control:GetNamedChild("RaritySelector")
    LL.uiItemTypeLabel = control:GetNamedChild("ItemTypeLabel")
    LL.uiItemTypeSelector = control:GetNamedChild("ItemTypeSelector")
    LL.uiSummaryLabel = control:GetNamedChild("Summary")
    LL.uiEmptyStateLabel = control:GetNamedChild("EmptyState")
    LL.uiList = LootLogItemList:New(control)
    LL.uiFilterText = GetCurrentFilterText()
    LL.uiRarityFilterIndex = 1
    LL.uiItemTypeFilter = nil
    LL.uiItemTypeOptions = BuildItemTypeFilterOptions("session")

    control:GetNamedChild("Title"):SetText("Loot Log")
    UpdateFilterDisplay()
    local sessionButton = control:GetNamedChild("SessionTab")
    local manualButton = control:GetNamedChild("ManualTab")
    local lifetimeButton = control:GetNamedChild("LifetimeTab")

    local sessionLabel = sessionButton and sessionButton:GetNamedChild("Label")
    if sessionLabel and type(sessionLabel.SetText) == "function" then
        sessionLabel:SetText(GetUIScopeLabel("session"))
    end
    local manualLabel = manualButton and manualButton:GetNamedChild("Label")
    if manualLabel and type(manualLabel.SetText) == "function" then
        manualLabel:SetText(GetUIScopeLabel("manual"))
    end
    local lifetimeLabel = lifetimeButton and lifetimeButton:GetNamedChild("Label")
    if lifetimeLabel and type(lifetimeLabel.SetText) == "function" then
        lifetimeLabel:SetText(GetUIScopeLabel("lifetime"))
    end
    UpdateRarityFilterDisplay()
    UpdateItemTypeFilterDisplay()

    if sessionButton and type(sessionButton.SetHandler) == "function" then
        sessionButton:SetHandler("OnMouseUp", function()
            LL.SelectUIScope("session")
        end)
    end
    if manualButton and type(manualButton.SetHandler) == "function" then
        manualButton:SetHandler("OnMouseUp", function()
            LL.SelectUIScope("manual")
        end)
    end
    if lifetimeButton and type(lifetimeButton.SetHandler) == "function" then
        lifetimeButton:SetHandler("OnMouseUp", function()
            LL.SelectUIScope("lifetime")
        end)
    end
    if LL.uiRaritySelector and type(LL.uiRaritySelector.SetHandler) == "function" then
        LL.uiRaritySelector:SetHandler("OnMouseUp", function(_, button)
            if button == 2 then
                CycleRarityOption(-1)
            else
                CycleRarityOption(1)
            end
        end)
    end
    if LL.uiItemTypeSelector and type(LL.uiItemTypeSelector.SetHandler) == "function" then
        LL.uiItemTypeSelector:SetHandler("OnMouseUp", function(_, button)
            if button == 2 then
                CycleItemTypeOption(-1)
            else
                CycleItemTypeOption(1)
            end
        end)
    end

    local uiScale = LL.saved and LL.saved.settings and LL.saved.settings.uiScale or nil
    if uiScale == nil then
        if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
            uiScale = 1.35
        else
            uiScale = 1.0
        end
    end
    LL.SetUIScale(uiScale)

    LL.uiSearchBox:SetHandler("OnTextChanged", function()
        SetFilterTextAndRefresh(GetCurrentFilterText())
    end)
    AttachHandler(LL.uiSearchBox, "OnFocusLost", function()
        SetFilterTextAndRefresh(GetCurrentFilterText())
    end)
    AttachHandler(LL.uiSearchBox, "OnEnter", function()
        SetFilterTextAndRefresh(GetCurrentFilterText())
    end)
    AttachHandler(LL.uiSearchBox, "OnEscape", function()
        SetFilterTextAndRefresh(GetCurrentFilterText())
    end)

    LL.RefreshUI()
end
