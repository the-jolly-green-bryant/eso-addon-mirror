local TT = TamrielicTongues
local data = TT.LanguageData.jel

TT.Registry:Register({
    id = "jel",
    wireId = 2,
    name = "Jel",
    race = "Argonian",
    alliance = "Ebonheart Pact",
    version = 1,
    seed = 81421,
    aliases = { "jel", "argonian", "saxhleel" },
    signatures = { "xaleth", "tzeel", "saxha", "nassa" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
