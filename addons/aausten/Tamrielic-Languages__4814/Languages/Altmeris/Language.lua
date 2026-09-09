local TT = TamrielicTongues
local data = TT.LanguageData.altmeris

TT.Registry:Register({
    id = "altmeris",
    wireId = 4,
    name = "Altmeris",
    race = "Altmer",
    alliance = "Aldmeri Dominion",
    version = 1,
    seed = 104729,
    aliases = { "altmeris", "altmer", "highelf", "high-elf" },
    signatures = { "aelir", "caelis", "elari", "thalen" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
