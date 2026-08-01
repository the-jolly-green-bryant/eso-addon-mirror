TraitBuddyData = {}
local ITEMSTYLE_GRIMHARLEQUIN = ITEMSTYLE_GRIMHARLEQUIN or 58 --ITEMSTYLE_UNUSED21
local ITEMSTYLE_HOLLOWJACK = ITEMSTYLE_HOLLOWJACK or 59 --ITEMSTYLE_UNUSED22
local traitMaterials = {
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] = 23203, --Chysolite
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 23204, --Amethyst
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 4486, --Ruby
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 810, --Jade
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 813, --Turquoise
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 23165, --Carnelian
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 23149, --Fire Opal
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 16291, --Citrine
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 56863, --Potent Nirncrux
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] = 4456, --Quartz
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 23219, --Diamond
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 30221, --Sardonyx
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 23221, --Almandine
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 4442, --Emerald
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 30219, --Bloodstone
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = 23171, --Garnet
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 23173, --Sapphire
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 56862 --Fortified Nirncrux
}
local itemStyleMaterial = {
	[ITEMSTYLE_RACIAL_HIGH_ELF] = {id=33252, icon=""}, --Adamantite
	[ITEMSTYLE_RACIAL_DARK_ELF] = {id=33253, icon=""}, --Obsidian
	[ITEMSTYLE_RACIAL_WOOD_ELF] = {id=33194, icon=""}, --Bone
	[ITEMSTYLE_RACIAL_NORD] = {id=33256, icon=""}, --Corundum
	[ITEMSTYLE_RACIAL_BRETON] = {id=33251, icon=""}, --Molybdenum
	[ITEMSTYLE_RACIAL_REDGUARD] = {id=33258, icon=""}, --Starmetal
	[ITEMSTYLE_RACIAL_KHAJIIT] = {id=33255, icon=""}, --Moonstone
	[ITEMSTYLE_RACIAL_ORC] = {id=33257, icon=""}, --Manganese
	[ITEMSTYLE_RACIAL_ARGONIAN] = {id=33150, icon=""}, --Flint
	[ITEMSTYLE_RACIAL_IMPERIAL] = {id=33254, icon=""}, --Nickel
	[ITEMSTYLE_AREA_ANCIENT_ELF] = {id=46152, icon=""}, --Palladium
	[ITEMSTYLE_AREA_REACH] = {id=46149, icon=""}, --Barbaric, Copper
	[ITEMSTYLE_ENEMY_PRIMITIVE] = {id=46150, icon=""}, --Primal, Argentum
	[ITEMSTYLE_ENEMY_DAEDRIC] = {id=46151, icon=""}, --Daedra Heart
	[ITEMSTYLE_AREA_DWEMER] = {id=57587, icon=""}, --Dwemer Frame
	[ITEMSTYLE_GLASS] = {id=64689, icon=""}, --Malachite
	[ITEMSTYLE_AREA_XIVKYN] = {id=59922, icon=""}, --Charcoal of Remorse
	[ITEMSTYLE_AREA_AKAVIRI] = {id=64687, icon=""}, --Gold Scale
	[ITEMSTYLE_UNDAUNTED] = {id=64713, icon=""}, --Laurel
	[ITEMSTYLE_AREA_ANCIENT_ORC] = {id=69555, icon=""}, --Cassiterite Sand
	[ITEMSTYLE_DEITY_TRINIMAC] = {id=71582, icon=""}, --Auric Tusk
	[ITEMSTYLE_DEITY_MALACATH] = {id=71584, icon=""}, --Potash
	[ITEMSTYLE_ORG_OUTLAW] = {id=71538, icon=""}, --Rogues Soot
	[ITEMSTYLE_ALLIANCE_ALDMERI] = {id=71738, icon=""}, --Eagle Feather
	[ITEMSTYLE_ALLIANCE_DAGGERFALL] = {id=71742, icon=""}, --Lion Fang
	[ITEMSTYLE_ALLIANCE_EBONHEART] = {id=71740, icon=""}, --Dragon Scute
	[ITEMSTYLE_AREA_SOUL_SHRIVEN] = {id=71766, icon=""}, --Azure Plasm
	[ITEMSTYLE_UNIVERSAL] = {id=71668, icon=""}, --Crown Mimic Stone
	[ITEMSTYLE_ORG_ABAHS_WATCH] = {id=76914, icon=""}, --Polished Shilling
	[ITEMSTYLE_ORG_THIEVES_GUILD] = {id=75370, icon=""}, --Fine Chalk
	[ITEMSTYLE_ORG_ASSASSINS] = {id=76910, icon=""}, --Tainted Blood
	[ITEMSTYLE_ENEMY_DROMOTHRA] = {id=79672, icon=""}, --Defiled Whiskers
	[ITEMSTYLE_ORG_DARK_BROTHERHOOD] = {id=79304, icon=""}, --Black Beeswax
	[ITEMSTYLE_ENEMY_MINOTAUR] = {id=81994, icon=""}, --Oxblood Fungus
	[ITEMSTYLE_DEITY_AKATOSH] = {id=81996, icon=""}, --Pearl Sand
	[ITEMSTYLE_AREA_YOKUDAN] = {id=64685, icon=""}, --Ferrous Salts
	[ITEMSTYLE_ENEMY_DRAUGR] = {id=75373, icon=""}, --Pristine Shroud
	[ITEMSTYLE_RAIDS_CRAGLORN] = {id=81998, icon=""}, --Star Sapphire
	[ITEMSTYLE_ENEMY_SKINCHANGER] = {id=96388, icon=""}, --Wolfsbane Incense
	[ITEMSTYLE_GRIMHARLEQUIN] = {id=82002, icon=""}, --Grinstones
	[ITEMSTYLE_HOLLOWJACK] = {id=82000, icon=""} --Amber Marble
}

local motifs = {
	[1] = {id=16424, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_HIGH_ELF, icon="esoui/art/charactercreate/charactercreate_altmericon_up.dds"},
	[2] = {id=27245, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_DARK_ELF, icon="esoui/art/charactercreate/charactercreate_dunmericon_up.dds"},
	[3] = {id=16428, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_WOOD_ELF, icon="esoui/art/charactercreate/charactercreate_bosmericon_up.dds"},
	[4] = {id=27244, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_NORD, icon="esoui/art/charactercreate/charactercreate_nordicon_up.dds"},
	[5] = {id=16425, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_BRETON, icon="esoui/art/charactercreate/charactercreate_bretonicon_up.dds"},
	[6] = {id=16427, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_REDGUARD, icon="esoui/art/charactercreate/charactercreate_redguardicon_up.dds"},
	[7] = {id=44698, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_KHAJIIT, icon="esoui/art/charactercreate/charactercreate_khajiiticon_up.dds"},
	[8] = {id=16426, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_ORC, icon="esoui/art/charactercreate/charactercreate_orcicon_up.dds"},
	[9] = {id=27246, quality=ITEM_QUALITY_ARCANE, style=ITEMSTYLE_RACIAL_ARGONIAN, icon="esoui/art/charactercreate/charactercreate_argonianicon_up.dds"},
	[10]= {id=54868, quality=ITEM_QUALITY_LEGENDARY, style=ITEMSTYLE_RACIAL_IMPERIAL, icon="esoui/art/charactercreate/charactercreate_imperialicon_up.dds"},
	[11]= {id=51638, quality=ITEM_QUALITY_ARTIFACT, style=ITEMSTYLE_AREA_ANCIENT_ELF, icon="esoui/art/icons/gear_ancient_elf_heavy_head_a.dds"},
	[12]= {id=51565, quality=ITEM_QUALITY_ARTIFACT, style=ITEMSTYLE_AREA_REACH, icon="esoui/art/icons/gear_reach_heavy_head_a.dds"}, --Barbaric
	[13]= {id=51345, quality=ITEM_QUALITY_ARTIFACT, style=ITEMSTYLE_ENEMY_PRIMITIVE, icon="esoui/art/icons/gear_primative_heavy_head_a.dds"}, --Primal
	[14]= {id=51688, quality=ITEM_QUALITY_ARTIFACT, style=ITEMSTYLE_ENEMY_DAEDRIC, icon="esoui/art/icons/gear_daedric_heavy_head_a.dds"},
	[15]= {
		id=57572,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_AREA_DWEMER,
		icon="esoui/art/icons/gear_dwarven_heavy_head_a.dds",
		[1] =57573, --Axes
		[2] =57574, --Belts
		[3] =57575, --Boots
		[4] =57576, --Bows
		[5] =57577, --Chests
		[6] =57578, --Daggers
		[7] =57579, --Gloves
		[8] =57580, --Helmets
		[9] =57581, --Legs
		[10]=57582, --Maces
		[11]=57583, --Shields
		[12]=57584, --Shoulders
		[13]=57585, --Staves
		[14]=57586  --Swords
	},
	[16] = {
		id=64669,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_GLASS,
		icon="esoui/art/icons/gear_glass_heavy_head_a.dds",
		[1] =64670, --Axes
		[2] =64671, --Belts
		[3] =64672, --Boots
		[4] =64673, --Bows
		[5] =64674, --Chests
		[6] =64675, --Daggers
		[7] =64676, --Gloves
		[8] =64677, --Helmets
		[9] =64678, --Legs
		[10]=64679, --Maces
		[11]=64680, --Shields
		[12]=64681, --Shoulders
		[13]=64682, --Staves
		[14]=64683  --Swords
	},
	[17] = {
		id=57834,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_AREA_XIVKYN,
		icon="esoui/art/icons/gear_imperialdaedric_heavy_head_a.dds",
		[1] =57835, --Axes
		[2] =57836, --Belts
		[3] =57837, --Boots
		[4] =57838, --Bows
		[5] =57839, --Chests
		[6] =57840, --Daggers
		[7] =57841, --Gloves
		[8] =57842, --Helmets
		[9] =57843, --Legs
		[10]=57844, --Maces
		[11]=57845, --Shields
		[12]=57846, --Shoulders
		[13]=57847, --Staves
		[14]=57848  --Swords
	},
	[18] = {
		id=57590,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_AREA_AKAVIRI,
		icon="esoui/art/icons/gear_akaviri_heavy_head_a.dds",
		[1] =57591, --Axes
		[2] =57592, --Belts
		[3] =57593, --Boots
		[4] =57594, --Bows
		[5] =57595, --Chests
		[6] =57596, --Daggers
		[7] =57597, --Gloves
		[8] =57598, --Helmets
		[9] =57599, --Legs
		[10]=57600, --Maces
		[11]=57601, --Shields
		[12]=57602, --Shoulders
		[13]=57603, --Staves
		[14]=57604  --Swords
	},
	[19] = {
		id=64715,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_UNDAUNTED,
		icon="esoui/art/icons/gear_undaunted_heavy_head_a.dds",
		[1] =64716, --Axes
		[2] =64717, --Belts
		[3] =64718, --Boots
		[4] =64719, --Bows
		[5] =64720, --Chests
		[6] =64721, --Daggers
		[7] =64722, --Gloves
		[8] =64723, --Helmets
		[9] =64724, --Legs
		[10]=64725, --Maces
		[11]=64726, --Shields
		[12]=64727, --Shoulders
		[13]=64728, --Staves
		[14]=64729  --Swords
	},
	[20] = {
		id=57605,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_AREA_YOKUDAN,
		icon="esoui/art/icons/gear_yokudan_heavy_head_a.dds",
		[1] =57606, --Axes
		[2] =57607, --Belts
		[3] =57608, --Boots
		[4] =57609, --Bows
		[5] =57610, --Chests
		[6] =57611, --Daggers
		[7] =57612, --Gloves
		[8] =57613, --Helmets
		[9] =57614, --Legs
		[10]=57615, --Maces
		[11]=57616, --Shields
		[12]=57617, --Shoulders
		[13]=57618, --Staves
		[14]=57619  --Swords
	},
	[21] = {
		id=69527,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_AREA_ANCIENT_ORC,
		icon="esoui/art/icons/gear_wrothgarorc_heavy_head_a.dds",
		[1] =69528, --Axes
		[2] =69529, --Belts
		[3] =69530, --Boots
		[4] =69531, --Bows
		[5] =69532, --Chests
		[6] =69533, --Daggers
		[7] =69534, --Gloves
		[8] =69535, --Helmets
		[9] =69536, --Legs
		[10]=69537, --Maces
		[11]=69538, --Shields
		[12]=69539, --Shoulders
		[13]=69540, --Staves
		[14]=69541  --Swords
	},
	[22] = {
		id=71550,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_DEITY_TRINIMAC,
		icon="esoui/art/icons/gear_trinimac_heavy_head_a.dds",
		[1] =71551, --Axes
		[2] =71552, --Belts
		[3] =71553, --Boots
		[4] =71554, --Bows
		[5] =71555, --Chests
		[6] =71556, --Daggers
		[7] =71557, --Gloves
		[8] =71558, --Helmets
		[9] =71559, --Legs
		[10]=71560, --Maces
		[11]=71561, --Shields
		[12]=71562, --Shoulders
		[13]=71563, --Staves
		[14]=71564  --Swords
	},
	[23] = {
		id=71566,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_DEITY_MALACATH,
		icon="esoui/art/icons/gear_malacath_heavy_head_a.dds",
		[1] =71567, --Axes
		[2] =71568, --Belts
		[3] =71569, --Boots
		[4] =71570, --Bows
		[5] =71571, --Chests
		[6] =71572, --Daggers
		[7] =71573, --Gloves
		[8] =71574, --Helmets
		[9] =71575, --Legs
		[10]=71576, --Maces
		[11]=71577, --Shields
		[12]=71578, --Shoulders
		[13]=71579, --Staves
		[14]=71580  --Swords
	},
	[24] = {
		id=71522,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ORG_OUTLAW,
		icon="esoui/art/icons/gear_thievesguildheavy_head_a.dds",
		[1] =71523, --Axes
		[2] =71524, --Belts
		[3] =71525, --Boots
		[4] =71526, --Bows
		[5] =71527, --Chests
		[6] =71528, --Daggers
		[7] =71529, --Gloves
		[8] =71530, --Helmets
		[9] =71531, --Legs
		[10]=71532, --Maces
		[11]=71533, --Shields
		[12]=71534, --Shoulders
		[13]=71535, --Staves
		[14]=71536  --Swords
	},
	[25] = {
		id=71688,
		quality=ITEM_QUALITY_ARTIFACT,
		style = ITEMSTYLE_ALLIANCE_ALDMERI, --Dominion
		icon="esoui/art/icons/gear_aldmeri_heavy_head_a.dds",
		[1] =71689, --Axes
		[2] =71690, --Belts
		[3] =71691, --Boots
		[4] =71692, --Bows
		[5] =71693, --Chests
		[6] =71694, --Daggers
		[7] =71695, --Gloves
		[8] =71696, --Helmets
		[9] =71697, --Legs
		[10]=71698, --Maces
		[11]=71699, --Shields
		[12]=71700, --Shoulders
		[13]=71701, --Staves
		[14]=71702  --Swords
	},
	[26] = {
		id=71704,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ALLIANCE_DAGGERFALL, --Covenant
		icon="esoui/art/icons/gear_daggerfall_heavy_head_a.dds",
		[1] =71705, --Axes
		[2] =71706, --Belts
		[3] =71707, --Boots
		[4] =71708, --Bows
		[5] =71709, --Chests
		[6] =71710, --Daggers
		[7] =71711, --Gloves
		[8] =71712, --Helmets
		[9] =71713, --Legs
		[10]=71714, --Maces
		[11]=71715, --Shields
		[12]=71716, --Shoulders
		[13]=71717, --Staves
		[14]=71718  --Swords
	},
	[27] = {
		id=71720,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ALLIANCE_EBONHEART, --Pact
		icon="esoui/art/icons/gear_ebonheart_heavy_head_a.dds",
		[1] =71721, --Axes
		[2] =71722, --Belts
		[3] =71723, --Boots
		[4] =71724, --Bows
		[5] =71725, --Chests
		[6] =71726, --Daggers
		[7] =71727, --Gloves
		[8] =71728, --Helmets
		[9] =71729, --Legs
		[10]=71730, --Maces
		[11]=71731, --Shields
		[12]=71732, --Shoulders
		[13]=71733, --Staves
		[14]=71734  --Swords
	},
	[29] = {id=71765, quality=ITEM_QUALITY_LEGENDARY, style=ITEMSTYLE_AREA_SOUL_SHRIVEN, icon="esoui/art/icons/gear_soulshriven_head_a.dds" }, --Soul-Shriven
	[31] = {
		id=73854,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ENEMY_SKINCHANGER,
		icon="esoui/art/icons/gear_skinchanger_heavy_head_a.dds",
		[1] =73855, --Axes
		[2] =73856, --Belts
		[3] =73857, --Boots
		[4] =73858, --Bows
		[5] =73859, --Chests
		[6] =73860, --Daggers
		[7] =73861, --Gloves
		[8] =73862, --Helmets
		[9] =73863, --Legs
		[10]=73864, --Maces
		[11]=73865, --Shields
		[12]=73866, --Shoulders
		[13]=73867, --Staves
		[14]=73868  --Swords
	},
	[32] = {
		id=74539,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ORG_ABAHS_WATCH,
		icon="esoui/art/icons/gear_abahswatch_heavy_head_a.dds",
		[1] =74540, --Axes
		[2] =74541, --Belts
		[3] =74542, --Boots
		[4] =74543, --Bows
		[5] =74544, --Chests
		[6] =74545, --Daggers
		[7] =74546, --Gloves
		[8] =74547, --Helmets
		[9] =74548, --Legs
		[10]=74549, --Maces
		[11]=74550, --Shields
		[12]=74551, --Shoulders
		[13]=74552, --Staves
		[14]=74553  --Swords
	},
	[33] = {
		id=74555,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ORG_THIEVES_GUILD,
		icon="esoui/art/icons/gear_thievesguildv2_heavy_head_a.dds",
		[1] =74556, --Axes
		[2] =74557, --Belts
		[3] =74558, --Boots
		[4] =74559, --Bows
		[5] =74560, --Chests
		[6] =74561, --Daggers
		[7] =74562, --Gloves
		[8] =74563, --Helmets
		[9] =74564, --Legs
		[10]=74565, --Maces
		[11]=74566, --Shields
		[12]=74567, --Shoulders
		[13]=74568, --Staves
		[14]=74569  --Swords
	},
	[34] = {
		id=76878,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ORG_ASSASSINS, --Assassins League
		icon="esoui/art/icons/gear_darkbrotherhood_heavy_head_a.dds",
		[1] =76879, --Axes
		[2] =76880, --Belts
		[3] =76881, --Boots
		[4] =76882, --Bows
		[5] =76883, --Chests
		[6] =76884, --Daggers
		[7] =76885, --Gloves
		[8] =76886, --Helmets
		[9] =76887, --Legs
		[10]=76888, --Maces
		[11]=76889, --Shields
		[12]=76890, --Shoulders
		[13]=76891, --Staves
		[14]=76892  --Swords
	},
	[35] = {
		id=74652,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ENEMY_DROMOTHRA, --Dro-M'Athra
		icon="esoui/art/icons/gear_dromathra_heavy_head_a.dds",
		[1] =74653, --Axes
		[2] =74654, --Belts
		[3] =74655, --Boots
		[4] =74656, --Bows
		[5] =74657, --Chests
		[6] =74658, --Daggers
		[7] =74659, --Gloves
		[8] =74660, --Helmets
		[9] =74661, --Legs
		[10]=74662, --Maces
		[11]=74663, --Shields
		[12]=74664, --Shoulders
		[13]=74665, --Staves
		[14]=74666  --Swords
	},
	[36] = {
		id=82054,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ORG_DARK_BROTHERHOOD,
		icon="esoui/art/icons/gear_darkbrotherhoodv2_heavy_head_a.dds",
		[1] =82055, --Axes
		[2] =82056, --Belts
		[3] =82057, --Boots
		[4] =82058, --Bows
		[5] =82059, --Chests
		[6] =82060, --Daggers
		[7] =82061, --Gloves
		[8] =82062, --Helmets
		[9] =82063, --Legs
		[10]=82064, --Maces
		[11]=82065, --Shields
		[12]=82066, --Shoulders
		[13]=82067, --Staves
		[14]=82068  --Swords
	},
	[37] = {
		id=76894,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ENEMY_DRAUGR,
		icon="esoui/art/icons/gear_draugr_heavy_head_a.dds",
		[1] =76895, --Axes
		[2] =76896, --Belts
		[3] =76897, --Boots
		[4] =76898, --Bows
		[5] =76899, --Chests
		[6] =76900, --Daggers
		[7] =76901, --Gloves
		[8] =76902, --Helmets
		[9] =76903, --Legs
		[10]=76904, --Maces
		[11]=76905, --Shields
		[12]=76906, --Shoulders
		[13]=76907, --Staves
		[14]=76908  --Swords
	},
	[39] = {
		id=82071,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_ENEMY_MINOTAUR,
		icon="esoui/art/icons/gear_minotaur_heavy_head_a.dds",
		[1] =82072, --Axes
		[2] =82073, --Belts
		[3] =82074, --Boots
		[4] =82075, --Bows
		[5] =82076, --Chests
		[6] =82077, --Daggers
		[7] =82078, --Gloves
		[8] =82079, --Helmets
		[9] =82080, --Legs
		[10]=82081, --Maces
		[11]=82082, --Shields
		[12]=82083, --Shoulders
		[13]=82084, --Staves
		[14]=82085  --Swords
	},
	[40] = {
		id=82087,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_DEITY_AKATOSH,
		icon="esoui/art/icons/gear_ooth_heavy_head_a.dds",
		[1] =82088, --Axes
		[2] =82089, --Belts
		[3] =82090, --Boots
		[4] =82091, --Bows
		[5] =82092, --Chests
		[6] =82093, --Daggers
		[7] =82094, --Gloves
		[8] =82095, --Helmets
		[9] =82096, --Legs
		[10]=82097, --Maces
		[11]=82098, --Shields
		[12]=82099, --Shoulders
		[13]=82100, --Staves
		[14]=82101  --Swords
	},
	[41] = {
		id=82006,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_RAIDS_CRAGLORN, --Celestrial
		icon="esoui/art/icons/gear_craglorn_heavy_head_a.dds",
		[1] =82007, --Axes
		[2] =82008, --Belts
		[3] =82009, --Boots
		[4] =82010, --Bows
		[5] =82011, --Chests
		[6] =82012, --Daggers
		[7] =82013, --Gloves
		[8] =82014, --Helmets
		[9] =82015, --Legs
		[10]=82016, --Maces
		[11]=82017, --Shields
		[12]=82018, --Shoulders
		[13]=82019, --Staves
		[14]=82020  --Swords
	},
	[42] = {
		id=82022,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_HOLLOWJACK,
		icon="esoui/art/icons/gear_hallowjack_heavy_head_a.dds",
		[1] =82023, --Axes
		[2] =82024, --Belts
		[3] =82025, --Boots
		[4] =82026, --Bows
		[5] =82027, --Chests
		[6] =82028, --Daggers
		[7] =82029, --Gloves
		[8] =82030, --Helmets
		[9] =82031, --Legs
		[10]=82032, --Maces
		[11]=82033, --Shields
		[12]=82034, --Shoulders
		[13]=82035, --Staves
		[14]=82036  --Swords
	},
	[43] = {
		id=82038,
		quality=ITEM_QUALITY_ARTIFACT,
		style=ITEMSTYLE_GRIMHARLEQUIN,
		icon="esoui/art/icons/gear_grimharlequin_heavy_head_a.dds",
		[1] =82039, --Axes
		[2] =82040, --Belts
		[3] =82041, --Boots
		[4] =82042, --Bows
		[5] =82043, --Chests
		[6] =82044, --Daggers
		[7] =82045, --Gloves
		[8] =82046, --Helmets
		[9] =82047, --Legs
		[10]=82048, --Maces
		[11]=82049, --Shields
		[12]=82050, --Shoulders
		[13]=82051, --Staves
		[14]=82052  --Swords
	},
}

--Chapter to motif book order
local chapterOrder = {
	[ITEM_STYLE_CHAPTER_AXES] = 1,
	[ITEM_STYLE_CHAPTER_BELTS] = 2,
	[ITEM_STYLE_CHAPTER_BOOTS] = 3,
	[ITEM_STYLE_CHAPTER_BOWS] = 4,
	[ITEM_STYLE_CHAPTER_CHESTS] = 5,
	[ITEM_STYLE_CHAPTER_DAGGERS] = 6,
	[ITEM_STYLE_CHAPTER_GLOVES] = 7,
	[ITEM_STYLE_CHAPTER_HELMETS] = 8,
	[ITEM_STYLE_CHAPTER_LEGS] = 9,
	[ITEM_STYLE_CHAPTER_MACES] = 10,
	[ITEM_STYLE_CHAPTER_SHIELDS] = 11,
	[ITEM_STYLE_CHAPTER_SHOULDERS] = 12,
	[ITEM_STYLE_CHAPTER_STAVES] = 13,
	[ITEM_STYLE_CHAPTER_SWORDS] = 14
}

local function TableEntries(tbl)
	local i = 0
	for k,v in pairs(tbl) do
		i = i + 1
	end
	return i
end

function TraitBuddyData:GetTraitMaterialIDs()
	return traitMaterials
end
function TraitBuddyData:GetMotif(index)
	return motifs[index]
end
function TraitBuddyData:GetMotifs()
	return motifs
end
function TraitBuddyData:GetNumMotifs()
	return TableEntries(motifs)
end
function TraitBuddyData:GetNumChapters()
	return TableEntries(chapterOrder)
end
function TraitBuddyData:GetMotifOrder(itemStyle)
	for k,v in pairs(motifs) do
		if v.style == itemStyle then
			return k
		end
	end
	return nil
end
function TraitBuddyData:GetChapterOrder(chapterIndex)
	if chapterOrder[chapterIndex] then
		return chapterOrder[chapterIndex]
	else
		return ITEM_STYLE_CHAPTER_ALL
	end
end
function TraitBuddyData:GetItemStyleMaterial(itemStyle)
	if itemStyleMaterial[itemStyle] then
		return itemStyleMaterial[itemStyle]
	else
		return 0
	end
end
function TraitBuddyData:MotifHasChapters(order)
	if order then
		if motifs[order][1] then
			return true
		else
			return false
		end
	else
		return false
	end
end
function TraitBuddyData:GetMotifStyle(itemLink)
	--Game does not often give the style from GetItemLinkItemStyle and never the chapter
	--Returns: style, chapter, motifOrder, chapterOrder
	local itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
	itemId = tonumber(itemId)
	for k,v in pairs(motifs) do
		if TraitBuddyData:MotifHasChapters(k) then
			for chapter,order in pairs(chapterOrder) do
				if itemId == v[order] then
					return v.style, chapter, k, order
				end
			end
		else
			if itemId == v.id then
				return v.style, ITEM_STYLE_CHAPTER_ALL, k, nil
			end
		end
	end
	return ITEMSTYLE_NONE, ITEM_STYLE_CHAPTER_ALL, nil, nil
end
function TraitBuddyData:Init()
	for styleItemIndex=1, GetNumSmithingStyleItems() do
		--Returns: itemName, icon, sellPrice, meetsUsageRequirement, itemStyle, quality
		local _, icon, _, _, itemStyle, _ = GetSmithingStyleItemInfo(styleItemIndex)
		if itemStyle ~= ITEMSTYLE_NONE then
			if itemStyleMaterial[itemStyle] then
				itemStyleMaterial[itemStyle].icon = icon
			end
		end
	end
	--[[
	if GetAPIVersion() < 100017 then --Before One Tamriel
		itemStyleMaterial[ITEMSTYLE_AREA_YOKUDAN]=nil
		motifs[20]=nil
	end
	]]--
end
TraitBuddyData:Init()