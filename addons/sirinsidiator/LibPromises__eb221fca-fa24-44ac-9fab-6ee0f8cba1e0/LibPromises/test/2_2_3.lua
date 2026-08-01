-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local deferred = LibPromiseTest.deferred
    local rejected = LibPromiseTest.rejected
    local testRejected = LibPromiseTest.testRejected
    local dummy = { dummy = "dummy" }      -- we fulfill or reject with this when we don't intend to test against it
    local sentinel = { sentinel = "sentinel" } -- a sentinel fulfillment value to test for with strict equality

    describe("2.2.3: If `onRejected` is a function,", function()
        describe(
        "2.2.3.1: it must be called after `promise` is rejected, with `promise`’s rejection reason as its first argument.",
            function()
                testRejected(sentinel, function(promise, done)
                    promise:Then(nil, function(reason)
                        assert.equals(reason, sentinel)
                        done()
                    end)
                end)
            end)

        describe("2.2.3.2: it must not be called before `promise` is rejected", function()
            it.async("rejected after a delay", function(done)
                local d = deferred()
                local isRejected = false

                d.promise:Then(nil, function()
                    assert.equals(isRejected, true)
                    done()
                end)

                zo_callLater(function()
                    d.reject(dummy)
                    isRejected = true
                end, 50)
            end)

            it.async("never rejected", function(done)
                local d = deferred()
                local onRejectedCalled = false

                d.promise:Then(nil, function()
                    onRejectedCalled = true
                    done()
                end)

                zo_callLater(function()
                    assert.equals(onRejectedCalled, false)
                    done()
                end, 150)
            end)
        end)

        describe("2.2.3.3: it must not be called more than once.", function()
            it.async("already-rejected", function(done)
                local timesCalled = 0

                rejected(dummy):Then(nil, function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)
            end)

            it.async("trying to reject a pending promise more than once, immediately", function(done)
                local d = deferred()
                local timesCalled = 0

                d.promise:Then(nil, function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)

                d.reject(dummy)
                d.reject(dummy)
            end)

            it.async("trying to reject a pending promise more than once, delayed", function(done)
                local d = deferred()
                local timesCalled = 0

                d.promise:Then(nil, function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)

                zo_callLater(function()
                    d.reject(dummy)
                    d.reject(dummy)
                end, 50)
            end)

            it.async("trying to reject a pending promise more than once, immediately then delayed", function(done)
                local d = deferred()
                local timesCalled = 0

                d.promise:Then(nil, function()
                    timesCalled = timesCalled + 1
                    assert.equals(timesCalled, 1)
                    done()
                end)

                d.reject(dummy)
                zo_callLater(function()
                    d.reject(dummy)
                end, 50)
            end)

            it.async("when multiple `then` calls are made, spaced apart in time", function(done)
                local d = deferred()
                local timesCalled = { 0, 0, 0 }

                d.promise:Then(nil, function()
                    timesCalled[1] = timesCalled[1] + 1
                    assert.equals(timesCalled[1], 1)
                end)

                zo_callLater(function()
                    d.promise:Then(nil, function()
                        timesCalled[2] = timesCalled[2] + 1
                        assert.equals(timesCalled[2], 1)
                    end)
                end, 50)

                zo_callLater(function()
                    d.promise:Then(nil, function()
                        timesCalled[3] = timesCalled[3] + 1
                        assert.equals(timesCalled[3], 1)
                        done()
                    end)
                end, 100)

                zo_callLater(function()
                    d.reject(dummy)
                end, 150)
            end)

            it.async("when `then` is interleaved with rejection", function(done)
                local d = deferred()
                local timesCalled = { 0, 0 }

                d.promise:Then(nil, function()
                    timesCalled[1] = timesCalled[1] + 1
                    assert.equals(timesCalled[1], 1)
                end)

                d.reject(dummy)

                d.promise:Then(nil, function()
                    timesCalled[2] = timesCalled[2] + 1
                    assert.equals(timesCalled[2], 1)
                    done()
                end)
            end)
        end)
    end)
end)
