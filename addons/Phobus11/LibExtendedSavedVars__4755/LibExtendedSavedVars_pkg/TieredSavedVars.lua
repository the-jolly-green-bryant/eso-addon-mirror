-- =================================================================================================
-- Title:   LibExtendedSavedVars
-- Name:    LibExtendedSavedVars
-- Author:  Phobus11
-- Version: 2.1.1
-- Date:    2026-08-05 00:00:00 TieredSavedVars.lua
-- =================================================================================================

if LibExtendedSavedVars and LibExtendedSavedVars.tieredSavedVarsVersion and LibExtendedSavedVars.tieredSavedVarsVersion >= 5 then
    return
end

LibExtendedSavedVars = LibExtendedSavedVars or {}
LibExtendedSavedVars.TieredSavedVars = LibExtendedSavedVars.TieredSavedVars or {}
local TSV = LibExtendedSavedVars.TieredSavedVars

local function FillDefaults(target, defaults)
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            FillDefaults(target[key], defaultValue)
        elseif target[key] == nil then
            target[key] = defaultValue
        end
    end
end

local function CopyUncustomizedValues(source, destination, defaults, isTopLevel)
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            CopyUncustomizedValues(source[key], destination[key], defaultValue, false)
        elseif not isTopLevel and destination[key] == defaultValue and source[key] ~= nil then
            destination[key] = source[key]
        end
    end
end

local function GetWorldTable(savedVariableTable)
    local root = _G[savedVariableTable]
    if type(root) ~= "table" then
        root = {}
        _G[savedVariableTable] = root
    end
    local worldName = GetWorldName()
    if type(root[worldName]) ~= "table" then
        root[worldName] = {}
    end
    return root[worldName]
end

local function GetActiveRawTable(state)
    local scope = state.characterRaw["$scope"] or state.defaultScope
    if scope == LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER then
        return state.megaServerRaw
    elseif scope == LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT then
        return state.accountRaw
    end
    return state.characterRaw
end

function TSV:New(savedVariableTable, version, namespace, defaults, defaultScope)
    local worldTable = GetWorldTable(savedVariableTable)

    worldTable.megaServer = worldTable.megaServer or {}
    worldTable.megaServer[namespace] = worldTable.megaServer[namespace] or {}
    local megaServerRaw = worldTable.megaServer[namespace]

    worldTable.accounts = worldTable.accounts or {}
    local displayName = GetDisplayName()
    worldTable.accounts[displayName] = worldTable.accounts[displayName] or {}
    local accountEntry = worldTable.accounts[displayName]

    accountEntry.account = accountEntry.account or {}
    accountEntry.account[namespace] = accountEntry.account[namespace] or {}
    local accountRaw = accountEntry.account[namespace]

    accountEntry.characters = accountEntry.characters or {}
    local characterId = GetCurrentCharacterId()
    accountEntry.characters[characterId] = accountEntry.characters[characterId] or {}
    accountEntry.characters[characterId][namespace] = accountEntry.characters[characterId][namespace] or {}
    local characterRaw = accountEntry.characters[characterId][namespace]

    FillDefaults(megaServerRaw, defaults)
    FillDefaults(accountRaw, defaults)
    FillDefaults(characterRaw, defaults)

    characterRaw["$scope"] = characterRaw["$scope"] or defaultScope or LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER

    local instance = {
        __state = { megaServerRaw = megaServerRaw, accountRaw = accountRaw, characterRaw = characterRaw, defaultScope = defaultScope or LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER, defaults = defaults },
    }
    return setmetatable(instance, TSV)
end

function TSV:GetScope()
    return self.__state.characterRaw["$scope"]
end

function TSV:SetScope(scope)
    local state = self.__state
    local oldRaw = GetActiveRawTable(state)
    state.characterRaw["$scope"] = scope
    local newRaw = GetActiveRawTable(state)
    if newRaw ~= oldRaw then
        CopyUncustomizedValues(oldRaw, newRaw, state.defaults, true)
    end
    return self
end

function TSV:GetLibAddonMenuScopeDropdown()
    return {
        type = "dropdown",
        width = "full",
        choices = { GetString(SI_LEV_SCOPE_MEGASERVER), GetString(SI_LEV_SCOPE_ACCOUNT), GetString(SI_LEV_SCOPE_CHARACTER) },
        choicesValues = { LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER, LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT, LIBEXTENDEDSAVEDVARS_SCOPE_CHARACTER },
        name = GetString(SI_LEV_SETTINGS_SCOPE),
        tooltip = GetString(SI_LEV_SETTINGS_SCOPE_TT),
        getFunc = function() return self:GetScope() end,
        setFunc = function(value) self:SetScope(value) end,
    }
end

function TSV:Version(version, onVersionUpdate)
    local state = self.__state
    for _, rawTable in ipairs({ state.megaServerRaw, state.accountRaw, state.characterRaw }) do
        if (rawTable["$dataVersion"] or 0) < version then
            onVersionUpdate(rawTable)
            rawTable["$dataVersion"] = version
        end
    end
    return self
end

function TSV.__index(instance, key)
    local classMember = rawget(TSV, key)
    if classMember ~= nil then
        return classMember
    end
    return GetActiveRawTable(rawget(instance, "__state"))[key]
end

function TSV.__newindex(instance, key, value)
    GetActiveRawTable(rawget(instance, "__state"))[key] = value
end

LibExtendedSavedVars.tieredSavedVarsVersion = 5
