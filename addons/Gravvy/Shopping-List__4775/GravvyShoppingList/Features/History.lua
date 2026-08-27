ShoppingListHistory = {}

local History = ShoppingListHistory
local WINDOW_WIDTH = 700
local WINDOW_HEIGHT = 500
local ROW_COUNT = 12
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

local function setRowColor(row, red)
    local color = red and { 1, 0.45, 0.35, 1 } or { 0.9, 0.9, 0.9, 1 }
    row.date:SetColor(unpack(color))
    row.quantity:SetColor(unpack(color))
    row.unitPrice:SetColor(unpack(color))
    row.totalPrice:SetColor(unpack(color))
    row.source:SetColor(unpack(color))
end

function History:New(owner)
    return setmetatable({ owner = owner, rows = {}, offset = 0 }, { __index = self })
end

function History:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListHistoryWindow")
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
    title:SetText(GetString(SI_SHOPPING_LIST_HISTORY_TITLE))
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

    self.summary = makeLabel(window, "ZoFontGameSmall")
    self.summary:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.summary:SetAnchor(TOPRIGHT, window, TOPRIGHT, -18, 12)
    self.summary:SetDimensions(330, 26)

    self.itemName = makeLabel(window, "ZoFontGame")
    self.itemName:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 43)
    self.itemName:SetDimensions(WINDOW_WIDTH - 36, 28)
    self.itemName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

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

function History:CreateHeader()
    local headers = {
        { text = GetString(SI_SHOPPING_LIST_HISTORY_DATE), x = 18, width = 105 },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_QUANTITY), x = 128, width = 45, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_EACH), x = 180, width = 85, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_TOTAL), x = 272, width = 90, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_SOURCE), x = 374, width = 308 },
    }
    for _, data in ipairs(headers) do
        local label = makeLabel(self.window, "ZoFontGameSmall")
        label:SetText(data.text)
        label:SetColor(0.72, 0.65, 0.5, 1)
        label:SetHorizontalAlignment(data.align or TEXT_ALIGN_LEFT)
        label:SetAnchor(TOPLEFT, self.window, TOPLEFT, data.x, 76)
        label:SetDimensions(data.width, 24)
    end
end

function History:CreateRow(index)
    local row = WINDOW_MANAGER:CreateControl(nil, self.window, CT_CONTROL)
    row:SetAnchor(TOPLEFT, self.window, TOPLEFT, 18, 101 + ((index - 1) * ROW_HEIGHT))
    row:SetDimensions(WINDOW_WIDTH - 36, ROW_HEIGHT)

    row.date = makeLabel(row, "ZoFontGameSmall")
    row.date:SetAnchor(LEFT, row, LEFT, 0, 0)
    row.date:SetDimensions(105, ROW_HEIGHT)

    row.quantity = makeLabel(row, "ZoFontGameSmall")
    row.quantity:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.quantity:SetAnchor(LEFT, row, LEFT, 110, 0)
    row.quantity:SetDimensions(45, ROW_HEIGHT)

    row.unitPrice = makeLabel(row, "ZoFontGameSmall")
    row.unitPrice:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.unitPrice:SetAnchor(LEFT, row, LEFT, 162, 0)
    row.unitPrice:SetDimensions(85, ROW_HEIGHT)

    row.totalPrice = makeLabel(row, "ZoFontGameSmall")
    row.totalPrice:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.totalPrice:SetAnchor(LEFT, row, LEFT, 254, 0)
    row.totalPrice:SetDimensions(90, ROW_HEIGHT)

    row.source = makeLabel(row, "ZoFontGameSmall")
    row.source:SetAnchor(LEFT, row, LEFT, 356, 0)
    row.source:SetDimensions(308, ROW_HEIGHT)
    row.source:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    return row
end

function History:Open(item)
    if not item then
        return
    end
    self.item = item
    self.offset = 0
    self.itemName:SetText(item.itemLink ~= "" and item.itemLink or item.name)
    self.window:SetHidden(false)
    self:Refresh()
end

function History:Hide()
    self.window:SetHidden(true)
end

function History:Scroll(delta)
    if not self.item then
        return
    end
    local history = self.item.purchaseHistory or {}
    self.offset = zo_clamp(self.offset + delta, 0, math.max(0, #history - ROW_COUNT))
    self:Refresh()
end

function History:Refresh()
    if not self.item then
        return
    end

    local history = self.item.purchaseHistory or {}
    local maxOffset = math.max(0, #history - ROW_COUNT)
    self.offset = zo_clamp(self.offset, 0, maxOffset)
    local purchaseCount = math.max(#history, tonumber(self.item.purchaseCount) or 0)
    local summary = zo_strformat(
        GetString(SI_SHOPPING_LIST_HISTORY_SUMMARY),
        purchaseCount,
        GetString(purchaseCount == 1
            and SI_SHOPPING_LIST_NOUN_PURCHASE
            or SI_SHOPPING_LIST_NOUN_PURCHASES),
        formatGold(self.item.totalSpent)
    )
    if purchaseCount > #history then
        summary = summary .. " · " .. zo_strformat(
            GetString(SI_SHOPPING_LIST_HISTORY_RECENT_SHOWN),
            #history
        )
    end
    self.summary:SetText(summary)

    for rowIndex, row in ipairs(self.rows) do
        local historyIndex = #history - self.offset - rowIndex + 1
        local purchase = history[historyIndex]
        row:SetHidden(purchase == nil)
        if purchase then
            row.date:SetText(formatDate(purchase.timestamp))
            row.quantity:SetText(tostring(purchase.quantity or 0))
            row.unitPrice:SetText(formatGold(purchase.unitPrice))
            row.totalPrice:SetText(formatGold(purchase.totalPrice))

            local source = {}
            if purchase.guildName and purchase.guildName ~= "" then
                source[#source + 1] = purchase.guildName
            end
            if purchase.sellerName and purchase.sellerName ~= "" then
                source[#source + 1] = purchase.sellerName
            end
            row.source:SetText(#source > 0
                and table.concat(source, " · ")
                or GetString(SI_SHOPPING_LIST_UNKNOWN_TRADER))
            setRowColor(
                row,
                self.item.maxUnitPrice
                    and (tonumber(purchase.unitPrice) or 0) > self.item.maxUnitPrice
            )
        end
    end

    if #history == 0 then
        self.page:SetText(GetString(SI_SHOPPING_LIST_NO_RECORDED_PURCHASES))
    elseif #history > ROW_COUNT then
        self.page:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PAGE_WITH_HINT),
            self.offset + 1,
            math.min(self.offset + ROW_COUNT, #history),
            #history,
            GetString(SI_SHOPPING_LIST_HINT_MOUSE_WHEEL)
        ))
    else
        self.page:SetText("")
    end
end
