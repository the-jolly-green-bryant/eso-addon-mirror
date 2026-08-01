--[[
================================================================================
 HTTT Favorites Module
 Contains favorites management functionality for quick travel options
 
 This module provides:
 - Storage and retrieval of favorite zones, friends, and friend houses
 - Slot-based favorites management (up to 10 slots per category)
 - User-friendly nickname support for favorites
 - Command interface for setting and using favorites
================================================================================
]]--

HTTT = HTTT or {}
HTTT.Favorites = {}

-- Initialize favorites module
-- Ensures all required data structures exist in saved variables
-- @ return nil
function HTTT.Favorites.Initialize()
    -- Ensure favorites tables exist
    HTTT.Core.EnsureFavorites(HTTT.Data.FAVORITE_TYPES.FRIEND_HOUSES)
    HTTT.Core.EnsureFavorites(HTTT.Data.FAVORITE_TYPES.ZONES)
    HTTT.Core.EnsureFavorites(HTTT.Data.FAVORITE_TYPES.FRIENDS)
end

-- Helper function to validate slot number
-- @ param slot number|string The slot number to validate
-- @ param maxSlot number The maximum allowed slot number
-- @ return number|false The validated slot number or false if invalid
-- @ usage local validSlot = HTTT.Favorites.ValidateSlot(3, 10)
function HTTT.Favorites.ValidateSlot(slot, maxSlot)
    slot = tonumber(slot)
    if not slot or slot < 1 or slot > maxSlot then
        return false
    end
    return slot
end

-- Helper function to validate slot and get entry in one step
-- @ param favoriteType string The type of favorite to retrieve
-- @ param slot number|string The slot number to validate and retrieve
-- @ param maxSlot number The maximum allowed slot number
-- @ return table|nil, number|nil, number|nil The favorite entry, validated slot, and error info
-- @ usage local entry, slot, err = HTTT.Favorites.GetFavoriteEntry(HTTT.Data.FAVORITE_TYPES.ZONES, 3, 10)
function HTTT.Favorites.GetFavoriteEntry(favoriteType, slot, maxSlot)
    slot = HTTT.Favorites.ValidateSlot(slot, maxSlot)
    if not slot then
        return nil, nil, maxSlot
    end
    
    local favorites = HTTT.Core.EnsureFavorites(favoriteType)
    local entry = favorites[slot]
    
    if not entry or not entry.id then
        return nil, slot, nil
    end
    
    return entry, slot, nil
end

-- Helper to extract account and nickname from params - optimized with early return
-- @ param param string The input parameter string containing account info
-- @ return string|nil, string|nil The account ID and optional nickname
-- @ usage local accountId, nickname = HTTT.Favorites.ExtractAccountInfo("@MyFriend /nickname Best Friend")
function HTTT.Favorites.ExtractAccountInfo(param)
    local accountid = string.match(param, "@[%w%._-]+")
    if not accountid then return nil, nil end
    
    local nickname = string.match(param, "/nickname%s+(.+)")
    
    if not nickname then
        local afterid = param:match("@[%w%._-]+%s*(.*)")
        if afterid and afterid ~= "" then
            nickname = afterid
        end
    end
    
    return accountid, HTTT.Core.CapitalizeNickname(nickname)
end

-- Generic function to set any type of favorite
-- @ param favoriteType string Type of favorite from HTTT.Data.FAVORITE_TYPES
-- @ param slot number|string Slot number to set
-- @ param param string Input parameters (account name or zone)
-- @ usage HTTT.Favorites.SetFavorite(HTTT.Data.FAVORITE_TYPES.ZONES, 3, "vvardenfell")
function HTTT.Favorites.SetFavorite(favoriteType, slot, param)
    -- Map favorite type to MAX_SLOTS key
    local maxSlotsKey
    if favoriteType == HTTT.Data.FAVORITE_TYPES.FRIEND_HOUSES then
        maxSlotsKey = "FRIEND_HOUSES"
    elseif favoriteType == HTTT.Data.FAVORITE_TYPES.ZONES then
        maxSlotsKey = "ZONES"
    elseif favoriteType == HTTT.Data.FAVORITE_TYPES.FRIENDS then
        maxSlotsKey = "FRIENDS"
    else
        d(HTTT.Core.PREFIX .. "Invalid favorite type.")
        return
    end
    
    local maxSlots = HTTT.Data.MAX_SLOTS[maxSlotsKey]
    slot = HTTT.Favorites.ValidateSlot(slot, maxSlots)
    if not slot then
        local typeName = favoriteType:gsub("favorite", ""):lower()
        d(HTTT.Core.PREFIX .. string.format("Usage: /tp set%s <slot> ...", favoriteType:lower()))
        return
    end
    
    -- Extract data based on type
    local data
    if favoriteType == HTTT.Data.FAVORITE_TYPES.ZONES then
        local zoneId = HTTT.Teleport.ResolveZoneId(param)
        if not zoneId or zoneId == 0 then
            d(HTTT.Core.PREFIX .. "Invalid zone name or id.")
            return
        end
        data = { id = zoneId, name = GetZoneNameById(zoneId) }
    else
        local accountid, nickname = HTTT.Favorites.ExtractAccountInfo(param)
        if not accountid then
            d(HTTT.Core.PREFIX .. string.format("Usage: /tp set%s %d @AccountName [/nickname Custom Name]", favoriteType:lower(), slot))
            return
        end
        data = { id = accountid, nickname = nickname }
    end
    
    -- Save data
    local favorites = HTTT.Core.EnsureFavorites(favoriteType)
    favorites[slot] = data
    
    -- Format success message based on type
    if favoriteType == HTTT.Data.FAVORITE_TYPES.ZONES then
        d(HTTT.Core.PREFIX .. string.format("Favorite zone slot %d set to %s (ID: %d). Use /tp favoritezone%d to travel.", 
            slot, data.name, data.id, slot))
    else
        local typeName = favoriteType == HTTT.Data.FAVORITE_TYPES.FRIEND_HOUSES and "friend house" or "friend"
        if data.nickname then
            d(HTTT.Core.PREFIX .. string.format("Favorite %s slot %d set to %s (nickname: %s). Use /tp favorite%s%d to travel.", 
                typeName, slot, data.id, data.nickname, typeName:gsub(" ", ""), slot))
        else
            d(HTTT.Core.PREFIX .. string.format("Favorite %s slot %d set to %s. Use /tp favorite%s%d to travel.", 
                typeName, slot, data.id, typeName:gsub(" ", ""), slot))
        end
    end
end

--[[ FAVORITE FRIEND HOUSES MANAGEMENT ]]--

-- Set a favorite friend's house
-- @ param slot number|string Slot number to set (1-10)
-- @ param param string Friend account name with optional nickname
-- @ usage HTTT.Favorites.SetFavoriteFriendHouse(1, "@MyFriend /nickname Luxury Manor")
function HTTT.Favorites.SetFavoriteFriendHouse(slot, param)
    HTTT.Favorites.SetFavorite(HTTT.Data.FAVORITE_TYPES.FRIEND_HOUSES, slot, param)
end

-- Travel to a favorite friend's house
-- @ param slot number|string Slot number to travel to
-- @ usage HTTT.Favorites.PortToFavoriteFriendHouse(1)
function HTTT.Favorites.PortToFavoriteFriendHouse(slot)
    local entry, validSlot = HTTT.Favorites.GetFavoriteEntry(
        HTTT.Data.FAVORITE_TYPES.FRIEND_HOUSES, 
        slot, 
        HTTT.Data.MAX_SLOTS.FRIEND_HOUSES
    )
    
    if not entry then
        if not validSlot then
            d(HTTT.Core.PREFIX .. "Usage: /tp favoritefriendhouse <slot>")
        else
            d(HTTT.Core.PREFIX .. string.format("No favorite friend house set in slot %d.", validSlot))
        end
        return
    end
    
    JumpToHouse(entry.id)
    d(HTTT.Core.PREFIX .. string.format("Traveling to favorite house: %s.", entry.nickname or entry.id))
end

-- List all favorite friend houses
-- @ usage HTTT.Favorites.ListFavoriteFriendHouses()
function HTTT.Favorites.ListFavoriteFriendHouses()
    HTTT.Favorites.ListFavorites(
        HTTT.Data.FAVORITE_TYPES.FRIEND_HOUSES,
        "Saved favorite friend houses:",
        HTTT.Data.MAX_SLOTS.FRIEND_HOUSES,
        function(i, entry)
            if entry.nickname then
                return string.format("%d: %s (%s)", i, entry.nickname, entry.id)
            else
                return string.format("%d: %s", i, entry.id)
            end
        end
    )
end

--[[ FAVORITE ZONES MANAGEMENT ]]--

-- Set a favorite zone
-- @ param slot number|string Slot number to set (1-10)
-- @ param param string Zone name or ID
-- @ usage HTTT.Favorites.SetFavoriteZone(1, "vvardenfell")
function HTTT.Favorites.SetFavoriteZone(slot, param)
    HTTT.Favorites.SetFavorite(HTTT.Data.FAVORITE_TYPES.ZONES, slot, param)
end

-- Travel to a favorite zone
-- @ param slot number|string Slot number to travel to
-- @ usage HTTT.Favorites.PortToFavoriteZone(1)
function HTTT.Favorites.PortToFavoriteZone(slot)
    local entry, validSlot = HTTT.Favorites.GetFavoriteEntry(
        HTTT.Data.FAVORITE_TYPES.ZONES, 
        slot, 
        HTTT.Data.MAX_SLOTS.ZONES
    )
    
    if not entry then
        if not validSlot then
            d(HTTT.Core.PREFIX .. "Usage: /tp favoritezone <slot>")
        else
            d(HTTT.Core.PREFIX .. string.format("No favorite zone set in slot %d.", validSlot))
        end
        return
    end
    
    local myDisplayName = GetDisplayName()
    local found = HTTT.Teleport.FindTeleportTargetInZone(entry.id, myDisplayName)
    
    if not found then
        -- Only fetch zone name when needed for error message
        local zoneName = entry.name or GetZoneNameById(entry.id)
        d(HTTT.Core.PREFIX .. string.format("No friends or guild members found in favorite zone: %s.", zoneName))
    end
end

-- List all favorite zones
-- @ usage HTTT.Favorites.ListFavoriteZones()
function HTTT.Favorites.ListFavoriteZones()
    HTTT.Favorites.ListFavorites(
        HTTT.Data.FAVORITE_TYPES.ZONES,
        "Favorite zones:",
        HTTT.Data.MAX_SLOTS.ZONES,
        function(i, entry)
            if entry.name then
                return string.format("%d: %s (ID: %d)", i, entry.name, entry.id)
            else
                return string.format("%d: (empty)", i)
            end
        end
    )
end

--[[ FAVORITE FRIENDS MANAGEMENT ]]--

-- Set a favorite friend
-- @ param slot number|string Slot number to set (1-10)
-- @ param param string Friend account name with optional nickname
-- @ usage HTTT.Favorites.SetFavoriteFriend(1, "@MyFriend /nickname Guild Leader")
function HTTT.Favorites.SetFavoriteFriend(slot, param)
    HTTT.Favorites.SetFavorite(HTTT.Data.FAVORITE_TYPES.FRIENDS, slot, param)
end

-- Travel to a favorite friend
-- @ param slot number|string Slot number to travel to
-- @ usage HTTT.Favorites.PortToFavoriteFriend(1)
function HTTT.Favorites.PortToFavoriteFriend(slot)
    local entry, validSlot = HTTT.Favorites.GetFavoriteEntry(
        HTTT.Data.FAVORITE_TYPES.FRIENDS, 
        slot, 
        HTTT.Data.MAX_SLOTS.FRIENDS
    )
    
    if not entry then
        if not validSlot then
            d(HTTT.Core.PREFIX .. "Usage: /tp favoritefriend <slot>")
        else
            d(HTTT.Core.PREFIX .. string.format("No favorite friend set in slot %d.", validSlot))
        end
        return
    end
    
    HTTT.Teleport.PortToUser(entry.id)
end

-- List all favorite friends
-- @ usage HTTT.Favorites.ListFavoriteFriends()
function HTTT.Favorites.ListFavoriteFriends()
    HTTT.Favorites.ListFavorites(
        HTTT.Data.FAVORITE_TYPES.FRIENDS,
        "Favorite friends:",
        HTTT.Data.MAX_SLOTS.FRIENDS,
        function(i, entry)
            if entry.nickname then
                return string.format("%d: %s (%s)", i, entry.nickname, entry.id)
            else
                return string.format("%d: %s", i, entry.id)
            end
        end
    )
end

-- Generic function to list any type of favorites
-- @ param favoriteType string The type of favorite to list
-- @ param title string The header text to display
-- @ param maxSlots number The maximum number of slots to display
-- @ param formatFunc function Formatting function for each entry
-- @ usage HTTT.Favorites.ListFavorites(HTTT.Data.FAVORITE_TYPES.ZONES, "My Zones:", 10, formatFunction)
function HTTT.Favorites.ListFavorites(favoriteType, title, maxSlots, formatFunc)
    local favorites = HTTT.Core.EnsureFavorites(favoriteType)
    
    d(HTTT.Core.PREFIX .. title)
    for i = 1, maxSlots do
        local entry = favorites[i]
        if entry then
            d(formatFunc(i, entry))
        else
            d(string.format("%d: (empty)", i))
        end
    end
end