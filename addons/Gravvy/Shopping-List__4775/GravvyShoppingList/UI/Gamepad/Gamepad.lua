ShoppingListGamepad = {}

local Gamepad = ShoppingListGamepad
local REMOVE_DIALOG = "SHOPPING_LIST_GAMEPAD_REMOVE_ITEM"
local ADD_DIALOG = "SHOPPING_LIST_GAMEPAD_ADD_ITEM"
local DUPLICATE_DIALOG = "SHOPPING_LIST_GAMEPAD_DUPLICATE_ITEM"

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

local function formatListName(list)
    local name = list.note and list.note ~= "" and zo_strformat(
        GetString(SI_SHOPPING_LIST_NOTE_MARKER),
        list.name
    ) or list.name
    if list.category and list.category ~= "" then
        name = zo_strformat(
            GetString(SI_SHOPPING_LIST_CATEGORY_MARKER),
            list.category,
            name
        )
    end
    if list.favorite then
        name = zo_strformat(GetString(SI_SHOPPING_LIST_FAVORITE_MARKER), name)
    end
    if list.pinned then
        name = zo_strformat(GetString(SI_SHOPPING_LIST_PINNED_MARKER), name)
    end
    if list.recurring then
        name = zo_strformat(GetString(SI_SHOPPING_LIST_RECURRING_MARKER), name)
    end
    return name
end

function Gamepad:New(owner)
    return setmetatable({ owner = owner, dirty = true }, { __index = self })
end

function Gamepad:Initialize()
    self.control = ShoppingListGamepadWindow
    self.listName = self.control:GetNamedChild("ListName")
    self.summary = self.control:GetNamedChild("Summary")
    self.status = self.control:GetNamedChild("Status")
    self.control:GetNamedChild("Title"):SetText(GetString(SI_SHOPPING_LIST_TITLE))
    ShoppingListAccessibility:RegisterBackdrop(
        self.control:GetNamedChild("Backdrop"),
        { 0.035, 0.035, 0.045, 0.96 },
        { 0.5, 0.42, 0.28, 0.9 }
    )

    local listControl = self.control:GetNamedChild("List")
    self.list = ZO_GamepadVerticalItemParametricScrollList:New(listControl)
    self.list:AddDataTemplate(
        "ZO_GamepadMenuEntryTemplate",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction
    )
    self.list:SetNoItemText(GetString(SI_SHOPPING_LIST_GAMEPAD_EMPTY))
    self.list:SetOnTargetDataChangedCallback(function()
        self:RefreshKeybinds()
    end)

    self:InitializeKeybinds()
    self:InitializeDialogs()
    self:InitializeManagementDialogs()
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_GamepadModeChanged",
        EVENT_GAMEPAD_PREFERRED_MODE_CHANGED,
        function(_, gamepadPreferred)
            if not gamepadPreferred then
                self:Hide()
            end
        end
    )
end

function Gamepad:InitializeKeybinds()
    self.keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            name = function()
                local item = self:GetTargetItem()
                if item and self.owner.data:IsItemComplete(item) then
                    return GetString(SI_SHOPPING_LIST_GAMEPAD_MARK_INCOMPLETE)
                end
                return GetString(SI_SHOPPING_LIST_GAMEPAD_MARK_COMPLETE)
            end,
            keybind = "UI_SHORTCUT_PRIMARY",
            enabled = function()
                local item = self:GetTargetItem()
                return item ~= nil and self.owner.data:GetTargetMode(item) == "buy"
            end,
            callback = function()
                local item = self:GetTargetItem()
                if item then
                    self.owner:ToggleItem(item.id)
                end
            end,
        },
        {
            name = GetString(SI_SHOPPING_LIST_BUTTON_FIND),
            keybind = "UI_SHORTCUT_SECONDARY",
            visible = function()
                return self:GetTargetItem() ~= nil
                    and self.owner.ags
                    and self.owner.ags:IsStoreReady()
            end,
            callback = function() self:FindTargetItem() end,
        },
        {
            name = GetString(SI_SHOPPING_LIST_GAMEPAD_ADD_ITEM),
            keybind = "UI_SHORTCUT_TERTIARY",
            callback = function() self:ShowAddItemDialog() end,
        },
        {
            name = GetString(SI_SHOPPING_LIST_GAMEPAD_REMOVE_ITEM),
            keybind = "UI_SHORTCUT_QUATERNARY",
            enabled = function() return self:GetTargetItem() ~= nil end,
            callback = function() self:ConfirmRemoveTargetItem() end,
        },
        {
            name = GetString(SI_SHOPPING_LIST_GAMEPAD_PREVIOUS_LIST),
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            visible = function() return #self.owner.data:GetLists() > 1 end,
            callback = function() self:SwitchList(-1) end,
        },
        {
            name = GetString(SI_SHOPPING_LIST_GAMEPAD_NEXT_LIST),
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            visible = function() return #self.owner.data:GetLists() > 1 end,
            callback = function() self:SwitchList(1) end,
        },
        {
            name = GetString(SI_SHOPPING_LIST_GAMEPAD_MANAGE),
            keybind = "UI_SHORTCUT_RIGHT_STICK",
            callback = function() self:ShowManagementDialog() end,
        },
        KEYBIND_STRIP:GenerateGamepadBackButtonDescriptor(function() self:Hide() end),
    }
    ZO_Gamepad_AddListTriggerKeybindDescriptors(self.keybinds, self.list)
end

function Gamepad:InitializeDialogs()
    ZO_Dialogs_RegisterCustomDialog(REMOVE_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_GAMEPAD_REMOVE_ITEM,
        },
        mainText = {
            text = function(dialog)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_GAMEPAD_REMOVE_CONFIRM),
                    dialog.data.item.name
                )
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    local item = dialog.data.item
                    self.owner:RemoveItem(item.id)
                    self:SetStatus(zo_strformat(
                        GetString(SI_SHOPPING_LIST_GAMEPAD_REMOVED_ITEM),
                        item.name
                    ))
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })

    local function setupTextField(control, data, selected, defaultText, maxChars, numeric)
        control.highlight:SetHidden(not selected)
        control.editBoxControl:SetDefaultText(defaultText)
        control.editBoxControl:SetMaxInputChars(maxChars)
        control.editBoxControl:SetText(data.value())
        control.editBoxControl:SetTextType(numeric and TEXT_TYPE_NUMERIC or TEXT_TYPE_ALL)
        control.editBoxControl.textChangedCallback = function(editBox)
            data.changed(editBox:GetText())
        end
        data.control = control
    end

    local function focusTextField(dialog)
        local data = dialog.entryList:GetTargetData()
        if data and data.control then
            data.control.editBoxControl:TakeFocus()
        end
    end

    ZO_Dialogs_RegisterCustomDialog(ADD_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            self.pendingItemName = ""
            self.pendingItemQuantity = "1"
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_GAMEPAD_ADD_ITEM_TITLE,
        },
        parametricList = {
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    value = function() return self.pendingItemName end,
                    changed = function(value) self.pendingItemName = value end,
                    setup = function(control, data, selected)
                        setupTextField(
                            control,
                            data,
                            selected,
                            GetString(SI_SHOPPING_LIST_GAMEPAD_ITEM_NAME),
                            ShoppingListModel.MAX_NAME_LENGTH,
                            false
                        )
                    end,
                    callback = focusTextField,
                    narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                },
            },
            {
                template = "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
                templateData = {
                    value = function() return self.pendingItemQuantity end,
                    changed = function(value) self.pendingItemQuantity = value end,
                    setup = function(control, data, selected)
                        setupTextField(
                            control,
                            data,
                            selected,
                            GetString(SI_SHOPPING_LIST_GAMEPAD_QUANTITY),
                            #tostring(ShoppingListModel.MAX_QUANTITY),
                            true
                        )
                    end,
                    callback = focusTextField,
                    narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
                },
            },
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    if data and data.callback then
                        data.callback(dialog)
                    end
                end,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_ADD,
                callback = function()
                    local source = {
                        name = self.pendingItemName,
                        quantity = self.pendingItemQuantity,
                    }
                    local item, message, result = self.owner:AddItemSource(
                        source,
                        "prompt"
                    )
                    if not item then
                        if result then
                            ZO_Dialogs_ReleaseDialogOnButtonPress(ADD_DIALOG)
                            zo_callLater(function()
                                ZO_Dialogs_ShowGamepadDialog(DUPLICATE_DIALOG, {
                                    source = source,
                                    duplicate = result,
                                })
                            end, 1)
                            return
                        end
                        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
                        return
                    end
                    ZO_Dialogs_ReleaseDialogOnButtonPress(ADD_DIALOG)
                    self:SetDuplicateStatus(item, source, result)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = function()
                    ZO_Dialogs_ReleaseDialogOnButtonPress(ADD_DIALOG)
                end,
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(DUPLICATE_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_DUPLICATE_ITEM_TITLE,
        },
        mainText = {
            text = function(dialog)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_DUPLICATE_ITEM_CONFIRM),
                    dialog.data.duplicate.name,
                    dialog.data.duplicate.desired,
                    dialog.data.source.quantity or 1
                )
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_BUTTON_MERGE,
                callback = function(dialog)
                    self:CompleteDuplicateAdd(dialog.data.source, "merge")
                end,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_REPLACE,
                callback = function(dialog)
                    self:CompleteDuplicateAdd(dialog.data.source, "replace")
                end,
            },
            {
                keybind = "DIALOG_TERTIARY",
                text = SI_SHOPPING_LIST_BUTTON_KEEP_SEPARATE,
                callback = function(dialog)
                    self:CompleteDuplicateAdd(dialog.data.source, "keep")
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function Gamepad:SetDuplicateStatus(item, source, result)
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

function Gamepad:CompleteDuplicateAdd(source, policy)
    local item, message, result = self.owner:AddItemSource(source, policy)
    if not item then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
        return
    end
    self:SetDuplicateStatus(item, source, result)
end

function Gamepad:GetTargetItem()
    local data = self.list:GetTargetData()
    return data and data.item
end

function Gamepad:IsShowing()
    return self.control and not self.control:IsHidden()
end

function Gamepad:Show()
    if not IsInGamepadPreferredMode() or self:IsShowing() then
        return
    end
    self.owner:RestoreStartupDataIfNeeded()
    self.owner.ui:Hide()
    self.control:SetHidden(false)
    self.keybindState = KEYBIND_STRIP:PushKeybindGroupState()
    KEYBIND_STRIP:RemoveDefaultExit(self.keybindState)
    KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds, self.keybindState)
    self.list:Activate()
    self:Refresh(true)
    PlaySound(SOUNDS.GAMEPAD_OPEN_WINDOW)
end

function Gamepad:Hide()
    if not self:IsShowing() then
        return
    end
    self.list:Deactivate()
    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds, self.keybindState)
    KEYBIND_STRIP:RestoreDefaultExit(self.keybindState)
    KEYBIND_STRIP:PopKeybindGroupState()
    self.keybindState = nil
    self.control:SetHidden(true)
    PlaySound(SOUNDS.GAMEPAD_CLOSE_WINDOW)
end

function Gamepad:Toggle()
    if self:IsShowing() then
        self:Hide()
    else
        self:Show()
    end
end

function Gamepad:ShowForStore()
    self:Show()
end

function Gamepad:HideForStore()
    if self.owner.data:GetSettings().closeWithStore then
        self:Hide()
    end
end

function Gamepad:SetStatus(message, isError)
    if self.owner.accessibility then
        message = self.owner.accessibility:FormatStatus(message, isError)
    end
    self.status:SetText(message or "")
    if isError then
        self.status:SetColor(1, 0.35, 0.35, 1)
    else
        self.status:SetColor(0.65, 0.82, 0.55, 1)
    end
end

function Gamepad:RefreshKeybinds()
    if self:IsShowing() then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybinds, self.keybindState)
    end
end

function Gamepad:Refresh(force)
    if not self:IsShowing() and not force then
        self.dirty = true
        return
    end

    local selectedItem = self:GetTargetItem()
    local selectedItemId = selectedItem and selectedItem.id
    local selectedIndex
    local current = self.owner.data:GetCurrentList()
    local shoppingLists = self.owner.data:GetShoppingLists()
    local currentName = formatListName(current)
    if self.owner.data:IsMultiListTripEnabled() then
        self.listName:SetText(zo_strformat(
            GetString(SI_SHOPPING_LIST_GAMEPAD_TRIP_HEADING),
            currentName,
            #shoppingLists
        ))
    else
        self.listName:SetText(currentName)
    end

    local completed = 0
    local shoppingItems = self.owner.data:GetShoppingItems()
    local spent = 0
    for _, list in ipairs(shoppingLists) do
        spent = spent + (tonumber(list.transactionSpent)
            or tonumber(list.totalSpent) or 0)
    end
    for _, item in ipairs(shoppingItems) do
        if self.owner.data:IsItemComplete(item) then
            completed = completed + 1
        end
    end
    self.list:Clear()
    for index, item in ipairs(self.owner.data:GetFilteredShoppingItems()) do
        local isComplete = self.owner.data:IsItemComplete(item)
        local itemName = item.name
        if self.owner.accessibility
            and self.owner.accessibility:UsesNonColorIndicators()
        then
            itemName = (isComplete and "[x] " or "[ ] ") .. itemName
        end
        local entry = ZO_GamepadEntryData:New(itemName)
        entry.item = item
        entry:SetFontScaleOnSelection(false)
        entry:SetShowUnselectedSublabels(true)
        local owned = self.owner.inventory and self.owner.inventory:GetCounts(item)
        if self.owner.data:GetTargetMode(item) == "own" then
            entry:AddSubLabel(zo_strformat(
                GetString(SI_SHOPPING_LIST_GAMEPAD_ITEM_TARGET_PROGRESS),
                owned and owned.total or 0,
                item.desired,
                self.owner.data:GetRemainingQuantity(item)
            ))
        else
            entry:AddSubLabel(zo_strformat(
                GetString(SI_SHOPPING_LIST_GAMEPAD_ITEM_PROGRESS),
                item.purchased,
                item.desired
            ))
        end
        entry:AddSubLabel(zo_strformat(
            GetString(SI_SHOPPING_LIST_GAMEPAD_ITEM_OWNED),
            owned and owned.total or 0,
            owned and owned.backpack or 0,
            owned and owned.bank or 0,
            owned and owned.craftBag or 0
        ))
        if item.note and item.note ~= "" then
            entry:AddSubLabel(zo_strformat(
                GetString(SI_SHOPPING_LIST_GAMEPAD_ITEM_NOTE),
                item.note
            ))
        end
        if self.owner.data:IsMultiListTripEnabled() then
            local sourceList = self.owner.data:GetListForItem(item.id)
            if sourceList then
                entry:AddSubLabel(zo_strformat(
                    GetString(SI_SHOPPING_LIST_GAMEPAD_SOURCE_LIST),
                    sourceList.name
                ))
            end
        end
        if item.maxUnitPrice then
            entry:AddSubLabel(zo_strformat(
                GetString(SI_SHOPPING_LIST_GAMEPAD_PRICE_TARGET),
                formatCompactGold(item.maxUnitPrice)
            ))
            if self.owner.data:ItemIsOverTarget(item)
                and self.owner.accessibility
                and self.owner.accessibility:UsesNonColorIndicators()
            then
                entry:AddSubLabel(GetString(SI_SHOPPING_LIST_ACCESSIBILITY_OVER_TARGET))
            end
        end
        if isComplete and not (self.owner.accessibility
            and self.owner.accessibility:UsesHighContrast())
        then
            entry:SetNameColors(ZO_DISABLED_TEXT, ZO_DISABLED_TEXT)
        end
        self.list:AddEntry("ZO_GamepadMenuEntryTemplate", entry)
        if item.id == selectedItemId then
            selectedIndex = index
        end
    end
    self.list:Commit()
    if selectedIndex then
        self.list:SetSelectedIndex(selectedIndex)
    end

    self.summary:SetText(zo_strformat(
        GetString(SI_SHOPPING_LIST_SUMMARY_SPENT),
        completed,
        #shoppingItems,
        formatCompactGold(spent)
    ))
    self.dirty = false
    self:RefreshKeybinds()
end

function Gamepad:SwitchList(direction)
    local lists = self.owner.data:GetDisplayLists()
    if #lists < 2 then
        return
    end

    local current = self.owner.data:GetCurrentList()
    local index = 1
    for listIndex, list in ipairs(lists) do
        if list.id == current.id then
            index = listIndex
            break
        end
    end
    local target = ((index - 1 + direction) % #lists) + 1
    self.owner.data:SelectList(lists[target].id)
    self:SetStatus("")
    self:Refresh(true)
    PlaySound(direction < 0 and SOUNDS.GAMEPAD_PAGE_BACK or SOUNDS.GAMEPAD_PAGE_FORWARD)
end

function Gamepad:FindTargetItem()
    local item = self:GetTargetItem()
    if not item then
        return
    end
    local ok, message = self.owner.ags:Search(item)
    if ok then
        self:Hide()
    else
        self:SetStatus(message, true)
    end
end

function Gamepad:ConfirmRemoveTargetItem()
    local item = self:GetTargetItem()
    if item then
        ZO_Dialogs_ShowGamepadDialog(REMOVE_DIALOG, { item = item })
    end
end

function Gamepad:ShowAddItemDialog()
    ZO_Dialogs_ShowGamepadDialog(ADD_DIALOG)
end
