WorhelloAchievementExporter = WorhelloAchievementExporter or {}
WorhelloAchievementExporter.Achievements = WorhelloAchievementExporter.Achievements or {}

-- This should be incremented as new achievement codes are added below
-- N.B Versions > 5 will only be incremented for the specific content type affected
--   1 - Initial implementation
--   2 - Add all extra achievements for DLC dungeons
--   3 - Add all extra achievements for trials and non-DLC dungeons
--   4 - Add achievements for Scions of Ithilia (U41)
--   5 - Add achievements for Lucent Citadel (U42)

WorhelloAchievementExporter.Achievements.Version = {}
WorhelloAchievementExporter.Achievements.Version["trial"]       = 5
WorhelloAchievementExporter.Achievements.Version["dungeon"]     = 5
WorhelloAchievementExporter.Achievements.Version["baseDungeon"] = 5


-- The initial implementation here was heavily based on Pithka's PITHKA.Data.Achievements.DB in PithkaAchievementTracker/Data/Achievements.lua
-- Now this will diverge as additional extra achievements will be added
WorhelloAchievementExporter.Achievements.DB = {
    -- Trials
    --                  VET   PHM1   PHM2   HM    TRI    EXT
    {ABBV="HRC", CODES={1474, "NIL", "NIL", 1136, "NIL", 1080,870                                                                     }, TYPE="trial"},
    {ABBV="AA",  CODES={1503, "NIL", "NIL", 1137, "NIL", 1081                                                                         }, TYPE="trial"},
    {ABBV="SO",  CODES={1462, "NIL", "NIL", 1138, "NIL", 1113,1124                                                                    }, TYPE="trial"},
    {ABBV="MOL", CODES={1368, "NIL", "NIL", 1344, "NIL", 1391 , 1386,1367,1392,1369,1385,1388,1389,1390                               }, TYPE="trial"},
    {ABBV="HOF", CODES={1810, "NIL", "NIL", 1829, 1838,  1836 , 1840,1833,1839,1832,1831,1830,1841,1837,1834,1809,1811                }, TYPE="trial"},
    {ABBV="AS",  CODES={2077, 2085,  2086,  2079, 2087,  2075 , 2078,2081,2080,2083,2084,2082                                         }, TYPE="trial"},
    {ABBV="CR",  CODES={2133, 2134,  2135,  2136, 2139,  2140 , 2132,2138,2137,2238,2237,2231,2232,2233,2234,2235,2236                }, TYPE="trial"},
    {ABBV="SS",  CODES={2435, 2469,  2470,  2466, 2467,  2468 , 2499,2434,2436,2437,2438,2500,2501                                    }, TYPE="trial"},
    {ABBV="KA",  CODES={2734, 2736,  2737,  2739, 2740,  2746 , 2743,2745,2742,2733,2816,2735,2744,2818,2817,2741                     }, TYPE="trial"},
    {ABBV="RG",  CODES={2987, 3005,  3006,  3007, 3003,  3004 , 2989,2990,2986,2988,3008,3009,3010,3011,3012                          }, TYPE="trial"},
    {ABBV="DSR", CODES={3244, 3250,  3251,  3252, 3248,  3249 , 3243,3245,3246,3247,3253,3254,3255,3256,3257                          }, TYPE="trial"},
    {ABBV="SE",  CODES={3560, 3566,  3567,  3568, 3564,  3565 , 3559,3561,3562,3563,3569,3570,3571,3572,3573,3670                     }, TYPE="trial"},
    {ABBV="LC",  CODES={4015, 4021,  4022,  4023, 4019,  9846 , 4020,4013,4014,4016,4017,4018,4024,4025,4026,4027,4028,4061,4079,4151 }, TYPE="trial"},

    -- Arenas   
    {ABBV="DSA",  CODES={1140, "NIL", "NIL"}, TYPE="arena"},
    {ABBV="BRP",  CODES={2363, 2368,  2372 }, TYPE="arena"},
    {ABBV="MSA",  CODES={1305, "NIL", "NIL"}, TYPE="arena"},
    {ABBV="VSA",  CODES={2908, 2912,  2913 }, TYPE="arena"},

    -- DLC Dungeons
    --                  Vet   HM    SR    ND    CHA    TRI    EXT...
    {ABBV="WGT", CODES={1120, 1279, 1275, 1276, "NIL", "NIL", 1306, 1280,1346,1281,1278,1277                                              },TYPE="dungeon"},
    {ABBV="ICP", CODES={880,  1303, 1128, 1129, 1132,  "NIL", 1133, 1122,1345,1131,1142,1130                                              },TYPE="dungeon"},
    {ABBV="ROM", CODES={1505, 1506, 1507, 1508, 1511,  "NIL", 1516, 1509,1510,1515,1517,1518,1519,1513,1514,1504,1512                     },TYPE="dungeon"},
    {ABBV="COS", CODES={1523, 1524, 1525, 1526, 1529,  "NIL", 1534, 1533,1535,1527,1528,1530,1531,1532,1522,1536                          },TYPE="dungeon"},
    {ABBV="FH",  CODES={1699, 1704, 1702, 1703, 1942,  "NIL", 1948, 1700,1701,1946,1947,1950,1951,1698,1945,1705,1949                     },TYPE="dungeon"},
    {ABBV="BF",  CODES={1691, 1696, 1694, 1695, 1941,  "NIL", 1819, 1692,1693,1816,1817,1818,1821,1822,1823,1820,1690,1697                },TYPE="dungeon"},
    {ABBV="FL",  CODES={1960, 1965, 1963, 1964, 1966,  2102,  1967, 1968,1970,1961,1962,1969,1971,1972,1973,1959,1974                     },TYPE="dungeon"},
    {ABBV="SP",  CODES={1976, 1981, 1979, 1980, 1982,  1983,  1991, 1984,1977,1978,1986,1987,1988,1989,1975                               },TYPE="dungeon"},
    {ABBV="MHK", CODES={2153, 2154, 2155, 2156, 2158,  2159,  2301, 2152,2298,2299,2307,2297,2300,2150,2151,2308,2309                     },TYPE="dungeon"},
    {ABBV="MOS", CODES={2163, 2164, 2165, 2166, 2167,  2168,  2305, 2162,2302,2306,2303,2304,2160,2161,2310,2311,2312                     },TYPE="dungeon"},
    {ABBV="FV",  CODES={2261, 2262, 2263, 2264, 2266,  2267,  2384, 2260,2380,2381,2382,2383,2385,2387,2258,2259,2386                     },TYPE="dungeon"},
    {ABBV="DOM", CODES={2271, 2272, 2273, 2274, 2275,  2276,  2395, 2270,2391,2392,2389,2268,2269,2388,2390,2393,2394                     },TYPE="dungeon"},
    {ABBV="LOM", CODES={2426, 2427, 2428, 2429, 2430,  2431,  2581, 2425,2576,2578,2580,2423,2424,2579,2582,2583,2584                     },TYPE="dungeon"},
    {ABBV="MF",  CODES={2416, 2417, 2418, 2419, 2421,  2422,  2575, 2415,2577,2570,2571,2413,2414,2572,2573,2574,2569                     },TYPE="dungeon"},
    {ABBV="IR",  CODES={2540, 2541, 2542, 2543, 2545,  2546,  2677, 2539,2676,2537,2538,2670,2672,2673,2674,2675                          },TYPE="dungeon"},
    {ABBV="UG",  CODES={2550, 2551, 2552, 2553, 2554,  2555,  2679, 2549,2678,2682,2547,2548,2683,2684                                    },TYPE="dungeon"},
    {ABBV="SG",  CODES={2695, 2755, 2697, 2698, 2700,  2701,  2824, 2694,2825,2810,2826,2753,2754,2693,2692,2823,2809,2808                },TYPE="dungeon"},
    {ABBV="CT",  CODES={2705, 2706, 2707, 2708, 2709,  2710,  2828, 2704,2814,2703,2702,2813,2811,2815,2827                               },TYPE="dungeon"},
    {ABBV="BDV", CODES={2832, 2833, 2834, 2835, 2837,  2838,  2883, 2830,2829,2881,2880,2879,2882,2831,2884                               },TYPE="dungeon"},
    {ABBV="TC",  CODES={2842, 2843, 2844, 2845, 2846,  2847,  2886, 2839,2890,2840,2887,2885,2888,2889,2841                               },TYPE="dungeon"},
    {ABBV="RPB", CODES={3017, 3018, 3019, 3020, 3022,  3023,  3035, 3014,3015,3086,3087,3036,3037,3016,3038,3039,3040                     },TYPE="dungeon"},
    {ABBV="DC",  CODES={3027, 3028, 3029, 3030, 3031,  3032,  3042, 3024,3025,3088,3089,3041,3043,3045,3046,3026,3044,3090,3091,3092      },TYPE="dungeon"},
    {ABBV="CA",  CODES={3105, 3153, 3107, 3108, 3110,  3111,  3226, 3102,3103,3106,3225,3123,3125,3126,3127,3128,3231,3104,3124,3230      },TYPE="dungeon"},
    {ABBV="SR",  CODES={3115, 3154, 3117, 3118, 3119,  3120,  3224, 3112,3113,3116,3223,3129,3130,3131,3132,3114,3134                     },TYPE="dungeon"},
    {ABBV="ER",  CODES={3376, 3377, 3378, 3379, 3380,  3381,  3391, 3388,3389,3525,3373,3374,3382,3383,3384,3386,3375,3385,3390           },TYPE="dungeon"},
    {ABBV="GD",  CODES={3395, 3396, 3397, 3398, 3399,  3400,  3410, 3407,3408,3526,3392,3393,3401,3404,3405,3425,3394,3403,3406,3409      },TYPE="dungeon"},
    {ABBV="BS",  CODES={3469, 3470, 3471, 3472, 3473,  3474,  3484, 3481,3482,3617,3466,3467,3475,3476,3477,3478,3468,3483,3479,3480,3619 },TYPE="dungeon"},
    {ABBV="SH",  CODES={3530, 3531, 3532, 3533, 3534,  3535,  3538, 3542,3543,3545,3618,3527,3528,3536,3537,3539,3540,3541,3529,3544,3662 },TYPE="dungeon"},
    {ABBV="OP",  CODES={3811, 3812, 3813, 3814, 3815,  3816,  3826, 3810,3825,3820,3823,3824,4009,3808,3809,3817,3818,3819,3821,3822      },TYPE="dungeon"},
    {ABBV="BV",  CODES={3852, 3853, 3854, 3855, 3856,  3857,  3867, 3851,3866,3860,3861,3864,3865,4010,3849,3850,3858,3859,3862,3863      },TYPE="dungeon"},
    {ABBV="BRP", CODES={2363, 2364, 2366, 2365, "NIL", 2368,  2372, 2362,2367,2369,2374,2370,2375,2371,2373                               },TYPE="dungeon"},

    -- Base Game Dungeons
    --                   VET   HM    SR    ND
    {ABBV="FG1",  CODES={1556, 1561, 1559, 1560, 1558,1557          }, TYPE='baseDungeon'},
    {ABBV="FG2",  CODES={343,  342,  340,  1563,  850, 851          }, TYPE='baseDungeon'},
    {ABBV="BC1",  CODES={1549, 1554, 1552, 1553, 1550,1551          }, TYPE='baseDungeon'},
    {ABBV="BC2",  CODES={545,  451,  449,  1564,  853, 852          }, TYPE='baseDungeon'},
    {ABBV="EH1",  CODES={1573, 1578, 1576, 1577, 1575,1574          }, TYPE='baseDungeon'},
    {ABBV="EH2",  CODES={459,  463,  461,  1580,  858, 859          }, TYPE='baseDungeon'},
    {ABBV="COA1", CODES={1597, 1602, 1600, 1601, 1598,1599          }, TYPE='baseDungeon'},
    {ABBV="COA2", CODES={878,  1114, 1108, 1107, 1105,1106,1159,1082}, TYPE='baseDungeon'},
    {ABBV="COH1", CODES={1610, 1615, 1613, 1614, 1612,1611          }, TYPE='baseDungeon'},
    {ABBV="COH2", CODES={876,  1084, 941,  942 ,  939, 940          }, TYPE='baseDungeon'},
    {ABBV="DC1",  CODES={1581, 1586, 1584, 1585, 1583,1582          }, TYPE='baseDungeon'},
    {ABBV="DC2",  CODES={464,  467,  465,  1588,  856, 857          }, TYPE='baseDungeon'},
    {ABBV="SC1",  CODES={1565, 1570, 1568, 1569, 1566,1567          }, TYPE='baseDungeon'},
    {ABBV="SC2",  CODES={421,  448,  446,  1572,  854, 855          }, TYPE='baseDungeon'},
    {ABBV="WS1",  CODES={1589, 1594, 1592, 1593, 1590,1591          }, TYPE='baseDungeon'},
    {ABBV="WS2",  CODES={678,  681,  679,  1596,  860, 861          }, TYPE='baseDungeon'},
    {ABBV="AC",   CODES={1604, 1609, 1607, 1608, 1605,1606          }, TYPE='baseDungeon'},
    {ABBV="BH",   CODES={1647, 1652, 1650, 1651, 1649,1648          }, TYPE='baseDungeon'},
    {ABBV="BC",   CODES={1641, 1646, 1644, 1645, 1643,1642          }, TYPE='baseDungeon'},
    {ABBV="DK",   CODES={1623, 1628, 1626, 1627, 1624,1625          }, TYPE='baseDungeon'},
    {ABBV="SW",   CODES={1635, 1640, 1638, 1639, 1636,1637          }, TYPE='baseDungeon'},
    {ABBV="TI",   CODES={1617, 1622, 1620, 1621, 1619,1618          }, TYPE='baseDungeon'},
    {ABBV="VOM",  CODES={1653, 1658, 1656, 1657, 1655,1654          }, TYPE='baseDungeon'},
    {ABBV="VOL",  CODES={1629, 1634, 1632, 1633, 1630,1631          }, TYPE='baseDungeon'}
}

WorhelloAchievementExporter.Achievements.DBFilter = function(query)
    local output = {}    
    for _, row in ipairs(WorhelloAchievementExporter.Achievements.DB) do 
        local test = true
        for key, value in pairs(query) do
            test = test and row[key] == value
        end
        if test then 
            table.insert(output, row) 
        end
    end

    return output
end

WorhelloAchievementExporter.Achievements.GetVersion = function(query)
    -- local type = query.TYPE
    -- local val = WorhelloAchievementExporter.Achievements.Version[type]
    -- d("read val: " .. val)

    return WorhelloAchievementExporter.Achievements.Version[query.TYPE]
end