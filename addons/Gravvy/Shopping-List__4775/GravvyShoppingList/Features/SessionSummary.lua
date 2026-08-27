ShoppingListSessionSummary = {}

local Session = ShoppingListSessionSummary
local WINDOW_WIDTH = 700
local WINDOW_HEIGHT = 500
local ROW_COUNT = 10
local ROW_HEIGHT = 27

local function makeLabel(parent, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    ShoppingListAccessibility:SetFont(label, font or "ZoFontGame")
    label:SetColor(0.9, 0.9, 0.9, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function makeButton(parent, text, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, 30)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    return button
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

function Session:New(owner)
    return setmetatable({ owner = owner }, { __index = self })
end

function Session:Reset()
    self.startedAt = GetTimeStamp()
    self.transactions = {}
    self.updatedLists = {}
    self.offset = 0
    if self.window and not self.window:IsHidden() then
        self:Refresh()
    end
end

function Session:Initialize()
    self:Reset()

    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListSessionSummaryWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetHandler("OnMouseWheel", function(_, delta) self:Scroll(-delta) end)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_SESSION_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(300, 30)
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

    self.overview = makeLabel(window, "ZoFontGameSmall")
    self.overview:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.overview:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.overview:SetAnchor(TOPRIGHT, window, TOPRIGHT, -18, 8)
    self.overview:SetDimensions(360, 42)
    self.overview:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    self:CreateHeader()
    self.rows = {}
    for index = 1, ROW_COUNT do
        self.rows[index] = self:CreateRow(index)
    end

    self.lists = makeLabel(window, "ZoFontGameSmall")
    self.lists:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 356)
    self.lists:SetDimensions(WINDOW_WIDTH - 36, 62)
    self.lists:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.lists:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    self.page = makeLabel(window, "ZoFontGameSmall")
    self.page:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.page:SetAnchor(BOTTOM, window, BOTTOM, 0, -50)
    self.page:SetDimensions(290, 22)

    local newer = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_NEWER), 80)
    newer:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -14)
    newer:SetHandler("OnClicked", function() self:Scroll(-ROW_COUNT) end)

    local older = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_OLDER), 80)
    older:SetAnchor(LEFT, newer, RIGHT, 8, 0)
    older:SetHandler("OnClicked", function() self:Scroll(ROW_COUNT) end)

    local reset = makeButton(window, GetString(SI_SHOPPING_LIST_SESSION_RESET), 125)
    reset:SetAnchor(BOTTOM, window, BOTTOM, 0, -14)
    reset:SetHandler("OnClicked", function() self:Reset() end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -14)
    close:SetHandler("OnClicked", function() self:Hide() end)
end

function Session:CreateHeader()
    local headers = {
        { text = GetString(SI_SHOPPING_LIST_SESSION_ITEM), x = 18, width = 330 },
        { text = GetString(SI_SHOPPING_LIST_SESSION_QUANTITY), x = 355, width = 55, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_SESSION_SPENT), x = 418, width = 95, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_SESSION_LISTS), x = 525, width = 157 },
    }
    for _, data in ipairs(headers) do
        local label = makeLabel(self.window, "ZoFontGameSmall")
        label:SetText(data.text)
        label:SetColor(0.72, 0.65, 0.5, 1)
        label:SetHorizontalAlignment(data.align or TEXT_ALIGN_LEFT)
        label:SetAnchor(TOPLEFT, self.window, TOPLEFT, data.x, 55)
        label:SetDimensions(data.width, 24)
    end
end

function Session:CreateRow(index)
    local row = WINDOW_MANAGER:CreateControl(nil, self.window, CT_CONTROL)
    row:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 80 + ((index - 1) * ROW_HEIGHT))
    row:SetDimensions(WINDOW_WIDTH - 36, ROW_HEIGHT)

    row.item = makeLabel(row, "ZoFontGameSmall")
    row.item:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.item:SetDimensions(330, ROW_HEIGHT)
    row.item:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.quantity = makeLabel(row, "ZoFontGameSmall")
    row.quantity:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.quantity:SetAnchor(LEFT, row, LEFT, 337, 0)
    row.quantity:SetDimensions(55, ROW_HEIGHT)

    row.spent = makeLabel(row, "ZoFontGameSmall")
    row.spent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.spent:SetAnchor(LEFT, row, LEFT, 400, 0)
    row.spent:SetDimensions(95, ROW_HEIGHT)

    row.lists = makeLabel(row, "ZoFontGameSmall")
    row.lists:SetAnchor(LEFT, row, LEFT, 507, 0)
    row.lists:SetDimensions(157, ROW_HEIGHT)
    row.lists:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    return row
end

function Session:RecordTransaction(transaction)
    if type(transaction) ~= "table" then
        return false
    end
    self.transactions = self.transactions or {}
    self.updatedLists = self.updatedLists or {}

    local listNames = {}
    local seen = {}
    for _, allocation in ipairs(transaction.allocations or {}) do
        local listId = allocation.listId
        if listId and not seen[listId] then
            seen[listId] = true
            local list = self.owner.data:FindList(listId)
                or self.owner.data:FindArchivedList(listId)
            local name = list and list.name or tostring(listId)
            listNames[#listNames + 1] = name
            self.updatedLists[listId] = name
        end
    end

    self.transactions[#self.transactions + 1] = {
        timestamp = transaction.timestamp,
        itemLink = transaction.itemLink,
        itemName = transaction.itemName,
        quantity = math.max(0, tonumber(transaction.quantity) or 0),
        totalPrice = math.max(0, tonumber(transaction.totalPrice) or 0),
        listNames = listNames,
    }
    if self.window and not self.window:IsHidden() then
        self:Refresh()
    end
    return true
end

function Session:GetSnapshot()
    local snapshot = {
        startedAt = self.startedAt,
        transactionCount = 0,
        purchasedQuantity = 0,
        totalSpent = 0,
        updatedListCount = 0,
        remainingEntries = 0,
        transactions = self.transactions or {},
        lists = {},
    }
    snapshot.transactionCount = #snapshot.transactions
    for _, transaction in ipairs(snapshot.transactions) do
        snapshot.purchasedQuantity = snapshot.purchasedQuantity
            + math.max(0, tonumber(transaction.quantity) or 0)
        snapshot.totalSpent = snapshot.totalSpent
            + math.max(0, tonumber(transaction.totalPrice) or 0)
    end

    for listId, recordedName in pairs(self.updatedLists or {}) do
        local list = self.owner.data:FindList(listId)
            or self.owner.data:FindArchivedList(listId)
        local remaining = 0
        if list then
            for _, item in ipairs(list.items or {}) do
                if self.owner.data:GetRemainingQuantity(item) > 0 then
                    remaining = remaining + 1
                end
            end
        end
        snapshot.lists[#snapshot.lists + 1] = {
            id = listId,
            name = list and list.name or recordedName,
            remainingEntries = remaining,
        }
        snapshot.remainingEntries = snapshot.remainingEntries + remaining
    end
    table.sort(snapshot.lists, function(left, right)
        return zo_strlower(left.name or "") < zo_strlower(right.name or "")
    end)
    snapshot.updatedListCount = #snapshot.lists
    return snapshot
end

function Session:GetOverviewText()
    local snapshot = self:GetSnapshot()
    if snapshot.transactionCount == 0 then
        return GetString(SI_SHOPPING_LIST_SESSION_EMPTY)
    end
    return zo_strformat(
        GetString(SI_SHOPPING_LIST_SESSION_OVERVIEW),
        snapshot.transactionCount,
        snapshot.purchasedQuantity,
        formatGold(snapshot.totalSpent),
        snapshot.updatedListCount,
        snapshot.remainingEntries
    )
end

function Session:GetUpdatedListsText()
    local snapshot = self:GetSnapshot()
    if #snapshot.lists == 0 then
        return ""
    end
    local parts = {}
    for _, list in ipairs(snapshot.lists) do
        parts[#parts + 1] = zo_strformat(
            GetString(SI_SHOPPING_LIST_SESSION_LIST_DETAIL),
            list.name,
            list.remainingEntries
        )
    end
    return zo_strformat(
        GetString(SI_SHOPPING_LIST_SESSION_UPDATED_LISTS),
        table.concat(parts, " · ")
    )
end

function Session:GetTransactionText(transaction)
    local name = transaction.itemLink
    if not name or name == "" then
        name = transaction.itemName or GetString(SI_SHOPPING_LIST_UNKNOWN_ITEM)
    end
    return zo_strformat(
        GetString(SI_SHOPPING_LIST_SESSION_TRANSACTION),
        name,
        transaction.quantity or 0,
        formatGold(transaction.totalPrice)
    )
end

function Session:Open()
    self.offset = 0
    self.window:SetHidden(false)
    self:Refresh()
end

function Session:Hide()
    if self.window then
        self.window:SetHidden(true)
    end
end

function Session:Scroll(delta)
    local transactions = self.transactions or {}
    self.offset = zo_clamp(
        (self.offset or 0) + delta,
        0,
        math.max(0, #transactions - ROW_COUNT)
    )
    self:Refresh()
end

function Session:Refresh()
    local snapshot = self:GetSnapshot()
    local maxOffset = math.max(0, #snapshot.transactions - ROW_COUNT)
    self.offset = zo_clamp(self.offset or 0, 0, maxOffset)
    self.overview:SetText(self:GetOverviewText())
    self.lists:SetText(self:GetUpdatedListsText())

    for rowIndex, row in ipairs(self.rows) do
        local transactionIndex = #snapshot.transactions - self.offset - rowIndex + 1
        local transaction = snapshot.transactions[transactionIndex]
        row:SetHidden(transaction == nil)
        if transaction then
            local name = transaction.itemLink
            if not name or name == "" then
                name = transaction.itemName or GetString(SI_SHOPPING_LIST_UNKNOWN_ITEM)
            end
            row.item:SetText(name)
            row.quantity:SetText(tostring(transaction.quantity or 0))
            row.spent:SetText(formatGold(transaction.totalPrice))
            row.lists:SetText(table.concat(transaction.listNames or {}, ", "))
        end
    end

    if #snapshot.transactions > ROW_COUNT then
        self.page:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PAGE_WITH_HINT),
            self.offset + 1,
            math.min(self.offset + ROW_COUNT, #snapshot.transactions),
            #snapshot.transactions,
            GetString(SI_SHOPPING_LIST_HINT_MOUSE_WHEEL)
        ))
    else
        self.page:SetText("")
    end
end
