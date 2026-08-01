-- LPC_Scanner.lua (z paczkami 3000 itemów i timestampem)
LibPriceCache = LibPriceCache or {}
LibPriceCache.Scanner = LibPriceCache.Scanner or {}
local S = LibPriceCache.Scanner

local BATCH_SIZE = 3000          -- 3000 itemów na paczkę
local BATCH_DELAY_MS = 100       -- 100ms przerwy między paczkami
local MIN_SCAN_INTERVAL = 3600   -- Minimum 1 godzina między skanami tego samego itemu (w sekundach)

local hasLibAsync = LibAsync and LibAsync.Create ~= nil
if hasLibAsync then
    LibPriceCache.Report:Log("[LPC_Scanner] LibAsync detected. Using async processing.")
else
    LibPriceCache.Report:Log("[LPC_Scanner] LibAsync not found. Using fallback mode.")
end

local isScanning = false
S.pendingItems = S.pendingItems or {}
S.pendingIndex = S.pendingIndex or 1
S.callbacks = S.callbacks or {}
S.lastScanTime = S.lastScanTime or {}  -- Przechowuje timestamp ostatniego skanu dla każdego itemKey

-- Zmienne dla trybu uśpienia
local isAsleep = true
local pendingWakeupItems = {}
local lastActivityTime = 0
local wakeupAttempts = 0
local WAKEUP_QUEUE_SIZE = 10
local WAKEUP_IDLE_TIME = 5
local MAX_WAKEUP_ATTEMPTS = 3
local WAKEUP_RETRY_INTERVAL = 60

local function HasEnoughPriceSources()
    local db = LibPriceCache.Core and LibPriceCache.Core.db
    if not db then return false end
    local sources = 0
    if db.UseTTCPrice and TamrielTradeCentrePrice then sources = sources + 1 end
    if db.UseMMPrice and MasterMerchant then sources = sources + 1 end
    if db.UseATTPrice and ArkadiusTradeTools then sources = sources + 1 end
    if db.UseESOHubPrice and LibEsoHubPrices then sources = sources + 1 end
    if db.UseUESPPrice and uespLog then sources = sources + 1 end
    return sources >= 1
end

local function AddItemToPendingQueue(itemLink, bagId, slotIndex)
    if not itemLink then return end
    local itemKey = LibPriceCache.Core:GetID(itemLink)
    
    -- Sprawdź czy był skanowany w ostatnim czasie
    local lastScan = S.lastScanTime[itemKey]
    if lastScan and (GetTimeStamp() - lastScan) < MIN_SCAN_INTERVAL then
        return  -- Pomijamy, skanowane niedawno
    end
    
    for _, queued in ipairs(S.pendingItems) do
        if queued.key == itemKey then return end
    end
    
    S.pendingItems[#S.pendingItems+1] = {
        key = itemKey,
        link = itemLink,
        bagId = bagId or 255,
        slot = slotIndex or 0
    }
    pendingWakeupItems[#pendingWakeupItems+1] = itemKey
    lastActivityTime = GetFrameTimeSeconds()
    if isAsleep and (#pendingWakeupItems >= WAKEUP_QUEUE_SIZE or (lastActivityTime - (lastWakeupCheck or 0)) >= WAKEUP_IDLE_TIME) then
        S:TryWakeUp()
    end
end

function S:TryWakeUp()
    if not isAsleep then return end
    if LibPriceCache.Core.uiCooldown then
        zo_callLater(function() S:TryWakeUp() end, 1000)
        return
    end
    if not HasEnoughPriceSources() then
        if wakeupAttempts < MAX_WAKEUP_ATTEMPTS then
            wakeupAttempts = wakeupAttempts + 1
            LibPriceCache.Report:Log(string.format("Not enough price sources (attempt %d/%d). Scanner remains asleep. Retry in %d seconds.", wakeupAttempts, MAX_WAKEUP_ATTEMPTS, WAKEUP_RETRY_INTERVAL))
            zo_callLater(function() S:TryWakeUp() end, WAKEUP_RETRY_INTERVAL * 1000)
        else
            LibPriceCache.Report:Log("Max wakeup attempts reached. Scanner will remain asleep. Use /lpcscan to start manually when price sources are available.")
        end
        return
    end
    if #S.pendingItems == 0 then
        return
    end
    isAsleep = false
    wakeupAttempts = 0
    pendingWakeupItems = {}
    LibPriceCache.Report:Log("Scanner waking up. Processing " .. #S.pendingItems .. " items.")
    S:Start()
end

function S:RegisterCallback(itemKey, callback)
    if not self.callbacks[itemKey] then self.callbacks[itemKey] = {} end
    self.callbacks[itemKey][#self.callbacks[itemKey]+1] = callback
end

function S:FireCallbacks(itemKey, price)
    if self.callbacks[itemKey] then
        for _, cb in ipairs(self.callbacks[itemKey]) do pcall(cb, itemKey, price) end
        self.callbacks[itemKey] = nil
    end
end

function S:SaveQueue()
    if not LibPriceCache_QueueData then LibPriceCache_QueueData = {} end
    LibPriceCache_QueueData.pendingItems = S.pendingItems
    LibPriceCache_QueueData.pendingIndex = S.pendingIndex
    LibPriceCache_QueueData.lastScanTime = S.lastScanTime
    LibPriceCache_QueueData.lastUpdate = GetTimeStamp()
end

function S:LoadQueue()
    if LibPriceCache_QueueData and LibPriceCache_QueueData.pendingItems then
        S.pendingItems = LibPriceCache_QueueData.pendingItems
        S.pendingIndex = LibPriceCache_QueueData.pendingIndex or 1
        S.lastScanTime = LibPriceCache_QueueData.lastScanTime or {}
        LibPriceCache.Report:Log(string.format("Loaded %d items from saved queue", #S.pendingItems))
    end
end

-- ============================================
-- PRZETWARZANIE JEDNEGO ITEMA
-- ============================================
local function ProcessOneItem()
    if not isScanning then return false end
    if LibPriceCache.Core.uiCooldown then
        return true
    end
    
    if S.pendingIndex > #S.pendingItems then
        return false
    end
    
    local core = LibPriceCache.Core
    if not core or not core.db then
        return true
    end
    
    local item = S.pendingItems[S.pendingIndex]
    S.pendingIndex = S.pendingIndex + 1
    
    -- Zapisz timestamp skanu
    if item and item.key then
        S.lastScanTime[item.key] = GetTimeStamp()
    end
    
    local priceData = nil
    
    if item and item.link then
        local module = core:GetDataModule(item.link, false)
        if module and module.db then
            local now = GetTimeStamp()
            local db = core.db
            
            if db.UseTTCPrice then
                local success, ttcData = pcall(function()
                    return LibPriceCache.Utils:GetTTC(item.link)
                end)
                if success and ttcData and ttcData.price and ttcData.price > 0 then
                    LibPriceCache.Cache:SetPrice(module, item.key, "TTC", now, ttcData.price)
                    priceData = ttcData
                end
            end
            
            if db.UseATTPrice then
                local success, attData = pcall(function()
                    return LibPriceCache.Utils:GetATT(item.link)
                end)
                if success and attData and attData.price and attData.price > 0 then
                    LibPriceCache.Cache:SetPrice(module, item.key, "ATT", now, attData.price)
                    if not priceData then priceData = attData end
                end
            end
            
            if db.UseMMPrice then
                local success, mmData = pcall(function()
                    return LibPriceCache.Utils:GetMM(item.link)
                end)
                if success and mmData and mmData.price and mmData.price > 0 then
                    LibPriceCache.Cache:SetPrice(module, item.key, "MM", now, mmData.price)
                    if not priceData then priceData = mmData end
                end
            end
            
            if db.UseESOHubPrice then
                local success, esoData = pcall(function()
                    return LibPriceCache.Utils:GetESOHub(item.link, item.bagId, item.slot)
                end)
                if success and esoData and esoData.price and esoData.price > 0 then
                    LibPriceCache.Cache:SetPrice(module, item.key, "ESO_Hub", now, esoData.price)
                    if not priceData then priceData = esoData end
                end
            end
            
            if db.UseUESPPrice then
                local success, uespData = pcall(function()
                    return LibPriceCache.Utils:GetUESP(item.link)
                end)
                if success and uespData and uespData.price and uespData.price > 0 then
                    LibPriceCache.Cache:SetPrice(module, item.key, "UESP", now, uespData.price)
                    if not priceData then priceData = uespData end
                end
            end
        end
    end
    
    if item and item.key and priceData and priceData.price then
        CALLBACK_MANAGER:FireCallbacks("LPC_PRICE_UPDATED", item.key, priceData.price, item.link)
        S:FireCallbacks(item.key, priceData.price)
    end
    
    return true
end

-- ============================================
-- PRZETWARZANIE PACZKI
-- ============================================
local asyncTask = nil

local function ProcessBatch()
    if not isScanning then return end
    
    local processed = 0
    
    while processed < BATCH_SIZE and S.pendingIndex <= #S.pendingItems do
        local shouldContinue = ProcessOneItem()
        if not shouldContinue then
            isScanning = false
            asyncTask = nil
            LibPriceCache.Report:Log("Queue processing complete")
            S:SaveQueue()
            return
        end
        processed = processed + 1
    end
    
    if S.pendingIndex <= #S.pendingItems then
        local remaining = #S.pendingItems - S.pendingIndex + 1
        if processed > 0 then
            LibPriceCache.Report:Log(string.format("Processed %d items, %d remaining. Taking a short break...", processed, remaining))
        end
        S:SaveQueue()  -- Zapisz postęp
        if hasLibAsync then
            asyncTask:Delay(BATCH_DELAY_MS, function() ProcessBatch() end)
        else
            zo_callLater(ProcessBatch, BATCH_DELAY_MS)
        end
    else
        isScanning = false
        asyncTask = nil
        LibPriceCache.Report:Log("Queue processing complete")
        S:SaveQueue()
    end
end

-- ============================================
-- START SKANOWANIA
-- ============================================
function S:Start(scanType)
    if isScanning then
        LibPriceCache.Report:Log("Scan already in progress")
        return
    end
    if isAsleep then
        S:TryWakeUp()
        if isAsleep then return end
    end
    if #S.pendingItems == 0 then
        LibPriceCache.Report:Log("Nothing to scan")
        return
    end
    
    isScanning = true
    S.pendingIndex = 1
    
    LibPriceCache.Report:Log(string.format("Starting scan of %d items in batches of %d...", #S.pendingItems, BATCH_SIZE))
    
    if hasLibAsync then
        asyncTask = LibAsync:Create("LPC_Scanner")
        asyncTask:Call(function() ProcessBatch() end):Resume()
    else
        ProcessBatch()
    end
end

-- ============================================
-- SKANOWANIE CRAFT BAG (zoptymalizowane)
-- ============================================
function S:ScanCraftBag()
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_VIRTUAL)
    if not bagCache or ZO_IsTableEmpty(bagCache) then
        LibPriceCache.Report:Log("Craft bag cache is empty - try opening craft bag first")
        return 0
    end
    LibPriceCache.Report:Log("Scanning craft bag...")
    
    -- Zbierz itemId bez tworzenia linków od razu
    local itemIds = {}
    for itemId, slotData in pairs(bagCache) do
        if slotData and slotData.slotIndex then
            itemIds[#itemIds+1] = itemId
        end
    end
    
    LibPriceCache.Report:Log(string.format("Found %d items in craft bag", #itemIds))
    
    local scannedCount = 0
    local skippedCount = 0
    local now = GetTimeStamp()
    
    -- Dodawaj po trochu, żeby nie zfreezować
    local function addBatch(startIndex)
        local endIndex = math.min(startIndex + 100, #itemIds)
        for i = startIndex, endIndex do
            local itemId = itemIds[i]
            local fakeLink = string.format('|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', itemId)
            if fakeLink then
                local itemKey = LibPriceCache.Core:GetID(fakeLink)
                
                -- Sprawdź czy był skanowany niedawno
                local lastScan = S.lastScanTime[itemKey]
                if lastScan and (now - lastScan) < MIN_SCAN_INTERVAL then
                    skippedCount = skippedCount + 1
                else
                    local alreadyQueued = false
                    for _, queued in ipairs(S.pendingItems) do
                        if queued.key == itemKey then
                            alreadyQueued = true
                            break
                        end
                    end
                    if not alreadyQueued then
                        S.pendingItems[#S.pendingItems+1] = { 
                            key = itemKey, 
                            link = fakeLink, 
                            bagId = BAG_VIRTUAL, 
                            slot = 0, 
                            itemId = itemId 
                        }
                        scannedCount = scannedCount + 1
                    end
                end
            end
        end
        
        if endIndex < #itemIds then
            zo_callLater(function() addBatch(endIndex + 1) end, 50)
        else
            S:SaveQueue()
            LibPriceCache.Report:Log(string.format("Craft bag: %d new items added to queue (%d skipped - recently scanned)", scannedCount, skippedCount))
            if not isScanning and #S.pendingItems > 0 then
                S:Start()
            end
        end
    end
    
    addBatch(1)
    return scannedCount
end

-- ============================================
-- POZOSTAŁE FUNKCJE
-- ============================================
function S:FullPriceDatabaseScan()
    LibPriceCache.Report:Log("Starting full database scan...")
    local itemsFound = {}
    local totalItems = 0
    local now = GetTimeStamp()
    
    if MasterMerchant and MasterMerchant.sales_data then
        LibPriceCache.Report:Log("Scanning Master Merchant...")
        for itemId, versions in pairs(MasterMerchant.sales_data) do
            for _, data in pairs(versions) do
                if data.itemDesc then
                    local fakeLink = string.format('|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h', itemId)
                    local itemKey = LibPriceCache.Core:GetID(fakeLink)
                    
                    -- Sprawdź czy był skanowany niedawno
                    local lastScan = S.lastScanTime[itemKey]
                    if not lastScan or (now - lastScan) >= MIN_SCAN_INTERVAL then
                        if not itemsFound[itemKey] then
                            itemsFound[itemKey] = { link = fakeLink, key = itemKey }
                            totalItems = totalItems + 1
                        end
                    end
                end
            end
        end
    end
    
    LibPriceCache.Report:Log(string.format("Found %d unique items from Master Merchant (needs refresh)", totalItems))
    
    local newCount = 0
    for key, data in pairs(itemsFound) do
        local alreadyQueued = false
        for _, queued in ipairs(S.pendingItems) do
            if queued.key == key then
                alreadyQueued = true
                break
            end
        end
        if not alreadyQueued then
            S.pendingItems[#S.pendingItems+1] = { key = key, link = data.link }
            newCount = newCount + 1
        end
    end
    
    S:SaveQueue()
    LibPriceCache.Report:Log(string.format("%d new items added to queue (total: %d)", newCount, #S.pendingItems))
    if not isScanning and #S.pendingItems > 0 then
        S:Start()
    end
end

function S:ScanVendorStore()
    LibPriceCache.Report:Log("Scanning vendor store...")
    local vendorBag = BAG_VENDOR
    local vendorSize = GetBagSize(vendorBag)
    if vendorSize == 0 then
        LibPriceCache.Report:Log("No vendor open")
        return 0
    end
    local scannedCount = 0
    local now = GetTimeStamp()
    
    for slot = 0, vendorSize - 1 do
        local itemLink = GetItemLink(vendorBag, slot)
        if itemLink and itemLink ~= "" then
            local itemKey = LibPriceCache.Core:GetID(itemLink)
            
            local lastScan = S.lastScanTime[itemKey]
            if not lastScan or (now - lastScan) >= MIN_SCAN_INTERVAL then
                local alreadyQueued = false
                for _, queued in ipairs(S.pendingItems) do
                    if queued.key == itemKey then
                        alreadyQueued = true
                        break
                    end
                end
                if not alreadyQueued then
                    S.pendingItems[#S.pendingItems+1] = { key = itemKey, link = itemLink, bagId = vendorBag, slot = slot }
                    scannedCount = scannedCount + 1
                end
            end
        end
    end
    
    S:SaveQueue()
    LibPriceCache.Report:Log(string.format("Vendor: %d items added to queue", scannedCount))
    if not isScanning and #S.pendingItems > 0 then
        S:Start()
    end
    return scannedCount
end

function S:GetQueueSize() return #S.pendingItems end
function S:ClearQueue() S.pendingItems = {}; S.pendingIndex = 1; isScanning = false; S:SaveQueue(); LibPriceCache.Report:Log("Queue cleared") end
function S:Stop() isScanning = false; LibPriceCache.Report:Log("Scanning stopped") end

-- ============================================
-- AUTO-SKANOWANIE
-- ============================================
local lootDebounceTimer = nil
local pendingLootItems = {}

local function ProcessPendingLootItems()
    for _, item in ipairs(pendingLootItems) do
        AddItemToPendingQueue(item.link, item.bagId, item.slot)
    end
    pendingLootItems = {}
    lootDebounceTimer = nil
end

local function OnLootReceived(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, selfLooted, isPickpocketLoot, questItemIcon, itemId, isStolen)
    if not selfLooted or not itemLink or itemLink == "" then return end
    pendingLootItems[#pendingLootItems+1] = {
        link = itemLink,
        bagId = 255,
        slot = 0
    }
    if lootDebounceTimer then
        zo_callLater(function() end, lootDebounceTimer)
    end
    lootDebounceTimer = zo_callLater(ProcessPendingLootItems, 500)
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_LootScan", EVENT_LOOT_RECEIVED, OnLootReceived)

local function OnCraftBagOpen()
    zo_callLater(function() if LibPriceCache.Scanner then LibPriceCache.Scanner:ScanCraftBag() end end, 500)
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_CraftBagAuto", EVENT_OPEN_CRAFT_BAG, OnCraftBagOpen)

local function OnBankOpen()
    zo_callLater(function() if LibPriceCache.Scanner then LibPriceCache.Scanner:Start() end end, 500)
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_BankAuto", EVENT_OPEN_BANK, OnBankOpen)

local function OnGuildBankOpen()
    zo_callLater(function() if LibPriceCache.Scanner then LibPriceCache.Scanner:Start() end end, 500)
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_GuildBankAuto", EVENT_OPEN_GUILD_BANK, OnGuildBankOpen)

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent("LibPriceCache_Startup", EVENT_PLAYER_ACTIVATED)
    zo_callLater(function() S:Start() end, 5000)
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_Startup", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

S:LoadQueue()