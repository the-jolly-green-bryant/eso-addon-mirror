WritStylePrice.Price = {}

-- @var table All saved variables dedicated to the price system.
WritStylePrice.Price.savedVars = nil

--[[
-- @var table The list of all items with a price.
-- ItemLink is the key
-- The value is also a table, where the source is the key, and value a table with all info about the price
--
-- Note : The list is not saved.
--]]
WritStylePrice.Price.list = {}

--[[
-- Initialise data used by the price system
--]]
function WritStylePrice.Price:init()
    self.savedVars = WritStylePrice.savedVariables.price

    self:initSavedVarsValues()
end

--[[
-- Initialise with a default value all saved variables dedicated to the sort system
--]]
function WritStylePrice.Price:initSavedVarsValues()
    if self.savedVars.order == nil then
        self.savedVars.order = {
            LibPrice.TTC,
            LibPrice.MM,
            LibPrice.ATT,
            LibPrice.CROWN,
            LibPrice.ROLIS
        }
    end
end

--[[
-- Obtain the current order to use
--
-- @return table
--]]
function WritStylePrice.Price:obtainOrder()
    return self.savedVars.order
end

--[[
-- Define a new order to use and refresh the UI list
--
-- @param integer pos The order priority index (1 to 3)
-- @param string value The order type to use
--]]
function WritStylePrice.Price:defineOrder(pos, value)
    self.savedVars.order[pos] = value
    WritStylePrice.GUI:refreshList()
end

--[[
-- Generate the price's table for the itemLink and add it to self.list
--
-- @param string itemLink
--]]
function WritStylePrice.Price:generatePrices(itemLink)
    local itemPrices = {}

    local priceList = LibPrice.ItemLinkToPriceData(itemLink)

    if priceList.ttc ~= nil then
        self:addPrice(itemPrices, LibPrice.TTC, priceList.ttc.Avg, "gold")
    end
    if priceList.mm ~= nil then
        self:addPrice(itemPrices, LibPrice.MM, priceList.mm.avgPrice, "gold")
    end
    if priceList.att ~= nil then
        self:addPrice(itemPrices, LibPrice.ATT, priceList.att.avgPrice, "gold")
    end
    if priceList.crown ~= nil then
        self:addPrice(itemPrices, LibPrice.CROWN, priceList.crown.crowns, "crown")
    end
    if priceList.rolis ~= nil then
        self:addPrice(itemPrices, LibPrice.ROLIS, priceList.rolis.vouchers, "vouchers")
    end

    self.list[itemLink] = itemPrices
end

--[[
-- Add a new price source to priceTable
--
-- @param table priceTable The table of price where to add the new price
-- @param string source
-- @param number price
-- @param string currency
--]]
function WritStylePrice.Price:addPrice(priceTable, source, price, currency)
    local currencyIcon = ""
    if currency == "gold" then
        currencyIcon = " |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
    elseif currency == "crown" then
        currencyIcon = " |t16:16:EsoUI/Art/currency/currency_crown.dds|t"
    elseif currency == "vouchers" then
        currencyIcon = " |t16:16:EsoUI/Art/currency/currency_writvoucher.dds|t"
    end

    priceTxt = ZO_LocalizeDecimalNumber(math.floor(price + 0.5))..currencyIcon

    priceTable[source] = {
        price    = price,
        priceTxt = priceTxt,
        currency = currency
    }
end

--[[
-- Obtain the price list for a specific itemLink
--
-- @param string itemLink
--
-- @return table|nil
--]]
function WritStylePrice.Price:obtainPriceList(itemLink)
    return self.list[itemLink]
end

--[[
-- Obtain the preferred price for a specific itemLink
--
-- @param sting itemLink
--
-- @return number|nil, string
--]]
function WritStylePrice.Price:obtainPreferredPrice(itemLink)
    local prefPriceVal = nil
    local prefPriceTxt = ""
    local priceList    = self.list[itemLink]

    if priceList ~= nil then
        for order, preferredSource in pairs(self.savedVars.order) do
            if prefPriceVal == nil then
                if priceList[preferredSource] ~= nil then
                    local priceData = priceList[preferredSource]

                    prefPriceVal = priceData.price
                    prefPriceTxt = priceData.priceTxt
                end
            end
        end
    end

    return prefPriceVal, prefPriceTxt
end

--[[
-- Convert a price source key to the translated human name
--
-- @param string sourceKey
--
-- @return string
--]]
function WritStylePrice.Price:convertSourceKeyToStr(sourceKey)
    if sourceKey == LibPrice.TTC then
        return GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_TTC)
    elseif sourceKey == LibPrice.MM then
        return GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_MM)
    elseif sourceKey == LibPrice.ATT then
        return GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_ATT)
    elseif sourceKey == LibPrice.CROWN then
        return GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_CROWN)
    elseif sourceKey == LibPrice.ROLIS then
        return GetString(SI_WRITSTYLEPRICE_SETTINGS_PREFERRED_PRICE_LIST_ROLIS)
    end
    
    return GetString(SI_WRITSTYLEPRICE_UNKNOWN)
end
