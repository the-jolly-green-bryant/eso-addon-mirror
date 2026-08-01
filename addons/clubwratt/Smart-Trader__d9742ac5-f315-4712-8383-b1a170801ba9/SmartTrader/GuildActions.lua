-- GuildActions.lua: Imperative actions that mutate guild cache state
-- These functions have side effects (mutate SmartTrader.state.savedVars.guildDataById)

local CL = SmartTrader.GetLogger()

local GuildActions = {}

---Cache guild data (MUTATES state)
---@param guildId number|nil Can be nil for side glances without guild ID
---@param guildName string|nil Guild name extracted from caption
---@param traderName string|nil NPC name
---@param city string|nil Zone/city name
function GuildActions.CacheGuildData(guildId, guildName, traderName, city)
    local GuildUtils = SmartTrader.GuildUtils
    local guildDataById = SmartTrader.state.savedVars.guildDataById
    local guildDataByTraderName = SmartTrader.state.savedVars.guildDataByTraderName

    -- Check if we already have this guild cached by ID
    if guildId and guildDataById[guildId] then
        local existingEntry = guildDataById[guildId]

        -- UPDATE existing entry - patch in observed data if we have new data
        if traderName and traderName ~= "" then
            local oldTraderName = existingEntry.traderName
            if oldTraderName and oldTraderName ~= "" and oldTraderName ~= traderName then
                -- Remove stale trader-name mapping if it still points at this entry.
                if guildDataByTraderName[oldTraderName] == existingEntry then
                    guildDataByTraderName[oldTraderName] = nil
                end
            end

            if oldTraderName ~= traderName then
                existingEntry.traderName = traderName
            end

            -- Ensure lookup points at this entry (even if we didn't change the name)
            guildDataByTraderName[traderName] = existingEntry
        end

        if city and city ~= "" then
            if existingEntry.city ~= city then
                existingEntry.city = city
            end
        end

        if guildName and guildName ~= "" then
            if not existingEntry.guildName or existingEntry.guildName == "" then
                existingEntry.guildName = guildName
            end
        end

        return
    end

    -- Guild not in cache - CREATE new entry
    local memberCount = nil
    local kioskAttribute = nil

    if not guildName or guildName == "" then
        return
    end

    local cacheEntry = GuildUtils.CreateCacheEntry(
        guildId, guildName, kioskAttribute, memberCount, traderName, city
    )

    -- Store by ID if we have it
    if guildId then
        guildDataById[guildId] = cacheEntry
    end

    -- Store by trader name if we have it
    if traderName and traderName ~= "" then
        guildDataByTraderName[traderName] = cacheEntry
    end
end

---Cache guild data from Guild Finder result (MUTATES state)
---@param guildId number
---@return boolean success
function GuildActions.CacheFromGuildFinder(guildId)
    local GuildUtils = SmartTrader.GuildUtils

    local guildName, kioskAttribute, memberCount = GuildUtils.GetDetailsFromFinder(guildId)

    if not memberCount or memberCount == 0 then
        return false
    end

    -- Parse kiosk attribute to extract trader name and city
    local traderName, city = GuildUtils.ParseKioskAttribute(kioskAttribute)

    -- Create complete cache entry with trader name and city from Guild Finder
    local cacheEntry = GuildUtils.CreateCacheEntry(
        guildId, guildName, kioskAttribute, memberCount, traderName, city
    )

    -- Store in BOTH lookups
    SmartTrader.state.savedVars.guildDataById[guildId] = cacheEntry
    if traderName and traderName ~= "" then
        SmartTrader.state.savedVars.guildDataByTraderName[traderName] = cacheEntry
    end

    return true
end

---Clear trader/location data but preserve cached guild sizes (MUTATES state)
function GuildActions.ClearTraderLocationsPreserveGuilds()
    local state = SmartTrader.state
    local ScanActions = SmartTrader.ScanActions

    if state and state.savedVars then
        -- Clear trader-name lookup so we don't show stale kiosk ownership after flip.
        state.savedVars.guildDataByTraderName = {}

        -- Clear location fields on preserved guild entries.
        local guildDataById = state.savedVars.guildDataById
        if guildDataById then
            for _, data in pairs(guildDataById) do
                if data then
                    data.traderName = nil
                    data.city = nil
                    data.kioskName = nil
                end
            end
        end
    end

    -- Reset reticle dedupe so the next kiosk visit re-caches immediately
    if state and state.reticleState then
        state.reticleState.lastCheckedGuildId = nil
        state.reticleState.lastCheckedTraderName = nil
        state.reticleState.lastFormattedText = nil
    end

    -- Cancel any active scan to prevent late results from re-populating cache
    if ScanActions and state and state.scanState and state.scanState.active then
        ScanActions.CancelScan()
    end

    CL:Log("[SmartTrader] Trader locations cleared (guild sizes preserved)")
end

---Clear all cached guild data (MUTATES state)
function GuildActions.ClearAllCache()
    local state = SmartTrader.state
    local ScanActions = SmartTrader.ScanActions
    local MapActions = SmartTrader.MapActions

    if state and state.savedVars then
        state.savedVars.guildDataById = {}
        state.savedVars.guildDataByTraderName = {}
        state.savedVars.nextFlipTime = nil
    end

    -- Reset reticle dedupe so the next kiosk visit re-caches immediately
    if state and state.reticleState then
        state.reticleState.lastCheckedGuildId = nil
        state.reticleState.lastCheckedTraderName = nil
        state.reticleState.lastFormattedText = nil
    end

    -- Cancel any active scan to prevent late results from re-populating cache
    if ScanActions and state and state.scanState and state.scanState.active then
        ScanActions.CancelScan()
    end

    CL:Log("[SmartTrader] Cache cleared")
end

SmartTrader.GuildActions = GuildActions
