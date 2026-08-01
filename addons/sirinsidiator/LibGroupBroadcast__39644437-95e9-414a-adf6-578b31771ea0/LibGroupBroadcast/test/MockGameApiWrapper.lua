-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local GameApiWrapper = LGB.internal.class.GameApiWrapper

--[[ doc.lua begin ]] --

--- @class MockGameApiWrapper: GameApiWrapper
--- @field New fun(self: MockGameApiWrapper, callbackManager: ZO_CallbackObject): MockGameApiWrapper
local MockGameApiWrapper = GameApiWrapper:Subclass()
LGB.internal.class.MockGameApiWrapper = MockGameApiWrapper

function MockGameApiWrapper:Initialize(callbackManager)
    GameApiWrapper.Initialize(self, 0, nil, callbackManager)
    self.cooldown = 10
    self.initialSendDelay = 5
    self.lastSendTime = 0
    self.inCombat = false
    self.inGroup = true
    self.unitTag = "player"
end

function MockGameApiWrapper:GetCooldown()
    local timeSinceLastSend = GetGameTimeMilliseconds() - self.lastSendTime
    return math.max(0, self.cooldown - timeSinceLastSend)
end

function MockGameApiWrapper:SetCooldown(cooldown)
    self.cooldown = cooldown
end

function MockGameApiWrapper:GetInitialSendDelay()
    return self.cooldown / 2
end

function MockGameApiWrapper:IsInCombat()
    return self.inCombat
end

function MockGameApiWrapper:SetInCombat(inCombat)
    self.inCombat = inCombat
end

function MockGameApiWrapper:IsGrouped()
    return self.inGroup
end

function MockGameApiWrapper:SetGrouped(inGroup)
    self.inGroup = inGroup
end

function MockGameApiWrapper:BroadcastData(buffer)
    if self:GetCooldown() > 0 then
        return GROUP_ADD_ON_DATA_BROADCAST_RESULT_ON_COOLDOWN
    end

    local values = buffer:ToUInt32Array()
    if #values > 8 then
        return GROUP_ADD_ON_DATA_BROADCAST_RESULT_TOO_LARGE
    end

    zo_callLater(function()
        self:OnDataReceived(self.unitTag, unpack(values))
    end, 10)
    self.lastSendTime = GetGameTimeMilliseconds()
    return GROUP_ADD_ON_DATA_BROADCAST_RESULT_SUCCESS
end

function MockGameApiWrapper:SetUnitTag(unitTag)
    self.unitTag = unitTag
end
