local SH = SalesHistory

SH.scanResults = {}
SH.isScanning  = false
SH.scanIterations = 0
SH.MAX_SCAN_ITERATIONS = 10 -- Prevent infinite loops
SH.guildHistoryRequest = nil

-- Keybind group pushed onto the strip when the Listings tab is active
local scanKeybindGroup = {
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name      = "Sales History",
        keybind   = "UI_SHORTCUT_PRIMARY",
        callback  = function() SH.StartScan() end,
    },
}
local scanKeybindGroupAdded = false

function SH.StartScan()
    if SH.isScanning then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "[SalesHistory] Scan already in progress.")
        return
    end

    if not LibHistoire then
        CHAT_SYSTEM:AddMessage("[SalesHistory] LibHistoire is not installed.")
        return
    end

    if not LibHistoire:IsReady() then
        CHAT_SYSTEM:AddMessage("[SalesHistory] LibHistoire is not ready yet. Please wait a moment and try again.")
        return
    end

    local guildIndex = tonumber(SH.savedVars.selectedGuildIndex) or 1
    local guildId    = GetGuildId(guildIndex)
    if not guildId or guildId == 0 then
        CHAT_SYSTEM:AddMessage("[SalesHistory] Invalid guild selected.")
        return
    end

    SH.scanResults = {}
    SH.scanIterations = 0
    SH.isScanning  = true
    SH.ShowSpinner()
    
    -- Create a guild history request object
    SH.guildHistoryRequest = ZO_GuildHistoryRequest:New(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)

    -- Start the iterative scan
    SH.PerformScanIteration(guildId)
end

function SH.PerformScanIteration(guildId)
    SH.scanIterations = SH.scanIterations + 1
    
    -- Safety check: prevent infinite loops
    if SH.scanIterations > SH.MAX_SCAN_ITERATIONS then
        SH.isScanning = false
        SH.HideSpinner()
        SH.OnScanComplete(SH.scanResults)
        return
    end
    
    d(string.format("[SalesHistory] Scan iteration %d...", SH.scanIterations))
    
    -- Request more events using the proper guild history request system
    if SH.guildHistoryRequest then
        local QUEUE_IF_ON_COOLDOWN = true
        local readyState = SH.guildHistoryRequest:RequestMoreEvents(QUEUE_IF_ON_COOLDOWN)
        
        if readyState == GUILD_HISTORY_DATA_READY_STATE_ON_COOLDOWN then
            d("[SalesHistory] Request on cooldown, will retry...")
        end
    end

    local playerName = GetDisplayName():gsub("^@", "")

    local function IsMyName(name)
        if not name then return false end
        return name:lower() == playerName:lower()
    end

    local processor = LibHistoire:CreateGuildHistoryProcessor(
        guildId,
        GUILD_HISTORY_EVENT_CATEGORY_TRADER,
        SH.name .. "_Iteration" .. SH.scanIterations
    )

    if not processor then
        CHAT_SYSTEM:AddMessage("[SalesHistory] No history cache found for this guild. LibHistoire may still be gathering data.")
        SH.isScanning = false
        SH.HideSpinner()
        return
    end

    processor:SetStopOnLastCachedEvent(true)
    
    local foundKnownSale = false
    local iterationResults = {}

    processor:SetNextEventCallback(function(event)
        local eventInfo = event:GetEventInfo()
        if eventInfo.eventType ~= GUILD_HISTORY_TRADER_EVENT_ITEM_SOLD then return end
        if not IsMyName(eventInfo.sellerDisplayName) then return end
        
        local itemLink = eventInfo.itemLink
        local saleData = {
            itemLink   = itemLink,
            itemName   = GetItemLinkName(itemLink),
            sellerName = eventInfo.sellerDisplayName,
            price      = eventInfo.price,
            tax        = eventInfo.tax,
            quantity   = eventInfo.quantity,
            dateStr    = GetDateStringFromTimestamp(eventInfo.timestampS),
            timestamp  = eventInfo.timestampS,
        }
        
        -- Check if this sale already exists in SavedVars
        local saleDate = saleData.dateStr
        for _, existingSale in ipairs(SH.savedVars.cachedResults) do
            local existingDate = existingSale.dateStr or GetDateStringFromTimestamp(existingSale.timestamp)
            if existingSale.itemLink == saleData.itemLink and 
               existingSale.price == saleData.price and
               existingDate == saleDate then
                foundKnownSale = true
                d("[SalesHistory] Found known sale, stopping scan.")
                return
            end
        end
        
        -- Check if we already found this in a previous iteration
        local alreadyFound = false
        for _, prevSale in ipairs(SH.scanResults) do
            if prevSale.itemLink == saleData.itemLink and 
               prevSale.price == saleData.price and
               prevSale.dateStr == saleDate then
                alreadyFound = true
                break
            end
        end
        
        if not alreadyFound then
            table.insert(iterationResults, saleData)
        end
    end)

    processor:SetOnStopCallback(function(reason)
        -- Merge iteration results into main results
        for _, sale in ipairs(iterationResults) do
            table.insert(SH.scanResults, sale)
        end
        
        d(string.format("[SalesHistory] Iteration %d complete. Found %d new sales this iteration. Total: %d",
            SH.scanIterations, #iterationResults, #SH.scanResults))
        
        -- If we found a known sale, stop scanning
        if foundKnownSale then
            SH.isScanning = false
            table.sort(SH.scanResults, function(a, b) return a.timestamp > b.timestamp end)
            SH.HideSpinner()
            SH.OnScanComplete(SH.scanResults)
            return
        end
        
        -- If this iteration found no new sales, we've reached the end
        if #iterationResults == 0 then
            SH.isScanning = false
            table.sort(SH.scanResults, function(a, b) return a.timestamp > b.timestamp end)
            SH.HideSpinner()
            SH.OnScanComplete(SH.scanResults)
            return
        end
        
        -- Otherwise, continue scanning (request more history)
        zo_callLater(function()
            if SH.isScanning then
                SH.PerformScanIteration(guildId)
            end
        end, 2000) -- Wait 2 seconds between iterations (ZOS rate limit)
    end)

    processor:Start()
end

-- Determine if the trading house is currently showing the Listings tab
local function IsInListingsMode()
    if not TRADING_HOUSE then return false end

    if TRADING_HOUSE_MODE_LISTINGS ~= nil then
        return TRADING_HOUSE.m_currentMode == TRADING_HOUSE_MODE_LISTINGS
    end

    if TRADING_HOUSE.IsAtTradingHouse and TRADING_HOUSE.IsInSearchMode and TRADING_HOUSE.IsInSellMode then
        return TRADING_HOUSE:IsAtTradingHouse()
           and not TRADING_HOUSE:IsInSearchMode()
           and not TRADING_HOUSE:IsInSellMode()
    end

    if TRADING_HOUSE.m_currentMode ~= nil then
        local mode = TRADING_HOUSE.m_currentMode
        return mode ~= "search" and mode ~= "sell"
    end

    return false
end

local function UpdateKeybind()
    if IsInListingsMode() then
        if not scanKeybindGroupAdded then
            KEYBIND_STRIP:AddKeybindButtonGroup(scanKeybindGroup)
            scanKeybindGroupAdded = true
        end
    else
        if scanKeybindGroupAdded then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(scanKeybindGroup)
            scanKeybindGroupAdded = false
        end
    end
end

local function OnTradingHouseModeChanged() UpdateKeybind() end
local function OnTradingHouseOpened()      UpdateKeybind() end
local function OnTradingHouseClosed()
    if scanKeybindGroupAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(scanKeybindGroup)
        scanKeybindGroupAdded = false
    end
end

EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_OPEN_TRADING_HOUSE,         OnTradingHouseOpened)
EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_CLOSE_TRADING_HOUSE,        OnTradingHouseClosed)
EVENT_MANAGER:RegisterForEvent(SH.name, EVENT_TRADING_HOUSE_MODE_CHANGED, OnTradingHouseModeChanged)
