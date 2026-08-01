-- Main.lua: Imperative initialization and orchestration
-- This is the main entry point that wires everything together

local SmartTrader = SmartTrader

local CL = SmartTrader.GetLogger()

---Initialize the addon
local function Initialize()
    local State = SmartTrader.State
    local GuildActions = SmartTrader.GuildActions
    local ReticleActions = SmartTrader.ReticleActions
    local ScanActions = SmartTrader.ScanActions
    local MapActions = SmartTrader.MapActions
    local GuildUtils = SmartTrader.GuildUtils

    -- Initialize state (defaults) then load saved variables
    SmartTrader.state = State.Create()
    SmartTrader.state.savedVars = ZO_SavedVars:NewAccountWide(
        "SmartTraderSavedVars",
        6, -- Bumped version for removing flipState/lastGuildScanTime
        nil,
        SmartTrader.state.savedVars
    )

    local currentTime = GetTimeStamp()
    math.randomseed(GetTimeStamp() + GetFrameTimeMilliseconds())
    ReticleActions.Initialize()
    MapActions.Initialize()

    -- Register event listeners
    EVENT_MANAGER:RegisterForEvent(SmartTrader.name, EVENT_GUILD_FINDER_SEARCH_COMPLETE, function(eventId, searchId)
        ScanActions.OnSearchComplete(searchId)
    end)

    EVENT_MANAGER:RegisterForEvent(SmartTrader.name, EVENT_PLAYER_ACTIVATED, function(eventId, initial)
        local savedVars = SmartTrader.state.savedVars
        local now = GetTimeStamp()

        -- Single rescan check: is cache valid?
        local needsRescan = (not savedVars.nextFlipTime) or (now >= savedVars.nextFlipTime)

        if needsRescan then
            -- RESCAN FLOW: Clear → Derive → Scan
            CL:Log("[SmartTrader] Cache expired - starting scan...")

            -- Clear trader locations but preserve guild sizes
            GuildActions.ClearTraderLocationsPreserveGuilds()

            -- Derive new expiry timestamp (flip + grace)
            local baseFlip = GuildUtils.GetNextTraderFlipTime(GetWorldName(), now)
            local grace = 15 * 60 + math.random(0, 15 * 60)
            savedVars.nextFlipTime = baseFlip + grace

            -- Start scan
            ScanActions.StartFullScan()
        end
    end)

end

---Handle slash commands
---@param args string
local function HandleCommand(args)
    local GuildUtils = SmartTrader.GuildUtils
    local ReticleUtils = SmartTrader.ReticleUtils
    local ScanActions = SmartTrader.ScanActions
    local ExportActions = SmartTrader.ExportActions

    args = args or ""
    local firstArg, rest = args:match("^(%S+)%s*(.*)$")

    -- Handle /st export commands
    if firstArg == "export" or firstArg == "exp" then
        if ExportActions and ExportActions.HandleCommand then
            ExportActions.HandleCommand(rest or "")
        else
            CL:Log("[SmartTrader] Export module not available.")
        end
        return
    end

    local function Trim(text)
        if not text then
            return ""
        end
        text = tostring(text)
        text = text:gsub("^%s+", "")
        text = text:gsub("%s+$", "")
        return text
    end

    local firstLower = firstArg and string.lower(firstArg) or ""
    local restTrimmed = Trim(rest)

    if firstLower == "map" then
        local sub, subRest = restTrimmed:match("^(%S+)%s*(.*)$")
        sub = sub and string.lower(sub) or ""
        subRest = Trim(subRest)

        ---@param zoneIndex luaindex|number|nil
        ---@return integer|nil zoneId
        ---@return integer|nil parentZoneId
        local function GetZoneContextForZoneIndex(zoneIndex)
            local zi = tonumber(zoneIndex) or 0
            if zi <= 0 then
                return nil, nil
            end

            local zoneId = nil
            if GetZoneId then
                zoneId = GetZoneId(zi)
                if type(zoneId) ~= "number" or zoneId == 0 then
                    zoneId = nil
                end
            end

            local parentZoneId = nil
            if ZO_ExplorationUtils_GetParentZoneIdByZoneIndex then
                local derived = ZO_ExplorationUtils_GetParentZoneIdByZoneIndex(zi)
                if type(derived) == "number" and derived ~= 0 then
                    parentZoneId = derived
                end
            end

            if (not parentZoneId) and zoneId and GetParentZoneId then
                local p = GetParentZoneId(zoneId)
                if type(p) == "number" and p ~= 0 then
                    parentZoneId = p
                end
            end

            return zoneId, parentZoneId
        end

        ---@param value number
        ---@return number
        local function Clamp01(value)
            if value < 0 then return 0 end
            if value > 1 then return 1 end
            return value
        end

        ---@param clickX number
        ---@param clickY number
        ---@return luaindex|nil resultingMapIndex
        local function FindResultingMapIndex(clickX, clickY)
            if not WouldProcessMapClick then return nil end

            local would, idx = WouldProcessMapClick(clickX, clickY)
            if would and idx then
                return idx
            end

            -- If the exact spot doesn't yield a map transition, try a few points around it (AGS-style).
            for i = 0, 7 do
                local a = math.pi * i / 4
                local nx = Clamp01(clickX + math.cos(a) * 0.05)
                local ny = Clamp01(clickY + math.sin(a) * 0.05)
                local w, j = WouldProcessMapClick(nx, ny)
                if w and j then
                    return j
                end
            end

            return nil
        end

        ---@param clickX number
        ---@param clickY number
        ---@return boolean changed
        local function TryProcessMapClickJitter(clickX, clickY)
            if not ProcessMapClick then return false end

            local result = ProcessMapClick(clickX, clickY)
            if result == SET_MAP_RESULT_MAP_CHANGED then
                return true
            end

            -- Even if WouldProcessMapClick returns false, some maps require slightly different click targets.
            for i = 0, 7 do
                local a = math.pi * i / 4
                local nx = Clamp01(clickX + math.cos(a) * 0.05)
                local ny = Clamp01(clickY + math.sin(a) * 0.05)
                local r = ProcessMapClick(nx, ny)
                if r == SET_MAP_RESULT_MAP_CHANGED then
                    return true
                end
            end

            return false
        end

        ---@param mapIndex luaindex|number
        ---@return SetMapResultCode|nil
        local function SetMapByIndexSafely(mapIndex)
            ---@type SetMapResultCode
            local SET_MAP_FAILED = SET_MAP_RESULT_FAILED

            local idx = tonumber(mapIndex) or 0
            if idx <= 0 then
                return SET_MAP_FAILED
            end

            -- Prefer WORLD_MAP_MANAGER so the UI doesn't snap back to player location.
            if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapByIndex then
                WORLD_MAP_MANAGER:SetMapByIndex(idx)
                return nil
            end

            if SetMapToMapListIndex then
                return SetMapToMapListIndex(idx)
            end

            return SET_MAP_FAILED
        end

        ---@param mapId integer|number
        ---@return SetMapResultCode|nil
        local function SetMapByIdSafely(mapId)
            ---@type SetMapResultCode
            local SET_MAP_FAILED = SET_MAP_RESULT_FAILED

            local id = tonumber(mapId) or 0
            if id <= 0 then
                return SET_MAP_FAILED
            end

            -- Prefer WORLD_MAP_MANAGER so the UI doesn't snap back to player location.
            if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById then
                WORLD_MAP_MANAGER:SetMapById(id)
                return nil
            end

            if SetMapToMapId then
                return SetMapToMapId(id)
            end

            return SET_MAP_FAILED
        end

        if sub == "" or sub == "help" then
            CL:Log("[SmartTrader] Map debug commands:")
            CL:Log(
                "  /st map info              - Show current mapIndex/mapId/mapType/contentType/zoneIndex/zoneId/parentZoneId")
            CL:Log("  /st map zonemaps [all]    - List mapIndexes that share your current parentZoneId (shows zoneIndex too)")
            CL:Log(
                "  /st map cityids [all]     - Match current zone POI names to map list entries; prints candidate city mapIds")
            CL:Log(
                "  /st map childzones [all]  - List zones whose parentZoneId matches current zone; prints their mapIds (often includes cities)")
            CL:Log(
                "  /st map scanids [all] [maxId] - Scan mapIds 1..maxId and print those that belong to the current zone (finds hidden city maps)")
            CL:Log("  /st map scanids stop      - Cancel an in-progress scanids run")
            CL:Log(
                "  /st map find <text>       - Search the entire map list by name, prints mapIndex/mapId/mapType/contentType/zoneIndex")
            CL:Log("  /st map pois [all]        - List POIs and their WouldProcessMapClick resulting mapIndex (if any)")
            CL:Log("  /st map openidx <mapIndex>- Set map by mapIndex (useful after zonemaps)")
            CL:Log("  /st map openid <mapId>    - Set map by mapId (useful if you already know the city mapId)")
            CL:Log("  /st map openpoi <poiIndex>- Try to open the map behind a POI (no-click via WouldProcessMapClick)")
            CL:Log("  /st map clickpoi <poiIndex>- Actually click a POI (ProcessMapClick + jitter) and report map change")
            CL:Log(
                "  /st map trycity [click]   - Try to open the first eligible child map discovered via POIs (or click mode)")
            return
        end

        if sub == "info" then
            local mapIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
            local mapId = GetCurrentMapId and GetCurrentMapId() or nil
            local mapName = GetMapName and GetMapName() or nil
            local mapType = GetMapType and GetMapType() or nil
            local mapContentType = GetMapContentType and GetMapContentType() or nil
            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            local zoneId, parentZoneId = GetZoneContextForZoneIndex(zoneIndex)

            CL:Log(string.format(
                "[SmartTrader] map info: mapIndex=%s mapId=%s mapType=%s contentType=%s zoneIndex=%s zoneId=%s parentZoneId=%s name=%s",
                tostring(mapIndex), tostring(mapId), tostring(mapType), tostring(mapContentType), tostring(zoneIndex),
                tostring(zoneId), tostring(parentZoneId), tostring(mapName)))
            return
        end

        if sub == "zonemaps" or sub == "zone" or sub == "zones" then
            if not GetNumMaps or not GetMapInfoByIndex then
                CL:Log("[SmartTrader] map zonemaps: missing map list APIs (GetNumMaps/GetMapInfoByIndex).")
                return
            end

            local anchorZoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            local anchorZoneId, anchorParentZoneId = GetZoneContextForZoneIndex(anchorZoneIndex)

            CL:Log(string.format(
                "[SmartTrader] map zonemaps: anchor zoneIndex=%s zoneId=%s parentZoneId=%s",
                tostring(anchorZoneIndex), tostring(anchorZoneId), tostring(anchorParentZoneId)))

            local numMaps = GetNumMaps() or 0
            local maxShow = (subRest == "all") and 500 or 100
            local shown = 0
            local matched = 0

            for mapIndex = 1, numMaps do
                local mapName, mapType, mapContentType, zoneIndex = GetMapInfoByIndex(mapIndex)
                local zoneId, parentZoneId = GetZoneContextForZoneIndex(zoneIndex)

                local inScope = false
                if anchorParentZoneId and parentZoneId and parentZoneId == anchorParentZoneId then
                    inScope = true
                elseif (not anchorParentZoneId) and anchorZoneId and zoneId and zoneId == anchorZoneId then
                    inScope = true
                elseif anchorZoneIndex and zoneIndex and zoneIndex == anchorZoneIndex then
                    inScope = true
                end

                if inScope then
                    matched = matched + 1
                    if shown < maxShow then
                        shown = shown + 1
                        local mapId = GetMapIdByIndex and GetMapIdByIndex(mapIndex) or 0
                        CL:Log(string.format(
                            "  mapIndex=%d mapId=%s mapType=%s contentType=%s zoneIndex=%s zoneId=%s parentZoneId=%s name=%s",
                            mapIndex, tostring(mapId), tostring(mapType), tostring(mapContentType),
                            tostring(zoneIndex), tostring(zoneId), tostring(parentZoneId), tostring(mapName)))
                    end
                end
            end

            if matched == 0 then
                CL:Log("[SmartTrader] map zonemaps: no mapIndexes matched this zone context.")
                return
            end
            if matched > shown then
                CL:Log(string.format("  ... and %d more (use: /st map zonemaps all)", matched - shown))
            end
            CL:Log(string.format("[SmartTrader] map zonemaps: matched=%d shown=%d", matched, shown))
            return
        end

        if sub == "childzones" then
            local anchorZoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not anchorZoneIndex or anchorZoneIndex == 0 then
                CL:Log("[SmartTrader] map childzones: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetNumZones or not GetZoneId or not GetParentZoneId then
                CL:Log("[SmartTrader] map childzones: missing zone APIs (GetNumZones/GetZoneId/GetParentZoneId).")
                return
            end
            if not GetMapIdByZoneId or not GetMapInfoById then
                CL:Log("[SmartTrader] map childzones: missing map APIs (GetMapIdByZoneId/GetMapInfoById).")
                return
            end

            local anchorZoneId, anchorParentZoneId = GetZoneContextForZoneIndex(anchorZoneIndex)
            if not anchorZoneId then
                CL:Log("[SmartTrader] map childzones: could not resolve anchor zoneId.")
                return
            end

            ---@type { zoneIndex: number, zoneId: integer, parentZoneId: integer, zoneName: string, mapId: integer, mapIndex: luaindex|nil, mapName: string, mapType: UIMapType, mapContentType: MapContentType, mapZoneIndex: luaindex|number|nil }[]
            local rows = {}

            local numZones = GetNumZones() or 0
            for zoneListIndex = 1, numZones do
                local zoneId = GetZoneId(zoneListIndex)
                if zoneId and zoneId ~= 0 then
                    local parentZoneId = GetParentZoneId(zoneId)
                    local isChild = false
                    if parentZoneId == anchorZoneId then
                        isChild = true
                    elseif anchorParentZoneId and parentZoneId == anchorParentZoneId then
                        isChild = true
                    end

                    if isChild then
                        local mapId = GetMapIdByZoneId(zoneId)
                        if type(mapId) == "number" and mapId ~= 0 then
                            local mapName, mapType, mapContentType, mapZoneIndex = GetMapInfoById(mapId)
                            local include = true

                            -- Default: show only city/town-like maps (non-dungeon, non-pvp, zone/subzone).
                            if subRest ~= "all" then
                                include = false
                                if mapContentType == MAP_CONTENT_NONE and (mapType == MAPTYPE_ZONE or mapType == MAPTYPE_SUBZONE) then
                                    include = true
                                end
                            end

                            if include then
                                local zoneName = (GetZoneNameById and GetZoneNameById(zoneId)) or ""
                                local mapIndex = (GetMapIndexByZoneId and GetMapIndexByZoneId(zoneId)) or
                                    (GetMapIndexById and GetMapIndexById(mapId)) or nil
                                rows[#rows + 1] = {
                                    zoneIndex = zoneListIndex,
                                    zoneId = zoneId,
                                    parentZoneId = parentZoneId,
                                    zoneName = tostring(zoneName or ""),
                                    mapId = mapId,
                                    mapIndex = mapIndex,
                                    mapName = tostring(mapName or ""),
                                    mapType = mapType,
                                    mapContentType = mapContentType,
                                    mapZoneIndex = mapZoneIndex,
                                }
                            end
                        end
                    end
                end
            end

            table.sort(rows, function(a, b)
                return tostring(a.mapName or "") < tostring(b.mapName or "")
            end)

            CL:Log(string.format(
                "[SmartTrader] map childzones: anchor zoneIndex=%s zoneId=%s parentZoneId=%s matches=%d (mode=%s)",
                tostring(anchorZoneIndex), tostring(anchorZoneId), tostring(anchorParentZoneId), #rows,
                (subRest == "all") and "all" or "cities"))

            if #rows == 0 then
                CL:Log(
                    "[SmartTrader] map childzones: no matches. Either this zone has no child zones in the zone list, or cities aren't exposed as child zones here.")
                CL:Log("  Try: /st map find <cityname> (e.g. /st map find Rimmen)")
                return
            end

            local shown = 0
            local maxShow = 100
            for _, row in ipairs(rows) do
                shown = shown + 1
                if shown > maxShow then
                    CL:Log(string.format("  ... and %d more (use: /st map childzones all; output capped at %d lines)",
                        #rows - maxShow, maxShow))
                    break
                end
                CL:Log(string.format(
                    "  zoneId=%s zoneIndex=%s zoneName=%s parentZoneId=%s -> mapId=%s mapIndex=%s mapType=%s content=%s mapZoneIndex=%s mapName=%s",
                    tostring(row.zoneId), tostring(row.zoneIndex), tostring(row.zoneName), tostring(row.parentZoneId),
                    tostring(row.mapId), tostring(row.mapIndex), tostring(row.mapType), tostring(row.mapContentType),
                    tostring(row.mapZoneIndex), tostring(row.mapName)))
            end

            CL:Log("  Tip: use /st map openid <mapId> to jump to any listed map")
            return
        end

        if sub == "scanids" then
            local SCAN_NAMESPACE = "SmartTrader_MapScanIds"

            -- Cancel
            if subRest == "stop" or subRest == "cancel" then
                if SmartTrader._mapScanIdsState then
                    SmartTrader._mapScanIdsState = nil
                    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAMESPACE)
                    CL:Log("[SmartTrader] map scanids: cancelled")
                else
                    CL:Log("[SmartTrader] map scanids: no scan running")
                end
                return
            end

            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not zoneIndex or zoneIndex == 0 then
                CL:Log("[SmartTrader] map scanids: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetMapInfoById then
                CL:Log("[SmartTrader] map scanids: missing GetMapInfoById.")
                return
            end
            if not GetZoneId then
                CL:Log("[SmartTrader] map scanids: missing GetZoneId.")
                return
            end

            local anchorZoneId, anchorParentZoneId = GetZoneContextForZoneIndex(zoneIndex)
            if not anchorZoneId then
                CL:Log("[SmartTrader] map scanids: could not resolve anchor zoneId.")
                return
            end

            local includeAll = false
            local maxId = nil
            for token in string.gmatch(subRest or "", "%S+") do
                if token == "all" then
                    includeAll = true
                else
                    local n = tonumber(token)
                    if n and n > 0 then
                        maxId = math.floor(n)
                    end
                end
            end

            -- Choose a default maxId based on the map list max mapId (plus a safety margin).
            if not maxId then
                maxId = 3000
                if GetNumMaps and GetMapIdByIndex then
                    local numMaps = GetNumMaps() or 0
                    local maxFromList = 0
                    for i = 1, numMaps do
                        local id = GetMapIdByIndex(i)
                        if type(id) == "number" and id > maxFromList then
                            maxFromList = id
                        end
                    end
                    if maxFromList > 0 then
                        maxId = maxFromList + 200
                    end
                end
            end

            SmartTrader._mapScanIdsState = {
                anchorZoneIndex = zoneIndex,
                anchorZoneId = anchorZoneId,
                anchorParentZoneId = anchorParentZoneId,
                includeAll = includeAll,
                currentId = 1,
                maxId = maxId,
                scanned = 0,
                matched = 0,
                printed = 0,
            }

            CL:Log(string.format(
                "[SmartTrader] map scanids: starting (zoneId=%s parentZoneId=%s maxId=%d mode=%s)",
                tostring(anchorZoneId), tostring(anchorParentZoneId), maxId, includeAll and "all" or "cities"))

            local function StepScan()
                local s = SmartTrader._mapScanIdsState
                if not s then
                    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAMESPACE)
                    return
                end

                local batch = 50
                for _ = 1, batch do
                    if s.currentId > s.maxId then
                        EVENT_MANAGER:UnregisterForUpdate(SCAN_NAMESPACE)
                        CL:Log(string.format(
                            "[SmartTrader] map scanids: done scanned=%d matched=%d printed=%d",
                            s.scanned, s.matched, s.printed))
                        SmartTrader._mapScanIdsState = nil
                        return
                    end

                    local mapId = s.currentId
                    s.currentId = s.currentId + 1
                    s.scanned = s.scanned + 1

                    local mapName, mapType, mapContentType, mapZoneIndex = GetMapInfoById(mapId)
                    if mapName and mapName ~= "" and mapZoneIndex and mapZoneIndex ~= 0 then
                        local mapZoneId = GetZoneId(mapZoneIndex)
                        local mapParentZoneId = nil
                        if mapZoneId and mapZoneId ~= 0 and GetParentZoneId then
                            mapParentZoneId = GetParentZoneId(mapZoneId)
                        end

                        local inZone = false
                        if mapZoneId == s.anchorZoneId then
                            inZone = true
                        elseif mapParentZoneId == s.anchorZoneId then
                            inZone = true
                        elseif s.anchorParentZoneId and mapParentZoneId == s.anchorParentZoneId then
                            inZone = true
                        end

                        if inZone then
                            local include = s.includeAll == true
                            if not include then
                                -- Default: city/town-like maps.
                                if mapContentType == MAP_CONTENT_NONE and (mapType == MAPTYPE_ZONE or mapType == MAPTYPE_SUBZONE) then
                                    include = true
                                end
                            end

                            if include then
                                s.matched = s.matched + 1
                                s.printed = s.printed + 1
                                local mapIndex = GetMapIndexById and GetMapIndexById(mapId) or nil
                                CL:Log(string.format(
                                    "  mapId=%d mapIndex=%s mapType=%s content=%s zoneIndex=%s zoneId=%s parentZoneId=%s name=%s",
                                    mapId, tostring(mapIndex), tostring(mapType), tostring(mapContentType),
                                    tostring(mapZoneIndex), tostring(mapZoneId), tostring(mapParentZoneId),
                                    tostring(mapName)))
                            end
                        end
                    end
                end
            end

            EVENT_MANAGER:UnregisterForUpdate(SCAN_NAMESPACE)
            EVENT_MANAGER:RegisterForUpdate(SCAN_NAMESPACE, 1, StepScan)
            return
        end

        if sub == "cityids" then
            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not zoneIndex or zoneIndex == 0 then
                CL:Log("[SmartTrader] map cityids: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetNumPOIs or not GetPOIInfo then
                CL:Log("[SmartTrader] map cityids: missing POI APIs (GetNumPOIs/GetPOIInfo).")
                return
            end
            if not GetNumMaps or not GetMapInfoByIndex then
                CL:Log("[SmartTrader] map cityids: missing map list APIs (GetNumMaps/GetMapInfoByIndex).")
                return
            end

            local anchorZoneId, anchorParentZoneId = GetZoneContextForZoneIndex(zoneIndex)

            ---@param text string|nil
            ---@return string
            local function NameKey(text)
                local s = tostring(text or "")
                if zo_strformat then
                    s = zo_strformat("<<1>>", s)
                end
                s = string.upper(s)
                -- Remove punctuation/whitespace so "Rimmen" and "Rimmen^N" normalize the same.
                s = s:gsub("[%p%s]+", "")
                return s
            end

            local numMaps = GetNumMaps() or 0
            ---@type table<string, { mapIndex: number, mapId: integer, mapName: string, mapType: UIMapType, mapContentType: MapContentType, zoneIndex: luaindex|number|nil, zoneId: integer|nil, parentZoneId: integer|nil }[]>
            local mapsByNameKey = {}
            for mapIndex = 1, numMaps do
                local mapName, mapType, mapContentType, mapZoneIndex = GetMapInfoByIndex(mapIndex)
                local mapZoneId, mapParentZoneId = GetZoneContextForZoneIndex(mapZoneIndex)

                -- Build a global name->map table, then decide "in-scope" at match-time.
                local eligible = true
                if mapType == MAPTYPE_WORLD or mapType == MAPTYPE_COSMIC or mapType == MAPTYPE_NONE or mapType == MAPTYPE_DEPRECATED_1 then
                    eligible = false
                elseif mapContentType == MAP_CONTENT_AVA or mapContentType == MAP_CONTENT_BATTLEGROUND then
                    eligible = false
                elseif mapContentType == MAP_CONTENT_DUNGEON then
                    eligible = false
                end

                -- City/town maps are typically non-dungeon zone/subzone content.
                if eligible and mapContentType == MAP_CONTENT_NONE and (mapType == MAPTYPE_ZONE or mapType == MAPTYPE_SUBZONE) then
                    local key = NameKey(mapName)
                    if key ~= "" then
                        local list = mapsByNameKey[key]
                        if not list then
                            list = {}
                            mapsByNameKey[key] = list
                        end
                        local mapId = GetMapIdByIndex and GetMapIdByIndex(mapIndex) or 0
                        list[#list + 1] = {
                            mapIndex = mapIndex,
                            mapId = mapId,
                            mapName = tostring(mapName or ""),
                            mapType = mapType,
                            mapContentType = mapContentType,
                            zoneIndex = mapZoneIndex,
                            zoneId = mapZoneId,
                            parentZoneId = mapParentZoneId,
                        }
                    end
                end
            end

            local numPois = GetNumPOIs(zoneIndex) or 0
            local matched = 0
            local matchedInScope = 0
            local matchedOutOfScope = 0
            local shown = 0
            local maxShow = (subRest == "all") and 200 or 50

            CL:Log(string.format(
                "[SmartTrader] map cityids: zoneIndex=%s zoneId=%s parentZoneId=%s numPois=%d (show=%d)",
                tostring(zoneIndex), tostring(anchorZoneId), tostring(anchorParentZoneId), numPois, maxShow))

            for poiIndex = 1, numPois do
                local poiName = select(1, GetPOIInfo(zoneIndex, poiIndex))
                local poiType = GetPOIType and GetPOIType(zoneIndex, poiIndex) or nil
                local key = NameKey(poiName)
                local hits = key ~= "" and mapsByNameKey[key] or nil
                if hits and #hits > 0 then
                    for _, hit in ipairs(hits) do
                        local inScope = false
                        if anchorParentZoneId and hit.parentZoneId and hit.parentZoneId == anchorParentZoneId then
                            inScope = true
                        elseif (not anchorParentZoneId) and anchorZoneId and hit.zoneId and hit.zoneId == anchorZoneId then
                            inScope = true
                        elseif hit.zoneIndex and zoneIndex and hit.zoneIndex == zoneIndex then
                            inScope = true
                        end

                        matched = matched + 1
                        if inScope then
                            matchedInScope = matchedInScope + 1
                        else
                            matchedOutOfScope = matchedOutOfScope + 1
                        end
                        if shown < maxShow then
                            shown = shown + 1
                            CL:Log(string.format(
                                "  poi=%d poiType=%s poiName=%s -> mapId=%s mapIndex=%s mapType=%s content=%s scope=%s mapZoneIndex=%s mapZoneId=%s mapParentZoneId=%s mapName=%s",
                                poiIndex, tostring(poiType), tostring(poiName),
                                tostring(hit.mapId), tostring(hit.mapIndex), tostring(hit.mapType),
                                tostring(hit.mapContentType),
                                inScope and "in" or "out",
                                tostring(hit.zoneIndex), tostring(hit.zoneId), tostring(hit.parentZoneId),
                                tostring(hit.mapName)))
                        end
                    end
                end
            end

            if matched == 0 then
                CL:Log("[SmartTrader] map cityids: no POI names matched any map names in the map list.")
                CL:Log("  Try: /st map find <name>      (e.g. /st map find Rimmen)")
                CL:Log("  Or:  /st map zonemaps all     (to browse maps in this zone context)")
                return
            end

            if matched > shown then
                CL:Log(string.format("  ... and %d more (use: /st map cityids all)", matched - shown))
            end
            CL:Log(string.format(
                "[SmartTrader] map cityids: matched=%d (inScope=%d outOfScope=%d) shown=%d",
                matched, matchedInScope, matchedOutOfScope, shown))

            if matchedInScope == 0 then
                CL:Log("[SmartTrader] map cityids: note: no matches were considered 'in-scope' by parentZoneId/zoneIndex.")
                CL:Log(
                    "  City maps often don't report the expected zone hierarchy; you can still use the mapId(s) above with: /st map openid <mapId>")
            end
            return
        end

        if sub == "find" then
            local query = subRest
            if query == "" then
                CL:Log("[SmartTrader] Usage: /st map find <text>")
                return
            end
            if not GetNumMaps or not GetMapInfoByIndex then
                CL:Log("[SmartTrader] map find: missing map list APIs (GetNumMaps/GetMapInfoByIndex).")
                return
            end

            local queryUpper = string.upper(query)
            local numMaps = GetNumMaps() or 0
            local maxShow = 50
            local shown = 0
            local matched = 0

            CL:Log(string.format("[SmartTrader] map find: query=%s numMaps=%d", tostring(query), numMaps))
            for mapIndex = 1, numMaps do
                local mapName, mapType, mapContentType, zoneIndex = GetMapInfoByIndex(mapIndex)
                local hay = tostring(mapName or "")
                if string.find(string.upper(hay), queryUpper, 1, true) then
                    matched = matched + 1
                    if shown < maxShow then
                        shown = shown + 1
                        local mapId = GetMapIdByIndex and GetMapIdByIndex(mapIndex) or 0
                        local zoneId, parentZoneId = GetZoneContextForZoneIndex(zoneIndex)
                        CL:Log(string.format(
                            "  mapIndex=%d mapId=%s mapType=%s contentType=%s zoneIndex=%s zoneId=%s parentZoneId=%s name=%s",
                            mapIndex, tostring(mapId), tostring(mapType), tostring(mapContentType),
                            tostring(zoneIndex), tostring(zoneId), tostring(parentZoneId), tostring(mapName)))
                    end
                end
            end

            if matched == 0 then
                CL:Log(string.format("[SmartTrader] map find: no matches for %s", tostring(query)))
                return
            end
            if matched > shown then
                CL:Log(string.format("  ... and %d more (showing first %d)", matched - shown, shown))
            end
            return
        end

        if sub == "pois" or sub == "poi" then
            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not zoneIndex or zoneIndex == 0 then
                CL:Log("[SmartTrader] map pois: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetNumPOIs or not GetPOIMapInfo then
                CL:Log("[SmartTrader] map pois: missing POI APIs (GetNumPOIs/GetPOIMapInfo).")
                return
            end

            local numPois = GetNumPOIs(zoneIndex) or 0
            local maxShow = (subRest == "all") and 200 or 50
            local shown = 0

            CL:Log(string.format("[SmartTrader] map pois: zoneIndex=%s numPois=%d", tostring(zoneIndex), numPois))
            for poiIndex = 1, numPois do
                if shown >= maxShow then
                    break
                end

                local x, z, poiPinType, _icon, isShownInCurrentMap, _locked, isDiscovered, isNearby =
                    GetPOIMapInfo(zoneIndex, poiIndex)

                local poiName = nil
                if GetPOIInfo then
                    poiName = select(1, GetPOIInfo(zoneIndex, poiIndex))
                end

                local poiType = nil
                if GetPOIType then
                    poiType = GetPOIType(zoneIndex, poiIndex)
                end

                local instanceType = nil
                if GetPOIInstanceType then
                    instanceType = GetPOIInstanceType(zoneIndex, poiIndex)
                end

                local would, resultingMapIndex = nil, nil
                if WouldProcessMapClick and x and z then
                    would, resultingMapIndex = WouldProcessMapClick(x, z)
                end

                local resultingName, resultingType, resultingContentType, resultingZoneIndex = nil, nil, nil, nil
                local resultingMapId = nil
                if resultingMapIndex and GetMapInfoByIndex then
                    resultingName, resultingType, resultingContentType, resultingZoneIndex = GetMapInfoByIndex(
                        resultingMapIndex)
                    resultingMapId = GetMapIdByIndex and GetMapIdByIndex(resultingMapIndex) or nil
                end

                shown = shown + 1
                CL:Log(string.format(
                    "  poi=%d name=%s type=%s inst=%s shown=%s disc=%s near=%s pin=%s x=%.3f z=%.3f would=%s -> mapIndex=%s mapId=%s mapType=%s content=%s zoneIndex=%s mapName=%s",
                    poiIndex,
                    tostring(poiName),
                    tostring(poiType),
                    tostring(instanceType),
                    tostring(isShownInCurrentMap),
                    tostring(isDiscovered),
                    tostring(isNearby),
                    tostring(poiPinType),
                    tonumber(x) or 0, tonumber(z) or 0,
                    tostring(would),
                    tostring(resultingMapIndex),
                    tostring(resultingMapId),
                    tostring(resultingType),
                    tostring(resultingContentType),
                    tostring(resultingZoneIndex),
                    tostring(resultingName)))
            end

            if numPois > shown then
                CL:Log(string.format("  ... and %d more (use: /st map pois all)", numPois - shown))
            end
            return
        end

        if sub == "openidx" then
            local mapIndex = tonumber(subRest or "")
            if not mapIndex or mapIndex <= 0 then
                CL:Log("[SmartTrader] Usage: /st map openidx <mapIndex>")
                return
            end

            local result = SetMapByIndexSafely(mapIndex)
            local afterIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
            local afterId = GetCurrentMapId and GetCurrentMapId() or nil
            local afterName = GetMapName and GetMapName() or nil
            CL:Log(string.format(
                "[SmartTrader] map openidx: requested=%d result=%s now mapIndex=%s mapId=%s name=%s",
                mapIndex, tostring(result), tostring(afterIndex), tostring(afterId), tostring(afterName)))
            return
        end

        if sub == "openid" then
            local mapId = tonumber(subRest or "")
            if not mapId or mapId <= 0 then
                CL:Log("[SmartTrader] Usage: /st map openid <mapId>")
                return
            end

            local mapIndex = GetMapIndexById and GetMapIndexById(mapId) or nil
            local mapName = GetMapNameById and GetMapNameById(mapId) or nil

            local result = SetMapByIdSafely(mapId)
            local afterIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
            local afterId = GetCurrentMapId and GetCurrentMapId() or nil
            local afterName = GetMapName and GetMapName() or nil
            CL:Log(string.format(
                "[SmartTrader] map openid: requested mapId=%d (mapIndex=%s name=%s) result=%s now mapIndex=%s mapId=%s name=%s",
                mapId, tostring(mapIndex), tostring(mapName), tostring(result),
                tostring(afterIndex), tostring(afterId), tostring(afterName)))
            return
        end

        if sub == "openpoi" then
            local poiIndex = tonumber(subRest or "")
            if not poiIndex or poiIndex <= 0 then
                CL:Log("[SmartTrader] Usage: /st map openpoi <poiIndex>")
                return
            end

            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not zoneIndex or zoneIndex == 0 then
                CL:Log("[SmartTrader] map openpoi: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetPOIMapInfo then
                CL:Log("[SmartTrader] map openpoi: missing GetPOIMapInfo.")
                return
            end

            local x, z = GetPOIMapInfo(zoneIndex, poiIndex)
            if not x or not z then
                CL:Log(string.format("[SmartTrader] map openpoi: could not read POI %d coords", poiIndex))
                return
            end

            local resultingMapIndex = FindResultingMapIndex(x, z)
            if not resultingMapIndex then
                local would = WouldProcessMapClick and select(1, WouldProcessMapClick(x, z)) or false
                CL:Log(string.format(
                    "[SmartTrader] map openpoi: no resulting mapIndex for poi=%d (x=%.3f z=%.3f would=%s)",
                    poiIndex, tonumber(x) or 0, tonumber(z) or 0, tostring(would)))
                return
            end

            local result = SetMapByIndexSafely(resultingMapIndex)
            local afterIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
            local afterId = GetCurrentMapId and GetCurrentMapId() or nil
            local afterName = GetMapName and GetMapName() or nil
            CL:Log(string.format(
                "[SmartTrader] map openpoi: poi=%d -> mapIndex=%s result=%s now mapIndex=%s mapId=%s name=%s",
                poiIndex, tostring(resultingMapIndex), tostring(result),
                tostring(afterIndex), tostring(afterId), tostring(afterName)))
            return
        end

        if sub == "clickpoi" then
            local poiIndex = tonumber(subRest or "")
            if not poiIndex or poiIndex <= 0 then
                CL:Log("[SmartTrader] Usage: /st map clickpoi <poiIndex>")
                return
            end

            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not zoneIndex or zoneIndex == 0 then
                CL:Log("[SmartTrader] map clickpoi: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetPOIMapInfo then
                CL:Log("[SmartTrader] map clickpoi: missing GetPOIMapInfo.")
                return
            end
            if not ProcessMapClick then
                CL:Log("[SmartTrader] map clickpoi: missing ProcessMapClick.")
                return
            end

            local beforeIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
            local beforeId = GetCurrentMapId and GetCurrentMapId() or nil
            local beforeName = GetMapName and GetMapName() or nil

            local x, z = GetPOIMapInfo(zoneIndex, poiIndex)
            if not x or not z then
                CL:Log(string.format("[SmartTrader] map clickpoi: could not read POI %d coords", poiIndex))
                return
            end

            local changed = TryProcessMapClickJitter(x, z)
            local afterIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
            local afterId = GetCurrentMapId and GetCurrentMapId() or nil
            local afterName = GetMapName and GetMapName() or nil

            CL:Log(string.format(
                "[SmartTrader] map clickpoi: poi=%d (x=%.3f z=%.3f) changed=%s before=%s/%s/%s after=%s/%s/%s",
                poiIndex, tonumber(x) or 0, tonumber(z) or 0, tostring(changed),
                tostring(beforeIndex), tostring(beforeId), tostring(beforeName),
                tostring(afterIndex), tostring(afterId), tostring(afterName)))
            return
        end

        if sub == "trycity" then
            local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
            if not zoneIndex or zoneIndex == 0 then
                CL:Log("[SmartTrader] map trycity: no current map zoneIndex (open a zone/subzone map).")
                return
            end
            if not GetNumPOIs or not GetPOIMapInfo or not WouldProcessMapClick or not GetMapInfoByIndex then
                CL:Log(
                    "[SmartTrader] map trycity: missing required APIs (GetNumPOIs/GetPOIMapInfo/WouldProcessMapClick/GetMapInfoByIndex).")
                return
            end

            local currentMapIndex = GetCurrentMapIndex and GetCurrentMapIndex() or 0
            local numPois = GetNumPOIs(zoneIndex) or 0
            local chosenPoi, chosenMapIndex, chosenName = nil, nil, nil
            local clickMode = (subRest == "click")
            for poiIndex = 1, numPois do
                local x, z = GetPOIMapInfo(zoneIndex, poiIndex)
                if x and z and (x ~= 0 or z ~= 0) then
                    if clickMode then
                        local beforeId = GetCurrentMapId and GetCurrentMapId() or 0
                        if TryProcessMapClickJitter(x, z) then
                            local afterId = GetCurrentMapId and GetCurrentMapId() or 0
                            if afterId ~= 0 and afterId ~= beforeId then
                                chosenPoi = poiIndex
                                chosenMapIndex = GetCurrentMapIndex and GetCurrentMapIndex() or nil
                                chosenName = GetMapName and GetMapName() or nil
                                break
                            end
                        end
                    else
                        local idx = FindResultingMapIndex(x, z)
                        if idx and idx ~= currentMapIndex then
                            local name, mapType, mapContentType = GetMapInfoByIndex(idx)
                            if mapContentType == MAP_CONTENT_NONE and (mapType == MAPTYPE_SUBZONE or mapType == MAPTYPE_ZONE) then
                                chosenPoi = poiIndex
                                chosenMapIndex = idx
                                chosenName = name
                                break
                            end
                        end
                    end
                end
            end

            if not chosenMapIndex then
                if clickMode then
                    CL:Log("[SmartTrader] map trycity(click): no POI click caused a map change on this map.")
                else
                    CL:Log("[SmartTrader] map trycity: no eligible child map found via POIs on this map.")
                end
                CL:Log("  Try: /st map pois all  (to see what POIs resolve to)")
                CL:Log("  Or:  /st map zonemaps  (to see mapIndexes in this zone/parent zone)")
                return
            end

            if clickMode then
                CL:Log(string.format(
                    "[SmartTrader] map trycity(click): chose poi=%d -> now mapIndex=%s name=%s",
                    chosenPoi, tostring(chosenMapIndex), tostring(chosenName)))
            else
                local result = SetMapByIndexSafely(chosenMapIndex)
                CL:Log(string.format(
                    "[SmartTrader] map trycity: chose poi=%d -> mapIndex=%s name=%s result=%s",
                    chosenPoi, tostring(chosenMapIndex), tostring(chosenName), tostring(result)))
            end
            return
        end

        CL:Log("[SmartTrader] Unknown /st map command. Use: /st map")
        return
    end

    if firstLower == "log" then
        local Export = LibConsoleLogger and LibConsoleLogger.WebExport or nil
        local MapActions = SmartTrader.MapActions
        local cfg = SmartTrader.state and SmartTrader.state.savedVars and SmartTrader.state.savedVars.logExport or nil
        if not Export then
            CL:Log("[SmartTrader] LibConsoleLogger.WebExport not available.")
            return
        end

        local sub, subRest = restTrimmed:match("^(%S+)%s*(.*)$")
        sub = sub and string.lower(sub) or ""
        subRest = Trim(subRest)

        if sub == "" then
            CL:Log("[SmartTrader] Hover logging commands:")
            CL:Log("  /st log on     - Start logging hovered map pins")
            CL:Log("  /st log off    - Stop logging and export all captured data")
            CL:Log("  /st log status - Show current hover log status")
            CL:Log("  /st log cancel - Stop logging without exporting")
            CL:Log("  /st log url    - Show export endpoint")
            CL:Log("  /st log url <url> - Set export endpoint")
            CL:Log("  /st log url clear  - Clear export endpoint")
            CL:Log("  /st log set-url <url> - Alias for setting endpoint")
            return
        end

        if sub == "url" then
            if subRest and subRest ~= "" then
                if subRest == "clear" or subRest == "unset" then
                    subRest = ""
                end
                if not Export.SetUrl then
                    CL:Log("[SmartTrader] Log export does not support setting a URL.")
                    return
                end
                local ok, reason = Export.SetUrl(subRest, cfg)
                if ok then
                    CL:Log(string.format("[SmartTrader] log url set: %s",
                        tostring(Export.GetUrl and Export.GetUrl(cfg) or "")))
                else
                    CL:Log(string.format("[SmartTrader] log url not set (reason=%s).", tostring(reason)))
                end
            else
                local current = tostring(Export.GetUrl and Export.GetUrl(cfg) or "")
                if current == "" then
                    current = "not set"
                end
                CL:Log(string.format("[SmartTrader] log url: %s", current))
            end
            return
        end

        if sub == "set-url" or sub == "seturl" then
            if not Export.SetUrl then
                CL:Log("[SmartTrader] Log export does not support setting a URL.")
                return
            end
            if not subRest or subRest == "" then
                CL:Log("[SmartTrader] Usage: /st log set-url <url>")
                return
            end
            if subRest == "clear" or subRest == "unset" then
                subRest = ""
            end
            local ok, reason = Export.SetUrl(subRest, cfg)
            if ok then
                CL:Log(string.format("[SmartTrader] log url set: %s",
                    tostring(Export.GetUrl and Export.GetUrl(cfg) or "")))
            else
                CL:Log(string.format("[SmartTrader] log url not set (reason=%s).", tostring(reason)))
            end
            return
        end

        if sub == "on" then
            if MapActions and MapActions.SetHoverLogEnabled then
                MapActions.SetHoverLogEnabled(true)
                CL:Log("[SmartTrader] Hover logging ON - hover over map pins to capture data")
            else
                CL:Log("[SmartTrader] MapActions not available.")
            end
            return
        end

        if sub == "off" then
            if not MapActions then
                CL:Log("[SmartTrader] MapActions not available.")
                return
            end

            local wasEnabled = MapActions.IsHoverLogEnabled and MapActions.IsHoverLogEnabled() or false
            local lines = MapActions.GetHoverLogLines and MapActions.GetHoverLogLines() or {}
            local count = #lines

            -- Disable logging
            if MapActions.SetHoverLogEnabled then
                MapActions.SetHoverLogEnabled(false)
            end

            if not wasEnabled then
                CL:Log("[SmartTrader] Hover logging was not enabled.")
                return
            end

            if count == 0 then
                CL:Log("[SmartTrader] Hover logging OFF - no pins were captured.")
                return
            end

            CL:Log(string.format("[SmartTrader] Hover logging OFF - exporting %d pins...", count))

            -- Export the captured lines
            local payload = table.concat(lines, "\n")
            local ok, reason = Export.ExportRaw("HoverLog", "hover_export", payload, cfg)
            if ok then
                CL:Log("[SmartTrader] Export opened (confirm prompt may appear).")
            else
                CL:Log(string.format("[SmartTrader] Could not export (reason=%s).", tostring(reason)))
            end
            return
        end

        if sub == "cancel" then
            if MapActions and MapActions.SetHoverLogEnabled then
                local wasEnabled = MapActions.IsHoverLogEnabled and MapActions.IsHoverLogEnabled() or false
                MapActions.SetHoverLogEnabled(false)
                if wasEnabled then
                    CL:Log("[SmartTrader] Hover logging cancelled (data discarded).")
                else
                    CL:Log("[SmartTrader] Hover logging was not enabled.")
                end
            else
                CL:Log("[SmartTrader] MapActions not available.")
            end
            return
        end

        if sub == "status" then
            if MapActions and MapActions.IsHoverLogEnabled then
                local enabled = MapActions.IsHoverLogEnabled()
                local count = MapActions.GetHoverLogCount and MapActions.GetHoverLogCount() or 0
                CL:Log(string.format("[SmartTrader] Hover log: %s, %d pins captured",
                    enabled and "ON" or "OFF", count))
            else
                CL:Log("[SmartTrader] MapActions not available.")
            end
            return
        end

        CL:Log("[SmartTrader] Unknown /st log command. Use: /st log")
        return
    end

    if firstLower == "find" then
        local query = restTrimmed
        if query == "" then
            CL:Log("[SmartTrader] Usage: /st find <text>")
            return
        end

        local guildDataById = SmartTrader.state.savedVars.guildDataById or {}
        local MapActions = SmartTrader.MapActions

        local queryUpper = string.upper(query)
        local totalMatches = 0
        local shown = 0
        local maxShow = 25

        CL:Log(string.format("[SmartTrader] Searching cached guilds for: %s", query))
        for guildId, data in pairs(guildDataById) do
            local hay =
                tostring(data and data.guildName or "") .. " " ..
                tostring(data and data.traderName or "") .. " " ..
                tostring(data and data.city or "") .. " " ..
                tostring(data and data.kioskName or "")

            if string.find(string.upper(hay), queryUpper, 1, true) then
                totalMatches = totalMatches + 1
                if shown < maxShow then
                    shown = shown + 1
                    local resolved = (MapActions and MapActions.DebugResolveCachedLocation) and
                        MapActions.DebugResolveCachedLocation(data) or nil
                    local parentName =
                        (resolved and resolved.parentZoneId and GetZoneNameById) and
                        GetZoneNameById(resolved.parentZoneId) or nil

                    CL:Log(string.format(
                        "  ID:%d | %s | %s | %s | key=%s parent=%s",
                        guildId,
                        tostring(data and data.guildName or "nil"),
                        tostring(data and data.traderName or "nil"),
                        tostring(data and data.city or "nil"),
                        tostring(resolved and resolved.locationKey or "nil"),
                        tostring(parentName or "nil")
                    ))
                end
            end
        end

        if totalMatches == 0 then
            CL:Log(string.format("[SmartTrader] No cached entries matched: %s", query))
            return
        end

        if totalMatches > shown then
            CL:Log(string.format("  ... and %d more", totalMatches - shown))
        end
        CL:Log("  Tip: /st guild <id> to dump one entry")
        return
    elseif firstLower == "guild" or firstLower == "gid" then
        local id = tonumber(restTrimmed)
        if not id or id <= 0 then
            CL:Log("[SmartTrader] Usage: /st guild <guildId>")
            return
        end

        local guildDataById = SmartTrader.state.savedVars.guildDataById or {}
        local data = guildDataById[id]
        if not data then
            CL:Log(string.format("[SmartTrader] Guild ID %d is not in cache", id))
            return
        end

        CL:Log(string.format("[SmartTrader] Guild ID: %d", id))
        CL:Log(string.format("  Name: %s", data.guildName or "nil"))
        CL:Log(string.format("  Members: %s", data.memberCount or "nil"))
        CL:Log(string.format("  Size: %s", data.size or "nil"))
        CL:Log(string.format("  Kiosk: %s", data.kioskName or "nil"))
        CL:Log(string.format("  Trader: %s", data.traderName or "nil"))
        CL:Log(string.format("  City: %s", data.city or "nil"))

        if GuildUtils and GuildUtils.ParseKioskAttribute and data.kioskName then
            local parsedTrader, parsedCity = GuildUtils.ParseKioskAttribute(data.kioskName)
            if parsedTrader or parsedCity then
                CL:Log(string.format("  Parsed kioskAttribute: trader=%s city=%s", tostring(parsedTrader),
                    tostring(parsedCity)))
            end
        end

        local MapActions = SmartTrader.MapActions
        if MapActions and MapActions.DebugResolveCachedLocation then
            local resolved = MapActions.DebugResolveCachedLocation(data)
            CL:Log("  Location resolve:")
            for k, v in pairs(resolved or {}) do
                CL:Log(string.format("    %s=%s", tostring(k), tostring(v)))
            end

            if resolved and resolved.parentZoneId and GetZoneNameById then
                CL:Log(string.format("    parentZoneName=%s", tostring(GetZoneNameById(resolved.parentZoneId))))
            end
            if resolved and resolved.zoneId and GetZoneNameById then
                CL:Log(string.format("    zoneName=%s", tostring(GetZoneNameById(resolved.zoneId))))
            end
        end
        return
    end

    if args == "cache" or args == "c" then
        local guildDataById = SmartTrader.state.savedVars.guildDataById
        local count = GuildUtils.GetCachedCount(guildDataById)

        if count == 0 then
            CL:Log("[SmartTrader] Cache is empty")
        else
            local sizeCounts = GuildUtils.GetCachedCountBySize(guildDataById)
            CL:Log(string.format("[SmartTrader] %d guilds cached:", count))
            CL:Log(string.format("  Small/Medium (red): %d", sizeCounts[1] + sizeCounts[2]))
            CL:Log(string.format("  Large (yellow): %d", sizeCounts[3]))
            CL:Log(string.format("  Gigantic (green): %d", sizeCounts[4]))
        end
    elseif args == "scan" or args == "s" then
        if ScanActions then
            CL:Log("[SmartTrader] Starting manual guild scan...")
            ScanActions.StartFullScan()
        else
            CL:Log("[SmartTrader] Addon not fully initialized yet.")
        end
    elseif args == "stop" then
        if ScanActions then
            ScanActions.CancelScan()
        else
            CL:Log("[SmartTrader] Addon not fully initialized yet.")
        end
    elseif args == "debug" or args == "d" then
        local guildDataById = SmartTrader.state.savedVars.guildDataById
        local cacheCount = GuildUtils.GetCachedCount(guildDataById)
        local currentTime = GetTimeStamp()
        local megaserver = GetWorldName()
        local nextFlip = GuildUtils.GetNextTraderFlipTime(megaserver, currentTime)
        local hoursUntilFlip = (nextFlip - currentTime) / 3600

        CL:Log(string.format("[SmartTrader] %d guilds cached, %.1fh until flip", cacheCount, hoursUntilFlip))

        -- Check if looking at a trader
        local guildId = nil
        for _, unitTag in ipairs({ "interact", "reticleOver", "reticleover" }) do
            if DoesUnitExist(unitTag) and IsUnitGuildKiosk(unitTag) then
                guildId = GetUnitGuildKioskOwner(unitTag)
                if guildId and guildId ~= 0 then
                    break
                end
            end
        end

        if guildId and guildId ~= 0 then
            CL:Log(string.format("  Guild ID: %d", guildId))
            local cachedData = GuildUtils.GetCachedData(guildDataById, guildId)
            if cachedData then
                CL:Log(string.format("  Name: %s", cachedData.guildName or "nil"))
                CL:Log(string.format("  Members: %s", cachedData.memberCount or "nil"))
                CL:Log(string.format("  Size: %s", cachedData.size or "nil"))
                CL:Log(string.format("  Kiosk: %s", cachedData.kioskName or "nil"))
                CL:Log(string.format("  Trader: %s", cachedData.traderName or "nil"))
                CL:Log(string.format("  City: %s", cachedData.city or "nil"))
            else
                CL:Log("  Not in cache")
            end
        else
            CL:Log("  Not looking at a trader")
        end
    elseif args == "clear" then
        local GuildActions = SmartTrader.GuildActions
        GuildActions.ClearAllCache()
    elseif args == "flip" or args == "f" then
        local currentTime = GetTimeStamp()
        local megaserver = GetWorldName()
        local nextFlip = GuildUtils.GetNextTraderFlipTime(megaserver, currentTime)
        local hoursUntilFlip = (nextFlip - currentTime) / 3600
        local daysUntilFlip = hoursUntilFlip / 24

        if daysUntilFlip >= 1 then
            CL:Log(string.format("[SmartTrader] Next trader flip: %.1f days (%.1f hours)", daysUntilFlip, hoursUntilFlip))
        else
            CL:Log(string.format("[SmartTrader] Next trader flip: %.1f hours", hoursUntilFlip))
        end
    elseif args == "stats" then
        -- Show statistics from various modules
        CL:Log("[SmartTrader] Operation Statistics:")

        -- Get reticle stats
        local stats = SmartTrader.ReticleActions.GetStats()
        CL:Log(string.format("  SetText calls: %d", stats.setTextCalls))
        CL:Log(string.format("  Cache hits: %d", stats.cacheHits))
        CL:Log(string.format("  Cache misses: %d", stats.cacheMisses))
        CL:Log(string.format("  Cache fetches: %d", stats.cacheFetches))

        -- Get cache stats
        local guildDataById = SmartTrader.state.savedVars.guildDataById
        local totalCount = GuildUtils.GetCachedCount(guildDataById)
        CL:Log(string.format("  Guilds cached: %d", totalCount))

        -- Get trader name lookup stats
        local traderLookupCount = 0
        for _ in pairs(SmartTrader.state.savedVars.guildDataByTraderName or {}) do
            traderLookupCount = traderLookupCount + 1
        end
        CL:Log(string.format("  Trader names indexed: %d", traderLookupCount))
    elseif args == "traders" then
        -- Show what's in the trader name lookup
        local guildDataByTraderName = SmartTrader.state.savedVars.guildDataByTraderName
        if not guildDataByTraderName then
            CL:Log("[SmartTrader] guildDataByTraderName is nil!")
            return
        end

        local count = 0
        for traderName, data in pairs(guildDataByTraderName) do
            count = count + 1
            if count <= 10 then
                CL:Log(string.format("  %s -> %s (ID:%d)", traderName, data.guildName or "?", data.guildId))
            end
        end

        if count > 10 then
            CL:Log(string.format("  ... and %d more", count - 10))
        elseif count == 0 then
            CL:Log("[SmartTrader] No trader names in lookup!")
        end
    else
        CL:Log("[SmartTrader] Commands:")
        CL:Log("  /st c        - Show cached guild data")
        CL:Log("  /st s        - Manually scan for guilds with traders")
        CL:Log("  /st stop     - Cancel running scan")
        CL:Log("  /st clear    - Clear all cached data")
        CL:Log("  /st f        - Show time until next trader flip")
        CL:Log("  /st d        - Show debug information")
        CL:Log("  /st stats    - Show operation statistics")
        CL:Log("  /st traders  - Show trader name lookup table")
        CL:Log("  /st log      - Hover logging (on/off/status/cancel)")
        CL:Log("  /st export   - Export snapshot for offline analysis")
        CL:Log("  /st find <text> - Search cached guild entries (name/trader/city/kiosk)")
        CL:Log("  /st guild <id>  - Dump one cached guild entry by guildId")
        CL:Log("  /st map      - Map debug tools (current zone POIs + map indexes)")
    end
end

-- Register slash commands
SLASH_COMMANDS["/smarttrader"] = HandleCommand
SLASH_COMMANDS["/st"] = HandleCommand

-- Initialize on addon loaded
EVENT_MANAGER:RegisterForEvent(SmartTrader.name, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == SmartTrader.name then
        Initialize()
        EVENT_MANAGER:UnregisterForEvent(SmartTrader.name, EVENT_ADD_ON_LOADED)
    end
end)
