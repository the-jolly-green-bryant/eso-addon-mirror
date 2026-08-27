local ADDON_NAME = "ShoppingList"

local function copyData(value, seen)
    local valueType = type(value)
    if valueType == "nil" or valueType == "boolean"
        or valueType == "number" or valueType == "string"
    then
        return value
    end
    if valueType ~= "table" then
        return nil
    end
    seen = seen or {}
    if seen[value] then
        return nil
    end
    seen[value] = true
    local result = {}
    for key, entry in pairs(value) do
        local copied = copyData(entry, seen)
        if copied ~= nil then
            result[key] = copied
        end
    end
    seen[value] = nil
    return result
end

local function getFormerAccountData()
    local raw = ShoppingList_Data
    if type(raw) ~= "table" then
        return nil
    end
    local profile = raw[GetWorldName()] or raw.Default
    if type(profile) ~= "table" then
        return nil
    end
    local account = profile[GetDisplayName()]
    if type(account) ~= "table" then
        return nil
    end
    local saved = account["$AccountWide"] or account
    return type(saved) == "table" and copyData(saved) or nil
end

local function onLoaded(_, name)
    if name ~= ADDON_NAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(
        "GravvyShoppingList_LegacyRecovery",
        EVENT_ADD_ON_LOADED
    )

    GravvyShoppingListLegacySavedVariables = {
        saved = getFormerAccountData(),
        source = ADDON_NAME,
        world = GetWorldName(),
    }
end

EVENT_MANAGER:RegisterForEvent(
    "GravvyShoppingList_LegacyRecovery",
    EVENT_ADD_ON_LOADED,
    onLoaded
)
