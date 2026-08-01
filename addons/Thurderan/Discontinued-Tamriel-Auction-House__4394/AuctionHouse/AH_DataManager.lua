--[[
=============================================================================
 AuctionHouse - DataManager
 Manages all data persistence through SavedVariables.
 Handles the data contract between the in-game addon and desktop client:
   - outgoing: Data the addon produces for the client to upload to the server
   - incoming: Data the client downloads from the server for the addon to read
   - metadata: Shared sync status information
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils

AH.DataManager = {}
local DM = AH.DataManager

-- Local state
local incomingListingsCache = {}    -- Parsed incoming listings ready for search
local localListingsCache = {}       -- Locally scanned listings not yet uploaded
local isDirty = false               -- Flag: outgoing data needs to be written

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function DM.Initialize()
    Utils.Debug("DataManager: Initializing")

    -- Parse any existing incoming data from the desktop client
    DM.ProcessIncomingData()

    -- Register a periodic check for new incoming data
    EVENT_MANAGER:RegisterForUpdate(
        AH.name .. "_IncomingCheck",
        15000,  -- Check every 15 seconds
        DM.CheckForIncomingUpdates
    )

    Utils.Debug("DataManager: Initialized with %d cached listings", #incomingListingsCache)
end

---------------------------------------------------------------------------
--  Outgoing Data (Addon -> Desktop Client -> Server)
---------------------------------------------------------------------------

--- Queue scanned listings to be uploaded by the desktop client.
--- @param listings table Array of listing records from the scanner.
function DM.QueueListingsForUpload(listings)
    if not listings or #listings == 0 then return end

    local outgoing = AH.savedVars.outgoing
    local existingCount = #outgoing.listings

    for _, listing in ipairs(listings) do
        -- Build the standardized listing record
        local record = {
            item_link       = listing.itemLink,
            item_id         = Utils.GetItemIDFromLink(listing.itemLink),
            item_name       = Utils.GetCleanItemName(listing.itemLink),
            seller          = listing.sellerName,
            guild_name      = listing.guildName,
            guild_id        = listing.guildId,
            price           = listing.purchasePrice,
            quantity        = listing.stackCount,
            unit_price      = listing.purchasePrice / math.max(listing.stackCount, 1),
            quality         = Utils.GetItemQuality(listing.itemLink),
            level           = GetItemLinkRequiredLevel(listing.itemLink),
            champion_points = GetItemLinkRequiredChampionPoints(listing.itemLink),
            time_remaining  = listing.timeRemaining,
            scan_timestamp  = Utils.GetTimestamp(),
            icon            = Utils.GetItemIcon(listing.itemLink),
            location        = Utils.GetCurrentLocation(),
            item_type       = GetItemLinkItemType(listing.itemLink),
            trait_type       = GetItemLinkTraitType(listing.itemLink),
        }

        table.insert(outgoing.listings, record)
    end

    isDirty = true
    local newCount = #outgoing.listings - existingCount

    Utils.Debug("DataManager: Queued %d listings for upload (total pending: %d)",
        newCount, #outgoing.listings)

    -- If buffer is large, trigger a flush to SavedVariables
    if #outgoing.listings >= AH.ScanConfig.OUTGOING_BUFFER_SIZE then
        Utils.Debug("DataManager: Outgoing buffer full, flushing")
        DM.FlushOutgoingData()
    end

    -- Also cache locally for immediate search
    for _, listing in ipairs(listings) do
        DM.CacheLocalListing(listing)
    end

    -- Fire event so UI can refresh
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED, #outgoing.listings)
end

--- Queue completed sale records for the desktop client.
--- @param saleData table Sale record from EVENT_TRADING_HOUSE_CONFIRM_ITEM_PURCHASE.
function DM.QueueSaleForUpload(saleData)
    if not saleData then return end

    local record = {
        item_link       = saleData.itemLink,
        item_id         = Utils.GetItemIDFromLink(saleData.itemLink),
        item_name       = Utils.GetCleanItemName(saleData.itemLink),
        seller          = saleData.sellerName,
        buyer           = Utils.GetPlayerName(),
        guild_name      = saleData.guildName,
        price           = saleData.purchasePrice,
        quantity        = saleData.stackCount,
        unit_price      = saleData.purchasePrice / math.max(saleData.stackCount, 1),
        sale_timestamp  = Utils.GetTimestamp(),
        tax             = saleData.taxAmount or 0,
    }

    table.insert(AH.savedVars.outgoing.sales, record)
    isDirty = true

    Utils.Debug("DataManager: Queued sale record for %s (%s gold)",
        record.item_name, Utils.FormatNumber(record.price))
end

--- Force flush outgoing data to SavedVariables.
--- Note: ESO automatically persists SavedVariables on /reloadui and logout,
--- but we can force a write by requesting a save.
function DM.FlushOutgoingData()
    if not isDirty then return end
    isDirty = false
    -- SavedVariables are automatically persisted by ESO.
    -- The desktop client will detect the file change and process it.
    Utils.Debug("DataManager: Outgoing data marked for save (%d listings, %d sales)",
        #AH.savedVars.outgoing.listings, #AH.savedVars.outgoing.sales)
end

--- Get the current outgoing data status.
function DM.GetOutgoingStatus()
    return {
        pendingListings = #AH.savedVars.outgoing.listings,
        pendingSales = #AH.savedVars.outgoing.sales,
        lastUploadTime = AH.savedVars.outgoing.last_upload_time,
        lastUploadStatus = AH.savedVars.outgoing.last_upload_status,
    }
end

---------------------------------------------------------------------------
--  Incoming Data (Server -> Desktop Client -> Addon)
---------------------------------------------------------------------------

--- Check if the desktop client has written new incoming data.
function DM.CheckForIncomingUpdates()
    -- With the addon-folder approach, data is only refreshed on /reloadui
    -- This periodic check is kept for future real-time approaches
    local incoming = AH_INCOMING_DATA
    if not incoming then return end

    local lastKnownTime = DM._lastProcessedTime or 0
    local syncTime = incoming.sync_time or ""

    if syncTime ~= "" and syncTime ~= DM._lastProcessedSyncTime then
        Utils.Debug("DataManager: New incoming data detected")
        DM.ProcessIncomingData()
    end
end

--- Process incoming listings from the desktop client.
function DM.ProcessIncomingData()
    local incoming = AH_INCOMING_DATA
    if not incoming then return end

    -- Update connection status from metadata
    local meta = AH_SYNC_METADATA
    if meta then
        AH.savedVars.metadata.last_sync = meta.last_sync or 0
        AH.savedVars.metadata.client_version = meta.client_version or ""
        AH.savedVars.metadata.sync_count = meta.sync_count or 0
    end

    local listings = incoming.ah_listings
    if not listings or type(listings) ~= "table" then return end

    local count = 0
    incomingListingsCache = {}

    for listingId, listing in pairs(listings) do
        if type(listing) == "table" and (listing.itemId or listing.item_id) then
            -- Normalize the listing for search (handle both camelCase and snake_case)
            local normalized = {
                id              = listing.id or listingId,
                itemId          = listing.itemId or listing.item_id,
                itemLink        = listing.itemLink or listing.item_link or "",
                itemName        = listing.itemName or listing.item_name or "Unknown",
                seller          = listing.seller or "",
                sellerOnline    = listing.sellerOnline or false,
                price           = listing.price or 0,
                quantity        = listing.quantity or 1,
                unitPrice       = listing.unitPrice or listing.unit_price or listing.price or 0,
                quality         = listing.quality or 1,
                level           = listing.level or 0,
                championPoints  = listing.championPoints or listing.champion_points or 0,
                timeRemaining   = listing.timeRemaining or listing.time_remaining or 0,
                icon            = listing.icon or "",
                itemType        = listing.itemType or listing.item_type or 0,
                traitType       = listing.traitType or listing.trait_type or 0,
                state           = listing.state or "listed",
                buyer           = listing.buyer,
                source          = "server",
            }
            table.insert(incomingListingsCache, normalized)
            count = count + 1
        end
    end

    DM._lastProcessedSyncTime = incoming.sync_time or ""

    -- Process notifications if present
    local notifications = incoming.ah_notifications

    -- Copy purchases and notifications to savedVars.incoming so
    -- CheckIncomingPurchases and other handlers can find them
    if not AH.savedVars.incoming then AH.savedVars.incoming = {} end
    AH.savedVars.incoming.ah_purchases = incoming.ah_purchases or {}
    AH.savedVars.incoming.ah_notifications = incoming.ah_notifications or {}

    -- Immediately process purchases (seller side - populates COD queue)
    if AH.ListingManager and AH.ListingManager.CheckIncomingPurchases then
        AH.ListingManager.CheckIncomingPurchases()
    end

    Utils.Debug("DataManager: Processed %d incoming listings from server", count)

    -- Process feature data (watchlist, trusted sellers, deals, stats)
    if AH.Features and AH.Features.ProcessServerFeatureData then
        AH.Features.ProcessServerFeatureData()
    end

    CALLBACK_MANAGER:FireCallbacks(AH.Events.INCOMING_DATA_READY, count)
    CALLBACK_MANAGER:FireCallbacks(AH.Events.UI_REFRESH_NEEDED)
end

--- Merge price summary data from the server into local cache.
function DM.MergePriceSummaries(summaries)
    if not summaries then return end

    local priceHistory = AH.savedVars.priceHistory

    for itemKey, summary in pairs(summaries) do
        if type(summary) == "table" then
            priceHistory[itemKey] = {
                average     = summary.average or 0,
                median      = summary.median or 0,
                min         = summary.min or 0,
                max         = summary.max or 0,
                volume      = summary.volume or 0,
                suggested   = summary.suggested or summary.median or 0,
                lastUpdated = summary.last_updated or Utils.GetTimestamp(),
                sampleSize  = summary.sample_size or 0,
            }
        end
    end

    CALLBACK_MANAGER:FireCallbacks(AH.Events.PRICE_DATA_UPDATED)
end

---------------------------------------------------------------------------
--  Local Listing Cache (for immediate search before upload)
---------------------------------------------------------------------------

--- Cache a locally scanned listing for immediate search availability.
function DM.CacheLocalListing(listing)
    local normalized = {
        itemId          = Utils.GetItemIDFromLink(listing.itemLink),
        itemLink        = listing.itemLink,
        itemName        = Utils.GetCleanItemName(listing.itemLink),
        seller          = listing.sellerName,
        guildName       = listing.guildName,
        guildId         = listing.guildId,
        price           = listing.purchasePrice,
        quantity        = listing.stackCount,
        unitPrice       = listing.purchasePrice / math.max(listing.stackCount, 1),
        quality         = Utils.GetItemQuality(listing.itemLink),
        level           = GetItemLinkRequiredLevel(listing.itemLink),
        championPoints  = GetItemLinkRequiredChampionPoints(listing.itemLink),
        timeRemaining   = listing.timeRemaining,
        scanTimestamp   = Utils.GetTimestamp(),
        icon            = Utils.GetItemIcon(listing.itemLink),
        location        = Utils.GetCurrentLocation(),
        itemType        = GetItemLinkItemType(listing.itemLink),
        traitType       = GetItemLinkTraitType(listing.itemLink),
        source          = "local",
    }

    table.insert(localListingsCache, normalized)
end

--- Clear local listing cache (called after successful upload confirmation).
function DM.ClearLocalCache()
    localListingsCache = {}
    Utils.Debug("DataManager: Local listing cache cleared")
end

---------------------------------------------------------------------------
--  Combined Data Access (for Search Engine)
---------------------------------------------------------------------------

--- Get all available listings (server + local).
--- @return table Array of normalized listing records.
function DM.GetAllListings()
    local combined = {}
    local seen = {}

    -- Add server listings first (they take priority)
    for _, listing in ipairs(incomingListingsCache) do
        -- Only show active listings
        local state = listing.state or "listed"
        if state == "listed" then
            table.insert(combined, listing)
            if listing.id then
                seen[listing.id] = true
            end
        end
    end

    -- Add local listings only if not already from server
    for _, listing in ipairs(localListingsCache) do
        local state = listing.state or "listed"
        if state == "listed" and (not listing.id or not seen[listing.id]) then
            table.insert(combined, listing)
        end
    end

    return combined
end

--- Get listings count.
function DM.GetListingCounts()
    return {
        server = #incomingListingsCache,
        localScan = #localListingsCache,
        total = #incomingListingsCache + #localListingsCache,
    }
end

--- Mark a listing as purchased so it's immediately removed from browse.
function DM.MarkListingPurchased(listingId)
    for i, listing in ipairs(incomingListingsCache) do
        if listing.id == listingId then
            listing.state = "awaiting_cod"
            break
        end
    end
    for i, listing in ipairs(localListingsCache) do
        if listing.id == listingId then
            listing.state = "awaiting_cod"
            break
        end
    end
end

---------------------------------------------------------------------------
--  Price History Access
---------------------------------------------------------------------------

--- Get price data for an item.
--- @param itemLink string ESO item link.
--- @return table|nil Price data or nil if not available.
function DM.GetPriceData(itemLink)
    if not itemLink then return nil end

    local itemKey = Utils.GetItemUniqueKey(itemLink)
    if not itemKey then return nil end

    -- Check saved price history
    local history = AH.savedVars.priceHistory[itemKey]
    if history and history.average > 0 then
        return history
    end

    -- Fallback: compute from available listings
    return DM.ComputePriceFromListings(itemLink)
end

--- Compute price statistics from available listings for an item.
function DM.ComputePriceFromListings(itemLink)
    local itemId = Utils.GetItemIDFromLink(itemLink)
    if not itemId then return nil end

    local unitPrices = {}
    local allListings = DM.GetAllListings()

    for _, listing in ipairs(allListings) do
        if listing.itemId == itemId then
            table.insert(unitPrices, listing.unitPrice)
        end
    end

    if #unitPrices == 0 then return nil end

    table.sort(unitPrices)

    -- Remove outliers (top/bottom 10%)
    local trimCount = math.max(1, math.floor(#unitPrices * 0.1))
    local trimmedPrices = {}
    for i = trimCount + 1, #unitPrices - trimCount do
        table.insert(trimmedPrices, unitPrices[i])
    end

    if #trimmedPrices == 0 then
        trimmedPrices = unitPrices
    end

    return {
        average     = Utils.Average(trimmedPrices),
        median      = Utils.Median(trimmedPrices),
        min         = unitPrices[1],
        max         = unitPrices[#unitPrices],
        volume      = #unitPrices,
        suggested   = Utils.Median(trimmedPrices),
        lastUpdated = Utils.GetTimestamp(),
        sampleSize  = #unitPrices,
    }
end

---------------------------------------------------------------------------
--  Scan History
---------------------------------------------------------------------------

--- Record a completed scan.
function DM.RecordScanHistory(guildId, guildName, listingCount, duration)
    local history = AH.savedVars.scanHistory
    table.insert(history, {
        guildId     = guildId,
        guildName   = guildName,
        count       = listingCount,
        duration    = duration,
        timestamp   = Utils.GetTimestamp(),
    })

    -- Keep only last 100 scan records
    while #history > 100 do
        table.remove(history, 1)
    end
end

--- Get the last scan time for a guild.
function DM.GetLastScanTime(guildId)
    local history = AH.savedVars.scanHistory
    for i = #history, 1, -1 do
        if history[i].guildId == guildId then
            return history[i].timestamp
        end
    end
    return 0
end

---------------------------------------------------------------------------
--  Watchlist / Favorites
---------------------------------------------------------------------------

--- Add an item to the watchlist.
function DM.AddToWatchlist(listing)
    if not listing or not listing.id then return false end

    AH.savedVars.watchlist[listing.id] = {
        id              = listing.id,
        itemLink        = listing.itemLink or "",
        itemName        = listing.itemName or "Unknown",
        itemId          = listing.itemId or "",
        icon            = listing.icon or "",
        quality         = listing.quality,
        quantity        = listing.quantity,
        price           = listing.price,
        unitPrice       = listing.unitPrice,
        level           = listing.level,
        championPoints  = listing.championPoints,
        seller          = listing.seller,
        expiresAt       = listing.expiresAt,
        guildName       = listing.guildName,
        state           = listing.state,
        addedTime       = Utils.GetTimestamp(),
    }

    Utils.Print("Added %s to watchlist", listing.itemName or "item")
    return true
end

--- Remove an item from the watchlist.
function DM.RemoveFromWatchlist(itemKey)
    if AH.savedVars.watchlist[itemKey] then
        local name = AH.savedVars.watchlist[itemKey].itemName
        AH.savedVars.watchlist[itemKey] = nil
        Utils.Print("Removed %s from watchlist", name)
        return true
    end
    return false
end

--- Get watchlist items with current best prices.
function DM.GetWatchlistWithPrices()
    local results = {}
    for listingId, watchItem in pairs(AH.savedVars.watchlist) do
        local entry = Utils.ShallowCopy(watchItem)
        entry.watchlistKey = listingId
        table.insert(results, entry)
    end
    table.sort(results, function(a, b)
        return (a.addedTime or 0) > (b.addedTime or 0)
    end)
    return results
end

---------------------------------------------------------------------------
--  Sync Status
---------------------------------------------------------------------------

--- Get the overall sync status for display.
function DM.GetSyncStatus()
    local meta = AH.savedVars.metadata
    local outStatus = DM.GetOutgoingStatus()
    local counts = DM.GetListingCounts()

    return {
        lastSync            = meta.last_sync or 0,
        clientVersion       = meta.client_version or "Not connected",
        syncCount           = meta.sync_count or 0,
        totalUploaded       = meta.total_uploaded or 0,
        totalDownloaded     = meta.total_downloaded or 0,
        pendingListings     = outStatus.pendingListings,
        pendingSales        = outStatus.pendingSales,
        serverListings      = counts.server,
        localListings       = counts.localScan,
        totalListings       = counts.total,
        isClientConnected   = meta.last_sync > 0 and
            (Utils.GetTimestamp() - meta.last_sync) < 300,
    }
end
