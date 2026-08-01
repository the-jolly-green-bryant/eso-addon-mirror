local addon = SquirrelSlayer
addon.Services.Combat = addon.Services.Combat or {}
local Combat = addon.Services.Combat

--- Traite un kill local (EVENT_KILL_LOCALLY) pour incrémenter les stats écureuil.
--- @param _ number eventId inutilisé
--- @param targetName string nom de la cible tuée
--- @param _alliance any inutilisé
--- @param _unitType any inutilisé
--- @param _zoneId any inutilisé
--- @param _poi any inutilisé
--- @param _x any inutilisé
--- @param _y any inutilisé
--- @param isCritter boolean indique si la cible est une créature
local function OnKillLocally(_, targetName, _alliance, _unitType, _zoneId, _poi, _x, _y, isCritter)
    local savedVariables = addon.State.GetSV()
    if isCritter and addon.Internal.IsSquirrelName(targetName) then
        savedVariables.total = (savedVariables.total or 0) + 1
        addon.Services.Hud.UpdateLabel()
        local playerX, playerY, mapKey = addon.Services.Map.GetPlayerMapPos()
        addon.Services.Spots.AddSquirrelSpot(mapKey, playerX, playerY)
    end
end

--- Traite les événements de combat standards pour détecter les morts d'écureuils.
--- @param _ number eventId inutilisé
--- @param result number résultat de l'événement de combat
--- @param _ any paramètres intermédiaires inutilisés
--- @param _ any paramètres intermédiaires inutilisés
--- @param _ any paramètres intermédiaires inutilisés
--- @param _ any paramètres intermédiaires inutilisés
--- @param sourceName string nom de la source du dégât
--- @param _ any paramètre inutilisé
--- @param targetName string nom de la cible
local function OnCombatEvent(_, result, _, _, _, _, sourceName, _, targetName)
    local savedVariables = addon.State.GetSV()
    if result ~= ACTION_RESULT_DIED and result ~= ACTION_RESULT_DIED_XP then return end
    if not targetName or not addon.Internal.IsSquirrelName(targetName) then return end

    local cleanedSourceName = addon.Internal.CleanName(sourceName)
    local cleanedPlayerName = addon.Internal.CleanName(GetUnitName("player"))
    if cleanedSourceName == cleanedPlayerName then
        savedVariables.total = (savedVariables.total or 0) + 1
        addon.Services.Hud.UpdateLabel()
        local playerX, playerY, mapKey = addon.Services.Map.GetPlayerMapPos()
        addon.Services.Spots.AddSquirrelSpot(mapKey, playerX, playerY)
    end
end

--- Enregistre tous les événements combat nécessaires à l'addon.
function Combat.RegisterEvents()
    if EVENT_KILL_LOCALLY then
        EVENT_MANAGER:RegisterForEvent("SquirrelSlayer", EVENT_KILL_LOCALLY, OnKillLocally)
    end
    EVENT_MANAGER:RegisterForEvent("SquirrelSlayer", EVENT_COMBAT_EVENT, OnCombatEvent)
end
