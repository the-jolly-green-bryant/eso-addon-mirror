MAIN = {}

local systemName = "LMPAdventurerToolkit"

local savedVariablesName = "SavedVariables"

function MAIN.GetName() return systemName end

local initializeSystemsList = {}

function MAIN.AddToInitializeSystemsList(newSystem)
    initializeSystemsList[newSystem] = newSystem
end

local function InitializeSystems()
    counter = 0
    for key, system in pairs(initializeSystemsList) do
        d(system.GetName().." initialized.")
        system.Initialize()
        d("==========================================")
        counter = counter + 1
    end
    d(counter.." system(s) initialized.")
end

function MAIN:Initialize()
    MAIN.characterVariables = ZO_SavedVars:NewCharacterIdSettings(savedVariablesName, 1, "character", {}, nil)
    MAIN.accountVariables = ZO_SavedVars:NewAccountWide(savedVariablesName, 1, "account", {}, nil)
    InitializeSystems()
end

EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == systemName then
        MAIN:Initialize()
        EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_ADD_ON_LOADED)
    end
end)