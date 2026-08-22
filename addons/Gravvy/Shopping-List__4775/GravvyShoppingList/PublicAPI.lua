local API_VERSION = 2
local MAX_QUANTITY = 1000000
local MAX_BATCH_ITEMS = 500
local MAX_LIST_NAME_BYTES = 512

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
}

local API = {
    VERSION = API_VERSION,
    ERROR = ERROR,
}

local QUALITY_MODES = {
    any = true,
    minimum = true,
    exact = true,
}

local LEVEL_MODES = {
    any = true,
    exact = true,
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
        if wanted == "" then
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

local function readItem(value)
    if type(value) ~= "string" then
        return nil
    end

    value = zo_strtrim(value)
    if value == "" then
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

    if values.traitType ~= nil then
        local traitType = readWholeNumber(values.traitType, 0)
        if not traitType then
            return nil, ERROR.INVALID_MATCH
        end
        rule.traitType = traitType
    end

    if values.qualityMode ~= nil then
        if type(values.qualityMode) ~= "string" or not QUALITY_MODES[values.qualityMode] then
            return nil, ERROR.INVALID_MATCH
        end
        rule.qualityMode = values.qualityMode
    end
    if values.quality ~= nil then
        local quality = readWholeNumber(values.quality, 0)
        if not quality then
            return nil, ERROR.INVALID_MATCH
        end
        rule.quality = quality
    end
    if rule.qualityMode ~= "any" and rule.quality == nil then
        return nil, ERROR.INVALID_MATCH
    end

    if values.levelMode ~= nil then
        if type(values.levelMode) ~= "string" or not LEVEL_MODES[values.levelMode] then
            return nil, ERROR.INVALID_MATCH
        end
        rule.levelMode = values.levelMode
    end
    if values.level ~= nil then
        local level = readWholeNumber(values.level, 1)
        if not level then
            return nil, ERROR.INVALID_MATCH
        end
        rule.level = level
    end
    if values.championPoints ~= nil then
        local championPoints = readWholeNumber(values.championPoints, 0)
        if not championPoints then
            return nil, ERROR.INVALID_MATCH
        end
        rule.championPoints = championPoints
    end
    if rule.levelMode == "exact"
        and (rule.level == nil or rule.championPoints == nil)
    then
        return nil, ERROR.INVALID_MATCH
    end

    return rule
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

    local match, matchError = prepareMatch(source.match, itemLink)
    if matchError then
        return nil, matchError
    end

    return {
        name = name,
        itemLink = itemLink,
        quantity = quantity,
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

    quantity = readWholeNumber(quantity, 1, MAX_QUANTITY)
    if not quantity then
        return false, ERROR.INVALID_QUANTITY
    end

    local prepared, itemError = prepareItem({
        item = itemLinkOrName,
        quantity = quantity,
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

    local items = data:AddItemsToList(list.id, { prepared })
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

    local prepared, itemError, itemIndex = prepareItems(sources)
    if not prepared then
        return false, itemError, itemIndex
    end

    local list, listError = findList(data, options)
    if not list then
        return false, listError
    end

    local items = data:AddItemsToList(list.id, prepared)
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
        spec.select ~= false
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

GravvyShoppingList.API = API
