--[[
    Traveller by Patrick Smyth
    
    This module contains routines that support the searching of lists of players. The routines
    allow the user to specify which lists are searched and in what order.
    
    These lists ordered include the groupmates, friends and guildmates lists. Minimal support
    is provided for node and group leader searches.

    These routines are also used to obtain a groupmate when a group leader jump is requested
    by the group leader.

    Support is also provided for validation of a house jump request for another players house. 
--]]

Order = {
    saveCache = { }
}

-- ==========================================================================================
--
--  Local constants
--

local l_DEFAULT_ORDER = "gf12345"

-- ==========================================================================================
--
-- Local routines
--

local function l_GetUnitZoneId(unitTag)
    local zoneIndex = GetUnitZoneIndex(unitTag)
    local zoneId = nil

    if zoneIndex ~= nil then
        zoneId = GetZoneId(zoneIndex)
    end

    return zoneId
end

local function l_IsUnitSelf(unitTag)
    local gotPC = AreUnitsEqual("player", unitTag)
    return gotPC
end

local function l_GetNumGroup(unitTag)
    local countMembers = 0
    local inGroup = IsUnitGrouped("player")
    inGroup = inGroup or false

    if inGroup then
        countMembers = GetGroupSize()
        countMembers = countMembers or 0
    end

    return countMembers
end

local function l_LookupGroup(callback, param)
    local finished = false
    local countMembers = l_GetNumGroup()

    -- Are we in a group?
    if countMembers > 1 then
        local unitTag = ""
        local zoneId = 0
        local count = 0
        local displayName = ""
        local characterName = ""
        local playerName = ""
        local unitSelf = false
        local canJump = false
        local jumpStatus = 0

        Traveller:Diag("Player is in group of " .. tostring(countMembers) .. " players", 70)

        while (count < countMembers) and not finished do
            count = count + 1
            unitTag = GetGroupUnitTagByIndex(count)

            if unitTag ~= nil then
                unitSelf = l_IsUnitSelf(unitTag)

                if not unitSelf then
                    characterName = GetUnitName(unitTag)
                    characterName = characterName or ""

                    displayName = GetUnitDisplayName(unitTag)
                    displayName = displayName or ""

                    playerName = characterName .. displayName

                    canJump, jumpStatus = CanJumpToGroupMember(unitTag)
                    canJump = canJump or false
                    jumpStatus = jumpStatus or 32767

                    if canJump or (jumpStatus == JUMP_TO_PLAYER_RESULT_SUCCESS) then
                        local playerDesc = { orderChar = G_JUMP_GROUP }

                        playerDesc.characterName = characterName
                        playerDesc.displayName = displayName

                        zoneId = l_GetUnitZoneId(unitTag)
                        playerDesc.zoneId = zoneId or 0

                        finished = callback(playerDesc, param)
                        finished = finished or false

                    elseif jumpStatus == JUMP_TO_PLAYER_RESULT_SOLO_ZONE then
                        Traveller:Diag("Player is in solo zone - " .. playerName, 80)
                    elseif jumpStatus == JUMP_TO_PLAYER_RESULT_CROSS_ALLIANCE_LOCKED then
                        Traveller:Diag("Player is cross-alliance locked - " .. playerName, 80)
                    elseif jumpStatus == JUMP_TO_PLAYER_RESULT_PLAYER_OFFLINE then
                        Traveller:Diag("Player is offline - " .. playerName, 80)
                    elseif jumpStatus == JUMP_TO_PLAYER_RESULT_PLAYER_DIFFICULTY_LOCKED then
                        Traveller:Diag("Player is difficulty locked - " .. playerName, 80)
                    elseif jumpStatus == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
                        local collectibleId = 0
                        local zoneIndex = GetUnitZoneIndex(unitTag)
                        Traveller:Diag("Player is in collectible locked zone - " .. playerName, 80)
                        if zoneIndex ~= nil then
                            collectibleId = GetCollectibleIdForZone(zoneIndex)
                            Traveller:CollectibleDesc(collectibleId)
                        end
                    else
                        Traveller:Diag("Player is not available - " .. playerName, 80)
                    end
                else
                    Traveller:Diag("Member " .. tostring(count) .. " is player", 80)
                end
            else
                Traveller:Diag("Cannot get unit tag for member " .. tostring(count), 80)
            end
        end
    else
        Traveller:Diag("Player is not in a group", 70)
    end

    return finished
end

local function l_LookupFriend(callback, param)
    local displayName = nil
    local characterName = nil
    local hasCharacter = false
    local playerStatus = 0
    local secsSinceLogoff = 0
    local zoneId = 0
    local count = 0
    local finished = false
    local friendCount = GetNumFriends()
    friendCount = friendCount or 0

    if friendCount > 0 then
        Traveller:Diag("Player has " .. tostring(friendCount) .. " friends", 70)
        while (count < friendCount) and not finished do
            count = count + 1
            displayName, _, playerStatus, secsSinceLogoff = GetFriendInfo(count)
            displayName = displayName or ""
            if displayName ~= "" then
                playerStatus = playerStatus or PLAYER_STATUS_OFFLINE
                secsSinceLogoff = secsSinceLogoff or 32767
                if (playerStatus ~= PLAYER_STATUS_OFFLINE) and (secsSinceLogoff <= 0) then
                    -- player is online
                    hasCharacter, characterName, _, _, _, _, _, zoneId = GetFriendCharacterInfo(count)
                    hasCharacter = hasCharacter or false
                    if hasCharacter then
                        local playerDesc = { orderChar = G_JUMP_FRIEND }

                        playerDesc.characterName = characterName or ""
                        playerDesc.displayName = displayName
                        playerDesc.zoneId = zoneId or 0

                        finished = callback(playerDesc, param)
                        finished = finished or false
                    else
                        Traveller:Diag("Friend " .. displayName .. " has no character info", 80)
                    end  
                else
                    Traveller:Diag("Friend " .. displayName .. " is offline", 80)
                end
            else
                Traveller:Diag("Friend " .. tostring(count) .. " has no display name", 80)
            end
        end
    else
        Traveller:Diag("Player has no friends :-(", 70)
    end

    return finished
end

local function l_IsGuildChar(currChar)
    local validChar = false
    local charLen = string.len(currChar)
    charLen = charLen or 0

    if charLen == 1 then
        local currGuild = tonumber(currChar)
        if currGuild ~= nil then
            validChar = ((currGuild >= 1) and (currGuild <= MAX_GUILDS))
        end
    end

    return validChar
end

local function l_GuildIdFromChar(currChar)
    local guildId = nil
    local currGuild = tonumber(currChar)
    local guildCount = GetNumGuilds()
    guildCount = guildCount or 0
    currGuild = currGuild or 32767

    if currGuild <= guildCount then
        guildId = GetGuildId(currGuild)
    end

    return guildId
end

local function l_LookupGuild(currChar, callback, param)
    local finished = false
    local guildId = l_GuildIdFromChar(currChar)

    if guildId ~= nil then
        local memberCount = GetGuildInfo(guildId)
        memberCount = memberCount or 0

        local guildname = GetGuildName(guildId)
        guildname = guildname or ""
        Traveller:Diag("Searching guild (" .. currChar .. "): " .. guildname, 70)

        if memberCount > 0 then
            local displayName = nil
            local characterName = nil
            local hasCharacter = false
            local playerStatus = 0
            local secsSinceLogoff = 0
            local ZoneId = 0
            local count = 0
            local memberIndex = GetPlayerGuildMemberIndex(guildId)
            memberIndex = memberIndex or 0

            Traveller:Diag("Guild has " .. tostring(memberCount) .. " members", 70)

            while (count < memberCount) and not finished do
                count = count + 1
                if count ~= memberIndex then
                    displayName, _, _, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, count)
                    displayName = displayName or ""
                    if displayName ~= "" then
                        playerStatus = playerStatus or PLAYER_STATUS_OFFLINE
                        secsSinceLogoff = secsSinceLogoff or 32767
                        if (playerStatus ~= PLAYER_STATUS_OFFLINE) and (secsSinceLogoff <= 0) then
                            -- player is online
                            hasCharacter, characterName, _, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, count)
                            hasCharacter = hasCharacter or false
                            if hasCharacter then
                                local playerDesc = { }

                                playerDesc.orderChar = currChar
                                playerDesc.characterName = characterName or ""
                                playerDesc.displayName = displayName
                                playerDesc.zoneId = zoneId or 0

                                finished = callback(playerDesc, param)
                                finished = finished or false
                            else
                                Traveller:Diag("Member " .. displayName .. " has no character info", 80)
                            end
                        else
                            Traveller:Diag("Member " .. displayName .. " is offline", 80)
                        end
                    else
                        Traveller:Diag("Member " .. tostring(count) .. " has no display name", 80)
                    end
                else
                    Traveller:Diag("Ignoring player as guild member", 80)
                end
            end
        else
            Traveller:Diag("Guild has no members", 70)
        end
    else
        Traveller:Diag("Player has no guild number " .. currChar, 70)
    end

    return finished
end

-- ==========================================================================================
--
--  External Interface
--

function Order:Initialise(saveCache)
    Order.saveCache = saveCache

    if Order.saveCache.CurrOrder == nil then
        Order.saveCache.CurrOrder = l_DEFAULT_ORDER
    end
end

function Order:Process(callback, param, order)
    local length = 0
    local current = order or ""
    
    if current == "" then
        current = self:Get()
    end

    Traveller:Diag("Using order: " .. current, 70)

    length = string.len(current)

    if length > 0 then
        local currChar = ""
        local count = 0
        local finished = false

        while (count < length) and not finished do
            count = count + 1
            currChar = string.sub(current, count, count)
            if currChar == G_JUMP_GROUP then
                finished = l_LookupGroup(callback, param)
            elseif currChar == G_JUMP_FRIEND then
                finished = l_LookupFriend(callback, param)
            elseif l_IsGuildChar(currChar) then
                finished = l_LookupGuild(currChar, callback, param)
            else
                Traveller:Diag("Unknown character detected in order: <" .. currChar .. ">", 70)
            end
        end
    end
end

function Order:Get()
    local current = Order.saveCache.CurrOrder or ""

    if current == "" then
        Order.saveCache.CurrOrder = l_DEFAULT_ORDER or ""
        current = l_DEFAULT_ORDER or ""
    end

    return current
end

function Order:GetFull()
    local current = self:Get()
    current = G_JUMP_NODE .. G_JUMP_LEADER .. G_JUMP_HOUSE .. current
    return current
end

function Order:Display()
    local current = self:Get()
    local length = string.len(current)
    local countMembers = 0

    Traveller:Diag("Current order is: " .. current, 0)

    if length > 0 then
        local currChar = ""

        Traveller:Diag("Players in:", 30)

        for count = 1, length do
            currChar = string.sub(current, count, count)
            if currChar == G_JUMP_GROUP then
                countMembers = l_GetNumGroup()

                if countMembers <= 1 then
                    Traveller:Diag("Same Group - Currently not grouped", 20)
                else
                    Traveller:Diag("Same Group - Currently in a group of " .. tostring(countMembers) .. " members", 20)
                end
            elseif currChar == G_JUMP_FRIEND then
                countMembers = GetNumFriends()
                countMembers = countMembers or 0

                if countMembers > 0 then
                    Traveller:Diag("Friends List - Currently you have " .. tostring(countMembers) .. " friends", 20)
                else
                    Traveller:Diag("Friends List - Currently you have no friends", 20)
                end
            elseif l_IsGuildChar(currChar) then

                local guildId = l_GuildIdFromChar(currChar)

                if guildId ~= nil then
                    countMembers = GetGuildInfo(guildId)
                    countMembers = countMembers or 0

                    local guildname = GetGuildName(guildId)
                    guildname = guildname or ""
                    
                    Traveller:Diag("Guild " .. currChar .. " - Currently " .. guildname.. " with " .. tostring(countMembers) .. " members", 20)
                else
                    Traveller:Diag("Guild " .. currChar .. " - Slot currently unoccupied", 20)
                end
            else
                Traveller:Diag("Unknown", 70)
            end
        end
    end
end

function Order:Set(newOrder)
    local proposed = Utils:Trim(newOrder)
    local length = string.len(proposed)
    proposed = string.lower(proposed)

    if length > 0 then
        local currChar = ""
        local stringOk = true
        local dupChar = false
        local gotg = false
        local gotf = false
        local gotguild = { }

        for count = 1, length do
            currChar = string.sub(proposed, count, count)

            dupChar = false

            if currChar == G_JUMP_GROUP then
                if gotg then
                    dupChar = true
                else
                    gotg = true
                end
            elseif currChar == G_JUMP_FRIEND then
                if gotf then
                    dupChar = true
                else
                    gotf = true
                end
            elseif l_IsGuildChar(currChar) then
                local guildNum = tonumber(currChar)

                if gotguild[guildNum] ~= nil then
                    dupChar = true
                else
                    gotguild[guildNum] = true
                end
            else
                Traveller:Diag("Invalid Character: <" .. currChar .. ">", 20)
                Traveller:Diag("Only the letters g and f and the digits 1-" .. tostring(MAX_GUILDS) .. " are permitted", 20)
                stringOk = false
            end

            if dupChar then
                Traveller:Diag("Duplicate Character: " .. currChar, 20)
                stringOk = false
            end
        end

        if stringOk then
            Order.saveCache.CurrOrder = proposed
            Traveller:Diag("Order set to " .. proposed, 30)
        else
            Traveller:Diag("Order not set", 30)
        end
    else
        Traveller:Diag("Empty order not permitted", 20)
    end
end

function Order:Reset()
    Order.saveCache.CurrOrder = l_DEFAULT_ORDER
    Traveller:Diag("Order reset to " .. l_DEFAULT_ORDER, 30)
end