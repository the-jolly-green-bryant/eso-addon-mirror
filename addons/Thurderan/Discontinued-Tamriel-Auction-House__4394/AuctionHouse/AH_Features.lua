--[[
=============================================================================
 AuctionHouse - Features
 New features module: watchlist (server-synced), seller ratings, trusted
 sellers, sale history & stats, daily deals, quick relist, undercut helper,
 bulk listing, seller storefront.
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils
local LM = AH.ListingManager
local DM = AH.DataManager

AH.Features = {}
local F = AH.Features

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function F.Initialize()
    Utils.Debug("Features: Initializing")

    if not AH.savedVars.watchlist then AH.savedVars.watchlist = {} end
    if not AH.savedVars.trustedSellers then AH.savedVars.trustedSellers = {} end
    if not AH.savedVars.saleStats then AH.savedVars.saleStats = {} end
    if not AH.savedVars.deals then AH.savedVars.deals = {} end
    if not AH.savedVars.sellerRatings then AH.savedVars.sellerRatings = {} end

    -- Process server watchlist/trusted data from incoming sync
    F.ProcessServerFeatureData()

    Utils.Debug("Features: Initialized")
end

---------------------------------------------------------------------------
--  Incoming Sync Data Processing
---------------------------------------------------------------------------

--- Called after DataManager processes incoming data to pick up
--- watchlist, trusted sellers, sale stats from the server sync response.
function F.ProcessServerFeatureData()
    local incoming = AH_INCOMING_DATA
    if not incoming then return end

    -- Server watchlist (merge from server, don't overwrite local)
    if incoming.ah_watchlist and type(incoming.ah_watchlist) == "table"
       and #incoming.ah_watchlist > 0 then
        for _, w in ipairs(incoming.ah_watchlist) do
            if w.itemId and w.itemId ~= "" then
                if not AH.savedVars.watchlist[w.itemId] then
                    AH.savedVars.watchlist[w.itemId] = {
                        serverId    = w.id,
                        itemName    = w.itemName or "",
                        itemId      = w.itemId or "",
                        maxPrice    = w.maxPrice or 0,
                        notifyCount = w.notifyCount or 0,
                    }
                end
            end
        end
        Utils.Debug("Features: Merged %d watchlist items from server",
            #incoming.ah_watchlist)
    end

    -- Trusted sellers (merge server data into local, don't overwrite)
    if incoming.ah_trusted_sellers and type(incoming.ah_trusted_sellers) == "table"
       and #incoming.ah_trusted_sellers > 0 then
        for _, t in ipairs(incoming.ah_trusted_sellers) do
            if t.seller and t.seller ~= "" then
                -- Only add from server if not already locally present
                if not AH.savedVars.trustedSellers[t.seller] then
                    AH.savedVars.trustedSellers[t.seller] = {
                        serverId = t.id,
                        notes    = t.notes or "",
                    }
                end
            end
        end
        Utils.Debug("Features: Merged %d trusted sellers from server",
            #incoming.ah_trusted_sellers)
    end

    -- Sale stats summary
    if incoming.ah_sale_stats and type(incoming.ah_sale_stats) == "table" then
        AH.savedVars.saleStats = incoming.ah_sale_stats
    end

    -- Daily deals
    if incoming.ah_deals and type(incoming.ah_deals) == "table" then
        AH.savedVars.deals = incoming.ah_deals
    end

    -- Seller ratings
    if incoming.ah_seller_ratings and type(incoming.ah_seller_ratings) == "table" then
        AH.savedVars.sellerRatings = incoming.ah_seller_ratings
        Utils.Debug("Features: Loaded seller ratings for %d sellers",
            Utils.TableCount(AH.savedVars.sellerRatings))
    end

    -- Watchlist match notifications
    if incoming.ah_notifications and type(incoming.ah_notifications) == "table" then
        for _, n in ipairs(incoming.ah_notifications) do
            if n.type == "watchlist_match" and n.data then
                local d = n.data
                if type(d) == "string" then
                    d = {} -- JSON parsing would happen in desktop client
                end
                local name = (type(d) == "table" and d.item_name) or "item"
                Utils.Print("")
                Utils.Print("%s Watchlist alert: %s is available!",
                    Utils.Colorize("★", AH.Colors.HIGHLIGHT),
                    Utils.Colorize(name, AH.Colors.POSITIVE))
                PlaySound(SOUNDS.QUEST_SHARED)
            end
        end
    end
end

---------------------------------------------------------------------------
--  WATCHLIST (Server-Synced)
---------------------------------------------------------------------------

--- Add an item type to watchlist (by item ID, not specific listing).
--- @param itemName string Display name of the item
--- @param itemId string The item's base ID
--- @param maxPrice number Maximum unit price to alert on (0 = any price)
function F.WatchlistAdd(itemName, itemId, maxPrice)
    if not itemId or itemId == "" then
        Utils.PrintError("Cannot watch item: no item ID.")
        return false
    end
    maxPrice = maxPrice or 0

    -- Save locally
    AH.savedVars.watchlist[itemId] = {
        itemName    = itemName,
        itemId      = itemId,
        maxPrice    = maxPrice,
        notifyCount = 0,
    }

    -- Queue sync to server
    LM.QueueForSync({
        id = "watchlist_" .. itemId,
        itemName = itemName,
        itemId   = itemId,
        maxPrice = maxPrice,
    }, "watchlist_add")

    Utils.Print("Watching %s%s",
        Utils.Colorize(itemName, AH.Colors.HIGHLIGHT),
        maxPrice > 0 and string.format(" (max %s/ea)", Utils.FormatGold(maxPrice)) or "")
    return true
end

--- Add the currently selected browse listing to watchlist.
function F.WatchlistAddFromListing(listing)
    if not listing then
        Utils.PrintError("Select a listing first.")
        return
    end
    F.WatchlistAdd(listing.itemName, listing.itemId, 0)
end

--- Remove an item from watchlist by item ID.
function F.WatchlistRemove(itemId)
    local entry = AH.savedVars.watchlist[itemId]
    if not entry then return false end

    local name = entry.itemName or itemId
    AH.savedVars.watchlist[itemId] = nil

    -- Queue sync to server
    LM.QueueForSync({
        id     = "watchlist_" .. itemId,
        itemId = itemId,
    }, "watchlist_remove")

    Utils.Print("Stopped watching %s", Utils.Colorize(name, AH.Colors.NEUTRAL))
    return true
end

--- Get watchlist items formatted for the scroll list.
function F.GetWatchlist()
    local results = {}
    for itemId, w in pairs(AH.savedVars.watchlist) do
        -- Find current best price from cached listings
        local bestPrice, numListed = F._FindBestPrice(itemId)
        table.insert(results, {
            id              = "watch_" .. itemId,
            itemId          = itemId,
            itemName        = w.itemName or "Unknown",
            maxPrice        = w.maxPrice or 0,
            notifyCount     = w.notifyCount or 0,
            unitPrice       = bestPrice,
            price           = bestPrice,
            quantity        = numListed,
            seller          = numListed > 0
                and string.format("%d listed", numListed)
                or Utils.Colorize("None listed", AH.Colors.NEUTRAL),
            sellerOnline    = false,
            quality         = 1,
            level           = 0,
            championPoints  = 0,
            icon            = "",
            watchlistKey    = itemId,
            source          = "watchlist",
        })
    end
    table.sort(results, function(a, b) return (a.itemName or "") < (b.itemName or "") end)
    return results
end

--- Find the best (lowest) price for an item in the current listing cache.
function F._FindBestPrice(itemId)
    local allListings = DM.GetAllListings()
    local best = nil
    local count = 0
    for _, l in ipairs(allListings) do
        if l.itemId == itemId and l.state ~= "cancelled" and l.state ~= "expired" then
            count = count + 1
            if not best or l.unitPrice < best then
                best = l.unitPrice
            end
        end
    end
    return best or 0, count
end

---------------------------------------------------------------------------
--  TRUSTED SELLERS
---------------------------------------------------------------------------

function F.TrustSeller(sellerName, notes)
    if not sellerName or sellerName == "" then return false end
    notes = notes or ""

    AH.savedVars.trustedSellers[sellerName] = { notes = notes }

    LM.QueueForSync({
        id     = "trust_" .. sellerName,
        seller = sellerName,
        notes  = notes,
    }, "trust_seller")

    Utils.Print("Added %s to trusted sellers.", Utils.Colorize(sellerName, AH.Colors.POSITIVE))
    return true
end

function F.UntrustSeller(sellerName)
    if not AH.savedVars.trustedSellers[sellerName] then return false end

    AH.savedVars.trustedSellers[sellerName] = nil

    LM.QueueForSync({
        id     = "untrust_" .. sellerName,
        seller = sellerName,
    }, "untrust_seller")

    Utils.Print("Removed %s from trusted sellers.", Utils.Colorize(sellerName, AH.Colors.NEUTRAL))
    return true
end

function F.IsTrustedSeller(sellerName)
    return AH.savedVars.trustedSellers[sellerName] ~= nil
end

function F.GetTrustedSellers()
    local results = {}
    for seller, data in pairs(AH.savedVars.trustedSellers) do
        table.insert(results, { seller = seller, notes = data.notes or "" })
    end
    table.sort(results, function(a, b) return a.seller < b.seller end)
    return results
end

---------------------------------------------------------------------------
--  SELLER RATINGS (display from server data cached locally)
---------------------------------------------------------------------------

--- Get seller rating string for display. Data comes from server via sync.
function F.GetSellerRatingText(sellerName)
    local ratings = AH.savedVars.sellerRatings
    if not ratings or not ratings[sellerName] then return nil end
    local r = ratings[sellerName]
    local avgTime = r.avg_cod_time_seconds or r.avg_cod_time
    local totalSales = r.total_sales or 0
    if not avgTime or totalSales == 0 then return nil end

    local timeStr = F.FormatDuration(avgTime)
    local tag
    if avgTime < 1800 then       -- under 30 min
        tag = Utils.Colorize("Lightning", AH.Colors.POSITIVE)
    elseif avgTime < 3600 then   -- under 1 hour
        tag = Utils.Colorize("Fast", AH.Colors.POSITIVE)
    elseif avgTime < 86400 then  -- under 24 hours
        tag = Utils.Colorize("Reliable", AH.Colors.HIGHLIGHT)
    else
        tag = Utils.Colorize("Slow", AH.Colors.NEUTRAL)
    end

    return string.format("%s seller (%s avg, %d sales)", tag, timeStr, totalSales)
end

function F.FormatDuration(seconds)
    if not seconds or seconds <= 0 then return "N/A" end
    if seconds < 60 then return string.format("%ds", seconds) end
    if seconds < 3600 then return string.format("%dm", math.floor(seconds / 60)) end
    if seconds < 86400 then return string.format("%.1fh", seconds / 3600) end
    return string.format("%.1fd", seconds / 86400)
end

---------------------------------------------------------------------------
--  SALE HISTORY & STATS
---------------------------------------------------------------------------

--- Get sale stats from server data. Updated each sync.
function F.GetSaleStats()
    return AH.savedVars.saleStats or {
        sold_7d   = 0,
        gold_7d   = 0,
        bought_7d = 0,
        spent_7d  = 0,
    }
end

--- Get formatted sale stats text for UI display.
function F.GetSaleStatsText()
    local s = F.GetSaleStats()
    return string.format(
        "7-Day Summary: %s sold for %s | %s bought for %s",
        Utils.Colorize(tostring(s.sold_7d or 0), AH.Colors.HIGHLIGHT),
        Utils.Colorize(Utils.FormatGold(s.gold_7d or 0), AH.Colors.POSITIVE),
        Utils.Colorize(tostring(s.bought_7d or 0), AH.Colors.HIGHLIGHT),
        Utils.Colorize(Utils.FormatGold(s.spent_7d or 0), AH.Colors.NEUTRAL)
    )
end

--- Get sale history from my completed listings (local savedVars).
function F.GetSaleHistory()
    local results = {}
    if not AH.savedVars.myListings then return results end
    for id, listing in pairs(AH.savedVars.myListings) do
        if listing.state == "completed" or listing.state == "cod_sent" or
           listing.state == "awaiting_cod" then
            local entry = Utils.ShallowCopy(listing)
            entry.source = "sale_history"
            table.insert(results, entry)
        end
    end
    table.sort(results, function(a, b)
        return (a.createdAt or 0) > (b.createdAt or 0)
    end)
    return results
end

---------------------------------------------------------------------------
--  DAILY DEALS (items below market average)
---------------------------------------------------------------------------

--- Get daily deals from server-synced data.
function F.GetDeals()
    local deals = AH.savedVars.deals or {}
    local results = {}
    for _, d in ipairs(deals) do
        local entry = {
            id              = d.id or "",
            itemName        = d.item_name or d.itemName or "Unknown",
            itemId          = d.item_id or d.itemId or "",
            itemLink        = d.item_link or d.itemLink or "",
            icon            = d.icon or "",
            quality         = d.quality or 1,
            quantity        = d.quantity or 1,
            price           = d.price or 0,
            unitPrice       = d.unit_price or d.unitPrice or 0,
            seller          = d.seller or "",
            sellerOnline    = d.seller_online or false,
            level           = d.level or 0,
            championPoints  = d.champion_points or d.championPoints or 0,
            timeRemaining   = d.time_remaining or d.timeRemaining or 0,
            marketAvg       = d.market_avg or d.marketAvg or 0,
            discountPct     = d.discount_pct or d.discountPct or 0,
            state           = "listed",
            source          = "deal",
        }
        table.insert(results, entry)
    end
    table.sort(results, function(a, b)
        return (a.discountPct or 0) > (b.discountPct or 0)
    end)
    return results
end

---------------------------------------------------------------------------
--  QUICK RELIST
---------------------------------------------------------------------------

--- Relist an expired or cancelled listing at the same (or new) price.
function F.QuickRelist(listingId, newPrice)
    if not AH.savedVars.myListings then return end
    local listing = AH.savedVars.myListings[listingId]
    if not listing then
        Utils.PrintError("Listing not found for relist.")
        return
    end
    if listing.state ~= "expired" and listing.state ~= "cancelled" then
        Utils.PrintError("Only expired or cancelled listings can be relisted.")
        return
    end

    -- Find the item in inventory
    local bagId, slotIndex = LM.FindItemInInventory(listing.itemLink)
    if not bagId then
        Utils.PrintError("Item not found in inventory: %s",
            Utils.Colorize(listing.itemName or "Unknown", AH.Colors.NEUTRAL))
        return
    end

    -- Build item info and list it
    local price = newPrice or listing.price
    local itemLink = GetItemLink(bagId, slotIndex)
    local _, stackCount = GetItemInfo(bagId, slotIndex)

    local itemInfo = {
        bagId           = bagId,
        slotIndex       = slotIndex,
        itemLink        = itemLink,
        itemName        = Utils.GetCleanItemName(itemLink),
        itemId          = Utils.GetItemIDFromLink(itemLink),
        icon            = Utils.GetItemIcon(itemLink),
        stackCount      = listing.quantity or stackCount,
        quality         = Utils.GetItemQuality(itemLink),
        level           = GetItemLinkRequiredLevel(itemLink),
        championPoints  = GetItemLinkRequiredChampionPoints(itemLink),
        traitType       = GetItemLinkTraitType(itemLink),
        itemType        = GetItemLinkItemType(itemLink),
        suggestedPrice  = math.floor(price / math.max(listing.quantity or 1, 1)),
    }

    -- Remove old listing from local data
    AH.savedVars.myListings[listingId] = nil

    -- Confirm the new listing directly
    LM.ConfirmListing(itemInfo, price, itemInfo.stackCount, 3) -- default 48h duration

    Utils.Print("Relisted %s for %s",
        Utils.Colorize(itemInfo.itemName, AH.Colors.HIGHLIGHT),
        Utils.Colorize(Utils.FormatGold(price), AH.Colors.POSITIVE))
end

---------------------------------------------------------------------------
--  UNDERCUT HELPER
---------------------------------------------------------------------------

--- Get undercut pricing info for an item.
--- @param itemId string Item base ID
--- @return table { lowest, numListed, suggested }
function F.GetUndercutInfo(itemId)
    if not itemId or itemId == "" then return nil end

    local allListings = DM.GetAllListings()
    local lowest = nil
    local count = 0
    local prices = {}

    for _, l in ipairs(allListings) do
        if l.itemId == itemId and l.state ~= "cancelled" and l.state ~= "expired" then
            count = count + 1
            table.insert(prices, l.unitPrice)
            if not lowest or l.unitPrice < lowest then
                lowest = l.unitPrice
            end
        end
    end

    local undercut = lowest and math.max(1, math.floor(lowest * 0.99)) or nil

    return {
        lowest      = lowest,
        numListed   = count,
        undercut    = undercut,
        matchPrice  = lowest,
    }
end

---------------------------------------------------------------------------
--  BULK LISTING
---------------------------------------------------------------------------

--- Get all tradeable items from backpack for bulk listing.
function F.GetBulkListCandidates()
    -- Build a set of item links already listed
    local listedLinks = {}
    if AH.savedVars.myListings then
        for _, listing in pairs(AH.savedVars.myListings) do
            if listing.state == "listed" or listing.state == "awaiting_cod" then
                listedLinks[listing.itemLink] = true
            end
        end
    end

    local items = {}
    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local itemLink = GetItemLink(BAG_BACKPACK, slot)
        if itemLink and itemLink ~= "" and not IsItemBound(BAG_BACKPACK, slot) then
            -- Skip already listed items
            if not listedLinks[itemLink] then
                local itemType = GetItemType(BAG_BACKPACK, slot)
                if itemType ~= ITEMTYPE_QUEST and itemType ~= ITEMTYPE_TROPHY then
                    local _, stackCount = GetItemInfo(BAG_BACKPACK, slot)
                    local itemName = Utils.GetCleanItemName(itemLink)
                    local itemId = Utils.GetItemIDFromLink(itemLink)
                    local suggestedPrice = 0
                    if AH.PriceTracker and AH.PriceTracker.GetSuggestedPrice then
                        suggestedPrice = AH.PriceTracker.GetSuggestedPrice(itemLink) or 0
                    end
                    table.insert(items, {
                        bagId           = BAG_BACKPACK,
                        slotIndex       = slot,
                        itemLink        = itemLink,
                        itemName        = itemName,
                        itemId          = itemId,
                        icon            = Utils.GetItemIcon(itemLink),
                        stackCount      = stackCount,
                        quantity        = stackCount,
                        quality         = Utils.GetItemQuality(itemLink),
                        level           = GetItemLinkRequiredLevel(itemLink),
                        championPoints  = GetItemLinkRequiredChampionPoints(itemLink),
                        traitType       = GetItemLinkTraitType(itemLink),
                        itemType        = GetItemLinkItemType(itemLink),
                        suggestedPrice  = suggestedPrice,
                        totalPrice      = math.floor(suggestedPrice * stackCount),
                        price           = math.floor(suggestedPrice * stackCount),
                        unitPrice       = math.floor(suggestedPrice),
                        seller          = suggestedPrice > 0
                            and Utils.FormatGold(math.floor(suggestedPrice)) .. "/ea"
                            or Utils.Colorize("No price data", AH.Colors.NEUTRAL),
                        sellerOnline    = false,
                        state           = "listed",
                        timeRemaining   = 0,
                        id              = "bulk_" .. tostring(slot),
                        selected        = false,
                        source          = "bulk",
                    })
                end
            end
        end
    end
    table.sort(items, function(a, b)
        if a.quality ~= b.quality then return a.quality > b.quality end
        return a.itemName < b.itemName
    end)
    return items
end

--- List multiple items at once with their suggested prices.
function F.BulkList(items)
    if not items or #items == 0 then
        Utils.PrintError("No items to list.")
        return 0
    end
    local listed = 0
    for _, item in ipairs(items) do
        if item.selected and item.totalPrice > 0 then
            -- Verify item is still in that slot
            local currentLink = GetItemLink(item.bagId, item.slotIndex)
            if currentLink == item.itemLink then
                local itemInfo = {
                    bagId           = item.bagId,
                    slotIndex       = item.slotIndex,
                    itemLink        = item.itemLink,
                    itemName        = item.itemName,
                    itemId          = item.itemId,
                    icon            = item.icon,
                    stackCount      = item.stackCount,
                    quality         = item.quality,
                    level           = item.level,
                    championPoints  = item.championPoints,
                    traitType       = item.traitType,
                    itemType        = item.itemType,
                    suggestedPrice  = item.suggestedPrice,
                }
                LM.ConfirmListing(itemInfo, item.totalPrice, item.stackCount, 3)
                listed = listed + 1
            end
        end
    end
    if listed > 0 then
        Utils.Print("Bulk listed %d items.", listed)
    end
    return listed
end

---------------------------------------------------------------------------
--  SELLER STOREFRONT
---------------------------------------------------------------------------

--- Get all active listings from a specific seller.
function F.GetSellerListings(sellerName)
    if not sellerName or sellerName == "" then return {} end

    local allListings = DM.GetAllListings()
    local results = {}
    for _, l in ipairs(allListings) do
        if l.seller == sellerName and l.state ~= "cancelled" and l.state ~= "expired" then
            local entry = Utils.ShallowCopy(l)
            entry.source = "storefront"
            table.insert(results, entry)
        end
    end
    table.sort(results, function(a, b) return (a.itemName or "") < (b.itemName or "") end)
    return results
end

---------------------------------------------------------------------------
--  PRICE TOOLTIP ENHANCEMENT
---------------------------------------------------------------------------

--- Get price trend text for item tooltips.
function F.GetPriceTrendTooltip(itemLink)
    if not itemLink or not AH.PriceTracker then return nil end

    local info = AH.PriceTracker.GetPriceInfo(itemLink)
    if not info then return nil end

    local parts = {}

    if info.suggested and info.suggested > 0 then
        table.insert(parts, string.format("TAH Avg: %s", Utils.FormatGold(info.suggested)))
    end
    if info.minPrice and info.minPrice > 0 then
        table.insert(parts, string.format("Low: %s", Utils.FormatGold(info.minPrice)))
    end
    if info.saleCount and info.saleCount > 0 then
        table.insert(parts, string.format("%d sales", info.saleCount))
    end

    -- Check undercut info
    local itemId = Utils.GetItemIDFromLink(itemLink)
    local undercut = F.GetUndercutInfo(itemId)
    if undercut and undercut.numListed > 0 then
        table.insert(parts, string.format("%d listed (low: %s)",
            undercut.numListed, Utils.FormatGold(undercut.lowest)))
    end

    if #parts == 0 then return nil end
    return table.concat(parts, " | ")
end

--- Hook item tooltips to show price data.
function F.HookTooltips()
    -- Hook PopupTooltip (linked items in chat)
    if PopupTooltip and PopupTooltip.SetLink then
        ZO_PreHook(PopupTooltip, "SetLink", function(self, link)
            zo_callLater(function()
                if self:IsHidden() then return end
                local text = F.GetPriceTrendTooltip(link)
                if text then
                    self:AddLine(Utils.Colorize("[TAH] ", "FFD700") .. text,
                        "ZoFontGameSmall")
                end
            end, 50)
        end)
    end

    -- Hook ItemTooltip (inventory hover)
    if ItemTooltip and ItemTooltip.SetBagItem then
        local origSetBagItem = ItemTooltip.SetBagItem
        ItemTooltip.SetBagItem = function(self, bagId, slotIndex, ...)
            origSetBagItem(self, bagId, slotIndex, ...)
            zo_callLater(function()
                if self:IsHidden() then return end
                local itemLink = GetItemLink(bagId, slotIndex)
                if itemLink and itemLink ~= "" then
                    local text = F.GetPriceTrendTooltip(itemLink)
                    if text then
                        self:AddLine(Utils.Colorize("[TAH] ", "FFD700") .. text,
                            "ZoFontGameSmall")
                    end
                end
            end, 50)
        end
    end

    -- Hook ItemTooltip SetLink (for browse/other tooltips)
    if ItemTooltip and ItemTooltip.SetLink then
        local origSetLink = ItemTooltip.SetLink
        ItemTooltip.SetLink = function(self, link, ...)
            origSetLink(self, link, ...)
            zo_callLater(function()
                if self:IsHidden() then return end
                local text = F.GetPriceTrendTooltip(link)
                if text then
                    self:AddLine(Utils.Colorize("[TAH] ", "FFD700") .. text,
                        "ZoFontGameSmall")
                end
            end, 50)
        end
    end
end

---------------------------------------------------------------------------
--  Context Menu Additions
---------------------------------------------------------------------------

--- Add "Watch Item" and "View Seller" context menu entries.
function F.HookContextMenuExtras()
    local lcm = LibCustomMenu
    if not lcm then return end

    -- Already registered main "List on TAH" in ListingManager.
    -- Add additional context items here.
    lcm:RegisterContextMenu(function(inventorySlot, slotActions)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if not bagId or not slotIndex then return end
        local itemLink = GetItemLink(bagId, slotIndex)
        if not itemLink or itemLink == "" then return end

        local itemId = Utils.GetItemIDFromLink(itemLink)
        local itemName = Utils.GetCleanItemName(itemLink)

        -- Watch / Unwatch toggle
        if itemId and itemId ~= "" then
            if AH.savedVars.watchlist[itemId] then
                AddCustomMenuItem(
                    Utils.Colorize("Unwatch (TAH)", "AAAAAA"),
                    function() F.WatchlistRemove(itemId) end
                )
            else
                AddCustomMenuItem(
                    Utils.Colorize("Watch on TAH", "44DDFF"),
                    function() F.WatchlistAdd(itemName, itemId, 0) end
                )
            end
        end
    end, lcm.CATEGORY_LATE)
end

---------------------------------------------------------------------------
--  SLASH COMMANDS
---------------------------------------------------------------------------

function F.RegisterCommands()
    -- /ah watch <item name>
    -- /ah unwatch <item name>
    -- /ah trust <player name>
    -- /ah untrust <player name>
    -- /ah deals
    -- /ah stats
    -- /ah relist
    -- /ah bulk
    -- /ah storefront <seller name>
    -- These are registered in AuctionHouse.lua as sub-commands
end
