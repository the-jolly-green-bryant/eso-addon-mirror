--Namespace
BetterDungonFinder = {}
local BAF = BetterDungonFinder

BAF.name = "BetterDungeonFinder"
BAF.title = "BetterDungeonFinder"
BAF.author = "@MelanAster"
BAF.version = "1.90"

--01, Normal activityId                   /script for i = 1, 10000 do if select(7, GetActivityInfo(i)) == 4 then d(i.." "..GetActivityName(i)) end end    
--02, Vertern activityId                  ...
--03, Zone Id                             /script d(GetActivityZoneId(integer activityId))
--04, SetsId Table                        /script d(select(6, GetItemLinkSetInfo("string itemLink")))
--05, HM AchievementId                    /script d(GetAchievementIdFromLink("string link"))
--06, SR AchievementId                    ...
--07, ND AchievementId                    ...
--08, Tri AchievementId                   ...
--09, SkillPoint QuestId                  /script for i = 1, 20000 do if HasQuest(i) then d(i.." "..GetQuestName(i)) end end
--10, Undaunted QuestId                   /script for i = 1, 20000 do if GetQuestZoneId(i) == * then d(i.." "..GetQuestName(i)) end end
--11, Undaunted weapon style PackId       /script BetterDungonFinder.PackScan("Arms Pack")
--12, Dungeon Style master achievement    ...
--13, Fast Travel Node Index              /script for i = 1, 10000 do if select(6, GetFastTravelNodeInfo(i)) == "/esoui/art/icons/poi/poi_groupinstance_glow.dds" then d(i.." "..select(2, GetFastTravelNodeInfo(i))) end end

BAF.BaseDungeonInfo = {
  [1] =  {4   , 20  , 380 , {265, 110, 197, 295}, 1554, 1552, 1553, nil, 4107, 5244, 6218, nil, 198}, -- The Banished Cells I
  [2] =  {300 , 301 , 935 , {170, 110, 197, 295}, 451 , 449 , 1564, nil, 4597, 5246, 9137, nil, 262}, -- The Banished Cells II
  [3] =  {2   , 299 , 283 , {266, 33,  61,  297}, 1561, 1559, 1560, nil, 3993, 5247, 8423, nil,  98}, -- Fungal Grotto I
  [4] =  {18  , 312 , 934 , {162, 33,  61,  297}, 342 , 340 , 1563, nil, 4303, 5248, 7836, nil, 266}, -- Fungal Grotto II
  [5] =  {3   , 315 , 144 , {267, 35,  55,  296}, 1570, 1568, 1569, nil, 4054, 5260, 6779, nil, 193}, -- Spindleclutch I
  [6] =  {316 , 19  , 936 , {163, 35,  55,  296}, 448 , 446 , 1572, nil, 4555, 5273, 6772, nil, 267}, -- Spindleclutch II
  [7] =  {5   , 309 , 63  , {268, 96,  300, 301}, 1586, 1584, 1585, nil, 4145, 5274, 8438, nil, 198}, -- Darkshade Caverns I
  [8] =  {308 , 21  , 930 , {166, 96,  300, 301}, 467 , 465 , 1588, nil, 4641, 5275, 7160, nil, 264}, -- Darkshade Caverns II
  [9] =  {7   , 23  , 126 , {269, 28,  155, 298}, 1578, 1576, 1577, nil, 4336, 5276, 7842, nil, 191}, -- Elden Hollow I
  [10] = {303 , 302 , 931 , {167, 28,  155, 298}, 463 , 461 , 1580, nil, 4675, 5277, 7166, nil, 265}, -- Elden Hollow II
  [11] = {6   , 306 , 146 , {270, 29,  194, 299}, 1594, 1592, 1593, nil, 4246, 5278, 7848, nil, 189}, -- Wayrest Sewers I
  [12] = {22  , 307 , 933 , {165, 29,  194, 299}, 681 , 679 , 1596, nil, 4813, 5282, 8821, nil, 263}, -- Wayrest Sewers II
  [13] = {8   , 305 , 148 , {271, 156, 303, 304}, 1609, 1607, 1608, nil, 4202, 5288, 6786, nil, 192}, -- Arx Corinium
  [14] = {10  , 310 , 176 , {272, 158, 159, 160}, 1602, 1600, 1601, nil, 4778, 5290, 8429, nil, 197}, -- City of Ash I
  [15] = {322 , 267 , 681 , {169, 158, 159, 160}, 1114, 1108, 1107, nil, 5120, 5381, 7154, nil, 268}, -- City of Ash II
  [16] = {9   , 261 , 130 , {273, 122, 134, 302}, 1615, 1613, 1614, nil, 4379, 5283, 6216, nil, 190}, -- Crypt of Hearts I
  [17] = {317 , 318 , 932 , {168, 122, 134, 302}, 1084, 941 , 942 , nil, 5113, 5284, 8891, nil, 269}, -- Crypt of Hearts II
  [18] = {11  , 319 , 449 , {274, 53,  103, 307}, 1628, 1626, 1627, nil, 4346, 5291, 6342, nil, 195}, -- Direfrost Keep
  [19] = {13  , 311 , 131 , {275, 186, 188, 193}, 1622, 1620, 1621, nil, 4538, 5301, 8589, nil, 188}, -- Tempest Island
  [20] = {12  , 304 , 22  , {276, 77,  102, 305}, 1634, 1632, 1633, nil, 4432, 5303, 9447, nil, 196}, -- Volenfell
  [21] = {15  , 321 , 38  , {277, 157, 308, 309}, 1652, 1650, 1651, nil, 4589, 5305, 7830, nil, 186}, -- Blackheart Haven
  [22] = {14  , 320 , 64  , {278, 46,  72,  310}, 1646, 1644, 1645, nil, 4469, 5306, 6369, nil, 187}, -- Blessed Crucible
  [23] = {16  , 313 , 31  , {279, 19,  71,  123}, 1640, 1638, 1639, nil, 4733, 5307, 9561, nil, 185}, -- Selene's Web
  [24] = {17  , 314 , 11  , {280, 91,  124, 311}, 1658, 1656, 1657, nil, 4822, 5309, 6321, nil, 184}, -- Vaults of Madness
}

BAF.DLCDungeonInfo = {
  [1]  = {288 , 287 , 688 , {183, 184, 185, 198}, 1279, 1275, 1276, nil,  5342, 5431, 6214  , nil , 247}, -- White-Gold Tower
  [2]  = {289 , 268 , 678 , {164, 190, 195, 196}, 1303, 1128, 1129, nil,  5136, 5382, 7663  , nil , 236}, -- Imperial City Prison
  [3]  = {293 , 294 , 843 , {256, 258, 259, 260}, 1506, 1507, 1508, nil,  5403, 5636, 7657  , 1795, 260}, -- Ruins of Mazzatun
  [4]  = {295 , 296 , 848 , {257, 261, 262, 263}, 1524, 1525, 1526, nil,  5702, 5780, 7651  , 1796, 261}, -- Cradle of Shadows
  [5]  = {324 , 325 , 973 , {341, 340, 338, 339}, 1696, 1694, 1695, nil,  5889, 6053, 9441  , 2098, 326}, -- Bloodroot Forge
  [6]  = {368 , 369 , 974 , {342, 336, 337, 335}, 1704, 1702, 1703, nil,  5891, 6054, 8861  , 2097, 332}, -- Falkreath Hold
  [7]  = {418 , 419 , 1010, {350, 346, 347, 348}, 1981, 1979, 1980, 1983, 6065, 6154, 9831  , 2189, 363}, -- Scalecaller Peak
  [8]  = {420 , 421 , 1009, {349, 344, 345, 343}, 1965, 1963, 1964, 2102, 6064, 6155, 9792  , 2190, 341}, -- Fang Lair
  [9]  = {426 , 427 , 1052, {398, 402, 403, 404}, 2154, 2155, 2156, 2159, 6186, 6187, 9786  , 2318, 371}, -- Moon Hunter Keep
  [10] = {428 , 429 , 1055, {397, 399, 400, 401}, 2164, 2165, 2166, 2168, 6188, 6189, 8675  , 2317, 370}, -- March of Sacrifices
  [11] = {433 , 434 , 1080, {432, 429, 430, 431}, 2262, 2263, 2264, 2267, 6249, 6250, 10041 , 2503, 389}, -- Frostvault
  [12] = {435 , 436 , 1081, {436, 433, 434, 435}, 2272, 2273, 2274, 2276, 6251, 6252, 10025 , 2504, 390}, -- Depths of Malatar
  [13] = {494 , 495 , 1122, {458, 452, 453, 454}, 2417, 2418, 2419, 2422, 6349, 6350, 10118 , 2628, 391}, -- Moongrave Fane
  [14] = {496 , 497 , 1123, {459, 455, 456, 457}, 2427, 2428, 2429, 2431, 6351, 6352, 10212 , 2629, 398}, -- Lair of Maarselok
  [15] = {503 , 504 , 1152, {478, 471, 472, 473}, 2541, 2542, 2543, 2546, 6414, 6415, 10206 , 2747, 424}, -- Icereach
  [16] = {505 , 506 , 1153, {479, 474, 475, 476}, 2551, 2552, 2553, 2555, 6416, 6417, 10200 , 2749, 425}, -- Unhallowed Grave
  [17] = {507 , 508 , 1197, {534, 516, 517, 518}, 2755, 2697, 2698, 2701, 6505, 6506, nil   , 2850, 435}, -- Stone Garden
  [18] = {509 , 510 , 1201, {535, 513, 514, 515}, 2706, 2707, 2708, 2710, 6507, 6508, 10931 , 2849, 436}, -- Castle Thorn
  [19] = {591 , 592 , 1228, {577, 569, 570, 571}, 2833, 2834, 2835, 2838, 6576, 6577, 11582 , 2984, 437}, -- Black Drake Villa
  [20] = {593 , 594 , 1229, {578, 572, 573, 574}, 2843, 2844, 2845, 2847, 6578, 6579, 10559 , 2991, 454}, -- The Cauldron
  [21] = {595 , 596 , 1267, {608, 605, 606, 607}, 3018, 3019, 3020, 3023, 6683, 6684, 10603 , 3097, 470}, -- Red Petal Bastion
  [22] = {597 , 598 , 1268, {609, 602, 603, 604}, 3028, 3029, 3030, 3032, 6685, 6686, 10613 , 3094, 469}, -- The Dread Cellar
  [23] = {599 , 600 , 1301, {632, 619, 620, 621}, 3153, 3107, 3108, 3111, 6740, 6741, 10937 , 3229, 497}, -- Coral Aerie
  [24] = {601 , 602 , 1302, {633, 622, 623, 624}, 3154, 3117, 3118, 3120, 6742, 6743, 10943 , 3228, 498}, -- Shipwright's Regret
  [25] = {608 , 609 , 1360, {666, 660, 661, 662}, 3377, 3378, 3379, 3381, 6835, 6836, 11824 , 3422, 520}, -- Earthen Root Enclave
  [26] = {610 , 611 , 1361, {667, 663, 664, 665}, 3396, 3397, 3398, 3400, 6837, 6838, 11830 , 3423, 521}, -- Graven Deep
  [27] = {613 , 614 , 1389, {683, 680, 681, 682}, 3470, 3471, 3472, 3474, 6896, 6897, 14546 , 3547, 531}, -- Bal Sunnar
  [28] = {615 , 616 , 1390, {687, 684, 685, 686}, 3531, 3532, 3533, 3535, 7027, 7028, nil   , 3546, 532}, -- Scrivener's Hall
  [29] = {638 , 639 , 1470, {734, 732, 730, 731}, 3812, 3813, 3814, 3816, 7105, 7106, nil   , 3921, 556}, -- Oathsworn Pit
  [30] = {640 , 641 , 1471, {738, 735, 736, 737}, 3853, 3854, 3855, 3857, 7155, 7156, 13229 , 3922, 565}, -- Bedlam Veil
  [31] = {855 , 856 , 1496, {797, 794, 795, 796}, 4111, 4112, 4113, 4115, 7235, 7236, nil   , 4159, 581}, -- Exiled Redoubt
  [32] = {857 , 858 , 1497, {801, 798, 799, 800}, 4130, 4131, 4132, 4134, 7237, 7238, nil   , 4160, 582}, -- Lep Seclusa
  [33] = {1037, 1038, 1551, {829, 825, 826, 827}, 4313, 4314, 4315, 4317, 7320, 7321, nil   , 4290, 606}, -- Naj-Caldeesh
  [34] = {1039, 1040, 1552, {828, 822, 823, 824}, 4336, 4337, 4338, 4340, 7323, 7324, nil   , 4289, 605}, -- Black Gem Foundry
}

BAF.CofferInfo = {
  --Base 1
  [211131] = {170, 265},
  [211132] = {166, 268},
  [211133] = {167, 269},
  [211134] = {162, 266},
  [211135] = {163, 267},
  [211136] = {165, 270},
  --Base 2
  [211137] = {169, 272},
  [211138] = {168, 273},
  [211139] = {271, 277},
  [211140] = {274, 278},
  [211141] = {275, 279},
  [211142] = {276, 280},
  --DLC
  [211143] = {164, 183},
  [211144] = {256, 257},
  [211145] = {341, 342},
  [211146] = {349, 350},
  [211147] = {397, 398},
  [211148] = {432, 436},
  [211149] = {458, 459},
  [211150] = {478, 479},
  [211151] = {534, 535},
  [211152] = {577, 578},
  [211153] = {608, 609},
  [211154] = {632, 633},
  [211155] = {666, 667},
  [211156] = {683, 687},
  [211157] = {734, 738},
  [214317] = {797, 801},
  [219848] = {828, 829},
}

BAF.RandomCofferInfo = {
  --Base 1
  [153513] = {
    211131, 211132, 211133, 211134,
    211135, 211136,
  },
  --Base 2
  [153514] = {
    211137, 211138, 211139, 211140,
    211141, 211142,
  },
  --DLC
  [153515] = {
    211143, 211144, 211145, 211146, 
    211147, 211148, 211149, 211150, 
    211151, 211152, 211153, 211154, 
    211155, 211156, 211157, 214317, 
    219848,
  },
}

--The status of dungeons of player
BAF.BD = {
--[[
  [Index] = {
  --Constant
    ["Raw"] = table DungeonInfo[Index]
    ["Name"] = String
    ["nId"] = Number
    ["vId"] = Number
    ["zoneId"] = Number
    ["Style"] = Number
  --Variable
    ["Availability"] = Number 0 none, 1 norma, 2 both
    ["Gear"] = Table {NumGet, NumTotal}
    ["HM"] = Number 0 false, 1 true
    ["SR"] = Number 0 false, 1 true
    ["ND"] = Number 0 false, 1 true
    ["Tri"] = Number 0 not get, 1 get, 2 not exist
  --Other variable
    ["SK"] = boolen
    ["IsGetUQ"] = boolen
    ["IsTodayU"] = boolen
    ["IsRich"] = boolen
  }
]]
}

BAF.DD = {}  --DLC dungeon
BAF.UD = {}  --Dungeon match the journal quests

BAF.SD = {} -- Selected dungeon

--The controls created to UI
BAF.BDC = {}
BAF.DDC = {}
BAF.UDC = {}

--Area for UDQ
BAF.UDRange = {
  [19]  = {231282, 241735, 234151, 245884},
  [57]  = {195078, 242561, 198653, 245926},
  [383] = {239320, 238002, 242507, 240885},
}

--Alert Type
BAF.AlertSound = {
  [0] = "",
  [1] = "Enchanting_PotencyRune_Removed",
  [2] = "Achievement_Awarded",
  [3] = "Quest_Abandon",
  [4] = "Inventory_DestroyJunk",
  [5] = "InventoryItem_Repair",
  [6] = "AlliancePoint_Transact",
  [7] = "Telvar_Transact",
  [8] = "Undaunted_Transact",
  [9] = "Group_Kick",
  [10] = "LFG_Search_Started",
  [11] = "LFG_Search_Finished",
  [12] = "BG_VictoryNear",
  [13] = "Ability_Ultimate_Ready_Sound",
  [14] = "Book_Acquired",
  [15] = "Tutorial_Window_Show",
  [16] = "Stats_Purchase",
  [17] = "Smithing_Start_Research",
  [18] = "LevelUpReward_Claim",
  [19] = "CodeRedemption_Success",
  [20] = "Endeavor_Complete",
}