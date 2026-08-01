--[[
Copyright 2018-2019 Sean McNamara <smcnam@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local LAM = LibStub("LibAddonMenu-2.0")
local LSC = LibStub("LibSlashCommander")
local LD = LibStub("LibDialog")
local gmnt_name = "GuildMemberNoteTemplate"
local gmnt_savedVarsName = "GuildMemberNoteTemplateDB"
local gmnt_guildIndexes = {}
local gmnt_guildNames = {}
local gmnt_numTemplates = 10
local gmnt_playerName = GetUnitName("player")
local gmnt_playerAt = GetUnitDisplayName("player")
local gmnt_requestData = {
	player = "",
	gid = "",
	note = "",
	args = {},
}
local gmnt_panelData = {
	type = "panel",
	name = gmnt_name,
	displayName = gmnt_name,
	author = "@Coorbin",
	version = "1.0",
	slashCommand = "/gmntset",
	registerForRefresh = false,
	registerForDefaults = false,
	website = "https://github.com/allquixotic/ESOGuildMemberNoteTemplateAddon",
}
local gmnt_optionsData = {}
local gmnt_savedVariables = {}

local function gmnt_yo()
	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(gmnt_savedVarsName)
end

local function gmnt_divineConclaveTemplates()
	gmnt_savedVariables.templates = {
		[1] = {
				guild = "The Divine Conclave",
				text = "$DATE $SELFAT\nNEEDS APPLICATION\nCharacter Name:\r $1\nPath: (Undecided) / Order: (Undecided)  / Sect: (Undecided) \r\nForum name:",
			},
		[2] = {
				guild = "The Divine Conclave",
				text = "$DATE $1\nNEEDS APPLICATION\nCharacter Name:\r $2\nPath: (Undecided) / Order: (Undecided)  / Sect: (Undecided) \r\nForum name:",
			},
		[3] = {
				guild = "The Divine Conclave",
				text = "$1 $2\nNEEDS APPLICATION\nCharacter Name:\r $3\nPath: (Undecided) / Order: (Undecided)  / Sect: (Undecided) \r\nForum name:",
			},
		[4] = {
				guild="The Divine Conclave",
				text="$1's Disciple\nCharacter Name: $2\nPath (Undecided) / Order (Undecided) / Sect (Undecided)\nForum name: $3"
			},
		[5]={guild="", text=""},
		[6]={guild="", text=""},
		[7]={guild="", text=""},
		[8]={guild="", text=""},
		[9]={guild="", text=""},
		[10]={guild="", text=""},
	}
	gmnt_yo()
	d("GMNT: Replaced your templates with Divine Conclave's.")
end

local function gmnt_showConclaveDialog()
	LD.dialogs[gmnt_name] = {}
	LD:RegisterDialog(gmnt_name, "GMNTConclave", "GMNT Conclave", "Are you SURE you want to wipe out your templates and replace them with ones used in The Divine Conclave?", gmnt_divineConclaveTemplates, nil, nil)
	LD:ShowDialog(gmnt_name, "GMNTConclave", nil)
end

local function gmnt_genDefaultTemplatesObject(howMany)
	retval = {}
	for i = 1, howMany do
		table.insert(retval, { guild = "", text = ""})
	end
	return retval
end
local gmnt_defaultVars = {
	templates = gmnt_genDefaultTemplatesObject(gmnt_numTemplates),
}

local function gmnt_split(text)
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

local function gmnt_updateGuildInfo()
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		local gid = GetGuildName(GetGuildId(i))
		gmnt_guildIndexes[gid] = i
		gmnt_guildNames[i] = gid
	end
end

local function gmnt_getPlayerGuildIndexes(atHandle, guildName)
	local idx = gmnt_guildIndexes[guildName]
	local n = GetNumGuildMembers(idx)
	for i=1,n do
		local name,note,rankIndex,playerStatus,secsSinceLogoff = GetGuildMemberInfo(idx,i)
		local hasChar, character = GetGuildMemberCharacterInfo(idx, i)
		if not hasChar then character = "" end
		if name == atHandle then 
			return {
				memberId = i,
				guildId = idx,
				charName = character
			} 
		end
	end
	return {
		memberId = -1,
		guildId = -1,
		charName = ""
	}
end

local function gmnt_interp(noteTemplate)
	local currentDate = GetDateStringFromTimestamp(GetTimeStamp())
	local curr = (noteTemplate:gsub("%$DATE", currentDate):gsub("%$SELFCHAR", gmnt_playerName):gsub("%$THEMAT", gmnt_requestData.player))
	local metadata = gmnt_getPlayerGuildIndexes(gmnt_requestData.player, gmnt_requestData.gid)
	curr = (curr:gsub("%$SELFAT", gmnt_playerAt):gsub("%$THEMCHAR", metadata.charName))
	local c = 0
	-- d("First: " .. curr)
	-- d("args: ")
	for k,v in pairs(gmnt_requestData.args) do 
		c = c + 1 
		if v == nil or v == "nil" then v = "" end
		curr = (curr:gsub("%$" .. tostring(c), v))
		-- d("arg: " .. tostring(k) .. "=" .. tostring(v))
	end
	-- d("Before: " .. curr)
	for i=50,1,-1 do
		curr = curr:gsub("%$" .. tostring(i), "")
	end
	-- d("After: " .. curr)

	return curr
end

local function gmnt_resetRequest()
	gmnt_requestData = {player="", gid="", note="", args={}}
end

local function gmnt_updateNote()
	local idxs = gmnt_getPlayerGuildIndexes(gmnt_requestData.player, gmnt_requestData.gid)
	if idxs.memberId == -1 or idxs.guildId == -1 then
		d("GMNT ERROR: Player " .. gmnt_requestData.player .. " does not exist in " .. gmnt_requestData.gid .. "! Taking no action." )
		gmnt_resetRequest()
		return false
	end
	SetGuildMemberNote(idxs.guildId, idxs.memberId, gmnt_requestData.note)
	d("GMNT: Successfully applied a new note to " .. gmnt_requestData.player .. " in " .. gmnt_requestData.gid .. ".")
	gmnt_resetRequest()
	return true
end

local function gmnt_dialogNo()
	gmnt_resetRequest()
end

local function gmnt_showDialog()
	LD.dialogs[gmnt_name] = {}
	LD:RegisterDialog(gmnt_name, "GMNTConfirm", "GMNT Confirm", "Are you SURE you want to set the note for " .. gmnt_requestData.player .. " in " .. gmnt_requestData.gid .. " to\n\n" .. gmnt_requestData.note .. "\n\n?", gmnt_updateNote, gmnt_dialogNo, nil)
	LD:ShowDialog(gmnt_name, "GMNTConfirm", nil)
end

local function gmnt_printHelp()
	d("/gmnt - Guild Member Note Template")
	d(" Usage: <index> <@handle> [arguments...]")
	d("  index: REQUIRED. The 1-based number corresponding to the template to apply (see addon settings)")
	d("  @handle: REQUIRED. The @handle (including '@') for the member to set a guild note for")
	d("  arguments: OPTIONAL. A space-delimited list of arguments to apply to the template")
	d(" See the addon settings pane for help designing templates")
end

local function gmnt_commandCb(data)
	local parze = gmnt_split(data)
	if parze[1] == "help" then 
		gmnt_printHelp()
	else
		gmnt_requestData.player = parze[2]
		local templateIdx = tonumber(parze[1])
		gmnt_requestData.note = gmnt_savedVariables.templates[templateIdx].text
		gmnt_requestData.gid = gmnt_savedVariables.templates[templateIdx].guild
		local i = 0
		for k,v in pairs(parze) do
			i = i + 1
			if i >= 3 then
				table.insert(gmnt_requestData.args, v)
			end
		end
		gmnt_requestData.note = gmnt_interp(gmnt_requestData.note)
		gmnt_showDialog()
	end
end

local function gmnt_generateOptionsData()

	for i = 1, gmnt_numTemplates do
		table.insert(gmnt_optionsData, {
			type = "header",
			name = "Note Template #" .. tostring(i),
		})

		table.insert(gmnt_optionsData, {
			type = "dropdown",
			name = "Guild for NT#" .. tostring(i),
			choices = gmnt_guildNames,
			getFunc = function() 
				return gmnt_savedVariables.templates[i].guild 
			end,
			setFunc = function(var) 
				gmnt_savedVariables.templates[i].guild = var
				gmnt_yo()
			end,
			tooltip = "Select the guild for whom the note will be applied",
			default = "",
		})

		table.insert(gmnt_optionsData, {
			type = "editbox",
			name = "Template for NT#" .. tostring(i),
			tooltip = "The note template itself",
			getFunc = function() 
				return gmnt_savedVariables.templates[i].text
			end,
			setFunc = function(var)
				gmnt_savedVariables.templates[i].text = var
				gmnt_yo()
			end,
			default = "",
			isExtraWide = true,
			isMultiline = true,
			width = "full",

		})
	end
end

local function gmnt_OnAddOnLoaded(event, addonName)
	if addonName == gmnt_name then
		gmnt_savedVariables = ZO_SavedVars:NewAccountWide(gmnt_savedVarsName, 15, nil, gmnt_defaultVars)
		gmnt_updateGuildInfo()
		LAM:RegisterAddonPanel(addonName, gmnt_panelData)
		gmnt_generateOptionsData()
		LAM:RegisterOptionControls(addonName, gmnt_optionsData)	
		gmnt_yo()
		LSC:Register("/gmnt", gmnt_commandCb, "Type /gmnt help for help")
		LSC:Register("/gmntconclave", gmnt_showConclaveDialog, "Set templates to Divine Conclave presets.")
		EVENT_MANAGER:UnregisterForEvent(gmnt_name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(gmnt_name, EVENT_ADD_ON_LOADED, gmnt_OnAddOnLoaded)