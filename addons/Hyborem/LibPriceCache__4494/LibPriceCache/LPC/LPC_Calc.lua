-- LPC_Calc.lua (żółte źródła, zielony LPC w gamepadzie)
LibPriceCache = LibPriceCache or {}
LibPriceCache.Calc = LibPriceCache.Calc or {}
local C = LibPriceCache.Calc

local lastTooltipLink = nil
local lastTooltipTime = 0

local function RoundForDisplay(v)
    if not v or type(v) ~= "number" then return 0 end
    return math.floor(v * 100 + 0.5) / 100
end

function C:FormatPrice(price, gamepad)
    if not price or price <= 0 then return "no data" end
    local rounded = RoundForDisplay(price)
    return ZO_Currency_FormatKeyboard(CURT_MONEY, rounded, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
end

function C:FormatDate(timestamp)
    if not timestamp or timestamp == 0 then return "" end
    return os.date("%Y-%m-%d", timestamp)
end

function C:AddPriceLinesToTooltip(tooltip, itemLink, gamepad)
    if not tooltip or not itemLink then return end

    local now = GetFrameTimeSeconds()
    if itemLink == lastTooltipLink and (now - lastTooltipTime) < 0.2 then
        return
    end
    lastTooltipLink = itemLink
    lastTooltipTime = now

    local core = LibPriceCache.Core
    if not core or not core.db then return end
    local db = core.db
    local isBound = IsItemLinkBound(itemLink)
    local maxAge = db.MaxPriceAgeDays * 86400
    local allPrices = C:GetAllPricesWithStatus(itemLink, maxAge, isBound)

    if not gamepad then
        tooltip:AddVerticalPadding(4)
    end

    for sourceName, sourceData in pairs(allPrices) do
        if sourceData and sourceData.show then
            if gamepad then
                local coloredText = string.format("|cFFD700%s|r", sourceData.text)
                tooltip:AddLine(coloredText, ZO_TOOLTIP_STYLES["topSection"])
            else
                local color = db.TooltipPriceInfoColor
                tooltip:AddLine(sourceData.text, "ZoFontWinH4", color.Red, color.Green, color.Blue, TOPLEFT)
            end
        end
    end

    if not isBound and db.UseAveragePrice then
        local avg = C:GetAveragePrice(itemLink, maxAge, allPrices)
        if avg and avg > 0 then
            local priceStr = C:FormatPrice(avg, gamepad)
            if not priceStr then priceStr = "no data" end
            if gamepad then
                local coloredText = string.format("|c00FF00LPC (avg): %s|r", priceStr)
                tooltip:AddLine(coloredText, ZO_TOOLTIP_STYLES["topSection"])
            else
                local color = db.TooltipColor
                tooltip:AddLine("LPC (avg): " .. priceStr, "ZoFontWinH4", color.Red, color.Green, color.Blue, TOPLEFT)
            end
        else
            local hasAnyData = C:HasAnyPriceData(itemLink)
            if not hasAnyData then
                if gamepad then
                    local coloredText = "|cFF8888LPC (avg): no data|r"
                    tooltip:AddLine(coloredText, ZO_TOOLTIP_STYLES["topSection"])
                else
                    local color = db.TooltipPriceInfoColor
                    tooltip:AddLine("LPC (avg): |cFF8888no data|r", "ZoFontWinH4", color.Red, color.Green, color.Blue, TOPLEFT)
                end
            end
        end
    end

    if not gamepad then
        tooltip:AddVerticalPadding(2)
    end
end

function C:GetAllPricesWithStatus(itemLink, maxAgeSeconds, isBound)
    local core = LibPriceCache.Core
    if not core then return {} end
    local db = core.db
    local itemKey = core:GetID(itemLink)
    local result = {}

 if isBound then
    local vendorBuy = GetItemLinkValue(itemLink) or 0
    local vendorSell = nil
    if MasterMerchant and MasterMerchant.vendor_price_table then
        local itemId = GetItemLinkItemId(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local typeTable = MasterMerchant.vendor_price_table[itemType]
        if typeTable and typeTable[itemId] then
            vendorSell = typeTable[itemId]
        end
    end
    if vendorBuy > 0 or (vendorSell and vendorSell > 0) then
        local textParts = {}
        if vendorBuy > 0 then
            table.insert(textParts, string.format("buy %s", C:FormatPrice(vendorBuy, false)))
        end
        if vendorSell and vendorSell > 0 then
            table.insert(textParts, string.format("sell %s", C:FormatPrice(vendorSell, false)))
        end
        result["Vendor"] = {
            text = string.format("Vendor: %s", table.concat(textParts, " / ")),
            price = (vendorBuy > 0 and vendorBuy or vendorSell) or 0,
            hasData = true,
            timestamp = GetTimeStamp(),
            show = db.ShowVendorInTooltip or false,
            useInAverage = false,
        }
    end
    return result
end

    local modules = { LibPriceCache.LPC01, LibPriceCache.LPC02, LibPriceCache.LPC03, LibPriceCache.LPC04 }
    for _, mod in ipairs(modules) do
        if mod and mod.db and mod.db.data then
            local allCachedPrices = LibPriceCache.Cache:GetAllPrices(itemKey, mod, nil)
            for _, p in ipairs(allCachedPrices) do
                if not result[p.source] or p.timestamp > result[p.source].timestamp then
                    local showSource = false
                    local useInAverage = false
                    
                    if p.source == "TTC" then
                        showSource = db.ShowTTCInTooltip
                        useInAverage = db.UseTTCPrice
                    elseif p.source == "ESO_Hub" then
                        showSource = db.ShowESOHubInTooltip
                        useInAverage = db.UseESOHubPrice
                    elseif p.source == "ATT" then
                        showSource = db.ShowATTInTooltip
                        useInAverage = db.UseATTPrice
                    elseif p.source == "MM" then
                        showSource = db.ShowMMInTooltip
                        useInAverage = db.UseMMPrice
                    elseif p.source == "UESP" then
                        showSource = db.ShowUESPInTooltip
                        useInAverage = db.UseUESPPrice
                    else
                        showSource = true
                        useInAverage = true
                    end
                    
                    if showSource or useInAverage then
                        local isFresh = not maxAgeSeconds or p.age <= maxAgeSeconds
                        local ageText = ""
                        local dateText = ""
                        if p.timestamp then
                            dateText = string.format(" (%s)", C:FormatDate(p.timestamp))
                        end
                        if not isFresh then
                            ageText = string.format(" |cFF8888(old)%s|r", dateText)
                        elseif p.age and p.age > 86400 then
                            local days = math.floor(p.age / 86400)
                            ageText = string.format(" (%dd)%s", days, dateText)
                        elseif dateText ~= "" then
                            ageText = dateText
                        end
                        
                        result[p.source] = {
                            text = string.format("%s%s: %s%s", p.source, ageText, C:FormatPrice(p.price, false), not isFresh and " |cFF8888(expired)|r" or ""),
                            price = p.price,
                            hasData = true,
                            age = p.age,
                            isFresh = isFresh,
                            timestamp = p.timestamp,
                            show = showSource,
                            useInAverage = useInAverage,
                        }
                    end
                end
            end
        end
    end

    if db.UseUESPPrice then
        local uespPrice = LibPriceCache.Utils:GetUESP(itemLink)
        if uespPrice and uespPrice.price and uespPrice.price > 0 then
            result["UESP"] = {
                text = string.format("UESP: %s", C:FormatPrice(uespPrice.price, false)),
                price = uespPrice.price,
                hasData = true,
                isFresh = true,
                timestamp = uespPrice.timestamp or GetTimeStamp(),
                show = db.ShowUESPInTooltip,
                useInAverage = db.UseUESPPrice,
            }
        end
    end

    if db.ShowVendorInTooltip then
        local vendorBuy = GetItemLinkValue(itemLink) or 0
        local vendorSell = nil
        if MasterMerchant and MasterMerchant.vendor_price_table then
            local itemId = GetItemLinkItemId(itemLink)
            local itemType = GetItemLinkItemType(itemLink)
            local typeTable = MasterMerchant.vendor_price_table[itemType]
            if typeTable and typeTable[itemId] then
                vendorSell = typeTable[itemId]
            end
        end
        if vendorBuy > 0 or (vendorSell and vendorSell > 0) then
            local textParts = {}
            if vendorBuy > 0 then
                table.insert(textParts, string.format("buy %s", C:FormatPrice(vendorBuy, false)))
            end
            if vendorSell and vendorSell > 0 then
                table.insert(textParts, string.format("sell %s", C:FormatPrice(vendorSell, false)))
            end
            result["Vendor"] = {
                text = string.format("Vendor: %s", table.concat(textParts, " / ")),
                price = vendorBuy > 0 and vendorBuy or vendorSell,
                hasData = true,
                timestamp = GetTimeStamp(),
                show = true,
                useInAverage = false,
            }
        end
    end

    return result
end

function C:HasAnyPriceData(itemLink)
    local core = LibPriceCache.Core
    if not core then return false end
    local itemKey = core:GetID(itemLink)
    local modules = { LibPriceCache.LPC01, LibPriceCache.LPC02, LibPriceCache.LPC03, LibPriceCache.LPC04 }
    for _, mod in ipairs(modules) do
        if mod and mod.db and mod.db.data then
            local allPrices = LibPriceCache.Cache:GetAllPrices(itemKey, mod, nil)
            if #allPrices > 0 then return true end
        end
    end
    return false
end

function C:GetAveragePrice(itemLink, maxAgeSeconds, allPrices)
    if not allPrices then
        allPrices = C:GetAllPricesWithStatus(itemLink, maxAgeSeconds, false)
    end

    local prices = {}
    local weights = {}
    local db = LibPriceCache.Core.db

    local srcMap = {
        TTC = "Weight_TTC",
        ESO_Hub = "Weight_ESO_Hub",
        ATT = "Weight_ATT",
        MM = "Weight_MM",
        UESP = "Weight_UESP"
    }

    for src, weightKey in pairs(srcMap) do
        local weight = db[weightKey] or 1
        if weight > 0 then
            local data = allPrices[src]
            -- używa useInAverage zamiast show
            if data and data.useInAverage and data.price and data.price > 0 and data.isFresh == true then
                table.insert(prices, data.price)
                table.insert(weights, weight)
            end
        end
    end

    if #prices == 0 then return nil end

    local weightedSum = 0
    local totalWeight = 0
    for i, price in ipairs(prices) do
        local weight = weights[i] or 1
        weightedSum = weightedSum + (price * weight)
        totalWeight = totalWeight + weight
    end

    if totalWeight > 0 then
        return weightedSum / totalWeight
    end
    return nil
end