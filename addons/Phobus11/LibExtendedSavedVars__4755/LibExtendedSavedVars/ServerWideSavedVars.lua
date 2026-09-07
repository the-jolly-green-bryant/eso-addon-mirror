-- =================================================================================================
-- Title:   LibExtendedSavedVars
-- Name:    LibExtendedSavedVars
-- Author:  Phobus11
-- Version: 2.3.0
-- Date:    2026-09-03 00:00:00 ServerWideSavedVars.lua
-- =================================================================================================

if LibExtendedSavedVars and LibExtendedSavedVars.serverWideSavedVarsVersion and LibExtendedSavedVars.serverWideSavedVarsVersion >= 8 then
    return
end

LibExtendedSavedVars = LibExtendedSavedVars or {}
LibExtendedSavedVars.ServerWideSavedVars = LibExtendedSavedVars.ServerWideSavedVars or {}
local SWSV = LibExtendedSavedVars.ServerWideSavedVars

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

local function GetServerWideRaw(savedVariableTable, namespace)
    local worldTable = GetWorldTable(savedVariableTable)
    worldTable.serverWide = worldTable.serverWide or {}
    worldTable.serverWide[namespace] = worldTable.serverWide[namespace] or {}
    return worldTable.serverWide[namespace]
end

function SWSV:New(savedVariableTable, version, namespace, defaults)
    local raw = GetServerWideRaw(savedVariableTable, namespace)
    if defaults then
        FillDefaults(raw, defaults)
    end
    local instance = {
        __state = { raw = raw, defaults = defaults or {}, version = version },
    }
    return setmetatable(instance, SWSV)
end

function SWSV:GetRawTable()
    return self.__state.raw
end

function SWSV:Version(version, onVersionUpdate)
    local raw = self.__state.raw
    if (raw["$dataVersion"] or 0) < version then
        onVersionUpdate(raw)
        raw["$dataVersion"] = version
    end
    return self
end

function SWSV:MigrateFrom(source, scalarKeys, tableKeys, migrationId)
    local raw = self.__state.raw
    migrationId = migrationId or "default"
    raw["$migrated"] = raw["$migrated"] or {}
    if raw["$migrated"][migrationId] then
        return self
    end

    if source then
        for _, key in ipairs(scalarKeys or {}) do
            if raw[key] == nil and source[key] ~= nil then
                raw[key] = source[key]
            end
        end
        for _, key in ipairs(tableKeys or {}) do
            if type(source[key]) == "table" and (type(raw[key]) ~= "table" or not next(raw[key])) then
                raw[key] = raw[key] or {}
                for k, v in pairs(source[key]) do
                    raw[key][k] = v
                end
            end
        end
    end

    raw["$migrated"][migrationId] = true
    return self
end

function SWSV.__index(instance, key)
    local classMember = rawget(SWSV, key)
    if classMember ~= nil then
        return classMember
    end
    return rawget(instance, "__state").raw[key]
end

function SWSV.__newindex(instance, key, value)
    rawget(instance, "__state").raw[key] = value
end

LibExtendedSavedVars.serverWideSavedVarsVersion = 8
