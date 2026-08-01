-- ============================================
-- CROWN FURNITURE CAPTURE SYSTEM
-- Captures crown prices when browsing furniture
-- ============================================

NWT.CrownCapture = {
    enabled = false,
    capturedItems = {},
    sessionCount = 0,
}

function NWT.InitCrownCapture()
    if not NWT.savedVars.capturedCrownFurniture then
        NWT.savedVars.capturedCrownFurniture = {}
    end
    NWT.CrownCapture.capturedItems = NWT.savedVars.capturedCrownFurniture
end

function NWT.CaptureFurnitureCrownPrice()
    local browserGamepad = GAMEPAD_HOUSING_FURNITURE_BROWSER or ZO_HOUSING_FURNITURE_BROWSER_GAMEPAD 
        or HOUSING_FURNITURE_BROWSER_GAMEPAD or _G["GAMEPAD_HOUSING_FURNITURE_BROWSER"] 
        or _G["ZO_HousingFurnitureBrowser_Gamepad"]
    
    if not browserGamepad then 
NWT.Debug("|cFFFF00[Crown Capture]|r Open the furniture browser first") 
        return 
    end
    
    local targetData = nil
    if browserGamepad.GetCurrentList then 
        local cl = browserGamepad:GetCurrentList() 
        if cl then targetData = cl:GetTargetData() end 
    end
    if not targetData and browserGamepad.GetTargetData then 
        targetData = browserGamepad:GetTargetData() 
    end
    if not targetData and browserGamepad.currentList then 
        local l = browserGamepad.currentList 
        if l.selectedData then targetData = l.selectedData 
        elseif l.GetTargetData then targetData = l:GetTargetData() end 
    end
    
    if not targetData then 
NWT.Debug("|cFFFF00[Crown Capture]|r No item selected") 
        return 
    end
    
    -- Extract all available data
    local itemName = targetData.name or targetData.formattedName or targetData.displayName 
        or targetData.text or targetData.label or targetData.rawName or "Unknown"
    local itemId = nil
    local crownPrice = nil
    local furnitureDataId = targetData.furnitureDataId
    local collectibleId = targetData.collectibleId
    
    -- Try to get itemId from various sources
    if targetData.bagId and targetData.slotIndex then
        local itemLink = GetItemLink(targetData.bagId, targetData.slotIndex)
        if itemLink and itemLink ~= "" then
            itemId = GetItemLinkItemId(itemLink)
        end
    end
    
    -- Check for crown price in targetData (narrationPrice is the key field!)
    crownPrice = targetData.narrationPrice or targetData.currencyCost or targetData.cost 
        or targetData.price or targetData.crownCost or targetData.crowns or targetData.purchasePrice
    
    -- Check furnitureObject.cost (another reliable source)
    if not crownPrice and targetData.furnitureObject then
        crownPrice = targetData.furnitureObject.cost
    end
    
    -- Try marketProductId if available
    if targetData.marketProductId then
        -- Note: GetMarketProductPricingByPresentation is private, may not work
        local ok, result = pcall(function()
            return GetMarketProductPricingByPresentation(targetData.marketProductId)
        end)
        if ok and result then
            crownPrice = result
        end
    end
    
    -- Check nested data structures
    if not crownPrice and targetData.dataEntry and targetData.dataEntry.data then
        local nested = targetData.dataEntry.data
        crownPrice = nested.currencyCost or nested.cost or nested.price or nested.crownCost
        itemId = itemId or nested.itemId or nested.furnitureDataId
    end
    
    -- Use furnitureDataId as fallback itemId
    if not itemId then
        itemId = furnitureDataId or collectibleId
    end
    
    -- Clean up item name (remove formatting codes)
    if itemName then
        itemName = zo_strformat("<<1>>", itemName)
    end
    
    -- Store the captured data
    local captureKey = tostring(itemId or itemName)
    local captureData = {
        itemId = itemId,
        name = itemName,
        crownPrice = crownPrice,
        furnitureDataId = furnitureDataId,
        collectibleId = collectibleId,
        timestamp = GetTimeStamp(),
        isCollectible = (collectibleId ~= nil),
    }
    
    NWT.savedVars.capturedCrownFurniture[captureKey] = captureData
    NWT.CrownCapture.capturedItems[captureKey] = captureData
    NWT.CrownCapture.sessionCount = NWT.CrownCapture.sessionCount + 1
    
    -- Show feedback
    local priceText = crownPrice and (tostring(crownPrice) .. " crowns") or "price unknown"
    NWT.Debug(string.format("|c00FF00[Crown Capture]|r %s (ID: %s) - %s", 
        itemName, tostring(itemId or "?"), priceText))
    PlaySound(SOUNDS.POSITIVE_CLICK)
end

function NWT.GetCapturedCrownCount()
    local count = 0
    for _ in pairs(NWT.savedVars.capturedCrownFurniture or {}) do
        count = count + 1
    end
    return count
end

function NWT.ShowCapturedCrownData()
    local items = NWT.savedVars.capturedCrownFurniture or {}
    local count = 0
    local withPrice = 0
    
NWT.Debug("|c00FF00========== CAPTURED CROWN FURNITURE ==========|r")
    for key, data in pairs(items) do
        count = count + 1
        if data.crownPrice then withPrice = withPrice + 1 end
        local priceText = data.crownPrice and ("|cFFD700" .. data.crownPrice .. " crowns|r") or "|c888888no price|r"
        NWT.Debug(string.format("[%s] %s - %s", tostring(data.itemId or key), data.name or "Unknown", priceText))
    end
NWT.Debug("|c888888-----------------------------------------|r")
    NWT.Debug(string.format("|cFFD700Total:|r %d items (%d with prices)", count, withPrice))
NWT.Debug("|c00FF00================================================|r")
end

function NWT.ClearCapturedCrownData()
    NWT.savedVars.capturedCrownFurniture = {}
    NWT.CrownCapture.capturedItems = {}
    NWT.CrownCapture.sessionCount = 0
NWT.Debug("|c00FF00[Crown Capture]|r Cleared all captured data")
end

-- Debug function to dump raw item data
function NWT.DebugCrownData()
    local browserGamepad = GAMEPAD_HOUSING_FURNITURE_BROWSER or ZO_HOUSING_FURNITURE_BROWSER_GAMEPAD 
        or HOUSING_FURNITURE_BROWSER_GAMEPAD or _G["GAMEPAD_HOUSING_FURNITURE_BROWSER"] 
        or _G["ZO_HousingFurnitureBrowser_Gamepad"]
    
    if not browserGamepad then 
NWT.Debug("|cFF0000[Debug]|r Open the furniture browser first") 
        return 
    end
    
    local targetData = nil
    if browserGamepad.GetCurrentList then 
        local cl = browserGamepad:GetCurrentList() 
        if cl then targetData = cl:GetTargetData() end 
    end
    if not targetData and browserGamepad.GetTargetData then 
        targetData = browserGamepad:GetTargetData() 
    end
    if not targetData and browserGamepad.currentList then 
        local l = browserGamepad.currentList 
        if l.selectedData then targetData = l.selectedData 
        elseif l.GetTargetData then targetData = l:GetTargetData() end 
    end
    
    if not targetData then 
NWT.Debug("|cFF0000[Debug]|r No item selected") 
        return 
    end
    
NWT.Debug("|c00FF00========== DEBUG: RAW ITEM DATA ==========|r")
    
    -- Dump all top-level keys and values
    local count = 0
    for key, value in pairs(targetData) do
        count = count + 1
        local valueType = type(value)
        local displayValue = ""
        
        if valueType == "string" then
            displayValue = "\"" .. tostring(value):sub(1, 50) .. "\""
        elseif valueType == "number" then
            displayValue = tostring(value)
        elseif valueType == "boolean" then
            displayValue = tostring(value)
        elseif valueType == "table" then
            displayValue = "{table}"
        elseif valueType == "function" then
            displayValue = "{function}"
        else
            displayValue = tostring(value)
        end
        
        NWT.Debug(string.format("|cFFFF00%s|r (%s): %s", tostring(key), valueType, displayValue))
        
        -- If it's a table, show its keys too
        if valueType == "table" then
            for subKey, subValue in pairs(value) do
                local subType = type(subValue)
                local subDisplay = ""
                if subType == "string" then
                    subDisplay = "\"" .. tostring(subValue):sub(1, 40) .. "\""
                elseif subType == "number" then
                    subDisplay = tostring(subValue)
                elseif subType == "boolean" then
                    subDisplay = tostring(subValue)
                else
                    subDisplay = "{" .. subType .. "}"
                end
                NWT.Debug(string.format("  |cAAFFAA.%s|r (%s): %s", tostring(subKey), subType, subDisplay))
            end
        end
    end
    
    NWT.Debug(string.format("|c00FF00=== Total: %d fields ===|r", count))
end

-- URL configuration (matches TraderScanner)
local MAX_URL_CHARS = 8400 -- Safe limit for URL length (tested ~8500 max)
local CROWN_BASE_URL = "https://proper-horse-442.convex.site/submit-crown-data"

-- URL queue state for batch submissions
NWT.CrownUrlQueue = {
    urls = {},
    currentIndex = 0,
    totalItems = 0,
}

local function urlEncode(str)
    if not str or str == "" then return "" end
    return string.gsub(str, "[^A-Za-z0-9%-_%.~]", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
end

-- Build URLs for server submission with batching (like TraderScanner)
function NWT.BuildCrownDataUrls()
    local items = NWT.savedVars.capturedCrownFurniture or {}
    local platform = GetWorldName() or "XBNA"
    local timestamp = GetTimeStamp()
    
    -- Build list of entries
    local entries = {}
    for key, item in pairs(items) do
        if item.itemId or item.name then
            local entry = string.format("%s,%s,%s",
                tostring(item.itemId or 0),
                (item.name or ""):gsub(",", ""):gsub(";", ""),
                tostring(item.crownPrice or 0)
            )
            table.insert(entries, entry)
        end
    end
    
    if #entries == 0 then
        return {}, 0
    end
    
    -- Calculate base URL length (without data)
    local baseUrlLen = #string.format("%s?p=%s&ts=%d&batch=1&data=", CROWN_BASE_URL, platform, timestamp)
    local maxDataChars = MAX_URL_CHARS - baseUrlLen
    
    -- Batch entries into multiple URLs
    local urls = {}
    local currentBatch = {}
    local currentLength = 0
    local batchNum = 1
    
    for _, entry in ipairs(entries) do
        local encodedEntry = urlEncode(entry)
        local entryLength = #encodedEntry + 1 -- +1 for separator
        
        -- If adding this entry would exceed limit, finalize current batch
        if currentLength + entryLength > maxDataChars and #currentBatch > 0 then
            local batchData = table.concat(currentBatch, ";")
            local url = string.format("%s?p=%s&ts=%d&batch=%d&data=%s",
                CROWN_BASE_URL, platform, timestamp, batchNum, urlEncode(batchData))
            table.insert(urls, url)
            batchNum = batchNum + 1
            currentBatch = {}
            currentLength = 0
        end
        
        table.insert(currentBatch, entry)
        currentLength = currentLength + entryLength
    end
    
    -- Final batch
    if #currentBatch > 0 then
        local batchData = table.concat(currentBatch, ";")
        local url = string.format("%s?p=%s&ts=%d&batch=%d&data=%s",
            CROWN_BASE_URL, platform, timestamp, batchNum, urlEncode(batchData))
        table.insert(urls, url)
    end
    
    return urls, #entries
end

function NWT.SubmitCrownData()
    local queue = NWT.CrownUrlQueue
    
    -- If we already have URLs queued and haven't finished, continue with next batch
    if #queue.urls > 0 and queue.currentIndex > 0 and queue.currentIndex <= #queue.urls then
        NWT.SubmitNextCrownBatch()
        return
    end
    
    -- Otherwise, build fresh URLs
    local urls, totalItems = NWT.BuildCrownDataUrls()
    
    if #urls == 0 then
NWT.Debug("|cFFFF00[Crown Capture]|r No data to submit")
        return
    end
    
    -- Store queue state
    queue.urls = urls
    queue.currentIndex = 1
    queue.totalItems = totalItems
    
    if #urls == 1 then
        NWT.Debug(string.format("|c00FFFF[Crown Capture]|r Submitting %d items (%d chars)... Press A to confirm", 
            totalItems, #urls[1]))
    else
        NWT.Debug(string.format("|c00FFFF[Crown Capture]|r Submitting %d items in %d batches... Press A after each", 
            totalItems, #urls))
NWT.Debug("|cFFFFAATip:|r Click Submit again after confirming each batch")
    end
    
    -- Submit first URL
    RequestOpenUnsafeURL(urls[1])
end

-- Submit next batch (call after user confirms previous)
function NWT.SubmitNextCrownBatch()
    local queue = NWT.CrownUrlQueue
    
    if #queue.urls == 0 then
NWT.Debug("|cFFFF00[Crown Capture]|r No URLs queued. Click Submit to start.")
        return false
    end
    
    queue.currentIndex = queue.currentIndex + 1
    
    if queue.currentIndex <= #queue.urls then
        NWT.Debug(string.format("|c00FFFF[Crown Capture]|r Batch %d/%d... Press A to confirm", 
            queue.currentIndex, #queue.urls))
        RequestOpenUnsafeURL(queue.urls[queue.currentIndex])
        return true
    else
        NWT.Debug(string.format("|c00FF00[Crown Capture]|r All %d batches submitted!", #queue.urls))
        queue.urls = {}
        queue.currentIndex = 0
        return false
    end
end

-- Get current submission status
function NWT.GetCrownSubmitStatus()
    local queue = NWT.CrownUrlQueue
    if #queue.urls == 0 then
        return "Submit Crown Data"
    elseif queue.currentIndex >= #queue.urls then
        return "All Submitted!"
    else
        return string.format("Submit Batch %d/%d", queue.currentIndex + 1, #queue.urls)
    end
end

-- Export captured data as text (for manual submission or Discord)
function NWT.ExportCrownData()
    local items = NWT.savedVars.capturedCrownFurniture or {}
    local count = 0
    local withPrice = 0
    
NWT.Debug("|c00FF00========== CROWN DATA EXPORT ==========|r")
NWT.Debug("|cFFFFAACopy this to share:|r")
NWT.Debug("```")
    for key, data in pairs(items) do
        count = count + 1
        if data.crownPrice and data.crownPrice > 0 then
            withPrice = withPrice + 1
            NWT.Debug(string.format("[%s] = {price = %d, name = \"%s\"},", 
                tostring(data.itemId or data.furnitureDataId or "?"), 
                data.crownPrice, 
                (data.name or "Unknown"):gsub("\"", "'")))
        end
    end
NWT.Debug("```")
    NWT.Debug(string.format("|cFFD700Total:|r %d items with prices (of %d captured)", withPrice, count))
NWT.Debug("|c00FF00==========================================|r")
end

-- Add keybind for capturing crown data
function NWT.AddCrownCaptureKeybinds()
    if not NWT.crownCaptureKeybindsAdded and KEYBIND_STRIP then
        if not NWT.crownCaptureKeybindGroup then
            NWT.crownCaptureKeybindGroup = {
                {
                    name = "Capture Crown Price",
                    order = 101,
                    keybind = "UI_SHORTCUT_TERTIARY", -- Y button
                    callback = function() NWT.CaptureFurnitureCrownPrice() end,
                },
            }
        end
        KEYBIND_STRIP:AddKeybindButtonGroup(NWT.crownCaptureKeybindGroup)
        NWT.crownCaptureKeybindsAdded = true
    end
end

function NWT.RemoveCrownCaptureKeybinds()
    if NWT.crownCaptureKeybindsAdded and KEYBIND_STRIP then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(NWT.crownCaptureKeybindGroup)
        NWT.crownCaptureKeybindsAdded = false
    end
end

function NWT.SetupCrownCaptureKeybinds()
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(scene, newState)
        if scene:GetName() == "gamepad_housing_furniture_scene" then
            if newState == SCENE_SHOWING then 
                zo_callLater(function() NWT.AddCrownCaptureKeybinds() end, 200)
            elseif newState == SCENE_HIDING then 
                NWT.RemoveCrownCaptureKeybinds() 
            end
        end
    end)
end

-- Scan ALL items in current furniture browser list
function NWT.ScanAllBrowserItems()
    local browserGamepad = GAMEPAD_HOUSING_FURNITURE_BROWSER or ZO_HOUSING_FURNITURE_BROWSER_GAMEPAD 
        or HOUSING_FURNITURE_BROWSER_GAMEPAD or _G["GAMEPAD_HOUSING_FURNITURE_BROWSER"] 
        or _G["ZO_HousingFurnitureBrowser_Gamepad"]
    
    if not browserGamepad then 
NWT.Debug("|cFFFF00[Crown Scan]|r Open the furniture browser first") 
        return 0
    end
    
    local currentList = nil
    if browserGamepad.GetCurrentList then 
        currentList = browserGamepad:GetCurrentList()
    end
    if not currentList and browserGamepad.currentList then
        currentList = browserGamepad.currentList
    end
    
    if not currentList then
NWT.Debug("|cFFFF00[Crown Scan]|r Could not find furniture list")
        return 0
    end
    
    local capturedCount = 0
    local dataList = currentList.dataList or currentList.data or {}
    
    -- Try to get all items from the list
    if currentList.GetNumItems then
        local numItems = currentList:GetNumItems()
        for i = 1, numItems do
            local itemData = nil
            if currentList.GetDataForDataIndex then
                itemData = currentList:GetDataForDataIndex(i)
            elseif currentList.GetEntryData then
                itemData = currentList:GetEntryData(i)
            end
            if itemData then
                local captured = NWT.CaptureItemData(itemData)
                if captured then capturedCount = capturedCount + 1 end
            end
        end
    else
        -- Fallback: iterate through dataList directly
        for _, entry in pairs(dataList) do
            local itemData = entry.data or entry
            if itemData then
                local captured = NWT.CaptureItemData(itemData)
                if captured then capturedCount = capturedCount + 1 end
            end
        end
    end
    
    return capturedCount
end

-- Helper to capture a single item's data
function NWT.CaptureItemData(targetData)
    if not targetData then return false end
    
    local itemName = targetData.name or targetData.formattedName or targetData.displayName 
        or targetData.text or targetData.label or targetData.rawName
    if not itemName or itemName == "" then return false end
    
    local itemId = nil
    local crownPrice = nil
    local furnitureDataId = targetData.furnitureDataId
    local collectibleId = targetData.collectibleId
    
    -- Try to get itemId
    if targetData.bagId and targetData.slotIndex then
        local itemLink = GetItemLink(targetData.bagId, targetData.slotIndex)
        if itemLink and itemLink ~= "" then
            itemId = GetItemLinkItemId(itemLink)
        end
    end
    
    -- Check for crown price (narrationPrice is the key field!)
    crownPrice = targetData.narrationPrice or targetData.currencyCost or targetData.cost 
        or targetData.price or targetData.crownCost or targetData.crowns or targetData.purchasePrice
    
    -- Check nested data (furnitureObject table - also has .cost!)
    if targetData.furnitureObject then
        local fo = targetData.furnitureObject
        crownPrice = crownPrice or fo.cost
        itemId = itemId or fo.furnitureDataId
        furnitureDataId = furnitureDataId or fo.furnitureDataId
    end
    
    if targetData.dataEntry and targetData.dataEntry.data then
        local nested = targetData.dataEntry.data
        crownPrice = crownPrice or nested.narrationPrice or nested.currencyCost or nested.cost or nested.price
        itemId = itemId or nested.itemId or nested.furnitureDataId
    end
    
    if not itemId then
        itemId = furnitureDataId or collectibleId
    end
    
    -- Clean up name
    itemName = zo_strformat("<<1>>", itemName)
    
    -- Store data
    local captureKey = tostring(itemId or itemName)
    NWT.savedVars.capturedCrownFurniture[captureKey] = {
        itemId = itemId,
        name = itemName,
        crownPrice = crownPrice,
        furnitureDataId = furnitureDataId,
        collectibleId = collectibleId,
        timestamp = GetTimeStamp(),
    }
    
    return true
end

-- Slash command handler
SLASH_COMMANDS["/nwcrown"] = function(args)
    local cmd = args:lower():match("^%s*(%S*)") or ""
    if cmd == "show" or cmd == "list" then
        NWT.ShowCapturedCrownData()
    elseif cmd == "clear" then
        NWT.ClearCapturedCrownData()
    elseif cmd == "submit" then
        NWT.SubmitCrownData()
    elseif cmd == "count" then
NWT.Debug("|c00FF00[Crown Capture]|r " .. NWT.GetCapturedCrownCount() .. " items captured")
    elseif cmd == "scan" then
        local count = NWT.ScanAllBrowserItems()
        NWT.Debug(string.format("|c00FF00[Crown Scan]|r Captured %d items from browser", count))
        PlaySound(SOUNDS.POSITIVE_CLICK)
    elseif cmd == "export" then
        NWT.ExportCrownData()
    elseif cmd == "next" then
        NWT.SubmitNextCrownBatch()
    elseif cmd == "debug" then
        NWT.DebugCrownData()
    else
NWT.Debug("|c00FF00========== CROWN CAPTURE ==========|r")
NWT.Debug("|cFFFFAAIn furniture browser: Press Y to capture|r")
NWT.Debug("|cFFFFAA/nwcrown scan|r - Scan ALL items in current list")
NWT.Debug("|cFFFFAA/nwcrown show|r - List captured items")
NWT.Debug("|cFFFFAA/nwcrown export|r - Export as Lua code")
NWT.Debug("|cFFFFAA/nwcrown submit|r - Send to server (batches if large)")
NWT.Debug("|cFFFFAA/nwcrown next|r - Submit next batch")
NWT.Debug("|cFFFFAA/nwcrown clear|r - Clear captured data")
NWT.Debug("|cFFFFAA/nwcrown count|r - Show capture count")
NWT.Debug("|cFFFFAA/nwcrown debug|r - Dump raw item fields")
NWT.Debug("|c00FF00===================================|r")
    end
end
