local Inviter = {
    started = false,
    message = "x",
    kickList = {}
}

function Inviter:Kick()
    if not Inviter.started then return end
    for name, data in pairs(Inviter.kickList) do
        if data ~= nil and (data.added == 0 or GetTimeStamp() - data.added > LeoDolmenRunner.settings.inviter.kickDelay) then
            for i = 1, GetGroupSize() do
                local tag = GetGroupUnitTagByIndex(i)
                if GetUnitName(tag) == name then
                    LeoDolmenRunner.log("Kicking " .. name)
                    GroupKick(tag)
                    break
                end
            end
            Inviter.kickList[name] = nil
        end
    end
end

function Inviter:CheckOfflines()
    if not Inviter.started then return end
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitName(unitTag)
        if not IsUnitOnline(unitTag) and Inviter.kickList[name] == nil then
            LeoDolmenRunner.debug("Adding " .. name .. " to kick list")
            Inviter.kickList[name] = {
                unitTag = unitTag,
                added  = GetTimeStamp()
            }
        elseif IsUnitOnline(unitTag) and Inviter.kickList[name] ~= nil then
            LeoDolmenRunner.debug("Removing " .. name .. " from kick list, back online")
            Inviter.kickList[name] = nil
        end
        if LeoDolmenRunner.settings.inviter.enableBlacklist and self:IsPlayerInBlacklist(name) then
            Inviter.kickList[name] = {
                unitTag = unitTag,
                added  = 0
            }
        end
    end
end

function Inviter:Update(tick)
    if not Inviter.started or not IsUnitSoloOrGroupLeader("player") or tick ~= 5 then return end

    self:CheckOfflines()
    self:Kick()
end

function Inviter:ChatMessage(type, from, message)
    if not Inviter.started or not IsUnitSoloOrGroupLeader("player") then return end

    if GetGroupSize() >= LeoDolmenRunner.settings.inviter.maxSize then return end

    if type ~= CHAT_CHANNEL_SAY and type ~= CHAT_CHANNEL_YELL and type ~= CHAT_CHANNEL_ZONE and type ~= CHAT_CHANNEL_ZONE_LANGUAGE_1 and
    type ~= CHAT_CHANNEL_ZONE_LANGUAGE_2 and type ~= CHAT_CHANNEL_ZONE_LANGUAGE_3 and type ~= CHAT_CHANNEL_ZONE_LANGUAGE_4 then return end

    message = string.lower(message)
    if message ~= Inviter.message or from == nil or from == "" then return end

    from = from:gsub("%^.+", "")
    if self:IsPlayerInBlacklist(from) then
        LeoDolmenRunner.log("Can't invite " .. from .. ": in the blacklist")
        return
    end
    LeoDolmenRunner.log(zo_strformat("Inviting <<1>>", from))
    GroupInviteByName(from)
end

function Inviter:StartStop()
    if not Inviter.started then
        Inviter:Start()
    else
        Inviter:Stop()
    end
end

function Inviter:Stop()
    LeoDolmenRunner.log("Stopping auto invite")
    Inviter.started = false
    EVENT_MANAGER:UnregisterForEvent(LeoDolmenRunner.name, EVENT_CHAT_MESSAGE_CHANNEL)
    LeoDolmenRunnerWindowInviterPanelStartStopLabel:SetText("Start")
end

local orig_GroupListRow_OnMouseUp = ZO_GroupListRow_OnMouseUp
function ZO_GroupListRow_OnMouseUp(control, button, upInside)
    orig_GroupListRow_OnMouseUp(control, button, upInside)
    if not LeoDolmenRunner.settings.inviter.enableBlacklist then return end
    local data = ZO_ScrollList_GetData(control)
    if button == MOUSE_BUTTON_INDEX_RIGHT and upInside and data.characterName ~= GetUnitName("player") then
        AddMenuItem("LDR: Add to blacklist", function()
            LeoDolmenRunner.log("Adding " .. data.characterName .. " to the blacklist")
            table.insert(LeoDolmenRunner.settings.inviter.blacklist, data.characterName)
        end)
        ShowMenu(control)
    end
end

function Inviter:DisplayBlacklist(name)
    LeoDolmenRunner.log("Blacklist:")
    for i, char in ipairs(LeoDolmenRunner.settings.inviter.blacklist) do
        d(tostring(i) .. ") " .. char)
    end
end

function Inviter:ClearBlacklist()
    LeoDolmenRunner.log("Clearing the blacklist")
    LeoDolmenRunner.settings.inviter.blacklist = {}
end

function Inviter:AddPlayerToBlacklist(name)
    if (self:IsPlayerInBlacklist(name)) then return end
    table.insert(LeoDolmenRunner.settings.inviter.blacklist, name)
end

function Inviter:RemovePlayerFromBlacklist(name)
    local pos = tonumber(name)
    if pos ~= nil and pos <= #LeoDolmenRunner.settings.inviter.blacklist then
        LeoDolmenRunner.log("Removing " .. LeoDolmenRunner.settings.inviter.blacklist[pos] .. " from the blacklist")
        table.remove(LeoDolmenRunner.settings.inviter.blacklist, pos)
        return
    end

    for i, char in pairs(LeoDolmenRunner.settings.inviter.blacklist) do
        if char == name then
            LeoDolmenRunner.log("Removing " .. char .. " from the blacklist")
            table.remove(LeoDolmenRunner.settings.inviter.blacklist, i)
            return
        end
    end
end

function Inviter:IsPlayerInBlacklist(name)
    for _, char in pairs(LeoDolmenRunner.settings.inviter.blacklist) do
        if char == name then return true end
    end
    return false
end

function Inviter:Start(message)
    if not IsUnitSoloOrGroupLeader("player") then
        LeoDolmenRunner.log("You need to be group leader to invite.")
        return
    end

    if message ~= nil then Inviter.message = message end

    Inviter.message = string.lower(Inviter.message)

    LeoDolmenRunnerWindowInviterPanelMessage:SetText(Inviter.message)

    LeoDolmenRunner.log("Starting auto invite. Listening to " .. Inviter.message)
    Inviter.started = true
    LeoDolmenRunnerWindowInviterPanelStartStopLabel:SetText("Stop")
    EVENT_MANAGER:RegisterForEvent(LeoDolmenRunner.name, EVENT_CHAT_MESSAGE_CHANNEL, function(event,...) Inviter:ChatMessage(...) end)
end

function Inviter:Initialize()
end

LeoDolmenRunner.inviter = Inviter
