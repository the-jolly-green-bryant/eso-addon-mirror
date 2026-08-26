local LCA = LibCombatAlerts

CombatAlertsData = {
	-- Zones that require the tracking of effects and/or unit IDs --------------
	effectTrackingZoneIds = {
		[1009] = true, -- Fang Lair
		[1010] = true, -- Scalecaller Peak
		[1051] = true, -- Cloudrest
		[1121] = true, -- Sunspire
		[1122] = true, -- Moongrave Fane
		[1153] = true, -- Unhallowed Grave
		[1196] = true, -- Kyne's Aegis
		[1197] = true, -- Stone Garden
		[1201] = true, -- Castle Thorn
		[1267] = true, -- Red Petal Bastion
		[1301] = true, -- Coral Aerie
		[1302] = true, -- Shipwright's Regret
		[1361] = true, -- Graven Deep
	},


	-- Zones that require boss checking ----------------------------------------
	bossCheckZoneIds = {
		[1009] = true, -- Fang Lair
	},


	-- Perfect Roll ------------------------------------------------------------
	dodge = {

		--[[ Options ---------------------------------------
		1: Size of alert window
			0: None
			>0: Time, in milliseconds
			-1: Default (auto-detect)
			-2: Default (melee)
			-3: Default (projectile)
		2: Alert text/ping (ignored if alert window is 0)
			0: Never
			1: Always
			2: Suppressed for tanks
		3: Interruptible (optional, default false)
		4: Color, regular (optional)
		5: Color, alerted (optional)
		vet: Vet-only?
		offset: Offset to reported hitValue, in milliseconds
		--------------------------------------------------]]

		ids = {
			[9845] = { -3, 0 }, -- Elden Hollow I -- Rotting Bolt
		--	[13783] = { -2, 2 }, -- ?? -- Hammer
			[18078] = { -3, 1 }, -- Spindleclutch I -- Web Blast
			[18111] = { -3, 1 }, -- Spindleclutch I -- Arachnophobia
			[23022] = { -3, 1 }, -- Fungal Grotto II -- Shadow Chains
			[23156] = { -3, 2 }, -- Fungal Grotto II -- Shadow Bolt
			[27741] = { -2, 1 }, -- Spindleclutch II -- Enervating Seal
			[25962] = { -2, 2 }, -- Blessed Crucible -- Overpowering Swing
			[51539] = { -3, 0 }, -- Crypt of Hearts II -- Necrotic Blast
			[55426] = { -3, 0 }, -- City of Ash II -- Magma Prison
			[55513] = { -3, 0 }, -- City of Ash II -- Flame Bolt
			[67420] = { -3, 0 }, -- Maelstrom Arena -- Necrotic Blast (bottom phase)
			[69001] = { -3, 0 }, -- Maelstrom Arena -- Necrotic Blast (top phase)
			[71771] = { -3, 2 }, -- Maelstrom Arena -- Ball Lightning
			[86914] = { -2, 2 }, -- Bloodroot Forge -- Anvil Cracker
			[92999] = { -3, 2 }, -- Falkreath Hold -- Fiery Blast
			[93133] = { -3, 2 }, -- Falkreath Hold -- Clobber
			[98667] = { -2, 2 }, -- Fang Lair -- Uppercut
			[99460] = { -2, 2 }, -- Scalecaller Peak -- Crushing Blow
			[99527] = { -2, 2 }, -- Scalecaller Peak -- Lacerate
			[101494] = { -2, 2 }, -- Scalecaller Peak -- Lacerate
			[101685] = { -2, 2 }, -- Scalecaller Peak -- Power Bash
			[109205] = { -3, 1 }, -- Frostvault -- Bola Ball
			[113465] = { -2, 2 }, -- Frostvault -- Reverberating Smash
			[112767] = { -2, 2 }, -- Depths of Malatar - Dissonant Blow
			[114075] = { -3, 2 }, -- Depths of Malatar - Gelid Globe
			[114349] = { -2, 2 }, -- Depths of Malatar - Ravaging Blow
			[115928] = { -2, 2 }, -- Moongrave Fane -- Heavy Slash (Grundwulf)
			[128527] = { -2, 2 }, -- Moongrave Fane -- Heavy Slash (Hollowfang Dire-Maw)
			[116190] = { -2, 2 }, -- Moongrave Fane -- Lacerate (Kujo Kethba)
			[120740] = { -2, 2 }, -- Moongrave Fane -- Lacerate (Sangiin's Thirst)
			[122984] = { -2, 2 }, -- Lair of Maarselok -- Chomp
			[122987] = { -2, 2 }, -- Lair of Maarselok -- Chomp
			[122989] = { -2, 2 }, -- Lair of Maarselok -- Chomp
			[123242] = { 400, 2 }, -- Lair of Maarselok -- Azureblight Spume
			[123906] = { -2, 2 }, -- Lair of Maarselok -- Venomous Fangs
			[123402] = { -2, 2 }, -- Lair of Maarselok -- Crushing Limbs (Azureblight Lurcher in Maarselok Flying, Maarselok Grounded)
			[124432] = { -2, 2 }, -- Lair of Maarselok -- Crushing Limbs (Azureblight Lurcher in Trash, Maarselok Perched)
			[127139] = { -2, 2 }, -- Lair of Maarselok -- Sickening Smash (Azureblight Infestor in Azureblight Cancroid)
			[128667] = { -2, 2 }, -- Lair of Maarselok -- Sickening Smash (Azureblight Infestor in Trash)
			[126530] = { -2, 2 }, -- Lair of Maarselok -- Devastate
			[126580] = { -3, 2 }, -- Lair of Maarselok -- Blight Burst
			[126695] = { -2, 2 }, -- Lair of Maarselok -- Deadly Strike
			[129133] = { -3, 2 }, -- Lair of Maarselok -- Icy Blast

			[126113] = { -2, 2 }, -- Icereach -- Freezing Bash
			[126385] = { -2, 2 }, -- Icereach -- Crypt Smash
			[127492] = { -2, 2 }, -- Icereach -- Uppercut
			[126038] = { -3, 2 }, -- Icereach -- Heavy Attack
			[126039] = { -3, 2 }, -- Icereach -- Heavy Attack
			[126095] = { -3, 2 }, -- Icereach -- Heavy Attack
			--[125789] = { 0, 0, false, { 0.4, 0.6, 0.8, 0.6 } }, -- Icereach -- Frozen Spit
			[129983] = { -2, 2 }, -- Unhallowed Grave -- Arcing Swing
			[130147] = { -2, 2 }, -- Unhallowed Grave -- Bone Sunder
			[130741] = { -2, 2 }, -- Unhallowed Grave -- Dissonant Blow
			[130294] = { -2, 2 }, -- Unhallowed Grave -- Clash of Bones
			[130035] = { -2, 2 }, -- Unhallowed Grave -- Heinous Flurry
			[131624] = { -2, 2 }, -- Unhallowed Grave -- Murderous Chop
			[131267] = { -3, 1, true }, -- Unhallowed Grave -- Icy Salvo

			[133965] = { 400, 2 }, -- Stone Garden -- Slaughter
			[134308] = { -2, 2 }, -- Stone Garden -- Whop
			[140129] = { -2, 2 }, -- Stone Garden -- Core Blast
			[140413] = { -2, 2, offset = -900 }, -- Stone Garden -- Shred
			[140743] = { -2, 2 }, -- Stone Garden -- Cross Swipe
			[144179] = { -2, 2 }, -- Stone Garden -- Rotbone
			[145540] = { -2, 2 }, -- Stone Garden -- Reap
			[137764] = { -2, 2, offset = -800 }, -- Castle Thorn -- Clobber
			[137906] = { -2, 2 }, -- Castle Thorn -- Lunge
			[137966] = { -2, 2 }, -- Castle Thorn -- Cross Swipe
			[138368] = { -2, 2 }, -- Castle Thorn -- Shadow Strike
			[138946] = { -2, 2 }, -- Castle Thorn -- Heavy Slash
			[139581] = { -2, 0 }, -- Castle Thorn -- Pummel
			[145376] = { -2, 2 }, -- Castle Thorn -- Cuff (Veteran)
			[145377] = { -2, 2 }, -- Castle Thorn -- Cuff (Normal)

			[105968] = { -2, 2 }, -- Cloudrest -- Corpulence
			[105975] = { -2, 1 }, -- Cloudrest -- Baneful Barb
			[104535] = { 0, 0, false, { 1, 0, 0.6, 0.8 } }, -- Cloudrest -- Nocturnal's Favor
			[106375] = { -2, 2 }, -- Cloudrest -- Ravaging Blow
			[104755] = { -2, 2 }, -- Cloudrest -- Scalding Sunder
			[105780] = { -2, 2 }, -- Cloudrest -- Shocking Smash
			[105673] = { -2, 0, vet = true }, -- Cloudrest -- Talon Slice
			[105674] = { -2, 0, vet = true }, -- Cloudrest -- Talon Slice
			[119817] = { -2, 2 }, -- Sunspire -- Anvil Cracker
			[115723] = { -2, 2 }, -- Sunspire -- Bite
			[115443] = { -2, 2 }, -- Sunspire -- Bite
			[122124] = { -2, 2 }, -- Sunspire -- Bite
			[120838] = { -2, 0 }, -- Sunspire -- Glacial Fist

			[132511] = { -3, 2 }, -- Kyne's Aegis -- Toxic Tide
			[133685] = { -2, 2 }, -- Kyne's Aegis -- Shield Bash
			[133756] = { -2, 2 }, -- Kyne's Aegis -- Thunderous Bash
			[134050] = { -3, 2, false, { 1, 0, 0.6, 0.4 }, { 1, 0, 0.6, 0.8 } }, -- Kyne's Aegis -- Wrath of Tides
			[135324] = { -2, 2 }, -- Kyne's Aegis -- Butcher's Blade
			[135991] = { -2, 2 }, -- Kyne's Aegis -- Toppling Blow
			[136591] = { -3, 2 }, -- Kyne's Aegis -- Bile Spray
			[136817] = { -2, 2 }, -- Kyne's Aegis -- Cross Swipe
			[136961] = { -2, 2 }, -- Kyne's Aegis -- Uppercut
			[136976] = { -3, 2 }, -- Kyne's Aegis -- Blood Cleave
			[140230] = { -2, 2 }, -- Kyne's Aegis -- Heavy Strike
			[140231] = { -3, 2, true }, -- Kyne's Aegis -- Javelin

			[165644] = { -3, 2 }, -- Shipwright's Regret -- Furious Blast
			[163929] = { -2, 2 }, -- Shipwright's Regret -- Soul Bash
			[166981] = { -2, 2 }, -- Shipwright's Regret -- Lacerate
			[164898] = { -2, 2 }, -- Shipwright's Regret -- Bludgeon
			[165378] = { -2, 2 }, -- Shipwright's Regret -- Windfall
			[166174] = { -2, 2 }, -- Shipwright's Regret -- Induction
			[166944] = { -2, 2 }, -- Shipwright's Regret -- Stormfront
			[163764] = { -2, 2 }, -- Shipwright's Regret -- Drown
			[159824] = { -2, 2, offset = 250 }, -- Coral Aerie -- Reave
			[162126] = { -2, 2 }, -- Coral Aerie -- Upthrust
			[162128] = { -2, 2 }, -- Coral Aerie -- Swordfall
			[162142] = { -2, 2 }, -- Coral Aerie -- Excision
			[158662] = { -2, 2 }, -- Coral Aerie -- Barbed Lance
			[168750] = { -2, 2 }, -- Coral Aerie -- Power Bash
			[162905] = { -2, 2 }, -- Coral Aerie -- Power Bash
			[158346] = { -2, 2 }, -- Coral Aerie -- Brand
			[159864] = { -2, 2 }, -- Coral Aerie -- Monstrous Claw
			[158778] = { 0, 0, false, { 1, 0, 0.6, 0.8 }, cutthroat = true }, -- Coral Aerie -- Obliterate

		--	[112995] = { -2, 0 }, -- Graven Deep -- Hammer (Duplicate of Frostvault)
			[168375] = { -2, 0 }, -- Graven Deep -- Lacerate
			[171986] = { -2, 0 }, -- Graven Deep -- Bristlebombard
			[175763] = { -2, 2 }, -- Graven Deep -- Feint Stab
			[171112] = { -2, 2 }, -- Graven Deep -- Clash of Bones
			[178900] = { -2, 2 }, -- Graven Deep -- Clash of Bones
			[175964] = { -2, 2 }, -- Graven Deep -- Soul Bash
			[172217] = { -2, 2 }, -- Graven Deep -- Necrotic Wave

			[171918] = { -2, 2 }, -- Earthen Root Enclave -- Crackdown
			[172130] = { -2, 2 }, -- Earthen Root Enclave -- Knuckle Duster
			[172147] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Earthen Root Enclave -- Chin Shatter
			[172790] = { -2, 2 }, -- Earthen Root Enclave -- Mince
			[172983] = { -2, 2 }, -- Earthen Root Enclave -- Hammerfall

			-- Taking Aim
			[70695] = { -3, 2, true }, -- Maelstrom Arena
			[74978] = { -3, 2, true }, -- Craglorn / Dragonstar Arena
			[76848] = { -3, 2, true }, -- Ruins of Mazzatun
			[78781] = { -3, 2, true },
			[100947] = { -3, 2, true }, -- Scalecaller Peak
			--[101651] = { -3, 2, true }, -- Scalecaller Peak (Mortieu -> Jorvuld)
			[108397] = { -3, 2, true }, -- Unhallowed Grave

			-- Misc
			[52825] = { -3, 2, true }, -- Dragonstar Arena -- Lethal Arrow
			[92892] = { -2, 2 }, -- Falkreath Hold / Fang Lair -- Clash of Bones
			[112995] = { -2, 2 }, -- Frostvault -- Hammer
			[112999] = { -3, 1, true }, -- Frostvault -- Targeted Salvo
			[117287] = { -2, 2 }, -- Frostvault -- Crushing Blow
			[109121] = { -2, 2 }, -- Frostvault -- Colossal Smash
		},

		interrupts = {
			[ACTION_RESULT_STUNNED]   = true,
			[ACTION_RESULT_INTERRUPT] = true,
			[ACTION_RESULT_DIED]      = true,
			[ACTION_RESULT_DIED_XP]   = true,
		},
	},


	-- General -----------------------------------------------------------------
	general = {
		taunt = 38254,
		guard = 80950,
	},

	damageEvents = {
		[ACTION_RESULT_DAMAGE] = true,
		[ACTION_RESULT_CRITICAL_DAMAGE] = true,
		[ACTION_RESULT_BLOCKED_DAMAGE] = true,
		[ACTION_RESULT_DOT_TICK] = true,
		[ACTION_RESULT_DOT_TICK_CRITICAL] = true,
	},


	-- Misc --------------------------------------------------------------------
	misc = {
		shadowStrike = {
			id = 152574,
			channel = 1260, -- 152574 channel time
			cast = 1000, -- 152577 cast time
		}
	},


	-- Maelstrom Arena ---------------------------------------------------------
	maelstrom = {
		webspinner = 76342,
		ghost = 67354,
		turretoccupied = 71044,
		troll = 71692,
		enrage = 71696,
		hoarvor = 69492,
		artifacts = 71689,
	},


	-- Scalecaller Peak --------------------------------------------------------
	scalecaller = {
		blastIds = {
			[100040] = "LEFT",
			[100884] = "CENTER",
			[101221] = "RIGHT",
		},
		beamId = 99723,
	},


	-- Fang Lair ---------------------------------------------------------------
	fanglair = {
		zone = 1009,
		interval = 30000,
		stare = 98960,
		fear = 99136,
		dormant = 102342,
		grip = 103328,
		names = {
			["cadaverous bear"] = true,
			["kadaverbär"] = true,
			["ours cadavérique"] = true,
		},
	},


	-- Cloudrest ---------------------------------------------------------------
	cloudrest = {
		zone = 1051,
		preyed = 105597,
		amulet = 106023,
		baneful = 107196,
		banefulName = LCA.GetAbilityName(107872),
		flare = {
			[103531] = true,
			[110431] = true,
			execute = 110431,
		},
		flareName = LCA.GetAbilityName(103531),
		flareDuration = 6500, -- 2500ms cast time + 4000ms duration
		sparkles = 105780,
		zmaja = "z'maja",
		crushing = 105239,
		crushingName = LCA.GetAbilityName(105205),
		shadowRealm = {
			[108045] = true, -- gateway
			[104620] = true, -- cone
		},
		overload = 87346,
		shiftShadows = {
			start = 104413,
			stop = 109017,
			name = 104614,
		},
		beadSpawn = 105363,
		beadCharge = 105373,
		beadName = LCA.GetAbilityName(105371),
	},


	-- Frostvault --------------------------------------------------------------
	frostvault = {
		zone = 1080,
		hardHealth = 5000000, -- 3292609 non-HM, 5926696 HM
		effluvium = 109932,
		skeevCharged = 115310,
		skeevWipe = 118251,
		embers = 114930,
		ignitionIds = {
			[114907] = true, -- Ignite, non-HM?
			[114939] = true, -- Ignite, HM
			[114923] = true, -- Disintegration Protocol, HM
			[114924] = true, -- Disintegration Protocol, HM
			[123448] = true, -- Disintegration Protocol, non-HM
			[123449] = true, -- Disintegration Protocol, non-HM
		},
		grind = 112665,
		whipping = 117491,
	},


	-- Depths of Malatar -------------------------------------------------------
	malatar = {
		decrepify = 114112,
	},


	-- Sunspire ----------------------------------------------------------------
	sunspire = {
		zone = 1121,
		thrash = 118562,
		sweepingIds = {
			[118743] = "RIGHT", -- right-to-left
			[120188] = "LEFT", -- left-to-right
		},
		negate = 121411,
		icyPresence = 123103,
		tomb = 119632,
		tombArming = 124687,
		tombArmed = 119638,
		summonFrost = 124046,
		glacialFist = 120838,
		focusFire = 121722,
		geyser = 124546,
		ignite = 121531,
		soulTear = 117526,
		meteor = 117251,
		meteorName = LCA.GetAbilityName(117249),
		meteorIcon = 117256,
		breathIds = {
			[119283] = true, -- Frost Breath
			[121723] = true, -- Fire Breath
			[121980] = true, -- Searing Breath
		},
		frostBolt = 119222,
		frostBreath = 119283,
		translation = 121436,
		timeBreach = 121216,
		defensiveStance = 38316,
		chillingComet = 116636,
		battleFury = 120697,
		standingInAoe = {
			-- { alert_duration, exclude_tanks }
			[115341] = { 700, true }, -- Lava Pool
			[118741] = { 600, false }, -- Boiling Oil
			[115624] = { 1050, true }, -- Flame Spit (Nahviintaas grounded)
			[119472] = { 1050, true }, -- Flame Spit (Nahviintaas in-flight)
			[122726] = { 600, true }, -- Storm Trail
			[122800] = { 600, true }, -- Storm Trail
			[122967] = { 600, true }, -- Storm Trail
		},
 	},


	-- Moongrave Fane ----------------------------------------------------------
 	fane = {
		zone = 1122,
		geyser = 116205,
		geyserPlug = 122258,
		drain = 126417,
		rockslide = 115976,
		shackles = 116953,
		wound = 119135,
		megabat = 119301,
		spawn = 10298,
		spawnFilters = {
			[119305] = true, -- Megabat
		}
 	},


	-- Lair of Maarselok -------------------------------------------------------
 	maarselok = {
 		zone = 1123,
 		headbutt = 123326,
		sweepingBreath = 123532,
		seed = 124783,
		blaze = 123210,
		bonds = 124452,
		bondsMax = 267722,
		unrelenting4 = 124020,
		unrelenting5 = 123334,
		talons = 126700,
		shagrath = 123436,
		shagrathSpit = 124642,
 	},


	-- Unhallowed Grave --------------------------------------------------------
 	uhg = {
 		zone = 1153,
 		ruin = 130161,
 		soulShatter = 129688,
 		soulShatterIds = {
 			[129688] = true,
 			[130236] = true,
 		},
 		abyss = 129966,
 		confinement = 130050,
 		brimstone = 130228,
 		breath = 130344,
 		uppercut = 29378,
 	},


	-- Icereach ----------------------------------------------------------------
 	icereach = {
 		shockHeavy = 126040,
 	},


	-- Kyne's Aegis ------------------------------------------------------------
	ka = {
		zone = 1196,
		crashingWave = {
			cast = 134196,
			name = 134197,
		},
		meteor = {
			ids = {
				[134023] = 1, -- Vrol
				[140606] = 1, -- Yandir
				[140941] = 2, -- Falgravn non-HM
				[140944] = 2, -- Falgravn HM
			},
			params = {
				[1] = { -- Meteor
					id = 140606,
					colorSelf = 0xFF6600FF,
					colorOthers = 0xFFFF00FF,
					excludeTanks = false,
				},
				[2] = { -- Instability
					id = 140941,
					colorSelf = 0x3399FFFF,
					colorOthers = 0xBBDDFFFF,
					excludeTanks = true,
				},
				[3] = { -- Instability Coincide
					id = 140941,
					colorSelf = 0xDD4400FF,
					colorOthers = 0xFF9933FF,
					excludeTanks = true,
				},
			},
		},
		totems = {
			[133045] = { 133264, 0xCC3300FF }, -- Dragon Totem
			[133510] = { 133511, 0x66CCFFFF }, -- Harpy Totem
			[133513] = { 133514, 0xDDCC66FF }, -- Gargoyle Totem
			[133515] = { 133516, 0x00CC00FF }, -- Chaurus Totem
		},
		knights = {
			[140183] = { "Bitter Knight (<<t:1>>)", 0xCC00FFFF }, -- Prison
			[140184] = { "Crimson Knight (<<t:1>>)", 0xFF9999FF, true }, -- Bloodlust
			[140185] = { "Blood Knight (<<t:1>>)", 0xCC0000FF }, -- Fountains
			spawnText = LCA.GetAbilityName(136622),
		},
		spear = 133936,
		gust = 136381,
		chaurus = {
			spawn = 133516,
			projectile = 133559,
		},
		slam = 136559,
		hailShield = 133004,
		toxicTide = 132513,
		frigidFog = 133808,
		shockingHarpoon = 133913,
		fountain = 140294,
		frenzy = 136953,
		sanguineGrasp = 136965,
		sanguinePrison = 132473,
		proxLightning = 134880,
		vrolName = "vrol",
		callLightning = 133428,
		falgRoomCenter = { 79075, 21670, 56040 },
		falgFloor1End = 135271,
		apotheosis = 138196,
		hemorrhage = 132927,
		ichorEruption = 136482,
		ichorTimer = 136548,
		bloodCounter = 133334,
		groundIchor = {
			-- { alert_duration, exclude_tanks }
			[133294] = { 350, true }, -- Pool of Ichor
			[141615] = { 600, false }, -- Corrupted Ichor
		},
		lightningBolt = {
			[136808] = true, -- Storm
			[139945] = true, -- Half-Giant Storm Caller
		},
	},


	-- Stonethorn --------------------------------------------------------------
	stonethorn = {
		charges = {
			[132868] = 30, -- Primal Fury
			[134693] = 30, -- Voltaic Rush
			[137178] = 15, -- Incursion
		},
		chaurus = 145545,
		wwtaunt = 133119,
		cannon = 134189,
		mark = 134243,
		bottled = 134057,
		discharge = 134747,

		annihilate = 137983,
		scatter = 138996,
		dive = 137858,
		memoryGame = {
			zoneId = 1201,
			imbued = 138583,
			gutted = 138646,
			disembowel = 138550,
		},
	},


	-- Ascending Tide ----------------------------------------------------------
	at = {
		bomb1 = 163756,
		bomb2 = 168314,
		fear = {
			[164465] = true,
			[168078] = true, -- HM
		},
		kindred = 164153,
		pursue = 168415,
		spout = 163864,

		daggerstorm = 158185,
		current = 168947,
		links = {
			[149225] = 1,
			[149227] = 2,
		},
		gryphons = {
			call = 158699,
			[158700] = "Ofallo", -- Lion Checker
			[158715] = "Iliata", -- Eagle Checker
			[158716] = "Mafremare", -- Snowowl Checker
			[163184] = "Ofallo", -- Lion Checker (HM)
			[163185] = "Iliata", -- Eagle Checker (HM)
			[163188] = "Mafremare", -- Snowowl Checker (HM)
			[163597] = "Kargaeda", -- Tropical Checker (HM)
		},

		standingInAoe = {
			-- { alert_duration, exclude_tanks }
			[168924] = { 400, false }, -- Lightning Storm
		},
	},


	-- Lost Depths -------------------------------------------------------------
	ld = {
		sunbolt = 171580,
		fear = 172543,
		fearDamage = 174228,
		barrage = 176182,
		soulSplit = {
			[173970] = 1,
			[173972] = 2,
			hmHealth = 10000000,
		},
		orbs = {
			[172618] = { ACTION_RESULT_EFFECT_GAINED, 15500 }, -- Damage Shield
			[172650] = { ACTION_RESULT_EFFECT_GAINED,  5500 }, -- Slow FX
			[178599] = { ACTION_RESULT_EFFECT_GAINED, 99999 }, -- Impact FX
			[178612] = { ACTION_RESULT_EFFECT_FADED , 12500 }, -- Climbing FX
			afterlife = 172552,
		},
		banners = {
			[170362] = 0x66CCFFFF, -- Shockwave Bash
			[172484] = 0xFFCC33FF, -- Earthquake Stomp
			[170823] = 0x66CCFFFF, -- Lightning Pillar (Human)
			[179139] = 0x66CCFFFF, -- Lightning Pillar (Bear)
		},
		purgeables = {
			[173406] = true, -- Crippling Grasp
			[179212] = true, -- Crippling Grasp
		},
		standingInAoe = {
			-- { alert_duration, exclude_tanks }
			[171400] = { 1200, false }, -- Corrupted Pulp
			[172166] = { 400, false }, -- Necrotic Wake
		},
	},
}
