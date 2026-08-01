-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcastInternal
local internal = LibGroupBroadcast.internal
do
    -- CRC-3/ROHC calculation based on https://github.com/emn178/js-crc/

    local function reverse(val, width)
        local result = 0
        for i = 0, val - 1 do
            if BitAnd(val, 1) == 1 then
                result = BitOr(result, BitLShift(1, width - 1 - i))
            end
            val = BitRShift(val, 1)
        end
        return result
    end

    local REVERSE_BYTE = {}
    for i = 0, 255 do
        REVERSE_BYTE[i] = reverse(i, 8);
    end

    local function createTable(poly, msbOffset, msb)
        local table = {}
        for i = 0, 255 do
            local byte = BitLShift(i, msbOffset)
            for _ = 0, 7 do
                if BitAnd(byte, msb) ~= 0 then
                    byte = BitXor(BitLShift(byte, 1), poly)
                else
                    byte = BitLShift(byte, 1)
                end
            end
            table[i] = byte
        end
        return table
    end

    local function moduloWithWrap(a, b)
        local value = a % b
        if value == 0 then
            return b
        end
        return value
    end

    local width = 3
    local poly = 0x3
    local init = 0x7
    local mask = 0x7
    local xorout = 0x0
    local bitOffset = 8 - moduloWithWrap(width, 8)
    local firstBlockBytes = moduloWithWrap(math.ceil(width / 8), 4)
    local firstBlockBits = BitLShift(firstBlockBytes, 3)
    local msb = BitAnd(BitLShift(1, (firstBlockBits - 1)), 0xFF)
    local msbOffset = firstBlockBits - 8;
    init = BitLShift(init, bitOffset)
    poly = BitLShift(poly, bitOffset)
    local table = createTable(poly, msbOffset, msb)

    function internal.CalculateCRC3ROHC(data)
        local crc = init
        for i = 1, #data.bytes do
            local byte = REVERSE_BYTE[data.bytes[i]]
            crc = BitXor(crc, BitLShift(byte, msbOffset))
            crc = BitXor(BitAnd(BitLShift(crc, 8), 0xFFFFFFFF), table[BitAnd(BitRShift(crc, msbOffset), 0xFF)])
        end

        crc = BitAnd(BitRShift(crc, bitOffset), mask)
        crc = reverse(crc, width)
        crc = BitXor(crc, xorout)
        return crc
    end
end
