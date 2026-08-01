local GH = GroupHistory

----------------------------------------------------------------------------------------------------
-- PRINT THE LATEST MESSAGE IN THE CHAT
----------------------------------------------------------------------------------------------------
function GH.SendMessage(message)
    local prefix = ""
    if GH.SV.enablePrefix then prefix = GH.ColorString('OG', GH.CHAT .. " ") end
    local timeStamp = ""
    if GH.SV.enableTimestamp then timeStamp = GH.ColorString('WH', "[" .. os.date("%H:%M:%S", GetTimeStamp()) .. "] ") end

    d(prefix .. timeStamp .. message)
end

----------------------------------------------------------------------------------------------------
-- ENABLE AND REGISTER ALL FUNCTIONS / EVENTS
----------------------------------------------------------------------------------------------------
function GH.Enable()
    EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED, GH.OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT, GH.OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, GH.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_CONNECTED_STATUS", EVENT_GROUP_MEMBER_CONNECTED_STATUS, GH.OnGroupMemberConnectedStateChanged)

    if GH.SV.enableRoleChange == true then
        EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_ROLE_CHANGED", EVENT_GROUP_MEMBER_ROLE_CHANGED, GH.OnGroupMemberRoleChanged)
    end
    if GH.SV.enableDifficultyChange == true then
        EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_VETERAN_DIFFICULTY_CHANGED", EVENT_VETERAN_DIFFICULTY_CHANGED, GH.OnDifficultyChanged)
        EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, GH.OnGroupDifficultyChanged)
    end
    if GH.SV.enableLeaderChange == true then
        EVENT_MANAGER:RegisterForEvent(GH.NAME.."EVENT_LEADER_UPDATE", EVENT_LEADER_UPDATE, GH.OnGroupLeaderChanged)
    end

    zo_callLater(function() GH.UpdateGroupMember() end, 1000)
end

----------------------------------------------------------------------------------------------------
-- DISABLE AND UNREGISTER ALL FUNCTIONS / EVENTS
----------------------------------------------------------------------------------------------------
function GH.Disable()
    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)

    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_ROLE_CHANGED", EVENT_GROUP_MEMBER_ROLE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_VETERAN_DIFFICULTY_CHANGED", EVENT_VETERAN_DIFFICULTY_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED", EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_LEADER_UPDATE", EVENT_LEADER_UPDATE)

    EVENT_MANAGER:UnregisterForEvent(GH.NAME.."EVENT_GROUP_MEMBER_CONNECTED_STATUS", EVENT_GROUP_MEMBER_CONNECTED_STATUS)
end

----------------------------------------------------------------------------------------------------
-- ENABLE IF DISABLED AND DISABLE IF ENABLED
----------------------------------------------------------------------------------------------------
function GH.ToggleEnable()
    GH.SV.isEnabled = not GH.SV.isEnabled
    if GH.SV.isEnabled then
        GH.Enable()
    else
        GH.Disable()
    end
end

----------------------------------------------------------------------------------------------------
-- GET BACK AN COLORED STRING FOR CHAT OUTPUT
----------------------------------------------------------------------------------------------------
function GH.ColorString(color, string)
    if not GH.Col[color] then return string end
    return GH.Col[color] .. string .. GH.Col.End
end

----------------------------------------------------------------------------------------------------
-- GET THE STRING ROLE FROM THE ID MAP
----------------------------------------------------------------------------------------------------
function GH.ColorRole(roleID)
    if not GH.SV.RoleCol[roleID] then return GH.SV.RoleCol[0] .. GH.RoleMap[0] .. GH.Col.End .. " " end
    return GH.SV.RoleCol[roleID] .. GH.RoleMap[roleID] .. GH.Col.End .. " "
end

----------------------------------------------------------------------------------------------------
-- UPDATE THE CURRENT GROUP MEMBERS AFTER F.E. SOMEONE LEFT OR RELOADUI
----------------------------------------------------------------------------------------------------
function GH.UpdateGroupMember()
    if not IsUnitGrouped("player") then return end

    ZO_ClearTable(GH.GroupMember)

    local groupSize = GetGroupSize() or 1
    GH.groupSize = (groupSize == nil or groupSize == "") and 0 or groupSize

    for i = 1, GH.groupSize do
        local unitTag = "group" .. i

        local unitDisplayName = GetUnitDisplayName(unitTag)
        local unitName = GetUnitName(unitTag)

        if unitName and unitName ~= "" and unitDisplayName and unitDisplayName ~= "" then
            local groupMemberSelectedRole = GetGroupMemberSelectedRole(unitTag) or 3
            GH.GroupMember[unitName] = {
                accountName = unitDisplayName,
                characterName = unitName,
                roleID = groupMemberSelectedRole,
                sortIndex = i
            }

            if not GH.OfflineMember[unitName] then GH.OfflineMember[unitName] = { isOffline = false } end
        end
    end

    for key, value in pairs(GH.OfflineMember) do
        if not GH.GroupMember[key] then GH.OfflineMember[key] = nil end
    end
end

----------------------------------------------------------------------------------------------------
-- PRINT ALL CURRENT GROUP MEMBERS TO CHAT
----------------------------------------------------------------------------------------------------
function GH.PrintGroupMembers()
    if not IsUnitGrouped("player") then
        GH.SendMessage(GH.ColorString('OG', "You are not currently in a group."))
        return
    end

    GH.UpdateGroupMember()

    local groupSizeMax = "/4"
    if GH.groupSize > 4 then groupSizeMax = "/12" end
    local colSize = (GH.groupSize == 4 or GH.groupSize == 12) and 'GN' or 'WH'

    d(GH.ColorString('OG', "[GroupHistory] ") .. GH.ColorString('WH', "Current Group ") .. GH.ColorString(colSize, tostring(GH.groupSize) .. groupSizeMax))

    local sortedMembers = {}
    for _, memberData in pairs(GH.GroupMember) do
        table.insert(sortedMembers, memberData)
    end

    table.sort(sortedMembers, function(a, b) return a.sortIndex < b.sortIndex end)

    for _, memberData in ipairs(sortedMembers) do
        local unitName = memberData.characterName
        local accountName = GH.ColorString('OG', ZO_LinkHandler_CreatePlayerLink(memberData.accountName) .. " ")
        local characterName = memberData.characterName

        if #characterName > 8 then characterName = string.sub(characterName, 1, 8):gsub("%s+$", "") .. ".." end
        characterName = GH.ColorString('WH', "(" .. characterName .. ") ")

        if not GH.SV.enableCharacterName then characterName = "" end

        local roleName = GH.ColorRole(memberData.roleID) or "Unknown"
        if GH.OfflineMember[unitName] and GH.OfflineMember[unitName].isOffline then
            roleName = GH.ColorRole(0)
        end

        d(GH.ColorString('WH', "→ ") .. accountName .. characterName .. roleName)
    end
end

----------------------------------------------------------------------------------------------------
-- EVENT_GROUP_MEMBER_JOINED
----------------------------------------------------------------------------------------------------
function GH.OnGroupMemberJoined(eventCode, memberCharacterName, memberDisplayName, isLocalPlayer)
    if not IsUnitGrouped("player") then return end

    GH.UpdateGroupMember()
    zo_callLater(function() GH.UpdateDifficulty() end, 1000)

    local groupSizeMax = "/4"
    if GH.groupSize > 4 then groupSizeMax = "/12" end
    local player = GetUnitName("player")
    if not player or player == "" then player = "GetUnitName" end
    local unitName = memberCharacterName:gsub("%^.+", "")
    if not unitName or unitName == "" then unitName = "memberCharacterName" end

    if unitName == player and GH.groupSize <= 2 then
        for i = 1, 12 do
            local unitTag = "group" .. i
            unitName = GetUnitName(unitTag)
            if not unitName or unitName == "" then unitName = "GetUnitName" .. i end
            if unitName ~= player then break end
        end
    end

    if not GH.GroupMember[unitName] then
        GH.SendMessage(GH.ColorString('OG', "[Unknown] ") .. GH.ColorString('GN', "joined group."))
        return
    end

    local accountName = GH.ColorString('OG', ZO_LinkHandler_CreatePlayerLink(GH.GroupMember[unitName].accountName) .. " ")
    local characterName = GH.GroupMember[unitName].characterName
        if #characterName > 8 then characterName = string.sub(characterName, 1, 8):gsub("%s+$", "") .. ".." end
        characterName = GH.ColorString('WH', "(" .. characterName .. ") ")
    if not GH.SV.enableCharacterName then characterName = "" end
    local roleName = GH.ColorRole(GH.GroupMember[unitName].roleID) or "Unknown"
    local colSize = (GH.groupSize == 4 or GH.groupSize == 12) and 'GN' or 'WH'

    GH.SendMessage(accountName .. characterName .. GH.ColorString('GN', "joined group ") .. roleName .. GH.ColorString('GN', "→ ") .. GH.ColorString(colSize, tostring(GH.groupSize) .. groupSizeMax))

    if (GH.groupSize == 4 and GH.SV.enablePlaySound4) or (GH.groupSize == 12 and GH.SV.enablePlaySound12) then
        PlaySound(SOUNDS.LEVEL_UP)
    end
end

----------------------------------------------------------------------------------------------------
-- EVENT_GROUP_MEMBER_LEFT
----------------------------------------------------------------------------------------------------
function GH.OnGroupMemberLeft(eventCode, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
    if reason == GROUP_LEAVE_REASON_DESTROYED then return end
    local player = GetUnitName("player")
    if not player or player == "" then player = "GetUnitName" end
    local unitName = memberCharacterName:gsub("%^.+", "")
    if not unitName or unitName == "" then unitName = "memberCharacterName" end

    if unitName ~= player then
        local groupSize = GetGroupSize()
        GH.groupSize = (groupSize == nil or groupSize == "") and 0 or groupSize
    else GH.groupSize = GH.groupSize - 1 end

    local groupSizeMax = "/4"
    if GH.groupSize > 4 then groupSizeMax = "/12" end

    if not GH.GroupMember[unitName] then
        GH.SendMessage(GH.ColorString('OG', "[Unknown] ") .. GH.ColorString('RD', "left group."))
        return
    end

    local accountName = GH.ColorString('OG', ZO_LinkHandler_CreatePlayerLink(GH.GroupMember[unitName].accountName) .. " ")
    local characterName = GH.GroupMember[unitName].characterName
        if #characterName > 8 then characterName = string.sub(characterName, 1, 8):gsub("%s+$", "") .. ".." end
        characterName = GH.ColorString('WH', "(" .. characterName .. ") ")
    if not GH.SV.enableCharacterName then characterName = "" end
    local roleName = GH.ColorRole(GH.GroupMember[unitName].roleID) or "Unknown"

    local colSize = (GH.groupSize == 4 or GH.groupSize == 12) and 'GN' or 'WH'
    local rsnText = (reason == GROUP_LEAVE_REASON_KICKED) and "was kicked " or "left group "

    GH.SendMessage(accountName .. characterName .. GH.ColorString('RD', rsnText) .. roleName .. GH.ColorString('RD', "← ") .. GH.ColorString(colSize, tostring(GH.groupSize) .. groupSizeMax))
    GH.UpdateGroupMember()
    zo_callLater(function() GH.UpdateDifficulty() end, 1000)
end

----------------------------------------------------------------------------------------------------
-- EVENT_GROUP_MEMBER_ROLE_CHANGED
----------------------------------------------------------------------------------------------------
function GH.OnGroupMemberRoleChanged(eventCode, unitTag, assignedRole)
    if not IsUnitGrouped("player") then return end
    local unitName = GetUnitName(unitTag) or "GetUnitName"

    if not GH.GroupMember[unitName] then return end
    if not GH.GroupMember[unitName].roleID then return end

    -- ROLE CHANGED TO SAME ROLE [Tank] -> [Tank] OR [Offline] -> [Offline]
    if assignedRole == GH.GroupMember[unitName].roleID then return end

    -- IGNORE PSEUDO OFFLINE
    if assignedRole == 0 or GH.GroupMember[unitName].roleID == 0 then return end

    local accountName = GH.ColorString('OG', ZO_LinkHandler_CreatePlayerLink(GH.GroupMember[unitName].accountName) .. " ")
    local characterName = GH.GroupMember[unitName].characterName
        if #characterName > 8 then characterName = string.sub(characterName, 1, 8):gsub("%s+$", "") .. ".." end
        characterName = GH.ColorString('WH', "(" .. characterName .. ") ")
    if not GH.SV.enableCharacterName then characterName = "" end
    local roleName = GH.ColorRole(GH.GroupMember[unitName].roleID)
    local assignedRoleName = GH.ColorRole(assignedRole)

    GH.SendMessage(accountName .. characterName .. GH.ColorString('YW', "changed role ") .. roleName .. GH.ColorString('YW', "→ ") .. assignedRoleName)
    GH.UpdateGroupMember()
end

----------------------------------------------------------------------------------------------------
-- EVENT_GROUP_MEMBER_CONNECTED_STATUS
----------------------------------------------------------------------------------------------------
function GH.OnGroupMemberConnectedStateChanged(eventCode, unitTag, isOnline)
    if not IsUnitGrouped("player") then return end

    local unitDisplayName = GetUnitDisplayName(unitTag)
    if not unitDisplayName or unitDisplayName == "" then return end

    local unitName = GetUnitName(unitTag)
    if not unitName or unitName == "" then return end

    local isOffline = not IsUnitOnline(unitTag)
    if not GH.OfflineMember[unitName] then GH.OfflineMember[unitName] = { isOffline = isOffline } end

    local wasOffline = GH.OfflineMember[unitName].isOffline

    local accountName = GH.ColorString('OG', ZO_LinkHandler_CreatePlayerLink(unitDisplayName) .. " ")
    local characterName = unitName
    if #characterName > 8 then characterName = string.sub(characterName, 1, 8):gsub("%s+$", "") .. ".." end
    characterName = GH.ColorString('WH', "(" .. characterName .. ") ")

    if not GH.SV.enableCharacterName then characterName = "" end

    if isOffline and not wasOffline then
        GH.OfflineMember[unitName].isOffline = true
        if GH.SV.enableOffline then GH.SendMessage(accountName .. characterName .. GH.ColorString('YW', "changed status ") .. GH.ColorString('RD', "→ [Offline]")) end
    elseif not isOffline and wasOffline then
        GH.OfflineMember[unitName].isOffline = false
        if GH.SV.enableOffline then GH.SendMessage(accountName .. characterName .. GH.ColorString('YW', "changed status ") .. GH.ColorString('GN', "→ [Online]")) end
    end
end

----------------------------------------------------------------------------------------------------
-- UPDATE THE PLAYER / GROUP DIFFICULTY AFTER ACTIVATION OR GROUP CHANGE
----------------------------------------------------------------------------------------------------
function GH.UpdateDifficulty()
    local unitTag = "player"
    if IsUnitGrouped("player") then unitTag = GetGroupLeaderUnitTag() end

    local isVeteranDifficulty = IsUnitUsingVeteranDifficulty(unitTag)
    if isVeteranDifficulty ~= GH.SV.isVeteranDifficulty then GH.OnDifficultyChanged(nil, unitTag, isVeteranDifficulty) end
end

----------------------------------------------------------------------------------------------------
-- EVENT_VETERAN_DIFFICULTY_CHANGED
----------------------------------------------------------------------------------------------------
function GH.OnDifficultyChanged(eventCode, unitTag, isDifficult)
    local currentTime = GetGameTimeMilliseconds()
    if currentTime >= (GH.timeDiffChange + GH.TIME_DIFF_CHANGE_MIN) then GH.timeDiffChange = currentTime
    else return end

    if isDifficult == true then
        if not GH.SV.isVeteranDifficulty then
            GH.SendMessage(GH.ColorString('OG', "Difficulty ") .. GH.ColorString('WH', "was changed to: ") .. GH.ColorString('BU', "[Veteran]"))
            GH.SV.isVeteranDifficulty = true
        end
    else
        if GH.SV.isVeteranDifficulty then
            GH.SendMessage(GH.ColorString('OG', "Difficulty ") .. GH.ColorString('WH', "was changed to: ") .. GH.ColorString('GN', "[Normal]"))
            GH.SV.isVeteranDifficulty = false
        end
    end
end

----------------------------------------------------------------------------------------------------
-- EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED
----------------------------------------------------------------------------------------------------
function GH.OnGroupDifficultyChanged(eventCode, isVeteranDifficulty)
    GH.OnDifficultyChanged(eventCode, "player", isVeteranDifficulty)
end

----------------------------------------------------------------------------------------------------
-- EVENT_LEADER_UPDATE (number eventCode, string leaderTag)
----------------------------------------------------------------------------------------------------
function GH.OnGroupLeaderChanged(eventCode, leaderTag)
    if not IsUnitGrouped("player") then return end
    local unitName = GetUnitName(leaderTag) or "GetUnitName"

    if not GH.GroupMember[unitName] then return end
    if not GH.GroupMember[unitName].roleID then return end

    local accountName = GH.ColorString('OG', ZO_LinkHandler_CreatePlayerLink(GH.GroupMember[unitName].accountName) .. " ")
    local characterName = GH.GroupMember[unitName].characterName
        if #characterName > 8 then characterName = string.sub(characterName, 1, 8):gsub("%s+$", "") .. ".." end
        characterName = GH.ColorString('WH', "(" .. characterName .. ") ")
        if not GH.SV.enableCharacterName then characterName = "" end

    zo_callLater(function()
        GH.SendMessage(accountName .. characterName .. GH.ColorString('WH', "was promoted to ") .. GH.ColorString('GN', "[Group Leader]"))
        GH.UpdateGroupMember()
    end, 1000)
end

----------------------------------------------------------------------------------------------------
-- EVENT_PLAYER_ACTIVATED (integer eventCode, boolean initial)
----------------------------------------------------------------------------------------------------
function GH.OnPlayerActivated()
    -- REBUILD AFTER RELOAD / TELEPORT
    GH.UpdateGroupMember()
    GH.UpdateDifficulty()
end