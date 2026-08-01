--[[
================================================================================
 HTTT Teleport Module
 Contains teleportation and zone resolution functionality
 
 This module combines ESO's fragmented teleport functions into a cohesive system that finds the best teleport option based on the context, saving players time and gold.
 
 This module provides:
 - Zone name resolution and fuzzy matching
 - Smart teleportation to find free travel options
 - Friend, guild member, and group member teleportation
 - Housing teleportation utilities
================================================================================
]]--

HTTT = HTTT or {}
HTTT.Teleport = {}

-- Resolves zone input (name, alias, or id) to a valid zoneId
-- @ param input string|number Zone name, alias, or ID to resolve
-- @ return number|nil Valid zoneId if found, nil otherwise
-- @ usage local zoneId = HTTT.Teleport.ResolveZoneId("alik'r") -- Returns 104
function HTTT.Teleport.ResolveZoneId(input)
    input = zo_strtrim(input or "")
    if input == "" then return nil end
    
    -- Return as soon as we find a direct numeric match
    local asId = tonumber(input)
    if asId and HTTT.Data.OVERLAND_ZONE_IDS[asId] then return asId end
    
    local search = input:lower():gsub("[^%w]", "")
    
    -- Check exact matches in aliases first (faster)
    local exactMatch = HTTT.Data.ALIAS_ZONE_NAMES[search]
    if exactMatch then return exactMatch end

    -- Check alias table
    for alias, zoneId in pairs(HTTT.Data.ALIAS_ZONE_NAMES) do
        local aliasKey = alias:lower():gsub("[^%w]", "")
        if aliasKey == search or aliasKey:find(search, 1, true) or search:find(aliasKey, 1, true) then
            return zoneId
        end
    end
    
    -- Check zone name mapping
    for zoneKey, id in pairs(HTTT.Data.ZONE_NAME_TO_ID) do
        if zoneKey:find(search, 1, true) then
            return id
        end
    end

    return nil
end

-- Get current overland zone ID
-- @ return number|nil Valid overland zoneId if player is in one, nil otherwise
-- @ usage local currentZone = HTTT.Teleport.GetRelevantOverlandZoneId()
function HTTT.Teleport.GetRelevantOverlandZoneId()
    local currentZoneId = GetZoneId(GetUnitZoneIndex("player"))
    if HTTT.Data.OVERLAND_ZONE_IDS[currentZoneId] then return currentZoneId end
    
    local parentZoneId = GetParentZoneId(currentZoneId)
    if HTTT.Data.OVERLAND_ZONE_IDS[parentZoneId] then return parentZoneId end
    
    return nil
end

-- Check if zone can be accessed for smart teleport
-- @ param zoneId number The zone ID to check
-- @ return boolean True if zone is accessible, false otherwise
-- @ usage if HTTT.Teleport.CanAccessZoneForSmartTeleport(zoneId) then -- Zone is accessible
function HTTT.Teleport.CanAccessZoneForSmartTeleport(zoneId)
    if not zoneId or zoneId == 0 then return false end
    
    local canJump, result = CanJumpToPlayerInZone(zoneId)
    if canJump then
        HTTT.Core.DebugMessage("[Debug] Zone OK: %s (%d)", GetZoneNameById(zoneId), zoneId)
        return true
    end
    
    -- Log debug reason if enabled
    local reasonText = HTTT.Data.JUMP_RESULT_REASON_MAP[result] or ("ReasonId:" .. tostring(result))
    HTTT.Core.DebugMessage("[Debug] Skipping zone %s (%d): %s", GetZoneNameById(zoneId), zoneId, reasonText)
    
    return false
end

-- Find teleport target in zone
-- @ param zoneId number The zone ID to search for targets in
-- @ param myDisplayName string The player's display name to exclude from results
-- @ return string|false The display name of the found target, or false if none found
-- @ usage local target = HTTT.Teleport.FindTeleportTargetInZone(zoneId, GetDisplayName())
function HTTT.Teleport.FindTeleportTargetInZone(zoneId, myDisplayName)
    -- Check friends
    for i = 1, GetNumFriends() do
        local displayName, _, status = GetFriendInfo(i)
        if displayName ~= myDisplayName and status ~= PLAYER_STATUS_OFFLINE then
            local hasChar, _, _, _, _, _, _, friendZoneId = GetFriendCharacterInfo(i)
            if hasChar and friendZoneId == zoneId then
                JumpToFriend(displayName)
                d(HTTT.Core.PREFIX .. string.format("Traveling to %s in %s.", displayName, GetZoneNameById(zoneId)))
                return displayName
            end
        end
    end
    
    -- Check guild members
    for g = 1, GetNumGuilds() do
        local guildId = GetGuildId(g)
        for i = 1, GetNumGuildMembers(guildId) do
            local displayName, _, _, status = GetGuildMemberInfo(guildId, i)
            if displayName ~= myDisplayName and status ~= PLAYER_STATUS_OFFLINE then
                local hasChar, _, _, _, _, _, _, guildZoneId = GetGuildMemberCharacterInfo(guildId, i)
                if hasChar and guildZoneId == zoneId then
                    JumpToGuildMember(displayName)
                    d(HTTT.Core.PREFIX .. string.format("Traveling to %s in %s.", displayName, GetZoneNameById(zoneId)))
                    return displayName
                end
            end
        end
    end
    
    return false
end

-- Try to jump to friend or guild in zone with fallbacks
-- @ param zoneId number|nil Optional specific zone ID to try first
-- @ return boolean True if teleport was successful, false otherwise
-- @ usage local success = HTTT.Teleport.TryJumpToFriendOrGuildInZone(1261) -- Try Blackwood first
function HTTT.Teleport.TryJumpToFriendOrGuildInZone(zoneId)
    local myDisplayName = GetDisplayName()
    local checkedZones = {}  -- Prevents duplicate zone evaluation attempts

    local function attempt(zone)
        if checkedZones[zone] then return false end
        checkedZones[zone] = true
        
        if not HTTT.Teleport.CanAccessZoneForSmartTeleport(zone) then
            return false
        end
        
        return HTTT.Teleport.FindTeleportTargetInZone(zone, myDisplayName) and true or false
    end

    -- Try requested zone first if provided (early return if successful)
    if zoneId and attempt(zoneId) then return true end

    -- Try priority expansion zones
    for _, dlcZoneId in ipairs(HTTT.Data.PRIORITY_EXPANSION_ZONE_IDS) do
        if attempt(dlcZoneId) then return true end
    end

    -- Try any overland zone as last resort
    for whitelistedZoneId in pairs(HTTT.Data.OVERLAND_ZONE_IDS) do
        if attempt(whitelistedZoneId) then return true end
    end
    
    return false
end

-- Main smart teleport function
-- Attempts to find a free teleport option to a wayshrine
-- @ usage HTTT.Teleport.FreeTeleportToPriorityWayshrine()
function HTTT.Teleport.FreeTeleportToPriorityWayshrine()
    local targetZoneId = HTTT.Teleport.GetRelevantOverlandZoneId()
    
    -- Try current zone
    if targetZoneId and HTTT.Teleport.TryJumpToFriendOrGuildInZone(targetZoneId) then
        return
    end
    
    -- Try priority zones
    for _, zoneId in ipairs(HTTT.Data.PRIORITY_EXPANSION_ZONE_IDS) do
        if not targetZoneId or zoneId ~= targetZoneId then
            if HTTT.Teleport.TryJumpToFriendOrGuildInZone(zoneId) then return end
        end
    end
    
    -- No targets found
    d(HTTT.Core.PREFIX .. "No friends or guild members found in any accessible prioritized overland zone.")
    d(HTTT.Core.PREFIX .. "|cFFFF00No free teleport available.|r You can find a wayshrine to travel for free, or pay gold to fast travel from your current location.")
    SCENE_MANAGER:Show("worldMap")
end

-- Teleport to user by account name - single attempt approach
-- @ param accountName string The account name to teleport to
-- @ usage HTTT.Teleport.PortToUser("@Friend_Name")
function HTTT.Teleport.PortToUser(accountName)
    if not accountName or accountName == "" then
        d(HTTT.Core.PREFIX .. "No account name provided.")
        return
    end
    
    if accountName:lower() == GetDisplayName():lower() then
        d(HTTT.Core.PREFIX .. "You cannot travel to yourself.")
        return
    end
    
    -- Choose only ONE method based on relationship priority
    if IsFriend(accountName) then
        -- Use friend teleport
        d(HTTT.Core.PREFIX .. string.format("Traveling to friend %s's location.", accountName))
        JumpToFriend(accountName)
    elseif IsPlayerInGroup(accountName) or DoesUnitExist("group" .. accountName) then
        -- Use group teleport
        d(HTTT.Core.PREFIX .. string.format("Traveling to group member %s's location.", accountName))
        JumpToGroupMember(accountName)
    else
        -- Default to guild teleport since we can't easily check if they're in a guild
        d(HTTT.Core.PREFIX .. string.format("Attempting to travel to %s's location.", accountName))
        JumpToGuildMember(accountName)
    end
end

-- Jump to primary home
-- @ param jumpOutside boolean If true, teleports outside the home; if false, teleports inside
-- @ usage HTTT.Teleport.JumpToPrimaryHome(true) -- Jump to outside of primary home
function HTTT.Teleport.JumpToPrimaryHome(jumpOutside)
    local houseId = GetHousingPrimaryHouse()
    if houseId > 0 then
        RequestJumpToHouse(houseId, jumpOutside)
        if jumpOutside then
            d(HTTT.Core.PREFIX .. "Traveling to your primary home - outside.")
        else
            d(HTTT.Core.PREFIX .. "Traveling to your primary home - inside.")
        end
    else
        d(HTTT.Core.PREFIX .. "You do not have a primary home set.")
    end
end