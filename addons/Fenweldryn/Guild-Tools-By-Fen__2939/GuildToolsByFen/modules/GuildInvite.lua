GuildToolsByFenInternals.GuildInvite = {}
local _GuildInvite = GuildToolsByFenInternals.GuildInvite

function _GuildInvite.addMenuItem(playerName, rawName)    
    guildsSubMenu = {}
    for i = 1, GetNumGuilds() do        
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        guildsSubMenu[i] = {
            label = guildName,
            callback = function() 
                GuildInvite(guildId, playerName)
            end,
            itemType = MENU_ADD_OPTION_LABEL,
            tooltip = "Invite " .. playerName .. ' to ' .. guildName,
        }
    end
    AddCustomSubMenuItem("Invite to Guild", guildsSubMenu)
end

LibCustomMenu:RegisterPlayerContextMenu(_GuildInvite.addMenuItem)
