-- =================================================================================================
-- Title:   LibExtendedSavedVars
-- Name:    LibExtendedSavedVars
-- Author:  Phobus11
-- Version: 2.1.1
-- Date:    2026-08-05 00:00:00 LibExtendedSavedVars.lua
-- =================================================================================================

if LibExtendedSavedVars and LibExtendedSavedVars.version and LibExtendedSavedVars.version >= 5 then
    return
end

local libExtendedSavedVarsStrings = LIBEXTENDEDSAVEDVARS_STRINGS
LIBEXTENDEDSAVEDVARS_STRINGS = nil
for stringId, value in pairs(libExtendedSavedVarsStrings) do
    ZO_CreateStringId(stringId, value)
end

LibExtendedSavedVars = LibExtendedSavedVars or {}
local LEV = LibExtendedSavedVars
LEV.version = 5

LIBEXTENDEDSAVEDVARS_SCOPE_CHARACTER = 1
LIBEXTENDEDSAVEDVARS_SCOPE_ACCOUNT = 2
LIBEXTENDEDSAVEDVARS_SCOPE_MEGASERVER = 3

function LEV.NewTieredSavedVars(savedVariableTable, version, namespace, defaults, defaultScope)
    return LEV.TieredSavedVars:New(savedVariableTable, version, namespace, defaults, defaultScope)
end
