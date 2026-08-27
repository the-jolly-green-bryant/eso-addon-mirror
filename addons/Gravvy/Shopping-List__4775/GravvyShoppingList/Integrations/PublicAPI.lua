local API_VERSION = 3
local MAX_QUANTITY = ShoppingListModel.MAX_QUANTITY
local MAX_BATCH_ITEMS = ShoppingListModel.MAX_ITEMS_PER_LIST
local MAX_LIST_NAME_BYTES = ShoppingListModel.MAX_NAME_LENGTH

local ERROR = {
    NOT_READY = "NOT_READY",
    INVALID_ITEM = "INVALID_ITEM",
    INVALID_QUANTITY = "INVALID_QUANTITY",
    INVALID_OPTIONS = "INVALID_OPTIONS",
    INVALID_MATCH = "INVALID_MATCH",
    INVALID_LIST_NAME = "INVALID_LIST_NAME",
    INVALID_ITEMS = "INVALID_ITEMS",
    TOO_MANY_ITEMS = "TOO_MANY_ITEMS",
    LIST_NOT_FOUND = "LIST_NOT_FOUND",
    LIST_EXISTS = "LIST_EXISTS",
    BATCH_FAILED = "BATCH_FAILED",
    ITEM_NOT_FOUND = "ITEM_NOT_FOUND",
    ARCHIVED_LIST_NOT_FOUND = "ARCHIVED_LIST_NOT_FOUND",
    LAST_LIST_REQUIRED = "LAST_LIST_REQUIRED",
    INVALID_EVENT = "INVALID_EVENT",
    INVALID_CALLBACK = "INVALID_CALLBACK",
    CALLBACK_NOT_FOUND = "CALLBACK_NOT_FOUND",
}

local EVENT = {
    LIST_UPDATED = "LIST_UPDATED",
    ITEM_UPDATED = "ITEM_UPDATED",
    PURCHASE_RECORDED = "PURCHASE_RECORDED",
}

local VALID_EVENTS = {}
for _, eventName in pairs(EVENT) do
    VALID_EVENTS[eventName] = true
end
local callbacks = {}
local updatePauseDepth = 0
local pendingUpdates = {}

local API = {
    VERSION = API_VERSION,
    ERROR = ERROR,
    EVENT = EVENT,
}

local function getData()
    if not GravvyShoppingList or not GravvyShoppingList.data then
        return nil
    end
    return GravvyShoppingList.data
end

local function findList(data, options)
    local listId = options.listId
    local listName = options.listName
    if listId ~= nil and listName ~= nil then
        return nil, ERROR.INVALID_OPTIONS
    end

    if listId ~= nil then
        if type(listId) ~= "number" or listId ~= math.floor(listId) then
            return nil, ERROR.INVALID_OPTIONS
        end
        local list = data:FindList(listId)
        return list, list and nil or ERROR.LIST_NOT_FOUND
    end

    if listName ~= nil then
        if type(listName) ~= "string" then
            return nil, ERROR.INVALID_OPTIONS
        end
        local wanted = zo_strlower(zo_strtrim(listName))
        if wanted == "" or #wanted > MAX_LIST_NAME_BYTES then
            return nil, ERROR.INVALID_OPTIONS
        end
        for _, list in ipairs(data:GetLists()) do
            if zo_strlower(list.name) == wanted then
                return list
            end
        end
        return nil, ERROR.LIST_NOT_FOUND
    end

    return data:GetCurrentList()
end

local function findArchivedList(data, options)
    local listId = options.listId
    local listName = options.listName
    if listId ~= nil and listName ~= nil then
        return nil, ERROR.INVALID_OPTIONS
    end
    if listId ~= nil then
        if type(listId) ~= "number" or listId ~= math.floor(listId) then
            return nil, ERROR.INVALID_OPTIONS
        end
        local list = data:FindArchivedList(listId)
        return list, list and nil or ERROR.ARCHIVED_LIST_NOT_FOUND
    end
    if listName ~= nil then
        if type(listName) ~= "string" then
            return nil, ERROR.INVALID_OPTIONS
        end
        local wanted = zo_strlower(zo_strtrim(listName))
        if wanted == "" or #wanted > MAX_LIST_NAME_BYTES then
            return nil, ERROR.INVALID_OPTIONS
        end
        for _, list in ipairs(data:GetArchivedLists()) do
            if zo_strlower(list.name) == wanted then
                return list
            end
        end
    end
    return nil, ERROR.ARCHIVED_LIST_NOT_FOUND
end

local function readItem(value)
    if type(value) ~= "string" then
        return nil
    end

    value = zo_strtrim(value)
    if value == "" or #value > ShoppingListModel.MAX_LINK_LENGTH then
        return nil
    end

    local _, _, linkType = ZO_LinkHandler_ParseLink(value)
    if linkType then
        if linkType ~= ITEM_LINK_TYPE then
            return nil
        end
        local name = zo_strtrim(GetItemLinkName(value) or "")
        if name == "" then
            return nil
        end
        return name, value
    end

    if string.find(value, "|H", 1, true) then
        return nil
    end
    if #value > ShoppingListModel.MAX_NAME_LENGTH then
        return nil
    end
    return value, ""
end

local function readWholeNumber(value, minimum, maximum)
    value = tonumber(value)
    if not value or value ~= math.floor(value) or value < minimum then
        return nil
    end
    if maximum and value > maximum then
        return nil
    end
    return value
end

local function readDuplicatePolicy(value, defaultValue)
    value = value or defaultValue
    if type(value) ~= "string"
        or not ShoppingListModel:IsValidDuplicatePolicy(value)
        or value == "prompt"
    then
        return nil
    end
    return value
end

local function defaultMatch(itemLink)
    local rule = {
        qualityMode = "any",
        levelMode = "any",
    }
    if itemLink == "" then
        return rule
    end

    rule.traitType = GetItemLinkTraitInfo(itemLink)
    rule.quality = GetItemLinkDisplayQuality(itemLink)
    rule.level = GetItemLinkRequiredLevel(itemLink)
    rule.championPoints = GetItemLinkRequiredChampionPoints(itemLink)

    local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)
    if hasSet then
        rule.setId = setId
        rule.setName = setName
        rule.normalizedSetName = ShoppingListData.NormalizeName(setName)
    end
    return rule
end

local function prepareMatch(values, itemLink)
    if values == nil then
        return nil
    end
    if type(values) ~= "table" then
        return nil, ERROR.INVALID_MATCH
    end

    local rule = defaultMatch(itemLink)

    if values.setName ~= nil then
        if type(values.setName) ~= "string" then
            return nil, ERROR.INVALID_MATCH
        end
        local setName = zo_strtrim(values.setName)
        if setName == "" then
            rule.setId = nil
            rule.setName = nil
            rule.normalizedSetName = nil
        else
            local normalized = ShoppingListData.NormalizeName(setName)
            if rule.normalizedSetName ~= normalized then
                rule.setId = nil
            end
            rule.setName = setName
            rule.normalizedSetName = normalized
        end
    end

    if values.traitType ~= nil then rule.traitType = values.traitType end

    if values.qualityMode ~= nil then
        rule.qualityMode = values.qualityMode
    end
    if values.quality ~= nil then
        rule.quality = values.quality
    end

    if values.levelMode ~= nil then
        rule.levelMode = values.levelMode
    end
    if values.level ~= nil then
        rule.level = values.level
    end
    if values.championPoints ~= nil then
        rule.championPoints = values.championPoints
    end

    rule = ShoppingListModel:NormalizeMatchingRule(rule)
    return rule, rule and nil or ERROR.INVALID_MATCH
end

local function readEntryValue(source)
    local value
    local count = 0
    for _, key in ipairs({ "item", "itemLink", "name" }) do
        if source[key] ~= nil then
            value = source[key]
            count = count + 1
        end
    end
    if count ~= 1 then
        return nil
    end
    return value
end

local function prepareItem(source)
    if type(source) ~= "table" then
        return nil, ERROR.INVALID_ITEM
    end
    if source.note ~= nil and type(source.note) ~= "string" then
        return nil, ERROR.INVALID_OPTIONS
    end
    if source.note and #source.note > ShoppingListModel.MAX_NOTE_LENGTH then
        return nil, ERROR.INVALID_OPTIONS
    end

    local value = readEntryValue(source)
    local name, itemLink = readItem(value)
    if not name then
        return nil, ERROR.INVALID_ITEM
    end
    if source.itemLink ~= nil and itemLink == "" then
        return nil, ERROR.INVALID_ITEM
    end

    local quantity = source.quantity == nil and 1
        or readWholeNumber(source.quantity, 1, MAX_QUANTITY)
    if not quantity then
        return nil, ERROR.INVALID_QUANTITY
    end
    local targetMode = source.targetMode or "buy"
    if not ShoppingListModel:IsValidTargetMode(targetMode) then
        return nil, ERROR.INVALID_OPTIONS
    end

    local match, matchError = prepareMatch(source.match, itemLink)
    if matchError then
        return nil, matchError
    end

    return {
        name = name,
        itemLink = itemLink,
        quantity = quantity,
        targetMode = targetMode,
        note = source.note,
        match = match,
    }
end

local function prepareItems(sources)
    if type(sources) ~= "table" then
        return nil, ERROR.INVALID_ITEMS
    end

    local count = #sources
    if count > MAX_BATCH_ITEMS then
        return nil, ERROR.TOO_MANY_ITEMS
    end
    for key in pairs(sources) do
        if type(key) ~= "number"
            or key ~= math.floor(key)
            or key < 1
            or key > count
        then
            return nil, ERROR.INVALID_ITEMS
        end
    end

    local prepared = {}
    for index, source in ipairs(sources) do
        local item, itemError = prepareItem(source)
        if not item then
            return nil, itemError, index
        end
        prepared[index] = item
    end
    return prepared
end

local function refresh()
    if GravvyShoppingList.ui then
        GravvyShoppingList.ui.listSignature = nil
        GravvyShoppingList.ui:Refresh()
    end
    if GravvyShoppingList.gamepad then
        GravvyShoppingList.gamepad:Refresh()
    end
    GravvyShoppingList:RefreshInventory()
end

local function itemIds(items)
    local ids = {}
    for index, item in ipairs(items) do
        ids[index] = item.id
    end
    return ids
end

local function copyValue(value, seen)
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
        copy[copyValue(key, seen)] = copyValue(entry, seen)
    end
    return copy
end

local function snapshotItem(data, item, list)
    local owned = data:GetOwnedQuantity(item)
    local remaining = data:GetRemainingQuantity(item)
    return {
        id = item.id,
        listId = list and list.id or nil,
        name = item.name,
        itemLink = item.itemLink or "",
        note = item.note or "",
        desired = item.desired,
        purchased = item.purchased or 0,
        owned = owned,
        remaining = remaining,
        completed = remaining == 0,
        targetMode = data:GetTargetMode(item),
        maxUnitPrice = item.maxUnitPrice,
        addedAt = item.addedAt,
        match = copyValue(item.match or {}),
    }
end

local function snapshotList(data, list, archived, includeItems)
    local snapshot = {
        id = list.id,
        name = list.name,
        note = list.note or "",
        category = list.category or "",
        budget = list.budget,
        allocatedSpent = tonumber(list.totalSpent) or 0,
        transactionSpent = tonumber(list.transactionSpent)
            or tonumber(list.totalSpent) or 0,
        favorite = list.favorite == true,
        pinned = list.pinned == true,
        recurring = list.recurring == true,
        selected = not archived and data:GetCurrentList().id == list.id,
        archived = archived == true,
        archivedAt = list.archivedAt,
        itemCount = #(list.items or {}),
        remainingEntryCount = 0,
        remainingQuantity = 0,
    }
    if includeItems then
        snapshot.items = {}
    end
    for _, item in ipairs(list.items or {}) do
        local itemSnapshot = snapshotItem(data, item, list)
        if itemSnapshot.remaining > 0 then
            snapshot.remainingEntryCount = snapshot.remainingEntryCount + 1
        end
        snapshot.remainingQuantity = snapshot.remainingQuantity
            + itemSnapshot.remaining
        if includeItems then
            snapshot.items[#snapshot.items + 1] = itemSnapshot
        end
    end
    return snapshot
end

function API:_Dispatch(eventName, details)
    if updatePauseDepth > 0 then
        pendingUpdates[#pendingUpdates + 1] = {
            eventName = eventName,
            details = copyValue(details or {}),
        }
        return
    end
    local listeners = callbacks[eventName]
    if not listeners then
        return
    end
    for callback in pairs(listeners) do
        local ok, message = pcall(callback, copyValue(details or {}))
        if not ok and d then
            d("Shopping List API callback failed: " .. tostring(message))
        end
    end
end

function API:_PauseUpdates()
    updatePauseDepth = updatePauseDepth + 1
end

function API:_ResumeUpdates()
    updatePauseDepth = math.max(0, updatePauseDepth - 1)
    if updatePauseDepth > 0 then
        return
    end
    local updates = pendingUpdates
    pendingUpdates = {}
    for _, update in ipairs(updates) do
        self:_Dispatch(update.eventName, update.details)
    end
end

function API:_AttachData(data)
    if not data or not data.SetUpdateListener then
        return
    end
    data:SetUpdateListener(function(kind, details)
        local eventName = kind == "list" and EVENT.LIST_UPDATED
            or kind == "item" and EVENT.ITEM_UPDATED
            or kind == "purchase" and EVENT.PURCHASE_RECORDED
            or nil
        if eventName then
            self:_Dispatch(eventName, details)
        end
    end)
end

function API:RegisterCallback(eventName, callback)
    if not VALID_EVENTS[eventName] then
        return false, ERROR.INVALID_EVENT
    end
    if type(callback) ~= "function" then
        return false, ERROR.INVALID_CALLBACK
    end
    callbacks[eventName] = callbacks[eventName] or {}
    callbacks[eventName][callback] = true
    return true
end

function API:UnregisterCallback(eventName, callback)
    if not VALID_EVENTS[eventName] then
        return false, ERROR.INVALID_EVENT
    end
    if type(callback) ~= "function" then
        return false, ERROR.INVALID_CALLBACK
    end
    local listeners = callbacks[eventName]
    if not listeners or not listeners[callback] then
        return false, ERROR.CALLBACK_NOT_FOUND
    end
    listeners[callback] = nil
    return true
end

function API:GetVersion()
    return API_VERSION
end

function API:GetLists()
    local data = getData()
    if not data then
        return nil, ERROR.NOT_READY
    end

    local lists = {}
    for _, list in ipairs(data:GetLists()) do
        lists[#lists + 1] = {
            id = list.id,
            name = list.name,
        }
    end
    return lists
end

function API:GetArchivedLists()
    local data = getData()
    if not data then
        return nil, ERROR.NOT_READY
    end
    local lists = {}
    for _, list in ipairs(data:GetArchivedLists()) do
        lists[#lists + 1] = snapshotList(data, list, true, false)
    end
    return lists
end

function API:GetList(options)
    local data = getData()
    if not data then
        return nil, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return nil, ERROR.INVALID_OPTIONS
    end
    options = options or {}
    if options.includeItems ~= nil and type(options.includeItems) ~= "boolean" then
        return nil, ERROR.INVALID_OPTIONS
    end

    local list, listError = findList(data, options)
    if not list then
        return nil, listError
    end
    return snapshotList(data, list, false, options.includeItems ~= false)
end

function API:GetRemainingQuantity(itemId)
    local data = getData()
    if not data then
        return nil, ERROR.NOT_READY
    end
    itemId = readWholeNumber(itemId, 1)
    if not itemId then
        return nil, ERROR.INVALID_OPTIONS
    end
    local item, _, list = data:FindItem(itemId)
    if not item then
        return nil, ERROR.ITEM_NOT_FOUND
    end
    return data:GetRemainingQuantity(item), snapshotItem(data, item, list)
end

function API:PreviewMatch(itemLinkOrName, options)
    local data = getData()
    if not data or not GravvyShoppingList.matcher then
        return nil, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return nil, ERROR.INVALID_OPTIONS
    end
    options = options or {}
    if options.allLists ~= nil and type(options.allLists) ~= "boolean" then
        return nil, ERROR.INVALID_OPTIONS
    end
    if options.includeCompleted ~= nil
        and type(options.includeCompleted) ~= "boolean"
    then
        return nil, ERROR.INVALID_OPTIONS
    end
    if options.allLists and (options.listId ~= nil or options.listName ~= nil) then
        return nil, ERROR.INVALID_OPTIONS
    end

    local itemName, itemLink = readItem(itemLinkOrName)
    if not itemName then
        return nil, ERROR.INVALID_ITEM
    end
    local quantity = options.quantity == nil and 1
        or readWholeNumber(options.quantity, 1, MAX_QUANTITY)
    if not quantity then
        return nil, ERROR.INVALID_QUANTITY
    end

    local items = {}
    if options.allLists then
        for _, list in ipairs(data:GetLists()) do
            for _, item in ipairs(list.items) do
                items[#items + 1] = item
            end
        end
    elseif options.listId ~= nil or options.listName ~= nil then
        local list, listError = findList(data, options)
        if not list then
            return nil, listError
        end
        for _, item in ipairs(list.items) do
            items[#items + 1] = item
        end
    else
        items = data:GetShoppingItems()
    end

    local _, unallocated, matches = GravvyShoppingList.matcher:PreviewPurchase(
        items,
        itemLink,
        itemName,
        quantity,
        function(item) return data:GetRemainingQuantity(item) end
    )
    local result = {
        itemName = itemName,
        itemLink = itemLink,
        quantity = quantity,
        matched = false,
        applicableQuantity = quantity - unallocated,
        unallocatedQuantity = unallocated,
        matches = {},
    }
    for _, match in ipairs(matches) do
        if options.includeCompleted or match.remaining > 0 then
            local list = data:GetListForItem(match.entry.id)
            result.matches[#result.matches + 1] = {
                listId = list and list.id or nil,
                listName = list and list.name or nil,
                itemId = match.entry.id,
                itemName = match.entry.name,
                score = match.score,
                remaining = match.remaining,
                wouldApply = match.quantity,
                wouldComplete = match.remaining > 0
                    and match.quantity >= match.remaining,
            }
        end
    end
    result.matched = #result.matches > 0
    return result
end

function API:AddItem(itemLinkOrName, quantity, options)
    local data = getData()
    if not data or not data.AddItemsToList then
        return false, ERROR.NOT_READY
    end

    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    options = options or {}
    if options.silent ~= nil and type(options.silent) ~= "boolean" then
        return false, ERROR.INVALID_OPTIONS
    end
    local duplicatePolicy = readDuplicatePolicy(options.duplicatePolicy, "keep")
    if not duplicatePolicy then
        return false, ERROR.INVALID_OPTIONS
    end

    quantity = readWholeNumber(quantity, 1, MAX_QUANTITY)
    if not quantity then
        return false, ERROR.INVALID_QUANTITY
    end

    local prepared, itemError = prepareItem({
        item = itemLinkOrName,
        quantity = quantity,
        targetMode = options.targetMode,
        note = options.note,
        match = options.match,
    })
    if not prepared then
        return false, itemError
    end

    local list, listError = findList(data, options)
    if not list then
        return false, listError
    end

    local items = data:AddItemsToList(list.id, { prepared }, duplicatePolicy)
    if not items then
        return false, ERROR.BATCH_FAILED
    end

    refresh()
    if not options.silent and GravvyShoppingList.ui then
        GravvyShoppingList.ui:SetStatus(zo_strformat(
            GetString(SI_SHOPPING_LIST_STATUS_ADDED_ITEM),
            items[1].name
        ))
    end
    return true, items[1].id
end

function API:AddItems(sources, options)
    local data = getData()
    if not data or not data.AddItemsToList then
        return false, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    options = options or {}
    if options.silent ~= nil and type(options.silent) ~= "boolean" then
        return false, ERROR.INVALID_OPTIONS
    end
    local duplicatePolicy = readDuplicatePolicy(options.duplicatePolicy, "keep")
    if not duplicatePolicy then
        return false, ERROR.INVALID_OPTIONS
    end

    local prepared, itemError, itemIndex = prepareItems(sources)
    if not prepared then
        return false, itemError, itemIndex
    end

    local list, listError = findList(data, options)
    if not list then
        return false, listError
    end

    local items = data:AddItemsToList(list.id, prepared, duplicatePolicy)
    if not items then
        return false, ERROR.BATCH_FAILED
    end

    refresh()
    if not options.silent and #items > 0 and GravvyShoppingList.ui then
        GravvyShoppingList.ui:SetStatus(zo_strformat(
            GetString(SI_SHOPPING_LIST_STATUS_API_ITEMS_ADDED),
            #items,
            GetString(#items == 1
                and SI_SHOPPING_LIST_NOUN_ITEM
                or SI_SHOPPING_LIST_NOUN_ITEMS),
            list.name
        ))
    end
    return true, itemIds(items)
end

function API:AddCraftingMaterials(materials, options)
    local data = getData()
    if not data or not data.AddItemsToList then
        return false, ERROR.NOT_READY
    end
    if type(materials) ~= "table"
        or (options ~= nil and type(options) ~= "table")
    then
        return false, ERROR.INVALID_ITEMS
    end
    options = options or {}

    local count = #materials
    if count < 1 or count > MAX_BATCH_ITEMS then
        return false, count > MAX_BATCH_ITEMS
            and ERROR.TOO_MANY_ITEMS or ERROR.INVALID_ITEMS
    end
    for key in pairs(materials) do
        if type(key) ~= "number"
            or key ~= math.floor(key)
            or key < 1
            or key > count
        then
            return false, ERROR.INVALID_ITEMS
        end
    end

    local targetMode = options.targetMode or "own"
    if not ShoppingListModel:IsValidTargetMode(targetMode) then
        return false, ERROR.INVALID_OPTIONS
    end
    local duplicatePolicy = readDuplicatePolicy(
        options.duplicatePolicy,
        "merge"
    )
    if not duplicatePolicy then
        return false, ERROR.INVALID_OPTIONS
    end
    if options.note ~= nil and (type(options.note) ~= "string"
        or #options.note > ShoppingListModel.MAX_NOTE_LENGTH)
    then
        return false, ERROR.INVALID_OPTIONS
    end

    local sources = {}
    local requiredQuantity = 0
    for index, material in ipairs(materials) do
        if type(material) ~= "table" then
            return false, ERROR.INVALID_ITEM, index
        end
        local quantity = readWholeNumber(material.quantity, 1, MAX_QUANTITY)
        if not quantity then
            return false, ERROR.INVALID_QUANTITY, index
        end
        local source = {
            quantity = quantity,
            targetMode = targetMode,
            note = material.note ~= nil and material.note or options.note,
            match = material.match,
        }
        local itemValue = readEntryValue(material)
        if not itemValue then
            return false, ERROR.INVALID_ITEM, index
        end
        if material.item ~= nil then
            source.item = itemValue
        elseif material.itemLink ~= nil then
            source.itemLink = itemValue
        else
            source.name = itemValue
        end
        sources[index] = source
        requiredQuantity = requiredQuantity + quantity
    end

    local addOptions = {
        listId = options.listId,
        listName = options.listName,
        silent = options.silent,
        duplicatePolicy = duplicatePolicy,
    }
    local success, idsOrError, itemIndex = self:AddItems(sources, addOptions)
    if not success then
        return false, idsOrError, itemIndex
    end

    local list, listError = findList(data, options)
    if not list then
        return false, listError
    end
    local itemIds = {}
    local seen = {}
    for _, itemId in ipairs(idsOrError) do
        if not seen[itemId] then
            seen[itemId] = true
            itemIds[#itemIds + 1] = itemId
        end
    end
    return true, {
        listId = list.id,
        listName = list.name,
        itemIds = itemIds,
        materialCount = #itemIds,
        requiredQuantity = requiredQuantity,
        targetMode = targetMode,
        duplicatePolicy = duplicatePolicy,
    }
end

function API:CreateList(spec)
    local data = getData()
    if not data or not data.AddListWithItems then
        return false, ERROR.NOT_READY
    end
    if type(spec) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    if type(spec.name) ~= "string" then
        return false, ERROR.INVALID_LIST_NAME
    end

    local name = zo_strtrim(spec.name)
    if name == "" or #name > MAX_LIST_NAME_BYTES then
        return false, ERROR.INVALID_LIST_NAME
    end
    if spec.note ~= nil and type(spec.note) ~= "string" then
        return false, ERROR.INVALID_OPTIONS
    end
    if spec.note and #spec.note > ShoppingListModel.MAX_NOTE_LENGTH then
        return false, ERROR.INVALID_OPTIONS
    end
    if spec.category ~= nil and (type(spec.category) ~= "string"
        or #spec.category > ShoppingListModel.MAX_CATEGORY_LENGTH)
    then
        return false, ERROR.INVALID_OPTIONS
    end
    if spec.select ~= nil and type(spec.select) ~= "boolean" then
        return false, ERROR.INVALID_OPTIONS
    end
    if spec.silent ~= nil and type(spec.silent) ~= "boolean" then
        return false, ERROR.INVALID_OPTIONS
    end

    local onNameConflict = spec.onNameConflict or "error"
    if onNameConflict ~= "error" and onNameConflict ~= "unique" then
        return false, ERROR.INVALID_OPTIONS
    end
    if data:ListNameExists(name) then
        if onNameConflict == "error" then
            return false, ERROR.LIST_EXISTS
        end
        name = data:GetUniqueListName(name)
    end

    local sources = spec.items
    if sources == nil then
        sources = {}
    end
    local prepared, itemError, itemIndex = prepareItems(sources)
    if not prepared then
        return false, itemError, itemIndex
    end

    local list, items = data:AddListWithItems(
        name,
        spec.note,
        prepared,
        spec.select ~= false,
        spec.category
    )
    if not list then
        return false, ERROR.BATCH_FAILED
    end

    refresh()
    if not spec.silent and GravvyShoppingList.ui then
        GravvyShoppingList.ui:SetStatus(zo_strformat(
            GetString(SI_SHOPPING_LIST_STATUS_API_LIST_CREATED),
            list.name,
            #items,
            GetString(#items == 1
                and SI_SHOPPING_LIST_NOUN_ITEM
                or SI_SHOPPING_LIST_NOUN_ITEMS)
        ))
    end
    return true, {
        id = list.id,
        name = list.name,
        itemIds = itemIds(items),
    }
end

function API:UpdateList(changes, options)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if type(changes) ~= "table"
        or (options ~= nil and type(options) ~= "table")
    then
        return false, ERROR.INVALID_OPTIONS
    end
    options = options or {}
    local list, listError = findList(data, options)
    if not list then
        return false, listError
    end

    local allowed = {
        name = true,
        note = true,
        category = true,
        budget = true,
        favorite = true,
        pinned = true,
        recurring = true,
    }
    local count = 0
    for key in pairs(changes) do
        if not allowed[key] then
            return false, ERROR.INVALID_OPTIONS
        end
        count = count + 1
    end
    if count == 0 then
        return false, ERROR.INVALID_OPTIONS
    end

    local name
    if changes.name ~= nil then
        if type(changes.name) ~= "string" then
            return false, ERROR.INVALID_LIST_NAME
        end
        name = zo_strtrim(changes.name)
        if name == "" or #name > MAX_LIST_NAME_BYTES then
            return false, ERROR.INVALID_LIST_NAME
        end
        if data:ListNameExists(name, list.id) then
            return false, ERROR.LIST_EXISTS
        end
    end
    if changes.note ~= nil and (type(changes.note) ~= "string"
        or #changes.note > ShoppingListModel.MAX_NOTE_LENGTH)
    then
        return false, ERROR.INVALID_OPTIONS
    end
    if changes.category ~= nil and (type(changes.category) ~= "string"
        or #changes.category > ShoppingListModel.MAX_CATEGORY_LENGTH)
    then
        return false, ERROR.INVALID_OPTIONS
    end
    local budget
    if changes.budget ~= nil then
        budget = readWholeNumber(changes.budget, 0, ShoppingListModel.MAX_PRICE)
        if not budget then
            return false, ERROR.INVALID_OPTIONS
        end
    end
    for _, field in ipairs({ "favorite", "pinned", "recurring" }) do
        if changes[field] ~= nil and type(changes[field]) ~= "boolean" then
            return false, ERROR.INVALID_OPTIONS
        end
    end

    self:_PauseUpdates()
    if name then data:RenameList(list.id, name) end
    if changes.note ~= nil then data:UpdateListNote(list.id, changes.note) end
    if changes.category ~= nil then
        data:UpdateListCategory(list.id, changes.category)
    end
    if changes.budget ~= nil then data:UpdateListBudget(list.id, budget) end
    if changes.favorite ~= nil then
        data:SetListFavorite(list.id, changes.favorite)
    end
    if changes.pinned ~= nil then data:SetListPinned(list.id, changes.pinned) end
    if changes.recurring ~= nil then
        data:SetListRecurring(list.id, changes.recurring)
    end
    self:_ResumeUpdates()

    refresh()
    return true, snapshotList(data, list, false, true)
end

function API:SelectList(options)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    local list, listError = findList(data, options or {})
    if not list then
        return false, listError
    end
    if not data:SelectList(list.id) then
        return false, ERROR.LIST_NOT_FOUND
    end
    refresh()
    return true, snapshotList(data, list, false, true)
end

function API:MoveList(options, direction)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if (options ~= nil and type(options) ~= "table")
        or (direction ~= -1 and direction ~= 1)
    then
        return false, ERROR.INVALID_OPTIONS
    end
    local list, listError = findList(data, options or {})
    if not list then
        return false, listError
    end
    if not data:MoveList(list.id, direction) then
        return false, ERROR.BATCH_FAILED
    end
    refresh()
    return true, snapshotList(data, list, false, true)
end

function API:DuplicateList(spec)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if type(spec) ~= "table" or type(spec.name) ~= "string" then
        return false, ERROR.INVALID_OPTIONS
    end
    local source, listError = findList(data, spec)
    if not source then
        return false, listError
    end
    local name = zo_strtrim(spec.name)
    if name == "" or #name > MAX_LIST_NAME_BYTES then
        return false, ERROR.INVALID_LIST_NAME
    end
    if spec.note ~= nil and (type(spec.note) ~= "string"
        or #spec.note > ShoppingListModel.MAX_NOTE_LENGTH)
    then
        return false, ERROR.INVALID_OPTIONS
    end
    if spec.category ~= nil and (type(spec.category) ~= "string"
        or #spec.category > ShoppingListModel.MAX_CATEGORY_LENGTH)
    then
        return false, ERROR.INVALID_OPTIONS
    end
    if spec.select ~= nil and type(spec.select) ~= "boolean" then
        return false, ERROR.INVALID_OPTIONS
    end
    local onNameConflict = spec.onNameConflict or "error"
    if onNameConflict ~= "error" and onNameConflict ~= "unique" then
        return false, ERROR.INVALID_OPTIONS
    end
    if data:ListNameExists(name) then
        if onNameConflict == "error" then
            return false, ERROR.LIST_EXISTS
        end
        name = data:GetUniqueListName(name)
    end

    local copy = data:DuplicateList(
        source.id,
        name,
        spec.note,
        spec.category,
        spec.select ~= false
    )
    if not copy then
        return false, ERROR.BATCH_FAILED
    end
    refresh()
    return true, snapshotList(data, copy, false, true)
end

function API:DeleteList(options)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    local list, listError = findList(data, options or {})
    if not list then
        return false, listError
    end
    if #data:GetLists() <= 1 then
        return false, ERROR.LAST_LIST_REQUIRED
    end
    local snapshot = snapshotList(data, list, false, true)
    local ok = data:DeleteList(list.id)
    if not ok then
        return false, ERROR.BATCH_FAILED
    end
    refresh()
    return true, snapshot
end

function API:ArchiveList(options)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    local list, listError = findList(data, options or {})
    if not list then
        return false, listError
    end
    local ok, archived = data:ArchiveList(list.id)
    if not ok then
        return false, ERROR.BATCH_FAILED
    end
    refresh()
    return true, snapshotList(data, archived, true, true)
end

function API:RestoreList(options)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    local list, listError = findArchivedList(data, options)
    if not list then
        return false, listError
    end
    local ok, restored = data:RestoreList(list.id)
    if not ok then
        return false, ERROR.BATCH_FAILED
    end
    refresh()
    return true, snapshotList(data, restored, false, true)
end

function API:ResetListProgress(options)
    local data = getData()
    if not data then
        return false, ERROR.NOT_READY
    end
    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    local list, listError = findList(data, options or {})
    if not list then
        return false, listError
    end
    if not data:ListHasPurchaseProgress(list) then
        return true, 0
    end
    local ok, count = data:ResetListProgress(list.id)
    if not ok then
        return false, ERROR.BATCH_FAILED
    end
    refresh()
    return true, count
end

GravvyShoppingList.API = API
if GravvyShoppingList.data then
    API:_AttachData(GravvyShoppingList.data)
end
