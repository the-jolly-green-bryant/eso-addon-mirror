local KD = KyzderpsDerps

---------------------------------------------------------------------
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end


---------------------------------------------------------------------
-- Port to zone
---------------------------------------------------------------------
local overlandZones = {
    [104] = true, -- Alik'r Desert
    [1413] = true, -- Apocrypha
    [1027] = true, -- Artaeum
    [381] = true, -- Auridon
    [281] = true, -- Bal Foyen
    [92] = true, -- Bangkorai
    [535] = true, -- Betnikh
    [1191] = true, -- Blackreach
    [1208] = true, -- Blackreach: Arkthzand Cavern
    [1161] = true, -- Blackreach: Greymoor Caverns
    [1261] = true, -- Blackwood
    [280] = true, -- Bleakrock Isle
    [980] = true, -- Clockwork City
    [981] = true, -- The Brass Fortress
    [347] = true, -- Coldharbour
    [888] = true, -- Craglorn
    [57] = true, -- Deshaan
    [101] = true, -- Eastmarch
    [267] = true, -- Eyevea
    [1463] = true, -- The Scholarium
    [1282] = true, -- Fargrave
    [1283] = true, -- The Shambles
    [1383] = true, -- Galen
    [3] = true, -- Glenumbra
    [823] = true, -- Gold Coast
    [383] = true, -- Grahtwood
    [108] = true, -- Greenshade
    [816] = true, -- Hew's Bane
    [1318] = true, -- High Isle
    [537] = true, -- Khenarthi's Roost
    [58] = true, -- Malabal Tor
    [726] = true, -- Murkmire
    [1086] = true, -- Northern Elsweyr
    [382] = true, -- Reaper's March
    [20] = true, -- Rivenspire
    [117] = true, -- Shadowfen
    [1502] = true, -- Solstice
    [1133] = true, -- Southern Elsweyr
    [41] = true, -- Stonefalls
    [19] = true, -- Stormhaven
    [534] = true, -- Stros M'Kai
    [1011] = true, -- Summerset
    [1414] = true, -- Telvanni Peninsula
    [1286] = true, -- The Deadlands
    [1207] = true, -- The Reach
    [103] = true, -- The Rift
    [849] = true, -- Vvardenfell
    [1443] = true, -- West Weald
    [1160] = true, -- Western Skyrim
    [684] = true, -- Wrothgar
    [1146] = true, -- Tideholm
    [1463] = true, -- The Scholarium
    [1559] = true, -- Night Market
}


---------------------------------------------------------------------
-- Target collection
---------------------------------------------------------------------
local TYPE_GROUP = 1
local TYPE_FRIEND = 2
local TYPE_GUILD = 3

local targetPlayers = {} -- {{atName = @asdf, zoneId = 123, charName = "asdf", type = TYPE_GROUP}}
local function AddTarget(atName, charName, zoneId, type)
    if (not CanJumpToPlayerInZone(zoneId)) then
        KD:dbg(zo_strformat("Excluding <<1>> from jump targets because you cannot jump to <<2>>", atName, GetZoneNameById(zoneId)))
        return
    end

    local target = targetPlayers[atName]
    if (target) then
        if (target.type <= type) then
            -- Don't allow e.g. guild to overwrite group
            return
        end
        target.type = type
    else
        targetPlayers[atName] = {atName = atName, charName = charName, zoneId = zoneId, type = type}
    end
end

-- Collect all potential target players, unique and ordered by type
local function CollectTargets()
    ZO_ClearTable(targetPlayers)

    local playerName = GetUnitDisplayName("player")

    -- Check group
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitDisplayName(unitTag)
        if (IsUnitOnline(unitTag) and name ~= playerName) then
            local zoneId = GetZoneId(GetUnitZoneIndex(unitTag))
            AddTarget(name, GetUnitName(unitTag), zoneId, TYPE_GROUP)
        end
    end

    -- Check friends
    for i = 1, GetNumFriends() do
        local name, _, status = GetFriendInfo(i)
        if (status ~= PLAYER_STATUS_OFFLINE and name ~= playerName) then
            local _, characterName, _, _, _, _, _, zoneId = GetFriendCharacterInfo(i)
            AddTarget(name, characterName, zoneId, TYPE_FRIEND)
        end
    end

    -- Check guilds
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        for j = 1, GetNumGuildMembers(guildId) do
            local name, _, _, status = GetGuildMemberInfo(guildId, j)
            if (status ~= PLAYER_STATUS_OFFLINE and name ~= playerName) then
                local _, characterName, _, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, j)
                AddTarget(name, characterName, zoneId, TYPE_GUILD)
            end
        end
    end

    -- Sort
    local sortedTargets = {}
    for _, data in pairs(targetPlayers) do
        table.insert(sortedTargets, data)
    end
    table.sort(sortedTargets, function(a, b)
        return a.type < b.type
    end)

    targetPlayers = sortedTargets
end


---------------------------------------------------------------------
-- Interacting with wayshrine after fallback
---------------------------------------------------------------------
local firstPlayerActivated = false

local function OnFastTravelInteract(zoneId)
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "FastTravel", EVENT_START_FAST_TRAVEL_INTERACTION)
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "FastTravelPlayerActivated", EVENT_PLAYER_ACTIVATED)

    KD:msg(string.format("Opening map to |c00FFFF%s |cAAAAAA(%d) because that's what you wanted... right?", GetZoneNameById(zoneId), zoneId))
    WORLD_MAP_MANAGER:SetMapById(GetMapIdByZoneId(zoneId))
end

local function OnPlayerActivated()
    if (firstPlayerActivated) then
        EVENT_MANAGER:UnregisterForEvent(KD.name .. "FastTravel", EVENT_START_FAST_TRAVEL_INTERACTION)
        EVENT_MANAGER:UnregisterForEvent(KD.name .. "FastTravelPlayerActivated", EVENT_PLAYER_ACTIVATED)
        firstPlayerActivated = false
        KD:dbg("more than 1 port after fallback map open intention; cancelling")
        return
    end

    firstPlayerActivated = true
end

-- If user had actually wanted to go to some zone, but no players were available there,
-- then assume the next interaction with a wayshrine is an intention to port to the
-- originally desired zone, so open the map to that zone
local function StartFallbackFastTravel(zoneId)
    KD:dbg("will try to open to " .. zoneId .. " next time")
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "FastTravel", EVENT_START_FAST_TRAVEL_INTERACTION)
    EVENT_MANAGER:RegisterForEvent(KD.name .. "FastTravel", EVENT_START_FAST_TRAVEL_INTERACTION,
        function() OnFastTravelInteract(zoneId) end)

    -- This function is called as soon as the command is sent, so we'll have 1 player
    -- activation after the initial port. After the 2nd player activation, assume the
    -- map open is no longer wanted and cancel it
    firstPlayerActivated = false
    EVENT_MANAGER:RegisterForEvent(KD.name .. "FastTravelPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end


---------------------------------------------------------------------
-- Final fallback
---------------------------------------------------------------------
-- Fallback to outside owned houses that are near wayshrines
-- Returns true if handled
local function PortOutsideHouse(ifFallbackDesiredZoneId)
    local decentHouses = {
        68, -- Sugar Bowl Suite
        32, -- Mournoth Keep
        63, -- Enchanted Snow Globe Home
        25, -- Cyrodilic Jungle House
        13, -- Snugpod
        78, -- Proudspire Manor
        80, -- Stillwaters Retreat
        37, -- Serenity Falls Estate

        -- Requires loadscreen
        6, -- Flaming Nix Deluxe Garret
        19, -- Kragenhome
        1, -- Mara's Kiss Public House
        3, -- The Ebony Flask Inn Room
    }

    for _, houseId in ipairs(decentHouses) do
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if (IsCollectibleUnlocked(collectibleId)) then
            KD:msg(zo_strformat("No players or zone found, porting outside of your <<1>> instead", GetCollectibleName(collectibleId)))
            RequestJumpToHouse(houseId, true)

            -- For opening map
            if (ifFallbackDesiredZoneId and KD.savedOptions.misc.openMapForFallback) then
                StartFallbackFastTravel(ifFallbackDesiredZoneId)
            end
            return true
        end
    end

    return false
end


---------------------------------------------------------------------
-- Porting logic
---------------------------------------------------------------------
local function ShowUsage()
    KD:msg("Usage: /ktp <@name || zoneName> - Example: /ktp @Kyzeragon || /ktp sol")
end

local portTypes = {
    [TYPE_GROUP] = {portFunc = JumpToGroupMember, format = "Porting to group member <<1>> in |c00FFFF<<2>>"},
    [TYPE_FRIEND] = {portFunc = JumpToFriend, format = "Porting to friend <<1>> in |c00FFFF<<2>>"},
    [TYPE_GUILD] = {portFunc = JumpToGuildMember, format = "Porting to guild member <<1>> in |c00FFFF<<2>>"},
}

-- ifFallbackDesiredZoneId: if this was a port to a zone that resulted in fallback, the zoneId
local function PortToTarget(target, ifFallbackDesiredZoneId)
    local portType = portTypes[target.type]
    portType.portFunc(target.atName)
    KD:msg(zo_strformat(portType.format, target.atName, GetZoneNameById(target.zoneId)))

    -- For opening map
    if (ifFallbackDesiredZoneId and KD.savedOptions.misc.openMapForFallback) then
        StartFallbackFastTravel(ifFallbackDesiredZoneId)
    end
end

-- Search targets for player
-- Returns true for handled
local function TryPortToPlayerName(argString, exact, beginning)
    local partial = argString
    if (not StartsWith(partial, "@") and beginning) then
        partial = "@" .. partial
    end
    partial = string.lower(partial)

    for _, target in ipairs(targetPlayers) do
        local loweredName = string.lower(target.atName)
        if (exact) then
            -- Exact name only
            if (partial == loweredName) then
                PortToTarget(target)
                return true
            end
        else
            -- Partial allowed
            if (beginning) then
                -- Must begin with
                if (StartsWith(loweredName, partial)) then
                    PortToTarget(target)
                    return true
                end
            else
                -- Match any part
                if (string.find(loweredName, partial, 1, true)) then
                    PortToTarget(target)
                    return true
                end
            end
        end
    end

    return false
end

-- Port to a player in the zone, or a fallback. Will always be handled, unless
-- there's really nowhere to port.
-- zoneId can be nil
local function PortToPlayerInZone(zoneId, collectTargets)
    if (collectTargets) then
        CollectTargets()
    end

    local fallbackSameZoneTarget, fallbackTarget
    for _, target in ipairs(targetPlayers) do
        if (target.zoneId == zoneId) then
            PortToTarget(target)
            return
        end

        -- Save fallbacks
        if (not fallbackSameZoneTarget and overlandZones[target.zoneId] and target.zoneId == GetZoneId(GetUnitZoneIndex("player"))) then
            fallbackSameZoneTarget = target
        end
        if (not fallbackTarget and overlandZones[target.zoneId]) then
            fallbackTarget = target
        end
    end

    -- If none found, use same overland zone as fallback, otherwise first overland zone as fallback
    if (fallbackSameZoneTarget or fallbackTarget) then
        if (zoneId) then
            KD:msg(zo_strformat("Unable to find any players in <<1>>; using fallback.", GetZoneNameById(zoneId)))
            PortToTarget(fallbackSameZoneTarget or fallbackTarget, zoneId)
            return
        else
            -- Called only for final fallback
            KD:msg("Unable to find a matching player or zone name or the zone is inaccessible; using fallback.")
            PortToTarget(fallbackSameZoneTarget or fallbackTarget)
            return
        end
    end

    -- If no zone fallback, use a house
    if (PortOutsideHouse(zoneId)) then return end

    -- Really? No houses?
    if (zoneId) then
        KD:msg(zo_strformat("Unable to find any players in <<1>> nor overland zones, nor do you own any decent houses. Maybe consider buying the Sugar Bowl Suite? :D", GetZoneNameById(zoneId)))
    else
        KD:msg("Unable to find a matching player or zone or the zone is inaccessible. No players found in overland zones, nor do you own any decent houses. Maybe consider buying the Sugar Bowl Suite? :D")
    end
end
KD.PortToPlayerInZone = PortToPlayerInZone


-- Matches for zone name and then ports
-- Returns true for handled
local function TryPortToZone(argString, exact, beginning)
    local searchString = string.lower(argString)

    for zoneId, _ in pairs(overlandZones) do
        local name = string.lower(GetZoneNameById(zoneId))

        if (exact) then
            -- Exact match
            if (searchString == name) then
                KD:msg(string.format("Matched zone %s (%d)", GetZoneNameById(zoneId), zoneId))
                PortToPlayerInZone(zoneId)
                return true
            end
        else
            if (beginning) then
                -- Begins with
                if (StartsWith(name, searchString)) then
                    KD:msg(string.format("Matched zone %s (%d)", GetZoneNameById(zoneId), zoneId))
                    PortToPlayerInZone(zoneId)
                    return true
                end
            else
                -- Contains
                if (string.find(name, searchString, 1, true)) then
                    KD:msg(string.format("Matched zone %s (%d)", GetZoneNameById(zoneId), zoneId))
                    PortToPlayerInZone(zoneId)
                    return true
                end
            end
        end
    end

    return false
end

local function PortToAny(argString)
    if (not argString or argString == "") then
        ShowUsage()
        return
    end

    CollectTargets()

    -- If @, only port to player
    if (StartsWith(argString, "@")) then
        if (TryPortToPlayerName(argString, true)) then return end
        if (TryPortToPlayerName(argString, false, true)) then return end
        if (TryPortToPlayerName(argString, false, false)) then return end
        KD:msg("Couldn't find any player matching " .. argString)
        return
    end

    -- Else, match full zone first, then full name, beginning zone, beginning name, partial zone, partial name
    if (TryPortToZone(argString, true)) then return end
    if (TryPortToPlayerName(argString, true)) then return end
    if (TryPortToZone(argString, false, true)) then return end
    if (TryPortToPlayerName(argString, false, true)) then return end
    if (TryPortToZone(argString, false, false)) then return end
    if (TryPortToPlayerName(argString, false, false)) then return end

    -- Final fallback that tries any overland zone, then houses
    PortToPlayerInZone()
end
KD.PortToAny = PortToAny
