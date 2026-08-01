TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.RaceRecords = TR.RaceRecords or {}
local Records = TR.RaceRecords

local HISTORY_LIMIT = 25

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d, e
end

local function CopyRoute(route)
    local result = {}
    for index, checkpoint in ipairs(route or {}) do
        result[index] = {
            nodeIndex = checkpoint.nodeIndex,
            zoneIndex = checkpoint.zoneIndex,
            poiIndex = checkpoint.poiIndex,
            name = checkpoint.name,
        }
    end
    return result
end

function Records:GetDifficultySnapshot()
    local difficultyId = SafeCall(GetUnitOverlandDifficulty, "player")
    if difficultyId == nil then difficultyId = SafeCall(GetOverlandDifficulty) end

    local difficultyName = nil
    if difficultyId ~= nil and type(GetString) == "function" then
        difficultyName = SafeCall(GetString, "SI_OVERLANDDIFFICULTYTYPE", difficultyId)
    end

    return {
        id = difficultyId,
        name = (type(difficultyName) == "string" and difficultyName ~= "") and difficultyName or "Unknown",
    }
end

function Records:GetMountSnapshot()
    local collectibleId = nil
    if type(GetActiveCollectibleByType) == "function" and COLLECTIBLE_CATEGORY_TYPE_MOUNT ~= nil then
        collectibleId = SafeCall(GetActiveCollectibleByType, COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    end
    if (not collectibleId or collectibleId == 0)
        and type(GetActiveCollectibleByCategoryType) == "function"
        and COLLECTIBLE_CATEGORY_TYPE_MOUNT ~= nil then
        collectibleId = SafeCall(GetActiveCollectibleByCategoryType, COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    end

    collectibleId = tonumber(collectibleId) or 0
    if collectibleId <= 0 then
        return { collectibleId = 0, name = "No active mount", icon = "" }
    end

    local name, _, icon = SafeCall(GetCollectibleInfo, collectibleId)
    return {
        collectibleId = collectibleId,
        name = (type(name) == "string" and name ~= "") and name or ("Mount " .. tostring(collectibleId)),
        icon = type(icon) == "string" and icon or "",
    }
end

function Records:CaptureStartContext()
    local state = TR.State
    local difficulty = self:GetDifficultySnapshot()
    local mount = self:GetMountSnapshot()

    state.raceDifficulty = difficulty.id
    state.raceDifficultyName = difficulty.name
    state.raceMount = mount
    state.raceModeId = state.raceModeId or "point_to_point"
    state.raceModeName = state.raceModeName or "Point-to-Point"
    state.raceTypeId = state.raceTypeId or "wayshrine_route"
    state.raceTypeName = state.raceTypeName or "Wayshrine Route"
    state.raceStartedTimestamp = GetTimeStamp and GetTimeStamp() or 0

    TR.sv.statistics = TR.sv.statistics or {}
    TR.sv.statistics.totalRaces = (tonumber(TR.sv.statistics.totalRaces) or 0) + 1
end

local function RecordKey(modeId, difficultyId)
    return tostring(modeId or "unknown") .. ":" .. tostring(difficultyId or "unknown")
end

function Records:UpdateBestRecords(record)
    if record.forfeited then return end

    TR.sv.bestOverall = TR.sv.bestOverall or {}
    TR.sv.bestByZone = TR.sv.bestByZone or {}

    local key = RecordKey(record.modeId, record.difficultyId)
    local overall = TR.sv.bestOverall[key]
    if not overall or record.time < overall.time then
        TR.sv.bestOverall[key] = {
            raceId = record.id, time = record.time,
            zoneIndex = record.zoneIndex, zone = record.zone,
            difficultyId = record.difficultyId, difficultyName = record.difficultyName,
            modeId = record.modeId, modeName = record.modeName,
            mountCollectibleId = record.mountCollectibleId,
            mountName = record.mountName, mountIcon = record.mountIcon,
            timestamp = record.timestamp,
        }
    end

    local zoneKey = tostring(record.zoneIndex or record.zone or "unknown")
    TR.sv.bestByZone[zoneKey] = TR.sv.bestByZone[zoneKey] or {}
    local zoneBest = TR.sv.bestByZone[zoneKey][key]
    if not zoneBest or record.time < zoneBest.time then
        TR.sv.bestByZone[zoneKey][key] = {
            raceId = record.id, time = record.time,
            zoneIndex = record.zoneIndex, zone = record.zone,
            difficultyId = record.difficultyId, difficultyName = record.difficultyName,
            modeId = record.modeId, modeName = record.modeName,
            mountCollectibleId = record.mountCollectibleId,
            mountName = record.mountName, mountIcon = record.mountIcon,
            timestamp = record.timestamp,
        }
    end
end

function Records:StoreRace(elapsed, result)
    local state = TR.State
    local timestamp = GetTimeStamp and GetTimeStamp() or 0
    TR.sv.nextRaceId = (tonumber(TR.sv.nextRaceId) or 0) + 1

    local route = CopyRoute(state.route)
    local first, last = route[1], route[#route]
    local mount = state.raceMount or { collectibleId = 0, name = "Unknown", icon = "" }
    local record = {
        id = TR.sv.nextRaceId,
        timestamp = timestamp,
        startedTimestamp = state.raceStartedTimestamp or timestamp,
        characterName = GetUnitName and GetUnitName("player") or "Unknown",
        zoneIndex = state.currentZoneIndex,
        zone = result.zone,
        modeId = state.raceModeId or "point_to_point",
        modeName = state.raceModeName or "Point-to-Point",
        raceTypeId = state.raceTypeId or "wayshrine_route",
        raceTypeName = state.raceTypeName or "Wayshrine Route",
        difficultyId = state.raceDifficulty,
        difficultyName = state.raceDifficultyName or "Unknown",
        startName = first and first.name or "Unknown",
        finishName = last and last.name or "Unknown",
        checkpointCount = #route,
        checkpoints = route,
        time = elapsed,
        forfeited = result.forfeited == true,
        reason = result.reason,
        mountCollectibleId = mount.collectibleId or 0,
        mountName = mount.name or "Unknown",
        mountIcon = mount.icon or "",
    }

    TR.sv.raceHistory = TR.sv.raceHistory or {}
    table.insert(TR.sv.raceHistory, 1, record)
    while #TR.sv.raceHistory > HISTORY_LIMIT do table.remove(TR.sv.raceHistory) end

    TR.sv.statistics = TR.sv.statistics or {}
    TR.sv.statistics.zonesRaced = TR.sv.statistics.zonesRaced or {}
    TR.sv.statistics.zonesRaced[tostring(record.zoneIndex or record.zone or "unknown")] = true
    if record.forfeited then
        TR.sv.statistics.forfeits = (tonumber(TR.sv.statistics.forfeits) or 0) + 1
    else
        TR.sv.statistics.validFinishes = (tonumber(TR.sv.statistics.validFinishes) or 0) + 1
    end

    self:UpdateBestRecords(record)
    TR.sv.lastRace = record
    state.lastResult = record
    return record
end

function Records:GetZoneCount()
    local count = 0
    local zones = TR.sv and TR.sv.statistics and TR.sv.statistics.zonesRaced or {}
    for _ in pairs(zones) do count = count + 1 end
    return count
end

function Records:OnRaceStarted() self:CaptureStartContext() end

TR.Controller:RegisterModule("RaceRecords", Records)
