CyroQuestManager = CyroQuestManager or {}
local CQM = CyroQuestManager

CQM.GenericQuests = {
	"Kill Enemy Players",
	"Capture Any Nine Resources",
	"Capture Any Three Keeps",
}

function CQM.shareQuest(questIndex)
	ShareQuest(questIndex)
	CHAT_SYSTEM:AddMessage(string.format("Sharing: |c0af50a [%s]|r", GetJournalQuestName(questIndex)))
end

function CQM.shareKeepRelatedQuests(keepName)
	for questIndex = 1, MAX_JOURNAL_QUESTS do
		if string.find(string.lower(GetJournalQuestName(questIndex)), string.lower(keepName)) then
			CQM.shareQuest(questIndex)
		end
	end
end

function CQM.shareScrollQuests()
	for questIndex = 1, MAX_JOURNAL_QUESTS do
		if string.find(string.lower(GetJournalQuestName(questIndex)), "elder scroll") then
			CQM.shareQuest(questIndex)
		end
	end
end

function CQM.isQuestGeneric(questName)
	for i=1, 3 do
		if questName == CQM.GenericQuests[i] then
			return true 
		end
	end
	return false
end