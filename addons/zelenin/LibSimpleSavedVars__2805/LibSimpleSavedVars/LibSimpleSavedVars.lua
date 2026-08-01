local addonId = "LibSimpleSavedVars"
local addon = ZO_Object:Subclass()

local function SearchPath(t, ...)
    local current = t
    for i = 1, select("#", ...) do

        local key = select(i, ...)

        if key ~= nil then
            if not current[key] then
                return nil
            end
            current = current[key]
        end
    end

    return current
end

local function CreatePath(t, ...)
    local current = t
    local container
    local containerKey
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if key ~= nil then
            if not current[key] then
                current[key] = {}
            end
            container = current
            containerKey = key
            current = current[key]
        end
    end

    return current, container, containerKey
end

local function SetPath(t, value, ...)
    if value ~= nil then
        CreatePath(t, ...)
    end
    local current = t
    local parent
    local lastKey
    for i = 1, select("#", ...) do
        local key = select(i, ...)
        if key ~= nil then
            lastKey = key
            parent = current
            if current == nil then
                return
            end
            current = current[key]
        end
    end
    if parent ~= nil then
        parent[lastKey] = value
    end
end

function addon:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function addon:initialize(name)
    self.name = name
    self.server = GetWorldName()
    self.account = GetDisplayName()
    self.characterId = GetCurrentCharacterId()
    self.version = self:getAddonData().version

    self.INSTALLATION_WIDE = 1
    self.SERVER_WIDE = 2
    self.ACCOUNT_WIDE = 3
    self.CHARACTER_WIDE = 4

    self.NA = "NA Megaserver"
    self.EU = "EU Megaserver"
    self.PTS = "PTS"
end

function addon:getAddonData()
    for index = 1, GetAddOnManager():GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = GetAddOnManager():GetAddOnInfo(index)
        if name == self.name then
            return {
                name = name,
                title = title,
                author = author,
                version = GetAddOnManager():GetAddOnVersion(index),
            }
        end
    end

    return nil
end

function addon:NewInstallationWide(name, version, defaults)
    return self:initSavedData(name, version, defaults, function()
        local current, container, containerKey = CreatePath(_G[name])
        return current, self.INSTALLATION_WIDE
    end)
end

function addon:NewServerWide(name, version, defaults)
    return self:initSavedData(name, version, defaults, function()
        local current, container, containerKey = CreatePath(_G[name], self.server)
        return current, self.SERVER_WIDE
    end)
end

function addon:NewAccountWide(name, version, defaults)
    return self:initSavedData(name, version, defaults, function()
        local current, container, containerKey = CreatePath(_G[name], self.server, self.account)
        return current, self.ACCOUNT_WIDE
    end)
end

function addon:NewCharacterWide(name, version, defaults)
    return self:initSavedData(name, version, defaults, function()
        local current, container, containerKey = CreatePath(_G[name], self.server, self.account, self.characterId)
        return current, self.CHARACTER_WIDE
    end)
end

function addon:GetInstallationData(name)
    return SearchPath(_G[name])
end

function addon:GetServerData(name, server)
    return SearchPath(_G[name], server and server or self.server)
end

function addon:GetAccountData(name, server, account)
    return SearchPath(_G[name], server and server or self.server, account and account or self.account)
end

function addon:GetCharacterData(name, server, account, characterId)
    return SearchPath(_G[name], server and server or self.server, account and account or self.account, characterId and characterId or self.characterId)
end

function addon:initSavedData(name, version, defaults, init)
    assert(type(name) == "string", "name must be a string")
    assert(type(version) == "number" and version > 0, "version must be a positive number")
    assert(type(defaults) == "table" or type(defaults) == "nil", "defaults must be a table or nil")

    if _G[name] == nil then
        _G[name] = {}
    end

    local data, dataType = init()

    if data.__meta == nil then
        data.__meta = {
            dataVersion = 0,
            type = dataType,
            libraryVersion = self.version
        }
    end

    if data.__meta.dataVersion < version then
        data = ZO_DeepTableCopy(type(defaults) == "table" and defaults or {}, data)
        data.__meta.dataVersion = version
    end

    return data
end

EVENT_MANAGER:RegisterForEvent(addonId, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName ~= addonId then
        return
    end
    assert(not _G[addonId], string.format("'%s' has already been loaded", addonId))
    _G[addonId] = addon:New(addonId)

    EVENT_MANAGER:UnregisterForEvent(addonId, EVENT_ADD_ON_LOADED)
end)
