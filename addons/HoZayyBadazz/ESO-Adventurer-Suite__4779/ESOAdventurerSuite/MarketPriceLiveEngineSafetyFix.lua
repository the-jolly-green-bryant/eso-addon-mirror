-- ESO Adventurer Suite
-- v0.29.687+ Live Market safety pass.
-- Makes a completed TTC full-store scan authoritative for that trader and also
-- bounds the older market caches that existed before the Live Market engine.

local EPC = ESOProgressionCoach
if not EPC or not EPC.MarketPriceChecker then return end
local M = EPC.MarketPriceChecker
if M._marketLiveSafety029687 then return end
M._marketLiveSafety029687 = true

local function safeNumber(value)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
    return n
end

local function now()
    if type(GetTimeStamp) == "function" then
        local ok, value = pcall(GetTimeStamp)
        if ok then return safeNumber(value) or 0 end
    end
    return 0
end

local function clean(value)
    local text = tostring(value or "")
    if type(zo_strformat) == "function" then
        local ok, formatted = pcall(zo_strformat, "<<1>>", text)
        if ok and type(formatted) == "string" and formatted ~= "" then text = formatted end
    end
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("[%c]+", " "):gsub("%s+", " ")
    return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function lower(value)
    return string.lower(clean(value))
end

local function currentContext()
    local guildId, guildName = 0, ""
    if type(GetCurrentTradingHouseGuildDetails) == "function" then
        local ok, id, name = pcall(GetCurrentTradingHouseGuildDetails)
        if ok then guildId, guildName = safeNumber(id) or 0, clean(name) end
    end

    local kioskId = nil
    local ttc = rawget(_G, "TamrielTradeCentre")
    if type(ttc) == "table" and type(ttc.GetCurrentKioskID) == "function" then
        local ok, id = pcall(ttc.GetCurrentKioskID, ttc)
        if ok then kioskId = safeNumber(id) end
    end
    return { guildId = guildId, guildName = guildName, kioskId = kioskId }
end

local function sameTrader(record, ctx)
    if type(record) ~= "table" or type(ctx) ~= "table" then return false end
    local recordKiosk = safeNumber(record.kioskId)
    local ctxKiosk = safeNumber(ctx.kioskId)
    local recordGuild = lower(record.guildName)
    local ctxGuild = lower(ctx.guildName)

    if ctxKiosk and recordKiosk and math.floor(ctxKiosk) == math.floor(recordKiosk) then
        return ctxGuild == "" or recordGuild == "" or ctxGuild == recordGuild
    end
    return ctxGuild ~= "" and recordGuild ~= "" and ctxGuild == recordGuild
end

local function pruneGroupRoot(root, rowField, retentionSeconds, maxItems)
    if type(root) ~= "table" then return end
    local currentTime = now()
    local groups = {}

    for key, group in pairs(root) do
        if type(group) ~= "table" then
            root[key] = nil
        else
            local rows = group[rowField]
            if type(rows) ~= "table" then
                root[key] = nil
            else
                local newest = safeNumber(group.lastSeen) or 0
                for id, record in pairs(rows) do
                    local remove = type(record) ~= "table"
                    if not remove then
                        local expireAt = safeNumber(record.expireAt)
                        local seenAt = safeNumber(record.seenAt) or 0
                        if expireAt and expireAt > 0 and expireAt <= currentTime then remove = true end
                        if not remove and seenAt > 0 and currentTime - seenAt > retentionSeconds then remove = true end
                        if seenAt > newest then newest = seenAt end
                    end
                    if remove then rows[id] = nil end
                end
                group.lastSeen = newest
                if next(rows) == nil then
                    root[key] = nil
                else
                    groups[#groups + 1] = { key = key, lastSeen = newest }
                end
            end
        end
    end

    if #groups > maxItems then
        table.sort(groups, function(a, b) return a.lastSeen > b.lastSeen end)
        for i = maxItems + 1, #groups do root[groups[i].key] = nil end
    end
end

function M:PurgeTraderListingsBefore029687(ctx, beforeTime)
    if type(ctx) ~= "table" or clean(ctx.guildName) == "" then return 0 end
    beforeTime = safeNumber(beforeTime) or 0
    if beforeTime <= 0 then return 0 end

    local removed = 0
    local roots = {
        { root = EPC.saved and EPC.saved.marketLiveTopCache029687, field = "rows" },
        { root = EPC.saved and EPC.saved.marketPriceTraderCacheV2029683, field = "traders" },
        { root = EPC.saved and EPC.saved.marketPriceTraderCache029683, field = "traders" },
    }

    for _, spec in ipairs(roots) do
        local root = spec.root
        if type(root) == "table" then
            for key, group in pairs(root) do
                local rows = type(group) == "table" and group[spec.field] or nil
                if type(rows) == "table" then
                    for id, record in pairs(rows) do
                        local seenAt = type(record) == "table" and (safeNumber(record.seenAt) or 0) or 0
                        if seenAt > 0 and seenAt < beforeTime and sameTrader(record, ctx) then
                            rows[id] = nil
                            removed = removed + 1
                        end
                    end
                    if next(rows) == nil then root[key] = nil end
                end
            end
        end
    end
    return removed
end

function M:PruneOlderMarketCaches029687()
    local saved = EPC.saved or {}
    local retentionDays = safeNumber(saved.marketLiveRetentionDays029687) or 7
    retentionDays = math.max(1, math.min(30, retentionDays))
    local retention = retentionDays * 24 * 60 * 60
    local maxItems = math.floor(safeNumber(saved.marketLiveMaxCachedItems029687) or 2400)
    maxItems = math.max(250, math.min(8000, maxItems))

    pruneGroupRoot(saved.marketPriceTraderCacheV2029683, "traders", retention, maxItems)
    pruneGroupRoot(saved.marketPriceTraderCache029683, "traders", retention, maxItems)
end

-- A TTC full-store scan can feed thousands of rows quickly. Do not run a full
-- cache sweep every 1,500 stores while that scan is active; the completed-scan
-- path performs one authoritative prune instead.
local baseStoreLive029687 = M.StoreLiveTopListing029687
if type(baseStoreLive029687) == "function" then
    function M:StoreLiveTopListing029687(record)
        if self.marketLiveScanSession029687 and (safeNumber(self.marketLiveStoresSincePrune029687) or 0) >= 1400 then
            self.marketLiveStoresSincePrune029687 = 0
        end
        return baseStoreLive029687(self, record)
    end
end

local basePrune029687 = M.PruneLiveMarketCache029687
if type(basePrune029687) == "function" then
    function M:PruneLiveMarketCache029687(...)
        local result = basePrune029687(self, ...)
        if not self.marketLiveScanSession029687 then
            self:PruneOlderMarketCaches029687()
        end
        return result
    end
end

local baseFinish029687 = M.FinishCurrentTraderScan029687
if type(baseFinish029687) == "function" then
    function M:FinishCurrentTraderScan029687(reason)
        local session = self.marketLiveScanSession029687
        local ctx = currentContext()
        local startedAt = type(session) == "table" and (safeNumber(session.startedAt) or 0) or 0
        local result = baseFinish029687(self, reason)
        if startedAt > 0 and clean(ctx.guildName) ~= "" then
            local removed = self:PurgeTraderListingsBefore029687(ctx, startedAt)
            if removed > 0 and EPC and type(EPC.Print) == "function" then
                EPC:Print("Live Market removed " .. tostring(removed) .. " older listing" .. (removed == 1 and "" or "s") .. " that the completed trader scan no longer found.")
            end
        end
        self:PruneOlderMarketCaches029687()
        return result
    end
end

-- Building the Guild Trader hub route can inspect many fast-travel nodes. Keep
-- that work user-triggered and cache the result so it never becomes a periodic
-- or login-time FPS cost. Resetting the route clears the cache when a rebuild is wanted.
local baseBuildRoute029687 = M.BuildTraderHubRoute029687
if type(baseBuildRoute029687) == "function" then
    function M:BuildTraderHubRoute029687(force)
        if force ~= true and type(self.marketLiveHubRoute029687) == "table" then
            return self.marketLiveHubRoute029687
        end
        return baseBuildRoute029687(self)
    end
end

EPC.marketPriceLiveEngineSafety029687 = true