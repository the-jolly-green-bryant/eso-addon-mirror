local Gamepad = ShoppingListGamepad

local MANAGE_DIALOG = "SHOPPING_LIST_GAMEPAD_MANAGE"
local EDIT_DIALOG = "SHOPPING_LIST_GAMEPAD_EDIT_ITEM"
local ARCHIVES_DIALOG = "SHOPPING_LIST_GAMEPAD_ARCHIVES"
local SHARE_DIALOG = "SHOPPING_LIST_GAMEPAD_SHARE"
local IMPORT_DIALOG = "SHOPPING_LIST_GAMEPAD_IMPORT"
local BACKUP_DIALOG = "SHOPPING_LIST_GAMEPAD_BACKUP"
local BACKUP_RESTORE_DIALOG = "SHOPPING_LIST_GAMEPAD_BACKUP_RESTORE"
local SAFETY_DIALOG = "SHOPPING_LIST_GAMEPAD_SAFETY_COPIES"
local SAFETY_RESTORE_DIALOG = "SHOPPING_LIST_GAMEPAD_SAFETY_RESTORE"
local HELP_DIALOG = "SHOPPING_LIST_GAMEPAD_HELP"
local RELEASE_NOTES_DIALOG = "SHOPPING_LIST_GAMEPAD_RELEASE_NOTES"
local LIST_NAME_DIALOG = "SHOPPING_LIST_GAMEPAD_LIST_NAME"
local DELETE_LIST_DIALOG = "SHOPPING_LIST_GAMEPAD_DELETE_LIST"
local RESET_PROGRESS_DIALOG = "SHOPPING_LIST_GAMEPAD_RESET_PROGRESS"
local BUDGET_DIALOG = "SHOPPING_LIST_GAMEPAD_BUDGET"
local BULK_DIALOG = "SHOPPING_LIST_GAMEPAD_BULK_ADD"
local BULK_DUPLICATE_DIALOG = "SHOPPING_LIST_GAMEPAD_BULK_DUPLICATES"
local TRIP_DIALOG = "SHOPPING_LIST_GAMEPAD_TRIP_LISTS"
local FILTER_DIALOG = "SHOPPING_LIST_GAMEPAD_FILTER"
local SEARCH_SORT_DIALOG = "SHOPPING_LIST_GAMEPAD_SEARCH_SORT"
local SESSION_DIALOG = "SHOPPING_LIST_GAMEPAD_SESSION_SUMMARY"
local PURCHASES_DIALOG = "SHOPPING_LIST_GAMEPAD_PURCHASES"
local PURCHASE_CORRECTION_DIALOG = "SHOPPING_LIST_GAMEPAD_PURCHASE_CORRECTION"
local REMOVE_PURCHASE_DIALOG = "SHOPPING_LIST_GAMEPAD_REMOVE_PURCHASE"
local FILTER_ORDER = { "all", "needed", "completed", "overTarget", "restricted" }

local function showError(message)
    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, message)
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

local function releaseAndOpen(dialogName, callback)
    ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
    zo_callLater(callback, 10)
end

local function actionEntry(text, callback, visible, enabled)
    local data = {
        setup = ZO_SharedGamepadEntry_OnSetup,
        callback = callback,
    }
    if visible then
        data.visible = visible
    end
    if enabled then
        data.enabled = enabled
    end
    return {
        template = "ZO_GamepadMenuEntryTemplate",
        text = text,
        templateData = data,
    }
end

local function setupTextField(control, data, selected, options)
    local edit = control.editBoxControl
    control.highlight:SetHidden(not selected)
    edit:SetDefaultText(options.defaultText or "")
    edit:SetMaxInputChars(options.maxChars)
    edit:SetNewLineEnabled(options.multiline == true)
    edit:SetSelectAllOnFocus(true)
    edit:SetTextType(options.numeric and TEXT_TYPE_NUMERIC or TEXT_TYPE_ALL)
    edit:SetText(options.value() or "")
    edit.textChangedCallback = function(editBox)
        options.changed(editBox:GetText())
    end
    data.control = control
end

local function focusTextField(dialog)
    local data = dialog.entryList:GetTargetData()
    if data and data.control then
        data.control.editBoxControl:TakeFocus()
    end
end

local function textFieldEntry(header, options)
    return {
        template = options.multiline
            and "ZO_Gamepad_GenericDialog_TextFieldItem_Multiline_Large"
            or "ZO_Gamepad_GenericDialog_Parametric_TextFieldItem",
        header = header,
        templateData = {
            setup = function(control, data, selected)
                setupTextField(control, data, selected, options)
            end,
            callback = focusTextField,
            narrationText = ZO_GetDefaultParametricListEditBoxNarrationText,
        },
    }
end

local function dropdownEntry(header, choices, value, changed)
    local label = GetString(header)
    return {
        template = "ZO_GamepadDropdownItem",
        header = header,
        text = label,
        templateData = {
            setup = function(control, data, selected)
                local dropdown = control.dropdown
                dropdown:SetName(label)
                dropdown:SetSortsItems(false)
                dropdown:SetSelectedItemTextColor(selected)
                dropdown:ClearItems()

                local firstEntry
                local selectedEntry
                local selectedValue = value()
                for _, choice in ipairs(choices) do
                    local choiceValue = choice.value
                    local entry = dropdown:CreateItemEntry(choice.label, function()
                        changed(choiceValue)
                    end)
                    dropdown:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
                    firstEntry = firstEntry or entry
                    if choiceValue == selectedValue then
                        selectedEntry = entry
                    end
                end

                dropdown:UpdateItems()
                dropdown:SelectItem(selectedEntry or firstEntry, true)
                SCREEN_NARRATION_MANAGER:RegisterDialogDropdown(data.dialog, dropdown)
            end,
            callback = function(dialog)
                local control = dialog.entryList:GetTargetControl()
                if control then
                    control.dropdown:Activate()
                end
            end,
            narrationText = function(_, control)
                return control.dropdown:GetNarrationText()
            end,
        },
    }
end

local function selectDialogEntry(dialog)
    local data = dialog.entryList:GetTargetData()
    if data and data.callback then
        data.callback(dialog)
    end
end

local function cancelDialog(dialogName)
    return function()
        ZO_Dialogs_ReleaseDialogOnButtonPress(dialogName)
    end
end

function Gamepad:InitializeManagementDialogs()
    self:InitializeManageDialog()
    self:InitializeListNameDialog()
    self:InitializeDeleteListDialog()
    self:InitializeResetProgressDialog()
    self:InitializeBudgetManagementDialog()
    self:InitializeBulkManagementDialog()
    self:InitializeTripManagementDialog()
    self:InitializeFilterManagementDialog()
    self:InitializeSearchSortDialog()
    self:InitializeSessionSummaryDialog()
    self:InitializePurchaseCorrectionDialogs()
    self:InitializeEditDialog()
    self:InitializeArchivesDialog()
    self:InitializeShareDialog()
    self:InitializeImportDialog()
    self:InitializeBackupDialog()
    self:InitializeSafetyDialogs()
    self:InitializeHelpDialogs()
end

function Gamepad:InitializeManageDialog()
    ZO_Dialogs_RegisterCustomDialog(MANAGE_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        title = {
            text = SI_SHOPPING_LIST_GAMEPAD_MANAGE_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_GAMEPAD_MANAGE_HELP,
        },
        parametricList = {
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_CREATE_LIST,
                function() self:OpenListNameFromManagement("new") end
            ),
            actionEntry(
                function()
                    return GetString(self.owner.data:GetCurrentList().locked
                        and SI_SHOPPING_LIST_UNLOCK_LIST
                        or SI_SHOPPING_LIST_LOCK_LIST)
                end,
                function() self:ToggleLockedFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_RENAME,
                function() self:OpenListNameFromManagement("rename") end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_DUPLICATE,
                function() self:OpenListNameFromManagement("duplicate") end
            ),
            actionEntry(
                function()
                    return GetString(self.owner.data:GetCurrentList().recurring
                        and SI_SHOPPING_LIST_RECURRING_ON
                        or SI_SHOPPING_LIST_RECURRING_OFF)
                end,
                function() self:ToggleRecurringFromManagement() end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_RESET_PROGRESS,
                function() self:OpenResetProgressFromManagement() end,
                nil,
                function()
                    return not self.owner.data:GetCurrentList().locked
                        and self.owner.data:ListHasPurchaseProgress(
                        self.owner.data:GetCurrentList()
                    )
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_DELETE,
                function() self:OpenDeleteListFromManagement() end,
                nil,
                function()
                    return not self.owner.data:GetCurrentList().locked
                        and #self.owner.data:GetLists() > 1
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_MOVE_UP,
                function() self:MoveCurrentListFromManagement(-1) end,
                nil,
                function()
                    local _, index = self.owner.data:FindList(
                        self.owner.data:GetCurrentList().id
                    )
                    return not self.owner.data:GetCurrentList().locked
                        and index and index > 1
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_MOVE_DOWN,
                function() self:MoveCurrentListFromManagement(1) end,
                nil,
                function()
                    local _, index = self.owner.data:FindList(
                        self.owner.data:GetCurrentList().id
                    )
                    return not self.owner.data:GetCurrentList().locked
                        and index and index < #self.owner.data:GetLists()
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_BUDGET,
                function() self:OpenBudgetFromManagement() end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_CLEAR_COMPLETED,
                function() self:ClearCompletedFromManagement() end,
                nil,
                function()
                    if self.owner.data:GetCurrentList().locked then
                        return false
                    end
                    for _, item in ipairs(self.owner.data:GetItems()) do
                        if self.owner.data:IsItemComplete(item) then
                            return true
                        end
                    end
                    return false
                end
            ),
            actionEntry(
                function()
                    return zo_strformat(
                        GetString(SI_SHOPPING_LIST_GAMEPAD_FILTER),
                        self:GetGamepadFilterLabel()
                    )
                end,
                function() self:OpenFilterFromManagement() end
            ),
            actionEntry(
                function()
                    return zo_strformat(
                        GetString(SI_SHOPPING_LIST_GAMEPAD_SEARCH_SORT),
                        self:GetGamepadSortLabel()
                    )
                end,
                function() self:OpenSearchSortFromManagement() end
            ),
            actionEntry(
                function()
                    return GetString(self.owner.data:GetCurrentList().favorite
                        and SI_SHOPPING_LIST_FAVORITE_ON
                        or SI_SHOPPING_LIST_FAVORITE_OFF)
                end,
                function() self:ToggleFavoriteFromManagement() end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                function()
                    return GetString(self.owner.data:GetCurrentList().pinned
                        and SI_SHOPPING_LIST_PINNED_ON
                        or SI_SHOPPING_LIST_PINNED_OFF)
                end,
                function() self:TogglePinnedFromManagement() end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_UNDO,
                function() self:UndoFromManagement() end,
                nil,
                function() return self.owner.data:CanUndoDeletion() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_BULK_ADD,
                function() self:OpenBulkFromManagement() end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                SI_SHOPPING_LIST_BUTTON_TRIP,
                function() self:OpenTripFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_SESSION_TITLE,
                function() self:OpenSessionSummaryFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_FIND_NEXT,
                function()
                    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
                    self:FindNextItem(true)
                end,
                nil,
                function()
                    return self.owner.ags
                        and self.owner.ags:IsStoreReady()
                        and self.owner.data:GetNextNeededItem(
                            self:GetTargetItem() and self:GetTargetItem().id
                        ) ~= nil
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_EDIT_MATCHING,
                function() self:OpenEditDialogFromManagement() end,
                function() return self:GetTargetItem() ~= nil end,
                function()
                    local item = self:GetTargetItem()
                    local list = item and self.owner.data:GetListForItem(item.id)
                    return list ~= nil and not list.locked
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_HISTORY_MANAGE,
                function() self:OpenPurchasesFromManagement() end,
                function() return self:GetTargetItem() ~= nil end,
                function()
                    local item = self:GetTargetItem()
                    local list = item and self.owner.data:GetListForItem(item.id)
                    return list ~= nil
                        and not list.locked
                        and self.owner.data:GetTargetMode(item) == "buy"
                end
            ),
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_ARCHIVE_CURRENT,
                function() self:ArchiveCurrentListFromManagement() end,
                nil,
                function() return not self.owner.data:GetCurrentList().locked end
            ),
            actionEntry(
                function()
                    return zo_strformat(
                        GetString(SI_SHOPPING_LIST_ARCHIVED_COUNT),
                        #self.owner.data:GetArchivedLists()
                    )
                end,
                function() self:OpenArchivesFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_SHARE_CURRENT,
                function() self:OpenShareFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_IMPORT_LIST,
                function() self:OpenImportFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_BACKUP,
                function() self:OpenBackupFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_SAFETY_TITLE,
                function() self:OpenSafetyCopiesFromManagement() end
            ),
            actionEntry(
                SI_SHOPPING_LIST_GAMEPAD_HELP,
                function() self:OpenHelpFromManagement() end
            ),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(MANAGE_DIALOG),
            },
        },
    })
end

function Gamepad:InitializePurchaseCorrectionDialogs()
    ZO_Dialogs_RegisterCustomDialog(PURCHASES_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup = function(dialog)
            dialog.info.parametricList = self:BuildPurchaseEntries(dialog.data.itemId)
            dialog:setupFunc()
        end,
        title = { text = SI_SHOPPING_LIST_HISTORY_MANAGE },
        mainText = { text = SI_SHOPPING_LIST_HISTORY_GAMEPAD_HELP },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_REMOVE,
                visible = function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    return data and data.historyIndex ~= nil
                end,
                callback = function(dialog)
                    local data = dialog.entryList:GetTargetData()
                    if data and data.historyIndex then
                        self:ConfirmGamepadPurchaseRemoval(
                            dialog.data.itemId,
                            data.historyIndex
                        )
                    end
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(PURCHASES_DIALOG),
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(PURCHASE_CORRECTION_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup = function(dialog)
            local item = self.owner.data:FindItem(dialog.data.itemId)
            local purchase = item and dialog.data.historyIndex
                and item.purchaseHistory[dialog.data.historyIndex] or nil
            self.pendingPurchaseQuantity = tostring(
                purchase and purchase.quantity or 1
            )
            self.pendingPurchasePrice = tostring(math.floor(
                tonumber(purchase and purchase.unitPrice) or 0
            ))
            dialog:setupFunc()
        end,
        title = {
            text = function(dialog)
                return GetString(dialog.data.mode == "edit"
                    and SI_SHOPPING_LIST_HISTORY_EDIT_TITLE
                    or SI_SHOPPING_LIST_HISTORY_ADJUST_TITLE)
            end,
        },
        mainText = {
            text = function(dialog)
                return GetString(dialog.data.mode == "edit"
                    and SI_SHOPPING_LIST_HISTORY_EDIT_HELP
                    or (dialog.data.mode == "reduce"
                        and SI_SHOPPING_LIST_HISTORY_REDUCE_HELP
                        or SI_SHOPPING_LIST_HISTORY_ADD_HELP))
            end,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_HISTORY_QUANTITY, {
                value = function() return self.pendingPurchaseQuantity end,
                changed = function(value) self.pendingPurchaseQuantity = value end,
                defaultText = "1",
                maxChars = #tostring(ShoppingListModel.MAX_QUANTITY),
                numeric = true,
            }),
            textFieldEntry(SI_SHOPPING_LIST_HISTORY_UNIT_PRICE, {
                value = function() return self.pendingPurchasePrice end,
                changed = function(value) self.pendingPurchasePrice = value end,
                defaultText = "0",
                maxChars = #tostring(ShoppingListModel.MAX_PRICE),
                numeric = true,
            }),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_SAVE,
                callback = function(dialog)
                    self:SaveGamepadPurchaseCorrection(dialog.data)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(PURCHASE_CORRECTION_DIALOG),
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(REMOVE_PURCHASE_DIALOG, {
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
        title = { text = SI_SHOPPING_LIST_HISTORY_REMOVE_TITLE },
        mainText = { text = SI_SHOPPING_LIST_HISTORY_REMOVE_CONFIRM },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_DIALOG_CONFIRM,
                callback = function(dialog)
                    self:RemoveGamepadPurchase(dialog.data)
                end,
            },
            { keybind = "DIALOG_NEGATIVE", text = SI_DIALOG_CANCEL },
        },
    })
end

function Gamepad:ToggleLockedFromManagement()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListLocked(list.id, not list.locked)
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(GetString(list.locked
        and SI_SHOPPING_LIST_STATUS_LIST_LOCKED
        or SI_SHOPPING_LIST_STATUS_LIST_UNLOCKED))
end

function Gamepad:InitializeListNameDialog()
    ZO_Dialogs_RegisterCustomDialog(LIST_NAME_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            self.pendingListMode = dialog.data.mode
            local current = self.owner.data:GetCurrentList()
            if self.pendingListMode == "new" then
                self.pendingListName = ""
                self.pendingListNote = ""
                self.pendingListCategory = ""
            elseif self.pendingListMode == "duplicate" then
                local baseName = zo_strformat(
                    GetString(SI_SHOPPING_LIST_COPIED_LIST_NAME),
                    current.name
                )
                self.pendingListName = self.owner.data:GetUniqueListName(baseName)
                self.pendingListNote = current.note or ""
                self.pendingListCategory = current.category or ""
            else
                self.pendingListName = current.name
                self.pendingListNote = current.note or ""
                self.pendingListCategory = current.category or ""
            end
            dialog:setupFunc()
        end,
        title = {
            text = function(dialog)
                local mode = dialog.data and dialog.data.mode
                if mode == "new" then
                    return GetString(SI_SHOPPING_LIST_NEW_LIST_TITLE)
                elseif mode == "duplicate" then
                    return GetString(SI_SHOPPING_LIST_DUPLICATE_LIST_TITLE)
                end
                return GetString(SI_SHOPPING_LIST_RENAME_LIST_TITLE)
            end,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_GAMEPAD_LIST_NAME, {
                value = function() return self.pendingListName end,
                changed = function(value) self.pendingListName = value end,
                defaultText = GetString(SI_SHOPPING_LIST_GAMEPAD_LIST_NAME),
                maxChars = ShoppingListModel.MAX_NAME_LENGTH,
            }),
            textFieldEntry(SI_SHOPPING_LIST_LIST_NOTE, {
                value = function() return self.pendingListNote end,
                changed = function(value) self.pendingListNote = value end,
                defaultText = GetString(SI_SHOPPING_LIST_NOTE_PLACEHOLDER),
                maxChars = ShoppingListData.MAX_NOTE_LENGTH,
                multiline = true,
            }),
            textFieldEntry(SI_SHOPPING_LIST_LIST_CATEGORY, {
                value = function() return self.pendingListCategory end,
                changed = function(value) self.pendingListCategory = value end,
                defaultText = GetString(SI_SHOPPING_LIST_CATEGORY_PLACEHOLDER),
                maxChars = ShoppingListModel.MAX_CATEGORY_LENGTH,
            }),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_SAVE,
                callback = function() self:SaveListNameFromManagement() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(LIST_NAME_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeDeleteListDialog()
    ZO_Dialogs_RegisterCustomDialog(DELETE_LIST_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_DELETE_LIST_TITLE,
        },
        mainText = {
            text = function()
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_DELETE_LIST_CONFIRM),
                    self.owner.data:GetCurrentList().name
                )
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_BUTTON_DELETE,
                callback = function() self:DeleteCurrentListFromManagement() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function Gamepad:InitializeResetProgressDialog()
    ZO_Dialogs_RegisterCustomDialog(RESET_PROGRESS_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_RESET_PROGRESS_TITLE,
        },
        mainText = {
            text = function(dialog)
                local list = self.owner.data:FindList(dialog.data.listId)
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_RESET_PROGRESS_CONFIRM),
                    list and list.name or ""
                )
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_BUTTON_RESET_PROGRESS,
                callback = function(dialog)
                    self:ResetProgressFromManagement(dialog.data.listId)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function Gamepad:InitializeBudgetManagementDialog()
    ZO_Dialogs_RegisterCustomDialog(BUDGET_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            local list = self.owner.data:GetCurrentList()
            self.pendingBudgetListId = list.id
            self.pendingBudget = list.budget and tostring(list.budget) or ""
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_BUDGET_TITLE,
        },
        mainText = {
            text = function()
                local list = self.owner.data:GetCurrentList()
                return self.owner.costPlanning:FormatProjection(
                    self.owner.costPlanning:GetProjection(list),
                    formatGold
                )
            end,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_BUTTON_BUDGET, {
                value = function() return self.pendingBudget end,
                changed = function(value) self.pendingBudget = value end,
                defaultText = GetString(SI_SHOPPING_LIST_NO_BUDGET),
                maxChars = #tostring(ShoppingListModel.MAX_PRICE),
                numeric = true,
            }),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_SAVE,
                callback = function() self:SaveBudgetFromManagement() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(BUDGET_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeBulkManagementDialog()
    ZO_Dialogs_RegisterCustomDialog(BULK_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            self.pendingBulkText = ""
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_BULK_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_GAMEPAD_BULK_HELP,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_BUTTON_BULK_ADD, {
                value = function() return self.pendingBulkText end,
                changed = function(value) self.pendingBulkText = value end,
                defaultText = GetString(SI_SHOPPING_LIST_BULK_PLACEHOLDER),
                maxChars = 20000,
                multiline = true,
            }),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BULK_ADD,
                callback = function() self:AddBulkItemsFromManagement() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(BULK_DIALOG),
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(BULK_DUPLICATE_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_DUPLICATE_ITEM_TITLE,
        },
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
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_BUTTON_MERGE,
                callback = function(dialog)
                    self:CompleteBulkItemsFromManagement(
                        dialog.data.entries,
                        "merge"
                    )
                end,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_REPLACE,
                callback = function(dialog)
                    self:CompleteBulkItemsFromManagement(
                        dialog.data.entries,
                        "replace"
                    )
                end,
            },
            {
                keybind = "DIALOG_TERTIARY",
                text = SI_SHOPPING_LIST_BUTTON_KEEP_SEPARATE,
                callback = function(dialog)
                    self:CompleteBulkItemsFromManagement(
                        dialog.data.entries,
                        "keep"
                    )
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function Gamepad:InitializeTripManagementDialog()
    ZO_Dialogs_RegisterCustomDialog(TRIP_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            dialog.info.parametricList = self:BuildTripManagementEntries()
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_TRIP_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_TRIP_HELP,
        },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(TRIP_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeFilterManagementDialog()
    ZO_Dialogs_RegisterCustomDialog(FILTER_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            dialog.info.parametricList = self:BuildFilterManagementEntries()
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_SETTINGS_ITEM_FILTER,
        },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(FILTER_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeSearchSortDialog()
    local choices = {
        { label = GetString(SI_SHOPPING_LIST_SORT_NAME_ASC), value = "name:true" },
        { label = GetString(SI_SHOPPING_LIST_SORT_NAME_DESC), value = "name:false" },
        { label = GetString(SI_SHOPPING_LIST_SORT_QUANTITY_ASC), value = "quantity:true" },
        { label = GetString(SI_SHOPPING_LIST_SORT_QUANTITY_DESC), value = "quantity:false" },
        { label = GetString(SI_SHOPPING_LIST_SORT_OWNED_ASC), value = "owned:true" },
        { label = GetString(SI_SHOPPING_LIST_SORT_OWNED_DESC), value = "owned:false" },
        { label = GetString(SI_SHOPPING_LIST_SORT_COMPLETION_ASC), value = "completion:true" },
        { label = GetString(SI_SHOPPING_LIST_SORT_COMPLETION_DESC), value = "completion:false" },
        { label = GetString(SI_SHOPPING_LIST_SORT_PRICE_ASC), value = "price:true" },
        { label = GetString(SI_SHOPPING_LIST_SORT_PRICE_DESC), value = "price:false" },
        { label = GetString(SI_SHOPPING_LIST_SORT_ADDED_ASC), value = "added:true" },
        { label = GetString(SI_SHOPPING_LIST_SORT_ADDED_DESC), value = "added:false" },
    }
    self.gamepadSortChoices = choices

    ZO_Dialogs_RegisterCustomDialog(SEARCH_SORT_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = { dialogType = GAMEPAD_DIALOGS.PARAMETRIC },
        setup = function(dialog)
            self.pendingItemSearch = self.owner.data:GetItemSearch()
            local sort, ascending = self.owner.data:GetItemSort()
            self.pendingItemSort = sort .. ":" .. tostring(ascending)
            dialog:setupFunc()
        end,
        title = { text = SI_SHOPPING_LIST_SEARCH_SORT_TITLE },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_SEARCH_LABEL, {
                value = function() return self.pendingItemSearch end,
                changed = function(value) self.pendingItemSearch = value end,
                defaultText = GetString(SI_SHOPPING_LIST_SEARCH_PLACEHOLDER),
                maxChars = ShoppingListModel.MAX_NAME_LENGTH,
            }),
            dropdownEntry(
                SI_SHOPPING_LIST_SORT_LABEL,
                choices,
                function() return self.pendingItemSort end,
                function(value) self.pendingItemSort = value end
            ),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_SAVE,
                callback = function() self:SaveSearchSortFromManagement() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(SEARCH_SORT_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeSessionSummaryDialog()
    ZO_Dialogs_RegisterCustomDialog(SESSION_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            dialog.info.parametricList = self:BuildSessionSummaryEntries()
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_SESSION_TITLE,
        },
        mainText = {
            text = function()
                local overview = self.owner.session:GetOverviewText()
                local lists = self.owner.session:GetUpdatedListsText()
                return lists ~= "" and (overview .. "\n" .. lists) or overview
            end,
        },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_SESSION_RESET,
                callback = function()
                    self.owner.session:Reset()
                    releaseAndOpen(SESSION_DIALOG, function()
                        ZO_Dialogs_ShowGamepadDialog(SESSION_DIALOG)
                    end)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(SESSION_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeEditDialog()
    local qualityModes = {
        { label = GetString(SI_SHOPPING_LIST_CHOICE_ANY), value = "any" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_AT_LEAST), value = "minimum" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_EXACTLY), value = "exact" },
    }
    local levelModes = {
        { label = GetString(SI_SHOPPING_LIST_CHOICE_ANY), value = "any" },
        { label = GetString(SI_SHOPPING_LIST_CHOICE_EXACTLY), value = "exact" },
    }
    local targetModes = {
        { label = GetString(SI_SHOPPING_LIST_TARGET_BUY), value = "buy" },
        { label = GetString(SI_SHOPPING_LIST_TARGET_OWN), value = "own" },
    }

    ZO_Dialogs_RegisterCustomDialog(EDIT_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            local item = self.owner.data:FindItem(dialog.data.itemId)
            if not item then
                showError(GetString(SI_SHOPPING_LIST_ERROR_ITEM_MISSING))
                ZO_Dialogs_ReleaseDialogOnButtonPress(EDIT_DIALOG)
                return
            end

            local rule = item.match or {}
            self.editingItemId = item.id
            self.pendingEdit = {
                desired = tostring(item.desired),
                targetMode = ShoppingListModel:NormalizeTargetMode(item.targetMode),
                setName = rule.setName or "",
                traitType = rule.traitType or ITEM_TRAIT_TYPE_NONE,
                qualityMode = rule.qualityMode or "any",
                quality = rule.quality or ITEM_QUALITY_NORMAL,
                levelMode = rule.levelMode or "any",
                level = tostring(rule.level or 1),
                championPoints = tostring(rule.championPoints or 0),
                maxUnitPrice = item.maxUnitPrice and tostring(item.maxUnitPrice) or "",
                note = item.note or "",
            }
            self.pendingPriceSuggestion = self.owner.costPlanning:GetSuggestion(item)
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_EDITOR_TITLE,
        },
        mainText = {
            text = function(dialog)
                local item = self.owner.data:FindItem(dialog.data.itemId)
                return item and item.name or ""
            end,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_EDITOR_QUANTITY, {
                value = function() return self.pendingEdit.desired end,
                changed = function(value) self.pendingEdit.desired = value end,
                defaultText = GetString(SI_SHOPPING_LIST_EDITOR_QUANTITY),
                maxChars = #tostring(ShoppingListModel.MAX_QUANTITY),
                numeric = true,
            }),
            dropdownEntry(
                SI_SHOPPING_LIST_EDITOR_TARGET_MODE,
                targetModes,
                function() return self.pendingEdit.targetMode end,
                function(value) self.pendingEdit.targetMode = value end
            ),
            textFieldEntry(SI_SHOPPING_LIST_EDITOR_SET, {
                value = function() return self.pendingEdit.setName end,
                changed = function(value) self.pendingEdit.setName = value end,
                defaultText = GetString(SI_SHOPPING_LIST_EDITOR_ANY_SET),
                maxChars = ShoppingListModel.MAX_NAME_LENGTH,
            }),
            dropdownEntry(
                SI_SHOPPING_LIST_EDITOR_TRAIT,
                ShoppingListEditor.GetTraitChoices(),
                function() return self.pendingEdit.traitType end,
                function(value) self.pendingEdit.traitType = value end
            ),
            dropdownEntry(
                SI_SHOPPING_LIST_EDITOR_QUALITY_RULE,
                qualityModes,
                function() return self.pendingEdit.qualityMode end,
                function(value) self.pendingEdit.qualityMode = value end
            ),
            dropdownEntry(
                SI_SHOPPING_LIST_GAMEPAD_QUALITY,
                ShoppingListEditor.GetQualityChoices(),
                function() return self.pendingEdit.quality end,
                function(value) self.pendingEdit.quality = value end
            ),
            dropdownEntry(
                SI_SHOPPING_LIST_EDITOR_LEVEL_RULE,
                levelModes,
                function() return self.pendingEdit.levelMode end,
                function(value) self.pendingEdit.levelMode = value end
            ),
            textFieldEntry(SI_SHOPPING_LIST_EDITOR_LEVEL, {
                value = function() return self.pendingEdit.level end,
                changed = function(value) self.pendingEdit.level = value end,
                defaultText = GetString(SI_SHOPPING_LIST_EDITOR_LEVEL),
                maxChars = #tostring(ShoppingListModel.MAX_LEVEL),
                numeric = true,
            }),
            textFieldEntry(SI_SHOPPING_LIST_EDITOR_CHAMPION_POINTS, {
                value = function() return self.pendingEdit.championPoints end,
                changed = function(value) self.pendingEdit.championPoints = value end,
                defaultText = GetString(SI_SHOPPING_LIST_EDITOR_CHAMPION_POINTS),
                maxChars = #tostring(ShoppingListModel.MAX_CHAMPION_POINTS),
                numeric = true,
            }),
            actionEntry(
                function()
                    local suggestion = self.pendingPriceSuggestion
                    return suggestion and zo_strformat(
                        GetString(SI_SHOPPING_LIST_GAMEPAD_USE_SUGGESTED_PRICE),
                        formatGold(suggestion.price),
                        suggestion.sourceName
                    ) or ""
                end,
                function()
                    if self.pendingPriceSuggestion then
                        self.pendingEdit.maxUnitPrice = tostring(
                            self.pendingPriceSuggestion.price
                        )
                    end
                end,
                function() return self.pendingPriceSuggestion ~= nil end
            ),
            textFieldEntry(SI_SHOPPING_LIST_EDITOR_MAX_UNIT_PRICE, {
                value = function() return self.pendingEdit.maxUnitPrice end,
                changed = function(value) self.pendingEdit.maxUnitPrice = value end,
                defaultText = GetString(SI_SHOPPING_LIST_EDITOR_GOLD_NONE),
                maxChars = #tostring(ShoppingListModel.MAX_PRICE),
                numeric = true,
            }),
            textFieldEntry(SI_SHOPPING_LIST_EDITOR_NOTE, {
                value = function() return self.pendingEdit.note end,
                changed = function(value) self.pendingEdit.note = value end,
                defaultText = GetString(SI_SHOPPING_LIST_NOTE_PLACEHOLDER),
                maxChars = ShoppingListData.MAX_NOTE_LENGTH,
                multiline = true,
            }),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BUTTON_SAVE,
                callback = function() self:SaveGamepadItemEdit() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(EDIT_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeArchivesDialog()
    ZO_Dialogs_RegisterCustomDialog(ARCHIVES_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            dialog.info.parametricList = self:BuildArchivedListEntries()
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_ARCHIVE_TITLE,
        },
        mainText = {
            text = function()
                local count = #self.owner.data:GetArchivedLists()
                return zo_strformat(
                    GetString(SI_SHOPPING_LIST_ARCHIVE_SUMMARY),
                    count,
                    GetString(count == 1
                        and SI_SHOPPING_LIST_NOUN_ARCHIVED_LIST
                        or SI_SHOPPING_LIST_NOUN_ARCHIVED_LISTS)
                )
            end,
        },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_BUTTON_RESTORE,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(ARCHIVES_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeShareDialog()
    local options = {
        value = function() return self.gamepadShareCode end,
        changed = function(value) self.gamepadShareCode = value end,
        defaultText = GetString(SI_SHOPPING_LIST_SHARE_CURRENT_CODE),
        maxChars = ShoppingListShare.MAX_CODE_LENGTH,
        multiline = true,
    }
    ZO_Dialogs_RegisterCustomDialog(SHARE_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            self.gamepadShareCode = dialog.data.code
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_SHARE_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_GAMEPAD_SHARE_HELP,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_SHARE_CURRENT_CODE, options),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_SHARE_SELECT_CODE,
                callback = function(dialog) self:SelectGamepadShareCode(dialog) end,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_SHARE_IMPORT_CODE,
                callback = function() self:OpenImportFromShare() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(SHARE_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeImportDialog()
    local options = {
        value = function() return self.gamepadImportCode end,
        changed = function(value) self.gamepadImportCode = value end,
        defaultText = GetString(SI_SHOPPING_LIST_IMPORT_PLACEHOLDER),
        maxChars = ShoppingListShare.MAX_CODE_LENGTH,
        multiline = true,
    }
    ZO_Dialogs_RegisterCustomDialog(IMPORT_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            self.gamepadImportCode = ""
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_IMPORT_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_GAMEPAD_IMPORT_HELP,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_SHARE_IMPORT_CODE, options),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_GAMEPAD_SELECT_OPTION,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_SHARE_IMPORT_CODE,
                callback = function() self:ImportGamepadCode() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
                callback = cancelDialog(IMPORT_DIALOG),
            },
        },
    })
end

function Gamepad:InitializeBackupDialog()
    local options = {
        value = function() return self.gamepadBackupCode end,
        changed = function(value) self.gamepadBackupCode = value end,
        defaultText = GetString(SI_SHOPPING_LIST_BACKUP_PLACEHOLDER),
        maxChars = ShoppingListBackup.MAX_CODE_LENGTH,
        multiline = true,
    }
    ZO_Dialogs_RegisterCustomDialog(BACKUP_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            self.gamepadBackupCode = dialog.data.code
            dialog.info.mainText.text = dialog.data.help
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_BACKUP_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_GAMEPAD_BACKUP_HELP,
        },
        parametricList = {
            textFieldEntry(SI_SHOPPING_LIST_BACKUP_TITLE, options),
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_SHARE_SELECT_CODE,
                callback = function(dialog) self:SelectGamepadBackupCode(dialog) end,
            },
            {
                keybind = "DIALOG_SECONDARY",
                text = SI_SHOPPING_LIST_BACKUP_RESTORE,
                callback = function() self:ConfirmGamepadBackupRestore() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(BACKUP_DIALOG),
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(BACKUP_RESTORE_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_BACKUP_RESTORE_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_BACKUP_RESTORE_CONFIRM,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_BACKUP_RESTORE,
                callback = function() self:RestoreGamepadBackup() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function Gamepad:InitializeSafetyDialogs()
    ZO_Dialogs_RegisterCustomDialog(SAFETY_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            dialog.info.parametricList = self:BuildSafetyCopyEntries()
            dialog:setupFunc()
        end,
        title = {
            text = SI_SHOPPING_LIST_SAFETY_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_SAFETY_GAMEPAD_HELP,
        },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_SAFETY_RESTORE,
                callback = selectDialogEntry,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(SAFETY_DIALOG),
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(SAFETY_RESTORE_DIALOG, {
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_SAFETY_RESTORE_TITLE,
        },
        mainText = {
            text = SI_SHOPPING_LIST_SAFETY_RESTORE_CONFIRM,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_SAFETY_RESTORE,
                callback = function() self:RestoreGamepadSafetyCopy() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_DIALOG_CANCEL,
            },
        },
    })
end

function Gamepad:InitializeHelpDialogs()
    ZO_Dialogs_RegisterCustomDialog(HELP_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_HELP_TITLE,
        },
        mainText = {
            text = function()
                return GetString(SI_SHOPPING_LIST_HELP_LIST_VIEWS)
                    .. "\n\n"
                    .. GetString(SI_SHOPPING_LIST_HELP_DUPLICATES)
                    .. "\n\n"
                    .. GetString(SI_SHOPPING_LIST_HELP_CONTENT)
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_HELP_RELEASE_NOTES,
                callback = function() self:OpenGamepadReleaseNotes() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(HELP_DIALOG),
            },
        },
    })

    ZO_Dialogs_RegisterCustomDialog(RELEASE_NOTES_DIALOG, {
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title = {
            text = SI_SHOPPING_LIST_HELP_RELEASE_NOTES,
        },
        mainText = {
            text = SI_SHOPPING_LIST_RELEASE_NOTES_CONTENT,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_SHOPPING_LIST_HELP_GETTING_STARTED,
                callback = function() self:OpenGamepadHelp() end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = cancelDialog(RELEASE_NOTES_DIALOG),
            },
        },
    })
end

function Gamepad:ShowManagementDialog()
    ZO_Dialogs_ShowGamepadDialog(MANAGE_DIALOG)
end

function Gamepad:RefreshAfterManagement(status)
    self.owner.ui.listSignature = nil
    self.owner.ui:Refresh()
    self:Refresh(true)
    self.owner:RefreshInventory()
    if status then
        self:SetStatus(status)
        self.owner.ui:SetStatus(status)
    end
end

function Gamepad:OpenListNameFromManagement(mode)
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(LIST_NAME_DIALOG, { mode = mode })
    end)
end

function Gamepad:SaveListNameFromManagement()
    local mode = self.pendingListMode
    local current = self.owner.data:GetCurrentList()
    if mode == "new" then
        local list, message = self.owner.data:AddList(
            self.pendingListName,
            self.pendingListNote,
            self.pendingListCategory
        )
        if not list then
            showError(message)
            return
        end
    elseif mode == "duplicate" then
        local list, message = self.owner.data:DuplicateList(
            current.id,
            self.pendingListName,
            self.pendingListNote,
            self.pendingListCategory
        )
        if not list then
            showError(message)
            return
        end
    else
        local ok, message = self.owner.data:RenameList(
            current.id,
            self.pendingListName
        )
        if not ok then
            showError(message)
            return
        end
        self.owner.data:UpdateListNote(current.id, self.pendingListNote)
        local categoryOk, categoryMessage = self.owner.data:UpdateListCategory(
            current.id,
            self.pendingListCategory
        )
        if not categoryOk then
            showError(categoryMessage)
            return
        end
    end

    ZO_Dialogs_ReleaseDialogOnButtonPress(LIST_NAME_DIALOG)
    self:RefreshAfterManagement(GetString(SI_SHOPPING_LIST_STATUS_LISTS_UPDATED))
end

function Gamepad:OpenDeleteListFromManagement()
    if #self.owner.data:GetLists() == 1 then
        showError(GetString(SI_SHOPPING_LIST_ERROR_LIST_REQUIRED))
        return
    end
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(DELETE_LIST_DIALOG)
    end)
end

function Gamepad:ToggleRecurringFromManagement()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListRecurring(
        list.id,
        list.recurring ~= true
    )
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(GetString(list.recurring
        and SI_SHOPPING_LIST_STATUS_RECURRING_ON
        or SI_SHOPPING_LIST_STATUS_RECURRING_OFF))
end

function Gamepad:ToggleFavoriteFromManagement()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListFavorite(list.id, not list.favorite)
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(GetString(list.favorite
        and SI_SHOPPING_LIST_STATUS_FAVORITE_ON
        or SI_SHOPPING_LIST_STATUS_FAVORITE_OFF))
end

function Gamepad:TogglePinnedFromManagement()
    local list = self.owner.data:GetCurrentList()
    local ok, message = self.owner.data:SetListPinned(list.id, not list.pinned)
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(GetString(list.pinned
        and SI_SHOPPING_LIST_STATUS_PINNED_ON
        or SI_SHOPPING_LIST_STATUS_PINNED_OFF))
end

function Gamepad:OpenResetProgressFromManagement()
    local list = self.owner.data:GetCurrentList()
    if not self.owner.data:ListHasPurchaseProgress(list) then
        showError(GetString(SI_SHOPPING_LIST_STATUS_NO_PROGRESS_TO_RESET))
        return
    end
    local listId = list.id
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(RESET_PROGRESS_DIALOG, { listId = listId })
    end)
end

function Gamepad:ResetProgressFromManagement(listId)
    local ok, countOrMessage, list = self.owner.data:ResetListProgress(listId)
    if not ok then
        showError(countOrMessage)
        return
    end
    self:RefreshAfterManagement(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_PROGRESS_RESET),
        list.name,
        countOrMessage
    ))
end

function Gamepad:DeleteCurrentListFromManagement()
    local deletedName = self.owner.data:GetCurrentList().name
    local ok, message = self.owner.data:DeleteList(
        self.owner.data:GetCurrentList().id
    )
    if not ok then
        showError(message)
        return
    end
    self:RefreshAfterManagement(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_DELETED),
        deletedName
    ))
end

function Gamepad:MoveCurrentListFromManagement(direction)
    local current = self.owner.data:GetCurrentList()
    if not self.owner.data:MoveList(current.id, direction) then
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(GetString(SI_SHOPPING_LIST_STATUS_LIST_ORDER_UPDATED))
end

function Gamepad:OpenBudgetFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(BUDGET_DIALOG)
    end)
end

function Gamepad:SaveBudgetFromManagement()
    local ok, message = self.owner.data:UpdateListBudget(
        self.pendingBudgetListId,
        self.pendingBudget
    )
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(BUDGET_DIALOG)
    self:RefreshAfterManagement(GetString(SI_SHOPPING_LIST_STATUS_BUDGET_UPDATED))
end

function Gamepad:ClearCompletedFromManagement()
    local count, message = self.owner.data:ClearCompleted()
    if count == nil then
        showError(message)
        return
    end
    if count == 0 then
        showError(GetString(SI_SHOPPING_LIST_STATUS_NO_COMPLETED_ITEMS))
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_CLEARED_COMPLETED),
        count
    ))
end

function Gamepad:GetGamepadFilterLabel()
    local filter = self.owner.data:GetItemFilter()
    if filter == "needed" then
        return GetString(SI_SHOPPING_LIST_FILTER_NEEDED)
    elseif filter == "completed" then
        return GetString(SI_SHOPPING_LIST_FILTER_COMPLETED)
    elseif filter == "overTarget" then
        return GetString(SI_SHOPPING_LIST_FILTER_OVER_TARGET)
    elseif filter == "restricted" then
        return GetString(SI_SHOPPING_LIST_FILTER_RESTRICTED)
    end
    return GetString(SI_SHOPPING_LIST_FILTER_ALL)
end

function Gamepad:OpenFilterFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(FILTER_DIALOG)
    end)
end

function Gamepad:BuildFilterManagementEntries()
    local entries = {}
    local current = self.owner.data:GetItemFilter()
    for _, filter in ipairs(FILTER_ORDER) do
        local filterValue = filter
        local label
        if filter == "needed" then
            label = GetString(SI_SHOPPING_LIST_FILTER_NEEDED)
        elseif filter == "completed" then
            label = GetString(SI_SHOPPING_LIST_FILTER_COMPLETED)
        elseif filter == "overTarget" then
            label = GetString(SI_SHOPPING_LIST_FILTER_OVER_TARGET)
        elseif filter == "restricted" then
            label = GetString(SI_SHOPPING_LIST_FILTER_RESTRICTED)
        else
            label = GetString(SI_SHOPPING_LIST_FILTER_ALL)
        end
        entries[#entries + 1] = actionEntry(
            filter == current and "[x] " .. label or "[ ] " .. label,
            function() self:SetFilterFromManagement(filterValue) end
        )
    end
    return entries
end

function Gamepad:SetFilterFromManagement(filter)
    self.owner.data:SetItemFilter(filter)
    ZO_Dialogs_ReleaseDialogOnButtonPress(FILTER_DIALOG)
    self:RefreshAfterManagement(zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_FILTER_UPDATED),
        self:GetGamepadFilterLabel()
    ))
end

function Gamepad:GetGamepadSortLabel()
    local sort, ascending = self.owner.data:GetItemSort()
    local value = sort .. ":" .. tostring(ascending)
    for _, choice in ipairs(self.gamepadSortChoices or {}) do
        if choice.value == value then
            return choice.label
        end
    end
    return GetString(SI_SHOPPING_LIST_SORT_ADDED_ASC)
end

function Gamepad:OpenSearchSortFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(SEARCH_SORT_DIALOG)
    end)
end

function Gamepad:OpenPurchasesFromManagement()
    local item = self:GetTargetItem()
    if not item then
        showError(GetString(SI_SHOPPING_LIST_ERROR_ITEM_MISSING))
        return
    end
    local itemId = item.id
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(PURCHASES_DIALOG, { itemId = itemId })
    end)
end

function Gamepad:BuildPurchaseEntries(itemId)
    local item = self.owner.data:FindItem(itemId)
    if not item then
        return {}
    end
    local entries = {
        actionEntry(
            SI_SHOPPING_LIST_HISTORY_ADD,
            function() self:OpenGamepadPurchaseCorrection(itemId, "add") end
        ),
        actionEntry(
            SI_SHOPPING_LIST_HISTORY_REDUCE,
            function() self:OpenGamepadPurchaseCorrection(itemId, "reduce") end,
            nil,
            function() return (item.purchased or 0) > 0 end
        ),
        actionEntry(
            SI_SHOPPING_LIST_HISTORY_UNDO_LATEST,
            function() self:UndoLatestGamepadPurchase(itemId) end,
            nil,
            function() return #(item.purchaseHistory or {}) > 0 end
        ),
    }
    for index = #(item.purchaseHistory or {}), 1, -1 do
        local historyIndex = index
        local purchase = item.purchaseHistory[index]
        local date = GetDateStringFromTimestamp
            and GetDateStringFromTimestamp(purchase.timestamp)
            or tostring(purchase.timestamp or "")
        local entry = actionEntry(
            zo_strformat(
                GetString(SI_SHOPPING_LIST_HISTORY_GAMEPAD_ROW),
                date,
                purchase.quantity or 0,
                formatGold(purchase.unitPrice)
            ),
            function()
                self:OpenGamepadPurchaseCorrection(
                    itemId,
                    "edit",
                    historyIndex
                )
            end
        )
        entry.templateData.historyIndex = historyIndex
        entries[#entries + 1] = entry
    end
    return entries
end

function Gamepad:OpenGamepadPurchaseCorrection(itemId, mode, historyIndex)
    releaseAndOpen(PURCHASES_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(PURCHASE_CORRECTION_DIALOG, {
            itemId = itemId,
            mode = mode,
            historyIndex = historyIndex,
        })
    end)
end

function Gamepad:SaveGamepadPurchaseCorrection(data)
    local quantity = tonumber(self.pendingPurchaseQuantity)
    local unitPrice = tonumber(self.pendingPurchasePrice) or 0
    local ok, message
    if data.mode == "edit" then
        ok, message = self.owner.data:UpdatePurchaseHistory(
            data.itemId,
            data.historyIndex,
            quantity,
            unitPrice
        )
    else
        local change = data.mode == "reduce" and -quantity or quantity
        ok, message = self.owner.data:AdjustPurchasedQuantity(
            data.itemId,
            change,
            unitPrice
        )
    end
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(PURCHASE_CORRECTION_DIALOG)
    self:RefreshAfterManagement(
        GetString(SI_SHOPPING_LIST_STATUS_PURCHASE_CORRECTED)
    )
end

function Gamepad:UndoLatestGamepadPurchase(itemId)
    local ok, message = self.owner.data:UndoLatestPurchase(itemId)
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(PURCHASES_DIALOG)
    self:RefreshAfterManagement(
        GetString(SI_SHOPPING_LIST_STATUS_PURCHASE_UNDONE)
    )
end

function Gamepad:ConfirmGamepadPurchaseRemoval(itemId, historyIndex)
    releaseAndOpen(PURCHASES_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(REMOVE_PURCHASE_DIALOG, {
            itemId = itemId,
            historyIndex = historyIndex,
        })
    end)
end

function Gamepad:RemoveGamepadPurchase(data)
    local ok, message = self.owner.data:RemovePurchaseHistory(
        data.itemId,
        data.historyIndex
    )
    if not ok then
        showError(message)
        return
    end
    self:RefreshAfterManagement(
        GetString(SI_SHOPPING_LIST_STATUS_PURCHASE_REMOVED)
    )
end

function Gamepad:SaveSearchSortFromManagement()
    local sort, ascending = string.match(
        self.pendingItemSort or "",
        "^([^:]+):(true|false)$"
    )
    local searchOk, searchMessage = self.owner.data:SetItemSearch(
        self.pendingItemSearch or ""
    )
    if not searchOk then
        showError(searchMessage)
        return
    end
    local sortOk, sortMessage = self.owner.data:SetItemSort(
        sort,
        ascending == "true"
    )
    if not sortOk then
        showError(sortMessage)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(SEARCH_SORT_DIALOG)
    self:RefreshAfterManagement(GetString(SI_SHOPPING_LIST_STATUS_VIEW_UPDATED))
end

function Gamepad:UndoFromManagement()
    local ok, message = self.owner:UndoDeletion()
    if not ok then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self:RefreshAfterManagement(GetString(SI_SHOPPING_LIST_STATUS_UNDO_COMPLETE))
end

function Gamepad:OpenBulkFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(BULK_DIALOG)
    end)
end

function Gamepad:AddBulkItemsFromManagement()
    local entries, message = ShoppingListListTools.ParseBulkText(
        self.pendingBulkText
    )
    if not entries then
        showError(message)
        return
    end
    local list = self.owner.data:GetCurrentList()
    local duplicateCount, duplicateMessage = self.owner.data:CountDuplicateSources(
        list.id,
        entries
    )
    if duplicateCount == nil then
        showError(duplicateMessage)
        return
    end
    if duplicateCount > 0 then
        releaseAndOpen(BULK_DIALOG, function()
            ZO_Dialogs_ShowGamepadDialog(BULK_DUPLICATE_DIALOG, {
                entries = entries,
                duplicateCount = duplicateCount,
            })
        end)
        return
    end

    self:CompleteBulkItemsFromManagement(entries, "keep", BULK_DIALOG)
end

function Gamepad:CompleteBulkItemsFromManagement(entries, duplicatePolicy, sourceDialog)
    local list = self.owner.data:GetCurrentList()
    local items, message = self.owner.data:AddItemsToList(
        list.id,
        entries,
        duplicatePolicy
    )
    if not items then
        showError(message)
        return
    end
    ZO_Dialogs_ReleaseDialogOnButtonPress(sourceDialog or BULK_DUPLICATE_DIALOG)
    self:RefreshAfterManagement(zo_strformat(
        GetString(SI_SHOPPING_LIST_BULK_ADDED),
        #items
    ))
end

function Gamepad:OpenTripFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(TRIP_DIALOG)
    end)
end

function Gamepad:RefreshTripManagementDialog()
    releaseAndOpen(TRIP_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(TRIP_DIALOG)
    end)
end

function Gamepad:BuildTripManagementEntries()
    local entries = {}
    entries[#entries + 1] = actionEntry(
        GetString(self.owner.data:IsMultiListTripEnabled()
            and SI_SHOPPING_LIST_TRIP_DISABLE
            or SI_SHOPPING_LIST_TRIP_ENABLE),
        function()
            self.owner.data:SetMultiListTripEnabled(
                not self.owner.data:IsMultiListTripEnabled()
            )
            self:RefreshAfterManagement()
            self:RefreshTripManagementDialog()
        end
    )
    entries[#entries + 1] = actionEntry(
        SI_SHOPPING_LIST_TRIP_ALL,
        function()
            self.owner.data:SetAllTripListsActive()
            self:RefreshAfterManagement()
            self:RefreshTripManagementDialog()
        end
    )
    entries[#entries + 1] = actionEntry(
        SI_SHOPPING_LIST_TRIP_CURRENT_ONLY,
        function()
            self.owner.data:SetOnlyTripListActive(
                self.owner.data:GetCurrentList().id
            )
            self:RefreshAfterManagement()
            self:RefreshTripManagementDialog()
        end
    )
    for _, list in ipairs(self.owner.data:GetLists()) do
        local listId = list.id
        entries[#entries + 1] = actionEntry(
            zo_strformat(
                GetString(list.tripActive
                    and SI_SHOPPING_LIST_TRIP_LIST_ACTIVE
                    or SI_SHOPPING_LIST_TRIP_LIST_INACTIVE),
                list.name
            ),
            function()
                local current = self.owner.data:FindList(listId)
                local ok, message = self.owner.data:SetListTripActive(
                    listId,
                    current and not current.tripActive
                )
                if not ok then
                    showError(message)
                    return
                end
                self:RefreshAfterManagement()
                self:RefreshTripManagementDialog()
            end
        )
    end
    return entries
end

function Gamepad:BuildSessionSummaryEntries()
    local entries = {}
    local transactions = self.owner.session.transactions or {}
    for index = #transactions, 1, -1 do
        entries[#entries + 1] = actionEntry(
            self.owner.session:GetTransactionText(transactions[index]),
            function() end
        )
    end
    return entries
end

function Gamepad:OpenSessionSummaryFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(SESSION_DIALOG)
    end)
end

function Gamepad:OpenEditDialogFromManagement()
    local item = self:GetTargetItem()
    if not item then
        showError(GetString(SI_SHOPPING_LIST_ERROR_ITEM_MISSING))
        return
    end
    local itemId = item.id
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(EDIT_DIALOG, { itemId = itemId })
    end)
end

function Gamepad:SaveGamepadItemEdit()
    local item = self.owner.data:FindItem(self.editingItemId)
    if not item then
        showError(GetString(SI_SHOPPING_LIST_ERROR_ITEM_MISSING))
        return
    end

    local ok, message = self.owner.data:UpdateItem(item.id, self.pendingEdit)
    if not ok then
        showError(message)
        return
    end

    ZO_Dialogs_ReleaseDialogOnButtonPress(EDIT_DIALOG)
    self.owner.ui:Refresh()
    self:Refresh(true)
    self.owner:RefreshInventory()
    local status = zo_strformat(GetString(SI_SHOPPING_LIST_STATUS_ITEM_UPDATED), item.name)
    self:SetStatus(status)
    self.owner.ui:SetStatus(status)
end

function Gamepad:ArchiveCurrentListFromManagement()
    local ok, listOrMessage = self.owner.data:ArchiveList(
        self.owner.data:GetCurrentList().id
    )
    if not ok then
        showError(listOrMessage)
        return
    end

    ZO_Dialogs_ReleaseDialogOnButtonPress(MANAGE_DIALOG)
    self.owner.ui.listSignature = nil
    self.owner.ui:Refresh()
    self:Refresh(true)
    self.owner:RefreshInventory()
    local status = zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_ARCHIVED),
        listOrMessage.name
    )
    self:SetStatus(status)
    self.owner.ui:SetStatus(status)
end

function Gamepad:OpenArchivesFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(ARCHIVES_DIALOG)
    end)
end

function Gamepad:OpenSafetyCopiesFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(SAFETY_DIALOG)
    end)
end

function Gamepad:BuildSafetyCopyEntries()
    local entries = {}
    local snapshots = self.owner.data:GetSafetySnapshots()
    for index = #snapshots, 1, -1 do
        local snapshot = snapshots[index]
        local snapshotId = snapshot.id
        local label = ShoppingListBackup.GetSafetyLabel(snapshot)
        local entry = ZO_GamepadEntryData:New(label)
        entry.setup = ZO_SharedGamepadEntry_OnSetup
        entry.callback = function()
            self.pendingGamepadSafetyId = snapshotId
            releaseAndOpen(SAFETY_DIALOG, function()
                ZO_Dialogs_ShowGamepadDialog(SAFETY_RESTORE_DIALOG)
            end)
        end
        entries[#entries + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            entryData = entry,
        }
    end
    if #entries == 0 then
        local empty = actionEntry(GetString(SI_SHOPPING_LIST_SAFETY_EMPTY), function() end)
        empty.templateData.enabled = false
        entries[1] = empty
    end
    return entries
end

function Gamepad:RestoreGamepadSafetyCopy()
    local id = self.pendingGamepadSafetyId
    self.pendingGamepadSafetyId = nil
    local ok, message = self.owner.data:RestoreSafetySnapshot(id)
    if not ok then
        showError(message)
        return
    end
    self.owner.ui.listSignature = nil
    self.owner.accessibility:Apply()
    self.owner:RefreshInventory()
    local status = GetString(SI_SHOPPING_LIST_SAFETY_RESTORED)
    self:SetStatus(status)
    self.owner.ui:SetStatus(status)
end

function Gamepad:BuildArchivedListEntries()
    local entries = {}
    local lists = self.owner.data:GetArchivedLists()
    for index = #lists, 1, -1 do
        local list = lists[index]
        local listId = list.id
        local entry = ZO_GamepadEntryData:New(list.name)
        entry.setup = ZO_SharedGamepadEntry_OnSetup
        entry.callback = function() self:RestoreArchivedList(listId) end
        entry:AddSubLabel(zo_strformat(
            GetString(SI_SHOPPING_LIST_GAMEPAD_ARCHIVE_DETAILS),
            #list.items,
            formatGold(list.transactionSpent or list.totalSpent)
        ))
        entries[#entries + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            entryData = entry,
        }
    end

    if #entries == 0 then
        local empty = actionEntry(GetString(SI_SHOPPING_LIST_ARCHIVE_EMPTY), function() end)
        empty.templateData.enabled = false
        entries[1] = empty
    end
    return entries
end

function Gamepad:RestoreArchivedList(listId)
    local ok, listOrMessage = self.owner.data:RestoreList(listId)
    if not ok then
        showError(listOrMessage)
        return
    end

    ZO_Dialogs_ReleaseDialogOnButtonPress(ARCHIVES_DIALOG)
    self.owner.ui.listSignature = nil
    self.owner.ui:Refresh()
    self:Refresh(true)
    self.owner:RefreshInventory()
    local status = zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_RESTORED),
        listOrMessage.name
    )
    self:SetStatus(status)
    self.owner.ui:SetStatus(status)
end

function Gamepad:OpenShareFromManagement()
    local code, message = ShoppingListShare.EncodeList(
        self.owner.data:GetCurrentList()
    )
    if not code then
        showError(message)
        return
    end
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(SHARE_DIALOG, { code = code })
    end)
end

function Gamepad:SelectGamepadShareCode(dialog)
    local data = dialog.entryList:GetTargetData()
    if not data or not data.control then
        return
    end
    local edit = data.control.editBoxControl
    edit:TakeFocus()
    if edit.SelectAll then
        edit:SelectAll()
    end
end

function Gamepad:OpenImportFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(IMPORT_DIALOG)
    end)
end

function Gamepad:OpenImportFromShare()
    releaseAndOpen(SHARE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(IMPORT_DIALOG)
    end)
end

function Gamepad:ImportGamepadCode()
    local decoded, message = ShoppingListShare.DecodeCode(self.gamepadImportCode)
    if not decoded then
        showError(message)
        return
    end

    local list, importMessage = self.owner.data:ImportList(
        decoded.name,
        decoded.items,
        decoded.note,
        decoded.recurring
    )
    if not list then
        showError(importMessage)
        return
    end

    ZO_Dialogs_ReleaseDialogOnButtonPress(IMPORT_DIALOG)
    self.owner.ui.listSignature = nil
    self.owner.ui:Refresh()
    self:Refresh(true)
    self.owner:RefreshInventory()
    local status = zo_strformat(
        GetString(SI_SHOPPING_LIST_STATUS_LIST_IMPORTED),
        list.name,
        #list.items,
        GetString(#list.items == 1
            and SI_SHOPPING_LIST_NOUN_ITEM
            or SI_SHOPPING_LIST_NOUN_ITEMS)
    )
    self:SetStatus(status)
    self.owner.ui:SetStatus(status)
end

function Gamepad:OpenBackupFromManagement()
    local code, message = ShoppingListBackup.Encode(
        self.owner.data:GetBackupData()
    )
    if not code then
        showError(message)
        return
    end
    local health = ShoppingListBackup.GetHealth(code)
    releaseAndOpen(MANAGE_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(BACKUP_DIALOG, {
            code = code,
            help = GetString(SI_SHOPPING_LIST_GAMEPAD_BACKUP_HELP)
                .. "\n" .. health,
        })
    end)
end

function Gamepad:SelectGamepadBackupCode(dialog)
    local data = dialog.entryList:GetTargetData()
    if not data or not data.control then
        return
    end
    local edit = data.control.editBoxControl
    edit:TakeFocus()
    if edit.SelectAll then
        edit:SelectAll()
    end
end

function Gamepad:ConfirmGamepadBackupRestore()
    local decoded, message = ShoppingListBackup.Decode(self.gamepadBackupCode)
    if not decoded then
        showError(message)
        return
    end
    self.pendingGamepadBackup = decoded
    releaseAndOpen(BACKUP_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(BACKUP_RESTORE_DIALOG)
    end)
end

function Gamepad:RestoreGamepadBackup()
    local snapshot = self.pendingGamepadBackup
    self.pendingGamepadBackup = nil
    local ok, message = self.owner.data:RestoreBackup(snapshot)
    if not ok then
        showError(message)
        return
    end

    self.owner.ui.listSignature = nil
    if self.owner.accessibility then
        self.owner.accessibility:Apply()
    end
    if self.owner.inventory then
        self.owner.inventory:Refresh()
    else
        self.owner.ui:Refresh()
        self:Refresh(true)
    end
    local status = GetString(SI_SHOPPING_LIST_BACKUP_RESTORED)
    self:SetStatus(status)
    self.owner.ui:SetStatus(status)
end

function Gamepad:OpenHelpFromManagement()
    releaseAndOpen(MANAGE_DIALOG, function()
        self:ShowHelpDialog()
    end)
end

function Gamepad:ShowHelpDialog()
    ZO_Dialogs_ShowGamepadDialog(HELP_DIALOG)
end

function Gamepad:OpenGamepadReleaseNotes()
    releaseAndOpen(HELP_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(RELEASE_NOTES_DIALOG)
    end)
end

function Gamepad:OpenGamepadHelp()
    releaseAndOpen(RELEASE_NOTES_DIALOG, function()
        ZO_Dialogs_ShowGamepadDialog(HELP_DIALOG)
    end)
end
