-- LPC01.lua - Gear Database
LibPriceCache = LibPriceCache or {}
LibPriceCache.LPC01 = LibPriceCache.LPC01 or {}
local M = LibPriceCache.LPC01
M.name = "LPC01"

local serverKey = GetDisplayName() .. "_" .. GetWorldName()

function M:Init()
    M.db = LibSavedVars:NewAccountWide("LibPriceCache_LPC01_DB", "Data", {data = {}}, nil, serverKey)
    if LibPriceCache.Report then
        LibPriceCache.Report:Log("|c00FF00LPC01 initialized|r")
    end
end

function M:GetPrice(itemKey, sourceName)
    if not M.db or not M.db.data then return nil, nil end
    return LibPriceCache.Cache:GetSourceData(M, itemKey, sourceName)
end

function M:SetPrice(itemKey, sourceName, timestamp, price)
    if not M.db then return false end
    return LibPriceCache.Cache:SetSourceData(M, itemKey, sourceName, timestamp, price)
end

function M:GetAllPrices(itemKey, maxAgeSeconds)
    if not M.db then return {} end
    return LibPriceCache.Cache:GetAllPrices(itemKey, M, maxAgeSeconds)
end

function M:CleanOldData(maxAgeDays)
    if not M.db or not M.db.data then return end
    local maxAgeSeconds = maxAgeDays * 86400
    local now = GetTimeStamp()
    local cleaned = 0
    for itemKey, itemDataStr in pairs(M.db.data) do
        local dataTable = LibPriceCache.Cache:DeserializeItemData(itemDataStr)
        if dataTable then
            local hasData = false
            for sourceName, sourceData in pairs(dataTable) do
                if now - sourceData.timestamp <= maxAgeSeconds then
                    hasData = true
                else
                    dataTable[sourceName] = nil
                end
            end
            if hasData then
                M.db.data[itemKey] = LibPriceCache.Cache:SerializeItemData(dataTable)
            else
                M.db.data[itemKey] = nil
                cleaned = cleaned + 1
            end
        end
    end
    if cleaned > 0 and LibPriceCache.Report then
        LibPriceCache.Report:Log(string.format("LPC01 cleaned %d expired items", cleaned))
    end
end

EVENT_MANAGER:RegisterForEvent("LPC01_Init", EVENT_ADD_ON_LOADED, function(_, addon)
    if addon == "LibPriceCache" then
        M:Init()
    end
end)