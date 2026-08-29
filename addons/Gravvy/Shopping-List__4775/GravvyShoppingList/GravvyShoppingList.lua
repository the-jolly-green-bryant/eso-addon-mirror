GravvyShoppingList = {
    name = "GravvyShoppingList",
}

local addon = GravvyShoppingList
local REQUIRED_LIBRARIES = {
    {
        name = "LibAddonMenu-2.0",
        isAvailable = function() return LibAddonMenu2 ~= nil end,
    },
    {
        name = "LibMainMenu-2.0",
        isAvailable = function() return LibMainMenu2 ~= nil end,
    },
    {
        name = "LibSets",
        isAvailable = function() return LibSets ~= nil end,
    },
}

function addon:GetBuildVersion()
    local manager = GetAddOnManager()
    for index = 1, manager:GetNumAddOns() do
        local name = manager:GetAddOnInfo(index)
        if name == self.name then
            return manager:GetAddOnVersion(index)
        end
    end
end

local function formatGold(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(value)
    end
    return tostring(value)
end

function addon:Initialize()
    local data, message = ShoppingListData:New()
    if not data then
        d(message or GetString(SI_SHOPPING_LIST_DATA_MIGRATION_FAILED))
        return
    end
    self.data = data
    if self.API and self.API._AttachData then
        self.API:_AttachData(data)
    end
    self.accessibility = ShoppingListAccessibility
    self.accessibility:Initialize(self)
    self.matcher = ShoppingListMatcher
    self.setCatalog = ShoppingListSetCatalog:New()
    self.ui = ShoppingListUI:New(self)
    self.ui:Initialize()
    self.gamepad = ShoppingListGamepad:New(self)
    self.gamepad:Initialize()
    self.inventory = ShoppingListInventory:New(self)
    self.data:SetInventory(self.inventory)
    self.inventory:Initialize()
    self.history = ShoppingListHistory:New(self)
    self.history:Initialize()
    self.session = ShoppingListSessionSummary:New(self)
    self.session:Initialize()
    self.archive = ShoppingListArchive:New(self)
    self.archive:Initialize()
    self.share = ShoppingListShare:New(self)
    self.share:Initialize()
    self.backup = ShoppingListBackup:New(self)
    self.backup:Initialize()
    self.editor = ShoppingListEditor:New(self)
    self.editor:Initialize()
    self.help = ShoppingListHelp:New(self)
    self.help:Initialize()
    self.listTools = ShoppingListListTools:New(self)
    self.listTools:Initialize()
    self.crafting = ShoppingListCraftingIntegration:New(self)

    self.ags = ShoppingListAGSAdapter:New(self)
    local hasAGS = self.ags:Initialize()

    self.purchaseTracker = ShoppingListPurchaseTracker:New(self)
    self.purchaseTracker:Initialize(hasAGS)
    self.tradingIndicators = ShoppingListTradingIndicators:New(self)
    self.tradingIndicators:Initialize()

    ShoppingListSettings:Initialize(self)
    ShoppingListContextMenu:Initialize(self)
    ShoppingListMainMenu:Initialize(self)
    self:RegisterEvents()
    self:RegisterCommands()

    if self.data.legacyRecoveredCount then
        d(zo_strformat(
            GetString(SI_SHOPPING_LIST_LEGACY_RECOVERED),
            self.data.legacyRecoveredCount
        ))
    elseif self.data.legacyRecoveryError then
        d(self.data.legacyRecoveryError)
    end
    if self.data.legacyDuplicateRepairCount then
        d(zo_strformat(
            GetString(SI_SHOPPING_LIST_LEGACY_DUPLICATES_REMOVED),
            self.data.legacyDuplicateRepairCount
        ))
    end
end

function addon:HandleStoreOpened()
    self.storeOpen = true
    if self.storeOpenQueued then
        return
    end
    self.storeOpenQueued = true
    zo_callLater(function()
        self.storeOpenQueued = false
        if not self.storeOpen then
            return
        end
        if self.data:GetSettings().autoOpen then
            if IsInGamepadPreferredMode() then
                self.gamepad:ShowForStore()
            else
                self.ui:ShowForStore()
            end
        else
            self.ui:Refresh()
            self.gamepad:Refresh()
        end
        if self.tradingIndicators then
            self.tradingIndicators:Refresh()
        end
    end, 100)
end

function addon:HandleStoreClosed()
    if not self.storeOpen then
        return
    end
    self.storeOpen = false
    self.storeOpenQueued = false
    self.ui:HideForStore()
    self.gamepad:HideForStore()
    self.ui:Refresh()
    self.gamepad:Refresh()
end

function addon:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_OpenStore",
        EVENT_OPEN_TRADING_HOUSE,
        function() self:HandleStoreOpened() end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_CloseStore",
        EVENT_CLOSE_TRADING_HOUSE,
        function() self:HandleStoreClosed() end
    )
    EVENT_MANAGER:RegisterForEvent(
        "GravvyShoppingList_SaveCheckpoint",
        EVENT_PLAYER_DEACTIVATED,
        function() self.data:CreateDeactivationBackup() end
    )

    local registeredScenes = {}
    for _, scene in pairs({
        TRADING_HOUSE_SCENE,
        GAMEPAD_TRADING_HOUSE_SCENE,
        TRADING_HOUSE_GAMEPAD_SCENE,
    }) do
        if scene and scene.RegisterCallback and not registeredScenes[scene] then
            registeredScenes[scene] = true
            scene:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                    self:HandleStoreOpened()
                elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                    self:HandleStoreClosed()
                end
            end)
        end
    end
end

function addon:RestoreStartupDataIfNeeded()
    if self.startupRecoveryChecked then
        return
    end
    self.startupRecoveryChecked = true
    local restored, message, attempted = self.data:RestorePendingExternalSnapshot()
    if not attempted then
        return
    end
    if not restored then
        self.startupRecoveryChecked = false
        d(zo_strformat(
            GetString(SI_SHOPPING_LIST_EXTERNAL_RESTORE_FAILED),
            message or GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
        ))
        return
    end
    self.ui.listSignature = nil
    self.accessibility:Apply()
    if self.inventory then
        self.inventory:Refresh()
    end
    d(GetString(SI_SHOPPING_LIST_EXTERNAL_RESTORED))
end

function addon:RegisterCommands()
    SLASH_COMMANDS["/shoppinglist"] = function() self:ToggleWindow() end
    SLASH_COMMANDS["/shoppinglisthelp"] = function()
        if IsInGamepadPreferredMode() then
            self.gamepad:ShowHelpDialog()
        else
            self.help:Open()
        end
    end
end

function addon:ToggleWindow()
    if IsInGamepadPreferredMode() then
        self.ui:Hide()
        self.gamepad:Toggle()
    else
        self.gamepad:Hide()
        self.ui:Toggle(true)
    end
end

function addon:AddItem(name, quantity, itemLink, nameHash, duplicatePolicy)
    return self:AddItemToList(
        self.data:GetCurrentList().id,
        name,
        quantity,
        itemLink,
        nameHash,
        nil,
        nil,
        duplicatePolicy
    )
end

function addon:AddItemSource(source, duplicatePolicy)
    return self:AddItemSourceToList(
        self.data:GetCurrentList().id,
        source,
        duplicatePolicy
    )
end

function addon:AddItemSourceToList(listId, source, duplicatePolicy)
    local item, message, result = self.data:AddPreparedItemToList(
        listId,
        source,
        duplicatePolicy
    )
    if item then
        self.ui:Refresh()
        self.gamepad:Refresh()
        self:RefreshInventory()
    end
    return item, message, result
end

function addon:AddItemToList(
    listId,
    name,
    quantity,
    itemLink,
    nameHash,
    note,
    targetMode,
    duplicatePolicy,
    match
)
    local item, message, result = self.data:AddItemToList(
        listId,
        name,
        quantity,
        itemLink,
        nameHash,
        note,
        targetMode,
        duplicatePolicy,
        match
    )
    if item then
        self.ui:Refresh()
        self.gamepad:Refresh()
        self:RefreshInventory()
    end
    return item, message, result
end

function addon:RefreshInventory()
    if self.inventory then
        self.inventory:RefreshAllocations()
        self.inventory:QueueRefresh(0)
    end
    if self.tradingIndicators then
        self.tradingIndicators:Refresh()
    end
end

function addon:RemoveItem(id)
    if self.data:RemoveItem(id) then
        self.ui:Refresh()
        self.gamepad:Refresh()
        self:RefreshInventory()
    end
end

function addon:ToggleItem(id)
    if self.data:ToggleItem(id) then
        self.ui:Refresh()
        self.gamepad:Refresh()
    end
end

function addon:MoveItem(id, direction)
    if not self.data:MoveItem(id, direction) then
        return false
    end
    self.ui:Refresh()
    self.gamepad:Refresh()
    return true
end

function addon:UndoDeletion()
    local ok, actionOrMessage = self.data:UndoLastDeletion()
    if not ok then
        return false, actionOrMessage
    end
    self.ui.listSignature = nil
    self.ui:Refresh()
    self.gamepad:Refresh()
    return true, actionOrMessage
end

function addon:RecordPurchase(itemLink, itemName, quantity, purchase)
    purchase = purchase or {}
    purchase.itemLink = purchase.itemLink or itemLink
    purchase.itemName = purchase.itemName or itemName
    local shoppingLists = self.data:GetShoppingLists()
    local spendingBefore = {}
    for _, list in ipairs(shoppingLists) do
        spendingBefore[list.id] = tonumber(list.transactionSpent)
            or tonumber(list.totalSpent) or 0
    end
    local changes = self.matcher:ApplyPurchase(
        self.data:GetShoppingItems(),
        itemLink,
        itemName,
        quantity,
        function(entry) return self.data:GetRemainingQuantity(entry) end
    )
    if #changes == 0 then
        return
    end

    purchase.quantity = purchase.quantity or quantity
    local transaction = self.data:RecordPurchaseTransaction(changes, purchase)
    if transaction and self.session then
        self.session:RecordTransaction(transaction)
    end
    for _, list in ipairs(shoppingLists) do
        local transactionSpent = tonumber(list.transactionSpent)
            or tonumber(list.totalSpent) or 0
        if list.budget
            and spendingBefore[list.id] <= list.budget
            and transactionSpent > list.budget
        then
            d(zo_strformat(
                GetString(SI_SHOPPING_LIST_CHAT_OVER_BUDGET),
                list.name,
                formatGold(transactionSpent - list.budget)
            ))
        end
    end
    self.ui:Refresh()
    self.gamepad:Refresh()
    self:RefreshInventory()
    if self.data:GetSettings().autoFindNext then
        local afterItemId = changes[#changes] and changes[#changes].entry.id
        if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
            self.gamepad:FindNextItem(false, afterItemId)
        else
            self.ui:FindNextItem(false, afterItemId)
        end
    end
    if self.data:GetSettings().announcePurchases then
        for _, change in ipairs(changes) do
            local entry = change.entry
            d(zo_strformat(
                GetString(SI_SHOPPING_LIST_CHAT_PURCHASE_PROGRESS),
                entry.name,
                entry.purchased,
                entry.desired
            ))
        end
    end
end

local function onAddOnLoaded(_, name)
    if name ~= addon.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("GravvyShoppingList_Loaded", EVENT_ADD_ON_LOADED)

    local missing = {}
    for _, library in ipairs(REQUIRED_LIBRARIES) do
        if not library.isAvailable() then
            missing[#missing + 1] = library.name
        end
    end
    if #missing > 0 then
        d(zo_strformat(
            GetString(SI_SHOPPING_LIST_CHAT_MISSING_LIBRARIES),
            table.concat(missing, ", ")
        ))
        return
    end

    addon:Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    "GravvyShoppingList_Loaded",
    EVENT_ADD_ON_LOADED,
    onAddOnLoaded
)
