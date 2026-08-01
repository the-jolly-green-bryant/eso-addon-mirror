local _addon = {
	name = "Jump Out Alert",
	author = "@czerepx",
	website = "",
	version = "0.1.0",
}

local function QJA_attemptJump()

	--d("Jump attempt detected")

	local curZoneId = GetUnitWorldPosition("player")
	local curZoneName = GetZoneNameByIndex(GetZoneIndex(curZoneId))
	local curParentZoneId = GetParentZoneId(curZoneId)

	--fix for The Reach caverns
	if curZoneId==1208 then curParentZoneId = 1207 end 

	local curParentZoneName = "";
	if curParentZoneId > 0 then
	  curParentZoneName = GetZoneNameByIndex(GetZoneIndex(curParentZoneId))
	end  
	
	local foundf = false
	local firstf = true
	for i = 1, MAX_JOURNAL_QUESTS do
		if GetJournalQuestRepeatType(i)==QUEST_REPEAT_DAILY then
			local questType = GetJournalQuestType(i)
			if questType~=QUEST_TYPE_DUNGEON and questType~=QUEST_TYPE_CRAFTING then
				local questName,_,activeStepText,_,_,isCompleted = GetJournalQuestInfo(i)
				local questZoneName = GetJournalQuestLocationInfo(i)
				if questZoneName==curZoneName or questZoneName==curParentZoneName then 
					if firstf then
						d("You are in: " .. curZoneName .. " / " .. curParentZoneName)
						firstf = false
					end	
					
					--fix for Undaunted dailies - these are marked as completed only when you approach Bolgrul
					if not isCompleted then
						local qtext = GetJournalQuestConditionInfo(i,1,1)
						if (string.find(qtext,"Bolgrul")) then isCompleted = true end
					end	

					if not isCompleted then
						--d("Unfinished daily quest in: " .. questZoneName)
						for j = 1, GetJournalQuestNumConditions(i,1) do
							local qtext, _, _, _, isComplete = GetJournalQuestConditionInfo(i,1,j)

							if not isComplete then
								d("|cFF3030" .. questName .. "|r, step: " .. qtext)
								foundf = true
								break
							end	
						end	
					else	
						d("|c70FF70" .. questName .. "|r - ready to turn in")
					end
				end	
			end	
		end
	end		
end

--ZO_PreHook("JumpToGuildMember", function() QJA_attemptJump() end)


local function QJA_loadAddon()
	ZO_PreHook("JumpToGuildMember", function() QJA_attemptJump() end)
	ZO_PreHook("JumpToGroupMember", function() QJA_attemptJump() end)
	ZO_PreHook("JumpToFriend", function() QJA_attemptJump() end)
	ZO_PreHook("JumpToHouse", function() QJA_attemptJump() end)
	ZO_PreHook("RequestJumpToHouse", function() QJA_attemptJump() end)
	ZO_PreHook("JumpToSpecificHouse", function() QJA_attemptJump() end)
	
	EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_ADD_ON_LOADED, QJA_loadAddon)

JumpOutAlert = _addon
