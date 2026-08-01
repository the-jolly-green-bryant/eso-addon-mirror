-- ExportActions.lua: Raw data export for offline analysis
-- Exports guild cache, fast travel nodes, and current map locations (traders + wayshrines + outlaw refuges)
-- Analysis/correlation done offline in Python, not in-game

local SmartTrader = SmartTrader or {}
SmartTrader.ExportActions = {}

local CL = SmartTrader.GetLogger()

local EXPORT_VERSION = "ST2"

local LOOKUPS_ZONE_CRAWL_NAMESPACE = "SmartTrader_LookupsZones"
local LOOKUPS_ZONE_CRAWL_INTERVAL_MS = 25
local LOOKUPS_ZONE_CRAWL_MAP_SWITCH_TIMEOUT_MS = 5000
local LOOKUPS_ZONE_CRAWL_MAP_SWITCH_SETTLE_MS = 100
local LOOKUPS_ZONE_CRAWL_MAPID_CACHE_MARGIN = 500
local LOOKUPS_ZONE_CRAWL_MAPID_CACHE_BATCH = 50

---@type table|nil
local lookupsZoneCrawlState = nil

---@return number|nil zoneIndex
---@return number|nil zoneId
---@return number|nil parentZoneId
local function GetCurrentMapZoneIdsForScope()
    local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
    if type(zoneIndex) ~= "number" or zoneIndex == 0 then
        return nil, nil, nil
    end

    local zoneId = (GetZoneId and GetZoneId(zoneIndex)) or nil
    if type(zoneId) ~= "number" or zoneId == 0 then
        return zoneIndex, nil, nil
    end

    -- Prefer ESOUI's exploration parent resolution when available.
    local parentZoneId = nil
    if ZO_ExplorationUtils_GetParentZoneIdByZoneIndex then
        local derived = ZO_ExplorationUtils_GetParentZoneIdByZoneIndex(zoneIndex)
        if type(derived) == "number" and derived ~= 0 then
            parentZoneId = derived
        end
    end
    if (not parentZoneId) and GetParentZoneId then
        local derived = GetParentZoneId(zoneId)
        if type(derived) == "number" and derived ~= 0 then
            parentZoneId = derived
        end
    end
    if not parentZoneId then
        parentZoneId = zoneId
    end

    return zoneIndex, zoneId, parentZoneId
end

---@param mapId number
---@return SetMapResultCode|nil setMapResult
local function SetMapToMapIdForCrawl(mapId)
    -- If the world map is open, setting via WORLD_MAP_MANAGER prevents ESOUI from snapping back to player location.
    if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById then
        WORLD_MAP_MANAGER:SetMapById(mapId)
        return nil
    end
    if SetMapToMapId then
        return SetMapToMapId(mapId)
    end
    return nil
end

---@param mapIndex number
---@return SetMapResultCode|nil setMapResult
local function SetMapToMapListIndexForCrawl(mapIndex)
    -- If the world map is open, setting via WORLD_MAP_MANAGER prevents ESOUI from snapping back to player location.
    if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapByIndex then
        WORLD_MAP_MANAGER:SetMapByIndex(mapIndex)
        return nil
    end
    if SetMapToMapListIndex then
        return SetMapToMapListIndex(mapIndex)
    end
    return nil
end

-- Trader location icons (from AwesomeGuildStore)
local KIOSK_ICON = "/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds"
local FENCE_ICON = "/esoui/art/icons/servicemappins/servicepin_fence.dds"
local THIEVES_GUILD_ICON = "/esoui/art/icons/servicemappins/servicepin_thievesguild.dds"
local VENDOR_ICON = "/esoui/art/icons/servicemappins/servicepin_vendor.dds"
local KIOSK_TOOLTIP_ICON = "/esoui/art/icons/servicetooltipicons/servicetooltipicon_guildkiosk.dds"

---@param icon string|nil
---@param needle string
---@return boolean
local function IconContains(icon, needle)
    if not icon or icon == "" then
        return false
    end
    return string.find(string.lower(icon), needle, 1, true) ~= nil
end

---@return string
local function GenerateSessionId()
    local ts = GetTimeStamp and GetTimeStamp() or os.time()
    local ms = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
    return string.format("%d_%d", ts, ms % 10000)
end

---@param value any
---@return string
local function SafeStr(value)
    if value == nil then
        return ""
    end
    local s = tostring(value)
    s = s:gsub("[\r\n\t|]", " ")
    s = s:gsub("%s+", " ")
    s = s:gsub("^%s+", "")
    s = s:gsub("%s+$", "")
    return s
end

---@class ExportBuffer
---@field sessionId string
---@field lines string[]

---@return ExportBuffer
local function CreateBuffer()
    return {
        sessionId = GenerateSessionId(),
        lines = {},
    }
end

---@param buf ExportBuffer
---@param recordType string
---@param fields string[]
local function AddLine(buf, recordType, fields)
    local line = string.format("%s|%s|%s|%s",
        EXPORT_VERSION, buf.sessionId, recordType, table.concat(fields, "|"))
    buf.lines[#buf.lines + 1] = line
end

---@class ExportSchemaDef
---@field recordType string
---@field columns string[]

---@param buf ExportBuffer
---@param defs ExportSchemaDef[]
local function AddSchemas(buf, defs)
    -- Describe the fixed prefix of every exported line:
    --   exportVersion|sessionId|recordType|...
    AddLine(buf, "SCHEMA", { "LINE", "exportVersion", "sessionId", "recordType", "fields..." })
    -- Describe the SCHEMA record itself (variable column count).
    AddLine(buf, "SCHEMA", { "SCHEMA", "recordType", "col1", "col2", "..." })

    for i = 1, #defs do
        local def = defs[i]
        local fields = { def.recordType }
        local cols = def.columns or {}
        for j = 1, #cols do
            fields[#fields + 1] = cols[j]
        end
        AddLine(buf, "SCHEMA", fields)
    end
end

---@param buf ExportBuffer
local function AddGuildExportSchema(buf)
    AddSchemas(buf, {
        { recordType = "META",  columns = { "addonVersion", "apiVersion", "worldName", "timestamp", "nextFlipTime" } },
        { recordType = "GUILD", columns = { "guildId", "guildName", "memberCount", "size", "kioskName", "traderName", "city" } },
        { recordType = "GLOC",  columns = { "guildId", "locationKey", "zoneIndex", "zoneId", "parentZoneId", "isOutlaw", "baseCityKey" } },
    })
end

---@param buf ExportBuffer
local function AddNodeExportSchema(buf)
    AddSchemas(buf, {
        { recordType = "META", columns = { "addonVersion", "apiVersion", "worldName", "timestamp", "nextFlipTime" } },
        {
            recordType = "NODE",
            columns = {
                "nodeIndex", "known", "name", "x", "y", "poiType",
                "zoneIndex", "zoneId", "zoneName", "parentZoneId", "parentZoneName",
                "poiIndex", "poiName",
            },
        },
    })
end

---@param buf ExportBuffer
local function AddMapExportSchema(buf)
    AddSchemas(buf, {
        { recordType = "META",    columns = { "addonVersion", "apiVersion", "worldName", "timestamp", "nextFlipTime" } },
        { recordType = "MAP",     columns = { "mapId", "mapName", "mapType", "mapContentType", "zoneIndex", "zoneId", "parentZoneId" } },
        { recordType = "LOC",     columns = { "mapId", "locIndex", "locType", "x", "y", "header" } },
        { recordType = "LOCLINE", columns = { "mapId", "locIndex", "lineIndex", "groupingId", "categoryName", "name", "icon", "visible" } },
        { recordType = "KIOSK",   columns = { "mapId", "locIndex", "kioskName" } },
        { recordType = "WAY",     columns = { "mapId", "nodeIndex", "known", "x", "y", "name" } },
        { recordType = "WAYMETA", columns = { "mapId", "nodeIndex", "nodeZoneIndex", "nodePoiIndex", "poiType", "isOnCurrentMap" } },
    })
end

---@param buf ExportBuffer
local function AddLookupExportSchema(buf)
    AddSchemas(buf, {
        { recordType = "META",    columns = { "addonVersion", "apiVersion", "worldName", "timestamp", "nextFlipTime" } },
        { recordType = "MAP",     columns = { "mapId", "mapName", "mapType", "mapContentType", "zoneIndex", "zoneId", "parentZoneId" } },
        { recordType = "LOC",     columns = { "mapId", "locIndex", "locType", "x", "y", "header" } },
        { recordType = "LOCLINE", columns = { "mapId", "locIndex", "lineIndex", "groupingId", "categoryName", "name", "icon", "visible" } },
        { recordType = "KIOSK",   columns = { "mapId", "locIndex", "kioskName" } },
        { recordType = "WAY",     columns = { "mapId", "nodeIndex", "known", "x", "y", "name" } },
        { recordType = "WAYMETA", columns = { "mapId", "nodeIndex", "nodeZoneIndex", "nodePoiIndex", "poiType", "isOnCurrentMap" } },
    })
end

---@param buf ExportBuffer
local function AddFullExportSchema(buf)
    AddSchemas(buf, {
        { recordType = "META",  columns = { "addonVersion", "apiVersion", "worldName", "timestamp", "nextFlipTime" } },
        { recordType = "GUILD", columns = { "guildId", "guildName", "memberCount", "size", "kioskName", "traderName", "city" } },
        { recordType = "GLOC",  columns = { "guildId", "locationKey", "zoneIndex", "zoneId", "parentZoneId", "isOutlaw", "baseCityKey" } },
        {
            recordType = "NODE",
            columns = {
                "nodeIndex", "known", "name", "x", "y", "poiType",
                "zoneIndex", "zoneId", "zoneName", "parentZoneId", "parentZoneName",
                "poiIndex", "poiName",
            },
        },
        { recordType = "MAP",     columns = { "mapId", "mapName", "mapType", "mapContentType", "zoneIndex", "zoneId", "parentZoneId" } },
        { recordType = "LOC",     columns = { "mapId", "locIndex", "locType", "x", "y", "header" } },
        { recordType = "LOCLINE", columns = { "mapId", "locIndex", "lineIndex", "groupingId", "categoryName", "name", "icon", "visible" } },
        { recordType = "KIOSK",   columns = { "mapId", "locIndex", "kioskName" } },
        { recordType = "WAY",     columns = { "mapId", "nodeIndex", "known", "x", "y", "name" } },
        { recordType = "WAYMETA", columns = { "mapId", "nodeIndex", "nodeZoneIndex", "nodePoiIndex", "poiType", "isOnCurrentMap" } },
    })
end

---@param buf ExportBuffer
local function AddMeta(buf)
    local savedVars = SmartTrader.state and SmartTrader.state.savedVars
    AddLine(buf, "META", {
        SafeStr(SmartTrader.version or ""),
        SafeStr(GetAPIVersion and GetAPIVersion() or 0),
        SafeStr(GetWorldName and GetWorldName() or ""),
        SafeStr(GetTimeStamp and GetTimeStamp() or 0),
        SafeStr(savedVars and savedVars.nextFlipTime or 0),
    })
end

---@param buf ExportBuffer
local function AddGuilds(buf)
    local savedVars = SmartTrader.state and SmartTrader.state.savedVars
    local guildDataById = savedVars and savedVars.guildDataById or {}
    local MapActions = SmartTrader.MapActions
    local Resolve = MapActions and MapActions.DebugResolveCachedLocation

    -- Build city format index once (not per-guild) to avoid O(N^2) performance
    local cityFormatIndex = nil
    if Resolve and MapActions.BuildCityLocationFormatIndex then
        cityFormatIndex = MapActions.BuildCityLocationFormatIndex(guildDataById)
    end

    for guildId, g in pairs(guildDataById) do
        -- GUILD|guildId|guildName|memberCount|size|kioskName|traderName|city
        AddLine(buf, "GUILD", {
            SafeStr(guildId),
            SafeStr(g.guildName),
            SafeStr(g.memberCount),
            SafeStr(g.size),
            SafeStr(g.kioskName),
            SafeStr(g.traderName),
            SafeStr(g.city),
        })

        if Resolve then
            -- Pass pre-built index to avoid rebuilding it for each guild
            local resolved = Resolve(g, cityFormatIndex)
            -- GLOC|guildId|locationKey|zoneIndex|zoneId|parentZoneId|isOutlaw|baseCityKey
            AddLine(buf, "GLOC", {
                SafeStr(guildId),
                SafeStr(resolved and resolved.locationKey or nil),
                SafeStr(resolved and resolved.zoneIndex or nil),
                SafeStr(resolved and resolved.zoneId or nil),
                SafeStr(resolved and resolved.parentZoneId or nil),
                SafeStr((resolved and resolved.isOutlaw) and 1 or 0),
                SafeStr(resolved and resolved.baseCityKey or nil),
            })
        end
    end
end

---@param buf ExportBuffer
local function AddNodes(buf)
    if not GetNumFastTravelNodes then return end

    local numNodes = GetNumFastTravelNodes() or 0
    for nodeIndex = 1, numNodes do
        local known, name, nX, nY, icon, glowIcon, poiType, isOnCurrentMap, linkedCollectibleLocked =
            GetFastTravelNodeInfo(nodeIndex)

        local zoneIndex, poiIndex
        if GetFastTravelNodePOIIndicies then
            zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        end

        local zoneId, parentZoneId, zoneName, parentZoneName
        if zoneIndex then
            if GetZoneId then zoneId = GetZoneId(zoneIndex) end
            if GetZoneNameByIndex then zoneName = GetZoneNameByIndex(zoneIndex) end
            if zoneId and GetParentZoneId then
                parentZoneId = GetParentZoneId(zoneId)
                if parentZoneId and GetZoneNameById then
                    parentZoneName = GetZoneNameById(parentZoneId)
                end
            end
        end

        local poiName
        if zoneIndex and poiIndex and GetPOIInfo then
            poiName = select(1, GetPOIInfo(zoneIndex, poiIndex))
        end

        -- NODE|nodeIndex|known|name|nX|nY|poiType|zoneIndex|zoneId|zoneName|parentZoneId|parentZoneName|poiIndex|poiName
        AddLine(buf, "NODE", {
            SafeStr(nodeIndex),
            SafeStr(known and 1 or 0),
            SafeStr(name),
            SafeStr(nX),
            SafeStr(nY),
            SafeStr(poiType),
            SafeStr(zoneIndex),
            SafeStr(zoneId),
            SafeStr(zoneName),
            SafeStr(parentZoneId),
            SafeStr(parentZoneName),
            SafeStr(poiIndex),
            SafeStr(poiName),
        })
    end
end

---@param icon string
---@return string|nil
local function GetMapLocationType(icon)
    -- Some maps (notably city/subzone maps) may use a different pin icon for kiosks.
    -- Prefer exact-match when possible, but allow a substring match as a low-risk fallback.
    if icon == KIOSK_ICON or IconContains(icon, "guildkiosk") then return "kiosk" end
    if icon == VENDOR_ICON then return "vendor" end
    if icon == FENCE_ICON then return "fence" end
    if icon == THIEVES_GUILD_ICON then return "thieves" end
    if IconContains(icon, "outlaw") then return "outlawrefuge" end
    return nil
end

---@param text any
---@return boolean
local function IsTraderText(text)
    if not text or text == "" then
        return false
    end
    local s = tostring(text)
    if zo_strformat then
        s = zo_strformat("<<1>>", s)
    end
    s = s:gsub("%s+", " ")
    s = string.upper(s)
    return string.find(s, "GUILD TRADER", 1, true) ~= nil or string.find(s, "OUTLAW TRADER", 1, true) ~= nil
end

---@param text any
---@return boolean
local function IsOutlawRefugeText(text)
    if not text or text == "" then
        return false
    end
    local s = tostring(text)
    if zo_strformat then
        s = zo_strformat("<<1>>", s)
    end
    s = s:gsub("%s+", " ")
    s = string.upper(s)
    return string.find(s, "OUTLAW", 1, true) ~= nil and string.find(s, "REFUGE", 1, true) ~= nil
end

---@param locationIndex number
---@return boolean
local function HasKioskTooltipIcon(locationIndex)
    if not GetNumMapLocationTooltipLines or not GetMapLocationTooltipLineInfo then
        return false
    end

    local numLines = GetNumMapLocationTooltipLines(locationIndex) or 0
    for lineIndex = 1, numLines do
        local visible = true
        if IsMapLocationTooltipLineVisible then
            visible = IsMapLocationTooltipLineVisible(locationIndex, lineIndex)
        end
        if visible then
            local lineIcon, name, _groupingId, categoryName = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)
            if lineIcon == KIOSK_TOOLTIP_ICON then
                return true
            end
            -- Fallback: if icon differs for some reason, use category/name heuristics.
            if IsTraderText(name) or IsTraderText(categoryName) then
                return true
            end
        end
    end

    return false
end

---@param locationIndex number
---@return boolean
local function HasOutlawRefugeTooltipIcon(locationIndex)
    if not GetNumMapLocationTooltipLines or not GetMapLocationTooltipLineInfo then
        return false
    end

    -- Primary: tooltip header often contains "Outlaws Refuge".
    if GetMapLocationTooltipHeader then
        local header = GetMapLocationTooltipHeader(locationIndex)
        if IsOutlawRefugeText(header) then
            return true
        end
    end

    local numLines = GetNumMapLocationTooltipLines(locationIndex) or 0
    for lineIndex = 1, numLines do
        local visible = true
        if IsMapLocationTooltipLineVisible then
            visible = IsMapLocationTooltipLineVisible(locationIndex, lineIndex)
        end
        if visible then
            local lineIcon, name, _groupingId, categoryName = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)
            if IconContains(lineIcon, "outlaw") then
                return true
            end
            -- Fallback: some refuge pins do not use an "outlaw" icon; detect via text.
            if IsOutlawRefugeText(name) or IsOutlawRefugeText(categoryName) then
                return true
            end
        end
    end
    return false
end

---@param locationIndex number
---@param icon string|nil
---@return string|nil
local function GetLookupLocationType(locationIndex, icon)
    -- Lookups exports only care about kiosks and Outlaws Refuge entrances.
    --
    -- Some Outlaws Refuge entrances show up with other service icons (e.g. fence/thieves),
    -- so in lookups-mode we must still classify them via tooltip text even when an icon maps
    -- to another locType.
    if icon and IconContains(icon, "outlaw") then
        return "outlawrefuge"
    end
    if HasOutlawRefugeTooltipIcon(locationIndex) then
        return "outlawrefuge"
    end

    if icon and (icon == KIOSK_ICON or IconContains(icon, "guildkiosk")) then
        return "kiosk"
    end
    if HasKioskTooltipIcon(locationIndex) then
        return "kiosk"
    end

    return nil
end

---@param x any
---@param y any
---@return boolean
local function IsNormalizedInBounds(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        return false
    end
    return x >= 0 and x <= 1 and y >= 0 and y <= 1
end

---@param buf ExportBuffer
---@param mapId number
---@param debug boolean|nil
---@return number
---@return table[]|nil waysFound
local function AddCurrentMapWayshrines(buf, mapId, debug)
    if not GetNumFastTravelNodes or not GetFastTravelNodeInfo then return 0 end
    if not POI_TYPE_WAYSHRINE then return 0 end

    local count = 0
    ---@type table[]|nil
    local waysFound = debug and {} or nil
    local numNodes = GetNumFastTravelNodes() or 0
    for nodeIndex = 1, numNodes do
        local known, name, nX, nY, _icon, _glowIcon, poiType, isOnCurrentMap = GetFastTravelNodeInfo(nodeIndex)
        local inBounds = IsNormalizedInBounds(nX, nY)
        if isOnCurrentMap and poiType == POI_TYPE_WAYSHRINE and inBounds then
            count = count + 1
            local cleanName = name
            if cleanName and zo_strformat then
                cleanName = zo_strformat("<<1>>", cleanName)
            end

            -- WAY|mapId|nodeIndex|known|x|y|name
            AddLine(buf, "WAY", {
                SafeStr(mapId),
                SafeStr(nodeIndex),
                SafeStr(known and 1 or 0),
                SafeStr(nX),
                SafeStr(nY),
                SafeStr(cleanName),
            })

            local nodeZoneIndex, nodePoiIndex = nil, nil
            if GetFastTravelNodePOIIndicies then
                nodeZoneIndex, nodePoiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
            end

            -- WAYMETA|mapId|nodeIndex|nodeZoneIndex|nodePoiIndex|poiType|isOnCurrentMap
            AddLine(buf, "WAYMETA", {
                SafeStr(mapId),
                SafeStr(nodeIndex),
                SafeStr(nodeZoneIndex),
                SafeStr(nodePoiIndex),
                SafeStr(poiType),
                SafeStr(isOnCurrentMap and 1 or 0),
            })

            if waysFound then
                waysFound[#waysFound + 1] = {
                    nodeIndex = nodeIndex,
                    name = cleanName,
                    known = known and 1 or 0,
                    x = nX,
                    y = nY,
                }
            end
        end
    end

    return count, waysFound
end

---@param buf ExportBuffer
local function AddCurrentMapLocations(buf)
    if not GetNumMapLocations then return 0 end

    local mapId = GetCurrentMapId and GetCurrentMapId() or 0
    local mapName = GetMapName and GetMapName() or ""
    local mapType = GetMapType and GetMapType() or 0
    local mapContentType = GetMapContentType and GetMapContentType() or 0
    local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or 0

    local zoneId, parentZoneId
    if zoneIndex and GetZoneId then
        zoneId = GetZoneId(zoneIndex)
        -- Prefer ESOUI's exploration parent resolution when available (matches MapActions behavior).
        if zoneIndex and ZO_ExplorationUtils_GetParentZoneIdByZoneIndex then
            local derived = ZO_ExplorationUtils_GetParentZoneIdByZoneIndex(zoneIndex)
            if type(derived) == "number" and derived ~= 0 then
                parentZoneId = derived
            end
        end
        if (not parentZoneId) and zoneId and GetParentZoneId then
            parentZoneId = GetParentZoneId(zoneId)
        end
    end

    -- MAP|mapId|mapName|mapType|mapContentType|zoneIndex|zoneId|parentZoneId
    AddLine(buf, "MAP", {
        SafeStr(mapId),
        SafeStr(mapName),
        SafeStr(mapType),
        SafeStr(mapContentType),
        SafeStr(zoneIndex),
        SafeStr(zoneId),
        SafeStr(parentZoneId),
    })

    local exportedCount = 0
    local numLocations = GetNumMapLocations() or 0

    for locIndex = 1, numLocations do
        local icon, x, y = GetMapLocationIcon(locIndex)
        local locType = GetMapLocationType(icon)
        if not locType and HasKioskTooltipIcon(locIndex) then
            locType = "kiosk"
        end
        if not locType and HasOutlawRefugeTooltipIcon(locIndex) then
            locType = "outlawrefuge"
        end

        if locType then
            exportedCount = exportedCount + 1
            local header = ""
            if GetMapLocationTooltipHeader then
                header = zo_strformat and zo_strformat("<<1>>", GetMapLocationTooltipHeader(locIndex)) or
                    GetMapLocationTooltipHeader(locIndex)
            end

            -- LOC|mapId|locIndex|locType|x|y|header
            AddLine(buf, "LOC", {
                SafeStr(mapId),
                SafeStr(locIndex),
                SafeStr(locType),
                SafeStr(x),
                SafeStr(y),
                SafeStr(header),
            })

            -- Export tooltip lines (includes groupingId used by ESOUI for grouping/sorting; not a stable guild id)
            if GetNumMapLocationTooltipLines and GetMapLocationTooltipLineInfo then
                local numLines = GetNumMapLocationTooltipLines(locIndex) or 0
                for lineIndex = 1, numLines do
                    local visible = true
                    if IsMapLocationTooltipLineVisible then
                        visible = IsMapLocationTooltipLineVisible(locIndex, lineIndex)
                    end

                    local lineIcon, name, groupingId, categoryName = GetMapLocationTooltipLineInfo(locIndex, lineIndex)
                    if groupingId == nil then
                        groupingId = 0
                    end

                    local cleanName = name
                    if cleanName and zo_strformat then
                        cleanName = zo_strformat("<<1>>", cleanName)
                    end
                    local cleanCategory = categoryName
                    if cleanCategory and zo_strformat then
                        cleanCategory = zo_strformat("<<1>>", cleanCategory)
                    end

                    -- LOCLINE|mapId|locIndex|lineIndex|groupingId|categoryName|name|icon|visible
                    AddLine(buf, "LOCLINE", {
                        SafeStr(mapId),
                        SafeStr(locIndex),
                        SafeStr(lineIndex),
                        SafeStr(groupingId),
                        SafeStr(cleanCategory),
                        SafeStr(cleanName),
                        SafeStr(lineIcon),
                        SafeStr(visible and 1 or 0),
                    })

                    -- Preserve existing kiosk export for continuity.
                    if visible and lineIcon == KIOSK_TOOLTIP_ICON and cleanName and cleanName ~= "" then
                        -- KIOSK|mapId|locIndex|kioskName
                        AddLine(buf, "KIOSK", {
                            SafeStr(mapId),
                            SafeStr(locIndex),
                            SafeStr(cleanName),
                        })
                    end
                end
            end
        end
    end

    exportedCount = exportedCount + AddCurrentMapWayshrines(buf, mapId)
    return exportedCount
end

---@param buf ExportBuffer
---@param includeTypes table<string, boolean>
---@param debug boolean|nil
---@return number exportedCount
---@return number kioskCount
---@return number outlawRefugeCount
---@return table|nil debugDetails
local function AddCurrentMapLocationsFiltered(buf, includeTypes, debug)
    if not GetNumMapLocations then return 0, 0, 0 end

    local mapId = GetCurrentMapId and GetCurrentMapId() or 0
    local mapName = GetMapName and GetMapName() or ""
    local mapType = GetMapType and GetMapType() or 0
    local mapContentType = GetMapContentType and GetMapContentType() or 0
    local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or 0

    local zoneId, parentZoneId
    if zoneIndex and GetZoneId then
        zoneId = GetZoneId(zoneIndex)
        if zoneIndex and ZO_ExplorationUtils_GetParentZoneIdByZoneIndex then
            local derived = ZO_ExplorationUtils_GetParentZoneIdByZoneIndex(zoneIndex)
            if type(derived) == "number" and derived ~= 0 then
                parentZoneId = derived
            end
        end
        if (not parentZoneId) and zoneId and GetParentZoneId then
            parentZoneId = GetParentZoneId(zoneId)
        end
    end

    -- MAP|mapId|mapName|mapType|mapContentType|zoneIndex|zoneId|parentZoneId
    AddLine(buf, "MAP", {
        SafeStr(mapId),
        SafeStr(mapName),
        SafeStr(mapType),
        SafeStr(mapContentType),
        SafeStr(zoneIndex),
        SafeStr(zoneId),
        SafeStr(parentZoneId),
    })

    local exportedCount = 0
    local kioskCount = 0
    local outlawRefugeCount = 0

    local traderSeen = nil
    local traders = nil
    local outlawSeen = nil
    local outlaws = nil
    local debugDetails = nil
    if debug then
        traderSeen = {}
        traders = {}
        outlawSeen = {}
        outlaws = {}
        debugDetails = {
            mapId = mapId,
            mapName = mapName,
            zoneIndex = zoneIndex,
            zoneId = zoneId,
            parentZoneId = parentZoneId,
            traders = traders,
            outlaws = outlaws,
        }
    end

    local numLocations = GetNumMapLocations() or 0
    for locIndex = 1, numLocations do
        local icon, x, y = GetMapLocationIcon(locIndex)
        local locType = GetLookupLocationType(locIndex, icon)

        if locType and includeTypes and includeTypes[locType] then
            exportedCount = exportedCount + 1
            if locType == "kiosk" then
                kioskCount = kioskCount + 1
            elseif locType == "outlawrefuge" then
                outlawRefugeCount = outlawRefugeCount + 1
            end

            local header = ""
            if GetMapLocationTooltipHeader then
                header = zo_strformat and zo_strformat("<<1>>", GetMapLocationTooltipHeader(locIndex)) or
                    GetMapLocationTooltipHeader(locIndex)
            end
            if debugDetails and outlawSeen and outlaws and locType == "outlawrefuge" then
                local key = SafeStr(header)
                if key ~= "" and not outlawSeen[key] then
                    outlawSeen[key] = true
                    outlaws[#outlaws + 1] = header
                end
            end

            -- LOC|mapId|locIndex|locType|x|y|header
            AddLine(buf, "LOC", {
                SafeStr(mapId),
                SafeStr(locIndex),
                SafeStr(locType),
                SafeStr(x),
                SafeStr(y),
                SafeStr(header),
            })

            -- Export tooltip lines (includes groupingId used by ESOUI for grouping/sorting; not a stable guild id)
            if GetNumMapLocationTooltipLines and GetMapLocationTooltipLineInfo then
                local numLines = GetNumMapLocationTooltipLines(locIndex) or 0
                for lineIndex = 1, numLines do
                    local visible = true
                    if IsMapLocationTooltipLineVisible then
                        visible = IsMapLocationTooltipLineVisible(locIndex, lineIndex)
                    end

                    local lineIcon, name, groupingId, categoryName = GetMapLocationTooltipLineInfo(locIndex, lineIndex)
                    if groupingId == nil then
                        groupingId = 0
                    end

                    local cleanName = name
                    if cleanName and zo_strformat then
                        cleanName = zo_strformat("<<1>>", cleanName)
                    end
                    local cleanCategory = categoryName
                    if cleanCategory and zo_strformat then
                        cleanCategory = zo_strformat("<<1>>", cleanCategory)
                    end

                    -- LOCLINE|mapId|locIndex|lineIndex|groupingId|categoryName|name|icon|visible
                    AddLine(buf, "LOCLINE", {
                        SafeStr(mapId),
                        SafeStr(locIndex),
                        SafeStr(lineIndex),
                        SafeStr(groupingId),
                        SafeStr(cleanCategory),
                        SafeStr(cleanName),
                        SafeStr(lineIcon),
                        SafeStr(visible and 1 or 0),
                    })

                    -- Preserve existing kiosk export for continuity.
                    if visible and lineIcon == KIOSK_TOOLTIP_ICON and cleanName and cleanName ~= "" then
                        -- KIOSK|mapId|locIndex|kioskName
                        AddLine(buf, "KIOSK", {
                            SafeStr(mapId),
                            SafeStr(locIndex),
                            SafeStr(cleanName),
                        })

                        if debugDetails and traderSeen and traders then
                            local key = SafeStr(cleanName)
                            if key ~= "" and not traderSeen[key] then
                                traderSeen[key] = true
                                traders[#traders + 1] = cleanName
                            end
                        end
                    end
                end
            end
        end
    end

    return exportedCount, kioskCount, outlawRefugeCount, debugDetails
end

---@return ExportBuffer
function SmartTrader.ExportActions.BuildGuildExport()
    local buf = CreateBuffer()
    AddGuildExportSchema(buf)
    AddMeta(buf)
    AddGuilds(buf)
    return buf
end

---@return ExportBuffer
function SmartTrader.ExportActions.BuildNodeExport()
    local buf = CreateBuffer()
    AddNodeExportSchema(buf)
    AddMeta(buf)
    AddNodes(buf)
    return buf
end

---@return ExportBuffer, number
function SmartTrader.ExportActions.BuildMapExport()
    local buf = CreateBuffer()
    AddMapExportSchema(buf)
    AddMeta(buf)
    local count = AddCurrentMapLocations(buf)
    return buf, count
end

---@return ExportBuffer
function SmartTrader.ExportActions.BuildFullExport()
    local buf = CreateBuffer()
    AddFullExportSchema(buf)
    AddMeta(buf)
    AddGuilds(buf)
    AddNodes(buf)
    AddCurrentMapLocations(buf)
    return buf
end

---@param scanAll boolean|nil When true, scans the entire map list. When false/nil, scopes to the current map's parentZoneId.
---@param debug boolean|nil When true, returns debugInfo to help diagnose map scoping / detection issues.
---@return ExportBuffer, number, string|nil errorMessage, table|nil debugInfo
function SmartTrader.ExportActions.BuildLookupExport(scanAll, debug)
    local buf = CreateBuffer()
    AddLookupExportSchema(buf)
    AddMeta(buf)

    if not GetNumMaps or not SetMapToMapListIndex then
        return buf, 0, "[SmartTrader] Export lookups not supported (missing map list APIs).", nil
    end

    local originalMapId = GetCurrentMapId and GetCurrentMapId() or nil

    -- Only export what we need for lookup tables (keep output size manageable).
    local includeTypes = {
        kiosk = true,
        outlawrefuge = true,
    }

    ---@return number|nil zoneIndex
    ---@return number|nil zoneId
    ---@return number|nil parentZoneId
    local function GetCurrentMapZoneIds()
        local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
        if type(zoneIndex) ~= "number" or zoneIndex == 0 then
            return nil, nil, nil
        end

        local zoneId = (GetZoneId and GetZoneId(zoneIndex)) or nil
        if type(zoneId) ~= "number" or zoneId == 0 then
            return zoneIndex, nil, nil
        end

        -- Prefer ESOUI's exploration parent resolution when available (matches MapActions behavior).
        local parentZoneId = nil
        if ZO_ExplorationUtils_GetParentZoneIdByZoneIndex then
            local derived = ZO_ExplorationUtils_GetParentZoneIdByZoneIndex(zoneIndex)
            if type(derived) == "number" and derived ~= 0 then
                parentZoneId = derived
            end
        end
        if (not parentZoneId) and GetParentZoneId then
            local derived = GetParentZoneId(zoneId)
            if type(derived) == "number" and derived ~= 0 then
                parentZoneId = derived
            end
        end

        -- Some zones report no parent; treat as self-parented.
        if not parentZoneId then
            parentZoneId = zoneId
        end

        return zoneIndex, zoneId, parentZoneId
    end

    local scopeAll = scanAll == true

    ---@param value any
    ---@return string
    local function NormalizeMapNameKey(value)
        if not value then
            return ""
        end
        local s = tostring(value)
        if zo_strformat then
            s = zo_strformat("<<1>>", s)
        end
        s = s:gsub("%s+", " ")
        s = s:gsub("^%s+", "")
        s = s:gsub("%s+$", "")
        return string.upper(s)
    end

    ---@param mapName any
    ---@return string|nil baseCityKeyUpper
    local function GetOutlawRefugeBaseCityKeyUpper(mapName)
        local upper = NormalizeMapNameKey(mapName)
        if upper == "" then
            return nil
        end
        local pos = string.find(upper, " OUTLAWS REFUGE", 1, true) or string.find(upper, " OUTLAW REFUGE", 1, true)
        if not pos then
            return nil
        end
        local base = string.sub(upper, 1, pos - 1)
        base = base:gsub("%s+$", "")
        if base == "" then
            return nil
        end
        return base
    end

    local anchorMapId = GetCurrentMapId and GetCurrentMapId() or 0
    local anchorMapName = GetMapName and GetMapName() or ""
    local anchorMapType = GetMapType and GetMapType() or nil
    local anchorZoneIndex, anchorZoneId, anchorParentZoneId = GetCurrentMapZoneIds()
    local anchorMapNameKey = NormalizeMapNameKey(anchorMapName)

    ---@param label string
    local function DumpLookupsOutlawRefugeDebugForCurrentMap(label)
        if not debug then
            return
        end
        if not GetNumMapLocations or not GetMapLocationIcon then
            return
        end

        local mapId = GetCurrentMapId and GetCurrentMapId() or 0
        local mapName = GetMapName and GetMapName() or ""
        local locCount = GetNumMapLocations() or 0
        CL:Log(string.format(
            "[SmartTrader] lookups debug: %s mapId=%s name=%s locations=%s",
            tostring(label), tostring(mapId), tostring(mapName), tostring(locCount)))

        if locCount == 0 then
            return
        end

        local printed = 0
        for locIndex = 1, locCount do
            local icon = select(1, GetMapLocationIcon(locIndex))
            local baseType = GetMapLocationType(icon)
            local lookupType = GetLookupLocationType(locIndex, icon)
            local tooltipOutlaw = HasOutlawRefugeTooltipIcon(locIndex)

            local header = ""
            if GetMapLocationTooltipHeader then
                header = zo_strformat and zo_strformat("<<1>>", GetMapLocationTooltipHeader(locIndex)) or
                    GetMapLocationTooltipHeader(locIndex)
            end

            local suspicious = tooltipOutlaw or lookupType == "outlawrefuge"
            if IconContains(icon, "outlaw") or IconContains(icon, "fence") or IconContains(icon, "thieves") then
                suspicious = true
            end
            local headerUpper = string.upper(tostring(header or ""))
            if headerUpper ~= "" and (string.find(headerUpper, "OUTLAW", 1, true) or string.find(headerUpper, "REFUGE", 1, true)) then
                suspicious = true
            end

            if not suspicious and GetNumMapLocationTooltipLines and GetMapLocationTooltipLineInfo then
                local numLines = GetNumMapLocationTooltipLines(locIndex) or 0
                for lineIndex = 1, numLines do
                    local visible = true
                    if IsMapLocationTooltipLineVisible then
                        visible = IsMapLocationTooltipLineVisible(locIndex, lineIndex)
                    end
                    if visible then
                        local lineIcon, name, _groupingId, categoryName = GetMapLocationTooltipLineInfo(locIndex,
                            lineIndex)
                        local upName = string.upper(tostring(name or ""))
                        local upCat = string.upper(tostring(categoryName or ""))
                        if (upName ~= "" and (string.find(upName, "OUTLAW", 1, true) or string.find(upName, "REFUGE", 1, true))) or
                            (upCat ~= "" and (string.find(upCat, "OUTLAW", 1, true) or string.find(upCat, "REFUGE", 1, true))) or
                            IconContains(lineIcon, "outlaw") then
                            suspicious = true
                            break
                        end
                    end
                end
            end

            if suspicious then
                printed = printed + 1
                CL:Log(string.format(
                    "[SmartTrader] lookups debug: loc=%d baseType=%s lookupType=%s tooltipOutlaw=%s icon=%s header=%s",
                    locIndex, tostring(baseType), tostring(lookupType), tostring(tooltipOutlaw), tostring(icon),
                    tostring(header)))
            end
        end

        if printed == 0 then
            CL:Log("[SmartTrader] lookups debug: no refuge-adjacent map locations found on " .. tostring(label))
        end
    end

    if not scopeAll then
        if anchorMapType == MAPTYPE_WORLD or anchorMapType == MAPTYPE_COSMIC then
            return buf, 0,
                "[SmartTrader] /st export lookups is zone-scoped: open a zone/city map (not world) and try again, or use: /st export lookups all, or: /st export lookups zones",
                nil
        end

        if not anchorParentZoneId then
            return buf, 0,
                "[SmartTrader] Could not determine current map zone context. Open a zone/city map first, or use: /st export lookups all",
                nil
        end
    end

    local totalExported = 0
    local totalKiosks = 0
    local totalOutlawRefuges = 0
    local mapsScanned = 0
    local mapsInScope = 0
    local mapsExported = 0
    local mapsSkippedDuplicate = 0
    local mapsNoLocations = 0

    ---@type table|nil
    local debugInfo = nil
    if debug then
        debugInfo = {
            anchor = {
                mapId = anchorMapId,
                mapName = anchorMapName,
                mapType = anchorMapType,
                zoneIndex = anchorZoneIndex,
                zoneId = anchorZoneId,
                parentZoneId = anchorParentZoneId,
                scopeAll = scopeAll,
            },
            maps = {
                scanned = 0,
                inScope = 0,
                exported = 0,
                skippedDuplicate = 0,
                noLocations = 0,
            },
            counts = {
                exportedLocs = 0,
                kioskPins = 0,
                outlawRefuges = 0,
            },
        }
    end

    ---@type table<number, boolean>
    local exportedMapIds = {}

    -- Export the currently viewed map first. Some city/subzone maps do not appear in the map list.
    local anchorLocCount = GetNumMapLocations and GetNumMapLocations() or 0
    DumpLookupsOutlawRefugeDebugForCurrentMap("anchor")
    if anchorLocCount > 0 then
        local exported, kiosks, outlaws = AddCurrentMapLocationsFiltered(buf, includeTypes)
        totalExported = totalExported + (exported or 0)
        totalKiosks = totalKiosks + (kiosks or 0)
        totalOutlawRefuges = totalOutlawRefuges + (outlaws or 0)
        mapsExported = mapsExported + 1
        if type(anchorMapId) == "number" and anchorMapId ~= 0 then
            exportedMapIds[anchorMapId] = true
        end
    else
        mapsNoLocations = mapsNoLocations + 1
    end

    local numMaps = GetNumMaps() or 0
    for mapListIndex = 1, numMaps do
        SetMapToMapListIndex(mapListIndex)
        mapsScanned = mapsScanned + 1

        local currentMapId = GetCurrentMapId and GetCurrentMapId() or 0
        local currentMapName = GetMapName and GetMapName() or ""
        local isRefugeMapForAnchor = false
        if not scopeAll and anchorMapNameKey ~= "" and IsOutlawRefugeText(currentMapName) then
            local baseCityKeyUpper = GetOutlawRefugeBaseCityKeyUpper(currentMapName)
            isRefugeMapForAnchor = baseCityKeyUpper ~= nil and baseCityKeyUpper == anchorMapNameKey
        end

        local inScope = true
        if not scopeAll then
            local _zoneIndex, _zoneId, parentZoneId = GetCurrentMapZoneIds()
            if not parentZoneId or parentZoneId ~= anchorParentZoneId then
                -- Different zone hierarchy; skip.
                inScope = false
                -- Fallback: some Outlaws Refuge interior maps may not report the expected zone hierarchy.
                if isRefugeMapForAnchor then
                    inScope = true
                end
            end
        end

        if inScope then
            mapsInScope = mapsInScope + 1

            if type(currentMapId) == "number" and currentMapId ~= 0 and exportedMapIds[currentMapId] then
                mapsSkippedDuplicate = mapsSkippedDuplicate + 1
            else
                -- Skip maps that have no locations (fast path).
                local locCount = GetNumMapLocations and GetNumMapLocations() or 0
                if locCount > 0 or isRefugeMapForAnchor then
                    local exported, kiosks, outlaws = AddCurrentMapLocationsFiltered(buf, includeTypes)
                    totalExported = totalExported + (exported or 0)
                    totalKiosks = totalKiosks + (kiosks or 0)
                    totalOutlawRefuges = totalOutlawRefuges + (outlaws or 0)
                    mapsExported = mapsExported + 1
                    if type(currentMapId) == "number" and currentMapId ~= 0 then
                        exportedMapIds[currentMapId] = true
                    end
                else
                    mapsNoLocations = mapsNoLocations + 1
                end
            end
        end
    end

    -- Restore original map.
    if originalMapId then
        SetMapToMapIdForCrawl(originalMapId)
    end

    if debugInfo then
        debugInfo.maps.scanned = mapsScanned
        debugInfo.maps.inScope = mapsInScope
        debugInfo.maps.exported = mapsExported
        debugInfo.maps.skippedDuplicate = mapsSkippedDuplicate
        debugInfo.maps.noLocations = mapsNoLocations
        debugInfo.counts.exportedLocs = totalExported
        debugInfo.counts.kioskPins = totalKiosks
        debugInfo.counts.outlawRefuges = totalOutlawRefuges
    end

    return buf, totalExported, nil, debugInfo
end

---@param buf ExportBuffer
---@return boolean, string|nil
local function SubmitBuffer(buf)
    local LogExport = LibConsoleLogger and LibConsoleLogger.WebExport or nil
    if not LogExport then
        return false, "LibConsoleLogger.WebExport not available"
    end
    if not buf or #buf.lines == 0 then
        return false, "No data to export"
    end

    local cfg = SmartTrader.state and SmartTrader.state.savedVars and SmartTrader.state.savedVars.logExport or nil

    LogExport.BufferClear()
    for _, line in ipairs(buf.lines) do
        LogExport.BufferD(line)
    end

    CL:Log(string.format("[SmartTrader] Export: %d lines, session=%s", #buf.lines, buf.sessionId))
    local ok, reason = LogExport.SubmitBuffered(cfg)
    if not ok then
        -- Avoid retaining large buffers on failed export attempts (e.g. no-url/no-api/busy).
        LogExport.BufferClear()
    end
    return ok, reason
end

local function StopLookupsZoneCrawl(message, restoreMap)
    local s = lookupsZoneCrawlState
    if not s then
        return
    end

    EVENT_MANAGER:UnregisterForUpdate(LOOKUPS_ZONE_CRAWL_NAMESPACE)
    lookupsZoneCrawlState = nil

    if restoreMap and s.originalMapId then
        SetMapToMapIdForCrawl(s.originalMapId)
    end

    if message then
        CL:Log(message)
    end
end

---@param debug boolean|nil
---@param targetZoneId number|nil When set, restricts the scan to the currently visible zone (zoneId) and its child maps.
function SmartTrader.ExportActions.StartLookupExportZoneCrawl(debug, targetZoneId)
    if lookupsZoneCrawlState then
        CL:Log("[SmartTrader] Lookups zone crawl already running.")
        return
    end

    if not GetMapInfoById or not GetCurrentMapId or not GetFrameTimeMilliseconds then
        CL:Log("[SmartTrader] /st export lookups zones not supported (missing mapId APIs).")
        return
    end

    if not SetMapToMapId and not (WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById) then
        CL:Log("[SmartTrader] /st export lookups zones not supported (missing SetMapToMapId).")
        return
    end

    ---@param mapName string
    ---@param mapType UIMapType
    ---@param mapContentType MapContentType
    ---@return boolean include
    local function IsEligibleLookupMap(mapName, mapType, mapContentType)
        if mapType == MAPTYPE_WORLD or mapType == MAPTYPE_COSMIC or mapType == MAPTYPE_NONE or mapType == MAPTYPE_DEPRECATED_1 then
            return false
        end
        if mapContentType == MAP_CONTENT_AVA or mapContentType == MAP_CONTENT_BATTLEGROUND then
            return false
        end
        if mapContentType == MAP_CONTENT_DUNGEON and not IsOutlawRefugeText(mapName) then
            return false
        end
        return true
    end

    ---@param zoneIndex luaindex|nil
    ---@return integer|nil zoneId
    ---@return integer|nil parentZoneId
    local function GetZoneIdsForZoneIndex(zoneIndex)
        local zi = tonumber(zoneIndex) or 0
        if zi <= 0 then
            return nil, nil
        end

        local zoneId = nil
        if GetZoneId then
            local z = GetZoneId(zi)
            if type(z) == "number" and z ~= 0 then
                zoneId = z
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

    local cacheMaxMapId = 3000
    if GetNumMaps and GetMapIdByIndex then
        local numMaps = GetNumMaps() or 0
        local maxFromList = 0
        for mapIndex = 1, numMaps do
            local mapId = GetMapIdByIndex(mapIndex)
            if type(mapId) == "number" and mapId > maxFromList then
                maxFromList = mapId
            end
        end
        if maxFromList > 0 then
            cacheMaxMapId = maxFromList + LOOKUPS_ZONE_CRAWL_MAPID_CACHE_MARGIN
        end
    end

    local buf = CreateBuffer()
    AddLookupExportSchema(buf)
    AddMeta(buf)

    -- Only export what we need for lookup tables (plus wayshrines).
    local includeTypes = {
        kiosk = true,
        outlawrefuge = true,
    }

    local originalMapId = GetCurrentMapId and GetCurrentMapId() or nil
    local originalMapName = GetMapName and GetMapName() or ""
    local originalZoneIndex, originalZoneId, originalParentZoneId = GetCurrentMapZoneIdsForScope()

    local target = tonumber(targetZoneId)
    if type(target) ~= "number" or target <= 0 then
        target = nil
    end

    lookupsZoneCrawlState = {
        buf = buf,
        includeTypes = includeTypes,
        debug = debug == true,
        originalMapId = originalMapId,
        originalMapName = originalMapName,
        originalZoneIndex = originalZoneIndex,
        originalZoneId = originalZoneId,
        originalParentZoneId = originalParentZoneId,
        targetZoneId = target,
        pendingMapId = nil,
        pendingPurpose = nil, -- "export"
        pendingStartMs = nil,
        pendingReadyMs = nil,
        ---@type table<number, boolean>
        exportedMapIds = {},
        -- MapId cache by parent zone id (built incrementally before scanning)
        cacheDone = false,
        cacheMaxMapId = cacheMaxMapId,
        cacheNextMapId = 1,
        cacheScanned = 0,
        cacheEligible = 0,
        ---@type table<integer, integer[]>
        mapIdsByParentZoneId = {},
        ---@type integer[]|nil
        targetMapIds = target and {} or nil,
        ---@type table<integer, table>|nil
        targetMapInfoById = target and {} or nil,
        ---@type integer[]|nil
        parentZoneIds = nil,
        nextParentIndex = nil,
        nextMapIndexInParent = nil,
        -- Counters
        parentsTotal = 0,
        parentsDone = 0,
        mapsTotal = 0,
        mapsAttempted = 0,
        mapsSetFailed = 0,
        mapsExported = 0,
        mapsNoData = 0,
        exportedLocs = 0,
        kioskPins = 0,
        outlawRefuges = 0,
        wayshrines = 0,
    }

    if target then
        CL:Log(string.format(
            "[SmartTrader] Lookups zone scan started: targetZoneId=%s mapId=%s name=%s (building mapId cache maxMapId=%d, debug=%s)",
            tostring(target), tostring(originalMapId), tostring(originalMapName), cacheMaxMapId, tostring(debug == true)))
    else
        CL:Log(string.format(
            "[SmartTrader] Lookups zone crawl started: building mapId cache (maxMapId=%d, debug=%s)",
            cacheMaxMapId, tostring(debug == true)))
    end

    local function Step()
        local s = lookupsZoneCrawlState
        if not s then
            EVENT_MANAGER:UnregisterForUpdate(LOOKUPS_ZONE_CRAWL_NAMESPACE)
            return
        end

        local nowMs = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0

        -- Phase 0: build the mapId cache (by parentZoneId) incrementally so we don't freeze the UI.
        if not s.cacheDone then
            for _ = 1, LOOKUPS_ZONE_CRAWL_MAPID_CACHE_BATCH do
                local mapId = s.cacheNextMapId or 0
                if mapId <= 0 or mapId > (s.cacheMaxMapId or 0) then
                    -- Finalize cache
                    s.cacheDone = true
                    if s.targetZoneId and s.targetMapIds then
                        table.sort(s.targetMapIds)
                        -- Dedupe
                        local write = 0
                        local last = nil
                        for i = 1, #s.targetMapIds do
                            local v = s.targetMapIds[i]
                            if v ~= last then
                                write = write + 1
                                s.targetMapIds[write] = v
                                last = v
                            end
                        end
                        for i = #s.targetMapIds, write + 1, -1 do
                            s.targetMapIds[i] = nil
                        end

                        -- Always include the map the user was on when starting (even if it didn't match zone metadata).
                        if type(s.originalMapId) == "number" and s.originalMapId > 0 then
                            local found = false
                            for i = 1, #s.targetMapIds do
                                if s.targetMapIds[i] == s.originalMapId then
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(s.targetMapIds, 1, s.originalMapId)
                            else
                                -- Move to front for determinism.
                                for i = 1, #s.targetMapIds do
                                    if s.targetMapIds[i] == s.originalMapId then
                                        table.remove(s.targetMapIds, i)
                                        break
                                    end
                                end
                                table.insert(s.targetMapIds, 1, s.originalMapId)
                            end
                        end

                        s.mapIdsByParentZoneId = {}
                        s.mapIdsByParentZoneId[s.targetZoneId] = s.targetMapIds
                        s.parentZoneIds = { s.targetZoneId }
                        s.nextParentIndex = 1
                        s.nextMapIndexInParent = 1
                        s.parentsTotal = 1
                        s.mapsTotal = #s.targetMapIds

                        CL:Log(string.format(
                            "[SmartTrader] Lookups zone scan cache ready: scanned=%d eligible=%d targetZoneId=%d maps=%d",
                            s.cacheScanned or 0, s.cacheEligible or 0, s.targetZoneId or 0, s.mapsTotal or 0))

                        if s.debug and s.targetMapInfoById then
                            CL:Log("[SmartTrader] lookups zone scan: maps to scan:")
                            local maxShow = 200
                            for i = 1, math.min(#s.targetMapIds, maxShow) do
                                local id = s.targetMapIds[i]
                                local info = s.targetMapInfoById[id]
                                if info then
                                    CL:Log(string.format(
                                        "  mapId=%d mapType=%s content=%s zoneIndex=%s zoneId=%s parentZoneId=%s name=%s",
                                        id,
                                        tostring(info.mapType),
                                        tostring(info.mapContentType),
                                        tostring(info.zoneIndex),
                                        tostring(info.zoneId),
                                        tostring(info.parentZoneId),
                                        tostring(info.mapName)))
                                else
                                    CL:Log(string.format("  mapId=%d", id))
                                end
                            end
                            if #s.targetMapIds > maxShow then
                                CL:Log(string.format("  ... and %d more (output capped at %d lines)",
                                    #s.targetMapIds - maxShow,
                                    maxShow))
                            end
                        end
                        return
                    end

                    local parentZoneIds = {}
                    local mapsTotal = 0
                    for parentZoneId, ids in pairs(s.mapIdsByParentZoneId or {}) do
                        table.sort(ids)
                        -- Dedupe
                        local write = 0
                        local last = nil
                        for i = 1, #ids do
                            local v = ids[i]
                            if v ~= last then
                                write = write + 1
                                ids[write] = v
                                last = v
                            end
                        end
                        for i = #ids, write + 1, -1 do
                            ids[i] = nil
                        end

                        mapsTotal = mapsTotal + #ids
                        parentZoneIds[#parentZoneIds + 1] = parentZoneId
                    end
                    table.sort(parentZoneIds)

                    s.parentZoneIds = parentZoneIds
                    s.nextParentIndex = 1
                    s.nextMapIndexInParent = 1
                    s.parentsTotal = #parentZoneIds
                    s.mapsTotal = mapsTotal

                    CL:Log(string.format(
                        "[SmartTrader] Lookups zone crawl cache ready: scanned=%d eligible=%d parents=%d maps=%d",
                        s.cacheScanned or 0, s.cacheEligible or 0, s.parentsTotal or 0, s.mapsTotal or 0))
                    return
                end

                s.cacheNextMapId = mapId + 1
                s.cacheScanned = (s.cacheScanned or 0) + 1

                local mapName, mapType, mapContentType, zoneIndex = GetMapInfoById(mapId)
                if mapName and mapName ~= "" and mapType and mapContentType then
                    if IsEligibleLookupMap(mapName, mapType, mapContentType) then
                        local zoneId, parentZoneId = GetZoneIdsForZoneIndex(zoneIndex)
                        local inTarget = true
                        if s.targetZoneId then
                            inTarget = (zoneId ~= nil and zoneId == s.targetZoneId) or
                                (parentZoneId ~= nil and parentZoneId == s.targetZoneId)
                        end

                        if inTarget then
                            if s.targetZoneId and s.targetMapIds then
                                s.targetMapIds[#s.targetMapIds + 1] = mapId
                                if s.targetMapInfoById then
                                    s.targetMapInfoById[mapId] = {
                                        mapName = mapName,
                                        mapType = mapType,
                                        mapContentType = mapContentType,
                                        zoneIndex = zoneIndex,
                                        zoneId = zoneId,
                                        parentZoneId = parentZoneId,
                                    }
                                end
                            else
                                local parentKey = parentZoneId or zoneId or 0
                                local list = s.mapIdsByParentZoneId[parentKey]
                                if not list then
                                    list = {}
                                    s.mapIdsByParentZoneId[parentKey] = list
                                end
                                list[#list + 1] = mapId
                            end
                        end
                        s.cacheEligible = (s.cacheEligible or 0) + 1
                    end
                end
            end

            if s.debug and (s.cacheScanned or 0) > 0 and ((s.cacheScanned or 0) % 500 == 0) then
                CL:Log(string.format(
                    "[SmartTrader] lookups zones: caching mapIds... scanned=%d/%d eligible=%d",
                    s.cacheScanned or 0, s.cacheMaxMapId or 0, s.cacheEligible or 0))
            end
            return
        end

        -- Phase 1: finish any pending map switch (wait until the mapId matches).
        if s.pendingMapId then
            local currentMapId = GetCurrentMapId and GetCurrentMapId() or 0
            if currentMapId == s.pendingMapId then
                -- Give the map a moment to load its locations before we read pins/wayshrines.
                if not s.pendingReadyMs then
                    s.pendingReadyMs = nowMs + LOOKUPS_ZONE_CRAWL_MAP_SWITCH_SETTLE_MS
                    return
                end
                if nowMs < s.pendingReadyMs then
                    return
                end

                local purpose = s.pendingPurpose

                if purpose == "export" then
                    if currentMapId ~= 0 and not s.exportedMapIds[currentMapId] then
                        -- Export kiosk/outlaw pins.
                        local exported, kiosks, outlaws, locDetails = AddCurrentMapLocationsFiltered(s.buf,
                            s.includeTypes,
                            s.debug)
                        s.exportedLocs = s.exportedLocs + (exported or 0)
                        s.kioskPins = s.kioskPins + (kiosks or 0)
                        s.outlawRefuges = s.outlawRefuges + (outlaws or 0)

                        -- Export wayshrines for this map.
                        local ways, waysFound = AddCurrentMapWayshrines(s.buf, currentMapId, s.debug)
                        s.wayshrines = s.wayshrines + (ways or 0)

                        s.mapsExported = s.mapsExported + 1
                        if (exported or 0) == 0 and (ways or 0) == 0 then
                            s.mapsNoData = s.mapsNoData + 1
                        end

                        s.exportedMapIds[currentMapId] = true

                        if s.debug then
                            local mapName = GetMapName and GetMapName() or ""
                            CL:Log(string.format(
                                "[SmartTrader] lookups zone: mapId=%s name=%s exportedLocs=%d kiosks=%d outlaws=%d ways=%d",
                                tostring(currentMapId), tostring(mapName), exported or 0, kiosks or 0, outlaws or 0,
                                ways or 0))

                            if locDetails and locDetails.traders and #locDetails.traders > 0 then
                                CL:Log(string.format("  traders (%d):", #locDetails.traders))
                                for i = 1, #locDetails.traders do
                                    CL:Log("    " .. tostring(locDetails.traders[i]))
                                end
                            end
                            if locDetails and locDetails.outlaws and #locDetails.outlaws > 0 then
                                CL:Log(string.format("  outlaw refuges (%d):", #locDetails.outlaws))
                                for i = 1, #locDetails.outlaws do
                                    CL:Log("    " .. tostring(locDetails.outlaws[i]))
                                end
                            end
                            if waysFound and #waysFound > 0 then
                                CL:Log(string.format("  wayshrines (%d):", #waysFound))
                                for i = 1, #waysFound do
                                    local w = waysFound[i]
                                    CL:Log(string.format("    node=%s known=%s name=%s", tostring(w.nodeIndex),
                                        tostring(w.known), tostring(w.name)))
                                end
                            end
                        end
                    end

                    if s.debug and (s.mapsExported % 50 == 0) then
                        CL:Log(string.format(
                            "[SmartTrader] lookups zones: exported=%d/%d attempted=%d failed=%d noData=%d kiosks=%d outlaws=%d ways=%d",
                            s.mapsExported, s.mapsTotal, s.mapsAttempted, s.mapsSetFailed, s.mapsNoData,
                            s.kioskPins, s.outlawRefuges, s.wayshrines))
                    end
                end

                s.pendingMapId = nil
                s.pendingPurpose = nil
                s.pendingStartMs = nil
                s.pendingReadyMs = nil
                return
            end

            -- Wait for the map to apply; then give up and continue.
            if not s.pendingStartMs then
                s.pendingStartMs = nowMs
            end
            if (nowMs - s.pendingStartMs) > LOOKUPS_ZONE_CRAWL_MAP_SWITCH_TIMEOUT_MS then
                s.mapsSetFailed = s.mapsSetFailed + 1
                if s.debug and s.mapsSetFailed <= 10 then
                    CL:Log(string.format(
                        "[SmartTrader] lookups zones: map switch timeout mapId=%s currentMapId=%s",
                        tostring(s.pendingMapId), tostring(currentMapId)))
                end
                s.pendingMapId = nil
                s.pendingPurpose = nil
                s.pendingStartMs = nil
                s.pendingReadyMs = nil
            end
            return
        end

        -- Phase 2: pick the next mapId (grouped by parentZoneId) and switch to it.
        local nextMapId = nil
        local parentZoneIds = s.parentZoneIds or {}
        while s.nextParentIndex and s.nextParentIndex <= #parentZoneIds do
            local parentZoneId = parentZoneIds[s.nextParentIndex]
            local list = (s.mapIdsByParentZoneId and s.mapIdsByParentZoneId[parentZoneId]) or {}

            if s.nextMapIndexInParent and s.nextMapIndexInParent <= #list then
                nextMapId = list[s.nextMapIndexInParent]
                s.nextMapIndexInParent = s.nextMapIndexInParent + 1
                break
            end

            s.parentsDone = (s.parentsDone or 0) + 1
            s.nextParentIndex = s.nextParentIndex + 1
            s.nextMapIndexInParent = 1
        end

        if not nextMapId then
            -- Done.
            EVENT_MANAGER:UnregisterForUpdate(LOOKUPS_ZONE_CRAWL_NAMESPACE)

            if s.originalMapId and SetMapToMapId then
                SetMapToMapIdForCrawl(s.originalMapId)
            end

            CL:Log(string.format(
                "%s done: parents=%d maps=%d attempted=%d exported=%d failed=%d noData=%d kiosks=%d outlaws=%d ways=%d",
                s.targetZoneId and "[SmartTrader] Lookups zone scan" or "[SmartTrader] Lookups zone crawl",
                s.parentsTotal or 0, s.mapsTotal or 0, s.mapsAttempted or 0,
                s.mapsExported, s.mapsSetFailed, s.mapsNoData,
                s.kioskPins, s.outlawRefuges, s.wayshrines))

            local ok, err = SubmitBuffer(s.buf)
            if not ok then
                CL:Log("[SmartTrader] Export failed: " .. tostring(err))
            end

            lookupsZoneCrawlState = nil
            return
        end

        s.mapsAttempted = (s.mapsAttempted or 0) + 1
        s.pendingMapId = nextMapId
        s.pendingPurpose = "export"
        s.pendingStartMs = nowMs
        s.pendingReadyMs = nil

        local result = SetMapToMapIdForCrawl(nextMapId)
        if result == SET_MAP_RESULT_FAILED then
            s.mapsSetFailed = s.mapsSetFailed + 1
            if s.debug and s.mapsSetFailed <= 10 then
                CL:Log(string.format("[SmartTrader] lookups zones: failed to set mapId=%s", tostring(nextMapId)))
            end
            s.pendingMapId = nil
            s.pendingPurpose = nil
            s.pendingStartMs = nil
            s.pendingReadyMs = nil
        end
    end

    EVENT_MANAGER:RegisterForUpdate(LOOKUPS_ZONE_CRAWL_NAMESPACE, LOOKUPS_ZONE_CRAWL_INTERVAL_MS, Step)
end

---@return table
function SmartTrader.ExportActions.GetStatus()
    local savedVars = SmartTrader.state and SmartTrader.state.savedVars
    local guildDataById = savedVars and savedVars.guildDataById or {}

    local guildCount = 0
    for _ in pairs(guildDataById) do
        guildCount = guildCount + 1
    end

    local nodeCount = GetNumFastTravelNodes and GetNumFastTravelNodes() or 0
    local mapLocations = GetNumMapLocations and GetNumMapLocations() or 0
    local mapName = GetMapName and GetMapName() or "?"
    local mapId = GetCurrentMapId and GetCurrentMapId() or 0

    return {
        guildCount = guildCount,
        nodeCount = nodeCount,
        mapLocations = mapLocations,
        mapName = mapName,
        mapId = mapId,
    }
end

---@param args string
function SmartTrader.ExportActions.HandleCommand(args)
    args = args or ""
    local sub = args:match("^(%S+)") or ""
    sub = string.lower(sub)
    local rest = args:match("^%S+%s*(.*)$") or ""
    rest = string.lower(rest or "")

    if sub == "" then
        CL:Log("[SmartTrader] Export commands:")
        CL:Log("  /st export guilds - Export guild cache only")
        CL:Log("  /st export nodes  - Export fast travel nodes only")
        CL:Log("  /st export map    - Export current map locations (traders + wayshrines + outlaw refuges)")
        CL:Log(
            "  /st export lookups [all|zones] [debug] - Export kiosk/outlaw lookups (default: current map's zone; add 'all' to scan everything; add 'zones' to crawl all zones)")
        CL:Log("  /st export all    - Export everything (guilds + nodes + current map)")
        CL:Log("  /st export status - Show what data is available")
        return
    end

    if sub == "status" then
        local s = SmartTrader.ExportActions.GetStatus()
        CL:Log("[SmartTrader] Export status:")
        CL:Log(string.format("  Cached guilds: %d", s.guildCount))
        CL:Log(string.format("  Fast travel nodes: %d", s.nodeCount))
        CL:Log(string.format("  Current map: %s (id=%d, locations=%d)", s.mapName, s.mapId, s.mapLocations))
        return
    end

    if sub == "guilds" then
        local buf = SmartTrader.ExportActions.BuildGuildExport()
        local ok, err = SubmitBuffer(buf)
        if not ok then CL:Log("[SmartTrader] Export failed: " .. tostring(err)) end
        return
    end

    if sub == "nodes" then
        local buf = SmartTrader.ExportActions.BuildNodeExport()
        local ok, err = SubmitBuffer(buf)
        if not ok then CL:Log("[SmartTrader] Export failed: " .. tostring(err)) end
        return
    end

    if sub == "map" then
        local buf, count = SmartTrader.ExportActions.BuildMapExport()
        if count == 0 then
            CL:Log("[SmartTrader] No exportable locations on current map. Open a city/zone map first.")
            return
        end
        local ok, err = SubmitBuffer(buf)
        if not ok then CL:Log("[SmartTrader] Export failed: " .. tostring(err)) end
        return
    end

    if sub == "lookups" or sub == "lookup" then
        local scanAll = false
        local scanZones = false
        local debug = false
        for token in string.gmatch(rest or "", "%S+") do
            if token == "all" then
                scanAll = true
            elseif token == "zones" then
                scanZones = true
            elseif token == "debug" then
                debug = true
            end
        end

        if scanZones then
            SmartTrader.ExportActions.StartLookupExportZoneCrawl(debug)
            return
        end

        -- Convenience: if the user runs the zone-scoped command while on the world/cosmic map,
        -- it almost always means they wanted the full crawl.
        if not scanAll then
            local mapType = GetMapType and GetMapType() or nil
            if mapType == MAPTYPE_WORLD or mapType == MAPTYPE_COSMIC then
                SmartTrader.ExportActions.StartLookupExportZoneCrawl(debug)
                return
            end
        end

        -- Zone-scoped: do the robust mapId-based scan for the currently visible zone.
        -- This performs the preliminary "find child maps whose parent is this zone" step, then exports kiosks/outlaws + wayshrines.
        if not scanAll then
            local _zoneIndex, zoneId = GetCurrentMapZoneIdsForScope()
            if not zoneId then
                CL:Log(
                    "[SmartTrader] Could not determine current map zone context. Open a zone/city map first, or use: /st export lookups all")
                return
            end
            SmartTrader.ExportActions.StartLookupExportZoneCrawl(debug, zoneId)
            return
        end

        local buf, count, err, info = SmartTrader.ExportActions.BuildLookupExport(scanAll, debug)
        if err then
            CL:Log(err)
            return
        end
        if debug and info then
            local a = info.anchor or {}
            local m = info.maps or {}
            local c = info.counts or {}
            CL:Log(string.format(
                "[SmartTrader] lookups debug: anchor mapId=%s mapType=%s zoneIndex=%s zoneId=%s parentZoneId=%s name=%s",
                tostring(a.mapId), tostring(a.mapType), tostring(a.zoneIndex), tostring(a.zoneId),
                tostring(a.parentZoneId),
                tostring(a.mapName)))
            CL:Log(string.format(
                "[SmartTrader] lookups debug: scanned=%s inScope=%s exportedMaps=%s skippedDup=%s noLocations=%s scopeAll=%s",
                tostring(m.scanned), tostring(m.inScope), tostring(m.exported), tostring(m.skippedDuplicate),
                tostring(m.noLocations), tostring(a.scopeAll)))
            CL:Log(string.format(
                "[SmartTrader] lookups debug: kioskPins=%s outlawRefuges=%s exportedLocs=%s",
                tostring(c.kioskPins), tostring(c.outlawRefuges), tostring(c.exportedLocs)))
        end
        if count == 0 then
            CL:Log("[SmartTrader] No kiosk/outlaw locations were found while scanning maps.")
            return
        end
        local ok, err = SubmitBuffer(buf)
        if not ok then CL:Log("[SmartTrader] Export failed: " .. tostring(err)) end
        return
    end

    if sub == "all" or sub == "full" or sub == "snapshot" then
        local buf = SmartTrader.ExportActions.BuildFullExport()
        local ok, err = SubmitBuffer(buf)
        if not ok then CL:Log("[SmartTrader] Export failed: " .. tostring(err)) end
        return
    end

    CL:Log("[SmartTrader] Unknown: " .. sub .. ". Use /st export for help")
end
