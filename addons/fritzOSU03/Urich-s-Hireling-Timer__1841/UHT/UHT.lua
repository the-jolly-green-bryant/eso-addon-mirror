if UHT == nil then UHT = {} end
UHT.AddonName = "UHT"
UHT.version = 1.0
UHT.active = false
local debugMode = false
local NUM_LOGIN_TIMES, NUM_ZONE_TIMES = 15, 100
local EM, SM = EVENT_MANAGER, SCENE_MANAGER
local GCCId = GetCurrentCharacterId
local zf = zo_strformat
local strF = string.format
local loginTime = 0
local _

local UHT_LTF = LibTableFunctions
if (not UHT_LTF) then return end

UHT.defaults = {
	firstRun = true,
	numChars = 0,
	charInfo = {},
	skillData = {},
	timeData = {},
}

UHT.skillData = {
	skillBS = 0,
	reqTimeBS = 0,
	skillCL = 0,
	reqTimeCL = 0,
	skillWW = 0,
	reqTimeWW = 0,
	skillEN = 0,
	reqTimeEN = 0,
	skillPV = 0,
	reqTimePV = 0,
}

UHT.timeData = {
	timeBS = 0,
	timeCL = 0,
	timeWW = 0,
	timeEN = 0,
	timePV = 0,
	loginTimes = {},
	zoneTimes = {},
}

UHT.data = {
	AbilityId = {
		BS = 48169,
		CL = 48199,
		WW = 48184,
		EN = 46770,
		PV = 44634,
	},
	AbilityIcon = {
		BS = "esoui/art/icons/servicemappins/servicepin_smithy.dds",
		CL = "esoui/art/icons/servicemappins/servicepin_clothier.dds",
		WW = "esoui/art/icons/servicemappins/servicepin_woodworking.dds",
		EN = "esoui/art/icons/servicemappins/servicepin_enchanting.dds",
		PV = "esoui/art/icons/servicemappins/servicepin_inn.dds",
	}
}

local function UHT_RedText(text)	return "|cFF0000"..tostring(text).."|r" end
local function UHT_GreenText(text)	return "|c00FF00"..tostring(text).."|r" end
local function UHT_BlueText(text)	return "|c0000FF"..tostring(text).."|r" end

local function UHT_SetLoginTime(charId)
	if(UHT.sVar.timeData[charId] ~= nil) then
		for i = #UHT.sVar.timeData[charId].loginTimes - 1, 1, -1 do
			UHT.sVar.timeData[charId].loginTimes[i+1] = UHT.sVar.timeData[charId].loginTimes[i]
		end
		UHT.sVar.timeData[charId].loginTimes[1] = loginTime
	end
	return
end

local function UHT_SetZoneChange(zoneTime)
	local charId = GCCId()
	for i = NUM_ZONE_TIMES - 1, 1, -1 do
		UHT.sVar.timeData[charId].zoneTimes[i+1] = UHT.sVar.timeData[charId].zoneTimes[i]
	end
	UHT.sVar.timeData[charId].zoneTimes[1] = zoneTime
	return
end

local function UHT_GetLastBSTime(charId)	return UHT.sVar.timeData[charId].timeBS end
local function UHT_GetLastCLTime(charId)	return UHT.sVar.timeData[charId].timeCL end
local function UHT_GetLastWWTime(charId)	return UHT.sVar.timeData[charId].timeWW end
local function UHT_GetLastENTime(charId)	return UHT.sVar.timeData[charId].timeEN end
local function UHT_GetLastPVTime(charId)	return UHT.sVar.timeData[charId].timePV end
local function UHT_GetBSSkill(charId)		return UHT.sVar.skillData[charId].skillBS end
local function UHT_GetCLSkill(charId)		return UHT.sVar.skillData[charId].skillCL end
local function UHT_GetWWSkill(charId)		return UHT.sVar.skillData[charId].skillWW end
local function UHT_GetENSkill(charId)		return UHT.sVar.skillData[charId].skillEN end
local function UHT_GetPVSkill(charId)		return UHT.sVar.skillData[charId].skillPV end

local function UHT_SetBSTime(thisCharId, timeReceived)
	if(timeReceived > UHT.sVar.timeData[thisCharId].timeBS and timeReceived < loginTime + 30 and timeReceived >= loginTime - 15) then
		UHT.sVar.timeData[thisCharId].timeBS = timeReceived; return
	end
	
	for k, v in pairs(UHT.sVar.charInfo) do
		for i = 1, NUM_LOGIN_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeBS and timeReceived < UHT.sVar.timeData[v.charId].loginTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].loginTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeBS = timeReceived; return
			end
		end
		
		for i = 1, NUM_ZONE_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeBS and timeReceived < UHT.sVar.timeData[v.charId].zoneTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].zoneTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeBS = timeReceived; return
			end
		end
	end
end

local function UHT_SetCLTime(thisCharId, timeReceived)
	if(timeReceived > UHT.sVar.timeData[thisCharId].timeCL and timeReceived < loginTime + 30 and timeReceived >= loginTime - 15) then
		UHT.sVar.timeData[thisCharId].timeCL = timeReceived; return
	end
	
	for k, v in pairs(UHT.sVar.charInfo) do
		for i = 1, NUM_LOGIN_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeCL and timeReceived < UHT.sVar.timeData[v.charId].loginTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].loginTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeCL = timeReceived; return
			end
		end
		
		for i = 1, NUM_ZONE_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeCL and timeReceived < UHT.sVar.timeData[v.charId].zoneTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].zoneTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeCL = timeReceived; return
			end
		end
	end
end

local function UHT_SetWWTime(thisCharId, timeReceived)
	if(timeReceived > UHT.sVar.timeData[thisCharId].timeWW and timeReceived < loginTime + 30 and timeReceived >= loginTime - 15) then
		UHT.sVar.timeData[thisCharId].timeWW = timeReceived; return
	end
	
	for k, v in pairs(UHT.sVar.charInfo) do
		for i = 1, NUM_LOGIN_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeWW and timeReceived < UHT.sVar.timeData[v.charId].loginTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].loginTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeWW = timeReceived; return
			end
		end
		
		for i = 1, NUM_ZONE_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeWW and timeReceived < UHT.sVar.timeData[v.charId].zoneTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].zoneTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeWW = timeReceived; return
			end
		end
	end
end

local function UHT_SetENTime(thisCharId, timeReceived)
	if(timeReceived > UHT.sVar.timeData[thisCharId].timeEN and timeReceived < loginTime + 30 and timeReceived >= loginTime - 15) then
		UHT.sVar.timeData[thisCharId].timeEN = timeReceived; return
	end
	
	for k, v in pairs(UHT.sVar.charInfo) do
		for i = 1, NUM_LOGIN_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeEN and timeReceived < UHT.sVar.timeData[v.charId].loginTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].loginTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeEN = timeReceived; return
			end
		end
		
		for i = 1, NUM_ZONE_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timeEN and timeReceived < UHT.sVar.timeData[v.charId].zoneTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].zoneTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timeEN = timeReceived; return
			end
		end
	end
end

local function UHT_SetPVTime(thisCharId, timeReceived)
	if(timeReceived > UHT.sVar.timeData[thisCharId].timePV and timeReceived < loginTime + 30 and timeReceived >= loginTime - 15) then
		UHT.sVar.timeData[thisCharId].timePV = timeReceived; return
	end
	
	for k, v in pairs(UHT.sVar.charInfo) do
		for i = 1, NUM_LOGIN_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timePV and timeReceived < UHT.sVar.timeData[v.charId].loginTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].loginTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timePV = timeReceived; return
			end
		end
		
		for i = 1, NUM_ZONE_TIMES do
			if(timeReceived > UHT.sVar.timeData[v.charId].timePV and timeReceived < UHT.sVar.timeData[v.charId].zoneTimes[i] + 30 and timeReceived >= UHT.sVar.timeData[v.charId].zoneTimes[i] - 15) then
				UHT.sVar.timeData[v.charId].timePV = timeReceived; return
			end
		end
	end
end

local function UHT_SetBSSkill(charId, skillLevel)
	UHT.sVar.skillData[charId].skillBS = skillLevel
	UHT.sVar.skillData[charId].reqTimeBS = (skillLevel > 0 and (skillLevel == 3 and 43200 or 86400) or 0)
end

local function UHT_SetCLSkill(charId, skillLevel)
	UHT.sVar.skillData[charId].skillCL = skillLevel
	UHT.sVar.skillData[charId].reqTimeCL = (skillLevel > 0 and (skillLevel == 3 and 43200 or 86400) or 0)
end

local function UHT_SetWWSkill(charId, skillLevel)
	UHT.sVar.skillData[charId].skillWW = skillLevel
	UHT.sVar.skillData[charId].reqTimeWW = (skillLevel > 0 and (skillLevel == 3 and 43200 or 86400) or 0)
end

local function UHT_SetENSkill(charId, skillLevel)
	UHT.sVar.skillData[charId].skillEN = skillLevel
	UHT.sVar.skillData[charId].reqTimeEN = (skillLevel > 0 and (skillLevel == 3 and 43200 or 86400) or 0)
end

local function UHT_SetPVSkill(charId, skillLevel)
	UHT.sVar.skillData[charId].skillPV = skillLevel
	UHT.sVar.skillData[charId].reqTimePV = (skillLevel > 0 and (skillLevel == 3 and 43200 or 86400) or 0)
end

local function UHT_SecondsToClock(value, timeFmt)
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

local function UHT_GetTimeElapsed(skill)
	local charId = GCCId()
	
	if(skill == "BS") then
		return (UHT.sVar.timeData[charId].timeBS > 0 and GetTimeStamp() - UHT.sVar.timeData[charId].timeBS or 0)
	elseif(skill == "CL") then
		return (UHT.sVar.timeData[charId].timeCL > 0 and GetTimeStamp() - UHT.sVar.timeData[charId].timeCL or 0)
	elseif(skill == "WW") then
		return (UHT.sVar.timeData[charId].timeWW > 0 and GetTimeStamp() - UHT.sVar.timeData[charId].timeWW or 0)
	elseif(skill == "EN") then
		return (UHT.sVar.timeData[charId].timeEN > 0 and GetTimeStamp() - UHT.sVar.timeData[charId].timeEN or 0)
	elseif(skill == "PV") then
		return (UHT.sVar.timeData[charId].timePV > 0 and GetTimeStamp() - UHT.sVar.timeData[charId].timePV or 0)
	else
		return 0
	end
end

local function UHT_GetHirelingTime(charId, skill)
	if(skill == "BS") then
		return (UHT.sVar.skillData[charId].skillBS > 0 and (UHT.sVar.skillData[charId].skillBS == 3 and 43200 or 86400) or 0)
	elseif(skill == "CL") then
		return (UHT.sVar.skillData[charId].skillCL > 0 and (UHT.sVar.skillData[charId].skillCL == 3 and 43200 or 86400) or 0)
	elseif(skill == "WW") then
		return (UHT.sVar.skillData[charId].skillWW > 0 and (UHT.sVar.skillData[charId].skillWW == 3 and 43200 or 86400) or 0)
	elseif(skill == "EN") then
		return (UHT.sVar.skillData[charId].skillEN > 0 and (UHT.sVar.skillData[charId].skillEN == 3 and 43200 or 86400) or 0)
	elseif(skill == "PV") then
		return (UHT.sVar.skillData[charId].skillPV > 0 and (UHT.sVar.skillData[charId].skillPV == 3 and 43200 or 86400) or 0)
	else
		return 0
	end
end

local function UHT_GetTimeRemaining(skill)
	local prevTime, requiredTime, charId = nil, nil, GCCId()
	if(skill == "BS") then prevTime = UHT.sVar.timeData[charId].timeBS
	elseif(skill == "CL") then prevTime = UHT.sVar.timeData[charId].timeCL
	elseif(skill == "WW") then prevTime = UHT.sVar.timeData[charId].timeWW
	elseif(skill == "EN") then prevTime = UHT.sVar.timeData[charId].timeEN
	elseif(skill == "PV") then prevTime = UHT.sVar.timeData[charId].timePV
	end
	
	requiredTime = UHT_GetHirelingTime(charId, skill)
	
	if(prevTime ~= nil and prevTime ~= 0 and requiredTime ~= nil) then
		local remainingTime = GetDiffBetweenTimeStamps(requiredTime + prevTime, GetTimeStamp())
		return (remainingTime >= 0 and remainingTime or 0)
	end
	return 0
end

local function UHT_GetThisTimeRemaining(charId, skill)
	local prevTime, requiredTime = nil, nil
	if(skill == "BS") then prevTime = UHT.sVar.timeData[charId].timeBS
	elseif(skill == "CL") then prevTime = UHT.sVar.timeData[charId].timeCL
	elseif(skill == "WW") then prevTime = UHT.sVar.timeData[charId].timeWW
	elseif(skill == "EN") then prevTime = UHT.sVar.timeData[charId].timeEN
	elseif(skill == "PV") then prevTime = UHT.sVar.timeData[charId].timePV
	end
	
	requiredTime = UHT_GetHirelingTime(charId, skill)
	
	if(prevTime ~= nil and prevTime ~= 0 and requiredTime ~= nil) then
		local remainingTime = GetDiffBetweenTimeStamps(requiredTime + prevTime, GetTimeStamp())
		return (remainingTime >= 0 and remainingTime or 0)
	end
	return 0
end

local function UHT_UpdateTime(_, _)
	for mailId in ZO_GetNextMailIdIter do
		senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
		
		local charId = GCCId()
		if(subject == GetString(UHT_MAIL_SUBJECT_BS) and fromSystem) then
			UHT_SetBSTime(charId, GetTimeStamp() - secsSinceReceived)
		elseif(subject == GetString(UHT_MAIL_SUBJECT_CL) and fromSystem) then
			UHT_SetCLTime(charId, GetTimeStamp() - secsSinceReceived)
		elseif(subject == GetString(UHT_MAIL_SUBJECT_WW) and fromSystem) then
			UHT_SetWWTime(charId, GetTimeStamp() - secsSinceReceived)
		elseif(subject == GetString(UHT_MAIL_SUBJECT_EN) and fromSystem) then
			UHT_SetENTime(charId, GetTimeStamp() - secsSinceReceived)
		elseif(subject == GetString(UHT_MAIL_SUBJECT_PV) and fromSystem) then
			UHT_SetPVTime(charId, GetTimeStamp() - secsSinceReceived)
		end
	end
end

local function UHT_UpdateSkills(eC, pB, pN, pPB, pPN)
	local charId, SST = GCCId(), SKILL_TYPE_TRADESKILL
	-- create localized names for comparison
	local skillNameBS = zf("<<t:1>>", GetCraftingSkillName(CRAFTING_TYPE_BLACKSMITHING))
	local skillNameCL = zf("<<t:1>>", GetCraftingSkillName(CRAFTING_TYPE_CLOTHIER))
	local skillNameWW = zf("<<t:1>>", GetCraftingSkillName(CRAFTING_TYPE_WOODWORKING))
	local skillNameEN = zf("<<t:1>>", GetCraftingSkillName(CRAFTING_TYPE_ENCHANTING))
	local skillNamePV = zf("<<t:1>>", GetCraftingSkillName(CRAFTING_TYPE_PROVISIONING))
	
	local abilityNameBS = zf("<<t:1>>", GetAbilityName(UHT.data.AbilityId.BS))
	local abilityNameCL = zf("<<t:1>>", GetAbilityName(UHT.data.AbilityId.CL))
	local abilityNameWW = zf("<<t:1>>", GetAbilityName(UHT.data.AbilityId.WW))
	local abilityNameEN = zf("<<t:1>>", GetAbilityName(UHT.data.AbilityId.EN))
	local abilityNamePV = zf("<<t:1>>", GetAbilityName(UHT.data.AbilityId.PV))
	
	for skillLine = 1, GetNumSkillLines(SST) do
		local skillName, skillRank, skillDiscovered, skillLineId = GetSkillLineInfo(SST, skillLine)
		-- localize skill name
		skillName = zf("<<t:1>>", skillName)
		
		for ability = 1, GetNumSkillAbilities(SST, skillLine) do
			local abilityName, abilityTexture, abilityRank, isPassive, isUltimate, isPurchased, progression = GetSkillAbilityInfo(SST, skillLine, ability)
			-- localize ability name
			abilityName = zf("<<t:1>>", abilityName)
			local currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(SST, skillLine, ability)
			
			if currentUpgradeLevel ~= nil then
				if(skillName == skillNameBS and abilityName == abilityNameBS) then
					UHT_SetBSSkill(charId, currentUpgradeLevel)
				elseif(skillName == skillNameCL and abilityName == abilityNameCL) then
					UHT_SetCLSkill(charId, currentUpgradeLevel)
				elseif(skillName == skillNameWW and abilityName == abilityNameWW) then
					UHT_SetWWSkill(charId, currentUpgradeLevel)
				elseif(skillName == skillNameEN and abilityName == abilityNameEN) then
					UHT_SetENSkill(charId, currentUpgradeLevel)
				elseif(skillName == skillNamePV and abilityName == abilityNamePV) then
					UHT_SetPVSkill(charId, currentUpgradeLevel)
				end
			end
		end
	end
end

local function UHT_FillLine(currLine, currItem)
	currLine.name:SetText(currItem == nil and "" or currItem.name)
	currLine.BStime:SetText(currItem == nil and "" or currItem.BStime)
	currLine.CLtime:SetText(currItem == nil and "" or currItem.CLtime)
	currLine.WWtime:SetText(currItem == nil and "" or currItem.WWtime)
	currLine.ENtime:SetText(currItem == nil and "" or currItem.ENtime)
	currLine.PVtime:SetText(currItem == nil and "" or currItem.PVtime)
end

local function UHT_InitializeTimeLines()
	local currLine, currData
	for i = 1, GetNumCharacters() do
		currLine = UHT_GUI_ListHolder.lines[i]
		currData = UHT_GUI_ListHolder.dataLines[i]

		if( currData ~= nil) then UHT_FillLine(currLine, currData)
		else UHT_FillLine(currLine, nil)
		end
	end
end

function UHT:UpdateDataLines()
	local dataLines = {}
	
	if(GetNumCharacters() > 0 and UHT.sVar.numChars ~= nil and UHT.sVar.numChars > 0)then
		for k, v in pairs(UHT.sVar.charInfo) do
			table.insert(dataLines, {
				name = v.charName,
				BStime = UHT_SecondsToClock(UHT_GetThisTimeRemaining(v.charId, "BS"), "h:mm:ss"),
				CLtime = UHT_SecondsToClock(UHT_GetThisTimeRemaining(v.charId, "CL"), "h:mm:ss"),
				WWtime = UHT_SecondsToClock(UHT_GetThisTimeRemaining(v.charId, "WW"), "h:mm:ss"),
				ENtime = UHT_SecondsToClock(UHT_GetThisTimeRemaining(v.charId, "EN"), "h:mm:ss"),
				PVtime = UHT_SecondsToClock(UHT_GetThisTimeRemaining(v.charId, "PV"), "h:mm:ss"),
			})
		end
	end
	
	UHT_GUI_ListHolder.dataLines = dataLines
	UHT_GUI_ListHolder:SetParent(UHT_GUI)
	UHT_InitializeTimeLines()
end

function UHT:ToggleWindow()
	UHT.active = not UHT.active
	if(UHT.active) then UHT:UpdateDataLines() end
	UHT_GUI:SetHidden(not UHT.active)
end

local function UHT_CreateLine(i, predecessor, parent)
	local record = CreateControlFromVirtual("UHT_Row_", parent, "UHT_SlotTemplate", i)
	
	record.name = record:GetNamedChild("_Name")
	record.BStime = record:GetNamedChild("_TimeBS")
	record.CLtime = record:GetNamedChild("_TimeCL")
	record.WWtime = record:GetNamedChild("_TimeWW")
	record.ENtime = record:GetNamedChild("_TimeEN")
	record.PVtime = record:GetNamedChild("_TimePV")
	
	record:SetHidden(false)
	record:SetMouseEnabled(true)
	record:SetHeight("24")
	
	if i == 1 then
		record:SetAnchor(TOPLEFT, UHT_GUI_ListHolder, TOPLEFT, 0, 0)
		record:SetAnchor(TOPRIGHT, UHT_GUI_ListHolder, TOPRIGHT, 0, 0)
	else
		record:SetAnchor(TOPLEFT, predecessor, BOTTOMLEFT, 0, UHT_GUI_ListHolder.rowHeight)
		record:SetAnchor(TOPRIGHT, predecessor, BOTTOMRIGHT, 0, UHT_GUI_ListHolder.rowHeight)
	end
	record:SetParent(UHT_GUI_ListHolder)
	return record
end

local function UHT_CreateListHolder()
	UHT_GUI_ListHolder.dataLines = {}
	UHT_GUI_ListHolder.lines = {}
	local predecessor = nil
	
	for i=1, GetNumCharacters() do
		UHT_GUI_ListHolder.lines[i] = UHT_CreateLine(i, predecessor, UHT_GUI_ListHolder)
		predecessor = UHT_GUI_ListHolder.lines[i]
	end
	UHT:UpdateDataLines()
end

local function UHT_UpdateCharList()
	UHT.sVar.charInfo = {}
	local id, name
	for i = 1, GetNumCharacters() do
		name, _, _, _, _, _, id, _ = GetCharacterInfo(i)
		UHT.sVar.charInfo[i] = {charId = id, charName = zf("<<t:1>>", name),}
	end
end

local function UHT_OnStart()
	local id, name = nil, nil
	local firstRun = ((UHT.sVar.firstRun or UHT.sVar.numChars == 0) and true or false)
	
	--If first run then setup the character table
	if(firstRun) then
		d(GetString(UHT_MSG_INIT))
		UHT.sVar.numChars = GetNumCharacters()
		for i = 1, GetNumCharacters() do
			name, _, _, _, _, _, id, _ = GetCharacterInfo(i)
			UHT.sVar.charInfo[i] = {charId = id, charName = zf("<<t:1>>", name),}
			
			--Write the character skill data table.
			UHT.sVar.skillData[id] = {}
			UHT.sVar.skillData[id] = UHT_LTF:CopyTable(UHT.skillData)
			
			--Write the character time data table.
			UHT.sVar.timeData[id] = {}
			UHT.sVar.timeData[id] = UHT_LTF:CopyTable(UHT.timeData)
			for j=1, NUM_LOGIN_TIMES do UHT.sVar.timeData[id].loginTimes[j] = 0 end
			for j=1, NUM_ZONE_TIMES do UHT.sVar.timeData[id].zoneTimes[j] = 0 end
		end
		
		--Show the welcome message.
		d(GetString(UHT_MSG_HELP))
		
		UHT.sVar.firstRun = false
	end
	
	--Setup the character info table.
	if(not firstRun) then UHT_UpdateCharList() end
	
	--Check for added characters and verify the time tables are intact.
	for k,v in pairs(UHT.sVar.charInfo) do
		if(not UHT_LTF:TableContains(UHT.sVar.timeData, v.charId, true)) then
			UHT.sVar.timeData[v.charId] = {}
			UHT.sVar.timeData[v.charId] = UHT_LTF:CopyTable(UHT.timeData)
		end
		
		if(not UHT_LTF:TableContains(UHT.sVar.skillData, v.charId, true)) then
			UHT.sVar.skillData[v.charId] = {}
			UHT.sVar.skillData[v.charId] = UHT_LTF:CopyTable(UHT.skillData)
		end
		
		if(UHT.sVar.timeData[v.charId].loginTimes[NUM_LOGIN_TIMES] == nil) then
			for j=1, NUM_LOGIN_TIMES do
				if(type(UHT.sVar.timeData[v.charId].loginTimes[j]) ~= 'number') then UHT.sVar.timeData[v.charId].loginTimes[j] = 0 end
			end
		end
		
		if(UHT.sVar.timeData[v.charId].zoneTimes[NUM_ZONE_TIMES] == nil) then
			for j=1, NUM_ZONE_TIMES do
				if(type(UHT.sVar.timeData[v.charId].zoneTimes[j]) ~= 'number') then UHT.sVar.timeData[v.charId].zoneTimes[j] = 0 end
			end
		end
	end
	
	--Check for removed characters.
	for k,v in pairs(UHT.sVar.timeData) do
		if(not UHT_LTF:TableContains(UHT.sVar.charInfo, k, false)) then
			UHT.sVar.timeData[k] = nil
		end
	end
	for k,v in pairs(UHT.sVar.skillData) do
		if(not UHT_LTF:TableContains(UHT.sVar.charInfo, k, false)) then
			UHT.sVar.skillData[k] = nil
		end
	end
	
	--Update the current character login times.
	loginTime = GetTimeStamp()
	UHT_SetLoginTime(GCCId())
	
	--Update current character skill levels.
	UHT_UpdateSkills(_, _, _, _, _)
	
	UHT_GUI:ClearAnchors()
	UHT_GUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	UHT_GUI:SetHeight(GetNumCharacters() * 24 + UHT_GUI_Header:GetHeight() + 18)
	
	--Add information to window.
	UHT_CreateListHolder()
	UHT_GUI_Header:SetParent(UHT_GUI)
	UHT_GUI_Header_Title:SetParent(UHT_GUI_Header)
	UHT_GUI_ListHolder:SetParent(UHT_GUI)
	
	UHT_GUI_Header_Title:SetText(GetString(UHT_GUI_TITLE))
	UHT_GUI_Header_HeaderName:SetText(GetString(UHT_GUI_CHAR_NAME))
	UHT_GUI_Header_IconBS:SetTexture(UHT.data.AbilityIcon.BS)
	UHT_GUI_Header_IconCL:SetTexture(UHT.data.AbilityIcon.CL)
	UHT_GUI_Header_IconWW:SetTexture(UHT.data.AbilityIcon.WW)
	UHT_GUI_Header_IconEN:SetTexture(UHT.data.AbilityIcon.EN)
	UHT_GUI_Header_IconPV:SetTexture(UHT.data.AbilityIcon.PV)
end

local function UHT_HelpSlash()
	d(GetString(UHT_MSG_CMD_TITLE))
	
	d(strF(GetString(UHT_MSG_CMD_OPTION_1), (UHT.active and GetString(UHT_MSG_HIDE) or GetString(UHT_MSG_SHOW))))
	d(GetString(UHT_MSG_CMD_OPTION_2))
	d(GetString(UHT_MSG_CMD_OPTION_3))
	d(GetString(UHT_MSG_CMD_OPTION_4))
	d(GetString(UHT_MSG_CMD_OPTION_5))
	d(GetString(UHT_MSG_CMD_OPTION_6))
	d(GetString(UHT_MSG_CMD_OPTION_7))
end

local function UHT_BadSlash()
	d(GetString(UHT_MSG_BAD_SLASH))
	d(GetString(UHT_MSG_CMD_TITLE))
	
	d(strF(GetString(UHT_MSG_CMD_OPTION_1), (UHT.active and GetString(UHT_MSG_HIDE) or GetString(UHT_MSG_SHOW))))
	d(GetString(UHT_MSG_CMD_OPTION_2))
	d(GetString(UHT_MSG_CMD_OPTION_3))
	d(GetString(UHT_MSG_CMD_OPTION_4))
	d(GetString(UHT_MSG_CMD_OPTION_5))
	d(GetString(UHT_MSG_CMD_OPTION_6))
	d(GetString(UHT_MSG_CMD_OPTION_7))
	d(GetString(UHT_MSG_CMD_OPTION_8))
end

local function UHT_TestHarness()
	d(GetString(UHT_MSG_HACK))
end

--Called by EVENT_PLAYER_ACTIVATED (triggers on login, reloadui, zone spawn)
local function UHT_PlayerActivated(eventCode)
	--Update zone times.
	UHT_SetZoneChange(GetTimeStamp())
end

--Called by EVENT_PLAYER_DEACTIVATED (triggers on zone change)
local function UHT_PlayerDeactivated(eventCode)
	--Update zone times.
	UHT_SetZoneChange(GetTimeStamp())
end

local function UHT_Initialized(eventCode, addonName)
	if addonName ~= UHT.AddonName then return end
	
	local world = GetWorldName()
	if(world == "NA Megaserver") then
		UHT.sVar = ZO_SavedVars:NewAccountWide("UHT_Settings", UHT.version, nil, UHT.defaults)
	else
		UHT.sVar = ZO_SavedVars:NewAccountWide("UHT_Settings", UHT.version, world, UHT.defaults)
	end
	
	--Run the startup routine.
	UHT_OnStart()
	
	--Create the keybind(s).
	ZO_CreateStringId("SI_BINDING_NAME_UHT_TOGGLE", "Show Hireling Timer")
	
	SLASH_COMMANDS["/uht"] = function(keyWord, argument)
		if(string.lower(keyWord) == "bs" or string.lower(keyWord) == "blacksmithing") then
			--Show BS time elapsed
			d(strF("%s: %s", GetString(UHT_MSG_LAST_BS), UHT_SecondsToClock(UHT_GetTimeElapsed("BS"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_BS), UHT_SecondsToClock(UHT_GetTimeRemaining("BS"), "h:mm:ss")))
		elseif(string.lower(keyWord) == "cl" or string.lower(keyWord) == "clothing") then
			--Show CL time elapsed
			d(strF("%s: %s", GetString(UHT_MSG_LAST_CL), UHT_SecondsToClock(UHT_GetTimeElapsed("CL"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_CL), UHT_SecondsToClock(UHT_GetTimeRemaining("CL"), "h:mm:ss")))
		elseif(string.lower(keyWord) == "ww" or string.lower(keyWord) == "woodworking") then
			--Show WW elapsed
			d(strF("%s: %s", GetString(UHT_MSG_LAST_WW), UHT_SecondsToClock(UHT_GetTimeElapsed("WW"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_WW), UHT_SecondsToClock(UHT_GetTimeRemaining("WW"), "h:mm:ss")))
		elseif(string.lower(keyWord) == "en" or string.lower(keyWord) == "enchanting") then
			--Show EN elapsed
			d(strF("%s: %s", GetString(UHT_MSG_LAST_EN), UHT_SecondsToClock(UHT_GetTimeElapsed("EN"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_EN), UHT_SecondsToClock(UHT_GetTimeRemaining("EN"), "h:mm:ss")))
		elseif(string.lower(keyWord) == "pv" or string.lower(keyWord) == "provisioning") then
			--Show PV time elapsed
			d(strF("%s: %s", GetString(UHT_MSG_LAST_PV), UHT_SecondsToClock(UHT_GetTimeElapsed("PV"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_PV), UHT_SecondsToClock(UHT_GetTimeRemaining("PV"), "h:mm:ss")))
		elseif(string.lower(keyWord) == "all") then
			--Show all elapsed times
			d(strF("%s: %s", GetString(UHT_MSG_LAST_BS), UHT_SecondsToClock(UHT_GetTimeElapsed("BS"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_BS), UHT_SecondsToClock(UHT_GetTimeRemaining("BS"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_LAST_CL), UHT_SecondsToClock(UHT_GetTimeElapsed("CL"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_CL), UHT_SecondsToClock(UHT_GetTimeRemaining("CL"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_LAST_WW), UHT_SecondsToClock(UHT_GetTimeElapsed("WW"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_WW), UHT_SecondsToClock(UHT_GetTimeRemaining("WW"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_LAST_EN), UHT_SecondsToClock(UHT_GetTimeElapsed("EN"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_EN), UHT_SecondsToClock(UHT_GetTimeRemaining("EN"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_LAST_PV), UHT_SecondsToClock(UHT_GetTimeElapsed("PV"), "h:mm:ss")))
			d(strF("%s: %s", GetString(UHT_MSG_NEXT_PV), UHT_SecondsToClock(UHT_GetTimeRemaining("PV"), "h:mm:ss")))
		elseif(string.lower(keyWord) == "help") then
			UHT_HelpSlash()
		elseif(keyWord == "") then
			UHT:ToggleWindow()
		elseif(keyWord == "test") then
			UHT_TestHarness()
		else
			UHT_BadSlash()
		end
	end
	
	--Handle the events.
	EM:RegisterForEvent(UHT.AddonName, EVENT_MAIL_READABLE, UHT_UpdateTime)
	EM:RegisterForEvent(UHT.AddonName, EVENT_SKILL_POINTS_CHANGED, UHT_UpdateSkills)
	EM:RegisterForEvent(UHT.AddonName, EVENT_PLAYER_ACTIVATED, UHT_PlayerActivated)
	EM:RegisterForEvent(UHT.AddonName, EVENT_PLAYER_DEACTIVATED, UHT_PlayerDeactivated)
	
	--Kill the initial event handler.
	EM:UnregisterForEvent("UHT_Initialized", EVENT_ADD_ON_LOADED)
end

--Register initialization event.
EM:RegisterForEvent("UHT_Initialized", EVENT_ADD_ON_LOADED, UHT_Initialized)
