--[[
=============================================================================
 AuctionHouse - SearchEngine
 Provides fast local search, filtering, and sorting of auction listings.
 Operates on the combined dataset from DataManager (server + local data).
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils
local DM = AH.DataManager

AH.SearchEngine = {}
local SE = AH.SearchEngine

-- Cache
local lastSearchText = ""
local lastFilters = {}
local lastSortColumn = ""
local lastSortAscending = true
local cachedResults = {}
local cacheValid = false

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function SE.Initialize()
    Utils.Debug("SearchEngine: Initializing")

    -- Invalidate cache when data updates
    CALLBACK_MANAGER:RegisterCallback(AH.Events.DATA_UPDATED, function()
        cacheValid = false
    end)
    CALLBACK_MANAGER:RegisterCallback(AH.Events.INCOMING_DATA_READY, function()
        cacheValid = false
    end)

    Utils.Debug("SearchEngine: Initialized")
end

---------------------------------------------------------------------------
--  Search Interface
---------------------------------------------------------------------------

--- Execute a search with text query, filters, and sorting.
--- @param searchText string Text to search for (item name).
--- @param filters table Filter criteria (quality, level, price, guild, etc.).
--- @param sortColumn string Column key to sort by.
--- @param sortAscending boolean Sort direction.
--- @return table Array of matching listing records.
--- @return number Total count before pagination.
function SE.Search(searchText, filters, sortColumn, sortAscending)
    searchText = searchText or ""
    filters = filters or {}
    sortColumn = sortColumn or "unitPrice"
    sortAscending = sortAscending ~= false

    -- Check if we can use cached results
    if cacheValid and
       searchText == lastSearchText and
       SE.FiltersEqual(filters, lastFilters) and
       sortColumn == lastSortColumn and
       sortAscending == lastSortAscending then
        return cachedResults, #cachedResults
    end

    Utils.Debug("SearchEngine: Executing search for '%s'", searchText)

    -- Get all available listings
    local allListings = DM.GetAllListings()

    -- Phase 1: Text filter
    local textFiltered = SE.FilterByText(allListings, searchText)

    -- Phase 2: Apply filters
    local filtered = SE.ApplyFilters(textFiltered, filters)

    -- Phase 3: Sort
    local sorted = SE.SortResults(filtered, sortColumn, sortAscending)

    -- Phase 4: Limit results
    local maxResults = AH.UIConfig.MAX_DISPLAY_RESULTS
    local totalCount = #sorted

    if #sorted > maxResults then
        local limited = {}
        for i = 1, maxResults do
            limited[i] = sorted[i]
        end
        sorted = limited
    end

    -- Cache results
    cachedResults = sorted
    lastSearchText = searchText
    lastFilters = Utils.ShallowCopy(filters)
    lastSortColumn = sortColumn
    lastSortAscending = sortAscending
    cacheValid = true

    Utils.Debug("SearchEngine: Found %d results (showing %d)",
        totalCount, #sorted)

    CALLBACK_MANAGER:FireCallbacks(AH.Events.SEARCH_RESULTS_READY, sorted, totalCount)

    return sorted, totalCount
end

--- Invalidate the search cache (force re-search on next query).
function SE.InvalidateCache()
    cacheValid = false
end

---------------------------------------------------------------------------
--  Text Filtering
---------------------------------------------------------------------------

--- Filter listings by text search (item name matching).
function SE.FilterByText(listings, searchText)
    if not searchText or searchText == "" then
        return listings
    end

    local lowerSearch = string.lower(searchText)
    local results = {}

    -- Support multiple search terms separated by spaces
    local searchTerms = {}
    for term in lowerSearch:gmatch("%S+") do
        table.insert(searchTerms, term)
    end

    for _, listing in ipairs(listings) do
        local lowerName = string.lower(listing.itemName or "")
        local lowerSeller = string.lower(listing.seller or "")
        local lowerGuild = string.lower(listing.guildName or "")

        local matchesAll = true
        for _, term in ipairs(searchTerms) do
            if not (string.find(lowerName, term, 1, true) or
                    string.find(lowerSeller, term, 1, true) or
                    string.find(lowerGuild, term, 1, true)) then
                matchesAll = false
                break
            end
        end

        if matchesAll then
            table.insert(results, listing)
        end
    end

    return results
end

---------------------------------------------------------------------------
--  Filter Application
---------------------------------------------------------------------------

--- Apply structured filters to a listing set.
function SE.ApplyFilters(listings, filters)
    if not filters or Utils.TableCount(filters) == 0 then
        return listings
    end

    local results = {}

    for _, listing in ipairs(listings) do
        if SE.MatchesFilters(listing, filters) then
            table.insert(results, listing)
        end
    end

    return results
end

--- Check if a single listing matches all filters.
function SE.MatchesFilters(listing, filters)
    -- Quality filter
    if filters.quality and filters.quality >= 0 then
        if listing.quality ~= filters.quality then
            return false
        end
    end

    -- Level range
    if filters.levelMin and filters.levelMin > 0 then
        if (listing.level or 0) < filters.levelMin then
            return false
        end
    end
    if filters.levelMax and filters.levelMax > 0 then
        if (listing.level or 0) > filters.levelMax then
            return false
        end
    end

    -- Champion Point range
    if filters.cpMin and filters.cpMin > 0 then
        if (listing.championPoints or 0) < filters.cpMin then
            return false
        end
    end
    if filters.cpMax and filters.cpMax > 0 then
        if (listing.championPoints or 0) > filters.cpMax then
            return false
        end
    end

    -- Price range (unit price)
    if filters.priceMin and filters.priceMin > 0 then
        if (listing.unitPrice or 0) < filters.priceMin then
            return false
        end
    end
    if filters.priceMax and filters.priceMax > 0 then
        if (listing.unitPrice or 0) > filters.priceMax then
            return false
        end
    end

    -- Guild name filter
    if filters.guildName and filters.guildName ~= "" then
        if not string.find(string.lower(listing.guildName or ""),
                           string.lower(filters.guildName), 1, true) then
            return false
        end
    end

    -- Item type filter
    if filters.itemType and filters.itemType > 0 then
        if (listing.itemType or 0) ~= filters.itemType then
            return false
        end
    end

    -- Trait type filter
    if filters.traitType and filters.traitType >= 0 then
        if (listing.traitType or 0) ~= filters.traitType then
            return false
        end
    end

    -- Seller filter (exclusion - for blacklist)
    if filters.excludeSellers and #filters.excludeSellers > 0 then
        local sellerLower = string.lower(listing.seller or "")
        for _, blocked in ipairs(filters.excludeSellers) do
            if sellerLower == string.lower(blocked) then
                return false
            end
        end
    end

    -- Category filter
    if filters.category and filters.category > 0 then
        local catDef = AH.CategoryFilters[filters.category]
        if catDef and catDef.filterType then
            if (listing.itemType or 0) ~= catDef.filterType then
                return false
            end
        end
    end

    -- Source filter (server only, local only, or both)
    if filters.source then
        if listing.source ~= filters.source then
            return false
        end
    end

    return true
end

---------------------------------------------------------------------------
--  Sorting
---------------------------------------------------------------------------

--- Sort results by the specified column.
function SE.SortResults(listings, sortColumn, ascending)
    if not sortColumn or sortColumn == "" then
        return listings
    end

    -- Create a copy to avoid mutating the original
    local sorted = {}
    for _, listing in ipairs(listings) do
        table.insert(sorted, listing)
    end

    local comparator = SE.GetComparator(sortColumn, ascending)
    if comparator then
        table.sort(sorted, comparator)
    end

    return sorted
end

--- Get a comparator function for the given sort column.
function SE.GetComparator(column, ascending)
    local keyMap = {
        name = "itemName",
        unitPrice = "unitPrice",
        totalPrice = "price",
        quantity = "quantity",
        quality = "quality",
        level = "level",
        seller = "seller",
        guildName = "guildName",
        timeRemaining = "timeRemaining",
    }

    local key = keyMap[column] or column

    return function(a, b)
        local valA = a[key]
        local valB = b[key]

        -- Handle nil values
        if valA == nil and valB == nil then return false end
        if valA == nil then return not ascending end
        if valB == nil then return ascending end

        -- String comparison
        if type(valA) == "string" then
            valA = string.lower(valA)
            valB = string.lower(tostring(valB))
            if ascending then
                return valA < valB
            else
                return valA > valB
            end
        end

        -- Numeric comparison
        if ascending then
            return valA < valB
        else
            return valA > valB
        end
    end
end

---------------------------------------------------------------------------
--  Aggregate Queries
---------------------------------------------------------------------------

--- Get a summary of available listings by guild.
function SE.GetGuildSummary()
    local allListings = DM.GetAllListings()
    local guildSummary = {}

    for _, listing in ipairs(allListings) do
        local guild = listing.guildName or "Unknown"
        if not guildSummary[guild] then
            guildSummary[guild] = {
                name = guild,
                listingCount = 0,
                totalValue = 0,
            }
        end
        guildSummary[guild].listingCount = guildSummary[guild].listingCount + 1
        guildSummary[guild].totalValue = guildSummary[guild].totalValue + (listing.price or 0)
    end

    -- Convert to array
    local results = {}
    for _, summary in pairs(guildSummary) do
        table.insert(results, summary)
    end

    -- Sort by listing count
    table.sort(results, function(a, b) return a.listingCount > b.listingCount end)

    return results
end

--- Find the best deals for a specific item across all guilds.
function SE.FindBestDeals(itemName, maxResults)
    maxResults = maxResults or 10
    local results = SE.Search(itemName, {}, "unitPrice", true)

    local limited = {}
    for i = 1, math.min(maxResults, #results) do
        limited[i] = results[i]
    end

    return limited
end

--- Get recently scanned listings (most recent first).
function SE.GetRecentListings(maxResults)
    maxResults = maxResults or 50
    local results = SE.Search("", {}, "scanTimestamp", false)

    local limited = {}
    for i = 1, math.min(maxResults, #results) do
        limited[i] = results[i]
    end

    return limited
end

---------------------------------------------------------------------------
--  Helpers
---------------------------------------------------------------------------

--- Compare two filter tables for equality.
function SE.FiltersEqual(a, b)
    if a == b then return true end
    if not a or not b then return false end

    for k, v in pairs(a) do
        if b[k] ~= v then return false end
    end
    for k, v in pairs(b) do
        if a[k] ~= v then return false end
    end

    return true
end
