-- Night Market Adventure Zone IDs
-- Note: Night Market has multiple zone IDs for different areas
local NIGHT_MARKET_ZONE_IDS = {
    1559,  -- Night Market (main zone)
    -- Add additional sub-zone IDs here if needed
}

-- Check if player is in the Night Market Adventure Zone
local function IsInNightMarketZone()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local zoneName = GetZoneNameById(zoneId)
    
    -- Check if zone ID matches any known Night Market zones
    for _, nmZoneId in ipairs(NIGHT_MARKET_ZONE_IDS) do
        if zoneId == nmZoneId then
            return true
        end
    end
    
    -- Also check by zone name (fallback)
    if zoneName and (string.find(zoneName:lower(), "night market") or 
                     string.find(zoneName:lower(), "parch") or
                     string.find(zoneName:lower(), "skittering") or
                     string.find(zoneName:lower(), "sorrow")) then
        return true
    end
    
    return false
end

NightMarketKeys = {}
NightMarketKeys.name = "NightMarketKeys"
NightMarketKeys.version = "1.0.4"

-- Key tracking
local ARGENT_KEYS = 6
local GILDED_KEYS = 3

-- Boss names for display (ordered by zone: Parch, Skittering, Sorrow's)
local ARGENT_NAMES = {
    "Ash Titan", "Ozezan", "Flesh Abom.", "Nassulekh", "Kovan", "Molonach"
}

local GILDED_NAMES = {
    "B'Kyfxi", "Alziriix", "Fateline"
}

-- Saved variables
local savedVars = nil

-- UI row tracking tables
local receivedRows = {}
local shareListRows = {}
local blockedRows = {}

-- Initialize the addon
function NightMarketKeys:Initialize()
    -- Load saved variables
    savedVars = ZO_SavedVars:NewAccountWide("NightMarketKeysData", 4, nil, {
        myKeys = {
            argent = {},
            gilded = {}
        },
        receivedKeys = {},  -- {displayName: {argent, gilded, timestamp}}
        shareList = {},  -- {displayName: lastSharedBitstring} - players to auto-share with, tracking what was sent
        lastSharedBitstring = "",  -- Track last overall key state
        blockedPlayers = {}  -- {displayName: true} - players whose keys we don't want to receive
    })
    
    -- Register for addon messages (P2P whisper sharing)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ADD_ON_MESSAGE_RECEIVED, function(...)
        self:OnAddonMessage(...)
    end)
    
    -- Register slash command
    SLASH_COMMANDS["/nmki"] = function(args)
        self:HandleCommand(args)
    end
    
    -- Register for player activated to show load message
    EVENT_MANAGER:RegisterForEvent(self.name .. "Activated", EVENT_PLAYER_ACTIVATED, function()
        d(string.format("|cFFD700Night Market Keys|r v%s loaded. Type |cFFFFFF/nmki|r to share your keys!", self.version))
        EVENT_MANAGER:UnregisterForEvent(self.name .. "Activated", EVENT_PLAYER_ACTIVATED)
    end)
end

-- Handle addon messages
function NightMarketKeys:OnAddonMessage(eventCode, messageType, senderDisplayName, message)
    if messageType == "NMKIKeys" then
        -- Check if sender is blocked
        if savedVars.blockedPlayers[senderDisplayName] then
            -- Silently ignore keys from blocked players
            return
        end
        
        -- Format: bitstring (9 digits)
        if message and #message == 9 and string.match(message, "^%d+$") then
            self:ParseBitstring(senderDisplayName, message)
            d(string.format("|c00FF00Received keys from %s|r", senderDisplayName))
        end
    end
end

-- Parse bitstring format
function NightMarketKeys:ParseBitstring(playerName, bitstring)
    local argent = {}
    local gilded = {}
    
    for i = 1, ARGENT_KEYS do
        if string.sub(bitstring, i, i) == "1" then
            argent[i] = true
        end
    end
    
    for i = 1, GILDED_KEYS do
        if string.sub(bitstring, ARGENT_KEYS + i, ARGENT_KEYS + i) == "1" then
            gilded[i] = true
        end
    end
    
    savedVars.receivedKeys[playerName] = {
        argent = argent,
        gilded = gilded,
        timestamp = GetTimeStamp()
    }
end

-- Convert keys to bitstring
function NightMarketKeys:KeysToBitstring(keys)
    local bits = ""
    for i = 1, ARGENT_KEYS do
        bits = bits .. (keys.argent[i] and "1" or "0")
    end
    for i = 1, GILDED_KEYS do
        bits = bits .. (keys.gilded[i] and "1" or "0")
    end
    return bits
end

-- Validate if a player exists (check friends, guilds, group, or recently shared)
function NightMarketKeys:ValidatePlayerName(playerName)
    -- Always valid if it's yourself
    local myDisplayName = GetDisplayName()
    if playerName == myDisplayName then
        return true, "yourself"
    end
    
    -- Check if we've received keys from this player
    if savedVars.receivedKeys[playerName] then
        return true, "received keys from"
    end
    
    -- Check friends list
    for i = 1, GetNumFriends() do
        local displayName = GetFriendInfo(i)
        if displayName == playerName then
            return true, "friend"
        end
    end
    
    -- Check all guilds
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if guildId > 0 then
            local numMembers = GetNumGuildMembers(guildId)
            for memberIndex = 1, numMembers do
                local displayName = GetGuildMemberInfo(guildId, memberIndex)
                if displayName == playerName then
                    return true, "guild member"
                end
            end
        end
    end
    
    -- Check current group
    if IsUnitGrouped("player") then
        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            if unitTag then
                local displayName = GetUnitDisplayName(unitTag)
                if displayName == playerName then
                    return true, "group member"
                end
            end
        end
    end
    
    -- Player not found, but might still be valid (could be offline friend, etc.)
    return false, "unknown"
end

-- Check if player has trial key
function NightMarketKeys:HasTrialKey(keys)
    for i = 1, GILDED_KEYS do
        if not keys.gilded[i] then
            return false
        end
    end
    return true
end

-- Use Adventure Zone Boss Tree API to set keys automatically
function NightMarketKeys:UseTreeData(silent)
    -- Check if player is in the Night Market zone first
    -- If not in zone, don't update keys (prevents clearing keys when outside zone)
    if not IsInNightMarketZone() then
        if not silent then
            d("|cFF6600Not in Night Market zone - keys not refreshed.|r")
        end
        return
    end
    
    local bossMap = {
        [ADVENTURE_ZONE_BOSS_PARCH_WORLD_BOSS_1] = {type = "argent", num = 1},
        [ADVENTURE_ZONE_BOSS_PARCH_WORLD_BOSS_2] = {type = "argent", num = 2},
        [ADVENTURE_ZONE_BOSS_SKITTERING_WORLD_BOSS_1] = {type = "argent", num = 3},
        [ADVENTURE_ZONE_BOSS_SKITTERING_WORLD_BOSS_2] = {type = "argent", num = 4},
        [ADVENTURE_ZONE_BOSS_SORROWS_FRIEND_WORLD_BOSS_1] = {type = "argent", num = 5},
        [ADVENTURE_ZONE_BOSS_SORROWS_FRIEND_WORLD_BOSS_2] = {type = "argent", num = 6},
        [ADVENTURE_ZONE_BOSS_PARCH_INSTANCE_BOSS] = {type = "gilded", num = 1},
        [ADVENTURE_ZONE_BOSS_SKITTERING_INSTANCE_BOSS] = {type = "gilded", num = 2},
        [ADVENTURE_ZONE_BOSS_SORROWS_FRIEND_INSTANCE_BOSS] = {type = "gilded", num = 3},
    }
    
    -- Only clear and rebuild keys if we're in the zone
    savedVars.myKeys = {argent = {}, gilded = {}}
    local keyCount = 0
    
    -- Guard against missing constants
    if not ADVENTURE_ZONE_BOSS_ITERATION_BEGIN or not ADVENTURE_ZONE_BOSS_ITERATION_END then
        if not silent then
            d("|cFF0000Adventure Zone Boss constants not available.|r")
        end
        return
    end
    
    for boss = ADVENTURE_ZONE_BOSS_ITERATION_BEGIN, ADVENTURE_ZONE_BOSS_ITERATION_END do
        local bossState = GetAdventureZoneBossState(boss)
        local keyInfo = bossMap[boss]
        if keyInfo and bossState == ADVENTURE_ZONE_BOSS_STATE_DEFEATED then
            if keyInfo.type == "argent" then
                savedVars.myKeys.argent[keyInfo.num] = true
            elseif keyInfo.type == "gilded" then
                savedVars.myKeys.gilded[keyInfo.num] = true
            end
            keyCount = keyCount + 1
        end
    end
    if not silent then
        d(string.format("|c00FF00Loaded %d key(s) from Boss Tree API.|r", keyCount))
    end
    
    -- Check if keys changed and auto-share with share list
    self:AutoShareWithShareList()
end

-- Auto-share with share list if keys changed for each player
function NightMarketKeys:AutoShareWithShareList()
    local currentBitstring = self:KeysToBitstring(savedVars.myKeys)
    local sharedCount = 0
    
    -- Check each player on share list individually
    for playerName, lastSharedBitstring in pairs(savedVars.shareList) do
        -- Only share if keys changed since last share with this specific player
        if currentBitstring ~= lastSharedBitstring then
            if self:ShareKeys(playerName, true) then  -- true = silent mode
                -- Update the last shared state for this player
                savedVars.shareList[playerName] = currentBitstring
                sharedCount = sharedCount + 1
            end
        end
    end
    
    if sharedCount > 0 then
        d(string.format("|c00FF00Auto-shared updated keys with %d player(s) on share list|r", sharedCount))
    end
    
    -- Update global last shared state
    savedVars.lastSharedBitstring = currentBitstring
end

-- Add player to share list
function NightMarketKeys:AddToShareList(playerName)
    -- Validate player name format
    if not string.match(playerName, "^@") then
        playerName = "@" .. playerName
    end
    
    -- Validate player exists
    local isValid, relationship = self:ValidatePlayerName(playerName)
    if not isValid then
        d("|cFF0000Player not found. Must be a friend, guild member, group member, or someone who has shared with you.|r")
        return false
    end
    
    -- Get current key state
    local currentBitstring = self:KeysToBitstring(savedVars.myKeys)
    
    -- Add to share list with current state
    savedVars.shareList[playerName] = currentBitstring
    d(string.format("|c00FF00Added %s to share list (%s)|r", playerName, relationship))
    
    -- Share immediately when added
    if self:ShareKeys(playerName, false) then
        -- Already tracked in shareList
    end
    
    return true
end

-- Remove player from share list
function NightMarketKeys:RemoveFromShareList(playerName)
    if savedVars.shareList[playerName] then
        savedVars.shareList[playerName] = nil
        d(string.format("|c00FF00Removed %s from share list|r", playerName))
        return true
    end
    return false
end

-- Clear received keys
function NightMarketKeys:ClearReceivedKeys()
    savedVars.receivedKeys = {}
    d("|c00FF00All received keys cleared.|r")
end

-- Remove a specific player's keys
function NightMarketKeys:RemovePlayer(playerName)
    if savedVars.receivedKeys[playerName] then
        savedVars.receivedKeys[playerName] = nil
        d(string.format("|c00FF00Removed %s from received keys.|r", playerName))
    else
        d(string.format("|cFF0000%s not found in received keys.|r", playerName))
    end
end

-- Block a player (prevent receiving their keys)
function NightMarketKeys:BlockPlayer(playerName)
    if savedVars.blockedPlayers[playerName] then
        d(string.format("|cFF6600%s is already blocked.|r", playerName))
        return false
    end
    
    savedVars.blockedPlayers[playerName] = true
    
    -- Also remove any existing received keys from this player
    if savedVars.receivedKeys[playerName] then
        savedVars.receivedKeys[playerName] = nil
    end
    
    d(string.format("|c00FF00Blocked %s. You will no longer receive their keys.|r", playerName))
    return true
end

-- Unblock a player (allow receiving their keys again)
function NightMarketKeys:UnblockPlayer(playerName)
    if not savedVars.blockedPlayers[playerName] then
        d(string.format("|cFF6600%s is not blocked.|r", playerName))
        return false
    end
    
    savedVars.blockedPlayers[playerName] = nil
    d(string.format("|c00FF00Unblocked %s. You can receive their keys again.|r", playerName))
    return true
end

-- Share keys with a player
function NightMarketKeys:ShareKeys(targetPlayer, silent)
    -- Validate player name format
    if not targetPlayer or targetPlayer == "" then
        if not silent then
            d("|cFF0000Please enter a player name.|r")
        end
        return false
    end
    
    -- Add @ if not present
    if not string.match(targetPlayer, "^@") then
        targetPlayer = "@" .. targetPlayer
    end
    
    -- Validate player exists
    local isValid, relationship = self:ValidatePlayerName(targetPlayer)
    
    local bitstring = self:KeysToBitstring(savedVars.myKeys)
    local myDisplayName = GetDisplayName()
    
    -- Special case: sharing with yourself (for testing)
    if targetPlayer == myDisplayName then
        -- Directly call the parse function to simulate receiving
        self:ParseBitstring(myDisplayName, bitstring)
        if not silent then
            d(string.format("|c00FF00Keys shared with yourself (test mode)|r"))
        end
        return true
    end
    
    -- Warn if player not found, but still try to send
    if not isValid then
        if not silent then
            d(string.format("|cFFFF00Warning: %s not found in friends/guilds. Will try to send anyway...|r", targetPlayer))
        end
    elseif not silent then
        d(string.format("|c00FF00Validated: %s (%s)|r", targetPlayer, relationship))
    end
    
    -- Send via whisper addon message
    local sent = pcall(function()
        SendChatMessage(bitstring, CHAT_CHANNEL_WHISPER, nil, targetPlayer, "NMKIKeys")
    end)
    
    if sent then
        if not silent then
            d(string.format("|c00FF00Keys shared with %s (if online and has addon)|r", targetPlayer))
        end
        return true
    else
        if not silent then
            d(string.format("|cFF0000Failed to share with %s (player may be offline)|r", targetPlayer))
        end
        return false
    end
end

-- Show help
function NightMarketKeys:ShowHelp()
    d("|cFFD700=== Night Market Keys - Help ===|r")
    d(" ")
    d("|cFFFFFF/nmki|r - Open main window (auto-detects keys)")
    d("|cFFFFFF/nmki share|r - Manage share list (auto-share)")
    d("|cFFFFFF/nmki list|r - Show received keys window")
    d("|cFFFFFF/nmki zone|r - Show current zone info (debug)")
    d("|cFFFFFF/nmki help|r - Show this help")
    d(" ")
    d("|c00FF00Note:|r Keys auto-shared with share list when they change")
end

-- Show current zone information (debug)
function NightMarketKeys:ShowZoneInfo()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    local zoneName = GetZoneNameById(zoneId)
    local isInNM = IsInNightMarketZone()
    
    d("|cFFD700=== Zone Information ===|r")
    d(string.format("Zone ID: |cFFFFFF%d|r", zoneId))
    d(string.format("Zone Name: |cFFFFFF%s|r", zoneName or "Unknown"))
    d(string.format("In Night Market: |c%sFFFF%s|r", isInNM and "00FF00" or "FF0000", tostring(isInNM)))
    d(" ")
    d("|cCCCCCCIf this is the Night Market zone, please report the Zone ID!|r")
end

-- Main command handler
function NightMarketKeys:HandleCommand(args)
    args = args:gsub("^%s+", ""):gsub("%s+$", "")
    
    if args == "" or args == "show" then
        self:ShowShareWindow()  -- Open main window
    elseif args == "watch" then
        self:ShowShareListWindow()  -- Open share list window
    elseif args == "list" or args == "received" then
        self:ShowReceivedWindow()  -- Open received keys window
    elseif args == "zone" then
        self:ShowZoneInfo()  -- Show zone debug info
    elseif args == "help" then
        self:ShowHelp()
    else
        -- Unknown command, just open the main window
        self:ShowShareWindow()
    end
end

--==================================================
-- UI FUNCTIONS
--==================================================

-- Initialize UI windows
function NightMarketKeys:InitializeUI()
    -- Set version label in footer
    local versionLabel = NightMarketKeysShareWindowFooterVersion
    if versionLabel then
        versionLabel:SetText("v" .. self.version)
    end
    
    -- Share window close button
    NightMarketKeysShareWindowTitleBarClose:SetHandler("OnClicked", function()
        NightMarketKeysShareWindow:SetHidden(true)
    end)
    
    -- Watch list window close button
    NightMarketKeysShareListWindowTitleBarClose:SetHandler("OnClicked", function()
        NightMarketKeysShareListWindow:SetHidden(true)
    end)
    
    -- Received window close button
    NightMarketKeysReceivedWindowTitleBarClose:SetHandler("OnClicked", function()
        NightMarketKeysReceivedWindow:SetHidden(true)
    end)
    
    -- Block list window close button
    NightMarketKeysBlockListWindowTitleBarClose:SetHandler("OnClicked", function()
        NightMarketKeysBlockListWindow:SetHidden(true)
    end)
    
    -- Manage Share List button handler
    NightMarketKeysShareWindowActionSectionShareListButton:SetHandler("OnClicked", function()
        self:ShowShareListWindow()
    end)
    
    -- View Received button handler
    NightMarketKeysShareWindowActionSectionViewButton:SetHandler("OnClicked", function()
        self:ShowReceivedWindow()
    end)
    
    -- Block List button handler
    NightMarketKeysReceivedWindowFooterBlockListButton:SetHandler("OnClicked", function()
        self:ShowBlockListWindow()
    end)
    
    -- Share List - Add button handler
    NightMarketKeysShareListWindowAddSectionAddButton:SetHandler("OnClicked", function()
        self:OnAddToShareListClicked()
    end)
    
    -- Share List - Input box enter key handler
    NightMarketKeysShareListWindowAddSectionInput:SetHandler("OnEnter", function(editBox)
        self:OnAddToShareListClicked()
    end)
    
    -- Set up autocomplete for share list input box
    local shareListInput = NightMarketKeysShareListWindowAddSectionInput
    if shareListInput and AUTO_COMPLETION then
        AUTO_COMPLETION:Register(shareListInput, AUTO_COMPLETION_ONLINE_OR_OFFLINE)
    end
    
    -- Clear All button handler with confirmation
    NightMarketKeysReceivedWindowFooterClearAllButton:SetHandler("OnClicked", function()
        ZO_Dialogs_ShowDialog("NMKI_CONFIRM_CLEAR_ALL")
    end)
end

-- Register confirmation dialogs
ESO_Dialogs["NMKI_CONFIRM_CLEAR_ALL"] = {
    title = {
        text = "Clear All Received Keys"
    },
    mainText = {
        text = "Are you sure you want to delete all received keys? This cannot be undone."
    },
    buttons = {
        {
            text = SI_DIALOG_YES,
            callback = function()
                NightMarketKeys:OnClearAllButtonClicked()
            end
        },
        {
            text = SI_DIALOG_NO
        }
    }
}

-- Show the main share window
function NightMarketKeys:ShowShareWindow()
    -- Auto-detect keys from Boss Tree whenever window is opened
    self:UseTreeData(true)  -- Silent mode (no chat spam)
    
    -- Check if we have any keys stored
    local hasAnyKeys = false
    for i = 1, ARGENT_KEYS do
        if savedVars.myKeys.argent[i] then
            hasAnyKeys = true
            break
        end
    end
    if not hasAnyKeys then
        for i = 1, GILDED_KEYS do
            if savedVars.myKeys.gilded[i] then
                hasAnyKeys = true
                break
            end
        end
    end
    
    -- If not in zone and no keys stored, show error and don't open window
    if not IsInNightMarketZone() and not hasAnyKeys then
        d("|cFF0000No key data available. Please travel to the Night Market zone to detect your keys.|r")
        return
    end
    
    -- Update display with latest keys
    self:UpdateShareWindowDisplay()
    
    NightMarketKeysShareWindow:SetHidden(false)
    NightMarketKeysReceivedWindow:SetHidden(true)
    NightMarketKeysShareListWindow:SetHidden(true)
end

-- Show the received keys window
function NightMarketKeys:ShowReceivedWindow()
    self:UpdateReceivedWindowDisplay()
    NightMarketKeysReceivedWindow:SetHidden(false)
end

-- Update the share window display with current keys
function NightMarketKeys:UpdateShareWindowDisplay()
    local myKeys = savedVars.myKeys
    
    -- Update argent keys display
    for i = 1, ARGENT_KEYS do
        local label = _G["NightMarketKeysShareWindowKeysSectionArgent" .. i]
        if label then
            local hasKey = myKeys.argent[i] or false
            local checkmark = hasKey and "|c00FF00[X]|r" or "[ ]"
            local bossName = ARGENT_NAMES[i] or "Boss " .. i
            label:SetText(checkmark .. " " .. bossName)
        end
    end
    
    -- Update gilded keys display
    for i = 1, GILDED_KEYS do
        local label = _G["NightMarketKeysShareWindowKeysSectionGilded" .. i]
        if label then
            local hasKey = myKeys.gilded[i] or false
            local checkmark = hasKey and "|c00FF00[X]|r" or "[ ]"
            local bossName = GILDED_NAMES[i] or "Boss G" .. i
            label:SetText(checkmark .. " " .. bossName .. " (Gilded)")
        end
    end
    
    -- Update trial status
    local gildedCount = 0
    for i = 1, GILDED_KEYS do
        if myKeys.gilded[i] then gildedCount = gildedCount + 1 end
    end
    local statusLabel = NightMarketKeysShareWindowKeysSectionTrialStatus
    if gildedCount == GILDED_KEYS then
        statusLabel:SetText("|c00FF00Opulent Ordeal: Ready!|r")
    else
        statusLabel:SetText("|cFF6600Opulent Ordeal: " .. gildedCount .. "/3 gilded keys|r")
    end
end

-- Update the received keys window display
function NightMarketKeys:UpdateReceivedWindowDisplay()
    local scrollChild = NightMarketKeysReceivedWindowListContainerScroll
    
    -- Clear existing rows
    for _, row in pairs(receivedRows) do
        if row then
            row:SetHidden(true)
        end
    end
    
    -- Count received keys
    local count = 0
    for _ in pairs(savedVars.receivedKeys) do
        count = count + 1
    end
    
    -- Update footer info
    local footerInfo = NightMarketKeysReceivedWindowFooterInfo
    if count == 0 then
        footerInfo:SetText("|cCCCCCCNo received keys|r")
    elseif count == 1 then
        footerInfo:SetText("|cCCCCCC1 received key|r")
    else
        footerInfo:SetText("|cCCCCCC" .. count .. " received keys|r")
    end
    
    -- If no keys, show message in scroll area
    if count == 0 then
        -- Could add a "no data" message here if desired
        return
    end
    
    -- Sort by timestamp (most recent first)
    local sortedPlayers = {}
    for playerName, data in pairs(savedVars.receivedKeys) do
        table.insert(sortedPlayers, {name = playerName, timestamp = data.timestamp or 0})
    end
    table.sort(sortedPlayers, function(a, b) return a.timestamp > b.timestamp end)
    
    -- Create rows for each player
    local yOffset = 0
    for idx, playerData in ipairs(sortedPlayers) do
        local playerName = playerData.name
        local data = savedVars.receivedKeys[playerName]
        
        -- Create or reuse row control
        local rowName = "NMKIReceivedRow" .. idx
        local row = receivedRows[idx]
        
        if not row then
            row = CreateControlFromVirtual(rowName, scrollChild, "NMKIReceivedRowTemplate")
            receivedRows[idx] = row
        end
        
        if row then
            row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
            row:SetHidden(false)
            
            -- Player name
            local nameLabel = row:GetNamedChild("Name")
            if nameLabel then
                nameLabel:SetText(playerName)
            end
            
            -- Keys display with bracketed boss initials
            local keysText = ""
            
            -- Argent keys - Parch (Red brackets)
            -- Ash Titan & Ozezan
            keysText = keysText .. "|cEE4444[|r"
            keysText = keysText .. (data.argent[1] and "|cEE4444A|r" or "|cFFFFFFa|r")
            keysText = keysText .. "  "
            keysText = keysText .. (data.argent[2] and "|cEE4444O|r" or "|cFFFFFFo|r")
            keysText = keysText .. "|cEE4444]|r  "
            
            -- Argent keys - Skittering (Green brackets)
            -- Flesh Abom & Nassulekh
            keysText = keysText .. "|c00FF00[|r"
            keysText = keysText .. (data.argent[3] and "|c00FF00F|r" or "|cFFFFFFf|r")
            keysText = keysText .. "  "
            keysText = keysText .. (data.argent[4] and "|c00FF00N|r" or "|cFFFFFFn|r")
            keysText = keysText .. "|c00FF00]|r  "
            
            -- Argent keys - Sorrow's (Blue brackets)
            -- Kovan & Molonach
            keysText = keysText .. "|c4169E1[|r"
            keysText = keysText .. (data.argent[5] and "|c4169E1K|r" or "|cFFFFFFk|r")
            keysText = keysText .. "  "
            keysText = keysText .. (data.argent[6] and "|c4169E1M|r" or "|cFFFFFFm|r")
            keysText = keysText .. "|c4169E1]|r  "
            
            -- Gilded keys - Parch (Red brackets)
            -- B'Kyfxi
            keysText = keysText .. "|cEE4444[|r"
            keysText = keysText .. (data.gilded[1] and "|cEE4444GB|r" or "|cFFFFFFgb|r")
            keysText = keysText .. "|cEE4444]|r  "
            
            -- Gilded keys - Skittering (Green brackets)
            -- Alziriix
            keysText = keysText .. "|c00FF00[|r"
            keysText = keysText .. (data.gilded[2] and "|c00FF00GA|r" or "|cFFFFFFga|r")
            keysText = keysText .. "|c00FF00]|r  "
            
            -- Gilded keys - Sorrow's (Blue brackets)
            -- Fateline
            keysText = keysText .. "|c4169E1[|r"
            keysText = keysText .. (data.gilded[3] and "|c4169E1GF|r" or "|cFFFFFFgf|r")
            keysText = keysText .. "|c4169E1]|r"
            
            local keysLabel = row:GetNamedChild("Keys")
            if keysLabel then
                keysLabel:SetText(keysText)
                -- Set monospace font with custom size
                keysLabel:SetFont("ZoFontGameFixed|16|soft-shadow-thin")
            end
            
            -- Block button
            local blockBtn = row:GetNamedChild("Block")
            if blockBtn then
                blockBtn:SetHandler("OnClicked", function()
                    self:BlockPlayer(playerName)
                    self:UpdateReceivedWindowDisplay()
                end)
            end
            
            -- Delete button
            local deleteBtn = row:GetNamedChild("Delete")
            if deleteBtn then
                deleteBtn:SetHandler("OnClicked", function()
                    self:RemovePlayer(playerName)
                    self:UpdateReceivedWindowDisplay()
                end)
            end
            
            yOffset = yOffset + 30  -- Row height
        end
    end
end

-- Show the share list window
function NightMarketKeys:ShowShareListWindow()
    self:UpdateShareListDisplay()
    NightMarketKeysShareListWindow:SetHidden(false)
end

-- Update the share list display
function NightMarketKeys:UpdateShareListDisplay()
    local scrollChild = NightMarketKeysShareListWindowListContainerScrollContainer
    if not scrollChild then return end
    
    -- Clear existing rows
    for _, row in pairs(shareListRows) do
        if row then
            row:SetHidden(true)
        end
    end
    
    -- Count and sort share list
    local count = 0
    local sortedList = {}
    for playerName, _ in pairs(savedVars.shareList) do
        table.insert(sortedList, playerName)
        count = count + 1
    end
    table.sort(sortedList)
    
    -- Create rows
    local yOffset = 0
    for index, playerName in ipairs(sortedList) do
        local rowName = "NMKIShareListRow" .. index
        local row = shareListRows[index]
        
        if not row then
            row = CreateControlFromVirtual(rowName, scrollChild, "NMKIShareListRowTemplate")
            shareListRows[index] = row
        end
        
        if row then
            row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
            row:SetHidden(false)
            
            -- Player name
            local nameLabel = row:GetNamedChild("Name")
            if nameLabel then
                nameLabel:SetText(playerName)
            end
            
            -- Remove button
            local removeButton = row:GetNamedChild("Remove")
            if removeButton then
                removeButton:SetHandler("OnClicked", function()
                    self:RemoveFromShareList(playerName)
                    self:UpdateShareListDisplay()
                end)
            end
            
            yOffset = yOffset + 30
        end
    end
    
    -- Update count label
    local countLabel = NightMarketKeysShareListWindowFooterCount
    if countLabel then
        countLabel:SetText(string.format("%d player(s) on share list", count))
    end
end

-- Handle add to share list button click
function NightMarketKeys:OnAddToShareListClicked()
    local inputBox = NightMarketKeysShareListWindowAddSectionInput
    local playerName = inputBox:GetText()
    
    if playerName == "" then
        d("|cFF0000Please enter a player name.|r")
        return
    end
    
    if self:AddToShareList(playerName) then
        self:UpdateShareListDisplay()
        inputBox:SetText("")  -- Clear input
    end
end

-- Handle share button click (OLD - needs to be removed/updated)
function NightMarketKeys:OnShareButtonClicked()
    local inputBox = NightMarketKeysShareWindowShareSectionInput
    if not inputBox then
        d("|cFF0000Share input box not found. Use /nmki share to manage auto-sharing.|r")
        return
    end
    
    local playerName = inputBox:GetText()
    
    if playerName == "" then
        d("|cFF0000Please enter a player name.|r")
        return
    end
    
    self:ShareKeys(playerName, false)
    inputBox:SetText("")  -- Clear input
end

-- Show the block list window
function NightMarketKeys:ShowBlockListWindow()
    self:UpdateBlockListDisplay()
    NightMarketKeysBlockListWindow:SetHidden(false)
end

-- Update the block list display
function NightMarketKeys:UpdateBlockListDisplay()
    local scrollChild = NightMarketKeysBlockListWindowListContainerScrollContainer
    if not scrollChild then return end
    
    -- Clear existing rows
    for _, row in pairs(blockedRows) do
        if row then
            row:SetHidden(true)
        end
    end
    
    -- Count blocked players
    local count = 0
    for _ in pairs(savedVars.blockedPlayers) do
        count = count + 1
    end
    
    if count == 0 then
        -- Update count label
        local countLabel = NightMarketKeysBlockListWindowFooterInfo
        if countLabel then
            countLabel:SetText("No blocked players")
        end
        return
    end
    
    -- Sort blocked players alphabetically
    local sortedPlayers = {}
    for playerName, _ in pairs(savedVars.blockedPlayers) do
        table.insert(sortedPlayers, playerName)
    end
    table.sort(sortedPlayers)
    
    -- Create rows for each blocked player
    local yOffset = 0
    for idx, playerName in ipairs(sortedPlayers) do
        local rowName = "NMKIBlockedRow" .. idx
        local row = blockedRows[idx]
        
        if not row then
            row = CreateControlFromVirtual(rowName, scrollChild, "NMKIBlockedRowTemplate")
            blockedRows[idx] = row
        end
        
        if row then
            row:SetAnchor(TOPLEFT, scrollChild, TOPLEFT, 0, yOffset)
            row:SetHidden(false)
            
            -- Player name
            local nameLabel = row:GetNamedChild("Name")
            if nameLabel then
                nameLabel:SetText(playerName)
            end
            
            -- Unblock button
            local unblockButton = row:GetNamedChild("Unblock")
            if unblockButton then
                unblockButton:SetHandler("OnClicked", function()
                    self:UnblockPlayer(playerName)
                    self:UpdateBlockListDisplay()
                end)
            end
            
            yOffset = yOffset + 30
        end
    end
    
    -- Update count label
    local countLabel = NightMarketKeysBlockListWindowFooterInfo
    if countLabel then
        if count == 1 then
            countLabel:SetText("1 blocked player")
        else
            countLabel:SetText(string.format("%d blocked players", count))
        end
    end
end

-- Handle clear all button click
function NightMarketKeys:OnClearAllButtonClicked()
    -- Confirmation dialog would be nice, but for now just clear
    self:ClearReceivedKeys()
    self:UpdateReceivedWindowDisplay()
end

-- Register for addon loaded event
local function OnAddOnLoaded(event, addonName)
    if addonName == NightMarketKeys.name then
        NightMarketKeys:Initialize()
        NightMarketKeys:InitializeUI()
        EVENT_MANAGER:UnregisterForEvent(NightMarketKeys.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(NightMarketKeys.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
