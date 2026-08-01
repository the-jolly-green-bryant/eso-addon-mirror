local L = EasyTravel_AEM.Localization
local Print = EasyTravel_AEM.Print
local WrapFunction = EasyTravel_AEM.WrapFunction
local DialogHelper = EasyTravel_AEM.DialogHelper
local TargetHelper = EasyTravel_AEM.TargetHelper

local EVENT_NAMESPACE1 = "EasyTravelAEM1"
local EVENT_NAMESPACE2 = "EasyTravelAEM2"

local STATE_READY = 1
local STATE_JUMP_REQUESTED = 2
local STATE_JUMP_STARTED = 3
local STATE_JUMP_REQUEST_FAILED = 4
local STATE_NO_JUMP_TARGETS = 5

local STATUS_TEXT = {
    [STATE_READY] = L["STATUS_TEXT_READY"],
    [STATE_JUMP_REQUESTED] = L["STATUS_TEXT_JUMP_REQUESTED"],
    [STATE_JUMP_STARTED] = L["STATUS_TEXT_JUMP_STARTED"],
    [STATE_JUMP_REQUEST_FAILED] = L["STATUS_TEXT_JUMP_REQUEST_FAILED"],
    [STATE_NO_JUMP_TARGETS] = L["STATUS_TEXT_NO_JUMP_TARGETS"],
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

local RECALL_ABILITY_ID = 6811
local _, RECALL_CAST_TIME = GetAbilityCastInfo(RECALL_ABILITY_ID)
RECALL_CAST_TIME = RECALL_CAST_TIME / 1000

local JumpHelper = ZO_Object:Subclass()

function JumpHelper:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function JumpHelper:Initialize()
    self.characterName = GetRawUnitName("player")
    self.state = STATE_READY

    self.HandleCombatState = function(...) self:OnCombatStateChanged(...) end
    self.HandleCombatEventResults = function(...) self:OnCombatEventResults(...) end
    self.HandleCombatEventErrors = function(...) self:OnCombatEventErrors(...) end
    self.HandleWeaponPairLockState = function(...) self:OnWeaponPairLockStateChanged(...) end
    self.HandleSocialErrors = function(...) self:OnSocialError(...) end
    self.HandleCleanup = function() self:CleanUp() end

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

    DialogHelper:SetText(STATUS_TEXT[state])
    if(state == STATE_JUMP_STARTED) then
        DialogHelper:SetCountdown(RECALL_CAST_TIME)
    else
        DialogHelper:ClearCountdown()
    end
end

function JumpHelper:OnCombatStateChanged(eventCode, inCombat)
    if(inCombat) then
        CancelCast()
        self:CleanUp()
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
        else
            Print(L["JUMP_FAILED_UNHANDLED"], result, GetString("SI_ACTIONRESULT", result))
            self:CleanUp()
        end
    end
end

function JumpHelper:OnWeaponPairLockStateChanged(eventCode, locked)
    if(self.state == STATE_JUMP_STARTED and not locked) then
        self:CleanUp()
    end
end

function JumpHelper:OnSocialError(eventCode, error)
    if(IS_SOCIAL_ERROR_JUMP_RELATED[error]) then
        if(CAN_RECOVER_FROM_SOCIAL_ERROR[error]) then
            self:SetState(STATE_JUMP_REQUEST_FAILED)
            self:Retry()
        else
            self:CleanUp()
        end
    end
end

function JumpHelper:OnTargetZoneChanged(zoneName)
    if(zoneName == self.targetZone and self.state == STATE_NO_JUMP_TARGETS) then
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

function JumpHelper:JumpTo(zoneName)
    if(IsUnitInCombat("player")) then return end
    CancelCast()
    self.targetZone = zoneName
    DialogHelper:ShowDialog(zoneName)
    TargetHelper:SetTargetZone(zoneName)
    self:RegisterEventHandlers()
    self:Retry()
end

function JumpHelper:Retry()
    TargetHelper:RebuildTargetList()
    if(TargetHelper:JumpToNextTarget()) then
        self:SetState(STATE_JUMP_REQUESTED)
    else
        self:SetState(STATE_NO_JUMP_TARGETS)
    end
end

function JumpHelper:CleanUp()
    DialogHelper:HideDialog()
    self:UnregisterEventHandlers()
    self:SetState(STATE_READY)
end

EasyTravel_AEM.JumpHelper = JumpHelper:New()
