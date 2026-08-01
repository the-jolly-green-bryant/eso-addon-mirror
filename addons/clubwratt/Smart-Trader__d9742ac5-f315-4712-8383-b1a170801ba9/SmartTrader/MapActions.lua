-- SmartTrader Map Actions
-- Gamepad world map tooltip enhancements:
-- - Replace Guild Trader location lines with guild name + member count (colored)
-- - Append a Guild Traders section to wayshrine tooltips (world/zone/city) by correlating nodeIndex -> zone/city

local SmartTrader = SmartTrader or {}
SmartTrader.MapActions = {}

local CL = SmartTrader.GetLogger()

local MAX_CITY_TRADERS_TO_LOG = 10
local MAX_HOVER_LOG_BYTES = 1024 * 1024
local HOVER_LOG_PREFIX = "[SmartTrader:HoverLog]"

---@type fun(nodeIndex: number|nil): table|nil
local ResolveWayshrineCityDebug

-- -----------------------------------------------------------------------------
-- Hover Logging System
-- -----------------------------------------------------------------------------

---@return boolean
local function IsHoverLogEnabled()
    return SmartTrader and SmartTrader.state and SmartTrader.state.mapState and
        SmartTrader.state.mapState.hoverLogEnabled == true
end

---@param enabled boolean
local function SetHoverLogEnabled(enabled)
    if not SmartTrader or not SmartTrader.state then
        return
    end
    SmartTrader.state.mapState = SmartTrader.state.mapState or {}
    if enabled then
        SmartTrader.state.mapState.hoverLogEnabled = true
        SmartTrader.state.mapState.hoverLogSessionId = (SmartTrader.state.mapState.hoverLogSessionId or 0) + 1
        SmartTrader.state.mapState.hoverLogSeenKeys = {}
        SmartTrader.state.mapState.hoverLogLines = {}
        SmartTrader.state.mapState.hoverLogKeys = {}
        SmartTrader.state.mapState.hoverLogBytes = 0
    else
        SmartTrader.state.mapState.hoverLogEnabled = false
    end
end

---@return string[]
local function GetHoverLogLines()
    return SmartTrader and SmartTrader.state and SmartTrader.state.mapState and
        SmartTrader.state.mapState.hoverLogLines or {}
end

---@return number
local function GetHoverLogCount()
    local lines = GetHoverLogLines()
    return #lines
end

---@param key string
---@return boolean alreadySeen
local function MarkHoverLogKeySeen(key)
    if not SmartTrader or not SmartTrader.state or not SmartTrader.state.mapState then
        return true
    end
    local seenKeys = SmartTrader.state.mapState.hoverLogSeenKeys
    if not seenKeys then
        return true
    end
    if seenKeys[key] then
        return true
    end
    seenKeys[key] = true
    return false
end

---@param key string
---@param line string
local function AppendHoverLogLine(key, line)
    if not SmartTrader or not SmartTrader.state or not SmartTrader.state.mapState then
        return
    end

    local mapState = SmartTrader.state.mapState
    local lines = mapState.hoverLogLines
    if not lines then
        lines = {}
        mapState.hoverLogLines = lines
    end

    local keys = mapState.hoverLogKeys
    if not keys then
        keys = {}
        mapState.hoverLogKeys = keys
    end

    local s = tostring(line or "")
    if s == "" then
        s = "[Empty String]"
    end

    -- Keep the hover log bounded (~1MB) to avoid unbounded growth if left enabled.
    local maxBytes = MAX_HOVER_LOG_BYTES
    local maxLineLen = maxBytes - 1
    if #s > maxLineLen then
        s = s:sub(1, maxLineLen)
    end

    lines[#lines + 1] = s
    keys[#keys + 1] = tostring(key or "")

    local bytes = tonumber(mapState.hoverLogBytes) or 0
    bytes = bytes + #s + 1 -- +1 for newline (payload concatenates with "\n")

    if bytes > maxBytes then
        -- Drop oldest lines until within the cap. Since this is debug-only, we do a single compaction pass.
        local dropCount = 0
        local newBytes = bytes
        local total = #lines
        while newBytes > maxBytes and dropCount < total do
            dropCount = dropCount + 1
            newBytes = newBytes - (#tostring(lines[dropCount] or "") + 1)
        end

        if dropCount >= total then
            mapState.hoverLogSeenKeys = {}
            mapState.hoverLogLines = {}
            mapState.hoverLogKeys = {}
            mapState.hoverLogBytes = 0
            return
        end

        local seenKeys = mapState.hoverLogSeenKeys
        if seenKeys then
            for i = 1, dropCount do
                local droppedKey = keys[i]
                if droppedKey and droppedKey ~= "" then
                    seenKeys[droppedKey] = nil
                end
            end
        end

        local newLines = {}
        local newKeys = {}
        local j = 0
        for i = dropCount + 1, total do
            j = j + 1
            newLines[j] = lines[i]
            newKeys[j] = keys[i]
        end
        mapState.hoverLogLines = newLines
        mapState.hoverLogKeys = newKeys
        mapState.hoverLogBytes = newBytes
        return
    end

    mapState.hoverLogBytes = bytes
end

---@param tbl table
---@return string
local function TableToJsonLine(tbl)
    -- Minimal JSON serializer for flat tables (no nested tables, no escaping edge cases)
    local parts = {}
    for k, v in pairs(tbl) do
        local key = tostring(k)
        local val
        if type(v) == "string" then
            -- Escape quotes and backslashes
            val = '"' .. v:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
        elseif type(v) == "number" or type(v) == "boolean" then
            val = tostring(v)
        elseif v == nil then
            val = "null"
        else
            val = '"' .. tostring(v) .. '"'
        end
        parts[#parts + 1] = '"' .. key .. '":' .. val
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

---@param pin any
---@param mapId number|nil
---@return string|nil dedupeKey, table|nil logData
local function BuildPinLogData(pin, mapId)
    if not pin then
        return nil, nil
    end

    local pinType = pin.GetPinType and pin:GetPinType() or nil
    ---@type any
    local mapPinClass = rawget(_G, "ZO_MapPin")
    local pinData = mapPinClass and mapPinClass["PIN_DATA"] or nil
    local hasGetStaticPinTexture = mapPinClass and mapPinClass["GetStaticPinTexture"] or nil
    local pinTypeString = pinType and hasGetStaticPinTexture and pinData and pinData[pinType] and
        pinData[pinType].texture or nil

    local x, y = nil, nil
    if pin.GetNormalizedPosition then
        x, y = pin:GetNormalizedPosition()
    end

    local nodeIndex = pin.GetFastTravelNodeIndex and pin:GetFastTravelNodeIndex() or nil
    local locationIndex = pin.GetLocationIndex and pin:GetLocationIndex() or nil
    local poiZoneIndex, poiIndex = nil, nil
    if pin.GetPOIZoneIndex then
        poiZoneIndex = pin:GetPOIZoneIndex()
    end
    if pin.GetPOIIndex then
        poiIndex = pin:GetPOIIndex()
    end

    -- Build a stable dedupe key
    local dedupeKey
    if nodeIndex then
        dedupeKey = string.format("node:%d:%s", nodeIndex, tostring(mapId or ""))
    elseif locationIndex then
        dedupeKey = string.format("loc:%d:%s", locationIndex, tostring(mapId or ""))
    elseif poiZoneIndex and poiIndex then
        dedupeKey = string.format("poi:%d:%d:%s", poiZoneIndex, poiIndex, tostring(mapId or ""))
    elseif pinType and x and y then
        dedupeKey = string.format("pos:%d:%.4f:%.4f:%s", pinType, x, y, tostring(mapId or ""))
    else
        return nil, nil
    end

    -- Gather pin-specific data
    local data = {
        mapId = mapId,
        pinType = pinType,
        x = x and string.format("%.4f", x) or nil,
        y = y and string.format("%.4f", y) or nil,
    }

    -- Wayshrine data
    if nodeIndex then
        data.nodeIndex = nodeIndex
        if GetFastTravelNodeInfo then
            local known, name = GetFastTravelNodeInfo(nodeIndex)
            data.nodeName = name
            data.nodeKnown = known
        end
        if GetFastTravelNodePOIIndicies then
            local nzi, npi = GetFastTravelNodePOIIndicies(nodeIndex)
            data.nodeZoneIndex = nzi
            data.nodePoiIndex = npi
        end
    end

    -- Map location data (traders, etc.)
    if locationIndex then
        data.locationIndex = locationIndex
        if GetMapLocationTooltipHeader then
            data.locationHeader = GetMapLocationTooltipHeader(locationIndex)
        end
        if GetNumMapLocationTooltipLines then
            local numLines = GetNumMapLocationTooltipLines(locationIndex) or 0
            data.locationLineCount = numLines
            -- Capture first few lines for context
            local lineData = {}
            for i = 1, math.min(numLines, 5) do
                if GetMapLocationTooltipLineInfo then
                    local icon, name, groupingId, categoryName = GetMapLocationTooltipLineInfo(locationIndex, i)
                    lineData[#lineData + 1] = string.format("%s|%s|%s", tostring(name or ""),
                        tostring(categoryName or ""), tostring(groupingId or ""))
                end
            end
            if #lineData > 0 then
                data.locationLines = table.concat(lineData, ";")
            end
        end
    end

    -- POI data
    if poiZoneIndex and poiIndex then
        data.poiZoneIndex = poiZoneIndex
        data.poiIndex = poiIndex
        if GetPOIInfo then
            local poiName = select(1, GetPOIInfo(poiZoneIndex, poiIndex))
            data.poiName = poiName
        end
    end

    return dedupeKey, data
end

---@param pin any
local function LogHoveredPin(pin)
    if not IsHoverLogEnabled() then
        return
    end
    if not pin then
        return
    end

    local mapId = GetCurrentMapId and GetCurrentMapId() or nil
    local dedupeKey, logData = BuildPinLogData(pin, mapId)
    if not dedupeKey or not logData then
        return
    end

    -- Dedupe: skip if already seen this session
    if MarkHoverLogKeySeen(dedupeKey) then
        return
    end

    -- Add map context
    logData.mapName = GetMapName and GetMapName() or nil
    logData.mapType = GetMapType and GetMapType() or nil
    logData.timestamp = GetTimeStamp and GetTimeStamp() or nil

    -- If this is a fast travel node, attach SmartTrader's own wayshrine->city resolution debug.
    -- This helps diagnose cases where zone-map wayshrines aren't showing expected city/outlaw trader lists.
    if ResolveWayshrineCityDebug and type(logData.nodeIndex) == "number" then
        local extra = ResolveWayshrineCityDebug(logData.nodeIndex)
        if extra then
            for k, v in pairs(extra) do
                -- Avoid clobbering core capture fields; we prefix debug keys with st*
                if logData[k] == nil then
                    logData[k] = v
                end
            end
        end
    end

    local jsonLine = TableToJsonLine(logData)
    AppendHoverLogLine(dedupeKey, jsonLine)

    CL:Log(string.format("%s [%d] %s", HOVER_LOG_PREFIX, GetHoverLogCount(), dedupeKey))
end

local function IsWorldOrZoneMap()
    if not GetMapType then
        return false
    end
    local mapType = GetMapType()
    return mapType == MAPTYPE_WORLD or mapType == MAPTYPE_ZONE
end

-- Forward declarations (some helper functions are referenced before they are defined in this file).
---@type fun(text: any): string|nil
local NormalizeWhitespace
---@type fun(text: any): string
local SafeUpper
---@type fun(zoneIndex: number|nil): number|nil, number|nil
local GetZoneIdAndParentZoneIdByZoneIndex
---@type fun(locationKey: string|nil): number|nil
local GetZoneIndexForWayshrineBaseCityKey

-- -----------------------------------------------------------------------------
-- NOTE: Previous versions built a wayshrine tooltip cache by traversing maps in the background.
-- That approach caused minimap flicker, so it has been removed. Wayshrine correlation now uses
-- direct nodeIndex -> zone/city resolution during tooltip hover.
-- -----------------------------------------------------------------------------

NormalizeWhitespace = function(text)
    if not text or text == "" then
        return nil
    end
    text = tostring(text)
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    if text == "" then
        return nil
    end
    return text
end

SafeUpper = function(text)
    if not text then
        return ""
    end
    return string.upper(tostring(text))
end

local function IsGuildTraderCategory(categoryName)
    local upperCategory = SafeUpper(categoryName)
    return string.find(upperCategory, "GUILD TRADER", 1, true) ~= nil
        or string.find(upperCategory, "OUTLAW TRADER", 1, true) ~= nil
end

---@param rawCity string|nil
---@return string|nil
local function NormalizeCityKey(rawCity)
    local city = NormalizeWhitespace(rawCity)
    if not city then
        return nil
    end

    -- Many ESO API strings include grammar tokens like "^F". Use zo_strformat to strip them so our lookups
    -- can match user-facing strings like "Anvil" / "Mournhold".
    if zo_strformat then
        city = zo_strformat("<<1>>", city)
    end

    city = NormalizeWhitespace(city)
    if not city then
        return nil
    end

    return SafeUpper(city)
end

-- Lazily-built zone name lookup so we can correlate trader locations to zone indices without
-- relying on wayshrine display-name string heuristics.
---@type table<string, number>|nil
local zoneNameKeyToZoneIndex = nil

-- Lazily-built POI name lookup for cities that are POIs (e.g. "Anvil") and not zones.
---@type table<string, table<number, boolean>>|nil
local poiNameKeyToZoneIndexSet = nil

local function EnsureZoneNameKeyToZoneIndex()
    if zoneNameKeyToZoneIndex then
        return
    end

    zoneNameKeyToZoneIndex = {}
    if not GetNumZones or not GetZoneNameByIndex then
        return
    end

    local numZones = GetNumZones() or 0
    for zoneIndex = 1, numZones do
        local zoneName = GetZoneNameByIndex(zoneIndex)
        local key = NormalizeCityKey(zoneName)
        if key then
            zoneNameKeyToZoneIndex[key] = zoneIndex
        end
    end
end

---@param locationKey string|nil
---@return number|nil
local function GetZoneIndexForLocationKey(locationKey)
    if not locationKey then
        return nil
    end
    EnsureZoneNameKeyToZoneIndex()
    return zoneNameKeyToZoneIndex and zoneNameKeyToZoneIndex[locationKey] or nil
end

local function EnsurePOINameKeyToZoneIndexSet()
    if poiNameKeyToZoneIndexSet then
        return
    end

    poiNameKeyToZoneIndexSet = {}

    if not GetNumZones or not GetNumPOIs or not GetPOIInfo then
        return
    end

    local numZones = GetNumZones() or 0
    for zoneIndex = 1, numZones do
        local numPOIs = GetNumPOIs(zoneIndex) or 0
        for poiIndex = 1, numPOIs do
            local poiName = select(1, GetPOIInfo(zoneIndex, poiIndex))
            local key = NormalizeCityKey(poiName)
            if key then
                local set = poiNameKeyToZoneIndexSet[key]
                if not set then
                    set = {}
                    poiNameKeyToZoneIndexSet[key] = set
                end
                set[zoneIndex] = true
            end
        end
    end
end

---@param key string|nil
---@param zoneIndex number|nil
---@return boolean
local function DoesPOIKeyBelongToZoneIndex(key, zoneIndex)
    if not key or not zoneIndex then
        return false
    end
    EnsurePOINameKeyToZoneIndexSet()
    local set = poiNameKeyToZoneIndexSet and poiNameKeyToZoneIndexSet[key] or nil
    return set ~= nil and set[zoneIndex] == true
end

---@param locationKey string|nil
---@return number|nil
local function GetZoneIndexForLocationOrPOIKey(locationKey)
    -- Prefer POI resolution first. Many capital/city names are both:
    -- - a subzone zone name (which can have confusing/undesired "parent zone" IDs), and
    -- - a POI inside the overland zone we actually want to correlate against.
    -- Example: "MOURNHOLD" should resolve to the overland zone (Deshaan) for matching purposes.
    EnsurePOINameKeyToZoneIndexSet()
    local set = poiNameKeyToZoneIndexSet and poiNameKeyToZoneIndexSet[locationKey] or nil

    -- Some overland POIs are named like "<City> City" even though guild locations are just "<City>".
    -- Example: Wayrest is often represented as "Wayrest City" in the Stormhaven POI list.
    if not set and locationKey and poiNameKeyToZoneIndexSet then
        local citySuffix = " CITY"
        if #locationKey < #citySuffix or locationKey:sub(#locationKey - #citySuffix + 1) ~= citySuffix then
            set = poiNameKeyToZoneIndexSet[locationKey .. citySuffix]
        end
    end
    if set then
        -- Prefer unique POI name mappings, but handle cases where the POI appears in both:
        -- - the overland zone (desired), and
        -- - the city/subzone map (undesired; can have "parent zone" = Stirk).
        local found = nil
        for zi in pairs(set) do
            if found then
                found = nil
                break
            end
            found = zi
        end
        if found then
            return found
        end

        -- Non-unique: prefer a unique "overland-like" candidate where zoneId == parentZoneId.
        local overland = nil
        for zi in pairs(set) do
            local zoneId, parentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(zi)
            if zoneId and parentZoneId and zoneId == parentZoneId then
                if overland then
                    overland = nil
                    break
                end
                overland = zi
            end
        end
        if overland then
            return overland
        end
    end

    -- Fallback: use fast travel node metadata to map "City" -> overland zone index.
    -- This handles cases where POI naming doesn't match guild location naming (e.g. "Wayrest City" vs "Wayrest").
    if GetZoneIndexForWayshrineBaseCityKey then
        local viaWayshrine = GetZoneIndexForWayshrineBaseCityKey(locationKey)
        if viaWayshrine then
            return viaWayshrine
        end
    end

    return GetZoneIndexForLocationKey(locationKey)
end

---@param zoneIndex number|nil
---@return number|nil
local function GetZoneIdByZoneIndex(zoneIndex)
    if not zoneIndex or not GetZoneId then
        return nil
    end
    local zoneId = GetZoneId(zoneIndex)
    if type(zoneId) ~= "number" or zoneId == 0 then
        return nil
    end
    return zoneId
end

---@param zoneId number|nil
---@return number|nil parentZoneId
local function GetParentZoneIdByZoneId(zoneId)
    if not zoneId or not GetParentZoneId then
        return nil
    end
    local parentZoneId = GetParentZoneId(zoneId)
    if type(parentZoneId) ~= "number" or parentZoneId == 0 then
        return zoneId
    end
    return parentZoneId
end

---@param zoneIndex number|nil
---@return number|nil zoneId
---@return number|nil parentZoneId
GetZoneIdAndParentZoneIdByZoneIndex = function(zoneIndex)
    local zoneId = GetZoneIdByZoneIndex(zoneIndex)

    -- Prefer ESOUI's exploration utils parent resolution when available.
    -- This matches how the world map derives parent zones for fast travel nodes and avoids
    -- odd parent mappings for some capital/city zones (e.g. Mournhold resolving under Stirk).
    local parentZoneId = nil
    if zoneIndex and ZO_ExplorationUtils_GetParentZoneIdByZoneIndex then
        local derived = ZO_ExplorationUtils_GetParentZoneIdByZoneIndex(zoneIndex)
        if type(derived) == "number" and derived ~= 0 then
            parentZoneId = derived
        end
    end

    -- Fallback to the API parent lookup via zoneId.
    if not parentZoneId then
        parentZoneId = zoneId and GetParentZoneIdByZoneId(zoneId) or nil
    end

    return zoneId, parentZoneId
end

---@param locationName string|nil
---@return boolean
local function IsOutlawRefugeLocation(locationName)
    local normalized = NormalizeWhitespace(locationName) or ""
    local upper = SafeUpper(normalized)
    return string.find(upper, "OUTLAW", 1, true) ~= nil and string.find(upper, "REFUGE", 1, true) ~= nil
end

---@param rawLocation string|nil
---@return string|nil wholeKey
---@return string|nil firstKey
---@return string|nil lastKey
local function GetLocationKeyVariants(rawLocation)
    local raw = NormalizeWhitespace(rawLocation)
    if not raw then
        return nil, nil, nil
    end

    local wholeKey = NormalizeCityKey(raw)
    local firstKey = nil
    local lastKey = nil

    -- Many kiosk location strings are "City, Zone". Prefer City for city matching and Zone for parent-zone resolution.
    local lastCommaPos = nil
    local searchPos = 1
    while true do
        local found = string.find(raw, ",", searchPos, true)
        if not found then
            break
        end
        lastCommaPos = found
        searchPos = found + 1
    end

    if lastCommaPos then
        local left = NormalizeWhitespace(string.sub(raw, 1, lastCommaPos - 1))
        local right = NormalizeWhitespace(string.sub(raw, lastCommaPos + 1))
        firstKey = NormalizeCityKey(left)
        lastKey = NormalizeCityKey(right)
    end

    return wholeKey, firstKey, lastKey
end

---@param locationName string|nil
---@return string|nil baseCityKey
local function GetOutlawBaseCityKey(locationName)
    local name = NormalizeWhitespace(locationName)
    if not name then
        return nil
    end

    local upper = SafeUpper(name)
    local pos = string.find(upper, " OUTLAWS REFUGE", 1, true)
        or string.find(upper, " OUTLAW REFUGE", 1, true)
        or string.find(upper, " OUTLAW'S REFUGE", 1, true)
        or string.find(upper, " OUTLAWS' REFUGE", 1, true)
    if pos then
        name = string.sub(name, 1, pos - 1)
    end

    return NormalizeCityKey(name)
end

-- -----------------------------------------------------------------------------
-- LookupTables-driven location resolution
-- -----------------------------------------------------------------------------

---@type table<integer, string>|nil
local mapIdToMapNameKey = nil

---@type table<integer, string>|nil
local outlawRefugeMapIdToBaseCityKey = nil

---@type table<string, boolean>|nil
local kioskMapNameKeySet = nil

---@type table<number, table<string, boolean>>|nil
local kioskMapNameKeysByParentZoneId = nil

local function EnsureLookupMapIndices()
    if mapIdToMapNameKey and outlawRefugeMapIdToBaseCityKey and kioskMapNameKeySet and kioskMapNameKeysByParentZoneId then
        return
    end

    mapIdToMapNameKey = {}
    outlawRefugeMapIdToBaseCityKey = {}
    kioskMapNameKeySet = {}
    kioskMapNameKeysByParentZoneId = {}

    local tables = SmartTrader and SmartTrader.LookupTables
    local mapById = tables and tables.MapById
    if not mapById then
        return
    end

    for mapId, row in pairs(mapById) do
        local mapName = row and row.mapName or nil

        local key = NormalizeCityKey(mapName)
        if key then
            mapIdToMapNameKey[mapId] = key
        end

        -- Identify Outlaws Refuge interior maps and capture their base city key.
        if IsOutlawRefugeLocation(mapName) then
            local baseKey = GetOutlawBaseCityKey(mapName)
            if baseKey then
                outlawRefugeMapIdToBaseCityKey[mapId] = baseKey
            end
        end
    end

    -- Record which map-name keys have kiosk pins so we can identify "city-ish" POIs/wayshrines
    -- without relying purely on display-name heuristics.
    local kioskPinByKey = tables and tables.KioskPinByKey
    if kioskPinByKey then
        for _, pin in pairs(kioskPinByKey) do
            local mapId = pin and pin.mapId or nil
            local key = (type(mapId) == "number") and mapIdToMapNameKey[mapId] or nil
            if key then
                kioskMapNameKeySet[key] = true

                local parentZoneId = pin and pin.parentZoneId or nil
                if type(parentZoneId) == "number" and parentZoneId ~= 0 then
                    local set = kioskMapNameKeysByParentZoneId[parentZoneId]
                    if not set then
                        set = {}
                        kioskMapNameKeysByParentZoneId[parentZoneId] = set
                    end
                    set[key] = true
                end
            end
        end
    end
end

---@param parentZoneId number|nil
---@return string|nil mapNameKey
local function GetUniqueKioskMapNameKeyForParentZoneId(parentZoneId)
    if type(parentZoneId) ~= "number" or parentZoneId == 0 then
        return nil
    end

    EnsureLookupMapIndices()
    local set = kioskMapNameKeysByParentZoneId and kioskMapNameKeysByParentZoneId[parentZoneId] or nil
    if not set then
        return nil
    end

    local found = nil
    for key in pairs(set) do
        if found then
            return nil
        end
        found = key
    end
    return found
end

---@type table<integer, string[]>|nil
local kioskTraderNamesByMapId = nil

---@param pinKey string|nil
---@return number|nil mapId
local function MapIdFromPinKey(pinKey)
    if type(pinKey) ~= "string" then
        return nil
    end
    local colonPos = string.find(pinKey, ":", 1, true)
    if not colonPos then
        return nil
    end
    return tonumber(string.sub(pinKey, 1, colonPos - 1))
end

local function EnsureKioskTraderNamesByMapId()
    if kioskTraderNamesByMapId then
        return
    end

    kioskTraderNamesByMapId = {}

    local tables = SmartTrader and SmartTrader.LookupTables
    local kioskTraderByKey = tables and tables.KioskTraderByKey
    if not kioskTraderByKey then
        return
    end

    for _, row in pairs(kioskTraderByKey) do
        local mapId = MapIdFromPinKey(row and row.pinKey or nil)
        local traderName = NormalizeWhitespace(row and row.traderName or nil)
        if type(mapId) == "number" and traderName then
            local list = kioskTraderNamesByMapId[mapId]
            if not list then
                list = {}
                kioskTraderNamesByMapId[mapId] = list
            end
            list[#list + 1] = traderName
        end
    end

    -- Dedupe + stable sort
    for mapId, list in pairs(kioskTraderNamesByMapId) do
        local seen = {}
        local uniq = {}
        for i = 1, #list do
            local name = NormalizeWhitespace(list[i]) or list[i]
            if name and name ~= "" and not seen[name] then
                seen[name] = true
                uniq[#uniq + 1] = name
            end
        end
        table.sort(uniq, function(a, b)
            return tostring(a) < tostring(b)
        end)
        kioskTraderNamesByMapId[mapId] = uniq
    end
end

---@param key string|nil
---@return string|nil
local function CanonicalizeKioskCityKey(key)
    if not key then
        return nil
    end
    if not kioskMapNameKeySet then
        return key
    end
    if kioskMapNameKeySet[key] then
        return key
    end

    -- Common variant: POIs are named "<City> City" while city map names are "<City>".
    local citySuffix = " CITY"
    local upper = SafeUpper(key)
    if #upper > #citySuffix and upper:sub(#upper - #citySuffix + 1) == citySuffix then
        local trimmed = NormalizeWhitespace(tostring(key):sub(1, #tostring(key) - #citySuffix))
        local trimmedKey = NormalizeCityKey(trimmed)
        if trimmedKey and kioskMapNameKeySet[trimmedKey] then
            return trimmedKey
        end
    else
        local withSuffix = key .. citySuffix
        if kioskMapNameKeySet[withSuffix] then
            return withSuffix
        end
    end

    return key
end

---@class LookupResolvedLocation
---@field locationKey string|nil
---@field zoneId number|nil
---@field parentZoneId number|nil
---@field isOutlaw boolean
---@field outlawBaseCityKey string|nil

---@param data CachedGuildData|nil
---@return LookupResolvedLocation|nil
local function ResolveCachedLocationFromLookup(data)
    local Lookup = SmartTrader and SmartTrader.LookupActions
    if not Lookup or not Lookup.ResolveKioskByTraderName then
        return nil
    end
    local traderName = data and data.traderName
    if not traderName or traderName == "" then
        return nil
    end

    local _, pin = Lookup.ResolveKioskByTraderName(traderName)
    if not pin then
        return nil
    end

    EnsureLookupMapIndices()

    local mapId = pin.mapId
    local baseCityKey = (outlawRefugeMapIdToBaseCityKey and type(mapId) == "number") and
        outlawRefugeMapIdToBaseCityKey[mapId] or nil

    local isOutlaw = baseCityKey ~= nil
    local locationKey = nil
    if isOutlaw then
        locationKey = baseCityKey
    else
        locationKey = (mapIdToMapNameKey and type(mapId) == "number") and mapIdToMapNameKey[mapId] or nil
    end

    return {
        locationKey = locationKey,
        zoneId = pin.zoneId,
        parentZoneId = pin.parentZoneId,
        isOutlaw = isOutlaw,
        outlawBaseCityKey = baseCityKey,
    }
end

-- Lazily-built Outlaws Refuge lookup so we can correlate "city-only" outlaw traders.
-- Some outlaw trader listings omit the ", Zone" suffix and are only labeled with the city name.
---@type table<string, table<number, boolean>>|nil
local outlawRefugeBaseCityKeyToZoneIndexSet = nil

local function EnsureOutlawRefugeBaseCityKeyToZoneIndexSet()
    if outlawRefugeBaseCityKeyToZoneIndexSet then
        return
    end

    outlawRefugeBaseCityKeyToZoneIndexSet = {}

    -- Reuse the general POI name scan so we don't traverse all POIs twice.
    EnsurePOINameKeyToZoneIndexSet()
    if not poiNameKeyToZoneIndexSet then
        return
    end

    for poiKey, set in pairs(poiNameKeyToZoneIndexSet) do
        local baseKey = GetOutlawBaseCityKey(poiKey)
        if baseKey then
            local dest = outlawRefugeBaseCityKeyToZoneIndexSet[baseKey]
            if not dest then
                dest = {}
                outlawRefugeBaseCityKeyToZoneIndexSet[baseKey] = dest
            end
            for zoneIndex in pairs(set) do
                dest[zoneIndex] = true
            end
        end
    end
end

---@param baseCityKey string|nil
---@return number|nil
local function GetOutlawRefugeZoneIndexForBaseCityKey(baseCityKey)
    if not baseCityKey then
        return nil
    end
    EnsureOutlawRefugeBaseCityKeyToZoneIndexSet()
    local set = outlawRefugeBaseCityKeyToZoneIndexSet and outlawRefugeBaseCityKeyToZoneIndexSet[baseCityKey] or nil
    if not set then
        return nil
    end

    -- Only accept unique mappings to avoid generic names across zones.
    local found = nil
    for zi in pairs(set) do
        if found then
            return nil
        end
        found = zi
    end
    return found
end

---@class CityLocationFormatIndex
---@field hasCommaVariant table<string, boolean>
---@field hasCityOnlyVariant table<string, boolean>

---@param guildDataById table<any, CachedGuildData>|nil
---@return CityLocationFormatIndex
function SmartTrader.MapActions.BuildCityLocationFormatIndex(guildDataById)
    ---@type CityLocationFormatIndex
    local index = {
        hasCommaVariant = {},
        hasCityOnlyVariant = {},
    }

    if not guildDataById then
        return index
    end

    for _, data in pairs(guildDataById) do
        local wholeKey, firstKey, lastKey = GetLocationKeyVariants(data and data.city)
        if firstKey and lastKey then
            index.hasCommaVariant[firstKey] = true
        end
        if wholeKey and not lastKey then
            index.hasCityOnlyVariant[wholeKey] = true
        end
    end

    return index
end

---@param data CachedGuildData|nil
---@param cityFormatIndex CityLocationFormatIndex|nil
---@return string|nil locationKey
---@return number|nil locationZoneIndex
---@return number|nil locationZoneId
---@return number|nil locationParentZoneId
---@return boolean isOutlawRefuge
---@return string|nil outlawBaseCityKey
local function ResolveCachedLocation(data, cityFormatIndex)
    local rawLocation = data and data.city
    local wholeKey, firstKey, lastKey = GetLocationKeyVariants(rawLocation)
    local locationKey = firstKey or wholeKey
    if not locationKey then
        return nil, nil, nil, nil, false, nil
    end

    local zoneIndex = GetZoneIndexForLocationOrPOIKey(lastKey) or GetZoneIndexForLocationOrPOIKey(wholeKey) or
        GetZoneIndexForLocationOrPOIKey(firstKey)
    local zoneId, parentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(zoneIndex)

    local isOutlaw = IsOutlawRefugeLocation(rawLocation)
    local baseCityKey = isOutlaw and GetOutlawBaseCityKey(rawLocation) or nil

    -- Delineate "city-only" outlaw traders ONLY when both formats exist for that city:
    -- - Regular traders: "City, Zone"
    -- - Outlaw traders (sometimes): "City"
    -- If a city ONLY appears as "City" in the cache, we do NOT assume it's an outlaw listing.
    if not isOutlaw and cityFormatIndex and wholeKey and not lastKey then
        if cityFormatIndex.hasCityOnlyVariant[wholeKey] and cityFormatIndex.hasCommaVariant[wholeKey] then
            isOutlaw = true
            baseCityKey = wholeKey
        end
    end

    -- Outlaw Refuge locations aren't zone names, so we may fail to resolve them via GetZoneNameByIndex.
    -- In that case, resolve the *base city* zone instead so outlaw traders can still be correlated.
    if isOutlaw and (not zoneId or not parentZoneId) and baseCityKey then
        local baseZoneIndex = GetZoneIndexForLocationOrPOIKey(baseCityKey)
        local baseZoneId, baseParentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(baseZoneIndex)
        if baseZoneId and baseParentZoneId then
            zoneIndex = baseZoneIndex
            zoneId = baseZoneId
            parentZoneId = baseParentZoneId
        end
    end

    return locationKey, zoneIndex, zoneId, parentZoneId, isOutlaw, baseCityKey
end

---@param zoneIndex number|nil
---@param poiIndex number|nil
---@return string|nil poiName
local function GetPOIName(zoneIndex, poiIndex)
    if not zoneIndex or not poiIndex or not GetPOIInfo then
        return nil
    end
    local name = select(1, GetPOIInfo(zoneIndex, poiIndex))
    return NormalizeWhitespace(name)
end

---@param value number
---@return number
local function Clamp01(value)
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end
    return value
end

---@param clickX number
---@param clickY number
---@return luaindex|nil resultingMapIndex
local function FindResultingMapIndexForClick(clickX, clickY)
    if not WouldProcessMapClick then
        return nil
    end

    local would, idx = WouldProcessMapClick(clickX, clickY)
    if would and idx then
        return idx
    end

    -- Some maps require slightly different click targets; try a few points around it.
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

---@param poiZoneIndex number|nil
---@param poiIndex number|nil
---@return string|nil cityKey
local function ResolveKioskCityKeyFromPOIMapClick(poiZoneIndex, poiIndex)
    if type(poiZoneIndex) ~= "number" or type(poiIndex) ~= "number" then
        return nil
    end
    if not GetPOIMapInfo or not GetMapIdByIndex then
        return nil
    end

    EnsureLookupMapIndices()
    if not kioskMapNameKeySet or not mapIdToMapNameKey then
        return nil
    end

    local x, y, _, _, isShownInCurrentMap = GetPOIMapInfo(poiZoneIndex, poiIndex)
    if not isShownInCurrentMap then
        return nil
    end
    if type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end

    local resultingMapIndex = FindResultingMapIndexForClick(x, y)
    if not resultingMapIndex then
        return nil
    end

    local mapId = GetMapIdByIndex(resultingMapIndex)
    if type(mapId) ~= "number" or mapId == 0 then
        return nil
    end

    local key = mapIdToMapNameKey[mapId]
    if key and kioskMapNameKeySet[key] then
        return key
    end

    return nil
end

---@param poiName string|nil
---@return string|nil cityKey
---@return number|nil cityZoneIndex
---@return number|nil cityZoneId
local function ResolveCityZoneFromPOIName(poiName)
    local raw = NormalizeWhitespace(poiName)
    if not raw then
        return nil, nil, nil
    end

    local function TryKey(candidate)
        local key = NormalizeCityKey(candidate)
        local zoneIndex = key and GetZoneIndexForLocationOrPOIKey(key) or nil
        local zoneId = zoneIndex and GetZoneIdByZoneIndex(zoneIndex) or nil
        if key and zoneIndex and zoneId then
            return key, zoneIndex, zoneId
        end
        return nil, nil, nil
    end

    -- Prefer exact POI name.
    local key, zoneIndex, zoneId = TryKey(raw)
    if key then
        return key, zoneIndex, zoneId
    end

    -- Some POI names include a trailing "City" while the subzone is just the city name.
    local upper = SafeUpper(raw)
    local suffix = " CITY"
    if #upper > #suffix and upper:sub(#upper - #suffix + 1) == suffix then
        local trimmed = NormalizeWhitespace(raw:sub(1, #raw - #suffix))
        key, zoneIndex, zoneId = TryKey(trimmed)
        if key then
            return key, zoneIndex, zoneId
        end
    end

    return nil, nil, nil
end

---@param wayshrineName string|nil
---@return string|nil cityKey
---@return number|nil cityZoneIndex
---@return number|nil cityZoneId
local function ResolveCityZoneFromWayshrineName(wayshrineName)
    local raw = NormalizeWhitespace(wayshrineName)
    if not raw then
        return nil, nil, nil
    end

    -- Remove trailing "Wayshrine" (and common variants) because the underlying city/subzone name
    -- is what we can resolve to a zone.
    local upper = SafeUpper(raw)
    local suffix = "WAYSHRINE"
    if #upper >= #suffix and upper:sub(#upper - #suffix + 1) == suffix then
        raw = NormalizeWhitespace(raw:sub(1, #raw - #suffix))
    end

    -- If it ends with "City" after stripping, try also without "City"
    local key, zoneIndex, zoneId = ResolveCityZoneFromPOIName(raw)
    if key then
        return key, zoneIndex, zoneId
    end

    return nil, nil, nil
end

---@param name string|nil
---@return string|nil
local function GetWayshrineBaseKey(name)
    local raw = NormalizeWhitespace(name)
    if not raw then
        return nil
    end

    local upper = SafeUpper(raw)
    local suffix = " WAYSHRINE"
    if #upper >= #suffix and upper:sub(#upper - #suffix + 1) == suffix then
        raw = NormalizeWhitespace(raw:sub(1, #raw - #suffix))
    end

    return NormalizeCityKey(raw)
end

-- Lazily-built mapping of "Base City Key" -> zoneIndex via fast travel node metadata.
-- This is used as a fallback when POI naming doesn't align with guild location strings.
---@type table<string, table<number, boolean>>|nil
local wayshrineBaseCityKeyToZoneIndexSet = nil

local function EnsureWayshrineBaseCityKeyToZoneIndexSet()
    if wayshrineBaseCityKeyToZoneIndexSet then
        return
    end

    wayshrineBaseCityKeyToZoneIndexSet = {}

    if not GetNumFastTravelNodes or not GetFastTravelNodeInfo or not GetFastTravelNodePOIIndicies then
        return
    end

    local numNodes = GetNumFastTravelNodes() or 0
    for nodeIndex = 1, numNodes do
        local _known, wayshrineName, _x, _y, _icon, _glow, poiType = GetFastTravelNodeInfo(nodeIndex)
        -- Only index actual wayshrines; houses/dungeons are also fast-travel nodes and must not influence city-key mapping.
        if poiType == POI_TYPE_WAYSHRINE then
            local baseKey = GetWayshrineBaseKey(wayshrineName)
            if baseKey then
                local nodeZoneIndex = select(1, GetFastTravelNodePOIIndicies(nodeIndex))
                if nodeZoneIndex then
                    local set = wayshrineBaseCityKeyToZoneIndexSet[baseKey]
                    if not set then
                        set = {}
                        wayshrineBaseCityKeyToZoneIndexSet[baseKey] = set
                    end
                    set[nodeZoneIndex] = true
                end
            end
        end
    end
end

---@param locationKey string|nil
---@return number|nil zoneIndex
GetZoneIndexForWayshrineBaseCityKey = function(locationKey)
    if not locationKey then
        return nil
    end

    EnsureWayshrineBaseCityKeyToZoneIndexSet()
    local set = wayshrineBaseCityKeyToZoneIndexSet and wayshrineBaseCityKeyToZoneIndexSet[locationKey] or nil
    if not set then
        return nil
    end

    -- Prefer unique.
    local found = nil
    for zi in pairs(set) do
        if found then
            found = nil
            break
        end
        found = zi
    end
    if found then
        return found
    end

    -- Non-unique: prefer unique "overland-like" candidate where zoneId == parentZoneId.
    local overland = nil
    for zi in pairs(set) do
        local zoneId, parentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(zi)
        if zoneId and parentZoneId and zoneId == parentZoneId then
            if overland then
                return nil
            end
            overland = zi
        end
    end

    return overland
end

---@return number
local function GetCachedGuildCount()
    local guildDataById = SmartTrader and SmartTrader.state and SmartTrader.state.savedVars and
        SmartTrader.state.savedVars.guildDataById
    if not guildDataById then
        return 0
    end
    local count = 0
    for _ in pairs(guildDataById) do
        count = count + 1
    end
    return count
end

---@param traderName string|nil
---@return string|nil
local function FormatMapGuildTraderLine(traderName)
    local name = NormalizeWhitespace(traderName)
    if not name then
        return nil
    end

    local state = SmartTrader and SmartTrader.state
    local savedVars = state and state.savedVars
    local guildDataByTraderName = savedVars and savedVars.guildDataByTraderName

    ---@type CachedGuildData|nil
    local data = guildDataByTraderName and guildDataByTraderName[name] or nil

    local GuildUtils = SmartTrader and SmartTrader.GuildUtils
    if GuildUtils and GuildUtils.FormatGuildDisplayText then
        local formatted = GuildUtils.FormatGuildDisplayText(data, name)
        if formatted then
            return formatted
        end
    end

    -- Fallback: if we at least know the guildName, prefer that over the NPC name.
    if data and data.guildName and data.guildName ~= "" then
        return data.guildName
    end

    return name
end

-- -----------------------------------------------------------------------------
-- Lookup table integration (optional; tables may be empty until generated offline)
-- -----------------------------------------------------------------------------

---@param traderName string|nil
---@return string|nil kioskKey
---@return table|nil kiosk
function SmartTrader.MapActions.DebugResolveKioskByTraderName(traderName)
    local Lookup = SmartTrader and SmartTrader.LookupActions
    if not Lookup or not Lookup.ResolveKioskByTraderName then
        return nil, nil
    end
    return Lookup.ResolveKioskByTraderName(traderName)
end

---@param data CachedGuildData|nil
---@return number memberCount
local function GetGuildMemberCount(data)
    if data and type(data.memberCount) == "number" then
        return data.memberCount
    end
    return 0
end

---@param list CachedGuildData[]
local function SortGuildsLargestFirst(list)
    table.sort(list, function(a, b)
        local aMembers = GetGuildMemberCount(a)
        local bMembers = GetGuildMemberCount(b)

        if aMembers ~= bMembers then
            return aMembers > bMembers
        end

        local aName = SafeUpper(a and a.guildName or "")
        local bName = SafeUpper(b and b.guildName or "")
        if aName ~= bName then
            return aName < bName
        end

        local aId = tonumber(a and a.guildId) or 0
        local bId = tonumber(b and b.guildId) or 0
        return aId < bId
    end)
end

local function TryHookMapLocationTooltipGamepad()
    ---@type any
    local tooltip = rawget(_G, "ZO_MapLocationTooltip_Gamepad")
    if not tooltip then
        return false
    end

    if tooltip.__SmartTraderGuildTooltipHooked then
        return true
    end

    if type(tooltip.SetMapLocation) ~= "function" or type(tooltip.LayoutLargeIconStringLine) ~= "function" then
        return false
    end

    tooltip.__SmartTraderGuildTooltipHooked = true

    local originalSetMapLocation = tooltip.SetMapLocation
    local originalLayoutLargeIconStringLine = tooltip.LayoutLargeIconStringLine

    tooltip.LayoutLargeIconStringLine = function(self, section, icon, text, ...)
        local queue = self.__SmartTraderLocationEntryQueue
        local index = self.__SmartTraderLocationEntryQueueIndex
        if queue and index and index <= #queue then
            local entry = queue[index]
            self.__SmartTraderLocationEntryQueueIndex = index + 1

            if entry then
                local display = nil

                -- LookupTables-first: if this hover matches a known kiosk pin, resolve trader lines by (mapId, locIndex, lineIndex)
                -- instead of relying on category text heuristics (which can vary by language/client).
                if self.__SmartTraderCurrentIsKioskPin == true then
                    local Lookup = SmartTrader and SmartTrader.LookupActions
                    if Lookup and Lookup.MakeKioskTraderKey and Lookup.GetKioskTraderByKey then
                        local kioskTraderKey = Lookup.MakeKioskTraderKey(
                            self.__SmartTraderCurrentMapId,
                            self.__SmartTraderCurrentLocationIndex,
                            entry.lineIndex
                        )
                        local traderRow = kioskTraderKey and Lookup.GetKioskTraderByKey(kioskTraderKey) or nil
                        if traderRow then
                            display = FormatMapGuildTraderLine(traderRow.traderName or entry.name)
                        end
                    end
                end

                -- Fallback: previous heuristic based on category string.
                if not display and IsGuildTraderCategory(entry.categoryName) then
                    display = FormatMapGuildTraderLine(entry.name)
                end

                if display then
                    -- Guild names can be long; use the smaller default label style by omitting the
                    -- title-style override that ESOUI sometimes passes for the "Guild Trader" category line.
                    return originalLayoutLargeIconStringLine(self, section, icon, display)
                end
            end
        end

        return originalLayoutLargeIconStringLine(self, section, icon, text, ...)
    end

    tooltip.SetMapLocation = function(self, locationIndex)
        -- Replace the *category* line for guild traders (the "Guild Trader" label), keeping the NPC name line.
        -- We do this by building an ordered queue that matches ESOUI's internal sort order (groupingId then name),
        -- and consuming it from our LayoutLargeIconStringLine hook.
        local queue = {}

        local mapId = GetCurrentMapId and GetCurrentMapId() or nil
        local Lookup = SmartTrader and SmartTrader.LookupActions
        local pinKey = (Lookup and Lookup.MakePinKey) and Lookup.MakePinKey(mapId, locationIndex) or nil
        local isKioskPin = false
        local tables = SmartTrader and SmartTrader.LookupTables
        local kioskPinByKey = tables and tables.KioskPinByKey
        if pinKey and kioskPinByKey and kioskPinByKey[pinKey] then
            isKioskPin = true
        end

        if type(locationIndex) == "number" and GetNumMapLocationTooltipLines and GetMapLocationTooltipLineInfo then
            ---@type table<number, { id: number, entries: table[] }>
            local groupingsById = {}
            ---@type table[]
            local groupingList = {}

            local numLines = GetNumMapLocationTooltipLines(locationIndex) or 0
            for lineIndex = 1, numLines do
                if (not IsMapLocationTooltipLineVisible) or IsMapLocationTooltipLineVisible(locationIndex, lineIndex) then
                    local icon, name, groupingId, categoryName = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)
                    if groupingId == nil then
                        groupingId = 0
                    end

                    local grouping = groupingsById[groupingId]
                    if not grouping then
                        grouping = { id = groupingId, entries = {} }
                        groupingsById[groupingId] = grouping
                        groupingList[#groupingList + 1] = grouping
                    end

                    grouping.entries[#grouping.entries + 1] =
                    {
                        icon = icon,
                        name = name,
                        groupingId = groupingId,
                        categoryName = categoryName,
                        lineIndex = lineIndex,
                    }
                end
            end

            table.sort(groupingList, function(a, b)
                return (a.id or 0) < (b.id or 0)
            end)

            for i = 1, #groupingList do
                local grouping = groupingList[i]
                table.sort(grouping.entries, function(a, b)
                    return tostring(a.name or "") < tostring(b.name or "")
                end)
                for j = 1, #grouping.entries do
                    queue[#queue + 1] = grouping.entries[j]
                end
            end
        end

        self.__SmartTraderLocationEntryQueue = queue
        self.__SmartTraderLocationEntryQueueIndex = 1
        self.__SmartTraderCurrentMapId = mapId
        self.__SmartTraderCurrentLocationIndex = locationIndex
        self.__SmartTraderCurrentPinKey = pinKey
        self.__SmartTraderCurrentIsKioskPin = isKioskPin

        local result = originalSetMapLocation(self, locationIndex)

        -- If this location is an Outlaws Refuge pin, append the matching outlaw traders (similar to wayshrines).
        if self and self.tooltip and type(self.tooltip.AcquireSection) == "function" then
            -- Only augment the gamepad world map right-panel tooltip.
            if IsInGamepadPreferredMode() and SCENE_MANAGER:IsCurrentSceneGamepad() and ZO_WorldMap_IsWorldMapShowing() then
                -- LookupTables-first: identify outlaws refuge pins by stable (mapId, locIndex) key.
                local isOutlawRefuge = false
                local baseCityKey = nil
                local tables = SmartTrader and SmartTrader.LookupTables
                local outlawRefugeByKey = tables and tables.OutlawRefugeByKey
                local outlawRow = (pinKey and outlawRefugeByKey) and outlawRefugeByKey[pinKey] or nil
                if outlawRow then
                    isOutlawRefuge = true
                end

                local headerText = (type(locationIndex) == "number" and GetMapLocationTooltipHeader) and
                    GetMapLocationTooltipHeader(locationIndex) or nil

                -- Fallback: detect Outlaws Refuge via header text.
                if not isOutlawRefuge then
                    isOutlawRefuge = headerText ~= nil and IsOutlawRefugeLocation(headerText)
                end
                baseCityKey = (isOutlawRefuge and headerText ~= nil) and GetOutlawBaseCityKey(headerText) or nil

                -- Fallback: detect Outlaws Refuge via tooltip lines (some headers may be generic).
                if (not isOutlawRefuge) or (isOutlawRefuge and not baseCityKey) then
                    if type(locationIndex) == "number" and GetNumMapLocationTooltipLines and GetMapLocationTooltipLineInfo then
                        local numLines = GetNumMapLocationTooltipLines(locationIndex) or 0
                        for lineIndex = 1, numLines do
                            if (not IsMapLocationTooltipLineVisible) or IsMapLocationTooltipLineVisible(locationIndex, lineIndex) then
                                local _, name, _, categoryName = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)
                                if IsOutlawRefugeLocation(categoryName) or IsOutlawRefugeLocation(name) then
                                    isOutlawRefuge = true
                                    baseCityKey = baseCityKey or GetOutlawBaseCityKey(name) or
                                        GetOutlawBaseCityKey(categoryName)
                                    break
                                end
                            end
                        end
                    end
                end

                -- If we know it's an outlaws refuge but couldn't derive a base city from the live tooltip text,
                -- fall back to the offline lookup header (which can include variants like "Outlaw's Refuge").
                if isOutlawRefuge and not baseCityKey and outlawRow and outlawRow.header then
                    baseCityKey = GetOutlawBaseCityKey(outlawRow.header)
                end

                if isOutlawRefuge then
                    -- If the header/lines don't include the city, fall back to the current map name (usually the city map).
                    if not baseCityKey and GetMapName then
                        baseCityKey = NormalizeCityKey(GetMapName())
                    end

                    local guildDataById = SmartTrader and SmartTrader.state and SmartTrader.state.savedVars and
                        SmartTrader.state.savedVars.guildDataById or nil
                    if baseCityKey then
                        local savedVars = SmartTrader and SmartTrader.state and SmartTrader.state.savedVars or nil
                        local guildDataByTraderName = savedVars and savedVars.guildDataByTraderName or nil
                        local Lookup = SmartTrader and SmartTrader.LookupActions
                        local traderNames = (Lookup and Lookup.GetOutlawTraderNamesByBaseCityKey) and
                            Lookup.GetOutlawTraderNamesByBaseCityKey(baseCityKey) or nil

                        if traderNames and #traderNames > 0 then
                            ---@type CachedGuildData[]
                            local outlawList = {}
                            for i = 1, #traderNames do
                                local traderName = traderNames[i]
                                local data = (guildDataByTraderName and traderName) and guildDataByTraderName
                                    [traderName] or
                                    nil
                                outlawList[#outlawList + 1] = data or
                                    {
                                        guildId = 0,
                                        guildName = traderName,
                                        traderName = traderName,
                                        memberCount = 0,
                                    }
                            end

                            SortGuildsLargestFirst(outlawList)

                            local dividerSection = self.tooltip:AcquireSection(self.tooltip:GetStyle(
                                "mapKeepCategorySpacing"))
                            if dividerSection and dividerSection.AddTexture and ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE then
                                dividerSection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE,
                                    self.tooltip:GetStyle("dividerLine"))
                            end
                            self.tooltip:AddSection(dividerSection)

                            local section = self.tooltip:AcquireSection(self.tooltip:GetStyle(
                                "mapLocationTooltipSection"))
                            self:LayoutIconStringLine(section, nil, "Outlaw Traders",
                                self.tooltip:GetStyle("mapLocationTooltipWayshrineHeader"))

                            local GuildUtils = SmartTrader and SmartTrader.GuildUtils
                            local countToShow = math.min(#outlawList, MAX_CITY_TRADERS_TO_LOG)
                            for i = 1, countToShow do
                                local data = outlawList[i]
                                local fallback = data and (data.traderName or data.guildName) or nil
                                local text = nil
                                if GuildUtils and GuildUtils.FormatGuildDisplayText then
                                    text = GuildUtils.FormatGuildDisplayText(data, fallback)
                                end
                                text = text or fallback or "(unknown)"
                                self:LayoutIconStringLine(section, nil, text)
                            end

                            if #outlawList > countToShow then
                                self:LayoutIconStringLine(section, nil,
                                    string.format("... +%d more", #outlawList - countToShow))
                            end

                            self.tooltip:AddSection(section)
                        end
                    end
                end
            end
        end

        self.__SmartTraderLocationEntryQueue = nil
        self.__SmartTraderLocationEntryQueueIndex = nil
        self.__SmartTraderCurrentMapId = nil
        self.__SmartTraderCurrentLocationIndex = nil
        self.__SmartTraderCurrentPinKey = nil
        self.__SmartTraderCurrentIsKioskPin = nil

        return result
    end

    return true
end

---@param self any
---@param nodeIndex number
local function AppendSmartTraderCityTraderSectionsForWayshrineNodeIndex(self, nodeIndex)
    if not nodeIndex or not GetMapType then
        return
    end

    local mapType = GetMapType()
    if mapType ~= MAPTYPE_WORLD and mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE then
        return
    end

    -- Debug marker: did our gamepad wayshrine hook run?
    if IsHoverLogEnabled() then
        local mapId = GetCurrentMapId and GetCurrentMapId() or nil
        local key = string.format("st:wayshrineHook:%d:%s:%s", tonumber(nodeIndex) or 0, tostring(mapId or ""),
            tostring(mapType or ""))
        if not MarkHoverLogKeySeen(key) then
            AppendHoverLogLine(key, TableToJsonLine({
                event = "stWayshrineTooltipHook",
                nodeIndex = nodeIndex,
                mapId = mapId,
                mapType = mapType,
                mapName = GetMapName and GetMapName() or nil,
                timestamp = GetTimeStamp and GetTimeStamp() or nil,
            }))
        end
    end

    local cycleId = (type(self.__SmartTraderTooltipCycleId) == "number") and self.__SmartTraderTooltipCycleId or nil
    if not cycleId then
        cycleId = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or (GetTimeStamp and GetTimeStamp()) or 0
    end

    -- Avoid double-injecting within the same tooltip build cycle (e.g. overlapping pins like custom + real wayshrines).
    if self.__SmartTraderAugmentedWayshrineNodeIndex == nodeIndex and self.__SmartTraderAugmentedWayshrineCycleId == cycleId then
        return
    end

    -- Prefer lookup-derived wayshrine metadata when the live API is missing info.
    local Lookup = SmartTrader and SmartTrader.LookupActions
    local way = (Lookup and Lookup.GetWayshrineByNodeIndex) and Lookup.GetWayshrineByNodeIndex(nodeIndex) or nil

    local nodeZoneIndex, nodePoiIndex = nil, nil
    if GetFastTravelNodePOIIndicies then
        nodeZoneIndex, nodePoiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
    end
    -- Some clients/maps return 0 instead of nil for POI indices; treat 0 as missing so our lookup fallback works.
    if type(nodeZoneIndex) ~= "number" or nodeZoneIndex == 0 then
        nodeZoneIndex = nil
    end
    if type(nodePoiIndex) ~= "number" or nodePoiIndex == 0 then
        nodePoiIndex = nil
    end
    if not nodeZoneIndex and way and type(way.nodeZoneIndex) == "number" and way.nodeZoneIndex ~= 0 then
        nodeZoneIndex = way.nodeZoneIndex
    end
    if (not nodePoiIndex) and way and type(way.nodePoiIndex) == "number" and way.nodePoiIndex ~= 0 then
        nodePoiIndex = way.nodePoiIndex
    end
    if not nodeZoneIndex then
        return
    end

    local nodeZoneId, nodeParentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(nodeZoneIndex)
    if (not nodeParentZoneId) and way then
        if type(way.parentZoneId) == "number" and way.parentZoneId ~= 0 then
            nodeParentZoneId = way.parentZoneId
        end
        if type(way.zoneId) == "number" and way.zoneId ~= 0 then
            nodeZoneId = way.zoneId
        end
    end
    if not nodeParentZoneId then
        return
    end

    local wayshrineName = nil
    local poiType = nil
    if GetFastTravelNodeInfo then
        local _known, name, _x, _y, _icon, _glow, pt = GetFastTravelNodeInfo(nodeIndex)
        wayshrineName = name
        poiType = pt
    end
    -- Only augment *wayshrines*. Houses and other fast travel nodes should never show city trader listings.
    if type(poiType) == "number" and poiType ~= POI_TYPE_WAYSHRINE then
        return
    end
    if not wayshrineName and way and way.name then
        wayshrineName = way.name
    end

    local zoneKey = GetZoneNameByIndex and NormalizeCityKey(GetZoneNameByIndex(nodeZoneIndex)) or nil

    local poiName = GetPOIName(nodeZoneIndex, nodePoiIndex)
    local poiCityKey, poiCityZoneIndex, poiCityZoneId = ResolveCityZoneFromPOIName(poiName)
    local poiCityParentZoneId = poiCityZoneId and GetParentZoneIdByZoneId(poiCityZoneId) or nil

    -- Build lookup indices once so we can use stable map-derived keys when possible.
    EnsureLookupMapIndices()

    -- Primary structural signal: if the node's zone is itself a subzone, treat it as a city wayshrine.
    local isCitySubzoneByNode = (nodeZoneId ~= nil and nodeZoneId ~= 0 and nodeParentZoneId ~= nil and
        nodeZoneId ~= nodeParentZoneId)

    -- Determine the "city zone" that a city wayshrine represents on zone maps.
    local cityKey = nil
    local cityZoneId = nil
    if isCitySubzoneByNode then
        cityZoneId = nodeZoneId
        cityKey = zoneKey
    elseif poiCityKey and poiCityParentZoneId and poiCityParentZoneId == nodeParentZoneId and kioskMapNameKeySet and
        kioskMapNameKeySet[poiCityKey] then
        -- Some city POIs share the same zoneId as their parent zone (e.g. Gonfalon Bay within High Isle),
        -- so we can't rely on zoneId != parentZoneId to identify them. If the POI resolves to a map-name
        -- key that we know contains kiosk pins, prefer matching by that stable key.
        cityKey = poiCityKey
        cityZoneId = nil
    elseif poiCityZoneId and poiCityParentZoneId and poiCityParentZoneId == nodeParentZoneId and poiCityZoneId ~=
        nodeParentZoneId then
        cityZoneId = poiCityZoneId
        cityKey = poiCityKey
    else
        -- Fallback (only when the node doesn't expose a subzone zoneId): derive from POI/display name.
        -- Prefer the POI name (driven by nodePoiIndex) over the wayshrine name (which may be a district name).
        local baseKey = GetWayshrineBaseKey(poiName) or GetWayshrineBaseKey(wayshrineName)

        local baseKeyIsKioskCity = baseKey and kioskMapNameKeySet and kioskMapNameKeySet[baseKey] or false
        local baseKeyMatchesParentZone = false
        if baseKeyIsKioskCity then
            if nodeParentZoneId and kioskMapNameKeysByParentZoneId then
                local set = kioskMapNameKeysByParentZoneId[nodeParentZoneId]
                -- If we have a parent-zone mapping, require membership; otherwise don't block.
                baseKeyMatchesParentZone = (not set) or (set[baseKey] == true)
            else
                baseKeyMatchesParentZone = true
            end
        end

        if baseKeyIsKioskCity and baseKeyMatchesParentZone then
            -- City-key by LookupTables map identity: this is stronger than POI-name membership and works even when
            -- the city doesn't exist as a zone (e.g. city maps whose zoneId == parentZoneId).
            cityKey = baseKey
            cityZoneId = nil -- may not exist as a zoneId; we match by cityKey
        elseif baseKey and DoesPOIKeyBelongToZoneIndex(baseKey, nodeZoneIndex) then
            -- This is a city POI inside the current zone (e.g. ANVIL inside Gold Coast).
            cityKey = baseKey
            cityZoneId = nil -- may not exist as a zoneId; we match by cityKey
        else
            local fallbackCityKey, _, fallbackCityZoneId = ResolveCityZoneFromWayshrineName(wayshrineName)
            if fallbackCityZoneId then
                cityZoneId = fallbackCityZoneId
                cityKey = fallbackCityKey
            end
        end
    end

    -- Last resort: if we're currently on a map that has kiosk pins, prefer that map's stable name-key.
    -- This fixes district-named wayshrines on city maps (e.g. "Gonfalon Square Wayshrine" should map to "Gonfalon Bay").
    if kioskMapNameKeySet then
        local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
        local currentMapKey = (type(currentMapId) == "number" and mapIdToMapNameKey) and mapIdToMapNameKey[currentMapId] or
            nil
        if currentMapKey and kioskMapNameKeySet[currentMapKey] then
            if (not cityKey) or (not kioskMapNameKeySet[cityKey]) then
                cityKey = currentMapKey
            end
        elseif GetMapName then
            local nameKey = NormalizeCityKey(GetMapName())
            if nameKey and kioskMapNameKeySet[nameKey] then
                if (not cityKey) or (not kioskMapNameKeySet[cityKey]) then
                    cityKey = nameKey
                end
            end
        end
    end

    -- Canonicalize common variants so we match LookupTables keys (e.g. "WAYREST CITY" -> "WAYREST").
    cityKey = CanonicalizeKioskCityKey(cityKey)

    -- If we're on a world/zone map, the POI/wayshrine name often reflects a district ("Gonfalon Square", "Stonetooth")
    -- rather than the city map name we key kiosks under. When the parent zone has exactly one kiosk-city in our
    -- lookup tables, use it as the cityKey.
    if kioskMapNameKeySet and nodeParentZoneId and (not cityKey or not kioskMapNameKeySet[cityKey]) then
        local uniqueKey = GetUniqueKioskMapNameKeyForParentZoneId(nodeParentZoneId)
        if uniqueKey then
            cityKey = uniqueKey
        elseif mapType == MAPTYPE_WORLD then
            -- World map fallback: if we can't map to a known kiosk city key, don't treat an unrecognized
            -- cityKey as authoritative (it blocks parent-zone matching).
            cityKey = nil
        end
    end

    -- Zone-map fallback for multi-city parent zones: use the POI's map transition (WouldProcessMapClick) to
    -- discover the actual city mapId, then mapId->mapNameKey (lookup-driven, avoids name guessing).
    if mapType == MAPTYPE_ZONE and kioskMapNameKeySet and (not cityKey or not kioskMapNameKeySet[cityKey]) then
        local viaPoiMap = ResolveKioskCityKeyFromPOIMapClick(nodeZoneIndex, nodePoiIndex)
        if viaPoiMap then
            cityKey = viaPoiMap
        end
    end

    -- Strongest signal (LookupTables): a city wayshrine appears on both the zone map and the city map.
    -- Use the mapId(s) that this nodeIndex is known to appear on and choose the one that actually has guild traders.
    local cityMapId = nil
    do
        local tables = SmartTrader and SmartTrader.LookupTables
        local mapIdsByNode = tables and tables.WayshrineMapIdsByNodeIndex
        local mapIds = (type(nodeIndex) == "number" and mapIdsByNode) and mapIdsByNode[nodeIndex] or nil
        if mapIds and #mapIds > 0 then
            EnsureKioskTraderNamesByMapId()
            local mapById = tables and tables.MapById
            local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil

            -- Prefer city/subzone mapIds when the node appears on both an overland zone map and a city map.
            -- Some overland maps also contain a "Guild Traders" location (e.g. Auridon) which can tie on trader count
            -- and incorrectly win unless we bias toward the subzone map.
            local preferSubzone = false
            local preferSubzoneKiosk = false
            for i = 1, #mapIds do
                local mid = mapIds[i]
                local row = mapById and mid and mapById[mid] or nil
                if row and row.mapType == MAPTYPE_SUBZONE then
                    preferSubzone = true
                    local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                    if key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                        preferSubzoneKiosk = true
                    end
                end
            end

            local bestMapId = nil
            local bestCount = 0
            local bestScore = nil
            for i = 1, #mapIds do
                local mid = mapIds[i]
                local row = mapById and mid and mapById[mid] or nil
                local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                local isSubzone = row and row.mapType == MAPTYPE_SUBZONE
                local isSubzoneKiosk = isSubzone and key and kioskMapNameKeySet and kioskMapNameKeySet[key]

                local eligible = true
                if preferSubzoneKiosk then
                    eligible = isSubzoneKiosk == true
                elseif preferSubzone then
                    eligible = isSubzone == true
                end

                if eligible then
                    local names = (kioskTraderNamesByMapId and type(mid) == "number") and kioskTraderNamesByMapId[mid] or nil
                    local count = names and #names or 0

                    -- Score: prefer more traders, then subzone/city maps, then matching current derived cityKey, then current map id.
                    local score = (count * 1000)
                    if isSubzone then
                        score = score + 100
                    end
                    if cityKey and key and key == cityKey then
                        score = score + 50
                    end
                    if currentMapId and mid == currentMapId then
                        score = score + 10
                    end

                    if (not bestScore) or score > bestScore then
                        bestScore = score
                        bestMapId = mid
                        bestCount = count
                    end
                end
            end

            local chosenMapId = nil
            if bestMapId and bestCount > 0 then
                chosenMapId = bestMapId
            else
                -- Fallback: even if LookupTables doesn't yet have kiosk traders for this map, prefer the city/subzone
                -- mapId over the overland mapId so cached guild data still resolves correctly.

                -- Pass 1: subzone map that is known to have kiosk pins (best structural match for "city wayshrine").
                for i = 1, #mapIds do
                    local mid = mapIds[i]
                    local row = mapById and mid and mapById[mid] or nil
                    local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                    if row and row.mapType == MAPTYPE_SUBZONE and key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                        chosenMapId = mid
                        break
                    end
                end

                -- Pass 2: any map that is known to have kiosk pins.
                if not chosenMapId then
                    for i = 1, #mapIds do
                        local mid = mapIds[i]
                        local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                        if key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                            chosenMapId = mid
                            break
                        end
                    end
                end

                -- Pass 3: any subzone map (even if not flagged as a kiosk city in lookup tables).
                if not chosenMapId then
                    for i = 1, #mapIds do
                        local mid = mapIds[i]
                        local row = mapById and mid and mapById[mid] or nil
                        if row and row.mapType == MAPTYPE_SUBZONE then
                            chosenMapId = mid
                            break
                        end
                    end
                end
            end

            if chosenMapId then
                cityMapId = chosenMapId
                local key = (mapIdToMapNameKey and type(chosenMapId) == "number") and mapIdToMapNameKey[chosenMapId] or nil
                if key then
                    cityKey = key
                end
            end
        end
    end
    local isCitySubzone = (cityKey ~= nil and cityKey ~= "" and (not zoneKey or cityKey ~= zoneKey))

    local savedVars = SmartTrader and SmartTrader.state and SmartTrader.state.savedVars
    local guildDataByTraderName = savedVars and savedVars.guildDataByTraderName or nil
    local guildDataById = savedVars and savedVars.guildDataById or nil

    -- On zone maps, we only show traders for city wayshrines (hidden layer).
    if mapType == MAPTYPE_ZONE and not isCitySubzone then
        return
    end

    ---@type CachedGuildData[]
    local matches = {}
    ---@type CachedGuildData[]
    local outlawMatches = {}

    -- LookupTables-first: show the known trader NPCs for the resolved city map, even if guild cache is incomplete.
    local usedLookup = false
    if cityMapId then
        EnsureKioskTraderNamesByMapId()
        local traderNames = kioskTraderNamesByMapId and kioskTraderNamesByMapId[cityMapId] or nil
        if traderNames and #traderNames > 0 then
            usedLookup = true
            for i = 1, #traderNames do
                local traderName = traderNames[i]
                local data = (guildDataByTraderName and traderName) and guildDataByTraderName[traderName] or nil
                matches[#matches + 1] = data or
                    {
                        guildId = 0,
                        guildName = traderName,
                        traderName = traderName,
                        memberCount = 0,
                    }
            end
        end
    end

    -- Fallback: if lookup tables don't cover this city, derive matches from cached guild data.
    if (not usedLookup) and guildDataById then
        local cityFormatIndex = SmartTrader.MapActions.BuildCityLocationFormatIndex(guildDataById)
        for _, data in pairs(guildDataById) do
            local locationKey, locationZoneIndex, locationZoneId, locationParentZoneId, isOutlaw, outlawBaseCityKey =
                nil, nil, nil, nil, false, nil

            -- Primary: resolve kiosk location via LookupTables.
            local resolved = ResolveCachedLocationFromLookup(data)
            if resolved then
                locationKey = resolved.locationKey
                locationZoneId = resolved.zoneId
                locationParentZoneId = resolved.parentZoneId
                isOutlaw = resolved.isOutlaw
                outlawBaseCityKey = resolved.outlawBaseCityKey
            else
                -- Fallback: use guild-finder-parsed location strings.
                locationKey, locationZoneIndex, locationZoneId, locationParentZoneId, isOutlaw, outlawBaseCityKey =
                    ResolveCachedLocation(data, cityFormatIndex)
            end

            if locationParentZoneId and locationParentZoneId == nodeParentZoneId then
                local include = false

                if mapType == MAPTYPE_WORLD then
                    -- World map pins often represent the "capital"/primary subzone of the parent zone.
                    -- Prefer correlating by derived city/subzone when we can; fall back to parent-zone matching otherwise.
                    if cityKey or cityZoneId then
                        if isOutlaw then
                            -- Outlaw refuges are their own subzones; associate them back to the city POI.
                            if cityKey and outlawBaseCityKey and cityKey == outlawBaseCityKey then
                                include = true
                            end
                        else
                            -- City traders: match by derived cityKey when available, otherwise by zoneId.
                            if cityKey and locationKey and locationKey == cityKey then
                                include = true
                            elseif locationZoneId and cityZoneId and locationZoneId == cityZoneId and
                                locationZoneId ~= locationParentZoneId then
                                include = true
                            end
                        end
                    else
                        include = true
                    end
                else
                    if isOutlaw then
                        -- Outlaw refuges are their own subzones; associate them back to the city POI.
                        if cityKey and outlawBaseCityKey and cityKey == outlawBaseCityKey then
                            include = true
                        end
                    else
                        -- City traders: match by derived cityKey when available, otherwise by zoneId.
                        if cityKey and locationKey and locationKey == cityKey then
                            include = true
                        elseif locationZoneId and cityZoneId and locationZoneId == cityZoneId and
                            locationZoneId ~= locationParentZoneId then
                            include = true
                        end
                    end
                end

                if include then
                    if isOutlaw then
                        outlawMatches[#outlawMatches + 1] = data
                    else
                        matches[#matches + 1] = data
                    end
                end
            end
        end
    end

    -- LookupTables-first: ensure Outlaw Traders are associated by the Outlaws Refuge map identity,
    -- not by guild-finder location-string parsing. This also lets us show trader names even when
    -- the owning guild hasn't been cached yet.
    if cityKey then
        local traderNames = (Lookup and Lookup.GetOutlawTraderNamesByBaseCityKey) and
            Lookup.GetOutlawTraderNamesByBaseCityKey(cityKey) or nil
        if traderNames and #traderNames > 0 then
            local outlawSet = {}
            for i = 1, #traderNames do
                outlawSet[traderNames[i]] = true
            end

            -- Move any mistakenly classified entries from regular -> outlaw.
            for i = #matches, 1, -1 do
                local data = matches[i]
                local traderName = data and data.traderName or nil
                if traderName and outlawSet[traderName] then
                    outlawMatches[#outlawMatches + 1] = data
                    table.remove(matches, i)
                end
            end

            -- Add missing outlaw traders (as placeholder entries) so tooltips remain useful even when not cached.
            local present = {}
            for i = 1, #outlawMatches do
                local traderName = outlawMatches[i] and outlawMatches[i].traderName or nil
                if traderName then
                    present[traderName] = true
                end
            end

            local guildDataByTraderName = savedVars and savedVars.guildDataByTraderName or nil
            for i = 1, #traderNames do
                local traderName = traderNames[i]
                if traderName and not present[traderName] then
                    local data = (guildDataByTraderName and guildDataByTraderName[traderName]) or nil
                    outlawMatches[#outlawMatches + 1] = data or
                        {
                            guildId = 0,
                            guildName = traderName,
                            traderName = traderName,
                            memberCount = 0,
                        }
                end
            end
        end
    end

    if #matches == 0 and #outlawMatches == 0 then
        return
    end

    -- Mark as injected for this tooltip cycle so overlapping pins don't duplicate our section.
    self.__SmartTraderAugmentedWayshrineNodeIndex = nodeIndex
    self.__SmartTraderAugmentedWayshrineCycleId = cycleId

    -- Debug: record what we resolved so hover-log exports include the final city/outlaw selection.
    if IsHoverLogEnabled() then
        local mapId = GetCurrentMapId and GetCurrentMapId() or nil
        local key = string.format("st:wayshrineResolved:%d:%s:%s", tonumber(nodeIndex) or 0, tostring(mapId or ""),
            tostring(mapType or ""))
        if not MarkHoverLogKeySeen(key) then
            local outlawNames = (Lookup and Lookup.GetOutlawTraderNamesByBaseCityKey and cityKey) and
                Lookup.GetOutlawTraderNamesByBaseCityKey(cityKey) or nil
            AppendHoverLogLine(key, TableToJsonLine({
                event = "stWayshrineTooltipResolved",
                nodeIndex = nodeIndex,
                mapId = mapId,
                mapType = mapType,
                mapName = GetMapName and GetMapName() or nil,
                cityKey = tostring(cityKey or ""),
                cityMapId = cityMapId,
                isCitySubzone = isCitySubzone and true or false,
                guildTraderCount = #matches,
                outlawTraderCount = #outlawMatches,
                outlawLookupCount = outlawNames and #outlawNames or 0,
                timestamp = GetTimeStamp and GetTimeStamp() or nil,
            }))
        end
    end

    SortGuildsLargestFirst(matches)
    SortGuildsLargestFirst(outlawMatches)

    -- World/Zone maps: add a little breathing room above our injected section.
    if IsWorldOrZoneMap() then
        local separatorSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("mapKeepCategorySpacing"))
        if separatorSection and separatorSection.AddTexture and ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE then
            separatorSection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, self.tooltip:GetStyle("dividerLine"))
        end
        self.tooltip:AddSection(separatorSection)
    end

    local GuildUtils = SmartTrader and SmartTrader.GuildUtils

    local function AppendTraderCategory(title, list)
        if not list or #list == 0 then
            return
        end

        local section = self.tooltip:AcquireSection(self.tooltip:GetStyle("mapLocationTooltipSection"))
        self:LayoutIconStringLine(section, nil, title, self.tooltip:GetStyle("mapLocationTooltipWayshrineHeader"))

        local countToShow = math.min(#list, MAX_CITY_TRADERS_TO_LOG)
        for i = 1, countToShow do
            local data = list[i]
            local fallback = data and (data.traderName or data.guildName) or nil
            local text = nil
            if GuildUtils and GuildUtils.FormatGuildDisplayText then
                text = GuildUtils.FormatGuildDisplayText(data, fallback)
            end
            text = text or fallback or "(unknown)"
            self:LayoutIconStringLine(section, nil, text)
        end

        if #list > countToShow then
            self:LayoutIconStringLine(section, nil, string.format("... +%d more", #list - countToShow))
        end

        self.tooltip:AddSection(section)
    end

    AppendTraderCategory("Guild Traders", matches)

    if #outlawMatches > 0 then
        -- "Outlaw Traders" gets its own divider/category.
        local dividerSection = self.tooltip:AcquireSection(self.tooltip:GetStyle("mapKeepCategorySpacing"))
        if dividerSection and dividerSection.AddTexture and ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE then
            dividerSection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, self.tooltip:GetStyle("dividerLine"))
        end
        self.tooltip:AddSection(dividerSection)
        AppendTraderCategory("Outlaw Traders", outlawMatches)
    end
end

-- -----------------------------------------------------------------------------
-- Hover-log debug helpers (wayshrine -> city/outlaw resolution)
-- -----------------------------------------------------------------------------

ResolveWayshrineCityDebug = function(nodeIndex)
    if type(nodeIndex) ~= "number" or nodeIndex <= 0 then
        return nil
    end

    ---@type table<string, any>
    local dbg = {
        stEvent = "stWayshrineResolve",
        stNodeIndex = nodeIndex,
        stMapId = GetCurrentMapId and GetCurrentMapId() or nil,
        stMapType = GetMapType and GetMapType() or nil,
        stMapName = GetMapName and GetMapName() or nil,
    }

    if not GetFastTravelNodeInfo then
        dbg.stReason = "no_GetFastTravelNodeInfo"
        return dbg
    end

    local known, name, _x, _y, _icon, _glow, poiType = GetFastTravelNodeInfo(nodeIndex)
    dbg.stNodeKnown = known and true or false
    dbg.stNodeName = name
    dbg.stPoiType = poiType

    if type(poiType) == "number" and poiType ~= POI_TYPE_WAYSHRINE then
        dbg.stReason = "not_wayshrine"
        return dbg
    end

    local Lookup = SmartTrader and SmartTrader.LookupActions
    local way = (Lookup and Lookup.GetWayshrineByNodeIndex) and Lookup.GetWayshrineByNodeIndex(nodeIndex) or nil

    local nodeZoneIndex, nodePoiIndex = nil, nil
    if GetFastTravelNodePOIIndicies then
        nodeZoneIndex, nodePoiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
    end
    if type(nodeZoneIndex) ~= "number" or nodeZoneIndex == 0 then
        nodeZoneIndex = nil
    end
    if type(nodePoiIndex) ~= "number" or nodePoiIndex == 0 then
        nodePoiIndex = nil
    end
    if not nodeZoneIndex and way and type(way.nodeZoneIndex) == "number" and way.nodeZoneIndex ~= 0 then
        nodeZoneIndex = way.nodeZoneIndex
    end
    if (not nodePoiIndex) and way and type(way.nodePoiIndex) == "number" and way.nodePoiIndex ~= 0 then
        nodePoiIndex = way.nodePoiIndex
    end

    dbg.stNodeZoneIndex = nodeZoneIndex
    dbg.stNodePoiIndex = nodePoiIndex

    if not nodeZoneIndex then
        dbg.stReason = "no_nodeZoneIndex"
        return dbg
    end

    local nodeZoneId, nodeParentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(nodeZoneIndex)
    if (not nodeParentZoneId) and way then
        if type(way.parentZoneId) == "number" and way.parentZoneId ~= 0 then
            nodeParentZoneId = way.parentZoneId
        end
        if type(way.zoneId) == "number" and way.zoneId ~= 0 then
            nodeZoneId = way.zoneId
        end
    end
    dbg.stNodeZoneId = nodeZoneId
    dbg.stNodeParentZoneId = nodeParentZoneId

    local zoneKey = GetZoneNameByIndex and NormalizeCityKey(GetZoneNameByIndex(nodeZoneIndex)) or nil
    dbg.stZoneKey = zoneKey

    local poiName = GetPOIName(nodeZoneIndex, nodePoiIndex)
    dbg.stPoiName = poiName

    EnsureLookupMapIndices()
    EnsureKioskTraderNamesByMapId()

    local tables = SmartTrader and SmartTrader.LookupTables
    local mapIdsByNode = tables and tables.WayshrineMapIdsByNodeIndex
    local mapIds = (mapIdsByNode and mapIdsByNode[nodeIndex]) or nil

    if mapIds and #mapIds > 0 then
        local parts = {}
        for i = 1, #mapIds do
            parts[#parts + 1] = tostring(mapIds[i])
        end
        dbg.stMapIdsByNodeIndex = table.concat(parts, ",")
    end

    local cityMapId = nil
    local cityKey = nil
    local bestMapId, bestCount = nil, 0
    local bestScore = nil
    local hintCityKey = GetWayshrineBaseKey(name)
    if hintCityKey and hintCityKey ~= "" then
        dbg.stCityKeyHint = hintCityKey
    end

    if mapIds and #mapIds > 0 then
        local mapById = tables and tables.MapById
        local currentMapId = dbg.stMapId

        local preferSubzone = false
        local preferSubzoneKiosk = false
        for i = 1, #mapIds do
            local mid = mapIds[i]
            local row = mapById and mid and mapById[mid] or nil
            if row and row.mapType == MAPTYPE_SUBZONE then
                preferSubzone = true
                local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                if key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                    preferSubzoneKiosk = true
                end
            end
        end

        for i = 1, #mapIds do
            local mid = mapIds[i]
            local row = mapById and mid and mapById[mid] or nil
            local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
            local isSubzone = row and row.mapType == MAPTYPE_SUBZONE
            local isSubzoneKiosk = isSubzone and key and kioskMapNameKeySet and kioskMapNameKeySet[key]

            local eligible = true
            if preferSubzoneKiosk then
                eligible = isSubzoneKiosk == true
            elseif preferSubzone then
                eligible = isSubzone == true
            end

            if eligible then
                local names = (kioskTraderNamesByMapId and type(mid) == "number") and kioskTraderNamesByMapId[mid] or nil
                local count = names and #names or 0

                local score = (count * 1000)
                if isSubzone then
                    score = score + 100
                end
                if hintCityKey and key and key == hintCityKey then
                    score = score + 50
                end
                if currentMapId and mid == currentMapId then
                    score = score + 10
                end

                if (not bestScore) or score > bestScore then
                    bestScore = score
                    bestCount = count
                    bestMapId = mid
                end
            end
        end

        dbg.stBestCityMapId = bestMapId
        dbg.stBestCityTraderCount = bestCount

        local chosenMapId = nil
        if bestMapId and bestCount > 0 then
            chosenMapId = bestMapId
        else
            -- Mirror the runtime fallback selection used by the tooltip logic.
            local mapById = tables and tables.MapById

            -- Pass 1: subzone map that is known to have kiosk pins.
            for i = 1, #mapIds do
                local mid = mapIds[i]
                local row = mapById and mid and mapById[mid] or nil
                local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                if row and row.mapType == MAPTYPE_SUBZONE and key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                    chosenMapId = mid
                    break
                end
            end

            -- Pass 2: any map that is known to have kiosk pins.
            if not chosenMapId then
                for i = 1, #mapIds do
                    local mid = mapIds[i]
                    local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                    if key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                        chosenMapId = mid
                        break
                    end
                end
            end

            -- Pass 3: any subzone map.
            if not chosenMapId then
                for i = 1, #mapIds do
                    local mid = mapIds[i]
                    local row = mapById and mid and mapById[mid] or nil
                    if row and row.mapType == MAPTYPE_SUBZONE then
                        chosenMapId = mid
                        break
                    end
                end
            end
        end

        if chosenMapId then
            cityMapId = chosenMapId
            cityKey = (mapIdToMapNameKey and type(chosenMapId) == "number") and mapIdToMapNameKey[chosenMapId] or nil
        end
    end

    dbg.stCityMapId = cityMapId
    dbg.stCityKey = cityKey
    dbg.stCityKeyCanon = CanonicalizeKioskCityKey(cityKey)

    local isCitySubzone = (dbg.stCityKeyCanon and dbg.stCityKeyCanon ~= "" and (not zoneKey or dbg.stCityKeyCanon ~= zoneKey))
    dbg.stIsCitySubzone = isCitySubzone and true or false
    if dbg.stMapType == MAPTYPE_ZONE and not isCitySubzone then
        dbg.stZoneMapWouldHide = true
    end

    if cityMapId then
        local traderNames = kioskTraderNamesByMapId and kioskTraderNamesByMapId[cityMapId] or nil
        dbg.stGuildTraderLookupCount = traderNames and #traderNames or 0
        if traderNames and #traderNames > 0 then
            dbg.stGuildTraderNames = table.concat(traderNames, ",")
        end
    end

    local canonKey = dbg.stCityKeyCanon
    if canonKey and Lookup and Lookup.GetOutlawTraderNamesByBaseCityKey then
        local outlawNames = Lookup.GetOutlawTraderNamesByBaseCityKey(canonKey)
        dbg.stOutlawTraderLookupCount = outlawNames and #outlawNames or 0
        if outlawNames and #outlawNames > 0 then
            dbg.stOutlawTraderNames = table.concat(outlawNames, ",")
        end
    end

    dbg.stReason = "ok"
    return dbg
end

---@param tooltip any
---@param nodeIndex number
local function AppendSmartTraderCityTraderLinesForWayshrineNodeIndexKeyboard(tooltip, nodeIndex)
    if not tooltip or type(tooltip.AddLine) ~= "function" then
        return
    end
    if not nodeIndex or not GetMapType then
        return
    end

    local mapType = GetMapType()
    if mapType ~= MAPTYPE_WORLD and mapType ~= MAPTYPE_ZONE and mapType ~= MAPTYPE_SUBZONE then
        return
    end

    -- Only augment *wayshrines*. Houses and other fast travel nodes should never show city trader listings.
    if GetFastTravelNodeInfo then
        local poiType = select(7, GetFastTravelNodeInfo(nodeIndex))
        if type(poiType) == "number" and poiType ~= POI_TYPE_WAYSHRINE then
            return
        end
    end

    -- Prefer lookup-derived wayshrine metadata when the live API is missing info.
    local Lookup = SmartTrader and SmartTrader.LookupActions
    local way = (Lookup and Lookup.GetWayshrineByNodeIndex) and Lookup.GetWayshrineByNodeIndex(nodeIndex) or nil

    local nodeZoneIndex, nodePoiIndex = nil, nil
    if GetFastTravelNodePOIIndicies then
        nodeZoneIndex, nodePoiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
    end
    -- Some clients/maps return 0 instead of nil for POI indices; treat 0 as missing so our lookup fallback works.
    if type(nodeZoneIndex) ~= "number" or nodeZoneIndex == 0 then
        nodeZoneIndex = nil
    end
    if type(nodePoiIndex) ~= "number" or nodePoiIndex == 0 then
        nodePoiIndex = nil
    end
    if not nodeZoneIndex and way and type(way.nodeZoneIndex) == "number" and way.nodeZoneIndex ~= 0 then
        nodeZoneIndex = way.nodeZoneIndex
    end
    if (not nodePoiIndex) and way and type(way.nodePoiIndex) == "number" and way.nodePoiIndex ~= 0 then
        nodePoiIndex = way.nodePoiIndex
    end
    if not nodeZoneIndex then
        return
    end

    local nodeZoneId, nodeParentZoneId = GetZoneIdAndParentZoneIdByZoneIndex(nodeZoneIndex)
    if (not nodeParentZoneId) and way then
        if type(way.parentZoneId) == "number" and way.parentZoneId ~= 0 then
            nodeParentZoneId = way.parentZoneId
        end
        if type(way.zoneId) == "number" and way.zoneId ~= 0 then
            nodeZoneId = way.zoneId
        end
    end
    if not nodeParentZoneId then
        return
    end

    local wayshrineName = nil
    if GetFastTravelNodeInfo then
        wayshrineName = select(2, GetFastTravelNodeInfo(nodeIndex))
    end
    if not wayshrineName and way and way.name then
        wayshrineName = way.name
    end

    local zoneKey = GetZoneNameByIndex and NormalizeCityKey(GetZoneNameByIndex(nodeZoneIndex)) or nil

    local poiName = GetPOIName(nodeZoneIndex, nodePoiIndex)
    local poiCityKey, _poiCityZoneIndex, poiCityZoneId = ResolveCityZoneFromPOIName(poiName)
    local poiCityParentZoneId = poiCityZoneId and GetParentZoneIdByZoneId(poiCityZoneId) or nil

    -- Build lookup indices once so we can use stable map-derived keys when possible.
    EnsureLookupMapIndices()

    -- Primary structural signal: if the node's zone is itself a subzone, treat it as a city wayshrine.
    local isCitySubzoneByNode = (nodeZoneId ~= nil and nodeZoneId ~= 0 and nodeParentZoneId ~= nil and
        nodeZoneId ~= nodeParentZoneId)

    -- Determine the "city zone" that a city wayshrine represents on zone maps.
    local cityKey = nil
    local cityZoneId = nil
    if isCitySubzoneByNode then
        cityZoneId = nodeZoneId
        cityKey = zoneKey
    elseif poiCityKey and poiCityParentZoneId and poiCityParentZoneId == nodeParentZoneId and kioskMapNameKeySet and
        kioskMapNameKeySet[poiCityKey] then
        -- Some city POIs share the same zoneId as their parent zone (e.g. Gonfalon Bay within High Isle),
        -- so we can't rely on zoneId != parentZoneId to identify them. If the POI resolves to a map-name
        -- key that we know contains kiosk pins, prefer matching by that stable key.
        cityKey = poiCityKey
        cityZoneId = nil
    elseif poiCityZoneId and poiCityParentZoneId and poiCityParentZoneId == nodeParentZoneId and poiCityZoneId ~=
        nodeParentZoneId then
        cityZoneId = poiCityZoneId
        cityKey = poiCityKey
    else
        -- Fallback (only when the node doesn't expose a subzone zoneId): derive from POI/display name.
        -- Prefer the POI name (driven by nodePoiIndex) over the wayshrine name (which may be a district name).
        local baseKey = GetWayshrineBaseKey(poiName) or GetWayshrineBaseKey(wayshrineName)

        local baseKeyIsKioskCity = baseKey and kioskMapNameKeySet and kioskMapNameKeySet[baseKey] or false
        local baseKeyMatchesParentZone = false
        if baseKeyIsKioskCity then
            if nodeParentZoneId and kioskMapNameKeysByParentZoneId then
                local set = kioskMapNameKeysByParentZoneId[nodeParentZoneId]
                -- If we have a parent-zone mapping, require membership; otherwise don't block.
                baseKeyMatchesParentZone = (not set) or (set[baseKey] == true)
            else
                baseKeyMatchesParentZone = true
            end
        end

        if baseKeyIsKioskCity and baseKeyMatchesParentZone then
            -- City-key by LookupTables map identity: this is stronger than POI-name membership and works even when
            -- the city doesn't exist as a zone (e.g. city maps whose zoneId == parentZoneId).
            cityKey = baseKey
            cityZoneId = nil -- may not exist as a zoneId; we match by cityKey
        elseif baseKey and DoesPOIKeyBelongToZoneIndex(baseKey, nodeZoneIndex) then
            -- This is a city POI inside the current zone (e.g. ANVIL inside Gold Coast).
            cityKey = baseKey
            cityZoneId = nil -- may not exist as a zoneId; we match by cityKey
        else
            local fallbackCityKey, _, fallbackCityZoneId = ResolveCityZoneFromWayshrineName(wayshrineName)
            if fallbackCityZoneId then
                cityZoneId = fallbackCityZoneId
                cityKey = fallbackCityKey
            end
        end
    end

    -- Last resort: if we're currently on a map that has kiosk pins, prefer that map's stable name-key.
    -- This fixes district-named wayshrines on city maps (e.g. "Gonfalon Square Wayshrine" should map to "Gonfalon Bay").
    if kioskMapNameKeySet then
        local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
        local currentMapKey = (type(currentMapId) == "number" and mapIdToMapNameKey) and mapIdToMapNameKey[currentMapId] or
            nil
        if currentMapKey and kioskMapNameKeySet[currentMapKey] then
            if (not cityKey) or (not kioskMapNameKeySet[cityKey]) then
                cityKey = currentMapKey
            end
        elseif GetMapName then
            local nameKey = NormalizeCityKey(GetMapName())
            if nameKey and kioskMapNameKeySet[nameKey] then
                if (not cityKey) or (not kioskMapNameKeySet[cityKey]) then
                    cityKey = nameKey
                end
            end
        end
    end

    -- Canonicalize common variants so we match LookupTables keys (e.g. "WAYREST CITY" -> "WAYREST").
    cityKey = CanonicalizeKioskCityKey(cityKey)

    -- If we're on a world/zone map, the POI/wayshrine name often reflects a district ("Gonfalon Square", "Stonetooth")
    -- rather than the city map name we key kiosks under. When the parent zone has exactly one kiosk-city in our
    -- lookup tables, use it as the cityKey.
    if kioskMapNameKeySet and nodeParentZoneId and (not cityKey or not kioskMapNameKeySet[cityKey]) then
        local uniqueKey = GetUniqueKioskMapNameKeyForParentZoneId(nodeParentZoneId)
        if uniqueKey then
            cityKey = uniqueKey
        elseif mapType == MAPTYPE_WORLD then
            -- World map fallback: if we can't map to a known kiosk city key, don't treat an unrecognized
            -- cityKey as authoritative (it blocks parent-zone matching).
            cityKey = nil
        end
    end

    -- Zone-map fallback for multi-city parent zones: use the POI's map transition (WouldProcessMapClick) to
    -- discover the actual city mapId, then mapId->mapNameKey (lookup-driven, avoids name guessing).
    if mapType == MAPTYPE_ZONE and kioskMapNameKeySet and (not cityKey or not kioskMapNameKeySet[cityKey]) then
        local viaPoiMap = ResolveKioskCityKeyFromPOIMapClick(nodeZoneIndex, nodePoiIndex)
        if viaPoiMap then
            cityKey = viaPoiMap
        end
    end

    -- Strongest signal (LookupTables): a city wayshrine appears on both the zone map and the city map.
    -- Use the mapId(s) that this nodeIndex is known to appear on and choose the one that actually has guild traders.
    local cityMapId = nil
    do
        local tables = SmartTrader and SmartTrader.LookupTables
        local mapIdsByNode = tables and tables.WayshrineMapIdsByNodeIndex
        local mapIds = (type(nodeIndex) == "number" and mapIdsByNode) and mapIdsByNode[nodeIndex] or nil
        if mapIds and #mapIds > 0 then
            EnsureKioskTraderNamesByMapId()
            local mapById = tables and tables.MapById
            local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil

            local preferSubzone = false
            local preferSubzoneKiosk = false
            for i = 1, #mapIds do
                local mid = mapIds[i]
                local row = mapById and mid and mapById[mid] or nil
                if row and row.mapType == MAPTYPE_SUBZONE then
                    preferSubzone = true
                    local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                    if key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                        preferSubzoneKiosk = true
                    end
                end
            end

            local bestMapId = nil
            local bestCount = 0
            local bestScore = nil
            for i = 1, #mapIds do
                local mid = mapIds[i]
                local row = mapById and mid and mapById[mid] or nil
                local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                local isSubzone = row and row.mapType == MAPTYPE_SUBZONE
                local isSubzoneKiosk = isSubzone and key and kioskMapNameKeySet and kioskMapNameKeySet[key]

                local eligible = true
                if preferSubzoneKiosk then
                    eligible = isSubzoneKiosk == true
                elseif preferSubzone then
                    eligible = isSubzone == true
                end

                if eligible then
                    local names = (kioskTraderNamesByMapId and type(mid) == "number") and kioskTraderNamesByMapId[mid] or nil
                    local count = names and #names or 0

                    local score = (count * 1000)
                    if isSubzone then
                        score = score + 100
                    end
                    if cityKey and key and key == cityKey then
                        score = score + 50
                    end
                    if currentMapId and mid == currentMapId then
                        score = score + 10
                    end

                    if (not bestScore) or score > bestScore then
                        bestScore = score
                        bestMapId = mid
                        bestCount = count
                    end
                end
            end

            local chosenMapId = nil
            if bestMapId and bestCount > 0 then
                chosenMapId = bestMapId
            else
                -- Fallback: even if LookupTables doesn't yet have kiosk traders for this map, prefer the city/subzone
                -- mapId over the overland mapId so cached guild data still resolves correctly.

                -- Pass 1: subzone map that is known to have kiosk pins (best structural match for "city wayshrine").
                for i = 1, #mapIds do
                    local mid = mapIds[i]
                    local row = mapById and mid and mapById[mid] or nil
                    local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                    if row and row.mapType == MAPTYPE_SUBZONE and key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                        chosenMapId = mid
                        break
                    end
                end

                -- Pass 2: any map that is known to have kiosk pins.
                if not chosenMapId then
                    for i = 1, #mapIds do
                        local mid = mapIds[i]
                        local key = (mapIdToMapNameKey and type(mid) == "number") and mapIdToMapNameKey[mid] or nil
                        if key and kioskMapNameKeySet and kioskMapNameKeySet[key] then
                            chosenMapId = mid
                            break
                        end
                    end
                end

                -- Pass 3: any subzone map (even if not flagged as a kiosk city in lookup tables).
                if not chosenMapId then
                    for i = 1, #mapIds do
                        local mid = mapIds[i]
                        local row = mapById and mid and mapById[mid] or nil
                        if row and row.mapType == MAPTYPE_SUBZONE then
                            chosenMapId = mid
                            break
                        end
                    end
                end
            end

            if chosenMapId then
                cityMapId = chosenMapId
                local key = (mapIdToMapNameKey and type(chosenMapId) == "number") and mapIdToMapNameKey[chosenMapId] or nil
                if key then
                    cityKey = key
                end
            end
        end
    end

    local isCitySubzone = (cityKey ~= nil and cityKey ~= "" and (not zoneKey or cityKey ~= zoneKey))

    -- On zone maps, we only show traders for city wayshrines (hidden layer).
    if mapType == MAPTYPE_ZONE and not isCitySubzone then
        return
    end

    local savedVars = SmartTrader and SmartTrader.state and SmartTrader.state.savedVars
    local guildDataByTraderName = savedVars and savedVars.guildDataByTraderName or nil
    local guildDataById = savedVars and savedVars.guildDataById or nil

    ---@type CachedGuildData[]
    local matches = {}
    ---@type CachedGuildData[]
    local outlawMatches = {}

    -- LookupTables-first: show the known trader NPCs for the resolved city map, even if guild cache is incomplete.
    local usedLookup = false
    if cityMapId then
        EnsureKioskTraderNamesByMapId()
        local traderNames = kioskTraderNamesByMapId and kioskTraderNamesByMapId[cityMapId] or nil
        if traderNames and #traderNames > 0 then
            usedLookup = true
            for i = 1, #traderNames do
                local traderName = traderNames[i]
                local data = (guildDataByTraderName and traderName) and guildDataByTraderName[traderName] or nil
                matches[#matches + 1] = data or
                    {
                        guildId = 0,
                        guildName = traderName,
                        traderName = traderName,
                        memberCount = 0,
                    }
            end
        end
    end

    -- Fallback: if lookup tables don't cover this city, derive matches from cached guild data.
    if (not usedLookup) and guildDataById then
        local cityFormatIndex = SmartTrader.MapActions.BuildCityLocationFormatIndex(guildDataById)
        for _, data in pairs(guildDataById) do
            local locationKey, _locationZoneIndex, locationZoneId, locationParentZoneId, isOutlaw, outlawBaseCityKey =
                nil, nil, nil, nil, false, nil

            -- Primary: resolve kiosk location via LookupTables.
            local resolved = ResolveCachedLocationFromLookup(data)
            if resolved then
                locationKey = resolved.locationKey
                locationZoneId = resolved.zoneId
                locationParentZoneId = resolved.parentZoneId
                isOutlaw = resolved.isOutlaw
                outlawBaseCityKey = resolved.outlawBaseCityKey
            else
                -- Fallback: use guild-finder-parsed location strings.
                locationKey, _locationZoneIndex, locationZoneId, locationParentZoneId, isOutlaw, outlawBaseCityKey =
                    ResolveCachedLocation(data, cityFormatIndex)
            end

            if locationParentZoneId and locationParentZoneId == nodeParentZoneId then
                local include = false

                if mapType == MAPTYPE_WORLD then
                    -- World map pins often represent the "capital"/primary subzone of the parent zone.
                    -- Prefer correlating by derived city/subzone when we can; fall back to parent-zone matching otherwise.
                    if cityKey or cityZoneId then
                        if isOutlaw then
                            -- Outlaw refuges are their own subzones; associate them back to the city POI.
                            if cityKey and outlawBaseCityKey and cityKey == outlawBaseCityKey then
                                include = true
                            end
                        else
                            -- City traders: match by derived cityKey when available, otherwise by zoneId.
                            if cityKey and locationKey and locationKey == cityKey then
                                include = true
                            elseif locationZoneId and cityZoneId and locationZoneId == cityZoneId and
                                locationZoneId ~= locationParentZoneId then
                                include = true
                            end
                        end
                    else
                        include = true
                    end
                else
                    if isOutlaw then
                        -- Outlaw refuges are their own subzones; associate them back to the city POI.
                        if cityKey and outlawBaseCityKey and cityKey == outlawBaseCityKey then
                            include = true
                        end
                    else
                        -- City traders: match by derived cityKey when available, otherwise by zoneId.
                        if cityKey and locationKey and locationKey == cityKey then
                            include = true
                        elseif locationZoneId and cityZoneId and locationZoneId == cityZoneId and
                            locationZoneId ~= locationParentZoneId then
                            include = true
                        end
                    end
                end

                if include then
                    if isOutlaw then
                        outlawMatches[#outlawMatches + 1] = data
                    else
                        matches[#matches + 1] = data
                    end
                end
            end
        end
    end

    -- LookupTables-first: ensure Outlaw Traders are associated by the Outlaws Refuge map identity,
    -- not by guild-finder location-string parsing. This also lets us show trader names even when
    -- the owning guild hasn't been cached yet.
    if cityKey then
        local traderNames = (Lookup and Lookup.GetOutlawTraderNamesByBaseCityKey) and
            Lookup.GetOutlawTraderNamesByBaseCityKey(cityKey) or nil
        if traderNames and #traderNames > 0 then
            local outlawSet = {}
            for i = 1, #traderNames do
                outlawSet[traderNames[i]] = true
            end

            -- Move any mistakenly classified entries from regular -> outlaw.
            for i = #matches, 1, -1 do
                local data = matches[i]
                local traderName = data and data.traderName or nil
                if traderName and outlawSet[traderName] then
                    outlawMatches[#outlawMatches + 1] = data
                    table.remove(matches, i)
                end
            end

            -- Add missing outlaw traders (as placeholder entries) so tooltips remain useful even when not cached.
            local present = {}
            for i = 1, #outlawMatches do
                local traderName = outlawMatches[i] and outlawMatches[i].traderName or nil
                if traderName then
                    present[traderName] = true
                end
            end

            local guildDataByTraderName2 = savedVars and savedVars.guildDataByTraderName or nil
            for i = 1, #traderNames do
                local traderName = traderNames[i]
                if traderName and not present[traderName] then
                    local data = (guildDataByTraderName2 and guildDataByTraderName2[traderName]) or nil
                    outlawMatches[#outlawMatches + 1] = data or
                        {
                            guildId = 0,
                            guildName = traderName,
                            traderName = traderName,
                            memberCount = 0,
                        }
                end
            end
        end
    end

    if #matches == 0 and #outlawMatches == 0 then
        return
    end

    SortGuildsLargestFirst(matches)
    SortGuildsLargestFirst(outlawMatches)

    local GuildUtils = SmartTrader and SmartTrader.GuildUtils

    ---@param title string
    ---@param list CachedGuildData[]
    local function AppendTraderCategoryLines(title, list)
        if not list or #list == 0 then
            return
        end

        tooltip:AddLine(title, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())

        local countToShow = math.min(#list, MAX_CITY_TRADERS_TO_LOG)
        for i = 1, countToShow do
            local data = list[i]
            local fallback = data and (data.traderName or data.guildName) or nil
            local text = nil
            if GuildUtils and GuildUtils.FormatGuildDisplayText then
                text = GuildUtils.FormatGuildDisplayText(data, fallback)
            end
            text = text or fallback or "(unknown)"
            tooltip:AddLine(text, "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        end

        if #list > countToShow then
            tooltip:AddLine(string.format("... +%d more", #list - countToShow), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        end
    end

    if tooltip.AddVerticalPadding then
        tooltip:AddVerticalPadding(10)
    else
        tooltip:AddLine(" ", "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end

    AppendTraderCategoryLines("Guild Traders", matches)

    if #outlawMatches > 0 then
        if tooltip.AddVerticalPadding then
            tooltip:AddVerticalPadding(10)
        else
            tooltip:AddLine(" ", "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
        end
        AppendTraderCategoryLines("Outlaw Traders", outlawMatches)
    end
end

local function TryHookWayshrineTooltipKeyboard()
    ---@type any
    local tooltip = rawget(_G, "InformationTooltip")
    if not tooltip then
        return false
    end

    if tooltip.__SmartTraderWayshrineKeyboardHooked then
        return true
    end

    if type(tooltip.AppendWayshrineTooltip) ~= "function" then
        return false
    end

    tooltip.__SmartTraderWayshrineKeyboardHooked = true

    local originalAppendWayshrineTooltip = tooltip.AppendWayshrineTooltip
    tooltip.AppendWayshrineTooltip = function(self, pin, ...)
        originalAppendWayshrineTooltip(self, pin, ...)

        -- Only augment keyboard tooltips.
        if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
            return
        end

        if not pin or not pin.GetFastTravelNodeIndex then
            return
        end

        local nodeIndex = pin:GetFastTravelNodeIndex()
        if not nodeIndex then
            return
        end

        AppendSmartTraderCityTraderLinesForWayshrineNodeIndexKeyboard(self, nodeIndex)
    end

    return true
end

local function TryHookWayshrineTooltipGamepad()
    -- IMPORTANT:
    -- `ZO_MapLocationTooltip_Gamepad` is mixed with ZO_MapInformationTooltip_Gamepad_Mixin at UI init time.
    -- Those functions are copied onto the control, so hooking the mixin table later won't affect the live tooltip.
    ---@type any
    local tooltip = rawget(_G, "ZO_MapLocationTooltip_Gamepad")
    if not tooltip then
        return false
    end

    if tooltip.__SmartTraderWayshrineHooked then
        return true
    end

    if type(tooltip.AppendWayshrineTooltip) ~= "function" then
        return false
    end

    tooltip.__SmartTraderWayshrineHooked = true

    local originalAppendWayshrineTooltip = tooltip.AppendWayshrineTooltip
    tooltip.AppendWayshrineTooltip = function(self, pin, ...)
        originalAppendWayshrineTooltip(self, pin, ...)

        -- Only augment the gamepad world map right-panel tooltip (works for world/zone/city map levels).
        if not IsInGamepadPreferredMode() or not SCENE_MANAGER:IsCurrentSceneGamepad() or not ZO_WorldMap_IsWorldMapShowing() then
            return
        end

        if not self or not self.tooltip or type(self.tooltip.AcquireSection) ~= "function" then
            return
        end

        if not pin or not pin.GetFastTravelNodeIndex then
            return
        end

        local nodeIndex = pin:GetFastTravelNodeIndex()
        if not nodeIndex then
            return
        end
        AppendSmartTraderCityTraderSectionsForWayshrineNodeIndex(self, nodeIndex)
    end

    return true
end

local function TryHookSuggestionActivityTooltipGamepad()
    ---@type any
    local tooltip = rawget(_G, "ZO_MapLocationTooltip_Gamepad")
    if not tooltip then
        return false
    end

    if tooltip.__SmartTraderSuggestionActivityHooked then
        return true
    end

    if type(tooltip.AppendSuggestionActivity) ~= "function" then
        return false
    end

    tooltip.__SmartTraderSuggestionActivityHooked = true

    local originalAppendSuggestionActivity = tooltip.AppendSuggestionActivity
    tooltip.AppendSuggestionActivity = function(self, pin, ...)
        originalAppendSuggestionActivity(self, pin, ...)

        -- Only augment the gamepad world map right-panel tooltip.
        if not IsInGamepadPreferredMode() or not SCENE_MANAGER:IsCurrentSceneGamepad() or not ZO_WorldMap_IsWorldMapShowing() then
            return
        end

        if not self or not self.tooltip or type(self.tooltip.AcquireSection) ~= "function" then
            return
        end

        if not pin then
            return
        end

        local Lookup = SmartTrader and SmartTrader.LookupActions
        if not Lookup then
            return
        end

        local nodeIndex = nil

        -- Some pins may still expose a fast travel node index.
        if pin.GetFastTravelNodeIndex then
            nodeIndex = pin:GetFastTravelNodeIndex()
        end

        -- Prefer POI indices when available (works for some suggestion pins).
        if not nodeIndex and Lookup.ResolveWayshrineNodeIndexByPOI then
            local poiZoneIndex = pin.GetPOIZoneIndex and pin:GetPOIZoneIndex() or nil
            local poiIndex = pin.GetPOIIndex and pin:GetPOIIndex() or nil
            if type(poiZoneIndex) == "number" and type(poiIndex) == "number" then
                nodeIndex = Lookup.ResolveWayshrineNodeIndexByPOI(poiZoneIndex, poiIndex)
            end
        end

        -- Zone story / zone guide pins often carry an activityId; try mapping that to POI indices.
        if not nodeIndex and Lookup.ResolveWayshrineNodeIndexByPOI and GetPOIIndices and pin.m_PinTag and
            type(pin.m_PinTag) == "table" then
            local activityId = pin.m_PinTag[3]
            if type(activityId) == "number" then
                local poiZoneIndex, poiIndex = GetPOIIndices(activityId)
                if type(poiZoneIndex) == "number" and type(poiIndex) == "number" then
                    nodeIndex = Lookup.ResolveWayshrineNodeIndexByPOI(poiZoneIndex, poiIndex)
                end
            end
        end

        -- Fallback: match by map position against lookup-table wayshrines.
        if not nodeIndex and Lookup.ResolveWayshrineNodeIndexByMapPosition and GetCurrentMapId and pin.GetNormalizedPosition then
            local mapId = GetCurrentMapId()
            local x, y = pin:GetNormalizedPosition()
            nodeIndex = Lookup.ResolveWayshrineNodeIndexByMapPosition(mapId, x, y)
        end

        if not nodeIndex then
            return
        end

        AppendSmartTraderCityTraderSectionsForWayshrineNodeIndex(self, nodeIndex)
    end

    return true
end

-- Hook ZO_WorldMapManager:UpdatePinTooltips to log hovered pins (class-level so it works even if WORLD_MAP_MANAGER isn't ready yet)
local function TryHookUpdatePinTooltips()
    if not ZO_WorldMapManager or type(ZO_WorldMapManager.UpdatePinTooltips) ~= "function" then
        return false
    end

    if ZO_WorldMapManager.__SmartTraderHoverLogHooked then
        return true
    end

    ZO_WorldMapManager.__SmartTraderHoverLogHooked = true

    local originalUpdatePinTooltips = ZO_WorldMapManager.UpdatePinTooltips
    ZO_WorldMapManager.UpdatePinTooltips = function(self, ...)
        -- Advance a tooltip-cycle id so our wayshrine augmentation dedupes per refresh instead of permanently.
        ---@type any
        local tooltip = rawget(_G, "ZO_MapLocationTooltip_Gamepad")
        if tooltip then
            tooltip.__SmartTraderTooltipCycleId = (tooltip.__SmartTraderTooltipCycleId or 0) + 1
        end

        local result = originalUpdatePinTooltips(self, ...)

        -- Only log if hover logging is enabled
        local getPins = self and self["GetFoundTooltipMouseOverPins"] or nil
        if IsHoverLogEnabled() and type(getPins) == "function" then
            local pins = getPins(self)
            if pins then
                for i = 1, #pins do
                    LogHoveredPin(pins[i])
                end
            end
        end

        return result
    end

    return true
end

--- Initialize map tooltip hooks
function SmartTrader.MapActions.Initialize()
    -- Hook the actual gamepad map tooltip panel so it shows guild name + size (like the 3D reticle).
    if not TryHookMapLocationTooltipGamepad() then
        zo_callLater(function()
            TryHookMapLocationTooltipGamepad()
        end, 1000)
    end

    -- Also augment wayshrine tooltips (information tooltip mode) to append cached city traders.
    if not TryHookWayshrineTooltipGamepad() then
        zo_callLater(function()
            TryHookWayshrineTooltipGamepad()
        end, 1000)
    end

    -- Also augment keyboard wayshrine tooltips (InformationTooltip) for the same trader lists.
    if not TryHookWayshrineTooltipKeyboard() then
        zo_callLater(function()
            TryHookWayshrineTooltipKeyboard()
        end, 1000)
    end

    -- Augment zone guide / suggestion pins (including addon-provided undiscovered wayshrine pins).
    if not TryHookSuggestionActivityTooltipGamepad() then
        zo_callLater(function()
            TryHookSuggestionActivityTooltipGamepad()
        end, 1000)
    end

    -- Hook UpdatePinTooltips for hover logging
    if not TryHookUpdatePinTooltips() then
        zo_callLater(function()
            TryHookUpdatePinTooltips()
        end, 1000)
    end
end

--- Clean up map tooltip hooks
function SmartTrader.MapActions.Shutdown()
    -- (no-op) We patch tooltip methods on the live control; they remain for the session.
end

-- -----------------------------------------------------------------------------
-- Hover Logging API (used by slash commands)
-- -----------------------------------------------------------------------------

---@return boolean
function SmartTrader.MapActions.IsHoverLogEnabled()
    return IsHoverLogEnabled()
end

---@param enabled boolean
function SmartTrader.MapActions.SetHoverLogEnabled(enabled)
    SetHoverLogEnabled(enabled)
    if enabled then
        -- Ensure the hook is installed even if the map manager is initialized after addon load.
        TryHookUpdatePinTooltips()
    end
end

---@return string[]
function SmartTrader.MapActions.GetHoverLogLines()
    return GetHoverLogLines()
end

---@return number
function SmartTrader.MapActions.GetHoverLogCount()
    return GetHoverLogCount()
end

--- Clear the hover log buffer without disabling
function SmartTrader.MapActions.ClearHoverLog()
    if SmartTrader and SmartTrader.state and SmartTrader.state.mapState then
        SmartTrader.state.mapState.hoverLogSeenKeys = {}
        SmartTrader.state.mapState.hoverLogLines = {}
        SmartTrader.state.mapState.hoverLogKeys = {}
        SmartTrader.state.mapState.hoverLogBytes = 0
    end
end

---@param data CachedGuildData|nil
---@param cityFormatIndex CityLocationFormatIndex|nil Optional pre-built index (for performance when resolving many guilds)
---@return table
function SmartTrader.MapActions.DebugResolveCachedLocation(data, cityFormatIndex)
    local rawLocation = data and data.city
    local wholeKey, firstKey, lastKey = GetLocationKeyVariants(rawLocation)

    -- Build index only if not provided (for backward compatibility and single-call performance)
    if not cityFormatIndex then
        local guildDataById = SmartTrader and SmartTrader.state and SmartTrader.state.savedVars and
            SmartTrader.state.savedVars.guildDataById or nil
        cityFormatIndex = SmartTrader.MapActions.BuildCityLocationFormatIndex(guildDataById)
    end

    local locationKey, zoneIndex, zoneId, parentZoneId, isOutlaw, baseCityKey = ResolveCachedLocation(data,
        cityFormatIndex)

    return {
        rawLocation = rawLocation,
        wholeKey = wholeKey,
        firstKey = firstKey,
        lastKey = lastKey,
        locationKey = locationKey,
        zoneIndex = zoneIndex,
        zoneId = zoneId,
        parentZoneId = parentZoneId,
        isOutlaw = isOutlaw,
        baseCityKey = baseCityKey,
    }
end
