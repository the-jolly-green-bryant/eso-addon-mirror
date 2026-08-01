-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local deferred = LibPromiseTest.deferred
    local resolved = LibPromiseTest.resolved
    local testFulfilled = LibPromiseTest.testFulfilled
    local dummy = { dummy = "dummy" }          -- we fulfill or reject with this when we don't intend to test against it
    local sentinel = { sentinel = "sentinel" } -- a sentinel fulfillment value to test for with strict equality

    describe("2.2.2: If `onFulfilled` is a function,", function()
        describe(
            "2.2.2.1: it must be called after `promise` is fulfilled, with `promise`'s fulfillment value as its first argument.",
            function()
                testFulfilled(sentinel, function(promise, done)
                    promise:Then(function(value)
                        assert.equals(value, sentinel)
                        done()
                    end)
                end)
            end)

        describe("2.2.2.2: it must not be called before `promise` is fulfilled", function()
            it.async("fulfilled after a delay", function(done)
                local d = deferred()
                local isFulfilled = false

                d.promise:Then(function()
                    assert.equals(isFulfilled, true)
                    done()
                end)

                zo_callLater(function()
                    d.resolve(dummy)
                    isFulfilled = true
                end, 50)
            end)

            it.async("never fulfilled", function(done)
                local d = deferred()
                local onFulfilledCalled = false

                d.promise:Then(function()
                    onFulfilledCalled = true
                    done()
                end)

                zo_callLater(function()
                    assert.equals(onFulfilledCalled, false)
                    done()
                end, 150)
            end)
        end)

        describe("2.2.2.3: it must not be called more than once.", function()
            it.async("already-fulfilled", function(done)
                local timesCalled = 0

                resolved(dummy):Then(function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)
            end)

            it.async("trying to fulfill a pending promise more than once, immediately", function(done)
                local d = deferred()
                local timesCalled = 0

                d.promise:Then(function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)

                d.resolve(dummy)
                d.resolve(dummy)
            end)

            it.async("trying to fulfill a pending promise more than once, delayed", function(done)
                local d = deferred()
                local timesCalled = 0

                d.promise:Then(function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)

                zo_callLater(function()
                    d.resolve(dummy)
                    d.resolve(dummy)
                end, 50)
            end)

            it.async("trying to fulfill a pending promise more than once, immediately then delayed", function(done)
                local d = deferred()
                local timesCalled = 0

                d.promise:Then(function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)

                d.resolve(dummy)
                zo_callLater(function()
                    d.resolve(dummy)
                end, 50)
            end)

            it.async("when multiple `then` calls are made, spaced apart in time", function(done)
                local d = deferred()
                local timesCalled = { 0, 0, 0 }

                d.promise:Then(function()
                    timesCalled[1] = timesCalled[1] + 1
                    assert.equals(timesCalled[1], 1)
                end)

                zo_callLater(function()
                    d.promise:Then(function()
                        timesCalled[2] = timesCalled[2] + 1
                        assert.equals(timesCalled[2], 1)
                    end)
                end, 50)

                zo_callLater(function()
                    d.promise:Then(function()
                        timesCalled[3] = timesCalled[3] + 1
                        assert.equals(timesCalled[3], 1)
                        done()
                    end)
                end, 100)

                zo_callLater(function()
                    d.resolve(dummy)
                end, 150)
            end)

            it.async("when `then` is interleaved with fulfillment", function(done)
                local d = deferred()
                local timesCalled = { 0, 0 }

                d.promise:Then(function()
                    timesCalled[1] = timesCalled[1] + 1
                    assert.equals(timesCalled[1], 1)
                end)

                d.resolve(dummy)

                d.promise:Then(function()
                    timesCalled[2] = timesCalled[2] + 1
                    assert.equals(timesCalled[2], 1)
                    done()
                end)
            end)
        end)
    end)
end)
