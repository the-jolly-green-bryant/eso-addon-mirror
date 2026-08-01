local GroupLog = {}
GroupLog.Members = GroupLog.Members or {}

-- ----------------------------
-- Track message display
-- ----------------------------
local displayEnabled = true

local ROLE_ICONS = {
    [LFG_ROLE_TANK] = "|t16:16:/esoui/art/lfg/lfg_icon_tank.dds|t",
    [LFG_ROLE_HEAL] = "|t16:16:/esoui/art/lfg/lfg_icon_healer.dds|t",
    [LFG_ROLE_DPS]  = "|t16:16:/esoui/art/lfg/lfg_icon_dps.dds|t",
}

local GROUP_ICON = "|t24:24:/esoui/art/tutorial/gamepad/gp_category_u30_companions.dds|t"

local ARROW_JOIN    = "|c00FF00←|r "
local ARROW_QUIT    = "|cFF0000→|r "
local ARROW_KICKED  = "|cFF00FF→|r "
local ARROW_CHANGED = "|c3399FF→|r "

-- ----------------------------
-- Utilities
-- ----------------------------

local function CleanName(name)
    return zo_strformat("<<1>>", name):gsub("%^.*", "")
end


local function MakeAccountLink(accountName)
    return ZO_LinkHandler_CreateLink(accountName, nil, DISPLAY_NAME_LINK_TYPE, accountName)
end

-- ----------------------------
-- Rebuild memory table
-- ----------------------------
local function RebuildGroupMembers()
    GroupLog.Members = {}

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local character = CleanName(GetUnitName(unitTag))
        local account   = GetUnitDisplayName(unitTag)
        local role      = GetGroupMemberSelectedRole(unitTag)

        GroupLog.Members[character] = {
            character = character,
            account   = account,
            role      = role
        }
    end
end

-- ----------------------------
-- Event: Group Member Joined
-- ----------------------------
local function OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    local cName = CleanName(memberCharacterName)

    if isLocalPlayer then
        displayEnabled = true
    end

    if not displayEnabled then return end

    RebuildGroupMembers()

    if isLocalPlayer then
        d(ARROW_JOIN .. GROUP_ICON)
    else
        local saved = GroupLog.Members[cName]
        local role = saved and saved.role
        if IsActiveWorldBattleground() and (not role or role == 0) then
            role = LFG_ROLE_DPS
        end
        local icon = ROLE_ICONS[role]
        local accLink = "|cCCCCCC" .. MakeAccountLink(memberDisplayName or cName) .. "|r"
        d(ARROW_JOIN .. icon .. " |c00FF00" .. cName .. "|r " .. accLink)
    end
end

-- ----------------------------
-- Event: Group Member Left
-- ----------------------------
local function OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
    if not displayEnabled then return end

    local cName = CleanName(memberCharacterName)
    
    if isLocalPlayer then
        if reason == GROUP_LEAVE_REASON_KICKED then
            d(ARROW_KICKED .. GROUP_ICON)
        else
            d(ARROW_QUIT .. GROUP_ICON)
        end
        displayEnabled = false
        GroupLog.Members = {}
        return
    end
    
    local saved = GroupLog.Members[cName]
    local role = saved and saved.role
    if IsActiveWorldBattleground() and (not role or role == 0) then
        role = LFG_ROLE_DPS
    end
    local icon = ROLE_ICONS[role] or ROLE_ICONS[LFG_ROLE_DPS]
    local accLink = "|cCCCCCC" .. MakeAccountLink(memberDisplayName or cName) .. "|r"
    
    if reason == GROUP_LEAVE_REASON_KICKED then
        d(ARROW_KICKED .. icon .. " |cFF0000" .. cName .. "|r " .. accLink)
    else
        d(ARROW_QUIT .. icon .. " |cFF0000" .. cName .. "|r " .. accLink)
    end

    if GroupLog.Members[cName] then
        GroupLog.Members[cName] = nil
    end
end

-- ----------------------------
-- Event: Role Changed
-- ----------------------------
local function OnGroupMemberRoleChanged(eventCode, unitTag, newRole)
    if not displayEnabled or not DoesUnitExist(unitTag) then return end

    local character = CleanName(GetUnitName(unitTag))
    local account   = GetUnitDisplayName(unitTag)

    if not newRole or newRole == 0 then return end

    local saved = GroupLog.Members[character]
    if not saved then
        GroupLog.Members[character] = {
            character = character,
            account   = account,
            role      = newRole,  
        }
        return                 
    end

    local oldSaved = saved.role
    
    if not oldSaved or oldSaved == 0 then
        saved.role = newRole
        return
    end

    if newRole == oldSaved then
        return
    end

    local currentRole = nil
    for i = 1, GetGroupSize() do
        local uTag = GetGroupUnitTagByIndex(i)
        local char = CleanName(GetUnitName(uTag))
        if char == character then
            currentRole = GetGroupMemberSelectedRole(uTag)
            break
        end
    end
    
    if currentRole == newRole and currentRole ~= oldSaved then
        local accLink = "|cBBBBBB" .. MakeAccountLink(account) .. "|r"
        local oldIcon = ROLE_ICONS[oldSaved]
        local newIcon = ROLE_ICONS[newRole]

        d(ARROW_CHANGED .. oldIcon .. newIcon .. " |c3399FF" .. character .. "|r " .. accLink)

        saved.role = newRole
    end
end

-- ----------------------------
-- Addon Loaded
-- ----------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= "GroupLog" then return end
    EVENT_MANAGER:UnregisterForEvent("GroupLog_Load", EVENT_ADD_ON_LOADED)

    if ZO_LinkHandler then
        ZO_LinkHandler:RegisterCallback("display", function(_, rawName)
            StartChatInput("/w " .. rawName .. " ")
        end)
    end

    EVENT_MANAGER:RegisterForEvent("GroupLog_Join",  EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent("GroupLog_Leave", EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent("GroupLog_Role",  EVENT_GROUP_MEMBER_ROLE_CHANGED, OnGroupMemberRoleChanged)
    EVENT_MANAGER:RegisterForEvent("GroupLog_PlayerActivated", EVENT_PLAYER_ACTIVATED, RebuildGroupMembers)


    RebuildGroupMembers()
end

EVENT_MANAGER:RegisterForEvent("GroupLog_Load", EVENT_ADD_ON_LOADED, OnAddonLoaded)