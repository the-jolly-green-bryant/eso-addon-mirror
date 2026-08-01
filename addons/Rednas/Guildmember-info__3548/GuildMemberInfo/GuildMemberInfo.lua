GuildMemberInfo = GuildMemberInfo or {}

GuildMemberInfo.name = "GuildMemberInfo"
GuildMemberInfo.author = "Rednas"
GuildMemberInfo.version = "1.2"
GuildMemberInfo.columns = {}
GuildMemberInfo.guildMembers = {}

GuildMemberInfo.variableVersion = 1
GuildMemberInfo.savedVars = {}
GuildMemberInfo.savedVarsDefaults = {
	["columns"] = {
		["numGuilds"] = true,
		["fullNotes"] = true,
		["immuneTill"] = false
	},
	["jit"] = false
}

GuildMemberInfo.DisplayNames = {}
GuildMemberInfo.DisplayNames["@leandra.c"] = true
GuildMemberInfo.DisplayNames["@rednasd"] = true
GuildMemberInfo.DisplayNames["@bansheevt"] = true
GuildMemberInfo.DisplayNames["@muradinius"] = true
GuildMemberInfo.DisplayNames["@elessar1993"] = true

GuildMemberInfo.immuneTillWord = {"immune","vac","vacation", "holiday", "safe"}

function GuildMemberInfo.GetNumberOfGuilds(name)
	ReturnValue = ""

	if not GuildMemberInfo.savedVars["jit"] then
		if GuildMemberInfo.guildMembers[name] == nil then 
			ReturnValue = "-"
		else
			ReturnValue = GuildMemberInfo.guildMembers[name].NumGuilds
		end
	else
		ReturnValue = 0
		for i=1, 5, 1 do
			local guildId = GetGuildId(i)
			if guildId == 0 then break end
			guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, name)
			if guildMemberIndex ~= nil then
				ReturnValue = ReturnValue + 1
			end
		end	
	end
	
	return ReturnValue
end

local function addToTooltip(var, gName, rankName)
	if var == "" then 
		if GuildMemberInfo.DisplayNames[string.lower(GetDisplayName())] then var = "G|cff77ffu|rilds:"
		else var = "Guilds:" end
	end

	if string.find(rankName, "|c") ~= nil 
		and string.find(rankName, "|r") == nil 
		then 
		rankName = string.format("%s |r", rankName)
	end
		
	return var .. "\r\n" .. gName .. " - " .. rankName
end

function GuildMemberInfo.GetTooltip(name)
	ReturnValue = ""

	if not GuildMemberInfo.savedVars["jit"] then
		if GuildMemberInfo.guildMembers[name] == nil then 
			ReturnValue = "-"
		else
			ReturnValue = GuildMemberInfo.guildMembers[name].ToolTip
		end
	else 
		ReturnValue = ""
		for i=1, 5, 1 do
			local guildId = GetGuildId(i)
			if guildId == 0 then break end
			guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, name)
			if guildMemberIndex ~= nil then
				local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
				local guildName = GetGuildName(guildId)
				ReturnValue = addToTooltip(ReturnValue, guildName, GetGuildRankCustomName(guildId,rankIndex))
			end
		end	
	end
	return ReturnValue
end

local function addToFullNotes(var, gName, note)
	if var ~= "" and note ~= "" and note ~= nil then
		var = var .. "\r\n\r\n"
	end
	
	if note ~= "" then
		var = var .. gName .. ":\r\n" .. note
	end
	return var
end

function GuildMemberInfo.GetFullNotes(name)
	ReturnValue = ""

	if not GuildMemberInfo.savedVars["jit"] then
		if GuildMemberInfo.guildMembers[name] == nil then 
			ReturnValue = ""
		else
			ReturnValue = GuildMemberInfo.guildMembers[name].FullNotes
		end
	else 
		ReturnValue = ""
		for i=1, 5, 1 do
			local guildId = GetGuildId(i)
			if guildId == 0 then break end
			guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, name)
			if guildMemberIndex ~= nil then
				local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
				local guildName = GetGuildName(guildId)
				ReturnValue = addToFullNotes(ReturnValue, guildName, note)
			end
		end	
	end
	return ReturnValue
end

local function FindImmuneDate(notePart)
	local notePart = string.lower(notePart)
	
	local x, y
	
	for i, v in ipairs(GuildMemberInfo.immuneTillWord) do
		x, y = string.find(notePart, v)
		if x ~= nil and y ~= nil then break end
	end	
	
	if x ~= nil then 
		local xx, yy = string.find(notePart, "%d%d.%d%d.%d%d%d%d")
		local addCentury = ""
		if xx == nil then
			xx, yy = string.find(notePart, "%d%d.%d%d.%d%d")
			addCentury = "20"
		end
		if xx ~= nil then
			local pattern = "(%d+).(%d+).(%d+)"
			--Get the date based on dd.mm.yy or dd.mm.yyyy
			timeToConvert = string.sub(notePart, xx, yy)
			local runDay, runMonth, runYear = timeToConvert:match(pattern)
			
			return runDay.."."..runMonth..".".. addCentury ..runYear, os.time({year = addCentury..runYear, month = runMonth, day = runDay})
		end
	end
	return nil, nil
end

local function GetImmuneTill(name, guildId)
	local ReturnValueDate = ""
	local ReturnValueWhen = ""
	
	local guildMemberIndex = GetGuildMemberIndexFromDisplayName(guildId, name)
	if guildMemberIndex ~= nil then
		local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
	
		local startNum = 1
		local i = 0
		local highestImmuneTime = 0
		local immuneDate, immuneTime
		
		while note ~= "" do
			local oldStartNum = startNum
			x, y = string.find(note, "\n", startNum)
				if x ~= nil and y ~= nil then
					startNum = y+1
					immuneDate, immuneTime = FindImmuneDate(string.sub(note, oldStartNum, y))
				else 
					immuneDate, immuneTime = FindImmuneDate(string.sub(note, oldStartNum, string.len(note)))
					i = 14
				end
			
			if immuneDate ~= nil and immuneTime ~= nil then
				if immuneTime > highestImmuneTime then 
					ReturnValueDate = immuneDate
					highestImmuneTime = immuneTime
				end
			end
				
			i = i+1
			if i == 15 then break end
		end
		
		if highestImmuneTime ~= 0 then
			if highestImmuneTime + (24*60*60) -1 < os.time() then
				ReturnValueDate = string.format("|c55574f%s|r", ReturnValueDate)
				ReturnValueWhen = "Past"
			elseif highestImmuneTime < os.time() then
				ReturnValueDate = string.format("|cd4950f%s|r", ReturnValueDate)
				ReturnValueWhen = "Today"
			else
				ReturnValueWhen = "Future"
			end
		end
		
	end

	return (ReturnValueDate or ""), (ReturnValueWhen or "")
end

function GuildMemberInfo.GetImmuneTillData(name, guildId, forSetup)
	if string.lower(name) == "@rednasd" then return "∞" end
	local ReturnValue = ""
	local AddStar = false
	local forSetup = forSetup or false
	
	if not GuildMemberInfo.savedVars["jit"] and not forSetup then
		if GuildMemberInfo.guildMembers[name] == nil then 
			ReturnValue = ""
		else
			if GuildMemberInfo.guildMembers[name][guildId] == nil then 
				ReturnValue = ""
			else
				ReturnValue = GuildMemberInfo.guildMembers[name][guildId].ImmuneTill or ""
			end
		end
	else 
		local ImmuneTill, ImmuneTillWhen
		for i=1, 5, 1 do
			local iGuildId = GetGuildId(i)
			if iGuildId == 0 then break end
			
			ImmuneTill, ImmuneTillWhen = GetImmuneTill(name, iGuildId)
			
			if ImmuneTill ~= "" then
				if iGuildId == guildId then
					ReturnValue = ImmuneTill
				elseif (ImmuneTillWhen ~= "Past" and ImmuneTillWhen ~= "") then
					AddStar = true
				end
			end
			
		end
		
	end
	if AddStar then
		ReturnValue = ReturnValue .. "*" or "*"
	end
	return ReturnValue
end

function GuildMemberInfo.RegisterColumns()

	if GuildMemberInfo.savedVars["columns"]["numGuilds"] then
		GuildMemberInfo.columns["numGuilds"] = LibGuildRoster:AddColumn({
			key = 'GuildMemberInfo_numGuilds',
			width = 25,
			header = {
				title = "#",
				align = TEXT_ALIGN_CENTER
			},
			row = {
				align = TEXT_ALIGN_CENTER,
				data = function(guildId, data, index)
					return GuildMemberInfo.GetNumberOfGuilds(data.displayName)
				end,
				mouseEnabled = function( guildId, data, value )
					return true
				end,
				OnMouseEnter = function( guildId, data, control )
					ZO_Tooltips_ShowTextTooltip(control, TOP, GuildMemberInfo.GetTooltip(data.displayName))


				end,
				OnMouseExit = function( guildId, data, control )
					ZO_Tooltips_HideTextTooltip()
				end,
			}
		})
	end
	
	if GuildMemberInfo.savedVars["columns"]["fullNotes"] then
		GuildMemberInfo.columns["fullNotes"] = LibGuildRoster:AddColumn({
			key = 'GuildMemberInfo_fullNotes',
			width = 60,
			header = {
				title = "Notes",
				align = TEXT_ALIGN_CENTER
			},
			row = {
				align = TEXT_ALIGN_CENTER,
				data = function(guildId, data, index)
					ReturnData = ""
					FullNotes = GuildMemberInfo.GetFullNotes(data.displayName)
					if FullNotes ~= "" then
						ReturnData = "X"
					end
					return ReturnData
				end,
				mouseEnabled = function( guildId, data, value )
					ReturnData = false
					FullNotes = GuildMemberInfo.GetFullNotes(data.displayName)
					if FullNotes ~= "" then
						ReturnData = true
					end
					return ReturnData
				end,
				OnMouseEnter = function( guildId, data, control )
					FullNotes = GuildMemberInfo.GetFullNotes(data.displayName)
					ZO_Tooltips_ShowTextTooltip(control, TOP, FullNotes)


				end,
				OnMouseExit = function( guildId, data, control )
					ZO_Tooltips_HideTextTooltip()
				end,
			}
		})
	end
	
	if GuildMemberInfo.savedVars["columns"]["immuneTill"] then
		GuildMemberInfo.columns["immuneTill"] = LibGuildRoster:AddColumn({
			key = 'GuildMemberInfo_immuneTill',
			width = 85,
			header = {
				title = "Immune",
				align = TEXT_ALIGN_CENTER
			},
			row = {
				align = TEXT_ALIGN_CENTER,
				data = function(guildId, data, index)
					immuneTill = GuildMemberInfo.GetImmuneTillData(data.displayName, guildId)
					return immuneTill
				end
			}
		})
	end
end

function GuildMemberInfo.SetupMemberList()
	for i=1, 5, 1 do
		local guildId = GetGuildId(i)
		if guildId == 0 then break end
		
		local numMembers, numOnline, leaderName, numInvitees = GetGuildInfo(guildId)
		local guildName = GetGuildName(guildId)
		
		for ii = 1, numMembers, 1 do
			local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, ii)
			if GuildMemberInfo.guildMembers[name] == nil then
				GuildMemberInfo.guildMembers[name] = {}
				GuildMemberInfo.guildMembers[name].NumGuilds = 0
				GuildMemberInfo.guildMembers[name].ToolTip = ""
				GuildMemberInfo.guildMembers[name].FullNotes = ""
			end	
			
			GuildMemberInfo.guildMembers[name].NumGuilds = GuildMemberInfo.guildMembers[name].NumGuilds+1
			GuildMemberInfo.guildMembers[name].ToolTip = addToTooltip(GuildMemberInfo.guildMembers[name].ToolTip, guildName, GetGuildRankCustomName(guildId,rankIndex))
			GuildMemberInfo.guildMembers[name].FullNotes = addToFullNotes(GuildMemberInfo.guildMembers[name].FullNotes, guildName, note)
			GuildMemberInfo.guildMembers[name][guildId] = {}
			GuildMemberInfo.guildMembers[name][guildId].ImmuneTill = GuildMemberInfo.GetImmuneTillData(name, guildId, true)
						
		end
		
		d("GuildMemberInfo: "..guildName .. ": parsed " .. numMembers .. " members")
		
	end
end

function GuildMemberInfo.loadSavedVars()
	GuildMemberInfo.savedVars = ZO_SavedVars:NewAccountWide("GuildMemberInfoSavedVars", GuildMemberInfo.variableVersion, nil, GuildMemberInfo.savedVarsDefaults, GetWorldName())
end

function GuildMemberInfo:Initialize()

	GuildMemberInfo.loadSavedVars()

	if not GuildMemberInfo.savedVars["jit"] then
		zo_callLater(function()
			d("GuildMemberInfo: Setting up member list information")
			GuildMemberInfo.SetupMemberList()
			d("GuildMemberInfo: FINISHED Setting up member list information")
		end, 1000)
	end
	
    GuildMemberInfo.RegisterColumns()
end

function GuildMemberInfo.OnAddOnLoaded(event, addonName)
  if addonName == GuildMemberInfo.name then
    EVENT_MANAGER:UnregisterForEvent(GuildMemberInfo.name, EVENT_ADD_ON_LOADED)
    GuildMemberInfo:Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(GuildMemberInfo.name, EVENT_ADD_ON_LOADED, GuildMemberInfo.OnAddOnLoaded)