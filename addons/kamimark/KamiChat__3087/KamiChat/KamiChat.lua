-- KamiChat.lua
-- KamiChat
-- Version 1.0.0
-- Copyright © 2021 by Mark Damon Hughes. All Rights Reserved.
-- License: See BSD License.txt
--
-- Contact: @kamimark in ESO
-- https://mdhughes.tech/eso
-- kamikaze.mark@gmail.com
-- @mdhughes@appdot.net on fediverse

KamiChat = KamiChat or {
	name = "KamiChat",
	version = "1.0.0",
	author = "@kamimark",
	varname = "KamiChatVariables",
	varversion = 1,
	vardefaults = {
		messages = {
			hi = "Hello, everyone!",
			pin = "/s Don't click the pinions, kill the Daedra!",
			bear = "/s Please move your bear off the crafting station.",
		},
	},
}

COLORS = {
	reset = "|r",
	red = "|cFF6666",
	orange = "|cFF6600",
	yellow = "|cFFFF66",
	green = "|c66FF66",
	blue = "|c6666FF",
	purple = "|cFF66FF",
	black = "|c333333",
	gray = "|c999999",
	silver = "|cCCCCCC",
	white = "|cEEEEEE",
}

function KamiChat.splitLine(line)
	local words = {}
	for w in line:gmatch("%S+") do
		table.insert(words, w)
	end
	return words
end

function KamiChat.debugMessage(msgname)
	local msg = KamiChat.vars.messages[msgname]
	d(COLORS.green.. msgname.. COLORS.gray.. " = ".. COLORS.silver.. msg.. COLORS.reset)
end

function KamiChat.showHelp()
	d(COLORS.green.. "Usage: /k list\n"..
	"       ".. COLORS.green.. "/k MSGNAME              Insert message\n"..
	"       ".. COLORS.green.. "/k set MSGNAME TEXT...  Creates a message\n"..
	"       ".. COLORS.green.. "/k clear MSGNAME        Removes a message\n"..
	COLORS.reset)
end

function KamiChat.listMessages(words)
	if #words ~= 1 then
		KamiChat.showHelp()
		return
	end
	for msgname,v in pairs(KamiChat.vars.messages) do
		KamiChat.debugMessage(msgname)
	end
end

function KamiChat.showMessage(words)
	if #words ~= 1 then
		KamiChat.showHelp()
		return
	end
	local msgname = words[1]
	local msg = KamiChat.vars.messages[msgname]
	if msg then
		StartChatInput(msg, CHAT_CHANNEL)
		-- CHAT_SYSTEM.textEntry:InsertLink(msg)
	else
		d(COLORS.red.. "KamiChat: unknown message ".. msgname.. COLORS.reset)
	end
end

function KamiChat.clearMessage(words)
	if #words ~= 2 then
		KamiChat.showHelp()
		return
	end
	local msgname = words[2]
	KamiChat.vars.messages[msgname] = nil
	d(COLORS.green.. "Cleared message ".. msgname.. COLORS.reset)
end

function KamiChat.setMessage(words)
	if #words < 3 then
		KamiChat.showHelp()
		return
	end
	local msgname = words[2]
	local msg = ""
	local i = 3
	local c = words[i]
	-- super sad this doesn't work, I wanted to make sparkly messages.
--	if COLORS[c] then
--		d("c=".. c)
--		msg = COLORS[c]
--		i=i+1
--	end
	while i <= #words do
		msg = msg.. words[i].. " "
		i=i+1
	end
--	if COLORS[c] then
--		msg = msg.. COLORS.reset
--	end
	KamiChat.vars.messages[msgname] = msg
	KamiChat.debugMessage(msgname)
end

function KamiChat.command(line, context)
	local words = KamiChat.splitLine(line)
	if #words == 0 or words[1] == "?" or words[1] == "help" then
		KamiChat.showHelp()
	elseif words[1] == "list" then
		KamiChat.listMessages(words)
	elseif words[1] == "set" then
		KamiChat.setMessage(words)
	elseif words[1] == "clear" then
		KamiChat.clearMessage(words)
	else
		KamiChat.showMessage(words)
	end
end

function KamiChat.init()
	d(COLORS.green.. KamiChat.name.. " v".. KamiChat.version.. " by ".. KamiChat.author.. COLORS.reset)

	KamiChat.vars = ZO_SavedVars:NewAccountWide(KamiChat.varname, KamiChat.varversion, nil, KamiChat.vardefaults)

	SLASH_COMMANDS['/k'] = KamiChat.command
end

function KamiChat.onAddOnLoaded(event, addonName)
	if addonName == KamiChat.name then
		EVENT_MANAGER:UnregisterForEvent(KamiChat.name, EVENT_ADD_ON_LOADED)
		zo_callLater(KamiChat.init, 1000)
	end
end

EVENT_MANAGER:RegisterForEvent(KamiChat.name, EVENT_ADD_ON_LOADED, KamiChat.onAddOnLoaded)
