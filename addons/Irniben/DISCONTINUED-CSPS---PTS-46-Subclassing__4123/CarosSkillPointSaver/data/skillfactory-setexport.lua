local function table_invert(t)
   local s={}
   for k,v in pairs(t) do
     s[v]=k
   end
   return s
end


local sfSetIds = {
	[19] = 77, --Vestments of the Warlock
	[20] = 51, --Witchman Armor
	[21] = 34, --Akaviri Dragonguard
	[22] = 14, --Dreamer's Mantle
	[23] = 97, --Archer's Mind
	[24] = 98, --Footman's Fortune
	[25] = 99, --Desert Rose
	[26] = 59, --Prisoner's Rags
	[27] = 33, --Fiord's Legacy
	[28] = 61, --Barkskin
	[29] = 69, --Sergeant's Mail
	[30] = 46, --Thunderbug's Carapace
	[31] = 8, --Silks of the Sun
	[32] = 100, --Healer's Habit
	[33] = 49, --Viper's Sting
	[34] = 16, --Night Mother's Embrace
	[35] = 83, --Knightmare
	[36] = 7, --Armor of the Veiled Heritance
	[37] = 101, --Death's Wind
	[38] = 102, --Twilight's Embrace
	[39] = 103, --Alessian Order
	[40] = 104, --Night's Silence
	[41] = 105, --Whitestrake's Retribution
	[43] = 106, --Armor of the Seducer
	[44] = 107, --Vampire's Kiss
	[46] = 72, --Noble Duelist's Silks
	[47] = 30, --Robes of the Withered Hand
	[48] = 108, --Magnus' Gift
	[49] = 1, --Shadow of the Red Mountain
	[50] = 109, --The Morag Tong
	[51] = 110, --Night Mother's Gaze
	[52] = 111, --Beckoning Steel
	[53] = 88, --The Ice Furnace
	[54] = 112, --Ashen Grip
	[55] = 39, --Prayer Shawl
	[56] = 36, --Stendarr's Embrace
	[57] = 10, --Syrabane's Grip
	[58] = 5, --Hide of the Werewolf
	[59] = 113, --Kyne's Kiss
	[60] = 25, --Darkstride
	[61] = 2, --Dreugh King Slayer
	[62] = 26, --Hatchling's Shell
	[63] = 114, --The Juggernaut
	[64] = 45, --Shadow Dancer's Raiment
	[65] = 4, --Bloodthorn's Touch
	[66] = 27, --Robes of the Hist
	[67] = 115, --Shadow Walker
	[68] = 44, --Stygian
	[69] = 9, --Ranger's Gait
	[70] = 57, --Seventh Legion Brute
	[71] = 75, --Durok's Bane
	[72] = 73, --Nikulas' Heavy Armor
	[73] = 116, --Oblivion's Foe
	[74] = 117, --Spectre's Eye
	[75] = 118, --Torug's Pact
	[76] = 119, --Robes of Alteration Mastery
	[77] = 87, --Crusader
	[78] = 120, --Hist Bark
	[79] = 121, --Willow's Path
	[80] = 122, --Hunding's Rage
	[81] = 123, --Song of Lamae
	[82] = 124, --Alessia's Bulwark
	[83] = 125, --Elf Bane
	[84] = 126, --Orgnum's Scales
	[85] = 127, --Almalexia's Mercy
	[86] = 32, --Queen's Elegance
	[87] = 128, --Eyes of Mara
	[88] = 129, --Robes of Destruction Mastery
	[89] = 130, --Sentry
	[90] = 41, --Senche's Bite
	[91] = 131, --Oblivion's Edge
	[92] = 132, --Kagrenac's Hope
	[93] = 12, --Storm Knight's Plate
	[94] = 60, --Meridia's Blessed Armor
	[95] = 96, --Shalidor's Curse
	[96] = 37, --Armor of Truth
	[97] = 133, --The Arch-Mage
	[98] = 23, --Necropotence
	[99] = 53, --Salvation
	[100] = 134, --Hawk's Eye
	[101] = 135, --Affliction
	[102] = 92, --Duneripper's Scales
	[103] = 89, --Magicka Furnace
	[104] = 136, --Curse Eater
	[105] = 15, --Twin Sisters
	[106] = 42, --Wilderqueen's Arch
	[107] = 3, --Wyrd Tree's Blessing
	[108] = 137, --Ravager
	[109] = 138, --Light of Cyrodiil
	[110] = 38, --Sanctuary
	[111] = 139, --Ward of Cyrodiil
	[112] = 13, --Night Terror
	[113] = 140, --Crest of Cyrodiil
	[114] = 47, --Soulshine
	[122] = 65, --Ebon Armory
	[123] = 78, --Hircine's Veneer
	[124] = 95, --The Worm's Raiment
	[125] = 144, --Wrath of the Imperium
	[126] = 145, --Grace of the Ancients
	[127] = 146, --Deadly Strike
	[128] = 147, --Blessing of the Potentates
	[129] = 148, --Vengeance Leech
	[130] = 152, --Eagle Eye
	[131] = 151, --Bastion of the Heartland
	[132] = 149, --Shield of the Valiant
	[133] = 150, --Buffer of the Swift
	[134] = 66, --Shroud of the Lich
	[135] = 50, --Draugr's Heritage
	[136] = 154, --Immortal Warrior
	[137] = 155, --Berserking Warrior
	[138] = 156, --Defending Warrior
	[139] = 157, --Wise Mage
	[140] = 158, --Destructive Mage
	[141] = 159, --Healing Mage
	[142] = 160, --Quick Serpent
	[143] = 161, --Poisonous Serpent
	[144] = 162, --Twice-Fanged Serpent
	[145] = 163, --Way of Fire
	[146] = 164, --Way of Air
	[147] = 165, --Way of Martial Knowledge
	[148] = 153, --Way of the Arena
	[155] = 67, --Undaunted Bastion
	[156] = 80, --Undaunted Infiltrator
	[157] = 71, --Undaunted Unweaver
	[158] = 20, --Embershield
	[159] = 19, --Sunderflame
	[160] = 79, --Burning Spellweave
	[161] = 177, --Twice-Born Star
	[162] = 178, --Spawn of Mephala
	[163] = 179, --Bloodspawn
	[164] = 180, --Lord Warden
	[165] = 181, --Scourge Harvester
	[166] = 182, --Engine Guardian
	[167] = 183, --Nightflame
	[168] = 184, --Nerien'eth
	[169] = 185, --Valkyn Skoria
	[170] = 186, --Maw of the Infernal
	[171] = 187, --Eternal Warrior
	[172] = 189, --Infallible Mage
	[173] = 188, --Vicious Serpent
	[176] = 190, --Noble's Conquest
	[177] = 191, --Redistributor
	[178] = 192, --Armor Master
	[179] = 201, --Black Rose
	[180] = 205, --Powerful Assault
	[181] = 207, --Meritorious Service
	[183] = 200, --Molag Kena
	[184] = 194, --Brands of Imperium
	[185] = 196, --Spell Power Cure
	[186] = 90, --Jolting Arms
	[187] = 28, --Swamp Raider
	[188] = 93, --Storm Master
	[190] = 199, --Scathing Mage
	[193] = 91, --Overwhelming Surge
	[194] = 68, --Combat Physician
	[195] = 198, --Sheer Venom
	[196] = 197, --Leeching Plate
	[197] = 81, --Tormentor
	[198] = 195, --Essence Thief
	[199] = 211, --Shield Breaker
	[200] = 213, --Phoenix
	[201] = 215, --Reactive Armor
	[204] = 175, --Endurance
	[205] = 193, --Willpower
	[206] = 216, --Agility
	[207] = 271, --Law of Julianos
	[208] = 218, --Trial by Fire
	[210] = 206, --Mark of the Pariah
	[211] = 212, --Permafrost
	[212] = 203, --Briarheart
	[213] = 209, --Glorious Defender
	[214] = 208, --Para Bellum
	[215] = 210, --Elemental Succession
	[216] = 214, --Hunt Leader
	[217] = 204, --Winterborn
	[218] = 202, --Trinimac's Valor
	[219] = 219, --Morkuldin
	[224] = 226, --Tava's Favor
	[225] = 227, --Clever Alchemist
	[226] = 228, --Eternal Hunt
	[227] = 229, --Bahraha's Curse
	[228] = 230, --Syvarra's Scales
	[229] = 232, --Twilight Remedy
	[230] = 231, --Moondancer
	[231] = 234, --Lunar Bastion
	[232] = 233, --Roar of Alkosh
	[234] = 235, --Marksman's Crest
	[235] = 240, --Robes of Transmutation
	[236] = 239, --Vicious Death
	[237] = 236, --Leki's Focus
	[238] = 237, --Fasalla's Guile
	[239] = 238, --Warrior's Fury
	[240] = 241, --Kvatch Gladiator
	[241] = 242, --Varen's Legacy
	[242] = 243, --Pelinal's Aptitude
	[243] = 244, --Hide of Morihaus
	[244] = 245, --Flanking Strategist
	[245] = 246, --Sithis' Touch
	[246] = 247, --Galerion's Revenge
	[247] = 248, --Vicecanon of Venom
	[248] = 249, --Thews of the Harbinger
	[253] = 250, --Imperial Physique
	[256] = 252, --Mighty Chudan
	[257] = 251, --Velidreth
	[258] = 254, --Amber Plasm
	[259] = 255, --Heem-Jas' Retribution
	[260] = 253, --Aspect of Mazzatun
	[261] = 257, --Gossamer
	[262] = 258, --Widowmaker
	[263] = 256, --Hand of Mephala
	[265] = 260, --Shadowrend
	[266] = 261, --Kra'gh
	[267] = 262, --Swarm Mother
	[268] = 263, --Sentinel of Rkugamz
	[269] = 264, --Chokethorn
	[270] = 265, --Slimecraw
	[271] = 266, --Sellistrix
	[272] = 267, --Infernal Guardian
	[273] = 268, --Ilambris
	[274] = 269, --Iceheart
	[275] = 270, --Stormfist
	[276] = 271, --Tremorscale
	[277] = 272, --Pirate Skeleton
	[278] = 273, --The Troll King
	[279] = 274, --Selene
	[280] = 275, --Grothdarr
	[281] = 6, --Armor of the Trainee
	[282] = 24, --Vampire Cloak
	[283] = 29, --Sword-Singer
	[284] = 31, --Order of Diagna
	[285] = 56, --Vampire Lord
	[286] = 55, --Spriggan's Thorns
	[287] = 11, --Green Pact
	[288] = 43, --Beekeeper's Gear
	[289] = 52, --Spinner's Garments
	[290] = 48, --Skooma Smuggler
	[291] = 22, --Shalk Exoskeleton
	[292] = 18, --Mother's Sorrow
	[293] = 17, --Plague Doctor
	[294] = 40, --Ysgramor's Birthright
	[295] = 84, --Jailbreaker
	[296] = 85, --Spelunker
	[297] = 82, --Spider Cultist Cowl
	[298] = 54, --Light Speaker
	[299] = 35, --Toothrow
	[300] = 58, --Netch's Touch
	[301] = 21, --Strength of the Automaton
	[302] = 62, --Leviathan
	[303] = 64, --Lamia's Song
	[304] = 63, --Medusa
	[305] = 86, --Treasure Hunter
	[307] = 94, --Draugr Hulk
	[308] = 70, --Bone Pirate's Tatters
	[309] = 76, --Knight-errant's Mail
	[310] = 74, --Sword Dancer
	[311] = 141, --Rattlecage
	[313] = 170, --Titanic Cleave
	[314] = 171, --Puncturing Remedy
	[315] = 176, --Stinging Slashes
	[316] = 172, --Caustic Arrow
	[317] = 173, --Destructive Impact
	[318] = 174, --Grand Rejuvenation
	[320] = 280, --War Maiden
	[321] = 281, --Defiler
	[322] = 279, --Warrior-Poet
	[323] = 276, --Assassin's Guile
	[324] = 277, --Daedric Trickery
	[325] = 278, --Shacklebreaker
	[326] = 282, --Vanguard's Challenge
	[327] = 283, --Coward's Gear
	[328] = 284, --Knight Slayer
	[329] = 285, --Wizard's Riposte
	[330] = 286, --Automated Defense
	[331] = 287, --War Machine
	[332] = 288, --Master Architect
	[333] = 289, --Inventor's Guard
	[334] = 290, --Impregnable Armor
	[335] = 292, --Draugr's Rest
	[336] = 293, --Pillar of Nirn
	[337] = 291, --Ironblood
	[338] = 296, --Flame Blossom
	[339] = 297, --Blooddrinker
	[340] = 295, --Hagraven's Garden
	[341] = 294, --Earthgore
	[342] = 298, --Domihaus
	[343] = 300, --Caluurion's Legacy
	[344] = 301, --Trappings of Invigoration
	[345] = 299, --Ulfnor's Favor
	[346] = 303, --Jorvuld's Guidance
	[347] = 304, --Plague Slinger
	[348] = 302, --Curse of Doylemish
	[349] = 305, --Thurvokun
	[350] = 306, --Zaan
	[351] = 307, --Innate Axiom
	[352] = 308, --Fortified Brass
	[353] = 309, --Mechanical Acuity
	[354] = 311, --Mad Tinkerer
	[355] = 312, --Unfathomable Darkness
	[356] = 310, --Livewire
	[357] = 315, --Perfected Disciplined Slash
	[358] = 313, --Perfected Defensive Position
	[359] = 314, --Perfected Chaotic Whirlwind
	[360] = 316, --Perfected Piercing Spray
	[361] = 317, --Perfected Concentrated Force
	[362] = 318, --Perfected Timeless Blessing
	[363] = 321, --Disciplined Slash
	[364] = 319, --Defensive Position
	[365] = 320, --Chaotic Whirlwind
	[366] = 322, --Piercing Spray
	[367] = 323, --Concentrated Force
	[368] = 324, --Timeless Blessing
	[369] = 222, --Merciless Charge
	[370] = 221, --Rampaging Slash
	[371] = 220, --Cruel Flurry
	[372] = 223, --Thunderous Volley
	[373] = 224, --Crushing Wall
	[374] = 2563, --Precise Regeneration
	[382] = 325, --Grace of Gloom
	[383] = 327, --Gryphon's Ferocity
	[384] = 326, --Wisdom of Vanus
	[385] = 330, --Adept Rider
	[386] = 331, --Sload's Semblance
	[387] = 332, --Nocturnal's Favor
	[388] = 333, --Aegis of Galenwe
	[389] = 334, --Arms of Relequen
	[390] = 335, --Mantle of Siroria
	[391] = 336, --Vestment of Olorime
	[392] = 338, --Perfected Aegis of Galenwe
	[393] = 339, --Perfected Arms of Relequen
	[394] = 340, --Perfected Mantle of Siroria
	[395] = 341, --Perfected Vestment of Olorime
	[397] = 348, --Balorgh
	[398] = 349, --Vykosa
	[399] = 343, --Hanu's Compassion
	[400] = 344, --Blood Moon
	[401] = 342, --Haven of Ursus
	[402] = 346, --Moon Hunter
	[403] = 347, --Savage Werewolf
	[404] = 345, --Jailer's Tenacity
	[405] = 352, --Bright-Throat's Boast
	[406] = 351, --Dead-Water's Guile
	[407] = 350, --Champion of the Hist
	[408] = 353, --Grave-Stake Collector
	[409] = 354, --Naga Shaman
	[410] = 355, --Might of the Lost Legion
	[411] = 362, --Gallant Charge
	[412] = 364, --Radial Uppercut
	[413] = 363, --Spectral Cloak
	[414] = 365, --Virulent Shot
	[415] = 366, --Wild Impulse
	[416] = 367, --Mender's Ward
	[417] = 356, --Indomitable Fury
	[418] = 357, --Spell Strategist
	[419] = 358, --Battlefield Acrobat
	[420] = 359, --Soldier of Anguish
	[421] = 360, --Steadfast Hero
	[422] = 361, --Battalion Defender
	[423] = 368, --Perfected Gallant Charge
	[424] = 370, --Perfected Radial Uppercut
	[425] = 369, --Perfected Spectral Cloak
	[426] = 371, --Perfected Virulent Shot
	[427] = 372, --Perfected Wild Impulse
	[428] = 373, --Perfected Mender's Ward
	[429] = 374, --Mighty Glacier
	[430] = 375, --Tzogvin's Warband
	[431] = 376, --Icy Conjuror
	[432] = 377, --Stonekeeper
	[433] = 378, --Frozen Watcher
	[434] = 379, --Scavenging Demise
	[435] = 380, --Auroran's Thunder
	[436] = 381, --Symphony of Blades
	[437] = 382, --Coldharbour's Favorite
	[438] = 383, --Senche-raht's Grit
	[439] = 384, --Vastarie's Tutelage
	[440] = 386, --Crafty Alfiq
	[441] = 387, --Vesture of Darloc Brae
	[442] = 385, --Call of the Undertaker
	[443] = 391, --Eye of Nahviintaas
	[444] = 390, --False God's Devotion
	[445] = 389, --Tooth of Lokkestiiz
	[446] = 388, --Claw of Yolnahkriin
	[448] = 395, --Perfected Eye of Nahviintaas
	[449] = 394, --Perfected False God's Devotion
	[450] = 393, --Perfected Tooth of Lokkestiiz
	[451] = 392, --Perfected Claw of Yolnahkriin
	[452] = 399, --Hollowfang Thirst
	[453] = 400, --Dro'Zakar's Claws
	[454] = 398, --Renald's Resolve
	[455] = 402, --Z'en's Redress
	[456] = 403, --Azureblight Reaper
	[457] = 401, --Dragon's Defilement
	[458] = 396, --Grundwulf
	[459] = 397, --Maarselok
	[465] = 407, --Senchal Defender
	[466] = 406, --Marauder's Haste
	[467] = 405, --Dragonguard Elite
	[468] = 408, --Daring Corsair
	[469] = 404, --Ancient Dragonguard
	[470] = 409, --New Moon Acolyte
	[471] = 410, --Hiti's Hearth
	[472] = 411, --Titanborn Strength
	[473] = 412, --Bani's Torment
	[474] = 413, --Draugrkin's Grip
	[475] = 414, --Aegis Caller
	[476] = 415, --Grave Guardian
	[478] = 416, --Mother Ciannait
	[479] = 417, --Kjalnar's Nightmare
	[480] = 418, --Critical Riposte
	[481] = 419, --Unchained Aggressor
	[482] = 420, --Dauntless Combatant
	[487] = 2523, --Winter's Respite
	[488] = 2521, --Venomous Smite
	[489] = 2522, --Eternal Vigor
	[490] = 2529, --Stuhn's Favor
	[491] = 2530, --Dragon's Appetite
	[492] = 2534, --Kyne's Wind
	[493] = 2538, --Perfected Kyne's Wind
	[494] = 2533, --Vrol's Command
	[495] = 2537, --Perfected Vrol's Command
	[496] = 2531, --Roaring Opportunist
	[497] = 2535, --Perfected Roaring Opportunist
	[498] = 2532, --Yandir's Might
	[499] = 2536, --Perfected Yandir's Might
	[501] = 2547, --Thrassian Stranglers
	[503] = 2540, --Ring of the Wild Hunt
	[505] = 2542, --Torc of Tonal Constancy
	[506] = 254, --Spell Parasite
	[513] = 7167, --Talfyg's Treachery
	[514] = 7168, --Unleashed Terror
	[515] = 7169, --Crimson Twilight
	[516] = 7170, --Elemental Catalyst
	[517] = 7171, --Kraglen's Howl
	[518] = 7172, --Arkasis's Genius
	[519] = 2549, --Snow Treaders
	[520] = 2550, --Malacath's Band of Brutality
	[521] = 2551, --Bloodlord's Embrace
	[522] = 2560, --Perfected Merciless Charge
	[523] = 2558, --Perfected Rampaging Slash
	[524] = 2559, --Perfected Cruel Flurry
	[525] = 2561, --Perfected Thunderous Volley
	[526] = 2562, --Perfected Crushing Wall
	[527] = 2563, --Perfected Precise Regeneration
	[528] = 2554, --Perfected Titanic Cleave
	[529] = 2552, --Perfected Puncturing Remedy
	[530] = 2553, --Perfected Stinging Slashes
	[531] = 2555, --Perfected Caustic Arrow
	[532] = 2556, --Perfected Destructive Impact
	[533] = 2557, --Perfected Grand Rejuvenation
	[534] = 7188, --Stone Husk
	[535] = 7189, --Lady Thorn
	[536] = 7190, --Radiant Bastion
	[537] = 7191, --Voidcaller
	[538] = 7192, --Witch-Knight's Defiance
	[539] = 7193, --Red Eagle's Fury
	[540] = 7194, --Legacy of Karth
	[541] = 7195, --Aetherial Ascension
	[542] = 7196, --Hex Siphon
	[543] = 7197, --Pestilent Host
	[544] = 7198, --Explosive Rebuke
	[557] = 7199, --Executioner's Blade
	[558] = 7200, --Void Bash
	[559] = 7201, --Frenzied Momentum
	[560] = 7202, --Point-Blank Snipe
	[561] = 7203, --Wrath of Elements
	[562] = 7204, --Force Overflow
	[563] = 7205, --Perfected Executioner's Blade
	[564] = 7206, --Perfected Void Bash
	[565] = 7207, --Perfected Frenzied Momentum
	[566] = 7208, --Perfected Point-Blank Snipe
	[567] = 7209, --Perfected Wrath of Elements
	[568] = 7210, --Perfected Force Overflow
	[569] = 8892, --True-Sworn Fury
	[570] = 8893, --Kinras's Wrath
	[571] = 8894, --Drake's Rush
	[572] = 8895, --Unleashed Ritualist
	[573] = 8896, --Dagon's Dominion
	[574] = 8897, --Foolkiller's Ward
	[575] = 7211, --Ring of the Pale Order
	[576] = 7166, --Pearls of Ehlnofey
	[577] = 8900, --Encratis's Behemoth
	[578] = 8901, --Baron Zaudrus
	[579] = 8902, --Frostbite
	[580] = 8903, --Deadlands Assassin
	[581] = 8904, --Bog Raider
	[582] = 8905, --Hist Whisperer
	[583] = 8906, --Heartland Conqueror
	[584] = 8907, --Diamond's Victory
	[585] = 8908, --Saxhleel Champion
	[586] = 8909, --Sul-Xan's Torment
	[587] = 8910, --Bahsei's Mania
	[588] = 8911, --Stone-Talker's Oath
	[589] = 8912, --Perfected Saxhleel Champion
	[590] = 8913, --Perfected Sul-Xan's Torment
	[591] = 8914, --Perfected Bahsei's Mania
	[592] = 8915, --Perfected Stone-Talker's Oath
	[593] = 8916, --Gaze of Sithis
	[594] = 8917, --Harpooner's Wading Kilt

	[596] = 8918, --Death Dealer's Fete
	[597] = 8919, --Shapeshifter's Chain
	[598] = 8920, --Zoal the Ever-Wakeful
	[599] = 8921, --Immolator Charr
	[600] = 8922, --Glorgoloch the Destroyer
	
	[602] = 9943, --Crimson Oath's Rive 
	[603] = 9944, --Scorion's Feast
	[604] = 9945, --Rush of Agony 
	[605] = 9946, --Silver Rose Vigil 
	[606] = 9947, --Thunder Caller 
	[607] = 9948, --Grisly Gourmet 
	[608] = 9949, --Prior Thierric 
	[609] = 9950, --Magma Incarnate
	[610] = 12035, --Wretched Vitality 
	[611] = 12036, --Deadlands Demolisher
	[612] = 12037, --Iron Flask 
	[613] = 12038, --Eye of the Grasp 
	[614] = 12039, --Hexos' Ward 
	[615] = 12040, --Kynmarcher's Cruelty 
	[616] = 9951, --Dark Convergence 
	[617] = 9952, --Plaguebreak 
	[618] = 9953, --Hrothgar's Chill 
	[619] = 12574, --Maligalig\'s Maelstrom 
	[620] = 12575, --Gryphon\'s Reprisal 
	[621] = 12576, --Glacial Guardian 
	[622] = 12577, --Turning Tide 
	[623] = 12578, --Storm-Curseds Revenge 
	[624] = 12579, --Spriggans Vigor
	[625] = 12044, --Markyn Ring of Majesty 
	[626] = 12045, --Belharzas Band 
	[627] = 12046, --Spaulder of Ruin
	
	[629] = 12583,--Rallying Cry 
	[630] = 12584, --Hew and Sunder 
	[631] = 12585, --Enervating Aura  
	[632] = 12586,--Kargaeda
	[633] = 12587, --Nazaray  
	[634] = 12588,--Nunatak
	[635] = 12589,--Lady Malydga
	[636] = 12590,--Baron Thirsk
	
	[640] = 13570, --Orders Wrath 
	[641] = 13697, --Serpents Disdain
	[642] = 13696, --Druids Braid 
	[643] = 13695, --Blessing of High Isle 
	[644] = 13686, --Steadfasts Mettle
	[645] = 13659, --Systres Scowl 
	[646] = 13653, --Whorl of the Depths 
	[647] = 13614, --Coral Riptide
	[648] = 13613, --Pearlescent Ward 
	[649] = 13612, --Pillagers Profit 
	[650] = 13611, --Perfected Pillagers Profit 
	[651] = 13610, --Perfected Pearlescent Ward
	[652] = 13609, --Perfected Coral Riptide 
	[653] = 13608, --Perfected Whorl of the Depths 
	[654] = 13607, --Moras Whispers
	[655] = 13606, --Dov-rha Sabatons 
	[656] = 13605, --Lefthanders War Girdle 
	[657] = 13604, --Sea-Serpents Coil 
	[658] = 13603, --Oakensoul Ring 
		
	[660] = 14824, --Deeproot Zeal
	[661] = 14825, --Stones Accord 
	[662] = 14826, --Rage of the Ursauk 
	[663] = 14827, --Pangrit Denmother 
	[664] = 14828, --Grave Inevitability
	[665] = 14829, --Phylacterys Grasp 
	[666] = 14830, --Archdruid Devyric 
	[667] = 14831, --Euphotic Gatekeeper 
	[668] = 14832, --Langour of Peryite 
	[669] = 14833, --Nocturnals Ploy 
	[670] = 14834, --Maras Balm 

	[671] = 15409, --Back-Alley Gourmand 
	[672] = 15410, --Phoenix Moth Theurge
	[673] = 15411, --Bastion of Draoife 
	[674] = 15412, --Faun's Lark Cladding 
	[675] = 15413, --Stormweaver's Cavort 
	[676] = 15414, --Syrabane's Ward 
	[677] = 15415, --Chimera's Rebuke 
	[678] = 15416, --Old Growth Brewer 
	[679] = 15417, --Claw of the Forest Wraith
	[680] = 16001, --Ritemaster's Bond 
	[681] = 16002, --Nix-Hound's Howl 
	[682] = 16003, --Telvanni Enforcer 
	[683] = 16004, --Roksa the Warped 
	[684] = 16005, --Runecarver's Blaze 
	[685] = 16006, --Apocryphal Inspiration 
	[686] = 16007, --Abyssal Brace 
	[687] = 16008, --Ozezan the Inferno
	[688] = 16009, --Snake in the Stars
	[689] = 16010, --Shell Splitter 
	[690] = 16011, --Judgement of Akatosh
	[691] = 16606, -- Cryptcanon Vestments
	[692] = 16607, -- Esoteric Environment Greaves
	[694] = 16608, -- Velothi Ur-Mage's Amulet
	[698] = 16612, -- Vivec's Duality
	[699] = 16613, -- Camonna Tong
	[700] = 16614, -- Adamant Lurker
	[701] = 16615, -- Peace and Serenity
	[702] = 16616, -- Ansuul's Torment
	[703] = 16617, -- Test of Resolve
	[704] = 16618, -- Transformative Hope
	[705] = 16619, -- Perfected Transformative Hope
	[706] = 16620, -- Perfected Test of Resolve
	[707] = 16621, -- Perfected Ansuul's Torment
	[708] = 16622, -- Perfected Peace and Serenity
	[711] = 17847, --Jerall Mountains Warchief
	[712] = 17848, --Nibenay Bay Battlereeve /
	[713] = 17849, --Colovian Highlands General
	[722] = 17850, --Reawakened Hierophant /
	[723] = 17851, --Basalt-Blooded Warrior 
	[724] = 17852, --Nobility in Decay  
	[726] = 17853, --Soulcleaver  
	[727] = 17854, --Monolith of Storms 
	[728] = 17855, --Wrathsun
	[729] = 17856, --Gardener of Seasons 
	[730] = 19721, -- Cinders of Anthelmir
	[731] = 19722, -- Sluthrug's Hunger
	[732] = 19723, -- Black-Glove Grounding
	[734] = 19724, -- Anthelmir's Construct
	[735] = 19725, -- Blind Path Induction
	[736] = 19726, -- Tarnished Nightmare
	[737] = 19727, -- Reflected Fury
	[738] = 19728, -- The Blind
	[754] = 19729, -- Oakfather's Retribution
	[755] = 19730, -- Blunted Blades
	[756] = 19731, -- Baan Dar's Blessing
	[757] = 20365, -- Symmetry of the Weald
	[758] = 20366, -- Macabre Vintage
	[759] = 20367, -- Ayleid Refuge
	[760] = 20368, -- Rourken Steamguards	
	[761] = 20369, -- The Shadow Queen's Cowl
	[762] = 20370, -- The Saint and the Seducer
	[766] = 20374, -- Mora Scribe's Thesis
	[767] = 20375, -- Slivers of the Null Arca
	[768] = 20376, -- Lucent Echoes	
	[769] = 20377, -- Xoryn's Masterpiece
	[770] = 20378, -- Perfected Xoryn's Masterpiece
	[771] = 20379, -- Perfected Lucent Echoes
	[772] = 20380, -- Perfected Slivers of the Null Arca
	[773] = 20381, -- Perfected Mora Scribe's Thesis	
	[775] = 20382, -- Spattering Disjunction
	[776] = 20383, -- Pyrebrand
	[777] = 20384, -- Corpseburster
	[778] = 20385, -- Umbral Edge
	[779] = 20386, -- Beacon of Oblivion
	[780] = 20387, -- Aetheric Lancer
	[781] = 20388, -- Aerie's Cry	
	[782] = 21046, -- Tracker's Lash
	[783] = 21047, -- Shared Pain
	[784] = 21048, -- Siegemaster's Focus
	[791] = 21049, -- Bulwark Ruination
	[792] = 21050, -- Farstrider
	[793] = 21051, -- Netch Oil
	[794] = 21715, -- Vandorallen's Resonance
	[795] = 21716, -- Jerensi's Bladestorm
	[796] = 21717, -- Lucilla's Windshield
	[797] = 21718, -- Squall of Retribution
	[798] = 21719, -- Heroic Unity
	[799] = 21720, -- Fledgling's Nest
	[800] = 21721, -- Noxious Boulder
	[801] = 21722, -- Orpheon the Tactician
	[802] = 21723, -- Arkay's Charity
	[803] = 21724, -- Lamp Knight's Art
	[804] = 21725, -- Blackfeather Flight
	
	-- /script SetCVar("language.2", "en")
} -- /script xyz = GetNextItemSetCollectionId(xyz) StartChatInput("["..xyz.."] = 0, -- "..GetItemSetName(xyz))

local sfTraits = {
		-- Armor traits
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 17,
	--[ITEM_TRAIT_TYPE_ARMOR_EXPLORATION] = 0,
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 11,
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 15,
	--[ITEM_TRAIT_TYPE_ARMOR_INTRICATE] = 0,
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 18,
	--[ITEM_TRAIT_TYPE_ARMOR_ORNATE] = 0,
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = 16,
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 12,
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] = 10,
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 14,
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 13,

	-- Jewlry traits
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = 19,
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 27,
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = 26,
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = 20,
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = 23,
	--[ITEM_TRAIT_TYPE_JEWELRY_INTRICATE] = 0,
	--[ITEM_TRAIT_TYPE_JEWELRY_ORNATE] = 0,
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = 24,
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = 21,
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = 25,
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = 22,

	-- Weapon traits
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 2,
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 8,
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 5,
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 4,
	--[ITEM_TRAIT_TYPE_WEAPON_INTRICATE] = 0,
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 9,
	--[ITEM_TRAIT_TYPE_WEAPON_ORNATE] = 0,
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] = 1,
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 3,
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 7,
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 6,
	--[ITEM_TRAIT_TYPE_WEAPON_WEIGHTED] = 0,
}


local sfEnchants = { --By Enchant Id
	[14] = 37,   -- frost resist
	[15] = 6,  -- frost weapon
	[16] = 11,  -- hardening
	[17] = 1,  -- health
	[18] = 38,   -- health recovery
	[19] = 2,  -- magicka
	[20] = 41,   -- magicka recovery
	[23] = 42,   -- poison resist
	[24] = 8,  -- poison weapon
	[25] = 3,  -- stamina
	[26] = 50,   -- stamina recovery
	[28] = 16,  -- weakening
	[3] = 9,  -- foul weapon
	[6] = 7,  -- shock weapon
	[7] = 17,  -- crushing
	[9] = 35,   -- disease resist
	[10] = 5,  -- flame weapon
	[11] = 36,   -- flame resist
	[31] = 49,   -- shock resist
	[29] = 12,  -- absorb health
	[82] = 14,  -- absorb stamina
	[83] = 13,  -- absorb magicka
	[84] = 10,  -- decrease health
	[86] = 48,   -- reduce spell cost
	[87] = 46,   -- reduce feat cost
	[88] = 31,   -- bashing
	[89] = 32,   -- shielding
	[90] = 43,   -- potion boost
	[91] = 44,   -- potion speed
	[92] = 40,   -- increase physical harm
	[93] = 39,   -- increase magical harm
	[94] = 33,   -- decrease physical harm
	[95] = 34,   -- decrease spell harm
	[4] = 15,  -- weapon damage
	[146] = 4,  -- prismatic defense
	[147] = 18,  -- prismatic onslaught
	[178] = 47,  -- reduce skill cost
	[179] = 45,  -- prismatic recovery
}

local sfArmorType = {
	[ARMORTYPE_HEAVY] = 3,
	[ARMORTYPE_LIGHT] = 1,
	[ARMORTYPE_MEDIUM] = 2,
}

local sfWeaponType = {
	[WEAPONTYPE_AXE] = 1,
	[WEAPONTYPE_HAMMER] = 2,
	[WEAPONTYPE_SWORD] = 3,
	[WEAPONTYPE_DAGGER] = 11,
	[WEAPONTYPE_TWO_HANDED_SWORD] = 4,
	[WEAPONTYPE_TWO_HANDED_AXE] = 5,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = 6,
	[WEAPONTYPE_BOW] = 8,
	[WEAPONTYPE_HEALING_STAFF] = 9,
	[WEAPONTYPE_FIRE_STAFF] = 12,
	[WEAPONTYPE_FROST_STAFF] = 13,
	[WEAPONTYPE_LIGHTNING_STAFF] = 15,
	[WEAPONTYPE_SHIELD] = 14,
}


local sfPoisons = {
	[76826] = 12, --Drain Health Poison IX
	[76827] = 8, --Damage Health Poison IX
	[76828] = 13, --Drain Magicka Poison IX
	[76829] = 9, --Damage Magicka Poison IX
	[76830] = 14, --Drain Stamina Poison IX
	[76831] = 10, --Damage Stamina Poison IX
	[76832] = 35, --Ward-Draining Poison IX
	[76833] = 1, --Breaching Poison IX
	[76834] = 25, --Resolve-Draining Poison IX
	[76835] = 18, --Fracturing Poison IX
	[76836] = 27, --Sorcery-Draining Poison IX
	[76837] = 7, --Cowardice Poison IX
	[76838] = 2, --Brutality-Draining Poison IX
	[76839] = 22, --Maiming Poison IX
	[76840] = 23, --Prophecy-Draining Poison IX
	[76841] = 32, --Uncertainty Poison IX
	[76842] = 26, --Savagery-Draining Poison IX
	[76843] = 15, --Enervating Poison IX
	[76844] = 17, --Escapist's Poison IX
	[76845] = 16, --Entrapping Poison IX
	[76846] = 29, --Stealth-Draining Poison IX
	[76847] = 6, --Conspicuous Poison IX
	[76848] = 28, --Speed-Draining Poison IX
	[76849] = 21, --Hindering Poison IX
	[77593] = 19, --Gradual Health Drain Poison IX
	[77595] = 20, --Gradual Ravage Health Poison IX
	[77597] = 24, --Protection-Reversing Poison IX
	[77599] = 34, --Vulnerability Poison IX
	[77601] = 33, --Vitality-Draining Poison IX
	[77603] = 11, --Defiling Poison IX
	[79690] = 36, --Crown Lethal Poison
	[79691] = 40, --Gold Coast Trapping Poison
	[79692] = 39, --Gold Coast Enfeebling Poison
	[79693] = 38, --Gold Coast Draining Poison
	[79694] = 37, --Gold Coast Debilitating Poison
	[81194] = 3, --Cloudy Damage Health Poison IX
	[81195] = 4, --Cloudy Gradual Ravage Health Poison IX
	[81196] = 5, --Cloudy Hindering Poison IX
	[152151] = 31, --Traumatic Poison IX
	[158309] = 30, --Timidity Poison IX
	[135121] = 36, --Crown Lethal Poison
	[135122] = 40, --Gold Coast Trapping Poison
	[135123] = 38, --Gold Coast Draining Poison
}

local sfSlots = {
	[EQUIP_SLOT_HEAD] = 1,
	[EQUIP_SLOT_SHOULDERS] = 2,
	[EQUIP_SLOT_HAND] = 3,
	[EQUIP_SLOT_CHEST] = 4,
	[EQUIP_SLOT_WAIST] = 5,
	[EQUIP_SLOT_LEGS] = 6,
	[EQUIP_SLOT_FEET] = 7,
	[EQUIP_SLOT_NECK] = 8,
	[EQUIP_SLOT_RING1] = 9,
	[EQUIP_SLOT_RING2] = 10,
	[EQUIP_SLOT_MAIN_HAND] = 11,
	[EQUIP_SLOT_OFF_HAND] = 12,
	[EQUIP_SLOT_BACKUP_MAIN] = 13,
	[EQUIP_SLOT_BACKUP_OFF] = 14,
	[EQUIP_SLOT_POISON] = 15,
	[EQUIP_SLOT_BACKUP_POISON] = 16,
}

function CSPS.GetSetList()
	local mySetList = {}
	for i, v in pairs(sfSetIds) do
		table.insert(mySetList, i)
	end
	return (mySetList)
end

function CSPS.GetSkillFactorySetData(myItem, slotId)
	if not myItem or myItem == "" then return false end
	local mySetData = {"", "", "0", "", ""}
	local myItemId = GetItemLinkItemId(myItem)
	if not myItemId then return false end
	if slotId == EQUIP_SLOT_POISON or slotId == EQUIP_SLOT_BACKUP_POISON then
		return sfPoisons[myItemId] or false
	end
	local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(myItem)
	if not hasSet or not setId or not sfSetIds[setId] then return false end
	mySetData[1] = sfSetIds[setId]
	
	local myWeaponType = GetItemLinkWeaponType(myItem)
	local myArmorType = GetItemLinkArmorType(myItem)
	if myWeaponType and myWeaponType ~= 0 and sfWeaponType[myWeaponType] then mySetData[2] = sfWeaponType[myWeaponType] end
	if myArmorType and myArmorType ~= 0 and sfArmorType[myArmorType] then mySetData[2] = sfArmorType[myArmorType] end
	
	local myQuality = GetItemLinkQuality(myItem)
	if myQuality and myQuality > 0 then mySetData[3] = myQuality end
	
	local myTrait = GetItemLinkTraitInfo(myItem)
	if myTrait and sfTraits[myTrait] then mySetData[4] = sfTraits[myTrait] end
	
	local enchantId = GetItemLinkAppliedEnchantId(myItem)
	if enchantId == 0 then enchantId = GetItemLinkDefaultEnchantId(myItem) end
	if enchantId > 0 and sfEnchants[enchantId] then mySetData[5] = sfEnchants[enchantId] end
	
	return table.concat(mySetData, ":")
end

local GetSkillFactorySetData = CSPS.GetSkillFactorySetData
local function getSFSetData2(myTable, gearSlot)
	if not myTable or type(myTable) ~= "table" then return false end
	local mySetData = {"", "", "0", "", ""}

	if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
		return sfPoisons[myTable.firstId or 0] or false
	end
	
	if not myTable.setId or not sfSetIds[myTable.setId] then d("No SetId: "..gearSlot) return false end
	
	mySetData[1] = sfSetIds[myTable.setId]
	
	if gearSlot == EQUIP_SLOT_MAIN_HAND or gearSlot == EQUIP_SLOT_OFF_HAND or gearSlot == EQUIP_SLOT_BACKUP_MAIN or gearSlot == EQUIP_SLOT_BACKUP_OFF then
		if myTable.type and sfWeaponType[myTable.type] then mySetData[2] = sfWeaponType[myTable.type] end
	elseif gearSlot == EQUIP_SLOT_NECK or gearSlot == EQUIP_SLOT_RING1 or gearSlot == EQUIP_SLOT_RING2 then
		-- no type for jewelry
	else
		if myTable.type and sfArmorType[myTable.type] then mySetData[2] = sfArmorType[myTable.type] end
	end

	if myTable.quality then mySetData[3] = myTable.quality end
	
	if myTable.trait and sfTraits[myTable.trait] then mySetData[4] = sfTraits[myTable.trait] end

	if myTable.enchant and myTable.enchant > 0 and sfEnchants[myTable.enchant] then mySetData[5] = sfEnchants[myTable.enchant] end
	
	return table.concat(mySetData, ":")	
end

function CSPS.BuildSkillFactorySetList()
	local sfSetTable = {}
	if CSPS.doGear then
		local theGear = CSPS.getTheGear()
		for gearSlot, sfSlot in pairs(sfSlots) do
			local myTable = theGear[gearSlot]
			local mySetData = getSFSetData2(myTable, gearSlot)
			if mySetData then table.insert(sfSetTable, string.format("%s:%s", sfSlot, mySetData)) end
		end
	else
		for gearSlot, sfSlot in pairs(sfSlots) do
			local myItem = GetItemLink(BAG_WORN, gearSlot)
			local mySetData = GetSkillFactorySetData(myItem, gearSlot)
			if mySetData then table.insert(sfSetTable, string.format("%s:%s", sfSlot, mySetData)) end
		end
	end
	return table.concat(sfSetTable, ",")
end

function CSPS.ImportSkillFactorySetList(myGearString)
	myGearString = string.gsub(myGearString, "::", ":0:")
	local myGearStringTable = {SplitString(",", myGearString)}
	local myGear = {}
	local sfSlotsInv = table_invert(sfSlots)
	local sfSetIdsInv = table_invert(sfSetIds)
	local sfTraitsInv = table_invert(sfTraits)
	local sfEnchantsInv = table_invert(sfEnchants)
	local sfWeaponTypeInv = table_invert(sfWeaponType)
	local sfArmorTypeInv = table_invert(sfArmorType)
	local sfPoisonsInv = table_invert(sfPoisons)
	local poisonItemLink = "|H0:item:%s:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:%s|h|h"
	
	for _, singleGearString in pairs(myGearStringTable) do
		local itemTable = {SplitString(":", singleGearString)}
		local gearSlot = sfSlotsInv[tonumber(itemTable[1]) or -1] or false
		if gearSlot then
			myGear[gearSlot] = {}
			local myTable = myGear[gearSlot]
			if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
				local firstId = sfPoisonsInv[tonumber(itemTable[2]) or 0] or 0
				local secondIdArray = CSPS.getPoisonIds(firstId)
				local secondId = secondIdArray and secondIdArray[1] or 0
				myTable.firstId = firstId
				myTable.secondId = secondId
				myTable.link = string.format(poisonItemLink, firstId, secondId)
			else
				myTable.setId = sfSetIdsInv[tonumber(itemTable[2]) or 0]
				myTable.quality = tonumber(itemTable[4]) or 0
				myTable.trait = sfTraitsInv[tonumber(itemTable[5]) or 0]
				myTable.enchant = sfEnchantsInv[tonumber(itemTable[6]) or 0]
				if gearSlot == EQUIP_SLOT_MAIN_HAND or gearSlot == EQUIP_SLOT_OFF_HAND or gearSlot == EQUIP_SLOT_BACKUP_MAIN or gearSlot == EQUIP_SLOT_BACKUP_OFF then
					myTable.type = sfWeaponTypeInv[tonumber(itemTable[3]) or 0]
				elseif gearSlot ~= EQUIP_SLOT_NECK and gearSlot ~= EQUIP_SLOT_RING1 and gearSlot ~= EQUIP_SLOT_RING2 then
					myTable.type = sfArmorTypeInv[tonumber(itemTable[3]) or 0]
				end
			end
		end
	end
	CSPS.setTheGear(myGear)
end