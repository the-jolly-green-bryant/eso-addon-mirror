local A = IAHelper

local ANY = 0
local BEGIN = ACTION_RESULT_BEGIN
local EFFECT = ACTION_RESULT_EFFECT_GAINED
local DURATION = ACTION_RESULT_EFFECT_GAINED_DURATION

IA_COLOR_YELLOW	= 'FFFF00'
IA_COLOR_RED	= 'FF0000'
IA_COLOR_GREEN	= '00FF00'
IA_COLOR_BLUE	= '1F51FF'
IA_COLOR_CYAN	= '00FFFF'
IA_COLOR_PINK	= 'FF00FF'
IA_COLOR_ORANGE	= 'FF6600'

A.ids = {
	[196689] = {A.VenomousArrow, BEGIN}, -- nasty dot by archers (can be avoided by blocking it)
	[196997] = {A.StormImpZap, ANY}, -- one shot without block on high arcs (500ms to start -> 3500ms channel (reduces with each arc) -> big final hit)
	[223720] = {A.StormImpZap, ANY}, -- frost imp, same logic

	-- Infuser
	--[210854] = {A.InfuserPoolOfShadow, BEGIN}, -- ground AoE
	--[210833] = {A.InfuserInfuse}, -- interrupt
	[210837] = {A.InfuserTargetAllies, EFFECT, 1}, -- infuse allies

	[157030] = {A.MendingMiasma, BEGIN, 1200}, -- Realmshaper Cast (interrupt)
	[196848] = {A.MundusBreach, BEGIN, 1000}, -- Realmshaper Wave
	[202513] = {A.ShockBarrage, BEGIN}, -- Dwarven Sphere Shock Barrage
	[212001] = {A.Nullification, BEGIN, 500}, -- Spellthief Nullification
	[195156] = {A.DaedricInfluence, BEGIN}, -- High Kinlord Rilis Bubble
	[196806] = {A.Negate, BEGIN}, -- Negate
	[210483] = {A.Inferno, BEGIN, 1000}, -- Inferno
	[221792] = {BEGIN, 500, color = IA_COLOR_PINK, text = 'BREW'}, -- Elixir of Diminishing (Fabled Brewmaster)

	-- Lord Warden Dusk
	--[197265] = A.LordWardenDuskShadowNova, -- hitValue 6000; pool mechanic?

	[200060] = {A.Scamp, DURATION, 10000}, -- Gw
	[200067] = {A.ScampEscape, BEGIN, 5000},

	--
	-- Heavy attacks and stuff
	--

	-- Last boss
	[212000] = {DURATION, 5000, 10100}, -- Spawn
	[192039] = {DURATION, 2000, 4000, color = IA_COLOR_RED}, -- Splintering Mirror (extra shards after destroying Replicanum's shield)
	--[211802] = {EFFECT, nil, 4500}, -- Splintering Ire (single shard), not too dangerous and can be too spammy
	[192517] = {BEGIN, 2333, color = IA_COLOR_RED, text = 'BLOB'}, -- Seeking Spheres (blob interrupt)
	[212268] = {A.Crap, DURATION, 1250}, -- blobs/tentacles spawn
	[208124] = {DURATION, nil, 4500, color = IA_COLOR_RED}, -- Glass Sky
	[193182] = {color = IA_COLOR_BLUE, filter = false}, -- Glass Labyrinth
	[209924] = true, -- Chomp 1
	[209925] = true, -- Chomp 2
	[209926] = true, -- Chomp 3
	[209931] = {color = IA_COLOR_GREEN}, -- Breath (<<<)
	[209948] = {color = IA_COLOR_GREEN}, -- Breath (>>>)
	[209846] = 1500, -- Right Wing Thrash
	--[192243] = {DURATION, 750, 1000}, -- Tentacle Sweep

	-- Shadowrend
	[191598] = {A.ShadowrendPounce, BEGIN, 100}, -- Pounce & Feed
	[191596] = 2000, -- Tail Smite

	-- Ra'khajin
	[203525] = true, -- Teleport Strike
	[28408] = true, -- Whirlwind
	[203519] = true, -- Throw Dagger

	-- Garron the Returned
	[195959] = {DURATION, 300, 4000, color = IA_COLOR_BLUE}, -- Consume Life

	-- Bittergreen the Wild
	[198680] = true, -- quick attack (hard to react)
	[198685] = true, -- jump/stomp

	-- Queen of the Reef
	[193811] = true, -- Heavy Attack

	-- High Kinlord Rilis
	[195079] = true, -- Heavy Attack

	-- Voidmother Elgroalif
	[195460] = true, -- ???
	[195484] = {color = IA_COLOR_GREEN}, -- AoE
	[195487] = {color = IA_COLOR_GREEN}, -- Big Bang

	-- Cynhamoth
	[198723] = true, -- Black Winter

	-- Captain Blackheart (most useless boss)
	[192522] = {DURATION, 2000}, -- Polymorph Skeleton

	-- The Lava Queen
	[195513] = true, -- Catching Flame (range attack)
	[195510] = true, -- Heavy Attack

	-- Old Snagara
	[193518] = true, -- Headbutt
	[193521] = {color = IA_COLOR_GREEN}, -- Shockwave
	[193515] = {color = IA_COLOR_RED}, -- Spit

	-- Vila Theran
	[195655] = 3000, -- Channel Shadow (3000/5000)

	-- Rada al-Saran
	[194269] = true, -- Heavy Attack
	[145467] = {color = IA_COLOR_RED}, -- Charge

	-- Ash Titan 
	[195420] = true, -- Cleave
	[195448] = {BEGIN, 3000, 1000, color = IA_COLOR_RED, filter = false}, -- Wing Burst
	[195455] = {EFFECT, 1500}, -- Molten Rain

	-- The Sable Knight 
	[198902] = true, -- Heavy Attack
	[209537] = true, -- Shield Throw

	-- Kra'gh the Dreugh King
	[191702] = true, -- Heavy Attack
	[191689] = {color = IA_COLOR_GREEN}, -- AoE
	[191693] = {BEGIN, 2000, color = IA_COLOR_BLUE}, -- Flurry

	-- Limenauruus
	[195639] = true,
	[195640] = {color = IA_COLOR_RED}, -- Charge

	-- Warchief Ozozai
	[191650] = true, -- Heavy Attack
	[191653] = true, -- Charge?
	[191670] = true, -- Daedric Blast

	-- Exarch Kraglen
	[197573] = true, -- Heavy Attack
	[197580] = {color = IA_COLOR_RED}, -- Blood Rage (interrupt)
	[197614] = true, -- AoE
	[197604] = true, -- Charge

	-- Razor Master Erthas
	[192348] = 1500, -- Burning Embers

	-- Taupezu Azzida
	[194335] = {color = IA_COLOR_RED}, -- Spear
	[194303] = true, -- AoE
	--[209190] = true, -- atro cast

	-- Valkynaz Nokvroz
	[194345] = {color = IA_COLOR_RED}, -- Heavy Attack
	[194356] = true, -- Fire Wave 1
	[194373] = true, -- Fire Wave 2
	[194378] = true, -- Fire Wave 3
	[194416] = {color = IA_COLOR_GREEN}, -- Flame Spout

	-- Sentinel Aksalaz
	[197661] = {BEGIN, 3000, 2000}, -- Heavy Attack [2200/2245]
	--197663, -- Sentinel Aksalaz
	[197868] = true, -- Wipeout
	[197683] = {DURATION, 3750, color = IA_COLOR_BLUE}, -- Aspect of Winter (ice comet)
	[209767] = true, -- Gelid Globe (Avatar of Vigor)
	[150355] = {color = IA_COLOR_RED}, -- Ice Atro Heavy Attack

	-- Doylemish Ironheart
	[199901] = true, -- Heavy Attack
	[199906] = {BEGIN, 800, color = IA_COLOR_GREEN}, -- Focal Quake

	-- Zhaj'hassa the Forgotten
	[197355] = true, -- Shatter
	[197421] = {EFFECT, 1750, color = IA_COLOR_BLUE}, -- Curse

	-- Rakkhat
	[204209] = 3500, -- Void Strike (Heavy Attack)
	[204216] = {BEGIN, 3600, color = IA_COLOR_BLUE}, -- Void Barrage
	[204260] = true, -- Lunar Smash
	[204225] = 1900, -- Threshing Wings

	-- Sonolia the Matriarch
	[46732] = {BEGIN, 700, color = IA_COLOR_RED}, -- Sonic Scream
	[9674] = {A.LamiaResonate, BEGIN, 1500}, -- Resonate
	[9671] = true, -- Heavy Attack

	-- Murklight
	[195669] = {color = IA_COLOR_BLUE}, -- Double Slam (can't dodge)
	[195671] = {color = IA_COLOR_RED}, -- Shadow Stomp
	[195722] = {BEGIN, 3100, color = IA_COLOR_GREEN}, -- Rune

	-- Nerien'eth
	[196235] = true, -- Heavy Attack
	[196129] = true, -- Necrotic Blast
	[196238] = {color = IA_COLOR_RED}, -- Lethal Stab

	-- The Imperfect
	[195351] = true, -- Light Attack
	[195323] = {BEGIN, 667, color = IA_COLOR_RED}, -- Pulse (shock attack)
	[94074] = {BEGIN, 900, 1000}, -- add spin

	-- Selene
	--[195814] = {color = IA_COLOR_GREEN}, -- Poison Wave (2000/4000)
	--[195816] = 1000, -- Poison Bolt (interrupt)
	[209645] = {color = IA_COLOR_RED}, -- Spider Heavy Attack
	[122995] = 600, -- Bear Roar (fear)
	[209640] = 1800, -- Bear Heavy Attack

	-- Molag Kena
	[196397] = true, -- Heavy Attack
	[196401] = {color = IA_COLOR_RED}, -- Cleave
	[196441] = {color = IA_COLOR_GREEN}, -- Storm Slam
	[196407] = {BEGIN, 800, 1000, color = IA_COLOR_BLUE}, -- Shock Spear
	[196414] = {BEGIN, 2000, color = IA_COLOR_GREEN}, -- Meteor Strike

	-- Ysmgar
	[194756] = true, -- Heavy Attack
	[195612] = {color = IA_COLOR_GREEN}, -- Crashing Wave (dodgable AoE)
	[195591] = {color = IA_COLOR_BLUE}, -- Smash

	-- Lord Warden Dusk
	[197157] = true, -- Barrage (3600/6000)
	[197016] = {color = IA_COLOR_BLUE}, -- Shadow Orb
	
	-- Canonreeve Oraneth
	[9944] = {color = IA_COLOR_BLUE}, -- Necrotic Burst (ground AoE)

	-- The Serpent
	[191707] = true, -- Heavy Attack
	[196517] = {A.SerpentTotem, BEGIN, 5}, -- Summon Buff Totem

	-- Yolnahkriin
	[194736] = {color = IA_COLOR_RED}, -- Unrelenting Force
	[194932] = {color = IA_COLOR_RED}, -- Yolnahkriin Right Wing Thrash
	[194918] = {color = IA_COLOR_RED}, -- Yolnahkriin Left Wing Thrash
	[194907] = true, -- Heavy Attack
	[194908] = true, -- Heavy Attack
	[194966] = {color = IA_COLOR_BLUE}, -- Takeoff

	-- Xeemhok the Trohpy-Taker
	[193812] = {color = IA_COLOR_RED}, -- Heavy Attack
	[191526] = true, -- AoE
	[191542] = {color = IA_COLOR_GREEN}, -- Breath
	[195462] = {color = IA_COLOR_GREEN}, -- Rock Fall

	-- Mulaamnir
	[196308] = true, -- Storm Breath
	[194811] = {color = IA_COLOR_BLUE}, -- Takeoff
	[196371] = {DURATION, 1000, color = IA_COLOR_BLUE}, -- Perch
	[196372] = {DURATION, 2000, color = IA_COLOR_GREEN}, -- Storm Run
	[196257] = 1500, -- Right Wing
	[196278] = 1500, -- Left Wing

	-- Symphony of Blades
	[196919] = true, -- Heavy Attack
	[196920] = {BEGIN, 400, 5400, color = IA_COLOR_BLUE}, -- Blade Dance
	[197065] = {BEGIN, nil, 500, color = IA_COLOR_GREEN}, -- Agonizing Bolts (shock AoE)

	-- Z'Baza
	[204558] = {BEGIN, 1000, color = IA_COLOR_BLUE, filter = false}, -- Mind Blast
	[204560] = {BEGIN, 2000, color = IA_COLOR_YELLOW}, -- Yaghra Heavy Attack 1
	[159824] = {BEGIN, 2200, color = IA_COLOR_RED}, -- Yaghra Heavy Attack 2

	-- Ghemvas the Harbinger
	[198946] = true, -- 3x combo 1st hit
	[198949] = true, -- 3x combo 2nd hit
	[198950] = {DURATION, 3000, 2100}, -- 3x combo last hit (heavy attack)
	[198958] = {color = IA_COLOR_BLUE}, -- Unstable Blitz

	-- Glemyos Wildhorn
	[194549] = true, -- Heavy Attack
	[194550] = true, -- Stomp AoE
	[195773] = {BEGIN, nil, 1100, color = IA_COLOR_RED}, -- Teleport & Strike
	[195790] = {color = IA_COLOR_GREEN}, -- Roots
	--[195801] = 700, -- Ram
	[173998] = {A.IndrikStaticCharge, BEGIN, 500}, -- Indrik Cast

	-- The Endling
	[198817] = {color = IA_COLOR_RED}, -- Heavy Attack
	[198775] = {filter = false}, -- Slam
	[195350] = true,
	[198819] = {BEGIN, 2000, color = IA_COLOR_RED, text = 'BREATH'}, -- Inferno (Fire Breath) (1500/2000)
	[198844] = {color = IA_COLOR_CYAN}, -- Arctic Shred (Ice AoE)
	[198853] = {BEGIN, 500, 1300, color = IA_COLOR_BLUE}, -- Lightning Bolt (stun)

	-- Prior Thierric Sarazen
	[199600] = true, -- Cleave
	[199608] = true, -- Heavy Attack
	[199628] = {DURATION, 2000, color = IA_COLOR_RED}, -- Bewilder (add)

	-- Baron Zaudrus
	[205013] = true, -- Crush (quick attack)
	[205030] = {color = IA_COLOR_RED}, -- Galvanic Blow (shock AoE)
	[205036] = {color = IA_COLOR_RED}, -- Heavy Attack
	[205021] = {DURATION, 2000}, -- Uneven Terrain

	--Laatvulon
	[194749] = {color = IA_COLOR_CYAN}, -- Breath
	[194830] = {DURATION, 3000, color = IA_COLOR_GREEN}, -- Storm Run
	[194828] = {DURATION, 1000, color = IA_COLOR_BLUE}, -- Perch (landing)
	[194777] = 1500, -- Right Wing
	[194765] = 1500, -- Left Wing

	-- Nazaray
	[204446] = true, -- Heavy Attack
	[204515] = {BEGIN, 1200, color = IA_COLOR_RED}, -- Liquidate (small AoE that makes her immune?)

	-- The Weeping Woman
	[199437] = {color = IA_COLOR_RED}, -- Heavy Attack
	[199410] = true, -- Shivering Swat (cone attack)

	-- Lady Belain
	[194663] = true, -- Heavy Attack
	[194605] = 1500, -- 3x Charges
	[194609] = {color = IA_COLOR_BLUE}, -- Ground Smash
	[194626] = {BEGIN, nil, 1500}, -- Blood Barrage

	-- Lady Thorn
	[198007] = {BEGIN, 100, 1500, color = IA_COLOR_GREEN}, -- Charge
	[197982] = {DURATION, 1250, color = IA_COLOR_RED}, -- Don't dodge, or she will bug out
	[198103] = {DURATION, 2000, 1500}, -- Blood Dive

	-- The Whisperer
	[193164] = {color = IA_COLOR_GREEN}, -- Summon spiders

	-- The Warrior
	[191366] = true, -- Channeled Swipes
	[191428] = {color = IA_COLOR_GREEN}, -- Shield Throw
	[191506] = {color = IA_COLOR_RED}, -- Cleave
	[191429] = {color = IA_COLOR_GREEN}, -- Leap
	[43237] = {A.WarriorInferno, BEGIN, 1000}, -- Inferno
	[47461] = {DURATION, 4500, color = IA_COLOR_BLUE}, -- Two-hander's Channel

	-- Councilor Vandacia
	[194158] = {color = IA_COLOR_RED},
	
	-- Varlariel
	[226975] = {BEGIN, 6700, color = IA_COLOR_RED}, -- Combustion (boom)

	-- Sail Ripper (harpy)
	[221964] = {BEGIN, 1500, color = IA_COLOR_BLUE}, -- Cyclone (AoE in front)
	[221959] = {BEGIN, 1500, 2500, color = IA_COLOR_RED, text = 'BASH'}, -- Air Burst (charge) -> Beam (must interrupt)
	[221929] = true, -- Heavy Attack
	[228021] = {BEGIN, 1500, color = IA_COLOR_GREEN, text = 'CELL'}, -- Storm Cell (donut)
	
	-- Yandir The Butcher
	[221988] = true, -- Sundering Strike (armor debuff)
	[221975] = {BEGIN, 1600, color = IA_COLOR_RED}, -- Heavy Attack
	[221979] = {BEGIN, 2400, color = IA_COLOR_GREEN, filter = false}, -- Toxic Tide
	
	-- Staada
	[221207] = true, -- Thunder Hammer
	[221209] = {BEGIN, 2000, color = IA_COLOR_RED, text = 'BASH'}, -- Shock Aura
	[227953] = {BEGIN, color = IA_COLOR_BLUE}, -- Agonizing Strike

	-- Graufang (bear)
	[221213] = true, -- Slam

	-- Dranos Velador
	[203593] = {filter = false}, -- Heavy Attack 1
	[221816] = {color = IA_COLOR_RED}, -- Heavy Attack 2
	[221791] = {DURATION, 15000, 1500, filter = false, color = IA_COLOR_GREEN, text = 'MOVE'}, -- Shadow Spinneret
	[221809] =  {color = IA_COLOR_BLUE}, -- Mark of Mephala
	
	-- Dugan the Red
	[221216] = true, -- Heavy Attack
	[221219] = {BEGIN, 633, 1000, filter = false, color = IA_COLOR_RED}, -- Standard

	-- Varzunon
	[221231] = true, -- Heavy Attack

	-- Kovan Giryon
	[220881] = {BEGIN, 1000, filter = false, color = IA_COLOR_GREEN}, -- Big AoE
	[220959] = true, -- Heavy Attack

	-- Risen Ruins
	[227222] = true, -- Boulder
	[227232] = {BEGIN, 500, 1000, filter = false, color = IA_COLOR_BLUE, text = 'NULL'}, -- Nullification

	-- Trash
	[7095] = true, -- Dremora Ravager Heavy Attack (id looks generic, so maybe someone else too)
	[196867] = true, -- Wild Guar Jump
	--[196870] = {DURATION, 1000, color = IA_COLOR_GREEN}, -- Wild Guar Bile Splatter
	[196860] = true, -- Durzog Rotbone
	[202945] = true, -- Wolf Lunge
	[211114] = {DURATION, 1400}, -- Magma Frog Heavy 1
	[223086] = true, -- Magma Frog Heavy 2
	[202940] = {color = IA_COLOR_CYAN}, -- Harry (arc 7+)
	[202948] = {color = IA_COLOR_CYAN}, -- Nip (arc 7+)
	[202374] = {color = IA_COLOR_BLUE}, -- Bone Colossus Pound (not dodgable)
	[202607] = true, -- Dreadhorn Earthgorer Clobber
	[202531] = true, -- Dwarven Centurion
	[202539] = true, -- Dwarven Sphere
	--[196718] = 2600, -- Bulwark (not needed?)
	[196719] = {DURATION, 2000, color = IA_COLOR_BLUE}, -- Bulwark (range attack, not dodgable?)
	[196727] = {BEGIN, nil, 1000, color = IA_COLOR_ORANGE}, -- Bulwark Standard
	[211594] = {color = IA_COLOR_RED}, -- Bulwark Power Bash
	[197002] = {BEGIN, 1600, 2100, color = IA_COLOR_BLUE}, -- Storm Atronach Heavy
	[197004] = true, -- Storm Atronach Impending Storm
	[203104] = true, -- Cliff Strider Dive
	[203100] = {BEGIN, 900, color = IA_COLOR_GREEN}, -- Cliff Strider AoE
	--[201831] = true, -- Firesong Rockseer Cleave
	[201835] = true, -- Firesong Rockseer Heavy Attack
	[194894] = {color = IA_COLOR_RED}, -- Dremora Ravager Uppercut
	[194984] = {color = IA_COLOR_RED}, -- Uppercut
	[194656] = true, -- Realmshaper Heavy Attack
	[196845] = {color = IA_COLOR_BLUE}, -- Realmshaper AoE
	--[157030] = {BEGIN, 1200, color = IA_COLOR_RED}, -- Realmshaper Cast (interrupt)
	[203467] = {BEGIN, 400, 750, color = IA_COLOR_RED}, -- Dreadhorn Scrapper Oil
	[201727] = {BEGIN, 1000, 1200}, -- Dremora Shield Charge
	[196959] = {BEGIN, 1400, color = IA_COLOR_RED}, -- Iron Atronach Heavy Attack
	[203496] = {color = IA_COLOR_RED}, -- Dremora Ironclad Heavy Attack
	[203492] = true, -- Dremora Ironclad Strike
	[196875] = {color = IA_COLOR_RED}, -- Lurcher Earthen Blast
	[196715] = {color = IA_COLOR_RED}, -- Goblin Power Bash
	[35849] = {color = IA_COLOR_BLUE}, -- Shadow Cloak
	[202632] = {A.PillarsOfNirn, BEGIN, 700}, -- Dreadhorn Firehide
	[202656] = {BEGIN, 1467, 2000, color = IA_COLOR_GREEN}, -- Dreadhorn Firehide AoE
	[210599] = {A.Totem, BEGIN, 2000}, -- Totem Master's Totem
	[210561] = {A.Totem, BEGIN, 2000}, -- Totem Master's Totem
	[221730] = {BEGIN, 500, 1000, color = IA_COLOR_CYAN, text = 'FLOOD'}, -- Fabled Stormcaller's AoE
	[221364] = {BEGIN, 44000, 2000, color = IA_COLOR_RED, text = 'BASH'}, -- Fabled Stormcaller's cast
	[221745] = {BEGIN, 2600, color = 'E2E8A9'}, -- Fabled Lightbringer's AoE
	[221753] = true, -- Fabled Lightbringer's Heavy Attack
	[222919] = {A.SoulCage, BEGIN, 1365}, -- Lich big AoE
	[211976] = {A.MeteorCall, BEGIN, 500}, -- Fabled Mystic's Meteor
	[222916] = {DURATION, 700, color = IA_COLOR_BLUE}, -- Lich small AoE
	[222933] = {BEGIN, 2500, color = IA_COLOR_RED, filter = false}, -- Lich cone AoE
	[222885] = {BEGIN, 1200, 1700, color = IA_COLOR_YELLOW}, -- Hag 3x fireball
	[223378] = {BEGIN, 2000, 2500}, -- Clannfear Leap
	[223191] = {BEGIN, color = IA_COLOR_BLUE, text = 'SWARM'}, -- Wraith of Crows AoE
	[223119] = true, -- Reap
	[223135] = {A.Abyss, BEGIN},

	-- Marauder Gothmau
	[210006] = true, -- 3x combo start (2 quick hits)
	[210010] = {BEGIN, 1500, color = IA_COLOR_RED}, -- 3x combo final hit (heavy attack)
	[210028] = {BEGIN, 1350, 1750, color = IA_COLOR_RED}, -- throwing swords

	-- Marauder Hilkarax
	[210519] = {color = IA_COLOR_RED}, -- Heavy Attack

	-- Marauder Ulmor
	[210840] = true, -- Heavy Attack
	[210841] = true, -- Crashing Wave (dodgable)
	[210830] = {color = IA_COLOR_BLUE}, -- Fulmination (blockable)

	-- Marauder Bittog
	[221112] = {color = IA_COLOR_RED}, -- Heavy Attack
	[221108] = true, -- Bite (puts bleeding)
	
	-- Marauder Zulfimbul
	[220298] = {color = IA_COLOR_RED}, -- Heavy Attack
	[227457] = {color = IA_COLOR_GREEN, filter = false}, -- AoE

	-- Aramril (event boss)
	[201193] = {A.Aramril, DURATION}, -- Start Fight (86400000 Aramril -> P)
	[199387] = {A.AramrilCast, BEGIN, 1000, 2000, color = IA_COLOR_RED}, -- Empowered Runeblades (interrupt), ~ 17s CD (first cast 15 or depends on crystal???)
	--[199492] = {DURATION, 2000, color = IA_COLOR_GREEN}, -- Ground Target (pool), no need to block or dodge, so ignore it?
	[199503] = {DURATION, 2000, color = IA_COLOR_GREEN}, -- Ground Target (tentacle)
	--[199320] = 1000, -- Arcane Shard (crystal)
	[194077] = true, -- Add's Heavy Attack
	[194034] = {BEGIN, 600, 750, color = IA_COLOR_BLUE}, -- Grasping Scream (fear, can be blocked; ??? target)

	-- Some ids from EAA
	[194053] = true, -- Allene Pellingare
	[193534] = true, -- Barbas
	[195490] = true, -- Grothdarr
	[192658] = true,
	[192659] = true, -- Iceheart
	[198333] = true, -- Kjarg the Tuskscraper
	[197157] = true,
	[197152] = true, -- Lord Warden Dusk
	[192205] = true, -- Tho'at Replicanum
	[201360] = true, -- Tremorscale
	[195978] = true,
	[195965] = {BEGIN, 2000, 3000}, -- Vorenor Winterbourne
	[194987] = {color = IA_COLOR_RED}, -- Ascendent Vanguard Heavy Attack
	[202665] = true, -- Bear
	[202377] = true, -- Bone Colossus
	[202129] = {BEGIN, 2000, 2100}, -- Dreadhorn Blade-Bearer Heavy Attack
	[203464] = true, -- Dreadhorn Scrapper
	[202530] = true, 
	[202541] = true,
	[192695] = true, -- Glass Leviathan
	[192707] = true, -- Glass Tendril
}
