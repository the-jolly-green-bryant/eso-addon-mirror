local TT = TamrielicTongues
local data = TT.LanguageData.yoku

TT.Registry:Register({
    id = "yoku",
    wireId = 8,
    name = "Yoku",
    race = "Redguard",
    alliance = "Daggerfall Covenant",
    version = 1,
    seed = 158003,
    aliases = { "yoku", "redguard", "yokudan" },
    signatures = { "ansel", "rahan", "yasar", "satak" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
