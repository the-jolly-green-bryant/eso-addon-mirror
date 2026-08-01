-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

--- @class LibGroupBroadcast
local LGB = LibGroupBroadcast
local FieldBase = LGB.internal.class.FieldBase
local NumericField = LGB.internal.class.NumericField
local ArrayField = LGB.internal.class.ArrayField
local EnumField = LGB.internal.class.EnumField
local logger = LGB.internal.logger

local AVAILABLE_OPTIONS = {
    characters = true,
    minLength = true,
    maxLength = true,
}

--[[ doc.lua begin ]] --

--- @docType options
--- @class StringFieldOptions: FieldOptionsBase
--- @field characters string? The characters to use for the string. If not provided, the string will be treated as a sequence of bytes.
--- @field minLength number? The minimum length of the string. Defaults to 0.
--- @field maxLength number? The maximum length of the string. Defaults to 255.
--- @field defaultValue string? The default value for the field.

--- @docType hidden
--- @class StringField: FieldBase
--- @field protected arrayField ArrayField
--- @field New fun(self: StringField, label: string, options?: StringFieldOptions): StringField
local StringField = FieldBase:Subclass()
LGB.internal.class.StringField = StringField

--[[ doc.lua end ]] --
-- as of v10.3.2 utf8.char still crashes the game, so we use this code ported from the utf8lib in Lua5.3 instead
local UTF8BUFFSZ = 8
local buff = {}
for i = 1, UTF8BUFFSZ do buff[i] = 0 end
local function utf8esc(x)
    local n = 1
    assert(x >= 0 and x <= 0x10FFFF, "Invalid codepoint")
    if x < 0x80 then
        buff[UTF8BUFFSZ - 1] = x
    else
        local mfb = 0x3F
        repeat
            buff[UTF8BUFFSZ - n] = BitAnd(0xFF, BitOr(0x80, BitAnd(x, 0x3F)))
            n = n + 1
            x = BitRShift(x, 6)
            mfb = BitRShift(mfb, 1)
        until x <= mfb
        buff[UTF8BUFFSZ - n] = BitAnd(0xFF, BitOr(BitLShift(BitNot(mfb, 8), 1), x))
    end
    return string.char(unpack(buff, UTF8BUFFSZ - n, UTF8BUFFSZ - 1))
end
--[[ doc.lua begin ]] --

--- @protected
function StringField:Initialize(label, options)
    self:RegisterAvailableOptions(AVAILABLE_OPTIONS)
    FieldBase.Initialize(self, label, options)
    options = self.options --[[@as StringFieldOptions]]

    local charField
    if options.characters then
        local characters = options.characters
        if not self:Assert(type(characters) == "string", "characters must be a string") then return end
        local codepoints = { utf8.codepoint(characters, 1, #characters) }
        charField = EnumField:New(label, codepoints)
    else
        charField = NumericField:New(label, { numBits = 8 })
    end
    self.arrayField = self:RegisterSubField(ArrayField:New(charField, {
        minLength = options.minLength,
        maxLength = options.maxLength,
    }))

    if options.defaultValue then
        self:Assert(type(options.defaultValue) == "string", "defaultValue must be a string")
    end
end

--- @protected
function StringField:GetNumBitsRangeInternal()
    return self.arrayField:GetNumBitsRange()
end

--- Picks the value from the input table based on the label and serializes it to the data stream.
--- @param data BinaryBuffer The data stream to write to.
--- @param input table The input table to pick a value from.
--- @return boolean success Whether the value was successfully serialized.
function StringField:Serialize(data, input)
    local value = self:GetInputOrDefaultValue(input)
    if type(value) ~= "string" then
        logger:Warn("value must be a string")
        return false
    end

    local parts
    if self.options.characters then
        parts = { utf8.codepoint(value, 1, #value) }
    else
        parts = { string.byte(value, 1, #value) }
    end
    return self.arrayField:Serialize(data, { [self.label] = parts })
end

--- Deserializes the value from the data stream, optionally storing it in a table.
--- @param data BinaryBuffer The data stream to read from.
--- @param output? table An optional table to store the deserialized value in with the label of the field as key.
--- @return string value The deserialized value.
function StringField:Deserialize(data, output)
    local value = ""
    local parts = self.arrayField:Deserialize(data)
    if #parts > 0 then
        if self.options.characters then
            for i = 1, #parts do
                parts[i] = utf8esc(parts[i])
            end
            value = table.concat(parts)
            -- TODO simplify, once the utf8.char function no longer crashes the game
            -- value = utf8.char(unpack(parts))
        else
            value = string.char(unpack(parts))
        end
    end
    if output then output[self.label] = value end
    return value
end
