ShoppingListData = {}

local Data = ShoppingListData
local DEFAULT_LIST_NAME = GetString(SI_SHOPPING_LIST_DEFAULT_LIST_NAME)
local MAX_DELETED_ACTIONS = 20
local MAX_NOTE_LENGTH = 2000
local VALID_FILTERS = {
    all = true,
    needed = true,
    completed = true,
    overTarget = true,
    restricted = true,
}

local defaults = {
    nextItemId = 1,
    nextListId = 2,
    selectedListId = 1,
    archivedLists = {},
    deletedActions = {},
    lists = {
        {
            id = 1,
            name = DEFAULT_LIST_NAME,
            note = "",
            items = {},
            totalSpent = 0,
            tripActive = true,
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

local function replaceTable(target, source)
    for key in pairs(target) do
        target[key] = nil
    end
    for key, value in pairs(source) do
        target[key] = value
    end
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
    data:Migrate()
    return data
end

function Data:Migrate()
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
    while #self.saved.deletedActions > MAX_DELETED_ACTIONS do
        table.remove(self.saved.deletedActions, 1)
    end

    local settings = self.saved.settings or {}
    self.saved.settings = settings
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
            if archived then
                list.archivedAt = tonumber(list.archivedAt) or GetTimeStamp()
            else
                list.archivedAt = nil
            end

            local itemSpending = 0
            for _, item in ipairs(list.items) do
                item.id = tonumber(item.id) or (highestItemId + 1)
                highestItemId = math.max(highestItemId, item.id)
                item.normalizedName = item.normalizedName or normalizeName(item.name)
                item.note = normalizeNote(item.note)
                item.desired = math.max(1, tonumber(item.desired) or 1)
                item.purchased = math.max(0, tonumber(item.purchased) or 0)
                item.match = item.match or {}
                item.purchaseHistory = type(item.purchaseHistory) == "table" and item.purchaseHistory or {}
                item.totalSpent = math.max(0, tonumber(item.totalSpent) or 0)
                item.pricedQuantity = math.max(0, tonumber(item.pricedQuantity) or 0)
                item.maxUnitPrice = math.floor(math.max(0, tonumber(item.maxUnitPrice) or 0))
                if item.maxUnitPrice == 0 then
                    item.maxUnitPrice = nil
                end
                itemSpending = itemSpending + item.totalSpent
                local rule = item.match
                if rule.setName and not rule.normalizedSetName then
                    rule.normalizedSetName = normalizeName(rule.setName)
                end
                rule.qualityMode = rule.qualityMode or "any"
                rule.levelMode = rule.levelMode or "any"
                item.completed = item.completed == true or item.purchased >= item.desired
            end
            list.totalSpent = math.max(0, tonumber(list.totalSpent) or 0, itemSpending)
            list.budget = math.floor(math.max(0, tonumber(list.budget) or 0))
            if list.budget == 0 then
                list.budget = nil
            end
        end
    end

    normalizeLists(self.saved.lists, false)
    normalizeLists(self.saved.archivedLists, true)

    self.saved.nextListId = math.max(tonumber(self.saved.nextListId) or 1, highestListId + 1)
    self.saved.nextItemId = math.max(tonumber(self.saved.nextItemId) or 1, highestItemId + 1)
    if not self:FindList(self.saved.selectedListId) then
        self.saved.selectedListId = self.saved.lists[1].id
    end
    self:EnsureActiveTripList()
end

function Data:GetItems()
    return self:GetCurrentList().items
end

function Data:GetLists()
    return self.saved.lists
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

function Data:SelectList(id)
    local list = self:FindList(id)
    if not list then
        return false
    end
    self.saved.selectedListId = list.id
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
        name = baseName .. " " .. tostring(suffix)
        suffix = suffix + 1
    end
    return name
end

function Data:AddList(name, note)
    name = zo_strtrim(name or "")
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_LIST_NAME)
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
        budget = nil,
        tripActive = self:IsMultiListTripEnabled(),
    }
    self.saved.nextListId = self.saved.nextListId + 1
    self.saved.lists[#self.saved.lists + 1] = list
    self.saved.selectedListId = list.id
    return list
end

function Data:ImportList(name, items)
    name = zo_strtrim(name or "")
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_NO_NAME)
    end
    if type(items) ~= "table" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_NO_ITEMS)
    end
    if #items > 500 then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_TOO_MANY_ITEMS)
    end

    local validated = {}
    for _, source in ipairs(items) do
        local itemName = zo_strtrim(source.name or "")
        local quantity = math.floor(tonumber(source.desired) or 0)
        if itemName == "" or quantity < 1 or quantity > 1000000 then
            return nil, GetString(SI_SHOPPING_LIST_ERROR_SHARED_LIST_INVALID_ITEM)
        end
        validated[#validated + 1] = { name = itemName, desired = quantity }
    end

    local list = {
        id = self.saved.nextListId,
        name = self:GetUniqueListName(name),
        note = "",
        items = {},
        totalSpent = 0,
        budget = nil,
        tripActive = self:IsMultiListTripEnabled(),
    }
    local nextItemId = self.saved.nextItemId
    for _, source in ipairs(validated) do
        list.items[#list.items + 1] = {
            id = nextItemId,
            name = zo_strformat(SI_TOOLTIP_ITEM_NAME, source.name),
            note = "",
            normalizedName = normalizeName(source.name),
            itemLink = "",
            desired = source.desired,
            purchased = 0,
            completed = false,
            purchaseHistory = {},
            totalSpent = 0,
            pricedQuantity = 0,
            maxUnitPrice = nil,
            match = {
                qualityMode = "any",
                levelMode = "any",
            },
        }
        nextItemId = nextItemId + 1
    end

    self.saved.nextItemId = nextItemId
    self.saved.nextListId = self.saved.nextListId + 1
    self.saved.lists[#self.saved.lists + 1] = list
    self.saved.selectedListId = list.id
    return list
end

function Data:DuplicateList(id, name, note)
    local source = self:FindList(id)
    if not source then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    name = zo_strtrim(name or "")
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_LIST_NAME)
    end
    if self:ListNameExists(name) then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_NAME_EXISTS)
    end

    local copy = {
        id = self.saved.nextListId,
        name = name,
        note = normalizeNote(note ~= nil and note or source.note),
        items = {},
        totalSpent = 0,
        budget = source.budget,
        tripActive = self:IsMultiListTripEnabled(),
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
            desired = item.desired,
            purchased = 0,
            completed = false,
            purchaseHistory = {},
            totalSpent = 0,
            pricedQuantity = 0,
            maxUnitPrice = item.maxUnitPrice,
            match = match,
        }
        self.saved.nextItemId = self.saved.nextItemId + 1
    end

    self.saved.lists[#self.saved.lists + 1] = copy
    self.saved.selectedListId = copy.id
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
    if self:ListNameExists(name, id) then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_NAME_EXISTS)
    end
    list.name = name
    return true
end

function Data:UpdateListNote(id, note)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end
    list.note = normalizeNote(note)
    return true
end

function Data:UpdateListBudget(id, value)
    local list = self:FindList(id)
    if not list then
        return false, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    local budget = math.floor(math.max(0, tonumber(value) or 0))
    list.budget = budget > 0 and budget or nil
    return true
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
            budget = nil,
        }
        self.saved.nextListId = self.saved.nextListId + 1
        self.saved.lists[1] = replacement
    end

    local selected = self.saved.lists[math.min(index, #self.saved.lists)]
    self.saved.selectedListId = selected.id
    self:EnsureActiveTripList()
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
    return true, list
end

function Data:GetSettings()
    return self.saved.settings
end

function Data:GetBackupData()
    return deepCopy(self.saved)
end

function Data:RestoreBackup(snapshot)
    if type(snapshot) ~= "table"
        or type(snapshot.lists) ~= "table"
        or type(snapshot.settings) ~= "table"
    then
        return false, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end

    local previous = deepCopy(self.saved)
    local settingsReference = self.saved.settings
    local function apply(source)
        local restored = deepCopy(source)
        local restoredSettings = restored.settings or {}
        restored.settings = nil
        replaceTable(self.saved, restored)
        replaceTable(settingsReference, restoredSettings)
        self.saved.settings = settingsReference
        self:Migrate()
    end

    local ok = pcall(apply, snapshot)
    if not ok then
        pcall(apply, previous)
        return false, GetString(SI_SHOPPING_LIST_BACKUP_ERROR_DATA)
    end
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
        return not item.completed
    elseif filter == "completed" then
        return item.completed == true
    elseif filter == "overTarget" then
        return self:ItemIsOverTarget(item)
    elseif filter == "restricted" then
        return self:ItemHasMatchingRules(item)
    end
    return true
end

function Data:GetFilteredShoppingItems()
    local result = {}
    local filter = self:GetItemFilter()
    for _, item in ipairs(self:GetShoppingItems()) do
        if self:ItemPassesFilter(item, filter) then
            result[#result + 1] = item
        end
    end
    return result
end

function Data:AddItemToList(listId, name, quantity, itemLink, nameHash, note)
    local list = self:FindList(listId)
    if not list then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_LIST_MISSING)
    end

    name = zo_strtrim(name or "")
    quantity = math.max(1, math.floor(tonumber(quantity) or 1))

    if name == "" and itemLink and itemLink ~= "" then
        name = GetItemLinkName(itemLink)
    end
    if name == "" then
        return nil, GetString(SI_SHOPPING_LIST_ERROR_ENTER_ITEM_NAME)
    end

    local details = readLinkDetails(itemLink)
    local item = {
        id = self.saved.nextItemId,
        name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name),
        note = normalizeNote(note),
        normalizedName = normalizeName(name),
        nameHash = nameHash,
        itemLink = itemLink or "",
        itemId = details.itemId,
        desired = quantity,
        purchased = 0,
        completed = false,
        purchaseHistory = {},
        totalSpent = 0,
        pricedQuantity = 0,
        maxUnitPrice = nil,
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
        },
    }

    self.saved.nextItemId = self.saved.nextItemId + 1
    table.insert(list.items, item)
    return item
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

    item.desired = math.max(1, math.floor(tonumber(values.desired) or item.desired))
    item.note = normalizeNote(values.note ~= nil and values.note or item.note)
    local maxUnitPrice = math.floor(math.max(0, tonumber(values.maxUnitPrice) or 0))
    item.maxUnitPrice = maxUnitPrice > 0 and maxUnitPrice or nil

    local rule = item.match or {}
    item.match = rule

    local setName = zo_strtrim(values.setName or "")
    if setName == "" then
        rule.setId = nil
        rule.setName = nil
        rule.normalizedSetName = nil
    else
        local linkDetails = readLinkDetails(item.itemLink)
        rule.setName = setName
        rule.normalizedSetName = normalizeName(setName)
        if linkDetails.normalizedSetName == rule.normalizedSetName then
            rule.setId = linkDetails.setId
        else
            rule.setId = nil
        end
    end

    rule.traitType = values.traitType
    rule.qualityMode = values.qualityMode or "any"
    rule.quality = tonumber(values.quality)
    rule.levelMode = values.levelMode or "any"
    rule.level = math.max(1, math.floor(tonumber(values.level) or 1))
    rule.championPoints = math.max(0, math.floor(tonumber(values.championPoints) or 0))

    item.completed = item.purchased >= item.desired
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
    return true
end

function Data:ToggleItem(id)
    local item = self:FindItem(id)
    if not item then
        return false
    end
    if item.completed then
        item.completed = false
        if item.purchased >= item.desired then
            item.purchased = math.max(0, item.desired - 1)
        end
    else
        item.completed = true
    end
    return true
end

function Data:ClearCompleted()
    local items = self:GetItems()
    local removed = {}
    for index = #items, 1, -1 do
        if items[index].completed then
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
    end
    return #removed
end

function Data:UndoLastDeletion()
    local actions = self.saved.deletedActions
    local action = actions[#actions]
    if not action then
        return false, GetString(SI_SHOPPING_LIST_ERROR_NOTHING_TO_UNDO)
    end

    if action.kind == "list" and action.list then
        local list = action.list
        if self:ListNameExists(list.name, list.id) then
            list.name = self:GetUniqueListName(list.name, list.id)
        end
        local index = zo_clamp(tonumber(action.index) or (#self.saved.lists + 1), 1, #self.saved.lists + 1)
        table.insert(self.saved.lists, index, list)
        self.saved.selectedListId = list.id
    elseif action.kind == "items" and type(action.items) == "table" then
        local list = self:FindList(action.listId)
        if not list then
            return false, GetString(SI_SHOPPING_LIST_ERROR_UNDO_LIST_MISSING)
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
    else
        table.remove(actions)
        return false, GetString(SI_SHOPPING_LIST_ERROR_NOTHING_TO_UNDO)
    end

    table.remove(actions)
    self:EnsureActiveTripList()
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
    local appliedPrice = math.floor((unitPrice * quantity) + 0.5)

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
    }
    entry.totalSpent = math.max(0, tonumber(entry.totalSpent) or 0) + appliedPrice
    entry.pricedQuantity = math.max(0, tonumber(entry.pricedQuantity) or 0) + quantity
    list.totalSpent = math.max(0, tonumber(list.totalSpent) or 0) + appliedPrice
    return list
end

function Data.NormalizeName(name)
    return normalizeName(name)
end
