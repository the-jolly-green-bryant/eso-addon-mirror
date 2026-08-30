ShoppingListPriceData = {}

local PriceData = ShoppingListPriceData
local SOURCE_ORDER = { "ttc", "esohub", "mm", "att" }

local function normalizePrice(value)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value <= 0 then
        return nil
    end
    return math.min(
        ShoppingListModel.MAX_PRICE,
        math.max(1, math.floor(value + 0.5))
    )
end

local function safely(callback)
    local ok, value = pcall(callback)
    return ok and normalizePrice(value) or nil
end

local function getTTCPrice(itemLink)
    if type(TamrielTradeCentrePrice) ~= "table"
        or type(TamrielTradeCentrePrice.GetPriceInfo) ~= "function"
    then
        return nil
    end
    return safely(function()
        local info = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
        return info and (info.SuggestedPrice or info.Avg)
    end)
end

local function getEsoHubPrice(itemLink)
    if type(LibEsoHubPrices) ~= "table"
        or type(LibEsoHubPrices.GetSimpleItemPrice) ~= "function"
    then
        return nil
    end
    return safely(function()
        return LibEsoHubPrices.GetSimpleItemPrice(itemLink)
    end)
end

local function getMasterMerchantPrice(itemLink)
    if type(MasterMerchant) == "table"
        and type(MasterMerchant.GetTooltipStats) == "function"
    then
        local price = safely(function()
            local info = MasterMerchant:GetTooltipStats(itemLink, true, false)
            return info and info.avgPrice
        end)
        if price then
            return price
        end
    end
    if type(LibPrice) == "table"
        and type(LibPrice.ItemLinkToPriceGold) == "function"
    then
        return safely(function()
            return LibPrice.ItemLinkToPriceGold(itemLink, "mm")
        end)
    end
end

local function getArkadiusPrice(itemLink)
    local sales = type(ArkadiusTradeTools) == "table"
        and type(ArkadiusTradeTools.Modules) == "table"
        and ArkadiusTradeTools.Modules.Sales or nil
    if type(sales) == "table"
        and type(sales.GetAveragePricePerItem) == "function"
    then
        for _, days in ipairs({ 3, 90 }) do
            local price = safely(function()
                return sales:GetAveragePricePerItem(
                    itemLink,
                    GetTimeStamp() - (ZO_ONE_DAY_IN_SECONDS * days)
                )
            end)
            if price then
                return price
            end
        end
    end
    if type(LibPrice) ~= "table"
        or type(LibPrice.ItemLinkToPriceGold) ~= "function"
    then
        return nil
    end
    return safely(function()
        return LibPrice.ItemLinkToPriceGold(itemLink, "att")
    end)
end

local READERS = {
    ttc = getTTCPrice,
    esohub = getEsoHubPrice,
    mm = getMasterMerchantPrice,
    att = getArkadiusPrice,
}

local LABELS = {
    ttc = SI_SHOPPING_LIST_PRICE_SOURCE_TTC,
    esohub = SI_SHOPPING_LIST_PRICE_SOURCE_ESOHUB,
    mm = SI_SHOPPING_LIST_PRICE_SOURCE_MM,
    att = SI_SHOPPING_LIST_PRICE_SOURCE_ATT,
}

function PriceData:New()
    return setmetatable({}, { __index = self })
end

function PriceData:GetSuggestion(itemLink, preferredSource)
    if type(itemLink) ~= "string" or itemLink == "" then
        return nil
    end

    local sources = SOURCE_ORDER
    if preferredSource and preferredSource ~= "auto" then
        if not READERS[preferredSource] then
            return nil
        end
        sources = { preferredSource }
    end

    for _, source in ipairs(sources) do
        local price = READERS[source](itemLink)
        if price then
            return {
                price = price,
                source = source,
                sourceName = GetString(LABELS[source]),
            }
        end
    end
end

function PriceData:IsSupportedSource(source)
    return source == "auto" or READERS[source] ~= nil
end
