BlacklistSync = BlacklistSync or {}

-- ============================================================================
-- CONFIGURATION & CONSTANTS
-- ============================================================================

BlacklistSync.CONFIG = {
    NAME = "BlacklistSync",
    LONG_NAME = "Blacklist Sync - Guild Blacklist Manager",
    AUTHOR = "|c00c1ffZai|r|cffffffZah|r",
    VERSION = "1.3.0",
    SVAR_VERSION = 1,
}

BlacklistSync.DEFAULT_SETTINGS = {
    selectedGuildId = 1,
    confirmImports = true,
    ExportedBlacklists = {},
    ImportHistory = {},
}

BlacklistSync.BLACKLIST_ENTRY_DATA = 1

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

BlacklistSync.State = {
    SVAR = {},
    isInitialized = false,
    currentGuildId = nil,
    selectedPlayer = nil,
    Data = {
        CurrentExport = nil,
        ImportProgress = {
            total = 0,
            processed = 0,
            errors = 0,
            duplicates = 0,
            isRunning = false,
            startTime = 0,
            operation = "" -- "import" or "clear"
        }
    }
}

BlacklistSync.SPAM_PROTECTION = {
    MAX_OPERATIONS_PER_SECOND = 2,  -- Conservative limit
    BURST_ALLOWANCE = 5,             -- Allow small bursts
    COOLDOWN_AFTER_BURST = 3000,     -- 3 seconds cooldown after burst
    ADAPTIVE_DELAY_MIN = 1000,       -- Minimum delay
    ADAPTIVE_DELAY_MAX = 5000,       -- Maximum delay
}

BlacklistSync.SpamProtection = {
    operationCount = 0,
    lastOperationTime = 0,
    burstCount = 0,
    isInCooldown = false,
    adaptiveDelay = 1000,
}

BlacklistSync.EventTracking = {
    isTrackingImport = false,
    isTrackingClear = false,
    expectedResults = {},
    currentOperation = nil
}

-- ============================================================================
-- UI VARIABLES
-- ============================================================================

BlacklistSync.UI = {
    mainWindow = nil,
    playerList = nil,
    exportButton = nil,
    csvExportButton = nil,
    importButton = nil,
    refreshButton = nil,
    clearButton = nil,
    progressWindow = nil
}

local originalBlacklistFailedDialog = nil
local progressTimer = nil

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

function BlacklistSync.GetGuildById(guildId)
    for i = 1, GetNumGuilds() do
        local id = GetGuildId(i)
        if id == guildId then
            return id, GetGuildName(id)
        end
    end
    return nil
end

function BlacklistSync.IsPlayerBlacklisted(guildId, playerName)
    local numEntries = GetNumGuildBlacklistEntries(guildId)
    for i = 1, numEntries do
        local accountName, note = GetGuildBlacklistInfoAt(guildId, i)
        if accountName and accountName:lower() == playerName:lower() then
            return true, i, note
        end
    end
    return false, nil, nil
end

function BlacklistSync.RefreshPlayerList()
    if not BlacklistSync.State.currentGuildId or not BlacklistSync.UI.playerList then
        return
    end
    
    -- Clear existing data
    ZO_ScrollList_Clear(BlacklistSync.UI.playerList)
    
    local numEntries = GetNumGuildBlacklistEntries(BlacklistSync.State.currentGuildId)
    if numEntries > 0 then
        local scrollData = ZO_ScrollList_GetDataList(BlacklistSync.UI.playerList)
        
        for i = 1, numEntries do
            local accountName, note = GetGuildBlacklistInfoAt(BlacklistSync.State.currentGuildId, i)
            if accountName and accountName ~= "" then
                local data = {
                    name = accountName,
                    note = note or "",
                    index = i
                }
                local dataEntry = ZO_ScrollList_CreateDataEntry(BlacklistSync.BLACKLIST_ENTRY_DATA, data)
                table.insert(scrollData, dataEntry)
            end
        end
    end
    
    ZO_ScrollList_Commit(BlacklistSync.UI.playerList)
    
    -- Update status
    if BlacklistSync.UI.mainWindow and BlacklistSync.UI.mainWindow.statusLabel then
        local count = GetNumGuildBlacklistEntries(BlacklistSync.State.currentGuildId)
        BlacklistSync.UI.mainWindow.statusLabel:SetText(string.format("%d players", count))
    end
end

-- Suppress the default blacklist failed dialog to avoid spam
function BlacklistSync.SuppressBlacklistFailedDialog()
    if not originalBlacklistFailedDialog then
        originalBlacklistFailedDialog = ESO_Dialogs["GUILD_FINDER_BLACKLIST_FAILED"]
        ESO_Dialogs["GUILD_FINDER_BLACKLIST_FAILED"] = nil
    end
end

-- Restore the original blacklist failed dialog if it was suppressed
function BlacklistSync.RestoreBlacklistFailedDialog()
    if originalBlacklistFailedDialog then
        ESO_Dialogs["GUILD_FINDER_BLACKLIST_FAILED"] = originalBlacklistFailedDialog
        originalBlacklistFailedDialog = nil
    end
end

function BlacklistSync.GetAdaptiveDelay()
    local currentTime = GetGameTimeMilliseconds()
    local timeSinceLastOp = currentTime - BlacklistSync.SpamProtection.lastOperationTime
    
    -- Reset counters if enough time has passed
    if timeSinceLastOp > 5000 then
        BlacklistSync.SpamProtection.operationCount = 0
        BlacklistSync.SpamProtection.burstCount = 0
        BlacklistSync.SpamProtection.isInCooldown = false
        BlacklistSync.SpamProtection.adaptiveDelay = BlacklistSync.SPAM_PROTECTION.ADAPTIVE_DELAY_MIN
    end
    
    -- Check if we're doing too many operations too quickly
    if timeSinceLastOp < 1000 then
        BlacklistSync.SpamProtection.operationCount = BlacklistSync.SpamProtection.operationCount + 1
        BlacklistSync.SpamProtection.burstCount = BlacklistSync.SpamProtection.burstCount + 1
        
        -- If we're in a burst, increase delay
        if BlacklistSync.SpamProtection.burstCount > BlacklistSync.SPAM_PROTECTION.BURST_ALLOWANCE then
            BlacklistSync.SpamProtection.isInCooldown = true
            BlacklistSync.SpamProtection.adaptiveDelay = math.min(
                BlacklistSync.SpamProtection.adaptiveDelay * 1.5,
                BlacklistSync.SPAM_PROTECTION.ADAPTIVE_DELAY_MAX
            )
        end
    else
        -- Gradually reduce delay if operations are spaced out
        BlacklistSync.SpamProtection.burstCount = 0
        BlacklistSync.SpamProtection.adaptiveDelay = math.max(
            BlacklistSync.SpamProtection.adaptiveDelay * 0.9,
            BlacklistSync.SPAM_PROTECTION.ADAPTIVE_DELAY_MIN
        )
    end
    
    BlacklistSync.SpamProtection.lastOperationTime = currentTime
    
    if BlacklistSync.SpamProtection.isInCooldown then
        return BlacklistSync.SPAM_PROTECTION.COOLDOWN_AFTER_BURST
    else
        return BlacklistSync.SpamProtection.adaptiveDelay
    end
end

-- ============================================================================
-- PROGRESS WINDOW CREATION AND MANAGEMENT
-- ============================================================================

function BlacklistSync.CreateProgressWindow()
    if BlacklistSync.UI.progressWindow then
        return -- Already created
    end
    
    -- Create main window - make it taller to accommodate all content
    local window = WINDOW_MANAGER:CreateTopLevelWindow("BlacklistSyncProgressWindow")
    window:SetDimensions(450, 380)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)BG", window, "ZO_DefaultBackdrop")
    bg:SetAnchorFill(window)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", window, CT_LABEL)
    title:SetAnchor(TOP, window, TOP, 0, 15)
    title:SetFont("ZoFontWinH2")
    title:SetText("Processing...")
    title:SetColor(1, 1, 1, 1)
    
    -- Operation label
    local operationLabel = WINDOW_MANAGER:CreateControl("$(parent)OperationLabel", window, CT_LABEL)
    operationLabel:SetAnchor(TOP, title, BOTTOM, 0, 15)
    operationLabel:SetFont("ZoFontWinH4")
    operationLabel:SetText("Importing blacklist...")
    operationLabel:SetColor(0.9, 0.9, 0.9, 1)
    
    -- Progress bar background
    local progressBg = WINDOW_MANAGER:CreateControl("$(parent)ProgressBG", window, CT_BACKDROP)
    progressBg:SetAnchor(TOP, operationLabel, BOTTOM, 0, 20)
    progressBg:SetDimensions(380, 20)
    progressBg:SetCenterColor(0.2, 0.2, 0.2, 1)
    progressBg:SetEdgeColor(0.5, 0.5, 0.5, 1)
    progressBg:SetEdgeTexture("", 1, 1, 1)
    
    -- Progress bar fill
    local progressFill = WINDOW_MANAGER:CreateControl("$(parent)ProgressFill", window, CT_BACKDROP)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 2, 0)
    progressFill:SetDimensions(1, 16)
    progressFill:SetCenterColor(0.3, 0.7, 0.3, 1)
    
    -- Progress text
    local progressText = WINDOW_MANAGER:CreateControl("$(parent)ProgressText", window, CT_LABEL)
    progressText:SetAnchor(TOP, progressBg, BOTTOM, 0, 10)
    progressText:SetFont("ZoFontWinH5")
    progressText:SetText("0 / 0 (0%)")
    progressText:SetColor(1, 1, 1, 1)
    
    -- Status details
    local statusDetails = WINDOW_MANAGER:CreateControl("$(parent)StatusDetails", window, CT_LABEL)
    statusDetails:SetAnchor(TOP, progressText, BOTTOM, 0, 15)
    statusDetails:SetFont("ZoFontWinH5")
    statusDetails:SetText("• Added: 0\n• Skipped: 0\n• Errors: 0\n• Non-existent: 0")
    statusDetails:SetColor(0.9, 0.9, 0.9, 1)
    
    -- Time elapsed
    local timeLabel = WINDOW_MANAGER:CreateControl("$(parent)TimeLabel", window, CT_LABEL)
    timeLabel:SetAnchor(TOP, statusDetails, BOTTOM, 0, 15)
    timeLabel:SetFont("ZoFontWinH5")
    timeLabel:SetText("Time elapsed: 0s")
    timeLabel:SetColor(0.8, 0.8, 0.8, 1)
    
    -- Cancel button - positioned at bottom
    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)CancelButton", window, "ZO_DefaultButton")
    cancelButton:SetAnchor(BOTTOM, window, BOTTOM, 0, -15)
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetText("Cancel")
    cancelButton:SetHandler("OnClicked", function()
        BlacklistSync.CancelCurrentOperation()
    end)
    
    -- Current item being processed - positioned between time label and cancel button
    local currentItemLabel = WINDOW_MANAGER:CreateControl("$(parent)CurrentItemLabel", window, CT_LABEL)
    currentItemLabel:SetAnchor(TOP, timeLabel, BOTTOM, 0, 15)
    currentItemLabel:SetAnchor(BOTTOM, cancelButton, TOP, 0, -15)
    currentItemLabel:SetFont("ZoFontWinH5")
    currentItemLabel:SetText("Processing: ")
    currentItemLabel:SetColor(0.7, 0.7, 0.7, 1)
    currentItemLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    currentItemLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    
    -- Store references
    window.title = title
    window.operationLabel = operationLabel
    window.progressBg = progressBg
    window.progressFill = progressFill
    window.progressText = progressText
    window.statusDetails = statusDetails
    window.timeLabel = timeLabel
    window.currentItemLabel = currentItemLabel
    window.cancelButton = cancelButton
    
    BlacklistSync.UI.progressWindow = window
end

function BlacklistSync.ShowProgressWindow(operation, total, targetGuildName, sourceGuildName)
    BlacklistSync.CreateProgressWindow()
    
    local window = BlacklistSync.UI.progressWindow
    local operationText = operation == "import" and "Importing" or "Clearing"
    local detailText = operation == "import" 
        and string.format("Importing %d entries from '%s' to '%s'", total, sourceGuildName or "Unknown", targetGuildName or "Unknown")
        or string.format("Clearing %d entries from '%s'", total, targetGuildName or "Unknown")
    
    window.title:SetText(string.format("%s Blacklist", operationText))
    window.operationLabel:SetText(detailText)
    window.progressText:SetText(string.format("0 / %d (0%%)", total))
    window.progressFill:SetDimensions(1, 16) -- Start with width 1 instead of 0
    window.statusDetails:SetText("• Added: 0\n• Skipped: 0\n• Errors: 0\n• Non-existent: 0")
    window.timeLabel:SetText("Time elapsed: 0s")
    window.currentItemLabel:SetText("Processing: Starting...")
    
    -- Reset progress state
    BlacklistSync.State.Data.ImportProgress = {
        total = total,
        processed = 0,
        errors = 0,
        duplicates = 0,
        isRunning = true,
        startTime = GetGameTimeMilliseconds(),
        operation = operation,
        added = 0,
        skipped = 0,
        nonExistent = 0
    }
    
    window:SetHidden(false)
    
    -- Start the timer update
    BlacklistSync.StartProgressTimer()
end

function BlacklistSync.UpdateProgress(processed, added, skipped, errors, nonExistent, currentItem)
    if not BlacklistSync.UI.progressWindow or BlacklistSync.UI.progressWindow:IsHidden() then
        return
    end
    
    local window = BlacklistSync.UI.progressWindow
    local progress = BlacklistSync.State.Data.ImportProgress
    
    progress.processed = processed
    progress.added = added or progress.added
    progress.skipped = skipped or progress.skipped
    progress.errors = errors or progress.errors
    progress.nonExistent = nonExistent or progress.nonExistent
    
    -- Update progress bar
    local percentage = progress.total > 0 and (processed / progress.total) * 100 or 0
    local fillWidth = math.max(1, (376 * percentage) / 100) -- Ensure minimum width of 1
    window.progressFill:SetDimensions(fillWidth, 16)
    
    -- Update progress text
    window.progressText:SetText(string.format("%d / %d (%.1f%%)", processed, progress.total, percentage))
    
    -- Update status details
    if progress.operation == "import" then
        window.statusDetails:SetText(string.format("• Added: %d\n• Skipped: %d\n• Errors: %d\n• Non-existent: %d", 
            progress.added, progress.skipped, progress.errors, progress.nonExistent))
    else
        window.statusDetails:SetText(string.format("• Removed: %d\n• Errors: %d", 
            progress.added, progress.errors))
    end
    
    -- Update current item
    if currentItem then
        window.currentItemLabel:SetText(string.format("Processing: %s", currentItem))
    end
end

function BlacklistSync.HideProgressWindow()
    if BlacklistSync.UI.progressWindow then
        BlacklistSync.UI.progressWindow:SetHidden(true)
    end
    BlacklistSync.State.Data.ImportProgress.isRunning = false
    BlacklistSync.StopProgressTimer()
end

function BlacklistSync.StartProgressTimer()
    BlacklistSync.StopProgressTimer() -- Stop any existing timer
    
    progressTimer = zo_callLater(function()
        BlacklistSync.UpdateProgressTimer()
    end, 1000)
end

function BlacklistSync.StopProgressTimer()
    if progressTimer then
        progressTimer = nil
    end
end

function BlacklistSync.UpdateProgressTimer()
    if not BlacklistSync.State.Data.ImportProgress.isRunning then
        return
    end
    
    if BlacklistSync.UI.progressWindow and not BlacklistSync.UI.progressWindow:IsHidden() then
        local elapsed = GetGameTimeMilliseconds() - BlacklistSync.State.Data.ImportProgress.startTime
        local elapsedSeconds = math.floor(elapsed / 1000)
        BlacklistSync.UI.progressWindow.timeLabel:SetText(string.format("Time elapsed: %ds", elapsedSeconds))
        
        -- Schedule next update
        progressTimer = zo_callLater(function()
            BlacklistSync.UpdateProgressTimer()
        end, 1000)
    end
end

function BlacklistSync.CancelCurrentOperation()
    BlacklistSync.State.Data.ImportProgress.isRunning = false
    BlacklistSync.EventTracking.isTrackingImport = false
    BlacklistSync.EventTracking.isTrackingClear = false
    BlacklistSync.EventTracking.expectedResults = {}
    BlacklistSync.HideProgressWindow()
    BlacklistSync.RestoreBlacklistFailedDialog()
    CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Operation cancelled by user")
end

function BlacklistSync.OnGuildBlacklistResponse(eventCode, guildId, accountName, result)
    if not BlacklistSync.EventTracking.isTrackingImport and not BlacklistSync.EventTracking.isTrackingClear then
        return -- Not tracking any operation
    end
    
    if not BlacklistSync.State.Data.ImportProgress.isRunning then
        return -- Operation was cancelled
    end
    
    -- Find the expected result for this account
    local expectedEntry = nil
    for i, entry in ipairs(BlacklistSync.EventTracking.expectedResults) do
        if entry.accountName == accountName and not entry.processed then
            expectedEntry = entry
            entry.processed = true
            break
        end
    end
    
    if not expectedEntry then
        return -- Unexpected response
    end
    
    -- Update counters based on result
    local progress = BlacklistSync.State.Data.ImportProgress
    
    if BlacklistSync.EventTracking.isTrackingImport then
        if result == GUILD_BLACKLIST_RESPONSE_BLACKLIST_SUCCESSFULLY_ADDED then
            progress.added = progress.added + 1
        elseif result == GUILD_BLACKLIST_RESPONSE_PLAYER_NOT_FOUND then
            progress.nonExistent = progress.nonExistent + 1
        elseif result == GUILD_BLACKLIST_RESPONSE_ALREADY_BLACKLISTED then
            progress.skipped = progress.skipped + 1
        else
            progress.errors = progress.errors + 1
            -- Log specific error for debugging
            if result == GUILD_BLACKLIST_RESPONSE_BLACKLIST_FULL then
                CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Guild blacklist is full")
            elseif result == GUILD_BLACKLIST_RESPONSE_NO_BLACKLIST_PERMISSION then
                CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Lost blacklist permission during import")
            end
        end
    elseif BlacklistSync.EventTracking.isTrackingClear then
        if result == GUILD_BLACKLIST_RESPONSE_BLACKLIST_SUCCESSFULLY_REMOVED then
            progress.added = progress.added + 1 -- Using 'added' for 'removed' count
        else
            progress.errors = progress.errors + 1
        end
    end
    
    -- Update progress display
    BlacklistSync.UpdateProgress(progress.processed, progress.added, progress.skipped, progress.errors, progress.nonExistent, accountName)
end

-- ============================================================================
-- BLACKLIST MANAGER MODULE
-- ============================================================================

function BlacklistSync.ExportGuildBlacklist(guildId)
    if not guildId then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No guild ID provided")
        return nil
    end
    
    -- Check permissions
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No permission to manage blacklist for this guild")
        return nil
    end
    
    local guildName = GetGuildName(guildId)
    local numEntries = GetNumGuildBlacklistEntries(guildId)
    
    if numEntries == 0 then
        CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Guild '%s' has no blacklisted players", guildName))
        return nil
    end
    
    local exportData = {
        guildId = guildId,
        guildName = guildName,
        exportDate = GetTimeStamp(),
        exportedBy = GetDisplayName(),
        entries = {}
    }
    
    -- Collect all blacklist entries
    for i = 1, numEntries do
        local accountName, note = GetGuildBlacklistInfoAt(guildId, i)
        if accountName and accountName ~= "" then
            table.insert(exportData.entries, {
                accountName = accountName,
                note = note or "",
                originalIndex = i
            })
        end
    end
    
    -- Store in saved variables
    local exportKey = string.format("%s_%d", guildName, exportData.exportDate)
    BlacklistSync.State.SVAR.ExportedBlacklists[exportKey] = exportData
    BlacklistSync.State.Data.CurrentExport = exportData
    
    -- Show confirmation dialog
    ZO_Dialogs_ShowDialog("BLACKLISTSYNC_EXPORT_SUCCESS", {
        guildName = guildName,
        entryCount = #exportData.entries,
        exportDate = exportData.exportDate
    })
            
    return exportData
end

function BlacklistSync.GetAvailableExports()
    local exports = {}
    
    -- Get exports from current megaserver
    for key, data in pairs(BlacklistSync.State.SVAR.ExportedBlacklists) do
        table.insert(exports, {
            key = key,
            guildName = data.guildName,
            exportDate = data.exportDate,
            exportedBy = data.exportedBy,
            entryCount = #data.entries,
            megaserver = GetWorldName() -- Current megaserver
        })
    end
    
    -- Get exports from other megaservers
    local currentMegaserver = GetWorldName()
    local accountName = GetDisplayName()
    
    -- Access the full saved variables table
    if BlacklistSync_SV then
        for megaserver, accountData in pairs(BlacklistSync_SV) do
            if megaserver ~= currentMegaserver and accountData[accountName] and accountData[accountName]["$AccountWide"] then
                local otherMegaserverData = accountData[accountName]["$AccountWide"]
                if otherMegaserverData.ExportedBlacklists then
                    for key, data in pairs(otherMegaserverData.ExportedBlacklists) do
                        table.insert(exports, {
                            key = key,
                            guildName = data.guildName,
                            exportDate = data.exportDate,
                            exportedBy = data.exportedBy,
                            entryCount = #data.entries,
                            megaserver = megaserver -- Source megaserver
                        })
                    end
                end
            end
        end
    end
    
    -- Sort by export date (newest first)
    table.sort(exports, function(a, b) return a.exportDate > b.exportDate end)
    
    return exports
end

function BlacklistSync.ImportToGuild(targetGuildId, importKey, options)
    if not targetGuildId then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No target guild ID provided")
        return false
    end
    
    -- Check permissions
    if not DoesPlayerHaveGuildPermission(targetGuildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No permission to manage blacklist for target guild")
        return false
    end
    
    local importData = BlacklistSync.State.SVAR.ExportedBlacklists[importKey]
    
    -- If not found in current megaserver, search other megaservers
    if not importData and BlacklistSync_SV then
        local currentMegaserver = GetWorldName()
        local accountName = GetDisplayName()
        
        for megaserver, accountData in pairs(BlacklistSync_SV) do
            if megaserver ~= currentMegaserver and accountData[accountName] and accountData[accountName]["$AccountWide"] then
                local otherMegaserverData = accountData[accountName]["$AccountWide"]
                if otherMegaserverData.ExportedBlacklists and otherMegaserverData.ExportedBlacklists[importKey] then
                    importData = otherMegaserverData.ExportedBlacklists[importKey]
                    break
                end
            end
        end
    end
    
    if not importData then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: Export data not found")
        return false
    end
    
    local targetGuildName = GetGuildName(targetGuildId)
    
    -- Show progress window
    BlacklistSync.ShowProgressWindow("import", #importData.entries, targetGuildName, importData.guildName)
    
    -- Suppress the blacklist failed dialog during import
    BlacklistSync.SuppressBlacklistFailedDialog()
    
    -- Reset spam protection for this operation
    BlacklistSync.SpamProtection.operationCount = 0
    BlacklistSync.SpamProtection.burstCount = 0
    BlacklistSync.SpamProtection.isInCooldown = false
    
    -- Set up event tracking
    BlacklistSync.EventTracking.isTrackingImport = true
    BlacklistSync.EventTracking.isTrackingClear = false
    BlacklistSync.EventTracking.expectedResults = {}
    BlacklistSync.EventTracking.currentOperation = "import"
    
    -- Pre-populate expected results
    for _, entry in ipairs(importData.entries) do
        table.insert(BlacklistSync.EventTracking.expectedResults, {
            accountName = entry.accountName,
            processed = false
        })
    end
    
    local currentIndex = 1
    
    local function ProcessNextEntry()
        -- Check if operation was cancelled
        if not BlacklistSync.State.Data.ImportProgress.isRunning then
            BlacklistSync.EventTracking.isTrackingImport = false
            BlacklistSync.EventTracking.expectedResults = {}
            BlacklistSync.RestoreBlacklistFailedDialog()
            return
        end
        
        if currentIndex > #importData.entries then
            -- Import complete - wait a moment for final events to process
            zo_callLater(function()
                BlacklistSync.EventTracking.isTrackingImport = false
                BlacklistSync.EventTracking.expectedResults = {}
                BlacklistSync.HideProgressWindow()
                BlacklistSync.RestoreBlacklistFailedDialog()
                
                local progress = BlacklistSync.State.Data.ImportProgress
                ZO_Dialogs_ShowDialog("BLACKLISTSYNC_IMPORT_COMPLETE", {
                    targetGuildName = targetGuildName,
                    importCount = progress.added,
                    skipCount = progress.skipped,
                    errorCount = progress.errors,
                    nonExistentCount = progress.nonExistent,
                    sourceGuildName = importData.guildName
                })
                BlacklistSync.RefreshPlayerList()
            end, 1000)
            return
        end
        
        local entry = importData.entries[currentIndex]
        
        -- Update progress with current item being processed
        local progress = BlacklistSync.State.Data.ImportProgress
        progress.processed = currentIndex
        BlacklistSync.UpdateProgress(currentIndex, progress.added, progress.skipped, progress.errors, progress.nonExistent, entry.accountName)
        
        -- Check if player already blacklisted (skip event tracking for these)
        local isBlacklisted, index, existingNote = BlacklistSync.IsPlayerBlacklisted(targetGuildId, entry.accountName)
        
        if isBlacklisted then
            progress.skipped = progress.skipped + 1
            -- Mark as processed in event tracking
            for _, expectedEntry in ipairs(BlacklistSync.EventTracking.expectedResults) do
                if expectedEntry.accountName == entry.accountName then
                    expectedEntry.processed = true
                    break
                end
            end
        elseif not entry.accountName or entry.accountName == "" then
            progress.errors = progress.errors + 1
            -- Mark as processed in event tracking
            for _, expectedEntry in ipairs(BlacklistSync.EventTracking.expectedResults) do
                if expectedEntry.accountName == entry.accountName then
                    expectedEntry.processed = true
                    break
                end
            end
        else
            -- Attempt to add to blacklist - event handler will process the result
            AddToGuildBlacklistByDisplayName(targetGuildId, entry.accountName, entry.note)
        end
        
        currentIndex = currentIndex + 1
        
        -- Calculate adaptive delay for next operation
        local delay = BlacklistSync.GetAdaptiveDelay()
        
        -- Schedule next entry
        zo_callLater(ProcessNextEntry, delay)
    end
    
    CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Import to '%s' started (%d entries)", 
        targetGuildName, #importData.entries))
    
    -- Start processing
    ProcessNextEntry()
    
    return true
end

function BlacklistSync.ShowImportDialog()
    local exports = BlacklistSync.GetAvailableExports()
    if #exports == 0 then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "No exported blacklists available")
        return
    end
    
    local dialogData = {
        exports = exports,
        targetGuildId = BlacklistSync.State.currentGuildId
    }
    
    ZO_Dialogs_ShowDialog("BLACKLISTSYNC_IMPORT_DIALOG", dialogData)
end

-- ============================================================================
-- BLACKLIST CLEARING FUNCTIONS
-- ============================================================================

function BlacklistSync.ClearGuildBlacklistWithDelay(guildId)
    if not guildId then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No guild ID provided")
        return false
    end
    
    -- Check permissions
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No permission to manage blacklist for this guild")
        return false
    end
    
    local guildName = GetGuildName(guildId)
    local numEntries = GetNumGuildBlacklistEntries(guildId)
    
    if numEntries == 0 then
        CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Guild '%s' blacklist is already empty", guildName))
        return true
    end
    
    -- Create a list of entries to remove (from highest index to lowest to avoid index shifting)
    local entriesToRemove = {}
    for i = numEntries, 1, -1 do
        local accountName, note = GetGuildBlacklistInfoAt(guildId, i)
        if accountName and accountName ~= "" then
            table.insert(entriesToRemove, {
                index = i,
                accountName = accountName,
                note = note or ""
            })
        end
    end
    
    -- Show progress window
    BlacklistSync.ShowProgressWindow("clear", #entriesToRemove, guildName)
    
    -- Reset spam protection for this operation
    BlacklistSync.SpamProtection.operationCount = 0
    BlacklistSync.SpamProtection.burstCount = 0
    BlacklistSync.SpamProtection.isInCooldown = false
    
    -- Set up event tracking
    BlacklistSync.EventTracking.isTrackingClear = true
    BlacklistSync.EventTracking.isTrackingImport = false
    BlacklistSync.EventTracking.expectedResults = {}
    BlacklistSync.EventTracking.currentOperation = "clear"
    
    -- Pre-populate expected results
    for _, entry in ipairs(entriesToRemove) do
        table.insert(BlacklistSync.EventTracking.expectedResults, {
            accountName = entry.accountName,
            processed = false
        })
    end
    
    local currentIndex = 1
    
    local function ProcessNextRemoval()
        -- Check if operation was cancelled
        if not BlacklistSync.State.Data.ImportProgress.isRunning then
            BlacklistSync.EventTracking.isTrackingClear = false
            BlacklistSync.EventTracking.expectedResults = {}
            return
        end
        
        if currentIndex > #entriesToRemove then
            -- Clear complete - wait a moment for final events to process
            zo_callLater(function()
                BlacklistSync.EventTracking.isTrackingClear = false
                BlacklistSync.EventTracking.expectedResults = {}
                BlacklistSync.HideProgressWindow()
                
                local progress = BlacklistSync.State.Data.ImportProgress
                if progress.errors > 0 then
                    CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Cleared %d entries from '%s' (%d errors)", 
                        progress.added, guildName, progress.errors))
                else
                    CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Successfully cleared %d entries from '%s'", 
                        progress.added, guildName))
                end
                BlacklistSync.RefreshPlayerList()
            end, 1000)
            return
        end
        
        local entry = entriesToRemove[currentIndex]
        
        -- Update progress with current item
        local progress = BlacklistSync.State.Data.ImportProgress
        progress.processed = currentIndex
        BlacklistSync.UpdateProgress(currentIndex, progress.added, 0, progress.errors, 0, entry.accountName)
        
        -- Find the current index of this entry (since indices may have shifted)
        local currentNumEntries = GetNumGuildBlacklistEntries(guildId)
        local foundIndex = nil
        
        for i = 1, currentNumEntries do
            local accountName, note = GetGuildBlacklistInfoAt(guildId, i)
            if accountName == entry.accountName then
                foundIndex = i
                break
            end
        end
        
        if foundIndex then
            -- Remove from blacklist - event handler will process the result
            RemoveFromGuildBlacklist(guildId, foundIndex)
        else
            -- Entry not found (might have been removed already)
            progress.errors = progress.errors + 1
            -- Mark as processed in event tracking
            for _, expectedEntry in ipairs(BlacklistSync.EventTracking.expectedResults) do
                if expectedEntry.accountName == entry.accountName then
                    expectedEntry.processed = true
                    break
                end
            end
        end
        
        currentIndex = currentIndex + 1
        
        -- Calculate adaptive delay for next operation
        local delay = BlacklistSync.GetAdaptiveDelay()
        
        -- Schedule next removal
        zo_callLater(ProcessNextRemoval, delay)
    end
    
    CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Starting to clear %d entries from '%s'", 
        #entriesToRemove, guildName))
    
    -- Start processing
    ProcessNextRemoval()
    
    return true
end

-- ============================================================================
-- SCROLL LIST FUNCTIONS
-- ============================================================================

function BlacklistSync.SetupBlacklistRow(control, data)
    local nameLabel = GetControl(control, "Name")
    local noteLabel = GetControl(control, "Note")
    
    if nameLabel then
        nameLabel:SetText(data.name)
        nameLabel:SetColor(1, 1, 1, 1)
    end
    
    if noteLabel then
        local noteText = data.note or ""
        if string.len(noteText) > 50 then
            noteText = string.sub(noteText, 1, 47) .. "..."
        end
        noteLabel:SetText(noteText)
        noteLabel:SetColor(0.8, 0.8, 0.8, 1)
    end
end

function BlacklistSync.BlacklistRow_OnMouseEnter(control)
    if BlacklistSync.UI.playerList then
        ZO_ScrollList_MouseEnter(BlacklistSync.UI.playerList, control)
    end
end

function BlacklistSync.BlacklistRow_OnMouseExit(control)
    if BlacklistSync.UI.playerList then
        ZO_ScrollList_MouseExit(BlacklistSync.UI.playerList, control)
    end
end

function BlacklistSync.BlacklistRow_OnMouseUp(control, button, upInside)
    if BlacklistSync.UI.playerList then
        ZO_ScrollList_MouseClick(BlacklistSync.UI.playerList, control)
        
        -- Handle right-click context menu
        if button == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            local data = ZO_ScrollList_GetData(control)
            if data then
                BlacklistSync.ShowBlacklistContextMenu(control, data)
            end
        end
    end
end

function BlacklistSync.ShowBlacklistContextMenu(control, data)
    ClearMenu()
    
    AddMenuItem("View Full Note", function()
        ZO_Dialogs_ShowDialog("BLACKLISTSYNC_VIEW_NOTE", {
            playerName = data.name,
            note = data.note or "No note"
        })
    end)
    
    ShowMenu(control)
end

-- ============================================================================
-- UI CREATION FUNCTIONS
-- ============================================================================

function BlacklistSync.CreateButtons()
    local mainWindow = BlacklistSync.UI.mainWindow
    
    -- JSON Export button
    BlacklistSync.UI.exportButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)ExportButton", mainWindow, "ZO_DefaultButton")
    BlacklistSync.UI.exportButton:SetAnchor(BOTTOMLEFT, mainWindow, BOTTOMLEFT, 20, -20)
    BlacklistSync.UI.exportButton:SetDimensions(90, 30)
    BlacklistSync.UI.exportButton:SetText("Export")
    BlacklistSync.UI.exportButton:SetHandler("OnClicked", function()
        if BlacklistSync.State.currentGuildId then
            BlacklistSync.ExportGuildBlacklist(BlacklistSync.State.currentGuildId)
        end
    end)
    
    -- CSV Export button
    BlacklistSync.UI.csvExportButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)CSVExportButton", mainWindow, "ZO_DefaultButton")
    BlacklistSync.UI.csvExportButton:SetAnchor(TOPLEFT, BlacklistSync.UI.exportButton, TOPRIGHT, 5, 0)
    BlacklistSync.UI.csvExportButton:SetDimensions(90, 30)
    BlacklistSync.UI.csvExportButton:SetText("Export CSV")
    BlacklistSync.UI.csvExportButton:SetHandler("OnClicked", function()
        if BlacklistSync.State.currentGuildId then
            BlacklistSync.ExportGuildBlacklistCSV(BlacklistSync.State.currentGuildId)
        end
    end)
    
    BlacklistSync.UI.importButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)ImportButton", mainWindow, "ZO_DefaultButton")
    BlacklistSync.UI.importButton:SetAnchor(TOPLEFT, BlacklistSync.UI.csvExportButton, TOPRIGHT, 10, 0)
    BlacklistSync.UI.importButton:SetDimensions(100, 30)
    BlacklistSync.UI.importButton:SetText("Import")
    BlacklistSync.UI.importButton:SetHandler("OnClicked", function()
        BlacklistSync.ShowImportDialog()
    end)
    
    BlacklistSync.UI.refreshButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)RefreshButton", mainWindow, "ZO_DefaultButton")
    BlacklistSync.UI.refreshButton:SetAnchor(TOPLEFT, BlacklistSync.UI.importButton, TOPRIGHT, 10, 0)
    BlacklistSync.UI.refreshButton:SetDimensions(100, 30)
    BlacklistSync.UI.refreshButton:SetText("Refresh")
    BlacklistSync.UI.refreshButton:SetHandler("OnClicked", function()
        BlacklistSync.RefreshPlayerList()
    end)
    
    BlacklistSync.UI.clearButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)ClearButton", mainWindow, "ZO_DefaultButton")
    BlacklistSync.UI.clearButton:SetAnchor(TOPLEFT, BlacklistSync.UI.refreshButton, TOPRIGHT, 10, 0)
    BlacklistSync.UI.clearButton:SetDimensions(130, 30)
    BlacklistSync.UI.clearButton:SetText("Clear Blacklist")
    BlacklistSync.UI.clearButton:SetHandler("OnClicked", function()
        ZO_Dialogs_ShowDialog("BLACKLISTSYNC_CLEAR_BLACKLIST")
    end)
end

function BlacklistSync.InitializeGuildDropdown(guildDropdown)
    local comboBox = ZO_ComboBox_ObjectFromContainer(guildDropdown)
    comboBox:ClearItems()
    
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local hasPermission = DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST)
        
        if hasPermission then
            local entry = comboBox:CreateItemEntry(guildName, function()
                BlacklistSync.State.currentGuildId = guildId
                BlacklistSync.State.SVAR.selectedGuildId = i
                BlacklistSync.RefreshPlayerList()
            end)
            comboBox:AddItem(entry)
        end
    end
    
    -- Set default selection
    if GetNumGuilds() > 0 then
        local defaultIndex = BlacklistSync.State.SVAR.selectedGuildId or 1
        if defaultIndex <= GetNumGuilds() then
            local guildId = GetGuildId(defaultIndex)
            if DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
                BlacklistSync.State.currentGuildId = guildId
                local guildName = GetGuildName(guildId)
                comboBox:SetSelectedItem(guildName)
            end
        end
    end
end

function BlacklistSync.CreateMainWindow()
    BlacklistSync.UI.mainWindow = WINDOW_MANAGER:CreateTopLevelWindow("BlacklistSyncMainWindow")
    BlacklistSync.UI.mainWindow:SetDimensions(700, 500)
    BlacklistSync.UI.mainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 256, 182)
    BlacklistSync.UI.mainWindow:SetMovable(true)
    BlacklistSync.UI.mainWindow:SetMouseEnabled(true)
    BlacklistSync.UI.mainWindow:SetClampedToScreen(true)
    BlacklistSync.UI.mainWindow:SetHidden(true)
    BlacklistSync.UI.mainWindow:SetDrawTier(DT_MEDIUM)
    
    local mainWindow = BlacklistSync.UI.mainWindow
    
    -- Background
    local bg = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)BG", mainWindow, "ZO_DefaultBackdrop")
    bg:SetAnchorFill(mainWindow)
    
    -- Title
    local title = WINDOW_MANAGER:CreateControl("$(parent)Title", mainWindow, CT_LABEL)
    title:SetAnchor(TOP, mainWindow, TOP, 0, 15)
    title:SetFont("ZoFontWinH2")
    title:SetText("Blacklist Sync - Guild Blacklist Manager")
    title:SetColor(1, 1, 1, 1)
    
    -- Close button
    local closeButton = WINDOW_MANAGER:CreateControl("$(parent)CloseButton", mainWindow, CT_BUTTON)
    closeButton:SetDimensions(32, 32)
    closeButton:SetAnchor(TOPRIGHT, mainWindow, TOPRIGHT, -10, 10)
    closeButton:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
    closeButton:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
    closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
    closeButton:SetHandler("OnClicked", function()
        mainWindow:SetHidden(true)
    end)
    
    -- Guild selection dropdown
    local guildLabel = WINDOW_MANAGER:CreateControl("$(parent)GuildLabel", mainWindow, CT_LABEL)
    guildLabel:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 20, 55)
    guildLabel:SetFont("ZoFontWinH4")
    guildLabel:SetText("Select Guild:")
    guildLabel:SetColor(1, 1, 1, 1)
    
    local guildDropdown = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)GuildDropdown", mainWindow, "ZO_ComboBox")
    guildDropdown:SetAnchor(TOPLEFT, guildLabel, TOPRIGHT, 10, -5)
    guildDropdown:SetDimensions(200, 30)
    
    -- Status label
    local statusLabel = WINDOW_MANAGER:CreateControl("$(parent)StatusLabel", mainWindow, CT_LABEL)
    statusLabel:SetAnchor(TOPRIGHT, mainWindow, TOPRIGHT, -20, 60)
    statusLabel:SetFont("ZoFontWinH5")
    statusLabel:SetText("0 players")
    statusLabel:SetColor(0.8, 0.8, 0.8, 1)
    
    -- Blacklist section label
    local listLabel = WINDOW_MANAGER:CreateControl("$(parent)ListLabel", mainWindow, CT_LABEL)
    listLabel:SetAnchor(TOPLEFT, guildLabel, BOTTOMLEFT, 0, 30)
    listLabel:SetFont("ZoFontWinH4")
    listLabel:SetText("Blacklisted Players:")
    listLabel:SetColor(1, 1, 1, 1)
    
    -- Column headers
    local headerBg = WINDOW_MANAGER:CreateControl("$(parent)HeaderBG", mainWindow, CT_BACKDROP)
    headerBg:SetAnchor(TOPLEFT, listLabel, BOTTOMLEFT, 0, 10)
    headerBg:SetDimensions(660, 25)
    headerBg:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    headerBg:SetEdgeColor(0.3, 0.3, 0.3, 1)
    headerBg:SetEdgeTexture("", 1, 1, 1)
    
    -- Column header text
    local nameHeader = WINDOW_MANAGER:CreateControl("$(parent)NameHeader", mainWindow, CT_LABEL)
    nameHeader:SetAnchor(LEFT, headerBg, LEFT, 10, 0)
    nameHeader:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    nameHeader:SetFont("ZoFontWinH5")
    nameHeader:SetText("Player Name")
    nameHeader:SetColor(1, 1, 1, 1)
    nameHeader:SetDimensions(180, 25)
    
    local noteHeader = WINDOW_MANAGER:CreateControl("$(parent)NoteHeader", mainWindow, CT_LABEL)
    noteHeader:SetAnchor(LEFT, headerBg, LEFT, 200, 0)
    noteHeader:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    noteHeader:SetFont("ZoFontWinH5")
    noteHeader:SetText("Note")
    noteHeader:SetColor(1, 1, 1, 1)
    noteHeader:SetDimensions(450, 25)
    
    -- Create scroll list
    BlacklistSync.UI.playerList = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)PlayerList", mainWindow, "ZO_ScrollList")
    BlacklistSync.UI.playerList:SetAnchor(TOPLEFT, headerBg, BOTTOMLEFT, 0, 15)
    BlacklistSync.UI.playerList:SetDimensions(660, 265)
    
    -- Initialize scroll list
    ZO_ScrollList_Initialize(BlacklistSync.UI.playerList)
    ZO_ScrollList_AddDataType(BlacklistSync.UI.playerList, BlacklistSync.BLACKLIST_ENTRY_DATA, "BlacklistSync_BlacklistRow", 28, 
        function(control, data) BlacklistSync.SetupBlacklistRow(control, data) end)
    ZO_ScrollList_EnableHighlight(BlacklistSync.UI.playerList, "ZO_ThinListHighlight")
    ZO_ScrollList_EnableSelection(BlacklistSync.UI.playerList, "ZO_ThinListHighlight", function(previouslySelectedData, selectedData) 
        BlacklistSync.State.selectedPlayer = selectedData
    end)
    
    -- Create buttons
    BlacklistSync.CreateButtons()
    
    -- Store status label reference
    mainWindow.statusLabel = statusLabel
    
    -- Initialize guild dropdown
    BlacklistSync.InitializeGuildDropdown(guildDropdown)
end

function BlacklistSync.ShowMainWindow()
    if BlacklistSync.UI.mainWindow then
        BlacklistSync.UI.mainWindow:SetHidden(false)
        
        -- Update the guild dropdown to match current guild if set via keybind
        if BlacklistSync.State.currentGuildId then
            local guildDropdown = GetControl(BlacklistSync.UI.mainWindow, "GuildDropdown")
            if guildDropdown then
                local comboBox = ZO_ComboBox_ObjectFromContainer(guildDropdown)
                local guildName = GetGuildName(BlacklistSync.State.currentGuildId)
                if guildName then
                    comboBox:SetSelectedItem(guildName)
                end
            end
        end
        BlacklistSync.RefreshPlayerList()
    end
end

-- ============================================================================
-- CSV EXPORT FUNCTIONS
-- ============================================================================

function BlacklistSync.ExportGuildBlacklistCSV(guildId)
    if not guildId then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No guild ID provided")
        return nil
    end
    
    -- Check permissions
    if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST) then
        CHAT_ROUTER:AddSystemMessage("[BlacklistSync] Error: No permission to manage blacklist for this guild")
        return nil
    end
    
    local guildName = GetGuildName(guildId)
    local numEntries = GetNumGuildBlacklistEntries(guildId)
    
    if numEntries == 0 then
        CHAT_ROUTER:AddSystemMessage(string.format("[BlacklistSync] Guild '%s' has no blacklisted players", guildName))
        return nil
    end
    
    local exportData = {
        guildId = guildId,
        guildName = guildName,
        exportDate = GetTimeStamp(),
        exportedBy = GetDisplayName(),
        entries = {}
    }
    
    -- Collect all blacklist entries
    for i = 1, numEntries do
        local accountName, note = GetGuildBlacklistInfoAt(guildId, i)
        if accountName and accountName ~= "" then
            table.insert(exportData.entries, {
                accountName = accountName,
                note = note or "",
                originalIndex = i
            })
        end
    end
    
    -- Generate CSV content directly
    local csvContent = BlacklistSync.GenerateCSVFormat(exportData)
    
    -- Show the copy window with CSV content only
    BlacklistSync.ShowCopyWindow(csvContent, "CSV Export - Copy to clipboard")
    
    return exportData
end

function BlacklistSync.GenerateCSVFormat(exportData)
    local lines = {}
    
    -- Add header information
    table.insert(lines, "# Blacklist Export - " .. (exportData.guildName or "Unknown Guild"))
    table.insert(lines, "# Generated: " .. os.date("%Y-%m-%d %H:%M:%S", exportData.exportDate))
    table.insert(lines, "# Exported By: " .. (exportData.exportedBy or "Unknown"))
    table.insert(lines, "# Total Entries: " .. #exportData.entries)
    table.insert(lines, "#")
    
    -- CSV header
    table.insert(lines, "Account Name,Note,Original Index")
    
    -- Add data rows
    for _, entry in ipairs(exportData.entries) do
        local row = string.format('"%s","%s",%d',
            entry.accountName:gsub('"', '""'), -- Escape quotes in CSV
            (entry.note or ""):gsub('"', '""'), -- Escape quotes in CSV
            entry.originalIndex)
        table.insert(lines, row)
    end
    
    return table.concat(lines, "\n")
end

function BlacklistSync.ShowCopyWindow(text, title)
    -- Create the window if it doesn't exist yet
    if not BlacklistSync.UI.copyWindow then
        -- Create main window
        local window = WINDOW_MANAGER:CreateTopLevelWindow("BlacklistSyncCopyWindow")
        window:SetDimensions(600, 450)
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        window:SetMovable(true)
        window:SetMouseEnabled(true)
        window:SetClampedToScreen(true)
        window:SetHidden(true)
        window:SetDrawTier(DT_HIGH)
        
        -- Background
        local bg = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)BG", window, "ZO_DefaultBackdrop")
        bg:SetAnchorFill(window)
        
        -- Title
        local titleLabel = WINDOW_MANAGER:CreateControl("$(parent)Title", window, CT_LABEL)
        titleLabel:SetAnchor(TOP, window, TOP, 0, 15)
        titleLabel:SetFont("ZoFontWinH3")
        titleLabel:SetColor(1, 1, 1, 1)
        
        -- Close button
        local closeButton = WINDOW_MANAGER:CreateControl("$(parent)CloseButton", window, CT_BUTTON)
        closeButton:SetDimensions(32, 32)
        closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 10)
        closeButton:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
        closeButton:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
        closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
        closeButton:SetHandler("OnClicked", function()
            window:SetHidden(true)
        end)
        
        -- Instructions
        local instructions = WINDOW_MANAGER:CreateControl("$(parent)Instructions", window, CT_LABEL)
        instructions:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 50)
        instructions:SetFont("ZoFontWinH5")
        instructions:SetText("Press Ctrl+A to select all, then Ctrl+C to copy")
        instructions:SetColor(0.8, 0.8, 0.8, 1)
        
        -- Create edit box for text
        local editBox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)EditBox", window, "ZO_DefaultEditMultiLineForBackdrop")
        editBox:SetAnchor(TOPLEFT, instructions, BOTTOMLEFT, 0, 15)
        editBox:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -20, -80)
        editBox:SetEditEnabled(false)
        editBox:SetMaxInputChars(50000)
        
        -- Button container
        local buttonContainer = WINDOW_MANAGER:CreateControl("$(parent)ButtonContainer", window, CT_CONTROL)
        buttonContainer:SetAnchor(BOTTOM, window, BOTTOM, 0, -15)
        buttonContainer:SetDimensions(560, 40)
        
        -- Close button
        local closeBottomButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)CloseBottomButton", buttonContainer, "ZO_DefaultButton")
        closeBottomButton:SetAnchor(RIGHT, buttonContainer, RIGHT, 0, 0)
        closeBottomButton:SetDimensions(100, 30)
        closeBottomButton:SetText("Close")
        closeBottomButton:SetHandler("OnClicked", function()
            window:SetHidden(true)
        end)
        
        -- Create "Select All" button
        local selectAllButton = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)SelectAllButton", buttonContainer, "ZO_DefaultButton")
        selectAllButton:SetAnchor(RIGHT, closeBottomButton, LEFT, -10, 0)
        selectAllButton:SetDimensions(120, 30)
        selectAllButton:SetText("Select All")
        selectAllButton:SetHandler("OnClicked", function()
            editBox:SelectAll()
            editBox:TakeFocus()
        end)
        
        -- Store references
        window.titleLabel = titleLabel
        window.editBox = editBox
        window.instructions = instructions
        
        BlacklistSync.UI.copyWindow = window
    end
    
    local window = BlacklistSync.UI.copyWindow
    
    -- Update window content
    window.titleLabel:SetText(title or "Copy Text")
    window.editBox:SetText(text)
    
    window:SetHidden(false)
    
    -- Focus the edit box and select all text automatically
    window.editBox:TakeFocus()
    zo_callLater(function()
        window.editBox:SelectAll()
    end, 100)
end

-- ============================================================================
-- DIALOG REGISTRATIONS
-- ============================================================================

function BlacklistSync.RegisterDialogs()
    -- Export success confirmation dialog
    ZO_Dialogs_RegisterCustomDialog("BLACKLISTSYNC_EXPORT_SUCCESS", {
        title = {
            text = "Export Complete"
        },
        mainText = {
            text = function(dialog)
                local data = dialog.data
                return string.format("Successfully exported %d blacklist entries from '%s'.\n\nExported on: %s", 
                    data.entryCount, 
                    data.guildName, 
                    ZO_FormatClockTime(data.exportDate))
            end
        },
        buttons = {
            {
                text = "OK",
                keybind = "UI_SHORTCUT_PRIMARY"
            }
        }
    })

    -- Updated import completion dialog
    ZO_Dialogs_RegisterCustomDialog("BLACKLISTSYNC_IMPORT_COMPLETE", {
        title = {
            text = "Import Complete"
        },
        mainText = {
            text = function(dialog)
                local data = dialog.data
                local message = string.format("Import to '%s' completed:\n\n• Added: %d players\n• Skipped: %d players (already blacklisted)\n• Errors: %d players", 
                    data.targetGuildName, 
                    data.importCount, 
                    data.skipCount, 
                    data.errorCount)
                
                if data.nonExistentCount and data.nonExistentCount > 0 then
                    message = message .. string.format("\n• Non-existent users: %d players (cross-megaserver)", data.nonExistentCount)
                end
                
                return message
            end
        },
        buttons = {
            {
                text = "OK",
                keybind = "UI_SHORTCUT_PRIMARY"
            }
        }
    })

    -- View note dialog
    ZO_Dialogs_RegisterCustomDialog("BLACKLISTSYNC_VIEW_NOTE", {
        title = {
            text = function(dialog)
                return string.format("Note for %s", dialog.data.playerName)
            end
        },
        mainText = {
            text = function(dialog)
                return dialog.data.note
            end
        },
        buttons = {
            {
                text = "OK",
                keybind = "UI_SHORTCUT_PRIMARY"
            }
        }
    })

    -- Clear blacklist confirmation dialog
    ZO_Dialogs_RegisterCustomDialog("BLACKLISTSYNC_CLEAR_BLACKLIST", {
        title = {
            text = "Clear Blacklist"
        },
        mainText = {
            text = function()
                local guildName = BlacklistSync.State.currentGuildId and GetGuildName(BlacklistSync.State.currentGuildId) or "Unknown"
                return string.format("Are you sure you want to clear all blacklist entries from '%s'?\n\nThis action cannot be undone.", guildName)
            end
        },
        buttons = {
            {
                text = "Clear All",
                callback = function()
                    if BlacklistSync.State.currentGuildId then
                        BlacklistSync.ClearGuildBlacklistWithDelay(BlacklistSync.State.currentGuildId)
                    end
                end
            },
            {
                text = "Cancel",
                keybind = "UI_SHORTCUT_NEGATIVE"
            }
        }
    })

    -- Dialog for import selection
    ZO_Dialogs_RegisterCustomDialog("BLACKLISTSYNC_IMPORT_DIALOG", {
        title = {
            text = "Select Import"
        },
        mainText = {
            text = function(dialog)
                local data = dialog.data
                local targetGuildName = GetGuildName(data.targetGuildId)
                local text = string.format("Select which blacklist to import to '%s':\n\n", targetGuildName)
                
                for i, export in ipairs(data.exports) do
                    local megaserverText = export.megaserver and export.megaserver ~= GetWorldName() 
                        and string.format(" (%s)", export.megaserver) or ""
                    text = text .. string.format("%d. %s (%d entries) - %s%s\n", 
                        i, export.guildName, export.entryCount, ZO_FormatClockTime(export.exportDate), megaserverText)
                end
                
                return text
            end
        },
        editBox = {
            defaultText = "1",
            maxInputCharacters = 2,
            textType = TEXT_TYPE_NUMERIC
        },
        buttons = {
            {
                text = "Import",
                callback = function(dialog)
                    local data = dialog.data
                    local input = ZO_Dialogs_GetEditBoxText(dialog)
                    local index = tonumber(input)
                    
                    if index and index > 0 and index <= #data.exports then
                        local exportKey = data.exports[index].key
                        BlacklistSync.ImportToGuild(data.targetGuildId, exportKey)
                    else
                        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Invalid selection")
                    end
                end,
                keybind = "UI_SHORTCUT_PRIMARY"
            },
            {
                text = "Cancel",
                keybind = "UI_SHORTCUT_NEGATIVE"
            }
        }
    })

    -- Clear exports confirmation dialog
    ZO_Dialogs_RegisterCustomDialog("BLACKLISTSYNC_CLEAR_EXPORTS", {
        title = {
            text = "Clear All Exports"
        },
        mainText = {
            text = "Are you sure you want to delete all stored blacklist exports?\n\nThis action cannot be undone."
        },
        buttons = {
            {
                text = "Clear All",
                callback = function()
                    BlacklistSync.State.SVAR.ExportedBlacklists = {}
                    CHAT_ROUTER:AddSystemMessage("[BlacklistSync] All exports cleared")
                end
            },
            {
                text = "Cancel",
                keybind = "UI_SHORTCUT_NEGATIVE"
            }
        }
    })
end

-- ============================================================================
-- KEYBIND INTEGRATION
-- ============================================================================

function BlacklistSync.RegisterGuildKeybinds()
    local guildKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = "Open Blacklist Sync",
            keybind = "UI_SHORTCUT_SECONDARY",
            callback = function()
                -- Ensure we have the current guild context when opened via keybind
                if GUILD_RECRUITMENT_BLACKLIST_KEYBOARD and GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId then
                    BlacklistSync.State.currentGuildId = GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId
                end
                
                BlacklistSync.ShowMainWindow()
            end,
            enabled = function()
                local guildId = nil
                if GUILD_RECRUITMENT_BLACKLIST_KEYBOARD and GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId then
                    guildId = GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId
                end
                return guildId ~= nil
            end,
            visible = function()
                local guildId = nil
                if GUILD_RECRUITMENT_BLACKLIST_KEYBOARD and GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId then
                    guildId = GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId
                end
                return guildId ~= nil and DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_MANAGE_BLACKLIST)
            end,
        },
    }

    -- Hook into guild blacklist showing/hiding using ZO_PostHook
    if GUILD_RECRUITMENT_BLACKLIST_KEYBOARD then
        ZO_PostHook(GUILD_RECRUITMENT_BLACKLIST_KEYBOARD, "OnShowing", function()
            if GUILD_RECRUITMENT_BLACKLIST_KEYBOARD and GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId then
                BlacklistSync.State.currentGuildId = GUILD_RECRUITMENT_BLACKLIST_KEYBOARD.guildId
                KEYBIND_STRIP:AddKeybindButtonGroup(guildKeybindDescriptor)
            end
        end)
        
        ZO_PostHook(GUILD_RECRUITMENT_BLACKLIST_KEYBOARD, "OnHidden", function()
            KEYBIND_STRIP:RemoveKeybindButtonGroup(guildKeybindDescriptor)
        end)
    end
end

-- ============================================================================
-- SETTINGS MENU
-- ============================================================================

function BlacklistSync.CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = BlacklistSync.CONFIG.LONG_NAME,
        displayName = BlacklistSync.CONFIG.LONG_NAME,
        author = BlacklistSync.CONFIG.AUTHOR,
        version = BlacklistSync.CONFIG.VERSION,
        slashCommand = "/blacklistsync",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    local optionsTable = {
        {
            type = "header",
            name = "General Settings",
        },
        {
            type = "checkbox",
            name = "Confirm Imports",
            tooltip = "Show confirmation dialog before importing blacklists",
            getFunc = function() return BlacklistSync.State.SVAR.confirmImports end,
            setFunc = function(value) BlacklistSync.State.SVAR.confirmImports = value end,
            default = true,
        },
        {
            type = "button",
            name = "Open Blacklist Manager",
            tooltip = "Open the main blacklist management window",
            func = function()
                BlacklistSync.ShowMainWindow()
            end,
        },
        {
            type = "header",
            name = "Export Management",
        },
        {
            type = "button",
            name = "Clear All Exports",
            tooltip = "Delete all stored blacklist exports",
            func = function()
                ZO_Dialogs_ShowDialog("BLACKLISTSYNC_CLEAR_EXPORTS")
            end,
        },
    }
    
    LibAddonMenu2:RegisterAddonPanel("BlacklistSyncOptions", panelData)
    LibAddonMenu2:RegisterOptionControls("BlacklistSyncOptions", optionsTable)
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function BlacklistSync.Initialize()
    BlacklistSync.State.SVAR = ZO_SavedVars:NewAccountWide("BlacklistSync_SV", BlacklistSync.CONFIG.SVAR_VERSION, nil, BlacklistSync.DEFAULT_SETTINGS, GetWorldName())
    
    -- Create UI
    BlacklistSync.CreateMainWindow()
    BlacklistSync.RegisterDialogs()
    
    -- Register guild keybinds and settings menu
    BlacklistSync.RegisterGuildKeybinds()
    BlacklistSync.CreateSettingsMenu()
    
    -- Register the event handler
    EVENT_MANAGER:RegisterForEvent(BlacklistSync.CONFIG.NAME .. "_BlacklistResponse", EVENT_GUILD_FINDER_BLACKLIST_RESPONSE, BlacklistSync.OnGuildBlacklistResponse)


    BlacklistSync.State.isInitialized = true
    return true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= BlacklistSync.CONFIG.NAME then return end
    EVENT_MANAGER:UnregisterForEvent(BlacklistSync.CONFIG.NAME, EVENT_ADD_ON_LOADED)
    BlacklistSync.Initialize()
end

EVENT_MANAGER:RegisterForEvent(BlacklistSync.CONFIG.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)