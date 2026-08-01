local SI = MyDung.SI

MyDung.DailyPledge={
	[1]={	--Maj
    [1] = SI.EldenHollow2,
    [2] = SI.WayrestSewers1,
    [3] = SI.Spindleclutch2,
    [4] = SI.BanishedCells1,
    [5] = SI.FungalGrotto2,
    [6] = SI.Spindleclutch1,
    [7] = SI.DarkshadeCaverns2,
    [8] = SI.EldenHollow1,
    [9] = SI.WayrestSewers2,
    [10] = SI.FungalGrotto1,
    [11] = SI.BanishedCells2,
    [12] = SI.DarkshadeCaverns1,
		shift=0
	},
	[2]={	--Glirion
    [1] = SI.Volenfell,
    [2] = SI.BlessedCrucible,
    [3] = SI.DirefrostKeep,
    [4] = SI.VaultsOfMadness,
    [5] = SI.CryptOfHearts2,
    [6] = SI.CityOfAsh1,
    [7] = SI.TempestIsland,
    [8] = SI.BlackheartHaven,
    [9] = SI.ArxCorinium,
    [10] = SI.SelenesWeb,
    [11] = SI.CityOfAsh2,
    [12] = SI.CryptOfHearts1,
		shift=0
	},
	[3]={	--Urgarlag
    [1] = SI.ImperialCityPrison,
    [2] = SI.RuinsOfMazzatun,
    [3] = SI.WhiteGoldTower,
    [4] = SI.CradleOfShadows,
    [5] = SI.BloodrootForge,
    [6] = SI.FalkreathHold,
    [7] = SI.FangLair,
    [8] = SI.ScalecallerPeak,
    [9] = SI.MoonHunterKeep,
    [10] = SI.MarchOfSacrifices,
    [11] = SI.DepthsOfMalatar,
    [12] = SI.Frostvault,
    [13] = SI.MoongraveFane,
    [14] = SI.LairOfMaarselok,
    [15] = SI.Icereach,
    [16] = SI.UnhallowedGrave,
    [17] = SI.StoneGarden,
    [18] = SI.CastleThorn,
    [19] = SI.BlackDrakeVilla,
    [20] = SI.Cauldron,
    [21] = SI.RedPetalBastion,
    [22] = SI.DreadCellar,
    [23] = SI.CoralAerie,
    [24] = SI.ShipwrightsRegret,
    [25] = SI.EarthenRootEnclave,
    [26] = SI.GravenDeep,
    [27] = SI.BalSunnar,
    [28] = SI.ScrivenersHall,
    [29] = SI.OathswornPit,
    [30] = SI.BedlamVeil,
	[31] = SI.ExiledRedoubt,
	[32] = SI.LepSeclusa,
		shift=27
	},
}

MyDung.DungeonIndex={
       --Normal
       [2]		={id=294, 	qt=3993},	--Fungal Grotto I
       [3]		={id=301, 	qt=4054},	--Spindleclutch I
       [4]		={id=325, 	qt=4107},	--Banished Cells I
       [5]		={id=78, 	qt=4145},	--Darkshade Caverns I
       [6]		={id=79, 	qt=4246},	--Wayrest Sewers I
       [7]		={id=11, 	qt=4336},	--Elden Hollow I
       [8]		={id=272, 	qt=4202},	--Arx Corinium
       [9]		={id=80, 	qt=4379},	--Crypt of Hearts I
       [10]	={id=551, 	qt=4778},	--City of Ash I
       [11]	={id=357, 	qt=4346},	--Direfrost Keep
       [12]	={id=391, 	qt=4432},	--Volenfell
       [13]	={id=81, 	qt=4538},	--Tempest Island
       [14]	={id=393, 	qt=4469},	--Blessed Crucible
       [15]	={id=410, 	qt=4589},	--Blackheart Haven
       [16]	={id=417, 	qt=4733},	--Selene's Web
       [17]	={id=570, 	qt=4822},	--Vaults of Madness
       [18]	={id=1562, 	qt=4303},	--Fungal Grotto II
       [22]	={id=1595, 	qt=4813},	--Wayrest Sewers II
       [288]	={id=1346, 	qt=5342},	--White-Gold Tower
       [289]	={id=1345, 	qt=5136},	--Imperial City Prison
       [293]	={id=1504, 	qt=5403},	--Ruins of Mazzatun
       [295]	={id=1522, 	qt=5702},	--Cradle of Shadows
       [300]	={id=1555, 	qt=4597},	--Banished Cells II
       [303]	={id=1579, 	qt=4675},	--Elden Hollow II
       [308]	={id=1587, 	qt=4641},	--Darkshade Caverns II
       [316]	={id=1571, 	qt=4555},	--Spindleclutch II
       [317]	={id=1616, 	qt=5113},	--Crypt of Hearts II
       [322]	={id=1603, 	qt=5120},	--City of Ash II
       [324]	={id=1690, 	qt=5889},	--Bloodroot Forge
       [368]	={id=1698, 	qt=5891},	--Falkreath Hold
       [420]	={id=1959, 	qt=6064},	--Fang Lair
       [418]	={id=1975, 	qt=6065},	--Scalecaller Peak
       [428]	={id=2162, 	qt=6188},	--March of Sacrifices
       [426]	={id=2152, 	qt=6186},	--Moon Hunter Keep
       [433]	={id=2260, 	qt=6249},	--Frostvault
       [435]	={id=2270, 	qt=6251},	--Depths of Malatar
       [496]	={id=2425, 	qt=6351},	--Lair of Maarselok
       [494]	={id=2415, 	qt=6349},	--Moongrave Fane
       [503]	={id=2539, 	qt=6414},	--Icereach
       [505]	={id=2549, 	qt=6416},	--Unhallowed Grave
       [507]	={id=2694, 	qt=6505},	--Stone Garden
       [509]	={id=2704, 	qt=6507},	--Castle Thorn
       [591]   ={id=2831, 	qt=6576},   --Black Drake Villa
       [593]   ={id=2841, 	qt=6578},   --Cauldron
       [595]	={id=3016, 	qt=6683},	--Red Petal Bastion
       [597]	={id=3026, 	qt=6685},	--The Dread Cellar
       [599]	={id=3104, 	qt=6740},	--Coral Aerie
       [601]	={id=3114, 	qt=6742},	--Shipwright's Regret
       [608]	={id=3375, 	qt=6835},	--Earthen Root Enclave
       [610]	={id=3394, 	qt=6837},	--Graven Deep
       [613]	={id=3468, 	qt=6896},	--Bal Sunnar
       [615]	={id=3529, 	qt=7027},	--Scrivener's Hall
       [638]	={id=3810, 	qt=7105},	--Oathsworn Pit
       [640]	={id=3851, 	qt=7155},	--Bedlam Veil
	   [855]    ={id=4109,  qt=7235},   --Exiled Redoubt
	   [857]    ={id=4128,  qt=7237},   --Lep Seclusa.
       --Veteran
       [19]	={id=421,	hm=448,		tt=446,		nd=1572, 	qt=4555},	--Spindleclutch II
       [20]	={id=1549,	hm=1554,	tt=1552,	nd=1553, 	qt=4107},	--Banished Cells I
       [21]	={id=464,	hm=467,		tt=465,		nd=1588, 	qt=4641},	--Darkshade Caverns II
       [23]	={id=1573,	hm=1578,	tt=1576,	nd=1577, 	qt=4336},	--Elden Hollow I
       [261]	={id=1610,	hm=1615,	tt=1613,	nd=1614, 	qt=4379},	--Crypt of Hearts I
       [267]	={id=878,	hm=1114,	tt=1108,	nd=1107, 	qt=5120},	--City of Ash II
       [268]	={id=880,	hm=1303,	tt=1128,	nd=1129, 	qt=5136},	--Imperial City Prison
       [287]	={id=1120,	hm=1279,	tt=1275,	nd=1276, 	qt=5342},	--White-Gold Tower
       [294]	={id=1505,	hm=1506,	tt=1507,	nd=1508, 	qt=5403},	--Ruins of Mazzatun
       [296]	={id=1523,	hm=1524,	tt=1525,	nd=1526, 	qt=5702},	--Cradle of Shadows
       [299]	={id=1556,	hm=1561,	tt=1559,	nd=1560, 	qt=3993},	--Fungal Grotto I
       [301]	={id=545,	hm=451,		tt=449,		nd=1564, 	qt=4597},	--Banished Cells II
       [302]	={id=459,	hm=463,		tt=461,		nd=1580, 	qt=4675},	--Elden Hollow II
       [304]	={id=1629,	hm=1634,	tt=1632,	nd=1633, 	qt=4432},	--Volenfell
       [305]	={id=1604,	hm=1609,	tt=1607,	nd=1608, 	qt=4202},	--Arx Corinium
       [306]	={id=1589,	hm=1594,	tt=1592,	nd=1593, 	qt=4246},	--Wayrest Sewers I
       [307]	={id=678,	hm=681,		tt=679,		nd=1596, 	qt=4813},	--Wayrest Sewers II
       [309]	={id=1581,	hm=1586,	tt=1584,	nd=1585, 	qt=4145},	--Darkshade Caverns I
       [310]	={id=1597,	hm=1602,	tt=1600,	nd=1601, 	qt=4778},	--City of Ash I
       [311]	={id=1617,	hm=1622,	tt=1620,	nd=1621, 	qt=4538},	--Tempest Island
       [312]	={id=343,	hm=342,		tt=340,		nd=1563, 	qt=4303},	--Fungal Grotto II
       [313]	={id=1635,	hm=1640,	tt=1638,	nd=1639, 	qt=4733},	--Selene's Web
       [314]	={id=1653,	hm=1658,	tt=1656,	nd=1657, 	qt=4822},	--Vaults of Madness
       [315]	={id=1565,	hm=1570,	tt=1568,	nd=1569,	qt=4054},	--Spindleclutch I
       [318]	={id=876,	hm=1084,	tt=941,		nd=942, 	qt=5113},	--Crypt of Hearts II
       [319]	={id=1623,	hm=1628,	tt=1626,	nd=1627, 	qt=4346},	--Direfrost Keep
       [320]	={id=1641,	hm=1646,	tt=1644,	nd=1645,	qt=4469},	--Blessed Crucible
       [321]	={id=1647,	hm=1652,	tt=1650,	nd=1651, 	qt=4589},	--Blackheart Haven
       [325]	={id=1691,	hm=1696,	tt=1694,	nd=1695, 	qt=5889},	--Bloodroot Forge
       [369]	={id=1699,	hm=1704,	tt=1702,	nd=1703,	qt=5891},	--Falkreath Hold
       [421]	={id=1960,	hm=1965,	tt=1963,	nd=1964, 	qt=6064},	--Fang Lair
       [419]	={id=1976,	hm=1981,	tt=1979,	nd=1980, 	qt=6065},	--Scalecaller Peak
       [429]	={id=2163,	hm=2164,	tt=2165,	nd=2166, 	qt=6188},	--March of Sacrifices
       [427]	={id=2153,	hm=2154,	tt=2155,	nd=2156, 	qt=6186},	--Moon Hunter Keep
       [434]	={id=2261,	hm=2262,	tt=2263,	nd=2264, 	qt=6249},	--Frostvault
       [436]	={id=2271,	hm=2272,	tt=2273,	nd=2274, 	qt=6251},	--Depths of Malatar
       [497]	={id=2426,	hm=2427,	tt=2428,	nd=2429, 	qt=6351},	--Lair of Maarselok
       [495]	={id=2416,	hm=2417,	tt=2418,	nd=2419, 	qt=6349},	--Moongrave Fane
       [504]	={id=2540,	hm=2541,	tt=2542,	nd=2543, 	qt=6414},	--Icereach
       [506]	={id=2550,	hm=2551,	tt=2552,	nd=2553, 	qt=6416},	--Unhallowed Grave
       [508]	={id=2695,	hm=2755,	tt=2697,	nd=2698, 	qt=6505},	--Stone Garden
       [510]	={id=2705,	hm=2706,	tt=2707,	nd=2708, 	qt=6507},	--Castle Thorn
       [592]    ={id=2832,	hm=2833,	tt=2834,	nd=2835, 	qt=6576},   --Black Drake Villa
       [594]    ={id=2842,	hm=2843,	tt=2844,	nd=2845, 	qt=6578},   --Cauldron
       [596]	={id=3017,	hm=3018,	tt=3019,	nd=3020, 	qt=6683},	--Red Petal Bastion
       [598]	={id=3027,	hm=3028,	tt=3029,	nd=3030, 	qt=6685},	--The Dread Cellar
       [600]	={id=3105,	hm=3153,	tt=3107,	nd=3108, 	qt=6740},	--Coral Aerie
       [602]	={id=3115,	hm=3154,	tt=3117,	nd=3118, 	qt=6742},	--Shipwright's Regret
       [609]	={id=3376,	hm=3377,	tt=3378,	nd=3379, 	qt=6835},	--Earthen Root Enclave
       [611]	={id=3395,	hm=3396,	tt=3397,	nd=3398, 	qt=6837},	--Graven Deep
       [614]	={id=3469,	hm=3470,	tt=3471,	nd=3472, 	qt=6896},	--Bal Sunnar
       [616]	={id=3530,	hm=3531,	tt=3532,	nd=3533, 	qt=7027},	--Scrivener's Hall
       [639]	={id=3811,	hm=3812,	tt=3813,	nd=3814, 	qt=7105},	--Oathsworn Pit 
       [641]	={id=3852,	hm=3853,	tt=3854,	nd=3855, 	qt=7155},	--Bedlam Veil
	   [856]    ={id=4110,  hm=4111,    tt=4112,    nd=4113,    qt=7235},   --Exiled Redoubt
	   [858]    ={id=4129,  hm=4130,    tt=4131,    nd=4132,    qt=7237},   --Lep Seclusa
       }
