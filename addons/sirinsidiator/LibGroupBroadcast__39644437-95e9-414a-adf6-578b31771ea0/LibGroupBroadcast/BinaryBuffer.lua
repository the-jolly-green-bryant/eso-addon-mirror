-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast

--[[ doc.lua begin ]] --

--- @class BinaryBuffer
--- @field protected bytes table<number> The bytes of the buffer.
--- @field protected bitLength number The number of bits in the buffer.
--- @field protected cursor number The current cursor position.
--- @field New fun(self: BinaryBuffer, numBits: number): BinaryBuffer
local BinaryBuffer = ZO_InitializingObject:Subclass()
LGB.internal.class.BinaryBuffer = BinaryBuffer

local function GetIndices(cursor)
    local byteIndex = math.ceil(cursor / 8)
    local bitIndex = 7 - ((cursor - 1) % 8)
    return byteIndex, bitIndex
end

--- Initializes a new BinaryBuffer with the specified number of bits.
--- @protected
--- @param numBits number The number of bits the buffer should have. Has to be a positive number.
function BinaryBuffer:Initialize(numBits)
    assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
    self.bytes = {}
    self.bitLength = numBits
    self:Clear()
end

--- Clears the buffer and sets all bits to 0. The length of the buffer remains the same.
function BinaryBuffer:Clear()
    for i = 1, self:GetByteLength() do
        self.bytes[i] = 0
    end
    self.cursor = 1
end

--- Grows the buffer if the specified number of bits would exceed the current length.
--- @param numBits number The number of bits to grow the buffer by.
function BinaryBuffer:GrowIfNeeded(numBits)
    assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
    local remainingBits = self.bitLength - self.cursor + 1
    if remainingBits >= numBits then return end

    local growBy = numBits - remainingBits
    self.bitLength = self.bitLength + growBy
    local bytes = self.bytes
    for i = #bytes, self:GetByteLength() do
        bytes[i] = bytes[i] or 0
    end
end

--- Getter for the number of bits in the buffer.
--- @return number bitLength The number of bits in the buffer.
function BinaryBuffer:GetNumBits()
    return self.bitLength
end

--- Getter for the number of bytes in the buffer.
--- @return number byteLength The number of bytes in the buffer (rounded up to full bytes).
function BinaryBuffer:GetByteLength()
    return math.ceil(self.bitLength / 8)
end

--- Writes a single bit to the buffer.
--- @param value number|boolean The value to write. Must be 1/0 or true/false.
function BinaryBuffer:WriteBit(value)
    assert(value == 1 or value == 0 or value == true or value == false, "Value must be 1/0 or true/false")
    assert(self.cursor <= self.bitLength, "Attempted to write past end of buffer")
    local byteIndex, bitIndex = GetIndices(self.cursor)

    local byte = self.bytes[byteIndex] or 0
    local mask = BitLShift(1, bitIndex)
    if value == 1 or value == true then
        byte = BitOr(byte, mask)
    else
        byte = BitAnd(byte, BitNot(mask, 8))
    end
    self.bytes[byteIndex] = byte

    self.cursor = self.cursor + 1
end

--- Writes an unsigned integer to the buffer.
--- @param value number The value to write. Must be a non-negative number and fit in the specified number of bits.
--- @param numBits number The number of bits to write. Must be a positive number.
function BinaryBuffer:WriteUInt(value, numBits)
    assert(type(value) == "number" and value >= 0, "Value must be a non-negative number")
    assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
    assert(value < BitLShift(1, numBits), "Value is too large for " .. numBits .. " bits")
    assert(self.cursor + numBits - 1 <= self.bitLength, "Attempted to write past end of buffer")

    local bits = {}
    for i = 1, numBits do
        local bit = BitAnd(BitRShift(value, numBits - i), 1)
        bits[#bits + 1] = bit
        self:WriteBit(bit)
    end
end

--- Writes a string to the buffer.
--- @param value string The value to write. Must be a string.
function BinaryBuffer:WriteString(value)
    assert(type(value) == "string", "Value must be a string")
    assert(self.cursor + #value * 8 - 1 <= self.bitLength, "Attempted to write past end of buffer")
    for i = 1, #value do
        self:WriteUInt(string.byte(value, i), 8)
    end
end

--- Writes another buffer to the buffer. The cursor of the input buffer is modified.
--- @param value BinaryBuffer The buffer to write. Must be a BinaryBuffer.
--- @param numBits? number The number of bits to write from the input buffer. If not specified the entire buffer is written.
--- @param offset? number The offset to start reading from. If not specified the input buffer is read from the start.
function BinaryBuffer:WriteBuffer(value, numBits, offset)
    assert(ZO_Object.IsInstanceOf(value, BinaryBuffer), "buffer must be a BinaryBuffer")
    assert(not numBits or numBits > 0 or numBits <= value.bitLength,
        "numBits must be a positive number less than or equal to the buffer length")
    local bitsToWrite = numBits or value.bitLength
    offset = offset or 1
    assert(offset + bitsToWrite - 1 <= value.bitLength, "Attempted to write more bits than are available")
    assert(self.cursor + bitsToWrite - 1 <= self.bitLength, "Attempted to write past end of buffer")
    value:Rewind(offset)
    for _ = 1, bitsToWrite do
        self:WriteBit(value:ReadBit())
    end
end

--- Reads a single bit from the buffer.
--- @param asBoolean? boolean Whether to return the value as a boolean. If not specified, the value is returned as a number.
--- @return number|boolean value The read value. If asBoolean is true, the value is a boolean.
function BinaryBuffer:ReadBit(asBoolean)
    assert(self.cursor <= self.bitLength, "Attempt to read past end of buffer")

    local byteIndex, bitIndex = GetIndices(self.cursor)
    local byte = self.bytes[byteIndex] or 0
    local value = BitAnd(BitRShift(byte, bitIndex), 1)

    self.cursor = self.cursor + 1
    if asBoolean then
        return value == 1
    end
    return value
end

--- Reads an unsigned integer from the buffer.
--- @param numBits number The number of bits to read. Must be a positive number.
--- @return number value The read value.
function BinaryBuffer:ReadUInt(numBits)
    assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
    assert(self.cursor + numBits - 1 <= self.bitLength, "Attempt to read past end of buffer")

    local value = 0
    for i = 1, numBits do
        value = BitOr(value, BitLShift(self:ReadBit() --[[@as number]], numBits - i))
    end
    return value
end

--- Reads a string from the buffer.
--- @param byteLength number The number of bytes to read. Must be a positive number.
--- @return string value The read value.
function BinaryBuffer:ReadString(byteLength)
    assert(type(byteLength) == "number" and byteLength > 0, "byteLength must be a positive number")
    assert(self.cursor + byteLength * 8 - 1 <= self.bitLength, "Attempt to read past end of buffer")

    local result = {}
    for i = 1, byteLength do
        table.insert(result, string.char(self:ReadUInt(8)))
    end
    return table.concat(result)
end

--- Reads a number of bits from the buffer and returns them as a new buffer.
--- @param numBits number The number of bits to read from the buffer.
--- @return BinaryBuffer value The new buffer.
function BinaryBuffer:ReadBuffer(numBits)
    assert(type(numBits) == "number" and numBits > 0, "numBits must be a positive number")
    assert(self.cursor + numBits - 1 <= self.bitLength, "Attempt to read past end of buffer")

    local result = BinaryBuffer:New(numBits)
    for _ = 1, numBits do
        result:WriteBit(self:ReadBit())
    end
    result:Rewind()
    return result
end

--- Seeks the cursor by the specified number of bits.
--- @param numBits number The number of bits to seek. Must be a positive number.
function BinaryBuffer:Seek(numBits)
    assert(self.cursor + numBits - 1 <= self.bitLength, "Attempt to seek past end of buffer")
    self.cursor = self.cursor + numBits
end

--- Rewinds the cursor to the specified position (starting at 1).
--- @param cursor? number The position to rewind to. If not specified, the cursor is rewound to the start of the buffer.
function BinaryBuffer:Rewind(cursor)
    if cursor then
        assert(type(cursor) == "number" and cursor >= 1 and cursor <= self.bitLength,
            "cursor must be a number between 1 and the buffer length")
        self.cursor = cursor
    else
        self.cursor = 1
    end
end

--- Returns the buffer as a hexadecimal string.
--- @return string hexString The buffer as a hexadecimal string.
function BinaryBuffer:ToHexString()
    local result = {}
    for i = 1, #self.bytes do
        result[#result + 1] = string.format("%02X", self.bytes[i])
    end
    return table.concat(result, " ")
end

--- Creates a new BinaryBuffer from a hexadecimal string.
--- @param hexString string The hexadecimal string to create the buffer from.
--- @return BinaryBuffer value The new buffer.
function BinaryBuffer.FromHexString(hexString)
    local bytes = {}
    for byte in hexString:gmatch("%x%x") do
        bytes[#bytes + 1] = tonumber(byte, 16)
    end

    local result = BinaryBuffer:New(#bytes * 8)
    result.bytes = bytes
    return result
end

--- Returns the buffer as a table of unsigned 32-bit integers for use with the broadcast api.
--- @return table<number> result The buffer as a table of unsigned 32-bit integers.
function BinaryBuffer:ToUInt32Array()
    local uint32Count = math.ceil(#self.bytes / 4)
    local result = {}
    for i = 1, uint32Count do
        local byte1 = self.bytes[i * 4 - 3] or 0
        local byte2 = self.bytes[i * 4 - 2] or 0
        local byte3 = self.bytes[i * 4 - 1] or 0
        local byte4 = self.bytes[i * 4] or 0

        local value = BitLShift(byte1, 24)
        value = BitOr(value, BitLShift(byte2, 16))
        value = BitOr(value, BitLShift(byte3, 8))
        value = BitOr(value, byte4)
        result[#result + 1] = value
    end
    return result
end

--- Creates a new BinaryBuffer from unsigned 32-bit integers, as passed by the broadcast api.
--- @param numBits number The number of bits the buffer should have. Must be a positive number.
--- @param ... number The values to create the buffer from. Must match the specified number of bits.
--- @return BinaryBuffer value The new buffer.
function BinaryBuffer.FromUInt32Values(numBits, ...)
    local length = math.ceil(numBits / 32)
    assert(select("#", ...) == length, "Incorrect number of values")

    local result = BinaryBuffer:New(numBits)
    for i = 1, length do
        local value = select(i, ...)
        local offset = (i - 1) * 4
        result.bytes[offset + 1] = BitAnd(BitRShift(value, 24), 0xFF)
        result.bytes[offset + 2] = BitAnd(BitRShift(value, 16), 0xFF)
        result.bytes[offset + 3] = BitAnd(BitRShift(value, 8), 0xFF)
        result.bytes[offset + 4] = BitAnd(value, 0xFF)
    end

    -- clean up surplus bytes
    local numBytes = result:GetByteLength()
    for i = numBytes + 1, #result.bytes do
        result.bytes[i] = nil
    end

    if numBits % 8 > 0 then -- surplus bits too
        local mask = BitLShift(1, numBits % 8) - 1
        result.bytes[numBytes] = BitAnd(result.bytes[numBytes], mask)
    end

    return result
end
