local ET = EasyTravel
local internal = ET.internal
local chat = internal.chat
local gettext = internal.gettext
local WrapFunction = internal.WrapFunction

local EVENT_NAMESPACE1 = "EasyTravel1"
local EVENT_NAMESPACE2 = "EasyTravel2"

local STATE_READY = 1
local STATE_JUMP_REQUESTED = 2
local STATE_JUMP_STARTED = 3
local STATE_JUMP_REQUEST_FAILED = 4
local STATE_NO_JUMP_TARGETS = 5

local RESULT_SUCCESS = true
local RESULT_FAILURE = false

local STATUS_TEXT = {
    -- TRANSLATORS: Status message for the jump dialog when nothing has happened yet.
    [STATE_READY] = gettext("Preparing to jump"),
    -- TRANSLATORS: Status message for the jump dialog when the jump request has been sent to the server.
    [STATE_JUMP_REQUESTED] = gettext("Jump requested"),
    -- TRANSLATORS: Status message for the jump dialog when the jump channelling has started. The variable is for the seconds remaining until the actual jump.
    [STATE_JUMP_STARTED] = gettext("Jump in progress (<<1>> seconds left)"),
    -- TRANSLATORS: Status message for the jump dialog when the jump request has failed for any reason.
    [STATE_JUMP_REQUEST_FAILED] = gettext("Jump failed"),
    -- TRANSLATORS: Status message for the jump dialog when the jump cannot be started due to a lack of players in the target locaton.
    [STATE_NO_JUMP_TARGETS] = gettext("No suitable players found\nWaiting for new targets"),
}

local IS_SOCIAL_ERROR_JUMP_RELATED = {
    [SOCIAL_RESULT_CHARACTER_NOT_FOUND] = true,
    [SOCIAL_RESULT_NOT_GROUPED] = true,
    [SOCIAL_RESULT_CANT_JUMP_SELF] = true,
    [SOCIAL_RESULT_NO_LOCATION] = true,
    [SOCIAL_RESULT_DESTINATION_FULL] = true,
    [SOCIAL_RESULT_NO_JUMP_IN_COMBAT] = true,
    [SOCIAL_RESULT_NOT_SAME_GROUP] = true,
    [SOCIAL_RESULT_WRONG_ALLIANCE] = true,
    [SOCIAL_RESULT_JUMPS_EXIT_DISABLED] = true,
    [SOCIAL_RESULT_NO_JUMP_CHAMPION_RANK] = true,
    [SOCIAL_RESULT_JUMP_ENTRY_DISABLED] = true,
    [SOCIAL_RESULT_NOT_IN_SAME_GROUP] = true,
    [SOCIAL_RESULT_NO_INTRA_CAMPAIGN_JUMPS_ALLOWED] = true,
    [SOCIAL_RESULT_BEING_ARRESTED] = true,
    [SOCIAL_RESULT_CANT_JUMP_INVALID_TARGET] = true,
}

local CAN_RECOVER_FROM_SOCIAL_ERROR = {
    [SOCIAL_RESULT_CHARACTER_NOT_FOUND] = true,
    [SOCIAL_RESULT_NOT_GROUPED] = true,
    [SOCIAL_RESULT_CANT_JUMP_SELF] = true,
    [SOCIAL_RESULT_NO_LOCATION] = true,
    [SOCIAL_RESULT_NOT_SAME_GROUP] = true,
    [SOCIAL_RESULT_WRONG_ALLIANCE] = true,
    [SOCIAL_RESULT_NOT_IN_SAME_GROUP] = true,
    [SOCIAL_RESULT_CANT_JUMP_INVALID_TARGET] = true,
}

    -- TRANSLATORS: Generic alert message for when a jump cannot be started due to the current player state
local GENERIC_JUMP_FAILURE_MESSAGE = gettext("You cannot travel right now.")
local PLAYER_BUSY_MESSAGE = {
    -- TRANSLATORS: Alert message when a jump cannot be started due to the player currently sprinting
    [ACTION_RESULT_SPRINTING] = gettext("You cannot travel while sprinting."),
    [ACTION_RESULT_STUNNED] = GENERIC_JUMP_FAILURE_MESSAGE,
    [ACTION_RESULT_DISORIENTED] = GENERIC_JUMP_FAILURE_MESSAGE,
}

local RECALL_ABILITY_ID = 6811
local _, RECALL_CAST_TIME = GetAbilityCastInfo(RECALL_ABILITY_ID)
RECALL_CAST_TIME = RECALL_CAST_TIME / 1000

local JumpHelper = ZO_InitializingObject:Subclass()
ET.class.JumpHelper = JumpHelper

function JumpHelper:Initialize(dialogHelper, targetHelper)
    self.dialogHelper = dialogHelper
    self.targetHelper = targetHelper
    self.characterName = GetRawUnitName("player")
    self.state = STATE_READY

    self.HandleCombatState = function(...) self:OnCombatStateChanged(...) end
    self.HandleCombatEventResults = function(...) self:OnCombatEventResults(...) end
    self.HandleCombatEventErrors = function(...) self:OnCombatEventErrors(...) end
    self.HandleWeaponPairLockState = function(...) self:OnWeaponPairLockStateChanged(...) end
    self.HandleSocialErrors = function(...) self:OnSocialError(...) end
    self.HandleCleanup = function() self:CleanUp(RESULT_SUCCESS) end

    self.HandleFriendTargetZoneChange = function(_, _, _, zoneName) self:OnTargetZoneChanged(zoneName) end
    self.HandleGuildTargetZoneChange = function(_, _, _, _, zoneName) self:OnTargetZoneChanged(zoneName) end
    self.HandleGroupZoneChange = function(_, unitTag)
        if(ZO_Group_IsGroupUnitTag(unitTag)) then
            self:OnTargetZoneChanged(GetUnitZone(unitTag))
        end
    end

    self.HandleFriendTargetStatusChange = function(_, _, _, oldStatus, newStatus) self:OnTargetStatusChanged(oldStatus, newStatus) end
    self.HandleGuildTargetStatusChange = function(_, _, _, oldStatus, newStatus) self:OnTargetStatusChanged(oldStatus, newStatus) end
    self.HandleGroupStatusChange = function(_, unitTag)
        if(ZO_Group_IsGroupUnitTag(unitTag)) then
            local status = IsUnitOnline(unitTag) and PLAYER_STATUS_ONLINE or PLAYER_STATUS_OFFLINE
            self:OnTargetStatusChanged(PLAYER_STATUS_OFFLINE, status)
        end
    end

    self.HandleFriendTargetAdded = function() self:OnTargetAdded() end
    self.HandleGuildTargetAdded = function() self:OnTargetAdded() end
    self.HandleGroupTargetAdded = function(_, unitTag)
        if(ZO_Group_IsGroupUnitTag(unitTag)) then
            self:OnTargetAdded()
        end
    end

    WrapFunction("IsSocialErrorIgnoreResponse", function(original, error)
        if(CAN_RECOVER_FROM_SOCIAL_ERROR[error] and self.state ~= STATE_READY) then return true end
        return original(error)
    end)
end

function JumpHelper:SetState(state)
    self.state = state

    local dialogHelper = self.dialogHelper
    dialogHelper:SetText(STATUS_TEXT[state])
    if(state == STATE_JUMP_STARTED) then
        dialogHelper:SetCountdown(RECALL_CAST_TIME)
    else
        dialogHelper:ClearCountdown()
    end
end

function JumpHelper:OnCombatStateChanged(eventCode, inCombat)
    if(inCombat) then
        CancelCast()
        self:CleanUp(RESULT_FAILURE)
    end
end

function JumpHelper:OnCombatEventResults(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if(targetName == self.characterName) then
        self:SetState(STATE_JUMP_STARTED)
    end
end

function JumpHelper:OnCombatEventErrors(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    if(targetName == self.characterName) then
        self:SetState(STATE_JUMP_REQUEST_FAILED)
        if(result == ACTION_RESULT_BUSY) then
            CancelCast()
            self:Retry()
        elseif(result == ACTION_RESULT_FAILED) then
            self:Retry()
        elseif(PLAYER_BUSY_MESSAGE[result]) then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.GENERAL_ALERT_ERROR, PLAYER_BUSY_MESSAGE[result])
            self:CleanUp(RESULT_FAILURE)
        else
            -- TRANSLATORS: Chat message when a jump failed in a way the addon does not know about yet.
            chat:Printf(gettext("Jump has been interrupted, unhandled result: %d, %s"), result, GetString("SI_ACTIONRESULT", result))
            self:CleanUp(RESULT_FAILURE)
        end
    end
end

function JumpHelper:OnWeaponPairLockStateChanged(eventCode, locked)
    if(self.state == STATE_JUMP_STARTED and not locked) then
        self:CleanUp(RESULT_FAILURE)
    end
end

function JumpHelper:OnSocialError(eventCode, error)
    if(IS_SOCIAL_ERROR_JUMP_RELATED[error]) then
        if(CAN_RECOVER_FROM_SOCIAL_ERROR[error]) then
            self:SetState(STATE_JUMP_REQUEST_FAILED)
            self:Retry()
        else
            self:CleanUp(RESULT_FAILURE)
        end
    end
end

function JumpHelper:OnTargetZoneChanged(zoneName)
    if(self.targetZone and zoneName == self.targetZone.name and self.state == STATE_NO_JUMP_TARGETS) then
        self:Retry()
    end
end

function JumpHelper:OnTargetStatusChanged(oldStatus, newStatus)
    if(oldStatus == PLAYER_STATUS_OFFLINE and newStatus ~= PLAYER_STATUS_OFFLINE and self.state == STATE_NO_JUMP_TARGETS) then
        self:Retry()
    end
end

function JumpHelper:OnTargetAdded()
    if(self.state == STATE_NO_JUMP_TARGETS) then
        self:Retry()
    end
end

function JumpHelper:RegisterEventHandlers()
    if(self.eventHandlersRegistered) then return end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_PLAYER_COMBAT_STATE, self.HandleCombatState)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_COMBAT_EVENT, self.HandleCombatEventResults)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE1, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE1, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, RECALL_ABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE1, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, false)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE1, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_IN_GAMEPAD_PREFERRED_MODE, false)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE2, EVENT_COMBAT_EVENT, self.HandleCombatEventErrors)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE2, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, RECALL_ABILITY_ID)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE2, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_ERROR, true)
    EVENT_MANAGER:AddFilterForEvent(EVENT_NAMESPACE2, EVENT_COMBAT_EVENT, REGISTER_FILTER_IS_IN_GAMEPAD_PREFERRED_MODE, false)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_SOCIAL_ERROR, self.HandleSocialErrors)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_WEAPON_PAIR_LOCK_CHANGED, self.HandleWeaponPairLockState)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_PLAYER_DEACTIVATED, self.HandleCleanup)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_FRIEND_CHARACTER_ZONE_CHANGED, self.HandleFriendTargetZoneChange)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_FRIEND_PLAYER_STATUS_CHANGED, self.HandleFriendTargetStatusChange)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_FRIEND_ADDED, self.HandleFriendTargetAdded)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, self.HandleGuildTargetZoneChange)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, self.HandleGuildTargetStatusChange)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_GUILD_MEMBER_ADDED, self.HandleGuildTargetAdded)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_ZONE_UPDATE, self.HandleGroupZoneChange)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_GROUP_MEMBER_CONNECTED_STATUS, self.HandleGroupStatusChange)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE1, EVENT_UNIT_CREATED, self.HandleGroupTargetAdded)

    self.eventHandlersRegistered = true
end

function JumpHelper:UnregisterEventHandlers()
    if(not self.eventHandlersRegistered) then return end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE2, EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_SOCIAL_ERROR)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_WEAPON_PAIR_LOCK_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_PLAYER_DEACTIVATED)

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_FRIEND_CHARACTER_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_FRIEND_PLAYER_STATUS_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_FRIEND_ADDED)

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_GUILD_MEMBER_ADDED)

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_ZONE_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE1, EVENT_UNIT_CREATED)

    self.eventHandlersRegistered = false
end

function JumpHelper:SetTargetZone(zone)
    self.targetZone = zone
    self.targetHelper:ClearJumpAttempts()
end

function JumpHelper:PrepareJump(message, zone)
    if(IsUnitInCombat("player")) then return false end
    CancelCast()
    self:SetTargetZone(zone)
    self.dialogHelper:ShowDialog(message)
    self:RegisterEventHandlers()
    if(not zone) then
        self:SetState(STATE_JUMP_REQUESTED)
    end
    return true
end

function JumpHelper:JumpTo(zone)
    if(self:PrepareJump(zone.name, zone)) then
        self:Retry()
    end
end

function JumpHelper:JumpToPlayer(player)
    if(self:PrepareJump(player.zone.name)) then
        self.targetHelper:JumpToPlayer(player)
    end
end

function JumpHelper:JumpToGroupLeader()
    local message = GetUnitName(GetGroupLeaderUnitTag())
    if(self:PrepareJump(message)) then
        self.targetHelper:JumpToGroupLeader()
    end
end

function JumpHelper:JumpToHouse(houseId)
    local message = GetCollectibleNickname(GetCollectibleIdForHouse(houseId))
    if(self:PrepareJump(message)) then
        self.targetHelper:JumpToHouse(houseId)
    end
end

function JumpHelper:Retry()
    if(not self.targetZone) then return end
    if(self.targetHelper:JumpToNextTargetInZone(self.targetZone)) then
        self:SetState(STATE_JUMP_REQUESTED)
    else
        self:SetState(STATE_NO_JUMP_TARGETS)
    end
end

function JumpHelper:CleanUp(wasSuccess)
    self.dialogHelper:HideDialog(wasSuccess)
    self:UnregisterEventHandlers()
    self:SetState(STATE_READY)
    self.targetHelper:ClearJumpAttempts()
end
