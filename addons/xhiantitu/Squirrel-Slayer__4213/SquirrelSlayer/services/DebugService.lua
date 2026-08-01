local addon = SquirrelSlayer

--- Proxy de log standard.
--- @param message string
--- @param force boolean|nil
local function Log(message, force)
    if addon.Internal.Log then addon.Internal.Log(message, force) end
end

--- Proxy de log erreur.
--- @param message string
local function LogError(message)
    if addon.Internal.LogError then addon.Internal.LogError(message) end
end

--- Retourne une chaîne localisée.
--- @param key string
--- @return string
local function GetString(key)
    return addon.GetString(key)
end

--- Enregistre les commandes slash réservées au mode debug.
local function RegisterDebugOnlyCommands()
    SLASH_COMMANDS["/sqsquirrel"] = function()
        local savedVariables = addon.State.GetSV()
        local playerX, playerY, mapKey = addon.Services.Map.GetPlayerMapPos()
        if not mapKey or not playerX or not playerY then LogError(GetString("no_player_pos")); return end

        savedVariables.total = (savedVariables.total or 0) + 1
        addon.Services.Hud.UpdateLabel()
        addon.Services.Spots.AddSquirrelSpot(mapKey, playerX, playerY)
        Log(string.format("[SquirrelSlayer] " .. GetString("sim_squirrel"), playerX, playerY, tostring(mapKey)))
    end

    SLASH_COMMANDS["/sqmerge"] = function()
        local playerX, playerY, mapKey = addon.Services.Map.GetPlayerMapPos()
        if not mapKey or not playerX or not playerY then LogError(GetString("no_player_pos")); return end

        local hasResult, neighborsCount, mergedX, mergedY, mergedTotalCount = addon.Services.Spots.MergeAroundPosition(mapKey, playerX, playerY)
        if hasResult == nil then Log("[SquirrelSlayer] No spots to merge on this map.", true); return end
        if hasResult == false then
            Log(string.format("[SquirrelSlayer] Nothing to merge here (neighbors=%d).", neighborsCount or 0), true)
            return
        end

        Log(string.format("[SquirrelSlayer] Merged around %.5f, %.5f => %.5f, %.5f (count=%d).", playerX, playerY, mergedX or -1, mergedY or -1, mergedTotalCount or 0), true)
    end
end

--- Retire les commandes debug pour éviter leur usage hors mode debug.
local function UnregisterDebugOnlyCommands()
    SLASH_COMMANDS["/sqsquirrel"] = nil
    SLASH_COMMANDS["/sqmerge"] = nil
end

-- Commande principale d'activation/désactivation du mode debug.
SLASH_COMMANDS["/sqdebug"] = function()
    addon.LOG_ENABLED = not addon.LOG_ENABLED
    if addon.LOG_ENABLED then
        Log(GetString("debug_on"), true)
        RegisterDebugOnlyCommands()
    else
        Log(GetString("debug_off"), true)
        UnregisterDebugOnlyCommands()
    end
end
