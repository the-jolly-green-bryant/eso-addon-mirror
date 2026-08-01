AllCraft_DailyWrits = {}
AllCraft_DailyWrits.name = "AllCraft_DailyWrits"

AllCraft_DailyWrits.dailyWritSettings = {}
AllCraft_DailyWrits.dailyWritDefaults ={

}

local QuestAccepted = {}
local function AcceptQuest(eventCode)
    EVENT_MANAGER:UnregisterForEvent(AllCraft_DailyWrits.name, EVENT_QUEST_OFFERED)
    QuestAccepted = true
    AcceptOfferedQuest()
end

local function QuestComplete(eventCode)
    EVENT_MANAGER:UnregisterForEvent(AllCraft_DailyWrits.name, EVENT_QUEST_COMPLETE_DIALOG)
    CompleteQuest()
end

local function CraftBoardInteract(eventCode,optionCount)
	-- No options do nothing
	if optionCount == 0 then return end
	for i = 1, optionCount do
		local chatterString, chatterType = GetChatterOption(i)
		if chatterType == CHATTER_START_NEW_QUEST_BESTOWAL
		and string.find(string.lower(chatterString), string.lower("writ")) ~= nil then
            EVENT_MANAGER:RegisterForEvent(AllCraft_DailyWrits.name, EVENT_QUEST_OFFERED, AcceptQuest)
            SelectChatterOption(i)
            return
        elseif chatterType == CHATTER_START_COMPLETE_QUEST or
        chatterType == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS then
            EVENT_MANAGER:RegisterForEvent(WritCreater.name, EVENT_QUEST_COMPLETE_DIALOG, QuestComplete)
            SelectChatterOption(1)
            return
		end
	end
end
AllCraft_DailyWrits.CraftBoardInteract = CraftBoardInteract
