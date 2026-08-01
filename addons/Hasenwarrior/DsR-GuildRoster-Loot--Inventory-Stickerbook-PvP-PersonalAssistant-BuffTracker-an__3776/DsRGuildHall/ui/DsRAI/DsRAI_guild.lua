local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if DsRAutoINV.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFF00" .. msg) end

DsRAutoINV = DsRAutoINV or {}

function DsRAutoINV.executeNameLookup(hasChar, charName, zone, acctName)
    if not hasChar then
        echo(zo_strformat(GetString(SI_DsRAI_ERROR_ACCOUNT), charName))
        return ""
    end

    charName = charName:gsub("%^.+", "")
    if DsRAutoINV.cfg.cyrCheck then
        if DsRAutoINV.isCyrodiil() and zone ~= "Cyrodiil" then
            echo(zo_strformat(GetString(SI_DsRAI_ERROR_ZONE), charName, zone))
            echo(GetString(SI_DsRAI_INV_BLOCK))
            return ""
        end
    end
    return charName
end

function DsRAutoINV.guildLookup(guildId, acctName)
    local aName
    for i = 1, GetNumGuildMembers(guildId) do
        aName = GetGuildMemberInfo(guildId, i)
        if aName == acctName then
            return DsRAutoINV.executeNameLookup(GetGuildMemberCharacterInfo(guildId, i),acctName)
        end
    end
end

function DsRAutoINV.friendLookup(acctName)
    for i = 1, GetNumFriends() do
        local aName = GetFriendInfo(i)
        if aName == acctName then
            return DsRAutoINV.executeNameLookup(GetFriendCharacterInfo(i))
        end
    end
    return nil
end

function DsRAutoINV.accountNameLookup(channel, acctName)
    local guildId = 0
    if channel == CHAT_CHANNEL_GUILD_1 or channel == CHAT_CHANNEL_OFFICER_1 then guildId = GetGuildId(1) end
    if channel == CHAT_CHANNEL_GUILD_2 or channel == CHAT_CHANNEL_OFFICER_2 then guildId = GetGuildId(2) end
    if channel == CHAT_CHANNEL_GUILD_3 or channel == CHAT_CHANNEL_OFFICER_3 then guildId = GetGuildId(3) end
    if channel == CHAT_CHANNEL_GUILD_4 or channel == CHAT_CHANNEL_OFFICER_4 then guildId = GetGuildId(4) end
    if channel == CHAT_CHANNEL_GUILD_5 or channel == CHAT_CHANNEL_OFFICER_5 then guildId = GetGuildId(5) end

    if guildId > 0 then
        return DsRAutoINV.guildLookup(guildId, acctName)
    else
        --Came in on whisper channel, so try friends then move to all guilds
        local charName = DsRAutoINV.friendLookup(acctName)
        if charName then return charName end

        for i = 1, 5 do
            guildId = GetGuildId(i)
            charName = DsRAutoINV.guildLookup(guildId, acctName)
            if charName then return charName end
        end

        echo(GetString(SI_DsRAI_ERROR_INVITE) .. channel)
    end
end
