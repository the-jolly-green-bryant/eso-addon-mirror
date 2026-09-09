local TT = TamrielicTongues
local data = TT.LanguageData.taagra

TT.Registry:Register({
    id = "taagra",
    wireId = 1,
    name = "Ta'agra",
    race = "Khajiit",
    alliance = "Aldmeri Dominion",
    version = 1,
    seed = 73129,
    aliases = { "taagra", "ta'agra", "khajiit", "khajiiti" },
    signatures = { "dar'zi", "ra'zir", "jo'ra", "sen'ji" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
