-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local testRejected = LibPromiseTest.testRejected
    local deferred = LibPromiseTest.deferred
    local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

    describe("2.1.3.1: When rejected, a promise: must not transition to any other state.", function()
        testRejected(dummy, function(promise, done)
            local onRejectedCalled = false

            promise:Then(function()
                assert.equals(onRejectedCalled, false)
                done()
            end, function()
                onRejectedCalled = true
            end)

            zo_callLater(done, 100)
        end)

        it.async("trying to reject then immediately fulfill", function(done)
            local d = deferred()
            local onRejectedCalled = false

            d.promise:Then(function()
                assert.equals(onRejectedCalled, false)
                done()
            end, function()
                onRejectedCalled = true
            end)

            d.reject(dummy)
            d.resolve(dummy)
            zo_callLater(done, 100)
        end)

        it.async("trying to reject then fulfill, delayed", function(done)
            local d = deferred()
            local onRejectedCalled = false

            d.promise:Then(function()
                assert.equals(onRejectedCalled, false)
                done()
            end, function()
                onRejectedCalled = true
            end)

            zo_callLater(function()
                d.reject(dummy)
                d.resolve(dummy)
            end, 50)
            zo_callLater(done, 100)
        end)

        it.async("trying to reject immediately then fulfill delayed", function(done)
            local d = deferred()
            local onRejectedCalled = false

            d.promise:Then(function()
                assert.equals(onRejectedCalled, false)
                done()
            end, function()
                onRejectedCalled = true
            end)

            d.reject(dummy)
            zo_callLater(function()
                d.resolve(dummy)
            end, 50)
            zo_callLater(done, 100)
        end)
    end)
end)
