TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.Config = {
    addonName = "Tamriel-Races",
    displayName = "Tamriel Races - STARS Edition",
    version = "0.8.0-rc2-navtest2",
    savedVariablesName = "TamrielRaces_SV",
    savedVariablesVersion = 4,
    updateName = "TamrielRacesTick",
    updateMs = 900,
    arrivalRadius = 0.00075,
    transitionGraceDurationMs = 180000,
    fastTravelActivationWindowMs = 15000,
    finalActivationMemoryMs = 2000,
    routeGenerationAttempts = 48,
    minimumFreshWayshrines = 4,
    minimumEndpointDistanceRatio = 0.55,
    compassPingType = MAP_PIN_TYPE_RALLY_POINT,
    compassPinType = "TAMRIEL_RACES_COMPASS",
}

TR.Defaults = {
    loaded = 0,
    records = {},
    racesCompleted = 0,
    lastRace = nil,
    nextRaceId = 0,
    raceHistory = {},
    bestOverall = {},
    bestByZone = {},
    lastGeneratedRoutesByZone = {},
    statistics = {
        totalRaces = 0,
        validFinishes = 0,
        forfeits = 0,
        zonesRaced = {},
    },
    settings = {
        diagnostics = false,
    },
}

TR.Util = TR.Util or {}

function TR.Util.NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

function TR.Util.FormatMs(ms)
    ms = math.max(0, tonumber(ms) or 0)
    local totalSeconds = math.floor(ms / 1000)
    local minutes = math.floor(totalSeconds / 60)
    local seconds = totalSeconds % 60
    local tenths = math.floor((ms % 1000) / 100)
    return string.format("%02d:%02d.%d", minutes, seconds, tenths)
end

function TR.Util.Distance2D(x1, y1, x2, y2)
    local dx = (tonumber(x1) or 0) - (tonumber(x2) or 0)
    local dy = (tonumber(y1) or 0) - (tonumber(y2) or 0)
    return math.sqrt(dx * dx + dy * dy)
end

function TR.Util.ToUniversal(mapId, x, y)
    if not mapId or not GetUniversallyNormalizedMapInfo then return x, y end
    local ox, oy, w, h = GetUniversallyNormalizedMapInfo(mapId)
    if not ox or not oy or not w or not h then return x, y end
    return ox + (x * w), oy + (y * h)
end

function TR.Util.FromUniversal(mapId, ux, uy)
    if not mapId or not GetUniversallyNormalizedMapInfo then return nil end
    local ox, oy, w, h = GetUniversallyNormalizedMapInfo(mapId)
    if not ox or not oy or not w or not h or w == 0 or h == 0 then return nil end
    return (ux - ox) / w, (uy - oy) / h
end

function TR.Util.GetCheckpointMapPosition(checkpoint, mapId)
    if type(checkpoint) ~= "table" then return nil end
    mapId = mapId or (GetCurrentMapId and GetCurrentMapId() or nil)

    if mapId and checkpoint.ux and checkpoint.uy then
        local x, y = TR.Util.FromUniversal(mapId, checkpoint.ux, checkpoint.uy)
        if x and y then return x, y end
    end

    if not checkpoint.mapId or not mapId or checkpoint.mapId == mapId then
        return checkpoint.x, checkpoint.y
    end

    return nil
end

function TR:NotifyChanged()
    if LibSTARSConnect and type(LibSTARSConnect.NotifyDataChanged) == "function" then
        LibSTARSConnect:NotifyDataChanged("tamriel_races")
    end
end
