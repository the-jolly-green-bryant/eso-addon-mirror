ShoppingListArchive = {}

local Archive = ShoppingListArchive
local WINDOW_WIDTH = 560
local WINDOW_HEIGHT = 430
local ROW_COUNT = 10
local ROW_HEIGHT = 29

local function makeLabel(parent, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    ShoppingListAccessibility:SetFont(label, font or "ZoFontGame")
    label:SetColor(0.9, 0.9, 0.9, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function makeButton(parent, text, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, 28)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    return button
end

local function formatDate(timestamp)
    timestamp = tonumber(timestamp)
    if not timestamp then
        return GetString(SI_SHOPPING_LIST_UNKNOWN_DATE)
    end
    if GetDateStringFromTimestamp then
        return GetDateStringFromTimestamp(timestamp)
    end
    return tostring(timestamp)
end

local function formatGold(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    if ZO_CommaDelimitNumber then
        return zo_strformat(
            GetString(SI_SHOPPING_LIST_GOLD_SHORT),
            ZO_CommaDelimitNumber(value)
        )
    end
    return zo_strformat(GetString(SI_SHOPPING_LIST_GOLD_SHORT), value)
end

function Archive:New(owner)
    return setmetatable({ owner = owner, rows = {}, offset = 0 }, { __index = self })
end

function Archive:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListArchiveWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetHandler("OnMouseWheel", function(_, delta) self:Scroll(-delta) end)
    self.window = window

    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_DefaultBackdrop")
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_ARCHIVE_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(340, 30)
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    title:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    self.summary = makeLabel(window, "ZoFontGameSmall")
    self.summary:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.summary:SetAnchor(TOPRIGHT, window, TOPRIGHT, -18, 12)
    self.summary:SetDimensions(180, 26)

    self.emptyMessage = makeLabel(window, "ZoFontGame")
    self.emptyMessage:SetText(GetString(SI_SHOPPING_LIST_ARCHIVE_EMPTY))
    self.emptyMessage:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.emptyMessage:SetAnchor(CENTER, window, CENTER, 0, -10)
    self.emptyMessage:SetDimensions(WINDOW_WIDTH - 50, 32)

    self:CreateHeader()
    for index = 1, ROW_COUNT do
        self.rows[index] = self:CreateRow(index)
    end

    self.page = makeLabel(window, "ZoFontGameSmall")
    self.page:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.page:SetAnchor(BOTTOM, window, BOTTOM, 0, -52)
    self.page:SetDimensions(260, 22)

    local newer = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_NEWER), 80)
    newer:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -14)
    newer:SetHandler("OnClicked", function() self:Scroll(-ROW_COUNT) end)

    local older = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_OLDER), 80)
    older:SetAnchor(LEFT, newer, RIGHT, 8, 0)
    older:SetHandler("OnClicked", function() self:Scroll(ROW_COUNT) end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -14)
    close:SetHandler("OnClicked", function() self:Hide() end)
end

function Archive:CreateHeader()
    local name = makeLabel(self.window, "ZoFontGameSmall")
    name:SetText(GetString(SI_SHOPPING_LIST_ARCHIVE_COLUMN_LIST))
    name:SetColor(0.72, 0.65, 0.5, 1)
    name:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 52)
    name:SetDimensions(255, 24)

    local details = makeLabel(self.window, "ZoFontGameSmall")
    details:SetText(GetString(SI_SHOPPING_LIST_ARCHIVE_COLUMN_DETAILS))
    details:SetColor(0.72, 0.65, 0.5, 1)
    details:SetAnchor(TOPLEFT, self.window, TOPLEFT, 282, 52)
    details:SetDimensions(160, 24)
end

function Archive:CreateRow(index)
    local row = WINDOW_MANAGER:CreateControl(nil, self.window, CT_CONTROL)
    row:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 78 + ((index - 1) * ROW_HEIGHT))
    row:SetDimensions(WINDOW_WIDTH - 36, ROW_HEIGHT)

    row.name = makeLabel(row, "ZoFontGame")
    row.name:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.name:SetDimensions(255, ROW_HEIGHT)
    row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.details = makeLabel(row, "ZoFontGameSmall")
    row.details:SetAnchor(LEFT, row, LEFT, 264, 0)
    row.details:SetDimensions(160, ROW_HEIGHT)
    row.details:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.restore = makeButton(row, GetString(SI_SHOPPING_LIST_BUTTON_RESTORE), 78)
    row.restore:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    return row
end

function Archive:Open()
    self.owner.ui:CloseListDialog()
    self.offset = 0
    self.window:SetHidden(false)
    self:Refresh()
end

function Archive:Hide()
    self.window:SetHidden(true)
end

function Archive:Scroll(delta)
    local lists = self.owner.data:GetArchivedLists()
    self.offset = zo_clamp(self.offset + delta, 0, math.max(0, #lists - ROW_COUNT))
    self:Refresh()
end

function Archive:Restore(listId)
    local ok, listOrMessage = self.owner.data:RestoreList(listId)
    if not ok then
        self.owner.ui:SetStatus(listOrMessage, true)
        self:Refresh()
        return
    end

    self.owner.ui.listSignature = nil
    self.owner.ui:SelectList(listOrMessage.id)
    self.owner:RefreshInventory()
    self.owner.ui:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_RESTORED),
        listOrMessage.name
    ))
    self:Refresh()
end

function Archive:Refresh()
    local lists = self.owner.data:GetArchivedLists()
    local maxOffset = math.max(0, #lists - ROW_COUNT)
    self.offset = zo_clamp(self.offset, 0, maxOffset)
    self.summary:SetText(zo_strformat(
        GetString(SI_SHOPPING_LIST_ARCHIVE_SUMMARY),
        #lists,
        GetString(#lists == 1
            and SI_SHOPPING_LIST_NOUN_ARCHIVED_LIST
            or SI_SHOPPING_LIST_NOUN_ARCHIVED_LISTS)
    ))
    self.emptyMessage:SetHidden(#lists > 0)

    for rowIndex, row in ipairs(self.rows) do
        local listIndex = #lists - self.offset - rowIndex + 1
        local list = lists[listIndex]
        row:SetHidden(list == nil)
        if list then
            local listId = list.id
            row.name:SetText(zo_strformat(
                GetString(SI_SHOPPING_LIST_ARCHIVE_ROW),
                list.name,
                #list.items,
                GetString(#list.items == 1
                    and SI_SHOPPING_LIST_NOUN_ITEM
                    or SI_SHOPPING_LIST_NOUN_ITEMS)
            ))
            row.details:SetText(zo_strformat(
                GetString(SI_SHOPPING_LIST_ARCHIVE_DETAILS),
                formatDate(list.archivedAt),
                formatGold(list.totalSpent)
            ))
            row.restore:SetHandler("OnClicked", function() self:Restore(listId) end)
        end
    end

    if #lists > ROW_COUNT then
        self.page:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PAGE_WITH_HINT),
            self.offset + 1,
            math.min(self.offset + ROW_COUNT, #lists),
            #lists,
            GetString(SI_SHOPPING_LIST_HINT_MOUSE_WHEEL)
        ))
    else
        self.page:SetText("")
    end
end
