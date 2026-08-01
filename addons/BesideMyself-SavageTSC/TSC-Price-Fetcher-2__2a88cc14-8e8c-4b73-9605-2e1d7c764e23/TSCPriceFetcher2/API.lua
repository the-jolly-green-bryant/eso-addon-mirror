_G.TSCPriceDataAPI = _G.TSCPriceDataAPI or {}
_G.TSCTesting = false  -- Enables chunk/loaded chat messages from data files
local TSCPriceDataAPI = _G.TSCPriceDataAPI

-- World name -> global table name (TSCPriceDataXBNA, TSCPriceDataXBEU, etc.)
local WORLD_TO_SERVER = {
    ["XB1live"] = "TSCPriceDataXBNA",
    ["NA Megaserver"] = "TSCPriceDataXBNA",
    ["PTS"] = "TSCPriceDataXBNA",
    ["XB1live-eu"] = "TSCPriceDataXBEU",
    ["PS4live"] = "TSCPriceDataPSNA",
    ["PS4live-eu"] = "TSCPriceDataPSEU",
}

local function getServerGlobal()
    local worldName = GetWorldName()
    local globalKey = WORLD_TO_SERVER[worldName]
    if globalKey then
        return _G[globalKey]
    end
    return nil
end

local function getServerPriceData()
    local server = getServerGlobal()
    return (server and server.priceData) or {}
end

local function getServerLoadingSentinel()
    local server = getServerGlobal()
    return server and server.LOADING_SENTINEL or nil
end

local function getServerReferenceDate()
    local server = getServerGlobal()
    return server and server.referenceDate or nil
end

TSCPriceDataAPI.priceData = getServerPriceData()
TSCPriceDataAPI.referenceDate = getServerReferenceDate()
local _loadingSentinel = getServerLoadingSentinel()
TSCPriceDataAPI.LOADING = _loadingSentinel

-- Start loading when player is in world (GetWorldName() is valid). Single trigger for all platforms.
local function tryStartLoading()
    local server = getServerGlobal()
    if server and server.startLoading then
        server.startLoading()
    end
end

EVENT_MANAGER:RegisterForEvent("TSCPriceDataAPI", EVENT_PLAYER_ACTIVATED, function(_, _)
    EVENT_MANAGER:UnregisterForEvent("TSCPriceDataAPI", EVENT_PLAYER_ACTIVATED)
    tryStartLoading()
end)

-- Parse 18-value lazy format: quality triples (1-15), legacy triple (16-18).
-- qualityIndex is 1-5. Returns (avg, min, max, fromLegacy, legacyAvg, legacyMin, legacyMax).
local function parseQualityFromEntry(dataString, qualityIndex)
    local values = {}
    for v in string.gmatch(dataString, "([^,]+)") do
        values[#values + 1] = v
    end
    local legacyAvg = (values[16] and values[16] ~= "-" and tonumber(values[16])) or nil
    local legacyMin = (values[17] and values[17] ~= "-" and tonumber(values[17])) or nil
    local legacyMax = (values[18] and values[18] ~= "-" and tonumber(values[18])) or nil
    local baseIndex = (qualityIndex - 1) * 3 + 1
    local avgStr = values[baseIndex]
    local minStr = values[baseIndex + 1]
    local maxStr = values[baseIndex + 2]
    if avgStr and avgStr ~= "-" and tonumber(avgStr) then
        return tonumber(avgStr), tonumber(minStr), tonumber(maxStr), false, legacyAvg, legacyMin, legacyMax
    end
    local legAvg = values[16]
    local legMin = values[17]
    local legMax = values[18]
    if legAvg and legAvg ~= "-" and tonumber(legAvg) then
        return tonumber(legAvg), tonumber(legMin), tonumber(legMax), true, legacyAvg, legacyMin, legacyMax
    end
    return nil, nil, nil, false, legacyAvg, legacyMin, legacyMax
end

function TSCPriceDataAPI:FormatItemName(itemLink)
    local itemName = GetItemLinkName(itemLink)
    -- Strip ZOS formatting in one pass
    itemName = zo_strformat("<<1>>", itemName)
    return itemName
end

function TSCPriceDataAPI:GetPrice(itemLink)
    if itemLink == nil then return nil, nil end
    if type(itemLink) ~= "string" then return nil, nil end

    local itemId = GetItemLinkItemId(itemLink)
    if not itemId then return nil, nil end

    local data = self.priceData and self.priceData[itemId]
    if data == _loadingSentinel then
        return TSCPriceDataAPI.LOADING, nil
    end
    if data == nil then return nil, nil end

    if type(data) == "string" then
        local quality = GetItemLinkFunctionalQuality(itemLink)  -- 0-4
        local qualityIndex = (quality and quality >= 0) and (quality + 1) or 1
        qualityIndex = math.max(1, math.min(5, qualityIndex))
        local avgPrice, _, _, fromLegacy = parseQualityFromEntry(data, qualityIndex)
        if avgPrice then
            return avgPrice, fromLegacy
        end
    end
    return nil, nil
end

function TSCPriceDataAPI:GetItemData(itemLink)
    if itemLink == nil then return nil end
    if type(itemLink) ~= "string" then return nil end

    local itemId = GetItemLinkItemId(itemLink)
    if not itemId then return nil end

    local data = self.priceData and self.priceData[itemId]
    if data == _loadingSentinel then
        return TSCPriceDataAPI.LOADING
    end
    if data == nil then return nil end

    if type(data) == "string" then
        local quality = GetItemLinkFunctionalQuality(itemLink)  -- 0-4
        local qualityIndex = (quality and quality >= 0) and (quality + 1) or 1
        qualityIndex = math.max(1, math.min(5, qualityIndex))
        local avgPrice, commonMin, commonMax, fromLegacy, legacyAvg, legacyMin, legacyMax = parseQualityFromEntry(data, qualityIndex)
        if avgPrice then
            return {
                avgPrice = avgPrice,
                commonMin = commonMin,
                commonMax = commonMax,
                fromLegacy = fromLegacy,
                legacyAvg = legacyAvg,
                legacyMin = legacyMin,
                legacyMax = legacyMax
            }
        end
    end
    return nil
end
