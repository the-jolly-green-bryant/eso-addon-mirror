ShoppingListSetCatalog = {}

local Catalog = ShoppingListSetCatalog
local MAX_MATCHED_SETS = 8
local MAX_RESULTS = 40

local function normalize(value)
    value = zo_strtrim(type(value) == "string" and value or "")
    return zo_strlower(value)
end

local function canTrade(itemLink)
    if not GetItemLinkBindType then
        return false
    end
    local bindType = GetItemLinkBindType(itemLink)
    return bindType == BIND_TYPE_NONE or bindType == BIND_TYPE_ON_EQUIP
end

function Catalog:New()
    local catalog = setmetatable({ entries = {}, itemCache = {} }, { __index = self })
    catalog:Refresh()
    return catalog
end

function Catalog:Refresh()
    self.entries = {}
    self.itemCache = {}
    if not LibSets
        or not LibSets.GetAllSetIds
        or not LibSets.GetSetName
        or (LibSets.checkIfSetsAreLoadedProperly
            and not LibSets.checkIfSetsAreLoadedProperly()) then
        return
    end

    local seen = {}
    for setId in pairs(LibSets.GetAllSetIds() or {}) do
        local name = zo_strtrim(LibSets.GetSetName(setId) or "")
        local searchName = normalize(name)
        if name ~= "" and not seen[searchName] then
            seen[searchName] = true
            self.entries[#self.entries + 1] = {
                setId = setId,
                name = name,
                searchName = searchName,
            }
        end
    end
    table.sort(self.entries, function(left, right)
        return left.searchName < right.searchName
    end)
end

function Catalog:GetTradeableItems(entry)
    if self.itemCache[entry.setId] then
        return self.itemCache[entry.setId]
    end

    local items = {}
    self.itemCache[entry.setId] = items
    if not LibSets.GetSetItemIds or not LibSets.buildItemLink then
        return items
    end

    local seen = {}
    for itemId in pairs(LibSets.GetSetItemIds(entry.setId, false) or {}) do
        local itemLink = LibSets.buildItemLink(itemId, 366)
        if itemLink and itemLink ~= "" and canTrade(itemLink) then
            local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink) or "")
            local key = normalize(name)
            if name ~= "" and not seen[key] then
                seen[key] = true
                items[#items + 1] = {
                    name = name,
                    itemLink = itemLink,
                    setId = entry.setId,
                    setName = entry.name,
                }
            end
        end
    end
    table.sort(items, function(left, right)
        return normalize(left.name) < normalize(right.name)
    end)
    return items
end

function Catalog:Search(text)
    local query = normalize(text)
    if #query < 2 then
        return {}
    end

    local startsWith = {}
    local contains = {}
    for _, entry in ipairs(self.entries) do
        local position = string.find(entry.searchName, query, 1, true)
        if position == 1 then
            startsWith[#startsWith + 1] = entry
        elseif position then
            contains[#contains + 1] = entry
        end
    end

    local results = {}
    local matchedSets = 0
    for _, group in ipairs({ startsWith, contains }) do
        for _, entry in ipairs(group) do
            matchedSets = matchedSets + 1
            for _, item in ipairs(self:GetTradeableItems(entry)) do
                results[#results + 1] = item
                if #results == MAX_RESULTS then
                    return results
                end
            end
            if matchedSets == MAX_MATCHED_SETS then
                return results
            end
        end
    end
    return results
end
