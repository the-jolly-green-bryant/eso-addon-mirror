local TT = TamrielicTongues
local data = TT.LanguageData.orcish

TT.Registry:Register({
    id = "orcish",
    wireId = 7,
    name = "Orcish",
    race = "Orc",
    alliance = "Daggerfall Covenant",
    version = 1,
    seed = 143771,
    aliases = { "orcish", "orc", "orsimer" },
    signatures = { "grosh", "maugr", "burak", "ugraz" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
