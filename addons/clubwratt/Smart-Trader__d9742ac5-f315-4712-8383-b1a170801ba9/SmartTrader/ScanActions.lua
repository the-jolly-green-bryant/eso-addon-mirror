-- ScanActions.lua: Imperative actions for guild scanning
-- These functions have side effects (mutate scanState, call APIs)

local CL = SmartTrader.GetLogger()

local ScanActions = {}
local ipairs = ipairs -- LuaLS: mark standard iterator as defined

---Execute a single search from the queue
---@param searchParams SearchParams
local function ExecuteSearch(searchParams)
    local ScanUtils = SmartTrader.ScanUtils
    if GuildFinderIsSearchOnCooldown() then
        CL:Log("[SmartTrader] Search is on cooldown. Trying in one second.")
        zo_callLater(function()
            ExecuteSearch(searchParams)
        end, 1000)
        return
    end

    -- Set search filters
    SetGuildFinderFocusSearchFilter(searchParams.focus.value)
    SetGuildFinderHasTradersSearchFilter(true)
    SetGuildFinderChampionPointsFilterValues(0, 3600)

    -- Clear all size filters first
    local allSizes = {
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_SMALL,    name = "Small" },
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_MEDIUM,   name = "Medium" },
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_LARGE,    name = "Large" },
        { value = GUILD_SIZE_ATTRIBUTE_VALUE_GIGANTIC, name = "Gigantic" },
    }

    for _, size in ipairs(allSizes) do
        SetGuildFinderSizeFilterValue(size.value, false)
    end

    -- Set only the sizes we want
    for _, size in ipairs(searchParams.sizes) do
        SetGuildFinderSizeFilterValue(size.value, true)
    end

    -- Handle alliance filters
    if searchParams.alliance then
        SetGuildFinderAllianceFilterValue(ALLIANCE_ALDMERI_DOMINION, false)
        SetGuildFinderAllianceFilterValue(ALLIANCE_DAGGERFALL_COVENANT, false)
        SetGuildFinderAllianceFilterValue(ALLIANCE_EBONHEART_PACT, false)
        SetGuildFinderAllianceFilterValue(searchParams.alliance.value, true)
    else
        SetGuildFinderAllianceFilterValue(ALLIANCE_ALDMERI_DOMINION, false)
        SetGuildFinderAllianceFilterValue(ALLIANCE_DAGGERFALL_COVENANT, false)
        SetGuildFinderAllianceFilterValue(ALLIANCE_EBONHEART_PACT, false)
    end

    -- Build logging strings
    local sizeStr = ScanUtils.BuildSizeString(searchParams.sizes)
    local allianceStr = ScanUtils.BuildAllianceString(searchParams.alliance)
    local scanState = SmartTrader.state.scanState

    CL:Log(string.format("[SmartTrader] Search %d/%d: %s %s%s",
        scanState.searchesCompleted + 1,
        scanState.totalSearches,
        searchParams.focus.name,
        sizeStr,
        allianceStr))

    -- Start the search
    local searchId = GuildFinderRequestSearch()

    if searchId then
        scanState.currentSearchId = searchId
        scanState.currentSearchParams = searchParams
    else
        CL:Log("[SmartTrader] ERROR: Search request failed! This may be a rate limit violation.")
        CL:Log("[SmartTrader] Stopping scan. Try increasing the delay between searches.")
        scanState.active = false
        scanState.cancelled = true
        scanState.searchQueue = {}
    end
end

---Process the next search in the queue (MUTATES scanState)
local function ProcessNextSearch()
    local GuildUtils = SmartTrader.GuildUtils
    local scanState = SmartTrader.state.scanState

    if scanState.cancelled then
        CL:Log(string.format("[SmartTrader] --- SCAN CANCELLED ---"))
        CL:Log(string.format("[SmartTrader] Completed %d/%d searches before cancelling",
            scanState.searchesCompleted,
            scanState.totalSearches))

        -- Reset scan state
        SmartTrader.state.scanState = {
            active = false,
            cancelled = false,
            searchQueue = {},
            currentSearchId = nil,
            currentSearchParams = nil,
            searchesCompleted = 0,
            totalSearches = 0,
            overflowWarnings = {}
        }
        return
    end

    if #scanState.searchQueue == 0 then
        local guildDataById = SmartTrader.state.savedVars.guildDataById
        local totalCached = GuildUtils.GetCachedCount(guildDataById)

        CL:Log(string.format("[SmartTrader] Completed %d searches", scanState.searchesCompleted))
        CL:Log(string.format("[SmartTrader] Total guilds cached: %d", totalCached))

        if #scanState.overflowWarnings > 0 then
            CL:Log("[SmartTrader] Manual searches needed for:")
            for _, warning in ipairs(scanState.overflowWarnings) do
                CL:Log(string.format("  %s", warning))
            end
        end

        scanState.active = false
        return
    end

    local searchParams = table.remove(scanState.searchQueue, 1)

    zo_callLater(function()
        ExecuteSearch(searchParams)
    end, 3000)
end

---Handle search overflow by splitting the search (MUTATES scanState)
---@param searchParams SearchParams
local function HandleSearchOverflow(searchParams)
    local ScanUtils = SmartTrader.ScanUtils
    local scanState = SmartTrader.state.scanState
    local splits, warning = ScanUtils.SplitSearchParams(searchParams)

    if warning then
        table.insert(scanState.overflowWarnings, warning)
        CL:Log(warning)
    end

    -- Insert splits at the front of the queue
    for i = #splits, 1, -1 do
        table.insert(scanState.searchQueue, 1, splits[i])
    end

    scanState.totalSearches = scanState.totalSearches + #splits
end

---Start a full scan for all guilds with traders (MUTATES scanState)
function ScanActions.StartFullScan()
    local ScanUtils = SmartTrader.ScanUtils
    local scanState = SmartTrader.state.scanState

    if scanState.active then
        CL:Log("[SmartTrader] Scan already in progress! Use /st stop to cancel.")
        return
    end

    -- If cache is currently "expired" (or was cleared), set the next expiry so
    -- we don't re-trigger the auto-rescan on the next PLAYER_ACTIVATED (zone load).
    local savedVars = SmartTrader.state.savedVars
    local now = GetTimeStamp()
    if savedVars and ((not savedVars.nextFlipTime) or (now >= savedVars.nextFlipTime)) then
        local GuildUtils = SmartTrader.GuildUtils
        local baseFlip = GuildUtils.GetNextTraderFlipTime(GetWorldName(), now)
        local grace = 15 * 60 + math.random(0, 15 * 60)
        savedVars.nextFlipTime = baseFlip + grace
    end

    -- Reset and initialize scan state
    ---@type ScanState
    SmartTrader.state.scanState = {
        active = true,
        cancelled = false,
        searchQueue = ScanUtils.BuildSearchQueue(),
        currentSearchId = nil,
        currentSearchParams = nil,
        searchesCompleted = 0,
        totalSearches = 0,
        overflowWarnings = {}
    }

    scanState = SmartTrader.state.scanState
    scanState.totalSearches = #scanState.searchQueue

    CL:Log(string.format("[SmartTrader] --- BEGINNING SCAN ---"))
    CL:Log(string.format("[SmartTrader] Total searches queued: %d", scanState.totalSearches))
    CL:Log(string.format("[SmartTrader] This will take 3s per search. Use /st stop to cancel."))

    ProcessNextSearch()
end

---Cancel ongoing scan (MUTATES scanState)
function ScanActions.CancelScan()
    local scanState = SmartTrader.state.scanState

    if scanState.active then
        CL:Log("[SmartTrader] Cancelling scan...")
        scanState.cancelled = true
    else
        CL:Log("[SmartTrader] No scan is currently running.")
    end
end

---Called when Guild Finder search completes (MUTATES scanState, guildCache)
---@param searchId number
function ScanActions.OnSearchComplete(searchId)
    local GuildActions = SmartTrader.GuildActions
    local numResults = GuildFinderGetNumSearchResults()
    local scanState = SmartTrader.state.scanState

    -- Ignore results if scan was cancelled (prevents late caching after clear)
    if scanState.cancelled then
        return
    end

    if numResults == 0 then
        if searchId == scanState.currentSearchId then
            scanState.currentSearchId = nil
            scanState.searchesCompleted = scanState.searchesCompleted + 1
            ProcessNextSearch()
        end
        return
    end

    local isOurSearch = (searchId == scanState.currentSearchId)
    local searchParams = scanState.currentSearchParams

    if isOurSearch then
        scanState.currentSearchId = nil
        scanState.searchesCompleted = scanState.searchesCompleted + 1

        if numResults >= 100 then
            HandleSearchOverflow(searchParams)
        end
    else
        CL:Log(string.format("[SmartTrader] Caching %d guilds from user search", numResults))
    end

    -- Cache all results
    local cached = 0
    for i = 1, numResults do
        local guildId = GuildFinderGetSearchResultGuildId(i)
        if guildId and guildId ~= 0 then
            if GuildActions.CacheFromGuildFinder(guildId) then
                cached = cached + 1
            end
        end
    end

    if isOurSearch then
        ProcessNextSearch()
    else
        if cached > 0 then
            CL:Log(string.format("[SmartTrader] Cached %d guild%s", cached, cached == 1 and "" or "s"))
        end
    end
end

SmartTrader.ScanActions = ScanActions
