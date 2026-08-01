local DTAddon = _G['DTAddon']

DTAddon.DungeonIndex = {
-- vII = ID (in [] to left) of alt version if dungeon has two versions
-- nA = Full normal mode dungeon clear achievement ID
-- vA = Full veteran mode dungeon clear achievement ID
-- hM = Hard mode achievement
-- tT = Time trial achievement
-- nD = No death achievement
-- fP = Faction dungeon completion achievement ID
-- questID = quest ID of the skillpoint quest for this dungeon
---------------------------------------------------------------------------

-- Dungeons
[192]	= {vII = 0,		nA = 272,	vA = 1604,	fP = 1073,	hM = 1609,	tT = 1607,	nD = 1608,	questID = 4202,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Arx Corinium (Force of Nature)
[531]	= {vII = 0,		nA = 3468,	vA = 3469,	fP = 0,		hM = 3470,	tT = 3471,	nD = 3472,	questID = 6896,	icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_scrollicon.dds|t"},			-- Bal Sunnar (Unstuck From Time)
[194]	= {vII = 262,	nA = 325,	vA = 1549,	fP = 1075,	hM = 1554,	tT = 1552,	nD = 1553,	questID = 4107,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Banished Cells I (Banishing the Banished)
[262]	= {vII = 194,	nA = 1555,	vA = 545,	fP = 1075,	hM = 451,	tT = 449,	nD = 1564,	questID = 4597,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Banished Cells II (The Plan)
[565]	= {vII = 0,		nA = 3851,	vA = 3852,	fP = 0,		hM = 3853,	tT = 3854,	nD = 3855,	questID = 7155,	icon = "|t24:24:/DungeonTracker/bin/daedric.dds|t"},								-- Bedlam Veil (The Forgotten Vault)
[186]	= {vII = 0,		nA = 410,	vA = 1647,	fP = 1074,	hM = 1652,	tT = 1650,	nD = 1651,	questID = 4589,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Blackheart Haven (Jumping Ship)
[437]	= {vII = 0,		nA = 2831,	vA = 2832,	fP = 0,		hM = 2833,	tT = 2834,	nD = 2835,	questID = 6576,	icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds|t"},	-- Black Drake Villa (Burning Secrets)
[187]	= {vII = 0,		nA = 393,	vA = 1641,	fP = 1073,	hM = 1646,	tT = 1644,	nD = 1645,	questID = 4469,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Blessed Crucible (Fires of Battle)
[326]	= {vII = 0,		nA = 1690,	vA = 1691,	fP = 0,		hM = 1696,	tT = 1694,	nD = 1695,	questID = 5889,	icon = "|t24:24:/DungeonTracker/bin/minotaur.dds|t"},								-- Bloodroot Forge (Blood for Blood)
[436]	= {vII = 0,		nA = 2704,	vA = 2705,	fP = 0,		hM = 2706,	tT = 2707,	nD = 2708,	questID = 6507,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Castle Thorn (Blood of the Past)
[197]	= {vII = 268,	nA = 551,	vA = 1597,	fP = 1075,	hM = 1602,	tT = 1600,	nD = 1601,	questID = 4778,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- City of Ash I (Razor's Edge)
[268]	= {vII = 197,	nA = 1603,	vA = 878,	fP = 1075,	hM = 1114,	tT = 1108,	nD = 1107,	questID = 5120,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- City of Ash II (Return to Ash)
[497]	= {vII = 0,		nA = 3104,	vA = 3105,	fP = 0,		hM = 3226,	tT = 3107,	nD = 3108,	questID = 6740,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Coral Aerie (An Order Gone Awry)
[261]	= {vII = 0,		nA = 1522,	vA = 1523,	fP = 0,		hM = 1524,	tT = 1525,	nD = 1526,	questID = 5702,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Cradle of Shadows (Silk and Shadow)
[190]	= {vII = 269,	nA = 80,	vA = 1610,	fP = 1074,	hM = 1615,	tT = 1613,	nD = 1614,	questID = 4379,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Crypt of Hearts I (Lover's Torment)
[269]	= {vII = 190,	nA = 1616,	vA = 876,	fP = 1074,	hM = 1084,	tT = 941,	nD = 942,	questID = 5113,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Crypt of Hearts II (Edge of Darkness)
[198]	= {vII = 264,	nA = 78,	vA = 1581,	fP = 1073,	hM = 1586,	tT = 1584,	nD = 1585,	questID = 4145,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Darkshade Caverns I (Mine All Mine)
[264]	= {vII = 198,	nA = 1587,	vA = 464,	fP = 1073,	hM = 467,	tT = 465,	nD = 1588,	questID = 4641,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Darkshade Caverns II (What Was Lost)
[390]	= {vII = 0,		nA = 2270,	vA = 2271,	fP = 0,		hM = 2272,	tT = 2273,	nD = 2274,	questID = 6251,	icon = "|t24:24:/DungeonTracker/bin/wrathstone.dds|t"},								-- Depths of Malatar (The Guiding Light)
[195]	= {vII = 0,		nA = 357,	vA = 1623,	fP = 1073,	hM = 1628,	tT = 1626,	nD = 1627,	questID = 4346,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Direfrost Keep (Nobles' Rest)
[520]	= {vII = 0,		nA = 3375,	vA = 3376,	fP = 0,		hM = 3377,	tT = 3378,	nD = 3379,	questID = 6835,	icon = "|t24:24:/DungeonTracker/bin/lostdepths.dds|t"},								-- Earthen Root Enclave (The Stonelore Defense)
[191]	= {vII = 265,	nA = 11,	vA = 1573,	fP = 1075,	hM = 1578,	tT = 1576,	nD = 1577,	questID = 4336,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Elden Hollow I (Ancient Remains)
[265]	= {vII = 191,	nA = 1579,	vA = 459,	fP = 1075,	hM = 463,	tT = 461,	nD = 1580,	questID = 4675,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Elden Hollow II (Consuming Darkness)
[581]   = {vII = 0,     nA = 4109,  vA = 4110,  fP = 0,     hM = 4111,  tT = 4112,  nD = 4113,  questID = 7235, icon = "|t24:24:/DungeonTracker/bin/daedric.dds|t"},                                -- Exiled Redoubt (Undying Requiem)
[332]	= {vII = 0,		nA = 1698,	vA = 1699,	fP = 0,		hM = 1704,	tT = 1702,	nD = 1703,	questID = 5891,	icon = "|t24:24:/DungeonTracker/bin/minotaur.dds|t"},								-- Falkreath Hold (Falkreath's Demise)
[341]	= {vII = 0,		nA = 1959,	vA = 1960,	fP = 0,		hM = 1965,	tT = 1963,	nD = 1964,	questID = 6064,	icon = "|t24:24:/DungeonTracker/bin/dbones.dds|t"},									-- Fang Lair (Casting the Bones)
[389]	= {vII = 0,		nA = 2260,	vA = 2261,	fP = 0,		hM = 2262,	tT = 2263,	nD = 2264,	questID = 6249,	icon = "|t24:24:/DungeonTracker/bin/wrathstone.dds|t"},								-- Frostvault (Lock and Keystone)
[98]	= {vII = 266,	nA = 294,	vA = 1556,	fP = 1073,	hM = 1561,	tT = 1559,	nD = 1560,	questID = 3993,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Fungal Grotto I (Kings of the Grotto)
[266]	= {vII = 98,	nA = 1562,	vA = 343,	fP = 1073,	hM = 342,	tT = 340,	nD = 1563,	questID = 4303,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Fungal Grotto II (Lighting the Shadows)
[521]	= {vII = 0,		nA = 3394,	vA = 3395,	fP = 0,		hM = 3396,	tT = 3397,	nD = 3398,	questID = 6837,	icon = "|t24:24:/DungeonTracker/bin/lostdepths.dds|t"},								-- Graven Deep (Haunted Depths)
[424]	= {vII = 0,		nA = 2539,	vA = 2540,	fP = 0,		hM = 2541,	tT = 2542,	nD = 2543,	questID = 6414,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Icereach (The Frozen Isle)
[236]	= {vII = 0,		nA = 1345,	vA = 880,	fP = 0,		hM = 1303,	tT = 1128,	nD = 1129,	questID = 5136,	icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds|t"},	-- Imperial City Prison (Summary Execution)
[398]	= {vII = 0,		nA = 2425,	vA = 2426,	fP = 0,		hM = 2427,	tT = 2428,	nD = 2429,	questID = 6351,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Lair of Maarselok (The Azure Blight)
[582]   = {vII = 0,     nA = 4128,  vA = 4129,  fP = 0,     hM = 4130,  tT = 4131,  nD = 4132,  questID = 7237, icon = "|t24:24:/DungeonTracker/bin/daedric.dds|t"},                                -- Lep Seclusa (Upstart Emperor)
[370]	= {vII = 0,		nA = 2162,	vA = 2163,	fP = 0,		hM = 2164,	tT = 2165,	nD = 2166,	questID = 6188,	icon = "|t24:24:/DungeonTracker/bin/wolfhunter.dds|t"},								-- March of Sacrifices (The Great Hunt)
[391]	= {vII = 0,		nA = 2415,	vA = 2416,	fP = 0,		hM = 2417,	tT = 2418,	nD = 2419,	questID = 6349,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Moongrave Fane (The Sanguine Successor)
[371]	= {vII = 0,		nA = 2152,	vA = 2153,	fP = 0,		hM = 2154,	tT = 2155,	nD = 2156,	questID = 6186,	icon = "|t24:24:/DungeonTracker/bin/wolfhunter.dds|t"},								-- Moon Hunter Keep (Moonlight Ascent)
[556]	= {vII = 0,		nA = 3810,	vA = 3811,	fP = 0,		hM = 3812,	tT = 3813,	nD = 3814,	questID = 7105,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Oathsworn Pit (Victory Through Strife)
[470]	= {vII = 0,		nA = 3016,	vA = 3017,	fP = 0,		hM = 3018,	tT = 3019,	nD = 3020,	questID = 6683,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Red Petal Bastion (A Rose of Many Thorns)
[260]	= {vII = 0,		nA = 1504,	vA = 1505,	fP = 0,		hM = 1506,	tT = 1507,	nD = 1508,	questID = 5403,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Ruins of Mazzatun (Sap and Stone)
[363]	= {vII = 0,		nA = 1975,	vA = 1976,	fP = 0,		hM = 1981,	tT = 1979,	nD = 1980,	questID = 6065,	icon = "|t24:24:/DungeonTracker/bin/dbones.dds|t"},									-- Scalecaller Peak (Plans of Pestilence)
[532]	= {vII = 0,		nA = 3529,	vA = 3530,	fP = 0,		hM = 3531,	tT = 3532,	nD = 3533,	questID = 7027,	icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_scrollicon.dds|t"},			-- Scrivener's Hall (A War of Scribes)
[185]	= {vII = 0,		nA = 417,	vA = 1635,	fP = 1075,	hM = 1640,	tT = 1638,	nD = 1639,	questID = 4733,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Selene's Web (Knowledge Gained)
[498]	= {vII = 0,		nA = 3114,	vA = 3115,	fP = 0,		hM = 3224,	tT = 3117,	nD = 3118,	questID = 6742,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Shipwright's Regret (Wright of Passage)
[193]	= {vII = 267,	nA = 301,	vA = 1565,	fP = 1074,	hM = 1570,	tT = 1568,	nD = 1569,	questID = 4054,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Spindleclutch I (Deadly Whispers)
[267]	= {vII = 193,	nA = 1571,	vA = 421,	fP = 1074,	hM = 448,	tT = 446,	nD = 1572,	questID = 4555,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Spindleclutch II (Blood Relations)
[435]	= {vII = 0,		nA = 2694,	vA = 2695,	fP = 0,		hM = 2755,	tT = 2697,	nD = 2698,	questID = 6505,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Stone Garden (Method and Madness)
[188]	= {vII = 0,		nA = 81,	vA = 1617,	fP = 1075,	hM = 1622,	tT = 1620,	nD = 1621,	questID = 4538,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Tempest Island (Eye of the Storm)
[454]	= {vII = 0,		nA = 2841,	vA = 2842,	fP = 0,		hM = 2843,	tT = 2844,	nD = 2845,	questID = 6578,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- The Cauldron (Into the Deep)
[469]	= {vII = 0,		nA = 3026,	vA = 3027,	fP = 0,		hM = 3028,	tT = 3029,	nD = 3030,	questID = 6685,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- The Dread Cellar (Quaking Dread)
[425]	= {vII = 0,		nA = 2549,	vA = 2550,	fP = 0,		hM = 2551,	tT = 2552,	nD = 2553,	questID = 6416,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Unhallowed Grave (Unhallowed Grave)
[184]	= {vII = 0,		nA = 570,	vA = 1653,	fP = 0,		hM = 1658,	tT = 1656,	nD = 1657,	questID = 4822,	icon = "|t34:34:/esoui/art/journal/gamepad/gp_questtypeicon_mainstory.dds|t"},		-- Vaults of Madness (Mind of Madness)
[196]	= {vII = 0,		nA = 391,	vA = 1629,	fP = 1074,	hM = 1634,	tT = 1632,	nD = 1633,	questID = 4432,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Volenfell (Blood and Sand)
[189]	= {vII = 263,	nA = 79,	vA = 1589,	fP = 1074,	hM = 1594,	tT = 1592,	nD = 1593,	questID = 4246,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Wayrest Sewers I (Deception in the Dark)
[263]	= {vII = 189,	nA = 1595,	vA = 678,	fP = 1074,	hM = 681,	tT = 679,	nD = 1596,	questID = 4813,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},			-- Wayrest Sewers II (No Second Chances)
[247]	= {vII = 0,		nA = 1346,	vA = 1120,	fP = 0,		hM = 1279,	tT = 1275,	nD = 1276,	questID = 5342,	icon = "|t48:48:/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds|t"},	-- White-Gold Tower (Planemeld Obverse)
-- Trials
[231]	= {vII = 0,		nA = 990,	vA = 1503,	fP = 0,		hM = 1137,	tT = 1081,	nD = 0,		questID = 0,	icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Aetherian Archive
[346]	= {vII = 0,		nA = 2076,	vA = 2077,	fP = 0,		hM = 2079,	tT = 2081,	nD = 2080,	questID = 0,	icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Asylum Sanctorium
[364]	= {vII = 0,		nA = 2131,	vA = 2133,	fP = 0,		hM = 2136,	tT = 2137,	nD = 2138,	questID = 0,	icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Cloudrest
[488]	= {vII = 0,		nA = 3242,	vA = 3244,	fP = 0,		hM = 3252,	tT = 3243,	nD = 3245,	questID = 0,	icon = "|t24:24:/DungeonTracker/bin/lostdepths.dds|t"},								-- Dreadsail Reef
[331]	= {vII = 0,		nA = 1808,	vA = 1810,	fP = 0,		hM = 1829,	tT = 1809,	nD = 1811,	questID = 0,	icon = "|t24:24:/DungeonTracker/bin/ashlander.dds|t"},								-- Halls of Fabrication
[230]	= {vII = 0,		nA = 991,	vA = 1474,	fP = 0,		hM = 1136,	tT = 1080,	nD = 0,		questID = 0,	icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Hel Ra Citadel
[258]	= {vII = 0,		nA = 1343,	vA = 1368,	fP = 0,		hM = 1344,	tT = 1367,	nD = 1392,	questID = 0,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Maw of Lorkhaj
[232]	= {vII = 0,		nA = 1123,	vA = 1462,	fP = 0,		hM = 1138,	tT = 1124,	nD = 0,		questID = 0,	icon = "|t48:48:/esoui/art/tutorial/ava_rankicon64_overlord.dds|t"},				-- Sanctum Ophidia
[399]	= {vII = 0,		nA = 2433,	vA = 2435,	fP = 0,		hM = 2466,	tT = 2434,	nD = 2436,	questID = 0,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},				-- Sunspire
[434]	= {vII = 0,		nA = 2732,	vA = 2734,	fP = 0,		hM = 2739,	tT = 2733,	nD = 2735,	questID = 0,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Kyne's Aegis
[468]	= {vII = 0,		nA = 2985,	vA = 2987,	fP = 0,		hM = 3007,	tT = 2986,	nD = 2988,	questID = 0,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},			-- Rockgrove (Trial)
[534]	= {vII = 0,		nA = 3558,	vA = 3560,	fP = 0,		hM = 3568,	tT = 3559,	nD = 3561,	questID = 0,	icon = "|t24:24:/DungeonTracker/bin/ashlander.dds|t"},								-- Sanity’s Edge
-- Arenas
[250]	= {vII = 0,		nA = 1304,	vA = 1305,	fP = 0,		hM = 0,		tT = 0,		nD = 1330,	questID = 0,	icon = "|t24:24:/DungeonTracker/bin/daedric.dds|t"},								-- Maelstrom Arena
[270]	= {vII = 0,		nA = 992,	vA = 1140,	fP = 0,		hM = 0,		tT = 0,		nD = 0,		questID = 0,	icon = "|t24:24:/DungeonTracker/bin/craglorn.dds|t"},								-- Dragonstar Arena
[378]	= {vII = 0,		nA = 2362,	vA = 2363,	fP = 0,		hM = 2364,	tT = 2366,	nD = 2365,	questID = 0,	icon = "|t24:24:/DungeonTracker/bin/argonian.dds|t"},								-- Blackrose Prison
[457]	= {vII = 0,		nA = 2907,	vA = 2908,	fP = 0,		hM = 2911,	tT = 2910,	nD = 2909,	questID = 0,	icon = "|t24:24:/DungeonTracker/bin/bloodroot.dds|t"},								-- Vateshran Hollows
}

DTAddon.DelveIndex = {
-- bA = All delve bosses defeated achievement ID
-- gA = Group challenge skillpoint achievement ID
-- fP = Faction delve completion achievement ID
-- key is concatenation of pin:GetPOIZoneIndex() and pin:GetPOIIndex() for poi pins
["2-41"]	= {bA = 1053,	gA = 380,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Bad Man's Hallows
["4-21"]	= {bA = 1054,	gA = 714,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Bonesnap Ruins
["11-37"]	= {bA = 1051,	gA = 460,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Crimson Cove
["9-18"]	= {bA = 368,	gA = 379,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Crow's Wood
["10-20"]	= {bA = 370,	gA = 388,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Forgotten Crypts
["469-35"]	= {bA = 1857,	gA = 1855,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/ashlander.dds|t"},							-- Forgotten Wastes
["885-12"]	= {bA = 3282,	gA = 3281,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/lostdepths.dds|t"}, 						-- Ghost Haven Bay
["960-16"]	= {bA = 3660,	gA = 3658,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/ashlander.dds|t"}, 							-- Gorne
["15-37"]	= {bA = 376,	gA = 381,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Hall of the Dead
["618-26"]	= {bA = 2094,	gA = 2096,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/altmer.dds|t"},								-- Karnwasten
["745-12"]	= {bA = 2717,	gA = 2714,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"}, 		-- Labyrinthian
["982-14"]	= {bA = 4001,	gA = 4000,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_imperialdistrict_neutral.dds|t"},		-- Leftwheal Trading Post
["16-31"]	= {bA = 374,	gA = 371,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Lion's Den
["17-28"]	= {bA = 396,	gA = 707,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Lost City of Na-Totambu
["469-34"]	= {bA = 1854,	gA = 1846,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/ashlander.dds|t"},							-- Nchuleftingth
["746-17"]	= {bA = 2718,	gA = 2715,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"}, 		-- Nchuthnkarst
["5-16"]	= {bA = 378,	gA = 713,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Obsidian Scar
["381-2"]	= {bA = 1239,	gA = 1238,	fP = 1257,	icon = "|t48:48:/esoui/art/mappins/ava_imperialdistrict_neutral.dds|t"},		-- Old Orsinium
["683-14"]	= {bA = 2442,	gA = 2445,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"}, 			-- Orcrest
["14-16"]	= {bA = 1055,	gA = 708,	fP = 1070,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_daggerfall.dds|t"},		-- Razak's Wheel
["683-13"]	= {bA = 2440,	gA = 2444,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"}, 			-- Rimmen Necropolis
["381-29"]	= {bA = 1236,	gA = 1235,	fP = 1257,	icon = "|t48:48:/esoui/art/mappins/ava_imperialdistrict_neutral.dds|t"},		-- Rkindaleft
["181-2"]	= {bA = 1049,	gA = 470,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Root Sunder
["18-1"]	= {bA = 1050,	gA = 445,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Rulanyil's Fall
["19-40"]	= {bA = 300,	gA = 372,	fP = 1068,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"},		-- Sanguine's Demesne
["982-13"]	= {bA = 4003,	gA = 4002,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_imperialdistrict_neutral.dds|t"},		-- Silorn
["885-11"]	= {bA = 3284,	gA = 3283,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/lostdepths.dds|t"}, 						-- Spire of the Crimson Coin
["618-25"]	= {bA = 2093,	gA = 2095,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/altmer.dds|t"},								-- Sunhold
["836-32"]	= {bA = 2996,	gA = 2994,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"}, 		-- The Silent Halls
["959-11"]	= {bA = 3659,	gA = 3657,	fP = 0,		icon = "|t24:24:/DungeonTracker/bin/ashlander.dds|t"}, 							-- The Underweave
["179-40"]	= {bA = 390,	gA = 468,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Toothmaul Gully
["180-23"]	= {bA = 1052,	gA = 469,	fP = 1069,	icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_aldmeri.dds|t"},			-- Vile Manse
["155-40"]	= {bA = 1056,	gA = 874,	fP = 0,		icon = "|t34:34:/esoui/art/journal/gamepad/gp_questtypeicon_mainstory.dds|t"},	-- Village of the Lost
["836-19"]	= {bA = 2997,	gA = 2995,	fP = 0,		icon = "|t48:48:/esoui/art/mappins/ava_borderkeep_pin_ebonheart.dds|t"}, 		-- Zenithar's Abbey
}

DTAddon.FinderNormalIndex = {
[8]		=	{svI = 192,		control = nil},		-- Arx Corinium
[613]	=	{svI = 531,		control = nil},		-- Bal Sunnar
[4]		=	{svI = 194,		control = nil},		-- Banished Cells I
[300]	=	{svI = 262,		control = nil},		-- Banished Cells II
[640]	=	{svI = 565,		control = nil},		-- Bedlam Veil
[15]	=	{svI = 186,		control = nil},		-- Blackheart Haven
[591]	=	{svI = 437,		control = nil},		-- Black Drake Villa
[14]	=	{svI = 187,		control = nil},		-- Blessed Crucible
[324]	=	{svI = 326,		control = nil},		-- Bloodroot Forge
[509]	=	{svI = 436,		control = nil},		-- Castle Thorn
[10]	=	{svI = 197,		control = nil},		-- City of Ash I
[322]	=	{svI = 268,		control = nil},		-- City of Ash II
[599]	=	{svI = 497,		control = nil},		-- Coral Aerie
[295]	=	{svI = 261,		control = nil},		-- Cradle of Shadows
[9]		=	{svI = 190,		control = nil},		-- Crypt of Hearts I
[317]	=	{svI = 269,		control = nil},		-- Crypt of Hearts II
[5]		=	{svI = 198,		control = nil},		-- Darkshade Caverns I
[308]	=	{svI = 264,		control = nil},		-- Darkshade Caverns II
[435]	=	{svI = 390,		control = nil},		-- Depths of Malatar
[11]	=	{svI = 195,		control = nil},		-- Direfrost Keep
[608]	=	{svI = 520,		control = nil},		-- Earthen Root Enclave
[7]		=	{svI = 191,		control = nil},		-- Elden Hollow I
[303]	=	{svI = 265,		control = nil},		-- Elden Hollow II
[855]	=	{svI = 581,		control = nil},		-- Exiled Redoubt
[368]	=	{svI = 332,		control = nil},		-- Falkreath Hold
[420]	=	{svI = 341,		control = nil},		-- Fang Lair
[433]	=	{svI = 389,		control = nil},		-- Frostvault
[2]		=	{svI = 98,		control = nil},		-- Fungal Grotto I
[18]	=	{svI = 266,		control = nil},		-- Fungal Grotto II
[610]	=	{svI = 521,		control = nil},		-- Graven Deep
[503]	=	{svI = 424,		control = nil},		-- Icereach
[289]	=	{svI = 236,		control = nil},		-- Imperial City Prison
[496]	=	{svI = 398,		control = nil},		-- Lair of Maarselok
[857]	=	{svI = 582,		control = nil},		-- Lep Seclusa
[428]	=	{svI = 370,		control = nil},		-- March of Sacrifices
[494]	=	{svI = 391,		control = nil},		-- Moongrave Fane
[426]	=	{svI = 371,		control = nil},		-- Moon Hunter Keep
[638]	=	{svI = 556,		control = nil},		-- Oathsworn Pit
[595]	=	{svI = 470,		control = nil},		-- Red Petal Bastion
[293]	=	{svI = 260,		control = nil},		-- Ruins of Mazzatun
[418]	=	{svI = 363,		control = nil},		-- Scalecaller Peak
[615]	=	{svI = 532,		control = nil},		-- Scrivener's Hall
[16]	=	{svI = 185,		control = nil},		-- Selene's Web
[601]	=	{svI = 498,		control = nil},		-- Shipwright's Regret
[3]		=	{svI = 193,		control = nil},		-- Spindleclutch I
[316]	=	{svI = 267,		control = nil},		-- Spindleclutch II
[507]	=	{svI = 435,		control = nil},		-- Stone Garden
[13]	=	{svI = 188,		control = nil},		-- Tempest Island
[593]	=	{svI = 454,		control = nil},		-- The Cauldron
[597]	=	{svI = 469,		control = nil},		-- The Dread Cellar
[505]	=	{svI = 425,		control = nil},		-- Unhallowed Grave
[17]	=	{svI = 184,		control = nil},		-- Vaults of Madness
[12]	=	{svI = 196,		control = nil},		-- Volenfell
[6]		=	{svI = 189,		control = nil},		-- Wayrest Sewers I
[22]	=	{svI = 263,		control = nil},		-- Wayrest Sewers II
[288]	=	{svI = 247,		control = nil},		-- White-Gold Tower
}

DTAddon.FinderVeteranIndex = {
[305]	=	{svI = 192,		control = nil},		-- Arx Corinium (Veteran)
[614]	=	{svI = 531,		control = nil},		-- Bal Sunnar (Veteran)
[20]	=	{svI = 194,		control = nil},		-- Banished Cells I (Veteran)
[301]	=	{svI = 262,		control = nil},		-- Banished Cells II (Veteran)
[641]	=	{svI = 565,		control = nil},		-- Bedlam Veil
[321]	=	{svI = 186,		control = nil},		-- Blackheart Haven (Veteran)
[592]	=	{svI = 437,		control = nil},		-- Black Drake Villa (Veteran)
[320]	=	{svI = 187,		control = nil},		-- Blessed Crucible (Veteran)
[325]	=	{svI = 326,		control = nil},		-- Bloodroot Forge (Veteran)
[510]	=	{svI = 436,		control = nil},		-- Castle Thorn (Veteran)
[310]	=	{svI = 197,		control = nil},		-- City of Ash I (Veteran)
[267]	=	{svI = 268,		control = nil},		-- City of Ash II (Veteran)
[600]	=	{svI = 497,		control = nil},		-- Coral Aerie (Veteran)
[296]	=	{svI = 261,		control = nil},		-- Cradle of Shadows (Veteran)
[261]	=	{svI = 190,		control = nil},		-- Crypt of Hearts I (Veteran)
[318]	=	{svI = 269,		control = nil},		-- Crypt of Hearts II (Veteran)
[309]	=	{svI = 198,		control = nil},		-- Darkshade Caverns I (Veteran)
[21]	=	{svI = 264,		control = nil},		-- Darkshade Caverns II (Veteran)
[436]	=	{svI = 390,		control = nil},		-- Depths of Malatar (Veteran)
[319]	=	{svI = 195,		control = nil},		-- Direfrost Keep (Veteran)
[609]	=	{svI = 520,		control = nil},		-- Earthen Root Enclave (Veteran)
[23]	=	{svI = 191,		control = nil},		-- Elden Hollow I (Veteran)
[302]	=	{svI = 265,		control = nil},		-- Elden Hollow II (Veteran)
[856]	=	{svI = 581,		control = nil},		-- Exiled Redoubt (Veteran)
[369]	=	{svI = 332,		control = nil},		-- Falkreath Hold (Veteran)
[421]	=	{svI = 341,		control = nil},		-- Fang Lair (Veteran)
[434]	=	{svI = 389,		control = nil},		-- Frostvault (Veteran)
[299]	=	{svI = 98,		control = nil},		-- Fungal Grotto I (Veteran)
[312]	=	{svI = 266,		control = nil},		-- Fungal Grotto II (Veteran)
[611]	=	{svI = 521,		control = nil},		-- Graven Deep (Veteran)
[504]	=	{svI = 424,		control = nil},		-- Icereach (Veteran)
[268]	=	{svI = 236,		control = nil},		-- Imperial City Prison (Veteran)
[497]	=	{svI = 398,		control = nil},		-- Lair of Maarselok (Veteran)
[858]	=	{svI = 582,		control = nil},		-- Lep Seclusa (Veteran)
[429]	=	{svI = 370,		control = nil},		-- March of Sacrifices (Veteran)
[495]	=	{svI = 391,		control = nil},		-- Moongrave Fane (Veteran)
[427]	=	{svI = 371,		control = nil},		-- Moon Hunter Keep (Veteran)
[639]	=	{svI = 556,		control = nil},		-- Oathsworn Pit (Veteran)
[596]	=	{svI = 470,		control = nil},		-- Red Petal Bastion (Veteran)
[294]	=	{svI = 260,		control = nil},		-- Ruins of Mazzatun (Veteran)
[419]	=	{svI = 363,		control = nil},		-- Scalecaller Peak (Veteran)
[616]	=	{svI = 532,		control = nil},		-- Scrivener's Hall (Veteran)
[313]	=	{svI = 185,		control = nil},		-- Selene's Web (Veteran)
[602]	=	{svI = 498,		control = nil},		-- Shipwright's Regret (Veteran)
[315]	=	{svI = 193,		control = nil},		-- Spindleclutch I (Veteran)
[19]	=	{svI = 267,		control = nil},		-- Spindleclutch II (Veteran)
[508]	=	{svI = 435,		control = nil},		-- Stone Garden (Veteran)
[311]	=	{svI = 188,		control = nil},		-- Tempest Island (Veteran)
[594]	=	{svI = 454,		control = nil},		-- The Cauldron (Veteran)
[598]	=	{svI = 469,		control = nil},		-- The Dread Cellar (Veteran)
[506]	=	{svI = 425,		control = nil},		-- Unhallowed Grave (Veteran)
[314]	=	{svI = 184,		control = nil},		-- Vaults of Madness (Veteran)
[304]	=	{svI = 196,		control = nil},		-- Volenfell (Veteran)
[306]	=	{svI = 189,		control = nil},		-- Wayrest Sewers I (Veteran)
[307]	=	{svI = 263,		control = nil},		-- Wayrest Sewers II (Veteran)
[287]	=	{svI = 247,		control = nil},		-- White-Gold Tower (Veteran)
}

------------------------------------------------------------------------------------------------------------------------------------
-- Helpful info and functions:

--local achievementName, description, points, icon, completed, date, time = GetAchievementInfo(294)
function DTInfo(cat, scat, i)
	local aid = GetAchievementId(cat, scat, i)

	d(aid)
	
	local aName, aDesc, aPoints, aIcon, complete, aDate, aTime = GetAchievementInfo(aid)
	
	d(aName.."\n"..aIcon)
end

--[[

-- use nil for 2nd value to see category base entries

/script DTInfo(18, nil, 1)

/script d("|t24:24:/esoui/art/icons/gear_skyforge_hammer.dds|t")

/script local a=GetAchievementId(5, nil, 21) d(tostring(a)) d(GetAchievementInfo(a))


--/script DTQuestFinder("Undying Requiem")
function DTQuestFinder(fName)
	for i=1, 9000 do
		local qName = GetQuestName(i)
		if qName ~= nil and qName ~= "" then
			if string.find(string.lower(qName), string.lower(fName)) ~= nil then
				d(i)
				d(GetQuestDescription(i)) -- ZOS randomly removed function?
			end
		end
	end
	d("done.")
end
--]]