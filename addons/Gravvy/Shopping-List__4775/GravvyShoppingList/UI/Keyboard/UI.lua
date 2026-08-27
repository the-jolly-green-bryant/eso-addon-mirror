ShoppingListUI = {}

local UI = ShoppingListUI
local DEFAULT_WIDTH = 350
local DEFAULT_HEIGHT = 500
local MIN_WIDTH = 350
local MIN_HEIGHT = 400
local MAX_WIDTH = 900
local MAX_HEIGHT = 900
local MAX_ROWS = 24
local ROW_TOP = 123
local ROW_HEIGHT = 33
local FOOTER_HEIGHT = 138
local SUGGESTION_ROWS = 6
local REMOVE_ITEM_DIALOG = "SHOPPING_LIST_CONFIRM_REMOVE_ITEM"
local RESET_PROGRESS_DIALOG = "SHOPPING_LIST_CONFIRM_RESET_PROGRESS"
local DUPLICATE_ITEM_DIALOG = "SHOPPING_LIST_DUPLICATE_ITEM"
local DONATION_RECIPIENT = "@Gravvy"
local NORTH_AMERICAN_MEGASERVER = "NA Megaserver"

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
    button:SetPressedFontColor(0.65, 0.55, 0.35, 1)
    return button
end

local function makeEdit(parent, width)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_EditBackdrop")
    backdrop:SetDimensions(width, 30)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(nil, backdrop, "ZO_DefaultEditForBackdrop")
    edit:ClearAnchors()
    edit:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 3, 2)
    edit:SetAnchor(BOTTOMRIGHT, backdrop, BOTTOMRIGHT, -3, -2)
    ShoppingListAccessibility:SetFont(edit, "ZoFontGame")
    edit:SetMaxInputChars(ShoppingListModel.MAX_NAME_LENGTH)
    edit:SetNewLineEnabled(false)
    edit:SetSelectAllOnFocus(true)
    return backdrop, edit
end

local function makeNoteEdit(parent, width, height)
    local backdrop = WINDOW_MANAGER:CreateControlFromVirtual(nil, parent, "ZO_EditBackdrop")
    backdrop:SetDimensions(width, height)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(
        nil,
        backdrop,
        "ZO_DefaultEditMultiLineForBackdrop"
    )
    edit:ClearAnchors()
    edit:SetAnchor(TOPLEFT, backdrop, TOPLEFT, 5, 4)
    edit:SetAnchor(BOTTOMRIGHT, backdrop, BOTTOMRIGHT, -5, -4)
    ShoppingListAccessibility:SetFont(edit, "ZoFontGame")
    edit:SetMaxInputChars(ShoppingListData.MAX_NOTE_LENGTH)
    edit:SetNewLineEnabled(true)
    return backdrop, edit
end

local function makeCombo(parent, name, width)
    local controlName = parent:GetName() .. name .. "Combo"
    local container = WINDOW_MANAGER:CreateControlFromVirtual(
        controlName,
        parent,
        "ZO_ComboBox"
    )
    container:SetDimensions(width, 30)
    local combo = ZO_ComboBox_ObjectFromContainer(container)
    combo:SetSortsItems(false)
    return container, combo
end

local function formatCompactGold(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    if value >= 1000000 then
        return zo_strformat(
            GetString(SI_SHOPPING_LIST_GOLD_MILLIONS),
            string.format("%.1f", value / 1000000)
        )
    end
    if value >= 1000 then
        return zo_strformat(
            GetString(SI_SHOPPING_LIST_GOLD_THOUSANDS),
            string.format("%.1f", value / 1000)
        )
    end
    return zo_strformat(GetString(SI_SHOPPING_LIST_GOLD_SHORT), value)
end

function UI:New(owner)
    return setmetatable({
        owner = owner,
        rows = {},
        offset = 0,
        taskId = nil,
        suggestionOffset = 0,
    }, { __index = self })
end

function UI:Initialize()
    self.geometry = self.owner.data:GetSettings().window

    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListWindow")
    window:SetDimensions(self.geometry.width, self.geometry.height)
    window:SetDimensionConstraints(
        MIN_WIDTH,
        MIN_HEIGHT,
        math.min(MAX_WIDTH, GuiRoot:GetWidth()),
        math.min(MAX_HEIGHT, GuiRoot:GetHeight())
    )
    window:SetResizeHandleSize(14)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetHandler("OnMouseWheel", function(_, delta) self:Scroll(-delta) end)
    window:SetHandler("OnResizeStop", function() self:SaveGeometry(true) end)
    window:SetHandler("OnMoveStop", function() self:SaveGeometry(true) end)
    window:SetHandler("OnUpdate", function()
        local width, height = window:GetDimensions()
        if width ~= self.lastWidth or height ~= self.lastHeight then
            self:Layout(width, height)
        end
    end)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.96)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.9)
    ShoppingListAccessibility:RegisterBackdrop(backdrop, { 0.035, 0.035, 0.045, 0.96 }, { 0.5, 0.42, 0.28, 0.9 })

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 16, 10)
    title:SetDimensions(170, 30)
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    title:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
            self:SaveGeometry(true)
        end
    end)

    self.summary = makeLabel(window, "ZoFontGameSmall")
    self.summary:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.summary:SetAnchor(TOPRIGHT, window, TOPRIGHT, -14, 12)
    self.summary:SetDimensions(145, 26)
    self.summary:SetMouseEnabled(true)
    self.summary:SetHandler("OnMouseEnter", function(control)
        control:SetColor(1, 0.9, 0.65, 1)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip, GetString(SI_SHOPPING_LIST_BUDGET_TOOLTIP))
    end)
    self.summary:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
        self:RefreshSummary()
    end)
    self.summary:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            self:OpenBudgetDialog()
        end
    end)

    self:CreateListControls()
    self:CreateListActions()

    self.divider = WINDOW_MANAGER:CreateControl(nil, window, CT_TEXTURE)
    self.divider:SetColor(0.5, 0.42, 0.28, 0.7)
    self.divider:SetAnchor(TOPLEFT, window, TOPLEFT, 12, 116)
    self.divider:SetHeight(1)

    for index = 1, MAX_ROWS do
        self.rows[index] = self:CreateRow(index)
    end

    self.page = makeLabel(window, "ZoFontGameSmall")
    self.page:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.page:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -14, -110)
    self.page:SetDimensions(160, 20)

    local filterContainer, filterCombo = makeCombo(window, "ItemFilter", 105)
    filterContainer:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 14, -84)
    local filterChoices = {
        { label = GetString(SI_SHOPPING_LIST_FILTER_ALL), value = "all" },
        { label = GetString(SI_SHOPPING_LIST_FILTER_NEEDED), value = "needed" },
        { label = GetString(SI_SHOPPING_LIST_FILTER_COMPLETED), value = "completed" },
        { label = GetString(SI_SHOPPING_LIST_FILTER_OVER_TARGET), value = "overTarget" },
        { label = GetString(SI_SHOPPING_LIST_FILTER_RESTRICTED), value = "restricted" },
    }
    for _, choice in ipairs(filterChoices) do
        local value = choice.value
        filterCombo:AddItem(filterCombo:CreateItemEntry(choice.label, function()
            self.owner.data:SetItemFilter(value)
            self.offset = 0
            self:Refresh()
            self.owner.gamepad:Refresh()
        end))
    end
    self.filterLabels = {}
    for _, choice in ipairs(filterChoices) do
        self.filterLabels[choice.value] = choice.label
    end
    self.filterCombo = filterCombo

    local sortContainer, sortCombo = makeCombo(window, "ItemSort", 120)
    sortContainer:SetAnchor(LEFT, filterContainer, RIGHT, 5, 0)
    local sortChoices = {
        { label = GetString(SI_SHOPPING_LIST_SORT_NAME_ASC), sort = "name", ascending = true },
        { label = GetString(SI_SHOPPING_LIST_SORT_NAME_DESC), sort = "name", ascending = false },
        { label = GetString(SI_SHOPPING_LIST_SORT_QUANTITY_ASC), sort = "quantity", ascending = true },
        { label = GetString(SI_SHOPPING_LIST_SORT_QUANTITY_DESC), sort = "quantity", ascending = false },
        { label = GetString(SI_SHOPPING_LIST_SORT_OWNED_ASC), sort = "owned", ascending = true },
        { label = GetString(SI_SHOPPING_LIST_SORT_OWNED_DESC), sort = "owned", ascending = false },
        { label = GetString(SI_SHOPPING_LIST_SORT_COMPLETION_ASC), sort = "completion", ascending = true },
        { label = GetString(SI_SHOPPING_LIST_SORT_COMPLETION_DESC), sort = "completion", ascending = false },
        { label = GetString(SI_SHOPPING_LIST_SORT_PRICE_ASC), sort = "price", ascending = true },
        { label = GetString(SI_SHOPPING_LIST_SORT_PRICE_DESC), sort = "price", ascending = false },
        { label = GetString(SI_SHOPPING_LIST_SORT_ADDED_ASC), sort = "added", ascending = true },
        { label = GetString(SI_SHOPPING_LIST_SORT_ADDED_DESC), sort = "added", ascending = false },
    }
    self.sortLabels = {}
    for _, choice in ipairs(sortChoices) do
        local sort = choice.sort
        local ascending = choice.ascending
        sortCombo:AddItem(sortCombo:CreateItemEntry(choice.label, function()
            self.owner.data:SetItemSort(sort, ascending)
            self.offset = 0
            self:Refresh()
            self.owner.gamepad:Refresh()
        end))
        self.sortLabels[sort .. ":" .. tostring(ascending)] = choice.label
    end
    self.sortContainer = sortContainer
    self.sortCombo = sortCombo

    local searchBackdrop, searchEdit = makeEdit(window, 80)
    searchBackdrop:SetAnchor(BOTTOMLEFT, sortContainer, BOTTOMRIGHT, 5, 0)
    searchBackdrop:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -14, -84)
    searchEdit:SetDefaultText(GetString(SI_SHOPPING_LIST_SEARCH_PLACEHOLDER))
    searchEdit:SetMaxInputChars(ShoppingListModel.MAX_NAME_LENGTH)
    searchEdit:SetHandler("OnTextChanged", function()
        if self.suppressItemSearch then
            return
        end
        local ok, message = self.owner.data:SetItemSearch(searchEdit:GetText())
        if not ok then
            self:SetStatus(message, true)
            return
        end
        self.offset = 0
        self:Refresh()
        self.owner.gamepad:Refresh()
    end)
    searchEdit:SetHandler("OnEscape", function()
        searchEdit:SetText("")
        searchEdit:LoseFocus()
    end)
    self.searchBackdrop = searchBackdrop
    self.searchEdit = searchEdit

    local nameBackdrop, nameEdit = makeEdit(window, 235)
    nameBackdrop:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 14, -48)
    nameEdit:SetDefaultText(GetString(SI_SHOPPING_LIST_ITEM_NAME_PLACEHOLDER))
    nameEdit:SetHandler("OnTextChanged", function()
        if not self.suppressAutocomplete then
            self:QueueAutocomplete()
        end
    end)
    nameEdit:SetHandler("OnEnter", function() self:AddFromInput() end)
    self.nameBackdrop = nameBackdrop
    self.nameEdit = nameEdit

    local quantityBackdrop, quantityEdit = makeEdit(window, 48)
    quantityBackdrop:SetAnchor(LEFT, nameBackdrop, RIGHT, 6, 0)
    quantityEdit:SetText("1")
    quantityEdit:SetMaxInputChars(#tostring(ShoppingListModel.MAX_QUANTITY))
    quantityEdit:SetTextType(TEXT_TYPE_NUMERIC)
    quantityEdit:SetHandler("OnEnter", function() self:AddFromInput() end)
    self.quantityEdit = quantityEdit

    local addButton = makeButton(window, "+", 34)
    addButton:SetAnchor(LEFT, quantityBackdrop, RIGHT, 5, 0)
    addButton:SetHandler("OnClicked", function() self:AddFromInput() end)

    self.status = makeLabel(window, "ZoFontGameSmall")
    self.status:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 16, -14)

    local closeButton = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 76)
    closeButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -22, -6)
    closeButton:SetHandler("OnClicked", function() self:Hide() end)

    local resizeHint = makeLabel(window, "ZoFontGameSmall")
    resizeHint:SetText("↘")
    resizeHint:SetColor(0.5, 0.42, 0.28, 0.8)
    resizeHint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    resizeHint:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -2, -1)
    resizeHint:SetDimensions(14, 14)

    self:CreateSuggestions(nameBackdrop)
    self:CreateListDialog()
    self:CreateBudgetDialog()
    self:InitializeDialogs()
    self:RegisterAutocompleteEvent()
    self:RegisterFocusEvent()
    self:RestorePosition()
    self:Layout(window:GetDimensions())
end

function UI:InitializeDialogs()
    ZO_Dialogs_RegisterCustomDialog(REMOVE_ITEM_DIALOG, {
        title = {
            text = SI_SHOPPING_LIST_REMOVE_ITEM_TITLE,
        },
        mainText = {
            text = function(dialog)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_REMOVE_ITEM_CONFIRM),
                    dialog.data.itemName
                )
            end,
        },
        buttons = {
            {
                text = SI_SHOPPING_LIST_BUTTON_REMOVE,
                callback = function(dialog)
                    self.owner:RemoveItem(dialog.data.itemId)
                    self:SetStatus(zo_strformat(
                        GetString(SI_SHOPPING_LIST_STATUS_REMOVED_ITEM),
                        dialog.data.itemName
                    ))
                end,
            },
            {
                text = SI_DIALOG_CANCEL,
            },
        },
        finishedCallback = function()
            self:RestoreOwnedMouse()
        end,
    })
    ZO_Dialogs_RegisterCustomDialog(RESET_PROGRESS_DIALOG, {
        title = {
            text = SI_SHOPPING_LIST_RESET_PROGRESS_TITLE,
        },
        mainText = {
            text = function(dialog)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_RESET_PROGRESS_CONFIRM),
                    dialog.data.listName
                )
            end,
        },
        buttons = {
            {
                text = SI_SHOPPING_LIST_BUTTON_RESET_PROGRESS,
                callback = function(dialog)
                    self:ResetListProgress(dialog.data.listId)
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
        finishedCallback = function()
            self:RestoreOwnedMouse()
        end,
    })
    ZO_Dialogs_RegisterCustomDialog(DUPLICATE_ITEM_DIALOG, {
        title = {
            text = SI_SHOPPING_LIST_DUPLICATE_ITEM_TITLE,
        },
        mainText = {
            text = function(dialog)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_DUPLICATE_ITEM_CONFIRM),
                    dialog.data.duplicate.name,
                    dialog.data.duplicate.desired,
                    dialog.data.source.quantity or dialog.data.source.desired or 1
                )
            end,
        },
        buttons = {
            {
                text = SI_SHOPPING_LIST_BUTTON_MERGE,
                callback = function(dialog)
                    self:CompleteDuplicateAdd(dialog.data, "merge")
                end,
            },
            {
                text = SI_SHOPPING_LIST_BUTTON_REPLACE,
                callback = function(dialog)
                    self:CompleteDuplicateAdd(dialog.data, "replace")
                end,
            },
            {
                text = SI_SHOPPING_LIST_BUTTON_KEEP_SEPARATE,
                callback = function(dialog)
                    self:CompleteDuplicateAdd(dialog.data, "keep")
                end,
            },
        },
        finishedCallback = function()
            self:RestoreOwnedMouse()
        end,
    })
end

function UI:CreateListControls()
    local container, combo = makeCombo(self.window, "ListSelector", 175)
    container:SetAnchor(TOPLEFT, self.window, TOPLEFT, 14, 45)
    self.listContainer = container
    self.listCombo = combo

    local add = makeButton(self.window, "+", 28)
    add:SetAnchor(LEFT, container, RIGHT, 4, 0)
    add:SetHandler("OnClicked", function() self:OpenListDialog("new") end)

    local rename = makeButton(self.window, GetString(SI_SHOPPING_LIST_GAMEPAD_MANAGE), 70)
    rename:SetAnchor(LEFT, add, RIGHT, 4, 0)
    rename:SetHandler("OnClicked", function() self:OpenListDialog("rename") end)

    local remove = makeButton(self.window, "−", 28)
    remove:SetAnchor(LEFT, rename, RIGHT, 4, 0)
    remove:SetHandler("OnClicked", function() self:OpenListDialog("delete") end)
    self.deleteListButton = remove
end

function UI:CreateListActions()
    local budget = makeButton(
        self.window,
        GetString(SI_SHOPPING_LIST_BUTTON_BUDGET),
        82
    )
    budget:SetAnchor(TOPLEFT, self.window, TOPLEFT, 14, 78)
    budget:SetHandler("OnClicked", function() self:OpenBudgetDialog() end)

    local share = makeButton(
        self.window,
        GetString(SI_SHOPPING_LIST_BUTTON_SHARE),
        110
    )
    share:SetAnchor(LEFT, budget, RIGHT, 8, 0)
    share:SetHandler("OnClicked", function()
        if self.owner.share then
            self.owner.share:Open()
        end
    end)

    local donate = makeButton(
        self.window,
        GetString(SI_SHOPPING_LIST_BUTTON_DONATE),
        72
    )
    donate:SetAnchor(LEFT, share, RIGHT, 8, 0)
    donate:SetHandler("OnClicked", function() self:OpenDonationMail() end)
    donate:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip, GetString(SI_SHOPPING_LIST_DONATE_TOOLTIP))
    end)
    donate:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    local help = makeButton(self.window, "?", 28)
    help:SetAnchor(LEFT, donate, RIGHT, 8, 0)
    help:SetHandler("OnClicked", function()
        if self.owner.help then
            self.owner.help:Open()
        end
    end)
    help:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip, GetString(SI_SHOPPING_LIST_HELP_TOOLTIP))
    end)
    help:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

function UI:OpenDonationMail()
    local worldName = GetWorldName()
    if worldName ~= NORTH_AMERICAN_MEGASERVER then
        self:SetStatus(zo_strformat(
            GetString(SI_SHOPPING_LIST_DONATE_WRONG_SERVER),
            worldName or GetString(SI_SHOPPING_LIST_UNKNOWN_SERVER)
        ), true)
        return
    end

    local composer = MAIL_SEND
    if IsInGamepadPreferredMode() and MAIL_GAMEPAD then
        composer = MAIL_GAMEPAD.send
    end
    if not composer then
        self:SetStatus(GetString(SI_SHOPPING_LIST_DONATE_MAIL_UNAVAILABLE), true)
        return
    end

    self:Hide()
    composer:ComposeMailTo(DONATION_RECIPIENT)
end

function UI:CreateListDialog()
    local dialog = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListNameWindow")
    dialog:SetDimensions(420, 510)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetClampedToScreen(true)
    dialog:SetMouseEnabled(true)
    dialog:SetHidden(true)
    dialog:SetDrawTier(DT_HIGH)
    self.listDialog = dialog

    local backdrop = ShoppingListControls:CreateBackdrop(dialog)
    backdrop:SetAnchorFill(dialog)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    self.listDialogTitle = makeLabel(dialog, "ZoFontWinH2")
    self.listDialogTitle:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 10)
    self.listDialogTitle:SetDimensions(384, 30)

    self.listDialogMessage = makeLabel(dialog, "ZoFontGame")
    self.listDialogMessage:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 48)
    self.listDialogMessage:SetDimensions(384, 42)
    self.listDialogMessage:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    local nameBackdrop, nameEdit = makeEdit(dialog, 384)
    nameBackdrop:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 52)
    nameEdit:SetMaxInputChars(ShoppingListModel.MAX_NAME_LENGTH)
    nameEdit:SetHandler("OnEnter", function() self:CompleteListDialog() end)
    nameEdit:SetHandler("OnEscape", function() self:CloseListDialog() end)
    self.listDialogNameBackdrop = nameBackdrop
    self.listDialogName = nameEdit

    self.listDialogOrderLabel = makeLabel(dialog, "ZoFontGame")
    self.listDialogOrderLabel:SetText(GetString(SI_SHOPPING_LIST_ORDER))
    self.listDialogOrderLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 91)
    self.listDialogOrderLabel:SetDimensions(60, 28)

    local moveUp = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_MOVE_UP), 90)
    moveUp:SetAnchor(TOPLEFT, dialog, TOPLEFT, 82, 91)
    moveUp:SetHandler("OnClicked", function() self:MoveCurrentList(-1) end)
    self.listDialogMoveUp = moveUp

    local moveDown = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_MOVE_DOWN), 100)
    moveDown:SetAnchor(LEFT, moveUp, RIGHT, 8, 0)
    moveDown:SetHandler("OnClicked", function() self:MoveCurrentList(1) end)
    self.listDialogMoveDown = moveDown

    local archive = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_ARCHIVE), 82)
    archive:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 128)
    archive:SetHandler("OnClicked", function() self:ArchiveCurrentList() end)
    self.listDialogArchive = archive

    local archived = makeButton(dialog, zo_strformat(
        GetString(SI_SHOPPING_LIST_ARCHIVED_COUNT),
        0
    ), 120)
    archived:SetAnchor(LEFT, archive, RIGHT, 8, 0)
    archived:SetHandler("OnClicked", function()
        if self.owner.archive then
            self.owner.archive:Open()
        end
    end)
    self.listDialogArchived = archived

    local share = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_SHARE), 105)
    share:SetAnchor(LEFT, archived, RIGHT, 8, 0)
    share:SetHandler("OnClicked", function()
        if self.owner.share then
            self.owner.share:Open()
        end
    end)
    self.listDialogShare = share

    local trip = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_TRIP), 72)
    trip:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 165)
    trip:SetHandler("OnClicked", function()
        self.owner.listTools:OpenTripWindow()
    end)
    self.listDialogTrip = trip

    local bulk = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_BULK_ADD), 88)
    bulk:SetAnchor(LEFT, trip, RIGHT, 8, 0)
    bulk:SetHandler("OnClicked", function()
        self.owner.listTools:OpenBulkWindow()
    end)
    self.listDialogBulk = bulk

    local undo = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_UNDO), 70)
    undo:SetAnchor(LEFT, bulk, RIGHT, 8, 0)
    undo:SetHandler("OnClicked", function() self:UndoLastDeletion() end)
    self.listDialogUndo = undo

    local clear = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_CLEAR_COMPLETED), 120)
    clear:SetAnchor(LEFT, undo, RIGHT, 8, 0)
    clear:SetHandler("OnClicked", function() self:ClearCompletedItems() end)
    self.listDialogClearCompleted = clear

    self.listDialogNoteLabel = makeLabel(dialog, "ZoFontGame")
    self.listDialogNoteLabel:SetText(GetString(SI_SHOPPING_LIST_LIST_NOTE))
    self.listDialogNoteLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 202)
    self.listDialogNoteLabel:SetDimensions(384, 26)

    local noteBackdrop, noteEdit = makeNoteEdit(dialog, 384, 100)
    noteBackdrop:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 230)
    noteEdit:SetHandler("OnEscape", function() self:CloseListDialog() end)
    self.listDialogNoteBackdrop = noteBackdrop
    self.listDialogNote = noteEdit

    self.listDialogCategoryLabel = makeLabel(dialog, "ZoFontGame")
    self.listDialogCategoryLabel:SetText(GetString(SI_SHOPPING_LIST_LIST_CATEGORY))
    self.listDialogCategoryLabel:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 334)
    self.listDialogCategoryLabel:SetDimensions(384, 26)

    local categoryBackdrop, categoryEdit = makeEdit(dialog, 384)
    categoryBackdrop:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 362)
    categoryEdit:SetMaxInputChars(ShoppingListModel.MAX_CATEGORY_LENGTH)
    categoryEdit:SetDefaultText(GetString(SI_SHOPPING_LIST_CATEGORY_PLACEHOLDER))
    categoryEdit:SetHandler("OnEscape", function() self:CloseListDialog() end)
    self.listDialogCategoryBackdrop = categoryBackdrop
    self.listDialogCategory = categoryEdit

    local recurring = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_RECURRING_OFF),
        120
    )
    recurring:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 400)
    recurring:SetHandler("OnClicked", function()
        self:ToggleCurrentListRecurring()
    end)
    self.listDialogRecurring = recurring

    local favorite = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_FAVORITE_OFF),
        120
    )
    favorite:SetAnchor(LEFT, recurring, RIGHT, 8, 0)
    favorite:SetHandler("OnClicked", function()
        self:ToggleCurrentListFavorite()
    end)
    self.listDialogFavorite = favorite

    local pinned = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_PINNED_OFF),
        120
    )
    pinned:SetAnchor(LEFT, favorite, RIGHT, 8, 0)
    pinned:SetHandler("OnClicked", function()
        self:ToggleCurrentListPinned()
    end)
    self.listDialogPinned = pinned

    local resetProgress = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_BUTTON_RESET_PROGRESS),
        180
    )
    resetProgress:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 437)
    resetProgress:SetHandler("OnClicked", function()
        self:ConfirmResetListProgress()
    end)
    self.listDialogResetProgress = resetProgress

    local session = makeButton(
        dialog,
        GetString(SI_SHOPPING_LIST_BUTTON_SESSION),
        180
    )
    session:SetAnchor(LEFT, resetProgress, RIGHT, 8, 0)
    session:SetHandler("OnClicked", function()
        self:CloseListDialog()
        if self.owner.session then
            self.owner.session:Open()
        end
    end)
    self.listDialogSession = session

    local duplicate = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_DUPLICATE), 90)
    duplicate:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 18, -16)
    duplicate:SetHidden(true)
    duplicate:SetHandler("OnClicked", function() self:OpenListDialog("duplicate") end)
    self.listDialogDuplicate = duplicate

    local confirm = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_SAVE), 90)
    confirm:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 118, -16)
    confirm:SetHandler("OnClicked", function() self:CompleteListDialog() end)
    self.listDialogConfirm = confirm

    local cancel = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_CANCEL), 90)
    cancel:SetAnchor(LEFT, confirm, RIGHT, 12, 0)
    cancel:SetHandler("OnClicked", function() self:CloseListDialog() end)
end

function UI:CloseListDialog()
    self.listDialogName:LoseFocus()
    self.listDialogNote:LoseFocus()
    self.listDialogCategory:LoseFocus()
    self.listDialog:SetHidden(true)
end

function UI:UpdateListMoveButtons()
    local list, index = self.owner.data:FindList(self.owner.data:GetCurrentList().id)
    local count = #self.owner.data:GetLists()
    self.listDialogMoveUp:SetEnabled(list ~= nil and index > 1)
    self.listDialogMoveDown:SetEnabled(list ~= nil and index < count)
end

function UI:UpdateListArchiveButtons()
    local list = self.owner.data:GetCurrentList()
    self.listDialogArchive:SetEnabled(true)
    self.listDialogUndo:SetEnabled(self.owner.data:CanUndoDeletion())
    local completed = 0
    for _, item in ipairs(self.owner.data:GetItems()) do
        if self.owner.data:IsItemComplete(item) then
            completed = completed + 1
        end
    end
    self.listDialogClearCompleted:SetEnabled(completed > 0)
    self.listDialogRecurring:SetText(GetString(list.recurring
        and SI_SHOPPING_LIST_RECURRING_ON
        or SI_SHOPPING_LIST_RECURRING_OFF))
    self.listDialogFavorite:SetText(GetString(list.favorite
        and SI_SHOPPING_LIST_FAVORITE_ON
        or SI_SHOPPING_LIST_FAVORITE_OFF))
    self.listDialogPinned:SetText(GetString(list.pinned
        and SI_SHOPPING_LIST_PINNED_ON
        or SI_SHOPPING_LIST_PINNED_OFF))
    self.listDialogResetProgress:SetEnabled(
        self.owner.data:ListHasPurchaseProgress(list)
    )
    self.listDialogArchived:SetText(zo_strformat(
        GetString(SI_SHOPPING_LIST_ARCHIVED_COUNT),
        #self.owner.data:GetArchivedLists()
    ))
end

function UI:ToggleCurrentListFavorite()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListFavorite(list.id, not list.favorite)
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self.listSignature = nil
    self:UpdateListArchiveButtons()
    self:Refresh()
    self.owner.gamepad:Refresh()
end

function UI:ToggleCurrentListPinned()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListPinned(list.id, not list.pinned)
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self.listSignature = nil
    self:UpdateListArchiveButtons()
    self:Refresh()
    self.owner.gamepad:Refresh()
end

function UI:ToggleCurrentListRecurring()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListRecurring(
        list.id,
        list.recurring ~= true
    )
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self.listSignature = nil
    self:UpdateListArchiveButtons()
    self:Refresh()
    self.owner.gamepad:Refresh()
    self:SetStatus(GetString(list.recurring
        and SI_SHOPPING_LIST_STATUS_RECURRING_ON
        or SI_SHOPPING_LIST_STATUS_RECURRING_OFF))
end

function UI:ConfirmResetListProgress()
    local list = self.owner.data:GetCurrentList()
    if not self.owner.data:ListHasPurchaseProgress(list) then
        self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_NO_PROGRESS_TO_RESET), true)
        return
    end
    ZO_Dialogs_ShowDialog(RESET_PROGRESS_DIALOG, {
        listId = list.id,
        listName = list.name,
    })
end

function UI:ResetListProgress(listId)
    local ok, countOrMessage, list = self.owner.data:ResetListProgress(listId)
    if not ok then
        self:SetStatus(countOrMessage, true)
        return
    end
    self:CloseListDialog()
    self.offset = 0
    self:Refresh()
    self.owner.gamepad:Refresh()
    self.owner:RefreshInventory()
    self:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_PROGRESS_RESET),
        list.name,
        countOrMessage
    ))
end

function UI:UndoLastDeletion()
    local ok, message = self.owner:UndoDeletion()
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self:CloseListDialog()
    self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_UNDO_COMPLETE))
end

function UI:ClearCompletedItems()
    local count = self.owner.data:ClearCompleted()
    if count == 0 then
        self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_NO_COMPLETED_ITEMS), true)
        return
    end
    self:CloseListDialog()
    self:Refresh()
    self.owner.gamepad:Refresh()
    self:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_CLEARED_COMPLETED),
        count
    ))
end

function UI:MoveCurrentList(direction)
    local list = self.owner.data:GetCurrentList()
    if not self.owner.data:MoveList(list.id, direction) then
        return
    end
    self.listSignature = nil
    self:Refresh()
    self:UpdateListMoveButtons()
    self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_LIST_ORDER_UPDATED))
end

function UI:ArchiveCurrentList()
    local current = self.owner.data:GetCurrentList()
    local ok, listOrMessage = self.owner.data:ArchiveList(current.id)
    if not ok then
        self:SetStatus(listOrMessage, true)
        return
    end

    self.offset = 0
    self.listSignature = nil
    if self.owner.editor then
        self.owner.editor:Hide()
    end
    if self.owner.history then
        self.owner.history:Hide()
    end
    if self.owner.session then
        self.owner.session:Hide()
    end
    self:CloseBudgetDialog()
    self:CloseListDialog()
    self:Refresh()
    self.owner:RefreshInventory()
    if self.owner.archive then
        self.owner.archive:Refresh()
    end
    self:SetStatus(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_ARCHIVED),
        listOrMessage.name
    ))
end

function UI:CreateBudgetDialog()
    local dialog = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListBudgetWindow")
    dialog:SetDimensions(390, 225)
    dialog:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    dialog:SetClampedToScreen(true)
    dialog:SetMouseEnabled(true)
    dialog:SetHidden(true)
    dialog:SetDrawTier(DT_HIGH)
    self.budgetDialog = dialog

    local backdrop = ShoppingListControls:CreateBackdrop(dialog)
    backdrop:SetAnchorFill(dialog)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.98)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop)

    local title = makeLabel(dialog, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_BUDGET_TITLE))
    title:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 10)
    title:SetDimensions(354, 30)

    self.budgetListName = makeLabel(dialog, "ZoFontGame")
    self.budgetListName:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 45)
    self.budgetListName:SetDimensions(354, 26)
    self.budgetListName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

    self.budgetSpent = makeLabel(dialog, "ZoFontGameSmall")
    self.budgetSpent:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 71)
    self.budgetSpent:SetDimensions(354, 40)
    self.budgetSpent:SetVerticalAlignment(TEXT_ALIGN_TOP)

    local budgetBackdrop, budgetEdit = makeEdit(dialog, 220)
    budgetBackdrop:SetAnchor(TOPLEFT, dialog, TOPLEFT, 18, 116)
    budgetEdit:SetTextType(TEXT_TYPE_NUMERIC)
    budgetEdit:SetMaxInputChars(#tostring(ShoppingListModel.MAX_PRICE))
    budgetEdit:SetDefaultText(GetString(SI_SHOPPING_LIST_NO_BUDGET))
    budgetEdit:SetHandler("OnEnter", function() self:SaveBudget() end)
    budgetEdit:SetHandler("OnEscape", function() self:CloseBudgetDialog() end)
    self.budgetEdit = budgetEdit

    local gold = makeLabel(dialog, "ZoFontGame")
    gold:SetText(GetString(SI_SHOPPING_LIST_GOLD_LONG))
    gold:SetAnchor(LEFT, budgetBackdrop, RIGHT, 8, 0)
    gold:SetDimensions(80, 30)

    local save = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_SAVE), 80)
    save:SetAnchor(BOTTOMLEFT, dialog, BOTTOMLEFT, 18, -16)
    save:SetHandler("OnClicked", function() self:SaveBudget() end)

    local clear = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_CLEAR), 80)
    clear:SetAnchor(LEFT, save, RIGHT, 8, 0)
    clear:SetHandler("OnClicked", function() self:ClearBudget() end)

    local cancel = makeButton(dialog, GetString(SI_SHOPPING_LIST_BUTTON_CANCEL), 80)
    cancel:SetAnchor(BOTTOMRIGHT, dialog, BOTTOMRIGHT, -18, -16)
    cancel:SetHandler("OnClicked", function() self:CloseBudgetDialog() end)
end

function UI:OpenBudgetDialog()
    local list = self.owner.data:GetCurrentList()
    self.budgetListId = list.id
    self.budgetListName:SetText(list.name)
    self.budgetSpent:SetText(zo_strformat(
        GetString(SI_SHOPPING_LIST_RECORDED_SPENDING),
        formatCompactGold(list.transactionSpent or list.totalSpent),
        formatCompactGold(list.totalSpent)
    ))
    self.budgetEdit:SetText(list.budget and tostring(list.budget) or "")
    self.budgetDialog:SetHidden(false)
    self.budgetEdit:TakeFocus()
end

function UI:CloseBudgetDialog()
    self.budgetEdit:LoseFocus()
    self.budgetDialog:SetHidden(true)
end

function UI:SaveBudget()
    local ok, message = self.owner.data:UpdateListBudget(
        self.budgetListId,
        self.budgetEdit:GetText()
    )
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self:CloseBudgetDialog()
    self:Refresh()
    self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_BUDGET_UPDATED))
end

function UI:ClearBudget()
    local ok, message = self.owner.data:UpdateListBudget(self.budgetListId, nil)
    if not ok then
        self:SetStatus(message, true)
        return
    end
    self:CloseBudgetDialog()
    self:Refresh()
    self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_BUDGET_CLEARED))
end

function UI:RefreshListSelector()
    local current = self.owner.data:GetCurrentList()
    local lists = self.owner.data:GetDisplayLists()
    local signature = {}
    local tripEnabled = self.owner.data:IsMultiListTripEnabled()
    for _, list in ipairs(lists) do
        signature[#signature + 1] = table.concat({
            tostring(list.id),
            list.name,
            list.note or "",
            tostring(list.tripActive),
            tostring(list.recurring),
            tostring(list.favorite),
            tostring(list.pinned),
            list.category or "",
            tostring(tripEnabled),
        }, ":")
    end
    signature = table.concat(signature, "|")

    if signature ~= self.listSignature then
        self.listSignature = signature
        self.listCombo:ClearItems()
        for _, list in ipairs(lists) do
            local listId = list.id
            local displayName = list.note and list.note ~= "" and zo_strformat(
                GetString(SI_SHOPPING_LIST_NOTE_MARKER),
                list.name
            ) or list.name
            if list.category and list.category ~= "" then
                displayName = zo_strformat(
                    GetString(SI_SHOPPING_LIST_CATEGORY_MARKER),
                    list.category,
                    displayName
                )
            end
            if list.favorite then
                displayName = zo_strformat(
                    GetString(SI_SHOPPING_LIST_FAVORITE_MARKER),
                    displayName
                )
            end
            if list.pinned then
                displayName = zo_strformat(
                    GetString(SI_SHOPPING_LIST_PINNED_MARKER),
                    displayName
                )
            end
            if list.recurring then
                displayName = zo_strformat(
                    GetString(SI_SHOPPING_LIST_RECURRING_MARKER),
                    displayName
                )
            end
            local label = tripEnabled and zo_strformat(
                GetString(list.tripActive
                    and SI_SHOPPING_LIST_TRIP_LIST_ACTIVE
                    or SI_SHOPPING_LIST_TRIP_LIST_INACTIVE),
                displayName
            ) or displayName
            self.listCombo:AddItem(self.listCombo:CreateItemEntry(label, function()
                self:SelectList(listId)
            end))
        end
    end
    local currentName = current.note and current.note ~= "" and zo_strformat(
        GetString(SI_SHOPPING_LIST_NOTE_MARKER),
        current.name
    ) or current.name
    if current.category and current.category ~= "" then
        currentName = zo_strformat(
            GetString(SI_SHOPPING_LIST_CATEGORY_MARKER),
            current.category,
            currentName
        )
    end
    if current.favorite then
        currentName = zo_strformat(
            GetString(SI_SHOPPING_LIST_FAVORITE_MARKER),
            currentName
        )
    end
    if current.pinned then
        currentName = zo_strformat(
            GetString(SI_SHOPPING_LIST_PINNED_MARKER),
            currentName
        )
    end
    if current.recurring then
        currentName = zo_strformat(
            GetString(SI_SHOPPING_LIST_RECURRING_MARKER),
            currentName
        )
    end
    local selectedLabel = tripEnabled and zo_strformat(
        GetString(current.tripActive
            and SI_SHOPPING_LIST_TRIP_LIST_ACTIVE
            or SI_SHOPPING_LIST_TRIP_LIST_INACTIVE),
        currentName
    ) or currentName
    self.listCombo:SetSelectedItem(selectedLabel)
    self.deleteListButton:SetEnabled(#lists > 1)
end

function UI:SelectList(id)
    if not self.owner.data:SelectList(id) then
        return
    end
    self.offset = 0
    if self.owner.editor then
        self.owner.editor:Hide()
    end
    if self.owner.history then
        self.owner.history:Hide()
    end
    self:CloseBudgetDialog()
    self:Refresh()
end

function UI:OpenListDialog(mode)
    local current = self.owner.data:GetCurrentList()
    self.listDialogMode = mode
    self.listDialogMessage:SetHidden(mode ~= "delete")
    self.listDialogNameBackdrop:SetHidden(mode == "delete")
    self.listDialogDuplicate:SetHidden(mode ~= "rename")
    self.listDialogOrderLabel:SetHidden(mode ~= "rename")
    self.listDialogMoveUp:SetHidden(mode ~= "rename")
    self.listDialogMoveDown:SetHidden(mode ~= "rename")
    self.listDialogArchive:SetHidden(mode ~= "rename")
    self.listDialogArchived:SetHidden(mode ~= "rename")
    self.listDialogShare:SetHidden(mode ~= "rename")
    self.listDialogTrip:SetHidden(mode ~= "rename")
    self.listDialogBulk:SetHidden(mode ~= "rename")
    self.listDialogUndo:SetHidden(mode ~= "rename")
    self.listDialogClearCompleted:SetHidden(mode ~= "rename")
    self.listDialogRecurring:SetHidden(mode ~= "rename")
    self.listDialogResetProgress:SetHidden(mode ~= "rename")
    self.listDialogSession:SetHidden(mode ~= "rename")
    self.listDialogFavorite:SetHidden(mode ~= "rename")
    self.listDialogPinned:SetHidden(mode ~= "rename")
    self.listDialogNoteLabel:SetHidden(mode == "delete")
    self.listDialogNoteBackdrop:SetHidden(mode == "delete")
    self.listDialogCategoryLabel:SetHidden(mode == "delete")
    self.listDialogCategoryBackdrop:SetHidden(mode == "delete")
    self.listDialog:SetHeight(mode == "delete" and 290
        or (mode == "rename" and 510 or 450))

    if mode == "new" then
        self.listDialogTitle:SetText(GetString(SI_SHOPPING_LIST_NEW_LIST_TITLE))
        self.listDialogName:SetText("")
        self.listDialogNote:SetText("")
        self.listDialogCategory:SetText("")
        self.listDialogConfirm:SetText(GetString(SI_SHOPPING_LIST_BUTTON_CREATE))
    elseif mode == "rename" then
        self.listDialogTitle:SetText(GetString(SI_SHOPPING_LIST_GAMEPAD_MANAGE_TITLE))
        self.listDialogName:SetText(current.name)
        self.listDialogNote:SetText(current.note or "")
        self.listDialogCategory:SetText(current.category or "")
        self.listDialogConfirm:SetText(GetString(SI_SHOPPING_LIST_BUTTON_SAVE))
    elseif mode == "duplicate" then
        local baseName = zo_strformat(
            GetString(SI_SHOPPING_LIST_COPIED_LIST_NAME),
            current.name
        )
        local name = baseName
        local suffix = 2
        while self.owner.data:ListNameExists(name) do
            name = baseName .. " " .. tostring(suffix)
            suffix = suffix + 1
        end
        self.listDialogTitle:SetText(GetString(SI_SHOPPING_LIST_DUPLICATE_LIST_TITLE))
        self.listDialogName:SetText(name)
        self.listDialogNote:SetText(current.note or "")
        self.listDialogCategory:SetText(current.category or "")
        self.listDialogConfirm:SetText(GetString(SI_SHOPPING_LIST_BUTTON_DUPLICATE))
    else
        if #self.owner.data:GetLists() == 1 then
            return
        end
        self.listDialogTitle:SetText(GetString(SI_SHOPPING_LIST_DELETE_LIST_TITLE))
        self.listDialogMessage:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_DELETE_LIST_CONFIRM),
            current.name
        ))
        self.listDialogConfirm:SetText(GetString(SI_SHOPPING_LIST_BUTTON_DELETE))
    end

    self.listDialog:SetHidden(false)
    self:UpdateListMoveButtons()
    self:UpdateListArchiveButtons()
    if mode ~= "delete" then
        self.listDialogName:TakeFocus()
    end
end

function UI:CompleteListDialog()
    local mode = self.listDialogMode
    local current = self.owner.data:GetCurrentList()
    local status
    if mode == "new" then
        local list, message = self.owner.data:AddList(
            self.listDialogName:GetText(),
            self.listDialogNote:GetText(),
            self.listDialogCategory:GetText()
        )
        if not list then
            self:SetStatus(message, true)
            return
        end
    elseif mode == "rename" then
        local ok, message = self.owner.data:RenameList(current.id, self.listDialogName:GetText())
        if not ok then
            self:SetStatus(message, true)
            return
        end
        self.owner.data:UpdateListNote(current.id, self.listDialogNote:GetText())
        local categoryOk, categoryMessage = self.owner.data:UpdateListCategory(
            current.id,
            self.listDialogCategory:GetText()
        )
        if not categoryOk then
            self:SetStatus(categoryMessage, true)
            return
        end
    elseif mode == "duplicate" then
        local list, message = self.owner.data:DuplicateList(
            current.id,
            self.listDialogName:GetText(),
            self.listDialogNote:GetText(),
            self.listDialogCategory:GetText()
        )
        if not list then
            self:SetStatus(message, true)
            return
        end
    elseif mode == "delete" then
        local deletedName = current.name
        local ok, message = self.owner.data:DeleteList(current.id)
        if not ok then
            self:SetStatus(message, true)
            return
        end
        status = zo_strformat(
            GetString(SI_SHOPPING_LIST_STATUS_LIST_DELETED),
            deletedName
        )
    else
        return
    end

    self.offset = 0
    if self.owner.editor then
        self.owner.editor:Hide()
    end
    if self.owner.history then
        self.owner.history:Hide()
    end
    self:CloseBudgetDialog()
    self:CloseListDialog()
    self:Refresh()
    self.owner:RefreshInventory()
    self:SetStatus(status or GetString(SI_SHOPPING_LIST_STATUS_LISTS_UPDATED))
end

function UI:CreateRow(index)
    local row = WINDOW_MANAGER:CreateControl(nil, self.window, CT_CONTROL)
    row:SetAnchor(TOPLEFT, self.window, TOPLEFT, 12, ROW_TOP + ((index - 1) * ROW_HEIGHT))
    row:SetHeight(32)

    row.toggle = makeButton(row, "[ ]", 32)
    row.toggle:SetAnchor(LEFT, row, LEFT, 0, 0)

    row.remove = makeButton(row, "×", 24)
    row.remove:SetAnchor(RIGHT, row, RIGHT, 0, 0)

    row.find = makeButton(row, GetString(SI_SHOPPING_LIST_BUTTON_FIND), 43)
    row.find:SetAnchor(RIGHT, row.remove, LEFT, -4, 0)

    row.edit = makeButton(row, GetString(SI_SHOPPING_LIST_BUTTON_EDIT), 42)
    row.edit:SetAnchor(RIGHT, row.find, LEFT, -4, 0)

    row.progress = makeLabel(row, "ZoFontGameSmall")
    row.progress:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    row.progress:SetAnchor(BOTTOMLEFT, row.toggle, BOTTOMRIGHT, 5, 0)
    row.progress:SetAnchor(BOTTOMRIGHT, row.edit, BOTTOMLEFT, -3, 0)
    row.progress:SetHeight(14)
    row.progress:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row.progress:SetMouseEnabled(true)
    row.progress:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip, control:GetText())
    end)
    row.progress:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    row.name = makeLabel(row, "ZoFontGame")
    row.name:SetAnchor(TOPLEFT, row.toggle, TOPRIGHT, 5, 0)
    row.name:SetAnchor(TOPRIGHT, row.edit, TOPLEFT, -3, 0)
    row.name:SetHeight(18)
    row.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    row.name:SetMouseEnabled(true)

    return row
end

function UI:CreateSuggestions(relativeTo)
    local panel = WINDOW_MANAGER:CreateControl(nil, self.window, CT_CONTROL)
    panel:SetDimensions(235, (SUGGESTION_ROWS * 22) + 25)
    panel:SetAnchor(BOTTOMLEFT, relativeTo, TOPLEFT, 0, -2)
    panel:SetHidden(true)
    panel:SetDrawTier(DT_HIGH)
    panel:SetMouseEnabled(true)
    panel:SetHandler("OnMouseWheel", function(_, delta) self:ScrollSuggestions(-delta) end)
    self.suggestionPanel = panel

    local backdrop = ShoppingListControls:CreateBackdrop(panel)
    backdrop:SetAnchorFill(panel)

    self.suggestions = {}
    for index = 1, SUGGESTION_ROWS do
        local button = makeButton(panel, "", 225)
        button:SetHeight(22)
        button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        button:SetAnchor(TOPLEFT, panel, TOPLEFT, 5, 5 + ((index - 1) * 22))
        button:SetHandler("OnClicked", function() self:ChooseSuggestion(index) end)
        button:SetHandler("OnMouseWheel", function(_, delta) self:ScrollSuggestions(-delta) end)
        self.suggestions[index] = button
    end

    self.suggestionPage = makeLabel(panel, "ZoFontGameSmall")
    self.suggestionPage:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.suggestionPage:SetAnchor(BOTTOM, panel, BOTTOM, 0, -2)
    self.suggestionPage:SetDimensions(160, 18)
end

function UI:RegisterAutocompleteEvent()
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_Autocomplete",
        EVENT_MATCH_TRADING_HOUSE_ITEM_NAMES_COMPLETE,
        function(_, taskId) self:OnAutocomplete(taskId) end
    )
end

function UI:QueueAutocomplete()
    self.selectedNameHash = nil
    self.selectedItemLink = nil
    self.selectedSetId = nil
    local text = zo_strtrim(self.nameEdit:GetText())
    local minimum = GetMinLettersInTradingHouseItemNameForCurrentLanguage()
    if #text < minimum then
        self.suggestionData = nil
        self.suggestionPanel:SetHidden(true)
        return
    end

    self.autocompleteSerial = (self.autocompleteSerial or 0) + 1
    local serial = self.autocompleteSerial
    zo_callLater(function()
        if serial ~= self.autocompleteSerial then
            return
        end
        if self.taskId then
            CancelMatchTradingHouseItemNames(self.taskId)
        end
        self.taskId = MatchTradingHouseItemNames(text)
    end, 200)
end

function UI:OnAutocomplete(taskId)
    if taskId ~= self.taskId then
        return
    end

    self.taskId = nil
    self.suggestionData = {}
    self.suggestionOffset = 0
    local seen = {}
    if self.owner.setCatalog then
        for _, suggestion in ipairs(self.owner.setCatalog:Search(self.nameEdit:GetText())) do
            local key = ShoppingListData.NormalizeName(suggestion.name)
            if not seen[key] then
                self.suggestionData[#self.suggestionData + 1] = suggestion
                seen[key] = #self.suggestionData
            end
        end
    end
    local count = GetNumMatchTradingHouseItemNamesResults(taskId) or 0
    for index = 1, count do
        local name, nameHash = GetMatchTradingHouseItemNamesResult(taskId, index)
        local key = ShoppingListData.NormalizeName(name)
        if not seen[key] then
            self.suggestionData[#self.suggestionData + 1] = {
                name = name,
                nameHash = nameHash,
            }
            seen[key] = #self.suggestionData
        else
            self.suggestionData[seen[key]].nameHash = nameHash
        end
    end
    self:RenderSuggestions()
end

function UI:RenderSuggestions()
    local data = self.suggestionData or {}
    local maxOffset = math.max(0, #data - SUGGESTION_ROWS)
    self.suggestionOffset = zo_clamp(self.suggestionOffset or 0, 0, maxOffset)

    for index, button in ipairs(self.suggestions) do
        local suggestion = data[self.suggestionOffset + index]
        button:SetHidden(suggestion == nil)
        if suggestion then
            button:SetText(suggestion.name)
        end
    end

    if #data > SUGGESTION_ROWS then
        self.suggestionPage:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PAGE_WITH_HINT),
            self.suggestionOffset + 1,
            math.min(self.suggestionOffset + SUGGESTION_ROWS, #data),
            #data,
            GetString(SI_SHOPPING_LIST_HINT_SCROLL)
        ))
    else
        self.suggestionPage:SetText("")
    end
    self.suggestionPanel:SetHidden(#data == 0)
end

function UI:ScrollSuggestions(delta)
    if not self.suggestionData or #self.suggestionData <= SUGGESTION_ROWS then
        return
    end
    self.suggestionOffset = self.suggestionOffset + delta
    self:RenderSuggestions()
end

function UI:ChooseSuggestion(index)
    local dataIndex = self.suggestionOffset + index
    local suggestion = self.suggestionData and self.suggestionData[dataIndex]
    if not suggestion then
        return
    end
    self.autocompleteSerial = (self.autocompleteSerial or 0) + 1
    self.suppressAutocomplete = true
    self.nameEdit:SetText(suggestion.name)
    self.suppressAutocomplete = false
    self.selectedNameHash = suggestion.nameHash
    self.selectedItemLink = suggestion.itemLink
    self.selectedSetId = suggestion.setId
    self.suggestionPanel:SetHidden(true)
end

function UI:ClearAddInput()
    self.suppressAutocomplete = true
    self.nameEdit:SetText("")
    self.suppressAutocomplete = false
    self.quantityEdit:SetText("1")
    self.selectedNameHash = nil
    self.selectedItemLink = nil
    self.selectedSetId = nil
    self.suggestionData = nil
    self.suggestionPanel:SetHidden(true)
end

function UI:SetAddedItemStatus(item, source, result)
    local stringId = SI_SHOPPING_LIST_STATUS_ADDED_ITEM
    if result == "merged" then
        stringId = SI_SHOPPING_LIST_STATUS_DUPLICATE_MERGED
    elseif result == "replaced" then
        stringId = SI_SHOPPING_LIST_STATUS_DUPLICATE_REPLACED
    elseif result == "kept" then
        stringId = SI_SHOPPING_LIST_STATUS_DUPLICATE_KEPT
    end
    self:SetStatus(zo_strformat(
        GetString(stringId),
        item.name,
        item.desired,
        source.quantity or source.desired or 1
    ))
end

function UI:CompleteDuplicateAdd(data, policy)
    local item, message, result = self.owner:AddItemSource(data.source, policy)
    if not item then
        self:SetStatus(message, true)
        return
    end
    self:SetAddedItemStatus(item, data.source, result)
    if data.callback then
        data.callback(item, result)
    end
end

function UI:AddSourceWithDuplicatePrompt(source, callback)
    local item, message, result = self.owner:AddItemSource(source, "prompt")
    if item then
        self:SetAddedItemStatus(item, source, result)
        if callback then
            callback(item, result)
        end
        return item
    end
    if result then
        ZO_Dialogs_ShowDialog(DUPLICATE_ITEM_DIALOG, {
            source = source,
            duplicate = result,
            callback = callback,
        })
        return nil
    end
    self:SetStatus(message, true)
    return nil
end

function UI:AddFromInput()
    local source = {
        name = self.nameEdit:GetText(),
        quantity = self.quantityEdit:GetText(),
        itemLink = self.selectedItemLink,
        nameHash = self.selectedNameHash,
        -- Set autocomplete uses a representative link. Its trait is not a
        -- player-selected rule and should not make otherwise identical set
        -- entries appear different.
        ignoreLinkTrait = self.selectedSetId ~= nil,
    }
    self:AddSourceWithDuplicatePrompt(source, function()
        self:ClearAddInput()
    end)
end

function UI:SetStatus(text, isError)
    if self.owner.accessibility then
        text = self.owner.accessibility:FormatStatus(text, isError)
    end
    self.status:SetText(text or "")
    if isError then
        self.status:SetColor(1, 0.35, 0.35, 1)
    else
        self.status:SetColor(0.65, 0.82, 0.55, 1)
    end
end

function UI:GetVisibleItems()
    return self.owner.data:GetFilteredShoppingItems()
end

function UI:GetRowCapacity()
    return self.rowCapacity or 1
end

function UI:RefreshSummary(completed, total)
    local list = self.owner.data:GetCurrentList()
    if self.owner.data:IsMultiListTripEnabled() then
        local lists = self.owner.data:GetShoppingLists()
        local items = self.owner.data:GetShoppingItems()
        completed = 0
        local spent = 0
        for _, item in ipairs(items) do
            if self.owner.data:IsItemComplete(item) then
                completed = completed + 1
            end
        end
        for _, activeList in ipairs(lists) do
            spent = spent + (tonumber(activeList.transactionSpent)
                or tonumber(activeList.totalSpent) or 0)
        end
        self.summary:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_SUMMARY_SPENT),
            completed,
            #items,
            formatCompactGold(spent)
        ))
        self.summary:SetColor(0.9, 0.9, 0.9, 1)
        return
    end
    if completed == nil or total == nil then
        completed = 0
        total = #list.items
        for _, item in ipairs(list.items) do
            if self.owner.data:IsItemComplete(item) then
                completed = completed + 1
            end
        end
    end

    if list.budget then
        local spent = tonumber(list.transactionSpent)
            or tonumber(list.totalSpent) or 0
        local summary = zo_strformat(
            GetString(SI_SHOPPING_LIST_SUMMARY_WITH_BUDGET),
            completed,
            total,
            formatCompactGold(spent),
            formatCompactGold(list.budget)
        )
        if spent > list.budget then
            if self.owner.accessibility
                and self.owner.accessibility:UsesNonColorIndicators()
            then
                summary = summary .. " [!]"
            end
            self.summary:SetColor(1, 0.35, 0.3, 1)
        else
            self.summary:SetColor(0.85, 0.78, 0.62, 1)
        end
        self.summary:SetText(summary)
    else
        self.summary:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_SUMMARY_SPENT),
            completed,
            total,
            formatCompactGold(list.transactionSpent or list.totalSpent)
        ))
        self.summary:SetColor(0.9, 0.9, 0.9, 1)
    end
end

function UI:Refresh()
    if not self.window then
        return
    end

    self:RefreshListSelector()
    self.filterCombo:SetSelectedItem(
        self.filterLabels[self.owner.data:GetItemFilter()]
            or self.filterLabels.all
    )
    local sort, ascending = self.owner.data:GetItemSort()
    self.sortCombo:SetSelectedItem(
        self.sortLabels[sort .. ":" .. tostring(ascending)]
            or self.sortLabels["added:true"]
    )
    local search = self.owner.data:GetItemSearch()
    if not self.searchEdit:HasFocus() and self.searchEdit:GetText() ~= search then
        self.suppressItemSearch = true
        self.searchEdit:SetText(search)
        self.suppressItemSearch = false
    end
    local capacity = self:GetRowCapacity()
    local items = self:GetVisibleItems()
    local maxOffset = math.max(0, #items - capacity)
    self.offset = zo_clamp(self.offset, 0, maxOffset)

    local completed = 0
    for _, item in ipairs(self.owner.data:GetShoppingItems()) do
        if self.owner.data:IsItemComplete(item) then
            completed = completed + 1
        end
    end
    self:RefreshSummary(completed, #self.owner.data:GetShoppingItems())

    local canSearch = self.owner.ags and self.owner.ags:IsStoreReady()
    for rowIndex, row in ipairs(self.rows) do
        local item = rowIndex <= capacity and items[self.offset + rowIndex] or nil
        row.item = item
        row:SetHidden(item == nil)
        if item then
            local itemId = item.id
            local isComplete = self.owner.data:IsItemComplete(item)
            local targetMode = self.owner.data:GetTargetMode(item)
            row.toggle:SetText(isComplete and "[x]" or "[ ]")
            row.toggle:SetEnabled(targetMode == "buy")
            local sourceList = self.owner.data:GetListForItem(item.id)
            if self.owner.data:IsMultiListTripEnabled() and sourceList then
                local itemName = zo_strformat(
                    GetString(SI_SHOPPING_LIST_TRIP_ITEM_NAME),
                    sourceList.name,
                    item.name
                )
                row.name:SetText(item.note and item.note ~= "" and zo_strformat(
                    GetString(SI_SHOPPING_LIST_NOTE_MARKER),
                    itemName
                ) or itemName)
            else
                row.name:SetText(item.note and item.note ~= "" and zo_strformat(
                    GetString(SI_SHOPPING_LIST_NOTE_MARKER),
                    item.name
                ) or item.name)
            end
            local owned = self.owner.inventory and self.owner.inventory:GetCounts(item)
            local progress
            if targetMode == "own" then
                progress = zo_strformat(
                    GetString(SI_SHOPPING_LIST_INVENTORY_TARGET_PROGRESS),
                    owned and owned.total or 0,
                    item.desired,
                    self.owner.data:GetRemainingQuantity(item)
                )
            else
                progress = zo_strformat(
                    GetString(SI_SHOPPING_LIST_INVENTORY_PROGRESS),
                    item.purchased,
                    item.desired,
                    owned and owned.total or 0
                )
            end
            local isOverTarget = self.owner.data:ItemIsOverTarget(item)
            if item.maxUnitPrice then
                progress = progress .. " · ≤ " .. formatCompactGold(item.maxUnitPrice)
                if isOverTarget
                    and self.owner.accessibility
                    and self.owner.accessibility:UsesNonColorIndicators()
                then
                    progress = progress .. " [!]"
                end
            end
            row.progress:SetText(progress)
            row.find:SetHidden(not canSearch)
            row.edit:ClearAnchors()
            if canSearch then
                row.edit:SetAnchor(RIGHT, row.find, LEFT, -4, 0)
            else
                row.edit:SetAnchor(RIGHT, row.remove, LEFT, -4, 0)
            end
            if isComplete then
                local dim = self.owner.accessibility
                    and self.owner.accessibility:UsesHighContrast()
                    and 0.72 or 0.5
                row.name:SetColor(dim, dim, dim, 1)
            else
                row.name:SetColor(0.92, 0.92, 0.92, 1)
            end
            if isOverTarget then
                row.progress:SetColor(1, 0.4, 0.3, 1)
            elseif isComplete then
                local dim = self.owner.accessibility
                    and self.owner.accessibility:UsesHighContrast()
                    and 0.72 or 0.5
                row.progress:SetColor(dim, dim, dim, 1)
            else
                row.progress:SetColor(0.9, 0.9, 0.9, 1)
            end
            row.toggle:SetHandler("OnClicked", function()
                self.owner:ToggleItem(itemId)
            end)
            row.remove:SetHandler("OnClicked", function()
                self:ConfirmRemoveItem(itemId)
            end)
            row.find:SetHandler("OnClicked", function()
                self:Search(itemId)
            end)
            row.edit:SetHandler("OnClicked", function()
                self:OpenEditor(itemId)
            end)
            row.name:SetHandler("OnMouseUp", function(_, button, upInside)
                if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                    self:OpenEditor(itemId)
                end
            end)
        end
    end

    if #items > capacity then
        self.page:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_PAGE),
            self.offset + 1,
            math.min(self.offset + capacity, #items),
            #items
        ))
    else
        self.page:SetText("")
    end
    if self.owner.session
        and self.owner.session.window
        and not self.owner.session.window:IsHidden()
    then
        self.owner.session:Refresh()
    end
end

function UI:ConfirmRemoveItem(itemId)
    local item = self.owner.data:FindItem(itemId)
    if not item then
        return
    end
    ZO_Dialogs_ShowDialog(REMOVE_ITEM_DIALOG, {
        itemId = item.id,
        itemName = item.name,
    })
end

function UI:OpenEditor(itemId)
    local item = self.owner.data:FindItem(itemId)
    if item then
        self.owner.editor:Open(item)
    end
end

function UI:Search(itemId)
    local item = self.owner.data:FindItem(itemId)
    if not item then
        return
    end
    local ok, message = self.owner.ags:Search(item)
    if ok and item.maxUnitPrice then
        message = message .. " " .. zo_strformat(
            GetString(SI_SHOPPING_LIST_SEARCH_TARGET),
            formatCompactGold(item.maxUnitPrice)
        )
    end
    self:SetStatus(message, not ok)
end

function UI:Scroll(delta)
    local count = #self:GetVisibleItems()
    local capacity = self:GetRowCapacity()
    self.offset = zo_clamp(self.offset + delta, 0, math.max(0, count - capacity))
    self:Refresh()
end

function UI:Layout(width, height)
    self.lastWidth = width
    self.lastHeight = height
    self.geometry.width = width
    self.geometry.height = height

    self.divider:SetWidth(width - 24)
    self.listContainer:SetWidth(width - 175)
    self.nameBackdrop:SetWidth(width - 115)
    self.status:SetDimensions(math.max(100, width - 130), 20)
    self.suggestionPanel:SetWidth(width - 115)
    for _, button in ipairs(self.suggestions) do
        button:SetWidth(width - 125)
    end

    self.rowCapacity = zo_clamp(
        math.floor((height - ROW_TOP - FOOTER_HEIGHT) / ROW_HEIGHT),
        1,
        MAX_ROWS
    )
    for _, row in ipairs(self.rows) do
        row:SetWidth(width - 24)
    end
    self:Refresh()
end

function UI:SaveGeometry(savePosition)
    local width, height = self.window:GetDimensions()
    self.geometry.width = width
    self.geometry.height = height
    if savePosition then
        self.geometry.left = self.window:GetLeft()
        self.geometry.top = self.window:GetTop()
    end
end

function UI:RestorePosition()
    self.window:ClearAnchors()
    if self.geometry.left and self.geometry.top then
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.geometry.left, self.geometry.top)
    else
        self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

function UI:ResetGeometry()
    self.geometry.left = nil
    self.geometry.top = nil
    self.geometry.width = DEFAULT_WIDTH
    self.geometry.height = DEFAULT_HEIGHT
    self.window:SetDimensions(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    self:PositionBesideStore()
    self:SetStatus(GetString(SI_SHOPPING_LIST_STATUS_WINDOW_RESET))
end

function UI:PositionBesideStore()
    if self.geometry.left and self.geometry.top then
        self:RestorePosition()
        return
    end

    local store = ZO_TradingHouse
    self.window:ClearAnchors()
    if not store or store:IsHidden() then
        self.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        return
    end

    local side = self.owner.data:GetSettings().panelSide
    local roomOnRight = store:GetRight() + self.window:GetWidth() + 8 <= GuiRoot:GetWidth()
    if side == "right" and roomOnRight then
        self.window:SetAnchor(TOPLEFT, store, TOPRIGHT, 8, 0)
    else
        self.window:SetAnchor(TOPRIGHT, store, TOPLEFT, -8, 0)
    end
end

function UI:AcquireMouse()
    if IsGameCameraUIModeActive and not IsGameCameraUIModeActive() then
        self.ownsUIMode = true
        SetGameCameraUIMode(true)
        zo_callLater(function()
            if self.ownsUIMode and not self.window:IsHidden() then
                SetGameCameraUIMode(true)
            end
        end, 10)
    end
end

function UI:RestoreOwnedMouse(delayMs)
    if not self.ownsUIMode or self.window:IsHidden() then
        return
    end

    zo_callLater(function()
        if self.ownsUIMode
            and not self.window:IsHidden()
            and IsGameCameraUIModeActive
            and not IsGameCameraUIModeActive()
        then
            SetGameCameraUIMode(true)
        end
    end, delayMs or 10)
end

function UI:RegisterFocusEvent()
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_GameFocusChanged",
        EVENT_GAME_FOCUS_CHANGED,
        function(_, hasFocus)
            if hasFocus then
                self:RestoreOwnedMouse(50)
            end
        end
    )
end

function UI:ReleaseMouse()
    if not self.ownsUIMode then
        return
    end
    self.ownsUIMode = false
    if IsGameCameraUIModeActive and IsGameCameraUIModeActive() then
        SetGameCameraUIMode(false)
    end
end

function UI:Show(requestMouse)
    self.owner:RestoreStartupDataIfNeeded()
    self:PositionBesideStore()
    self.window:SetHidden(false)
    if requestMouse then
        self:AcquireMouse()
    end
    self:Refresh()
end

function UI:Hide()
    self.window:SetHidden(true)
    self.suggestionPanel:SetHidden(true)
    ClearTooltip(InformationTooltip)
    self:CloseListDialog()
    if self.owner.editor then
        self.owner.editor:Hide()
    end
    if self.owner.history then
        self.owner.history:Hide()
    end
    if self.owner.session then
        self.owner.session:Hide()
    end
    if self.owner.archive then
        self.owner.archive:Hide()
    end
    if self.owner.share then
        self.owner.share:Hide()
    end
    if self.owner.backup then
        self.owner.backup:Hide()
    end
    if self.owner.help then
        self.owner.help:Hide()
    end
    if self.owner.listTools then
        self.owner.listTools:Hide()
    end
    self:CloseBudgetDialog()
    self:ReleaseMouse()
end

function UI:ShowForStore()
    self:Show(false)
end

function UI:HideForStore()
    if self.owner.data:GetSettings().closeWithStore then
        self:Hide()
    end
end

function UI:Toggle(requestMouse)
    if self.window:IsHidden() then
        self:Show(requestMouse)
    else
        self:Hide()
    end
end
