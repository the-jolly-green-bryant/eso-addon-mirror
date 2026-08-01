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
		[1344] = true, -- Dreadsail Reef
		[1361] = true, -- Graven Deep
		[1389] = true, -- Bal Sunnar
		[1390] = true, -- Scrivener's Hall
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
			[102107] = { -2, 2 }, -- Moon Hunter Keep -- Crushing Leap
			[103951] = { -2, 2 }, -- Moon Hunter Keep -- Lunge (Dire Wolf)
			[103994] = { -2, 2 }, -- Moon Hunter Keep -- Rending Slash
			[105324] = { -2, 2 }, -- Moon Hunter Keep -- Devastating Leap
			[106808] = { -2, 2 }, -- March of Sacrifices -- Ravaging Blow (Dagrund the Bulky)
			[106885] = { -2, 2 }, -- March of Sacrifices -- Crushing Limbs
			[107323] = { -3, 2 }, -- March of Sacrifices -- Horn Burst
			[107697] = { -2, 2 }, -- March of Sacrifices -- Power Bash
			[107711] = { -2, 2 }, -- March of Sacrifices -- Shield Charge
			[108152] = { -2, 2 }, -- March of Sacrifices -- Dire Lunge
			[108155] = { -2, 2 }, -- March of Sacrifices -- Crushing Leap
			[108569] = { -2, 2 }, -- March of Sacrifices -- Ravaging Blow (Bloodscent Thundermaul)
			[103587] = { -2, 2 }, -- Moon Hunter Keep -- Shred
			[105494] = { -2, 2 }, -- Moon Hunter Keep -- Crushing Limbs
			[110225] = { -2, 2 }, -- Moon Hunter Keep -- Crushing Leap
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
			[158778] = { 0, 0, false, { 1, 0, 0.6, 0.8 } }, -- Coral Aerie -- Obliterate

			[163987] = { -2, 2 }, -- Dreadsail Reef -- Coral Slam
			[166019] = { -2, 2 }, -- Dreadsail Reef -- Crush
			[166020] = { -2, 2 }, -- Dreadsail Reef -- Claw
			[166582] = { -2, 2 }, -- Dreadsail Reef -- Monstrous Claw
			[166586] = { -2, 2 }, -- Dreadsail Reef -- Crackdown
			[167273] = { -2, 0, false, { 1, 0, 0.6, 0.8 }, offset = -875 }, -- Dreadsail Reef -- Broiling Hew
			[167280] = { -2, 0, false, { 1, 0, 0.6, 0.8 }, offset = -875 }, -- Dreadsail Reef -- Stinging Shear
			[169096] = { -2, 0, false, { 1, 0, 0.6, 0.8 }, offset = -1900 }, -- Dreadsail Reef -- Concussive Blow
			[169253] = { -2, 0, false, { 1, 0, 0.6, 0.8 }, offset = -1900 }, -- Dreadsail Reef -- Brutal Bash
			[169981] = { -2, 2 }, -- Dreadsail Reef -- Whirling Dervish
			[169991] = { -2, 2 }, -- Dreadsail Reef -- Wing Slice
			[170184] = { -2, 2 }, -- Dreadsail Reef -- Uppercut
			[170188] = { -2, 1 }, -- Dreadsail Reef -- Cascading Boot
			[170192] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Dreadsail Reef -- Shield Slam
			[174607] = { -3, 2, true }, -- Dreadsail Reef -- Taking Aim
		--	[164158] = { -2, 0 }, -- Dreadsail Reef -- Crush
		--	[164160] = { -2, 0 }, -- Dreadsail Reef -- Strike
		--	[164162] = { -2, 0 }, -- Dreadsail Reef -- Hack
		--	[164164] = { -2, 0 }, -- Dreadsail Reef -- Drowning Strike

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

			[176988] = { -2, 2 }, -- Bal Sunnar -- Bisect (Boss)
			[176989] = { -2, 2 }, -- Bal Sunnar -- Bisect
			[179945] = { 0, 0, false, { 1, 0, 0.6, 0.8 } }, -- Bal Sunnar -- Plague Bomb
			[181469] = { -2, 2 }, -- Bal Sunnar -- Gore
			[182386] = { -2, 2 }, -- Bal Sunnar -- Interpose

			[180921] = { -2, 2 }, -- Scrivener's Hall -- Chaw
			[182139] = { -2, 2 }, -- Scrivener's Hall -- Eviscerate
			[184768] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Scrivener's Hall -- Mangle
			[184797] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Scrivener's Hall -- Crypt Smash
			[184750] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Scrivener's Hall -- Dual Strike
			[184810] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Scrivener's Hall -- Crackdown
			[184816] = { -2, 0, false, { 1, 0, 0.6, 0.8 } }, -- Scrivener's Hall -- Chin Shatter
			[183089] = { -2, 2, offset = -1900 }, -- Scrivener's Hall -- Brutal Bash


			-- Taking Aim
			[70695] = { -3, 2, true }, -- Maelstrom Arena
			[74978] = { -3, 2, true }, -- Craglorn / Dragonstar Arena
			[76848] = { -3, 2, true }, -- Ruins of Mazzatun
			[78781] = { -3, 2, true },
			[100947] = { -3, 2, true }, -- Scalecaller Peak
			[101651] = { -3, 2, true },
			[105303] = { -3, 2, true }, -- March of Sacrifices / Moon Hunter Keep
			[107654] = { -3, 2, true }, -- March of Sacrifices (Wyress Strigidae)
			[108397] = { -3, 2, true },

			-- Misc
			[52825] = { -3, 2, true }, -- Dragonstar Arena -- Lethal Arrow
			[92892] = { -2, 2 }, -- Falkreath Hold / Fang Lair -- Clash of Bones
			[107955] = { -2, 1 }, -- March of Sacrifices -- Slaughtering Strike
			[108564] = { -3, 2 }, -- March of Sacrifices -- Fetid Globule
			[111420] = { -3, 1, true }, -- March of Sacrifices -- Trapping Bolt
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
		banefulName = GetFormattedAbilityName(107872),
		flare = {
			[103531] = true,
			[110431] = true,
			execute = 110431,
		},
		flareName = GetFormattedAbilityName(103531),
		flareDuration = 6500, -- 2500ms cast time + 4000ms duration
		sparkles = 105780,
		zmaja = "z'maja",
		crushing = 105239,
		crushingName = GetFormattedAbilityName(105205),
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
		beadName = GetFormattedAbilityName(105371),
	},


	-- March of Sacrifices -----------------------------------------------------
	march = {
		fireId = 112386,
		hardHealth = 6300000, -- 5645195 non-HM, 6491974 HM (pre-U35: 6272440 non-HM, 7213306 HM)
		water = {
			name = GetFormattedAbilityName(107624), -- Electric Water
			color = 0x66CCFFFF,
		},
		venom = {
			name = GetFormattedAbilityName(107777), -- Venomous Spores
			color = 0x00CC00FF,
		},
		[106541] = "water", -- Thunder Stomp
		[106727] = "venom", -- Venomous Slam
		[107624] = "water", -- Electric Water
		[107740] = "venom", -- Venom Slam
	},


	-- Moon Hunter Keep --------------------------------------------------------
	moonhunter = {
		root = 104196,
		pounce = 104863,
		switch = 113626,
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
		meteorName = GetFormattedAbilityName(117249),
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
			spawnText = GetFormattedAbilityName(136622),
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


	-- Dreadsail Reef ----------------------------------------------------------
	dsr = {
		zone = 1344,
		targeted = 170523,
		cinderShot = 170392,
		marksman = {
			target = 170434,
			damage = 170438,
		},
		twinsColors = {
			0xFF6600,
			0x66CCFF,
		},
		multi = {
			[166745] = true, -- Turlassil MultiLoc
			[166909] = true, -- Lylanar MultiLoc
		},
		imminent = {
			[166522] = true, -- Imminent Blister
			[166527] = true, -- Imminent Chill
		},
		summon = {
			[168817] = 0xFFCC00FF, -- Incendiary Axe
			[168912] = 0x3399FFFF, -- Calamitous Sword
			[166928] = 0x66CCFFFF, -- Summon Behemoth
			[166929] = 0x9966FFFF, -- Summon Siren
		},
		summon2 = {
			[168713] = 0xFF6600FF, -- Summon Iron Atronach
			[168722] = 0x66CCFFFF, -- Summon Frost Atronach
		},
		summon3 = {
			[167763] = 0xFF6600FF, -- Summon Iron Atronach
			[167900] = 0x66CCFFFF, -- Summon Frost Atronach
		},
		dome = {
			ice = 166192,
			fire = 166210,
			[166192] = 1, -- Piercing Hailstone
			[166210] = 2, -- Destructive Ember
		},
		brands = {
			start = 166355,
			[166358] = "fire", -- Firebrand
			[166445] = "frost", -- Frostbrand
			removal = {
				[166472] = true, -- Firebrand
				[166482] = true, -- Frostbrand
			},
			["fire"] = "frost",
			["frost"] = "fire",
			hmHealth = 50000000,
		},
		replication = 163701,
		heartburn = 170481,
		heartburnResult = {
			[166031] = { color = 0x00FF00, text = GetString(SI_LCA_SUCCESS) }, -- Heartburn Vulnerability
			[166032] = { color = 0xFF0000, text = GetString(SI_LCA_FAIL) }, -- Heartburn Empowerment
		},
		deluge = {
			start = 167124,
			icon = 174966,
			colorSelf = 0x3399FFFF,
			colorOthers = 0xBBDDFFFF,
			[174959] = true, -- Normal
			[174960] = true, -- Veteran
			[174961] = true, -- Hard Mode
			damage = {
				[174964] = true, -- Normal
				[174966] = true, -- Veteran
				[174969] = true, -- Hard Mode
			},
		},
		storm = {
			name = 174865,
			tracker = 174891,
			[175447] = 1,
			[174866] = -1,
		},
		bridge = {
			platform = 167704,
			stop = 169297,
			summons = {
				[166479] = 1, -- Summon Channelers (50%)
				[175279] = 2, -- Summon Channelers (35%)
				[175291] = 3, -- Summon Channelers (20%)
			},
			channelers = {
				[175134] = 0xFFFF00FF, -- Sweltering Heat
				[175132] = 0x00CC00FF, -- Nematocyst Cloud
				[175136] = 0xCC00CCFF, -- Suffocating Waves
			},
			channels = {
				[165994] = 0xFFFF00, -- Sweltering Heat
				[166042] = 0x00CC00, -- Nematocyst Cloud
				[166044] = 0xCC00CC, -- Suffocating Waves
			},
		},
		maelstrom = 166292,
		wave = {
			start = 166353,
			target = 174943,
			damage = 174948,
		},
		standingInAoe = {
			-- { alert_duration, exclude_tanks }
			[163896] = { 1100, false }, -- Whirlpool
			[165987] = { 1100, true }, -- Acid Pool
			[168619] = { 600, true }, -- Frigid Blood
			[168625] = { 600, true }, -- Blazing Bead
			[175172] = { 1000, true }, -- Arcing Slash
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


	-- Scribes of Fate ---------------------------------------------------------
	u37 = {
		manipulate = 182465,
		verge = {
			boss = 177646,
			shade = 177942,
			name = GetFormattedAbilityName(177660) .. " (<<1>>)",
		},
		darklight = {
			start = 177112,
			star = 177228,
			name = GetFormattedAbilityName(177235)
		},
		summonNix = 177573,
		choking = 182495,

		effusion = 182041,
		bash = 182014,
		slash = 181739,
		hellfire = 184602,
		parasite = 181185,
		parasiteSack = 181244,
		ironAtro = 183117,
		thirst = 182214,
		web = 179938,
		trapTrip = 183080,
		trapName = GetFormattedAbilityName(182393),
		meteor = {
			start = 185833,
			damage = 185834,
			timer = 3000,
		},

		banners = {
			[182334] = 0xFF6600FF, -- Rain of Fire
			[182355] = 0xFF0000FF, -- Ignite
			[182393] = 0xFFCC00FF, -- Immolation Trap
			[184441] = 0xCC33FFFF, -- Summon Entangler
			[182670] = 0x00CC00FF, -- Plague of Insects
			[177345] = 0x99FF99FF, -- Plague of Insects (Choking Pestilence)
		},
		standingInAoe = {
			-- { alert_duration, exclude_tanks }
			[189528] = { 300, false }, -- Fold
			[189537] = { 300, false }, -- Fold
		},
	},

}
