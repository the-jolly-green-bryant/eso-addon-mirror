ADawgsFlipWorthy = ADawgsFlipWorthy or {}

local ADDON_NAME = "ADawgsFlipWorthy"
local ADDON_DISPLAY_NAME = "a dawg's FlipWorthy"
local ADDON_VERSION = "1.1.0"
local SAVED_VARS_VERSION = 1
local vars = nil
local cache = {}
local cacheOrder = {}
local hookState = {}

local COLOR_TITLE = "|cFFD700"
local COLOR_GOOD = "|c66FF66"
local COLOR_BAD = "|cFF6666"
local COLOR_WARN = "|cFFD966"
local COLOR_MUTED = "|cB0B0B0"
local COLOR_RESET = "|r"
local COLOR_DEAL_BUYIT = "|cEECA2A"
local COLOR_DEAL_GREAT = "|cA02EF7"
local COLOR_DEAL_GOOD = "|c3A92FF"
local COLOR_DEAL_REASONABLE = "|c2DC50E"
local COLOR_DEAL_OKAY = "|cFFFFFF"
local COLOR_DEAL_OVERPRICED = "|cF90202"

local PRICE_LABEL_SALES_AVG = "TTC Sales Avg"
local PRICE_LABEL_SUGGESTED_AVG = "TTC Suggested Avg"
local PRICE_LABEL_LISTING_AVG = "TTC Listing Avg"
local CACHE_LIMIT = 500
local SALES_AVG_ONLY_PRICE_OPTIONS = { mode = "sale", salesAvgOnly = true }
local MAX_HOOK_RETRIES = 30
local GAMEPAD_GUILD_STORE_MARKER_STYLE = {
    font = "ZoFontGamepad22",
    compactWidth = 44,
    fullWidth = 150,
    height = 26,
}
local VALID_PRICE_MODES = {
    sale = true,
    suggested = true,
    avg = true,
    companion = true,
}

local hookRetryCounts = {}

local GetPrice
local Calculate
local AppendTooltip
local UpdateInventoryMarker
local UpdateCraftingMarker
local SetMarkerResult
local UpdateGuildStoreMarker
local IsSalesAvgGuildStoreDeal
local ClearCache
local RegisterSettings
local InstallHooks
local OnAddonLoaded

local QUALITY_NORMAL = ITEM_DISPLAY_QUALITY_NORMAL
local QUALITY_MAGIC = ITEM_DISPLAY_QUALITY_MAGIC
local QUALITY_ARCANE = ITEM_DISPLAY_QUALITY_ARCANE
local QUALITY_ARTIFACT = ITEM_DISPLAY_QUALITY_ARTIFACT
local QUALITY_LEGENDARY = ITEM_DISPLAY_QUALITY_LEGENDARY

local LINK_SUBTYPE_LEGENDARY = 370

local DEFAULTS = {
    enabled = true,
    debug = false,
    minProfit = 10000,
    showLoss = false,
    priceMode = "sale",
    tooltipInventory = true,
    tooltipGuildStore = true,
    inventoryMarker = true,
    guildStoreMarker = true,
    guildStoreSalesAvgFilter = false,
    guildStoreSalesAvgFilterMinProfit = nil,
    compactInventoryMarker = false,
    materialLinks = {},
    counts = {
        green = 2,
        blue = 3,
        purple = 4,
        gold = 8,
    },
    dealRanges = {
        buyit = 100,
        great = 80,
        good = 60,
        reasonable = 30,
        okay = 0,
    },
    dealColors = {
        buyit = { r = 0.93, g = 0.79, b = 0.16 },
        great = { r = 0.63, g = 0.18, b = 0.97 },
        good = { r = 0.23, g = 0.57, b = 1.0 },
        reasonable = { r = 0.18, g = 0.77, b = 0.05 },
        okay = { r = 1.0, g = 1.0, b = 1.0 },
        overpriced = { r = 0.98, g = 0.01, b = 0.01 },
    },
}

local QUALITY_STEP_KEYS = {
    [QUALITY_MAGIC] = "green",
    [QUALITY_ARCANE] = "blue",
    [QUALITY_ARTIFACT] = "purple",
    [QUALITY_LEGENDARY] = "gold",
}

local MATERIAL_BY_CRAFT = {
    blacksmithing = {
        [QUALITY_MAGIC] = "honing",
        [QUALITY_ARCANE] = "oil",
        [QUALITY_ARTIFACT] = "grain",
        [QUALITY_LEGENDARY] = "alloy",
    },
    clothing = {
        [QUALITY_MAGIC] = "hemming",
        [QUALITY_ARCANE] = "embroidery",
        [QUALITY_ARTIFACT] = "elegant",
        [QUALITY_LEGENDARY] = "wax",
    },
    woodworking = {
        [QUALITY_MAGIC] = "pitch",
        [QUALITY_ARCANE] = "turpen",
        [QUALITY_ARTIFACT] = "mastic",
        [QUALITY_LEGENDARY] = "rosin",
    },
    jewelry = {
        [QUALITY_MAGIC] = "terne",
        [QUALITY_ARCANE] = "iridium",
        [QUALITY_ARTIFACT] = "zircon",
        [QUALITY_LEGENDARY] = "chromium",
    },
}

local MATERIAL_ALIASES = {
    alloy = true,
    wax = true,
    rosin = true,
    chromium = true,
    grain = true,
    elegant = true,
    mastic = true,
    zircon = true,
    honing = true,
    oil = true,
    hemming = true,
    embroidery = true,
    pitch = true,
    turpen = true,
    terne = true,
    iridium = true,
}

local DEFAULT_MATERIALS = {
    alloy = { name = "Tempering Alloy", id = 5687, qualityId = 4 },
    wax = { name = "Dreugh Wax", id = 211, qualityId = 4 },
    rosin = { name = "Rosin", id = 2677, qualityId = 4 },
    chromium = { name = "Chromium Plating", id = 27586, qualityId = 4 },
    grain = { name = "Grain Solvent", id = 4314, qualityId = 3 },
    elegant = { name = "Elegant Lining", id = 558, qualityId = 3 },
    mastic = { name = "Mastic", id = 2070, qualityId = 3 },
    zircon = { name = "Zircon Plating", id = 27544, qualityId = 3 },
    honing = { name = "Honing Stone", id = 4593, qualityId = 1 },
    oil = { name = "Dwarven Oil", id = 1016, qualityId = 2 },
    hemming = { name = "Hemming", id = 388, qualityId = 1 },
    embroidery = { name = "Embroidery", id = 1748, qualityId = 2 },
    pitch = { name = "Pitch", id = 4811, qualityId = 1 },
    turpen = { name = "Turpen", id = 2969, qualityId = 2 },
    terne = { name = "Terne Plating", id = 27550, qualityId = 1 },
    iridium = { name = "Iridium Plating", id = 27545, qualityId = 2 },
}

local function Chat(message)
    d(COLOR_TITLE .. "[ADFW]" .. COLOR_RESET .. " " .. message)
end

local function Debug(reason)
    if vars and vars.debug then
        Chat(COLOR_MUTED .. tostring(reason) .. COLOR_RESET)
    end
end

local function ScheduleHookRetry(key, callback)
    hookRetryCounts[key] = (hookRetryCounts[key] or 0) + 1
    if hookRetryCounts[key] > MAX_HOOK_RETRIES then
        Debug("Stopped retrying hook: " .. tostring(key))
        return
    end

    zo_callLater(callback, 1000)
end

local function ResetHookRetry(key)
    hookRetryCounts[key] = nil
end

local function FormatGold(value)
    if value == nil then
        return "no data"
    end
    if TamrielTradeCentre and TamrielTradeCentre.FormatNumber then
        return TamrielTradeCentre:FormatNumber(value, 0) .. "g"
    end
    return zo_strformat("<<1>>g", zo_round(value))
end

local function SignedGold(value)
    if value == nil then
        return "no data"
    end
    local prefix = value >= 0 and "+" or "-"
    return prefix .. FormatGold(math.abs(value))
end

local function FormatPercent(value)
    if value == nil then
        return "no data"
    end
    local prefix = value >= 0 and "+" or ""
    return prefix .. string.format("%.1f%%", value)
end

local function FormatCount(value)
    if not value then
        return nil
    end
    if TamrielTradeCentre and TamrielTradeCentre.FormatNumber then
        return TamrielTradeCentre:FormatNumber(value, 0)
    end
    return tostring(zo_round(value))
end

local function FormatSalesCount(priceInfo)
    if not priceInfo or not priceInfo.SaleEntryCount then
        return nil
    end

    local saleCount = FormatCount(priceInfo.SaleEntryCount)
    if priceInfo.SaleAmountCount and priceInfo.SaleAmountCount ~= priceInfo.SaleEntryCount then
        return saleCount .. " sales / " .. FormatCount(priceInfo.SaleAmountCount) .. " items"
    end
    return saleCount .. " sales"
end

local function GetSaleEntryCount(priceInfo)
    return tonumber(priceInfo and priceInfo.SaleEntryCount) or 0
end

local function ColorTableToCode(colorTable, fallback)
    if not colorTable then
        return fallback
    end
    local r = math.floor((colorTable.r or 1) * 255 + 0.5)
    local g = math.floor((colorTable.g or 1) * 255 + 0.5)
    local b = math.floor((colorTable.b or 1) * 255 + 0.5)
    return string.format("|c%02X%02X%02X", r, g, b)
end

local function GetConfiguredDealColor(key, fallback)
    return ColorTableToCode(vars and vars.dealColors and vars.dealColors[key], fallback)
end

local function GetDealRangeColor(percent)
    local ranges = vars and vars.dealRanges or DEFAULTS.dealRanges
    if percent == nil then
        return COLOR_MUTED
    elseif percent >= (ranges.buyit or 100) then
        return GetConfiguredDealColor("buyit", COLOR_DEAL_BUYIT)
    elseif percent >= (ranges.great or 80) then
        return GetConfiguredDealColor("great", COLOR_DEAL_GREAT)
    elseif percent >= (ranges.good or 60) then
        return GetConfiguredDealColor("good", COLOR_DEAL_GOOD)
    elseif percent >= (ranges.reasonable or 30) then
        return GetConfiguredDealColor("reasonable", COLOR_DEAL_REASONABLE)
    elseif percent >= (ranges.okay or 0) then
        return GetConfiguredDealColor("okay", COLOR_DEAL_OKAY)
    end
    return GetConfiguredDealColor("overpriced", COLOR_DEAL_OVERPRICED)
end

local function FormatWholePercent(value)
    if value == nil then
        return "?%"
    end
    local rounded = zo_round(value)
    return tostring(rounded) .. "%"
end

local function GetPriceSourceMarker(priceLabel, priceInfo)
    if not priceLabel then
        return ""
    elseif string.find(priceLabel, "Sales Avg", 1, true) then
        if GetSaleEntryCount(priceInfo) >= 5 then
            return "|c22FF22++|r"
        end
        return "|c00FF33+|r"
    elseif string.find(priceLabel, "Suggested", 1, true) then
        return "|cFF9900?|r"
    elseif string.find(priceLabel, "Listing Avg", 1, true) then
        return "|cFF3333!|r"
    end
    return ""
end

local function GetPriceSourceTextMarker(priceLabel, priceInfo)
    return GetPriceSourceMarker(priceLabel, priceInfo)
end

local function GetPriceSourceColor(priceLabel)
    if not priceLabel then
        return COLOR_MUTED
    elseif string.find(priceLabel, "Sales Avg", 1, true) then
        return COLOR_GOOD
    elseif string.find(priceLabel, "Suggested", 1, true) then
        return "|cFF9900"
    elseif string.find(priceLabel, "Listing Avg", 1, true) then
        return COLOR_BAD
    elseif string.find(priceLabel, "Companion", 1, true) then
        return COLOR_TITLE
    end
    return COLOR_MUTED
end

local function ColorizePriceSource(priceLabel, restoreColor)
    if not priceLabel then
        return COLOR_MUTED .. "TTC price" .. COLOR_RESET .. (restoreColor or "")
    end
    return GetPriceSourceColor(priceLabel) .. priceLabel .. COLOR_RESET .. (restoreColor or "")
end

local function AddTooltipLine(tooltip, text, color)
    if tooltip and tooltip.AddLine then
        tooltip:AddLine((color or "") .. text .. COLOR_RESET)
    end
end

local function AddDivider(tooltip)
    if tooltip and tooltip.AddVerticalPadding then
        tooltip:AddVerticalPadding(5)
    end
    if tooltip then
        ZO_Tooltip_AddDivider(tooltip)
    end
end

local function GetPriceModeLabel()
    local mode = vars and vars.priceMode or "sale"
    if mode == "sale" then
        return PRICE_LABEL_SALES_AVG
    elseif mode == "suggested" then
        return PRICE_LABEL_SUGGESTED_AVG
    elseif mode == "avg" then
        return PRICE_LABEL_LISTING_AVG
    elseif mode == "companion" then
        return "TTC Companion setting"
    end
    return PRICE_LABEL_SALES_AVG
end

local function SafeGetPriceInfo(itemInfoOrLink)
    if not TamrielTradeCentrePrice or type(TamrielTradeCentrePrice.GetPriceInfo) ~= "function" then
        return nil, "TTC API not found"
    end
    if not itemInfoOrLink or itemInfoOrLink == "" then
        return nil, "Missing item price target"
    end
    local ok, priceInfo = pcall(function()
        return TamrielTradeCentrePrice:GetPriceInfo(itemInfoOrLink)
    end)
    if not ok then
        return nil, "TTC lookup failed"
    end
    if not priceInfo then
        return nil, "No TTC data"
    end
    return priceInfo, nil
end

GetPrice = function(itemInfoOrLink, priceOptions)
    local priceInfo, reason = SafeGetPriceInfo(itemInfoOrLink)
    if not priceInfo then
        return nil, reason, nil, nil
    end

    local mode = priceOptions and priceOptions.mode or vars.priceMode
    if priceOptions and priceOptions.salesAvgOnly then
        if priceInfo.SaleAvg then
            return priceInfo.SaleAvg, nil, priceInfo, PRICE_LABEL_SALES_AVG
        end
        return nil, "TTC Sales Avg missing", priceInfo, nil
    end

    local price = nil
    local usedLabel = nil
    if type(itemInfoOrLink) == "string" and mode == "companion" and TTCCompanion and type(TTCCompanion.GetTamrielTradeCentrePriceToUse) == "function" then
        local ok, companionPrice = pcall(function()
            return TTCCompanion:GetTamrielTradeCentrePriceToUse(itemInfoOrLink)
        end)
        if ok then
            price = companionPrice
            if price then
                usedLabel = "TTC Companion"
            end
        end
    end

    if not price then
        if mode == "suggested" then
            if priceInfo.SuggestedPrice then
                price = priceInfo.SuggestedPrice
                usedLabel = PRICE_LABEL_SUGGESTED_AVG
            elseif priceInfo.SaleAvg then
                price = priceInfo.SaleAvg
                usedLabel = PRICE_LABEL_SALES_AVG
            elseif priceInfo.Avg then
                price = priceInfo.Avg
                usedLabel = PRICE_LABEL_LISTING_AVG
            end
        elseif mode == "avg" then
            if priceInfo.Avg then
                price = priceInfo.Avg
                usedLabel = PRICE_LABEL_LISTING_AVG
            elseif priceInfo.SaleAvg then
                price = priceInfo.SaleAvg
                usedLabel = PRICE_LABEL_SALES_AVG
            elseif priceInfo.SuggestedPrice then
                price = priceInfo.SuggestedPrice
                usedLabel = PRICE_LABEL_SUGGESTED_AVG
            end
        else
            if priceInfo.SaleAvg then
                price = priceInfo.SaleAvg
                usedLabel = PRICE_LABEL_SALES_AVG
            elseif priceInfo.SuggestedPrice then
                price = priceInfo.SuggestedPrice
                usedLabel = PRICE_LABEL_SUGGESTED_AVG
            elseif priceInfo.Avg then
                price = priceInfo.Avg
                usedLabel = PRICE_LABEL_LISTING_AVG
            end
        end
    end

    if not price then
        return nil, "TTC price fields missing", priceInfo, nil
    end
    return price, nil, priceInfo, usedLabel
end

local function GetDefaultMaterialItemInfo(materialKey)
    local material = DEFAULT_MATERIALS[materialKey]
    if not material then
        return nil
    end
    return {
        ID = material.id,
        Name = material.name,
        QualityID = material.qualityId,
        Level = 1,
        TraitID = nil,
    }
end

local function GetMaterialPrice(materialKey, priceOptions)
    local savedLink = vars.materialLinks[materialKey]
    if savedLink then
        return GetPrice(savedLink, priceOptions)
    end

    local defaultInfo = GetDefaultMaterialItemInfo(materialKey)
    if not defaultInfo then
        return nil, "Missing default material: " .. tostring(materialKey)
    end
    return GetPrice(defaultInfo, priceOptions)
end

local function IsGear(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
        return true
    end
    return equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING
end

local function IsBoundItemLink(itemLink)
    if not itemLink then
        return false
    end
    return IsItemLinkBound(itemLink)
end

local function GetCraftType(itemLink)
    local equipType = GetItemLinkEquipType(itemLink)
    if equipType == EQUIP_TYPE_NECK or equipType == EQUIP_TYPE_RING then
        return "jewelry"
    end

    local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_ARMOR then
        local armorType = GetItemLinkArmorType(itemLink)
        if armorType == ARMORTYPE_HEAVY then
            return "blacksmithing"
        elseif armorType == ARMORTYPE_LIGHT or armorType == ARMORTYPE_MEDIUM then
            return "clothing"
        end
    elseif itemType == ITEMTYPE_WEAPON then
        local weaponType = GetItemLinkWeaponType(itemLink)
        if weaponType == WEAPONTYPE_BOW
            or weaponType == WEAPONTYPE_FIRE_STAFF
            or weaponType == WEAPONTYPE_FROST_STAFF
            or weaponType == WEAPONTYPE_LIGHTNING_STAFF
            or weaponType == WEAPONTYPE_HEALING_STAFF
            or weaponType == WEAPONTYPE_SHIELD then
            return "woodworking"
        end
        return "blacksmithing"
    end
    return nil
end

local function ChangeItemQuality(itemLink, newSubType)
    if not itemLink then
        return nil
    end
    local changed = itemLink:gsub("(|H%d:item:%d+):(%d+)(:.*)", "%1:" .. tostring(newSubType) .. "%3", 1)
    if changed == itemLink then
        return nil
    end
    return changed
end

local function MakeLegendaryLink(itemLink)
    local legendaryLink = ChangeItemQuality(itemLink, LINK_SUBTYPE_LEGENDARY)
    if not legendaryLink then
        return nil, "Could not change item link quality"
    end
    if GetItemLinkFunctionalQuality(legendaryLink) ~= QUALITY_LEGENDARY then
        return nil, "Could not generate Legendary link"
    end
    return legendaryLink, nil
end

local function GetMaterialCost(currentQuality, craftType, priceOptions)
    local craftMaterials = MATERIAL_BY_CRAFT[craftType]
    if not craftMaterials then
        return nil, "Unknown crafting category"
    end

    local total = 0
    local details = {}
    for targetQuality = currentQuality + 1, QUALITY_LEGENDARY do
        local materialKey = craftMaterials[targetQuality]
        local countKey = QUALITY_STEP_KEYS[targetQuality]
        local count = countKey and vars.counts[countKey]

        if not count or count <= 0 then
            return nil, "Missing material count: " .. tostring(countKey)
        end

        local price, reason = GetMaterialPrice(materialKey, priceOptions)
        if not price then
            return nil, "Missing material TTC price: " .. tostring(materialKey) .. " (" .. tostring(reason) .. ")"
        end

        total = total + price * count
        details[#details + 1] = {
            key = materialKey,
            count = count,
            price = price,
        }
    end
    return total, nil, details
end

local function MakeCacheKey(itemLink, basisPrice, source, priceOptions)
    local mode = priceOptions and priceOptions.mode or (vars and vars.priceMode) or "sale"
    local salesAvgOnly = priceOptions and priceOptions.salesAvgOnly and "sales-only" or "fallback"
    return tostring(itemLink) .. "|" .. tostring(basisPrice or "") .. "|" .. tostring(source or "") .. "|" .. mode .. "|" .. salesAvgOnly
end

local function CacheResult(key, result)
    cache = cache or {}
    cacheOrder = cacheOrder or {}
    if not cache[key] then
        cacheOrder[#cacheOrder + 1] = key
    end
    cache[key] = result
    if #cacheOrder > CACHE_LIMIT then
        local oldKey = table.remove(cacheOrder, 1)
        if oldKey then
            cache[oldKey] = nil
        end
    end
end

Calculate = function(itemLink, basisPrice, source, priceOptions)
    cache = cache or {}
    local key = MakeCacheKey(itemLink, basisPrice, source, priceOptions)
    local cached = cache[key]
    if cached then
        return cached
    end

    local result = {
        itemLink = itemLink,
        source = source or "inventory",
        ok = false,
    }

    if not vars.enabled then
        result.reason = "Addon disabled"
    elseif not itemLink or itemLink == "" then
        result.reason = "Missing item link"
    elseif not TamrielTradeCentrePrice then
        result.reason = "TTC addon not loaded"
    elseif IsBoundItemLink(itemLink) then
        result.reason = "Item is bound"
    elseif not IsGear(itemLink) then
        result.reason = "Item is not gear"
    else
        local quality = GetItemLinkFunctionalQuality(itemLink)
        result.currentQuality = quality

        if quality >= QUALITY_LEGENDARY then
            result.reason = "Item is already Legendary"
        elseif quality < QUALITY_NORMAL then
            result.reason = "Item quality is below Normal"
        else
            local craftType = GetCraftType(itemLink)
            result.craftType = craftType
            if not craftType then
                result.reason = "Could not detect crafting category"
            else
                local legendaryLink, linkReason = MakeLegendaryLink(itemLink)
                result.legendaryLink = legendaryLink
                if not legendaryLink then
                    result.reason = linkReason
                else
                    local currentPrice = basisPrice
                    local currentReason = nil
                    local currentPriceLabel = basisPrice and "Listing price" or nil
                    local currentPriceInfo = nil
                    if not currentPrice then
                        currentPrice, currentReason, currentPriceInfo, currentPriceLabel = GetPrice(itemLink, priceOptions)
                    end
                    result.currentPrice = currentPrice
                    result.currentPriceLabel = currentPriceLabel
                    result.currentPriceInfo = currentPriceInfo

                    local legendaryPrice, legendaryReason, legendaryPriceInfo, legendaryPriceLabel = GetPrice(legendaryLink, priceOptions)
                    result.legendaryPrice = legendaryPrice
                    result.legendaryPriceLabel = legendaryPriceLabel
                    result.legendaryPriceInfo = legendaryPriceInfo

                    local materialCost, materialReason, materialDetails = GetMaterialCost(quality, craftType, priceOptions)
                    result.materialCost = materialCost
                    result.materialDetails = materialDetails

                    if not currentPrice and source == "inventory" then
                        result.currentPriceMissing = true
                        result.currentPriceReason = currentReason
                        currentPrice = 0
                        result.currentPrice = 0
                    end

                    if not currentPrice then
                        result.reason = "Current item has no TTC data: " .. tostring(currentReason)
                    elseif not legendaryPrice then
                        result.reason = "Legendary item has no TTC data: " .. tostring(legendaryReason)
                    elseif not materialCost then
                        result.reason = materialReason
                    else
                        result.profit = legendaryPrice - currentPrice - materialCost
                        result.investment = currentPrice + materialCost
                        if result.investment and result.investment > 0 then
                            result.returnPercent = (result.profit / result.investment) * 100
                        end
                        result.ok = true
                        result.worth = result.profit >= vars.minProfit
                        if result.worth then
                            result.recommendation = result.currentPriceMissing and "Likely worth upgrading (estimate)" or "Likely worth upgrading"
                        elseif result.profit >= 0 then
                            result.recommendation = result.currentPriceMissing and "Profitable estimate, below threshold" or "Profitable, below threshold"
                        else
                            result.recommendation = "Not worth upgrading"
                        end
                    end
                end
            end
        end
    end

    CacheResult(key, result)
    return result
end

AppendTooltip = function(tooltip, itemLink, basisPrice, source)
    if not vars.enabled or not tooltip then
        return
    end

    local result = Calculate(itemLink, basisPrice, source)
    if not result.ok and not vars.debug
        and (result.reason == "Item is not gear"
            or result.reason == "Item is bound"
            or result.reason == "Item is already Legendary"
            or result.reason == "Item quality is below Normal"
            or result.reason == "Addon disabled"
            or result.reason == "Missing item link") then
        return
    end

    AddDivider(tooltip)
    AddTooltipLine(tooltip, ADDON_DISPLAY_NAME, COLOR_TITLE)
    AddTooltipLine(tooltip, "Price preference: " .. ColorizePriceSource(GetPriceModeLabel(), COLOR_MUTED), COLOR_MUTED)

    if result.ok then
        if source == "guildstore" and basisPrice then
            AddTooltipLine(tooltip, "Listing price: " .. FormatGold(result.currentPrice), COLOR_MUTED)
        elseif result.currentPriceMissing then
            AddTooltipLine(tooltip, "Current TTC: no data", COLOR_WARN)
        else
            AddTooltipLine(tooltip, "Current TTC (" .. ColorizePriceSource(result.currentPriceLabel, COLOR_MUTED) .. "): " .. FormatGold(result.currentPrice), COLOR_MUTED)
        end
        local legendaryExtra = ""
        local salesCount = result.legendaryPriceLabel == PRICE_LABEL_SALES_AVG and FormatSalesCount(result.legendaryPriceInfo) or nil
        if salesCount then
            legendaryExtra = " (" .. salesCount .. ")"
        end
        AddTooltipLine(tooltip, "Legendary TTC (" .. ColorizePriceSource(result.legendaryPriceLabel, COLOR_MUTED) .. "): " .. FormatGold(result.legendaryPrice) .. legendaryExtra, COLOR_MUTED)
        AddTooltipLine(tooltip, "Upgrade cost: " .. FormatGold(result.materialCost), COLOR_MUTED)
        local profitColor = GetDealRangeColor(result.returnPercent)
        local profitLabel = source == "guildstore" and "Profit after buying: " or (result.currentPriceMissing and "Profit after upgrade cost: " or "Profit vs selling now: ")
        AddTooltipLine(tooltip, profitLabel .. SignedGold(result.profit), profitColor)
        AddTooltipLine(tooltip, "Return: " .. FormatPercent(result.returnPercent), profitColor)
    else
        AddTooltipLine(tooltip, "Cannot calculate", COLOR_WARN)
        AddTooltipLine(tooltip, "Reason: " .. tostring(result.reason), COLOR_MUTED)
    end
end

local function GetTradingHousePurchasePrice(index)
    local _, _, _, _, _, _, purchasePrice = GetTradingHouseSearchResultItemInfo(index)
    return purchasePrice
end

local function HookTooltipMethod(tooltip, methodName, linkFunction, source, priceFunction)
    if not tooltip or not tooltip[methodName] or type(linkFunction) ~= "function" then
        return
    end

    local originalMethod = tooltip[methodName]
    tooltip[methodName] = function(control, ...)
        local returns = { originalMethod(control, ...) }

        if source == "inventory" and not vars.tooltipInventory then
            return unpack(returns)
        end
        if source == "guildstore" and not vars.tooltipGuildStore then
            return unpack(returns)
        end

        local itemLink = linkFunction(...)
        local basisPrice = priceFunction and priceFunction(...) or nil
        AppendTooltip(control, itemLink, basisPrice, source)
        return unpack(returns)
    end
end

local function GetRowPriceControl(rowControl)
    if not rowControl then
        return nil
    end

    return rowControl.sellPriceControl
        or rowControl.priceLabel
        or rowControl.unitPriceLabel
        or rowControl:GetNamedChild("SellPriceText")
        or rowControl:GetNamedChild("SellPrice")
        or rowControl:GetNamedChild("Price")
end

local function EnsureMarker(rowControl)
    local marker = rowControl.ADFWMarker
    if marker then
        return marker
    end

    marker = marker or WINDOW_MANAGER:CreateControl(nil, rowControl, CT_LABEL)
    marker:SetFont("ZoFontGame")
    marker:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    marker:SetDimensions(120, 22)
    marker:SetHidden(true)

    local priceControl = GetRowPriceControl(rowControl)
    if priceControl then
        marker:SetAnchor(RIGHT, priceControl, LEFT, -6, 0)
    else
        marker:SetAnchor(RIGHT, rowControl, RIGHT, -12, 0)
    end
    rowControl.ADFWMarker = marker
    return marker
end

local function HideExistingMarker(rowControl)
    local marker = rowControl and rowControl.ADFWMarker
    if marker then
        marker:SetHidden(true)
    end
end

local function ShouldShowMarkerResult(result)
    return result and result.ok and (result.profit >= vars.minProfit or vars.showLoss)
end

local function BuildMarkerText(result)
    local color = GetDealRangeColor(result.returnPercent)
    local textMarker = GetPriceSourceTextMarker(result.legendaryPriceLabel, result.legendaryPriceInfo)
    local markerPrefix = textMarker ~= "" and (textMarker .. " ") or ""

    if vars.compactInventoryMarker then
        return markerPrefix .. color .. "$" .. COLOR_RESET
    end

    return markerPrefix .. color .. SignedGold(result.profit) .. " (" .. FormatWholePercent(result.returnPercent) .. ")" .. COLOR_RESET
end

UpdateInventoryMarker = function(rowControl, slot)
    HideExistingMarker(rowControl)
    if not vars.enabled or not vars.inventoryMarker or not rowControl or not slot then
        return
    end
    local marker = EnsureMarker(rowControl)
    marker:SetHidden(true)

    if not slot.bagId or not slot.slotIndex then
        return
    end

    local itemLink = GetItemLink(slot.bagId, slot.slotIndex, LINK_STYLE_DEFAULT)
    local result = Calculate(itemLink, nil, "inventory")
    if result.ok then
        SetMarkerResult(marker, result, false)
    elseif vars.debug then
        marker:SetText(COLOR_WARN .. "ADFW ?" .. COLOR_RESET)
        marker:SetHidden(false)
    end
end

local function GetSlotData(slot)
    local data = slot
    if data and data.dataEntry and data.dataEntry.data then
        data = data.dataEntry.data
    end
    if data and data.data then
        data = data.data
    end

    local bagId = data and (data.bagId or data.bag)
    local slotIndex = data and (data.slotIndex or data.slot)
    return bagId, slotIndex
end

local function GetInventoryControlBagAndSlot(control)
    if not control then
        return nil, nil
    end

    return ZO_Inventory_GetBagAndIndex(control)
end

UpdateCraftingMarker = function(rowControl, slot)
    HideExistingMarker(rowControl)
    if not vars.enabled or not vars.inventoryMarker or not rowControl then
        return
    end

    local marker = EnsureMarker(rowControl)
    marker:SetHidden(true)
    marker:ClearAnchors()
    marker:SetAnchor(RIGHT, rowControl, RIGHT, -128, 0)
    marker:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local bagId, slotIndex = GetSlotData(slot)
    if not bagId or not slotIndex then
        bagId, slotIndex = GetInventoryControlBagAndSlot(rowControl)
    end
    if not bagId or not slotIndex then
        return
    end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    local result = Calculate(itemLink, nil, "inventory")
    if result.ok then
        SetMarkerResult(marker, result, false)
    elseif vars.debug then
        marker:SetText(COLOR_WARN .. "ADFW ?" .. COLOR_RESET)
        marker:SetHidden(false)
    end
end

SetMarkerResult = function(marker, result, isGuildStore, style)
    if not ShouldShowMarkerResult(result) then
        return
    end

    local font = style and style.font or (isGuildStore and "ZoFontGameSmall" or "ZoFontGame")
    local compactWidth = style and style.compactWidth or (isGuildStore and 34 or 44)
    local fullWidth = style and style.fullWidth or (isGuildStore and 118 or 132)
    local height = style and style.height or (isGuildStore and 18 or 22)

    if vars.compactInventoryMarker then
        marker:SetDimensions(compactWidth, height)
    else
        marker:SetDimensions(fullWidth, height)
    end

    marker:SetFont(font)
    marker:SetText(BuildMarkerText(result))
    marker:SetHidden(false)
end

UpdateGuildStoreMarker = function(rowControl, resultData)
    HideExistingMarker(rowControl)
    if not vars.enabled or not vars.guildStoreMarker or not rowControl or not resultData then
        return
    end

    local marker = EnsureMarker(rowControl)
    marker:SetHidden(true)
    marker:ClearAnchors()
    marker:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    local priceControl = GetRowPriceControl(rowControl)
    if priceControl then
        marker:SetAnchor(RIGHT, priceControl, LEFT, -8, 0)
    else
        marker:SetAnchor(RIGHT, rowControl, RIGHT, -88, 0)
    end

    if resultData.purchased or resultData.soldout then
        return
    end

    local itemLink = resultData.itemLink
    local purchasePrice = resultData.purchasePrice
    if (not itemLink or itemLink == "") and resultData.slotIndex then
        itemLink = GetTradingHouseSearchResultItemLink(resultData.slotIndex, LINK_STYLE_DEFAULT)
    end
    if not purchasePrice and resultData.slotIndex then
        purchasePrice = GetTradingHousePurchasePrice(resultData.slotIndex)
    end

    local result = Calculate(itemLink, purchasePrice, "guildstore")
    if result.ok then
        SetMarkerResult(marker, result, true)
    elseif vars.debug then
        marker:SetText(COLOR_WARN .. "ADFW ?" .. COLOR_RESET)
        marker:SetHidden(false)
    end
end

local function UpdateGamepadGuildStoreMarker(rowControl, itemData)
    HideExistingMarker(rowControl)
    if not vars.enabled or not vars.guildStoreMarker or not rowControl or not itemData or itemData.isGuildSpecificItem then
        return
    end
    if itemData.purchased or itemData.soldout then
        return
    end

    local marker = EnsureMarker(rowControl)
    marker:SetHidden(true)
    marker:ClearAnchors()
    marker:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local priceControl = GetRowPriceControl(rowControl)
    if priceControl then
        marker:SetAnchor(RIGHT, priceControl, LEFT, -10, 0)
    else
        marker:SetAnchor(RIGHT, rowControl, RIGHT, -20, 0)
    end

    local result = Calculate(itemData.itemLink, itemData.purchasePrice, "guildstore")
    if result.ok then
        SetMarkerResult(marker, result, true, GAMEPAD_GUILD_STORE_MARKER_STYLE)
    elseif vars.debug then
        marker:SetFont(GAMEPAD_GUILD_STORE_MARKER_STYLE.font)
        marker:SetText(COLOR_WARN .. "ADFW ?" .. COLOR_RESET)
        marker:SetHidden(false)
    end
end

local function AddGamepadEntryMarker(entryData, bagId, slotIndex)
    if not vars.enabled or not vars.inventoryMarker or not entryData or not bagId or not slotIndex then
        return
    end
    if type(entryData.AddSubLabel) ~= "function" then
        return
    end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
    local result = Calculate(itemLink, nil, "inventory")
    if ShouldShowMarkerResult(result) then
        entryData:AddSubLabel(BuildMarkerText(result))
    elseif vars.debug then
        entryData:AddSubLabel(COLOR_WARN .. "ADFW ?" .. COLOR_RESET)
    end
end

local function GetGuildStoreItemData(itemData)
    if not itemData then
        return nil, nil
    end

    local itemLink = itemData.itemLink
    local purchasePrice = itemData.purchasePrice

    local resultIndex = itemData.slotIndex
    if (not itemLink or itemLink == "") and resultIndex then
        itemLink = GetTradingHouseSearchResultItemLink(resultIndex, LINK_STYLE_DEFAULT)
    end
    if not purchasePrice and resultIndex then
        purchasePrice = GetTradingHousePurchasePrice(resultIndex)
    end

    return itemLink, purchasePrice
end

IsSalesAvgGuildStoreDeal = function(itemData)
    if itemData and (itemData.purchased or itemData.soldout) then
        return false
    end

    local itemLink, purchasePrice = GetGuildStoreItemData(itemData)
    local result = Calculate(itemLink, purchasePrice, "guildstore", SALES_AVG_ONLY_PRICE_OPTIONS)
    local ranges = vars and vars.dealRanges or DEFAULTS.dealRanges
    local minimumReturn = ranges.good or DEFAULTS.dealRanges.good
    local minimumProfit = vars and vars.guildStoreSalesAvgFilterMinProfit
        or vars and vars.minProfit
        or DEFAULTS.minProfit
    return result.ok
        and result.profit >= minimumProfit
        and result.returnPercent >= minimumReturn
        and result.legendaryPriceLabel == PRICE_LABEL_SALES_AVG
end

local function RefreshAGSResults()
    local AGS = AwesomeGuildStore
    local searchManager = AGS and AGS.internal and AGS.internal.tradingHouse and AGS.internal.tradingHouse.searchManager
    local activeSearch = searchManager and searchManager.GetActiveSearch and searchManager:GetActiveSearch()
    if searchManager and activeSearch and searchManager.RequestResultUpdate then
        searchManager:RequestResultUpdate()
        return true
    end
    return false
end

local function FilterAGSResultList(searchResults)
    if not vars or not vars.enabled or not vars.guildStoreSalesAvgFilter or not searchResults then
        return false
    end

    local removed = false
    local writeIndex = 1
    for readIndex = 1, #searchResults do
        local resultData = searchResults[readIndex]
        if IsSalesAvgGuildStoreDeal(resultData) then
            if writeIndex ~= readIndex then
                searchResults[writeIndex] = resultData
            end
            writeIndex = writeIndex + 1
        else
            removed = true
        end
    end
    for index = #searchResults, writeIndex, -1 do
        searchResults[index] = nil
    end
    return removed
end

local function InstallAGSForcedFilterHook()
    local AGS = AwesomeGuildStore
    if not AGS then
        return
    end

    local searchManager = AGS and AGS.internal and AGS.internal.tradingHouse and AGS.internal.tradingHouse.searchManager
    if not searchManager or searchManager.ADFWForcedFilterHooked then
        if not searchManager then
            ScheduleHookRetry("agsFilter", InstallAGSForcedFilterHook)
        end
        return
    end

    local originalUpdateSearchResults = searchManager.UpdateSearchResults
    if type(originalUpdateSearchResults) ~= "function" then
        return
    end

    searchManager.UpdateSearchResults = function(self, ...)
        local returns = { originalUpdateSearchResults(self, ...) }
        if vars and vars.guildStoreSalesAvgFilter then
            local activeSearch = self.GetActiveSearch and self:GetActiveSearch()
            if not activeSearch then
                Debug("AGS filtering skipped: no active search")
                return unpack(returns)
            end
        end
        if FilterAGSResultList(self.searchResults) and AGS.internal and AGS.internal.FireCallbacks then
            AGS.internal:FireCallbacks(AGS.callback.SEARCH_RESULT_UPDATE, self.searchResults, self.hasMorePages)
        end
        return unpack(returns)
    end
    searchManager.ADFWForcedFilterHooked = true
    ResetHookRetry("agsFilter")
end

local function GetGuildStoreContextLink(inventorySlot)
    if not inventorySlot then
        return nil
    end

    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    local slotIndex = ZO_Inventory_GetSlotIndex(inventorySlot)
    if not slotIndex then
        return nil
    end

    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        return GetTradingHouseSearchResultItemLink(slotIndex, LINK_STYLE_DEFAULT)
    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        return GetTradingHouseListingItemLink(slotIndex, LINK_STYLE_DEFAULT)
    end
    return nil
end

local function OpenLegendaryTTCPage(itemLink)
    local legendaryLink, reason = MakeLegendaryLink(itemLink)
    if not legendaryLink then
        Chat("Could not create Legendary link: " .. tostring(reason))
        return
    end

    if not TamrielTradeCentre_ItemInfo or not TamrielTradeCentrePrice or type(TamrielTradeCentrePrice.PriceDetailOnline) ~= "function" then
        Chat("TTC price detail API not found.")
        return
    end

    local ok, itemInfo = pcall(function()
        return TamrielTradeCentre_ItemInfo:New(legendaryLink)
    end)
    if not ok then
        Chat("TTC could not read the Legendary item link.")
        return
    end
    if not itemInfo or not itemInfo.ID then
        Chat("TTC could not read the Legendary item link.")
        return
    end

    local opened = pcall(function()
        TamrielTradeCentrePrice:PriceDetailOnline(itemInfo)
    end)
    if not opened then
        Chat("TTC could not open the Legendary price page.")
    end
end

local function InstallLegendaryTTCContextMenu()
    if hookState.legendaryTTCContextHooked then
        return
    end
    if not LibCustomMenu or type(LibCustomMenu.RegisterContextMenu) ~= "function" then
        Debug("LibCustomMenu not ready for Legendary TTC context menu")
        return
    end
    if type(AddCustomMenuItem) ~= "function" then
        Debug("LibCustomMenu item API not ready for Legendary TTC context menu")
        return
    end

    LibCustomMenu:RegisterContextMenu(function(inventorySlot)
        local itemLink = GetGuildStoreContextLink(inventorySlot)
        if not itemLink or itemLink == "" or IsBoundItemLink(itemLink) or not IsGear(itemLink) then
            return
        end
        if GetItemLinkFunctionalQuality(itemLink) >= QUALITY_LEGENDARY then
            return
        end

        AddCustomMenuItem("TTC Legendary page", function()
            OpenLegendaryTTCPage(itemLink)
        end)
    end)

    hookState.legendaryTTCContextHooked = true
end

local function RegisterAwesomeGuildStoreFilter()
    -- This version avoids native AGS filter registration to reduce setup work and addon conflicts.
    InstallAGSForcedFilterHook()
end

local function InstallInventoryMarkerHook()
    if hookState.inventoryMarkerHooked then
        return
    end

    if not PLAYER_INVENTORY or not PLAYER_INVENTORY.inventories then
        Debug("PLAYER_INVENTORY not ready for marker hook")
        ScheduleHookRetry("inventoryMarker", InstallInventoryMarkerHook)
        return
    end

    local hookedAny = false
    for _, inventory in pairs(PLAYER_INVENTORY.inventories) do
        local listView = inventory.listView
        local dataType = listView and listView.dataTypes and listView.dataTypes[1]
        if dataType and dataType.setupCallback then
            if not dataType.ADFWMarkerHooked then
                local originalSetup = dataType.setupCallback
                dataType.setupCallback = function(rowControl, slot)
                    local returns = { originalSetup(rowControl, slot) }
                    UpdateInventoryMarker(rowControl, slot)
                    return unpack(returns)
                end
                dataType.ADFWMarkerHooked = true
            end
            hookedAny = true
        end
    end

    if hookedAny then
        hookState.inventoryMarkerHooked = true
        ResetHookRetry("inventoryMarker")
    else
        Debug("Inventory lists not ready for marker hook")
        ScheduleHookRetry("inventoryMarker", InstallInventoryMarkerHook)
    end
end

local function HookCraftingInventory(inventory, hookName)
    if not inventory then
        return false
    end

    local listView = inventory.listView or inventory.list or inventory.backpackList or inventory.control or inventory
    local dataType = nil
    if listView and listView.dataTypes then
        dataType = listView.dataTypes[1]
    end
    if not dataType and listView then
        dataType = ZO_ScrollList_GetDataTypeTable(listView, 1)
    end

    if dataType and dataType.setupCallback and not dataType[hookName] then
        local originalSetup = dataType.setupCallback
        dataType.setupCallback = function(rowControl, slot)
            local returns = { originalSetup(rowControl, slot) }
            UpdateCraftingMarker(rowControl, slot)
            return unpack(returns)
        end
        dataType[hookName] = true
        return true
    end
    return false
end

local function InstallCraftingMarkerHooks()
    if hookState.deconstructionMarkerHooked and hookState.improvementMarkerHooked and hookState.universalDeconstructionMarkerHooked then
        ResetHookRetry("craftingMarker")
        return
    end

    local changed = false
    if SMITHING then
        local deconstructionPanel = SMITHING.deconstructionPanel or SMITHING.deconstruction
        local improvementPanel = SMITHING.improvementPanel or SMITHING.improvement
        if not hookState.deconstructionMarkerHooked then
            hookState.deconstructionMarkerHooked = HookCraftingInventory(deconstructionPanel and deconstructionPanel.inventory, "ADFWDeconstructionMarkerHooked")
            changed = hookState.deconstructionMarkerHooked or changed
        end
        if not hookState.improvementMarkerHooked then
            hookState.improvementMarkerHooked = HookCraftingInventory(improvementPanel and improvementPanel.inventory, "ADFWImprovementMarkerHooked")
            changed = hookState.improvementMarkerHooked or changed
        end
    end
    if not hookState.universalDeconstructionMarkerHooked then
        hookState.universalDeconstructionMarkerHooked = HookCraftingInventory(ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack, "ADFWUniversalDeconstructionMarkerHooked")
        changed = hookState.universalDeconstructionMarkerHooked or changed
    end

    if changed then
        Debug("Crafting marker hook installed")
    end
    if not hookState.deconstructionMarkerHooked or not hookState.improvementMarkerHooked or not hookState.universalDeconstructionMarkerHooked then
        Debug("Crafting inventory not ready for marker hook")
        ScheduleHookRetry("craftingMarker", InstallCraftingMarkerHooks)
    else
        ResetHookRetry("craftingMarker")
    end
end

local function SetResultMarker(parent, itemLink)
    HideExistingMarker(parent)
    if not parent or not itemLink or itemLink == "" then
        return
    end

    local marker = EnsureMarker(parent)
    marker:SetHidden(true)
    marker:ClearAnchors()
    marker:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -18, 14)
    marker:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local result = Calculate(itemLink, nil, "inventory")
    if result.ok then
        SetMarkerResult(marker, result, false)
    elseif vars.debug then
        marker:SetText(COLOR_WARN .. "ADFW ?" .. COLOR_RESET)
        marker:SetHidden(false)
    end
end

local function HookObjectMethod(object, methodName, hookFlag, callback)
    if not object or type(object[methodName]) ~= "function" or object[hookFlag] then
        return false
    end

    local originalMethod = object[methodName]
    object[methodName] = function(self, ...)
        local returns = { originalMethod(self, ...) }
        callback(self, ...)
        return unpack(returns)
    end
    object[hookFlag] = true
    return true
end

local function InstallSmithingResultMarkerHooks()
    if hookState.smithingResultMarkerHooked then
        return
    end

    local hookedCreation = HookObjectMethod(ZO_SmithingCreation, "SetupResultTooltip", "ADFWCreationResultMarkerHooked", function(_, patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
        local itemLink = GetSmithingPatternResultLink(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex)
        SetResultMarker(ZO_SmithingTopLevelCreationPanelResultTooltip or ZO_SmithingTopLevelCreationPanel, itemLink)
    end)

    local hookedImprovement = HookObjectMethod(ZO_SmithingImprovement, "SetupResultTooltip", "ADFWImprovementResultMarkerHooked", function(_, bagId, slotIndex)
        local itemLink = bagId and slotIndex and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        SetResultMarker(ZO_SmithingTopLevelImprovementPanelResultTooltip or ZO_SmithingTopLevelImprovementPanel, itemLink)
    end)

    if hookedCreation or hookedImprovement then
        hookState.smithingResultMarkerHooked = true
        ResetHookRetry("smithingResultMarker")
    else
        ScheduleHookRetry("smithingResultMarker", InstallSmithingResultMarkerHooks)
    end
end

local function HookGuildStoreDataType(scrollList, dataTypeId)
    local dataType = scrollList and ZO_ScrollList_GetDataTypeTable(scrollList, dataTypeId)
    if not dataType or type(dataType.setupCallback) ~= "function" then
        return false
    end

    if dataType.ADFWGuildStoreMarkerCallback == dataType.setupCallback then
        return true
    end

    local originalSetup = dataType.setupCallback
    local wrappedSetup = function(rowControl, resultData)
        local returns = { originalSetup(rowControl, resultData) }
        UpdateGuildStoreMarker(rowControl, resultData)
        return unpack(returns)
    end

    dataType.setupCallback = wrappedSetup
    dataType.ADFWGuildStoreMarkerCallback = wrappedSetup
    dataType.ADFWGuildStoreMarkerHooked = true
    return true
end

local function InstallGuildStoreMarkerHook()
    local tradingHouse = TRADING_HOUSE or ZO_TradingHouse
    local searchResultsList = tradingHouse and tradingHouse.searchResultsList
    if not searchResultsList then
        Debug("Trading house search results list not ready for marker hook")
        ScheduleHookRetry("guildStoreMarker", InstallGuildStoreMarkerHook)
        return
    end

    local hookedSearch = HookGuildStoreDataType(searchResultsList, 1)
    local hookedGuild = HookGuildStoreDataType(searchResultsList, 3)
    if hookedSearch or hookedGuild then
        hookState.guildStoreMarkerHooked = true
        ResetHookRetry("guildStoreMarker")
    else
        ScheduleHookRetry("guildStoreMarker", InstallGuildStoreMarkerHook)
    end
end

local function InstallAwesomeGuildStoreMarkerHook()
    local AGS = AwesomeGuildStore
    local wrapper = AGS and AGS.class and AGS.class.SearchResultListWrapper
    if not wrapper or type(wrapper.InitializeResultList) ~= "function" then
        ScheduleHookRetry("agsResultListMarker", InstallAwesomeGuildStoreMarkerHook)
        return
    end

    if wrapper.ADFWResultListMarkerHooked then
        InstallGuildStoreMarkerHook()
        return
    end

    local originalInitializeResultList = wrapper.InitializeResultList
    wrapper.InitializeResultList = function(self, ...)
        local returns = { originalInitializeResultList(self, ...) }
        InstallGuildStoreMarkerHook()
        return unpack(returns)
    end
    wrapper.ADFWResultListMarkerHooked = true
    ResetHookRetry("agsResultListMarker")
    InstallGuildStoreMarkerHook()
end

local function InstallGamepadGuildStoreMarkerHook()
    if hookState.gamepadGuildStoreMarkerHooked then
        return
    end

    local browseResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    if not browseResults or type(browseResults.SetupResultItemRow) ~= "function" then
        ScheduleHookRetry("gamepadGuildStoreMarker", InstallGamepadGuildStoreMarkerHook)
        return
    end

    local hooked = HookObjectMethod(browseResults, "SetupResultItemRow", "ADFWGamepadGuildStoreMarkerHooked", function(_, rowControl, itemData)
        UpdateGamepadGuildStoreMarker(rowControl, itemData)
    end)

    if hooked then
        hookState.gamepadGuildStoreMarkerHooked = true
        ResetHookRetry("gamepadGuildStoreMarker")
    else
        ScheduleHookRetry("gamepadGuildStoreMarker", InstallGamepadGuildStoreMarkerHook)
    end
end

local function InstallGamepadInventoryMarkerHook()
    if hookState.gamepadInventoryMarkerHooked then
        return
    end

    if not ZO_GamepadInventoryList or type(ZO_GamepadInventoryList.SetupItemEntry) ~= "function" then
        ScheduleHookRetry("gamepadInventoryMarker", InstallGamepadInventoryMarkerHook)
        return
    end

    local originalSetupItemEntry = ZO_GamepadInventoryList.SetupItemEntry
    ZO_GamepadInventoryList.SetupItemEntry = function(self, entry, itemData, ...)
        local returns = { originalSetupItemEntry(self, entry, itemData, ...) }
        if itemData then
            AddGamepadEntryMarker(entry, itemData.bagId or itemData.bag, itemData.slotIndex or itemData.slot)
        end
        return unpack(returns)
    end

    hookState.gamepadInventoryMarkerHooked = true
    ResetHookRetry("gamepadInventoryMarker")
end

local function InstallGamepadCraftingMarkerHook()
    if hookState.gamepadCraftingMarkerHooked then
        return
    end

    if not ZO_GamepadCraftingInventory or type(ZO_GamepadCraftingInventory.GenerateCraftingInventoryEntryData) ~= "function" then
        ScheduleHookRetry("gamepadCraftingMarker", InstallGamepadCraftingMarkerHook)
        return
    end

    local originalGenerateEntryData = ZO_GamepadCraftingInventory.GenerateCraftingInventoryEntryData
    ZO_GamepadCraftingInventory.GenerateCraftingInventoryEntryData = function(self, bagId, slotIndex, ...)
        local entryData = originalGenerateEntryData(self, bagId, slotIndex, ...)
        AddGamepadEntryMarker(entryData, bagId, slotIndex)
        return entryData
    end

    hookState.gamepadCraftingMarkerHooked = true
    ResetHookRetry("gamepadCraftingMarker")
end

ClearCache = function()
    cache = {}
    cacheOrder = {}
end

local function CopyDefaultValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, nestedValue in pairs(value) do
        copy[key] = CopyDefaultValue(nestedValue)
    end
    return copy
end

local function HasSavedVarData(savedVars)
    if type(savedVars) ~= "table" then
        return false
    end

    for key in pairs(DEFAULTS) do
        if savedVars[key] ~= nil then
            return true
        end
    end
    return false
end

local function CopySavedVarData(source, target)
    if type(source) ~= "table" or type(target) ~= "table" then
        return
    end

    for key in pairs(DEFAULTS) do
        if source[key] ~= nil then
            target[key] = CopyDefaultValue(source[key])
        end
    end
end

local function ApplyDefaults(target, defaults)
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = CopyDefaultValue(defaultValue)
            else
                ApplyDefaults(target[key], defaultValue)
            end
        elseif target[key] == nil then
            target[key] = defaultValue
        end
    end
end

local function NormalizeSavedVars()
    vars = vars or {}
    ApplyDefaults(vars, DEFAULTS)

    if not VALID_PRICE_MODES[vars.priceMode] then
        vars.priceMode = DEFAULTS.priceMode
    end

    local booleanKeys = {
        "enabled",
        "debug",
        "showLoss",
        "tooltipInventory",
        "tooltipGuildStore",
        "inventoryMarker",
        "guildStoreMarker",
        "guildStoreSalesAvgFilter",
        "compactInventoryMarker",
    }
    for _, key in ipairs(booleanKeys) do
        if type(vars[key]) ~= "boolean" then
            vars[key] = DEFAULTS[key]
        end
    end

    vars.minProfit = tonumber(vars.minProfit) or DEFAULTS.minProfit
    vars.guildStoreSalesAvgFilterMinProfit = tonumber(vars.guildStoreSalesAvgFilterMinProfit)

    for key, value in pairs(DEFAULTS.counts) do
        vars.counts[key] = tonumber(vars.counts[key]) or value
    end

    for key, value in pairs(DEFAULTS.dealRanges) do
        vars.dealRanges[key] = tonumber(vars.dealRanges[key]) or value
    end

    for key, value in pairs(DEFAULTS.dealColors) do
        vars.dealColors[key] = vars.dealColors[key] or {}
        vars.dealColors[key].r = tonumber(vars.dealColors[key].r) or value.r
        vars.dealColors[key].g = tonumber(vars.dealColors[key].g) or value.g
        vars.dealColors[key].b = tonumber(vars.dealColors[key].b) or value.b
    end
end

local function GetSavedVarsWorldKey()
    local worldName = GetWorldName()
    if worldName and worldName ~= "" then
        return worldName
    end
    return "Default"
end

local function LoadSavedVars()
    local worldKey = GetSavedVarsWorldKey()
    vars = ZO_SavedVars:NewAccountWide("ADawgsFlipWorthyVars", SAVED_VARS_VERSION, worldKey, {})

    local legacyVars = ZO_SavedVars:NewAccountWide("ADawgsFlipWorthyVars", SAVED_VARS_VERSION, nil, {})
    if legacyVars
        and vars
        and not vars.adfwWorldMigrationComplete
        and HasSavedVarData(legacyVars)
        and not HasSavedVarData(vars)
    then
        CopySavedVarData(legacyVars, vars)
        vars.adfwWorldMigrationComplete = true
        vars.adfwWorldKey = worldKey
    end
end

local function SetDealRange(key, value)
    vars.dealRanges[key] = value
    ClearCache()
end

local function SetDealColor(key, r, g, b)
    vars.dealColors[key] = vars.dealColors[key] or {}
    vars.dealColors[key].r = r
    vars.dealColors[key].g = g
    vars.dealColors[key].b = b
    ClearCache()
end

local function AddRangeSlider(options, key, name, tooltip, minValue, maxValue)
    options[#options + 1] = {
        type = "slider",
        name = name,
        tooltip = tooltip,
        min = minValue or -100,
        max = maxValue or 300,
        step = 1,
        getFunc = function()
            return vars.dealRanges[key]
        end,
        setFunc = function(value)
            SetDealRange(key, value)
        end,
        default = DEFAULTS.dealRanges[key],
    }
end

local function AddColorPicker(options, key, name, tooltip)
    options[#options + 1] = {
        type = "colorpicker",
        name = name,
        tooltip = tooltip,
        getFunc = function()
            local color = vars.dealColors[key]
            return color.r, color.g, color.b, 1
        end,
        setFunc = function(r, g, b)
            SetDealColor(key, r, g, b)
        end,
        default = {
            r = DEFAULTS.dealColors[key].r,
            g = DEFAULTS.dealColors[key].g,
            b = DEFAULTS.dealColors[key].b,
            a = 1,
        },
    }
end

RegisterSettings = function()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = ADDON_DISPLAY_NAME,
        displayName = COLOR_TITLE .. ADDON_DISPLAY_NAME .. COLOR_RESET,
        author = "runcarsnowpen",
        version = ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("ADawgsFlipWorthyOptions", panelData)

    local options = {
        {
            type = "checkbox",
            name = "Enable ADFW",
            getFunc = function() return vars.enabled end,
            setFunc = function(value)
                vars.enabled = value
                ClearCache()
                RefreshAGSResults()
            end,
            default = DEFAULTS.enabled,
        },
        {
            type = "dropdown",
            name = "Price preference",
            tooltip = "ADFW tries this TTC field first, then shows the actual field used in the tooltip.",
            choices = {
                "|c66FF66TTC Sales Avg|r",
                "|cFF9900TTC Suggested Avg|r",
                "|cFF3333TTC Listing Avg|r",
                "|cFFD700TTC Companion setting|r",
            },
            choicesValues = { "sale", "suggested", "avg", "companion" },
            getFunc = function() return vars.priceMode end,
            setFunc = function(value)
                vars.priceMode = value
                ClearCache()
            end,
            default = DEFAULTS.priceMode,
        },
        {
            type = "slider",
            name = "Minimum profit for markers",
            min = 0,
            max = 250000,
            step = 1000,
            getFunc = function() return vars.minProfit end,
            setFunc = function(value)
                vars.minProfit = value
                ClearCache()
            end,
            default = DEFAULTS.minProfit,
        },
        {
            type = "checkbox",
            name = "Show inventory marker",
            getFunc = function() return vars.inventoryMarker end,
            setFunc = function(value)
                vars.inventoryMarker = value
                ClearCache()
            end,
            default = DEFAULTS.inventoryMarker,
        },
        {
            type = "checkbox",
            name = "Show guild store marker",
            getFunc = function() return vars.guildStoreMarker end,
            setFunc = function(value)
                vars.guildStoreMarker = value
                ClearCache()
                RefreshAGSResults()
            end,
            default = DEFAULTS.guildStoreMarker,
        },
        {
            type = "checkbox",
            name = "Filter guild store to Sales Avg flips",
            tooltip = "Hides guild store rows unless buying, upgrading, and selling meets your minimum profit using TTC Sales Avg for the Legendary value.",
            getFunc = function() return vars.guildStoreSalesAvgFilter end,
            setFunc = function(value)
                vars.guildStoreSalesAvgFilter = value
                vars.guildStoreSalesAvgFilterMinProfit = nil
                ClearCache()
                if not RefreshAGSResults() then
                    Debug("AGS filter enabled; refresh skipped until guild store search is ready")
                end
            end,
            default = DEFAULTS.guildStoreSalesAvgFilter,
        },
        {
            type = "checkbox",
            name = "Show losses in markers",
            getFunc = function() return vars.showLoss end,
            setFunc = function(value)
                vars.showLoss = value
                ClearCache()
            end,
            default = DEFAULTS.showLoss,
        },
        {
            type = "checkbox",
            name = "Compact marker",
            tooltip = "Show only a colored $ instead of gold value and return percent.",
            getFunc = function() return vars.compactInventoryMarker end,
            setFunc = function(value)
                vars.compactInventoryMarker = value
                ClearCache()
            end,
            default = DEFAULTS.compactInventoryMarker,
        },
        {
            type = "header",
            name = "Deal range thresholds",
        },
    }

    AddRangeSlider(options, "buyit", "Yellow range", "Return percentage needed for yellow.", 0, 300)
    AddRangeSlider(options, "great", "Purple range", "Return percentage needed for purple.", 0, 300)
    AddRangeSlider(options, "good", "Blue range", "Return percentage needed for blue.", 0, 300)
    AddRangeSlider(options, "reasonable", "Green range", "Return percentage needed for green.", 0, 300)
    AddRangeSlider(options, "okay", "White range", "Return percentage needed for white. Values below this are red.", -100, 100)

    options[#options + 1] = {
        type = "header",
        name = "Deal range colors",
    }

    AddColorPicker(options, "buyit", "Yellow range color", "Color used at or above the yellow threshold.")
    AddColorPicker(options, "great", "Purple range color", "Color used at or above the purple threshold.")
    AddColorPicker(options, "good", "Blue range color", "Color used at or above the blue threshold.")
    AddColorPicker(options, "reasonable", "Green range color", "Color used at or above the green threshold.")
    AddColorPicker(options, "okay", "White range color", "Color used at or above the white threshold.")
    AddColorPicker(options, "overpriced", "Red range color", "Color used below the white threshold.")

    options[#options + 1] = {
        type = "button",
        name = "Reset deal ranges and colors",
        func = function()
            vars.dealRanges = {}
            vars.dealColors = {}
            NormalizeSavedVars()
            ClearCache()
            Chat("Deal ranges and colors reset.")
        end,
    }

    LAM:RegisterOptionControls("ADawgsFlipWorthyOptions", options)
end

local function ParseLinkFromText(text)
    if not text then
        return nil
    end
    return text:match("(|H.-|h.-|h)")
end

local function SetMaterialLink(key, link)
    key = key and string.lower(key) or nil
    if not key or not MATERIAL_ALIASES[key] then
        Chat("Unknown material key. Try /adfw help.")
        return
    end
    if not link then
        Chat("Missing item link. Shift-click the material after the command.")
        return
    end
    vars.materialLinks[key] = link
    ClearCache()
    Chat("Saved material " .. COLOR_WARN .. key .. COLOR_RESET .. ": " .. link)
end

local function SetCount(key, value)
    key = key and string.lower(key) or nil
    value = tonumber(value)
    if not vars.counts[key] or not value or value < 0 then
        Chat("Usage: /adfwcount <green|blue|purple|gold> <number>")
        return
    end
    vars.counts[key] = value
    ClearCache()
    Chat("Set " .. key .. " improvement count to " .. tostring(value))
end

local function PrintHelp()
    Chat("/adfw on | off | debug | help | resetmats")
    Chat("/adfw agsfilter on|off, /adfw agsfilter50k on|off, /adfw agsfilter100k on|off")
    Chat("/adfw price suggested|avg|sale|companion")
    Chat("/adfw minprofit <gold>, /adfw showloss on|off")
    Chat("/adfw inventory marker|off, /adfw tooltip inventory|guildstore on|off")
    Chat("/adfwmat <key> [item link]. Keys: alloy, wax, rosin, chromium, grain, elegant, mastic, zircon, plus lower-tier tempers.")
    Chat("/adfwcount <green|blue|purple|gold> <number>")
end

local function HandleMainCommand(args)
    args = args or ""
    local command, a, b = args:match("^(%S*)%s*(%S*)%s*(.-)$")
    command = string.lower(command or "")
    a = string.lower(a or "")

    if command == "on" then
        vars.enabled = true
        ClearCache()
        RefreshAGSResults()
        Chat("Enabled.")
    elseif command == "off" then
        vars.enabled = false
        ClearCache()
        RefreshAGSResults()
        Chat("Disabled.")
    elseif command == "debug" then
        vars.debug = not vars.debug
        Chat("Debug " .. (vars.debug and "on." or "off."))
    elseif command == "resetmats" then
        vars.materialLinks = {}
        ClearCache()
        Chat("Material links reset.")
    elseif command == "price" then
        if a == "suggested" or a == "avg" or a == "sale" or a == "companion" then
            vars.priceMode = a
            ClearCache()
            Chat("Price mode set to " .. a .. ".")
        else
            Chat("Usage: /adfw price suggested|avg|sale|companion")
        end
    elseif command == "minprofit" then
        local amount = tonumber(a)
        if amount then
            vars.minProfit = amount
            ClearCache()
            Chat("Minimum profit set to " .. FormatGold(amount) .. ".")
        else
            Chat("Usage: /adfw minprofit <gold>")
        end
    elseif command == "showloss" then
        vars.showLoss = a == "on"
        ClearCache()
        Chat("Show losses " .. (vars.showLoss and "on." or "off."))
    elseif command == "agsfilter" then
        if a == "on" or a == "off" then
            vars.guildStoreSalesAvgFilter = a == "on"
            vars.guildStoreSalesAvgFilterMinProfit = nil
            ClearCache()
            local refreshed = RefreshAGSResults()
            Chat("Guild store Sales Avg flip filter " .. (vars.guildStoreSalesAvgFilter and "on." or "off."))
            if not refreshed then
                Chat("Open the guild store or run a new search to apply it.")
            end
        else
            Chat("Usage: /adfw agsfilter on|off")
        end
    elseif command == "agsfilter50k" or command == "agsfilter100k" then
        local threshold = command == "agsfilter100k" and 100000 or 50000
        if a == "on" or a == "off" then
            vars.guildStoreSalesAvgFilter = a == "on"
            vars.guildStoreSalesAvgFilterMinProfit = a == "on" and threshold or nil
            ClearCache()
            local refreshed = RefreshAGSResults()
            Chat("Guild store Sales Avg flip filter " .. (vars.guildStoreSalesAvgFilter and ("on, minimum profit " .. FormatGold(threshold) .. ".") or "off."))
            if not refreshed then
                Chat("Open the guild store or run a new search to apply it.")
            end
        else
            Chat("Usage: /adfw " .. command .. " on|off")
        end
    elseif command == "inventory" then
        vars.inventoryMarker = a ~= "off"
        ClearCache()
        Chat("Inventory marker " .. (vars.inventoryMarker and "on." or "off."))
    elseif command == "tooltip" then
        local enabled = b and string.lower(b) == "on"
        if a == "inventory" then
            vars.tooltipInventory = enabled
            Chat("Inventory tooltip " .. (enabled and "on." or "off."))
        elseif a == "guildstore" then
            vars.tooltipGuildStore = enabled
            Chat("Guild store tooltip " .. (enabled and "on." or "off."))
        else
            Chat("Usage: /adfw tooltip inventory|guildstore on|off")
        end
    else
        PrintHelp()
    end
end

local function HandleMaterialCommand(args)
    local key, rest = args:match("^(%S+)%s*(.*)$")
    SetMaterialLink(key, ParseLinkFromText(rest))
end

local function HandleCountCommand(args)
    local key, value = args:match("^(%S+)%s+(%S+)")
    SetCount(key, value)
end

InstallHooks = function()
    HookTooltipMethod(ItemTooltip, "SetBagItem", GetItemLink, "inventory")
    HookTooltipMethod(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink, "guildstore", GetTradingHousePurchasePrice)
    HookTooltipMethod(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink, "guildstore")
    RegisterAwesomeGuildStoreFilter()
    InstallLegendaryTTCContextMenu()
    InstallInventoryMarkerHook()
    InstallCraftingMarkerHooks()
    InstallSmithingResultMarkerHooks()
    InstallAwesomeGuildStoreMarkerHook()
    InstallGuildStoreMarkerHook()
    InstallGamepadInventoryMarkerHook()
    InstallGamepadCraftingMarkerHook()
    InstallGamepadGuildStoreMarkerHook()
end

OnAddonLoaded = function(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    LoadSavedVars()
    NormalizeSavedVars()
    ClearCache()

    SLASH_COMMANDS["/adfw"] = HandleMainCommand
    SLASH_COMMANDS["/adfwmat"] = HandleMaterialCommand
    SLASH_COMMANDS["/adfwcount"] = HandleCountCommand

    InstallHooks()
    RegisterSettings()
    Debug("Loaded " .. ADDON_VERSION)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
