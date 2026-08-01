--[[

Map Tools
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]


-- Function to search the players guilds for a member with the specified name.
-- Returns guildId for the guild where the member was found or 0 when not found.
-- memberName can be the displayName or characterName.
local function GetCommonGuild(memberName)
    -- Check every guild
    for guildId=1, GetNumGuilds(), 1 do
        -- Check every member
        for memberIndex=1, GetNumGuildMembers(guildId), 1 do
            -- Get user name and char name
            local uName = GetGuildMemberInfo(guildId, memberIndex)
            local _, cName = GetGuildMemberCharacterInfo(guildId, memberIndex)
            -- Check name
            if uName == memberName
            or string.match(cName, "(.*)^.*") == memberName then
                return guildId
            end
        end
    end
    return 0
end

-- Function to search the players friends and guilds for a member who is in the specified zone.
-- zone can also only be part of a zone name (e.g. "Rawl" for Rawl'kha) and is not case sensitive.
-- Return: string displayName, string zoneName, string memberSource
-- memberSource can be "friends", "guild 1", "guild 2", "guild 3", "guild 4" or "guild 5".
-- Returns nil, nil, nil if not found.
local function GetPlayerInZone(zone)
    zone = string.lower(zone)
    local playerAlliance = GetUnitAlliance("player")
    
    -- Check friends
    for i=1, GetNumFriends(), 1 do
        displayName, _, playerStatus = GetFriendInfo(i)
        -- Only check for online players
        if playerStatus ~= PLAYER_STATUS_OFFLINE then
            _, _, zoneName, _, alliance = GetFriendCharacterInfo(i)
            -- Check if member is in same alliance and the prefered zone
            if alliance == playerAlliance
            and string.match(string.lower(zoneName), zone) ~= nil then
                return displayName, zoneName, "friends"
            end
        end
    end

    -- Check every guild
    for guildId=1, GetNumGuilds(), 1 do
        -- Check every member
        for memberIndex=1, GetNumGuildMembers(guildId), 1 do
            -- Get user name and char name
            local displayName, _, _, playerStatus = GetGuildMemberInfo(guildId, memberIndex)
            -- Only check for online players and self
            if playerStatus ~= PLAYER_STATUS_OFFLINE and displayName ~= GetDisplayName() then
                local _, _, zoneName, _, alliance = GetGuildMemberCharacterInfo(guildId, memberIndex)
                -- Check if member is in same alliance and the prefered zone
                if alliance == playerAlliance
                and string.match(string.lower(zoneName), zone) ~= nil then
                    return displayName, zoneName, "guild "..guildId
                end
            end
        end
    end
    return nil, nil, nil
end

-- Slash command function for advanced fast travel
-- name: name of a friend, guild/group member or zone
local function JumpTo(name)
    -- Argument specified --> Jump to player with that name
    if name ~= "" then
        if IsFriend(name) then
            JumpToFriend(name)
        elseif IsPlayerInGroup(name) then
            JumpToGroupMember(name)
        else
            local guildId = GetCommonGuild(name)
            if guildId > 0 then
                JumpToGuildMember(name)
            else
                local playerInZone, zoneName, memberSource = GetPlayerInZone(name)
                if playerInZone ~= nil then
                    d("Fasttravel to |cFFFFFF"..playerInZone.."|r from |cFFFFFF"..memberSource.."|r in |cFFFFFF"..zoneName)
                    JumpTo(playerInZone)
                else
                    d("Not found")
                end
            end
        end
    else
        local groupSize = GetGroupSize()
        if groupSize <= 1 then
            -- Not grouped, get current zone and try to teleport
            local name = GetZoneNameByIndex(GetCurrentMapZoneIndex())
            JumpTo(name)
        elseif GetGroupSize() == 2 and IsUnitGroupLeader("player") then
            name = GetUnitName("group1")
            if name == GetUnitName("player") then
                name = GetUnitName("group2")
            end
            JumpToGroupMember(name)
        else  -- Group has at least 2 members and player isn't leader
            JumpToGroupLeader()
        end
    end
end
SLASH_COMMANDS["/tp"] = JumpTo