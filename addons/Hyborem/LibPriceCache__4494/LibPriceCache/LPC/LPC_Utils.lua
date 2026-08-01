-- LPC_Utils.lua
LibPriceCache = LibPriceCache or {}
LibPriceCache.Utils = LibPriceCache.Utils or {}
local U = LibPriceCache.Utils

function U:GetTTC(link)
    if not TamrielTradeCentrePrice then return nil end
    local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(link)
    if not priceInfo then return nil end
    local price = priceInfo.SuggestedPrice
    if not price or price <= 0 then price = priceInfo.Avg end
    if price and price > 0 then
        return {
            price = price,
            timestamp = GetTimeStamp(),
            source = "TTC",
            listings = priceInfo.EntryCount
        }
    end
    return nil
end

function U:GetMM(link)
    if not MasterMerchant or not MasterMerchant.itemStats then return nil end
    local itemInfo = MasterMerchant:itemStats(link, false)
    if not itemInfo then return nil end
    if itemInfo.avgPrice and itemInfo.avgPrice > 0 then
        return {
            price = itemInfo.avgPrice,
            timestamp = GetTimeStamp(),
            source = "MM",
            saleCount = itemInfo.numSales
        }
    end
    return nil
end

local function GetATTSalesModule()
    if not ArkadiusTradeTools then return nil end
    if ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
        return ArkadiusTradeTools.Modules.Sales
    end
    return nil
end

function U:GetATT(link, daysBack)
    local attSales = GetATTSalesModule()
    if not attSales then return nil end
    daysBack = daysBack or 30
    local fromTimeStamp = GetTimeStamp() - (daysBack * 86400)
    local normalizedLink = link
    if attSales.NormalizeItemLink then
        local success, result = pcall(attSales.NormalizeItemLink, attSales, link)
        if success and result then normalizedLink = result end
    end
    if not normalizedLink then return nil end
    local avgPrice = attSales:GetAveragePricePerItem(normalizedLink, fromTimeStamp)
    if avgPrice and avgPrice > 0 then
        return {
            price = avgPrice,
            timestamp = GetTimeStamp(),
            source = "ATT",
            daysBack = daysBack
        }
    end
    return nil
end

function U:GetESOHub(link, bagId, slotIndex)
    if not LibEsoHubPrices then return nil end
    if not link or link == "" then return nil end
    local normalizedLink = link
    if bagId == 255 and slotIndex then
        local itemId = GetItemLinkItemId(link)
        if itemId and itemId > 0 then
            normalizedLink = string.format('|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', itemId)
        end
    end
    local price = LibEsoHubPrices.GetSimpleItemPrice(normalizedLink)
    if not price or price <= 0 then
        local priceData = LibEsoHubPrices.GetItemPriceData(normalizedLink)
        if priceData then price = priceData.averageSales or priceData.suggestedSalesPriceMin or priceData.averageListing end
    end
    if price and price > 0 then
        return {
            price = price,
            timestamp = GetTimeStamp(),
            source = "ESO-Hub"
        }
    end
    return nil
end

local function ParseItemLinkForUESP(link)
    if not link or link == "" then return nil end
    local linkData = {}
    linkData.linkType, linkData.itemText, linkData.itemId, linkData.internalSubType, linkData.internalLevel,
    linkData.enchantId, linkData.enchantSubtype, linkData.enchantLevel, linkData.writ1, linkData.writ2,
    linkData.writ3, linkData.writ4, linkData.writ5, linkData.writ6, linkData.zero1, linkData.zero2,
    linkData.zero3, linkData.style, linkData.crafted, linkData.bound, linkData.stolen, linkData.charges,
    linkData.potionData, linkData.itemName = link:match("|H(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-):(.-)|h(.-)|h")
    if not linkData.linkType then return nil end
    linkData.itemId = tonumber(linkData.itemId)
    linkData.internalSubType = tonumber(linkData.internalSubType)
    linkData.internalLevel = tonumber(linkData.internalLevel)
    linkData.enchantId = tonumber(linkData.enchantId)
    linkData.enchantSubtype = tonumber(linkData.enchantSubtype)
    linkData.enchantLevel = tonumber(linkData.enchantLevel)
    linkData.writ1 = tonumber(linkData.writ1)
    linkData.writ2 = tonumber(linkData.writ2)
    linkData.writ3 = tonumber(linkData.writ3)
    linkData.writ4 = tonumber(linkData.writ4)
    linkData.writ5 = tonumber(linkData.writ5)
    linkData.writ6 = tonumber(linkData.writ6)
    linkData.style = tonumber(linkData.style)
    linkData.crafted = tonumber(linkData.crafted)
    linkData.bound = tonumber(linkData.bound)
    linkData.stolen = tonumber(linkData.stolen)
    linkData.charges = tonumber(linkData.charges)
    linkData.potionData = tonumber(linkData.potionData)
    return linkData
end

function U:GetUESP(link)
    if not uespLog or not uespLog.SalesPrices then return nil end
    local linkData = ParseItemLinkForUESP(link)
    if not linkData then return nil end
    local levelData = uespLog.SalesPrices[linkData.itemId]
    if not levelData then return nil end
    local quality = GetItemLinkDisplayQuality(link)
    local trait = GetItemLinkTraitInfo(link) or 0
    local level = GetItemLinkRequiredLevel(link)
    local reqCP = GetItemLinkRequiredChampionPoints(link)
    if reqCP > 0 then level = 50 + math.floor(reqCP / 10) end
    local qualityData = levelData[level]
    if not qualityData then return nil end
    local traitData = qualityData[quality]
    if not traitData then return nil end
    local potionKey = linkData.potionData
    if linkData.writ1 and linkData.writ1 > 0 then
        potionKey = string.format("%d:%d:%d:%d:%d:%d", linkData.writ1, linkData.writ2, linkData.writ3, linkData.writ4, linkData.writ5, linkData.writ6)
    end
    local salesData = traitData[trait] and traitData[trait][potionKey]
    if not salesData then return nil end
    local price = salesData[2] or salesData[1]
    if not price or price <= 0 then return nil end
    return { price = price, timestamp = GetTimeStamp(), source = "UESP" }
end

function U:DebugUESPFull(link)
    local testLink = link or "|H0:item:54177:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    LibPriceCache.Report:Log("=== UESP FULL DIAGNOSTIC ===")
    LibPriceCache.Report:Log("uespLog exists: " .. tostring(uespLog ~= nil))
    if uespLog and uespLog.SalesPrices then
        local count = 0
        for _ in pairs(uespLog.SalesPrices) do count = count + 1 end
        LibPriceCache.Report:Log("SalesPrices count: " .. count)
        local itemId = GetItemLinkItemId(testLink)
        LibPriceCache.Report:Log("Test itemId: " .. tostring(itemId))
        local data = uespLog.SalesPrices[itemId]
        LibPriceCache.Report:Log("Data for itemId " .. itemId .. ": " .. tostring(data))
        if data then
            for k, v in pairs(data) do LibPriceCache.Report:Log("  " .. tostring(k) .. " = " .. tostring(v)) end
        end
    end
    if uespLog and uespLog.FindSalesPrice then
        local result = uespLog.FindSalesPrice(testLink)
        LibPriceCache.Report:Log("FindSalesPrice result: " .. tostring(result))
    end
end

SLASH_COMMANDS["/lpcdbguesp"] = function()
    if LibPriceCache.Utils then LibPriceCache.Utils:DebugUESPFull() end
end