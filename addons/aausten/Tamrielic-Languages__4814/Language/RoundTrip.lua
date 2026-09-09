local TT = TamrielicTongues

TT.RoundTrip = {}

function TT.RoundTrip:Validate(languageId, text)
    local encoded, encodeError = TT.Translator:Encode(languageId, text)
    if not encoded then
        return false, encodeError
    end

    local decoded, profile = TT.Translator:Decode(encoded)
    if not decoded then
        return false, "encoded text was not recognized"
    end

    return decoded == text, {
        encoded = encoded,
        decoded = decoded,
        language = profile and profile.id or nil,
    }
end
