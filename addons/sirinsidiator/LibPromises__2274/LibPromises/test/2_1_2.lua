-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local testFulfilled = LibPromiseTest.testFulfilled
    local deferred = LibPromiseTest.deferred
    local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

    describe("2.1.2.1: When fulfilled, a promise: must not transition to any other state.", function()
        testFulfilled(dummy, function(promise, done)
            local onFulfilledCalled = false

            promise:Then(function()
                onFulfilledCalled = true
            end, function()
                assert.equals(onFulfilledCalled, false)
                done()
            end)

            zo_callLater(done, 100)
        end)

        it.async("trying to fulfill then immediately reject", function(done)
            local d = deferred()
            local onFulfilledCalled = false

            d.promise:Then(function()
                onFulfilledCalled = true
            end, function()
                assert.equals(onFulfilledCalled, false)
                done()
            end)

            d.resolve(dummy)
            d.reject(dummy)
            zo_callLater(done, 100)
        end)

        it.async("trying to fulfill then reject, delayed", function(done)
            local d = deferred()
            local onFulfilledCalled = false

            d.promise:Then(function()
                onFulfilledCalled = true
            end, function()
                assert.equals(onFulfilledCalled, false)
                done()
            end)

            zo_callLater(function()
                d.resolve(dummy)
                d.reject(dummy)
            end, 50)
            zo_callLater(done, 100)
        end)

        it.async("trying to fulfill immediately then reject delayed", function(done)
            local d = deferred()
            local onFulfilledCalled = false

            d.promise:Then(function()
                onFulfilledCalled = true
            end, function()
                assert.equals(onFulfilledCalled, false)
                done()
            end)

            d.resolve(dummy)
            zo_callLater(function()
                d.reject(dummy)
            end, 50)
            zo_callLater(done, 100)
        end)
    end)
end)
