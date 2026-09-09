local TT = TamrielicTongues

TT.Translator = {}

local ALPHABET = "abcdefghijklmnopqrstuvwxyz"

local function buildCodec(profile)
    profile.reverseCodec = {}
    assert(#profile.codec == 26, "language codec requires exactly 26 digraphs")

    for index = 1, 26 do
        local source = ALPHABET:sub(index, index)
        local target = string.lower(profile.codec[index])
        assert(#target == 2, "codec token must be exactly two ASCII characters: " .. target)
        assert(not profile.reverseCodec[target], "duplicate codec token: " .. target)
        profile.codec[index] = target
        profile.reverseCodec[target] = source
    end
end

function TT.Translator:PrepareLanguage(profile)
    buildCodec(profile)
    TT.WordGenerator:BuildLexicon(profile)
end

local function encodeCodecWord(profile, word)
    local out = {}
    for i = 1, #word do
        local character = word:sub(i, i)
        local lower = string.lower(character)
        local index = ALPHABET:find(lower, 1, true)
        if not index then
            return word
        end

        local token = profile.codec[index]
        if character == string.upper(character) and character ~= string.lower(character) then
            token = string.upper(token)
        end
        out[#out + 1] = token
    end
    return table.concat(out)
end

local function decodeCodecWord(profile, word)
    if #word % 2 ~= 0 then
        return nil
    end

    local out = {}
    for i = 1, #word, 2 do
        local token = word:sub(i, i + 1)
        local source = profile.reverseCodec[string.lower(token)]
        if not source then
            return nil
        end
        if token == string.upper(token) and token ~= string.lower(token) then
            source = string.upper(source)
        end
        out[#out + 1] = source
    end
    return table.concat(out)
end

function TT.Translator:EncodeWord(profile, word)
    local lower = string.lower(word)
    local caseMode = TT.Normalizer:GetCase(word)

    local direct = profile.lexicon[lower]
    if direct then
        return TT.Normalizer:ApplyCase(direct, caseMode)
    end

    local inflected = TT.Morphology:TryEncode(profile, word)
    if inflected then
        return inflected
    end

    return encodeCodecWord(profile, word)
end

function TT.Translator:DecodeWord(profile, word)
    local lower = string.lower(word)
    local caseMode = TT.Normalizer:GetCase(word)

    local direct = profile.reverseLexicon[lower]
    if direct then
        return TT.Normalizer:ApplyCase(direct, caseMode)
    end

    local inflected = TT.Morphology:TryDecode(profile, word)
    if inflected then
        return inflected
    end

    return decodeCodecWord(profile, word) or word
end

function TT.Translator:EncodeBody(profile, text)
    return TT.Grammar:Encode(profile, text, function(word, sentenceStart)
        -- English capitalizes the pronoun everywhere; translated words need
        -- that capital only at a sentence boundary, not in the middle of one.
        if word == "I" and not sentenceStart then
            word = "i"
        end
        return self:EncodeWord(profile, word)
    end)
end

function TT.Translator:DecodeBody(profile, text)
    return TT.Grammar:Decode(profile, text, function(word)
        local decoded = self:DecodeWord(profile, word)
        -- Restore English orthography after context-sensitive encoding.
        return decoded == "i" and "I" or decoded
    end)
end

function TT.Translator:ChooseSignature(profile, text)
    local hash = TT.WordGenerator:Hash(text, profile.seed)
    return profile.signatures[(hash % #profile.signatures) + 1]
end

function TT.Translator:Detect(text)
    if type(text) ~= "string" then
        return nil
    end

    local wireVersion, wireId, markerBody = TT.Versioning:ParseMarker(text)
    if wireVersion ~= nil then
        local profile = TT.Registry:FromWireId(wireId)
        if markerBody == "" or not TT.Versioning:IsCompatible(profile, wireVersion) then
            return nil
        end
        return profile, markerBody
    end

    -- Legacy signatures remain readable, but are no longer sent.
    local signature, body = text:match("^(%S+)%s+(.+)$")
    if not signature then
        return nil
    end

    local profile = TT.Registry:FromSignature(signature)
    if not TT.Versioning:IsCompatible(profile, 1) then
        return nil
    end

    return profile, body
end

function TT.Translator:Encode(languageId, text)
    if type(text) ~= "string" or text == "" then
        return nil, TT.Locale:Get("MESSAGE_EMPTY")
    end
    if TT.Registry:ResolveId(languageId) == TT.Constants.COMMON_LANGUAGE_ID then
        return text
    end

    local profile = TT.Registry:Resolve(languageId)
    if not profile then
        return nil, TT.Locale:Get("ENCODE_UNKNOWN_LANGUAGE", tostring(languageId))
    end

    if not TT.Versioning:IsCompatible(profile) then
        return nil, TT.Locale:Get("UNSUPPORTED_LANGUAGE_VERSION", tostring(languageId))
    end

    local body = self:EncodeBody(profile, text)

    return body .. TT.Versioning:GetMarker(profile), nil, profile
end

function TT.Translator:Decode(text)
    local profile, body = self:Detect(text)
    if not profile then
        return nil
    end

    return self:DecodeBody(profile, body), profile
end
