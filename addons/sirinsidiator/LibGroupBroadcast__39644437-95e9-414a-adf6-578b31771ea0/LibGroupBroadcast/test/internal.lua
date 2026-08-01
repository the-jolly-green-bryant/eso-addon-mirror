-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local CalculateCRC3ROHC = LGB.internal.CalculateCRC3ROHC

Taneth("LibGroupBroadcast", function()
    describe("checksum", function()
        it("should match the original implementation", function()
            local input = "123456789"
            local fakeBuffer = { bytes = {} }
            for i = 1, #input do
                table.insert(fakeBuffer.bytes, string.byte(input, i, i))
            end
            local expected = 6
            local actual = CalculateCRC3ROHC(fakeBuffer)
            assert.equals(expected, actual)
        end)

        it("should be able to correctly handle a 32 byte input", function()
            local fakeBuffer = { bytes = {} }
            for _ = 1, 32 do
                table.insert(fakeBuffer.bytes, 0)
            end
            local expected = 1
            local actual = CalculateCRC3ROHC(fakeBuffer)
            assert.equals(expected, actual)
        end)
    end)
end)
