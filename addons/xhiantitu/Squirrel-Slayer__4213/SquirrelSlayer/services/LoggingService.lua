local addon = SquirrelSlayer
local ADDON_NAME = "SquirrelSlayer"

--- Écrit un message dans le chat debug ESO.
--- @param message string
--- @param force boolean|nil si true, log même hors mode debug
local function Log(message, force)
    if force or addon.LOG_ENABLED then
        d(string.format("|cFFD400[%s]|r %s", ADDON_NAME, tostring(message)))
    end
end

--- Écrit un message d'erreur en rouge.
--- @param message string
local function LogError(message)
    Log(string.format("|cFF4444%s|r", tostring(message)), true)
end

addon.Internal.Log = Log
addon.Internal.LogError = LogError
addon.Internal.GetString = function(key) return addon.GetString(key) end
