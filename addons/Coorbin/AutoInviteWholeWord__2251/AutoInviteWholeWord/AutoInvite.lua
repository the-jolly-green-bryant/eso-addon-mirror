-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
-- (C) 2019 Sean McNamara (Coorbin) <smcnam@gmail.com>
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
AutoInvite.AddonId = "AutoInvite"

------------------------------------------------
--- Utility functions
------------------------------------------------
local function b(v) if v then return "T" else return "F" end end
local function nn(val) if val == nil then return "NIL" else return val end end
local function dbg(msg) if AutoInvite.debug then d("|c999999" .. msg) end end
local function echo(msg) CHAT_SYSTEM.primaryContainer.currentBuffer:AddMessage("|CFFFF00" .. msg) end

AutoInvite.isCyrodiil = function(unit)
    if unit == nil then unit = "player" end
    dbg("Current zone: '" .. GetUnitZone(unit) .. "'")
    return GetUnitZone(unit) == "Cyrodiil"
end

local function ai_startsWith(str, start)
   return str:sub(1, #start) == start
end

-- From http://lua-users.org/wiki/SplitJoin
function ai_split(str, pat)
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

-- From https://stackoverflow.com/questions/54510033/match-repeatable-string-as-a-whole-word-in-lua-5-1
-- I am ever grateful to the people who worked hard on that problem, especially Egor Skriptunoff!
function ai_containsWholeWord(input, word)
   return (" "..input:gsub(word:gsub("%%", "%%%%"), "\0").." "):find"%s%p*%z+%p*%s" ~= nil
end

function ai_matches_one(pattern, message)
	message = string.lower(message)
	if ai_startsWith(pattern, "\\!") then
		return message == string.sub(pattern, 2)
	end
	if ai_startsWith(pattern, "!") then
		local tmpWatchStr = string.sub(pattern, 2)
		return message == tmpWatchStr or ai_containsWholeWord(message, tmpWatchStr)
	else
		return message == pattern
	end
end

function ai_matches(pattern, message)
    local eachBar = ai_split(pattern, '|')
    for i, bar in ipairs(eachBar) do
        if ai_matches_one(bar, message) == true then
            return true
        end
    end
    return false
end

------------------------------------------------
--- Event handlers
------------------------------------------------

--Main callback fired on chat message
AutoInvite.callback = function(_, messageType, from, message)
    if not AutoInvite.enabled or not AutoInvite.listening then
        return
    end

    local allowed = true
    if AutoInvite.cfg.allowedChannels ~= nil and #AutoInvite.cfg.allowedChannels > 0 then
        allowed = false
        for k,v in pairs(AutoInvite.cfg.allowedChannels) do
            if tostring(v) == tostring(messageType) then 
                allowed = true
            end
        end
    end
    if allowed == false then
        return
    end

    if from ~= nil and from ~= "" and AutoInvite.cfg.ignored ~= nil and #AutoInvite.cfg.ignored > 0 then
        local lfrom = ai_split(string.lower(from), "^")[1]
        for i, iname in ipairs(AutoInvite.cfg.ignored) do
            local liname = string.lower(iname)
            if liname == lfrom or "@" .. liname == lfrom or "@" .. lfrom == liname then
                return
            end
        end
    end

    --TODO: Move this to the actual invite send so not per-message
    if GetGroupSize() >= AutoInvite.cfg.maxSize then
        echo(GetString(SI_AUTO_INVITE_GROUP_FULL_STOP))
        AutoInvite.stopListening()
    end
		
    if ai_matches(AutoInvite.cfg.watchStr, message) and from ~= nil and from ~= "" then
        if (messageType >= CHAT_CHANNEL_GUILD_1 and messageType <= CHAT_CHANNEL_OFFICER_5) or messageType == CHAT_CHANNEL_WHISPER then
            from = AutoInvite.accountNameLookup(messageType, from)
            if from == "" or from == nil then return end
        else
            
        end

        echo(zo_strformat(GetString(SI_AUTO_INVITE_SEND_TO_USER), from))
        AutoInvite:invitePlayer(from)
    end
    --d("Checking message '" .. string.lower(message) .."' ?= '" .. AutoInvite.cfg.watchStr .."'")
end

--
AutoInvite.playerLeave = function(_, unitTag, connectStatus, isSelf)
    if AutoInvite.enabled and AutoInvite.cfg.restart then
        if not AutoInvite.listening then
            echo(zo_strformat(GetString(SI_AUTO_INVITE_GROUP_OPEN_RESTART), AutoInvite.cfg.watchStr))
        end
        AutoInvite.startListening()
    end

    if isSelf then
        AutoInvite.kickTable = {}
    else
        local unitName = GetUnitName(unitTag):gsub("%^.+", "")
        AutoInvite.kickTable[unitName] = nil
    end
end

AutoInvite.offlineEvent = function(_, unitTag, connectStatus)
    local unitName = GetUnitName(unitTag):gsub("%^.+", "")
    if connectStatus then
        dbg(unitTag .. "/" .. unitName .. " has reconnected")
        AutoInvite.kickTable[unitName] = nil
    else
        dbg(unitTag .. "/" .. unitName .. " has disconnected")
        AutoInvite.kickTable[unitName] = GetTimeStamp()
    end
    MINI_GROUP_LIST:updateSingle(name)
end

-- tick function: called every 1s
function AutoInvite.tick()
    local self = AutoInvite
    self.kickCheck()

    if self.listening then
        if GetGroupSize() >= self.cfg.maxSize then
            self.stopListening()
        else
            self:checkSentInvites()
            self:processQueue()
        end
    end
end

------------------------------------------------
--- Event control
------------------------------------------------
AutoInvite.disable = function()
    AutoInvite.enabled = false
    AutoInvite.stopListening()
    EVENT_MANAGER:UnregisterForUpdate(AutoInvite.AddonId)
    EVENT_MANAGER:UnregisterForEvent(AutoInvite.AddonId, EVENT_GROUP_INVITE_RESPONSE)
end

AutoInvite.stopListening = function()
    EVENT_MANAGER:UnregisterForEvent(AutoInvite.AddonId, EVENT_CHAT_MESSAGE_CHANNEL)
    AutoInvite.listening = false
end

--@param restart: (boolean) - true if restarted listening due to space open up
--currently only used for different print strings
AutoInvite.startListening = function(restart)
    if not AutoInvite.enabled then
        AutoInvite.enabled = true
        AutoInvite.checkOffline()
        EVENT_MANAGER:RegisterForUpdate(AutoInvite.AddonId, 1000, AutoInvite.tick)
        EVENT_MANAGER:RegisterForEvent(AutoInvite.AddonId, EVENT_GROUP_INVITE_RESPONSE, AutoInvite.inviteResponse)
    end

    if not AutoInvite.listening and GetGroupSize() < AutoInvite.cfg.maxSize then
        --Add handler
        EVENT_MANAGER:RegisterForEvent(AutoInvite.AddonId, EVENT_CHAT_MESSAGE_CHANNEL, AutoInvite.callback)
        AutoInvite.listening = true
        if restart ~= nil then
            echo(zo_strformat(GetString(SI_AUTO_INVITE_GROUP_OPEN_RESTART), AutoInvite.cfg.watchStr))
        else
            echo(zo_strformat(GetString(SI_AUTO_INVITE_START_ON), AutoInvite.cfg.watchStr))
        end
    end
	if AutoInvite.cfg.watchStr == "!a" then
		d("AutoInvite WARNING: Are you sure you want to use that pattern? You will be sending invites to people who use the English word 'a' in conversation, which is probably not what you want. AutoInvite is enabled, regardless.")
	end
	if AutoInvite.cfg.watchStr == "!i" then
		d("AutoInvite WARNING: Are you sure you want to use that pattern? You will be sending invites to people who use the English word 'I' in conversation, which is probably not what you want. AutoInvite is enabled, regardless.")
	end
end

------------------------------------------------
--- Initialization
------------------------------------------------
AutoInvite.init = function()
    EVENT_MANAGER:UnregisterForEvent("AutoInviteInit", EVENT_PLAYER_ACTIVATED)
    if AutoInvite.initDone then return end
    AutoInvite.initDone = true

    local def = {
        maxSize = 24,
        restart = false,
        cyrCheck = false,
        autoKick = false,
        kickDelay = 300,
        watchStr = "",
        showPanel = true,
        allowedChannels = {},
        ignored = {}
    }
    AutoInvite.cfg = ZO_SavedVars:NewAccountWide("AutoInviteSettings", 1.0, "config", def)
    EVENT_MANAGER:RegisterForEvent(AutoInvite.AddonId, EVENT_GROUP_MEMBER_LEFT, AutoInvite.playerLeave)
    EVENT_MANAGER:RegisterForEvent(AutoInvite.AddonId, EVENT_GROUP_MEMBER_CONNECTED_STATUS, AutoInvite.offlineEvent)

    --Make sure Offline is updated after player zones (is offline for a bit
    EVENT_MANAGER:RegisterForEvent("AutoInviteInit", EVENT_PLAYER_ACTIVATED, AutoInvite.checkOffline)

    AutoInvite.listening = false
    AutoInvite.enabled = false
    AutoInvite.player = GetUnitName("player")
    AutoInviteUI.init()
end

EVENT_MANAGER:RegisterForEvent("AutoInviteInit", EVENT_PLAYER_ACTIVATED, AutoInvite.init)

