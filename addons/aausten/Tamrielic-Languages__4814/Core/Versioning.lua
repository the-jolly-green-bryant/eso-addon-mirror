local TT = TamrielicTongues

TT.Versioning = {
    WIRE_VERSION = 1,
    MARKER_PREFIX = "D7",
    ZERO_BIT = string.char(226, 128, 139), -- U+200B
    ONE_BIT = string.char(226, 128, 140), -- U+200C
    MARKER_BITS = 24,
    MARKER_BYTES = 72,
}

function TT.Versioning:GetLanguageVersion(profile)
    return profile and profile.version or nil
end

function TT.Versioning:IsCompatible(profile, wireVersion)
    if wireVersion == nil then
        wireVersion = self.WIRE_VERSION
    end
    return wireVersion == 1 and type(profile) == "table" and profile.version == 1
end

function TT.Versioning:GetMarker(profile)
    assert(self:IsCompatible(profile), "incompatible language profile or wire version")
    local wireId = profile.wireId
    assert(type(wireId) == "number" and wireId >= 1 and wireId <= 4095 and wireId % 1 == 0,
        "language wire id must be an integer from 1 to 4095")
    local payload = tonumber(self.MARKER_PREFIX, 16) * 65536 + self.WIRE_VERSION * 4096 + wireId
    local out = {}
    for bit = self.MARKER_BITS - 1, 0, -1 do
        out[#out + 1] = math.floor(payload / 2 ^ bit) % 2 == 0 and self.ZERO_BIT or self.ONE_BIT
    end
    return table.concat(out)
end

function TT.Versioning:ParseMarker(text)
    if type(text) ~= "string" or #text < self.MARKER_BYTES then
        return nil
    end

    local start = #text - self.MARKER_BYTES + 1
    local payload = 0
    for index = start, #text, 3 do
        local character = string.sub(text, index, index + 2)
        if character == self.ZERO_BIT then
            payload = payload * 2
        elseif character == self.ONE_BIT then
            payload = payload * 2 + 1
        else
            return nil
        end
    end
    if math.floor(payload / 65536) ~= tonumber(self.MARKER_PREFIX, 16) then
        return nil
    end

    -- Parse unsupported values too, so callers can reject without legacy fallback.
    return math.floor(payload / 4096) % 16, payload % 4096, string.sub(text, 1, start - 1)
end
