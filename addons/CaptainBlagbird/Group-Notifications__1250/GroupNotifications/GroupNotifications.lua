--[[

Group Notifications
by CaptainBlagbird
Updated by Baertram
https://github.com/CaptainBlagbird

--]]
local gn = {}
GroupNotifications = gn
gn.name = "GroupNotifications"
gn.version = "2.0"
gn.clientLang = GetCVar("language.2")

-- Addon info
local AddonName = gn.name
local clientLang = gn.clientLang
-- Language
local SI_GROUP_NOTIFICATION_GROUP_JOINED = "<<1>> (<<2>>) has joined the group."
local SI_GROUP_NOTIFICATION_GROUP_JOINED_FIRST = "<<1>> has joined the group 1st."
if clientLang == "de" then
    SI_GROUP_NOTIFICATION_GROUP_JOINED = "<<1>> (<<2>>) ist der Gruppe beigetreten."
    SI_GROUP_NOTIFICATION_GROUP_JOINED_FIRST = "<<1>> ist der Gruppe als 1. beigetreten."
elseif clientLang == "fr" then
    SI_GROUP_NOTIFICATION_GROUP_JOINED = "<<1>> (<<2>>) a rejoint le groupe."
    SI_GROUP_NOTIFICATION_GROUP_JOINED_FIRST = "<<1>> a rejoint le groupe en premier."
end


--EVENT_GROUP_MEMBER_JOINED (number eventCode, string memberCharacterName, string memberDisplayName, boolean isLocalPlayer)
local function OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    --d(">EVENT_GROUP_MEMBER_JOINED: memberCharacterName: " ..tostring(memberCharacterName) .. ", memberDisplayName: " ..tostring(memberDisplayName) .. ", isLocalPlayer: " .. tostring(isLocalPlayer))
    if not IsUnitGrouped("player") then return end
    --As first event only shows the own character name (thanks ZOs...): Workaround to check if the group size is 2 and then get the other character's name and show it to the chat
    if isLocalPlayer then
        local groupSize = GetGroupSize()
        if groupSize == 2 then
            local playerName = GetUnitName("player")
            -- Cycle through group and get their unit tags. If the unitTag's name is not the player ones, show it!
            for i=1, groupSize, 1 do
                local otherGroupCharName = GetUnitName(GetGroupUnitTagByIndex(i))
                if otherGroupCharName ~= playerName then
                    local otherGroupCharDisplayName = "" --No function to get this, unfortunately
                    local msg = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_JOINED_FIRST, ZO_LinkHandler_CreateCharacterLink(otherGroupCharName))
                    d(msg)
                    return
                end
            end
        end
    end
    --Else: Groupsize is > 2: Event should show the correct "OTHER" character names
    local memberName = ZO_LinkHandler_CreateCharacterLink(memberCharacterName)
    local memberDisplay = zo_strformat(SI_UNIT_NAME, memberDisplayName)
    local msg = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_JOINED, memberName, memberDisplay)
    d(msg)
end

--EVENT_GROUP_MEMBER_LEFT (number eventCode, string memberCharacterName, GroupLeaveReason reason, boolean isLocalPlayer, boolean isLeader, string memberDisplayName, boolean actionRequiredVote)
local function OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
--d(">EVENT_GROUP_MEMBER_LEFT: reason: " .. tostring(reason) .. "- memberCharacterName: " ..tostring(memberCharacterName) .. ", memberDisplayName: " ..tostring(memberDisplayName) .. ", isLocalPlayer: " .. tostring(isLocalPlayer) .. ", isLeader: " ..tostring(isLeader))
    --[[
        --Reasons:
    GROUP_LEAVE_REASON_MIN_VALUE            0
    GROUP_LEAVE_REASON_ITERATION_BEGIN      0
    GROUP_LEAVE_REASON_VOLUNTARY            0
    GROUP_LEAVE_REASON_KICKED               1
    GROUP_LEAVE_REASON_DISBAND              2
    GROUP_LEAVE_REASON_DESTROYED            3
    GROUP_LEAVE_REASON_LEFT_BATTLEGROUND    4
    GROUP_LEAVE_REASON_ITERATION_END        4
    GROUP_LEAVE_REASON_MAX_VALUE            4
]]
    local memberName = ZO_LinkHandler_CreateCharacterLink(memberCharacterName)
    local memberDisplay = zo_strformat(SI_UNIT_NAME, memberDisplayName)
    local msg = ""
    -- Disbanded
    if reason == GROUP_LEAVE_REASON_DISBAND and isLeader then
        msg = zo_strformat(SI_GROUPLEAVEREASON2, memberName, memberDisplay)
    -- Kicked
    elseif reason == GROUP_LEAVE_REASON_KICKED then
        if isLocalPlayer then
            msg = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
        else
            msg = zo_strformat(SI_GROUPLEAVEREASON1, memberName, memberDisplay)
        end
    -- Left
    elseif reason == GROUP_LEAVE_REASON_VOLUNTARY and not isLocalPlayer then
        -- msg = zo_strformat(SI_GROUPLEAVEREASON0, memberName, memberDisplayName)
        msg = zo_strformat(SI_GROUPLEAVEREASON0, memberName, memberDisplay)
    -- Destroyed
    else -- GROUP_LEAVE_REASON_DESTROYED
        -- Reason for every other group member after leaving or being kicked from a group
        -- Don't display a message in this case
        return
    end
    d(msg)
end

-- Event handler function for EVENT_LEADER_UPDATE
-- EVENT_LEADER_UPDATE (number eventCode, string leaderTag)
local function OnLeaderUpdate(eventCode, leaderTag)
    if not IsUnitGrouped("player") then return end
    d(zo_strformat(SI_GROUP_NOTIFICATION_GROUP_LEADER_CHANGED, ZO_LinkHandler_CreateCharacterLink(GetUnitName(leaderTag))))
end

local function OnAddOnLoaded(eventName, addonName)
    if addonName ~= AddonName then return end
    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_GROUP_MEMBER_JOINED,    OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_GROUP_MEMBER_LEFT,      OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_LEADER_UPDATE,          OnLeaderUpdate)
end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
