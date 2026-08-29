ShoppingListHistory = {}

local History = ShoppingListHistory
local WINDOW_WIDTH = 840
local WINDOW_HEIGHT = 500
local ROW_COUNT = 12
local ROW_HEIGHT = 27
local REMOVE_PURCHASE_DIALOG = "SHOPPING_LIST_REMOVE_PURCHASE"

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

local function makeEdit(parent, width)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(
        nil,
        parent,
        "ZO_EditBackdrop"
    )
    backdrop:SetDimensions(width, 30)
    local edit = WINDOW_MANAGER:CreateControlFromVirtual(
        nil,
        backdrop,
        "ZO_DefaultEditForBackdrop"
    )
    edit:SetAnchorFill(backdrop)
    ShoppingListAccessibility:SetFont(edit, "ZoFontGame")
    return backdrop, edit
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

    local add = makeButton(window, GetString(SI_SHOPPING_LIST_HISTORY_ADD), 112)
    add:SetAnchor(LEFT, older, RIGHT, 16, 0)
    add:SetHandler("OnClicked", function() self:OpenCorrection("add") end)
    self.addButton = add

    local reduce = makeButton(window, GetString(SI_SHOPPING_LIST_HISTORY_REDUCE), 92)
    reduce:SetAnchor(LEFT, add, RIGHT, 8, 0)
    reduce:SetHandler("OnClicked", function() self:OpenCorrection("reduce") end)
    self.reduceButton = reduce

    local undo = makeButton(window, GetString(SI_SHOPPING_LIST_HISTORY_UNDO_LATEST), 118)
    undo:SetAnchor(LEFT, reduce, RIGHT, 8, 0)
    undo:SetHandler("OnClicked", function() self:UndoLatest() end)
    self.undoButton = undo

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -14)
    close:SetHandler("OnClicked", function() self:Hide() end)

    self:CreateCorrectionDialog()
    ZO_Dialogs_RegisterCustomDialog(REMOVE_PURCHASE_DIALOG, {
        title = { text = SI_SHOPPING_LIST_HISTORY_REMOVE_TITLE },
        mainText = { text = SI_SHOPPING_LIST_HISTORY_REMOVE_CONFIRM },
        buttons = {
            {
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    self:RemovePurchase(dialog.data.historyIndex)
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    })
end

function History:CreateHeader()
    local headers = {
        { text = GetString(SI_SHOPPING_LIST_HISTORY_DATE), x = 18, width = 105 },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_QUANTITY), x = 128, width = 45, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_EACH), x = 180, width = 85, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_TOTAL), x = 272, width = 90, align = TEXT_ALIGN_RIGHT },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_SOURCE), x = 374, width = 280 },
        { text = GetString(SI_SHOPPING_LIST_HISTORY_ACTIONS), x = 663, width = 158 },
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
    row.source:SetDimensions(280, ROW_HEIGHT)
    row.source:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    row.edit = makeButton(row, GetString(SI_SHOPPING_LIST_BUTTON_EDIT), 70)
    row.edit:SetAnchor(LEFT, row, LEFT, 645, 0)

    row.remove = makeButton(row, GetString(SI_SHOPPING_LIST_BUTTON_REMOVE), 76)
    row.remove:SetAnchor(LEFT, row.edit, RIGHT, 6, 0)
    return row
end

function History:CreateCorrectionDialog()
    local dialog = WINDOW_MANAGER:CreateTopLevelWindow(
        "ShoppingListPurchaseCorrectionWindow"
    )
    dialog:SetDimensions(400, 245)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetClampedToScreen(true)
    dialog:SetMouseEnabled(true)
    dialog:SetHidden(true)
    dialog:SetDrawTier(DT_HIGH)
    self.correctionDialog = dialog

    local backdrop = ShoppingListControls:CreateBackdrop(dialog)
    backdrop:SetAnchorFill(dialog)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    self.correctionTitle = makeLabel(dialog, "ZoFontWinH2")
    self.correctionTitle:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 10)
    self.correctionTitle:SetDimensions(364, 30)

    self.correctionHelp = makeLabel(dialog, "ZoFontGameSmall")
    self.correctionHelp:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 44)
    self.correctionHelp:SetDimensions(364, 40)
    self.correctionHelp:SetVerticalAlignment(TEXT_ALIGN_TOP)

    self.quantityLabel = makeLabel(dialog, "ZoFontGame")
    self.quantityLabel:SetText(GetString(SI_SHOPPING_LIST_HISTORY_QUANTITY))
    self.quantityLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 89)
    self.quantityLabel:SetDimensions(130, 28)

    local quantityBackdrop, quantityEdit = makeEdit(dialog, 190)
    quantityBackdrop:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -18, 87)
    quantityEdit:SetTextType(TEXT_TYPE_NUMERIC)
    quantityEdit:SetMaxInputChars(#tostring(ShoppingListModel.MAX_QUANTITY))
    self.quantityBackdrop = quantityBackdrop
    self.quantityEdit = quantityEdit

    self.priceLabel = makeLabel(dialog, "ZoFontGame")
    self.priceLabel:SetText(GetString(SI_SHOPPING_LIST_HISTORY_UNIT_PRICE))
    self.priceLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 127)
    self.priceLabel:SetDimensions(160, 28)

    local priceBackdrop, priceEdit = makeEdit(dialog, 190)
    priceBackdrop:SetAnchor(TOPRIGHT, dialog, TOPRIGHT, -18, 125)
    priceEdit:SetTextType(TEXT_TYPE_NUMERIC)
    priceEdit:SetMaxInputChars(#tostring(ShoppingListModel.MAX_PRICE))
    self.priceBackdrop = priceBackdrop
    self.priceEdit = priceEdit

    local save = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_SAVE), 90)
    save:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 18, -16)
    save:SetHandler("OnClicked", function() self:SaveCorrection() end)

    local cancel = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_CANCEL), 90)
    cancel:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -18, -16)
    cancel:SetHandler("OnClicked", function() self:CloseCorrection() end)
end

function History:OpenCorrection(mode, historyIndex)
    if not self.item then return end
    local list = self.owner.data:GetListForItem(self.item.id)
    if list and list.locked then
        self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_ERROR_LIST_LOCKED), true)
        return
    end
    if self.owner.data:GetTargetMode(self.item) == "own" then
        self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_ERROR_OWN_TOTAL_MANUAL), true)
        return
    end
    self.correctionMode = mode
    self.correctionHistoryIndex = historyIndex
    local purchase = historyIndex
        and self.item.purchaseHistory[historyIndex] or nil
    if mode == "edit" and not purchase then return end
    self.correctionTitle:SetText(GetString(mode == "edit"
        and SI_SHOPPING_LIST_HISTORY_EDIT_TITLE
        or SI_SHOPPING_LIST_HISTORY_ADJUST_TITLE))
    self.correctionHelp:SetText(GetString(mode == "edit"
        and SI_SHOPPING_LIST_HISTORY_EDIT_HELP
        or (mode == "reduce"
            and SI_SHOPPING_LIST_HISTORY_REDUCE_HELP
            or SI_SHOPPING_LIST_HISTORY_ADD_HELP)))
    self.quantityEdit:SetText(tostring(purchase and purchase.quantity or 1))
    self.priceEdit:SetText(tostring(math.floor(
        tonumber(purchase and purchase.unitPrice) or 0
    )))
    local showPrice = mode ~= "reduce"
    self.priceLabel:SetHidden(not showPrice)
    self.priceBackdrop:SetHidden(not showPrice)
    self.correctionDialog:SetHidden(false)
    self.quantityEdit:TakeFocus()
end

function History:CloseCorrection()
    self.quantityEdit:LoseFocus()
    self.priceEdit:LoseFocus()
    self.correctionDialog:SetHidden(true)
end

function History:SaveCorrection()
    local quantity = tonumber(self.quantityEdit:GetText())
    local unitPrice = tonumber(self.priceEdit:GetText()) or 0
    local ok, message
    if self.correctionMode == "edit" then
        ok, message = self.owner.data:UpdatePurchaseHistory(
            self.item.id,
            self.correctionHistoryIndex,
            quantity,
            unitPrice
        )
    else
        local change = self.correctionMode == "reduce" and -quantity or quantity
        ok, message = self.owner.data:AdjustPurchasedQuantity(
            self.item.id,
            change,
            unitPrice
        )
    end
    if not ok then
        self.owner.ui:SetStatus(message, true)
        return
    end
    self:CloseCorrection()
    self.owner:RefreshInventory()
    self.owner.ui:Refresh()
    self.owner.gamepad:Refresh()
    self:Refresh()
    self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_PURCHASE_CORRECTED))
end

function History:ConfirmRemovePurchase(historyIndex)
    ZO_Dialogs_ShowDialog(REMOVE_PURCHASE_DIALOG, { historyIndex = historyIndex })
end

function History:RemovePurchase(historyIndex)
    local ok, message = self.owner.data:RemovePurchaseHistory(
        self.item.id,
        historyIndex
    )
    if not ok then
        self.owner.ui:SetStatus(message, true)
        return
    end
    self.owner:RefreshInventory()
    self.owner.ui:Refresh()
    self.owner.gamepad:Refresh()
    self:Refresh()
    self.owner.ui:RestoreOwnedMouse(10)
    self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_PURCHASE_REMOVED))
end

function History:UndoLatest()
    local ok, message = self.owner.data:UndoLatestPurchase(self.item.id)
    if not ok then
        self.owner.ui:SetStatus(message, true)
        return
    end
    self.owner:RefreshInventory()
    self.owner.ui:Refresh()
    self.owner.gamepad:Refresh()
    self:Refresh()
    self.owner.ui:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_PURCHASE_UNDONE))
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
    self:CloseCorrection()
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
    local list = self.owner.data:GetListForItem(self.item.id)
    local editable = list ~= nil
        and not list.locked
        and self.owner.data:GetTargetMode(self.item) == "buy"
    self.addButton:SetEnabled(editable)
    self.reduceButton:SetEnabled(editable and (self.item.purchased or 0) > 0)
    self.undoButton:SetEnabled(editable and #history > 0)

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
            row.edit:SetEnabled(editable)
            row.remove:SetEnabled(editable)
            row.edit:SetHandler("OnClicked", function()
                self:OpenCorrection("edit", historyIndex)
            end)
            row.remove:SetHandler("OnClicked", function()
                self:ConfirmRemovePurchase(historyIndex)
            end)
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
