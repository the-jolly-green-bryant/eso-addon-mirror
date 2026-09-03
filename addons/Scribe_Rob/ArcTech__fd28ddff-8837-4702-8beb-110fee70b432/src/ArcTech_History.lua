local function SumBankDepositsThisMonth(guildId, displayName)
    local monthStart = GetStartOfCurrentMonthTimestamp()
    local total = 0

    -- If LibHistoire isn't available, you can't do the cached approach.
    if not LibHistoire then
        return 0
    end

    -- 1) Get a cache/iterator for guild bank history (exact call name varies by LibHistoire version)
    -- You’re aiming for: “give me iterable events for (guildId, GUILD_HISTORY_BANK)”
    local category = GUILD_HISTORY_BANK

    local eventsIterator = nil

    -- Common pattern in libs: a function that returns an iterator or a cache object you can iterate.
    -- Replace this with the actual LibHistoire call you have available.
    if LibHistoire.GetGuildHistoryCache then
        local cache = LibHistoire:GetGuildHistoryCache(guildId, category)
        if cache and cache.IterateEvents then
            eventsIterator = cache:IterateEvents()
        end
    end

    if not eventsIterator then
        -- If you can’t get an iterator/cached list from LibHistoire on Xbox,
        -- you may need to fall back to native guild history APIs instead.
        return 0
    end

    local me = string.lower(displayName or "")
    for event in eventsIterator do
        -- You need from each event:
        -- event.timestamp
        -- event.eventType
        -- event.actor (displayName)
        -- event.goldAmount (or similar)

        if event.timestamp and event.timestamp >= monthStart then
            local actor = event.actor and string.lower(event.actor) or ""
            if actor == me then
                -- Filter to “gold deposited” event type
                if event.eventType == GUILD_EVENT_GUILD_BANK_GOLD_ADDED then
                    total = total + (tonumber(event.goldAmount) or 0)
                end
            end
        end
    end

    return total
end