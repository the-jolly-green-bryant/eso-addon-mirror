local min = math.min
local floor = math.floor

local BinaryBuffer = {}
BinaryBuffer.__index = BinaryBuffer

function BinaryBuffer.New(tbl)
    local self = setmetatable(tbl or {}, BinaryBuffer)

    self.pointer = 0

    return self
end

function BinaryBuffer:Seek(position)
    self.pointer = position
end

function BinaryBuffer:Skip(length)
    self.pointer = self.pointer + length
end

function BinaryBuffer:Read(length)
    local decimal = 0

    local start = self.pointer + 1
    self.pointer = self.pointer + length
    local stop = min(#self, self.pointer)

    for i = stop, start, -1 do
        decimal = decimal * 2 + self[i]
    end

    return decimal
end

local MBL = {}
do
    for i = 1, 32 do MBL[i] = 2^i - 1 end
end

function BinaryBuffer:Write(decimal, length)
    if MBL[length] < decimal then
        error(('%d cant be written to buffer with length %d'):format(decimal, length))
    end

    local start = self.pointer + 1
    self.pointer = self.pointer + length

    for i = start, self.pointer do
        self[i] = decimal % 2
        decimal = floor(decimal / 2)
    end
end

function BinaryBuffer:WriteBit(bit)
    self.pointer = self.pointer + 1
    self[self.pointer] = bit
end

function BinaryBuffer:WriteBits(bits, length)
    for i = 1, length do
        self[self.pointer+i] = bits[i]
    end

    self.pointer = self.pointer + length
end

function BinaryBuffer:Available()
    return self.pointer <= #self
end

-- ----------------------------------------------------------------------------

LibDataPacker_BinaryBuffer = BinaryBuffer
