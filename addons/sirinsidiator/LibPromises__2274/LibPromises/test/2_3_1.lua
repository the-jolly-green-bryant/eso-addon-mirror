-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end

Taneth("LibPromises", function()
    local resolved = LibPromiseTest.resolved
    local rejected = LibPromiseTest.rejected

    local dummy = { dummy = "dummy" } -- we fulfill or reject with this when we don't intend to test against it

    describe("2.3.1: If `promise` and `x` refer to the same object, reject `promise` with a `TypeError' as the reason.",
        function()
            it.async("via return from a fulfilled promise", function(done)
                local promise
                promise = resolved(dummy):Then(function()
                    return promise
                end)

                promise:Then(nil, function(reason)
                    assert.equals(reason, "TypeError: Tried to pass promise to itself")
                    done()
                end)
            end)

            it.async("via return from a rejected promise", function(done)
                local promise
                promise = rejected(dummy):Then(nil, function()
                    return promise
                end)

                promise:Then(nil, function(reason)
                    assert.equals(reason, "TypeError: Tried to pass promise to itself")
                    done()
                end)
            end)
        end)
end)
