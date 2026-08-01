local LMP_DQT = LuiginoMPsDailyQuestTool
local LMP_DQM = LMP_DailyQuestManager
LMP_DailyResetCalculator = {} 
local system = LMP_DailyResetCalculator
system.name = "DailyResetCalculator"

LMP_DQT.AddTosubSystems(system)

local timeZone = 5
local oneDay = 86400
local oneHour = 3600
local oneMinute = 60
local initialResetTimeStamp = 1636959600 --Mon Nov 15 2021 02:00:00 GMT-0500 (Eastern Standard Time)

local function print(message)
    LMP_DQT.print(system,message)
end

function system.Initialize()
    if LuiginoMPsDailyQuestTool.characterVariables.lastResetTimeStamp == nil then
        LuiginoMPsDailyQuestTool.characterVariables.lastResetTimeStamp = initialResetTimeStamp
        print("Running first-time setup")
    else print("Last reset on "..GetDateStringFromTimestamp(LuiginoMPsDailyQuestTool.characterVariables.lastResetTimeStamp))
    end
    LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp = LuiginoMPsDailyQuestTool.characterVariables.lastResetTimeStamp + oneDay
    print("Next reset on "..GetDateStringFromTimestamp(LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp))
    local now = GetTimeStamp()
    if now >= LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp then
        print("Daily reset triggered")
        LMP_DQM.ResetAllDailyQuests()
        while now >= LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp do
            LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp = LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp + oneDay
        end
        LuiginoMPsDailyQuestTool.characterVariables.lastResetTimeStamp = LuiginoMPsDailyQuestTool.characterVariables.nextResetTimeStamp - oneDay
    end
    print("Initialized")
end