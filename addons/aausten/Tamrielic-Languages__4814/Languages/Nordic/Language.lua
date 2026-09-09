local TT = TamrielicTongues
local data = TT.LanguageData.nordic

TT.Registry:Register({
    id = "nordic",
    wireId = 6,
    name = "Nordic",
    race = "Nord",
    alliance = "Ebonheart Pact",
    version = 1,
    seed = 129749,
    aliases = { "nordic", "nord", "nords" },
    signatures = { "skald", "hjorn", "vargr", "thrym" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
