local TT = TamrielicTongues

TT.Grammar = {}

-- v1 deliberately preserves source word order. The abstraction exists so later
-- language versions can add safe, versioned transformations without changing the
-- chat integration or language-pack contract.
function TT.Grammar:Encode(profile, text, wordEncoder)
    return TT.Tokenizer:MapWords(text, wordEncoder)
end

function TT.Grammar:Decode(profile, text, wordDecoder)
    return TT.Tokenizer:MapWords(text, wordDecoder)
end
