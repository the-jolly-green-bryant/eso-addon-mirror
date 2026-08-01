local TSCDataHub = {
    name = "TSCDataHub",
    version = "0.0.1",
}

-- Get LibAsync reference
local async = LibAsync

-- Local references for performance
local EVENT_MANAGER = EVENT_MANAGER
local zo_callLater = zo_callLater
local GetItemLinkFunctionalQuality = GetItemLinkFunctionalQuality
local isInitialized = false
local SAVED_VARS_VERSION = 1
local ONE_DAY_SECONDS = 24 * 60 * 60
local MAX_ALLOWED_CHARS = 7800 -- 8000 max from aws policy, subtracted 200 for safety

-- QR_BATCH_SIZE removed - now using character-aware batching with URL character limits
-- URL configuration for submissions
-- Set to true for production, false for local testing
local USE_PRODUCTION_URL = true

-- Local testing configuration
local LOCAL_BASE_URL = "http://localhost:3000"
local LOCAL_PATH_PREFIX = "/dev/esoapp/submissions"

-- Production configuration
local PROD_BASE_URL = "https://late-violet-4084.fly.dev"
local PROD_PATH_PREFIX = "/prod/esoapp/submissions"

local TRANSACTION_SEPARATOR = ";" -- Between transactions

-- Helper function to get base URL with access code
local function getBaseURL()
    local sv = TSCDataHub.savedVars
    if not sv then
        return nil
    end
    local accessCode = sv.accessCode or ""
    if accessCode == "" then
        return nil -- Will be checked before use
    end
    
    local baseURL, pathPrefix
    if USE_PRODUCTION_URL then
        baseURL = PROD_BASE_URL
        pathPrefix = PROD_PATH_PREFIX
    else
        baseURL = LOCAL_BASE_URL
        pathPrefix = LOCAL_PATH_PREFIX
    end
    
    return string.format("%s%s/%s", baseURL, pathPrefix, accessCode)
end

-- Default values for flags optimization
local DEFAULT_QUALITY = 1  -- Normal quality (most common)
local DEFAULT_PERSONAL = 0  -- Not currently used, kept for future personal sales tracking
local DEFAULT_QUANTITY = 1  -- Single item (most common)


-- Flag Encoding Rules (for backend parsing):
-- Flags are variable-length for compression optimization
-- Format: quality (1 digit) + optional quantity (3-4 digits, padded)
-- 
-- Possible flag lengths and meanings:
--   0 chars: quality=1 (Normal), quantity=1 (defaults - no flags needed)
--   1 char:  quality=2,3,4,5 with quantity=1
--            Examples: "2"=Fine, "3"=Superior, "4"=Epic, "5"=Legendary
--   4 chars: quality (1-5) with quantity 2-999
--            Format: quality (1 digit) + quantity (3 digits, zero-padded)
--            Examples: "1015"=Normal qty15, "2015"=Fine qty15, "1999"=Normal qty999
--   5 chars: quality (1-5) with quantity=1000
--            Format: quality (1 digit) + quantity (4 digits)
--            Examples: "11000"=Normal qty1000, "21000"=Fine qty1000, "51000"=Legendary qty1000
--
-- Quality values: 1=Normal, 2=Fine, 3=Superior, 4=Epic, 5=Legendary
-- Quantity: 1-1000 (1 is default, omitted when quality is also default)
--
-- Backend parsing logic:
--   if flags.length == 0: quality=1, quantity=1
--   if flags.length == 1: quality=flags[0], quantity=1
--   if flags.length == 4: quality=flags[0], quantity=flags[1-3] (parse as int, range 2-999)
--   if flags.length == 5: quality=flags[0], quantity=flags[1-4] (parse as int, value=1000)

local savedVars           -- Will be set after initialization
local SERVER_PLATFORM     -- Will be set at initialization
local PLAYER_ACCOUNT_NAME -- Will be set at initialization

local function urlEncode(str)
    if not str or str == "" then
        return ""
    end
    -- Encode any character that's not unreserved (A-Za-z0-9-_.~)
    -- Use explicit pattern matching to avoid nested character class issues
    return string.gsub(str, "[^A-Za-z0-9%-_%.~]", function(char)
        return string.format("%%%02X", string.byte(char))
    end)
end

-- URL submission state
local urlTable = nil
local currentUrlIndex = nil
local totalUrls = nil

-- Async processing state
TSCDataHub.currentTask = nil
TSCDataHub.progressText = ""
TSCDataHub.isProcessing = false
TSCDataHub.processingGuildSlot = nil      -- Track which guild is being processed
TSCDataHub.capturedGuildsThisSession = {} -- Track guilds captured in this session

-- Default settings structure
TSCDataHub.default = {
    trackPersonalSales = false,
    guildSubmissionTracking = {}, -- Track last submission timestamp per guild
    accessCode = "", -- 32-character alphanumeric code for personal submission page
    pin = "", -- User PIN for authentication
}

-- =========================================================================
-- QR CODE FUNCTIONS
-- =========================================================================

local qrUi = {
    window = nil,
    texture = nil,
    title = nil,
    autoHideId = nil,
}

local function EnsureQrWindow()
    if qrUi.window then
        return qrUi.window
    end

    local frameWidth = 240
    local frameHeight = 260
    local qrPadding = 16

    local window = WINDOW_MANAGER:CreateTopLevelWindow("TSCDataHubSettingsQR")
    window:SetDimensions(frameWidth, frameHeight)
    window:SetAnchor(CENTER, GUI_ROOT, CENTER, 420, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetDrawTier(DT_HIGH)

    local backdrop = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0.05, 0.05, 0.05, 0.95)
    backdrop:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BGedge.dds", 256, 128, 16)
    backdrop:SetEdgeColor(0.35, 0.6, 1, 0.8)

    local title = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    title:SetFont("ZoFontHeader3")
    title:SetColor(0.82, 0.92, 1, 1)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, qrPadding, qrPadding)
    title:SetAnchor(TOPRIGHT, window, TOPRIGHT, -qrPadding, qrPadding)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetText("QR Code")

    local closeButton = WINDOW_MANAGER:CreateControl(nil, window, CT_BUTTON)
    closeButton:SetDimensions(24, 24)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -8, 8)
    closeButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    closeButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
    closeButton:SetHandler("OnClicked", function()
        window:SetHidden(true)
    end)

    local qrControl = LibQRCode.CreateQRControl(frameWidth - (qrPadding * 2), "")
    qrControl:SetParent(window)
    qrControl:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, qrPadding)
    qrControl:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -qrPadding, -qrPadding)

    qrUi.window = window
    qrUi.texture = qrControl
    qrUi.title = title

    return window
end

function TSCDataHub.showSettingsQRCode(url, title)
    if not LibQRCode then
        CHAT_ROUTER:AddSystemMessage("LibQRCode not available, opening URL directly")
        RequestOpenUnsafeURL(url)
        return
    end

    local qrWindow = EnsureQrWindow()

    if qrUi.title then
        qrUi.title:SetText(title or "QR Code")
    end

    if qrUi.texture then
        LibQRCode.DrawQRCode(qrUi.texture, url)
    end

    if qrUi.autoHideId then
        zo_removeCallLater(qrUi.autoHideId)
        qrUi.autoHideId = nil
    end

    qrWindow:SetHidden(false)
    qrUi.autoHideId = zo_callLater(function()
        if qrUi.window and not qrUi.window:IsHidden() then
            qrUi.window:SetHidden(true)
        end
        qrUi.autoHideId = nil
    end, 10000)
end

function TSCDataHub.showGuildDataURL(url, title)
    RequestOpenUnsafeURL(url)
end

-- ============================================================================
-- URL SUBMISSION FUNCTIONS
-- ============================================================================

function TSCDataHub.updateSubmitButton()
    -- Force LHAS to refresh the controls like Dolgubons does
    if TSCDataHub.settings and TSCDataHub.settings.UpdateControls then
        TSCDataHub.settings:UpdateControls()
    end
end

function TSCDataHub.updateProgress(text)
    TSCDataHub.progressText = text or ""
    TSCDataHub.updateSubmitButton()
end

function TSCDataHub.setProcessing(processing, guildSlot)
    TSCDataHub.isProcessing = processing
    TSCDataHub.processingGuildSlot = processing and guildSlot or nil
    if not processing then
        TSCDataHub.progressText = ""
        TSCDataHub.currentTask = nil
        TSCDataHub.processingGuildSlot = nil
    end
    TSCDataHub.updateSubmitButton()
end

function TSCDataHub.resetSessionCaptures()
    TSCDataHub.capturedGuildsThisSession = {}
    TSCDataHub.updateSubmitButton()
end

-- ============================================================================
-- SUBMISSION TRACKING FUNCTIONS
-- ============================================================================

local function getSubmissionTracking(guildId)
    if not savedVars.guildSubmissionTracking then
        savedVars.guildSubmissionTracking = {}
    end
    return savedVars.guildSubmissionTracking[guildId]
end

local function setSubmissionTracking(guildId, timestamp, eventId)
    if not savedVars.guildSubmissionTracking then
        savedVars.guildSubmissionTracking = {}
    end
    savedVars.guildSubmissionTracking[guildId] = {
        lastSubmissionTime = timestamp,
        lastSubmissionEventId = eventId
    }
end

local function clearAllSubmissionTracking()
    -- Clear submission tracking for all guilds
    if savedVars.guildSubmissionTracking then
        savedVars.guildSubmissionTracking = {}
    end

    -- Clear the URL table to remove any pending submissions
    urlTable = nil
    currentUrlIndex = 1
    totalUrls = 0

    -- Reset session captures so all guilds can be captured again
    TSCDataHub.capturedGuildsThisSession = {}

    CHAT_ROUTER:AddSystemMessage("[TSC] Fresh start: Cleared all tracking, URLs, and session data")
end

local function findNewestEventInBatch(salesEvents)
    if not salesEvents or #salesEvents == 0 then
        return nil, nil
    end

    local newestTime = 0
    local newestEventId = nil

    for _, event in ipairs(salesEvents) do
        if event.timestamp > newestTime then
            newestTime = event.timestamp
            newestEventId = event.eventId
        end
    end

    return newestTime, newestEventId
end

-- Now that submission tracking functions are defined, we can define submitNextURL
function TSCDataHub.submitNextURL()
    if not urlTable or not currentUrlIndex or currentUrlIndex > totalUrls then
        return
    end

    local url = urlTable[currentUrlIndex]
    if url then
        RequestOpenUnsafeURL(url)
        currentUrlIndex = currentUrlIndex + 1

        -- Check if all URLs have been submitted
        if currentUrlIndex > totalUrls then
            -- All URLs submitted - now update the submission tracking
            if urlTable.pendingSubmissionTracking then
                -- Update tracking for all guilds that were captured this session
                for guildId, pending in pairs(urlTable.pendingSubmissionTracking) do
                    setSubmissionTracking(pending.guildId, pending.timestamp, pending.eventId)
                end
                CHAT_ROUTER:AddSystemMessage("All data submitted successfully - submission tracking updated")
                urlTable.pendingSubmissionTracking = nil
            end

            -- Reset session captures since all data has been submitted
            TSCDataHub.resetSessionCaptures()
        end

        TSCDataHub.updateSubmitButton()
    end
end

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function normalizePlayerName(name)
    if not name then return "" end
    -- Remove leading @, leading/trailing spaces, convert to lowercase for comparison
    name = string.gsub(name, "^@", "")
    name = string.gsub(name, "^ ", "")
    name = string.gsub(name, " $", "")
    name = string.lower(name)
    return name
end

local function isGuildHistoryReady(guildId, category)
    local numEvents = GetNumGuildHistoryEvents(guildId, category)
    return numEvents > 0
end

local function isSalesEvent(eventData)
    -- Check if event is a sales event
    -- For now, accept type 0 since that's what we're getting from the API
    return eventData and
        (eventData.eventType == 0 or eventData.eventType == GUILD_EVENT_ITEM_SOLD or eventData.eventType == GUILD_EVENT_ITEM_LISTED)
end

local function extractSalesDetails(eventData)
    -- CHAT_ROUTER:AddSystemMessage("extractSalesDetails: " .. eventData.itemLink)
    -- Use ESO's built-in functions to extract item information
    local itemId = GetItemLinkItemId(eventData.itemLink)
    -- CHAT_ROUTER:AddSystemMessage("extractSalesDetails: " .. itemId)
    local trait = GetItemLinkTraitInfo(eventData.itemLink)
    -- CHAT_ROUTER:AddSystemMessage("extractSalesDetails: " .. trait)
    local quality = GetItemLinkFunctionalQuality(eventData.itemLink)
    -- CHAT_ROUTER:AddSystemMessage("extractSalesDetails: " .. quality)

    -- Validate quality: must be 1-5 (1=Normal, 2=Fine, 3=Superior, 4=Epic, 5=Legendary)
    -- If invalid (e.g., 0 from API edge cases with untradeable items), default to 1 (Normal)
    if not quality or quality < 1 or quality > 5 then
        quality = DEFAULT_QUALITY
    end

    -- Convert to standardized transaction format
    return {
        itemId = itemId,
        trait = trait,
        quality = quality,
        price = eventData.price or 0,
        timestamp = eventData.timestamp,
        seller = eventData.seller or "",
        quantity = eventData.quantity or 1
    }
end


-- ============================================================================
-- DATA FETCHING FUNCTIONS (Phase 1)
-- ============================================================================


local function waitForGuildHistory(guildId, category, callback, maxRetries)
    maxRetries = maxRetries or 10 -- Default to 10 retries (5 seconds)

    if isGuildHistoryReady(guildId, category) then
        callback()
    elseif maxRetries > 0 then
        zo_callLater(function()
            waitForGuildHistory(guildId, category, callback, maxRetries - 1)
        end, 500) -- Wait 500ms before retry
    else
        CHAT_ROUTER:AddSystemMessage("Guild history failed to load")
        callback() -- Proceed anyway, let the individual fetches handle failures
    end
end

local function fetchEventData(guildId, category, index)
    -- For trader events, use the specific trader API
    if category == GUILD_HISTORY_EVENT_CATEGORY_TRADER then
        local eventId, timestampS, _, eventType, sellerDisplayName, _, itemLink, quantity, price, _ =
            GetGuildHistoryTraderEventInfo(guildId, index)

        -- Check if we got valid data
        if not eventId or eventId == 0 or not timestampS or timestampS == 0 then
            return nil
        end

        return {
            eventId = eventId,
            timestamp = timestampS,
            eventType = eventType,
            index = index,
            seller = sellerDisplayName,
            itemLink = itemLink,
            quantity = quantity,
            price = price,
        }
    else
        -- For other categories, use basic info
        local eventId, eventTimestamp = GetGuildHistoryEventBasicInfo(guildId, category, index)

        if not eventId or eventId == 0 or not eventTimestamp or eventTimestamp == 0 then
            return nil
        end

        return {
            eventId = eventId,
            timestamp = eventTimestamp,
            index = index
        }
    end
end

local function processEventBatch(guildId, category, startIndex, endIndex)
    local totalEvents = 0
    local salesEvents = {}
    local salesCount = 0
    local eventTypeCounts = {}

    -- Process each index in the range
    for index = startIndex, endIndex do
        totalEvents = totalEvents + 1

        -- Fetch basic event data
        local eventData = fetchEventData(guildId, category, index)
        if eventData then
            -- Track event types for debugging
            local eventType = eventData.eventType or "unknown"
            eventTypeCounts[eventType] = (eventTypeCounts[eventType] or 0) + 1

            -- Log first few events to see what we're getting
            -- if totalEvents <= 5 then
            --     CHAT_ROUTER:AddSystemMessage("Event " ..
            --         tostring(index) ..
            --         " - Type: " .. tostring(eventType) .. ", Price: " .. tostring(eventData.price or "nil"))
            --     CHAT_ROUTER:AddSystemMessage("  Full data: " ..
            --         tostring(eventData.eventId) ..
            --         ", " ..
            --         tostring(eventData.timestamp) ..
            --         ", " ..
            --         tostring(eventData.seller or "nil") ..
            --         ", " ..
            --         tostring(eventData.buyer or "nil") ..
            --         ", " .. tostring(eventData.quantity or "nil") .. ", " .. tostring(eventData.tax or "nil"))
            --     CHAT_ROUTER:AddSystemMessage("  Raw itemLink: " .. tostring(eventData.itemLink or "nil"))
            -- end

            -- Check if it's a sales event
            if isSalesEvent(eventData) then
                salesCount = salesCount + 1

                -- Get detailed sales data
                local salesData = extractSalesDetails(eventData)
                if salesData then
                    table.insert(salesEvents, salesData)
                end
            end
        end
    end

    -- Log event type breakdown
    -- CHAT_ROUTER:AddSystemMessage("Event types found:")
    for eventType, count in pairs(eventTypeCounts) do
        -- CHAT_ROUTER:AddSystemMessage("  Type " .. tostring(eventType) .. ": " .. tostring(count) .. " events")
    end

    -- CHAT_ROUTER:AddSystemMessage("Found " .. tostring(salesCount) .. " sales events")

    return salesEvents
end

local function processAllEventsAsync(guildId, category, startIndex, endIndex, callback)
    -- Create async task for processing all events
    local task = async:Create("ProcessAllEvents")
    TSCDataHub.currentTask = task

    local totalEvents = endIndex - startIndex + 1
    local allSalesEvents = {}
    local totalSalesCount = 0
    local totalProcessedEvents = 0
    local eventTypeCounts = {}

    local EVENT_BATCH_SIZE = 100
    local currentBatchStart = startIndex

    -- CHAT_ROUTER:AddSystemMessage("[TSC] Starting to process " .. totalEvents .. " events in batches of " .. EVENT_BATCH_SIZE)

    local function processBatch()
        if currentBatchStart > endIndex then
            -- All batches complete
            -- CHAT_ROUTER:AddSystemMessage("[TSC] Completed processing all events. Found " .. totalSalesCount .. " sales events out of " .. totalProcessedEvents .. " total events")
            if callback then
                callback(allSalesEvents)
            end
            return
        end

        local batchEnd = math.min(currentBatchStart + EVENT_BATCH_SIZE - 1, endIndex)
        local batchNum = math.floor((currentBatchStart - startIndex) / EVENT_BATCH_SIZE) + 1
        local totalBatches = math.ceil(totalEvents / EVENT_BATCH_SIZE)

        -- Process this batch asynchronously
        task:Call(function()
            local batchSalesEvents = {}
            local batchSalesCount = 0

            -- Process events in this batch
            for index = currentBatchStart, batchEnd do
                totalProcessedEvents = totalProcessedEvents + 1

                -- Fetch basic event data
                local eventData = fetchEventData(guildId, category, index)
                if eventData then
                    -- Track event types for debugging
                    local eventType = eventData.eventType or "unknown"
                    eventTypeCounts[eventType] = (eventTypeCounts[eventType] or 0) + 1

                    -- Check if it's a sales event
                    if isSalesEvent(eventData) then
                        batchSalesCount = batchSalesCount + 1
                        totalSalesCount = totalSalesCount + 1

                        -- Get detailed sales data
                        local salesData = extractSalesDetails(eventData)
                        if salesData then
                            table.insert(batchSalesEvents, salesData)
                            table.insert(allSalesEvents, salesData)
                        end
                    end
                end
            end
        end):Then(function()
            -- Move to next batch
            currentBatchStart = currentBatchStart + EVENT_BATCH_SIZE
            processBatch() -- Continue with next batch
        end)
    end

    -- Start processing batches
    task:Call(function()
        processBatch()
    end):OnError(function(task)
        CHAT_ROUTER:AddSystemMessage("[TSC] Error processing events: " .. tostring(task.Error))
        if callback then
            callback({})
        end
    end):Finally(function()
        TSCDataHub.currentTask = nil
    end)
end

local function fetchGuildSalesAsync(guildId, startTime, callback)
    local currentTime = GetTimeStamp()

    -- Use TRADER category for sales data
    local newestIndex, oldestIndex = GetGuildHistoryEventIndicesForTimeRange(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER,
        currentTime, startTime)

    if not newestIndex or not oldestIndex then
        CHAT_ROUTER:AddSystemMessage("No guild history events found in time range")
        callback({})
        return
    end

    -- Determine the correct order (oldest to newest)
    local startIndex, endIndex
    if oldestIndex <= newestIndex then
        startIndex, endIndex = oldestIndex, newestIndex
    else
        startIndex, endIndex = newestIndex, oldestIndex
    end

    local totalEvents = endIndex - startIndex + 1
    -- CHAT_ROUTER:AddSystemMessage("[TSC] Processing " .. totalEvents .. " events from guild history (indices " .. startIndex .. " to " .. endIndex .. ")")

    -- Wait for guild history to be ready before processing
    waitForGuildHistory(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, function()
        -- Process ALL events using our new async function that handles all batches
        processAllEventsAsync(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER, startIndex, endIndex, function(salesEvents)
            -- Return all the sales events to the callback
            callback(salesEvents)
        end)
    end)
end

-- ============================================================================
-- DATA ENCODING FUNCTIONS
-- ============================================================================

local function encodeFlags(quality, quantity)
    -- Variable-length flag encoding for compression
    -- See documentation above for flag format rules
    
    -- Check if any values are non-default
    -- Trait is baked into itemId, so not included in flags
    if quality == DEFAULT_QUALITY and quantity == DEFAULT_QUANTITY then
        return nil -- No flags needed (both defaults)
    end

    -- Build base flags: quality (1 digit, 1-5)
    -- Quality values: 1=Normal, 2=Fine, 3=Superior, 4=Epic, 5=Legendary
    local flags = string.format("%d", quality)

    -- Add quantity if it's not the default
    -- Quantities 2-999: 3 digits zero-padded (results in 4-char flags)
    -- Quantity 1000: 4 digits (results in 5-char flags)
    if quantity ~= DEFAULT_QUANTITY then
        flags = flags .. string.format("%03d", quantity)
    end

    return flags
end

local function encodeTransaction(transaction, minTimestamp)
    local deltaTime = transaction.timestamp - minTimestamp

    -- Personal sales tracking is disabled for now (may be added in the future)
    -- Check if this is a personal sale (if tracking is enabled)
    -- PLAYER_ACCOUNT_NAME is already normalized at init, so just normalize the seller name
    -- local normalizedSeller = normalizePlayerName(transaction.seller)
    -- local isPersonalSale = savedVars.trackPersonalSales and normalizedSeller == PLAYER_ACCOUNT_NAME
    -- local isPersonalSale = false

    -- Encode flags if any are non-default
    -- Trait is baked into itemId, so not passed to encodeFlags
    -- Personal sales tracking disabled - not used in encoding
    local flags = encodeFlags(transaction.quality, transaction.quantity or 1)

    local encodedTransaction
    if flags then
        -- Include flags field: itemId,price,deltaTime,flags
        encodedTransaction = string.format("%d,%d,%d,%s",
            transaction.itemId,
            transaction.price,
            deltaTime,
            flags
        )
    else
        -- No flags field: itemId,price,deltaTime
        encodedTransaction = string.format("%d,%d,%d",
            transaction.itemId,
            transaction.price,
            deltaTime
        )
    end

    return encodedTransaction
end

local function computeBatchBudget(guildId, guildName, referenceTimestamp)
    local baseURL = getBaseURL()
    if not baseURL then
        return 0, "", "" -- Invalid - access code missing
    end

    local sv = TSCDataHub.savedVars
    if not sv or not sv.pin or sv.pin == "" then
        return 0, "", "" -- Invalid - PIN missing
    end

    local playerName = savedVars.trackPersonalSales and PLAYER_ACCOUNT_NAME or "0"
    local encodedPlayerName = urlEncode(playerName)
    local encodedGuildName = urlEncode(guildName)
    local encodedPin = urlEncode(sv.pin)

    local fixedPrefix = string.format("%s?code=%s&sp=%d&g=%d&gn=%s&t=%d&p=%s&d=",
        baseURL, encodedPin, SERVER_PLATFORM, guildId, encodedGuildName, referenceTimestamp, encodedPlayerName)

    local budget = MAX_ALLOWED_CHARS - #fixedPrefix
    if budget < 0 then
        budget = 0
    end

    return budget, encodedPlayerName, encodedGuildName
end

local function createURLFromEncodedBatch(encodedBatch, guildId, encodedGuildName, referenceTimestamp, encodedPlayerName)
    local baseURL = getBaseURL()
    if not baseURL then
        return nil, 0 -- Invalid - access code missing
    end

    local sv = TSCDataHub.savedVars
    if not sv or not sv.pin or sv.pin == "" then
        return nil, 0 -- Invalid - PIN missing
    end

    local encodedPin = urlEncode(sv.pin)
    local dataString = table.concat(encodedBatch.encodedTransactions, TRANSACTION_SEPARATOR)

    local url = string.format("%s?code=%s&sp=%d&g=%d&gn=%s&t=%d&p=%s&d=%s",
        baseURL, encodedPin, SERVER_PLATFORM, guildId, encodedGuildName, referenceTimestamp, encodedPlayerName, dataString)

    return url, #url
end

local function createEncodedBatches(encodedTransactions, maxTransactionChars)
    -- Split encoded transactions into batches based on character count
    local batches = {}
    local currentBatch = {
        encodedTransactions = {}
    }
    local currentBatchLength = 0

    for _, encodedTxn in ipairs(encodedTransactions) do
        local transactionLength = string.len(encodedTxn.encoded) + 1 -- +1 for separator

        -- Check if adding this transaction would exceed the limit
        if (currentBatchLength + transactionLength) > maxTransactionChars and #currentBatch.encodedTransactions > 0 then
            -- Current batch is full, save it and start fresh
            table.insert(batches, currentBatch)
            currentBatch = {
                encodedTransactions = { encodedTxn.encoded }
            }
            currentBatchLength = transactionLength
        else
            -- Add to current batch
            table.insert(currentBatch.encodedTransactions, encodedTxn.encoded)
            currentBatchLength = currentBatchLength + transactionLength
        end
    end

    -- Add remaining transactions
    if #currentBatch.encodedTransactions > 0 then
        table.insert(batches, currentBatch)
    end
    return batches
end

local function encodeAllTransactionsAsync(salesEvents, referenceTimestamp, callback)
    if not salesEvents or #salesEvents == 0 then
        callback({})
        return
    end

    local task = async:Create("EncodeAllTransactions")
    TSCDataHub.currentTask = task

    local totalTransactions = #salesEvents
    local allEncodedTransactions = {}
    local totalProcessedTransactions = 0

    local ENCODING_BATCH_SIZE = 100
    local currentBatchStart = 1

    -- CHAT_ROUTER:AddSystemMessage("[TSC] Starting to encode " .. totalTransactions .. " transactions in batches of " .. ENCODING_BATCH_SIZE)

    local function encodeBatch()
        if currentBatchStart > totalTransactions then
            -- All batches complete
            -- CHAT_ROUTER:AddSystemMessage("[TSC] Completed encoding all transactions. Total: " .. #allEncodedTransactions)
            if callback then
                callback(allEncodedTransactions)
            end
            return
        end

        local batchEnd = math.min(currentBatchStart + ENCODING_BATCH_SIZE - 1, totalTransactions)
        local batchNum = math.floor((currentBatchStart - 1) / ENCODING_BATCH_SIZE) + 1
        local totalBatches = math.ceil(totalTransactions / ENCODING_BATCH_SIZE)

        -- Encode this batch asynchronously
        task:Call(function()
            local batchEncodedTransactions = {}

            -- Encode transactions in this batch
            for i = currentBatchStart, batchEnd do
                local transaction = salesEvents[i]
                local encoded = encodeTransaction(transaction, referenceTimestamp)
                local encodedTxn = {
                    encoded = encoded,
                    timestamp = transaction.timestamp
                }
                table.insert(batchEncodedTransactions, encodedTxn)
                table.insert(allEncodedTransactions, encodedTxn)
                totalProcessedTransactions = totalProcessedTransactions + 1
            end
        end):Then(function()
            -- Move to next batch
            currentBatchStart = currentBatchStart + ENCODING_BATCH_SIZE
            encodeBatch() -- Continue with next batch
        end)
    end

    -- Start encoding batches
    task:Call(function()
        encodeBatch()
    end):OnError(function(task)
        CHAT_ROUTER:AddSystemMessage("[TSC] Error encoding transactions: " .. tostring(task.Error))
        if callback then
            callback({})
        end
    end):Finally(function()
        TSCDataHub.currentTask = nil
    end)
end

-- ============================================================================
-- SERVICE FUNCTIONS
-- ============================================================================

local function validateGuildSlot(guildSlot)
    local numGuilds = GetNumGuilds()

    if guildSlot > numGuilds then
        local ordinal = ""
        if guildSlot == 1 then
            ordinal = "1st"
        elseif guildSlot == 2 then
            ordinal = "2nd"
        elseif guildSlot == 3 then
            ordinal = "3rd"
        else
            ordinal = guildSlot .. "th"
        end

        return nil, "You don't have a " .. ordinal .. " guild!"
    end

    return true
end

local function getGuildData(guildSlot)
    local guildId = GetGuildId(guildSlot)
    local guildName = GetGuildName(guildId) or "gn-1"
    local currentTime = GetTimeStamp()
    local eightDaysAgo = currentTime - (8 * 24 * 60 * 60) - 1

    -- Check submission tracking to determine start time
    local submissionTracking = getSubmissionTracking(guildId)
    local startTime

    if submissionTracking and submissionTracking.lastSubmissionTime then
        -- Returning user: only get data newer than last submission
        startTime = submissionTracking.lastSubmissionTime + 1

        -- But enforce 8-day maximum lookback for very old submissions
        if startTime < eightDaysAgo then
            startTime = eightDaysAgo
            CHAT_ROUTER:AddSystemMessage("Last submission was >8 days ago, capturing last 8 days")
        else
            local daysSinceSubmission = math.floor((currentTime - submissionTracking.lastSubmissionTime) / 86400)
            CHAT_ROUTER:AddSystemMessage("Capturing new data since last submission (" ..
                daysSinceSubmission .. " days ago)")
        end
    else
        -- New user: get up to 8 days
        startTime = eightDaysAgo
        CHAT_ROUTER:AddSystemMessage("First time capturing this guild - getting up to 8 days of data")
    end

    -- CHAT_ROUTER:AddSystemMessage("[TSC] Time range: " .. startTime .. " to " .. currentTime .. " (duration: " .. string.format("%.1f", (currentTime - startTime) / 86400) .. " days)")

    return {
        guildId = guildId,
        guildName = guildName,
        startTime = startTime,
        currentTime = currentTime
    }
end

-- ============================================================================
-- CONTROLLER FUNCTIONS
-- ============================================================================

local function CheckGuildAndCollect(guildSlot)
    -- Prevent multiple simultaneous operations
    if TSCDataHub.isProcessing then
        CHAT_ROUTER:AddSystemMessage("[TSC] Processing already in progress. Please wait or cancel current operation.")
        return
    end

    -- Set processing state for this guild
    TSCDataHub.setProcessing(true, guildSlot)

    -- Step 1: Validate guild slot
    local isValid, errorMsg = validateGuildSlot(guildSlot)
    if not isValid then
        CHAT_ROUTER:AddSystemMessage(errorMsg)
        return
    end

    -- Step 2: Get guild data with automatic windowing
    local guildData = getGuildData(guildSlot)

    -- CHAT_ROUTER:AddSystemMessage("Starting data collection for guild " .. guildData.guildId)

    -- Step 3: Start async data collection for the entire time range
    -- Initialize urlTable if it doesn't exist, but don't clear existing URLs
    if not urlTable then
        urlTable = {}
    end

    -- Wait a bit for guild history to be ready
    zo_callLater(function()
        -- Fetch ALL sales data for the time range using async processing
        fetchGuildSalesAsync(guildData.guildId, guildData.startTime, function(salesEvents)
            if salesEvents and #salesEvents > 0 then
                -- Use collection start time as universal reference for delta compression
                local referenceTimestamp = guildData.startTime

                -- Step 1: Encode all transactions asynchronously
                encodeAllTransactionsAsync(salesEvents, referenceTimestamp, function(encodedTransactions)
                    if #encodedTransactions > 0 then
                        -- Step 2: Create character-aware batches using platform and method specific limits
                        -- CHAT_ROUTER:AddSystemMessage("[TSC] Creating batches from " .. #encodedTransactions .. " transactions with " .. MAX_ALLOWED_CHARS .. " char limit")
                        local batchBudget, encodedPlayerName, encodedGuildName = computeBatchBudget(guildData.guildId, guildData.guildName, referenceTimestamp)
                        local sv = TSCDataHub.savedVars
                        if batchBudget == 0 and (not sv or not sv.accessCode or sv.accessCode == "") then
                            CHAT_ROUTER:AddSystemMessage("[TSC] Error: Access code is required to create submission URLs")
                            TSCDataHub.setProcessing(false)
                            return
                        end
                        if not sv or not sv.pin or sv.pin == "" then
                            CHAT_ROUTER:AddSystemMessage("[TSC] Error: PIN is required to create submission URLs")
                            TSCDataHub.setProcessing(false)
                            return
                        end
                        local batches = createEncodedBatches(encodedTransactions, batchBudget)

                        for i, batch in ipairs(batches) do
                            local url, length = createURLFromEncodedBatch(batch, guildData.guildId, encodedGuildName, referenceTimestamp, encodedPlayerName)
                            local sv = TSCDataHub.savedVars
                            if not url then
                                CHAT_ROUTER:AddSystemMessage("[TSC] Error: Access code is required to create submission URLs")
                                break
                            elseif not sv or not sv.pin or sv.pin == "" then
                                CHAT_ROUTER:AddSystemMessage("[TSC] Error: PIN is required to create submission URLs")
                                break
                            elseif length > MAX_ALLOWED_CHARS then
                                CHAT_ROUTER:AddSystemMessage(string.format("[TSC] Warning: URL %d length (%d) exceeded limit, skipping", i, length))
                            else
                                table.insert(urlTable, url)
                            end
                        end

                        -- Update URL indices (don't reset if there are existing URLs)
                        if not currentUrlIndex then
                            currentUrlIndex = 1
                        end
                        totalUrls = #urlTable

                        -- Store data for submission tracking update after submission
                        local newestTime, newestEventId = findNewestEventInBatch(salesEvents)
                        if newestTime then
                            -- Store these for updating after all URLs are submitted
                            if not urlTable.pendingSubmissionTracking then
                                urlTable.pendingSubmissionTracking = {}
                            end
                            urlTable.pendingSubmissionTracking[guildData.guildId] = {
                                guildId = guildData.guildId,
                                timestamp = newestTime,
                                eventId = newestEventId
                            }
                        end

                        -- Mark this guild as captured this session
                        TSCDataHub.capturedGuildsThisSession[guildData.guildId] = true

                        TSCDataHub.setProcessing(false)
                        -- CHAT_ROUTER:AddSystemMessage("[TSC] Processing complete! Ready to submit " .. totalUrls .. " URLs")
                        TSCDataHub.updateSubmitButton()
                    else
                        TSCDataHub.setProcessing(false)
                        CHAT_ROUTER:AddSystemMessage("No transactions to encode")
                    end
                end)
            else
                TSCDataHub.setProcessing(false)
                CHAT_ROUTER:AddSystemMessage("No sales events found in the specified time range")
            end
        end)
    end, 1000) -- Wait 1 second before starting
end

-- ============================================================================
-- SETTINGS FUNCTIONS
-- ============================================================================

local function setupSettingsMenu()
    local LHAS = LibHarvensAddonSettings
    if not LHAS then
        d("LibHarvensAddonSettings not found - settings menu will not be available")
        return
    end

    local options = {
        allowDefaults = true,         --will allow users to reset the settings to default values
        allowRefresh = true,          --if this is true, when one of settings is changed, all other settings will be checked for state change (disable/enable)
        defaultsFunction = function() --this function is called when allowDefaults is true and user hit the reset button
            d("Reset")
        end,
    }
    --Create settings "container" for your addon
    --First parameter is the name that will be displayed in the options,
    --Second parameter is the options table (it is optional)
    local settings = LHAS:AddAddon("TSC Data Hub", options)
    if not settings then
        return
    end

    -- Store reference to settings for refreshing
    TSCDataHub.settings = settings

    --[[
        INFORMATION SECTION
    --]]
    local informationSection = {
        type = LHAS.ST_SECTION,
        label = "Information",
    }
    settings:AddSetting(informationSection)

    local whatsNewButton = {
        type = LHAS.ST_BUTTON,
        label = "What's New",
        tooltip = [[v126: Production Release]],
        buttonText = "View Update Info",
        clickHandler = function(control, button)
        end,
    }
    settings:AddSetting(whatsNewButton)

    local bugReportButton = {
        type = LHAS.ST_BUTTON,
        label = "Troubleshoot",
        tooltip = "Generate a QR code that will link to the FAQ + Troubleshooting page on tamrielsavings.com",
        buttonText = "Open QR Code",
        clickHandler = function(control, button)
            TSCDataHub.showSettingsQRCode("https://tamrielsavings.com/faq", "Troubleshoot")
        end,
    }
    settings:AddSetting(bugReportButton)

    local discordButton = {
        type = LHAS.ST_BUTTON,
        label = "Join TSC on Discord",
        tooltip = "Generate a QR code that will link to the TSC Discord server",
        buttonText = "Open QR Code",
        clickHandler = function(control, button)
            TSCDataHub.showSettingsQRCode("https://discord.gg/7DzUVCQ", "Join TSC on Discord")
        end,
    }
    settings:AddSetting(discordButton)

    local donateButton = {
        type = LHAS.ST_BUTTON,
        label = "Donate to TSC",
        tooltip = "Generate a QR code that will link to the Donate page on tamrielsavings.com",
        buttonText = "Open QR Code",
        clickHandler = function(control, button)
            TSCDataHub.showSettingsQRCode("https://tamrielsavings.com/donations", "Donate to TSC")
        end,
    }
    settings:AddSetting(donateButton)

    local infoButton = {
        type = LHAS.ST_BUTTON,
        label = "Info",
        tooltip = "To sign up to submit data, contact SavageTSC on Discord\n\n" ..
            "Data is captured automatically based on your submission history:\n" ..
            "• First time: Up to 8 days of data\n" ..
            "• Returning users: Only new data since last submission\n" ..
            "• No duplicate data sent to server",
        buttonText = "Info",
        clickHandler = function(control, button)
        end,
    }
    settings:AddSetting(infoButton)

    local howToButton = {
        type = LHAS.ST_BUTTON,
        label = "How To",
        tooltip =
            "Before capturing, manually scroll through your guild sales history in-game:\n" ..
            "• Open Menu > Social > Guilds, select a guild, then History > Purchases\n" ..
            "• Scroll backward (Right Trigger on Xbox, R2 on PS) to load at least 8 days of sales data\n" ..
            "• Repeat for each guild you want to capture\n\n" ..
            "Enter your Access Code and PIN in the 'Data Submission Settings' section below.\n" ..
            "This is a one-time setup - your information will be saved and remembered.\n" ..
            "Note: If you clear your game data or cache, you will need to re-enter this information.\n\n" ..
            "To capture sales data, scroll down to the first 'Ready to Capture' guild and click the 'Capture' button.\n\n" ..
            "Do this for each guild you want to capture data for.\n\n" ..
            "To submit the data, click the 'Submit URL ...' button below.\n\n" ..
            "Repeat 'Submit URL' until all URLs are submitted.",
        buttonText = "How To",
        clickHandler = function(control, button)
        end,
    }
    settings:AddSetting(howToButton)

    --[[
        TRADING SETTINGS SECTION
    --]]
    local tradingSettingsSection = {
        type = LHAS.ST_SECTION,
        label = "Data Submission Settings",
    }
    settings:AddSetting(tradingSettingsSection)

    local accessCodeSetting = {
        type = LHAS.ST_EDIT,
        label = "Access Code",
        tooltip = "Enter your 32-character access code to enable data submissions. This code identifies your personal submission page.",
        maxChars = 32,
        setFunction = function(value)
            savedVars.accessCode = value or ""
        end,
        getFunction = function()
            return savedVars.accessCode or ""
        end,
    }
    settings:AddSetting(accessCodeSetting)

    local pinSetting = {
        type = LHAS.ST_EDIT,
        label = "PIN",
        tooltip = "Enter your PIN for authentication.",
        maxChars = 8,
        setFunction = function(value)
            savedVars.pin = value or ""
        end,
        getFunction = function()
            return savedVars.pin or ""
        end,
    }
    settings:AddSetting(pinSetting)

    --[[
        We will be keeping this disabled for now as we are not ready to track personal sales yet.
        We need a way to be GDPR compliant:
        - We need to be able to opt-in to track personal sales
        - We need to be able to opt-out of tracking personal sales
        - We need to be able to delete all personal sales data
        - We need to be able to deliver all personal sales data
    --]]

    -- local trackPersonalSales = {
    --     type = LHAS.ST_CHECKBOX,
    --     label = "Track Personal Sales",
    --     tooltip =
    --     "Setting this ON will track allow you to track your personal sales on the website.  Setting this OFF will not track your personal sales.",
    --     default = false,
    --     setFunction = function(state)
    --         savedVars.trackPersonalSales = state
    --     end,
    --     getFunction = function()
    --         return savedVars.trackPersonalSales
    --     end,
    -- }
    -- settings:AddSetting(trackPersonalSales)

    --[[
        GUILD CAPTURE SETTINGS SECTION
    --]]
    -- Create individual sections for each guild
    local numGuilds = GetNumGuilds()

    for i = 1, numGuilds do
        local guildSlot = i -- Capture the guild slot value
        local guildId = GetGuildId(guildSlot)
        local guildName = GetGuildName(guildId) or "Guild " .. guildSlot

        -- Create section for this guild
        local guildSection = {
            type = LHAS.ST_SECTION,
            label = guildName,
        }
        settings:AddSetting(guildSection)

        -- Guild status label (without guild name since it's in the section)
        local guildStatusLabel = {
            type = LHAS.ST_LABEL,
            label = function()
                local currentGuildId = GetGuildId(guildSlot)

                -- Check if this guild is currently being processed
                if TSCDataHub.isProcessing and TSCDataHub.processingGuildSlot == guildSlot then
                    return "|cFFFF00Capturing...|r" -- Yellow
                end

                -- Check if this guild was captured this session
                if TSCDataHub.capturedGuildsThisSession[currentGuildId] then
                    return "|c00FFFF Submit URL(s) below|r" -- Cyan
                end

                -- Standard status checking
                local submissionTracking = getSubmissionTracking(currentGuildId)
                local statusText = "Ready to capture"
                local color = "|c00FF00" -- Green

                if submissionTracking and submissionTracking.lastSubmissionTime then
                    -- Check if there's new data since last submission
                    local numEvents = GetNumGuildHistoryEvents(currentGuildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
                    if numEvents > 0 then
                        local _, newestTime = GetGuildHistoryEventBasicInfo(currentGuildId,
                            GUILD_HISTORY_EVENT_CATEGORY_TRADER, 1)
                        if newestTime and newestTime > submissionTracking.lastSubmissionTime then
                            statusText = "Ready to capture"
                            color = "|c00FF00" -- Green
                        else
                            statusText = "Up to date"
                            color = "|c888888" -- Gray
                        end
                    else
                        statusText = "No data available"
                        color = "|c888888" -- Gray
                    end
                else
                    -- No previous submission
                    statusText = "Ready to capture"
                    color = "|c00FF00" -- Green
                end

                return color .. statusText .. "|r"
            end,
        }
        settings:AddSetting(guildStatusLabel)

        -- Capture button for this guild (with guild name in button text)
        local guildCaptureButton = {
            type = LHAS.ST_BUTTON,
            label = "Capture " .. guildName,
            tooltip = "Start capturing new sales data for " ..
                guildName .. " (automatically determines what data to capture)",
            buttonText = function()
                local currentGuildId = GetGuildId(guildSlot)
                if TSCDataHub.isProcessing and TSCDataHub.processingGuildSlot == guildSlot then
                    return "Capturing..."
                elseif TSCDataHub.capturedGuildsThisSession[currentGuildId] then
                    return "Captured"
                end
                return "Capture"
            end,
            disable = function()
                local sv = TSCDataHub.savedVars
                if not sv then
                    return true
                end
                -- Disable if access code is missing
                local accessCode = sv.accessCode or ""
                if accessCode == "" then
                    return true
                end
                -- Disable if PIN is missing
                local pin = sv.pin or ""
                if pin == "" then
                    return true
                end
                local currentGuildId = GetGuildId(guildSlot)
                return TSCDataHub.isProcessing or TSCDataHub.capturedGuildsThisSession[currentGuildId]
            end,
            clickHandler = function()
                return CheckGuildAndCollect(guildSlot)
            end
        }
        settings:AddSetting(guildCaptureButton)
    end

    --[[
        URL SUBMISSION SECTION
    --]]
    local urlSubmissionSection = {
        type = LHAS.ST_SECTION,
        label = "URL Submission",
    }
    settings:AddSetting(urlSubmissionSection)

    local submitButton = {
        type = LHAS.ST_BUTTON,
        label = function()
            if not urlTable or not currentUrlIndex or not totalUrls then
                return "No URLs available"
            end
            if currentUrlIndex > totalUrls then
                return "All URLs submitted"
            end
            return string.format("Submit URL %d of %d", currentUrlIndex, totalUrls)
        end,
        tooltip = "Submit the next URL in the queue",
        buttonText = "Submit",
        disable = function()
            -- Disable if access code is missing
            local accessCode = savedVars and savedVars.accessCode or ""
            if accessCode == "" then
                return true
            end
            -- Disable if PIN is missing
            local pin = savedVars and savedVars.pin or ""
            if pin == "" then
                return true
            end
            -- Disable during processing
            if TSCDataHub.isProcessing then
                return true
            end
            if not urlTable or not currentUrlIndex or not totalUrls then
                return true
            end
            if currentUrlIndex > totalUrls then
                return true
            end
            return false
        end,
        clickHandler = function()
            TSCDataHub.submitNextURL()
        end,
    }
    settings:AddSetting(submitButton)
    -- Store references for updates (store the actual control objects)
    TSCDataHub.submitButton = submitButton

    --[[
        ADVANCED SECTION
    --]]
    local advancedSection = {
        type = LHAS.ST_SECTION,
        label = "Advanced",
    }
    settings:AddSetting(advancedSection)

    local clearTrackingButton = {
        type = LHAS.ST_BUTTON,
        label = "Clear Submission Tracking",
        tooltip = "Reset submission tracking for all guilds - makes all guilds appear as 'Ready to capture'",
        buttonText = "Clear Tracking",
        disable = function()
            -- Disable during processing
            return TSCDataHub.isProcessing
        end,
        clickHandler = function()
            clearAllSubmissionTracking()
            -- Refresh the status display after clearing
            if TSCDataHub.settings and TSCDataHub.settings.UpdateControls then
                TSCDataHub.settings:UpdateControls()
            end
        end,
    }
    settings:AddSetting(clearTrackingButton)
end

-- ============================================================================
-- INITIALIZATION FUNCTIONS
-- ============================================================================

local function initializeSavedVars()
    -- Initialize account-wide saved variables
    TSCDataHub.savedVars = ZO_SavedVars:NewAccountWide(
        "TSCDataHubData", SAVED_VARS_VERSION, nil, TSCDataHub.default)

    -- Set local reference for performance
    savedVars = TSCDataHub.savedVars

    -- Handle migration by adding any missing default fields
    -- Always ensure all default fields exist (not just on version change)
    for key, defaultValue in pairs(TSCDataHub.default) do
        if TSCDataHub.savedVars[key] == nil then
            TSCDataHub.savedVars[key] = defaultValue
        end
    end
    
    -- Update version if needed
    if TSCDataHub.savedVars.version ~= SAVED_VARS_VERSION then
        TSCDataHub.savedVars.version = SAVED_VARS_VERSION
    end
end

local function setServerPlatform()
    local SERVER_PLATFORM_MAPPING = {
        ["XB1live"] = 0, -- XBNA
        ["PS4live"] = 1, -- PSNA
        ["NA Megaserver"] = 2, -- PCNA
        ["XB1live-eu"] = 3, -- XBEU
        ["PS4live-eu"] = 4, -- PSEU
        ["EU Megaserver"] = 5, -- PCEU
        ["PTS"] = 6 -- PTS
    }
    
    local worldName = GetWorldName()
    SERVER_PLATFORM = SERVER_PLATFORM_MAPPING[worldName]
    
    if not SERVER_PLATFORM then
        CHAT_ROUTER:AddSystemMessage("[TSC] Unknown world name: " .. worldName .. " - defaulting to NA PC")
        SERVER_PLATFORM = 2 -- Default to NA PC
    end
end

local function initialize()
    if isInitialized then
        return
    end

    -- Initialize server platform once
    local accountName = normalizePlayerName(GetDisplayName())
    setServerPlatform()
    setupSettingsMenu()
    PLAYER_ACCOUNT_NAME = accountName

    -- SLASH_COMMANDS["/tscdhg1"] = function()
    --     CheckGuildAndCollect(1)
    -- end

    -- SLASH_COMMANDS["/tscdhg2"] = function()
    --     CheckGuildAndCollect(2)
    -- end

    -- SLASH_COMMANDS["/tscdhg3"] = function()
    --     CheckGuildAndCollect(3)
    -- end

    -- SLASH_COMMANDS["/tscdhg4"] = function()
    --     CheckGuildAndCollect(4)
    -- end

    -- SLASH_COMMANDS["/tscdhg5"] = function()
    --     CheckGuildAndCollect(5)
    -- end

    SLASH_COMMANDS["/tester"] = function()
        -- CHAT_ROUTER:AddSystemMessage("UI_PLATFORM_PC: " .. UI_PLATFORM_PC)
        -- CHAT_ROUTER:AddSystemMessage("UI_PLATFORM_PS4: " .. UI_PLATFORM_PS4)
        -- CHAT_ROUTER:AddSystemMessage("UI_PLATFORM_PS5: " .. UI_PLATFORM_PS5)
        -- CHAT_ROUTER:AddSystemMessage("UI_PLATFORM_REUSE_ME: " .. UI_PLATFORM_REUSE_ME)
        -- CHAT_ROUTER:AddSystemMessage("UI_PLATFORM_XBOX: " .. UI_PLATFORM_XBOX)
        CHAT_ROUTER:AddSystemMessage("PIN: " .. savedVars.pin)
        CHAT_ROUTER:AddSystemMessage("ACCESS_CODE: " .. savedVars.accessCode)
    end

    -- Cache Management Commands
    SLASH_COMMANDS["/tscstatus"] = function()
        CHAT_ROUTER:AddSystemMessage("[TSC] Guild Cache Status:")
        for i = 1, GetNumGuilds() do
            local guildId = GetGuildId(i)
            local guildName = GetGuildName(guildId)
            local numEvents = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_TRADER)
            CHAT_ROUTER:AddSystemMessage("  " .. i .. ". " .. guildName .. ": " .. numEvents .. " trader events")
        end
    end

    SLASH_COMMANDS["/tsccheck"] = function()
        CHAT_ROUTER:AddSystemMessage("[TSC] Cache check: This addon reads from the manually-scrolled guild history cache.")
        CHAT_ROUTER:AddSystemMessage("[TSC] Make sure you've manually scrolled through guild history in the UI to warm the cache.")
    end

    SLASH_COMMANDS["/tscguilds"] = function()
        CHAT_ROUTER:AddSystemMessage("[TSC] Your Guild Slots:")
        local numGuilds = GetNumGuilds()
        if numGuilds == 0 then
            CHAT_ROUTER:AddSystemMessage("  No guilds found")
            return
        end

        for i = 1, numGuilds do
            local guildId = GetGuildId(i)
            local guildName = GetGuildName(guildId)
            CHAT_ROUTER:AddSystemMessage("  Slot " .. i .. ": " .. guildName)
        end
    end

    SLASH_COMMANDS["/tscclear"] = function()
        CHAT_ROUTER:AddSystemMessage("[TSC] Clearing guild history cache for all guilds...")
        for i = 1, GetNumGuilds() do
            local guildId = GetGuildId(i)
            local guildName = GetGuildName(guildId)
            local result = ClearGuildHistoryCache(guildId)
            CHAT_ROUTER:AddSystemMessage("  " .. guildName .. ": " .. (result and "cleared" or "failed"))
        end
        CHAT_ROUTER:AddSystemMessage("[TSC] Cache clearing complete")
    end

    SLASH_COMMANDS["/tscdebug"] = function()
        CHAT_ROUTER:AddSystemMessage("[TSC] Debug Info:")
        CHAT_ROUTER:AddSystemMessage("  GetTimeStamp(): " .. GetTimeStamp())
        CHAT_ROUTER:AddSystemMessage("  Processing: " .. tostring(TSCDataHub.isProcessing))
        if TSCDataHub.processingGuildSlot then
            CHAT_ROUTER:AddSystemMessage("  Processing guild slot: " .. tostring(TSCDataHub.processingGuildSlot))
        end
    end

    isInitialized = true
end

-- ============================================================================
-- ADDON SETUP
-- ============================================================================

_G.TSCDataHub = TSCDataHub

-- Register events directly
EVENT_MANAGER:RegisterForEvent(TSCDataHub.name, EVENT_ADD_ON_LOADED, function(event, addonName)
    if addonName == TSCDataHub.name then
        -- Initialize saved variables first
        initializeSavedVars()

        -- Initialize the addon
        initialize()

        EVENT_MANAGER:UnregisterForEvent(TSCDataHub.name, EVENT_ADD_ON_LOADED)
    end
end)

EVENT_MANAGER:RegisterForEvent(TSCDataHub.name, EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(TSCDataHub.name, EVENT_PLAYER_ACTIVATED)
end)
