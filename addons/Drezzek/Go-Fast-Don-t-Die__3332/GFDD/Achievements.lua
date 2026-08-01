DB = {}

-- Achievement IDs

DB = {

-- Base Game Dungeons

    {NAME = "Fungal Grotto I",      VET=1556, HM = 1561,   SR = 1559,   ND = 1560,  TYPE='baseDungeon'},
    {NAME = "Fungal Grotto II",     VET=343,  HM = 342,    SR = 340,    ND = 1563,  TYPE='baseDungeon'},
    {NAME = "Banished Cells I",     VET=1549, HM = 1554,   SR = 1552,   ND = 1553,  TYPE='baseDungeon'},
    {NAME = "Banished Cells II",    VET=545,  HM = 451,    SR = 449,    ND = 1564,  TYPE='baseDungeon'},
    {NAME = "Elden Hollow I",       VET=1573, HM = 1578,   SR = 1576,   ND = 1577,  TYPE='baseDungeon'},
    {NAME = "Elden Hollow II",      VET=459,  HM = 463,    SR = 461,    ND = 1580,  TYPE='baseDungeon'},
    {NAME = "City of Ash I",        VET=1597, HM = 1602,   SR = 1600,   ND = 1601,  TYPE='baseDungeon'},
    {NAME = "City of Ash II",       VET=878,  HM = 1114,   SR = 1108,   ND = 1107,  TYPE='baseDungeon'},
    {NAME = "Crypt of Hearts I",    VET=1610, HM = 1615,   SR = 1613,   ND = 1614,  TYPE='baseDungeon'},
    {NAME = "Crypt of Hearts II",   VET=876,  HM = 1084,   SR = 941,    ND = 942 ,  TYPE='baseDungeon'},
    {NAME = "Darkshade Caverns I",  VET=1581, HM = 1586,   SR = 1584,   ND = 1585,  TYPE='baseDungeon'},
    {NAME = "Darkshade Caverns II", VET=464,  HM = 467,    SR = 465,    ND = 1588,  TYPE='baseDungeon'},
    {NAME = "Spindleclutch I",      VET=1565, HM = 1570,   SR = 1568,   ND = 1569,  TYPE='baseDungeon'},
    {NAME = "Spindleclutch II",     VET=421,  HM = 448,    SR = 446,    ND = 1572,  TYPE='baseDungeon'},
    {NAME = "Wayrest Sewers I",     VET=1589, HM = 1594,   SR = 1592,   ND = 1593,  TYPE='baseDungeon'},
    {NAME = "Wayrest Sewers II",    VET=678,  HM = 681,    SR = 679,    ND = 1596,  TYPE='baseDungeon'},
    {NAME = "Arx Corinium",         VET=1604, HM = 1609,   SR = 1607,   ND = 1608,  TYPE='baseDungeon'},
    {NAME = "Blackheart Haven",     VET=1647, HM = 1652,   SR = 1650,   ND = 1651,  TYPE='baseDungeon'},
    {NAME = "Blessed Crucible",     VET=1641, HM = 1646,   SR = 1644,   ND = 1645,  TYPE='baseDungeon'},
    {NAME = "Direfrost Keep",       VET=1623, HM = 1628,   SR = 1626,   ND = 1627,  TYPE='baseDungeon'},
    {NAME = "Selene's Web",         VET=1635, HM = 1640,   SR = 1638,   ND = 1639,  TYPE='baseDungeon'},
    {NAME = "Tempest Island",       VET=1617, HM = 1622,   SR = 1620,   ND = 1621,  TYPE='baseDungeon'},
    {NAME = "Vaults of Madness",    VET=1653, HM = 1658,   SR = 1656,   ND = 1657,  TYPE='baseDungeon'},
    {NAME = "Volenfell",            VET=1629, HM = 1634,   SR = 1632,   ND = 1633,  TYPE='baseDungeon'},

-- DLC Dungeons

    {NAME = "White Gold Tower",     VET = 1120,  CHA = nil,  HM = 1279, SR = 1275, ND = 1276, TRI = nil , TYPE="dungeon"},
    {NAME = "Imperial City Prison", VET = 880,   CHA = 1132, HM = 1303, SR = 1128, ND = 1129, TRI = nil , TYPE="dungeon"},
    {NAME = "Ruins of Mazzatun",    VET = 1505,  CHA = 1511, HM = 1506, SR = 1507, ND = 1508, TRI = nil , TYPE="dungeon"},
    {NAME = "Cradle of Shadows",    VET = 1523,  CHA = 1529, HM = 1524, SR = 1525, ND = 1526, TRI = nil , TYPE="dungeon"},
    {NAME = "Falkreath Hold",       VET = 1699,  CHA = 1942, HM = 1704, SR = 1702, ND = 1703, TRI = nil , TYPE="dungeon"},
    {NAME = "Bloodroot Forge",      VET = 1691,  CHA = 1941, HM = 1696, SR = 1694, ND = 1695, TRI = nil , TYPE="dungeon"},
    {NAME = "Fang Lair",            VET = 1960,  CHA = 1966, HM = 1965, SR = 1963, ND = 1964, TRI = 2102, TYPE="dungeon"},
    {NAME = "Scalecaller Peak",     VET = 1976,  CHA = 1982, HM = 1981, SR = 1979, ND = 1980, TRI = 1983, TYPE="dungeon"},
    {NAME = "Moon Hunter Keep",     VET = 2153,  CHA = 2158, HM = 2154, SR = 2155, ND = 2156, TRI = 2159, TYPE="dungeon"},
    {NAME = "March of Sacrifices",  VET = 2163,  CHA = 2167, HM = 2164, SR = 2165, ND = 2166, TRI = 2168, TYPE="dungeon"},
    {NAME = "Frostvault",           VET = 2261,  CHA = 2266, HM = 2262, SR = 2263, ND = 2264, TRI = 2267, TYPE="dungeon"},
    {NAME = "Depths of Malatar",    VET = 2271,  CHA = 2275, HM = 2272, SR = 2273, ND = 2274, TRI = 2276, TYPE="dungeon"},
    {NAME = "Lair of Maarselok",    VET = 2426,  CHA = 2430, HM = 2427, SR = 2428, ND = 2429, TRI = 2431, TYPE="dungeon"},
    {NAME = "Moongrave Fane",       VET = 2416,  CHA = 2421, HM = 2417, SR = 2418, ND = 2419, TRI = 2422, TYPE="dungeon"},
    {NAME = "Icereach",             VET = 2540,  CHA = 2545, HM = 2541, SR = 2542, ND = 2543, TRI = 2546, TYPE="dungeon"},
    {NAME = "Unhallowed Grave",     VET = 2550,  CHA = 2554, HM = 2551, SR = 2552, ND = 2553, TRI = 2555, TYPE="dungeon"},
    {NAME = "Stone Garden",         VET = 2695,  CHA = 2700, HM = 2755, SR = 2697, ND = 2698, TRI = 2701, TYPE="dungeon"},
    {NAME = "Castle Thorn",         VET = 2705,  CHA = 2709, HM = 2706, SR = 2707, ND = 2708, TRI = 2710, TYPE="dungeon"},
    {NAME = "Black Drake Villa",    VET = 2832,  CHA = 2837, HM = 2833, SR = 2834, ND = 2835, TRI = 2838, TYPE="dungeon"},
    {NAME = "The Cauldron",         VET = 2842,  CHA = 2846, HM = 2843, SR = 2844, ND = 2845, TRI = 2847, TYPE="dungeon"},
    {NAME = "Red Petal Bastion",    VET = 3017,  CHA = 3022, HM = 3018, SR = 3019, ND = 3020, TRI = 3023, TYPE="dungeon"},
    {NAME = "Dread Cellar",         VET = 3027,  CHA = 3031, HM = 3028, SR = 3029, ND = 3030, TRI = 3032, TYPE="dungeon"},
    {NAME = "Coral Aerie",          VET = 3105,  CHA = 3110, HM = 3153, SR = 3107, ND = 3108, TRI = 3111, TYPE="dungeon"},
    {NAME = "Shipwright's Regret",  VET = 3115,  CHA = 3119, HM = 3154, SR = 3117, ND = 3118, TRI = 3120, TYPE="dungeon"},    
    {NAME = "Earthen Root Enclave", VET = 3376,  CHA = 3380, HM = 3377, SR = 3378, ND = 3379, TRI = 3381, TYPE="dungeon"},
    {NAME = "Graven Deep",          VET = 3395,  CHA = 3399, HM = 3396, SR = 3397, ND = 3398, TRI = 3400, TYPE="dungeon"},
    {NAME = "Bal Sunnar",           VET = 3469,  CHA = 3473, HM = 3470, SR = 3471, ND = 3472, TRI = 3474, TYPE="dungeon"},
    {NAME = "Scrivener's Hall",     VET = 3530,  CHA = 3534, HM = 3531, SR = 3532, ND = 3533, TRI = 3535, TYPE="dungeon"},

} 


--[[ New or unused Dungeons

    {NAME = "Blackrose Prison",     VET = 2363,  CHA = nil,  HM = 2364, SR = 2366, ND = 2365, TRI = 2368, TYPE="dungeon"},

--]]

