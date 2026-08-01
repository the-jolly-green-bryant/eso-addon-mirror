-- busted BitSetTest.lua

require "BitSet"
local BitSet = LibBitSetBitSet

describe("BitSet", function()

    it("should create a new BitSet", function()
        local bitset = BitSet.New()
        assert.are.same(0, bitset.maxBlockIndex)
        assert.are.same({}, bitset.blocks)
    end)

    it("should set and get bits correctly", function()
        local bitset = BitSet.New()

        bitset:SetBit(1)
        assert.are.equal(1, bitset:GetBit(1))

        assert.are.equal(0, bitset:GetBit(2))
        assert.are.equal(0, bitset:GetBit(53))
    end)

    it("should clear bits correctly", function()
        local bitset = BitSet.New()

        local bitIndex = 60

        bitset:SetBit(bitIndex)
        assert.are.equal(1, bitset:GetBit(bitIndex))

        bitset:ClearBit(bitIndex)
        assert.are.equal(0, bitset:GetBit(bitIndex))
    end)

    it("should toggle bits correctly", function()
        local bitset = BitSet.New()

        local bitIndex = 60

        bitset:ToggleBit(bitIndex)
        assert.are.equal(1, bitset:GetBit(bitIndex))

        bitset:ToggleBit(bitIndex)
        assert.are.equal(0, bitset:GetBit(bitIndex))
    end)

    it("should count set bits correctly", function()
        local bitset = BitSet.New()

        bitset:SetBit(1)
        bitset:SetBit(10)
        bitset:SetBit(60)

        assert.are.equal(3, bitset:CountSetBits())
    end)

    it("should perform bitwise OR correctly", function()
        local bitset1 = BitSet.New()
        local bitset2 = BitSet.New()

        bitset1:SetBit(1)
        bitset2:SetBit(60)

        local result = bitset1:BitwiseOr(bitset2)

        assert.are.equal(1, result:GetBit(1))
        assert.are.equal(1, result:GetBit(60))
    end)

    it("should perform bitwise AND correctly", function()
        local bitset1 = BitSet.New()
        local bitset2 = BitSet.New()

        bitset1:SetBit(1)
        bitset1:SetBit(60)
        bitset2:SetBit(60)

        local result = bitset1:BitwiseAnd(bitset2)

        assert.are.equal(0, result:GetBit(1))
        assert.are.equal(1, result:GetBit(60))
    end)

    it("should perform bitwise NOT correctly", function()
        local bitset = BitSet.New()

        bitset:SetBit(1)
        bitset:SetBit(60)

        local result = bitset:BitwiseNot(60)

        assert.are.equal(0, result:GetBit(1))
        assert.are.equal(1, result:GetBit(2))
        assert.are.equal(1, result:GetBit(59))
        assert.are.equal(0, result:GetBit(60))
    end)

    it("should convert to string correctly", function()
        local bitset = BitSet.New()

        bitset:SetBit(1)
        bitset:SetBit(3)
        bitset:SetBit(60)

        assert.are.equal("0000100000000000000000000000000000000000000000000000000000000101", bitset:ToString(64))
    end)

    it("should iterate over set bits", function()
        local bitset = BitSet.New()

        bitset:SetBit(1)
        bitset:SetBit(3)
        bitset:SetBit(60)

        local indices = {}
        for index, bitValue in LibBitSetIterator(bitset, 1) do
            table.insert(indices, index)
        end

        assert.are.same({ 1, 3, 60 }, indices)
    end)
end)
