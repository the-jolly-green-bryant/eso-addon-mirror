-- LPC_Cache.lua
LibPriceCache = LibPriceCache or {}
LibPriceCache.Cache = LibPriceCache.Cache or {}
local C = LibPriceCache.Cache

C.SOURCE_NAMES = {"TTC", "MM", "ATT", "ESO_Hub", "UESP"}

function C:SerializeItemData(dataTable)
    local parts = {}
    for i, source in ipairs(C.SOURCE_NAMES) do
        local entry = dataTable[source]
        if entry and entry.timestamp and entry.price then
            local priceStr = string.format("%.2f", entry.price)
            parts[#parts+1] = string.format("%d:%s", entry.timestamp, priceStr)
        else
            parts[#parts+1] = "x"
        end
    end
    return table.concat(parts, ",")
end

function C:DeserializeItemData(str)
    if not str or str == "" then return nil end
    local result = {}
    local parts = {}
    for part in string.gmatch(str, "[^,]+") do
        parts[#parts+1] = part
    end
    for i, source in ipairs(C.SOURCE_NAMES) do
        local part = parts[i]
        if part and part ~= "x" then
            local timestamp, price = part:match("(%d+):(%d+%.?%d*)")
            if timestamp and price then
                result[source] = { timestamp = tonumber(timestamp), price = tonumber(price) }
            end
        end
    end
    return result
end

function C:SetPrice(module, itemKey, sourceName, timestamp, price)
    if not module or not module.db then return false end
    if not module.db.data then module.db.data = {} end
    local itemDataStr = module.db.data[itemKey]
    local dataTable = itemDataStr and C:DeserializeItemData(itemDataStr) or {}
    local existing = dataTable[sourceName]
    if not price or price == 0 or price == "x" then return false end
    if not existing or timestamp > existing.timestamp then
        dataTable[sourceName] = { timestamp = timestamp, price = price }
        module.db.data[itemKey] = C:SerializeItemData(dataTable)
        module.db.dirty = true
        return true
    end
    return false
end

function C:GetAllPrices(itemKey, module, maxAgeSeconds)
    if not module or not module.db then return {} end
    local itemDataStr = module.db.data[itemKey]
    if not itemDataStr then return {} end
    local dataTable = C:DeserializeItemData(itemDataStr)
    if not dataTable then return {} end
    local result = {}
    local now = GetTimeStamp()
    for sourceName, sourceData in pairs(dataTable) do
        if sourceData.price and sourceData.price > 0 then
            if not maxAgeSeconds or (now - sourceData.timestamp) <= maxAgeSeconds then
                result[#result+1] = {
                    source = sourceName,
                    price = sourceData.price,
                    timestamp = sourceData.timestamp,
                    age = now - sourceData.timestamp
                }
            end
        end
    end
    return result
end

function C:GetSourceData(module, itemKey, sourceName)
    if not module or not module.db then return nil, nil end
    local itemDataStr = module.db.data[itemKey]
    if not itemDataStr then return nil, nil end
    local dataTable = C:DeserializeItemData(itemDataStr)
    if not dataTable or not dataTable[sourceName] then return nil, nil end
    local entry = dataTable[sourceName]
    return entry.price, entry.timestamp
end

function C:SetSourceData(module, itemKey, sourceName, timestamp, price)
    return C:SetPrice(module, itemKey, sourceName, timestamp, price)
end