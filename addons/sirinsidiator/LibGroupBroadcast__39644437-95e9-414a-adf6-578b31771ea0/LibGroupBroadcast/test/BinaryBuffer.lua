-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local BinaryBuffer = LGB.internal.class.BinaryBuffer

Taneth("LibGroupBroadcast", function()
    describe("BinaryBuffer", function()
        it("should be able to create a new instance", function()
            local buffer = BinaryBuffer:New(1)
            assert.is_true(ZO_Object.IsInstanceOf(buffer, BinaryBuffer))
        end)

        it("should be able to write and read a bit", function()
            local buffer = BinaryBuffer:New(1)
            buffer:WriteBit(1)

            buffer:Rewind()
            assert.equals(1, buffer:ReadBit())
        end)

        it("should be able to write and read a byte", function()
            local buffer = BinaryBuffer:New(8)
            buffer:WriteUInt(0xFF, 8)

            buffer:Rewind()
            assert.equals(0xFF, buffer:ReadUInt(8))
        end)

        it("should be able to write and read a string", function()
            local buffer = BinaryBuffer:New(8 * 3)
            buffer:WriteString("abc")

            buffer:Rewind()
            assert.equals("abc", buffer:ReadString(3))
        end)

        it("should be able to write and read a buffer", function()
            local bufferA = BinaryBuffer:New(8 * 3)
            bufferA:WriteString("abc")

            local bufferB = BinaryBuffer:New(8 * 3)
            bufferB:WriteBuffer(bufferA)

            bufferB:Rewind()
            local bufferC = bufferB:ReadBuffer(8 * 3)

            bufferC:Rewind()
            assert.equals("abc", bufferC:ReadString(3))
        end)

        it("should be able to convert to and from a uint32 array", function()
            local input = "abcdefghij"
            local bufferA = BinaryBuffer:New(8 * #input)
            bufferA:WriteString(input)
            local uint32Array = bufferA:ToUInt32Array()
            assert.equals(3, #uint32Array)
            assert.equals(0x61626364, uint32Array[1])
            assert.equals(0x65666768, uint32Array[2])
            assert.equals(0x696A0000, uint32Array[3])

            local bufferB = BinaryBuffer.FromUInt32Values(8 * #input, unpack(uint32Array))
            assert.equals(input, bufferB:ReadString(10))
        end)

        it("should be able to convert to a hex string", function()
            local buffer = BinaryBuffer:New(8 * 3)
            buffer:WriteString("abc")

            assert.equals("61 62 63", buffer:ToHexString())
        end)
    end)
end)
