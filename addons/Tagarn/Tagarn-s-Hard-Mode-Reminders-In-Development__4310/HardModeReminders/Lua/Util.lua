-- Copyright (c) 2025 by Tagarn

-- This add-on may be copied, shared, and used as-is while playing Elder
-- Scrolls Online, provided this notice is left intact. However, this
-- add-on, in part or in full, may not be used in the creation of other
-- add-ons without the express written consent of Tagarn.

-- The Elder Scrolls Online add-on provided by Tagarn ("we," "us," or "our")
-- is for entertainment purposes only. UNDER NO CIRCUMSTANCE SHALL WE HAVE ANY
-- LIABILITY TO YOU FOR ANY LOSS OR DAMAGE OF ANY KIND INCURRED AS A RESULT OF
-- THE USE OF OUR ADD-ON. YOUR USE OF OUR ADD-ON IS SOLELY AT YOUR OWN RISK.

HardModeRemindersUtilities = {}

local HMRU = HardModeRemindersUtilities

function HMRU.hex_to_bin(hex)
    return (hex:gsub('..', function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

function HMRU.bin_to_hex(bin)
    return (bin:gsub('.', function(c)
        return string.format('%02X', string.byte(c))
    end))
end

-- XOR two bytes (0–255) without bit libraries
local function xor_byte(a, b)
    local result = 0
    local bit = 1

    while a > 0 or b > 0 do
        local abit = a % 2
        local bbit = b % 2

        if abit ~= bbit then
            result = result + bit
        end

        a = (a - abit) / 2
        b = (b - bbit) / 2
        bit = bit * 2
    end

    return result
end

-- XOR an entire string with a single‑byte key
function HMRU.xor(s, key)
    return (s:gsub(".", function(c)
        return string.char(xor_byte(string.byte(c), key))
    end))
end
