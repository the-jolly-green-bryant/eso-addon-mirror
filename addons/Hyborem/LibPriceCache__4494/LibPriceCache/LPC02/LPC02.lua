-- LPC02.lua - Items Database
LibPriceCache = LibPriceCache or {}
LibPriceCache.LPC02 = LibPriceCache.LPC02 or {}
local M = LibPriceCache.LPC02
M.name = "LPC02"

local serverKey = GetDisplayName() .. "_" .. GetWorldName()

function M:Init()
    M.db = LibSavedVars:NewAccountWide("LibPriceCache_LPC02_DB", "Data", {data = {}}, nil, serverKey)
    if LibPriceCache.Report then
        LibPriceCache.Report:Log("|c00FF00LPC02 initialized|r")
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

EVENT_MANAGER:RegisterForEvent("LPC02_Init", EVENT_ADD_ON_LOADED, function(_, addon)
    if addon == "LibPriceCache" then
        M:Init()
    end
end)