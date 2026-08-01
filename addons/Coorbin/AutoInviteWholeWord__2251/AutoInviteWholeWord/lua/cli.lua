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

AutoInvite = AutoInvite or {}
------------------------------------------------
--- Utility functions
------------------------------------------------
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00" .. msg) end

-- print command usage
AutoInvite.help = function()
    echo(GetString(SI_AUTO_INVITE_SLASHCMD_INFO))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_START))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_REGRP))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_HELP))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_STOP))
    return
end

-- From http://lua-users.org/wiki/SplitJoin
local function ai_cli_split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t,cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
    end
    return t
end

local chatChannels = {
    [0] = "Say",
    [1] = "Yell",
    [2] = "Whisper",
    [3] = "Group",
    [4] = "Outgoing Whisper",
    [5] = "Unused 1",
    [6] = "Emote",
    [7] = "NPC Say",
    [8] = "NPC Yell",
    [9] = "NPC Whisper",
    [10] = "NPC Emote",
    [11] = "System",
    [12] = "Guild 1",
    [13] = "Guild 2",
    [14] = "Guild 3",
    [15] = "Guild 4",
    [16] = "Guild 5",
    [17] = "Officer 1",
    [18] = "Officer 2",
    [19] = "Officer 3",
    [20] = "Officer 4",
    [21] = "Officer 5",
    [22] = "Custom 1",
    [23] = "Custom 2",
    [24] = "Custom 3",
    [25] = "Custom 4",
    [26] = "Custom 5",
    [27] = "Custom 6",
    [28] = "Custom 7",
    [29] = "Custom 8",
    [30] = "Custom 9",
    [31] = "Zone",
    [32] = "Zone Intl 1",
    [33] = "Zone Intl 2",
    [34] = "Zone Intl 3",
    [35] = "Zone Intl 4"
  }

local function generateChatChannelString()
    local builder = ""
    for k,v in pairs(chatChannels) do
        if k >= 1 then
            builder = builder .. ", "
        end
        builder = builder .. k .. " = " .. v
    end
    return builder
end

local chatChannelString = generateChatChannelString()

local function printIgnoreList()
    if AutoInvite.cfg.ignored == nil then
        AutoInvite.cfg.ignored = {}
    end
    if #AutoInvite.cfg.ignored > 0 then
        local build = "Your AutoInvite ignore list is: "
        for i, person in pairs(AutoInvite.cfg.ignored) do
            if i > 1 then
                build = build .. ", "
            end
            build = build .. person
        end
        d(build)
    else
        d("Your AutoInvite ignore list is empty.")
    end
end

--Main interaction switch
SLASH_COMMANDS["/ai"] = function(str)
    if not str or str == "" or str == "help" then
        if not AutoInvite.listening or str == "help" then
            AutoInvite.help()
            return
        end
        echo(GetString(SI_AUTO_INVITE_OFF))
        AutoInvite.disable()
        return
    elseif str == "regrp" then
        AutoInvite:resetGroup()
        return
    end
    AutoInvite.cfg.watchStr = string.lower(str)
    AutoInvite.startListening()

    AutoInviteUI.refresh()
end

SLASH_COMMANDS["/aichan"] = function(str)
    AutoInvite.cfg.allowedChannels = {}
    local answer = "Listening on "
    local chans = ai_cli_split(str, ",")
    for i,chan in ipairs(chans) do
        if i > 1 then 
            answer = answer .. ", "
        end
        local nchan = tonumber(chan)
        if nchan == nil or nchan > 35 or nchan < 0 then 
            d("Invalid channel: " .. chan)
            d("Valid chat channels: " .. chatChannelString)
            d("Now listening on ALL channels.")
            return
        end
        table.insert(AutoInvite.cfg.allowedChannels, chan)
        answer = answer .. chatChannels[nchan]
    end
    if #AutoInvite.cfg.allowedChannels == 0 then
        d("Listening on ALL channels. If you want to only listen on specific channels, supply a comma-separated list of channel numbers to listen on.")
        d("Valid chat channels: " .. chatChannelString)
    else
        d(answer)
    end
end

SLASH_COMMANDS["/aignadd"] = function(str)
    if AutoInvite.cfg.ignored == nil then
        AutoInvite.cfg.ignored = {}
    end
    table.insert(AutoInvite.cfg.ignored, str)
    printIgnoreList()
end

SLASH_COMMANDS["/aignrem"] = function(str)
    if AutoInvite.cfg.ignored == nil then
        AutoInvite.cfg.ignored = {}
    end
    local keyToRemove = nil
    str = string.lower(str)
    for k,v in pairs(AutoInvite.cfg.ignored) do
        local lv = string.lower(v)
        if lv == str or "@" .. lv == str then
            keyToRemove = k
        end
    end
    if keyToRemove ~= nil then
        table.remove(AutoInvite.cfg.ignored, keyToRemove)
        d("Removed '" .. str .. "' from the AutoInvite ignore list.")
    else
        d("Didn't find a '" .. str .. "' to remove from the AutoInvite ignore list!")
    end
    printIgnoreList()
end

SLASH_COMMANDS["/aignclear"] = function(str)
    AutoInvite.cfg.ignored = {}
    d("Cleared your AutoInvite ignore list!")
    printIgnoreList()
end

-- Debug commands
SLASH_COMMANDS["/aidebug"] = function()
    echo("|cFF0000Beginning debug mode for AutoInvite.")
    AutoInvite.debug = true
    echo("Enabled? " .. b(AutoInvite.enabled) .. " / Listening? " .. b(AutoInvite.listening))
end

SLASH_COMMANDS["/airesponse"] = function()
    EVENT_MANAGER:RegisterForEvent(AutoInvite.AddonId, EVENT_GROUP_INVITE_RESPONSE, AutoInvite.inviteResponse)
end

SLASH_COMMANDS["/airg"] = function()
    AutoInvite:resetGroup()
end
