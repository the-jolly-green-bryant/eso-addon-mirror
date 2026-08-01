-- defaults
local Inviter = {
    started = false,
    kickList = {}
}

local LDR = LeoDolmenRunnerRedux

-- todo: turning this off in settings makes no difference, it still runs
function Inviter:Kick()
    if not Inviter.started then
        return
    end
    for name, data in pairs(Inviter.kickList) do
        if data ~= nil and (data.added == 0 or GetTimeStamp() - data.added > LeoDolmenRunnerRedux.settings.inviter.kickDelay) then
            for i = 1, GetGroupSize() do
                local tag = GetGroupUnitTagByIndex(i)
                if GetUnitName(tag) == name then
                    LDR.utils:Log("Kicking " .. name)
                    GroupKick(tag)
                    break
                end
            end
            Inviter.kickList[name] = nil
        end
    end
end

function Inviter:CheckOfflines()
    if not Inviter.started then
        return
    end
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        if not IsUnitOnline(unitTag) and Inviter.kickList[name] == nil then
            LDR.utils:Debug("Adding " .. name .. " to kick list")
            Inviter.kickList[name] = {
                unitTag = unitTag,
                added = GetTimeStamp()
            }
        elseif IsUnitOnline(unitTag) and Inviter.kickList[name] ~= nil then
            LDR.utils:Debug("Removing " .. name .. " from kick list, back online")
            Inviter.kickList[name] = nil
        end
        if LeoDolmenRunnerRedux.settings.inviter.enableBlacklist and Inviter:IsPlayerInBlacklist(name) then
            Inviter.kickList[name] = {
                unitTag = unitTag,
                added = 0
            }
        end
    end
end

---------------------------------------------------------------
-- the update function only effects checking offlines and kicks
---------------------------------------------------------------
function Inviter:Update(tick)
    if not Inviter.started or not IsUnitSoloOrGroupLeader("player") or tick ~= 5 then
        return
    end

    self:CheckOfflines()
    self:Kick()
end

function Inviter:ChatMessage(type, from, message)
    if not Inviter.started or not IsUnitSoloOrGroupLeader("player") then
        return
    end

    if GetGroupSize() >= LeoDolmenRunnerRedux.settings.inviter.maxSize then
        return
    end

    if type ~= CHAT_CHANNEL_SAY and type ~= CHAT_CHANNEL_YELL and type ~= CHAT_CHANNEL_ZONE and type ~= CHAT_CHANNEL_ZONE_LANGUAGE_1 and
            type ~= CHAT_CHANNEL_ZONE_LANGUAGE_2 and type ~= CHAT_CHANNEL_ZONE_LANGUAGE_3 and type ~= CHAT_CHANNEL_ZONE_LANGUAGE_4 then
        return
    end

    -- iterate over the messages array
    for i, char in pairs(LeoDolmenRunnerRedux.settings.inviter.terms) do
        mess = string.lower(char)

        -- if the message matches and from isnt empty
        if string.lower(message) == mess and from ~= nil and from ~= "" then
            from = from:gsub("%^.+", "")
            -- is the player in the blacklist?
            if self:IsPlayerInBlacklist(from) then
                LDR.utils:Log("Can't invite " .. from .. ": in the blacklist")
                return
            end
            LDR.utils:Log(zo_strformat("Inviting <<1>>", from))
            TryGroupInviteByName(from, false, true)

            -- exit the loop as we found it
            return
        end
    end
end

function Inviter:StartStop()
    if not Inviter.started then
        Inviter:Start()
    else
        Inviter:Stop()
    end
end

function Inviter:Stop()
    LDR.utils:Log("Stopping auto invite")
    Inviter.started = false
    EVENT_MANAGER:UnregisterForEvent(LeoDolmenRunnerRedux.name, EVENT_CHAT_MESSAGE_CHANNEL)
    LeoDolmenRunnerReduxWindowInviterPanelStartStopLabel:SetText("Start")
end

local orig_GroupListRow_OnMouseUp = ZO_GroupListRow_OnMouseUp
function ZO_GroupListRow_OnMouseUp(control, button, upInside)
    orig_GroupListRow_OnMouseUp(control, button, upInside)
    if not LeoDolmenRunnerRedux.settings.inviter.enableBlacklist then
        return
    end
    local data = ZO_ScrollList_GetData(control)
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside and data.characterName ~= GetUnitName("player") then
        AddMenuItem("LDR: Add to blacklist", function()
            LDR.utils:Log("Adding " .. data.characterName .. " to the blacklist")
            table.insert(LeoDolmenRunnerRedux.settings.inviter.blacklist, data.characterName)
        end)
        ShowMenu(control)
    end
end

--------------------------------------
-- Blacklist functions
--------------------------------------
function Inviter:DisplayBlacklist()
    LDR.utils:Log("Blacklist:")
    LDR.utils:PrintArrayInList(LeoDolmenRunnerRedux.settings.inviter.blacklist, true)
end

function Inviter:ClearBlacklist()
    LDR.utils:Log("Clearing the blacklist")
    LeoDolmenRunnerRedux.settings.inviter.blacklist = {}
end

function Inviter:AddPlayerToBlacklist(name)
    if LDR.utils.FindValuePosInArray(LeoDolmenRunnerRedux.settings.inviter.blacklist, name) ~= false then
        LDR.utils:Log(name .. " is already in the blacklist")
        return
    end
    LDR.utils:Log("Adding " .. name .. " to the blacklist")
    table.insert(LeoDolmenRunnerRedux.settings.inviter.blacklist, name)
end

function Inviter:RemovePlayerFromBlacklist(name)
    result = LDR.utils:RemoveValueFromArrayIfNotExists(LeoDolmenRunnerRedux.settings.inviter.blacklist, name)

    if type(result) == "string" then
        LDR.utils:Log("Removed '" .. result .. "' from blacklist")
    else
        LDR.utils:Log("Name not found in blacklist.")
    end
end

function Inviter:IsPlayerInBlacklist(name)
    return LDR.utils.FindValuePosInArray(LeoDolmenRunnerRedux.settings.inviter.blacklist, name) ~= false
end

--------------------------------------
-- Match Terms functions
--------------------------------------
function Inviter:DisplayTerms()
    LDR.utils:Log("Terms:")
    LDR.utils:PrintArrayInList(LeoDolmenRunnerRedux.settings.inviter.terms, true)
end

function Inviter:AddTermToMessageList(term)
    if LDR.utils:AddValueToArrayIfNotExists(LeoDolmenRunnerRedux.settings.inviter.terms, term) then
        LDR.utils:Log("Added '" .. term .. "' to terms list")
    end
    return
end

function Inviter:RemoveTermFromMessageList(term)
    result = LDR.utils:RemoveValueFromArrayIfNotExists(LeoDolmenRunnerRedux.settings.inviter.terms, term)

    if type(result) == "string" then
        LDR.utils:Log("Removed '" .. result .. "' from terms list")
    else
        LDR.utils:Log("Term not found in list.")
    end

    return
end

--------------------------------------
-- Initialize
--------------------------------------
function Inviter:Start(message)
    -- this is not really necessary now, but its useful to not turn on the feature

    if not IsUnitSoloOrGroupLeader("player") then
        LDR.utils:Log("You need to be group leader to invite.")
        return
    end

    LDR.utils:Log("Starting auto invite.")
    Inviter.started = true
    LeoDolmenRunnerReduxWindowInviterPanelStartStopLabel:SetText("Stop")
    EVENT_MANAGER:RegisterForEvent(LeoDolmenRunnerRedux.name, EVENT_CHAT_MESSAGE_CHANNEL, function(event, ...)
        Inviter:ChatMessage(...)
    end)
end

function Inviter:Initialize()
end

LeoDolmenRunnerRedux.inviter = Inviter
