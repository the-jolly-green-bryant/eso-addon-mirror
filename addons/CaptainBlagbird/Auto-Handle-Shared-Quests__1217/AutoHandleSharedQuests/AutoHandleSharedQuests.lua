--[[

Auto Handle Shared Quests
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
AutoHandleSharedQuests = AutoHandleSharedQuests or {}
AutoHandleSharedQuests.name     = "Auto Handle Shared Quests"
AutoHandleSharedQuests.version  = "2.3"
AutoHandleSharedQuests.SVversion= 2.3
AutoHandleSharedQuests.author   = "|c70C0DECaptainBlagbird|r"
AutoHandleSharedQuests.website  = "https://www.esoui.com/downloads/info1217-AutoHandleSharedQuests.html#info"
--SavedVariables
AutoHandleSharedQuests.svName = "AutoHandleSharedQuests_SavedVars"
AutoHandleSharedQuests.SavedVars = {}
AutoHandleSharedQuests.SavedVarsDefault = {
    ActionAvA = 0,
    ActionPvE = 0,
}

local AddonNameAHSQ = AutoHandleSharedQuests.name

-- Local function: Quest handling
local doQuestHandling = {
    --Nothing
    [0] = function(questId)
            -- Nothing
        end,
    --Accept
    [1] = function(questId)
            AcceptSharedQuest(questId)
            d(zo_strformat(GetString(SI_AHSQ_MSG_ACCEPTED), GetOfferedQuestShareInfo(questId)))
        end,
    --Decline
    [2] = function(questId)
            DeclineSharedQuest(questId)
            d(zo_strformat(GetString(SI_AHSQ_MSG_DECLINED), GetOfferedQuestShareInfo(questId)))
        end,
}


-- Event handler function for EVENT_QUEST_SHARED
local function OnQuestShared(eventCode, questId)
    if not questId then return end
    -- GetCompletedQuestInfo(questId)
    local sv = AutoHandleSharedQuests.SavedVars
    if not sv then return end
    local whatToDo
    if IsPlayerInAvAWorld() then
        whatToDo = sv.ActionAvA
    else
        whatToDo = sv.ActionPvE
    end
    if whatToDo then
        local funcToDo = doQuestHandling[whatToDo]
        if funcToDo and type(funcToDo) == "function" then
            funcToDo(questId)
        end
    end

end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
    -- Unregister this event
    EVENT_MANAGER:UnregisterForEvent(AddonNameAHSQ, EVENT_PLAYER_ACTIVATED)

    --Check if old SV contains wrong "String" version and fix it
    --[[
    ["EU Megaserver"] =
    {
        ["@AccountName"] =
        {
            ["charId"] =
            {
                ["ActionPvE"] = 0,
                ["ActionAvA"] = 0,
                ["version"] = "2.1", --> Wrong version, needs to be number not a string!
                ["$LastCharacterName"] = "CharName",
            },
    ]]
    local doReloadUi = false
    local oldSV = _G[AutoHandleSharedQuests.svName]
    if oldSV then
        local displayName = GetDisplayName()
        local worldName = GetWorldName()
        local svServerData = oldSV[worldName]
        if svServerData then
            local svServerDisplayData = svServerData[displayName]
            if svServerDisplayData then
                --Loop over the account data and check each character SV data
                for charIdString, charSVData in pairs(svServerDisplayData) do
                    if charSVData then
                        local version = charSVData["version"]
                        if type(version) == "string" then
                            _G[AutoHandleSharedQuests.svName][worldName][displayName][charIdString]["version"] = tonumber(version)
                            doReloadUi = true
                        end
                    end
                end
            end
        end
    end
    --ReloadUI needed here to save correct SV?
    if doReloadUi == true then
        ReloadUI("ingame")
    end

    -- Set up SavedVariables table
    --ZO_SavedVars:NewCharacterIdSettings(savedVariableTable, version, namespace, defaults, profile) -> Rename safe!
    AutoHandleSharedQuests.SavedVars = ZO_SavedVars:NewCharacterIdSettings(AutoHandleSharedQuests.svName, tonumber(AutoHandleSharedQuests.SVversion), nil, AutoHandleSharedQuests.SavedVarsDefault, GetWorldName())
    --Build the settings menu
    AutoHandleSharedQuests.buildAddonMenu()
    -- Register events that use SavedVariables
    EVENT_MANAGER:RegisterForEvent(AddonNameAHSQ, EVENT_QUEST_SHARED, OnQuestShared)
end
EVENT_MANAGER:RegisterForEvent(AddonNameAHSQ, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)