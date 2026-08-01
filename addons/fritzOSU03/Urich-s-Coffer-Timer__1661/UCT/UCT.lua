if UCT == nil then UCT = {} end
UCT.AddonName = "UCT"
UCT.version = 1.0
UCT.active = false
local debugMode = false
local EM = EVENT_MANAGER
local GCCId = GetCurrentCharacterId
local zf = zo_strformat
local strF = string.format
local _

local UCT_LTF = LibTableFunctions

UCT.defaults = {
	firstRun = true,
	numChars = 0,
	charInfo = {},
	timeData = {},
}

UCT.timeData = {
	timeAA = 0,
	timeAS = 0,
	timeHoF = 0,
	timeHRC = 0,
	timeSO = 0,
	timeMaw = 0,
	timeCR = 0,
	timeSS = 0,
}

UCT.data = {
	QuestId = {
		AA = 5102,
		AS = 6090,
		CR = 6192,
		HoF = 5894,
		HRC = 5087,
		SO = 5171,
		Maw = 5352,
		SS = 6353,
	},
	ZoneId = {
		AA = 638,
		AS = 1000,
		CR = 1051,
		HoF = 975,
		HRC = 636,
		SO = 639,
		Maw = 725,
		SS = 1121,
	},
}

local function UCT_RedText(text)	return "|cFF0000"..tostring(text).."|r" end
local function UCT_GreenText(text)	return "|c00FF00"..tostring(text).."|r" end
local function UCT_BlueText(text)	return "|c0000FF"..tostring(text).."|r" end

local function UCT_GetLastAATime(charId)	return UCT.sVar.timeData[charId].timeAA  end
local function UCT_GetLastASTime(charId)	return UCT.sVar.timeData[charId].timeAS  end
local function UCT_GetLastCRTime(charId)	return UCT.sVar.timeData[charId].timeCR  end
local function UCT_GetLastHoFTime(charId)	return UCT.sVar.timeData[charId].timeHoF end
local function UCT_GetLastHRCTime(charId)	return UCT.sVar.timeData[charId].timeHRC end
local function UCT_GetLastMawTime(charId)	return UCT.sVar.timeData[charId].timeMaw end
local function UCT_GetLastSOTime(charId)	return UCT.sVar.timeData[charId].timeSO  end
local function UCT_GetLastSSTime(charId)	return UCT.sVar.timeData[charId].timeSS  end

local function UCT_SetAATime(charId)	UCT.sVar.timeData[charId].timeAA = GetTimeStamp()  end
local function UCT_SetASTime(charId)	UCT.sVar.timeData[charId].timeAS = GetTimeStamp()  end
local function UCT_SetCRTime(charId)	UCT.sVar.timeData[charId].timeCR = GetTimeStamp()  end
local function UCT_SetHoFTime(charId)	UCT.sVar.timeData[charId].timeHoF = GetTimeStamp() end
local function UCT_SetHRCTime(charId)	UCT.sVar.timeData[charId].timeHRC = GetTimeStamp() end
local function UCT_SetMawTime(charId)	UCT.sVar.timeData[charId].timeMaw = GetTimeStamp() end
local function UCT_SetSOTime(charId)	UCT.sVar.timeData[charId].timeSO = GetTimeStamp()  end
local function UCT_SetSSTime(charId)	UCT.sVar.timeData[charId].timeSS = GetTimeStamp()  end

local function UCT_SecondsToClock(value, timeFmt)
	local days, hours, mins, secs, seconds = 0, 0, 0, 0, tonumber(value)
	
	--timeFmt Options
	--Full(dhms) = d days, h hours, m minutes, s seconds
	--Full(hms) = h hours, m minutes, s seconds
	--d:hh:mm:ss
	--d:h:mm:ss
	--h:mm:ss
	
	if(timeFmt == "Full(dhms)") then
		if seconds <= 0 then return "None";
		else
			days = math.floor(seconds/86400);
			seconds = seconds - (days * 86400);
			hours = math.floor(seconds/3600);
			seconds = seconds - (hours * 3600);
			mins = math.floor(seconds/60);
			seconds = seconds - (mins * 60);
			secs = math.floor(seconds);
			
			if(days == "0" and hours == "0" and mins == "0") then return strF("%01.f seconds", secs)
			elseif(days == "0" and hours == "0") then return strF("%01.f minutes, %01.f seconds", mins, secs)
			elseif(days == "0") then return strF("%01.f hours, %01.f minutes, %01.f seconds", hours, mins, secs)
			else return strF("%01.f days, %01.f hours, %01.f minutes, %01.f seconds", days, hours, mins, secs)
			end
		end
	elseif(timeFmt == "Full(hms)") then
		if seconds <= 0 then return "None";
		else
			hours = math.floor(seconds/3600);
			seconds = seconds - (hours * 3600);
			mins = math.floor(seconds/60);
			seconds = seconds - (mins * 60);
			secs = math.floor(seconds);
			
			if(hours == "0" and mins == "0") then return strF("%01.f seconds", secs)
			elseif(hours == "0") then return strF("%01.f minutes, %01.f seconds", mins, secs)
			else return strF("%01.f hours, %01.f minutes, %01.f seconds", hours, mins, secs)
			end
		end
	elseif(timeFmt == "d:hh:mm:ss") then
		if seconds <= 0 then return "-";
		else
			days = math.floor(seconds/86400);
			seconds = seconds - (days * 86400);
			hours = math.floor(seconds/3600);
			seconds = seconds - (hours * 3600);
			mins = math.floor(seconds/60);
			seconds = seconds - (mins * 60);
			secs = math.floor(seconds);
			
			return strF("%01.f:%02.f:%02.f:%02.f", days, hours, mins, secs)
		end
	elseif(timeFmt == "d:h:mm:ss") then
		if seconds <= 0 then return "-";
		else
			days = math.floor(seconds/86400);
			seconds = seconds - (days * 86400);
			hours = math.floor(seconds/3600);
			seconds = seconds - (hours * 3600);
			mins = math.floor(seconds/60);
			seconds = seconds - (mins * 60);
			secs = math.floor(seconds);
			
			return strF("%01.f:%01.f:%02.f:%02.f", days, hours, mins, secs)
		end
	elseif(timeFmt == "h:mm:ss") then
		if seconds <= 0 then return "-";
		else
			hours = math.floor(seconds/3600);
			seconds = seconds - (hours * 3600);
			mins = math.floor(seconds/60);
			seconds = seconds - (mins * 60);
			secs = math.floor(seconds);
			
			return strF("%01.f:%02.f:%02.f", hours, mins, secs)
		end
	else
		if seconds <= 0 then return "-";
		else
			days = math.floor(seconds/86400);
			seconds = seconds - (days * 86400);
			hours = math.floor(seconds/3600);
			seconds = seconds - (hours * 3600);
			mins = math.floor(seconds/60);
			seconds = seconds - (mins * 60);
			secs = math.floor(seconds);
			
			return strF("%01.f:%02.f:%02.f:%02.f", days, hours, mins, secs)
		end
	end
end

local function UCT_GetTimeElapsed(prevTime)
	return (prevTime ~= nil and prevTime ~= 0) and GetDiffBetweenTimeStamps(GetTimeStamp(), prevTime) or 0
end

local function UCT_GetTimeRemaining(prevTime)
	if(prevTime ~= nil and prevTime ~= 0) then
		local remainingTime = GetDiffBetweenTimeStamps(604800 + prevTime, GetTimeStamp())
		return (remainingTime >= 0 and remainingTime or 0)
	end
	return 0
end

local function UCT_UpdateTime(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
	local charId = GCCId()
	if(isCompleted) then
		if(questID == UCT.data.QuestId.AA and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeAA) <= 0) then UCT_SetAATime(charId) return end
		if(questID == UCT.data.QuestId.AS and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeAS) <= 0) then UCT_SetASTime(charId) return end
		if(questID == UCT.data.QuestId.CR and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeCR) <= 0) then UCT_SetCRTime(charId) return end
		if(questID == UCT.data.QuestId.HoF and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeHoF) <= 0) then UCT_SetHoFTime(charId) return end
		if(questID == UCT.data.QuestId.HRC and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeHRC) <= 0) then UCT_SetHRCTime(charId) return end
		if(questID == UCT.data.QuestId.SO and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeSO) <= 0) then UCT_SetSOTime(charId) return end
		if(questID == UCT.data.QuestId.Maw and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeMaw) <= 0) then UCT_SetMawTime(charId) return end
		if(questID == UCT.data.QuestId.SS and UCT_GetTimeRemaining(UCT.sVar.timeData[charId].timeSS) <= 0) then UCT_SetSSTime(charId) return end
	end
end

local function UCT_FillLine(currLine, currItem)
	currLine.name:SetText(		currItem == nil and "" or currItem.name)
	currLine.AAtime:SetText(	currItem == nil and "" or currItem.AAtime)
	currLine.AStime:SetText(	currItem == nil and "" or currItem.AStime)
	currLine.CRtime:SetText(	currItem == nil and "" or currItem.CRtime)
	currLine.HoFtime:SetText(	currItem == nil and "" or currItem.HoFtime)
	currLine.HRCtime:SetText(	currItem == nil and "" or currItem.HRCtime)
	currLine.SOtime:SetText(	currItem == nil and "" or currItem.SOtime)
	currLine.Mawtime:SetText(	currItem == nil and "" or currItem.Mawtime)
	currLine.SStime:SetText(	currItem == nil and "" or currItem.SStime)
end

local function UCT_InitializeTimeLines()
	local currLine, currData
	for i = 1, GetNumCharacters() do
		currLine = UCT_GUI_ListHolder.lines[i]
		currData = UCT_GUI_ListHolder.dataLines[i]

		if( currData ~= nil) then UCT_FillLine(currLine, currData)
		else UCT_FillLine(currLine, nil)
		end
	end
end

function UCT:UpdateDataLines()
	local dataLines = {}
	if(GetNumCharacters() > 0 and UCT.sVar.numChars ~= nil and UCT.sVar.numChars > 0)then
		for k, v in pairs(UCT.sVar.charInfo) do
			table.insert(dataLines, {
				name = v.charName,
				AAtime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeAA), "d:hh:mm:ss"),
				AStime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeAS), "d:hh:mm:ss"),
				CRtime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeCR), "d:hh:mm:ss"),
				HoFtime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeHoF), "d:hh:mm:ss"),
				HRCtime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeHRC), "d:hh:mm:ss"),
				SOtime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeSO), "d:hh:mm:ss"),
				Mawtime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeMaw), "d:hh:mm:ss"),
				SStime = UCT_SecondsToClock(UCT_GetTimeRemaining(UCT.sVar.timeData[v.charId].timeSS), "d:hh:mm:ss"),
			})
		end
	end
	
	UCT_GUI_ListHolder.dataLines = dataLines
	UCT_GUI_ListHolder:SetParent(UCT_GUI)
	UCT_InitializeTimeLines()
end

function UCT:ToggleWindow()
	UCT.active = not UCT.active
	if(UCT.active) then UCT:UpdateDataLines() end
	UCT_GUI:SetHidden(not UCT.active)
end

local function UCT_CreateLine(i, predecessor, parent)
	local record = CreateControlFromVirtual("UCT_Row_", parent, "UCT_SlotTemplate", i)
	
	record.name = record:GetNamedChild("_Name")
	record.AAtime = record:GetNamedChild("_TimeAA")
	record.AStime = record:GetNamedChild("_TimeAS")
	record.CRtime = record:GetNamedChild("_TimeCR")
	record.HoFtime = record:GetNamedChild("_TimeHoF")
	record.HRCtime = record:GetNamedChild("_TimeHRC")
	record.SOtime = record:GetNamedChild("_TimeSO")
	record.Mawtime = record:GetNamedChild("_TimeMaw")
	record.SStime = record:GetNamedChild("_TimeSS")
	
	record:SetHidden(false)
	record:SetMouseEnabled(true)
	record:SetHeight("24")
	
	if i == 1 then
		record:SetAnchor(TOPLEFT, UCT_GUI_ListHolder, TOPLEFT, 0, 0)
		record:SetAnchor(TOPRIGHT, UCT_GUI_ListHolder, TOPRIGHT, 0, 0)
	else
		record:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, UCT_GUI_ListHolder.rowHeight)
		record:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, UCT_GUI_ListHolder.rowHeight)
	end
	record:SetParent(UCT_GUI_ListHolder)
	return record
end

local function UCT_CreateListHolder()
	UCT_GUI_ListHolder.dataLines = {}
	UCT_GUI_ListHolder.lines = {}
	local predecessor = nil
	
	for i=1, GetNumCharacters() do
		UCT_GUI_ListHolder.lines[i] = UCT_CreateLine(i, predecessor, UCT_GUI_ListHolder)
		predecessor = UCT_GUI_ListHolder.lines[i]
	end
	UCT:UpdateDataLines()
end

local function UCT_UpdateCharList()
	UCT.sVar.charInfo = {}
	local id, name
	for i = 1, GetNumCharacters() do
		name, _, _, _, _, _, id, _ = GetCharacterInfo(i)
		UCT.sVar.charInfo[i] = {charId = id, charName = zf("<<t:1>>", name),}
	end
end

local function UCT_OnStart()
	local name = nil
	local firstRun = ((UCT.sVar.firstRun or UCT.sVar.numChars == 0) and true or false)
	
	--If first run then setup the character table
	if(firstRun) then
		d(GetString(UCT_MSG_INIT))
		UCT.sVar.numChars = GetNumCharacters()
		for i = 1, GetNumCharacters() do
			name, _, _, _, _, _, id, _ = GetCharacterInfo(i)
			UCT.sVar.charInfo[i] = {charId = id, charName = zf("<<t:1>>", name),}
			
			--Write the character points data table.
			UCT.sVar.timeData[id] = {}
			UCT.sVar.timeData[id] = UCT_LTF:CopyTable(UCT.timeData)
			UCT.sVar.timeData[id].charName = UCT.sVar.charInfo[i].charName
		end
		
		--Show the welcome message.
		d(GetString(UCT_MSG_HELP))
		
		UCT.sVar.firstRun = false
	end
	
	--Setup the character info table.
	if(not firstRun) then UCT_UpdateCharList() end
	
	--Check for added characters.
	for k,v in pairs(UCT.sVar.charInfo) do
		if(not UCT_LTF:TableContains(UCT.sVar.timeData, v.charId, true)) then
			UCT.sVar.timeData[v.charId] = UCT_LTF:CopyTable(UCT.timeData)
		end
	end
	
	--Check for removed characters.
	for k,v in pairs(UCT.sVar.timeData) do
		if(not UCT_LTF:TableContains(UCT.sVar.charInfo, k, false)) then
			UCT.sVar.timeData[k] = nil
		end
	end
	
	--Verify that all values exist for all characters.
	for i = 1, GetNumCharacters() do
		_, _, _, _, _, _, id, _ = GetCharacterInfo(i)
		
		--Write the character points data table.
		for k,v in pairs(UCT.timeData) do
			UCT.sVar.timeData[id][k] = (UCT.sVar.timeData[id][k] ~= nil and UCT.sVar.timeData[id][k] or v)
		end
	end
	
	UCT_GUI:ClearAnchors()
	UCT_GUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	UCT_GUI:SetHeight(GetNumCharacters() * 24 + UCT_GUI_Header:GetHeight() + 18)
	
	--Add information to window.
	UCT_CreateListHolder()
	UCT_GUI_Header:SetParent(UCT_GUI)
	UCT_GUI_Header_Title:SetParent(UCT_GUI_Header)
	UCT_GUI_ListHolder:SetParent(UCT_GUI)
	
	UCT_GUI_Header_Title:SetText(GetString(UCT_GUI_TITLE))
	UCT_GUI_Header_HeaderName:SetText(GetString(UCT_GUI_CHAR_NAME))
	UCT_GUI_Header_HeaderAA:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.AA)))
	UCT_GUI_Header_HeaderHRC:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.HRC)))
	UCT_GUI_Header_HeaderSO:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.SO)))
	UCT_GUI_Header_HeaderMaw:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.Maw)))
	UCT_GUI_Header_HeaderHoF:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.HoF)))
	UCT_GUI_Header_HeaderAS:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.AS)))
	UCT_GUI_Header_HeaderCR:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.CR)))
	UCT_GUI_Header_HeaderSS:SetText(zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.SS)))
end

local function UCT_HelpSlash()
	d(GetString(UCT_MSG_CMD_TITLE))
	d(strF(GetString(UCT_MSG_CMD_OPTION_1), (UCT.active and GetString(UCT_MSG_HIDE) or GetString(UCT_MSG_SHOW))))
	
	d(strF(GetString(UCT_MSG_CMD_OPTION_2), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.AA))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_3), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.AS))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_4), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.CR))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_5), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.HoF))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_6), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.HRC))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_7), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.Maw))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_8), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.SO))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_9), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.SS))))
	d(GetString(UCT_MSG_CMD_OPTION_10))
end

local function UCT_BadSlash()
	d(GetString(UCT_MSG_BAD_SLASH))
	d(GetString(UCT_MSG_CMD_TITLE))
	d(strF(GetString(UCT_MSG_CMD_OPTION_1), (UCT.active and GetString(UCT_MSG_HIDE) or GetString(UCT_MSG_SHOW))))
	
	d(strF(GetString(UCT_MSG_CMD_OPTION_2), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.AA))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_3), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.AS))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_4), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.CR))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_5), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.HoF))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_6), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.HRC))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_7), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.Maw))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_8), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.SO))))
	d(strF(GetString(UCT_MSG_CMD_OPTION_9), zf("<<t:1>>", GetZoneNameById(UCT.data.ZoneId.SS))))
	d(GetString(UCT_MSG_CMD_OPTION_10))
end

local function UCT_TestHarness()
	d(GetString(UCT_MSG_HACK))
	--[[
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.AA), GetZoneIndex(UCT.data.ZoneId.AA), UCT.data.QuestId.AA)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.AS), GetZoneIndex(UCT.data.ZoneId.AS), UCT.data.QuestId.AS)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.CR), GetZoneIndex(UCT.data.ZoneId.CR), UCT.data.QuestId.CR)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.HoF), GetZoneIndex(UCT.data.ZoneId.HoF), UCT.data.QuestId.HoF)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.HRC), GetZoneIndex(UCT.data.ZoneId.HRC), UCT.data.QuestId.HRC)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.SO), GetZoneIndex(UCT.data.ZoneId.SO), UCT.data.QuestId.SO)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.Maw), GetZoneIndex(UCT.data.ZoneId.Maw), UCT.data.QuestId.Maw)
	UCT_UpdateTime(0, true, 0, "", GetZoneIndex(UCT.data.ZoneId.SS), GetZoneIndex(UCT.data.ZoneId.SS), UCT.data.QuestId.SS)
	]]--
end

local function UCT_Initialized(eventCode, addonName)
	if addonName ~= UCT.AddonName then return end
	
	local world = GetWorldName()
	if(world == "NA Megaserver") then
		UCT.sVar = ZO_SavedVars:NewAccountWide("UCT_Settings", UCT.version, nil, UCT.defaults)
	else
		UCT.sVar = ZO_SavedVars:NewAccountWide("UCT_Settings", UCT.version, world, UCT.defaults)
	end
	
	--Run the startup routine.
	UCT_OnStart()
	
	--Create the keybind(s).
	ZO_CreateStringId("SI_BINDING_NAME_UCT_TOGGLE", "Show Coffer Timer")
	
	--Register the slash commands.
	SLASH_COMMANDS["/uct"] = function(keyWord, argument)
		if(string.lower(keyWord) == "aa") then
			--Show AA time elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_AA), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastAATime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_AA), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastAATime(GCCId())))))
		elseif(string.lower(keyWord) == "as") then
			--Show AS time elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_AS), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastASTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_AS), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastASTime(GCCId())))))
		elseif(string.lower(keyWord) == "cr") then
			--Show CR time elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_CR), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastCRTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_CR), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastCRTime(GCCId())))))
		elseif(string.lower(keyWord) == "hof") then
			--Show HoF elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_HOF), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastHoFTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_HOF), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastHoFTime(GCCId())))))
		elseif(string.lower(keyWord) == "hrc") then
			--Show HRC elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_HRC), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastHRCTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_HRC), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastHRCTime(GCCId())))))
		elseif(string.lower(keyWord) == "so") then
			--Show SO time elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_SO), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastSOTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_SO), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastSOTime(GCCId())))))
		elseif(string.lower(keyWord) == "maw") then
			--Show Maw time elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_MAW), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastMawTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_MAW), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastMawTime(GCCId())))))
		elseif(string.lower(keyWord) == "ss") then
			--Show SO time elapsed
			d(strF("%s%s", GetString(UCT_MSG_LAST_SS), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastSSTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_SS), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastSSTime(GCCId())))))
		elseif(string.lower(keyWord) == "all") then
			--Show all elapsed times
			d(strF("%s%s", GetString(UCT_MSG_LAST_AA), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastAATime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_AA), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastAATime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_AS), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastASTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_AS), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastASTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_CR), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastCRTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_CR), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastCRTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_HOF), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastHoFTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_HOF), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastHoFTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_HRC), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastHRCTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_HRC), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastHRCTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_SO), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastSOTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_SO), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastSOTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_MAW), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastMawTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_MAW), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastMawTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_LAST_SS), UCT_SecondsToClock(UCT_GetTimeElapsed(UCT_GetLastSSTime(GCCId())))))
			d(strF("%s%s", GetString(UCT_MSG_NEXT_SS), UCT_SecondsToClock(UCT_GetTimeRemaining(UCT_GetLastSSTime(GCCId())))))
		elseif(string.lower(keyWord) == "help") then
			UCT_HelpSlash()
		elseif(keyWord == "") then
			UCT:ToggleWindow()
		--elseif(keyWord == "test") then
		--	UCT_TestHarness()
		else
			UCT_BadSlash()
		end
	end
	
	--Create the event handlers.
	EM:RegisterForEvent(UCT.AddonName, EVENT_QUEST_REMOVED, UCT_UpdateTime)
	
	--Kill the initial event handler.
	EM:UnregisterForEvent("UCT_Initialized", EVENT_ADD_ON_LOADED)
end

--Register initialization event.
EM:RegisterForEvent("UCT_Initialized", EVENT_ADD_ON_LOADED, UCT_Initialized)
