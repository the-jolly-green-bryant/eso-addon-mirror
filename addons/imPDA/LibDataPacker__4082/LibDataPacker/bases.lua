-- local Log = LibDataPacker_Logger()
local BinaryBuffer = LibDataPacker_BinaryBuffer
local floor = math.floor
local log = math.log
local char = string.char
local concat = table.concat

-- ----------------------------------------------------------------------------

--- @class Base
--- @field __index Base
--- @field alphabet table The alphabet to use
--- @field alphabet1 table The alphabet to use in decoding with shifted index
--- @field encodeTable table Encode table based on alphabet 
--- @field lookupTable table Lookup table based on alphabet 
--- @field bitLength integer Bit length of one charater from the alphabet
local Base = {}
Base.__index = Base

function Base.FromAlphabet(alphabet)
    local concreteBase = setmetatable({}, Base)

    local bitLength = floor(log(#alphabet+1) / log(2))
    local alphabetArray = { alphabet:byte(1, #alphabet) }

    local lookupTable = {}
    for i = 1, #alphabetArray do
        lookupTable[alphabetArray[i]] = i - 1
    end

    concreteBase.bitLength = bitLength
    concreteBase.alphabet = alphabetArray
    concreteBase.lookupTable = lookupTable

    local alphabet1 = {}
    for i = 0, #alphabetArray-1 do
        alphabet1[i] = alphabetArray[i+1]
    end
    concreteBase.alphabet1 = alphabet1

    return concreteBase
end

function Base:Encode(binaryBuffer)
    local tempTable = {}
    binaryBuffer:Seek(0)

    local alphabet1 = self.alphabet1

    for i = 1, #binaryBuffer do
        tempTable[i] = alphabet1[binaryBuffer[i]]
    end

    return char(unpack(tempTable))
end

function Base:Decode(encodedString)
    local lookupTable = self.lookupTable

    local charsArray = { encodedString:byte(1, #encodedString) }
    for i = 1, #charsArray do
        charsArray[i] = lookupTable[charsArray[i]]
    end

    return BinaryBuffer.New(charsArray, self.bitLength)
end

-- ----------------------------------------------------------------------------

local Base64RCF4648 = Base.FromAlphabet('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/')
local Base64LinkSafe = Base.FromAlphabet('23456789CFGHJMPQRVWXcfghjmpqrvwx01bBdDkKlLsStT!@#&=_{};,<>`~-]*/')

-- ----------------------------------------------------------------------------

-- local Base256LibBinaryEncode = LBE and {
--     Encode = LBE.Encode,
--     Decode = LBE.DecodeToString,
-- } or {
--     __index = error('LibBinaryEncode is missing!')
-- }

-- ----------------------------------------------------------------------------
----[[
--- @class PrimitiveBase
--- @field __index PrimitiveBase
--- @field bitLength integer Bit length of one character
local PrimitiveBase = {
    bitLength = 8,
}
PrimitiveBase.__index = PrimitiveBase

--- @param binaryBuffer table BinaryBuffer instance with chunkSize = 8
--- @return string Raw string where each byte corresponds to buffer[i]
function PrimitiveBase:Encode(binaryBuffer)
    binaryBuffer:Seek(0)
    return char(unpack(binaryBuffer))
end

--- Decodes a raw binary string into a BinaryBuffer with chunkSize = 8.
--- @param rawString string String of bytes (any valid Lua string)
--- @return table BinaryBuffer instance containing the byte values
function PrimitiveBase:Decode(rawString)
    local bytes = { rawString:byte(1, #rawString) }  -- table of 0..255
    return BinaryBuffer.New(bytes, 8)                -- 8 bits per chunk
end

-- function PrimitiveBase.New(bitLength)
--     local concreteBase = setmetatable({}, PrimitiveBase)

--     concreteBase.bitLength = bitLength

--     return concreteBase
-- end

-- function PrimitiveBase:Encode(binaryString)
--     local encodedString = ''

--     local startIndex, dec, character
--     for i = #binaryString, 1, -self.bitLength do
--         startIndex = i - self.bitLength + 1
--         startIndex = startIndex > 1 and startIndex or 1
--         dec = binaryStringToDecimal(binaryString:sub(startIndex, i)) + 32
--         encodedString = encodedString .. char(dec)
--     end

--     return encodedString
-- end

-- function PrimitiveBase:Decode(encodedString)
--     local binaryString = ''

--     local bytes = { encodedString:byte(1, #encodedString) }

--     for _, byte in ipairs(bytes) do
--         byte = byte - 32
-- 		binaryString = decimalToBinaryString(byte, self.bitLength) .. binaryString
-- 	end

--     return binaryString
-- end
--]]

-- local Base128Primitive = PrimitiveBase.New(7)
-- local Base256Primitive = PrimitiveBase.New(8)

-- ----------------------------------------------------------------------------

local LDP = LibDataPacker

LDP.Base = {
    CustomAlphabet = Base.FromAlphabet,
    Base64RCF4648 = Base64RCF4648,
    Base64LinkSafe = Base64LinkSafe,
    -- Base256LibBinaryEncode = Base256LibBinaryEncode,
    -- Base128Primitive = Base128Primitive,
    -- Base256Primitive = Base256Primitive,
    Primitive = PrimitiveBase,
}
