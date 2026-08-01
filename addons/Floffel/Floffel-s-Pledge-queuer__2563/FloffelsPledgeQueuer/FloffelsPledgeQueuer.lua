--[[ TODO: Refactor code... clean this mess! ]]--
--[[ TODO: Check if it works for non English clients ]]--
--[[ TODO: Investigate if quest "ready for turn in" status can be found some other way, and make sure the current one actually works in all cases]]--

FPQ = {}
FPQ.name = "FloffelsPledgeQueuer"
FPQ.version = "1.42"
FPQ.settingsVersion = "1.1"
FPQ.debug = false

FPQ.DIFFICULTY_VETERAN = "V"
FPQ.DIFFICULTY_NORMAL = "N"
FPQ.DIFFICULTY_BOTH = "B"
FPQ.FAIL_ACTION_SKIP = "Skip"
FPQ.FAIL_ACTION_DOWNGRADE = "Downgrade"

local saveData = {}
local defaultData = 
{
	preferredDifficuly = FPQ.DIFFICULTY_VETERAN,
	--adaptToGroup = true,
	failAction	= FPQ.FAIL_ACTION_DOWNGRADE,
	allowCancel = false,
	skip300CP = false
}
local pledgeList = {}
local MinTargetLevel = 0
local MinTargetCp = 0

local vetIcon = "|t32:32:esoui/art/lfg/lfg_veterandungeon_up.dds|t"
local normalIcon = "|t32:32:esoui/art/lfg/lfg_normaldungeon_up.dds|t"
local checkIcon = "|t32:32:esoui/art/miscellaneous/check_icon_32.dds|t"
local crossIcon = "|t32:32:esoui/art/miscellaneous/eso_icon_warning.dds|t"

local ChatMessages = {}
local waitingForResponse = false;

local function darkPink(text)
	return "|cff8ffb" .. text .. "|r"
end

local function lightPink(text)
	return "|cffe8fe" .. text .. "|r"
end

local function red(text)
	return "|cff0000" .. text .. "|r"
end

local function orange(text)
	return "|cffbb30" .. text .. "|r"
end

local displayTag = darkPink("[PledgeQueuer]")

local function addChatMessage(message, status)
	if(status == "SUCCESS") then
		ChatMessages.success[#ChatMessages.success + 1] = message
	elseif(status == "DOWNGRADE") then
		ChatMessages.downgrade[#ChatMessages.downgrade + 1] = message
	else -- "SKIP"
		ChatMessages.skip[#ChatMessages.skip + 1] = message
	end
end

local function resetChatMessages()
	ChatMessages = {success = {}, downgrade = {}, skip = {}}
end

local function printChatMessages()

	-- sort lists
	local sort_func = function( a,b ) return a < b end
	table.sort(ChatMessages.success, sort_func )
	table.sort(ChatMessages.downgrade, sort_func )
	table.sort(ChatMessages.skip, sort_func )
	
	-- print success
	local nrOfSuccess = table.getn(ChatMessages.success)
	for i = 1, nrOfSuccess do
		CHAT_SYSTEM:AddMessage(checkIcon .. ChatMessages.success[i])
	end
	
	--print downgrade
	local nrOfDowngrade = table.getn(ChatMessages.downgrade)
	for i = 1, nrOfDowngrade do
		CHAT_SYSTEM:AddMessage(checkIcon .. ChatMessages.downgrade[i])
	end
	
	--print skips
	local nrOfSkip = table.getn(ChatMessages.skip)
	for i = 1, nrOfSkip do
		CHAT_SYSTEM:AddMessage(crossIcon .. ChatMessages.skip[i])
	end
	
	resetChatMessages()
end

-- Check if the player is eligible for the activity
local function isEligible(id, unitLevel, unitCpLevel)
	local name, levelMin, _, championPointsMin, _, _, _, _, _ = GetActivityInfo(id)
	--d(name .. " " .. unitLevel .. "/" .. levelMin .. " " .. unitCpLevel .. "/" .. championPointsMin)
	return (levelMin <= unitLevel and championPointsMin <= unitCpLevel)
end


-- Return the correct ActivityId based on if we can do veteran or not.
-- Also return a message for the chat
local function getDungeonActivityId(dungeon, preferredDifficuly, previousDifficulty, ignoreDowngrade)

	if(ignoreDowngrade == nil) then
		ignoreDowngrade = false
	end

	if(preferredDifficuly == FPQ.DIFFICULTY_VETERAN and dungeon.veteran ~= nil) then
		local name = GetActivityName(dungeon.veteran)

		local playerCp = GetUnitChampionPoints("player")
		if(playerCp >= 300 and saveData.skip300CP) then
			playerCp = 299
		end	
		local isPlayerEligible = isEligible(dungeon.veteran, GetUnitLevel("player"), playerCp)
		-- we want to queue for veteran
		if (isEligible(dungeon.veteran, MinTargetLevel, MinTargetCp)) then
			-- we are allowed to queue
			addChatMessage(lightPink(name .. " ") .. vetIcon, "SUCCESS")
			return dungeon.veteran
		elseif(not ignoreDowngrade and (saveData.failAction == FPQ.FAIL_ACTION_DOWNGRADE or not isPlayerEligible)) then
			-- try to downgrade

			if(isPlayerEligible) then
				return getDungeonActivityId(dungeon, FPQ.DIFFICULTY_NORMAL, FPQ.DIFFICULTY_VETERAN)
			end
			-- else we try normal difficulty without saying it's a "downgrade"
			return getDungeonActivityId(dungeon, FPQ.DIFFICULTY_NORMAL)
		else
			-- skip
			if (isPlayerEligible) then
				addChatMessage(lightPink(name .. " ") .. vetIcon .. red(" skipped!"), "SKIP")
			end
			
			return nil
		end
	elseif (preferredDifficuly == FPQ.DIFFICULTY_NORMAL and dungeon.normal ~= nil) then
		local name = GetActivityName(dungeon.normal)
		
		local diff = " " .. normalIcon
		-- we want to queue for veteran
		if(isEligible(dungeon.normal, MinTargetLevel, MinTargetCp)) then
			-- we are allowed to queue
			local status = "SUCCESS"
			-- is this a downgrade?
			if(previousDifficulty ~= nil) then
				diff = " " .. normalIcon .. orange(" lowered difficulty.")
				status = "DOWNGRADE"
			end
			addChatMessage(lightPink(name) .. diff, status)
			return dungeon.normal
		else
			-- skip
			diff = " " .. normalIcon .. red(" skipped!")
			addChatMessage(lightPink(name) .. diff, "SKIP")
			return nil
		end
	end
	
	-- should never reach here
	return nil, nil
end

local function groupFinderSeach(eventCode, status)
	--d(status)
	if (status == ACTIVITY_FINDER_STATUS_QUEUED) then
		--we queued!
		CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" Queue status of found pledges:"))
		printChatMessages()
		
		EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ACTIVITY_QUEUE_RESULT) -- also remove fail handler
	end
	
	-- remove eventhandler
	waitingForResponse = false
	EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
end

local function showHelp()
	CHAT_SYSTEM:AddMessage("|cff4df9Floffel's |cff8ffbpledge queuer|r")
	CHAT_SYSTEM:AddMessage(lightPink("Under Controls you can set a ") .. darkPink("keybind") .. lightPink(" for starting the queue, or use the new button at the bottom of the ") .. darkPink("Group & Activity Finder") .. lightPink("."))
	CHAT_SYSTEM:AddMessage(" ")
	
	CHAT_SYSTEM:AddMessage("|cff4df9[Available slash commands]|r")
	CHAT_SYSTEM:AddMessage(lightPink("Command: ") .. darkPink("/PledgeQueuer"))
	CHAT_SYSTEM:AddMessage(lightPink("Alias: ") .. darkPink("/pq"))
	CHAT_SYSTEM:AddMessage(lightPink("Effect: Queue for pledges using default settings (change in addon settings)."))
	CHAT_SYSTEM:AddMessage(lightPink("Example: ") .. darkPink("/pq"))
	CHAT_SYSTEM:AddMessage(" ")
	
	CHAT_SYSTEM:AddMessage(lightPink("Command: ") .. darkPink("/PledgeQueuer normal"))
	CHAT_SYSTEM:AddMessage(lightPink("Alias: ") .. darkPink("/pq normal"))
	CHAT_SYSTEM:AddMessage(lightPink("Effect: Queue for pledges and prioritize Normal difficulty."))
	CHAT_SYSTEM:AddMessage(lightPink("Example: ") .. darkPink("/pq n") .. lightPink(" and ") .. darkPink("/pq norm"))
	CHAT_SYSTEM:AddMessage(" ")
	
	CHAT_SYSTEM:AddMessage(lightPink("Command: ") .. darkPink("/PledgeQueuer veteran"))
	CHAT_SYSTEM:AddMessage(lightPink("Alias: ") .. darkPink("/pq veteran"))
	CHAT_SYSTEM:AddMessage(lightPink("Effect: Queue for pledges and prioritize Veteran difficulty."))
	CHAT_SYSTEM:AddMessage(lightPink("Example: ") .. darkPink("/pq v") .. lightPink(" and ") .. darkPink("/pq vet"))
	CHAT_SYSTEM:AddMessage(" ")
	
	CHAT_SYSTEM:AddMessage(lightPink("Command: ") .. darkPink("/PledgeQueuer both"))
	CHAT_SYSTEM:AddMessage(lightPink("Alias: ") .. darkPink("/pq both"))
	CHAT_SYSTEM:AddMessage(lightPink("Effect: Queue for pledges of Normal and Veteran difficulty."))
	CHAT_SYSTEM:AddMessage(lightPink("Example: ") .. darkPink("/pq b") .. lightPink(" and ") .. darkPink("/pq both"))
	CHAT_SYSTEM:AddMessage(" ")
	
	CHAT_SYSTEM:AddMessage(lightPink("Command: ") .. darkPink("/PledgeQueuer Help"))
	CHAT_SYSTEM:AddMessage(lightPink("Alias: ") .. darkPink("/pq help"))
	CHAT_SYSTEM:AddMessage(lightPink("Effect: Show this help menu!"))
end

local function abortQueueResponse(eventCode, status)
	if (status == ACTIVITY_FINDER_STATUS_NONE) then
		CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" Cancelled the current queue."))
	end
	
	-- remove eventhandler
	waitingForResponse = false
	EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE)
end

local function getMinLevels()
	local lvl = GetUnitLevel("player")
	local cpLvl = GetUnitChampionPoints("player")
	if(cpLvl >= 300 and saveData.skip300CP) then
		cpLvl = 299
	end
	local numInGroup = GetGroupSize()
	for i = 1, numInGroup do
		local newLvl = GetUnitLevel("group" .. i)
		
		-- after a dungeon the player sometimes seem to be returned with a value of 0 / "" for all get GetUnitX("group" .. i) calls if a group member leaves.
		-- so if a level of 0 (not valid) is found i will assume it is this bug and skip it.
		if (newLvl ~= nil and newLvl > 0) then
		
			local newCpLvl = GetUnitChampionPoints("group" .. i)
			--local name = GetUnitName("group" .. i)
			--d(name .. " " .. newLvl .. " " ..newCpLvl)
			if (newLvl ~= nil and newLvl < lvl) then
				lvl = newLvl
			end
			if (newCpLvl ~= nil and newCpLvl < cpLvl) then
				cpLvl = newCpLvl
			end
		end
		
	end 
	--d("lowest: " .. lvl .. " " .. cpLvl)
	return lvl, cpLvl
end

--check if the current step is the same as the last step.
local function questReadyForTurnIn(activeStep, endStepOverrideText)
	-- should try and find another way to do this... but it seems to work
	return activeStep == endStepOverrideText and activeStep ~= ''
end

local function getDungeonfromQuestName(questName)
	
	local wordsInQuestName = {}
		
	questName = questName:gsub('%W',' ') -- replace all special characters with space. fix for names containing "-" that breaks string.match for some reason..
	questName = questName:gsub(string.char(195),'') -- replace invalid characters, fix for zos not returning correct german names.
	questName = questName:gsub(string.char(194),'') -- replace invalid characters, fix for zos not returning correct german names.
	d(questName)
	
	for word in string.gmatch(questName, "%S+") do
		wordsInQuestName[#wordsInQuestName + 1] = string.upper(word)
	end
		--d(" ")
		--d(wordsInQuestName)
		
	--loop through all available dungeons
	for i = 1, table.getn(pledgeList) do
		-- see if all parts of the name match (the name of the quest is not always the same as the dungeon)
		-- room for improvement here, but i wanted to avoid a hardcoded list

		--make sure they exist in the dungeons name
		local matchFound = false
		--d(pledgeList[i].name)
		for j = 2, table.getn(wordsInQuestName) do -- start at index 2 so we skip the "Pledge:" part of the name
			--d(wordsInQuestName[j])
			--d(string.match(pledgeList[i].name, wordsInQuestName[j]))
			--d(" ")
			if(string.match(pledgeList[i].name, wordsInQuestName[j])) then
				matchFound = true -- continue to make sure all words match
			else
				matchFound = false
				break -- no need to continue
			end
		end
		
		--did we get a match?
		if(matchFound) then
			return pledgeList[i]
		end
	end
	
	return nil -- not match, this is a error
end

--[[
local function cooldownResponse(status)
	d(status)
	
	-- remove eventhandler
	waitingForResponse = false
	EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE)
end
--]]

-- only fires on failed queue attempts
local function queueResultErrorResponse(eventCode, status)

	resetChatMessages()
	-- remove eventhandler
	waitingForResponse = false
	EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ACTIVITY_QUEUE_RESULT)
	EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE) -- also remove the success event
	
end

-- the onClick event handler
function FPQ.Start(param)

	if(waitingForResponse)then return end

	if(string.upper(param) == "HELP") then
		showHelp()
		return
	end

	--for i = 1, table.getn(pledgeList) do
	--	name = pledgeList[i].name
	--	d(name)
		--if (name:find(string.char(195)) ~= nil) then
			--d(string.byte(name, 1, 30))
		--end
		
		
		--for j = 1, string.len(name) do
		--	d(string.sub(name, j, 1))
		--	d(string.sub(name, j, 1))
		--end
	--end
	--d(pledgeList)
	
	--[[
	if (FPQ.debug and string.upper(param) == "DEBUG") then
		local numInGroup = GetGroupSize()
		d("-----")
		d("numInGroup: " .. numInGroup)
		for i = 1, numInGroup do
			local lvl = GetUnitLevel("group" .. i)
			local eLvl = GetUnitEffectiveLevel("group" .. i)
			local cp = GetUnitChampionPoints("group" .. i)
			local eCp = GetUnitEffectiveChampionPoints("group" .. i)
			local name = GetUnitName("group" .. i)
			d("group" .. i)
			d("name: " .. name .. " lvl/elvl: " .. lvl .. "/" .. eLvl .. " cp/ecp: " .. cp .. "/" .. eCp)
					
		end
		return
	end
	]]--
	
	if(IsUnitGrouped("player") and not IsUnitGroupLeader("player")) then
		CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" Only available when you are the group leader."))
		return
	end
	
	--Make sure we are ready to queue
	local status = GetActivityFinderStatus()
	if(status ~= ACTIVITY_FINDER_STATUS_NONE and status ~= ACTIVITY_FINDER_STATUS_COMPLETE) then
		if(saveData.allowCancel) then
			--if(status == ACTIVITY_FINDER_STATUS_READY_CHECK) then
			--	EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, cooldownResponse)
			--	DeclineLFGReadyCheckNotification()
			if(status == ACTIVITY_FINDER_STATUS_QUEUED) then
				waitingForResponse = true
				EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, abortQueueResponse)
				CancelGroupSearches()
			end
		else
			CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" Already queued, leave the queue and try again."))
		end
		return
	end
	
	--reset stuff
	ClearGroupFinderSearch()
	MinTargetLevel, MinTargetCp = getMinLevels()
	resetChatMessages()
	
	local dMatches = {}
	local preferredDifficuly = saveData.preferredDifficuly
	local overrideDifficuly = string.upper(string.sub(param, 1, 1))
	if (overrideDifficuly == FPQ.DIFFICULTY_VETERAN) then
		preferredDifficuly = FPQ.DIFFICULTY_VETERAN
	elseif (overrideDifficuly == FPQ.DIFFICULTY_NORMAL) then
		preferredDifficuly = FPQ.DIFFICULTY_NORMAL
	elseif (overrideDifficuly == FPQ.DIFFICULTY_BOTH) then
		preferredDifficuly = FPQ.DIFFICULTY_BOTH
	end
	
	--find dungeons matching currently active quests
	local nrOfQuests = GetNumJournalQuests()
	for i = 1, nrOfQuests do
		local questName, _, _, _, activeHudText, _, _, _, _, questType, instanceDisplayType = GetJournalQuestInfo(i)
		
		if(questType == QUEST_TYPE_UNDAUNTED_PLEDGE) then

			
			--[[
			d(questName)
			for j = 1, GetJournalQuestNumSteps(i) do
				d("step " .. j)
				for k = 1, GetJournalQuestNumConditions(i,j) do
					 local name, current, maxx, isFailCondition, isComplete, isCreditShared, isVisible, _ = GetJournalQuestConditionInfo(i, j, k)
					d("cond " .. k .. " isComplete: " .. tostring(isComplete))
				end
				
				for r = 1, GetJournalQuestNumRewards
			end
			--]]
			
			local dungeon = getDungeonfromQuestName(questName)
			if(dungeon ~= nil) then
				local _, _, _, stepHudText, _ = GetJournalQuestStepInfo(i, 1) -- get first step only, 2nd step seem to be veteran scroll quest 
				-- compare hudtext override of questInfo and the step. activeHudText seem to be nil when not completed, so rhen all conditions are met they should match..
				-- there is probably a better way of doing this...
				if(not questReadyForTurnIn(activeHudText, stepHudText)) then 
					dMatches[#dMatches + 1] = dungeon
				end			
			else
				CHAT_SYSTEM:AddMessage(displayTag .. red(" ERROR!") .. lightPink(" dungeon was not found for quest: \"" .. questName .. "\"."))
			end
		end
		--d(name .. " " .. stepType)
	end
	
	--did we get matches?
	local nrOfMatches = table.getn(dMatches)
	if (nrOfMatches > 0) then
	
		local hasSearchEntries = false
		for i = 1, nrOfMatches do
			--get the correct activityId
			if (preferredDifficuly == FPQ.DIFFICULTY_BOTH) then
				local vetActivityId = getDungeonActivityId(dMatches[i], FPQ.DIFFICULTY_VETERAN, nil, true)
				local normalActivityId = getDungeonActivityId(dMatches[i], FPQ.DIFFICULTY_NORMAL, nil, true)
				
				if (vetActivityId ~= nil) then
					hasSearchEntries = true
					AddActivityFinderSpecificSearchEntry(vetActivityId)
				end
				if (normalActivityId ~= nil) then
					hasSearchEntries = true
					AddActivityFinderSpecificSearchEntry(normalActivityId)
				end	
			else
				--just get one dungeon
				local activityId = getDungeonActivityId(dMatches[i], preferredDifficuly)
				if (activityId ~= nil) then
					hasSearchEntries = true
					AddActivityFinderSpecificSearchEntry(activityId)
				end
			end				
		end 
		
		if(hasSearchEntries) then
			local result, res = StartGroupFinderSearch()
			--d(result, res)
			if(result == ACTIVITY_QUEUE_RESULT_SUCCESS) then
				--save messages so our event can get them later
				waitingForResponse = true
				EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, groupFinderSeach)
				EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_ACTIVITY_QUEUE_RESULT, queueResultErrorResponse) -- handle errors, like queue is busy etc
				--EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, cooldownResponse)
			else
				-- we will most likely not end up here.. result always seem to be == 0 for some reason. eventhandler above should handle this.
				resetChatMessages()
				CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" Failed to enter queue."))
			end
		else
			-- no requirement is met, print messages now
			CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" Group does not meet requirements!"))
			printChatMessages()
			
			--[[
			--debug group info
			if (FPQ.debug) then
				d("preferredDifficuly: " .. preferredDifficuly)
				d("dMatches: " .. dMatches)
				d("MinTargetLevel: " .. MinTargetLevel)
				d("MinTargetCp: " .. MinTargetCp)
				local numInGroup = GetGroupSize()
				d("-----")
				d("numInGroup: " .. numInGroup)
				for i = 1, numInGroup do
					local lvl = GetUnitLevel("group" .. i)
					local eLvl = GetUnitEffectiveLevel("group" .. i)
					local cp = GetUnitChampionPoints("group" .. i)
					local eCp = GetUnitEffectiveChampionPoints("group" .. i)
					local name = GetUnitName("group" .. i)
					d("name: " .. name .. " lvl/elvl: " .. lvl .. "/" .. eLvl .. " cp/ecp: " .. cp .. "/" .. eCp)
					
				end
			end
			--}]]
		end
		
	else
		CHAT_SYSTEM:AddMessage(displayTag .. lightPink(" No pledges found!"))
	end
end

--button to add in the group menu
local queueButton = {
	name = "Queue for pledges",
	keybind = "FLOFFELS_QUEUE_FOR_PLEDGES",
	callback = function() FPQ.Start("") end,
	alignment = KEYBIND_STRIP_ALIGN_CENTER
}

--scene change event handler. adds and removes the button
local function sceneChange(oldState, newState)
    if (newState == SCENE_SHOWING) then
        KEYBIND_STRIP:AddKeybindButton(queueButton)
    elseif (newState == SCENE_HIDING) then
        KEYBIND_STRIP:RemoveKeybindButton(queueButton)
    end
    
end

-- create the dungeon list
-- this can probable be sped up, but for now i take the safe approach in case we ever have a mismatch between normal and vet dungeons
local function setupDungeons()
	
	local dungeonList = {}
	-- add normal dungeons
    for i = 1, GetNumLFGOptions(LFG_ACTIVITY_DUNGEON) do
        local id = GetActivityIdByTypeAndIndex(LFG_ACTIVITY_DUNGEON, i)
		local dName = string.upper(GetActivityName(id))

		dName = dName:gsub('%W',' ') -- replace special characters with space. fix for dungeons containing "-" that broke the matching...
		dName = dName:gsub(string.char(195),'') -- replace invalid characters, fix for zos not returning correct german names.
		dName = dName:gsub(string.char(194),'') -- replace invalid characters, fix for zos not returning correct german names.
		--add normal dungeon to list
		dungeonList[#dungeonList + 1] = {name = dName, normal = id, veteran = nil}
	end
	
	-- add veteran dungeons
	local incorrectList = {}
    for i = 1, GetNumLFGOptions(LFG_ACTIVITY_MASTER_DUNGEON) do
        local id = GetActivityIdByTypeAndIndex(LFG_ACTIVITY_MASTER_DUNGEON, i)
		local dName = string.upper(GetActivityName(id))
		dName = dName:gsub('%W',' ') -- replace special characters with space. fix for dungeons containing "-" that broke the matching...
		dName = dName:gsub(string.char(195),'') -- replace invalid characters, fix for zos not returning correct german names.
		dName = dName:gsub(string.char(194),'') -- replace invalid characters, fix for zos not returning correct german names.
		-- find the existing normal version
		local matchFound = false
		for i = 1, table.getn(dungeonList) do
			if(dungeonList[i].name == dName) then
				dungeonList[i].veteran = id
				matchFound = true
				break
			end
		end
		
		--should not happen
		if(not matchFound) then
			incorrectList[#incorrectList + 1] = {name = dName, normal = nil, veteran = id}
		end
	end
	
	--append incorrect lists, should never happen
	for i = 1, table.getn(incorrectList) do
		dungeonList[#dungeonList + 1] = incorrectList[i]
	end
	--d(dungeonList)
	pledgeList = dungeonList
end

--register addon settings menu
local function registerAddonMenu()
	local LAM = LibAddonMenu2
	local panelName = FPQ.name

	local panelData = {
		type = "panel",
		name = "Floffel's pledge queuer",
		displayName = "|cff4df9Floffel's |cff8ffbpledge queuer|r",
		author = "Floffel",
		version = FPQ.version
	}

	local panel = LAM:RegisterAddonPanel(panelName, panelData)

	local optionsTable = {
		[1] = {
			type = "header",
			name = "Description",
			width = "full",	--or "half" (optional)
		},
		[2] = {
			type = "description",
			--title = "My Title",	--(optional)
			title = nil,	--(optional)
			text = "PledgeQueuer will scan your quest journal for Undaunted pledges and automatically queue you for the correct dungeons.\n\n" .. 
					"If your preferred difficulty is set to Veteran and you don't meet the requirements for a specific dungeon, the Normal version can be selected instead.",
			width = "full",	--or "half" (optional)
		},
		[3] = {
			type = "header",
			name = "Settings",
			width = "full",	--or "half" (optional)
		},
		[4] = {
			type = "dropdown",
            name = "Preferred difficulty:",
            tooltip = "Choose the preferred difficulty of dungeons.",
			width = "full",
            choices = {"Normal", "Veteran", "Both"},
            getFunc = function() 
							if(saveData.preferredDifficuly == FPQ.DIFFICULTY_VETERAN) then 
								return "Veteran" 
							elseif(saveData.preferredDifficuly == FPQ.DIFFICULTY_NORMAL) then
								return "Normal"
							else
								return "Both"
							end
					   end,
            setFunc = function(var) 
							if(var == "Veteran") then 
								saveData.preferredDifficuly = FPQ.DIFFICULTY_VETERAN
							elseif (var == "Normal") then
								saveData.preferredDifficuly = FPQ.DIFFICULTY_NORMAL
							else
								saveData.preferredDifficuly = FPQ.DIFFICULTY_BOTH
							end 
					  end,
		},
		 [5] = {
			type = "dropdown",
            name = "If group don't meet dungeon requirements:",
            tooltip = "If a group member don't meet the requirements of a dungeon, should we lower the difficulty or skip it?",
			width = "full",
			warning = "Ignored if Preferred difficulty \"Both\" is used.",
            choices = {"Lower difficulty", "Skip"},
            getFunc = function() 
							if(saveData.failAction == FPQ.FAIL_ACTION_DOWNGRADE) then 
								return "Lower difficulty" 
							else
								return "Skip"
							end
					   end,
            setFunc = function(var) 
							if(var == "Lower difficulty") then 
								saveData.failAction = FPQ.FAIL_ACTION_DOWNGRADE
							else
								saveData.failAction = FPQ.FAIL_ACTION_SKIP
							end 
					  end,
		},
		[6] = {
              type = "checkbox",
              name = "Cancel ongoing queue?",
              tooltip = "If you are in a queue when starting PledgeQueuer, should we abort that queue?",
              getFunc = function() return saveData.allowCancel end,
              setFunc = function(value) saveData.allowCancel = value end,
			  width = "full"
         },
		[7] = {
              type = "checkbox",
              name = "Skip 300 CP dungeons",
              tooltip = "Will skip the 300 CP dungeons, and queue for normal difficulty instead.",
              getFunc = function() return saveData.skip300CP end,
              setFunc = function(value) saveData.skip300CP = value end,
			  width = "full"
         },
		[8] = {
			type = "divider",
			width = "full",	--or "half" (optional)
		},
		[9] = {
			type = "submenu",
			name = " Help",
			controls = 
			{
				{
					type = "description",
					--title = "My Title",	--(optional)
					title = nil,	--(optional)
					text = "To start the queue press the new button under Group Finder or assign a hotkey.\n" .. 
						"You can also use the following slash commands:\n" ..
						"/PledgeQueuer\n" ..
						"/pq\n\n" ..
						"Use the optional parameter \"Veteran\", \"Normal\" or \"Both\" after each command to override the default difficulty setting above.\n\n" ..
						"Example: \"/PledgeQueuer Normal\" or \"/PledgeQueuer N\" will queue you for pledges of Normal difficulty, even if your preferred difficulty is set to Veteran.\n\n" .. 
						"Example: \"/PledgeQueuer Both\" or \"/PledgeQueuer B\" will queue you for pledges of Normal and Veteran difficulty, regardless of your default preferred difficulty setting.",
					width = "full",	--or "half" (optional)
				}	
			}
		}
	}

	LAM:RegisterOptionControls(panelName, optionsTable)
end

--INIT, look for scene here when the UI is loaded
local function OnPlayerActivated(_, initial)
	local scene = SCENE_MANAGER:GetScene("groupMenuKeyboard")
	scene:RegisterCallback("StateChange", sceneChange)
	
	--reset "waitingForResponse" just to be safe
	waitingForResponse = false
end

--INIT, stuff that dont require the UI to be loaded
local function OnLoaded(eventCode, addonName)
	if addonName~=FPQ.name then return end
	EVENT_MANAGER:UnregisterForEvent(FPQ.name, EVENT_ADD_ON_LOADED)
	
	saveData = ZO_SavedVars:NewAccountWide("FloffelsPledgeQueuerVars", FPQ.settingsVersion, nil, defaultData)
	setupDungeons()
	registerAddonMenu()
	
	EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

--register load event
EVENT_MANAGER:RegisterForEvent(FPQ.name, EVENT_ADD_ON_LOADED, OnLoaded)

--register keybind
ZO_CreateStringId("SI_BINDING_NAME_FLOFFELS_QUEUE_FOR_PLEDGES", "Queue for pledges")

local LSC = LibSlashCommander
--register slash commands
if (LSC ~= nil) then
	LSC:Register({"/PledgeQueuer", "/pq"}, function(input) FPQ.Start(input) end, "Queue for pledges")
else
	SLASH_COMMANDS["/PledgeQueuer"] = FPQ.Start
	SLASH_COMMANDS["/pq"] = FPQ.Start
end

