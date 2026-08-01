-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcastInternal
local internal = LibGroupBroadcast.internal
local authKey = internal.authKey

local function SetupGroupedTest()
    if ResetGroupAddOnDataBroadcast then
        ResetGroupAddOnDataBroadcast()
    end
    if SetGroupAddOnDataBroadcastFailOnInvalidGroup then
        SetGroupAddOnDataBroadcastFailOnInvalidGroup(false)
    end
end

local function SetupUngroupedTest()
    if ResetGroupAddOnDataBroadcast then
        ResetGroupAddOnDataBroadcast()
    end
    if SetGroupAddOnDataBroadcastFailOnInvalidGroup then
        SetGroupAddOnDataBroadcastFailOnInvalidGroup(true)
    end
end

local function CanRunGroupedTests()
    if SetGroupAddOnDataBroadcastFailOnInvalidGroup then return true end
    return IsUnitGrouped("player")
end

local function CanRunUngroupedTests()
    if SetGroupAddOnDataBroadcastFailOnInvalidGroup then return true end
    return not IsUnitGrouped("player")
end

Taneth("LibGroupBroadcast", function()
    describe("game api", function()
        it("attempt re-register for auth key", function()
            local authKey, addonName = RegisterForGroupAddOnDataBroadcastAuthKey("LibGroupBroadcastTest")
            assert.is_nil(authKey)
            assert.equals("LibGroupBroadcast", addonName)
        end)

        describe("without group", function()
            -- TODO beforeEach(SetupUngroupedTest)

            it("get invalid group result", function()
                SetupUngroupedTest()
                if CanRunUngroupedTests() then
                    local result = BroadcastAddOnDataToGroup(authKey, 1)
                    assert.equals(GROUP_ADD_ON_DATA_BROADCAST_RESULT_INVALID_GROUP, result)
                else
                    skip()
                end
            end)
        end)

        describe("with group", function()
            -- TODO beforeEach(SetupGroupedTest)

            it("send with invalid auth key", function()
                SetupGroupedTest()
                if CanRunGroupedTests() then
                    local result = BroadcastAddOnDataToGroup(0, 1)
                    assert.equals(GROUP_ADD_ON_DATA_BROADCAST_RESULT_INVALID_AUTH_KEY, result)
                else
                    skip()
                end
            end)

            it("get too large result", function()
                SetupGroupedTest()
                if CanRunGroupedTests() then
                    local result = BroadcastAddOnDataToGroup(authKey, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                    assert.equals(GROUP_ADD_ON_DATA_BROADCAST_RESULT_TOO_LARGE, result)
                else
                    skip()
                end
            end)

            it.async("receive data", function(done)
                SetupGroupedTest()
                if CanRunGroupedTests() then
                    EVENT_MANAGER:RegisterForEvent("LibGroupBroadcastTest", EVENT_GROUP_ADD_ON_DATA_RECEIVED,
                        function(event, unitTag, ...)
                            EVENT_MANAGER:UnregisterForEvent("LibGroupBroadcastTest",
                                EVENT_GROUP_ADD_ON_DATA_RECEIVED)
                            assert.is_true(IsUnitPlayer(unitTag))
                            assert.same({ 2, 0, 0, 0, 0, 0, 0, 0 }, { ... })
                            done()
                        end)

                    local result = BroadcastAddOnDataToGroup(authKey, 2)
                    assert.equals(GROUP_ADD_ON_DATA_BROADCAST_RESULT_SUCCESS, result)

                    local result2 = BroadcastAddOnDataToGroup(authKey, 1)
                    assert.equals(GROUP_ADD_ON_DATA_BROADCAST_RESULT_ON_COOLDOWN, result2)
                else
                    skip()
                end
            end)
        end)
    end)
end)
