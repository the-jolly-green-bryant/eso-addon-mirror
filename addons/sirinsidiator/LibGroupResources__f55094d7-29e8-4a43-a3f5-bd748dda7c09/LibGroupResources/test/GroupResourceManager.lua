-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
local LGB = LibGroupBroadcast
local GroupResources = LGB:GetHandlerApi("GroupResources")
local SetupMockInstance = LGB.SetupMockInstance
local GroupResourceManager = GroupResources.GroupResourceManager

local function SetupResource(id, name, powerType)
    local api = SetupMockInstance()
    local callbackManager = ZO_CallbackObject:New()
    local handler = api:RegisterHandler("test")
    local resource = GroupResourceManager:New(handler, id, name, powerType, callbackManager, api)
    resource.CanSend = function() return true end
    return resource, api
end

local function TeardownResource(handler)
    local namespace = handler.namespace
    EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_POWER_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_GROUP_MEMBER_LEFT)
end

Taneth("LibGroupResources", function()
    describe("GroupResourceManager", function()
        it("should be able to create a new instance", function()
            local resource = SetupResource(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)
            assert.is_true(ZO_Object.IsInstanceOf(resource, GroupResourceManager))
            TeardownResource(resource)
        end)

        it.async("should be able to send power updates including the maximum value", function(done)
            local resource = SetupResource(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)

            local current1, maximum1, percentage1 = resource:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            resource:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(10600, current2)
                assert.equals(21000, maximum2)
                assert.equals(32 / 63, percentage2)

                local current3, maximum3, percentage3 = resource:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownResource(resource)
                done()
            end)
            resource:OnPlayerResourceChanged(10540, 21023)
        end, 1000)

        it.async("should be able to send power updates without the maximum value", function(done)
            local resource = SetupResource(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)
            resource.config.sendMaximum = false

            local current1, maximum1, percentage1 = resource:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            resource:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(50, current2)
                assert.equals(100, maximum2)
                assert.equals(32 / 63, percentage2)

                local current3, maximum3, percentage3 = resource:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownResource(resource)
                done()
            end)
            resource:OnPlayerResourceChanged(10540, 21023)
        end, 1000)


        it.async("should be able to replace queued power updates with more current values", function(done)
            local resource = SetupResource(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)
            resource.config.sendMaximum = false

            local current1, maximum1, percentage1 = resource:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            resource:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(100, current2)
                assert.equals(100, maximum2)
                assert.equals(1, percentage2)

                local current3, maximum3, percentage3 = resource:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownResource(resource)
                done()
            end)
            resource:OnPlayerResourceChanged(0, 21023)
            resource:OnPlayerResourceChanged(21023, 21023)
        end, 1000)

        it.async("should be able to send power updates when the maximum value is 0", function(done)
            local resource = SetupResource(1, "Stamina", COMBAT_MECHANIC_FLAGS_STAMINA)

            local current1, maximum1, percentage1 = resource:GetValues("player")
            assert.is_nil(current1)
            assert.is_nil(maximum1)
            assert.is_nil(percentage1)

            resource:RegisterForChanges(function(unitTag, unitName, current2, maximum2, percentage2)
                assert.equals("player", unitTag)
                assert.equals(GetRawUnitName("player"), unitName)
                assert.equals(0, current2)
                assert.equals(0, maximum2)
                assert.equals(0, percentage2)

                local current3, maximum3, percentage3 = resource:GetValues("player")
                assert.equals(current2, current3)
                assert.equals(maximum2, maximum3)
                assert.equals(percentage2, percentage3)

                TeardownResource(resource)
                done()
            end)
            resource:OnPlayerResourceChanged(0, 0)
        end, 1000)
    end)
end)
