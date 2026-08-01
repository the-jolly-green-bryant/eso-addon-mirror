--[[
================================================================================
 HTTT Commands Module
 Contains command handling and user interface interaction via slash commands
 
 This module provides:
 - Slash command registration and parsing
 - Command dispatch to appropriate functional modules
 - User help and documentation via in-game chat
 - Pattern matching for command variants
================================================================================
]]--

HTTT = HTTT or {}
HTTT.Commands = {}

-- Show help text with all available commands
-- @ usage HTTT.Commands.ShowTpHelp()
function HTTT.Commands.ShowTpHelp()
    d(HTTT.Core.PREFIX .. "Usage:")
    d("/tp — Smart teleport to a wayshrine in your current zone, if no users are in your zone, you will be teleported to the latest dlc zone in which a friend is located.")
    d("/tp <zone> — Smart fuzzy-matched city/zone travel.")
    d("/tp home — Port to your primary home (inside).")
    d("/tp outsidehome — Port to your primary home (outside).")
    d("/tp favoritefriendhouse# — Port to favorite friend house slot #. Example: /tp favoritefriendhouse1")
    d("/tp setfavoritefriendhouse <slot> @AccountName [/nickname Custom Name] — Set favorite friend house slot.")
    d("/tp favoritezone# — Port to favorite zone slot #. Example: /tp favoritezone1")
    d("/tp setfavoritezone <slot> <zone name or id> — Set favorite zone slot.")
    d("/tp favoritefriend# — Travel to favorite friend slot #. Example: /tp favoritefriend1")
    d("/tp setfavoritefriend <slot> @AccountName [/nickname Custom Name] — Set favorite friend slot.")
    d("/tp listfavoritefriendhouses — List favorite friend house slots.")
    d("/tp listfavoritezones — List favorite zone slots.")
    d("/tp listfavoritefriends — List favorite friend slots.")
    d("/tp @AccountName — Travel directly to a friend/guild member by account name.")
    d("/tp debug on|off — Toggle debug messages for smart teleport.")
end

-- Command dispatch table for simple exact matches
-- Maps command strings to handler functions
-- @ usage local handler = HTTT.Commands.HANDLERS["debug on"]
HTTT.Commands.HANDLERS = {
    -- Simple commands (exact match)
    ["listfavoritefriendhouses"] = function() HTTT.Favorites.ListFavoriteFriendHouses() end,
    ["listfavoritezones"] = function() HTTT.Favorites.ListFavoriteZones() end,
    ["listfavoritefriends"] = function() HTTT.Favorites.ListFavoriteFriends() end,
    ["debug on"] = function() HTTT.Core.SetSmartTeleportDebug(true); d(HTTT.Core.PREFIX .. "Debug mode enabled") end,
    ["debug off"] = function() HTTT.Core.SetSmartTeleportDebug(false); d(HTTT.Core.PREFIX .. "Debug mode disabled") end,
}

-- Initialize commands module
-- Registers slash commands and sets up command handlers
-- @ return nil
function HTTT.Commands.Initialize()
    -- Register the /tp slash command
    SLASH_COMMANDS["/tp"] = function(param)
        param = zo_strtrim(param or "")
        local lower = param:lower()
        
        -- Quick checks for most common commands first (optimization)
        if lower == "" then 
            HTTT.Teleport.FreeTeleportToPriorityWayshrine()
            return
        elseif lower == "home" then
            HTTT.Teleport.JumpToPrimaryHome(false)
            return
        elseif lower == "outsidehome" then
            HTTT.Teleport.JumpToPrimaryHome(true)
            return
        elseif lower == "help" then
            HTTT.Commands.ShowTpHelp()
            return
        end
        
        -- Check other exact matches in the handlers table
        local handler = HTTT.Commands.HANDLERS[lower]
        if handler then
            handler()
            return
        end
        
        -- Check specific set commands in order of specificity
        -- 1. Check setfavoritefriendhouse (most specific)
        if lower:match("^setfavoritefriendhouse%s+%d+%s+@") then
            local slot, rest = lower:match("^setfavoritefriendhouse%s+(%d+)%s+(.*)$")
            slot = tonumber(slot)
            if slot and rest and rest ~= "" then
                HTTT.Favorites.SetFavoriteFriendHouse(slot, rest)
            else
                d(HTTT.Core.PREFIX .. "Usage: /tp setfavoritefriendhouse <slot> @AccountName [/nickname Custom Name]")
            end
            return
        end
        
        -- 2. Check setfavoritezone
        if lower:match("^setfavoritezone%s+%d+%s+") then
            local slot, rest = lower:match("^setfavoritezone%s+(%d+)%s+(.*)$")
            slot = tonumber(slot)
            if slot and rest and rest ~= "" then
                HTTT.Favorites.SetFavoriteZone(slot, rest)
            else
                d(HTTT.Core.PREFIX .. "Usage: /tp setfavoritezone <slot> <zone name or id>")
            end
            return
        end
        
        -- 3. Check setfavoritefriend (least specific of the three)
        if lower:match("^setfavoritefriend%s+%d+%s+@") then
            local slot, rest = lower:match("^setfavoritefriend%s+(%d+)%s+(.*)$")
            slot = tonumber(slot)
            if slot and rest and rest ~= "" then
                HTTT.Favorites.SetFavoriteFriend(slot, rest)
            else
                d(HTTT.Core.PREFIX .. "Usage: /tp setfavoritefriend <slot> @AccountName [/nickname Custom Name]")
            end
            return
        end
        
        -- Also support commands without spaces like "setfavoritefriendhouse1"
        local setCmd, slotStr, rest
        
        -- Check for no-space versions of set commands
        setCmd, slotStr, rest = lower:match("^(setfavoritefriendhouse)(%d+)%s*(.*)$")
        if setCmd and slotStr then
            local slot = tonumber(slotStr)
            if slot and rest and rest ~= "" then
                HTTT.Favorites.SetFavoriteFriendHouse(slot, rest)
            else
                d(HTTT.Core.PREFIX .. "Usage: /tp setfavoritefriendhouse <slot> @AccountName [/nickname Custom Name]")
            end
            return
        end
        
        setCmd, slotStr, rest = lower:match("^(setfavoritezone)(%d+)%s*(.*)$")
        if setCmd and slotStr then
            local slot = tonumber(slotStr)
            if slot and rest and rest ~= "" then
                HTTT.Favorites.SetFavoriteZone(slot, rest)
            else
                d(HTTT.Core.PREFIX .. "Usage: /tp setfavoritezone <slot> <zone name or id>")
            end
            return
        end
        
        setCmd, slotStr, rest = lower:match("^(setfavoritefriend)(%d+)%s*(.*)$")
        if setCmd and slotStr then
            local slot = tonumber(slotStr)
            if slot and rest and rest ~= "" then
                HTTT.Favorites.SetFavoriteFriend(slot, rest)
            else
                d(HTTT.Core.PREFIX .. "Usage: /tp setfavoritefriend <slot> @AccountName [/nickname Custom Name]")
            end
            return
        end
        
        -- Optimized check for favorite commands (common patterns)
        local cmdType, slotNum = lower:match("^(favoritefriendhouse|favoritezone|favoritefriend)(%d+)$")
        if cmdType and slotNum then
            local slot = tonumber(slotNum)
            if slot then
                if cmdType == "favoritefriendhouse" then
                    HTTT.Favorites.PortToFavoriteFriendHouse(slot)
                elseif cmdType == "favoritezone" then
                    HTTT.Favorites.PortToFavoriteZone(slot)
                elseif cmdType == "favoritefriend" then
                    HTTT.Favorites.PortToFavoriteFriend(slot)
                end
                return
            end
        end
        
        -- Check @AccountName pattern directly (optimization)
        if lower:match("^@[%w%._-]+$") then
            HTTT.Teleport.PortToUser(param:match("^(@[%w%._-]+)"))
            return
        end
        
        -- Handle zone teleport as fallback
        local zoneId = HTTT.Teleport.ResolveZoneId(param)
        if zoneId and zoneId ~= 0 then
            local zoneName = GetZoneNameById(zoneId) or param
            local myDisplayName = GetDisplayName()
            local found = HTTT.Teleport.FindTeleportTargetInZone(zoneId, myDisplayName)
            if not found then
                d(HTTT.Core.PREFIX .. string.format("No friends or guild members found in %s.", zoneName))
            end
            return
        end
        
        d(HTTT.Core.PREFIX .. "Invalid command or zone name. Try '/tp help' for usage.")
    end
end