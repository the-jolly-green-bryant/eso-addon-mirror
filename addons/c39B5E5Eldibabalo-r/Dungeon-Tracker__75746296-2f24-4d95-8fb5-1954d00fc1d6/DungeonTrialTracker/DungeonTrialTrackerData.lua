-- =============================================================================
-- Dungeon Tracker — Data Definitions
-- All dungeon, trial, and arena content with hardcoded achievement IDs.
-- Achievement IDs sourced from Pithka's Achievement Tracker.
-- =============================================================================

DTT_Data = {}

-- ---------------------------------------------------------------------------
-- Content type constants
-- ---------------------------------------------------------------------------
DTT_Data.CONTENT_DUNGEON = 1
DTT_Data.CONTENT_TRIAL   = 2
DTT_Data.CONTENT_ARENA   = 3

-- ---------------------------------------------------------------------------
-- Achievement type constants
-- ---------------------------------------------------------------------------
DTT_Data.ACH_VETERAN   = "veteran"
DTT_Data.ACH_HARD_MODE = "hardMode"
DTT_Data.ACH_SPEED_RUN = "speedRun"
DTT_Data.ACH_NO_DEATH  = "noDeath"
DTT_Data.ACH_TRIFECTA  = "trifecta"
DTT_Data.ACH_OTHER     = "other"

-- ---------------------------------------------------------------------------
-- Dungeon definitions
-- Each entry: { name, group, vetId, hmId, srId, ndId, triId?, questId? }
-- questId = numeric story / dungeon objective quest (per character via GetCompletedQuestInfo).
-- IDs sourced from UESP quest pages where available; omit questId when unknown.
-- ---------------------------------------------------------------------------
DTT_Data.Dungeons = {
    -- ── Base Game Dungeons ──────────────────────────────────────────────
    { name = "Fungal Grotto I",        group = "Base Game",  vetId = 1556, hmId = 1561, srId = 1559, ndId = 1560, questId = 3993 },
    { name = "Fungal Grotto II",       group = "Base Game",  vetId = 343,  hmId = 342,  srId = 340,  ndId = 1563, questId = 4303 },
    { name = "Spindleclutch I",        group = "Base Game",  vetId = 1565, hmId = 1570, srId = 1568, ndId = 1569, questId = 4054 },
    { name = "Spindleclutch II",       group = "Base Game",  vetId = 421,  hmId = 448,  srId = 446,  ndId = 1572, questId = 4555 },
    { name = "The Banished Cells I",   group = "Base Game",  vetId = 1549, hmId = 1554, srId = 1552, ndId = 1553, questId = 4107 },
    { name = "The Banished Cells II",  group = "Base Game",  vetId = 545,  hmId = 451,  srId = 449,  ndId = 1564, questId = 4597 },
    { name = "Elden Hollow I",         group = "Base Game",  vetId = 1573, hmId = 1578, srId = 1576, ndId = 1577, questId = 4336 },
    { name = "Elden Hollow II",        group = "Base Game",  vetId = 459,  hmId = 463,  srId = 461,  ndId = 1580, questId = 4675 },
    { name = "Wayrest Sewers I",       group = "Base Game",  vetId = 1589, hmId = 1594, srId = 1592, ndId = 1593, questId = 4246 },
    { name = "Wayrest Sewers II",      group = "Base Game",  vetId = 678,  hmId = 681,  srId = 679,  ndId = 1596, questId = 4813 },
    { name = "Arx Corinium",           group = "Base Game",  vetId = 1604, hmId = 1609, srId = 1607, ndId = 1608, questId = 4202 },
    { name = "City of Ash I",          group = "Base Game",  vetId = 1597, hmId = 1602, srId = 1600, ndId = 1601, questId = 4778 },
    { name = "City of Ash II",         group = "Base Game",  vetId = 878,  hmId = 1114, srId = 1108, ndId = 1107, questId = 5120 },
    { name = "Crypt of Hearts I",      group = "Base Game",  vetId = 1610, hmId = 1615, srId = 1613, ndId = 1614, questId = 4379 },
    { name = "Crypt of Hearts II",     group = "Base Game",  vetId = 876,  hmId = 1084, srId = 941,  ndId = 942,  questId = 5113 },
    { name = "Direfrost Keep",         group = "Base Game",  vetId = 1623, hmId = 1628, srId = 1626, ndId = 1627, questId = 4346 },
    -- Story quest ID not listed on UESP (Eye of the Storm); add when confirmed in-game
    { name = "Tempest Island",         group = "Base Game",  vetId = 1617, hmId = 1622, srId = 1620, ndId = 1621 },
    { name = "Volenfell",              group = "Base Game",  vetId = 1629, hmId = 1634, srId = 1632, ndId = 1633, questId = 4432 },
    { name = "Darkshade Caverns I",    group = "Base Game",  vetId = 1581, hmId = 1586, srId = 1584, ndId = 1585, questId = 4145 },
    { name = "Darkshade Caverns II",   group = "Base Game",  vetId = 464,  hmId = 467,  srId = 465,  ndId = 1588, questId = 4641 },
    { name = "Blackheart Haven",       group = "Base Game",  vetId = 1647, hmId = 1652, srId = 1650, ndId = 1651, questId = 4589 },
    { name = "Blessed Crucible",       group = "Base Game",  vetId = 1641, hmId = 1646, srId = 1644, ndId = 1645, questId = 4469 },
    { name = "Selene's Web",           group = "Base Game",  vetId = 1635, hmId = 1640, srId = 1638, ndId = 1639, questId = 4733 },
    { name = "Vaults of Madness",      group = "Base Game",  vetId = 1653, hmId = 1658, srId = 1656, ndId = 1657, questId = 4822 },

    -- ── DLC Dungeons (no trifecta) ────────────────────────────────────
    { name = "Imperial City Prison",   group = "Imperial City",        vetId = 880,  hmId = 1303, srId = 1128, ndId = 1129, questId = 5136 },
    { name = "White-Gold Tower",       group = "Imperial City",        vetId = 1120, hmId = 1279, srId = 1275, ndId = 1276, questId = 5342 },
    { name = "Ruins of Mazzatun",      group = "Shadows of the Hist",  vetId = 1505, hmId = 1506, srId = 1507, ndId = 1508, questId = 5403 },
    { name = "Cradle of Shadows",      group = "Shadows of the Hist",  vetId = 1523, hmId = 1524, srId = 1525, ndId = 1526, questId = 5702 },
    { name = "Falkreath Hold",         group = "Horns of the Reach",   vetId = 1699, hmId = 1704, srId = 1702, ndId = 1703, questId = 5891 },
    { name = "Bloodroot Forge",        group = "Horns of the Reach",   vetId = 1691, hmId = 1696, srId = 1694, ndId = 1695, questId = 5889 },

    -- ── DLC Dungeons (with trifecta) ──────────────────────────────────
    { name = "Fang Lair",              group = "Dragon Bones",         vetId = 1960, hmId = 1965, srId = 1963, ndId = 1964, triId = 2102, questId = 6064 },
    { name = "Scalecaller Peak",       group = "Dragon Bones",         vetId = 1976, hmId = 1981, srId = 1979, ndId = 1980, triId = 1983, questId = 6065 },
    { name = "Moon Hunter Keep",       group = "Wolfhunter",           vetId = 2153, hmId = 2154, srId = 2155, ndId = 2156, triId = 2159, questId = 6186 },
    { name = "March of Sacrifices",    group = "Wolfhunter",           vetId = 2163, hmId = 2164, srId = 2165, ndId = 2166, triId = 2168, questId = 6188 },
    { name = "Frostvault",             group = "Wrathstone",           vetId = 2261, hmId = 2262, srId = 2263, ndId = 2264, triId = 2267, questId = 6249 },
    { name = "Depths of Malatar",      group = "Wrathstone",           vetId = 2271, hmId = 2272, srId = 2273, ndId = 2274, triId = 2276, questId = 6251 },
    { name = "Lair of Maarselok",      group = "Scalebreaker",         vetId = 2426, hmId = 2427, srId = 2428, ndId = 2429, triId = 2431, questId = 6351 },
    { name = "Moongrave Fane",         group = "Scalebreaker",         vetId = 2416, hmId = 2417, srId = 2418, ndId = 2419, triId = 2422, questId = 6349 },
    { name = "Icereach",               group = "Harrowstorm",          vetId = 2540, hmId = 2541, srId = 2542, ndId = 2543, triId = 2546, questId = 6414 },
    { name = "Unhallowed Grave",       group = "Harrowstorm",          vetId = 2550, hmId = 2551, srId = 2552, ndId = 2553, triId = 2555, questId = 7224 },
    { name = "Stone Garden",           group = "Stonethorn",           vetId = 2695, hmId = 2755, srId = 2697, ndId = 2698, triId = 2701, questId = 6505 },
    -- Story quest ID not on UESP infobox (Blood of the Past); add when confirmed
    { name = "Castle Thorn",           group = "Stonethorn",           vetId = 2705, hmId = 2706, srId = 2707, ndId = 2708, triId = 2710 },
    { name = "Black Drake Villa",      group = "Flames of Ambition",   vetId = 2832, hmId = 2833, srId = 2834, ndId = 2835, triId = 2838, questId = 6576 },
    { name = "The Cauldron",           group = "Flames of Ambition",   vetId = 2842, hmId = 2843, srId = 2844, ndId = 2845, triId = 2847, questId = 6578 },
    { name = "Red Petal Bastion",      group = "Waking Flame",         vetId = 3017, hmId = 3018, srId = 3019, ndId = 3020, triId = 3023, questId = 6683 },
    { name = "The Dread Cellar",       group = "Waking Flame",         vetId = 3027, hmId = 3028, srId = 3029, ndId = 3030, triId = 3032, questId = 6685 },
    { name = "Coral Aerie",            group = "Ascending Tide",       vetId = 3105, hmId = 3153, srId = 3107, ndId = 3108, triId = 3111, questId = 6740 },
    { name = "Shipwright's Regret",    group = "Ascending Tide",       vetId = 3115, hmId = 3154, srId = 3117, ndId = 3118, triId = 3120, questId = 6742 },
    { name = "Earthen Root Enclave",   group = "Lost Depths",          vetId = 3376, hmId = 3377, srId = 3378, ndId = 3379, triId = 3381, questId = 6835 },
    { name = "Graven Deep",            group = "Lost Depths",          vetId = 3395, hmId = 3396, srId = 3397, ndId = 3398, triId = 3400, questId = 6837 },
    { name = "Bal Sunnar",             group = "Scribes of Fate",      vetId = 3469, hmId = 3470, srId = 3471, ndId = 3472, triId = 3474, questId = 6896 },
    { name = "Scrivener's Hall",       group = "Scribes of Fate",      vetId = 3530, hmId = 3531, srId = 3532, ndId = 3533, triId = 3535, questId = 7027 },
    { name = "Oathsworn Pit",          group = "Scions of Ithelia",    vetId = 3811, hmId = 3812, srId = 3813, ndId = 3814, triId = 3816, questId = 7105 },
    { name = "Bedlam Veil",            group = "Scions of Ithelia",    vetId = 3852, hmId = 3853, srId = 3854, ndId = 3855, triId = 3857, questId = 7155 },
    { name = "Exiled Redoubt",         group = "Fallen Banners",       vetId = 4110, hmId = 4111, srId = 4112, ndId = 4113, triId = 4115, questId = 7235 },
    { name = "Lep Seclusa",            group = "Fallen Banners",       vetId = 4129, hmId = 4130, srId = 4131, ndId = 4132, triId = 4134, questId = 7237 },
    { name = "Naj-Caldeesh",           group = "Feast of Shadows",     vetId = 4312, hmId = 4313, srId = 4314, ndId = 4315, triId = 4317, questId = 7320 },
    { name = "Black Gem Foundry",      group = "Feast of Shadows",     vetId = 4335, hmId = 4336, srId = 4337, ndId = 4338, triId = 4340, questId = 7323 },
}

-- ---------------------------------------------------------------------------
-- Trial definitions (kept for data completeness, not shown in Dungeon Tracker UI)
-- ---------------------------------------------------------------------------
DTT_Data.Trials = {
    { name = "Aetherian Archive",    group = "Craglorn",                    vetId = 1503, hmId = 1137 },
    { name = "Hel Ra Citadel",       group = "Craglorn",                    vetId = 1474, hmId = 1136 },
    { name = "Sanctum Ophidia",      group = "Craglorn",                    vetId = 1462, hmId = 1138 },
    { name = "Maw of Lorkhaj",       group = "Thieves Guild",               vetId = 1368, hmId = 1344 },
    { name = "Halls of Fabrication", group = "Morrowind",                    vetId = 1810, hmId = 1829, triId = 1838 },
    { name = "Asylum Sanctorium",    group = "Clockwork City",               vetId = 2077, hmId = 2079, triId = 2087 },
    { name = "Cloudrest",            group = "Summerset",                    vetId = 2133, hmId = 2136, triId = 2139 },
    { name = "Sunspire",             group = "Elsweyr",                      vetId = 2435, hmId = 2466, triId = 2467 },
    { name = "Kyne's Aegis",         group = "Greymoor",                     vetId = 2734, hmId = 2739, triId = 2740 },
    { name = "Rockgrove",            group = "Blackwood",                    vetId = 2987, hmId = 3007, triId = 3003 },
    { name = "Dreadsail Reef",       group = "High Isle",                    vetId = 3244, hmId = 3252, triId = 3248 },
    { name = "Sanity's Edge",        group = "Necrom",                       vetId = 3560, hmId = 3568, triId = 3564 },
    { name = "Lucent Citadel",       group = "Gold Road",                    vetId = 4015, hmId = 4023, triId = 4019 },
    { name = "Ossein Cage",          group = "Seasons of the Worm Cult",     vetId = 4268, hmId = 4276, triId = 4272 },
}

-- ---------------------------------------------------------------------------
-- Arena definitions (kept for data completeness, not shown in Dungeon Tracker UI)
-- ---------------------------------------------------------------------------
DTT_Data.Arenas = {
    { name = "Dragonstar Arena",     group = "Craglorn",  vetId = 1140 },
    { name = "Maelstrom Arena",      group = "Orsinium",  vetId = 1305, ndId = 1330 },
    { name = "Blackrose Prison",     group = "Murkmire",  vetId = 2363, hmId = 2364, srId = 2366, ndId = 2365, triId = 2368 },
    { name = "Vateshran Hollows",    group = "Markarth",  vetId = 2908, ndId = 2909, srId = 2910, triId = 2912 },
}

-- ---------------------------------------------------------------------------
-- Group ordering
-- ---------------------------------------------------------------------------
DTT_Data.DungeonGroupOrder = {
    "Base Game",
    "Imperial City",
    "Shadows of the Hist",
    "Horns of the Reach",
    "Dragon Bones",
    "Wolfhunter",
    "Wrathstone",
    "Scalebreaker",
    "Harrowstorm",
    "Stonethorn",
    "Flames of Ambition",
    "Waking Flame",
    "Ascending Tide",
    "Lost Depths",
    "Scribes of Fate",
    "Scions of Ithelia",
    "Fallen Banners",
    "Feast of Shadows",
}

DTT_Data.TrialGroupOrder = {
    "Craglorn", "Thieves Guild", "Morrowind", "Clockwork City",
    "Summerset", "Elsweyr", "Greymoor", "Blackwood",
    "High Isle", "Necrom", "Gold Road", "Seasons of the Worm Cult",
}

DTT_Data.ArenaGroupOrder = {
    "Craglorn", "Orsinium", "Murkmire", "Markarth",
}
