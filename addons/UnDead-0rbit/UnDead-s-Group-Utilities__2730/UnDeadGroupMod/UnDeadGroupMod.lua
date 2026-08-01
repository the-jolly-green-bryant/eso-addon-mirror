UnDeadGroupMod = {
    name = "UnDeadGroupMod",
    version = "2.1",
    updateTimeInSeconds = 1000,
    FriendList = {},
    FriendToJoin = "",
    MailTopic = "",
    MailBody = "",
    defaults = {
        filtered = {},
        Friends = { "", "", "" },
        FriendZones = { "", "", "" },
        willAcceptLFGCheck = false,
        willAcceptGroupInvite = false,
        willNotAcceptTravelToLeader = false,
        canLeaveLFG = false,
        ActivityIdList = {},
        ActivitySetIdNames = {},
        ActivityIdNames = {},
        ActivitySetIdList = {},
        SelectedQName = "Random Normal Dungeon",
        selectedQ = 62,
        isDifficultyVisible = true,
        isTitleVisible = true,
        isRoleVisible = true,
        isReadyCheckVisible = true,
        didVoteNewName = false,
        dungeonAchievementDump = {},
        autoDungeonActivityToAchievement = {},
        autoDungeonExtras = {},
        -- (auto dungeon flags removed)
    }
}

local groupMemberJoinedFlag = false

--Call the initialization
function UnDeadGroupMod.OnAddOnLoaded(_, addonName)
    if addonName == UnDeadGroupMod.name then UnDeadGroupMod:Initialize() end
end

function UnDeadGroupMod.OnIndicatorMoveStop()
    local sv = UnDeadGroupMod.SavedVariables
    sv.left, sv.top = UnDeadGroupModIndicator:GetLeft(), UnDeadGroupModIndicator:GetTop()
end

function UnDeadGroupMod.RestorePosition()
    local sv = UnDeadGroupMod.SavedVariables
    UnDeadGroupModIndicator:ClearAnchors()
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
    UnDeadGroupModIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left or 0, sv.top or 0)
end

--Initialize the addon
function UnDeadGroupMod:Initialize()
    UnDeadGroupModIndicator:SetHidden(false)
    ---@type UDGM_SavedVars
    ---@diagnostic disable-next-line: assign-type-mismatch
    UnDeadGroupMod.SavedVariables = ZO_SavedVars:New("UnDeadGroupModSavedVariables", 2, nil, UnDeadGroupMod.defaults)
    UnDeadGroupMod.RestorePosition()
    UnDeadGroupMod.CreateSettings()
    UnDeadGroupMod.VisibilityChange()
    UnDeadGroupMod.UpdateUI()
end

--Hide UI in Menus
local gphFragment = ZO_HUDFadeSceneFragment:New(UnDeadGroupModIndicator, nil, 0)
HUD_SCENE:AddFragment(gphFragment)
HUD_UI_SCENE:AddFragment(gphFragment)


function UnDeadGroupMod.UpdateUI()
    local sv = UnDeadGroupMod.SavedVariables

    -- Difficulty UI
    if sv.isDifficultyVisible then
        UnDeadGroupModIndicatorButton1:SetHidden(not (IsUnitSoloOrGroupLeader("player") and select(1, CanPlayerChangeGroupDifficulty())))
        local isVet = IsUnitUsingVeteranDifficulty("player")
        local isGroupVet = IsGroupUsingVeteranDifficulty()
        local inGroup = IsUnitGrouped("player")
        local diffText = (inGroup and isGroupVet or (not inGroup and isVet)) and "Veteran" or "Normal"
        UnDeadGroupModIndicatorLabel1:SetText("Difficulty: " .. diffText)
    end

    -- My House button
    local isJumpable = CanJumpToHouseFromCurrentLocation()
    UnDeadGroupModIndicatorButtonMyHouse:SetHidden(not isJumpable)

    -- Ready check UI
    if sv.isReadyCheckVisible then
        if ELECTION.ACTIVE then
            UnDeadGroupModIndicatorButtonReady:SetHidden(true)
            UnDeadGroupModIndicatorLabelReady:SetText("|cffff00Election Pending|r")
        elseif ELECTION.COUNTER == 0 then
            UnDeadGroupModIndicatorButtonReady:SetHidden(false)
            UnDeadGroupModIndicatorLabelReady:SetText("Initiate Ready Check")
        else
            ELECTION.COUNTER = ELECTION.COUNTER + 1
            UnDeadGroupModIndicatorLabelReady:SetText(ELECTION.PASSED and "|c00cc99Check Passed|r" or
                "|ce32636Check Failed|r")
            if ELECTION.COUNTER == 10 then ELECTION.COUNTER = 0 end
            UnDeadGroupModIndicatorButtonReady:SetHidden(true)
        end
    end

    -- Role UI
    if sv.isRoleVisible then
        local LFGRole = GetSelectedLFGRole()
        local roleText = (LFGRole == ROLE.DPS and "DPS") or (LFGRole == ROLE.TANK and "TANK") or
            (LFGRole == ROLE.HEALER and "HEAL") or "Unknown"
        UnDeadGroupModIndicatorLabelRole:SetText("Group Role: " .. roleText)
        UnDeadGroupModIndicatorButtonRole:SetHidden(not CanUpdateSelectedLFGRole())
    end

    -- Queue name
    sv.SelectedQName = QUEUE_NAMES[sv.selectedQ] or sv.SelectedQName

    -- Helper: is friend currently in my group
    local function IsFriendInMyGroup(displayName)
        if not IsUnitGrouped("player") or not displayName or displayName == "" then return false end
        local groupSize = GetGroupSize()
        for i = 1, groupSize do
            local tag = GetGroupUnitTagByIndex(i)
            if tag and GetUnitDisplayName(tag) == displayName then
                return true
            end
        end
        return false
    end

    -- Friend UI update helper
    local function updateFriendUI(idx, sv, isJumpable)
        local friendName = sv.Friends[idx] or ""
        local label      = _G["UnDeadGroupModIndicatorLabel" .. (idx + 1)]
        local jumpBtn    = _G["UnDeadGroupModIndicatorButtonJump" .. idx]
        local inviteBtn  = _G["UnDeadGroupModIndicatorButton" .. (idx + 1)]
        local houseBtn   = _G["UnDeadGroupModIndicatorButtonHouse" .. idx]

        local status     = FRIEND_STATUS.NOT_FRIEND

        if IsFriend(friendName) then
            for i = 1, GetNumFriends() do
                local fname, _, fstatus = GetFriendInfo(i)
                if fname == friendName then
                    ---@diagnostic disable-next-line: cast-local-type
                    status = fstatus
                    _, _, sv.FriendZones[idx] = GetFriendCharacterInfo(i)
                    break
                end
            end
        elseif friendName ~= "" then
            label:SetText("|c" .. COLOR_STATUS[FRIEND_STATUS.NOT_FRIEND] .. "User not a Friend|r")
            houseBtn:SetHidden(true)
            jumpBtn:SetHidden(true)
            inviteBtn:SetHidden(true)
            return
        end

        -- Label text
        if status == FRIEND_STATUS.NOT_FRIEND then
            label:SetText(idx == 1 and "Add Friends in Settings" or "")
        else
            local color = COLOR_STATUS[status] or COLOR_STATUS[FRIEND_STATUS.OFFLINE]
            label:SetText("|c" .. color .. friendName .. "|r")
        end

        -- Group highlight (correct detection of friend in player's group)
        if status == FRIEND_STATUS.ONLINE and IsFriendInMyGroup(friendName) then
            label:SetText("|c" .. COLOR_STATUS.IN_MY_GROUP .. friendName .. "|r")
            inviteBtn:SetHidden(true)
        end

        -- Button visibility
        houseBtn:SetHidden(not isJumpable or status == FRIEND_STATUS.NOT_FRIEND)
        local canInteract = status ~= FRIEND_STATUS.NOT_FRIEND and status ~= FRIEND_STATUS.OFFLINE
        jumpBtn:SetHidden(not canInteract)
        inviteBtn:SetHidden(not canInteract)
    end

    -- Loop over friends
    local isJumpable = CanJumpToHouseFromCurrentLocation()
    for i = 1, 3 do
        updateFriendUI(i, UnDeadGroupMod.SavedVariables, isJumpable)
    end
end

function UnDeadGroupMod.VisibilityChange()
    local sv = UnDeadGroupMod.SavedVariables

    --Title Visible
    UnDeadGroupModIndicatorTitle:SetHidden(not sv.isTitleVisible)

    -- Difficulty
    local diffVisible = sv.isDifficultyVisible
    UnDeadGroupModIndicatorLabelRole:SetAnchor(3,
        diffVisible and UnDeadGroupModIndicatorLabel1 or UnDeadGroupModIndicatorButtonOptions, 6, 0, 0)
    UnDeadGroupModIndicatorLabel1:SetHidden(not diffVisible)
    UnDeadGroupModIndicatorButton1:SetHidden(not diffVisible)
    UnDeadGroupModIndicatorButtonRandom:SetHidden(not diffVisible)

    -- Role
    local roleVisible = sv.isRoleVisible
    UnDeadGroupModIndicatorButtonMyHouse:SetAnchor(2,
        roleVisible and UnDeadGroupModIndicatorButtonRole or UnDeadGroupModIndicatorTitle,
        8, roleVisible and 0 or -50, -1)
    UnDeadGroupModIndicatorLabel2:SetAnchor(3,
        roleVisible and UnDeadGroupModIndicatorLabelRole or UnDeadGroupModIndicatorLabel1,
        6, 0, 0)
    UnDeadGroupModIndicatorLabelRole:SetHidden(not roleVisible)
    UnDeadGroupModIndicatorButtonRole:SetHidden(not roleVisible)

    -- Ready Check
    local readyVisible = sv.isReadyCheckVisible
    UnDeadGroupModIndicatorLabelReady:SetHidden(not readyVisible)
    UnDeadGroupModIndicatorButtonReady:SetHidden(not readyVisible)

    -- No Role & No Difficulty
    if not roleVisible and not diffVisible then
        UnDeadGroupModIndicatorLabel2:SetAnchor(3, UnDeadGroupModIndicatorButtonOptions, 6, 0, 0)
    end

    --Difficulty and Role Not Visible
    if UnDeadGroupMod.SavedVariables.isRoleVisible == false and UnDeadGroupMod.SavedVariables.isDifficultyVisible == false then
        UnDeadGroupModIndicatorLabel2:SetAnchor(3, UnDeadGroupModIndicatorButtonOptions, 6, 0, 0)
    end
end

function UnDeadGroupMod.AFUpdate(eventCode, result)
    if UnDeadGroupMod.SavedVariables.willAcceptLFGCheck == true and result == 4 then
        AcceptLFGReadyCheckNotification()
    end
end

function UnDeadGroupMod.PlayerActivated()
    local numFriends = GetNumFriends()
    for index = 1, numFriends do
        UnDeadGroupMod.FriendList[index] = GetFriendInfo(index)
    end
    --for aIndex = 1, 40 do
    --UnDeadGroupMod.SavedVariables.ActivitySetIdList[aIndex] = GetActivitySetIdByTypeAndIndex(7, aIndex)
    --local name, description, sortOrder = GetActivitySetInfo()
    --end

    --local rewardUIDataId, xpReward = GetActivitySetRewardData()
    --d(rewardUIDataId)
    --d(xpReward) --33682
end

function UnDeadGroupMod.GroupInviteReceived(_, _, inviterDisplayName)
    local sv = UnDeadGroupMod.SavedVariables
    if not sv.willAcceptGroupInvite then return end
    for i = 1, 3 do
        if inviterDisplayName == sv.Friends[i] then
            AcceptGroupInvite()
            break
        end
    end
end

local originalAddPrompt = PLAYER_TO_PLAYER.AddPromptToIncomingQueue
function PLAYER_TO_PLAYER.AddPromptToIncomingQueue(self, interactType, ...)
    if interactType == 19 and groupMemberJoinedFlag and UnDeadGroupMod.SavedVariables.willNotAcceptTravelToLeader then
        groupMemberJoinedFlag = false
        return {}
    end
    return originalAddPrompt(self, interactType, ...)
end

function UnDeadGroupMod.OnGroupMemberJoined(_, _, _, isLocalPlayer)
    if isLocalPlayer and UnDeadGroupMod.SavedVariables.willNotAcceptTravelToLeader then
        groupMemberJoinedFlag = true
    end
end

function UnDeadGroupMod.ElectionResult(_, result)
    if result == 4 or result == 5 then
        ELECTION.COUNTER = 1
        ELECTION.PASSED = (result == 4)
    end
    ELECTION.ACTIVE = false
end

function UnDeadGroupMod.ChatMessageEvent(eventCode, channelType, fromName, text, isCustomerService, fromDisplayName)
    if text == JOIN_GROUP_CODE and channelType == 2 then
        GroupInviteByName(fromName)
    end
end

function UnDeadGroupMod.SendJoinMessage()
    local msgToSend = string.format("/w %s %s", UnDeadGroupMod.FriendToJoin, JOIN_GROUP_CODE)
    ---@diagnostic disable-next-line: undefined-field
    CHAT_SYSTEM:StartTextEntry(msgToSend)
    ---@diagnostic disable-next-line: undefined-global
    ZO_ChatWindowTextEntry:SetAlpha(1)
    ---@diagnostic disable-next-line: undefined-global
    ZO_ChatWindowTextEntryEditBox:SelectAll()
    ---@diagnostic disable-next-line: undefined-global
    ZO_ChatWindowTextEntryEditBox:TakeFocus()
end

function UnDeadGroupMod.LeaveLFG()
    if UnDeadGroupMod.SavedVariables.canLeaveLFG then GroupLeave() end
end

--Events
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_ADD_ON_LOADED, UnDeadGroupMod.OnAddOnLoaded)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_PLAYER_ACTIVATED, UnDeadGroupMod.PlayerActivated)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForUpdate(UnDeadGroupMod.name, UnDeadGroupMod.updateTimeInSeconds, UnDeadGroupMod.UpdateUI)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, UnDeadGroupMod.AFUpdate)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_GROUP_ELECTION_RESULT, UnDeadGroupMod.ElectionResult)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_GROUP_INVITE_RECEIVED, UnDeadGroupMod.GroupInviteReceived)
--EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_GROUPING_TOOLS_LFG_JOINED, UnDeadGroupMod.LFGJoined)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_GROUP_MEMBER_JOINED, UnDeadGroupMod.OnGroupMemberJoined)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_CHAT_MESSAGE_CHANNEL, UnDeadGroupMod.ChatMessageEvent)
---@diagnostic disable-next-line: param-type-mismatch
EVENT_MANAGER:RegisterForEvent(UnDeadGroupMod.name, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, UnDeadGroupMod.LeaveLFG)
