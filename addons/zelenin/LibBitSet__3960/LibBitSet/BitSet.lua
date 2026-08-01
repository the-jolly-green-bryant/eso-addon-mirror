local BitSet = {}
BitSet.__index = BitSet
LibBitSetBitSet = BitSet

local size = 53
if type(GetESOVersionString) ~= "function" then
    size = 32
    local bit = require("bit")
    BitOr = bit.bor
    BitAnd = bit.band
    BitXor = bit.bxor
    BitLShift = bit.lshift
    BitRShift = bit.rshift
    BitNot = bit.bnot
end

local function getBlockIndexAndBitIndex(index)
    local blockIndex = math.floor((index - 1) / size) + 1
    local bitIndex = (index - 1) % size
    return blockIndex, bitIndex
end

function BitSet.New()
    local self = setmetatable({}, BitSet)
    self.maxBlockIndex = 0
    self.blocks = {}
    return self
end

function BitSet:SetBit(index)
    local blockIndex, bitIndex = getBlockIndexAndBitIndex(index)

    if not self.blocks[blockIndex] then
        self.blocks[blockIndex] = 0
        if blockIndex > self.maxBlockIndex then
            self.maxBlockIndex = blockIndex
        end
    end

    self.blocks[blockIndex] = BitOr(self.blocks[blockIndex], BitLShift(1, bitIndex))
end

function BitSet:ClearBit(index)
    local blockIndex, bitIndex = getBlockIndexAndBitIndex(index)

    if not self.blocks[blockIndex] then
        return
    end

    self.blocks[blockIndex] = BitAnd(self.blocks[blockIndex], BitNot(BitLShift(1, bitIndex), size))
end

function BitSet:ToggleBit(index)
    local blockIndex, bitIndex = getBlockIndexAndBitIndex(index)

    if not self.blocks[blockIndex] then
        self.blocks[blockIndex] = 0
        if blockIndex > self.maxBlockIndex then
            self.maxBlockIndex = blockIndex
        end
    end

    self.blocks[blockIndex] = BitXor(self.blocks[blockIndex], BitLShift(1, bitIndex))
end

function BitSet:GetBit(index)
    local blockIndex, bitIndex = getBlockIndexAndBitIndex(index)

    if not self.blocks[blockIndex] then
        return 0
    end

    return BitAnd(BitRShift(self.blocks[blockIndex], bitIndex), 1)
end

function BitSet:BitwiseOr(other)
    local result = BitSet.New()
    local maxBlocks = math.max(self.maxBlockIndex, other.maxBlockIndex)

    for i = 1, maxBlocks do
        local a = self.blocks[i] or 0
        local b = other.blocks[i] or 0
        result.blocks[i] = BitOr(a, b)
    end
    result.maxBlockIndex = maxBlocks

    return result
end

function BitSet:BitwiseAnd(other)
    local result = BitSet.New()
    local maxBlocks = math.max(self.maxBlockIndex, other.maxBlockIndex)

    for i = 1, maxBlocks do
        local a = self.blocks[i] or 0
        local b = other.blocks[i] or 0
        result.blocks[i] = BitAnd(a, b)
    end
    result.maxBlockIndex = maxBlocks

    return result
end

function BitSet:BitwiseNot(maxIndex)
    local result = BitSet.New()
    local maxBlocks = math.ceil(maxIndex / size)

    for i = 1, maxBlocks do
        local a = self.blocks[i] or 0
        result.blocks[i] = BitNot(a, size)
    end
    result.maxBlockIndex = maxBlocks

    return result
end

function BitSet:ToString(maxIndex)
    local str = ""
    maxIndex = maxIndex or self.maxBlockIndex * size

    for i = maxIndex, 1, -1 do
        str = str .. self:GetBit(i)
    end

    return str
end

function BitSet:CountSetBits()
    local count = 0
    for i = 1, self.maxBlockIndex do
        local block = self.blocks[i] or 0
        while block ~= 0 do
            block = BitAnd(block, block - 1)
            count = count + 1
        end
    end

    return count
end

function LibBitSetIterator(bitset, bitValue)
    local blockIndex = 1
    local bitIndex = 0

    return function()
        while blockIndex <= bitset.maxBlockIndex do
            local block = bitset.blocks[blockIndex] or 0

            while bitIndex < size do
                bitIndex = bitIndex + 1
                local bitInBlock = BitAnd(BitRShift(block, bitIndex - 1), 1)

                if bitValue == nil or (bitValue ~= nil and bitInBlock == bitValue) then
                    return (blockIndex - 1) * size + bitIndex, bitInBlock
                end
            end

            blockIndex = blockIndex + 1
            bitIndex = 0
        end

        return nil
    end
end

function LibBitSetLoad(bitset, table)
    if table.maxBlockIndex and table.blocks then
        bitset.maxBlockIndex = table.maxBlockIndex
        bitset.blocks = table.blocks
    end
    return bitset
end
