GuildSalesJournal = GuildSalesJournal or {}
local GSJ = GuildSalesJournal

GSJ.name = "GuildSalesJournal"
GSJ.version = "0.0.9"
GSJ.tag = "[GSJ]"

GSJ.STORAGE_PROFILES = {
    compact = { name = "Compact", maxEntries = 1000, purgeBatch = 250 },
    balanced = { name = "Balanced", maxEntries = 2000, purgeBatch = 500 },
    extended = { name = "Extended", maxEntries = 5000, purgeBatch = 1000 },
}

local DEFAULT_SETTINGS = {
    version = 2,
    refreshMode = "AUTO",
    storageProfile = "balanced",
    maxEntries = 2000,
    purgeBatch = 500,
    lastScanAt = 0,
    lastScanInspected = 0,
    lastScanImported = 0,
    lastScanGuilds = {},
    diagnosticSellerSamples = {},
    playerDisplayNameRaw = "",
    playerDisplayNameNormalized = "",
}

local DEFAULT_SALES = {
    version = 2,
    records = {},
    count = 0,
}

function GSJ:Message(text)
    d(string.format("%s %s", self.tag, tostring(text)))
end

function GSJ:CountRecords(records)
    local count = 0
    for _ in pairs(records or {}) do
        count = count + 1
    end
    return count
end

function GSJ:GetStorageProfile()
    return self.STORAGE_PROFILES[self.settings.storageProfile] or self.STORAGE_PROFILES.balanced
end

function GSJ:ApplyStorageProfile(profileKey)
    local profile = self.STORAGE_PROFILES[profileKey] or self.STORAGE_PROFILES.balanced
    self.settings.storageProfile = profileKey
    self.settings.maxEntries = profile.maxEntries
    self.settings.purgeBatch = profile.purgeBatch
    self:PurgeOldestRecords(true)
end

function GSJ:PurgeOldestRecords(forceToMaximum)
    local records = self.sales.records
    local count = self:CountRecords(records)
    local maximum = tonumber(self.settings.maxEntries) or 2000

    if count <= maximum then
        self.sales.count = count
        return 0
    end

    local ordered = {}
    for eventKey, record in pairs(records) do
        ordered[#ordered + 1] = {
            key = eventKey,
            timestamp = tonumber(record[2]) or 0,
        }
    end

    table.sort(ordered, function(a, b)
        if a.timestamp == b.timestamp then
            return tostring(a.key) < tostring(b.key)
        end
        return a.timestamp < b.timestamp
    end)

    local excess = count - maximum
    local removeCount = forceToMaximum and excess
        or math.max(excess, tonumber(self.settings.purgeBatch) or 500)
    removeCount = math.min(removeCount, count)

    for index = 1, removeCount do
        records[ordered[index].key] = nil
    end

    self.sales.count = self:CountRecords(records)
    return removeCount
end


function GSJ:NormalizeAccountName(name)
    local value = tostring(name or "")
    if zo_strtrim then value = zo_strtrim(value) end
    if zo_strlower then
        value = zo_strlower(value)
    else
        value = string.lower(value)
    end
    value = value:gsub("^@", "")
    return value
end

function GSJ:IsPlayerSeller(sellerDisplayName)
    local seller = self:NormalizeAccountName(sellerDisplayName)
    if seller == "" then return false end

    local playerRaw = GetDisplayName and GetDisplayName() or ""
    local player = self:NormalizeAccountName(playerRaw)
    if seller == player then return true end

    if ZO_FormatUserFacingDisplayName then
        local formatted = ZO_FormatUserFacingDisplayName(playerRaw)
        if seller == self:NormalizeAccountName(formatted) then
            return true
        end
    end

    return false
end

function GSJ:GetOrCreateHistoryRequest(guildId)
    self.historyRequests = self.historyRequests or {}
    local request = self.historyRequests[guildId]
    if request and request.requestId and request.requestId ~= 0 then
        return request
    end

    if not CreateGuildHistoryRequest then return nil end
    local requestId = CreateGuildHistoryRequest(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
    if not requestId or requestId == 0 then return nil end

    request = { requestId = requestId, guildId = guildId }
    self.historyRequests[guildId] = request
    return request
end

function GSJ:RequestTraderHistoryForGuild(guildId)
    local request = self:GetOrCreateHistoryRequest(guildId)
    if not request or not RequestMoreGuildHistoryEvents then
        return false
    end

    if TryCleanExistingGuildHistoryRequestParameters then
        pcall(TryCleanExistingGuildHistoryRequestParameters, guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
    end

    local queueIfOnCooldown = true
    local ok = pcall(RequestMoreGuildHistoryEvents, request.requestId, queueIfOnCooldown)
    return ok
end

function GSJ:RequestAllTraderHistory()
    local requested = 0
    for _, source in ipairs(self:GetGuildSources()) do
        if self:RequestTraderHistoryForGuild(source.guildId) then
            requested = requested + 1
        end
    end
    return requested
end

function GSJ:StoreSale(guildId, eventId, timestampS, buyerDisplayName, itemLink, quantity, price, tax)
    local eventKey = tostring(eventId)
    if self.sales.records[eventKey] then
        return false
    end

    -- Compact indexed record:
    -- 1 guildId, 2 timestamp, 3 buyer, 4 itemLink, 5 quantity, 6 price, 7 tax
    self.sales.records[eventKey] = {
        guildId,
        timestampS,
        buyerDisplayName,
        itemLink,
        quantity,
        price,
        tax,
    }
    self.sales.count = self.sales.count + 1
    return true
end

function GSJ:GetGuildSources()
    local sources = {}
    if not GetNumGuilds or not GetGuildId then return sources end

    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if guildId and guildId > 0 then
            sources[#sources + 1] = {
                guildIndex = guildIndex,
                guildId = guildId,
                name = (GetGuildName and GetGuildName(guildId)) or ("Guild " .. tostring(guildIndex)),
            }
        end
    end
    return sources
end

function GSJ:GetGuildNameSafe(guildId)
    if GetGuildName then
        local name = GetGuildName(guildId)
        if name and name ~= "" then return name end
    end
    return "Guild " .. tostring(guildId or "?")
end

function GSJ:ScanCachedHistory(silent)
    if not GetNumGuilds or not GetNumGuildHistoryEvents or not GetGuildHistoryTraderEventInfo then
        self:Message("Guild History API is unavailable.")
        return false
    end

    local playerRaw = GetDisplayName and GetDisplayName() or ""
    local playerNormalized = self:NormalizeAccountName(playerRaw)
    local imported = 0
    local inspected = 0
    local traderSales = 0
    local sellerMatches = 0
    local redacted = 0
    local sourceStats = {}
    local sellerSamples = {}
    local sources = self:GetGuildSources()

    for _, source in ipairs(sources) do
        local eventCount = GetNumGuildHistoryEvents(source.guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER) or 0
        local guildImported = 0
        local guildSellerMatches = 0
        local guildTraderSales = 0
        local guildRedacted = 0

        for eventIndex = 1, eventCount do
            local eventId, timestampS, isRedacted, eventType,
                sellerDisplayName, buyerDisplayName, itemLink,
                quantity, price, tax = GetGuildHistoryTraderEventInfo(source.guildId, eventIndex)

            inspected = inspected + 1

            if isRedacted then
                redacted = redacted + 1
                guildRedacted = guildRedacted + 1
            else
                -- Trader history currently represents completed trader transactions.
                -- Do not depend on one enum name being present on every console API build:
                -- require the transaction fields instead.
                local looksLikeSale = eventId ~= nil
                    and sellerDisplayName ~= nil
                    and itemLink ~= nil
                    and tonumber(quantity) ~= nil
                    and tonumber(price) ~= nil

                if looksLikeSale then
                    traderSales = traderSales + 1
                    guildTraderSales = guildTraderSales + 1

                    if #sellerSamples < 8 and sellerDisplayName and sellerDisplayName ~= "" then
                        sellerSamples[#sellerSamples + 1] = tostring(sellerDisplayName)
                    end

                    if self:IsPlayerSeller(sellerDisplayName) then
                        sellerMatches = sellerMatches + 1
                        guildSellerMatches = guildSellerMatches + 1

                        if self:StoreSale(
                            source.guildId,
                            eventId,
                            timestampS,
                            buyerDisplayName,
                            itemLink,
                            quantity,
                            price,
                            tax
                        ) then
                            imported = imported + 1
                            guildImported = guildImported + 1
                        end
                    end
                end
            end
        end

        sourceStats[#sourceStats + 1] = {
            guildIndex = source.guildIndex,
            guildId = source.guildId,
            name = source.name,
            cachedEvents = eventCount,
            traderSales = guildTraderSales,
            sellerMatches = guildSellerMatches,
            imported = guildImported,
            redacted = guildRedacted,
        }
    end

    local purged = self:PurgeOldestRecords(false)
    self.settings.lastScanAt = GetTimeStamp and GetTimeStamp() or 0
    self.settings.lastScanInspected = inspected
    self.settings.lastScanImported = imported
    self.settings.lastScanTraderSales = traderSales
    self.settings.lastScanSellerMatches = sellerMatches
    self.settings.lastScanRedacted = redacted
    self.settings.lastScanGuilds = sourceStats
    self.settings.diagnosticSellerSamples = sellerSamples
    self.settings.playerDisplayNameRaw = playerRaw
    self.settings.playerDisplayNameNormalized = playerNormalized

    if not silent then
        self:Message(string.format(
            "Scan complete: %d guilds, %d cached events, %d trader sales, %d seller matches, %d new, %d stored.",
            #sources,
            inspected,
            traderSales,
            sellerMatches,
            imported,
            self.sales.count
        ))
        if purged > 0 then
            self:Message(string.format("Storage limit reached: removed %d oldest records.", purged))
        end
        if inspected == 0 then
            self:Message("No cached trader history found. A history request has been queued.")
        end
    end

    if self.Journal and self.Journal.Refresh then
        self.Journal:Refresh()
    end
    return true
end

function GSJ:RefreshTraderHistory(silent)
    local requested = self:RequestAllTraderHistory()
    self:ScanCachedHistory(silent)
    if not silent then
        self:Message(string.format("Queued/checked trader history for %d guilds.", requested))
    end
end

function GSJ:GetSortedRecords(guildId)
    local list = {}
    for eventId, record in pairs(self.sales.records or {}) do
        if not guildId or tonumber(record[1]) == tonumber(guildId) then
            list[#list + 1] = {
                eventId = eventId,
                guildId = record[1],
                timestamp = record[2],
                buyer = record[3],
                itemLink = record[4],
                quantity = record[5],
                price = record[6],
                tax = record[7],
            }
        end
    end
    table.sort(list, function(a, b)
        local at = tonumber(a.timestamp) or 0
        local bt = tonumber(b.timestamp) or 0
        if at == bt then return tostring(a.eventId) > tostring(b.eventId) end
        return at > bt
    end)
    return list
end

function GSJ:ClearSales()
    self.sales.records = {}
    self.sales.count = 0
    if self.Journal and self.Journal.Refresh then
        self.Journal:Refresh()
    end
    self:Message("Sales history cleared. Settings retained.")
end

function GSJ:ResetSettings()
    for key in pairs(self.settings) do
        self.settings[key] = nil
    end
    for key, value in pairs(DEFAULT_SETTINGS) do
        if type(value) == "table" then
            self.settings[key] = {}
        else
            self.settings[key] = value
        end
    end
    self:ApplyStorageProfile("balanced")
    self:Message("Settings reset. Sales history retained.")
end

local function Initialize()
    GSJ.settings = ZO_SavedVars:NewAccountWide(
        "GuildSalesJournal_Settings", 2, nil, DEFAULT_SETTINGS
    )
    GSJ.sales = ZO_SavedVars:NewAccountWide(
        "GuildSalesJournal_Sales", 2, nil, DEFAULT_SALES
    )

    GSJ.sales.records = GSJ.sales.records or {}
    GSJ.sales.count = GSJ:CountRecords(GSJ.sales.records)
    GSJ.settings.lastScanGuilds = GSJ.settings.lastScanGuilds or {}
    GSJ:ApplyStorageProfile(GSJ.settings.storageProfile or "balanced")

    if GSJ.Settings and GSJ.Settings.Initialize then
        GSJ.Settings:Initialize()
    end
    if GSJ.Journal and GSJ.Journal.Initialize then
        GSJ.Journal:Initialize()
    end

    SLASH_COMMANDS["/gsj"] = function()
        GSJ:RefreshTraderHistory(false)
    end
    SLASH_COMMANDS["/gsjcount"] = function()
        GSJ:Message(string.format(
            "%d/%d sales stored. Purge batch: %d.",
            GSJ.sales.count,
            GSJ.settings.maxEntries,
            GSJ.settings.purgeBatch
        ))
    end

    EVENT_MANAGER:RegisterForEvent(
        "GuildSalesJournal_HistoryUpdated",
        EVENT_GUILD_HISTORY_CATEGORY_UPDATED,
        function(_, guildId, eventCategory, flags)
            if eventCategory ~= GUILD_HISTORY_EVENT_CATEGORY_TRADER then return end
            zo_callLater(function()
                GSJ:ScanCachedHistory(true)
            end, 150)
        end
    )

    GSJ:Message("0.0.9 loaded. Open Journal > Personal Finance Journal.")
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= GSJ.name then return end
    EVENT_MANAGER:UnregisterForEvent(GSJ.name, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(GSJ.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
