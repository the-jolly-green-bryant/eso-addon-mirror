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

--Main Title (not translated)
ZO_CreateStringId("SI_AUTO_INVITE", "AutoInvite")

--Status messages
ZO_CreateStringId("SI_AUTO_INVITE_NO_GROUP_MESSAGE", "Group is empty")
ZO_CreateStringId("SI_AUTO_INVITE_SEND_TO_USER", "Sending invite to <<1>>")
ZO_CreateStringId("SI_AUTO_INVITE_KICK", "Kicking <<1>> (offline for <<2>>)")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_OPEN_RESTART", "Now space in group. Restarted listening on '<<1>>'")
ZO_CreateStringId("SI_AUTO_INVITE_START_ON", "AutoInvite listening on string '<<1>>'")
ZO_CreateStringId("SI_AUTO_INVITE_STOP", "Stop AutoInvite")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_FULL_STOP", "Group full. Disabling AutoInvite")
ZO_CreateStringId("SI_AUTO_INVITE_OFF", "Disabling AutoInvite")

--Error messages
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ACCOUNT", "Could not find player name for <<1>>. Please manually invite.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ZONE", "Player <<1>> is not in Cyrodiil but in <<2>>")
ZO_CreateStringId("SI_AUTO_INVITE_INV_BLOCK", "Blocking invite to prevent crashes.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_INVITE", "Error - couldn't invite on channel:")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_KICK_TABLE", "No one named <<1>> found in group scan. Please manually kick.")

--Menu
ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENABLED", "Enabled")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENABLED", "Whether to enable AutoInvite")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_STRING", "Invite String")
ZO_CreateStringId("SI_AUTO_INVITE_TT_STRING", "Text to check messages to auto-invite for. If you put a ! at the beginning of the string, match any whole word containing that string.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_MAX_SIZE", "Max group size")
ZO_CreateStringId("SI_AUTO_INVITE_TT_MAX_SIZE", "Maximum number of players to invite to group")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_RESTART", "Restart")
ZO_CreateStringId("SI_AUTO_INVITE_TT_RESTART", "Restart AutoInvite if drop below max")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_CYRCHECK", "Cyrodiil Check")
ZO_CreateStringId("SI_AUTO_INVITE_TT_CYRCHECK", "Only invite players that are in Cyrodiil.\n(This only runs if you are in Cyrodiil yourself.)")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK", "Auto kick")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK", "Kick players that go offline")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK_TIME", "Time before kick")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK_TIME", "Number of seconds to wait before kicking an offline player")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_SLASHCMD", "Slash Commands")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFRESH", "Refresh List")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFORM", "Re-form Group")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REINVITE", "Re-Invite Group")

-- keybind
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REGROUP", "Re-form Group")
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REINVITE", "Re-Invite Group")

--Slash commands
--Note: Don't translate between the color codes  |C ... |r
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_INFO", "AutoInvite - command |CFFFF00/ai <str>|r. Usage:")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_START", "|CFFFF00/ai foo|r - start listening on 'foo'. If you put a ! at the beginning of the string, match any whole word containing that string.")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_STOP", "|CFFFF00/ai|r - turn off AutoInvite")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_REGRP", "|CFFFF00/ai regrp|r - Re-form Group")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_HELP", "|CFFFF00/ai help|r - show this help menu")

--Templates for using in code (reference):
--ZO_CreateStringId("SI_AUTO_INVITE_", )
--GetString(SI_AUTO_INVITE...)
--zo_strformat(GetString(SI_AUTO_INVITE_...), param1, param2))
