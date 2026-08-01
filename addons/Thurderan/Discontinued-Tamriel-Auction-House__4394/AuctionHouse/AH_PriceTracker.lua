--[[
=============================================================================
 AuctionHouse - PriceTracker
 Tracks item prices locally, computes statistics, and integrates with
 the item tooltip system to show price data while browsing inventory
 or guild stores.
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils

AH.PriceTracker = {}
local PT = AH.PriceTracker

-- Local price observation buffer (before persisting to SavedVariables)
local priceBuffer = {}

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function PT.Initialize()
    Utils.Debug("PriceTracker: Initializing")

    -- Hook into the tooltip system
    PT.HookTooltips()

    -- Periodic cleanup of old price data
    EVENT_MANAGER:RegisterForUpdate(
        AH.name .. "_PriceCleanup",
        3600000,    -- Every hour
        PT.CleanupOldData
    )

    Utils.Debug("PriceTracker: Initialized")
end

---------------------------------------------------------------------------
--  Price Recording
---------------------------------------------------------------------------

--- Record a listing observation (from scanning).
function PT.RecordListing(itemLink, totalPrice, stackCount)
    if not itemLink or not totalPrice or totalPrice <= 0 then return end
    stackCount = math.max(stackCount or 1, 1)

    local itemKey = Utils.GetItemUniqueKey(itemLink)
    if not itemKey then return end

    local unitPrice = totalPrice / stackCount

    PT.AddPriceObservation(itemKey, unitPrice, "listing")
end

--- Record a completed sale (more reliable price data).
function PT.RecordSale(itemLink, totalPrice, stackCount)
    if not itemLink or not totalPrice or totalPrice <= 0 then return end
    stackCount = math.max(stackCount or 1, 1)

    local itemKey = Utils.GetItemUniqueKey(itemLink)
    if not itemKey then return end

    local unitPrice = totalPrice / stackCount

    -- Sales are weighted more heavily than listings
    PT.AddPriceObservation(itemKey, unitPrice, "sale")
end

--- Add a price observation to the tracking system.
function PT.AddPriceObservation(itemKey, unitPrice, source)
    -- Buffer in memory first
    if not priceBuffer[itemKey] then
        priceBuffer[itemKey] = {}
    end

    table.insert(priceBuffer[itemKey], {
        price       = unitPrice,
        timestamp   = Utils.GetTimestamp(),
        source      = source,
    })

    -- Flush buffer periodically
    if Utils.TableCount(priceBuffer) > 200 then
        PT.FlushBuffer()
    end
end

--- Flush the price buffer to SavedVariables.
function PT.FlushBuffer()
    local priceHistory = AH.savedVars.priceHistory
    local maxDays = AH.savedVars.settings.maxPriceHistoryDays
    local cutoff = Utils.GetTimestamp() - (maxDays * 86400)

    for itemKey, observations in pairs(priceBuffer) do
        if not priceHistory[itemKey] then
            priceHistory[itemKey] = {
                observations = {},
                average = 0,
                median = 0,
                min = 0,
                max = 0,
                volume = 0,
                suggested = 0,
                lastUpdated = 0,
                sampleSize = 0,
            }
        end

        local entry = priceHistory[itemKey]
        if not entry.observations then
            entry.observations = {}
        end

        -- Add new observations
        for _, obs in ipairs(observations) do
            table.insert(entry.observations, obs)
        end

        -- Remove observations older than the retention period
        Utils.TableRemoveWhere(entry.observations, function(obs)
            return obs.timestamp < cutoff
        end)

        -- Recompute statistics
        PT.RecomputeStats(itemKey)
    end

    priceBuffer = {}
end

--- Recompute price statistics for an item.
function PT.RecomputeStats(itemKey)
    local entry = AH.savedVars.priceHistory[itemKey]
    if not entry or not entry.observations or #entry.observations == 0 then
        return
    end

    local prices = {}
    local salePrices = {}

    for _, obs in ipairs(entry.observations) do
        table.insert(prices, obs.price)
        if obs.source == "sale" then
            table.insert(salePrices, obs.price)
        end
    end

    table.sort(prices)

    -- Remove outliers using IQR method
    local cleanPrices = PT.RemoveOutliers(prices)

    entry.average     = Utils.Average(cleanPrices)
    entry.median      = Utils.Median(cleanPrices)
    entry.min         = cleanPrices[1] or 0
    entry.max         = cleanPrices[#cleanPrices] or 0
    entry.volume      = #prices
    entry.sampleSize  = #cleanPrices
    entry.lastUpdated = Utils.GetTimestamp()

    -- Suggested price: prefer sale median if enough data, else listing median
    if #salePrices >= 5 then
        entry.suggested = Utils.Median(salePrices)
    else
        entry.suggested = entry.median
    end
end

--- Remove statistical outliers using the IQR method.
function PT.RemoveOutliers(sortedPrices)
    if #sortedPrices < 4 then return sortedPrices end

    local q1Index = math.floor(#sortedPrices * 0.25)
    local q3Index = math.floor(#sortedPrices * 0.75)
    local q1 = sortedPrices[math.max(q1Index, 1)]
    local q3 = sortedPrices[math.max(q3Index, 1)]
    local iqr = q3 - q1

    local lowerBound = q1 - (iqr * 1.5)
    local upperBound = q3 + (iqr * 1.5)

    local cleaned = {}
    for _, price in ipairs(sortedPrices) do
        if price >= lowerBound and price <= upperBound then
            table.insert(cleaned, price)
        end
    end

    return #cleaned > 0 and cleaned or sortedPrices
end

---------------------------------------------------------------------------
--  Price Lookup
---------------------------------------------------------------------------

--- Get price data for an item (with fallback to DataManager).
function PT.GetPriceInfo(itemLink)
    if not itemLink then return nil end

    local itemKey = Utils.GetItemUniqueKey(itemLink)
    if not itemKey then return nil end

    -- Check local history first
    local history = AH.savedVars.priceHistory[itemKey]
    if history and history.average > 0 then
        return history
    end

    -- Check buffer
    if priceBuffer[itemKey] and #priceBuffer[itemKey] > 0 then
        local prices = {}
        for _, obs in ipairs(priceBuffer[itemKey]) do
            table.insert(prices, obs.price)
        end
        return {
            average   = Utils.Average(prices),
            median    = Utils.Median(prices),
            min       = math.min(unpack(prices)),
            max       = math.max(unpack(prices)),
            volume    = #prices,
            suggested = Utils.Median(prices),
            sampleSize = #prices,
            lastUpdated = Utils.GetTimestamp(),
        }
    end

    -- Fall back to DataManager's computation from listings
    return AH.DataManager.GetPriceData(itemLink)
end

--- Get a simple suggested price for an item.
function PT.GetSuggestedPrice(itemLink)
    local info = PT.GetPriceInfo(itemLink)
    if info then
        return info.suggested
    end
    return nil
end

---------------------------------------------------------------------------
--  Tooltip Integration
---------------------------------------------------------------------------

--- Hook into ESO's tooltip system to add price data.
function PT.HookTooltips()
    if not AH.savedVars.settings.showPriceInTooltip then
        return
    end

    -- Hook ItemTooltip
    local origSetLink = ItemTooltip.SetLink
    if origSetLink then
        ItemTooltip.SetLink = function(self, itemLink, ...)
            origSetLink(self, itemLink, ...)
            PT.AddPriceToTooltip(self, itemLink)
        end
    end

    -- Hook PopupTooltip
    local origPopupSetLink = PopupTooltip.SetLink
    if origPopupSetLink then
        PopupTooltip.SetLink = function(self, itemLink, ...)
            origPopupSetLink(self, itemLink, ...)
            PT.AddPriceToTooltip(self, itemLink)
        end
    end

    -- Hook SetBagItem for inventory tooltips
    local origSetBagItem = ItemTooltip.SetBagItem
    if origSetBagItem then
        ItemTooltip.SetBagItem = function(self, bagId, slotIndex, ...)
            origSetBagItem(self, bagId, slotIndex, ...)
            local itemLink = GetItemLink(bagId, slotIndex)
            if itemLink then
                PT.AddPriceToTooltip(self, itemLink)
            end
        end
    end

    -- Hook trading house result tooltips
    local origSetTHResult = ItemTooltip.SetTradingHouseItem
    if origSetTHResult then
        ItemTooltip.SetTradingHouseItem = function(self, tradingHouseIndex, ...)
            origSetTHResult(self, tradingHouseIndex, ...)
            local itemLink = GetTradingHouseSearchResultItemLink(tradingHouseIndex)
            if itemLink then
                PT.AddPriceToTooltip(self, itemLink)
            end
        end
    end

    Utils.Debug("PriceTracker: Tooltip hooks installed")
end

--- Add price information to an item tooltip.
function PT.AddPriceToTooltip(tooltip, itemLink)
    if not tooltip or not itemLink then return end

    local settings = AH.savedVars.settings
    if not settings.showPriceInTooltip then return end

    local priceInfo = PT.GetPriceInfo(itemLink)
    if not priceInfo then return end

    -- Add a separator line
    tooltip:AddLine("")
    tooltip:AddLine(
        Utils.Colorize(string.format("[%s]", AH.displayName), AH.Colors.GOLD),
        "ZoFontGameSmall", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER
    )

    -- Suggested price
    if settings.tooltipShowSuggested and priceInfo.suggested > 0 then
        tooltip:AddLine(
            string.format("  Suggested: %s",
                Utils.Colorize(Utils.FormatGold(math.floor(priceInfo.suggested)), AH.Colors.HIGHLIGHT)),
            "ZoFontGameSmall"
        )
    end

    -- Average price
    if settings.tooltipShowAverage and priceInfo.average > 0 then
        tooltip:AddLine(
            string.format("  Average: %s",
                Utils.Colorize(Utils.FormatGold(math.floor(priceInfo.average)), AH.Colors.WHITE)),
            "ZoFontGameSmall"
        )
    end

    -- Price range
    if settings.tooltipShowRange and priceInfo.min > 0 then
        tooltip:AddLine(
            string.format("  Range: %s - %s",
                Utils.FormatGold(math.floor(priceInfo.min)),
                Utils.FormatGold(math.floor(priceInfo.max))),
            "ZoFontGameSmall"
        )
    end

    -- Volume
    if settings.tooltipShowVolume and priceInfo.volume > 0 then
        tooltip:AddLine(
            string.format("  Seen: %s listings",
                Utils.Colorize(Utils.FormatNumber(priceInfo.volume), AH.Colors.NEUTRAL)),
            "ZoFontGameSmall"
        )
    end
end

---------------------------------------------------------------------------
--  Cleanup
---------------------------------------------------------------------------

--- Remove price data older than the configured retention period.
function PT.CleanupOldData()
    local maxDays = AH.savedVars.settings.maxPriceHistoryDays
    local cutoff = Utils.GetTimestamp() - (maxDays * 86400)
    local removed = 0

    local priceHistory = AH.savedVars.priceHistory

    for itemKey, entry in pairs(priceHistory) do
        if entry.observations then
            local beforeCount = #entry.observations
            Utils.TableRemoveWhere(entry.observations, function(obs)
                return obs.timestamp < cutoff
            end)
            removed = removed + (beforeCount - #entry.observations)

            -- Remove entry entirely if no observations left
            if #entry.observations == 0 then
                priceHistory[itemKey] = nil
            else
                PT.RecomputeStats(itemKey)
            end
        elseif entry.lastUpdated and entry.lastUpdated < cutoff then
            priceHistory[itemKey] = nil
            removed = removed + 1
        end
    end

    if removed > 0 then
        Utils.Debug("PriceTracker: Cleaned up %d old price records", removed)
    end
end
