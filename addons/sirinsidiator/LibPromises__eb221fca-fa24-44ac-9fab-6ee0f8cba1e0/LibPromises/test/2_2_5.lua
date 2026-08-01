-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local resolved = LibPromiseTest.resolved
    local rejected = LibPromiseTest.rejected
    local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

    describe("2.2.5 `onFulfilled` and `onRejected` must be called as functions (i.e. with no `this` value).", function()
        it.async("fulfilled", function(done)
            resolved(dummy):Then(function(...)
                -- Lua does not have an equivalent for this test, so we just check if the argument count is 1 instead
                assert.equals(select("#", ...), 1)
                done()
            end)
        end)

        it.async("rejected", function(done)
            rejected(dummy):Then(nil, function(...)
                -- Lua does not have an equivalent for this test, so we just check if the argument count is 1 instead
                assert.equals(select("#", ...), 1)
                done()
            end)
        end)
    end)
end)
