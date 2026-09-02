ShoppingListListTools = {}

local ListTools = ShoppingListListTools
local MAX_BULK_ITEMS = ShoppingListModel.MAX_ITEMS_PER_LIST
local MAX_BULK_TEXT = 20000
local TRIP_ROW_COUNT = 10
local TRIP_ROW_HEIGHT = 31
local BULK_DUPLICATE_DIALOG = "SHOPPING_LIST_BULK_DUPLICATES"

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
    button:SetPressedFontColor(0.65, 0.55, 0.35, 1)
    return button
end

local function trim(value)
    return zo_strtrim(value or "")
end

function ListTools.ParseBulkText(text)
    local entries = {}
    local normalized = string.gsub(text or "", "\r\n", "\n")
    normalized = string.gsub(normalized, "\r", "\n")
    local lineNumber = 0

    for line in string.gmatch(normalized .. "\n", "(.-)\n") do
        lineNumber = lineNumber + 1
        line = trim(line)
        if line ~= "" then
            local name
            local quantity
            quantity, name = string.match(line, "^(%d+)%s*[xX]%s+(.+)$")
            if not name then
                name, quantity = string.match(line, "^(.-)%s+[xX]%s*(%d+)$")
            end
            if not name then
                name, quantity = string.match(line, "^(.-)%s*[,;|\t]%s*(%d+)$")
            end
            if not name then
                name = line
                quantity = 1
            end

            name = trim(name)
            quantity = math.floor(tonumber(quantity) or 0)
            if name == "" or #name > ShoppingListModel.MAX_NAME_LENGTH
                or quantity < 1 or quantity > ShoppingListModel.MAX_QUANTITY
            then
                return nil, zo_strformat(
                    GetString(SI_SHOPPING_LIST_BULK_ERROR_LINE),
                    lineNumber
                )
            end
            entries[#entries + 1] = { name = name, quantity = quantity }
            if #entries > MAX_BULK_ITEMS then
                return nil, zo_strformat(
                    GetString(SI_SHOPPING_LIST_BULK_ERROR_TOO_MANY),
                    MAX_BULK_ITEMS
                )
            end
        end
    end

    if #entries == 0 then
        return nil, GetString(SI_SHOPPING_LIST_BULK_ERROR_EMPTY)
    end
    return entries
end

function ListTools:New(owner)
    return setmetatable({
        owner = owner,
        tripRows = {},
        tripOffset = 0,
    }, { __index = self })
end

function ListTools:Initialize()
    self:CreateBulkWindow()
    self:CreateTripWindow()
    self:InitializeDialogs()
end

function ListTools:InitializeDialogs()
    ZO_Dialogs_RegisterCustomDialog(BULK_DUPLICATE_DIALOG, {
        title = { text = SI_SHOPPING_LIST_DUPLICATE_ITEM_TITLE },
        mainText = {
            text = function(dialog)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_BULK_DUPLICATE_CONFIRM),
                    dialog.data.duplicateCount
                )
            end,
        },
        buttons = {
            {
                text = SI_SHOPPING_LIST_BUTTON_MERGE,
                callback = function(dialog)
                    self:CompleteBulkItems(dialog.data.entries, "merge")
                end,
            },
            {
                text = SI_SHOPPING_LIST_BUTTON_REPLACE,
                callback = function(dialog)
                    self:CompleteBulkItems(dialog.data.entries, "replace")
                end,
            },
            {
                text = SI_SHOPPING_LIST_BUTTON_KEEP_SEPARATE,
                callback = function(dialog)
                    self:CompleteBulkItems(dialog.data.entries, "keep")
                end,
            },
        },
        finishedCallback = function()
            if self.owner.ui then
                self.owner.ui:RestoreOwnedMouse()
            end
        end,
    })
end

function ListTools:CreateBulkWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListBulkWindow")
    window:SetDimensions(620, 430)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    self.bulkWindow = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_BULK_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(584, 30)
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
    ShoppingListControls:MakeWindowMovable(
        window,
        title,
        self.owner.data,
        "bulkAdd"
    )

    local help = makeLabel(window, "ZoFontGame")
    help:SetText(GetString(SI_SHOPPING_LIST_BULK_HELP))
    help:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 45)
    help:SetDimensions(584, 48)
    help:SetVerticalAlignment(TEXT_ALIGN_TOP)
    help:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    local editBackdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, window, "ZO_EditBackdrop")
    editBackdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 98)
    editBackdrop:SetDimensions(584, 245)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(nil, editBackdrop, "ZO_DefaultEditForBackdrop")
    edit:ClearAnchors()
    edit:SetAnchor(TOPLEFT, editBackdrop, TOPLEFT, 5, 4)
    edit:SetAnchor(BOTTOMRIGHT, editBackdrop, BOTTOMRIGHT, -5, -4)
    ShoppingListAccessibility:SetFont(edit, "ZoFontGame")
    edit:SetMaxInputChars(MAX_BULK_TEXT)
    edit:SetNewLineEnabled(true)
    edit:SetSelectAllOnFocus(false)
    edit:SetDefaultText(GetString(SI_SHOPPING_LIST_BULK_PLACEHOLDER))
    edit:SetHandler("OnEscape", function() self:CloseBulkWindow() end)
    self.bulkEdit = edit

    self.bulkStatus = makeLabel(window, "ZoFontGameSmall")
    self.bulkStatus:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 348)
    self.bulkStatus:SetDimensions(584, 28)

    local add = makeButton(window, GetString(SI_SHOPPING_LIST_BULK_ADD), 120)
    add:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -16)
    add:SetHandler("OnClicked", function() self:AddBulkItems() end)

    local cancel = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CANCEL), 90)
    cancel:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -16)
    cancel:SetHandler("OnClicked", function() self:CloseBulkWindow() end)
end

function ListTools:CreateTripWindow()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListTripWindow")
    window:SetDimensions(510, 500)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetHandler("OnMouseWheel", function(_, delta) self:ScrollTripLists(-delta) end)
    self.tripWindow = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_TRIP_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(474, 30)
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
    ShoppingListControls:MakeWindowMovable(
        window,
        title,
        self.owner.data,
        "shoppingTrip"
    )

    local help = makeLabel(window, "ZoFontGame")
    help:SetText(GetString(SI_SHOPPING_LIST_TRIP_HELP))
    help:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 44)
    help:SetDimensions(474, 48)
    help:SetVerticalAlignment(TEXT_ALIGN_TOP)
    help:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    for index = 1, TRIP_ROW_COUNT do
        local row = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
        row:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 96 + ((index - 1) * TRIP_ROW_HEIGHT))
        row:SetDimensions(474, TRIP_ROW_HEIGHT)
        row.toggle = makeButton(row, "[ ]", 38)
        row.toggle:SetAnchor(LEFT, row, LEFT, 0, 0)
        row.name = makeLabel(row, "ZoFontGame")
        row.name:SetAnchor(LEFT, row.toggle, RIGHT, 8, 0)
        row.name:SetDimensions(420, TRIP_ROW_HEIGHT)
        row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        self.tripRows[index] = row
    end

    self.tripStatus = makeLabel(window, "ZoFontGameSmall")
    self.tripStatus:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -52)
    self.tripStatus:SetDimensions(290, 24)

    self.tripPage = makeLabel(window, "ZoFontGameSmall")
    self.tripPage:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.tripPage:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -52)
    self.tripPage:SetDimensions(180, 24)

    self.tripModeButton = makeButton(window, "", 150)
    self.tripModeButton:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -16)
    self.tripModeButton:SetHandler("OnClicked", function() self:ToggleTripMode() end)

    local all = makeButton(window, GetString(SI_SHOPPING_LIST_TRIP_ALL), 70)
    all:SetAnchor(LEFT, self.tripModeButton, RIGHT, 8, 0)
    all:SetHandler("OnClicked", function()
        self.owner.data:SetAllTripListsActive()
        self:TripSelectionChanged()
    end)

    local current = makeButton(window, GetString(SI_SHOPPING_LIST_TRIP_CURRENT_ONLY), 110)
    current:SetAnchor(LEFT, all, RIGHT, 8, 0)
    current:SetHandler("OnClicked", function()
        self.owner.data:SetOnlyTripListActive(self.owner.data:GetCurrentList().id)
        self:TripSelectionChanged()
    end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -16)
    close:SetHandler("OnClicked", function() self:CloseTripWindow() end)
end

function ListTools:SetBulkStatus(message, isError)
    if self.owner.accessibility then
        message = self.owner.accessibility:FormatStatus(message, isError)
    end
    self.bulkStatus:SetText(message or "")
    self.bulkStatus:SetColor(isError and 1 or 0.65, isError and 0.35 or 0.82, isError and 0.35 or 0.55, 1)
end

function ListTools:SetTripStatus(message, isError)
    if self.owner.accessibility then
        message = self.owner.accessibility:FormatStatus(message, isError)
    end
    self.tripStatus:SetText(message or "")
    self.tripStatus:SetColor(isError and 1 or 0.65, isError and 0.35 or 0.82, isError and 0.35 or 0.55, 1)
end

function ListTools:OpenBulkWindow()
    self.owner.ui:CloseListDialog()
    self.bulkEdit:SetText("")
    self:SetBulkStatus("")
    self.bulkWindow:SetHidden(false)
    self.bulkEdit:TakeFocus()
end

function ListTools:CloseBulkWindow()
    self.bulkEdit:LoseFocus()
    self.bulkWindow:SetHidden(true)
end

function ListTools:AddBulkItems()
    local entries, message = ListTools.ParseBulkText(self.bulkEdit:GetText())
    if not entries then
        self:SetBulkStatus(message, true)
        return
    end

    local list = self.owner.data:GetCurrentList()
    local duplicateCount, duplicateMessage = self.owner.data:CountDuplicateSources(
        list.id,
        entries
    )
    if duplicateCount == nil then
        self:SetBulkStatus(duplicateMessage, true)
        return
    end
    if duplicateCount > 0 then
        self.bulkEdit:LoseFocus()
        ZO_Dialogs_ShowDialog(BULK_DUPLICATE_DIALOG, {
            entries = entries,
            duplicateCount = duplicateCount,
        })
        return
    end

    self:CompleteBulkItems(entries, "keep")
end

function ListTools:CompleteBulkItems(entries, duplicatePolicy)
    local list = self.owner.data:GetCurrentList()
    local items, message = self.owner.data:AddItemsToList(
        list.id,
        entries,
        duplicatePolicy
    )
    if not items then
        self:SetBulkStatus(message, true)
        self.bulkEdit:TakeFocus()
        return
    end
    self:CloseBulkWindow()
    self.owner.ui:Refresh()
    self.owner.gamepad:Refresh()
    self.owner:RefreshInventory()
    self.owner.ui:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_BULK_ADDED),
        #items
    ))
end

function ListTools:OpenTripWindow()
    self.owner.ui:CloseListDialog()
    self.tripOffset = 0
    self:SetTripStatus("")
    self.tripWindow:SetHidden(false)
    self:RefreshTripWindow()
end

function ListTools:CloseTripWindow()
    self.tripWindow:SetHidden(true)
end

function ListTools:Hide()
    self:CloseBulkWindow()
    self:CloseTripWindow()
end

function ListTools:ScrollTripLists(delta)
    local lists = self.owner.data:GetLists()
    self.tripOffset = zo_clamp(
        self.tripOffset + delta,
        0,
        math.max(0, #lists - TRIP_ROW_COUNT)
    )
    self:RefreshTripWindow()
end

function ListTools:RefreshTripWindow()
    local lists = self.owner.data:GetLists()
    self.tripOffset = zo_clamp(
        self.tripOffset,
        0,
        math.max(0, #lists - TRIP_ROW_COUNT)
    )
    local currentId = self.owner.data:GetCurrentList().id
    for rowIndex, row in ipairs(self.tripRows) do
        local list = lists[self.tripOffset + rowIndex]
        row:SetHidden(list == nil)
        if list then
            local listId = list.id
            row.toggle:SetText(list.tripActive and "[x]" or "[ ]")
            row.name:SetText(list.id == currentId
                and zo_strformat(GetString(SI_SHOPPING_LIST_TRIP_SELECTED_LIST), list.name)
                or list.name)
            row.toggle:SetHandler("OnClicked", function()
                local current = self.owner.data:FindList(listId)
                local ok, message = self.owner.data:SetListTripActive(
                    listId,
                    current and not current.tripActive
                )
                if not ok then
                    self:SetTripStatus(message, true)
                    return
                end
                self:TripSelectionChanged()
            end)
        end
    end
    if #lists > TRIP_ROW_COUNT then
        self.tripPage:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PAGE_WITH_HINT),
            self.tripOffset + 1,
            math.min(self.tripOffset + TRIP_ROW_COUNT, #lists),
            #lists,
            GetString(SI_SHOPPING_LIST_HINT_MOUSE_WHEEL)
        ))
    else
        self.tripPage:SetText("")
    end
    self.tripModeButton:SetText(GetString(self.owner.data:IsMultiListTripEnabled()
        and SI_SHOPPING_LIST_TRIP_DISABLE
        or SI_SHOPPING_LIST_TRIP_ENABLE))
end

function ListTools:TripSelectionChanged()
    self.owner:RefreshInventory()
    self.owner.ui.listSignature = nil
    self.owner.ui:Refresh()
    self.owner.gamepad:Refresh()
    self:SetTripStatus(GetString(SI_SHOPPING_LIST_TRIP_SELECTION_UPDATED))
    self:RefreshTripWindow()
end

function ListTools:ToggleTripMode()
    local enabled = not self.owner.data:IsMultiListTripEnabled()
    self.owner.data:SetMultiListTripEnabled(enabled)
    self:TripSelectionChanged()
    self:SetTripStatus(GetString(enabled
        and SI_SHOPPING_LIST_TRIP_ENABLED
        or SI_SHOPPING_LIST_TRIP_DISABLED))
end
