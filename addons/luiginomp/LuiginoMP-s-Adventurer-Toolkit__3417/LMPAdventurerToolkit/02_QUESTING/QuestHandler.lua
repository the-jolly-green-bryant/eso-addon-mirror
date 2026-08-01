QUEST_HANDLER = {}
local systemName = "Quest Handler"
function QUEST_HANDLER.GetName() return systemName end

function QUEST_HANDLER.GetQuestFromName(inputName)
    local curQuestId = GetNextCompletedQuestId()
    local questDetails = {}
    while curQuestId ~= nil do
        local questName, questType = GetCompletedQuestInfo(curQuestId)
        if questName == inputName then
            questDetails.questId = curQuestId
            questDetails.questName = questName
            local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
            questDetails.zoneName = zoneName
            curQuestId = nil
        else curQuestId = GetNextCompletedQuestId(curQuestId)
        end
    end
    return questDetails
end

function QUEST_HANDLER.GetQuestIdFromName(searchName)
    local questId = GetNextCompletedQuestId()
    local questName, questType = GetCompletedQuestInfo(questId)
    local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(questId)
    local finalId = nil
    while questId ~= nil do
        local questName, questType = GetCompletedQuestInfo(questId)
        if questName == searchName then 
            finalID = questId
            questId = nil
        else questId = GetNextCompletedQuestId(questId)
        end
    end
    return finalId
end

function QUEST_HANDLER.GetAllCompletedQuests()
    local questId = GetNextCompletedQuestId()
    local questName, questType = GetCompletedQuestInfo(questId)

    while questId ~= nil do
        local questName, questType = GetCompletedQuestInfo(questId)
        local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(questId)
        d(questId..", "..questName..", "..questType..", "..zoneName)
        questId = GetNextCompletedQuestId(questId)
    end
end

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_COMPLETE, function(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
    d("EVENT_QUEST_COMPLETE")
    QUEST_HANDLER.GetQuestIdFromName(questName)
end)

SLASH_COMMANDS["/getallcompletedquests"] = function() QUEST_HANDLER.GetAllCompletedQuests() end
SLASH_COMMANDS["/getquestid"] = function(questName)
    if questName == nil or questName == "" then d("Enter a quest name.")
    else
        questId = QUEST_HANDLER.GetQuestIdFromName(questName)
        if questId ~= nil and questId ~= "" then d("Quest ID for "..questName..": "..questId)
        else d("No quest ID found for "..questName..".")
        end
    end
end