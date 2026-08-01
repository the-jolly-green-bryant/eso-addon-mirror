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
local function echo(msg) CHAT_ROUTER:AddSystemMessage("|CFFFFFF[AutoInvite] |r|CFFFF00" .. msg) end

-- print command usage
AutoInvite.help = function()
    echo(GetString(SI_AUTO_INVITE_SLASHCMD_INFO))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_START))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_REGRP))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_HELP))
    echo("  " .. GetString(SI_AUTO_INVITE_SLASHCMD_STOP))
    return
end

--Main interaction switch
SLASH_COMMANDS["/ai"] = function(str)
    if not str or str == "" or str == "help" then
        if not AutoInvite.listening or str == "help" then
            AutoInvite.help()
            return
        end
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
