LootTrackerSolution.TradeCenter = {}

local TradeCenter = LootTrackerSolution.TradeCenter

local TamrielTradeCentrePrice = TamrielTradeCentrePrice

function TradeCenter.Restruct(price)
    if price.TTC == nil then return price end

    local convertedTable = {
        ["TTC"] = {
            ["Average"] = price.TTC and price.TTC.Average or 0,
            ["Min"] = price.TTC and price.TTC.Min or 0,
            ["Max"] = price.TTC and price.TTC.Max or 0,
            ["SuggestedPrice"] = price.TTC and price.TTC.SuggestedPrice or 0,
        },
        ["Vendor"] = price.Vendor or 0,
        ["MasterMerchant"] = price.MasterMerchant or 0,
    }

    return convertedTable
end

function TradeCenter.SelectPriceInfo(priceInfo)
    if priceInfo == nil then
        return 0
    end

    priceInfo = TradeCenter.Restruct(priceInfo)
    local priceSource = LootTrackerSolution.LootStorageModule:GetGeneralSetting("PriceSource")
    local priceType = LootTrackerSolution.LootStorageModule:GetGeneralSetting("PriceType")

    local itemPrice = 0
    if (priceSource == 1 and LootTrackerSolution.TamrielTradeCentre) then 
        local TradePrice = priceInfo["TTC"]
        if (TradePrice ~= nil) then
            if (priceType == 1) then    
                itemPrice = TradePrice["Avg"] or 0
            elseif (priceType == 2) then 
                itemPrice = TradePrice["Min"] or 0
            elseif (priceType == 3) then 
                itemPrice = TradePrice["Max"] or 0  
            elseif (priceType == 4) then 
                itemPrice = TradePrice["SuggestedPrice"] or 0
            end
        else
            itemPrice = priceInfo["Vendor"] or 0
        end
    elseif (priceSource == 3) then 

    end

    if (priceSource == 2 or itemPrice == 0 or not LootTrackerSolution.TamrielTradeCentre) then 
        itemPrice = priceInfo["Vendor"] or 0
    end

    return itemPrice
end

function TradeCenter.GetPriceInfo(itemLink)
    local TradePrice = nil

    if (LootTrackerSolution.TamrielTradeCentre) then
        TradePrice = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    end

    local price = {}
    if TradePrice == nil then
        price = {
            TTC = {
                Average = 0,
                Min = 0,
                Max = 0,
                SuggestedPrice = 0,
            },
            Vendor = GetItemLinkValue(itemLink, true) or 0,
            MasterMerchant = 0,
        }
    else
        price = {
            TTC = {
                Average = TradePrice.Avg or 0,
                Min = TradePrice.Min or 0,
                Max = TradePrice.Max or 0,
                SuggestedPrice = TradePrice.SuggestedPrice or 0,
            },
            Vendor = GetItemLinkValue(itemLink, true) or 0,
            MasterMerchant = 0,
        }
    end
    return price
end

function TradeCenter.GetPrice(itemLink)
    local priceSource = LootTrackerSolution.LootStorageModule:GetGeneralSetting("PriceSource")
    local priceType = LootTrackerSolution.LootStorageModule:GetGeneralSetting("PriceType")

    local itemPrice = 0

    if (priceSource == 1 and LootTrackerSolution.TamrielTradeCentre) then 
        local TradePrice = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
        if (TradePrice ~= nil) then
            if (priceType == 1) then    
                itemPrice = TradePrice.Avg or 0
            elseif (priceType == 2) then 
                itemPrice = TradePrice.Min or 0
            elseif (priceType == 3) then 
                itemPrice = TradePrice.Max or 0
            elseif (priceType == 4) then 
                itemPrice = TradePrice.SuggestedPrice or 0
            end
        else
            itemPrice = GetItemLinkValue(itemLink, true) or 0
        end
    elseif (priceSource == 3) then 

    elseif (priceSource == 2 or not LootTrackerSolution.TamrielTradeCentre) then 
        itemPrice = GetItemLinkValue(itemLink, true) or 0
    end

    return itemPrice
end