LootReader = LootReader or {}

local name = "LootReader"
local author = "vexaiv"
local version = "0.3"

local readableQuestItems = {}

local function isIconReadable(icon)
	if icon == "/esoui/art/icons/icon_missing.dds" then return false end
	
	local icons = {
		"/esoui/art/icons/quest_book",
		"/esoui/art/icons/quest_letter",
		"/esoui/art/icons/quest_plans",
		"/esoui/art/icons/quest_scroll",
	}
	
	for i = 1, #icons do
		if string.find(icon, icons[i]) then
			return true
		end
	end
end

local function updateReadableItemsForQuest(questIndex)
	-- First update all the tools for the quest...
	for toolIndex = 1, GetQuestToolCount(questIndex) do
		if CanUseQuestTool(questIndex, toolIndex) then
			local icon, _, _, _, qItemId = GetQuestToolInfo(questIndex, toolIndex)
			if isIconReadable(icon) then
				readableQuestItems[qItemId] = { questIndex = questIndex, toolIndex = toolIndex }
			end
		end
	end
	-- Then update all the collectable items...
	for stepIndex = 1, GetJournalQuestNumSteps(questIndex) do
		for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
			if CanUseQuestItem(questIndex, stepIndex, conditionIndex) then
				local icon, _, _, qItemId = GetQuestItemInfo(questIndex, stepIndex, conditionIndex)
				if isIconReadable(icon) then
					readableQuestItems[qItemId] = { questIndex = questIndex, stepIndex = stepIndex, conditionIndex = conditionIndex }
				end
			end
		end
	end
end

local function onQuestItemLooted(itemId)
	local item = readableQuestItems[itemId]
	if not item then return end
	
	if CanUseQuestTool(item.questIndex, item.toolIndex) then
		UseQuestTool(item.questIndex, item.toolIndex)
	elseif CanUseQuestItem(item.questIndex, item.stepIndex, item.conditionIndex) then
		UseQuestItem(item.questIndex, item.stepIndex, item.conditionIndex)
	end
	readableQuestItems[itemId] = nil --won't pick up the same item again in the quest so the data is not needed anymore
end

local function onAddOnLoaded(event, addonName)
	if addonName ~= name then return end
	EVENT_MANAGER:UnregisterForEvent(name, EVENT_ADD_ON_LOADED)
	
	EVENT_MANAGER:RegisterForEvent(name, EVENT_QUEST_ADDED,
		function(eventCode, questIndex, questName, objectiveName)
			updateReadableItemsForQuest(questIndex)
	end)
	
	EVENT_MANAGER:RegisterForEvent(name, EVENT_LOOT_RECEIVED,
		function(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, isSelf, isPickPocket, itemIcon, itemId, isStolen)
			if isSelf and lootType == LOOT_TYPE_QUEST_ITEM then
				onQuestItemLooted(itemId)
			end
	end)
	
	--[[ Probably no need to update on QUEST_ADVANCED because the QUEST_ADDED handler already iterates
	through all the steps and conditions of the quest, but, just in case, let's do an additional update. ]]--
	EVENT_MANAGER:RegisterForEvent(name, EVENT_QUEST_ADVANCED,
		function(eventCode, questIndex, questName, isPushed, isComplete, mainStepChanged)
			updateReadableItemsForQuest(questIndex)
	end)
	
	--[[ Probably no need to update on PLAYER_ACTIVATED because the tests show that QUEST_ADVANCED
	occurs before LOOT_RECEIVED, so the usable quest items are already updated at the pickup moment.
	But, just in case, let's additionally update for all the active quests on PLAYER_ACTIVATED just
	once (after login or ReloadUI) and then unregister to not update on every zone change. ]]--
	EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function()
		local quests = QUEST_JOURNAL_MANAGER:GetQuestList()
		for _, questInfo in ipairs(quests) do
			updateReadableItemsForQuest(questInfo.questIndex)
		end
		EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)
	end)
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
