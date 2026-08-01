JournalQuestLog = {}

local INDEX_TYPE = 1
local QUEST_CAT_ZONE = 1
local QUEST_CAT_OTHER = 2
local QUEST_CAT_MISC = 3

JournalQuestLog.extendedCategories = false

JournalQuestLog.name = "JournalQuestLog"
local completedQuests = {}

function JournalQuestLog.OnAddOnLoaded(event, addonName)
	if addonName ~= JournalQuestLog.name then return end
	EVENT_MANAGER:UnregisterForEvent(JournalQuestLog.name, EVENT_ADD_ON_LOADED)
	JournalQuestLog:Initialize()
end

EVENT_MANAGER:RegisterForEvent(JournalQuestLog.name, EVENT_ADD_ON_LOADED, JournalQuestLog.OnAddOnLoaded)

function JournalQuestLog:Initialize()

	local function InitializeRow(control, data)
		control:SetText(data.questName)--(zo_strformat(GetString(SI_JOURNAL_QUEST_LOG_ROW_ENTRY), data.questName))
	end

	indexContainer = GetControl("JQL_QuestIndex")
	ZO_ScrollList_AddDataType(indexContainer, INDEX_TYPE, "JQL_QuestEntryTemplate", 24, InitializeRow)

	-- Votan's stuff
	local sceneName = "QuestLog"
	JQL_FRAGMENT = ZO_HUDFadeSceneFragment:New(JQL_Window)
	JQL_SCENE = ZO_Scene:New(sceneName, SCENE_MANAGER)
	JQL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
	JQL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	JQL_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	JQL_SCENE:AddFragment(FRAME_TARGET_BLUR_STANDARD_RIGHT_PANEL_FRAGMENT)
	JQL_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
	JQL_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	JQL_SCENE:AddFragment(TITLE_FRAGMENT)
	JQL_SCENE:AddFragment(JOURNAL_TITLE_FRAGMENT)
	JQL_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	JQL_SCENE:AddFragment(CODEX_WINDOW_SOUNDS)
	JQL_SCENE:AddFragment(JQL_FRAGMENT)

	SYSTEMS:RegisterKeyboardRootScene(sceneName, JQL_SCENE)

	local sceneGroupInfo = MAIN_MENU_KEYBOARD.sceneGroupInfo["journalSceneGroup"]
	local iconData = sceneGroupInfo.menuBarIconData
	--Override Quests default
	iconData[1] = {
		categoryName = SI_JOURNAL_QUEST_LOG_MENU_QUESTS,
		descriptor = "questJournal",
		normal = "EsoUI/Art/Journal/journal_tabIcon_quest_up.dds",
		pressed = "EsoUI/Art/Journal/journal_tabIcon_quest_down.dds",
		highlight = "EsoUI/Art/Journal/journal_tabIcon_quest_over.dds",
	}
	--Add new Log window
	iconData[#iconData + 1] = {
		categoryName = SI_JOURNAL_QUEST_LOG_MENU_HEADER,
		descriptor = sceneName,
		normal = "/esoui/art/mainmenu/menubar_journal_up.dds",
		pressed = "/esoui/art/mainmenu/menubar_journal_down.dds",
		highlight = "/esoui/art/mainmenu/menubar_journal_over.dds",
	}
	local sceneGroupBarFragment = sceneGroupInfo.sceneGroupBarFragment
	JQL_SCENE:AddFragment(sceneGroupBarFragment)

	local scenegroup = SCENE_MANAGER:GetSceneGroup("journalSceneGroup")
	scenegroup:AddScene(sceneName)
	MAIN_MENU_KEYBOARD:AddRawScene(sceneName, MENU_CATEGORY_JOURNAL, MAIN_MENU_KEYBOARD.categoryInfo[MENU_CATEGORY_JOURNAL], "journalSceneGroup")
	JQL_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			JournalQuestLog:RefreshCompletedQuests()
		elseif newState == SCENE_HIDING then
			JournalQuestLog:CleanCompletedQuests()
		end
	end )

end

function JournalQuestLog:RefreshCompletedQuests()

	local scrollData = ZO_ScrollList_GetDataList(indexContainer)
	ZO_ScrollList_Clear(indexContainer)

	local questId = 0
	local i = 0
	while questId < 10000 do
		questId = GetNextCompletedQuestId(questId)
		if questId == nil then break end
		i = i + 1
		local questName, questType = GetCompletedQuestInfo(questId)
		local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(questId)
		local categoryName
		local categoryType

		if questType == QUEST_TYPE_MAIN_STORY then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_MAIN_STORY)
			categoryType = QUEST_CAT_OTHER
		elseif questType == QUEST_TYPE_GUILD then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_GUILD)
			categoryType = QUEST_CAT_OTHER
		elseif questType == QUEST_TYPE_CRAFTING then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_CRAFTING)
			categoryType = QUEST_CAT_OTHER
		elseif questType == QUEST_TYPE_HOLIDAY_EVENT then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_HOLIDAY_EVENT)
			categoryType = QUEST_CAT_OTHER
		elseif questType == QUEST_TYPE_BATTLEGROUND then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_BATTLEGROUND)
			categoryType = QUEST_CAT_OTHER
		elseif JournalQuestLog.extendedCategories and questType == QUEST_TYPE_AVA then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_AVA)
			categoryType = QUEST_CAT_OTHER
		elseif JournalQuestLog.extendedCategories and questType == QUEST_TYPE_DUNGEON then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_DUNGEON)
			categoryType = QUEST_CAT_OTHER
		elseif JournalQuestLog.extendedCategories and questType == QUEST_TYPE_RAID then
			categoryName = GetString("SI_QUESTTYPE", QUEST_TYPE_RAID)
			categoryType = QUEST_CAT_OTHER
		elseif zoneName ~= "" then
			categoryName = zo_strformat(SI_QUEST_JOURNAL_ZONE_FORMAT, zoneName)
			categoryType = QUEST_CAT_ZONE
		else
			categoryName = GetString(SI_QUEST_JOURNAL_GENERAL_CATEGORY)
			categoryType = QUEST_CAT_MISC
		end

		if questName == "" then
			questName = zo_strformat(SI_JOURNAL_QUEST_LOG_UNKNOWN_QUEST_NAME, questId)
		end


		completedQuests[i] = {questId=questId, questName=questName, questType=questType, zoneName=zoneName, objectiveName=objectiveName, zoneIndex=zoneIndex, poiIndex=poiIndex, categoryName=categoryName, categoryType=categoryType}
	end

	local function QuestEntryComparator(leftScrollData, rightScrollData)
		local leftName = leftScrollData.questName
		local rightName = rightScrollData.questName
		
		return leftName < rightName
	end

	table.sort(completedQuests,QuestEntryComparator)

	-- the strings corresponding to the keys for data held in completedQuests[i]
	local questInfoFields = { "questId", "questName", "questType", "zoneName", "objectiveName", "zoneIndex", "poiIndex", "categoryName", "categoryType", }
	local dataCatName = { }
	local data = { }

	--[[
			table structure is roughly: data = { [1] = { cat = "category1 by name", quests = { [1] = quest1, [2] = quest2, ... } }, [2] = { cat="category2 by name", quests = { [1] = quest3, [2] = quest4, ...} }, ...}
			where dataCatName = { ["category1 by name"] = data[1], ["category2 by name"] = data[2], ...}
	--]]
	for i = 1, #completedQuests do
		local questInfo = { }
		-- fill out the current quest info into our data format
		for _, field in pairs(questInfoFields) do
			questInfo[tostring(field)] = completedQuests[i][tostring(field)]
		end

		local pos = 1
		local categoryName = completedQuests[i].categoryName
		-- if the category doesn't exist yet, create it
		if not dataCatName[categoryName] then
			-- save by name as the key, because I want to be able to find this using the category name to quickly associate quests with their category table
			dataCatName[categoryName] = { cat = categoryName }
			-- but also create an iterative key version of the category names, using keys 1 to n, since it makes it easier to sort and use generically when we care less about the name
			if #data > 0 then
				for i = 1, #data do
					-- find the first spot where the new category is lower down the alphabet, and keep going until the end of the table or the first time its no longer lower
					-- more reliable in practice than table.sort, which wasn't providing the correct order
					if tostring(categoryName) > tostring(data[i].cat)then pos = i+1 end
				end
			end
			-- insert into pos 1 if the table is empty or the category precedes all the others alphabetically, else place it (after the first miss) into the spot it belongs
			table.insert(data, pos, dataCatName[categoryName])
		end

		local dcn = dataCatName[categoryName]
		-- make sure this category has room to hold quests
		if not dcn.quests then dcn.quests = { } end
		local questName = completedQuests[i].questName

		-- if this quest isn't in the category yet, add it
		--if not dcn.quests[questName] then dcn.quests[questName]  = { } end
		local k = #dcn.quests + 1
		dcn.quests[k] = { }

		-- copy the quest info to the table
		for field, value in pairs(questInfo) do
			dcn.quests[k][tostring(field)] = value
		end
	end

	-- color the zone names/categories
	local color = ZO_ColorDef:New()
	color:SetRGBA(0.5, 0.5, 0.5, 1)
	for i = 1, #data do
		local category = data[i]
		-- add the zone name/category with a blank line above it
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = ""})
		scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = color:Colorize(category.cat)})
		for _, quest in pairs(category.quests) do
			-- add the quests to each category, in alphabetical order from before
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(INDEX_TYPE, {questName = quest.questName})
		end
	end

	ZO_ScrollList_Commit(indexContainer)

	local QuestCounter = GetControl("JQL_QuestCount")
	QuestCounter:SetText(zo_strformat(GetString(SI_JOURNAL_QUEST_LOG_COMPLETED),#completedQuests))
	--d("JQL Refreshed")

end

function JournalQuestLog:CleanCompletedQuests()

	local scrollData = ZO_ScrollList_GetDataList(indexContainer)
	ZO_ScrollList_Clear(indexContainer)

	completedQuests = {}
	--d("JQL Cleaned")
end
