local LMP_DQT = LuiginoMPsDailyQuestTool
local LMP_DQG = LMP_DailyQuestGiverManager
LMP_DailyQuestManager = {} 
local system = LMP_DailyQuestManager
system.name = "DailyQuestManager"

LMP_DQT.AddTosubSystems(system)

local function print(message)
    LMP_DQT.print(system,message)
end

local function PurgeAllDailyQuestData()
    LuiginoMPsDailyQuestTool.accountVariables.dailyQuests = {}
    LuiginoMPsDailyQuestTool.accountVariables.dailyQuests["Any Zone"] = {}
end

local function CheckZone(zoneName)
    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName] == nil
    then LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName] = {}
        --print(zo_strformat("Added <<1>> to Daily Quest Table",zoneName))
    end
end

local function CheckQuest(zoneName,questName)
    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName] == nil then
        LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName] = {}
        --print(zo_strformat("Added <<1>> (<<2>>) to Daily Quest Table",questName,zoneName))
    end
end

local function CheckCharacter(zoneName,questName,characterName)
    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters == nil then
        LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters = {}
    end
    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName] == nil then
        LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName] = {}
        print(zo_strformat("Added <<1>> (<<2>>) to Daily Quest Table for <<3>>",questName,zoneName,characterName))
    end
end

function system.Initialize()
    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests == nil then
        PurgeAllDailyQuestData()
        print("Running first-time setup")
    else
        for zoneName, questNames in pairs(LuiginoMPsDailyQuestTool.accountVariables.dailyQuests) do
            local questCounter = 0
            for questName, questDetails in pairs (questNames) do
                questCounter = questCounter + 1
                if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].questId == nil then
                    local curQuestId = GetNextCompletedQuestId()
                    while curQuestId ~= nil do
                        local curQuestName, curQuestType = GetCompletedQuestInfo(curQuestId)
                        if questName == curQuestName then
                            local curZoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
                            if zoneName == curZoneName then
                                LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].questId = curQuestId
                                print("Quest ID updated for "..questName)
                            end
                            curQuestId = nil
                        else curQuestId = GetNextCompletedQuestId(curQuestId)
                        end
                    end
                end
                local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
                CheckCharacter(zoneName,questName,characterName)
            end
            print(questCounter.." quest(s) found for "..zoneName)
        end
    end
    print("Initialized")
end

local function OnDailyQuestAdded(zoneName, questName)
    CheckZone(zoneName)
    CheckQuest(zoneName,questName)
    local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
    CheckCharacter(zoneName,questName,characterName)
    LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete = false
end

EVENT_MANAGER:RegisterForEvent(system.name, EVENT_QUEST_ADDED, function(eventCode, journalIndex, questName, objectiveName)
    if GetJournalQuestRepeatType(journalIndex) == 2 then
        local zoneName, objectiveName, zoneIndex, poiIndex = GetJournalQuestLocationInfo(journalIndex)
        if zoneName == nil or zoneName == "" then zoneName = "Any Zone"
        end
        OnDailyQuestAdded(zoneName, questName)
    end
end)

local function OnDailyQuestCompleted(questName)
    local zoneName = ""
    local questFound = false
    local curQuestId = GetNextCompletedQuestId()
    while curQuestId ~= nil do
        local curQuestName, curQuestType = GetCompletedQuestInfo(curQuestId)
        if questName == curQuestName then
            local curZoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
            if curZoneName == nil or curZoneName == ""
            then zoneName = "Any Zone"
            else zoneName = curZoneName
            end
            if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName] ~= nil then
                if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName] ~= nil then
                    local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
                    CheckCharacter(zoneName,questName,characterName)
                    LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete = true
                    questFound = true
                    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].questId == nil then
                        LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].questId = curQuestId
                        print("Quest ID updated for "..questName)
                    elseif LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].questId ~= curQuestId then
                        local existing = LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].questId
                        local found = curQuestId
                        print(zo_strformat("Warning! Found a mismatch between existing quest ID and found quest ID for [<<1>>][<<2>>]: <<3>> vs <<4>>",zoneName,questName,existing,found))
                        LMP_DQT.PlayError()
                    end
                end
            end
            curQuestId = nil
        else curQuestId = GetNextCompletedQuestId(curQuestId)
        end
    end
    if questFound == true
    then print(zo_strformat("Daily quest [<<1>>][<<2>>] completed",zoneName,questName))
    else print(zo_strformat("Warning! Could not complete quest [<<1>>][<<2>>]",zoneName,questName))
    end
end

EVENT_MANAGER:RegisterForEvent(system.name, EVENT_QUEST_COMPLETE, function(eventCode, questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
    OnDailyQuestCompleted(questName)
end)

local function ResetDailyQuest(zoneName, questName)
    local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
    CheckCharacter(zoneName,questName,characterName)
    if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete == nil
    or LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete ~= false
    then LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete = false
        print(zo_strformat("Reset daily quest [<<1>>][<<2>>]",zoneName,questName))
        return true
    else return false
    end
end

function LMP_DailyQuestManager.ResetAllDailyQuests()
    for zoneName, questNames in pairs(LuiginoMPsDailyQuestTool.accountVariables.dailyQuests) do
        local questCounter = 0
        local resetCounter = 0
        for questName, quest in pairs (questNames) do
            questCounter = questCounter + 1
            if ResetDailyQuest(zoneName,questName) == true then resetCounter = resetCounter + 1 end
        end
        print(zo_strformat("<<1>> out of <<2>> daily quests reset for <<3>>",resetCounter,questCounter,zoneName))
    end
end

SLASH_COMMANDS["/lmpdailyquestspurgealldailyquests"] = function ()
    PurgeAllDailyQuestData()
    print("All daily quest data purged")
end
SLASH_COMMANDS["/lmpdailyquestsresetallquests"] = function() LMP_DailyQuestManager.ResetAllDailyQuests() end
SLASH_COMMANDS["lmpdailyquestsresetbyname"] = function(questName)
    local curQuestId = GetNextCompletedQuestId()
    while curQuestId ~= nil do
        local curQuestName, curQuestType = GetCompletedQuestInfo(curQuestId)
        if questName == curQuestName then
            local curZoneName, objectiveName, zoneIndex, poiIndex = GetCompletedQuestLocationInfo(curQuestId)
            if zoneName == curZoneName then
                ResetDailyQuest(zoneName, questName)
            end
            curQuestId = nil
        else curQuestId = GetNextCompletedQuestId(curQuestId)
        end
    end
end
SLASH_COMMANDS["/lmpdailyquestscompletebyname"] = function(questName) OnDailyQuestCompleted(questName) end
SLASH_COMMANDS["/lmpdailyquestsabandonall"] = function()
    local counter = GetNumJournalQuests()
    for journalIndex = 1, counter do
        if GetJournalQuestRepeatType(journalIndex) == 2 then
            local questName = GetJournalQuestName(journalIndex)
            local zoneName, objectiveName, zoneIndex, poiIndex = GetJournalQuestLocationInfo(journalIndex)
            if zoneName == nil or zoneName == "" then zoneName = "Any Zone" end
            AbandonQuest(journalIndex)
            print(zo_strformat("Abandoned Daily Quest <<1>> (<<2>>)",questName,zoneName))
        end
    end
end
SLASH_COMMANDS["/lmpdailyquestsshareall"] = function()
    local counter = GetNumJournalQuests()
    for journalIndex = 1, counter do
        if GetJournalQuestRepeatType(journalIndex) == 2 then
            local questName = GetJournalQuestName(journalIndex)
            local zoneName, objectiveName, zoneIndex, poiIndex = GetJournalQuestLocationInfo(journalIndex)
            if zoneName == nil or zoneName == "" then zoneName = "Any Zone" end
            ShareQuest(journalIndex)
            print(zo_strformat("Sharing Daily Quest <<1>> (<<2>>)",questName,zoneName))
        end
    end
end
SLASH_COMMANDS["/lmpdailyquestsgetunfinished"] = function(zoneName)
    d("Listing discovered unfinished quests:")
    if zoneName == nil or zoneName == "" then
        for curZoneName, questNames in pairs(LuiginoMPsDailyQuestTool.accountVariables.dailyQuests) do
            d("-----"..curZoneName.."-----")
            local questCounter = 0
            for questName, questDetails in pairs (questNames) do
                local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
                if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[curZoneName][questName].characters[characterName].isComplete == false then
                    d(questName)
                    questCounter = questCounter + 1
                end
            end
            d(questCounter.." quest(s) found for "..curZoneName)
        end
    elseif LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName] ~= nil then
        d("-----"..zoneName.."-----")
        local questCounter = 0
        for questName, questDetails in pairs (LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName]) do
            local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
            if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete == false then
                d(questName)
                questCounter = questCounter + 1
            end
        end
        d(questCounter.." quest(s) found for "..zoneName)
    else print(zo_strformat("Couldn't find zone named '<<1>>'. It may be spelled incorrectly or no quests have been added for that zone yet.",zoneName))
    end
end
SLASH_COMMANDS["/lmpdailyquestsgetfinished"] = function(zoneName)
    d("Listing discovered finished quests:")
    if zoneName == nil or zoneName == "" then
        for curZoneName, questNames in pairs(LuiginoMPsDailyQuestTool.accountVariables.dailyQuests) do
            d("-----"..curZoneName.."-----")
            local questCounter = 0
            for questName, questDetails in pairs (questNames) do
                local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
                if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[curZoneName][questName].characters[characterName].isComplete == true then
                    d(questName)
                    questCounter = questCounter + 1
                end
            end
            d(questCounter.." quest(s) found for "..curZoneName)
        end
    elseif LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName] ~= nil then
        d("-----"..zoneName.."-----")
        local questCounter = 0
        for questName, questDetails in pairs (LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName]) do
            local characterName = zo_strformat("<<1>>",GetRawUnitName("player"))
            if LuiginoMPsDailyQuestTool.accountVariables.dailyQuests[zoneName][questName].characters[characterName].isComplete == true then
                d(questName)
                questCounter = questCounter + 1
            end
        end
        d(questCounter.." quest(s) found for "..zoneName)
    else print(zo_strformat("Couldn't find zone named '<<1>>'. It may be spelled incorrectly or no quests have been added for that zone yet.",zoneName))
    end
end