local C = Conductor
C.SessionSerializer = C.SessionSerializer or {}
local Serializer = C.SessionSerializer

local ENTRY_SEP = ";"
local VALUE_SEP = "^"
local ESCAPE_MAP = { ["%"] = "%25", [";"] = "%3B", ["^"] = "%5E", ["="] = "%3D", ["."] = "%2E" }

local function Escape(value)
    return (tostring(value or ""):gsub("[%%;^=.]", ESCAPE_MAP))
end

local function Unescape(value)
    return tostring(value or ""):gsub("%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

local function Split(text, separator)
    local result, start = {}, 1
    text = tostring(text or "")
    while true do
        local pos = string.find(text, separator, start, true)
        if not pos then
            result[#result + 1] = string.sub(text, start)
            break
        end
        result[#result + 1] = string.sub(text, start, pos - 1)
        start = pos + #separator
    end
    return result
end

local function TypeCode(value)
    local valueType = type(value)
    if valueType == "number" then return "N" end
    if valueType == "boolean" then return "B" end
    return "S"
end

local function DecodeValue(typeCode, value)
    value = Unescape(value)
    if typeCode == "N" then return tonumber(value) or 0 end
    if typeCode == "B" then return value == "1" end
    if typeCode == "T" then return {} end
    return value
end

local function Flatten(value, path, output)
    if type(value) ~= "table" then
        local encoded = value
        if type(value) == "boolean" then encoded = value and "1" or "0" end
        output[#output + 1] = table.concat({ Escape(path), TypeCode(value), Escape(encoded) }, VALUE_SEP)
        return
    end
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    if #keys == 0 then
        output[#output + 1] = table.concat({ Escape(path), "T", "" }, VALUE_SEP)
        return
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    for _, key in ipairs(keys) do
        local childPath = path == "" and tostring(key) or (path .. "." .. tostring(key))
        Flatten(value[key], childPath, output)
    end
end

local function AssignPath(root, encodedPath, typeCode, encodedValue)
    local parts = Split(Unescape(encodedPath), ".")
    local current = root
    for index = 1, #parts - 1 do
        local key = tonumber(parts[index]) or parts[index]
        if type(current[key]) ~= "table" then current[key] = {} end
        current = current[key]
    end
    local key = tonumber(parts[#parts]) or parts[#parts]
    current[key] = DecodeValue(typeCode, encodedValue)
end

function Serializer:Encode(value)
    if type(value) ~= "table" then return nil, "snapshot must be a table" end
    local entries = {}
    Flatten(value, "", entries)
    return table.concat(entries, ENTRY_SEP)
end

function Serializer:Decode(body)
    if type(body) ~= "string" or body == "" then return nil, "serialized snapshot is empty" end
    local output = {}
    for _, entry in ipairs(Split(body, ENTRY_SEP)) do
        local values = Split(entry, VALUE_SEP)
        if #values < 3 or values[1] == "" then return nil, "serialized snapshot contains an invalid entry" end
        AssignPath(output, values[1], values[2], values[3])
    end
    return output
end

-- Adler-32 is sufficient here because LibGroupBroadcast already protects its
-- individual frames. This checksum verifies the reconstructed application payload.
function Serializer:Checksum(value)
    local a, b = 1, 0
    for index = 1, #value do
        a = (a + string.byte(value, index)) % 65521
        b = (b + a) % 65521
    end
    return b * 65536 + a
end

function Serializer:RoundTrip(value)
    local encoded, encodeError = self:Encode(value)
    if not encoded then return nil, encodeError end
    local decoded, decodeError = self:Decode(encoded)
    if not decoded then return nil, decodeError end
    return decoded, encoded
end
