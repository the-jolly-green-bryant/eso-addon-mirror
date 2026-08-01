LuiginoMPsDailyQuestTool = {}
LuiginoMPsDailyQuestTool.name = "LuiginoMPsDailyQuestTool"
LuiginoMPsDailyQuestTool.savedVariablesName = "LMP_DQT_SavedVariables"
LuiginoMPsDailyQuestTool.subSystems = {}
local LMP_DQT = LuiginoMPsDailyQuestTool

function LuiginoMPsDailyQuestTool.PlayAddonActivated()
    PlaySound("Dialog_Accept")
end

function LuiginoMPsDailyQuestTool.PlayAddonDeactivated()
    PlaySound("Dialog_Decline")
end

function LuiginoMPsDailyQuestTool.PlayAlert()
    PlaySound("Voice_Chat_Alert_Channel_Made_Active")
end

function LuiginoMPsDailyQuestTool.PlayError()
    PlaySound("General_Alert_Error")
end

local function print(message)
    d(zo_strformat("[<<1>>]: <<2>>.",LMP_DQT.name,message))
end

function LuiginoMPsDailyQuestTool.print(system,message)
    if system.name == nil then
        print("Warning! Failed to provide valid system argument when calling LuiginoMPsDailyQuestTool.print(system,message)")
        LMP_DQT.PlayError()
    else d(zo_strformat("[<<1>>/<<2>>]: <<3>>.",LMP_DQT.name,system.name,message))
    end
end

function LuiginoMPsDailyQuestTool.AddTosubSystems(system)
    LMP_DQT.subSystems[system.name] = system
    --print("Added "..system.name.." to Initialization List")
end

local function InitializeSystems()
    d("==========================================")
    print("Initialization started")
    local counter = 0
    for systemName, system in pairs(LMP_DQT.subSystems) do
        if counter == 0 then d("------------------------------------------") end
        system.Initialize()
        d("------------------------------------------")
        counter = counter + 1
    end
    print("Initialization Complete. Total Count is "..counter)
    d("==========================================")
end

function LuiginoMPsDailyQuestTool:Initialize()
    LuiginoMPsDailyQuestTool.characterVariables = ZO_SavedVars:NewCharacterIdSettings(LMP_DQT.savedVariablesName, 1, "character", {}, nil)
    LuiginoMPsDailyQuestTool.accountVariables = ZO_SavedVars:NewAccountWide(LMP_DQT.savedVariablesName, 1, "account", {}, nil)
    InitializeSystems()
end

EVENT_MANAGER:RegisterForEvent(LMP_DQT.name, EVENT_ADD_ON_LOADED, function(eventCode, addonName)
    if addonName == LMP_DQT.name then
        LuiginoMPsDailyQuestTool:Initialize()
        EVENT_MANAGER:UnregisterForEvent(LMP_DQT.name, EVENT_ADD_ON_LOADED)
    end
end)

SLASH_COMMANDS["/lmpdailyquestsinitialize"] = InitializeSystems