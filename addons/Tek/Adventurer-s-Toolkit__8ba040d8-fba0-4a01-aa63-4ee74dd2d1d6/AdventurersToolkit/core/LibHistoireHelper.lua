-- ============================================
-- LibHistoire Helper Module
-- Shared processor management for AdventurersToolkit
-- ============================================

NWT.LibHistoire = {}

-- NOTE: Do NOT capture LibHistoire at file load time as it may not be initialized yet.
-- Always use GetLH() to get the current reference.
local function GetLH()
    return LibHistoire
end
local ADDON_NAME = "AdventurersToolkit"

-- State tracking
NWT.LibHistoire.processors = {}
NWT.LibHistoire.isReady = false
NWT.LibHistoire.pendingCallbacks = {}
NWT.LibHistoire.activeScans = {}

-- Initialize when LibHistoire is ready
function NWT.LibHistoire.Initialize()
    local LH = GetLH()
    if not LH then
        d("|cFF0000[Adventurer's Toolkit] ERROR: LibHistoire is required but not found!|r")
        d("|cFF0000Please install LibHistoire from ESOUI or Minion.|r")
        return false
    end

    LH:OnReady(function()
        NWT.LibHistoire.isReady = true
        NWT.Debug("|c00FF00[ATK] LibHistoire ready|r")

        -- Execute any pending callbacks
        for _, callback in ipairs(NWT.LibHistoire.pendingCallbacks) do
            pcall(callback)
        end
        NWT.LibHistoire.pendingCallbacks = {}
    end)

    -- Register for managed range events
    LH:RegisterCallback(LH.callback.MANAGED_RANGE_LOST, function(guildId, category)
        NWT.Debug("|cFFAA00[ATK] Managed range lost for guild " .. guildId .. " category " .. category .. "|r")
        NWT.LibHistoire.OnManagedRangeLost(guildId, category)
    end)

    LH:RegisterCallback(LH.callback.MANAGED_RANGE_FOUND, function(guildId, category)
        NWT.Debug("|c00FF00[ATK] Managed range found for guild " .. guildId .. " category " .. category .. "|r")
    end)

    return true
end

-- Queue a callback to run when LibHistoire is ready
function NWT.LibHistoire.WhenReady(callback)
    -- First check our cached ready state
    if NWT.LibHistoire.isReady then
        pcall(callback)
        return
    end
    
    -- Fallback: check LibHistoire directly in case Initialize() was called late
    local LH = GetLH()
    if LH and LH:IsReady() then
        -- LibHistoire is ready, update our flag and run the callback
        NWT.LibHistoire.isReady = true
        pcall(callback)
        return
    end
    
    -- Not ready yet - queue the callback
    table.insert(NWT.LibHistoire.pendingCallbacks, callback)
    
    -- Also register directly with LibHistoire in case our Initialize() wasn't called
    if LH and not NWT.LibHistoire._fallbackRegistered then
        NWT.LibHistoire._fallbackRegistered = true
        LH:OnReady(function()
            NWT.LibHistoire.isReady = true
            -- Execute any pending callbacks
            for _, cb in ipairs(NWT.LibHistoire.pendingCallbacks) do
                pcall(cb)
            end
            NWT.LibHistoire.pendingCallbacks = {}
        end)
    end
end

-- Create a processor for a guild/category
-- Returns processor or nil if category cache not available
function NWT.LibHistoire.CreateProcessor(guildId, category)
    local LH = GetLH()
    if not LH then 
        NWT.Debug("|cFF0000[ATK]|r CreateProcessor failed: LibHistoire global is nil")
        return nil 
    end

    local processor = LH:CreateGuildHistoryProcessor(guildId, category, ADDON_NAME)
    if not processor then
        NWT.Debug("|cFFAA00[ATK] Could not create processor for guild " .. guildId .. " category " .. category .. " (Cache not ready?)|r")
        return nil
    end

    return processor
end

-- Get or create a streaming processor (continuous listening)
function NWT.LibHistoire.GetStreamingProcessor(guildId, category, eventCallback, lastEventId)
    local key = guildId .. "_" .. category

    -- Stop existing processor if running
    if NWT.LibHistoire.processors[key] then
        local existing = NWT.LibHistoire.processors[key]
        if existing:IsRunning() then
            existing:Stop()
        end
    end

    local processor = NWT.LibHistoire.CreateProcessor(guildId, category)
    if not processor then return nil end

    -- Configure for streaming
    processor:SetEventCallback(eventCallback)

    NWT.LibHistoire.processors[key] = processor

    -- Start streaming from last processed event
    local started = processor:StartStreaming(lastEventId, nil)
    if not started then
        NWT.Debug("|cFF0000[ATK] Failed to start streaming processor|r")
        return nil
    end

    return processor
end

-- Create a one-time scan processor for a time range
function NWT.LibHistoire.ScanTimeRange(guildId, category, startTime, endTime, eventCallback, finishedCallback)
    local processor = NWT.LibHistoire.CreateProcessor(guildId, category)
    if not processor then
        if finishedCallback then
            local LH = GetLH()
            finishedCallback(LH and LH.StopReason and LH.StopReason.MANUAL_STOP or "manualStop")
        end
        return nil
    end

    -- Keep a reference to prevent garbage collection until finished
    local scanKey = tostring(guildId) .. "_" .. tostring(category) .. "_" .. tostring(startTime)
    NWT.LibHistoire.activeScans[scanKey] = processor

    processor:StartIteratingTimeRange(startTime, endTime, eventCallback, function(reason)
        -- Clear reference once scan is done
        NWT.LibHistoire.activeScans[scanKey] = nil
        if finishedCallback then
            finishedCallback(reason)
        end
    end)

    return processor
end

-- Extract data from trader event object
function NWT.LibHistoire.ExtractTraderEventData(event)
    local eventId = event:GetEventId()
    local timestampS = event:GetEventTimestampS()
    local eventType = event:GetEventType()

    if eventType ~= GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then
        return nil
    end

    local info = event:GetEventInfo()
    if not info then
        return nil
    end

    return {
        eventId = eventId,
        timestampS = timestampS,
        sellerName = info.sellerDisplayName or "",
        buyerName = info.buyerDisplayName or "",
        itemLink = info.itemLink or "",
        quantity = info.quantity or 1,
        price = info.price or 0,
        tax = info.tax or 0,
    }
end

-- Extract data from banked currency event
function NWT.LibHistoire.ExtractBankedCurrencyEventData(event)
    local eventId = event:GetEventId()
    local timestampS = event:GetEventTimestampS()
    local eventType = event:GetEventType()

    local info = event:GetEventInfo()
    if not info then
        return nil
    end

    -- Only process gold (CURT_MONEY)
    local currencyType = info.currencyType
    if currencyType and currencyType ~= CURT_MONEY then
        return nil
    end

    return {
        eventId = eventId,
        timestampS = timestampS,
        eventType = eventType,
        displayName = info.displayName or "",
        amount = info.amount or 0,
        kioskName = info.kioskName or "",
    }
end

-- Handle managed range loss
function NWT.LibHistoire.OnManagedRangeLost(guildId, category)
    local guildName = GetGuildName(guildId) or ("Guild " .. guildId)

    if category == GUILD_HISTORY_EVENT_CATEGORY_TRADER then
        d("|cFFAA00[ATK] Guild trader history data was reset for " .. guildName .. "|r")
        if NWT.OnTraderRangeLost then
            NWT.OnTraderRangeLost(guildId)
        end
    elseif category == GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY then
        d("|cFFAA00[ATK] Guild bank history data was reset for " .. guildName .. "|r")
        if NWT.OnBankRangeLost then
            NWT.OnBankRangeLost(guildId)
        end
    end
end

-- Stop all processors for a guild
function NWT.LibHistoire.StopGuildProcessors(guildId)
    for key, processor in pairs(NWT.LibHistoire.processors) do
        if key:find("^" .. guildId .. "_") then
            if processor:IsRunning() then
                processor:Stop()
            end
            NWT.LibHistoire.processors[key] = nil
        end
    end
end

-- Stop all processors
function NWT.LibHistoire.StopAllProcessors()
    for key, processor in pairs(NWT.LibHistoire.processors) do
        if processor:IsRunning() then
            processor:Stop()
        end
    end
    NWT.LibHistoire.processors = {}
end

-- Convert legacy id64 to new event id
function NWT.LibHistoire.ConvertLegacyEventId(id64)
    local LH = GetLH()
    if not LH then return nil end
    if LH.ConvertArtificialLegacyId64ToEventId then
        return LH:ConvertArtificialLegacyId64ToEventId(id64)
    end
    return nil
end

-- Check if LibHistoire is available and ready
function NWT.LibHistoire.IsAvailable()
    local LH = GetLH()
    return LH ~= nil and NWT.LibHistoire.isReady
end

-- Get processor progress metrics
function NWT.LibHistoire.GetProcessorMetrics(guildId, category)
    local key = guildId .. "_" .. category
    local processor = NWT.LibHistoire.processors[key]
    if not processor or not processor:IsRunning() then
        return 0, 0, -1
    end
    return processor:GetPendingEventMetrics()
end
