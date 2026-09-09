local TT = TamrielicTongues
local data = TT.LanguageData.bretic

TT.Registry:Register({
    id = "bretic",
    wireId = 9,
    name = "Bretic",
    race = "Breton",
    alliance = "Daggerfall Covenant",
    version = 1,
    seed = 173021,
    aliases = { "bretic", "breton", "oldbretic", "old-bretic" },
    signatures = { "avelin", "caern", "brenna", "veren" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
