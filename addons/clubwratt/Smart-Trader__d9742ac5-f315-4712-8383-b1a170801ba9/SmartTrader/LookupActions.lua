-- LookupActions.lua: Runtime query helpers over offline-generated lookup tables

local SmartTrader = SmartTrader or {}
SmartTrader.LookupActions = {}

---@param value any
---@return string|nil
local function NormalizeWhitespace(value)
    if not value or value == "" then
        return nil
    end
    local s = tostring(value)
    -- Strip ESO grammar tokens (e.g. "^F") so guild-finder strings match map-export strings.
    if zo_strformat then
        s = zo_strformat("<<1>>", s)
    end
    s = s:gsub("%^%w+", "")
    s = s:gsub("%s+", " ")
    s = s:gsub("^%s+", "")
    s = s:gsub("%s+$", "")
    if s == "" then
        return nil
    end
    return s
end

---@param value any
---@return string
local function SafeUpper(value)
    if not value then
        return ""
    end
    return string.upper(tostring(value))
end

---@param traderName string|nil
---@return string|nil traderKey
local function TraderKeyFromName(traderName)
    local name = NormalizeWhitespace(traderName)
    if not name then
        return nil
    end

    -- Exports attempt to strip grammar tokens with zo_strformat in-game; still normalize here.
    return SafeUpper(name)
end

---@param traderName string|nil
---@return string|nil kioskKey
---@return table|nil kiosk
function SmartTrader.LookupActions.ResolveKioskByTraderName(traderName)
    local key = TraderKeyFromName(traderName)
    if not key then
        return nil, nil
    end

    local tables = SmartTrader.LookupTables
    if not tables then
        return nil, nil
    end

    -- Preferred (v2.1.51+): per-trader keys.
    local traderKeysByTraderKey = tables.KioskTraderKeysByTraderKey
    local traderByKey = tables.KioskTraderByKey
    local pinByKey = tables.KioskPinByKey
    if traderKeysByTraderKey and traderByKey and pinByKey then
        local traderKeys = traderKeysByTraderKey[key]
        if traderKeys and #traderKeys > 0 then
            local kioskTraderKey = traderKeys[1]
            local traderRow = traderByKey[kioskTraderKey]
            local pinKey = traderRow and traderRow.pinKey or nil
            if pinKey then
                return pinKey, pinByKey[pinKey]
            end
        end
    end

    -- Legacy (v2.1.50): one-to-one traderKey -> pinKey.
    local byTrader = tables.KioskKeyByTraderKey
    local byKey = tables.KioskByKey
    if not byTrader or not byKey then
        return nil, nil
    end

    local kioskKey = byTrader[key]
    if not kioskKey then
        return nil, nil
    end

    return kioskKey, byKey[kioskKey]
end

---@param kioskKey string
---@return table|nil
function SmartTrader.LookupActions.GetKioskByKey(kioskKey)
    local tables = SmartTrader.LookupTables
    local byKey = tables and tables.KioskByKey
    return byKey and byKey[kioskKey] or nil
end

---@param pinKey string
---@return table|nil
function SmartTrader.LookupActions.GetKioskPinByKey(pinKey)
    local tables = SmartTrader.LookupTables
    local byKey = tables and tables.KioskPinByKey
    return byKey and byKey[pinKey] or nil
end

---@param kioskTraderKey string
---@return table|nil
function SmartTrader.LookupActions.GetKioskTraderByKey(kioskTraderKey)
    local tables = SmartTrader.LookupTables
    local byKey = tables and tables.KioskTraderByKey
    return byKey and byKey[kioskTraderKey] or nil
end

---@param traderName string|nil
---@return string[]|nil kioskTraderKeys
function SmartTrader.LookupActions.ResolveKioskTraderKeysByTraderName(traderName)
    local key = TraderKeyFromName(traderName)
    if not key then
        return nil
    end

    local tables = SmartTrader.LookupTables
    local byTraderKey = tables and tables.KioskTraderKeysByTraderKey
    if not byTraderKey then
        return nil
    end

    return byTraderKey[key]
end

---@param refugeKey string
---@return table|nil
function SmartTrader.LookupActions.GetOutlawRefugeByKey(refugeKey)
    local tables = SmartTrader.LookupTables
    local byKey = tables and tables.OutlawRefugeByKey
    return byKey and byKey[refugeKey] or nil
end

---@param nodeIndex number
---@return table|nil
function SmartTrader.LookupActions.GetWayshrineByNodeIndex(nodeIndex)
    local tables = SmartTrader.LookupTables
    local byIndex = tables and tables.WayshrineByNodeIndex
    return byIndex and byIndex[nodeIndex] or nil
end

---@param mapId number
---@return table|nil
function SmartTrader.LookupActions.GetMapById(mapId)
    local tables = SmartTrader.LookupTables
    local byId = tables and tables.MapById
    return byId and byId[mapId] or nil
end

---@param mapId number|nil
---@param locIndex number|nil
---@return string|nil pinKey
function SmartTrader.LookupActions.MakePinKey(mapId, locIndex)
    if type(mapId) ~= "number" or type(locIndex) ~= "number" then
        return nil
    end
    return string.format("%d:%d", mapId, locIndex)
end

---@param mapId number|nil
---@param locIndex number|nil
---@param lineIndex number|nil
---@return string|nil kioskTraderKey
function SmartTrader.LookupActions.MakeKioskTraderKey(mapId, locIndex, lineIndex)
    if type(mapId) ~= "number" or type(locIndex) ~= "number" or type(lineIndex) ~= "number" then
        return nil
    end
    return string.format("%d:%d:%d", mapId, locIndex, lineIndex)
end

---@param mapId number|nil
---@param locIndex number|nil
---@return table|nil
function SmartTrader.LookupActions.GetKioskPinByMapLocation(mapId, locIndex)
    local pinKey = SmartTrader.LookupActions.MakePinKey(mapId, locIndex)
    return pinKey and SmartTrader.LookupActions.GetKioskPinByKey(pinKey) or nil
end

---@param mapId number|nil
---@param locIndex number|nil
---@return table|nil
function SmartTrader.LookupActions.GetOutlawRefugeByMapLocation(mapId, locIndex)
    local pinKey = SmartTrader.LookupActions.MakePinKey(mapId, locIndex)
    return pinKey and SmartTrader.LookupActions.GetOutlawRefugeByKey(pinKey) or nil
end

-- -----------------------------------------------------------------------------
-- Outlaws Refuge / Outlaw Trader Resolution
-- -----------------------------------------------------------------------------

---@param value any
---@return boolean
local function IsOutlawRefugeText(value)
    local name = NormalizeWhitespace(value) or ""
    local upper = SafeUpper(name)
    return string.find(upper, "OUTLAW", 1, true) ~= nil and string.find(upper, "REFUGE", 1, true) ~= nil
end

---@param value any
---@return string|nil baseCityKey
local function OutlawBaseCityKeyFromText(value)
    local name = NormalizeWhitespace(value)
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

    return SafeUpper(NormalizeWhitespace(name))
end

---@param mapId number|nil
---@return string|nil baseCityKey
function SmartTrader.LookupActions.ResolveOutlawBaseCityKeyByMapId(mapId)
    if type(mapId) ~= "number" then
        return nil
    end
    local mapRow = SmartTrader.LookupActions.GetMapById(mapId)
    if not mapRow or not mapRow.mapName then
        return nil
    end
    if not IsOutlawRefugeText(mapRow.mapName) then
        return nil
    end
    return OutlawBaseCityKeyFromText(mapRow.mapName)
end

---@type table<string, string[]>|nil
local outlawTraderNamesByBaseCityKey = nil

local function EnsureOutlawTraderNamesByBaseCityKey()
    if outlawTraderNamesByBaseCityKey then
        return
    end

    outlawTraderNamesByBaseCityKey = {}

    local tables = SmartTrader.LookupTables
    local mapById = tables and tables.MapById
    local kioskTraderByKey = tables and tables.KioskTraderByKey
    if not mapById or not kioskTraderByKey then
        return
    end

    ---@type table<number, string>
    local baseCityKeyByOutlawMapId = {}
    for mapId, mapRow in pairs(mapById) do
        local key = mapRow and mapRow.mapName and OutlawBaseCityKeyFromText(mapRow.mapName) or nil
        if key and IsOutlawRefugeText(mapRow.mapName) then
            baseCityKeyByOutlawMapId[mapId] = key
        end
    end

    ---@param pinKey string|nil
    ---@return number|nil
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

    for _, traderRow in pairs(kioskTraderByKey) do
        local mapId = MapIdFromPinKey(traderRow and traderRow.pinKey or nil)
        local baseCityKey = mapId and baseCityKeyByOutlawMapId[mapId] or nil
        if baseCityKey then
            local name = traderRow and traderRow.traderName or nil
            if name and name ~= "" then
                local list = outlawTraderNamesByBaseCityKey[baseCityKey]
                if not list then
                    list = {}
                    outlawTraderNamesByBaseCityKey[baseCityKey] = list
                end
                list[#list + 1] = name
            end
        end
    end

    -- Dedupe + stable sort
    for baseCityKey, list in pairs(outlawTraderNamesByBaseCityKey) do
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
        outlawTraderNamesByBaseCityKey[baseCityKey] = uniq
    end
end

---@param baseCityKey string|nil
---@return string[]|nil traderNames
function SmartTrader.LookupActions.GetOutlawTraderNamesByBaseCityKey(baseCityKey)
    local key = SafeUpper(NormalizeWhitespace(baseCityKey))
    if not key then
        return nil
    end
    EnsureOutlawTraderNamesByBaseCityKey()
    return outlawTraderNamesByBaseCityKey and outlawTraderNamesByBaseCityKey[key] or nil
end

-- -----------------------------------------------------------------------------
-- Wayshrine Resolution Helpers (for undiscovered/custom pins)
-- -----------------------------------------------------------------------------

---@type table<string, number>|nil
local wayshrineNodeIndexByPoiKey = nil

local function EnsureWayshrineNodeIndexByPoiKey()
    if wayshrineNodeIndexByPoiKey then
        return
    end
    wayshrineNodeIndexByPoiKey = {}

    local tables = SmartTrader.LookupTables
    local byNodeIndex = tables and tables.WayshrineByNodeIndex
    if not byNodeIndex then
        return
    end

    for nodeIndex, row in pairs(byNodeIndex) do
        local zoneIndex = row and row.nodeZoneIndex or 0
        local poiIndex = row and row.nodePoiIndex or 0
        if type(zoneIndex) == "number" and zoneIndex > 0 and type(poiIndex) == "number" and poiIndex > 0 then
            local key = string.format("%d:%d", zoneIndex, poiIndex)
            if not wayshrineNodeIndexByPoiKey[key] then
                wayshrineNodeIndexByPoiKey[key] = nodeIndex
            end
        end
    end
end

---@param poiZoneIndex number|nil
---@param poiIndex number|nil
---@return number|nil nodeIndex
function SmartTrader.LookupActions.ResolveWayshrineNodeIndexByPOI(poiZoneIndex, poiIndex)
    if type(poiZoneIndex) ~= "number" or type(poiIndex) ~= "number" then
        return nil
    end
    EnsureWayshrineNodeIndexByPoiKey()
    local key = string.format("%d:%d", poiZoneIndex, poiIndex)
    return wayshrineNodeIndexByPoiKey and wayshrineNodeIndexByPoiKey[key] or nil
end

---@type table<number, table[]>|nil
local wayshrinesByMapId = nil

local function EnsureWayshrinesByMapId()
    if wayshrinesByMapId then
        return
    end
    wayshrinesByMapId = {}

    local tables = SmartTrader.LookupTables
    local byNodeIndex = tables and tables.WayshrineByNodeIndex
    if not byNodeIndex then
        return
    end

    for nodeIndex, row in pairs(byNodeIndex) do
        local mapId = row and row.mapId or nil
        local x = row and row.x or nil
        local y = row and row.y or nil
        if type(mapId) == "number" and type(x) == "number" and type(y) == "number" then
            -- Only index normalized map coords; some special maps export world coords.
            if x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                local list = wayshrinesByMapId[mapId]
                if not list then
                    list = {}
                    wayshrinesByMapId[mapId] = list
                end
                list[#list + 1] = { nodeIndex = nodeIndex, x = x, y = y }
            end
        end
    end
end

---@param mapId number|nil
---@param x number|nil
---@param y number|nil
---@return number|nil nodeIndex
function SmartTrader.LookupActions.ResolveWayshrineNodeIndexByMapPosition(mapId, x, y)
    if type(mapId) ~= "number" or type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end
    if x < 0 or x > 1 or y < 0 or y > 1 then
        return nil
    end

    EnsureWayshrinesByMapId()
    local list = wayshrinesByMapId and wayshrinesByMapId[mapId] or nil
    if not list then
        return nil
    end

    local bestNode = nil
    local bestDist2 = nil
    for i = 1, #list do
        local row = list[i]
        local dx = x - row.x
        local dy = y - row.y
        local d2 = (dx * dx) + (dy * dy)
        if (not bestDist2) or d2 < bestDist2 then
            bestDist2 = d2
            bestNode = row.nodeIndex
        end
    end

    -- Accept only tight matches to avoid misclassifying nearby POIs.
    local MAX_DIST2 = 0.0001 -- ~0.01 normalized units
    if bestDist2 and bestDist2 <= MAX_DIST2 then
        return bestNode
    end

    return nil
end
