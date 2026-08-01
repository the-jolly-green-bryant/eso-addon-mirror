local LMP_DQT = LuiginoMPsDailyQuestTool
local LMP_DS = LuiginoMPsDialogueSkipper
LMP_DailyQuestGiverManager = {}
local system = LMP_DailyQuestGiverManager
system.name = "DailyQuestGiverManager"

local currentDialogueTarget = nil

local function print(message)
    LMP_DQT.print(system,message)
end
--LMP_DQT.AddTosubSystems(system)

EVENT_MANAGER:RegisterForEvent(system.name, EVENT_QUEST_ADDED, function(eventCode, journalIndex, questName, objectiveName)
    if GetJournalQuestRepeatType(journalIndex) == 2 then
        local mapName = GetMapName()
        if currentDialogueTarget ~= nil and LMP_DS.CheckIfEntityLocationExists(currentDialogueTarget,mapName) == false then
            print(zo_strformat("Daily Quest Giver '<<1>>' discovered in '<<2>>'",currentDialogueTarget,mapName))
            LMP_DS.AddToEntityDialogueWatchList(currentDialogueTarget,mapName,true)
        end
    end
end)

-- function system.Initialize()
-- end

EVENT_MANAGER:RegisterForEvent(system.name, EVENT_CLIENT_INTERACT_RESULT, function(eventCode, result, interactTargetName)
    currentDialogueTarget = zo_strformat("<<1>>", interactTargetName)
end)

EVENT_MANAGER:RegisterForEvent(system.name, EVENT_CHATTER_END, function(eventCode)
    currentDialogueTarget = nil
end)