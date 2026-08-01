-- ***** Pawprint's PVP Tools - Quest Share *****



--------------------------------------------------
-- Initialize our namespace
--------------------------------------------------
if not PVPTools then PVPTools = {} end
if not PVPTools.QuestShare then PVPTools.QuestShare = {} end
local PT = PVPTools
local QS = PVPTools.QuestShare
local listenString = "qs"

-- "|c00ffff" - color used to identify all quest share messages PT.colorQuestShare


--------------------------------------------------
-- Initialize Data
--------------------------------------------------
QS.ICQuests = { -- Verified
	"Dousing the Fires of Industry",	-- Elven Gardens
	"Historical Accuracy",				-- Arboretum
	"Priceless Treasures",				-- Temple
	"Speaking For The Dead",			-- Memorial
	"The Lifeblood of an Empire",		-- Arena
	"Watch Your Step"					-- Nobles
}

QS.ICKeywords = {
	["elven"]		="industry",
	["arboretum"]	= "accuracy",
	["temple"]		= "treasures",
	["memorial"]	= "speaking",
	["arena"]		= "lifeblood",
	["nobles"]		= "step"
}

QS.ConquestQuestsNames = {
	["resources"] 	= "Capture Any Nine Resources",
	["keeps"] 		= "Capture Any Three Keeps",
	["towns"]		= "Capture All 3 Towns",
	["150"]			= "Kill 150 Enemy Players:",
}

QS.ScrollQuests = { -- TODO test
	["chim"] 		= "Chim",
	
	["ghartok"] 	= "Ghartok",
	["gartok"]		= "Ghartok",
	["ghar"]		= "Ghartok",
	["gar"]			= "Ghartok",
	
	["ni-mohk"]		= "Ni-Mohk",
	["ni-monk"]		= "Ni-Mohk",
	["ni-mokh"]		= "Ni-Mohk",
	["nimohk"]		= "Ni-Mohk",
	["nimonk"]		= "Ni-Mohk",
	["nimokh"]		= "Ni-Mohk",
	["ni"]			= "Ni-Mohk",
	
	["alma-ruma"]	= "Alma Ruma",
	["almaruma"]	= "Alma Ruma",
	["alma"]		= "Alma Ruma",
	
	["altadoon"]	= "Altadoon",
	["alta"]		= "Altadoon",
	["doon"]		= "Altadoon",
	
	["mnem"]		= "Mnem",
}

QS.KillQuests = { -- TODO test
	["players"] 		= "Players",
	["player"]			= "Players",

	["templars"]		= "Templars",
	["templar"]			= "Templars",
	["temp"]			= "Templars",
	["temps"]			= "Templars",

	["nightblades"]		= "Nightblades",
	["nightblade"]		= "Nightblades",
	["nb"]				= "Nightblades",
	["nbs"]				= "Nightblades",

	["sorcerers"]		= "Sorcerers",
	["sorcerer"]		= "Sorcerers",
	["sorc"]			= "Sorcerers",
	["sorcs"]			= "Sorcerers",

	["dragonknights"]	= "Dragonknights",
	["dragonknight"]	= "Dragonknights",
	["dk"]				= "Dragonknights",
	["dks"]				= "Dragonknights",

	["wardens"]			= "Wardens",
	["wdn"]				= "Wardens",
	["wdns"]			= "Wardens",

	["necromancers"]	= "Necromancers",
	["necro"]			= "Necromancers",
	["necros"]			= "Necromancers",

	["arcanists"]		= "Arcanists",
	["arc"]				= "Arcanists",
	["arcs"]			= "Arcanists",
}

QS.Resources = {
	["lumbermill"]	= "Lumbermill",
	["lumber"]		= "Lumbermill",
	["lm"]			= "Lumbermill", 
	["farm"]		= "Farm",
	["mine"]		= "Mine",
}

QS.Locations = {
	["blackboot"]	= "Castle Black Boot",
	["boot"]		= "Castle Black Boot",
	["bb"]			= "Castle Black Boot",
	
	["bloodmayne"]	= "Castle Bloodmayne",
	["blood"]		= "Castle Bloodmayne",
	["bm"]			= "Castle Bloodmayne",
	
	["faregyl"]		= "Castle Faregyl",
	["faragyl"]		= "Castle Faregyl",
	["farragyl"]	= "Castle Faregyl",
	["ferregyl"]	= "Castle Faregyl",
	["feregyl"]		= "Castle Faregyl",
	["fare"]		= "Castle Faregyl",
	["gyl"]			= "Castle Faregyl",
	
	["alessia"]		= "Castle Alessia",
	
	["roebeck"]		= "Castle Roebeck",
	["roe"]			= "Castle Roebeck",
	
	["brindle"]		= "Castle Brindle",
	
	["drakelowe"]	= "Drakelowe Keep",
	["drakelow"]	= "Drakelowe Keep",
	["drake"]		= "Drakelowe Keep",
	
	["blueroad"]	= "Blue Road Keep",
	["blue"]		= "Blue Road Keep",
	["brk"]			= "Blue Road Keep",
	
	["farragut"]	= "Farragut Keep",
	["ferragut"]	= "Farragut Keep",
	["feregut"]		= "farragut Keep",
	["faragut"]		= "Farragut Keep",
	["farra"]		= "Farragut Keep",
	["gut"]			= "Farragut Keep",
	
	["arrius"]		= "Arrius Keep",
	
	["kingscrest"]	= "Kingscrest Keep",
	["kings"]		= "Kingscrest Keep",
	["king"]		= "Kingscrest Keep",
	
	["chalman"]		= "Chalman Keep",
	["chal"]		= "Chalman Keep",
	["chalamo"]		= "Chalman Keep",
	
	["ash"]			= "Fort Ash",
	
	["dragonclaw"]	= "Fort Dragonclaw",
	["dragon"]		= "Fort Dragonclaw",
	
	["aleswell"]	= "Fort Aleswell",
	["ales"]		= "Fort Aleswell",
	
	["glademist"]	= "Fort Glademist",
	["glade"]		= "Fort Glademist",
	
	["warden"]		= "Fort Warden",
	
	["rayles"]		= "Fort Rayles",
}

-- a table of the locations formated to be used in capture resouce quests
QS.ResourceLocations = {
	["blackboot"]	= "Black Boot",
	["boot"]		= "Black Boot",
	["bb"]			= "Black Boot",
	
	["bloodmayne"]	= "Bloodmayne",
	["bloodmane"]	= "Bloodmayne",
	["blood"]		= "Bloodmayne",
	["bm"]			= "Bloodmayne",
	
	["faregyl"]		= "Faregyl",
	["faragyl"]		= "Faregyl",
	["farragyl"]	= "Faregyl",
	["ferregyl"]	= "Faregyl",
	["feregyl"]		= "Faregyl",
	["fare"]		= "Faregyl",
	["gyl"]			= "Faregyl",
	
	["alessia"]		= "Alessia",
	
	["roebeck"]		= "Roebeck",
	["roe"]			= "Roebeck",
	
	["brindle"]		= "Brindle",
	
	["drakelowe"]	= "Drakelowe",
	["drake"]		= "Drakelowe",
	
	["blueroad"]	= "Blue Road",
	["blue"]		= "Blue Road",
	["brk"]			= "Blue Road",
	
	["farragut"]	= "Farragut",
	["ferragut"]	= "Farragut",
	["feregut"]		= "farragut",
	["faragut"]		= "Farragut",
	["farra"]		= "Farragut",
	["fara"]		= "Farragut",
	["gut"]			= "Farragut",
	
	["arrius"]		= "Arrius",
	
	["kingscrest"]	= "Kingscrest",
	["kings"]		= "Kingscrest",
	["king"]		= "Kingscrest",
	
	["chalman"]		= "Chalman",
	["chal"]		= "Chalman",
	["chalamo"]		= "Chalman",
	
	["ash"]			= "Ash",
	
	["dragonclaw"]	= "Dragonclaw",
	["dragon"]		= "Dragonclaw",
	
	["aleswell"]	= "Aleswell",
	["ales"]		= "Aleswell",
	
	["glademist"]	= "Glademist",
	["glade"]		= "Glademist",
	
	["warden"]		= "Warden",
	
	["rayles"]		= "Rayles",
}

QS.Conquest = {
	["resources"] 	= "Capture Any Nine Resources",
	["resource"] 	= "Capture Any Nine Resources",
	["rss"]			= "Capture Any Nine Resources",
	["keeps"]		= "Capture Any Three Keeps",
	["keep"]		= "Capture Any Three Keeps",
	["towns"]		= "Capture All 3 Towns",
	["town"]		= "Capture All 3 Towns",
	["150"]			= "Kill 150 Enemy Players",
}


QS.Exclusions = {
	"grounds",
	"bridge",
	"milegate",
	"temple",
	"gate",
	"fields"
}

-- quests
-- scrolls
-- keeps
-- resources
-- kill
-- conquest
-- IC

--------------------------------------------------
-- ToggleModule - turn module off or on depending on settings made in the addon menu
-- Called by setting in PT_Settings
--------------------------------------------------
function QS.ToggleModule() -- Verified
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ToggleModule") end

	PT.ASV.settingsQSModuleOn = not PT.ASV.settingsQSModuleOn

	if PT.ASV.settingsQSModuleOn then
		PT.CheckEventRegistrations()
		if PT.ASV.settingsQSTrackDaily and PT.QuestShare.DailyResetHappened() then PT.QuestShare.ResetDailyTimers() end	
	else
		PT.CheckEventRegistrations()
	end

end


--------------------------------------------------
-- ToggleAutoShare - toggle the auto share menu setting
-- Called by setting in PT_Settings
--------------------------------------------------
function QS.ToggleAutoShare() -- Verified
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ToggleAutoShare") end

	PT.ASV.settingsQSAutoShare = not PT.ASV.settingsQSAutoShare

	if PT.ASV.settingsQSAutoShare then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Turn on AutoShare") end

		PT.CheckEventRegistrations()
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Turn off AutoShare") end

		PT.CheckEventRegistrations()
	end
end


--------------------------------------------------
-- ToggleAutoAccept - toggle the auto share menu setting
-- Called by setting in PT_Settings
--------------------------------------------------
function QS.ToggleAutoAccept() -- Verified
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ToggleAutoAccept") end

	PT.ASV.settingsQSAutoAccept = not PT.ASV.settingsQSAutoAccept

	if PT.ASV.settingsQSAutoAccept then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Turn on AutoAccept") end

		PT.CheckEventRegistrations()
	else
		if PT.debug then PT.DebugEntry(PT.Spacer().."Turn off AutoAccept") end

		PT.CheckEventRegistrations()
	end
end


--------------------------------------------------
-- ToggleTrackDaily - toggle the daily pvp quest tracking setting
-- Called by setting in PT_Settings
--------------------------------------------------
function QS.ToggleTrackDaily()
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ToggleTrackDaily") end
	
	PT.ASV.settingsQSTrackDaily = not PT.ASV.settingsQSTrackDaily
	
	if PT.ASV.settingsQSTrackDaily then
		if PT.debug then PT.DebugEntry(PT.Spacer().."Turn on TrackDaily") end
		PT.CheckEventRegistrations()
		if PT.QuestShare.DailyResetHappened() then PT.QuestShare.ResetDailyTimers() end
	else
		if PT.debug then PT. DebugEntry(PT.Spacer().."Turn off TrackDaily") end
		PT.CheckEventRegistrations()
	end
end


--------------------------------------------------
-- ToggleAnnounce - toggle the use center screen announcement setting
-- Called by setting in PT_Settings
--------------------------------------------------
function QS.ToggleAnnounce()
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ToggleAnnounce") end
	PT.ASV.settingsQSCenterAnnounce = not PT.ASV.settingsQSCenterAnnounce
end


--------------------------------------------------
-- ToggleAlert - toggle the use right side alert setting
-- Called by setting in PT_Settings
--------------------------------------------------
function QS.ToggleAlert()
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ToggleAlert") end
	PT.ASV.settingsQSAlert = not PT.ASV.settingsQSAlert
end


--------------------------------------------------
-- OnQuestShared - when something happens with a scroll
--------------------------------------------------
function QS.ProcessQuestShared(questID)
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ProcessQuestShared") end

	local questName, characterName, msSinceRequest, displayName = GetOfferedQuestShareInfo(questID)

	-- cross-faction quest shares create a mess, if the user is in PVP and in a group then they are on the same faction
	if PT.IsPVPZone() then 
		AcceptSharedQuest(questID)
		local outputTable = {}
		table.insert(outputTable, "|c00ffffAccepted |r")
		table.insert(outputTable, questName)
		table.insert(outputTable, " |c00fffffrom ")
		table.insert(outputTable, displayName)
		table.insert(outputTable, "|r")
		PT.AMS.DisplayMessage(table.concat(outputTable, ""), "qs")
	end

end


--------------------------------------------------
-- ProcessMessage - check if the message is a share request and process the request
--------------------------------------------------
function QS.ProcessMessage(msgChannel, message, fromName)
	if PT.debug then 
		PT.DebugEntry("PVPTools.QuestShare.ProcessMessage")
		PT.DebugEntry("message: "..message)
		PT.DebugEntry("from: "..fromName)
		PT.DebugEntry("IsMe: ".. PT.ConvertBool(PT.IsMe(fromName)))
	end

	if PT.IsGrouped() and PT.IsPVPZone() then
		message = string.lower(message)

		
		-- TODO Remove before official release
		if string.sub(message, 1, 4) == "cms " then message = string.gsub(message, "cms ", "qs ", 1) end -- TODO Remove this before release.  This is just to help transition from cms to pvptools
		
		local offset = string.len(listenString)
		local prefix = string.sub(message, 1, offset)
		local request = string.sub(message, offset + 2)

		if PT.debug then
			PT.DebugEntry(PT.Spacer().."Original message: "..message)
			PT.DebugEntry(PT.Spacer().."Prefix: "..prefix)
			PT.DebugEntry(PT.Spacer().."Request: "..request)
		end
		
		if string.lower(listenString) == prefix then
			local weMadeRequest = PT.IsMe(fromName)
			
			if weMadeRequest and msgChannel ~= CHAT_CHANNEL_PARTY then
				PT.AMS.DisplayMessage("|cff0000Quest Share Error: Requests must be made in the group channel.  Press Enter to retry.|r", "qs")
				PlaySound(PT.soundError)
				PT.PreparedMessageToChat("/g "..message)
			end

			if msgChannel == CHAT_CHANNEL_PARTY then
				
				--check for special case
				if request == "ic" then
					if weMadeRequest then
						PT.AMS.DisplayMessage("|c00ffffSearching for IC Quests|r")
					else
						QS.ShareICQuests()
					end
				elseif request == "here" then
					if weMadeRequest then
						PT.AMS.DisplayMessage("|c00ffffSearching for quest at this location|r")
					else
						if IsInImperialCity() then
							QS.ShareICQuests()
						else
							QS.ProcessZoneChange(GetPlayerActiveSubzoneName())
						end
					end
				else
					local found, quest = QS.ParseRequest(request)
					if PT.debug and found then 
						PT.DebugEntry("Original Request: "..request)
						PT.DebugEntry("Resulting Quest Search: "..quest)
					end
					if found then QS.DoWeHaveQuest(quest, weMadeRequest) end	
				end
			end
		end
		
	end
end


--------------------------------------------------
-- ParseRequest - process the string and return the quest we are looking for
--------------------------------------------------
function QS.ParseRequest(request)
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ParseRequest: "..request) end
	local found = false
	local quest = nil
	local segments = {}
	
	-- split the string
	for substring in string.gmatch(request, "%S+") do
		table.insert(segments, substring)
	end
	
	-- strip the request of unrecognized keywords
	if #segments > 1 then
		segments = QS.StripElements(segments)
	end

	-- we have a simple request
	if #segments == 1 then
		request = segments[1]
		-- check if they want a scroll quest
		for keyword, scroll in pairs(QS.ScrollQuests) do
			if request == keyword then
				found = true
				quest = "The Elder Scroll of "..scroll
				break
			end
		end

		-- check if they want a kill players quest
		if not found then
			for keyword, players in pairs(QS.KillQuests) do
				if request == keyword then
					found = true
					quest = "Kill Enemy "..players
					break
				end
			end
		end
		
		-- check if they want a location capture quest
		if not found then
			for keyword, location in pairs(QS.Locations) do
				if request == keyword then
					found = true
					quest = "Capture "..location
					break
				end
			end
		end
		
		-- check if they want a conquest quest
		if not found then
			for keyword, conquest in pairs(QS.Conquest) do
				if request == keyword then
					found = true
					quest = conquest
					break
				end
			end
		end
	elseif #segments == 2 then -- we might be looking for a resource quest
		for location, formattedlocation in pairs(QS.ResourceLocations) do
			if segments[1] == location then
				quest = "Capture "..formattedlocation.." "
				for resource, formattedresource in pairs(QS.Resources) do
					if segments[2] == resource then
						found = true
						quest = quest..formattedresource
						break
					end
				end
				
			break
			end
		end
	end

	return found, quest
end


--------------------------------------------------
-- StripElements - strip the request of unrecognized words until there are a maximum of two elements
--------------------------------------------------
function QS.StripElements(segments)
	if PT.debug then 
		PT.DebugEntry("PVPTools.QuestShare.StripElements")
	end
	
	local returnTable = {}
	
	for index, element in ipairs(segments) do
		local valid = false
		
		-- quick check if the element is a valid scroll
		for possible, scroll in pairs(QS.ScrollQuests) do
			if element == possible then
				valid = true
				table.insert(returnTable, element)
				break
			end
		end
		
		-- quick check if the element is a valid enemy player type
		if not valid then
			for possible, players in pairs(QS.KillQuests) do
				if element == possible then
					valid = true
					table.insert(returnTable, element)
					break
				end
			end
		end
		
		-- quick check if the element is a valid resource
		if not valid then
			for possible, resource in pairs(QS.Resources) do
				if element == possible then
					valid = true
					table.insert(returnTable, element)
					break
				end
			end
		end
		
		-- quick check if the element is a valid location
		if not valid then
			for possible, location in pairs(QS.Locations) do
				if element == possible then
					valid = true
					table.insert(returnTable, element)
					break
				end
			end
		end
	end
	
	return returnTable
end


--------------------------------------------------
-- ShareICQuests - try to share the ic quests
--------------------------------------------------
function QS.ShareICQuests(counter)
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ShareICQuests ") end

	if counter == nil then counter = 1 end

	if counter <= 6 then
		QS.DoWeHaveQuest(QS.ICQuests[counter])
		counter = counter + 1
		zo_callLater(function() QS.ShareICQuests(counter) end, 1000)
	end
end


--------------------------------------------------
-- DoWeHaveQuest - if we have the quest then share it
--------------------------------------------------
function QS.DoWeHaveQuest(questText, myRequest, zoneShare)
		
	if PT.debug then 
		PT.DebugEntry("PVPTools.QuestShare.DoWeHaveQuest")
		PT.DebugEntry(questText)
		PT.DebugEntry("MyRequest: "..PT.ConvertBool(MyRequest))
	end
	
	if myRequest then
		PT.AMS.DisplayMessage("|c00ffffAsking for Quest: |r"..questText, "qs")
	else
		if PT.debug then PT.DebugEntry("Checking if we can share: "..questText) end
		for questJournalIndex = 1, GetNumJournalQuests() do
			if 	(GetJournalQuestType(questJournalIndex) == QUEST_TYPE_AVA) and
				(GetJournalQuestName(questJournalIndex) == questText)
			then
				PT.AMS.DisplayMessage("|c00ffffSharing Quest: |r"..questText, "qs")
				ShareQuest(questJournalIndex)
				break
			end
		end
	end
end


--------------------------------------------------
-- ProcessScrollChange - process when the state of a scrolls changes
--------------------------------------------------
function QS.ProcessScrollChange(objectiveName, holderAlliance)
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ProcessScrollChange") end

	if holderAlliance == PT.MyAlliance() then
		local found, quest = QS.ParseRequest("qs "..objectiveName)
		if found then QS.DoWeHaveQuest(quest) end
	end
end


--------------------------------------------------
-- ProcessZoneChange - check the new zone to see if we have a quest to share
--------------------------------------------------
function QS.ProcessZoneChange(subZoneName, hotkey)
	local exclusion = false
	
	if PT.debug then 
		PT.DebugEntry("PVPTools.QuestShare.ProcessZoneChange") 
		PT.DebugEntry(PT.Spacer().."Subzone: "..subZoneName)
		PT.DebugEntry(PT.Spacer().."Hotkey: "..PT.ConvertBool(hotkey))
		PT.DebugEntry(PT.Spacer().."My Request: "..PT.ConvertBool("myRequest"))
	end
	
	if IsInImperialCity() and hotkey then
		QS.ShareICQuests()
		return
	end

	subZoneName = string.lower(subZoneName)
	
	for key, exclusionString in pairs(QS.Exclusions) do
		if string.find(subZoneName, exclusionString) then exclusion = true end
	end
	
	if hotkey and exclusion then PT.AMS.DisplayMessage("|cff0000No quest exists for this location|r", "qs") PlaySound(PT.soundError) end
	
	if not exclusion
	then
		local keepId = PT.GetKeepId(subZoneName)
		if (keepId > 0) and (GetKeepAlliance(keepId, BGQUERY_LOCAL) ~= GetUnitAlliance("player")) then
			local found, quest = QS.ParseRequest("qs "..subZoneName)
			
			if hotkey and found then PT.AMS.DisplayMessage("|c00ffffChecking if we can share: |r"..quest, "qs") end
			if hotkey and not found then PT.AMS.DisplayMessage("|cff0000No quest exists for this location|r", "qs") PlaySound(PT.soundError) end
			if found then 
				QS.DoWeHaveQuest(quest, myRequest, true) 
			end
		end
	end
end


--------------------------------------------------
-- ProcessQuestComplete - check if the completed quest is one we track
--------------------------------------------------
function QS.ProcessQuestComplete(questName)
	if PT.debug then 
		PT.DebugEntry("PVPTools.QuestShare.ProcessQuestComplete")
		PT.DebugEntry(PT.Spacer()..questName)
	end
	
	if PT.ASV.settingsQSTrackDaily and PT.QuestShare.DailyResetHappened() then PT.QuestShare.ResetDailyTimers() end

	PT.AMS.DisplayMessage("Completed Quest: "..questName, "qs")
	
	questName = string.lower(questName)
	
	for name, keyword in pairs(QS.ICKeywords) do
		if string.find(questName, keyword) then
			PT.CSV.completedImperialCityQuests[name] = true
			return
		end
	end
	
	for name, complete in pairs(PT.CSV.completedConquestQuests) do
		if string.find(questName, name) then
			PT.CSV.completedConquestQuests[name] = true
			return
		end
	end
	
	for name, complete in pairs(PT.CSV.completedBountyQuests) do
		if string.find(questName, name) then
			PT.CSV.completedBountyQuests[name] = true
			return
		end
	end
	
end
--------------------------------------------------
-- DAILY QUEST TIMER FUNCTIONS
--------------------------------------------------


--------------------------------------------------
-- CheckForReset - check if the current time is past the saved server reset time
--------------------------------------------------
function QS.DailyResetHappened()
	if GetTimeStamp() > PT.CSV.savedResetTime then
		return true
	else
		return false
	end
end


--------------------------------------------------
-- CalculateDailyReset - determine the time of the next daily reset
--------------------------------------------------
function QS.ResetDailyTimers()
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.ResetDailyTimers") end
	
	local currentTime = GetTimeStamp()  
	local timeUntilNextReset = GetTimeUntilNextDailyLoginRewardClaimS()
	
	PT.CSV.savedResetTime = currentTime + timeUntilNextReset
	PT.CSV.completedConquestQuests = PT.characterDefaults.completedConquestQuests
	PT.CSV.completedBountyQuests = PT.characterDefaults.completedBountyQuests
	PT.CSV.completedImperialCityQuests = PT.characterDefaults.completedImperialCityQuests
end


--------------------------------------------------
-- DisplayQuestTimers - display the remaining time until quest reset and the status of IC and Cyro daily quests
--------------------------------------------------
function QS.DisplayQuestTimers()
	if PT.debug then PT.DebugEntry("PVPTools.QuestShare.DisplayQuestTimers") end
	
	if PT.ASV.settingsQSTrackDaily and PT.QuestShare.DailyResetHappened() then QS.ResetDailyTimers() end
		
	local outputTable = {}
	
	PT.AMS.DisplayMessage("|c00ffffDaily Quests Reset In: "..QS.TimeUntilReset(), "qs")
	
	if not PT.ASV.settingsQSTrackDaily then
		-- Display reset timer with tracking turned off warning
		PT.AMS.DisplayMessage("|cff0000Daily Quest Tracking is Turned Off|r", "qs")
	else
		-- Display Imperial City Quests
		table.insert(outputTable, "|ca9a9a9IC Quests: |r")
		local totalelements = 0
		local elementcount = 0
		totalelements = PT.CountPairs(PT.CSV.completedImperialCityQuests)
		
		for name, complete in pairs(PT.CSV.completedImperialCityQuests) do
			if not complete then
				table.insert(outputTable, "|c00FF00" .. PT.Capitalize(name) .. "|r")
			else
				table.insert(outputTable, "|cff0000" .. PT.Capitalize(name) .. "|r ")
			end
			elementcount = elementcount + 1
			if elementcount ~= totalelements then
				table.insert(outputTable, "|ca9a9a9 - |r")
			end
		end
		
		table.insert(outputTable, "\n")
		
		-- Display Conquest Mission Quests
		table.insert(outputTable, "|ca9a9a9Cyrodiil Conquest Mission Quests:|r ")
		elementcount = 0
		totalelements = PT.CountPairs(PT.CSV.completedConquestQuests)
		
		for name, complete in pairs(PT.CSV.completedConquestQuests) do
			if not complete then
				table.insert(outputTable, "|c00FF00")
				table.insert(outputTable, QS.ConquestQuestsNames[name])
				table.insert(outputTable, "|r")
			else
				table.insert(outputTable, "|cff0000")
				table.insert(outputTable, QS.ConquestQuestsNames[name])
				table.insert(outputTable, "|r ")
			end
			elementcount = elementcount + 1
			if elementcount ~= totalelements then
				table.insert(outputTable, "|ca9a9a9 - |r")
			end
		end
		
		table.insert(outputTable, "\n")
		
		-- Display Bounty Quests
		table.insert(outputTable, "|ca9a9a9Cyrodiil Bounty Quests:|r ")
		elementcount = 0
		totalelements = PT.CountPairs(PT.CSV.completedBountyQuests)
		
		for name, complete in pairs(PT.CSV.completedBountyQuests) do
			if not complete then
				table.insert(outputTable, "|c00FF00")
				table.insert(outputTable, PT.Capitalize(name))
				table.insert(outputTable, "|r")
			else
				table.insert(outputTable, "|cff0000")
				table.insert(outputTable, PT.Capitalize(name))
				table.insert(outputTable, "|r")
			end
			elementcount = elementcount + 1
			if elementcount ~= totalelements then
				table.insert(outputTable, "|ca9a9a9 - |r")
			end
		end

		PT.AMS.DisplayMessage(table.concat(outputTable))
	end
end


--------------------------------------------------
-- TimeUntilReset - returns a formatted string showing how long before the next quest reset
--------------------------------------------------
function QS.TimeUntilReset()
	if PT.debug then PT.DebugEntry ("PVPTools.QuestShare.TimeUntilReset") end
	
	if QS.DailyResetHappened() then QS.ResetDailyTimers() end
	
    local numbercolor = "|cffd700"
	local spacercolor = "|cb8860b" 
	local endcolor = "|r"
	local stringTable = {}
	local secondsRemaining = PT.CSV.savedResetTime - GetTimeStamp()
	local hours = string.format("%02.f", math.floor(secondsRemaining/3600));
	local mins = string.format("%02.f", math.floor(secondsRemaining/60 - (hours*60)));
	local secs = string.format("%02.f", math.floor(secondsRemaining - hours*3600 - mins *60));
	
	table.insert(stringTable, numbercolor)
	table.insert(stringTable, hours)
	table.insert(stringTable, endcolor)
	
	table.insert(stringTable, spacercolor)
	table.insert(stringTable, ":")
	table.insert(stringTable, endcolor)
	
	table.insert(stringTable, numbercolor)
	table.insert(stringTable, mins)
	table.insert(stringTable, endcolor)
	
	table.insert(stringTable, spacercolor)
	table.insert(stringTable, ":")
	table.insert(stringTable, endcolor)
	
	table.insert(stringTable, numbercolor)
	table.insert(stringTable, secs)
	table.insert(stringTable, endcolor)
	
	return table.concat(stringTable, "")
end