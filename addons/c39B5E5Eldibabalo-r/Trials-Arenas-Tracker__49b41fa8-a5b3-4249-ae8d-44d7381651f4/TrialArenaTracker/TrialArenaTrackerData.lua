-- =============================================================================
-- Trial & Arena Tracker — Data Definitions
-- All trial and arena content with hardcoded achievement IDs.
-- Achievement IDs sourced from Pithka's Achievement Tracker.
-- =============================================================================

TAT_Data = {}

-- ---------------------------------------------------------------------------
-- Content type constants
-- ---------------------------------------------------------------------------
TAT_Data.CONTENT_TRIAL = 1
TAT_Data.CONTENT_ARENA = 2

-- ---------------------------------------------------------------------------
-- Achievement type constants
-- ---------------------------------------------------------------------------
TAT_Data.ACH_VETERAN   = "veteran"
TAT_Data.ACH_HARD_MODE = "hardMode"
TAT_Data.ACH_SPEED_RUN = "speedRun"
TAT_Data.ACH_NO_DEATH  = "noDeath"
TAT_Data.ACH_TRIFECTA  = "trifecta"
TAT_Data.ACH_OTHER     = "other"

-- ---------------------------------------------------------------------------
-- Trial definitions
-- ---------------------------------------------------------------------------
TAT_Data.Trials = {
    { name = "Aetherian Archive",    group = "Craglorn",                  vetId = 1503, hmId = 1137, srId = 1081 },
    { name = "Hel Ra Citadel",       group = "Craglorn",                  vetId = 1474, hmId = 1136, srId = 1080 },
    { name = "Sanctum Ophidia",      group = "Craglorn",                  vetId = 1462, hmId = 1138, srId = 1124 },
    { name = "Maw of Lorkhaj",       group = "Thieves Guild",             vetId = 1368, hmId = 1344, srId = 1367, ndId = 1392 },
    { name = "Halls of Fabrication", group = "Morrowind",                  vetId = 1810, hmId = 1829, srId = 1809, ndId = 1811, triId = 1838 },
    { name = "Asylum Sanctorium",    group = "Clockwork City",             vetId = 2077, hmId = 2079, srId = 2081, ndId = 2080, triId = 2087 },
    { name = "Cloudrest",            group = "Summerset",                  vetId = 2133, hmId = 2136, srId = 2137, ndId = 2138, triId = 2139 },
    { name = "Sunspire",             group = "Elsweyr",                    vetId = 2435, hmId = 2466, srId = 2434, ndId = 2436, triId = 2467 },
    { name = "Kyne's Aegis",         group = "Greymoor",                   vetId = 2734, hmId = 2739, srId = 2733, ndId = 2735, triId = 2740 },
    { name = "Rockgrove",            group = "Blackwood",                  vetId = 2987, hmId = 3007, srId = 2986, ndId = 2988, triId = 3003 },
    { name = "Dreadsail Reef",       group = "High Isle",                  vetId = 3244, hmId = 3252, srId = 3243, ndId = 3245, triId = 3248 },
    { name = "Sanity's Edge",        group = "Necrom",                     vetId = 3560, hmId = 3568, srId = 3559, ndId = 3561, triId = 3564 },
    { name = "Lucent Citadel",       group = "Gold Road",                  vetId = 4015, hmId = 4023, srId = 4014, ndId = 4016, triId = 4019 },
    { name = "Ossein Cage",          group = "Seasons of the Worm Cult",   vetId = 4268, hmId = 4276, srId = 4267, ndId = 4269, triId = 4272 },
}

-- ---------------------------------------------------------------------------
-- Arena definitions
-- ---------------------------------------------------------------------------
TAT_Data.Arenas = {
    { name = "Dragonstar Arena",     group = "Craglorn",  vetId = 1140 },
    { name = "Maelstrom Arena",      group = "Orsinium",  vetId = 1305, ndId = 1330 },
    { name = "Blackrose Prison",     group = "Murkmire",  vetId = 2363, hmId = 2364, srId = 2366, ndId = 2365, triId = 2368 },
    { name = "Vateshran Hollows",    group = "Markarth",  vetId = 2908, ndId = 2909, srId = 2910, triId = 2912 },
}

-- ---------------------------------------------------------------------------
-- Group ordering
-- ---------------------------------------------------------------------------
TAT_Data.TrialGroupOrder = {
    "Craglorn", "Thieves Guild", "Morrowind", "Clockwork City",
    "Summerset", "Elsweyr", "Greymoor", "Blackwood",
    "High Isle", "Necrom", "Gold Road", "Seasons of the Worm Cult",
}

TAT_Data.ArenaGroupOrder = {
    "Craglorn", "Orsinium", "Murkmire", "Markarth",
}
