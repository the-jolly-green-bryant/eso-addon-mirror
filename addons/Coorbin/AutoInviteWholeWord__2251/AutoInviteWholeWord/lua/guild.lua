-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00" .. msg) end

AutoInvite = AutoInvite or {}

function AutoInvite.executeNameLookup(hasChar, charName, zone)
    if not hasChar then
        echo(zo_strformat(GetString(SI_AUTO_INVITE_ERROR_ACCOUNT), charName))
        return ""
    end

    charName = charName:gsub("%^.+", "")
    if AutoInvite.cfg.cyrCheck then
        dbg("In Cyrodiil? " .. b(AutoInvite.isCyrodiil()) .. " / Zone: " .. zone)

        if AutoInvite.isCyrodiil() and zone ~= "Cyrodiil" then
            echo(zo_strformat(GetString(SI_AUTO_INVITE_ERROR_ZONE), charName, zone))
            echo(GetString(SI_AUTO_INVITE_INV_BLOCK))
            return ""
        end
    end

    return charName
end

function AutoInvite.guildLookup(guildId, acctName)
    local aName
    for i = 1, GetNumGuildMembers(guildId) do
        aName = GetGuildMemberInfo(guildId, i)
        if aName == acctName then
            return AutoInvite.executeNameLookup(GetGuildMemberCharacterInfo(guildId, i))
        end
    end
end

function AutoInvite.friendLookup(acctName)
    for i = 1, GetNumFriends() do
        local aName = GetFriendInfo(i)
        if aName == acctName then
            return AutoInvite.executeNameLookup(GetFriendCharacterInfo(i))
        end
    end
    return nil
end

function AutoInvite.accountNameLookup(channel, acctName)
    local guildId = 0
    if channel == CHAT_CHANNEL_GUILD_1 or channel == CHAT_CHANNEL_OFFICER_1 then guildId = GetGuildId(1) end
    if channel == CHAT_CHANNEL_GUILD_2 or channel == CHAT_CHANNEL_OFFICER_2 then guildId = GetGuildId(2) end
    if channel == CHAT_CHANNEL_GUILD_3 or channel == CHAT_CHANNEL_OFFICER_3 then guildId = GetGuildId(3) end
    if channel == CHAT_CHANNEL_GUILD_4 or channel == CHAT_CHANNEL_OFFICER_4 then guildId = GetGuildId(4) end
    if channel == CHAT_CHANNEL_GUILD_5 or channel == CHAT_CHANNEL_OFFICER_5 then guildId = GetGuildId(5) end

    if guildId > 0 then
        return AutoInvite.guildLookup(guildId, acctName)
    else
        --Came in on whisper channel, so try friends then move to all guilds
        local charName = AutoInvite.friendLookup(acctName)
        if charName then return charName end

        for i = 1, 5 do
            guildId = GetGuildId(i)
            charName = AutoInvite.guildLookup(guildId, acctName)
            if charName then return charName end
        end

        echo(GetString(SI_AUTO_INVITE_ERROR_INVITE) .. channel)
    end
end
