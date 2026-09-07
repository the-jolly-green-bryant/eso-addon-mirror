-- =================================================================================================
-- Title:   LibExtendedSavedVars
-- Name:    LibExtendedSavedVars
-- Author:  Phobus11
-- Version: 2.3.0
-- Date:    2026-09-06 00:00:00 TieredSavedVars.lua
-- =================================================================================================

if LibExtendedSavedVars and LibExtendedSavedVars.tieredSavedVarsVersion and LibExtendedSavedVars.tieredSavedVarsVersion >= 8 then
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

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = DeepCopy(v)
    end
    return copy
end

local function SeedFromParent(parentRaw, targetRaw)
    for key, value in pairs(parentRaw) do
        if key == "$dataVersion" then
            targetRaw[key] = value
        elseif type(key) ~= "string" or string.sub(key, 1, 1) ~= "$" then
            targetRaw[key] = DeepCopy(value)
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

local function RawForScope(state, scope)
    if scope == LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER then
        return state.megaServerRaw
    elseif scope == LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT then
        return state.accountRaw
    end
    return state.characterRaw
end

local function GetActiveRawTable(state)
    return RawForScope(state, state.characterRaw["$scope"] or state.defaultScope)
end

local function InheritanceEnabled(state)
    local value = state.megaServerRaw["$inherit"]
    if value == nil then
        return true
    end
    return value
end

local function EnsureEstablished(state, scope)
    local raw = RawForScope(state, scope)
    if raw["$init"] then
        return
    end
    if InheritanceEnabled(state) and scope ~= LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER then
        local parentScope = LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT
        if scope == LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT then
            parentScope = LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER
        end
        EnsureEstablished(state, parentScope)
        SeedFromParent(RawForScope(state, parentScope), raw)
    end
    raw["$init"] = true
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

    for _, rawTable in ipairs({ megaServerRaw, accountRaw, characterRaw }) do
        if rawTable["$init"] == nil and next(rawTable) ~= nil then
            rawTable["$init"] = true
        end
    end

    FillDefaults(megaServerRaw, defaults)
    FillDefaults(accountRaw, defaults)
    FillDefaults(characterRaw, defaults)

    characterRaw["$scope"] = characterRaw["$scope"] or defaultScope or LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER

    local instance = {
        __state = { megaServerRaw = megaServerRaw, accountRaw = accountRaw, characterRaw = characterRaw, defaultScope = defaultScope or LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER, defaults = defaults },
    }
    EnsureEstablished(instance.__state, characterRaw["$scope"])
    return setmetatable(instance, TSV)
end

function TSV:GetScope()
    return self.__state.characterRaw["$scope"]
end

function TSV:SetScope(scope)
    self.__state.characterRaw["$scope"] = scope
    EnsureEstablished(self.__state, scope)
    return self
end

function TSV:GetInheritanceEnabled()
    return InheritanceEnabled(self.__state)
end

function TSV:SetInheritanceEnabled(enabled)
    self.__state.megaServerRaw["$inherit"] = enabled and true or false
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

function TSV:GetLibAddonMenuInheritanceCheckbox()
    return {
        type = "checkbox",
        width = "full",
        name = GetString(SI_LEV_INHERIT_SCOPES),
        tooltip = GetString(SI_LEV_INHERIT_SCOPES_TT),
        default = true,
        getFunc = function() return self:GetInheritanceEnabled() end,
        setFunc = function(value) self:SetInheritanceEnabled(value) end,
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
    local raw = GetActiveRawTable(rawget(instance, "__state"))
    raw[key] = value
    raw["$init"] = true
end

LibExtendedSavedVars.tieredSavedVarsVersion = 8
