--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

--[[
Acknowledgments

I'd like to thank the following addons:
- ESO Daily Quest Tracker by Phinix
- AutoInvite by Sasky
- AP Meter by ghostbane
]]

-- Initialized the addon names
CyrodiilMissionShare = {}
CyrodiilMissionShare.name = "CyrodiilMissionShare"
CyrodiilMissionShare.version = 12.0

-- Initializes various things; variables aptly named
CyrodiilMissionShare.searchString = 'cms'
CyrodiilMissionShare.playerAtName = nil
CyrodiilMissionShare.playerIsLooking = false
CyrodiilMissionShare.questWasShared = false
CyrodiilMissionShare.lastZoneShared = ''
CyrodiilMissionShare.playerInPvP = false
CyrodiilMissionShare.playerAlliance = nil
CyrodiilMissionShare.playerTypeRequest = nil
CyrodiilMissionShare.playerZoneId = 0

-- For the addon settings menu
CyrodiilMissionShare.LAM2 = LibAddonMenu2

-- Saved beyond session variables

CyrodiilMissionShare.defaults = {
	autoDeclineWardens=false,
	autoAcceptRequest=true,
	autoShareKillQuest=false,
	killQuests = {
		['Players'] = false,
		['Templars'] = false,
		['Nightblades'] = false,
		['Sorcerers'] = false,
		['Dragonknights'] = false,
		['Wardens'] = false,
		['Necromancers'] = false
	},
	timezone=2,
	lastKillFinishTime=nil,
	autoCompleteQuest=false,
	autoShareCaptureQuest=true,
	autoShareScrollQuest=true,
	captureKeepQuests={},
	captureResourceQuests={},
	captureTownQuests={}
}

-- CMS data
CyrodiilMissionShare.scrollQuests = {
	['chim'] = 'Chim',
	['altadoon'] = 'Altadoon',
	['mnem'] = 'Mnem',
	['ghartok'] = 'Ghartok',
	['ni-mohk'] = 'Ni-Mohk',
	['alma ruma'] = 'Alma Ruma',
	['almaruma'] = 'Alma Ruma',
	['nimohk'] = 'Ni-Mohk',
	['ni mohk'] = 'Ni-Mohk',
	['ni-mohk'] = 'Ni-Mohk',
	['nimonk'] = 'Ni-Mohk',
	['ni monk'] = 'Ni-Mohk',
	['ni-monk'] = 'Ni-Mohk',
}

CyrodiilMissionShare.killQuests = {
	['player'] = 'Players',
	['templar'] = 'Templars',
	['nightblade'] = 'Nightblades',
	['sorcerer'] = 'Sorcerers',
	['dragonknight'] = 'Dragonknights',
	['warden'] = 'Wardens',
	['nb'] = 'Nightblades',
	['sorc'] = 'Sorcerers',
	['dk'] = 'Dragonknights',
	['necromancer'] = 'Necromancers',
	['necro'] = 'Necromancers',
	['nm'] = 'Necromancers'
}

CyrodiilMissionShare.resourceNames = {
	['Farm'] = 'Farm',
	['Lumbermill'] = 'Lumbermill',
	['Mine'] = 'Mine',
	['lumber'] = 'Lumbermill'
}

CyrodiilMissionShare.keepNames = {
	['Black Boot'] = 'Castle Black Boot',
	['Bloodmayne'] = 'Castle Bloodmayne',
	['Faregyl'] = 'Castle Faregyl',
	['Alessia'] = 'Castle Alessia',
	['Roebeck'] = 'Castle Roebeck',
	['Brindle'] = 'Castle Brindle',
	['Drakelowe'] = 'Drakelowe Keep',
	['Blue Road'] = 'Blue Road Keep',
	['Farragut'] = 'Farragut Keep',
	['Arrius'] = 'Arrius Keep',
	['Kingscrest'] = 'Kingscrest Keep',
	['Chalman'] = 'Chalman Keep',
	['Ash'] = 'Fort Ash',
	['Dragonclaw'] = 'Fort Dragonclaw',
	['Aleswell'] = 'Fort Aleswell',
	['Glademist'] = 'Fort Glademist',
	['Warden'] = 'Fort Warden',
	['Rayles'] = 'Fort Rayles'
}

CyrodiilMissionShare.keepNicknames = {
	['BB'] = 'Black Boot',
	['BM'] = 'Bloodmayne',
	['Fare'] = 'Faregyl',
	['Alessia'] = 'Alessia',
	['Roe'] = 'Roebeck',
	['Brindle'] = 'Brindle',
	['Drake'] = 'Drakelowe',
	['BRK'] = 'Blue Road',
	['Farragut'] = 'Farragut',
	['Arrius'] = 'Arrius',
	['Kings'] = 'Kingscrest',
	['Chal'] = 'Chalman',
	['Ash'] = 'Ash',
	['Dragonclaw'] = 'Dragonclaw',
	['Aleswell'] = 'Aleswell',
	['Glade'] = 'Glademist',
	['Warden'] = 'Warden',
	['Rayles'] = 'Rayles'
}

CyrodiilMissionShare.keeps = {
    [3] = "Fort Warden",
    [4] = "Fort Rayles",
    [5] = "Fort Glademist",
    [6] = "Fort Ash",
    [7] = "Fort Aleswell",
    [8] = "Fort Dragonclaw",
    [9] = "Chalman Keep",
    [10] = "Arrius Keep",
    [11] = "Kingscrest Keep",
    [12] = "Farragut Keep",
    [13] = "Blue Road Keep",
    [14] = "Drakelowe Keep",
    [15] = "Castle Alessia",
    [16] = "Castle Faregyl",
    [17] = "Castle Roebeck",
    [18] = "Castle Brindle",
    [19] = "Castle Black Boot",
    [20] = "Castle Bloodmayne",
    [22] = "Castle Bloodmayne Farm",
    [23] = "Castle Bloodmayne Mine",
    [24] = "Castle Bloodmayne Lumbermill",
    [34] = "Castle Black Boot Lumbermill",
    [35] = "Castle Black Boot Mine",
    [36] = "Castle Black Boot Farm",
    [37] = "Farragut Keep Lumbermill",
    [38] = "Farragut Keep Mine",
    [39] = "Farragut Keep Farm",
    [40] = "Fort Warden Farm",
    [41] = "Fort Warden Lumbermill",
    [42] = "Fort Warden Mine",
    [43] = "Castle Faregyl Farm",
    [44] = "Castle Faregyl Lumbermill",
    [45] = "Castle Faregyl Mine",
    [46] = "Arrius Keep Farm",
    [47] = "Arrius Keep Lumbermill",
    [48] = "Arrius Keep Mine",
    [49] = "Fort Glademist Farm",
    [50] = "Fort Glademist Lumbermill",
    [51] = "Fort Glademist Mine",
    [52] = "Kingscrest Keep Farm",
    [53] = "Kingscrest Keep Lumbermill",
    [54] = "Kingscrest Keep Mine",
    [55] = "Fort Rayles Farm",
    [56] = "Fort Rayles Lumbermill",
    [57] = "Fort Rayles Mine",
    [61] = "Fort Ash Farm",
    [62] = "Fort Ash Lumbermill",
    [63] = "Fort Ash Mine",
    [64] = "Fort Aleswell Mine",
    [65] = "Fort Aleswell Lumbermill",
    [66] = "Fort Aleswell Farm",
    [67] = "Fort Dragonclaw Mine",
    [68] = "Fort Dragonclaw Lumbermill",
    [69] = "Fort Dragonclaw Farm",
    [70] = "Chalman Keep Mine",
    [71] = "Chalman Keep Lumbermill",
    [72] = "Chalman Keep Farm",
    [73] = "Blue Road Keep Mine",
    [74] = "Blue Road Keep Lumbermill",
    [75] = "Blue Road Keep Farm",
    [76] = "Drakelowe Keep Mine",
    [77] = "Drakelowe Keep Lumbermill",
    [78] = "Drakelowe Keep Farm",
    [79] = "Castle Alessia Mine",
    [80] = "Castle Alessia Lumbermill",
    [81] = "Castle Alessia Farm",
    [82] = "Castle Roebeck Mine",
    [83] = "Castle Roebeck Lumbermill",
    [84] = "Castle Roebeck Farm",
    [85] = "Castle Brindle Mine",
    [86] = "Castle Brindle Lumbermill",
    [87] = "Castle Brindle Farm"
}

CyrodiilMissionShare.commonCommands = {
	[1] = 'capture',
	[2] = 'scroll',
	[3] = 'kill',
	--[4] = 'keep',
	[5] = 'fort',
	[6] = 'castle'
}

CyrodiilMissionShare.TimeZones = {[1]='1 AM',[2]='2 AM',[3]='3 AM',[4]='4 AM',[5]='5 AM',[6]='6 AM',[7]='7 AM',[8]='8 AM',[9]='9 AM',[10]='10 AM',[11]='11 AM',[12]='12 PM',[13]='1 PM',[14]='2 PM',[15]='3 PM',[16]='4 PM',[17]='5 PM',[18]='6 PM',[19]='7 PM',[20]='8 PM',[21]='9 PM',[22]='10 PM',[23]='11 PM',[24]='12 AM'}
CyrodiilMissionShare.HourNumbers = {[1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,[16]=16,[17]=17,[18]=18,[19]=19,[20]=20,[21]=21,[22]=22,[23]=23,[24]=0}

function CyrodiilMissionShare:Initialize()
	CyrodiilMissionShare.playerAtName = GetUnitDisplayName('player')
	CyrodiilMissionShare.playerAlliance = GetUnitAlliance('player')

	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_CHAT_MESSAGE_CHANNEL, CyrodiilMissionShare.onChatMessage)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_QUEST_SHARED, CyrodiilMissionShare.onQuestShared)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_QUEST_COMPLETE, CyrodiilMissionShare.onQuestCompleted)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_QUEST_ADDED , CyrodiilMissionShare.onQuestAdded)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_PLAYER_ACTIVATED, CyrodiilMissionShare.OnPlayerActivated)
	EVENT_MANAGER:RegisterForUpdate(CyrodiilMissionShare.name, 5000, CyrodiilMissionShare.checkForShare)
	--EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_QUEST_COMPLETE_DIALOG, CyrodiilMissionShare.onQuestCompleteDialog)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_ARTIFACT_SCROLL_STATE_CHANGED, CyrodiilMissionShare.onScrollStateChange)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_ZONE_CHANGED, CyrodiilMissionShare.onZoneUpdate)
	EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, CyrodiilMissionShare.keepAllianceOwnerChanged)
end

-- Loads the addon; only hit once
function CyrodiilMissionShare.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= CyrodiilMissionShare.name then
		return
	end

	CyrodiilMissionShare.SV = ZO_SavedVars:New("CyrodiilMissionShareTrackerSettings", 1.1, "Settings", CyrodiilMissionShare.defaults)
	CyrodiilMissionShare:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(CyrodiilMissionShare.name, EVENT_ADD_ON_LOADED)

	CyrodiilMissionShare:Initialize()
	CyrodiilMissionShare:SetupCommands()
end

-- look to see if you can share a quest
function CyrodiilMissionShare.onZoneUpdate(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
	CyrodiilMissionShare.playerZoneId = CyrodiilMissionShare.getKeepId(subZoneName)

	if CyrodiilMissionShare.SV.autoShareCaptureQuest == false or CyrodiilMissionShare.playerInPvP == false or CyrodiilMissionShare.isPlayerInGroup() == false or subZoneName == '' then
		return
	end

	local keepNames = {'Keep', 'Castle', 'Fort'}
    local resourceNames = {'Lumbermill', 'Mine', 'Farm'}
	local locationString = ''

	-- only want to look at keeps and resources
	for i = 1,3 do
        if string.find(subZoneName, keepNames[i]) then
            locationString = subZoneName
			break
        end
    end

	if locationString == '' then
		for i = 1,3 do
			if string.find(subZoneName, resourceNames[i]) then
				locationString = subZoneName
				break
			end
		end
	end

	if locationString == '' then
		return
	end

	-- check if keep / resource is owned by your alliance
	local keepId = CyrodiilMissionShare.getKeepId(locationString)

	if keepId ~= nil then
		-- don't want to share if your alliance currently owns it
		if GetKeepAlliance(keepId, BGQUERY_LOCAL) == CyrodiilMissionShare.playerAlliance then
			return
		end
	end

    for i = 1,3 do
        if string.find(subZoneName, resourceNames[i]) then
            for j = 1,3 do
				if string.find(subZoneName, keepNames[j]) then
					locationString = string.gsub(subZoneName, keepNames[j], '')

					break
				end
			end

			break
        end
    end

	if CyrodiilMissionShare.lastZoneShared == locationString then
		return
	end

	CyrodiilMissionShare.isMissionQuest("capture " .. locationString, CyrodiilMissionShare.playerAtName)

	-- helpful if you are running across the zone line again and again
	CyrodiilMissionShare.lastZoneShared = locationString
end

function CyrodiilMissionShare.getKeepId(lookingKeepName)
	for keepId, keepName in pairs(CyrodiilMissionShare.keeps) do
		if keepName == lookingKeepName then
			return keepId
		end
	end
end

-- activated whenever you start requesting a quest
function CyrodiilMissionShare.checkForShare()
	if CyrodiilMissionShare.playerIsLooking == false then
		return
	end
	
	--d("Doesn't look like anyone has that quest!")
	
	CyrodiilMissionShare.playerIsLooking = false
end

function CyrodiilMissionShare.onScrollStateChange(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext, objectiveName, objectiveControlEvent, objectiveControlState, originalOwnerAlliance, holderAlliance, lastHolderAlliance, capturedAtKeepId, pinType)
	if CyrodiilMissionShare.SV.autoShareScrollQuest == false then
		return
	end

	if holderAlliance == CyrodiilMissionShare.playerAlliance then
		CyrodiilMissionShare.isMissionQuest("scroll The " .. objectiveName, CyrodiilMissionShare.playerAtName)
	end
end

-- part of auto-complete code
function CyrodiilMissionShare.onQuestCompleteDialog(eventCode, journalQuestIndex)
	if CyrodiilMissionShare.SV.autoCompleteQuest == false then
		return
	end

	local questType = GetJournalQuestType(journalQuestIndex) 

	if questType ~= QUEST_TYPE_AVA then
		return
	end

	CompleteQuest()
end

-- whenever you complete a quest
function CyrodiilMissionShare.onQuestCompleted(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType,instanceDisplayType) 
	if questType ~= QUEST_TYPE_AVA then
		return
	end

	for playerType, haveDone in pairs(CyrodiilMissionShare.SV.killQuests) do
		if haveDone == false then
			if questName == 'Kill Enemy ' .. playerType then
				CyrodiilMissionShare.SV.killQuests[playerType] = true
				CyrodiilMissionShare.SV.lastKillFinishTime = GetTimeStamp()
				CyrodiilMissionShare.ResetTime()
				break
			end
		end
	end

	if questName == 'Capture All Three Towns' or questName == 'Capture Any Nine Resources' or questName == 'Capture Any Three Keeps' then
		CyrodiilMissionShare.SV.captureTownQuests = {}
		CyrodiilMissionShare.SV.captureResourceQuests = {}
		CyrodiilMissionShare.SV.captureKeepQuests = {}
	end
end

-- whenever a quest is shared with you
function CyrodiilMissionShare.onQuestShared(eventCode, questId)
	local questName, characterName, _, _ = GetOfferedQuestShareInfo(questId)

	--[[if CyrodiilMissionShare.SV.autoDeclineWardens == true and questName == 'Kill Enemy Wardens' then
		DeclineSharedQuest(questId)
		return
	end]]

	if CyrodiilMissionShare.SV.autoAcceptRequest == true and IsUnitInCombat('player') == true and IsPlayerInAvAWorld() == true then
		d("Accepted " .. questName .. " from " .. characterName)
		AcceptSharedQuest(questId)
	end

	if CyrodiilMissionShare.playerIsLooking == false then
		return
	end

	if CyrodiilMissionShare.SV.autoAcceptRequest == true then
		d("Accepted " .. questName .. " from " .. characterName)
		AcceptSharedQuest(questId)
	end
	
	CyrodiilMissionShare.playerIsLooking = false
end

-- check to see if we're group or solo
function CyrodiilMissionShare.isPlayerInGroup()
	if GetGroupSize() > 0 then
		return true
	end

	return false
end

-- whenever you add a quest
function CyrodiilMissionShare.onQuestAdded(eventCode, journalQuestIndex, questName, objectiveName)
	if questName == 'Capture All Three Towns' or questName == 'Capture Any Nine Resources' or questName == 'Capture Any Three Keeps' then
		CyrodiilMissionShare.SV.captureTownQuests = {}
		CyrodiilMissionShare.SV.captureResourceQuests = {}
		CyrodiilMissionShare.SV.captureKeepQuests = {}
	end

	CyrodiilMissionShare.ResetTime()

	-- only share if in group
	if CyrodiilMissionShare.isPlayerInGroup() == false then
		return
	end

	if CyrodiilMissionShare.SV.autoShareKillQuest == false then
		CyrodiilMissionShare.questWasShared = false
		return
	end

	--[[if CyrodiilMissionShare.SV.autoDeclineWardens == true and questName == 'Kill Enemy Wardens' then
		return
	end]]

	if string.find(questName, 'Kill Enemy') and CyrodiilMissionShare.playerIsLooking == false then
		d("Sharing quest: "..questName)
		ShareQuest(journalQuestIndex)
	end
end

-- set-up slash commands for chat window
function CyrodiilMissionShare:SetupCommands()
	SLASH_COMMANDS["/sharequest"] = function (extra)
		local pieces = CyrodiilMissionShare.string_split(extra)

		if #pieces >= 1 then
			CyrodiilMissionShare.isMissionQuest(extra, CyrodiilMissionShare.playerAtName)
		else
			CyrodiilMissionShare.shareAllPVPQuests()
		end
	end

	SLASH_COMMANDS["/scroll"] = function (extra)
		local pieces = CyrodiilMissionShare.string_split(extra)

		if #pieces == 1 then
			CHAT_SYSTEM:StartTextEntry('cms scroll ' .. extra, CHAT_CHANNEL_PARTY)
		end
	end

	SLASH_COMMANDS["/capture"] = function (extra)
		local pieces = CyrodiilMissionShare.string_split(extra)

		if #pieces >= 1 then
			CHAT_SYSTEM:StartTextEntry('cms capture ' .. extra, CHAT_CHANNEL_PARTY)
		end
	end
	
	SLASH_COMMANDS["/killquests"] = function (extra)
		CyrodiilMissionShare.ResetTime()
	
		local finishedAll = true
		local message = "You still need to do any of the following 'Kill Enemy' quests: "
	
		for playerType, haveDone in pairs(CyrodiilMissionShare.SV.killQuests) do
			--[[if CyrodiilMissionShare.SV.autoDeclineWardens == true and playerType == 'Wardens' then
				-- do nothing
			else]]if haveDone == false then
				message = message .. playerType .. " "
				finishedAll = false
			end
		end
		
		if finishedAll == true then
			message = "You have done all the Bounty Mission Quests!"
		end
		
		d(message)
	end

	SLASH_COMMANDS["/capturequests"] = function (extra)
		local pieces = CyrodiilMissionShare.string_split(extra)

		if #pieces >= 1 then
			local text = string.lower(extra)

			if string.find(text, 'keep') then
				CyrodiilMissionShare.printCapture('keep')
			elseif string.find(text, 'resource') then
				CyrodiilMissionShare.printCapture('resource')
			elseif string.find(text, 'town') then
				CyrodiilMissionShare.printCapture('town')
			end
		else
			CyrodiilMissionShare.printCapture('keep')
			CyrodiilMissionShare.printCapture('resource')
			CyrodiilMissionShare.printCapture('town')
		end
	end

	SLASH_COMMANDS["/resetcapturequests"] = function (extra)
		CyrodiilMissionShare.SV.captureKeepQuests = {}
		CyrodiilMissionShare.SV.captureResourceQuests = {}
		CyrodiilMissionShare.SV.captureTownQuests = {}
	end

	SLASH_COMMANDS["/kill"] = function (extra)
		CyrodiilMissionShare.ResetTime()

		local pieces = CyrodiilMissionShare.string_split(extra)

		CyrodiilMissionShare.playerIsLooking = true

		if #pieces == 1 then
			CHAT_SYSTEM:StartTextEntry('cms kill ' .. extra, CHAT_CHANNEL_PARTY)
		else
			for playerType, haveDone in pairs(CyrodiilMissionShare.SV.killQuests) do
				--[[if CyrodiilMissionShare.SV.autoDeclineWardens == true and playerType == 'Wardens' then
					-- do nothing
				else]]if haveDone == false then
					CHAT_SYSTEM:StartTextEntry('cms kill ' .. playerType, CHAT_CHANNEL_PARTY)
					break
				end
			end
		end
	end

	SLASH_COMMANDS["/cmshelp"] = function (extra)
		d("All commands only work in group chat, since you can only share quests with your group. All commands start with 'cms ', followed by the command. Some example commands: 'cms capture alessia', 'cms scroll mnem', 'cms kill templars', 'cms alma ruma', 'cms sorcs', 'cms brk farm', 'cms kill enemy players', 'cms capture fare'.")
	end
end

function CyrodiilMissionShare.printCapture(captureType)
	local message = "You have captured the following '"..captureType.."' quests: "

	local array = nil
	local noneDone = true

	if captureType == 'keep' then
		array = CyrodiilMissionShare.SV.captureKeepQuests
	elseif captureType == 'resource' then
		array = CyrodiilMissionShare.SV.captureResourceQuests
	elseif captureType == 'town' then
		array = CyrodiilMissionShare.SV.captureTownQuests
	end

	if array == nil then
		return
	end

	local counter = 0

	for keepId, _ in pairs(array) do
		if counter == 0 then
			message = message .. CyrodiilMissionShare.keeps[keepId]
			counter = counter + 1
		else
			message = message .. ', ' .. CyrodiilMissionShare.keeps[keepId]
		end

		noneDone = false
	end

	if noneDone == true then
		message = message .. 'None'
	end

	d(message)
end

-- helper function for SetupCommands
function CyrodiilMissionShare.string_split(string, pattern)
	pattern = pattern or "%S+"
	local array = {}

	for i in string.gmatch(string, pattern) do
		table.insert(array, i)
	end

	return array
end

function CyrodiilMissionShare.printHintMessage()
	d("HINT: The command needs to be 'cms ', optionally followed by 'kill', 'capture', or 'scroll', then the appropriate text. EX: 'cms kill players', 'cms capture alessia farm', 'cms scroll mnem', 'cms sorcs', 'cms brk', 'cms alma ruma', 'cms 40 player', 'cms town'.")
end

function CyrodiilMissionShare.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- scan for messages that are with 'cms'
function CyrodiilMissionShare.onChatMessage(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
	if fromName == nil or fromName == "" then
		return
	end

	text = CyrodiilMissionShare.trim(text)

	-- only look for requests from group, since you can only share with group
	if channelType ~= CHAT_CHANNEL_PARTY then
		if fromDisplayName == CyrodiilMissionShare.playerAtName then
			local message = string.sub(text, 1, string.len(CyrodiilMissionShare.searchString))

			if string.lower(message) == CyrodiilMissionShare.searchString then
				d("Remember to place the command in group chat!")

				CHAT_SYSTEM:StartTextEntry(text, CHAT_CHANNEL_PARTY)
			end
		end

		return
	end

	local from = zo_strformat("<<1>>", fromName)
	local message = string.sub(text, 1, string.len(CyrodiilMissionShare.searchString))

	if string.lower(message) == CyrodiilMissionShare.searchString then
		local requestType = string.sub(text, string.len(CyrodiilMissionShare.searchString)+2)

		if string.len(requestType) > 1 then
			if fromDisplayName == CyrodiilMissionShare.playerAtName then
				CyrodiilMissionShare.playerTypeRequest = nil
				local questName = CyrodiilMissionShare.getMissionQuest(requestType, fromDisplayName)

				if questName ~= nil then
					if CyrodiilMissionShare.hasMissionQuest(questName) == true then
						d("You already have '" .. questName .. "' in your Quest Journal!")
					--[[elseif CyrodiilMissionShare.hasMissionQuestType() == true then
						d("You already have a '" .. CyrodiilMissionShare.playerTypeRequest .. "' quest in your Quest Journal!")]]
					else
						d("Looking for: " .. questName)
					end
				else
					-- check for 'Did you mean'
					CyrodiilMissionShare.checkLikelyCommands(requestType)
				end

				CyrodiilMissionShare.playerIsLooking = true
				return
			end

			CyrodiilMissionShare.isMissionQuest(requestType, fromDisplayName)
		end
	end
end

function CyrodiilMissionShare.findMatches(questGroup, command)
	local matches = 0

	for i = 1, #questGroup do
		local c = questGroup:sub(i,i)

		for j = (i-1), math.min((i+1), #command) do
			local n = command:sub(j,j)

			if n == c then
				matches = matches + 1
				break
			end
		end
	end

	-- d(match .. " / " .. #questGroup)

	return matches
end

function CyrodiilMissionShare.getSuggestions(questGroup, partialName, suggestions)
	partialName = string.lower(partialName)

	local matches = CyrodiilMissionShare.findMatches(questGroup, partialName)

	if matches > 0 then
		local percentage = (matches / #questGroup) * 100

		if percentage < 0 then
			percentage = 0
		end

		percentage = tonumber(string.format("%.0f", percentage))

		if percentage > 70 then
			--d(partialName .. " " .. tostring(percentage) .. "%")
			if suggestions == nil then
				suggestions = "'" .. partialName .. "'"
			else
				if string.find(suggestions, partialName) then
					-- don't add
				else
					suggestions = suggestions .. " OR '" .. partialName .. "'"
				end
			end
		end
	end

	return suggestions
end

function CyrodiilMissionShare.checkLikelyCommands(request)
	local questGroup = CyrodiilMissionShare.clearOutString(request)
	local suggestions = nil

	for partialName, _ in pairs(CyrodiilMissionShare.keepNames) do
		suggestions = CyrodiilMissionShare.getSuggestions(questGroup, partialName, suggestions)
	end

	if suggestions == nil then
		for _, fullName in pairs(CyrodiilMissionShare.scrollQuests) do
			suggestions = CyrodiilMissionShare.getSuggestions(questGroup, fullName, suggestions)
		end
	end

	if suggestions == nil then
		for _, fullName in pairs(CyrodiilMissionShare.killQuests) do
			suggestions = CyrodiilMissionShare.getSuggestions(questGroup, fullName, suggestions)
		end
	end

	if suggestions ~= nil then
		d("That command did not work. Did you mean: " .. suggestions)
	else
		d("That command did not work!")
		CyrodiilMissionShare.printHintMessage()
	end
end

function CyrodiilMissionShare.checkCapture(questGroup)
	for resourceNickName, resourceName in pairs(CyrodiilMissionShare.resourceNames) do
		if string.find(questGroup, string.lower(resourceName)) or string.find(questGroup, string.lower(resourceNickName)) then
			for nickName, keepName in pairs(CyrodiilMissionShare.keepNicknames) do
				if string.find(questGroup, string.lower(nickName)) or string.find(questGroup, string.lower(keepName)) then
					CyrodiilMissionShare.playerTypeRequest = 'Capture'
					return 'Capture ' .. keepName .. ' ' .. resourceName
				end
			end

			break
		end
	end

	for nickName, keepName in pairs(CyrodiilMissionShare.keepNicknames) do
		if string.find(questGroup, string.lower(nickName)) or string.find(questGroup, string.lower(keepName)) then
			CyrodiilMissionShare.playerTypeRequest = 'Capture'
			return 'Capture ' .. CyrodiilMissionShare.keepNames[keepName]
		end
	end

	if string.find(questGroup, string.lower('Keep')) then
		CyrodiilMissionShare.playerTypeRequest = 'Capture'
		return 'Capture Any Three Keeps'
	elseif string.find(questGroup, string.lower('Resource')) then
		CyrodiilMissionShare.playerTypeRequest = 'Capture'
		return 'Capture Any Nine Resources'
	elseif string.find(questGroup, string.lower('Town')) then
		CyrodiilMissionShare.playerTypeRequest = 'Capture'
		return 'Capture All Three Towns'
	end
end

function CyrodiilMissionShare.checkKill(questGroup)
	if string.find(questGroup, string.lower('40')) and string.find(questGroup, string.lower('player')) then
		CyrodiilMissionShare.playerTypeRequest = 'Kill'
		return 'Kill 40 Enemy Players'
	end

	for nickName, killName in pairs(CyrodiilMissionShare.killQuests) do
		if questGroup == nickName or string.find(questGroup, nickName) then
			CyrodiilMissionShare.playerTypeRequest = 'Kill'
			return 'Kill Enemy ' .. killName
		end
	end
end

function CyrodiilMissionShare.checkScroll(questGroup)
	for nickName, scrollName in pairs(CyrodiilMissionShare.scrollQuests) do
		if questGroup == nickName or string.find(questGroup, nickName) then
			CyrodiilMissionShare.playerTypeRequest = 'Scroll'
			return 'The Elder Scroll of ' .. scrollName
		end
	end
end

function CyrodiilMissionShare.clearOutString(questGroup)
	questGroup = string.lower(questGroup)

	for _, command in pairs(CyrodiilMissionShare.commonCommands) do
		if string.find(questGroup, command) then
			questGroup = questGroup:gsub(command .. " ", "")
			questGroup = questGroup:gsub(command, "")
		end
	end

	return questGroup
end

function CyrodiilMissionShare.getMissionQuest(request, fromDisplayName)
	local questGroup = CyrodiilMissionShare.clearOutString(request)

	if string.find(request, 'warden') then
		if string.find(request, 'capture') then
			return CyrodiilMissionShare.checkCapture(questGroup)
		elseif string.find(request, 'kill') then
			return CyrodiilMissionShare.checkKill(questGroup)
		end

		if fromDisplayName == CyrodiilMissionShare.playerAtName then
			d("Please specify either the kill quest for wardens by typing 'cms kill wardens' or the capture fort warden quest by typing 'cms capture warden'")
		end

		return nil
	end

	local quest = nil

	if quest == nil then
		quest = CyrodiilMissionShare.checkCapture(questGroup)
	end

	if quest == nil then
		quest = CyrodiilMissionShare.checkKill(questGroup)
	end

	if quest == nil then
		quest = CyrodiilMissionShare.checkScroll(questGroup)
	end

	return quest
end

-- Checks for request from group chat for capture, kill or scroll
function CyrodiilMissionShare.isMissionQuest(request, fromDisplayName)
	local questName = CyrodiilMissionShare.getMissionQuest(request, fromDisplayName)

	if questName ~= nil then
		CyrodiilMissionShare.findMissionQuest(questName)
	end
end

function CyrodiilMissionShare.hasMissionQuest(questString)
	for journalQuestIndex = 1, GetNumJournalQuests() do
		local questType = GetJournalQuestType(journalQuestIndex) 

		if questType == QUEST_TYPE_AVA then
			local questName = GetJournalQuestName(journalQuestIndex)

			if questName == questString then
				return true
			end
		end
	end

	return false
end

function CyrodiilMissionShare.hasMissionQuestType()
	if CyrodiilMissionShare.playerTypeRequest == nil then
		return false
	end

	for journalQuestIndex = 1, GetNumJournalQuests() do
		local questType = GetJournalQuestType(journalQuestIndex) 

		if questType == QUEST_TYPE_AVA then
			local questName = GetJournalQuestName(journalQuestIndex)

			if string.find(questName, CyrodiilMissionShare.playerTypeRequest) then
				CyrodiilMissionShare.playerTypeRequest = questName
				return true
			end
		end
	end

	return false
end

-- share a specific quest
function CyrodiilMissionShare.findMissionQuest(questString)
	for journalQuestIndex = 1, GetNumJournalQuests() do
		local questType = GetJournalQuestType(journalQuestIndex) 

		if questType == QUEST_TYPE_AVA then
			local questName = GetJournalQuestName(journalQuestIndex)

			if questName == questString then
				d("Sharing Quest: " .. questName)
				ShareQuest(journalQuestIndex)
				break
			end
		end
	end
end

-- Share all your Cyro daily quests
function CyrodiilMissionShare.shareAllPVPQuests()
	for journalQuestIndex = 1, GetNumJournalQuests() do
		local questType = GetJournalQuestType(journalQuestIndex) 

		if questType == QUEST_TYPE_AVA then
			local questName = GetJournalQuestName(journalQuestIndex)
			d("Sharing Quest: " .. questName)
			ShareQuest(journalQuestIndex)
		end
	end
end

-- Everytime the user 'loads', either by transitioning between zones or just reloading
function CyrodiilMissionShare.OnPlayerActivated(eventCode, initial)
	CyrodiilMissionShare.playerInPvP = IsPlayerInAvAWorld()
	CyrodiilMissionShare.ResetTime()
end

function CyrodiilMissionShare.resetKillQuests()
	d("Kill Quest Timer has been reset!")

	CyrodiilMissionShare.SV.lastKillFinishTime = nil

	CyrodiilMissionShare.SV.killQuests = {
		['Players'] = false,
		['Templars'] = false,
		['Nightblades'] = false,
		['Sorcerers'] = false,
		['Dragonknights'] = false,
		['Wardens'] = false,
		['Necromancers'] = false
	}
end

-- Figure out if we need to reset the kill quests
function CyrodiilMissionShare.ResetTime()
	if CyrodiilMissionShare.SV.lastKillFinishTime == nil then
		return
	end

	local datestring = tostring(GetDate())
	local timestring = tostring(GetTimeString())

	local year = tonumber(datestring:sub(1,4))
	local month = tonumber(datestring:sub(5,6))
	local day = tonumber(datestring:sub(7,8))
	local hour = tonumber(CyrodiilMissionShare.HourNumbers[CyrodiilMissionShare.SV.timezone])
	local minute = tonumber(timestring:sub(4,5))
	local second = tonumber(timestring:sub(7,8))

	local offset = os.time() - os.time(os.date("!*t"))
	local timeZoneTimeStamp = os.time({day=day,month=month,year=year,hour=hour,min=minute,sec=second})+offset

	-- current time in their time zone must be more then last kill
	-- so if I killed last at 9 PM and logged in at 7 AM, it should reset
	-- but if I log in at 1 AM, it shouldn't reset until the current time is greater then the current timezone
	if timeZoneTimeStamp >= CyrodiilMissionShare.SV.lastKillFinishTime and GetTimeStamp() >= timeZoneTimeStamp then
		CyrodiilMissionShare.resetKillQuests()
	end
end

function CyrodiilMissionShare.keepAllianceOwnerChanged(eventCode, keepId, battlegroundContext, owningAlliance, oldOwningAlliance)
	if owningAlliance ~= CyrodiilMissionShare.playerAlliance or CyrodiilMissionShare.keeps[keepId] == nil or keepId ~= CyrodiilMissionShare.playerZoneId then
		return
	end

	-- tell if resource, town or keep
	local name = string.lower(CyrodiilMissionShare.keeps[keepId])

	if string.find(name, 'farm') or string.find(name, 'lumbermill') or string.find(name, 'mine') then
		CyrodiilMissionShare.SV.captureResourceQuests[keepId] = true
	elseif string.find(name, 'keep') or string.find(name, 'fort') or string.find(name, 'castle') then
		CyrodiilMissionShare.SV.captureKeepQuests[keepId] = true
	elseif string.find(name, 'vlastarus') or string.find(name, 'bruma') or string.find(name, 'cropsford') then
		CyrodiilMissionShare.SV.captureTownQuests[keepId] = true
	end
end

-- Creates the addon settings menu
function CyrodiilMissionShare:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "Cyrodiil Mission Share",
		displayName = "|c66ccffCyrodiil Mission Share",
		author = "|c4779ce@aldericon|r",
		version = string.format("%.2f", CyrodiilMissionShare.version),
		slashCommand = "/cms",
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("Cyrodiil_Mission_Share", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "Cyrodiil Mission Share helps with auto-sharing the Kill, Capture and Scroll quests found on, or near, the Mission Boards at your PVP base. Use commands such as '/killquests' to see what 'Kill Enemy' quests you've already done, or '/sharequest' to share all Cyro-related quests with the group. See ESOUI Website page for full list of commands and explanations.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Cyrodiil Mission Share Options",
	})
	--[[table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Decline 'Kill Enemy Wardens' Quest",
		tooltip = "ON - will auto-decline this quest, if shared, OFF - will not auto-decline this quest, if shared",
		default = self.defaults.autoDeclineWardens,
		getFunc = function() return self.SV.autoDeclineWardens end,
		setFunc = function(newValue) self.SV.autoDeclineWardens = newValue end,
	})]]
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Accept Cyrodiil Quest",
		tooltip = "ON - will auto-accept that quest when you request that quest OR when in combat in PVP, OFF - will never auto-accept requested quest",
		default = self.defaults.autoAcceptRequest,
		getFunc = function() return self.SV.autoAcceptRequest end,
		setFunc = function(newValue) self.SV.autoAcceptRequest = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Share Kill Enemy Quests",
		tooltip = "ON - will auto-share with group as you pick up each 'Kill Enemy' quest, OFF - will never auto-share 'Kill Enemy' quest",
		default = self.defaults.autoShareKillQuest,
		getFunc = function() return self.SV.autoShareKillQuest end,
		setFunc = function(newValue) self.SV.autoShareKillQuest = newValue end,
	})
	--[[table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Complete any Cyrodiil Quest",
		tooltip = "ON - will autocomplete any PVP quest when at the mission boards, OFF - won't auto-complete the quest",
		default = self.defaults.autoCompleteQuest,
		getFunc = function() return self.SV.autoCompleteQuest end,
		setFunc = function(newValue) self.SV.autoCompleteQuest = newValue end,
	})]]
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Share Capture Quests",
		tooltip = "ON - as you enter each Resource or Keep, the addon will check if you have that quest and auto-share with your group, OFF - will never auto-share 'Capture' quest",
		default = self.defaults.autoShareCaptureQuest,
		getFunc = function() return self.SV.autoShareCaptureQuest end,
		setFunc = function(newValue) self.SV.autoShareCaptureQuest = newValue end,
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Auto-Share Scroll Quests",
		tooltip = "ON - when someone in your alliance picks up a scroll, if you have that scroll quest, it will auto-share with your group, OFF - will never auto-share 'Scroll' quest",
		default = self.defaults.autoShareScrollQuest,
		getFunc = function() return self.SV.autoShareScrollQuest end,
		setFunc = function(newValue) self.SV.autoShareScrollQuest = newValue end,
	})
	table.insert(optionsData, {
		type = "header",
		name = "Quest Reset Time",
	})
	table.insert(optionsData, {
		type = "description",
		text = "Daily reset occurs at 2 AM EDT / 11 PM PDT (during Daylight Savings) or 1 AM EST/10 PM PST (after Daylight Savings ends). Adjust your local reset time accordingly below. This is set so the addon knows when to reset your tracked kill quests.",
	})
	table.insert(optionsData, {
		type = "dropdown",
		name = "Quest Reset Time:",
		tooltip = "Select the time (your local time) when daily quests reset.",
		choices = CyrodiilMissionShare.TimeZones,
		getFunc = function() return CyrodiilMissionShare.TimeZones[CyrodiilMissionShare.SV.timezone] end,
		setFunc = function(selected)
				for k,v in ipairs(CyrodiilMissionShare.TimeZones) do
					if v == selected then
						CyrodiilMissionShare.SV.timezone = k
						break
					end
				end
				CyrodiilMissionShare.ResetTime()
		end,
		default = 3,
	})
	table.insert(optionsData, {
		type = "button",
		name = "Reset Kill Quests Tracker",
		tooltip = 'Manually reset your kill quests tracker, if needed',
		func = function ()
			CyrodiilMissionShare.resetKillQuests()
		end,
	})

	self.LAM2:RegisterOptionControls("Cyrodiil_Mission_Share", optionsData)	
end

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(CyrodiilMissionShare.name, EVENT_ADD_ON_LOADED, CyrodiilMissionShare.OnAddOnLoaded)