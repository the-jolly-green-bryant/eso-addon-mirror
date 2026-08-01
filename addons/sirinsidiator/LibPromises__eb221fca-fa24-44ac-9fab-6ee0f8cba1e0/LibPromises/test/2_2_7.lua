-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local deferred = LibPromiseTest.deferred
    local testFulfilled = LibPromiseTest.testFulfilled
    local testRejected = LibPromiseTest.testRejected

    local reasons = LibPromiseTest.reasons

    local dummy = { dummy = "dummy" }          -- we fulfill or reject with this when we don't intend to test against it
    local sentinel = { sentinel = "sentinel" } -- a sentinel fulfillment value to test for with strict equality
    local other = { other = "other" }          -- a value we don't want to be strict equal to

    describe("2.2.7: `then` must return a promise: `promise2 = promise1:Then(onFulfilled, onRejected)`", function()
        it.async("is a promise", function(done)
            local promise1 = deferred().promise
            local promise2 = promise1:Then()

            assert(type(promise2) == "table" or type(promise2) == "function")
            assert(promise2 ~= nil)
            assert.equals(type(promise2.Then), "function")
            done()
        end)

        describe(
            "2.2.7.1: If either `onFulfilled` or `onRejected` returns a value `x`, run the Promise Resolution Procedure `[[Resolve]](promise2, x)`",
            function()
                it.async("see separate 3.3 tests", function(done) done() end)
            end)

        describe(
            "2.2.7.2: If either `onFulfilled` or `onRejected` throws an exception `e`, `promise2` must be rejected with `e` as the reason.",
            function()
                local function testReason(expectedReason, stringRepresentation)
                    describe("The reason is " .. stringRepresentation, function()
                        testFulfilled(dummy, function(promise1, done)
                            local promise2 = promise1:Then(function()
                                error(expectedReason)
                            end)

                            promise2:Then(nil, function(actualReason)
                                assert.equals(actualReason, expectedReason)
                                done()
                            end)
                        end)
                        testRejected(dummy, function(promise1, done)
                            local promise2 = promise1:Then(nil, function()
                                error(expectedReason)
                            end)

                            promise2:Then(nil, function(actualReason)
                                assert.equals(actualReason, expectedReason)
                                done()
                            end)
                        end)
                    end)
                end

                for stringRepresentation, func in pairs(reasons) do
                    testReason(func(), stringRepresentation)
                end
            end)

        describe(
            "2.2.7.3: If `onFulfilled` is not a function and `promise1` is fulfilled, `promise2` must be fulfilled with the same value.",
            function()
                local function testNonFunction(nonFunction, stringRepresentation)
                    describe("`onFulfilled` is " .. stringRepresentation, function()
                        testFulfilled(sentinel, function(promise1, done)
                            local promise2 = promise1:Then(nonFunction)

                            promise2:Then(function(value)
                                assert.equals(value, sentinel)
                                done()
                            end)
                        end)
                    end)
                end

                testNonFunction(nil, "`nil`")
                testNonFunction(false, "`false`")
                testNonFunction(5, "`5`")
                testNonFunction({}, "a table")
                testNonFunction({ function() return other end }, "an array containing a function")
            end)

        describe(
            "2.2.7.4: If `onRejected` is not a function and `promise1` is rejected, `promise2` must be rejected with the same reason.",
            function()
                local function testNonFunction(nonFunction, stringRepresentation)
                    describe("`onRejected` is " .. stringRepresentation, function()
                        testRejected(sentinel, function(promise1, done)
                            local promise2 = promise1:Then(nil, nonFunction)

                            promise2:Then(nil, function(reason)
                                assert.equals(reason, sentinel)
                                done()
                            end)
                        end)
                    end)
                end

                testNonFunction(nil, "`nil`")
                testNonFunction(false, "`false`")
                testNonFunction(5, "`5`")
                testNonFunction({}, "a table")
                testNonFunction({ function() return other end }, "an array containing a function")
            end)
    end)
end)
