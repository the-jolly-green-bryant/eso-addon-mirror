ShoppingListData = {}

local Data = ShoppingListData
local DEFAULT_LIST_NAME = GetString(SI_SHOPPING_LIST_DEFAULT_LIST_NAME)
local MAX_DELETED_ACTIONS = 20
local MAX_NOTE_LENGTH = ShoppingListModel.MAX_NOTE_LENGTH
local CURRENT_SCHEMA_VERSION = 5
local MAX_RECOVERY_SNAPSHOTS = 5
local MAX_EXTERNAL_SNAPSHOTS = 10
local MAX_BACKUP_LISTS = ShoppingListModel.MAX_LISTS
local MAX_BACKUP_ITEMS = 100000
local MAX_HISTORY_PER_ITEM = ShoppingListModel.MAX_PURCHASE_HISTORY
local MAX_BACKUP_HISTORY_PER_ITEM = 10000
local MAX_NAME_LENGTH = ShoppingListModel.MAX_NAME_LENGTH
local MAX_LINK_LENGTH = ShoppingListModel.MAX_LINK_LENGTH
local MAX_QUANTITY = ShoppingListModel.MAX_QUANTITY
local MAX_U32 = ShoppingListModel.MAX_SET_OR_ITEM_ID
local MAX_SAFE_INTEGER = 9007199254740991
local VALID_FILTERS = {
    all = true,
    needed = true,
    completed = true,
    overTarget = true,
    restricted = true,
}
local DEFAULT_ITEM_SORT = "added"

local defaults = {
    schemaVersion = CURRENT_SCHEMA_VERSION,
    nextItemId = 1,
    nextListId = 2,
    nextTransactionId = 1,
    purchaseTransactions = {},
    language = GetCVar and GetCVar("language.2") or "",
    selectedListId = 1,
    archivedLists = {},
    deletedActions = {},
    recovery = {
        nextId = 1,
        snapshots = {},
    },
    legacyRecovery = {},
    lists = {
        {
            id = 1,
            name = DEFAULT_LIST_NAME,
            note = "",
            items = {},
            totalSpent = 0,
            transactionSpent = 0,
            tripActive = true,
            recurring = false,
            resetCount = 0,
            favorite = false,
            pinned = false,
            category = "",
            itemSearch = "",
            itemSort = DEFAULT_ITEM_SORT,
            itemSortAscending = true,
        },
    },
    settings = {
        autoOpen = true,
        closeWithStore = true,
        showCompleted = true,
        announcePurchases = true,
        panelSide = "right",
        itemFilter = "all",
        filterMigrated = false,
        multiListTrips = false,
        fontScale = 1,
        highContrast = false,
        nonColorIndicators = false,
        window = {
            width = 350,
            height = 500,
        },
    },
}

Data.MAX_NOTE_LENGTH = MAX_NOTE_LENGTH
Data.CURRENT_SCHEMA_VERSION = CURRENT_SCHEMA_VERSION

function Data:SetUpdateListener(listener)
    self.updateListener = type(listener) == "function" and listener or nil
end

function Data:NotifyUpdate(kind, details)
    if self.updateListener then
        self.updateListener(kind, details or {})
    end
end

local function normalizeName(name)
    name = zo_strtrim(name or "")
    return zo_strlower(zo_strformat(SI_TOOLTIP_ITEM_NAME, name))
end

local function normalizeNote(note)
    note = tostring(note or "")
    if #note > MAX_NOTE_LENGTH then
        note = string.sub(note, 1, MAX_NOTE_LENGTH)
    end
    return note
end

local function normalizeCategory(category)
    category = zo_strtrim(tostring(category or ""))
    if #category > ShoppingListModel.MAX_CATEGORY_LENGTH then
        category = string.sub(category, 1, ShoppingListModel.MAX_CATEGORY_LENGTH)
    end
    return category
end

local function deepCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end
    seen = seen or {}
    if seen[value] then
        return seen[value]
    end
    local copy = {}
    seen[value] = copy
    for key, entry in pairs(value) do
        copy[deepCopy(key, seen)] = deepCopy(entry, seen)
    end
    return copy
end

local STATE_KEYS = {
    "schemaVersion",
    "nextItemId",
    "nextListId",
    "nextTransactionId",
    "selectedListId",
    "lists",
    "archivedLists",
    "deletedActions",
    "purchaseTransactions",
    "recovery",
    "legacyRecovery",
    "language",
    "settings",
    "items",
}

local function extractState(source)
    local state = {}
    if type(source) ~= "table" then
        return state
    end
    for _, key in ipairs(STATE_KEYS) do
        local value = source[key]
        if value ~= nil then
            state[key] = deepCopy(value)
        end
    end
    return state
end

local function applyState(target, source)
    for _, key in ipairs(STATE_KEYS) do
        target[key] = deepCopy(source[key])
    end
end

local function copyPersistable(value, active)
    local valueType = type(value)
    if valueType == "nil" or valueType == "boolean" or valueType == "string" then
        return value, true
    end
    if valueType == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            return nil, false
        end
        return value, true
    end
    if valueType ~= "table" then
        return nil, false
    end

    active = active or {}
    if active[value] then
        return nil, false
    end
    active[value] = true

    local copy = {}
    for key, entry in pairs(value) do
        local copiedKey, keyOk = copyPersistable(key, active)
        local copiedEntry, entryOk = copyPersistable(entry, active)
        if keyOk and entryOk and copiedKey ~= nil then
            copy[copiedKey] = copiedEntry
        end
    end

    active[value] = nil
    return copy, true
end

local function readLinkDetails(itemLink)
    if not itemLink or itemLink == "" then
        return {}
    end

    local details = {
        itemId = GetItemLinkItemId(itemLink),
        quality = GetItemLinkDisplayQuality(itemLink),
    }

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if hasSet then
        details.setId = setId
        details.setName = setName
        details.normalizedSetName = normalizeName(setName)
    end

    details.traitType = GetItemLinkTraitInfo(itemLink)
    details.level = GetItemLinkRequiredLevel(itemLink)
    details.championPoints = GetItemLinkRequiredChampionPoints(itemLink)

    return details
end

function Data:New()
    local data = setmetatable({}, { __index = self })
    data.saved = ZO_SavedVars:NewAccountWide(
        "ShoppingList_Data",
        1,
        nil,
        defaults,
        GetWorldName()
    )
    data.externalBackups = ZO_SavedVars:NewAccountWide(
        "ShoppingList_BackupData",
        1,
        nil,
        { nextId = 1, snapshots = {} },
        GetWorldName()
    )
    local previousExternal = data:GetLatestExternalSnapshot()
    local startupExternal, backupMessage = data:CreateExternalSnapshot(
        "startup",
        data.saved
    )
    if not startupExternal then
        return nil, backupMessage
    end
    local ok, message = data:Migrate()
    if not ok then
        return nil, message
    end
    data:DetectStartupDataLoss(startupExternal, previousExternal)
    data:RecoverLegacyData()
    return data
end

function Data:Normalize()
    local currentLanguage = GetCVar and GetCVar("language.2") or ""
    local languageChanged = self.saved.language ~= currentLanguage
    if type(self.saved.items) == "table" then
        self.saved.lists = {
            {
                id = 1,
                name = DEFAULT_LIST_NAME,
                items = self.saved.items,
            },
        }
        self.saved.items = nil
        self.saved.selectedListId = 1
        self.saved.nextListId = 2
    end

    if type(self.saved.lists) ~= "table" or #self.saved.lists == 0 then
        self.saved.lists = {
            {
                id = 1,
                name = DEFAULT_LIST_NAME,
                items = {},
                totalSpent = 0,
                transactionSpent = 0,
            },
        }
        self.saved.selectedListId = 1
        self.saved.nextListId = 2
    end

    if type(self.saved.archivedLists) ~= "table" then
        self.saved.archivedLists = {}
    end
    if type(self.saved.deletedActions) ~= "table" then
        self.saved.deletedActions = {}
    end
    if type(self.saved.purchaseTransactions) ~= "table" then
        self.saved.purchaseTransactions = {}
    end
    while #self.saved.purchaseTransactions > ShoppingListModel.MAX_PURCHASE_TRANSACTIONS do
        table.remove(self.saved.purchaseTransactions, 1)
    end
    while #self.saved.deletedActions > MAX_DELETED_ACTIONS do
        table.remove(self.saved.deletedActions, 1)
    end

    local settings = self.saved.settings or {}
    self.saved.settings = settings
    if settings.autoOpen == nil then
        settings.autoOpen = true
    else
        settings.autoOpen = settings.autoOpen == true
    end
    if settings.closeWithStore == nil then
        settings.closeWithStore = true
    else
        settings.closeWithStore = settings.closeWithStore == true
    end
    if settings.showCompleted == nil then
        settings.showCompleted = true
    else
        settings.showCompleted = settings.showCompleted == true
    end
    if settings.announcePurchases == nil then
        settings.announcePurchases = true
    else
        settings.announcePurchases = settings.announcePurchases == true
    end
    if settings.filterMigrated ~= true then
        settings.itemFilter = settings.showCompleted == false and "needed" or "all"
        settings.filterMigrated = true
    elseif not VALID_FILTERS[settings.itemFilter] then
        settings.itemFilter = "all"
    end
    settings.multiListTrips = settings.multiListTrips == true
    settings.fontScale = zo_clamp(tonumber(settings.fontScale) or 1, 0.9, 1.4)
    settings.highContrast = settings.highContrast == true
    settings.nonColorIndicators = settings.nonColorIndicators == true
    local window = settings.window or {}
    settings.window = window
    window.width = zo_clamp(tonumber(window.width) or 350, 350, 900)
    window.height = zo_clamp(tonumber(window.height) or 500, 400, 900)

    local highestListId = 0
    local highestItemId = 0
    local function normalizeLists(lists, archived)
        for _, list in ipairs(lists) do
            list.id = tonumber(list.id) or (highestListId + 1)
            highestListId = math.max(highestListId, list.id)
            list.name = zo_strtrim(list.name or "")
            if list.name == "" then
                list.name = zo_strformat(
                    GetString(SI_SHOPPING_LIST_DEFAULT_LIST_NUMBERED),
                    list.id
                )
            end
            list.note = normalizeNote(list.note)
            list.items = type(list.items) == "table" and list.items or {}
            list.tripActive = list.tripActive == true
            list.recurring = list.recurring == true
            list.favorite = list.favorite == true
            list.pinned = list.pinned == true
            list.category = normalizeCategory(list.category)
            list.itemSearch = zo_strtrim(tostring(list.itemSearch or ""))
            if #list.itemSearch > ShoppingListModel.MAX_NAME_LENGTH then
                list.itemSearch = string.sub(
                    list.itemSearch,
                    1,
                    ShoppingListModel.MAX_NAME_LENGTH
                )
            end
            list.itemSort = ShoppingListModel.ITEM_SORTS[list.itemSort]
                and list.itemSort or DEFAULT_ITEM_SORT
            list.itemSortAscending = list.itemSortAscending ~= false
            list.resetCount = math.max(0, math.floor(tonumber(list.resetCount) or 0))
            list.lastResetAt = math.max(0, math.floor(tonumber(list.lastResetAt) or 0))
            if list.lastResetAt == 0 then
                list.lastResetAt = nil
            end
            if archived then
                list.archivedAt = tonumber(list.archivedAt) or GetTimeStamp()
            else
                list.archivedAt = nil
            end

            local itemSpending = 0
            for _, item in ipairs(list.items) do
                item.id = tonumber(item.id) or (highestItemId + 1)
                highestItemId = math.max(highestItemId, item.id)
                if languageChanged and item.itemLink and item.itemLink ~= "" then
                    local linkedName = zo_strtrim(GetItemLinkName(item.itemLink) or "")
                    if linkedName ~= "" then
                        item.name = zo_strformat(SI_TOOLTIP_ITEM_NAME, linkedName)
                        item.nameHash = nil
                    end
                end
                item.normalizedName = normalizeName(item.name)
                item.note = normalizeNote(item.note)
                item.desired = math.max(1, tonumber(item.desired) or 1)
                item.purchased = math.max(0, tonumber(item.purchased) or 0)
                item.targetMode = ShoppingListModel:NormalizeTargetMode(item.targetMode)
                item.addedAt = math.max(
                    0,
                    math.floor(tonumber(item.addedAt) or tonumber(item.id) or 0)
                )
                item.match = ShoppingListModel:NormalizeMatchingRule(item.match, true)
                if languageChanged and item.itemLink and item.itemLink ~= "" then
                    local details = readLinkDetails(item.itemLink)
                    item.itemId = details.itemId or item.itemId
                    if item.match.setId or item.match.setName then
                        item.match.setId = details.setId
                        item.match.setName = details.setName
                        item.match.normalizedSetName = details.normalizedSetName
                    end
                end
                item.purchaseHistory = type(item.purchaseHistory) == "table" and item.purchaseHistory or {}
                item.purchaseCount = math.max(
                    #item.purchaseHistory,
                    math.floor(tonumber(item.purchaseCount) or 0)
                )
                while #item.purchaseHistory > MAX_HISTORY_PER_ITEM do
                    table.remove(item.purchaseHistory, 1)
                end
                item.totalSpent = math.max(0, tonumber(item.totalSpent) or 0)
                item.pricedQuantity = math.max(0, tonumber(item.pricedQuantity) or 0)
                item.maxUnitPrice = math.floor(math.max(0, tonumber(item.maxUnitPrice) or 0))
                if item.maxUnitPrice == 0 then
                    item.maxUnitPrice = nil
                end
                itemSpending = itemSpending + item.totalSpent
                item.completed = item.completed == true or item.purchased >= item.desired
            end
            list.totalSpent = math.max(0, tonumber(list.totalSpent) or 0, itemSpending)
            list.transactionSpent = math.max(
                list.totalSpent,
                tonumber(list.transactionSpent) or list.totalSpent
            )
            list.budget = math.floor(math.max(0, tonumber(list.budget) or 0))
            if list.budget == 0 then
                list.budget = nil
            end
        end
    end

    normalizeLists(self.saved.lists, false)
    normalizeLists(self.saved.archivedLists, true)
    self.saved.language = currentLanguage

    self.saved.nextListId = math.max(tonumber(self.saved.nextListId) or 1, highestListId + 1)
    self.saved.nextItemId = math.max(tonumber(self.saved.nextItemId) or 1, highestItemId + 1)
    local highestTransactionId = 0
    for _, transaction in ipairs(self.saved.purchaseTransactions) do
        highestTransactionId = math.max(
            highestTransactionId,
            tonumber(transaction.id) or 0
        )
    end
    self.saved.nextTransactionId = math.max(
        tonumber(self.saved.nextTransactionId) or 1,
        highestTransactionId + 1
    )
    if not self:FindList(self.saved.selectedListId) then
        self.saved.selectedListId = self.saved.lists[1].id
    end
    self:EnsureActiveTripList()
end

local migrations = {
    [1] = function(candidate)
        candidate:Normalize()
        candidate.saved.schemaVersion = 2
    end,
    [2] = function(candidate)
        candidate:Normalize()
        candidate.saved.schemaVersion = 3
    end,
    [3] = function(candidate)
        candidate:Normalize()
        candidate.saved.schemaVersion = 4
    end,
    [4] = function(candidate)
        candidate:Normalize()
        candidate.saved.schemaVersion = 5
    end,
}

local function isFiniteNumber(value, minimum, maximum)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
        and (minimum == nil or value >= minimum)
        and (maximum == nil or value <= maximum)
end

local function isWholeNumber(value, minimum, maximum)
    return isFiniteNumber(value, minimum, maximum) and value == math.floor(value)
end

local function isBoundedString(value, maximum, allowEmpty)
    return type(value) == "string"
        and #value <= maximum
        and (allowEmpty or zo_strtrim(value) ~= "")
end

local function isSequentialArray(value, maximum)
    if type(value) ~= "table" then
        return false
    end
    local count = 0
    local highest = 0
    for key in pairs(value) do
        if not isWholeNumber(key, 1, maximum) then
            return false
        end
        count = count + 1
        highest = math.max(highest, key)
    end
    return count == highest and highest <= maximum
end

local function optionalBoolean(value)
    return value == nil or type(value) == "boolean"
end

local function optionalWholeNumber(value, minimum, maximum)
    return value == nil or isWholeNumber(value, minimum, maximum)
end

local function optionalFiniteNumber(value, minimum, maximum)
    return value == nil or isFiniteNumber(value, minimum, maximum)
end

local function optionalString(value, maximum)
    return value == nil or isBoundedString(value, maximum, true)
end

local function validateMatch(rule)
    return ShoppingListModel:IsValidMatchingRule(rule)
end

local function validateHistory(history)
    if not isSequentialArray(history, MAX_BACKUP_HISTORY_PER_ITEM) then
        return false
    end
    for _, purchase in ipairs(history) do
        if type(purchase) ~= "table"
            or not optionalWholeNumber(purchase.timestamp, 0, MAX_SAFE_INTEGER)
            or not optionalFiniteNumber(purchase.quantity, 0, MAX_QUANTITY)
            or not optionalWholeNumber(purchase.totalPrice, 0, MAX_SAFE_INTEGER)
            or not optionalFiniteNumber(purchase.unitPrice, 0, MAX_SAFE_INTEGER)
            or not optionalFiniteNumber(purchase.listingQuantity, 1, MAX_QUANTITY)
            or not optionalWholeNumber(purchase.listingPrice, 0, MAX_SAFE_INTEGER)
            or not optionalWholeNumber(purchase.currencyType, 0, 65535)
            or not optionalString(purchase.sellerName, MAX_NAME_LENGTH)
            or not optionalString(purchase.guildName, MAX_NAME_LENGTH)
            or not optionalString(purchase.itemName, MAX_NAME_LENGTH)
            or not optionalString(purchase.itemLink, MAX_LINK_LENGTH)
            or not optionalWholeNumber(purchase.transactionId, 1, MAX_U32)
            or not optionalWholeNumber(purchase.transactionPrice, 0, MAX_SAFE_INTEGER)
        then
            return false
        end
    end
    return true
end

local function validateItem(item, itemIds)
    if type(item) ~= "table"
        or not isWholeNumber(item.id, 1, MAX_U32)
        or itemIds[item.id]
        or not isBoundedString(item.name, MAX_NAME_LENGTH, false)
        or not optionalString(item.normalizedName, MAX_NAME_LENGTH)
        or not optionalString(item.note, MAX_NOTE_LENGTH)
        or not optionalString(item.itemLink, MAX_LINK_LENGTH)
        or not optionalWholeNumber(item.itemId, 1, MAX_U32)
        or not optionalWholeNumber(item.addedAt, 0, MAX_SAFE_INTEGER)
        or not isWholeNumber(item.desired, 1, MAX_QUANTITY)
        or not isWholeNumber(item.purchased or 0, 0, MAX_QUANTITY)
        or not ShoppingListModel:IsValidTargetMode(item.targetMode or "buy")
        or not optionalBoolean(item.completed)
        or not optionalWholeNumber(item.totalSpent, 0, MAX_SAFE_INTEGER)
        or not optionalWholeNumber(item.purchaseCount, 0, MAX_SAFE_INTEGER)
        or not optionalFiniteNumber(item.pricedQuantity, 0, MAX_QUANTITY)
        or not optionalWholeNumber(item.maxUnitPrice, 1, ShoppingListModel.MAX_PRICE)
        or not validateMatch(item.match)
        or not validateHistory(item.purchaseHistory or {})
    then
        return false
    end
    local hashType = type(item.nameHash)
    if item.nameHash ~= nil and hashType ~= "number" and hashType ~= "string" then
        return false
    end
    if hashType == "number" and not isFiniteNumber(item.nameHash) then
        return false
    end
    if hashType == "string" and #item.nameHash > MAX_NAME_LENGTH then
        return false
    end
    itemIds[item.id] = true
    return true
end

local function validateList(list, archived, listIds, itemIds, totals)
    if type(list) ~= "table"
        or not isWholeNumber(list.id, 1, MAX_U32)
        or listIds[list.id]
        or not isBoundedString(list.name, MAX_NAME_LENGTH, false)
        or not optionalString(list.note, MAX_NOTE_LENGTH)
        or not isSequentialArray(list.items, MAX_BACKUP_ITEMS)
        or not optionalWholeNumber(list.totalSpent, 0, MAX_SAFE_INTEGER)
        or not optionalWholeNumber(list.transactionSpent, 0, MAX_SAFE_INTEGER)
        or not optionalWholeNumber(list.budget, 1, ShoppingListModel.MAX_PRICE)
        or not optionalBoolean(list.tripActive)
        or not optionalBoolean(list.recurring)
        or not optionalBoolean(list.favorite)
        or not optionalBoolean(list.pinned)
        or not optionalString(list.category, ShoppingListModel.MAX_CATEGORY_LENGTH)
        or not optionalString(list.itemSearch, MAX_NAME_LENGTH)
        or (list.itemSort ~= nil and not ShoppingListModel.ITEM_SORTS[list.itemSort])
        or not optionalBoolean(list.itemSortAscending)
        or not optionalWholeNumber(list.resetCount, 0, MAX_SAFE_INTEGER)
        or not optionalWholeNumber(list.lastResetAt, 0, MAX_SAFE_INTEGER)
    then
        return false
    end
    if archived then
        if not optionalWholeNumber(list.archivedAt, 0, MAX_SAFE_INTEGER) then
            return false
        end
    elseif list.archivedAt ~= nil then
        return false
    end

    listIds[list.id] = true
    totals.items = totals.items + #list.items
    if totals.items > MAX_BACKUP_ITEMS then
        return false
    end
    for _, item in ipairs(list.items) do
        if not validateItem(item, itemIds) then
            return false
        end
    end
    return true
end

local function validateTransactions(transactions)
    if not isSequentialArray(
        transactions,
        ShoppingListModel.MAX_PURCHASE_TRANSACTIONS
    ) then
        return false
    end
    local ids = {}
    for _, transaction in ipairs(transactions) do
        if type(transaction) ~= "table"
            or not isWholeNumber(transaction.id, 1, MAX_U32)
            or ids[transaction.id]
            or not isWholeNumber(transaction.timestamp, 0, MAX_SAFE_INTEGER)
            or not isWholeNumber(transaction.quantity, 1, MAX_QUANTITY)
            or not isWholeNumber(transaction.totalPrice, 0, MAX_SAFE_INTEGER)
            or not optionalFiniteNumber(transaction.unitPrice, 0, MAX_SAFE_INTEGER)
            or not optionalWholeNumber(transaction.currencyType, 0, 65535)
            or not optionalString(transaction.sellerName, MAX_NAME_LENGTH)
            or not optionalString(transaction.guildName, MAX_NAME_LENGTH)
            or not optionalString(transaction.itemName, MAX_NAME_LENGTH)
            or not optionalString(transaction.itemLink, MAX_LINK_LENGTH)
            or not isSequentialArray(
                transaction.allocations,
                MAX_BACKUP_ITEMS
            )
        then
            return false
        end
        ids[transaction.id] = true
        for _, allocation in ipairs(transaction.allocations) do
            if type(allocation) ~= "table"
                or not isWholeNumber(allocation.listId, 1, MAX_U32)
                or not isWholeNumber(allocation.itemId, 1, MAX_U32)
                or not isWholeNumber(allocation.quantity, 1, MAX_QUANTITY)
                or not isWholeNumber(allocation.allocatedPrice, 0, MAX_SAFE_INTEGER)
                or not isWholeNumber(allocation.transactionPrice, 0, MAX_SAFE_INTEGER)
            then
                return false
            end
        end
    end
    return true
end

local function validateLegacyRecovery(value)
    if value == nil then
        return true
    end
    if type(value) ~= "table" then
        return false
    end
    local imports = value.imports
    if imports == nil then
        return true
    end
    if type(imports) ~= "table" then
        return false
    end
    local count = 0
    for fingerprint, entry in pairs(imports) do
        count = count + 1
        if count > 20
            or not isBoundedString(fingerprint, 128, false)
            or type(entry) ~= "table"
            or not isWholeNumber(entry.recoveredAt, 0, MAX_SAFE_INTEGER)
            or not isWholeNumber(entry.listCount, 0, MAX_BACKUP_LISTS)
            or not isBoundedString(entry.source, 128, false)
            or not isBoundedString(entry.world, 256, false)
            or not isBoundedString(
                entry.backupCode,
                ShoppingListBackup.MAX_CODE_LENGTH,
                false
            )
            or string.sub(entry.backupCode, 1, 5) ~= "SLB1:"
        then
            return false
        end
    end
    return true
end

function Data:ValidateBackupSnapshot(snapshot)
    if type(snapshot) ~= "table"
        or not isSequentialArray(snapshot.lists, MAX_BACKUP_LISTS)
        or #snapshot.lists == 0
        or not isSequentialArray(snapshot.archivedLists or {}, MAX_BACKUP_LISTS)
        or #snapshot.lists + #(snapshot.archivedLists or {}) > MAX_BACKUP_LISTS
        or type(snapshot.settings) ~= "table"
        or not isSequentialArray(snapshot.deletedActions or {}, MAX_DELETED_ACTIONS)
        or not validateTransactions(snapshot.purchaseTransactions or {})
        or not optionalWholeNumber(snapshot.schemaVersion, 1, CURRENT_SCHEMA_VERSION)
        or not optionalString(snapshot.language, 16)
        or snapshot.recovery ~= nil
        or not validateLegacyRecovery(snapshot.legacyRecovery)
    then
        return false
    end

    local listIds = {}
    local activeListIds = {}
    local itemIds = {}
    local totals = { items = 0 }
    for _, list in ipairs(snapshot.lists) do
        if not validateList(list, false, listIds, itemIds, totals) then
            return false
        end
        activeListIds[list.id] = true
    end
    for _, list in ipairs(snapshot.archivedLists or {}) do
        if not validateList(list, true, listIds, itemIds, totals) then
            return false
        end
    end

    local deletedListCount = 0
    for _, action in ipairs(snapshot.deletedActions or {}) do
        if type(action) ~= "table"
            or (action.kind ~= "list" and action.kind ~= "items")
            or not optionalWholeNumber(action.deletedAt, 0, MAX_SAFE_INTEGER)
        then
            return false
        end
        if action.kind == "list" then
            deletedListCount = deletedListCount + 1
            if deletedListCount + #snapshot.lists + #(snapshot.archivedLists or {})
                    > MAX_BACKUP_LISTS
                or not isWholeNumber(action.index, 1, MAX_BACKUP_LISTS)
                or not validateList(action.list, false, listIds, itemIds, totals)
            then
                return false
            end
        else
            if not isWholeNumber(action.listId, 1, MAX_U32)
                or not isSequentialArray(action.items, MAX_BACKUP_ITEMS)
            then
                return false
            end
            for _, removed in ipairs(action.items) do
                if type(removed) ~= "table"
                    or not isWholeNumber(removed.index, 1, MAX_BACKUP_ITEMS)
                    or not validateItem(removed.item, itemIds)
                then
                    return false
                end
                totals.items = totals.items + 1
                if totals.items > MAX_BACKUP_ITEMS then
                    return false
                end
            end
        end
    end

    local highestListId = 0
    for id in pairs(listIds) do
        highestListId = math.max(highestListId, id)
    end
    local highestItemId = 0
    for id in pairs(itemIds) do
        highestItemId = math.max(highestItemId, id)
    end
    if not isWholeNumber(snapshot.selectedListId, 1, MAX_U32)
        or not activeListIds[snapshot.selectedListId]
        or not isWholeNumber(snapshot.nextListId, highestListId + 1, MAX_U32)
        or not isWholeNumber(snapshot.nextItemId, highestItemId + 1, MAX_U32)
        or not isWholeNumber(snapshot.nextTransactionId or 1, 1, MAX_U32)
    then
        return false
    end
    for _, transaction in ipairs(snapshot.purchaseTransactions or {}) do
        if (snapshot.nextTransactionId or 1) <= transaction.id then
            return false
        end
    end

    local settings = snapshot.settings
    if not optionalBoolean(settings.autoOpen)
        or not optionalBoolean(settings.closeWithStore)
        or not optionalBoolean(settings.showCompleted)
        or not optionalBoolean(settings.announcePurchases)
        or (settings.panelSide ~= nil and settings.panelSide ~= "left" and settings.panelSide ~= "right")
        or (settings.itemFilter ~= nil and not VALID_FILTERS[settings.itemFilter])
        or not optionalBoolean(settings.filterMigrated)
        or not optionalBoolean(settings.multiListTrips)
        or not optionalFiniteNumber(settings.fontScale, 0.9, 1.4)
        or not optionalBoolean(settings.highContrast)
        or not optionalBoolean(settings.nonColorIndicators)
        or (settings.window ~= nil and type(settings.window) ~= "table")
    then
        return false
    end
    if settings.window
        and (not optionalFiniteNumber(settings.window.width, 350, 900)
            or not optionalFiniteNumber(settings.window.height, 400, 900)
            or not optionalFiniteNumber(settings.window.left, -100000, 100000)
            or not optionalFiniteNumber(settings.window.top, -100000, 100000))
    then
        return false
    end
    return true
end

local function validateCandidate(candidate)
    if type(candidate) ~= "table"
        or type(candidate.lists) ~= "table"
        or #candidate.lists == 0
        or type(candidate.archivedLists) ~= "table"
        or type(candidate.settings) ~= "table"
    then
        return false
    end
    for _, collection in ipairs({ candidate.lists, candidate.archivedLists }) do
        for _, list in ipairs(collection) do
            if type(list) ~= "table" or type(list.items) ~= "table" then
                return false
            end
            for _, item in ipairs(list.items) do
                if type(item) ~= "table" or type(item.name) ~= "string" then
                    return false
                end
            end
        end
    end
    return true
end

function Data:PrepareCandidate(source)
    local candidateSaved = extractState(source)
    if type(candidateSaved) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end

    local version = tonumber(candidateSaved.schemaVersion) or 1
    if version ~= math.floor(version) or version < 1 or version > CURRENT_SCHEMA_VERSION then
        return nil, GetString(SI_SHOPPING_LIST_DATA_SCHEMA_UNSUPPORTED)
    end

    local candidate = setmetatable({ saved = candidateSaved }, { __index = self })
    while version < CURRENT_SCHEMA_VERSION do
        local migrate = migrations[version]
        if not migrate then
            return nil, GetString(SI_SHOPPING_LIST_DATA_MIGRATION_FAILED)
        end
        local ok = pcall(migrate, candidate)
        if not ok then
            return nil, GetString(SI_SHOPPING_LIST_DATA_MIGRATION_FAILED)
        end
        local nextVersion = tonumber(candidate.saved.schemaVersion)
        if not nextVersion or nextVersion <= version then
            return nil, GetString(SI_SHOPPING_LIST_DATA_MIGRATION_FAILED)
        end
        version = nextVersion
    end

    local ok = pcall(function() candidate:Normalize() end)
    if not ok or not validateCandidate(candidate.saved) then
        return nil, GetString(SI_SHOPPING_LIST_DATA_MIGRATION_FAILED)
    end
    candidate.saved.schemaVersion = CURRENT_SCHEMA_VERSION
    return candidate.saved
end

function Data:GetPersistableData(source)
    local snapshot = copyPersistable(extractState(source or self.saved))
    if not snapshot then
        return nil
    end
    snapshot.recovery = nil
    return snapshot
end

local function getContentCounts(source)
    local counts = {
        listCount = 0,
        itemCount = 0,
        historyCount = 0,
        transactionCount = type(source.purchaseTransactions) == "table"
            and #source.purchaseTransactions or 0,
        meaningfulListCount = 0,
        meaningfulItemCount = 0,
    }
    local function countList(list)
        if type(list) ~= "table" then
            return
        end
        counts.listCount = counts.listCount + 1
        if zo_strtrim(list.name or "") ~= DEFAULT_LIST_NAME
            or zo_strtrim(list.note or "") ~= ""
            or (tonumber(list.totalSpent) or 0) > 0
            or (tonumber(list.transactionSpent) or 0) > 0
            or (tonumber(list.budget) or 0) > 0
            or list.recurring == true
            or (tonumber(list.resetCount) or 0) > 0
            or (tonumber(list.lastResetAt) or 0) > 0
        then
            counts.meaningfulListCount = counts.meaningfulListCount + 1
        end
        for _, item in ipairs(type(list.items) == "table" and list.items or {}) do
            counts.itemCount = counts.itemCount + 1
            local history = type(item.purchaseHistory) == "table"
                and item.purchaseHistory or {}
            counts.historyCount = counts.historyCount + math.max(
                #history,
                tonumber(item.purchaseCount) or 0
            )
            if zo_strtrim(item.note or "") ~= ""
                or (tonumber(item.purchased) or 0) > 0
                or (tonumber(item.totalSpent) or 0) > 0
                or item.maxUnitPrice ~= nil
                or item.match ~= nil
            then
                counts.meaningfulItemCount = counts.meaningfulItemCount + 1
            end
        end
    end
    for _, key in ipairs({ "lists", "archivedLists" }) do
        for _, list in ipairs(type(source[key]) == "table" and source[key] or {}) do
            countList(list)
        end
    end
    for _, action in ipairs(type(source.deletedActions) == "table"
        and source.deletedActions or {})
    do
        if action.kind == "list" then
            countList(action.list)
        elseif action.kind == "items" then
            for _, removed in ipairs(type(action.items) == "table" and action.items or {}) do
                local item = removed.item
                if type(item) == "table" then
                    counts.itemCount = counts.itemCount + 1
                    local history = type(item.purchaseHistory) == "table"
                        and item.purchaseHistory or {}
                    counts.historyCount = counts.historyCount + math.max(
                        #history,
                        tonumber(item.purchaseCount) or 0
                    )
                    counts.meaningfulItemCount = counts.meaningfulItemCount + 1
                end
            end
        end
    end
    return counts
end

local function snapshotHasMore(candidate, current)
    if type(candidate) ~= "table" then
        return false
    end
    for _, key in ipairs({
        "listCount",
        "itemCount",
        "historyCount",
        "transactionCount",
        "meaningfulListCount",
        "meaningfulItemCount",
    }) do
        if (tonumber(candidate[key]) or 0) > (tonumber(current[key]) or 0) then
            return true
        end
    end
    return false
end

function Data:GetLatestExternalSnapshot()
    local store = self.externalBackups
    if type(store) ~= "table" or type(store.snapshots) ~= "table" then
        return nil
    end
    for index = #store.snapshots, 1, -1 do
        local snapshot = store.snapshots[index]
        if type(snapshot) == "table"
            and (type(snapshot.code) == "string" or type(snapshot.data) == "table")
        then
            return snapshot
        end
    end
end

function Data:CreateExternalSnapshot(kind, source)
    local store = self.externalBackups
    if type(store) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_EXTERNAL_BACKUP_FAILED)
    end
    store.snapshots = type(store.snapshots) == "table" and store.snapshots or {}
    store.nextId = math.max(1, math.floor(tonumber(store.nextId) or 1))

    local data = self:GetPersistableData(source)
    if not data then
        return nil, GetString(SI_SHOPPING_LIST_EXTERNAL_BACKUP_FAILED)
    end
    local code = ShoppingListBackup.Encode(data)
    local counts = getContentCounts(data)
    local latest = store.snapshots[#store.snapshots]
    if code and type(latest) == "table" and latest.code == code then
        latest.kind = tostring(kind or "checkpoint")
        latest.createdAt = GetTimeStamp()
        latest.schemaVersion = tonumber(data.schemaVersion) or 1
        latest.addonVersion = GravvyShoppingList
            and GravvyShoppingList.GetBuildVersion
            and GravvyShoppingList:GetBuildVersion() or 0
        for key, value in pairs(counts) do
            latest[key] = value
        end
        return latest
    end
    local snapshot = {
        id = store.nextId,
        kind = tostring(kind or "checkpoint"),
        createdAt = GetTimeStamp(),
        schemaVersion = tonumber(data.schemaVersion) or 1,
        addonVersion = GravvyShoppingList and GravvyShoppingList.GetBuildVersion
            and GravvyShoppingList:GetBuildVersion() or 0,
        world = GetWorldName(),
        code = code,
    }
    if not code then
        snapshot.data = data
    end
    for key, value in pairs(counts) do
        snapshot[key] = value
    end
    store.nextId = store.nextId + 1
    store.snapshots[#store.snapshots + 1] = snapshot
    while #store.snapshots > MAX_EXTERNAL_SNAPSHOTS do
        table.remove(store.snapshots, 1)
    end
    return snapshot
end

function Data:DetectStartupDataLoss(startupSnapshot, previousSnapshot)
    local current = getContentCounts(self.saved)
    if snapshotHasMore(startupSnapshot, current) then
        self.pendingExternalRestore = startupSnapshot
    elseif snapshotHasMore(previousSnapshot, current) then
        self.pendingExternalRestore = previousSnapshot
    end
    if not self.pendingExternalRestore then
        local snapshots = self:GetSafetySnapshots()
        for index = #snapshots, 1, -1 do
            local safety = snapshots[index]
            local recovered = type(safety) == "table"
                and type(safety.code) == "string"
                and ShoppingListBackup.Decode(safety.code) or nil
            if recovered then
                local candidate = {
                    code = safety.code,
                    kind = "internal_safety",
                }
                for key, value in pairs(getContentCounts(recovered)) do
                    candidate[key] = value
                end
                if snapshotHasMore(candidate, current) then
                    self.pendingExternalRestore = candidate
                    break
                end
            end
        end
    end
    return self.pendingExternalRestore ~= nil
end

function Data:RestorePendingExternalSnapshot()
    local pending = self.pendingExternalRestore
    if not pending then
        return false, nil, false
    end
    local snapshot, message
    if type(pending.code) == "string" then
        snapshot, message = ShoppingListBackup.Decode(pending.code)
    elseif type(pending.data) == "table" then
        snapshot = deepCopy(pending.data)
    end
    if not snapshot then
        return false, message, true
    end
    local ok
    ok, message = self:RestoreBackup(snapshot)
    if not ok then
        return false, message, true
    end
    self.pendingExternalRestore = nil
    self:CreateExternalSnapshot("automatic_restore", self.saved)
    return true, nil, true
end

function Data:CreateDeactivationBackup()
    if self.pendingExternalRestore then
        return false
    end
    return self:CreateExternalSnapshot("checkpoint", self.saved) ~= nil
end

function Data:CreateSafetySnapshot(kind, source)
    local snapshot = self:GetPersistableData(source)
    if not snapshot then
        return false, GetString(SI_SHOPPING_LIST_SAFETY_CREATE_FAILED)
    end
    local code = ShoppingListBackup.Encode(snapshot)
    if not code then
        return false, GetString(SI_SHOPPING_LIST_SAFETY_CREATE_FAILED)
    end

    local recovery = self.saved.recovery
    if type(recovery) ~= "table" then
        recovery = {}
        self.saved.recovery = recovery
    end
    recovery.nextId = math.max(1, math.floor(tonumber(recovery.nextId) or 1))
    recovery.snapshots = type(recovery.snapshots) == "table" and recovery.snapshots or {}
    recovery.snapshots[#recovery.snapshots + 1] = {
        id = recovery.nextId,
        kind = tostring(kind or "manual"),
        createdAt = GetTimeStamp(),
        sourceSchema = tonumber(snapshot.schemaVersion) or 1,
        addonVersion = GravvyShoppingList and GravvyShoppingList.GetBuildVersion
            and GravvyShoppingList:GetBuildVersion() or 0,
        world = GetWorldName(),
        code = code,
    }
    recovery.nextId = recovery.nextId + 1
    while #recovery.snapshots > MAX_RECOVERY_SNAPSHOTS do
        table.remove(recovery.snapshots, 1)
    end
    return true
end

function Data:GetSafetySnapshots()
    local recovery = self.saved.recovery
    return type(recovery) == "table" and type(recovery.snapshots) == "table"
        and recovery.snapshots or {}
end

function Data:Migrate()
    local version = tonumber(self.saved.schemaVersion) or 1
    if version < CURRENT_SCHEMA_VERSION then
        local saved, message = self:CreateSafetySnapshot("pre_migration")
        if not saved then
            return false, message
        end
    end

    local candidate, message = self:PrepareCandidate(extractState(self.saved))
    if not candidate then
        return false, message
    end
    applyState(self.saved, candidate)
    return true
end

local function isPristineDefault(saved)
    if #saved.lists ~= 1 or #saved.archivedLists ~= 0 then
        return false
    end
    local list = saved.lists[1]
    return list.name == DEFAULT_LIST_NAME
        and #list.items == 0
        and (list.note or "") == ""
        and (tonumber(list.totalSpent) or 0) == 0
end

local function hasLegacyListContent(saved)
    if type(saved.items) == "table" and #saved.items > 0 then
        return true
    end
    for _, key in ipairs({ "lists", "archivedLists" }) do
        local lists = saved[key]
        if type(lists) == "table" then
            for _, list in ipairs(lists) do
                if type(list) == "table" then
                    local name = zo_strtrim(list.name or "")
                    if name ~= "" and name ~= DEFAULT_LIST_NAME then
                        return true
                    end
                    if type(list.items) == "table" and #list.items > 0 then
                        return true
                    end
                    if zo_strtrim(list.note or "") ~= ""
                        or (tonumber(list.totalSpent) or 0) > 0
                        or (tonumber(list.budget) or 0) > 0
                    then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function Data:RecoverLegacyData()
    local staged = GravvyShoppingListLegacySavedVariables
    if type(staged) ~= "table" or type(staged.saved) ~= "table" then
        return false
    end
    if not hasLegacyListContent(staged.saved) then
        return false
    end

    local sourceCode = ShoppingListBackup.Encode(self:GetPersistableData(staged.saved))
    if not sourceCode then
        self.legacyRecoveryError = GetString(SI_SHOPPING_LIST_LEGACY_RECOVERY_FAILED)
        return false
    end
    local fingerprint = tostring(#sourceCode) .. ":" .. string.sub(sourceCode, -32)
    local legacyRecovery = self.saved.legacyRecovery
    if type(legacyRecovery) ~= "table" then
        legacyRecovery = {}
        self.saved.legacyRecovery = legacyRecovery
    end
    legacyRecovery.imports = type(legacyRecovery.imports) == "table"
        and legacyRecovery.imports or {}
    if legacyRecovery.imports[fingerprint] then
        return false
    end

    local legacy, message = self:PrepareCandidate(staged.saved)
    if not legacy then
        self.legacyRecoveryError = message or GetString(SI_SHOPPING_LIST_LEGACY_RECOVERY_FAILED)
        return false
    end
    local snapshotted, snapshotMessage = self:CreateSafetySnapshot("pre_legacy_recovery")
    if not snapshotted then
        self.legacyRecoveryError = snapshotMessage
        return false
    end

    local candidate = extractState(self.saved)
    local working = setmetatable({ saved = candidate }, { __index = self })
    local removeDefault = isPristineDefault(candidate)
    if removeDefault then
        candidate.lists = {}
    end

    local recoveredCount = 0
    local firstRecoveredId
    local function appendLists(source, archived)
        local target = archived and candidate.archivedLists or candidate.lists
        for _, sourceList in ipairs(source) do
            local list = deepCopy(sourceList)
            list.id = candidate.nextListId
            candidate.nextListId = candidate.nextListId + 1
            list.name = working:GetUniqueListName(list.name)
            for _, item in ipairs(list.items) do
                item.id = candidate.nextItemId
                candidate.nextItemId = candidate.nextItemId + 1
            end
            if archived then
                list.archivedAt = tonumber(list.archivedAt) or GetTimeStamp()
            else
                list.archivedAt = nil
                firstRecoveredId = firstRecoveredId or list.id
            end
            target[#target + 1] = list
            recoveredCount = recoveredCount + 1
        end
    end

    local ok = pcall(function()
        appendLists(legacy.lists, false)
        appendLists(legacy.archivedLists, true)
        if #candidate.lists == 0 then
            candidate.lists[1] = deepCopy(defaults.lists[1])
            candidate.lists[1].id = candidate.nextListId
            candidate.nextListId = candidate.nextListId + 1
        elseif removeDefault and firstRecoveredId then
            candidate.selectedListId = firstRecoveredId
        end
        candidate.legacyRecovery = candidate.legacyRecovery or {}
        candidate.legacyRecovery.imports = candidate.legacyRecovery.imports or {}
        candidate.legacyRecovery.imports[fingerprint] = {
            recoveredAt = GetTimeStamp(),
            listCount = recoveredCount,
            source = staged.source or "ShoppingList",
            world = staged.world or GetWorldName(),
            backupCode = sourceCode,
        }
    end)
    if not ok then
        self.legacyRecoveryError = GetString(SI_SHOPPING_LIST_LEGACY_RECOVERY_FAILED)
        return false
    end

    local prepared, prepareMessage = self:PrepareCandidate(candidate)
    if not prepared then
        self.legacyRecoveryError = prepareMessage
        return false
    end
    applyState(self.saved, prepared)
    self.legacyRecoveredCount = recoveredCount
    return true
end

function Data:RestoreSafetySnapshot(id)
    for _, entry in ipairs(self:GetSafetySnapshots()) do
        if entry.id == id then
            local decoded, message = ShoppingListBackup.Decode(entry.code)
            if not decoded then
                return false, message
            end
            return self:RestoreBackup(decoded)
        end
    end
    return false, GetString(SI_SHOPPING_LIST_SAFETY_MISSING)
end

function Data:GetItems()
    return self:GetCurrentList().items
end

function Data:GetLists()
    return self.saved.lists
end

function Data:GetDisplayLists()
    local result = {}
    for index, list in ipairs(self.saved.lists) do
        result[#result + 1] = { list = list, index = index }
    end
    table.sort(result, function(left, right)
        if left.list.pinned ~= right.list.pinned then
            return left.list.pinned == true
        end
        return left.index < right.index
    end)
    for index, entry in ipairs(result) do
        result[index] = entry.list
    end
    return result
end

function Data:GetArchivedLists()
    return self.saved.archivedLists
end

function Data:FindList(id)
    for index, list in ipairs(self.saved.lists) do
        if list.id == id then
            return list, index
        end
    end
end

function Data:FindArchivedList(id)
    for index, list in ipairs(self.saved.archivedLists) do
        if list.id == id then
            return list, index
        end
    end
end

function Data:GetCurrentList()
    local list = self:FindList(self.saved.selectedListId)
    if not list then
        list = self.saved.lists[1]
        self.saved.selectedListId = list.id
    end
    return list
end

function Data:EnsureActiveTripList()
    for _, list in ipairs(self.saved.lists) do
        if list.tripActive then
            return
        end
    end
    self:GetCurrentList().tripActive = true
end

function Data:IsMultiListTripEnabled()
    return self.saved.settings.multiListTrips == true
end

function Data:SetMultiListTripEnabled(enabled)
    self.saved.settings.multiListTrips = enabled == true
    if enabled then
        self:GetCurrentList().tripActive = true
        self:EnsureActiveTripList()
    end
end

function Data:SetListTripActive(id, active)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if not active and list.tripActive then
        local activeCount = 0
        for _, candidate in ipairs(self.saved.lists) do
            if candidate.tripActive then
                activeCount = activeCount + 1
            end
        end
        if activeCount == 1 then
            return false, GetString(SI_SHOPPING_LIST_ERROR_TRIP_LIST_REQUIRED)
        end
    end
    list.tripActive = active == true
    return true
end

function Data:SetAllTripListsActive()
    for _, list in ipairs(self.saved.lists) do
        list.tripActive = true
    end
end

function Data:SetOnlyTripListActive(id)
    local selected = self:FindList(id)
    if not selected then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    for _, list in ipairs(self.saved.lists) do
        list.tripActive = list.id == id
    end
    return true
end

function Data:GetShoppingLists()
    if not self:IsMultiListTripEnabled() then
        return { self:GetCurrentList() }
    end

    local result = {}
    for _, list in ipairs(self.saved.lists) do
        if list.tripActive then
            result[#result + 1] = list
        end
    end
    return result
end

function Data:GetShoppingItems()
    local result = {}
    for _, list in ipairs(self:GetShoppingLists()) do
        for _, item in ipairs(list.items) do
            result[#result + 1] = item
        end
    end
    return result
end

function Data:SetInventory(inventory)
    self.inventory = inventory
end

function Data:GetTargetMode(item)
    return ShoppingListModel:NormalizeTargetMode(item and item.targetMode)
end

function Data:GetOwnedQuantity(item)
    local counts = self.inventory and self.inventory:GetCounts(item)
    return math.max(0, tonumber(counts and counts.total) or 0)
end

function Data:GetRemainingQuantity(item)
    if not item then
        return 0
    end
    if self:GetTargetMode(item) == "own" then
        return math.max(0, item.desired - self:GetOwnedQuantity(item))
    end
    if item.completed then
        return 0
    end
    return math.max(0, item.desired - item.purchased)
end

function Data:IsItemComplete(item)
    return item ~= nil and self:GetRemainingQuantity(item) == 0
end

function Data:RefreshInventoryCompletion(item)
    if item and self:GetTargetMode(item) == "own" then
        item.completed = self:GetOwnedQuantity(item) >= item.desired
    end
end

function Data:SelectList(id)
    local list = self:FindList(id)
    if not list then
        return false
    end
    self.saved.selectedListId = list.id
    self:NotifyUpdate("list", {
        action = "selected",
        listId = list.id,
    })
    return true
end

function Data:MoveList(id, direction)
    local _, index = self:FindList(id)
    if not index then
        return false
    end

    local target = zo_clamp(index + direction, 1, #self.saved.lists)
    if target == index then
        return false
    end
    self.saved.lists[index], self.saved.lists[target] =
        self.saved.lists[target], self.saved.lists[index]
    self:NotifyUpdate("list", {
        action = "moved",
        listId = id,
        fromIndex = index,
        toIndex = target,
    })
    return true
end

function Data:ListNameExists(name, exceptId)
    local normalized = zo_strlower(zo_strtrim(name or ""))
    local collections = { self.saved.lists, self.saved.archivedLists }
    for _, lists in ipairs(collections) do
        for _, list in ipairs(lists) do
            if list.id ~= exceptId and zo_strlower(list.name) == normalized then
                return true
            end
        end
    end
    return false
end

function Data:GetUniqueListName(baseName, exceptId)
    local name = baseName
    local suffix = 2
    while self:ListNameExists(name, exceptId) do
        local ending = " " .. tostring(suffix)
        name = string.sub(
            baseName,
            1,
            ShoppingListModel.MAX_NAME_LENGTH - #ending
        ) .. ending
        suffix = suffix + 1
    end
    return name
end

function Data:GetStoredListCount()
    local count = #self.saved.lists + #self.saved.archivedLists
    for _, action in ipairs(self.saved.deletedActions or {}) do
        if action.kind == "list" and action.list then
            count = count + 1
        end
    end
    return count
end

function Data:AddList(name, note, category, suppressUpdate)
    name = zo_strtrim(name or "")
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_LIST_NAME)
    end
    if #name > ShoppingListModel.MAX_NAME_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NAME_TOO_LONG)
    end
    if type(note) ~= "nil" and type(note) ~= "string" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    if #(note or "") > ShoppingListModel.MAX_NOTE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    if category ~= nil and (type(category) ~= "string"
        or #category > ShoppingListModel.MAX_CATEGORY_LENGTH)
    then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_CATEGORY_TOO_LONG)
    end
    if self:GetStoredListCount() >= ShoppingListModel.MAX_LISTS then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_TOO_MANY_LISTS)
    end
    if self:ListNameExists(name) then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_NAME_EXISTS)
    end

    local list = {
        id = self.saved.nextListId,
        name = name,
        note = normalizeNote(note),
        items = {},
        totalSpent = 0,
        transactionSpent = 0,
        budget = nil,
        tripActive = self:IsMultiListTripEnabled(),
        recurring = false,
        resetCount = 0,
        favorite = false,
        pinned = false,
        category = normalizeCategory(category),
        itemSearch = "",
        itemSort = DEFAULT_ITEM_SORT,
        itemSortAscending = true,
    }
    self.saved.nextListId = self.saved.nextListId + 1
    self.saved.lists[#self.saved.lists + 1] = list
    self.saved.selectedListId = list.id
    if not suppressUpdate then
        self:NotifyUpdate("list", {
            action = "created",
            listId = list.id,
        })
    end
    return list
end

function Data:ImportList(name, items, note, recurring)
    name = zo_strtrim(name or "")
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_NO_NAME)
    end
    if #name > ShoppingListModel.MAX_NAME_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NAME_TOO_LONG)
    end
    if type(items) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_NO_ITEMS)
    end
    if note ~= nil and type(note) ~= "string" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
    end
    if #(note or "") > ShoppingListModel.MAX_NOTE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    if recurring ~= nil and type(recurring) ~= "boolean" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_RECURRING)
    end
    if #items > ShoppingListModel.MAX_ITEMS_PER_LIST then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_TOO_MANY_ITEMS)
    end

    local validated = {}
    for _, source in ipairs(items) do
        if type(source) ~= "table" or type(source.name) ~= "string" then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
        end

        local itemName = zo_strtrim(source.name)
        local quantity = tonumber(source.desired)
        local itemLink = source.itemLink or ""
        local itemNote = source.note or ""
        local maxUnitPrice = source.maxUnitPrice
        local targetMode = source.targetMode or "buy"
        if itemName == "" or #itemName > ShoppingListModel.MAX_NAME_LENGTH
            or not ShoppingListModel:IsWholeNumber(
                quantity,
                1,
                ShoppingListModel.MAX_QUANTITY
            )
            or type(itemLink) ~= "string" or type(itemNote) ~= "string"
            or #itemLink > ShoppingListModel.MAX_LINK_LENGTH
            or #itemNote > ShoppingListModel.MAX_NOTE_LENGTH
            or not ShoppingListModel:IsValidTargetMode(targetMode)
            or not ShoppingListModel:IsValidMatchingRule(source.match)
        then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
        end
        if maxUnitPrice ~= nil then
            maxUnitPrice = tonumber(maxUnitPrice)
            if not ShoppingListModel:IsWholeNumber(
                maxUnitPrice,
                1,
                ShoppingListModel.MAX_PRICE
            )
            then
                return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
            end
        end
        if itemLink ~= "" then
            local _, _, linkType = ZO_LinkHandler_ParseLink(itemLink)
            local linkedName = zo_strtrim(GetItemLinkName(itemLink) or "")
            if linkType ~= ITEM_LINK_TYPE or linkedName == "" then
                return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
            end
            itemName = linkedName
        end

        validated[#validated + 1] = {
            name = itemName,
            quantity = quantity,
            itemLink = itemLink,
            note = itemNote,
            targetMode = targetMode,
            maxUnitPrice = maxUnitPrice,
            match = ShoppingListModel:NormalizeMatchingRule(source.match),
        }
    end

    local snapshotted, snapshotMessage = self:CreateSafetySnapshot("pre_import")
    if not snapshotted then
        return nil, snapshotMessage
    end

    local list, createdOrMessage = self:AddListWithItems(
        self:GetUniqueListName(name),
        note or "",
        validated,
        true
    )
    if not list then
        return nil, createdOrMessage
    end
    list.recurring = recurring == true
    if list.recurring then
        self:NotifyUpdate("list", {
            action = "updated",
            listId = list.id,
            field = "recurring",
        })
    end
    return list
end

function Data:DuplicateList(id, name, note, category, selectList)
    local source = self:FindList(id)
    if not source then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    name = zo_strtrim(name or "")
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_LIST_NAME)
    end
    if #name > ShoppingListModel.MAX_NAME_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NAME_TOO_LONG)
    end
    local copiedNote = note ~= nil and note or source.note or ""
    if type(copiedNote) ~= "string"
        or #copiedNote > ShoppingListModel.MAX_NOTE_LENGTH
    then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    local copiedCategory = category ~= nil and category or source.category or ""
    if type(copiedCategory) ~= "string"
        or #copiedCategory > ShoppingListModel.MAX_CATEGORY_LENGTH
    then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_CATEGORY_TOO_LONG)
    end
    if self:GetStoredListCount() >= ShoppingListModel.MAX_LISTS then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_TOO_MANY_LISTS)
    end
    if self:ListNameExists(name) then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_NAME_EXISTS)
    end

    local copy = {
        id = self.saved.nextListId,
        name = name,
        note = normalizeNote(copiedNote),
        items = {},
        totalSpent = 0,
        transactionSpent = 0,
        budget = source.budget,
        tripActive = self:IsMultiListTripEnabled(),
        recurring = source.recurring == true,
        resetCount = 0,
        favorite = false,
        pinned = false,
        category = normalizeCategory(copiedCategory),
        itemSearch = "",
        itemSort = source.itemSort or DEFAULT_ITEM_SORT,
        itemSortAscending = source.itemSortAscending ~= false,
    }
    self.saved.nextListId = self.saved.nextListId + 1

    for _, item in ipairs(source.items) do
        local match = {}
        for key, value in pairs(item.match or {}) do
            match[key] = value
        end

        copy.items[#copy.items + 1] = {
            id = self.saved.nextItemId,
            name = item.name,
            note = item.note,
            normalizedName = item.normalizedName,
            nameHash = item.nameHash,
            itemLink = item.itemLink,
            itemId = item.itemId,
            addedAt = GetTimeStamp(),
            desired = item.desired,
            purchased = 0,
            targetMode = ShoppingListModel:NormalizeTargetMode(item.targetMode),
            completed = false,
            purchaseHistory = {},
            purchaseCount = 0,
            totalSpent = 0,
            pricedQuantity = 0,
            maxUnitPrice = item.maxUnitPrice,
            match = match,
        }
        self.saved.nextItemId = self.saved.nextItemId + 1
    end

    self.saved.lists[#self.saved.lists + 1] = copy
    if selectList ~= false then
        self.saved.selectedListId = copy.id
    end
    self:NotifyUpdate("list", {
        action = "duplicated",
        listId = copy.id,
        sourceListId = source.id,
    })
    return copy
end

function Data:RenameList(id, name)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    name = zo_strtrim(name or "")
    if name == "" then
        return false, GetString(SI_SHOPPING_LIST_ERROR_ENTER_LIST_NAME)
    end
    if #name > ShoppingListModel.MAX_NAME_LENGTH then
        return false, GetString(SI_SHOPPING_LIST_ERROR_NAME_TOO_LONG)
    end
    if self:ListNameExists(name, id) then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_NAME_EXISTS)
    end
    list.name = name
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "name",
    })
    return true
end

function Data:UpdateListNote(id, note)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(note) ~= "string" or #note > ShoppingListModel.MAX_NOTE_LENGTH then
        return false, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    list.note = note
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "note",
    })
    return true
end

function Data:UpdateListCategory(id, category)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(category) ~= "string"
        or #category > ShoppingListModel.MAX_CATEGORY_LENGTH
    then
        return false, GetString(SI_SHOPPING_LIST_ERROR_CATEGORY_TOO_LONG)
    end
    list.category = normalizeCategory(category)
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "category",
    })
    return true
end

function Data:SetListFavorite(id, favorite)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(favorite) ~= "boolean" then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_LIST_ORGANIZATION)
    end
    list.favorite = favorite
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "favorite",
    })
    return true
end

function Data:SetListPinned(id, pinned)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(pinned) ~= "boolean" then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_LIST_ORGANIZATION)
    end
    list.pinned = pinned
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "pinned",
    })
    return true
end

function Data:UpdateListBudget(id, value)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    local budget = tonumber(value)
    if budget ~= nil and budget ~= 0 and not ShoppingListModel:IsWholeNumber(
        budget,
        1,
        ShoppingListModel.MAX_PRICE
    ) then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_PRICE)
    end
    budget = budget or 0
    list.budget = budget > 0 and budget or nil
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "budget",
    })
    return true
end

function Data:SetListRecurring(id, recurring)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(recurring) ~= "boolean" then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_RECURRING)
    end
    list.recurring = recurring
    self:NotifyUpdate("list", {
        action = "updated",
        listId = list.id,
        field = "recurring",
    })
    return true, list
end

function Data:ListHasPurchaseProgress(list)
    list = type(list) == "table" and list or self:FindList(list)
    if not list then
        return false
    end
    for _, item in ipairs(list.items) do
        if (tonumber(item.purchased) or 0) > 0
            or (self:GetTargetMode(item) == "buy" and item.completed == true)
        then
            return true
        end
    end
    return false
end

function Data:ResetListProgress(id)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if not self:ListHasPurchaseProgress(list) then
        return false, GetString(SI_SHOPPING_LIST_STATUS_NO_PROGRESS_TO_RESET)
    end

    local snapshotted, snapshotMessage = self:CreateSafetySnapshot(
        "pre_progress_reset"
    )
    if not snapshotted then
        return false, snapshotMessage
    end

    local resetItems = 0
    for _, item in ipairs(list.items) do
        if (tonumber(item.purchased) or 0) > 0
            or (self:GetTargetMode(item) == "buy" and item.completed == true)
        then
            resetItems = resetItems + 1
        end
        item.purchased = 0
        if self:GetTargetMode(item) == "own" then
            item.completed = self:GetOwnedQuantity(item) >= item.desired
        else
            item.completed = false
        end
    end
    list.resetCount = math.max(0, tonumber(list.resetCount) or 0) + 1
    list.lastResetAt = GetTimeStamp()
    self:NotifyUpdate("list", {
        action = "progressReset",
        listId = list.id,
        itemCount = resetItems,
    })
    return true, resetItems, list
end

function Data:PushDeletedAction(action)
    action.deletedAt = GetTimeStamp()
    local actions = self.saved.deletedActions
    actions[#actions + 1] = action
    while #actions > MAX_DELETED_ACTIONS do
        table.remove(actions, 1)
    end
end

function Data:CanUndoDeletion()
    return #self.saved.deletedActions > 0
end

function Data:DeleteList(id)
    if #self.saved.lists == 1 then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_REQUIRED)
    end

    local list, index = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    self:PushDeletedAction({
        kind = "list",
        list = list,
        index = index,
    })
    table.remove(self.saved.lists, index)
    local selected = self.saved.lists[math.min(index, #self.saved.lists)]
    self.saved.selectedListId = selected.id
    self:EnsureActiveTripList()
    self:NotifyUpdate("list", {
        action = "deleted",
        listId = list.id,
        name = list.name,
        selectedListId = selected.id,
    })
    return true, selected
end

function Data:ArchiveList(id)
    local list, index = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    table.remove(self.saved.lists, index)
    list.archivedAt = GetTimeStamp()
    self.saved.archivedLists[#self.saved.archivedLists + 1] = list

    if #self.saved.lists == 0 then
        local replacement = {
            id = self.saved.nextListId,
            name = self:GetUniqueListName(DEFAULT_LIST_NAME),
            note = "",
            items = {},
            totalSpent = 0,
            transactionSpent = 0,
            budget = nil,
        }
        self.saved.nextListId = self.saved.nextListId + 1
        self.saved.lists[1] = replacement
    end

    local selected = self.saved.lists[math.min(index, #self.saved.lists)]
    self.saved.selectedListId = selected.id
    self:EnsureActiveTripList()
    self:NotifyUpdate("list", {
        action = "archived",
        listId = list.id,
        name = list.name,
        selectedListId = selected.id,
    })
    return true, list, selected
end

function Data:RestoreList(id)
    local list, index = self:FindArchivedList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_ARCHIVED_LIST_MISSING)
    end
    if self:ListNameExists(list.name, list.id) then
        list.name = self:GetUniqueListName(zo_strformat(
            GetString(SI_SHOPPING_LIST_RESTORED_LIST_NAME),
            list.name
        ), list.id)
    end
    table.remove(self.saved.archivedLists, index)
    list.archivedAt = nil
    self.saved.lists[#self.saved.lists + 1] = list
    self.saved.selectedListId = list.id
    self:NotifyUpdate("list", {
        action = "restored",
        listId = list.id,
    })
    return true, list
end

function Data:GetSettings()
    return self.saved.settings
end

function Data:GetBackupData()
    local snapshot = self:GetPersistableData(self.saved)
    return snapshot or {}
end

function Data:RestoreBackup(snapshot)
    if type(snapshot) ~= "table" then
        return false, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end
    local sourceVersion = tonumber(snapshot.schemaVersion) or 1
    if sourceVersion == CURRENT_SCHEMA_VERSION
        and not self:ValidateBackupSnapshot(snapshot)
    then
        return false, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end

    local candidate, candidateMessage = self:PrepareCandidate(snapshot)
    if not candidate or not self:ValidateBackupSnapshot(candidate) then
        return false, candidateMessage or GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end
    local snapshotted, snapshotMessage = self:CreateSafetySnapshot("pre_restore")
    if not snapshotted then
        return false, snapshotMessage
    end

    local previous = extractState(self.saved)
    local recoveryReference = self.saved.recovery
    local legacyRecoveryReference = self.saved.legacyRecovery
    local function apply(restored)
        restored = deepCopy(restored)
        restored.recovery = recoveryReference
        restored.legacyRecovery = legacyRecoveryReference
        applyState(self.saved, restored)
    end

    local ok = pcall(apply, candidate)
    if not ok then
        applyState(self.saved, previous)
        return false, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end
    self:NotifyUpdate("list", {
        action = "restoredAll",
        selectedListId = self.saved.selectedListId,
    })
    return true
end

function Data:GetItemFilter()
    return self.saved.settings.itemFilter or "all"
end

function Data:SetItemFilter(filter)
    if not VALID_FILTERS[filter] then
        return false
    end
    self.saved.settings.itemFilter = filter
    return true
end

function Data:ItemIsOverTarget(item)
    if not item.maxUnitPrice then
        return false
    end
    local history = item.purchaseHistory or {}
    local lastPurchase = history[#history]
    return lastPurchase ~= nil
        and (tonumber(lastPurchase.unitPrice) or 0) > item.maxUnitPrice
end

function Data:ItemHasMatchingRules(item)
    local rule = item.match or {}
    return rule.setId ~= nil
        or (rule.setName ~= nil and rule.setName ~= "")
        or (rule.traitType ~= nil and rule.traitType ~= ITEM_TRAIT_TYPE_NONE)
        or (rule.qualityMode ~= nil and rule.qualityMode ~= "any")
        or (rule.levelMode ~= nil and rule.levelMode ~= "any")
end

function Data:ItemPassesFilter(item, filter)
    filter = filter or self:GetItemFilter()
    if filter == "needed" then
        return not self:IsItemComplete(item)
    elseif filter == "completed" then
        return self:IsItemComplete(item)
    elseif filter == "overTarget" then
        return self:ItemIsOverTarget(item)
    elseif filter == "restricted" then
        return self:ItemHasMatchingRules(item)
    end
    return true
end

function Data:GetItemSearch()
    return self:GetCurrentList().itemSearch or ""
end

function Data:SetItemSearch(search)
    if type(search) ~= "string"
        or #search > ShoppingListModel.MAX_NAME_LENGTH
    then
        return false, GetString(SI_SHOPPING_LIST_ERROR_SEARCH_TOO_LONG)
    end
    self:GetCurrentList().itemSearch = zo_strtrim(search)
    return true
end

function Data:GetItemSort()
    local list = self:GetCurrentList()
    return list.itemSort or DEFAULT_ITEM_SORT, list.itemSortAscending ~= false
end

function Data:SetItemSort(sort, ascending)
    if not ShoppingListModel.ITEM_SORTS[sort] or type(ascending) ~= "boolean" then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_SORT)
    end
    local list = self:GetCurrentList()
    list.itemSort = sort
    list.itemSortAscending = ascending
    return true
end

function Data:ItemPassesSearch(item, search)
    search = zo_strlower(zo_strtrim(search or ""))
    if search == "" then
        return true
    end
    local rule = item.match or {}
    local haystack = table.concat({
        item.normalizedName or normalizeName(item.name),
        zo_strlower(item.note or ""),
        rule.normalizedSetName or normalizeName(rule.setName),
    }, "\n")
    for term in string.gmatch(search, "%S+") do
        if not string.find(haystack, term, 1, true) then
            return false
        end
    end
    return true
end

local function itemSortValue(data, item, sort)
    if sort == "name" then
        return item.normalizedName or normalizeName(item.name)
    elseif sort == "quantity" then
        return tonumber(item.desired) or 0
    elseif sort == "owned" then
        return data:GetOwnedQuantity(item)
    elseif sort == "completion" then
        return data:IsItemComplete(item) and 1 or 0
    elseif sort == "price" then
        return tonumber(item.maxUnitPrice)
    end
    return tonumber(item.addedAt) or tonumber(item.id) or 0
end

function Data:GetFilteredShoppingItems()
    local decorated = {}
    local filter = self:GetItemFilter()
    local search = self:GetItemSearch()
    local sort, ascending = self:GetItemSort()
    for _, item in ipairs(self:GetShoppingItems()) do
        if self:ItemPassesFilter(item, filter)
            and self:ItemPassesSearch(item, search)
        then
            decorated[#decorated + 1] = {
                item = item,
                value = itemSortValue(self, item, sort),
            }
        end
    end

    table.sort(decorated, function(left, right)
        if left.value == nil or right.value == nil then
            if left.value == nil and right.value ~= nil then
                return false
            elseif left.value ~= nil and right.value == nil then
                return true
            end
        elseif left.value ~= right.value then
            if ascending then
                return left.value < right.value
            end
            return left.value > right.value
        end
        local leftName = left.item.normalizedName or normalizeName(left.item.name)
        local rightName = right.item.normalizedName or normalizeName(right.item.name)
        if leftName ~= rightName then
            return leftName < rightName
        end
        return left.item.id < right.item.id
    end)

    local result = {}
    for index, entry in ipairs(decorated) do
        result[index] = entry.item
    end
    return result
end

function Data:BuildItemCandidate(source)
    if type(source) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
    end

    local name = source.name
    local itemLink = source.itemLink
    local note = source.note
    local quantity = source.quantity ~= nil and source.quantity or source.desired
    local targetMode = source.targetMode or "buy"

    if type(name) ~= "string" and name ~= nil then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_ITEM_NAME)
    end
    if type(itemLink) ~= "string" and itemLink ~= nil then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_LINK)
    end
    if type(note) ~= "string" and note ~= nil then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end

    name = zo_strtrim(name or "")
    itemLink = itemLink or ""
    quantity = tonumber(quantity) or 1

    if name == "" and itemLink ~= "" then
        name = GetItemLinkName(itemLink)
    end
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_ITEM_NAME)
    end
    if #name > ShoppingListModel.MAX_NAME_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ITEM_NAME_TOO_LONG)
    end
    if #itemLink > ShoppingListModel.MAX_LINK_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LINK_TOO_LONG)
    end
    if #(note or "") > ShoppingListModel.MAX_NOTE_LENGTH then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    if not ShoppingListModel:IsWholeNumber(
        quantity,
        1,
        ShoppingListModel.MAX_QUANTITY
    ) then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_QUANTITY)
    end
    if not ShoppingListModel:IsValidTargetMode(targetMode) then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_TARGET_MODE)
    end
    if itemLink ~= "" then
        local _, _, linkType = ZO_LinkHandler_ParseLink(itemLink)
        if linkType ~= ITEM_LINK_TYPE then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_LINK)
        end
    end

    local maxUnitPrice = source.maxUnitPrice
    if maxUnitPrice ~= nil then
        maxUnitPrice = tonumber(maxUnitPrice)
        if not ShoppingListModel:IsWholeNumber(
            maxUnitPrice,
            1,
            ShoppingListModel.MAX_PRICE
        ) then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_PRICE)
        end
    end

    local details = readLinkDetails(itemLink)
    local match = source.match
    if match ~= nil then
        match = ShoppingListModel:NormalizeMatchingRule(match)
        if not match then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_MATCH)
        end
    else
        match = {
            setId = details.setId,
            setName = details.setName,
            normalizedSetName = details.normalizedSetName,
            traitType = details.traitType,
            qualityMode = "any",
            quality = details.quality,
            levelMode = "any",
            level = details.level,
            championPoints = details.championPoints,
        }
    end
    if source.ignoreLinkTrait then
        match.traitType = nil
    end

    return {
        id = self.saved.nextItemId,
        name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name),
        note = normalizeNote(note),
        normalizedName = normalizeName(name),
        nameHash = source.nameHash,
        itemLink = itemLink,
        itemId = details.itemId,
        addedAt = GetTimeStamp(),
        desired = quantity,
        purchased = 0,
        targetMode = targetMode,
        completed = false,
        purchaseHistory = {},
        purchaseCount = 0,
        totalSpent = 0,
        pricedQuantity = 0,
        maxUnitPrice = maxUnitPrice,
        match = match,
    }
end

function Data:FindDuplicateItem(listId, candidate)
    local list = self:FindList(listId)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    for index, item in ipairs(list.items) do
        if ShoppingListModel:ItemsAreDuplicates(item, candidate) then
            return item, nil, index
        end
    end
    return nil
end

function Data:CountDuplicateSources(listId, sources)
    local list = self:FindList(listId)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(sources) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
    end

    local candidates = {}
    local duplicateCount = 0
    for _, source in ipairs(sources) do
        local candidate, message = self:BuildItemCandidate(source)
        if not candidate then
            return nil, message
        end

        local duplicate = false
        for _, item in ipairs(list.items) do
            if ShoppingListModel:ItemsAreDuplicates(item, candidate) then
                duplicate = true
                break
            end
        end
        if not duplicate then
            for _, prior in ipairs(candidates) do
                if ShoppingListModel:ItemsAreDuplicates(prior, candidate) then
                    duplicate = true
                    break
                end
            end
        end
        if duplicate then
            duplicateCount = duplicateCount + 1
        end
        candidates[#candidates + 1] = candidate
    end
    return duplicateCount
end

function Data:AddPreparedItemToList(listId, source, duplicatePolicy, suppressUpdate)
    local list = self:FindList(listId)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    duplicatePolicy = duplicatePolicy or "keep"
    if not ShoppingListModel:IsValidDuplicatePolicy(duplicatePolicy) then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_DUPLICATE_POLICY)
    end

    local item, message = self:BuildItemCandidate(source)
    if not item then
        return nil, message
    end

    local duplicate = self:FindDuplicateItem(list.id, item)
    if duplicate then
        if duplicatePolicy == "prompt" then
            return nil, GetString(SI_SHOPPING_LIST_STATUS_DUPLICATE_FOUND), duplicate
        elseif duplicatePolicy == "merge" then
            local desired = duplicate.desired + item.desired
            if desired > ShoppingListModel.MAX_QUANTITY then
                return nil, GetString(SI_SHOPPING_LIST_ERROR_DUPLICATE_MERGE_QUANTITY)
            end
            duplicate.desired = desired
            if self:GetTargetMode(duplicate) == "own" then
                duplicate.completed = self:GetOwnedQuantity(duplicate) >= desired
            else
                duplicate.completed = duplicate.purchased >= desired
            end
            if not suppressUpdate then
                self:NotifyUpdate("item", {
                    action = "merged",
                    listId = list.id,
                    itemId = duplicate.id,
                })
            end
            return duplicate, nil, "merged"
        elseif duplicatePolicy == "replace" then
            duplicate.desired = item.desired
            if (duplicate.itemLink or "") == "" and item.itemLink ~= "" then
                duplicate.name = item.name
                duplicate.normalizedName = item.normalizedName
                duplicate.nameHash = item.nameHash or duplicate.nameHash
                duplicate.itemLink = item.itemLink
                duplicate.itemId = item.itemId
                local rule = duplicate.match or {}
                rule.quality = rule.quality or item.match.quality
                rule.level = rule.level or item.match.level
                rule.championPoints = rule.championPoints
                    or item.match.championPoints
                duplicate.match = rule
            end
            if source.note ~= nil then
                duplicate.note = item.note
            end
            if source.maxUnitPrice ~= nil then
                duplicate.maxUnitPrice = item.maxUnitPrice
            end
            if self:GetTargetMode(duplicate) == "own" then
                duplicate.completed = self:GetOwnedQuantity(duplicate) >= duplicate.desired
            else
                duplicate.completed = duplicate.purchased >= duplicate.desired
            end
            if not suppressUpdate then
                self:NotifyUpdate("item", {
                    action = "replaced",
                    listId = list.id,
                    itemId = duplicate.id,
                })
            end
            return duplicate, nil, "replaced"
        end
    end

    if #list.items >= ShoppingListModel.MAX_ITEMS_PER_LIST then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_FULL)
    end

    self.saved.nextItemId = self.saved.nextItemId + 1
    table.insert(list.items, item)
    if not suppressUpdate then
        self:NotifyUpdate("item", {
            action = "added",
            listId = list.id,
            itemId = item.id,
        })
    end
    return item, nil, duplicate and "kept" or "added"
end

function Data:AddItemToList(
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
    return self:AddPreparedItemToList(listId, {
        name = name,
        quantity = quantity,
        itemLink = itemLink,
        nameHash = nameHash,
        note = note,
        targetMode = targetMode,
        match = match,
    }, duplicatePolicy)
end

function Data:AddItemsToList(listId, sources, duplicatePolicy, suppressUpdate)
    local list = self:FindList(listId)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    if type(sources) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
    end
    duplicatePolicy = duplicatePolicy or "keep"
    if not ShoppingListModel:IsValidDuplicatePolicy(duplicatePolicy)
        or duplicatePolicy == "prompt"
    then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_DUPLICATE_POLICY)
    end
    if duplicatePolicy == "keep"
        and #list.items + #sources > ShoppingListModel.MAX_ITEMS_PER_LIST
    then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_FULL)
    end

    local firstItemId = self.saved.nextItemId
    local originalItems = deepCopy(list.items)
    local items = {}

    for _, source in ipairs(sources) do
        if type(source) ~= "table"
            or not ShoppingListModel:IsValidMatchingRule(source.match)
        then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_MATCH)
        end
        if not ShoppingListModel:IsValidTargetMode(source.targetMode or "buy") then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_TARGET_MODE)
        end
        if source.maxUnitPrice ~= nil and not ShoppingListModel:IsWholeNumber(
            tonumber(source.maxUnitPrice),
            1,
            ShoppingListModel.MAX_PRICE
        ) then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_INVALID_PRICE)
        end
    end

    for _, source in ipairs(sources) do
        local item, message = self:AddPreparedItemToList(
            list.id,
            source,
            duplicatePolicy,
            true
        )
        if not item then
            list.items = originalItems
            self.saved.nextItemId = firstItemId
            return nil, message
        end
        items[#items + 1] = item
    end

    if not suppressUpdate and #items > 0 then
        local ids = {}
        for index, item in ipairs(items) do
            ids[index] = item.id
        end
        self:NotifyUpdate("item", {
            action = "changedBatch",
            listId = list.id,
            itemIds = ids,
        })
    end

    return items
end

function Data:AddListWithItems(name, note, sources, selectList, category)
    if type(sources) ~= "table"
        or #sources > ShoppingListModel.MAX_ITEMS_PER_LIST
    then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_FULL)
    end
    local previousListId = self.saved.selectedListId
    local firstListId = self.saved.nextListId
    local list, message = self:AddList(name, note, category, true)
    if not list then
        return nil, message
    end

    local items
    items, message = self:AddItemsToList(list.id, sources, nil, true)
    if not items then
        local _, index = self:FindList(list.id)
        if index then
            table.remove(self.saved.lists, index)
        end
        self.saved.nextListId = firstListId
        self.saved.selectedListId = previousListId
        return nil, message
    end

    if selectList == false then
        self.saved.selectedListId = previousListId
    end
    self:NotifyUpdate("list", {
        action = "created",
        listId = list.id,
    })
    if #items > 0 then
        local ids = {}
        for index, item in ipairs(items) do
            ids[index] = item.id
        end
        self:NotifyUpdate("item", {
            action = "addedBatch",
            listId = list.id,
            itemIds = ids,
        })
    end
    return list, items
end

function Data:AddItem(name, quantity, itemLink, nameHash)
    return self:AddItemToList(
        self:GetCurrentList().id,
        name,
        quantity,
        itemLink,
        nameHash
    )
end

function Data:UpdateItem(id, values)
    local item = self:FindItem(id)
    if not item then
        return false, GetString(SI_SHOPPING_LIST_ERROR_ITEM_MISSING)
    end

    values = values or {}
    local desired = tonumber(values.desired ~= nil and values.desired or item.desired)
    if not ShoppingListModel:IsWholeNumber(
        desired,
        1,
        ShoppingListModel.MAX_QUANTITY
    ) then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_QUANTITY)
    end
    local targetMode = values.targetMode ~= nil and values.targetMode
        or ShoppingListModel:NormalizeTargetMode(item.targetMode)
    if not ShoppingListModel:IsValidTargetMode(targetMode) then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_TARGET_MODE)
    end
    local note = values.note ~= nil and values.note or item.note or ""
    if type(note) ~= "string" or #note > ShoppingListModel.MAX_NOTE_LENGTH then
        return false, GetString(SI_SHOPPING_LIST_ERROR_NOTE_TOO_LONG)
    end
    local maxUnitPrice = tonumber(values.maxUnitPrice)
    if maxUnitPrice == nil or maxUnitPrice == 0 then
        maxUnitPrice = nil
    elseif not ShoppingListModel:IsWholeNumber(
        maxUnitPrice,
        1,
        ShoppingListModel.MAX_PRICE
    ) then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_PRICE)
    end

    local existingRule = item.match or {}
    local ruleSource = {
        traitType = values.traitType ~= nil and values.traitType or existingRule.traitType,
        qualityMode = values.qualityMode or existingRule.qualityMode or "any",
        quality = values.quality ~= nil and tonumber(values.quality) or existingRule.quality,
        levelMode = values.levelMode or existingRule.levelMode or "any",
        level = values.level ~= nil and tonumber(values.level) or existingRule.level,
        championPoints = values.championPoints ~= nil
            and tonumber(values.championPoints) or existingRule.championPoints,
    }

    local setName = zo_strtrim(values.setName ~= nil and values.setName or existingRule.setName or "")
    if setName == "" then
        ruleSource.setId = nil
        ruleSource.setName = nil
    else
        local linkDetails = readLinkDetails(item.itemLink)
        ruleSource.setName = setName
        if linkDetails.normalizedSetName == normalizeName(setName) then
            ruleSource.setId = linkDetails.setId
        else
            ruleSource.setId = nil
        end
    end

    local rule = ShoppingListModel:NormalizeMatchingRule(ruleSource)
    if not rule then
        return false, GetString(SI_SHOPPING_LIST_ERROR_INVALID_MATCH)
    end

    item.desired = desired
    item.targetMode = targetMode
    item.note = note
    item.maxUnitPrice = maxUnitPrice
    item.match = rule

    if targetMode == "own" then
        item.completed = self:GetOwnedQuantity(item) >= item.desired
    else
        item.completed = item.purchased >= item.desired
    end
    local list = self:GetListForItem(item.id)
    self:NotifyUpdate("item", {
        action = "updated",
        listId = list and list.id,
        itemId = item.id,
    })
    return true
end

function Data:FindItem(id)
    local current = self:GetCurrentList()
    for index, item in ipairs(current.items) do
        if item.id == id then
            return item, index, current
        end
    end
    for _, list in ipairs(self.saved.lists) do
        if list ~= current then
            for index, item in ipairs(list.items) do
                if item.id == id then
                    return item, index, list
                end
            end
        end
    end
end

function Data:GetListForItem(id)
    local _, _, list = self:FindItem(id)
    return list
end

function Data:RemoveItem(id)
    local item, index, list = self:FindItem(id)
    if not item then
        return false
    end
    self:PushDeletedAction({
        kind = "items",
        listId = list.id,
        items = { { item = item, index = index } },
    })
    table.remove(list.items, index)
    self:NotifyUpdate("item", {
        action = "removed",
        listId = list.id,
        itemId = item.id,
        name = item.name,
    })
    return true
end

function Data:MoveItem(id, direction)
    local item, index, list = self:FindItem(id)
    if not item then
        return false
    end

    local items = list.items
    local target = zo_clamp(index + direction, 1, #items)
    if target == index then
        return false
    end
    items[index], items[target] = items[target], items[index]
    self:NotifyUpdate("item", {
        action = "moved",
        listId = list.id,
        itemId = item.id,
        fromIndex = index,
        toIndex = target,
    })
    return true
end

function Data:ToggleItem(id)
    local item = self:FindItem(id)
    if not item then
        return false
    end
    if self:GetTargetMode(item) == "own" then
        return false
    end
    if self:IsItemComplete(item) then
        item.completed = false
        if item.purchased >= item.desired then
            item.purchased = math.max(0, item.desired - 1)
        end
    else
        item.completed = true
    end
    local list = self:GetListForItem(item.id)
    self:NotifyUpdate("item", {
        action = "completionChanged",
        listId = list and list.id,
        itemId = item.id,
    })
    return true
end

function Data:ClearCompleted()
    local items = self:GetItems()
    local removed = {}
    for index = #items, 1, -1 do
        if self:IsItemComplete(items[index]) then
            removed[#removed + 1] = {
                item = table.remove(items, index),
                index = index,
            }
        end
    end
    if #removed > 0 then
        self:PushDeletedAction({
            kind = "items",
            listId = self:GetCurrentList().id,
            items = removed,
        })
        local ids = {}
        for index, entry in ipairs(removed) do
            ids[index] = entry.item.id
        end
        self:NotifyUpdate("item", {
            action = "removedBatch",
            listId = self:GetCurrentList().id,
            itemIds = ids,
        })
    end
    return #removed
end

function Data:UndoLastDeletion()
    local actions = self.saved.deletedActions
    local action = actions[#actions]
    if not action then
        return false, GetString(SI_SHOPPING_LIST_ERROR_NOTHING_TO_UNDO)
    end

    local updateKind
    local updateDetails
    if action.kind == "list" and action.list then
        local list = action.list
        if self:ListNameExists(list.name, list.id) then
            list.name = self:GetUniqueListName(list.name, list.id)
        end
        local index = zo_clamp(tonumber(action.index) or (#self.saved.lists + 1), 1, #self.saved.lists + 1)
        table.insert(self.saved.lists, index, list)
        self.saved.selectedListId = list.id
        updateKind = "list"
        updateDetails = {
            action = "restoredDeleted",
            listId = list.id,
        }
    elseif action.kind == "items" and type(action.items) == "table" then
        local list = self:FindList(action.listId)
        if not list then
            return false, GetString(SI_SHOPPING_LIST_ERROR_UNDO_LIST_MISSING)
        end
        if #list.items + #action.items > ShoppingListModel.MAX_ITEMS_PER_LIST then
            return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_FULL)
        end
        table.sort(action.items, function(left, right)
            return (tonumber(left.index) or 1) < (tonumber(right.index) or 1)
        end)
        for _, removed in ipairs(action.items) do
            if removed.item then
                local index = zo_clamp(tonumber(removed.index) or (#list.items + 1), 1, #list.items + 1)
                table.insert(list.items, index, removed.item)
            end
        end
        self.saved.selectedListId = list.id
        local ids = {}
        for index, removed in ipairs(action.items) do
            if removed.item then
                ids[index] = removed.item.id
            end
        end
        updateKind = "item"
        updateDetails = {
            action = "restoredBatch",
            listId = list.id,
            itemIds = ids,
        }
    else
        table.remove(actions)
        return false, GetString(SI_SHOPPING_LIST_ERROR_NOTHING_TO_UNDO)
    end

    table.remove(actions)
    self:EnsureActiveTripList()
    self:NotifyUpdate(updateKind, updateDetails)
    return true, action
end

function Data:RecordPurchase(entry, quantity, purchase)
    purchase = purchase or {}
    quantity = math.max(0, tonumber(quantity) or 0)
    if not entry or quantity == 0 then
        return
    end
    local list = self:GetListForItem(entry.id)
    if not list then
        return
    end

    local listingQuantity = math.max(1, tonumber(purchase.quantity) or quantity)
    local listingPrice = math.max(0, tonumber(purchase.totalPrice) or 0)
    local unitPrice = tonumber(purchase.unitPrice)
    if not unitPrice and listingPrice > 0 then
        unitPrice = listingPrice / listingQuantity
    end
    unitPrice = math.max(0, unitPrice or 0)
    local appliedPrice = tonumber(purchase.allocatedPrice)
        or math.floor((unitPrice * quantity) + 0.5)

    entry.purchaseHistory = entry.purchaseHistory or {}
    entry.purchaseHistory[#entry.purchaseHistory + 1] = {
        timestamp = tonumber(purchase.timestamp) or GetTimeStamp(),
        quantity = quantity,
        totalPrice = appliedPrice,
        unitPrice = unitPrice,
        listingQuantity = listingQuantity,
        listingPrice = listingPrice,
        sellerName = purchase.sellerName,
        guildName = purchase.guildName,
        currencyType = purchase.currencyType or CURT_MONEY,
        itemLink = purchase.itemLink,
        itemName = purchase.itemName,
        transactionId = purchase.transactionId,
        transactionPrice = purchase.transactionPrice,
    }
    while #entry.purchaseHistory > MAX_HISTORY_PER_ITEM do
        table.remove(entry.purchaseHistory, 1)
    end
    entry.purchaseCount = math.max(
        #entry.purchaseHistory,
        math.floor(tonumber(entry.purchaseCount) or 0) + 1
    )
    entry.totalSpent = math.max(0, tonumber(entry.totalSpent) or 0) + appliedPrice
    entry.pricedQuantity = math.max(0, tonumber(entry.pricedQuantity) or 0) + quantity
    list.totalSpent = math.max(0, tonumber(list.totalSpent) or 0) + appliedPrice
    return list
end

function Data:RecordPurchaseTransaction(changes, purchase)
    purchase = purchase or {}
    if type(changes) ~= "table" or #changes == 0 then
        return nil
    end

    local appliedQuantity = 0
    for _, change in ipairs(changes) do
        appliedQuantity = appliedQuantity + math.max(0, tonumber(change.quantity) or 0)
    end
    if appliedQuantity <= 0 then
        return nil
    end

    local listingQuantity = math.max(
        1,
        math.floor(tonumber(purchase.quantity) or appliedQuantity)
    )
    local listingPrice = math.max(
        0,
        math.floor(tonumber(purchase.totalPrice) or 0)
    )
    local unitPrice = tonumber(purchase.unitPrice)
    if not unitPrice and listingPrice > 0 then
        unitPrice = listingPrice / listingQuantity
    end
    unitPrice = math.max(0, unitPrice or 0)
    if purchase.totalPrice == nil and unitPrice > 0 then
        listingPrice = math.floor((unitPrice * listingQuantity) + 0.5)
    end

    local transactionId = self.saved.nextTransactionId
    self.saved.nextTransactionId = transactionId + 1
    local transaction = {
        id = transactionId,
        timestamp = math.max(0, math.floor(tonumber(purchase.timestamp) or GetTimeStamp())),
        quantity = listingQuantity,
        totalPrice = listingPrice,
        unitPrice = unitPrice,
        sellerName = purchase.sellerName,
        guildName = purchase.guildName,
        currencyType = purchase.currencyType or CURT_MONEY,
        itemLink = purchase.itemLink,
        itemName = purchase.itemName,
        allocations = {},
    }

    local distributedPrice = 0
    for index, change in ipairs(changes) do
        local list = self:GetListForItem(change.entry.id)
        if list then
            local transactionPrice
            if index == #changes then
                transactionPrice = listingPrice - distributedPrice
            else
                transactionPrice = math.floor(
                    (listingPrice * change.quantity) / appliedQuantity
                )
                distributedPrice = distributedPrice + transactionPrice
            end
            local allocatedPrice = math.floor((unitPrice * change.quantity) + 0.5)
            self:RecordPurchase(change.entry, change.quantity, {
                quantity = listingQuantity,
                totalPrice = listingPrice,
                unitPrice = unitPrice,
                timestamp = transaction.timestamp,
                sellerName = purchase.sellerName,
                guildName = purchase.guildName,
                currencyType = transaction.currencyType,
                itemLink = purchase.itemLink,
                itemName = purchase.itemName,
                allocatedPrice = allocatedPrice,
                transactionId = transactionId,
                transactionPrice = transactionPrice,
            })
            list.transactionSpent = math.max(
                0,
                tonumber(list.transactionSpent) or tonumber(list.totalSpent) or 0
            ) + transactionPrice
            transaction.allocations[#transaction.allocations + 1] = {
                listId = list.id,
                itemId = change.entry.id,
                quantity = change.quantity,
                allocatedPrice = allocatedPrice,
                transactionPrice = transactionPrice,
            }
        end
    end

    self.saved.purchaseTransactions[#self.saved.purchaseTransactions + 1] = transaction
    while #self.saved.purchaseTransactions
        > ShoppingListModel.MAX_PURCHASE_TRANSACTIONS
    do
        table.remove(self.saved.purchaseTransactions, 1)
    end
    local listIds = {}
    local itemIds = {}
    local seenLists = {}
    for _, allocation in ipairs(transaction.allocations) do
        itemIds[#itemIds + 1] = allocation.itemId
        if not seenLists[allocation.listId] then
            seenLists[allocation.listId] = true
            listIds[#listIds + 1] = allocation.listId
        end
    end
    self:NotifyUpdate("purchase", {
        action = "recorded",
        transactionId = transaction.id,
        listIds = listIds,
        itemIds = itemIds,
        quantity = transaction.quantity,
        totalPrice = transaction.totalPrice,
        itemLink = transaction.itemLink,
        itemName = transaction.itemName,
    })
    return transaction
end

function Data.NormalizeName(name)
    return normalizeName(name)
end
