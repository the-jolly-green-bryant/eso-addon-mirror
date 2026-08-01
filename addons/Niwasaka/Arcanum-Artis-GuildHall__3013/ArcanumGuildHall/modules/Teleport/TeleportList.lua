local ArcanumGuildHall = _G["ArcanumGuildHall"]
local UI = ArcanumGuildHallTeleportUI
local Teleport = ArcanumGuildHall.Teleport
local res = ArcanumGuildHallMediaRes

UI.TeleportWindow = UI.TeleportWindow or {}
UI.TeleportDetails = UI.TeleportDetails or {}
UI.TeleportList = UI.TeleportList or {}

local Window = UI.TeleportWindow
local Details = UI.TeleportDetails
local List = UI.TeleportList

local ROW_ACTION = 1
local ROW_DIVIDER = 2

local function matchFilter(entry)
    if entry.entryType ~= "action" then
        return true
    end

    local details = entry.details or {}

    if UI.activeTab == "network" and details.category == Teleport.CATEGORY.HOUSE then
        return false
    end

    if Window.SupportsFavorites() and UI.filters.favoriteOnly and not Teleport.IsFavorite(entry) then
        return false
    end

    if Window.UsesHouseFilter() then
        local houseFilter = UI.filters.house or "all"

        if houseFilter == "owned" then
            return details.isOwnedHouse
        end

        if houseFilter == "unowned" then
            return details.isOwnedHouse == false
        end

        return true
    end

    if not Window.UsesCategoryFilter() then
        return true
    end

    local filterValue = UI.filters.category or "all"
    if filterValue == "all" then
        return true
    end

    return details.category == Teleport.GetCategoryIdByKey(filterValue)
end

local function matchSearch(entry)
    local needle = Teleport.NormalizeKey(UI.searchText)
    if needle == "" then
        return true
    end

    local details = entry.details or {}

    return Teleport.ContainsSearch(details.searchTarget or "", needle)
            or Teleport.ContainsSearch(details.searchDisplayName or "", needle)
            or Teleport.ContainsSearch(details.searchSource or "", needle)
            or Teleport.ContainsSearch(details.searchZone or "", needle)
            or Teleport.ContainsSearch(Teleport.NormalizeKey(entry.text or ""), needle)
end

local function filterEntries(sourceEntries)
    local filtered = {}
    local pendingDivider = nil
    local hasActionAfterDivider = false

    for i = 1, #sourceEntries do
        local entry = sourceEntries[i]

        if entry.entryType == "divider" and not entry.details then
            pendingDivider = entry
            hasActionAfterDivider = false
        elseif matchFilter(entry) and matchSearch(entry) then
            if pendingDivider and not hasActionAfterDivider then
                filtered[#filtered + 1] = pendingDivider
                hasActionAfterDivider = true
            end

            filtered[#filtered + 1] = entry
        end
    end

    if #filtered == 0 then
        filtered[1] = Teleport.CreateDividerEntry(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_EMPTY_ENTRIES")
        )
    end

    return filtered
end

local function getSelectionKey(entry)
    if not entry or entry.entryType ~= "action" then
        return nil
    end

    local details = entry.details or {}

    return table.concat({
        UI.activeTab or "",
        tostring(details.houseId or 0),
        tostring(details.nodeId or 0),
        tostring(details.collectibleId or 0),
        tostring(details.zoneId or 0),
        Teleport.NormalizeKey(details.ownerDisplayName or ""),
        Teleport.NormalizeKey(details.target or entry.text or ""),
        Teleport.NormalizeKey(details.displayName or ""),
        Teleport.NormalizeKey(details.source or ""),
        tostring(details.category or 0),
    }, "|")
end

local function saveSelection(entry)
    UI.selectionKey = getSelectionKey(entry)
end

local function findSavedSelection(entries)
    if not UI.selectionKey then
        return nil
    end

    for i = 1, #entries do
        if getSelectionKey(entries[i]) == UI.selectionKey then
            return entries[i]
        end
    end

    return nil
end

local function findFirstEntry(entries)
    for i = 1, #entries do
        local entry = entries[i]
        if entry and entry.entryType == "action" then
            return entry
        end
    end

    return nil
end

local function getRowChild(control, suffix)
    local child = control:GetNamedChild(suffix)
    if child then
        return child
    end

    local controlName = control.GetName and control:GetName()
    if not controlName or controlName == "" then
        return nil
    end

    return WINDOW_MANAGER:GetControlByName(controlName .. "_" .. suffix)
end

local function anchorRowText(control, leftControl, offsetX)
    control.textLabel:ClearAnchors()

    if leftControl then
        control.textLabel:SetAnchor(LEFT, leftControl, RIGHT, offsetX, 0)
    else
        control.textLabel:SetAnchor(LEFT, control, LEFT, offsetX, 0)
    end

    control.textLabel:SetAnchor(RIGHT, control, RIGHT, -6, 0)
    control.textLabel:SetHeight(Window.STYLE.rows.height)
end

local function isBlockedByAvA(entry)
    return entry
            and entry.entryType == "action"
            and entry.callback ~= nil
            and Teleport.IsBlockedByAvA()
            or false
end

local function selectEntry(entry, refreshVisible)
    if not entry then
        UI.selectionKey = nil
        UI.selectedData = nil
        Window.UpdateTeleportButton(nil)
        Details.Clear(UI)

        if refreshVisible then
            ZO_ScrollList_RefreshVisible(Window.GetList())
        end

        return
    end

    UI.selectedData = entry
    saveSelection(entry)
    Window.UpdateTeleportButton(entry)
    Details.Update(UI, entry)

    if refreshVisible then
        ZO_ScrollList_RefreshVisible(Window.GetList())
    end
end

local function initActionRow(control)
    if control.textLabel and control.bg and control.hover and control.lockIcon and control.icon and control.favoriteIcon then
        return true
    end

    control.bg = getRowChild(control, "Bg")
    control.hover = getRowChild(control, "Hover")
    control.lockIcon = getRowChild(control, "LockIcon")
    control.icon = getRowChild(control, "Icon")
    control.textLabel = getRowChild(control, "Text")
    control.favoriteIcon = getRowChild(control, "FavoriteIcon")

    if not control.bg or not control.hover or not control.lockIcon or not control.icon or not control.textLabel or not control.favoriteIcon then
        return false
    end

    control.textLabel:SetFont("ZoFontGame")
    control.textLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    control.textLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local style = Window.STYLE.rows
    control.bg:SetCenterColor(style.selectedCenter[1], style.selectedCenter[2], style.selectedCenter[3], style.selectedCenter[4])
    control.bg:SetEdgeColor(style.selectedEdge[1], style.selectedEdge[2], style.selectedEdge[3], style.selectedEdge[4])

    control.hover:SetCenterColor(style.hoverCenter[1], style.hoverCenter[2], style.hoverCenter[3], style.hoverCenter[4])
    control.hover:SetEdgeColor(style.hoverEdge[1], style.hoverEdge[2], style.hoverEdge[3], style.hoverEdge[4])

    if control.handlersReady then
        return true
    end

    control:SetHandler("OnMouseEnter", function(selfControl)
        local entry = selfControl.entryData
        if not entry or entry.entryType ~= "action" or selfControl.isDisabled then
            return
        end

        local isSelected = UI.selectionKey and getSelectionKey(entry) == UI.selectionKey
        if not isSelected then
            selfControl.hover:SetHidden(false)
        end
    end)

    control:SetHandler("OnMouseExit", function(selfControl)
        selfControl.hover:SetHidden(true)
    end)

    control:SetHandler("OnClicked", function(selfControl)
        local entry = selfControl.entryData
        if not entry or entry.entryType ~= "action" then
            return
        end

        local nowMs = GetGameTimeMilliseconds()
        local currentKey = getSelectionKey(entry)

        local wasDoubleClick = not selfControl.isDisabled
                and UI.lastClickKey
                and UI.lastClickKey == currentKey
                and UI.lastClickMs
                and (nowMs - UI.lastClickMs) <= Window.DOUBLE_CLICK_MS

        UI.lastClickKey = currentKey
        UI.lastClickMs = nowMs

        selectEntry(entry, true)

        if wasDoubleClick then
            if not Window.ShowHouseMenu(entry, selfControl) then
                Window.TeleportSelected(UI)
            end
        end
    end)

    control.handlersReady = true
    return true
end

local function initDividerRow(control)
    if control.textLabel then
        return true
    end

    control.textLabel = getRowChild(control, "Text")
    if not control.textLabel then
        return false
    end

    control.textLabel:SetFont("ZoFontGame")
    control.textLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    control.textLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return true
end

local function setupEntryRow(control, entry)
    if not initActionRow(control) then
        return
    end

    control.entryData = entry
    control.isDisabled = entry.callback == nil

    local details = entry.details or {}
    local iconPath = details.customIcon or Window.CATEGORY_ICONS[details.category]
    local isSelected = UI.selectionKey and getSelectionKey(entry) == UI.selectionKey
    local isFavorite = Teleport.IsFavorite(entry)
    local isDisabled = control.isDisabled
    local isUnknown = details.isUnknown
    local isLocked = details.isLocked
    local isDimmed = details.isDimmed
    local avaBlocked = isBlockedByAvA(entry)

    control.bg:SetHidden(not isSelected)
    control.hover:SetHidden(true)
    control.lockIcon:SetHidden(true)
    control.icon:SetHidden(true)
    control.favoriteIcon:SetHidden(true)

    local leftControl = nil

    if isFavorite then
        control.favoriteIcon:SetTexture(res.IconPortFavorite)
        control.favoriteIcon:SetAlpha(isDisabled and 0.45 or 0.90)
        control.favoriteIcon:ClearAnchors()
        control.favoriteIcon:SetAnchor(LEFT, control, LEFT, Window.STYLE.rows.iconOffsetX, 0)
        control.favoriteIcon:SetHidden(false)
        leftControl = control.favoriteIcon
    end

    if isUnknown or isLocked then
        control.lockIcon:SetTexture(res.IconPortUnknownLocked)
        control.lockIcon:SetAlpha(isDisabled and 0.55 or 0.72)
        control.lockIcon:ClearAnchors()

        if leftControl then
            control.lockIcon:SetAnchor(LEFT, leftControl, RIGHT, 3, 0)
        else
            control.lockIcon:SetAnchor(LEFT, control, LEFT, Window.STYLE.rows.iconOffsetX, 0)
        end

        control.lockIcon:SetHidden(false)

        if iconPath then
            control.icon:SetTexture(iconPath)
            control.icon:SetAlpha(isDimmed and 0.45 or 0.68)
            control.icon:ClearAnchors()
            control.icon:SetAnchor(LEFT, control.lockIcon, RIGHT, 3, 0)
            control.icon:SetHidden(false)
            anchorRowText(control, control.icon, Window.STYLE.rows.textOffsetX)
        else
            anchorRowText(control, control.lockIcon, Window.STYLE.rows.textOffsetX)
        end
    else
        if iconPath then
            control.icon:SetTexture(iconPath)
            control.icon:SetAlpha(isDisabled and 0.45 or (isDimmed and 0.55 or 0.92))
            control.icon:ClearAnchors()

            if leftControl then
                control.icon:SetAnchor(LEFT, leftControl, RIGHT, 3, 0)
            else
                control.icon:SetAnchor(LEFT, control, LEFT, Window.STYLE.rows.iconOffsetX, 0)
            end

            control.icon:SetHidden(false)
            anchorRowText(control, control.icon, Window.STYLE.rows.textOffsetX)
        else
            anchorRowText(control, leftControl, Window.STYLE.rows.textOffsetX)
        end
    end

    if avaBlocked then
        control.textLabel:SetText((res.Ccolor3 or "") .. (entry.text or "") .. "|r")
        control.textLabel:SetColor(1, 1, 1, 1)
        return
    end

    control.textLabel:SetText(entry.text or "")

    if isDisabled then
        local color = Window.STYLE.text.disabled
        control.textLabel:SetColor(color[1], color[2], color[3], color[4])
    elseif isDimmed then
        local color = Window.STYLE.text.dimmed
        control.textLabel:SetColor(color[1], color[2], color[3], color[4])
    else
        local color = Window.STYLE.text.normal
        control.textLabel:SetColor(color[1], color[2], color[3], color[4])
    end
end

local function setupHeaderRow(control, entry)
    if not initDividerRow(control) then
        return
    end

    control.entryData = entry
    control.textLabel:SetText(entry.text or "")

    local color = Window.STYLE.text.divider
    control.textLabel:SetColor(color[1], color[2], color[3], color[4])
end

function List.InitScrollList()
    if UI.scrollListReady then
        return
    end

    local list = Window.GetList()
    if not list then
        return
    end

    ZO_ScrollList_AddDataType(
            list,
            ROW_ACTION,
            "ArcanumGuildHallTeleportScrollRow",
            Window.STYLE.rows.height,
            setupEntryRow
    )

    ZO_ScrollList_AddDataType(
            list,
            ROW_DIVIDER,
            "ArcanumGuildHallTeleportScrollDividerRow",
            Window.STYLE.rows.height,
            setupHeaderRow
    )

    UI.scrollListReady = true
end

function List.Fill(entries)
    local list = Window.GetList()
    local dataList = ZO_ScrollList_GetDataList(list)

    ZO_ScrollList_Clear(list)

    for i = 1, #entries do
        local entry = entries[i]
        local rowType = entry.entryType == "action" and ROW_ACTION or ROW_DIVIDER
        dataList[#dataList + 1] = ZO_ScrollList_CreateDataEntry(rowType, entry)
    end

    ZO_ScrollList_Commit(list)
end

function List.RefreshList(self)
    local sourceEntries = Window.GetEntries() or {}
    local filteredEntries = filterEntries(sourceEntries)

    local selectedEntry = findSavedSelection(filteredEntries) or findFirstEntry(filteredEntries)

    selectEntry(selectedEntry, false)
    List.Fill(filteredEntries)
    Details.UpdateLoading(self)
end