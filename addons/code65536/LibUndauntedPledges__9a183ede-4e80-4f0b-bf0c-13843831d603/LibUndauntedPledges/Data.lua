local LUP = LibUndauntedPledges

LUP.IDS = {
	-- { zoneId, questId, activityIdN, activityIdV }
	[LUP.BASE1] = {
		{ 144, 5260,   3, 315 }, -- Spindleclutch I
		{ 930, 5275, 308,  21 }, -- Darkshade Caverns II
		{ 126, 5276,   7,  23 }, -- Elden Hollow I
		{ 933, 5282,  22, 307 }, -- Wayrest Sewers II
		{ 283, 5247,   2, 299 }, -- Fungal Grotto I
		{ 935, 5246, 300, 301 }, -- The Banished Cells II
		{  63, 5274,   5, 309 }, -- Darkshade Caverns I
		{ 931, 5277, 303, 302 }, -- Elden Hollow II
		{ 146, 5278,   6, 306 }, -- Wayrest Sewers I
		{ 936, 5273, 316,  19 }, -- Spindleclutch II
		{ 380, 5244,   4,  20 }, -- The Banished Cells I
		{ 934, 5248,  18, 312 }, -- Fungal Grotto II
	},
	[LUP.BASE2] = {
		{ 176, 5290,  10, 310 }, -- City of Ash I
		{ 131, 5301,  13, 311 }, -- Tempest Island
		{  38, 5305,  15, 321 }, -- Blackheart Haven
		{ 148, 5288,   8, 305 }, -- Arx Corinium
		{  31, 5307,  16, 313 }, -- Selene's Web
		{ 681, 5381, 322, 267 }, -- City of Ash II
		{ 130, 5283,   9, 261 }, -- Crypt of Hearts I
		{  22, 5303,  12, 304 }, -- Volenfell
		{  64, 5306,  14, 320 }, -- Blessed Crucible
		{ 449, 5291,  11, 319 }, -- Direfrost Keep
		{  11, 5309,  17, 314 }, -- Vaults of Madness
		{ 932, 5284, 317, 318 }, -- Crypt of Hearts II
	},
	[LUP.DLC1] = {
		{  678, 5382, 289, 268 }, -- Imperial City Prison
		{  843, 5636, 293, 294 }, -- Ruins of Mazzatun
		{  688, 5431, 288, 287 }, -- White-Gold Tower
		{  848, 5780, 295, 296 }, -- Cradle of Shadows
		{  973, 6053, 324, 325 }, -- Bloodroot Forge
		{  974, 6054, 368, 369 }, -- Falkreath Hold
		{ 1009, 6155, 420, 421 }, -- Fang Lair
		{ 1010, 6154, 418, 419 }, -- Scalecaller Peak
		{ 1052, 6187, 426, 427 }, -- Moon Hunter Keep
		{ 1055, 6189, 428, 429 }, -- March of Sacrifices
		{ 1081, 6252, 435, 436 }, -- Depths of Malatar
		{ 1080, 6250, 433, 434 }, -- Frostvault
		{ 1122, 6350, 494, 495 }, -- Moongrave Fane
		{ 1123, 6352, 496, 497 }, -- Lair of Maarselok
		{ 1152, 6415, 618, 504 }, -- Icereach
		{ 1153, 6417, 505, 506 }, -- Unhallowed Grave
		{ 1197, 6506, 507, 508 }, -- Stone Garden
		{ 1201, 6508, 509, 510 }, -- Castle Thorn
		{ 1228, 6577, 591, 592 }, -- Black Drake Villa
		{ 1229, 6579, 593, 594 }, -- The Cauldron
		{ 1267, 6684, 595, 596 }, -- Red Petal Bastion
		{ 1268, 6686, 597, 598 }, -- The Dread Cellar
		{ 1301, 6741, 599, 600 }, -- Coral Aerie
		{ 1302, 6743, 601, 602 }, -- Shipwright's Regret
		{ 1360, 6836, 608, 609 }, -- Earthen Root Enclave
		{ 1361, 6838, 610, 611 }, -- Graven Deep
		{ 1389, 6897, 613, 614 }, -- Bal Sunnar
		{ 1390, 7028, 615, 616 }, -- Scrivener's Hall
		{ 1470, 7106, 638, 639 }, -- Oathsworn Pit
		{ 1471, 7156, 640, 641 }, -- Bedlam Veil
		{ 1496, 7236, 855, 856 }, -- Exiled Redoubt
		{ 1497, 7238, 857, 858 }, -- Lep Seclusa
	},
}

-- Update 45
LUP.CYCLE_START = {
	timestamp = GetTimestampForStartOfDate(2025, 3, 13, false),
	[LUP.BASE1] = 0,
	[LUP.BASE2] = 0,
	[LUP.DLC1] = 0,
}

-- Update 47
if (GetAPIVersion() >= 101047) then
	table.insert(LUP.IDS[LUP.DLC1], { 1551, 7321, 1037, 1038 }) -- Naj-Caldeesh
	table.insert(LUP.IDS[LUP.DLC1], { 1552, 7324, 1039, 1040 }) -- Black Gem Foundry
	LUP.CYCLE_START[LUP.DLC1] = -2
end

do
	local RAW_NAMES = {
		["8290981-0-58826"] = { default = "Maj al-Ragath^F", de = "Maj al-Ragath^F", es = "Maj al-Ragath^F", fr = "Maj al-Ragath^F", jp = "マジ・アルラガス^F", ru = "Мадж аль-Рагат^F", zh = "玛吉·阿尔拉加斯^F" },
		["8290981-0-58841"] = { default = "Glirion the Redbeard^M", de = "Glirion der Rotbart^M", es = "Glirion el Barbarroja^M", fr = "Glirion Barbe-Rousse^M", jp = "赤髭グリリオン^M", ru = "Глирион Рыжебородый^M", zh = "红胡子格利里恩^M" },
		["8290981-0-74695"] = { default = "Urgarlag Chief-bane", de = "Urgarlag Häuptlingsfluch^F", es = "Urgarlag la Castradora^F", fr = "Urgarlag l'Émasculatrice^F", jp = "族長殺しのウルガルラグ^f", ru = "Ургарлаг Бич Вождей^f", zh = "乌尔加拉格·酋长克星" },
	}

	local Localize = function( key )
		local data = RAW_NAMES[key]
		return zo_strformat(SI_UNIT_NAME, data[GetCVar("Language.2")] or data.default)
	end

	LUP.NAMES = {
		[LUP.BASE1] = Localize("8290981-0-58826"),
		[LUP.BASE2] = Localize("8290981-0-58841"),
		[LUP.DLC1] = Localize("8290981-0-74695"),
	}
end
