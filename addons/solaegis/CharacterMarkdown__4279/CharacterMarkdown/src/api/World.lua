-- CharacterMarkdown - API Layer - World Progress
-- Skyshards, lorebooks, zone story completion, and dungeon progress

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.world = {}

local api = CM.api.world

local function CleanName(name)
    if not name or type(name) ~= "string" then
        return name or "Unknown"
    end
    return name:gsub("%^%w+$", "")
end

local function IsSkyshardAcquired(status)
    if not status then
        return false
    end
    if SKYSHARD_DISCOVERY_STATUS_ACQUIRED and status == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
        return true
    end
    -- Some clients treat DISCOVERED as collected for account progress
    if SKYSHARD_DISCOVERY_STATUS_DISCOVERED and status == SKYSHARD_DISCOVERY_STATUS_DISCOVERED then
        return true
    end
    return false
end

---Account-wide skyshard totals and per-zone breakdown (zones with shards only).
function api.GetSkyshards()
    local result = {
        collected = 0,
        total = 0,
        zones = {},
    }

    local numZones = CM.SafeCall(GetNumZones) or 0
    for zoneIndex = 1, numZones do
        local zoneId = CM.SafeCall(GetZoneId, zoneIndex)
        if zoneId and zoneId > 0 then
            local numInZone = CM.SafeCall(GetNumSkyshardsInZone, zoneId) or 0
            if numInZone > 0 then
                local zoneName = CleanName(CM.SafeCall(GetZoneNameById, zoneId) or "")
                if zoneName == "" then
                    zoneName = CleanName(CM.SafeCall(GetZoneNameByIndex, zoneIndex) or ("Zone " .. tostring(zoneId)))
                end

                local collected = 0
                for shardIndex = 1, numInZone do
                    local skyshardId = CM.SafeCall(GetZoneSkyshardId, zoneId, shardIndex)
                    if skyshardId and skyshardId > 0 then
                        local status = CM.SafeCall(GetSkyshardDiscoveryStatus, skyshardId)
                        if IsSkyshardAcquired(status) then
                            collected = collected + 1
                        end
                    end
                end

                local pct = numInZone > 0 and math.floor((collected / numInZone) * 100) or 0
                result.zones[zoneName] = {
                    collected = collected,
                    total = numInZone,
                    percentage = pct,
                    zoneId = zoneId,
                }
                result.collected = result.collected + collected
                result.total = result.total + numInZone
            end
        end
    end

    -- Fallback: global skyshard count if zone iteration found nothing
    if result.total == 0 then
        local numSkyshards = CM.SafeCall(GetNumSkyshards) or 0
        local collected = 0
        for i = 1, numSkyshards do
            local skyshardId = CM.SafeCall(GetSkyshardId, i)
            if skyshardId and skyshardId > 0 then
                local status = CM.SafeCall(GetSkyshardDiscoveryStatus, skyshardId)
                if IsSkyshardAcquired(status) then
                    collected = collected + 1
                end
            end
        end
        result.total = numSkyshards
        result.collected = collected
    end

    return result
end

---Full lore library summary by category (reuses Lore API).
function api.GetLorebooks()
    local result = {
        collected = 0,
        total = 0,
        categories = {},
    }

    local loreApi = CM.api.lore
    if not loreApi then
        return result
    end

    local numCategories = loreApi.GetNumCategories() or 0
    for catIndex = 1, numCategories do
        local catInfo = loreApi.GetCategoryInfo(catIndex)
        if catInfo and catInfo.name then
            local catCollected = 0
            local catTotal = 0
            local numCollections = catInfo.numCollections or 0
            for collIndex = 1, numCollections do
                local coll = loreApi.GetCollectionInfo(catIndex, collIndex)
                if coll and not coll.hidden then
                    catCollected = catCollected + (coll.numKnownBooks or 0)
                    catTotal = catTotal + (coll.totalBooks or 0)
                end
            end
            if catTotal > 0 then
                result.categories[CleanName(catInfo.name)] = {
                    collected = catCollected,
                    total = catTotal,
                }
                result.collected = result.collected + catCollected
                result.total = result.total + catTotal
            end
        end
    end

    return result
end

local function GetZoneActivityProgress(zoneId, completionType)
    if not zoneId or not completionType then
        return 0, 0
    end
    local total = CM.SafeCall(GetNumZoneActivitiesForZoneCompletionType, zoneId, completionType) or 0
    local completed = CM.SafeCall(GetNumCompletedZoneActivitiesForZoneCompletionType, zoneId, completionType) or 0
    return completed, total
end

---Current-zone completion percentage from zone-story activity types.
function api.GetCurrentZoneCompletion()
    local zoneIndex = CM.SafeCall(GetUnitZoneIndex, "player")
    local zoneId = zoneIndex and CM.SafeCall(GetZoneId, zoneIndex) or nil
    local zoneName = CleanName(
        CM.SafeCall(GetPlayerActiveZoneName)
            or (zoneId and CM.SafeCall(GetZoneNameById, zoneId))
            or CM.SafeCall(GetUnitZone, "player")
            or ""
    )

    local storyZoneId = zoneId
    if zoneId and GetZoneStoryZoneIdForZoneId then
        local mapped = CM.SafeCall(GetZoneStoryZoneIdForZoneId, zoneId)
        if mapped and mapped > 0 then
            storyZoneId = mapped
        end
    end

    local completedSum = 0
    local totalSum = 0
    local types = {
        ZONE_COMPLETION_TYPE_SKYSHARDS,
        ZONE_COMPLETION_TYPE_DELVES,
        ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS,
        ZONE_COMPLETION_TYPE_WAYSHRINES,
        ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST,
        ZONE_COMPLETION_TYPE_STRIKING_LOCALES,
        ZONE_COMPLETION_TYPE_WORLD_EVENTS,
        ZONE_COMPLETION_TYPE_GROUP_BOSSES,
        ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
    }

    if storyZoneId then
        for _, ctype in ipairs(types) do
            if ctype then
                local completed, total = GetZoneActivityProgress(storyZoneId, ctype)
                completedSum = completedSum + completed
                totalSum = totalSum + total
            end
        end
    end

    local percent = totalSum > 0 and math.floor((completedSum / totalSum) * 100) or 0

    -- Optional direct API when present
    if GetZoneCompletionStatus and zoneIndex then
        local direct = CM.SafeCall(GetZoneCompletionStatus, zoneIndex)
        if direct and type(direct) == "number" and direct > 0 then
            percent = math.floor(direct)
            if percent > 100 then
                percent = math.floor(direct * 100)
            end
            if percent > 100 then
                percent = 100
            end
        end
    end

    return {
        currentZone = zoneName,
        zoneId = zoneId,
        completionPercentage = percent,
        completedActivities = completedSum,
        totalActivities = totalSum,
        isZoneStoryComplete = storyZoneId and (CM.SafeCall(IsZoneStoryComplete, storyZoneId) or false) or false,
        isZoneStoryStarted = storyZoneId and (CM.SafeCall(IsZoneStoryStarted, storyZoneId) or false) or false,
    }
end

---Aggregate delve / public dungeon progress across zone-story zones.
function api.GetDungeonProgress()
    local delvesCompleted, delvesTotal = 0, 0
    local pdCompleted, pdTotal = 0, 0

    local lastZoneId = nil
    local safety = 0
    while safety < 500 do
        safety = safety + 1
        local nextId = CM.SafeCall(GetNextZoneStoryZoneId, lastZoneId)
        if not nextId or nextId == 0 or nextId == lastZoneId then
            break
        end
        lastZoneId = nextId

        if ZONE_COMPLETION_TYPE_DELVES then
            local c, t = GetZoneActivityProgress(nextId, ZONE_COMPLETION_TYPE_DELVES)
            delvesCompleted = delvesCompleted + c
            delvesTotal = delvesTotal + t
        end
        if ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS then
            local c, t = GetZoneActivityProgress(nextId, ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS)
            pdCompleted = pdCompleted + c
            pdTotal = pdTotal + t
        end
    end

    return {
        delves = {
            completed = delvesCompleted,
            total = delvesTotal,
        },
        publicDungeons = {
            completed = pdCompleted,
            total = pdTotal,
        },
    }
end

---Cadwell progression summary (Bronze / Silver / Gold).
function api.GetCadwellProgress()
    local level = CM.SafeCall(GetCadwellProgressionLevel)
    if level == nil then
        return nil
    end

    local levelName = "Unknown"
    if CADWELL_PROGRESSION_LEVEL_BRONZE and level == CADWELL_PROGRESSION_LEVEL_BRONZE then
        levelName = "Bronze"
    elseif CADWELL_PROGRESSION_LEVEL_SILVER and level == CADWELL_PROGRESSION_LEVEL_SILVER then
        levelName = "Silver"
    elseif CADWELL_PROGRESSION_LEVEL_GOLD and level == CADWELL_PROGRESSION_LEVEL_GOLD then
        levelName = "Gold"
    else
        levelName = tostring(level)
    end

    local zones = {}
    local numZones = CM.SafeCall(GetNumZonesForCadwellProgressionLevel, level) or 0
    for zoneIndex = 1, numZones do
        local success, zoneName, zoneDescription, zoneOrder =
            CM.SafeCallMulti(GetCadwellZoneInfo, level, zoneIndex)
        if success and zoneName then
            table.insert(zones, {
                name = CleanName(zoneName),
                description = zoneDescription,
                order = zoneOrder,
            })
        end
    end

    return {
        level = level,
        levelName = levelName,
        zones = zones,
        zoneCount = #zones,
    }
end

CM.DebugPrint("API", "World API module loaded")
