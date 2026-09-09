local TT = TamrielicTongues

TT.Registry = {
    -- Permanent protocol assignments: never renumber or reuse an ID.
    WireIds = {
        taagra = 1,
        jel = 2,
        dunmeri = 3,
        altmeris = 4,
        bosmeri = 5,
        nordic = 6,
        orcish = 7,
        yoku = 8,
        bretic = 9,
    },
    wireLanguages = {},
    languages = {},
    aliases = {},
    signatures = {},
    ordered = {},
}

local function normalize(value)
    if not value then
        return nil
    end
    return string.lower(value)
end

function TT.Registry:Register(profile)
    assert(type(profile) == "table", "language profile must be a table")
    assert(type(profile.id) == "string", "language profile requires id")
    assert(type(profile.name) == "string", "language profile requires name")
    assert(type(profile.race) == "string", "language profile requires race")
    local legacySignatures = profile.signatures or {}
    assert(type(legacySignatures) == "table", "language signatures must be a table")

    local id = string.lower(profile.id)
    assert(not self.languages[id], "duplicate language id: " .. id)

    local wireId = profile.wireId
    assert(type(wireId) == "number" and wireId >= 1 and wireId <= 4095 and wireId % 1 == 0,
        "language wire id must be an integer from 1 to 4095")
    assert(self.WireIds[id] == wireId, "language wire id does not match permanent assignment: " .. id)
    assert(not self.wireLanguages[wireId], "duplicate language wire id: " .. wireId)

    for _, alias in ipairs(profile.aliases or {}) do
        assert(type(alias) == "string", "language alias must be a string")
    end

    local signatures = {}
    for _, signature in ipairs(legacySignatures) do
        assert(type(signature) == "string", "language signature must be a string")
        local key = string.lower(signature)
        assert(not self.signatures[key] and not signatures[key], "duplicate language signature: " .. key)
        signatures[key] = true
    end

    profile.id = id
    self.languages[id] = profile
    self.wireLanguages[wireId] = profile
    self.ordered[#self.ordered + 1] = profile

    self.aliases[id] = id
    self.aliases[string.lower(profile.name)] = id
    self.aliases[string.lower(profile.race)] = id

    for _, alias in ipairs(profile.aliases or {}) do
        self.aliases[string.lower(alias)] = id
    end

    for key in pairs(signatures) do
        self.signatures[key] = profile
    end
end

function TT.Registry:Resolve(value)
    local key = normalize(value)
    if not key or key == TT.Constants.COMMON_LANGUAGE_ID or key == "off" or key == "tamrielic" then
        return nil
    end

    local id = self.aliases[key] or key
    return self.languages[id]
end

function TT.Registry:ResolveId(value)
    local key = normalize(value)
    if not key then
        return nil
    end
    if key == TT.Constants.COMMON_LANGUAGE_ID or key == "off" or key == "tamrielic" then
        return TT.Constants.COMMON_LANGUAGE_ID
    end
    return self.aliases[key] or (self.languages[key] and key or nil)
end

function TT.Registry:FromSignature(signature)
    return self.signatures[normalize(signature)]
end

function TT.Registry:FromWireId(id)
    return self.wireLanguages[id]
end

function TT.Registry:GetOrdered()
    return self.ordered
end

function TT.Registry:Finalize()
    for _, profile in ipairs(self.ordered) do
        TT.Translator:PrepareLanguage(profile)
    end
end
