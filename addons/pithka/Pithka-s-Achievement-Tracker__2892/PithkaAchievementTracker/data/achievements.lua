-- global namspacing
PITHKA = PITHKA or {}
PITHKA.data = PITHKA.data or {}
PITHKA.data.achievements = {}

---------------------------------------------------------------------------------------------------------
-- Achievement Database
---------------------------------------------------------------------------------------------------------

PITHKA.data.achievements = {
    -- Trials
        {NAME="Hel Ra Citadel",       ABBV="HRC", VET=1474, PHM1=nil,  PHM1NAME="",         PHM2=nil,  PHM2NAME="",        HM=1136, HMNAME="Celest. Warrior", TRI=nil,  TRINAME="",                    EXT=nil,  EXTNAME="",                      DLC=false,   LBINDEX=1,   portID= 230,  TYPE="trial", SCORED=true},
        {NAME="Aetherian Archive",    ABBV="AA",  VET=1503, PHM1=nil,  PHM1NAME="",         PHM2=nil,  PHM2NAME="",        HM=1137, HMNAME="Celest. Mage",    TRI=nil,  TRINAME="",                    EXT=nil,  EXTNAME="",                      DLC=false,   LBINDEX=2,   portID= 231,  TYPE="trial", SCORED=true},
        {NAME="Sanctum Ophidia",      ABBV="SO",  VET=1462, PHM1=nil,  PHM1NAME="",         PHM2=nil,  PHM2NAME="",        HM=1138, HMNAME="Celest. Serpent", TRI=nil,  TRINAME="",                    EXT=nil,  EXTNAME="",                      DLC=false,   LBINDEX=3,   portID= 232,  TYPE="trial", SCORED=true},
        {NAME="Maw of Lorkhaj",       ABBV="MOL", VET=1368, PHM1=nil,  PHM1NAME="",         PHM2=nil,  PHM2NAME="",        HM=1344, HMNAME="Rakkhat",         TRI=nil,  TRINAME="",                    EXT=1391, EXTNAME="Dro-m'Athra Destroyer", DLC=true,    LBINDEX=5,   portID= 258,  TYPE="trial", SCORED=true},
        {NAME="Halls of Fabrication", ABBV="HOF", VET=1810, PHM1=nil,  PHM1NAME="",         PHM2=nil,  PHM2NAME="",        HM=1829, HMNAME="Assembly Gen.",   TRI=1838, TRINAME="Tick-Tock Tormentor", EXT=1836, EXTNAME="The Dynamo",            DLC=true,    LBINDEX=7,   portID= 331,  TYPE="trial", SCORED=true},
        {NAME="Asylum Sanctorium",    ABBV="AS",  VET=2077, PHM1=2085, PHM1NAME="+Llothis", PHM2=2086, PHM2NAME="+Felms",  HM=2079, HMNAME="vAS +2",          TRI=2087, TRINAME="Saintly Savior",      EXT=2075, EXTNAME="Immortal Redeemer",     DLC=true,    LBINDEX=8,   portID= 346,  TYPE="trial", SCORED=true},
        {NAME="Cloudrest",            ABBV="CR",  VET=2133, PHM1=2134, PHM1NAME="vCR +1",   PHM2=2135, PHM2NAME="vCR +2",  HM=2136, HMNAME="vCR +3",          TRI=2139, TRINAME="Gryphon Heart",       EXT=2140, EXTNAME="Welkynar Liberator",    DLC=true,    LBINDEX=9,   portID= 364,  TYPE="trial", SCORED=true},    
        {NAME="Sunspire",             ABBV="SS",  VET=2435, PHM1=2469, PHM1NAME="Yolna",    PHM2=2470, PHM2NAME="Lokke",   HM=2466, HMNAME="Nahvi",           TRI=2467, TRINAME="Godslayer",           EXT=2468, EXTNAME="Hand of Alkosh",        DLC=true,    LBINDEX=12,  portID= 399,  TYPE="trial", SCORED=true},
        {NAME="Kyne's Aegis",         ABBV="KA",  VET=2734, PHM1=2736, PHM1NAME="Yandir",   PHM2=2737, PHM2NAME="Vrol",    HM=2739, HMNAME="Falgravn",        TRI=2740, TRINAME="Kyne's Wrath",        EXT=2746, EXTNAME="Dawnbringer",           DLC=true,    LBINDEX=13,  portID= 434,  TYPE="trial", SCORED=true},
        {NAME="Rockgrove",            ABBV="RG",  VET=2987, PHM1=3005, PHM1NAME="Oaxiltso", PHM2=3006, PHM2NAME="Bahsei",  HM=3007, HMNAME="Xalvakka",        TRI=3003, TRINAME="Planesbreaker",       EXT=3004, EXTNAME="Daedric Bane",          DLC=true,    LBINDEX=15,  portID= 468,  TYPE="trial", SCORED=true},
        {NAME="Dreadsail Reef",       ABBV="DSR", VET=3244, PHM1=3250, PHM1NAME="Twins",    PHM2=3251, PHM2NAME="Reef",    HM=3252, HMNAME="Taleria",         TRI=3248, TRINAME="Soul of the Squall",  EXT=3249, EXTNAME="Swashbuckler Supreme",  DLC=true,    LBINDEX=16,  portID= 488,  TYPE="trial", SCORED=true},
        {NAME="Sanity's Edge",        ABBV="SE",  VET=3560, PHM1=3566, PHM1NAME="Yaseyla",  PHM2=3567, PHM2NAME="Twelvane",HM=3568, HMNAME="Ansuul",          TRI=3564, TRINAME="Dream Master",        EXT=3565, EXTNAME="Mindmender",            DLC=true,    LBINDEX=17,  portID= 534,  TYPE="trial", SCORED=true},
        {NAME="Lucent Citadel",       ABBV="LC",  VET=4015, PHM1=4021, PHM1NAME="Count",    PHM2=4022, PHM2NAME="Orphic",  HM=4023, HMNAME="Arcane Knot",     TRI=4019, TRINAME="Unstoppable",         EXT=4020, EXTNAME="Arcane Stabilizer",     DLC=true,    LBINDEX=18,  portID= 568,  TYPE="trial", SCORED=true},
        {NAME="Ossein Cage",          ABBV="OC",  VET=4268, PHM1=4274, PHM1NAME="Shapers",  PHM2=4275, PHM2NAME="Jynorah", HM=4276, HMNAME="Kazpian",         TRI=4272, TRINAME="Misery's Master",     EXT=4273, EXTNAME="Cista Breaker",         DLC=true,    LBINDEX=19,  portID= 589,  TYPE="trial", SCORED=true},
		
		{NAME="Opulent Ordeal",       ABBV="OO",  VET=4517, PHM1=nil,  PHM1NAME="",         PHM2=nil,  PHM2NAME="",        HM=nil,  HMNAME="",                TRI=nil,  TRINAME="",                    EXT=4485, EXTNAME="Pathwalker",            DLC=true,    LBINDEX=20,  portID= nil,  TYPE="trial", SCORED=false},

        -- Infinity Archive
        {NAME="Solo",                 ABBV="EA1",  VET=nil, TRI=nil,  TRINAME=nil,      EXT=nil, EXTNAME=nil,  DLC=true,    IAINDEX=0, portID= 550,  TYPE="endless"}, -- Oct 30, 2023
        {NAME="Duo",                  ABBV="EA2",  VET=nil, TRI=nil,  TRINAME=nil,      EXT=nil, EXTNAME=nil,  DLC=true,    IAINDEX=1, portID= 550,  TYPE="endless"}, -- Oct 30, 2023

    -- Arenas   
        {NAME="Maelstrom Arena",      ABBV="MSA", VET=1305, CHA=nil,  HM=nil,  SR=nil,  ND=nil,  TRI=nil,  TRINAME="",                       EXT=nil,  EXTNAME="",                       vQueue=nil, nQueue=nil, portID=250, TYPE="arena", LBINDEX=6 },
        {NAME="Dragonstar Arena",     ABBV="DSA", VET=1140, CHA=nil,  HM=nil,  SR=nil,  ND=nil,  TRI=nil,  TRINAME="",                       EXT=nil,  EXTNAME="",                       vQueue=nil, nQueue=nil, portID=270, TYPE="arena", LBINDEX=4 },    
        {NAME="Blackrose Prison",     ABBV="BRP", VET=2363, CHA=nil,  HM=2364, SR=2366, ND=2365, TRI=2368, TRINAME="Unchained",              EXT=2372, EXTNAME="A Thrilling Trifecta",   vQueue=nil, nQueue=nil, portID=378, TYPE="arena", LBINDEX=11},        
        {NAME="Vateshran Arena",      ABBV="VSA", VET=2908, CHA=nil,  HM=nil,  SR=nil,  ND=nil,  TRI=2912, TRINAME="Spirit Slayer",          EXT=2913, EXTNAME="Hero of Undying Song",   vQueue=nil, nQueue=nil, portID=457, TYPE="arena", LBINDEX=14},    
    
        -- Trifecta Dungeons
        {NAME="Fang Lair",            ABBV="FL",  VET=1960, CHA=1966, HM=1965, SR=1963, ND=1964, TRI=2102, TRINAME="Leave No Bone Unbroken", EXT=1967, EXTNAME="Minimal Animosity",      vQueue=421, nQueue=420, portID=341, TYPE="triDungeon"},
        {NAME="Scalecaller Peak",     ABBV="SP",  VET=1976, CHA=1982, HM=1981, SR=1979, ND=1980, TRI=1983, TRINAME="Mountain God",           EXT=1991, EXTNAME="Daedric Deflector",      vQueue=419, nQueue=418, portID=363, TYPE="triDungeon"},
        {NAME="Moon Hunter Keep",     ABBV="MHK", VET=2153, CHA=2158, HM=2154, SR=2155, ND=2156, TRI=2159, TRINAME="Pure Lunacy",            EXT=2301, EXTNAME="Strangling Cowardice",   vQueue=427, nQueue=426, portID=371, TYPE="triDungeon"},
        {NAME="March of Sacrifices",  ABBV="MOS", VET=2163, CHA=2167, HM=2164, SR=2165, ND=2166, TRI=2168, TRINAME="Apex Predator",          EXT=2305, EXTNAME="Mist Walker",            vQueue=429, nQueue=428, portID=370, TYPE="triDungeon"},
        {NAME="Frostvault",           ABBV="FV",  VET=2261, CHA=2266, HM=2262, SR=2263, ND=2264, TRI=2267, TRINAME="Relentless Raider",      EXT=2384, EXTNAME="Cold Potato",            vQueue=434, nQueue=433, portID=389, TYPE="triDungeon"},
        {NAME="Depths of Malatar",    ABBV="DOM", VET=2271, CHA=2275, HM=2272, SR=2273, ND=2274, TRI=2276, TRINAME="Depths Defier",          EXT=2395, EXTNAME="Lackluster",             vQueue=436, nQueue=435, portID=390, TYPE="triDungeon"},
        {NAME="Lair of Maarselok",    ABBV="LOM", VET=2426, CHA=2430, HM=2427, SR=2428, ND=2429, TRI=2431, TRINAME="Nature's Wrath",         EXT=2581, EXTNAME="Shagrath's Shield",      vQueue=497, nQueue=496, portID=398, TYPE="triDungeon"},
        {NAME="Moongrave Fane",       ABBV="MF",  VET=2416, CHA=2421, HM=2417, SR=2418, ND=2419, TRI=2422, TRINAME="Defanged the Devourer",  EXT=2575, EXTNAME="Drop the Block",         vQueue=495, nQueue=494, portID=391, TYPE="triDungeon"},
        {NAME="Icereach",             ABBV="IR",  VET=2540, CHA=2545, HM=2541, SR=2542, ND=2543, TRI=2546, TRINAME="Storm Foe",              EXT=2677, EXTNAME="Prodigous Pacification", vQueue=504, nQueue=503, portID=424, TYPE="triDungeon"},
        {NAME="Unhallowed Grave",     ABBV="UG",  VET=2550, CHA=2554, HM=2551, SR=2552, ND=2553, TRI=2555, TRINAME="Bonecaller's Bane",      EXT=2679, EXTNAME="Relentless Dogcatcher",  vQueue=506, nQueue=505, portID=425, TYPE="triDungeon"},
        {NAME="Stone Garden",         ABBV="SG",  VET=2695, CHA=2700, HM=2755, SR=2697, ND=2698, TRI=2701, TRINAME="True Genius",            EXT=2824, EXTNAME="Old Fashioned",          vQueue=508, nQueue=507, portID=435, TYPE="triDungeon"},
        {NAME="Castle Thorn",         ABBV="CT",  VET=2705, CHA=2709, HM=2706, SR=2707, ND=2708, TRI=2710, TRINAME="Bane of Thorns",         EXT=2828, EXTNAME="Guardian Preserved",     vQueue=510, nQueue=509, portID=436, TYPE="triDungeon"},
        {NAME="Black Drake Villa",    ABBV="BDV", VET=2832, CHA=2837, HM=2833, SR=2834, ND=2835, TRI=2838, TRINAME="Ardent Bibliophile",     EXT=2883, EXTNAME="Salley-oop",             vQueue=592, nQueue=591, portID=437, TYPE="triDungeon"},
        {NAME="The Cauldron",         ABBV="TC",  VET=2842, CHA=2846, HM=2843, SR=2844, ND=2845, TRI=2847, TRINAME="Subterranean Smasher",   EXT=2886, EXTNAME="Can't Catch Me",         vQueue=594, nQueue=593, portID=454, TYPE="triDungeon"},
        {NAME="Red Petal Bastion",    ABBV="RPB", VET=3017, CHA=3022, HM=3018, SR=3019, ND=3020, TRI=3023, TRINAME="of the Silver Rose",     EXT=3035, EXTNAME="Terror Billy",           vQueue=596, nQueue=595, portID=470, TYPE="triDungeon"},
        {NAME="Dread Cellar",         ABBV="DC",  VET=3027, CHA=3031, HM=3028, SR=3029, ND=3030, TRI=3032, TRINAME="the Dreaded",            EXT=3042, EXTNAME="Settling Scores",        vQueue=598, nQueue=597, portID=469, TYPE="triDungeon"},    
        {NAME="Coral Aerie",          ABBV="CA",  VET=3105, CHA=3110, HM=3153, SR=3107, ND=3108, TRI=3111, TRINAME="Coral Caretaker",        EXT=3226, EXTNAME="Tentacless Triumph",     vQueue=600, nQueue=599, portID=497, TYPE="triDungeon"},
        {NAME="Shipwright's Regret",  ABBV="SR",  VET=3115, CHA=3119, HM=3154, SR=3117, ND=3118, TRI=3120, TRINAME="Privateer",              EXT=3224, EXTNAME="Sans Spirit Support",    vQueue=602, nQueue=601, portID=498, TYPE="triDungeon"},
        {NAME="Earthen Root Enclave", ABBV="ERE", VET=3376, CHA=3380, HM=3377, SR=3378, ND=3379, TRI=3381, TRINAME="Invaders' Bane",         EXT=3391, EXTNAME="Scourge of Archdruid",   vQueue=609, nQueue=608, portID=520, TYPE="triDungeon"},
        {NAME="Graven Deep",          ABBV="GD",  VET=3395, CHA=3399, HM=3396, SR=3397, ND=3398, TRI=3400, TRINAME="Fist of Tava",           EXT=3410, EXTNAME="Pressure in the Deep",   vQueue=611, nQueue=610, portID=521, TYPE="triDungeon"},
        {NAME="Bal Sunnar",           ABBV="BS",  VET=3469, CHA=3473, HM=3470, SR=3471, ND=3472, TRI=3474, TRINAME="Temporal Tempest",       EXT=3484, EXTNAME="No Time to Waste",       vQueue=614, nQueue=613, portID=531, TYPE="triDungeon"},
        {NAME="Scrivener's Hall",     ABBV="SH",  VET=3530, CHA=3534, HM=3531, SR=3532, ND=3533, TRI=3535, TRINAME="Curator's Champion",     EXT=3538, EXTNAME="Harsh Edit",             vQueue=616, nQueue=615, portID=532, TYPE="triDungeon"},
        {NAME="Oathsworn Pit",        ABBV="OP",  VET=3811, CHA=3815, HM=3812, SR=3813, ND=3814, TRI=3816, TRINAME="Oathsworn",              EXT=3826, EXTNAME="Dogged Avenger",         vQueue=639, nQueue=617, portID=556, TYPE="triDungeon"},
        {NAME="Bedlam Veil",          ABBV="BV",  VET=3852, CHA=3856, HM=3853, SR=3854, ND=3855, TRI=3857, TRINAME="Bedlam's Disciple",      EXT=3867, EXTNAME="Martial Gift",           vQueue=641, nQueue=619, portID=565, TYPE="triDungeon"},
        {NAME="Exiled Redoubt",       ABBV="ER",  VET=4110, CHA=4114, HM=4111, SR=4112, ND=4113, TRI=4115, TRINAME="Revenge Breaker",        EXT=4120, EXTNAME="Exposed to the Elements",vQueue=856, nQueue=855, portID=581, TYPE="triDungeon"},
        {NAME="Lep Seclusa",          ABBV="LS",  VET=4129, CHA=4133, HM=4130, SR=4131, ND=4132, TRI=4134, TRINAME="Sic Semper",             EXT=4139, EXTNAME="Fight the Darkness",     vQueue=858, nQueue=857, portID=582, TYPE="triDungeon"},
		{NAME="Naj-Caldeesh",          ABBV="NC",  VET=4312, CHA=4316, HM=4313, SR=4314, ND=4315, TRI=4317, TRINAME="Key to the Stone",             EXT=4327, EXTNAME="No Time To Explore",     vQueue=1038, nQueue=1037, portID=606, TYPE="triDungeon"},
		{NAME="Black Gem Foundry",          ABBV="BGF",  VET=4335, CHA=4339, HM=4336, SR=4337, ND=4338, TRI=4340, TRINAME="Cut Above The Rest",             EXT=4350, EXTNAME="Entry-Level Position",     vQueue=1040, nQueue=1039, portID=605, TYPE="triDungeon"},

        -- Dungeons without Trifectas    
        {NAME = "Fungal Grotto I",      ABBV="FG1", VET=1556, HM = 1561, SR = 1559, ND = 1560, vQueue=299, nQueue=2,   portID=98,  TYPE="baseDungeon-wI"},
        {NAME = "Fungal Grotto II",     ABBV="FG2", VET=343,  HM = 342,  SR = 340,  ND = 1563, vQueue=312, nQueue=18,  portID=266, TYPE="baseDungeon-wI"},
        {NAME = "Banished Cells I",     ABBV="BC1", VET=1549, HM = 1554, SR = 1552, ND = 1553, vQueue=20,  nQueue=4,   portID=194, TYPE="baseDungeon-wI"},
        {NAME = "Banished Cells II",    ABBV="BC2", VET=545,  HM = 451,  SR = 449,  ND = 1564, vQueue=301, nQueue=300, portID=262, TYPE="baseDungeon-wI"},
        {NAME = "Elden Hollow I",       ABBV="EH1", VET=1573, HM = 1578, SR = 1576, ND = 1577, vQueue=23,  nQueue=7,   portID=191, TYPE="baseDungeon-wI"},
        {NAME = "Elden Hollow II",      ABBV="EH2", VET=459,  HM = 463,  SR = 461,  ND = 1580, vQueue=302, nQueue=303, portID=265, TYPE="baseDungeon-wI"},
        {NAME = "City of Ash I",        ABBV="COA1",VET=1597, HM = 1602, SR = 1600, ND = 1601, vQueue=310, nQueue=10,  portID=197, TYPE="baseDungeon-wI"},
        {NAME = "City of Ash II",       ABBV="COA2",VET=878,  HM = 1114, SR = 1108, ND = 1107, vQueue=267, nQueue=322, portID=268, TYPE="baseDungeon-wI"},
        {NAME = "Crypt of Hearts I",    ABBV="COH1",VET=1610, HM = 1615, SR = 1613, ND = 1614, vQueue=261, nQueue=9,   portID=190, TYPE="baseDungeon-wI"},
        {NAME = "Crypt of Hearts II",   ABBV="COH2",VET=876,  HM = 1084, SR = 941,  ND = 942 , vQueue=318, nQueue=317, portID=269, TYPE="baseDungeon-wI"},
        {NAME = "Darkshade Caverns I",  ABBV="DC1", VET=1581, HM = 1586, SR = 1584, ND = 1585, vQueue=309, nQueue=5,   portID=198, TYPE="baseDungeon-wI"},
        {NAME = "Darkshade Caverns II", ABBV="DC2", VET=464,  HM = 467,  SR = 465,  ND = 1588, vQueue=21,  nQueue=308, portID=264, TYPE="baseDungeon-wI"},
        {NAME = "Spindleclutch I",      ABBV="SC1", VET=1565, HM = 1570, SR = 1568, ND = 1569, vQueue=315, nQueue=3,   portID=193, TYPE="baseDungeon-wI"},
        {NAME = "Spindleclutch II",     ABBV="SC2", VET=421,  HM = 448,  SR = 446,  ND = 1572, vQueue=19,  nQueue=316, portID=267, TYPE="baseDungeon-wI"},
        {NAME = "Wayrest Sewers I",     ABBV="WS1", VET=1589, HM = 1594, SR = 1592, ND = 1593, vQueue=306, nQueue=6,   portID=189, TYPE="baseDungeon-wI"},
        {NAME = "Wayrest Sewers II",    ABBV="WS2", VET=678,  HM = 681,  SR = 679,  ND = 1596, vQueue=307, nQueue=22,  portID=263, TYPE="baseDungeon-wI"},
        {NAME = "Arx Corinium",         ABBV="AC",  VET=1604, HM = 1609, SR = 1607, ND = 1608, vQueue=305, nQueue=8,   portID=192, TYPE="baseDungeon-noI"},
        {NAME = "Blackheart Haven",     ABBV="BH",  VET=1647, HM = 1652, SR = 1650, ND = 1651, vQueue=321, nQueue=15,  portID=186, TYPE="baseDungeon-noI"},
        {NAME = "Blessed Crucible",     ABBV="BC",  VET=1641, HM = 1646, SR = 1644, ND = 1645, vQueue=320, nQueue=14,  portID=187, TYPE="baseDungeon-noI"},
        {NAME = "Direfrost Keep",       ABBV="DK",  VET=1623, HM = 1628, SR = 1626, ND = 1627, vQueue=319, nQueue=11,  portID=195, TYPE="baseDungeon-noI"},
        {NAME = "Selene's Web",         ABBV="SW",  VET=1635, HM = 1640, SR = 1638, ND = 1639, vQueue=313, nQueue=16,  portID=185, TYPE="baseDungeon-noI"},
        {NAME = "Tempest Island",       ABBV="TI",  VET=1617, HM = 1622, SR = 1620, ND = 1621, vQueue=311, nQueue=13,  portID=188, TYPE="baseDungeon-noI"},
        {NAME = "Vaults of Madness",    ABBV="VOM", VET=1653, HM = 1658, SR = 1656, ND = 1657, vQueue=314, nQueue=17,  portID=184, TYPE="baseDungeon-noI"},
        {NAME = "Volenfell",            ABBV="VOL", VET=1629, HM = 1634, SR = 1632, ND = 1633, vQueue=304, nQueue=12,  portID=196, TYPE="baseDungeon-noI"},
        {NAME = "White Gold Tower",     ABBV="WGT", VET=1120, HM = 1279, SR = 1275, ND = 1276, vQueue=287, nQueue=288, portID=247, TYPE="baseDungeon-noI"},
        {NAME = "Imperial City Prison", ABBV="ICP", VET=880,  HM = 1303, SR = 1128, ND = 1129, vQueue=268, nQueue=289, portID=236, TYPE="baseDungeon-noI"},
        {NAME = "Ruins of Mazzatun",    ABBV="ROM", VET=1505, HM = 1506, SR = 1507, ND = 1508, vQueue=294, nQueue=293, portID=260, TYPE="baseDungeon-noI"},
        {NAME = "Cradle of Shadows",    ABBV="COS", VET=1523, HM = 1524, SR = 1525, ND = 1526, vQueue=296, nQueue=295, portID=261, TYPE="baseDungeon-noI"},
        {NAME = "Falkreath Hold",       ABBV="FH",  VET=1699, HM = 1704, SR = 1702, ND = 1703, vQueue=369, nQueue=368, portID=332, TYPE="baseDungeon-noI"},
        {NAME = "Bloodroot Forge",      ABBV="BF",  VET=1691, HM = 1696, SR = 1694, ND = 1695, vQueue=325, nQueue=224, portID=326, TYPE="baseDungeon-noI"},
    }  

---------------------------------------------------------------------------------------------------------
-- Achievement Database Filtering Interface
---------------------------------------------------------------------------------------------------------

function PITHKA.data.filterAchievements(filter, columns)
    local filteredTable = {}
    
    -- Filter rows based on key-value pairs
    for _, row in ipairs(PITHKA.data.achievements) do
        local match = true
        for key, value in pairs(filter) do
            if row[key] ~= value then
                match = false
                break
            end
        end
        if match then
            table.insert(filteredTable, row)
        end
    end

    -- Select specific columns if provided
    if columns then
        local columnTable = {}
        for _, row in ipairs(filteredTable) do
            local filteredRow = {}
            for _, column in ipairs(columns) do
                filteredRow[column] = row[column]
            end
            table.insert(columnTable, filteredRow)
        end
        filteredTable = columnTable
    end
    
    -- No results
    if #filteredTable == 0 then
        return nil
    
    -- Single value result
    elseif #filteredTable == 1 and columns and #columns == 1 then
        local row = filteredTable[1]
        local value = row[columns[1]]
        return value
    
    -- Single row result
    elseif #filteredTable == 1 then
        local row = filteredTable[1]
        return row

    -- single column result
    elseif columns and #columns == 1 then
        -- return all values in the column
        local values = {}
        for _, row in ipairs(filteredTable) do
            table.insert(values, row[columns[1]])
        end
        return values

    -- Table result
    else
        return filteredTable
    end
end
      

-- generic print function that takes value, row, or table and prints properly depending on type
-- if table, print all keys and values
-- if row, print all keys and values
-- if value, print the value
function PITHKA.data.print(value)
    if type(value) == "table" then
        for key, value in pairs(value) do
            d(key, value)
        end
    elseif type(value) == "string" then
        d(value)
    else
        d(tostring(value))
    end
end