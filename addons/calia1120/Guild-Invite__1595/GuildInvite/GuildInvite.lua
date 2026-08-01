-- GuildInvite    
    
    local isDebug = false
     
    local function AddPlayerToGuild(name, guildid, guildname)
        d(zo_strformat(GINV_GUILDINVITED, name, guildname))
        GuildInvite(guildid, name)
    end
     
    local function ManualInvite(option)
        local options = {}
        local searchResult = { zo_strmatch(option, "^(%S+)%s?(.*)") }
        for i,v in ipairs(searchResult) do
            if (v ~= nil and v ~= "") then
                options[i] = zo_strlower(v)
            end
        end
            if #options == 0 or options[1] == "help" then
            d(GetString(GINV_HELP))
            d("/ginv debug")
        elseif options[1] == "debug" then
            isDebug = not isDebug
            d("Debugging " .. (isDebug and "|c00FF00on|r" or "|cFF0000off|r"))
        else
            local gid = GetGuildId(options[2])
            local guildName = GetGuildName(gid)
            AddPlayerToGuild(options[1], gid, guildName)
        end
    end
     
    local ShowPlayerContextMenu = CHAT_SYSTEM.ShowPlayerContextMenu
    CHAT_SYSTEM.ShowPlayerContextMenu = function(self, name, rawName, ...)
        ShowPlayerContextMenu(self, name, rawName, ...)
        if isDebug then
            d(zo_strjoin(nil, "Name: |cFFFFFF", name, "|r RawName: |cFFFFFF", rawName, "|r"))
        end
     
        for i = 1, GetNumGuilds() do
            local gid = GetGuildId(i)
            if DoesPlayerHaveGuildPermission(gid, GUILD_PERMISSION_INVITE) then
                local guildName = GetGuildName(gid)
                AddMenuItem(zo_strformat(GINV_GUILDINVITE, guildName), function() AddPlayerToGuild(name, gid, guildName) end)
            end
        end
        if ZO_Menu_GetNumMenuItems() > 0 then
            ShowMenu()
        end
    end
     
    SLASH_COMMANDS["/ginv"] = ManualInvite