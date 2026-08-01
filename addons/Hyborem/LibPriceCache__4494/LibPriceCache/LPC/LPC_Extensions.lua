-- LPC_Extensions.lua
LibPriceCache = LibPriceCache or {}
-- Zabezpieczenie przed brakiem modułu Report
if not LibPriceCache.Report then
    LibPriceCache.Report = {}
    function LibPriceCache.Report:Log(msg) d(msg) end
    function LibPriceCache.Report:EmergencyLog(ctx, err) d(ctx .. ": " .. err) end
end

LibPriceCache.Extensions = LibPriceCache.Extensions or {}
local EX = LibPriceCache.Extensions

EX.name = "LibPriceCache.Extensions"
EX.version = "1.6.19"
d("[DEBUG] LPC_Extensions.lua loaded")
LibPriceCache.Report:Log("[LibPriceCache.Extensions] Loading...")

local IIfAScanned = false

-- Opóźnione dodawanie do kolejki (1 sekunda)
local pendingAddTimer = nil
local pendingAddQueue = {}

local function ProcessPendingAddQueue()
    for _, item in ipairs(pendingAddQueue) do
        local core = LibPriceCache.Core
        if not core or not core.GetID then return false end
        local scanner = LibPriceCache.Scanner
        if not scanner then
            LibPriceCache.Report:Log("[LibPriceCache.Extensions] Scanner not available")
            return false
        end
        if not scanner.pendingItems then scanner.pendingItems = {} end
        local itemKey = core:GetID(item.link)
        local alreadyQueued = false
        for _, queued in ipairs(scanner.pendingItems) do
            if queued.key == itemKey then
                alreadyQueued = true
                break
            end
        end
        if not alreadyQueued then
            scanner.pendingItems[#scanner.pendingItems+1] = {
                key = itemKey,
                link = item.link,
                bagId = item.bagId or 255,
                slot = item.slotIndex or 0
            }
        end
    end
    pendingAddQueue = {}
    pendingAddTimer = nil
end

local function AddToLPCScanDelayed(itemLink, bagId, slotIndex)
    if not itemLink then return false end
    pendingAddQueue[#pendingAddQueue+1] = { link = itemLink, bagId = bagId, slotIndex = slotIndex }
    if pendingAddTimer then
        zo_callLater(function() end, pendingAddTimer)
    end
    pendingAddTimer = zo_callLater(ProcessPendingAddQueue, 1000)
    return true
end

local function ScanIIfA()
    if IIfAScanned then
        LibPriceCache.Report:Log("[LibPriceCache] IIfA already scanned this session")
        return
    end
    if not LibPriceCache.Scanner or not LibPriceCache.Scanner.pendingItems then
        LibPriceCache.Report:Log("[LibPriceCache] Scanner not ready, retrying in 2 seconds...")
        zo_callLater(ScanIIfA, 2000)
        return
    end
    local cache = IIfA and IIfA.GetInventoryDB and IIfA:GetInventoryDB()
    if not cache then
        LibPriceCache.Report:Log("[LibPriceCache] IIfA not available or cache empty")
        return
    end
    LibPriceCache.Report:Log("[LibPriceCache] Scanning IIfA database...")
    local added = 0
    for itemKey, itemData in pairs(cache) do
        local itemLink = itemData and itemData.link
        if not itemLink and tonumber(itemKey) then
            itemLink = string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemKey)
        end
        if itemLink and AddToLPCScanDelayed(itemLink, 255, 0) then
            added = added + 1
        end
    end
    if added > 0 then
        if LibPriceCache.Scanner.SaveQueue then LibPriceCache.Scanner:SaveQueue() end
        LibPriceCache.Report:Log(string.format("[LibPriceCache] Added %d items from IIfA to queue", added))
        if not LibPriceCache.Scanner.isScanning then LibPriceCache.Scanner:Start() end
    end
    IIfAScanned = true
end

local function OnPlayerActivated()
    EVENT_MANAGER:UnregisterForEvent("LibPriceCache_IIfAScan", EVENT_PLAYER_ACTIVATED)
    local core = LibPriceCache.Core
    if core and core.db and core.db.AutoScanIIfA and IIfA and IIfA.GetInventoryDB then
        zo_callLater(ScanIIfA, 15000)
    else
        LibPriceCache.Report:Log("[LibPriceCache] Auto-scan IIfA disabled or IIfA not installed")
    end
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_IIfAScan", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

local function OnEsoTradingHubScanComplete()
    if not EsoTradingHub or not EsoTradingHub.internal then
        LibPriceCache.Report:Log("[LibPriceCache] EsoTradingHub not available")
        return
    end
    local ETHint = EsoTradingHub.internal
    if not ETHint.currentGuild or not ETHint.currentGuild.scannedItems then
        LibPriceCache.Report:Log("[LibPriceCache] No scanned items from EsoTradingHub")
        return
    end
    LibPriceCache.Report:Log("[LibPriceCache] Processing items from EsoTradingHub scan...")
    local added = 0
    for itemUniqueId, itemData in pairs(ETHint.currentGuild.scannedItems) do
        local itemLink = itemData:match("^([^,]+)")
        if itemLink and AddToLPCScanDelayed(itemLink, BAG_TRADING_HOUSE, 0) then
            added = added + 1
        end
    end
    if added > 0 then
        if LibPriceCache.Scanner.SaveQueue then LibPriceCache.Scanner:SaveQueue() end
        LibPriceCache.Report:Log(string.format("[LibPriceCache] Added %d items from EsoTradingHub scan to queue", added))
        if not LibPriceCache.Scanner.isScanning then LibPriceCache.Scanner:Start() end
    end
end

local function SetupEsoTradingHubIntegration()
    if not EsoTradingHub or not EsoTradingHub.StopFullTradingHouseScan then
        LibPriceCache.Report:Log("[LibPriceCache] EsoTradingHub not available, integration skipped")
        return
    end
    local originalStop = EsoTradingHub.StopFullTradingHouseScan
    EsoTradingHub.StopFullTradingHouseScan = function(isScanComplete)
        originalStop(isScanComplete)
        if isScanComplete then
            zo_callLater(OnEsoTradingHubScanComplete, 500)
        end
    end
    LibPriceCache.Report:Log("[LibPriceCache] EsoTradingHub integration enabled")
end
zo_callLater(SetupEsoTradingHubIntegration, 5000)

-- ============================================
-- OPTYMALIZACJA: Zbieranie kluczy w paczkach (bez freeze)
-- ============================================
function EX:FullDatabasePriceScan()
    if not LibPriceCache.Scanner or not LibPriceCache.Scanner.pendingItems then
        LibPriceCache.Report:Log("[LibPriceCache] Scanner not ready, cannot perform full database scan")
        return
    end
    
    LibPriceCache.Report:Log("[LibPriceCache] Starting full database price scan...")
    
    local allKeys = {}
    local modules = { LibPriceCache.LPC01, LibPriceCache.LPC02, LibPriceCache.LPC03, LibPriceCache.LPC04 }
    local currentModule = 1
    local currentKeys = nil
    local currentIndex = 1
    
    -- Funkcja do zbierania kluczy z jednego modułu w paczkach
    local function collectFromModule()
        if currentModule > #modules then
            -- Wszystkie klucze zebrane, teraz dodaj do kolejki (też w paczkach)
            local allKeysList = {}
            for key, _ in pairs(allKeys) do
                allKeysList[#allKeysList+1] = key
            end
            
            local totalQueued = 0
            local queueIndex = 1
            
            local function queueBatch()
                local batchEnd = math.min(queueIndex + 500, #allKeysList)
                for i = queueIndex, batchEnd do
                    local key = allKeysList[i]
                    local parts = {}
                    for part in string.gmatch(key, "[^:]+") do
                        parts[#parts+1] = part
                    end
                    if #parts >= 4 then
                        local server, itemId, cp, quality = parts[1], parts[2], parts[3], parts[4]
                        local fakeLink = string.format("|H0:item:%s:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId, cp)
                        if AddToLPCScanDelayed(fakeLink, 255, 0) then
                            totalQueued = totalQueued + 1
                            if totalQueued % 100 == 0 then
                                LibPriceCache.Report:Log(string.format("[LibPriceCache] Queued %d items for price refresh...", totalQueued))
                            end
                        end
                    end
                end
                
                queueIndex = batchEnd + 1
                if queueIndex <= #allKeysList then
                    zo_callLater(queueBatch, 50)
                else
                    if LibPriceCache.Scanner.SaveQueue then LibPriceCache.Scanner:SaveQueue() end
                    LibPriceCache.Report:Log(string.format("[LibPriceCache] Full database scan completed. %d items added to queue.", totalQueued))
                    if not LibPriceCache.Scanner.isScanning then LibPriceCache.Scanner:Start() end
                end
            end
            
            queueBatch()
            return
        end
        
        local mod = modules[currentModule]
        if mod and mod.db and mod.db.data then
            if not currentKeys then
                -- Zbierz wszystkie klucze z tego modułu do tabeli
                currentKeys = {}
                for key, _ in pairs(mod.db.data) do
                    currentKeys[#currentKeys+1] = key
                end
                currentIndex = 1
            end
            
            -- Przetwarzaj po 500 kluczy na raz
            local batchEnd = math.min(currentIndex + 500, #currentKeys)
            for i = currentIndex, batchEnd do
                allKeys[currentKeys[i]] = true
            end
            
            currentIndex = batchEnd + 1
            
            if currentIndex <= #currentKeys then
                -- Więcej kluczy w tym module, kontynuuj po przerwie
                zo_callLater(collectFromModule, 50)
            else
                -- Koniec tego modułu, przejdź do następnego
                currentModule = currentModule + 1
                currentKeys = nil
                currentIndex = 1
                zo_callLater(collectFromModule, 50)
            end
        else
            currentModule = currentModule + 1
            zo_callLater(collectFromModule, 50)
        end
    end
    
    collectFromModule()
end

SLASH_COMMANDS["/lpcguildscan"] = function()
    if EsoTradingHub and EsoTradingHub.StartFullTradingHouseScan then
        LibPriceCache.Report:Log("[LibPriceCache] Triggering EsoTradingHub scan...")
        EsoTradingHub.StartFullTradingHouseScan()
    else
        LibPriceCache.Report:Log("[LibPriceCache] EsoTradingHub not available. Cannot scan guild store.")
    end
end

SLASH_COMMANDS["/lpcrescan"] = function()
    LibPriceCache.Report:Log("[LibPriceCache] Manual full rescan triggered...")
    ScanIIfA()
    EX:FullDatabasePriceScan()
    if EsoTradingHub and EsoTradingHub.StartFullTradingHouseScan then
        EsoTradingHub.StartFullTradingHouseScan()
    else
        LibPriceCache.Report:Log("[LibPriceCache] EsoTradingHub not available, skip guild scan.")
    end
end

SLASH_COMMANDS["/lpcscanii"] = ScanIIfA
SLASH_COMMANDS["/lpcfulldbscan"] = function() EX:FullDatabasePriceScan() end

-- Tylko jedna rejestracja context menu (przez LibCustomMenu)
if LibCustomMenu then
    LibCustomMenu:RegisterContextMenu(function(inventorySlot)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if bagId and slotIndex then
            local itemLink = GetItemLink(bagId, slotIndex)
            if itemLink then
                AddCustomMenuItem("Add to LPC scan", function()
                    AddToLPCScanDelayed(itemLink, bagId, slotIndex)
                end)
            end
        end
    end)
    LibPriceCache.Report:Log("[LibPriceCache] Context menu registered")
end

-- Druga rejestracja (przez ZO_LinkHandler_OnLinkMouseUp) została USUNIĘTA

LibPriceCache.Report:Log("[LibPriceCache.Extensions] v" .. EX.version .. " fully loaded.")