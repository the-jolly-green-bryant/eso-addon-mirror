local TT = TamrielicTongues

TT.Morphology = {}

local function endsWith(value, suffix)
    return suffix ~= "" and value:sub(-#suffix) == suffix
end

function TT.Morphology:TryEncode(profile, word)
    local lower = string.lower(word)
    local caseMode = TT.Normalizer:GetCase(word)
    local rules = {
        { sourceSuffix = "ing", targetSuffix = profile.morphology.progressive },
        { sourceSuffix = "ed", targetSuffix = profile.morphology.past },
        { sourceSuffix = "s", targetSuffix = profile.morphology.plural },
    }

    for _, rule in ipairs(rules) do
        if #lower > #rule.sourceSuffix + 1 and endsWith(lower, rule.sourceSuffix) then
            local base = lower:sub(1, #lower - #rule.sourceSuffix)
            local translatedBase = profile.lexicon[base]
            if translatedBase then
                return TT.Normalizer:ApplyCase(translatedBase .. rule.targetSuffix, caseMode)
            end
        end
    end

    return nil
end

function TT.Morphology:TryDecode(profile, word)
    local lower = string.lower(word)
    local caseMode = TT.Normalizer:GetCase(word)
    local rules = {
        { targetSuffix = profile.morphology.progressive, sourceSuffix = "ing" },
        { targetSuffix = profile.morphology.past, sourceSuffix = "ed" },
        { targetSuffix = profile.morphology.plural, sourceSuffix = "s" },
    }

    for _, rule in ipairs(rules) do
        if #lower > #rule.targetSuffix and endsWith(lower, rule.targetSuffix) then
            local translatedBase = lower:sub(1, #lower - #rule.targetSuffix)
            local sourceBase = profile.reverseLexicon[translatedBase]
            if sourceBase then
                return TT.Normalizer:ApplyCase(sourceBase .. rule.sourceSuffix, caseMode)
            end
        end
    end

    return nil
end
