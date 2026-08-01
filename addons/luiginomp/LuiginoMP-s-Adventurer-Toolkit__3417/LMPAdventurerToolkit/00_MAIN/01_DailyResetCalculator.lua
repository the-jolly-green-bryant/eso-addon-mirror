DAILY_RESET = {}

local systemName = "Daily Reset Calculator"

function DAILY_RESET.GetName() return systemName end

local timeZone = 5
local oneDay = 86400
local oneHour = 3600
local oneMinute = 60
local initialResetTimeStamp = 1636959600 --Mon Nov 15 2021 02:00:00 GMT-0500 (Eastern Standard Time)

local resetSystemsList = {}

function DAILY_RESET.AddToResetSystemsList(newSystem)
    resetSystemsList[newSystem] = newSystem
end

function ResetSystems()
    counter = 0
    for key, system in pairs(resetSystemsList) do
        counter = counter + 1
        system.Reset()
    end
    d(counter.." system(s) reset.")
end

local function CalculateDailyReset()
    if MAIN.characterVariables.lastResetTimeStamp == nil then MAIN.characterVariables.lastResetTimeStamp = initialResetTimeStamp end
    MAIN.characterVariables.nextResetTimeStamp = MAIN.characterVariables.lastResetTimeStamp + oneDay
    local now = GetTimeStamp()
    if now >= MAIN.characterVariables.nextResetTimeStamp then
        d("Daily reset triggered.")
        ResetSystems()
        while now >= MAIN.characterVariables.nextResetTimeStamp do
            MAIN.characterVariables.nextResetTimeStamp = MAIN.characterVariables.nextResetTimeStamp + oneDay
        end
        MAIN.characterVariables.lastResetTimeStamp = MAIN.characterVariables.nextResetTimeStamp - oneDay
    end
end

function DAILY_RESET.Initialize()
    CalculateDailyReset()
    d("Last reset on "..GetDateStringFromTimestamp(MAIN.characterVariables.lastResetTimeStamp))
    d("Next reset on "..GetDateStringFromTimestamp(MAIN.characterVariables.nextResetTimeStamp))
end

MAIN.AddToInitializeSystemsList(DAILY_RESET)

SLASH_COMMANDS["/dailyresetgetlastreset"] = function() d(GetDateStringFromTimestamp(MAIN.characterVariables.lastResetTimeStamp)) end
SLASH_COMMANDS["/dailyresetgetnextreset"] = function() d(GetDateStringFromTimestamp(MAIN.characterVariables.nextResetTimeStamp)) end