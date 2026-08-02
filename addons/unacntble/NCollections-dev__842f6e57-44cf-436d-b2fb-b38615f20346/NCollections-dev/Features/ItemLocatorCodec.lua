NCollections = NCollections or {}

local Codec = {}
NCollections.ItemLocatorCodec = Codec

local ALPHABET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-_"
local DECODE = {}

for index = 1, #ALPHABET do
    DECODE[string.byte(ALPHABET, index)] = index - 1
end

local function Clear(values)
    for key in pairs(values) do
        values[key] = nil
    end
end

local function AppendUnsigned(buffer, value)
    value = math.floor(tonumber(value) or 0)
    if value < 0 then return false end

    repeat
        local digit = value % 32
        value = math.floor(value / 32)
        if value > 0 then digit = digit + 32 end
        buffer[#buffer + 1] = string.sub(ALPHABET, digit + 1, digit + 1)
    until value == 0
    return true
end

local function ReadUnsigned(encoded, offset)
    local value = 0
    local multiplier = 1
    local length = #encoded
    local digits = 0

    while offset <= length do
        local digit = DECODE[string.byte(encoded, offset)]
        if digit == nil then return nil, offset end
        offset = offset + 1
        digits = digits + 1
        if digits > 11 then return nil, offset end

        local continued = digit >= 32
        if continued then digit = digit - 32 end
        value = value + (digit * multiplier)
        if not continued then return value, offset end
        multiplier = multiplier * 32
    end

    return nil, offset
end

local function EncodeSigned(value)
    value = math.floor(tonumber(value) or 0)
    if value < 0 then return (-value * 2) - 1 end
    return value * 2
end

local function DecodeSigned(value)
    if value % 2 == 1 then return -math.floor((value + 1) / 2) end
    return math.floor(value / 2)
end

function Codec.EncodeCounts(counts, buffer, ids)
    buffer = buffer or {}
    ids = ids or {}
    Clear(buffer)
    Clear(ids)

    for catalogId, count in pairs(counts or {}) do
        local normalizedId = tonumber(catalogId)
        local normalizedCount = tonumber(count)
        if normalizedId and normalizedId > 0 and normalizedCount and normalizedCount > 0 then
            ids[#ids + 1] = math.floor(normalizedId)
        end
    end
    table.sort(ids)

    local previousId = 0
    for index = 1, #ids do
        local catalogId = ids[index]
        AppendUnsigned(buffer, catalogId - previousId)
        AppendUnsigned(buffer, math.floor(counts[catalogId]))
        previousId = catalogId
    end

    return table.concat(buffer)
end

function Codec.DecodeCounts(encoded, output)
    output = output or {}
    Clear(output)
    if encoded == nil or encoded == "" then return output end
    if type(encoded) ~= "string" then return nil, "not-string" end

    local offset = 1
    local previousId = 0
    while offset <= #encoded do
        local delta
        delta, offset = ReadUnsigned(encoded, offset)
        if not delta or delta <= 0 then return nil, "invalid-id" end

        local count
        count, offset = ReadUnsigned(encoded, offset)
        if not count or count <= 0 then return nil, "invalid-count" end

        local catalogId = previousId + delta
        if catalogId <= previousId then return nil, "unordered-id" end
        output[catalogId] = count
        previousId = catalogId
    end

    return output
end

local function ParseItemLinkFields(itemLink, fields)
    Clear(fields)
    if type(itemLink) ~= "string" then return false end
    local payload = string.match(itemLink, "|H%d+:item:([^|]+)|h")
    if not payload then return false end

    for field in string.gmatch(payload, "([^:]+)") do
        local value = tonumber(field)
        if value == nil then return false end
        fields[#fields + 1] = value
    end
    return #fields > 0
end

function Codec.PackVariant(itemLink, flags, buffer, fields)
    buffer = buffer or {}
    fields = fields or {}
    Clear(buffer)
    if not ParseItemLinkFields(itemLink, fields) then return nil end

    AppendUnsigned(buffer, math.max(math.floor(tonumber(flags) or 0), 0))
    AppendUnsigned(buffer, #fields)
    for index = 1, #fields do
        AppendUnsigned(buffer, EncodeSigned(fields[index]))
    end
    return table.concat(buffer)
end

function Codec.UnpackVariant(packed, fields)
    if type(packed) ~= "string" or packed == "" then return nil, nil, "invalid-variant" end
    fields = fields or {}
    Clear(fields)

    local flags, offset = ReadUnsigned(packed, 1)
    if flags == nil then return nil, nil, "invalid-flags" end
    local fieldCount
    fieldCount, offset = ReadUnsigned(packed, offset)
    if not fieldCount or fieldCount <= 0 or fieldCount > 128 then
        return nil, nil, "invalid-field-count"
    end

    for index = 1, fieldCount do
        local encodedValue
        encodedValue, offset = ReadUnsigned(packed, offset)
        if encodedValue == nil then return nil, nil, "truncated-variant" end
        fields[index] = DecodeSigned(encodedValue)
    end
    if offset <= #packed then return nil, nil, "trailing-variant-data" end

    local text = {}
    for index = 1, #fields do
        text[index] = tostring(fields[index])
    end
    return "|H1:item:" .. table.concat(text, ":") .. "|h|h", flags
end

function Codec.RemapCounts(encoded, remap, scratch, result)
    scratch = scratch or {}
    result = result or {}
    local decoded, errorCode = Codec.DecodeCounts(encoded, scratch)
    if not decoded then return nil, errorCode end
    Clear(result)

    for oldId, count in pairs(decoded) do
        local newId = remap[oldId]
        if newId then result[newId] = (result[newId] or 0) + count end
    end
    return Codec.EncodeCounts(result)
end

Codec._AppendUnsigned = AppendUnsigned
Codec._ReadUnsigned = ReadUnsigned
