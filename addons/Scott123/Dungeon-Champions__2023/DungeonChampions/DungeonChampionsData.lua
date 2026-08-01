-------------------------------------------------------------------------------
-- Dungeon Champions Data v1.0.16
-------------------------------------------------------------------------------
--
-- Updated by @Gadget's 2021, 2022
--
-- Update and Changers for Dungeon Champions by Scott123 2022
-- The Changes are in Copyright by MerlinGer
--
-- Copyright (c) 2014, 2015 Ales Machat (Garkin)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------

--achievementIDs for Dungeon Champions:
local achievementIDs = {
    [202] = true, -- Inner Sea Armature
	[203] = true, -- Emberflint Mine
	[205] = true, -- Mephala's Nest
	[206] = true, -- Hightide Hollow
	[207] = true, -- Softloam Cavern
	[208] = true, -- Sheogorath's Tongue
    [215] = true, -- Ilessan Tower
    [216] = true, -- Silumm
	[217] = true, -- Enduum
	[218] = true, -- Mines Of Khuras
	[219] = true, -- Ebon Crypt
    [220] = true, -- Cryptwatch Fort
	[221] = true, -- Portdun Watch
	[222] = true, -- Koeglin Mine
	[223] = true, -- Pariah Catacombs
	[224] = true, -- Farangel's Delve
	[225] = true, -- Bearclaw Mine
	[226] = true, -- Norvolk Ruins
	[227] = true, -- Crestshade Mine
	[228] = true, -- Flyleaf Catacombs
	[229] = true, -- Tribulation Crypt
	[230] = true, -- Orc's Finger Ruins
	[231] = true, -- Erokii Ruins
	[232] = true, -- Hildune's Secret Refuge
	[245] = true, -- Atanaz Ruins
	[246] = true, -- Broken Tusk
	[247] = true, -- Chid-Moska Ruins
	[248] = true, -- Gandranen
	[249] = true, -- Onkobra Kwama Mine
	[250] = true, -- Black Maw Shrine
	[251] = true, -- Chill Hollow
	[252] = true, -- Icehammer's Vault
	[253] = true, -- Old Sord's Cave
	[254] = true, -- Frigid Grotto
	[255] = true, -- Stormcrag Crypt
	[256] = true, -- Bastard's Tomb
	[264] = true, -- Lady Llarel's Shelter
	[265] = true, -- Lower Bthanual
	[266] = true, -- Triple Circle Mine
	[267] = true, -- Taleon's Crag
	[268] = true, -- Knife Ear Grotto
	[269] = true, -- Corpse Garden
	[274] = true, -- Dead Man's Drop
	[281] = true, -- Black Vine Ruins
	[282] = true, -- Roots of Silvenar
	[286] = true, -- Shael Ruins
	[288] = true, -- Del's Claim
	[289] = true, -- Ondil
	[290] = true, -- Entila's Folly
	[291] = true, -- Wansalen
	[292] = true, -- Mehrunes Spite
	[293] = true, -- Bewan
	[297] = true, -- Tomb Of The Apostates
	[298] = true, -- Hoarvor Pit
    [300] = true, -- Sanguine's Demesne
	[329] = true, -- Faldar's Tooth
	[330] = true, -- Broken Helm
	[332] = true, -- Fort Greenwall
	[333] = true, -- Shroud Hearth Barrow
	[334] = true, -- Snapleg Cave
    [368] = true, -- Crow's Wood's
    [370] = true, -- Forgotten Crypts
    [374] = true, -- Lion's Den
    [376] = true, -- Hall of the Dead
    [378] = true, -- Obsidian Scar
    [390] = true, -- Toothmaul Gully
    [396] = true, -- Lost City of the Na-Totambu
	[412] = true, -- Santaki
	[414] = true, -- Divad's Chagrin Mine
	[416] = true, -- Aldunz Ruins
	[419] = true, -- Coldrock Diggings
	[420] = true, -- Sandblown Mine
	[423] = true, -- Yldzuun Ruins
	[432] = true, -- Aba-Loria
	[433] = true, -- Grotto of Depravity
	[434] = true, -- Cave of Trophies
	[435] = true, -- Forgefire Vault
	[436] = true, -- Mal Sorra's Tomb
	[437] = true, -- Wailing Maw
	[453] = true, -- Kuna's Delve
	[454] = true, -- Thibaut's Cairn
	[455] = true, -- Weeping Wind Cave
	[456] = true, -- Claw's Strike
	[457] = true, -- Fardir's Folly
    [458] = true, -- Jode's Light
	[539] = true, -- Troll's Toothpick
	[540] = true, -- Torog's Spite
	[541] = true, -- Crypt of the Exiles
	[542] = true, -- Viridian Watch
	[543] = true, -- Rubble Butte
	[544] = true, -- Klathzgar
	[550] = true, -- The Underroot
	[553] = true, -- Carac Dena
	[555] = true, -- Gurzag's Mine
	[558] = true, -- Harridan's Lair
	[559] = true, -- Barrow Trench
	[567] = true, -- Naril Nagaia
	[573] = true, -- Ne Salas
	[574] = true, -- The Scuttle Pit
	[575] = true, -- Vinedeath Cave
	[576] = true, -- Burroot Kwama Mine
	[577] = true, -- Wormroot Depths
    [578] = true, -- Mobar Mine
	
    [1049] = true, -- Root Sunder
    [1050] = true, -- Rulanyil's Fall
    [1051] = true, -- Crimson Cove
    [1052] = true, -- The Vile Manse
    [1053] = true, -- Bad Man's Hallows
    [1054] = true, -- Bonesnap Ruins
    [1055] = true, -- Razak's Wheel
    [1056] = true, -- Village of the Lost
    [371] = true, -- Group Lion's Den
    [372] = true, -- Group Sanguine's Demesne
    [379] = true, -- Group Crow's Wood's
    [380] = true, -- Group Bad Man's Hallows
    [381] = true, -- Group Hall of the Dead
    [388] = true, -- Group Forgotten Crypts
    [445] = true, -- Group Rulanyil's Fall 
    [460] = true, -- Group Crimson Cove
    [468] = true, -- Group Toothmaul Gully
    [469] = true, -- Group Vile Manse
    [470] = true, -- Group Root Sunder
    [707] = true, -- Group Lost City of the Na-Totambu
    [708] = true, -- Group Razak's Wheel
    [713] = true, -- Group Obsidian Scar
    [714] = true, -- Group Bonesnap Ruins
    [874] = true, -- Group Village of the Lost
	
    [730] = true, -- Bloodmayne Cave
    [731] = true, -- Breakneck Cave
    [732] = true, -- Haynote Cave
    [733] = true, -- Nisin Cave
    [734] = true, -- Pothole Caverns
    [735] = true, -- Serpent Hollow
    [736] = true, -- Capstone Cave
    [737] = true, -- Echo Cave
    [738] = true, -- Lipsand Tarn
    [739] = true, -- Red Ruby Cave
    [740] = true, -- Toadstool Hollow
    [741] = true, -- Underpall Cave
    [742] = true, -- Cracked Wood Cave
    [743] = true, -- Kingscrest Cavern
    [744] = true, -- Muck Valley Cavern
    [745] = true, -- Newt Cave
    [746] = true, -- Quickwater Cave
    [747] = true, -- Vahtacen
	
	-- Craglorn
	[884] = true, -- Molavar
	[885] = true, -- Rkundzelft
	[886] = true, -- Serpent's Nest
	[887] = true, -- Ilthag's Undertower
	[888] = true, -- Ruins of Kardala
	[889] = true, -- Loth'Na Caverns
	[890] = true, -- Rkhardhark
	[891] = true, -- Haddock's Market
	[892] = true, -- Chieselshriek Mine
	[893] = true, -- Buried Sands
	[894] = true, -- Mtharnaz
	[895] = true, -- The Howling Sepulchers
	[896] = true, -- Balamath
	[897] = true, -- Fearfangs Cavern
	[898] = true, -- Exarch's Stronghold
	[899] = true, -- Zalgaz's Den
	[900] = true, -- Tombs of Na-Totambu
	[901] = true, -- Hircine Haunt

	-- Old Orsinium
	[1235] = true, -- Rkindaleft Group Event
	[1236] = true, -- Group Rkindaleft
	[1238] = true, -- Old Orsinium Group Event
	[1239] = true, -- Group Old Orsinium
	
	[1297] = true, -- Nikolvara's Kennel
	[1298] = true, -- Coldperch Cavern
	[1299] = true, -- Argent Mine
	[1300] = true, -- Thukhozod's Sanctum 
	[1301] = true, -- Watcher's Hold
	[1302] = true, -- Zthenganaz
	
	-- Hew's Bane (Thieves Guild DLC)
	[1355] = true, -- Bahraha's Gloom
	[1356] = true, -- Shark's Teeth Grotto
	
	 -- Goldcoast (Dark Brother Hood DLC)
	[1426] = true, -- Hrota Cave
	[1426] = true, -- Garlas Agea
	
	 -- Vvardenfell (Morrowind)
	[1858] = true, -- Khartag Point
	[1859] = true, -- Ashalmawia
	[1860] = true, -- Zainsipilu
	[1861] = true, -- Matus-Akin Egg Mine
	[1862] = true, -- Pulk
	[1863] = true, -- Nchuleft Depths
	
	[1846] = true, -- Nchuleftingth Group Event
	[1854] = true, -- Nchuleftingth
	[1856] = true, -- Forgotten Wastes
	[1855] = true, -- Forgotten Wastes Group Event
	
	 -- Summerset
	[2016] = true, -- Halls Of Regulation
	[2017] = true, -- The Shadow Cleft
	[2001] = true, -- King's Haven Pass
	[2002] = true, -- Eton Nir Grotto
	[2003] = true, -- Archon's Grove
	[2004] = true, -- Tor-Hame-Khard
	[2005] = true, -- Wasten Coraldale
	[2006] = true, -- Traitor's Vault
	
	[2093] = true, -- Sunhold Public Dungeon
	[2095] = true, -- Sunhold Group Event
	[2094] = true, -- Karnwasten Public Dungeon
	[2096] = true, -- Karnwasten Group Event
	
	-- Murkmire
	[2286] = true, -- Tsofeer Cavern
	[2287] = true, -- Teeth Of Sithis
	
	-- Elsweyr
	[2402] = true, -- Northern Elsweyr Cave Delver
	[2440] = true, -- Rimmen Necropolis Public Dungeon
	[2442] = true, -- Orcrest Public Dungeon
	[2444] = true, -- Rimmen Necropolis Group Event
	[2445] = true, -- Orcrest Group Event
	
	-- Southern Elsweyr
    [2557] = true, -- Forsaken Citadel
    [2558] = true, -- Moonlit Cove
	
	-- Western Skyrim - Greymoor
	[2639] = true, -- Chillwind Depths
	[2640] = true, -- Dragonhome
	[2641] = true, -- Frozen Coast
	[2642] = true, -- Midnight Barrow
	[2643] = true, -- Shadowgreen
	[2644] = true, -- The Scraps
	
	[2714] = true, -- Labyrinthian Group Event
	[2715] = true, -- Nchuthnkarst Group Event
	[2717] = true, -- Labyrinthian Public Dungeon
	[2718] = true, -- Nchuthnkarst Public Dungeon
	
	-- The Reach
	[2852] = true, -- Gloomreach
	[2853] = true, -- Briar Rock Ruins
	
	-- Blackwood
	[2965] = true, -- Undertow Cavern
	[2966] = true, -- Xi-Tsei
	[2967] = true, -- Doomvault Porcixid
	[2968] = true, -- Arpenia
	[2969] = true, -- Bloodrun Cave
	[2970] = true, -- Vunalk
	
	[2994] = true, -- The Silent Halls Group Event
	[2995] = true, -- Zenithar's Abbey Group Event
	[2996] = true, -- The Silent Halls Public Dungeon
	[2997] = true, -- Zenithar's Abbey Public Dungeon
	
	-- High Isle
	[3275] = true, -- The Firepot
	[3276] = true, -- Breakwater Cave
	[3277] = true, -- Death's Valor Keep
	[3278] = true, -- Shipwreck Shoals
	[3279] = true, -- Whalefall
	[3280] = true, -- Coral Cliffs
	
	[3281] = true, -- Ghost Haven Bay Group Event
	[3282] = true, -- Ghost Haven Bay Public Dungeon
	[3283] = true, -- Spire of the Crimson Coin Group Event
	[3284] = true -- Spire of the Crimson Coin Public Dungeon
}

local DungeonChampionsData = {}
local DungeonChampionsDataID = {}
-- format: locX, locY, achievementId, criteriaIndex

DungeonChampionsData["shadowfen"] = { --300 Sanguine's Demesne - Verified
   ["sanguinesdemesne_base"] = {
      { 0.06, 0.51, 300, 1}, -- Shrom
      { 0.81, 0.69, 300, 2}, -- Brol
      { 0.39, 0.44, 300, 3}, -- Guest That Wouldn't Leave
      { 0.51, 0.19, 300, 4}, -- Drel
      { 0.53, 0.28, 300, 5}, -- the Bloody Judge
      { 0.85, 0.55, 300, 6}, -- Fire-Eater
      { 0.19, 0.26, 372, 1}, -- Group Boss Fight-Master Grel
   },
   
   ["atanazruins_base"] = {
      { 0.55, 0.46, 245, 1}, -- Atanaz Ruins
   },
   ["shrineofblackworm_base"] = {
      { 0.63, 0.70, 250, 1}, -- Black Maw Shrine
   },
   ["brokentuskcave_base"] = {
      { 0.34, 0.27, 246, 1}, -- Broken Tusk
   },
   ["chidmoskaruins_base"] = {
      { 0.68, 0.38, 247, 1}, -- Chid-Moska Ruins
   },
   ["gandranen_base"] = {
      { 0.76, 0.60, 248, 1}, -- Gandranen
   },
   ["onkobrakwamamine_base"] = {
      { 0.64, 0.55, 249, 1}, -- Onkobra Kwama Mine
   },
}

DungeonChampionsData["stonefalls"] = { -- 368 Crow's Wood's - Verified
   ["crowswood_base"] = {
      { 0.37, 0.52, 368, 1}, -- Shriekscorn
      { 0.60, 0.41, 368, 2}, -- Grizzlehide
      { 0.29, 0.58, 368, 3}, -- Buron
      { 0.25, 0.86, 368, 4}, -- Moonlit Maiden
      { 0.56, 0.37, 368, 5}, -- Wrathvenom
      { 0.67, 0.57, 379, 1}, -- Group Boss Soul Wraith
   },
   
   ["emberflintmine_base"] = {
      { 0.42, 0.68, 203, 1}, -- Emberflint Mine
   },
   ["innerseaarmature_base"] = {
      { 0.26, 0.83, 202, 1}, -- Inner Sea Armature
   },
   ["hightidehollow_base"] = {
      { 0.48, 0.29, 206, 1}, -- Hightide Hollow
   },
   ["mephalasnest_base"] = {
      { 0.10, 0.49, 205, 1}, -- Mephala's Nest
   },
   ["sheogorathstongue_base"] = {
      { 0.21, 0.61, 208, 1}, -- Sheogorath's Tongue
   },
   ["softloamcavern_base"] = {
      { 0.68, 0.65, 207, 1}, -- Softloam Cavern
   },
}

DungeonChampionsData["deshaan"] = { -- 370 Forgotten Crypts - Verified
   ["forgottencrypts_base"] = {
      { 0.76, 0.55, 370, 1}, -- the Silent Colossus
      { 0.72, 0.27, 370, 2}, -- Fyrayn Telvanni
      { 0.56, 0.42, 370, 3}, -- the Forgotten Sheriff
      { 0.48, 0.16, 370, 4}, -- Timothe the Sharp
      { 0.58, 0.91, 388, 1}, -- Group Boss Kwama Guardians
   },
   
   ["corpsegarden_base"] = {
      { 0.25, 0.41, 269, 1}, -- Corpse Garden
   },
   ["kwamacolony_base"] = {
      { 0.53, 0.75, 264, 1}, -- Lady Llarel's Shelter
   },
   ["lowerbthanuel_base"] = {
      { 0.53, 0.42, 265, 1}, -- Lower Bthanual
   },
   ["desolatecave_base"] = {
      { 0.80, 0.37, 268, 1}, -- Knife Ear Grotto
   },
   ["unexploredcrag_base"] = {
      { 0.47, 0.55, 267, 1}, -- Taleon's Crag
   },
   ["triplecirclemine_base"] = {
      { 0.56, 0.32, 266, 1}, -- Triple Circle Mine
   },
}

DungeonChampionsData["therift"] = { -- 374 Lion's Den - Verified by Garkin
   ["thelionsden_base"] = {
      { 0.66, 0.31, 374, 1}, -- Lieutenant Derone
      { 0.73, 0.34, 374, 2}, -- Sargent Lort
      { 0.70, 0.57, 374, 3}, -- Lieutenant Stenric
      { 0.33, 0.22, 374, 4}, -- Sargent Themond
      { 0.82, 0.20, 374, 5}, -- Frost Troll
      { 0.38, 0.13, 374, 6}, -- Den Mother
      { 0.68, 0.53, 374, 7}, -- Crazy Sebastien
      { 0.11, 0.87, 371, 1}, -- Group Boss Loney Giant
   },
   
   ["avancheznel_base"] = {
      { 0.51, 0.55, 331, 1}, -- Avancheznel
   },
   ["brokenhelm_base"] = {
      { 0.57, 0.70, 330, 1}, -- Broken Helm
   },
   ["ebonmeretower_base"] = {
      { 0.54, 0.84, 329, 1}, -- Faldar's Tooth
   },
   ["fortgreenwall_base"] = {
      { 0.67, 0.83, 332, 1}, -- Fort Greenwall
   },
   ["shroudhearth_base"] = {
      { 0.61, 0.51, 333, 1}, -- Shroud Hearth Barrow
   },
   ["snaplegcave_base"] = {
      { 0.51, 0.38, 334, 1}, -- Snapleg Cave
   },
}
 
DungeonChampionsData["eastmarch"] = { -- 376 Hall of the Dead - Verified
   ["hallofthedead_base"] = {
      { 0.76, 0.79, 376, 1}, -- Gefvid Lodorrsbane
      { 0.42, 0.90, 376, 2}, -- Hlaki Lodorrsbane
      { 0.24, 0.75, 376, 3}, -- Hrerik Lodorrsbane
      { 0.66, 0.93, 376, 4}, -- Jalfrid Lodorrsbane
      { 0.34, 0.88, 376, 5}, -- Sorgild Lodorrsbane
      { 0.42, 0.22, 376, 6}, -- the Old Priest
      { 0.76, 0.50, 381, 1}, -- Group Boss Rynir the Destroyer
   },
   
   ["thebastardstomb_base"] = {
      { 0.80, 0.73, 256, 1}, -- Bastard's Tomb
   },
   ["thechillhollow_base"] = {
      { 0.65, 0.40, 251, 1}, -- Chill Hollow
   },
   ["thefrigidgrotto_base"] = {
      { 0.72, 0.30, 254, 1}, -- Frigid Grotto
   },
   ["icehammersvault_base"] = {
      { 0.47, 0.48, 252, 1}, -- Icehammer's Vault
   },
   ["oldsordscave_base"] = {
      { 0.85, 0.15, 253, 1}, -- Old Sord's Cave
   },
   ["stormcragcrypt_base"] = {
      { 0.79, 0.15, 255, 1}, -- Stormcrag Crypt
   },
}

DungeonChampionsData["rivenspire"] = { -- 378 Obsidian Scar - Verified
   ["obsidianscar_base"] = {
      { 0.68, 0.75, 378, 1}, -- Doom Witch Dekamma
      { 0.56, 0.88, 378, 2}, -- Ogmash the Mighty
      { 0.89, 0.44, 378, 3}, -- Bumbuk Bear-Slayer
      { 0.71, 0.23, 378, 4}, -- High Overseer Kvotai
      { 0.24, 0.39, 378, 5}, -- Murgbakh Axe-Hands
      { 0.59, 0.17, 378, 6}, -- Grand Shaman Glazgor
      { 0.24, 0.42, 378, 7}, -- Zozullu
      { 0.38, 0.14, 713, 1}, -- Group Boss Zilbash the Deceiver
   },
   
   ["crestshademine_base"] = {
      { 0.45, 0.43, 227, 1}, -- Crestshade Mine
   },
   ["erokii_base"] = {
      { 0.69, 0.69, 231, 1}, -- Erokii Ruins
   },
   ["flyleafcatacombs_base"] = {
      { 0.68, 0.19, 228, 1}, -- Flyleaf Catacombs
   },
   ["hildunessecretrefuge_base"] = {
      { 0.84, 0.27, 232, 1}, -- Hildune's Secret Refuge
   },
   ["orcsfingerruins_base"] = {
      { 0.77, 0.74, 230, 1}, -- Orc's Finger Ruins
   },
   ["tribulationcrypt_base"] = {
      { 0.68, 0.20, 229, 1}, -- Tribulation Crypt
   },
}

DungeonChampionsData["auridon"] = { -- 390 Toothmaul Gully - Verified
   ["toothmaulgully_base"] = {
      { 0.48, 0.78, 390, 1}, -- Dzeizik
      { 0.24, 0.27, 390, 2}, -- Nitch
      { 0.61, 0.67, 390, 3}, -- Slakkith and Gorg
      { 0.28, 0.43, 390, 4}, -- Thek and Black Bessie
      { 0.45, 0.63, 390, 5}, -- Togga the Skewerer
      { 0.48, 0.65, 468, 1}, -- Group Boss Bloodroot
   },
   
   ["bewan_base"] = {
      { 0.56, 0.21, 293, 1}, -- Bewan
   },
   ["delsclaim_base"] = {
      { 0.80, 0.16, 288, 1}, -- Del's Claim
   },
   ["entilasfolly_base"] = {
      { 0.13, 0.45, 290, 1}, -- Entila's Folly
   },
   ["mehrunesspite_base"] = {
      { 0.29, 0.39, 292, 1}, -- Mehrunes Spite
   },
   ["ondil_base"] = {
      { 0.50, 0.27, 289, 1}, -- Ondil
   },
   ["wansalen_base"] = {
      { 0.36, 0.86, 291, 1}, -- Wansalen
   },
}

DungeonChampionsData["alikr"] = { -- 396 Lost City of the Na-Totambu - Verified
   ["lostcity_base"] = {
      { 0.42, 0.88, 396, 1}, -- Arbhu-ra
      { 0.66, 0.72, 396, 2}, -- Clacker
      { 0.66, 0.45, 396, 3}, -- Gritstone Patriarch
      { 0.34, 0.58, 396, 4}, -- The Silent Sword
      { 0.46, 0.94, 396, 5}, -- Vath'ira
      { 0.34, 0.63, 707, 1}, -- Group Boss Puzzle of the Guardians
   },
   
   ["aldunz_base"] = {
      { 0.71, 0.55, 416, 1}, -- Aldunz Ruins
   },
   ["coldrockdiggings_base"] = {
      { 0.21, 0.82, 419, 1}, -- Coldrock Diggings
   },
   ["divadschagrinmine_base"] = {
      { 0.73, 0.55, 414, 1}, -- Divad's Chagrin Mine
   },
   ["sandblownmine_base"] = {
      { 0.90, 0.67, 420, 1}, -- Sandblown Mine
   },
   ["santaki_base"] = {
      { 0.35, 0.21, 412, 1}, -- Santaki
   },
   ["yldzuun_base"] = {
      { 0.81, 0.77, 423, 1}, -- Yldzuun Ruins
   },
}

--data are copied from Joe_Schmo2840's APB - All Public Bosses addon
DungeonChampionsData["cyrodiil"] = {
--Cyrodiil (all, lvl 10+)
   ["capstonecave_base"] = {
      { 0.718519, 0.166667, 736, 1 }, --Claudette the Sharper
   },
   ["potholecavern_base"] = {
      { 0.620988, 0.462963, 734, 1 }, --Serrin Vol
      { 0.604938, 0.697531, 734, 2 }, --Diabolist Vethisa
      { 0.5370, 0.1333, 734, 3 },     --Blighttooth
   },
   ["breakneckcave_base"] = {
      { 0.271605, 0.301235, 731, 1 }, --Hegris
      { 0.277778, 0.588889, 731, 2 }, --Longfang
   },
   ["lipsandtarn_base"] = {
      { 0.392593, 0.177778, 738, 1 }, --Gaston Ashham
      { 0.253086, 0.586420, 738, 2 }, --Marbita
   },
   ["echocave_base"] = {
      { 0.280, 0.188, 737, 1 }, --Sargos Grent --bug #1361
   },
   ["toadstoolhollowlower_base"] = {
      { 0.085185, 0.527160, 740, 1 }, --Lucienne Cerine
      { 0.279012, 0.522222, 740, 2 }, --Captain Roreles
      { 0.307407, 0.751852, 740, 3 }, --Captain Serniel
      { 0.303704, 0.344444, 740, 4 }, --General Virane
   },
   ["toadstoolhollow_base"] = {
      { 0.266667, 0.306173, 740, 5 }, --Dreadfang
   },
   ["redrubycave_base"] = {
      { 0.379012, 0.220988, 739, 1 }, --Endare
      { 0.780247, 0.262963, 739, 2 }, --Zandur
   },
   ["bloodmaynecave_base"] = {
      { 0.137037, 0.353086, 730, 1 }, --Acanthia
      { 0.475309, 0.386420, 730, 2 }, --Ironlash
      { 0.392593, 0.446914, 730, 3 }, --Razorback
   },
   ["newtcave_base"] = {
      { 0.148148, 0.319753, 745, 1 }, --Gravel Tooth
      { 0.611111, 0.733333, 745, 2 }, --Rock Wing
   },
   ["crackedwoodcave_base"] = {
      { 0.701235, 0.380247, 742, 1 }, --Mebs Runnyeye
      { 0.329630, 0.085185, 742, 2 }, --Regsrot Blacktongue
      { 0.344444, 0.356790, 742, 3 }, --Traug Wolfbreath
   },
   ["muckvalleycavern_base"] = {
      { 0.187654, 0.690123, 744, 1 }, --Kerks Half-Ear
      { 0.782716, 0.159259, 744, 2 }, --Ogre Biter
      { 0.375309, 0.888889, 744, 3 }, --Webmistress
   },
   ["vahtacen_base"] = {
      { 0.145679, 0.653086, 747, 1 }, --Faceless
   },
   ["quickwatercave_base"] = {
      { 0.401235, 0.930864, 746, 1 }, --Athal Andas
      { 0.3456, 0.4430, 746, 2 }, --Steel-Tail
   },
   ["kingscrest_base"] = {
      { 0.846914, 0.512346, 743, 1 }, --Cynaceae the Verdant
   },
   ["serpenthollowcave_base"] = {
      { 0.225926, 0.571605, 735, 1 }, --Bruuke
      { 0.402469, 0.267901, 735, 2 }, --Bear Matriarch
   },
   ["haynotecave_base"] = {
      { 0.316049, 0.483951, 732, 1 }, --Theurgist Thelas
      { 0.549383, 0.193827, 732, 2 }, --Diabolist Volcatia
   },
   ["nisincave_base"] = {
      { 0.108642, 0.645679, 733, 1 }, --Barasatii
      { 0.600000, 0.601235, 733, 2 }, --Volgo the Harrower
   },
   ["underpallcave_base"] = {
      { 0.301235, 0.172840, 741, 1 }, --Raelynne Ashham
      { 0.717284, 0.607407, 741, 2 }, --Emelin the Returned
   },
}

DungeonChampionsData["grahtwood"] = { -- 1049 Root Sunder - Verified
   ["rootsunder_base"] = {
      { 0.59, 0.60, 1049, 1}, -- the Devil Wrathmaw
      { 0.22, 0.56, 1049, 2}, -- Rootbiter
      { 0.89, 0.45, 1049, 3}, -- Rustjaw
      { 0.75, 0.46, 1049, 4}, -- Silent Claw
      { 0.60, 0.75, 1049, 5}, -- Great Thorn
      { 0.51, 0.34, 1049, 6}, -- Thick-Bark
      { 0.66, 0.17,  470, 1}, -- Group Boss The Bonemonger
   },
   
   ["burrootkwamamine_base"] = {
      { 0.77, 0.50, 576, 1}, -- Burroot Kwama Mine
   },
   ["mobarmine_base"] = {
      { 0.10, 0.61, 578, 1}, -- Mobar Mine
   },
   ["nesalas_base"] = {
      { 0.63, 0.72, 573, 1}, -- Ne Salas
   },
   ["dessicatedcave_base"] = {
      { 0.35, 0.24, 574, 1}, -- The Scuttle Pit
   },
   ["vindeathcave_base"] = {
      { 0.31, 0.76, 575, 1}, -- Vinedeath Cave
   },
   ["wormrootdepths_base"] = {
      { 0.68, 0.37, 577, 1}, -- Wormroot Depths
   },

}

DungeonChampionsData["greenshade"] = { -- 1050 Rulanyil's Fall - Verified
   ["rulanyilsfall_base"] = {
      { 0.26, 0.55, 1050, 1}, -- Hannat the Bonebringer
      { 0.34, 0.35, 1050, 2}, -- Magna Tharn
      { 0.64, 0.44, 1050, 3}, -- Necromancer Utiasl
      { 0.79, 0.39, 1050, 4}, -- Onkal the Harbinger
      { 0.50, 0.44, 1050, 5}, -- Skirar the Decaying
      { 0.13, 0.38, 1050, 6}, -- Vree Foulflesh
      { 0.83, 0.66,  445, 1}, -- Group Boss Hergor the Fallen
   },
   
   ["barrowtrench_base"] = {
      { 0.31, 0.60, 559, 1}, -- Barrow Trench
   },
   ["caracdena_base"] = {
      { 0.58, 0.63, 553, 1}, -- Carac Dena
   },
   ["gurzagsmine_base"] = {
      { 0.75, 0.46, 555, 1}, -- Gurzag's Mine
   },
   ["harridanslair_base"] = {
      { 0.21, 0.76, 558, 1}, -- Harridan's Lair
   },
   ["narilnagaia_base"] = {
      { 0.75, 0.61, 567, 1}, -- Naril Nagaia
   },
   ["theunderroot_base"] = {
      { 0.33, 0.27, 550, 1}, -- The Underroot
   },
}

DungeonChampionsData["malabaltor"] = { -- 1051 Crimson Cove - Verified
   ["crimsoncove_base"] = {
      { 0.53, 0.48, 1051, 2}, -- Povaren One-Eye
      { 0.53, 0.34, 1051, 3}, -- Yiralai the Wicked
      { 0.35, 0.55, 1051, 4}, -- Old Strongclaw
      { 0.69, 0.55, 1051, 5}, -- Rokut the Mauler
      { 0.60, 0.75,  460, 1}, -- Group Boss Flat Tooth
   },

   ["crimsoncove02_base"] = {
      { 0.67, 0.33, 1051, 1}, -- Pilot Ostrala
      { 0.53, 0.48, 1051, 2}, -- Povaren One-Eye
      { 0.53, 0.34, 1051, 3}, -- Yiralai the Wicked
      { 0.35, 0.55, 1051, 4}, -- Old Strongclaw
      { 0.69, 0.55, 1051, 5}, -- Rokut the Mauler
      { 0.61, 0.10, 1051, 6}, -- Reja Laransdottir
      { 0.8690, 0.2951, 1051, 7}, -- Viro Redhands --bug #1361, #1408
      { 0.60, 0.75,  460, 1}, -- Group Boss Flat Tooth
   },
   
   ["blackvineruins_base"] = {
      { 0.54, 0.25, 281, 1}, -- Black Vine Ruins
   },
   ["deadmansdrop_base"] = {
      { 0.37, 0.71, 274, 1}, -- Dead Man's Drop
   },
   ["hoarvorpit_base"] = {
      { 0.65, 0.45, 298, 1}, -- Hoarvor Pit
   },
   ["rootsofsilvenar_base"] = {
      { 0.85, 0.58, 282, 1}, -- Roots of Silvenar
   },
   ["shaelruins_base"] = {
      { 0.75, 0.70, 286, 1}, -- Shael Ruins
   },
   ["tomboftheapostates_base"] = {
      { 0.61, 0.59, 297, 1}, -- Tomb Of The Apostates
   },
}

DungeonChampionsData["reapersmarch"] = { -- 1052 The Vile Manse - Verified
   ["thevilemansefirstfloor_base"] = {
      { 0.36, 0.55, 1052, 2}, -- the Marrow Thief
      { 0.69, 0.28, 1052, 3}, -- Pelona the Marksman
      { 0.69, 0.51, 1052, 4}, -- Sergeant Atilus
      { 0.33, 0.13, 1052, 5}, -- Venissia the Twisted
      { 0.47, 0.90, 469 , 1}, -- Group Boss Graccus' frost experiments
   },
   ["thevilemansesecondfloor_base"] = {
      { 0.33, 0.61, 1052, 1}, -- the Ancient Primalist
      { 0.65, 0.41, 1052, 6}, -- Xevat-Golgok
   },
   
   ["clawsstrike_base"] = {
      { 0.87, 0.69, 456, 1}, -- Claw's Strike
   },
   ["fardirsfolly_base"] = {
      { 0.76, 0.15, 457, 1}, -- Fardir's Folly
   },
   ["jodeslight_base"] = {
      { 0.52, 0.58, 458, 1}, -- Jode's Light
   },
   ["kunasdelve_base"] = {
      { 0.19, 0.30, 453, 1}, -- Kuna's Delve
   },
   ["thibautscairn_base"] = {
      { 0.21, 0.20, 454, 1}, -- Thibaut's Cairn
   },
   ["weepingwindcave_base"] = {
      { 0.64, 0.31, 455, 1}, -- Weeping Wind Cave
   },
}

DungeonChampionsData["glenumbra"] = { -- 1053 Bad Man's Hallows - Verified
   ["badmanscave_base"] = {
      { 0.72, 0.73, 1053, 1}, -- Bloatgut
      { 0.59, 0.44, 1053, 2}, -- Skitterflame
      { 0.43, 0.72, 1053, 3}, -- Rutmange
      { 0.53, 0.68, 1053, 4}, -- Bloodcraw
      { 0.18, 0.40,  380, 1}, -- Group Boss Giant Snake Mother
   },
   
   ["cryptwatchfort_base"] = {
      { 0.46, 0.80, 220, 1}, -- Cryptwatch Fort
   },
   ["enduum_base"] = {
      { 0.70, 0.08, 217, 1}, -- Enduum
   },
   ["eboncrypt_base"] = {
      { 0.66, 0.47, 219, 1}, -- Ebon Crypt
   },
   ["ilessantower_base"] = {
      { 0.42, 0.48, 215, 1}, -- Ilessan Tower
   },
   ["minesofkhuras_base"] = {
      { 0.32, 0.22, 218, 1}, -- Mines of Khuras
   },
   ["silumm_base"] = {
      { 0.81, 0.47, 216, 1}, -- Silumm
   },
}

DungeonChampionsData["stormhaven"] = { -- 1054 Bonesnap Ruins - Verified
   ["bonesnapruinssecret_base"] = {
      { 0.62, 0.61, 1054, 1}, -- Lughar
      { 0.66, 0.42, 1054, 2}, -- Bloodmaw
      { 0.44, 0.33, 1054, 3}, -- Rork Bonehammer
      { 0.33, 0.54, 1054, 4}, -- Mar-Zak
      { 0.28, 0.73, 1054, 5}, -- Thargan
      { 0.50, 0.78, 1054, 6}, -- Torak Shadebringer
      { 0.40, 0.17,  714, 1}, -- Group Boss The Eternal One
   },
   
   ["bearclawmine_base"] = {
      { 0.28, 0.62, 225, 1}, -- Bearclaw Mine
   },
   ["farangelsdelve_base"] = {
      { 0.26, 0.49, 224, 1}, -- Farangel's Delve
   },
   ["koeglinmine_base"] = {
      { 0.44, 0.34, 222, 1}, -- Koeglin Mine
   },
   ["pariahcatacombs_base"] = {
      { 0.30, 0.21, 223, 1}, -- Pariah Catacombs
   },
   ["portdunwatch_base"] = {
      { 0.61, 0.44, 221, 1}, -- Portdun Watch
   },
   ["norvulkruins_base"] = {
      { 0.60, 0.67, 226, 1}, -- Norvolk Ruins
   },
}

DungeonChampionsData["bangkorai"] = { -- 1055 Razak's Wheel - Verified
   ["razakswheel_base"] = {
      { 0.79, 0.36, 1055, 1}, -- Razak's Behemoth
      { 0.43, 0.42, 1055, 2}, -- Centurion Solinthia
      { 0.77, 0.62, 1055, 3}, -- Archivist Poneria
      { 0.37, 0.58, 1055, 4}, -- Archivist Sanctius
      { 0.71, 0.51, 1055, 5}, -- Rkurdamz
      { 0.68, 0.79, 1055, 6}, -- Mzanchndalft
      { 0.86, 0.52,  708, 1}, -- Group Boss flesh atronach
   },
   
   ["cryptoftheexiles_base"] = {
      { 0.17, 0.59, 541, 1}, -- Crypt of the Exiles
   },
   ["jaggerjaw_base"] = {
      { 0.47, 0.11, 544, 1}, -- Klathzgar
   },
   ["rubblebutte_base"] = {
      { 0.62, 0.45, 543, 1}, -- Rubble Butte
   },
   ["murciensclaim_base"] = {
      { 0.62, 0.35, 540, 1}, -- Torog's Spite
   },
   ["trollstoothpick_base"] = {
      { 0.57, 0.52, 539, 1}, -- Troll's Toothpick
   },
   ["viridianwatch_base"] = {
      { 0.72, 0.48, 542, 1}, -- Viridian Watch
   },
}

DungeonChampionsData["coldharbor"] = { -- Village of the Lost
   ["villageofthelost_base"] = {
      { 0.85, 0.41, 1056, 1}, -- Mirok the Deplorable
      { 0.19, 0.67, 1056, 2}, -- Gruthaz
      { 0.32, 0.27, 1056, 3}, -- Vrendi
      { 0.34, 0.67, 1056, 4}, -- Aez the Collector
      { 0.72, 0.35, 1056, 5}, -- Iluzan
      { 0.77, 0.57, 1056, 6}, -- Macius Cento
      { 0.48, 0.45, 1056, 7}, -- Uluzzur
      { 0.38, 0.23,  874, 1}, -- Group Boss Zatalguch
   },
   
   ["aba-loria_base"] = {
      { 0.75, 0.63, 432, 1}, -- Aba-Loria
   },
   ["caveoftrophies_base"] = {
      { 0.56, 0.36, 434, 1}, -- Cave of Trophies
   },
   ["vaultofhamanforgefire_base"] = {
      { 0.67, 0.67, 435, 1}, -- Forgefire Vault
   },
   ["depravedgrotto_base"] = {
      { 0.70, 0.58, 433, 1}, -- Grotto of Depravity
   },
   ["malsorrastomb_base"] = {
      { 0.77, 0.37, 436, 1}, -- Mal Sorra's Tomb
   },
   ["wailingmaw_base"] = {
      { 0.60, 0.34, 437, 1}, -- Wailing Maw
   },
}

DungeonChampionsData["craglorn"] = { -- Craglorn
   ["molavar_base"] = {
      { 0.4759, 0.3254, 884, 1}, -- Molavar
   },
   ["rkundzelft_base"] = {
      { 0.4919, 0.3714, 885, 1}, -- Rkundzelft
   },
   ["serpentsnest_base"] = {
      { 0.4915, 0.2318, 886, 1}, -- Serpent's Nest
   },
   ["ilthagsundertower_base"] = {
      { 0.1619, 0.4716, 887, 1}, -- Ilthag's Undertower
   },
   ["kardala_base"] = {
      { 0.6215, 0.3612, 888, 1}, -- Ruins of Kardala
   },
   ["lothna_base"] = {
      { 0.6115, 0.3412, 889, 1}, -- Loth'Na Caverns
   },
   ["rkhardahrk_0"] = {
      { 0.1385, 0.4941, 890, 1}, -- Rkhardhark
   },
   ["haddock_base"] = {
      { 0.7482, 0.3277, 891, 1}, -- Haddock's Market
   },
   ["chiselshriek_base"] = {
      { 0.6982, 0.2177, 892, 1}, -- Chieselshriek Mine
   },
   ["burriedsands_base"] = {
      { 0.7270, 0.2846, 893, 1}, -- Buried Sands
   },
   ["mtharnaz_base"] = {
      { 0.1710, 0.6216, 894, 1}, -- Mtharnaz
   },
   ["howlingsepulchersoverland_base"] = {
      { 0.8298, 0.4681, 895, 1}, -- The Howling Sepulchers
   },
   ["balamath_base"] = {
      { 0.7712, 0.2605, 896, 1}, -- Balamath
   },
   ["fearfang_base"] = {
      { 0.1938, 0.5921, 897, 1}, -- Fearfangs Cavern
   },
   ["exarchsstronghold_base"] = {
      { 0.4180, 0.8221, 898, 1}, -- Exarch's Stronghold
   },
   ["thaliasretreat_base"] = {
      { 0.2818, 0.1511, 899, 1}, -- Zalgaz's Den
   },
   ["cryptoftarishzizone_base"] = {
      { 0.5630, 0.6596, 900, 1}, -- Tombs of Na-Totambu
   },
   ["hircineshaunt_base"] = {
      { 0.2110, 0.7716, 901, 1}, -- Hircine Haunt
   },
}

DungeonChampionsData["wrothgar"] = { -- Old Orsinium
   ["oldorsiniummap02_base"] = {
      { 0.17, 0.85, 1239, 3}, -- Great Zoraluma
   },
   ["oldorsiniummap03_base"] = {
      { 0.31, 0.89, 1239, 1}, -- Orzik the Storm Born
   },
   ["oldorsiniummap04_base"] = {
      { 0.07, 0.52, 1239, 4}, -- Janavynnm
   },
   ["oldorsiniummap05_base"] = {
      { 0.49, 0.27, 1239, 2}, -- Mercedune the Cursed
   },
   ["oldorsiniummap06_base"] = {
      { 0.76, 0.57, 1239, 5}, -- Batunulur
   },
   ["oldorsiniummap07_base"] = {
      { 0.15, 0.74, 1238, 1}, -- Group Boss Pyre Keeper Rugdrulz
   },

   -- 1236 Rkindaleft
   ["rkindaleftint01_base"] = {
      { 0.69, 0.80, 1236, 4}, -- Sharga the Firestarter
   },
   ["rkindaleftoutside_base"] = {
      { 0.57, 0.55, 1236, 1}, -- Rkinadhar
      { 0.11, 0.47, 1236, 2}, -- Wandering Illia
      { 0.20, 0.33, 1236, 3}, -- Azzorinuz  Eingang = 0.265, 0.39
      { 0.57, 0.43, 1235, 1}, -- Group Boss Resonant Centurion (door)
   },
   ["rkindaleftint02_base"] = {
      { 0.50, 0.49, 1235, 1}, -- Group Boss Resonant Centurion (room)
   },
   
   ["argentmine2_base"] = {
      { 0.71, 0.25, 1299, 1}, -- Argent Mine
   },
   ["coldperchcavern_base"] = {
      { 0.75, 0.48, 1298, 1}, -- Coldperch Cavern
   },
   ["kennelrun_base"] = {
      { 0.42, 0.35, 1297, 1}, -- Nikolvara's Kennel
   },
   ["thukozods_base"] = {
      { 0.78, 0.74, 1300, 1}, -- Thukhozod's Sanctum
   },
   ["watchershold_base"] = {
      { 0.63, 0.25, 1301, 1}, -- Watcher's Hold
   },
   ["zthenganaz_base"] = {
      { 0.89, 0.33, 1302, 1}, -- Zthenganaz
   },
}

DungeonChampionsData["thievesguild"] = { -- Hew's Bane (Thieves Guild DLC)
   ["bahrahasgloom_base"] = {
      { 0.66, 0.68, 1355, 1}, -- Bahraha's Gloom
   },
   ["sharktoothgrotto2_base"] = {
      { 0.18, 0.60, 1356, 1}, -- Shark's Teeth Grotto
   },
}

DungeonChampionsData["darkbrotherhood"] = { -- Goldcoast (Dark Brother Hood DLC)
   ["hrotacave_base"] = {
      { 0.87, 0.75, 1426, 1},  -- Hrota Cave
   },
   
   ["garlasagea_base"] = {
      { 0.58, 0.42, 1427, 1},  -- Garlas Agea
   },
}

DungeonChampionsData["vvardenfell"] = { -- Vvardenfell (Morrowind)
   ["khartagpoint_base"] = {
      { 0.76, 0.18, 1858, 1}, -- Khartag Point
   },
   ["ashalmawia02_base"] = {
      { 0.35, 0.31, 1859, 1}, -- Ashalmawia
   },
   ["zainsipilu_base"] = {
      { 0.13, 0.79, 1860, 1}, -- Zainsipilu
   },
   ["matusakin_base"] = {
      { 0.53, 0.61, 1861, 1}, -- Matus-Akin Egg Mine
   },
   ["pulklower_base"] = {
      { 0.80, 0.50, 1862, 1}, -- Pulk
   },
   ["nchuleftdepths_base"] = {
      { 0.48, 0.42, 1863, 1}, -- Nchuleft Depths
   },
   
      -- Forgotten Wastes
   ["forgottenwastesext_base"] = {
      { 0.22, 0.55, 1855, 1}, -- Forgotten Wastes Group Event
   },
   ["drinithtombfw01_base"] = {
      { 0.68, 0.82, 1856, 1}, -- Voracity
   },
   ["koradurfw02_base"] = {
      { 0.27, 0.75, 1856, 2}, -- Mynar Igna
   },
   ["cavernsofkogoruhnfw03_base"] = {
      { 0.09, 0.24, 1856, 3}, -- Beckoner Morvayn
   },
   ["forgottendepthsfw04_base"] = {
      { 0.20, 0.49, 1856, 4}, -- Coaxer Veran, Castigator Athin, and Confessor Dradas
   },
   ["forgottenwastesext_base"] = {
      { 0.57, 0.50, 1856, 5}, -- The Cliff Strider Matriarch
   },
   
   -- Nchuleftingth
   ["nchuleftingth6_base"] = {
      { 0.49, 0.59, 1846, 1}, -- Nchuleftingth Group Event
   },
   ["nchuleftingth4_base"] = {
      { 0.1215, 0.4660, 1854, 1}, -- Renduril the Hammer and Friar Hadelar
   },
   ["nchuleftingth2_base"] = {
      { 0.46, 0.66, 1854, 2}, -- The Guardian of Bthark
   },
   ["nchuleftingth3_base"] = {
      { 0.36, 0.26, 1854, 3}, -- Mud-Tusk
   },
   ["nchuleftingth4_base"] = {
      { 0.43, 0.44, 1854, 4}, -- Nilarion the Cavalier
   },
   ["nchuleftingth5_base"] = {
      { 0.48, 0.40, 1854, 5}, -- Steamreaver
   },
}

DungeonChampionsData["clockwork"] = { -- The Clockwork City DLC
   ["hallsofregulation_2"] = {
      { 0.72, 0.40, 2016, 1}, -- Halls Of Regulation
   },
   ["shadowcleft_base"] = {
      { 0.36, 0.22, 2017, 1}, -- The Shadow Cleft
   },
}

DungeonChampionsData["summerset"] = { -- Summerset
   ["kingshavenext_base"] = {
      { 0.17, 0.41, 2001, 1}, -- King's Haven Pass
   },
   
   ["etonnir_01"] = {
      { 0.14, 0.77, 2002, 1}, -- Eton Nir Grotto
   },
   
   ["archonsgrove_base"] = {
      { 0.12, 0.58, 2003, 1}, -- Archon's Grove
   },
   
   ["torhamekhard_01"] = {
      { 0.66, 0.16, 2004, 1}, -- Tor-Hame-Khard
   },
   ["torhamekhard_02"] = {
      { 0.66, 0.16, 2004, 1}, -- Tor-Hame-Khard
   },
   
   ["wastencoraldale_base"] = {
      { 0.61, 0.35, 2005, 1}, -- Wasten Coraldale
   },
   
   ["traitorsvault01_base"] = {
      { 0.72, 0.72, 2006, 1}, -- Traitor's Vault
   },
   
   ["traitorsvault02_base"] = {
      { 0.72, 0.72, 2006, 1}, -- Traitor's Vault
   },
   
   ["traitorsvault03_base"] = {
      { 0.72, 0.72, 2006, 1}, -- Traitor's Vault
   },
   
   ["sunhold_base"] = { -- Sunhold Public Dungeon
      { 0.64, 0.42, 2093, 1}, -- Kolondir the Demon
      { 0.80, 0.75, 2093, 2}, -- Welkadra
      { 0.43, 0.80, 2093, 3}, -- Shipbreaker
      { 0.45, 0.26, 2093, 4}, -- The Pyandonean Wind
      { 0.59, 0.37, 2093, 5}, -- Captain Quergura
      { 0.41, 0.15, 2095, 1}, -- Konnugil the Leviathan Group Event
   },
   
   ["sum_karnwasten"] = { -- Karnwasten Public Dungeon
      { 0.21, 0.45, 2094, 1}, -- Tendirrion
      { 0.18, 0.67, 2094, 2}, -- Gilleruk the Viscous
      { 0.64, 0.81, 2094, 3}, -- Waste of Flesh
      { 0.65, 0.51, 2094, 4}, -- Shahmar
      { 0.52, 0.60, 2094, 5}, -- Nolore Stieve
      { 0.90, 0.73, 2096, 1}, -- Sea Sload K'Garza Group Event
   },
}

DungeonChampionsData["murkmire"] = { -- Murkmire
   ["tsofeercavern01_0"] = {
      { 0.7709, 0.3628, 2286, 1}, -- Tsofeer Cavern
   },
   ["teethofsithis02b_base"] = {
      { 0.5337, 0.6837, 2287, 1}, -- Teeth Of Sithis
   },
}

DungeonChampionsData["elsweyr"] = { -- Elsweyr
   ["abodeofignominy_base"] = {
      { 0.1755, 0.7533, 2402, 1}, -- Abode of Ignominy
   },
   ["predatorrise_base"] = {
      { 0.5670, 0.4132, 2402, 2}, -- Predator Mesa
   },
   ["desertwind_base"] = {
      { 0.5569, 0.1809, 2402, 3}, -- Desert Wind Caverns
   },
   ["desertwind2a_base"] = {
      { 0.5569, 0.1809, 2402, 3}, -- Desert Wind Caverns
   },
   ["tombofserpents_base"] = {
      { 0.5061, 0.4579, 2402, 4}, -- Tomb Of The Serpents
   },
   ["thescab_base"] = {
      { 0.4612, 0.2077, 2402, 5}, -- DarkPool Mine
   },
   ["thetangle_base"] = {
      { 0.4529, 0.6280, 2402, 6}, -- The Tangle
   },
   ["rimmennecropolis_base"] = { -- Rimmen Necropolis
      { 0.1028, 0.4707, 2440, 1}, -- Gormandizer Blyhicius
	  { 0.9008, 0.7457, 2440, 2}, -- Lieutenant Kurzatha
	  { 0.7908, 0.4004, 2440, 3}, -- Lieutenant Fazumir
      { 0.1100, 0.6781, 2440, 4}, -- Bakea the Forge Guardian
	  { 0.4914, 0.2480, 2440, 5}, -- Jinninji-ri, Zebiden-jo, and Tullar-dra
      { 0.4896, 0.6583, 2444, 1}, -- Rimmen Necropolis Group Event
   },
   ["orcrest_base"] = { -- Orcrest
      { 0.5387, 0.6400, 2442, 1}, -- Eludin the Cannibal King
	  { 0.2739, 0.7846, 2442, 2}, -- Meat of the Discarded
	  { 0.6136, 0.4172, 2442, 3}, -- Alchemist Zhininda
      { 0.4276, 0.4339, 2442, 4}, -- Charred Prince
	  { 0.4050, 0.5752, 2442, 5}, -- Noordigloop the Clog
      { 0.7760, 0.2989, 2445, 1}, -- Plague of Crows in Orcrest
   },
    ["orcrest2_base"] = { -- Orcrest
      { 0.5387, 0.6400, 2442, 1}, -- Eludin the Cannibal King
	  { 0.2739, 0.7846, 2442, 2}, -- Meat of the Discarded
	  { 0.6136, 0.4172, 2442, 3}, -- Alchemist Zhininda
      { 0.4276, 0.4339, 2442, 4}, -- Charred Prince
	  { 0.4050, 0.5752, 2442, 5}, -- Noordigloop the Clog
      { 0.7760, 0.2989, 2445, 1}, -- Plague of Crows in Orcrest
   },
   ["orcrestsewer_base"] = { -- Orcrest
   	  { 0.4843, 0.4882, 2442, 5}, -- Noordigloop the Clog
   }
}

DungeonChampionsData["southernelsweyr"] = { -- Southern Elsweyr
   ["houseofembersoutside_base"] = {
      { 0.4575, 0.2774, 2557, 1}, -- Forsaken Citadel
   },
   ["moonlitcove01_base"] = {
      { 0.4255, 0.4174, 2558, 1}, -- Moonlit Cove
   },
   ["moonlitcove02_base"] = {
      { 0.4255, 0.4174, 2558, 1}, -- Moonlit Cove
   },
   ["moonlitcove03_base"] = {
      { 0.4555, 0.4174, 2558, 1}, -- Moonlit Cove
   },
   ["moonlitcove04_base"] = {
      { 0.4255, 0.4174, 2558, 1}, -- Moonlit Cove
   },
   ["moonlitcove05_base"] = {
      { 0.4255, 0.4174, 2558, 1}, -- Moonlit Cove
   },
}

DungeonChampionsData["skyrim"] = { -- Western Skyrim - Greymoor
   ["chillwinddepths_base"] = {
      { 0.4416, 0.1946, 2639, 1}, -- Frozen Coast
   },
   ["dragonhome_base"] = {
      { 0.3493, 0.2985, 2640, 1}, -- Dragonhome
   },
   ["frozencoast_base"] = {
      { 0.7215, 0.1912, 2641, 1}, -- Frozen Coast
   },
   ["midnightbarrow_base"] = {
      { 0.6324, 0.1261, 2642, 1}, -- Midnight Barrow
   },
   ["shadowgreen_lower"] = {
      { 0.3592, 0.4852, 2643, 1}, -- Shadowgreen
   },
   ["thescraps_base"] = {
      { 0.2866, 0.5739, 2644, 1}, -- The Scraps
   },
   ["labyrinthian_base"] = { -- Labyrinthian
      { 0.8182, 0.6971, 2717, 1}, -- Blackmaw
      { 0.8411, 0.2733, 2717, 2}, -- Tulnir
   },
   ["labyrinthianb_base"] = { -- Labyrinthian Temple
   	  { 0.1398, 0.5149, 2714, 1}, -- Labyrinthian Group Event
      { 0.4017, 0.5902, 2717, 3}, -- Gralthum the Tormented
      { 0.6934, 0.4034, 2717, 4}, -- Andumgar
	  { 0.8342, 0.5666, 2717, 5}, -- Hjarnnir and Sleeraak
   },
   ["nchuthnkarst_base"] = { -- Nchuthnkarst
   	  { 0.7754, 0.5131, 2715, 1}, -- Nchuthnkarst Group Event
   	  { 0.0994, 0.5589, 2718, 1}, -- Dwarf-light the Destroyer
      { 0.3784, 0.1132, 2718, 2}, -- Imperfect Iteration
      { 0.6147, 0.2491, 2718, 3}, -- Shahmar
	  { 0.6268, 0.4190, 2718, 4}, -- Brsssp the Behemoth
	  { 0.3436, 0.4805, 2718, 5}, -- Krodunth the Mantikora
   },
}

DungeonChampionsData["reach"] = { -- The Reach
   ["gloomreach_base"] = {
      { 0.2932, 0.5010, 2852, 1}, -- Gloomreach
   },
   ["gloomreach2_base"] = {
      { 0.2932, 0.5010, 2852, 1}, -- Gloomreach
   },
   ["gloomreach2b_base"] = {
      { 0.2932, 0.5010, 2852, 1}, -- Gloomreach
   },
   ["gloomreach2c_base"] = {
      { 0.2932, 0.5010, 2852, 1}, -- Gloomreach
   },
   ["gloomreach4_base"] = {
      { 0.2932, 0.5010, 2852, 1}, -- Gloomreach
   },
   ["gloomreach5_base"] = {
      { 0.2932, 0.5010, 2852, 1}, -- Gloomreach
   },
   ["briarrockruins_ext"] = {
      { 0.1231, 0.5768, 2853, 1}, -- Briar Rock Ruins
   },
}

DungeonChampionsData["blackwood"] = { -- Blackwood
   ["u30_undertowcavern"] = {
      { 0.5031, 0.1590, 2965, 1}, -- Undertow Cavern
   },
   ["u30_xanmeeroverlook"] = {
      { 0.5169, 0.4595, 2966, 1}, -- Xi-Tsei
   },
   ["vaultdelve_int03"] = {
      { 0.3393, 0.6577, 2967, 1}, -- Doomvault Porcixid
   },
   ["arpeniah_base"] = {
      { 0.1660, 0.3811, 2968, 1}, -- Arpenia
   },
   ["arpeniah1_base"] = {
      { 0.1660, 0.3811, 2968, 1}, -- Arpenia
   },
   ["arpeniah2_base"] = {
      { 0.1660, 0.3811, 2968, 1}, -- Arpenia
   },
   ["arpeniah3_base"] = {
      { 0.1660, 0.3811, 2968, 1}, -- Arpenia
   },
   ["u30_bloodruncave"] = {
      { 0.2905, 0.6477, 2969, 1}, -- Bloodrun Cave
   },
   ["vunalk1_base"] = {
      { 0.2884, 0.4247, 2970, 1}, -- Vunalk
   },
   ["vunalk2_base"] = {
      { 0.2884, 0.4247, 2970, 1}, -- Vunalk
   },
   ["zhgroupevent_base"] = {-- Zenithar's Abbey
      { 0.6133, 0.5190, 2995, 1}, -- Ra'back the Trap Master Group Event
   },
   ["zhmain_base"] = { -- Zenithar's Abbey
   	  { 0.3567, 0.4692, 2997, 1}, -- Grapnur the Crusher and Burthar Meatwise
      { 0.2021, 0.7177, 2997, 2}, -- The Frigid Temptress
      { 0.3885, 0.1755, 2997, 3}, -- Gloom-Tooth
	  { 0.5547, 0.4798, 2997, 4}, -- Arbitrator Tasellis
	  { 0.8656, 0.5438, 2997, 5}, -- Fulciinius the Bone Miser
   },
}

DungeonChampionsDataID[1943] = {  -- Blackwood / The Silent Halls
	{ 0.5929, 0.3299, 2996, 1}, -- Kao'kuul
	{ 0.3310, 0.7107, 2996, 2}, -- Silent Sentry
}

DungeonChampionsDataID[1958] = {  -- Blackwood / The Silent Halls
	{ 0.2623, 0.6136, 2996, 3}, -- Rootwhisperer
	{ 0.5270, 0.1814, 2996, 4}, -- Vor'chul the Beastbreaker
}

DungeonChampionsDataID[1959] = {  -- Blackwood / The Silent Halls
	{ 0.4616, 0.7475, 2996, 5}, -- Dread Irenan
	{ 0.6193, 0.2794, 2994, 1}, -- Warlord Iaza and His Tribe Group Event
}

DungeonChampionsData["systres"] = { -- High Isle
   ["u34_firepotcave"] = {
      { 0.6451, 0.4852, 3275, 1}, -- The Firepot
   },
   ["u34_breakwatercave"] = {
      { 0.0962, 0.6868, 3276, 1}, -- Breakwater Cave
   },
   ["u34_hauntedsepulcherint"] = {
      { 0.3563, 0.4704, 3277, 1}, -- Death's Valor Keep
   },
   ["u34_shipwreckshoalsint"] = {
      { 0.2982, 0.8195, 3278, 1}, -- Shipwreck Shoals
   },
   ["u34_whalefall"] = {
      { 0.4184, 0.3158, 3279, 1}, -- Whalefall
   },
   ["u34_coralcliffsext"] = {
      { 0.5637, 0.7200, 3280, 1}, -- Coral Cliffs
   },
   ["u34_tots"] = {
      { 0.5338, 0.6625, 3283, 1}, -- Crimson Mother Group Event
   },
   ["u34_ghosthavenext"] = {
      { 0.7720, 0.5043, 3281, 1}, -- Hadolid Broodmother Group Event
	  { 0.6661, 0.8043, 3282, 1}, -- Captain Altair
	  { 0.5659, 0.1721, 3282, 2}, -- Razor Fangs
   },
   ["u34_ghosthaven"] = {
	  { 0.4638, 0.6091, 3282, 3}, -- Captain Tuvacca
	  { 0.3862, 0.4597, 3282, 4}, -- Captain Marley
	  { 0.4859, 0.2542, 3282, 5}, -- Captain Fauvette
   },
}

DungeonChampionsDataID[2171] = {  -- Spire of the Crimson Coin Public Dungeon
      { 0.4499, 0.4840, 3283, 1}, -- Crimson Mother Group Event
	  { 0.3863, 0.6335, 3284, 1}, -- Blighted Carapace
	  { 0.5498, 0.3423, 3284, 2}, -- Anya Mouz the Unclean
	  { 0.6934, 0.6988, 3284, 3}, -- Chillspine
	  { 0.8264, 0.4838, 3284, 4}, -- Crimson Apprentice
	  { 0.6860, 0.2527, 3284, 5}, -- Shambleback
}

function GetAchievementIDs()
   return achievementIDs
end

function DungeonChampions_GetLocalData(zone, subzone, mapid)
	if mapid and DungeonChampionsDataID[mapid] then
		return DungeonChampionsDataID[mapid]
	end
   if type(zone) == "string" and type(subzone) == "string" and DungeonChampionsData[zone] and DungeonChampionsData[zone][subzone] then
      return DungeonChampionsData[zone][subzone]
   end
end