local TT = TamrielicTongues
local data = TT.LanguageData.bosmeri

TT.Registry:Register({
    id = "bosmeri",
    wireId = 5,
    name = "Bosmeri",
    race = "Bosmer",
    alliance = "Aldmeri Dominion",
    version = 1,
    seed = 116731,
    aliases = { "bosmeri", "bosmer", "woodelf", "wood-elf" },
    signatures = { "vaeli", "thren", "galar", "naeth" },
    codec = data.phonology.codec,
    phonology = data.phonology,
    morphology = data.morphology,
    grammar = data.grammar,
    lexicon = data.lexicon,
    provenance = data.lexiconProvenance,
})
