--[[
Copyright 2018 Sean McNamara <smcnam@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local LAM = LibStub("LibAddonMenu-2.0")
local LSC = LibStub("LibSlashCommander")
local pq_name = "PlayerQueue"
local pq_savedVarsName = "PlayerQueueDB"
local pq_guildIndexes = {}
local pq_guildNames = {}
local pq_numTemplates = 10
local pq_playerName = GetUnitName("player")
local pq_playerAt = GetUnitDisplayName("player")
local pq_queue = {
	
}
local pq_panelData = {
	type = "panel",
	name = pq_name,
	displayName = pq_name,
	author = "@Coorbin",
	version = "1.0",
	slashCommand = "/pqset",
	registerForRefresh = false,
	registerForDefaults = false,
	website = "https://github.com/allquixotic/ESOPlayerQueueAddon",
}
local pq_optionsData = {}
local pq_savedVariables = {}
local pq_defaultVars = {
	guildMonitors = {},
	sayMonitor = false,
	emoteMonitor = false,
	groupMonitor = true,
	zoneMonitor = false,
	whisperMonitor = true,
	enabled = true
}

local function pq_getQueue()
	local retval = ""
	for k, v in pairs(pq_queue) do
		if retval == "" then
			retval = v.charName .. v.handle
		else
			retval = retval .. " > " .. v.charName .. v.handle
		end
	end
	return retval
end

local function pq_yo()
	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(pq_savedVarsName)
end

local function pq_updateGuildInfo()
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		local gid = GetGuildName(GetGuildId(i))
		pq_guildIndexes[gid] = i
		pq_guildNames[i] = gid
	end
end

function pq_cleanName(name) return name:gsub('%^.*', '') end 

local function pq_findCharOrHandle(atHandle)
	local numGuilds = GetNumGuilds()
	local theFind = nil
	for idx = 1, numGuilds do
		local n = GetNumGuildMembers(idx)
		for i=1,n do
			local name,note,rankIndex,playerStatus,secsSinceLogoff = GetGuildMemberInfo(idx,i)
			local lname = string.lower(name)
			local latHandle = string.lower(atHandle)
			local hasChar, character, ta, tb, tc, td, te, tf = GetGuildMemberCharacterInfo(idx, i)
			character = pq_cleanName(character)
			if not hasChar then character = "" end
			local lcharacter = string.lower(character)
			local pee = string.find(lcharacter, latHandle, 1, true)
			if lname == latHandle or ("@" .. lname) == latHandle then 
				return {
					memberId = i,
					guildId = idx,
					charName = character,
					handle = name,
					ambiguous = false
				}
			elseif pee ~= nil then
				if theFind == nil then
					theFind = {
						memberId = i,
						guildId = idx,
						charName = character,
						handle = name,
						ambiguous = false
					}
				else
					if theFind.handle ~= name then
						theFind.ambiguous = true
						return theFind
					end
				end
			end
		end
	end
	if theFind == nil then
		return {
			memberId = -1,
			guildId = -1,
			charName = "",
			handle = "",
			ambiguous = false
		}
	else
		return theFind
	end
end

local function nq_printHelp()
	d("/nq - Enqueue someone into your player queue")
	d(" Usage: <@handle/Char Name>")
	d("  @handle/Char Name: REQUIRED. The @handle or (partial) character name for the person to enqueue")
end

local function qf_printHelp()
	d("/qf - Put someone at the FRONT of your player queue")
	d(" Usage: <@handle/Char Name>")
	d("  @handle/Char Name: REQUIRED. The @handle or (partial) character name for the person to put at the FRONT of the queue")
end

local function dq_printHelp()
	d("/dq - Dequeue (remove) someone from your player queue")
	d(" Usage: <@handle/Char Name>")
	d("  @handle/Char Name: REQUIRED. The @handle or (partial) character name for the person to dequeue")
end

local function pq_nqCb(data)
	if data == "help" then 
		nq_printHelp()
	else
		local charInfo = pq_findCharOrHandle(data)
		if charInfo.ambiguous == true then
			d("Ambiguous character name! Please use the @handle instead.")
			return nil
		elseif charInfo.memberId == -1 then
			d("Didn't find anyone in any of your guilds with @handle or character name of '" .. data .. "'.")
			return nil
		else
			table.insert(pq_queue, charInfo)
			d("Added " .. charInfo.charName .. charInfo.handle .. " to the queue.")
			d("Queue: " .. pq_getQueue())
		end
	end
end

local function pq_qfCb(data)
	if data == "help" then 
		qf_printHelp()
	else
		local charInfo = pq_findCharOrHandle(data)
		if charInfo.ambiguous == true then
			d("Ambiguous character name! Please use the @handle instead.")
			return nil
		elseif charInfo.memberId == -1 then
			d("Didn't find anyone in any of your guilds with @handle or character name of '" .. data .. "'.")
			return nil
		else
			table.insert(pq_queue, 1, charInfo)
			d("Prepended " .. charInfo.charName .. charInfo.handle .. " to the queue.")
			d("Queue: " .. pq_getQueue())
		end
	end
end

local function pq_dqCb(data)
	if data == "help" then 
		dq_printHelp()
	else
		local ldata = string.lower(data)
		local keyToRemove = nil
		local valueRemoved = nil
		for k, v in pairs(pq_queue) do
			local lhandle = string.lower(v.handle)
			local lcharName = string.lower(v.charName)
			if ldata == lhandle or ("@" .. ldata) == lhandle or string.find(lcharName, ldata, 1, true) then
				keyToRemove = k
				valueRemoved = v
			end
		end
		if keyToRemove ~= nil then
			table.remove(pq_queue, keyToRemove)
			d("Removed " .. valueRemoved.charName .. valueRemoved.handle .. " from the queue.")
			d("Queue: " .. pq_getQueue())
		end
	end
end

local function pq_getqCb(data)
	local theq = pq_getQueue()
	if theq == "" or theq == nil then theq = "(Queue is Empty)" end
	ZO_ChatWindowTextEntryEditBox:SetText(theq)
end

local function pq_printqCb(data)
	local theq = pq_getQueue()
	if theq == "" or theq == nil then theq = "(Queue is Empty)" end
	d(theq)
end

local function pq_cqCb(data)
	pq_queue = {}
	pq_printqCb(data)
end

local function pq_copyqCb(data)
	local theq = pq_getQueue()
	if theq == "" or theq == nil then theq = "(Queue is Empty)" end
	ZO_ChatWindowTextEntryEditBox:SetText(theq)
end

local function pq_generateOptionsData()
	table.insert(pq_optionsData, {
		type = "checkbox",
		name = "Enabled",
		tooltip = "Whether to process queue commands or not.",
		getFunc = function()
			return pq_savedVariables.enabled == true
		end,
		setFunc = function(var)
			pq_savedVariables.enabled = var
			pq_yo()
		end
	})
	local numGuilds = GetNumGuilds()
	for idx = 1, numGuilds do
		local gn = pq_guildNames[idx]
		table.insert(pq_optionsData, {
			type = "checkbox",
			name = "Monitor " .. gn,
			tooltip = "Monitor " .. gn .. " guild chat for queue commands?",
			getFunc = function()
				return pq_savedVariables.guildMonitors[idx] == true
			end,
			setFunc = function(var)
				pq_savedVariables.guildMonitors[idx] = var
				pq_yo()
			end
		})
	end
	table.insert(pq_optionsData, {
		type = "checkbox",
		name = "Monitor /say",
		tooltip = "Monitor /say and /yell chat for commands?",
		getFunc = function()
			return pq_savedVariables.sayMonitor == true
		end,
		setFunc = function(var)
			pq_savedVariables.sayMonitor = var
			pq_yo()
		end
	})
	table.insert(pq_optionsData, {
		type = "checkbox",
		name = "Monitor /e",
		tooltip = "Monitor emote chat for commands?",
		getFunc = function()
			return pq_savedVariables.emoteMonitor == true
		end,
		setFunc = function(var)
			pq_savedVariables.emoteMonitor = var
			pq_yo()
		end
	})
	table.insert(pq_optionsData, {
		type = "checkbox",
		name = "Monitor /group",
		tooltip = "Monitor group chat for commands?",
		getFunc = function()
			return pq_savedVariables.groupMonitor == true
		end,
		setFunc = function(var)
			pq_savedVariables.groupMonitor = var
			pq_yo()
		end
	})
	table.insert(pq_optionsData, {
		type = "checkbox",
		name = "Monitor /zone",
		tooltip = "Monitor zone chat for commands?",
		getFunc = function()
			return pq_savedVariables.zoneMonitor == true
		end,
		setFunc = function(var)
			pq_savedVariables.zoneMonitor = var
			pq_yo()
		end
	})
	table.insert(pq_optionsData, {
		type = "checkbox",
		name = "Monitor whispers",
		tooltip = "Monitor incoming whispers for commands?",
		getFunc = function()
			return pq_savedVariables.whisperMonitor == true
		end,
		setFunc = function(var)
			pq_savedVariables.whisperMonitor = var
			pq_yo()
		end
	})
end

local function pq_trim(s)
	-- from PiL2 20.4
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function pq_split(text)
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	local retval = {}
	for str in text:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then table.insert(retval, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then 
		return { [1] = "Missing matching quote for "..buf } 
	else
		return retval
	end
end

local function pq_starts_with(str, start)
	return str:sub(1, #start) == start
end

local function pq_chatCb(eventCode, messageType, from, message)
	if pq_savedVariables.enabled == true and ((messageType == CHAT_CHANNEL_ZONE and pq_savedVariables.zoneMonitor == true) or
	   ((messageType == CHAT_CHANNEL_SAY or messageType == CHAT_CHANNEL_YELL) and pq_savedVariables.sayMonitor == true) or
	   (messageType == CHAT_CHANNEL_WHISPER and pq_savedVariables.whisperMonitor == true) or
	   (messageType == CHAT_CHANNEL_PARTY and pq_savedVariables.groupMonitor == true) or
	   (messageType == CHAT_CHANNEL_EMOTE and pq_savedVariables.emoteMonitor == true) or
	   (messageType == CHAT_CHANNEL_GUILD_1 and pq_savedVariables.guildMonitors[1] == true) or
	   (messageType == CHAT_CHANNEL_GUILD_2 and pq_savedVariables.guildMonitors[2] == true) or
	   (messageType == CHAT_CHANNEL_GUILD_3 and pq_savedVariables.guildMonitors[3] == true) or
	   (messageType == CHAT_CHANNEL_GUILD_4 and pq_savedVariables.guildMonitors[4] == true) or
	   (messageType == CHAT_CHANNEL_GUILD_5 and pq_savedVariables.guildMonitors[5] == true))
	   then
		local m = pq_trim(string.lower(message))
		if (m == "!q") then
			pq_nqCb(pq_cleanName(from))
		elseif (m == "!dq") then
			pq_dqCb(pq_cleanName(from))
		elseif pq_starts_with(m, "!q ") then
			pq_nqCb(pq_split(m)[2])
		elseif pq_starts_with(m, "!dq ") then
			pq_dqCb(pq_split(m)[2])
		end
	   end
end

local function pq_stfuqCb(data)
	pq_savedVariables.enabled = false
	d("PlayerQueue chat processing is OFF.")
end

local function pq_startqCb(data)
	pq_savedVariables.enabled = true
	d("PlayerQueue chat processing is ON.")
end

local function pq_OnAddOnLoaded(event, addonName)
	if addonName == pq_name then
		pq_savedVariables = ZO_SavedVars:NewAccountWide(pq_savedVarsName, 15, nil, pq_defaultVars)
		if(pq_savedVariables.enabled == true) then 
			d("PlayerQueue chat processing is ON.")
		else
			d("PlayerQueue chat processing is OFF.")
		end
		pq_updateGuildInfo()
		LAM:RegisterAddonPanel(addonName, pq_panelData)
		pq_generateOptionsData()
		LAM:RegisterOptionControls(addonName, pq_optionsData)	
		pq_yo()
		LSC:Register("/nq", pq_nqCb, "Type /nq help for help")
		LSC:Register("/qf", pq_qfCb, "Type /qf help for help")
		LSC:Register("/dq", pq_dqCb, "Type /dq help for help")
		LSC:Register("/cq", pq_cqCb, "Clear player queue")
		LSC:Register("/getq", pq_getqCb, "Print queue to your chat and copy to chat buffer")
		LSC:Register("/printq", pq_printqCb, "Print queue to your chat only")
		LSC:Register("/copyq", pq_copyqCb, "Copy queue into your chat buffer")
		LSC:Register("/stfuq", pq_stfuqCb, "Disable the queue processing functionality")
		LSC:Register("/startq", pq_startqCb, "Enable the queue processing functionality")
		EVENT_MANAGER:RegisterForEvent(pq_name, EVENT_CHAT_MESSAGE_CHANNEL, pq_chatCb)
		EVENT_MANAGER:UnregisterForEvent(pq_name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(pq_name, EVENT_ADD_ON_LOADED, pq_OnAddOnLoaded)