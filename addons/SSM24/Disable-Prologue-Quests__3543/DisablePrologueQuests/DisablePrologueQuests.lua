DisablePrologueQuests = {}

DisablePrologueQuests.name = "DisablePrologueQuests"

function DisablePrologueQuests.Initialize()

end

function DisablePrologueQuests.OnAddOnLoaded(event, addonName)
    if addonName == DisablePrologueQuests.name then
        DisablePrologueQuests.Initialize()
        EVENT_MANAGER:UnregisterForEvent(DisablePrologueQuests.name, EVENT_ADD_ON_LOADED) 
    end
end

function DisablePrologueQuests.OnQuestAdded(event, journalIndex, questName, objectiveName)
    if GetJournalQuestType(journalIndex) == QUEST_TYPE_PROLOGUE then
        EndInteraction(GetInteractionType())
        AbandonQuest(journalIndex)
        DisablePrologueQuests.PrintMessage(questName)
    end
end

function DisablePrologueQuests.PrintMessage(questName)
    if LibChatMessage then
        local chat = LibChatMessage("DisablePrologueQuests", "DPQ")
        chat:SetTagColor("fabbff")
        chat:Printf("Prologue quest added, auto-abandoning (|cFFFFFF%s|r)", questName)
    else
        df("Prologue quest added, auto-abandoning (|cFFFFFF%s|r)", questName)
    end
end

EVENT_MANAGER:RegisterForEvent(DisablePrologueQuests.name, EVENT_ADD_ON_LOADED, DisablePrologueQuests.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(DisablePrologueQuests.name, EVENT_QUEST_ADDED, DisablePrologueQuests.OnQuestAdded)
