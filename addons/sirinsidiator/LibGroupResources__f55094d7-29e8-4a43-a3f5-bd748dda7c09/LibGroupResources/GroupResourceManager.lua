-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

local GroupResources = LibGroupBroadcast:GetHandlerApi("GroupResources")

--- @class GroupResourceManager
local GroupResourceManager = ZO_InitializingObject:Subclass()
GroupResources.GroupResourceManager = GroupResourceManager

--- Initializes the group resource manager.
--- @param handler Handler The handler object.
--- @param id number The ID of the group resource.
--- @param name string The name of the group resource.
--- @param powerType number The power type of the group resource.
--- @param callbackManager ZO_CallbackObject The callback manager.
--- @param api LibGroupBroadcast The API.
function GroupResourceManager:Initialize(handler, id, name, powerType, callbackManager, api)
    local protocol = handler:DeclareProtocol(id, name)

    protocol:AddField(api.CreatePercentageField("percentage", {
        numBits = 6,
    }))
    protocol:AddField(api.CreateOptionalField(api.CreateNumericField("maximum", {
        numBits = 11,
        precision = 100,
        minValue = 0,
        maxValue = (2 ^ 11 - 1) * 100,
        trimValues = true
    })))
    protocol:OnData(function(unitTag, data) self:OnGroupResourceChanged(unitTag, data.percentage, data.maximum) end)
    protocol:Finalize({
        isRelevantInCombat = true,
    })

    self.callbackManager = callbackManager
    self.callbackName = "On" .. name .. "Changed"
    self.protocol = protocol
    self.config = {
        sendChangeThreshold = 0.05,
        sendMaximum = true,
    }
    self.resourceCache = {}

    local namespace = "LibGroupBroadcast" .. name
    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_POWER_UPDATE,
        function(_, _, _, _, powerValue, powerMax, _) self:OnPlayerResourceChanged(powerValue, powerMax) end)
    EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, powerType)

    EVENT_MANAGER:RegisterForEvent(namespace, EVENT_GROUP_MEMBER_LEFT,
        function(_, unitName, _, isLocalPlayer, _, _, _)
            if isLocalPlayer then
                ZO_ClearTable(self.resourceCache)
            else
                self.resourceCache[unitName] = nil
            end
        end)
    self.namespace = namespace
end

function GroupResourceManager:OnGroupResourceChanged(unitTag, percentage, maximum)
    local unitName = GetRawUnitName(unitTag)
    local entry = self.resourceCache[unitName]
    if not entry then
        entry = {
            percentage = 1,
            current = 100,
            maximum = 100,
        }
        self.resourceCache[unitName] = entry
    end

    entry.percentage = percentage
    maximum = maximum or entry.maximum
    if maximum == 100 then
        entry.current = math.floor(percentage * 100)
    else
        entry.current = math.floor(percentage * maximum / 100) * 100
    end
    entry.maximum = maximum
    entry.lastUpdate = GetGameTimeMilliseconds()

    self.callbackManager:FireCallbacks(self.callbackName, unitTag, unitName, entry.current, entry.maximum,
        entry.percentage)
end

function GroupResourceManager:OnPlayerResourceChanged(powerValue, powerMax)
    powerMax = math.max(powerMax, 1)
    local percentage = powerValue / powerMax
    local _, cachedMaximum, cachedPercentage = self:GetValues("player")

    local data = {}
    local shouldSend = false
    if not cachedPercentage or (percentage == 1 and cachedPercentage ~= 1) or math.abs(cachedPercentage - percentage) >= self.config.sendChangeThreshold then
        data.percentage = percentage
        shouldSend = true
    end

    if self.config.sendMaximum then
        local diff = cachedMaximum and math.abs(cachedMaximum - powerMax) or 1000
        if not cachedMaximum or shouldSend or (diff >= 100 and diff / cachedMaximum >= self.config.sendChangeThreshold) then
            data.percentage = percentage
            data.maximum = powerMax
            shouldSend = true
        end
    end

    if shouldSend and self:CanSend() then
        self.protocol:Send(data)
    end
end

function GroupResourceManager:CanSend()
    return IsUnitGrouped("player") and self.protocol:IsEnabled()
end

function GroupResourceManager:RegisterForChanges(callback)
    self.callbackManager:RegisterCallback(self.callbackName, callback)
end

function GroupResourceManager:UnregisterForChanges(callback)
    self.callbackManager:UnregisterCallback(self.callbackName, callback)
end

function GroupResourceManager:GetValues(unitTag)
    local unitName = GetRawUnitName(unitTag)
    local entry = self.resourceCache[unitName]
    if not entry then
        return
    end
    return entry.current, entry.maximum, entry.percentage
end

function GroupResourceManager:GetLastUpdateTime(unitTag)
    local unitName = GetRawUnitName(unitTag)
    local entry = self.resourceCache[unitName]
    if not entry or not entry.lastUpdate then
        return -1
    end
    return entry.lastUpdate
end
