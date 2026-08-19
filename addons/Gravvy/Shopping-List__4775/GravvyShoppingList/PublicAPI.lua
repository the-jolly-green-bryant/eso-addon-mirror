local API_VERSION = 1
local MAX_QUANTITY = 1000000

local ERROR = {
    NOT_READY = "NOT_READY",
    INVALID_ITEM = "INVALID_ITEM",
    INVALID_QUANTITY = "INVALID_QUANTITY",
    INVALID_OPTIONS = "INVALID_OPTIONS",
    LIST_NOT_FOUND = "LIST_NOT_FOUND",
}

local API = {
    VERSION = API_VERSION,
    ERROR = ERROR,
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
        return data:FindList(listId), ERROR.LIST_NOT_FOUND
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
    if not data or not GravvyShoppingList.AddItemToList then
        return false, ERROR.NOT_READY
    end

    if options ~= nil and type(options) ~= "table" then
        return false, ERROR.INVALID_OPTIONS
    end
    options = options or {}
    if options.note ~= nil and type(options.note) ~= "string" then
        return false, ERROR.INVALID_OPTIONS
    end
    if options.silent ~= nil and type(options.silent) ~= "boolean" then
        return false, ERROR.INVALID_OPTIONS
    end

    quantity = tonumber(quantity)
    if not quantity
        or quantity ~= math.floor(quantity)
        or quantity < 1
        or quantity > MAX_QUANTITY
    then
        return false, ERROR.INVALID_QUANTITY
    end

    local name, itemLink = readItem(itemLinkOrName)
    if not name then
        return false, ERROR.INVALID_ITEM
    end

    local list, listError = findList(data, options)
    if not list then
        return false, listError
    end

    local item = GravvyShoppingList:AddItemToList(
        list.id,
        name,
        quantity,
        itemLink,
        nil,
        options.note
    )
    if not item then
        return false, ERROR.INVALID_ITEM
    end

    if not options.silent and GravvyShoppingList.ui then
        GravvyShoppingList.ui:SetStatus(zo_strformat(
            GetString(SI_SHOPPING_LIST_STATUS_ADDED_ITEM),
            item.name
        ))
    end
    return true, item.id
end

GravvyShoppingList.API = API
