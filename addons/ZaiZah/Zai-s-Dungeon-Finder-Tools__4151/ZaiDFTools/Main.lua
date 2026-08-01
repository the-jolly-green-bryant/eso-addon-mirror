-- ZaiDFTools - Zai's Dungeon Finder Tools
-- Features:
--   - Achievement tracking for dungeon completion
--   - Daily pledge highlighting and selection
--   - Veteran achievement tracking (HM, Speed, No Death, Trifecta)
--   - Set collection and motif tracking

ZaiDFTools = ZaiDFTools or {}
local LAM2 = LibAddonMenu2

-- Configuration
local CONFIG = {
    NAME = "ZaiDFTools",
    LONG_NAME = GetString(ZDFT_NAME),
    AUTHOR = "|c00c1ffZai|r|cffffffZah|r",
    VERSION = "07.12.2025",
    SVAR_VERSION = 3,
    CACHE_VERSION = 3,
    CONTAINER_CHECK_INTERVAL = 1000,
}

-- Default settings
local DEFAULT_SETTINGS = {
    showTrifectaIcon = true,
    showHardModeIcon = true,
    showNoDeathIcon = true,
    showSpeedrunIcon = true,
    showClearedIcon = true,
    showMotifIcon = false,
    showSetCollectionIcon = false,

    highlightPledges = true,
    showPledgeIcon = true,
    pledgeDifficulty = "follow",
    showPledgeButton = true,
    
    showCollectionButton = false,
    collectionButtonType = "sets",
    collectionButtonDifficulty = "follow",
    
    -- Persistent data
    achievementCache = {},
    dungeonDataCache = {},
    setCollectionCache = {},
    motifCache = {},
    dailyPledges = {},
    lastPledgeUpdate = 0,
    cacheVersion = CONFIG.CACHE_VERSION,
    
    -- Daily pledge completion tracking
    dailyPledgeCompletion = {
        timestamp = 0,
        characters = {}
    },
}

-- State management
local State = {
    SVAR = {},
    isInitialized = false,
    pledgeButton = nil,
    collectionButton = nil,
}

-- Caches
local Cache = {
    containers = {},
    lastContainerCheck = 0,
    achievementToDungeon = {},
}

-- Constants
local ICONS = {
    TRIFECTA = "|t22:22:/esoui/art/treeicons/gamepad/gp_store_indexicon_fragments.dds|t",
    TRIFECTA_GREY = "|c505050|t22:22:/esoui/art/treeicons/gamepad/gp_store_indexicon_fragments.dds:inheritcolor|t|r",
    HARDMODE = " |t22:22:/esoui/art/unitframes/target_veteranrank_icon.dds|t",
    HARDMODE_GREY = " |c505050|t22:22:/esoui/art/unitframes/target_veteranrank_icon.dds:inheritcolor|t|r",
    NODEATH = " |t22:22:/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds|t",
    NODEATH_GREY = " |c505050|t22:22:/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds:inheritcolor|t|r",
    SPEEDRUN = " |t22:22:/esoui/art/ava/overview_icon_underdog_score.dds|t",
    SPEEDRUN_GREY = " |c505050|t22:22:/esoui/art/ava/overview_icon_underdog_score.dds:inheritcolor|t|r",
    CLEARED = " |t22:22:/esoui/art/inventory/inventory_icon_visible.dds|t",
    CLEARED_GREY = " |c505050|t22:22:/esoui/art/inventory/inventory_icon_visible.dds:inheritcolor|t|r",
    MOTIF = " |t22:22:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds|t",
    MOTIF_GREY = " |c505050|t22:22:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds:inheritcolor|t|r",
    SET_COLLECTION = " |t22:22:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_apparel_head.dds|t",
    SET_COLLECTION_GREY = " |c505050|t22:22:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_apparel_head.dds:inheritcolor|t|r",
    PLEDGE = " |t20:20:/esoui/art/currency/undauntedkey_64.dds|t",
    TOOLTIP_QUEST = "|t24:24:/esoui/art/inventory/inventory_icon_visible.dds|t ",
    TOOLTIP_HM = "|t24:24:/esoui/art/unitframes/target_veteranrank_icon.dds|t ",
    TOOLTIP_SPEED = "|t24:24:/esoui/art/ava/overview_icon_underdog_score.dds|t ",
    TOOLTIP_NODEATH = "|t24:24:/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds|t ",
    TOOLTIP_TRIFECTA = "|t24:24:/esoui/art/treeicons/gamepad/gp_store_indexicon_fragments.dds|t ",
    TOOLTIP_MOTIF = "|t24:24:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_racial_style_motif_book.dds|t ",
    TOOLTIP_SET_COLLECTION = "|t24:24:/esoui/art/tradinghouse/gamepad/gp_tradinghouse_apparel_head.dds|t "
}

local COLORS = {
    WHITE = "|cFFFFFF",
    GREEN = "|c2ECC71",
    BLUE = "|c3498DB",
    ORANGE = "|cE67E22",
    GREY = "|c7F8C8D",
    DLC_GREEN = "|c52C977",
    RESET = "|r",
    
    -- Pledge status colors
    PLEDGE_AVAILABLE = "|c3498DB",
    PLEDGE_IN_PROGRESS = "|cF39C12",
    PLEDGE_COMPLETED = "|c27AE60",
    PLEDGE_TURNED_IN = "|c95A5A6",
}

local STRINGS = {
    PLEDGE_GIVERS = {
        GetString(ZDFT_MAJ_AL_RAGATH),
        GetString(ZDFT_GLIRION_REDBEARD), 
        GetString(ZDFT_URGARLAG_CHIEF)
    },
    
    COMPLETED_STATUS = GetString(SI_ACHIEVEMENTS_TOOLTIP_COMPLETE),  -- ZOS Internal string
    AVAILABLE_STATUS = GetString(SI_ANTIQUITY_SUBHEADING_AVAILABLE), -- ZOS Internal string
    UNKNOWN = GetString(SI_INPUT_LANGUAGE_UNKNOWN),  -- ZOS Internal string
    READY_TO_TURN_IN = GetString(ZDFT_READY_TO_TURN_IN),
    QUEST_IN_PROGRESS = GetString(ZDFT_QUEST_IN_PROGRESS),
    ALREADY_COMPLETED_TODAY = GetString(ZDFT_ALREADY_COMPLETED_TODAY),
    AVAILABLE_TO_ACCEPT = GetString(ZDFT_AVAILABLE_TO_ACCEPT),
    DAILY_PLEDGE = GetString(ZDFT_DAILY_PLEDGE),
    QUEST = GetString(SI_ITEMFILTERTYPE7), -- ZOS Internal string
    ACHIEVEMENTS = GetString(SI_JOURNAL_MENU_ACHIEVEMENTS), -- ZOS Internal string
    VETERAN_ACHIEVEMENTS = GetString(ZDFT_VETERAN_ACHIEVEMENTS),
    TRIFECTA = GetString(ZDFT_TRIFECTA_TEXT),
    MOTIF = GetString(SI_ITEMTYPEDISPLAYCATEGORY24), -- ZOS Internal string
    SETS = GetString(SI_SMITHING_CONSOLIDATED_STATION_ITEM_SETS_UNLOCKED_HEADER), -- ZOS Internal string
    DLC_DUNGEON = GetString(ZDFT_DLC_DUNGEON_TEXT),
    BASE_GAME = GetString(ZDFT_BASE_GAME_TEXT),
    COLLECTIONS = GetString(SI_COLLECTIONS_MENU_ROOT_TITLE), -- ZOS Internal string
}

-- Pre-declared constants
local DEFAULT_PLEDGE_STATUS = {maj = false, glirion = false, urgarlag = false}
local GIVER_NAMES = {"maj", "glirion", "urgarlag"}
local baseTimestamp = 1517464800

-- Pre-declared hover color tables
local HOVER_COLORS = {
    COMPLETED_BRIGHT = {0.4, 0.9, 0.4, 1},
    QUEST_BRIGHT = {1, 0.9, 0.4, 1},
    AVAILABLE_BRIGHT = {0.4, 0.7, 1, 1},
    COMPLETED_GREY_BRIGHT = {0.8, 0.8, 0.8, 1},
    COMPLETED_NORMAL = {0.15, 0.68, 0.38, 1},
    QUEST_NORMAL = {0.95, 0.61, 0.07, 1},
    AVAILABLE_NORMAL = {0.2, 0.6, 0.86, 1},
    COMPLETED_GREY_NORMAL = {0.58, 0.65, 0.65, 1}
}

-- Cache variables
local questStatusCache = {}
local lastQuestCacheUpdate = 0
local recentlyProcessedQuests = {}
local pledgeReadyStatus = {}
local cachedPlayerName = nil
local cachedDayTimestamp = nil
local lastTimestampCheck = 0

-- Dungeon data
local DungeonData = {
    Index = {
        --Normal
            [2]     ={id=294, isDLC=false, itemSetIDs = {33, 61, 297}},  --Fungal Grotto I
            [3]     ={id=301, isDLC=false, itemSetIDs = {35, 55, 296}},  --Spindleclutch I
            [4]     ={id=325, isDLC=false, itemSetIDs = {110, 194, 295}},  --Banished Cells I
            [5]     ={id=78,  isDLC=false, itemSetIDs = {96, 300, 301}},  --Darkshade Caverns I
            [6]     ={id=79,  isDLC=false, itemSetIDs = {29, 194, 299}},  --Wayrest Sewers I
            [7]     ={id=11,  isDLC=false, itemSetIDs = {28, 155, 298}},  --Elden Hollow I
            [8]     ={id=272, isDLC=false, itemSetIDs = {156, 303, 304}},  --Arx Corinium
            [9]     ={id=80,  isDLC=false, itemSetIDs = {122, 134, 302}},  --Crypt of Hearts I
            [10]    ={id=551, isDLC=false, itemSetIDs = {158, 159, 160}},  --City of Ash I
            [11]    ={id=357, isDLC=false, itemSetIDs = {53, 103, 307}},  --Direfrost Keep
            [12]    ={id=391, isDLC=false, itemSetIDs = {77, 102, 305}},  --Volenfell
            [13]    ={id=81,  isDLC=false, itemSetIDs = {186, 188, 193}},  --Tempest Island
            [14]    ={id=393, isDLC=false, itemSetIDs = {46, 72, 310}},  --Blessed Crucible
            [15]    ={id=410, isDLC=false, itemSetIDs = {157, 308, 309}},  --Blackheart Haven
            [16]    ={id=417, isDLC=false, itemSetIDs = {19, 71, 123}},  --Selene's Web
            [17]    ={id=570, isDLC=false, itemSetIDs = {91, 124, 311}},  --Vaults of Madness
            [18]    ={id=1562, isDLC=false, itemSetIDs = {33, 61, 297}}, --Fungal Grotto II
            [22]    ={id=1595, isDLC=false, itemSetIDs = {29, 194, 299}}, --Wayrest Sewers II
            [288]   ={id=1346, isDLC=true, itemSetIDs = {184, 185, 198}},  --White-Gold Tower
            [289]   ={id=1345, isDLC=true, itemSetIDs = {190, 195, 196}},  --Imperial City Prison
            [293]   ={id=1504, isDLC=true, itemSetIDs = {258, 259, 260}, motif=1795},  --Ruins of Mazzatun
            [295]   ={id=1522, isDLC=true, itemSetIDs = {261, 262, 263}, motif=1796},  --Cradle of Shadows
            [300]   ={id=1555, isDLC=false, itemSetIDs = {110, 194, 295}}, --Banished Cells II
            [303]   ={id=1579, isDLC=false, itemSetIDs = {28, 155, 298}}, --Elden Hollow II
            [308]   ={id=1587, isDLC=false, itemSetIDs = {96, 300, 301}}, --Darkshade Caverns II
            [316]   ={id=1571, isDLC=false, itemSetIDs = {35, 55, 296}}, --Spindleclutch II
            [317]   ={id=1616, isDLC=false, itemSetIDs = {122, 134, 302}}, --Crypt of Hearts II
            [322]   ={id=1603, isDLC=false, itemSetIDs = {158, 159, 160}}, --City of Ash II
            [324]   ={id=1690, isDLC=true, itemSetIDs = {338, 339, 340}, motif=2098},  --Bloodroot Forge
            [368]   ={id=1698, isDLC=true, itemSetIDs = {335, 336, 337}, motif=2097},  --Falkreath Hold
            [418]   ={id=1975, isDLC=true, itemSetIDs = {346, 347, 348}, motif=2189},  --Scalecaller Peak
            [420]   ={id=1959, isDLC=true, itemSetIDs = {343, 344, 345}, motif=2190},  --Fang Lair
            [426]   ={id=2152, isDLC=true, itemSetIDs = {402, 403, 404}, motif=2318},  --Moon Hunter Keep
            [428]   ={id=2162, isDLC=true, itemSetIDs = {399, 400, 401}, motif=2317},  --March of Sacrifices
            [433]   ={id=2260, isDLC=true, itemSetIDs = {429, 430, 431}, motif=2503},  --Frostvault
            [435]   ={id=2270, isDLC=true, itemSetIDs = {433, 434, 435}, motif=2504},  --Depths of Malatar
            [494]   ={id=2415, isDLC=true, itemSetIDs = {452, 453, 454}, motif=2628},  --Moongrave Fane
            [496]   ={id=2425, isDLC=true, itemSetIDs = {455, 456, 457}, motif=2629},  --Lair of Maarselok
            [503]   ={id=2539, isDLC=true, itemSetIDs = {471, 472, 473}, motif=2747},  --Icereach
            [505]   ={id=2549, isDLC=true, itemSetIDs = {474, 475, 476}, motif=2749},  --Unhallowed Grave
            [507]   ={id=2694, isDLC=true, itemSetIDs = {516, 517, 518}, motif=2850},  --Stone Garden
            [509]   ={id=2704, isDLC=true, itemSetIDs = {513, 514, 515}, motif=2849},  --Castle Thorn
            [591]   ={id=2831, isDLC=true, itemSetIDs = {569, 570, 571}, motif=2984},  --Black Drake Villa
            [593]   ={id=2841, isDLC=true, itemSetIDs = {572, 573, 574}, motif=2991},  --Cauldron
            [595]   ={id=3016, isDLC=true, itemSetIDs = {605, 606, 607}, motif=3097},  --Red Petal Bastion
            [597]   ={id=3026, isDLC=true, itemSetIDs = {602, 603, 604}, motif=3094},  --The Dread Cellar
            [599]   ={id=3104, isDLC=true, itemSetIDs = {619, 620, 621}, motif=3229},  --Coral Aerie
            [601]   ={id=3114, isDLC=true, itemSetIDs = {622, 623, 624}, motif=3228},  --Shipwright's Regret
            [608]   ={id=3375, isDLC=true, itemSetIDs = {660, 661, 662}, motif=3422},  --Earthen Root Enclave
            [610]   ={id=3394, isDLC=true, itemSetIDs = {663, 664, 665}, motif=3423},  --Graven Deep
            [613]   ={id=3468, isDLC=true, itemSetIDs = {680, 681, 682}, motif=3547},  --Bal Sunnar
            [615]   ={id=3529, isDLC=true, itemSetIDs = {684, 685, 686}, motif=3546},  --Scrivener's Hall
            [638]   ={id=3810, isDLC=true, itemSetIDs = {730, 731, 732}, motif=3921},  --Oathsworn Pit
            [640]   ={id=3851, isDLC=true, itemSetIDs = {735, 736, 737}, motif=3922},  --Bedlam Veil
            [855]   ={id=4109, isDLC=true, itemSetIDs = {794, 795, 796}, motif=4159},  --Exiled Redoubt
            [857]   ={id=4128, isDLC=true, itemSetIDs = {798, 799, 800}, motif=4160},  --Lep Seclusa
            [1037] = {id=4311, isDLC=true, itemSetIDs = {825,826,827}, motif=nil}, -- Naj-Caldeesh
            [1039] = {id=4334, isDLC=true, itemSetIDs = {822,823,824}, motif=nil}, -- Black Gem Foundry
        --Veteran
            [19]    ={id=421,  hm=448,  tt=446,  nd=1572, tri=nil,  isDLC=false, itemSetIDs = {35, 55, 296, 163}}, --Spindleclutch II
            [20]    ={id=1549, hm=1554, tt=1552, nd=1553, tri=nil,  isDLC=false, itemSetIDs = {110, 194, 295, 170}}, --Banished Cells I
            [21]    ={id=464,  hm=467,  tt=465,  nd=1588, tri=nil,  isDLC=false, itemSetIDs = {96, 300, 301, 166}}, --Darkshade Caverns II
            [23]    ={id=1573, hm=1578, tt=1576, nd=1577, tri=nil,  isDLC=false, itemSetIDs = {28, 155, 298, 167}}, --Elden Hollow I
            [261]   ={id=1610, hm=1615, tt=1613, nd=1614, tri=nil,  isDLC=false, itemSetIDs = {122, 134, 302, 168}}, --Crypt of Hearts I
            [267]   ={id=878,  hm=1114, tt=1108, nd=1107, tri=nil,  isDLC=false, itemSetIDs = {158, 159, 160, 169}}, --City of Ash II
            [268]   ={id=880,  hm=1303, tt=1128, nd=1129, tri=nil,  isDLC=true, itemSetIDs = {190, 195, 196, 164}},  --Imperial City Prison
            [287]   ={id=1120, hm=1279, tt=1275, nd=1276, tri=nil,  isDLC=true, itemSetIDs = {184, 185, 198, 183}},  --White-Gold Tower
            [294]   ={id=1505, hm=1506, tt=1507, nd=1508, tri=nil,  isDLC=true, itemSetIDs = {258, 259, 260, 256}, motif=1795},  --Ruins of Mazzatun
            [296]   ={id=1523, hm=1524, tt=1525, nd=1526, tri=nil,  isDLC=true, itemSetIDs = {261, 262, 263, 257}, motif=1796},  --Cradle of Shadows
            [299]   ={id=1556, hm=1561, tt=1559, nd=1560, tri=nil,  isDLC=false, itemSetIDs = {33, 61, 297, 266}}, --Fungal Grotto I
            [301]   ={id=545,  hm=451,  tt=449,  nd=1564, tri=nil,  isDLC=false, itemSetIDs = {110, 194, 295, 170}}, --Banished Cells II
            [302]   ={id=459,  hm=463,  tt=461,  nd=1580, tri=nil,  isDLC=false, itemSetIDs = {28, 155, 298, 167}}, --Elden Hollow II
            [304]   ={id=1629, hm=1634, tt=1632, nd=1633, tri=nil,  isDLC=false, itemSetIDs = {77, 102, 305, 276}}, --Volenfell
            [305]   ={id=1604, hm=1609, tt=1607, nd=1608, tri=nil,  isDLC=false, itemSetIDs = {156, 303, 304, 271}}, --Arx Corinium
            [306]   ={id=1589, hm=1594, tt=1592, nd=1593, tri=nil,  isDLC=false, itemSetIDs = {29, 194, 299, 270}}, --Wayrest Sewers I
            [307]   ={id=678,  hm=681,  tt=679,  nd=1596, tri=nil,  isDLC=false, itemSetIDs = {29, 194, 299, 165}}, --Wayrest Sewers II
            [309]   ={id=1581, hm=1586, tt=1584, nd=1585, tri=nil,  isDLC=false, itemSetIDs = {96, 300, 301, 268}}, --Darkshade Caverns I
            [310]   ={id=1597, hm=1602, tt=1600, nd=1601, tri=nil,  isDLC=false, itemSetIDs = {158, 159, 160, 272}}, --City of Ash I
            [311]   ={id=1617, hm=1622, tt=1620, nd=1621, tri=nil,  isDLC=false, itemSetIDs = {186, 188, 193, 275}}, --Tempest Island
            [312]   ={id=343,  hm=342,  tt=340,  nd=1563, tri=nil,  isDLC=false, itemSetIDs = {33, 61, 297, 162}}, --Fungal Grotto II
            [313]   ={id=1635, hm=1640, tt=1638, nd=1639, tri=nil,  isDLC=false, itemSetIDs = {19, 71, 123, 279}}, --Selene's Web
            [314]   ={id=1653, hm=1658, tt=1656, nd=1657, tri=nil,  isDLC=false, itemSetIDs = {91, 124, 311, 280}}, --Vaults of Madness
            [315]   ={id=1565, hm=1570, tt=1568, nd=1569, tri=nil,  isDLC=false, itemSetIDs = {35, 55, 296, 267}}, --Spindleclutch I
            [318]   ={id=876,  hm=1084, tt=941,  nd=942,  tri=nil,  isDLC=false, itemSetIDs = {122, 134, 302, 168}}, --Crypt of Hearts II
            [319]   ={id=1623, hm=1628, tt=1626, nd=1627, tri=nil,  isDLC=false, itemSetIDs = {53, 103, 307, 274}}, --Direfrost Keep
            [320]   ={id=1641, hm=1646, tt=1644, nd=1645, tri=nil,  isDLC=false, itemSetIDs = {46, 72, 310, 278}}, --Blessed Crucible
            [321]   ={id=1647, hm=1652, tt=1650, nd=1651, tri=nil,  isDLC=false, itemSetIDs = {157, 308, 309, 277}}, --Blackheart Haven
            [325]   ={id=1691, hm=1696, tt=1694, nd=1695, tri=nil,  isDLC=true, itemSetIDs = {338, 339, 340, 341}, motif=2098},  --Bloodroot Forge
            [369]   ={id=1699, hm=1704, tt=1702, nd=1703, tri=nil,  isDLC=true, itemSetIDs = {335, 336, 337, 342}, motif=2097},  --Falkreath Hold
            [419]   ={id=1976, hm=1981, tt=1979, nd=1980, tri=1983, isDLC=true, itemSetIDs = {346, 347, 348, 350}, motif=2189},  --Scalecaller Peak
            [421]   ={id=1960, hm=1965, tt=1963, nd=1964, tri=2102, isDLC=true, itemSetIDs = {343, 344, 345, 349}, motif=2190},  --Fang Lair
            [427]   ={id=2153, hm=2154, tt=2155, nd=2156, tri=2159, isDLC=true, itemSetIDs = {402, 403, 404, 398}, motif=2318},  --Moon Hunter Keep
            [429]   ={id=2163, hm=2164, tt=2165, nd=2166, tri=2168, isDLC=true, itemSetIDs = {399, 400, 401, 397}, motif=2317},  --March of Sacrifices
            [434]   ={id=2261, hm=2262, tt=2263, nd=2264, tri=2267, isDLC=true, itemSetIDs = {429, 430, 431, 432}, motif=2503},  --Frostvault
            [436]   ={id=2271, hm=2272, tt=2273, nd=2274, tri=2276, isDLC=true, itemSetIDs = {433, 434, 435, 436}, motif=2504},  --Depths of Malatar
            [495]   ={id=2416, hm=2417, tt=2418, nd=2419, tri=2422, isDLC=true, itemSetIDs = {452, 453, 454, 458}, motif=2628},  --Moongrave Fane
            [497]   ={id=2426, hm=2427, tt=2428, nd=2429, tri=2431, isDLC=true, itemSetIDs = {455, 456, 457, 459}, motif=2629},  --Lair of Maarselok
            [504]   ={id=2540, hm=2541, tt=2542, nd=2543, tri=2546, isDLC=true, itemSetIDs = {471, 472, 473, 478}, motif=2747},  --Icereach
            [506]   ={id=2550, hm=2551, tt=2552, nd=2553, tri=2555, isDLC=true, itemSetIDs = {474, 475, 476, 479}, motif=2749},  --Unhallowed Grave
            [508]   ={id=2695, hm=2755, tt=2697, nd=2698, tri=2701, isDLC=true, itemSetIDs = {516, 517, 518, 534}, motif=2850},  --Stone Garden
            [510]   ={id=2705, hm=2706, tt=2707, nd=2708, tri=2710, isDLC=true, itemSetIDs = {513, 514, 515, 535}, motif=2849},  --Castle Thorn
            [592]   ={id=2832, hm=2833, tt=2834, nd=2835, tri=2838, isDLC=true, itemSetIDs = {569, 570, 571, 577}, motif=2984},  --Black Drake Villa
            [594]   ={id=2842, hm=2843, tt=2844, nd=2845, tri=2847, isDLC=true, itemSetIDs = {572, 573, 574, 578}, motif=2991},  --Cauldron
            [596]   ={id=3017, hm=3018, tt=3019, nd=3020, tri=3023, isDLC=true, itemSetIDs = {605, 606, 607, 608}, motif=3097},  --Red Petal Bastion
            [598]   ={id=3027, hm=3028, tt=3029, nd=3030, tri=3032, isDLC=true, itemSetIDs = {602, 603, 604, 609}, motif=3094},  --The Dread Cellar
            [600]   ={id=3105, hm=3153, tt=3107, nd=3108, tri=3111, isDLC=true, itemSetIDs = {619, 620, 621, 632}, motif=3229},  --Coral Aerie
            [602]   ={id=3115, hm=3154, tt=3117, nd=3118, tri=3120, isDLC=true, itemSetIDs = {622, 623, 624, 633}, motif=3228},  --Shipwright's Regret
            [609]   ={id=3376, hm=3377, tt=3378, nd=3379, tri=3381, isDLC=true, itemSetIDs = {660, 661, 662, 666}, motif=3422},  --Earthen Root Enclave
            [611]   ={id=3395, hm=3396, tt=3397, nd=3398, tri=3400, isDLC=true, itemSetIDs = {663, 664, 665, 667}, motif=3423},  --Graven Deep
            [614]   ={id=3469, hm=3470, tt=3471, nd=3472, tri=3474, isDLC=true, itemSetIDs = {680, 681, 682, 683}, motif=3547},  --Bal Sunnar
            [616]   ={id=3530, hm=3531, tt=3532, nd=3533, tri=3535, isDLC=true, itemSetIDs = {684, 685, 686, 687}, motif=3546},  --Scrivener's Hall
            [639]   ={id=3811, hm=3812, tt=3813, nd=3814, tri=3816, isDLC=true, itemSetIDs = {730, 731, 732, 734}, motif=3921},  --Oathsworn Pit
            [641]   ={id=3852, hm=3853, tt=3854, nd=3855, tri=3857, isDLC=true, itemSetIDs = {735, 736, 737, 738}, motif=3922},  --Bedlam Veil
            [856]   ={id=4110, hm=4111, tt=4112, nd=4113, tri=4115, isDLC=true, itemSetIDs = {794, 795, 796, 797}, motif=4159},  --Exiled Redoubt
            [858]   ={id=4129, hm=4130, tt=4131, nd=4132, tri=4134, isDLC=true, itemSetIDs = {798, 799, 800, 801}, motif=4160},  --Lep Seclusa
            [1038] = {id=4312, hm=4313, tt=4314, nd=4315, tri=4317, isDLC=true, itemSetIDs = {825,826,827,829}, motif=nil}, -- Naj-Caldeesh
            [1040] = {id=4335, hm=4336, tt=4337, nd=4338, tri=4340, isDLC=true, itemSetIDs = {822,823,824,828}, motif=nil}, -- Black Gem Foundry   
    },

    Pledges = {
        [1] = { -- Maj
            { id = 303, vetId = 302 },  -- Elden Hollow II
            { id = 6, vetId = 306 },    -- Wayrest Sewers I
            { id = 316, vetId = 19 },   -- Spindleclutch II
            { id = 4, vetId = 20 },     -- Banished Cells I
            { id = 18, vetId = 312 },   -- Fungal Grotto II
            { id = 3, vetId = 315 },    -- Spindleclutch I
            { id = 308, vetId = 21 },   -- Darkshade Caverns II
            { id = 7, vetId = 23 },     -- Elden Hollow I
            { id = 22, vetId = 307 },   -- Wayrest Sewers II
            { id = 2, vetId = 299 },    -- Fungal Grotto I
            { id = 300, vetId = 301 },  -- Banished Cells II
            { id = 5, vetId = 309 },    -- Darkshade Caverns I
            shift = 0
        },
        [2] = { -- Glirion
            { id = 12, vetId = 304 },   -- Volenfell
            { id = 14, vetId = 320 },   -- Blessed Crucible
            { id = 11, vetId = 319 },   -- Direfrost Keep
            { id = 17, vetId = 314 },   -- Vaults of Madness
            { id = 317, vetId = 318 },  -- Crypt of Hearts II
            { id = 10, vetId = 310 },   -- City of Ash I
            { id = 13, vetId = 311 },   -- Tempest Island
            { id = 15, vetId = 321 },   -- Blackheart Haven
            { id = 8, vetId = 305 },    -- Arx Corinium
            { id = 16, vetId = 313 },   -- Selene's Web
            { id = 322, vetId = 267 },  -- City of Ash II
            { id = 9, vetId = 261 },    -- Crypt of Hearts I
            shift = 0
        },
        [3] = { -- Urgarlag
            { id = 289, vetId = 268 },  -- Imperial City Prison
            { id = 293, vetId = 294 },  -- Ruins of Mazzatun
            { id = 288, vetId = 287 },  -- White-Gold Tower
            { id = 295, vetId = 296 },  -- Cradle of Shadows
            { id = 324, vetId = 325 },  -- Bloodroot Forge -- 05/09/2025
            { id = 368, vetId = 369 },  -- Falkreath Hold
            { id = 420, vetId = 421 },  -- Fang Lair
            { id = 418, vetId = 419 },  -- Scalecaller Peak
            { id = 426, vetId = 427 },  -- Moon Hunter Keep
            { id = 428, vetId = 429 },  -- March of Sacrifices
            { id = 435, vetId = 436 },  -- Depths of Malatar
            { id = 433, vetId = 434 },  -- Frostvault
            { id = 494, vetId = 495 },  -- Moongrave Fane
            { id = 496, vetId = 497 },  -- Lair of Maarselok
            { id = 503, vetId = 504 },  -- Icereach
            { id = 505, vetId = 506 },  -- Unhallowed Grave
            { id = 507, vetId = 508 },  -- Stone Garden
            { id = 509, vetId = 510 },  -- Castle Thorn
            { id = 591, vetId = 592 },  -- Black Drake Villa
            { id = 593, vetId = 594 },  -- Cauldron
            { id = 595, vetId = 596 },  -- Red Petal Bastion
            { id = 597, vetId = 598 },  -- The Dread Cellar
            { id = 599, vetId = 600 },  -- Coral Aerie
            { id = 601, vetId = 602 },  -- Shipwright's Regret
            { id = 608, vetId = 609 },  -- Earthen Root Enclave
            { id = 610, vetId = 611 },  -- Graven Deep
            { id = 613, vetId = 614 },  -- Bal Sunnar
            { id = 615, vetId = 616 },  -- Scrivener's Hall
            { id = 638, vetId = 639 },  -- Oathsworn Pit
            { id = 640, vetId = 641 },  -- Bedlam Veil
            { id = 855, vetId = 856 },  -- Exiled Redoubt
            { id = 857, vetId = 858 },  -- Lep Seclusa
            { id = 1037, vetId = 1038 },  -- Naj-Caldessh
            { id = 1039, vetId = 1040 },  -- Black Gem Foundry
            shift = 19
        },
    },
}

-- DONT MODIFY THIS TABLE
local RETURN_TO_PATTERNS = {
    -- English
    ["en"] = {
        "Return to", -- Return to
    },
    -- German
    ["de"] = {
        "Kehrt zu", -- Return to
    },
    -- Spanish
    ["es"] = {
        "Vuelve con", -- Come back with
    },
    -- French
    ["fr"] = {
        "Retournez voir", -- Go back and see
    },
    -- Russian
    ["ru"] = {
        "Вернуться к", -- Back to
        "Вернуться", -- Return
    },
    -- Chinese
    ["zh"] = {
        "返回", -- Return
        "回到", -- Return to
    }
}

-- These are directly copied from the game's localization files and then hashed with HashString()
-- DO NOT MODIFY THIS TABLE
local PLEDGE_QUEST_HASHES = {
    -- [HashString("Pledge: Banished Cells I")] = ESO Activity ID,
    ["en"] = {
        [3867212071] = 4, -- Pledge: Banished Cells I
        [3001307362] = 300, -- Pledge: Banished Cells II
        [1149945730] = 2, -- Pledge: Fungal Grotto I
        [2779322695] = 18, -- Pledge: Fungal Grotto II
        [3566387954] = 3, -- Pledge: Spindleclutch I
        [319814103] = 316, -- Pledge: Spindleclutch II
        [4141980939] = 5, -- Pledge: Darkshade Caverns I
        [4157735880] = 308, -- Pledge: Darkshade II
        [1578794417] = 7, -- Pledge: Elden Hollow I
        [2788552408] = 303, -- Pledge: Elden Hollow II
        [1554116646] = 6, -- Pledge: Wayrest Sewers I
        [3154123171] = 22, -- Pledge: Wayrest Sewers II
        [2948633134] = 9, -- Pledge: Crypt of Hearts I
        [3532781979] = 317, -- Pledge: Crypt of Hearts II
        [3412730798] = 8, -- Pledge: Arx Corinium
        [58646508] = 10, -- Pledge: City of Ash I
        [3156548445] = 322, -- Pledge: City of Ash II
        [1964250936] = 11, -- Pledge: Direfrost Keep
        [3167556386] = 13, -- Pledge: Tempest Island
        [2684938780] = 12, -- Pledge: Volenfell
        [2514249132] = 15, -- Pledge: Blackheart Haven
        [1728713012] = 14, -- Pledge: Blessed Crucible
        [268250689] = 16, -- Pledge: Selene's Web
        [1145162814] = 17, -- Pledge: Vaults of Madness
        [2680080794] = 289, -- Pledge: Imperial City Prison
        [1870653516] = 288, -- Pledge: White-Gold Tower
        [3961643573] = 293, -- Pledge: Ruins of Mazzatun
        [3553713312] = 295, -- Pledge: Cradle of Shadows
        [3844202020] = 324, -- Pledge: Bloodroot Forge
        [16981174] = 368, -- Pledge: Falkreath Hold
        [1403911081] = 418, -- Pledge: Scalecaller Peak
        [4000484523] = 420, -- Pledge: Fang Lair
        [4255083717] = 426, -- Pledge: Moon Hunter Keep
        [2301665679] = 428, -- Pledge: March of Sacrifices
        [1574982605] = 433, -- Pledge: Frostvault
        [478250244] = 435, -- Pledge: Depths of Malatar
        [3431421645] = 494, -- Pledge: Moongrave Fane
        [1853387435] = 496, -- Pledge: Lair of Maarselok
        [2539453223] = 503, -- Pledge: Icereach
        [441848669] = 505, -- Pledge: Unhallowed Grave
        [170837423] = 507, -- Pledge: Stone Garden
        [3801210318] = 509, -- Pledge: Castle Thorn
        [1643519739] = 591, -- Pledge: Black Drake Villa
        [606285424] = 593, -- Pledge: The Cauldron
        [840981316] = 595, -- Pledge: Red Petal Bastion
        [286779623] = 597, -- Pledge: The Dread Cellar
        [2700212796] = 599, -- Pledge: Coral Aerie
        [2420375457] = 601, -- Pledge: Shipwright's Regret
        [3227948780] = 608, -- Pledge: Earthen Root Enclave
        [3391919876] = 610, -- Pledge: Graven Deep
        [1952810501] = 613, -- Pledge: Bal Sunnar
        [73336807] = 615, -- Pledge: Scrivener's Hall
        [1697584157] = 638, -- Pledge: Oathsworn Pit
        [3104543228] = 640, -- Pledge: Bedlam Veil
        [1644724285] = 855, -- Pledge: Exiled Redoubt
        [2644078464] = 857, -- Pledge: Lep Seclusa
        [2005022112] = 1037, -- Pledge: Naj-Caldeesh
        [3124017816] = 1039, -- Pledge: Black Gem Foundry
    },
    ["de"] = {
        [850437584] = 4, -- Verbannungszellen I
        [524865145] = 300, -- Verbannungszellen II
        [252766275] = 2, -- Pilzgrotte I
        [2641111238] = 18, -- Pilzgrotte II
        [2403479651] = 3, -- Spindeltiefen I
        [1907157158] = 316, -- Spindeltiefen II
        [1979165146] = 5, -- Dunkelschattenkavernen I
        [2982989039] = 308, -- Dunkelschattenkavernen II
        [1110685457] = 7, -- Eldengrund I
        [30084472] = 303, -- Eldengrund II
        [3453611658] = 6, -- Kanalisation von Wegesruh I
        [2536223807] = 22, -- Kanalisation von Wegesruh II
        [1763386617] = 9, -- Krypta der Herzen I
        [44505488] = 317, -- Krypta der Herzen II
        [4294636335] = 8, -- Arx Corinium
        [1315064316] = 10, -- Stadt der Asche I
        [2485925197] = 322, -- Stadt der Asche II
        [1360831524] = 11, -- Burg Grauenfrost
        [2749282912] = 13, -- Orkaninsel
        [2757827035] = 12, -- Volenfell
        [4029895213] = 15, -- Schwarzherz-Unterschlupf
        [1948336238] = 14, -- Gesegnete Feuerprobe
        [927297100] = 16, -- Selenes Netz
        [2053273002] = 17, -- Kammern des Wahnsinns
        [544283082] = 289, -- Gefängnis der Kaiserstadt
        [2681330931] = 288, -- Weißgoldturm
        [932590266] = 293, -- Ruinen von Mazzatun
        [2151817936] = 295, -- Wiege der Schatten
        [3809708266] = 324, -- Blutquellschmiede
        [2770429139] = 368, -- Falkenring
        [1506641055] = 418, -- Gipfel der Schuppenruferin
        [917381516] = 420, -- Krallenhort
        [1593700004] = 426, -- Mondjägerfeste
        [2715899065] = 428, -- Marsch der Aufopferung
        [25753223] = 433, -- Frostgewölbe
        [458558800] = 435, -- Tiefen von Malatar
        [2000615820] = 494, -- Mondgrab-Tempelstadt
        [2105081086] = 496, -- Der Hort von Maarselok
        [4052387435] = 503, -- Eiskap
        [1909413223] = 505, -- Unheiliges Grab
        [1789866766] = 507, -- Steingarten
        [602154041] = 509, -- Kastell Dorn
        [1307606743] = 591, -- Schwarzdrachenvilla
        [843732272] = 593, -- Der Kessel
        [3170548805] = 595, -- Rotblütenbastion
        [2699577261] = 597, -- Der Schreckenskeller
        [2410952641] = 599, -- Der Korallenhorst
        [3757406616] = 601, -- Gram des Schiffbauers
        [1447086134] = 608, -- Erdwurz-Enklave
        [1464246572] = 610, -- Kentertiefen
        [3050849798] = 613, -- Bal Sunnar
        [460233637] = 615, -- Halle der Schriftmeister
        [3989937424] = 638, -- Grube der Eidgeschworenen
        [2415816221] = 640, -- Schleier des Aufruhrs
        [2906218016] = 855, -- Schanze der Abgeschiedenen
        [2027401151] = 857, -- Lep Seclusa
        [2886927649] = 1037, -- Naj-Caldeesh
        [2355918498] = 1039, -- Schwarzstein-Gießerei
    },
    ["es"] = {
        [498982555] = 4, -- Compromiso: Celdas del Destierro I
        [810862702] = 300, -- Compromiso: Celdas del Destierro II
        [1749911315] = 2, -- Compromiso: Gruta de los Hongos 1
        [1749911316] = 18, -- Compromiso: Gruta de los Hongos 2
        [3396089912] = 3, -- Compromiso: El Espiráculo I
        [148493841] = 316, -- Compromiso: El Espiráculo II
        [834500489] = 5, -- Compromiso: Cavernas Sombra Oscura 1
        [3785396886] = 308, -- Compromiso: Cavernas Sombra Oscura II
        [2573150468] = 7, -- Compromiso: Hondonada de Elden 1
        [2573150469] = 303, -- Compromiso: Hondonada de Elden 2
        [3542844319] = 6, -- Compromiso: Cloacas de Quietud 1
        [3542844320] = 22, -- Compromiso: Cloacas de Quietud 2
        [1511691843] = 9, -- Compromiso: Cripta de los Corazones 1
        [1511691844] = 317, -- Compromiso: Cripta de los Corazones 2
        [1861315257] = 8, -- Compromiso: Arx Corinium
        [2902768654] = 10, -- Compromiso: Ciudad de Ceniza I
        [1345865659] = 322, -- Compromiso: Ciudad de Ceniza II
        [101399368] = 11, -- Compromiso: Bastión Escarcha Aviesa
        [2681135506] = 13, -- Compromiso: Isla de la Tempestad
        [2274310865] = 12, -- Compromiso: Volenfell
        [1696762400] = 15, -- Compromiso: Refugio del Corazón Negro
        [485549427] = 14, -- Compromiso: Crisol Sagrado
        [2536312437] = 16, -- Compromiso: Telaraña de Selene
        [1219116823] = 17, -- Compromiso: Cámaras de la Locura
        [2772561154] = 289, -- Compromiso: Prisión de la Ciudad Imperial
        [737607561] = 288, -- Compromiso: Torre Blanca y Dorada
        [4193371459] = 293, -- Compromiso: ruinas de Mazzatun
        [2169125829] = 295, -- Compromiso: Cuna de Sombras
        [2076229394] = 324, -- Compromiso: Forja Sanguinaria
        [3592852451] = 368, -- Compromiso: comarca de Falkreath
        [3067915190] = 418, -- Compromiso: Cumbre de la Invocadora de Escamas
        [2804912756] = 420, -- Compromiso: Guarida de los Colmillos
        [3415549436] = 426, -- Compromiso: Bastión del Cazador de la Luna
        [4294820962] = 428, -- Compromiso: Marcha de los Sacrificios
        [3745169730] = 433, -- Compromiso: Cripta Helada
        [3120202409] = 435, -- Compromiso: Profundidades de Malatar
        [4197635083] = 494, -- Compromiso: Sepulcro Lunar
        [3167214453] = 496, -- Compromiso: Guarida de Maarselok
        [2270473904] = 503, -- Compromiso: Cuenca Glacial
        [2788662142] = 505, -- Compromiso: Sepulcro Profano
        [770105591] = 507, -- Compromiso: Jardín de Piedra
        [1008815051] = 509, -- Compromiso: Castillo Espina
        [1569609179] = 591, -- Compromiso: Villa del Draco Negro
        [3244422621] = 593, -- Compromiso: El Caldero
        [3937780338] = 595, -- Compromiso: Bastión del Pétalo Rojo
        [1269317697] = 597, -- Compromiso: el Sótano Pavoroso
        [4139434146] = 599, -- Compromiso: Nido de Coral
        [1987447098] = 601, -- Compromiso: el Lamento del Armador
        [2358860186] = 608, -- Compromiso: Enclave de Raíz Terrosa
        [3802576000] = 610, -- Compromiso: Sima Mortuoria
        [3207094928] = 613, -- Compromiso: Bal Sunnar
        [889956260] = 615, -- Compromiso: Sala del Escribano
        [754176210] = 638, -- Compromiso: Palestra de los Juramentados
        [1114979919] = 640, -- Compromiso: Velo del Trastorno
        [3084094491] = 855, -- Compromiso: Reducto de los Exiliados
        [3759715765] = 857, -- Compromiso: Lep Seclusa
        [453606571] = 1037, -- Compromiso: Naj-Caldeesh
        [2852899039] = 1039, -- Compromiso: Fundición de la Gema Negra
    },
    ["fr"] = {
        [3541329970] = 4, -- Serment : Cachot interdit I
        [1513596055] = 300, -- Serment : Cachot interdit II
        [4074913678] = 2, -- Serment : Champignonnière I
        [87794747] = 18, -- Serment : Champignonnière II
        [1403958270] = 3, -- Serment : Tressefuseau I
        [1274825675] = 316, -- Serment : Tressefuseau II
        [1934028516] = 5, -- Serment : Cavernes d'Ombre-noire I
        [1297664613] = 308, -- Serment : Cavernes d'Ombre-noire II
        [2494522663] = 7, -- Serment : Creuset des aînés I
        [4233159906] = 303, -- Serment : Creuset des aînés II
        [405797187] = 6, -- Serment : Égouts d'Haltevoie I
        [3977336774] = 22, -- Serment : Égouts d'Haltevoie II
        [2662953987] = 9, -- Serment : Crypte des cœurs I
        [2208730374] = 317, -- Serment : Crypte des cœurs II
        [2523445713] = 8, -- Serment : Arx Corinium
        [215558069] = 10, -- Serment : Cité des cendres I
        [1361429972] = 322, -- Serment : Cité des cendres II
        [4267542478] = 11, -- Serment : Donjon d'Affregivre
        [1520370591] = 13, -- Serment : Île des Tempêtes
        [267098553] = 12, -- Serment : Volenfell
        [1941372779] = 15, -- Serment : Havre de Cœurnoir
        [1893472644] = 14, -- Serment : Creuset béni
        [1496126451] = 16, -- Serment : Toile de Sélène
        [1769560996] = 17, -- Serment : Chambres de la folie
        [1315569948] = 289, -- Serment : prison de la cité impériale
        [3866471512] = 288, -- Serment : Tour d'or blanc
        [1199109495] = 293, -- Serment : Ruines de Mazzatun
        [2995824487] = 295, -- Serment : Berceau des ombres
        [711764439] = 324, -- Serment : Forge de Sangracine
        [1877279256] = 368, -- Serment : Forteresse d'Épervine
        [2857846789] = 418, -- Serment : Pic de la Mandécailles
        [966031464] = 420, -- Serment : Repaire du croc
        [2502240866] = 426, -- Serment : Fort du Chasseur lunaire
        [2875027729] = 428, -- Serment : Procession des Sacrifiés
        [1062556633] = 433, -- Serment : Arquegivre
        [436389762] = 435, -- Serment : Profondeurs de Malatar
        [1742755451] = 494, -- Serment : le reliquaire des Lunes funèbres
        [1465280092] = 496, -- Serment : Repaire de Maarselok
        [1467397530] = 503, -- Serment : Crève-Nève
        [3206692869] = 505, -- Serment : Sépulcre profane
        [2604830184] = 507, -- Serment : Jardin de pierre
        [1775681241] = 509, -- Serment : Bastion-les-Ronce
        [1218889756] = 591, -- Serment : Villa du Dragon noir
        [2474774955] = 593, -- Serment : Le Chaudron
        [2726189469] = 595, -- Serment : Bastion du Pétale rouge
        [2364143572] = 597, -- Serment : la Cave d'effroi
        [4055500730] = 599, -- Serment : Aire de corail
        [3769567751] = 601, -- Serment : regret du charpentier
        [1493891421] = 608, -- Serment : Enclave des Racines de la terre
        [3033806956] = 610, -- Serment : Profondeurs mortuaires
        [2899033512] = 613, -- Serment : Bal Sunnar
        [509895411] = 615, -- Serment : Salles du
        [3189348982] = 638, -- Serment : Fosse aux fidèles
        [2401460014] = 640, -- Serment : Voile des fous
        [605239286] = 855, -- Serment : redoute de l'Exil
        [3060015261] = 857, -- Serment : Lep Seclusa
        [1115737027] = 1037, -- Serment : Naj-Caldeesh
        [3097390882] = 1039, -- Serment : Fonderie des Pierres noires
    },
    ["jp"] = {
        [924686843] = 4, -- 誓い: 追放者の監房1
        [924686844] = 300, -- 誓い: 追放者の監房2
        [3694265742] = 2, -- 誓い: フンガル洞窟1
        [3694265743] = 18, -- 誓い: フンガル洞窟2
        [3989628698] = 3, -- 誓い: スピンドルクラッチ1
        [3989628699] = 316, -- 誓い: スピンドルクラッチ2
        [1331991928] = 5, -- 誓い: ダークシェイド洞窟1
        [283600901] = 308, -- 誓い: ダークシェイド2
        [2144402982] = 7, -- 誓い: エルデン洞穴1
        [2144402983] = 303, -- 誓い: エルデン洞穴2
        [165227002] = 6, -- 誓い: ウェイレスト下水道1
        [165227003] = 22, -- 誓い: ウェイレスト下水道2
        [3241384082] = 9, -- 誓い: ハーツ墓地1
        [3241384083] = 317, -- 誓い: ハーツ墓地2
        [2907467377] = 8, -- 誓い: アークス・コリニウム
        [3904217224] = 10, -- 誓い: 灰の街1
        [3904217225] = 322, -- 誓い: 灰の街2
        [2310794788] = 11, -- 誓い: ダイアフロスト砦
        [2457676168] = 13, -- 誓い: テンペスト島
        [2814748224] = 12, -- 誓い: ヴォレンフェル
        [2742873244] = 15, -- 誓い: ブラックハート・ヘヴン
        [3844708450] = 14, -- 誓い: 聖なるるつぼ
        [2321350499] = 16, -- 誓い: セレーンの巣
        [3791752503] = 17, -- 誓い: 狂気の地下室
        [1377016515] = 289, -- 誓い: 帝都監獄
        [2813829483] = 288, -- 誓い: 白金の塔
        [1607919154] = 293, -- 誓い: マザッタン遺跡
        [3500320895] = 295, -- 誓い: 影のゆりかご
        [27853866] = 324, -- 誓い: ブラッドルート・フォージ
        [3067390298] = 368, -- 誓い: ファルクリース要塞
        [2075996641] = 418, -- 誓い: スケイルコーラー・ピーク
        [3036139837] = 420, -- 誓い: 牙の巣
        [2319292179] = 426, -- 誓い: 月狩人の砦
        [1063164693] = 428, -- 誓い: マーチ・オブ・サクリファイス
        [198218292] = 433, -- 誓い: フロストヴォルト
        [3537485963] = 435, -- 誓い: マラタールの深淵
        [3584087103] = 494, -- 誓い: ムーングレイブ神殿
        [2317010951] = 496, -- 誓い: マーセロクの巣
        [4000656434] = 503, -- 誓い: アイスリーチ
        [2689923581] = 505, -- 誓い: 不浄の墓
        [1209801851] = 507, -- 誓い: ストーンガーデン
        [643597754] = 509, -- 誓い: ソーン城
        [1525358239] = 591, -- 誓い: ブラック・ドレイクの邸宅
        [2722415037] = 593, -- 誓い: 〈大鍋〉
        [911067970] = 595, -- 誓い: 赤い花弁の砦
        [3730129227] = 597, -- 誓い: ドレッドセラー
        [343808442] = 599, -- 誓い: サンゴの高所
        [1352596236] = 601, -- 誓い: 船大工の後悔
        [4022292475] = 608, -- 誓い: アーセンルート居留地
        [649416103] = 610, -- 誓い: グレイブン・ディープ
        [2517470659] = 613, -- 誓い: バル・サナー
        [7458413] = 615, -- 誓い: 書記の館
        [3417159727] = 638, -- 誓約: オーススウォーンの訓練場
        [865987403] = 640, -- 誓約: ベドラムのベール
        [1231203045] = 855, -- 誓い: 追放者の砦
        [4075161564] = 857, -- 誓い: レプ・セクルーサ
        [2038927612] = 1037, -- 誓い: ナジ・カルディーシュ
        [1314305829] = 1039, -- 誓い: 黒き石の工場
    },
    ["ru"] = {
        [2554907937] = 4, -- Обет: темницы Изгнанников I
        [1191934824] = 300, -- Обет: темницы Изгнанников II
        [441721988] = 2, -- Обет: Грибной грот I
        [2671312069] = 18, -- Обет: Грибной грот II
        [917718230] = 3, -- Обет: Логово Мертвой Хватки I
        [3136549107] = 316, -- Обет: Логово Мертвой Хватки II
        [1518893258] = 5, -- Обет: пещеры Глубокой Тени I
        [3227499007] = 308, -- Обет: пещеры Глубокой Тени II
        [296360496] = 7, -- Обет: Элденская расщелина I
        [1930195481] = 303, -- Обет: Элденская расщелина II
        [249620742] = 6, -- Обет: канализация Вэйреста I
        [2455722179] = 22, -- Обет: канализация Вэйреста II
        [3741430388] = 9, -- Обет: Крипта Сердец I
        [2480859861] = 317, -- Обет: Крипта Сердец II
        [1129781499] = 8, -- Обет: Аркс-Кориниум
        [2278976698] = 10, -- Обет: Город Пепла I
        [3665740303] = 322, -- Обет: Город Пепла II
        [2489006793] = 11, -- Обет: крепость Лютых Морозов
        [1478295044] = 13, -- Обет: остров Бурь
        [55909638] = 12, -- Обет: Воленфелл
        [1274390559] = 15, -- Обет: гавань Черного Сердца
        [2159443144] = 14, -- Обет: Священное Горнило
        [2840546011] = 16, -- Обет: Паутина Селены
        [2460539527] = 17, -- Обет: Своды Безумия
        [1331629041] = 289, -- Обет: тюрьма Имперского города
        [2233042045] = 288, -- Обет: Башня Белого Золота
        [1324562255] = 293, -- Обет: руины Маззатуна
        [1501571550] = 295, -- Обет: Колыбель Теней
        [117647456] = 324, -- Обет: кузница Кровавого Корня
        [1631509540] = 368, -- Обет: владение Фолкрит
        [662953646] = 418, -- Обет: пик Воспевательницы Дракона
        [2679386004] = 420, -- Обет: Логово Клыка
        [3889410124] = 426, -- Обет: крепость Лунного Охотника
        [3530581150] = 428, -- Обет: Путь Жертвоприношений
        [4038756991] = 433, -- Обет: Морозное хранилище
        [2727318588] = 435, -- Обет: Глубины Малатара
        [3656714306] = 494, -- Обет: храм Погребенных Лун
        [397410830] = 496, -- Обет: логово Марселока
        [4059736054] = 503, -- Обет: Ледяной Предел
        [3238420015] = 505, -- Обет: Нечестивая Могила
        [2891303506] = 507, -- Обет: Каменный Сад
        [168512553] = 509, -- Обет: замок Шипов
        [1963332074] = 591, -- Обет: вилла Черного Змея
        [2439679588] = 593, -- Обет: Котел
        [1376020417] = 595, -- Обет: оплот Алый Лепесток
        [320048426] = 597, -- Обет: Ужасный Подвал
        [2555176771] = 599, -- Обет: Коралловое Гнездо
        [1445386824] = 601, -- Обет: Горе Корабела
        [663492180] = 608, -- Обет: Анклав Земляного Корня
        [1499811499] = 610, -- Обет: Могильная Пучина
        [2701678434] = 613, -- Обет: Бал-Суннар
        [3455769207] = 615, -- Обет: Зал Книжников
        [4228951892] = 638, -- Обет: храм Верных Клятве
        [1090067626] = 640, -- Обет: Завеса Хаоса
        [1022050752] = 855, -- Обет: оплот Изгнания
        [1665030503] = 857, -- Обет: Леп-Секлуза
        [3978253987] = 1037, -- Обет: Надж-Калдиш
        [3656343602] = 1039, -- Обет: литейная Черного Камня
    },
    ["zh"] = {
        [3704502732] = 4, -- 誓约任务：放逐地牢 I
        [2425108861] = 300, -- 誓约任务：放逐地牢 II
        [629695883] = 2, -- 誓约任务：真菌岩洞 I
        [2719743358] = 18, -- 誓约任务：真菌岩洞 II
        [2865786145] = 3, -- 誓约任务：蛛丝之握洞穴 I
        [1986780008] = 316, -- 誓约任务：蛛丝之握洞穴 II
        [2283177012] = 5, -- 誓约任务：暗影洞穴 I
        [29264149] = 308, -- 誓约任务：暗影洞穴 II
        [2960260762] = 7, -- 誓约任务：探索艾尔登洞穴 I
        [1789372463] = 303, -- 誓约任务：探索艾尔登洞穴 II
        [4253622894] = 6, -- 誓约任务：探索途歇城下水道 I
        [2267904347] = 22, -- 誓约任务：探索途歇城下水道 II
        [6615047] = 9, -- 誓约任务：心灵地穴 I
        [3003383655] = 317, -- 誓约任务：探索心灵地穴 II
        [2826351811] = 8, -- 誓约任务：科林涅姆堡垒
        [2694505588] = 10, -- 誓约任务：灰烬之城 I
        [1787967701] = 322, -- 誓约任务：灰烬之城 II
        [1737989793] = 11, -- 誓约任务：探索恐霜要塞
        [456082900] = 13, -- 誓约任务：探索风暴岛
        [2387331457] = 12, -- 誓约任务：探索沃伦费尔
        [2746545529] = 15, -- 誓约任务：黑心港口
        [2095102455] = 14, -- 誓约任务：受佑熔炉
        [1093976628] = 16, -- 誓约任务：夕月之网
        [1091515184] = 17, -- 誓约任务：疯狂密室
        [387578684] = 289, -- 誓约任务：帝都监狱
        [1976210813] = 288, -- 誓约任务：白金塔
        [261328056] = 293, -- 誓约任务：马扎顿遗迹
        [55891123] = 295, -- 誓约任务：暗影摇篮
        [2416840484] = 324, -- 誓约任务：血根熔炉
        [3365803155] = 368, -- 誓约任务：佛克瑞斯领地
        [4100512088] = 418, -- 誓约任务：唤鳞者之巅
        [1886096594] = 420, -- 誓约任务：獠牙巢穴
        [778167621] = 426, -- 誓约任务：月狩要塞
        [2422729833] = 428, -- 誓约任务：献祭之境
        [2476400567] = 433, -- 誓约任务：冰霜宝库
        [3933949381] = 435, -- 誓约任务：马拉塔深渊
        [3336226241] = 494, -- 誓约任务：月墓古庙
        [193663465] = 496, -- 誓约任务：马塞洛克巢穴
        [1237894314] = 503, -- 誓约任务：冰境
        [1422347967] = 505, -- 誓约任务：亵渎坟墓
        [629483889] = 507, -- 誓约任务：探索石之花园
        [1602776511] = 509, -- 誓约任务：荆棘城堡
        [675025128] = 591, -- 誓约任务: 探索黑德雷克庄园
        [4144146148] = 593, -- 誓约任务：探索大釜
        [1794976499] = 595, -- 誓约任务：红花堡
        [4041257999] = 597, -- 誓约任务：恐惧地牢
        [1470470097] = 599, -- 誓约任务：探索珊瑚鹫巢
        [3459534748] = 601, -- 誓约任务：船工之憾地牢
        [1451578318] = 608, -- 誓约任务：地根飞地
        [832358270] = 610, -- 誓约任务：铭深岛
        [833526180] = 613, -- 誓约任务：巴尔桑纳
        [1644143674] = 615, -- 誓约任务：书吏大厅
        [4100429008] = 638, -- 誓约任务：誓约者深渊
        [691731939] = 640, -- 誓约任务：癫狂之幕
        [3926481127] = 855, -- 誓约任务：流亡哨站
        [3087591511] = 857, -- 誓约任务：秀跃隐修院
        [2063671714] = 1037, -- 誓约任务：纳吉-卡尔迪什
        [863445163] = 1039, -- 誓约任务：黑宝石铸造厂
    },
}

local function GetGameLanguage()
    local lang = GetCVar("language.2") or "en"
    return lang:lower()
end

local function ContainsReturnToPattern(text)
    if not text or type(text) ~= "string" then
        return false
    end
    
    local lowerText = string.lower(text)
    local currentLang = GetGameLanguage()
    local patterns = RETURN_TO_PATTERNS[currentLang] or RETURN_TO_PATTERNS["en"] -- fallback to English
    
    for _, pattern in ipairs(patterns) do
        local lowerPattern = pattern:lower()
        if lowerText:find(lowerPattern) then
            return true
        end
    end
    
    return false
end

local function trimString(s)
    return s:match("^%s*(.-)%s*$")
end

local function MatchPledgeQuestHash(questName)
    if not questName then return false, nil end
    
    local questHash = HashString(questName)

    -- Get current game language first for efficiency
    local currentLang = GetGameLanguage()

    local dungeonID = PLEDGE_QUEST_HASHES[currentLang] and PLEDGE_QUEST_HASHES[currentLang][questHash]
    if dungeonID then
        return true, dungeonID
    end

    return false, nil
end

-- Module: Collection System (Achievement, Motif, and Set Collection)
local CollectionSystem = {}

function CollectionSystem.GetCached(id, collectionType)
    -- SI_UNIT_NAME == <<C:1>>
    local cache = State.SVAR[collectionType .. "Cache"]
    if cache and cache[id] then
        return unpack(cache[id])
    end
    
    local result = {}
    
    if collectionType == "achievement" then
        local name, _, _, _, completed = GetAchievementInfo(id)
        -- Format the achievement name to remove gender/localization formatting
        name = name and zo_strformat(SI_UNIT_NAME, name) or STRINGS.UNKNOWN
        result = {name, completed or false}
    elseif collectionType == "motif" then
        local name, _, _, _, completed = GetAchievementInfo(id)
        -- Format the achievement name to remove gender/localization formatting
        name = name and zo_strformat(SI_UNIT_NAME, name) or STRINGS.UNKNOWN
        completed = completed or false
        
        local numCriteria = GetAchievementNumCriteria(id)
        local totalObtained = 0
        
        for i = 1, numCriteria do
            local _, numCompleted, numRequired = GetAchievementCriterion(id, i)
            totalObtained = totalObtained + (numCompleted or 0)
        end
        
        result = {name, completed, totalObtained, numCriteria}
    elseif collectionType == "setCollection" then
        local name = GetItemSetName(id)
        -- Format the set name to remove gender markers (^n, ^f, ^m) and other formatting
        name = name and zo_strformat(SI_UNIT_NAME, name) or STRINGS.UNKNOWN
        local total = GetNumItemSetCollectionPieces(id) or 0
        local obtained = GetNumItemSetCollectionSlotsUnlocked(id) or 0
        local completed = (total > 0 and obtained >= total) or false
        
        result = {name, completed, obtained, total}
    end
    
    cache[id] = result
    return unpack(result)
end

function CollectionSystem.BatchGetCompletions(ids, collectionType)
    local results = {}
    for i, id in ipairs(ids) do
        local _, completed = CollectionSystem.GetCached(id, collectionType)
        results[i] = completed
    end
    return results
end

function CollectionSystem.InvalidateCache(id, collectionType)
    local cache = State.SVAR[collectionType .. "Cache"]
    if id then
        cache[id] = nil
    else
        for key in pairs(cache) do
            cache[key] = nil
        end
    end
end

-- Module: Dungeon System
local DungeonSystem = {}

function DungeonSystem.GetData(dungeonId)
    if State.SVAR.dungeonDataCache[dungeonId] then
        return State.SVAR.dungeonDataCache[dungeonId]
    end

    local result = {
        isCleared = false,
        isHMCompleted = false,
        isSpeedCompleted = false,
        isNoDeathCompleted = false,
        isTrifectaCompleted = false,
        areAllSetsCompleted = false,
        isMotifCompleted = false
    }
    
    local dungeonInfo = DungeonData.Index[dungeonId]
    if not dungeonInfo then 
        return result 
    end
    
    -- Check achievements
    local achievements = {
        {dungeonInfo.id, "isCleared"},
        {dungeonInfo.hm, "isHMCompleted"},
        {dungeonInfo.tt, "isSpeedCompleted"},
        {dungeonInfo.nd, "isNoDeathCompleted"},
        {dungeonInfo.tri, "isTrifectaCompleted"},
        {dungeonInfo.motif, "isMotifCompleted"}
    }
    
    for _, achievement in ipairs(achievements) do
        if achievement[1] then
            local _, completed = CollectionSystem.GetCached(achievement[1], "achievement")
            result[achievement[2]] = completed
        end
    end
    
    -- Check set collections
    if dungeonInfo.itemSetIDs and #dungeonInfo.itemSetIDs > 0 then
        local setCompletions = CollectionSystem.BatchGetCompletions(dungeonInfo.itemSetIDs, "setCollection")
        result.areAllSetsCompleted = true
        for i = 1, #setCompletions do
            if not setCompletions[i] then
                result.areAllSetsCompleted = false
                break
            end
        end
    end

    State.SVAR.dungeonDataCache[dungeonId] = result
    return result
end

function DungeonSystem.BuildStatusText(dungeonData, dungeonInfo)
    local parts = {}
    local count = 0
    
    if dungeonInfo.hm or dungeonInfo.tt or dungeonInfo.nd then
        local icons = {
            {State.SVAR.showTrifectaIcon and dungeonInfo.tri, dungeonData.isTrifectaCompleted, ICONS.TRIFECTA, ICONS.TRIFECTA_GREY},
            {State.SVAR.showHardModeIcon and dungeonInfo.hm, dungeonData.isHMCompleted, ICONS.HARDMODE, ICONS.HARDMODE_GREY},
            {State.SVAR.showSpeedrunIcon and dungeonInfo.tt, dungeonData.isSpeedCompleted, ICONS.SPEEDRUN, ICONS.SPEEDRUN_GREY},
            {State.SVAR.showNoDeathIcon and dungeonInfo.nd, dungeonData.isNoDeathCompleted, ICONS.NODEATH, ICONS.NODEATH_GREY}
        }
        
        for _, icon in ipairs(icons) do
            if icon[1] then
                count = count + 1
                parts[count] = icon[2] and icon[3] or icon[4]
            end
        end
    end

    if State.SVAR.showMotifIcon and dungeonInfo.motif then
        count = count + 1
        parts[count] = dungeonData.isMotifCompleted and ICONS.MOTIF or ICONS.MOTIF_GREY
    end

    if State.SVAR.showSetCollectionIcon and dungeonInfo.itemSetIDs then
        count = count + 1
        parts[count] = dungeonData.areAllSetsCompleted and ICONS.SET_COLLECTION or ICONS.SET_COLLECTION_GREY
    end
    
    if State.SVAR.showClearedIcon and dungeonInfo.id then
        count = count + 1
        parts[count] = dungeonData.isCleared and ICONS.CLEARED or ICONS.CLEARED_GREY
    end
    
    return table.concat(parts)
end

function DungeonSystem.InvalidateCache(dungeonId)
    if dungeonId then
        State.SVAR.dungeonDataCache[dungeonId] = nil
    else
        State.SVAR.dungeonDataCache = {}
    end
end

-- Module: Quest System
local QuestSystem = {}
local pledgeQuestMappings = {} -- [questIndex] = {pledgeGiver, dungeonID, questName}
local lastPledgeQuestScan = 0

local function ScanPledgeQuests()
    local currentTime = GetTimeStamp()
    
    if (currentTime - lastPledgeQuestScan) < 5 and next(pledgeQuestMappings) then
        return
    end
    
    for k in pairs(pledgeQuestMappings) do
        pledgeQuestMappings[k] = nil
    end
    
    local numQuests = GetNumJournalQuests()
    
    for i = 1, numQuests do
        local name = GetJournalQuestName(i)
        local questType = GetJournalQuestType(i)
        
        if name and questType == QUEST_TYPE_UNDAUNTED_PLEDGE then
            local hashMatch, dungeonID = MatchPledgeQuestHash(name)
            
            if hashMatch and dungeonID and State.SVAR and State.SVAR.dailyPledges then
                local pledgeGiver = State.SVAR.dailyPledges[dungeonID]
                if pledgeGiver then
                    pledgeQuestMappings[i] = {
                        pledgeGiver = pledgeGiver,
                        dungeonID = dungeonID,
                        questName = name
                    }
                end
            end
        end
    end
    
    lastPledgeQuestScan = currentTime
end

function QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
    if not pledgeGiver then 
        return false, false, nil
    end
    
    local currentTime = GetTimeStamp()
    local cacheKey = "giver_" .. pledgeGiver
    
    if questStatusCache[cacheKey] and (currentTime - lastQuestCacheUpdate) < 5 then
        local cached = questStatusCache[cacheKey]
        pledgeReadyStatus[pledgeGiver] = cached.isCompleted
        return cached.hasQuest, cached.isCompleted, cached.questId
    end
    
    ScanPledgeQuests()
    
    for questIndex, mapping in pairs(pledgeQuestMappings) do
        if mapping.pledgeGiver == pledgeGiver then
            local conditionText = GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP_INDEX, 1)

            local isReadyToTurnIn = ContainsReturnToPattern(conditionText)
            
            questStatusCache[cacheKey] = {
                hasQuest = true,
                isCompleted = isReadyToTurnIn,
                questId = questIndex,
                questName = mapping.questName
            }
            pledgeReadyStatus[pledgeGiver] = isReadyToTurnIn
            lastQuestCacheUpdate = currentTime
            
            return true, isReadyToTurnIn, questIndex
        end
    end
    
    questStatusCache[cacheKey] = {hasQuest = false, isCompleted = false, questId = nil, questName = nil}
    pledgeReadyStatus[pledgeGiver] = false
    lastQuestCacheUpdate = currentTime
    
    return false, false, nil
end

function QuestSystem.GetPledgeQuestName(pledgeGiver)
    local cacheKey = "giver_" .. pledgeGiver
    local cached = questStatusCache[cacheKey]
    
    if cached and cached.questName then
        return cached.questName
    end
    
    local hasQuest = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
    if hasQuest and questStatusCache[cacheKey] then
        return questStatusCache[cacheKey].questName
    end
    
    return nil
end

function QuestSystem.ClearCache(specificGiver)
    if specificGiver then
        -- Clear cache for specific giver only
        local cacheKey = "giver_" .. specificGiver
        questStatusCache[cacheKey] = nil
    else
        -- Clear all cache
        questStatusCache = {}
    end
    lastQuestCacheUpdate = 0
end

-- Module: Pledge Tracking System
local PledgeTrackingSystem = {}

function PledgeTrackingSystem.GetCurrentCharacterName()
    if not cachedPlayerName then
        cachedPlayerName = GetUnitName("player")
    end
    return cachedPlayerName
end

function PledgeTrackingSystem.GetDayTimestamp()
    local currentTime = GetTimeStamp()
    
    if not cachedDayTimestamp or (currentTime - lastTimestampCheck) > 1800 then
        cachedDayTimestamp = math.floor(currentTime / 86400) * 86400
        lastTimestampCheck = currentTime
    end
    
    return cachedDayTimestamp
end

function PledgeTrackingSystem.InitializeCharacterData(characterName)
    local currentDay = PledgeTrackingSystem.GetDayTimestamp()
    
    if not State.SVAR.dailyPledgeCompletion then
        State.SVAR.dailyPledgeCompletion = {
            timestamp = 0,
            characters = {}
        }
    end
    
    if State.SVAR.dailyPledgeCompletion.timestamp < currentDay then
        State.SVAR.dailyPledgeCompletion.timestamp = currentDay
        State.SVAR.dailyPledgeCompletion.characters = {}
    end
    
    if not State.SVAR.dailyPledgeCompletion.characters[characterName] then
        State.SVAR.dailyPledgeCompletion.characters[characterName] = {
            maj = false,
            glirion = false,
            urgarlag = false,
            lastChecked = 0
        }
    else
        local charData = State.SVAR.dailyPledgeCompletion.characters[characterName]
        if not charData.lastChecked then
            charData.lastChecked = 0
        end
    end
end

function PledgeTrackingSystem.MarkPledgeCompleted(pledgeGiver, questName, characterName)
    characterName = characterName or PledgeTrackingSystem.GetCurrentCharacterName()
    if not characterName then return end
    
    PledgeTrackingSystem.InitializeCharacterData(characterName)
    local charData = State.SVAR.dailyPledgeCompletion.characters[characterName]
    
    if pledgeGiver >= 1 and pledgeGiver <= 3 and charData then
        charData[GIVER_NAMES[pledgeGiver]] = true
    end
end

function PledgeTrackingSystem.UpdateCharacterPledgeStatus(force)
    local characterName = PledgeTrackingSystem.GetCurrentCharacterName()
    if not characterName or not DungeonData or not DungeonData.Pledges or not State.SVAR then
        return
    end
    
    PledgeTrackingSystem.InitializeCharacterData(characterName)
    
    local charData = State.SVAR.dailyPledgeCompletion.characters[characterName]
    if not charData then return end
    
    local currentTime = GetTimeStamp()
    
    if not force and (currentTime - charData.lastChecked) < 30 then
        return
    end
    
    charData.lastChecked = currentTime

    if not State.SVAR.dailyPledges or not State.SVAR.lastPledgeUpdate or (currentTime - State.SVAR.lastPledgeUpdate) > 86400 then
        local pledgeUpdateSuccess = pcall(function()
            PledgeSystem.UpdateDaily()
        end)
        
        if not pledgeUpdateSuccess then
            return
        end
    end
    
    for pledgeGiver = 1, 3 do
        local giverKey = GIVER_NAMES[pledgeGiver]
        
        if not charData[giverKey] then
            local hasQuest, isCompleted, questId = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
            
            if hasQuest and isCompleted then
                charData[giverKey] = true
            end
        end
    end
end

function PledgeTrackingSystem.GetPledgeGiverForDungeonID(dungeonID)  
    if not dungeonID then
        return nil
    end
    
    if not State.SVAR.dailyPledges then
        return nil
    end
    
    local pledgeGiver = State.SVAR.dailyPledges[dungeonID] 

    return pledgeGiver
end

function PledgeTrackingSystem.GetCharacterPledgeStatus(characterName)
    characterName = characterName or PledgeTrackingSystem.GetCurrentCharacterName()
    if not characterName then 
        return DEFAULT_PLEDGE_STATUS
    end
    
    PledgeTrackingSystem.InitializeCharacterData(characterName)
    local charData = State.SVAR.dailyPledgeCompletion.characters[characterName]
    
    if not charData then
        return DEFAULT_PLEDGE_STATUS
    end
    
    return {
        maj = charData.maj,
        glirion = charData.glirion,
        urgarlag = charData.urgarlag
    }
end

function PledgeTrackingSystem.IsPledgeCompletedForCharacter(pledgeGiver, characterName)
    characterName = characterName or PledgeTrackingSystem.GetCurrentCharacterName()
    if not characterName then return false end
    
    PledgeTrackingSystem.InitializeCharacterData(characterName)
    local charData = State.SVAR.dailyPledgeCompletion.characters[characterName]
    
    if not charData then return false end
    
    local giverKey = GIVER_NAMES[pledgeGiver]
    
    return giverKey and charData[giverKey] or false
end

-- Module: Pledge System
local PledgeSystem = {}

function PledgeSystem.UpdateDaily()
    if not DungeonData or not DungeonData.Pledges or not State.SVAR then
        return
    end

    local timestamp = GetTimeStamp()
    if not timestamp then
        return
    end
    
    if not State.SVAR.dailyPledges then
        State.SVAR.dailyPledges = {}
    end
    
    local daysSinceBase = math.floor((timestamp - baseTimestamp) / 86400)
    
    local lastUpdateDay = 0
    if State.SVAR.lastPledgeUpdate then
        lastUpdateDay = math.floor((State.SVAR.lastPledgeUpdate - baseTimestamp) / 86400)
    end
    
    if daysSinceBase == lastUpdateDay and State.SVAR.lastPledgeUpdate then
        return
    end
    
    State.SVAR.lastPledgeUpdate = timestamp
    State.SVAR.dailyPledges = {}

    for pledgeGiver = 1, 3 do
        local offset = PledgeSystem.GetDailyOffset(pledgeGiver)
        if offset ~= nil then
            local pledgeList = DungeonData.Pledges[pledgeGiver]
            if pledgeList and type(pledgeList) == "table" and #pledgeList > 0 then
                local pledgeIndex = offset + 1
                if pledgeIndex > 0 and pledgeIndex <= #pledgeList then
                    local todaysPledge = pledgeList[pledgeIndex]
                    if todaysPledge and type(todaysPledge) == "table" and todaysPledge.id and todaysPledge.vetId then
                        State.SVAR.dailyPledges[todaysPledge.id] = pledgeGiver
                        State.SVAR.dailyPledges[todaysPledge.vetId] = pledgeGiver
                    end
                end
            end
        end
    end
end

function PledgeSystem.GetDailyOffset(pledgeGiver)
    if not DungeonData or not DungeonData.Pledges then
        return 0
    end
    
    if not pledgeGiver or type(pledgeGiver) ~= "number" then
        return 0
    end
    
    local pledgeList = DungeonData.Pledges[pledgeGiver]
    if not pledgeList or type(pledgeList) ~= "table" or #pledgeList == 0 then
        return 0
    end
    
    local currentTime = GetTimeStamp()
    
    if not currentTime then
        return 0
    end
    
    local daysSinceBase = math.floor((currentTime - baseTimestamp) / 86400)
    local shift = pledgeList.shift or 0
    
    return (daysSinceBase + shift) % #pledgeList
end

function PledgeSystem.IsDungeonPledge(dungeonId)
    if not DungeonData or not DungeonData.Pledges or not State.SVAR or not dungeonId or type(dungeonId) ~= "number" then
        return false
    end

    local currentTime = GetTimeStamp()
    if currentTime and (not State.SVAR.lastPledgeUpdate or (currentTime - State.SVAR.lastPledgeUpdate) > 86400) then
        PledgeSystem.UpdateDaily()
    end

    if not State.SVAR.dailyPledges then
        return false
    end

    local pledgeGiver = State.SVAR.dailyPledges[dungeonId]
    if not pledgeGiver then
        return false
    end

    local hasQuest, isCompleted, questId = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
    return true, pledgeGiver, hasQuest, isCompleted
end

-- Module: Tooltip System
local TooltipSystem = {}

function TooltipSystem.BuildTooltipText(dungeonId, dungeonInfo, dungeonData, dungeonName)
    local parts = {}
    local count = 2
    
    -- Pre-populate the first two parts
    parts[1] = (COLORS.WHITE or "|cFFFFFF") .. (dungeonName or STRINGS.UNKNOWN) .. (COLORS.RESET or "|r")
    parts[2] = dungeonInfo.isDLC and (" " .. (COLORS.DLC_GREEN or "|c52C977") .. "(" .. (STRINGS.DLC_DUNGEON or STRINGS.UNKNOWN) .. ")" .. (COLORS.RESET or "|r")) or (" " .. (COLORS.GREY or "|c7F8C8D") .. "(" .. STRINGS.BASE_GAME .. ")" .. (COLORS.RESET or "|r"))

    local isPledge, pledgeGiver, hasQuest, isCompleted = PledgeSystem.IsDungeonPledge(dungeonId)
    
    if isPledge and pledgeGiver and STRINGS.PLEDGE_GIVERS and STRINGS.PLEDGE_GIVERS[pledgeGiver] then
        count = count + 1
        parts[count] = "\n\n" .. (COLORS.ORANGE or "|cE67E22") .. (STRINGS.DAILY_PLEDGE or STRINGS.UNKNOWN) .. ":" .. (COLORS.RESET or "|r")

        local pledgeStatus = ""
        if hasQuest then
            if isCompleted then
                pledgeStatus = " - " .. (COLORS.PLEDGE_COMPLETED or "|c27AE60") .. "(" .. (STRINGS.READY_TO_TURN_IN or STRINGS.UNKNOWN) .. ")" .. (COLORS.RESET or "|r")
            else
                pledgeStatus = " - " .. (COLORS.PLEDGE_IN_PROGRESS or "|cF39C12") .. "(" .. (STRINGS.QUEST_IN_PROGRESS or STRINGS.UNKNOWN) .. ")" .. (COLORS.RESET or "|r")
            end
        else
            local characterCompleted = PledgeTrackingSystem.IsPledgeCompletedForCharacter(pledgeGiver)
            
            if characterCompleted then
                pledgeStatus = " - " .. (COLORS.PLEDGE_TURNED_IN or "|c95A5A6") .. "(" .. (STRINGS.ALREADY_COMPLETED_TODAY or STRINGS.UNKNOWN) .. ")" .. (COLORS.RESET or "|r")
            else
                pledgeStatus = " - " .. (COLORS.PLEDGE_AVAILABLE or "|c3498DB") .. "(" .. (STRINGS.AVAILABLE_TO_ACCEPT or STRINGS.UNKNOWN) .. ")" .. (COLORS.RESET or "|r")
            end
        end
        
        count = count + 1

        local pledgeGiverName = STRINGS.PLEDGE_GIVERS[pledgeGiver] or STRINGS.UNKNOWN
        parts[count] = "\n" .. (COLORS.YELLOW or "|cF1C40F") .. pledgeGiverName .. (COLORS.RESET or "|r") .. (pledgeStatus or STRINGS.UNKNOWN)

        if hasQuest then
            local questName = QuestSystem.GetPledgeQuestName(pledgeGiver)
            if questName then
                count = count + 1
                parts[count] = "\n" .. (COLORS.GREY or "|c7F8C8D") .. (STRINGS.QUEST or STRINGS.UNKNOWN) .. ": " .. (questName or STRINGS.UNKNOWN) .. (COLORS.RESET or "|r")
            end
        end
    end
    
    count = count + 1
    parts[count] = "\n\n" .. (COLORS.ORANGE or "|cE67E22") .. (STRINGS.ACHIEVEMENTS or STRINGS.UNKNOWN) .. ":" .. (COLORS.RESET or "|r")

    local questAchievementId = dungeonInfo.id
    if questAchievementId then
        local questName, _ = CollectionSystem.GetCached(questAchievementId, "achievement")
        local nameColor = dungeonData.isCleared and (COLORS.GREEN or "|c2ECC71") or (COLORS.GREY or "|c7F8C8D")
        count = count + 1
        parts[count] = "\n" .. (ICONS.TOOLTIP_QUEST or "") .. nameColor .. (questName or STRINGS.UNKNOWN) .. (COLORS.RESET or "|r")
    else
        count = count + 1
        parts[count] = "\n" .. (ICONS.TOOLTIP_QUEST or "") .. (COLORS.GREY or "|c7F8C8D") .. STRINGS.UNKNOWN .. (COLORS.RESET or "|r")
    end
    
    if dungeonInfo.hm or dungeonInfo.tt or dungeonInfo.nd then
        count = count + 1
        parts[count] = "\n\n" .. COLORS.ORANGE .. STRINGS.VETERAN_ACHIEVEMENTS .. ":" .. COLORS.RESET
        
        if dungeonInfo.hm then
            local hmName, _ = CollectionSystem.GetCached(dungeonInfo.hm, "achievement")
            local nameColor = dungeonData.isHMCompleted and COLORS.GREEN or COLORS.GREY
            count = count + 1
            parts[count] = "\n" .. ICONS.TOOLTIP_HM .. nameColor .. (hmName or STRINGS.UNKNOWN) .. COLORS.RESET
        end
        
        if dungeonInfo.tt then
            local speedName, _ = CollectionSystem.GetCached(dungeonInfo.tt, "achievement")
            local nameColor = dungeonData.isSpeedCompleted and COLORS.GREEN or COLORS.GREY
            count = count + 1
            parts[count] = "\n" .. ICONS.TOOLTIP_SPEED .. nameColor .. (speedName or STRINGS.UNKNOWN) .. COLORS.RESET
        end
        
        if dungeonInfo.nd then
            local noDeathName, _ = CollectionSystem.GetCached(dungeonInfo.nd, "achievement")
            local nameColor = dungeonData.isNoDeathCompleted and COLORS.GREEN or COLORS.GREY
            count = count + 1
            parts[count] = "\n" .. ICONS.TOOLTIP_NODEATH .. nameColor .. (noDeathName or STRINGS.UNKNOWN) .. COLORS.RESET
        end
        
        if dungeonInfo.tri then
            local trifectaName, _ = CollectionSystem.GetCached(dungeonInfo.tri, "achievement")
            local nameColor = dungeonData.isTrifectaCompleted and COLORS.GREEN or COLORS.GREY
            
            count = count + 1
            parts[count] = "\n\n" .. COLORS.ORANGE .. STRINGS.TRIFECTA .. ":" .. COLORS.RESET .. " " .. COLORS.GREY .. "(All 3 Veteran)" .. COLORS.RESET
            count = count + 1
            parts[count] = "\n" .. ICONS.TOOLTIP_TRIFECTA .. nameColor .. (trifectaName or STRINGS.UNKNOWN) .. COLORS.RESET
        end
    end

    if dungeonInfo.motif then
        count = count + 1
        parts[count] = "\n\n" .. COLORS.ORANGE .. STRINGS.MOTIF .. ":" .. COLORS.RESET

        local motifName, completed, obtained, total = CollectionSystem.GetCached(dungeonInfo.motif, "motif")
        local nameColor = completed and COLORS.GREEN or COLORS.GREY
        
        count = count + 1
        parts[count] = "\n" .. ICONS.TOOLTIP_MOTIF .. nameColor .. (motifName or STRINGS.UNKNOWN) .. " (" .. (obtained or 0) .. "/" .. (total or 0) .. ")" .. COLORS.RESET
    end

    if dungeonInfo.itemSetIDs and #dungeonInfo.itemSetIDs > 0 then
        count = count + 1
        parts[count] = "\n\n" .. COLORS.ORANGE .. STRINGS.SETS .. ":" .. COLORS.RESET
        
        for _, setId in ipairs(dungeonInfo.itemSetIDs) do
            local setName, completed, obtained, total = CollectionSystem.GetCached(setId, "setCollection")
            local nameColor = completed and COLORS.GREEN or COLORS.GREY
            
            count = count + 1
            parts[count] = "\n" .. ICONS.TOOLTIP_SET_COLLECTION .. nameColor .. (setName or STRINGS.UNKNOWN) .. " (" .. (obtained or 0) .. "/" .. (total or 0) .. ")" .. COLORS.RESET
        end
    end
    
    return table.concat(parts)
end

function TooltipSystem.CreateDungeonTooltip(dungeonId)
    local dungeonInfo = DungeonData.Index[dungeonId]
    if not dungeonInfo then 
        return COLORS.WHITE .. GetString(ZDFT_INVALID_DUNGEON_DATA_TEXT) .. COLORS.RESET 
    end
    
    local dungeonData = DungeonSystem.GetData(dungeonId)
    local dungeonName = GetActivityName(dungeonId) or STRINGS.UNKNOWN

    return TooltipSystem.BuildTooltipText(dungeonId, dungeonInfo, dungeonData, dungeonName)
end

-- Module: UI System
local UISystem = {}
local lastUIRefresh = 0
local UI_REFRESH_THROTTLE = 100

function UISystem.GetCachedContainer(containerId)
    local now = GetGameTimeMilliseconds()
    if now - Cache.lastContainerCheck > CONFIG.CONTAINER_CHECK_INTERVAL then
        Cache.containers = {}
        Cache.lastContainerCheck = now
    end
    
    if not Cache.containers[containerId] then
        Cache.containers[containerId] = _G["ZO_DungeonFinder_KeyboardListSectionScrollChildContainer" .. containerId]
    end
    
    return Cache.containers[containerId]
end

function UISystem.SetupMouseHandlers(control)
    local function onMouseEnter(self)
        if self.originalMouseEnter then
            self.originalMouseEnter(self)
        end
        
        if self.isPledge and State.SVAR.highlightPledges and self.text then
            if not self.originalR then
                self.originalR, self.originalG, self.originalB = self.text:GetColor()
            end
            
            local isPledge, pledgeGiver, hasQuest, isCompleted = PledgeSystem.IsDungeonPledge(self.dungeonId or (self.node and self.node.data and self.node.data.id))
            
            local characterCompleted = false
            if isPledge and pledgeGiver then
                characterCompleted = PledgeTrackingSystem.IsPledgeCompletedForCharacter(pledgeGiver)
            end
            
            local isReadyToTurnIn = false
            
            if hasQuest then
                isReadyToTurnIn = isCompleted
                
                if not isReadyToTurnIn and pledgeReadyStatus[pledgeGiver] then
                    isReadyToTurnIn = pledgeReadyStatus[pledgeGiver]
                end
                
                if not isReadyToTurnIn then
                    local hasQuest2, isCompleted2 = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
                    if hasQuest2 then
                        isReadyToTurnIn = isCompleted2
                    end
                end
            end
            
            local colors
            if hasQuest and isReadyToTurnIn then
                colors = HOVER_COLORS.COMPLETED_BRIGHT
            elseif characterCompleted then
                colors = HOVER_COLORS.COMPLETED_GREY_BRIGHT
            elseif hasQuest then
                colors = HOVER_COLORS.QUEST_BRIGHT
            else
                colors = HOVER_COLORS.AVAILABLE_BRIGHT
            end
            
            self.text:SetColor(unpack(colors))
        end
    end
    
    local function onMouseExit(self)
        if self.originalMouseExit then
            self.originalMouseExit(self)
        end
        
        if self.isPledge and State.SVAR.highlightPledges and self.text then
            local isPledge, pledgeGiver, hasQuest, isCompleted = PledgeSystem.IsDungeonPledge(self.dungeonId or (self.node and self.node.data and self.node.data.id))
            
            local characterCompleted = false
            if isPledge and pledgeGiver then
                characterCompleted = PledgeTrackingSystem.IsPledgeCompletedForCharacter(pledgeGiver)
            end
            
            local isReadyToTurnIn = false
            
            if hasQuest then
                isReadyToTurnIn = isCompleted
                
                if not isReadyToTurnIn and pledgeReadyStatus[pledgeGiver] then
                    isReadyToTurnIn = pledgeReadyStatus[pledgeGiver]
                end
                
                if not isReadyToTurnIn then
                    local hasQuest2, isCompleted2 = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
                    if hasQuest2 then
                        isReadyToTurnIn = isCompleted2
                    end
                end
            end
            
            local colors
            if hasQuest and isReadyToTurnIn then
                colors = HOVER_COLORS.COMPLETED_NORMAL
            elseif characterCompleted then
                colors = HOVER_COLORS.COMPLETED_GREY_NORMAL
            elseif hasQuest then
                colors = HOVER_COLORS.QUEST_NORMAL
            else
                colors = HOVER_COLORS.AVAILABLE_NORMAL
            end
            
            self.text:SetColor(unpack(colors))
        elseif self.text and self.originalR then
            self.text:SetColor(self.originalR, self.originalG, self.originalB, 1)
        end
    end

    control.originalMouseEnter = control:GetHandler("OnMouseEnter")
    control.originalMouseExit = control:GetHandler("OnMouseExit")
    
    control:SetHandler("OnMouseEnter", onMouseEnter)
    control:SetHandler("OnMouseExit", onMouseExit)
end

function UISystem.UpdatePledgeStatus(control, dungeonId)
    if not control.text then return end

    -- Store dungeonId for mouse handlers
    control.dungeonId = dungeonId

    local isPledge, pledgeGiver, hasQuest, isCompleted = PledgeSystem.IsDungeonPledge(dungeonId)
    
    local characterCompleted = false
    if isPledge and pledgeGiver then
        characterCompleted = PledgeTrackingSystem.IsPledgeCompletedForCharacter(pledgeGiver)
    end
    
    if not control.originalR then
        control.originalR, control.originalG, control.originalB = control.text:GetColor()
    end
    
    local originalText = control.text:GetText()
    
    -- Optimized icon removal with single pass
    originalText = originalText:gsub("|t%d+:%d+:[^|]+|t%s*", "")
    originalText = trimString(originalText)
    
    if isPledge and State.SVAR.showPledgeIcon then
        control.text:SetText(originalText .. ICONS.PLEDGE)
    else
        control.text:SetText(originalText)
    end
    
    if isPledge and State.SVAR.highlightPledges then
        local isReadyToTurnIn = false
        
        if hasQuest then
            isReadyToTurnIn = isCompleted
            
            if not isReadyToTurnIn and pledgeReadyStatus[pledgeGiver] then
                isReadyToTurnIn = pledgeReadyStatus[pledgeGiver]
            end
            
            if not isReadyToTurnIn then
                local hasQuest2, isCompleted2 = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
                if hasQuest2 then
                    isReadyToTurnIn = isCompleted2
                end
            end
        end
        
        local colors
        -- IMPORTANT: Check ready-to-turn-in status BEFORE character completion
        -- A quest that's ready to turn in should show green even if character completed other pledges
        if hasQuest and isReadyToTurnIn then
            -- Has quest and it's ready to turn in - GREEN (highest priority)
            colors = HOVER_COLORS.COMPLETED_NORMAL
        elseif characterCompleted then
            -- Character has already completed this pledge today - GREY
            colors = HOVER_COLORS.COMPLETED_GREY_NORMAL
        elseif hasQuest then
            -- Has quest but not ready to turn in - ORANGE
            colors = HOVER_COLORS.QUEST_NORMAL
        else
            -- Available to accept - BLUE
            colors = HOVER_COLORS.AVAILABLE_NORMAL
        end
        
        control.text:SetColor(unpack(colors))
    elseif not isPledge and control.originalR then
        control.text:SetColor(control.originalR, control.originalG, control.originalB, 1)
    end
    
    control.isPledge = isPledge
    control.hasQuest = hasQuest
    control.isCompleted = isReadyToTurnIn
    control.characterCompleted = characterCompleted
    
    if not control.originalMouseEnter then
        UISystem.SetupMouseHandlers(control)
    end
end

function UISystem.CreateAchievementLabel(control)
    if not control then return end
    
    local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    
    local anchorTarget = control.check or control
    label:SetAnchor(RIGHT, anchorTarget, RIGHT, 520, 0)
    label:SetDrawLayer(DL_TEXT)
    label:SetDrawTier(DT_HIGH)

    label:SetMouseEnabled(true)
    label:SetHandler("OnMouseEnter", function(self)
        local dungeonId = control.node and control.node.data and control.node.data.id
        if dungeonId then
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, TooltipSystem.CreateDungeonTooltip(dungeonId))
        end
    end)
    
    label:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
    
    -- Add click handler for achievement navigation
    label:SetHandler("OnMouseUp", function(self, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            local dungeonId = control.node and control.node.data and control.node.data.id
            if dungeonId then
                UISystem.HandleAchievementIconClick(dungeonId)
            end
        end
    end)
    
    control.achievementLabel = label
end

function UISystem.HandleAchievementIconClick(dungeonId)
    local dungeonInfo = DungeonData.Index[dungeonId]
    if not dungeonInfo then return end
    
    ClearMenu()
    
    local menuItems = {}
    
    -- Add completion achievement if it exists
    if dungeonInfo.id then
        local achievementName, _ = CollectionSystem.GetCached(dungeonInfo.id, "achievement")
        table.insert(menuItems, {
            text = GetString(SI_DUNGEON_FINDER_GENERAL_ACTIVITY_DESCRIPTOR) .. ": " .. achievementName,
            callback = function() SYSTEMS:GetObject("achievements"):ShowAchievement(dungeonInfo.id) end
        })
    end
    
    -- Add veteran achievements if they exist
    if dungeonInfo.hm or dungeonInfo.tt or dungeonInfo.nd or dungeonInfo.tri then
        if #menuItems > 0 then
            table.insert(menuItems, { isDivider = true })
        end

        local veteranAchievements = {
            {dungeonInfo.hm, GetString(ZDFT_HARDMODE_TEXT)},
            {dungeonInfo.tt, GetString(ZDFT_SPEEDRUN_TEXT)},
            {dungeonInfo.nd, GetString(ZDFT_NODEATH_TEXT)},
            {dungeonInfo.tri, STRINGS.TRIFECTA}
        }
        
        for _, achievement in ipairs(veteranAchievements) do
            if achievement[1] then
                local achName, _ = CollectionSystem.GetCached(achievement[1], "achievement")
                table.insert(menuItems, {
                    text = achievement[2] .. ": " .. achName,
                    callback = function() SYSTEMS:GetObject("achievements"):ShowAchievement(achievement[1]) end
                })
            end
        end
    end
    
    -- Add motif achievement if it exists
    if dungeonInfo.motif then
        if #menuItems > 0 then
            table.insert(menuItems, { isDivider = true })
        end
        
        local motifName, _ = CollectionSystem.GetCached(dungeonInfo.motif, "motif")
        table.insert(menuItems, {
            text = STRINGS.MOTIF .. ": " .. motifName,
            callback = function() SYSTEMS:GetObject("achievements"):ShowAchievement(dungeonInfo.motif) end
        })
    end
    
    -- Add menu items
    for _, item in ipairs(menuItems) do
        if item.isDivider then
            AddMenuItem("|t300:4:esoui/art/miscellaneous/wide_divider_right.dds|t", function() end, MENU_ADD_OPTION_LABEL, nil, DEFAULT_TEXT_COLOR, DEFAULT_TEXT_HIGHLIGHT, 0, TEXT_ALIGN_LEFT, nil, nil, nil, false)
        else
            AddMenuItem(item.text, item.callback)
        end
    end
    
    ShowMenu(control)
end

function UISystem.UpdateDungeonEntry(control, dungeonId)
    if not control or not dungeonId then return end
    
    local dungeonInfo = DungeonData.Index[dungeonId]
    if not dungeonInfo then return end
    
    local dungeonData = DungeonSystem.GetData(dungeonId)
        
    if not control.achievementLabel then
        UISystem.CreateAchievementLabel(control)
    else
        control.achievementLabel:SetHidden(false)
    end
    
    local statusText = DungeonSystem.BuildStatusText(dungeonData, dungeonInfo)
    control.achievementLabel:SetText(statusText)
    
    UISystem.UpdatePledgeStatus(control, dungeonId)
end

function UISystem.RefreshAllDungeonEntries()
    if not State.isInitialized then return end
    
    local currentTime = GetGameTimeMilliseconds()
    if (currentTime - lastUIRefresh) < UI_REFRESH_THROTTLE then
        return
    end
    lastUIRefresh = currentTime
    
    for i = 2, 3 do
        local container = UISystem.GetCachedContainer(i)
        if container then
            for j = 1, container:GetNumChildren() do
                local control = container:GetChild(j)
                
                if control and control.node and control.node.data and control.node.data.id then
                    local dungeonId = control.node.data.id
                    if type(dungeonId) == "number" then
                        local success, err = pcall(UISystem.UpdateDungeonEntry, control, dungeonId)
                        if not success then
                            CHAT_ROUTER:AddSystemMessage("ZaiDFTools: Error updating dungeon entry: " .. tostring(err))
                        end
                    end
                end
            end
        end
    end
end

function UISystem.RefreshPledgeDungeonEntries()
    if not State.isInitialized or not State.SVAR.dailyPledges then return end
    
    local currentTime = GetGameTimeMilliseconds()
    if (currentTime - lastUIRefresh) < UI_REFRESH_THROTTLE then
        return
    end
    lastUIRefresh = currentTime
    
    local pledgeDungeonIds = {}
    for dungeonId, _ in pairs(State.SVAR.dailyPledges) do
        pledgeDungeonIds[dungeonId] = true
    end
    
    for i = 2, 3 do
        local container = UISystem.GetCachedContainer(i)
        if container then
            for j = 1, container:GetNumChildren() do
                local control = container:GetChild(j)
                
                if control and control.node and control.node.data and control.node.data.id then
                    local dungeonId = control.node.data.id

                    if pledgeDungeonIds[dungeonId] then
                        local success, err = pcall(UISystem.UpdateDungeonEntry, control, dungeonId)
                        if not success then
                            CHAT_ROUTER:AddSystemMessage("ZaiDFTools: Error updating dungeon entry: " .. tostring(err))
                        end
                    end
                end
            end
        end
    end
end

-- Module: Button System
local ButtonSystem = {}

function ButtonSystem.GetDifficultySelection(difficultyType)
    local selectNormal, selectVeteran = false, false
    
    if difficultyType == "follow" then
        local currentDifficulty = ZO_GetEffectiveDungeonDifficulty()
        selectVeteran = (currentDifficulty == DUNGEON_DIFFICULTY_VETERAN)
        selectNormal = not selectVeteran
    elseif difficultyType == "veteran" then
        selectVeteran = true
    elseif difficultyType == "normal" then
        selectNormal = true
    elseif difficultyType == "both" then
        selectNormal, selectVeteran = true, true
    end
    
    return selectNormal, selectVeteran
end

function ButtonSystem.ProcessDungeonSelection(filterFunc, difficulty, alertMessages)
    local selected = 0
    local total = 0
    local controls = {}
    
    for i = 2, 3 do
        local container = UISystem.GetCachedContainer(i)
        if container then
            for j = 1, container:GetNumChildren() do
                local control = container:GetChild(j)
                if control and control.node and control.node.data then
                    local dungeonId = control.node.data.id
                    if dungeonId and filterFunc(dungeonId) then
                        total = total + 1
                        table.insert(controls, control)
                        
                        if control.check and control.check:GetState() == BSTATE_PRESSED then
                            selected = selected + 1
                        end
                    end
                end
            end
        end
    end
    
    if total == 0 then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, alertMessages.none)
        return
    end
    
    -- Deselect if any are selected
    if selected > 0 then
        for _, control in ipairs(controls) do
            if control.check and control.check:GetState() == BSTATE_PRESSED then
                ZO_CheckButton_OnClicked(control.check)
                if control.node and control.node.data then
                    ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(control.node.data)
                end
            end
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.BOOK_CLOSE, string.format(alertMessages.deselected, selected))
        return
    end
    
    -- Select matching entries
    local selectNormal, selectVeteran = ButtonSystem.GetDifficultySelection(difficulty)
    selected = 0
    
    for i = 2, 3 do
        local shouldSelect = (i == 2 and selectNormal) or (i == 3 and selectVeteran)
        
        if shouldSelect then
            local container = UISystem.GetCachedContainer(i)
            if container then
                for j = 1, container:GetNumChildren() do
                    local control = container:GetChild(j)
                    if control and control.node and control.node.data then
                        local dungeonId = control.node.data.id
                        if dungeonId and filterFunc(dungeonId) then
                            if control.check and control.check:GetState() ~= BSTATE_PRESSED then
                                ZO_CheckButton_OnClicked(control.check)
                                ZO_ACTIVITY_FINDER_ROOT_MANAGER:ToggleLocationSelected(control.node.data)
                                selected = selected + 1
                            end
                        end
                    end
                end
            end
        end
    end
    
    if selected > 0 then
        local difficultyText = selectNormal and selectVeteran and GetString(ZDFT_NORMAL_VETERAN) or 
                              selectVeteran and GetString(SI_DUNGEONDIFFICULTY2) or 
                              GetString(SI_DUNGEONDIFFICULTY1)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.POSITIVE_CLICK, string.format(alertMessages.selected, selected, difficultyText))
    else
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, alertMessages.none)
    end
end

function ButtonSystem.SwitchToSpecificDungeonsIfNeeded(callback)
    local filterDropdown = ZO_DungeonFinder_KeyboardFilter
    if not filterDropdown then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(ZDFT_COULD_NOT_FIND_FILTER))
        return
    end
    
    local items = filterDropdown.m_comboBox and filterDropdown.m_comboBox.m_sortedItems
    if not items or #items < 3 then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(ZDFT_COULD_NOT_ACCESS_DROPDOWN))
        return
    end
    
    local currentItem = filterDropdown.m_comboBox.m_selectedItemData
    local needsTabSwitch = not (currentItem and currentItem.name == GetString(SI_DUNGEON_FINDER_SPECIFIC_FILTER_TEXT))
    
    if needsTabSwitch then
        filterDropdown.m_comboBox:SelectItem(items[3])
        zo_callLater(callback, 500)
    else
        callback()
    end
end

-- Pledge Button System
function ButtonSystem.CheckPledges()
    PledgeSystem.UpdateDaily()
    
    ButtonSystem.SwitchToSpecificDungeonsIfNeeded(function()
        ButtonSystem.ProcessDungeonSelection(
            function(dungeonId) return PledgeSystem.IsDungeonPledge(dungeonId) end,
            State.SVAR.pledgeDifficulty,
            {
                none = GetString(ZDFT_NO_PLEDGES_FOUND_TEXT),
                deselected = GetString(ZDFT_DESELECTED_PLEDGES_TEXT),
                selected = GetString(ZDFT_SELECTED_PLEDGES_FORMAT)
            }
        )
    end)
end

function ButtonSystem.CreatePledgeButton()
    local parent = ZO_DungeonFinder_Keyboard
    if not parent or not State.SVAR.showPledgeButton then return end
    
    if not State.pledgeButton then
        State.pledgeButton = WINDOW_MANAGER:CreateControlFromVirtual("ZUI_PledgesCheck", parent, "ZO_DefaultButton")
        State.pledgeButton:SetDimensions(220, 28)
        State.pledgeButton:SetText(GetString(ZDFT_SELECT_PLEDGES_BUTTON))
        State.pledgeButton:ClearAnchors()
        State.pledgeButton:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)
        State.pledgeButton:SetClickSound("Click")
        State.pledgeButton:SetHandler("OnClicked", ButtonSystem.CheckPledges)
        State.pledgeButton:SetDrawTier(2)
    end
    
    State.pledgeButton:SetHidden(not State.SVAR.showPledgeButton)
end

function ButtonSystem.UpdatePledgeButtonVisibility()
    if State.pledgeButton then
        State.pledgeButton:SetHidden(not State.SVAR.showPledgeButton)
    elseif State.SVAR.showPledgeButton then
        ButtonSystem.CreatePledgeButton()
    end
end

-- Collection Button System
function ButtonSystem.HasIncompleteCollections(dungeonId)
    local dungeonInfo = DungeonData.Index[dungeonId]
    if not dungeonInfo then return false end
    
    local checkSets = State.SVAR.collectionButtonType == "sets" or State.SVAR.collectionButtonType == "both"
    local checkMotifs = State.SVAR.collectionButtonType == "motifs" or State.SVAR.collectionButtonType == "both"
    
    if checkSets and dungeonInfo.itemSetIDs then
        for _, setId in ipairs(dungeonInfo.itemSetIDs) do
            local _, completed = CollectionSystem.GetCached(setId, "setCollection")
            if not completed then
                return true
            end
        end
    end
    
    if checkMotifs and dungeonInfo.motif then
        local _, completed = CollectionSystem.GetCached(dungeonInfo.motif, "motif")
        if not completed then
            return true
        end
    end
    
    return false
end

function ButtonSystem.CheckCollections()
    ButtonSystem.SwitchToSpecificDungeonsIfNeeded(function()
        local typeText = State.SVAR.collectionButtonType == "sets" and GetString(ZDFT_SETS_TEXT) or 
                        State.SVAR.collectionButtonType == "motifs" and GetString(ZDFT_MOTIFS_TEXT) or 
                        STRINGS.COLLECTIONS
        
        ButtonSystem.ProcessDungeonSelection(
            ButtonSystem.HasIncompleteCollections,
            State.SVAR.collectionButtonDifficulty,
            {
                none = string.format(GetString(ZDFT_NO_COLLECTIONS_FOUND_TEXT), typeText),
                deselected = GetString(ZDFT_DESELECTED_COLLECTIONS_TEXT),
                selected = GetString(ZDFT_SELECTED_COLLECTIONS_FORMAT)
            }
        )
    end)
end

function ButtonSystem.CreateCollectionButton()
    local parent = ZO_DungeonFinder_Keyboard
    if not parent or not State.SVAR.showCollectionButton then return end
    
    if not State.collectionButton then
        State.collectionButton = WINDOW_MANAGER:CreateControlFromVirtual("ZUI_CollectionCheck", parent, "ZO_DefaultButton")
        State.collectionButton:SetDimensions(220, 28)
        State.collectionButton:ClearAnchors()
        State.collectionButton:SetAnchor(BOTTOMLEFT, parent, BOTTOMLEFT, 0, 0)
        State.collectionButton:SetClickSound("Click")
        State.collectionButton:SetHandler("OnClicked", ButtonSystem.CheckCollections)
        State.collectionButton:SetDrawTier(2)
        
        ButtonSystem.UpdateCollectionButtonText()
    end
    
    State.collectionButton:SetHidden(not State.SVAR.showCollectionButton)
end

function ButtonSystem.UpdateCollectionButtonVisibility()
    if State.collectionButton then
        State.collectionButton:SetHidden(not State.SVAR.showCollectionButton)
    elseif State.SVAR.showCollectionButton then
        ButtonSystem.CreateCollectionButton()
    end
end

function ButtonSystem.UpdateCollectionButtonText()
    if State.collectionButton then
        local typeText = State.SVAR.collectionButtonType == "sets" and GetString(ZDFT_SETS_TEXT) or 
                        State.SVAR.collectionButtonType == "motifs" and GetString(ZDFT_MOTIFS_TEXT) or 
                        STRINGS.COLLECTIONS
        State.collectionButton:SetText(string.format(GetString(ZDFT_SELECT_COLLECTIONS_BUTTON_FORMAT), typeText))
    end
end

-- Module: Settings System
local SettingsSystem = {}

function SettingsSystem.Donation()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function() 
        ZO_MailSendToField:SetText("@ZaiZah")
        ZO_MailSendSubjectField:SetText("Donation for Zai's Dungeon Finder Tools")
        ZO_MailSendBodyField:SetText("Thanks for the great addon! Here's a donation to support your work.")
        ZO_MailSendBodyField:TakeFocus()
    end, 250)
end

function SettingsSystem.Register()
    local panelId = "ZDFTSettingsPanel"
    
    LAM2:RegisterAddonPanel(panelId, {
        type = "panel",
        name = CONFIG.LONG_NAME,
        displayName = CONFIG.LONG_NAME,
        author = CONFIG.AUTHOR,
        version = CONFIG.VERSION,
        donation = SettingsSystem.Donation,
        slashCommand = "/zdft",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    local function createCheckbox(name, tooltip, getFunc, setFunc, width)
        return {
            type = "checkbox",
            name = GetString(name),
            tooltip = GetString(tooltip) or "",
            getFunc = getFunc,
            setFunc = setFunc,
            width = width or "half",
        }
    end

    local function createDropdown(name, tooltip, choices, choicesValues, getFunc, setFunc, default, width)
        return {
            type = "dropdown",
            name = GetString(name),
            tooltip = GetString(tooltip) or "",
            choices = choices,
            choicesValues = choicesValues,
            getFunc = getFunc,
            setFunc = setFunc,
            default = default,
            width = width or "half",
        }
    end

    local function clearAllCaches()
        -- Show warning dialog first
        ZO_Dialogs_ShowDialog("ZDFT_CLEAR_CACHE_CONFIRM")
    end 

    local options = {
        {
            type = "header",
            name = GetString(ZDFT_SETTINGS_ACHIEVEMENT_ICONS),
        },
        createCheckbox(ZDFT_SETTINGS_SHOW_TRIFECTA, ZDFT_SETTINGS_SHOW_TRIFECTA_TT, 
            function() return State.SVAR.showTrifectaIcon end,
            function(value) State.SVAR.showTrifectaIcon = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_HARDMODE, ZDFT_SETTINGS_SHOW_HARDMODE_TT,
            function() return State.SVAR.showHardModeIcon end,
            function(value) State.SVAR.showHardModeIcon = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_NODEATH, ZDFT_SETTINGS_SHOW_NODEATH_TT,
            function() return State.SVAR.showNoDeathIcon end,
            function(value) State.SVAR.showNoDeathIcon = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_SPEEDRUN, ZDFT_SETTINGS_SHOW_SPEEDRUN_TT,
            function() return State.SVAR.showSpeedrunIcon end,
            function(value) State.SVAR.showSpeedrunIcon = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_CLEARED, ZDFT_SETTINGS_SHOW_CLEARED_TT,
            function() return State.SVAR.showClearedIcon end,
            function(value) State.SVAR.showClearedIcon = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_MOTIF, ZDFT_SETTINGS_SHOW_MOTIF_TT,
            function() return State.SVAR.showMotifIcon end,
            function(value) State.SVAR.showMotifIcon = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_SET, ZDFT_SETTINGS_SHOW_SET_TT,
            function() return State.SVAR.showSetCollectionIcon end,
            function(value) State.SVAR.showSetCollectionIcon = value; UISystem.RefreshAllDungeonEntries() end),
        
        { type = "divider", width = "full" },
        
        {
            type = "header",
            name = GetString(ZDFT_SETTINGS_PLEDGE),
        },
        createCheckbox(ZDFT_SETTINGS_HIGHLIGHT_PLEDGES, ZDFT_SETTINGS_HIGHLIGHT_PLEDGES_TT,
            function() return State.SVAR.highlightPledges end,
            function(value) State.SVAR.highlightPledges = value; UISystem.RefreshAllDungeonEntries() end),
        createCheckbox(ZDFT_SETTINGS_SHOW_PLEDGE_ICON, ZDFT_SETTINGS_SHOW_PLEDGE_ICON_TT,
            function() return State.SVAR.showPledgeIcon end,
            function(value) State.SVAR.showPledgeIcon = value; UISystem.RefreshAllDungeonEntries() end),
        
        { type = "divider", width = "full" },
        
        {
            type = "header",
            name = GetString(ZDFT_SETTINGS_COLLECTIONS),
        },
        createCheckbox(ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON, ZDFT_SETTINGS_SHOW_COLLECTION_BUTTON_TT,
            function() return State.SVAR.showCollectionButton end,
            function(value) State.SVAR.showCollectionButton = value; ButtonSystem.UpdateCollectionButtonVisibility() end, "full"),
        createDropdown(ZDFT_SETTINGS_COLLECTION_TYPE, ZDFT_SETTINGS_COLLECTION_TYPE_TT,
            {
                GetString(ZDFT_SETTINGS_COLLECTION_SETS),
                GetString(ZDFT_SETTINGS_COLLECTION_MOTIFS),
                GetString(ZDFT_SETTINGS_COLLECTION_BOTH)
            },
            {"sets", "motifs", "both"},
            function() return State.SVAR.collectionButtonType end,
            function(value) State.SVAR.collectionButtonType = value; ButtonSystem.UpdateCollectionButtonText() end,
            "sets"),
        createDropdown(ZDFT_SETTINGS_COLLECTION_DIFFICULTY, ZDFT_SETTINGS_COLLECTION_DIFFICULTY_TT,
            {
                GetString(ZDFT_SETTINGS_FOLLOW_FINDER),
                GetString(ZDFT_SETTINGS_ALWAYS_NORMAL),
                GetString(ZDFT_SETTINGS_ALWAYS_VETERAN),
                GetString(ZDFT_SETTINGS_BOTH_DIFFICULTIES)
            },
            {"follow", "normal", "veteran", "both"},
            function() return State.SVAR.collectionButtonDifficulty end,
            function(value) State.SVAR.collectionButtonDifficulty = value end,
            "follow"),
        
        { type = "divider", width = "full" },
        
        createCheckbox(ZDFT_SETTINGS_SHOW_BUTTON, ZDFT_SETTINGS_SHOW_BUTTON_TT,
            function() return State.SVAR.showPledgeButton end,
            function(value) State.SVAR.showPledgeButton = value; ButtonSystem.UpdatePledgeButtonVisibility() end, "full"),
        createDropdown(ZDFT_SETTINGS_PLEDGE_DIFFICULTY, ZDFT_SETTINGS_PLEDGE_DIFFICULTY_TT,
            {
                GetString(ZDFT_SETTINGS_FOLLOW_FINDER),
                GetString(ZDFT_SETTINGS_ALWAYS_NORMAL),
                GetString(ZDFT_SETTINGS_ALWAYS_VETERAN),
                GetString(ZDFT_SETTINGS_BOTH_DIFFICULTIES)
            },
            {"follow", "normal", "veteran", "both"},
            function() return State.SVAR.pledgeDifficulty end,
            function(value) State.SVAR.pledgeDifficulty = value end,
            "follow", "full"),
        
        { type = "divider", width = "full" },
        

        {
            type = "header",
            name = "Cache Management",
        },
        {
            type = "description",
            title = "Clear All Caches",
            text = "|cFF6B6BWarning:|r This will clear all cached achievement, dungeon, set collection, and motif data. The UI will reload and regenerate fresh cache data from the game. This may take a moment to complete and should only be used if you're experiencing data issues.",
            width = "full",
        },
        {
            type = "button",
            name = "Clear All Caches & Reload UI",
            warning = "Clears all cached data and reloads the UI to regenerate fresh cache. Use this if you're experiencing incorrect achievement or collection data.",
            func = clearAllCaches,
            width = "full",
        },
        
        { type = "divider", width = "full" },



        {
            type = "description",
            title = GetString(ZDFT_COLOR_LEGEND_TITLE),
            text = COLORS.PLEDGE_AVAILABLE .. GetString(ZDFT_COLOR_LEGEND_BLUE) .. COLORS.RESET .. "\n" ..
                   COLORS.PLEDGE_IN_PROGRESS .. GetString(ZDFT_COLOR_LEGEND_ORANGE) .. COLORS.RESET .. "\n" ..
                   COLORS.PLEDGE_COMPLETED .. GetString(ZDFT_COLOR_LEGEND_GREEN) .. COLORS.RESET .. "\n" ..
                   COLORS.PLEDGE_TURNED_IN .. GetString(ZDFT_COLOR_LEGEND_GREY) .. COLORS.RESET,
            width = "half",
        },

        {
            type = "description",
            title = GetString(ZDFT_TODAYS_PLEDGE_STATUS),
            text = function()
                local status = PledgeTrackingSystem.GetCharacterPledgeStatus()
                local parts = {}
                local statusKeys = {"maj", "glirion", "urgarlag"}
                
                PledgeSystem.UpdateDaily()
                
                for i = 1, 3 do
                    local completed = status[statusKeys[i]]
                    local color = completed and COLORS.PLEDGE_COMPLETED or COLORS.PLEDGE_AVAILABLE
                    local statusText = completed and STRINGS.COMPLETED_STATUS or STRINGS.AVAILABLE_STATUS
                    
                    local dungeonName = STRINGS.UNKNOWN
                    if State.SVAR.dailyPledges then
                        for dungeonId, pledgeGiver in pairs(State.SVAR.dailyPledges) do
                            if pledgeGiver == i then
                                local activityName = GetActivityName(dungeonId)
                                if activityName then
                                    dungeonName = activityName
                                    break
                                end
                            end
                        end
                    end
                    
                    local hasQuest, isCompleted = QuestSystem.HasPledgeQuestForGiver(i)
                    local questStatus = ""
                    if hasQuest then
                        if isCompleted then
                            questStatus = " " .. COLORS.PLEDGE_COMPLETED .. "(" .. STRINGS.READY_TO_TURN_IN .. ")" .. COLORS.RESET
                        else
                            questStatus = " " .. COLORS.PLEDGE_IN_PROGRESS .. "(" .. STRINGS.QUEST_IN_PROGRESS .. ")" .. COLORS.RESET
                        end
                    elseif not completed then
                        questStatus = " " .. COLORS.PLEDGE_AVAILABLE .. "(" .. STRINGS.AVAILABLE_TO_ACCEPT .. ")" .. COLORS.RESET
                    end
                    
                    table.insert(parts, color .. STRINGS.PLEDGE_GIVERS[i] .. ": " .. statusText .. COLORS.RESET .. "\n" .. 
                                        COLORS.GREY .. dungeonName .. COLORS.RESET .. questStatus)
                end
                
                return table.concat(parts, "\n\n")
            end,
            width = "half",
        },

    }

    LAM2:RegisterOptionControls(panelId, options)


-- Register confirmation dialog for cache clearing
    ZO_Dialogs_RegisterCustomDialog("ZDFT_CLEAR_CACHE_CONFIRM", {
        title = {
            text = "Clear All Caches",
        },
        mainText = {
            text = "|cFF6B6BWarning:|r\n\nThis will clear ALL cached data including:\n• Achievement completion status\n• Dungeon data cache\n• Set collection progress\n• Motif completion data\n• Pledge quest mappings\n• Daily pledge data\n\nThe UI will reload and regenerate all cache data from scratch. This process may take a few moments.\n\nAre you sure you want to continue?",
        },
        buttons = {
            {
                text = "Clear Caches & Reload",
                callback = function()
                    -- Clear all cache tables
                    if State.SVAR then
                        State.SVAR.achievementCache = {}
                        State.SVAR.dungeonDataCache = {}
                        State.SVAR.setCollectionCache = {}
                        State.SVAR.motifCache = {}
                        State.SVAR.dailyPledges = {}
                        State.SVAR.lastPledgeUpdate = 0
                        
                        -- Clear daily pledge completion tracking
                        State.SVAR.dailyPledgeCompletion = {
                            timestamp = 0,
                            characters = {}
                        }
                        
                        -- Clear runtime caches as well
                        questStatusCache = {}
                        pledgeReadyStatus = {}
                        recentlyProcessedQuests = {}
                        Cache.achievementToDungeon = {}
                        pledgeQuestMappings = {}
                        lastPledgeQuestScan = 0
                        lastQuestCacheUpdate = 0
                        cachedPlayerName = nil
                        cachedDayTimestamp = nil
                        lastTimestampCheck = 0
                        
                        CHAT_ROUTER:AddSystemMessage("|c00c1ffZaiDFTools:|r All caches cleared. Reloading UI...")
                    end
                    
                    -- Reload UI after a short delay
                    zo_callLater(function()
                        ReloadUI()
                    end, 500)
                end,
            },
            {
                text = "Cancel",
                callback = function()
                    -- Do nothing, just close dialog
                end,
            },
        },
    })

end

-- Event Handlers
local EventHandlers = {}

function EventHandlers.OnAchievementAwarded(_, name, points, achievementId)
    State.SVAR.achievementCache[achievementId] = {name, true}
    
    local dungeonId = Cache.achievementToDungeon[achievementId]
    if dungeonId then
        DungeonSystem.InvalidateCache(dungeonId)
        zo_callLater(function() UISystem.RefreshAllDungeonEntries() end, 100)
    end
end

function EventHandlers.OnAchievementUpdated(_, achievementId)
    State.SVAR.achievementCache[achievementId] = nil
    State.SVAR.motifCache[achievementId] = nil
    
    for dungeonId, dungeonInfo in pairs(DungeonData.Index) do
        if dungeonInfo.motif == achievementId then
            DungeonSystem.InvalidateCache(dungeonId)
            break
        end
    end
    
    zo_callLater(function() UISystem.RefreshAllDungeonEntries() end, 100)
end

function EventHandlers.OnQuestAdded(_, questIndex, questName)
    local questType = GetJournalQuestType(questIndex)

    if questType == QUEST_TYPE_UNDAUNTED_PLEDGE then
        lastPledgeQuestScan = 0
        
        local hashMatch, dungeonID = MatchPledgeQuestHash(questName)
        if hashMatch and dungeonID then
            local pledgeGiver = PledgeTrackingSystem.GetPledgeGiverForDungeonID(dungeonID)
            if pledgeGiver then
                QuestSystem.ClearCache(pledgeGiver)
                pledgeReadyStatus[pledgeGiver] = false

                zo_callLater(function()
                    UISystem.RefreshPledgeDungeonEntries()
                end, 250)
            end
        end
    end
end

function EventHandlers.OnQuestAdvanced(_, journalIndex, questName, isPushed, isComplete, mainStepChanged)
    if not mainStepChanged then 
        return 
    end
    
    local questType = GetJournalQuestType(journalIndex)
    
    if questType ~= QUEST_TYPE_UNDAUNTED_PLEDGE then
        return
    end

    local pledgeGiver = nil
    local hashMatch, dungeonID = MatchPledgeQuestHash(questName)
    if hashMatch and dungeonID then
        pledgeGiver = PledgeTrackingSystem.GetPledgeGiverForDungeonID(dungeonID)
    end
    
    if not pledgeGiver then 
        return 
    end

    local readyToTurnIn = false
    
    if isComplete then
        readyToTurnIn = true
    else
        local conditionText = GetJournalQuestConditionInfo(journalIndex, QUEST_MAIN_STEP_INDEX, 1)

        if ContainsReturnToPattern(conditionText) then
            readyToTurnIn = true
        end
    end
    
    pledgeReadyStatus[pledgeGiver] = readyToTurnIn
    QuestSystem.ClearCache(pledgeGiver)
    local cacheKey = "giver_" .. pledgeGiver

    questStatusCache[cacheKey] = {
        hasQuest = true,
        isCompleted = readyToTurnIn,
        questId = journalIndex,
        questName = questName
    }
    lastQuestCacheUpdate = GetTimeStamp()
    
    zo_callLater(function()
        UISystem.RefreshPledgeDungeonEntries()
    end, 100)
end

function EventHandlers.OnQuestRemoved(_, isCompleted, questIndex, questName)
    if not questName then
        return
    end

    lastPledgeQuestScan = 0

    local hashMatch, dungeonID = MatchPledgeQuestHash(questName) 
    if hashMatch and dungeonID then
        pledgeGiver = PledgeTrackingSystem.GetPledgeGiverForDungeonID(dungeonID)
    end
    
    if pledgeGiver then
        pledgeReadyStatus[pledgeGiver] = false
        
        local questKey = pledgeGiver .. "_" .. (questName:gsub("%s+", ""):lower())
        local lastProcessed = recentlyProcessedQuests[questKey]
        
        if lastProcessed and (GetTimeStamp() - lastProcessed) < 5 then
            return
        else
            if isCompleted then
                PledgeTrackingSystem.MarkPledgeCompleted(pledgeGiver, questName)
                recentlyProcessedQuests[questKey] = GetTimeStamp()
            end
        end

        QuestSystem.ClearCache(pledgeGiver)

        zo_callLater(function()
            UISystem.RefreshPledgeDungeonEntries()
        end, 200)
    end
end

function EventHandlers.OnQuestComplete(_, questName, level, previousExperience, currentExperience, championPoints, questType, instanceType)
    if questType ~= QUEST_TYPE_UNDAUNTED_PLEDGE then
        return
    end
    
    local hashMatch, dungeonID = MatchPledgeQuestHash(questName)
    if hashMatch and dungeonID then
        pledgeGiver = PledgeTrackingSystem.GetPledgeGiverForDungeonID(dungeonID)
    end
    
    if pledgeGiver then
        local questKey = pledgeGiver .. "_" .. (questName:gsub("%s+", ""):lower())
        local lastProcessed = recentlyProcessedQuests[questKey]
        if lastProcessed and (GetTimeStamp() - lastProcessed) < 5 then
            return
        end
        
        QuestSystem.ClearCache(pledgeGiver)
        PledgeTrackingSystem.MarkPledgeCompleted(pledgeGiver, questName)
        recentlyProcessedQuests[questKey] = GetTimeStamp()
        
        zo_callLater(function()
            PledgeTrackingSystem.UpdateCharacterPledgeStatus(true)
            UISystem.RefreshAllDungeonEntries()
        end, 100)
    end
end

function EventHandlers.CleanupProcessedQuestsCache()
    local currentTime = GetTimeStamp()
    for questKey, timestamp in pairs(recentlyProcessedQuests) do
        if (currentTime - timestamp) > 60 then
            recentlyProcessedQuests[questKey] = nil
        end
    end
end

function EventHandlers.OnSetCollectionUpdated(_, setId)
    State.SVAR.setCollectionCache[setId] = nil

    local dungeonAffected = false
    for dungeonId, dungeonInfo in pairs(DungeonData.Index) do
        if dungeonInfo.itemSetIDs then
            for _, id in ipairs(dungeonInfo.itemSetIDs) do
                if id == setId then
                    DungeonSystem.InvalidateCache(dungeonId)
                    dungeonAffected = true
                    break
                end
            end
        end
    end
    
    zo_callLater(function() UISystem.RefreshAllDungeonEntries() end, 100)
end

function EventHandlers.OnPlayerActivated()
    EVENT_MANAGER:RegisterForUpdate(CONFIG.NAME .. "_PledgeUpdate", 60000, function()
        if State.isInitialized and SCENE_MANAGER:IsShowing("dungeonFinder") then
            PledgeTrackingSystem.UpdateCharacterPledgeStatus(false)
        end
    end)
end

local function InitializeDungeonMaps()
    for dungeonId, dungeonInfo in pairs(DungeonData.Index) do
        local achievements = {dungeonInfo.id, dungeonInfo.hm, dungeonInfo.tt, dungeonInfo.nd, dungeonInfo.tri, dungeonInfo.motif}
        for _, achId in ipairs(achievements) do
            if achId then
                Cache.achievementToDungeon[achId] = dungeonId
            end
        end
        
        if dungeonInfo.itemSetIDs then
            for _, setId in ipairs(dungeonInfo.itemSetIDs) do
                Cache.achievementToDungeon[setId] = dungeonId
            end
        end
    end
end

local function Initialize()
    if not DungeonData or not DungeonData.Pledges then return false end

    State.SVAR = ZO_SavedVars:NewAccountWide("ZaiDFTools_SV", CONFIG.SVAR_VERSION, nil, DEFAULT_SETTINGS, GetWorldName())

    if not State.SVAR.cacheVersion or State.SVAR.cacheVersion < CONFIG.CACHE_VERSION then
        local caches = {"setCollectionCache", "achievementCache", "dungeonDataCache", "motifCache"}
        for _, cache in ipairs(caches) do
            State.SVAR[cache] = {}
        end
        State.SVAR.cacheVersion = CONFIG.CACHE_VERSION
    end

    State.SVAR.dailyPledges = State.SVAR.dailyPledges or {}
    State.SVAR.dailyPledgeCompletion = State.SVAR.dailyPledgeCompletion or {timestamp = 0, characters = {}}

    if State.SVAR.dailyPledgeCompletion.characters then
        for _, charData in pairs(State.SVAR.dailyPledgeCompletion.characters) do
            charData.lastChecked = charData.lastChecked or 0
        end
    end

    InitializeDungeonMaps()
    PledgeSystem.UpdateDaily()

    local events = {
        {EVENT_ACHIEVEMENT_AWARDED, EventHandlers.OnAchievementAwarded},
        {EVENT_ACHIEVEMENT_UPDATED, EventHandlers.OnAchievementUpdated},
        {EVENT_ITEM_SET_COLLECTION_UPDATED, EventHandlers.OnSetCollectionUpdated},
        {EVENT_QUEST_COMPLETE, EventHandlers.OnQuestComplete},
        {EVENT_QUEST_ADDED, EventHandlers.OnQuestAdded},
        {EVENT_QUEST_REMOVED, EventHandlers.OnQuestRemoved},
        {EVENT_QUEST_ADVANCED, EventHandlers.OnQuestAdvanced},
    }
    
    for _, event in ipairs(events) do
        EVENT_MANAGER:RegisterForEvent(CONFIG.NAME, event[1], event[2])
    end

    EVENT_MANAGER:RegisterForUpdate(CONFIG.NAME .. "_CacheCleanup", 60000, EventHandlers.CleanupProcessedQuestsCache)

    local templateInfo = DUNGEON_FINDER_KEYBOARD.navigationTree.templateInfo
    if templateInfo and templateInfo.ZO_ActivityFinderTemplateNavigationEntry_Keyboard then
        local originalSetupFunction = templateInfo.ZO_ActivityFinderTemplateNavigationEntry_Keyboard.setupFunction
        
        templateInfo.ZO_ActivityFinderTemplateNavigationEntry_Keyboard.setupFunction = function(node, control, data, open)
            originalSetupFunction(node, control, data, open)
            
            if data and data.id then
                UISystem.UpdateDungeonEntry(control, data.id)
            end
        end
    end

    ButtonSystem.CreatePledgeButton()
    ButtonSystem.CreateCollectionButton()

    SLASH_COMMANDS["/zdftpledges"] = function()
        PledgeSystem.UpdateDaily()
        
        CHAT_ROUTER:AddSystemMessage("=== " .. GetString(ZDFT_TODAYS_PLEDGE_QUESTS) .. " ===")
        
        for pledgeGiver = 1, 3 do
            local dungeonName = STRINGS.UNKNOWN
            if State.SVAR.dailyPledges then
                for dungeonId, giver in pairs(State.SVAR.dailyPledges) do
                    if giver == pledgeGiver then
                        dungeonName = GetActivityName(dungeonId) or STRINGS.UNKNOWN
                        break
                    end
                end
            end
            
            local hasQuest, isCompleted = QuestSystem.HasPledgeQuestForGiver(pledgeGiver)
            local questName = GetString(ZDFT_NO_ACTIVE_QUEST)
            
            if hasQuest then
                for i = 1, MAX_JOURNAL_QUESTS do
                    local name, _, _, _, _, _, _, _, _, questType, instanceType = GetJournalQuestInfo(i)
                    if name and questType == QUEST_TYPE_UNDAUNTED_PLEDGE and instanceType == INSTANCE_TYPE_GROUP then
                        local questDungeon = name:match(".*[:%：]%s*(.*)")
                        if questDungeon then
                            local normalizedQuest = questDungeon:lower():gsub(" ", "")
                            local normalizedPledge = dungeonName:lower():gsub(" ", "")
                            
                            if normalizedQuest == normalizedPledge or 
                                normalizedQuest:find(normalizedPledge) or 
                                normalizedPledge:find(normalizedQuest) then
                                questName = name
                                break
                            end
                        end
                    end
                end
            end
            
            local status = ""
            if hasQuest then
                status = " " .. (isCompleted and 
                    ("|c27AE60(" .. GetString(ZDFT_READY_TO_TURN_IN) .. ")") or 
                    ("|cF39C12(" .. GetString(ZDFT_QUEST_IN_PROGRESS) .. ")")) .. "|r"
            else
                local characterCompleted = PledgeTrackingSystem.IsPledgeCompletedForCharacter(pledgeGiver)
                status = " " .. (characterCompleted and 
                    ("|c95A5A6(" .. GetString(ZDFT_ALREADY_COMPLETED_TODAY) .. ")") or 
                    ("|c3498DB(" .. GetString(ZDFT_AVAILABLE_TO_ACCEPT) .. ")")) .. "|r"
            end

            CHAT_ROUTER:AddSystemMessage(STRINGS.PLEDGE_GIVERS[pledgeGiver] .. " - " .. dungeonName .. status)
        end
    end

    SettingsSystem.Register()

    EVENT_MANAGER:RegisterForEvent(CONFIG.NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(CONFIG.NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
        
        EventHandlers.OnPlayerActivated()
        zo_callLater(function()
            if DungeonData and DungeonData.Pledges and State.SVAR then
                PledgeTrackingSystem.UpdateCharacterPledgeStatus(true)
            end
        end, 2000)
    end)
    
    State.isInitialized = true
    return true
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= CONFIG.NAME then return end
    EVENT_MANAGER:UnregisterForEvent(CONFIG.NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(CONFIG.NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

-- DEBUGGING FUNCTIONS
-- Export Item Set Data
-- Calculate Pledge Shifts
-- Change UI Language for Testing
-- Find Missing Dungeon ID's

function ZaiDFTools.ExportItemSetData(startID, endID, categoryFilter)
    -- Parameter validation and defaults
    if not startID and not endID then
        startID = 1
        endID = 500
    elseif startID and not endID then
        endID = startID + 500
    elseif not startID and endID then
        -- Process in blocks of 500 if no startID but endID is provided
        startID = math.max(1, endID - 499)
    end
    
    -- Ensure valid range
    startID = math.max(1, startID or 1)
    endID = math.max(startID, endID or startID + 500)
    
    d("=== Exporting ItemSet Data ===")
    d(string.format("Scanning item sets from ID %d to %d", startID, endID))
    if categoryFilter then
        d(string.format("Filtering by category: %s", tostring(categoryFilter)))
    end
    d("Copy the following data:")
    d(" ") -- Use space instead of empty string
    
    local exportData = {}
    local scannedCount = 0
    local foundCount = 0
    
    -- Try to use the collections manager if available
    if ITEM_SET_COLLECTIONS_DATA_MANAGER then
        d("Using ITEM_SET_COLLECTIONS_DATA_MANAGER")
        
        -- Clean data first
        ITEM_SET_COLLECTIONS_DATA_MANAGER:CleanData()
        
        -- Iterate through all item set collections
        for _, itemSetCollectionData in ITEM_SET_COLLECTIONS_DATA_MANAGER:ItemSetCollectionIterator() do
            local setId = itemSetCollectionData:GetId()
            
            -- Check if it's in our range
            if setId >= startID and setId <= endID then
                scannedCount = scannedCount + 1
                
                local setName = itemSetCollectionData:GetRawName()
                local setType = itemSetCollectionData:GetSetType()
                local totalPieces = itemSetCollectionData:GetNumPieces()
                
                -- Get category information
                local categoryData = itemSetCollectionData:GetCategoryData()
                local categoryName = "Unknown"
                local subcategoryName = "Unknown"
                
                if categoryData then
                    categoryName = categoryData:GetName() or "Unknown"
                    local parentCategory = categoryData:GetParentCategoryData()
                    if parentCategory then
                        subcategoryName = categoryName
                        categoryName = parentCategory:GetName() or "Unknown"
                    end
                end
                
                -- Apply category filter if specified
                local includeSet = true
                if categoryFilter then
                    local filterLower = string.lower(tostring(categoryFilter))
                    local categoryLower = string.lower(categoryName)
                    local subcategoryLower = string.lower(subcategoryName)
                    
                    if filterLower == "dungeon" then
                        -- Only include actual dungeons, exclude arenas and trials
                        includeSet = (setType == ITEM_SET_TYPE_DUNGEON) or 
                                   (string.find(categoryLower, "dungeon") and 
                                    not string.find(categoryLower, "arena") and 
                                    not string.find(categoryLower, "trial")) or
                                   (string.find(subcategoryLower, "dungeon") and 
                                    not string.find(subcategoryLower, "arena") and 
                                    not string.find(subcategoryLower, "trial")) or
                                   (categoryLower == "dungeons" or subcategoryLower == "dungeons") or
                                   (string.find(categoryLower, "dlc") and string.find(categoryLower, "dungeon"))
                    elseif filterLower == "dlcdungeon" or filterLower == "dlc_dungeon" then
                        -- Only DLC dungeons
                        includeSet = (string.find(categoryLower, "dlc") and 
                                    (string.find(categoryLower, "dungeon") or string.find(subcategoryLower, "dungeon"))) and
                                    not string.find(categoryLower, "arena") and 
                                    not string.find(categoryLower, "trial")
                    else
                        includeSet = string.find(categoryLower, filterLower) or string.find(subcategoryLower, filterLower)
                    end
                end
                
                if totalPieces > 0 and includeSet then
                    foundCount = foundCount + 1
                    table.insert(exportData, {
                        id = setId,
                        name = setName,
                        type = setType,
                        pieces = totalPieces,
                        category = categoryName,
                        subcategory = subcategoryName
                    })
                end
            end
        end
    else
        -- Fallback to the original method
        d("Falling back to basic GetItemSetName method")
        
        for setId = startID, endID do
            scannedCount = scannedCount + 1
            local setName = GetItemSetName(setId)
            if setName and setName ~= "" then
                local setType = GetItemSetType(setId)
                local totalPieces = GetNumItemSetCollectionPieces(setId) or 0
                
                -- For DLC dungeons, we can check the set type
                local includeSet = true
                if categoryFilter then
                    local filterLower = string.lower(tostring(categoryFilter))
                    if filterLower == "dungeon" or filterLower == "dlcdungeon" or filterLower == "dlc_dungeon" then
                        includeSet = (setType == ITEM_SET_TYPE_DUNGEON)
                    end
                end
                
                if totalPieces > 0 and includeSet then
                    foundCount = foundCount + 1
                    table.insert(exportData, {
                        id = setId,
                        name = setName,
                        type = setType,
                        pieces = totalPieces,
                        category = "Unknown",
                        subcategory = "Unknown"
                    })
                end
            end
        end
    end
    
    -- Sort by ID for easier reading
    table.sort(exportData, function(a, b) return a.id < b.id end)
    
    d(string.format("Found %d valid item sets out of %d scanned IDs", foundCount, scannedCount))
    d(" ") -- Use space instead of empty string
    d("local ITEM_SETS = {")
    for _, setInfo in ipairs(exportData) do
        local categoryInfo = ""
        if setInfo.category ~= "Unknown" or setInfo.subcategory ~= "Unknown" then
            categoryInfo = string.format(" [%s/%s]", setInfo.category, setInfo.subcategory)
        end
        
        d(string.format("    [%d] = { name = \"%s\", type = %d, pieces = %d },%s -- %s", 
            setInfo.id, setInfo.name, setInfo.type, setInfo.pieces, categoryInfo, setInfo.name))
    end
    d("}")
end

function ZaiDFTools.CalculatePledgeShifts()
    d("=== Calculating Pledge Shifts ===")
    d("This function will help determine the correct shift values for pledge rotations.")
    d(" ")
    
    -- Force update daily pledges first
    PledgeSystem.UpdateDaily()
    
    -- Get current pledges from the game by scanning all journal quests
    local currentPledges = {}
    local numQuests = GetNumJournalQuests()
    
    d("|cFFFFFFScanning " .. numQuests .. " journal quests for pledge quests...|r")
    d(" ")
    
    for i = 1, numQuests do
        local name = GetJournalQuestName(i)
        local questType = GetJournalQuestType(i)
        
        if name and questType == QUEST_TYPE_UNDAUNTED_PLEDGE then
            d("|cF39C12Found pledge quest:|r " .. name)
            
            -- Try to match this quest to a dungeon
            local hashMatch, dungeonID = MatchPledgeQuestHash(name)
            
            if hashMatch and dungeonID then
                d("  |c27AE60Matched to dungeon ID:|r " .. dungeonID .. " (" .. (GetActivityName(dungeonID) or "Unknown") .. ")")
                
                -- Find which pledge giver this dungeon belongs to
                local pledgeGiver = nil
                
                -- Check our daily pledges mapping first
                if State.SVAR.dailyPledges and State.SVAR.dailyPledges[dungeonID] then
                    pledgeGiver = State.SVAR.dailyPledges[dungeonID]
                    d("  |c27AE60Found in daily pledges mapping:|r Giver " .. pledgeGiver)
                else
                    -- Manually search through all pledge lists to find this dungeon
                    d("  |cF39C12Not found in daily mapping, searching pledge lists...|r")
                    for giver = 1, 3 do
                        local pledgeList = DungeonData.Pledges[giver]
                        if pledgeList then
                            for j, pledge in ipairs(pledgeList) do
                                if pledge.id == dungeonID or pledge.vetId == dungeonID then
                                    pledgeGiver = giver
                                    d("  |c27AE60Found in " .. STRINGS.PLEDGE_GIVERS[giver] .. "'s list at position " .. j .. "|r")
                                    break
                                end
                            end
                            if pledgeGiver then break end
                        end
                    end
                end
                
                if pledgeGiver then
                    currentPledges[pledgeGiver] = {
                        dungeonId = dungeonID,
                        questName = name,
                        activityName = GetActivityName(dungeonID) or "Unknown",
                        questIndex = i
                    }
                else
                    d("  |cFF0000Could not determine pledge giver for this dungeon!|r")
                end
            else
                d("  |cFF0000Could not match quest name to any known dungeon!|r")
                d("  |cFF0000Quest hash:|r " .. HashString(name))
            end
            d(" ")
        end
    end
    
    if next(currentPledges) == nil then
        d("|cFF0000No pledge quests found in journal!|r")
        d("Make sure you have accepted pledge quests from the Undaunted Enclave.")
        d(" ")
        d("|cF39C12Debug: Available pledge quest hashes for current language:|r")
        local currentLang = GetGameLanguage()
        local hashes = PLEDGE_QUEST_HASHES[currentLang]
        if hashes then
            for hash, dungeonId in pairs(hashes) do
                local questName = "Unknown"
                -- Try to reverse lookup the quest name (this won't work perfectly but helps debug)
                for i = 1, numQuests do
                    local name = GetJournalQuestName(i)
                    if name and HashString(name) == hash then
                        questName = name
                        break
                    end
                end
                d("  Hash " .. hash .. " -> Dungeon " .. dungeonId .. " (" .. (GetActivityName(dungeonId) or "Unknown") .. ")")
            end
        else
            d("  No pledge quest hashes found for language: " .. currentLang)
        end
        return
    end
    
    d("|c27AE60Current pledges found in your journal:|r")
    for pledgeGiver = 1, 3 do
        local pledge = currentPledges[pledgeGiver]
        if pledge then
            d(string.format("  %s: %s (ID: %d)", 
                STRINGS.PLEDGE_GIVERS[pledgeGiver], 
                pledge.activityName, 
                pledge.dungeonId))
        else
            d(string.format("  %s: |cFF0000No quest found|r", STRINGS.PLEDGE_GIVERS[pledgeGiver]))
        end
    end
    d(" ")
    
    -- Calculate what our addon thinks the pledges should be
    local currentTime = GetTimeStamp()
    local daysSinceBase = math.floor((currentTime - baseTimestamp) / 86400)
    
    d("|cFFFFFFDays since base timestamp:|r " .. daysSinceBase)
    d("|cFFFFFFWhat addon thinks should be today's pledges:|r")
    
    for pledgeGiver = 1, 3 do
        local pledgeList = DungeonData.Pledges[pledgeGiver]
        if pledgeList then
            local currentShift = pledgeList.shift or 0
            local expectedIndex = ((daysSinceBase + currentShift) % #pledgeList) + 1
            local expectedPledge = pledgeList[expectedIndex]
            if expectedPledge then
                local expectedName = GetActivityName(expectedPledge.id) or "Unknown"
                d(string.format("  %s: %s (ID: %d, position %d)", 
                    STRINGS.PLEDGE_GIVERS[pledgeGiver], 
                    expectedName, 
                    expectedPledge.id,
                    expectedIndex))
            end
        end
    end
    d(" ")
    
    -- For each pledge giver, find the correct shift
    local newShifts = {}
    
    for pledgeGiver = 1, 3 do
        local pledgeList = DungeonData.Pledges[pledgeGiver]
        local currentPledge = currentPledges[pledgeGiver]
        
        if pledgeList and currentPledge then
            d(string.format("|cFFFFFF%s rotation analysis:|r", STRINGS.PLEDGE_GIVERS[pledgeGiver]))
            
            -- Find which index in our list matches the current pledge
            local foundIndex = nil
            for i, pledge in ipairs(pledgeList) do
                if pledge.id == currentPledge.dungeonId or pledge.vetId == currentPledge.dungeonId then
                    foundIndex = i
                    break
                end
            end
            
            if foundIndex then
                -- Calculate what shift would put us at this index today
                local currentShift = pledgeList.shift or 0
                local expectedIndex = ((daysSinceBase + currentShift) % #pledgeList) + 1
                local requiredShift = (foundIndex - 1 - daysSinceBase) % #pledgeList
                
                d(string.format("  Current pledge: %s (position %d in rotation)", 
                    currentPledge.activityName, foundIndex))
                d(string.format("  Current shift: %d (gives position %d)", 
                    currentShift, expectedIndex))
                d(string.format("  Required shift: %d", requiredShift))
                
                newShifts[pledgeGiver] = requiredShift
            else
                d(string.format("  |cFF0000Could not find %s in %s's rotation!|r", 
                    currentPledge.activityName, STRINGS.PLEDGE_GIVERS[pledgeGiver]))
                d("  This dungeon might be missing from the DungeonData.Pledges table.")
                
                -- Show what dungeons are in this giver's rotation
                d("  |cF39C12Dungeons in this giver's rotation:|r")
                for i, pledge in ipairs(pledgeList) do
                    local dungeonName = GetActivityName(pledge.id) or "Unknown"
                    d(string.format("    %d: %s (ID: %d)", i, dungeonName, pledge.id))
                end
            end
        else
            d(string.format("|cFF0000No data for %s|r", STRINGS.PLEDGE_GIVERS[pledgeGiver]))
            if not pledgeList then
                d("  No pledge list found for this giver")
            end
            if not currentPledge then
                d("  No current pledge found for this giver")
            end
        end
        d(" ")
    end
    
    -- Show the required updates
    if next(newShifts) then
        d("|c27AE60=== Required Updates ===|r")
        d("Update your DungeonData.Pledges with these shift values:")
        d(" ")
        
        for pledgeGiver = 1, 3 do
            local newShift = newShifts[pledgeGiver]
            if newShift then
                local oldShift = DungeonData.Pledges[pledgeGiver].shift or 0
                local giverNames = {"Maj", "Glirion", "Urgarlag"}
                
                d(string.format("  [%d] = { -- %s", pledgeGiver, giverNames[pledgeGiver]))
                d("      -- ... existing dungeon entries ...")
                d(string.format("      shift = %d  -- was %d", newShift, oldShift))
                d("  },")
            end
        end
    else
        d("|cFF0000Could not calculate any shifts!|r")
        d("Make sure you have pledge quests in your journal and they exist in DungeonData.Pledges")
    end
end

SLASH_COMMANDS["/zdftexportsets"] = function(args)
    local startID, endID, categoryFilter
    
    if args and args ~= "" then
        -- Parse arguments
        local parts = {}
        for part in string.gmatch(args, "%S+") do
            table.insert(parts, part)
        end
        
        if #parts >= 1 then
            startID = tonumber(parts[1])
        end
        if #parts >= 2 then
            endID = tonumber(parts[2])
        end
        if #parts >= 3 then
            categoryFilter = parts[3]
        end
    end
    
    ZaiDFTools.ExportItemSetData(startID, endID, categoryFilter)
end

SLASH_COMMANDS["/zdftshifts"] = function()
    ZaiDFTools.CalculatePledgeShifts()
end

SLASH_COMMANDS["/zdftlang"] = function(args)
    local arg = zo_strtrim(args):lower()
    
    if arg == "" then
        local currentLang = GetCVar("language.2")
        d("|c00c1ffZaiDFTools|r - Current UI Language: |cFFFFFF" .. (currentLang or "unknown") .. "|r")
        d("Available languages:")
        d("  |cFFFFFF/zdftlang en|r - English")
        d("  |cFFFFFF/zdftlang de|r - German")
        d("  |cFFFFFF/zdftlang es|r - Spanish")
        d("  |cFFFFFF/zdftlang fr|r - French")
        d("  |cFFFFFF/zdftlang ru|r - Russian")
        d("  |cFFFFFF/zdftlang jp|r - Japanese")
        d("  |cFFFFFF/zdftlang zh|r - Chinese")
        d("Note: UI will reload immediately after language change!")
        return
    end
    
    local validLanguages = {
        ["en"] = "English",
        ["de"] = "German", 
        ["es"] = "Spanish",
        ["fr"] = "French",
        ["ru"] = "Russian",
        ["jp"] = "Japanese",
        ["zh"] = "Chinese"
    }
    
    if not validLanguages[arg] then
        d("|c00c1ffZaiDFTools|r - Invalid language code: |cFF0000" .. arg .. "|r")
        d("Use |cFFFFFF/zdftlang|r without arguments to see available languages.")
        return
    end
    
    local currentLang = GetCVar("language.2")
    
    if currentLang == arg then
        d("|c00c1ffZaiDFTools|r - UI language is already set to |cFFFFFF" .. validLanguages[arg] .. "|r")
        return
    end
    
    d("|c00c1ffZaiDFTools|r - Switching UI language to |cFFFFFF" .. validLanguages[arg] .. "|r...")
    d("UI will reload now!")
    
    zo_callLater(function()
        SetCVar("language.2", arg)
    end, 100)
end

SLASH_COMMANDS["/zdftmissing"] = function()
    d("=== Scanning for Missing Dungeons ===")
    d("You must have the Dungeon Finder UI open to scan for missing dungeons.")
    
    local missingDungeons = {}
    local knownDungeonNames = {}
    
    -- First, collect all known dungeon names from our data
    for dungeonId, dungeonInfo in pairs(DungeonData.Index) do
        local name = GetActivityName(dungeonId)
        if name then
            knownDungeonNames[name:lower()] = dungeonId
        end
    end
    
    -- Scan through the dungeon finder UI to find all available dungeons
    for i = 2, 3 do -- Normal and Veteran containers
        local container = UISystem.GetCachedContainer(i)
        if container then
            for j = 1, container:GetNumChildren() do
                local control = container:GetChild(j)
                if control and control.node and control.node.data and control.node.data.id then
                    local dungeonId = control.node.data.id
                    local dungeonName = GetActivityName(dungeonId)
                    
                    if dungeonName and not DungeonData.Index[dungeonId] then
                        -- This is a dungeon we don't have data for
                        local isVeteran = (i == 3)
                        
                        if not missingDungeons[dungeonId] then
                            missingDungeons[dungeonId] = {
                                name = dungeonName,
                                isVeteran = isVeteran
                            }
                        end
                    end
                end
            end
        end
    end
    
    if next(missingDungeons) then
        d("|cFF0000Found " .. NonContiguousCount(missingDungeons) .. " dungeons missing from DungeonData.Index:|r")
        d("")
        
        -- Separate normal and veteran dungeons
        local normalDungeons = {}
        local veteranDungeons = {}
        
        for dungeonId, info in pairs(missingDungeons) do
            if info.isVeteran then
                table.insert(veteranDungeons, {id = dungeonId, info = info})
            else
                table.insert(normalDungeons, {id = dungeonId, info = info})
            end
        end
        
        -- Sort by ID for better organization
        table.sort(normalDungeons, function(a, b) return a.id < b.id end)
        table.sort(veteranDungeons, function(a, b) return a.id < b.id end)
        
        -- Display Normal dungeons
        if #normalDungeons > 0 then
            d("|cFFFFFF-- Normal Dungeons:|r")
            for _, dungeon in ipairs(normalDungeons) do
                d("|cFFFFFF[" .. dungeon.id .. "]|r = {id=0000, isDLC=true, itemSetIDs = {000,000,000}, motif=0000}, -- " .. dungeon.info.name)
            end
            d("")
        end
        
        -- Display Veteran dungeons
        if #veteranDungeons > 0 then
            d("|cFFFFFF-- Veteran Dungeons:|r")
            for _, dungeon in ipairs(veteranDungeons) do
                d("|cFFFFFF[" .. dungeon.id .. "]|r = {id=0000, hm=0000, tt=0000, nd=0000, tri=0000, isDLC=true, itemSetIDs = {000,000,000,000}, motif=0000}, -- " .. dungeon.info.name)
            end
            d("")
        end
        
        d("|cF39C12Note:|r Replace the placeholder values (0000, 000) with actual achievement IDs and item set IDs.")
        d("|cF39C12Note:|r Normal dungeons use 3 item sets, Veteran dungeons use 4 item sets (including the Veteran-only set).")
    else
        d("|c27AE60All dungeons in the finder are accounted for in DungeonData.Index!|r")
    end
end  