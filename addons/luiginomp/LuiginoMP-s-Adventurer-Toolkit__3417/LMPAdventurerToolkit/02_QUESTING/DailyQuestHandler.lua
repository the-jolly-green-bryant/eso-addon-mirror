DAILY_QUEST_HANDLER = {}
local systemName = "Daily Quest Tracker"

function DAILY_QUEST_HANDLER.GetName() return systemName end

function DAILY_QUEST_HANDLER.Initialize()
    if MAIN.accountVariables.dailyQuests == nil then
        MAIN.accountVariables.dailyQuests = {}
        d("No existing quest list found. New list created.")
    else
        for zoneName, questNames in pairs(MAIN.accountVariables.dailyQuests) do
            local counter = 0
            for questName, questDetails in pairs (questNames) do
                counter = counter + 1
                local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
                if MAIN.accountVariables.dailyQuests[zoneName][questName][characterName] == nil then
                    MAIN.accountVariables.dailyQuests[zoneName][questName][characterName] = {}
                    d("Added "..characterName.." for "..zoneName..", "..questName)
                end
            end
            d(zoneName..": "..counter)
        end
    end
end
MAIN.AddToInitializeSystemsList(DAILY_QUEST_HANDLER)

function CheckIfQuestKeyExists(questKey)
    if MAIN.accountVariables.dailyQuests[questKey] ~= nil then
        d(zo_strformat("Quest Key [<<1>>] exists.",questKey))
        return true
    else
        d(zo_strformat("Quest Key [<<1>>] doesn't exist.",questKey))
        return false
    end
end

function AddDailyQuest(zoneName, questName)
    if zoneName == nil or zoneName == "" then zoneName = "Any Zone" end
    if MAIN.accountVariables.dailyQuests[zoneName] == nil then
        MAIN.accountVariables.dailyQuests[zoneName] = {}
        d("Added daily quest zone ["..zoneName.."].")
    end
    if MAIN.accountVariables.dailyQuests[zoneName][questName] == nil then
        MAIN.accountVariables.dailyQuests[zoneName][questName] = {}
        d("Added daily quest ["..questName.."] for zone ["..zoneName.."].")
    end
    local curQuestId = GetNextCompletedQuestId()
    while curQuestId ~= nil do
        local curQuestName, curQuestType = GetCompletedQuestInfo(curQuestId)
        if questName == curQuestName then
            local curZoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
            if zoneName == curZoneName then
                MAIN.accountVariables.dailyQuests[zoneName][questName].questId = curQuestId
            end
            curQuestId = nil
        else curQuestId = GetNextCompletedQuestId(curQuestId)
        end
    end
end

function CompleteDailyQuest(zoneName, questName, questId)
    if MAIN.accountVariables.dailyQuests[zoneName] ~= nil then
        if MAIN.accountVariables.dailyQuests[zoneName][questName] ~= nil then
            MAIN.accountVariables.dailyQuests[zoneName][questName].questId = questId
            local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
            if MAIN.accountVariables.dailyQuests[zoneName][questName][characterName] == nil then MAIN.accountVariables.dailyQuests[zoneName][questName][characterName] = {} end
            MAIN.accountVariables.dailyQuests[zoneName][questName][characterName].isComplete = true
            MAIN.accountVariables.dailyQuests[zoneName][questName][characterName].lastCompletedOn = GetDateStringFromTimestamp(GetTimeStamp())
            d(characterName.." completed '"..questName.."' in "..zoneName.." on "..MAIN.accountVariables.dailyQuests[zoneName][questName][characterName].lastCompletedOn)
            GetAllUnfinishedDailyQuestsInZone(zoneName)
        end
    end
end

function ResetDailyQuest(zoneName, questName)
    MAIN.accountVariables.dailyQuests[zoneName][questName][zo_strformat("<<1>>",GetRawUnitName("player"))].isComplete = false
end

function ResetAllDailyQuests()
    for zoneName, questNames in pairs(MAIN.accountVariables.dailyQuests) do
        local counter = 0
        for questName, characterNames in pairs (questNames) do
            for characterName, completionStats in pairs (characterNames) do
                if characterName == zo_strformat("<<1>>",GetRawUnitName("player")) then
                    ResetDailyQuest(zoneName, questName)
                    counter = counter + 1
                end
            end
        end
        d(zoneName.." quests reset: "..counter)
    end
end

function DAILY_QUEST_HANDLER.Reset()
    ResetAllDailyQuests()
end

DAILY_RESET.AddToResetSystemsList(DAILY_QUEST_HANDLER)

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_ADDED, function(eventCode, journalIndex, questName, objectiveName)
    if GetJournalQuestRepeatType(journalIndex) == 2 then
        local zoneName, objectiveName, zoneIndex, poiIndex = GetJournalQuestLocationInfo(journalIndex)
        --local questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText, completed, tracked, questLevel, pushed, questType, instanceDisplayType = GetJournalQuestInfo(journalIndex)
        if zoneName == nil or zoneName == "" then zoneName = "Any Zone" end
        AddDailyQuest(zoneName, questName)
        if DIALOGUE.GetTargetName() ~= nil then
            local dailyQuestGiver = DIALOGUE.GetTargetName()
            local dailyQuestGiverLocation = GetMapName()
            local skipList = DIALOGUE_SKIPPER.GetNPCSkipList()
            if dailyQuestGiver ~= nil and (skipList[dailyQuestGiver] == nil or skipList[dailyQuestGiver].locations[dailyQuestGiverLocation] == nil)
            then DIALOGUE_SKIPPER.AddNPCToSkipList(dailyQuestGiver, dailyQuestGiverLocation, true) end
        end
        
        
    end
end)

function GetAllUnfinishedDailyQuestsInZone(zoneName)
    if zoneName == nil or zoneName == ""
    then d("Zone Name missing.")
    else
        d("==========================================")
        local questCounter = 0
        local unfinishedCounter = 0
        local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
        for questName, questDetails in pairs (MAIN.accountVariables.dailyQuests[zoneName]) do
            questCounter = questCounter + 1
            if MAIN.accountVariables.dailyQuests[zoneName][questName][characterName] == nil
            or MAIN.accountVariables.dailyQuests[zoneName][questName][characterName].isComplete ~= true then
                d(questName)
                unfinishedCounter = unfinishedCounter + 1
            end
        end
        d(unfinishedCounter.." out of "..questCounter.." quests left unfinished for "..characterName.." in "..zoneName..".")
    end
end

function OnQuestCompletion(questName)
    local curQuestId = GetNextCompletedQuestId()
    while curQuestId ~= nil do
        local curQuestName, curQuestType = GetCompletedQuestInfo(curQuestId)
        if questName == curQuestName then
            local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
            if zoneName == nil or zoneName == "" then zoneName = "Any Zone" end
            CompleteDailyQuest(zoneName, questName, curQuestId)
            curQuestId = nil
        else curQuestId = GetNextCompletedQuestId(curQuestId)
        end
    end
end

function ShareDailyQuest(input)
    if input == nil or input == ""
    then d("Enter an input to share daily quests.")
    else
        for journalIndex = 1, GetNumJournalQuests() do
            if GetJournalQuestRepeatType(journalIndex) == 2 then
                local searchQuestName = GetJournalQuestName(journalIndex)
                --Handle Zone Sharing
                for zoneName, questNames in pairs(MAIN.accountVariables.dailyQuests) do
                    if zoneName == input then
                        for questName, questDetails in pairs(questNames) do
                            if questName == searchQuestName then
                                ShareQuest(journalIndex)
                                d("Sharing "..searchQuestName)
                            end
                        end
                    end
                end
                --/Handle Zone Sharing
            end
        end
    end
end

function RemoveDailyQuest(searchQuestName)
    for zoneName, questNames in pairs(MAIN.accountVariables.dailyQuests) do
        for questName, questDetails in pairs(questNames) do
            if questName == searchQuestName then
                MAIN.accountVariables.dailyQuests[zoneName][questName] = nil
                d("Removed "..searchQuestName.. " in "..zoneName.." from daily quests.")
            end
        end
    end
end

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_COMPLETE, function(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
    OnQuestCompletion(questName)
end)

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_QUEST_SHARE_RESULT, function(eventCode, shareTargetCharacterName, shareTargetDisplayName, questName, result)
    local message = "<Unknown Error>"
    if result == 0 then message = "Unable to share "..questName.." with "..shareTargetCharacterName.." ("..shareTargetDisplayName..") - result: "..result
    elseif result == 1 then message = shareTargetCharacterName.." ("..shareTargetDisplayName..") accepted "..questName
    elseif result == 2 then message = shareTargetCharacterName.." ("..shareTargetDisplayName..") declined "..questName
    else message = "<Unknown result: "..result..">"
    end
    d(message)
end)

SLASH_COMMANDS["/dailyunfinishedall"] = function()
    local counter = 0
    for zoneName, questNames in pairs(MAIN.accountVariables.dailyQuests) do
        GetAllUnfinishedDailyQuestsInZone(zoneName)
        counter = counter + 1
    end
end
SLASH_COMMANDS["/dailyunfinishedinzone"] = function(zoneName) GetAllUnfinishedDailyQuestsInZone(zoneName) end
SLASH_COMMANDS["/dailycomplete"] = function(questName) OnQuestCompletion(questName) end
SLASH_COMMANDS["/dailyresetquest"] = function(questName)
    local curQuestId = GetNextCompletedQuestId()
    while curQuestId ~= nil do
        local curQuestName, curQuestType = GetCompletedQuestInfo(curQuestId)
        if questName == curQuestName then
            local zoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
            ResetDailyQuest(zoneName, questName)
            d(questName.." manually reset.")
            curQuestId = nil
        else curQuestId = GetNextCompletedQuestId(curQuestId)
        end
    end
end
SLASH_COMMANDS["/dailyresetallquests"] = ResetAllDailyQuests
SLASH_COMMANDS["/dailyshare"] = function(input) ShareDailyQuest(input) end
SLASH_COMMANDS["/dailysharezone"] = function() ShareDailyQuest(GetPlayerActiveZoneName()) end
SLASH_COMMANDS["/dailyremovequest"] = function(questName) RemoveDailyQuest(questName) end