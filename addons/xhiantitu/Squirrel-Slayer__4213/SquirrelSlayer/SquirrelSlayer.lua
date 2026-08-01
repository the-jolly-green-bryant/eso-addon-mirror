-- ============================================================================
--  SquirrelSlayer : Orchestrateur principal
--  Toute la logique métier est répartie en services sous /services et /ui.
-- ============================================================================

local ADDON_NAME = "SquirrelSlayer"

SquirrelSlayer = SquirrelSlayer or {}
local addon = SquirrelSlayer

addon.LOG_ENABLED = addon.LOG_ENABLED == true
addon.Services = addon.Services or {}
addon.Internal = addon.Internal or {}
addon.State = addon.State or {}

-- Valeurs par défaut persistées dans les SavedVariables du compte.
local defaultSavedVariables = {
    total = 0,
    pos   = { x = 200, y = 200 },
    scale = nil,
    spots = {},

    knownRegions = {},
    regionNames  = {},
    mapNames     = {},
    mapToRegion  = {},
    mapToZone    = {},

    migration = { mapKeyVersion = 2, done = false },
    legacyMapKeyToId = {},

    statsUI = { x = 300, y = 200, w = 520, h = 600, page = 1, sort = "kills_desc" },
}

--- Retourne l'instance SavedVariables active pour l'addon.
--- @return table|nil savedVariables
addon.State.GetSV = addon.State.GetSV or function()
    return addon.State.SV
end

--- Définit l'instance SavedVariables active pour l'addon.
--- @param savedVariables table
addon.State.SetSV = addon.State.SetSV or function(savedVariables)
    addon.State.SV = savedVariables
end

--- Callback ESO déclenché lors du chargement d'un addon.
--- @param _ number eventId inutilisé
--- @param loadedAddonName string nom de l'addon chargé
local function OnAddOnLoaded(_, loadedAddonName)
    if loadedAddonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    -- 1) Charge et expose les SavedVariables.
    local savedVariables = ZO_SavedVars:NewAccountWide(ADDON_NAME .. "_SV", 1, nil, defaultSavedVariables)
    addon.State.SetSV(savedVariables)

    -- 2) Exécute les migrations de données si nécessaire.
    if addon.Services.Map then addon.Services.Map.MigrateLegacyMapKeysToMapId() end

    -- 3) Initialise les composants visuels.
    if addon.Internal.Log then addon.Internal.Log(addon.Internal.GetString("addon_loaded"), true) end
    if addon.Services.Hud then
        addon.Services.Hud.CreateUI()
        addon.Services.Hud.UpdateLabel()
    end
    if addon.Services.Pins then addon.Services.Pins.InitMapPins() end
    if addon.Services.Map then addon.Services.Map.RememberCurrentRegion() end
    if addon.Services.StatsUI and addon.Services.StatsUI.Initialize then addon.Services.StatsUI.Initialize() end

    -- 4) Branche les événements de gameplay.
    if addon.Services.Combat then addon.Services.Combat.RegisterEvents() end

    if addon.Internal.Log then addon.Internal.Log("Addon loaded.") end
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
