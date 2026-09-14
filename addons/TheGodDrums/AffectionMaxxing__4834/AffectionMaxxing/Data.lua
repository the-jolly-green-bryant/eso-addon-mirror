local AM = AffectionMaxxing

-- Companions are found at runtime from the companion collectibles, then matched to
-- these keys by a case-insensitive substring of their name.
AM.COMPANIONS = {
    BASTIAN = { "Bastian" },
    MIRRI = { "Mirri" },
    EMBER = { "Ember" },
    ISOBEL = { "Isobel" },
    SHARP = { "Sharp-as-Night", "Sharp" },
    AZANDAR = { "Azandar" },
    TANLORIN = { "Tanlorin" },
    ZERITH = { "Zerith" },
}

-- Rapport earned by turning in repeatable quests, from
-- https://en.uesp.net/wiki/Online:Companions#Rapport
--
-- A rule applies to a repeatable quest when:
--   questType  (if set) equals the journal quest type, and
--   givers / names / prefixes (if any are set) match at least once.
-- givers are case-insensitive substrings of the NPC you accepted the quest from or are
-- turning it in to. names are exact quest names and prefixes are quest-name prefixes,
-- both case-insensitive plain text (English client).
-- skillLine names the companion guild skill line the quest levels for whichever
-- companion is summoned, whether or not they like the quest.
AM.RULES = {
    {
        label = "Mages Guild relic daily",
        amount = 125,
        companions = { "BASTIAN", "EMBER" },
        givers = { "Alvur Baren" },
        prefixes = { "Madness in " },
        skillLine = "Mages Guild",
    },
    {
        label = "Fighters Guild Dark Anchor contract",
        amount = 125,
        companions = { "MIRRI", "TANLORIN" },
        givers = { "Cardea Gallus" },
        prefixes = { "Dark Anchors in " },
        skillLine = "Fighters Guild",
    },
    {
        label = "Ashlander relic daily",
        amount = 125,
        companions = { "MIRRI", "SHARP" },
        givers = { "Numani-Rasi" },
        prefixes = { "Relics of " },
        note = "Sharp-as-Night only counts one Ashlander daily per day.",
    },
    {
        label = "Ashlander hunt daily",
        amount = 125,
        companions = { "SHARP" },
        givers = { "Sorim-Nakar" },
        names = {
            "Ash-Eater Hunt",
            "Great Zexxin Hunt",
            "King Razor-Tusk Hunt",
            "Mother Jagged-Claw Hunt",
            "Old Stomper Hunt",
            "Tarra-Suj Hunt",
            "Writhing Sveeth Hunt",
        },
        note = "Sharp-as-Night only counts one Ashlander daily per day.",
    },
    {
        label = "Undaunted delve daily",
        amount = 125,
        companions = { "ISOBEL" },
        givers = { "Bolgrul" },
        skillLine = "Undaunted",
    },
    {
        label = "High Isle group boss daily",
        amount = 125,
        companions = { "ISOBEL" },
        givers = { "Parisse Plouff" },
    },
    {
        label = "High Isle delve daily",
        amount = 125,
        companions = { "EMBER" },
        givers = { "Wayllod" },
    },
    {
        label = "Necrom world boss daily",
        amount = 125,
        companions = { "SHARP" },
        givers = { "Nelyn" },
    },
    {
        label = "Necrom delve daily",
        amount = 125,
        companions = { "AZANDAR" },
        givers = { "Tilena" },
    },
    {
        label = "Northern Elsweyr Defense Force daily",
        amount = 125,
        companions = { "ZERITH" },
        givers = { "Zahari" },
    },
    {
        label = "Tales of Tribute daily",
        amount = 125,
        companions = { "ZERITH" },
        questType = QUEST_TYPE_TRIBUTE,
        note = "Zerith-var only counts one Tales of Tribute daily per day.",
    },
    {
        label = "Thieves Guild heist",
        amount = 125,
        companions = { "EMBER" },
        prefixes = { "Heist: " },
    },
    {
        label = "Alchemist writ",
        amount = 125,
        companions = { "TANLORIN" },
        questType = QUEST_TYPE_CRAFTING,
        names = { "Alchemist Writ" },
    },
    {
        label = "Enchanter writ",
        amount = 125,
        companions = { "AZANDAR" },
        questType = QUEST_TYPE_CRAFTING,
        names = { "Enchanter Writ" },
    },
    {
        label = "Enchanting master writ",
        amount = 15,
        companions = { "AZANDAR" },
        questType = QUEST_TYPE_CRAFTING,
        names = { "A Masterful Glyph" },
    },
    {
        label = "Thieves Guild tip board job",
        amount = 5,
        companions = { "EMBER" },
        names = { "Crime Spree", "Idle Hands", "Plucking Fingers", "The Covetous Countess", "Under Our Thumb" },
    },
    {
        label = "Festival writ",
        amount = 5,
        companions = { "TANLORIN" },
        names = { "Witches Festival Writ", "Imperial Charity Writ" },
    },
}
