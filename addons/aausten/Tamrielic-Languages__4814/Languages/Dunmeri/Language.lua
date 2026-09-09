local TT = TamrielicTongues
local data = TT.LanguageData.dunmeri

TT.Registry:Register({
    id = "dunmeri",
    wireId = 3,
    name = "Dunmeri",
    race = "Dunmer",
    alliance = "Ebonheart Pact",
    version = 1,
    seed = 92717,
    aliases = { "dunmeri", "dunmer", "darkelf", "dark-elf" },
    signatures = { "velas", "draveth", "seran", "narev" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
