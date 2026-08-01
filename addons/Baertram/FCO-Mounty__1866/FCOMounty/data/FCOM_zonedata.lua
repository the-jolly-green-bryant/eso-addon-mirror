if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

FCOMounty.ZoneData = {}
local zoneData = FCOMounty.ZoneData

--The zones and subzones of the game, as strings (for library libMapPin access)
--> Taken zone names from addon Skyshards by Ayantir & Garkin: http://www.esoui.com/downloads/info128-SkyShards.html
zoneData["alikr"] = { --Alik'r Desert
    [FCOM_ZONE_ID_STRING] = 104,
    --Alik'r Desert
    ["alikr_base"] = 104, --Alik'r Desert
    ["sentinel_base"] = 756,
    ["bergama_base"] = true,
    ["kozanset_base"] = true,
    ["aldunz_base"] = 329,
    ["coldrockdiggings_base"] = 330,
    ["divadschagrinmine_base"] = 328,
    ["sandblownmine_base"] = 331,
    ["santaki_base"] = 327,
    ["yldzuun_base"] = 332,
    ["lostcity_base"] = 308,
}

zoneData["eyevea"] = { --Eyevea
    [FCOM_ZONE_ID_STRING] = 267,
    --Eyevea
    ["eyevea_base"] = 267, --"Augvea"
}

zoneData["auridon"] = { --Auridon
    [FCOM_ZONE_ID_STRING] = 381,
    --Auridon
    ["auridon_base"] = 381, -- Auridon
    ["vulkhelguard_base"] = "Vulkhel Guard",
    ["skywatch_base"] = true,
    ["bewan_base"] = 401,
    ["delsclaim_base"] = 397,
    ["entilasfolly_base"] = 398,
    ["mehrunesspite_base"] = 400,
    ["ondil_base"] = 396,
    ["wansalen_base"] = 399,
    ["toothmaulgully_base"] = 486,
    ["khenarthisroost_base"] = 537 ,--"Khenarthis Roost",
    ["mistral_base"] = true,
    ["firsthold_base"] = true,
}

zoneData["bangkorai"] = { --Bangkorai
    [FCOM_ZONE_ID_STRING] = 92,
    --Bangkorai
    ["bangkorai_base"] = 92, --Bangkorai
    ["evermore_base"] = true,
    ["cryptoftheexiles_base"] = 336,
    ["jaggerjaw_base"] = true,
    ["murciensclaim_base"] = "Murchien's Hamlet",
    ["rubblebutte_base"] = 338,
    ["trollstoothpick_base"] = 334,
    ["viridianwatch_base"] = 335,
    ["razakswheel_base"] = 169,
    --??? Check if those exist!
    ["klathzgar_base"] = 337,
    ["torogsspite_base"] = 333,
    ["hallinsstand_base"] = "Hallins Stand",
}

zoneData["coldharbor"] = { --Coldharbour
    [FCOM_ZONE_ID_STRING] = 347,
    --Coldharbour
    ["coldharbour_base"] = 347, -- Coldharbour
    ["aba-loria_base"] = 417,
    ["vaultofhamanforgefire_base"] = 418,
    ["depravedgrotto_base"] = 419,
    ["caveoftrophies_base"] = 420,
    ["malsorrastomb_base"] = 421,
    ["wailingmaw_base"] = 422,
    ["villageofthelost_base"] = 557,
    ["thehollowcity_base"] = "Hollow City",
    ["hollowcity_base"] = "Hollow City",
}

zoneData["craglorn"] = { --Craglorn
    [FCOM_ZONE_ID_STRING] = 888,
    --Craglorn
    ["craglorn_base"] = 888, --Craglorn
    ["belkarth_base"] = true,
    ["molavar_base"] = 889,
    ["rkundzelft_base"] = 890,
    ["kardala_base"] = 893,
    ["rkhardahrk_0"] = true,
    ["haddock_base"] = 896,
    ["chiselshriek_base"] = 897,
    ["burriedsands_base"] = 898,
    ["mtharnaz_base"] = 899,
    ["balamath_base"] = 901,
    ["thaliasretreat_base"] = "Thalia's Retreat",
    ["cryptoftarishzizone_base"] = 905, -- Tombs of the Na-Totambu
    ["hircineshaunt_base"] = 906,
    --Upper Craglorn
    ["serpentsnest_base"] = 891,
    ["ilthagsundertower_base"] = 892,
    ["lothna_base"] = 894,
    ["howlingsepulchersoverland_base"] = 900,
    ["fearfang_base"] = 902,
    ["exarchsstronghold_base"] = 903,
    ["dragonstar_base"] = true,
    --Check (South-West)
    ["zalgazsden_base"] = 904,
    --Check (South-East)
    ["elinhir_base"] = 910,

    ["craglorn_dragonstar_base"] = "Dragonstar", --Dragonstar
}

zoneData["cyrodiil"] = { --Cyrodiil
    [FCOM_ZONE_ID_STRING] = 181,
    --Cyrodiil
    ["ava_whole"] = 181, --"Cyrodiil",
    --Aldmeri
    ["bloodmaynecave_base"] = 507,
    ["breakneckcave_base"] = 493,
    ["haynotecave_base"] = 497,
    ["nisincave_base"] = 502,
    ["potholecavern_base"] = 503,
    ["serpenthollowcave_base"] = 506,
    --Dagerrfall
    ["capstonecave_base"] = 494,
    ["echocave_base"] = 496,
    ["lipsandtarn_base"] = 499,
    ["redrubycave_base"] = 505,
    ["toadstoolhollow_base"] = 531,
    ["underpallcave_base"] = 533,
    --Ebonheart
    ["crackedwoodcave_base"] = 495,
    ["kingscrest_base"] = 498,
    ["muckvalleycavern_base"] = 500,
    ["newtcave_base"] = 501,
    ["quickwatercave_base"] = 504,
    ["vahtacen_base"] = 532,
    --Imperial City
    ["imperialcity_base"] = 584,
    ["imperialsewers_ebon1"] = "IC sewers: Ebonheart Pact 1",
    ["imperialsewers_ebon2"] = "IC sewers: Ebonheart Pact 2",
    ["imperialsewers_aldmeri1"] = "IC sewers: Aldmeri Dominion 1",
    ["imperialsewers_aldmeri2"] = "IC sewers: Aldmeri Dominion 2",
    ["imperialsewer_daggerfall1"] = "IC sewers: Daggerfall Covenant 1",
    ["imperialsewer_daggerfall2"] = "IC sewers: Daggerfall 2",
    ["imperialsewershub_base"] = "IC sewers: Imperial Sewers",
    ["imperialsewer_ebonheart3"] = "IC sewers: Ebonheart Pact 3",
    ["imperialsewers_aldmeri3"] = "IC sewers: Aldmeri Dominion 3",
    ["imperialsewer_daggerfall3"] = "IC sewers: Daggerfall Covenant 3",

    ["southhighrockgate_base"] = "Southern High Rock Gate", --Southern High Rock Gate
    ["imperialsewer_daggerfall1_base"] = 643, --Lambent Passage
    ["northhighrockgate_base"] = "Northern High Rock Gate", --Northern High Rock Gate
}

zoneData["deshaan"] = { --"Deshaan"
    [FCOM_ZONE_ID_STRING] = 57,
    --Deshaan
    ["deshaan_base"] = 57, -- Deshaan
    ["narsis_base"] = 250,
    ["mournhold_base"] = 600,
    ["forgottencrypts_base"] = 306,
    ["desolatecave_base"] = "Desolate Cave",
    ["kwamacolony_base"] = 274,
    ["lowerbthanuel_base"] = 406,
    ["triplecirclemine_base"] = 407,
    ["unexploredcrag_base"] = 408,
    ["corpsegarden_base"] = 410,
    --Check (North-West)
    ["ladyllarelsshelter_base"] = 405,
    --Check (North-East)
    ["knifeeargrotto_base"] = 409,
}

zoneData["eastmarch"] = { --Eastmarch
    [FCOM_ZONE_ID_STRING] = 101,
    --Eastmarch
    ["eastmarch_base"] = 101, --Eastmarch
    ["fortamol_base"] = "Fort Amol",
    ["hallofthedead_base"] = 339,
    ["thechillhollow_base"] = 359,
    ["icehammersvault_base"] = 360,
    ["oldsordscave_base"]   = 361,
    ["thefrigidgrotto_base"] = 362,
    ["stormcragcrypt_base"] = 363,
    ["thebastardstomb_base"] = 364,
    ["windhelm_base"] = true,
}

zoneData["glenumbra"] = { --Glenumbra
    [FCOM_ZONE_ID_STRING] = 3,
    --Glenumbra
    ["glenumbra_base"] = 3, -- Glenumbra
    ["daggerfall_base"] = true,
    ["crosswych_base"] = 256,
    ["ilessantower_base"] = 309,
    ["silumm_base"] = 310,
    ["minesofkhuras_base"] = 311,
    ["enduum_base"] = 312,
    ["eboncrypt_base"] = 313,
    ["cryptwatchfort_base"] = 314,
    ["badmanscave_base"] = 284,
    ["aldcroft_base"] = true,
    --Betnikh (Daggerfall, lvl 1-5)
    ["betnihk_base"] = 535, --"Betnikh"
    ["stonetoothfortress_base"] = "Stonetooth Fortress",
    --Stros M'Kai (Daggerfall, lvl 1-5)
    ["strosmkai_base"] = 534, -- "Stros M'Kai",
    ["porthunding_base"] = "Port Hunding",
}

zoneData["grahtwood"] = { --Grahtwood
    [FCOM_ZONE_ID_STRING] = 383,
    --Grahtwood
    ["grahtwood_base"] = 383, -- Grahtwodd
    ["haven_base"] = true,
    ["eldenrootgroundfloor_base"] = 599,
    ["nesalas_base"] = 442,
    ["dessicatedcave_base"] = 475,
    ["burrootkwamamine_base"] = 444,
    ["vindeathcave_base"] = 477,
    ["wormrootdepths_base"] = 478,
    ["mobarmine_base"] = 447,
    ["rootsunder_base"] = 124,
    ["redfurtradingpost_base"] = "Redfur Trading Post",
    ["eldenrootservices_base"] = 383,
}

zoneData["greenshade"] = { --Greenshade
    [FCOM_ZONE_ID_STRING] = 108,
    --Greenshade
    ["greenshade_base"] = 108, -- Greenshade
    ["marbruk_base"] = true,
    ["woodhearth_base"] = true,
    ["caracdena_base"] = 575,
    ["gurzagsmine_base"] = 576,
    ["theunderroot_base"] = 577,
    ["narilnagaia_base"] = 578,
    ["harridanslair_base"] = 579,
    ["barrowtrench_base"] = 580,
    ["rulanyilsfall_base"] = 137,
}

zoneData["malabaltor"] = { --Malabal Tor
    [FCOM_ZONE_ID_STRING] = 58,
    --Malabal Tor
    [FCOM_ZONE_MAPPING_STRING] = "Malabal Tor",
    ["malabaltor_base"] = 58, -- Malabal Tor
    ["velynharbor_base"] = "Velyn Harbor",
    ["vulkwasten_base"] = true,
    ["baandaritradingpost_base"] = "Baandari Trading Post",
    ["blackvineruins_base"] = 473,
    ["deadmansdrop_base"] = 468,
    ["hoarvorpit_base"] = 470,
    ["shaelruins_base"] = 471,
    ["rootsofsilvenar_base"] = 472,
    ["tomboftheapostates_base"] = 469,
    ["crimsoncove02_base"] = 138,
}

zoneData["reapersmarch"] = { --Reaper's March
    [FCOM_ZONE_ID_STRING] = 382,
    --Reaper's March
    [FCOM_ZONE_MAPPING_STRING] = "Reapers March",
    ["reapersmarch_base"] = 382, --"Reapers March",
    ["dune_base"] = true,
    ["thibautscairn_base"] = 462,
    ["kunasdelve_base"] = 463,
    ["fardirsfolly_base"] = 464,
    ["clawsstrike_base"] = 465,
    ["weepingwindcave_base"] = 466,
    ["jodeslight_base"] = 467,
    ["thevilemansefirstfloor_base"] = 487,
    ["rawlkha_base"] = 455,
    ["arenthia_base"] = true,
}

zoneData["rivenspire"] = { --Rivenspire
    [FCOM_ZONE_ID_STRING] = 20,
    ["rivenspire_base"] = 20, --Rivenspire
    ["shornhelm_base"] = true,
    ["northpoint_base"] = 589,
    ["crestshademine_base"] = 321,
    ["erokii_base"] = 325,
    ["flyleafcatacombs_base"] = 322,
    ["hildunessecretrefuge_base"] = 326,
    ["orcsfingerruins_base"] = 324,
    ["tribulationcrypt_base"] = 323,
    ["obsidianscar_base"] = 162,
    ["hoarfrostdowns_base"] = "Hoarfrost Downs",

    ["hoarfrost_base"] = "Hoarfrost Downs", --Hoarfrost Downs
    ["shroudedpass_base"] = "Shrouded Pass", --Shrouded Pass
}

zoneData["shadowfen"] = { --Shadowfen
    [FCOM_ZONE_ID_STRING] = 117,
    ["shadowfen_base"] = 117, --Shadowfen
    ["stormhold_base"] = true,
    ["altencorimont_base"] = "Alten Corimont",
    ["atanazruins_base"] = 272,
    ["brokentuskcave_base"] = 271,
    ["chidmoskaruins_base"] = 273,
    ["gandranen_base"] = 275,
    ["onkobrakwamamine_base"] = 274,
    ["shrineofblackworm_base"] = 270,
    ["sanguinesdemesne_base"] = 134,
}

zoneData["stonefalls"] = { --Stonefalls
    [FCOM_ZONE_ID_STRING] = 41,
    ["stonefalls_base"] = 41, --Stonefalls
    ["davonswatch_base"] = "Davons Watch",
    ["innerseaarmature_base"] = 287,
    ["emberflintmine_base"] = 296,
    ["mephalasnest_base"] = 288,
    ["softloamcavern_base"] = 289,
    ["hightidehollow_base"] = 290,
    ["sheogorathstongue_base"] = 291,
    ["crowswood_base"] = 216,
    ["balfoyen_base"] = 281, -- Bal Foyen
    ["dhalmora_base"] = true,
    ["bleakrock_base"] = 280,
    ["hozzinsfolley_base"] = "Hozzins Folley",
    ["ebonheart_base"] = true,
    ["kragenmoor_base"] = true,
    ["bleakrockvillage_base"] = "Bleackrock Village",
}

zoneData["stormhaven"] = { --Stormhaven
    [FCOM_ZONE_ID_STRING] = 19,
    ["stormhaven_base"] = 19, --Stormhaven
    ["portdunwatch_base"] = 315,
    ["koeglinmine_base"] = 316,
    ["pariahcatacombs_base"] = 317,
    ["farangelsdelve_base"] = 318,
    ["bearclawmine_base"] = 319,
    ["norvulkruins_base"] = 320,
    ["bonesnapruins_base"] = 142,
    ["wayrest_base"] = 601,
    ["koeglinvillage_base"] = "Koeglin Village",
    ["alcairecastle_base"] = 545,
}

zoneData["therift"] = { --The Rift
    [FCOM_ZONE_ID_STRING] = 103,
    [FCOM_ZONE_MAPPING_STRING] = "The Rift",
    ["therift_base"] = 103, --The Rift
    ["shorsstone_base"] = 402,
    ["riften_base"] = true,
    ["avancheznel_base"] = 413,
    ["ebonmeretower_base"] = "Ebonmere Tower",
    ["snaplegcave_base"] = 480,
    ["fortgreenwall_base"] = 481,
    ["shroudhearth_base"] = 482,
    ["brokenhelm_base"] = 485,
    ["thelionsden_base"] = 341,
    ["nimalten_base"] = 412,
}

zoneData["wrothgar"] = { --Wrothgar
    [FCOM_ZONE_ID_STRING] = 684,
    ["wrothgar_base"] = 684, --Wrothgar
    ["morkul_base"] = true,
    ["rkindaleftoutside_base"] = 705,
    ["oldorsiniummap06_base"] = 706,
    ["argentmine2_base"] = 694,
    ["coldperchcavern_base"] = 693,
    ["thukozods_base"] = 691,
    ["zthenganaz_base"] = 697,
    ["kennelrun_base"] = 689,
    ["watchershold_base"] = 692,
    ["orsinium_base"] = true,
    ["morkulstronghold_base"] = 698,

    ["arenaslobbyexterior_base"] = "Lobby of Maelstrom Arena",
}

zoneData["thievesguild"] = { --Hew's Bane
    [FCOM_ZONE_ID_STRING] = 816,
    [FCOM_ZONE_MAPPING_STRING] = "Hews Bane",
    ["hewsbane_base"] = 816, --Hew's Bane
    ["abahslanding_base"] = "Abahs Landing",
    ["bahrahasgloom_base"] = 817,
    ["sharktoothgrotto1_base"] = 676,
}

zoneData["darkbrotherhood"] = { -- Gold Coast
    [FCOM_ZONE_ID_STRING] = 823,
    [FCOM_ZONE_MAPPING_STRING] = "Gold Coast",
    ["goldcoast_base"] = 823, -- "Gold Coast",
    ["hrotacave_base"] = 824,
    ["garlasagea_base"] = 825,
    ["anvilcity_base"] = 831,
    ["kvatchcity_base"] = 832,
}

zoneData["vvardenfell"] = { -- Vvardenfell
    [FCOM_ZONE_ID_STRING] = 849,
    ["vvardenfell_base"] = 849, --Vvardenfell
    ["cavernsofkogoruhnfw03_base"] = "Caverns Of Kogoruhn",
    ["khartagpoint_base"] = 921,
    ["ashalmawia02_base"] = 961,
    ["zainsipilu_base"] = 922,
    ["matusakin_base"] = 923,
    ["pulklower_base"] = 924,
    ["nchuleftdepths_base"] = 918,
    ["viveccity_base"] = "Vivec City",
    ["viviccity_base"] = "Vivec City",
    ["balmora_base"] = true,
    ["sadrithmora_base"] = true,
    ["forgottenwastes_base"] = 919,
    ["vivecsdelyn03b_base"] = "Vivecs Delyn 03b",
}

zoneData["clockwork"] = {-- Clockwork City
    [FCOM_ZONE_ID_STRING] = 980,
    [FCOM_ZONE_MAPPING_STRING] = "Clockwork City",
    ["clockwork_base"] = 980, -- Clockwork City
    ["brassfortress_base"] = 981,
    ["hallsofregulation_base"] = 985,
    ["shadowcleft_base"] = 986,
}

zoneData["summerset"] = {-- Summerset
    [FCOM_ZONE_ID_STRING] = 1011,
    --Summerset
    ["alinor_base"] = true,
    ["archonsgrove_base"] = 1017,
    ["artaeum_base"] = 1027, --"Artaeum"
    ["etonnir_base"] = 1015,
    ["kingshavenint1_base"] = 1018,
    ["lillandrill_base"] = true,
    ["shimmerene_base"] = true,
    ["sum_karnwasten"] = 1020,
    ["summerset_base"] = 1011, -- Summerset
    ["sunhold_base"] = 1021,
    ["torhamekhard_base"] = 1014,
    ["traitorsvault03_base"] = 1016,
    ["wastencoraldale_base"] = 1019,
    ["collegeofpsijicsruins_base"] = "College of Psijics Ruins (indoor)", --College of Psijics Ruins (indoors area...)
}

zoneData["murkmire"] = {-- Murkmire
    [FCOM_ZONE_ID_STRING] = 726,
    --Murkmire
    ["murkmire_base"]       = 726, -- Murkmire
    ["lilmothcity_base"]    = "Lilmoth",
    ["deadwatervillage_base"] = "Deadwater Village",
    --[[
        [1064] = "Hunter's Glade",
        [1065] = "Blight Bog Sump",
        [1066] = "Tsofeer Cavern",
        [1067] = "The Dreaming Nest",
        [1068] = "Ixtaxh Xanmeer",
        [1069] = "Tomb of Many Spears",
        [1070] = "Lilmoth Outlaws Refuge",
        [1071] = "Xul-Thuxis",
        [1072] = "Norg-Tzel",
        [1073] = "Teeth of Sithis",
        [1074] = "The Sunless Hollow",
        [1075] = "The Sunless Hollow",
        [1076] = "The Sunless Hollow",
        [1077] = "The Swallowed Grove",
        [1078] = "Remnant of Argon",
        [1079] = "Vakka-Bok Xanmeer",
        [1083] = "Deep-Root",
        [1108] = "Lakemire Xanmeer Manor",
        [1109] = "Enchanted Snow Globe Home",
    ]]
}

zoneData["elsweyr"] = {-- Elsweyr
    [FCOM_ZONE_ID_STRING] = 1086,
    --Northern Elsweyr
    ["elsweyr_base"]       = 1086, -- Northern Elsweyr
    ["abodeofignominy_base"] = 1091,
    ["ashencombs1_base"] = 1086, --unsure
    ["ashencombs2_base"] = 1086, --unsure
    ["cheesemongerava_base"] = 203,
    ["cicatriceoasis_base"] = 1111,
    ["cicatriceoasisbossroom_base"] = 1111,
    ["cicatriceoasisupperfloor_base"] = 1111,
    ["dancingmoon01_base"] = 1117,
    ["dancingmoon02_base"] = 1117,
    ["dancingmoon03_base"] = 1117,
    ["desertwind2_2a_base"] = 1119,
    ["desertwind2_base"] = 1119,
    ["desertwind2a_base"] = 1119,
    ["desertwind3_base"] = 1119,
    ["desertwind_base"] = 1119,
    ["dragonguardoutpost_base"] = 1110,
    ["elsweyr_base"] = 1086,
    ["hakoshaecrypts_base"] = 1114,
    ["jodesembrace1.base"] = 1130,
    ["jodesembrace2.base"] = 1130,
    ["jodesembrace3.base"] = 1130,
    ["khasdaskeep01_base"] = 1120, --Meirvale Keep?
    ["khasdaskeep02_base"] = 1120,
    ["khasdaskeep03_base"] = 1120,
    ["khasdaskeep04_base"] = 1120,
    ["khasdaskeep05_base"] = 1120,
    ["khasdaskeep06_base"] = 1120,
    ["merrivillesugarfarm_base"] = 1115,
    ["moongate_base"] = 1103,
    ["moonsurface_base"] = 1103,
    ["mulaamnirslair_base"] = 1097,
    ["phoom01_base"] = 1086, --unsure
    ["predatorrise_base"] = 1092,
    ["rimmen_base"] = "Rimmen",
    ["rimmencrypts_base"] = 1101,
    ["rimmenoutlawsrefuge_base"] = 1088,
    ["rimmenpalace_base"] = 1099,
    ["rimmenpalacecourtyard_base"] = 1099,
    ["rimmenpalaceinterior_base"] = 1099,
    ["rimmensewer_base"] = 1101,
    ["riverholdcity_base"] = 1098,
    ["riverholdinstance_base"] = 1098,
    ["sepulcherofmischance00_base"] = 1102,
    ["sepulcherofmischance00b_base"] = 1102,
    ["sepulcherofmischance01_base"] = 1102,
    ["sepulcherofmischance02_base"] = 1102,
    ["sepulcherofmischance03_base"] = 1102,
    ["sepulcherofmischance04_base"] = 1102,
    ["skoomacatscloister1_base"] = 1105,
    ["skoomacatscloister2_base"] = 1105,
    ["smugglershideout_base"] = 1098,
    ["starhavencatacombs_base"] = 1106,
    ["starhaventraininghalls_base"] = 1106,
    ["stitches_base"] = "The Stitches",
    ["sugarslingersden01_base"] = 774,
    ["sugarslingersden01a_base"] = 774,
    ["sugarslingersden01b_base"] = 774,
    ["sugarslingersden02_base"] = 774,
    ["sugarslingersden02a_base"] = 774,
    ["sugarslingersden02b_base"] = 774,
    ["sugarslingersden02c_base"] = 774,
    ["thescab_base"] = 1095,
    ["thetangle_base"] = 1096,
    ["tombofserpents_base"] = 1094,
    ["tutorial1_base"] = 1086,
    ["tutorial2_base"] = 1086,
    ["tutorial3_base"] = 1086,
    ["weepingscar_base"] = 1112, --one or more of these is probably not the ossuary
    ["weepingscar_f2_base"] = 1112,
    ["weepingscarmain_base"] = 1112,
    ["weepingscarpit_base"] = 1112,
}

zoneData["southernelsweyr"] = {-- Southern Elsweyr
    [FCOM_ZONE_ID_STRING] = 1133,
    --Southern Elsweyr
    ["southernelsweyr_base"]       = 1133, -- Southern Elsweyr
	["senchal_base"] = "Senchal",
    ["els_dg_sanctuary_base"] = 1146, --Dragonguard Sanctum
    ["senchalpalace01_base"] = "Senchal Palace",
}

zoneData["skyrim"] = {-- Skyrim
    [FCOM_ZONE_ID_STRING] = 1160,
    --Western Skyrim
    ["westernskryim_base"]  = 1160,
    ["solitudecity_base"]   = "Solitude City",
    --Blackreach
    ["blackreach_base"]     = 1161, -- Blackreach (underground of Western Skyrim)
}

zoneData["reach"] = {-- Reach
    [FCOM_ZONE_ID_STRING] = 1207,
    --The Reach
    ["reach_base"] = 1207,
    ["markarthcity_base"] = "Markarth City",
    --Blackreach
    ["u28_blackreach_base"] = 1208, -- Blackreach (underground of The Reach)
}

zoneData["blackwood"] = {-- Blackwood
    [FCOM_ZONE_ID_STRING] = 1261,
    ["blackwood_base"] = 1261,
    ["u30_gideoncity_base"] = "Gideon",
    ["u30_leyawiincity_base"] = "Leyawiin",
    ["stonewastesfortress_base"] = "Stonewastes Fortress",
}

zoneData["deadlands"] = {--Deadlands
    [FCOM_ZONE_ID_STRING] = 1282,
    ["u32deadlandszone_base"] = 1286, --Deadlands
    ["u32_fargrave_base"] = 1282, --Fargrave
}

zoneData["galen"] = { --Galen
    [FCOM_ZONE_ID_STRING] = 1383,
    ["u36_galenisland_base"] = 1383,
    ["u36_vastyrcity_base"] = "Vastyr City",
}

zoneData["systres"] = { --Systren
    [FCOM_ZONE_ID_STRING] = 1318,
    ["u34_systreszone_base"] = 1318,
    ["u34_gonfalonbaycity_base"] = "Gonfalon",
    ["u34_amenosstation_city_base"] = "Amenos Station",
}

zoneData["telvanni"] = { --Telvanni Peninsula
    [FCOM_ZONE_ID_STRING] = 1414,
    ["u38_telvannipeninsula_base"] = 1414,
    ["u38_necrom_base"] = "Necrom",
}

zoneData["apocrypha"] = {--Apocrypha
    [FCOM_ZONE_ID_STRING]           = 1413,
    ["u38_apocrypha_base"]          = 1413,
    ["u38_ciphersmidden_city_base"] = "Ciphersmidden",
}

zoneData["westweald"] =  { -- Gold Coast
    [FCOM_ZONE_ID_STRING] = 1443,
    ["u42_skingrad_base"] = "Skingrad",
    ["westwealdoverland_base"] = "Westweald Overland",
}
