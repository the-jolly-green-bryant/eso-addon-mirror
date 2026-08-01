--[[----------------------------------------------------------------------
    Dynamic Encounters : Wayshrine Cache
    Builds a zone to wayshrine lookup on load using nodeIndex (1..N).

    ESO API NOTE: GetFastTravelNodeInfo(index) returns 9 values:
      known, name, normalizedX, normalizedY, icon, glowIcon, poiType,
      isShownInCurrentMap, linkedCollectibleIsLocked
    The 7th value is poiType: WAYSHRINE=1, GROUP_DUNGEON=6, HOUSE=7.
    We use nodeIndex as the stable key and resolve zone lazily.

    Provides: zone dropdown data, wayshrine name lookup, click-to-map.
----------------------------------------------------------------------]]--

DynamicEncounters.Timers = DynamicEncounters.Timers or {}
local T = DynamicEncounters.Timers
local HE = DynamicEncounters

-- -------------------------------------------------------------------
-- cache structure:
--   T.wayshrinesByIndex[index] = { name, known, x, y, zoneId, houseId }
-- -------------------------------------------------------------------

T.wayshrinesByZone  = {}
T.wayshrinesByIndex = {}

-- -------------------------------------------------------------------
-- debug helper: only prints when DynamicEncounters.sv.debugMode is true
-- -------------------------------------------------------------------
local function dbg(msg)
    local ok, _ = pcall(function()
        if DynamicEncounters.sv.debugMode then
            d(msg)
        end
    end)
end

-- -------------------------------------------------------------------
-- build the cache (called once on addon load)
-- -------------------------------------------------------------------

function T.BuildWayshrineCache()
    T.wayshrinesByZone  = {}
    T.wayshrinesByIndex = {}

    local numNodes = GetNumFastTravelNodes()

    -- -------------------------------------------------------------------
    -- API PROBE: check ALL possible zone-resolution APIs in this ESO version
    -- -------------------------------------------------------------------
    if not T._apiProbeDone then
        T._apiProbeDone = true
        local apis = {
            "GetFastTravelNodePOIInfo", "ZO_GetFastTravelNodePOIInfo",
            "GetMapForFastTravelNode", "ZO_GetMapForFastTravelNode",
            "DoesMapHaveFastTravelNode", "ZO_DoesMapHaveFastTravelNode",
            "FAST_TRAVEL_MANAGER", "LibGPS", "LibGPS3",
            "GetFastTravelNodeZoneInfo", "GetNodeZoneInfo",
            "ZO_WorldMap_GetFastTravelNodeInfo",
        }
        for _, name in ipairs(apis) do
            local exists = _G[name] and "EXISTS" or "nil"
            dbg(string.format("[DE API Probe] %s = %s", name, exists))
        end
    end
    for i = 1, numNodes do
        -- API returns 9 values:
        --   known, name, x, y, icon, glowIcon, poiType,
        --   isShownInCurrentMap, linkedCollectibleIsLocked
        -- The 7th value is poiType:
        --   POI_TYPE_NONE=0, POI_TYPE_WAYSHRINE=1, POI_TYPE_GROUP_DUNGEON=6, POI_TYPE_HOUSE=7
        local known, name, x, y, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(i)

        -- Filter out player houses only (POI_TYPE_HOUSE = 7).
        -- Only houses (poiType == 7) are filtered out; wayshrines (poiType == 1) pass through.
        if poiType == nil then poiType = 0 end
        local isHouse = (poiType == 7)

        if not isHouse and name and name ~= "" then
            local entry = {
                index   = i,
                name    = name,
                known   = known,
                x       = x or 0,
                y       = y or 0,
                zoneId  = nil,     -- resolved by ResolveNodeZones
                zoneName = nil,   -- cached zone name
                poiType = poiType,
                isShownInCurrentMap = isShownInCurrentMap,
            }
            T.wayshrinesByIndex[i] = entry
        end
    end
end

-- -------------------------------------------------------------------
-- Resolve zoneId for ALL wayshrines by iterating zone maps.
-- This is the established technique (same as BeamMeUp addon).
-- Run once after EVENT_PLAYER_ACTIVATED. Node indices are stable per session.
-- -------------------------------------------------------------------

function T.ResolveNodeZones(forceReset)
    if not T.wayshrinesByIndex then return end

    -- If forceReset, clear all cached zoneIds so we re-resolve from scratch.
    -- This is used when the picker opens, to guarantee zone names are accurate
    -- even if a previous resolution was incorrect (e.g. old fallback bugs).
    if forceReset then
        for _, entry in pairs(T.wayshrinesByIndex) do
            entry.zoneId = nil
            entry.zoneName = nil
        end
    end

    -- Count how many nodes still need zone resolution
    local unresolved = 0
    for _, entry in pairs(T.wayshrinesByIndex) do
        if not entry.zoneId then unresolved = unresolved + 1 end
    end
    if unresolved == 0 then return end  -- all already resolved

    local numNodes = GetNumFastTravelNodes()

    -- -------------------------------------------------------------------
    -- PRIMARY METHOD: Hardcoded wayshrine lookup table
    -- This is the most reliable method: a complete table built from
    -- UESP data mapping wayshrine names to zone names. Zone names are
    -- resolved to zoneIds at runtime via GetMapInfo map names.
    --
    -- This bypasses both GetFastTravelNodePOIInfo (unavailable in some
    -- ESO versions) and the map-iteration fallback (unreliable for
    -- border nodes like Rawl'kha that appear on multiple zone maps).
    -- -------------------------------------------------------------------
    if not T._zoneResolveDiagDone then
        T._zoneResolveDiagDone = true
        dbg("[DynamicEncounters] Zone resolve: using hardcoded lookup table (primary)")
    end

    -- Build the zoneName->zoneId runtime map if not done yet
    if not T._zoneNameToId or next(T._zoneNameToId) == nil then
        T.BuildZoneNameToIdMap()
    end

    -- Apply the hardcoded table to all unresolved nodes
    local tableResolved = 0
    for _, entry in pairs(T.wayshrinesByIndex) do
        if not entry.zoneId then
            if T.ResolveZoneFromTable(entry) then
                tableResolved = tableResolved + 1
                unresolved = unresolved - 1
            end
        end
    end

    if not T._tableDiagDone then
        T._tableDiagDone = true
        dbg(string.format("[DE Debug] Hardcoded table: %d resolved, %d remaining", tableResolved, unresolved))
        local shown = 0
        for idx, entry in pairs(T.wayshrinesByIndex) do
            if shown < 5 and entry._resolvedViaTable then
                shown = shown + 1
                dbg(string.format("[DE Debug] node %d '%s' -> zoneId=%d zoneName='%s' via=TABLE",
                    idx, entry.name, entry.zoneId or 0, entry.zoneName or "nil"))
            end
        end
    end

    if unresolved <= 0 then
        T.DiagnoseUnresolvedWayshrines()
        return
    end

    -- -------------------------------------------------------------------
    -- SECONDARY METHOD: GetFastTravelNodePOIInfo (if available)
    -- For nodes not in the hardcoded table, try the ESO API.
    -- -------------------------------------------------------------------
    if GetFastTravelNodePOIInfo then
        for nodeIndex, entry in pairs(T.wayshrinesByIndex) do
            if not entry.zoneId then
                local rawZone, poiIndex = GetFastTravelNodePOIInfo(nodeIndex)
                if rawZone and rawZone > 0 then
                    local zoneId = rawZone
                    if rawZone < 100 then
                        zoneId = GetZoneId(rawZone)
                        if not zoneId or zoneId == 0 then
                            zoneId = GetZoneId(rawZone - 1)
                        end
                        if not zoneId or zoneId == 0 then
                            zoneId = GetZoneId(rawZone + 1)
                        end
                    end
                    if zoneId and zoneId > 0 and GetParentZoneId then
                        local parentId = GetParentZoneId(zoneId)
                        while parentId and parentId ~= 0 and parentId ~= zoneId do
                            zoneId = parentId
                            parentId = GetParentZoneId(zoneId)
                        end
                    end
                    if zoneId and zoneId > 0 then
                        entry.zoneId = zoneId
                        entry.zoneName = GetZoneNameById(zoneId)
                        entry._resolvedViaPOI = true
                        unresolved = unresolved - 1
                    end
                end
            end
        end
    end

    if unresolved <= 0 then
        T.DiagnoseUnresolvedWayshrines()
        return
    end

    -- -------------------------------------------------------------------
    -- FALLBACK METHOD: interiority-based map iteration
    -- For any nodes not resolved by GetFastTravelNodePOIInfo (rare),
    -- iterate zone/subzone maps and pick the zone where the wayshrine
    -- is furthest from the map EDGES (highest interiority score).
    --
    -- Why "interiority" instead of "closest to center"?  A border
    -- wayshrine like Rawl'kha (Reaper's March) appears on both the
    -- Auridon map and the Reaper's March map.  On Auridon's map it is
    -- right at the southern edge (interiority ~0.02).  On Reaper's
    -- March map it is well inside (interiority ~0.25).  "Closest to
    -- center" can fail when the wrong zone's map is small enough for
    -- the border node to be near its centre.  "Furthest from edges"
    -- is reliable because a node will always be near an edge on the
    -- WRONG zone's map.
    -- -------------------------------------------------------------------
    local numMaps = GetNumMaps()
    -- DIAGNOSTIC: count how many maps pass each filter gate
    local diagMapTotal, diagMapTypePass, diagZoneIdPass, diagSetMapPass, diagMatchFound = 0, 0, 0, 0, 0
    for mapIndex = 1, numMaps do
        local mapName, mapType, mapContentType, zoneIndex = GetMapInfo(mapIndex)
        diagMapTotal = diagMapTotal + 1
        -- Only process actual zone/subzone maps (skip continent/world/cosmic).
        -- Continent maps (MAPTYPE_WORLD=1, MAPTYPE_CONTINENT=2) show ALL nodes
        -- and would poison any distance/edge heuristic. MAPTYPE_ZONE=3,
        -- MAPTYPE_SUBZONE=4 are the map types that contain meaningful zone data.
        if zoneIndex and zoneIndex >= 0 and (mapType == MAPTYPE_ZONE or mapType == MAPTYPE_SUBZONE or mapType == 3 or mapType == 4) then
            diagMapTypePass = diagMapTypePass + 1
            local zoneId = GetZoneId(zoneIndex)
            -- DIAGNOSTIC: show maps that fail the zoneId check
            if not (zoneId and zoneId > 0) then
                dbg(string.format("[DE FB Diag] FILTERED OUT: map %d '%s' zoneId=%d (too low or nil)",
                    mapIndex, mapName or "?", zoneId or -1))
            end

            -- Allow all zoneIds > 0. ZoneId=0 maps (like Tamriel world map)
            -- are skipped because they show every node and poison heuristics.
            if zoneId and zoneId > 0 then
                diagZoneIdPass = diagZoneIdPass + 1
                -- Save map->zone mapping for hardcoded table building
                if not T._mapZones then T._mapZones = {} end
                T._mapZones[mapIndex] = {name = mapName, zoneId = zoneId}
                local result = SetMapToMapListIndex(mapIndex)
                -- DIAGNOSTIC: log first 3 SetMapToMapListIndex results + constant values
                if diagSetMapPass < 3 then
                    dbg(string.format("[DE FB Diag] map %d '%s' mapType=%d zoneId=%d SetMapResult=%d (CHANGED=%s UNCHANGED=%s)",
                        mapIndex, mapName or "?", mapType or -1, zoneId or -1, result or -1,
                        tostring(SET_MAP_RESULT_MAP_CHANGED), tostring(SET_MAP_RESULT_MAP_UNCHANGED)))
                end
                if result and (result == SET_MAP_RESULT_MAP_CHANGED or result == SET_MAP_RESULT_MAP_UNCHANGED or result == 0 or result == 1) then
                    diagSetMapPass = diagSetMapPass + 1
                    -- DIAGNOSTIC: confirm SetMapResult branch IS entered
                    if diagSetMapPass <= 3 then
                        dbg(string.format("[DE FB Diag] ENTERED SetMap success branch #%d for map %d '%s', now scanning %d nodes",
                            diagSetMapPass, mapIndex, mapName or "?", numNodes))
                    end
                    local nodeMatchedThisMap = 0
                    for nodeIndex = 1, numNodes do
                        local entry = T.wayshrinesByIndex[nodeIndex]
                        if entry and not entry.zoneId then
                            -- Get LIVE map-relative coordinates from GetFastTravelNodeInfo.
                            -- Using cached entry.x/entry.y is WRONG because those
                            -- coordinates were captured when the cache was built on a
                            -- potentially different map. After SetMapToMapListIndex
                            -- switches the active map, GetFastTravelNodeInfo returns
                            -- coordinates relative to the CURRENT map, which is what
                            -- we need for accurate edge-distance calculation.
                            local _, _, nodeX, nodeY, _, _, _, isShown = GetFastTravelNodeInfo(nodeIndex)
                            if isShown then
                                nodeMatchedThisMap = nodeMatchedThisMap + 1
                                diagMatchFound = diagMatchFound + 1
                                -- Unique-match: count how many maps show this node.
                                -- Only assign zoneId when it appears on exactly ONE map
                                -- (100% reliable). Border nodes showing on multiple maps
                                -- are left unresolved rather than guessed wrong.
                                if not entry._matchCount then entry._matchCount = 0 end
                                if not entry._lastZoneId then entry._lastZoneId = zoneId end
                                if not entry._lastZoneName then entry._lastZoneName = GetZoneNameById(zoneId) end
                                entry._matchCount = entry._matchCount + 1
                                entry._lastZoneId = zoneId
                                entry._lastZoneName = GetZoneNameById(zoneId)
                            end
                        end
                    end
                    dbg(string.format("[DE FB Diag] map %d '%s' zoneId=%d: %d isShown matches found", mapIndex, mapName or "?", zoneId or -1, nodeMatchedThisMap))
                end
            end
        end
    end
    -- DIAGNOSTIC: one-time summary of fallback filter gates
    if not T._fbDiagDone then
        T._fbDiagDone = true
        dbg(string.format("[DE FB Diag] SUMMARY: %d total maps -> %d mapType-pass -> %d zoneId-pass -> %d SetMap-pass -> %d isShown matches",
            diagMapTotal, diagMapTypePass, diagZoneIdPass, diagSetMapPass, diagMatchFound))
    end

    -- DIAGNOSTIC: check if interiority logic actually set candidates
    if not T._fbAssignDiagDone then
        T._fbAssignDiagDone = true
        local withCandidate = 0
        for _, entry in pairs(T.wayshrinesByIndex) do
            if entry._candidateZoneId then withCandidate = withCandidate + 1 end
        end
        dbg(string.format("[DE FB Diag] Pre-assign: %d entries have _candidateZoneId set", withCandidate))
        -- also dump first 3 entries' full state
        local dumped = 0
        for idx, entry in pairs(T.wayshrinesByIndex) do
            if dumped < 3 then
                dbg(string.format("[DE FB Diag] Pre-assign entry %d '%s': zoneId=%s candZoneId=%s candZoneName=%s bestInt=%s",
                    idx, entry.name or "?",
                    tostring(entry.zoneId), tostring(entry._candidateZoneId),
                    tostring(entry._candidateZoneName), tostring(entry._bestInteriority)))
                dumped = dumped + 1
            end
        end
    end

    -- Unique-match-only: assign zoneId only for nodes appearing on exactly
    -- ONE zone map (100% reliable). Border nodes stay unresolved.
    local assigned, skipped = 0, 0
    for _, entry in pairs(T.wayshrinesByIndex) do
        if not entry.zoneId then
            if entry._matchCount and entry._matchCount == 1 and entry._lastZoneId then
                entry.zoneId = entry._lastZoneId
                -- Only set zoneName from fallback if the table didn't already set one.
                -- The hardcoded table's zoneName is authoritative (from UESP).
                -- GetZoneNameById returns wrong names like "Clean Test" in some ESO versions.
                if not entry.zoneName or entry.zoneName == "" then
                    entry.zoneName = entry._lastZoneName
                end
                unresolved = unresolved - 1
                assigned = assigned + 1
            elseif entry._matchCount and entry._matchCount > 1 then
                skipped = skipped + 1
            end
        end
        -- Clean up temporary fields
        entry._matchCount = nil
        entry._lastZoneId = nil
        entry._lastZoneName = nil
        entry._bestInteriority = nil
        entry._candidateZoneId = nil
        entry._candidateZoneName = nil
    end
    if assigned > 0 or skipped > 0 then
        dbg(string.format("[DE FB Diag] Unique-match: %d assigned, %d skipped (multi-map)",
            assigned, skipped))
    end


    -- DEBUG: one-time diagnostic dump of resolved zones
    if forceReset and not T._debugDumpDone then
        T._debugDumpDone = true
        local poiCount, fbCount, total = 0, 0, 0
        for _, entry in pairs(T.wayshrinesByIndex) do
            if entry.zoneId then
                total = total + 1
                if entry._resolvedViaPOI then poiCount = poiCount + 1
                else fbCount = fbCount + 1 end
            end
        end
        dbg(string.format("[DE Debug] Zone resolve: %d total, %d via POI API, %d via fallback", total, poiCount, fbCount))

        -- Dump sample nodes: named ones + first 3
        local sampleNames = {["Rawl'kha"]=true, ["Mournhold"]=true, ["Vulkhel Guard"]=true}
        local dumped = 0
        for idx, entry in pairs(T.wayshrinesByIndex) do
            if dumped < 3 or sampleNames[entry.name] then
                local zoneId = entry.zoneId or 0
                local zoneName = entry.zoneName or GetZoneNameById(zoneId) or "nil"
                local via = entry._resolvedViaPOI and "POI" or "FB"
                dbg(string.format("[DE Debug] node %d '%s' -> zoneId=%d zoneName='%s' via=%s",
                    idx, entry.name, zoneId, zoneName, via))
                dumped = dumped + 1
            end
        end
    end

    -- Restore map to player location
    SetMapToPlayerLocation()

    -- Debug data writing removed: writing directly to DynamicEncountersSV
    -- bypassed ZO_SavedVars and could leak the account name. Diagnostics
    -- are now shown in chat only (when debugMode is enabled in settings).
    if forceReset and not T._svDebugWritten and HE.sv and HE.sv.debugMode then
        T._svDebugWritten = true
        local total, assigned = 0, 0
        for _, entry in pairs(T.wayshrinesByIndex) do
            total = total + 1
            if entry.zoneId and entry.zoneId > 0 then assigned = assigned + 1 end
        end
        dbg(string.format("[DE Debug] Zone resolve complete: %d/%d assigned", assigned, total))
    end
end

-- -------------------------------------------------------------------
-- Get the zone name for a wayshrine node (cached after ResolveNodeZones)
-- -------------------------------------------------------------------

local function ResolveZoneForNode(entry)
    if not entry then return nil end
    if entry.zoneId then return entry.zoneId end
    -- Do NOT guess. Previously this fell back to the player's current zone
    -- (HE.currentZoneId), which produced wrong zone labels whenever the
    -- player was in a different zone than the wayshrine. Return nil instead;
    -- callers can provide their own fallback zoneId if needed.
    return nil
end

-- -------------------------------------------------------------------
-- get zone name for a wayshrine node (by index)
-- -------------------------------------------------------------------

function T.GetWayshrineZoneName(index, fallbackZoneId)
    if not index then return nil end
    local entry = T.wayshrinesByIndex and T.wayshrinesByIndex[index]
    if not entry then return nil end
    -- Prefer entry.zoneName (set by hardcoded table) over GetZoneNameById
    -- which returns wrong names like Clean Test in some ESO versions.
    if entry.zoneName and entry.zoneName ~= "" then
        return entry.zoneName
    end
    local zoneId = entry.zoneId or fallbackZoneId
    if zoneId and zoneId > 0 then
        local zoneName = GetZoneNameById(zoneId)
        if zoneName and zoneName ~= "" and zoneName ~= "Clean Test" then return zoneName end
    end
    return entry.name
end

-- -------------------------------------------------------------------
-- click-to-map: open world map centered on the wayshrine
-- -------------------------------------------------------------------

function T.OpenMapToWayshrineZone(index)
    if not index then return end
    local entry = T.wayshrinesByIndex and T.wayshrinesByIndex[index]
    if not entry then return end

    -- If we know the zone, navigate the map there directly
    if entry.zoneId and entry.zoneId > 0 then
        if HE.OpenMapToZone then
            HE.OpenMapToZone(entry.zoneId)
        else
            ZO_WorldMap_ShowWorldMap()
            local mapIndex = GetMapIndexByZoneId(entry.zoneId)
            if mapIndex then SetMapToMapListIndex(mapIndex) end
        end
    else
        -- No zone info — just open the map
        ZO_WorldMap_ShowWorldMap()
    end
end

-- -------------------------------------------------------------------
-- Initiate actual fast travel to a node, with cost check.
-- Returns true if travel initiated, false if blocked.
-- -------------------------------------------------------------------

function T.CanFastTravelTo(index)
    if not index then return false, "No node selected" end
    if IsUnitInCombat("player") then return false, "Cannot travel while in combat" end

    local known, name = GetFastTravelNodeInfo(index)
    if not known then return false, "Wayshrine not discovered" end

    return true
end

function T.DoFastTravel(index)
    local ok, reason = T.CanFastTravelTo(index)
    if not ok then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, reason)
        return false
    end
    FastTravelToNode(index)
    return true
end

-- -------------------------------------------------------------------
-- Get recall cost text for display
-- -------------------------------------------------------------------

function T.GetTravelCostText()
    local cost = GetRecallCost()
    if cost == 0 then
        return "Free"
    end
    return zo_strformat("<<1>> gold", cost)
end

-- -------------------------------------------------------------------
-- get zone list for dropdown menu
-- -------------------------------------------------------------------

function T.GetZoneList()
    local zones = {}
    local seen = {}

    if HE.ENCOUNTERS then
        for zoneId in pairs(HE.ENCOUNTERS) do
            if not seen[zoneId] then
                seen[zoneId] = true
                zones[#zones + 1] = {
                    zoneId   = zoneId,
                    zoneName = HE.GetZoneName(zoneId) or ("Zone " .. zoneId),
                }
            end
        end
    end

    if HE.sv and HE.sv.timerSettings and HE.sv.timerSettings.list then
        for _, timer in pairs(HE.sv.timerSettings.list) do
            if timer.wayshrineZoneId and not seen[timer.wayshrineZoneId] then
                seen[timer.wayshrineZoneId] = true
                zones[#zones + 1] = {
                    zoneId   = timer.wayshrineZoneId,
                    zoneName = HE.GetZoneName(timer.wayshrineZoneId) or ("Zone " .. timer.wayshrineZoneId),
                }
            end
        end
    end

    table.sort(zones, function(a, b) return a.zoneName < b.zoneName end)
    return zones
end

-- -------------------------------------------------------------------
-- FindNearestWayshrine
-- Returns { index, zoneId, name } for the closest known wayshrine to
-- the player, or nil if none found.
-- -------------------------------------------------------------------

function T.FindNearestWayshrine()
    if not T.wayshrinesByIndex then return nil end

    -- Ensure zone IDs are resolved before searching. ResolveNodeZones
    -- self-guards (returns immediately if all nodes already resolved).
    if T.ResolveNodeZones then T.ResolveNodeZones() end

    local px, py = GetMapPlayerPosition("player")
    if not px or not py then return nil end

    -- Compare normalized map coordinates (0..1) against the player.
    -- Only consider nodes within 0.25 distance to avoid cross-zone matches.
    local bestDist, bestIndex, bestZoneId, bestName

    for index, entry in pairs(T.wayshrinesByIndex) do
        if entry.known then
            -- POI type filter: only match actual wayshrines (poiType == 1).
            -- Group dungeon nodes (poiType == 6) like "Blackheart Haven" are
            -- valid fast-travel targets but should NOT be suggested as the
            -- "nearest wayshrine" because their names are dungeon names, not
            -- zone names, and their zoneId is typically unresolved. Without
            -- this filter, a nearby dungeon node can be selected as "nearest"
            -- and its dungeon name would appear in the tooltip instead of the
            -- expected zone/wayshrine name.
            local poiType = entry.poiType or 0
            local isWayshrine = (poiType == 1)

            if isWayshrine then
                -- Compare normalized map coordinates (0..1) against the player.
                local dx = (entry.x or 0) - px
                local dy = (entry.y or 0) - py
                local dist = dx * dx + dy * dy

                -- ESO fast travel coordinates are in normalized [0..1] space
                -- for each zone map. Use a threshold (0.25 = quarter map)
                -- to avoid matching wayshrines on different maps.
                if dist < 0.25 then
                    if not bestDist or dist < bestDist then
                        bestDist = dist
                        bestIndex = index
                        bestZoneId = entry.zoneId
                        bestName = entry.name
                    end
                end
            end
        end
    end

    if bestIndex then
        return { index = bestIndex, zoneId = bestZoneId, name = bestName }
    end
    return nil
end


-- Old hardcoded zone tables moved to WayshrineZones.lua
-- (WAYSHRINE_ZONES, WAYSHRINE_ZONE_NAMES, ApplyHardcodedZones)
-- The new WayshrineZones.lua has a complete table with runtime zoneId resolution.
